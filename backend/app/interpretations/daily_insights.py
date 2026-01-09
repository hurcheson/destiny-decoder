"""
Daily Insights Interpretations
Provides personalized daily guidance based on calculated power numbers (1-9).
Each insight includes practical action, spiritual focus, and energy theme.
"""

DAILY_INSIGHTS = {
    1: {
        "title": "Day of Initiative",
        "energy": "Leadership & New Beginnings",
        "insight": "Today's energy calls you to lead with confidence and take decisive action. New opportunities emerge when you step forward courageously. Trust your vision and initiate what you've been contemplating.",
        "action_focus": [
            "Start that project you've been postponing",
            "Make a bold decision you've been avoiding",
            "Take initiative in a relationship or situation"
        ],
        "spiritual_guidance": "Ask for divine alignment before acting. Let courage be paired with wisdom, not recklessness.",
        "energy_color": "Vibrant Red",
        "affirmation": "I am a confident leader. I trust my vision and act with courage.",
        "caution": "Avoid impulsiveness. Think before you leap, but don't overthink into paralysis."
    },
    2: {
        "title": "Day of Harmony",
        "energy": "Partnership & Patience",
        "insight": "Today favors cooperation over competition. Your sensitivity to others' needs opens doors that force cannot. Practice patience and listen deeply. Solutions emerge through collaboration, not control.",
        "action_focus": [
            "Reach out to mend a relationship",
            "Seek input before making solo decisions",
            "Practice active listening in all conversations"
        ],
        "spiritual_guidance": "Pursue peace without becoming passive. Balance giving with healthy boundaries.",
        "energy_color": "Soft Silver",
        "affirmation": "I honor connection. I listen with presence and speak with grace.",
        "caution": "Don't lose yourself trying to please everyone. Harmony includes honoring your own needs."
    },
    3: {
        "title": "Day of Expression",
        "energy": "Creativity & Communication",
        "insight": "Your voice carries power today. Share your truth, create something beautiful, or inspire others with your words. This is a day for artistic flow, social connection, and joyful self-expression.",
        "action_focus": [
            "Write, paint, or create something meaningful",
            "Share your story or ideas with others",
            "Encourage someone who needs uplifting"
        ],
        "spiritual_guidance": "Use words to edify, not embellish. Let truth govern your expression.",
        "energy_color": "Bright Yellow",
        "affirmation": "My voice matters. I express myself with clarity, creativity, and joy.",
        "caution": "Avoid scattering energy across too many ideas. Focus your creative power on one meaningful thing."
    },
    4: {
        "title": "Day of Foundation",
        "energy": "Structure & Stability",
        "insight": "Today is for building, organizing, and strengthening foundations. Progress comes through discipline and practical action. Focus on systems, routines, and what creates lasting stability in your life.",
        "action_focus": [
            "Organize your space, finances, or schedule",
            "Create a routine that supports your goals",
            "Complete a task that's been lingering"
        ],
        "spiritual_guidance": "Let diligence be paired with faith. Build on rock, not anxiety or control.",
        "energy_color": "Earthy Brown",
        "affirmation": "I build my life on solid ground. My discipline creates lasting abundance.",
        "caution": "Don't become so rigid that you miss necessary adjustments. Balance structure with flexibility."
    },
    5: {
        "title": "Day of Freedom",
        "energy": "Change & Adventure",
        "insight": "Today brings unexpected opportunities through adaptability. Embrace change, explore new paths, and welcome the unknown. Your willingness to pivot opens doors to exciting possibilities.",
        "action_focus": [
            "Try something you've never done before",
            "Say yes to an unexpected opportunity",
            "Break a routine that no longer serves you"
        ],
        "spiritual_guidance": "Let freedom be directed by purpose, not restlessness. Not all change is progress.",
        "energy_color": "Electric Blue",
        "affirmation": "I embrace change with courage. I flow with life's rhythm while staying rooted in purpose.",
        "caution": "Avoid impulsive decisions disguised as adventure. True freedom includes responsibility."
    },
    6: {
        "title": "Day of Service",
        "energy": "Love & Responsibility",
        "insight": "Today calls you to nurture, support, and care for those around you. Your gift of presence and practical help makes a profound difference. Balance giving with self-care to sustain your loving energy.",
        "action_focus": [
            "Show up for someone who needs you",
            "Create beauty and harmony in your environment",
            "Practice self-care without guilt"
        ],
        "spiritual_guidance": "Love practically, not just emotionally. Service includes healthy boundaries.",
        "energy_color": "Warm Pink",
        "affirmation": "I give and receive love freely. I care for others while honoring myself.",
        "caution": "Don't sacrifice yourself on the altar of others' needs. You can't pour from an empty cup."
    },
    7: {
        "title": "Day of Reflection",
        "energy": "Wisdom & Solitude",
        "insight": "Today favors introspection, study, and spiritual connection. Withdraw from noise to listen to your inner voice. Deep wisdom emerges in silence. Trust your intuition and seek meaning beneath the surface.",
        "action_focus": [
            "Spend time in quiet reflection or meditation",
            "Study something that deepens your understanding",
            "Trust your intuition on a pending decision"
        ],
        "spiritual_guidance": "Seek God in stillness. Let silence reveal what noise conceals.",
        "energy_color": "Mystic Purple",
        "affirmation": "I trust my inner knowing. Wisdom flows through me when I am still.",
        "caution": "Don't isolate to the point of disconnection. Balance solitude with healthy connection."
    },
    8: {
        "title": "Day of Mastery",
        "energy": "Power & Achievement",
        "insight": "Today is for strategic action, goal execution, and stepping into your authority. Your capacity to manifest is amplified. Focus on what creates tangible results and lasting impact in your material world.",
        "action_focus": [
            "Make a strategic move toward a major goal",
            "Negotiate with confidence and clarity",
            "Take ownership of a situation requiring leadership"
        ],
        "spiritual_guidance": "Use power to serve, not dominate. True mastery includes humility and generosity.",
        "energy_color": "Deep Gold",
        "affirmation": "I am powerful and wise. I create abundance while serving the greater good.",
        "caution": "Don't let ambition blind you to relationships. Success without connection is hollow."
    },
    9: {
        "title": "Day of Completion",
        "energy": "Release & Compassion",
        "insight": "Today is for letting go, forgiving, and making space for new beginnings. Release what no longer serves you with grace. Your compassion for yourself and others creates healing closure and opens fresh chapters.",
        "action_focus": [
            "Forgive someone (including yourself)",
            "Complete or close something that's been dragging",
            "Let go of an attachment, habit, or grudge"
        ],
        "spiritual_guidance": "Practice surrender without resignation. Endings create space for divine renewal.",
        "energy_color": "Soft Lavender",
        "affirmation": "I release with love. I trust that endings create space for beautiful new beginnings.",
        "caution": "Don't confuse letting go with giving up. Some things are worth fighting for; discern wisely."
    }
}

def get_daily_insight(power_number: int) -> dict:
    """
    Retrieve daily insight interpretation for given power number.
    
    Args:
        power_number: Integer 1-9 representing today's power number
        
    Returns:
        Dictionary containing title, energy, insight text, action focus,
        spiritual guidance, color, affirmation, and caution
        
    Raises:
        ValueError: If power_number is not between 1-9
    """
    if power_number < 1 or power_number > 9:
        raise ValueError(f"Power number must be 1-9, got {power_number}")
    
    return DAILY_INSIGHTS[power_number]


def get_brief_daily_insight(power_number: int) -> str:
    """
    Get a brief one-line insight for notifications or quick display.
    
    Args:
        power_number: Integer 1-9
        
    Returns:
        String with brief insight (2-3 sentences max)
    """
    insights_brief = {
        1: "Lead with confidence today. New opportunities emerge through decisive action.",
        2: "Practice patience and cooperation. Solutions come through listening and collaboration.",
        3: "Express yourself creatively. Your voice and ideas have power today.",
        4: "Build strong foundations. Organize, stabilize, and strengthen your systems.",
        5: "Embrace change and adventure. Flexibility opens unexpected doors.",
        6: "Nurture and serve with love. Balance giving with healthy self-care.",
        7: "Seek wisdom in solitude. Trust your intuition and inner guidance.",
        8: "Take strategic action. Your power to manifest is amplified today.",
        9: "Release what no longer serves. Forgiveness creates space for renewal."
    }
    
    if power_number < 1 or power_number > 9:
        raise ValueError(f"Power number must be 1-9, got {power_number}")
    
    return insights_brief[power_number]
