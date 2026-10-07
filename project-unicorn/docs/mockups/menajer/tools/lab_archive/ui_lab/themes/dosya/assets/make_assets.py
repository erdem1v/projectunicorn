"""Draws the Dosya nine-slice textures, one texture pixel per screen pixel.

Colours, slice lines and shadow rooms are read from ../direction.gd, so the PNGs and the theme stay
one set. Every texture is sampled 8 x 8 times per pixel with exact half-plane tests, composited in
premultiplied alpha and box-filtered down: diagonals and shadows get smooth edges without dark
fringes. Every anti-aliased or shaded pixel lies inside a corner patch or across an edge patch, so
only flat folder and flat paper are stretched; the one exception is window_closed.png, whose
one-texel left slice lets the page shade's first 1/255 step into the stretched bottom band.

Run from this folder: python make_assets.py
"""
import math
import re
from pathlib import Path

import numpy as np
from PIL import Image

HERE = Path(__file__).resolve().parent
SOURCE = (HERE.parent / "direction.gd").read_text(encoding="utf-8")
K = 8


def palette() -> dict:
    colours = {}
    for name, hexv in re.findall(r'^const (\w+) := Color\("#([0-9A-Fa-f]{6,8})"\)', SOURCE, re.M):
        hexv = hexv if len(hexv) == 8 else hexv + "ff"
        colours[name] = np.array([int(hexv[i:i + 2], 16) / 255 for i in (0, 2, 4, 6)])
    return colours


C = palette()
G = {name: [int(v) for v in values.split(",")]
     for name, values in re.findall(r"^const (\w+) := \[([0-9, ]+)\]$", SOURCE, re.M)}


def faded(colour, alpha: float):
    return np.array([colour[0], colour[1], colour[2], alpha])


class Canvas:
    """Premultiplied RGBA, K x K samples per texture pixel."""

    def __init__(self, w: int, h: int):
        self.w, self.h = w, h
        self.px = np.zeros((h * K, w * K, 4))
        ys, xs = np.mgrid[0:h * K, 0:w * K]
        self.x = (xs + 0.5) / K
        self.y = (ys + 0.5) / K

    def over(self, mask, colour) -> None:
        a = mask * colour[3]
        self.px = np.dstack([colour[0] * a, colour[1] * a, colour[2] * a, a]) + self.px * (1 - a)[..., None]

    def rect(self, x0, y0, x1, y1):
        return ((self.x >= x0) & (self.x < x1) & (self.y >= y0) & (self.y < y1)).astype(float)

    def polygon(self, points, inset=None):
        """Samples inside a convex polygon listed clockwise (y down), edge i moved in by inset[i]."""
        inset = inset or [0] * len(points)
        inside = np.ones_like(self.x, dtype=bool)
        for i, (x0, y0) in enumerate(points):
            x1, y1 = points[(i + 1) % len(points)]
            length = math.hypot(x1 - x0, y1 - y0)
            inside &= ((self.x - x0) * -(y1 - y0) + (self.y - y0) * (x1 - x0)) / length >= inset[i]
        return inside.astype(float)

    def save(self, name: str) -> None:
        img = self.px.reshape(self.h, K, self.w, K, 4).mean(axis=(1, 3))
        alpha = img[..., 3:]
        rgb = np.where(alpha > 0, img[..., :3] / np.maximum(alpha, 1e-9), 0)
        out = np.round(np.concatenate([rgb, alpha], axis=2) * 255).astype(np.uint8)
        Image.fromarray(out, "RGBA").save(HERE / name)
        print("wrote", name, self.w, "x", self.h)


def blur(mask, sigma: float):
    radius = int(3 * sigma * K)
    t = np.arange(-radius, radius + 1) / K
    kernel = np.exp(-t * t / (2 * sigma * sigma))
    kernel /= kernel.sum()
    mask = np.apply_along_axis(np.convolve, 0, mask, kernel, "same")
    return np.apply_along_axis(np.convolve, 1, mask, kernel, "same")


def tab(name: str, w: int, h: int, slice_name: str, fill, line, open_right=False) -> None:
    """A rectangle with its top-right corner cut at 45 degrees, a 1 px rule inside its edge. The
    selected rail tab leaves its right side open: it runs into the folder frame there."""
    shoulder = G[slice_name][2] - 2
    cv = Canvas(w, h)
    shape = [(0, 0), (w - shoulder, 0), (w, shoulder), (w, h), (0, h)]
    cv.over(cv.polygon(shape), line)
    cv.over(cv.polygon(shape, [1, 1, 0 if open_right else 1, 1, 1]), fill)
    cv.save(name)


def folder(name: str, side: int, slice_name: str, room_name: str, left_rule: bool, shadow: tuple) -> None:
    """A folder lying open: a band of folder grey with a rule on its outer edge, a paper page inside
    it edged by a hairline and lifted by a faint shade, and a drop shadow in the shadow room.
    Without a left rule the frame stands on the rail, whose own rule is its edge there.
    shadow = (dx, dy, sigma, alpha)."""
    room = G[room_name]
    band = G[slice_name][1] - room[1] - 4
    cv = Canvas(side, side)
    x0, y0, x1, y1 = room[0], room[1], side - room[2], side - room[3]
    dx, dy, sigma, alpha = shadow
    cv.over(blur(cv.rect(x0 + dx, y0 + dy, x1 + dx, y1 + dy), sigma), faded(C["INK"], alpha))
    cv.over(cv.rect(x0, y0, x1, y1), C["RULE_DARK"])
    cv.over(cv.rect(x0 + (1 if left_rule else 0), y0 + 1, x1 - 1, y1 - 1), C["FOLDER"])
    px0, py0, px1, py1 = x0 + band, y0 + band, x1 - band, y1 - band
    cv.over(blur(cv.rect(px0 + 1, py0 + 1, px1 + 1, py1 + 1), 0.8), faded(C["INK"], 0.10))
    cv.over(cv.rect(px0, py0, px1, py1), C["RULE"])
    cv.over(cv.rect(px0 + 1, py0 + 1, px1 - 1, py1 - 1), C["PAPER"])
    cv.save(name)


# Rail tabs, 76 x 64 on the rail.
tab("tab_idle.png", 40, 32, "TAB_SLICE", C["FOLDER_DEEP"], C["RULE_DARK"])
tab("tab_idle_hover.png", 40, 32, "TAB_SLICE", C["FOLDER_DEEP"], C["INK_DIM"])
tab("tab_selected.png", 40, 32, "TAB_SLICE", C["FOLDER"], C["RULE_DARK"], open_right=True)
# Sales band selector, 19 px tall.
tab("chip_idle.png", 20, 16, "CHIP_SLICE", C["FOLDER_DEEP"], C["RULE_DARK"])
tab("chip_idle_hover.png", 20, 16, "CHIP_SLICE", C["FOLDER_DEEP"], C["INK_DIM"])
tab("chip_selected.png", 20, 16, "CHIP_SLICE", C["PAPER"], C["INK"])
# Modals float free: ruled on four sides, shadowed all round.
folder("folder.png", 80, "FOLDER_SLICE", "FOLDER_SHADOW", True, (0, 2, 2.5, 0.30))
# WindowPanel stands on the rail, whose rule is its left edge; FolderWindow is the same frame closed.
folder("window.png", 64, "WINDOW_SLICE", "WINDOW_SHADOW", False, (1, 2, 1.5, 0.22))
folder("window_closed.png", 64, "CLOSED_SLICE", "WINDOW_SHADOW", True, (1, 2, 1.5, 0.22))
