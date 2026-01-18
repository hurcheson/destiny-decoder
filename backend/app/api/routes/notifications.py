"""
API routes for push notifications, FCM tokens, and notification preferences.
"""
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional
from datetime import datetime
import logging
import re

from app.config.database import get_db
from app.models.device import Device
from app.models.notification_preference import NotificationPreference

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/notifications", tags=["notifications"])


class TokenRegistrationRequest(BaseModel):
    """Register a device push notification token."""
    fcm_token: str
    device_type: str  # ios, android, web
    topics: Optional[list[str]] = None  # e.g., ["daily_insights", "blessed_days"]


class NotificationPreferences(BaseModel):
    """User notification preferences."""
    blessed_day_alerts: bool = True
    personal_year_alerts: bool = True
    lunar_phase_alerts: bool = False
    email_digest: bool = False
    digest_frequency: str = "weekly"  # daily, weekly, monthly


class TestNotificationRequest(BaseModel):
    """Request to send a test notification."""
    token: Optional[str] = None  # If provided, send to this token. Otherwise, send to topic.
    topic: Optional[str] = None  # Topic name for multicast
    title: str = "Test Notification"
    body: str = "This is a test notification from Destiny Decoder"


@router.post("/tokens/register")
async def register_device_token(request: TokenRegistrationRequest, db: Session = Depends(get_db)) -> dict:
    """
    Register a device FCM token for push notifications.
    
    Args:
        fcm_token: Firebase Cloud Messaging token from the device
        device_type: ios, android, or web
        topics: Optional list of topics to subscribe to
    
    Returns:
        {"success": bool, "message": str, "topics_subscribed": list}
    """
    if not request.fcm_token:
        raise HTTPException(status_code=400, detail="fcm_token is required")
    
    try:
        from app.services.firebase_admin_service import get_firebase_service
        import uuid
        import os
        
        firebase = None
        topics_subscribed = []
        
        # Try to get Firebase service (optional in development)
        try:
            firebase = get_firebase_service()
            # Subscribe to requested topics
            if request.topics:
                for topic in request.topics:
                    try:
                        result = firebase.subscribe_to_topic([request.fcm_token], topic)
                        if result.get("success"):
                            topics_subscribed.append(topic)
                    except Exception as e:
                        logger.warning(f"Could not subscribe to topic {topic}: {str(e)}")
        except FileNotFoundError:
            # Firebase not configured in development mode
            logger.info("Firebase not available, using topics as-is without FCM subscription")
            topics_subscribed = request.topics or []
        except Exception as e:
            logger.warning(f"Firebase service warning: {str(e)}")
            topics_subscribed = request.topics or []
        
        # Generate device_id or use existing one (based on token)
        # Check if token already exists
        existing_device = db.query(Device).filter(Device.fcm_token == request.fcm_token).first()
        
        if existing_device:
            # Update existing device
            existing_device.device_type = request.device_type
            existing_device.active = True
            existing_device.last_active = datetime.utcnow()
            existing_device.topics = ",".join(topics_subscribed)
            device = existing_device
        else:
            # Create new device
            device_id = str(uuid.uuid4())
            device = Device(
                device_id=device_id,
                fcm_token=request.fcm_token,
                device_type=request.device_type,
                active=True,
                topics=",".join(topics_subscribed),
            )
            db.add(device)
            
            # Create default notification preferences
            default_prefs = NotificationPreference(
                device_id=device_id,
                blessed_day_alerts=True,
                daily_insights=True,
                lunar_phase_alerts=False,
                motivational_quotes=True,
            )
            db.add(default_prefs)
        
        db.commit()
        db.refresh(device)
        
        logger.info(f"✓ Token registered: {request.device_type} ({device.device_id}) - subscribed to {len(topics_subscribed)} topics")
        
        return {
            "success": True,
            "message": f"Token registered for {request.device_type}",
            "device_id": device.device_id,
            "token_prefix": request.fcm_token[:10],
            "topics_subscribed": topics_subscribed,
        }
    except Exception as e:
        db.rollback()
        logger.error(f"Error registering token: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/tokens/unregister")
async def unregister_device_token(fcm_token: str, db: Session = Depends(get_db)) -> dict:
    """
    Unregister a device FCM token (e.g., on logout).
    
    Args:
        fcm_token: Token to remove
    
    Returns:
        {"success": bool, "message": str}
    """
    if not fcm_token:
        raise HTTPException(status_code=400, detail="fcm_token is required")
    
    try:
        # Find and mark device as inactive (or delete)
        device = db.query(Device).filter(Device.fcm_token == fcm_token).first()
        if device:
            device.active = False
            db.commit()
            logger.info(f"✓ Token unregistered: {fcm_token[:10]}")
        else:
            logger.warning(f"Token not found: {fcm_token[:10]}")
        
        return {"success": True, "message": "Token unregistered"}
    except Exception as e:
        db.rollback()
        logger.error(f"Error unregistering token: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# OLD ENDPOINTS REMOVED - Using database-backed endpoints below instead


@router.post("/test/blessed-day")
async def send_test_blessed_day_notification(request: TestNotificationRequest) -> dict:
    """
    (Dev/Test) Send a test blessed day notification.
    
    Args:
        request: Optional token for single notification, or topic for multicast
    
    Returns:
        {"success": bool, "message": str, "sent_count": int}
    """
    try:
        from app.services.firebase_admin_service import get_firebase_service, FCMNotification
        
        firebase = get_firebase_service()
        
        notification = FCMNotification(
            title="🌟 Blessed Day Alert (Test)",
            body="Today is a blessed day for new beginnings and positive changes",
            data={
                "type": "blessed_day",
                "test": "true",
            }
        )
        
        if request.token:
            result = firebase.send_notification(request.token, notification)
            return {
                "success": result.get("success"),
                "message": result.get("message_id") if result.get("success") else result.get("error"),
                "sent_count": 1 if result.get("success") else 0,
            }
        else:
            # Send to all blessed_days topic subscribers
            result = firebase.send_to_topic("blessed_days", notification)
            return {
                "success": result.get("success"),
                "message": result.get("message_id") if result.get("success") else result.get("error"),
                "sent_count": 1 if result.get("success") else 0,
            }
    except Exception as e:
        logger.error(f"Error sending test blessed day notification: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/test/personal-year")
async def send_test_personal_year_notification(request: TestNotificationRequest) -> dict:
    """
    (Dev/Test) Send a test personal year milestone notification.
    
    Args:
        request: Optional token for single notification, or topic for multicast
    
    Returns:
        {"success": bool, "message": str, "sent_count": int}
    """
    try:
        from app.services.firebase_admin_service import get_firebase_service, FCMNotification
        
        firebase = get_firebase_service()
        
        notification = FCMNotification(
            title="🎯 Personal Year Milestone (Test)",
            body="You're entering a new personal year cycle of growth and opportunity",
            data={
                "type": "personal_year",
                "test": "true",
            }
        )
        
        if request.token:
            result = firebase.send_notification(request.token, notification)
            return {
                "success": result.get("success"),
                "message": result.get("message_id") if result.get("success") else result.get("error"),
                "sent_count": 1 if result.get("success") else 0,
            }
        else:
            result = firebase.send_to_topic("personal_year", notification)
            return {
                "success": result.get("success"),
                "message": result.get("message_id") if result.get("success") else result.get("error"),
                "sent_count": 1 if result.get("success") else 0,
            }
    except Exception as e:
        logger.error(f"Error sending test personal year notification: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/test/send")
async def send_test_notification(request: TestNotificationRequest) -> dict:
    """
    (Dev/Test) Send a custom test notification.
    
    Args:
        request: Notification details with optional token or topic
    
    Returns:
        {"success": bool, "details": dict}
    """
    try:
        from app.services.firebase_admin_service import get_firebase_service, FCMNotification
        
        firebase = get_firebase_service()
        
        notification = FCMNotification(
            title=request.title,
            body=request.body,
            data={"test": "true"}
        )
        
        if request.token:
            result = firebase.send_notification(request.token, notification)
        elif request.topic:
            result = firebase.send_to_topic(request.topic, notification)
        else:
            raise HTTPException(
                status_code=400,
                detail="Either 'token' or 'topic' must be provided"
            )
        
        return {
            "success": result.get("success"),
            "details": result,
        }
    except Exception as e:
        logger.error(f"Error sending test notification: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/scheduler/status")
async def get_scheduler_status() -> dict:
    """
    Get the current status of the notification scheduler.
    
    Returns:
        Dict with scheduler status and list of scheduled jobs
    """
    try:
        from app.services.notification_scheduler import get_notification_scheduler
        
        scheduler = get_notification_scheduler()
        status = scheduler.get_job_status()
        
        return {
            "success": True,
            "scheduler": status,
        }
    except Exception as e:
        logger.error(f"Error getting scheduler status: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/preferences")
async def save_notification_preferences(request: dict, db: Session = Depends(get_db)) -> dict:
    """
    Save user notification preferences.
    
    Args:
        device_id or user_id: Identifier for the user (required)
        blessed_day_alerts: Enable/disable blessed day notifications
        daily_insights: Enable/disable daily insights
        lunar_phase_alerts: Enable/disable lunar phase updates
        motivational_quotes: Enable/disable motivational quotes
        quiet_hours_enabled: Enable quiet hours (no notifications)
        quiet_hours_start: Quiet hours start time (HH:MM format, 24h)
        quiet_hours_end: Quiet hours end time (HH:MM format, 24h)
    
    Returns:
        Saved preferences with timestamp
    """
    try:
        # Get device/user identifier
        device_id = request.get("device_id") or request.get("user_id")
        if not device_id:
            raise HTTPException(
                status_code=400,
                detail="device_id or user_id is required"
            )
        
        # Validate quiet hours format if provided
        quiet_hours_enabled = request.get("quiet_hours_enabled", False)
        if quiet_hours_enabled:
            quiet_start = request.get("quiet_hours_start")
            quiet_end = request.get("quiet_hours_end")
            if not quiet_start or not quiet_end:
                raise HTTPException(
                    status_code=400,
                    detail="quiet_hours_start and quiet_hours_end required when quiet_hours_enabled=true"
                )
            # Basic validation
            time_pattern = r"^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$"
            if not re.match(time_pattern, quiet_start):
                raise HTTPException(status_code=400, detail="Invalid quiet_hours_start format (use HH:MM)")
            if not re.match(time_pattern, quiet_end):
                raise HTTPException(status_code=400, detail="Invalid quiet_hours_end format (use HH:MM)")
        
        # Find or create notification preferences
        prefs = db.query(NotificationPreference).filter(
            NotificationPreference.device_id == device_id
        ).first()
        
        if prefs:
            # Update existing preferences
            prefs.blessed_day_alerts = request.get("blessed_day_alerts", prefs.blessed_day_alerts)
            prefs.daily_insights = request.get("daily_insights", prefs.daily_insights)
            prefs.lunar_phase_alerts = request.get("lunar_phase_alerts", prefs.lunar_phase_alerts)
            prefs.motivational_quotes = request.get("motivational_quotes", prefs.motivational_quotes)
            prefs.quiet_hours_enabled = quiet_hours_enabled
            prefs.quiet_hours_start = request.get("quiet_hours_start", prefs.quiet_hours_start)
            prefs.quiet_hours_end = request.get("quiet_hours_end", prefs.quiet_hours_end)
            prefs.updated_at = datetime.utcnow()
        else:
            # Create new preferences
            prefs = NotificationPreference(
                device_id=device_id,
                blessed_day_alerts=request.get("blessed_day_alerts", True),
                daily_insights=request.get("daily_insights", True),
                lunar_phase_alerts=request.get("lunar_phase_alerts", False),
                motivational_quotes=request.get("motivational_quotes", True),
                quiet_hours_enabled=quiet_hours_enabled,
                quiet_hours_start=request.get("quiet_hours_start", "22:00"),
                quiet_hours_end=request.get("quiet_hours_end", "06:00"),
            )
            db.add(prefs)
        
        db.commit()
        db.refresh(prefs)
        
        logger.info(f"✓ Preferences saved for {device_id}")
        
        return {
            "success": True,
            "message": "Notification preferences saved",
            "preferences": prefs.to_dict(),
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error saving preferences: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/preferences")
async def get_notification_preferences(
    device_id: Optional[str] = None, 
    user_id: Optional[str] = None,
    db: Session = Depends(get_db)
) -> dict:
    """
    Retrieve user notification preferences.
    
    Query Parameters:
        device_id or user_id: Identifier for the user (required)
    
    Returns:
        Saved preferences
    """
    try:
        identifier = device_id or user_id
        if not identifier:
            raise HTTPException(
                status_code=400,
                detail="device_id or user_id is required"
            )
        
        # Get preferences from database
        prefs = db.query(NotificationPreference).filter(
            NotificationPreference.device_id == identifier
        ).first()
        
        if prefs:
            preferences = prefs.to_dict()
        else:
            # Return defaults if not found
            preferences = {
                "device_id": identifier,
                "blessed_day_alerts": True,
                "daily_insights": True,
                "lunar_phase_alerts": False,
                "motivational_quotes": True,
                "quiet_hours_enabled": False,
                "quiet_hours_start": "22:00",
                "quiet_hours_end": "06:00",
                "updated_at": None,
            }
        
        return {
            "success": True,
            "preferences": preferences,
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving preferences: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))