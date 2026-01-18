"""
API routes for subscription management.
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

from app.config.database import get_db
from app.models import User, SubscriptionHistory
from app.services.subscription_service import SubscriptionService


router = APIRouter(prefix="/api/subscription", tags=["subscription"])


# ===== Request/Response Models =====

class SubscriptionValidateRequest(BaseModel):
    """Request model for receipt validation."""
    user_id: str = Field(..., description="User ID")
    platform: str = Field(..., description="Platform: ios, android, web")
    receipt_data: str = Field(..., description="Base64 encoded receipt from platform")
    product_id: str = Field(..., description="Product ID (e.g., premium_monthly)")


class SubscriptionStatusResponse(BaseModel):
    """Response model for subscription status."""
    user_id: str
    tier: str  # 'free', 'premium', 'pro'
    is_active: bool
    expires_at: Optional[datetime]
    features: dict


class SubscriptionHistoryResponse(BaseModel):
    """Response model for subscription history item."""
    id: str
    tier: str
    status: str
    started_at: datetime
    expires_at: datetime
    cancelled_at: Optional[datetime]
    platform: str
    price_usd: Optional[str]


class CancelSubscriptionRequest(BaseModel):
    """Request model for cancelling subscription."""
    user_id: str = Field(..., description="User ID")


# ===== Endpoints =====

@router.post("/validate", status_code=status.HTTP_201_CREATED)
async def validate_subscription(
    request: SubscriptionValidateRequest,
    db: Session = Depends(get_db)
):
    """
    Validate purchase receipt with Apple/Google and create subscription.
    
    Workflow:
    1. Validate receipt with platform API
    2. Extract transaction details
    3. Create/update subscription in database
    4. Return subscription status
    """
    try:
        # Validate receipt with platform
        validation_result = SubscriptionService.validate_receipt(
            request.platform,
            request.receipt_data
        )
        
        if not validation_result.get("valid"):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid receipt"
            )
        
        # Extract subscription details
        transaction_id = validation_result.get("transaction_id")
        expires_date = validation_result.get("expires_date")
        
        # Determine tier from product_id
        tier = "premium" if "premium" in request.product_id else "pro"
        
        # Calculate duration
        duration_months = 1 if "monthly" in request.product_id else 12
        
        # Get price
        price_map = {
            "premium_monthly": "2.99",
            "premium_annual": "24.99",
            "pro_annual": "49.99"
        }
        price_usd = price_map.get(request.product_id)
        
        # Create subscription
        subscription = SubscriptionService.create_subscription(
            db=db,
            user_id=request.user_id,
            tier=tier,
            platform=request.platform,
            transaction_id=transaction_id,
            duration_months=duration_months,
            price_usd=price_usd
        )
        
        return {
            "success": True,
            "message": "Subscription activated",
            "subscription": {
                "id": subscription.id,
                "tier": subscription.tier,
                "expires_at": subscription.expires_at.isoformat(),
                "status": subscription.status.value
            }
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process subscription: {str(e)}"
        )


@router.get("/status/{user_id}", response_model=SubscriptionStatusResponse)
async def get_subscription_status(
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    Get current subscription status for a user.
    
    Returns subscription tier, expiry date, and available features.
    """
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Determine available features
    features = {
        "unlimited_readings": SubscriptionService.check_feature_access(user, "unlimited_readings"),
        "full_interpretations": SubscriptionService.check_feature_access(user, "full_interpretations"),
        "unlimited_pdf": SubscriptionService.check_feature_access(user, "unlimited_pdf"),
        "detailed_compatibility": SubscriptionService.check_feature_access(user, "detailed_compatibility"),
        "advanced_analytics": SubscriptionService.check_feature_access(user, "advanced_analytics"),
        "ad_free": SubscriptionService.check_feature_access(user, "ad_free"),
        "reading_limit": SubscriptionService.get_reading_limit(user),
        "pdf_monthly_limit": SubscriptionService.get_pdf_monthly_limit(user)
    }
    
    return SubscriptionStatusResponse(
        user_id=user.id,
        tier=user.subscription_tier.value,
        is_active=user.is_premium or user.is_pro,
        expires_at=user.subscription_expires,
        features=features
    )


@router.post("/cancel")
async def cancel_subscription(
    request: CancelSubscriptionRequest,
    db: Session = Depends(get_db)
):
    """
    Cancel an active subscription.
    
    Note: User retains access until expiry date.
    """
    success = SubscriptionService.cancel_subscription(db, request.user_id)
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No active subscription found"
        )
    
    return {
        "success": True,
        "message": "Subscription cancelled. Access remains until expiry date."
    }


@router.get("/history/{user_id}", response_model=List[SubscriptionHistoryResponse])
async def get_subscription_history(
    user_id: str,
    db: Session = Depends(get_db)
):
    """
    Get subscription history for a user.
    
    Returns list of all past and current subscriptions.
    """
    subscriptions = (
        db.query(SubscriptionHistory)
        .filter(SubscriptionHistory.user_id == user_id)
        .order_by(SubscriptionHistory.created_at.desc())
        .all()
    )
    
    return [
        SubscriptionHistoryResponse(
            id=sub.id,
            tier=sub.tier,
            status=sub.status.value,
            started_at=sub.started_at,
            expires_at=sub.expires_at,
            cancelled_at=sub.cancelled_at,
            platform=sub.platform,
            price_usd=sub.price_usd
        )
        for sub in subscriptions
    ]


@router.get("/features")
async def get_feature_list():
    """
    Get list of all features and their tier requirements.
    
    Useful for displaying feature comparison tables.
    """
    return {
        "free": {
            "tier": "free",
            "price": "$0",
            "features": [
                "3 saved readings",
                "Basic interpretations (truncated)",
                "1 PDF export per month (1-page)",
                "Compatibility score only",
                "Basic daily insights"
            ]
        },
        "premium": {
            "tier": "premium",
            "price": "$2.99/month or $24.99/year",
            "features": [
                "Unlimited saved readings",
                "Full interpretation text",
                "Unlimited PDF exports (4-page professional)",
                "Detailed compatibility analysis",
                "Advanced analytics & tracking",
                "Ad-free experience",
                "Priority email support (24h)"
            ]
        },
        "pro": {
            "tier": "pro",
            "price": "$49.99/year",
            "features": [
                "Everything in Premium",
                "Custom PDF branding",
                "Group readings (up to 10 people)",
                "API access for integrations",
                "1-on-1 coaching session (30 min)",
                "Early access to new features",
                "AI-powered insights"
            ]
        }
    }
