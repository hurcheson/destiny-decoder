from backend.app.core.life_seal import calculate_life_seal

def test_life_seal_basic():
    result = calculate_life_seal(day=9, month=4, year=1998)

    assert result["number"] == 4
    assert result["planet"] == "URANUS"

