#!/usr/bin/env python3
"""Test the compatibility PDF endpoint"""

import requests

url = "http://127.0.0.1:8000/export/compatibility/pdf"
data = {
    "person_a": {
        "full_name": "John Smith",
        "year_of_birth": 1990,
        "month_of_birth": 5,
        "day_of_birth": 15
    },
    "person_b": {
        "full_name": "Jane Doe",
        "year_of_birth": 1992,
        "month_of_birth": 8,
        "day_of_birth": 20
    }
}

try:
    response = requests.post(url, json=data)
    print(f"Status: {response.status_code}")
    print(f"Headers: {response.headers}")
    
    if response.status_code == 200:
        with open("test_compatibility_output.pdf", "wb") as f:
            f.write(response.content)
        print(f"PDF saved! Size: {len(response.content)} bytes")
    else:
        print(f"Error: {response.text}")
except Exception as e:
    print(f"Request failed: {e}")
