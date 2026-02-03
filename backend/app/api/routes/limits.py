"""
Reading limit checking endpoint.
Enforces subscription-based reading limits (3/month for free, unlimited for premium).
"""

from fastapi import APIRouter, HTTPException, status, Depends, Request
from sqlalchemy.orm import Session
from datetime import datetime, timedelta

from app.config.database import get_db
from app.models.user import User, SubscriptionTier, Reading
from app.core.feature_gates import check_reading_limit, get_user_from_request

router = APIRouter(
    prefix="/api/limits",
    tags=["limits"]
)


@router.get("/reading-check")
async def check_reading_limit_endpoint(
    request: Request,
    db: Session = Depends(get_db)
):
    """
    Check if user has remaining readings in their monthly quota.
    
    **Response:**
    - allowed: bool - Can user create a new reading?
    - remaining: int - Readings left this month
    - limit: int - Total readings allowed this month
    - reset_date: str - When the limit resets (ISO format)
    - tier: str - User's subscription tier
    
    **Error Codes:**
    - 401: Not authenticated
    - 402: Payment required (quota exceeded, needs upgrade)
    """
    # Get user from request
    user = get_user_from_request(request, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated"
        )
    
    # Check reading limit
    is_allowed, remaining = check_reading_limit(user, db)
    
    # Calculate reset date (30 days from now if free tier)
    if user.subscription_tier == SubscriptionTier.FREE:
        month_ago = datetime.utcnow() - timedelta(days=30)
        reset_date = (month_ago + timedelta(days=30)).isoformat()
        limit = 3
    else:
        reset_date = None
        limit = 999
    
    # If quota exceeded and free tier, return 402 Payment Required
    if not is_allowed and user.subscription_tier == SubscriptionTier.FREE:
        raise HTTPException(
            status_code=status.HTTP_402_PAYMENT_REQUIRED,
            detail="Reading quota exceeded. Upgrade to Premium for unlimited readings.",
            headers={
                "X-Remaining": "0",
                "X-Limit": str(limit),
                "X-Reset-Date": reset_date or "",
            }
        )
    
    return {
        "allowed": is_allowed,
        "remaining": remaining,
        "limit": limit,
        "reset_date": reset_date,
        "tier": user.subscription_tier.value,
        "message": (
            "Readings unlimited" if user.subscription_tier != SubscriptionTier.FREE
            else f"You have {remaining} reading(s) left this month"
        )
    }


@router.get("/status")
async def get_limit_status(
    request: Request,
    db: Session = Depends(get_db)
):
    """Get current subscription and reading limit status."""
    user = get_user_from_request(request, db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Not authenticated"
        )
    
    is_allowed, remaining = check_reading_limit(user, db)
    
    return {
        "subscription_tier": user.subscription_tier.value,
        "is_premium": user.is_premium,
        "is_pro": user.is_pro,
        "subscription_expires": user.subscription_expires.isoformat() if user.subscription_expires else None,
        "reading_quota": {
            "allowed": is_allowed,
            "remaining": remaining,
            "total_this_month": 999 if user.is_premium or user.is_pro else 3,
        }
    }
