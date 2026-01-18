"""
Subscription history model for tracking subscription changes.
"""
from sqlalchemy import Column, String, DateTime, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
import uuid

from app.config.database import Base


class SubscriptionStatus(enum.Enum):
    """Subscription status enumeration."""
    ACTIVE = "active"
    EXPIRED = "expired"
    CANCELLED = "cancelled"
    REFUNDED = "refunded"
    TRIAL = "trial"


class SubscriptionHistory(Base):
    """Subscription history tracking."""
    __tablename__ = "subscription_history"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # Subscription details
    tier = Column(String, nullable=False)  # 'premium' or 'pro'
    status = Column(SQLEnum(SubscriptionStatus), nullable=False)
    
    # Timing
    started_at = Column(DateTime, nullable=False)
    expires_at = Column(DateTime, nullable=False)
    cancelled_at = Column(DateTime, nullable=True)
    
    # Platform details
    platform = Column(String, nullable=False)  # 'ios', 'android', 'web'
    transaction_id = Column(String, nullable=True, unique=True)  # Apple/Google transaction ID
    original_transaction_id = Column(String, nullable=True)  # For renewals
    
    # Pricing
    price_usd = Column(String, nullable=True)
    currency = Column(String, default="USD")
    
    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="subscription_history")
    
    def __repr__(self):
        return f"<SubscriptionHistory(user_id={self.user_id}, tier={self.tier}, status={self.status.value})>"
