"""Prepare the native UI face from Noto Sans CJK SC (SIL OFL 1.1).

python Tools/design/prepare-go-font.py /path/to/NotoSansCJKsc-Regular.otf
Requires fonttools. Source and license links are in README.md.
"""
from pathlib import Path
import sys
from fontTools.ttLib import TTFont

source = Path(sys.argv[1])
weight = 'Medium' if 'Medium' in source.stem else 'Regular'
root = Path(__file__).resolve().parents[2]
font = TTFont(source)
# Dora fits font size to hhea's line box; use Noto's typographic em metrics.
# This changes layout metrics only, not outlines or Unicode coverage.
font['hhea'].ascent = 880
font['hhea'].descent = -120
font['hhea'].lineGap = 0
names = {1: 'Dora UI Sans', 4: f'Dora UI Sans {weight}', 6: f'DoraUISans-{weight}',
         16: 'Dora UI Sans', 17: weight}
for record in font['name'].names:
    if record.nameID in names:
        record.string = names[record.nameID].encode(record.getEncoding())
if 'CFF ' in font:
    cff = font['CFF '].cff
    cff.fontNames = [f'DoraUISans-{weight}']
    cff.topDictIndex[0].FamilyName = 'Dora UI Sans'
    cff.topDictIndex[0].FullName = f'Dora UI Sans {weight}'
font.save(root / f'Assets/Font/DoraUISans-{weight}.otf')
