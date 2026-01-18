# 🚀 Deploy to Railway - 10 Minute Guide

**Current Status:** ✅ Backend Ready for Deployment  
**Platform:** Railway.app (Easiest & Fastest)  
**Cost:** FREE (then $5/month if needed)

---

## ✅ What's Already Done

- ✅ Rate limiting added (100 requests/minute)
- ✅ CORS configured for mobile apps
- ✅ Health check endpoint at `/health`
- ✅ `Procfile` created
- ✅ `railway.json` created  
- ✅ `requirements.txt` generated
- ✅ Python 3.11 specified

**All code committed to git!**

---

## 🏃 Deploy NOW (10 Minutes)

### Step 1: Sign Up for Railway (2 minutes)

1. Go to: **https://railway.app**
2. Click **"Start a New Project"**
3. Sign up with GitHub (recommended)
   - Or use email/Google

### Step 2: Create New Project (3 minutes)

1. **New Project** button
2. Select **"Deploy from GitHub repo"**
3. **Connect your GitHub account** (if not already)
4. **Select repository:** `destiny-decoder`
5. Railway will auto-detect:
   - ✅ Python project
   - ✅ FastAPI application
   - ✅ Procfile configuration

### Step 3: Configure Project (2 minutes)

Railway Dashboard → **Settings**:

1. **Root Directory:** Set to `backend`
   - Variables → Add variable
   - Name: `RAILWAY_ROOT_DIR`
   - Value: `backend`

2. **Environment Variables** (click "+ New Variable"):
   ```
   ENVIRONMENT=production
   ```

3. **Optional** (if using Firebase):
   ```
   FIREBASE_CREDENTIALS_PATH=/app/firebase-key.json
   ```

### Step 4: Deploy! (1 minute)

1. Railway will automatically start building
2. Watch the logs in real-time
3. Wait for: **"Build successful ✓"**
4. Wait for: **"Deploy successful ✓"**

**You'll get a URL like:**
```
https://destiny-decoder-production.up.railway.app
```

### Step 5: Test Deployment (2 minutes)

**Test Health Endpoint:**
```bash
curl https://your-url.railway.app/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "services": {
    "api": "running",
    "firebase": "initialized",
    "scheduler": "running"
  }
}
```

**Test Decode Endpoint:**
```bash
curl -X POST https://your-url.railway.app/decode/full \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "birth_date": "1990-01-15"
  }'
```

Should return full numerology reading!

---

## 📱 Update Mobile App (5 Minutes)

### Edit Configuration File

Open: `mobile/destiny_decoder_app/lib/core/config/android_config.dart`

**Find this line:**
```dart
static const String currentEnvironment = development;
```

**Change to:**
```dart
static const String currentEnvironment = production;
```

**Add your Railway URL:**
```dart
case production:
  return 'https://your-project-name.up.railway.app';  // ← YOUR URL HERE
```

### Complete Example:
```dart
class EnvironmentConfig {
  static const String development = 'development';
  static const String staging = 'staging';
  static const String production = 'production';
  
  // ← CHANGE THIS LINE
  static const String currentEnvironment = production;

  static String getBackendUrl() {
    switch (currentEnvironment) {
      case development:
        return 'http://10.0.2.2:8000';
      case staging:
        return 'https://staging-api.destinydecoderapp.com';
      case production:
        return 'https://destiny-decoder-production.up.railway.app';  // ← YOUR URL
      default:
        return 'http://10.0.2.2:8000';
    }
  }
}
```

### Test Mobile App

```bash
cd mobile/destiny_decoder_app
flutter clean
flutter pub get
flutter run -d emulator-5554
```

**Try these actions:**
1. Create a reading → Should work!
2. Export PDF → Should work!
3. Check compatibility → Should work!
4. View daily insights → Should work!

---

## 🎉 You're Live!

### Your Backend is Now:

✅ **Deployed** to Railway  
✅ **Live** at your Railway URL  
✅ **Rate Limited** (100 req/min)  
✅ **CORS Enabled** for mobile  
✅ **Health Monitored** via `/health`  
✅ **Auto-scaling** on Railway  
✅ **Free tier** (500 hours/month)

---

## 📊 Monitor Your App

### Railway Dashboard

**View Logs:**
- Dashboard → Deployments → View Logs
- See all API requests in real-time

**Check Metrics:**
- Dashboard → Metrics
- CPU, Memory, Network usage

**View Deployments:**
- Dashboard → Deployments
- History of all deploys

### Set Up Alerts (Optional)

1. Dashboard → Settings → Notifications
2. Add email or Slack webhook
3. Get notified of:
   - Deploy failures
   - High CPU/memory
   - Crashes

---

## 🔧 Troubleshooting

### Issue: "Build failed"

**Check logs for error:**
- Usually missing dependency
- Fix: Update `requirements.txt`
- Redeploy

### Issue: "Deploy succeeded but app won't start"

**Check if port is correct:**
- Railway provides `$PORT` environment variable
- Procfile should have: `--port $PORT`
- ✅ Already configured!

### Issue: "502 Bad Gateway"

**Check application logs:**
- Dashboard → Logs
- Look for Python errors
- Common: Database file not writable

**Fix:**
```python
# SQLite may not work on Railway
# Consider PostgreSQL for production
# Or use Railway's SQLite volume
```

### Issue: Mobile app can't connect

**Verify URL in mobile app:**
1. Check `android_config.dart` has correct URL
2. Verify URL in browser works: `https://your-url.railway.app/health`
3. Check Railway app is running (not crashed)

### Issue: CORS errors

**Already configured, but if needed:**
```python
# backend/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Already set
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

---

## 💰 Railway Pricing

### Free Tier
- **500 execution hours/month**
- **512 MB RAM**
- **1 GB outbound network**
- **Perfect for testing!**

### Hobby Plan ($5/month)
- **Unlimited execution hours**
- **8 GB RAM**
- **100 GB outbound network**
- **Upgrade when needed**

**For Ghana users:** Railway accepts all cards including GH cards

---

## 🚀 Next Steps After Deployment

### 1. Custom Domain (Optional)

**Railway allows custom domains:**
1. Dashboard → Settings → Domains
2. Add your domain: `api.destinydecoderapp.com`
3. Update DNS records
4. Railway provides automatic HTTPS!

### 2. Database Upgrade (Later)

**If you need persistent database:**
1. Railway → Add PostgreSQL database
2. Update `DATABASE_URL` env variable
3. Migrate from SQLite

### 3. Monitoring (Optional)

**Add monitoring service:**
- Sentry (error tracking)
- LogRocket (session replay)
- Datadog (performance monitoring)

### 4. Submit to App Stores

**Now that backend is live:**
1. Update mobile app with production URL
2. Test thoroughly
3. Submit to Google Play Console
4. Submit to App Store Connect

---

## ✅ Deployment Checklist

- [x] Backend code ready
- [x] Rate limiting added
- [x] CORS configured
- [x] Health endpoint working
- [x] Deployment files created
- [x] Requirements.txt generated
- [ ] Railway account created
- [ ] Project deployed to Railway
- [ ] Health endpoint tested
- [ ] Mobile app updated with URL
- [ ] Mobile app tested with production backend
- [ ] Ready for app store submission!

---

## 🎯 Quick Commands

**Redeploy after changes:**
```bash
git add -A
git commit -m "Update feature X"
git push origin main
```
Railway auto-deploys on push to main!

**View logs:**
```bash
# Railway CLI (optional)
npm install -g @railway/cli
railway login
railway logs
```

**Test endpoint:**
```bash
curl https://your-url.railway.app/health
```

---

## 🔗 Useful Links

- **Railway Dashboard:** https://railway.app/dashboard
- **Railway Docs:** https://docs.railway.app
- **Railway Status:** https://status.railway.app
- **Railway Discord:** https://discord.gg/railway

---

**🎉 Your backend is production-ready! Deploy now and go live! 🚀**

**Time to deploy:** 10 minutes  
**Cost:** FREE  
**Result:** Live backend API for your app

**Ready? Go to https://railway.app and click "Start a New Project"!**
