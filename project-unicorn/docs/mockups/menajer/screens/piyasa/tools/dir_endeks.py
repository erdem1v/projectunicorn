"""Direction A, "the newspaper's market page" (dir_endeks): one editorial frame of the Piyasa window, built on gen.py's
shell (top bar, rail, office plate, ticker, window chrome) and seed. The list is read, not scanned: the ten largest
names set large, the rest of the list as a small-type tail, the week's three moves with their reasons in one place,
and one chart. The player has no rank on this page, only a quiet valuation line under the deck.

  python dir_endeks.py     -> ../build/dir_endeks.html
"""
import datetime
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import gen  # noqa: E402
from gen import L, n, money_b, money_m, pct_txt, listed, series, kpis, window, page, screen, topbar, rail, news_market, SEED, _d  # noqa: E402
from common import ic  # noqa: E402
from kit import tag  # noqa: E402

OUT = os.path.join(gen.BUILD, "dir_endeks.html")

# ------------------------------------------------------------------ strings (new for this direction; TR/EN approval pending)
S = {
    "deck": ("April 2012: the device giant holds the throne and the social network is preparing its listing.",
             "Nisan 2012: cihaz devi tahtta, sosyal ağ halka arza hazırlanıyor."),
    "you": ("You · {value} valuation", "Sen · {value} değerleme"),
    "you_tail": ("last name on the list {value}", "listenin son adı {value}"),
    "top10": ("Top 10", "İlk 10"),
    "rest": ("Next 25", "Sonraki 25"),
    "moves": ("Moves of the week", "Haftanın hareketleri"),
    "feature": ("In focus", "Mercek"),
    "value_5y": ("Value · 5 years", "Değer · 5 yıl"),
    "about": ("About", "Hakkında"),
    "why_device": ("first quarter of the new device", "yeni cihazın ilk çeyreği"),
    "about_malus": ("Builds the device and its operating system under one roof; half its revenue is the 2007 phone.",
                    "Cihazı ve işletim sistemini tek çatıda yapan elektronik devi; gelirinin yarısı 2007'deki telefonu."),
}


def s(key, **kw):
    en, tr = S[key]
    v = tr if gen.common.LANG == "tr" else en
    return v.format(**kw) if kw else v


# the five-year curve needs an anchor before its first point (Apr 2007): the 2006 year end, rounded like the rest
MALUS_HIST = {2006: 72, **gen.POMELO_HIST}

# the week's moves: the seed's 4-week change, one reason each (two reasons are the ticker's own strings)
MOVES = [("Cufflink", lambda: gen.s("why_sub")), ("Malus", lambda: s("why_device")), ("Nordlund Mobile", lambda: gen.s("why_layoff"))]


# ------------------------------------------------------------------ columns
def sector(r):
    return r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]


def big_rows(rows, selected):
    out = []
    for r in rows:
        out.append('<div class="ed-big%s"><span class="rk t-caption">%d</span>'
                   '<span class="nm"><span class="n">%s</span><span class="sec t-caption">%s</span></span>'
                   '<span class="v t-data-med">%s</span></div>'
                   % (" is-selected" if r["name"] == selected else "", r["rank"], r["name"], sector(r), n(money_b(r["value_b"]))))
    return "".join(out)


def small_rows(rows):
    return "".join('<div class="ed-small"><span class="rk t-small">%d</span><span class="n t-cdata">%s</span><span class="v t-cdata">%s</span></div>'
                   % (r["rank"], r["name"], n(money_b(r["value_b"]))) for r in rows)


def move_blocks(rows):
    by = {r["name"]: r for r in rows}
    out = []
    for name, why in MOVES:
        p = by[name]["pct_4w"]
        pct = ('<span class="pct up t-kpi">%s%s</span>' % (ic("tri_up", 16), n(pct_txt(p)))) if p > 0 else ('<span class="pct t-kpi">%s</span>' % n(pct_txt(p)))
        out.append('<div class="ed-move"><span class="n">%s</span>%s<span class="why t-caption">%s</span></div>' % (name, pct, why()))
    return "".join(out)


def curve_5y(vals, week, w=396, h=256):
    """Weekly points over five years; year ticks on the axis, three value gridlines."""
    pad_l, pad_r, pad_t, pad_b = 48, 8, 8, 22
    lo, hi = min(vals), max(vals)
    base = 10 ** math.floor(math.log10(hi - lo))
    for step in (base, base * 2, base * 5, base * 10):
        ylo, yhi = math.floor(lo / step) * step, math.ceil(hi / step) * step
        if round((yhi - ylo) / step) <= 3:
            break
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi - ylo) * (h - pad_t - pad_b)
    g = []
    for k in range(int(round((yhi - ylo) / step)) + 1):
        v = ylo + k * step
        g.append('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % (pad_l, w - pad_r, Y(v), Y(v)))
        g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(v) + 4, n(money_b(v)) if v else "$0"))
    w0 = week - len(vals) + 1
    for i in range(1, len(vals)):
        d = _d(w0 + i)
        if d.year != _d(w0 + i - 1).year:
            g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
            g.append('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="middle">%d</text>' % (X(i), h - 4, d.year))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def year_strip(hist, today_v, today_year=2012):
    cells = [(str(y), n(money_b(hist[y]))) for y in sorted(hist) if y >= today_year - 4] + [(str(today_year), n(money_b(today_v)))]
    return '<div class="ed-years">%s</div>' % "".join(
        '<span class="yc%s"><span class="y t-caption">%s</span><span class="v t-data">%s</span></span>' % (" is-today" if i == len(cells) - 1 else "", y, v)
        for i, (y, v) in enumerate(cells))


def feature(r, week):
    head = ('<div class="ed-fhead"><span class="n">%s</span>%s<span class="v t-kpi">%s</span></div>'
            % (r["name"], tag(sector(r), "outline"), n(money_b(r["value_b"]))))
    return (head + '<div class="ed-sub t-micro">%s</div>' % s("value_5y") + curve_5y(series(r, week, MALUS_HIST, points=260), week)
            + year_strip(MALUS_HIST, r["value_b"]) + '<div class="ed-sub t-micro">%s</div>' % s("about")
            + '<p class="ed-about t-data">%s</p>' % s("about_malus"))


def col(title, inner, cls=""):
    return '<div class="ed-col %s"><div class="ed-h t-label">%s</div>%s</div>' % (cls, title, inner)


# ------------------------------------------------------------------ the page
def body(rows, week):
    top, rest = rows[:10], rows[10:35]
    sel = rows[0]
    mast = ('<div class="ed-mast"><div class="ed-deck t-quote">%s</div>'
            '<div class="ed-you t-data">%s<span class="tail"> · %s</span></div></div>'
            % (s("deck"), s("you", value=n(money_m(SEED["player"]["seed_post_money_m"]))), s("you_tail", value=n(money_b(rows[-1]["value_b"])))))
    cols = ('<div class="ed-cols">%s%s%s%s</div>'
            % (col(s("top10"), big_rows(top, sel["name"])), col(s("rest"), small_rows(rest)),
               col(s("moves"), move_blocks(rows)), col(s("feature"), feature(sel, week), "feat")))
    return '<div class="ed">%s%s</div>' % (mast, cols)


CSS = """
/* dir_endeks: the editorial market page. Tokens and the spacing scale only. */
.ed { flex: 1; min-width: 0; display: flex; flex-direction: column; padding: 0 var(--sp-32) var(--sp-24); }
.ed-mast { flex: none; padding: var(--sp-24) 0 var(--sp-20); border-bottom: var(--bw-1) solid var(--line-1); }
.ed-deck { color: var(--ink-2); }
.ed-you { margin-top: var(--sp-8); color: var(--ink-3); }
.ed-you .tail { color: var(--ink-4); }
.ed-cols { flex: 1; min-height: 0; display: grid; grid-template-columns: 372px 212px 260px 396px; column-gap: var(--sp-40); padding-top: var(--sp-20); }
.ed-col { min-width: 0; display: flex; flex-direction: column; }
.ed-h { flex: none; height: 28px; margin-bottom: var(--sp-8); color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
/* the ten largest: rank, name set large with its sector under it, value on the right; the featured one is the selected row */
.ed-big { position: relative; display: grid; grid-template-columns: 28px 1fr auto; align-items: center; height: 60px;
  padding: 0 var(--sp-8) 0 var(--sp-4); border-bottom: var(--bw-1) solid var(--row-rule); }
.ed-big .rk { color: var(--ink-4); }
.ed-big .nm { display: flex; flex-direction: column; min-width: 0; }
.ed-big .n { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-26); line-height: var(--lh-26); color: var(--ink-1);
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis; margin-bottom: -2px; }
.ed-big .sec { color: var(--ink-3); }
.ed-big .v { color: var(--ink-1); }
.ed-big.is-selected { background: var(--surface-4); }
.ed-big.is-selected::after { content: ""; position: absolute; left: 0; top: 8px; bottom: 8px; width: var(--bw-3); background: var(--selected-mark); border-radius: 0 2px 2px 0; }
/* the tail of the list: small type, name and value */
.ed-small { display: grid; grid-template-columns: 24px 1fr auto; align-items: center; height: 24px; padding: 0 var(--sp-4); }
.ed-small .rk { color: var(--ink-4); }
.ed-small .n { color: var(--ink-2); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ed-small .v { color: var(--ink-3); }
/* the week's moves: name, the change, the reason */
.ed-move { display: flex; flex-direction: column; gap: var(--sp-4); padding: var(--sp-16) 0 var(--sp-20); border-bottom: var(--bw-1) solid var(--row-rule); }
.ed-move .n { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-20); line-height: var(--lh-20); color: var(--ink-1); }
.ed-move .pct { display: inline-flex; align-items: center; gap: var(--sp-4); color: var(--ink-2); }
.ed-move .pct .ic { width: 16px; height: 16px; }
.ed-move .pct.up { color: var(--pos); }
.ed-move .why { color: var(--ink-3); }
/* in focus: name, sector, value, the five-year curve, year ends, two lines about */
.ed-fhead { display: flex; align-items: center; gap: var(--sp-12); height: 40px; }
.ed-fhead .n { font-family: var(--f-cond); font-weight: 700; font-size: var(--fs-30); line-height: var(--lh-30); color: var(--ink-1); }
.ed-fhead .v { margin-left: auto; color: var(--ink-1); }
.ed-sub { margin: var(--sp-16) 0 var(--sp-6); color: var(--ink-3); }
.ed-years { display: flex; margin-top: var(--sp-12); border-top: var(--bw-1) solid var(--line-1); border-bottom: var(--bw-1) solid var(--line-1); }
.ed-years .yc { flex: 1; display: flex; flex-direction: column; padding: var(--sp-8) 0; }
.ed-years .yc + .yc { border-left: var(--bw-1) solid var(--row-rule); padding-left: var(--sp-12); }
.ed-years .y { color: var(--ink-3); }
.ed-years .v { color: var(--ink-2); }
.ed-years .is-today .v { color: var(--ink-1); font-weight: 500; }
.ed-about { margin: 0; color: var(--ink-2); text-wrap: pretty; }
.ch-last { fill: var(--ink-1); stroke: var(--surface-3); stroke-width: 3; paint-order: stroke; }
"""


def build():
    rows = listed()
    win = window(208, 88, 1424, 928, kpis(rows)[:2], "", body(rows, 14))
    html = page(screen(topbar(gen.TOP_SEED), rail("piyasa", gen.B_THEME), win, news_market()))
    html = html.replace("</head>", "<style>%s</style></head>" % CSS, 1)
    os.makedirs(gen.BUILD, exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(html)
    print("built", OUT)


if __name__ == "__main__":
    build()
