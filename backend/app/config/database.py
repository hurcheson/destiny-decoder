"""
Database configuration and session management using SQLAlchemy.
Supports PostgreSQL, SQLite, and other SQLAlchemy-compatible databases.
"""
from sqlalchemy import create_engine, event
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import StaticPool
import os
import logging

logger = logging.getLogger(__name__)

# Database URL from environment variable with fallback to SQLite
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "sqlite:///./destiny_decoder.db"  # Default to SQLite for easy development
)

# Handle PostgreSQL URL format from some hosting providers
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

# SQLAlchemy engine configuration
engine_kwargs = {
    "echo": False,  # Set to True for SQL query logging in development
    "pool_pre_ping": True,  # Verify connections before using them
}

# SQLite-specific configuration
if DATABASE_URL.startswith("sqlite"):
    engine_kwargs.update({
        "connect_args": {"check_same_thread": False},
        "poolclass": StaticPool,  # Use static pool for SQLite
    })
else:
    # PostgreSQL/MySQL configuration
    engine_kwargs.update({
        "pool_size": 5,  # Number of connections to maintain
        "max_overflow": 10,  # Maximum overflow connections
        "pool_recycle": 3600,  # Recycle connections after 1 hour
    })

# Create engine
engine = create_engine(DATABASE_URL, **engine_kwargs)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()


def get_db() -> Session:
    """
    Dependency function for FastAPI routes.
    Provides a database session and ensures it's closed after use.
    
    Usage:
        @router.get("/items")
        def get_items(db: Session = Depends(get_db)):
            return db.query(Item).all()
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    """
    Initialize database by creating all tables.
    Call this during application startup.
    """
    try:
        # Import all models so they're registered with Base
        from app.models.device import Device  # noqa: F401
        from app.models.notification_preference import NotificationPreference  # noqa: F401
        
        # Create all tables
        Base.metadata.create_all(bind=engine)
        logger.info(f"✓ Database initialized successfully")
        logger.info(f"  Database URL: {DATABASE_URL.split('@')[-1] if '@' in DATABASE_URL else DATABASE_URL}")
        
        # Log table creation
        table_names = Base.metadata.tables.keys()
        for table_name in table_names:
            logger.info(f"  ✓ Table created: {table_name}")
            
    except Exception as e:
        logger.error(f"✗ Failed to initialize database: {str(e)}")
        raise


def check_db_connection() -> bool:
    """
    Check if database connection is working.
    Returns True if connection successful, False otherwise.
    """
    try:
        from sqlalchemy import text
        db = SessionLocal()
        # Execute a simple query to test connection
        db.execute(text("SELECT 1"))
        db.close()
        return True
    except Exception as e:
        logger.error(f"Database connection check failed: {str(e)}")
        return False


# Enable foreign key constraints for SQLite
if DATABASE_URL.startswith("sqlite"):
    @event.listens_for(engine, "connect")
    def set_sqlite_pragma(dbapi_conn, connection_record):
        cursor = dbapi_conn.cursor()
        cursor.execute("PRAGMA foreign_keys=ON")
        cursor.close()
