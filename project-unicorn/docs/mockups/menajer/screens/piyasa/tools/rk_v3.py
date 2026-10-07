"""rk_v3: the Market window's COMPANY page (Malus) on the rk_v2 skeleton, after the owner's reading of v2: cleaner,
plainer, more finished; less data; the game in it; no rank anywhere, the player's valuation instead. Three tiles in
one language (the third is the player's, from rk_v1), a four-row period table in the Plutocracy "Finances" pattern
(no tree, no year sentences: those belong to the Yıllar tab), the dial, the identity quartet and two sentences of
About on the right, and a five-year strip whose anchors are the table's own numbers. Builds ../build/rk_v3.html.

  python rk_v3.py

The shell (top bar, rail, office plate, ticker), the seed, the number forms and the 13-week series are gen.py's.
"""
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen  # noqa: E402
from gen import L, n, money_b, ic, listed, series, _d  # noqa: E402

WIN = (208, 88, 1424, 928)
BARS = 13
# the comparison period: year-end 2011 (the list's total and the gap to the second company are the mockup's own numbers;
# the company's value is POMELO_HIST[2011])
EOY = dict(year=2011, list_total=2190.0, gap=130.0)

CSS = """
/* window head: back, title with the company name (a proper noun, never caps), page tabs */
.rk-head { gap: var(--sp-16); }
.rk-head .back { margin-left: calc(-1 * var(--sp-12)); color: var(--ink-3); }
.rk-head .back .ic { width: 16px; height: 16px; }
.rk-head .ttl { display: flex; align-items: baseline; gap: var(--sp-12); color: var(--ink-1); white-space: nowrap; }
.rk-head .ttl .dot { color: var(--ink-4); }
.rk-head .ttl .co { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-30); line-height: var(--lh-30); }
.rk-head .seg { margin-right: var(--sp-24); }
/* body: four bands; the middle band takes the slack so the strip sits on the floor */
.rk-body { display: flex; flex-direction: column; gap: var(--sp-20); padding: var(--sp-16) var(--sp-24) var(--sp-24); }
.rk-body > * { flex: none; }
.rk-ctx { color: var(--ink-3); white-space: nowrap; }
/* tiles: one language for all three (raised ground, condensed figure, ink-3 line, thirteen bars with the last lit);
   the player's tile has no bars and keeps the room empty */
.tiles { display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--sp-16); }
.tile { display: flex; flex-direction: column; height: 136px; padding: var(--sp-16) var(--sp-20);
  background: var(--surface-4); border: var(--bw-1) solid var(--line-2); border-radius: var(--r-3); }
.tile .k { color: var(--ink-3); }
.tile .v { display: flex; align-items: baseline; gap: var(--sp-12); margin-top: var(--sp-2); }
.tile .v .big { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-40); line-height: 44px; color: var(--ink-1); }
.tile .v .pct { gap: var(--sp-4); }
.tile .v .pct .ic { width: 14px; height: 14px; }
.tile .d { color: var(--ink-3); white-space: nowrap; }
.tile .bars { display: flex; align-items: flex-end; gap: var(--sp-4); height: 24px; margin-top: auto; }
.tile .bars i { flex: 1; background: var(--ink-3); border-radius: var(--r-1); }
.tile .bars i:last-child { background: var(--ink-1); }
/* middle: the period table (left) and the dial, identity and about (right) */
.mid { flex: 1 1 auto !important; min-height: 0; display: grid; grid-template-columns: 1fr 520px; gap: var(--sp-40); align-items: start; }
.sec-h { display: flex; align-items: center; height: 28px; color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
.vt .grid { grid-template-columns: 1fr 144px 144px 128px; column-gap: var(--sp-8); }
.vt .tbl-head { height: 36px; padding-bottom: var(--sp-8); }
.vt .th { padding-right: var(--sp-4); }
.vt .row { height: 56px; }
.vt .cell.lbl { color: var(--ink-2); }
.vt .cell.num { text-align: right; padding-right: var(--sp-4); color: var(--ink-2); }
.vt .cell.now { color: var(--ink-1); font-weight: 500; }
.vt .cell.chg { display: flex; justify-content: flex-end; padding-right: var(--sp-4); }
.vt .cell.chg .pct { gap: var(--sp-4); }
.side { display: flex; flex-direction: column; gap: var(--sp-16); }
.dial { position: relative; display: flex; flex-direction: column; align-items: center; gap: var(--sp-4); padding-top: var(--sp-8); }
.dial .arc-rest { fill: none; stroke: var(--ink-4); stroke-width: 6; stroke-linecap: round; }
.dial .arc-share { fill: none; stroke: var(--ink-2); stroke-width: 6; stroke-linecap: round; }
.dial .big { position: absolute; left: 0; right: 0; top: 60px; text-align: center; font-family: var(--f-cond); font-weight: 700;
  font-size: var(--fs-40); line-height: 44px; color: var(--ink-1); }
.dial .cap { color: var(--ink-3); white-space: nowrap; }
.idk { display: flex; gap: var(--sp-32); padding-top: var(--sp-4); }
.idk > div { display: flex; flex-direction: column; gap: var(--sp-2); }
.idk .k { color: var(--ink-3); }
.idk .n { color: var(--ink-2); white-space: nowrap; }
.about { margin: 0; color: var(--ink-2); text-wrap: pretty; }
/* bottom: the five-year strip */
.strip { display: flex; flex-direction: column; gap: var(--sp-8); }
.strip .sec-h .seg { margin-left: auto; gap: var(--sp-16); }
.strip .sec-h .seg-tab { font-size: var(--fs-14); line-height: var(--lh-14); }
.ch-last { fill: var(--ink-1); stroke: var(--surface-3); stroke-width: 3; paint-order: stroke; }
.ch-yr { fill: var(--ink-4); stroke: var(--surface-3); stroke-width: 2; paint-order: stroke; }
"""

# ------------------------------------------------------------------ strings (EN first, TR second: the new keys for INDEX.md)
NEW = {
    "back": ("List", "Liste"),
    "tab_ozet": ("Summary", "Özet"), "tab_yillar": ("Years", "Yıllar"), "tab_benzer": ("Peers", "Benzerler"),
    "ctx": ("April 2012 · The smartphone wave carries the list; the first big social-network IPO comes in May.",
            "Nisan 2012 · Akıllı telefon dalgası listeyi taşıyor; sosyal ağların ilk büyük halka arzı mayısta."),
    "k_value": ("Market value", "Piyasa değeri"), "d_value": ("Last 13 weeks", "Son 13 hafta"),
    "k_list": ("List", "Liste"), "d_list": ("{count} companies · last 13 weeks", "{count} şirket · son 13 hafta"),
    "k_you": ("Your valuation", "Senin değerlemen"), "d_you": ("Post seed · April 2012", "Seed sonrası · Nisan 2012"),
    "h_value": ("Value", "Değer"),
    "col_now": ("April 2012", "Nisan 2012"), "col_eoy": ("Year end {y}", "Yıl sonu {y}"), "col_change": ("Change", "Değişim"),
    "r_value": ("Market value", "Piyasa değeri"), "r_share": ("Share of the list", "Listedeki payı"),
    "r_total": ("List total", "Liste toplamı"), "r_gap": ("Gap to the next company", "Sıradaki şirkete fark"),
    "pts": ("{p} points", "{p} puan"),
    "h_share": ("Share of the list", "Listedeki payı"), "dial_cap": ("of {total} across {count} companies", "{count} şirketin {total} toplamında"),
    "founder": ("Founder", "Kurucu"), "ceo": ("CEO", "CEO"), "ipo": ("Listed", "Halka arz"), "sector": ("Sector", "Sektör"),
    "h_chart": ("Five years", "Beş yıl"),
    "r_1y": ("1Y", "1Y"), "r_5y": ("5Y", "5Y"), "r_all": ("All", "Tümü"),
    "today": ("April 2012", "Nisan 2012"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if gen.common.LANG == "tr" else en
    return v.format(**kw) if kw else v


def up(txt, size=12):
    """A gain: the glyph is the sign; with no text it only says the figure grew."""
    return '<span class="pct up">%s%s</span>' % (ic("tri_up", size), txt)


# ------------------------------------------------------------------ tiles
def bars(vals):
    lo, hi = min(vals), max(vals)
    return '<div class="bars">%s</div>' % "".join('<i style="height:%.0fpx"></i>' % (8 + (v - lo) / float(hi - lo or 1) * 16) for v in vals)


def tile(key, big, desc, pct=None, foot=""):
    p = up(n(gen.pct_txt(pct)), 14) if pct is not None else ""
    return ('<div class="tile"><span class="k t-label">%s</span><div class="v"><span class="big">%s</span>%s</div>'
            '<span class="d t-caption">%s</span>%s</div>' % (key, big, p, desc, foot))


def tiles(r, rows, week, hist, value_m):
    total = sum(x["value_b"] for x in rows)
    old = sum(x["value_b"] / (1 + x["pct_4w"] / 100.0) for x in rows)
    # the list's 13 weekly totals: the sum of the rows' series; every row's four-week pin lands on one index, so that
    # point is read as the mean of its neighbours (the figure beside the value carries the change)
    lst = [sum(series(x, week)[i] for x in rows) for i in range(52 - BARS, 52)]
    lst[-5] = (lst[-6] + lst[-4]) / 2
    return '<div class="tiles">%s%s%s</div>' % (
        tile(s("k_value"), n(money_b(r["value_b"])), s("d_value"), r["pct_4w"], bars(series(r, week, hist, points=BARS))),
        tile(s("k_list"), n(money_b(total)), s("d_list", count=len(rows)), (total / old - 1) * 100, bars(lst)),
        tile(s("k_you"), n(gen.money_m(value_m)), s("d_you")))


# ------------------------------------------------------------------ the period table: today against year end, four rows
def value_table(r, rows, hist):
    total = sum(x["value_b"] for x in rows)
    gap = r["value_b"] - rows[1]["value_b"]
    share, share_eoy = r["value_b"] / total * 100, hist[EOY["year"]] / EOY["list_total"] * 100
    pct = lambda a, b: up(n(gen.pct_txt((a / b - 1) * 100, dec=0)))
    lines = [(s("r_value"), n(money_b(r["value_b"])), n(money_b(hist[EOY["year"]])), pct(r["value_b"], hist[EOY["year"]])),
             (s("r_share"), n(gen.pct_txt(share, dec=0)), n(gen.pct_txt(share_eoy, dec=0)), up(s("pts", p=round(share - share_eoy)))),
             (s("r_total"), n(money_b(total)), n(money_b(EOY["list_total"])), pct(total, EOY["list_total"])),
             (s("r_gap"), n(money_b(gap)), n(money_b(EOY["gap"])), up(""))]
    head = ('<div class="tbl-head grid"><div class="th t-label"></div><div class="th r t-label">%s</div>'
            '<div class="th r t-label">%s</div><div class="th r t-label">%s</div></div>'
            % (s("col_now"), s("col_eoy", y=EOY["year"]), s("col_change")))
    body = "".join('<div class="row grid"><div class="cell lbl t-data">%s</div><div class="cell num now t-data">%s</div>'
                   '<div class="cell num t-data">%s</div><div class="cell chg t-data">%s</div></div>' % ln for ln in lines)
    return '<div class="vt"><div class="sec-h t-label">%s</div><div class="tbl">%s<div class="rows">%s</div></div></div>' % (s("h_value"), head, body)


# ------------------------------------------------------------------ side: the dial, the identity quartet, about
def dial(share, count, total, w=220, h=104):
    cx, cy, rad = w / 2.0, h - 6, 90
    pt = lambda deg: (cx + rad * math.cos(math.radians(180 - deg)), cy - rad * math.sin(math.radians(180 - deg)))
    x0, y0 = pt(0)
    x1, y1 = pt(180)
    xs, ys = pt(180 * share / 100.0)
    g = ('<path class="arc-rest" d="M%.1f,%.1f A%d,%d 0 0 1 %.1f,%.1f"/><path class="arc-share" d="M%.1f,%.1f A%d,%d 0 0 1 %.1f,%.1f"/>'
         % (x0, y0, rad, rad, x1, y1, x0, y0, rad, rad, xs, ys))
    return ('<div class="dial"><svg width="%d" height="%d">%s</svg><span class="big">%s</span><span class="cap t-caption">%s</span></div>'
            % (w, h, g, n(gen.pct_txt(share, dec=0)), s("dial_cap", count=count, total=n(money_b(total)))))


def identity(r, ceo, ipo_year):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    kv = [(s("founder"), r["person"]), (s("ceo"), ceo), (s("ipo"), str(ipo_year)), (s("sector"), sec)]
    return '<div class="idk">%s</div>' % "".join('<div><span class="k t-caption">%s</span><span class="n t-data">%s</span></div>' % p for p in kv)


def side(r, rows, about):
    total = sum(x["value_b"] for x in rows)
    return ('<div class="side"><div class="sec-h t-label">%s</div>%s%s<p class="about t-body">%s</p></div>'
            % (s("h_share"), dial(r["value_b"] / total * 100, len(rows), total), identity(r, "Timo Koch", 1980), about))


# ------------------------------------------------------------------ the five-year strip: the table's anchors, straight lines between
def five_year(r, hist, week):
    """Weekly values from the last week of 2008 to today. The anchors are the year-end values the table lists and today's
    value; between them a straight line with a faint noise that dies at every anchor. Returns the values and the
    (index, label) of each anchor."""
    last = {}
    for w in range(-240, week + 1):
        last[_d(w).year] = w
    anchors = {last[y]: (v, str(y)) for y, v in hist.items() if y >= 2008}
    anchors[week] = (r["value_b"], s("today"))
    keys = sorted(anchors)
    w0 = keys[0]
    rnd = random.Random(r["name"])
    ph = [rnd.uniform(0, 2 * math.pi) for _ in range(3)]
    out = []
    for w in range(w0, week + 1):
        a = max(k for k in keys if k <= w)
        b = min(k for k in keys if k >= w)
        base = anchors[a][0] if a == b else anchors[a][0] + (anchors[b][0] - anchors[a][0]) * (w - a) / float(b - a)
        t = (w - w0) / float(week - w0)
        noise = sum(math.sin(2 * math.pi * (k + 1) * 2.3 * t + ph[k]) / (k + 1) for k in range(3)) * 0.035
        fade = min(1.0, min(abs(w - k) for k in keys) / 5.0)
        out.append(base * (1 + noise * fade))
    return out, [(k - w0, anchors[k][1]) for k in keys]


def chart5y(vals, marks, w=1376, h=200):
    pad_l, pad_r, pad_t, pad_b = 56, 16, 12, 24
    step = 200.0
    yhi = math.ceil(max(vals) / step) * step
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / yhi * (h - pad_t - pad_b)
    g = []
    for k in range(1, int(yhi / step) + 1):
        g.append('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % (pad_l, w - pad_r, Y(k * step), Y(k * step)))
        g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(k * step) + 4, n(money_b(k * step))))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    for i, label in marks:
        anchor = "end" if i == len(vals) - 1 else "middle"
        g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
        g.append('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="%s">%s</text>' % (X(i), h - 4, anchor, label))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    for i, _ in marks[:-1]:
        g.append('<circle class="ch-yr" cx="%.1f" cy="%.1f" r="3"/>' % (X(i), Y(vals[i])))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def strip(r, week, hist):
    tabs = [("r_1y", False), ("r_5y", True), ("r_all", False)]
    seg = '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if on else "", s(k)) for k, on in tabs)
    vals, marks = five_year(r, hist, week)
    return '<div class="strip"><div class="sec-h t-label">%s%s</div>%s</div>' % (s("h_chart"), seg, chart5y(vals, marks))


# ------------------------------------------------------------------ window and frame
def window(r, body):
    x, y, w, h = WIN
    tabs = [("tab_ozet", True), ("tab_yillar", False), ("tab_benzer", False)]
    seg = '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if on else "", s(k)) for k, on in tabs)
    head = ('<div class="win-head rk-head"><span class="btn btn-ghost btn-sm back">%s%s</span>'
            '<div class="ttl"><h1 class="t-h1" style="margin:0">%s</h1><span class="dot t-h2">·</span><span class="co">%s</span></div>'
            '<div class="grow"></div>%s<span class="win-close">%s</span></div>'
            % (ic("chevleft"), s("back"), gen.s("tab_piyasa"), r["name"], seg, ic("close")))
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s<div class="win-body rk-body">%s</div></section>'
            % (x, y, w, h, head, body))


def build(week=14):
    rows = listed(week)
    malus = next(r for r in rows if r["name"] == "Malus")
    hist = gen.POMELO_HIST
    about = L("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
              "gelirinin yarısından çoğu bugün o tek üründen geliyor.",
              "A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
              "handset market; more than half its revenue now comes from that one product.")
    body = ('<div class="rk-ctx t-meta">%s</div>%s<div class="mid">%s%s</div>%s'
            % (s("ctx"), tiles(malus, rows, week, hist, gen.SEED["player"]["seed_post_money_m"]),
               value_table(malus, rows, hist), side(malus, rows, about), strip(malus, week, hist)))
    html = gen.page(gen.screen(gen.topbar(gen.TOP_SEED), gen.rail("piyasa", gen.B_THEME), window(malus, body), gen.news_market()))
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    out = os.path.join(gen.BUILD, "rk_v3.html")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(build())
    print("built", out)
