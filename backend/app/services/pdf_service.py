"""
PDF export service for Destiny readings.
Generates clean, readable PDF documents from report data.
"""

from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle, LongTable
from reportlab.lib import colors


def generate_report_pdf(full_name: str, date_of_birth: str, report: dict) -> BytesIO:
    """
    Generate a PDF document from a report object.
    
    Args:
        full_name: User's full name
        date_of_birth: Birth date (YYYY-MM-DD format)
        report: Report dict with sections (overview, life_cycles, turning_points, closing_summary)
    
    Returns:
        BytesIO buffer containing PDF data
    """
    
    # Create in-memory PDF document
    pdf_buffer = BytesIO()
    doc = SimpleDocTemplate(
        pdf_buffer,
        pagesize=letter,
        rightMargin=0.75 * inch,
        leftMargin=0.75 * inch,
        topMargin=0.75 * inch,
        bottomMargin=0.75 * inch,
    )
    
    # Define styles
    styles = getSampleStyleSheet()
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=24,
        textColor=colors.HexColor('#2C3E50'),
        spaceAfter=6,
        alignment=0
    )
    
    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor('#34495E'),
        spaceAfter=12,
        spaceBefore=12,
        alignment=0
    )
    
    subtitle_style = ParagraphStyle(
        'Subtitle',
        parent=styles['Normal'],
        fontSize=11,
        textColor=colors.HexColor('#7F8C8D'),
        spaceAfter=6,
        italic=True
    )
    
    body_style = ParagraphStyle(
        'Body',
        parent=styles['Normal'],
        fontSize=10,
        textColor=colors.HexColor('#2C3E50'),
        spaceAfter=10,
        leading=14
    )
    
    label_style = ParagraphStyle(
        'Label',
        parent=styles['Normal'],
        fontSize=10,
        textColor=colors.HexColor('#34495E'),
        bold=True,
        spaceAfter=4
    )
    
    # Build document content
    story = []
    
    # Title page
    story.append(Spacer(1, 0.3 * inch))
    story.append(Paragraph("Destiny Decoder Report", title_style))
    story.append(Spacer(1, 0.1 * inch))
    story.append(Paragraph(f"<b>Name:</b> {full_name}", body_style))
    story.append(Paragraph(f"<b>Birth Date:</b> {date_of_birth}", body_style))
    story.append(Spacer(1, 0.4 * inch))
    
    # SECTION 1: Overview
    if 'overview' in report:
        overview = report['overview']
        story.append(Paragraph(overview.get('title', 'Overview'), section_header_style))
        story.append(Paragraph(overview.get('subtitle', ''), subtitle_style))
        story.append(Paragraph(overview.get('description', ''), body_style))
        story.append(Spacer(1, 0.15 * inch))
        
        # Core numbers table
        if 'core_numbers' in overview:
            core_nums = overview['core_numbers']
            table_data = [[
                Paragraph('Number', label_style),
                Paragraph('Value', label_style),
                Paragraph('Meaning', label_style),
            ]]
            
            if 'life_seal' in core_nums:
                ls = core_nums['life_seal']
                table_data.append([
                    Paragraph('Life Seal', label_style),
                    Paragraph(f"{ls['number']} ({ls['planet']})", body_style),
                    Paragraph(ls.get('description', ''), body_style),
                ])
            
            if 'soul_number' in core_nums:
                sn = core_nums['soul_number']
                table_data.append([
                    Paragraph('Soul Number', label_style),
                    Paragraph(str(sn.get('number', '')), body_style),
                    Paragraph(sn.get('description', ''), body_style),
                ])
            
            if 'personality_number' in core_nums:
                pn = core_nums['personality_number']
                table_data.append([
                    Paragraph('Personality Number', label_style),
                    Paragraph(str(pn.get('number', '')), body_style),
                    Paragraph(pn.get('description', ''), body_style),
                ])
            
            if 'personal_year' in core_nums:
                py = core_nums['personal_year']
                table_data.append([
                    Paragraph('Personal Year', label_style),
                    Paragraph(str(py.get('number', '')), body_style),
                    Paragraph(py.get('description', ''), body_style),
                ])
            # Use LongTable to allow multi-page splitting and repeat header row
            table = LongTable(
                table_data,
                colWidths=[doc.width * 0.25, doc.width * 0.20, doc.width * 0.55],
                repeatRows=1,
                hAlign='LEFT',
            )
            table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#34495E')),
                ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
                ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
                ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('FONTSIZE', (0, 0), (-1, 0), 10),
                ('FONTSIZE', (0, 1), (-1, -1), 9),
                ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
                ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor('#ECF0F1')),
                ('GRID', (0, 0), (-1, -1), 1, colors.HexColor('#BDC3C7')),
                ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor('#ECF0F1'), colors.white]),
                ('LINEBELOW', (0, 0), (-1, 0), 1, colors.HexColor('#BDC3C7')),
            ]))
            story.append(table)
        
        story.append(PageBreak())
    
    # SECTION 2: Life Cycles
    if 'life_cycles' in report:
        life_cycles = report['life_cycles']
        story.append(Paragraph(life_cycles.get('title', 'Life Cycles'), section_header_style))
        story.append(Paragraph(life_cycles.get('subtitle', ''), subtitle_style))
        story.append(Paragraph(life_cycles.get('description', ''), body_style))
        story.append(Spacer(1, 0.15 * inch))
        
        # Life cycles phases
        if 'phases' in life_cycles:
            for idx, phase in enumerate(life_cycles['phases'], 1):
                age_range = phase.get('age_range', '')
                cycle_num = phase.get('cycle_number', '')
                interpretation = phase.get('interpretation', '')
                narrative = phase.get('narrative', '')
                
                story.append(Paragraph(f"<b>Phase {idx}: Ages {age_range} (Cycle {cycle_num})</b>", label_style))
                story.append(Paragraph(interpretation, body_style))
                story.append(Paragraph(narrative, body_style))
                story.append(Spacer(1, 0.1 * inch))
        
        story.append(PageBreak())
    
    # SECTION 3: Turning Points
    if 'turning_points' in report:
        turning_points = report['turning_points']
        story.append(Paragraph(turning_points.get('title', 'Turning Points'), section_header_style))
        story.append(Paragraph(turning_points.get('subtitle', ''), subtitle_style))
        story.append(Paragraph(turning_points.get('description', ''), body_style))
        story.append(Spacer(1, 0.15 * inch))
        
        # Turning points timeline
        if 'points' in turning_points:
            for point in turning_points['points']:
                age = point.get('age', '')
                tp_num = point.get('turning_point_number', '')
                interpretation = point.get('interpretation', '')
                narrative = point.get('narrative', '')
                
                story.append(Paragraph(f"<b>Age {age} - Turning Point {tp_num}</b>", label_style))
                story.append(Paragraph(interpretation, body_style))
                story.append(Paragraph(narrative, body_style))
                story.append(Spacer(1, 0.1 * inch))
        
        story.append(PageBreak())
    
    # SECTION 4: Closing Summary
    if 'closing_summary' in report:
        closing = report['closing_summary']
        story.append(Paragraph(closing.get('title', 'Closing Summary'), section_header_style))
        story.append(Paragraph(closing.get('subtitle', ''), subtitle_style))
        story.append(Paragraph(closing.get('description', ''), body_style))
        story.append(Spacer(1, 0.15 * inch))
        
        # Overall narrative
        if 'overview' in closing:
            story.append(Paragraph("<b>Your Life Journey</b>", label_style))
            story.append(Paragraph(closing['overview'], body_style))
        
        story.append(Spacer(1, 0.15 * inch))
        
        # Life phase summary
        if 'life_phase_summary' in closing:
            story.append(Paragraph("<b>Phase Summary</b>", label_style))
            for phase_summary in closing['life_phase_summary']:
                age_range = phase_summary.get('age_range', '')
                text = phase_summary.get('text', '')
                story.append(Paragraph(f"• <b>Ages {age_range}:</b> {text}", body_style))
        
        story.append(Spacer(1, 0.3 * inch))
        story.append(Paragraph("---", body_style))
        story.append(Spacer(1, 0.1 * inch))
        story.append(Paragraph("Generated by Destiny Decoder", subtitle_style))
    
    # Build the PDF
    doc.build(story)
    pdf_buffer.seek(0)
    
    return pdf_buffer


def _truncate(text: str, max_length: int) -> str:
    """Truncate text to max length."""
    if len(text) <= max_length:
        return text
    return text[:max_length - 3] + "..."
