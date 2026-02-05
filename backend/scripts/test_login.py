#!/usr/bin/env python3
"""Test login verification for dev account."""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.config.database import SessionLocal
from app.models.user import User
from app.api.routes.auth import verify_password
import bcrypt

db = SessionLocal()

try:
    user = db.query(User).filter(User.email == 'admin@dd.com').first()
    
    if not user:
        print("❌ User not found!")
        exit(1)
    
    print(f"✅ User found: {user.email}")
    print(f"   User ID: {user.id}")
    print(f"   Hash length: {len(user.password_hash)}")
    print(f"   Hash preview: {user.password_hash[:30]}...")
    print(f"   Is bcrypt format: {user.password_hash.startswith('$2b$')}")
    
    # Test direct bcrypt verification
    password = "admin@dd.com"
    direct_check = bcrypt.checkpw(password.encode(), user.password_hash.encode())
    print(f"\n🔑 Direct bcrypt check: {direct_check}")
    
    # Test using auth module function
    auth_check = verify_password(password, user.password_hash)
    print(f"🔑 Auth module check: {auth_check}")
    
    if not auth_check:
        print("\n❌ Password verification FAILED")
        print("   Attempting to fix by recreating hash...")
        
        # Create new hash
        new_hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()
        print(f"   New hash: {new_hash[:30]}...")
        
        # Verify new hash works
        new_check = bcrypt.checkpw(password.encode(), new_hash.encode())
        print(f"   New hash verification: {new_check}")
        
        if new_check:
            # Update in database
            from app.config.database import engine
            import sqlalchemy
            conn = engine.connect()
            conn.execute(
                sqlalchemy.text('UPDATE users SET password_hash = :hash WHERE email = :email'),
                {'hash': new_hash, 'email': 'admin@dd.com'}
            )
            conn.commit()
            print("   ✅ Database updated with working hash")
    else:
        print("\n✅ Password verification SUCCESS - Login should work!")
        
finally:
    db.close()
