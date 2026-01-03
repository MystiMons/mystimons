import os
import sys
import unittest

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
sys.path.insert(0, ROOT)

import tracker  # noqa
import deck_validator  # noqa


class ToolingTests(unittest.TestCase):
    def test_tracker_reset_autoflip_and_turn_increment(self):
        caps_all = tracker.load_caps()
        caps = caps_all["formats"]["starter"]

        s = tracker.TrackerState()
        self.assertEqual(s.active_player, "P1")
        self.assertEqual(s.turn_number, 1)

        tracker.apply_action(s, caps, "action")
        tracker.otp_use(s, "X")
        tracker.reset_turn(s)  # auto flip
        self.assertEqual(s.active_player, "P2")
        self.assertEqual(s.turn_number, 2)
        self.assertEqual(s.per_turn.actions_used, 0)
        self.assertEqual(s.once_per_turn, {})

    def test_deck_validator_example_ok(self):
        caps_path = os.path.join(ROOT, "caps.defaults.json")
        caps_all = deck_validator.load_caps(caps_path)
        deck_path = os.path.abspath(os.path.join(ROOT, "..", "DECKS", "_examples", "example_starter.txt"))
        deck = deck_validator.read_deck(deck_path)
        issues = deck_validator.validate_deck(deck, "starter", caps_all, deny_deprecated=False)
        self.assertTrue(all(i.level != "ERROR" for i in issues))


if __name__ == "__main__":
    unittest.main()
