"""
Test script to verify database persistence.
Tests that device tokens and preferences are stored and retrieved correctly.
"""
import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.config.database import SessionLocal, init_db
from app.models.device import Device
from app.models.notification_preference import NotificationPreference
from datetime import datetime
import uuid


def test_database_persistence():
    """Test that data persists correctly."""
    print("\n" + "=" * 60)
    print("Database Persistence Test")
    print("=" * 60 + "\n")
    
    # Initialize database
    print("1. Initializing database...")
    init_db()
    print("   ✓ Database initialized\n")
    
    # Create a test device
    print("2. Creating test device...")
    db = SessionLocal()
    test_device_id = str(uuid.uuid4())
    test_token = f"test_token_{uuid.uuid4()}"
    
    device = Device(
        device_id=test_device_id,
        fcm_token=test_token,
        device_type="android",
        active=True,
        topics="daily_insights,blessed_days",
    )
    db.add(device)
    db.commit()
    print(f"   ✓ Device created: {test_device_id[:8]}...\n")
    
    # Create preferences
    print("3. Creating notification preferences...")
    prefs = NotificationPreference(
        device_id=test_device_id,
        blessed_day_alerts=True,
        daily_insights=False,
        lunar_phase_alerts=True,
        motivational_quotes=False,
        quiet_hours_enabled=True,
        quiet_hours_start="22:00",
        quiet_hours_end="06:00",
    )
    db.add(prefs)
    db.commit()
    print("   ✓ Preferences created\n")
    
    db.close()
    
    # Test retrieval
    print("4. Testing data retrieval...")
    db = SessionLocal()
    
    retrieved_device = db.query(Device).filter(
        Device.device_id == test_device_id
    ).first()
    
    if retrieved_device:
        print(f"   ✓ Device retrieved: {retrieved_device.device_type}")
        print(f"     Token: {retrieved_device.fcm_token[:20]}...")
        print(f"     Topics: {retrieved_device.topics}")
    else:
        print("   ✗ Device not found!")
        return False
    
    retrieved_prefs = db.query(NotificationPreference).filter(
        NotificationPreference.device_id == test_device_id
    ).first()
    
    if retrieved_prefs:
        print(f"   ✓ Preferences retrieved")
        print(f"     Daily insights: {retrieved_prefs.daily_insights}")
        print(f"     Quiet hours: {retrieved_prefs.quiet_hours_start} - {retrieved_prefs.quiet_hours_end}")
    else:
        print("   ✗ Preferences not found!")
        return False
    
    print("\n5. Testing relationship...")
    if retrieved_device.notification_preference:
        print("   ✓ Device-preference relationship working")
    else:
        print("   ✗ Relationship not working")
        return False
    
    # Cleanup
    print("\n6. Cleaning up test data...")
    db.delete(retrieved_prefs)
    db.delete(retrieved_device)
    db.commit()
    db.close()
    print("   ✓ Test data cleaned up\n")
    
    print("=" * 60)
    print("✅ All tests passed! Database persistence is working.")
    print("=" * 60 + "\n")
    return True


if __name__ == "__main__":
    try:
        success = test_database_persistence()
        sys.exit(0 if success else 1)
    except Exception as e:
        print(f"\n❌ Test failed with error: {str(e)}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
