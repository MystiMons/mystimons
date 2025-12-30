# APP REQUIREMENTS — SET-002

## Required capabilities (baseline)
- Smart Mat input (Active + Bench A/B per player; double-sided mat).
- Deterministic window control (Charge / Clash / Afterglow).
- Zone locking during Clash (integrity).

## Set-specific focus
- Windowing polish
- Error handling & recovery
- Basic AR overlays (status, timers)

## Non-goals
- No additional hardware zones are introduced in this set scaffold.
- Avoid introducing high-admin subsystems that require constant manual confirmations.

## Telemetry
- Log: zone changes, lock violations, and resolution timing to support playtest analysis.

