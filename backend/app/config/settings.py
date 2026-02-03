"""
Application settings and configuration.
"""
from pydantic_settings import BaseSettings
import os


class Settings(BaseSettings):
    """Application settings from environment variables."""
    
    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite:///./destiny_decoder.db"
    )
    
    # JWT Configuration
    JWT_SECRET_KEY: str = os.getenv(
        "JWT_SECRET_KEY",
        "your-secret-key-change-this-in-production"  # WARNING: Change in production!
    )
    JWT_ALGORITHM: str = "HS256"
    JWT_EXPIRATION_HOURS: int = 24 * 30  # 30 days
    
    # Firebase
    FIREBASE_CREDENTIALS_PATH: str = os.getenv(
        "FIREBASE_CREDENTIALS_PATH",
        "./firebase-credentials.json"
    )
    
    # API Configuration
    API_TITLE: str = "Destiny Decoder API"
    API_VERSION: str = "1.0.0"
    API_RATE_LIMIT: str = "100/minute"
    
    # Feature Flags
    ENABLE_ANALYTICS: bool = os.getenv("ENABLE_ANALYTICS", "true").lower() == "true"
    ENABLE_NOTIFICATIONS: bool = os.getenv("ENABLE_NOTIFICATIONS", "true").lower() == "true"
    ENABLE_FIREBASE: bool = os.getenv("ENABLE_FIREBASE", "true").lower() == "true"
    
    # Environment
    ENVIRONMENT: str = os.getenv("ENVIRONMENT", "development")
    DEBUG: bool = ENVIRONMENT == "development"
    
    class Config:
        env_file = ".env"


def get_settings() -> Settings:
    """Get application settings singleton."""
    return Settings()
