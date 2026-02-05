#!/usr/bin/env python3
"""Clean up and recreate dev account on Railway."""

import requests
import json

BACKEND_URL = "https://destiny-decoder-production.up.railway.app"

def cleanup_and_create():
    """
    The issue: Multiple accounts with admin@dd.com exist on Railway
    with different password hashes, causing login to fail.
    
    Solution: Create a fresh account from scratch.
    """
    
    print("=" * 70)
    print("RAILWAY DATABASE CLEANUP & FRESH ACCOUNT CREATION")
    print("=" * 70)
    
    # Step 1: Create a completely new account with a fresh password
    print("\n[STEP 1] Creating fresh dev account...")
    
    signup_url = f"{BACKEND_URL}/api/auth/signup"
    signup_data = {
        "email": "dev@dd.test",  # Use temp email
        "password": "test@123456",
        "first_name": "Dev Test"
    }
    
    response = requests.post(signup_url, json=signup_data)
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Created temp account: dev@dd.test")
        print(f"   User ID: {result['user_id']}")
        print(f"   Token: {result['token'][:50]}...")
    else:
        print(f"❌ Failed to create temp account: {response.status_code}")
        print(f"   {response.text}")
        return
    
    # Step 2: Use admin API or direct approach
    # Since we can't access Railway DB directly, let's use a different approach
    # Create the account with a simple, testable password
    
    print("\n[STEP 2] Creating admin@dd.com account with fresh password...")
    
    admin_data = {
        "email": "admin@dd.com",
        "password": "Dev@12345",  # Stronger password for testing
        "first_name": "Admin"
    }
    
    response = requests.post(signup_url, json=admin_data)
    
    if response.status_code == 200:
        result = response.json()
        print(f"✅ Created fresh admin account!")
        print(f"   Email: admin@dd.com")
        print(f"   Password: Dev@12345")
        print(f"   User ID: {result['user_id']}")
        return "Dev@12345"
    elif response.status_code == 400 and "already registered" in response.text:
        print(f"⚠️  Account already exists. Cannot recreate (no delete endpoint).")
        print(f"   This is the core issue - multiple password hashes for same email")
        print(f"   Recommended solution:")
        print(f"   1. Contact Railway to manually delete the user from DB, OR")
        print(f"   2. Use a different test email (dev@test.com, qa@test.com, etc.)")
        return None
    else:
        print(f"❌ Unexpected error: {response.status_code}")
        print(f"   {response.text}")
        return None
    
    # Step 3: Test login with new password
    print("\n[STEP 3] Testing login with new password...")
    
    login_url = f"{BACKEND_URL}/api/auth/login"
    login_data = {
        "email": "admin@dd.com",
        "password": password if (password := cleanup_and_create.__dict__.get('password')) else "Dev@12345"
    }
    
    response = requests.post(login_url, json=login_data)
    if response.status_code == 200:
        print(f"✅ Login successful!")
    else:
        print(f"❌ Login failed: {response.status_code}")
        print(f"   {response.text}")

if __name__ == "__main__":
    cleanup_and_create()
    
    print("\n" + "=" * 70)
    print("NOTES:")
    print("=" * 70)
    print("""
The root cause: Railway's database has the admin@dd.com account with an
OLD password hash from when we created it with SHA256 (before bcrypt
was installed).

The signup endpoint has a duplicate check, but if Railway's DB already has
the account, trying to signup again creates a NEW account with a DIFFERENT
password hash, causing confusion.

Solutions:
1. Contact Railway support to manually delete the corrupted user
2. Use a different email for testing (better approach)
3. Add a password reset endpoint to the backend
4. Add an admin delete endpoint

Recommendation: Use dev@test.com instead of admin@dd.com for testing
""")
