"""Window halo: will Godot's linear StyleBoxFlat shadow band over the dimmed office? (review finding 23)

Godot draws shadow_size as a ring whose vertex alpha runs linearly from shadow_color.a at the box edge to 0,
blended in the 8-bit 2D buffer. This script repeats that over (a) the flattest office colours (the toon floors
and walls, where banding shows first) and (b) a strip of the real office plate, both dimmed by --dim, and
reports how many pixels each 8-bit step spans. It also writes the fallback: a 9-patch alpha texture with an
eased (smoothstep) falloff and ordered dither, for a NinePatchRect behind the window if the probe shows bands.

  python halo.py      writes ../assets/halo_9patch.png (192 x 192, margins 96) and ../pages/halo_check.png
"""
import os
import sys

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SYS = os.path.normpath(os.path.join(HERE, ".."))
sys.path.insert(0, HERE)
from common import ROOT, MENAJER  # noqa: E402
import contrast  # noqa: E402

SIZE = 96
HALO = contrast.to_rgba(ROOT["--halo"][0])           # (10, 8, 6, 0.66)
DIM = float(ROOT["--dim"][0])
BAYER4 = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]


def linear_alpha(d):
    return HALO[3] * max(0.0, 1.0 - d / SIZE)


def eased_alpha(d):
    t = max(0.0, 1.0 - d / SIZE)
    return HALO[3] * t * t * (3 - 2 * t)


def over(bg, a):
    return tuple(int(round(bg[i] * (1 - a) + HALO[i] * a)) for i in range(3))


def bands(bg, fn):
    """Widths in px of the runs of equal 8-bit luma across the 96 px feather over one flat colour."""
    vals = [over(bg, fn(d)) for d in range(SIZE + 1)]
    luma = [round(0.2126 * r + 0.7152 * g + 0.0722 * b) for r, g, b in vals]
    runs, n = [], 1
    for i in range(1, len(luma)):
        if luma[i] == luma[i - 1]:
            n += 1
        else:
            runs.append(n)
            n = 1
    runs.append(n)
    return max(runs), len(set(luma))


def main():
    os.makedirs(os.path.join(SYS, "assets"), exist_ok=True)
    plate = Image.open(os.path.join(MENAJER, "art", "office_full.png")).convert("RGB")
    # the flattest large colours of the plate: floor, wall, asphalt (most common colours)
    counts = plate.resize((480, 270)).getcolors(480 * 270)
    flat = [tuple(int(c * DIM) for c in col) for _, col in sorted(counts, reverse=True)[:3]]
    flat += [tuple(int(c * 0.35) for c in flat[0]), (21, 18, 15)]   # the office at night, and the rail (surface-1)
    lines = ["| Ground (office x %.2f) | Linear: widest 8-bit band | levels | Eased + dither (fallback) |" % DIM, "|---|---|---|---|"]
    for bg in flat:
        w1, n1 = bands(bg, linear_alpha)
        w2, n2 = bands(bg, eased_alpha)
        lines.append("| #%02X%02X%02X | %d px | %d | %d px before dither, dither breaks the edge |" % (tuple(bg) + (w1, n1, w2)))
    print("\n".join(lines))
    # inspection image: the feather over the four flats, contrast x8 around each ground so bands show
    rows = []
    for bg in flat:
        strip = Image.new("RGB", (SIZE * 4, 24))
        px = strip.load()
        for x in range(SIZE * 4):
            d = x / 4
            v = over(bg, linear_alpha(d))
            amp = tuple(max(0, min(255, 128 + (v[i] - bg[i]) * 8)) for i in range(3))
            for y in range(24):
                px[x, y] = amp
        rows.append(strip)
    check = Image.new("RGB", (SIZE * 4, 24 * len(rows) + 8 * (len(rows) - 1)), (16, 14, 11))
    for i, r in enumerate(rows):
        check.paste(r, (0, i * 32))
    check.save(os.path.join(SYS, "pages", "halo_check.png"))
    # fallback 9-patch: 192 x 192 alpha, the window rect is the 0x0 centre, margins 96
    nine = Image.new("RGBA", (2 * SIZE, 2 * SIZE))
    p = nine.load()
    for y in range(2 * SIZE):
        for x in range(2 * SIZE):
            dx = max(0, abs(x - SIZE + 0.5) - 0.5)
            dy = max(0, abs(y - SIZE + 0.5) - 0.5)
            d = (dx * dx + dy * dy) ** 0.5
            a = eased_alpha(d) * 255 + (BAYER4[y % 4][x % 4] / 16.0 - 0.5)
            p[x, y] = (int(HALO[0]), int(HALO[1]), int(HALO[2]), max(0, min(255, int(round(a)))))
    nine.save(os.path.join(SYS, "assets", "halo_9patch.png"))
    return lines


if __name__ == "__main__":
    main()
