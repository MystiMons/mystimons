# Deck Validation (v0.5)

This repo contains a CLI tool to validate decklists against **mode rules** and **available cards**.

## Files

- Schema: `03_TCG/AUTHORING/SCHEMAS/deck.schema.json`
- Rules: `03_TCG/AUTHORING/MATCH/deck_rules.json`
- Tool: `03_TCG/AUTHORING/TOOLS/validate_deck.py`

## Usage

Validate a deck file:

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_deck.py --deck path/to/deck.json
```

Common options:

- `--sets SET-001,SET-002` : restrict validation to specific sets (default: all)
- `--ignore-minimums` : skip minimum requirements (useful while the pool lacks Energy/Items)
- `--format STANDARD` : override the deck’s `format`

## What is checked

- Deck schema validity
- Deck size (min/max or exact)
- Max copies per card (Energy may be exempt depending on format)
- Minimum counts by card type (MystiMon/Energy), unless `--ignore-minimums`
- Sideboard size (TURNIER)
- Legendary cap (TURNIER) via rarity/tags heuristic
