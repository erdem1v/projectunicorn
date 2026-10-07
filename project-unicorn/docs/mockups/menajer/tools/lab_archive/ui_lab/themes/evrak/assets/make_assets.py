"""Draws evrak's nine-slice textures at 1:1 (a texture pixel is a screen pixel). Each shape's coverage
is sampled at 4x4 points per pixel, so straight edges on pixel lines stay crisp and slants are
smooth. Colours, slice lines and the frame shadow come from ../direction.gd, so the baked pixels and
the theme stay one set: edit there, then run
    python make_assets.py"""
import re
from pathlib import Path

import numpy as np
from PIL import Image, ImageFilter

HERE = Path(__file__).resolve().parent
SOURCE = (HERE.parent / "direction.gd").read_text("utf-8")
K = 4  # samples per pixel side
CENTRE = 8  # stretched middle of every texture

COLOURS = dict(re.findall(r'^const ([A-Z_]+) := Color\("#([0-9A-Fa-f]{6,8})"\)', SOURCE, re.M))
SLICES = {name: [int(v) for v in values.split(",")]
          for name, values in re.findall(r"^const SLICE_([A-Z_]+) := \[([0-9, ]+)\]", SOURCE, re.M)}
SHADOW_ROOM = int(re.search(r"^const WINDOW_SHADOW := (\d+)$", SOURCE, re.M).group(1))


def rgba(name, alpha=1.0):
    h = COLOURS[name]
    a = int(h[6:8], 16) / 255 if len(h) == 8 else 1.0
    return [int(h[i:i + 2], 16) / 255 for i in (0, 2, 4)] + [min(1.0, a * alpha)]


# --- drawing on a premultiplied float canvas; convex polygons run clockwise on screen --------------

def coverage(img, poly):
    h, w = img.shape[:2]
    ys, xs = np.mgrid[0:h * K, 0:w * K]
    px, py = (xs + 0.5) / K, (ys + 0.5) / K
    inside = np.ones(px.shape, bool)
    for (x1, y1), (x2, y2) in zip(poly, poly[1:] + poly[:1]):
        inside &= (x2 - x1) * (py - y1) - (y2 - y1) * (px - x1) >= 0
    return inside.reshape(h, K, w, K).mean(axis=(1, 3))


def paint(img, alpha, colour):
    a = alpha * colour[3]
    img[:] = np.dstack([a * c for c in colour[:3]] + [a]) + img * (1 - a)[..., None]


def fill(img, poly, colour):
    paint(img, coverage(img, poly), colour)


def punch(img, poly):
    img *= (1 - coverage(img, poly))[..., None]


def inset(poly, offsets):
    """Moves edge i (poly[i] -> poly[i+1]) inward by offsets[i]."""
    lines = []
    for (x1, y1), (x2, y2), d in zip(poly, poly[1:] + poly[:1], offsets):
        dx, dy = x2 - x1, y2 - y1
        length = np.hypot(dx, dy)
        lines.append(((x1 - dy / length * d, y1 + dx / length * d), (dx, dy)))
    out = []
    for (p, r), (q, s) in zip(lines[-1:] + lines[:-1], lines):
        t = ((q[0] - p[0]) * s[1] - (q[1] - p[1]) * s[0]) / (r[0] * s[1] - r[1] * s[0])
        out.append((p[0] + r[0] * t, p[1] + r[1] * t))
    return out


def save(img, name):
    a = img[..., 3:]
    rgb = np.where(a > 0, img[..., :3] / np.maximum(a, 1e-6), 0)
    Image.fromarray(np.round(np.dstack([rgb, a]) * 255).astype(np.uint8), "RGBA").save(HERE / name)
    print("%-20s %dx%d" % (name, img.shape[1], img.shape[0]))


# --- folder tabs: a rectangle whose top-right shoulder is cut on a slant --------------------------

def tab(name, slice_name, face, edge, open_right=False):
    """The shoulder fills the top-right slice corner but its last 2 px. An open tab has no right
    edge: its manila runs on into the window band it joins."""
    left, top, right, bottom = SLICES[slice_name]
    w, h = left + CENTRE + right, top + CENTRE + bottom
    shape = [(0, 0), (w - (right - 2), 0), (w, top - 2), (w, h), (0, h)]
    img = np.zeros((h, w, 4))
    fill(img, shape, rgba(edge))
    fill(img, inset(shape, [1, 1, 0 if open_right else 1, 1, 1]), rgba(face))
    save(img, name)


# --- the folder frame: a soft shadow, the manila band, the paper page lying on it -----------------

def window(name, slice_name, left_edge="shadow"):
    """left_edge "shadow": closed, shadowed all round (modals). "flush": closed with no shadow on the
    left, so a selected tab laid over the left slice ends on the page (FolderWindow). "open": the
    real window, whose left edge is the rail's right rule, so no outline or shadow on that side."""
    left, top, right, bottom = SLICES[slice_name]
    band = top - SHADOW_ROOM - 2
    w, h = left + CENTRE + right, top + CENTRE + bottom
    x0 = {"shadow": SHADOW_ROOM, "flush": 0, "open": -2 * SHADOW_ROOM}[left_edge]  # open runs past the edge
    x1, y0, y1 = w - SHADOW_ROOM, SHADOW_ROOM, h - SHADOW_ROOM
    img = np.zeros((h, w, 4))

    drop = np.zeros((h, w))
    drop[y0 + 2:y1 + 2, max(x0, 0):x1] = 1.0
    blurred = Image.fromarray((drop * 255).astype(np.uint8), "L").filter(ImageFilter.GaussianBlur(3))
    paint(img, np.asarray(blurred) / 255, rgba("SHADOW", 1.8))

    frame = [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
    fill(img, frame, rgba("FOLDER_EDGE"))
    fill(img, inset(frame, [1, 1, 1, 0 if left_edge == "open" else 1]), rgba("MANILA"))
    sx0 = max(x0, 0) + band
    sheet = [(sx0, y0 + band), (x1 - band, y0 + band), (x1 - band, y1 - band), (sx0, y1 - band)]
    fill(img, [(x + 1, y + 1) for x, y in sheet], rgba("FOLDER_EDGE", 0.28))
    fill(img, sheet, rgba("EDGE"))
    fill(img, inset(sheet, [1, 1, 1, 1]), rgba("PAPER"))
    save(img, name)


# --- the rubber stamp: a double rule in stamp ink, empty inside -----------------------------------

def stamp(name):
    s = SLICES["STAMP"][0] * 2 + CENTRE
    square = [(0, 0), (s, 0), (s, s), (0, s)]
    ink = rgba("STAMP", 0.92)
    img = np.zeros((s, s, 4))
    fill(img, square, ink)
    punch(img, inset(square, [2] * 4))
    fill(img, inset(square, [3] * 4), ink)
    punch(img, inset(square, [4] * 4))
    save(img, name)


if __name__ == "__main__":
    tab("tab_idle.png", "TAB", "MANILA_DEEP", "FOLDER_EDGE")
    tab("tab_hover.png", "TAB", "MANILA_DEEP", "INK")
    tab("tab_selected.png", "TAB", "MANILA", "FOLDER_EDGE", open_right=True)
    tab("chip_idle.png", "CHIP", "PAPER", "EDGE_HOVER")
    tab("chip_hover.png", "CHIP", "PAPER", "INK")
    tab("chip_selected.png", "CHIP", "MANILA", "FOLDER_EDGE")
    window("window.png", "WINDOW", "flush")
    window("modal.png", "MODAL")
    window("window_open.png", "WINDOW", "open")
    stamp("stamp.png")
