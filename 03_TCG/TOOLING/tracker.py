#!/usr/bin/env python3
# MystiMons TCG Tooling v0.5.1 — Tracker Reset + Cap checks (hotfix: dataclass defaults)

from __future__ import annotations

import json
import os
from dataclasses import dataclass, asdict, field
from typing import Dict, Any, Optional, List


# --- Phase Flow (v0.5.x) ---
PHASES = ["start", "draw", "main", "battle", "end"]
NEXT_PHASE = {PHASES[i]: PHASES[i + 1] for i in range(len(PHASES) - 1)}


DEFAULT_CAPS_PATH = os.path.join(os.path.dirname(__file__), "caps.defaults.json")


@dataclass
class PerTurn:
    actions_used: int = 0
    attacks_used: int = 0
    switches_used: int = 0
    energy_attached: int = 0
    cards_drawn_from_effects: int = 0
    resonances_started: int = 0


@dataclass
class TrackerState:
    version: str = "0.5"
    turn_number: int = 1
    active_player: str = "P1"
    phase: str = "start"
    per_turn: PerTurn = field(default_factory=PerTurn)
    once_per_turn: Dict[str, bool] = field(default_factory=dict)  # card/entity id -> used this turn?

    def to_dict(self) -> Dict[str, Any]:
        d = asdict(self)
        d["per_turn"] = asdict(self.per_turn)
        return d

    @staticmethod
    def from_dict(d: Dict[str, Any]) -> "TrackerState":
        pt = d.get("per_turn", {})
        return TrackerState(
            version=d.get("version", "0.5"),
            turn_number=int(d.get("turn_number", 1)),
            active_player=d.get("active_player", "P1"),
            phase=d.get("phase", "start"),
            per_turn=PerTurn(
                actions_used=int(pt.get("actions_used", 0)),
                attacks_used=int(pt.get("attacks_used", 0)),
                switches_used=int(pt.get("switches_used", 0)),
                energy_attached=int(pt.get("energy_attached", 0)),
                cards_drawn_from_effects=int(pt.get("cards_drawn_from_effects", 0)),
                resonances_started=int(pt.get("resonances_started", 0)),
            ),
            once_per_turn=dict(d.get("once_per_turn", {})),
        )


def load_caps(caps_path: str = DEFAULT_CAPS_PATH) -> Dict[str, Any]:
    with open(caps_path, "r", encoding="utf-8") as f:
        text = f.read()
    text = text.lstrip("\ufeff")  # BOM-safe
    if not text.strip():
        raise RuntimeError(f"Caps file is empty: {caps_path}")
    return json.loads(text)


def reset_turn(state: TrackerState, next_player: Optional[str] = None) -> TrackerState:
    """
    Advances to the next turn:
    - increments turn_number
    - resets per-turn counters
    - clears once-per-turn flags
    - flips active_player automatically if next_player is not provided
    """
    # advance turn counter (Model A: each player's turn increments)
    state.turn_number += 1

    # auto flip player unless explicitly set
    if next_player is None:
        state.active_player = "P2" if state.active_player == "P1" else "P1"
    else:
        state.active_player = next_player

    # per-turn resets
    state.per_turn = PerTurn()
    state.once_per_turn = {}
    state.phase = "start"
    return state




class CapError(RuntimeError):
    pass

def ensure_phase_valid(state: TrackerState) -> None:
    if state.phase not in PHASES:
        raise CapError(f"Invalid phase '{state.phase}'. Allowed: {PHASES}")

def set_phase(state: TrackerState, phase: str) -> None:
    if phase not in PHASES:
        raise CapError(f"Invalid phase '{phase}'. Allowed: {PHASES}")
    state.phase = phase

def ensure_phase(state: TrackerState, allowed: List[str]) -> None:
    """
    Guard for rules/engine calls:
      ensure_phase(state, ["main"])  # e.g. only allow plays in main
    """
    ensure_phase_valid(state)
    if state.phase not in allowed:
        raise CapError(f"Action not allowed in phase '{state.phase}'. Allowed phases: {allowed}")

def advance_phase(state: TrackerState, *, end_starts_new_turn: bool = False) -> str:
    """
    Advances phase strictly along:
      start -> draw -> main -> battle -> end
    If end_starts_new_turn=True and current phase is 'end', it will:
      - reset_turn(state)  (auto-flip + turn++)
      - keep phase at 'start'
    Returns the new phase.
    """
    ensure_phase_valid(state)

    if state.phase == "end":
        if end_starts_new_turn:
            reset_turn(state)  # uses your auto-flip + turn++ implementation
            return state.phase
        raise CapError("Cannot advance phase past 'end' (use end_starts_new_turn=True to start next turn).")

    state.phase = NEXT_PHASE[state.phase]
    return state.phase



def _cap_check(current: int, cap: int, label: str) -> None:
    if current > cap:
        raise CapError(f"Cap exceeded: {label} {current}/{cap}")


def apply_action(state: TrackerState, caps: Dict[str, Any], action: str) -> None:
    tc = caps["turn_caps"]

    if action == "action":
        state.per_turn.actions_used += 1
        _cap_check(state.per_turn.actions_used, tc["max_actions"], "actions_used")

    elif action == "attack":
        state.per_turn.attacks_used += 1
        _cap_check(state.per_turn.attacks_used, tc["max_attacks"], "attacks_used")

    elif action == "switch":
        state.per_turn.switches_used += 1
        _cap_check(state.per_turn.switches_used, tc["max_switches"], "switches_used")

    elif action == "energy_attach":
        state.per_turn.energy_attached += 1
        _cap_check(state.per_turn.energy_attached, tc["max_energy_attach"], "energy_attached")

    elif action == "draw_effect":
        state.per_turn.cards_drawn_from_effects += 1
        _cap_check(
            state.per_turn.cards_drawn_from_effects,
            tc["max_cards_drawn_from_effects"],
            "cards_drawn_from_effects",
        )

    elif action == "resonance_start":
        state.per_turn.resonances_started += 1
        _cap_check(state.per_turn.resonances_started, tc["max_resonances_started"], "resonances_started")

    else:
        raise ValueError(f"Unknown action: {action}")


def otp_use(state: TrackerState, key: str) -> None:
    if state.once_per_turn.get(key, False):
        raise CapError(f"Once-per-turn already used: {key}")
    state.once_per_turn[key] = True


def demo():
    caps_all = load_caps()
    caps = caps_all["formats"]["starter"]

    s = TrackerState()
    print("START:", json.dumps(s.to_dict(), indent=2, ensure_ascii=False))

    apply_action(s, caps, "action")
    apply_action(s, caps, "attack")
    otp_use(s, "CARD_ABC:ping")

    print("MID:", json.dumps(s.to_dict(), indent=2, ensure_ascii=False))

    reset_turn(s)
    print("RESET:", json.dumps(s.to_dict(), indent=2, ensure_ascii=False))
    print("PHASE:", s.phase)
    advance_phase(s)  # start->draw
    print("PHASE:", s.phase)
    advance_phase(s)  # draw->main
    print("PHASE:", s.phase)
    advance_phase(s)  # main->battle
    print("PHASE:", s.phase)
    advance_phase(s)  # battle->end
    print("PHASE:", s.phase)

    # end -> next turn (auto flip)
    advance_phase(s, end_starts_new_turn=True)
    print("NEXT TURN:", json.dumps(s.to_dict(), indent=2, ensure_ascii=False))



if __name__ == "__main__":
    import argparse

    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", nargs="?", default="demo", choices=["demo"])
    args = ap.parse_args()
    if args.cmd == "demo":
        demo()
