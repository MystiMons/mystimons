# PRINT VS DIGITAL KONVENTION
## TCG-Regeln für physische und digitale Versionen

**Version:** 1.0
**Status:** Design Guideline
**Referenz:** 3_MODI_SYSTEM

---

# GRUNDPRINZIP

```
EINE IP, DREI ERFAHRUNGEN:
- Physisch + App (Baseline, immer)
- Full AR (optional, später)

ABER: Der CORE ist identisch.
```

---

# CARD SCHEMA

Jede Karte hat zwei Textblöcke:

## 1. PRINT TEXT (Physisch)

```yaml
print_text: |
  Beschreibung, die ohne zusätzlichen Scan-Overhead funktioniert.
  Muss klar, eindeutig, rules-compliant sein.
  Keine versteckten Effekte.
  
print_tracking: null # Keine Mechaniken, die Tracking brauchen
```

**Regel (aktualisiert):** Das Spiel ist **App-required**. Der Print-Text muss **klar und knapp** sein, aber die App ist **Rules-Engine** (Timing, Locks, Counters, Modusregeln, AR).

---

## 2. DIGITAL LOGIC (App-Enhanced / Full AR)

```yaml
digital_logic:
  base_effect: "Identisch zu print_text"
  enhanced_effects:
    - tracking: true # App trackt Zustände
    - animation: true # Visuelles Feedback
    - history: true # Spielverlauf einsehbar
  
patches_allowed: true # Balance-Fixes möglich
rng_allowed: false # Keine echten Zufallseffekte
```

**Regel:** Digital darf MEHR können, aber nie ANDERS als Print.

---

# MECHANIK-KATEGORIEN

## PRINT-SAFE (✅ Immer erlaubt)

| Mechanik | Beispiel |
|----------|----------|
| Stat-Buffs | "+2 ATK bis Ende des Zuges" |
| Einfache Konditionen | "Wenn HP < 50%..." |
| Klare Kosten | "Zahle 2 Energie" |
| Definierte Targets | "Wähle einen Verbündeten" |

---

## HYBRID (⚠️ Print möglich, Digital besser)

| Mechanik | Print-Lösung | Digital-Vorteil |
|----------|--------------|-----------------|
| Tracking über Züge | Marker/Würfel | Auto-Tracking |
| Komplexe Bedingungen | Referenzkarte | Live-Anzeige |
| Versteckte Info | Face-down | App kennt's |

---

## DIGITAL-ONLY (❌ Nicht für Print)

| Mechanik | Warum nicht Print |
|----------|-------------------|
| Echter Zufall | RNG unfair ohne Kontrolle |
| Dynamische Stats | Zu viel Tracking |
| Echtzeit-Effekte | Nicht messbar |
| Meta-Game-Bezug | Braucht Server |

**Regel:** Digital-Only-Mechaniken dürfen in physischen Spielen NIE erscheinen.

---

# CARD TEMPLATE

```yaml
# BEISPIEL: Resonanzkern-Impuls
id: CARD-SET-001-023
name: "Resonanzkern-Impuls"
type: "Spell"
rarity: "Uncommon"

# PRINT VERSION
cost_print: 2
print_text: "Gib einem Verbündeten +2 ATK bis Ende des Zuges."
print_tracking: null

# DIGITAL VERSION
digital_logic:
  base_effect: "+2 ATK bis Ende des Zuges"
  tracking: ["per_turn_buff"]
  animation: "Goldenes Leuchten"
  patches_allowed: true
  rng_allowed: false

# LORE
links:
  object: OBJ-001 # Resonanzkern
  laws: [LAW-009] # Kein Pay-to-Win

flavor_text: "Die Verbindung verstärkt sich, wenn man sie braucht."
```

---

# BALANCE-REGELN

## Für Print:

```
1. Keine Karte ist automatisch stärker weil seltener (@LAW-009)
2. Jedes Element hat gleich starke Options (@PIL-002)
3. Skill > Wallet
```

## Für Digital (zusätzlich):

```
4. Patches dürfen Balance fixen, aber NIE Print invalidieren
5. Enhanced Effects sind BONUS, nicht ERSATZ
6. Premium-Cosmetics okay, Premium-Power nie
```

---

# VALIDIERUNGS-CHECKLISTE

Bevor eine Karte finalisiert wird:

- [ ] Funktioniert Print-Text ohne zusätzlichen Scan-Overhead?
- [ ] Ist Print-Text eindeutig?
- [ ] Widerspricht Digital-Logic dem Print-Text?
- [ ] Braucht Print-Version Tracking, das unfair ist?
- [ ] Verstößt irgendwas gegen @LAW-009?
- [ ] Ist das Element-Balance gewahrt?

---

# MODUS-ÜBERSICHT

| Modus | Karten | App | Features |
|-------|--------|-----|----------|
| **Physisch** | ✅ | ❌ | Core Rules only |
| **App-Enhanced** | ✅ | ✅ | Tracking, Animationen |
| **Full AR** | ❌ | ✅ | Alles digital, keine physischen Karten nötig |

---

*Letzte Änderung: 30. Dezember 2025*
*Quelle: MYSTIMONS_3_MODI_SYSTEM_OFFICIAL*
