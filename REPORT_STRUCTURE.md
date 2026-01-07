# Destiny Report Structure

## Overview
The destiny output has been restructured to include a report-ready container while maintaining full backward compatibility. All existing fields remain unchanged.

---

## Updated Response Shape

### Top-Level Keys (Unchanged)
- `life_seal` ✓
- `life_planet` ✓
- `physical_name_number` ✓
- `soul_number` ✓
- `personality_number` ✓
- `personal_year` ✓
- `blessed_years` ✓
- `blessed_days` ✓
- `life_cycle_phase` ✓
- `life_turning_points` ✓
- `life_cycles` ✓
- `turning_points` ✓
- `narrative` ✓
- **`report` ← NEW**

---

## Report Structure (New Top-Level Field)

```json
{
  "report": {
    "overview": { ... },
    "life_cycles": { ... },
    "turning_points": { ... },
    "closing_summary": { ... }
  }
}
```

### Section 1: Overview
Contains core identity numbers.

```json
{
  "overview": {
    "title": "Overview",
    "description": "Your core numerological profile.",
    "core_numbers": {
      "life_seal": {
        "number": 7,
        "planet": "Neptune",
        "description": "Your foundational life number, derived from your birth date."
      },
      "soul_number": {
        "number": 6,
        "description": "Your inner nature and deepest desires, derived from vowels in your name."
      },
      "personality_number": {
        "number": 5,
        "description": "Your outer expression and how others perceive you, derived from consonants in your name."
      },
      "personal_year": {
        "number": 3,
        "description": "Your current year's influence, based on today's date."
      }
    }
  }
}
```

### Section 2: Life Cycles
Three phases with interpretations and age ranges.

```json
{
  "life_cycles": {
    "title": "Life Cycles",
    "description": "Your life unfolds in three distinct phases, each with its own character and lessons.",
    "phases": [
      {
        "phase_number": 1,
        "cycle_number": 8,
        "age_range": "0–30",
        "interpretation": "Power & Achievement: A time that often involves stepping into your capabilities...",
        "narrative": "Ages 0–30: Power & Achievement: A time that often involves..."
      },
      {
        "phase_number": 2,
        "cycle_number": 7,
        "age_range": "30–55",
        "interpretation": "Reflection & Wisdom: This period invites deeper understanding...",
        "narrative": "Ages 30–55: Reflection & Wisdom: This period invites..."
      },
      {
        "phase_number": 3,
        "cycle_number": 6,
        "age_range": "55+",
        "interpretation": "Service & Harmony: A time when nurturing others...",
        "narrative": "Ages 55+: Service & Harmony: A time when nurturing..."
      }
    ]
  }
}
```

### Section 3: Turning Points
Key transition ages (36, 45, 54, 63) with interpretations.

```json
{
  "turning_points": {
    "title": "Turning Points",
    "description": "Natural transition points in your journey where shifts often occur.",
    "points": [
      {
        "age": 36,
        "turning_point_number": 8,
        "interpretation": "Power & Achievement: A time that often involves...",
        "narrative": "Around age 36, a natural transition point often emerges, bringing themes of..."
      },
      {
        "age": 45,
        "turning_point_number": 6,
        "interpretation": "Service & Harmony: A time when nurturing others...",
        "narrative": "Around age 45, a natural transition point often emerges..."
      },
      {
        "age": 54,
        "turning_point_number": 4,
        "interpretation": "Stability & Structure: This time often involves...",
        "narrative": "Around age 54, a natural transition point often emerges..."
      },
      {
        "age": 63,
        "turning_point_number": 3,
        "interpretation": "Expression & Creativity: A phase where creative output...",
        "narrative": "Around age 63, a natural transition point often emerges..."
      }
    ]
  }
}
```

### Section 4: Closing Summary
Narrative overview and life phase summary.

```json
{
  "closing_summary": {
    "title": "Closing Summary",
    "description": "A deeper perspective on your life journey.",
    "overview": "Your life unfolds through 3 distinct phases, each with its own character. These periods, called Life Cycles, tend to emerge naturally over time. Key transitions often appear at midlife points. Awareness of these patterns may help you approach life with greater clarity.",
    "life_phase_summary": [
      {
        "age_range": "0–30",
        "text": "Ages 0–30: Power & Achievement: A time that often involves..."
      },
      {
        "age_range": "30–55",
        "text": "Ages 30–55: Reflection & Wisdom: This period invites..."
      },
      {
        "age_range": "55+",
        "text": "Ages 55+: Service & Harmony: A time when nurturing..."
      }
    ]
  }
}
```

---

## Key Design Principles

✓ **Non-breaking**: All existing fields remain unchanged
✓ **Additive**: Report is a new top-level field
✓ **Reference-only**: Report uses existing data, no new numerology
✓ **Ordered sections**: Overview → Life Cycles → Turning Points → Summary
✓ **Frontend compatible**: Existing code continues to work unchanged

---

## Usage Example

For the full `/decode/full` endpoint, the response now includes:

```json
{
  "input": { ... },
  "core": {
    "life_seal": 7,
    "life_planet": "Neptune",
    "soul_number": 6,
    "personality_number": 5,
    "personal_year": 3,
    "blessed_years": [...],
    "blessed_days": [...],
    "life_cycle_phase": "Establishment",
    "life_turning_points": [36, 45, 54, 63],
    "life_cycles": [...],
    "turning_points": [...],
    "narrative": {...},
    "report": {
      "overview": {...},
      "life_cycles": {...},
      "turning_points": {...},
      "closing_summary": {...}
    }
  },
  "interpretations": { ... }
}
```

---

## Implementation Notes

- Report builder: `backend/app/services/report_service.py`
- Integration: `backend/app/services/destiny_service.py`
- No changes to numerology logic
- Narrative text remains unchanged
- All existing API endpoints continue to work
