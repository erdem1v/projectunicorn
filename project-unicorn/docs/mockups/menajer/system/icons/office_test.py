# Head icons in the office: renders every head icon at 128 px (as Godot imports them), shrinks them the way a
# mipmapped Sprite3D does (box filter), and pastes them over the game's own renders at the real head positions.
#   python office_test.py html   -> rounds/heads128.html (render it at 1152 x 384)
#   python office_test.py comp   -> review/heads_office.png (needs the two rounds/heads128_*.png renders)
import os, sys, glob, json
from PIL import Image
import build_icons as B
from glyphs import HEAD_ORDER

HERE = os.path.dirname(os.path.abspath(__file__))
REPO_ICONS = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "..", "assets", "art", "office", "icons"))
OFFICE = os.path.normpath(os.path.join(HERE, "..", "..", "art", "office_full.png"))
ROWS = [("invert", lambda n: B.head_svg(n, "invert")), ("ring", lambda n: B.head_svg(n, "ring")),
        ("today", lambda n: open(os.path.join(REPO_ICONS, n + ".svg"), encoding="utf-8").read())]


def html(bg="#000000", name="heads128_k.html"):
    cells = []
    for _, fn in ROWS:
        for n in HEAD_ORDER:
            svg = fn(n).replace('<svg ', '<svg style="display:block" ', 1)
            cells.append('<div style="width:128px;height:128px">%s</div>' % svg)
    doc = ('<!doctype html><html><head><meta charset="utf-8"><style>*{margin:0}body{background:%s;width:1152px;'
           'display:grid;grid-template-columns:repeat(9,128px)}</style></head><body>%s</body></html>' % (bg, "".join(cells)))
    open(os.path.join(HERE, "rounds", name), "w", encoding="utf-8").write(doc)


def comp():
    os.makedirs(os.path.join(HERE, "review"), exist_ok=True)
    kb = Image.open(os.path.join(HERE, "rounds", "heads128_k.png")).convert("RGB")
    wb = Image.open(os.path.join(HERE, "rounds", "heads128_w.png")).convert("RGB")
    office = Image.open(OFFICE).convert("RGB")
    key = (255, 0, 255)

    def icon(row, col, px):
        box = (col * 128, row * 128, col * 128 + 128, row * 128 + 128)
        k, w = kb.crop(box).load(), wb.crop(box).load()
        # alpha from the black and white renders: a = 1 - (white - black), colour = black / a
        rgba = Image.new("RGBA", (128, 128))
        px_out = rgba.load()
        for y in range(128):
            for x in range(128):
                kr, kg, kb_ = k[x, y]; wr, wg, wb_ = w[x, y]
                a = 255 - ((wr - kr) + (wg - kg) + (wb_ - kb_)) / 3.0
                a = max(0.0, min(255.0, a))
                c = (lambda v: int(min(255, v * 255.0 / a)) if a > 0 else 0)
                px_out[x, y] = (c(kr), c(kg), c(kb_), int(a))
        # OfficeActor modulates by ICON_TINT #d2d2d2
        r_, g_, b_, a_ = rgba.split()
        tint = lambda c: c.point(lambda v: v * 0xd2 // 255)
        rgba = Image.merge("RGBA", (tint(r_), tint(g_), tint(b_), a_))
        return rgba.resize((px, px), Image.BOX)

    # the game's own renders without icons, people at their real head positions and real icon sizes
    # (art/office_safe_1920*_heads.json). Statuses mix work and breaks so the break cue shows.
    ART = os.path.dirname(OFFICE)
    scenes = [("office_safe_1920", ["research", "test", "design", "coffee", "phone"], (660, 390, 1120, 690)),
              ("office_safe_1920_loft", ["research", "meeting", "design", "wc", "food"], (400, 250, 780, 550))]
    tiles = []
    for ri in range(len(ROWS)):
        row = []
        for base_name, statuses, box_ in scenes:
            base = Image.open(os.path.join(ART, base_name + "_noicons.png")).convert("RGB")
            heads = json.load(open(os.path.join(ART, base_name + "_heads.json"), encoding="utf-8"))["people"]
            for p, st in zip(heads, statuses):
                px = int(p["icon_px"])
                ic = icon(ri, HEAD_ORDER.index(st), px)
                x, y = p["icon_xy"]
                base.paste(ic, (int(x) - px // 2, int(y) - px // 2), ic)
            row.append(base.crop(box_))
        tiles.append(row)
    W = sum(t.width for t in tiles[0]) + 16 * (len(scenes) - 1)
    H = sum(r[0].height for r in tiles) + 16 * (len(tiles) - 1)
    out = Image.new("RGB", (W, H), (16, 14, 11))
    y = 0
    for row in tiles:
        x = 0
        for t in row:
            out.paste(t, (x, y)); x += t.width + 16
        y += row[0].height + 16
    out.save(os.path.join(HERE, "review", "heads_office.png"))
    # the recommended row at 2x, nearest neighbour, both scenes
    zoom = Image.new("RGB", (460, 616), (16, 14, 11))
    zoom.paste(tiles[0][0].crop((40, 100, 270, 250)).resize((460, 300), Image.NEAREST), (0, 0))
    zoom.paste(tiles[0][1].crop((60, 50, 290, 200)).resize((460, 300), Image.NEAREST), (0, 316))
    zoom.save(os.path.join(HERE, "review", "heads_zoom.png"))


if __name__ == "__main__":
    if sys.argv[1] == "html":
        html("#000000", "heads128_k.html"); html("#FFFFFF", "heads128_w.html")
    else:
        comp()
