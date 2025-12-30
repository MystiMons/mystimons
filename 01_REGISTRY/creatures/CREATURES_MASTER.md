# CREATURES REGISTRY
## Die 22 Starter-Resonanten

**Version:** 1.0
**ID-Schema:** CRE-###
**Struktur:** 11 Haupt-Linien + 11 Mini-Resonanten

---

# TEIL 1: HAUPT-LINIEN (Evolvieren)

---

## CRE-001: EMBRIX-LINIE (Feuer)

```yaml
id: CRE-001
name: Embrix
element: ELM-001
region: REG-001
type: Main-Line Starter
evolution_chain:
  - stage_1: Embrix (40/4/2/3)
  - stage_2: Flaru (55/5/3/4)
  - stage_3a: Pyralux (70/7/3/6) # Speed-Path
  - stage_3b: Magmorus (85/6/6/2) # Tank-Path
  - stage_4a: Infernyx (90/9/4/8) # Phoenix-Speedster ☆☆☆
  - stage_4b: Pyrathor (110/8/8/3) # Vulkan-Gott ☆☆☆
personality:
  traits: ["nervös", "flackernd", "loyal"]
  growth: "Von ängstlich zu mutig"
tcg_archetype: Aggro
book_1_partner: Rex Ashford
canon_constraints:
  - "@PIL-001: Wählt Partner selbst"
  - "@LAW-004: Hat eigenen Willen"
```

---

## CRE-002: AQUOR-LINIE (Wasser)

```yaml
id: CRE-002
name: Aquor
element: ELM-002
region: REG-002
type: Main-Line Starter
evolution_chain:
  - stage_1: Aquor (45/3/3/4)
  - stage_2: Hydron (60/4/4/5)
  - stage_3a: Torrentia (75/6/4/6) # Wave-Path
  - stage_3b: Aquashield (80/4/7/4) # Shield-Path
  - stage_4a: Maelstrix (95/8/5/7) # ☆☆
  - stage_4b: Hydronyx (105/6/9/5) # Ozean-Titan ☆☆
personality:
  traits: ["verspielt", "elegant", "anpassungsfähig"]
  visual: "Leuchtender Otter mit Wasserschwanz"
tcg_archetype: Control/Midrange
book_1_partner: Nila Tideborn
first_appearance: Kapitel 5
```

---

## CRE-003: SYLPHIRA-LINIE (Natur)

```yaml
id: CRE-003
name: Sylphira
element: ELM-009
region: REG-009
type: Main-Line Starter
evolution_chain:
  - stage_1: Sylphira (42/3/3/4)
  - stage_2: Floriva (58/4/4/5)
  - stage_3a: Bloomara (72/5/5/5) # Heal-Path
  - stage_3b: Thornyx (68/7/4/6) # Poison-Path
  - stage_4a: Floralis (88/6/7/6) # Ultimate Healer ☆☆
  - stage_4b: Venomthor (85/9/5/7) # Tödlichstes Gift ☆☆☆
personality:
  traits: ["sanft", "weise", "beschützend"]
  visual: "Kleiner Waldgeist, Moos und Blüten"
tcg_archetype: Heal/Poison
book_1_partner: Finn Alder (ab Kapitel 25)
first_appearance: Kapitel 2 (verletzt)
special_note: "Zeigt Bilder von Theo → Hauptplot-Trigger"
communication_pre_binding: "Gefühle und Bilder, KEINE Worte"
```

---

## CRE-004: TERRAGUS-LINIE (Erde)

```yaml
id: CRE-004
name: Terragus
element: ELM-003
region: REG-003
type: Main-Line Starter
evolution_chain:
  - stage_1: Terragus (50/4/4/2)
  - stage_2: Terramight (65/5/5/3)
  - stage_3a: Geodrax (80/7/5/3) # Quake-Path
  - stage_3b: Stoneguard (90/5/8/2) # Wall-Path
  - stage_4a: Terraforge (100/9/6/4) # AOE-Titan ☆☆
  - stage_4b: Titanrock (120/7/10/2) # Unzerstörbar ☆☆☆
personality:
  traits: ["stur", "loyal", "geduldig"]
  visual: "Steinwesen mit Moos-Haar"
tcg_archetype: Defense/Wall
book_1_partner: Elara Stoneheart
first_appearance: Kapitel 14
```

---

## CRE-005: AERIS-LINIE (Wind)

```yaml
id: CRE-005
name: Aeris
element: ELM-004
region: REG-004
type: Main-Line Starter
evolution_chain:
  - stage_1: Aeris (38/3/2/5)
  - stage_2: Zephyros (52/4/3/6)
  - stage_3a: Tempestus (65/6/3/8) # Storm-Path
  - stage_3b: Zephyrine (60/4/4/7) # Evasion-Path
  - stage_4a: Cyclonyx (80/8/4/10) # Multi-Hit God ☆☆☆
  - stage_4b: Mistral (75/5/5/9) # 60% Dodge ☆
personality:
  traits: ["frei", "neckisch", "schnell"]
  visual: "Kleiner Wind-Vogel, Kolibri-Energie"
tcg_archetype: Tempo/Evasion
book_1_partner: Widerstandsführer (Zephyros-Stufe)
```

---

## CRE-006: FROSTIX-LINIE (Eis)

```yaml
id: CRE-006
name: Frostix
element: ELM-006
region: REG-006
type: Main-Line Starter
evolution_chain:
  - stage_1: Frostix (44/3/3/4)
  - stage_2: Glaciron (58/4/5/4)
  - stage_3a: Frostbite (72/6/4/5) # Control-Path
  - stage_3b: Glacithor (82/5/7/3) # Wall-Path
  - stage_4a: Cryosthor (90/8/6/6) # Freeze unbreakable ☆☆☆
  - stage_4b: Cryonyx (100/6/9/4) # Feuer-immun ☆☆
personality:
  traits: ["still", "beobachtend", "kalt aber treu"]
  visual: "Kleines Eis-Wesen, kristallin"
tcg_archetype: Control/Lock
book_1_partner: Captain Harrow (Schmuggler)
```

---

## CRE-007: VOLTIS-LINIE (Blitz)

```yaml
id: CRE-007
name: Voltis
element: ELM-005
region: REG-005
type: Main-Line Starter
evolution_chain:
  - stage_1: Voltis (36/4/2/5)
  - stage_2: Voltrix (50/5/3/6)
  - stage_3a: Surgion (62/7/3/8) # Speed-Path
  - stage_3b: Voltaic (58/5/4/7) # Paralyze-Path
  - stage_4a: Stormclaw (75/9/4/10) # Multi-Hit Champion ☆☆☆☆
  - stage_4b: Thundron (80/8/5/9) # Paralyze unbreakable ☆☆☆☆
personality:
  traits: ["hyperaktiv", "unberechenbar", "loyal"]
  visual: "Kleines elektrisches Wesen"
tcg_archetype: Speed/Aggro
book_1_usage: System-Soldaten (Feinde)
```

---

## CRE-008: SHADOWSTRIKE-LINIE (Schatten)

```yaml
id: CRE-008
name: Shadowstrike
element: ELM-008
region: REG-008
type: Main-Line Starter
evolution_chain:
  - stage_1: Shadowstrike (40/4/2/4)
  - stage_2: Nox (54/5/3/5)
  - stage_3a: Shadowblade (68/8/3/6) # Assassin-Path
  - stage_3b: Voidmaw (75/6/5/4) # Tank-Path
  - stage_4a: Umbrael (82/10/4/7) # Instant-KO <60% HP ☆☆☆☆
  - stage_4b: Voidlord (95/7/7/5) # Life-Steal +25 HP ☆☆☆
personality:
  traits: ["formlos", "geheimnisvoll", "loyal wenn vertraut"]
  visual: "Schatten-Wesen, rote Augen (als Nox)"
tcg_archetype: Assassin/Stealth
book_1_usage: Nur erwähnt (Setup für später)
```

---

## CRE-009: LUMIX-LINIE (Licht)

```yaml
id: CRE-009
name: Lumix
element: ELM-007
region: REG-007
type: Main-Line Starter
evolution_chain:
  - stage_1: Lumix (42/3/3/4)
  - stage_2: Lucendi (56/4/4/5)
  - stage_3a: Radiara (70/5/5/5) # Heal-Path
  - stage_3b: Prismor (65/6/4/6) # Divine-Path
  - stage_4a: Solarius (85/6/7/6) # Rebind ☆☆
  - stage_4b: Radianthor (80/8/5/7) # Anti-Schatten ☆☆☆
personality:
  traits: ["freundlich", "heilend", "wahrheitssuchend"]
  visual: "Fee-artiges Licht-Wesen"
tcg_archetype: Support/Heal
book_1_usage: Akademie-Heiler im Climax
```

---

## CRE-010: IRONIX-LINIE (Metall)

```yaml
id: CRE-010
name: Ironix
element: ELM-010
region: REG-010
type: Main-Line Starter
evolution_chain:
  - stage_1: Ironix (48/4/4/2)
  - stage_2: Steelion (62/5/5/3)
  - stage_3a: Bladeclaw (76/7/5/4) # Offense-Path
  - stage_3b: Ironguard (88/5/8/2) # Defense-Path
  - stage_4a: Bladestorm (92/9/6/5) # Offense+Defense ☆☆☆
  - stage_4b: Titansteel (110/6/10/3) # Min 1 HP ☆☆
personality:
  traits: ["unbeugsam", "loyal", "mechanisch präzise"]
  visual: "Kleiner Metall-Golem"
tcg_archetype: Defense/Equipment
book_1_note: "Ferron (Calders Partner) ist Stufe 2+ Variante"
```

---

## CRE-022: DRAKYN-LINIE (Drache / Region Kosmos)

```yaml
id: CRE-022
name: Drakyn
element: ELM-011
region: REG-011
type: Main-Line Starter (RARE)
evolution_chain:
  - stage_1: Drakyn (46/4/3/4)
  - stage_2: Dracor (60/5/4/5)
  - stage_3a: Skydrax (75/7/4/6) # Sky-Path
  - stage_3b: Drakathor (80/6/6/5) # Ancient-Path
  - stage_4a: Dracathor (95/9/5/7) # Multi-Element ☆☆☆☆
  - stage_4b: Dracaethon (100/8/7/6) # 50% Damage-Reduction ☆☆☆
personality:
  traits: ["alle Elemente subtil", "mysteriös", "selten"]
  visual: "Baby-Drache, Regenbogen-Schimmer"
tcg_archetype: Multi-Element/Versatile
book_1_usage: Wird im Climax befreit (Kapitel 25)
rarity_note: "Extrem selten — keine regulären Partner"
canon_constraints:
  - "@LAW-008: Mysterium bewahren"
```

---

# TEIL 2: MINI-RESONANTEN (Nicht-Evolution)

---

## CRE-011: MOSSLING (Natur-Mini)

```yaml
id: CRE-011
name: Mossling
element: ELM-009
type: Mini-Resonant
evolves: false
stats: null # Nicht kampffähig
visual: "Winziger Moosklumpen mit Augen"
behavior: "Neugierig, folgt Menschen"
tcg_role: Draw-Support
book_1_location: Kapitel 1, überall in Sylvaris
```

---

## CRE-012: FLICKERLING (Feuer-Mini)

```yaml
id: CRE-012
name: Flickerling
element: ELM-001
type: Mini-Resonant
evolves: false
visual: "Tanzende kleine Flamme"
behavior: "Rastlos, flackert"
tcg_role: Burn-Enabler
book_1_location: Kapitel 8, Pyros-Atmosphäre
book_1_note: "Wird in Kapitel 5 gerettet (Moral-Bridge)"
```

---

## CRE-013: BUBLIN (Wasser-Mini)

```yaml
id: CRE-013
name: Bublin
element: ELM-002
type: Mini-Resonant
evolves: false
visual: "Schwebende Wasserblase"
behavior: "Verspielt, platzt bei Gefahr"
tcg_role: Heal-Support
book_1_location: Kapitel 5, Hafen-Atmosphäre
```

---

## CRE-014: PEBLIT (Erde-Mini)

```yaml
id: CRE-014
name: Peblit
element: ELM-003
type: Mini-Resonant
evolves: false
visual: "Rollender Kieselstein mit Gesicht"
behavior: "Stur, bleibt stehen"
tcg_role: DEF-Buff
book_1_location: Kapitel 13, Bergpfade
```

---

## CRE-015: BREEZEL (Wind-Mini)

```yaml
id: CRE-015
name: Breezel
element: ELM-004
type: Mini-Resonant
evolves: false
visual: "Unsichtbarer Windwirbel"
behavior: "Schnell, neckisch"
tcg_role: SPD-Buff
book_1_location: Kapitel 17, überall in Zephyria
```

---

## CRE-016: SHARDLING (Eis-Mini)

```yaml
id: CRE-016
name: Shardling
element: ELM-006
type: Mini-Resonant
evolves: false
visual: "Schwebender Eissplitter"
behavior: "Still, kalt"
tcg_role: Freeze-Support
```

---

## CRE-017: SPARKLIN (Blitz-Mini)

```yaml
id: CRE-017
name: Sparklin
element: ELM-005
type: Mini-Resonant
evolves: false
visual: "Knisternder Funkenball"
behavior: "Hyperaktiv, zappelig"
tcg_role: Paralyze-Support
```

---

## CRE-018: GLOOMLET (Schatten-Mini)

```yaml
id: CRE-018
name: Gloomlet
element: ELM-008
type: Mini-Resonant
evolves: false
visual: "Schatten, der sich bewegt"
behavior: "Scheu, versteckt sich"
tcg_role: Stealth-Enabler
book_1_location: Kapitel 15, Schatten in Tunneln
```

---

## CRE-019: GLIMMER (Licht-Mini)

```yaml
id: CRE-019
name: Glimmer
element: ELM-007
type: Mini-Resonant
evolves: false
visual: "Leuchtender Lichtpunkt"
behavior: "Freundlich, führt"
tcg_role: Search-Support
book_1_location: Kapitel 22, überall in Lumion
```

---

## CRE-020: COGLET (Metall-Mini)

```yaml
id: CRE-020
name: Coglet
element: ELM-010
type: Mini-Resonant
evolves: false
visual: "Winziges Zahnrad-Wesen"
behavior: "Mechanisch, tickt"
tcg_role: Relic-Support
```

---

## (Kein Mini-Drache)

```yaml
# Drachen sind immer selten
# Kein Mini-Resonant für ELM-011
# Dies verstärkt die Mystik
```

---

# TEIL 3: SPECIAL RESONANTEN

---

## VERDANTIS (Theos Partner)

```yaml
id: CRE-SPECIAL-001
name: Verdantis
element: ELM-009
type: Special (Stufe 3 Natur)
description: "Seltener Waldwächter"
partner: Theo Alder (Finns Bruder)
first_appearance: Kapitel 2 (in Sylphiras Vision)
reunion: Kapitel 19
```

---

## FERRON (Calders Partner)

```yaml
id: CRE-SPECIAL-002
name: Ferron
element: ELM-010
type: Special (Stufe 2+ Metall)
description: "Stahl-Koloss"
partner: Aufseher Calder
first_appearance: Kapitel 7 (erwähnt), Kapitel 12 (erscheint)
role: Antagonist-Partner
```

---

# REFERENZ-TABELLE

| ID | Name | Element | Type |
|----|------|---------|------|
| CRE-001 | Embrix | Feuer | Main |
| CRE-002 | Aquor | Wasser | Main |
| CRE-003 | Sylphira | Natur | Main |
| CRE-004 | Terragus | Erde | Main |
| CRE-005 | Aeris | Wind | Main |
| CRE-006 | Frostix | Eis | Main |
| CRE-007 | Voltis | Blitz | Main |
| CRE-008 | Shadowstrike | Schatten | Main |
| CRE-009 | Lumix | Licht | Main |
| CRE-010 | Ironix | Metall | Main |
| CRE-011 | Mossling | Natur | Mini |
| CRE-012 | Flickerling | Feuer | Mini |
| CRE-013 | Bublin | Wasser | Mini |
| CRE-014 | Peblit | Erde | Mini |
| CRE-015 | Breezel | Wind | Mini |
| CRE-016 | Shardling | Eis | Mini |
| CRE-017 | Sparklin | Blitz | Mini |
| CRE-018 | Gloomlet | Schatten | Mini |
| CRE-019 | Glimmer | Licht | Mini |
| CRE-020 | Coglet | Metall | Mini |
| CRE-022 | Drakyn | Drache | Main (Rare) |

---

*Letzte Änderung: 30. Dezember 2025*
