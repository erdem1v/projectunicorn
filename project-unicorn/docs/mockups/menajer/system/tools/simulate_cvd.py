"""Colour-vision previews for page 8: the Ekip skill and morale columns from the standard page (04) and the
colour-blind page (08), each passed through the Machado 2009 deuteranopia matrix (severity 1.0).

  python simulate_cvd.py        writes ../pages/sim_std_deutan.png and ../pages/sim_cb_deutan.png
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
PAGES = os.path.join(HERE, "..", "pages")
sys.path.insert(0, HERE)
from contrast import MACHADO  # noqa: E402

# Same table on both pages: the seven skill columns and the morale column of the five people rows
# (row tops below, 40 px each), stacked without the group headers, 1:1.
CROPS = {"sim_std_deutan.png": ("04_veri.png", (385, 425, 501, 541, 617)),
         "sim_cb_deutan.png": ("08_renk_koru.png", (249, 289, 365, 405, 481))}
# table x0 = 73 on both pages (window or pane edge 48 + 1 + 24): skills + leadership 291..635, morale 1259..1351
SKILLS_X, MORALE_X, ROW = (291, 635), (1259, 1351), 40


def _lut():
    enc = []
    for i in range(4096):
        x = i / 4095
        enc.append(int(round(255 * (12.92 * x if x <= 0.0031308 else 1.055 * x ** (1 / 2.4) - 0.055))))
    return enc


def simulate(im, kind="deutan"):
    m = MACHADO[kind]
    lin = [(c / 255) / 12.92 if c / 255 <= 0.04045 else (((c / 255) + 0.055) / 1.055) ** 2.4 for c in range(256)]
    enc = _lut()
    px = im.convert("RGB").load()
    w, h = im.size
    out = Image.new("RGB", (w, h))
    po = out.load()
    for y in range(h):
        for x in range(w):
            r, g, b = px[x, y]
            l = (lin[r], lin[g], lin[b])
            v = [min(1.0, max(0.0, m[k][0] * l[0] + m[k][1] * l[1] + m[k][2] * l[2])) for k in range(3)]
            po[x, y] = tuple(enc[int(c * 4095)] for c in v)
    return out


if __name__ == "__main__":
    for dst, (src, top) in CROPS.items():
        p = os.path.join(PAGES, src)
        if not os.path.exists(p):
            print("skip", dst, "(no", src + ")")
            continue
        page = Image.open(p)
        w = (SKILLS_X[1] - SKILLS_X[0]) + 12 + (MORALE_X[1] - MORALE_X[0])
        both = Image.new("RGB", (w, ROW * len(top)), page.getpixel((SKILLS_X[0], top[0] + 2)))
        for i, y in enumerate(top):
            both.paste(page.crop((SKILLS_X[0], y, SKILLS_X[1], y + ROW)), (0, i * ROW))
            both.paste(page.crop((MORALE_X[0], y, MORALE_X[1], y + ROW)), (SKILLS_X[1] - SKILLS_X[0] + 12, i * ROW))
        simulate(both).save(os.path.join(PAGES, dst), optimize=True)
        print("wrote", dst)
