# ⚡ Quick APK Build Guide (2 Minutes)

## 🎯 One Command to Rule Them All

```bash
# 1. Change ONE line in this file:
# File: mobile/destiny_decoder_app/android/app/build.gradle.kts
# Line 25: applicationId = "com.yourcompany.destinydecoder"

# 2. Then run:
cd mobile/destiny_decoder_app
flutter clean && flutter build apk --release

# 3. APK is here:
# build/app/outputs/flutter-apk/app-release-unsigned.apk
```

---

## 📋 Pre-Build Checklist

- [ ] Updated package name in `build.gradle.kts`
- [ ] Run `flutter clean`
- [ ] Run `flutter pub get`

---

## 🏗️ Build Commands

```bash
# Debug (fast, larger ~180MB)
flutter build apk --debug

# Release (slower, smaller ~35MB) ← RECOMMENDED
flutter build apk --release

# Bundle (for Google Play Store)
flutter build appbundle --release
```

---

## 📁 Output Locations

```
build/app/outputs/flutter-apk/
├── app-debug.apk              (if you ran --debug)
└── app-release-unsigned.apk   (if you ran --release) ← Use this

build/app/outputs/bundle/release/
└── app-release.aab            (if you ran appbundle)
```

---

## 📱 Install on Device

```bash
# Using adb
adb install build/app/outputs/flutter-apk/app-release-unsigned.apk

# Or manually:
# 1. Copy APK to phone
# 2. Settings → Apps → Install unknown apps → [Browser] → Allow
# 3. Open Downloads, tap APK, tap Install
# 4. Done!
```

---

## 🔍 Verify Before Building

```bash
# Check package name
grep applicationId mobile/destiny_decoder_app/android/app/build.gradle.kts

# Check for errors
flutter analyze

# Check dependencies
flutter pub get
```

---

## ⏱️ Build Time

- Clean: ~30 seconds
- Pub get: ~20 seconds
- Build: ~90-120 seconds
- **Total: 2-3 minutes**

---

## 🚨 If Build Fails

```bash
# Complete reset
flutter clean
flutter pub get
flutter analyze  # Check for issues
flutter build apk --release  # Try again
```

---

## ✅ Success Indicators

Build successful when you see:
```
✅ Built build/app/outputs/flutter-apk/app-release-unsigned.apk
```

---

## 📊 File Sizes (Expected)

| Build Type | Size | Status |
|-----------|------|--------|
| Debug APK | 150-200 MB | Too large for sharing |
| Release APK | 35-40 MB | Perfect ✅ |
| App Bundle | 25-30 MB | For Play Store only |

---

## 🎯 For Team Testing

1. **Build**: `flutter build apk --release`
2. **Share**: `app-release-unsigned.apk` (~35 MB)
3. **Install**: Team taps APK → Install
4. **Test**: Team tests all features
5. **Feedback**: Team reports issues

---

**That's it!** Your app is ready. 🚀

See full guides:
- [CHANGES_BEFORE_APK_PACKAGING.md](CHANGES_BEFORE_APK_PACKAGING.md)
- [APK_PACKAGING_CHECKLIST.md](APK_PACKAGING_CHECKLIST.md)
- [TEAM_TESTING_READY.md](TEAM_TESTING_READY.md)
