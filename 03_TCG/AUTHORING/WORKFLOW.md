# Card Authoring Workflow (Markdown ⇄ JSON)

This project supports two equivalent authoring surfaces:

- **Machine-readable:** `cards.json` (source for validation, tooling, patch pipelines)
- **Human review:** `CARD_LIST.md` (fast scanning, PR reviews, design discussions)

## Recommended rule: JSON is canonical
- Treat `cards.json` as the single source of truth.
- Generate `CARD_LIST.md` for reviews, and never hand-edit generated tables.

If your team prefers writing in Markdown first, you may invert the rule **per set**, but then you must regenerate JSON after every change.

## Converter tool
Location: `03_TCG/AUTHORING/TOOLS/cardlist_exporter.py`

### JSON → Markdown
Run in a set folder:
```
python ../../AUTHORING/TOOLS/cardlist_exporter.py json2md --json cards.json --out CARD_LIST.md
```

### Markdown → JSON
Run in a set folder:
```
python ../../AUTHORING/TOOLS/cardlist_exporter.py md2json --set-id SET-001 --md CARD_LIST.md --out cards.json
```

## Markdown table format
Use a single pipe-table with these columns:

| id | name | card_type | rarity | cost | stats | print_text | tracking | rng | patchable | tags | notes |

Notes:
- `stats` supports `HP 80 / ATK 30 / DEF 20` or `80/30/20`.
- `tracking` and `tags` are comma-separated lists.
- `rng`: use `none` for deterministic cards; otherwise write a short description.
- `patchable`: `true/false`.

## CI/Validation (future)
The intent is to validate:
- JSON schema compliance (`cards_file.schema.json` + `card.schema.json`)
- Set keyword pool compliance (`keyword_pool.json`)
- Print vs Digital contract compliance


## Validation (required before merge)

Run:

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_sets.py --all
```

For strict PR gates:

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_sets.py --all --strict
```
