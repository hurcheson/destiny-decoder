from backend.app.core.cycles import calculate_life_cycles, calculate_turning_points
from backend.app.core.name_numbers import get_name_matrix_values, calculate_soul_number, calculate_personality_number
from backend.app.services.destiny_service import calculate_destiny

def test_life_cycles_regression():
    """Regression test locking Excel V9.18 parity for Life Cycles and Turning Points.
    
    Uses same input as test_name_numbers: "JOHN"
    This ensures Life Cycles calculations remain Excel-faithful.
    """
    name = "JOHN"
    
    # Extract components (same as in destiny_service.py)
    matrix = get_name_matrix_values(name)
    extra_1 = calculate_soul_number(name)  # 6
    extra_2 = calculate_personality_number(name)  # 5
    
    # Calculate Life Cycles
    life_cycles = calculate_life_cycles(matrix, extra_1, extra_2)
    
    # Calculate Turning Points
    turning_points = calculate_turning_points(life_cycles)
    
    # Golden values locked from Excel V9.18
    # J(1) O(6) H(8) N(5) → matrix = [1, 6, 8, 5]
    # sum(matrix) = 20 → excel_reduce(20) = ((20-1) % 9) + 1 = 2
    # LC1 = excel_reduce(2 + 6) = excel_reduce(8) = 8
    # LC2 = excel_reduce(2 + 5) = excel_reduce(7) = 7
    # LC3 = excel_reduce(8 + 7) = excel_reduce(15) = 6
    assert life_cycles == [8, 7, 6], f"Life Cycles mismatch: {life_cycles}"
    
    # TP1 = excel_reduce(8) = 8
    # TP2 = excel_reduce(7 + 8) = excel_reduce(15) = 6
    # TP3 = excel_reduce(6 + 7) = excel_reduce(13) = 4
    # TP4 = excel_reduce(8 + 7 + 6) = excel_reduce(21) = 3
    assert turning_points == [8, 6, 4, 3], f"Turning Points mismatch: {turning_points}"

def test_life_cycles_invariants():
    """Ensure Life Cycles and Turning Points always produce valid single digits."""
    name = "JOHN"
    
    matrix = get_name_matrix_values(name)
    extra_1 = calculate_soul_number(name)
    extra_2 = calculate_personality_number(name)
    
    life_cycles = calculate_life_cycles(matrix, extra_1, extra_2)
    turning_points = calculate_turning_points(life_cycles)
    
    # All values must be 0-9
    for lc in life_cycles:
        assert 0 <= lc <= 9
    
    for tp in turning_points:
        assert 0 <= tp <= 9

def test_destiny_with_life_cycles_full():
    """End-to-end regression test: full destiny calculation with life cycles and turning points.
    
    Golden input: John, born April 9, 1998 (used in test_life_seal.py).
    This test locks the entire numerology output to ensure no drift.
    """
    payload = {
        "first_name": "John",
        "day_of_birth": 9,
        "month_of_birth": 4,
        "year_of_birth": 1998,
        "current_year": 2024,
    }
    
    result = calculate_destiny(payload)
    
    # Lock core numerology values (these must never change)
    assert result["life_seal"] == 4, f"life_seal mismatch: {result['life_seal']}"
    assert result["physical_name_number"] == 2, f"physical_name_number mismatch: {result['physical_name_number']}"
    assert result["soul_number"] == 6, f"soul_number mismatch: {result['soul_number']}"
    assert result["personality_number"] == 5, f"personality_number mismatch: {result['personality_number']}"
    
    # Lock Life Cycles and Turning Points
    assert len(result["life_cycles"]) == 3, f"life_cycles length mismatch: {len(result['life_cycles'])}"
    assert len(result["turning_points"]) == 4, f"turning_points length mismatch: {len(result['turning_points'])}"
    
    # Verify Life Cycles structure and values
    for idx, lc in enumerate(result["life_cycles"]):
        assert "number" in lc, f"life_cycles[{idx}] missing 'number'"
        assert "interpretation" in lc, f"life_cycles[{idx}] missing 'interpretation'"
        assert "age_range" in lc, f"life_cycles[{idx}] missing 'age_range'"
        assert 0 <= lc["number"] <= 9, f"life_cycles[{idx}]['number'] out of range: {lc['number']}"
    
    # Verify Turning Points structure and values
    expected_tp_ages = [36, 45, 54, 63]
    for idx, tp in enumerate(result["turning_points"]):
        assert "number" in tp, f"turning_points[{idx}] missing 'number'"
        assert "interpretation" in tp, f"turning_points[{idx}] missing 'interpretation'"
        assert "age" in tp, f"turning_points[{idx}] missing 'age'"
        assert 0 <= tp["number"] <= 9, f"turning_points[{idx}]['number'] out of range: {tp['number']}"
        assert tp["age"] == expected_tp_ages[idx], f"turning_points[{idx}]['age'] mismatch: {tp['age']}"
    
    # Lock expected Life Cycles values (from name "John")
    # J(1) O(6) H(8) N(5) → matrix [1,6,8,5], sum=20, reduce=2
    # LC1 = reduce(2 + 6) = 8, LC2 = reduce(2 + 5) = 7, LC3 = reduce(8+7) = 6
    assert result["life_cycles"][0]["number"] == 8, f"LC1 mismatch: {result['life_cycles'][0]['number']}"
    assert result["life_cycles"][1]["number"] == 7, f"LC2 mismatch: {result['life_cycles'][1]['number']}"
    assert result["life_cycles"][2]["number"] == 6, f"LC3 mismatch: {result['life_cycles'][2]['number']}"
    
    # Lock expected Turning Points values
    # TP1 = reduce(8) = 8, TP2 = reduce(7+8) = 6, TP3 = reduce(6+7) = 4, TP4 = reduce(8+7+6) = 3
    assert result["turning_points"][0]["number"] == 8, f"TP1 mismatch: {result['turning_points'][0]['number']}"
    assert result["turning_points"][1]["number"] == 6, f"TP2 mismatch: {result['turning_points'][1]['number']}"
    assert result["turning_points"][2]["number"] == 4, f"TP3 mismatch: {result['turning_points'][2]['number']}"
    assert result["turning_points"][3]["number"] == 3, f"TP4 mismatch: {result['turning_points'][3]['number']}"
    
    # Verify age ranges are Excel-faithful
    assert result["life_cycles"][0]["age_range"] == "0–30"
    assert result["life_cycles"][1]["age_range"] == "30–55"
    assert result["life_cycles"][2]["age_range"] == "55+"
    
    for tp in turning_points:
        assert 0 <= tp <= 9
