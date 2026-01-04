from fastapi import APIRouter, HTTPException
from ...services.interpretation_service import get_life_seal_interpretation

router = APIRouter(prefix="/interpretations", tags=["interpretations"])

@router.get("/life-seal/{life_seal_number}")
async def get_life_seal(life_seal_number: int):
    try:
        return get_life_seal_interpretation(life_seal_number)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid life seal number")
