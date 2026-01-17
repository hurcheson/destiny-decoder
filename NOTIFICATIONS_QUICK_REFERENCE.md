# 📋 Push Notification System - Quick Reference Card

## 🚀 Quick Start

### Start Backend
```bash
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder
uvicorn main:app
```
**Expected**: Backend running on http://0.0.0.0:8000

### Start Flutter App
```bash
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\mobile\destiny_decoder_app
flutter run --debug
```
**Expected**: App launches with FCM token registered

---

## 🧪 Quick Tests

### Test 1: Check Scheduler (30 seconds)
```powershell
(Invoke-WebRequest http://localhost:8000/notifications/scheduler/status -UseBasicParsing).Content | ConvertFrom-Json | Select-Object success
```
**Expected**: `success: true` (all 4 jobs active)

### Test 2: Send Notification (1 minute)
```powershell
$token = "YOUR_FCM_TOKEN"
$body = @{token=$token; title="Test"; body="Hello!"} | ConvertTo-Json
(Invoke-WebRequest http://localhost:8000/notifications/test/send -Method POST -Body $body -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json
```
**Expected**: `success: true` + `message_id` (notification appears on device)

### Test 3: Check Analytics
1. Open Firebase Console: https://console.firebase.google.com
2. Select project: `destiny-decoder-6b571`
3. Go to **Analytics** → **Real-time**
4. Look for `fcm_token_registered` and `app_open` events

**Expected**: Events appear within 5 seconds

---

## 📱 Device Notification Channel

| Notification Type | Android Channel | Priority | Sound |
|-------------------|-----------------|----------|-------|
| Daily Insights | daily_insights | High | Default |
| Blessed Day Alert | blessed_days | High | Default |
| Lunar Update | lunar_phases | Normal | Silent |
| Motivational | inspirational | Normal | Silent |

---

## 🗂️ Key Files

### Backend
- [backend/app/services/firebase_admin_service.py](backend/app/services/firebase_admin_service.py) - Firebase wrapper (338 lines)
- [backend/app/services/notification_scheduler.py](backend/app/services/notification_scheduler.py) - APScheduler (142 lines)
- [backend/app/api/routes/notifications.py](backend/app/api/routes/notifications.py) - API endpoints (286 lines)
- [backend/main.py](backend/main.py) - FastAPI app with lifespan

### Flutter
- [lib/core/firebase/firebase_service.dart](mobile/destiny_decoder_app/lib/core/firebase/firebase_service.dart) - FCM management
- [lib/core/analytics/analytics_service.dart](mobile/destiny_decoder_app/lib/core/analytics/analytics_service.dart) - Analytics tracking (200+ lines)
- [lib/main.dart](mobile/destiny_decoder_app/lib/main.dart) - App initialization
- [pubspec.yaml](mobile/destiny_decoder_app/pubspec.yaml) - Dependencies

---

## 🔌 API Reference

### POST /notifications/tokens/register
```json
Request: {
  "fcm_token": "euY3O3CTQZyuaKYn9EgWOj:APA91bF...",
  "device_type": "android",
  "topics": ["daily_insights", "blessed_days"]
}
Response: {
  "success": true,
  "message": "Token registered for android",
  "token_prefix": "euY3O3CT",
  "topics_subscribed": ["daily_insights", "blessed_days"]
}
```

### POST /notifications/test/send
```json
Request: {
  "token": "euY3O3CTQZyuaKYn9EgWOj:APA91bF...",
  "title": "Test Notification",
  "body": "Message content here"
}
Response: {
  "success": true,
  "details": {
    "success": true,
    "message_id": "projects/destiny-decoder-6b571/messages/0:1768689645707075%06a21b88",
    "timestamp": "2026-01-17T22:40:41.661888"
  }
}
```

### GET /notifications/scheduler/status
```json
Response: {
  "success": true,
  "scheduler": {
    "scheduler_running": true,
    "total_jobs": 4,
    "jobs": [
      {
        "id": "daily_insights",
        "name": "Daily Insights Notification",
        "next_run_time": "2026-01-18T06:00:00+00:00",
        "trigger": "cron[hour='6', minute='0']"
      },
      ... (3 more jobs)
    ]
  }
}
```

---

## 🔥 Firebase Project Details

**Project ID**: `destiny-decoder-6b571`
**Messaging Sender ID**: `177104812289`
**Android App ID**: `1:177104812289:android:e668ecd67d6c0250b54300`
**Service Account**: `firebase-service-account-key.json.json`

**Console**: https://console.firebase.google.com/project/destiny-decoder-6b571

---

## 📊 Analytics Events

| Event | Triggered By | Parameters |
|-------|--------------|-----------|
| `app_open` | App startup | - |
| `calculation_completed` | Decode calculation | `life_seal_number` |
| `compatibility_check` | Compatibility form | - |
| `pdf_export` | PDF download | - |
| `notification_opened` | Notification tap | `type` |
| `fcm_token_registered` | Token registration | - |

---

## ⏰ Notification Schedule

| Job | Time | Frequency | Next Run |
|-----|------|-----------|----------|
| Daily Insights | 6:00 AM | Daily | 06:00 |
| Blessed Day Alert | 8:00 AM | Daily | 08:00 |
| Lunar Phase Update | 7:00 PM | Sunday | Next Sunday |
| Motivational Quote | 5:00 PM | Every 2 days | Every 2 days |

---

## 🐛 Debugging

### View Backend Logs
```bash
# Terminal showing uvicorn output
# Look for: "INFO: POST /notifications/tokens/register"
```

### View App Logs
```bash
# Flutter console in VS Code
# Look for: "FCM Token obtained:"
# Look for: "Token registered with backend"
```

### Check Device Notifications
1. Pull down notification shade
2. Swipe down for notification details
3. Look for notification from Destiny Decoder app
4. Timestamp shows when received

### Monitor Analytics
```
Firebase Console → Analytics → Real-time
Watch for events appearing in real-time as you use the app
```

---

## ✅ Health Check (< 1 minute)

Run these 3 commands to verify system health:

```powershell
# 1. Backend running
(Invoke-WebRequest http://localhost:8000/notifications/scheduler/status).StatusCode  # Should be 200

# 2. All jobs active
(Invoke-WebRequest http://localhost:8000/notifications/scheduler/status).Content | ConvertFrom-Json | Select-Object -ExpandProperty scheduler | Select-Object total_jobs  # Should be 4

# 3. App logs show token registered
# Check Flutter console for: "✓ Token registered with backend"
```

---

## 🛠️ Common Operations

### Send Manual Notification
```powershell
$token = "PASTE_FCM_TOKEN_HERE"
$body = @{token=$token; title="Test"; body="Message"} | ConvertTo-Json
Invoke-WebRequest http://localhost:8000/notifications/test/send -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
```

### View Next Scheduled Job
```powershell
(Invoke-WebRequest http://localhost:8000/notifications/scheduler/status).Content | ConvertFrom-Json | Select-Object -ExpandProperty scheduler | Select-Object -ExpandProperty jobs | Sort-Object next_run_time | Select-Object -First 1
```

### Restart Backend
```powershell
Get-Process uvicorn | Stop-Process -Force
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder
uvicorn main:app
```

### Restart App
```bash
# In Flutter terminal: q (to quit)
cd mobile/destiny_decoder_app
flutter run --debug
```

---

## 📞 Support

**Documentation**:
- Full Guide: [PUSH_NOTIFICATIONS_COMPLETE.md](PUSH_NOTIFICATIONS_COMPLETE.md)
- Testing Guide: [QUICK_TEST_NOTIFICATIONS.md](QUICK_TEST_NOTIFICATIONS.md)
- Verification: [VERIFICATION_CHECKLIST_NOTIFICATIONS.md](VERIFICATION_CHECKLIST_NOTIFICATIONS.md)

**Links**:
- Firebase Console: https://console.firebase.google.com
- Dart Docs: https://pub.dev/packages/firebase_messaging
- Python Docs: https://firebase.google.com/docs/admin/setup

---

**Last Updated**: January 17, 2026
**Status**: ✅ Production Ready
**Test Coverage**: End-to-end verified
