"""
Subscription service for managing user subscriptions and feature access.
"""
from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.orm import Session

from app.models import User, SubscriptionHistory, SubscriptionStatus, SubscriptionTier


class SubscriptionService:
    """Service for subscription management."""
    
    @staticmethod
    def check_feature_access(user: Optional[User], feature: str) -> bool:
        """
        Check if user has access to a premium feature.
        
        Args:
            user: User object (None for anonymous users)
            feature: Feature identifier
            
        Returns:
            True if user has access, False otherwise
        """
        # Anonymous users have free tier access only
        if user is None:
            return feature in ["basic_reading", "limited_pdf", "basic_compatibility"]
        
        # Check if subscription is still active
        if not user.is_premium and not user.is_pro:
            return feature in ["basic_reading", "limited_pdf", "basic_compatibility"]
        
        # Premium features
        premium_features = [
            "unlimited_readings",
            "full_interpretations",
            "unlimited_pdf",
            "detailed_compatibility",
            "advanced_analytics",
            "ad_free"
        ]
        
        # Pro-only features
        pro_features = [
            "custom_branding",
            "group_readings",
            "api_access",
            "coaching_session"
        ]
        
        if user.is_pro:
            return True  # Pro has access to everything
        
        if user.is_premium:
            return feature in premium_features
        
        return False
    
    @staticmethod
    def get_reading_limit(user: Optional[User]) -> int:
        """
        Get maximum number of saved readings for user.
        
        Returns:
            Maximum readings (-1 for unlimited)
        """
        if user is None:
            return 3  # Anonymous users: 3 readings
        
        if user.is_premium or user.is_pro:
            return -1  # Unlimited
        
        return 3  # Free tier: 3 readings
    
    @staticmethod
    def get_pdf_monthly_limit(user: Optional[User]) -> int:
        """
        Get monthly PDF export limit.
        
        Returns:
            Maximum PDFs per month (-1 for unlimited)
        """
        if user is None:
            return 1  # Anonymous: 1 per month
        
        if user.is_premium or user.is_pro:
            return -1  # Unlimited
        
        return 1  # Free tier: 1 per month
    
    @staticmethod
    def should_truncate_interpretation(user: Optional[User]) -> bool:
        """Check if interpretations should be truncated to 50 chars."""
        if user is None:
            return True  # Truncate for anonymous
        
        return not (user.is_premium or user.is_pro)
    
    @staticmethod
    def create_subscription(
        db: Session,
        user_id: str,
        tier: str,
        platform: str,
        transaction_id: str,
        duration_months: int = 1,
        price_usd: str = None
    ) -> SubscriptionHistory:
        """
        Create a new subscription.
        
        Args:
            db: Database session
            user_id: User ID
            tier: 'premium' or 'pro'
            platform: 'ios', 'android', or 'web'
            transaction_id: Platform transaction ID
            duration_months: Subscription duration in months
            price_usd: Price in USD
            
        Returns:
            SubscriptionHistory object
        """
        started_at = datetime.utcnow()
        expires_at = started_at + timedelta(days=30 * duration_months)
        
        subscription = SubscriptionHistory(
            user_id=user_id,
            tier=tier,
            status=SubscriptionStatus.ACTIVE,
            started_at=started_at,
            expires_at=expires_at,
            platform=platform,
            transaction_id=transaction_id,
            price_usd=price_usd
        )
        
        db.add(subscription)
        
        # Update user's subscription status
        user = db.query(User).filter(User.id == user_id).first()
        if user:
            user.subscription_tier = SubscriptionTier.PREMIUM if tier == "premium" else SubscriptionTier.PRO
            user.subscription_expires = expires_at
        
        db.commit()
        db.refresh(subscription)
        
        return subscription
    
    @staticmethod
    def cancel_subscription(db: Session, user_id: str) -> bool:
        """
        Cancel an active subscription.
        
        Args:
            db: Database session
            user_id: User ID
            
        Returns:
            True if cancelled, False if no active subscription
        """
        # Find active subscription
        subscription = (
            db.query(SubscriptionHistory)
            .filter(
                SubscriptionHistory.user_id == user_id,
                SubscriptionHistory.status == SubscriptionStatus.ACTIVE
            )
            .order_by(SubscriptionHistory.created_at.desc())
            .first()
        )
        
        if not subscription:
            return False
        
        # Mark as cancelled
        subscription.status = SubscriptionStatus.CANCELLED
        subscription.cancelled_at = datetime.utcnow()
        
        # Update user status (subscription remains valid until expiry)
        user = db.query(User).filter(User.id == user_id).first()
        # Don't change tier immediately - let it expire naturally
        
        db.commit()
        
        return True
    
    @staticmethod
    def validate_receipt(platform: str, receipt_data: str) -> dict:
        """
        Validate purchase receipt with platform (Apple/Google).
        
        This is a placeholder - actual implementation requires:
        - For iOS: StoreKit API calls to Apple servers
        - For Android: Google Play Developer API calls
        
        Args:
            platform: 'ios' or 'android'
            receipt_data: Base64 encoded receipt from client
            
        Returns:
            Dictionary with validation result
        """
        # TODO: Implement actual receipt validation
        # For iOS: https://developer.apple.com/documentation/appstorereceipts/verifyreceipt
        # For Android: https://developers.google.com/android-publisher/api-ref/rest/v3/purchases.subscriptions/get
        
        return {
            "valid": True,  # Placeholder
            "transaction_id": "mock_transaction_123",
            "product_id": "premium_monthly",
            "expires_date": datetime.utcnow() + timedelta(days=30)
        }
