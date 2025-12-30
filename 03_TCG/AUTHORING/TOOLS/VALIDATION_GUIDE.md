# Validation Guide (Sets)

This folder contains a lightweight validator (no external Python dependencies).

## What it validates
- `set_config.json` consistency and capability flags
- `cards.json` wrapper + per-card structural sanity checks
- Keyword pool compliance (allowed/experimental/banned)
- Reveal gating: `digital.hidden_info.reveal_level` must not exceed the set reveal level
- Capability gating: `uses_hidden_intent` requires the set to declare it
- Print-vs-digital contract heuristics (warnings)

## Run
From the `MYSTIMONS` folder:

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_sets.py --all
```

Validate one set:

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_sets.py --set SET-004
```

Strict mode (warnings become errors):

```bash
python3 03_TCG/AUTHORING/TOOLS/validate_sets.py --all --strict
```

## Interpreting results
- **ERROR**: must be fixed before merge/print.
- **WARN**: should be reviewed; typically indicates drift risk (e.g., print text referencing app).
