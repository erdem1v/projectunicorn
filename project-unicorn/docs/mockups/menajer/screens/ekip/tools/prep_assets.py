"""Derived art for the ekip frames (written only into ../assets/).

The three Atlas candidates of the HR seed (Deniz Aksoy, Arda Arslan, Ece Erdem) have no bust in art/: their
looks are generated per search by HRSearchSystem. The only render of them is the 34 px avatar in
baseline/hr__dosyalar.png. This cuts those discs out, keys the old ground (#1B232B) and anything outside the
disc to transparent and scales them x4 once, so the frames can put them on the system's lit avatar ground.

  python prep_assets.py
"""
import os

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MEN = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.normpath(os.path.join(HERE, "..", "assets"))
GROUND = (27, 35, 43)
# disc centres in the baseline frame (x of the card's avatar, measured on the 1920 frame), radius 17
DISCS = [(221, 392), (731, 392), (1241, 392)]
R = 17


def main():
    os.makedirs(OUT, exist_ok=True)
    im = Image.open(os.path.join(MEN, "baseline", "hr__dosyalar.png")).convert("RGB")
    for i, (cx, cy) in enumerate(DISCS):
        box = (cx - R - 1, cy - R - 1, cx + R + 1, cy + R + 1)
        src = im.crop(box)
        w, h = src.size
        out = Image.new("RGBA", (w, h))
        for y in range(h):
            for x in range(w):
                r, g, b = src.getpixel((x, y))
                d = ((x + 0.5 - w / 2) ** 2 + (y + 0.5 - h / 2) ** 2) ** 0.5
                near = abs(r - GROUND[0]) + abs(g - GROUND[1]) + abs(b - GROUND[2])
                if d > R - 2.0:
                    a = 0
                elif near < 18:
                    a = 0
                elif near < 36:
                    a = int(255 * (near - 18) / 18)
                else:
                    a = 255
                out.putpixel((x, y), (r, g, b, a))
        out = out.resize((w * 4, h * 4), Image.LANCZOS)
        out.save(os.path.join(OUT, "cand_%d.png" % i))
        print("cand_%d.png" % i, out.size)


if __name__ == "__main__":
    main()
