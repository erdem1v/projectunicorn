"""Piyasa, the accepted direction (rk_v1, the owner's pick 2026-10-07): builds every frame of the V1 set into
../build/<name>.html.

  python gen_v1.py            build all frames
  python gen_v1.py <name> ... build the named frames only
  python gen_v1.py --sizes    print "name width height scale" per frame

The shell, the seed, the number forms and the 13-week series are gen.py's; the window is rk_v1's layout, kept as the
owner approved it (tile strip · short ranked list · report card), with the known faults closed: the five-year chart is
drawn from the table's own anchors (rk_v3 five_year), the leader tile's key is one word and the company name sits in
the description, the gauge is rk_v3's dial (6 px, no ticks), the sector tag is the seed's word as written, and the
player's own rank is printed nowhere. The owner's three decisions of 2026-10-07 on top: the share price sits beside the
value in the list (the list column is 460 px for it, the card narrows), the filter chips stand above the list in every
frame (36 px row, so the list shows 11 rows at 1080 and 7 at 1536), and the seed tile prints the PRD formula's value
(amount × 100 / equity). Render with render_v1.sh.
"""
import html
import math
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen  # noqa: E402
from gen import L, n, money_b, ic, tag, listed, series, _d  # noqa: E402

WIN = (208, 88, 1424, 928)
WIN_1536 = (88, 88, 1424, 712)
BARS = 13

CSS = """
/* local type: the card's name is Barlow Bold 40 as typed (a proper noun is never caps); the hero figure is Plex 40 */
.t-display { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-40); line-height: var(--lh-40); letter-spacing: 0; }
.t-big { font-family: var(--f-sans); font-weight: 600; font-size: var(--fs-40); line-height: var(--lh-40); letter-spacing: 0; }
.t-tile { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-36); line-height: var(--lh-36); letter-spacing: 0; }
.win-head.rk { gap: var(--sp-24); }
.win-head.rk .ctx { color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; min-width: 0; }
/* tile strip: three raised tiles (surface-4), one figure each; the value line keeps its height when empty (rule 9) */
.kts { flex: none; display: grid; grid-template-columns: repeat(3, 1fr); gap: var(--sp-16); padding: var(--sp-16) var(--sp-24);
  border-bottom: var(--bw-1) solid var(--line-1); }
.kt { display: flex; flex-direction: column; height: 120px; padding: var(--sp-12) var(--sp-20); background: var(--surface-4);
  border: var(--bw-1) solid var(--line-1); border-radius: var(--r-3); }
.kt-k { color: var(--ink-3); }
.kt-v { display: flex; align-items: baseline; gap: var(--sp-12); min-height: var(--lh-36); color: var(--ink-1); }
.kt-v .pct { font-family: var(--f-sans); font-weight: 500; font-size: var(--fs-15); line-height: var(--lh-15); }
.kt-foot { display: flex; align-items: flex-end; justify-content: space-between; margin-top: auto; }
.kt-d { color: var(--ink-3); }
.kt-bars { display: flex; align-items: flex-end; gap: 3px; height: 24px; }
.kt-bars i { display: block; width: 6px; background: var(--ink-3); border-radius: 1px; }
.kt-bars i:last-child { background: var(--ink-1); }
/* body: the list and the card. The list is 460 px (24 + 36 rank · name · 76 price · 88 value + 16; gaps 8): the price
   column sits between the name and the value, smaller than the value (13 under 15, 15 under 18), ink-2, tabular */
.rk-body { display: flex; flex: 1; min-height: 0; }
.rk-list { flex: none; width: 460px; display: flex; flex-direction: column; padding: var(--sp-16) var(--sp-16) 0 var(--sp-24); }
.rk-list .row { height: 52px; grid-template-columns: 36px 1fr 76px 88px; column-gap: var(--sp-8); }
.rk-r { color: var(--ink-4); padding-left: var(--sp-8); }
.rk-co { display: flex; flex-direction: column; justify-content: center; min-width: 0; }
.rk-nm { color: var(--ink-1); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.rk-nm .tag { height: 18px; padding: 0 var(--sp-4); margin-left: var(--sp-8); vertical-align: 2px; font-size: var(--fs-12); }
.rk-sc { color: var(--ink-3); white-space: nowrap; }
.rk-pr { text-align: right; color: var(--ink-2); white-space: nowrap; }
.rk-vl { text-align: right; padding-right: var(--sp-8); color: var(--ink-2); }
.row.top .rk-vl { color: var(--ink-1); }
.rk-more { height: 40px; display: flex; align-items: center; padding-left: var(--sp-8); color: var(--ink-3); }
.rk-note { height: 40px; display: flex; align-items: center; padding-left: var(--sp-8); color: var(--ink-3); }
/* filter chips above the list in every frame: a 36 px row and 12 below; selected is an ink border (rule 3), never amber */
.rk-ctl { display: flex; gap: var(--sp-8); margin-bottom: var(--sp-12); }
.rk-ctl .chip { height: 36px; color: var(--ink-3); }
.rk-ctl .chip.is-on { background: var(--surface-4); border-color: var(--ink-1); color: var(--ink-1); }
.rk-card { flex: 1; min-width: 0; display: flex; flex-direction: column; padding: var(--sp-24) var(--sp-32) var(--sp-24);
  background: var(--surface-2); border-left: var(--bw-1) solid var(--line-1); }
.rc-head { display: flex; align-items: baseline; gap: var(--sp-16); }
.rc-nm { color: var(--ink-1); }
/* the sector tag is a common noun in sentence case: the tag's caps and tracking are switched off here */
.rc-head .tag { position: relative; top: -6px; }
.tag.sec { text-transform: none; letter-spacing: 0; font-weight: 600; }
.rc-ipo { margin-left: auto; color: var(--ink-3); }
.rc-sub { display: flex; gap: var(--sp-16); margin-top: var(--sp-2); min-height: var(--lh-13); color: var(--ink-3); }
.rc-sub b { font-weight: 500; color: var(--ink-2); }
/* the upper half: hero · label:value rows · the share gauge, three panes split by rules */
.rc-panes { display: grid; grid-template-columns: 1fr 1fr 1fr; margin-top: var(--sp-24); height: 160px; }
.rc-pane { display: flex; flex-direction: column; justify-content: center; padding: 0 var(--sp-32); }
.rc-pane + .rc-pane { border-left: var(--bw-1) solid var(--line-1); }
.rc-pane:first-child { padding-left: 0; }
.rc-hero { color: var(--ink-1); }
.rc-cap { color: var(--ink-3); margin-top: var(--sp-4); }
.rc-why { display: flex; align-items: center; gap: var(--sp-6); margin-top: var(--sp-8); min-height: var(--lh-13); color: var(--ink-3); }
.rc-why .pct, .rc-n .pct { color: var(--pos); gap: var(--sp-2); }
.rc-why .pct .ic, .rc-n .pct .ic { width: 12px; height: 12px; }
.rc-kv { display: grid; grid-template-columns: 1fr auto; column-gap: var(--sp-24); align-items: center; }
.rc-k { height: 28px; display: flex; align-items: center; color: var(--ink-3); }
.rc-n { height: 28px; display: flex; align-items: center; justify-content: flex-end; color: var(--ink-2); }
/* the dial: 6 px, the share in ink-2 on an ink-4 rest, no ticks */
.rc-gauge { display: flex; flex-direction: column; align-items: center; }
.rc-gauge svg { display: block; overflow: visible; }
.g-rest { fill: none; stroke: var(--ink-4); stroke-width: 6; stroke-linecap: round; }
.g-arc { fill: none; stroke: var(--ink-2); stroke-width: 6; stroke-linecap: round; }
.g-num { fill: var(--ink-1); font-family: var(--f-sans); font-weight: 600; font-size: var(--fs-26); }
.g-lbl { color: var(--ink-3); margin-top: var(--sp-4); }
/* the lower half: one chart, its range row above */
.rc-rng { display: flex; align-items: center; margin-top: var(--sp-24); height: 28px; border-bottom: var(--bw-1) solid var(--line-1); color: var(--ink-3); }
.rc-rng .seg { margin-left: auto; gap: var(--sp-16); }
.rc-rng .seg-tab { font-size: var(--fs-14); line-height: var(--lh-14); }
.rk-card .chart { margin-top: var(--sp-12); }
.ch-area { fill: var(--chart-pos-area); }
.ch-last { fill: var(--ink-1); stroke: var(--surface-2); stroke-width: 3; paint-order: stroke; }
.ch-yr { fill: var(--ink-4); stroke: var(--surface-2); stroke-width: 2; paint-order: stroke; }
.ch-lbl.mark { fill: var(--ink-2); }
/* products (a rival of the player's sub-type): line name · the shipped step, the same words the sales objection uses */
.rc-prod { margin-top: var(--sp-24); }
.rc-prod .rc-h { display: block; height: 28px; line-height: 28px; border-bottom: var(--bw-1) solid var(--line-1); width: auto; }
.rc-prod .prod-row { height: 32px; }
.rc-about { display: flex; gap: var(--sp-24); margin-top: auto; align-items: baseline; }
.rc-h { flex: none; width: 88px; color: var(--ink-3); }
.rc-about p { margin: 0; color: var(--ink-2); text-wrap: pretty; }
/* 1536: the window is 712 tall, so the tiles and the panes give up height; the chart is 140 */
.w1536 .kts { padding: var(--sp-8) var(--sp-24); }
.w1536 .kt { height: 100px; padding: var(--sp-8) var(--sp-20) var(--sp-12); }
.w1536 .rc-panes { height: 128px; margin-top: var(--sp-16); }
.w1536 .rc-rng { margin-top: var(--sp-16); }
"""

# ------------------------------------------------------------------ strings (EN first, TR second; INDEX.md lists the new ones)
NEW = {
    # the title's context line is a period row (month + period text from the period table, I3), one entry per run year
    "ctx_2012": ("{month} · The smartphone wave carries the list", "{month} · Akıllı telefon dalgası listeyi taşıyor"),
    "ctx_2013": ("{month} · The year of mobile ads", "{month} · Mobil reklam yılı"),
    "k_list": ("List value", "Liste değeri"), "k_lead": ("Leader", "Lider"), "k_you": ("Your valuation", "Senin değerlemen"),
    "d_list": ("{c} companies · last 13 weeks", "{c} şirket · son 13 hafta"),
    "d_lead": ("{name} · {sector} · last 13 weeks", "{name} · {sector} · son 13 hafta"),
    "d_seed": ("Post seed · {month}", "Seed sonrası · {month}"),
    "d_series_a": ("Series A · Week {w}", "Series A · Hafta {w}"),
    "d_none": ("No valuation yet. Your seed round sets it.", "Değerleme henüz yok. Seed turunda belirlenir."),   # PER_NO_VALUATION, PRD §3.5
    "more": ("and {c} more", "ve {c} şirket daha"),
    "above": ("{c} more above", "{c} şirket yukarıda"),
    "lists_in": ("{name} · listing {month}", "{name} · halka arz {month}"),   # the value takes no suffix (CLAUDE.md §5)
    "new": ("New", "Yeni"),
    "founder": ("Founder", "Kurucu"), "ceo": ("CEO", "CEO"), "ipo": ("Listed {y}", "Halka arz {y}"),
    "cap": ("Market value · {month}", "Piyasa değeri · {month}"),
    "four_w": ("over four weeks", "dört haftada"),
    "eoy_first": ("Year end {y}", "Yıl sonu {y}"), "since": ("Since end of {y}", "{y} sonundan beri"),
    "share": ("Share of the list", "Listedeki payı"),
    "lt": ("<{p}", "<{p}"),
    "value": ("Value", "Değer"),
    "ipo_mark": ("listed", "halka arz"),
    "products": ("Products", "Ürünleri"),
    "about": ("About", "Hakkında"),
    "f_all": ("All", "Tümü"), "f_tech": ("Technology", "Teknoloji"), "f_fin": ("Finance", "Finans"), "f_mine": ("My sector", "Sektörüm"),
    "r_13w": ("13W", "13H"), "r_1y": ("1Y", "1Y"), "r_5y": ("5Y", "5Y"), "r_all": ("All", "Tümü"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if gen.common.LANG == "tr" else en
    return v.format(**kw) if kw else v


def month(week):
    d = _d(week)
    return "%s %d" % (L(gen.MON_TR, gen.MON_EN)[d.month - 1], d.year)


def date(week):
    """The top bar prints the run week (the game's own count), not the week of the year; equal in the run's first year."""
    d = _d(week)
    return L("Hafta %d · %s %d", "Week %d · %s %d") % (week, L(gen.MON_TR, gen.MON_EN)[d.month - 1], d.year)


gen.date = date


def up(p, dec=1, size=12):
    return '<span class="pct up">%s%s</span>' % (ic("tri_up", size), n(gen.pct_txt(p, dec)))


# ------------------------------------------------------------------ data: year-end anchors, people, listing years, about, products
# year-end values: a rounded real analogue for the giants, fiction for the sector rows (INDEX.md)
HIST = {
    "Malus": {2007: 170, 2008: 76, 2009: 190, 2010: 295, 2011: 375, 2012: 500},
    "Pythia": {2007: 0.175, 2008: 0.14, 2009: 0.12, 2010: 0.17, 2011: 0.21},
    "Datenwald": {2007: 50, 2008: 45, 2009: 58, 2010: 62, 2011: 66},
}
CEO = {"Malus": "Timo Koch"}
IPO_YEAR = {"Malus": 1980, "Pythia": 2007, "Datenwald": 1988}
ABOUT = {
    "Malus": ("A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
              "handset market; more than half its revenue now comes from that one product.",
              "Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
              "gelirinin yarısından çoğu bugün o tek üründen geliyor."),
    "Pythia": ("An enterprise vendor selling cloud accounting and stock to small and mid-size firms; growth is slow but profitable.",
               "Küçük ve orta işletmelere bulutta muhasebe ve stok satan kurumsal yazılımcı; büyümesi yavaş ama kârlı."),
    "Datenwald": ("Europe's enterprise software giant; the books of most large companies run on its system. Licence revenue still carries "
                  "it, and the move to the cloud is slow.",
                  "Avrupa'nın kurumsal yazılım devi; büyük şirketlerin çoğunun defteri onun sisteminde döner. Lisans geliri hâlâ sırtlıyor, "
                  "bulut geçişi yavaş."),
    "Facewall": ("The social network that started in a college dorm, today the largest membership roll in the world. Revenue is advertising; "
                 "the move to mobile is still unproven.",
                 "Üniversite yurdunda doğan sosyal ağ, bugün dünyanın en kalabalık üyelik defteri. Geliri reklamdan; mobil geçişi henüz "
                 "kanıtlanmadı."),
}


def products_pythia():
    return [(L("Defter", "Ledger"), L("Hesap Planı", "Chart of Accounts")),                 # PROD_LINE_ERP_LEDGER · PROD_STEP_ERP_LEDGER_K2
            (L("Fatura", "Invoicing"), L("Toplu Fatura", "Batch Invoicing")),               # PROD_LINE_ERP_INVOICING · _K2
            (L("Nakit Akışı", "Cash Flow"), L("Nakit Akış Tablosu", "Cash Flow Statement"))]  # PROD_LINE_ERP_CASHFLOW · _K2


def sector(r):
    """The sector word under the name, as the seed writes it (the Sektörüm filter reads `group`, not this word)."""
    return r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]


def hist_of(r, week):
    """The year-end anchors before today's year."""
    y = _d(week).year
    return {k: v for k, v in HIST.get(r["name"], {}).items() if k < y}


def rows_at(week):
    rows = listed(week)
    for r in rows:
        if r.get("new") and week - gen.SEED["ipo_frame"]["week"] > 4:   # a year on, the listing is old news and moves like the rest (fiction)
            r.update(new=False, pct_4w=3.0)
    return rows


# ------------------------------------------------------------------ tiles
def bars(vals):
    lo, hi = min(vals), max(vals)
    H = lambda v: 5 + (v - lo) / float(hi - lo or 1) * 19
    return '<div class="kt-bars">%s</div>' % "".join('<i style="height:%.0fpx"></i>' % H(v) for v in vals)


def tile(key, value, desc, pct=None, spark=""):
    return ('<div class="kt"><span class="kt-k t-label">%s</span><span class="kt-v"><span class="t-tile">%s</span>%s</span>'
            '<div class="kt-foot"><span class="kt-d t-caption">%s</span>%s</div></div>' % (key, value, up(pct, size=14) if pct else "", desc, spark))


def tiles(rows, leader, week, you):
    old_rows = [r for r in rows if not r.get("new")]
    total = sum(r["value_b"] for r in rows)
    now = sum(r["value_b"] for r in old_rows)
    old = sum(r["value_b"] / (1 + r["pct_4w"] / 100.0) for r in old_rows)
    idx = (now / old - 1) * 100
    # the list's 13 weekly totals: the sum of the rows' series; the four-week pin of every row lands on one index, so that
    # point is read as the mean of its neighbours (the tile shows the level, the change is the figure beside the value)
    lst = [sum(series(r, week)[i] for r in old_rows) for i in range(52 - BARS, 52)]
    lst[-5] = (lst[-6] + lst[-4]) / 2
    lead = series(leader, week, hist_of(leader, week))[-BARS:]
    return '<div class="kts">%s%s%s</div>' % (
        tile(s("k_list"), n(money_b(total)), s("d_list", c=len(rows)), idx, bars(lst)),
        tile(s("k_lead"), n(money_b(leader["value_b"])), s("d_lead", name=leader["name"], sector=sector(leader)), leader["pct_4w"], bars(lead)),
        tile(s("k_you"), you[0], you[1]))


# ------------------------------------------------------------------ list
def row(r, top, selected):
    nm, pr, vl = ("t-value", "t-data", "t-value") if top else ("t-data-strong", "t-caption", "t-data")
    cls = "row grid" + (" top" if top else "") + (" is-selected" if selected else "")
    new = tag(s("new"), "neutral") if r.get("new") else ""
    return ('<div class="%s"><span class="rk-r t-small">%d</span><span class="rk-co"><span class="rk-nm %s">%s%s</span><span class="rk-sc t-small">%s</span></span>'
            '<span class="rk-pr %s">%s</span><span class="rk-vl %s">%s</span></div>'
            % (cls, r["rank"], nm, r["name"], new, sector(r), pr, n(gen.price(r["price"])), vl, n(money_b(r["value_b"]))))


def list_col(rows, selected, shown=11, first=0, ctl="", note=""):
    """The ranked list, `shown` rows from `first`; a hint above when rows are skipped, a hint below when rows remain."""
    vis = rows[first:first + shown]
    html = "".join(row(r, r["rank"] <= 3, r["name"] == selected) for r in vis)
    above = ('<div class="rk-more t-caption">%s</div>' % s("above", c=first)) if first else ""
    left = len(rows) - first - len(vis)
    below = ('<div class="rk-more t-caption">%s</div>' % s("more", c=left)) if left else ""
    return '<div class="rk-list">%s%s<div class="tbl"><div class="rows">%s</div></div>%s%s</div>' % (ctl, above, html, below, note)


FILTERS = [("all", "f_all"), ("tech", "f_tech"), ("fin", "f_fin"), ("sektor", "f_mine")]


def ctl(active):
    return '<div class="rk-ctl">%s</div>' % "".join('<span class="chip%s">%s</span>' % (" is-on" if k == active else "", s(key)) for k, key in FILTERS)


# ------------------------------------------------------------------ card
def gauge(share_pct, w=200, h=104):
    """rk_v3's dial: 6 px, the share in ink-2 on an ink-4 rest, no ticks. Under 0,1 % the figure reads "<%0,1" and no
    share arc is drawn (a round-capped arc that short is a dot, which reads as a glitch): the number carries the value."""
    cx, cy, R = w / 2.0, h - 4, 88
    pt = lambda deg: (cx + R * math.cos(math.radians(180 - deg)), cy - R * math.sin(math.radians(180 - deg)))
    (x0, y0), (x1, y1), (xs, ys) = pt(0), pt(180), pt(180 * share_pct / 100.0)
    small = share_pct < 0.1
    txt = s("lt", p=n(gen.pct_txt(0.1))) if small else n(gen.pct_txt(share_pct, dec=0))
    g = ['<path class="g-rest" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>' % (x0, y0, R, R, x1, y1),
         "" if small else '<path class="g-arc" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>' % (x0, y0, R, R, xs, ys),
         '<text class="g-num" x="%.1f" y="%.1f" text-anchor="middle">%s</text>' % (cx, cy - 6, html.escape(txt))]
    return '<div class="rc-gauge"><svg width="%d" height="%d">%s</svg><span class="g-lbl t-caption">%s</span></div>' % (w, h, "".join(g), s("share"))


def five_year(r, hist, week):
    """Weekly values from the last week of the first anchor year to today. The anchors are the year-end values the table
    lists and today's value; between them a straight line with a faint noise that dies at every anchor. Returns the
    values and the (index, label) of each anchor."""
    last = {}
    for w in range(-300, week + 1):
        last[_d(w).year] = w
    anchors = {last[y]: (hist[y], str(y)) for y in table_years(hist)}
    anchors[week] = (r["value_b"], month(week))
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


def y_scale(hi):
    base = 10 ** math.floor(math.log10(hi))
    for step in (base / 2, base, base * 2, base * 5):
        yhi = math.ceil(hi / step) * step
        if yhi / step <= 4:
            return step, yhi


def chart5y(vals, marks, w=898, h=256, span=None):
    """The anchors' straight lines, the area under them filled, a tick and the year at every anchor and today at the end.
    `span` (points) widens the axis beyond the data: the line then covers only its tail (a fresh listing). The width is
    the card's interior (1424 − 460 list − 1 rule − 2 × 32 padding), so the chart ends on the DEĞER rule."""
    pad_l, pad_r, pad_t, pad_b = 56, 12, 12, 24
    step, yhi = y_scale(max(vals))
    N = span or len(vals)
    off = N - len(vals)
    X = lambda i: pad_l + (i + off) * (w - pad_l - pad_r) / float(N - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi) * (h - pad_t - pad_b)
    g = []
    for k in range(int(round(yhi / step)) + 1):
        v = k * step
        g.append('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % (pad_l, w - pad_r, Y(v), Y(v)))
        if v:
            g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(v) + 4, n(money_b(v))))
    pts = " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals))
    g.append('<polygon class="ch-area" points="%.1f,%.1f %s %.1f,%.1f"/>' % (X(0), Y(0), pts, X(len(vals) - 1), Y(0)))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    last = len(vals) - 1
    for i, label in marks:
        # today's label ends at the right edge; a year-end anchor within 100 px of it ends at its own tick instead
        anchor, dx = "middle", 0
        if i == last:
            anchor = "end"
        elif span and i == 0:
            anchor = "start"
        elif X(last) - X(i) < 100:
            anchor, dx = "end", -4
        g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
        g.append('<text class="ch-lbl%s" x="%.1f" y="%d" text-anchor="%s">%s</text>'
                 % (" mark" if span and i == 0 else "", X(i) + dx, h - 4, anchor, label))
    g.append('<polyline class="ch-line" points="%s"/>' % pts)
    for i, _ in marks[:-1]:
        g.append('<circle class="ch-yr" cx="%.1f" cy="%.1f" r="3"/>' % (X(i), Y(vals[i])))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def ranges(active="r_5y"):
    tabs = ["r_13w", "r_1y", "r_5y", "r_all"]
    return '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if k == active else "", s(k)) for k in tabs)


def table_years(hist):
    """The four year-end anchors the card's table lists; the chart draws exactly these (the table and the chart agree)."""
    return sorted(hist)[-4:]


def kv_rows(r, hist):
    years = table_years(hist)
    years.reverse()
    kv = ['<span class="rc-k t-caption">%s</span><span class="rc-n t-data">%s</span>' % (s("eoy_first", y=y) if i == 0 else y, n(money_b(hist[y])))
          for i, y in enumerate(years)]
    kv.append('<span class="rc-k t-caption">%s</span><span class="rc-n t-data">%s</span>' % (s("since", y=years[0]), up((r["value_b"] / hist[years[0]] - 1) * 100, dec=0)))
    return "".join(kv)


def card(r, rows, week, chart_h=256, products=()):
    hist = hist_of(r, week)
    share = r["value_b"] / sum(x["value_b"] for x in rows) * 100
    who = []
    if r["person"]:
        who.append('<span>%s <b>%s</b></span>' % (s("founder"), r["person"]))
    if r["name"] in CEO:
        who.append('<span>%s <b>%s</b></span>' % (s("ceo"), CEO[r["name"]]))
    why = ('%s<span>%s</span>' % (up(r["pct_4w"]), s("four_w"))) if r.get("pct_4w") is not None else ""
    if r.get("new"):   # a fresh listing: the card keeps its skeleton; the header slot carries the listing month, the year-end pane is empty (rule 9)
        ipo_w = gen.SEED["ipo_frame"]["week"] - 2   # listed two weeks before the frame: the chart is that short line
        ipo = s("ipo", y=month(ipo_w))
        kv = ""
        vals = [r["value_b"] * (1 + 0.01 * math.sin(i)) for i in range(week - ipo_w + 1)]
        vals[-1] = r["value_b"]
        chart = chart5y(vals, [(0, s("ipo_mark")), (len(vals) - 1, month(week))], h=chart_h, span=BARS)
        rng = "r_13w"
    else:
        ipo = s("ipo", y=IPO_YEAR[r["name"]])
        kv = kv_rows(r, hist)
        vals, marks = five_year(r, hist, week)
        chart = chart5y(vals, marks, h=chart_h)
        rng = "r_5y"
    prod = ""
    if products:
        prod = ('<div class="rc-prod"><span class="rc-h t-label">%s</span>%s</div>'
                % (s("products"), "".join('<div class="prod-row"><span class="l t-data">%s</span><span class="s t-caption">%s</span></div>' % p for p in products)))
    en, tr = ABOUT[r["name"]]
    return ('<div class="rk-card">'
            '<div class="rc-head"><span class="rc-nm t-display">%s</span>%s<span class="rc-ipo t-caption">%s</span></div>'
            '<div class="rc-sub t-caption">%s</div>'
            '<div class="rc-panes">'
            '<div class="rc-pane"><span class="rc-hero t-big">%s</span><span class="rc-cap t-caption">%s</span><span class="rc-why t-caption">%s</span></div>'
            '<div class="rc-pane"><div class="rc-kv">%s</div></div>'
            '<div class="rc-pane">%s</div>'
            '</div>'
            '<div class="rc-rng"><span class="t-label">%s</span>%s</div>%s%s'
            '<div class="rc-about"><span class="rc-h t-label">%s</span><p class="t-body">%s</p></div>'
            '</div>'
            % (r["name"], '<span class="tag tag-outline sec">%s</span>' % sector(r), ipo,
               "".join(who),
               n(money_b(r["value_b"])), s("cap", month=month(week)), why,
               kv,
               gauge(share),
               s("value"), ranges(rng), chart, prod,
               s("about"), L(tr, en)))


# ------------------------------------------------------------------ window and frame
def window(inner, week, geo=WIN):
    x, y, w, h = geo
    head = ('<div class="win-head rk"><h1 class="win-title t-h1">%s</h1><span class="ctx t-body">%s</span><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (gen.s("tab_piyasa"), s("ctx_%d" % _d(week).year, month=month(week)), ic("close")))
    return '<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s%s</section>' % (x, y, w, h, head, inner)


def you_seed(week):
    """The seed tile prints the PRD §3.5 formula: post-money = amount × 100 / equity ($130K × 100 / 16 = $812,5K → $0,8M)."""
    p = gen.SEED["player"]
    return n(gen.money_m(p["seed_amount_k"] * 100.0 / p["seed_equity_pct"] / 1000)), s("d_seed", month=month(week))


def frame(top, you, selected="Malus", week=14, shown=11, first=0, active="all", note="", chart_h=256, products=(), w1536=False, cb=False):
    rows = rows_at(week)
    leader = rows[0]
    sel = next(r for r in rows if r["name"] == selected)
    show = rows if active == "all" else [r for r in rows if r["group"] == active]
    body = '<div class="rk-body">%s%s</div>' % (
        list_col(show, selected, shown=shown, first=first, ctl=ctl(active), note=note),
        card(sel, rows, week, chart_h=chart_h, products=products))
    inner = tiles(rows, leader, week, you) + body
    news = gen.news_market(ipo=week == gen.SEED["ipo_frame"]["week"])
    if w1536:
        win = window(inner, week, WIN_1536)
        html = gen.page(gen.screen(gen.topbar(top, compact=True, W=1536), gen.rail("piyasa", gen.B_THEME, icons=True), win, news, w=1536), w1536=True)
    else:
        html = gen.page(gen.screen(gen.topbar(top), gen.rail("piyasa", gen.B_THEME), window(inner, week), news), cb=cb)
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


# ------------------------------------------------------------------ frames
def f_liste(cb=False):
    return frame(gen.TOP_SEED, you_seed(14), cb=cb)


def f_seed_oncesi():
    return frame(gen.TOP_THEME, ("", s("d_none")))


def f_series_a():
    wk = 72   # fiction: Series A signed in the run's second year (INDEX.md)
    return frame(dict(gen.TOP_A, week=wk), (n(gen.money_m(gen.SEED["player"]["series_a_valuation_m"])), s("d_series_a", w=wk)), week=wk)


def f_detay_sektor():
    return frame(gen.TOP_SEED, you_seed(14), selected="Pythia", first=24, chart_h=150, products=products_pythia())


def f_filtre_sektor():
    note = '<div class="rk-note t-caption">%s</div>' % s("lists_in", name="Werktag", month=L("Ekim 2012", "October 2012"))
    return frame(gen.TOP_SEED, you_seed(14), selected="Datenwald", active="sektor", note=note)


def f_ipo():
    wk = gen.SEED["ipo_frame"]["week"]
    return frame(dict(gen.TOP_SEED, week=wk), you_seed(wk), selected="Facewall", week=wk)


def f_1536():
    return frame(gen.TOP_SEED, you_seed(14), shown=7, chart_h=140, w1536=True)


FRAMES = {
    "piyasa__liste": f_liste,
    "piyasa__seed_oncesi": f_seed_oncesi,
    "piyasa__series_a": f_series_a,
    "piyasa__detay_sektor": f_detay_sektor,
    "piyasa__filtre_sektor": f_filtre_sektor,
    "piyasa__ipo": f_ipo,
    "piyasa__1536": f_1536,
    "piyasa__renk_koru": lambda: f_liste(cb=True),
}
EN = ["piyasa__liste"]


def jobs():
    return [(k, "tr") for k in FRAMES] + [(k + "_en", "en") for k in EN]


def main(names):
    os.makedirs(gen.BUILD, exist_ok=True)
    for name, lang in jobs():
        if names and name not in names:
            continue
        gen.set_lang(lang)
        try:
            html = FRAMES[name[:-3] if lang == "en" else name]()
        finally:
            gen.set_lang("tr")
        with open(os.path.join(gen.BUILD, name + ".html"), "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print("built", name)


if __name__ == "__main__":
    if sys.argv[1:] == ["--sizes"]:
        for name, _ in jobs():
            print(name, *((1536, 864, 1.25) if name.endswith("__1536") else (1920, 1080, 1)))
    else:
        main(sys.argv[1:])
