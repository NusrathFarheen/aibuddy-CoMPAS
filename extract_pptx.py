import zipfile
import xml.etree.ElementTree as ET
import sys

pptx_file = r"D:\PROJECTS\AIBUDDY(compas)\idea and design\1ST REV.pptx"

def extract_text_from_pptx(path):
    text_runs = []
    try:
        with zipfile.ZipFile(path, 'r') as slide_zip:
            # Get slides and sort them by slide number
            slide_names = [n for n in slide_zip.namelist() if n.startswith('ppt/slides/slide') and n.endswith('.xml')]
            slide_names.sort(key=lambda x: int(''.join(filter(str.isdigit, x))))
            
            for name in slide_names:
                slide_xml = slide_zip.read(name)
                root = ET.fromstring(slide_xml)
                text_runs.append(f"--- Slide: {name} ---")
                slide_text = []
                for elem in root.iter():
                    if elem.tag.endswith('}t') and elem.text:
                        slide_text.append(elem.text)
                text_runs.append(" ".join(slide_text))
    except Exception as e:
        return str(e)
    return "\n".join(text_runs)

if __name__ == "__main__":
    print(extract_text_from_pptx(pptx_file))
