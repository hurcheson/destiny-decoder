from fastapi import APIRouter, HTTPException
from ...services.interpretation_service import get_life_seal_interpretation
from ...interpretations.cycle_interpretations import (
    get_enhanced_cycle_interpretation,
    get_glossary_term,
    NUMEROLOGY_GLOSSARY
)

router = APIRouter(prefix="/interpretations", tags=["interpretations"])

@router.get("/life-seal/{life_seal_number}")
async def get_life_seal(life_seal_number: int):
    try:
        return get_life_seal_interpretation(life_seal_number)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid life seal number")

@router.get("/cycle/{cycle_number}")
async def get_cycle_enhanced(cycle_number: int):
    """Get enhanced structured interpretation for a cycle/turning point number."""
    if not 1 <= cycle_number <= 9:
        raise HTTPException(status_code=400, detail="Cycle number must be between 1 and 9")
    
    enhanced = get_enhanced_cycle_interpretation(cycle_number)
    if not enhanced:
        raise HTTPException(status_code=404, detail="Interpretation not found")
    
    return enhanced

@router.get("/glossary/{term}")
async def get_glossary(term: str):
    """Get definition for a numerology term."""
    glossary_item = get_glossary_term(term.lower())
    if not glossary_item:
        raise HTTPException(status_code=404, detail=f"Term '{term}' not found in glossary")
    
    return glossary_item

@router.get("/glossary")
async def get_all_glossary():
    """Get all glossary terms."""
    return NUMEROLOGY_GLOSSARY

