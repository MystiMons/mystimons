# TCG Authoring Format (v1.0)

This folder defines the **canonical data format** for card, keyword, creature, and set metadata so content can be:
- versioned cleanly,
- validated mechanically,
- and implemented consistently in the app.

## Files & responsibilities

- `SCHEMAS/` — JSON Schemas for automated validation (future scripts/CI).
- `TEMPLATES/` — copy/paste starter files for authors.
- `EXAMPLES/` — minimal working examples.

## ID conventions

- Cards: `CARD-SET-###-###` (e.g., `CARD-SET-001-023`)
- Sets: `SET-###`
- Keywords: `KWD-###`
- Registry entities: `CRE-###`, `CHR-###`, `OBJ-###`, `REG-###`, `ELM-###`
- Canon refs: `LAW-###`, `PIL-###`

## Print vs Digital contract

**Print** must stay short and deterministic.
Anything that needs counters, timers, long-term tracking, hidden intent, or patching goes into **Digital**.

## Reveal policy

Use `digital.hidden_info.reveal_level` in addition to the set's `REVEAL_POLICY.md`:
- S0: no spoilers / baseline
- S1: hints / fragments
- S2: explicit but partial truth
- S3: full truth (reserved for SET-007 Origin frame)

## Where set files live

Each set folder under `03_TCG/sets/SET-###/` may include:
- `cards.json` (machine-readable list)
- `set_config.json` (optional, machine-readable config)
- The existing markdown scaffolds remain the human-facing design docs.

## Keyword Pool per Set
Each set maintains a machine-readable keyword pool:

- Canonical: `03_TCG/AUTHORING/KEYWORD_POOLS/SET-XXX.keyword_pool.json`
- Convenience copy: `03_TCG/sets/SET-XXX/keyword_pool.json`

Set configs should reference the canonical pool via `keyword_pool_path`.

## Cardlist Export (Markdown ⇄ JSON)
See: `03_TCG/AUTHORING/WORKFLOW.md` and `03_TCG/AUTHORING/TOOLS/cardlist_exporter.py`

