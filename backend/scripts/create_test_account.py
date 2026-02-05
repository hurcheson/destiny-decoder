#!/usr/bin/env python3
"""Create a clean test account on Railway."""

import requests

BACKEND_URL = "https://destiny-decoder-production.up.railway.app"

# Create test account
signup_url = f"{BACKEND_URL}/api/auth/signup"
data = {
    "email": "testdev@example.com",
    "password": "TestDev@12345",
    "first_name": "Test"
}

response = requests.post(signup_url, json=data)

if response.status_code == 200:
    result = response.json()
    print("✅ TEST ACCOUNT CREATED")
    print("=" * 60)
    print(f"Email:    testdev@example.com")
    print(f"Password: TestDev@12345")
    print(f"User ID:  {result['user_id']}")
    print("=" * 60)
    print("\nUse these credentials to test login on the app")
    
    # Verify login works
    login_url = f"{BACKEND_URL}/api/auth/login"
    login_response = requests.post(login_url, json={
        "email": data['email'],
        "password": data['password']
    })
    
    if login_response.status_code == 200:
        print("✅ Login verified - credentials work!")
    else:
        print(f"❌ Login test failed: {login_response.status_code}")
else:
    print(f"❌ Failed to create account: {response.status_code}")
    print(f"Response: {response.text}")
