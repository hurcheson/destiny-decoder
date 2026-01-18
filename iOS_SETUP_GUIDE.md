## iOS Setup Guide for Freemium Paywall

**Date:** January 18, 2026  
**Purpose:** Complete setup instructions for StoreKit integration

---

## ✅ What's Already Configured

### pubspec.yaml Dependencies
- ✅ `in_app_purchase: ^3.1.11` - Core IAP
- ✅ `in_app_purchase_storekit: ^0.3.6+7` - iOS support
- ✅ Ready to use StoreKit 2 APIs

### iOS Configuration
- ✅ Xcode project configured
- ✅ Code signing setup available
- ✅ In-app purchase capability ready

---

## 🔧 iOS-Specific Setup

### Step 1: Update iOS Minimum Version
```bash
# Open ios/Podfile
# Change to iOS 12.0+ (required for StoreKit)

# Find this line:
platform :ios, '11.0'

# Change to:
platform :ios, '12.0'

# Then run:
cd ios
pod install
```

### Step 2: Configure App ID Capabilities
```
1. Open Xcode: ios/Runner.xcworkspace
2. Select "Runner" project in sidebar
3. Select "Runner" target
4. Go to "Signing & Capabilities"
5. Click "+ Capability" button
6. Search for "In-App Purchase"
7. Click to add it
8. Verify it appears in capability list
```

### Step 3: Check Bundle ID
```
1. In Xcode, check Bundle Identifier
2. Should match: com.example.destinydecoderapp
3. Use same Bundle ID in App Store Connect
4. (Or update both to match your domain)
```

### Step 4: Configure Code Signing
```
1. In Xcode → Runner target → Signing & Capabilities
2. Team: Select your Apple Developer Team
3. Bundle Identifier: com.example.destinydecoderapp
4. Automatically manage signing: ✓ checked
5. Xcode will handle certificates
```

---

## 🏪 App Store Connect Setup

### Step 1: Create App
```
1. Go to https://appstoreconnect.apple.com
2. Click "My Apps"
3. Click "+" → "New App"
4. Fill in:
   - Platform: iOS
   - Name: Destiny Decoder
   - Primary Language: English
   - Bundle ID: com.example.destinydecoderapp
   - SKU: com.example.destinydecoderapp (unique)
5. Click "Create"
```

### Step 2: Create Subscription Group
```
1. Left sidebar → In-App Purchases
2. Click "+" → "Subscription"
3. Click "Create Subscription Group"
4. Name: Premium Features
5. Reference name: premium_features
6. Click "Create"
```

### Step 3: Create Subscriptions

#### Subscription 1: Premium Monthly
```
1. Group: Premium Features (just created)
2. Product ID: destiny_decoder_premium_monthly
3. Reference Name: Premium Monthly
4. Subscription Duration: 1 Month
5. Price tier: Tier 10 ($2.99 USD)
6. Localization: Add name/description
7. Click "Save"
```

#### Subscription 2: Premium Annual
```
1. Group: Premium Features
2. Product ID: destiny_decoder_premium_annual
3. Reference Name: Premium Annual
4. Subscription Duration: 1 Year
5. Price tier: Tier 100 ($24.99 USD)
6. Localization: Add name/description
7. Click "Save"
```

#### Subscription 3: Pro Annual
```
1. Group: Premium Features
2. Product ID: destiny_decoder_pro_annual
3. Reference Name: Pro Annual
4. Subscription Duration: 1 Year
5. Price tier: Tier 200 ($49.99 USD)
6. Localization: Add name/description
7. Click "Save"
```

### Step 4: Create Test Account (Sandbox)
```
1. Left sidebar → Users and Roles
2. Click "Sandbox Testers"
3. Click "+" to add tester
4. Fill in:
   - Email: test1@icloud.com (or your test email)
   - Name: Test User
   - Password: (auto-generated)
5. Country/region: United States
6. Age: Adult
7. Click "Create"
8. Save credentials for testing
```

---

## 📱 iOS Device/Simulator Setup

### Sandbox Tester on Simulator
```
1. Run app on iOS simulator
2. Go to Settings app → Passwords & Security
3. Scroll to "Share Across Devices"
4. Add your Sandbox tester account
5. Or sign in with test account when prompted

Note: Simulator doesn't show "Test" indicator
      Use test account to get free/discounted purchases
```

### Sandbox Tester on Real Device
```
1. Device Settings → [Your Name] → iCloud
2. Sign out of your personal account
3. Go to App Store
4. Click your profile icon (top right)
5. Tap "Sign In"
6. Use Sandbox tester credentials
7. Confirm with 2FA if needed
```

### Important for Testing
```
⚠️ You MUST sign in with sandbox test account
❌ Real account = real charges (avoid!)
✅ Test account = free/1-minute expiring subscriptions
✅ Test purchases don't appear in real receipts
✅ Perfect for development/testing
```

---

## 🔌 iOS Configuration File

Create `lib/core/config/ios_config.dart`:

```dart
/// iOS-specific configuration for Destiny Decoder
class iOSConfig {
  /// App Store Bundle ID
  static const String bundleId = 'com.example.destinydecoderapp';

  /// Subscription product IDs (must match App Store Connect)
  static const String premiumMonthlySku = 'destiny_decoder_premium_monthly';
  static const String premiumAnnualSku = 'destiny_decoder_premium_annual';
  static const String proAnnualSku = 'destiny_decoder_pro_annual';

  /// List of all available subscription SKUs
  static const List<String> subscriptionSkus = [
    premiumMonthlySku,
    premiumAnnualSku,
    proAnnualSku,
  ];

  /// Sandbox tester email (for testing)
  static const String sandboxTesterEmail = 'test1@icloud.com';

  /// Whether to use sandbox
  static const bool useSandbox = true;

  /// Request codes
  static const int purchaseRequestCode = 2001;

  /// Timeouts
  static const int networkTimeoutSeconds = 30;

  /// Backend configuration
  static const String backendBaseUrl = 'http://localhost:8000'; // Change for production
}
```

---

## 🔐 Server Configuration

### For Receipt Validation (Backend)

The iOS app sends:
```json
{
  "user_id": "user123",
  "platform": "ios",
  "receipt_data": "base64_encoded_receipt",
  "product_id": "destiny_decoder_premium_monthly"
}
```

Backend must validate:
```python
# backend/app/services/subscription_service.py
# Implement validate_receipt() for iOS:

async def validate_receipt_apple(receipt_data: str):
    """
    Validate Apple StoreKit receipt
    
    Call Apple API with receipt
    Confirm subscription is valid
    Extract transaction ID
    Return subscription details
    """
    pass  # TODO: Implement
```

### Test Receipt Validation

Use Apple's test receipts:
```
# Test receipt format
{
  "environment": "Sandbox",
  "latest_receipt_info": [
    {
      "transaction_id": "test_transaction_123",
      "product_id": "destiny_decoder_premium_monthly",
      "expires_date_ms": "1674259199000",
      "is_trial_period": "false"
    }
  ]
}
```

---

## 🧪 Testing Workflow

### Test 1: Verify Products Load
```
1. Run app on simulator/device
2. Go to Settings → Subscription
3. Should see three pricing options
4. Paywall should display all products
5. No errors in console
```

### Test 2: Test Purchase Flow
```
1. Attempt action requiring premium (4th reading)
2. Paywall appears
3. Select plan (Premium Monthly recommended)
4. Tap "Start Premium"
5. System pops up:
   "Continue with [Sandbox Tester Email]?" → Tap "Continue"
6. "Confirm Subscription" dialog
7. Tap "Confirm" to complete test purchase
8. ✅ Subscription immediately becomes active
```

### Test 3: Verify Subscription Status
```
1. After purchase completes
2. Settings → Subscription should show "Premium"
3. All features should be unlocked
4. Can save unlimited readings
5. Full interpretation text shows
6. Can export unlimited PDFs
```

### Test 4: Test Cancellation
```
1. Settings → Subscription
2. Tap "Cancel Subscription"
3. Confirm cancellation
4. Status shows "Cancelled"
5. Access retained until expiry
```

### Test 5: Test Restore Purchases
```
1. Uninstall app
2. Reinstall app
3. Go to Settings → Subscription
4. Tap "Restore Purchases"
5. Sign in with sandbox account
6. Previous subscription should restore
7. Premium status returns
```

---

## 🎯 Key Differences: iOS vs Android

| Feature | iOS | Android |
|---------|-----|---------|
| Framework | StoreKit 2 | Google Play Billing |
| Testing | Sandbox accounts | Test accounts + test cards |
| Receipts | JWT format | JSON format |
| Validation | Apple servers | Google servers |
| Expiry | Auto-renewing | Auto-renewing |
| Cancellation | App Store Settings | Google Play Settings |
| Testing Cost | Free/discounted | Free/discounted |

---

## 📋 Checklist Before Testing

- [ ] iOS deployment target set to 12.0+
- [ ] In-App Purchase capability added in Xcode
- [ ] Bundle ID matches App Store Connect
- [ ] Code signing configured
- [ ] App created in App Store Connect
- [ ] Subscription group created (Premium Features)
- [ ] 3 subscriptions created with exact Product IDs
- [ ] Sandbox tester account created
- [ ] Sandbox tester email recorded
- [ ] pubspec.yaml has all IAP packages
- [ ] `pub get` run to download dependencies
- [ ] iOS config file created

---

## 🔗 Key Differences from Android

### Android Uses:
```dart
// Google Play package name
static const String googlePlayPackageName = 'com.example.destiny_decoder_app';

// Test accounts in Google Play Console
// Test cards in Google Play
```

### iOS Uses:
```dart
// Bundle ID
static const String bundleId = 'com.example.destinydecoderapp';

// Sandbox tester accounts in App Store Connect
// Automatic test receipts
```

---

## 🚀 Quick Start for iOS

```bash
# 1. Update iOS deployment target
cd ios
nano Podfile
# Change platform :ios, '11.0' to '12.0'
# Save and exit

# 2. Install pods
pod install
cd ..

# 3. Open Xcode and add In-App Purchase capability
open ios/Runner.xcworkspace

# 4. Run on simulator
flutter run -d iphone

# 5. Test in Settings → Subscription
```

---

## ⚠️ Important Reminders

### Sandboxes is REQUIRED
```
❌ Don't test with real account
❌ Don't use real payment method
✅ Always use sandbox tester account
✅ Test purchases are free/discounted
✅ No real charges ever
```

### Product IDs Must Match
```
iOS: Create exact same Product IDs as backend expects
- destiny_decoder_premium_monthly
- destiny_decoder_premium_annual
- destiny_decoder_pro_annual
```

### Testing Subscriptions Expire Quickly
```
1-minute subscriptions expire in 1 minute
5-minute subscriptions expire in 5 minutes
Perfect for rapid testing!
```

---

## 🔗 Useful Resources

- Apple Documentation: https://developer.apple.com/in-app-purchase/
- StoreKit 2 Guide: https://developer.apple.com/documentation/storekit
- Testing: https://developer.apple.com/documentation/storekit/testing

---

## 📊 Product ID Reference

Keep these consistent across platforms:

```
Monthly:  destiny_decoder_premium_monthly
Annual:   destiny_decoder_premium_annual
Pro:      destiny_decoder_pro_annual
```

---

**iOS setup complete and ready for testing!** 🚀

