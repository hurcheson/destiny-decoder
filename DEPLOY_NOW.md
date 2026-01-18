# 🚀 Deploy Backend NOW - Quick Guide

**Status:** Ready to Deploy  
**Target:** Production Backend for Destiny Decoder  
**Date:** January 18, 2026

---

## 🎯 Deployment Options (Choose One)

### Option 1: Heroku (Easiest - 15 minutes)
✅ One-click deploy  
✅ Free tier available  
✅ Automatic HTTPS  
✅ Easy scaling  
💰 Free (or $7/month for always-on)

### Option 2: DigitalOcean (Recommended - 30 minutes)
✅ $6/month droplet  
✅ Full control  
✅ Fast in Africa  
✅ Simple setup  
💰 $6/month

### Option 3: Railway (Fastest - 10 minutes)
✅ Modern platform  
✅ GitHub integration  
✅ Free tier  
✅ Auto-deploy on push  
💰 Free ($5/month for more resources)

### Option 4: Render (Good Alternative - 15 minutes)
✅ Free tier  
✅ Auto-deploy  
✅ HTTPS included  
✅ Good for Python  
💰 Free (spins down after inactivity)

---

## 🏃 FASTEST PATH: Railway (10 Minutes)

### Step 1: Prepare Backend (2 minutes)

Create `requirements.txt` if missing:
```bash
cd backend
pip freeze > requirements.txt
```

Create `Procfile`:
```
web: uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

Create `railway.json`:
```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "uvicorn app.main:app --host 0.0.0.0 --port $PORT",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

### Step 2: Deploy to Railway (5 minutes)

1. **Go to Railway:** https://railway.app
2. **Sign up** with GitHub
3. **New Project** → Deploy from GitHub repo
4. **Select** your `destiny-decoder` repo
5. **Root directory:** `backend`
6. **Deploy!**

Railway will:
- ✅ Auto-detect Python
- ✅ Install dependencies
- ✅ Start server
- ✅ Give you a URL: `https://destiny-decoder-production.up.railway.app`

### Step 3: Configure Environment (1 minute)

In Railway dashboard:
- Add environment variable: `ENVIRONMENT=production`
- Add: `FIREBASE_CREDENTIALS_PATH=/app/firebase-key.json` (if using Firebase)

### Step 4: Update Mobile App (2 minutes)

Edit `mobile/destiny_decoder_app/lib/core/config/android_config.dart`:

```dart
class EnvironmentConfig {
  static const String currentEnvironment = production;  // ← Change this
  
  static String getBackendUrl() {
    switch (currentEnvironment) {
      case production:
        return 'https://destiny-decoder-production.up.railway.app';  // ← Your Railway URL
      // ... rest
    }
  }
}
```

**Done! Backend deployed! 🎉**

---

## 💪 BETTER CONTROL: DigitalOcean (30 Minutes)

### Step 1: Create Droplet (5 minutes)

1. **Sign up:** https://digitalocean.com
2. **Create Droplet:**
   - Ubuntu 22.04 LTS
   - Basic plan: $6/month
   - Region: **Frankfurt** (closest to Ghana)
   - Add SSH key

3. **SSH into droplet:**
```bash
ssh root@your-droplet-ip
```

### Step 2: Install Dependencies (5 minutes)

```bash
# Update system
apt update && apt upgrade -y

# Install Python 3.11
apt install python3.11 python3.11-venv python3-pip -y

# Install nginx (reverse proxy)
apt install nginx -y

# Install supervisor (process manager)
apt install supervisor -y
```

### Step 3: Deploy Application (10 minutes)

```bash
# Create app directory
mkdir -p /var/www/destiny-decoder
cd /var/www/destiny-decoder

# Clone your repo (or upload files)
git clone https://github.com/yourusername/destiny-decoder.git .

# Create virtual environment
cd backend
python3.11 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install gunicorn

# Test server
gunicorn app.main:app --bind 0.0.0.0:8000 --workers 4
# Ctrl+C to stop
```

### Step 4: Configure Nginx (5 minutes)

Create `/etc/nginx/sites-available/destiny-decoder`:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # or use IP for now

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable site:
```bash
ln -s /etc/nginx/sites-available/destiny-decoder /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx
```

### Step 5: Configure Supervisor (5 minutes)

Create `/etc/supervisor/conf.d/destiny-decoder.conf`:

```ini
[program:destiny-decoder]
directory=/var/www/destiny-decoder/backend
command=/var/www/destiny-decoder/backend/venv/bin/gunicorn app.main:app --bind 127.0.0.1:8000 --workers 4
user=root
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
stderr_logfile=/var/log/destiny-decoder.err.log
stdout_logfile=/var/log/destiny-decoder.out.log
```

Start service:
```bash
supervisorctl reread
supervisorctl update
supervisorctl start destiny-decoder
supervisorctl status
```

### Step 6: Configure Firewall

```bash
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw enable
```

### Step 7: Get HTTPS (Optional but Recommended)

```bash
# Install certbot
apt install certbot python3-certbot-nginx -y

# Get certificate (need domain first)
certbot --nginx -d yourdomain.com
```

**Your backend is live at:** `http://your-droplet-ip` or `https://yourdomain.com`

---

## 📝 Pre-Deployment Checklist

### 1. Add CORS Configuration

Edit `backend/app/main.py`:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Destiny Decoder API")

# Add CORS for mobile app
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:*",
        "capacitor://localhost",
        "ionic://localhost",
        "http://localhost",
        "http://localhost:8080",
        "http://localhost:8100",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Your existing routes...
```

### 2. Add Rate Limiting

Install slowapi:
```bash
pip install slowapi
```

Edit `backend/app/main.py`:

```python
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Add to endpoints:
@app.post("/decode/full")
@limiter.limit("10/minute")  # 10 requests per minute
async def decode_full(request: Request, data: DecodeRequest):
    # ... your code
```

### 3. Add Health Check

Edit `backend/app/main.py`:

```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "version": "1.0.0",
        "timestamp": datetime.now().isoformat()
    }
```

### 4. Environment Variables

Create `.env` file (don't commit!):
```env
ENVIRONMENT=production
DATABASE_URL=sqlite:///./destiny_decoder.db
FIREBASE_CREDENTIALS_PATH=./firebase-key.json
SECRET_KEY=your-secret-key-here
```

---

## 🧪 Test Deployment

### Test Endpoints

```bash
# Health check
curl https://your-domain.com/health

# Test calculation
curl -X POST https://your-domain.com/calculate-destiny \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "birth_date": "1990-01-15"}'

# Test full decode
curl -X POST https://your-domain.com/decode/full \
  -H "Content-Type: application/json" \
  -d '{"name": "John Doe", "birth_date": "1990-01-15"}'
```

### Test from Mobile

1. Update android_config.dart with production URL
2. Run app: `flutter run`
3. Try creating a reading
4. Check backend logs for request

---

## 📱 Update Mobile App Configuration

### Option A: Environment-Based (Recommended)

Edit `lib/core/config/android_config.dart`:

```dart
class EnvironmentConfig {
  // Change this line:
  static const String currentEnvironment = production;
  
  static String getBackendUrl() {
    switch (currentEnvironment) {
      case development:
        return 'http://10.0.2.2:8000';
      case staging:
        return 'https://staging-api.destinydecoderapp.com';
      case production:
        return 'https://your-production-url.com';  // ← ADD YOUR URL
      default:
        return 'http://10.0.2.2:8000';
    }
  }
}
```

### Option B: Build Flavors (Advanced)

Create separate builds for dev/staging/prod with different URLs.

---

## 🔍 Monitor Your Deployment

### Check Logs

**Railway:**
- Dashboard → Deployments → View Logs

**DigitalOcean:**
```bash
# Supervisor logs
tail -f /var/log/destiny-decoder.out.log
tail -f /var/log/destiny-decoder.err.log

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### Monitor Performance

Add simple monitoring:
```bash
# Install monitoring (optional)
apt install htop
htop

# Check process
ps aux | grep gunicorn
```

---

## 🚨 Common Issues & Fixes

### Issue: CORS errors from mobile app
**Fix:** Make sure CORS middleware is configured correctly in main.py

### Issue: 502 Bad Gateway
**Fix:** Check if gunicorn is running: `supervisorctl status`

### Issue: Database locked
**Fix:** SQLite doesn't work well with multiple workers. Use PostgreSQL for production or set workers=1

### Issue: Mobile can't connect
**Fix:** 
- Check firewall allows port 80/443
- Test with curl from another machine
- Verify URL in mobile app config

### Issue: Slow responses
**Fix:**
- Increase gunicorn workers: `--workers 4`
- Add caching
- Use faster database (PostgreSQL)

---

## 🎉 Post-Deployment

### 1. Update Documentation

Update these files with your production URL:
- `README.md`
- `QUICK_START_GUIDE.md`
- `android_config.dart`

### 2. Submit to App Stores

Now that backend is live:
1. **Google Play Console:**
   - Update app with production URL
   - Submit for review (1-3 days)

2. **App Store Connect:**
   - Update app with production URL
   - Submit for review (1-2 weeks)

### 3. Monitor Usage

Set up basic analytics:
- Track endpoint usage
- Monitor error rates
- Track response times

### 4. Backup Database

```bash
# Backup SQLite database
cp /var/www/destiny-decoder/backend/destiny_decoder.db /backups/

# Or set up automated backups
```

---

## 💰 Cost Summary

| Platform | Free Tier | Paid Tier | Best For |
|----------|-----------|-----------|----------|
| Railway | 500 hours/month | $5/month | Quick start |
| Render | Spins down after 15 min | $7/month | Side projects |
| Heroku | Limited dynos | $7/month | Easy scaling |
| DigitalOcean | Trial credit | $6/month | Full control |
| AWS/GCP | Free tier 12mo | Variable | Enterprise |

**Recommendation for Ghana:** DigitalOcean Frankfurt region ($6/month) for low latency

---

## 🎯 Quick Decision Guide

**Just want it working fast?**
→ Use **Railway** (10 minutes, free)

**Want full control?**
→ Use **DigitalOcean** (30 minutes, $6/month)

**Want automatic scaling?**
→ Use **Heroku** (15 minutes, $7/month)

**Want free forever?**
→ Use **Render** (15 minutes, free but slower)

---

## ✅ Deployment Checklist

- [ ] Choose platform (Railway/DigitalOcean/Heroku/Render)
- [ ] Add CORS middleware to backend
- [ ] Add rate limiting to endpoints
- [ ] Add health check endpoint
- [ ] Create requirements.txt
- [ ] Deploy backend
- [ ] Test all endpoints with curl
- [ ] Update mobile app config with production URL
- [ ] Test mobile app with production backend
- [ ] Monitor logs for errors
- [ ] Set up backups (for DigitalOcean)
- [ ] Submit app to stores

---

**Ready to deploy? Pick your platform and let's go! 🚀**

**Recommended:** Start with Railway for fastest deployment, then migrate to DigitalOcean if you need more control.
