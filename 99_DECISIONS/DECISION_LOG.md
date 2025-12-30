# DECISION LOG
## Alle Canon-relevanten Entscheidungen
## Story Arc

- **DEC-ARC-001 (2025-12-30):** Finn ist Protagonist in **Band 1–3**.
- **DEC-ARC-002 (2025-12-30):** Finn **stirbt in Band 4** (permanent). **Kira übernimmt** als Protagonistin ab Band 4.
- **DEC-SPOIL-001 (2025-12-30):** **Spoiler-Gate-Policy:** TCG/App dürfen Finns Tod nicht vor dem Book-4-Release-Fenster explizit offenlegen.

**Version:** 1.0
**Regel:** Änderungen an CANON erfordern Eintrag hier + Review

---

# LOG-FORMAT

```
## [DATUM] - [TITEL]

**Entscheidung:** Was wurde entschieden?
**Grund:** Warum?
**Betroffene IDs:** @XXX-###
**Genehmigt von:** Pascal
**Status:** FINAL / OFFEN
```

---

# ENTSCHEIDUNGEN

---

## 2025-12-25 - Option C gewählt

**Entscheidung:** Buch 1 (Hauptgeschichte) zuerst, dann Kiras Buch

**Grund:** 
- Kiras Geschichte zu dunkel als Einstieg
- Franchise braucht zugänglichen Köder
- Kiras Buch wird besser wenn Welt etabliert

**Betroffene IDs:** Alle @CHR-###, @REG-###

**Genehmigt von:** Pascal

**Status:** FINAL

---

## 2025-12-25 - 22 Starter statt 71

**Entscheidung:** Nur 22 Kreaturen für Start (11 Linien + 11 Minis)

**Grund:**
- Qualität über Quantität
- Merkbarkeit für Leser/Spieler
- "Die Originalen" werden ikonisch

**Betroffene IDs:** @CRE-001 bis @CRE-022

**Genehmigt von:** Pascal

**Status:** FINAL

---

## 2025-12-25 - Finn als Protagonist

**Entscheidung:** Finn Alder (14) als Buch 1 Protagonist

**Grund:**
- Jünger, hoffnungsvoller als Kira
- Reise-Struktur zeigt Welt
- "Das Hören" als unique ability

**Betroffene IDs:** @CHR-001

**Genehmigt von:** Pascal

**Status:** FINAL

---

## 2025-12-25 - 11 Elemente (nicht 10, nicht 12)

**Entscheidung:** 11 Elemente mit Kosmos/Drache als 11.

**Grund:**
- Ungerade Zahl für visuelles Design
- Kosmos bleibt Mysterium (@LAW-008)
- 11 Regionen = 11 Champions

**Betroffene IDs:** @ELM-001 bis @ELM-011, @REG-001 bis @REG-011

**Genehmigt von:** Pascal

**Status:** FINAL

---

## 2025-12-30 - Strukturumbau zu 3-Schichten-System

**Entscheidung:** Neue Ordnerstruktur mit CANON / REGISTRY / PRODUKT-SPECS

**Grund:**
- Maschinenvalidierbar
- Canon-Drift vermeiden
- Saubere Referenzierung mit IDs

**Betroffene IDs:** Alle (neue ID-Konvention eingeführt)

**Genehmigt von:** Pascal

**Status:** FINAL

---

# OFFENE ENTSCHEIDUNGEN

---

## OFFEN - Widerstandsführer Name

**Frage:** Wie heißt @CHR-009?

**Optionen:** TBD

**Status:** OFFEN

---

## OFFEN - Finns Mutter Name

**Frage:** Ist "Mira Alder" final für @CHR-010?

**Optionen:** TBD

**Status:** OFFEN

---

# WIDERSPRUCH-FIXES

Wenn Canon-Widersprüche entdeckt werden (@LAW-010):

```
## [DATUM] - WIDERSPRUCH FIX: [TITEL]

**Widerspruch:** Was widerspricht sich?
**Quellen:** Dokument A vs Dokument B
**Lösung:** Was ist jetzt Canon?
**Betroffene IDs:** @XXX-###
**Status:** GEFIXT
```

---

*Letzte Änderung: 30. Dezember 2025*


## 2025-12-30 — Element 11: Drache vs. Kosmos
- **Entscheidung:** Für Buch 1 + SET-001 ist **Drache** das 11. Element (ELM-011) gemäß Naming Bible v5.0 und 22-Starter.
- **Kosmos** bleibt als **REG-011** (Sperrregion / Myth-Layer) bestehen und kann später als eigenes Element- oder Subsystem ausgebaut werden.
- **Auswirkung:** Registry, Index und Region-Header wurden angepasst; ältere Formulierungen "Kosmos/Drache" gelten als deprecated.


## 2025-12-30 — Bindung & Terminologie: Kapitel 24 / "Rebind" vs. Resurrection
- **Entscheidung:** Finns **Bindung / „Das Hören“** ist in der aktuellen Buch-1-Struktur **Kapitel 24** (nicht 25).
- **Terminologie:** Im TCG wird „KO“ als **Erschöpfung/Rückzug** gelesen (kein Lore-Tod). Entsprechend wird der TCG-Effect als **Rebind** (statt „Resurrect“) geführt, um @LAW-Canon („Tote Resonanten bleiben tot“) nicht zu verletzen.
- **Auswirkung:** Starter-22, Index, Codex-Referenz und Naming-Bible wurden angepasst.

---

## Hardware / Hybrid UX

**DEC-HW-001 (2025-12-30):** Baseline ist **App-required**. Die App ist Rules-Engine; kein „ohne App“-Modus.
**Grund:** USP Hybrid/AR, konsistente Durchsetzung von Timing/Tracking.
**Betroffene IDs:** (global)
**Genehmigt von:** Pascal
**Status:** FINAL

**DEC-HW-002 (2025-12-30):** v1 Smart Mat ist **doppelseitig** (2 Spieler) mit **3 NFC-Zonen pro Seite** (Active + 2 Bench).
**Grund:** Reduziert Scan-Friction, erhält TCG-Table-Feel, minimiert Hardware-Scope.
**Betroffene IDs:** (global)
**Genehmigt von:** Pascal
**Status:** FINAL

**DEC-HW-003 (2025-12-30):** v1 Smart Mat hat **visuelles Feedback (LED)** pro Zone + Window-Locks (Clash = locked).
**Grund:** Verständlichkeit, Anti-Exploit, weniger App-Blick.
**Betroffene IDs:** (global)
**Genehmigt von:** Pascal
**Status:** FINAL

**DEC-HW-004 (2025-12-30):** Smart Mat Connectivity v1: **Single-Host BLE** (ein Gerät verbindet sich zur Matte; zweites Gerät joint die Session logisch).
**Grund:** Robustheit, weniger Support-/Pairing-Komplexität, turnierfreundlich.
**Betroffene IDs:** (global)
**Genehmigt von:** Pascal
**Status:** FINAL


## Story Arc / Bücher

**DEC-ARC-001 (2025-12-30):** Finn ist Protagonist in **Band 1–3**.
**Status:** FINAL

**DEC-ARC-002 (2025-12-30):** In **Band 4** stirbt Finn (permanent). **Kira übernimmt** als Protagonistin.
**Status:** FINAL

**DEC-ARC-003 (2025-12-30):** Hauptreihe umfasst **Band 1–6** (Finn 1–3, Kira 4–6). **Band 7** ist **Origin/Prequel** (Entstehung von Aetherion) und erscheint als **Release #7 nach Band 6**.
**Status:** FINAL

**DEC-ARC-004 (2025-12-30):** Origin-Fakten zu Aetherion sind bis Band 7/SET-007 **spoiler-gated** (vorher nur Myth/Fragment).
**Status:** FINAL
