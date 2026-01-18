# Onboarding Testing Guide

## ✅ Fixes Applied

### 1. **Async Initialization Issue** - FIXED
**Problem**: `OnboardingStateNotifier` was trying to use `_service` before it was initialized
**Solution**: 
- Made `_service` nullable
- Added `_isInitialized` flag
- Added `_ensureInitialized()` method to all state-changing methods
- All methods now wait for service initialization before executing

### 2. **Loading State** - ADDED
**Problem**: No visual feedback while service initializes
**Solution**: Added loading indicator and error handling in `onboarding_page.dart`

---

## 🧪 How to Test

### Step 1: Clear Previous Onboarding State
```powershell
# On Windows - delete app data to start fresh
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\mobile\destiny_decoder_app
flutter run
```

Then in the app:
1. Navigate to Settings
2. Scroll down to "Developer Options"
3. Tap "Reset Onboarding"
4. Restart the app

### Step 2: Test Each Onboarding Step

**Step 0 - Welcome Screen**
- ✅ Should show "Welcome to Destiny Decoder"
- ✅ Shows 3 feature highlights
- ✅ Has "Get Started" button
- ✅ No back button (first step)

**Step 1 - Birth Info**
- ✅ Input fields for Day/Month/Year
- ✅ Validation works (day 1-31, month 1-12, year 1900-current)
- ✅ "Next" button disabled until valid date entered
- ✅ "Skip" button available
- ✅ Back button works

**Step 2 - Calculate Life Seal**
- ✅ Shows calculated Life Seal number (1-9)
- ✅ Large circular display with gradient
- ✅ Shows birth date used for calculation
- ✅ "Continue" button advances to next step

**Step 3 - Life Seal Display**
- ✅ Shows Life Seal number
- ✅ Shows meaning/interpretation
- ✅ "Next: Features" button advances

**Step 4 - Features Overview**
- ✅ Shows 4 feature cards:
  - Daily Insights
  - Compatibility Check
  - Reading Library
  - Monthly Guidance
- ✅ "Next: Permissions" button

**Step 5 - Permissions**
- ✅ Two permission cards (Notifications, Calendar)
- ✅ "Enable Permissions" button requests permissions
- ✅ Visual feedback when permissions granted
- ✅ "Open App Settings" button if needed
- ✅ "Skip" button available

**Step 6 - Ready**
- ✅ Success icon and "You're All Set!" message
- ✅ "What's Next" list with 3 items
- ✅ "Start Using Destiny Decoder" button
- ✅ Navigates to DecodeFormPage on completion
- ✅ Sets `has_seen_onboarding` flag

### Step 3: Verify State Persistence

1. Complete onboarding through Step 3 (Life Seal Display)
2. Force close the app (swipe away from recent apps)
3. Reopen the app
4. ✅ Should resume at Step 3 (not restart from beginning)

### Step 4: Test Skip Functionality

1. Reset onboarding
2. Skip Step 1 (Birth Info)
3. ✅ Should advance to Step 2
4. ✅ Skipped steps should be tracked

### Step 5: Test Back Navigation

1. Advance to Step 3
2. Press back button or device back gesture
3. ✅ Should go back to Step 2
4. ✅ On Step 0, back should exit onboarding

---

## 🐛 Known Issues & Workarounds

### If Onboarding Doesn't Load
1. Check terminal output for initialization errors
2. Verify SharedPreferences is working
3. Use "Reset Onboarding" from Settings → Developer Options

### If Permissions Don't Work
- **Android 13+**: Notification permission must be granted
- **iOS**: Calendar permission may not be available on all iOS versions
- Both are optional - app works without them

### If State Not Persisting
- Check that `has_seen_onboarding` key is set in SharedPreferences
- Verify `onboarding_state` JSON is being saved

---

## 📱 Quick Test Commands

### Run on Connected Device
```powershell
cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\mobile\destiny_decoder_app
flutter run
```

### Check for Errors
```powershell
flutter analyze lib/features/onboarding lib/core/onboarding
```

### View Logs (Debug Build)
Look for these log messages:
- `✅ Onboarding service initialized`
- `📱 Current step: X`
- `💾 Onboarding state saved`
- `✓ Onboarding completed`

---

## ✅ Success Criteria

All of these should work:
- ✅ Onboarding loads without crashes
- ✅ All 7 steps display correctly
- ✅ Navigation (next/back/skip) works
- ✅ Birth date validation works
- ✅ Life Seal calculation is correct
- ✅ State persists across app restarts
- ✅ Completion navigates to main app
- ✅ `has_seen_onboarding` flag prevents re-showing
- ✅ Analytics events are logged

---

## 🔧 Debugging Tips

### Enable Debug Prints
The code already has `debugPrint` statements. Run with:
```powershell
flutter run --debug
```

### Check SharedPreferences
Add temporary debug code in `main.dart`:
```dart
final prefs = await SharedPreferences.getInstance();
print('Onboarding seen: ${prefs.getBool('has_seen_onboarding')}');
print('Onboarding state: ${prefs.getString('onboarding_state')}');
```

### Reset Everything
```dart
// In Settings page or add temporary button
await ref.read(onboardingStateProvider.notifier).reset();
final prefs = await SharedPreferences.getInstance();
await prefs.remove('has_seen_onboarding');
```

---

**Test Date**: January 18, 2026
**Status**: Ready for testing
**Next Steps**: Run the app and follow the test steps above
