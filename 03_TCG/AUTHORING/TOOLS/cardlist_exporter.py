#!/usr/bin/env python3
"""MystiMons Cardlist Exporter

Converts between:
- Markdown pipe-table cardlists (human review) and
- cards.json (machine-readable, set wrapper: {set_id, cards})

Usage:
  python cardlist_exporter.py md2json --set-id SET-001 --md CARD_LIST.md --out cards.json
  python cardlist_exporter.py json2md --json cards.json --out CARD_LIST.md

Markdown format (single table expected; header names are case-insensitive):
| id | name | card_type | rarity | cost | stats | print_text | tracking | rng | patchable | tags | notes |
"""

import argparse
import json
import re
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

DEFAULT_COLUMNS = ["id","name","card_type","rarity","cost","stats","print_text","tracking","rng","patchable","tags","notes"]

def _split_row(line: str) -> List[str]:
    raw = line.strip().strip("|")
    return [p.strip() for p in raw.split("|")]

def _find_table(lines: List[str]) -> Tuple[List[str], List[List[str]]]:
    for i in range(len(lines)-2):
        if "|" not in lines[i]:
            continue
        header = _split_row(lines[i])
        sep = lines[i+1].strip()
        if re.fullmatch(r"\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)+\|?", sep):
            rows = []
            j = i+2
            while j < len(lines) and "|" in lines[j]:
                row = _split_row(lines[j])
                if any(cell.strip() for cell in row):
                    rows.append(row)
                j += 1
            return header, rows
    raise ValueError("No markdown pipe-table found (expected header + separator + rows).")

def _norm(s: str) -> str:
    return re.sub(r"\s+","_",s.strip().lower())

def _parse_stats(stats: str) -> Optional[Dict[str,int]]:
    if not stats or stats.strip() in {"-","—"}:
        return None
    s = stats.strip()
    m = re.findall(r"(HP|ATK|DEF)\s*(\d+)", s, flags=re.IGNORECASE)
    if m:
        out={}
        for k,v in m:
            out[k.upper()] = int(v)
        return out
    m2 = re.fullmatch(r"(\d+)\s*/\s*(\d+)\s*/\s*(\d+)", s)
    if m2:
        hp, atk, df = map(int, m2.groups())
        return {"HP":hp,"ATK":atk,"DEF":df}
    return None

def _parse_list(cell: str) -> List[str]:
    if not cell or cell.strip() in {"-","—"}:
        return []
    return [c.strip() for c in cell.split(",") if c.strip()]

def md_to_cards(set_id: str, md_path: Path) -> List[Dict[str,Any]]:
    lines = md_path.read_text(encoding="utf-8").splitlines()
    header, rows = _find_table(lines)
    cols = [_norm(h) for h in header]
    col_index = {c:i for i,c in enumerate(cols)}

    def cell(row, key, default=""):
        keyn=_norm(key)
        if keyn not in col_index:
            return default
        i=col_index[keyn]
        return row[i].strip() if i < len(row) else default

    cards=[]
    for r in rows:
        cid = cell(r,"id")
        if not cid:
            continue
        card={
            "id": cid,
            "set_id": set_id,
            "name": cell(r,"name"),
            "card_type": cell(r,"card_type"),
            "rarity": cell(r,"rarity") or "Common",
            "tags": _parse_list(cell(r,"tags")),
            "print": {
                "cost": int(cell(r,"cost") or "0"),
                "text": cell(r,"print_text")
            },
            "digital": {
                "patchable": (cell(r,"patchable") or "true").strip().lower() in {"true","1","yes","y"},
                "rng": {
                    "allowed": (cell(r,"rng") or "none").strip().lower() not in {"none","no","false","0","-","—"},
                    "notes": "" if (cell(r,"rng") or "").strip().lower() in {"none","no","false","0","-","—"} else cell(r,"rng")
                },
                "tracking": _parse_list(cell(r,"tracking"))
            },
            "links": {},
            "version": "0.1"
        }
        stats = _parse_stats(cell(r,"stats"))
        if stats:
            card["print"]["stats"] = stats
        notes = cell(r,"notes")
        if notes:
            card["digital"]["notes"] = notes
        cards.append(card)
    return cards

def cards_to_md(cards: List[Dict[str,Any]]) -> str:
    lines=[]
    lines.append("| " + " | ".join(DEFAULT_COLUMNS) + " |")
    lines.append("|" + "|".join(["---"]*len(DEFAULT_COLUMNS)) + "|")
    for c in cards:
        stats = c.get("print",{}).get("stats")
        stats_s = "-"
        if isinstance(stats, dict) and stats:
            hp = stats.get("HP","")
            atk = stats.get("ATK","")
            df = stats.get("DEF","")
            parts=[]
            if hp!="": parts.append(f"HP {hp}")
            if atk!="": parts.append(f"ATK {atk}")
            if df!="": parts.append(f"DEF {df}")
            stats_s=" / ".join(parts) if parts else "-"
        rng = c.get("digital",{}).get("rng",{})
        rng_s = "none"
        if rng.get("allowed"):
            rng_s = (rng.get("notes") or "allowed").strip()
        tracking = ", ".join(c.get("digital",{}).get("tracking") or []) or "-"
        tags = ", ".join(c.get("tags") or []) or "-"
        row = [
            c.get("id",""),
            c.get("name",""),
            c.get("card_type",""),
            c.get("rarity",""),
            str(c.get("print",{}).get("cost",0)),
            stats_s,
            (c.get("print",{}).get("text","") or "").replace("\n"," "),
            tracking,
            rng_s,
            "true" if c.get("digital",{}).get("patchable",True) else "false",
            tags,
            (c.get("digital",{}).get("notes","") or "")
        ]
        lines.append("| " + " | ".join(row) + " |")
    return "\n".join(lines) + "\n"

def read_cards_file(path: Path) -> Dict[str,Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(data, dict) and "cards" in data:
        return data
    if isinstance(data, list):
        # legacy: list of cards only
        return {"set_id": "", "cards": data}
    raise ValueError("Unsupported cards.json format (expected {set_id, cards} or [cards]).")

def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)

    md2j = sub.add_parser("md2json")
    md2j.add_argument("--set-id", required=True)
    md2j.add_argument("--md", required=True)
    md2j.add_argument("--out", required=True)

    j2md = sub.add_parser("json2md")
    j2md.add_argument("--json", required=True)
    j2md.add_argument("--out", required=True)

    args = ap.parse_args()

    if args.cmd == "md2json":
        cards = md_to_cards(args.set_id, Path(args.md))
        wrapper = {"set_id": args.set_id, "cards": cards}
        Path(args.out).write_text(json.dumps(wrapper, ensure_ascii=False, indent=2), encoding="utf-8")
    elif args.cmd == "json2md":
        wrapper = read_cards_file(Path(args.json))
        Path(args.out).write_text(cards_to_md(wrapper.get("cards",[])), encoding="utf-8")

if __name__ == "__main__":
    main()
