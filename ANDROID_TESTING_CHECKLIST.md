# Android Testing Checklist for Freemium Paywall

**Status:** ✅ Ready for Setup  
**Date:** January 18, 2026  
**Purpose:** Quick reference for Android testing setup

---

## 📋 Pre-Testing Checklist

### Code Configuration
- [ ] `android/app/build.gradle.kts` has `billing:7.0.0` dependency
- [ ] `android/app/src/main/AndroidManifest.xml` has `com.android.vending.BILLING` permission
- [ ] `lib/core/config/android_config.dart` created and configured
- [ ] `lib/core/iap/subscription_manager.dart` updated with EnvironmentConfig import
- [ ] All dependencies: `flutter pub get`

### Backend Ready
- [ ] Backend installed and tested locally
- [ ] Can start: `cd backend && python run_server.py`
- [ ] Runs on: `http://127.0.0.1:8000`
- [ ] SQLite database ready (auto-created)

### Device/Emulator Ready
- [ ] Android Emulator running (API level 33+)
- [ ] OR Physical device with USB debugging enabled
- [ ] Device has Google Play Store app
- [ ] Connected to wifi/network

### Google Play Console Setup
- [ ] Created project: "Destiny Decoder"
- [ ] Created application
- [ ] Created subscription products:
  - [ ] `destiny_decoder_premium_monthly` ($2.99/month)
  - [ ] `destiny_decoder_premium_annual` ($24.99/year)
  - [ ] `destiny_decoder_pro_annual` ($49.99/year)
- [ ] Added test account (e.g., test1@gmail.com)
- [ ] Added yourself as license tester

### Account Setup on Device
- [ ] Signed in to Google Play with test account
- [ ] Test account shows in Play Store
- [ ] Can see "Test Card" payment method

---

## 🚀 Step-by-Step Testing

### Step 1: Start Backend (Terminal 1)
```bash
cd backend
python run_server.py

# Expected output:
# Uvicorn running on http://127.0.0.1:8000
# ✓ Database connection verified
# ✓ Firebase Admin SDK initialized (optional)
```

### Step 2: Start Flutter App (Terminal 2)
```bash
cd mobile/destiny_decoder_app
flutter devices  # Verify device is listed

# For emulator:
flutter run -d emulator-5554

# For device:
flutter run -d <device_id>

# App should compile and install
```

### Step 3: Verify Paywall Loads
```
1. App opens to home screen
2. Go to Settings
3. Tap "Subscription"
4. Should see:
   ✓ Current tier: "Free"
   ✓ Pricing options: Monthly, Annual, Pro Annual
   ✓ Upgrade button available
5. No errors in Flutter console
```

### Step 4: Test Reading Limit
```
1. Go back to home
2. Create 3 readings successfully
3. Try to create 4th reading
4. Should trigger paywall with message:
   "Reading Limit Reached"
5. Paywall shows all pricing options
```

### Step 5: Test Purchase Flow
```
1. In paywall, select "Premium Annual"
2. Tap "Start Premium"
3. Google Play dialog appears
4. Shows plan details and price
5. Option to "Review" or "Continue"
6. Tap "Continue"
7. Requires confirmation
8. May ask to login if needed
9. Purchase completes
```

### Step 6: Verify Subscription Activated
```
1. Purchase dialog closes
2. Paywall may close automatically
3. Go to Settings → Subscription again
4. Should now show:
   ✓ Tier: "Premium"
   ✓ Active status
   ✓ All features unlocked
   ✓ No more limits
5. Check backend logs:
   ✓ POST /api/subscription/validate was called
   ✓ Receipt was processed
   ✓ Subscription created
   ✓ User tier updated
```

### Step 7: Test Feature Gates
```
After purchase:
1. Try to save 4th, 5th, 6th reading
   ✓ All save successfully (no paywall)
2. View interpretation
   ✓ Full text shows (not truncated)
3. Export PDF multiple times
   ✓ No limit on exports
4. View detailed compatibility
   ✓ Full analysis available
```

---

## 🔍 What to Monitor

### Flutter Console
```
✅ No red errors
✅ No network errors
✅ No Google Play errors
✅ Purchase completion message

❌ Bad: "GooglePlayHelper error"
❌ Bad: "Receipt validation failed"
❌ Bad: "SKU not found"
```

### Backend Logs
```
# Terminal with running backend

✅ POST /api/subscription/validate received
✅ Receipt data parsed
✅ User tier updated
✅ Subscription created

❌ Bad: Connection refused
❌ Bad: Receipt validation failed
❌ Bad: Database error
```

### Google Play Console
```
1. Monitor → Subscriptions
2. Should show:
   ✅ Test purchase appears
   ✅ Status: Active/Trial
   ✅ Test account listed
   ✅ SKU matches product created
```

---

## 🐛 Common Issues & Fixes

### Issue: "SKU not found in app"
```
Cause: Product ID doesn't match Google Play
Fix:
1. Check Google Play Console → Products list
2. Copy exact Product ID
3. Verify in android_config.dart matches exactly
4. Product IDs are case-sensitive!
5. Reinstall app after changing
```

### Issue: "Google Play Billing not available"
```
Cause: Device doesn't have Play Billing
Fix:
1. Verify device/emulator has Google Play Store app
2. Check: Settings → Apps → "Google Play Store" exists
3. Make sure signed in with test account
4. Try different emulator if needed
5. Check API level 33+ (minimum required)
```

### Issue: Backend receives purchase but receipt validation fails
```
Cause: Receipt format issue or validation not implemented
Fix:
1. Check backend logs for error message
2. Check receipt_data is base64 encoded
3. Check product_id matches submitted product
4. Backend TODO: Implement Apple/Google validation
5. For now: Create mock validation that always succeeds
```

### Issue: Paywall doesn't appear on 4th reading
```
Cause: Feature gate not integrated or disabled
Fix:
1. Check: Paywall trigger code is in place
2. Check: SubscriptionService.get_reading_limit() returns 3 for free
3. Check: App correctly checks limit before save
4. Verify: Feature gate code was integrated
5. Restart app and try again
```

### Issue: Emulator can't reach backend
```
Cause: Using wrong URL
❌ Wrong: http://localhost:8000
✅ Right: http://10.0.2.2:8000

Fix:
1. Check android_config.dart
2. For emulator: must use 10.0.2.2 (special alias)
3. For device on same WiFi: use machine IP (192.168.x.x:8000)
4. For different network: use deployed backend
5. Restart app after changing
```

### Issue: Receipt not being validated
```
Cause: Backend validation not implemented
Fix:
1. Check backend logs for request
2. If request received: validate_receipt() TODO needs implementation
3. For testing: create mock validator:
   - Always return valid
   - Create fake subscription record
   - This lets you test full flow
4. Later: implement real Apple/Google validation
```

---

## ✅ Success Indicators

### Successful Test Complete When:
- ✅ Paywall appears on reading limit
- ✅ Google Play dialog opens
- ✅ Test purchase completes
- ✅ Backend receives receipt
- ✅ Subscription created in database
- ✅ User tier updated to "Premium"
- ✅ Paywall closes and features unlock
- ✅ Settings shows "Premium" tier
- ✅ Can perform unlimited actions

---

## 📊 Test Scenarios

### Scenario 1: Basic Purchase
```
Free user → Save 3 readings
           → Try 4th reading
           → Paywall appears
           → Complete purchase
           → Unlimited readings work ✓
```

### Scenario 2: Multiple Products
```
Show paywall → Try monthly ($2.99)
            → Try annual ($24.99)
            → Try pro ($49.99)
            → All should work ✓
```

### Scenario 3: Cancellation
```
Premium user → Settings → Subscription
            → Cancel Subscription
            → Status shows "Cancelled"
            → But access retained until expiry ✓
```

### Scenario 4: Restore Purchases
```
Premium user → Uninstall app
            → Reinstall app
            → Settings → Restore Purchases
            → Sign in with test account
            → Premium restored ✓
```

---

## 📱 Quick Commands

```bash
# Start backend
cd backend && python run_server.py

# Check emulator is running
adb devices

# Install and run app
cd mobile/destiny_decoder_app
flutter pub get
flutter run -d emulator-5554

# View logs
flutter logs

# Check network requests
# Monitor Firebase Console or use proxy tool
```

---

## 🎯 Next Steps After Testing

1. **Works locally?** → Great!
2. **Purchase succeeds?** → Implement backend receipt validation
3. **All features work?** → Deploy backend to production
4. **Ready to launch?** → Submit to Google Play

---

## 📞 Debug Info to Collect

If something fails, collect:
```
1. Full error message (screenshot)
2. Backend logs (paste last 50 lines)
3. Flutter logs (flutter logs > logs.txt)
4. Test account email used
5. SKU that failed
6. Device/Emulator details
7. Google Play product ID created
8. Network connectivity
```

---

**Android testing ready! Let's go! 🚀**

