# APP STATE MACHINE v0.1
## Übersetzung von Matten-Events in Board-State (Active/Bench)

**Prämisse:** Die App ist Rules-Engine. Die Matte liefert Placement-Events.

---

## 1) Board Snapshot (per Match)

Für jede Seite (`P1`, `P2`):

```yaml
active_tag: null | string
bench_a_tag: null | string
bench_b_tag: null | string
lock_state: LOCKED | UNLOCKED
window: CHARGE | CLASH | AFTERGLOW
```

---

## 2) Event Handling (Deterministisch)

### 2.1 zone_present
Wenn `window == CLASH` und Move nicht explizit erlaubt:
- UI: „Illegal move“ + Log
- App sendet `LED_SET_ZONE_STATE(..., ERROR)`
- App kann (Mode-abhängig) entweder:
  - Soft: akzeptieren, aber warnen
  - Hard: den letzten validen Snapshot als „authoritative“ behalten

Wenn legal:
- Snapshot-Feld setzen (active/bench)
- LED: `VALID`

### 2.2 zone_removed
Wenn legal:
- Snapshot-Feld auf null
- LED: `READY`

Wenn illegal:
- wie oben (ERROR + Log)

### 2.3 zone_unstable
- Snapshot bleibt unverändert
- LED: `UNSTABLE`
- UI: „Bitte Karte korrekt platzieren“

---

## 3) Window Control (App → Matte)
App setzt Window & Locks als Teil der Turn-Engine:

- Turn Start → `SET_WINDOW(CHARGE)` + Unlock
- Combat Start → `SET_WINDOW(CLASH)` + Lock (ALL oder Side-spezifisch)
- End Phase → `SET_WINDOW(AFTERGLOW)` + Unlock

---

## 4) Resilience
Bei BLE-Reconnect:
- App sendet `GET_SNAPSHOT`
- App reconciled Snapshot gegen Game State:
  - Wenn abweichend: UI verlangt manuelle Bestätigung („Board sync“)

---

## 5) Logging (Minimum)
Für Debug/Integrity:

- `event_seq`, `ts_ms`
- `window`, `lock_state`
- `side`, `zone`, `tag_id`
- `resolution`: accepted | rejected | unstable
