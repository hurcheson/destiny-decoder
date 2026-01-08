# Quick Deployment Reference

## 🚀 One-Command Deployments

### Local Development
```bash
# Backend
pip install -r requirements.txt
uvicorn backend.main:app --reload

# Frontend
cd mobile/destiny_decoder_app
flutter run
```

### Docker (Recommended)
```bash
# Build and run
docker-compose up -d

# View logs
docker-compose logs -f backend

# Stop
docker-compose down
```

### Deploy to Heroku
```bash
# Install Heroku CLI first
heroku login
heroku create your-app-name
git push heroku main
heroku open
```

### Deploy to Railway
```bash
# Install Railway CLI
railway login
railway init
railway up
```

### Deploy to Google Cloud Run
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Build and push
gcloud builds submit --tag gcr.io/YOUR_PROJECT_ID/destiny-decoder

# Deploy
gcloud run deploy destiny-decoder \
  --image gcr.io/YOUR_PROJECT_ID/destiny-decoder \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

---

## 📋 Pre-Deployment Checklist

```
Backend:
[ ] requirements.txt has all dependencies
[ ] CORS origins updated for production
[ ] .env configured with secrets
[ ] DEBUG=false
[ ] Docker builds successfully: docker build -t api:latest .

Frontend:
[ ] API_BASE_URL configured correctly
[ ] pubspec.yaml dependencies resolved: flutter pub get
[ ] No build errors: flutter analyze
[ ] Build succeeds: flutter build web/appbundle/ios --release

General:
[ ] .gitignore excludes sensitive files
[ ] No hardcoded passwords or API keys
[ ] Tests pass (if applicable)
[ ] README.md is up to date
```

---

## 🔒 Security Checklist

Before deploying to production:

```
[ ] CORS allow_origins is NOT "*"
[ ] DEBUG=false
[ ] HTTPS/SSL configured
[ ] .env file NOT committed to git
[ ] Secrets in .env.example are template values only
[ ] API keys rotated
[ ] Database credentials secured
[ ] Rate limiting configured
[ ] Input validation in place
[ ] Error messages don't expose sensitive info
```

---

## 📊 Environment Variables Quick Reference

| Env | Backend | Frontend | Type |
|-----|---------|----------|------|
| Development | DEBUG=true, RELOAD=true | localhost:8000 | Local |
| Staging | DEBUG=false, test APIs | staging-api.domain.com | Pre-prod |
| Production | DEBUG=false | api.domain.com | Live |

---

## 🐳 Docker Quick Ref

```bash
# Build image
docker build -t destiny-api:latest .

# Run container
docker run -p 8000:8000 destiny-api:latest

# With env file
docker run -p 8000:8000 --env-file .env destiny-api:latest

# Interactive (for debugging)
docker run -it -p 8000:8000 destiny-api:latest bash

# View running containers
docker ps

# View logs
docker logs CONTAINER_ID

# Stop container
docker stop CONTAINER_ID

# Remove image
docker rmi destiny-api:latest
```

---

## 🌐 Hosting Platform Comparison

| Platform | Setup Time | Cost | Auto-scale | Best For |
|----------|-----------|------|-----------|----------|
| **Heroku** | 5 min | Medium | Yes | Quick deploy |
| **Railway** | 5 min | Low | Yes | Cheap & easy |
| **Render** | 5 min | Low | Yes | Free tier available |
| **Google Cloud Run** | 10 min | Pay-per-use | Yes | Serverless |
| **AWS** | 30+ min | Variable | Yes | Enterprise |
| **VPS** (DigitalOcean) | 30+ min | Low | Manual | Full control |

---

## 🔗 API Test Commands

```bash
# Get API docs
curl https://api.yourdomain.com/docs

# Test health
curl https://api.yourdomain.com/

# Calculate destiny
curl -X POST https://api.yourdomain.com/calculate-destiny \
  -H "Content-Type: application/json" \
  -d '{
    "day_of_birth": 15,
    "month_of_birth": 6,
    "year_of_birth": 1990,
    "first_name": "John",
    "other_names": "Michael"
  }'

# Full decode
curl -X POST https://api.yourdomain.com/decode/full \
  -H "Content-Type: application/json" \
  -d '{
    "day_of_birth": 15,
    "month_of_birth": 6,
    "year_of_birth": 1990,
    "first_name": "John",
    "other_names": "Michael"
  }'
```

---

## 📁 Important Files for Deployment

```
destiny-decoder/
├── requirements.txt          ← Python dependencies
├── Dockerfile               ← Container config
├── docker-compose.yml       ← Multi-container setup
├── .env.example            ← Config template
├── README.md               ← Project overview
├── DEPLOYMENT.md           ← Detailed guide
├── PRE_DEPLOYMENT_CHECKLIST.md  ← Verification steps
├── ENVIRONMENT_CONFIG.md   ← Environment setup
├── backend/main.py         ← Entry point
└── mobile/pubspec.yaml     ← Flutter deps
```

---

## 🆘 Common Issues & Fixes

### Port 8000 already in use
```bash
# Find process using port
lsof -i :8000          # Mac/Linux
netstat -ano | findstr :8000  # Windows

# Kill process
kill -9 PID            # Mac/Linux
taskkill /PID PID /F   # Windows
```

### Docker build fails
```bash
# Clear Docker cache
docker system prune -a

# Rebuild
docker build --no-cache -t destiny-api:latest .
```

### CORS errors
Update `backend/main.py`:
```python
allow_origins=["https://yourdomain.com"]
```

### Frontend can't reach backend
1. Verify backend is running: `curl http://localhost:8000/docs`
2. Check API URL in Flutter code matches backend URL
3. Check firewall/network connectivity
4. Check CORS headers: `curl -i http://localhost:8000/docs`

---

## 📞 Support Resources

- **FastAPI Docs**: https://fastapi.tiangolo.com
- **Flutter Docs**: https://flutter.dev/docs
- **Docker Docs**: https://docs.docker.com
- **Heroku Docs**: https://devcenter.heroku.com

See detailed guides in:
- [DEPLOYMENT.md](DEPLOYMENT.md) - Full deployment guide
- [ENVIRONMENT_CONFIG.md](ENVIRONMENT_CONFIG.md) - Environment setup
- [PRE_DEPLOYMENT_CHECKLIST.md](PRE_DEPLOYMENT_CHECKLIST.md) - Verification steps
