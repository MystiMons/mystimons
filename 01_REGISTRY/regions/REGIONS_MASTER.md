# REGIONEN REGISTRY
## Die 11 Regionen von Aetheria

**Version:** 1.0
**ID-Schema:** REG-###

---

## REG-001: PYROS (Feuer)

```yaml
id: REG-001
name: Pyros
element: ELM-001
terrain: Vulkane, Lavaströme, heiße Quellen
climate: Extrem heiß, trocken
culture:
  adjectives: ["leidenschaftlich", "impulsiv", "ehrlich"]
  government: Stammesräte, Stärkster führt
  economy: Schmiedekunst, Obsidian, Energie
key_locations:
  - Feuerschmieden
  - Vulkanhöhlen
  - Thermalstädte
resonants_common:
  - CRE-001 (Embrix-Linie)
  - CRE-012 (Flickerling)
book_1_chapters: [8, 9, 10, 11, 12]
```

---

## REG-002: AQUARION (Wasser)

```yaml
id: REG-002
name: Aquarion
element: ELM-002
terrain: Ozeane, Küsten, fließende Städte
climate: Feucht, gemäßigt, wechselhaft
culture:
  adjectives: ["anpassungsfähig", "handelsorientiert", "fließend"]
  government: Handelsgilden, Hafenmeister
  economy: Fischerei, Handel, Schifffahrt
key_locations:
  - Schwimmende Märkte
  - Hafen von Tidesmeet
  - Unterwasserhöhlen
resonants_common:
  - CRE-002 (Aquor-Linie)
  - CRE-013 (Bublin)
book_1_chapters: [5, 6, 7]
```

---

## REG-003: TERRAVOK (Erde)

```yaml
id: REG-003
name: Terravok
element: ELM-003
terrain: Berge, Höhlen, Steinwüsten
climate: Stabil, kühl in Höhen, warm in Tälern
culture:
  adjectives: ["stur", "beständig", "loyal"]
  government: Ältestenräte, Tradition
  economy: Bergbau, Steinmetzerei, Kristalle
key_locations:
  - Tiefe Tunnel
  - Kristallhöhlen
  - Bergfestungen
resonants_common:
  - CRE-004 (Terragus-Linie)
  - CRE-015 (Peblit)
book_1_chapters: [13, 14, 15, 16]
```

---

## REG-004: ZEPHYRIA (Wind)

```yaml
id: REG-004
name: Zephyria
element: ELM-004
terrain: Hochebenen, schwebende Dörfer, Klippen
climate: Windig, frisch, wechselhaft
culture:
  adjectives: ["frei", "nomadisch", "ungebunden"]
  government: Keine zentrale Macht, Nomadenstämme
  economy: Lufthandel, Botendienste, Vogelzucht
key_locations:
  - Schwebende Inseln
  - Windtempel
  - Klippensiedlungen
resonants_common:
  - CRE-005 (Aeris-Linie)
  - CRE-016 (Breezel)
book_1_chapters: [17, 18, 19, 20, 21]
```

---

## REG-005: FULGURIS (Blitz)

```yaml
id: REG-005
name: Fulguris
element: ELM-005
terrain: Gewitterebenen, Energietürme, Blitzfelder
climate: Stürmisch, elektrisch geladen
culture:
  adjectives: ["schnell", "innovativ", "rastlos"]
  government: Technokratie, Ingenieur-Gilden
  economy: Energie, Technologie, Kommunikation
key_locations:
  - Blitzfänger-Türme
  - Sturmzitadelle
  - Energiekraftwerke
resonants_common:
  - CRE-007 (Voltis-Linie)
  - CRE-018 (Sparklin)
book_1_chapters: [] # Nicht in Buch 1
```

---

## REG-006: CRYSTARA (Eis)

```yaml
id: REG-006
name: Crystara
element: ELM-006
terrain: Gletscher, Eiswüsten, Kristallhöhlen
climate: Extrem kalt, still, konservierend
culture:
  adjectives: ["bewahrend", "ruhig", "isoliert"]
  government: Hüter der Erinnerung, Älteste
  economy: Kristalle, Konservierung, Archivierung
key_locations:
  - Gefrorene Bibliotheken
  - Kristallpaläste
  - Eisbrücken
resonants_common:
  - CRE-006 (Frostix-Linie)
  - CRE-017 (Shardling)
book_1_chapters: [] # Erwähnt via Captain Harrow
```

---

## REG-007: LUMION (Licht)

```yaml
id: REG-007
name: Lumion
element: ELM-007
terrain: Strahlende Ebenen, Kristallstädte, Akademie
climate: Hell, warm, "perfekt"
culture:
  adjectives: ["ordentlich", "hierarchisch", "trügerisch"]
  government: Der Rat der Balance (11 Champions)
  economy: Ausbildung, Administration, Macht
key_locations:
  - Die Akademie
  - Ratshalle
  - Lichtturm
status: "Zentrum der Macht — korrupt unter der Oberfläche"
resonants_common:
  - CRE-009 (Lumix-Linie)
  - CRE-020 (Glimmer)
book_1_chapters: [22, 23, 24, 25, 26, 27, 28]
```

---

## REG-008: UMBRA'NOCT (Schatten)

```yaml
id: REG-008
name: Umbra'Noct
element: ELM-008
terrain: Ewige Dämmerung, Schattenwälder, verborgene Städte
climate: Dunkel, kühl, geheimnisvoll
culture:
  adjectives: ["misstrauisch", "geheimnisvoll", "überlebend"]
  government: Schattenfürsten, dezentral
  economy: Information, Spionage, verbotene Güter
key_locations:
  - Versteckte Siedlungen
  - Schattenmärkte
  - Verlorene Tempel
resonants_common:
  - CRE-008 (Shadowstrike-Linie)
  - CRE-019 (Gloomlet)
book_1_chapters: [] # Setup für später
```

---

## REG-009: SYLVARIS (Natur)

```yaml
id: REG-009
name: Sylvaris
element: ELM-009
terrain: Urwälder, Blumenwiesen, lebende Städte
climate: Feucht, grün, lebendig
culture:
  adjectives: ["naturverbunden", "zyklisch", "heilend"]
  government: Waldräte, Hüter des Zyklus
  economy: Heilkräuter, Holz, Nahrung
key_locations:
  - Grünhafen (Finns Heimatdorf)
  - Großer Baum
  - Heilende Quellen
resonants_common:
  - CRE-003 (Sylphira-Linie)
  - CRE-011 (Mossling)
  - Verdantis (Theos Partner)
book_1_chapters: [1, 2, 3, 4]
protagonist_origin: true
```

---

## REG-010: FERROS (Metall)

```yaml
id: REG-010
name: Ferros
element: ELM-010
terrain: Industriestädte, Minen, Fabriken
climate: Rauchig, warm, künstlich
culture:
  adjectives: ["strukturiert", "fleißig", "praktisch"]
  government: Fabrikherren, Gilden
  economy: Metallverarbeitung, Waffen, Werkzeuge
key_locations:
  - Große Schmieden
  - Minenstädte
  - Eisenbahnen
resonants_common:
  - CRE-010 (Ironix-Linie)
  - CRE-021 (Coglet)
book_1_chapters: [] # Nicht in Buch 1
```

---

## REG-011: KOSMOS (Sperrregion)

```yaml
id: REG-011
name: "Kosmos"
element: ELM-011
terrain: Unbekannt
climate: Unbekannt
culture:
  adjectives: ["mysteriös", "verboten", "vergessen"]
  government: Unbekannt
  economy: Unbekannt
status: "GESPERRT — Betreten verboten"
key_locations:
  - Unbekannt
resonants_common:
  - CRE-022 (Drakyn-Linie) — extrem selten
book_1_chapters: [] # Erwähnt als Mysterium
note: "Keine vollständige Enthüllung vor Band 5+ (@LAW-008)"
```

---

## REGIONEN-KARTE (Konzept)

```
              [REG-004 ZEPHYRIA]
                    ↑ Hochland
                    |
[REG-006]←——[REG-007 LUMION]——→[REG-001]
CRYSTARA         (Zentrum)         PYROS
   ↑                |                ↑
   |                ↓                |
[REG-002]←——[REG-009 SYLVARIS]——→[REG-003]
AQUARION         (Süden)         TERRAVOK
                    |
              [REG-008 UMBRA'NOCT]
                 (Verborgen)

[REG-005 FULGURIS] — im Osten
[REG-010 FERROS] — im Nordwesten
[REG-011 KOSMOS] — Lage unbekannt
```

---

*Letzte Änderung: 30. Dezember 2025*
