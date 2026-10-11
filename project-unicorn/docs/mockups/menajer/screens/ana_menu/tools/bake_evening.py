# Bakes the daytime city plate (office_safe_1920_city.png, a real engine capture) into a full-frame evening plate
# for the main menu: sky keyed out (border-connected smooth region), city graded into a warm-charcoal dusk band that
# keeps a little of its own hue, glass-tower windows lit sparsely and warm, then scaled up to fill the frame and
# faded into surface-0 on the left where the menu column sits.
#   python bake_evening.py <src> <out_dir> [scale] [ox] [oy]
import sys, os
from PIL import Image, ImageFilter
import numpy as np
from scipy import ndimage as ndi

src, out = sys.argv[1], sys.argv[2]
SCALE = float(sys.argv[3]) if len(sys.argv) > 3 else 1.75
OX = float(sys.argv[4]) if len(sys.argv) > 4 else -620   # where the source's (0,0) lands in the 1920 frame
OY = float(sys.argv[5]) if len(sys.argv) > 5 else -40

im = np.asarray(Image.open(src).convert("RGB")).astype(np.float32)
H, W, _ = im.shape
gx = np.abs(np.diff(im, axis=1, append=im[:, -1:, :])).max(axis=2)
gy = np.abs(np.diff(im, axis=0, append=im[-1:, :, :])).max(axis=2)
lab, n = ndi.label(np.maximum(gx, gy) < 4.0)
border = set(np.unique(np.concatenate([lab[0], lab[-1], lab[:, 0], lab[:, -1]]))) - {0}
sky = ndi.binary_closing(np.isin(lab, list(border)), iterations=2)
city = ndi.binary_opening(~sky, iterations=1)
alpha = np.asarray(Image.fromarray((city * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.8))).astype(np.float32) / 255.0

r, g, b = im[..., 0], im[..., 1], im[..., 2]
lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0
gray = lum[..., None] * 255.0
# dusk duotone: deep warm shadow -> muted warm stone (between line-1 and line-3), a touch brighter than B's silhouette
lo = np.array([0x16, 0x13, 0x10], np.float32)
hi = np.array([0x5E, 0x54, 0x49], np.float32)
t = np.clip(lum, 0, 1) ** 1.55
base = lo * (1 - t[..., None]) + hi * t[..., None]
# keep a little of the scene's own hue (brick roofs, water, park) so it reads as OUR city, not a stock skyline
chroma = (im - gray) * 0.16
# cool the evening slightly: shift the shadows to blue-grey, keep the highlights warm
cool = np.array([-3, 0, 5], np.float32) * (1 - t[..., None])
rgb = np.clip(base + chroma + cool, 0, 255)

# lit windows: the glass towers' window panes are bright and blue-leaning. Light ~28% of them by 5x5 cell hash.
pane = (b > r + 18) & (lum > 0.62) & city
yy, xx = np.mgrid[0:H, 0:W]
cell = ((xx // 7) * 73856093 ^ (yy // 6) * 19349663) & 0xFFFF
lit = pane & ((cell % 100) < 17)
# unlit glass at dusk goes dark instead of reflecting a daytime sky
rgb = np.where((pane & ~lit)[..., None], rgb * 0.62, rgb)
warm = np.array([0xD8, 0xB0, 0x72], np.float32)
glow = np.clip((lum - 0.55) / 0.35, 0, 1)[..., None] * 0.70
rgb = np.where(lit[..., None], rgb * (1 - glow) + warm * glow, rgb)
# a faint bloom around lit panes (baked, not a shader)
bloom = ndi.gaussian_filter(lit.astype(np.float32), 3.0) * 0.45
rgb = np.clip(rgb + bloom[..., None] * np.array([0x60, 0x48, 0x28], np.float32), 0, 255)

cityimg = Image.fromarray(np.dstack([rgb, alpha * 255]).astype(np.uint8), "RGBA")

def compose(FW, FH, k):
    s = SCALE * k
    big = cityimg.resize((round(W * s), round(H * s)), Image.LANCZOS)
    # ground: surface-0 with a soft dusk lift behind the towers (no stock sky, just the page warming up)
    yy2, xx2 = np.mgrid[0:FH, 0:FW].astype(np.float32)
    cx, cy = FW * 0.70, FH * 0.30
    d = np.sqrt(((xx2 - cx) / (FW * 0.55)) ** 2 + ((yy2 - cy) / (FH * 0.75)) ** 2)
    lift = np.clip(1 - d, 0, 1) ** 1.6
    g0 = np.array([0x10, 0x0E, 0x0B], np.float32); g1 = np.array([0x22, 0x1E, 0x1B], np.float32)
    ground = g0 * (1 - lift[..., None]) + g1 * lift[..., None]
    canvas = Image.fromarray(ground.astype(np.uint8), "RGB").convert("RGBA")
    canvas.alpha_composite(big, (round(OX * k), round(OY * k)))
    a = np.asarray(canvas.convert("RGB")).astype(np.float32)
    # left fade for the menu column: surface-0 at full strength to ~34% of the width, gone by ~62%
    x = np.arange(FW, dtype=np.float32) / FW
    f = np.clip((x - 0.24) / (0.64 - 0.24), 0, 1)
    f = f * f * (3 - 2 * f)
    keep = 0.15 + 0.85 * f
    a = g0 * (1 - keep[None, :, None]) + a * keep[None, :, None]
    # bottom fade so the version line sits on ground
    y = np.arange(FH, dtype=np.float32) / FH
    fb = np.clip((y - 0.86) / 0.14, 0, 1)
    a = a * (1 - 0.6 * fb[:, None, None]) + g0 * (0.6 * fb[:, None, None])
    return Image.fromarray(np.clip(a + 0.5, 0, 255).astype(np.uint8), "RGB")

os.makedirs(out, exist_ok=True)
compose(1920, 1080, 1.0).save(os.path.join(out, "plate_evening_1920.png"))
compose(1536, 864, 0.8).save(os.path.join(out, "plate_evening_1536.png"))
cityimg.save(os.path.join(out, "city_evening_rgba.png"))
print("ok", n, int(lit.sum()), "lit px")
