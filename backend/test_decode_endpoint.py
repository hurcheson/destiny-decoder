"""
Quick test of the decode/full endpoint
"""
import requests
import json
import time

BASE_URL = "http://localhost:8001"

def test_decode():
    payload = {
        "first_name": "John",
        "other_names": "Michael",
        "full_name": "John Michael Doe",
        "day_of_birth": 15,
        "month_of_birth": 8,
        "year_of_birth": 1990
    }
    
    print("Testing /decode/full endpoint...")
    print(f"Request: {json.dumps(payload, indent=2)}\n")
    
    start = time.time()
    try:
        response = requests.post(
            f"{BASE_URL}/decode/full",
            json=payload,
            timeout=30
        )
        elapsed = time.time() - start
        
        print(f"Status: {response.status_code}")
        print(f"Time: {elapsed:.2f}s")
        
        if response.status_code == 200:
            data = response.json()
            print(f"\nLife Seal: {data['interpretations']['life_seal']['number']}")
            print(f"Soul Number: {data['interpretations']['soul_number']['number']}")
            print("✓ Success!")
        else:
            print(f"Error: {response.text}")
            
    except requests.exceptions.Timeout:
        elapsed = time.time() - start
        print(f"✗ TIMEOUT after {elapsed:.2f}s")
    except Exception as e:
        elapsed = time.time() - start
        print(f"✗ ERROR after {elapsed:.2f}s: {e}")

if __name__ == "__main__":
    test_decode()
