from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes.destiny import router as destiny_router
from app.api.routes.interpretations import router as interpretations_router

app = FastAPI(title="Destiny Decoder API")

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
