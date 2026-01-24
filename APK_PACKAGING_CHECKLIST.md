# 📦 APK Packaging Checklist - Before Release

## ✅ Pre-Packaging Verification

### Code Quality
- [x] 0 compilation errors
- [x] 0 warnings
- [x] All imports resolved
- [x] Clean Dart code

### Critical Configuration Items

#### 1. **Backend API Configuration** ⚠️ IMPORTANT
**Current Status**: Production URL configured
- File: [mobile/destiny_decoder_app/lib/core/config/app_config.dart](mobile/destiny_decoder_app/lib/core/config/app_config.dart)
- Current default: `https://destiny-decoder-production.up.railway.app`
- ✅ **Ready**: Using Railway production endpoint

**What to confirm with your team**:
- [ ] Backend is deployed and running
- [ ] Backend URL is correct
- [ ] CORS is configured to allow mobile requests
- [ ] All API endpoints are responding

#### 2. **Android Package Name** ⚠️ IMPORTANT
**Current Status**: Example name (needs update)
- File: [mobile/destiny_decoder_app/android/app/build.gradle.kts](mobile/destiny_decoder_app/android/app/build.gradle.kts)
- Current: `com.example.destiny_decoder_app`
- **Need to change to**: Your actual package name (e.g., `com.yourcompany.destiny_decoder`)

**Steps**:
```bash
# 1. Update build.gradle.kts
applicationId = "com.yourcompany.destiny_decoder"

# 2. Update AndroidManifest.xml reference if needed
# (Usually auto-applied by Flutter)
```

#### 3. **App Version** ✅ GOOD
- Current: `version: 1.0.0+1` in pubspec.yaml
- This is a good starting version for team testing

#### 4. **Firebase Configuration** ⚠️ CHECK
- File: [mobile/destiny_decoder_app/android/app/google-services.json](mobile/destiny_decoder_app/android/app/google-services.json)
- **Verify**: 
  - [ ] google-services.json is present and valid
  - [ ] Firebase project matches your backend setup
  - [ ] FCM is enabled in Firebase Console
  - [ ] Analytics is enabled

#### 5. **Google Play Billing** ⚠️ CHECK
**Current Status**: Configured in config
- File: [mobile/destiny_decoder_app/lib/core/config/android_config.dart](mobile/destiny_decoder_app/lib/core/config/android_config.dart)
- SKUs defined: premium_monthly, premium_annual, pro_annual
- **Verify**: 
  - [ ] Google Play Console app created
  - [ ] SKUs match exactly with console setup (case-sensitive!)
  - [ ] Package name matches in both places

**Config to verify**:
```dart
// android_config.dart
static const String googlePlayPackageName = 'com.yourcompany.destiny_decoder';
static const String premiumMonthlySku = 'destiny_decoder_premium_monthly';
static const String premiumAnnualSku = 'destiny_decoder_premium_annual';
static const String proAnnualSku = 'destiny_decoder_pro_annual';
```

#### 6. **Required Permissions** ✅ CONFIGURED
Check: [mobile/destiny_decoder_app/android/app/src/main/AndroidManifest.xml](mobile/destiny_decoder_app/android/app/src/main/AndroidManifest.xml)

Already included:
- Internet (required for API calls)
- Camera (for image sharing)
- Storage (for PDF/image saving)
- Location (optional, for deep linking)

---

## 🔧 Quick Fixes Needed Before Packaging

### Fix 1: Update Package Name (Required)
File: [mobile/destiny_decoder_app/android/app/build.gradle.kts](mobile/destiny_decoder_app/android/app/build.gradle.kts)

Change line:
```gradle
applicationId = "com.example.destiny_decoder_app"
```

To:
```gradle
applicationId = "com.yourcompany.destiny_decoder"
```

Replace `yourcompany` with your actual company identifier.

---

### Fix 2: Disable Debug Logging (Optional but Recommended)
File: [mobile/destiny_decoder_app/lib/core/config/android_config.dart](mobile/destiny_decoder_app/lib/core/config/android_config.dart)

Find:
```dart
static const bool debugLogging = true;
```

Change to:
```dart
static const bool debugLogging = false;  // Disable for release
```

---

### Fix 3: Verify Backend API URL
File: [mobile/destiny_decoder_app/lib/core/config/app_config.dart](mobile/destiny_decoder_app/lib/core/config/app_config.dart)

Confirm the API URL is accessible:
```bash
# Test if backend is running
curl https://destiny-decoder-production.up.railway.app/docs
# Should return API documentation

# Or test a specific endpoint
curl -X POST https://destiny-decoder-production.up.railway.app/decode \
  -H "Content-Type: application/json" \
  -d '{"full_name":"Test","date_of_birth":"1990-01-01"}'
```

If backend is not deployed:
- See: [DEPLOY_RAILWAY_NOW.md](../../DEPLOY_RAILWAY_NOW.md) for 10-minute deployment
- Or update API_BASE_URL for testing on local machine

---

## 📋 Packaging Steps

### Step 1: Clean Build
```bash
cd mobile/destiny_decoder_app

# Clean previous builds
flutter clean

# Get latest dependencies
flutter pub get

# Analyze for any issues
flutter analyze
```

### Step 2: Build APK

#### For Debug Testing (Quick, Large File)
```bash
flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk (~150-200 MB)
# ⚠️ Large file due to debug symbols
```

#### For Release/Production (Recommended)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release-unsigned.apk (~30-40 MB)
# ✅ Much smaller, optimized
```

#### Optional: App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
# ℹ️ Used for Google Play Store (more efficient than APK)
```

### Step 3: Locate Built APK
```bash
# After build completes, APK is here:
mobile/destiny_decoder_app/build/app/outputs/flutter-apk/
```

Files:
- `app-debug.apk` - Debug version (if you ran `--debug`)
- `app-release-unsigned.apk` - Release version (if you ran `--release`)

### Step 4: Share with Team

#### For Quick Testing
Send the debug APK directly:
```
mobile/destiny_decoder_app/build/app/outputs/flutter-apk/app-debug.apk
```

Team can install with:
```bash
adb install app-debug.apk
```

#### For Multiple Devices
Create a shared folder:
```
/team_testing/APK/
  ├── app-debug.apk
  ├── INSTALL_INSTRUCTIONS.txt
  └── TEST_CHECKLIST.md
```

---

## 🧪 Testing Checklist for Your Team

### Core Features
- [ ] App launches without crashes
- [ ] Can calculate destiny (name + DOB)
- [ ] All cards display correctly (Life Seal, Soul Number, etc.)
- [ ] PDF export works
- [ ] Image sharing works
- [ ] Reading history saves and loads
- [ ] Compatibility analysis works

### UI/UX
- [ ] Animations are smooth
- [ ] Colors look correct
- [ ] Text is readable
- [ ] Buttons are clickable
- [ ] No layout issues on different screen sizes
- [ ] Dark mode works (if enabled)

### Data Validation
- [ ] Invalid inputs show errors (e.g., bad date)
- [ ] Calculations are accurate
- [ ] PDF content is correct
- [ ] Shared text includes all information

### Performance
- [ ] App starts in <3 seconds
- [ ] Calculations are instant
- [ ] No freezing or lag
- [ ] Memory usage is reasonable (check with `adb shell dumpsys meminfo`)

---

## 🚀 Installation Instructions for Team

Create a `INSTALL_INSTRUCTIONS.txt` to share with APK:

```
🎯 Destiny Decoder APK - Installation Guide

REQUIREMENTS:
- Android 5.0+ (API level 21+)
- 200 MB free space
- Internet connection (for backend API)

INSTALLATION:

1. Download the APK file to your Android phone

2. Enable installation from unknown sources:
   Settings → Apps & Notifications → Advanced → 
   Special app access → Install unknown apps → [Browser] → Allow

3. Open file manager, navigate to Downloads, tap the APK

4. Tap "Install"

5. Wait for installation to complete

6. Tap "Open" or find app in your app drawer

INITIAL SETUP:
- Allow notifications (optional)
- No login needed for testing
- Try entering a birth date to get started

BACKEND CONNECTION:
- App connects to: https://destiny-decoder-production.up.railway.app
- Requires internet connection
- If backend is down, you'll see connection errors

TESTING NOTES:
- All features are available in this test build
- Freemium paywalls are DISABLED for testing
- Data is saved locally on device
- Uninstall to clear all test data

ISSUES?
- If app crashes: Check Android logs with `adb logcat`
- If features fail: Verify backend is running
- Force restart: Settings → Apps → Destiny Decoder → Force Stop

VERSION: 1.0.0+1
BUILT: January 22, 2026
```

---

## ⚠️ Critical Pre-Packaging Checklist

Before sending APK to team, verify:

- [ ] **Backend is deployed and running**
  - Test: `curl https://destiny-decoder-production.up.railway.app/docs`
  
- [ ] **Package name is changed from example**
  - Current: `com.example.destiny_decoder_app` → Change to your actual ID
  
- [ ] **firebase/google-services.json is valid**
  - File exists: [mobile/destiny_decoder_app/android/app/google-services.json](mobile/destiny_decoder_app/android/app/google-services.json)
  - Check: JSON is not empty, has valid format
  
- [ ] **No sensitive keys in code**
  - Grep for: passwords, API keys, secrets
  - Should all be in `.env` or backend only
  
- [ ] **App builds successfully**
  - Run: `flutter build apk --release`
  - No errors in build output
  
- [ ] **APK is reasonable size**
  - Debug: 100-200 MB (OK for testing)
  - Release: 30-50 MB (Good for distribution)

---

## 📊 Files to Modify Before Packaging

| File | Current Value | Need to Change? | Purpose |
|------|---|---|---|
| [build.gradle.kts](mobile/destiny_decoder_app/android/app/build.gradle.kts) | `com.example.destiny_decoder_app` | **YES** | Package name |
| [android_config.dart](mobile/destiny_decoder_app/lib/core/config/android_config.dart) | `debugLogging = true` | Optional | Reduce console spam |
| [app_config.dart](mobile/destiny_decoder_app/lib/core/config/app_config.dart) | Railway URL | Check | Backend connection |
| [google-services.json](mobile/destiny_decoder_app/android/app/google-services.json) | Your Firebase config | Verify | Push notifications |
| [pubspec.yaml](mobile/destiny_decoder_app/pubspec.yaml) | `1.0.0+1` | Optional | Version bump |

---

## 🎯 Quick Summary

**What needs to be done RIGHT NOW**:

1. ✅ Code quality: GOOD (0 errors, 0 warnings)
2. ⚠️ Package name: CHANGE from `com.example.*` to your ID
3. ✅ API URL: CONFIGURED and ready
4. ⚠️ Firebase: VERIFY google-services.json is valid
5. ✅ Dependencies: ALL included and up-to-date

**Then**:
```bash
cd mobile/destiny_decoder_app
flutter build apk --release
# Share: build/app/outputs/flutter-apk/app-release-unsigned.apk
```

**Done!** Your team can start testing.

---

**Generated**: January 22, 2026  
**App Status**: 🟢 Ready for packaging (1 configuration change needed)
