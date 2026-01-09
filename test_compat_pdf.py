#!/usr/bin/env python3
"""Test compatibility PDF generation"""

import sys
sys.path.insert(0, 'backend')

from app.services.compatibility_pdf_service import generate_compatibility_pdf

# Test data
person_a = {
    'input': {
        'full_name': 'John Smith',
        'date_of_birth': '1990-05-15',
    },
    'core': {
        'life_seal': 7,
        'soul_number': 3,
        'personality_number': 4,
    }
}

person_b = {
    'input': {
        'full_name': 'Jane Doe',
        'date_of_birth': '1992-08-20',
    },
    'core': {
        'life_seal': 3,
        'soul_number': 7,
        'personality_number': 2,
    }
}

compatibility = {
    'overall': 'Compatible',
    'life_seal': 'Compatible',
    'soul_number': 'Compatible',
    'personality_number': 'Challenging',
    'score': 7,
    'max_score': 12,
}

try:
    pdf_buffer = generate_compatibility_pdf(person_a, person_b, compatibility)
    print("PDF generated successfully!")
    print(f"Size: {len(pdf_buffer.getvalue())} bytes")
except Exception as e:
    print(f"Error: {e}")
    import traceback
    traceback.print_exc()
