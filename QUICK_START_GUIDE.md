# Destiny Decoder - Quick Start Guide

**Last Updated**: January 9, 2026  
**For**: Developers, Testers, New Team Members

---

## 🚀 5-Minute Setup

### Prerequisites
- Python 3.9+
- Flutter 3.0+
- Git

### Backend (2 minutes)
```bash
# Clone and navigate
cd backend

# Install dependencies
pip install -r requirements.txt

# Run server
uvicorn backend.main:app --reload --host 0.0.0.0 --port 8000

# API docs at: http://localhost:8000/docs
```

### Frontend (3 minutes)
```bash
# Navigate to Flutter app
cd mobile/destiny_decoder_app

# Install dependencies
flutter pub get

# Run app
flutter run

# Or for specific device
flutter run -d chrome  # Web
flutter run -d android  # Android
flutter run -d iphone  # iOS
```

---

## 📱 Test the App (1 minute)

### Example Input
```
Full Name: John Smith
Date of Birth: 1998-04-09
```

### Expected Output
- Life Seal: 4 (Uranus)
- Soul Number: 6
- Personality Number: 5
- Personal Year: 8 (for 2024)

### Features to Test
1. ✅ Enter name and DOB → Calculate
2. ✅ View animated results with cards
3. ✅ Swipe between tabs (Overview, Numbers, Timeline)
4. ✅ Tap accordion sections to expand
5. ✅ Export PDF (tap FAB → Export PDF)
6. ✅ Save reading (tap FAB → Save Reading)
7. ✅ Share as image (tap FAB → Share Image)
8. ✅ View history (back button → History)
9. ✅ Check compatibility (home → Compatibility)
10. ✅ Try dark mode (device settings)

---

## 📂 Project Structure (Simple)

```
destiny-decoder/
├── backend/              # Python FastAPI server
│   ├── app/
│   │   ├── core/        # Numerology calculations
│   │   ├── services/    # Business logic
│   │   ├── api/         # REST endpoints
│   │   └── interpretations/  # Number meanings
│   └── main.py          # Entry point
│
├── mobile/              # Flutter mobile app
│   └── destiny_decoder_app/
│       └── lib/
│           ├── features/    # Main features
│           │   ├── decode/  # Calculation UI
│           │   ├── onboarding/  # Welcome screens
│           │   ├── history/     # Saved readings
│           │   └── compatibility/  # Partner check
│           └── core/        # Shared utilities
│
├── docs/                # Technical documentation
├── tests/               # Backend unit tests
└── [Many .md files]     # Documentation
```

---

## 🔧 Common Commands

### Backend
```bash
# Run tests
pytest

# Run with auto-reload
uvicorn backend.main:app --reload

# Check for errors
flake8 backend/

# Format code
black backend/
```

### Frontend
```bash
# Run on device
flutter run

# Run tests
flutter test

# Check for issues
flutter analyze

# Build for production
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
```

### Docker
```bash
# Build and run everything
docker-compose up -d

# View logs
docker-compose logs -f

# Stop
docker-compose down
```

---

## 🐛 Troubleshooting

### Backend Issues

**Port already in use**
```bash
# Find process
lsof -i :8000

# Kill it
kill -9 <PID>
```

**Import errors**
```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall
```

### Frontend Issues

**Dependencies not found**
```bash
# Clean and reinstall
flutter clean
flutter pub get
```

**Build errors**
```bash
# Clear cache
flutter clean
rm -rf ~/.pub-cache

# Get dependencies again
flutter pub get
```

**Can't find devices**
```bash
# List available devices
flutter devices

# For iOS simulator
open -a Simulator

# For Android emulator
flutter emulators --launch <emulator_id>
```

---

## 📖 Key Documentation Files

**Start Here**:
- `README.md` - Project overview
- `PRODUCT_ROADMAP_2026.md` - Future plans
- `CODEBASE_OVERVIEW.md` - Detailed architecture

**For Development**:
- `docs/formulas.md` - Numerology calculation specs
- `docs/api_contract.md` - API documentation
- `IMPLEMENTATION_HISTORY.md` - What's been built

**For Deployment**:
- `DEPLOYMENT.md` - Full deployment guide
- `QUICK_DEPLOY.md` - One-command setups
- `PRE_DEPLOYMENT_CHECKLIST.md` - Pre-launch checks

---

## 🎯 Core API Endpoints

### 1. Calculate Core Numbers
```http
POST http://localhost:8000/api/destiny/calculate-destiny
Content-Type: application/json

{
  "first_name": "John",
  "day_of_birth": 9,
  "month_of_birth": 4,
  "year_of_birth": 1998,
  "current_year": 2024
}
```

### 2. Full Reading with Interpretations
```http
POST http://localhost:8000/api/destiny/decode/full
Content-Type: application/json

{
  "first_name": "John",
  "other_names": "Smith",
  "day_of_birth": 9,
  "month_of_birth": 4,
  "year_of_birth": 1998
}
```

### 3. Export PDF Report
```http
POST http://localhost:8000/api/destiny/export/report/pdf
Content-Type: application/json

{
  "first_name": "John",
  "other_names": "Smith",
  "day_of_birth": 9,
  "month_of_birth": 4,
  "year_of_birth": 1998
}

# Returns PDF file for download
```

---

## 🎨 UI/UX Features

### Design System
- **Colors**: 9 planet colors (gold, silver, purple, blue, green, coral, teal, gray, red)
- **Typography**: Clean, readable Material Design 3
- **Spacing**: 16px grid system
- **Animations**: 4 types (number reveals, cascades, loading, FAB)
- **Dark Mode**: Full support with optimized contrast

### Animations
1. **Number Reveal**: Life Seal animates from 0 → target (1200ms)
2. **Card Cascade**: Staggered appearance with 100ms delays
3. **Loading Spinner**: Mandala with rotating planets
4. **FAB Rotation**: Spins during export operations

### Navigation
- **Tabs**: Swipe between Overview, Numbers, Timeline
- **Pull-to-Refresh**: Pull down to scroll to top
- **Accordion**: Tap to expand interpretations
- **FAB**: Floating action button for export options

---

## 🔐 Environment Variables

### Backend (.env)
```bash
# Optional - defaults work for local dev
API_BASE_URL=http://localhost:8000
DEBUG=true
CORS_ORIGINS=*

# For production
DEBUG=false
CORS_ORIGINS=https://yourdomain.com
```

### Frontend
No environment variables needed for local development.

For production, update:
- `lib/core/config/api_config.dart` - Set production API URL

---

## 🧪 Testing Checklist

### Backend Tests
```bash
cd backend
pytest tests/

# Specific tests
pytest tests/test_life_seal.py -v
```

### Manual Frontend Testing
- [ ] Onboarding flow (first-time user)
- [ ] Form validation (empty fields, invalid dates)
- [ ] Calculation accuracy (use test data)
- [ ] PDF export (downloads correctly)
- [ ] Image save (gallery permission)
- [ ] Share functionality (native sheet works)
- [ ] History (save, load, delete)
- [ ] Compatibility (two people comparison)
- [ ] Dark mode (toggle device settings)
- [ ] Animations (smooth 60fps)
- [ ] Pull-to-refresh (scrolls to top)
- [ ] Tab swiping (left/right navigation)

---

## 💡 Pro Tips

1. **Use Hot Reload**: In Flutter, press `r` to hot reload, `R` to hot restart
2. **Check API Docs**: Visit `/docs` on backend for interactive API testing
3. **Use Dev Tools**: Flutter DevTools for debugging (`flutter pub global activate devtools`)
4. **Test on Real Device**: Emulators don't show true performance
5. **Watch Logs**: `flutter run --verbose` for detailed output

---

## 🆘 Getting Help

### Internal Resources
- `CODEBASE_OVERVIEW.md` - Architecture details
- `docs/` folder - Technical specifications
- Git history - See what changed and why

### External Resources
- Flutter docs: https://docs.flutter.dev/
- FastAPI docs: https://fastapi.tiangolo.com/
- ReportLab guide: https://www.reportlab.com/docs/

### Common Questions

**Q: Where are calculations done?**  
A: `backend/app/core/` - Pure Python, deterministic

**Q: How do I add a new interpretation?**  
A: Edit `backend/app/interpretations/`

**Q: How do I change colors?**  
A: `mobile/destiny_decoder_app/lib/core/theme/app_theme.dart`

**Q: Can I run without backend?**  
A: No, frontend requires backend API

**Q: How do I deploy?**  
A: See `DEPLOYMENT.md` for full guide

---

## ✅ Pre-Commit Checklist

Before committing code:
- [ ] Backend tests pass (`pytest`)
- [ ] Frontend analyzes clean (`flutter analyze`)
- [ ] No console errors
- [ ] Features work on device (not just emulator)
- [ ] Dark mode tested
- [ ] Documentation updated if needed

---

## 🎉 You're Ready!

You now know enough to:
- ✅ Run the app locally
- ✅ Test all features
- ✅ Find relevant documentation
- ✅ Troubleshoot common issues
- ✅ Make changes confidently

**Next Steps**:
1. Run the app and explore
2. Read `PRODUCT_ROADMAP_2026.md` for future work
3. Pick a feature from Phase 6 to implement
4. Have fun building! 🚀

---

**This guide consolidates**:
- QUICK_START_TIER1.md
- TESTING_GUIDE_TIER1.md
- START_TIER1.md
- START_HERE.md
- QUICK_REFERENCE.md

**For detailed implementation history**: See `IMPLEMENTATION_HISTORY.md`  
**For future plans**: See `PRODUCT_ROADMAP_2026.md`  
**For deployment**: See `DEPLOYMENT.md`
