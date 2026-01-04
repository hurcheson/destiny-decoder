from .reduction import reduce_to_single_digit

PLANET_MAPPING = {
    1: "SUN",
    2: "MOON",
    3: "JUPITER",
    4: "URANUS",
    5: "MERCURY",
    6: "VENUS",
    7: "NEPTUNE",
    8: "SATURN",
    9: "MARS"
}

def calculate_life_seal(day: int, month: int, year: int) -> dict:
    day_r = reduce_to_single_digit(day)
    month_r = reduce_to_single_digit(month)
    year_r = reduce_to_single_digit(year)
    
    life_seal_raw = day_r + month_r + year_r
    life_seal = reduce_to_single_digit(life_seal_raw)
    
    planet = PLANET_MAPPING[life_seal]
    
    return {
        "number": life_seal,
        "planet": planet
    }
