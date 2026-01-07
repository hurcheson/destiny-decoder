# Interpretations sourced from Excel V9.18 IF-lookup tables.
# Used for Life Cycles and Turning Points (same mapping, reused everywhere).
# Text is exact as extracted—no normalization or rephrasing.

CYCLE_INTERPRETATIONS = {
    1: "Poirneer, Leader (Alone),Independent,Traveller, Goals Achiever, Self Gratification, Inventor/Creative, Good Counsellor,Inspirational Leader, Achiever of Prosperity.) Peoples' Perception: Arrogant,Proud,Sturbon.",
    2: "Diplomatic,Emmotion and Intuitive Ability to Develop,Perfect Partner/Corperater/Associate,Warm/Slow,Timid, Secretive,Domestic Person, Like to Help People, Thinker, Worried, Peaceful,Working Quietly, Heeding to Counsel, Know Publicly.",
    3: "Love/Affection, Creativity,Play,Jovial, Fun Loving, Artistic, Sports Persons, Likes Popularity,lover of Marriage and Children, Careless, Talented,Fascinated, A lot of Opprtunities, Be among the winning team, Makes Good Choices, Marked with Success.",
    4: "Stabilizer, Hardworking,Cold, Intellectual, Discipline,Lover of Restrictions,Sympathetic,Startegic,Extremely Resourceful,To finish and Complete a Test,Unique,Energetic,Initiater of Ideas, Have a lot of Good Ideas.",
    5: "Religious, Spiritual,Change,Freedom, Careless in Action, Good (Sales Person, Researcher, Communicator) ,Traveller( Financial Break Through),Media Person,Rist Taker,Quick Tempered, Don't Listen.Helpers are outside your Family,Knowledgeable, Superfical.",
    6: "Matrial Supply, Education,Family, Marriage Life, Keeper,Harmonizer,Rhythmic,Dominioring,Intellectual,Emotional,Community, Large Institution,Admirer, Dedicated with work/Family/People.",
    7: "Wisdom, Knowledge, Perfection, Details,Researcher,Life Full of Challenges, A Planner, Full of Ideas, Has Good Health.",
    8: "Blessed with Money, 2 Conduits,Extremely Busy,Good Health, Energetic, Endurance,Powerful, Discipline,Systemic, Makes things Easy and Better for people, Conservative,Grow with Money,listener of Advice,Good Implementer.(Always choose 3&7).",
    9: "Finisher, Tarnsitions,Challenging and Busier Life, Spiritual,Preparing Students for Exams, Fighter, lover of Breaking Research, Hot Tempered, Sensitive to the Spirit,Lover of Sex(Sexual Energy)",
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
