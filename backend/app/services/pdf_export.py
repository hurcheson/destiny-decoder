"""PDF export service for numerology readings."""

from io import BytesIO
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak, Table, TableStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY
from reportlab.lib import colors


class PDFExportService:
    """Generate professional PDF reports for numerology readings."""

    def __init__(self):
        self.styles = getSampleStyleSheet()
        self._setup_custom_styles()

    def _setup_custom_styles(self):
        """Create custom paragraph styles."""
        # Title style
        self.styles.add(ParagraphStyle(
            name='CustomTitle',
            parent=self.styles['Heading1'],
            fontSize=26,
            textColor=colors.HexColor('#4A148C'),
            spaceAfter=20,
            alignment=TA_CENTER,
            fontName='Helvetica-Bold',
        ))

        # Subtitle style
        self.styles.add(ParagraphStyle(
            name='CustomSubtitle',
            parent=self.styles['Heading2'],
            fontSize=14,
            textColor=colors.HexColor('#7B1FA2'),
            spaceAfter=12,
            fontName='Helvetica-Bold',
            spaceBefore=12,
        ))

        # Section header
        self.styles.add(ParagraphStyle(
            name='SectionHeader',
            parent=self.styles['Heading3'],
            fontSize=13,
            textColor=colors.HexColor('#512DA8'),
            spaceAfter=10,
            spaceBefore=10,
            fontName='Helvetica-Bold',
        ))

        # Body style
        self.styles.add(ParagraphStyle(
            name='CustomBody',
            parent=self.styles['BodyText'],
            fontSize=10,
            leading=14,
            spaceAfter=10,
            alignment=TA_JUSTIFY,
        ))

        # Info label
        self.styles.add(ParagraphStyle(
            name='InfoLabel',
            parent=self.styles['Normal'],
            fontSize=9,
            textColor=colors.HexColor('#666666'),
            fontName='Helvetica-Bold',
        ))

    def generate_full_reading_pdf(self, decode_response: dict) -> BytesIO:
        """
        Generate a comprehensive PDF report from /decode/full response.
        
        Args:
            decode_response: Full response from /decode/full endpoint containing:
                - input: {full_name, date_of_birth}
                - core: Core calculation data
                - interpretations: Interpretations for all numbers
            
        Returns:
            BytesIO buffer containing the PDF
            
        Raises:
            ValueError: If required data is missing
        """
        # Extract data with safe defaults
        input_data = decode_response.get('input', {})
        core = decode_response.get('core', {})
        interpretations = decode_response.get('interpretations', {})
        
        # Validate required data
        if not input_data or not input_data.get('full_name'):
            raise ValueError("Missing required input data: full_name")
        
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter,
                                topMargin=0.5*inch, bottomMargin=0.5*inch,
                                leftMargin=0.75*inch, rightMargin=0.75*inch)
        
        story = []
        
        # Extract data
        input_data = decode_response.get('input', {})
        core = decode_response.get('core', {})
        interpretations = decode_response.get('interpretations', {})
        
        # Title
        story.append(Paragraph("🌙 Your Destiny Reading 🌙", self.styles['CustomTitle']))
        story.append(Spacer(1, 0.15*inch))
        
        # Personal Information
        story.append(Paragraph(f"<b>Name:</b> {input_data.get('full_name', 'N/A')}", self.styles['CustomBody']))
        story.append(Paragraph(f"<b>Date of Birth:</b> {input_data.get('date_of_birth', 'N/A')}", self.styles['CustomBody']))
        story.append(Paragraph(f"<b>Report Generated:</b> {datetime.now().strftime('%B %d, %Y at %I:%M %p')}", self.styles['CustomBody']))
        story.append(Spacer(1, 0.2*inch))
        
        # Core Numbers Summary Table
        story.append(Paragraph("Core Numbers", self.styles['CustomSubtitle']))
        core_data = [
            ['Number Type', 'Number', 'Planet/Meaning'],
            ['Life Path (Life Seal)', str(core.get('life_seal', 'N/A')), core.get('life_planet', 'N/A')],
            ['Soul Urge (Soul Number)', str(core.get('soul_number', 'N/A')), 'Inner Desire'],
            ['Expression (Destiny)', str(core.get('expression_number', 'N/A')), 'Life Purpose'],
            ['Personality', str(core.get('personality_number', 'N/A')), 'Outer Expression'],
            ['Personal Year', str(core.get('personal_year', 'N/A')), 'Current Cycle'],
        ]
        
        core_table = Table(core_data, colWidths=[2*inch, 1*inch, 2*inch])
        core_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#7B1FA2')),
            ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
            ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
            ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
            ('FONTSIZE', (0, 0), (-1, 0), 11),
            ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
            ('BACKGROUND', (0, 1), (-1, -1), colors.HexColor('#F3E5F5')),
            ('GRID', (0, 0), (-1, -1), 1, colors.HexColor('#E1BEE7')),
            ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.HexColor('#F3E5F5'), colors.white]),
            ('FONTSIZE', (0, 1), (-1, -1), 10),
        ]))
        
        story.append(core_table)
        story.append(Spacer(1, 0.2*inch))
        
        # Life Seal Interpretation
        if interpretations.get('life_seal'):
            life_seal = interpretations['life_seal']
            story.append(Paragraph(f"Life Path Number {life_seal['number']}", self.styles['CustomSubtitle']))
            story.append(Paragraph(f"<i>Planet: {life_seal.get('planet', 'N/A')}</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.08*inch))
            story.append(Paragraph(life_seal.get('content', ''), self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        # Soul Number Interpretation
        if interpretations.get('soul_number'):
            soul = interpretations['soul_number']
            story.append(Paragraph(f"Soul Urge Number {soul['number']}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            story.append(Paragraph(soul.get('content', ''), self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        # Personality Number Interpretation
        if interpretations.get('personality_number'):
            pers = interpretations['personality_number']
            story.append(Paragraph(f"Personality Number {pers['number']}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            story.append(Paragraph(pers.get('content', ''), self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        story.append(PageBreak())
        
        # Personal Year
        if interpretations.get('personal_year'):
            py = interpretations['personal_year']
            story.append(Paragraph(f"Personal Year Cycle - Year {py['number']}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            story.append(Paragraph(py.get('content', ''), self.styles['CustomBody']))
            story.append(Spacer(1, 0.2*inch))
        
        # Life Cycles
        if core.get('life_cycles'):
            story.append(Paragraph("Life Cycles", self.styles['CustomSubtitle']))
            cycles = core['life_cycles']
            
            for cycle_name, cycle_data in cycles.items():
                if isinstance(cycle_data, dict) and cycle_data.get('number'):
                    clean_name = cycle_name.replace('_', ' ').title()
                    story.append(Paragraph(
                        f"<b>{clean_name}:</b> Number {cycle_data.get('number')} "
                        f"(Ages {cycle_data.get('start_age', 'N/A')}-{cycle_data.get('end_age', 'N/A')})",
                        self.styles['CustomBody']
                    ))
            
            story.append(Spacer(1, 0.2*inch))
        
        # Pinnacles
        if interpretations.get('pinnacles'):
            story.append(Paragraph("Pinnacles (Life Pinnacles)", self.styles['CustomSubtitle']))
            pinnacles = interpretations['pinnacles']
            
            for i, pinnacle in enumerate(pinnacles, 1):
                story.append(Paragraph(
                    f"<b>Pinnacle {i} - Number {pinnacle.get('number', 'N/A')}</b>",
                    self.styles['SectionHeader']
                ))
                if pinnacle.get('content'):
                    story.append(Paragraph(pinnacle['content'], self.styles['CustomBody']))
                story.append(Spacer(1, 0.1*inch))
            
            story.append(Spacer(1, 0.15*inch))
        
        story.append(PageBreak())
        
        # Challenges (if available in core data)
        if core.get('challenges'):
            story.append(Paragraph("Life Challenges", self.styles['CustomSubtitle']))
            challenges = core['challenges']
            
            for i, challenge in enumerate(challenges, 1):
                if isinstance(challenge, dict):
                    story.append(Paragraph(
                        f"<b>Challenge {i} - Number {challenge.get('number', 'N/A')}</b>",
                        self.styles['SectionHeader']
                    ))
                    if challenge.get('interpretation'):
                        story.append(Paragraph(challenge['interpretation'], self.styles['CustomBody']))
                    story.append(Spacer(1, 0.1*inch))
            
            story.append(Spacer(1, 0.15*inch))
        
        # Footer
        story.append(Spacer(1, 0.3*inch))
        story.append(Paragraph(
            "<i style='font-size:9px'>This numerology reading is for entertainment and spiritual guidance purposes. "
            "Numerology is an ancient belief system that ascribes mystical significance to numbers. "
            "Generated by Destiny Decoder.</i>",
            self.styles['CustomBody']
        ))
        
        # Build PDF
        doc.build(story)
        buffer.seek(0)
        return buffer

