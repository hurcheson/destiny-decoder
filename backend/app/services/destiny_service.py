from datetime import date
from ..core.life_seal import calculate_life_seal
from ..core.name_numbers import (
    calculate_physical_name_number,
    calculate_soul_number,
    calculate_personality_number
)
from ..core.personal_year import calculate_personal_year
from ..core.cycles import (
    generate_blessed_years,
    calculate_blessed_days,
    determine_life_cycle_phase,
    get_life_turning_points
)
from ..core.compatibility import evaluate_compatibility


def calculate_destiny(payload: dict) -> dict:
    day = payload["day_of_birth"]
    month = payload["month_of_birth"]
    year = payload["year_of_birth"]
    first_name = payload["first_name"]
    other_names = payload.get("other_names", "")
    full_name_input = payload.get("full_name")
    partner_name = payload.get("partner_name")

    # Normalize name components deterministically
    # Support both input patterns: (first_name + other_names) OR full_name
    if full_name_input:
        # If full_name provided, derive other_names from it
        full_name = full_name_input.strip()
        # Extract other_names: everything after first_name
        name_parts = full_name.split(None, 1)  # Split on first whitespace
        if len(name_parts) > 1:
            other_names = name_parts[1]
        else:
            other_names = ""
    else:
        # Construct full_name from first_name + other_names
        other_names = other_names or ""
        full_name = " ".join([first_name, other_names]).strip()

    # Handle current_year: if None or missing, use current year
    current_year = payload.get("current_year") or date.today().year

    # Compute age safely
    today = date.today()
    age = today.year - year - (
        (today.month, today.day) < (month, day)
    )

    life_seal_data = calculate_life_seal(day, month, year)

    result = {
        "life_seal": life_seal_data["number"],
        "life_planet": life_seal_data["planet"],
        "physical_name_number": calculate_physical_name_number(full_name),
        "soul_number": calculate_soul_number(full_name),
        "personality_number": calculate_personality_number(full_name),
        "personal_year": calculate_personal_year(day, month, current_year),
        "blessed_years": generate_blessed_years(current_year),
        "blessed_days": calculate_blessed_days(day),
        "life_cycle_phase": determine_life_cycle_phase(age),
        "life_turning_points": get_life_turning_points(),
    }

    if partner_name:
        sex_number_1 = calculate_physical_name_number(first_name)
        sex_number_2 = calculate_physical_name_number(partner_name)
        result["compatibility"] = evaluate_compatibility(
            sex_number_1, sex_number_2
        )

    return result
