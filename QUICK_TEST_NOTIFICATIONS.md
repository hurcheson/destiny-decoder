# Quick Testing Guide - Push Notifications

## 🚀 Start Services

### 1. Start Backend
```bash
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder
uvicorn main:app
```
**Expected Output**:
```
✓ Firebase service account key found at: firebase-service-account-key.json.json
✓ Firebase Admin SDK initialized successfully
✓ Notification scheduler started
INFO: Uvicorn running on http://0.0.0.0:8000
```

### 2. Start Flutter App
```bash
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\mobile\destiny_decoder_app
flutter run --debug
```
**Expected Output**:
```
✅ Firebase initialized successfully
📱 FCM Token obtained: euY3O3CTQZyuaKYn9EgWOj:APA91bFZhAX6gKL_...
[API] -> POST http://192.168.100.197:8000/notifications/tokens/register
[API] <- 200 /notifications/tokens/register
✓ Token registered with backend
✓ FCM token registered with backend
Analytics: User property set - notification_opt_in: true
Analytics: FCM token registered
```

---

## 📱 Test 1: Check Scheduler Status

**Command**:
```powershell
(Invoke-WebRequest -Uri http://localhost:8000/notifications/scheduler/status -UseBasicParsing).Content | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response**:
```json
{
  "success": true,
  "scheduler": {
    "scheduler_running": true,
    "total_jobs": 4,
    "jobs": [
      {
        "id": "daily_insights",
        "name": "Daily Insights Notification",
        "next_run_time": "2026-01-18T06:00:00+00:00"
      },
      {
        "id": "blessed_day_alert",
        "name": "Blessed Day Alert",
        "next_run_time": "2026-01-18T08:00:00+00:00"
      },
      {
        "id": "lunar_update",
        "name": "Lunar Phase Update",
        "next_run_time": "2026-01-18T19:00:00+00:00"
      },
      {
        "id": "motivational_quote",
        "name": "Motivational Quote",
        "next_run_time": "2026-01-19T17:00:00+00:00"
      }
    ]
  }
}
```

---

## 📨 Test 2: Send Test Notification

**Get FCM Token** from app console output (copy the token after "📱 FCM Token obtained:")

**PowerShell Command**:
```powershell
$token = "YOUR_FCM_TOKEN_HERE"
$body = @{
    token = $token
    title = "Test Notification"
    body = "This is a test push notification!"
} | ConvertTo-Json
(Invoke-WebRequest -Uri http://localhost:8000/notifications/test/send -Method POST -Body $body -ContentType "application/json" -UseBasicParsing).Content | ConvertFrom-Json | ConvertTo-Json
```

**Expected Response**:
```json
{
  "success": true,
  "details": {
    "success": true,
    "message_id": "projects/destiny-decoder-6b571/messages/0:1768689645707075%06a21b8806a21b88",
    "timestamp": "2026-01-17T22:40:41.661888"
  }
}
```

**What Should Happen on Device**:
- Notification appears in Android notification center
- If app is in background: notification is shown
- If app is in foreground: message handler logs in console

---

## 📊 Test 3: Track Analytics Events

### Event: Calculate Life Seal Number
1. Open app
2. Go to "Decode" section
3. Enter birth date and name
4. Tap "Calculate"
5. Check Firebase Console → Analytics → Real-time → `calculation_completed` event
6. Verify user property `life_seal_number` is set (1-9)

**Expected Analytics Event**:
```
Event: calculation_completed
Parameters:
  life_seal_number: 5 (example)
User Properties:
  life_seal_number: 5
```

### Event: Compatibility Check
1. Go to "Compatibility" section
2. Enter two birth dates
3. Tap "Check Compatibility"
4. Check Firebase Console for `compatibility_check` event

### Event: Export PDF
1. View any result
2. Tap "Export as PDF"
3. Check Firebase Console for `pdf_export` event

---

## 🔍 Debugging Tips

### View Backend Logs
Keep backend terminal visible to see:
```
INFO: POST /notifications/tokens/register
{"fcm_token": "...", "device_type": "android", "topics": [...]}
RESPONSE: 200 OK
```

### View App Console Logs
Look for:
```
✅ Firebase initialized successfully
📱 FCM Token obtained: ...
[API] -> POST http://192.168.100.197:8000/notifications/tokens/register
[API] <- 200 /notifications/tokens/register
```

### Check Device Notifications
1. Pull down notification shade on Android
2. Scroll through recent notifications
3. Tap notification to view details
4. Watch app console for message handler logs

### Firebase Console Monitoring
1. Open Firebase Console (console.firebase.google.com)
2. Select project: `destiny-decoder-6b571`
3. Go to **Analytics** → **Real-time**
4. Perform actions in app
5. Watch events appear in real-time

---

## 🛠️ Common Issues & Fixes

### Issue: "Firebase not initialized"
**Cause**: FirebaseService.initialize() not called
**Fix**: Ensure `lib/main.dart` has FirebaseService initialization

### Issue: "Token registration failed"
**Cause**: Backend not running or network issue
**Fix**: 
1. Check backend is running: `curl http://localhost:8000/notifications/scheduler/status`
2. Check device IP: Same network as backend
3. Check FirebaseService.initialize() is called first

### Issue: "No notification received"
**Cause**: Device token not registered, notification job not triggered yet
**Fix**:
1. Check app console shows "Token registered with backend"
2. For scheduled jobs: wait until next scheduled time
3. Use test endpoint to send immediate notification

### Issue: "Permission denied for notifications"
**Cause**: Android 13+ requires runtime permission
**Fix**: 
1. Ensure permission_handler is installed
2. App should request permission on startup
3. Check device settings → Apps → Destiny Decoder → Notifications

---

## 📋 Notification Job Schedules

| Job | Time | Day | Next Run |
|-----|------|-----|----------|
| Daily Insights | 6:00 AM | Every day | 2026-01-18T06:00:00 |
| Blessed Day Alert | 8:00 AM | Every day | 2026-01-18T08:00:00 |
| Lunar Phase Update | 7:00 PM | Sunday | 2026-01-18T19:00:00 |
| Motivational Quote | 5:00 PM | Every 2 days | 2026-01-19T17:00:00 |

To test scheduled jobs, modify times in `backend/app/services/notification_scheduler.py` to trigger immediately.

---

## 🎯 Success Criteria

All of the following should be ✅:

- ✅ Backend starts without Firebase errors
- ✅ All 4 scheduler jobs show as active
- ✅ App gets FCM token on startup
- ✅ Token registration succeeds (200 OK response)
- ✅ Test notification is sent successfully (returns message_id)
- ✅ Notification appears on device
- ✅ Analytics events appear in Firebase Console
- ✅ User properties are set (life_seal_number, notification_opt_in)
- ✅ Hot reload works without crashing
- ✅ No permission errors on Android 13+

When all ✅ are green, the push notification system is fully operational!
