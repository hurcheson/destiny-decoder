# Deep Linking Implementation - Complete Guide

## Overview
Users clicking shared links now open content directly in the app instead of a browser. Each share includes a unique `ref` code for attribution tracking.

## What Was Implemented

### 1. Deep Link Configuration
- **Android**: Intent filters for `https://destinydecoder.app/*` and custom scheme `destinydecoder://`
- **Package**: `app_links` for cross-platform deep linking
- **Routes**: Automatically handles `/articles/<slug>` paths

### 2. Share URLs Now Include Deep Links
Example Life Seal share:
```
🔮 My Life Seal: #7 - The Seeker

...

Get the app: destinydecoder://destinydecoder.app?ref=x7k9m2qa&utm_source=share&utm_medium=app&utm_campaign=life_seal
```

Example Article share:
```
📚 I just found this insightful article:

"Life Seal 7: The Seeker"

Read it here: destinydecoder://destinydecoder.app/articles/life-seal-7-the-seeker?ref=a3b8c9d1&utm_source=share&utm_medium=app&utm_campaign=article
```

### 3. Analytics Tracking
- Referral clicks automatically logged to `/analytics/referral-clicks`
- Data includes: `ref_code`, `target` path, and timestamp
- Fire-and-forget (non-blocking)

### 4. Navigation Flow
```
User clicks link → App opens → Extract ref code → Track referral → Navigate to article
```

## Testing Instructions

### Method 1: In-App Test Page (Easiest)
1. **Run the app**:
   ```powershell
   cd c:\Users\ix_hurcheson\Desktop\destiny-decoder\mobile\destiny_decoder_app
   flutter run -d 23106RN0DA
   ```

2. **Navigate to test page**:
   - Tap bottom navigation: Decode → Settings (gear icon top-right)
   - Scroll down to "Debug Tools" section (only visible in debug mode)
   - Tap "Test Deep Links"

3. **Test a link**:
   - Tap "Article: Life Seal 7" → App should navigate to article
   - Check logs for: `📎 Deep link received:` and `📊 Tracked referral click:`

### Method 2: Manual Test (Most Realistic)
1. **Share from app**:
   - Decode a reading → scroll to "Share Your Life Seal" → tap "Copy"
   - Or open any article → tap "Copy"

2. **Paste and open**:
   - Open Notes, Messages, or any app
   - Paste the link
   - Tap the link → Should open in Destiny Decoder app

3. **Verify**:
   - App should navigate to the article
   - Check backend logs: `cat backend/app/data/referral_clicks.jsonl`

### Method 3: ADB Command Line
```bash
# Test article deep link
adb shell am start -W -a android.intent.action.VIEW -d "destinydecoder://destinydecoder.app/articles/life-seal-7-the-seeker?ref=testref123" com.example.destiny_decoder_app

# Test app landing
adb shell am start -W -a android.intent.action.VIEW -d "destinydecoder://destinydecoder.app?ref=landing001" com.example.destiny_decoder_app
```

### Method 4: Browser Test
1. **Create HTML file** (`test_deeplink.html`):
```html
<!DOCTYPE html>
<html>
<body>
  <h1>Deep Link Test</h1>
  <a href="destinydecoder://destinydecoder.app/articles/life-seal-7-the-seeker?ref=browser123">
    Open Life Seal 7 Article
  </a>
</body>
</html>
```

2. **Open on phone** (via Google Drive, email, or local server)
3. **Tap link** → Should open in app

## Expected Behavior

### ✅ Success
- Link tap opens Destiny Decoder app
- App navigates to article page
- No browser intermediary
- Console logs show:
  ```
  📎 Deep link received: /articles/life-seal-7-the-seeker
  📊 Tracked referral click: ref=x7k9m2qa, path=/articles/...
  ```
- Backend `referral_clicks.jsonl` has new entry

### ❌ Common Issues

**"No app found to open this link"**
- Make sure app is installed and running
- Try rebuilding: `flutter run -d 23106RN0DA`

**Link opens browser instead of app**
- Android's app verification takes time (~24 hours for https://)
- Use custom scheme for testing: `destinydecoder://`
- Or use the in-app test page

**App opens but doesn't navigate**
- Check logs for errors
- Verify article slug exists in backend
- Ensure deep link service initialized (happens in main.dart)

## Production Deployment

### When You Have a Domain

1. **Update AndroidManifest.xml**:
   ```xml
   <data android:scheme="https" android:host="yourdomain.com" />
   ```

2. **Add Digital Asset Links** (for Android App Links):
   - Host `/.well-known/assetlinks.json` on your domain
   - Android will auto-verify and skip the "Open with" dialog

3. **Update share URLs**:
   ```bash
   flutter run --dart-define=APP_SHARE_URL=https://yourdomain.com
   ```

4. **iOS Universal Links** (future):
   - Add associated domains to Xcode
   - Host `apple-app-site-association` file

## Analytics Queries

### View referral clicks:
```bash
cat backend/app/data/referral_clicks.jsonl | jq .
```

### Count clicks per ref code:
```python
import json
from collections import Counter

with open('backend/app/data/referral_clicks.jsonl') as f:
    clicks = [json.loads(line) for line in f]
    
ref_counts = Counter(c['ref_code'] for c in clicks)
print(ref_counts.most_common(10))
```

### Join shares → clicks (conversion):
```python
import json

# Load both files
with open('backend/app/data/analytics_share_events.jsonl') as f:
    shares = [json.loads(line) for line in f]
    
with open('backend/app/data/referral_clicks.jsonl') as f:
    clicks = [json.loads(line) for line in f]

# Count shares that led to clicks
share_refs = {s['ref_code'] for s in shares if s.get('ref_code')}
click_refs = {c['ref_code'] for c in clicks}

converted = share_refs & click_refs
conversion_rate = len(converted) / len(share_refs) if share_refs else 0

print(f"Shares: {len(share_refs)}")
print(f"Clicks: {len(click_refs)}")
print(f"Converted: {len(converted)} ({conversion_rate:.1%})")
```

## Files Changed
1. `pubspec.yaml` - Added app_links package
2. `AndroidManifest.xml` - Intent filters for deep linking
3. `lib/core/deep_linking/deep_link_service.dart` - Deep link handler
4. `lib/main.dart` - Initialize deep linking, handle navigation
5. `lib/core/config/app_config.dart` - Default to custom scheme for testing
6. `lib/features/debug/deep_link_test_page.dart` - Testing UI
7. `lib/features/settings/presentation/settings_page.dart` - Added debug tools link

## Next Steps
- Test thoroughly using Method 1 (easiest)
- Once working, test Method 2 (realistic sharing flow)
- View analytics to confirm tracking works
- When deployed, switch to https:// scheme and add App Links verification
