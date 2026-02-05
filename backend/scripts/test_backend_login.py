#!/usr/bin/env python3
"""Test login for testdev@example.com account."""

import requests

BACKEND_URL = "https://destiny-decoder-production.up.railway.app"

# Test login
login_url = f"{BACKEND_URL}/api/auth/login"
data = {
    "email": "testdev@example.com",
    "password": "TestDev@12345"
}

print("Testing backend login...")
print(f"Email: {data['email']}")
print(f"Password: {data['password']}")

response = requests.post(login_url, json=data)

if response.status_code == 200:
    print("\n✅ Backend login works!")
    result = response.json()
    print(f"Token: {result['token'][:50]}...")
else:
    print(f"\n❌ Backend login failed: {response.status_code}")
    print(f"Response: {response.text}")
