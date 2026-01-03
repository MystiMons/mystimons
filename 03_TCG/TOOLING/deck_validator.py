#!/usr/bin/env python3
# MystiMons TCG Tooling v0.5.2 — Deck Validator CLI (CI-ready)

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from typing import Dict, Any, List, Optional, Tuple


TOOLING_DIR = os.path.dirname(__file__)
DEFAULT_CAPS_PATH = os.path.join(TOOLING_DIR, "caps.defaults.json")

LINE_RE = re.compile(r"^\s*(\d+)\s*x\s*(.+?)\s*$", re.IGNORECASE)
TAG_TRAIL_RE = re.compile(r"\s*(\((?:C|U|R|UR)\)|\[(?:COMMON|UNCOMMON|RARE|ULTRA(?:_RARE)?|CHAMPION)\])\s*$", re.IGNORECASE)
STAR_LEAD_RE = re.compile(r"^\s*★\s*")

def split_name_and_tags(name: str) -> Tuple[str, str]:
    """
    Returns (base_name, trailing_tags) where trailing_tags includes leading space.
    Examples:
      "Verdantis (C)" -> ("Verdantis", " (C)")
      "Verdantis [COMMON]" -> ("Verdantis", " [COMMON]")
      "★ Verdantis (C)" -> ("Verdantis", " (C)")
      "Moosveil" -> ("Moosveil", "")
    """
    n = name.strip()
    n = STAR_LEAD_RE.sub("", n)  # drop leading star marker
    m = TAG_TRAIL_RE.search(n)
    if not m:
        return (n, "")
    tag = m.group(1)
    base = n[: m.start()].rstrip()
    return (base, f" {tag}")



class ValidationIssue:
    def __init__(self, level: str, msg: str, code: str = "GENERIC"):
        self.level = level  # "ERROR" | "WARN"
        self.msg = msg
        self.code = code

    def __str__(self) -> str:
        return f"[{self.level}] {self.msg}"

    def to_dict(self) -> Dict[str, Any]:
        return {"level": self.level, "code": self.code, "message": self.msg}


def load_caps(caps_path: str) -> Dict[str, Any]:
    with open(caps_path, "r", encoding="utf-8") as f:
        text = f.read()
    text = text.lstrip("\ufeff")  # BOM-safe
    if not text.strip():
        raise RuntimeError(f"Caps file is empty or unreadable: {caps_path}")
    return json.loads(text)


def read_deck(path: str) -> Dict[str, Any]:
    """
    Supports:
    - .txt : lines like "3x Aquor"
    - .json: {"main":[{"name":"Aquor","count":3}], "side":[...], "meta":{...}}
    """
    if path.lower().endswith(".json"):
        with open(path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return normalize_json_deck(data)

    main: List[Dict[str, Any]] = []
    side: List[Dict[str, Any]] = []
    section = "main"

    with open(path, "r", encoding="utf-8") as f:
        for raw in f.readlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if line.lower() in ("[main]", "main:"):
                section = "main"
                continue
            if line.lower() in ("[side]", "[sideboard]", "side:", "sideboard:"):
                section = "side"
                continue

            m = LINE_RE.match(line)
            if not m:
                raise ValueError(f"Invalid line: '{line}' (expected '3x Card Name')")
            count = int(m.group(1))
            name = m.group(2).strip()
            if section == "main":
                main.append({"name": name, "count": count})
            else:
                side.append({"name": name, "count": count})

    return {"main": main, "side": side, "meta": {"source": "txt"}}


def normalize_json_deck(data: Dict[str, Any]) -> Dict[str, Any]:
    main = data.get("main", [])
    side = data.get("side", data.get("sideboard", []))
    meta = data.get("meta", {})

    def norm(arr):
        out = []
        for e in arr:
            if isinstance(e, dict):
                out.append({"name": str(e["name"]), "count": int(e.get("count", 1))})
            else:
                out.append({"name": str(e), "count": 1})
        return out

    return {"main": norm(main), "side": norm(side), "meta": meta}


def sum_cards(section: List[Dict[str, Any]]) -> int:
    return sum(int(e["count"]) for e in section)


def expand_counts(section: List[Dict[str, Any]]) -> Dict[str, int]:
    d: Dict[str, int] = {}
    for e in section:
        name = e["name"]
        d[name] = d.get(name, 0) + int(e["count"])
    return d


def naming_guard(
    issues: List[ValidationIssue],
    caps_all: Dict[str, Any],
    name: str,
    deny_deprecated: bool,
) -> str:
    dep = caps_all.get("naming_guard", {}).get("deprecated_names", {})

    base, tag = split_name_and_tags(name)

    if base in dep:
        replacement_base = dep[base]
        msg = f"Deprecated name '{base}' detected. Use '{replacement_base}' (canon naming)."
        if deny_deprecated:
            issues.append(ValidationIssue("ERROR", msg, code="DEPRECATED_NAME"))
        else:
            issues.append(ValidationIssue("WARN", msg, code="DEPRECATED_NAME"))

        # preserve original trailing tag
        return f"{replacement_base}{tag}"

    return name



def validate_deck(
    deck: Dict[str, Any],
    fmt: str,
    caps_all: Dict[str, Any],
    deny_deprecated: bool = False,
) -> List[ValidationIssue]:
    issues: List[ValidationIssue] = []

    if fmt not in caps_all["formats"]:
        return [ValidationIssue("ERROR", f"Unknown format '{fmt}'. Available: {', '.join(caps_all['formats'].keys())}", code="BAD_FORMAT")]

    rules = caps_all["formats"][fmt]["deck_rules"]

    main_n = sum_cards(deck["main"])
    side_n = sum_cards(deck["side"])

    if main_n < rules["main_deck_min"]:
        issues.append(ValidationIssue("ERROR", f"Main deck too small: {main_n} < {rules['main_deck_min']}", code="DECK_TOO_SMALL"))
    if main_n > rules["main_deck_max"]:
        issues.append(ValidationIssue("ERROR", f"Main deck too large: {main_n} > {rules['main_deck_max']}", code="DECK_TOO_LARGE"))

    if side_n > rules["sideboard_max"]:
        issues.append(ValidationIssue("ERROR", f"Sideboard too large: {side_n} > {rules['sideboard_max']}", code="SIDEBOARD_TOO_LARGE"))

    combined = expand_counts(deck["main"])
    for k, v in expand_counts(deck["side"]).items():
        combined[k] = combined.get(k, 0) + v

    normalized: Dict[str, int] = {}
    for name, cnt in combined.items():
        nn = naming_guard(issues, caps_all, name, deny_deprecated=deny_deprecated)
        normalized[nn] = normalized.get(nn, 0) + cnt

    max_copies = int(rules["max_copies_per_card"])
    if max_copies < 99:
        for name, cnt in normalized.items():
            if cnt > max_copies:
                issues.append(ValidationIssue("ERROR", f"Too many copies of '{name}': {cnt} > {max_copies}", code="TOO_MANY_COPIES"))

    # Champion cap heuristic (v0.5): "★" or "[CHAMPION]"
    champion_cnt = 0
    for name, cnt in normalized.items():
        if name.strip().startswith("★") or "[CHAMPION]" in name.upper():
            champion_cnt += cnt

    if champion_cnt > int(rules["max_champions"]):
        issues.append(ValidationIssue("ERROR", f"Too many Champions: {champion_cnt} > {rules['max_champions']} (v0.5 heuristic)", code="TOO_MANY_CHAMPIONS"))

    # Fairness support: rarity score warning heuristic tags (C/U/R/UR, CHAMPION)
    weights = caps_all.get("rarity_weights", {})
    rarity_score = 0

    def detect_rarity(n: str) -> Optional[str]:
        u = n.upper()
        if "(UR)" in u or "[ULTRA]" in u or "[ULTRA_RARE]" in u:
            return "ultra_rare"
        if "(R)" in u or "[RARE]" in u:
            return "rare"
        if "(U)" in u or "[UNCOMMON]" in u:
            return "uncommon"
        if "(C)" in u or "[COMMON]" in u:
            return "common"
        if "[CHAMPION]" in u or "★" in n:
            return "champion"
        return None

    for name, cnt in normalized.items():
        r = detect_rarity(name)
        if r:
            rarity_score += int(weights.get(r, 0)) * cnt

    thr = int(rules.get("rarity_warn_threshold", 999999))
    if rarity_score >= thr:
        issues.append(
            ValidationIssue(
                "WARN",
                f"High rarity score ({rarity_score} ≥ {thr}). Allowed, but consider fairness (No Pay-to-Win).",
                code="RARITY_SCORE_HIGH",
            )
        )

    return issues


def _result_payload(deck_path: str, fmt: str, issues: List[ValidationIssue]) -> Dict[str, Any]:
    errors = [i for i in issues if i.level == "ERROR"]
    warns = [i for i in issues if i.level == "WARN"]
    return {
        "deck": deck_path,
        "format": fmt,
        "ok": len(errors) == 0,
        "error_count": len(errors),
        "warn_count": len(warns),
        "issues": [i.to_dict() for i in issues],
    }


def cmd_validate(args: argparse.Namespace) -> int:
    caps_all = load_caps(args.caps)
    deck = read_deck(args.deck)
    issues = validate_deck(deck, args.format, caps_all, deny_deprecated=args.deny_deprecated)

    errors = [i for i in issues if i.level == "ERROR"]
    warns = [i for i in issues if i.level == "WARN"]

    if args.json_output:
        print(json.dumps(_result_payload(args.deck, args.format, issues), ensure_ascii=False, indent=2))
    else:
        if warns and not args.quiet:
            for w in warns:
                print(str(w))
        if errors:
            for e in errors:
                print(str(e), file=sys.stderr)
        if not errors and not args.quiet:
            print("[OK] Deck is valid for format:", args.format)

    if errors:
        return 2
    if warns and args.fail_on_warn:
        return 1
    return 0


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="deck_validator", description="MystiMons TCG Deck Validator (v0.5.2)")
    sub = p.add_subparsers(dest="cmd", required=True)

    v = sub.add_parser("validate", help="Validate a deck file (.txt or .json)")
    v.add_argument("deck", help="Path to deck file")
    v.add_argument("--format", default="standard", choices=["starter", "standard", "limited"])
    v.add_argument("--caps", default=DEFAULT_CAPS_PATH, help="Path to caps.defaults.json")
    v.add_argument("--quiet", action="store_true", help="Only exit code, no output")
    v.add_argument("--json-output", action="store_true", help="Emit machine-readable JSON result")
    v.add_argument("--fail-on-warn", action="store_true", help="Exit code 1 if warnings exist")
    v.add_argument("--deny-deprecated", action="store_true", help="Treat deprecated names as ERROR")
    v.set_defaults(func=cmd_validate)

    return p


def main(argv: List[str]) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
