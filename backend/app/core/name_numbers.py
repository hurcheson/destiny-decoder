from .reduction import reduce_to_single_digit

LETTER_MAP = {
    'A': 1, 'J': 1, 'S': 1,
    'B': 2, 'K': 2, 'T': 2,
    'C': 3, 'L': 3, 'U': 3,
    'D': 4, 'M': 4, 'V': 4,
    'E': 5, 'N': 5, 'W': 5,
    'F': 6, 'O': 6, 'X': 6,
    'G': 7, 'P': 7, 'Y': 7,
    'H': 8, 'Q': 8, 'Z': 8,
    'I': 9, 'R': 9
}

VOWELS = 'AEIOU'

def calculate_physical_name_number(name: str) -> int:
    clean_name = ''.join(c for c in name.upper() if c.isalpha())
    total = sum(LETTER_MAP.get(c, 0) for c in clean_name)
    return reduce_to_single_digit(total)

def calculate_soul_number(name: str) -> int:
    clean_name = ''.join(c for c in name.upper() if c.isalpha())
    total = sum(LETTER_MAP.get(c, 0) for c in clean_name if c in VOWELS)
    return reduce_to_single_digit(total)

def calculate_personality_number(name: str) -> int:
    clean_name = ''.join(c for c in name.upper() if c.isalpha())
    total = sum(LETTER_MAP.get(c, 0) for c in clean_name if c not in VOWELS)
    return reduce_to_single_digit(total)

def get_name_matrix_values(name: str) -> list[int]:
    """Extract per-letter reduced values from name (Excel matrix equivalent)."""
    clean_name = ''.join(c for c in name.upper() if c.isalpha())
    return [LETTER_MAP.get(c, 0) for c in clean_name]
