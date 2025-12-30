# LED STATE MAP v0.1
## Visuelles Feedback pro Zone (Player-Side + Zone)

**Ziel:** Spieler erkennt den gültigen Board-State ohne App-Blick.

---

## 1) Zone States (v1)

| State | Bedeutung | Wann? | UX-Anforderung |
|---|---|---|---|
| READY | Zone leer / bereit | Kein Tag stabil erkannt | Ruhig, nicht ablenkend |
| VALID | Karte stabil erkannt | `zone_present` bestätigt | Sofortiges „OK“-Signal |
| LOCKED | Bewegungen gesperrt | Clash Window / Lock aktiv | Deutlich, aber nicht aggressiv |
| UNSTABLE | Lesefehler / Mehrfach-Tag | Multi-Tag / Interferenz | Spieler korrigiert Placement |
| ERROR | Illegaler Move / Regelverstoß | Zone change während Lock | Unmissverständlich |

---

## 2) Global Indicators (optional, v1 nice-to-have)
- `P1_TURN` / `P2_TURN`: Dezent, nur zur Orientierung.
- `RECONNECTING`: Alle Zonen blinken kurz synchron (max. 1 Hz).

---

## 3) Mode-Semantik
- **Casual:** ERROR = Warnung (kein Match-Stop).
- **Ranked/Tournament:** ERROR = Warnung + Log (Penalty Policy extern).

---

## 4) Implementation Notes
- LEDs sollen in v1 über **Zustände** gesteuert werden (nicht „freie Farben“), um konsistente UX zu garantieren.
