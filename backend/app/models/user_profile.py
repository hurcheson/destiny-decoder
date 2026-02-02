"""
User Profile Model - Stores personalization data for each user.
Supports both authenticated users (future) and anonymous device-based profiles.
"""

import uuid
from datetime import datetime
from enum import Enum
from sqlalchemy import Column, String, DateTime, Integer, JSON, Boolean
from app.config.database import Base


class LifeStage(str, Enum):
    """User's current life stage for context-aware interpretations."""
    TWENTIES = "twenties"       # 18-29
    THIRTIES = "thirties"       # 30-39
    FORTIES = "forties"         # 40-49
    FIFTIES_PLUS = "fifties+"   # 50+
    UNKNOWN = "unknown"         # User hasn't specified


class SpiritualPreference(str, Enum):
    """User's preferred spiritual/religious lens for interpretations."""
    CHRISTIAN = "christian"         # Include Bible verses, Christian context
    UNIVERSAL = "universal"         # Non-denominational, spiritual but universal
    PRACTICAL = "practical"         # Focus on psychology and practical wisdom
    CUSTOM = "custom"               # User will curate their mix
    NOT_SPECIFIED = "not_specified"


class CommunicationStyle(str, Enum):
    """User's preferred interpretation style."""
    SPIRITUAL = "spiritual"     # Emphasis on spiritual growth and divine meaning
    PRACTICAL = "practical"     # Focus on actionable advice and real-world application
    BALANCED = "balanced"       # Mix of both spiritual and practical
    NOT_SPECIFIED = "not_specified"


class UserProfile(Base):
    """
    User profile storing personalization preferences.
    
    Can be device-based (anonymous, device_id only) or user-based (email + device_id).
    Enables per-user personalization across all features.
    """
    __tablename__ = "user_profiles"

    # Core identifiers
    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    device_id = Column(String(255), nullable=False, unique=True, index=True)
    user_id = Column(String, nullable=True, index=True)  # For future auth integration

    # Personal information
    first_name = Column(String(100), nullable=False)
    date_of_birth = Column(String, nullable=False)  # YYYY-MM-DD format
    life_seal = Column(Integer, nullable=True, index=True)  # 1-9 or None if not calculated yet

    # Preferences for personalization
    life_stage = Column(String(20), default=LifeStage.UNKNOWN)
    spiritual_preference = Column(String(30), default=SpiritualPreference.NOT_SPECIFIED)
    communication_style = Column(String(20), default=CommunicationStyle.NOT_SPECIFIED)
    
    # User interests for content filtering (stored as JSON list)
    # Examples: ["career", "relationships", "spirituality", "personal_growth"]
    interests = Column(JSON, nullable=True)
    
    # Notification preferences
    notification_style = Column(String(20), default="motivational")  # motivational, informational, minimal
    
    # Engagement metrics
    readings_count = Column(Integer, default=0)
    last_reading_date = Column(DateTime, nullable=True)
    has_completed_onboarding = Column(Boolean, default=False)
    has_seen_dashboard_intro = Column(Boolean, default=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    def __repr__(self):
        return (
            f"<UserProfile("
            f"id={self.id}, "
            f"device_id={self.device_id}, "
            f"name={self.first_name}, "
            f"life_seal={self.life_seal}, "
            f"spiritual={self.spiritual_preference}"
            f")>"
        )

    def to_dict(self) -> dict:
        """Convert profile to dictionary for API responses."""
        return {
            "id": self.id,
            "device_id": self.device_id,
            "first_name": self.first_name,
            "date_of_birth": self.date_of_birth,
            "life_seal": self.life_seal,
            "life_stage": self.life_stage,
            "spiritual_preference": self.spiritual_preference,
            "communication_style": self.communication_style,
            "interests": self.interests or [],
            "notification_style": self.notification_style,
            "readings_count": self.readings_count,
            "last_reading_date": self.last_reading_date.isoformat() if self.last_reading_date else None,
            "has_completed_onboarding": self.has_completed_onboarding,
            "has_seen_dashboard_intro": self.has_seen_dashboard_intro,
            "created_at": self.created_at.isoformat(),
            "updated_at": self.updated_at.isoformat(),
        }
