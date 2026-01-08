# Destiny Decoder - Deployment Guide

## Pre-Deployment Checklist

### Backend (FastAPI)
- [x] All dependencies listed in `requirements.txt`
- [x] Environment variables template in `.env.example`
- [x] Docker containerization ready
- [x] CORS configuration with production warnings
- [ ] API endpoints tested and working
- [ ] Database configuration (if needed)
- [ ] Logging configured
- [ ] Error handling verified

### Frontend (Flutter)
- [ ] Dependencies in `pubspec.yaml` verified
- [ ] API URL configured for target environment
- [ ] Build tested for all target platforms
- [ ] Error handling for network failures
- [ ] Loading states implemented

## Backend Deployment

### Local Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

### Docker Deployment
```bash
# Build image
docker build -t destiny-decoder-api:latest .

# Run container
docker run -p 8000:8000 \
  -e DEBUG=false \
  destiny-decoder-api:latest

# Or use docker-compose
docker-compose up -d
```

### Environment Variables
Create a `.env` file from `.env.example` and configure:
```
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
BACKEND_RELOAD=false
DEBUG=false
FLUTTER_APP_API_URL=https://api.yourdomain.com
```

### Production Deployment

#### Critical Security Settings
1. **Update CORS Origins** in `backend/main.py`:
   ```python
   allow_origins=[
       "https://yourdomain.com",
       "https://app.yourdomain.com"
   ]
   ```

2. **Set DEBUG=false** in environment

3. **Use HTTPS** for all API calls

4. **Consider adding:**
   - Rate limiting
   - Request validation
   - API authentication if needed
   - Logging and monitoring

#### Deployment Platforms

**Option 1: Docker on Cloud (AWS, GCP, Azure)**
```bash
docker build -t your-registry/destiny-decoder-api:latest .
docker push your-registry/destiny-decoder-api:latest
# Then deploy to your container service (ECS, Cloud Run, ACI, etc.)
```

**Option 2: Heroku**
```bash
heroku create your-app-name
heroku config:set DEBUG=false
git push heroku main
```

**Option 3: Railway/Render**
- Connect GitHub repo
- Set root directory to backend
- Configure environment variables
- Auto-deploy on push

**Option 4: Traditional VPS (DigitalOcean, Linode)**
```bash
# Install Python 3.11+
# Clone repository
git clone <repo-url>
cd destiny-decoder

# Setup virtual environment
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt

# Use systemd or supervisor to run uvicorn
# Configure nginx as reverse proxy
# Setup SSL with Let's Encrypt
```

## Frontend Deployment

### Flutter Web
```bash
cd mobile/destiny_decoder_app
flutter build web --release
# Output in: build/web/
```

Deploy to:
- **Firebase Hosting**: `firebase deploy`
- **Netlify**: Connect GitHub or drag/drop `build/web/`
- **Vercel**: `vercel deploy`
- **AWS S3 + CloudFront**: Upload to S3 bucket

### Flutter Mobile

**iOS**
```bash
cd mobile/destiny_decoder_app
flutter build ios --release
# Use Xcode to submit to App Store
```

**Android**
```bash
flutter build appbundle --release
# Upload to Google Play Console
```

## API Endpoints

### Core Endpoints
- **POST** `/calculate-destiny` - Calculate all destiny numbers from birth data
- **POST** `/decode/full` - Get full interpretation with narrative

### Required Request Format
```json
{
  "day_of_birth": 15,
  "month_of_birth": 6,
  "year_of_birth": 1990,
  "first_name": "John",
  "other_names": "Michael",
  "partner_name": "Jane" (optional),
  "current_year": 2024 (optional)
}
```

## Testing Before Deploy

### Backend
```bash
# Run tests
pytest

# Check code style
flake8 backend/

# Type checking (if using mypy)
mypy backend/
```

### Frontend
```bash
cd mobile/destiny_decoder_app

# Run tests
flutter test

# Check formatting
dart format lib/

# Analyze
dart analyze
```

## Monitoring & Maintenance

### Logs
- Backend: Configure logging with Python logging module
- Check container logs: `docker logs <container-id>`

### Uptime Monitoring
- Use services like Uptime Robot or Datadog
- Configure health checks on your hosting platform

### Updates
- Regularly update dependencies: `pip list --outdated`
- Monitor security vulnerabilities
- Keep FastAPI, Flutter, and dependencies current

## Troubleshooting

### Backend won't start
- Check Python version (3.8+)
- Verify all dependencies installed: `pip list`
- Check port isn't in use: `lsof -i :8000` (Linux/Mac)

### CORS errors
- Update `allow_origins` in `backend/main.py`
- Ensure frontend URL matches exactly (https://, domain, port)

### Flutter can't connect to API
- Verify backend is running: `curl http://api-url/docs`
- Check API URL in Flutter app configuration
- Check network connectivity and firewalls

## Next Steps

1. [ ] Test all API endpoints locally
2. [ ] Set up monitoring and logging
3. [ ] Configure proper CORS origins for production
4. [ ] Set up CI/CD pipeline for automated deployments
5. [ ] Configure SSL/TLS certificates
6. [ ] Set up backup strategy for any persistent data
7. [ ] Document API usage for clients
8. [ ] Plan scaling strategy if needed
