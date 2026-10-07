"""Turns capture_menajer.gd's raw renders (scratchpad/menajer_raw) into the mockup PNGs.

    python post_art.py busts        art/busts/<vc|prospect|crowd40>/*.png, straight alpha
    python post_art.py portraits    portraits/*.png (4:5 at 640x800, faces), straight alpha
    python post_art.py sheets       portraits/sheet_frank.png, portraits/sheet_founders.png

The studio viewport is transparent: alpha is close to binary at render size (the ink quad's
cutout), colour is premultiplied where alpha is partial, and a few partial pixels carry straight
colour (a channel above alpha). Downsampling happens on premultiplied colour, then the colour is
divided back out, so no dark or light fringe is left on any background.
"""
import json
import os
import sys

import numpy as np
from PIL import Image

RAW = "C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/0e406678-a661-4d23-90af-2e43deb375cc/scratchpad/menajer_raw/"
ROOT = "C:/Users/erdem/Desktop/project steam/project-unicorn/docs/mockups/menajer/"
FOUNDERS = "C:/Users/erdem/Desktop/project steam/project-unicorn/assets/art/founders/"
SHEET_BG = (0x1E, 0x1B, 0x18)


def premult(path):
    """Raw render -> float premultiplied RGBA in 0..1."""
    a = np.asarray(Image.open(path).convert("RGBA")).astype(np.float64) / 255.0
    rgb, al = a[..., :3], a[..., 3:4]
    straight = (rgb.max(axis=2, keepdims=True) > al + 1e-9) & (al > 0)
    rgb = np.where(straight, rgb * al, rgb)
    rgb = np.where(al > 0, rgb, 0.0)
    return np.concatenate([rgb, al], axis=2)


def reduce(p, k):
    """Box filter by an integer factor, on premultiplied colour."""
    if k == 1:
        return p
    h, w = p.shape[0] // k * k, p.shape[1] // k * k
    return p[:h, :w].reshape(h // k, k, w // k, k, 4).mean(axis=(1, 3))


def resize(p, size):
    """Lanczos resize on premultiplied colour (non integer factors), clamped."""
    out = []
    for c in range(4):
        ch = Image.fromarray((p[..., c] * 65535).astype(np.uint16).astype(np.int32), mode="I")
        ch = ch.resize(size, Image.LANCZOS)
        out.append(np.asarray(ch).astype(np.float64) / 65535.0)
    q = np.clip(np.stack(out, axis=2), 0.0, 1.0)
    q[..., :3] = np.minimum(q[..., :3], q[..., 3:4])
    return q


def straight_image(p):
    al = p[..., 3:4]
    rgb = np.where(al > 1e-6, p[..., :3] / np.maximum(al, 1e-6), 0.0)
    out = np.concatenate([np.clip(rgb, 0, 1), al], axis=2)
    return Image.fromarray((out * 255.0 + 0.5).astype(np.uint8), "RGBA")


def stats(p):
    al = p[..., 3]
    return "opaque=%d partial=%d" % ((al >= 0.999).sum(), ((al > 0) & (al < 0.999)).sum())


def busts():
    n = 0
    for sub in ("vc", "prospect", "crowd40"):
        src = RAW + "busts/" + sub + "/"
        dst = ROOT + "art/busts/" + sub + "/"
        os.makedirs(dst, exist_ok=True)
        for f in sorted(os.listdir(src)):
            straight_image(premult(src + f)).save(dst + f)
            n += 1
    print("busts", n)


def portraits():
    src = RAW + "portraits/"
    dst = ROOT + "portraits/"
    os.makedirs(dst, exist_ok=True)
    meta = json.load(open(src + "meta.json", encoding="utf-8"))
    names = sorted(meta["looks"])
    for name in names:
        big = premult(src + name + ".png")
        out = reduce(big, 2)
        straight_image(out).save(dst + name + ".png")
        # The face at the game's bust framing: a 128 render read down to 64, as an in-game
        # 64 px avatar is drawn (PersonBust renders 2x and the filter reads it down).
        face = reduce(premult(src + name + "_face128.png"), 2)
        straight_image(face).save(dst + name + "_face64.png")
        face32 = reduce(premult(src + name + "_face64r.png"), 2)
        straight_image(face32).save(dst + name + "_face32.png")
        print(name, out.shape[1], out.shape[0], stats(out))
    frank = {k[len("frank_cand_"):]: v for k, v in meta["looks"].items() if k.startswith("frank_cand_")}
    if frank:
        studio = {k: v for k, v in meta.items() if k != "looks"}
        json.dump({"studio": studio, "looks": frank}, open(dst + "frank_looks.json", "w", encoding="utf-8"),
                  indent=2, ensure_ascii=False)


def comp(img, bg, size):
    base = Image.new("RGBA", size, bg + (255,))
    im = img.resize(size, Image.LANCZOS) if img.size != size else img
    base.alpha_composite(im)
    return base


FONT = "C:/Users/erdem/Desktop/project steam/project-unicorn/assets/fonts/sans/IBMPlexSans-SemiBold.ttf"
INK2 = (0xB3, 0xAA, 0x9E)
WELL = (0x16, 0x12, 0x0F)


def sheets():
    from PIL import ImageDraw, ImageFont
    font = ImageFont.truetype(FONT, 16)
    small = ImageFont.truetype(FONT, 12)
    dst = ROOT + "portraits/"
    raw = RAW + "portraits/"
    # Frank: four candidates at the reading pane size (256x320) and at the 64 and 32 px faces.
    cands = [c for c in "abcd" if os.path.exists(dst + "frank_cand_%s.png" % c)]
    pad = 24
    w = pad + len(cands) * (256 + pad)
    sheet = Image.new("RGBA", (w, pad + 24 + 320 + 16 + 64 + 18 + pad), SHEET_BG + (255,))
    d = ImageDraw.Draw(sheet)
    for i, c in enumerate(cands):
        x = pad + i * (256 + pad)
        d.text((x, pad - 4), c.upper(), font=font, fill=INK2)
        p = reduce(premult(raw + "frank_cand_%s.png" % c), 5)          # 1280x1600 -> 256x320
        sheet.alpha_composite(straight_image(p), (x, pad + 24))
        y = pad + 24 + 320 + 16
        sheet.alpha_composite(Image.open(dst + "frank_cand_%s_face64.png" % c), (x, y))
        sheet.alpha_composite(Image.open(dst + "frank_cand_%s_face32.png" % c), (x + 64 + 16, y + 32))
        d.text((x, y + 64 + 2), "64", font=small, fill=INK2)
        d.text((x + 64 + 16, y + 64 + 2), "32", font=small, fill=INK2)
    sheet.convert("RGB").save(dst + "sheet_frank.png")
    # Founders: each painted portrait beside its pre-render on the portrait well, both 256x320.
    ids = ["founder_%02d" % i for i in range(1, 12)]
    cw = 256 * 2 + 8
    cols = 4
    rows = (len(ids) + cols - 1) // cols
    fs = Image.new("RGBA", (pad + cols * (cw + pad), pad + rows * (24 + 320 + pad)), SHEET_BG + (255,))
    d = ImageDraw.Draw(fs)
    for i, fid in enumerate(ids):
        x = pad + (i % cols) * (cw + pad)
        y = pad + (i // cols) * (24 + 320 + pad)
        d.text((x, y - 4), fid, font=font, fill=INK2)
        paint = Image.open(FOUNDERS + fid + ".webp").convert("RGBA").resize((256, 320), Image.LANCZOS)
        fs.alpha_composite(paint, (x, y + 24))
        p = reduce(premult(raw + fid + ".png"), 5)
        fs.alpha_composite(comp(straight_image(p), WELL, (256, 320)), (x + 264, y + 24))
        f32 = Image.open(dst + fid + "_face32.png")
        fs.alpha_composite(comp(f32, (0x1B, 0x23, 0x2B), (32, 32)), (x + 264 + 256 - 40, y + 24 + 320 - 40))
    fs.convert("RGB").save(dst + "sheet_founders.png")
    print("sheets", sheet.size, fs.size)


if __name__ == "__main__":
    for cmd in sys.argv[1:]:
        {"busts": busts, "portraits": portraits, "sheets": sheets}[cmd]()
