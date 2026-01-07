# CRITICAL: This logic is extracted from Excel V9.18 and is regression-tested.
# Life Cycles and Turning Points must NOT be modified without updating tests.
# Deviations from Excel parity will be caught by test_life_cycles_regression().

# CRITICAL: Life Cycles and Turning Points logic extracted from Excel V9.18.
# Do NOT replace with standard numerology formulas (month+day, etc.).
# Must remain Excel-faithful: sum → reduce → add → reduce pattern only.

from .reduction import reduce_to_single_digit, excel_reduce

def generate_blessed_years(current_year: int, cycles: int = 20) -> list[int]:
    return [current_year + 6 * n for n in range(cycles)]

def calculate_blessed_days(day_of_birth: int) -> list[int]:
    target = reduce_to_single_digit(day_of_birth)
    return [d for d in range(1, 32) if reduce_to_single_digit(d) == target]

def determine_life_cycle_phase(age: int) -> str:
    if age <= 30:
        return "Formative / Development"
    elif age <= 45:
        return "Establishment"
    elif age <= 63:
        return "Fruit / Manifestation"
    else:
        return "Legacy Phase"

def get_life_turning_points() -> list[int]:
    return [36, 45, 54, 63]

def calculate_life_cycles(matrix: list[int], extra_1: int, extra_2: int) -> list[int]:
    """Calculate Life Cycles using Excel-faithful logic.
    
    Pattern: sum → reduce → add → reduce
    
    Life Cycle 1 (Formative, age 0-30):
      Q1 = sum(matrix)
      R1 = excel_reduce(Q1)
      X1 = excel_reduce(extra_1)
      Y1 = R1 + X1
      LC1 = excel_reduce(Y1)
    
    Life Cycle 2 (Establishment, age 30-55):
      Q2 = sum(matrix)
      R2 = excel_reduce(Q2)
      X2 = excel_reduce(extra_2)
      Y2 = R2 + X2
      LC2 = excel_reduce(Y2)
    
    Life Cycle 3 (Fruit/Manifestation, age 55+):
      LC3 = excel_reduce(LC1 + LC2)
    
    Args:
        matrix: name_matrix_values (per-letter reduced values)
        extra_1: soul_number
        extra_2: personality_number
    
    Returns:
        [LifeCycle1, LifeCycle2, LifeCycle3]
    """
    # Life Cycle 1 (Formative)
    Q1 = sum(matrix)
    R1 = excel_reduce(Q1)
    X1 = excel_reduce(extra_1)
    Y1 = R1 + X1
    LC1 = excel_reduce(Y1)
    
    # Life Cycle 2 (Establishment)
    Q2 = sum(matrix)
    R2 = excel_reduce(Q2)
    X2 = excel_reduce(extra_2)
    Y2 = R2 + X2
    LC2 = excel_reduce(Y2)
    
    # Life Cycle 3 (Fruit/Manifestation)
    LC3 = excel_reduce(LC1 + LC2)
    
    # Invariant: Life Cycles must be valid single digits (0-9)
    assert 0 <= LC1 <= 9, f"LC1 out of range: {LC1}"
    assert 0 <= LC2 <= 9, f"LC2 out of range: {LC2}"
    assert 0 <= LC3 <= 9, f"LC3 out of range: {LC3}"
    
    return [LC1, LC2, LC3]

def calculate_turning_points(life_cycles: list[int]) -> list[int]:
    """Calculate Turning Points from Life Cycles using Excel-faithful logic.
    
    TP1 = excel_reduce(LC1)
    TP2 = excel_reduce(LC2 + LC1)
    TP3 = excel_reduce(LC3 + LC2)
    TP4 = excel_reduce(LC1 + LC2 + LC3)
    
    Args:
        life_cycles: [LC1, LC2, LC3]
    
    Returns:
        [TP1, TP2, TP3, TP4]
    """
    LC1, LC2, LC3 = life_cycles
    
    TP1 = excel_reduce(LC1)
    TP2 = excel_reduce(LC2 + LC1)
    TP3 = excel_reduce(LC3 + LC2)
    TP4 = excel_reduce(LC1 + LC2 + LC3)
    
    # Invariant: Turning Points must be valid single digits (0-9)
    assert 0 <= TP1 <= 9, f"TP1 out of range: {TP1}"
    assert 0 <= TP2 <= 9, f"TP2 out of range: {TP2}"
    assert 0 <= TP3 <= 9, f"TP3 out of range: {TP3}"
    assert 0 <= TP4 <= 9, f"TP4 out of range: {TP4}"
    
    return [TP1, TP2, TP3, TP4]
