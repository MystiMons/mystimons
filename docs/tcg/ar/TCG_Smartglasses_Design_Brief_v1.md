# DESIGN-BRIEF: Smartglasses-Integration fürs MystiMons TCG (Future Concept)

**Dokumenttyp:** Produkt-/Design-Brief (1 Seite)  
**Status:** Draft (zur Ablage im Repo)  
**Owner:** Chatti (Structurist) · Review: Pascal (Creative), Sammy (Writing)  
**Letztes Update:** 2025-12-31  
**Scope-Horizont:** „Wenn Smartglasses massentauglich werden“ (kein kurzfristiger Commit)

---

## 1) Zielbild (Warum überhaupt?)
Smartglasses sollen das MystiMons TCG **erlebbarer, zugänglicher und event-tauglicher** machen – als **Erlebnis-Schicht** über dem physischen Spiel:

- **Immersion:** Resonanz-/Element-Effekte sichtbar machen (ohne Regelvorteil)
- **Lernen:** Regeln und Abläufe verständlicher für Neueinsteiger
- **Events & Content:** Spectator-/Stream-Overlays, Turnier-Organisation „hands-free“

**Wichtig:** Smartglasses dürfen **nie** ein „Power-Upgrade“ sein (siehe Guardrails).

---

## 2) Canon- & Fairness-Guardrails (Hard Rules)
Diese Punkte sind nicht verhandelbar, weil sie direkt Canon & TCG-Fairness schützen:

1. **Kein Pay-to-Win / kein spielentscheidender Vorteil** (LAW-009)  
   - Keine exklusiven Infos, die ohne Brille nicht verfügbar sind.
   - Keine „best move“-Empfehlungen, keine Wahrscheinlichkeits-/Meta-Optimierung.
2. **Resonanz ist freiwillig** (PIL-001)  
   - Keine Mechanik, die Spieler zu Bindungen zwingt oder „Autoplay“/Zwang suggeriert.
3. **Verbindung > Solo** (PIL-003)  
   - AR-Inszenierung soll Team-Synergien emotional verstärken, nicht „Solo-Highlights“ glorifizieren.
4. **Macht hat einen Preis** (PIL-004)  
   - Visuelle/akustische Effekte dürfen Konsequenzen/Kosten miterzählen (Fatigue, Brüche, Rückstoß).
5. **Datenschutz/Consent-by-Design**  
   - Kamera/Audio: Aufnahmefunktionen standardmäßig AUS.  
   - Explizite Zustimmung aller Beteiligten bei Recording (insb. wegen Minderjährigen).

---

## 3) Kern-Use-Cases (Top 5)
### UC-1: „Arena-Overlay“ (Player Immersion, Zero Advantage)
- Visuelle Effekte über Karten/Board: Auren, Resonanz-Fäden, Element-Impulse, Status (Burn/Frost/Shield etc.)
- **Nur Darstellung** dessen, was ohnehin am Tisch klar ist.

### UC-2: „Regel-Coach“ (Opt-in, Onboarding)
- Kontextsensitive Regel-Erklärungen („Jetzt triggert X“, „Du darfst 1 Marker legen“)
- Keine taktischen Empfehlungen, keine Hidden-Info-Auswertung

### UC-3: „Lore-Stinger“ (Charakter & Welt)
- Kurze, optionale Flavor-Snippets (Text + Sound) beim Ausspielen wichtiger Karten
- Unterstützt: Resonanten wirken als „Wesen mit Willen“, nicht als Werkzeuge

### UC-4: „Spectator/Stream Mode“
- Zuschauer sehen Overlays (LP, Effekte, Karten-Highlights) via Brille oder Smartphone-AR
- Spieler bekommen **nichts zusätzlich** → ideal für Turniere/Content

### UC-5: „Event Ops / Judge Toolkit“ (Hands-free)
- Timer, Pairings, Ergebnisscan (QR), Rundenverwaltung
- Recording/Replay nur als späteres Optional-Feature mit strikten Consent-Regeln

---

## 4) No-Go-Liste (Explizit verboten)
- „Hidden Info“-Extraktion (Hand/Deck erkennen, verdeckte Karten scannen)
- Meta-/Winrate-/Probability-Overlays im Match
- Automatisches Tracken, das ohne physische Bestätigung regelseitig „bindend“ ist
- Exklusive Karten/Promos, die nur mit Smartglasses sinnvoll nutzbar sind
- Anything, das Spieler ohne Smartglasses objektiv schwächer macht

---

## 5) Feature-Design-Prinzipien (Umsetzung)
- **Parity-Prinzip:** Alles Regelrelevante muss ohne Brille gleich gut funktionieren (Smartphone/Print).
- **AR als Spiegel:** Physische Marker bleiben „Source of Truth“. AR ist nur Visualisierung.
- **Fail gracefully:** Wenn Tracking ausfällt → Match läuft normal weiter.
- **Opt-in Layers:** Player kann Effekte/Coach/Lore getrennt aktivieren.
- **Accessibility:** Dezent, nicht überfordernd (YA, unterschiedliche Reiz-Sensitivität).

---

## 6) Technischer High-Level-Ansatz (keine Implementierungsdetails)
- **Card Identity:** QR/ID + Bild-Feature-Fallback (robust gegen Licht/Angles)
- **Board Anchoring:** Tisch-/Spielfeld-Erkennung + stabile AR-Anker
- **State Source:** Companion-App als „State Hub“ (lokal, offline-first), Brille = Client
- **Event Backend:** Optional für Turniere (Pairings/Results), nicht für Casual zwingend

---

## 7) Roadmap (Phasen, risikoarm)
**Phase 0 (Jetzt, Smartphone):**  
- Card-Scan → Regellexikon, Tutorial-Quests, Deck-Builder, Event Check-in (QR)

**Phase 1 (Smartglasses Optional):**  
- Arena-Overlay, Lore-Stinger, Regel-Coach (nur Regeln)

**Phase 2 (Premium Events):**  
- Spectator/Stream Mode, Judge Toolkit, Broadcast-Overlays

**Phase 3 (Nur wenn rechtlich & technisch sauber):**  
- Dispute-Assist (Replay) mit explizitem Consent + Jugendschutz-Flow

---

## 8) Akzeptanzkriterien (Definition of „Canon & Fair“)
- Ein Spieler ohne Brille hat **keinen** messbaren Nachteil im Competitive Play.
- Alle AR-Informationen sind entweder:
  - rein kosmetisch, oder
  - identisch verfügbar via Smartphone/Print, oder
  - ausschließlich für Zuschauer/Judges.
- Tracking-Ausfall verursacht **keine** Regelbrüche (physische Marker bleiben gültig).
- Aufnahmefunktionen sind **opt-in** und benötigen Consent aller Anwesenden.

---

## 9) Offene Fragen (für späteres Decision Log)
- Welche Status/Marker sind im TCG „must-have“ für Visualisierung?
- Welche Turnierformate profitieren am meisten von Spectator-Overlays?
- Welche Jugendschutz-/Consent-Flows sind UX-tauglich im Event-Lärm?
- Welche Mindest-Genauigkeit braucht Card/Board-Tracking, um nicht zu frustrieren?

---

## Decision Log (Placeholder)
- [ ] DL-001: Festlegung „Parity-Prinzip“ als offizielles AR-Guideline
- [ ] DL-002: Aufnahme-Policy für Events (Default Off + Consent Flow)
