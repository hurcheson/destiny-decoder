from ...services.interpretation_service import (
    get_life_seal_interpretation,
    get_soul_number_interpretation,
    get_personality_number_interpretation,
    get_personal_year_interpretation,
    get_pinnacle_interpretation,
)
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from ..schemas import DestinyRequest, DestinyResponse
from ...services.destiny_service import calculate_destiny
from ...services.pdf_service import generate_report_pdf

router = APIRouter()

@router.post("/calculate-destiny", response_model=DestinyResponse)
async def post_calculate_destiny(request: DestinyRequest) -> DestinyResponse:
    result = calculate_destiny(request.dict())
    return DestinyResponse(**result)

@router.post("/decode/full")
async def post_decode_full(request: DestinyRequest):
    input_data = request.dict()
    core = calculate_destiny(input_data)
    life_seal_number = core["life_seal"]
    life_planet = core["life_planet"]
    soul_number = core["soul_number"]
    personality_number = core["personality_number"]
    personal_year = core["personal_year"]
    pinnacles = core.get("pinnacles", [])
    
    try:
        life_seal_interpretation = get_life_seal_interpretation(life_seal_number)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid life seal number for interpretation")
    
    try:
        soul_number_interpretation = get_soul_number_interpretation(soul_number)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid soul number for interpretation")
    
    try:
        personality_number_interpretation = get_personality_number_interpretation(personality_number)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid personality number for interpretation")

    try:
        personal_year_interpretation = get_personal_year_interpretation(personal_year)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid personal year for interpretation")

    pinnacle_interpretations = []
    for pinnacle in pinnacles:
        try:
            pinnacle_interpretations.append({
                "number": pinnacle,
                "content": get_pinnacle_interpretation(pinnacle)
            })
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid pinnacle number for interpretation")
    
    # Format date_of_birth for Flutter app (expects YYYY-MM-DD string)
    date_of_birth = f"{input_data['year_of_birth']}-{input_data['month_of_birth']:02d}-{input_data['day_of_birth']:02d}"
    
    return {
        "input": {
            "full_name": input_data.get("full_name") or f"{input_data['first_name']} {input_data.get('other_names', '')}".strip(),
            "date_of_birth": date_of_birth,
        },
        "core": core,
        "interpretations": {
            "life_seal": {
                "number": life_seal_number,
                "planet": life_planet,
                "content": life_seal_interpretation
            },
            "soul_number": {
                "number": soul_number,
                "content": soul_number_interpretation
            },
            "personality_number": {
                "number": personality_number,
                "content": personality_number_interpretation
            },
            "personal_year": {
                "number": personal_year,
                "planet": "YEAR",
                "content": personal_year_interpretation
            },
            "pinnacles": pinnacle_interpretations,
        }
    }

@router.post("/export/report/pdf")
async def post_export_report_pdf(request: DestinyRequest):
    """
    Generate and export a PDF report for a destiny reading.
    
    Request body contains the same fields as /decode/full.
    Returns PDF file as a downloadable attachment.
    """
    input_data = request.dict()
    
    # Calculate full destiny reading
    core = calculate_destiny(input_data)
    
    # Format metadata
    full_name = input_data.get("full_name") or f"{input_data['first_name']} {input_data.get('other_names', '')}".strip()
    date_of_birth = f"{input_data['year_of_birth']}-{input_data['month_of_birth']:02d}-{input_data['day_of_birth']:02d}"
    
    # Generate PDF from report
    pdf_buffer = generate_report_pdf(full_name, date_of_birth, core["report"])
    
    # Return as downloadable file
    return StreamingResponse(
        iter([pdf_buffer.getvalue()]),
        media_type="application/pdf",
        headers={"Content-Disposition": f"attachment; filename=destiny-report-{full_name.replace(' ', '-')}.pdf"}
    )