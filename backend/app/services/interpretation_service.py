from ..interpretations.life_seal import LIFE_SEAL_INTERPRETATIONS
from ..interpretations.soul_number import SOUL_NUMBER_INTERPRETATIONS
from ..interpretations.personality_number import PERSONALITY_NUMBER_INTERPRETATIONS
from ..interpretations.personal_year import PERSONAL_YEAR_INTERPRETATIONS
from ..interpretations.pinnacles import PINNACLE_INTERPRETATIONS

def get_life_seal_interpretation(life_seal_number: int) -> dict:
    if not (1 <= life_seal_number <= 9):
        raise ValueError("Life seal number must be between 1 and 9")
    return LIFE_SEAL_INTERPRETATIONS[life_seal_number]

def get_soul_number_interpretation(soul_number: int) -> dict:
    if not (1 <= soul_number <= 9):
        raise ValueError("Soul number must be between 1 and 9")
    return SOUL_NUMBER_INTERPRETATIONS[soul_number]

def get_personality_number_interpretation(personality_number: int) -> dict:
    if not (1 <= personality_number <= 9):
        raise ValueError("Personality number must be between 1 and 9")
    return PERSONALITY_NUMBER_INTERPRETATIONS[personality_number]

def get_personal_year_interpretation(personal_year: int) -> dict:
    if not (1 <= personal_year <= 9):
        raise ValueError("Personal year must be between 1 and 9")
    return PERSONAL_YEAR_INTERPRETATIONS[personal_year]

def get_personal_year_interpretation(personal_year: int) -> dict:
    if not (1 <= personal_year <= 9):
        raise ValueError("Personal year must be between 1 and 9")
    return PERSONAL_YEAR_INTERPRETATIONS[personal_year]

def get_pinnacle_interpretation(pinnacle_number: int) -> dict:
    if not (1 <= pinnacle_number <= 9):
        raise ValueError("Pinnacle number must be between 1 and 9")
    return PINNACLE_INTERPRETATIONS[pinnacle_number]