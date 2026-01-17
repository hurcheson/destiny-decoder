"""Detailed PDF content analysis."""
from PyPDF2 import PdfReader

reader = PdfReader('test_output.pdf')
print(f'=== COMPLETE PDF TEXT EXTRACTION ===')
print(f'Total Pages: {len(reader.pages)}\n')

for page_num, page in enumerate(reader.pages, 1):
    text = page.extract_text()
    print(f'\n{"="*80}')
    print(f'PAGE {page_num} ({len(text)} characters)')
    print(f'{"="*80}')
    print(text)
    print()
