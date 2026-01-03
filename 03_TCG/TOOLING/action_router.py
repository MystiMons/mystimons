#!/usr/bin/env python3
# MystiMons TCG Tooling v0.5.x — Action Router (phase + caps + OTP in one place)

from __future__ import annotations

import json
import os
from dataclasses import dataclass, field
from typing import Any, Dict, List, Optional

# tracker.py must be in the same folder
import tracker


@dataclass
class ActionEvent:
    type: str
    payload: Dict[str, Any] = field(default_factory=dict)

    def to_dict(self) -> Dict[str, Any]:
        return {"type": self.type, "payload": self.payload}


@dataclass
class ActionContext:
    """
    Centralized runtime context:
      - tracker state
      - caps for the chosen format
      - event log (optional)
    """
    state: tracker.TrackerState
    caps: Dict[str, Any]
    events: List[ActionEvent] = field(default_factory=list)

    def emit(self, type_: str, **payload: Any) -> None:
        self.events.append(ActionEvent(type_, payload))


def load_caps_for_format(fmt: str, caps_path: Optional[str] = None) -> Dict[str, Any]:
    caps_all = tracker.load_caps(caps_path or tracker.DEFAULT_CAPS_PATH)
    if fmt not in caps_all["formats"]:
        raise ValueError(f"Unknown format '{fmt}'. Available: {list(caps_all['formats'].keys())}")
    return caps_all["formats"][fmt]


# -------------------------
# ROUTED ACTIONS (v0.5.x)
# -------------------------

def do_play_card(ctx: ActionContext, card_name: str, *, source: str = "hand") -> None:
    # Most plays happen in main.
    tracker.ensure_phase(ctx.state, ["main"])
    tracker.apply_action(ctx.state, ctx.caps, "action")
    ctx.emit("PLAY_CARD", card=card_name, source=source)


def do_attach_energy(ctx: ActionContext, target: str, *, consume_action: bool = True) -> None:
    tracker.ensure_phase(ctx.state, ["main"])
    if consume_action:
        tracker.apply_action(ctx.state, ctx.caps, "action")
    tracker.apply_action(ctx.state, ctx.caps, "energy_attach")
    ctx.emit("ATTACH_ENERGY", target=target, consume_action=consume_action)


def do_switch(ctx: ActionContext, new_active: str) -> None:
    # Allow switch in main or battle (pre-attack), depending on your rules.
    tracker.ensure_phase(ctx.state, ["main", "battle"])
    tracker.apply_action(ctx.state, ctx.caps, "switch")
    ctx.emit("SWITCH", new_active=new_active)


def do_attack(ctx: ActionContext, attacker: str, move: str) -> None:
    tracker.ensure_phase(ctx.state, ["battle"])
    tracker.apply_action(ctx.state, ctx.caps, "attack")
    ctx.emit("ATTACK", attacker=attacker, move=move)


def do_draw_from_effect(ctx: ActionContext, n: int, *, reason: str = "effect") -> None:
    # Draw caps are tracked per card drawn-from-effect
    if n < 0:
        raise ValueError("n must be >= 0")
    # Usually allowed in draw/main; loosen if needed.
    tracker.ensure_phase(ctx.state, ["draw", "main", "battle"])
    for _ in range(n):
        tracker.apply_action(ctx.state, ctx.caps, "draw_effect")
    ctx.emit("DRAW_EFFECT", n=n, reason=reason)


def do_start_resonance(ctx: ActionContext, huter: str, resonant: str, *, consume_action: bool = True) -> None:
    # Resonance start should feel voluntary; this is only the mechanical routing.
    tracker.ensure_phase(ctx.state, ["main"])
    if consume_action:
        tracker.apply_action(ctx.state, ctx.caps, "action")
    tracker.apply_action(ctx.state, ctx.caps, "resonance_start")
    ctx.emit("START_RESONANCE", huter=huter, resonant=resonant, consume_action=consume_action)


def do_use_once_per_turn(ctx: ActionContext, key: str, *, allowed_phases: Optional[List[str]] = None, consume_action: bool = False) -> None:
    if allowed_phases is None:
        allowed_phases = ["main"]
    tracker.ensure_phase(ctx.state, allowed_phases)
    tracker.otp_use(ctx.state, key)
    if consume_action:
        tracker.apply_action(ctx.state, ctx.caps, "action")
    ctx.emit("ONCE_PER_TURN", key=key, allowed_phases=allowed_phases, consume_action=consume_action)


def do_advance_phase(ctx: ActionContext, *, end_starts_new_turn: bool = False) -> str:
    old = ctx.state.phase
    new = tracker.advance_phase(ctx.state, end_starts_new_turn=end_starts_new_turn)
    ctx.emit("ADVANCE_PHASE", old=old, new=new, end_starts_new_turn=end_starts_new_turn)
    return new


def do_end_turn(ctx: ActionContext, *, auto_run_to_end: bool = True) -> None:
    """
    Convenience:
      - If auto_run_to_end=True: advances phases until 'end', then starts next turn.
      - If False: requires you already to be at 'end', then starts next turn.
    """
    if auto_run_to_end:
        while ctx.state.phase != "end":
            do_advance_phase(ctx)
        do_advance_phase(ctx, end_starts_new_turn=True)
        return

    tracker.ensure_phase(ctx.state, ["end"])
    do_advance_phase(ctx, end_starts_new_turn=True)


# -------------------------
# DEMO
# -------------------------

def demo():
    caps = load_caps_for_format("starter")
    ctx = ActionContext(state=tracker.TrackerState(), caps=caps)

    print("STATE:", json.dumps(ctx.state.to_dict(), indent=2, ensure_ascii=False))

    # start -> draw -> main
    do_advance_phase(ctx)  # start->draw
    do_advance_phase(ctx)  # draw->main

    do_play_card(ctx, "Aquor (C)")
    do_attach_energy(ctx, "Aquor (C)", consume_action=False)  # example: free attach + capped attach
    do_use_once_per_turn(ctx, "CARD_ABC:ping", allowed_phases=["main"], consume_action=False)

    # main -> battle -> end -> next turn
    do_advance_phase(ctx)  # main->battle
    do_attack(ctx, "Aquor (C)", "Splash")
    do_end_turn(ctx, auto_run_to_end=True)

    print("EVENTS:")
    for e in ctx.events:
        print(" -", e.to_dict())

    print("FINAL:", json.dumps(ctx.state.to_dict(), indent=2, ensure_ascii=False))


if __name__ == "__main__":
    import argparse

    ap = argparse.ArgumentParser()
    ap.add_argument("cmd", nargs="?", default="demo", choices=["demo"])
    args = ap.parse_args()
    if args.cmd == "demo":
        demo()
