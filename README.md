# Destiny Decoder

A numerology-based destiny reading application with FastAPI backend and Flutter cross-platform mobile app.

## Features

- **Destiny Calculation**: Calculate life seal, soul number, personality number, and more
- **Life Cycles**: Track personal year cycles and turning points
- **Compatibility**: Check numerological compatibility with partners
- **PDF Reports**: Generate and export full readings as PDF
- **Cross-Platform**: Works on web, iOS, and Android

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
