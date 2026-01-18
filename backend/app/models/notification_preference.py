"""
NotificationPreference model for storing user notification settings.
"""
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class NotificationPreference(Base):
    """
    Stores notification preferences for each device.
    Controls which types of notifications the user wants to receive.
    """
    __tablename__ = "notification_preferences"

    # Foreign key to device
    device_id = Column(String(255), ForeignKey("devices.device_id", ondelete="CASCADE"), primary_key=True)
    
    # Notification type preferences
    blessed_day_alerts = Column(Boolean, default=True, nullable=False)
    daily_insights = Column(Boolean, default=True, nullable=False)
    lunar_phase_alerts = Column(Boolean, default=False, nullable=False)
    motivational_quotes = Column(Boolean, default=True, nullable=False)
    
    # Quiet hours configuration
    quiet_hours_enabled = Column(Boolean, default=False, nullable=False)
    quiet_hours_start = Column(String(5), default="22:00", nullable=False)  # HH:MM format
    quiet_hours_end = Column(String(5), default="06:00", nullable=False)    # HH:MM format
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationship back to device
    device = relationship("Device", back_populates="notification_preference")

    def __repr__(self):
        return f"<NotificationPreference(device_id={self.device_id})>"
    
    def to_dict(self):
        """Convert preferences to dictionary."""
        return {
            "device_id": self.device_id,
            "blessed_day_alerts": self.blessed_day_alerts,
            "daily_insights": self.daily_insights,
            "lunar_phase_alerts": self.lunar_phase_alerts,
            "motivational_quotes": self.motivational_quotes,
            "quiet_hours_enabled": self.quiet_hours_enabled,
            "quiet_hours_start": self.quiet_hours_start,
            "quiet_hours_end": self.quiet_hours_end,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
