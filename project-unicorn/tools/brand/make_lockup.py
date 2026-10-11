"""Writes the brand assets from one geometry and prints it: the lock-up (assets/brand/lockup.svg, the orange square
and "Project" / "Unicorn" in Barlow Condensed Bold, drawn as outlines so no font ships with it) and the app icon
(the square alone: icon.svg, and icon.ico at 16, 32, 48 and 256 px).
    python tools/brand/make_lockup.py
S is the square's side. Corner radius 0.08 S; text size F = S / 1.68, set 0.25 S right of the square; the cap top of
"Project" sits on the square's top edge and the baseline of "Unicorn" on its bottom edge, so cap 0.70 F + line gap
0.28 F + cap 0.70 F = S. The SVG box is the ink box: the "j" dot and the round overshoots poke a few px out of the
square's rows, so the square's top is `square_top` px below the SVG's top.
"""
import math
from pathlib import Path

from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parents[2]
BRAND = ROOT / "assets" / "brand"
S = 128                # the splash's size; every other placement scales the import down
ORANGE = "#FFA028"     # UiTokens.D_BRAND_MARK
INK = "#FFFFFF"        # UiTokens.D_INK_1
ICON = 256

font = TTFont(ROOT / "assets" / "fonts" / "cond" / "BarlowCondensed-Bold.ttf")
glyphs, cmap, hmtx = font.getGlyphSet(), font.getBestCmap(), font["hmtx"]
F = S / 1.68
k = F / font["head"].unitsPerEm
cap = font["OS/2"].sCapHeight * k


def word(text, baseline):
    """Outline path data of `text` in px, set at (1.25 S, baseline), and its ink bounds."""
    pen, ink, x = SVGPathPen(glyphs, lambda v: f"{v:.2f}".rstrip("0").rstrip(".")), BoundsPen(glyphs), S * 1.25
    for ch in text:
        g = cmap[ord(ch)]
        m = (k, 0, 0, -k, x, baseline)
        glyphs[g].draw(TransformPen(pen, m))
        glyphs[g].draw(TransformPen(ink, m))
        x += hmtx[g][0] * k
    return pen.getCommands(), ink.bounds


def square(side):
    return f'<rect width="{side}" height="{side}" rx="{0.08 * side:g}" fill="{ORANGE}"/>'


project, p_box = word("Project", cap)
unicorn, u_box = word("Unicorn", S)
top = math.floor(min(0, p_box[1], u_box[1]))
height = math.ceil(max(S, p_box[3], u_box[3])) - top
width = math.ceil(max(p_box[2], u_box[2]))
(BRAND / "lockup.svg").write_text(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" viewBox="0 {top} {width} {height}">'
    f'{square(S)}<path fill="{INK}" d="{project}{unicorn}"/></svg>\n', encoding="utf-8", newline="\n")
(BRAND / "icon.svg").write_text(
    f'<svg xmlns="http://www.w3.org/2000/svg" width="{ICON}" height="{ICON}">{square(ICON)}</svg>\n', encoding="utf-8", newline="\n")

big = Image.new("RGBA", (ICON * 4, ICON * 4))
ImageDraw.Draw(big).rounded_rectangle((0, 0, ICON * 4 - 1, ICON * 4 - 1), radius=0.08 * ICON * 4, fill=ORANGE)
big.resize((ICON, ICON), Image.Resampling.LANCZOS).save(BRAND / "icon.ico", sizes=[(16, 16), (32, 32), (48, 48), (256, 256)])

cap_top = word("P", cap)[1][1]
baseline = word("n", S)[1][3]
print(f"LOCKUP|S={S}|F={F:.2f}|radius={0.08 * S:.2f}|text_x={S * 1.25:g}|svg={width}x{height}|square_top={-top}"
      f"|square_h={S}|p_cap_top={cap_top:.2f}|unicorn_baseline={baseline:.2f}|cap_to_baseline={baseline - cap_top:.2f}")
