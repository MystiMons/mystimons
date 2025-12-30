# CHARACTERS REGISTRY
## Charaktere aus Buch 1

## Core Protagonists

- **@CHR-001** — Finn Alder (Protagonist Band 1–3; stirbt Band 4)
- **@CHR-011** — Kira (Protagonistin ab Band 4)


## CHR-001: FINN ALDER

```yaml
id: CHR-001
name: Finn Alder
role: Protagonist (Buch 1)
age: 14
origin: Grünhafen, Sylvaris (@REG-009)
element_affinity: Natur (@ELM-009)
resonant: Sylphira (@CRE-003) — ab Kapitel 25

special_ability:
  name: "Das Hören"
  description: "Kann ALLE Resonanten-Emotionen spüren"
  mechanics:
    - Spürt Emotionen und Druck
    - KEINE Richtung/Gedanken
    - KEINE menschlichen Gedanken
  costs:
    - Nasenbluten bei Überlastung
    - Übelkeit
    - Erschöpfung

personality:
  traits: ["überfordert", "loyal", "mutig trotz Angst"]
  growth_arc: "Von passiv zu aktiv, von Sucher zu Beschützer"
  voice_guide:
    - Kurze Sätze in Stress
    - "du Idiot", "verdammt" sparsam
    - Keine poetischen Analysen
    - Authentisch 14-jährig

relationships:
  - Theo (Bruder): Sucht ihn verzweifelt
  - Sylphira: Wächst zur Bindung
  - Nila: Erste Verbündete
  - Rex: Rival → Freund

quest: "Bruder Theo finden"
faction: Neutral → Vergessene-aligned (@FAC-002)

book_1_arc:
  start: "Dorfbewohner, passiv"
  midpoint: "Aktiver Sucher, findet Verbündete"
  end: "Beschützer, gebunden mit Sylphira"

canon_constraints:
  - "@PIL-001: Bindung muss freiwillig sein"
  - "@LAW-004: Sylphira wählt ihn"

death_note: "Stirbt mit 26 Jahren (Buch 2 Prolog) — Kiras Katalysator"
```

---

## CHR-002: THEO ALDER

```yaml
id: CHR-002
name: Theo Alder
role: Supporting/Quest Object
age: 18
origin: Grünhafen, Sylvaris (@REG-009)
resonant: Verdantis (@CRE-SPECIAL-001)

status: "Verschwunden (Buch 1 Start)"
reason: "Kämpft gegen das System"

personality:
  traits: ["beschützend", "idealistisch", "geheimnisvoll"]
  relationship_to_finn: "Großer Bruder, Beschützer"

book_1_appearances:
  - Kapitel 2: In Sylphiras Vision
  - Kapitel 19: Wiedersehen in Zephyria
  - Kapitel 25+: Climax-Unterstützung

faction: Die Vergessenen (@FAC-002)
```

---

# VERBÜNDETE

---

## CHR-003: NILA TIDEBORN

```yaml
id: CHR-003
name: Nila Tideborn
role: Ally
age: 15
origin: Aquarion (@REG-002)
element_affinity: Wasser (@ELM-002)
resonant: Aquor (@CRE-002) — etabliert

personality:
  traits: ["praktisch", "loyal", "sarkastisch"]
  function: "Finns erste Verbündete, Realitäts-Check"

first_appearance: Kapitel 5
join_party: Kapitel 5

special_skill: "Hafenkenntnis, Navigation"
```

---

## CHR-004: REX ASHFORD

```yaml
id: CHR-004
name: Rex Ashford
role: Ally (Rival → Freund)
age: 16
origin: Pyros (@REG-001)
element_affinity: Feuer (@ELM-001)
resonant: Embrix (@CRE-001) — etabliert

personality:
  traits: ["arrogant", "mutig", "loyal wenn überzeugt"]
  arc: "Von Rival zu echtem Freund"

first_appearance: Kapitel 9
join_party: Kapitel 11

special_skill: "Kampferfahrung"
```

---

## CHR-005: ELARA STONEHEART

```yaml
id: CHR-005
name: Elara Stoneheart
role: Ally
age: 17
origin: Terravok (@REG-003)
element_affinity: Erde (@ELM-003)
resonant: Terragus (@CRE-004) — etabliert

personality:
  traits: ["ruhig", "weise", "beschützend"]
  function: "Ältere Schwester-Figur, Stabilität"

first_appearance: Kapitel 14
join_party: Kapitel 14

special_skill: "Tunnel-Navigation, Erdmanipulation"
```

---

# ANTAGONISTEN

---

## CHR-006: AUFSEHER CALDER

```yaml
id: CHR-006
name: Aufseher Calder
role: Antagonist (Mid-level)
origin: Ferros (@REG-010)
resonant: Ferron (@CRE-SPECIAL-002)
faction: Der Rat (@FAC-001) / Die Scouts (@FAC-003)

personality:
  traits: ["brutal", "effizient", "überzeugt"]
  motivation: "Glaubt an Ordnung durch Kontrolle"
  nuance: "Nicht rein böse — glaubt an seine Mission (@PIL-005)"

appearances:
  - Kapitel 7: Erwähnt
  - Kapitel 12: Erscheint
  - Kapitel 27: Konfrontation

methods:
  - Erzwungene Bindungen
  - Jagd auf Ungebundene
  - Einschüchterung

conflict_engine: Dominanz (@CONFLICT-ENGINE)
```

---

## CHR-007: FLAMRION

```yaml
id: CHR-007
name: Flamrion
role: Main Antagonist (hinter den Kulissen)
title: "Feuer-Champion des Rates"
faction: Der Rat (@FAC-001) — Anführer der Scouts (@FAC-003)

status: "Erwähnt, nicht direkt konfrontiert in Buch 1"

personality:
  traits: ["mächtig", "korrupt", "einst idealistisch"]
  backstory: "Was machte ihn zu dem, was er ist?"

methods:
  - Absorption (stillschweigend)
  - Absolute Kontrolle
  - Multiple Resonanten durch Absorption

conflict_engine: Extreme Dominanz (@CONFLICT-ENGINE)

book_1_role: "Drohende Präsenz, Setup für später"
canon_constraints:
  - "@LAW-005: Absorption ist immer böse"
```

---

# NEBENCHARAKTERE

---

## CHR-008: CAPTAIN HARROW

```yaml
id: CHR-008
name: Captain Harrow
role: Supporting (Neutral)
resonant: Frostix (@CRE-006)

function: "Schmuggler, hilft gegen Bezahlung"
appearance: Kapitel 7

moral_alignment: "Neutral — hilft wem er will"
```

---

## CHR-009: WIDERSTANDSFÜHRER (Name TBD)

```yaml
id: CHR-009
name: TBD
role: Supporting (Vergessene)
resonant: Zephyros (Aeris @CRE-005 Stufe 2)

function: "Kontakt zu den Vergessenen"
appearance: Kapitel 18

faction: Die Vergessenen (@FAC-002)
```

---

# FAMILIE

---

## CHR-010: FINNS MUTTER

```yaml
id: CHR-010
name: Mira Alder (TBD)
role: Supporting
status: "In Grünhafen, wartet"

function: "Emotionaler Anker, Finns Motivation"
appearance: Kapitel 1, Kapitel 28 (Ende)
```

---

# OFFENE SLOTS

```yaml
# Weitere Charaktere nach Bedarf:
# CHR-011 bis CHR-020 reserviert

# ICON CHARACTERS (Marketing):
# - Finn (@CHR-001)
# - Sylphira (@CRE-003)
# - Embrix (@CRE-001)
# - Das Siegel (@OBJ-003)
```

---

*Letzte Änderung: 30. Dezember 2025*