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
        
        # Safe conversion to string for table cells
        def safe_str(value):
            """Convert value to string safely, handling dicts/lists."""
            if value is None:
                return 'N/A'
            if isinstance(value, (dict, list)):
                return 'N/A'  # Skip complex types
            return str(value)
        
        core_data = [
            ['Number Type', 'Number', 'Planet/Meaning'],
            ['Life Path (Life Seal)', safe_str(core.get('life_seal')), safe_str(core.get('life_planet'))],
            ['Soul Urge (Soul Number)', safe_str(core.get('soul_number')), 'Inner Desire'],
            ['Expression (Destiny)', safe_str(core.get('expression_number')), 'Life Purpose'],
            ['Personality', safe_str(core.get('personality_number')), 'Outer Expression'],
            ['Personal Year', safe_str(core.get('personal_year')), 'Current Cycle'],
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
            story.append(Paragraph(f"Life Path Number {life_seal.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Paragraph(f"<i>Planet: {safe_str(life_seal.get('planet', 'N/A'))}</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.08*inch))
            content = life_seal.get('content', '')
            if content and isinstance(content, str):
                story.append(Paragraph(content, self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        # Soul Number Interpretation
        if interpretations.get('soul_number'):
            soul = interpretations['soul_number']
            story.append(Paragraph(f"Soul Urge Number {soul.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = soul.get('content', '')
            if content and isinstance(content, str):
                story.append(Paragraph(content, self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        # Personality Number Interpretation
        if interpretations.get('personality_number'):
            pers = interpretations['personality_number']
            story.append(Paragraph(f"Personality Number {pers.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = pers.get('content', '')
            if content and isinstance(content, str):
                story.append(Paragraph(content, self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        story.append(PageBreak())
        
        # Personal Year
        if interpretations.get('personal_year'):
            py = interpretations['personal_year']
            story.append(Paragraph(f"Personal Year Cycle - Year {py.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = py.get('content', '')
            if content and isinstance(content, str):
                story.append(Paragraph(content, self.styles['CustomBody']))
            story.append(Spacer(1, 0.2*inch))
        
        # Life Cycles
        if core.get('life_cycles'):
            story.append(Paragraph("Life Cycles", self.styles['CustomSubtitle']))
            cycles = core['life_cycles']
            
            # life_cycles is a list of dicts, not a dict
            if isinstance(cycles, list):
                cycle_names = ["First Cycle", "Second Cycle", "Third Cycle"]
                for idx, cycle_data in enumerate(cycles):
                    if isinstance(cycle_data, dict) and cycle_data.get('number'):
                        cycle_name = cycle_names[idx] if idx < len(cycle_names) else f"Cycle {idx+1}"
                        story.append(Paragraph(
                            f"<b>{cycle_name}:</b> Number {cycle_data.get('number')} "
                            f"<i>{cycle_data.get('age_range', 'N/A')}</i>",
                            self.styles['CustomBody']
                        ))
                        if cycle_data.get('interpretation'):
                            story.append(Paragraph(cycle_data['interpretation'], self.styles['InfoLabel']))
                        story.append(Spacer(1, 0.08*inch))
            
            story.append(Spacer(1, 0.2*inch))
        
        # Pinnacles
        if interpretations.get('pinnacles'):
            story.append(Paragraph("Pinnacles (Life Pinnacles)", self.styles['CustomSubtitle']))
            pinnacles = interpretations['pinnacles']
            
            for i, pinnacle in enumerate(pinnacles, 1):
                if isinstance(pinnacle, dict):
                    story.append(Paragraph(
                        f"<b>Pinnacle {i} - Number {pinnacle.get('number', 'N/A')}</b>",
                        self.styles['SectionHeader']
                    ))
                    content = pinnacle.get('content')
                    if content and isinstance(content, str):
                        story.append(Paragraph(content, self.styles['CustomBody']))
                    story.append(Spacer(1, 0.1*inch))
            
            story.append(Spacer(1, 0.15*inch))
        
        story.append(PageBreak())
        
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

