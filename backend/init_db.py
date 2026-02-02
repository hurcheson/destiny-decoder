"""
Database initialization and management script.
Run this to set up the database for the first time.
"""
import sys
import os

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.config.database import init_db, check_db_connection, engine, DATABASE_URL
from app.models import Device, NotificationPreference
from app.models.user_profile import UserProfile
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def main():
    """Initialize the database and create all tables."""
    print("=" * 60)
    print("Destiny Decoder - Database Initialization")
    print("=" * 60)
    print()
    
    print(f"Database URL: {DATABASE_URL.split('@')[-1] if '@' in DATABASE_URL else DATABASE_URL}")
    print()
    
    # Check connection first
    print("Checking database connection...")
    if not check_db_connection():
        print("❌ Failed to connect to database. Please check your DATABASE_URL.")
        return 1
    
    print("✓ Database connection successful")
    print()
    
    # Initialize database
    print("Creating tables...")
    try:
        init_db()
        print()
        print("✅ Database initialized successfully!")
        print()
        print("Tables created:")
        print("  - devices")
        print("  - notification_preferences")
        print("  - user_profiles")
        print()
        print("You can now start the server with: uvicorn backend.main:app --reload")
        return 0
    except Exception as e:
        print(f"❌ Failed to initialize database: {str(e)}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
