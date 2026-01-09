"""
PDF export service for Compatibility analysis.
Generates comparison reports showing two people's numerological compatibility.
"""

from io import BytesIO
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle
from reportlab.lib import colors


def generate_compatibility_pdf(person_a: dict, person_b: dict, compatibility: dict) -> BytesIO:
    """
    Generate a PDF document for compatibility analysis.
    
    Args:
        person_a: Person A's reading data
        person_b: Person B's reading data
        compatibility: Compatibility scores and analysis
    
    Returns:
        BytesIO buffer containing PDF data
    """
    
    pdf_buffer = BytesIO()
    doc = SimpleDocTemplate(
        pdf_buffer,
        pagesize=letter,
        rightMargin=0.75 * inch,
        leftMargin=0.75 * inch,
        topMargin=0.75 * inch,
        bottomMargin=0.75 * inch,
    )
    
    # Define color palette - Professional compatibility theme
    PRIMARY_COLOR = '#8B4789'      # Rich purple (Compatibility/Hearts theme)
    SECONDARY_COLOR = '#D4AF37'    # Gold accent
    DARK_TEXT = '#1A1A1A'          # Near black for readability
    LIGHT_TEXT = '#FFFFFF'         # White for contrast
    BORDER_COLOR = '#C89EC9'       # Lighter purple for borders
    HEADER_BG = '#8B4789'          # Rich purple background
    SECTION_BG = '#FAF6FD'         # Very light purple background
    TABLE_HEADER_BG = '#8B4789'    # Rich purple for table headers
    TABLE_HEADER_TEXT = '#FFFFFF'  # White text on headers
    TABLE_ALT_ROW = '#FAF6FD'      # Very light purple alternate rows
    TABLE_BORDER = '#D4B5DC'       # Muted purple borders
    
    styles = getSampleStyleSheet()
    
    # Premium title style
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Heading1'],
        fontSize=28,
        textColor=colors.HexColor(PRIMARY_COLOR),
        spaceAfter=12,
        alignment=1,  # Center
        fontName='Helvetica-Bold'
    )
    
    # Section headers
    section_header_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading2'],
        fontSize=16,
        textColor=colors.HexColor(PRIMARY_COLOR),
        spaceAfter=12,
        spaceBefore=12,
        fontName='Helvetica-Bold'
    )
    
    # Body text
    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['BodyText'],
        fontSize=11,
        textColor=colors.HexColor(DARK_TEXT),
        leading=14,
        spaceAfter=12,
        fontName='Helvetica'
    )
    
    elements = []
    
    # Title
    elements.append(Paragraph("💫 Numerology Compatibility Analysis", title_style))
    elements.append(Spacer(1, 0.3 * inch))
    
    # Names
    name_text = f"<b>{person_a['input']['full_name']}</b> & <b>{person_b['input']['full_name']}</b>"
    elements.append(Paragraph(name_text, ParagraphStyle(
        'Names',
        parent=styles['Normal'],
        fontSize=14,
        alignment=1,
        spaceAfter=12,
    )))
    
    # Overall compatibility score
    overall = compatibility['overall']
    score = compatibility['score']
    max_score = compatibility['max_score']
    
    score_color = colors.HexColor('#2ECC71') if score >= 10 else (
        colors.HexColor('#F39C12') if score >= 7 else colors.HexColor('#E74C3C')
    )
    
    elements.append(Paragraph(f"<b>Overall Compatibility: {overall}</b>", ParagraphStyle(
        'OverallScore',
        parent=styles['Normal'],
        fontSize=16,
        textColor=score_color,
        alignment=1,
        spaceAfter=8,
    )))
    
    elements.append(Paragraph(f"Score: {score} / {max_score}", ParagraphStyle(
        'ScoreDetail',
        parent=styles['Normal'],
        fontSize=12,
        alignment=1,
        spaceAfter=20,
    )))
    
    # Compatibility breakdown
    elements.append(Paragraph("Compatibility Breakdown", section_header_style))
    
    breakdown_data = [
        ['Area', 'Level', 'Notes'],
        ['Life Path', compatibility['life_seal'], _get_compatibility_notes(compatibility['life_seal'])],
        ['Soul Connection', compatibility['soul_number'], _get_compatibility_notes(compatibility['soul_number'])],
        ['Personality Match', compatibility['personality_number'], _get_compatibility_notes(compatibility['personality_number'])],
    ]
    
    breakdown_table = Table(breakdown_data, colWidths=[2*inch, 1.5*inch, 3*inch])
    breakdown_table.setStyle(TableStyle([
        # Header styling - Rich purple with white text and gold underline
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor(TABLE_HEADER_BG)),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.HexColor(TABLE_HEADER_TEXT)),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('VALIGN', (0, 0), (-1, 0), 'MIDDLE'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 14),
        ('TOPPADDING', (0, 0), (-1, 0), 10),
        ('LINEBELOW', (0, 0), (-1, 0), 2, colors.HexColor(SECONDARY_COLOR)),
        
        # Row styling - Alternating light purple and white with proper borders
        ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor(TABLE_ALT_ROW)),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor(TABLE_ALT_ROW), colors.white]),
        ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 10),
        ('TOPPADDING', (0, 1), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 1), (-1, -1), 8),
        ('LEFTPADDING', (0, 1), (-1, -1), 8),
        ('RIGHTPADDING', (0, 1), (-1, -1), 8),
        
        # Border styling - Muted purple instead of black
        ('GRID', (0, 0), (-1, -1), 1, colors.HexColor(TABLE_BORDER)),
    ]))
    elements.append(breakdown_table)
    elements.append(Spacer(1, 0.3 * inch))
    
    # Individual profiles
    elements.append(Paragraph("Individual Numerological Profiles", section_header_style))
    
    profile_data = [
        ['', person_a['input']['full_name'], person_b['input']['full_name']],
        ['Date of Birth', person_a['input']['date_of_birth'], person_b['input']['date_of_birth']],
        ['Life Seal', str(person_a['core']['life_seal']), str(person_b['core']['life_seal'])],
        ['Soul Number', str(person_a['core']['soul_number']), str(person_b['core']['soul_number'])],
        ['Personality Number', str(person_a['core']['personality_number']), str(person_b['core']['personality_number'])],
    ]
    
    # Only add personal year if it exists
    if 'personal_year' in person_a['core'] and 'personal_year' in person_b['core']:
        profile_data.append(['Personal Year', str(person_a['core']['personal_year']), str(person_b['core']['personal_year'])])
    
    profile_table = Table(profile_data, colWidths=[2*inch, 2.25*inch, 2.25*inch])
    profile_table.setStyle(TableStyle([
        # Header styling - Rich purple with white text and gold underline
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor(TABLE_HEADER_BG)),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.HexColor(TABLE_HEADER_TEXT)),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 12),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),
        ('VALIGN', (0, 0), (-1, 0), 'MIDDLE'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 14),
        ('TOPPADDING', (0, 0), (-1, 0), 10),
        ('LINEBELOW', (0, 0), (-1, 0), 2, colors.HexColor(SECONDARY_COLOR)),
        
        # First column styling - Light background with purple text
        ('BACKGROUND', (0, 1), (0, -1), colors.HexColor(SECTION_BG)),
        ('TEXTCOLOR', (0, 1), (0, -1), colors.HexColor(PRIMARY_COLOR)),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),
        
        # Data columns - Alternating light purple and white rows
        ('BACKGROUND', (1, 1), (-1, -1), colors.white),
        ('ROWBACKGROUNDS', (1, 1), (-1, -1), [colors.HexColor(TABLE_ALT_ROW), colors.white]),
        
        # Overall alignment and padding
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('TOPPADDING', (0, 0), (-1, -1), 8),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 8),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
        ('RIGHTPADDING', (0, 0), (-1, -1), 8),
        
        # Border styling - Muted purple instead of black
        ('GRID', (0, 0), (-1, -1), 1, colors.HexColor(TABLE_BORDER)),
    ]))
    elements.append(profile_table)
    elements.append(Spacer(1, 0.3 * inch))
    
    # Interpretation
    elements.append(Paragraph("Understanding Your Compatibility", section_header_style))
    
    interpretation = _generate_interpretation(compatibility)
    elements.append(Paragraph(interpretation, body_style))
    
    # Footer
    elements.append(Spacer(1, 0.5 * inch))
    elements.append(Paragraph(
        "<i>This compatibility analysis is based on numerological principles and should be used as guidance for understanding relationship dynamics.</i>",
        ParagraphStyle(
            'Footer',
            parent=styles['Normal'],
            fontSize=9,
            textColor=colors.grey,
            alignment=1,
        )
    ))
    
    doc.build(elements)
    pdf_buffer.seek(0)
    return pdf_buffer


def _get_compatibility_notes(level: str) -> str:
    """Get descriptive notes for compatibility level."""
    notes = {
        "Very Strong": "Excellent harmony and natural understanding",
        "Compatible": "Good alignment with minor adjustments",
        "Challenging": "Requires effort and understanding"
    }
    return notes.get(level, "")


def _generate_interpretation(compatibility: dict) -> str:
    """Generate interpretation text based on compatibility scores."""
    overall = compatibility['overall']
    
    if overall == "Highly Compatible":
        return (
            "Your numerological profiles show exceptional harmony. The strong alignment in your core numbers "
            "suggests natural understanding and complementary energies. This compatibility indicates a relationship "
            "where both individuals support each other's growth and can navigate challenges with mutual respect."
        )
    elif overall == "Compatible":
        return (
            "Your numerological profiles demonstrate good compatibility. While there are areas of strong alignment, "
            "some aspects may require conscious effort and communication. This balance of harmony and challenge "
            "can create a dynamic and growth-oriented relationship."
        )
    elif overall == "Moderately Compatible":
        return (
            "Your numerological profiles show moderate compatibility with both harmonious and challenging aspects. "
            "Success in this relationship will depend on mutual understanding, patience, and willingness to "
            "appreciate differences. The contrasts in your numbers can provide opportunities for personal growth."
        )
    else:
        return (
            "Your numerological profiles present significant challenges that will require dedication, communication, "
            "and mutual respect to navigate. The differences in your core numbers suggest distinct life paths and "
            "perspectives. While challenging, these relationships can offer profound lessons and transformation "
            "when both individuals commit to understanding and growth."
        )
