# Interpretations sourced from Excel V9.18, enhanced for user-friendliness
# Used for Life Cycles and Turning Points (same mapping, reused everywhere).

# Legacy text-only interpretations (kept for backward compatibility)
CYCLE_INTERPRETATIONS = {
    1: "Pioneer, Independent Leader, Traveller, Goals Achiever, Self Gratification, Inventor/Creative, Good Counsellor, Inspirational Leader, Achiever of Prosperity. Peoples' Perception: Arrogant, Proud, Stubborn.",
    2: "Diplomatic, Emotion and Intuitive Ability to Develop, Perfect Partner/Cooperator/Associate, Warm/Slow, Timid, Secretive, Domestic Person, Like to Help People, Thinker, Worried, Peaceful, Working Quietly, Heeding to Counsel, Know Publicly.",
    3: "Love/Affection, Creativity, Play, Jovial, Fun Loving, Artistic, Sports Persons, Likes Popularity, Lover of Marriage and Children, Careless, Talented, Fascinated, A lot of Opportunities, Be among the winning team, Makes Good Choices, Marked with Success.",
    4: "Stabilizer, Hardworking, Cold, Intellectual, Discipline, Lover of Restrictions, Sympathetic, Strategic, Extremely Resourceful, To finish and Complete a Test, Unique, Energetic, Initiator of Ideas, Have a lot of Good Ideas.",
    5: "Religious, Spiritual, Change, Freedom, Careless in Action, Good (Sales Person, Researcher, Communicator), Traveller with Financial Breakthrough Potential, Media Person, Risk Taker, Quick Tempered, Don't Listen. Helpers are outside your Family, Knowledgeable, Superficial.",
    6: "Material Supply, Education, Family, Marriage Life, Keeper, Harmonizer, Rhythmic, Domineering, Intellectual, Emotional, Community, Large Institution, Admirer, Dedicated with work/Family/People.",
    7: "Wisdom, Knowledge, Perfection, Details, Researcher, Life Full of Challenges, A Planner, Full of Ideas, Has Good Health.",
        8: "Blessed with Money, Dual Income Streams (2 Conduits), Extremely Busy, Good Health, Energetic, Endurance, Powerful, Discipline, Systemic, Makes things Easy and Better for people, Conservative, Grow with Money, Listener of Advice, Good Implementer.",
    9: "Finisher, Transitions, Challenging and Busier Life, Spiritual, Preparing Students for Exams, Fighter, Lover of Breaking Research, Hot Tempered, Sensitive to the Spirit, Strong Passion and Sexual Energy",
    0: None,
}

# Enhanced structured interpretations with user-friendly formatting
ENHANCED_CYCLE_INTERPRETATIONS = {
    1: {
        "title": "The Pioneer",
        "essence": "A time of independence, leadership, and new beginnings. You're forging your own path and setting the direction for your journey.",
        "strengths": [
            "Natural leadership and pioneering spirit",
            "Independent thinking and self-reliance",
            "Creative problem-solving and innovation",
            "Ability to inspire and counsel others",
            "Goal-oriented with strong achievement drive"
        ],
        "opportunities": [
            "Start new ventures or projects",
            "Take initiative in your career or life",
            "Travel and explore new horizons",
            "Build prosperity through original ideas"
        ],
        "challenges": [
            "May appear arrogant or overly proud to others",
            "Tendency toward stubbornness",
            "Learning to balance independence with collaboration"
        ],
        "guidance": "Embrace your leadership abilities while staying open to others' perspectives. Your pioneering energy is a gift—use it to create positive change."
    },
    2: {
        "title": "The Diplomat",
        "essence": "A period focused on partnerships, cooperation, and emotional development. Success comes through collaboration and helping others.",
        "strengths": [
            "Diplomatic and skilled at mediation",
            "Strong intuitive and emotional intelligence",
            "Perfect partner and cooperator",
            "Patient and thoughtful approach",
            "Natural ability to help and support others"
        ],
        "opportunities": [
            "Build meaningful partnerships",
            "Develop your intuitive abilities",
            "Work in peaceful, collaborative environments",
            "Gain recognition through quiet excellence"
        ],
        "challenges": [
            "Tendency toward timidity or secrecy",
            "May worry excessively",
            "Can be overly cautious or slow to act"
        ],
        "guidance": "Trust your intuition and emotional wisdom. Your ability to harmonize and cooperate is your greatest strength. Work quietly but confidently toward your goals."
    },
    3: {
        "title": "The Creative",
        "essence": "A joyful period of creativity, self-expression, and social connection. Life becomes playful, artistic, and full of opportunities.",
        "strengths": [
            "Creative and artistic expression",
            "Joyful, fun-loving personality",
            "Natural talent and fascination for life",
            "Social magnetism and popularity",
            "Ability to make winning choices"
        ],
        "opportunities": [
            "Express yourself creatively",
            "Enjoy sports, arts, and entertainment",
            "Build loving relationships and family",
            "Join winning teams and successful groups",
            "Embrace abundant opportunities"
        ],
        "challenges": [
            "Can be careless or scattered",
            "May prioritize fun over responsibility",
            "Risk of superficial connections"
        ],
        "guidance": "Channel your creative energy into meaningful projects. Your joy and talent attract success—use them wisely while maintaining focus on what truly matters."
    },
    4: {
        "title": "The Builder",
        "essence": "A time for creating solid foundations through hard work, discipline, and practical action. Build lasting structures in your life.",
        "strengths": [
            "Hardworking and disciplined",
            "Strategic thinking and planning",
            "Extremely resourceful problem-solver",
            "Energetic initiator of ideas",
            "Ability to complete and finish tasks"
        ],
        "opportunities": [
            "Build solid foundations for future success",
            "Complete important projects",
            "Implement practical systems and structures",
            "Use your intellectual abilities strategically"
        ],
        "challenges": [
            "May appear cold or overly serious",
            "Love of restrictions can limit flexibility",
            "Risk of overwork or rigidity"
        ],
        "guidance": "Your ability to build and systematize is invaluable. Balance your disciplined approach with warmth and flexibility. Complete what you start—your persistence pays off."
    },
    5: {
        "title": "The Explorer",
        "essence": "A dynamic period of change, freedom, and discovery. Embrace new experiences, travel, and personal transformation.",
        "strengths": [
            "Spiritual depth and religious connection",
            "Love of freedom and change",
            "Excellent communicator and researcher",
            "Sales and media abilities",
            "Knowledgeable and curious mind"
        ],
        "opportunities": [
            "Travel and explore new places",
            "Experience financial breakthroughs",
            "Excel in sales, research, or media",
            "Take calculated risks",
            "Seek help from outside your usual circle"
        ],
        "challenges": [
            "Can be careless in action",
            "Quick tempered and impatient",
            "May not listen to advice",
            "Risk of superficial knowledge"
        ],
        "guidance": "Your love of freedom and change is a gift. Channel your energy wisely, listen to guidance, and remember that not all change needs to be rushed. Your helpers often come from unexpected places."
    },
    6: {
        "title": "The Nurturer",
        "essence": "A phase centered on family, education, and service. Focus on creating harmony and supporting your community and loved ones.",
        "strengths": [
            "Natural provider and caretaker",
            "Educational and teaching abilities",
            "Harmonizer in relationships",
            "Strong intellectual and emotional balance",
            "Dedication to work, family, and community"
        ],
        "opportunities": [
            "Strengthen family bonds",
            "Pursue education or teach others",
            "Create material security",
            "Work with large institutions or community",
            "Marriage and partnership success"
        ],
        "challenges": [
            "Can be domineering or controlling",
            "Tendency to overextend yourself",
            "May neglect personal needs while caring for others"
        ],
        "guidance": "Your nurturing energy creates stability and harmony. Balance giving to others with self-care. Your dedication to family and community makes a lasting impact."
    },
    7: {
        "title": "The Seeker",
        "essence": "A contemplative period of inner wisdom, research, and personal refinement. Seek knowledge, perfection, and deeper understanding.",
        "strengths": [
            "Wisdom and deep knowledge",
            "Eye for perfection and detail",
            "Research and analytical abilities",
            "Strategic planning skills",
            "Good health and well-being",
            "Full of innovative ideas"
        ],
        "opportunities": [
            "Pursue deep study or research",
            "Perfect your skills and abilities",
            "Plan strategically for the future",
            "Develop spiritual wisdom",
            "Face and overcome challenges with insight"
        ],
        "challenges": [
            "Life may feel full of challenges",
            "Perfectionism can cause stress",
            "May become too isolated in study"
        ],
        "guidance": "Your pursuit of wisdom and perfection is noble. Remember that growth comes through challenges. Use your analytical mind to plan carefully, but don't let perfectionism paralyze progress."
    },
    8: {
        "title": "The Powerhouse",
        "essence": "An abundant period of material success, power, and dual opportunities. You're blessed with the energy to manage multiple income streams and major responsibilities.",
        "strengths": [
            "Financial abundance and material success",
            "Dual channels of opportunity (2 conduits means multiple income/project streams)",
            "Exceptional energy and endurance",
            "Excellent health and vitality",
            "Powerful, disciplined, and systematic",
            "Natural ability to help and improve systems",
            "Conservative and growth-oriented with money",
            "Strong listener and implementer of advice"
        ],
        "opportunities": [
            "Manage multiple income sources simultaneously",
            "Lead large projects or organizations",
            "Grow wealth through strategic investments",
            "Make things easier and better for others",
            "Partner with numbers 3 and 7 for maximum compatibility"
        ],
        "challenges": [
            "Extremely busy—risk of burnout despite high energy",
            "Balancing multiple responsibilities",
            "May become too conservative with resources"
        ],
        "guidance": "This is your power phase! You have the rare ability to handle two major streams of activity (the '2 conduits'). Use your exceptional energy wisely—you're built to accomplish big things while helping others succeed.",
        "special_note": "The '2 conduits' means you're naturally equipped to manage dual channels—whether that's two businesses, two major projects, or multiple income streams. This isn't about being scattered; it's about having the capacity for parallel success.",
        "compatibility_hint": "For intimate relationships: People with first names that reduce to 3 or 7 create the most harmonious partnerships with you (based on physical name number compatibility)."
    },
    9: {
        "title": "The Completer",
        "essence": "A transformative period of endings, transitions, and spiritual growth. Finish cycles, let go of the old, and prepare for new beginnings.",
        "strengths": [
            "Ability to finish and complete cycles",
            "Spiritual depth and sensitivity",
            "Fighter spirit and determination",
            "Research and breakthrough abilities",
            "Teaching and preparing others",
            "Strong life force and passion"
        ],
        "opportunities": [
            "Complete unfinished business",
            "Break through research barriers",
            "Prepare others for their journeys",
            "Embrace spiritual transformation",
            "Channel your passion productively"
        ],
        "challenges": [
            "Life may feel challenging and busy",
            "Hot tempered and highly sensitive",
            "Difficulty letting go of the past",
            "Managing intense emotional and sexual energy"
        ],
        "guidance": "This is a completion phase—release what no longer serves you. Your fighter spirit helps you finish strong. Trust your spiritual sensitivity, channel your passionate energy wisely, and know that endings always lead to new beginnings."
    },
    0: None,
}

# Glossary of numerology terms for user education
NUMEROLOGY_GLOSSARY = {
    "conduits": {
        "term": "Conduits",
        "definition": "Energy channels or pathways through which opportunities, resources, and abundance flow in your life.",
        "example": "'2 Conduits' means you have two streams—like managing dual careers, multiple income sources, or parallel major projects successfully."
    },
    "blessed_days": {
        "term": "Blessed Days",
        "definition": "Days when your energy aligns with universal vibrations, making them particularly favorable for important activities.",
        "example": "Days where your birth number matches the day's numerological value are your blessed days."
    },
    "life_seal": {
        "term": "Life Seal",
        "definition": "Your core numerological number derived from your complete birth date, representing your life's primary energy and purpose.",
        "example": "If you were born on 09/04/1998, your Life Seal calculation reveals your fundamental life path number."
    },
    "turning_point": {
        "term": "Turning Point",
        "definition": "Key ages where significant life transitions naturally occur, based on your numerological cycles.",
        "example": "Common turning points occur around ages 36, 45, 54, and 63."
    },
    "life_cycle": {
        "term": "Life Cycle",
        "definition": "Major phases of your life journey, each with distinct themes and lessons spanning multiple decades.",
        "example": "The three cycles typically cover ages 0-30 (Formative), 30-55 (Establishment), and 55+ (Harvest)."
    },
    "personal_year": {
        "term": "Personal Year",
        "definition": "The numerological theme for your current year, influencing the types of experiences and opportunities you'll encounter.",
        "example": "Your Personal Year changes annually and guides your focus for that 12-month period."
    },
    "physical_name_number": {
        "term": "Physical Name Number (Sex/Intimacy Number)",
        "definition": "Calculated from ALL letters in your first name only, used to determine romantic and intimate compatibility.",
        "example": "JOHN: J(1) + O(6) + H(8) + N(5) = 20 → reduces to 2. People with names reducing to 3 or 7 are compatible with 2s."
    },
    "soul_number": {
        "term": "Soul Number",
        "definition": "Calculated from only the VOWELS in your full name, representing your inner desires and spiritual nature.",
        "example": "In JOHN: O = 6, so Soul Number is 6. This reveals what you truly desire at a soul level."
    },
    "personality_number": {
        "term": "Personality Number",
        "definition": "Calculated from only the CONSONANTS in your full name, representing how others perceive you.",
        "example": "In JOHN: J(1) + H(8) + N(5) = 14 → reduces to 5. This is the energy you project to the world."
    },
    "compatibility": {
        "term": "Compatibility",
        "definition": "A measure of numerological harmony between two people, calculated from their Physical Name Numbers (first name only).",
        "example": "If person A's first name reduces to 8 and person B's to 3, they have 'Compatible' energy (difference of 5... wait, that's actually Challenging). Differences of 0 = Very Strong, 1-2 = Compatible, 3+ = Challenging."
    },
    "excel_reduce": {
        "term": "Reduction",
        "definition": "The process of reducing multi-digit numbers to single digits (1-9) to reveal their numerological meaning.",
        "example": "The number 25 reduces to 7 (2+5=7), revealing the energy of wisdom and analysis."
    }
}


def get_cycle_interpretation(number: int) -> str | None:
    """Retrieve legacy interpretation text for a cycle number (backward compatibility).
    
    Args:
        number: Integer 0-9 representing the cycle value.
    
    Returns:
        Interpretation text string, or None if number == 0 or not found.
    
    Notes:
        - This returns the original comma-separated text format
        - For enhanced structured data, use get_enhanced_cycle_interpretation()
    """
    return CYCLE_INTERPRETATIONS.get(number)

def get_enhanced_cycle_interpretation(number: int) -> dict | None:
    """Retrieve enhanced structured interpretation for a cycle number.
    
    Args:
        number: Integer 0-9 representing the cycle value.
    
    Returns:
        Dictionary with structured interpretation data including:
        - title: User-friendly name
        - essence: Brief overview
        - strengths: List of positive traits
        - opportunities: List of possibilities
        - challenges: List of potential difficulties
        - guidance: Practical advice
        - special_note (optional): Additional context
        
        Returns None if number == 0 or not found.
    """
    return ENHANCED_CYCLE_INTERPRETATIONS.get(number)

def get_glossary_term(term_key: str) -> dict | None:
    """Retrieve glossary definition for a numerology term.
    
    Args:
        term_key: Key for the term (e.g., 'conduits', 'blessed_days')
    
    Returns:
        Dictionary with term, definition, and example, or None if not found.
    """
    return NUMEROLOGY_GLOSSARY.get(term_key)

def format_interpretation_for_display(number: int, use_enhanced: bool = True) -> str:
    """Format interpretation in a readable way for display.
    
    Args:
        number: The cycle number (1-9)
        use_enhanced: If True, formats enhanced data; if False, returns legacy text
    
    Returns:
        Formatted string ready for display
    """
    if not use_enhanced:
        return get_cycle_interpretation(number) or ""
    
    enhanced = get_enhanced_cycle_interpretation(number)
    if not enhanced:
        return ""
    
    parts = [
        f"✨ {enhanced['essence']}",
        "",
        "💪 Key Strengths:",
        *[f"• {s}" for s in enhanced['strengths']],
        "",
        "🌟 Opportunities:",
        *[f"• {o}" for o in enhanced['opportunities']],
        "",
        "⚠️ Watch For:",
        *[f"• {c}" for c in enhanced['challenges']],
        "",
        f"🧭 Guidance: {enhanced['guidance']}"
    ]
    
    if 'special_note' in enhanced:
        parts.extend(["", f"💡 Note: {enhanced['special_note']}"])
    
    return "\n".join(parts)
