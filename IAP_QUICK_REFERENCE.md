# IAP Quick Reference Guide 🚀

**Last Updated:** January 24, 2026  
**Commit:** fd8da9b

---

## 📋 Testing Checklist

### Pre-Testing Setup
```bash
# 1. Backend Environment
APPLE_SHARED_SECRET=<from_app_store_connect>
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON=/path/to/service-account.json

# 2. Product IDs (must match App Store/Play Store)
destiny_decoder_premium_monthly  # $4.99/month
destiny_decoder_premium_annual   # $49.99/year
destiny_decoder_pro_annual       # $99.99/year

# 3. Sandbox Accounts
iOS: Create sandbox tester in App Store Connect
Android: Add license testers in Play Console
```

### Testing Flow
1. ✅ Sign in with sandbox account on device
2. ✅ Launch app, navigate to paywall
3. ✅ Tap "Subscribe" button
4. ✅ Confirm purchase in dialog
5. ✅ Complete payment in native sheet
6. ✅ Verify "Purchase successful" message
7. ✅ Check database: User.subscription_tier updated
8. ✅ Check database: SubscriptionHistory record created
9. ✅ Verify premium features unlocked
10. ✅ Test reading limit removed

---

## 🔗 API Endpoints

### Validate Receipt
```http
POST /api/subscriptions/validate-receipt
Content-Type: application/json
Authorization: Bearer <jwt_token>

{
  "receipt_data": "base64_encoded_receipt",
  "product_id": "destiny_decoder_premium_monthly",
  "platform": "ios"
}

Response:
{
  "message": "Subscription validated successfully",
  "tier": "premium",
  "expires_at": "2026-02-24T12:00:00Z",
  "transaction_id": "1000000123456789"
}
```

### Get Status
```http
GET /api/subscriptions/status
Authorization: Bearer <jwt_token>

Response:
{
  "tier": "premium",
  "is_active": true,
  "expires_at": "2026-02-24T12:00:00Z",
  "auto_renew": true,
  "platform": "ios"
}
```

### Get History
```http
GET /api/subscriptions/history
Authorization: Bearer <jwt_token>

Response:
[
  {
    "transaction_id": "1000000123456789",
    "platform": "ios",
    "started_at": "2026-01-24T12:00:00Z",
    "expires_at": "2026-02-24T12:00:00Z",
    "status": "active",
    "price_usd": 4.99
  }
]
```

---

## 📱 Mobile Purchase Flow

### Initiate Purchase
```dart
// User taps subscribe button
await _initiatePurchase(context, ref, 'premium');

// Maps to product ID
'premium' → ProductIds.premiumMonthly
'pro' → ProductIds.proAnnual
```

### Handle Success
```dart
// PurchaseService automatically:
1. Extracts receipt from PurchaseDetails
2. Calls backend validation endpoint
3. Logs success with tier and expiration
4. Provider refreshes → UI updates
```

### Error Handling
```dart
// Handles:
- IAP unavailable: "In-app purchases not available on this device"
- Product not found: "This subscription is not available right now"
- Purchase failed: "Purchase failed. Please try again later."
- Network error: "Connection error. Please check your network."
```

---

## 🗄️ Database Schema

### User Table
```python
subscription_tier: Enum['free', 'premium', 'pro']
subscription_expires: DateTime (nullable)
```

### SubscriptionHistory Table
```python
user_id: ForeignKey
transaction_id: String (unique)
platform: String ('ios' or 'android')
started_at: DateTime
expires_at: DateTime
status: Enum['active', 'expired', 'cancelled', 'refunded']
price_usd: Decimal
```

---

## 🛠️ Debugging Commands

### Check Backend Logs
```bash
# Docker
docker-compose logs -f backend | grep subscription

# Railway
railway logs --service backend | grep subscription
```

### Test Receipt Validation Manually
```bash
# Apple iTunes Sandbox
curl -X POST https://sandbox.itunes.apple.com/verifyReceipt \
  -H "Content-Type: application/json" \
  -d '{
    "receipt-data": "<base64_receipt>",
    "password": "<shared_secret>"
  }'
```

### Query Database
```sql
-- Check user subscription
SELECT id, email, subscription_tier, subscription_expires 
FROM users 
WHERE email = 'test@example.com';

-- Check transaction history
SELECT * FROM subscription_history 
WHERE user_id = 1 
ORDER BY started_at DESC;
```

---

## ⚠️ Common Issues

### Issue: "Receipt validation failed"
**Cause:** Wrong environment (sandbox receipt sent to production)  
**Solution:** Backend automatically handles 21007 status and retries sandbox

### Issue: "Product not found"
**Cause:** Product IDs don't match App Store/Play Store  
**Solution:** Verify IDs in store configuration match code:
```dart
static const String premiumMonthly = 'destiny_decoder_premium_monthly';
```

### Issue: "Purchase successful but features not unlocked"
**Cause:** Provider not refreshed  
**Solution:** Check paywall_screen.dart line 565:
```dart
ref.invalidate(subscriptionTierProvider);
```

### Issue: "IAP not available"
**Cause:** Testing on simulator/emulator  
**Solution:** Must test on physical device with sandbox account

---

## 📊 Pricing Configuration

| Tier | Product ID | Price | Period |
|------|-----------|-------|--------|
| Premium | `destiny_decoder_premium_monthly` | $4.99 | Monthly |
| Premium | `destiny_decoder_premium_annual` | $49.99 | Annual |
| Pro | `destiny_decoder_pro_annual` | $99.99 | Annual |

**Free Tier:** 3 readings/month, basic features only

---

## 🔐 Security Checklist

- [x] Receipt validation server-side only
- [x] JWT authentication on all endpoints
- [x] Transaction IDs stored for audit
- [x] Passwords/secrets in environment variables
- [x] No sensitive data in client logs
- [x] HTTPS for all API calls
- [x] User.subscription_tier validated on every request

---

## 🚀 Production Deployment

### Backend Configuration
1. Set `APPLE_SHARED_SECRET` from App Store Connect
2. Add Google service account JSON to secrets
3. Switch to production iTunes URL (automatic fallback handles this)
4. Add monitoring for failed validations

### Mobile Configuration
1. Verify product IDs in App Store Connect
2. Verify product IDs in Google Play Console
3. Test restore purchases flow
4. Submit for app review with sandbox tester account

### Monitoring
```bash
# Track validation failures
grep "Receipt validation failed" logs/*.log | wc -l

# Track successful purchases
grep "Subscription validated successfully" logs/*.log | wc -l

# Check subscription distribution
SELECT subscription_tier, COUNT(*) FROM users GROUP BY subscription_tier;
```

---

## 📞 Support Scenarios

### User: "I purchased but still see paywall"
1. Check subscriptionHistory for transaction_id
2. Verify User.subscription_tier = 'premium' or 'pro'
3. Verify subscription_expires > NOW()
4. Ask user to force-quit and restart app
5. Check JWT token includes updated tier

### User: "Purchase failed after payment"
1. Check backend logs for validation errors
2. Verify receipt sent to backend (purchase_service.dart logs)
3. Check Apple/Google transaction in their respective consoles
4. Manually update User.subscription_tier if receipt valid

### User: "Want to cancel subscription"
1. iOS: Settings > Apple ID > Subscriptions
2. Android: Play Store > Subscriptions
3. User retains access until expiration
4. Backend handles expiration automatically

---

## 🔄 Subscription Lifecycle

```
NEW USER
  ↓
FREE TIER (3 readings/month)
  ↓
[User taps Subscribe]
  ↓
PAYMENT FLOW (Apple/Google)
  ↓
RECEIPT VALIDATION (Backend)
  ↓
PREMIUM/PRO TIER (unlimited)
  ↓
[Auto-renewal every month/year]
  ↓
[User cancels OR payment fails]
  ↓
GRACE PERIOD (still active until expires_at)
  ↓
EXPIRED (revert to FREE TIER)
```

---

## 📝 Files Modified

```
Backend:
├─ backend/app/services/receipt_validation_service.py (NEW)
└─ backend/app/api/routes/subscriptions.py (MODIFIED)

Mobile:
├─ mobile/lib/core/iap/purchase_service.dart (MODIFIED)
└─ mobile/lib/features/paywall/paywall_screen.dart (MODIFIED)
```

---

## ✅ Final Verification

```bash
# 1. Backend running
curl http://localhost:8000/health

# 2. Mobile build successful
cd mobile/destiny_decoder_app
flutter analyze
# Expected: No issues found

# 3. Git status clean
git status
# Expected: nothing to commit, working tree clean

# 4. Commit pushed
git log --oneline -1
# Expected: fd8da9b Phase 3C: Complete IAP integration
```

---

**Status:** ✅ Ready for Sandbox Testing  
**Next:** Configure Apple/Google sandbox credentials and test on physical devices
