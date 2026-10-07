# Rebuilds everything: the SVG files, the head-icon office composite, ../icons.html and its pages ../icons_pN.png.
#   python run_all.py
# Needs shapely 2.x (pip install shapely; or ICON_PYLIB=<dir> pointing at a folder that holds it) and Chrome
# through ../../tools/render.sh. The sheet renders as one tall page; each page ends with a 4 px marker at x 0,
# which is where it is cut.
import os, subprocess, glob
from PIL import Image
import build_icons as B, office_test, sheet

HERE = os.path.dirname(os.path.abspath(__file__))
SYS = os.path.dirname(HERE)
RENDER = os.path.normpath(os.path.join(SYS, "..", "tools", "render.sh"))


def render(html, png, w, h):
    subprocess.run(["bash", RENDER, html, png, str(w), str(h), "1"], check=True, cwd=HERE, stdout=subprocess.DEVNULL)


print("ui svgs:", B.write_ui_svgs())
B.write_head_svgs()
B.write_theme_svgs()
office_test.html()
render("rounds/heads128_k.html", "rounds/heads128_k.png", 1152, 384)
render("rounds/heads128_w.html", "rounds/heads128_w.png", 1152, 384)
office_test.comp()
out = sheet.build()
full = os.path.join(SYS, "icons_all.png")
render(out, full, sheet.PAGE_W, 14000)
im = Image.open(full).convert("RGB")
px = im.load()
cuts = [y for y in range(im.height) if px[0, y] == (255, 0, 255) and px[0, y - 1] != (255, 0, 255)]
for f in glob.glob(os.path.join(SYS, "icons_p*.png")):
    os.remove(f)
top = 0
for i, y in enumerate(cuts):
    im.crop((0, top, sheet.PAGE_W, y)).save(os.path.join(SYS, "icons_p%d.png" % (i + 1)))
    top = y + 4
os.remove(full)
print("pages:", len(cuts), [c for c in cuts])
