"""
User Profile API Routes
Handles CRUD operations for user profiles with personalization data.
Supports device-based (anonymous) and user-based (authenticated) profiles.
"""

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.config.database import get_db
from app.models.user_profile import UserProfile, LifeStage, SpiritualPreference, CommunicationStyle
from app.api.schemas import (
    CreateUserProfileRequest,
    UpdateUserProfileRequest,
    UserProfileResponse,
    UserProfileWithCalculationsResponse,
)
from app.core.life_seal import calculate_life_seal
from app.core.name_numbers import calculate_soul_number, calculate_personality_number
from app.core.personal_year import calculate_personal_year
from app.core.cycles import calculate_blessed_days

router = APIRouter(prefix="/api/profile", tags=["profile"])


@router.post("/create", response_model=UserProfileResponse, status_code=status.HTTP_201_CREATED)
async def create_profile(
    request: CreateUserProfileRequest,
    db: Session = Depends(get_db)
) -> UserProfileResponse:
    """
    Create a new user profile during onboarding.
    
    Device-based profile creation for anonymous users.
    Future: Will support user_id for authenticated profiles.
    
    Args:
        request: Profile creation request with name, DOB, preferences
        db: Database session
        
    Returns:
        Created user profile
        
    Raises:
        HTTPException 400: If device already has profile
        HTTPException 400: If invalid data provided
    """
    try:
        # Check if profile already exists for this device
        existing = db.query(UserProfile).filter(
            UserProfile.device_id == request.device_id
        ).first()
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Profile already exists for device {request.device_id}"
            )
        
        # Calculate life seal from DOB
        date_parts = request.date_of_birth.split("-")
        year = int(date_parts[0])
        month = int(date_parts[1])
        day = int(date_parts[2])
        
        life_seal_data = calculate_life_seal(day, month, year)
        life_seal_number = life_seal_data["number"]
        
        # Create new profile
        profile = UserProfile(
            id=str(uuid.uuid4()),
            device_id=request.device_id,
            first_name=request.first_name,
            date_of_birth=request.date_of_birth,
            life_seal=life_seal_number,
            life_stage=request.life_stage or LifeStage.UNKNOWN,
            spiritual_preference=request.spiritual_preference or SpiritualPreference.NOT_SPECIFIED,
            communication_style=request.communication_style or CommunicationStyle.NOT_SPECIFIED,
            interests=request.interests or [],
            notification_style=request.notification_style or "motivational",
            has_completed_onboarding=True,
        )
        
        db.add(profile)
        db.commit()
        db.refresh(profile)
        
        return UserProfileResponse(**profile.to_dict())
        
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid date format: {str(e)}"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to create profile: {str(e)}"
        )


@router.get("/me", response_model=UserProfileResponse)
async def get_profile(
    device_id: str,
    db: Session = Depends(get_db)
) -> UserProfileResponse:
    """
    Get current user's profile.
    
    Args:
        device_id: Device identifier
        db: Database session
        
    Returns:
        User profile data
        
    Raises:
        HTTPException 404: If profile not found
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    return UserProfileResponse(**profile.to_dict())


@router.get("/me/with-calculations", response_model=UserProfileWithCalculationsResponse)
async def get_profile_with_calculations(
    device_id: str,
    db: Session = Depends(get_db)
) -> UserProfileWithCalculationsResponse:
    """
    Get user profile with calculated daily numbers.
    
    Includes today's power number, blessed day status, and other
    calculated values for dashboard display.
    
    Args:
        device_id: Device identifier
        db: Database session
        
    Returns:
        Profile with calculated daily numbers
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    # Calculate additional numbers for today
    date_parts = profile.date_of_birth.split("-")
    year = int(date_parts[0])
    month = int(date_parts[1])
    day = int(date_parts[2])
    
    soul_number = calculate_soul_number(profile.first_name)
    personality_number = calculate_personality_number(profile.first_name)
    personal_year = calculate_personal_year(day, month, year)
    
    # Get today's power number (simplified - just use personal year for now)
    today = datetime.now()
    today_power = personal_year  # Simplified calculation
    daily_power = personal_year  # Simplified calculation
    
    # Check if today is a blessed day
    blessed_days = calculate_blessed_days(day)
    is_blessed = today.day in blessed_days
    
    response_data = profile.to_dict()
    response_data.update({
        "soul_number": soul_number,
        "personality_number": personality_number,
        "personal_year": personal_year,
        "daily_power_number": daily_power,
        "today_power_number": today_power,
        "is_blessed_day_today": is_blessed,
    })
    
    return UserProfileWithCalculationsResponse(**response_data)


@router.put("/me", response_model=UserProfileResponse)
async def update_profile(
    device_id: str,
    request: UpdateUserProfileRequest,
    db: Session = Depends(get_db)
) -> UserProfileResponse:
    """
    Update user profile preferences.
    
    Args:
        device_id: Device identifier
        request: Updated profile data
        db: Database session
        
    Returns:
        Updated profile
        
    Raises:
        HTTPException 404: If profile not found
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    # Update only provided fields
    update_data = request.dict(exclude_unset=True)
    for field, value in update_data.items():
        if value is not None:
            setattr(profile, field, value)
    
    profile.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(profile)
    
    return UserProfileResponse(**profile.to_dict())


@router.post("/me/increment-readings")
async def increment_readings(
    device_id: str,
    db: Session = Depends(get_db)
) -> dict:
    """
    Increment readings count and update last reading date.
    Called after each successful decode operation.
    
    Args:
        device_id: Device identifier
        db: Database session
        
    Returns:
        Updated readings count
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    profile.readings_count += 1
    profile.last_reading_date = datetime.utcnow()
    db.commit()
    db.refresh(profile)
    
    return {
        "readings_count": profile.readings_count,
        "last_reading_date": profile.last_reading_date.isoformat(),
    }


@router.post("/me/mark-dashboard-seen")
async def mark_dashboard_seen(
    device_id: str,
    db: Session = Depends(get_db)
) -> dict:
    """
    Mark dashboard intro as seen (don't show again).
    
    Args:
        device_id: Device identifier
        db: Database session
        
    Returns:
        Success status
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    profile.has_seen_dashboard_intro = True
    db.commit()
    
    return {"success": True, "message": "Dashboard intro marked as seen"}


@router.delete("/me")
async def delete_profile(
    device_id: str,
    db: Session = Depends(get_db)
) -> dict:
    """
    Delete user profile (for testing/cleanup purposes).
    
    Args:
        device_id: Device identifier
        db: Database session
        
    Returns:
        Success status
    """
    profile = db.query(UserProfile).filter(
        UserProfile.device_id == device_id
    ).first()
    
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Profile not found for this device"
        )
    
    db.delete(profile)
    db.commit()
    
    return {"success": True, "message": "Profile deleted"}
