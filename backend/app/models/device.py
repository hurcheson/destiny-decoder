"""
Device model for tracking FCM tokens and device information.
"""
from sqlalchemy import Column, String, DateTime, Boolean, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class Device(Base):
    """
    Represents a user device with FCM token for push notifications.
    Tracks device information and token status.
    """
    __tablename__ = "devices"

    # Primary key - unique device identifier (generated client-side)
    device_id = Column(String(255), primary_key=True, index=True)
    
    # Optional user association
    user_id = Column(String, ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    
    # FCM token for push notifications
    fcm_token = Column(String(500), unique=True, nullable=False, index=True)
    
    # Device type: android, ios, web
    device_type = Column(String(50), nullable=False, default="android")
    
    # Token status
    active = Column(Boolean, default=True, nullable=False)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    last_active = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Topics subscribed to (comma-separated for simplicity)
    # Example: "daily_insights,blessed_days,lunar_phases"
    topics = Column(String(500), default="", nullable=False)
    
    # Relationship to notification preferences
    user = relationship("User", back_populates="device")
    notification_preference = relationship(
        "NotificationPreference",
        back_populates="device",
        uselist=False,  # One-to-one relationship
        cascade="all, delete-orphan"
    )
    share_logs = relationship("ShareLog", back_populates="device", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<Device(device_id={self.device_id}, type={self.device_type}, active={self.active})>"
    
    def to_dict(self):
        """Convert device to dictionary."""
        return {
            "device_id": self.device_id,
            "fcm_token": self.fcm_token[:20] + "..." if len(self.fcm_token) > 20 else self.fcm_token,
            "device_type": self.device_type,
            "active": self.active,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "last_active": self.last_active.isoformat() if self.last_active else None,
            "topics": self.topics.split(",") if self.topics else [],
        }
