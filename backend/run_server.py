"""
Temporary backend server without Firebase initialization for testing
"""
import uvicorn
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes.destiny import router as destiny_router
from app.api.routes.interpretations import router as interpretations_router
from app.api.routes.compatibility import router as compatibility_router
from app.api.routes.daily_insights import router as daily_insights_router
from app.api.routes.notifications import router as notifications_router
from app.api.routes.export import router as export_router
from app.api.routes.content import router as content_router
from app.api.routes.analytics import router as analytics_router
from app.api.routes.profile import router as profile_router

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app without lifespan management
app = FastAPI(title="Destiny Decoder API")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers (routers already define their own prefixes)
app.include_router(destiny_router)
app.include_router(interpretations_router)
app.include_router(compatibility_router)
app.include_router(daily_insights_router)
app.include_router(notifications_router)
app.include_router(export_router)
app.include_router(content_router)
app.include_router(analytics_router)
app.include_router(profile_router)

# Health check endpoint
@app.get("/health")
async def health():
    return {"status": "ok", "service": "Destiny Decoder API"}

if __name__ == "__main__":
    logger.info("Starting Destiny Decoder API server...")
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        log_level="info",
    )
