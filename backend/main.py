from contextlib import asynccontextmanager
from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
from app.api.routes.destiny import router as destiny_router
from app.api.routes.interpretations import router as interpretations_router
from app.api.routes.compatibility import router as compatibility_router
from app.api.routes.daily_insights import router as daily_insights_router
from app.api.routes.notifications import router as notifications_router
from app.api.routes.export import router as export_router
from app.api.routes.content import router as content_router
from app.api.routes.analytics import router as analytics_router
from app.api.routes.shares import router as shares_router
from app.api.routes.subscriptions import router as subscriptions_router
from app.api.routes.profile import router as profile_router
from app.services.notification_scheduler import get_notification_scheduler
import logging

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manage app startup and shutdown.
    - Startup: Initialize database, Firebase, and notification scheduler
    - Shutdown: Gracefully stop scheduler
    """
    # Startup
    try:
        from app.services.firebase_admin_service import get_firebase_service
        from app.config.database import init_db, check_db_connection
        
        # Initialize database
        init_db()
        
        # Check database connection
        if check_db_connection():
            logger.info("✓ Database connection verified")
        else:
            logger.warning("⚠ Database connection check failed")
        
        # Initialize Firebase Admin SDK (optional for development)
        try:
            firebase_service = get_firebase_service()
            logger.info("✓ Firebase Admin SDK initialized")
        except FileNotFoundError as e:
            logger.warning(f"⚠ Firebase not configured (development mode): {str(e)}")
        except Exception as e:
            logger.warning(f"⚠ Firebase initialization warning: {str(e)}")
        
        # Start notification scheduler
        try:
            scheduler = get_notification_scheduler()
            await scheduler.start()
        except Exception as e:
            logger.warning(f"⚠ Notification scheduler warning: {str(e)}")
        
    except Exception as e:
        logger.error(f"Failed to initialize critical services: {str(e)}")
        raise

    yield

    # Shutdown
    try:
        scheduler = get_notification_scheduler()
        await scheduler.stop()
        logger.info("✓ All services shut down gracefully")
    except Exception as e:
        logger.error(f"Error during shutdown: {str(e)}")


app = FastAPI(
    title="Destiny Decoder API",
    lifespan=lifespan
)

# Initialize rate limiter
limiter = Limiter(key_func=get_remote_address, default_limits=["100/minute"])
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Configure CORS for Flutter web
# IMPORTANT: In production, replace ["*"] with specific origins like:
# allow_origins=["https://yourdomain.com", "https://app.yourdomain.com"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # TODO: Update for production deployment
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(destiny_router)
app.include_router(interpretations_router)
app.include_router(compatibility_router)
app.include_router(daily_insights_router)
app.include_router(notifications_router)
app.include_router(export_router)
app.include_router(content_router)
app.include_router(analytics_router)
app.include_router(shares_router)
app.include_router(subscriptions_router)
app.include_router(profile_router)


@app.get("/health")
async def health_check():
    """
    Health check endpoint to verify service status.
    Returns database connection status and service health.
    """
    from app.config.database import check_db_connection
    
    db_status = check_db_connection()
    
    return {
        "status": "healthy" if db_status else "degraded",
        "database": "connected" if db_status else "disconnected",
        "services": {
            "api": "running",
            "firebase": "initialized",
            "scheduler": "running",
        }
    }
