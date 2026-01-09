"""
Daily Insights API Routes
Provides endpoints for daily power numbers, blessed days, and personalized daily guidance.
"""

from fastapi import APIRouter, HTTPException, status
from datetime import date, datetime
from typing import List

from ..schemas import (
    DailyInsightRequest,
    DailyInsightResponse,
    WeeklyInsightsRequest,
    WeeklyInsightsResponse,
    DailyPowerPreview,
    BlessedDaysRequest,
    BlessedDaysResponse,
    PersonalMonthRequest,
    PersonalMonthResponse
)
from ...services.daily_insights_service import (
    get_daily_insight_full,
    get_weekly_power_numbers,
    get_monthly_blessed_days,
    get_personal_month_guidance
)

router = APIRouter(
    prefix="/daily",
    tags=["daily-insights"]
)


@router.post("/insight", response_model=DailyInsightResponse)
async def get_daily_insight(request: DailyInsightRequest):
    """
    Get complete daily insight including power number, blessed status, and interpretation.
    
    **Parameters:**
    - life_seal: User's life seal number (1-9)
    - day_of_birth: User's birth day (1-31)
    - target_date: Optional ISO date string (defaults to today)
    
    **Returns:**
    - Complete daily insight with power number, blessed status, full interpretation,
      brief insight, and day of week
    
    **Example:**
    ```json
    {
        "life_seal": 7,
        "day_of_birth": 9,
        "target_date": "2026-01-09"
    }
    ```
    """
    try:
        # Parse target date if provided
        target_date_obj = None
        if request.target_date:
            try:
                target_date_obj = datetime.fromisoformat(request.target_date).date()
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid date format. Use ISO format: YYYY-MM-DD"
                )
        
        # Get daily insight
        insight_data = get_daily_insight_full(
            life_seal=request.life_seal,
            day_of_birth=request.day_of_birth,
            target_date=target_date_obj
        )
        
        return DailyInsightResponse(**insight_data)
    
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating daily insight: {str(e)}"
        )


@router.post("/weekly", response_model=WeeklyInsightsResponse)
async def get_weekly_insights(request: WeeklyInsightsRequest):
    """
    Get power numbers and brief insights for the next 7 days.
    Useful for weekly planning and overview.
    
    **Parameters:**
    - life_seal: User's life seal number (1-9)
    - start_date: Optional ISO date string (defaults to today)
    
    **Returns:**
    - List of 7 days with dates, power numbers, and brief insights
    """
    try:
        # Parse start date if provided
        start_date_obj = None
        if request.start_date:
            try:
                start_date_obj = datetime.fromisoformat(request.start_date).date()
            except ValueError:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Invalid date format. Use ISO format: YYYY-MM-DD"
                )
        
        # Get weekly data
        weekly_data = get_weekly_power_numbers(
            life_seal=request.life_seal,
            start_date=start_date_obj
        )
        
        # Convert to response models
        previews = [DailyPowerPreview(**day_data) for day_data in weekly_data]
        
        week_start = start_date_obj if start_date_obj else date.today()
        
        return WeeklyInsightsResponse(
            week_starting=week_start.isoformat(),
            daily_previews=previews
        )
    
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating weekly insights: {str(e)}"
        )


@router.post("/blessed-days", response_model=BlessedDaysResponse)
async def get_blessed_days_month(request: BlessedDaysRequest):
    """
    Get all blessed days in a specific month.
    Useful for calendar view highlighting and monthly planning.
    
    **Parameters:**
    - day_of_birth: User's birth day (1-31)
    - month: Optional target month (1-12, defaults to current)
    - year: Optional target year (defaults to current)
    
    **Returns:**
    - List of blessed dates in the specified month
    """
    try:
        blessed_dates = get_monthly_blessed_days(
            day_of_birth=request.day_of_birth,
            month=request.month,
            year=request.year
        )
        
        # Use first blessed date to get month/year if not provided
        # or default to today's month/year
        if blessed_dates:
            month_val = blessed_dates[0].month
            year_val = blessed_dates[0].year
            month_name = blessed_dates[0].strftime("%B")
        else:
            today = date.today()
            month_val = request.month if request.month else today.month
            year_val = request.year if request.year else today.year
            month_name = date(year_val, month_val, 1).strftime("%B")
        
        return BlessedDaysResponse(
            month=month_val,
            year=year_val,
            month_name=month_name,
            blessed_dates=[d.isoformat() for d in blessed_dates]
        )
    
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating blessed days: {str(e)}"
        )


@router.post("/personal-month", response_model=PersonalMonthResponse)
async def get_personal_month(request: PersonalMonthRequest):
    """
    Calculate personal month number and theme.
    Personal Month combines Personal Year with current calendar month.
    
    **Parameters:**
    - day_of_birth, month_of_birth, year_of_birth: User's birth date
    - target_month: Optional month (1-12, defaults to current)
    - target_year: Optional year (defaults to current)
    
    **Returns:**
    - Personal month number, personal year, calendar info, and monthly theme
    """
    try:
        month_data = get_personal_month_guidance(
            day_of_birth=request.day_of_birth,
            month_of_birth=request.month_of_birth,
            year_of_birth=request.year_of_birth,
            target_month=request.target_month,
            target_year=request.target_year
        )
        
        return PersonalMonthResponse(**month_data)
    
    except ValueError as ve:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(ve)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error calculating personal month: {str(e)}"
        )
