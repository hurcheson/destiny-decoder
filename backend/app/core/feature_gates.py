"""
Feature gate decorators for enforcing subscription requirements on API endpoints.
Allows fine-grained control over which subscription tiers can access which features.
"""

from functools import wraps
from fastapi import HTTPException, status, Depends
from sqlalchemy.orm import Session
from typing import Callable, List, Optional

from app.config.database import get_db
from app.models.user import User, SubscriptionTier
from app.api.routes.auth import verify_jwt_token


def get_user_from_request(request, db: Session) -> Optional[User]:
    """Extract user from request Authorization header."""
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        return None
    
    token = auth_header.replace("Bearer ", "")
    try:
        payload = verify_jwt_token(token)
        user_id = payload.get("user_id")
        user = db.query(User).filter(User.id == user_id).first()
        return user
    except Exception:
        return None


def require_subscription(*allowed_tiers: str):
    """
    Decorator to enforce subscription requirements on endpoints.
    
    Usage:
        @require_subscription("premium", "pro")
        async def get_daily_insights(user_id: str):
            # Only premium and pro users can access
            ...
    
    Args:
        *allowed_tiers: List of allowed subscription tiers (e.g., "premium", "pro", "free")
    
    Raises:
        HTTPException(403): If user's tier is not in allowed_tiers
    """
    def decorator(func: Callable):
        @wraps(func)
        async def wrapper(*args, request=None, db: Session = None, **kwargs):
            # Handle dependency injection
            if db is None:
                # Get db from dependencies if not passed
                from app.config.database import SessionLocal
                db = SessionLocal()
            
            # Extract user from request
            user = get_user_from_request(request, db)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Not authenticated"
                )
            
            # Check subscription tier
            if user.subscription_tier.value not in allowed_tiers:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail=f"This feature requires one of: {', '.join(allowed_tiers)}. "
                           f"Your tier: {user.subscription_tier.value}. Upgrade to unlock.",
                    headers={"X-Subscription-Tier": user.subscription_tier.value}
                )
            
            # Check if subscription is active (not expired)
            if user.subscription_tier != SubscriptionTier.FREE:
                if not user.is_premium and not user.is_pro:
                    raise HTTPException(
                        status_code=status.HTTP_403_FORBIDDEN,
                        detail="Your subscription has expired. Renew to continue.",
                        headers={"X-Subscription-Expired": "true"}
                    )
            
            # Call original function
            return await func(*args, request=request, db=db, **kwargs)
        
        return wrapper
    return decorator


def require_premium(func: Callable):
    """Shorthand decorator for premium-only features."""
    return require_subscription("premium", "pro")(func)


def require_pro(func: Callable):
    """Shorthand decorator for pro-only features."""
    return require_subscription("pro")(func)


class SubscriptionRequired(Exception):
    """Exception raised when user doesn't have required subscription."""
    def __init__(self, message: str, required_tier: str, user_tier: str):
        self.message = message
        self.required_tier = required_tier
        self.user_tier = user_tier
        super().__init__(self.message)


def check_subscription(user: User, required_tier: str) -> bool:
    """
    Check if user has required subscription tier.
    
    Args:
        user: User object
        required_tier: Required tier (e.g., "premium", "pro")
    
    Returns:
        bool: True if user has required tier
    """
    if required_tier == "free":
        return True
    
    if required_tier == "premium":
        return user.is_premium or user.is_pro
    
    if required_tier == "pro":
        return user.is_pro
    
    return False


def check_reading_limit(user: User, db: Session) -> tuple[bool, int]:
    """
    Check if user has exceeded monthly reading limit.
    
    Free tier: 3 readings/month
    Premium: Unlimited
    Pro: Unlimited
    
    Args:
        user: User object
        db: Database session
    
    Returns:
        tuple: (is_allowed, remaining_reads)
    """
    from datetime import datetime, timedelta
    from app.models.user import Reading
    
    # Premium and pro users have unlimited reads
    if user.subscription_tier == SubscriptionTier.PREMIUM:
        return True, 999
    if user.subscription_tier == SubscriptionTier.PRO:
        return True, 999
    
    # Check free tier limit (3 per month)
    month_ago = datetime.utcnow() - timedelta(days=30)
    
    recent_readings = db.query(Reading).filter(
        Reading.user_id == user.id,
        Reading.created_at >= month_ago
    ).count()
    
    readings_limit = 3
    remaining = max(0, readings_limit - recent_readings)
    
    return recent_readings < readings_limit, remaining
