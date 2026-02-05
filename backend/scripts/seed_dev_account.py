#!/usr/bin/env python3
"""
Create a dev account for testing.
Run from backend directory: python scripts/seed_dev_account.py
"""

import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.config.database import SessionLocal, engine, Base
from app.models.user import User, SubscriptionTier
import uuid
import hashlib


def create_dev_account():
    """Create a dev account in the database."""
    Base.metadata.create_all(bind=engine)
    db = SessionLocal()
    
    try:
        email = "admin@dd.com"
        password = "admin@dd.com"
        
        # Delete existing account if it exists (for recreation)
        existing = db.query(User).filter(User.email == email).first()
        if existing:
            print(f"🔄 Deleting existing dev account to recreate with proper hash...")
            db.delete(existing)
            db.commit()
        
        # Hash password using simple sha256 (or use bcrypt if available)
        try:
            import bcrypt
            password_hash = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt()).decode('utf-8')
        except ImportError:
            # Fallback to sha256 if bcrypt not available
            password_hash = hashlib.sha256(password.encode()).hexdigest()
        
        # Create new user
        new_user = User(
            id=str(uuid.uuid4()),
            email=email,
            password_hash=password_hash,
            subscription_tier=SubscriptionTier.PRO,  # Give dev account PRO tier
        )
        
        db.add(new_user)
        db.commit()
        db.refresh(new_user)
        
        print(f"✅ Dev account created successfully!")
        print(f"   Email: {email}")
        print(f"   Password: {password}")
        print(f"   User ID: {new_user.id}")
        print(f"   Tier: PRO (unlimited access)")
        
    except Exception as e:
        db.rollback()
        print(f"❌ Error creating dev account: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    create_dev_account()
