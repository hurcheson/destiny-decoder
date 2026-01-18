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

# Include routers
app.include_router(destiny_router, prefix="/destiny", tags=["Destiny"])
app.include_router(interpretations_router, prefix="/interpretations", tags=["Interpretations"])
app.include_router(compatibility_router, prefix="/compatibility", tags=["Compatibility"])
app.include_router(daily_insights_router, prefix="/daily", tags=["Daily Insights"])
app.include_router(notifications_router, prefix="/notifications", tags=["Notifications"])
app.include_router(export_router, prefix="/export", tags=["Export"])
app.include_router(content_router, prefix="/content", tags=["Content"])

# Health check endpoint
@app.get("/health")
async def health():
    return {"status": "ok", "service": "Destiny Decoder API"}

if __name__ == "__main__":
    logger.info("Starting Destiny Decoder API server...")
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8001,
        log_level="info",
    )
