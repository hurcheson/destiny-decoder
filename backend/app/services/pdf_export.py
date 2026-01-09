"""PDF export service for numerology readings."""

from io import BytesIO
from datetime import datetime
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, PageBreak
from reportlab.lib.enums import TA_CENTER, TA_LEFT
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
            fontSize=24,
            textColor=colors.HexColor('#4A148C'),
            spaceAfter=30,
            alignment=TA_CENTER,
        ))

        # Subtitle style
        self.styles.add(ParagraphStyle(
            name='CustomSubtitle',
            parent=self.styles['Heading2'],
            fontSize=16,
            textColor=colors.HexColor('#7B1FA2'),
            spaceAfter=12,
        ))

        # Body style
        self.styles.add(ParagraphStyle(
            name='CustomBody',
            parent=self.styles['BodyText'],
            fontSize=11,
            leading=16,
            spaceAfter=12,
        ))

    def generate_full_reading_pdf(self, decode_data: dict) -> BytesIO:
        """
        Generate a comprehensive PDF report for a full numerology reading.
        
        Args:
            decode_data: Full decode response from /decode/full endpoint
            
        Returns:
            BytesIO buffer containing the PDF
        """
        buffer = BytesIO()
        doc = SimpleDocTemplate(buffer, pagesize=letter,
                                topMargin=0.75*inch, bottomMargin=0.75*inch,
                                leftMargin=1*inch, rightMargin=1*inch)
        
        story = []
        
        # Title
        story.append(Paragraph("🌙 Destiny Decoder Reading 🌙", self.styles['CustomTitle']))
        story.append(Spacer(1, 0.2*inch))
        
        # Personal information
        input_data = decode_data.get('input', {})
        story.append(Paragraph(f"<b>Name:</b> {input_data.get('full_name', 'N/A')}", self.styles['CustomBody']))
        story.append(Paragraph(f"<b>Date of Birth:</b> {input_data.get('date_of_birth', 'N/A')}", self.styles['CustomBody']))
        story.append(Paragraph(f"<b>Report Generated:</b> {datetime.now().strftime('%B %d, %Y')}", self.styles['CustomBody']))
        story.append(Spacer(1, 0.3*inch))
        
        # Core Numbers
        story.append(Paragraph("Core Numbers", self.styles['CustomSubtitle']))
        core_numbers = decode_data.get('core_numbers', {})
        
        if core_numbers.get('life_path'):
            lp = core_numbers['life_path']
            story.append(Paragraph(f"<b>Life Path Number: {lp['number']}</b>", self.styles['CustomBody']))
            story.append(Paragraph(lp['interpretation'], self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        if core_numbers.get('expression'):
            expr = core_numbers['expression']
            story.append(Paragraph(f"<b>Expression Number: {expr['number']}</b>", self.styles['CustomBody']))
            story.append(Paragraph(expr['interpretation'], self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        if core_numbers.get('soul_urge'):
            soul = core_numbers['soul_urge']
            story.append(Paragraph(f"<b>Soul Urge Number: {soul['number']}</b>", self.styles['CustomBody']))
            story.append(Paragraph(soul['interpretation'], self.styles['CustomBody']))
            story.append(Spacer(1, 0.15*inch))
        
        if core_numbers.get('personality'):
            pers = core_numbers['personality']
            story.append(Paragraph(f"<b>Personality Number: {pers['number']}</b>", self.styles['CustomBody']))
            story.append(Paragraph(pers['interpretation'], self.styles['CustomBody']))
            story.append(Spacer(1, 0.3*inch))
        
        # Life Cycles
        if decode_data.get('life_cycles'):
            story.append(Paragraph("Life Cycles", self.styles['CustomSubtitle']))
            cycles = decode_data['life_cycles']
            
            for cycle_name, cycle_data in cycles.items():
                if isinstance(cycle_data, dict):
                    story.append(Paragraph(
                        f"<b>{cycle_name.replace('_', ' ').title()}:</b> Number {cycle_data.get('number', 'N/A')} "
                        f"(Ages {cycle_data.get('start_age', 'N/A')}-{cycle_data.get('end_age', 'N/A')})",
                        self.styles['CustomBody']
                    ))
                    if cycle_data.get('interpretation'):
                        story.append(Paragraph(cycle_data['interpretation'], self.styles['CustomBody']))
                    story.append(Spacer(1, 0.1*inch))
            
            story.append(Spacer(1, 0.2*inch))
        
        # Personal Year
        if decode_data.get('current_year'):
            story.append(PageBreak())
            story.append(Paragraph("Current Personal Year", self.styles['CustomSubtitle']))
            py = decode_data['current_year']
            story.append(Paragraph(f"<b>Personal Year {py['number']}</b>", self.styles['CustomBody']))
            story.append(Paragraph(py['interpretation'], self.styles['CustomBody']))
            story.append(Spacer(1, 0.3*inch))
        
        # Pinnacles
        if decode_data.get('pinnacles'):
            story.append(Paragraph("Pinnacles", self.styles['CustomSubtitle']))
            pinnacles = decode_data['pinnacles']
            
            for i, pinnacle in enumerate(pinnacles, 1):
                story.append(Paragraph(
                    f"<b>Pinnacle {i}:</b> Number {pinnacle.get('number', 'N/A')} "
                    f"(Ages {pinnacle.get('start_age', 'N/A')}-{pinnacle.get('end_age', 'N/A')})",
                    self.styles['CustomBody']
                ))
                if pinnacle.get('interpretation'):
                    story.append(Paragraph(pinnacle['interpretation'], self.styles['CustomBody']))
                story.append(Spacer(1, 0.1*inch))
            
            story.append(Spacer(1, 0.2*inch))
        
        # Challenges
        if decode_data.get('challenges'):
            story.append(Paragraph("Challenges", self.styles['CustomSubtitle']))
            challenges = decode_data['challenges']
            
            for i, challenge in enumerate(challenges, 1):
                story.append(Paragraph(
                    f"<b>Challenge {i}:</b> Number {challenge.get('number', 'N/A')} "
                    f"(Ages {challenge.get('start_age', 'N/A')}-{challenge.get('end_age', 'N/A')})",
                    self.styles['CustomBody']
                ))
                if challenge.get('interpretation'):
                    story.append(Paragraph(challenge['interpretation'], self.styles['CustomBody']))
                story.append(Spacer(1, 0.1*inch))
        
        # Footer
        story.append(Spacer(1, 0.5*inch))
        story.append(Paragraph(
            "<i>This reading is for entertainment purposes only. "
            "Generated by Destiny Decoder.</i>",
            self.styles['CustomBody']
        ))
        
        # Build PDF
        doc.build(story)
        buffer.seek(0)
        return buffer
