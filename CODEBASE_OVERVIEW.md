# Destiny Decoder - Comprehensive Codebase Overview

## 📚 Project Summary

**Destiny Decoder** is a cross-platform numerology application that calculates and interprets destiny readings based on a user's birth date and name. The project consists of:

- **Backend**: FastAPI server (Python) with numerology calculations
- **Frontend**: Flutter mobile app (iOS, Android, Web)
- **Deployment**: Docker-containerized with support for Railway, Heroku, and VPS

---

## 🏗️ Project Architecture

### Backend Stack
- **Framework**: FastAPI (modern async Python web framework)
- **Server**: Uvicorn (ASGI server)
- **PDF Generation**: ReportLab 4.0.7
- **Data Validation**: Pydantic
- **Production**: Gunicorn (WSGI server)

### Frontend Stack
- **Framework**: Flutter 3.0+
- **State Management**: Riverpod (reactive state management)
- **Routing**: GoRouter (declarative navigation)
- **HTTP Client**: Dio (type-safe HTTP requests)
- **File Management**: path_provider (cross-platform file access)

---

## 📁 Backend Structure (`backend/`)

### Core Numerology Calculations (`app/core/`)
```
core/
├── reduction.py          # Number reduction (single-digit conversion)
├── life_seal.py          # Birth date → Life Seal + Planet mapping
├── name_numbers.py       # Name → Soul, Personality, Physical numbers
├── personal_year.py      # Current year + Life Seal → Personal Year
├── cycles.py             # Life Cycles (3 phases) & Turning Points (4 ages)
└── compatibility.py      # Numerological compatibility calculations
```

**Key Formula**: Numerological reduction uses two methods:
- `reduce_to_single_digit()`: Standard digit sum (9 + 9 = 18 → 1 + 8 = 9)
- `excel_reduce()`: Excel-faithful formula ((n-1) % 9 + 1) for 1-9 mapping

### API Layer (`app/api/`)
```
api/
├── schemas.py            # Pydantic request/response models
└── routes/
    ├── destiny.py        # Main endpoints (3 total)
    └── interpretations.py # Interpretation data
```

**Primary Endpoints**:
1. `POST /calculate-destiny` - Returns core numbers only
2. `POST /decode/full` - Returns core numbers + interpretations + narrative
3. `POST /export/report/pdf` - Generates downloadable PDF report

### Services (`app/services/`)
```
services/
├── destiny_service.py        # Main calculation orchestrator
├── interpretation_service.py  # Number → Human-readable meaning
├── narrative_service.py       # Template-driven narrative generation
├── report_service.py          # Report data structure builder
└── pdf_service.py            # PDF generation (4-page professional layout)
```

### Interpretations (`app/interpretations/`)
Database of numerological meanings:
- `cycle_interpretations.py` - Life Cycles & Turning Points (numbers 1-9)
- `life_seal.py` - Life Seal planets (1-9 planets)
- `soul_number.py`, `personality_number.py`, `personal_year.py` - Number meanings
- `pinnacles.py` - Pinnacle number interpretations

---

## 📱 Frontend Structure (`mobile/destiny_decoder_app/`)

### Features
```
lib/features/
├── decode/                    # Main feature: Calculate destiny reading
│   ├── presentation/
│   │   └── decode_form_page.dart    # UI form for input
│   ├── domain/
│   │   └── destiny_model.dart       # Data models
│   └── data/
│       └── destiny_service.dart     # API communication
└── history/                   # Reading history (future feature)
```

### Core
```
lib/core/
├── config/
│   └── api_config.dart       # API base URL configuration
├── network/
│   └── dio_client.dart       # HTTP client setup
└── theme/
    └── theme.dart            # Material design theme
```

### Main Entry
- `main.dart` - App initialization with Riverpod and Material theme

---

## 🔢 Numerology Logic

### Calculation Flow

**Input**: Birth date (day, month, year) + Full name

**Step 1: Birth Date Calculations**
```python
# Life Seal (from birth date)
day_r = reduce(day)
month_r = reduce(month)
year_r = reduce(year)
life_seal = reduce(day_r + month_r + year_r)
planet = PLANET_MAPPING[life_seal]  # Maps 1-9 to planets

# Personal Year (from current year + life seal)
current_year_r = reduce(current_year)
personal_year = reduce(current_year_r + life_seal)
```

**Step 2: Name Calculations**
```python
# Letter mapping: A=1, B=2, ... I=9, J=1, K=2, etc.
LETTER_MAP = {A:1, B:2, C:3, ..., Z:8}

# Soul Number (sum of vowels)
soul_number = reduce(sum of vowel values)

# Personality Number (sum of consonants)
personality_number = reduce(sum of consonant values)

# Physical Name Number (sum of all letters)
physical_name_number = reduce(sum of all letter values)
```

**Step 3: Life Cycles (3 phases)**
```python
# Excel-faithful logic (not standard numerology)
name_matrix = [letter_value for letter in name]  # Per-letter values

# Life Cycle 1 (Formative, age 0-30)
LC1 = excel_reduce(excel_reduce(sum(matrix)) + excel_reduce(soul_number))

# Life Cycle 2 (Establishment, age 30-55)
LC2 = excel_reduce(excel_reduce(sum(matrix)) + excel_reduce(personality_number))

# Life Cycle 3 (Fruit/Manifestation, age 55+)
LC3 = excel_reduce(LC1 + LC2)
```

**Step 4: Turning Points (4 ages)**
```python
# Natural transition points at ages 36, 45, 54, 63
TP1 = excel_reduce(LC1)
TP2 = excel_reduce(LC2 + LC1)
TP3 = excel_reduce(LC3 + LC2)
TP4 = excel_reduce(LC1 + LC2 + LC3)
```

### Interpretation Data
Each number (1-9) has:
- **Personality meaning** (soul/personality numbers)
- **Life cycle meaning** (life phase themes)
- **Turning point meaning** (transition themes)
- **Personal year meaning** (annual influence)
- **Planet association** (1-9 planets for life seal)

---

## 📄 PDF Export Feature (Phase 4.1)

### Structure (4 pages)

**Page 1: Title & Overview**
- Name and birth date
- Core numerological numbers in formatted table
- Introduction

**Page 2: Life Cycles**
- Three life phases with age ranges (0-30, 30-55, 55+)
- Cycle numbers and full interpretations
- Narrative descriptions

**Page 3: Turning Points**
- Four key transitions at ages 36, 45, 54, 63
- Turning point numbers and interpretations
- Narrative descriptions

**Page 4: Closing Summary**
- Overall life narrative
- Phase-by-phase summary with key themes
- Footer with generation info

### Technical Implementation
- **File**: `backend/app/services/pdf_service.py`
- **Function**: `generate_report_pdf(full_name, date_of_birth, report)`
- **Output**: BytesIO buffer (in-memory)
- **Size**: ~7KB per report
- **Generation**: <100ms
- **Library**: ReportLab 4.0.7 (pure Python, no external binaries)

### API Endpoint
```
POST /export/report/pdf
Content-Type: application/json

Request:
{
  "first_name": "John",
  "day_of_birth": 9,
  "month_of_birth": 4,
  "year_of_birth": 1998
}

Response:
- Content-Type: application/pdf
- Content-Disposition: attachment; filename=destiny-report-John.pdf
- Body: PDF binary data
```

---

## 🔌 API Endpoints Reference

### 1. Calculate Core Numbers
```
POST /calculate-destiny
Input: DestinyRequest
Output: DestinyResponse (core numbers only)

Fields:
- day_of_birth, month_of_birth, year_of_birth (required)
- first_name (required)
- other_names (optional)
- full_name (optional, alternative to first_name + other_names)
- current_year (optional, defaults to today's year)
```

**Response**:
```json
{
  "life_seal": 7,
  "life_planet": "NEPTUNE",
  "physical_name_number": 5,
  "soul_number": 4,
  "personality_number": 1,
  "personal_year": 8,
  "blessed_years": [2024, 2030, 2036, ...],
  "blessed_days": [4, 13, 22, 31],
  "life_cycle_phase": "Formative / Development",
  "life_turning_points": [36, 45, 54, 63],
  "compatibility": "Compatible"
}
```

### 2. Full Destiny Reading
```
POST /decode/full
Input: DestinyRequest
Output: Full report with interpretations and narratives

Response structure:
{
  "input": {
    "full_name": "John Smith",
    "date_of_birth": "1998-04-09"
  },
  "core": { /* all numbers from /calculate-destiny */ },
  "interpretations": {
    "life_seal": { "number": 7, "planet": "NEPTUNE", "content": "..." },
    "soul_number": { "number": 4, "content": "..." },
    "personality_number": { "number": 1, "content": "..." },
    "personal_year": { "number": 8, "planet": "YEAR", "content": "..." },
    "pinnacles": [ { "number": X, "content": "..." } ]
  }
}
```

### 3. Export PDF Report
```
POST /export/report/pdf
Input: DestinyRequest (same as /decode/full)
Output: PDF file download

Returns:
- Content-Type: application/pdf
- Filename: destiny-report-{first_name}.pdf
- Body: 4-page professional PDF
```

---

## 🚀 Deployment Options

### Configured For
1. **Railway.app** (5 min setup, ~$5-15/month)
2. **Heroku** (5 min setup, ~$50+/month)
3. **Docker on VPS** (DigitalOcean, 30 min setup, ~$5-10/month)
4. **Ubuntu Server** (systemd service, full manual control)

### Docker Setup
```bash
# Development
docker-compose up -d

# Production
docker-compose -f docker-compose.yml up -d
```

**Environment Variables** (.env):
```
API_BASE_URL=http://localhost:8000
DEBUG=false
CORS_ORIGINS=["https://yourdomain.com"]
```

---

## 🧪 Testing

### Backend Tests
Located in `tests/`:
- `test_reduction.py` - Number reduction logic
- `test_life_seal.py` - Birth date calculations
- `test_name_numbers.py` - Name-based numbers
- `test_personal_year.py` - Personal year calculations
- `test_life_cycles.py` - **CRITICAL** regression tests for Excel parity

**Note**: Life Cycle and Turning Point logic is **regression-tested** against Excel V9.18. Modifications require test updates.

### Run Tests
```bash
pytest
# or with config
pytest -c pytest.ini
```

---

## 🔒 Security Considerations

### Current Status
- ✅ No hardcoded secrets
- ✅ Environment variables for configuration
- ✅ CORS configured (currently `["*"]` for development)
- ⚠️ **TODO**: Update CORS origins for production
- ⚠️ **TODO**: Set DEBUG=false before deployment

### CORS Configuration
**File**: `backend/main.py`
```python
allow_origins=["*"]  # CHANGE for production!
# Example production:
# allow_origins=["https://yourdomain.com", "https://app.yourdomain.com"]
```

---

## 📝 Key Files to Know

### Core Business Logic
- `backend/app/core/cycles.py` - **Most critical**: Life Cycles & Turning Points
- `backend/app/services/destiny_service.py` - Orchestration
- `backend/app/api/routes/destiny.py` - HTTP endpoints

### Data & Models
- `backend/app/api/schemas.py` - Request/response validation
- `backend/app/models/reading.py` - Reading data model
- `backend/app/models/user.py` - User model

### Interpretations
- `backend/app/interpretations/cycle_interpretations.py` - Number meanings
- `backend/app/services/interpretation_service.py` - Lookup logic

### Frontend
- `mobile/destiny_decoder_app/lib/features/decode/` - Main feature
- `mobile/destiny_decoder_app/lib/core/network/` - API communication

---

## 🎯 Project Maturity

### ✅ Completed Features
1. Core numerology calculations (birth date + name)
2. Life Seal with planet mapping
3. Soul, Personality, Physical name numbers
4. Personal Year calculations
5. Life Cycles (3 phases, 0-30, 30-55, 55+)
6. Turning Points (4 ages: 36, 45, 54, 63)
7. Blessed years and blessed days
8. Compatibility calculations
9. Full narrative generation (template-driven)
10. PDF export with professional layout
11. Cross-platform Flutter app
12. Docker deployment configuration
13. API documentation (Swagger at `/docs`)

### 🚀 Production-Ready
- Comprehensive error handling
- Input validation (Pydantic)
- Regression tests for critical logic
- Docker containerization
- Multiple deployment options
- Professional PDF output
- CORS configuration support

---

## 🔄 Development Workflow

### Local Development

**Backend**:
```bash
# Install dependencies
pip install -r requirements.txt

# Run dev server with auto-reload
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

# API docs at http://localhost:8000/docs
# OpenAPI schema at http://localhost:8000/openapi.json
```

**Frontend**:
```bash
cd mobile/destiny_decoder_app

# Get dependencies
flutter pub get

# Run app
flutter run

# Build for specific platform
flutter build apk    # Android
flutter build ios    # iOS
flutter build web    # Web
```

### Adding Features
1. Add calculation logic to `backend/app/core/`
2. Add interpretations to `backend/app/interpretations/`
3. Add API endpoint in `backend/app/api/routes/`
4. Update `backend/app/services/destiny_service.py` orchestration
5. Add Flutter UI in `mobile/destiny_decoder_app/lib/features/`
6. Update tests in `tests/`

---

## 📚 Documentation Files

Quick reference for specific topics:
- `START_HERE.md` - Entry point for deployment
- `README.md` - Project overview
- `QUICK_DEPLOY.md` - One-command deployments
- `DEPLOYMENT.md` - Platform-specific guides
- `PHASE_4_1_COMPLETE.md` - PDF export implementation details
- `QUICK_REFERENCE.md` - API quick reference
- `docs/api_contract.md` - API specifications
- `docs/domain.md` - Numerology domain concepts
- `docs/formulas.md` - Mathematical formulas

---

## 🎓 Understanding the Codebase

### For New Features
1. Start with `backend/app/services/destiny_service.py` (orchestrator)
2. Add logic to appropriate `core/` module
3. Add interpretations to `interpretations/` module
4. Wire up in service + routes
5. Update Flutter UI as needed

### For Bug Fixes
1. Check `tests/` for regression tests
2. Understand the formula intent from `docs/formulas.md`
3. Test locally with `pytest`
4. Verify against existing test data

### For Deployment Issues
1. Check `.env` configuration
2. Review Docker setup in `docker-compose.yml`
3. Check CORS origins in `backend/main.py`
4. See `DEPLOYMENT.md` for platform-specific issues

---

**Last Updated**: January 8, 2026 | **Phase**: 4.1 (PDF Export Complete) | **Status**: Production Ready ✅
