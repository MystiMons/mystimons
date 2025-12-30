# MYSTIMONS PROJEKT-STRUKTUR v3.1
## 3-Schichten-System für AAA-Transmedia-Franchise

**Erstellt:** 30. Dezember 2025
**Von:** Pascal Werner + Claude (Sammy)

---

# ÜBERSICHT

```
/MYSTIMONS/
│
├── 00_CANON/              ← SCHICHT 1: Unverrückbar
│   ├── PILLARS.md         (5 World Pillars)
│   ├── CANON_LAWS.md      (10 Canon Laws)
│   ├── SINGLE_SOURCE_OF_TRUTH.md (Prioritäten + Glossar)
│   ├── CONFLICT_ENGINE.md (Hingabe vs. Dominanz)
│   ├── BRAND_PROMISE.md   (Was MystiMons verspricht)
│   └── TONE_GUIDE.md      (Wie MystiMons klingt)
│
├── 01_REGISTRY/           ← SCHICHT 2: Entities mit IDs
│   ├── elements/          (ELM-###)
│   ├── regions/           (REG-###)
│   ├── factions/          (FAC-###)
│   ├── objects/           (OBJ-###)
│   ├── creatures/         (CRE-###)
│   ├── characters/        (CHR-###)
│   ├── keywords/          (KWD-###)
│   ├── INDEX.md           (Menschenlesbar)
│   └── INDEX.json         (Maschinenlesbar)
│
├── 02_NARRATIVE/          ← SCHICHT 3: Produkt-Specs
│   ├── book_01/           (Band 1 — Finn)
│   ├── book_02/           (Band 2 — Finn)
│   ├── book_03/           (Band 3 — Finn)
│   ├── book_04_kira/      (Band 4 — Kira übernimmt; Finns Tod als Übergabe-Event)
│   ├── book_05_kira/      (Band 5 — Kira)
│   ├── book_06_kira/      (Band 6 — Kira Finale der Hauptreihe)
│   ├── book_07_origin_aetherion/ (Band 7 — Origin/Prequel: Entstehung Aetherion; Release #7)
│   └── STORY_SEEDS.md     (Zukünftige Geschichten)
│
├── 03_TCG/
│   ├── sets/SET-001/      (TCG Set 1)
│   └── PRINT_VS_DIGITAL.md
│
├── 04_APP_TECH/           (App + Hardware Specs; inkl. Smart Mat)
│
├── 05_VISUAL_BRAND/       (Später)
│   └── LOGO/
│
├── 06_OPS_COMMUNITY/
│   ├── TRANSMEDIA_MATRIX.md
│   └── MEDIUM_GUIDES/
│
└── 99_DECISIONS/
    └── DECISION_LOG.md    (Alle Canon-Entscheidungen)
```

---

# DIE 3 SCHICHTEN

## Schicht 1: CANON (00_CANON/)

**Was:** Die unverrückbaren Regeln.

**Änderungen:** NUR via Review + Decision Log.

**Inhalt:**
- 5 World Pillars (@PIL-001 bis @PIL-005)
- 10 Canon Laws (@LAW-001 bis @LAW-010)
- Conflict Engine (Hingabe vs. Dominanz)
- Brand Promise & Tone Guide

---

## Schicht 2: REGISTRY (01_REGISTRY/)

**Was:** Alle Entities mit eindeutigen IDs.

**Zweck:** Referenzierbar, validierbar, konsistent.

**ID-Schema:**
| Prefix | Entity |
|--------|--------|
| ELM-### | Element |
| REG-### | Region |
| FAC-### | Faction |
| OBJ-### | Object |
| CRE-### | Creature |
| CHR-### | Character |
| KWD-### | Keyword |

**Nutzung:** In allen Dokumenten `@CRE-001` für Embrix, etc.

---

## Schicht 3: PRODUKT-SPECS (02-06)

**Was:** Konkrete Artefakte (Bücher, TCG, App).

**Referenziert:** Schicht 1 + 2.

**Beispiel:**
- Buch 1 Outline referenziert @CHR-001 (Finn)
- TCG Set 1 referenziert @CRE-001 bis @CRE-022
- App-Spec referenziert @OBJ-001 (Resonanzkern)

---

# REFERENZ-SYNTAX

In allen Dokumenten:

```
@CRE-001 → Embrix
@REG-007 → Lumion
@PIL-001 → Resonanz ist freiwillig
@LAW-005 → Absorption ist immer böse
```

---

# VALIDIERUNG

Mit dieser Struktur kann später automatisch geprüft werden:

1. **ID-Konflikte:** Gibt es doppelte IDs?
2. **Canon-Verstöße:** Widerspricht etwas @LAW-###?
3. **Referenz-Checks:** Existiert @CRE-025? (Nein!)
4. **Timeline-Konsistenz:** Passt alles zusammen?

---

# WAS NOCH FEHLT

- [ ] Buch 1 Outline in `/02_NARRATIVE/book_01/`
- [ ] TCG Regelwerk in `/03_TCG/`
- [ ] App MVP Scope in `/04_APP_TECH/`
- [ ] Visual Style Guide in `/05_VISUAL_BRAND/`

---

# NÄCHSTE SCHRITTE

1. Diese Struktur in Google Drive übernehmen
2. Existierende Dokumente migrieren
3. Buch 1 Outline erstellen
4. Kapitel schreiben

---

**PASCAL + CLAUDE (SAMMY)**
**KI-ONLY AAA TRANSMEDIA FRANCHISE**
**2025-2026**


## Story Arc (Books)
- Band 1–3: Finn
- Band 4–6: Kira (Finns Tod in Band 4 als Übergabe-Event)
- Band 7: Origin/Prequel — Entstehung von Aetherion (Release #7 nach Band 6)


## Smart Mat (v1)
- Baseline ist App-required. Active/Bench werden über die doppelseitige NFC-Matte erfasst.
- Spezifikation: `04_APP_TECH/SMART_MAT/SMART_MAT_SPEC_v0_2.md`

## TCG Roadmap & Smart Mat Backlog
- `03_TCG/sets/SET_ROADMAP.md` (SET-002…SET-007 scaffolds)
- `04_APP_TECH/SMART_MAT/BACKLOG_TICKETS.md`
- `04_APP_TECH/SMART_MAT/ACCEPTANCE_TESTS.md`


## TCG Authoring
- Canonical data formats and schemas: `03_TCG/AUTHORING/`.

PushEndpointTest: verify /git/push works

SmokeGateTest: verify smoke-test gate

TrimIOTest: verify stdout/stderr truncation
