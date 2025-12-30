# SIGNATURE OBJECTS REGISTRY
## Die 3 ikonischen Objekte von MystiMons

**Version:** 1.0
**ID-Schema:** OBJ-###

---

## OBJ-001: DER RESONANZKERN

```yaml
id: OBJ-001
name: Der Resonanzkern
type: Bonding Artifact
rarity: Unique per Bonded Pair
visual:
  size: Handflächengroß
  glow: Leuchtet in Farbe des Elements
  pulse: Pulsiert wie Herzschlag
  form: Einzigartige Form pro Person
function:
  - Ermöglicht Kommunikation mit dem Resonanten
  - Zeigt Stärke der Bindung (heller = stärker)
  - Zerbricht, wenn die Bindung stirbt
lore:
  - Manifestiert sich bei erfolgreicher Resonanz
  - Kann nicht künstlich hergestellt werden
  - Jeder Kern ist einzigartig wie ein Fingerabdruck
canon_constraints:
  - "@PIL-001: Kann nicht erzwungen werden"
  - "@LAW-004: Resonant muss zustimmen"
merch_potential:
  - Schmuck (Anhänger, Ringe)
  - Leuchtende Repliken
  - Sammelbare Varianten pro Element
tcg_relevance:
  - Card: "Resonanzkern-Aktivierung"
  - Mechanic: Bond-Marker
```

---

## OBJ-002: DIE AETHER-KARTE

```yaml
id: OBJ-002
name: Die Aether-Karte
type: Storage/Knowledge Artifact
rarity: Common to Legendary
visual:
  size: Kreditkartenformat
  design: Goldene Aether-Linien
  element: Element-Symbol als Wasserzeichen
in_lore_meaning:
  - Alte Artefakte, die Resonanten "speichern" können
  - Hüter nutzen sie, um Wissen zu teilen
  - Jede Karte enthält Essenz einer Begegnung
function_in_world:
  - Dokumentation von Resonanten
  - Training-Tool für junge Hüter
  - Sammlerstücke für Forscher
function_in_tcg:
  - Die physischen Spielkarten selbst
  - Bridge zwischen Realität und Lore
canon_constraints:
  - Speichern ≠ Gefangenhalten
  - Können Erinnerungen/Wissen bewahren
  - Keine Resonanz-Erzwingung
merch_potential:
  - Das TCG selbst
  - Premium-Versionen (Metall, holografisch)
  - "Ancient Cards" Sammelreihe
tcg_relevance:
  - Jede Karte ist eine Aether-Karte
  - Flavor Text = Lore-Delivery
```

---

## OBJ-003: DAS SIEGEL DER BALANCE

```yaml
id: OBJ-003
name: Das Siegel der Balance
type: Authority/Symbol
rarity: Unique (offiziell), Common (Repliken)
visual:
  shape: Kreisförmig
  segments: 11 (eines pro Element)
  center: Aetherion-Auge
  variants:
    - Intakt (offiziell)
    - Korrumpiert (geheim)
    - Zerbrochen (Vergessene)
function:
  - Offizielles Siegel des Rates
  - Auf Dokumenten, Gebäuden, Uniformen
  - Autorität und Legitimation
symbolic_meaning:
  - Balance der 11 Elemente
  - Einheit unter dem Rat
  - (Ironisch: System ist unbalanciert)
rebel_use:
  - Durchgestrichen = Widerstand
  - Verändert = Autonomie
  - Zerbrochen = Hoffnung auf Neuanfang
canon_constraints:
  - "@FAC-001: Offizielles Symbol"
  - "@FAC-002: Widerstandssymbol wenn verändert"
merch_potential:
  - Pins, Patches
  - Kleidung
  - Flaggen, Poster
  - "Choose your side" Marketing
tcg_relevance:
  - Card: "Siegel der Autorität"
  - Stadium Card: "Ratshalle"
```

---

## OBJEKT-BEZIEHUNGEN

```
OBJ-001 (Resonanzkern)
    ↓ ermöglicht
Bindung zwischen Mensch & Resonant
    ↓ wird dokumentiert auf
OBJ-002 (Aether-Karte)
    ↓ wird reguliert durch
OBJ-003 (Siegel der Balance)
```

---

## WEITERE OBJEKTE (Minor)

Diese sind weniger ikonisch, aber relevant:

```yaml
- id: OBJ-004
  name: Hüter-Handschuh
  function: Verstärkt Resonanz-Kommunikation
  
- id: OBJ-005
  name: Aether-Kompass
  function: Zeigt Richtung zu Resonanten
  
- id: OBJ-006
  name: Bindungs-Ring
  function: Zeigt Bindungsstatus (aktiv/ruhend)
```

---

*Letzte Änderung: 30. Dezember 2025*
