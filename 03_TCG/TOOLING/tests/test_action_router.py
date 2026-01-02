import os
import sys
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import tracker  # noqa
import action_router as ar  # noqa


class ActionRouterTests(unittest.TestCase):
    def setUp(self):
        caps = ar.load_caps_for_format("starter")
        self.ctx = ar.ActionContext(state=tracker.TrackerState(), caps=caps)

    def test_cannot_attack_outside_battle(self):
        # start phase initially -> attack must fail
        with self.assertRaises(tracker.CapError):
            ar.do_attack(self.ctx, "Aquor (C)", "Splash")

        # move to main -> still fail
        ar.do_advance_phase(self.ctx)  # start->draw
        ar.do_advance_phase(self.ctx)  # draw->main
        with self.assertRaises(tracker.CapError):
            ar.do_attack(self.ctx, "Aquor (C)", "Splash")

        # move to battle -> now ok (but only once per turn)
        ar.do_advance_phase(self.ctx)  # main->battle
        ar.do_attack(self.ctx, "Aquor (C)", "Splash")

    def test_attack_cap_one_per_turn(self):
        ar.do_advance_phase(self.ctx)  # start->draw
        ar.do_advance_phase(self.ctx)  # draw->main
        ar.do_advance_phase(self.ctx)  # main->battle

        ar.do_attack(self.ctx, "Aquor (C)", "Splash")
        with self.assertRaises(tracker.CapError):
            ar.do_attack(self.ctx, "Aquor (C)", "Splash2")

    def test_once_per_turn_enforced(self):
        ar.do_advance_phase(self.ctx)  # start->draw
        ar.do_advance_phase(self.ctx)  # draw->main

        ar.do_use_once_per_turn(self.ctx, "CARD_X:ability", allowed_phases=["main"])
        with self.assertRaises(tracker.CapError):
            ar.do_use_once_per_turn(self.ctx, "CARD_X:ability", allowed_phases=["main"])

    def test_end_turn_resets_and_flips(self):
        # advance to main and do something
        ar.do_advance_phase(self.ctx)  # start->draw
        ar.do_advance_phase(self.ctx)  # draw->main
        ar.do_play_card(self.ctx, "Aquor (C)")
        ar.do_use_once_per_turn(self.ctx, "CARD_X:ability", allowed_phases=["main"])

        self.assertEqual(self.ctx.state.active_player, "P1")
        self.assertEqual(self.ctx.state.turn_number, 1)

        ar.do_end_turn(self.ctx, auto_run_to_end=True)

        self.assertEqual(self.ctx.state.active_player, "P2")
        self.assertEqual(self.ctx.state.turn_number, 2)
        self.assertEqual(self.ctx.state.phase, "start")
        self.assertEqual(self.ctx.state.per_turn.actions_used, 0)
        self.assertEqual(self.ctx.state.once_per_turn, {})


if __name__ == "__main__":
    unittest.main()
