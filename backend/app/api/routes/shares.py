"""
Share tracking endpoints for logging and retrieving social share statistics.
"""
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy import func
from datetime import datetime, timedelta
from app.config.database import get_db
from app.models.share_log import ShareLog
from app.models.device import Device
from pydantic import BaseModel

router = APIRouter(prefix="/api/shares", tags=["shares"])


class ShareEventRequest(BaseModel):
    """Request model for logging a share event."""
    device_id: str
    life_seal_number: int
    platform: str  # whatsapp, instagram, twitter, copy_clipboard, other
    share_text: str = None


class ShareEventResponse(BaseModel):
    """Response model for a share event."""
    id: int
    device_id: str
    life_seal_number: int
    platform: str
    share_text: str = None
    created_at: str


class ShareStatsResponse(BaseModel):
    """Response model for share statistics."""
    life_seal_number: int = None
    total_shares: int
    shares_by_platform: dict
    unique_devices: int
    period_days: int = None


@router.post("/track", response_model=ShareEventResponse, status_code=201)
async def track_share(
    request: ShareEventRequest,
    db: Session = Depends(get_db)
):
    """
    Log a share event when user shares reading or life seal card.
    
    Args:
        device_id: Device identifier
        life_seal_number: Life seal number being shared
        platform: Platform shared to (whatsapp, instagram, twitter, copy_clipboard)
        share_text: Optional text preview that was shared
    
    Returns:
        Created share log entry
    """
    # Verify device exists
    device = db.query(Device).filter(Device.device_id == request.device_id).first()
    if not device:
        raise HTTPException(status_code=404, detail="Device not found")
    
    # Create share log entry
    share_log = ShareLog(
        device_id=request.device_id,
        life_seal_number=request.life_seal_number,
        platform=request.platform,
        share_text=request.share_text
    )
    
    db.add(share_log)
    db.commit()
    db.refresh(share_log)
    
    return ShareEventResponse(
        id=share_log.id,
        device_id=share_log.device_id,
        life_seal_number=share_log.life_seal_number,
        platform=share_log.platform,
        share_text=share_log.share_text,
        created_at=share_log.created_at.isoformat()
    )


@router.get("/stats", response_model=ShareStatsResponse)
async def get_share_stats(
    life_seal_number: int = Query(None, description="Filter by specific life seal number"),
    days: int = Query(30, description="Days to look back (default 30)"),
    db: Session = Depends(get_db)
):
    """
    Get share statistics across all shares or for a specific life seal.
    
    Args:
        life_seal_number: Optional life seal to filter by
        days: Number of days to include in stats (default 30)
    
    Returns:
        Share statistics including total shares, breakdown by platform, unique devices
    """
    # Calculate date range
    start_date = datetime.utcnow() - timedelta(days=days)
    
    # Build base query
    query = db.query(ShareLog).filter(ShareLog.created_at >= start_date)
    
    # Filter by life seal if specified
    if life_seal_number is not None:
        query = query.filter(ShareLog.life_seal_number == life_seal_number)
    
    # Get all matching shares
    shares = query.all()
    
    # Calculate statistics
    total_shares = len(shares)
    unique_devices = len(set(s.device_id for s in shares))
    
    # Platform breakdown
    shares_by_platform = {}
    for share in shares:
        platform = share.platform or "unknown"
        shares_by_platform[platform] = shares_by_platform.get(platform, 0) + 1
    
    return ShareStatsResponse(
        life_seal_number=life_seal_number,
        total_shares=total_shares,
        shares_by_platform=shares_by_platform,
        unique_devices=unique_devices,
        period_days=days
    )


@router.get("/stats/top", response_model=dict)
async def get_top_shared(
    limit: int = Query(10, description="Number of top items to return"),
    days: int = Query(30, description="Days to look back"),
    db: Session = Depends(get_db)
):
    """
    Get the most frequently shared life seal numbers.
    
    Args:
        limit: Number of top items to return
        days: Number of days to include
    
    Returns:
        Dictionary with top life seal numbers and their share counts
    """
    start_date = datetime.utcnow() - timedelta(days=days)
    
    results = db.query(
        ShareLog.life_seal_number,
        func.count(ShareLog.id).label("share_count")
    ).filter(
        ShareLog.created_at >= start_date
    ).group_by(
        ShareLog.life_seal_number
    ).order_by(
        func.count(ShareLog.id).desc()
    ).limit(limit).all()
    
    top_shared = {str(life_seal): count for life_seal, count in results}
    
    return {
        "period_days": days,
        "top_shared": top_shared,
        "total_results": len(results)
    }
