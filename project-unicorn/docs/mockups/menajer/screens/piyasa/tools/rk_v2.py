"""rk_v2: the Market window as two pages, this frame is the COMPANY page (Malus), after the two references the owner
kept: Plutocracy "Finances" (three dark KPI tiles, a tree table of period comparison, the market-share dial) read in
the Menajer language, and Startup Company "Website Stats" for the reading order (hero figure, then key:value, then the
chart). Builds ../build/rk_v2.html.

  python rk_v2.py

The shell (top bar, rail, office plate, ticker), the seed, the number forms and the series builder are gen.py's; only
the window is new. The list page (not this frame) carries the player's "Senin değerlemen $4,2M" tile; the company page
shows no player at all (owner: no rank, the valuation may be shown, and only on the list).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen  # noqa: E402
from gen import L, n, money_b, ic, tag, listed, series, pct_cell, _d  # noqa: E402

WIN = (208, 88, 1424, 928)

CSS = """
/* window head: back, title with the company name (a proper noun, never caps), page tabs */
.rk-head { gap: var(--sp-16); }
.rk-head .back { margin-left: calc(-1 * var(--sp-12)); color: var(--ink-3); }
.rk-head .back .ic { width: 16px; height: 16px; }
.rk-head .ttl { display: flex; align-items: baseline; gap: var(--sp-12); color: var(--ink-1); white-space: nowrap; }
.rk-head .ttl .dot { color: var(--ink-4); }
.rk-head .ttl .co { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-30); line-height: var(--lh-30); }
.rk-head .seg { margin-right: var(--sp-24); }
/* body: one column of four bands */
.rk-body { display: flex; flex-direction: column; gap: var(--sp-20); padding: var(--sp-16) var(--sp-24) var(--sp-24); }
.rk-ctx { flex: none; color: var(--ink-3); white-space: nowrap; }
.rk-body > * { flex: none; }
/* KPI tiles: raised ground, big condensed figure, one explanation line, mini bars with the last one lit */
.tiles { display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--sp-16); }
.tile { display: flex; flex-direction: column; height: 136px; padding: var(--sp-16) var(--sp-20);
  background: var(--surface-4); border: var(--bw-1) solid var(--line-2); border-radius: var(--r-3); }
.tile .k { color: var(--ink-3); }
.tile .v { display: flex; align-items: baseline; gap: var(--sp-12); margin-top: var(--sp-2); }
.tile .v .big { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-40); line-height: 44px; color: var(--ink-1); }
.tile .v .pct { gap: var(--sp-4); }
.tile .v .pct .ic { width: 14px; height: 14px; }
.tile .d { color: var(--ink-3); }
.tile .bars { display: flex; align-items: flex-end; gap: var(--sp-4); height: 24px; margin-top: auto; }
.tile .bars i { flex: 1; background: var(--bar-fill); border-radius: var(--r-1); opacity: .55; }
.tile .bars i:last-child { background: var(--bar-emph); opacity: 1; }
.tile .pw { position: relative; height: 6px; margin-top: auto; background: var(--bar-track); border-radius: var(--r-1); }
.tile .pw i { position: absolute; left: 0; top: 0; bottom: 0; background: var(--bar-emph); border-radius: var(--r-1); }
/* middle: the value table (years as the tree under the root) and the side column (dial, identity, about) */
.mid { display: grid; grid-template-columns: 1fr 456px; gap: var(--sp-40); align-items: start; }
.sec-h { display: flex; align-items: center; height: 28px; color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
.vt .grid { grid-template-columns: 1fr 128px 112px; column-gap: var(--sp-8); }
.vt .tbl-head { height: 32px; padding-bottom: var(--sp-6); }
.vt .row.root { height: 44px; }
.vt .row.yr { height: 48px; }
.vt .cell.lbl { display: flex; flex-direction: column; justify-content: center; gap: var(--sp-2); }
.vt .row.root .cell.lbl .nm { color: var(--ink-1); }
.vt .row.yr .cell.lbl { position: relative; padding-left: 28px; }
.vt .row.yr .cell.lbl::before { content: ""; position: absolute; left: 6px; top: 10px; width: 10px; height: 12px;
  border-left: var(--bw-1) solid var(--line-3); border-bottom: var(--bw-1) solid var(--line-3); border-radius: 0 0 0 2px; }
.vt .cell.lbl .nm { color: var(--ink-2); }
.vt .cell.lbl .st { color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.vt .cell.num { text-align: right; color: var(--ink-2); }
.vt .row.root .cell.num { color: var(--ink-1); font-weight: 500; }
.vt .cell.chg { display: flex; justify-content: flex-end; padding-right: var(--sp-4); }
.side { display: flex; flex-direction: column; gap: var(--sp-16); }
.dial { position: relative; display: flex; flex-direction: column; align-items: center; gap: var(--sp-4); padding-top: var(--sp-8); }
.dial .arc-track { fill: none; stroke: var(--bar-track); stroke-width: 6; stroke-linecap: round; }
.dial .arc-share { fill: none; stroke: var(--chart-line); stroke-width: 6; stroke-linecap: round; }
.dial .tick { stroke: var(--chart-axis); stroke-width: 1; }
.dial .big { position: absolute; left: 0; right: 0; top: 60px; text-align: center; font-family: var(--f-cond); font-weight: 700;
  font-size: var(--fs-40); line-height: 44px; color: var(--ink-1); }
.dial .cap { color: var(--ink-3); white-space: nowrap; }
.idk { display: flex; gap: var(--sp-32); padding-top: var(--sp-8); }
.idk > div { display: flex; flex-direction: column; gap: var(--sp-2); }
.idk .k { color: var(--ink-3); }
.idk .n { color: var(--ink-2); display: flex; align-items: center; gap: var(--sp-8); }
.about { color: var(--ink-2); text-wrap: pretty; }
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
    "k_value": ("Market value", "Piyasa değeri"), "d_value": ("Last 13 weeks · change over 4 weeks", "Son 13 hafta · değişim 4 haftalık"),
    "k_eoy": ("Year end {y}", "Yıl sonu {y}"), "d_eoy": ("Year-end values {a} to {b}", "{a}'den {b}'e yıl sonu değerleri"),
    "k_share": ("Share of the list", "Listedeki payı"), "d_share": ("{count} companies · {total} in all", "{count} şirket · toplam {total}"),
    "h_table": ("Value by year", "Yıllara göre değer"),
    "col_year": ("Year", "Yıl"), "col_value": ("Value", "Değer"), "col_change": ("Change", "Değişim"),
    "root": ("Market value · {y} today", "Piyasa değeri · {y} bugün"),
    "st_2011": ("The founder hands the chair to Koch; the phone's fourth model ships.", "Kurucu koltuğu Koch'a bırakıyor; telefonun dördüncü modeli çıkıyor."),
    "st_2010": ("The tablet ships; the smartphone wave carries the whole list.", "Tablet çıkıyor; akıllı telefon dalgası tüm listeyi taşıyor."),
    "st_2009": ("The app store's second year; the phone's third model.", "Uygulama mağazasının ikinci yılı; telefonun üçüncü modeli."),
    "st_2008": ("The crisis year; the app store opens.", "Kriz yılı; uygulama mağazası açılıyor."),
    "st_2007": ("The first phone ships.", "İlk telefon çıkıyor."),
    "h_share": ("Share of the list", "Listedeki payı"), "dial_cap": ("of {total} across {count} companies", "{count} şirketin {total} toplamında"),
    "founder": ("Founder", "Kurucu"), "ceo": ("CEO", "CEO"), "ipo": ("Listed", "Halka arz"), "sector": ("Sector", "Sektör"),
    "about": ("About", "Hakkında"),
    "h_chart": ("Five years", "Beş yıl"),
    "r_1y": ("1Y", "1Y"), "r_5y": ("5Y", "5Y"), "r_all": ("All", "Tümü"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if gen.common.LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ tiles
def bars(vals):
    hi = max(vals)
    return '<div class="bars">%s</div>' % "".join('<i style="height:%d%%"></i>' % max(8, round(v / hi * 100)) for v in vals)


def tile(key, big, desc, foot, pct=None):
    p = pct_cell(pct, "pct t-value") if pct is not None else ""
    return ('<div class="tile"><span class="k t-label">%s</span><div class="v"><span class="big">%s</span>%s</div>'
            '<span class="d t-caption">%s</span>%s</div>' % (key, big, p, desc, foot))


def tiles(r, hist, week, share, count, total):
    years = sorted(hist)   # 2007 to 2011, one year-end bar each
    return '<div class="tiles">%s%s%s</div>' % (
        tile(s("k_value"), n(money_b(r["value_b"])), s("d_value"), bars(series(r, week, hist, points=13)), pct=r["pct_4w"]),
        tile(s("k_eoy", y=years[-1]), n(money_b(hist[years[-1]])), s("d_eoy", a=years[0], b=years[-1]), bars([hist[y] for y in years])),
        tile(s("k_share"), n(gen.pct_txt(share, dec=0)), s("d_share", count=count, total=n(money_b(total))),
             '<div class="pw"><i style="width:%d%%"></i></div>' % round(share)))


# ------------------------------------------------------------------ the value table: the root is today, the years hang under it
def value_table(r, hist):
    head = ('<div class="tbl-head grid"><div class="th t-label">%s</div><div class="th r t-label">%s</div>'
            '<div class="th r t-label" style="padding-right:4px">%s</div></div>' % (s("col_year"), s("col_value"), s("col_change")))
    years = sorted(hist)
    rows = ['<div class="row root grid"><div class="cell lbl"><span class="nm t-data-strong">%s</span></div>'
            '<div class="cell num t-value">%s</div>%s</div>'
            % (s("root", y=2012), n(money_b(r["value_b"])), pct_cell((r["value_b"] / hist[years[-1]] - 1) * 100, "cell chg t-data", dec=0))]
    for y in reversed(years):   # the first year has no earlier value: its change cell stays empty (rule 9)
        ch = (hist[y] / hist[y - 1] - 1) * 100 if y - 1 in hist else None
        rows.append('<div class="row yr grid"><div class="cell lbl"><span class="nm t-data">%d</span><span class="st t-caption">%s</span></div>'
                    '<div class="cell num t-data">%s</div>%s</div>'
                    % (y, s("st_%d" % y), n(money_b(hist[y])), pct_cell(ch, "cell chg t-data", dec=0)))
    return '<div class="vt"><div class="sec-h t-label">%s</div><div class="tbl">%s<div class="rows">%s</div></div></div>' % (s("h_table"), head, "".join(rows))


# ------------------------------------------------------------------ side: the dial, the identity card, about
def dial(share, count, total, w=220, h=104):
    cx, cy, rad = w / 2.0, h - 6, 90
    pt = lambda deg: (cx + rad * math.cos(math.radians(180 - deg)), cy - rad * math.sin(math.radians(180 - deg)))
    a = 180 * share / 100.0
    x0, y0 = pt(0)
    x1, y1 = pt(180)
    xs, ys = pt(a)
    g = ['<path class="arc-track" d="M%.1f,%.1f A%d,%d 0 0 1 %.1f,%.1f"/>' % (x0, y0, rad, rad, x1, y1),
         '<path class="arc-share" d="M%.1f,%.1f A%d,%d 0 0 1 %.1f,%.1f"/>' % (x0, y0, rad, rad, xs, ys)]
    for deg in (45, 90, 135):   # the quarter ticks sit inside the arc, the dial's only scale
        ax, ay = pt(deg)
        bx, by = cx + (rad - 12) * math.cos(math.radians(180 - deg)), cy - (rad - 12) * math.sin(math.radians(180 - deg))
        g.append('<line class="tick" x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f"/>' % (ax, ay, bx, by))
    return ('<div class="dial"><svg width="%d" height="%d">%s</svg><span class="big">%s</span><span class="cap t-caption">%s</span></div>'
            % (w, h, "".join(g), n(gen.pct_txt(share, dec=0)), s("dial_cap", count=count, total=n(money_b(total)))))


def identity(r, ceo, ipo_year):
    sec = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    kv = [(s("founder"), r["person"]), (s("ceo"), ceo), (s("ipo"), str(ipo_year)), (s("sector"), tag(sec, "outline"))]
    return '<div class="idk">%s</div>' % "".join('<div><span class="k t-caption">%s</span><span class="n t-data">%s</span></div>' % p for p in kv)


def side(r, share, count, total, about):
    return ('<div class="side"><div class="sec-h t-label">%s</div>%s%s<p class="about t-body">%s</p></div>'
            % (s("h_share"), dial(share, count, total), identity(r, "Timo Koch", 1980), about))


# ------------------------------------------------------------------ the five-year strip
def chart5y(vals, week, w=1374, h=200):
    """Weekly points from January 2008 to today: a tick and the year at every January, three or four gridlines, the
    December year-end points ringed so the strip and the table agree by eye."""
    pad_l, pad_r, pad_t, pad_b = 56, 16, 12, 24
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
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    for i in range(1, len(vals)):   # the last tick of each December: the year-end value the table lists
        if _d(w0 + i).year != _d(w0 + i - 1).year:
            g.append('<circle class="ch-yr" cx="%.1f" cy="%.1f" r="3"/>' % (X(i - 1), Y(vals[i - 1])))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def strip(r, week, hist):
    tabs = [("r_1y", False), ("r_5y", True), ("r_all", False)]
    seg = '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if on else "", s(k)) for k, on in tabs)
    pts = series(r, week, hist, points=223)   # the first point falls in January 2008; December anchors pin the year-end values
    return '<div class="strip"><div class="sec-h t-label">%s%s</div>%s</div>' % (s("h_chart"), seg, chart5y(pts, week))


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
    total = sum(r["value_b"] for r in rows)
    share = malus["value_b"] / total * 100
    about = L("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
              "gelirinin yarısından çoğu bugün o tek üründen geliyor.",
              "A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
              "handset market; more than half its revenue now comes from that one product.")
    body = ('<div class="rk-ctx t-meta">%s</div>%s<div class="mid">%s%s</div>%s'
            % (s("ctx"), tiles(malus, gen.POMELO_HIST, week, share, len(rows), total),
               value_table(malus, gen.POMELO_HIST), side(malus, share, len(rows), total, about), strip(malus, week, gen.POMELO_HIST)))
    html = gen.page(gen.screen(gen.topbar(gen.TOP_SEED), gen.rail("piyasa", gen.B_THEME), window(malus, body), gen.news_market()))
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    out = os.path.join(gen.BUILD, "rk_v2.html")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(build())
    print("built", out)
