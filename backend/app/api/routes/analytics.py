from fastapi import APIRouter, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from collections import Counter, defaultdict
import json
import os

router = APIRouter(prefix="/analytics", tags=["analytics"])

# Paths
DATA_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "data")
TEMPLATES_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "templates")
SHARE_EVENTS_PATH = os.path.join(DATA_DIR, "analytics_share_events.jsonl")
REFERRAL_CLICKS_PATH = os.path.join(DATA_DIR, "referral_clicks.jsonl")

templates = Jinja2Templates(directory=TEMPLATES_DIR)

class ShareEvent(BaseModel):
    event_type: str = Field(..., description="life_seal | article | reading")
    life_seal_number: Optional[int] = None
    slug: Optional[str] = None
    platform: Optional[str] = None
    ref_code: Optional[str] = None
    source: Optional[str] = Field(default="app", description="app | web | other")

class ReferralClick(BaseModel):
    ref_code: str
    target: Optional[str] = None  # e.g. articles/<slug> or app_landing
    user_agent: Optional[str] = None


def _ensure_data_dir():
    os.makedirs(DATA_DIR, exist_ok=True)


def _append_jsonl(path: str, record: dict):
    _ensure_data_dir()
    with open(path, "a", encoding="utf-8") as f:
        f.write(json.dumps(record, ensure_ascii=False) + "\n")


@router.post("/share-events")
async def record_share_event(event: ShareEvent):
    try:
        record = event.dict()
        record["timestamp"] = datetime.utcnow().isoformat()
        _append_jsonl(SHARE_EVENTS_PATH, record)
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to record event: {e}")


@router.post("/referral-clicks")
async def record_referral_click(click: ReferralClick):
    try:
        record = click.dict()
        record["timestamp"] = datetime.utcnow().isoformat()
        _append_jsonl(REFERRAL_CLICKS_PATH, record)
        return {"status": "ok"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to record click: {e}")


def _read_jsonl(path: str) -> list:
    """Read all records from JSONL file"""
    if not os.path.exists(path):
        return []
    records = []
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if line:
                records.append(json.loads(line))
    return records


@router.get("/dashboard", response_class=HTMLResponse)
async def analytics_dashboard(request: Request):
    """Analytics dashboard showing viral growth metrics"""
    
    # Read data
    share_events = _read_jsonl(SHARE_EVENTS_PATH)
    referral_clicks = _read_jsonl(REFERRAL_CLICKS_PATH)
    
    # Calculate summary stats
    total_shares = len(share_events)
    total_clicks = len(referral_clicks)
    unique_refs = len(set(e.get("ref_code") for e in share_events if e.get("ref_code")))
    click_rate = round((total_clicks / total_shares * 100) if total_shares > 0 else 0, 1)
    
    # Share by type
    type_counts = Counter(e.get("event_type") for e in share_events)
    share_by_type_labels = list(type_counts.keys()) or ["No data"]
    share_by_type_data = list(type_counts.values()) or [0]
    
    # Timeline (group by date)
    timeline = defaultdict(int)
    for event in share_events:
        timestamp = event.get("timestamp", "")
        date = timestamp.split("T")[0] if timestamp else "Unknown"
        timeline[date] += 1
    
    sorted_dates = sorted(timeline.keys())
    timeline_labels = sorted_dates or ["No data"]
    timeline_data = [timeline[d] for d in sorted_dates] or [0]
    
    # Top content
    content_counts = Counter()
    for event in share_events:
        event_type = event.get("event_type")
        if event_type == "life_seal" and event.get("life_seal_number"):
            label = f"Life Seal {event['life_seal_number']}"
            content_counts[(label, "life_seal")] += 1
        elif event_type == "article" and event.get("slug"):
            slug = event["slug"]
            label = slug.replace("-", " ").title()
            content_counts[(label, "article")] += 1
    
    top_content = [
        {"label": label, "type": content_type, "count": count}
        for (label, content_type), count in content_counts.most_common(10)
    ]
    
    return templates.TemplateResponse("analytics_dashboard.html", {
        "request": request,
        "total_shares": total_shares,
        "total_clicks": total_clicks,
        "click_rate": click_rate,
        "unique_refs": unique_refs,
        "share_by_type_labels": json.dumps(share_by_type_labels),
        "share_by_type_data": json.dumps(share_by_type_data),
        "timeline_labels": json.dumps(timeline_labels),
        "timeline_data": json.dumps(timeline_data),
        "top_content": top_content,
    })

