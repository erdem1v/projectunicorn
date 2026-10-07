import json, os, math
from PIL import Image, ImageDraw, ImageFont
HERE = os.path.dirname(os.path.abspath(__file__))
frames = json.load(open(os.path.join(HERE, "frames.json"), encoding="utf-8"))
os.makedirs(os.path.join(HERE, "sheets"), exist_ok=True)
TW, TH, COLS = 480, 270, 4
font = ImageFont.load_default()
for g in frames["groups"]:
    fs = g["frames"]
    for part in range(math.ceil(len(fs) / 16)):
        chunk = fs[part * 16:(part + 1) * 16]
        rows = math.ceil(len(chunk) / COLS)
        sheet = Image.new("RGB", (COLS * (TW + 8) + 8, rows * (TH + 24) + 8), (16, 14, 11))
        d = ImageDraw.Draw(sheet)
        for i, f in enumerate(chunk):
            im = Image.open(os.path.join(HERE, f["file"])).convert("RGB")
            im.thumbnail((TW, TH))
            x = 8 + (i % COLS) * (TW + 8)
            y = 8 + (i // COLS) * (TH + 24)
            sheet.paste(im, (x, y))
            d.text((x, y + TH + 4), os.path.basename(f["file"])[:70], fill=(220, 214, 200), font=font)
        sheet.save(os.path.join(HERE, "sheets", f"{g['key']}_{part + 1}.jpg"), quality=85)
        print(g["key"], part + 1, len(chunk))
