# Review sheet for the icon family: ../icons.html, split into ../icons_pN.png by run_all.py.
# Colours and type come from ../tokens.css (A1), so the sheet follows the system's tokens.
import os, html
import build_icons as B

HERE = os.path.dirname(os.path.abspath(__file__)).replace("\\", "/")
SYS = os.path.dirname(HERE)
PAGE_W = 1680
MARK = "#FF00FF"   # 4 px page-end marker at x 0, found and cut away by run_all.py

FONTS = ("https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&family=IBM+Plex+Sans+Condensed:wght@400"
         "&family=IBM+Plex+Sans:wght@400;500;600;700&display=block")

CSS = """
*{box-sizing:border-box;margin:0;padding:0}
html,body{background:var(--surface-0);width:%(W)dpx}
body{font-family:var(--f-sans);color:var(--ink-2);-webkit-font-smoothing:antialiased;font-variant-numeric:tabular-nums}
svg{display:block;flex:none}
.page{width:%(W)dpx;padding:40px 48px 44px;position:relative}
.page .mark{position:absolute;left:0;bottom:0;width:4px;height:4px;background:%(M)s}
.ph{display:flex;align-items:baseline;gap:20px;margin-bottom:8px}
.ph h1{font-family:var(--f-cond);font-weight:700;font-size:36px;line-height:44px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-1)}
.ph .pg{font-family:var(--f-cond);font-weight:600;font-size:15px;letter-spacing:1px;color:var(--ink-4);margin-left:auto}
.lead{font-size:16px;line-height:24px;color:var(--ink-3);max-width:1440px;margin-bottom:20px}
.lead b{color:var(--ink-2);font-weight:600}
h2{font-family:var(--f-cond);font-weight:700;font-size:20px;line-height:27px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-2);margin:22px 0 10px;display:flex;align-items:baseline;gap:12px}
h2 .n{font-family:var(--f-sans);font-weight:400;font-size:14px;letter-spacing:0;text-transform:none;color:var(--ink-4)}
.grid{display:grid;gap:10px}
.cell{background:var(--surface-2);border:1px solid var(--line-1);border-radius:6px;padding:10px;display:flex;flex-direction:column;gap:8px}
.cell .hd{display:flex;align-items:baseline;gap:6px;min-width:0}
.cell .nm{font-family:var(--f-cond);font-weight:600;font-size:16px;line-height:20px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-2);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.cell .fn{font-family:var(--f-sansc);font-size:12px;color:var(--ink-4);margin-left:auto;white-space:nowrap}
.zoomrow{display:flex;gap:10px;align-items:flex-start}
.zoom{width:96px;height:96px;flex:none;position:relative;border-radius:3px;background-color:#16130F;
 background-image:linear-gradient(to right,rgba(233,228,218,.07) 1px,transparent 1px),linear-gradient(to bottom,rgba(233,228,218,.07) 1px,transparent 1px);
 background-size:4px 4px}
.zoom::after{content:"";position:absolute;left:8px;top:8px;width:80px;height:80px;border:1px dashed rgba(242,181,58,.28)}
.zoom svg{position:absolute;left:0;top:0;color:var(--ink-2)}
.sizes{display:flex;flex-direction:column;gap:6px;flex:1;min-width:0}
.srow{display:flex;align-items:center;gap:10px;height:42px;border-radius:4px;padding:0 10px}
.srow.pn{background:var(--surface-3)}
.srow.rl{background:var(--surface-1)}
.srow .k{font-family:var(--f-cond);font-weight:600;font-size:12px;letter-spacing:1px;color:var(--ink-4);width:38px}
.srow.pn svg{color:var(--ink-2)}
.srow.rl svg{color:var(--ink-4)}
.mean{font-size:14px;line-height:20px;color:var(--ink-3)}
.mean b{font-weight:600;color:var(--ink-2)}
.mean .en{color:var(--ink-4)}
.mean .gl{color:var(--ink-2)}
.mean .q{color:var(--warn)}
.tag{display:inline-block;font-family:var(--f-cond);font-weight:700;font-size:12px;letter-spacing:1px;padding:0 6px;line-height:18px;border-radius:3px;border:1px solid var(--line-3);color:var(--ink-3);vertical-align:1px}
.tag.new{border-color:rgba(79,210,122,.55);color:var(--pos-ink)}
.tag.chg{border-color:rgba(232,145,58,.6);color:var(--warn)}
.rules{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
.rule{background:var(--surface-2);border:1px solid var(--line-1);border-radius:6px;padding:12px 14px;font-size:14px;line-height:20px;color:var(--ink-3)}
.rule b{display:block;font-family:var(--f-cond);font-weight:700;font-size:15px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-2);margin-bottom:4px}
.box{background:var(--surface-3);border:1px solid var(--line-1);border-radius:8px;padding:16px 18px}
.box .cap{font-family:var(--f-cond);font-weight:600;font-size:14px;letter-spacing:1px;text-transform:uppercase;color:var(--ink-3);margin-bottom:10px}
.box p{font-size:14px;line-height:21px;color:var(--ink-3)}
.box p+p{margin-top:10px}
.box p b{color:var(--ink-2);font-weight:600}
.two{display:grid;grid-template-columns:1fr 1fr;gap:16px}
"""


def ic(key, size, color=None, cls=""):
    st = (' style="color:%s"' % color) if color else ""
    return '<svg class="%s" width="%d" height="%d"%s><use href="#i-%s"/></svg>' % (cls, size, size, st, key.replace("/", "-"))


def cell(key, title, meaning="", tag=None):
    sizes = "".join('<div class="srow %s"><span class="k">%s</span>%s%s%s</div>' % (
        bg, lab, ic(key, 24), ic(key, 20), ic(key, 16)) for bg, lab in (("pn", "PANEL"), ("rl", "RAY")))
    m = ('<div class="mean">%s</div>' % meaning) if meaning else ""
    t = ""
    if tag:
        t = '<span class="tag %s">%s</span>' % (tag[0], tag[1])
    return ('<div class="cell"><div class="hd"><span class="nm">%s</span>%s<span class="fn">%s.svg</span></div>'
            '<div class="zoomrow"><div class="zoom">%s</div><div class="sizes">%s</div></div>%s</div>'
            % (html.escape(title), t, key, ic(key, 96), sizes, m))


def grid(cells, cols):
    return '<div class="grid" style="grid-template-columns:repeat(%d,minmax(0,1fr))">%s</div>' % (cols, "".join(cells))


def page(title, n, total, lead, inner):
    return ('<section class="page"><div class="ph"><h1>%s</h1><span class="pg">MENAJER MASASI · İKON AİLESİ · SAYFA %d / %d</span></div>'
            '<p class="lead">%s</p>%s<div class="mark"></div></section>' % (title, n, total, lead, inner))


def build():
    import pages
    css2, body = pages.all_pages(cell, grid, page, ic)
    out = os.path.join(SYS, "icons.html")
    doc = ('<!doctype html><html lang="tr"><head><meta charset="utf-8"><title>İkon ailesi</title>'
           '<link rel="stylesheet" href="%s"><link rel="stylesheet" href="tokens.css"><style>%s</style></head><body>'
           '<svg width="0" height="0" style="position:absolute">%s%s</svg>%s</body></html>'
           % (html.escape(FONTS), CSS % {"W": PAGE_W, "M": MARK} + css2, B.symbols(), pages.extra_symbols(), body))
    open(out, "w", encoding="utf-8", newline="\n").write(doc)
    return out
