"""Pinnacle number calculations.

Pinnacles are achievement periods calculated from birth date.
Standard numerology has 4 pinnacles that span different age ranges.
"""

from .reduction import reduce_to_single_digit


def calculate_pinnacles(day: int, month: int, year: int) -> list[int]:
    """Calculate the 4 pinnacle numbers based on birth date.
    
    Pinnacles represent major achievement periods in life.
    
    Standard numerology formulas:
    - Pinnacle 1 (Ages 0-36): month + day
    - Pinnacle 2 (Ages 36-45): day + year
    - Pinnacle 3 (Ages 45-54): Pinnacle 1 + Pinnacle 2
    - Pinnacle 4 (Ages 54+): month + year
    
    Args:
        day: Day of birth (1-31)
        month: Month of birth (1-12)
        year: Full year of birth (e.g., 1990)
    
    Returns:
        List of 4 reduced pinnacle numbers [P1, P2, P3, P4]
    """
    # Reduce each component first
    reduced_month = reduce_to_single_digit(month)
    reduced_day = reduce_to_single_digit(day)
    reduced_year = reduce_to_single_digit(year)
    
    # Calculate each pinnacle
    pinnacle_1 = reduce_to_single_digit(reduced_month + reduced_day)
    pinnacle_2 = reduce_to_single_digit(reduced_day + reduced_year)
    pinnacle_3 = reduce_to_single_digit(pinnacle_1 + pinnacle_2)
    pinnacle_4 = reduce_to_single_digit(reduced_month + reduced_year)
    
    return [pinnacle_1, pinnacle_2, pinnacle_3, pinnacle_4]
