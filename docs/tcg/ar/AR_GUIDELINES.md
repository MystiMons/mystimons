# AR_GUIDELINES (Smartglasses / AR Layer) — MystiMons TCG
Version: v1.0  
Status: Draft (repo-ready)  
Owner: Structurist / Product + TCG Design  
Last updated: 2025-12-31  

## 1) Zweck
Diese Guidelines definieren **harte Regeln** für Smartglasses-/AR-Features rund um das MystiMons TCG, damit:
- **Fairness** im kompetitiven Spiel garantiert bleibt (kein Pay-to-Win / kein Info-Vorteil).
- **Canon** (Pillars & Laws) nicht verletzt wird.
- **Privacy/Consent** gerade mit junger Zielgruppe „by design“ eingehalten wird.
- AR als **Erlebnis-Schicht** funktioniert (Immersion, Lernen, Events), nicht als „Power-Up“.

---

## 2) Nicht verhandelbare Grundprinzipien (Guardrails)

### G-01: Parity-Prinzip (Fairness)
Alles, was **spielrelevant** ist (Regeln, Zustände, Trigger, Timer, Pairings), muss **vollständig** auch ohne Smartglasses verfügbar sein — mindestens via **Smartphone-App + physische Komponenten**.

> Smartglasses dürfen **Komfort** geben, nicht **Stärke**.

### G-02: Kein Entscheidungs- oder Scouting-Advantage
AR darf **keine Empfehlungen** geben, die über reine Regelhilfe hinausgehen:
- Kein „Best Move“
- Keine Win-Percentages / Odds / Simulationen
- Kein Deck-/Hand-/Sideboard-Scouting
- Keine Hidden-Info-Erkennung (z. B. markierte Sleeves, Handkarten-Schatten, etc.)

### G-03: Opt-in & Consent-by-Design
Features mit Kamera/Mikrofon/Recording sind **standardmäßig aus** und erfordern:
- sichtbaren **Recording-Indikator**
- **beidseitiges** Einverständnis am Tisch (oder Event-Policy)
- klare, einfache „Stop“-Funktion (Voice/Knopf) + sofortige Deaktivierung

### G-04: Offline-first
Ein Match darf **niemals** davon abhängen, dass Cloud/Netz verfügbar ist.
- AR-Visuals dürfen ausfallen, ohne das Spiel zu brechen.
- Regeltexte/Referenzen müssen lokal cachebar sein.

### G-05: Reliability & Fallback
Wenn AR-Tracking/Erkennung nicht 100% zuverlässig ist:
- Es ist **nur kosmetisch** (Flavor).
- Physische Marker/State bleiben „Source of Truth“.

---

## 3) Erlaubt / Empfohlen (Green List)

### A) Kosmetische AR-Inszenierung (0% Competitive Impact)
- Element-Auren, Summon-VFX, „Resonanz-Brücken“
- UI-Overlays für Zuschauer/Stream (Spectator Mode)
- Lore-Stinger (1 Satz / kurzer Audio-Tag) beim Ausspielen einer Karte

### B) Regel-Assist (nur „Rules“, nicht „Strategy“)
- Erklärung von Timing-Fenstern („Jetzt darfst du …“)
- Erinnerung an **optionale** Trigger („Du kannst …“)
- Karten-Glossar / Keyword-Hilfe / Suchfunktion
- Onboarding-Tutorials & Quests (Training Mode)

### C) Turnier- & Event-Komfort
- Pairings/Timer/Result-Scan via QR (nicht spielentscheidend)
- Judge-Tools: Rulings-Nachschlagen, Round-Management (Event Mode)

---

## 4) Verboten (Red List)

### R-01: Strategische Entscheidungshilfe
- „Empfohlener Zug“, „Beste Linie“, „Top 3 Plays“
- Wahrscheinlichkeiten/EV/Odds/Simulations (auch „nur als Tipp“)

### R-02: Hidden-Information / Scouting
- Erkennen/Schätzen von Handkarten, Decklisten, Sideboard
- Erkennen von Sleeves/Markierungen
- Gegner-Analyse („Gegner spielt vermutlich Deck X“ basierend auf Scans)

### R-03: Exklusive Effekte / Vorteile nur für Brillennutzer
- Zusätzliche Ressourcen, Trigger, Draws, Re-Rolls, Timer-Boni
- Zugang zu exklusiven Karten/Mechaniken, die am Tisch powern

### R-04: Non-consensual Recording / Biometrie
- Always-on Aufnahme
- Gesichtserkennung, Altersschätzung, Emotionserkennung
- Speicherung/Upload ohne expliziten Opt-in

---

## 5) Privacy & Safety Policy (Minimum Standard)
- **Default**: Kamera/Mikrofon aus.
- **Local-first**: Bild-/Audioverarbeitung möglichst lokal; Upload nur mit Opt-in.
- **Data minimization**: nur speichern, was zwingend nötig ist.
- **Delete**: „Löschen jetzt“ muss schnell, sichtbar, verlässlich sein.
- **Youth safe**: keine Social-Features, die Kids in 1:1 Kontakt mit Fremden bringen (oder nur stark moderiert/guardian).

*(Hinweis: Diese Datei ersetzt keine Rechtsberatung. Für konkrete Regionen bitte Legal/Compliance reviewen.)*

---

## 6) Competitive Play Regeln (Tournament Integrity)
- Bei Competitive/Ranked:
  - **Nur Green-List** Features erlaubt.
  - Coach-Modus nur als **Rules-Reference**, nicht als „Hinweisgeber“.
  - Recording grundsätzlich **verboten**, außer Event-Policy erlaubt es explizit.
- Bei Casual/Story Play:
  - Mehr Spielraum, aber weiterhin: Consent & Parity.

---

## 7) QA-Checkliste (Go/No-Go)
Ein AR/Smartglasses-Feature ist **nur dann shipbar**, wenn alle Punkte „Ja“:

1. ☐ Gibt es **keinen** strategischen Vorteil gegenüber Non-AR?
2. ☐ Ist alles Spielrelevante via **Phone + physisch** vollständig verfügbar?
3. ☐ Funktioniert das Match **offline** ohne Feature?
4. ☐ Gibt es saubere **Fallbacks** bei Tracking-Fehlern?
5. ☐ Kein Hidden-Info-Scan, kein Scouting, keine Odds/Simulation.
6. ☐ Consent-by-design umgesetzt + sichtbarer Recording-Indicator.
7. ☐ Datenschutz: Data minimization, local-first, simple delete.
8. ☐ Turnier-Regeln & Judge-Policy dokumentiert.
9. ☐ Accessibility: Kann man es ausschalten, ohne Nachteile?
10. ☐ Canon-Check: verletzt nichts aus Pillars/Laws (insb. Fairness & „Willen“ der Resonanten in der Darstellung).

---

## 8) Review-Template (für PRs / Design Reviews)
**Feature Name:**  
**Goal (1 Satz):**  
**User Mode:** Casual / Competitive / Spectator / Judge  
**Source of Truth:** Physisch / App / Mixed (begründet)  
**Parity:** Welche Funktion ist identisch ohne Brille?  
**Competitive Risk:** Low / Medium / High (warum)  
**Privacy:** Welche Sensoren? Speicherung? Opt-in?  
**Offline:** Was passiert ohne Netz?  
**Fallbacks:** Was passiert bei Erkennungsfehlern?  
**Canon:** Pillars/Laws betroffen? (Ja/Nein + welche)  
**Decision:** Approve / Revise / Reject  

---

## 9) Offene Fragen (Backlog)
- Event-Policies pro Region (Recording, minors, venue rules)
- „Spectator Mode“ Architektur (Phone vs. Glasses vs. Stream overlay)
- Moderation/Reporting, wenn Social später kommt
- Performance-Budget & Battery constraints (wenn konkrete Hardware feststeht)
