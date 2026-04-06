from PyPDF2 import PdfReader

try:
    with open('pdf_output.txt', 'w', encoding='utf-8') as f:
        f.write('--- IDEA ORIGIN ---\n')
        reader1 = PdfReader('idea and design/idea origin.pdf')
        for page in reader1.pages:
            f.write(page.extract_text() + '\n')
            
        f.write('\n\n--- DESIGN ---\n')
        reader2 = PdfReader('idea and design/design.pdf')
        for page in reader2.pages:
            f.write(page.extract_text() + '\n')
    print("Done writing to pdf_output.txt")
except Exception as e:
    print(f"Error: {e}")
