# ACCEPTANCE TESTS — Smart Mat v1 (Double-sided, 3 zones per side)

## A) Core recognition
1. **Presence latency:** Card placed in zone triggers VALID within 0.7s (95th percentile).
2. **Removal latency:** Card removed triggers READY within 1.2s (95th percentile).
3. **No false positives:** Empty zone must not report VALID under normal table noise.

## B) Interference handling
4. **Overlap detection:** Two tags in one zone results in UNSTABLE within 0.7s and does not commit a snapshot.
5. **Adjacent zone safety:** Card in ACTIVE must not be detected in BENCH zones (and vice versa) when placed correctly.

## C) Reconnect & resync
6. **BLE reconnect:** If BLE drops, reconnect restores a correct full snapshot within 5s.
7. **Snapshot authority:** After reconnect, app snapshot matches mat snapshot without manual rescans.

## D) Window locks
8. **Lock enforcement:** During CLASH lock, moving a card triggers:
   - Casual: warning + continue
   - Ranked/Tournament: warning + log (policy stub acceptable for v1)
9. **LED lock state:** Locked zones show LOCKED pattern within 0.1s after lock command.

## E) LED semantics
10. **State mapping:** READY/VALID/UNSTABLE/ERROR patterns are visually distinct and consistent across all 6 zones.
11. **Error recovery:** Returning to a legal single-card placement clears UNSTABLE within 1s.

## F) Host usability
12. **Table readability:** Both players can confirm who is ACTIVE/ON BENCH and which window is running without swapping devices.
13. **Failure mode:** If a zone remains unstable for >10s, app provides a guided step that resolves the match state in <=2 actions.

## Reporting
- Each test logs: timestamp, zone id, observed state, and pass/fail.
