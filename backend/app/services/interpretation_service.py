from ..interpretations.life_seal import LIFE_SEAL_INTERPRETATIONS

def get_life_seal_interpretation(life_seal_number: int) -> dict:
    if not (1 <= life_seal_number <= 9):
        raise ValueError("Life seal number must be between 1 and 9")
    return LIFE_SEAL_INTERPRETATIONS[life_seal_number]
