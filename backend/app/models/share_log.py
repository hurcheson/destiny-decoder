"""
ShareLog model for tracking social shares of readings and life seal cards.
"""
from sqlalchemy import Column, String, DateTime, Integer, ForeignKey
from sqlalchemy.orm import relationship
from datetime import datetime
from app.config.database import Base


class ShareLog(Base):
    """
    Represents a share event when user shares their reading or life seal card.
    Tracks which platform, when, and what content was shared.
    """
    __tablename__ = "share_logs"

    # Primary key
    id = Column(Integer, primary_key=True, index=True)
    
    # Foreign key to device
    device_id = Column(String(255), ForeignKey("devices.device_id", ondelete="CASCADE"), nullable=False, index=True)
    
    # Life seal number being shared (from reading)
    life_seal_number = Column(Integer, nullable=False, index=True)
    
    # Platform shared to: whatsapp, instagram, twitter, copy_clipboard, other
    platform = Column(String(50), nullable=False, index=True)
    
    # Optional: short text preview that was shared
    share_text = Column(String(500), nullable=True)
    
    # Timestamp of share
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    
    # Relationship to device
    device = relationship(
        "Device",
        foreign_keys=[device_id]
    )

    def __repr__(self):
        return f"<ShareLog(id={self.id}, device={self.device_id}, life_seal={self.life_seal_number}, platform={self.platform})>"
    
    def to_dict(self):
        """Convert share log to dictionary."""
        return {
            "id": self.id,
            "device_id": self.device_id,
            "life_seal_number": self.life_seal_number,
            "platform": self.platform,
            "share_text": self.share_text,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
