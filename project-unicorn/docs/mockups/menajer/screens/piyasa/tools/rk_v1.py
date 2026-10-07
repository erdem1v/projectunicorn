"""Variant rk_v1: the Market window as a REPORT CARD, after the two references the owner kept (Startup Company's
Website Stats card and Plutocracy's Finances tiles). Builds ../build/rk_v1.html.

  python rk_v1.py

The shell (top bar, rail, office plate, ticker), the seed, the number forms and the series builder are gen.py's;
only the window is new. Under the window head a strip of three dark tiles (list value with 13 weekly bars and the
four-week change · the leader · the player's own valuation, no rank). Below, two columns: a short ranked list on
the left (rank, name over sector, value; the summit three in a larger face; 12 rows, then "and 23 more") and on the
right the selected company's report card in the reference's reading order: hero figure → label:value rows → the
share gauge → one five-year area chart → one line of About.

Player fiction (for INDEX, not written here): the $4,2M post-money is the seed's own figure; the "Seed $130K for
16 %" line the brief mentions does not reconcile with it (130 / 0,16 = $812K), so the tile names the round and the
month only and prints no round terms. Every local class carries the rk-/rc-/kt-/g- prefix: base.css owns .sc, .pane,
.n, .k and the other short names.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen  # noqa: E402
from gen import L, n, money_b, ic, tag, listed, series, _d  # noqa: E402

WIN = (208, 88, 1424, 928)
SHOWN = 12
BARS = 13

CSS = """
/* local type: the card's name is Barlow Bold 40 as typed (a proper noun is never caps); the hero figure is Plex 40 */
.t-display { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-40); line-height: var(--lh-40); letter-spacing: 0; }
.t-big { font-family: var(--f-sans); font-weight: 600; font-size: var(--fs-40); line-height: var(--lh-40); letter-spacing: 0; }
.t-tile { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-36); line-height: var(--lh-36); letter-spacing: 0; }
.win-head.rk { gap: var(--sp-24); }
.win-head.rk .ctx { color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0; }
/* tile strip: three raised tiles (surface-4), one figure each */
.kts { flex: none; display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--sp-16); padding: var(--sp-16) var(--sp-24);
  border-bottom: var(--bw-1) solid var(--line-1); }
.kt { display: flex; flex-direction: column; height: 120px; padding: var(--sp-12) var(--sp-20); background: var(--surface-4);
  border: var(--bw-1) solid var(--line-1); border-radius: var(--r-3); }
.kt-k { color: var(--ink-3); }
.kt-v { display: flex; align-items: baseline; gap: var(--sp-12); color: var(--ink-1); }
.kt-v .pct { font-family: var(--f-sans); font-weight: 500; font-size: var(--fs-15); line-height: var(--lh-15); }
.kt-foot { display: flex; align-items: flex-end; justify-content: space-between; margin-top: auto; }
.kt-d { color: var(--ink-3); }
.kt-bars { display: flex; align-items: flex-end; gap: 3px; height: 24px; }
.kt-bars i { display: block; width: 6px; background: var(--ink-3); border-radius: 1px; }
.kt-bars i:last-child { background: var(--ink-1); }
/* body: the list and the card */
.rk-body { display: flex; flex: 1; min-height: 0; }
.rk-list { flex: none; width: 424px; display: flex; flex-direction: column; padding: var(--sp-16) var(--sp-16) 0 var(--sp-24); }
.rk-list .row { height: 52px; grid-template-columns: 36px 1fr 104px; column-gap: var(--sp-8); }
.rk-r { color: var(--ink-4); padding-left: var(--sp-8); }
.rk-co { display: flex; flex-direction: column; justify-content: center; min-width: 0; }
.rk-nm { color: var(--ink-1); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.rk-sc { color: var(--ink-3); white-space: nowrap; }
.rk-vl { text-align: right; padding-right: var(--sp-8); color: var(--ink-2); }
.row.top .rk-vl { color: var(--ink-1); }
.rk-more { height: 40px; display: flex; align-items: center; padding-left: var(--sp-8); color: var(--ink-3); }
.rk-card { flex: 1; min-width: 0; display: flex; flex-direction: column; padding: var(--sp-24) var(--sp-32) var(--sp-24);
  background: var(--surface-2); border-left: var(--bw-1) solid var(--line-1); }
.rc-head { display: flex; align-items: baseline; gap: var(--sp-16); }
.rc-nm { color: var(--ink-1); }
.rc-head .tag { position: relative; top: -6px; }
.rc-ipo { margin-left: auto; color: var(--ink-3); }
.rc-sub { display: flex; gap: var(--sp-16); margin-top: var(--sp-2); color: var(--ink-3); }
.rc-sub b { font-weight: 500; color: var(--ink-2); }
/* the upper half: hero · label:value rows · the share gauge, three panes split by rules */
.rc-panes { display: grid; grid-template-columns: 1fr 1fr 1fr; margin-top: var(--sp-24); height: 160px; }
.rc-pane { display: flex; flex-direction: column; justify-content: center; padding: 0 var(--sp-32); }
.rc-pane + .rc-pane { border-left: var(--bw-1) solid var(--line-1); }
.rc-pane:first-child { padding-left: 0; }
.rc-hero { color: var(--ink-1); }
.rc-cap { color: var(--ink-3); margin-top: var(--sp-4); }
.rc-why { display: flex; align-items: center; gap: var(--sp-6); margin-top: var(--sp-8); color: var(--ink-3); }
.rc-why .pct, .rc-n .pct { color: var(--pos); gap: var(--sp-2); }
.rc-why .pct .ic, .rc-n .pct .ic { width: 12px; height: 12px; }
.rc-kv { display: grid; grid-template-columns: 1fr auto; column-gap: var(--sp-24); align-items: center; }
.rc-k { height: 28px; display: flex; align-items: center; color: var(--ink-3); }
.rc-n { height: 28px; display: flex; align-items: center; justify-content: flex-end; color: var(--ink-2); }
.rc-gauge { display: flex; flex-direction: column; align-items: center; }
.rc-gauge svg { display: block; overflow: visible; }
.g-track { fill: none; stroke: var(--chart-grid); stroke-width: 3; }
.g-arc { fill: none; stroke: var(--chart-line); stroke-width: 3; }
.g-tick { stroke: var(--chart-axis); stroke-width: 1; }
.g-num { fill: var(--ink-1); font-family: var(--f-sans); font-weight: 600; font-size: var(--fs-26); }
.g-lbl { color: var(--ink-3); margin-top: var(--sp-4); }
/* the lower half: one chart, its range row above */
.rc-rng { display: flex; align-items: center; margin-top: var(--sp-24); height: 28px; border-bottom: var(--bw-1) solid var(--line-1); color: var(--ink-3); }
.rc-rng .seg { margin-left: auto; gap: var(--sp-16); }
.rc-rng .seg-tab { font-size: var(--fs-14); line-height: var(--lh-14); }
.rk-card .chart { margin-top: var(--sp-12); }
.ch-area { fill: var(--chart-pos-area); }
.ch-last { fill: var(--ink-1); stroke: var(--surface-2); stroke-width: 3; paint-order: stroke; }
.rc-about { display: flex; gap: var(--sp-24); margin-top: auto; align-items: baseline; }
.rc-h { flex: none; width: 88px; color: var(--ink-3); }
.rc-about p { margin: 0; color: var(--ink-2); text-wrap: pretty; }
"""

# ------------------------------------------------------------------ strings (TR first; EN for the width pass)
STR = {
    "ctx": ("Nisan 2012 · Akıllı telefon dalgası listeyi taşıyor", "April 2012 · The smartphone wave carries the list"),
    "k_list": ("Liste değeri", "List value"), "k_lead": ("Lider · {name}", "Leader · {name}"), "k_you": ("Senin değerlemen", "Your valuation"),
    "d_list": ("{c} şirket · son 13 hafta", "{c} companies · last 13 weeks"),
    "d_lead": ("{sector} · son 13 hafta", "{sector} · last 13 weeks"),
    "d_you": ("Seed sonrası · Nisan 2012", "Post seed · April 2012"),
    "more": ("ve {c} şirket daha", "and {c} more"),
    "founder": ("Kurucu", "Founder"), "ceo": ("CEO", "CEO"), "ipo": ("Halka arz {y}", "Listed {y}"),
    "cap": ("Piyasa değeri · Nisan 2012", "Market value · April 2012"),
    "four_w": ("dört haftada", "over four weeks"),
    "eoy_first": ("Yıl sonu {y}", "Year end {y}"), "since": ("{y} sonundan beri", "Since end of {y}"),
    "share": ("Listedeki payı", "Share of the list"),
    "value": ("Değer", "Value"),
    "about": ("Hakkında", "About"),
    "about_malus": ("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
                    "gelirinin yarısından çoğu bugün o tek üründen geliyor.",
                    "A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
                    "handset market; more than half its revenue now comes from that one product."),
}


def s(key, **kw):
    v = STR[key][0 if gen.common.LANG == "tr" else 1]
    return v.format(**kw) if kw else v


def up(p, dec=1, size=12):
    return '<span class="pct up">%s%s</span>' % (ic("tri_up", size), n(gen.pct_txt(p, dec)))


# ------------------------------------------------------------------ tiles
def bars(vals):
    lo, hi = min(vals), max(vals)
    H = lambda v: 5 + (v - lo) / float(hi - lo or 1) * 19
    return '<div class="kt-bars">%s</div>' % "".join('<i style="height:%.0fpx"></i>' % H(v) for v in vals)


def tile(key, value, desc, pct=None, spark=""):
    return ('<div class="kt"><span class="kt-k t-label">%s</span><span class="kt-v"><span class="t-tile">%s</span>%s</span>'
            '<div class="kt-foot"><span class="kt-d t-caption">%s</span>%s</div></div>' % (key, value, up(pct, size=14) if pct else "", desc, spark))


def tiles(rows, leader, week, value_m):
    total = sum(r["value_b"] for r in rows)
    old = sum(r["value_b"] / (1 + r["pct_4w"] / 100.0) for r in rows)
    idx = (total / old - 1) * 100
    # the list's 13 weekly totals: the sum of the rows' series; the four-week pin of every row lands on one index, so that
    # point is read as the mean of its neighbours (the tile shows the level, the change is the figure beside the value)
    lst = [sum(series(r, week)[i] for r in rows) for i in range(52 - BARS, 52)]
    lst[-5] = (lst[-6] + lst[-4]) / 2
    lead = series(leader, week, gen.POMELO_HIST)[-BARS:]
    sec = leader["sector_tr"] if gen.common.LANG == "tr" else leader["sector_en"]
    return '<div class="kts">%s%s%s</div>' % (
        tile(s("k_list"), n(money_b(total)), s("d_list", c=len(rows)), idx, bars(lst)),
        tile(s("k_lead", name=leader["name"]), n(money_b(leader["value_b"])), s("d_lead", sector=sec), leader["pct_4w"], bars(lead)),
        tile(s("k_you"), n(gen.money_m(value_m)), s("d_you")))


# ------------------------------------------------------------------ list
def row(r, top, selected):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    nm, vl = ("t-value", "t-value") if top else ("t-data-strong", "t-data")
    cls = "row grid" + (" top" if top else "") + (" is-selected" if selected else "")
    return ('<div class="%s"><span class="rk-r t-small">%d</span><span class="rk-co"><span class="rk-nm %s">%s</span><span class="rk-sc t-small">%s</span></span>'
            '<span class="rk-vl %s">%s</span></div>' % (cls, r["rank"], nm, r["name"], sec, vl, n(money_b(r["value_b"]))))


def list_col(rows, selected):
    html = "".join(row(r, i < 3, r["name"] == selected) for i, r in enumerate(rows[:SHOWN]))
    return '<div class="rk-list"><div class="tbl"><div class="rows">%s</div></div><div class="rk-more t-caption">%s</div></div>' % (html, s("more", c=len(rows) - SHOWN))


# ------------------------------------------------------------------ card
def gauge(share, w=200, h=104):
    cx, cy, R = w / 2.0, h - 4, 88
    P = lambda t: (cx - R * math.cos(math.pi * t), cy - R * math.sin(math.pi * t))
    (x0, y0), (x1, y1), (xs, ys) = P(0), P(1), P(share)
    g = ['<path class="g-track" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>' % (x0, y0, R, R, x1, y1),
         '<path class="g-arc" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>' % (x0, y0, R, R, xs, ys),
         '<line class="g-tick" x1="%.1f" x2="%.1f" y1="%.1f" y2="%.1f"/>' % (x0, x0, y0 - 6, y0 + 6),
         '<line class="g-tick" x1="%.1f" x2="%.1f" y1="%.1f" y2="%.1f"/>' % (x1, x1, y1 - 6, y1 + 6),
         '<text class="g-num" x="%.1f" y="%.1f" text-anchor="middle">%s</text>' % (cx, cy - 6, n(gen.pct_txt(share * 100, dec=0)))]
    return '<div class="rc-gauge"><svg width="%d" height="%d">%s</svg><span class="g-lbl t-caption">%s</span></div>' % (w, h, "".join(g), s("share"))


def chart5y(vals, week, w=934, h=256):
    """Weekly points from January 2008 to today, the area under the line filled; a tick and the year at every January."""
    pad_l, pad_r, pad_t, pad_b = 56, 12, 12, 24
    hi = max(vals)
    base = 10 ** math.floor(math.log10(hi))
    for step in (base / 2, base, base * 2, base * 5):
        yhi = math.ceil(hi / step) * step
        if yhi / step <= 4:
            break
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi) * (h - pad_t - pad_b)
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
    pts = " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals))
    g.append('<polygon class="ch-area" points="%.1f,%.1f %s %.1f,%.1f"/>' % (X(0), Y(0), pts, X(len(vals) - 1), Y(0)))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    g.append('<polyline class="ch-line" points="%s"/>' % pts)
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def ranges():
    tabs = [("r_13w", False), ("r_1y", False), ("r_5y", True), ("r_all", False)]
    return '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if on else "", gen.s(k)) for k, on in tabs)


def card(r, rows, week, hist, ceo, ipo_year):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    years = sorted(hist)[1:]
    years.reverse()
    kv = ['<span class="rc-k t-caption">%s</span><span class="rc-n t-data">%s</span>' % (s("eoy_first", y=y) if i == 0 else y, n(money_b(hist[y])))
          for i, y in enumerate(years)]
    kv.append('<span class="rc-k t-caption">%s</span><span class="rc-n t-data">%s</span>' % (s("since", y=years[0]), up((r["value_b"] / hist[years[0]] - 1) * 100, dec=0)))
    share = r["value_b"] / sum(x["value_b"] for x in rows)
    pts = series(r, week, hist, points=223)   # the first point falls in January 2008; December anchors pin the year-end values
    return ('<div class="rk-card">'
            '<div class="rc-head"><span class="rc-nm t-display">%s</span>%s<span class="rc-ipo t-caption">%s</span></div>'
            '<div class="rc-sub t-caption"><span>%s <b>%s</b></span><span>%s <b>%s</b></span></div>'
            '<div class="rc-panes">'
            '<div class="rc-pane"><span class="rc-hero t-big">%s</span><span class="rc-cap t-caption">%s</span><span class="rc-why t-caption">%s<span>%s</span></span></div>'
            '<div class="rc-pane"><div class="rc-kv">%s</div></div>'
            '<div class="rc-pane">%s</div>'
            '</div>'
            '<div class="rc-rng"><span class="t-label">%s</span>%s</div>%s'
            '<div class="rc-about"><span class="rc-h t-label">%s</span><p class="t-body">%s</p></div>'
            '</div>'
            % (r["name"], tag(sec, "outline"), s("ipo", y=ipo_year),
               s("founder"), r["person"], s("ceo"), ceo,
               n(money_b(r["value_b"])), s("cap"), up(r["pct_4w"]), s("four_w"),
               "".join(kv),
               gauge(share),
               s("value"), ranges(), chart5y(pts, week),
               s("about"), s("about_malus")))


# ------------------------------------------------------------------ window and frame
def window(inner):
    x, y, w, h = WIN
    head = ('<div class="win-head rk"><h1 class="win-title t-h1">%s</h1><span class="ctx t-body">%s</span><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (gen.s("tab_piyasa"), s("ctx"), ic("close")))
    return '<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s%s</section>' % (x, y, w, h, head, inner)


def build(week=14):
    rows = listed(week)
    malus = next(r for r in rows if r["name"] == "Malus")
    value_m = gen.SEED["player"]["seed_post_money_m"]
    inner = tiles(rows, malus, week, value_m) + '<div class="rk-body">%s%s</div>' % (
        list_col(rows, "Malus"), card(malus, rows, week, gen.POMELO_HIST, "Timo Koch", 1980))
    html = gen.page(gen.screen(gen.topbar(gen.TOP_SEED), gen.rail("piyasa", gen.B_THEME), window(inner), gen.news_market()))
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    out = os.path.join(gen.BUILD, "rk_v1.html")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(build())
    print("built", out)
