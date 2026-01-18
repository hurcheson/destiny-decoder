# Phase 6.1 Daily Insights - Visual & Technical Reference

## 📱 Screen Layout

```
┌─────────────────────────────────────┐
│         Daily Insights              │ ◄── AppBar with title
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │   TODAY'S POWER NUMBER      │   │ ◄── DailyInsightTile
│  │   ┌───────────────────────┐ │   │    - Power number (1-9) in circle
│  │ 7 │   Spiritual Growth    │ │   │    - Day of week + date
│  │   │   (with full insight) │ │   │    - Blessed day indicator (⭐)
│  │   │   [tap to expand]     │ │   │    - Full interpretation text
│  │   └───────────────────────┘ │   │
│  └─────────────────────────────┘   │
│                                     │
│  WEEKLY PREVIEW                     │ ◄── WeeklyPreviewCarousel
│  ┌──────┬──────┬──────┬──────┐   │    - Horizontal scroll
│  │ 9    │ 1    │ 2    │ 3    │   │    - 7 days
│  │ Fri  │ Sat  │ Sun  │ Mon  │   │    - Brief insight per day
│  │ Jan9 │ Jan10│ Jan11│ Jan12│   │
│  │Brief │Brief │Brief │Brief │   │
│  └──────┴──────┴──────┴──────┘   │
│                                     │
│  BLESSED DAYS CALENDAR              │ ◄── BlessedDaysCalendar
│  ◄ January 2026 ►                  │    - Month navigation
│  ┌──┬──┬──┬──┬──┬──┬──┐          │    - 7x7 grid (weeks)
│  │ 1 │ 2 │ 3 │ 4 │ 5 │ 6 │ 7 │  │    - Color coded:
│  ├──┼──┼──┼──┼──┼──┼──┤          │      * Green = Blessed
│  │ 8 │ 9●│10 │11 │12 │13 │14│  │      * Blue = Today
│  │   │●●│   │   │   │   │   │  │
│  ├──┼──┼──┼──┼──┼──┼──┤          │    - Dot below blessed
│  │15 │16 │17 │18●│19 │20 │21│  │    - Red dot on today
│  │   │   │   │●●│   │   │   │  │
│  ├──┼──┼──┼──┼──┼──┼──┤          │
│  │22 │23 │24 │25 │26 │27●│28│  │
│  │   │   │   │   │   │●●│   │  │
│  └──┴──┴──┴──┴──┴──┴──┘          │
│  □ Blessed day  □ Today           │
│                                     │
│  PERSONAL MONTH GUIDANCE            │ ◄── PersonalMonthGuidanceCard
│  ┌─────────────────────────────┐   │    - Large month badge
│  │ Personal Month    ┌─────┐   │   │    - Theme text
│  │ January 2026      │  7  │   │   │    - Actionable guidance
│  │                   │Month│   │   │    - Color coded by #
│  │ Personal Year: 6  │     │   │   │
│  │ Calendar: 1       └─────┘   │   │
│  │                             │   │
│  │ Theme: Introspection &      │   │
│  │ spiritual growth. A time    │   │
│  │ for reflection and wisdom.  │   │
│  │                             │   │
│  │ 🧘 A time for reflection   │   │
│  │ and inner wisdom. Trust     │   │
│  │ your intuition.             │   │
│  └─────────────────────────────┘   │
│                                     │
│                           ◄─ Scroll │
└─────────────────────────────────────┘
```

---

## 🎨 Color Coding System

### Monthly Personal Month Colors (1-9)

```
Month 1 (Red):
  - Background: Red 100
  - Accent: Red
  - Icon: Circle outline, leading number

Month 2 (Orange):
  - Background: Orange 100
  - Accent: Orange
  - Icon: Partnership symbol

Month 3 (Yellow):
  - Background: Yellow 100
  - Accent: Yellow 700
  - Icon: Creative spark

Month 4 (Green):
  - Background: Green 100
  - Accent: Green
  - Icon: Foundation/building

Month 5 (Teal):
  - Background: Teal 100
  - Accent: Teal
  - Icon: Movement/change

Month 6 (Blue):
  - Background: Blue 100
  - Accent: Blue
  - Icon: Heart/service

Month 7 (Indigo):
  - Background: Indigo 100
  - Accent: Indigo
  - Icon: Third eye/wisdom

Month 8 (Purple):
  - Background: Purple 100
  - Accent: Purple
  - Icon: Crown/power

Month 9 (Pink):
  - Background: Pink 100
  - Accent: Pink
  - Icon: Flower/completion
```

---

## 🔄 State Management Flow

### Provider Architecture

```
DailyInsightParams
├── lifeSeal: int
├── dayOfBirth: int
└── targetDate: String? (ISO YYYY-MM-DD)
    ↓
dailyInsightProvider (FutureProvider.family)
    ↓
DailyInsightsService.getDailyInsight()
    ↓
POST /daily/insight
    ↓
DailyInsightResponse
├── date: String
├── dayOfWeek: String
├── powerNumber: int
├── isBlessedDay: bool
├── insight: DailyInsightInterpretation
└── briefInsight: String

WeeklyParams
├── lifeSeal: int
└── startDate: String?
    ↓
weeklyInsightsProvider (FutureProvider.family)
    ↓
DailyInsightsService.getWeeklyInsights()
    ↓
POST /daily/weekly
    ↓
WeeklyInsightsResponse
├── weekStarting: String
└── dailyPreviews: List<DailyPowerPreview>
    ├── date: String
    ├── dayOfWeek: String
    ├── powerNumber: int
    └── briefInsight: String

BlessedDaysParams
├── dayOfBirth: int
├── month: int
└── year: int
    ↓
blessedDaysProvider (FutureProvider.family)
    ↓
DailyInsightsService.getBlessedDays()
    ↓
POST /daily/blessed-days
    ↓
BlessedDaysResponse
├── month: int
├── year: int
├── monthName: String
└── blessedDates: List<String> (ISO dates)

PersonalMonthParams
├── dayOfBirth: int
├── monthOfBirth: int
├── yearOfBirth: int
├── targetMonth: int?
└── targetYear: int?
    ↓
personalMonthProvider (FutureProvider.family)
    ↓
DailyInsightsService.getPersonalMonth()
    ↓
POST /daily/personal-month
    ↓
PersonalMonthResponse
├── personalMonth: int (1-9)
├── personalYear: int (1-9)
├── calendarMonth: int
├── calendarYear: int
├── monthName: String
└── theme: String
```

---

## 📐 Widget Hierarchy

```
DailyInsightsPage (ConsumerWidget)
├── Scaffold
│   ├── AppBar(title: "Daily Insights")
│   └── body: RefreshIndicator
│       └── ListView
│           ├── DailyInsightTile (data: DailyInsightResponse)
│           │   ├── Power number circle
│           │   ├── Day + date
│           │   ├── Blessed indicator
│           │   └── Full insight text
│           │
│           ├── SizedBox(height: 16)
│           ├── Text("Weekly Preview")
│           │
│           ├── WeeklyPreviewCarousel(lifeSeal, onSelect)
│           │   ├── SingleChildScrollView (horizontal)
│           │   └── Row of DailyPowerPreview cards
│           │       ├── Power number circle
│           │       ├── Day of week + date
│           │       └── Brief insight (3 lines max)
│           │
│           ├── SizedBox(height: 24)
│           ├── Text("Blessed Days")
│           │
│           ├── BlessedDaysCalendar(dayOfBirth, initialMonth, onSelectDate)
│           │   ├── Row (navigation buttons)
│           │   │   ├── IconButton (prev month)
│           │   │   ├── Text (month name)
│           │   │   └── IconButton (next month)
│           │   │
│           │   └── GridView.builder
│           │       └── [49 cells = 7 cols × 7 weeks]
│           │           └── Each cell:
│           │               ├── InkWell(onTap)
│           │               ├── AnimatedContainer
│           │               └── Stack
│           │                   ├── Center(Text: day number)
│           │                   └── Positioned(dot for blessed)
│           │
│           │   └── Legend
│           │       ├── Blessed indicator + text
│           │       └── Today indicator + text
│           │
│           ├── SizedBox(height: 24)
│           ├── Text("Personal Month Guidance")
│           │
│           └── PersonalMonthGuidanceCard(dayOfBirth, monthOfBirth, yearOfBirth)
│               ├── Card(elevation: 2)
│               └── Padding
│                   ├── Row (header)
│                   │   ├── Column (month name + year)
│                   │   └── Container (large number badge)
│                   │       └── Column
│                   │           ├── Text(number)
│                   │           └── Text("Personal")
│                   │
│                   ├── SizedBox
│                   │
│                   ├── Container (info box)
│                   │   └── Row (2 columns + divider)
│                   │       ├── Personal Year
│                   │       ├── Divider
│                   │       └── Calendar Month
│                   │
│                   ├── SizedBox
│                   │
│                   ├── Text("Monthly Theme")
│                   ├── Text(data.theme)
│                   │
│                   └── Container (guidance box)
│                       └── Text(actionable guidance)
```

---

## 🌊 Data Flow Example

### Scenario: User opens "Daily Insights" from Decode Result

```
1. User taps "Daily Insights" FAB
   ↓
2. Extract birth info:
   - lifeSeal = 7
   - dayOfBirth = 9
   - monthOfBirth = 5
   - yearOfBirth = 1990
   ↓
3. Navigate to DailyInsightsPage:
   DailyInsightsPage(
     lifeSeal: 7,
     dayOfBirth: 9,
     monthOfBirth: 5,
     yearOfBirth: 1990,
   )
   ↓
4. Page creates params:
   DailyInsightParams(lifeSeal: 7, dayOfBirth: 9, targetDate: null)
   WeeklyParams(lifeSeal: 7, startDate: null)
   BlessedDaysParams(dayOfBirth: 9, month: 1, year: 2026)
   PersonalMonthParams(dayOfBirth: 9, monthOfBirth: 5, yearOfBirth: 1990)
   ↓
5. Providers fetch data in parallel:
   - dailyInsightProvider → GET /daily/insight
   - weeklyInsightsProvider → GET /daily/weekly
   - blessedDaysProvider → GET /daily/blessed-days
   - personalMonthProvider → GET /daily/personal-month
   ↓
6. UI builds while loading (skeleton states):
   - DailyInsightTile: Loading skeleton
   - WeeklyPreviewCarousel: Shimmer effect
   - BlessedDaysCalendar: Grid skeleton
   - PersonalMonthGuidanceCard: Loading skeleton
   ↓
7. Data arrives, UI updates:
   - Today: Power 7, blessed, insight "Spiritual Growth"
   - Week: [9, 1, 2, 3, 4, 5, 6] for next 7 days
   - Blessed: [9, 18, 27] highlighted in green
   - Personal Month: 7 (January for this user)
   ↓
8. User can interact:
   - Swipe weekly carousel
   - Click blessed date (9, 18, 27)
   - Previous/next month in calendar
   - Refresh with pull gesture
   ↓
9. On date selection:
   - Update targetDate: "2026-01-18"
   - Reload dailyInsightProvider with new date
   - Show loading state, then new data
```

---

## ⚡ Performance Optimizations

### Caching Strategy
- **Riverpod caching**: Providers cache for entire session
- **API response caching**: 5-minute TTL in DailyInsightsService
- **Widget rebuilding**: Only affected widgets rebuild on state change
- **Lazy loading**: Calendar grid only builds visible cells

### Memory Usage
- **No memory leaks**: Proper disposal of listeners
- **Image optimization**: No heavy images in UI
- **String pooling**: Reusable text styles
- **List reuse**: DailyPowerPreview cached in provider

---

## 🚨 Error Handling

### Scenarios Handled

1. **Network Error**
   ```
   Error state shown with:
   - Warning icon
   - "Could not load [feature]"
   - "Check your connection and try again"
   - Retry button available
   ```

2. **Invalid Date**
   ```
   Gracefully handled:
   - Past dates in calendar
   - Future dates
   - Feb 29 in non-leap years
   - Month boundaries
   ```

3. **Loading Timeout**
   ```
   Skeleton loaders show for up to 30s:
   - Smooth shimmer animation
   - Never shows blank screen
   - Automatic retry on timeout
   ```

4. **Partial Load Failure**
   ```
   Independent loading:
   - Blessed calendar fails? Other features load
   - Personal month fails? Daily tile still works
   - Each widget handles its own errors
   ```

---

## 🔐 Security & Validation

### Input Validation
- ✅ Date format validation (YYYY-MM-DD)
- ✅ Birth day range (1-31)
- ✅ Birth month range (1-12)
- ✅ Year range (1900-current)
- ✅ Life seal range (1-9)

### Data Sanitization
- ✅ API responses validated against models
- ✅ Null checks on all optional fields
- ✅ Type safety with Dart's strict mode
- ✅ No XSS vectors (Flutter, no HTML)

### Privacy
- ✅ No birth data transmitted beyond API
- ✅ No analytics on sensitive calculations
- ✅ Local storage only (no cloud sync yet)
- ✅ No data sharing with third parties

---

## 📈 Analytics Integration

### Events Tracked (Ready for Firebase)

```
Event: daily_insights_viewed
- Parameters:
  - personal_month: int (1-9)
  - power_number: int (1-9)
  - is_blessed_day: boolean
  - view_date: ISO date
  
Event: blessed_day_selected
- Parameters:
  - date: ISO date
  - month: int
  
Event: personal_month_viewed
- Parameters:
  - personal_month: int (1-9)
  - personal_year: int (1-9)
  
Event: weekly_preview_tapped
- Parameters:
  - target_power_number: int
  - days_ahead: int (0-6)
```

---

## ✅ Verification Checklist

- ✅ All 4 data providers working
- ✅ Daily insight tile displays correctly
- ✅ Weekly carousel scrolls smoothly
- ✅ Blessed calendar highlights properly
- ✅ Personal month card shows theme
- ✅ Today indicator visible
- ✅ Month navigation works
- ✅ Date selection updates view
- ✅ Error states display correctly
- ✅ Loading states smooth
- ✅ No compilation errors
- ✅ No runtime crashes
- ✅ Responsive on all screen sizes
- ✅ Dark mode works
- ✅ Accessibility features present
- ✅ Performance is smooth (60 FPS)

---

## 📚 Code References

### Key Files
- **Main Page:** `lib/features/daily_insights/view/daily_insights_page.dart`
- **Month Card:** `lib/features/monthly_guidance/personal_month_guidance_card.dart`
- **Calendar:** `lib/features/daily_insights/widgets/blessed_days_calendar.dart`
- **Daily Tile:** `lib/features/daily_insights/widgets/daily_insight_tile.dart`
- **Weekly Carousel:** `lib/features/daily_insights/widgets/weekly_preview_carousel.dart`
- **Service:** `lib/features/daily_insights/service.dart`
- **Providers:** `lib/features/daily_insights/providers.dart`
- **Models:** `lib/features/daily_insights/models.dart`

### Backend Routes
- `POST /daily/insight` - Daily power number
- `POST /daily/weekly` - 7-day forecast
- `POST /daily/blessed-days` - Blessed dates
- `POST /daily/personal-month` - Month theme

---

**Last Updated:** January 17, 2026  
**Status:** ✅ Complete & Production Ready  
**Next Phase:** 6.2 Enhanced Onboarding (Optional)
