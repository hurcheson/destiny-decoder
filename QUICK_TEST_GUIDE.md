# Quick Testing Guide - January 19, 2026

## Backend Testing

### 1. Server Status
```bash
# Backend already running on port 8001
# Check at: http://127.0.0.1:8001
```

### 2. Test Destiny Calculation
```bash
curl -X POST http://127.0.0.1:8001/calculate-destiny \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "date_of_birth": "1990-01-15"
  }'
```

### 3. Test Full Decoding
```bash
curl -X POST http://127.0.0.1:8001/decode/full \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "Jane Smith",
    "date_of_birth": "1985-05-20"
  }'
```

### 4. Access API Docs
Open browser to: `http://127.0.0.1:8001/docs`

---

## Mobile App Testing

### 1. Get Dependencies
```bash
cd mobile/destiny_decoder_app
flutter pub get
```

### 2. Analyze Code
```bash
flutter analyze
# Expected: No errors
```

### 3. Run on Emulator
```bash
flutter run
```

### 4. Run Tests
```bash
flutter test
```

---

## Verification Checklist

### Backend ✅
- [ ] Server running on port 8001
- [ ] API docs accessible
- [ ] Destiny endpoint responds
- [ ] PDF export works

### Mobile ✅
- [ ] No compilation errors
- [ ] Flutter pub get succeeds
- [ ] App launches without crashes
- [ ] Home page displays
- [ ] Destiny form functional

### Integration ✅
- [ ] App connects to backend API
- [ ] Calculate button returns results
- [ ] PDF export functional
- [ ] History saves readings

---

## Expected Behavior After Fixes

1. **Compilation:** ✅ Zero errors
2. **Backend:** ✅ Running smoothly
3. **Mobile:** ✅ Ready to test on device
4. **Integration:** ✅ All systems connected

---

## Known Limitations (To Address Next)

1. **Firebase:** Notifications infrastructure ready, but key not configured (dev mode)
2. **Receipts:** IAP structure ready, but backend validation not implemented
3. **Database:** Token storage not yet implemented
4. **Analytics:** Events tracked, but persistence pending

---

## If Issues Arise

### Backend Won't Start
```bash
# Try different port
python -m uvicorn backend.main:app --host 127.0.0.1 --port 8002 --reload
```

### Flutter Won't Compile
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter analyze
```

### Missing Packages
```bash
# Update all dependencies
flutter pub upgrade
```

---

All systems are GO for testing! ✅
