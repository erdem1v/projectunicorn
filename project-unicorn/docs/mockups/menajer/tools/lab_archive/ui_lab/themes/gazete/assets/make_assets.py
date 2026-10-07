"""Draws the gazete nine-slice textures next to this file: python make_assets.py

Colours, slice lines and shadows come from ../direction.gd, so the baked pixels and the theme stay
one set: edit there, then run this again. Everything is drawn at 4x and box-filtered down, so
straight rules land on whole pixels and only the shoulder diagonal and the corner arcs are
anti-aliased. Texture pixels map 1:1 to the screen; the slice margins sit on flat colour, never on
an anti-aliased edge.
"""
import math
import re
from pathlib import Path

from PIL import Image, ImageFilter

S = 4  # supersampling factor
HERE = Path(__file__).parent
SOURCE = (HERE.parent / "direction.gd").read_text("utf-8")

COLOURS = {name: tuple(int(h[i:i + 2], 16) for i in (0, 2, 4))
           for name, h in re.findall(r'^const ([A-Z_]+) := Color\("#([0-9A-Fa-f]{6})"\)', SOURCE, re.M)}
GEOMETRY = {name: [int(v) for v in values.split(",")]
            for name, values in re.findall(r"^const ([A-Z_]+) := \[([0-9, ]+)\]$", SOURCE, re.M)}
PAPER, NEWSPRINT, RULE, INK, RED = (COLOURS[name] for name in ("PAPER", "NEWSPRINT", "RULE", "INK", "RED"))

SHOULDER = GEOMETRY["TAB_SLICE"][1] - 2  # the slanted top-right corner of a folder tab
BAND = GEOMETRY["WINDOW_SLICE"][0] - GEOMETRY["WINDOW_SHADOW"][0] - 2  # outer rule included


def fill(img, pts, value):
    """Even-odd fill by subpixel centre. Pillow's own polygon fill is inclusive on both ends of a
    span, which would widen every right and bottom edge by one subpixel."""
    px = img.load()
    p = [(x * S, y * S) for x, y in pts]
    for row in range(max(0, math.floor(min(y for _, y in p))), min(img.height, math.ceil(max(y for _, y in p)))):
        yc = row + 0.5
        xs = sorted(x0 + (yc - y0) * (x1 - x0) / (y1 - y0)
                    for (x0, y0), (x1, y1) in zip(p, p[1:] + p[:1]) if min(y0, y1) <= yc < max(y0, y1))
        for a, b in zip(xs[::2], xs[1::2]):
            for col in range(max(0, math.ceil(a - 0.5)), min(img.width, math.ceil(b - 0.5))):
                px[col, row] = value


def arc(cx, cy, r, a0, a1, steps=8):
    return [(cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / steps)),
             cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / steps))) for i in range(steps + 1)]


def tab_outline(w, h, inset, open_right, r=2.0):
    """Tab silhouette shrunk by `inset` on its ruled sides; an open right side runs to the edge."""
    right = w if open_right else w - inset
    # The shoulder line x - y = w - SHOULDER, moved inward along its normal.
    k = w - SHOULDER - inset * math.sqrt(2)
    ri = max(r - inset, 0.0)
    pts = arc(inset + ri, inset + ri, ri, 180, 270)
    pts += [(k + inset, inset), (right, right - k)]
    if open_right:
        pts += [(w, h - inset)]
    else:
        pts += arc(right - ri, h - inset - ri, ri, 0, 90)
    pts += arc(inset + ri, h - inset - ri, ri, 90, 180)
    return pts


def window_outline(x0, y0, x1, y1, inset, open_left, r=3.0):
    """Folder band silhouette; the left side is open where the rail's own rule stands in for it."""
    ri = max(r - inset, 0.0)
    left = x0 if open_left else x0 + inset
    pts = [(left, y0 + inset)] if open_left else arc(left + ri, y0 + inset + ri, ri, 180, 270)
    pts += arc(x1 - inset - ri, y0 + inset + ri, ri, 270, 360)
    pts += arc(x1 - inset - ri, y1 - inset - ri, ri, 0, 90)
    pts += [(left, y1 - inset)] if open_left else arc(left + ri, y1 - inset - ri, ri, 90, 180)
    return pts


def rect(x0, y0, x1, y1):
    return [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]


def canvas(w, h):
    return Image.new("RGBA", (w * S, h * S), (0, 0, 0, 0))


def save(img, name):
    img.resize((img.width // S, img.height // S), Image.BOX).save(HERE / name)
    print("wrote", name, img.width // S, "x", img.height // S)


def tab(name, w, h, colour, edge, open_right=False):
    img = canvas(w, h)
    fill(img, tab_outline(w, h, 0, open_right), edge + (255,))
    fill(img, tab_outline(w, h, 1, open_right), colour + (255,))
    save(img, name)


def folder(name, size, room, open_left, offset, sigma, alpha):
    """Band in paper with its outer rule, a hairline around the newsprint page, a soft drop shadow
    in the room [left, top, right, bottom] the texture keeps outside the band."""
    x0, y0, x1, y1 = room[0], room[1], size - room[2], size - room[3]
    outer = window_outline(x0, y0, x1, y1, 0, open_left)
    mask = Image.new("L", (size * S, size * S), 0)
    fill(mask, [(x + offset[0], y + offset[1]) for x, y in outer], int(255 * alpha))
    img = Image.new("RGBA", mask.size, INK + (0,))
    img.putalpha(mask.filter(ImageFilter.GaussianBlur(sigma * S)))
    fill(img, outer, RULE + (255,))
    fill(img, window_outline(x0, y0, x1, y1, 1, open_left), PAPER + (255,))
    fill(img, rect(x0 + BAND, y0 + BAND, x1 - BAND, y1 - BAND), RULE + (255,))
    fill(img, rect(x0 + BAND + 1, y0 + BAND + 1, x1 - BAND - 1, y1 - BAND - 1), NEWSPRINT + (255,))
    save(img, name)


def stamp(name):
    """Print badge: a solid ink block with a paper rule set in by two pixels."""
    img = canvas(16, 16)
    fill(img, rect(0, 0, 16, 16), INK + (255,))
    fill(img, rect(2, 2, 14, 14), PAPER + (255,))
    fill(img, rect(3, 3, 13, 13), INK + (255,))
    save(img, name)


if __name__ == "__main__":
    tab("tab_idle.png", 32, 24, NEWSPRINT, RULE)
    tab("tab_hover.png", 32, 24, NEWSPRINT, RED)
    tab("tab_selected.png", 32, 24, PAPER, RULE, open_right=True)
    tab("tab_selected_closed.png", 32, 24, PAPER, RULE)
    # Window: shadow falls right and down only, so the open left edge meets the rail flush.
    folder("window.png", 64, GEOMETRY["WINDOW_SHADOW"], True, (2, 2), 1.5, 0.22)
    # The closed window (FolderWindow itself): no shadow on the left, so a tab laid over its left
    # slice ends on the page.
    folder("window_closed.png", 64, GEOMETRY["WINDOW_SHADOW"], False, (2, 2), 1.5, 0.22)
    folder("modal.png", 94, GEOMETRY["FOLDER_SHADOW"], False, (0, 4), 5.0, 0.30)
    stamp("stamp.png")
