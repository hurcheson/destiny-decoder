"""
Report builder for Destiny readings.
Organizes existing numerology and narrative data into report-ready sections.
Pure organizational layer - no new numerology, no new data generation.
"""


def build_report(
    life_cycles: list[dict],
    turning_points: list[dict],
    narrative: dict,
    life_seal: int,
    life_planet: str,
    soul_number: int,
    personality_number: int,
    personal_year: int,
) -> dict:
    """
    Build a report-ready container from existing data.
    
    Sections (in order):
    1. Overview - Life seal, core numbers, personal year
    2. Life Cycles - Three distinct phases with age ranges and interpretations
    3. Turning Points - Key transition ages
    4. Closing Summary - Narrative overview
    
    Args:
        life_cycles: List of dicts with 'number', 'interpretation', 'age_range'
        turning_points: List of dicts with 'number', 'interpretation', 'age'
        narrative: Dict with 'overview', 'life_phases', 'turning_points'
        life_seal: Life seal number (1-9)
        life_planet: Associated planet name
        soul_number: Soul number (1-9)
        personality_number: Personality number (1-9)
        personal_year: Current personal year (1-9)
    
    Returns:
        Dict with keys: 'overview', 'life_cycles', 'turning_points', 'closing_summary'
    """
    
    # SECTION 1: Overview
    # Core identity numbers and current year influence
    overview = {
        "title": "Overview",
        "subtitle": "Your Core Numerological Profile",
        "content_type": "text",
        "description": "Your core numerological profile.",
        "core_numbers": {
            "life_seal": {
                "number": life_seal,
                "planet": life_planet,
                "description": "Your foundational life number, derived from your birth date."
            },
            "soul_number": {
                "number": soul_number,
                "description": "Your inner nature and deepest desires, derived from vowels in your name."
            },
            "personality_number": {
                "number": personality_number,
                "description": "Your outer expression and how others perceive you, derived from consonants in your name."
            },
            "personal_year": {
                "number": personal_year,
                "description": "Your current year's influence, based on today's date."
            }
        }
    }
    
    # SECTION 2: Life Cycles
    # Three phases with their interpretations and age ranges
    life_cycles_section = {
        "title": "Life Cycles",
        "subtitle": "Three Phases of Your Life Journey",
        "content_type": "list",
        "description": "Your life unfolds in three distinct phases, each with its own character and lessons.",
        "phases": []
    }
    
    for idx, cycle in enumerate(life_cycles, 1):
        phase_number = cycle.get("number")
        age_range = cycle.get("age_range", "")
        interpretation = cycle.get("interpretation", "")
        
        # Find corresponding narrative text
        narrative_text = ""
        if narrative.get("life_phases"):
            if idx <= len(narrative["life_phases"]):
                narrative_text = narrative["life_phases"][idx - 1].get("text", "")
        
        life_cycles_section["phases"].append({
            "phase_number": idx,
            "cycle_number": phase_number,
            "age_range": age_range,
            "interpretation": interpretation,
            "narrative": narrative_text
        })
    
    # SECTION 3: Turning Points
    # Key transition ages derived from life cycles
    turning_points_section = {
        "title": "Turning Points",
        "subtitle": "Key Transitions in Your Life Path",
        "content_type": "timeline",
        "description": "Natural transition points in your journey where shifts often occur.",
        "points": []
    }
    
    turning_point_ages = [36, 45, 54, 63]
    
    for idx, tp in enumerate(turning_points):
        tp_number = tp.get("number")
        age = turning_point_ages[idx] if idx < len(turning_point_ages) else None
        interpretation = tp.get("interpretation", "")
        
        # Find corresponding narrative text
        narrative_text = ""
        if narrative.get("turning_points"):
            if idx < len(narrative["turning_points"]):
                narrative_text = narrative["turning_points"][idx].get("text", "")
        
        turning_points_section["points"].append({
            "age": age,
            "turning_point_number": tp_number,
            "interpretation": interpretation,
            "narrative": narrative_text
        })
    
    # SECTION 4: Closing Summary
    # Narrative overview and life phases summary
    closing_summary = {
        "title": "Closing Summary",
        "subtitle": "Your Life Journey Perspective",
        "content_type": "text",
        "description": "A deeper perspective on your life journey.",
        "overview": narrative.get("overview", ""),
        "life_phase_summary": narrative.get("life_phases", [])
    }
    
    return {
        "overview": overview,
        "life_cycles": life_cycles_section,
        "turning_points": turning_points_section,
        "closing_summary": closing_summary
    }
