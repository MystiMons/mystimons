# ELEMENTE REGISTRY
## Die 11 Elemente von Aetheria

**Version:** 1.0
**ID-Schema:** ELM-###

---

## ELM-001: FEUER (Pyros)

```yaml
id: ELM-001
name_de: Feuer
name_en: Fire
region: REG-001
color_primary: "#FF4500"
color_secondary: "#FFD700"
traits:
  - Leidenschaft
  - Impulsivität
  - Zerstörung/Erneuerung
strengths:
  - Offensive Power
  - Burn Effects
weaknesses:
  - Wasser (@ELM-002)
  - Geringe Ausdauer
tcg_archetype: Aggro
```

---

## ELM-002: WASSER (Aquarion)

```yaml
id: ELM-002
name_de: Wasser
name_en: Water
region: REG-002
color_primary: "#1E90FF"
color_secondary: "#00CED1"
traits:
  - Anpassungsfähigkeit
  - Beständigkeit
  - Tiefe
strengths:
  - Heal Effects
  - Flow/Combo
weaknesses:
  - Blitz (@ELM-005)
  - Langsamer Start
tcg_archetype: Control/Midrange
```

---

## ELM-003: ERDE (Terravok)

```yaml
id: ELM-003
name_de: Erde
name_en: Earth
region: REG-003
color_primary: "#8B4513"
color_secondary: "#DEB887"
traits:
  - Stabilität
  - Ausdauer
  - Sturheit
strengths:
  - Defense/Tank
  - HP-Pool
weaknesses:
  - Wind (@ELM-004)
  - Mobilität
tcg_archetype: Defense/Wall
```

---

## ELM-004: WIND (Zephyria)

```yaml
id: ELM-004
name_de: Wind
name_en: Wind
region: REG-004
color_primary: "#87CEEB"
color_secondary: "#E0FFFF"
traits:
  - Freiheit
  - Schnelligkeit
  - Unbeständigkeit
strengths:
  - Speed
  - Evasion
weaknesses:
  - Eis (@ELM-006)
  - Geringe HP
tcg_archetype: Tempo/Evasion
```

---

## ELM-005: BLITZ (Fulguris)

```yaml
id: ELM-005
name_de: Blitz
name_en: Lightning
region: REG-005
color_primary: "#FFD700"
color_secondary: "#FFFACD"
traits:
  - Energie
  - Geschwindigkeit
  - Unberechenbarkeit
strengths:
  - Speed
  - Paralyze
weaknesses:
  - Erde (@ELM-003)
  - Erschöpfung
tcg_archetype: Speed/Aggro
```

---

## ELM-006: EIS (Crystara)

```yaml
id: ELM-006
name_de: Eis
name_en: Ice
region: REG-006
color_primary: "#ADD8E6"
color_secondary: "#F0FFFF"
traits:
  - Stille
  - Bewahrung
  - Isolation
strengths:
  - Freeze/Control
  - Preservation
weaknesses:
  - Feuer (@ELM-001)
  - Spröde
tcg_archetype: Control/Lock
```

---

## ELM-007: LICHT (Lumion)

```yaml
id: ELM-007
name_de: Licht
name_en: Light
region: REG-007
color_primary: "#FFFAF0"
color_secondary: "#FFE4B5"
traits:
  - Wahrheit
  - Heilung
  - Offenbarung
strengths:
  - Heal
  - Anti-Schatten
weaknesses:
  - Schatten (@ELM-008) (gegenseitig)
  - Keine Stealth
tcg_archetype: Support/Heal
note: "Licht ist NICHT automatisch 'gut' (@PIL-002)"
```

---

## ELM-008: SCHATTEN (Umbra'Noct)

```yaml
id: ELM-008
name_de: Schatten
name_en: Shadow
region: REG-008
color_primary: "#2F4F4F"
color_secondary: "#696969"
traits:
  - Geheimnisse
  - Täuschung
  - Verborgenheit
strengths:
  - Stealth
  - Life-Steal
  - Assassination
weaknesses:
  - Licht (@ELM-007) (gegenseitig)
  - Isolation
tcg_archetype: Assassin/Stealth
note: "Schatten ist NICHT automatisch 'böse' (@PIL-002)"
```

---

## ELM-009: NATUR (Sylvaris)

```yaml
id: ELM-009
name_de: Natur
name_en: Nature
region: REG-009
color_primary: "#228B22"
color_secondary: "#90EE90"
traits:
  - Wachstum
  - Kreislauf
  - Verbundenheit
strengths:
  - Heal over Time
  - Poison
  - Growth
weaknesses:
  - Feuer (@ELM-001)
  - Langsam zu starten
tcg_archetype: Ramp/Growth
```

---

## ELM-010: METALL (Ferros)

```yaml
id: ELM-010
name_de: Metall
name_en: Metal
region: REG-010
color_primary: "#708090"
color_secondary: "#C0C0C0"
traits:
  - Struktur
  - Industrie
  - Unbeugsamkeit
strengths:
  - Defense
  - Equipment Synergy
weaknesses:
  - Blitz (@ELM-005)
  - Unflexibel
tcg_archetype: Defense/Equipment
```

---

## ELM-011: DRACHE (Drakonis)

```yaml
id: ELM-011
name_de: Drache
name_en: Dragon
region: REG-011
color_primary: "#4B0082"
color_secondary: "#9400D3"
traits:
  - Mysterium
  - Alle Elemente
  - Seltenheit
strengths:
  - Versatility
  - Raw Power
weaknesses:
  - Keine spezifischen (aber selten!)
tcg_archetype: Multi-Element
status: "Versteckt, mysteriös, unbekannt"
note: "Region gesperrt — was dort ist, weiß niemand (@LAW-008)"
```

---

## ELEMENT-BEZIEHUNGEN

```
Feuer → stark gegen → Natur, Eis
Wasser → stark gegen → Feuer
Erde → stark gegen → Blitz
Wind → stark gegen → Erde
Blitz → stark gegen → Wasser, Metall
Eis → stark gegen → Wind, Natur
Licht ↔ Schatten (gegenseitig effektiv)
Natur → stark gegen → Wasser, Erde
Metall → stark gegen → Eis
Drache → neutral gegen alle (aber selten)
```

---

*Letzte Änderung: 30. Dezember 2025*
