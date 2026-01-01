import os, json, re, pathlib

with open(".tmp_narrative_review/files.txt") as f:
    files = [l.strip() for l in f if l.strip()]

TOKEN_LIMIT = int(os.environ.get("TOKEN_LIMIT", "4000"))
TARGET_CHUNK = int(os.environ.get("TARGET_CHUNK_TOKENS", "3500"))
TARGET_BATCH = int(os.environ.get("TARGET_BATCH_TOKENS", "7000"))
outdir = pathlib.Path(".tmp_narrative_review")

def est_tokens(s): return max(1, len(s) // 4)
def sanitize(n): return re.sub(r"[^A-Za-z0-9._-]+", "_", n)

def chunk_text(text):
    if est_tokens(text) <= TOKEN_LIMIT: return [text]
    lines, chunks, buf, buf_tok = text.splitlines(keepends=True), [], [], 0
    for ln in lines:
        ln_tok = est_tokens(ln)
        is_brk = ln.strip() == "" or ln.lstrip().startswith("#")
        if buf and buf_tok + ln_tok > TARGET_CHUNK and is_brk:
            chunks.append("".join(buf))
            buf, buf_tok = [], 0
        buf.append(ln)
        buf_tok += ln_tok
    if buf: chunks.append("".join(buf))
    return chunks or [text]

manifest = []
for f in files:
    p = pathlib.Path(f)
    if not p.exists(): continue
    text = p.read_text(encoding="utf-8", errors="ignore")
    parts = chunk_text(text)
    for i, part in enumerate(parts, 1):
        cp = outdir / f"{sanitize(p.as_posix())}__chunk{i:02d}.txt"
        cp.write_text(part, encoding="utf-8")
        manifest.append({"file": p.as_posix(), "chunk": i, "chunk_count": len(parts),
                         "chunk_path": cp.as_posix(), "est_tokens": est_tokens(part)})

batches = []
for f in sorted(set(c["file"] for c in manifest)):
    chs = sorted([c for c in manifest if c["file"] == f], key=lambda x: x["chunk"])
    batch, batch_tok, batch_idx = [], 0, 1
    for c in chs:
        if batch and batch_tok + c["est_tokens"] > TARGET_BATCH:
            batches.append({"file": f, "batch": batch_idx, "chunks": batch})
            batch, batch_tok, batch_idx = [], 0, batch_idx + 1
        batch.append(c)
        batch_tok += c["est_tokens"]
    if batch:
        batches.append({"file": f, "batch": batch_idx, "chunks": batch})

(outdir / "batches.json").write_text(json.dumps(batches, indent=2))
print(f"Files: {len(files)}, Batches: {len(batches)}")