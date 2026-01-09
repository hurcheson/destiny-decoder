"""
FCM (Firebase Cloud Messaging) token management and notification dispatch.
"""
from typing import Optional, List
from pydantic import BaseModel
from datetime import datetime


class DeviceToken(BaseModel):
    """Device push notification token."""
    token: str
    device_type: str  # ios, android, web
    created_at: datetime = datetime.now()
    active: bool = True


class NotificationDispatcher:
    """Dispatch notifications via FCM (or local fallback)."""

    def __init__(self, fcm_api_key: Optional[str] = None):
        """
        Initialize dispatcher.
        
        Args:
            fcm_api_key: Firebase Cloud Messaging API key (optional for local dev)
        """
        self.fcm_api_key = fcm_api_key
        self.tokens_db: dict[str, List[DeviceToken]] = {}  # user_id -> [tokens]

    def register_device_token(self, user_id: str, token: str, device_type: str) -> bool:
        """Register a device token for push notifications."""
        if user_id not in self.tokens_db:
            self.tokens_db[user_id] = []
        
        # Check if token already exists
        existing = next((t for t in self.tokens_db[user_id] if t.token == token), None)
        if existing:
            existing.active = True
            return True
        
        self.tokens_db[user_id].append(
            DeviceToken(token=token, device_type=device_type)
        )
        return True

    def unregister_device_token(self, user_id: str, token: str) -> bool:
        """Unregister a device token."""
        if user_id not in self.tokens_db:
            return False
        
        self.tokens_db[user_id] = [
            t for t in self.tokens_db[user_id] if t.token != token
        ]
        return True

    async def send_notification(
        self,
        user_id: str,
        title: str,
        body: str,
        data: dict = None,
    ) -> dict:
        """
        Send push notification to user's devices.
        
        Returns:
            dict with 'success', 'message', and 'sent_count'
        """
        if user_id not in self.tokens_db or not self.tokens_db[user_id]:
            return {
                "success": False,
                "message": f"No active devices for user {user_id}",
                "sent_count": 0,
            }

        active_tokens = [t for t in self.tokens_db[user_id] if t.active]
        if not active_tokens:
            return {
                "success": False,
                "message": f"No active devices for user {user_id}",
                "sent_count": 0,
            }

        # In production, call FCM API here
        # For now, log and return success (local dev mode)
        if self.fcm_api_key:
            # TODO: Call Firebase Cloud Messaging API
            # See: https://firebase.google.com/docs/cloud-messaging/send-message
            pass
        
        return {
            "success": True,
            "message": f"Notification queued for {len(active_tokens)} device(s)",
            "sent_count": len(active_tokens),
            "tokens": [t.token for t in active_tokens],
        }

    def get_user_tokens(self, user_id: str) -> List[DeviceToken]:
        """Get all active tokens for a user."""
        if user_id not in self.tokens_db:
            return []
        return [t for t in self.tokens_db[user_id] if t.active]
