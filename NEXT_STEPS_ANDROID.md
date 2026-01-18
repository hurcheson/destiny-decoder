# 🚀 Next Steps: Android Freemium Testing

**Status:** ✅ Code Complete | ⏳ Testing Ready  
**Last Commit:** 87bbcc6 (Android Testing Checklist added)  
**Current Phase:** User Testing & Google Play Console Setup

---

## 📌 What's Complete Right Now

### ✅ Code Infrastructure
- Backend: Complete subscription system with 5 REST endpoints
- Mobile: Complete IAP services, PaywallPage, FeatureGates
- Android manifest: Google Play Billing permission added
- Android gradle: Google Play Billing Library 7.0.0 added
- Configuration: android_config.dart with environment routing
- Guides: ANDROID_SETUP_GUIDE.md + iOS_SETUP_GUIDE.md created

### ✅ Documentation
- ANDROID_SETUP_GUIDE.md: 250+ lines with Google Play Console steps
- iOS_SETUP_GUIDE.md: 280+ lines with App Store Connect steps
- ANDROID_TESTING_CHECKLIST.md: Complete testing procedures
- Commit history: All changes tracked (commits: e1a37b3, fb0ef58, 87bbcc6)

---

## 🎯 Immediate Next Steps (Do This Now)

### Step 1: Create Google Play Products (20 minutes)
```
1. Go to Google Play Console
   → https://play.google.com/console
   
2. Select or create "Destiny Decoder" project
   → If exists: go to Products → Subscriptions
   → If not: Create new project
   
3. Create 3 subscription products:
   
   Product 1: Monthly Premium
   - Product ID: destiny_decoder_premium_monthly
   - Name: Premium Monthly
   - Price: $2.99/month (set in your region)
   - Billing Period: 1 month
   - Free trial: None (optional: add 7-day trial)
   
   Product 2: Annual Premium  
   - Product ID: destiny_decoder_premium_annual
   - Name: Premium Annual
   - Price: $24.99/year
   - Billing Period: 1 year
   - Free trial: None
   
   Product 3: Pro Annual
   - Product ID: destiny_decoder_pro_annual
   - Name: Pro Annual
   - Price: $49.99/year
   - Billing Period: 1 year
   - Free trial: None

⚠️ IMPORTANT: Product IDs are CASE-SENSITIVE
   Must match exactly in android_config.dart!
```

### Step 2: Add Test Account (5 minutes)
```
In Google Play Console:

1. Settings → Testers
   
2. Add yourself as tester:
   Settings → Your Profile → Copy email address
   
3. Settings → Testers → Add tester
   - Paste your email address
   - Make them a License Tester
   - (Don't need to be Closed Tester, just License Tester)
   
4. On Android device/emulator:
   - Sign in to Google Play Store with this email
   - Purchase will now use TEST CARD (no real charge)
```

### Step 3: Start Backend Locally
```bash
# Terminal 1: Start backend
cd backend
python run_server.py

# You should see:
# INFO:     Uvicorn running on http://127.0.0.1:8000
# Database initialized
# Ready for connections
```

### Step 4: Run App on Emulator or Device
```bash
# Terminal 2: Start app
cd mobile/destiny_decoder_app
flutter pub get
flutter run -d emulator-5554  # or your device

# Watch console for:
# ✓ App compiled
# ✓ Installed on device
# ✓ Settings → Subscription shows pricing
```

### Step 5: Test Purchase Flow
```
1. Open app → go to Settings → Subscription
2. Verify you see the 3 pricing options
3. Create 3 readings (free limit)
4. Try to create 4th reading
5. Paywall should appear
6. Tap "Start Premium" (Monthly option)
7. Google Play dialog opens
8. Complete test purchase (uses TEST CARD, no charge)
9. Subscription should activate
10. Paywall closes, features unlock
```

---

## 🔧 Configuration Reference

### android_config.dart SKUs
```dart
class AndroidConfig {
  static const String premiumMonthly = 'destiny_decoder_premium_monthly';
  static const String premiumAnnual = 'destiny_decoder_premium_annual';
  static const String proAnnual = 'destiny_decoder_pro_annual';
  
  // Change this to switch environments:
  // 'development' → http://10.0.2.2:8000 (emulator)
  // 'production' → https://api.destinydecoderapp.com (when deployed)
}
```

### Backend URLs
- **Emulator:** `http://10.0.2.2:8000` (special alias, not localhost!)
- **Physical Device on WiFi:** `http://192.168.x.x:8000` (use your machine IP)
- **Production:** Will be your deployed URL later

### Test Account
```
Email: (your test email)
Payment Method: TEST CARD (provided by Google, no charge)
Test Purchases: Free, all complete instantly
Real Purchases: Would require live card
```

---

## 📊 Testing Workflow

```
┌─────────────────────────────────────────┐
│ Step 1: Create Products in Google Play  │ ← DO THIS NOW
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ Step 2: Add Test Account                │ ← DO THIS NOW
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ Step 3: Start Backend (python)          │ ← RUN: python run_server.py
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ Step 4: Run App (flutter run)           │ ← RUN: flutter run -d emulator
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│ Step 5: Test Purchase & Features        │ ← MANUAL TESTING
└──────────────┬──────────────────────────┘
               │
         SUCCESS? ───── NO ──→ Check TROUBLESHOOTING
               │
              YES
               │
┌──────────────▼──────────────────────────┐
│ ✅ Testing Complete!                    │
│ Ready for next phase:                   │
│ - Backend receipt validation            │
│ - iOS setup (parallel with Phase 7.2)   │
│ - Live Play Store submission            │
└─────────────────────────────────────────┘
```

---

## 🚨 Common Issues & Quick Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| "SKU not found" | Product ID mismatch | Check exact spelling in Google Play, must match android_config.dart |
| Emulator can't reach backend | Using localhost:8000 | Use `10.0.2.2:8000` instead (special emulator alias) |
| Paywall doesn't appear | Feature gate not integrated | Verify reading limit check exists before save |
| Purchase fails silently | Receipt validation not implemented | Backend TODO: validate_receipt() needs implementation |
| Device can't reach backend | Using wrong IP | Device WiFi: use `192.168.x.x:8000` or deployed URL |

**See:** ANDROID_TESTING_CHECKLIST.md for detailed troubleshooting

---

## 📋 What Happens After Testing Works

1. **Backend Receipt Validation** (3-4 hours)
   - Implement validate_receipt() for Google Play
   - Call Google Play Verification API
   - Verify receipt authenticity
   - Create subscription record

2. **Database Migration** (30 mins)
   - Run: `alembic revision --autogenerate`
   - Run: `alembic upgrade head`
   - Populate test data

3. **iOS Setup** (parallel with above)
   - Create App Store Connect products
   - Configure StoreKit
   - Implement iOS receipt validation
   - Test on iOS

4. **Live Testing**
   - Submit app to Google Play (alpha/beta)
   - Submit app to App Store
   - Get approval
   - Launch

---

## 💡 Pro Tips

### For Emulator Testing
```bash
# Use highest API level available
flutter emulators --launch Pixel_6_API_34

# If having issues, try clean rebuild
flutter clean
flutter pub get
flutter run -d emulator-5554
```

### For Device Testing
```bash
# Enable USB debugging on device
# Settings → Developer Options → USB Debugging

# List connected devices
flutter devices

# Run on device
flutter run -d <device_id>

# If not showing: adb devices
```

### Viewing Logs
```bash
# Real-time Flutter logs
flutter logs

# Backend logs
# Terminal running backend shows logs in real-time
```

### Monitoring Backend
```python
# In backend/app/services/subscription_service.py
# Check these methods are being called:
- validate_receipt()      # Process purchase receipt
- check_feature_access()  # Check subscription status
- create_subscription()   # Create subscription after purchase
```

---

## ✅ Verification Checklist

Use this to verify each step worked:

- [ ] Google Play Console products created (all 3 SKUs visible)
- [ ] Test account added and can sign in on device
- [ ] Backend starts without errors: `python run_server.py`
- [ ] App installs and runs: `flutter run`
- [ ] Settings → Subscription page loads with 3 pricing options
- [ ] Created 3 readings, 4th triggers paywall ✓
- [ ] Purchase dialog opens from paywall ✓
- [ ] Google Play shows test card (no charge) ✓
- [ ] Purchase completes successfully ✓
- [ ] Backend logs show subscription created ✓
- [ ] Settings now shows "Premium" tier ✓
- [ ] Can create unlimited readings post-purchase ✓

---

## 📞 Quick Reference Links

- **Google Play Console:** https://play.google.com/console
- **Google Play Billing Docs:** https://developer.android.com/google-play/billing
- **Flutter IAP Docs:** https://pub.dev/packages/in_app_purchase
- **Android Testing Guide:** See ANDROID_SETUP_GUIDE.md in this repo

---

**You're ready! Start with Step 1 (Google Play products) right now. It'll take ~20 minutes. 🎯**

