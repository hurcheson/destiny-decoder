#!/usr/bin/env python3
"""Create dev account on the deployed Railway backend via API."""

import requests

# Your Railway backend URL
BACKEND_URL = "https://destiny-decoder-production.up.railway.app"

def create_account():
    """Create dev account via signup API."""
    url = f"{BACKEND_URL}/api/auth/signup"
    
    data = {
        "email": "admin@dd.com",
        "password": "admin@dd.com",
        "first_name": "Admin Dev"
    }
    
    print(f"🔄 Creating dev account on {BACKEND_URL}...")
    print(f"   Email: {data['email']}")
    
    try:
        response = requests.post(url, json=data)
        
        if response.status_code == 200:
            result = response.json()
            print(f"\n✅ Account created successfully!")
            print(f"   User ID: {result.get('user_id')}")
            print(f"   Email: {result.get('email')}")
            print(f"   Tier: {result.get('subscription_tier')}")
            print(f"\n🔑 Login Credentials:")
            print(f"   Email: {data['email']}")
            print(f"   Password: {data['password']}")
        elif response.status_code == 400 and "already registered" in response.text:
            print(f"\n✅ Account already exists on Railway!")
            print(f"   Attempting login test...")
            
            # Try logging in
            login_url = f"{BACKEND_URL}/api/auth/login"
            login_response = requests.post(login_url, json={
                "email": data['email'],
                "password": data['password']
            })
            
            if login_response.status_code == 200:
                print(f"   ✅ Login successful!")
                result = login_response.json()
                print(f"   User ID: {result.get('user_id')}")
            else:
                print(f"   ❌ Login failed: {login_response.status_code}")
                print(f"   Response: {login_response.text}")
        else:
            print(f"\n❌ Failed to create account")
            print(f"   Status: {response.status_code}")
            print(f"   Response: {response.text}")
            
    except Exception as e:
        print(f"\n❌ Error: {e}")

if __name__ == "__main__":
    create_account()
