# BLE PROTOCOL v0.1
## Smart Mat ↔ App (Single-Host Topology)

**Status:** Implementierbar (v1)  
**Topologie:** **Single-Host** — ein Host-Gerät verbindet sich per BLE mit der Matte.  
**Multi-Device:** Zweites Gerät (zweiter Spieler) joint die Match-Session logisch (QR/Invite); Events werden durch die App geteilt (Netzwerk/Local).

---

## 1) BLE Services (Empfehlung)
- **Service UUID:** `MYSTIMONS_SMARTMAT_SERVICE` (Vendor UUID)
- Characteristics:
  1. **EVENT_STREAM** (Notify) — Matte → Host
  2. **COMMANDS** (Write) — Host → Matte
  3. **STATUS** (Read/Notify) — Matte → Host (Battery/FW/Errors)

---

## 2) Message Encoding (v1)
**Binary (empfohlen)** oder **CBOR** für Stabilität.  
Für frühe Prototypen ist **JSON Lines** zulässig, wenn die Payload klein bleibt.

### 2.1 Event Envelope
Felder (required):
- `msg_type`: `"zone_present" | "zone_removed" | "zone_unstable" | "heartbeat"`
- `seq`: monoton steigende Sequenznummer
- `ts_ms`: Zeitstempel (Matte, ms)
- `side`: `"P1" | "P2"`
- `zone`: `"ACTIVE" | "BENCH_A" | "BENCH_B"`

Optional:
- `tag_id`: string
- `confidence`: 0–100
- `reason`: string (bei unstable)

### 2.2 Beispiele
```json
{"msg_type":"zone_present","seq":1841,"ts_ms":12345678,"side":"P1","zone":"ACTIVE","tag_id":"04A1...","confidence":92}
{"msg_type":"zone_removed","seq":1842,"ts_ms":12346821,"side":"P1","zone":"ACTIVE","tag_id":"04A1..."}
{"msg_type":"zone_unstable","seq":1843,"ts_ms":12346910,"side":"P2","zone":"BENCH_B","reason":"multi_tag"}
```

---

## 3) Commands (Host → Matte)

### 3.1 Match Configuration
- `SET_LOCK_STATE`:
  - payload: `{ "side":"P1|P2|ALL", "lock":"LOCKED|UNLOCKED" }`
- `SET_WINDOW`:
  - payload: `{ "window":"CHARGE|CLASH|AFTERGLOW" }`

### 3.2 LED Control (high-level)
- `LED_SET_ZONE_STATE`:
  - payload: `{ "side":"P1|P2", "zone":"ACTIVE|BENCH_A|BENCH_B", "state":"READY|VALID|LOCKED|ERROR|UNSTABLE" }`
- `LED_SET_GLOBAL`:
  - payload: `{ "state":"P1_TURN|P2_TURN|NEUTRAL" }`

**Hinweis:** v1 sollte bevorzugt „high-level states“ nutzen, nicht RGB-Werte, damit App/UX konsistent bleibt.

---

## 4) Reconnect Behavior (v1)
- Matte sendet `heartbeat` alle 2 s.
- Host erkennt Timeout nach 6 s und zeigt „Reconnecting…“.
- Nach Reconnect fordert Host einen **Full Snapshot** an (`GET_SNAPSHOT`).
- Matte liefert pro Zone den aktuellen `tag_id` (oder null).

---

## 5) Versioning
- `STATUS` enthält:
  - `fw_version`
  - `protocol_version` (z. B. `0.1`)
  - `capabilities` (z. B. `["dual_side","led_zones"]`)
