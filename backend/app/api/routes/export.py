"""Export routes for PDF and image generation."""

from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field
import logging

from ...services.pdf_export import PDFExportService

router = APIRouter(prefix="/export", tags=["export"])
pdf_service = PDFExportService()
logger = logging.getLogger(__name__)


class ExportRequest(BaseModel):
    """Request model for exporting readings."""
    full_name: str = Field(..., min_length=1, max_length=100)
    date_of_birth: str = Field(..., pattern=r'^\d{4}-\d{2}-\d{2}$')
    decode_data: dict = Field(..., description="Full decode response data")


@router.post("/pdf")
async def export_pdf(request: ExportRequest):
    """
    Generate and download a PDF report of the numerology reading.
    
    Request body:
        full_name: User's full name
        date_of_birth: YYYY-MM-DD format
        decode_data: Full response from /decode/full endpoint
    
    Returns:
        PDF file as downloadable attachment
    """
    try:
        logger.info(f"PDF export request for {request.full_name}")
        
        # Validate decode_data structure
        if not request.decode_data or 'input' not in request.decode_data:
            raise ValueError("Invalid decode_data structure: missing 'input' key")
        
        # Generate PDF
        pdf_buffer = pdf_service.generate_full_reading_pdf(request.decode_data)
        
        # Create filename
        safe_name = request.full_name.replace(' ', '_')[:30]
        filename = f"destiny_reading_{safe_name}.pdf"
        
        logger.info(f"PDF generated successfully for {request.full_name}")
        
        return StreamingResponse(
            pdf_buffer,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except ValueError as ve:
        logger.error(f"Validation error: {str(ve)}")
        raise HTTPException(status_code=400, detail=f"Invalid request data: {str(ve)}")
    except Exception as e:
        logger.error(f"PDF generation failed: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"PDF generation failed: {str(e)}")
