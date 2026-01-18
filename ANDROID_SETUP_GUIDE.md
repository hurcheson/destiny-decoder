## Android Setup Guide for Freemium Paywall

**Date:** January 18, 2026  
**Purpose:** Complete setup instructions for Google Play Billing integration

---

## ✅ What We Just Configured

### 1. **AndroidManifest.xml**
- ✅ Added `com.android.vending.BILLING` permission
- ✅ Necessary for Google Play Billing to work

### 2. **build.gradle.kts**
- ✅ Added Google Play Billing Library `7.0.0`
- ✅ Latest version with full feature support

### 3. **Android Config File**
- ✅ Created `android_config.dart` for environment configuration
- ✅ Settings for development, staging, production
- ✅ SKU definitions matching Google Play

---

## 🔧 Configuration Files

### `lib/core/config/android_config.dart`
```dart
// Current settings:
- Backend URL (development): http://10.0.2.2:8000
- Backend URL (production): https://api.destinydecoderapp.com
- Google Play package: com.example.destiny_decoder_app
- SKUs: premium_monthly, premium_annual, pro_annual
- Sandbox testing: enabled
```

### For Emulator Testing
```
http://10.0.2.2:8000  ← Use this (not localhost:8000)
                       This is how Android emulator reaches host machine
```

### For Device Testing
```
http://192.168.x.x:8000  ← Use your machine's actual IP
                          Or use deployed backend URL
```

---

## 🚀 Next Steps: Google Play Console Setup

### Step 1: Create a Project (if not done)
```
1. Go to Google Play Console (play.google.com/console)
2. Click "Create project"
3. Name: "Destiny Decoder"
4. Accept terms
```

### Step 2: Create Application
```
1. Click "Create app"
2. App name: "Destiny Decoder"
3. Default language: English
4. App category: Lifestyle
5. Type: Free app
6. Continue
```

### Step 3: Set Up Signing
```
1. Left sidebar → Setup → App signing
2. Google will manage your signing key (recommended)
3. You'll get SHA-1 certificate fingerprint
4. Use this for Firebase (if needed later)
```

### Step 4: Fill Out Store Details
```
1. Go to Store listing
2. Fill in:
   - App name: "Destiny Decoder"
   - Short description: "Numerology destiny readings"
   - Full description: (your description)
   - Ratings: Lifestyle/Self-help
   - Save draft
```

### Step 5: Create In-App Products (CRITICAL)
```
1. Left sidebar → Monetization → Products → In-app products
2. Click "Create product"

PRODUCT 1: Premium Monthly
├─ Product ID: destiny_decoder_premium_monthly
├─ Product name: Premium Monthly Subscription
├─ Product type: Subscription
├─ Default price: $2.99/month
├─ Billing period: Monthly
├─ Description: Unlimited readings and features
└─ Save

PRODUCT 2: Premium Annual
├─ Product ID: destiny_decoder_premium_annual
├─ Product name: Premium Annual Subscription
├─ Product type: Subscription
├─ Default price: $24.99/year (or $29.99)
├─ Billing period: Yearly
├─ Description: Best value - full access for a year
└─ Save

PRODUCT 3: Pro Annual
├─ Product ID: destiny_decoder_pro_annual
├─ Product name: Pro Annual Subscription
├─ Product type: Subscription
├─ Default price: $49.99/year
├─ Billing period: Yearly
├─ Description: Premium + Coaching + API access
└─ Save
```

### Step 6: Add Test Accounts
```
1. Go to Settings → Testing
2. License Testing Accounts
3. Click "Add Google account email"
4. Add test accounts:
   - test1@gmail.com
   - test2@gmail.com
   - your.email@gmail.com
```

### Step 7: Configure Billing
```
1. Settings → Billing setup
2. Add your business address
3. Add your bank details (for actual payments)
4. For testing: use test accounts, no real payments
```

---

## 📱 Android Device/Emulator Setup

### Option A: Android Emulator (Easiest)
```
1. Open Android Studio
2. AVD Manager → Create Virtual Device
3. Device: Pixel 6 (or similar)
4. API Level: 33+ (required for Play Billing)
5. System Image: Google APIs (has Play Store)
6. Start the emulator
```

### Option B: Physical Device
```
1. Enable Developer Mode:
   - Settings → About Phone
   - Tap "Build Number" 7 times
2. Enable USB Debugging:
   - Settings → Developer options → USB debugging
3. Connect to computer via USB
4. Run: flutter devices (to verify connection)
```

### Install Test Account
```
For emulator/device:
1. Go to Google Play Store app
2. Sign in with test account
3. Accept terms
4. Billing will show "Test Card" with special behavior
```

---

## 🔌 Backend Setup for Android Testing

### Local Backend (Development)
```bash
# Terminal 1: Start backend
cd backend
python run_server.py
# Output: Uvicorn running on http://127.0.0.1:8000

# This runs on YOUR MACHINE
# Android emulator reaches it via: http://10.0.2.2:8000
```

### Update Android Config
```dart
// lib/core/config/android_config.dart

class EnvironmentConfig {
  static const String currentEnvironment = development;
  
  // Already configured to use:
  // http://10.0.2.2:8000 for emulator development
  // https://api.destinydecoderapp.com for production
}
```

### For Device on WiFi
```dart
// If using device on same WiFi as backend:
// Find your machine's IP: ipconfig (Windows) or ifconfig (Mac/Linux)
// Update android_config.dart:

static String getBackendUrl() {
  // Example: http://192.168.1.100:8000
  return 'http://YOUR_MACHINE_IP:8000';
}
```

---

## 🔬 Testing Workflow

### Test 1: Verify IAP Service Loads
```
1. Run app on device/emulator
2. Go to Settings → Subscription
3. Should show: "Free" tier with upgrade buttons
4. Check: Paywall loads without errors
```

### Test 2: Test Purchase Flow
```
1. Try to save 4th reading (triggers paywall)
2. Paywall appears with pricing
3. Select Premium plan
4. Tap "Start Premium"
5. Google Play dialog appears
6. Select "Use test card" or similar
7. Confirm purchase
8. Check backend logs for receipt validation
```

### Test 3: Check Backend Receipt Validation
```
Logs should show:
✅ POST /api/subscription/validate received
✅ Receipt data processed
✅ Subscription record created
✅ User tier updated to "premium"

If errors:
❌ Check backend is running on correct URL
❌ Check firewall allows connection
❌ Check SKU matches Google Play
```

### Test 4: Verify Features Unlock
```
1. After purchase completes
2. Go to Settings → Subscription
3. Should show: "Premium" tier
4. Should show: All features unlocked
5. Should show: Unlimited readings, full text, etc.
6. Try saving 5th reading (should work)
7. Try exporting 2nd PDF (should work)
8. Interpretation text should be full (not truncated)
```

---

## 🐛 Troubleshooting

### "Google Play Billing not available"
```
✅ Make sure device/emulator has Google Play Store app
✅ Make sure you signed in with test account
✅ Make sure API level 33+
✅ Make sure com.android.vending.BILLING permission added
```

### "SKU not found"
```
✅ Product ID must match EXACTLY (case-sensitive)
✅ Product ID in code: destiny_decoder_premium_monthly
✅ Product ID in Google Play: destiny_decoder_premium_monthly
✅ Check: Left sidebar → Products → In-app products → List
```

### "Receipt validation fails"
```
✅ Check backend is running: http://10.0.2.2:8000 (emulator)
✅ Check backend logs for errors
✅ Check product_id sent matches SKU in Google Play
✅ Check network connectivity
✅ Check firewall not blocking port 8000
```

### "Emulator can't reach backend"
```
❌ Don't use: http://localhost:8000
✅ Do use: http://10.0.2.2:8000

Android emulator runs in isolated network
10.0.2.2 is special alias for "host machine"
```

### "Purchase works but subscription doesn't activate"
```
✅ Check backend logs show receipt validation success
✅ Check database shows new subscription_history entry
✅ Check user.subscription_tier was updated
✅ Check Riverpod provider is invalidated after purchase
✅ Try app restart to fetch fresh status
```

---

## 📋 Checklist Before Testing

- [ ] AndroidManifest.xml has `com.android.vending.BILLING` permission
- [ ] build.gradle.kts has `com.android.billingclient:billing:7.0.0`
- [ ] android_config.dart created with correct URLs
- [ ] Backend running locally (or deployed)
- [ ] Google Play Console project created
- [ ] 3 subscription products created with exact SKU names
- [ ] Test account added to Google Play Console
- [ ] Emulator/device has Google Play Store app
- [ ] Test account signed into device/emulator Play Store
- [ ] pubspec.yaml has all IAP packages
- [ ] `pub get` run to download dependencies
- [ ] App built and installed on device/emulator

---

## 🔗 Key Files

| File | Purpose |
|------|---------|
| `android/app/src/main/AndroidManifest.xml` | Billing permission |
| `android/app/build.gradle.kts` | Billing library dependency |
| `lib/core/config/android_config.dart` | Configuration and URLs |
| `lib/core/iap/subscription_manager.dart` | Uses EnvironmentConfig |
| `lib/core/iap/purchase_service.dart` | IAP implementation |
| `lib/features/paywall/paywall_page.dart` | Paywall UI |

---

## 🚀 Quick Start Commands

```bash
# 1. Start backend
cd backend
python run_server.py

# 2. In another terminal, start Flutter
cd mobile/destiny_decoder_app
flutter pub get
flutter run -d emulator-5554  # or your device ID

# 3. Test the flow
# - Go to Settings
# - Try to save 4th reading
# - Complete purchase with test card
# - Check features unlock
```

---

## 📊 SKU Reference

Keep these handy:

```
MONTHLY:  destiny_decoder_premium_monthly
ANNUAL:   destiny_decoder_premium_annual
PRO:      destiny_decoder_pro_annual
```

These must match EXACTLY in:
1. Google Play Console (product setup)
2. android_config.dart (ProductIds class)
3. purchase_service.dart (product loading)

---

## ✅ Success Indicators

Once everything is set up correctly:
- ✅ Paywall appears when limit hit
- ✅ Google Play dialog opens on purchase button
- ✅ Test purchase completes without error
- ✅ Backend receives and validates receipt
- ✅ Subscription tier updates in database
- ✅ Features unlock immediately
- ✅ Settings page shows correct tier

---

## 🎯 Next Steps

1. **Create products in Google Play Console** (15 mins)
2. **Add test account to Console** (5 mins)
3. **Start backend locally** (2 mins)
4. **Run app on emulator** (5 mins)
5. **Test purchase flow** (10 mins)
6. **Check backend logs** (5 mins)
7. **Verify features unlock** (5 mins)

**Total: ~45 minutes to first test**

---

**Android setup complete and ready for testing!** 🚀

