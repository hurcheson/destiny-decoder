"""
API routes for subscription management.
"""
import logging
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime, timedelta

from app.config.database import get_db
from app.models import User, SubscriptionHistory
from app.models.subscription_history import SubscriptionStatus
from app.models.user import SubscriptionTier
from app.services.receipt_validation_service import ReceiptValidationService
from app.core.feature_gates import get_user_from_request

logger = logging.getLogger(__name__)


router = APIRouter(prefix="/api/subscriptions", tags=["subscriptions"])


# Dependency to get current user from JWT
async def get_current_user(db: Session = Depends(get_db)) -> User:
    """Get current authenticated user from JWT token."""
    user = get_user_from_request(db)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    return user


# ===== Request/Response Models =====

class ValidateReceiptRequest(BaseModel):
    """Request model for receipt validation."""
    receipt_data: str = Field(..., description="Base64 encoded receipt from platform")
    product_id: str = Field(..., description="Product ID (e.g., destiny_decoder_premium_monthly)")
    platform: str = Field(..., description="Platform: ios or android")


class SubscriptionStatusResponse(BaseModel):
    """Response model for subscription status."""
    tier: str  # 'free', 'premium', 'pro'
    is_active: bool
    expires_at: Optional[datetime]
    auto_renew: bool
    platform: Optional[str]


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

@router.post("/validate-receipt", status_code=status.HTTP_200_OK)
async def validate_receipt(
    request: ValidateReceiptRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Validate purchase receipt with Apple/Google and activate subscription.
    
    Workflow:
    1. Validate receipt with platform API
    2. Extract transaction details
    3. Update user subscription tier
    4. Create subscription history record
    5. Return updated subscription status
    """
    try:
        logger.info(f"Validating receipt for user {current_user.id}, product {request.product_id}")
        
        # Validate receipt with platform
        validation_result = ReceiptValidationService.validate_receipt(
            platform=request.platform,
            receipt_data=request.receipt_data,
            product_id=request.product_id
        )
        
        if not validation_result.get("valid"):
            logger.warning(f"Invalid receipt: {validation_result.get('error')}")
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=validation_result.get("error", "Invalid receipt")
            )
        
        # Extract subscription details
        transaction_id = validation_result.get("transaction_id")
        original_transaction_id = validation_result.get("original_transaction_id")
        expires_date = validation_result.get("expires_date")
        purchase_date = validation_result.get("purchase_date")
        is_active = validation_result.get("is_active", True)
        
        # Determine tier from product_id
        if "premium" in request.product_id.lower():
            tier = SubscriptionTier.PREMIUM
            tier_str = "premium"
        elif "pro" in request.product_id.lower():
            tier = SubscriptionTier.PRO
            tier_str = "pro"
        else:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unknown product: {request.product_id}"
            )
        
        # Get price mapping
        price_map = {
            "destiny_decoder_premium_monthly": "4.99",
            "destiny_decoder_premium_annual": "49.99",
            "destiny_decoder_pro_annual": "99.99",
        }
        price_usd = price_map.get(request.product_id, "0.00")
        
        # Update user subscription
        current_user.subscription_tier = tier
        current_user.subscription_expires = expires_date
        db.add(current_user)
        
        # Create subscription history record
        subscription_history = SubscriptionHistory(
            user_id=current_user.id,
            tier=tier_str,
            status=SubscriptionStatus.ACTIVE if is_active else SubscriptionStatus.EXPIRED,
            started_at=purchase_date or datetime.utcnow(),
            expires_at=expires_date or (datetime.utcnow() + timedelta(days=30)),
            platform=request.platform,
            transaction_id=transaction_id,
            original_transaction_id=original_transaction_id,
            price_usd=price_usd,
            currency="USD"
        )
        db.add(subscription_history)
        db.commit()
        db.refresh(current_user)
        
        logger.info(f"✅ Subscription activated: {current_user.id} → {tier_str}")
        
        return {
            "success": True,
            "message": f"{tier_str.capitalize()} subscription activated",
            "subscription": {
                "tier": tier_str,
                "expires_at": expires_date.isoformat() if expires_date else None,
                "is_active": is_active,
                "transaction_id": transaction_id
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"❌ Error processing subscription: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process subscription: {str(e)}"
        )


@router.get("/status", response_model=SubscriptionStatusResponse)
async def get_subscription_status(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get current subscription status for authenticated user.
    
    Returns subscription tier, expiry date, and platform info.
    """
    # Get latest subscription history for platform info
    latest_subscription = (
        db.query(SubscriptionHistory)
        .filter(SubscriptionHistory.user_id == current_user.id)
        .order_by(SubscriptionHistory.created_at.desc())
        .first()
    )
    
    # Check if subscription is still active
    is_active = False
    if current_user.subscription_tier != SubscriptionTier.FREE:
        if current_user.subscription_expires:
            is_active = current_user.subscription_expires > datetime.utcnow()
        else:
            is_active = True  # Lifetime or no expiration
    
    return SubscriptionStatusResponse(
        tier=current_user.subscription_tier.value,
        is_active=is_active,
        expires_at=current_user.subscription_expires,
        auto_renew=is_active and latest_subscription is not None,
        platform=latest_subscription.platform if latest_subscription else None
    )


@router.get("/history")
async def get_subscription_history(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Get subscription history for authenticated user.
    
    Returns list of all past and current subscriptions.
    """
    subscriptions = (
        db.query(SubscriptionHistory)
        .filter(SubscriptionHistory.user_id == current_user.id)
        .order_by(SubscriptionHistory.created_at.desc())
        .all()
    )
    
    return [
        {
            "id": sub.id,
            "tier": sub.tier,
            "status": sub.status.value,
            "started_at": sub.started_at.isoformat(),
            "expires_at": sub.expires_at.isoformat(),
            "cancelled_at": sub.cancelled_at.isoformat() if sub.cancelled_at else None,
            "platform": sub.platform,
            "price_usd": sub.price_usd
        }
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
