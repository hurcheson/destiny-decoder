# Phase 4 - Premium Design System Visual Reference Guide

## 🎨 Component Overview

### 1. AnimatedNumber Component
**Purpose**: Animate numeric values from 0 to target  
**Usage**: Display numbers with visual interest

```dart
// Basic usage
AnimatedNumber(
  42,
  textStyle: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
  duration: Duration(milliseconds: 1200),
  curve: Curves.easeOutCubic,
)

// With prefix/suffix
AnimatedNumber(
  7,
  prefix: '# ',
  suffix: ' - Neptune',
  duration: Duration(milliseconds: 1400),
)
```

**Features:**
- 0 → target number counting animation
- Configurable duration (default: 1.2s)
- Smooth easing curve (easeOutCubic)
- Optional prefix/suffix text
- Decimal place support
- Auto-start with 100ms delay

---

### 2. AnimatedHeroNumberCard Component
**Purpose**: Display Life Seal with animated entrance  
**Usage**: Hero section of results page

```dart
// Life Seal display
AnimatedHeroNumberCard(
  number: 7,
  label: 'YOUR LIFE SEAL',
  subtitle: 'NEPTUNE',
  backgroundColor: AppColors.neptune,
  animationDuration: Duration(milliseconds: 1400),
)
```

**Animation Sequence:**
1. Fade in (0 → 1) over 800ms
2. Slide up (offset 0.15 → 0) over 800ms
3. Number counter starts (1st card fully visible)
4. Smooth easeOut curve throughout

---

### 3. StaggeredNumberGrid Component
**Purpose**: Display multiple number cards with cascade effect  
**Usage**: Core numbers section

```dart
StaggeredNumberGrid(
  isDarkMode: isDarkMode,
  items: [
    {'number': 4, 'label': 'Soul Number'},
    {'number': 5, 'label': 'Personality'},
    {'number': 8, 'label': 'Personal Year'},
    {'number': 3, 'label': 'Physical Name'},
  ],
)
```

**Animation Sequence:**
- Card 1: 0ms delay
- Card 2: 100ms delay
- Card 3: 200ms delay
- Card 4: 300ms delay

**Per-Card Animation:**
- Fade: 0 → 1 (500ms)
- Scale: 0.8 → 1.0 (500ms)
- Curve: easeOutCubic

---

### 4. NumerologyLoadingAnimation Component
**Purpose**: Premium loading screen with mandala theme  
**Usage**: Full-screen loading overlay

```dart
// Full overlay (in form page)
if (isLoading)
  Container(
    color: Colors.black.withValues(alpha: 0.5),
    child: const Center(
      child: NumerologyLoadingAnimation(
        message: 'Decoding Your Destiny...',
      ),
    ),
  )

// Standalone widget
NumerologyLoadingAnimation(
  message: 'Processing numerology...',
  textStyle: TextStyle(fontSize: 16, color: Colors.white),
)
```

**Animation Components:**
1. **Outer Ring** (120px diameter)
   - 9 planet dots arranged in circle
   - Continuous 4-second rotation
   - Linear curve for smooth spin

2. **Middle Ring** (80px diameter)
   - Pulsing accent border
   - 1.5-second cycle (0.8 → 1.2 scale)
   - easeInOut curve

3. **Center Sphere** (60px diameter)
   - Gradient from primary color
   - Sparkle emoji (✨)
   - Same 1.5-second pulse cycle

4. **Loading Dots** (below message)
   - 3 dots with staggered opacity
   - 1.5-second cycle with 150ms delays
   - Creates wave effect

---

### 5. ExportOptionsDialog Component
**Purpose**: Multi-option export interface  
**Usage**: Export/share functionality

```dart
// Show dialog
showDialog(
  context: context,
  builder: (context) => ExportOptionsDialog(
    isLoading: isExporting,
    onExportPdf: () => _exportPdf(ref, result),
    onShare: () => _shareReading(),
    onSaveLocal: () => _saveReading(),
  ),
)
```

**Layout:**
- Header with icon and title
- Subtitle explaining functionality
- 2x2 grid of export options
- Info footer with explanatory text

**Export Options:**
1. **PDF Export**
   - Icon: picture_as_pdf (red)
   - Description: "Professional 4-page report"
   - Primary action

2. **Share Reading** (future)
   - Icon: share (accent gold)
   - Description: "Send to friends & family"

3. **Save Reading** (future)
   - Icon: bookmark (primary)
   - Description: "Keep in your library"

4. **Close**
   - Icon: close (gray)
   - Description: "Return to reading"

---

### 6. EnhancedExportFAB Component
**Purpose**: Smart FAB with loading state animation  
**Usage**: Primary export action button

```dart
EnhancedExportFAB(
  onPressed: () => showDialog(...),
  isLoading: isExporting,
  backgroundColor: AppColors.accent,
  foregroundColor: Colors.black,
)
```

**States:**

| State | Icon | Label | Animation |
|-------|------|-------|-----------|
| Idle | download | "Export PDF" | None |
| Loading | hourglass_top | "Exporting..." | Continuous rotation (600ms) |

**Animation:**
- 600ms per rotation cycle
- Linear easing for smooth spin
- Icon rotates continuously while loading

---

## 🎬 Animation Timeline Examples

### Example 1: Results Page Entry Flow
```
Time    Event
0ms     Overview tab visible
50ms    Hero card starts fade + slide
100ms   Number counter starts (Life Seal number)
550ms   Number animation complete
600ms   Grid card 1 fades + scales in
700ms   Grid card 2 fades + scales in
800ms   Grid card 3 fades + scales in
900ms   Grid card 4 fades + scales in
1100ms  All animations complete, page ready
```

### Example 2: Form Page Loading
```
Time    Event
0ms     Form visible, user submits
100ms   Loading overlay appears (fade in)
150ms   Mandala spinner starts
        - Outer ring begins 4s rotation
        - Pulsing rings start 1.5s cycle
        - Loading dots begin wave
200ms   Loading message visible
        (API request processing)
4000ms  API response received
        - Loading overlay fades out
        - Results page navigates in
```

### Example 3: Export Button
```
Time    Event
0ms     User taps FAB
50ms    Dialog appears (fade + scale in)
5000ms  User selects "Export PDF"
        - Dialog closes
        - FAB rotation starts
        - PDF generation begins
8000ms  PDF ready, saves to file
        - FAB stops rotating
        - Success message shown
        - FAB returns to idle state
```

---

## 🎨 Color Integration

### Light Mode
- **Hero Card**: Planet color gradient
- **Grid Cards**: Planet color light background (8% alpha)
- **Loading Overlay**: Semi-transparent black (50% alpha)
- **Accent**: Gold (#D4AF37)

### Dark Mode
- **Hero Card**: Planet color light variant
- **Grid Cards**: Planet color dark background (15% alpha)
- **Loading Overlay**: Semi-transparent black (50% alpha)
- **Accent**: Bright gold (#FFD700)

---

## ⚡ Performance Considerations

### Animation Costs
| Component | CPU | Memory | Notes |
|-----------|-----|--------|-------|
| AnimatedNumber | Low | Low | Single number animation |
| StaggeredGrid | Low-Medium | Low | 4 staggered animations |
| LoadingAnimation | Medium | Medium | Complex spinner with 9 dots |
| ExportFAB | Low | Low | Simple rotation animation |

### Recommendations
- ✅ All animations run simultaneously (acceptable)
- ✅ Animations use efficient Flutter primitives
- ✅ No image assets required
- ✅ Minimal memory footprint
- ✅ Smooth 60fps possible on modern devices

---

## 🌙 Dark Mode Support

All components automatically adapt to dark mode:

```dart
// Automatic detection
final isDarkMode = Theme.of(context).brightness == Brightness.dark;

// Components handle both modes
- AnimatedNumber: Uses provided TextStyle
- AnimatedHeroNumberCard: Uses planet color variants
- StaggeredNumberGrid: Uses theme-aware colors
- NumerologyLoadingAnimation: Adapts colors automatically
- ExportDialog: Uses theme-aware backgrounds
- EnhancedExportFAB: Uses provided colors
```

---

## 📱 Responsive Design

### Mobile (< 600dp)
- ✅ Full-screen loading overlay
- ✅ 2-column grid (responsive GridView)
- ✅ Touch-friendly FAB sizing
- ✅ Readable text sizes throughout

### Tablet (600dp+)
- ✅ Same animations, larger text
- ✅ More breathing room
- ✅ Proportional scaling
- ✅ Landscape support

---

## ♿ Accessibility

### Motion & Animation
- ✅ All animations ~500-1200ms (not too fast)
- ✅ Respect system reduce motion setting (implemented in _wrapAnimated)
- ✅ No flashing or rapid sequences
- ✅ Smooth easing curves (not jarring)

### Color & Contrast
- ✅ WCAG AAA contrast maintained
- ✅ Planet colors support white text
- ✅ Dark mode variants provided
- ✅ Semantic color meanings clear

### Touch Targets
- ✅ FAB: 56dp diameter (Material standard)
- ✅ Dialog buttons: ~72px height (tap-friendly)
- ✅ Cards: Full-width, tappable areas

---

## 🔧 Customization Guide

### Adjusting Animation Speed
```dart
// In widget definition, modify duration parameter
AnimatedNumber(
  number,
  duration: Duration(milliseconds: 800), // Faster (default: 1200)
)

// For StaggeredNumberGrid
const delay = 50; // Faster cascade (default: 100ms)
```

### Changing Colors
```dart
// Hero card
AnimatedHeroNumberCard(
  backgroundColor: Colors.purple, // Custom color
  textColor: Colors.white,
)

// Loading animation (auto-adapts to theme colors)
// No color parameters needed - uses AppColors system
```

### Custom Messages
```dart
NumerologyLoadingAnimation(
  message: 'Your custom message here',
)
```

---

## 📋 Implementation Checklist

- ✅ Number counter animation working
- ✅ Staggered grid cascade visible
- ✅ Loading screen displays on form
- ✅ Export dialog shows on FAB tap
- ✅ FAB rotates during export
- ✅ All colors support dark mode
- ✅ Animations smooth at 60fps
- ✅ No memory leaks (controllers disposed)
- ✅ Touch interactions responsive
- ✅ Accessibility considerations met

---

## 🚀 Future Enhancements

**Potential additions for Phase 5:**
- Custom Lottie animations
- Haptic feedback on animations
- Gesture-driven animations (swipe, drag)
- Particle effects on reveal
- Sound effects (optional)
- Confetti on success
- Progress indicators for long operations

---

**Created**: January 9, 2026  
**Status**: Phase 4 Complete  
**Next**: Phase 5 - Advanced Features
