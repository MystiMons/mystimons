# Effect Engine Hooks (v0.4)

This document makes `digital.app_effect_id` **implementable** in an authoritative runtime without ambiguity.

## 1) Effect lifecycle

### 1.1 Availability
An effect is *available* if:
- its source card instance is **in play** (zone rules apply),
- the match is currently in an **allowed window**,
- and its **gates** pass (per-turn caps, per-match caps, status restrictions).

Availability is **not** computed client-side; the server/engine decides and may emit `STATE_SNAPSHOT` or UI hints.

### 1.2 Activation
Client requests an activation via:

- **Command:** `ACTIVATE_EFFECT`
- **Payload (minimum):**
  - `source_instance_id`
  - `effect_id`
  - `intent_id` (client-generated; idempotency)

The engine validates window/gates and emits:
- `EFFECT_ACTIVATED` (success) or
- `COMMAND_REJECTED` / `EFFECT_FAILED` (failure)

### 1.3 Choice prompts (hidden info)
If an effect requires a choice (targets, options, hidden selection), the server emits:

- **Event:** `CHOICE_PROMPTED`
- **Fields:**
  - `prompt_id`
  - `prompt_type` (e.g., `SELECT_CARD_FROM_REVEAL`, `SELECT_TARGET_BENCH`)
  - `constraints` (count, zones, filters)
  - `choices` (may be **redacted** for non-owner audiences)

Client answers with:

- **Command:** `SUBMIT_CHOICE`
- **Payload:**
  - `prompt_id`
  - `selections` (ids or indices, per prompt contract)

Server then emits:
- `CHOICE_RESOLVED` (audience-aware; may be redacted)
- followed by `EFFECT_RESOLVED` (final outcome events may be separate domain events too, e.g. `CARD_DRAWN`, `STATUS_APPLIED`)

## 2) Canonical handler signature (C#)

```csharp
public interface IEffectHandler
{
    string EffectId { get; }

    // Called on ACTIVATE_EFFECT after validation of window and base legality.
    EffectResolution Begin(EffectContext ctx, EffectActivation act);

    // Called on SUBMIT_CHOICE for prompts produced by this effect.
    EffectResolution Continue(EffectContext ctx, EffectChoice choice);
}

public sealed record EffectContext(
    MatchState State,
    MatchConfig Config,
    IRandomSource Rng,          // server-side only
    ITracker Tracker,           // per-turn/per-match counters
    IRedactionPolicy Redaction  // audience-aware event shaping
);

public sealed record EffectActivation(
    string IntentId,
    string SourceInstanceId,
    string EffectId
);

public sealed record EffectChoice(
    string PromptId,
    string PlayerId,
    JsonElement Selections
);

public sealed record EffectResolution(
    IReadOnlyList<MatchEvent> Events,
    IReadOnlyList<EffectPrompt> Prompts
);
```

**Rules:**
- Handlers must be **purely deterministic** given `(State, Config, Tracker, Rng-seed)`; RNG calls must be server-sourced and event-logged.
- Any state changes occur **only** via emitted events (event-sourcing).
- The engine is responsible for applying events to produce the next state.

## 3) Prompt contracts (standard types)

### `SELECT_CARD_FROM_REVEAL`
- Engine reveals a set of N cards to the acting player (audience = P1/P2).
- Opponent receives `redacted=true` and only `count=N`.
- Selection is an **index** (0..N-1) or an opaque `choice_id` issued by server.

### `SELECT_TARGET_BENCH`
- Constraints: target must be in `BENCH` and match a filter (e.g., opponent bench only).
- Selection is a `target_instance_id`.

### `YES_NO`
- Selection is `"YES"` or `"NO"`.

## 4) Mapping: SET-001 mini effects (expected behavior)

| Effect ID | Trigger | Allowed Windows | Needs Prompt | Primary Outcome Events | Caps/Tracking |
|---|---|---|---|---|---|
| `EFF_MINI_DRAW_001` | activated | `TURN.MAIN` | `YES_NO` optional | `CARD_DRAWN` | `mini_draw_used_this_turn` (global) |
| `EFF_MINI_HEAL_001` | activated | `TURN.END` | no | `DAMAGE_APPLIED` (negative damage) or `STATUS_APPLIED` | `mini_heal_used_this_turn` |
| `EFF_MINI_BURN_001` | triggered | `TURN.COMBAT.DECLARE/RESOLVE` | no | `STATUS_APPLIED` | `mini_burn_triggers_this_match` |
| `EFF_MINI_DEF_001` | passive | all | no | (derived modifier) | non-stacking recommended |
| `EFF_MINI_SPD_001` | passive | all | no | (derived modifier) | non-stacking recommended |
| `EFF_MINI_FREEZE_001` | triggered | `TURN.COMBAT.RESOLVE` | no | `STATUS_APPLIED` | duration cap (<=1 turn) |
| `EFF_MINI_PARALYZE_001` | triggered | `TURN.DRAW` | `SELECT_TARGET_BENCH` | `STATUS_APPLIED` | frequency cap |
| `EFF_MINI_STEALTH_001` | activated | `TURN.MAIN` | no | `STATUS_APPLIED` | once/turn |
| `EFF_MINI_SEARCH_001` | activated | `TURN.MAIN` | `SELECT_CARD_FROM_REVEAL` | `CHOICE_*` + `CARD_DRAWN` or `CARD_MOVED` | `mini_search_used_this_turn` |
| `EFF_MINI_RELIC_001` | passive | all | no | (cost modifier) | non-stacking recommended |

## 5) Exploit notes (engine-enforced)
- **Global caps** for draw/search effects prevent “mini spam” decks from degenerating.
- **Duration caps** for control statuses prevent soft locks.
- **Window enforcement** prevents combat-time activations unless explicitly allowed.
- **Idempotency:** `intent_id` prevents double-submit on reconnect.

