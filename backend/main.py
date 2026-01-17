from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes.destiny import router as destiny_router
from app.api.routes.interpretations import router as interpretations_router
from app.api.routes.compatibility import router as compatibility_router
from app.api.routes.daily_insights import router as daily_insights_router
from app.api.routes.notifications import router as notifications_router
from app.api.routes.export import router as export_router
from app.services.notification_scheduler import get_notification_scheduler
import logging

logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manage app startup and shutdown.
    - Startup: Initialize Firebase and start notification scheduler
    - Shutdown: Gracefully stop scheduler
    """
    # Startup
    try:
        from app.services.firebase_admin_service import get_firebase_service
        
        # Initialize Firebase Admin SDK
        firebase_service = get_firebase_service()
        logger.info("✓ Firebase Admin SDK initialized")
        
        # Start notification scheduler
        scheduler = get_notification_scheduler()
        await scheduler.start()
        
    except Exception as e:
        logger.error(f"Failed to initialize services: {str(e)}")
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
