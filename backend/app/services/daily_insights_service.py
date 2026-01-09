"""
Daily Insights Service
Handles calculation of daily power numbers and blessed day status.
Provides personalized daily guidance based on user's life seal and current date.
"""

from datetime import date, datetime
from typing import Dict, List, Optional
from ..core.reduction import reduce_to_single_digit
from ..core.cycles import calculate_blessed_days
from ..interpretations.daily_insights import get_daily_insight, get_brief_daily_insight


def calculate_daily_power_number(target_date: date, life_seal: int) -> int:
    """
    Calculate the power number for a specific date combined with user's life seal.
    
    Formula: reduce(day + month + year + life_seal)
    
    Args:
        target_date: The date to calculate power number for
        life_seal: User's life seal number (1-9)
        
    Returns:
        Integer 1-9 representing the power number
        
    Example:
        For January 9, 2026 (09/01/2026) with Life Seal 7:
        day_r = reduce(9) = 9
        month_r = reduce(1) = 1
        year_r = reduce(2026) = reduce(10) = 1
        power = reduce(9 + 1 + 1 + 7) = reduce(18) = 9
    """
    if life_seal < 1 or life_seal > 9:
        raise ValueError(f"Life seal must be 1-9, got {life_seal}")
    
    day_reduced = reduce_to_single_digit(target_date.day)
    month_reduced = reduce_to_single_digit(target_date.month)
    year_reduced = reduce_to_single_digit(target_date.year)
    
    total = day_reduced + month_reduced + year_reduced + life_seal
    power_number = reduce_to_single_digit(total)
    
    return power_number


def check_blessed_day(target_date: date, day_of_birth: int) -> bool:
    """
    Check if target date is a blessed day for user.
    A day is blessed if its reduced value matches the user's reduced birth day.
    
    Args:
        target_date: Date to check
        day_of_birth: User's birth day (1-31)
        
    Returns:
        Boolean indicating if it's a blessed day
        
    Example:
        Birth day: 9 (reduces to 9)
        Blessed days: 9, 18, 27 (all reduce to 9)
        So Jan 9, 18, 27 would be blessed days
    """
    blessed_days_list = calculate_blessed_days(day_of_birth)
    return target_date.day in blessed_days_list


def get_daily_insight_full(
    life_seal: int,
    day_of_birth: int,
    target_date: Optional[date] = None
) -> Dict:
    """
    Get complete daily insight including power number, blessed status, and interpretation.
    
    Args:
        life_seal: User's life seal number (1-9)
        day_of_birth: User's birth day (1-31)
        target_date: Date to get insight for (defaults to today)
        
    Returns:
        Dictionary containing:
        - date: ISO format date string
        - power_number: 1-9
        - is_blessed_day: boolean
        - insight: Full interpretation object
        - brief_insight: Short text for notifications
        
    Example:
        {
            "date": "2026-01-09",
            "power_number": 7,
            "is_blessed_day": True,
            "insight": {...full interpretation...},
            "brief_insight": "Seek wisdom in solitude..."
        }
    """
    if target_date is None:
        target_date = date.today()
    
    power_number = calculate_daily_power_number(target_date, life_seal)
    is_blessed = check_blessed_day(target_date, day_of_birth)
    full_insight = get_daily_insight(power_number)
    brief_text = get_brief_daily_insight(power_number)
    
    return {
        "date": target_date.isoformat(),
        "power_number": power_number,
        "is_blessed_day": is_blessed,
        "insight": full_insight,
        "brief_insight": brief_text,
        "day_of_week": target_date.strftime("%A")
    }


def get_weekly_power_numbers(
    life_seal: int,
    start_date: Optional[date] = None
) -> List[Dict]:
    """
    Get power numbers for the next 7 days from start date.
    Useful for weekly planning view.
    
    Args:
        life_seal: User's life seal number (1-9)
        start_date: Starting date (defaults to today)
        
    Returns:
        List of 7 dictionaries with date and power_number
    """
    if start_date is None:
        start_date = date.today()
    
    weekly_data = []
    for day_offset in range(7):
        from datetime import timedelta
        current_date = start_date + timedelta(days=day_offset)
        power_num = calculate_daily_power_number(current_date, life_seal)
        
        weekly_data.append({
            "date": current_date.isoformat(),
            "day_of_week": current_date.strftime("%A"),
            "power_number": power_num,
            "brief_insight": get_brief_daily_insight(power_num)
        })
    
    return weekly_data


def get_monthly_blessed_days(
    day_of_birth: int,
    month: Optional[int] = None,
    year: Optional[int] = None
) -> List[date]:
    """
    Get all blessed days in a specific month.
    Useful for calendar view highlighting.
    
    Args:
        day_of_birth: User's birth day (1-31)
        month: Target month (1-12), defaults to current month
        year: Target year (YYYY), defaults to current year
        
    Returns:
        List of date objects representing blessed days in the month
    """
    if month is None:
        month = date.today().month
    if year is None:
        year = date.today().year
    
    blessed_day_numbers = calculate_blessed_days(day_of_birth)
    
    # Get number of days in target month
    from calendar import monthrange
    _, days_in_month = monthrange(year, month)
    
    blessed_dates = []
    for day in blessed_day_numbers:
        if day <= days_in_month:
            blessed_dates.append(date(year, month, day))
    
    return blessed_dates


def get_personal_month_guidance(
    day_of_birth: int,
    month_of_birth: int,
    year_of_birth: int,
    target_month: Optional[int] = None,
    target_year: Optional[int] = None
) -> Dict:
    """
    Calculate personal month number and provide guidance.
    Personal Month = reduce(personal_year + current_calendar_month)
    
    Args:
        day_of_birth: User's birth day
        month_of_birth: User's birth month
        year_of_birth: User's birth year
        target_month: Month to calculate for (defaults to current)
        target_year: Year to calculate for (defaults to current)
        
    Returns:
        Dictionary with personal_month number and brief guidance
    """
    from ..core.personal_year import calculate_personal_year
    
    if target_month is None:
        target_month = date.today().month
    if target_year is None:
        target_year = date.today().year
    
    # Calculate personal year for target year
    personal_year = calculate_personal_year(day_of_birth, month_of_birth, target_year)
    
    # Calculate personal month
    personal_month_raw = personal_year + target_month
    personal_month = reduce_to_single_digit(personal_month_raw)
    
    # Month themes (brief version)
    month_themes = {
        1: "New beginnings in your personal journey",
        2: "Focus on relationships and partnerships",
        3: "Creative expression and communication",
        4: "Building foundations and stability",
        5: "Change, freedom, and new experiences",
        6: "Service, love, and responsibility",
        7: "Introspection and spiritual growth",
        8: "Achievement and material success",
        9: "Completion and letting go"
    }
    
    return {
        "personal_month": personal_month,
        "personal_year": personal_year,
        "calendar_month": target_month,
        "calendar_year": target_year,
        "theme": month_themes[personal_month],
        "month_name": date(target_year, target_month, 1).strftime("%B")
    }
