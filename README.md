# Destiny Decoder

A beautiful, feature-rich numerology application with FastAPI backend and Flutter cross-platform mobile app.

## ✨ Features

- **🔮 Destiny Calculation**: Life seal, soul number, personality number, personal year
- **📈 Life Journey Timeline**: Interactive visualization with life cycles and turning points
- **💕 Compatibility Analysis**: Check numerological compatibility with partners
- **📄 PDF Reports**: Professional 4-page reports with interpretations
- **💾 Reading History**: Save and revisit unlimited readings
- **🖼️ Image Export**: Share readings as beautiful images
- **🌙 Onboarding Flow**: 5-screen welcome experience
- **🎨 Premium Design**: Smooth animations, dark mode, planet-color theming
- **📱 Cross-Platform**: iOS, Android, and Web support

## Project Structure

```
destiny-decoder/
├── backend/              # FastAPI Python backend
│   ├── app/
│   │   ├── api/         # API routes and schemas
│   │   ├── core/        # Numerology calculations
│   │   ├── interpretations/  # Interpretation logic
│   │   ├── models/      # Data models
│   │   └── services/    # Business logic
│   └── main.py          # FastAPI app entry point
├── mobile/              # Flutter app
│   └── destiny_decoder_app/
├── requirements.txt     # Python dependencies
├── Dockerfile          # Docker configuration
├── docker-compose.yml  # Docker Compose setup
└── DEPLOYMENT.md       # Deployment guide
```

## Getting Started

### Backend Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run development server
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

# API docs available at: http://localhost:8000/docs
```

### Frontend Development

```bash
cd mobile/destiny_decoder_app

# Install dependencies
flutter pub get

# Run app
flutter run
```

## API Documentation

Full API documentation available at `/docs` when backend is running.

### Key Endpoints

- **POST** `/calculate-destiny` - Core destiny calculations
- **POST** `/decode/full` - Full reading with interpretations

## Deployment

For detailed deployment instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

Quick start with Docker:
```bash
docker-compose up -d
```

## Testing

```bash
# Backend tests
pytest

# Frontend tests
cd mobile/destiny_decoder_app
flutter test
```

## Development

### Backend Stack
- FastAPI 0.104.1
- Pydantic for validation
- ReportLab for PDF generation

### Frontend Stack
- Flutter 3.0+
- Riverpod for state management
- Dio for HTTP requests

## 📚 Documentation

### Getting Started
- **[QUICK_START_GUIDE.md](QUICK_START_GUIDE.md)** - Get up and running in 5 minutes
- **[CODEBASE_OVERVIEW.md](CODEBASE_OVERVIEW.md)** - Architecture and technical details
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Complete deployment guide

### Development
- **[PRODUCT_ROADMAP_2026.md](PRODUCT_ROADMAP_2026.md)** - Future features and roadmap
- **[IMPLEMENTATION_HISTORY.md](IMPLEMENTATION_HISTORY.md)** - What's been built (Phases 1-5)
- **[docs/formulas.md](docs/formulas.md)** - Numerology calculation specifications

### Quick Deploy
- **[QUICK_DEPLOY.md](QUICK_DEPLOY.md)** - One-command deployment options
- **[PRE_DEPLOYMENT_CHECKLIST.md](PRE_DEPLOYMENT_CHECKLIST.md)** - Pre-launch verification

## Environment Variables

See `.env.example` for all available configuration options.

## Security Notes

⚠️ **Before Production Deployment:**
- Update CORS origins in `backend/main.py`
- Set `DEBUG=false`
- Use HTTPS for all endpoints
- Implement rate limiting if needed
- Configure proper authentication if required

## Support

For issues or questions, refer to the deployment guide and troubleshooting section in [DEPLOYMENT.md](DEPLOYMENT.md).
