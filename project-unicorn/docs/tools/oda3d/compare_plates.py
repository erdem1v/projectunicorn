"""ODA 3D spike — plate comparison: sealed proof | Godot render, with the layout-contract rects
drawn on both, plus per-region statistics so exposure/tint decisions are made from numbers.

usage:
  python docs/tools/oda3d/compare_plates.py --sealed <proof.png> --render <plate.png> \
         --out <side_by_side.png> [--label "day"] [--rects] [--json <stats.json>]

Regions are normalized [x, y, w, h] on the 16:9 frame (same convention as OdaLayout.RECTS).
"""
import argparse, json, os, sys
from PIL import Image, ImageDraw, ImageFont
import numpy as np

# Layout contract, copied from scripts/ui/oda/oda_layout.gd RECTS (hosts) — drawn as overlays.
CONTRACT = {
    "board_outer":   (0.3400, 0.0392, 0.3762, 0.4515),
    "board_inner":   (0.3550, 0.0669, 0.3459, 0.3994),
    "frames_band":   (0.0191, 0.0596, 0.2734, 0.1517),
    "window":        (0.9000, 0.0000, 0.1000, 0.8070),
    "monitor":       (0.27370, 0.44028, 0.24349, 0.40324),
    "lamp":          (0.01250, 0.60046, 0.08802, 0.23426),
    "mug":           (0.56901, 0.80648, 0.04531, 0.08102),
    "phone":         (0.51458, 0.89583, 0.03281, 0.04907),
    "keyboard":      (0.30286, 0.86898, 0.14089, 0.04213),
    "papers_zone":   (0.120, 0.836, 0.170, 0.142),
}

# Measurement patches: flat, single-material areas that are lit the same way in both plates.
REGIONS = {
    "wall_between_frames_and_board": (0.300, 0.10, 0.035, 0.16),
    "wall_right_of_board":           (0.735, 0.20, 0.06, 0.20),
    "cork_lower_right":              (0.600, 0.30, 0.08, 0.10),
    "desk_below_keyboard":           (0.420, 0.93, 0.06, 0.04),
    "desk_right_front":              (0.640, 0.92, 0.05, 0.04),
    "monitor_glass":                 (0.300, 0.47, 0.18, 0.25),
    "window_glass":                  (0.935, 0.05, 0.05, 0.20),
    "frame_backing_0":               (0.030, 0.075, 0.045, 0.11),
    "lamp_shade":                    (0.055, 0.60, 0.04, 0.05),
    "mug_body":                      (0.575, 0.83, 0.03, 0.04),
    "wall_top_left":                 (0.02, 0.005, 0.25, 0.04),
    "wall_below_board":              (0.55, 0.60, 0.15, 0.10),
    "desk_in_shadow_left":           (0.225, 0.87, 0.04, 0.04),
    "wall_in_shadow_left_of_board":  (0.300, 0.42, 0.035, 0.06),
    "full_frame":                    (0.0, 0.0, 1.0, 1.0),
}


def load(p):
    im = Image.open(p).convert("RGB")
    return im


def region_stats(im, r):
    W, H = im.size
    x, y, w, h = r
    box = (int(x * W), int(y * H), int((x + w) * W), int((y + h) * H))
    a = np.asarray(im.crop(box)).astype(np.float64)
    mean = a.reshape(-1, 3).mean(axis=0)
    mx = a.reshape(-1, 3).max(axis=0)
    lum = 0.2126 * mean[0] + 0.7152 * mean[1] + 0.0722 * mean[2]
    lum_px = 0.2126 * a[..., 0] + 0.7152 * a[..., 1] + 0.0722 * a[..., 2]
    std = float(lum_px.std())
    # fraction of pixels with any channel >= 254 (clipping)
    clip = float((a.max(axis=2) >= 254).mean())
    return {"mean": [round(float(v), 1) for v in mean], "max": [int(v) for v in mx],
            "lum": round(float(lum), 1), "lum_std": round(std, 1), "clip_frac": round(clip, 4)}


def draw_rects(im, color=(255, 64, 64), width=3, font=None):
    d = ImageDraw.Draw(im)
    W, H = im.size
    for k, (x, y, w, h) in CONTRACT.items():
        d.rectangle([x * W, y * H, (x + w) * W, (y + h) * H], outline=color, width=width)
        d.text((x * W + 4, y * H + 2), k, fill=color, font=font)
    return im


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sealed", required=True)
    ap.add_argument("--render", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--label", default="")
    ap.add_argument("--rects", action="store_true", help="draw contract rects on both halves")
    ap.add_argument("--width", type=int, default=1920, help="per-half width of the side-by-side")
    ap.add_argument("--json", default="")
    a = ap.parse_args()

    s = load(a.sealed)
    r = load(a.render)
    # stats at a common size (the render's native, sealed resized to it) — statistics on means
    # are scale-invariant, so 1080p halves are enough for the numbers.
    W = a.width; H = W * 9 // 16
    s1 = s.resize((W, H), Image.LANCZOS)
    r1 = r.resize((W, H), Image.LANCZOS)
    stats = {}
    for k, reg in REGIONS.items():
        ss = region_stats(s1, reg); rs = region_stats(r1, reg)
        ratio = [round(rs["mean"][i] / max(ss["mean"][i], 1e-6), 3) for i in range(3)]
        stats[k] = {"sealed": ss, "render": rs, "ratio_render_over_sealed": ratio,
                    "lum_ratio": round(rs["lum"] / max(ss["lum"], 1e-6), 3)}
    # composite
    try:
        font = ImageFont.truetype("arial.ttf", 22)
    except Exception:
        font = None
    left = s1.copy(); right = r1.copy()
    if a.rects:
        draw_rects(left, font=font); draw_rects(right, font=font)
    canvas = Image.new("RGB", (W * 2 + 8, H + 40), (20, 20, 20))
    canvas.paste(left, (0, 40)); canvas.paste(right, (W + 8, 40))
    d = ImageDraw.Draw(canvas)
    d.text((10, 8), "SEALED (three.js proof) %s" % a.label, fill=(230, 230, 230), font=font)
    d.text((W + 18, 8), "GODOT 4.6 3D %s" % a.label, fill=(230, 230, 230), font=font)
    canvas.save(a.out)
    print("wrote", a.out)
    print("%-30s %-21s %-21s %-21s %s" % ("region", "sealed mean RGB", "render mean RGB", "ratio R/G/B", "lum ratio | std s/r | clip%"))
    for k, v in stats.items():
        print("%-30s %-21s %-21s %-21s %.3f | %.1f/%.1f | %.1f%%" % (k, v["sealed"]["mean"], v["render"]["mean"], v["ratio_render_over_sealed"], v["lum_ratio"], v["sealed"]["lum_std"], v["render"]["lum_std"], v["render"]["clip_frac"] * 100))
    if a.json:
        with open(a.json, "w", encoding="utf-8") as f:
            json.dump(stats, f, indent=1)


if __name__ == "__main__":
    main()
