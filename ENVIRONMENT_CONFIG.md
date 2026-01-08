# Environment Configuration Guide

## Overview
This guide helps you configure the Destiny Decoder for different deployment environments.

## Backend Configuration

### 1. Development Environment

Create `.env` in the project root:
```env
BACKEND_HOST=localhost
BACKEND_PORT=8000
BACKEND_RELOAD=true
DEBUG=true
FLUTTER_APP_API_URL=http://localhost:8000
```

Run:
```bash
pip install -r requirements.txt
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000
```

### 2. Staging Environment

Create `.env.staging`:
```env
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
BACKEND_RELOAD=false
DEBUG=false
FLUTTER_APP_API_URL=https://staging-api.yourdomain.com
```

Run with Docker:
```bash
docker build -t destiny-decoder-api:staging .
docker run -p 8000:8000 \
  --env-file .env.staging \
  destiny-decoder-api:staging
```

### 3. Production Environment

Create `.env.production`:
```env
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
BACKEND_RELOAD=false
DEBUG=false
FLUTTER_APP_API_URL=https://api.yourdomain.com
```

**Critical Production Settings:**

Update `backend/main.py` CORS configuration:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "https://yourdomain.com",
        "https://app.yourdomain.com",
        "https://www.yourdomain.com"
    ],
    allow_credentials=True,
    allow_methods=["POST", "GET", "OPTIONS"],
    allow_headers=["*"],
)
```

## Frontend Configuration

### 1. Development
In your Flutter code (e.g., in a config file):
```dart
const String API_BASE_URL = 'http://localhost:8000';
```

### 2. Staging
```dart
const String API_BASE_URL = 'https://staging-api.yourdomain.com';
```

### 3. Production
```dart
const String API_BASE_URL = 'https://api.yourdomain.com';
```

**Build and deploy:**
```bash
# Web
flutter build web --release
# Deploy build/web/ to your hosting platform

# Android
flutter build appbundle --release
# Upload to Google Play Console

# iOS
flutter build ios --release
# Upload to App Store using Xcode
```

## Docker Environment Variables

When using Docker, pass environment variables at runtime:

```bash
# Local development with docker-compose
docker-compose up -d

# Production deployment
docker run \
  -e BACKEND_HOST=0.0.0.0 \
  -e BACKEND_PORT=8000 \
  -e DEBUG=false \
  -p 8000:8000 \
  destiny-decoder-api:latest
```

Or create `.env.docker`:
```env
BACKEND_HOST=0.0.0.0
BACKEND_PORT=8000
DEBUG=false
```

Then:
```bash
docker run --env-file .env.docker -p 8000:8000 destiny-decoder-api:latest
```

## Platform-Specific Configuration

### Heroku

Create `Procfile`:
```
web: uvicorn backend.main:app --host 0.0.0.0 --port $PORT
```

Set environment variables:
```bash
heroku config:set DEBUG=false
heroku config:set FLASK_ENV=production
```

### Railway/Render

1. Connect your GitHub repository
2. Set environment variables in dashboard:
   - `DEBUG=false`
   - `BACKEND_PORT=8000`
3. Configure start command: `uvicorn backend.main:app --host 0.0.0.0 --port 8000`

### AWS (ECS)

Create task definition with environment variables:
```json
{
  "environment": [
    {
      "name": "DEBUG",
      "value": "false"
    },
    {
      "name": "BACKEND_PORT",
      "value": "8000"
    }
  ]
}
```

### Google Cloud Run

```bash
gcloud run deploy destiny-decoder \
  --set-env-vars="DEBUG=false,BACKEND_PORT=8000" \
  --image=gcr.io/your-project/destiny-decoder-api
```

## Security Best Practices

### Never commit these to version control:
- `.env` (local environment file)
- Actual API keys or secrets
- Database passwords
- Private configuration

### Use `.env.example` as template:
Everyone gets the template with placeholder values, actual secrets configured per environment.

### Rotate secrets regularly:
- Change API keys periodically
- Update database passwords
- Refresh authentication tokens

### Use secrets management tools:
- Kubernetes Secrets
- AWS Secrets Manager
- Google Cloud Secret Manager
- HashiCorp Vault
- 1Password for teams

## Environment Variables Reference

### Backend Variables
| Variable | Required | Default | Example |
|----------|----------|---------|---------|
| `BACKEND_HOST` | No | `0.0.0.0` | `0.0.0.0` |
| `BACKEND_PORT` | No | `8000` | `8000` |
| `BACKEND_RELOAD` | No | `false` | `false` |
| `DEBUG` | No | `false` | `false` |
| `FLUTTER_APP_API_URL` | No | `http://localhost:8000` | `https://api.yourdomain.com` |

### Frontend Variables
| Variable | Required | Default | Example |
|----------|----------|---------|---------|
| `API_BASE_URL` | Yes | None | `https://api.yourdomain.com` |

## Troubleshooting Configuration Issues

### "Connection refused" errors
- Verify backend is running on correct host:port
- Check firewall rules
- Verify API URL in frontend matches backend address

### CORS errors
- Check `allow_origins` in backend CORS configuration
- Ensure frontend URL matches exactly (protocol, domain, port)
- Check CORS headers in response: `curl -i https://api.yourdomain.com`

### SSL/HTTPS errors
- Verify SSL certificate is valid
- Check certificate chains
- Use `https://` in API URL, not `http://`

### Variable not being picked up
- Verify `.env` file is in correct location
- Check file formatting (no extra spaces)
- Restart application after changing variables
- Use `echo $VARIABLE_NAME` to verify it's set

## Next Steps

1. Choose your deployment platform
2. Configure appropriate environment variables
3. Test with staging environment first
4. Deploy to production with verified settings
5. Monitor logs and error rates
6. Rotate secrets periodically
