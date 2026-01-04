from backend.app.core.name_numbers import (
    calculate_physical_name_number,
    calculate_soul_number,
    calculate_personality_number
)

def test_physical_name_number():
    assert calculate_physical_name_number("JOHN") == 2
    # J(1)+O(6)+H(8)+N(5) = 20 → 2

def test_soul_number():
    assert calculate_soul_number("JOHN") == 6  # O only

def test_personality_number():
    assert calculate_personality_number("JOHN") == 5
    # J(1)+H(8)+N(5) = 14 → 5
