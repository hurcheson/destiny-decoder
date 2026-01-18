# Phase 6.7 - Notification Settings UI Reference

## User-Facing Settings Page Layout

### Before (Current)
```
Settings Page
├── Notifications
│   ├── FCM Device Token (Debug Only) [Info Box]
│   ├── Test Notifications [Buttons]
│   └── Test Blessed Day [Button]
│       Test Personal Year [Button]
└── About
    └── Version info, app description
```

### After (Phase 6.7)
```
Settings Page
├── Notifications (Existing Tests)
│   ├── FCM Device Token (Debug Only) [Info Box]
│   ├── Test Notifications [Buttons]
│   └── Test Blessed Day, Personal Year [Buttons]
│
├── Notification Settings [NEW SECTION] ⭐
│   ├── Notification Types Header
│   │
│   ├── 🌟 Blessed Days [Toggle ON/OFF]
│   │   "Get notified on your blessed dates"
│   │
│   ├── 📚 Daily Insights [Toggle ON/OFF]
│   │   "Receive your daily numerology reading"
│   │
│   ├── 🌙 Lunar Phase Updates [Toggle ON/OFF]
│   │   "Stay informed about lunar cycles"
│   │
│   ├── 💫 Motivational Quotes [Toggle ON/OFF]
│   │   "Daily inspiration and encouragement"
│   │
│   ├── Quiet Hours Header
│   │
│   ├── Enable Quiet Hours [Toggle ON/OFF]
│   │   "Pause notifications during selected hours"
│   │
│   ├── IF QUIET HOURS ENABLED:
│   │   ├── From [🕐 22:00] (Tap to change)
│   │   ├── To [🕐 06:00] (Tap to change)
│   │   └── Info Box: "Notifications paused between 22:00 and 06:00"
│   │
│   └── [Error message if any]
│
└── About (Existing)
    └── Version info, app description
```

---

## Interactive Flow

### Scenario 1: User Enables Quiet Hours
```
1. User scrolls to "Quiet Hours" section
   ↓
2. Sees "Enable Quiet Hours" toggle (currently OFF)
   ↓
3. Taps toggle → Switch turns ON
   ↓
4. Two new fields appear:
   - "From" with time picker (default 22:00)
   - "To" with time picker (default 06:00)
   ↓
5. Info box appears:
   "Notifications paused between 22:00 and 06:00"
   ↓
6. User can tap each time picker to change:
   - Material Design time picker appears
   - User selects new time
   - Field updates immediately
   ↓
7. Changes auto-save to backend
   ↓
8. Backend scheduler respects new quiet hours on next job run
```

### Scenario 2: User Disables a Notification Type
```
1. User sees "Daily Insights" toggle (currently ON)
   ↓
2. Taps toggle → Switch turns OFF
   ↓
3. Visual feedback: Toggle slides left, color changes
   ↓
4. Change saved to backend immediately
   ↓
5. Next daily insights job (6am) skips this user
```

### Scenario 3: User with Multiple Preferences
```
Example Configuration:
├── 🌟 Blessed Days: ON
├── 📚 Daily Insights: OFF (user disabled)
├── 🌙 Lunar Phase: ON (user enabled)
├── 💫 Quotes: ON
│
└── Quiet Hours: ON
    ├── From: 23:00 (11 PM)
    └── To: 07:00 (7 AM)

Result:
• 6 AM (Daily Insights job): BLOCKED by preference
• 7:30 AM (Blessed Days job): ALLOWED (outside quiet hours)
• 8 AM (Blessed Days job): ALLOWED
• 7 PM (Lunar job): ALLOWED
• Anytime (Quote job): BLOCKED by quiet hours if time matches
```

---

## Color Scheme & Styling

### Light Mode
```
Background: White (#FFFFFF)
Card Background: Light Gray (#F5F5F5)
Border: Light Gray (#E0E0E0)
Text: Dark Gray (#212121)
Accent: Theme Primary Color (Brand color)
Toggle: ON → Primary Color, OFF → Gray
```

### Dark Mode
```
Background: Dark Gray (#121212)
Card Background: Very Dark Gray (#1E1E1E)
Border: Dark Gray (#333333)
Text: Light Gray (#FFFFFF)
Accent: Theme Primary Color (Brand color - lightened)
Toggle: ON → Primary Color, OFF → Gray
```

### Icons & Emojis
```
🌟 Blessed Days - Golden star
📚 Daily Insights - Open book
🌙 Lunar Phase - Crescent moon
💫 Motivational Quotes - Sparkle/star
🕐 Time Picker - Clock icon
ℹ️ Info Box - Information circle
❌ Error - Error circle
```

---

## Widget Component Hierarchy

```
NotificationPreferencesWidget (Root)
├── SingleChildScrollView
│   └── Column
│       ├── Title: "Notification Settings"
│       │
│       ├── Section Header: "Notification Types"
│       │
│       ├── _buildNotificationToggle × 4
│       │   (Blessed Days, Daily Insights, Lunar, Quotes)
│       │   Each contains:
│       │   ├── Container (Card styling)
│       │   ├── Row
│       │   │   ├── Emoji icon (24px)
│       │   │   ├── Expanded Column
│       │   │   │   ├── Title text
│       │   │   │   └── Subtitle text
│       │   │   └── Switch
│       │   └── Border + shadow
│       │
│       ├── Section Header: "Quiet Hours"
│       │
│       ├── Quiet Hours Enable Toggle
│       │   Container (Card)
│       │   └── Row
│       │       ├── Icon
│       │       ├── Text + Description
│       │       └── Switch
│       │
│       ├── IF Quiet Hours Enabled:
│       │   ├── _buildTimePickerRow (Start)
│       │   ├── _buildTimePickerRow (End)
│       │   └── Info Box (Blue background)
│       │
│       └── Error Message (if any)
│           Container (Red background)
└── Bottom padding
```

---

## State Management (Riverpod)

```
notificationPreferencesProvider
├── State: NotificationPreferences (7 fields)
│   ├── blessedDayAlerts: bool
│   ├── dailyInsights: bool
│   ├── lunarPhaseAlerts: bool
│   ├── motivationalQuotes: bool
│   ├── quietHoursEnabled: bool
│   ├── quietHoursStart: String (HH:MM)
│   └── quietHoursEnd: String (HH:MM)
│
└── Methods in NotificationPreferencesNotifier
    ├── loadPreferences() → Load from API
    ├── updateBlessedDayAlerts() → Auto-save
    ├── updateDailyInsights() → Auto-save
    ├── updateLunarPhaseAlerts() → Auto-save
    ├── updateMotivationalQuotes() → Auto-save
    ├── updateQuietHours() → Auto-save (with validation)
    └── _savePreferences() → API call
```

---

## Network Requests & Responses

### On Widget Load
```
GET /notifications/preferences?device_id=device_xyz123
↓
Response (200):
{
  "success": true,
  "preferences": {
    "blessed_day_alerts": true,
    "daily_insights": true,
    "lunar_phase_alerts": false,
    "motivational_quotes": true,
    "quiet_hours_enabled": true,
    "quiet_hours_start": "22:00",
    "quiet_hours_end": "06:00"
  }
}
↓
Widget populates with these values
```

### When User Changes a Toggle
```
POST /notifications/preferences
Body:
{
  "device_id": "device_xyz123",
  "blessed_day_alerts": false,  ← Changed from true
  "daily_insights": true,
  "lunar_phase_alerts": false,
  "motivational_quotes": true,
  "quiet_hours_enabled": true,
  "quiet_hours_start": "22:00",
  "quiet_hours_end": "06:00"
}
↓
Response (200):
{
  "success": true,
  "preferences": {...same as request...},
  "updated_at": "2026-01-17T12:34:56Z"
}
↓
UI updates with success (no error shown)
```

### On Quiet Hours Change
```
POST /notifications/preferences
Body:
{
  "device_id": "device_xyz123",
  ...other preferences...,
  "quiet_hours_enabled": true,
  "quiet_hours_start": "23:00",  ← Changed from 22:00
  "quiet_hours_end": "06:00"
}
↓
Backend validates time format (HH:MM 24-hour)
↓
Response (200): Updated preferences
↓
Info box updates: "Notifications paused between 23:00 and 06:00"
```

---

## Error Handling & User Feedback

### Network Error
```
User Action: Toggle switch
↓
Error occurs: "Network error: Request failed"
↓
UI Response:
- Toggle reverts to previous state
- Red error box appears:
  "❌ Failed to save preferences: Network error"
- Error automatically clears after 3 seconds
```

### Time Format Error (Backend Validation)
```
User Action: Set quiet hours start to "25:00" (invalid)
↓
Backend rejects: Invalid time format
↓
UI Response:
- Time picker prevents invalid input (0-23 hours only)
- No error shown (prevented client-side)
```

### API Timeout
```
User Action: Enable quiet hours while offline
↓
API doesn't respond within 10 seconds
↓
UI Response:
- Toggle reverts
- Error message: "Request timeout - please try again"
- User can retry

```

---

## Accessibility Features

### Text Labels
- All toggles have descriptive labels
- Subtitle text explains purpose
- Error messages clearly state problem

### Color Contrast
- Primary text: AAA rated (7:1 contrast)
- Secondary text: AA rated (4.5:1 contrast)
- Button text: AAA rated

### Touch Targets
- Toggle switches: 48px height (Android standard)
- Time pickers: 56px height (Material standard)
- All tappable areas: minimum 48×48 dp

### Screen Reader Support (iOS/Android)
- Widget labels announced
- Toggle states announced
- Error messages announced
- Time picker accessible

---

## Platform-Specific Behaviors

### Android
```
Time Picker: Material 3 style (vertical)
Colors: Uses Material color system
Fonts: Roboto
Vibration: Short haptic feedback on toggle
Back Button: Returns to previous screen
```

### iOS
```
Time Picker: iOS style (scroll wheel)
Colors: Adapted for iOS aesthetic
Fonts: San Francisco
Haptics: Light impact on toggle
Swipe: Gesture to go back
```

---

## Performance Metrics

| Action | Target | Expected |
|--------|--------|----------|
| Widget build | <100ms | ✅ |
| Load preferences | <500ms | ✅ |
| Toggle response | <50ms | ✅ |
| Save to backend | <800ms | ✅ |
| Time picker open | <200ms | ✅ |
| Error display | <100ms | ✅ |

---

## Test Scenarios

### Happy Path
1. ✅ Open settings
2. ✅ Toggle blessed days OFF
3. ✅ Enable quiet hours
4. ✅ Set time to 11 PM - 7 AM
5. ✅ Close and reopen settings
6. ✅ Verify all preferences persisted

### Error Path
1. ✅ Toggle preference while offline
2. ✅ Observe error message
3. ✅ Toggle reverts
4. ✅ Go online
5. ✅ Toggle again
6. ✅ Observe success

### Edge Cases
1. ✅ Set quiet hours to midnight-spanning (e.g., 10pm-2am)
2. ✅ Change multiple preferences rapidly
3. ✅ Kill app during save operation
4. ✅ Test with very long device ID
5. ✅ Test with no internet connection

---

## Screenshots (Conceptual)

### Light Mode - Default State
```
┌─────────────────────────────────┐
│ < Settings                  ≡   │
├─────────────────────────────────┤
│ Notification Types              │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🌟 Blessed Days        [ON] │ │
│ │ Get notified on dates       │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 📚 Daily Insights      [ON] │ │
│ │ Receive daily reading       │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🌙 Lunar Updates       [OFF]│ │
│ │ Stay informed              │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 💫 Motivational       [ON]  │ │
│ │ Daily inspiration          │ │
│ └─────────────────────────────┘ │
│                                 │
│ Quiet Hours                     │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🌙 Enable Quiet Hours  [OFF]│ │
│ │ Pause notifications        │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

### Dark Mode - Quiet Hours Enabled
```
┌─────────────────────────────────┐
│ < Settings                  ≡   │
├─────────────────────────────────┤
│ ... (same notification toggles) │
│                                 │
│ Quiet Hours                     │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🌙 Enable Quiet Hours  [ON] │ │
│ │ Pause notifications        │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🕐 From         [22:00  🔧] │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ 🕐 To           [06:00  🔧] │ │
│ └─────────────────────────────┘ │
│                                 │
│ ┌─────────────────────────────┐ │
│ │ ℹ️ Notifications paused     │ │
│ │ between 22:00 and 06:00     │ │
│ └─────────────────────────────┘ │
└─────────────────────────────────┘
```

---

**UI Design Complete**
**User Experience: Intuitive & Accessible**
**Platform Compatibility: iOS & Android**
