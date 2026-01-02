# Trackers (v0.5)

Trackers are digital counters/statuses referenced by cards via `digital.tracking`.

## Default reset rules

- `PLAYER_TURN` trackers reset at `TURN.START`.
- `CARD_INSTANCE` status trackers are advanced/expired at `TURN.END` based on their duration.
- Engine must reject activation if a cap tracker would exceed `max`.

## Canonical trackers

| Key | Kind | Scope | Reset | Default | Max | Notes |
|---|---|---|---|---|---|---|
| `cap_draw_used_this_turn` | cap | PLAYER_TURN | TURN.START | 0 | 1 | Global draw cap per player per turn. |
| `cap_heal_used_this_turn` | cap | PLAYER_TURN | TURN.START | 0 | 1 | Global heal cap per player per turn (mini heal). |
| `cap_search_used_this_turn` | cap | PLAYER_TURN | TURN.START | 0 | 1 | Global search cap per player per turn. |
| `cap_relic_discount_used_this_turn` | cap | PLAYER_TURN | TURN.START | 0 | 1 | Global relic discount cap per player per turn. |
| `status_burn` | status | CARD_INSTANCE | DURATION | 0 |  | Burn status with intensity/duration tracked digitally. |
| `status_freeze` | status | CARD_INSTANCE | DURATION | 0 |  | Freeze status tracked digitally. |
| `status_paralyze` | status | CARD_INSTANCE | DURATION | 0 |  | Paralyze status tracked digitally. |
| `status_stealth` | status | CARD_INSTANCE | DURATION | 0 |  | Stealth until break (attack or damage). |
| `spd` | stat_overlay | CARD_INSTANCE | MATCH.END | None |  | SPD is digital-only; base SPD is stored in `digital.notes` and derived into runtime stats. |
