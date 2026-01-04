from .reduction import reduce_to_single_digit

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
