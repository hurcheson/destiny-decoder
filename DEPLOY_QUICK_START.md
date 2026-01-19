# ⚡ DEPLOY BACKEND - QUICK START

**Status:** ✅ Fixed & Ready! (SQLAlchemy version constraint fixed)

**Everything is ready! Follow these 3 steps:**

---

## Step 1: Deploy to Railway (10 mins) 

1. **Go to:** https://railway.app
2. **Sign up** with GitHub
3. **New Project** → "Deploy from GitHub repo"
4. **Select:** `destiny-decoder` repository
5. **Settings** → Set root directory: `backend`
6. **Deploy!** Railway builds automatically

**You'll get a URL like:**
```
https://destiny-decoder-production.up.railway.app
```

📖 **Detailed guide:** See [DEPLOY_RAILWAY_NOW.md](DEPLOY_RAILWAY_NOW.md)

---

## Step 2: Update Mobile App (2 mins)

Edit: `mobile/destiny_decoder_app/lib/core/config/android_config.dart`

**Change line 7:**
```dart
static const String currentEnvironment = production;  // ← was: development
```

**Update line 13 with your Railway URL:**
```dart
case production:
  return 'https://your-railway-url.up.railway.app';  // ← YOUR URL
```

---

## Step 3: Test (5 mins)

**Test backend:**
```bash
curl https://your-url.railway.app/health
```

**Test mobile app:**
```bash
cd mobile/destiny_decoder_app
flutter run -d emulator-5554
# Try creating a reading!
```

---

## ✅ What's Deployed

- ✅ **All numerology endpoints** (calculate, decode, compatibility, PDF)
- ✅ **Daily insights** (power numbers, blessed days, personal month)
- ✅ **Push notifications backend** (scheduler running)
- ✅ **Subscription endpoints** (ready for Phase 7.2)
- ✅ **Rate limiting** (100 requests/minute)
- ✅ **CORS enabled** (mobile apps can connect)
- ✅ **Health monitoring** (/health endpoint)

---

## 💰 Cost: FREE

Railway free tier includes:
- 500 execution hours/month
- Perfect for testing and early users
- Upgrade to $5/month when needed

---

## 🚨 Important Notes

1. **Database:** SQLite works but not ideal for production
   - For now: Works great for testing
   - Later: Upgrade to PostgreSQL when you have many users

2. **Environment:** Currently set to `production` mode
   - Firebase may show warnings (that's OK)
   - Scheduler runs (that's OK)
   - Everything works!

3. **No Auth Yet:** Endpoints are open
   - Rate limited to 100 req/min
   - Good for testing
   - Add authentication in Phase 7.3

---

## 📱 After Deployment: Submit to Stores

Once backend is live and tested:

1. **Google Play Console:**
   - Build release APK/Bundle
   - Upload to Play Console
   - Submit for review (1-3 days)

2. **App Store Connect:**
   - Build iOS release
   - Upload to App Store
   - Submit for review (1-2 weeks)

---

## 🎯 Current Status

✅ **Phase 1-5:** Complete (core numerology, Firebase, push notifications)  
✅ **Phase 6.1:** Complete (daily insights)  
✅ **Phase 6.4:** Complete (analytics)  
✅ **Phase 6.7:** Complete (push notifications)  
✅ **Phase 7.1:** Complete (subscription infrastructure)  
⏸️ **Google Play:** Paused (team discussion needed)  
🚀 **READY TO DEPLOY!**

---

## 🔗 Quick Links

- **Deploy:** https://railway.app
- **Full Guide:** [DEPLOY_RAILWAY_NOW.md](DEPLOY_RAILWAY_NOW.md)
- **All Options:** [DEPLOY_NOW.md](DEPLOY_NOW.md)
- **Feature Status:** [PRE_DEPLOYMENT_FEATURE_STATUS.md](PRE_DEPLOYMENT_FEATURE_STATUS.md)

---

**🎉 You're 10 minutes away from having a live backend! Let's go! 🚀**
