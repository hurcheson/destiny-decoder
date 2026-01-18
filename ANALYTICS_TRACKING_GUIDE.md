# Analytics & Referral Tracking

## Overview

Tracks share events and referral clicks to measure viral growth and content engagement.

## Endpoints

### POST `/analytics/share-events`

Records when a user shares content (Life Seal or Article).

**Request Body:**
```json
{
  "event_type": "life_seal" | "article" | "reading",
  "life_seal_number": 7,
  "slug": "life-seal-7-the-seeker",
  "ref_code": "abc12345",
  "source": "app"
}
```

### POST `/analytics/referral-clicks`

Records when someone clicks a shared link with a ref code.

**Request Body:**
```json
{
  "ref_code": "abc12345",
  "target": "articles/life-seal-7-the-seeker",
  "user_agent": "Mozilla/5.0..."
}
```

## Data Storage

Events are stored as JSONL (JSON Lines) in:
- `backend/app/data/analytics_share_events.jsonl`
- `backend/app/data/referral_clicks.jsonl`

Each event includes an ISO 8601 timestamp.

## Mobile Integration

The Flutter app automatically:
1. Generates a unique 8-character `refCode` on every share/copy action
2. Appends UTM parameters and `ref` to shared links (when `APP_SHARE_URL` is set)
3. Tracks the event via `AnalyticsApiClient` (fire-and-forget, won't block UI)

**Example Share Message:**
```
🔮 My Life Seal: #7 - The Seeker

...

Get the app: https://your-landing.page?ref=abc12345&utm_source=share&utm_medium=app&utm_campaign=life_seal
```

## Usage

### Run with Share URL (for tracking)
```bash
flutter run --dart-define=APP_SHARE_URL=https://your-landing.page
```

### Query Analytics Data
```python
import json

with open('backend/app/data/analytics_share_events.jsonl') as f:
    events = [json.loads(line) for line in f]
    
# Count shares by type
from collections import Counter
print(Counter(e['event_type'] for e in events))

# Find top referral codes
ref_counts = Counter(e.get('ref_code') for e in events if e.get('ref_code'))
print(ref_counts.most_common(10))
```

## Future Enhancements

- Dashboard UI to visualize share metrics
- Deep link handling to redirect users from `ref` links to in-app content
- Conversion tracking (install → share click)
- Segment analysis (which Life Seals get shared most?)
