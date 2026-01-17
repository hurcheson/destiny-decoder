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
        story.append(Paragraph("Your Destiny Reading", self.styles['CustomTitle']))
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
        
        def format_interpretation(text):
            """Format interpretation text for better readability."""
            if not text or not isinstance(text, str):
                return ''
            # Add space after commas if missing
            text = text.replace(',', ', ').replace(',  ', ', ')
            # Fix common typos
            text = text.replace('Matrial', 'Material')
            text = text.replace('Startegic', 'Strategic')
            text = text.replace('Dominioring', 'Domineering')
            text = text.replace('Opprtunities', 'Opportunities')
            return text
        
        core_data = [
            ['Number Type', 'Number', 'Planet/Meaning'],
            ['Life Path (Life Seal)', safe_str(core.get('life_seal')), safe_str(core.get('life_planet'))],
            ['Soul Urge (Soul Number)', safe_str(core.get('soul_number')), 'Inner Desire'],
            ['Expression (Destiny)', safe_str(core.get('physical_name_number')), 'Life Purpose'],
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
                formatted_content = format_interpretation(content)
                story.append(Paragraph(formatted_content, self.styles['CustomBody']))
            elif not content:
                story.append(Paragraph("<i>Interpretation data not available.</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.15*inch))
        
        # Soul Number Interpretation
        if interpretations.get('soul_number'):
            soul = interpretations['soul_number']
            story.append(Paragraph(f"Soul Urge Number {soul.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = soul.get('content', '')
            if content and isinstance(content, str):
                formatted_content = format_interpretation(content)
                story.append(Paragraph(formatted_content, self.styles['CustomBody']))
            elif not content:
                story.append(Paragraph("<i>Interpretation data not available.</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.15*inch))
        
        # Personality Number Interpretation
        if interpretations.get('personality_number'):
            pers = interpretations['personality_number']
            story.append(Paragraph(f"Personality Number {pers.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = pers.get('content', '')
            if content and isinstance(content, str):
                formatted_content = format_interpretation(content)
                story.append(Paragraph(formatted_content, self.styles['CustomBody']))
            elif not content:
                story.append(Paragraph("<i>Interpretation data not available.</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.15*inch))
        
        story.append(PageBreak())
        
        # Personal Year
        if interpretations.get('personal_year'):
            py = interpretations['personal_year']
            story.append(Paragraph(f"Personal Year Cycle - Year {py.get('number', 'N/A')}", self.styles['CustomSubtitle']))
            story.append(Spacer(1, 0.08*inch))
            content = py.get('content', '')
            if content and isinstance(content, str):
                formatted_content = format_interpretation(content)
                story.append(Paragraph(formatted_content, self.styles['CustomBody']))
            elif not content:
                story.append(Paragraph("<i>Interpretation data not available.</i>", self.styles['InfoLabel']))
            story.append(Spacer(1, 0.2*inch))
        
        # Blessed Years and Days
        if core.get('blessed_years') or core.get('blessed_days'):
            story.append(Paragraph("Blessed Years & Days", self.styles['CustomSubtitle']))
            if core.get('blessed_years'):
                blessed_years = core['blessed_years']
                if isinstance(blessed_years, list):
                    years_str = ', '.join(str(y) for y in blessed_years[:10])  # Show first 10
                    story.append(Paragraph(f"<b>Blessed Years (next 10):</b> {years_str}", self.styles['CustomBody']))
            if core.get('blessed_days'):
                blessed_days = core['blessed_days']
                if isinstance(blessed_days, list):
                    days_str = ', '.join(str(d) for d in blessed_days)
                    story.append(Paragraph(f"<b>Blessed Days (each month):</b> {days_str}", self.styles['CustomBody']))
            story.append(Spacer(1, 0.2*inch))
        
        # Life Cycles - Enhanced with narrative
        if core.get('life_cycles'):
            story.append(Paragraph("Life Cycles - Your Life Journey Phases", self.styles['CustomSubtitle']))
            cycles = core['life_cycles']
            
            if isinstance(cycles, list):
                cycle_names = ["First Cycle (Formative Years)", "Second Cycle (Productive Years)", "Third Cycle (Harvest Years)"]
                for idx, cycle_data in enumerate(cycles):
                    if isinstance(cycle_data, dict) and cycle_data.get('number'):
                        cycle_name = cycle_names[idx] if idx < len(cycle_names) else f"Cycle {idx+1}"
                        story.append(Paragraph(
                            f"<b>{cycle_name}</b> - Number {cycle_data.get('number')} "
                            f"<i>(Ages {cycle_data.get('age_range', 'N/A')})</i>",
                            self.styles['SectionHeader']
                        ))
                        
                        # Interpretation with formatting
                        if cycle_data.get('interpretation'):
                            formatted_interp = format_interpretation(cycle_data['interpretation'])
                            story.append(Paragraph(formatted_interp, self.styles['CustomBody']))
                        
                        story.append(Spacer(1, 0.12*inch))
            
            story.append(Spacer(1, 0.2*inch))
        
        # Turning Points - Enhanced with ages and narrative
        if core.get('turning_points'):
            story.append(Paragraph("Turning Points - Major Life Transitions", self.styles['CustomSubtitle']))
            turning_points = core['turning_points']
            
            if isinstance(turning_points, list):
                for idx, tp_data in enumerate(turning_points):
                    if isinstance(tp_data, dict) and tp_data.get('number'):
                        age = tp_data.get('age', 'N/A')
                        story.append(Paragraph(
                            f"<b>Turning Point {idx+1} at Age {age}</b> - Number {tp_data.get('number')}",
                            self.styles['SectionHeader']
                        ))
                        
                        # Interpretation with formatting
                        if tp_data.get('interpretation'):
                            formatted_interp = format_interpretation(tp_data['interpretation'])
                            story.append(Paragraph(formatted_interp, self.styles['CustomBody']))
                        
                        story.append(Spacer(1, 0.12*inch))
            
            story.append(Spacer(1, 0.2*inch))
        
        story.append(PageBreak())
        
        # Pinnacles
        if interpretations.get('pinnacles'):
            story.append(Paragraph("Pinnacles - Achievement Periods", self.styles['CustomSubtitle']))
            story.append(Paragraph(
                "<i>Four major achievement periods that highlight opportunities and focus areas throughout your life.</i>",
                self.styles['InfoLabel']
            ))
            story.append(Spacer(1, 0.1*inch))
            pinnacles = interpretations['pinnacles']
            
            for i, pinnacle in enumerate(pinnacles, 1):
                if isinstance(pinnacle, dict):
                    story.append(Paragraph(
                        f"<b>Pinnacle {i} - Number {pinnacle.get('number', 'N/A')}</b>",
                        self.styles['SectionHeader']
                    ))
                    content = pinnacle.get('content')
                    if content and isinstance(content, str):
                        formatted_content = format_interpretation(content)
                        story.append(Paragraph(formatted_content, self.styles['CustomBody']))
                    story.append(Spacer(1, 0.12*inch))
            
            story.append(Spacer(1, 0.15*inch))
        
        # Life Journey Narrative (from report if available)
        if core.get('narrative'):
            narrative = core['narrative']
            if isinstance(narrative, dict):
                story.append(PageBreak())
                story.append(Paragraph("Your Life Journey - Deeper Insights", self.styles['CustomSubtitle']))
                
                # Overview
                if narrative.get('overview'):
                    story.append(Paragraph(narrative['overview'], self.styles['CustomBody']))
                    story.append(Spacer(1, 0.15*inch))
                
                # Life Phases detailed narrative
                if narrative.get('life_phases'):
                    story.append(Paragraph("Life Phase Perspectives:", self.styles['SectionHeader']))
                    for phase in narrative['life_phases']:
                        if isinstance(phase, dict):
                            age_range = phase.get('age_range', '')
                            text = phase.get('text', '')
                            if age_range and text:
                                # Remove duplicate age prefix from text if it exists
                                text_clean = text.strip()
                                if text_clean.startswith(f"Ages {age_range}:"):
                                    text_clean = text_clean[len(f"Ages {age_range}:"):].strip()
                                elif text_clean.startswith(age_range):
                                    text_clean = text_clean[len(age_range):].strip().lstrip(':')
                                story.append(Paragraph(f"<b>Ages {age_range}:</b> {text_clean}", self.styles['CustomBody']))
                                story.append(Spacer(1, 0.1*inch))
                
                # Turning Points detailed narrative
                if narrative.get('turning_points'):
                    story.append(Spacer(1, 0.15*inch))
                    story.append(Paragraph("Turning Point Insights:", self.styles['SectionHeader']))
                    for tp in narrative['turning_points']:
                        if isinstance(tp, dict):
                            age = tp.get('age', '')
                            text = tp.get('text', '')
                            if age and text:
                                # Ensure text is complete - find last complete sentence
                                text_clean = text.strip()
                                if len(text_clean) > 300 and not text_clean.endswith('.'):
                                    # Find last period before cutoff
                                    last_period = text_clean.rfind('.', 0, 300)
                                    if last_period > 0:
                                        text_clean = text_clean[:last_period + 1]
                                story.append(Paragraph(f"<b>Age {age}:</b> {text_clean}", self.styles['CustomBody']))
                                story.append(Spacer(1, 0.1*inch))
        
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

