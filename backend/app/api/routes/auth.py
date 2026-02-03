"""
Authentication routes for user sign-up, login, and token management.
Implements JWT-based auth with secure password hashing.
"""

from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from pydantic import BaseModel, EmailStr
import jwt
import bcrypt

from app.config.database import get_db
from app.config.settings import get_settings
from app.models.user import User, SubscriptionTier

router = APIRouter(prefix="/api/auth", tags=["auth"])
settings = get_settings()


# Pydantic schemas
class SignUpRequest(BaseModel):
    """User sign-up request."""
    email: EmailStr
    password: str
    first_name: str


class LoginRequest(BaseModel):
    """User login request."""
    email: EmailStr
    password: str


class AuthResponse(BaseModel):
    """Successful auth response with JWT token."""
    token: str
    user_id: str
    email: str
    subscription_tier: str
    message: str


class ErrorResponse(BaseModel):
    """Error response."""
    error: str
    details: str = None


# Password hashing utilities
def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    salt = bcrypt.gensalt(rounds=12)
    return bcrypt.hashpw(password.encode(), salt).decode()


def verify_password(password: str, hash: str) -> bool:
    """Verify password against hash."""
    return bcrypt.checkpw(password.encode(), hash.encode())


# JWT utilities
def create_jwt_token(user_id: str, email: str, expires_in_days: int = 30) -> str:
    """Create JWT token for authenticated user."""
    payload = {
        "user_id": user_id,
        "email": email,
        "exp": datetime.utcnow() + timedelta(days=expires_in_days),
        "iat": datetime.utcnow(),
    }
    token = jwt.encode(
        payload,
        settings.JWT_SECRET_KEY,
        algorithm="HS256"
    )
    return token


def verify_jwt_token(token: str) -> dict:
    """Verify JWT token and return payload."""
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=["HS256"]
        )
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired"
        )
    except jwt.InvalidTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token"
        )


# Dependency for getting current user
def get_current_user(
    token: str = None,
    db: Session = Depends(get_db)
) -> User:
    """Get authenticated user from JWT token."""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No token provided"
        )
    
    payload = verify_jwt_token(token)
    user_id = payload.get("user_id")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user


@router.post("/signup", response_model=AuthResponse)
async def signup(request: SignUpRequest, db: Session = Depends(get_db)):
    """
    Create new user account.
    
    **Request Body:**
    - email: Valid email address
    - password: At least 8 characters
    - first_name: User's first name
    
    **Response:**
    - token: JWT token for authenticated requests
    - user_id: Unique user ID
    - subscription_tier: "free" (default for new users)
    """
    # Validate email format and uniqueness
    existing_user = db.query(User).filter(User.email == request.email).first()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Validate password strength
    if len(request.password) < 8:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Password must be at least 8 characters"
        )
    
    # Create new user
    password_hash = hash_password(request.password)
    new_user = User(
        email=request.email,
        password_hash=password_hash,
        subscription_tier=SubscriptionTier.FREE
    )
    
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    # Generate JWT token
    token = create_jwt_token(new_user.id, new_user.email)
    
    return AuthResponse(
        token=token,
        user_id=new_user.id,
        email=new_user.email,
        subscription_tier=SubscriptionTier.FREE.value,
        message="Account created successfully. Welcome to Destiny Decoder!"
    )


@router.post("/login", response_model=AuthResponse)
async def login(request: LoginRequest, db: Session = Depends(get_db)):
    """
    Authenticate user and return JWT token.
    
    **Request Body:**
    - email: User's registered email
    - password: User's password
    
    **Response:**
    - token: JWT token for authenticated requests
    - user_id: Unique user ID
    - subscription_tier: User's current subscription tier
    """
    # Find user by email
    user = db.query(User).filter(User.email == request.email).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Verify password
    if not verify_password(request.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Generate JWT token
    token = create_jwt_token(user.id, user.email)
    
    return AuthResponse(
        token=token,
        user_id=user.id,
        email=user.email,
        subscription_tier=user.subscription_tier.value,
        message=f"Welcome back, {user.email}!"
    )


@router.get("/verify")
async def verify_token(token: str = None):
    """
    Verify JWT token validity and return user info.
    
    **Query Parameters:**
    - token: JWT token to verify
    
    **Response:**
    - valid: Boolean indicating if token is valid
    - user_id: User ID if token is valid
    """
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No token provided"
        )
    
    try:
        payload = verify_jwt_token(token)
        return {
            "valid": True,
            "user_id": payload.get("user_id"),
            "email": payload.get("email")
        }
    except HTTPException:
        raise


@router.post("/refresh")
async def refresh_token(token: str = None, db: Session = Depends(get_db)):
    """
    Refresh expiring JWT token.
    
    **Query Parameters:**
    - token: Existing JWT token
    
    **Response:**
    - token: New JWT token
    """
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No token provided"
        )
    
    payload = verify_jwt_token(token)
    user_id = payload.get("user_id")
    
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Generate new token
    new_token = create_jwt_token(user.id, user.email)
    
    return {
        "token": new_token,
        "message": "Token refreshed successfully"
    }
