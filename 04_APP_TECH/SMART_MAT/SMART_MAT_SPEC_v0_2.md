# SMART MAT SPEC v0.2
## Doppelseitige NFC-Spielmatte (2 Spieler) + LED-Feedback, v1 Scope: 3 Zonen pro Spieler

**Status:** Spezifikation (implementierbar)  
**Baseline-Prämisse:** MystiMons TCG setzt **immer** eine App voraus (kein „ohne App“-Modus).  
**Ziel:** Karten-Input wird über die Matte erfasst, damit Spieler **nicht permanent ans Handy** müssen; die App bleibt Rules-Engine + AR-Layer.

---

## 1) Scope (v1)

### 1.1 Unterstützte Zonen
Pro Spieler-Seite (identisches Layout):
- `ACTIVE`
- `BENCH_A`
- `BENCH_B`

Gesamt:
- 2 Seiten (`P1`, `P2`) → **6 NFC-Zonen**.

### 1.2 Nicht im v1 Scope
- Deck/Hand/Discard Tracking über NFC
- Attached/Pool Energy Zonen per NFC
- Kryptografische Tags (Anti-Cloning) als Pflicht (siehe Roadmap)

---

## 2) UX & Table-Feel (nicht verhandelbar)

- **Table-First:** Der relevante Board-State ist auf dem Tisch sichtbar (Karten in Zonen); AR/Status ergänzt, ersetzt aber nicht.
- **Low Admin:** Keine zusätzlichen physischen Tokens nötig, außer Karten selbst.
- **Determinismus:** Die Matte signalisiert Zustände eindeutig (LED), die App bestätigt nur, erzwingt aber Regeln.

---

## 3) Physisches Zonenlayout

### 3.1 Zonen-IDs
Zonen sind eindeutig über `(side, zone)` identifiziert:

- `P1_ACTIVE`, `P1_BENCH_A`, `P1_BENCH_B`
- `P2_ACTIVE`, `P2_BENCH_A`, `P2_BENCH_B`

### 3.2 Design-Hinweise (Hardware- & Cheat-Prevention)
- **Card Wells / Frames** pro Zone (leichte Vertiefung oder Rahmen), um Überlappung/Schräglage zu reduzieren.
- Zonenabstände so wählen, dass NFC-Felder sich nicht „sehen“ (Ferrit-Shield empfohlen).
- Pro Zone ist **max. 1 Karte** zulässig (regelseitig + physisch intendiert).

---

## 4) NFC Read Model

### 4.1 Stabilitäts-/Debounce-Parameter (Baseline)
Ziel: keine Flackerzustände, keine „Ghost Moves“.

- `present` wird ausgelöst, wenn ein Tag **≥ 600 ms** kontinuierlich erkannt wird.
- `removed` wird ausgelöst, wenn ein Tag **≥ 1000 ms** nicht erkannt wird.

Diese Werte sind **Mode-abhängig** konfigurierbar (Casual toleranter, Tournament strikter).

### 4.2 Multi-Tag / Interferenz
Wenn zwei Tags gleichzeitig „in einer Zone“ wirken (Overlap/Interferenz):
- Zone geht in Status `UNSTABLE`.
- App fordert Korrektur (nur, wenn Spielstate betroffen ist).
- LED signalisiert Error (siehe LED Map).

### 4.3 Read Scheduling (6 Zonen)
Um Interferenz zu minimieren:
- Reader werden **zeitgesliced** gepollt (Round-Robin).
- Ziel: effektive Zonen-Update-Rate 300–600 ms.

---

## 5) Turn- & Window Locks (Anti-Exploit)

### 5.1 Windows (v1, kompatibel zur TCG-Engine)
- `CHARGE` (Moves erlaubt)
- `CLASH` (Zonen gesperrt)
- `AFTERGLOW` (Moves wieder erlaubt)

### 5.2 Lock-Regeln
- Während `CLASH` sind Zone-Änderungen **illegal**, außer ein Effekt erlaubt explizit Switch/Move.
- Bei illegaler Änderung:
  - **Casual:** Warnung + Event-Log
  - **Ranked/Tournament:** Warnung + Event-Log (Penalty Policy wird separat definiert)

---

## 6) Sicherheits-/Fairness-Policy (v1)

### 6.1 Tag Spoofing (bekanntes Risiko)
v1 akzeptiert Tag-IDs ohne Kryptografie (für Prototyping & Casual).

**Roadmap (Ranked/Tournament):**
- Kryptografische Tags (Challenge/Response) + Session-Binding.

### 6.2 Hot-Swap Abuse
Mitigation:
- Window Locks
- Minimum-Dwell-Time (Debounce)
- Event-Logging (für Turnier / Debugging)

---

## 7) Integration Requirements (App)

- Matte ist **primäres Input-Device** für Board-Placement (Active/Bench).
- App muss einen **Board Snapshot** pro Spieler führen und mit Game State synchronisieren.
- App muss „unstable states“ handhaben (UI: „bitte Karte korrekt platzieren“).

Siehe: `APP_STATE_MACHINE_v0_1.md`.

---

## 8) Testkriterien (Abnahme v1)

- **Correctness:** Zone present/removed entspricht realem Placement in ≥ 99% der Fälle bei normaler Nutzung.
- **Latency:** Wahrgenommene Reaktion ≤ 1.2 s (inkl. Debounce).
- **UX:** Spieler kann 10 Turns spielen ohne „Scan ans Handy“-Zwang.
- **Robustness:** Reconnect innerhalb 5 s ohne Match-Abbruch.

