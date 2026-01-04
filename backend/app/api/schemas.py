from pydantic import BaseModel
from typing import Optional, List

class DestinyRequest(BaseModel):
    day_of_birth: int
    month_of_birth: int
    year_of_birth: int
    first_name: str
    other_names: Optional[str] = None
    full_name: Optional[str] = None
    current_year: Optional[int] = None
    age: Optional[int] = None
    partner_name: Optional[str] = None

class DestinyResponse(BaseModel):
    life_seal: int
    life_planet: str
    physical_name_number: int
    soul_number: int
    personality_number: int
    personal_year: int
    blessed_years: List[int]
    blessed_days: List[int]
    life_cycle_phase: str
    life_turning_points: List[int]
    compatibility: Optional[str] = None
