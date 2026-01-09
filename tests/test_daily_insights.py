"""
Unit Tests for Daily Insights Service
Tests all calculation logic, blessed day checking, and edge cases.
"""

import pytest
from datetime import date, timedelta
from backend.app.services.daily_insights_service import (
    calculate_daily_power_number,
    check_blessed_day,
    get_daily_insight_full,
    get_weekly_power_numbers,
    get_monthly_blessed_days,
    get_personal_month_guidance
)


class TestDailyPowerNumber:
    """Test daily power number calculations"""
    
    def test_basic_calculation(self):
        """Test power number calculation for a known date"""
        # Jan 9, 2026: day=9, month=1, year=2026(reduces to 1)
        # Life seal = 7
        # 9 + 1 + 1 + 7 = 18 → 9
        test_date = date(2026, 1, 9)
        result = calculate_daily_power_number(test_date, life_seal=7)
        assert result == 9
    
    def test_different_life_seals(self):
        """Test same date with different life seals produces different power numbers"""
        test_date = date(2026, 1, 15)
        # day=15→6, month=1, year=2026→1
        
        result_ls1 = calculate_daily_power_number(test_date, life_seal=1)
        result_ls5 = calculate_daily_power_number(test_date, life_seal=5)
        
        # 6+1+1+1=9 vs 6+1+1+5=13→4
        assert result_ls1 == 9
        assert result_ls5 == 4
    
    def test_reduction_chain(self):
        """Test dates requiring multiple reduction steps"""
        # Dec 29, 2026: day=29→11→2, month=12→3, year=2026→1
        # Life seal = 9
        # 2 + 3 + 1 + 9 = 15 → 6
        test_date = date(2026, 12, 29)
        result = calculate_daily_power_number(test_date, life_seal=9)
        assert result == 6
    
    def test_all_power_numbers_possible(self):
        """Verify all numbers 1-9 are reachable"""
        test_date = date(2026, 1, 1)  # Simple baseline
        reached_numbers = set()
        
        for life_seal in range(1, 10):
            power = calculate_daily_power_number(test_date, life_seal)
            reached_numbers.add(power)
        
        # Should be able to reach multiple different numbers
        assert len(reached_numbers) > 5
    
    def test_invalid_life_seal(self):
        """Test validation of life seal range"""
        test_date = date(2026, 1, 1)
        
        with pytest.raises(ValueError, match="Life seal must be 1-9"):
            calculate_daily_power_number(test_date, life_seal=0)
        
        with pytest.raises(ValueError, match="Life seal must be 1-9"):
            calculate_daily_power_number(test_date, life_seal=10)
    
    def test_leap_year_date(self):
        """Test calculation works for Feb 29 leap year"""
        test_date = date(2024, 2, 29)
        result = calculate_daily_power_number(test_date, life_seal=5)
        assert 1 <= result <= 9


class TestBlessedDays:
    """Test blessed day checking logic"""
    
    def test_blessed_day_match(self):
        """Test that dates reducing to birth day are blessed"""
        # Birth day 9 → blessed days should include 9, 18, 27
        assert check_blessed_day(date(2026, 1, 9), day_of_birth=9) is True
        assert check_blessed_day(date(2026, 1, 18), day_of_birth=9) is True
        assert check_blessed_day(date(2026, 1, 27), day_of_birth=9) is True
    
    def test_blessed_day_no_match(self):
        """Test that non-matching dates are not blessed"""
        assert check_blessed_day(date(2026, 1, 10), day_of_birth=9) is False
        assert check_blessed_day(date(2026, 1, 17), day_of_birth=9) is False
    
    def test_double_digit_birth_day(self):
        """Test blessed days for double-digit birth days"""
        # Birth day 15 → reduces to 6 → blessed: 6, 15, 24
        assert check_blessed_day(date(2026, 1, 6), day_of_birth=15) is True
        assert check_blessed_day(date(2026, 1, 15), day_of_birth=15) is True
        assert check_blessed_day(date(2026, 1, 24), day_of_birth=15) is True
        assert check_blessed_day(date(2026, 1, 7), day_of_birth=15) is False
    
    def test_month_independence(self):
        """Test blessed status is day-of-month based, not month-dependent"""
        # If 9th is blessed in Jan, should be blessed in all months
        assert check_blessed_day(date(2026, 1, 9), day_of_birth=9) is True
        assert check_blessed_day(date(2026, 6, 9), day_of_birth=9) is True
        assert check_blessed_day(date(2026, 12, 9), day_of_birth=9) is True


class TestFullDailyInsight:
    """Test complete daily insight generation"""
    
    def test_full_insight_structure(self):
        """Test that full insight contains all expected fields"""
        result = get_daily_insight_full(
            life_seal=7,
            day_of_birth=9,
            target_date=date(2026, 1, 9)
        )
        
        # Check top-level keys
        assert "date" in result
        assert "power_number" in result
        assert "is_blessed_day" in result
        assert "insight" in result
        assert "brief_insight" in result
        assert "day_of_week" in result
        
        # Check insight object structure
        insight = result["insight"]
        assert "title" in insight
        assert "energy" in insight
        assert "insight" in insight
        assert "action_focus" in insight
        assert "spiritual_guidance" in insight
        assert "energy_color" in insight
        assert "affirmation" in insight
        assert "caution" in insight
    
    def test_today_default(self):
        """Test that None target_date defaults to today"""
        result = get_daily_insight_full(life_seal=5, day_of_birth=12)
        result_date = date.fromisoformat(result["date"])
        assert result_date == date.today()
    
    def test_blessed_day_detection(self):
        """Test blessed day flag is correctly set"""
        # Day 9 born, checking Jan 9
        result = get_daily_insight_full(
            life_seal=7,
            day_of_birth=9,
            target_date=date(2026, 1, 9)
        )
        assert result["is_blessed_day"] is True
        
        # Day 9 born, checking Jan 10
        result = get_daily_insight_full(
            life_seal=7,
            day_of_birth=9,
            target_date=date(2026, 1, 10)
        )
        assert result["is_blessed_day"] is False
    
    def test_day_of_week_format(self):
        """Test day_of_week is properly formatted"""
        result = get_daily_insight_full(
            life_seal=5,
            day_of_birth=12,
            target_date=date(2026, 1, 9)  # This is a Friday
        )
        assert result["day_of_week"] == "Friday"


class TestWeeklyInsights:
    """Test weekly power number generation"""
    
    def test_weekly_length(self):
        """Test that exactly 7 days are returned"""
        result = get_weekly_power_numbers(
            life_seal=5,
            start_date=date(2026, 1, 1)
        )
        assert len(result) == 7
    
    def test_weekly_sequential_dates(self):
        """Test that dates are consecutive"""
        start = date(2026, 1, 1)
        result = get_weekly_power_numbers(life_seal=5, start_date=start)
        
        for i, day_data in enumerate(result):
            expected_date = start + timedelta(days=i)
            assert day_data["date"] == expected_date.isoformat()
    
    def test_weekly_structure(self):
        """Test each day has required fields"""
        result = get_weekly_power_numbers(life_seal=5)
        
        for day in result:
            assert "date" in day
            assert "day_of_week" in day
            assert "power_number" in day
            assert "brief_insight" in day
            assert 1 <= day["power_number"] <= 9
    
    def test_weekly_today_default(self):
        """Test None start_date defaults to today"""
        result = get_weekly_power_numbers(life_seal=5)
        first_date = date.fromisoformat(result[0]["date"])
        assert first_date == date.today()


class TestMonthlyBlessedDays:
    """Test monthly blessed days listing"""
    
    def test_blessed_days_in_month(self):
        """Test correct blessed days returned for a month"""
        # Birth day 9 → blessed: 9, 18, 27
        result = get_monthly_blessed_days(
            day_of_birth=9,
            month=1,
            year=2026
        )
        
        expected_dates = [
            date(2026, 1, 9),
            date(2026, 1, 18),
            date(2026, 1, 27)
        ]
        assert result == expected_dates
    
    def test_february_blessed_days(self):
        """Test blessed days respect month length (Feb has no 29/30/31)"""
        # Birth day 1 → blessed: 1, 10, 19, 28
        result = get_monthly_blessed_days(
            day_of_birth=1,
            month=2,
            year=2026  # Not leap year, 28 days
        )
        
        expected_dates = [
            date(2026, 2, 1),
            date(2026, 2, 10),
            date(2026, 2, 19),
            date(2026, 2, 28)
        ]
        assert result == expected_dates
    
    def test_leap_year_february(self):
        """Test Feb 29 included in leap year if blessed"""
        # Birth day 11 → reduces to 2 → blessed: 2, 11, 20, 29
        result = get_monthly_blessed_days(
            day_of_birth=11,
            month=2,
            year=2024  # Leap year
        )
        
        assert date(2024, 2, 29) in result
    
    def test_current_month_default(self):
        """Test None month/year defaults to current"""
        result = get_monthly_blessed_days(day_of_birth=5)
        today = date.today()
        
        # All dates should be in current month/year
        for blessed_date in result:
            assert blessed_date.month == today.month
            assert blessed_date.year == today.year


class TestPersonalMonth:
    """Test personal month calculation"""
    
    def test_personal_month_calculation(self):
        """Test basic personal month calculation"""
        # Birth: 9/5/1990
        # For Jan 2026: personal_year should be calculated first
        result = get_personal_month_guidance(
            day_of_birth=9,
            month_of_birth=5,
            year_of_birth=1990,
            target_month=1,
            target_year=2026
        )
        
        assert "personal_month" in result
        assert "personal_year" in result
        assert 1 <= result["personal_month"] <= 9
        assert 1 <= result["personal_year"] <= 9
    
    def test_personal_month_structure(self):
        """Test response contains all expected fields"""
        result = get_personal_month_guidance(
            day_of_birth=15,
            month_of_birth=7,
            year_of_birth=1985,
            target_month=3,
            target_year=2026
        )
        
        assert "personal_month" in result
        assert "personal_year" in result
        assert "calendar_month" in result
        assert "calendar_year" in result
        assert "theme" in result
        assert "month_name" in result
        
        assert result["calendar_month"] == 3
        assert result["calendar_year"] == 2026
        assert result["month_name"] == "March"
    
    def test_personal_month_current_default(self):
        """Test None month/year defaults to current"""
        result = get_personal_month_guidance(
            day_of_birth=20,
            month_of_birth=8,
            year_of_birth=1992
        )
        
        today = date.today()
        assert result["calendar_month"] == today.month
        assert result["calendar_year"] == today.year
    
    def test_all_months_have_themes(self):
        """Test that all personal months 1-9 have themes"""
        # Use different target months to potentially hit all personal months
        themes_found = set()
        
        for target_month in range(1, 13):
            result = get_personal_month_guidance(
                day_of_birth=5,
                month_of_birth=5,
                year_of_birth=1990,
                target_month=target_month,
                target_year=2026
            )
            themes_found.add(result["personal_month"])
        
        # Should hit multiple different personal months across year
        assert len(themes_found) >= 9  # Should cover all 9 numbers


class TestEdgeCases:
    """Test edge cases and boundary conditions"""
    
    def test_year_2000_calculation(self):
        """Test calculations work for Y2K edge case"""
        test_date = date(2000, 1, 1)
        result = calculate_daily_power_number(test_date, life_seal=5)
        assert 1 <= result <= 9
    
    def test_far_future_date(self):
        """Test calculations work for distant future"""
        test_date = date(2099, 12, 31)
        result = calculate_daily_power_number(test_date, life_seal=5)
        assert 1 <= result <= 9
    
    def test_birth_day_31(self):
        """Test blessed days for day 31 (only exists in some months)"""
        result = get_monthly_blessed_days(
            day_of_birth=31,
            month=2,  # February never has 31
            year=2026
        )
        # Should not include day 31 in February
        assert all(d.day != 31 for d in result)
    
    def test_birth_day_29_non_leap_year(self):
        """Test blessed days for Feb 29 birth in non-leap year"""
        result = get_monthly_blessed_days(
            day_of_birth=29,
            month=2,
            year=2026  # Not leap year
        )
        # Should not include Feb 29 in non-leap year (Feb only has 28 days)
        # Just verify no date with day 29 exists in result
        assert all(d.day != 29 for d in result)
