# Destiny Decoder API Contract

This document describes the public API endpoints available in the Destiny Decoder backend.

## Base URL
- Local development: `http://127.0.0.1:8000`
- Swagger UI: `/docs`

## Authentication
- Not required (public endpoints). If adding auth later, prefer JWT with short-lived tokens.

## Content Type
- All requests: `application/json`
- All responses: `application/json`

---

## Daily Insights

### POST `/daily/insight`
Returns complete daily guidance including power number, blessed day status, and interpretation.

Request body:
```
{
	"life_seal": 7,              // 1-9
	"day_of_birth": 9,           // 1-31
	"target_date": "2026-01-09" // optional, ISO YYYY-MM-DD (defaults to today)
}
```

Response body:
```
{
	"date": "2026-01-09",
	"day_of_week": "Friday",
	"power_number": 9,
	"is_blessed_day": true,
	"insight": {
		"title": "Day of Completion",
		"energy": "Release & Compassion",
		"insight": "...",
		"action_focus": ["..."],
		"spiritual_guidance": "...",
		"energy_color": "Soft Lavender",
		"affirmation": "...",
		"caution": "..."
	},
	"brief_insight": "Release what no longer serves..."
}
```

Errors:
- 400: Invalid date format or out-of-range values
- 500: Server error calculating insight

### POST `/daily/weekly`
Returns 7-day power numbers and brief insights, useful for weekly planning.

Request body:
```
{
	"life_seal": 7,               // 1-9
	"start_date": "2026-01-09"   // optional, ISO (defaults to today)
}
```

Response body:
```
{
	"week_starting": "2026-01-09",
	"daily_previews": [
		{ "date": "2026-01-09", "day_of_week": "Friday", "power_number": 9, "brief_insight": "..." },
		{ "date": "2026-01-10", "day_of_week": "Saturday", "power_number": 1, "brief_insight": "..." },
		// ... 5 more days
	]
}
```

Errors:
- 400: Invalid date format or out-of-range values
- 500: Server error calculating weekly insights

### POST `/daily/blessed-days`
Lists all blessed days (by day-of-month reduction) for a specific month.

Request body:
```
{
	"day_of_birth": 9,   // 1-31
	"month": 1,          // optional, 1-12
	"year": 2026         // optional, YYYY
}
```

Response body:
```
{
	"month": 1,
	"year": 2026,
	"month_name": "January",
	"blessed_dates": ["2026-01-09", "2026-01-18", "2026-01-27"]
}
```

Errors:
- 400: Out-of-range values
- 500: Server error calculating blessed days

### POST `/daily/personal-month`
Calculates the personal month number and returns a brief theme.

Request body:
```
{
	"day_of_birth": 9,
	"month_of_birth": 5,
	"year_of_birth": 1990,
	"target_month": 1,        // optional, 1-12
	"target_year": 2026       // optional, YYYY
}
```

Response body:
```
{
	"personal_month": 7,
	"personal_year": 6,
	"calendar_month": 1,
	"calendar_year": 2026,
	"month_name": "January",
	"theme": "Introspection and spiritual growth"
}
```

Errors:
- 400: Out-of-range values
- 500: Server error calculating personal month

---

## Status Codes
- 200: Success
- 400: Client validation error
- 500: Server error

## Notes
- Power number calculation: reduce(day + month + year + life_seal)
- Blessed days: all days in the month whose day-of-month reduces to the birth day’s reduced number
