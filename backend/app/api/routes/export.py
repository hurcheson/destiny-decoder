"""Export routes for PDF and image generation."""

from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from ...services.pdf_export import PDFExportService

router = APIRouter(prefix="/export", tags=["export"])

pdf_service = PDFExportService()


class ExportRequest(BaseModel):
    """Request model for exporting readings."""
    full_name: str = Field(..., min_length=1, max_length=100)
    date_of_birth: str = Field(..., pattern=r'^\d{4}-\d{2}-\d{2}$')
    decode_data: dict = Field(..., description="Full decode response data")


@router.post("/pdf")
async def export_pdf(request: ExportRequest):
    """
    Generate and download a PDF report of the numerology reading.
    
    Returns:
        PDF file as downloadable attachment
    """
    try:
        # Generate PDF
        pdf_buffer = pdf_service.generate_full_reading_pdf(request.decode_data)
        
        # Create filename
        safe_name = request.full_name.replace(' ', '_')[:30]
        filename = f"destiny_reading_{safe_name}.pdf"
        
        return StreamingResponse(
            pdf_buffer,
            media_type="application/pdf",
            headers={
                "Content-Disposition": f"attachment; filename={filename}"
            }
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"PDF generation failed: {str(e)}")
