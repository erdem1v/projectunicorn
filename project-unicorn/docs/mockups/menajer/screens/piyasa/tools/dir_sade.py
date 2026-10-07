"""Direction D, "dir_sade": the calm, sparse Market list. Builds ../build/dir_sade.html.

  python dir_sade.py

The shell (top bar, rail, office plate, ticker), the seed, the number forms and the series builder are gen.py's;
only the window is new. Three columns on the left (rank, name with one word, value), a summit block of five in a
larger face, the rest standard; movement is a small glyph with no number. The right column is the selected giant:
a five-year chart, the year-end strip, the founder line, three lines of About and three peer chips. The player is
one quiet line at the foot of the list, valuation only, no rank (owner ruling).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen  # noqa: E402
from gen import L, n, money_b, ic, tag, listed, series, _d  # noqa: E402

WIN = (208, 88, 1424, 928)
ROW = 48
GLYPH_MIN = 1.0   # a four-week move under one per cent is no move: the cell stays empty (rule 9)

CSS = """
.win-head.sade { gap: var(--sp-24); }
.win-head.sade .ctx { color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0; }
.sade-body { display: flex; flex: 1; min-height: 0; }
.sl { position: relative; flex: none; width: 784px; display: flex; flex-direction: column; padding: var(--sp-32) var(--sp-32) var(--sp-24); }
.sl .grid { grid-template-columns: 48px 1fr 24px 128px; column-gap: var(--sp-8); }
.sl .tbl-head { padding-left: var(--sp-12); }
.sl .tbl-group { padding-left: var(--sp-12); }
.sl .row { height: 48px; padding-left: var(--sp-12); }
.sl .cell { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.sl .cell.rank { color: var(--ink-3); }
.sl .cell.co { display: flex; align-items: baseline; gap: var(--sp-8); }
.sl .cell.co .nm { color: var(--ink-1); }
.sl .cell.co .sec { color: var(--ink-3); }
.sl .cell.mv { display: flex; justify-content: center; color: var(--ink-3); }
.sl .cell.mv .ic { width: 10px; height: 10px; }
.sl .cell.val { text-align: right; padding-right: var(--sp-8); color: var(--ink-2); }
.sl .row.top .cell.val { color: var(--ink-1); }
.sl .rest { position: relative; flex: none; clip-path: inset(0 -16px 0 0); }   /* clips the rows top and bottom; the bar sits in the gutter */
.sl .rest .rows { position: absolute; left: 0; right: 0; top: 0; }
.sl .rest > .sb { right: -16px; top: 0; }
.sl .you { height: 48px; margin-top: auto; padding: 0 var(--sp-12); flex-direction: row; align-items: center; justify-content: space-between;
  background: transparent; border: 0; border-top: var(--bw-1) solid var(--line-1); border-radius: 0; }
.sl .you .k { color: var(--ink-2); }
.sl .you .v { color: var(--ink-3); }
.sr { flex: 1; min-width: 0; display: flex; flex-direction: column; padding: var(--sp-32) var(--sp-32) var(--sp-24); background: var(--surface-2); border-left: var(--bw-1) solid var(--line-1); }
.sr .name { display: flex; align-items: baseline; gap: var(--sp-16); color: var(--ink-1); }
.sr .name .tag { position: relative; top: -4px; }
.sr .val { margin-top: var(--sp-16); color: var(--ink-1); }
.sr .cap { color: var(--ink-3); }
.sr .why { display: flex; align-items: center; gap: var(--sp-6); margin-top: var(--sp-2); color: var(--ink-3); }
.sr .why .ic { width: 10px; height: 10px; }
.sr .sec { margin-top: var(--sp-24); }
.sr .sec .h { display: flex; align-items: center; height: 28px; margin-bottom: var(--sp-8); color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
.sr .chart { margin-top: var(--sp-20); }
.sr .yrs { display: grid; grid-template-columns: repeat(5, 1fr); margin-top: var(--sp-4); }
.sr .yrs > div { display: flex; flex-direction: column; gap: var(--sp-2); }
.sr .yrs .y { color: var(--ink-3); }
.sr .yrs .n { color: var(--ink-2); }
.sr .yrs .now .n { color: var(--ink-1); font-weight: 500; }
.sr .kv { display: flex; gap: var(--sp-32); }
.sr .kv .k { color: var(--ink-3); margin-right: var(--sp-8); }
.sr .kv .n { color: var(--ink-2); }
.sr .about { color: var(--ink-2); text-wrap: pretty; }
.sr .peers { display: flex; align-items: center; gap: var(--sp-12); }
.sr .peers .h2 { color: var(--ink-3); margin-right: var(--sp-4); }
"""

# ------------------------------------------------------------------ strings (TR first; EN kept for the width pass)
STR = {
    "ctx": ("Nisan 2012 · Akıllı telefon dalgası listeyi taşıyor, sosyal ağların ilk büyük halka arzı mayısta.",
            "April 2012 · The smartphone wave carries the list; the first big social-network IPO comes in May."),
    "col_rank": ("Sıra", "Rank"), "col_co": ("Şirket", "Company"), "col_val": ("Değer", "Value"),
    "g_top": ("Zirve", "Summit"), "g_rest": ("Liste", "List"),
    "you": ("Sen · {v} değerleme", "You · {v} valuation"),
    "threshold": ("Listenin eşiği {v}", "List threshold {v}"),
    "cap": ("Piyasa değeri · Nisan 2012", "Market value · April 2012"),
    "why": ("Son dört haftada yükseldi · yeni telefona talep", "Up over the last four weeks · demand for the new phone"),
    "eoy": ("Yıl sonu değeri", "Year-end value"), "today": ("bugün", "today"),
    "founder": ("Kurucu", "Founder"), "ceo": ("CEO", "CEO"), "ipo": ("Halka arz", "Listed"),
    "about": ("Hakkında", "About"), "peers": ("Benzerler", "Peers"),
}


def s(key, **kw):
    v = STR[key][0 if gen.common.LANG == "tr" else 1]
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ list
def move(r):
    p = r.get("pct_4w")
    if p is None or abs(p) < GLYPH_MIN:
        return ""
    return ic("tri_up" if p > 0 else "tri_down")


def row(r, top=False, selected=False):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    nm, val = ("t-value", "t-value") if top else ("t-data-strong", "t-data")
    cls = "row grid" + (" top" if top else "") + (" is-selected" if selected else "")
    return ('<div class="%s"><div class="cell rank t-data">%d</div>'
            '<div class="cell co"><span class="nm %s">%s</span><span class="sec t-small">%s</span></div>'
            '<div class="cell mv">%s</div><div class="cell val %s">%s</div></div>'
            % (cls, r["rank"], nm, r["name"], sec, move(r), val, n(money_b(r["value_b"]))))


def group(label):
    return '<div class="tbl-group t-group">%s</div>' % label


def list_col(rows, selected, value_m, rest_h):
    head = ('<div class="tbl-head grid"><div class="th t-label">%s</div><div class="th t-label">%s</div><div class="th"></div>'
            '<div class="th r t-label" style="padding-right:8px">%s</div></div>' % (s("col_rank"), s("col_co"), s("col_val")))
    top = "".join(row(r, top=True, selected=(r["name"] == selected)) for r in rows[:5])
    vis = rest_h // ROW + 1   # one more than fits: the clipped row reads as a scroll
    rest = "".join(row(r, selected=(r["name"] == selected)) for r in rows[5:5 + vis])
    thumb_h = max(48, int(rest_h * (rest_h // ROW) / float(len(rows) - 5)))
    sb = gen.scrollbar(0, rest_h, 0, thumb_h)
    floor_v = min(r["value_b"] for r in rows)
    you = ('<div class="you"><span class="k t-data">%s</span><span class="v t-data">%s</span></div>'
           % (s("you", v=n(gen.money_m(value_m))), s("threshold", v=n(money_b(floor_v)))))
    return ('<div class="sl"><div class="tbl">%s%s<div class="rows">%s</div>%s</div>'
            '<div class="rest" style="height:%dpx"><div class="rows">%s</div>%s</div>%s</div>'
            % (head, group(s("g_top")), top, group(s("g_rest")), rest_h, rest, sb, you))


# ------------------------------------------------------------------ detail
def chart5y(vals, week, w=576, h=240):
    """Weekly points from January 2008 to today; a tick and the year at every January; three or four gridlines."""
    pad_l, pad_r, pad_t, pad_b = 56, 12, 12, 24
    lo, hi = 0, max(vals)
    base = 10 ** math.floor(math.log10(hi))
    for step in (base / 2, base, base * 2, base * 5):
        yhi = math.ceil(hi / step) * step
        if yhi / step <= 4:
            break
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi - lo) * (h - pad_t - pad_b)
    g = []
    for k in range(int(round(yhi / step)) + 1):
        v = k * step
        g.append('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % (pad_l, w - pad_r, Y(v), Y(v)))
        if v:
            g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(v) + 4, n(money_b(v))))
    w0 = week - len(vals) + 1
    for i in range(len(vals)):
        d = _d(w0 + i)
        if i == 0 or d.year != _d(w0 + i - 1).year:
            g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
            g.append('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="middle">%d</text>' % (X(i), h - 4, d.year))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def detail(r, week, hist, about, peers, ceo, ipo_year):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    years = sorted(hist)[1:]
    cells = "".join('<div><span class="y t-small">%d</span><span class="n t-data">%s</span></div>' % (y, n(money_b(hist[y]))) for y in years)
    cells += '<div class="now"><span class="y t-small">%d · %s</span><span class="n t-data">%s</span></div>' % (2012, s("today"), n(money_b(r["value_b"])))
    chips = "".join('<span class="chip sm t-data">%s</span>' % p for p in peers)
    pts = series(r, week, hist, points=223)   # the first point falls in January 2008; December anchors pin the year-end values
    return ('<div class="sr">'
            '<div class="name"><span class="t-h2">%s</span>%s</div>'
            '<div class="val t-hero">%s</div><div class="cap t-caption">%s</div><div class="why t-caption">%s%s</div>'
            '%s'
            '<div class="sec"><div class="h t-label">%s</div><div class="yrs">%s</div></div>'
            '<div class="sec"><div class="kv t-data"><span><span class="k">%s</span><span class="n">%s</span></span>'
            '<span><span class="k">%s</span><span class="n">%s</span></span><span><span class="k">%s</span><span class="n">%d</span></span></div></div>'
            '<div class="sec"><div class="h t-label">%s</div><p class="about t-body">%s</p></div>'
            '<div class="sec peers"><span class="h2 t-label">%s</span>%s</div>'
            '</div>'
            % (r["name"], tag(sec, "outline"),
               n(money_b(r["value_b"])), s("cap"), ic("tri_up"), s("why"),
               chart5y(pts, week),
               s("eoy"), cells,
               s("founder"), r["person"], s("ceo"), ceo, s("ipo"), ipo_year,
               s("about"), about,
               s("peers"), chips))


# ------------------------------------------------------------------ window and frame
def window(body):
    x, y, w, h = WIN
    head = ('<div class="win-head sade"><h1 class="win-title t-h1">%s</h1><span class="ctx t-body">%s</span><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (gen.s("tab_piyasa"), s("ctx"), ic("close")))
    return '<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s<div class="sade-body">%s</div></section>' % (x, y, w, h, head, body)


def build(week=14):
    rows = listed(week)
    about = L("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
              "gelirinin yarısından çoğu bugün o tek üründen geliyor.",
              "A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
              "handset market; more than half its revenue now comes from that one product.")
    malus = next(r for r in rows if r["name"] == "Malus")
    # left column: 854 body − 32 pad − 36 head − 36 group − 240 summit − 36 group − 64 player line − 24 pad = 386 for the rest;
    # 360 shows seven rows and half of the eighth, so the block reads as a scroll
    body = list_col(rows, "Malus", gen.SEED["player"]["seed_post_money_m"], 360) + detail(malus, week, gen.POMELO_HIST, about, ["Samdal", "Fenstra", "Gogol"], "Timo Koch", 1980)
    html = gen.page(gen.screen(gen.topbar(gen.TOP_THEME), gen.rail("piyasa", gen.B_THEME), window(body), gen.news_market()))
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    out = os.path.join(gen.BUILD, "dir_sade.html")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(build())
    print("built", out)
