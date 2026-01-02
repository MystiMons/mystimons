#!/usr/bin/env python3
"""MystiMons TCG — Deck Validation Tool (v0.5)

Validates a decklist JSON file against:
- deck.schema.json
- deck_rules.json
- available cards in 03_TCG/sets/**/cards.json

Exit codes:
0 = ok
1 = validation errors
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Dict, Any, List, Tuple

from jsonschema import Draft202012Validator


def load_json(path: Path) -> Any:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except UnicodeDecodeError:
        return json.loads(path.read_text(encoding="latin-1"))


def load_schema(schema_path: Path) -> Draft202012Validator:
    schema = load_json(schema_path)
    return Draft202012Validator(schema)


def collect_cards(project_root: Path, set_filter: List[str] | None = None) -> Dict[str, Dict[str, Any]]:
    cards_by_id: Dict[str, Dict[str, Any]] = {}
    sets_dir = project_root / "03_TCG" / "sets"
    for set_dir in sorted(sets_dir.glob("SET-*")):
        if set_filter and set_dir.name not in set_filter:
            continue
        cards_file = set_dir / "cards.json"
        if not cards_file.exists():
            continue
        data = load_json(cards_file)
        for card in data.get("cards", []):
            cid = card.get("id")
            if cid:
                cards_by_id[cid] = card
    return cards_by_id


def is_legendary(card: Dict[str, Any], rules: Dict[str, Any]) -> bool:
    ld = rules.get("legendary_detection", {})
    # rarity heuristic
    if card.get("rarity") in ld.get("rarity", []):
        return True
    # tag regex heuristic
    rx = ld.get("tag_regex")
    if rx:
        tags = " ".join(card.get("tags", []))
        if re.search(rx, tags):
            return True
    return False


def validate_deck(deck: Dict[str, Any], cards_db: Dict[str, Dict[str, Any]], ruleset: Dict[str, Any], ignore_minimums: bool) -> Tuple[List[str], List[str]]:
    errors: List[str] = []
    warnings: List[str] = []

    fmt = deck.get("format")
    if fmt not in ruleset["formats"]:
        errors.append(f"Unknown format '{fmt}'. Allowed: {', '.join(ruleset['formats'].keys())}")
        return errors, warnings

    fmt_rules = ruleset["formats"][fmt]

    # Expand deck entries
    counts: Dict[str, int] = {}
    total = 0
    for entry in deck.get("cards", []):
        cid = entry["card_id"]
        n = int(entry["count"])
        total += n
        counts[cid] = counts.get(cid, 0) + n

    # Deck size
    size_min = fmt_rules["deck_size"]["min"]
    size_max = fmt_rules["deck_size"]["max"]
    if not (size_min <= total <= size_max):
        errors.append(f"Deck size {total} outside allowed range [{size_min}, {size_max}] for format {fmt}.")

    # Card existence + copy limits + type counts
    by_type: Dict[str, int] = {}
    legendary_counts: Dict[str, int] = {}
    max_copies = int(fmt_rules.get("max_copies_per_card", 4))
    energy_unlimited = bool(fmt_rules.get("energy_unlimited", False))

    for cid, n in sorted(counts.items()):
        card = cards_db.get(cid)
        if not card:
            errors.append(f"Unknown card_id '{cid}' (not found in selected sets).")
            continue

        ctype = card.get("card_type", "Unknown")
        by_type[ctype] = by_type.get(ctype, 0) + n

        # copy limit
        if ctype == "Energy" and energy_unlimited:
            pass
        else:
            if n > max_copies:
                errors.append(f"Too many copies of {cid} ({card.get('name','?')}): {n} > {max_copies} in {fmt}.")

        # legendary limit (TURNIER)
        if fmt == "TURNIER" and fmt_rules.get("max_legendary_per_card") is not None:
            if is_legendary(card, fmt_rules):
                legendary_counts[cid] = legendary_counts.get(cid, 0) + n
                if n > int(fmt_rules["max_legendary_per_card"]):
                    errors.append(f"Legendary limit exceeded for {cid} ({card.get('name','?')}): {n} > {fmt_rules['max_legendary_per_card']}.")

    # Minimums
    if not ignore_minimums:
        for ctype, min_n in fmt_rules.get("min_counts", {}).items():
            have = by_type.get(ctype, 0)
            if have < int(min_n):
                errors.append(f"Minimum not met: {ctype} = {have} < {min_n} in {fmt}.")

    # Sideboard
    sb_rules = fmt_rules.get("sideboard", {"enabled": False})
    sideboard = deck.get("sideboard", None)
    if sb_rules.get("enabled"):
        if not sideboard:
            errors.append("TURNIER requires a sideboard (10 cards).")
        else:
            sb_total = sum(int(e["count"]) for e in sideboard)
            sb_min = sb_rules["size"]["min"]
            sb_max = sb_rules["size"]["max"]
            if not (sb_min <= sb_total <= sb_max):
                errors.append(f"Sideboard size {sb_total} outside allowed range [{sb_min}, {sb_max}] in TURNIER.")
    else:
        if sideboard:
            warnings.append("Sideboard present but not enabled for this format; it will be ignored.")

    return errors, warnings


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--deck", required=True, help="Path to deck.json")
    parser.add_argument("--sets", default="", help="Comma-separated set ids (e.g. SET-001,SET-002). Default: all.")
    parser.add_argument("--format", default="", help="Override deck.format (EINFACH|STANDARD|TURNIER)")
    parser.add_argument("--ignore-minimums", action="store_true", help="Skip minimum type requirements (useful before Energy/Items exist).")
    args = parser.parse_args()

    deck_path = Path(args.deck).resolve()
    if not deck_path.exists():
        print(f"ERROR: Deck file not found: {deck_path}", file=sys.stderr)
        return 1

    # locate project root by walking up until 03_TCG exists
    project_root = deck_path
    for _ in range(8):
        if (project_root / "03_TCG").exists():
            break
        project_root = project_root.parent
    else:
        print("ERROR: Could not locate project root (missing 03_TCG). Run from inside the repo.", file=sys.stderr)
        return 1

    schema_path = project_root / "03_TCG" / "AUTHORING" / "SCHEMAS" / "deck.schema.json"
    rules_path = project_root / "03_TCG" / "AUTHORING" / "MATCH" / "deck_rules.json"
    if not schema_path.exists():
        print(f"ERROR: Missing schema: {schema_path}", file=sys.stderr)
        return 1
    if not rules_path.exists():
        print(f"ERROR: Missing rules: {rules_path}", file=sys.stderr)
        return 1

    validator = load_schema(schema_path)
    deck = load_json(deck_path)

    # optional format override
    if args.format:
        deck["format"] = args.format

    schema_errors = sorted(validator.iter_errors(deck), key=lambda e: e.path)
    if schema_errors:
        print("SCHEMA ERRORS:")
        for e in schema_errors:
            loc = ".".join(str(p) for p in e.path)
            print(f" - {loc}: {e.message}")
        return 1

    set_filter = [s.strip() for s in args.sets.split(",") if s.strip()] or None
    cards_db = collect_cards(project_root, set_filter=set_filter)
    ruleset = load_json(rules_path)

    errors, warnings = validate_deck(deck, cards_db, ruleset, ignore_minimums=args.ignore_minimums)

    if warnings:
        print("WARNINGS:")
        for w in warnings:
            print(f" - {w}")

    if errors:
        print("ERRORS:")
        for err in errors:
            print(f" - {err}")
        return 1

    print("OK: Deck is valid.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
