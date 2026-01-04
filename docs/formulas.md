# Destiny Decoder – Core Calculation Specification
Version: 1.0  
Source of Truth: Destiny_Decypher_V9.18.xlsx  
Purpose: Define all deterministic calculations used by the Destiny Decoder backend.

IMPORTANT:
- All calculations MUST be deterministic.
- No AI, randomness, or inference is allowed in this file.
- All outputs must match Excel results for the same inputs.
- This document defines the ONLY valid calculation logic.

---

## 1. GENERAL UTILITIES

### 1.1 Digit Reduction

Definition:
Repeatedly sum the digits of a number until a single digit (1–9) is obtained.

Pseudocode:
function reduce_to_single_digit(n):
while n > 9:
n = sum(digits(n))
return n


Notes:
- No master number exception unless explicitly added later.
- Used globally across all modules.

---

## 2. INPUT DEFINITIONS

### 2.1 Required Inputs
- day_of_birth (integer: 1–31)
- month_of_birth (integer: 1–12)
- year_of_birth (integer: YYYY)
- first_name (string)

### 2.2 Optional Inputs
- other_names (string)
- gender (enum: male, female)
- partner_name (string)

---

## 3. LIFE SEAL MODULE

### 3.1 Reduced Date Components

day_r = reduce_to_single_digit(day_of_birth)
month_r = reduce_to_single_digit(month_of_birth)
year_r = reduce_to_single_digit(year_of_birth)


---

### 3.2 Life Seal Number

life_seal_raw = day_r + month_r + year_r
life_seal = reduce_to_single_digit(life_seal_raw)


---

### 3.3 Planetary Mapping

1 → SUN
2 → MOON
3 → JUPITER
4 → URANUS
5 → MERCURY
6 → VENUS
7 → NEPTUNE
8 → SATURN
9 → MARS

life_planet = planet_map[life_seal]


---

## 4. NAME-BASED NUMEROLOGY

### 4.1 Letter-to-Number Mapping (Physical & Hebrew)

A J S → 1
B K T → 2
C L U → 3
D M V → 4
E N W → 5
F O X → 6
G P Y → 7
H Q Z → 8
I R → 9


Only alphabetical characters are processed.

---

### 4.2 Physical Name Number

Definition:
Sum of letter values of full name (first_name + other_names).

physical_name_total = sum(letter_map[char])
physical_name_number = reduce_to_single_digit(physical_name_total)


---

### 4.3 Soul’s Edge / Desire / Motivation (Vowels Only)

Definition:
Sum of vowels in the name.

Vowels:
A, E, I, O, U

soul_total = sum(letter_map[vowel])
soul_number = reduce_to_single_digit(soul_total)


---

### 4.4 Personality Number (Consonants Only)

Definition:
Sum of consonants in the name.

personality_total = sum(letter_map[consonants])
personality_number = reduce_to_single_digit(personality_total)


---

## 5. PERSONAL YEAR MODULE

### 5.1 Personal Year Number

current_year_r = reduce_to_single_digit(current_year)

personal_year_raw = day_r + month_r + current_year_r
personal_year = reduce_to_single_digit(personal_year_raw)


---

## 6. BLESSED YEARS MODULE

Definition:
Blessed years repeat in cycles of 6 years.

blessed_years = [current_year + (6 * n)] for n ≥ 0


Default:
- Generate next 20 blessed years.

---

## 7. BLESSED DAYS MODULE

Definition:
Days of the month whose reduced value equals reduced day of birth.

target = reduce_to_single_digit(day_of_birth)

blessed_days = [
d for d in range(1, 32)
if reduce_to_single_digit(d) == target
]


---

## 8. PERSONAL MONTH MODULE

### 8.1 Personal Month Number

personal_month = reduce_to_single_digit(personal_year + calendar_month)


Used for:
- Monthly focus
- Instalments
- Cardinal vibration analysis

---

## 9. LIFE CYCLE PHASES

Definition:
Life is divided into age-based phases.

if age <= 30:
phase = "Formative / Development"
elif age <= 45:
phase = "Establishment"
elif age <= 63:
phase = "Fruit / Manifestation"
else:
phase = "Legacy Phase"


---

## 10. LIFE TURNING POINTS

Fixed ages:

36, 45, 54, 63


These represent major life transitions.

---

## 11. COMPATIBILITY MODULE (OPTIONAL)

### 11.1 Sex / Intimacy Number
Uses Physical Name Number of first name only.

sex_number = calculate_name_number(first_name)


---

### 11.2 Compatibility Evaluation

difference = abs(number_1 - number_2)

if difference == 0:
compatibility = "Very Strong"
elif difference <= 2:
compatibility = "Compatible"
else:
compatibility = "Challenging"


---

## 12. OUTPUT SUMMARY

A complete destiny calculation should output:

- life_seal
- life_planet
- physical_name_number
- soul_number
- personality_number
- personal_year
- blessed_years
- blessed_days
- life_cycle_phase
- life_turning_points
- compatibility (if applicable)

---

## 13. NON-GOALS

The following are explicitly excluded from this document:
- Interpretation text
- Bible verses
- Prayers or affirmations
- AI-generated content
- UI logic

These belong to higher layers of the system.

---

END OF SPECIFICATION

