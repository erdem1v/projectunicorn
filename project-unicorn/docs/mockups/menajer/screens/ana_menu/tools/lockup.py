"""Logo lock-up: orange square at the left, "Project" over "Unicorn" at its right (S = square edge).
Cap tops sit on the square's top edge and the "Unicorn" baseline on its bottom edge: 0.70F + 0.28F + 0.70F = S."""
import os
from fontTools.ttLib import TTFont

FONT = os.path.join(os.path.dirname(os.path.abspath(__file__)), *[".."] * 6, "assets", "fonts", "cond", "BarlowCondensed-Bold.ttf")
_t = TTFont(FONT)
_cmap, _hmtx = _t.getBestCmap(), _t["hmtx"]


def _width(s, f):
    return sum(_hmtx[_cmap[ord(c)]][0] for c in s) / 1000 * f


def lockup(S):
    F = S / 1.68
    gap = round(S * 0.25)
    w = round(S + gap + max(_width("Project", F), _width("Unicorn", F))) + 2
    text = (f"position:absolute;left:{S + gap}px;font-family:'Barlow Condensed';font-weight:700;font-size:{F:.2f}px;"
            f"line-height:{F:.2f}px;color:var(--ink-1);white-space:nowrap;")
    return (f'<div style="position:relative;width:{w}px;height:{S}px;flex:none">'
            f'<i style="position:absolute;left:0;top:0;width:{S}px;height:{S}px;border-radius:{max(4, round(S * 0.08))}px;'
            f'background:var(--brand-mark);display:block"></i>'
            f'<b style="{text}top:{-0.2 * F:.2f}px">Project</b><b style="{text}top:{S - 0.9 * F:.2f}px">Unicorn</b></div>')
