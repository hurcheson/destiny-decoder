from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional
from ...services.destiny_service import calculate_destiny
from ...services.interpretation_service import (
    get_life_seal_interpretation,
    get_soul_number_interpretation,
    get_personality_number_interpretation,
    get_personal_year_interpretation,
)
from ...services.compatibility_pdf_service import generate_compatibility_pdf
from ...core.compatibility import evaluate_compatibility

router = APIRouter()


class PersonInput(BaseModel):
    full_name: str
    year_of_birth: int
    month_of_birth: int
    day_of_birth: int


class CompatibilityRequest(BaseModel):
    person_a: PersonInput
    person_b: PersonInput


@router.post("/decode/compatibility")
async def post_decode_compatibility(request: CompatibilityRequest):
    """
    Compare two people's numerology for compatibility analysis.
    Returns both full readings plus compatibility scores.
    """
    
    # Calculate both readings - transform data to match calculate_destiny expectations
    person_a_input = request.person_a.dict()
    person_b_input = request.person_b.dict()
    
    # Transform to match calculate_destiny format (needs first_name not full_name)
    person_a_data = {
        'first_name': person_a_input['full_name'].split()[0] if person_a_input['full_name'] else '',
        'other_names': ' '.join(person_a_input['full_name'].split()[1:]) if len(person_a_input['full_name'].split()) > 1 else '',
        'year_of_birth': person_a_input['year_of_birth'],
        'month_of_birth': person_a_input['month_of_birth'],
        'day_of_birth': person_a_input['day_of_birth'],
    }
    
    person_b_data = {
        'first_name': person_b_input['full_name'].split()[0] if person_b_input['full_name'] else '',
        'other_names': ' '.join(person_b_input['full_name'].split()[1:]) if len(person_b_input['full_name'].split()) > 1 else '',
        'year_of_birth': person_b_input['year_of_birth'],
        'month_of_birth': person_b_input['month_of_birth'],
        'day_of_birth': person_b_input['day_of_birth'],
    }
    
    core_a = calculate_destiny(person_a_data)
    core_b = calculate_destiny(person_b_data)
    
    # Get interpretations for person A
    life_seal_a = get_life_seal_interpretation(core_a["life_seal"])
    soul_a = get_soul_number_interpretation(core_a["soul_number"])
    personality_a = get_personality_number_interpretation(core_a["personality_number"])
    personal_year_a = get_personal_year_interpretation(core_a["personal_year"])
    
    # Get interpretations for person B
    life_seal_b = get_life_seal_interpretation(core_b["life_seal"])
    soul_b = get_soul_number_interpretation(core_b["soul_number"])
    personality_b = get_personality_number_interpretation(core_b["personality_number"])
    personal_year_b = get_personal_year_interpretation(core_b["personal_year"])
    
    # Calculate compatibility scores
    life_seal_compat = evaluate_compatibility(core_a["life_seal"], core_b["life_seal"])
    soul_compat = evaluate_compatibility(core_a["soul_number"], core_b["soul_number"])
    personality_compat = evaluate_compatibility(core_a["personality_number"], core_b["personality_number"])
    
    # Overall compatibility (weighted average logic)
    compat_scores = {
        "Very Strong": 3,
        "Compatible": 2,
        "Challenging": 1
    }
    
    total_score = (
        compat_scores[life_seal_compat] * 2 +  # Life seal weighted 2x
        compat_scores[soul_compat] +
        compat_scores[personality_compat]
    )
    max_score = 12  # (3*2) + 3 + 3
    
    if total_score >= 10:
        overall = "Highly Compatible"
    elif total_score >= 7:
        overall = "Compatible"
    elif total_score >= 5:
        overall = "Moderately Compatible"
    else:
        overall = "Challenging"
    
    # Format dates from original input
    date_a = f"{person_a_input['year_of_birth']}-{person_a_input['month_of_birth']:02d}-{person_a_input['day_of_birth']:02d}"
    date_b = f"{person_b_input['year_of_birth']}-{person_b_input['month_of_birth']:02d}-{person_b_input['day_of_birth']:02d}"
    
    return {
        "person_a": {
            "input": {
                "full_name": person_a_input["full_name"],
                "date_of_birth": date_a,
            },
            "core": core_a,
            "interpretations": {
                "life_seal": {
                    "number": core_a["life_seal"],
                    "planet": core_a["life_planet"],
                    "content": life_seal_a
                },
                "soul_number": {
                    "number": core_a["soul_number"],
                    "content": soul_a
                },
                "personality_number": {
                    "number": core_a["personality_number"],
                    "content": personality_a
                },
                "personal_year": {
                    "number": core_a["personal_year"],
                    "planet": "YEAR",
                    "content": personal_year_a
                },
            }
        },
        "person_b": {
            "input": {
                "full_name": person_b_input["full_name"],
                "date_of_birth": date_b,
            },
            "core": core_b,
            "interpretations": {
                "life_seal": {
                    "number": core_b["life_seal"],
                    "planet": core_b["life_planet"],
                    "content": life_seal_b
                },
                "soul_number": {
                    "number": core_b["soul_number"],
                    "content": soul_b
                },
                "personality_number": {
                    "number": core_b["personality_number"],
                    "content": personality_b
                },
                "personal_year": {
                    "number": core_b["personal_year"],
                    "planet": "YEAR",
                    "content": personal_year_b
                },
            }
        },
        "compatibility": {
            "overall": overall,
            "life_seal": life_seal_compat,
            "soul_number": soul_compat,
            "personality_number": personality_compat,
            "score": total_score,
            "max_score": max_score,
        }
    }


@router.post("/export/compatibility/pdf")
async def export_compatibility_pdf(request: CompatibilityRequest):
    """
    Generate and export a PDF report for compatibility analysis.
    Returns PDF file as a downloadable attachment.
    """
    
    # Reuse the compatibility calculation logic
    person_a_input = request.person_a.dict()
    person_b_input = request.person_b.dict()
    
    person_a_data = {
        'first_name': person_a_input['full_name'].split()[0] if person_a_input['full_name'] else '',
        'other_names': ' '.join(person_a_input['full_name'].split()[1:]) if len(person_a_input['full_name'].split()) > 1 else '',
        'year_of_birth': person_a_input['year_of_birth'],
        'month_of_birth': person_a_input['month_of_birth'],
        'day_of_birth': person_a_input['day_of_birth'],
    }
    
    person_b_data = {
        'first_name': person_b_input['full_name'].split()[0] if person_b_input['full_name'] else '',
        'other_names': ' '.join(person_b_input['full_name'].split()[1:]) if len(person_b_input['full_name'].split()) > 1 else '',
        'year_of_birth': person_b_input['year_of_birth'],
        'month_of_birth': person_b_input['month_of_birth'],
        'day_of_birth': person_b_input['day_of_birth'],
    }
    
    core_a = calculate_destiny(person_a_data)
    core_b = calculate_destiny(person_b_data)
    
    # Calculate compatibility
    life_seal_compat = evaluate_compatibility(core_a["life_seal"], core_b["life_seal"])
    soul_compat = evaluate_compatibility(core_a["soul_number"], core_b["soul_number"])
    personality_compat = evaluate_compatibility(core_a["personality_number"], core_b["personality_number"])
    
    compat_scores = {"Very Strong": 3, "Compatible": 2, "Challenging": 1}
    total_score = (
        compat_scores[life_seal_compat] * 2 +
        compat_scores[soul_compat] +
        compat_scores[personality_compat]
    )
    max_score = 12
    
    if total_score >= 10:
        overall = "Highly Compatible"
    elif total_score >= 7:
        overall = "Compatible"
    elif total_score >= 5:
        overall = "Moderately Compatible"
    else:
        overall = "Challenging"
    
    # Format data for PDF
    date_a = f"{person_a_input['year_of_birth']}-{person_a_input['month_of_birth']:02d}-{person_a_input['day_of_birth']:02d}"
    date_b = f"{person_b_input['year_of_birth']}-{person_b_input['month_of_birth']:02d}-{person_b_input['day_of_birth']:02d}"
    
    person_a_pdf = {
        'input': {
            'full_name': person_a_input['full_name'],
            'date_of_birth': date_a,
        },
        'core': core_a,
    }
    
    person_b_pdf = {
        'input': {
            'full_name': person_b_input['full_name'],
            'date_of_birth': date_b,
        },
        'core': core_b,
    }
    
    compatibility_pdf = {
        'overall': overall,
        'life_seal': life_seal_compat,
        'soul_number': soul_compat,
        'personality_number': personality_compat,
        'score': total_score,
        'max_score': max_score,
    }
    
    # Generate PDF
    pdf_buffer = generate_compatibility_pdf(person_a_pdf, person_b_pdf, compatibility_pdf)
    
    filename = f"compatibility-{person_a_input['full_name'].replace(' ', '-')}-{person_b_input['full_name'].replace(' ', '-')}.pdf"
    
    return StreamingResponse(
        pdf_buffer,
        media_type='application/pdf',
        headers={
            'Content-Disposition': f'attachment; filename="{filename}"'
        }
    )
