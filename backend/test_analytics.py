"""
Quick test of analytics endpoint
"""
import requests
import json

BASE_URL = "http://localhost:8001"

def test_share_event():
    response = requests.post(
        f"{BASE_URL}/analytics/share-events",
        json={
            "event_type": "life_seal",
            "life_seal_number": 7,
            "ref_code": "test1234",
            "source": "app"
        }
    )
    print(f"Share event: {response.status_code} - {response.json()}")

def test_referral_click():
    response = requests.post(
        f"{BASE_URL}/analytics/referral-clicks",
        json={
            "ref_code": "test1234",
            "target": "articles/life-seal-7-the-seeker"
        }
    )
    print(f"Referral click: {response.status_code} - {response.json()}")

def read_analytics_log():
    import os
    data_dir = "../backend/app/data"
    share_events = os.path.join(data_dir, "analytics_share_events.jsonl")
    
    if os.path.exists(share_events):
        print("\n📊 Share Events:")
        with open(share_events, 'r') as f:
            for line in f:
                print(f"  {line.strip()}")
    else:
        print("\nNo share events file yet")

if __name__ == "__main__":
    print("Testing analytics endpoints...\n")
    test_share_event()
    test_referral_click()
    read_analytics_log()
