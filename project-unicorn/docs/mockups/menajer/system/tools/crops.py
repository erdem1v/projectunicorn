"""Avatar and portrait crops from a bust or portrait render (SPEC §3.5 "Avatar kırpımı", review finding 11).

The rule is defined on the figure, not on the file, so it survives a re-shoot with different framing:
  top    first row whose alpha passes 50 % (the hair top; 0 when the render clips the head)
  neck   the narrowest silhouette row between 25 % and 70 % of the figure height
  head   hh = neck - top; head centre x = mean midpoint of the rows from 30 % to 85 % of hh
Crops (source rectangles, then scaled to the target size):
  (the head itself, crown to chin, is about 0.91 hh in the 3D characters)
  disc S (24, 32, 40, 48)   head and neck: diameter = hh / 0.77, centre y = top + 0.55 hh   (head ~70 % of the disc)
  disc L (64, 96)           head and shoulders: diameter = hh / 0.55, centre y = top + 0.78 hh
  card 4:5 (256x320 well, 260x325 onboarding)  hh = 53 % of the card height (crown to chin ~48 %, a 0.48 m
                            studio frame), crown 6 % below the card top
Faz C bakes exactly these crops (with the lit ground baked in); the sheet positions the large render with CSS.

  python crops.py <png> ...      print the measured figure and the crop boxes
"""
import json
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
CACHE = os.path.join(HERE, "crops_cache.json")


def figure(path):
    st = os.stat(path)
    key = "%s|%d|%d" % (os.path.abspath(path), st.st_size, int(st.st_mtime))
    cache = json.load(open(CACHE, encoding="utf-8")) if os.path.exists(CACHE) else {}
    if key in cache:
        return cache[key]
    im = Image.open(path).convert("RGBA")
    w, h = im.size
    a = im.split()[3].load()
    rows = []
    for y in range(h):
        xs = [x for x in range(0, w, 2) if a[x, y] > 128]
        rows.append((xs[0], xs[-1]) if xs else None)
    top = next(y for y in range(h) if rows[y])
    bot = max(y for y in range(h) if rows[y])
    span = bot - top
    lo, hi = top + int(0.25 * span), top + int(0.70 * span)
    neck = min(range(lo, hi), key=lambda y: (rows[y][1] - rows[y][0]) if rows[y] else 1e9)
    hh = neck - top
    mids = [(rows[y][0] + rows[y][1]) / 2 for y in range(top + int(0.30 * hh), top + int(0.85 * hh)) if rows[y]]
    cx = sum(mids) / len(mids)
    fig = {"w": w, "h": h, "top": top, "neck": neck, "hh": hh, "cx": cx}
    cache[key] = fig
    json.dump(cache, open(CACHE, "w", encoding="utf-8"), indent=0)
    return fig


def disc_box(path, size):
    """Source square (x, y, d) for a disc avatar of `size` px."""
    f = figure(path)
    if size <= 48:
        d, cy = f["hh"] / 0.77, f["top"] + 0.55 * f["hh"]
    else:
        d, cy = f["hh"] / 0.55, f["top"] + 0.78 * f["hh"]
    return f["cx"] - d / 2, cy - d / 2, d


def card_box(path, w, h):
    """Source rectangle (x, y, sw, sh) for a 4:5 portrait card of w x h px."""
    f = figure(path)
    s = 0.53 * h / f["hh"]
    sw, sh = w / s, h / s
    return f["cx"] - sw / 2, f["top"] - 0.06 * h / s, sw, sh


def css_img(path, rel, box_w, box_h, src):
    """<img> style that shows the source rectangle src=(x, y, sw, sh) of `path` in a box_w x box_h box."""
    f = figure(path)
    x, y, sw, sh = src
    k = box_w / sw
    return ('<img src="%s" alt="" style="position:absolute;width:%.1fpx;height:%.1fpx;left:%.1fpx;top:%.1fpx">'
            % (rel, f["w"] * k, f["h"] * k, -x * k, -y * k))


if __name__ == "__main__":
    for p in sys.argv[1:]:
        print(p, figure(p), "disc32", [round(v, 1) for v in disc_box(p, 32)], "card", [round(v, 1) for v in card_box(p, 256, 320)])
