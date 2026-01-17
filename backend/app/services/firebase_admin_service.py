"""
Firebase Admin Service for sending push notifications via Firebase Cloud Messaging (FCM).
Uses firebase-admin SDK with service account credentials.
"""
import os
import json
from typing import Optional, Dict, List
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, messaging
from pydantic import BaseModel


class FCMNotification(BaseModel):
    """FCM notification payload."""
    title: str
    body: str
    data: Optional[Dict[str, str]] = None
    image_url: Optional[str] = None


class FirebaseAdminService:
    """
    Singleton service for Firebase Admin SDK operations.
    Handles FCM token registration and push notification sending.
    """
    
    _instance = None
    _initialized = False

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance

    def __init__(self):
        """Initialize Firebase Admin SDK if not already initialized."""
        if FirebaseAdminService._initialized:
            return

        # Get service account key path
        service_account_path = os.getenv(
            "FIREBASE_SERVICE_ACCOUNT_KEY",
            None
        )
        
        # Try multiple paths in order
        paths_to_try = [
            service_account_path,  # Environment variable (if set)
            "firebase-service-account-key.json.json",  # Current dir (backend/)
            "firebase-service-account-key.json",  # Current dir without double .json
            "./backend/firebase-service-account-key.json.json",  # Parent dir with backend/
            "./backend/firebase-service-account-key.json",  # Parent dir with backend/ without double .json
            "/app/firebase-service-account-key.json.json",  # Docker path
        ]
        
        found_path = None
        for path in paths_to_try:
            if path and os.path.exists(path):
                found_path = path
                print(f"✓ Firebase service account key found at: {path}")
                break
        
        if not found_path:
            raise FileNotFoundError(
                f"Firebase service account key not found. Checked:\n" +
                "\n".join([f"  - {p}" for p in paths_to_try if p])
            )
        
        service_account_path = found_path

        # Initialize Firebase Admin SDK
        try:
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
            FirebaseAdminService._initialized = True
            print(f"✓ Firebase Admin SDK initialized successfully")
        except Exception as e:
            raise RuntimeError(f"Failed to initialize Firebase Admin SDK: {str(e)}")

    def send_notification(
        self,
        token: str,
        notification: FCMNotification,
        android_priority: str = "high",
    ) -> Dict:
        """
        Send a push notification to a single device.
        
        Args:
            token: FCM device token
            notification: Notification content
            android_priority: Priority level for Android (high, normal)
        
        Returns:
            Dict with success status and message ID or error
        """
        try:
            message = messaging.Message(
                token=token,
                notification=messaging.Notification(
                    title=notification.title,
                    body=notification.body,
                    image=notification.image_url,
                ),
                data=notification.data or {},
                android=messaging.AndroidConfig(
                    priority=android_priority,
                    notification=messaging.AndroidNotification(
                        title=notification.title,
                        body=notification.body,
                        image=notification.image_url,
                    ),
                ) if android_priority else None,
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=notification.title,
                                body=notification.body,
                            ),
                            mutable_content=True,
                            custom_data=notification.data or {},
                        ),
                    ),
                ),
                webpush=messaging.WebpushConfig(
                    data=notification.data or {},
                    notification=messaging.WebpushNotification(
                        title=notification.title,
                        body=notification.body,
                        icon=notification.image_url,
                    ),
                ),
            )
            
            response = messaging.send(message, dry_run=False)
            
            return {
                "success": True,
                "message_id": response,
                "timestamp": datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def send_multicast(
        self,
        tokens: List[str],
        notification: FCMNotification,
        android_priority: str = "high",
    ) -> Dict:
        """
        Send notifications to multiple devices.
        
        Args:
            tokens: List of FCM device tokens
            notification: Notification content
            android_priority: Priority level for Android
        
        Returns:
            Dict with success/failure counts and details
        """
        if not tokens:
            return {
                "success": False,
                "error": "No tokens provided",
                "successful": 0,
                "failed": 0,
            }

        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=notification.title,
                    body=notification.body,
                    image=notification.image_url,
                ),
                data=notification.data or {},
                android=messaging.AndroidConfig(
                    priority=android_priority,
                    notification=messaging.AndroidNotification(
                        title=notification.title,
                        body=notification.body,
                        image=notification.image_url,
                    ),
                ) if android_priority else None,
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            alert=messaging.ApsAlert(
                                title=notification.title,
                                body=notification.body,
                            ),
                            mutable_content=True,
                            custom_data=notification.data or {},
                        ),
                    ),
                ),
            )
            
            response = messaging.send_multicast(message)
            
            return {
                "success": response.failure_count == 0,
                "successful": response.success_count,
                "failed": response.failure_count,
                "message_ids": [r.message_id for r in response.responses if r.success],
                "errors": [
                    {"token": tokens[i], "error": str(r.exception)}
                    for i, r in enumerate(response.responses)
                    if not r.success
                ],
                "timestamp": datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "successful": 0,
                "failed": len(tokens),
                "timestamp": datetime.now().isoformat(),
            }

    def subscribe_to_topic(
        self,
        tokens: List[str],
        topic: str,
    ) -> Dict:
        """
        Subscribe device tokens to a topic.
        
        Args:
            tokens: List of FCM device tokens
            topic: Topic name (e.g., "daily_insights", "blessed_days")
        
        Returns:
            Dict with subscription result
        """
        if not tokens:
            return {
                "success": False,
                "error": "No tokens provided",
            }

        try:
            response = messaging.make_topic_management_response(
                messaging.subscribe_to_topic(tokens, topic)
            )
            
            return {
                "success": True,
                "topic": topic,
                "subscribed_count": len(tokens),
                "timestamp": datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def unsubscribe_from_topic(
        self,
        tokens: List[str],
        topic: str,
    ) -> Dict:
        """
        Unsubscribe device tokens from a topic.
        
        Args:
            tokens: List of FCM device tokens
            topic: Topic name
        
        Returns:
            Dict with unsubscription result
        """
        if not tokens:
            return {
                "success": False,
                "error": "No tokens provided",
            }

        try:
            messaging.unsubscribe_from_topic(tokens, topic)
            
            return {
                "success": True,
                "topic": topic,
                "unsubscribed_count": len(tokens),
                "timestamp": datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "timestamp": datetime.now().isoformat(),
            }

    def send_to_topic(
        self,
        topic: str,
        notification: FCMNotification,
    ) -> Dict:
        """
        Send a notification to all devices subscribed to a topic.
        
        Args:
            topic: Topic name
            notification: Notification content
        
        Returns:
            Dict with send result
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=notification.title,
                    body=notification.body,
                    image=notification.image_url,
                ),
                data=notification.data or {},
                topic=topic,
            )
            
            response = messaging.send(message)
            
            return {
                "success": True,
                "message_id": response,
                "topic": topic,
                "timestamp": datetime.now().isoformat(),
            }
        except Exception as e:
            return {
                "success": False,
                "error": str(e),
                "topic": topic,
                "timestamp": datetime.now().isoformat(),
            }


# Singleton instance
firebase_service = None


def get_firebase_service() -> FirebaseAdminService:
    """Get or create Firebase Admin Service instance."""
    global firebase_service
    if firebase_service is None:
        firebase_service = FirebaseAdminService()
    return firebase_service
