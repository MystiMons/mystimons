#!/usr/bin/env python3
"""
MystiMons Deck Validator (v0.6+)

Validates:
- deck size per format
- sideboard size per format (if any)
- copy limits per format (ENERGY_* exempt if energy_unlimited=true)
- min energy per format (ENERGY_* always counted)
- min resonants per format (best-effort; requires card DB scan)
- optional strict card existence (non-ENERGY_* must exist in scanned sets)

Card DB is built by scanning:
  03_TCG/sets/SET-*/cards.json

This file intentionally has no external dependencies.
"""

import argparse
import json
import os
import sys
from collections import Counter
from typing import Dict, Any, Tuple


def load_json(path: str) -> Any:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def is_virtual_energy(card_id: str, energy_prefix: str) -> bool:
    return card_id.startswith(energy_prefix)


def build_card_db(repo_root: str) -> Dict[str, Dict[str, Any]]:
    """
    Scans 03_TCG/sets/*/cards.json and returns {card_id: card_object}.
    If no sets exist, returns empty dict.
    """
    db: Dict[str, Dict[str, Any]] = {}
    sets_dir = os.path.join(repo_root, "03_TCG", "sets")
    if not os.path.isdir(sets_dir):
        return db

    for set_name in os.listdir(sets_dir):
        if not set_name.startswith("SET-"):
            continue
        cards_path = os.path.join(sets_dir, set_name, "cards.json")
        if not os.path.isfile(cards_path):
            continue
        try:
            blob = load_json(cards_path)
            for c in blob.get("cards", []):
                cid = c.get("id")
                if cid:
                    db[cid] = c
        except Exception:
            # ignore malformed files in early stages
            continue

    return db


def count_resonants_and_energy(
    main_counts: Counter,
    card_db: Dict[str, Dict[str, Any]],
    energy_prefix: str
) -> Tuple[int, int]:
    """
    Counts Resonants (incl. MiniResonant) and Energy.
    Energy: any card whose type contains 'energy' OR virtual ENERGY_*.
    Resonants: card_type contains 'resonant' (covers Resonant, MiniResonant).
    """
    resonants = 0
    energy = 0

    for cid, cnt in main_counts.items():
        if is_virtual_energy(cid, energy_prefix):
            energy += cnt
            continue

        c = card_db.get(cid)
        if not c:
            continue

        ctype = str(c.get("card_type") or "").lower()
        if "energy" in ctype:
            energy += cnt
        if "resonant" in ctype:
            resonants += cnt

    return resonants, energy


def validate_deck(
    deck_path: str,
    rules_path: str,
    repo_root: str,
    strict_card_existence: bool
) -> int:
    deck = load_json(deck_path)
    rules = load_json(rules_path)

    fmt = deck.get("format")
    formats = rules.get("formats", {})
    if fmt not in formats:
        print(f"[ERR] Unknown format: {fmt}")
        return 2

    fmt_rules = formats[fmt]
    energy_prefix = rules.get("energy_id_prefix", "ENERGY_")

    cards = deck.get("cards", [])
    sideboard = deck.get("sideboard", []) or []

    # Aggregate counts
    main_counts = Counter()
    for entry in cards:
        main_counts[entry["card_id"]] += int(entry["count"])

    side_counts = Counter()
    for entry in sideboard:
        side_counts[entry["card_id"]] += int(entry["count"])

    main_total = sum(main_counts.values())
    side_total = sum(side_counts.values())

    # Size checks
    expected_size = int(fmt_rules["deck_size"])
    if main_total != expected_size:
        print(f"[ERR] Deck size mismatch: {main_total} != {expected_size} ({fmt})")
        return 2

    expected_side = int(fmt_rules.get("sideboard_size", 0))
    if side_total != expected_side:
        if expected_side == 0 and side_total == 0:
            pass
        else:
            print(f"[ERR] Sideboard size mismatch: {side_total} != {expected_side} ({fmt})")
            return 2

    # Copy limits (energy exempt if energy_unlimited)
    max_copies = int(fmt_rules["max_copies_per_card"])
    energy_unlimited = bool(fmt_rules.get("energy_unlimited", False))

    for cid, cnt in main_counts.items():
        if energy_unlimited and is_virtual_energy(cid, energy_prefix):
            continue
        if cnt > max_copies:
            print(f"[ERR] Copy limit exceeded: {cid} has {cnt} > {max_copies} ({fmt})")
            return 2

    # Optional: card existence + type counting
    card_db = build_card_db(repo_root)

    if strict_card_existence:
        missing = [
            cid for cid in main_counts.keys()
            if (not is_virtual_energy(cid, energy_prefix)) and (cid not in card_db)
        ]
        if missing:
            print(f"[ERR] Missing card IDs in set database (non-ENERGY_*):")
            for m in missing:
                print(f"  - {m}")
            return 2

    # Type minimums (best-effort; requires card_db for resonants)
    min_res = int(fmt_rules.get("min_resonants", 0))
    min_en = int(fmt_rules.get("min_energy", 0))

    resonants, energy = count_resonants_and_energy(main_counts, card_db, energy_prefix)

    # min_resonants requires card_db; without it we warn (not fail)
    if min_res > 0:
        if card_db:
            if resonants < min_res:
                print(f"[ERR] Too few Resonants: {resonants} < {min_res} ({fmt})")
                return 2
        else:
            print(f"[WARN] Cannot verify min_resonants (no card DB found). Expected >= {min_res}.")

    # min_energy always enforceable because ENERGY_* always counted
    if min_en > 0:
        if energy < min_en:
            print(f"[ERR] Too few Energy: {energy} < {min_en} ({fmt})")
            return 2

    print(f"[OK] Deck valid: {deck.get('name')} [{fmt}]")
    print(f"     Cards: {main_total}, Sideboard: {side_total}")
    print(f"     Energy: {energy}" + (f", Resonants: {resonants}" if card_db else " (Resonants not counted)"))

    return 0


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--deck", required=True, help="Path to deck.json")
    ap.add_argument(
        "--rules",
        default="03_TCG/AUTHORING/MATCH/deck_rules.json",
        help="Path to deck_rules.json"
    )
    ap.add_argument(
        "--repo-root",
        default=".",
        help="Repo root (for scanning 03_TCG/sets/*/cards.json)"
    )
    ap.add_argument(
        "--strict-card-existence",
        action="store_true",
        help="Fail if non-ENERGY_* IDs not found in scanned set DB"
    )
    args = ap.parse_args()

    rc = validate_deck(args.deck, args.rules, args.repo_root, args.strict_card_existence)
    raise SystemExit(rc)


if __name__ == "__main__":
    main()
