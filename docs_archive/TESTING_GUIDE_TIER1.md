# Testing Guide: Tier 1 Card-Based Design

## Quick Start

### To run on your phone:

```bash
cd mobile/destiny_decoder_app
flutter run
```

### For iOS:
```bash
flutter run -d iphone
# or for specific device
flutter run -d <device-id>
```

### For Android:
```bash
flutter run -d android
# or for specific device
flutter run -d <device-id>
```

---

## What to Test

### 1. Form Page (Input Screen)
- [ ] **Header looks good**: "🌙 Destiny Decoder 🌙" centered and styled
- [ ] **Gold divider line** appears below subtitle
- [ ] **Form card** is centered with white background
- [ ] **Input fields** have:
  - Icons on the left (person, calendar)
  - Proper placeholder text
  - Rounded corners
  - Focus border is indigo/primary color
  
- [ ] **Button** says "Reveal Your Destiny"
  - Button is full width (minus padding)
  - Has icon on left side
  - Proper spacing
  
- [ ] **Info section** at bottom:
  - Blue background with border
  - Icon + helpful text visible
  
- [ ] **Gradient background**: Subtle gradient visible (indigo to accent)

### 2. Results Page (Output Screen)

#### Hero Section
- [ ] **Life Seal card** at top is prominent:
  - Large centered number (7, 3, 5, etc.)
  - Planet name (NEPTUNE, JUPITER, etc.)
  - Color gradient matches planet
  - ✨ sparkles around title
  - Card has nice shadow
  
#### Core Numbers Grid
- [ ] **Grid displays 4 cards** in 2 columns:
  - Soul Number
  - Personality Number
  - Personal Year
  - Physical Name Number
  
- [ ] **Each card shows**:
  - Large number in planet color
  - Label text
  - Color border matching planet
  - Light tinted background
  
- [ ] **Colors are correct**:
  - Different color for each number (1-9)
  - Match the planet color mapping
  
#### Export Button
- [ ] **PDF export button** is centered:
  - Full width with padding
  - "Export as PDF" text
  - PDF icon on left
  - Primary indigo color
  - Proper size (touch-friendly)
  
#### Interpretation Sections
- [ ] **Section cards display** for Life Seal, Soul, Personality, Personal Year
- [ ] **Each section has**:
  - Colored header bar (planet color)
  - Title + number
  - Main content area
  - Proper spacing
  
- [ ] **Content visibility**:
  - Title/summary text readable
  - Bullet points show correctly
  - Strengths & Weaknesses formatted properly
  - Spiritual Focus shows if available
  
#### Page Layout
- [ ] **Background gradient** is subtle and visible
- [ ] **Spacing** between sections is consistent (not cramped)
- [ ] **Page scrolls smoothly** if content is long
- [ ] **Bottom section** (timeline) visible when scrolling down

---

## Color Verification

Test these numbers to verify colors:
- **1 (Sun)**: Gold/Yellow
- **2 (Moon)**: Silver/Light Gray
- **3 (Jupiter)**: Purple
- **4 (Uranus)**: Blue
- **5 (Mercury)**: Green
- **6 (Venus)**: Pink/Coral
- **7 (Neptune)**: Teal/Cyan
- **8 (Saturn)**: Dark Gray
- **9 (Mars)**: Red

---

## Dark Mode Testing

```bash
# On Android/iOS, toggle dark mode in system settings
# Or in iOS: Settings > Display & Brightness > Dark
# App should automatically respond to system theme
```

- [ ] **Text is readable** in dark mode
- [ ] **Card backgrounds** adjust for dark mode
- [ ] **Contrast ratios** still good
- [ ] **Colors** remain visible

---

## Responsive Design

Test on different screen sizes:
- [ ] **Phone (small)**: 5"+ screen, portrait
- [ ] **Tablet (if available)**: Cards layout well
- [ ] **Rotation**: Layout adjusts properly when rotating
- [ ] **Landscape mode**: Cards arrange nicely

---

## Touch & Interaction

- [ ] **Form inputs**: Keyboard appears when tapping
- [ ] **Buttons**: Have ripple/feedback when pressed
- [ ] **Scrolling**: Smooth and responsive
- [ ] **No layout jank**: No jumping or visual glitches

---

## Performance Check

- [ ] **Form loads instantly** (no delay)
- [ ] **Results page responds quickly** after API call
- [ ] **PDF export** button loads without freezing
- [ ] **No memory warnings** in console output

---

## Known Warnings (Safe to Ignore)

These warnings appear but don't affect functionality:

```
withOpacity is deprecated - use .withValues() instead
(This is a Flutter deprecation, works fine as-is)

BuildContext async gaps warning
(Safe in this context, not causing issues)
```

---

## Test Data

Use these dates to test different life seal numbers:

| Name | DOB | Expected Life Seal |
|------|-----|-------------------|
| John Smith | 1985-03-15 | 7 |
| Jane Doe | 1992-07-22 | 1 |
| Test User | 2000-01-01 | 2 |
| Sample Person | 1999-12-31 | 1 |

---

## Feedback to Provide

When testing, note:
- [ ] Any visual glitches
- [ ] Text readability issues
- [ ] Color scheme preferences
- [ ] Button/spacing sizing
- [ ] Performance issues
- [ ] Missing/broken features
- [ ] Suggestions for improvement

---

## If Something Breaks

Check these common issues:

### Blank screen?
```bash
# Clear build and reinstall
flutter clean
flutter pub get
flutter run
```

### Compilation error?
```bash
flutter analyze  # See what's wrong
flutter pub get  # Update dependencies
```

### Widget not found?
- Make sure `widgets/cards.dart` exists
- Check `lib/core/theme/app_theme.dart` exists
- Verify imports are correct

---

## Taking Screenshots

To capture screenshots for feedback:

**Android:**
```bash
adb shell screencap -p > screenshot.png
```

**iOS:**
- Hardware button: Volume Up + Side button (simultaneously)

**Flutter devtools:**
```bash
flutter run
# In terminal: Press 's' to take screenshot
```

---

## Next Steps After Testing

1. **Send feedback** on what looks good/needs improvement
2. **Note any bugs** with steps to reproduce
3. **Share screenshots** of what you like
4. **Decide on Tier 2** features (tabs, expandable cards, etc.)

---

**Ready to see the new design? Run `flutter run` now!** 🚀✨
