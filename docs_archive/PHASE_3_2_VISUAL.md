# Visual Structure: Report with Presentation Metadata

## Report Hierarchy

```
report/
├── overview (text)
│   ├── title: "Overview"
│   ├── subtitle: "Your Core Numerological Profile"
│   ├── content_type: "text"
│   ├── description: "Your core numerological profile."
│   └── core_numbers/
│       ├── life_seal: {number, planet, description}
│       ├── soul_number: {number, description}
│       ├── personality_number: {number, description}
│       └── personal_year: {number, description}
│
├── life_cycles (list)
│   ├── title: "Life Cycles"
│   ├── subtitle: "Three Phases of Your Life Journey"
│   ├── content_type: "list"
│   ├── description: "Your life unfolds in three distinct phases..."
│   └── phases/ (array of 3)
│       ├── [0] {phase_number: 1, cycle_number: 8, age_range: "0–30", ...}
│       ├── [1] {phase_number: 2, cycle_number: 7, age_range: "30–55", ...}
│       └── [2] {phase_number: 3, cycle_number: 6, age_range: "55+", ...}
│
├── turning_points (timeline)
│   ├── title: "Turning Points"
│   ├── subtitle: "Key Transitions in Your Life Path"
│   ├── content_type: "timeline"
│   ├── description: "Natural transition points in your journey..."
│   └── points/ (array of 4)
│       ├── [0] {age: 36, turning_point_number: 8, ...}
│       ├── [1] {age: 45, turning_point_number: 6, ...}
│       ├── [2] {age: 54, turning_point_number: 4, ...}
│       └── [3] {age: 63, turning_point_number: 3, ...}
│
└── closing_summary (text)
    ├── title: "Closing Summary"
    ├── subtitle: "Your Life Journey Perspective"
    ├── content_type: "text"
    ├── description: "A deeper perspective on your life journey."
    ├── overview: "Your life unfolds through 3 distinct phases..."
    └── life_phase_summary/ (array of 3)
        ├── [0] {age_range: "0–30", text: "Ages 0–30: Power & Achievement..."}
        ├── [1] {age_range: "30–55", text: "Ages 30–55: Reflection & Wisdom..."}
        └── [2] {age_range: "55+", text: "Ages 55+: Service & Harmony..."}
```

---

## Section Types & Rendering

### Overview (type: text)
```
┌──────────────────────────────────────┐
│        OVERVIEW                      │
│  Your Core Numerological Profile     │  ← subtitle
├──────────────────────────────────────┤
│ Your core numerological profile...   │  ← description
│                                      │
│ Life Seal: 4 (URANUS)               │
│ Soul Number: 6                       │  ← core_numbers
│ Personality Number: 5                │
│ Personal Year: 3                     │
└──────────────────────────────────────┘
```

### Life Cycles (type: list)
```
┌──────────────────────────────────────┐
│        LIFE CYCLES                   │
│  Three Phases of Your Life Journey   │  ← subtitle
├──────────────────────────────────────┤
│ Your life unfolds in three...        │  ← description
│                                      │
│ ◆ Phase 1 (Ages 0–30)               │
│   Cycle 8: Power & Achievement      │
│   [interpretation & narrative]      │
│                                      │
│ ◆ Phase 2 (Ages 30–55)              │  ← list items
│   Cycle 7: Reflection & Wisdom      │
│   [interpretation & narrative]      │
│                                      │
│ ◆ Phase 3 (Ages 55+)                │
│   Cycle 6: Service & Harmony        │
│   [interpretation & narrative]      │
└──────────────────────────────────────┘
```

### Turning Points (type: timeline)
```
Age 0                                  Age 100
|◄─────────────────────────────────────►|

Age 36 ━━ Turning Point 1 (TP 8)
  └─ Around age 36, a natural transition...

Age 45 ━━ Turning Point 2 (TP 6)
  └─ Around age 45, a natural transition...

Age 54 ━━ Turning Point 3 (TP 4)
  └─ Around age 54, a natural transition...

Age 63 ━━ Turning Point 4 (TP 3)
  └─ Around age 63, a natural transition...
```

### Closing Summary (type: text)
```
┌──────────────────────────────────────┐
│      CLOSING SUMMARY                 │
│    Your Life Journey Perspective     │  ← subtitle
├──────────────────────────────────────┤
│ A deeper perspective on your...      │  ← description
│                                      │
│ Your life unfolds through 3 distinct │
│ phases, each with its own character. │  ← overview
│ These periods, called Life Cycles,   │
│ tend to emerge naturally over time.  │
│ Key transitions often appear at      │
│ midlife points. Awareness of these   │
│ patterns may help you approach life  │
│ with greater clarity.                │
│                                      │
│ Phase Summary:                       │  ← life_phase_summary
│ • Ages 0–30: Power & Achievement... │
│ • Ages 30–55: Reflection & Wisdom...│
│ • Ages 55+: Service & Harmony...    │
└──────────────────────────────────────┘
```

---

## Metadata Flow

```
Backend: calculate_destiny()
    ↓
Backend: build_narrative()
    ↓
Backend: build_report()  ← Adds metadata here
    ├─ "title" (existing)
    ├─ "subtitle" (NEW)
    ├─ "content_type" (NEW)
    └─ Content data (existing)
    ↓
API Response: result["report"]
    ↓
Frontend: response.report
    ├─ Read metadata
    ├─ Detect content_type
    ├─ Select renderer
    └─ Render section
```

---

## Content Type Decision Tree

```
report.section.content_type
│
├─ "text"
│  └─ Render as prose/narrative
│     • Paragraph layout
│     • Word-wrapping
│     • Full width
│     • Sections: Overview, Closing Summary
│
├─ "list"
│  └─ Render as ordered items
│     • Card layout
│     • Numbered items
│     • Multi-column
│     • Section: Life Cycles (3 phases)
│
└─ "timeline"
   └─ Render as chronological events
      • Timeline visualization
      • Age markers (36, 45, 54, 63)
      • Vertical sequence
      • Section: Turning Points (4 ages)
```

---

## Metadata Usage Examples

### Check Section Type
```javascript
const contentType = report.life_cycles.content_type;
console.log(contentType); // "list"
```

### Build Header
```javascript
const header = `${report.overview.title}: ${report.overview.subtitle}`;
console.log(header);
// "Overview: Your Core Numerological Profile"
```

### Select Renderer
```javascript
const renderers = {
  'text': renderTextSection,
  'list': renderListSection,
  'timeline': renderTimelineSection
};

const renderer = renderers[section.content_type];
renderer(section);
```

### Generate PDF
```javascript
sections.forEach(section => {
  const template = templates[section.content_type];
  pdf.addPage(template.render(section));
});
```

---

## Before vs After

### BEFORE (Phase 3.1)
```json
{
  "title": "Overview",
  "description": "...",
  "core_numbers": {...}
}
```

### AFTER (Phase 3.2)
```json
{
  "title": "Overview",
  "subtitle": "Your Core Numerological Profile",
  "content_type": "text",
  "description": "...",
  "core_numbers": {...}
}
```

---

## Key Features

✓ **Export-Ready** - Metadata guides rendering
✓ **Type-Safe** - Content type indicates format
✓ **Backward Compatible** - Old code still works
✓ **Self-Documenting** - Subtitles explain content
✓ **Framework Agnostic** - No platform-specific code
✓ **Extensible** - Easy to add more metadata
✓ **Minimal** - Only essential fields added

---

## Files Modified

```
backend/app/services/report_service.py
├─ Added subtitle to Overview
├─ Added content_type to Overview
├─ Added subtitle to Life Cycles
├─ Added content_type to Life Cycles
├─ Added subtitle to Turning Points
├─ Added content_type to Turning Points
├─ Added subtitle to Closing Summary
└─ Added content_type to Closing Summary
```

**Total: 8 lines added, 0 lines removed**
