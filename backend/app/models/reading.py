"""
Reading model for storing user destiny readings.
"""
from sqlalchemy import Column, String, DateTime, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.config.database import Base


class Reading(Base):
    """User destiny reading storage."""
    __tablename__ = "readings"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # Reading data (full JSON blob from calculation)
    full_data = Column(JSON, nullable=False)
    
    # Quick access fields
    life_seal = Column(String, nullable=True)  # "1", "2", ... "9"
    person_name = Column(String, nullable=True)
    birth_date = Column(String, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="readings")
    
    def __repr__(self):
        return f"<Reading(id={self.id}, user_id={self.user_id}, life_seal={self.life_seal})>"
