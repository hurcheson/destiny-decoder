from pydantic import BaseModel, Field
from typing import Optional, List, Dict
from datetime import date

class DestinyRequest(BaseModel):
    day_of_birth: int
    month_of_birth: int
    year_of_birth: int
    first_name: str
    other_names: Optional[str] = None
    full_name: Optional[str] = None
    current_year: Optional[int] = None
    age: Optional[int] = None
    partner_name: Optional[str] = None

class DestinyResponse(BaseModel):
    life_seal: int
    life_planet: str
    physical_name_number: int
    soul_number: int
    personality_number: int
    personal_year: int
    blessed_years: List[int]
    blessed_days: List[int]
    life_cycle_phase: str
    life_turning_points: List[int]
    compatibility: Optional[str] = None


# Daily Insights Schemas
class DailyInsightRequest(BaseModel):
    """Request schema for daily insight calculation"""
    life_seal: int = Field(..., ge=1, le=9, description="User's life seal number (1-9)")
    day_of_birth: int = Field(..., ge=1, le=31, description="User's birth day")
    target_date: Optional[str] = Field(None, description="ISO format date (YYYY-MM-DD), defaults to today")

class DailyInsightInterpretation(BaseModel):
    """Full interpretation structure for daily insight"""
    title: str
    energy: str
    insight: str
    action_focus: List[str]
    spiritual_guidance: str
    energy_color: str
    affirmation: str
    caution: str

class DailyInsightResponse(BaseModel):
    """Complete daily insight response"""
    date: str = Field(..., description="ISO format date")
    day_of_week: str = Field(..., description="Day name (e.g., Monday)")
    power_number: int = Field(..., ge=1, le=9)
    is_blessed_day: bool
    insight: DailyInsightInterpretation
    brief_insight: str

class WeeklyInsightsRequest(BaseModel):
    """Request schema for 7-day power number preview"""
    life_seal: int = Field(..., ge=1, le=9)
    start_date: Optional[str] = Field(None, description="ISO format date, defaults to today")

class DailyPowerPreview(BaseModel):
    """Brief daily power info for weekly view"""
    date: str
    day_of_week: str
    power_number: int
    brief_insight: str

class WeeklyInsightsResponse(BaseModel):
    """7-day power numbers and brief insights"""
    week_starting: str
    daily_previews: List[DailyPowerPreview]

class BlessedDaysRequest(BaseModel):
    """Request schema for monthly blessed days"""
    day_of_birth: int = Field(..., ge=1, le=31)
    month: Optional[int] = Field(None, ge=1, le=12, description="Target month, defaults to current")
    year: Optional[int] = Field(None, description="Target year, defaults to current")

class BlessedDaysResponse(BaseModel):
    """List of blessed days in specified month"""
    month: int
    year: int
    month_name: str
    blessed_dates: List[str] = Field(..., description="List of ISO format dates")

class PersonalMonthRequest(BaseModel):
    """Request schema for personal month guidance"""
    day_of_birth: int = Field(..., ge=1, le=31)
    month_of_birth: int = Field(..., ge=1, le=12)
    year_of_birth: int
    target_month: Optional[int] = Field(None, ge=1, le=12)
    target_year: Optional[int] = None

class PersonalMonthResponse(BaseModel):
    """Personal month calculation and theme"""
    personal_month: int = Field(..., ge=1, le=9)
    personal_year: int = Field(..., ge=1, le=9)
    calendar_month: int
    calendar_year: int
    month_name: str
    theme: str

# Notification Preferences Schemas
class NotificationPreferencesRequest(BaseModel):
    """User notification preferences"""
    blessed_day_alerts: Optional[bool] = True
    daily_insights: Optional[bool] = True
    lunar_phase_alerts: Optional[bool] = False
    motivational_quotes: Optional[bool] = True
    quiet_hours_enabled: Optional[bool] = False
    quiet_hours_start: Optional[str] = None  # HH:MM format (24h)
    quiet_hours_end: Optional[str] = None    # HH:MM format (24h)


class NotificationPreferencesResponse(BaseModel):
    """User notification preferences response"""
    blessed_day_alerts: bool
    daily_insights: bool
    lunar_phase_alerts: bool
    motivational_quotes: bool
    quiet_hours_enabled: bool
    quiet_hours_start: Optional[str]
    quiet_hours_end: Optional[str]
    updated_at: str  # ISO timestamp


# User Profile Schemas
class CreateUserProfileRequest(BaseModel):
    """Create new user profile during onboarding"""
    device_id: str
    user_id: Optional[str] = None
    first_name: str = Field(..., min_length=1, max_length=100)
    date_of_birth: str = Field(..., description="YYYY-MM-DD format")
    life_stage: Optional[str] = None  # twenties, thirties, forties, fifties+
    spiritual_preference: Optional[str] = None  # christian, universal, practical, custom
    communication_style: Optional[str] = None  # spiritual, practical, balanced
    interests: Optional[List[str]] = None  # ["career", "relationships", "spirituality", "personal_growth"]
    notification_style: Optional[str] = "motivational"  # motivational, informational, minimal


class UpdateUserProfileRequest(BaseModel):
    """Update existing user profile"""
    first_name: Optional[str] = None
    life_stage: Optional[str] = None
    spiritual_preference: Optional[str] = None
    communication_style: Optional[str] = None
    interests: Optional[List[str]] = None
    notification_style: Optional[str] = None


class UserProfileResponse(BaseModel):
    """User profile response"""
    id: str
    device_id: str
    user_id: Optional[str] = None
    first_name: str
    date_of_birth: str
    life_seal: Optional[int]
    life_stage: str
    spiritual_preference: str
    communication_style: str
    interests: List[str]
    notification_style: str
    readings_count: int
    last_reading_date: Optional[str]
    pdf_exports_count: int
    pdf_exports_month: Optional[str]
    has_completed_onboarding: bool
    has_seen_dashboard_intro: bool
    created_at: str
    updated_at: str


class UserProfileWithCalculationsResponse(UserProfileResponse):
    """Extended profile response with calculated numbers"""
    soul_number: Optional[int] = None
    personality_number: Optional[int] = None
    personal_year: Optional[int] = None
    daily_power_number: Optional[int] = None
    today_power_number: Optional[int] = None
    is_blessed_day_today: Optional[bool] = None