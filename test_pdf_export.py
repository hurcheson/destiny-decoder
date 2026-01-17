"""Test script to generate and inspect PDF export."""
import requests
import json
import sys

# Fix Windows encoding issues
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')

# Test data
test_data = {
    'first_name': 'John',
    'other_names': 'Michael Smith',
    'day_of_birth': 15,
    'month_of_birth': 6,
    'year_of_birth': 1990
}

print('=== Testing PDF Generation ===')
print(f'Test Subject: {test_data["first_name"]} {test_data["other_names"]}')
print(f'DOB: {test_data["year_of_birth"]}-{test_data["month_of_birth"]:02d}-{test_data["day_of_birth"]:02d}')
print()

# First, get the decode data
print('Step 1: Getting decode data from /decode/full...')
try:
    decode_response = requests.post(
        'http://127.0.0.1:8000/decode/full',
        json=test_data,
        timeout=10
    )
    
    if decode_response.status_code == 200:
        decode_data = decode_response.json()
        print(f'✓ Decode successful')
        print(f'  Life Seal: {decode_data.get("core", {}).get("life_seal")}')
        print(f'  Soul Number: {decode_data.get("core", {}).get("soul_number")}')
        print(f'  Personal Year: {decode_data.get("core", {}).get("personal_year")}')
        
        # Print structure analysis
        print('\n=== Decode Data Structure ===')
        core = decode_data.get('core', {})
        print(f'Core keys: {list(core.keys())}')
        
        if 'life_cycles' in core:
            print(f'Life Cycles count: {len(core["life_cycles"])}')
            for i, cycle in enumerate(core["life_cycles"], 1):
                print(f'  Cycle {i}: Number={cycle.get("number")}, Age={cycle.get("age_range")}')
        
        if 'turning_points' in core:
            print(f'Turning Points count: {len(core["turning_points"])}')
            for i, tp in enumerate(core["turning_points"], 1):
                print(f'  TP {i}: Number={tp.get("number")}, Age={tp.get("age")}')
        
        if 'narrative' in core:
            narrative = core['narrative']
            print(f'Narrative keys: {list(narrative.keys())}')
        
        # Check interpretations
        interpretations = decode_data.get('interpretations', {})
        print(f'\nInterpretations available: {list(interpretations.keys())}')
        if 'life_seal' in interpretations:
            life_seal = interpretations['life_seal']
            content_preview = str(life_seal.get("content", ""))[:50] + "..." if life_seal.get("content") else "NONE"
            print(f'  Life Seal: number={life_seal.get("number")}, content={content_preview}')
        if 'soul_number' in interpretations:
            soul = interpretations['soul_number']
            content_preview = str(soul.get("content", ""))[:50] + "..." if soul.get("content") else "NONE"
            print(f'  Soul: number={soul.get("number")}, content={content_preview}')
        if 'pinnacles' in interpretations:
            pinnacles = interpretations['pinnacles']
            print(f'  Pinnacles: type={type(pinnacles).__name__}, count={len(pinnacles) if isinstance(pinnacles, list) else "N/A"}')
            if isinstance(pinnacles, list) and len(pinnacles) > 0:
                p1 = pinnacles[0]
                print(f'    First pinnacle: type={type(p1).__name__}, number={p1.get("number") if isinstance(p1, dict) else "N/A"}')
        
        print()
        
        # Now export PDF
        print('Step 2: Generating PDF from /export/pdf...')
        export_data = {
            'full_name': 'John Michael Smith',
            'date_of_birth': '1990-06-15',
            'decode_data': decode_data
        }
        
        pdf_response = requests.post(
            'http://127.0.0.1:8000/export/pdf',
            json=export_data,
            timeout=10
        )
        
        if pdf_response.status_code == 200:
            print(f'✓ PDF generated successfully')
            print(f'  Size: {len(pdf_response.content)} bytes')
            
            # Save PDF for inspection
            with open('test_output.pdf', 'wb') as f:
                f.write(pdf_response.content)
            print(f'  Saved to: test_output.pdf')
            
            # Try to extract text for analysis
            try:
                from PyPDF2 import PdfReader
                reader = PdfReader('test_output.pdf')
                print(f'\n=== PDF Content Analysis ===')
                print(f'Pages: {len(reader.pages)}')
                
                for page_num, page in enumerate(reader.pages, 1):
                    text = page.extract_text()
                    print(f'\n--- Page {page_num} ({len(text)} chars) ---')
                    # Show first 500 chars of each page
                    preview = text[:500].replace('\n', ' ')
                    print(preview + '...' if len(text) > 500 else preview)
                    
            except ImportError:
                print('\nNote: Install PyPDF2 to inspect PDF text: pip install PyPDF2')
            except Exception as e:
                print(f'\nNote: Could not extract PDF text: {e}')
                
        else:
            print(f'✗ PDF generation failed: {pdf_response.status_code}')
            print(f'  Error: {pdf_response.text}')
    else:
        print(f'✗ Decode failed: {decode_response.status_code}')
        print(f'  Error: {decode_response.text}')
        
except Exception as e:
    print(f'✗ Error: {e}')
    import traceback
    traceback.print_exc()
