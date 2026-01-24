# 🎯 Pre-APK Packaging - Changes Required

## One Critical Change Needed

Your app is **99% ready** to package. Only one thing needs updating:

---

## ⚠️ CRITICAL: Update Package Name

### Why?
The current package name is `com.example.destiny_decoder_app` which is just a placeholder. You need to change it to your actual company identifier.

### Where to Change

**File**: `mobile/destiny_decoder_app/android/app/build.gradle.kts`

**Line 25** - Find:
```gradle
applicationId = "com.example.destiny_decoder_app"
```

**Change to** (replace `yourcompany` with your actual identifier):
```gradle
applicationId = "com.yourcompany.destinydecoder"
```

Examples:
- If your company is "Acme": `com.acme.destinydecoder`
- If personal: `com.myname.destinydecoder`
- Standard format: `com.companyname.appname` (all lowercase, no spaces)

### Also Update Firebase Config

**File**: `mobile/destiny_decoder_app/android/app/google-services.json`

**Line 10** - The package name also appears in your Firebase config:
```json
"package_name": "com.example.destiny_decoder_app"
```

This should match the `build.gradle.kts` change.

**However**: This `google-services.json` is generated from Firebase Console. If you already have Firebase setup with `com.example.*`, you can:
- **Option A**: Keep it as-is (Firebase will auto-configure for your actual package name when you publish)
- **Option B**: Re-download `google-services.json` from Firebase Console after updating the package name

---

## ✅ Everything Else is Ready

| Item | Status | Details |
|------|--------|---------|
| **Code Quality** | ✅ PASS | 0 errors, 0 warnings |
| **Backend URL** | ✅ READY | Railway production configured |
| **Firebase** | ✅ VALID | google-services.json present |
| **Permissions** | ✅ SET | Internet, Camera, Storage configured |
| **Dependencies** | ✅ GOOD | All packages up-to-date |
| **Google Play Billing** | ✅ CONFIG | SKUs defined in android_config.dart |
| **Version** | ✅ SET | 1.0.0+1 (good for testing) |

---

## 📝 Step-by-Step: Change Package Name

### Step 1: Edit build.gradle.kts

```bash
# Navigate to the file
cd mobile/destiny_decoder_app/android/app

# Edit build.gradle.kts with your editor
# Find line 25: applicationId = "com.example.destiny_decoder_app"
# Change to your package name
```

### Step 2: Build APK

Once you update the package name:

```bash
cd mobile/destiny_decoder_app

# Clean
flutter clean

# Build
flutter build apk --release

# APK will be at:
# build/app/outputs/flutter-apk/app-release-unsigned.apk
```

### Step 3: Test & Share

Send the APK to your team with these instructions:

```
Installation:
1. Download APK to Android phone
2. Settings → Apps → Advanced → Install unknown apps → [Browser] → Allow
3. Open Downloads, tap APK, tap Install
4. Open app and test features

Backend: https://destiny-decoder-production.up.railway.app
Version: 1.0.0+1
```

---

## 🔍 Verification Before Building

Run this check:

```bash
# Check current package name in build config
grep "applicationId" mobile/destiny_decoder_app/android/app/build.gradle.kts

# Check Firebase config
grep "package_name" mobile/destiny_decoder_app/android/app/google-services.json
```

Both should show your new package name (not `com.example.*`)

---

## 🚀 Quick Build Commands

After updating the package name:

```bash
# Option 1: Debug APK (quick, larger)
cd mobile/destiny_decoder_app && flutter build apk --debug
# Output: build/app/outputs/flutter-apk/app-debug.apk

# Option 2: Release APK (slow, much smaller)
cd mobile/destiny_decoder_app && flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release-unsigned.apk

# Option 3: Release Bundle (for Google Play Store)
cd mobile/destiny_decoder_app && flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

For team testing, use **Release APK** (much smaller file).

---

## 📊 Pre-Build Checklist

Before running `flutter build apk`:

- [ ] Package name changed in `build.gradle.kts`
- [ ] Package name matches in `google-services.json` (or matches Firebase Console setup)
- [ ] Backend API is deployed and running
- [ ] No compilation errors: `flutter analyze`
- [ ] Dependencies are up-to-date: `flutter pub get`

---

## ❓ What Package Name Should I Use?

### Standard Format:
```
com.companyname.appname
```

### Examples:
- Company project: `com.acmecorp.destinydecoder`
- Personal project: `com.johnsmith.destinydecoder`
- Startup: `com.startupname.destiny`

### Rules:
- All lowercase
- No spaces or special characters (except dots)
- Reverse domain format: `com.yourcompany.appname`
- Must be unique (if publishing to Google Play)
- Between 1-50 characters per segment

### Google Play Console:
Once you have your package name, create your app in Google Play Console with:
1. App name: "Destiny Decoder"
2. Package name: Your chosen ID (e.g., `com.acmecorp.destinydecoder`)
3. This is permanent, can't be changed later!

---

## ✨ That's It!

Once you update the package name, your app is ready to:
- ✅ Build and test
- ✅ Share with your team
- ✅ Prepare for Google Play Store (later)

The app includes all working features:
- Destiny calculation ✅
- PDF export ✅
- Image sharing ✅
- Reading history ✅
- Compatibility analysis ✅
- Notifications (Firebase) ✅

**No other changes needed!**

---

**Next**: Update the package name → Build APK → Test with team

Questions? See [APK_PACKAGING_CHECKLIST.md](APK_PACKAGING_CHECKLIST.md) for full details.
