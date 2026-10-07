# Iteration proof: every glyph at 4x on the grid and at 24 / 20 / 16 on panel (surface-3) and rail (surface-1).
#   python proof.py [prefix ...]   -> rounds/proof.html, rendered by run_proof.sh
import os, sys
import kit
from glyphs import build

HERE = os.path.dirname(os.path.abspath(__file__))


def sym(key, g, color="currentColor"):
    return '<symbol id="i-%s" viewBox="0 0 24 24">%s</symbol>' % (key.replace("/", "-"), kit.paths(g, color))


def use(key, px, color):
    return '<svg width="%d" height="%d" style="color:%s;display:block"><use href="#i-%s"/></svg>' % (
        px, px, color, key.replace("/", "-"))


def main(prefixes, out="rounds/proof.html", cols=8):
    gl = build()
    keys = [k for k in gl if not prefixes or any(k.startswith(p) for p in prefixes)]
    syms = "".join(sym(k, gl[k]) for k in keys)
    cells = []
    for k in keys:
        rows = "".join('<div class="r" style="background:%s">%s%s%s</div>' % (bg, use(k, 24, c), use(k, 20, c), use(k, 16, c))
                       for bg, c in (("#1E1B18", "#E9E4DA"), ("#15120F", "#9A9184")))
        cells.append('<div class="c"><div class="z">%s</div><div class="s">%s</div><div class="n">%s</div></div>'
                     % (use(k, 96, "#E9E4DA"), rows, k))
    doc = ('<!doctype html><html><head><meta charset="utf-8"><style>*{margin:0;box-sizing:border-box}'
           'body{background:#100E0B;width:%dpx;padding:12px;display:grid;grid-template-columns:repeat(%d,1fr);gap:8px;'
           'font:12px/16px sans-serif;color:#9A9184}'
           '.c{background:#1E1B18;border:1px solid #3A342D;border-radius:4px;padding:6px;display:grid;grid-template-columns:96px 1fr;gap:6px}'
           '.z{width:96px;height:96px;background-color:#16130F;background-image:linear-gradient(to right,rgba(233,228,218,.07) 1px,transparent 1px),'
           'linear-gradient(to bottom,rgba(233,228,218,.07) 1px,transparent 1px);background-size:4px 4px}'
           '.s{display:flex;flex-direction:column;gap:4px}.r{display:flex;gap:10px;align-items:center;padding:6px 8px;border-radius:3px}'
           '.n{grid-column:1/3}</style></head><body>'
           '<svg width="0" height="0" style="position:absolute">%s</svg>%s</body></html>'
           % (cols * 236 + 24, cols, syms, "".join(cells)))
    p = os.path.join(HERE, out)
    open(p, "w", encoding="utf-8").write(doc)
    rows_n = (len(keys) + cols - 1) // cols
    print(p, cols * 236 + 24, rows_n * 136 + 24)


if __name__ == "__main__":
    main(sys.argv[1:])


def strip(out="rounds/strip.html", per=26):
    """Every glyph at 16 and 20 px, 1:1, panel ink-2 and rail ink-4: for 3x nearest crops."""
    gl = build()
    keys = list(gl)
    syms = "".join(sym(k, gl[k]) for k in keys)
    rows = []
    for i in range(0, len(keys), per):
        ks = keys[i:i + per]
        for px, bg, c in ((16, "#1E1B18", "#E9E4DA"), (16, "#15120F", "#9A9184"), (20, "#1E1B18", "#E9E4DA"), (20, "#15120F", "#9A9184")):
            rows.append('<div class="row" style="background:%s">%s</div>' % (
                bg, "".join('<div class="cl">%s</div>' % use(k, px, c) for k in ks)))
        rows.append('<div class="row lab">%s</div>' % "".join('<div class="cl t">%d</div>' % (i + j) for j in range(len(ks))))
    doc = ('<!doctype html><html><head><meta charset="utf-8"><style>*{margin:0;box-sizing:border-box}'
           'body{background:#100E0B;width:%dpx;padding:8px;font:10px/12px sans-serif;color:#6B6358}'
           '.row{display:flex}.cl{width:28px;height:28px;display:flex;align-items:center;justify-content:center}'
           '.lab .cl{height:14px}</style></head><body><svg width="0" height="0" style="position:absolute">%s</svg>%s</body></html>'
           % (per * 28 + 16, syms, "".join(rows)))
    open(os.path.join(HERE, out), "w", encoding="utf-8").write(doc)
    n = (len(keys) + per - 1) // per
    print(per * 28 + 16, n * (4 * 28 + 14) + 16)
    return keys
