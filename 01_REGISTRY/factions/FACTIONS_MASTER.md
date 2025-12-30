# FRAKTIONEN REGISTRY
## Die 4 Hauptfraktionen von Aetheria

**Version:** 1.0
**ID-Schema:** FAC-###

---

## FAC-001: DER RAT DER BALANCE

```yaml
id: FAC-001
name: Der Rat der Balance
type: Government/Antagonist
alignment: Lawful (corrupt)
emblem: Das Siegel der Balance (11 Segmente + Aetherion-Auge)
colors:
  primary: Gold
  secondary: Weiß
  accent: Schwarz
adjectives:
  - Mächtig
  - Kontrollierend
  - Korrupt
visual_language:
  - Symmetrie
  - Saubere Linien
  - Imposante Architektur
  - Uniformen, Hierarchie
headquarters: Lumion (@REG-007)
structure:
  - 11 Champions (einer pro Element)
  - Scouts/Soldaten
  - Bürokraten
conflict_engine: Dominanz (@CONFLICT-ENGINE)
known_members:
  - Flamrion (Feuer-Champion)
  - Calder (Aufseher, @CHR-TBD)
practices:
  - Absorption (stillschweigend erlaubt)
  - Zwangskontrolle von Resonanten
  - Unterdrückung der Vergessenen
```

---

## FAC-002: DIE VERGESSENEN

```yaml
id: FAC-002
name: Die Vergessenen
type: Resistance/Protagonist-aligned
alignment: Chaotic Good (mostly)
emblem: Zerbrochenes Siegel (durchgestrichenes Rats-Symbol)
colors:
  primary: Grau
  secondary: Rostrot
  accent: Dunkelblau
adjectives:
  - Rebellisch
  - Hoffnungsvoll
  - Verzweifelt
visual_language:
  - Asymmetrie
  - Geflickte Kleidung
  - Versteckte Orte
  - Individualität statt Uniformen
headquarters: Dezentral, versteckte Zellen
structure:
  - Lose Netzwerke
  - Regionale Anführer
  - Keine zentrale Macht
conflict_engine: Hingabe (@CONFLICT-ENGINE)
goals:
  - Befreiung von Resonanten
  - Sturz des korrupten Rats
  - Wahre Resonanz für alle
risks:
  - Können selbst zu Tyrannen werden (@PIL-005)
  - Interne Konflikte
  - Verzweiflung führt zu schlechten Entscheidungen
```

---

## FAC-003: DIE SCOUTS (Flamrions Jäger)

```yaml
id: FAC-003
name: Die Scouts (Flamrions Jäger)
type: Enforcement/Antagonist
alignment: Lawful Evil
emblem: Flammendes Auge
colors:
  primary: Schwarz
  secondary: Orange
  accent: Rot
adjectives:
  - Brutal
  - Effizient
  - Angsteinflößend
visual_language:
  - Scharfe Kanten
  - Narben, Brandmale
  - Militärisch, aber chaotisch
  - Waffen immer sichtbar
headquarters: Mobile, folgen Flamrion
structure:
  - Flamrion (Anführer)
  - Captains
  - Scouts (Fußsoldaten)
conflict_engine: Extreme Dominanz (@CONFLICT-ENGINE)
methods:
  - Jagd auf Ungebundene
  - Erzwungene Resonanz (die dann Dissonanz wird)
  - Einschüchterung
relationship_to_rat: Offiziell Teil des Systems, aber eigene Agenda
```

---

## FAC-004: DIE NEUTRALEN (Akademie, Zivilisten)

```yaml
id: FAC-004
name: Die Neutralen
type: Civilian/Mixed
alignment: True Neutral
emblem: Offener Kreis (unvollständig)
colors:
  primary: Blau
  secondary: Weiß
  accent: Grau
adjectives:
  - Gelehrt
  - Vorsichtig
  - Unentschlossen
visual_language:
  - Roben, Bücher
  - Offene Räume
  - Bibliotheken, Labore
  - Keine Waffen
headquarters: Die Akademie (Lumion, @REG-007)
includes:
  - Akademie-Lehrer
  - Studenten
  - Zivilisten aller Regionen
  - Händler, Handwerker
conflict_engine: Vermeidung, später Hingabe (@CONFLICT-ENGINE)
internal_conflict:
  - Manche unterstützen heimlich die Vergessenen
  - Manche sind loyal zum Rat
  - Die meisten wollen einfach überleben
```

---

## FRAKTIONS-BEZIEHUNGEN

```
           FAC-001 (RAT)
               ↑
       kontrolliert/bekämpft
               ↓
    FAC-002 (VERGESSENE)
               ↑
    unterstützt heimlich einige
               ↓
    FAC-004 (NEUTRALE)
               ↑
       werden rekrutiert
               ↓
    FAC-003 (SCOUTS)
               ↑
       dienen/fürchten
               ↓
           FAC-001 (RAT)
```

---

## EMBLEM-VARIATIONEN

### Siegel der Balance (@FAC-001)
- **Intakt:** 11 Segmente, zentrales Auge, gold leuchtend
- **Korrumpiert:** Risse, dunkle Flecken, blutrotes Auge

### Zerbrochenes Siegel (@FAC-002)
- **Standard:** Durchgestrichenes Rats-Symbol
- **Varianten:** Regionale Anpassungen, handgemalt

### Flammendes Auge (@FAC-003)
- **Standard:** Brennendes Auge in Flammenkreis
- **Brandmal:** Auf Mitglieder gebrannt

### Offener Kreis (@FAC-004)
- **Standard:** Unvollständiger Kreis (Neutralität)
- **Akademie:** Mit Buch-Symbol

---

*Letzte Änderung: 30. Dezember 2025*
