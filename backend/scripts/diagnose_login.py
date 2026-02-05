#!/usr/bin/env python3
"""Detailed diagnostic of login issue."""

import requests
import json

BACKEND_URL = "https://destiny-decoder-production.up.railway.app"

def test_login():
    """Test login and get detailed error info."""
    
    print("=" * 60)
    print("TESTING LOGIN ON RAILWAY BACKEND")
    print("=" * 60)
    
    # Test 1: Check if backend is alive
    print("\n[TEST 1] Backend health check...")
    try:
        health = requests.get(f"{BACKEND_URL}/api/health", timeout=5)
        print(f"✅ Backend responding: {health.status_code}")
    except Exception as e:
        print(f"❌ Backend not responding: {e}")
        return
    
    # Test 2: Try login
    print("\n[TEST 2] Testing login request...")
    login_url = f"{BACKEND_URL}/api/auth/login"
    login_data = {
        "email": "admin@dd.com",
        "password": "admin@dd.com"
    }
    
    print(f"URL: {login_url}")
    print(f"Data: {json.dumps(login_data, indent=2)}")
    
    response = requests.post(login_url, json=login_data)
    print(f"\nResponse Status: {response.status_code}")
    print(f"Response Body: {response.text}")
    
    if response.status_code != 200:
        try:
            error_detail = response.json()
            print(f"Parsed Error: {json.dumps(error_detail, indent=2)}")
        except:
            pass
    
    # Test 3: Check if account exists by signup (duplicate check)
    print("\n[TEST 3] Testing if account exists (via signup duplicate check)...")
    signup_url = f"{BACKEND_URL}/api/auth/signup"
    signup_data = {
        "email": "admin@dd.com",
        "password": "admin@dd.com",
        "first_name": "Admin"
    }
    
    response = requests.post(signup_url, json=signup_data)
    print(f"Response Status: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 400:
        print("✅ Account exists (signup rejected as duplicate)")
    
    # Test 4: Check database directly via a simple endpoint
    print("\n[TEST 4] Testing different credentials...")
    
    # Try wrong password
    wrong_pwd = {
        "email": "admin@dd.com",
        "password": "wrongpassword"
    }
    response = requests.post(login_url, json=wrong_pwd)
    print(f"Wrong password response: {response.status_code} - {response.text}")
    
    # Try wrong email
    wrong_email = {
        "email": "wrong@example.com",
        "password": "admin@dd.com"
    }
    response = requests.post(login_url, json=wrong_email)
    print(f"Wrong email response: {response.status_code} - {response.text}")
    
    print("\n" + "=" * 60)
    print("DIAGNOSTIC COMPLETE")
    print("=" * 60)

if __name__ == "__main__":
    test_login()
