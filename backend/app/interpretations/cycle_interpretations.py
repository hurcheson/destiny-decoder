# Interpretations sourced from Excel V9.18 IF-lookup tables.
# Used for Life Cycles and Turning Points (same mapping, reused everywhere).
# Text is exact as extracted—no normalization or rephrasing.

CYCLE_INTERPRETATIONS = {
    1: "Pioneer, Leader (Alone), Independent, Traveller, Goals Achiever, Self Gratification, Inventor/Creative, Good Counsellor, Inspirational Leader, Achiever of Prosperity. Peoples' Perception: Arrogant, Proud, Stubborn.",
    2: "Diplomatic, Emotion and Intuitive Ability to Develop, Perfect Partner/Cooperator/Associate, Warm/Slow, Timid, Secretive, Domestic Person, Like to Help People, Thinker, Worried, Peaceful, Working Quietly, Heeding to Counsel, Know Publicly.",
    3: "Love/Affection, Creativity, Play, Jovial, Fun Loving, Artistic, Sports Persons, Likes Popularity, Lover of Marriage and Children, Careless, Talented, Fascinated, A lot of Opportunities, Be among the winning team, Makes Good Choices, Marked with Success.",
    4: "Stabilizer, Hardworking, Cold, Intellectual, Discipline, Lover of Restrictions, Sympathetic, Strategic, Extremely Resourceful, To finish and Complete a Test, Unique, Energetic, Initiator of Ideas, Have a lot of Good Ideas.",
    5: "Religious, Spiritual, Change, Freedom, Careless in Action, Good (Sales Person, Researcher, Communicator), Traveller (Financial Break Through), Media Person, Risk Taker, Quick Tempered, Don't Listen. Helpers are outside your Family, Knowledgeable, Superficial.",
    6: "Material Supply, Education, Family, Marriage Life, Keeper, Harmonizer, Rhythmic, Domineering, Intellectual, Emotional, Community, Large Institution, Admirer, Dedicated with work/Family/People.",
    7: "Wisdom, Knowledge, Perfection, Details, Researcher, Life Full of Challenges, A Planner, Full of Ideas, Has Good Health.",
    8: "Blessed with Money, 2 Conduits, Extremely Busy, Good Health, Energetic, Endurance, Powerful, Discipline, Systemic, Makes things Easy and Better for people, Conservative, Grow with Money, Listener of Advice, Good Implementer. (Always choose 3&7).",
    9: "Finisher, Transitions, Challenging and Busier Life, Spiritual, Preparing Students for Exams, Fighter, Lover of Breaking Research, Hot Tempered, Sensitive to the Spirit, Lover of Sex (Sexual Energy)",
    0: None,
}

def get_cycle_interpretation(number: int) -> str | None:
    """Retrieve interpretation text for a cycle number (Life Cycle or Turning Point).
    
    Args:
        number: Integer 0-9 representing the cycle value.
    
    Returns:
        Interpretation text string, or None if number == 0 or not found.
    
    Notes:
        - This mapping is reused for Life Cycles and Turning Points.
        - Text is sourced directly from Excel V9.18 and is exact as provided.
        - Numbers should be final (already reduced); no computation here.
    """
    return CYCLE_INTERPRETATIONS.get(number)
