# Phase 3.2 Quick Reference: Presentation Metadata

## What Changed?
✓ Added **title**, **subtitle**, and **content_type** to each report section
✓ Enabling export and presentation rendering
✓ Zero breaking changes
✓ Minimal diff (8 lines)

---

## New Metadata Fields

### title (string)
Section heading - already existed, preserved

### subtitle (string)  
Human-readable description of section content

### content_type (string)
Rendering hint for export/presentation:
- `"text"` - Narrative/prose content
- `"list"` - Ordered sequence (Life Cycles)
- `"timeline"` - Chronological events (Turning Points)

---

## Section Metadata

| Section | Title | Subtitle | Type |
|---------|-------|----------|------|
| Overview | "Overview" | "Your Core Numerological Profile" | text |
| Life Cycles | "Life Cycles" | "Three Phases of Your Life Journey" | list |
| Turning Points | "Turning Points" | "Key Transitions in Your Life Path" | timeline |
| Closing Summary | "Closing Summary" | "Your Life Journey Perspective" | text |

---

## Example Structure

```
report
├── overview
│   ├── title: "Overview"
│   ├── subtitle: "Your Core Numerological Profile"
│   ├── content_type: "text"
│   ├── description: "..."
│   └── core_numbers: {...}
│
├── life_cycles
│   ├── title: "Life Cycles"
│   ├── subtitle: "Three Phases of Your Life Journey"
│   ├── content_type: "list"
│   ├── description: "..."
│   └── phases: [...]
│
├── turning_points
│   ├── title: "Turning Points"
│   ├── subtitle: "Key Transitions in Your Life Path"
│   ├── content_type: "timeline"
│   ├── description: "..."
│   └── points: [...]
│
└── closing_summary
    ├── title: "Closing Summary"
    ├── subtitle: "Your Life Journey Perspective"
    ├── content_type: "text"
    ├── description: "..."
    ├── overview: "..."
    └── life_phase_summary: [...]
```

---

## Access in Frontend

```javascript
// Get section metadata
const section = response.report.overview;
const title = section.title;           // "Overview"
const subtitle = section.subtitle;     // "Your Core Numerological Profile"
const type = section.content_type;     // "text"

// Render based on content type
switch (type) {
  case 'text':
    renderTextSection(section);
    break;
  case 'list':
    renderListSection(section);
    break;
  case 'timeline':
    renderTimelineSection(section);
    break;
}
```

---

## Export Use Cases

### PDF Generation
```
Use content_type to select PDF template:
- text → paragraph layout
- list → bullet/numbered layout
- timeline → sequential vertical layout
```

### HTML Export
```
Semantic structure:
<section data-type="text">
  <h2>{title}</h2>
  <h3>{subtitle}</h3>
  <p>{description}</p>
  {content}
</section>
```

### JSON/CSV
```
Add metadata fields for data transformation:
{
  "section_type": "text",
  "section_title": "Overview",
  "section_subtitle": "...",
  "content": {...}
}
```

---

## Backward Compatibility

✓ All existing content fields unchanged
✓ All existing rendering code works
✓ All tests passing
✓ New fields are additive only
✓ Can be safely ignored by existing code

---

## Files Modified

```
backend/app/services/report_service.py  (+8 lines)
  - 2 lines per section (subtitle + content_type)
```

---

## Implementation Details

Each section now includes:
```python
{
    "title": "...",              # Existing
    "subtitle": "...",           # NEW
    "content_type": "...",       # NEW
    "description": "...",        # Existing
    ...content fields...         # Existing
}
```

---

## Status: COMPLETE ✓

Metadata added for export-ready reporting:
- ✓ Section titles and subtitles
- ✓ Content type hints
- ✓ Zero breaking changes
- ✓ All tests passing
- ✓ Backward compatible

Ready for PDF/export features.
