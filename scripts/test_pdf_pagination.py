import os, sys

# Ensure repository root is on Python path
ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from backend.app.services.pdf_service import generate_report_pdf

# Build a sample report with long descriptions to test pagination
report = {
    'overview': {
        'title': 'Overview',
        'subtitle': 'Your Core Numerological Profile',
        'description': 'This section summarizes your core numerological profile including Life Seal, Soul, Personality, and Personal Year values. The descriptions below are intentionally long to test wrapping and pagination.',
        'core_numbers': {
            'life_seal': {
                'number': 7,
                'planet': 'Neptune',
                'description': ' '.join(['Insightful and introspective qualities leading to deep understanding of life and self.']*30)
            },
            'soul_number': {
                'number': 3,
                'description': ' '.join(['Creative expression, optimism, and communication drive soulful connections.']*25)
            },
            'personality_number': {
                'number': 9,
                'description': ' '.join(['Compassionate presence with humanitarian focus; expresses wisdom through actions.']*25)
            },
            'personal_year': {
                'number': 1,
                'description': ' '.join(['A year of new beginnings, initiative, and leadership opportunities in multiple domains.']*25)
            }
        }
    },
    'life_cycles': {
        'title': 'Life Cycles',
        'subtitle': 'Three Phases of Your Life Journey',
        'description': 'Life unfolds in phases with distinct energies.',
        'phases': [
            {'age_range': '0-27', 'cycle_number': 1, 'interpretation': 'Foundations are set.', 'narrative': 'A long narrative '*50},
            {'age_range': '28-55', 'cycle_number': 2, 'interpretation': 'Growth and expansion.', 'narrative': 'A long narrative '*50},
            {'age_range': '56+', 'cycle_number': 3, 'interpretation': 'Wisdom and synthesis.', 'narrative': 'A long narrative '*50},
        ]
    },
    'turning_points': {
        'title': 'Turning Points',
        'subtitle': 'Key Transitions in Your Life Path',
        'description': 'Key transitions mark your path.',
        'points': [
            {'age': '27', 'turning_point_number': 1, 'interpretation': 'Challenge and change.', 'narrative': 'Details '*50},
            {'age': '36', 'turning_point_number': 2, 'interpretation': 'Opportunity and growth.', 'narrative': 'Details '*50},
            {'age': '45', 'turning_point_number': 3, 'interpretation': 'Reflection and redirection.', 'narrative': 'Details '*50},
            {'age': '54', 'turning_point_number': 4, 'interpretation': 'Integration and mastery.', 'narrative': 'Details '*50},
        ]
    },
    'closing_summary': {
        'title': 'Closing Summary',
        'subtitle': 'Your Life Journey Perspective',
        'description': 'A cohesive view of your life journey.',
        'overview': 'Overall narrative goes here.'*50,
        'life_phase_summary': [
            {'age_range': '0-27', 'text': 'Summary for early years.'},
            {'age_range': '28-55', 'text': 'Summary for middle years.'},
            {'age_range': '56+', 'text': 'Summary for later years.'},
        ]
    }
}

buf = generate_report_pdf('John Doe', '1990-01-01', report)
with open('test_pagination.pdf','wb') as f:
    f.write(buf.getvalue())
print('OK: Generated PDF with size', len(buf.getvalue()))
