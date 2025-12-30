#!/usr/bin/env python3
"""
MystiMons TCG — Set Validation Tool (no external dependencies)

Validates per-set authoring files:
- cards.json wrapper + per-card structure
- keyword_pool.json compliance (allowed/experimental/banned)
- Print vs Digital contract heuristics
- Reveal-level gating (hidden_info.reveal_level <= set_config.reveal_level)
- App-requirement gating (e.g., uses_hidden_intent requires set capability)

Usage examples:
  python3 validate_sets.py --all
  python3 validate_sets.py --set SET-004
  python3 validate_sets.py --all --strict
"""

from __future__ import annotations
import argparse
import json
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Set, Tuple


RE_SET_ID = re.compile(r"^SET-\d{3}$")
RE_CARD_ID = re.compile(r"^CARD-(SET-\d{3})-\d{3}$")
RE_KWD_ID = re.compile(r"^KWD-\d{3}$")

REVEAL_ORDER = {"S0": 0, "S1": 1, "S2": 2, "S3": 3}

CARD_TYPES = {"MystiMon", "Action", "Relic", "Terrain", "Energy"}
RARITIES = {"Common", "Uncommon", "Rare", "Ultra", "Champion"}

PRINT_FORBIDDEN_HINTS = [
    "app", "digital", "nfc", "scan", "bluetooth", "ble", "ar", "augmented", "camera",
]
RNG_HINTS = ["random", "flip", "coin", "roll", "rng", "würfel", "zufall"]


@dataclass
class Finding:
    level: str   # "ERROR" | "WARN"
    set_id: str
    card_id: Optional[str]
    message: str

    def __str__(self) -> str:
        loc = f"{self.set_id}"
        if self.card_id:
            loc += f"::{self.card_id}"
        return f"[{self.level}] {loc} — {self.message}"


def _load_json(path: Path) -> Any:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def _is_int(x: Any) -> bool:
    return isinstance(x, int) and not isinstance(x, bool)


def _validate_set_config(cfg: Dict[str, Any], set_id: str) -> List[str]:
    errs: List[str] = []

    req = ["set_id", "name", "reveal_level", "mechanic_budget", "app_requirements"]
    for k in req:
        if k not in cfg:
            errs.append(f"set_config missing required field '{k}'.")
    if errs:
        return errs

    if cfg.get("set_id") != set_id:
        errs.append(f"set_config.set_id '{cfg.get('set_id')}' does not match folder '{set_id}'.")
    if not isinstance(cfg.get("name"), str) or not cfg["name"].strip():
        errs.append("set_config.name must be a non-empty string.")
    rl = cfg.get("reveal_level")
    if rl not in REVEAL_ORDER:
        errs.append(f"set_config.reveal_level must be one of {sorted(REVEAL_ORDER.keys())}.")
    mb = cfg.get("mechanic_budget")
    if not isinstance(mb, dict):
        errs.append("set_config.mechanic_budget must be an object.")
    else:
        if "new_keywords_max" in mb and not _is_int(mb["new_keywords_max"]):
            errs.append("set_config.mechanic_budget.new_keywords_max must be an integer.")
        if "new_subsystems" in mb and not isinstance(mb["new_subsystems"], list):
            errs.append("set_config.mechanic_budget.new_subsystems must be an array.")
    ar = cfg.get("app_requirements")
    if not isinstance(ar, dict):
        errs.append("set_config.app_requirements must be an object.")
    else:
        for k in ["requires_smart_mat", "requires_hidden_intent", "requires_time_windows", "requires_chronicle_layer"]:
            if k not in ar or not isinstance(ar[k], bool):
                errs.append(f"set_config.app_requirements.{k} must be a boolean (required).")
    return errs


def _validate_keyword_pool(pool: Dict[str, Any], keywords_by_id: Dict[str, str], set_id: str) -> Tuple[Set[str], Set[str], Set[str], List[str]]:
    errs: List[str] = []
    if pool.get("set_id") != set_id:
        errs.append(f"keyword_pool.set_id '{pool.get('set_id')}' does not match '{set_id}'.")
    allowed = set(pool.get("allowed", []) or [])
    experimental = set(pool.get("experimental", []) or [])
    banned = set(pool.get("banned", []) or [])

    for group_name, group in [("allowed", allowed), ("experimental", experimental), ("banned", banned)]:
        for kw in group:
            if not isinstance(kw, str) or not RE_KWD_ID.match(kw):
                errs.append(f"keyword_pool.{group_name} contains invalid keyword id: {kw!r}")
            elif kw not in keywords_by_id:
                errs.append(f"keyword_pool.{group_name} references unknown keyword id: {kw}")
    # Disallow overlap
    if (allowed & banned) or (experimental & banned) or (allowed & experimental):
        errs.append("keyword_pool has overlapping IDs across allowed/experimental/banned.")
    return allowed, experimental, banned, errs


def _extract_kw_ids_from_tags(tags: Any) -> Set[str]:
    if not isinstance(tags, list):
        return set()
    out=set()
    for t in tags:
        if isinstance(t, str) and RE_KWD_ID.match(t):
            out.add(t)
    return out


def _find_keyword_names_in_text(text: str, keyword_name_to_id: Dict[str, str]) -> Set[str]:
    # simple whole-word-ish match, case-insensitive
    found=set()
    low = text.lower()
    for name, kid in keyword_name_to_id.items():
        n = name.lower()
        # match as a token or prefixed by ** / punctuation
        if re.search(rf"(?<![a-z0-9]){re.escape(n)}(?![a-z0-9])", low):
            found.add(kid)
    return found


def _validate_card(card: Dict[str, Any], set_cfg: Dict[str, Any], allowed: Set[str], experimental: Set[str], banned: Set[str],
                   keyword_name_to_id: Dict[str, str], set_id: str) -> Tuple[List[str], List[str]]:
    errs: List[str] = []
    warns: List[str] = []

    # required fields
    for k in ["id", "set_id", "name", "card_type", "rarity", "print", "digital"]:
        if k not in card:
            errs.append(f"card missing required field '{k}'.")
    if errs:
        return errs, warns

    cid = card.get("id")
    if not isinstance(cid, str) or not RE_CARD_ID.match(cid):
        errs.append("card.id must match pattern 'CARD-SET-XXX-YYY'.")
    else:
        m = RE_CARD_ID.match(cid)
        if m and m.group(1) != set_id:
            errs.append(f"card.id '{cid}' does not match set_id '{set_id}'.")
    if card.get("set_id") != set_id:
        errs.append(f"card.set_id '{card.get('set_id')}' does not match '{set_id}'.")
    if not isinstance(card.get("name"), str) or not card["name"].strip():
        errs.append("card.name must be a non-empty string.")
    if card.get("card_type") not in CARD_TYPES:
        errs.append(f"card.card_type must be one of {sorted(CARD_TYPES)}.")
    if card.get("rarity") not in RARITIES:
        errs.append(f"card.rarity must be one of {sorted(RARITIES)}.")

    # print
    pr = card.get("print")
    if not isinstance(pr, dict):
        errs.append("card.print must be an object.")
    else:
        if "cost" not in pr or not _is_int(pr["cost"]) or pr["cost"] < 0:
            errs.append("card.print.cost must be an integer >= 0.")
        txt = pr.get("text")
        if not isinstance(txt, str) or not txt.strip():
            errs.append("card.print.text must be a non-empty string.")
        else:
            low = txt.lower()
            if any(h in low for h in PRINT_FORBIDDEN_HINTS):
                warns.append("print.text references app/tech terms; keep print text table-clean and app-agnostic.")
            if any(h in low for h in RNG_HINTS):
                # only warn if rng isn't enabled
                dg = card.get("digital", {})
                rng_allowed = bool(((dg.get("rng") or {}).get("allowed")) if isinstance(dg, dict) else False)
                if not rng_allowed:
                    warns.append("print.text implies randomness but digital.rng.allowed is false.")
        # MystiMon stats expectation (soft enforce)
        if card.get("card_type") == "MystiMon":
            st = pr.get("stats")
            if not isinstance(st, dict):
                warns.append("MystiMon card has no print.stats; expected hp/atk/def/stage for table readability.")
            else:
                for k in ["hp", "atk", "def", "stage"]:
                    if k not in st:
                        warns.append(f"MystiMon print.stats missing '{k}'.")
                if "stage" in st and (_is_int(st["stage"]) and not (1 <= st["stage"] <= 5)):
                    errs.append("print.stats.stage must be within 1..5.")

    # digital
    dg = card.get("digital")
    if not isinstance(dg, dict):
        errs.append("card.digital must be an object.")
    else:
        if "patchable" not in dg or not isinstance(dg["patchable"], bool):
            errs.append("digital.patchable must be a boolean.")
        rng = dg.get("rng")
        if not isinstance(rng, dict) or "allowed" not in rng or not isinstance(rng["allowed"], bool):
            errs.append("digital.rng.allowed must be a boolean.")
        tr = dg.get("tracking")
        if not isinstance(tr, list) or not all(isinstance(x, str) for x in tr):
            errs.append("digital.tracking must be an array of strings.")
        hi = dg.get("hidden_info")
        if hi is not None:
            if not isinstance(hi, dict):
                errs.append("digital.hidden_info must be an object when present.")
            else:
                if "uses_hidden_intent" in hi and not isinstance(hi["uses_hidden_intent"], bool):
                    errs.append("digital.hidden_info.uses_hidden_intent must be boolean.")
                if "reveal_level" in hi:
                    rl = hi["reveal_level"]
                    if rl not in REVEAL_ORDER:
                        errs.append("digital.hidden_info.reveal_level must be S0..S3.")
                    else:
                        set_rl = set_cfg.get("reveal_level", "S0")
                        if REVEAL_ORDER[rl] > REVEAL_ORDER.get(set_rl, 0):
                            errs.append(f"digital.hidden_info.reveal_level {rl} exceeds set reveal_level {set_rl}.")
                # requirement gating
                if hi.get("uses_hidden_intent") is True and not set_cfg.get("app_requirements", {}).get("requires_hidden_intent", False):
                    errs.append("Card uses_hidden_intent but set_config.app_requirements.requires_hidden_intent is false.")
        # RNG gating heuristic
        if rng and rng.get("allowed") is True:
            # if set doesn't have Dissonance allowed/experimental, warn
            pass

    # keyword pool compliance
    tags = card.get("tags", [])
    kw_tags = _extract_kw_ids_from_tags(tags)

    # Also detect keyword name usage in print text (warn only)
    if isinstance(pr, dict) and isinstance(pr.get("text"), str):
        kw_in_text = _find_keyword_names_in_text(pr["text"], keyword_name_to_id)
        missing = kw_in_text - kw_tags
        if missing:
            warns.append("print.text contains keyword names but card.tags is missing those keyword IDs: " + ", ".join(sorted(missing)))

    # pool checks
    for kw in kw_tags:
        if kw in banned:
            errs.append(f"Uses banned keyword {kw}.")
        elif kw not in allowed and kw not in experimental:
            errs.append(f"Uses keyword {kw} not present in this set's allowed/experimental pool.")

    # RNG + keyword heuristic
    if isinstance(dg, dict):
        rng = dg.get("rng") or {}
        if isinstance(rng, dict) and rng.get("allowed") is True:
            if "KWD-004" not in kw_tags and "KWD-004" not in allowed and "KWD-004" not in experimental:
                warns.append("digital.rng.allowed is true, but Dissonance (KWD-004) is not in pool/tags; confirm this RNG is intended.")

    return errs, warns


def validate_set(project_root: Path, set_id: str, strict: bool=False) -> List[Finding]:
    findings: List[Finding] = []

    sets_dir = project_root / "03_TCG" / "sets"
    authoring_dir = project_root / "03_TCG" / "AUTHORING"
    set_dir = sets_dir / set_id

    if not set_dir.exists():
        return [Finding("ERROR", set_id, None, f"Set folder not found: {set_dir}")]

    # load keyword definitions
    kw_defs_path = authoring_dir / "KEYWORDS" / "keywords.json"
    if not kw_defs_path.exists():
        return [Finding("ERROR", set_id, None, f"Missing keyword definitions: {kw_defs_path}")]
    kw_defs = _load_json(kw_defs_path)
    keywords_by_id = {k["id"]: k.get("name","") for k in kw_defs if isinstance(k, dict) and isinstance(k.get("id"), str)}
    keyword_name_to_id = {k.get("name",""): k.get("id") for k in kw_defs if isinstance(k, dict) and isinstance(k.get("name"), str) and isinstance(k.get("id"), str)}

    # set_config
    cfg_path = set_dir / "set_config.json"
    if not cfg_path.exists():
        findings.append(Finding("ERROR", set_id, None, "Missing set_config.json"))
        return findings
    set_cfg = _load_json(cfg_path)
    for e in _validate_set_config(set_cfg, set_id):
        findings.append(Finding("ERROR", set_id, None, e))

    # keyword pool (canonical preferred)
    pool_path: Optional[Path] = None
    if isinstance(set_cfg, dict):
        kp = set_cfg.get("keyword_pool_path")
        if isinstance(kp, str) and kp.strip():
            pool_path = (set_dir / kp).resolve()
    if not pool_path or not pool_path.exists():
        # fallback to set local copy
        pool_path = set_dir / "keyword_pool.json"
    if not pool_path.exists():
        findings.append(Finding("ERROR", set_id, None, f"Missing keyword pool file: {pool_path}"))
        return findings

    pool = _load_json(pool_path)

    allowed, experimental, banned, perrs = _validate_keyword_pool(pool, keywords_by_id, set_id)
    for e in perrs:
        findings.append(Finding("ERROR", set_id, None, e))

    # If local keyword_pool.json differs from canonical pool file, warn
    local_pool_path = set_dir / "keyword_pool.json"
    if local_pool_path.exists() and local_pool_path.resolve() != pool_path.resolve():
        try:
            local_pool = _load_json(local_pool_path)
            if json.dumps(local_pool, sort_keys=True) != json.dumps(pool, sort_keys=True):
                findings.append(Finding("WARN", set_id, None, "Local keyword_pool.json differs from canonical pool; canonical is used for validation."))
        except Exception:
            findings.append(Finding("WARN", set_id, None, "Could not compare local keyword_pool.json to canonical pool."))

    # cards
    cards_path = set_dir / "cards.json"
    if not cards_path.exists():
        findings.append(Finding("ERROR", set_id, None, "Missing cards.json"))
        return findings
    cards_file = _load_json(cards_path)
    if not isinstance(cards_file, dict) or cards_file.get("set_id") != set_id or "cards" not in cards_file:
        findings.append(Finding("ERROR", set_id, None, "cards.json must be an object with { set_id, cards }."))
        return findings
    cards = cards_file.get("cards")
    if not isinstance(cards, list):
        findings.append(Finding("ERROR", set_id, None, "cards.json.cards must be an array."))
        return findings
    if len(cards) == 0:
        findings.append(Finding("WARN", set_id, None, "cards.json contains 0 cards (ok for scaffolding; ignore if WIP)."))

    # unique ids
    seen: Set[str] = set()
    for c in cards:
        cid = c.get("id") if isinstance(c, dict) else None
        if isinstance(cid, str):
            if cid in seen:
                findings.append(Finding("ERROR", set_id, cid, "Duplicate card.id within set."))
            seen.add(cid)

    # per-card validations
    for c in cards:
        if not isinstance(c, dict):
            findings.append(Finding("ERROR", set_id, None, "cards.json.cards contains a non-object entry."))
            continue
        cid = c.get("id") if isinstance(c.get("id"), str) else None
        errs, warns = _validate_card(c, set_cfg if isinstance(set_cfg, dict) else {}, allowed, experimental, banned, keyword_name_to_id, set_id)
        for e in errs:
            findings.append(Finding("ERROR", set_id, cid, e))
        for w in warns:
            findings.append(Finding("WARN", set_id, cid, w))

    # strict mode: upgrade WARN to ERROR
    if strict:
        findings = [Finding("ERROR" if f.level == "WARN" else f.level, f.set_id, f.card_id, f.message) for f in findings]

    return findings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--project-root", type=str, default=None, help="Path to MYSTIMONS directory (defaults to auto-detect).")
    parser.add_argument("--set", dest="set_id", type=str, default=None, help="Validate only a single set (e.g. SET-004).")
    parser.add_argument("--all", action="store_true", help="Validate all sets under 03_TCG/sets.")
    parser.add_argument("--strict", action="store_true", help="Treat warnings as errors.")
    args = parser.parse_args()

    # auto-detect project root: .../03_TCG/AUTHORING/TOOLS/validate_sets.py -> up 3 -> MYSTIMONS
    if args.project_root:
        project_root = Path(args.project_root).resolve()
    else:
        project_root = Path(__file__).resolve().parents[3]  # MYSTIMONS
    if not (project_root / "03_TCG").exists():
        print(f"[ERROR] Could not locate project root at: {project_root}")
        print("        Pass --project-root /path/to/MYSTIMONS")
        return 2

    sets_dir = project_root / "03_TCG" / "sets"
    if args.set_id:
        set_ids = [args.set_id]
    elif args.all or not args.set_id:
        set_ids = sorted([p.name for p in sets_dir.iterdir() if p.is_dir() and RE_SET_ID.match(p.name)])
    else:
        parser.print_help()
        return 2

    all_findings: List[Finding] = []
    for sid in set_ids:
        all_findings.extend(validate_set(project_root, sid, strict=args.strict))

    # report
    errors = [f for f in all_findings if f.level == "ERROR"]
    warns = [f for f in all_findings if f.level == "WARN"]

    for f in all_findings:
        print(str(f))

    print(f"\nSummary: {len(errors)} error(s), {len(warns)} warning(s) across {len(set_ids)} set(s).")
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
