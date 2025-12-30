# SINGLE SOURCE OF TRUTH
## Canon-Prioritäten & Glossar (Lore / TCG / App)

**Zweck:** Dieses Dokument ist die verbindliche Referenz für (a) Konfliktauflösung bei widersprüchlichen Dokumenten und (b) eindeutig definierte Begriffe, damit Lore und TCG nicht semantisch „driften“.

**Gilt für:** Buchreihe Band 1–7 + TCG (Sets) + App/AR + Smart Mat (Rules Engine).

---

## 1) Canon-Prioritäten (Conflict Resolution)

---

## 1.1 Baseline-Policy: App-required + Smart Mat (Board Input)

- **Baseline:** MystiMons TCG wird **immer** mit App gespielt (kein vollständig analoger Modus).
- **Smart Mat (v1):** Active/Bench-Placement wird primär über die **doppelseitige NFC-Matte** erfasst (je Seite: Active + 2 Bench).
- **Authority:** Bei Konflikten zwischen „was liegt physisch“ und „was die App glaubt“ gilt:
  1. **Matten-Snapshot** (stabil erkannt) ist authoritative für Active/Bench.
  2. Bei `UNSTABLE` oder Reconnect fordert die App eine **Sync-Bestätigung**.

- **Window Locks:** Während `CLASH` sind Zone-Änderungen standardmäßig illegal (Anti-Exploit / Fairness).

Siehe: `04_APP_TECH/SMART_MAT/*`.


Wenn zwei Quellen sich widersprechen, gilt **immer** die Quelle mit der höheren Priorität.
Innerhalb einer Prioritätsstufe gilt: **neueste Version / jüngstes Datum** gewinnt.

### PRIORITY 0 — Unverrückbar (Hard Canon)
1. `00_CANON/PILLARS.md`  
2. `00_CANON/CANON_LAWS.md`  
3. `00_CANON/CONFLICT_ENGINE.md`  
4. `00_CANON/BRAND_PROMISE.md` + `00_CANON/TONE_GUIDE.md`

> Hinweis: Diese Dateien definieren, was *niemals* passieren darf und welche Werte MystiMons transportiert.

### PRIORITY 1 — Buch-1-Spezifikationen (Hard Overrides für Buch 1)
1. `00_CANON/SUPPLEMENTS/CANON_BIBEL_BOOK1.md`

> Wird genutzt, um Power-Creep zu verhindern und Buch-1-spezifische Limits festzunageln (insb. „Das Hören“ und „Bindung“).

### PRIORITY 2 — Welt-/Magiesystem-Referenz (Canon Reference)
1. `00_CANON/SUPPLEMENTS/MAGIESYSTEM_CODEX_V1_1.md`

> Definiert Mechanik-Logik, Kostenmodelle, Grenzen („nicht möglich“) und Progression.

### PRIORITY 3 — Narrative Produktspezifikation (Buch 1)
1. `02_NARRATIVE/book_01/OUTLINES/*` (z. B. `AETHERIA_BUCH_1_OUTLINE_v2_REALITY.md`)  
2. `02_NARRATIVE/book_01/WRITING_FRAMEWORK/*` (Master Guide / Scorecard)  

> Diese Ebene darf Details konkretisieren, aber nicht gegen PRIORITY 0–2 verstoßen.

### PRIORITY 4 — TCG Produktspezifikation (Set 1 + Regeln)
1. `03_TCG/RULEBOOK/*` (z. B. Regelwerk v2.x)  
2. `03_TCG/sets/SET-001/*` (z. B. Naming Bible, Set Overview)  
3. `03_TCG/MODES/*` (Simple/Standard/Tournament als Modusschicht)

> TCG-Regeln definieren Spiellogik. Sie dürfen nie Canon Laws brechen (z. B. „Tod ist permanent“, „Kein Pay-to-Win“).

### PRIORITY 5 — Registry (Entities / IDs)
1. `01_REGISTRY/INDEX.json` (maschinenlesbar, referenzführend)  
2. `01_REGISTRY/*/*_MASTER.md` (human-readable Views)  

> Bei Konflikten gilt: **INDEX.json** ist führend; Master-MDs sind sekundäre Darstellung.

---

## 2) Terminologie: Lore vs. TCG (Semantik-Bridge)

### 2.1 „Tod“ vs. „KO“ (nicht verwechseln)
- **Lore: TOD**  
  - Irreversibel. Keine echte Wiederbelebung.
  - „Geister/Erinnerungen“ sind möglich, aber kein Zurückholen der Person/Seele.

- **TCG: KO (Knockout)**  
  - Rein spielmechanisch: MystiMon fällt auf **0 HP**, geht **in den Discard**, **Attached Energy** geht verloren.
  - KO ist **kein** Lore-Tod. Es ist „kampfunfähig / ausgeschaltet“.

**Regel:** Kartentexte dürfen nie suggerieren, dass ein KO einem Lore-Tod entspricht.

### 2.2 Discard / Graveyard
- **Discard** ist der Spielbereich für abgelegte Karten (KO, Kosten, Effekte).  
- Für die Lore-Kommunikation sollte Discard nicht als „Friedhof“ bezeichnet werden (um Tod-Semantik zu vermeiden).

### 2.3 Rebind (TCG-Term, empfohlen)
**Definition:** Spielmechanik, die ein **KO’d** MystiMon aus dem **Discard** zurück in eine erlaubte Spielzone bringt (Hand/Bench/Active, je nach Effekt).

**Regel:** Wenn ältere Kartentexte „Resurrect“ nutzen, ist die canonical Interpretation **immer**: **Rebind** (KO-Recovery), niemals echte Wiederbelebung.

### 2.4 Bindung (Buch 1)
**Definition:** Der „Premium-Kanal“ der Resonanz (Telepathie/Komplexität/Qualität), explizit als **Upgrade** ab dem Bindungsereignis gesetzt.

**Buch-1 Fixpunkt:** **Bindung = Kapitel 24** (Finn ↔ Sylphira).

### 2.5 „Das Hören“ (Finn) — Canon Limits
**Vor Bindung (K1–K23):**
- Sensorik/Emotion/Atmosphäre/Impuls, kein „Detektivscanner“
- Keine präzise Ortung, keine verlässlichen Fakten, keine Identitäts-Erkennung
- Seltene „Impressions“ sind unscharf, nicht steuerbar, nicht plottragend

**Nach Bindung (ab K24):**
- Steigerung ist erlaubt, aber muss sich wie ein echtes Upgrade anfühlen (weil vorher bewusst limitiert war).

### 2.6 Dominanz / Hingabe (Weltmechanik)
- **Dominanz:** schneller Machtgewinn, immer mit Schmerz/Kosten; erhöhtes Risiko von Bruch/Dissonanz.
- **Hingabe:** langsam, stabil, langfristig stärker; Kosten sind kontrollierbar.

---

## 3) „Reserved Words“ (Begriffe mit Schutzstatus)

Diese Begriffe dürfen nicht frei synonym verwendet werden:

| Begriff | Schutzregel | Warum |
|---|---|---|
| **Tod** | Nur Lore-Kontext. Nicht für TCG KO verwenden. | Canon Law: Tod ist permanent. |
| **KO** | Nur TCG-Kontext. | Verhindert Lore-Fehlinterpretation. |
| **Absorption** | Immer negativ / villain-coded. | Canon Law: Absorption ist immer böse. |
| **Bindung** | Buch 1: ab K24 als Upgrade. | Power-Creep-Schutz, klare Progression. |
| **Aetherion** | Mystery-Layer. Keine Voll-Erklärung vor späteren Bänden. | Canon Law: Aetherion bleibt Mysterium. |

---

## 4) Authoring-Standards (damit Sync funktioniert)

### 4.1 Tagging (empfohlen)
Jeder neue Abschnitt/Entwurf beginnt mit einem der Tags:
- `[LORE]` (Buch / Worldbuilding)
- `[TCG]` (Karten / Regeln / Balance)
- `[APP]` (Tracking / Patchbarkeit / Hidden Info)

### 4.2 Print vs Digital (Hybrid-Regel)
- Alles, was **Counter-Tracking**, **RNG**, **persistente Entwicklung** oder **umfangreiche Statusverwaltung** braucht, ist **Digital-Logik**.
- Print bleibt kurz, klar, und enthält keine komplexen Buchhaltungsaufgaben.

### 4.3 „Canon-Check“ (Minimal)
Bei jeder neuen Lore-Szene oder neuen Karte:
1. Bricht es eine Canon Law?
2. Wird „Das Hören“ als GPS/Scanner missbraucht?
3. Verwechselt der Text KO mit Tod?
4. Ist Absorption klar als böse/corrupt codiert?
5. Erhöht ein Effekt Power ohne Kosten?

---

## 5) Open Issues (aktueller Stand, bewusst offen)
- **Echos/Rest-Resonanz** (Story Seeds) dürfen nicht als echte Resurrection interpretiert werden. Wenn genutzt, dann als Erinnerung/Spur/Mysterium, nicht als Rückkehr.
- Wenn ein Begriff im Set-Text (Naming Bible / Card List) gegen dieses Glossar läuft, wird er **umbenannt** (z. B. „Resurrect“ → „Rebind“).

---

**Letztes Update:** 30. Dezember 2025  
**Owner:** 00_CANON (Hard Canon)

## Story Arc (Hard Production Canon)

- **ARC-LENGTH-001:** Hauptreihe umfasst **6 Bände** (Band 1–6). **Band 7** ist ein **Origin/Prequel** (Entstehung von Aetherion) und erscheint als **Release #7 nach Band 6**.
- **ARC-PROTAG-001:** Finn ist die Hauptfigur in **Band 1–3**.
- **ARC-PROTAG-003:** Kira ist die Hauptfigur in **Band 4–6**.
- **ARC-PROTAG-002:** In **Band 4** stirbt Finn (Lore-Tod ist permanent). Der Fokus wechselt dauerhaft auf Kira (keine „Zurücknahme“).
- **ARC-ORIGIN-001:** Band 7 darf Origin-Fakten vollständig auflösen, aber **keine Retcons** gegen PRIORITY 0–2 erzeugen (nur Reframing von zuvor als Mythos/Fragment markierten Informationen).

### Spoiler-Gates (Transmedia)
- **ARC-SPOIL-001:** TCG/App dürfen Finns Tod **nicht** vor dem Band-4-Release-Fenster explizit spoilern.
- **ARC-SPOIL-002:** Origin-Fakten zu Aetherion sind bis Band 7 **myth/fragment-only** (keine explizite Bestätigung in Karten-/App-Texten vor SET-007/Band 7).


## Authoring & validation
- Canonical card/keyword/set schemas live in `03_TCG/AUTHORING/` and are the source of truth for machine-readable TCG content.
