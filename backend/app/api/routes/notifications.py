"""
API routes for push notifications, FCM tokens, and notification preferences.
"""
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import logging

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
async def register_device_token(request: TokenRegistrationRequest) -> dict:
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
        
        firebase = get_firebase_service()
        topics_subscribed = []
        
        # Subscribe to requested topics
        if request.topics:
            for topic in request.topics:
                result = firebase.subscribe_to_topic([request.fcm_token], topic)
                if result.get("success"):
                    topics_subscribed.append(topic)
        
        # TODO: Store token in database linked to authenticated user
        logger.info(f"✓ Token registered: {request.device_type} - subscribed to {len(topics_subscribed)} topics")
        
        return {
            "success": True,
            "message": f"Token registered for {request.device_type}",
            "token_prefix": request.fcm_token[:10],
            "topics_subscribed": topics_subscribed,
        }
    except Exception as e:
        logger.error(f"Error registering token: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


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
    
    try:
        # TODO: Remove token from database
        logger.info(f"✓ Token unregistered: {fcm_token[:10]}")
        return {"success": True, "message": "Token unregistered"}
    except Exception as e:
        logger.error(f"Error unregistering token: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


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
