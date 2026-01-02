# Match Contracts v0.3 (Minimal Set)

This file defines the minimal **Command/Event** vocabulary required to implement an authoritative match runtime.

## Commands

| Command Type | Allowed Windows | Modes | Payload Shape (high-level) |
|---|---|---|---|
| `SETUP_SELECT_ACTIVE` | `SETUP.SELECT_ACTIVE` | EINFACH, STANDARD, TURNIER | `{ card_id, source_zone }` |
| `SETUP_ADD_BENCH` | `SETUP.SELECT_BENCH` | EINFACH, STANDARD, TURNIER | `{ card_id, bench_slot }` |
| `SETUP_MULLIGAN` | `SETUP.MULLIGAN` | EINFACH, STANDARD, TURNIER | `{ confirm: true }` |
| `SETUP_READY` | `SETUP.READY` | EINFACH, STANDARD, TURNIER | `{ confirm: true }` |
| `DRAW_ACK` | `TURN.DRAW` | EINFACH, STANDARD, TURNIER | `{ confirm: true }` |
| `ATTACH_ENERGY` | `TURN.ENERGY` | EINFACH, STANDARD, TURNIER | `{ energy_card_id, dest: 'ATTACHED'|'POOL', target_instance_id? }` |
| `SUMMON_STAGE1` | `TURN.MAIN` | EINFACH, STANDARD, TURNIER | `{ card_id, dest: 'ACTIVE'|'BENCH', bench_slot? }` |
| `EVOLVE` | `TURN.MAIN` | STANDARD, TURNIER | `{ base_instance_id, evo_card_id }` |
| `RITUAL_SUMMON` | `TURN.MAIN` | TURNIER | `{ champion_card_id, sacrifices: [instance_id...] }` |
| `PLAY_ITEM` | `TURN.MAIN` | EINFACH, STANDARD, TURNIER | `{ card_id, targets? }` |
| `PLAY_RELIC` | `TURN.MAIN` | STANDARD, TURNIER | `{ card_id, attach_to_instance_id? }` |
| `PLAY_TERRAIN` | `TURN.MAIN` | STANDARD, TURNIER | `{ card_id }` |
| `SWITCH` | `TURN.MAIN` | EINFACH, STANDARD, TURNIER | `{ bench_slot }` |
| `ATTACK` | `TURN.COMBAT.DECLARE` | EINFACH, STANDARD, TURNIER | `{ attacker_instance_id, attack_id, target: {side, zone, instance_id} }` |
| `END_TURN` | `TURN.END` | EINFACH, STANDARD, TURNIER | `{ confirm: true }` |
| `SURRENDER` | `SETUP.SELECT_ACTIVE`, `SETUP.SELECT_BENCH`, `TURN.DRAW`, `TURN.ENERGY`, `TURN.MAIN`, `TURN.COMBAT.DECLARE`, `TURN.END` | EINFACH, STANDARD, TURNIER | `{ confirm: true }` |

### Command Rules (Server)
- Reject if `window` is not current authoritative window.
- Reject if `seq` is not the next expected sequence number for that player.
- Reject if `content_manifest_hash` does not match the match's content manifest (optional but recommended).
- Reject if mode-gated command is used in the wrong mode.

## Events

| Event Type | Default Audience | Payload Notes |
|---|---|---|
| `MATCH_CREATED` | ALL | { match_id, mode, players[] } |
| `MATCH_STARTED` | ALL | { first_player_id, turn: 1 } |
| `SETUP_REQUIRED` | ALL | { phase: 'SETUP' } |
| `CARD_DRAWN` | P1|P2 | { player_id, card_id, instance_id } (opponent receives redacted card_id) |
| `ENERGY_ATTACHED` | ALL | { player_id, energy_card_id, target_instance_id } |
| `ENERGY_POOLED` | ALL | { player_id, energy_card_id } |
| `CARD_SUMMONED` | ALL | { player_id, card_id, instance_id, dest, bench_slot? } |
| `CARD_EVOLVED` | ALL | { player_id, base_instance_id, evo_card_id, evo_instance_id } |
| `CARD_PLAYED_ITEM` | ALL | { player_id, card_id, resolved_events[]? } |
| `CARD_PLAYED_RELIC` | ALL | { player_id, card_id, attach_to_instance_id? } |
| `TERRAIN_CHANGED` | ALL | { player_id, card_id } |
| `SWITCHED` | ALL | { player_id, new_active_instance_id } |
| `ATTACK_DECLARED` | ALL | { player_id, attacker_instance_id, attack_id, target } |
| `DAMAGE_APPLIED` | ALL | { source_instance_id, target_instance_id, amount, effectiveness } |
| `STATUS_APPLIED` | ALL | { target_instance_id, status_id, duration? } |
| `KO` | ALL | { target_instance_id } |
| `HAND_DISCARD` | P1|P2 | { player_id, discarded: [{instance_id, card_id}] } |
| `TURN_ENDED` | ALL | { player_id, next_player_id, turn_number } |
| `MATCH_ENDED` | ALL | { winner_player_id, reason } |
| `COMMAND_REJECTED` | P1|P2 | { cmd_id, reason_code, message } |
| `STATE_SNAPSHOT` | P1|P2 | { state } (debug/reconcile) |

### Audience/Redaction
- Server may emit **different payloads** per audience (e.g., opponent receives redacted `card_id` for draws/search).
- Persisted match logs (for arbitration/debug) should store the **full** payload, then derive client streams via redaction.

## Window → Smart Mat Mapping
- `CHARGE`: movement allowed (normal play)
- `CLASH`: movement locked (combat resolution)
- `AFTERGLOW`: movement allowed (cleanup/idle)