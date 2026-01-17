"""
Narrative builder for Life Cycles and Turning Points.
Templates are deterministic, based on numerology interpretations.
No AI generation; purely template-driven from existing data.
"""


# =============================================================================
# NARRATIVE TEMPLATES
# =============================================================================

# Overall life overview template
LIFE_OVERVIEW_TEMPLATE = (
    "Your life unfolds through {num_phases} distinct phases, each with its own character. "
    "These periods, called Life Cycles, tend to emerge naturally over time. "
    "Key transitions often appear at midlife points. "
    "Awareness of these patterns may help you approach life with greater clarity."
)

# Life Cycle phase narrative templates
LIFE_CYCLE_TEMPLATES = {
    1: "Foundation & New Beginnings: A time that often involves planting seeds and exploring new directions. You may find yourself establishing patterns that shape what comes later.",
    2: "Cooperation & Partnership: This period tends to emphasize balance and relationships. Working together with others toward shared goals often becomes central.",
    3: "Expression & Creativity: A phase where creative output and communication may come to the forefront. You might find new ways to bring your ideas into visible form.",
    4: "Stability & Structure: This time often involves building solid foundations. Creating systems and establishing lasting order may become important themes.",
    5: "Freedom & Adventure: A period marked by change and exploration. You may experience shifts in circumstances that invite adaptation and growth.",
    6: "Service & Harmony: A time when nurturing others and creating peaceful environments often takes priority. Supporting those around you may feel especially meaningful.",
    7: "Reflection & Wisdom: This period invites deeper understanding and introspection. Inner development and quiet contemplation tend to become more significant.",
    8: "Power & Achievement: A time that often involves stepping into your capabilities. You may find yourself taking charge and working toward tangible goals.",
    9: "Completion & Transition: A phase of natural endings and releasing what no longer serves. This period tends to prepare the way for new beginnings.",
}

# Turning Point narrative template
TURNING_POINT_TEMPLATE = (
    "Around age {age}, a natural transition point often emerges, bringing themes of {interpretation_hint}. "
    "This shift may invite you to adjust your focus and explore new possibilities."
)

# Default fallback for unknown numbers
DEFAULT_CYCLE_DESCRIPTION = "A meaningful phase in your journey that carries its own lessons and possibilities."


# =============================================================================
# NARRATIVE BUILDER
# =============================================================================

def build_narrative(
    life_cycles: list[dict],
    turning_points: list[dict]
) -> dict:
    """
    Build a deterministic narrative summary from Life Cycles and Turning Points.

    Args:
        life_cycles: List of dicts with keys 'number', 'interpretation', 'age_range'
        turning_points: List of dicts with keys 'number', 'interpretation', 'age'

    Returns:
        Dict with keys: 'overview', 'life_phases', 'turning_points'
    """
    
    # Build overall overview
    num_phases = len(life_cycles)
    overview = LIFE_OVERVIEW_TEMPLATE.format(num_phases=num_phases)
    
    # Build life phase narratives
    life_phases = []
    for cycle in life_cycles:
        number = cycle.get("number", 0)
        age_range = cycle.get("age_range", "")
        
        # Get template description or fallback
        phase_description = LIFE_CYCLE_TEMPLATES.get(number, DEFAULT_CYCLE_DESCRIPTION)
        
        phase_text = f"Ages {age_range}: {phase_description}"
        
        life_phases.append({
            "age_range": age_range,
            "text": phase_text
        })
    
    # Build turning point narratives
    turning_points_narrative = []
    for tp in turning_points:
        age = tp.get("age", 0)
        number = tp.get("number", 0)
        interpretation = tp.get("interpretation", "significant transition")
        
        # Extract brief hint from interpretation (first phrase, max 5 words)
        hint = _extract_hint(interpretation)
        
        tp_text = TURNING_POINT_TEMPLATE.format(
            age=age,
            interpretation_hint=hint
        )
        
        turning_points_narrative.append({
            "age": age,
            "text": tp_text
        })
    
    return {
        "overview": overview,
        "life_phases": life_phases,
        "turning_points": turning_points_narrative
    }


# =============================================================================
# HELPERS
# =============================================================================

def _extract_hint(interpretation: str, max_words: int = 8) -> str:
    """
    Extract a brief hint from interpretation text.
    Returns first phrase up to max_words, ending at complete word/punctuation.
    
    Args:
        interpretation: Full interpretation text
        max_words: Maximum words to extract (increased to 8 for completeness)
    
    Returns:
        Brief hint phrase
    """
    if not interpretation:
        return "personal growth"
    
    # Clean up interpretation text
    text = interpretation.strip()
    
    # If there's a comma or period early, stop there
    first_comma = text.find(',')
    first_period = text.find('.')
    
    # Use the earliest punctuation as natural break point
    if first_comma > 0 and first_comma < 60:  # Reasonable comma position
        text = text[:first_comma]
    elif first_period > 0 and first_period < 80:  # Reasonable period position
        text = text[:first_period]
    
    # Split and limit to max_words
    words = text.split()[:max_words]
    hint = " ".join(words).lower().rstrip(".,;:")
    
    return hint if hint else "significant transition"
