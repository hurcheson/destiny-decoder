"""
API routes for push notifications, FCM tokens, and notification preferences.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/notifications", tags=["notifications"])


class TokenRegistrationRequest(BaseModel):
    """Register a device push notification token."""
    fcm_token: str
    device_type: str  # ios, android, web


class NotificationPreferences(BaseModel):
    """User notification preferences."""
    blessed_day_alerts: bool = True
    personal_year_alerts: bool = True
    lunar_phase_alerts: bool = False
    email_digest: bool = False
    digest_frequency: str = "weekly"  # daily, weekly, monthly


@router.post("/tokens/register")
async def register_device_token(request: TokenRegistrationRequest) -> dict:
    """
    Register a device FCM token for push notifications.
    
    Args:
        fcm_token: Firebase Cloud Messaging token from the device
        device_type: ios, android, or web
    
    Returns:
        {"success": bool, "message": str}
    """
    if not request.fcm_token:
        raise HTTPException(status_code=400, detail="fcm_token is required")
    
    # TODO: Store token in database linked to authenticated user
    # For now, just acknowledge
    return {
        "success": True,
        "message": f"Token registered for {request.device_type}",
        "token_prefix": request.fcm_token[:10],
    }


@router.post("/tokens/unregister")
async def unregister_device_token(fcm_token: str) -> dict:
    """
    Unregister a device FCM token (e.g., on logout).
    
    Args:
        fcm_token: Token to remove
    
    Returns:
        {"success": bool, "message": str}
    """
    if not fcm_token:
        raise HTTPException(status_code=400, detail="fcm_token is required")
    
    # TODO: Remove token from database
    return {"success": True, "message": "Token unregistered"}


@router.get("/preferences")
async def get_notification_preferences() -> NotificationPreferences:
    """
    Retrieve user's notification preferences.
    
    Returns:
        NotificationPreferences object
    """
    # TODO: Fetch from database for authenticated user
    return NotificationPreferences()


@router.put("/preferences")
async def update_notification_preferences(prefs: NotificationPreferences) -> dict:
    """
    Update user's notification preferences.
    
    Args:
        prefs: Updated preferences
    
    Returns:
        {"success": bool, "message": str}
    """
    # TODO: Save to database for authenticated user
    return {
        "success": True,
        "message": "Notification preferences updated",
        "preferences": prefs.dict(),
    }


@router.post("/test/blessed-day")
async def send_test_blessed_day_notification() -> dict:
    """
    (Dev/Test) Send a test blessed day notification.
    
    Returns:
        {"success": bool, "message": str, "sent_count": int}
    """
    # TODO: Call notification service to simulate blessed day alert
    return {
        "success": True,
        "message": "Test blessed day notification queued",
        "sent_count": 1,
    }


@router.post("/test/personal-year")
async def send_test_personal_year_notification() -> dict:
    """
    (Dev/Test) Send a test personal year milestone notification.
    
    Returns:
        {"success": bool, "message": str, "sent_count": int}
    """
    # TODO: Call notification service to simulate personal year alert
    return {
        "success": True,
        "message": "Test personal year notification queued",
        "sent_count": 1,
    }
