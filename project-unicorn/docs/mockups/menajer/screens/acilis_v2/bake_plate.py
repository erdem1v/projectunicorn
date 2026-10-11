"""Evening grade of the approved daytime Ev plate (art/office_safe_1920_home_noicons.png), read only.
Writes art/ev_aksam.png next to this file. Ambient goes cool and low, the room's own lamps (floor lamp,
two bedside lamps, kitchen pendant) become warm pools that light the albedo; corners fall off. No facade
window is lit (that is a night-material task, not a grade). Godot equivalent: --office-shot=home:19:30 or a
MenuBackdrop capture with no people; this bake only stands in for that render in the mockups."""
import os
import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SRC = os.path.join(HERE, "..", "..", "art", "office_safe_1920_home_noicons.png")
im = np.asarray(Image.open(SRC).convert("RGB")).astype(np.float32) / 255.0
h, w, _ = im.shape
yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)

light = np.zeros_like(im)
light += np.array([0.20, 0.22, 0.28], np.float32)            # dusk ambient, cool and low
warm = np.array([1.00, 0.74, 0.46], np.float32)
# (x, y, radius, strength): the floor lamp by the sofa, the two bedside lamps, the kitchen pendant
for x, y, r, s in [(1090, 470, 250, 1.0), (1140, 585, 110, 0.5), (1003, 662, 110, 0.5), (1060, 230, 170, 0.26), (770, 260, 140, 0.2)]:
    g = np.exp(-(((xx - x) ** 2 + ((yy - y) * 1.35) ** 2) / (r * r)))
    light += g[..., None] * s * warm
out = im * light
# the shades themselves glow
for x, y, r, s in [(1100, 482, 18, 0.9), (1140, 568, 10, 0.6), (1003, 648, 10, 0.6)]:
    g = np.exp(-(((xx - x) ** 2 + (yy - y) ** 2) / (r * r)))
    out += g[..., None] * s * np.array([1.0, 0.86, 0.62], np.float32)
# corners fall off (vignette centred on the living room)
d = np.sqrt(((xx - 1050) / (w * 0.62)) ** 2 + ((yy - 470) / (h * 0.70)) ** 2)
out *= np.clip(1.15 - 0.85 * d, 0.25, 1.0)[..., None]
out = np.clip(out, 0, 1)
os.makedirs(os.path.join(HERE, "art"), exist_ok=True)
Image.fromarray((out * 255 + 0.5).astype(np.uint8)).save(os.path.join(HERE, "art", "ev_aksam.png"))
print("ok")
