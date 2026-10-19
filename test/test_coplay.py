import json
import pytest
from app.models import CoupleProfile, GameCategory
from app.room_manager import RoomManager

# Testing the protocol and state machine logic
def test_protocol_dual_submission_and_reveal():
    manager = RoomManager()
    profile = CoupleProfile(
        couple_id="c-flutter-1",
        partner_a_id="mobile_a",
        partner_a_name="Aarav",
        partner_b_id="mobile_b",
        partner_b_name="Diya",
        preferred_category=GameCategory.THIS_OR_THAT
    )

    session = manager.create_session(profile)
    joined = manager.join_by_code(session.room_code, "mobile_b", "Diya")
    assert joined is not None

    # Step 1: Partner A submits -> waiting for partner
    ok1, reveal1 = manager.submit_answer(session.session_id, "mobile_a", 0, "Midnight Maggi")
    assert ok1 is True
    assert reveal1 is None

    # Step 2: Partner B submits -> simultaneous reveal
    ok2, reveal2 = manager.submit_answer(session.session_id, "mobile_b", 0, "Midnight Maggi")
    assert ok2 is True
    assert reveal2 is not None
    assert reveal2.is_match is True
    assert reveal2.compatibility_score == 100
    print("Dual reveal verified successfully!")

if __name__ == "__main__":
    test_protocol_dual_submission_and_reveal()
