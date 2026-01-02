# Match Windows v0.3

Canonical timing windows used by the Rules Engine and Match Server.

## Window Table

| Window ID | Phase | Smart Mat Lock | Purpose |
|---|---|---|---|
| `SETUP.SELECT_ACTIVE` | SETUP | `CHARGE` | Players choose their initial ACTIVE MystiMon (Stage 1). |
| `SETUP.SELECT_BENCH` | SETUP | `CHARGE` | Players optionally place up to 2 Stage 1 MystiMons on BENCH. |
| `SETUP.MULLIGAN` | SETUP | `CHARGE` | Player declares mulligan if no eligible MystiMon in opening hand. |
| `SETUP.READY` | SETUP | `CHARGE` | Both players confirm setup completion; server starts Turn 1. |
| `TURN.DRAW` | TURN | `AFTERGLOW` | Start-of-turn draw step. Player 1 skips draw on Turn 1 (ruleset). |
| `TURN.ENERGY` | TURN | `CHARGE` | Attach exactly 1 Energy card (ATTACHED or POOL). |
| `TURN.MAIN` | TURN | `CHARGE` | Main actions in any order: summon Stage 1 (1x), evolve, play items/relics/terrain, switch (1x). |
| `TURN.COMBAT.DECLARE` | COMBAT | `CHARGE` | Declare attack and targets; pay pool costs; validate legality. |
| `TURN.COMBAT.RESOLVE` | COMBAT | `CLASH` | Server resolves damage, effectiveness, status, KO, triggers. Zones locked. |
| `TURN.END` | END | `AFTERGLOW` | Cleanup: HP-Drain, status ticks, end-of-turn effects, hand limit discard; then End Turn. |
| `MATCH.ENDED` | END | `AFTERGLOW` | Terminal window after win/lose/surrender/deck-out. |

## Notes
- **Smart Mat Lock** is advisory UI/UX + anti-exploit; the **Rules Engine still validates** legality by `window` and by ruleset.
- `TURN.COMBAT.RESOLVE` is the default **lock zone** (`CLASH`) to prevent hot-swap abuse during damage resolution.
- Mode gating happens via **MatchConfig.mode**; see `CONTRACTS.md` for command availability by mode.