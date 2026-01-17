from datetime import date
from ..core.life_seal import calculate_life_seal
from ..core.name_numbers import (
    calculate_physical_name_number,
    calculate_soul_number,
    calculate_personality_number,
    get_name_matrix_values
)
from ..core.personal_year import calculate_personal_year
from ..core.cycles import (
    generate_blessed_years,
    calculate_blessed_days,
    determine_life_cycle_phase,
    get_life_turning_points,
    calculate_life_cycles,
    calculate_turning_points
)
from ..core.pinnacles import calculate_pinnacles
from ..core.compatibility import evaluate_compatibility
from ..interpretations.cycle_interpretations import get_cycle_interpretation
from .narrative_service import build_narrative
from .report_service import build_report


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

    # Calculate name-based numbers
    physical_name_number = calculate_physical_name_number(full_name)
    soul_number = calculate_soul_number(full_name)
    personality_number = calculate_personality_number(full_name)
    
    # Extract name matrix values (per-letter reduced values)
    name_matrix_values = get_name_matrix_values(full_name)
    
    # Calculate Life Cycles using Excel-faithful logic
    # matrix = name_matrix_values, extra_1 = soul_number, extra_2 = personality_number
    life_cycles = calculate_life_cycles(name_matrix_values, soul_number, personality_number)
    
    # Calculate Turning Points from Life Cycles
    turning_points = calculate_turning_points(life_cycles)
    
    # Excel-faithful age ranges for Life Cycles
    life_cycle_age_ranges = ["0–30", "30–55", "55+"]
    
    # Build Life Cycles with interpretations and age ranges
    life_cycles_with_interpretations = [
        {
            "number": num,
            "interpretation": get_cycle_interpretation(num),
            "age_range": life_cycle_age_ranges[idx]
        }
        for idx, num in enumerate(life_cycles)
    ]
    
    # Excel-faithful ages for Turning Points
    turning_point_ages = [36, 45, 54, 63]
    
    # Build Turning Points with interpretations and ages
    turning_points_with_interpretations = [
        {
            "number": num,
            "interpretation": get_cycle_interpretation(num),
            "age": turning_point_ages[idx]
        }
        for idx, num in enumerate(turning_points)
    ]
    
    # Calculate Pinnacles
    pinnacles = calculate_pinnacles(day, month, year)

    result = {
        "life_seal": life_seal_data["number"],
        "life_planet": life_seal_data["planet"],
        "physical_name_number": physical_name_number,
        "soul_number": soul_number,
        "personality_number": personality_number,
        "personal_year": calculate_personal_year(day, month, current_year),
        "blessed_years": generate_blessed_years(current_year),
        "blessed_days": calculate_blessed_days(day),
        "life_cycle_phase": determine_life_cycle_phase(age),
        "life_turning_points": get_life_turning_points(),
        "life_cycles": life_cycles_with_interpretations,
        "turning_points": turning_points_with_interpretations,
        "pinnacles": pinnacles,
        "narrative": build_narrative(
            life_cycles_with_interpretations,
            turning_points_with_interpretations
        ),
        "report": build_report(
            life_cycles_with_interpretations,
            turning_points_with_interpretations,
            build_narrative(
                life_cycles_with_interpretations,
                turning_points_with_interpretations
            ),
            life_seal_data["number"],
            life_seal_data["planet"],
            soul_number,
            personality_number,
            calculate_personal_year(day, month, current_year)
        )
    }

    if partner_name:
        sex_number_1 = calculate_physical_name_number(first_name)
        sex_number_2 = calculate_physical_name_number(partner_name)
        result["compatibility"] = evaluate_compatibility(
            sex_number_1, sex_number_2
        )

    return result
