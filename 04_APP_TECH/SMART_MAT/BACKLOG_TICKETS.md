# IMPLEMENTATION BACKLOG (Derived from Books 1–7 / Sets 001–007 + Smart Mat v1)

**Scope:** Firmware + App + UX needed to support the baseline (App-required) and the 3-zone-per-side double-sided Smart Mat.

**Principle:** Prioritize robustness and determinism over feature breadth. Set scaffolds (SET-002…SET-007) do not introduce additional hardware zones; SET-007 introduces the Origin Frame (Chronicle Layer) as an App/AR feature.

---

## A) Firmware (SMART MAT)

### SM-FW-001 — 6-zone reader scheduling (time-sliced polling)
- **Goal:** Reliable reads across 6 zones without cross-talk.
- **Done when:** Each zone produces stable presence/removed events under expected placement variance.

### SM-FW-002 — Debounce + stability classification
- **Goal:** Implement present/removed thresholds and `UNSTABLE` detection (multi-tag / flapping).
- **Done when:** Flapping and overlaps are flagged deterministically with a reason code.

### SM-FW-003 — Snapshot broadcaster
- **Goal:** Periodic full snapshot message for recovery (e.g., every 1–2s).
- **Done when:** App can resync after reconnect without manual scanning loops.

### SM-FW-004 — LED driver + state mapping
- **Goal:** READY/VALID/LOCKED/UNSTABLE/ERROR patterns per zone.
- **Done when:** LEDs reflect app-commanded state with <100ms response.

### SM-FW-005 — BLE reliability (reconnect, pairing, firmware versioning)
- **Goal:** Resilient session behavior and clear device identity.
- **Done when:** Reconnect restores snapshot within 5s.

---

## B) App Core (Rules Engine)

### SM-APP-001 — BLE transport + message decoder/encoder
- **Goal:** Implement BLE service integration as per `BLE_PROTOCOL_v0_1.md`.
- **Done when:** Zone events are parsed and routed to state machine; commands drive LEDs.

### SM-APP-002 — Board snapshot state machine (authoritative Active/Bench)
- **Goal:** Maintain deterministic per-side snapshot with conflict handling.
- **Done when:** App never enters ambiguous state; `UNSTABLE` triggers guided recovery.

### SM-APP-003 — Window engine + lock enforcement
- **Goal:** Charge/Clash/Afterglow timing with lock rules.
- **Done when:** Zone changes during LOCK are caught and handled per mode.

### SM-APP-004 — Match logging + telemetry
- **Goal:** Log zone changes, lock violations, and resolution timings.
- **Done when:** Exportable logs exist for playtest analysis.

---

## C) UX / Product

### SM-UX-001 — Host device mode (Tablet-first)
- **Goal:** One-tablet host UI that both players can read (premium table experience).
- **Done when:** Both sides can verify board state and windows without passing devices.

### SM-UX-002 — Error recovery flows
- **Goal:** Clear prompts for unstable zones, reconnect, and illegal moves.
- **Done when:** Recovery requires at most 2 steps and does not stall the match.

---

## D) Content/Set Integration (App features influenced by set roadmap)

### SM-CONT-001 — Spoiler-gate framework (Books 4–7; SET-004+)
- **Goal:** Prevent early revelation of Book 4 transition and Origin truths.
- **Done when:** Reveal levels are enforced by config toggles and release gates.

### SM-CONT-002 — Chronicle Layer (SET-007 Origin Frame)
- **Goal:** Unlockable lore entries with sequenced reveals and no competitive advantage.
- **Done when:** Chronicle entries render in AR/UI without impacting Ranked/Tournament power.

---

## Suggested execution order (quality-first)
1) SM-FW-001/002 + SM-APP-001/002 (stable board state)
2) SM-FW-004 + SM-APP-003 (locks + feedback)
3) SM-UX-002 + SM-FW-003 (recovery)
4) Telemetry + spoiler gates (SM-APP-004, SM-CONT-001)
5) Chronicle Layer (SM-CONT-002) for SET-007
