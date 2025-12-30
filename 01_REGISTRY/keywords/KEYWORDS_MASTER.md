# KEYWORDS REGISTRY
## Begriffe, Mechaniken, Terminologie

**Version:** 1.0
**ID-Schema:** KWD-###
**Quelle:** NAMING_BIBLE

---

# KERN-BEGRIFFE

---

## KWD-001: RESONANZ

```yaml
id: KWD-001
term_de: Resonanz
term_en: Resonance
type: Core Mechanic

definition: >
  Die freiwillige, telepathische Bindung zwischen 
  Mensch (Hüter) und Resonant.

key_aspects:
  - Immer freiwillig (@PIL-001)
  - Gegenseitiges Vertrauen erforderlich
  - Wächst über Zeit
  - Ermöglicht Kommunikation
  - Verstärkt beide Partner

visual_indicator: Resonanzkern leuchtet (@OBJ-001)

canon_constraints:
  - "@PIL-001: Nie erzwungen"
  - "@LAW-004: Resonant muss zustimmen"

opposite: Dissonanz (@KWD-002)

usage_in_text:
  correct: "Die Resonanz zwischen ihnen wuchs."
  incorrect: "Er benutzte Magie." # Zu generisch
```

---

## KWD-002: DISSONANZ

```yaml
id: KWD-002
term_de: Dissonanz
term_en: Dissonance
type: Core Mechanic

definition: >
  Das Gegenteil von Resonanz — eine erzwungene oder
  zerbrochene Bindung. Schmerzhaft für beide Seiten.

causes:
  - Erzwungene Bindung
  - Vertrauensbruch
  - Absorption-Versuch
  - Extreme Traumata

effects:
  - Schmerz für beide
  - Geschwächte Fähigkeiten
  - Kann zur Trennung führen
  - Resonanzkern verdunkelt sich

canon_constraints:
  - "@PIL-001: Zwang führt zu Dissonanz"
  - "@LAW-005: Absorption erzeugt permanente Dissonanz"

opposite: Resonanz (@KWD-001)
```

---

## KWD-003: ABSORPTION

```yaml
id: KWD-003
term_de: Absorption
term_en: Absorption
type: Forbidden Mechanic

definition: >
  Das gewaltsame Reißen eines Resonanten von seinem
  Hüter und Einverleiben in sich selbst.

effects:
  - Ursprünglicher Hüter: Trauma, oft Tod
  - Resonant: Seele wird zerstört
  - Absorbierer: Gewinnt Macht, verliert Seele

canon_law: "@LAW-005: Absorption ist IMMER böse"

visual_indicator:
  - Dunkle Adern beim Absorbierer
  - Resonanzkern des Opfers zerbricht
  - Schwarze Energie während Prozess

practitioners:
  - Manche Champions (geheim)
  - Flamrion (@CHR-007)

usage_note: >
  Es gibt KEINE "gute" Absorption. Keine Ausnahmen.
```

---

## KWD-004: HÜTER

```yaml
id: KWD-004
term_de: Hüter
term_en: Keeper
type: Role

definition: >
  Ein Mensch, der in Resonanz mit einem Resonanten steht.

requirements:
  - Gegenseitige Wahl
  - Vertrauen aufbauen
  - Verantwortung übernehmen

not_to_use:
  - "Trainer" (zu Pokémon)
  - "Meister" (impliziert Dominanz)
  - "Besitzer" (Resonanten sind keine Besitztümer)

hierarchy:
  - Anwärter: Noch ohne Resonant
  - Hüter: Mit aktivem Resonant
  - Meister-Hüter: Langjährig, erfahren
  - Champion: Höchster Rang (11 im Rat)
```

---

## KWD-005: RESONANT

```yaml
id: KWD-005
term_de: Resonant
term_en: Resonant
type: Entity

definition: >
  Wesen, die aus Aether geboren werden. Intelligent,
  emotional, individuell. Partner, nicht Werkzeuge.

key_aspects:
  - Haben eigenen Willen (@LAW-004)
  - Jedes Element vertreten
  - Können evolvieren (Haupt-Linien)
  - Persönlichkeit ist einzigartig

not_to_use:
  - "Monster" (abwertend)
  - "Kreatur" (nur außerhalb der Welt)
  - "Tier" (zu primitiv)

communication:
  pre_binding: "Gefühle und Bilder, KEINE Worte"
  post_binding: "Telepathisch, Worte möglich"
```

---

## KWD-006: AETHER

```yaml
id: KWD-006
term_de: Aether
term_en: Aether
type: World Element

definition: >
  Die Lebensenergie, die alles in Aetheria verbindet.
  Fließt wie Blut durch die Welt.

properties:
  - Unsichtbar, aber spürbar
  - Ermöglicht Resonanz
  - Genährt von Aetherion
  - In 11 Elemente differenziert

visual_representation:
  - Goldene Linien (Aether-Karten)
  - Leuchtende Kristalle
  - Subtiles Leuchten in der Luft
```

---

## KWD-007: AETHERION

```yaml
id: KWD-007
term_de: Aetherion
term_en: Aetherion
type: Deity/Mystery

definition: >
  Der Schöpfer von Aetheria. Brachte die 11 Elemente
  in Balance. Verschwand vor langer Zeit.

canon_law: "@LAW-008: Bleibt Mysterium bis Band 5+"

what_we_know:
  - Erschuf Aetheria
  - Brachte 11 Elemente in Balance
  - Verschwand

what_we_dont_know:
  - Warum verschwand er?
  - Ist er tot?
  - Kommt er zurück?
  - Was hat er hinterlassen?

usage_in_book_1:
  - Kaum erwähnt
  - Legenden, keine Fakten
  - Symbol im Siegel (@OBJ-003)
```

---

# TCG-MECHANIKEN

---

## KWD-010: EVOLUTION

```yaml
id: KWD-010
term_de: Evolution
term_en: Evolution
type: TCG Mechanic

definition: >
  Der Prozess, bei dem ein Resonant eine höhere
  Entwicklungsstufe erreicht.

stages:
  - Stufe 1: Basis
  - Stufe 2: Erste Evolution
  - Stufe 3A/3B: Split-Paths
  - Stufe 4A/4B: Finale Formen

requirements_in_lore:
  - Zeit und Training
  - Vertrauensaufbau
  - Emotionale Trigger

requirements_in_tcg:
  - Vorherige Stufe im Spiel
  - Evolutions-Kosten zahlen
```

---

## KWD-011: TERRAIN

```yaml
id: KWD-011
term_de: Terrain
term_en: Terrain
type: TCG Mechanic

definition: >
  Spielfeld-Modifikatoren, die bestimmte Elemente
  verstärken oder schwächen.

examples:
  - Vulkanfeld: Feuer +1 ATK
  - Ozean: Wasser +1 DEF
  - Sturm: Blitz +1 SPD
```

---

## KWD-012: QUINTESSENZ

```yaml
id: KWD-012
term_de: Quintessenz
term_en: Quintessence
type: TCG Mechanic

definition: >
  Universelle Energie-Form, die jedes Element
  aktivieren kann. Selten und wertvoll.

tcg_function:
  - Zählt als beliebiges Element
  - 1 pro Deck Maximum (Standard)
  - Höhere Limits in Casual
```

---

# LOCATIONS

---

## KWD-020: DIE AKADEMIE

```yaml
id: KWD-020
term_de: Die Akademie
term_en: The Academy
type: Location

location: Lumion (@REG-007)
function: "Ausbildungsstätte für Hüter"
faction: Neutral (@FAC-004) / Rat-kontrolliert (@FAC-001)

appearance_in_book_1: Kapitel 22-28
```

---

## KWD-021: DER RAT DER BALANCE

```yaml
id: KWD-021
term_de: Der Rat der Balance
term_en: The Council of Balance
type: Organization

structure: 11 Champions, einer pro Element
function: Regierung von Aetheria
faction: @FAC-001

corruption: "Versteckt unter 'Ordnung'"
```

---

# REFERENZ-TABELLE

| ID | Begriff | Typ |
|----|---------|-----|
| KWD-001 | Resonanz | Core |
| KWD-002 | Dissonanz | Core |
| KWD-003 | Absorption | Forbidden |
| KWD-004 | Hüter | Role |
| KWD-005 | Resonant | Entity |
| KWD-006 | Aether | World |
| KWD-007 | Aetherion | Mystery |
| KWD-010 | Evolution | TCG |
| KWD-011 | Terrain | TCG |
| KWD-012 | Quintessenz | TCG |
| KWD-020 | Die Akademie | Location |
| KWD-021 | Der Rat | Organization |

---

*Letzte Änderung: 30. Dezember 2025*
