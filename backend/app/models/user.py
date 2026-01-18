"""
User model for authentication and subscription management.
"""
from sqlalchemy import Column, String, DateTime, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
import uuid

from app.config.database import Base


class SubscriptionTier(enum.Enum):
    """Subscription tier enumeration."""
    FREE = "free"
    PREMIUM = "premium"
    PRO = "pro"


class User(Base):
    """User account model."""
    __tablename__ = "users"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String, unique=True, nullable=False, index=True)
    password_hash = Column(String, nullable=False)
    
    # Subscription information
    subscription_tier = Column(
        SQLEnum(SubscriptionTier), 
        default=SubscriptionTier.FREE,
        nullable=False
    )
    subscription_expires = Column(DateTime, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    readings = relationship("Reading", back_populates="user", cascade="all, delete-orphan")
    subscription_history = relationship("SubscriptionHistory", back_populates="user")
    device = relationship("Device", back_populates="user", uselist=False)
    
    @property
    def is_premium(self) -> bool:
        """Check if user has active premium subscription."""
        if self.subscription_tier == SubscriptionTier.FREE:
            return False
        if self.subscription_expires is None:
            return False
        return datetime.utcnow() < self.subscription_expires
    
    @property
    def is_pro(self) -> bool:
        """Check if user has active pro subscription."""
        if self.subscription_tier != SubscriptionTier.PRO:
            return False
        if self.subscription_expires is None:
            return False
        return datetime.utcnow() < self.subscription_expires
    
    def __repr__(self):
        return f"<User(id={self.id}, email={self.email}, tier={self.subscription_tier.value})>"
