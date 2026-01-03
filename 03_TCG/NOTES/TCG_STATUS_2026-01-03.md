Task:
Create a single new file in the repository and do not modify anything else.

Constraints:
- Only create: `03_TCG/NOTES/TCG_STATUS_2026-01-03.md`
- No edits to existing files
- No renames, no deletes
- Content must be exactly as provided below (verbatim)

FILE PATH:
03_TCG/NOTES/TCG_STATUS_2026-01-03.md

FILE CONTENT (verbatim):
---
# MystiMons TCG – Status / Übergabe
**Datum:** 2026-01-03  
**Kontext:** Set 1 / Wave-1 Konsolidierung, App-first Hybrid-TCG

---

## Entscheidungen (final)

### App-Mode
- **App ist von Anfang an Pflicht** (app-native Play).
- **Wave-1 enthält kein Hidden Intent** (keine verdeckten Informationen, keine geheimen Entscheidungen).

### Global Slot
- **Terrain bleibt** als einziger globaler Slot.
- **Stadium wird aus Set 1 entfernt** (S-01…S-04 raus; ggf. später recyceln).

### Naming
- Element-Naming: **„Pflanze“ wird vollständig zu „Natur“** vereinheitlicht.

---

## Kritische Konsolidierung

### Problem: ID-Kollisionen
Es existieren reale Kollisionen / Mehrfachverwendungen von Prefixes:
- `E-01` wird für **Energie** und **Erde-MystiMons** verwendet.
- Wind/Wasser/Action-Prefixes überschneiden sich ebenfalls.

### Entscheidung: Typ-Prefix-IDs (global eindeutig)
Neue kanonische Prefixe:
- `MON-` = MystiMons
- `ENE-` = Energie
- `ACT-` = Aktionen
- `REL-` = Relikte
- `TER-` = Terrain
- `CHM-` = Special Champions

**Element-Codes (3-letter, eindeutig):**
FEU / WAS / NAT / ERD / WIN / EIS / BLI / SCH / LIC / MET / DRA

**Empfohlenes MystiMon-ID-Format:**
`MON-<CODE>-S<Stufe>-<NN>`
Beispiel: `MON-WAS-S1-01`

---

## Wave-1 Scope (Starter Environment)

### Grundsatz
- **Wave-1 = Stufe 1–2 pro Element + Support-Suite**  
- Keine Stage 3–4, keine Champions/Specials in Wave-1 Meta.
- App übernimmt Tracking/Timer/„1× pro Zug“-Caps, aber **keine Hidden Intent Mechaniken**.

### Inputs vorhanden
- `ELEMENTE.zip` (alle Elemente / MystiMons Specs)
- Set-1 Support-Dokumente: Energie / Relikte / Terrain / Aktionen
- Overviews: Master Overview, Set-1 Übersicht, Session Summary

---

## Balance-Watchlist (sofort)

### 1) Karten-Suche
- Alt: `A-12` (tutor „bis zu 3 Karten deiner Wahl“)
- Neu: `ACT-12`
- **Risiko:** Format-warping (zu starke Konsistenz/Combo/Antwort-Dichte)
- **Aktion:** Errata finalisieren (depowered tutor + klare Caps)

### 2) Dissonanten-Detektor
- Alt: `R-13`
- Neu: `REL-13`
- **Risiko:** Dauerhafte Card-Selection-Engine, zu viel „free quality“
- **Aktion:** Errata finalisieren (weniger Frequenz/strengere Caps)

### 3) Resonanz-Verstärker (Duplikat/Stack-Risiko)
- `REL-11` (Field) vs. `A-14`/`ACT-14` (Item)
- **Risiko:** Identitäts-Overlap + potenzielles Stack-/Burst-Problem
- **Aktion:** In Set 1 nur **eine** Version behalten, die andere verschieben.

---

## Offene Aufgaben (nächster Termin)

1) **Alt → Neu ID-Mapping-Tabelle** für Set 1 vollständig erstellen  
   (Support + alle MONs) und konsistent in Docs übernehmen.
2) **Errata finalisieren:** `ACT-12`, `REL-13`, Resonanz-Verstärker-Duplikat
3) **Wave-1 Keyword/Status Baseline** (Allowed/Experimental/Banned) ohne Hidden Intent
4) **Set-1 Aktionen konsolidieren:** Stadium-Sektion entfernen, Count auf **14 Aktionen** fixen
---
