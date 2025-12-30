from __future__ import annotations

import hashlib
import os
import shutil
import subprocess
import uuid
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict, Any, List
import threading
import time


from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel

def _find_repo_root(start: Path) -> Path | None:
    """Walk upwards from start to find a directory containing .git."""
    start = start.resolve()
    for p in [start] + list(start.parents):
        if (p / ".git").exists():
            return p
    return None



# --- CONFIG ---
_env_repo = os.environ.get("MYSTIMONS_REPO_ROOT")
if _env_repo:
    REPO_ROOT = Path(_env_repo).resolve()
else:
    REPO_ROOT = (
        _find_repo_root(Path.cwd())
        or _find_repo_root(Path(__file__).resolve().parent)
        or Path(__file__).resolve().parents[1]  # fallback
    )


PROJECT_ROOT = REPO_ROOT  # alias

VALIDATOR = REPO_ROOT / "03_TCG" / "AUTHORING" / "TOOLS" / "validate_sets.py"

# --- /git/push Guardrails ---
ALLOWED_REMOTE = "https://github.com/MystiMons/mystimons.git"
SMOKE_TEST_SCRIPT = REPO_ROOT / "tools" / "run_smoke_test.ps1"
SMOKE_TEST_TIMEOUT_SEC = 600  # 10 Minuten
MAX_IO_CHARS = 8000  # max chars returned for stdout/stderr

TOOL_TOKEN_ENV = "MYSTIMONS_TOOL_TOKEN"  # optional: wenn gesetzt, muss X-Tool-Token passen

# --- /git/push Branch Policy ---
ALLOWED_BRANCH_PREFIXES = (
    "feature/",
    "fix/",
    "docs/",
    "chore/",
    "change/",
    "hotfix/",
)

def _is_allowed_push_branch(branch: str) -> bool:
    return any(branch.startswith(p) for p in ALLOWED_BRANCH_PREFIXES)



GIT_LOCK = threading.Lock()

SERVER_ROOT = REPO_ROOT / "server"
CHANGES_ROOT = SERVER_ROOT / ".changes"
TMP_ROOT = SERVER_ROOT / ".tmp"


PYTHON_EXE = (
    str(Path(os.environ["VIRTUAL_ENV"]) / "Scripts" / "python.exe")
    if os.environ.get("VIRTUAL_ENV")
    else "python"
)

app = FastAPI(title="MystiMons Tool Server (MVP)", version="0.2")


# -------------------------
# Helpers
# -------------------------

def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def sha256_text(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def safe_resolve(rel_path: str) -> Path:
    """
    Prevent path traversal and restrict reads/writes to within REPO_ROOT.
    """
    p = (REPO_ROOT / rel_path).resolve()
    root = REPO_ROOT.resolve()
    if not str(p).startswith(str(root) + os.sep) and p != root:
        raise HTTPException(status_code=400, detail="Invalid path (outside repo root).")
    return p


def ensure_dirs():
    CHANGES_ROOT.mkdir(parents=True, exist_ok=True)
    TMP_ROOT.mkdir(parents=True, exist_ok=True)


def change_dir(change_id: str) -> Path:
    return CHANGES_ROOT / change_id


def manifest_path(change_id: str) -> Path:
    return change_dir(change_id) / "manifest.json"


def load_manifest(change_id: str) -> Dict[str, Any]:
    mp = manifest_path(change_id)
    if not mp.exists():
        raise HTTPException(status_code=404, detail="Unknown change_id.")
    return json.loads(mp.read_text(encoding="utf-8"))


def save_manifest(change_id: str, manifest: Dict[str, Any]) -> None:
    mp = manifest_path(change_id)
    mp.write_text(json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8")


def is_canon_path(rel_path: str) -> bool:
    # treat everything under 00_CANON as gated
    return rel_path.replace("\\", "/").startswith("00_CANON/")


def apply_ignore_patterns(src: str, names):
    # keep it conservative; repo is mostly text, but ignore obvious noise
    ignore = {
        ".git",
        ".venv",
        "__pycache__",
        "node_modules",
        ".changes",
        ".tmp",
    }
    return {n for n in names if n in ignore}

def run_git(args: List[str], cwd: Path) -> subprocess.CompletedProcess:
    proc = subprocess.run(["git", *args], cwd=str(cwd), capture_output=True, text=True)
    return proc

def _run_smoke_test_or_raise(repo_root: Path) -> None:
    if not SMOKE_TEST_SCRIPT.exists():
        raise HTTPException(status_code=400, detail={
            "error": "smoke_test_script_missing",
            "path": str(SMOKE_TEST_SCRIPT),
        })

    try:
        p = subprocess.run(
            [
                "powershell",
                "-NoProfile",
                "-ExecutionPolicy", "Bypass",
                "-File", str(SMOKE_TEST_SCRIPT),
            ],
            cwd=str(repo_root),
            capture_output=True,
            text=True,
            timeout=SMOKE_TEST_TIMEOUT_SEC,
        )
    except subprocess.TimeoutExpired:
        raise HTTPException(status_code=400, detail={
            "error": "smoke_test_timeout",
            "timeout_sec": SMOKE_TEST_TIMEOUT_SEC,
        })

    if p.returncode != 0:
        raise HTTPException(status_code=400, detail={
            "error": "smoke_test_failed",
            "exit_code": p.returncode,
            "stdout": _trim_io(p.stdout),
            "stderr": _trim_io(p.stderr),
        })


# -------------------------
# Models
# -------------------------
class WriteRequest(BaseModel):
    path: str
    base_sha256: str
    new_content: str
    decision_id: Optional[str] = None
    rationale: Optional[str] = None


class ChangeOpenRequest(BaseModel):
    title: str = "Untitled change"
    intent: str = ""
    author: Optional[str] = None


class ChangeStageRequest(BaseModel):
    change_id: str
    path: str
    base_sha256: str
    new_content: str
    decision_id: Optional[str] = None
    rationale: Optional[str] = None


class ChangeStageFromCurrentRequest(BaseModel):
    change_id: str
    path: str
    decision_id: Optional[str] = None
    rationale: Optional[str] = None


class ChangeValidateRequest(BaseModel):
    change_id: str
    set_id: Optional[str] = None
    strict: bool = False


class ChangeCommitRequest(BaseModel):
    change_id: str
    branch_name: Optional[str] = None
    message: Optional[str] = None



# -------------------------
# Basic Endpoints
# -------------------------
@app.get("/health")
def health():
    ensure_dirs()
    return {
        "ok": True,
        "repo_root": str(REPO_ROOT),
        "validator_exists": VALIDATOR.exists(),
        "python_exe": PYTHON_EXE,
        "changes_root": str(CHANGES_ROOT),
    }


@app.get("/git/status")
def git_status():
    # git version
    v = run_git(["--version"], REPO_ROOT)
    if v.returncode != 0:
        raise HTTPException(status_code=500, detail={"error": "git_not_available", "stderr": v.stderr})

    # are we in a repo?
    inside = run_git(["rev-parse", "--is-inside-work-tree"], REPO_ROOT)
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        return {"ok": False, "git_version": v.stdout.strip(), "repo": False}

    branch = run_git(["rev-parse", "--abbrev-ref", "HEAD"], REPO_ROOT)
    dirty = run_git(["status", "--porcelain"], REPO_ROOT)

    return {
        "ok": True,
        "git_version": v.stdout.strip(),
        "repo": True,
        "branch": branch.stdout.strip() if branch.returncode == 0 else None,
        "dirty": bool(dirty.stdout.strip()),
        "porcelain": dirty.stdout,
    }






def _run_git(args: list[str], cwd: Path) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["git", *args],
        cwd=str(cwd),
        capture_output=True,
        text=True,
        shell=False
    )

def _trim_io(s: str | None, limit: int = MAX_IO_CHARS) -> str:
    if not s:
        return ""
    if len(s) <= limit:
        return s
    extra = len(s) - limit
    return s[:limit] + f"\n... [truncated {extra} chars]"



def _run_smoke_test(cwd: Path) -> subprocess.CompletedProcess:
    if not SMOKE_TEST_SCRIPT.exists():
        return subprocess.CompletedProcess(
            args=["powershell", "-File", str(SMOKE_TEST_SCRIPT)],
            returncode=2,
            stdout="",
            stderr=f"Smoke test script not found: {SMOKE_TEST_SCRIPT}"
        )

    return subprocess.run(
        [
            "powershell",
            "-NoProfile",
            "-ExecutionPolicy", "Bypass",
            "-File", str(SMOKE_TEST_SCRIPT)
        ],
        cwd=str(cwd),
        capture_output=True,
        text=True,
        shell=False,
        timeout=SMOKE_TEST_TIMEOUT_SEC

    )



class GitPushRequest(BaseModel):
    remote: str = "origin"
    branch: str | None = None
    set_upstream: bool = True
    force: bool = False
    tags: bool = False
    dry_run: bool = False
    run_smoke_test: bool = True


@app.post("/git/push")
def git_push(req: GitPushRequest, x_tool_token: str | None = Header(default=None, alias="X-Tool-Token")):
    t0 = time.time()

    expected = os.environ.get("MYSTIMONS_TOOL_TOKEN")
    if expected:
        if not x_tool_token or x_tool_token != expected:
            raise HTTPException(status_code=401, detail="Missing/invalid X-Tool-Token.")

    if req.force:
        raise HTTPException(status_code=403, detail="Force push is not allowed.")

    if not REPO_ROOT.exists():
        raise HTTPException(status_code=500, detail=f"Repo root not found: {REPO_ROOT}")

    with GIT_LOCK:
        # Remote URL allowlist
        r = _run_git(["remote", "get-url", req.remote], REPO_ROOT)
        if r.returncode != 0:
            raise HTTPException(status_code=400, detail=f"Remote '{req.remote}' not found: {r.stderr.strip()}")
        remote_url = r.stdout.strip()
        if remote_url != ALLOWED_REMOTE:
            raise HTTPException(status_code=403, detail=f"Remote URL not allowed: {remote_url}")

    # Current branch
        b = _run_git(["branch", "--show-current"], REPO_ROOT)
        if b.returncode != 0:
            raise HTTPException(status_code=500, detail=_trim_io(b.stderr) or _trim_io(b.stdout))
        current_branch = b.stdout.strip()

        branch = (req.branch or current_branch).strip()
        if req.branch and branch != current_branch:
            raise HTTPException(status_code=400, detail={
                "error": "branch_must_match_current_checkout",
                "current_branch": current_branch,
                "requested_branch": req.branch,
            })

        # Block main always
        if branch == "main":
            raise HTTPException(status_code=403, detail="Direct pushes from 'main' are blocked. Use a feature branch + PR.")

        # Allowlist branch prefixes
        if not _is_allowed_push_branch(branch):
            raise HTTPException(status_code=403, detail={
                "error": "branch_not_allowed_for_git_push",
                "branch": branch,
                "allowed_prefixes": list(ALLOWED_BRANCH_PREFIXES),
            })

        # Working tree clean?
        s = _run_git(["status", "--porcelain"], REPO_ROOT)
        if s.returncode != 0:
            raise HTTPException(status_code=500, detail=_trim_io(s.stderr) or _trim_io(s.stdout))
        if s.stdout.strip():
            raise HTTPException(status_code=400, detail={
                "error": "working_tree_not_clean",
                "porcelain": _trim_io(s.stdout),
            })

        # Optional smoke-test gate
        if getattr(req, "run_smoke_test", True):
            _run_smoke_test_or_raise(REPO_ROOT)


        # Push command
        push_args = ["push"]
        if req.dry_run:
            push_args.append("--dry-run")
        if req.tags:
            push_args.append("--tags")

        if req.set_upstream:
            push_args += ["-u", req.remote, branch]
        else:
            push_args += [req.remote, branch]

        p = _run_git(push_args, REPO_ROOT)
        dt = int((time.time() - t0) * 1000)

        if p.returncode != 0:
            raise HTTPException(status_code=400, detail={
                "error": "git push failed",
                "stdout": _trim_io(p.stdout),
                "stderr": _trim_io(p.stderr),
                "duration_ms": dt
            })

        return {
            "ok": True,
            "remote": req.remote,
            "remote_url": remote_url,
            "branch": branch,
            "stdout": _trim_io(p.stdout),
            "stderr": _trim_io(p.stderr),
            "duration_ms": dt
        }



@app.get("/artifact")
def read_artifact(path: str):
    p = safe_resolve(path)
    if not p.exists() or not p.is_file():
        raise HTTPException(status_code=404, detail="File not found.")
    content = p.read_text(encoding="utf-8")
    return {"path": path, "sha256": sha256_text(content), "content": content}


@app.post("/artifact/write")
def write_artifact(req: WriteRequest):
    # Canon gate
    if is_canon_path(req.path):
        if not req.decision_id:
            raise HTTPException(
                status_code=403,
                detail="Writes to 00_CANON require decision_id (canon gate).",
            )

    p = safe_resolve(req.path)
    if not p.exists() or not p.is_file():
        raise HTTPException(status_code=404, detail="File not found.")

    current = p.read_text(encoding="utf-8")
    current_hash = sha256_text(current)

    if req.base_sha256 != current_hash:
        raise HTTPException(
            status_code=409,
            detail={"error": "base_sha256_mismatch", "current_sha256": current_hash},
        )

    p.write_text(req.new_content, encoding="utf-8")
    return {"path": req.path, "sha256": sha256_text(req.new_content), "written": True}


@app.post("/validate/set")
def validate_set(set_id: str, strict: bool = False):
    if not VALIDATOR.exists():
        raise HTTPException(status_code=500, detail="Validator script not found.")

    cmd = [PYTHON_EXE, str(VALIDATOR), "--set", set_id]
    if strict:
        cmd.append("--strict")

    proc = subprocess.run(cmd, cwd=str(REPO_ROOT), capture_output=True, text=True)

    return {
        "set_id": set_id,
        "strict": strict,
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


@app.post("/validate/all")
def validate_all(strict: bool = False):
    if not VALIDATOR.exists():
        raise HTTPException(status_code=500, detail="Validator script not found.")

    cmd = [PYTHON_EXE, str(VALIDATOR), "--all"]
    if strict:
        cmd.append("--strict")

    proc = subprocess.run(cmd, cwd=str(REPO_ROOT), capture_output=True, text=True)

    return {
        "strict": strict,
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


# -------------------------
# Change Bundles (PR-light)
# -------------------------
@app.post("/changes/open")
def changes_open(req: ChangeOpenRequest):
    ensure_dirs()
    cid = uuid.uuid4().hex
    cdir = change_dir(cid)
    (cdir / "staged").mkdir(parents=True, exist_ok=True)

    manifest = {
        "change_id": cid,
        "title": req.title,
        "intent": req.intent,
        "author": req.author,
        "created_at": now_iso(),
        "status": "open",
        "files": {},  # path -> {base_sha256, new_sha256}
        "canon_notes": [],  # list of {path, decision_id, rationale}
    }
    save_manifest(cid, manifest)
    return {"change_id": cid, "created_at": manifest["created_at"]}


@app.get("/changes/status")
def changes_status(change_id: str):
    manifest = load_manifest(change_id)
    return manifest


@app.post("/changes/stage")
def changes_stage(req: ChangeStageRequest):
    ensure_dirs()
    manifest = load_manifest(req.change_id)

    # Canon gate
    if is_canon_path(req.path):
        if not req.decision_id:
            raise HTTPException(
                status_code=403,
                detail="Staging to 00_CANON requires decision_id (canon gate).",
            )
        manifest["canon_notes"].append(
            {
                "path": req.path,
                "decision_id": req.decision_id,
                "rationale": req.rationale or "",
                "staged_at": now_iso(),
            }
        )

    # Ensure file exists in repo now, and base matches
    p = safe_resolve(req.path)
    if not p.exists() or not p.is_file():
        raise HTTPException(status_code=404, detail="File not found.")

    current = p.read_text(encoding="utf-8")
    current_hash = sha256_text(current)
    if req.base_sha256 != current_hash:
        raise HTTPException(
            status_code=409,
            detail={"error": "base_sha256_mismatch", "current_sha256": current_hash},
        )

    new_hash = sha256_text(req.new_content)

    # write staged file
    staged_file = (change_dir(req.change_id) / "staged" / req.path).resolve()
    staged_file.parent.mkdir(parents=True, exist_ok=True)
    staged_file.write_text(req.new_content, encoding="utf-8")

    # update manifest
    manifest["files"][req.path] = {"base_sha256": req.base_sha256, "new_sha256": new_hash}
    manifest["updated_at"] = now_iso()
    save_manifest(req.change_id, manifest)

    return {"change_id": req.change_id, "path": req.path, "staged": True, "new_sha256": new_hash}

@app.post("/changes/stage_from_current")
def changes_stage_from_current(req: ChangeStageFromCurrentRequest):
    ensure_dirs()
    manifest = load_manifest(req.change_id)

    # Canon gate
    if is_canon_path(req.path):
        if not req.decision_id:
            raise HTTPException(
                status_code=403,
                detail="Staging to 00_CANON requires decision_id (canon gate).",
            )
        manifest["canon_notes"].append(
            {
                "path": req.path,
                "decision_id": req.decision_id,
                "rationale": req.rationale or "",
                "staged_at": now_iso(),
            }
        )

    p = safe_resolve(req.path)
    if not p.exists() or not p.is_file():
        raise HTTPException(status_code=404, detail="File not found.")

    content = p.read_text(encoding="utf-8")
    base_hash = sha256_text(content)
    new_hash = base_hash  # no-op stage

    staged_file = (change_dir(req.change_id) / "staged" / req.path).resolve()
    staged_file.parent.mkdir(parents=True, exist_ok=True)
    staged_file.write_text(content, encoding="utf-8")

    manifest["files"][req.path] = {"base_sha256": base_hash, "new_sha256": new_hash}
    manifest["updated_at"] = now_iso()
    save_manifest(req.change_id, manifest)

    return {
        "change_id": req.change_id,
        "path": req.path,
        "staged": True,
        "base_sha256": base_hash,
        "new_sha256": new_hash,
        "note": "staged from current (no-op)",
    }



@app.post("/changes/validate")
def changes_validate(req: ChangeValidateRequest):
    ensure_dirs()
    manifest = load_manifest(req.change_id)

    # build temp workspace
    temp_repo = (TMP_ROOT / req.change_id).resolve()
    if temp_repo.exists():
        shutil.rmtree(temp_repo)

    shutil.copytree(
        REPO_ROOT,
        temp_repo,
        ignore=apply_ignore_patterns,
        dirs_exist_ok=False,
    )

    # overlay staged files
    for rel_path in manifest["files"].keys():
        staged_file = change_dir(req.change_id) / "staged" / rel_path
        if not staged_file.exists():
            raise HTTPException(status_code=500, detail=f"Missing staged file: {rel_path}")
        dest = (temp_repo / rel_path).resolve()
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(staged_file.read_text(encoding="utf-8"), encoding="utf-8")

    # run validator inside temp workspace
    validator_in_temp = temp_repo / "03_TCG" / "AUTHORING" / "TOOLS" / "validate_sets.py"
    if not validator_in_temp.exists():
        raise HTTPException(status_code=500, detail="Validator missing in temp workspace.")

    if req.set_id:
        cmd = [PYTHON_EXE, str(validator_in_temp), "--set", req.set_id]
    else:
        cmd = [PYTHON_EXE, str(validator_in_temp), "--all"]
    if req.strict:
        cmd.append("--strict")

    proc = subprocess.run(cmd, cwd=str(temp_repo), capture_output=True, text=True)

    manifest["last_validation"] = {
        "at": now_iso(),
        "set_id": req.set_id,
        "strict": req.strict,
        "exit_code": proc.returncode,
    }
    save_manifest(req.change_id, manifest)

    return {
        "change_id": req.change_id,
        "set_id": req.set_id,
        "strict": req.strict,
        "exit_code": proc.returncode,
        "stdout": proc.stdout,
        "stderr": proc.stderr,
        "ok": proc.returncode == 0,
    }


@app.post("/changes/apply")
def changes_apply(change_id: str):
    ensure_dirs()
    manifest = load_manifest(change_id)

    # Apply staged files to repo with base hash check again (safety)
    applied = []
    for rel_path, meta in manifest["files"].items():
        p = safe_resolve(rel_path)
        if not p.exists() or not p.is_file():
            raise HTTPException(status_code=404, detail=f"File missing at apply time: {rel_path}")

        current = p.read_text(encoding="utf-8")
        current_hash = sha256_text(current)
        if current_hash != meta["base_sha256"]:
            raise HTTPException(
                status_code=409,
                detail={
                    "error": "base_sha256_mismatch_at_apply",
                    "path": rel_path,
                    "expected_base": meta["base_sha256"],
                    "current_sha256": current_hash,
                },
            )

        staged_file = change_dir(change_id) / "staged" / rel_path
        if not staged_file.exists():
            raise HTTPException(status_code=500, detail=f"Missing staged file at apply: {rel_path}")

        new_content = staged_file.read_text(encoding="utf-8")
        p.write_text(new_content, encoding="utf-8")
        applied.append(rel_path)

    manifest["status"] = "applied"
    manifest["applied_at"] = now_iso()
    save_manifest(change_id, manifest)

    return {"change_id": change_id, "applied_files": applied, "status": "applied"}


@app.post("/changes/commit")
def changes_commit(req: ChangeCommitRequest):
    ensure_dirs()
    manifest = load_manifest(req.change_id)

    # enforce validation gate
    lv = manifest.get("last_validation")
    if not lv:
        raise HTTPException(status_code=412, detail="No last_validation found. Run /changes/validate first.")
    if lv.get("exit_code") != 0:
        raise HTTPException(status_code=412, detail={"error": "validation_failed", "last_validation": lv})

    # ensure git is available and repo is clean
    v = run_git(["--version"], REPO_ROOT)
    if v.returncode != 0:
        raise HTTPException(status_code=500, detail={"error": "git_not_available", "stderr": v.stderr})

    inside = run_git(["rev-parse", "--is-inside-work-tree"], REPO_ROOT)
    if inside.returncode != 0 or inside.stdout.strip() != "true":
        raise HTTPException(status_code=500, detail="REPO_ROOT is not a git repository (run git init).")

    dirty = run_git(["status", "--porcelain"], REPO_ROOT)
    if dirty.stdout.strip():
        raise HTTPException(status_code=409, detail={"error": "working_tree_dirty", "porcelain": dirty.stdout})

    # branch handling
    branch = req.branch_name or f"change/{req.change_id}"
    exists = run_git(["rev-parse", "--verify", branch], REPO_ROOT)

    if exists.returncode == 0:
        sw = run_git(["switch", branch], REPO_ROOT)
    else:
        sw = run_git(["switch", "-c", branch], REPO_ROOT)

    if sw.returncode != 0:
        raise HTTPException(status_code=500, detail={"error": "git_switch_failed", "stdout": sw.stdout, "stderr": sw.stderr})

    # apply staged files to repo (no base hash re-check here; stage already checked base)
    applied = []
    for rel_path in manifest.get("files", {}).keys():
        staged_file = change_dir(req.change_id) / "staged" / rel_path
        if not staged_file.exists():
            raise HTTPException(status_code=500, detail=f"Missing staged file: {rel_path}")

        dest = safe_resolve(rel_path)
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(staged_file.read_text(encoding="utf-8"), encoding="utf-8")
        applied.append(rel_path)

    add = run_git(["add", *applied], REPO_ROOT)
    if add.returncode != 0:
        raise HTTPException(status_code=500, detail={"error": "git_add_failed", "stdout": add.stdout, "stderr": add.stderr})

    # commit (handle "nothing to commit")
    title = manifest.get("title", "change")
    msg = req.message or f"change({req.change_id}): {title}"

    commit = run_git(["commit", "-m", msg], REPO_ROOT)
    if commit.returncode != 0:
        # common case: nothing to commit
        st = run_git(["status", "--porcelain"], REPO_ROOT)
        if not st.stdout.strip():
            return {
                "change_id": req.change_id,
                "branch": branch,
                "applied_files": applied,
                "committed": False,
                "reason": "nothing_to_commit",
            }
        raise HTTPException(status_code=500, detail={"error": "git_commit_failed", "stdout": commit.stdout, "stderr": commit.stderr})

    # get commit hash
    head = run_git(["rev-parse", "HEAD"], REPO_ROOT)
    return {
        "change_id": req.change_id,
        "branch": branch,
        "applied_files": applied,
        "committed": True,
        "commit": head.stdout.strip() if head.returncode == 0 else None,
        "message": msg,
    }

