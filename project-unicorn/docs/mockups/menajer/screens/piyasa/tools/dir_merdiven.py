"""Direction B, "merdiven": the Market window as a logarithmic value ladder (seed H14 · April 2012, player post-Seed $4,2M).

  python dir_merdiven.py      builds ../build/dir_merdiven.html

The shell (top bar, rail, ticker, office plate), the seed, the number forms and the text helpers are gen.py's; only
the window is new. Five decade bands ($100M .. $1T) on alternating grounds; every listed company is a step in its
band, the name set larger the higher the band, its value beside it, the four-week move as a glyph only when it
exceeds five per cent. The player is a 2 px ink-1 line at $4,2M on the same axis: a valuation, never a rank.
"""
import datetime
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import gen  # noqa: E402
from common import ic  # noqa: E402
from kit import tag  # noqa: E402

n, L, money_b, pct_txt = gen.n, gen.L, gen.money_b, gen.pct_txt
MOVE_MIN = 5.0   # the glyph's threshold: a four-week move of at least this many per cent

# ------------------------------------------------------------------ the five bands: (label at the band's top line, floor in $B, ceiling in $B, height px)
BANDS = [("Trilyon", 100, 1000, 220), ("100 milyar", 10, 100, 212), ("10 milyar", 1, 10, 100),
         ("1 milyar", 0.1, 1, 84), ("100 milyon", 0.001, 0.1, 150)]
STYLE = {0: ("nm-1", "v-1", "it-1"), 1: ("nm-2", "v-2", "it-2"), 2: ("nm-3", "v-3", "it-3"), 3: ("nm-4", "v-4", "it-4"), 4: ("nm-4", "v-4", "it-4")}


def move_glyph(p):
    if p is None or abs(p) < MOVE_MIN:
        return ""
    return '<span class="mv%s">%s</span>' % (" up" if p > 0 else "", ic("tri_up" if p > 0 else "tri_down", 12))


def item(r, k, selected=False, hover=False):
    nm, v, it = STYLE[k]
    cls = "it %s%s%s" % (it, " is-selected" if selected else "", " is-hover" if hover else "")
    return ('<span class="%s"><span class="nm %s">%s</span><span class="v %s">%s</span>%s</span>'
            % (cls, nm, r["name"], v, n(money_b(r["value_b"])), move_glyph(r.get("pct_4w"))))


def player_line(h, floor_b, ceil_b, value_m):
    frac = (math.log10(value_m / 1000.0) - math.log10(floor_b)) / (math.log10(ceil_b) - math.log10(floor_b))
    y = round(h * (1 - frac))
    return ('<div class="you" style="top:%dpx"><span class="you-l"><span class="t-data-strong">%s</span><span class="t-caption">%s</span></span></div>'
            % (y, L("Sen · %s", "You · %s") % n(gen.money_m(value_m)), L("Seed sonrası değerleme", "post-Seed valuation")))


def ladder(rows, value_m, selected, hover):
    out = []
    for k, (label, lo, hi, h) in enumerate(BANDS):
        inb = [r for r in rows if lo <= r["value_b"] < hi]
        items = "".join(item(r, k, r["name"] == selected, r["name"] == hover) for r in inb)
        you = player_line(h, lo, hi, value_m) if lo * 1000 <= value_m < hi * 1000 else ""
        last = ('<span class="tick t-label last">%s</span>' % L("1 milyon", "1 million")) if k == len(BANDS) - 1 else ""
        out.append('<div class="band b%d" style="height:%dpx"><div class="ax"><span class="tick t-label">%s</span>%s</div>'
                   '<div class="items">%s</div>%s</div>' % (k % 2, h, L(label, label.replace("milyar", "billion").replace("milyon", "million").replace("Trilyon", "Trillion")), last, items, you))
    legend = ('<div class="ld-key t-caption">%s%s %s</div>'
              % (ic("tri_up", 12), ic("tri_down", 12), L("dört haftada %5'i aşan hareket", "a move above 5% in four weeks")))
    return '<div class="ld"><div class="ld-top"></div>%s%s</div>' % ("".join(out), legend)


# ------------------------------------------------------------------ the card: the selected step
def chart5(hist, today_b, w=432, h=200):
    """Monthly points from the first year-end to today (April 2012), log-interpolated between the year-end anchors with a
    little seeded noise that fades at every anchor; linear y with gridlines; a year tick per January."""
    years = sorted(hist)
    anchors = {datetime.date(y, 12, 1): hist[y] for y in years}
    anchors[datetime.date(2012, 4, 1)] = today_b
    keys = sorted(anchors)
    months = []
    d = keys[0]
    while d <= keys[-1]:
        months.append(d)
        d = datetime.date(d.year + (d.month == 12), d.month % 12 + 1, 1)
    rnd = random.Random("merdiven")
    ph = [rnd.uniform(0, 2 * math.pi) for _ in range(3)]
    idx = lambda d: (d.year - keys[0].year) * 12 + d.month - keys[0].month
    vals = []
    for d in months:
        a = max(k for k in keys if k <= d)
        b = min(k for k in keys if k >= d)
        if a == b:
            base = anchors[a]
        else:
            t = (idx(d) - idx(a)) / float(idx(b) - idx(a))
            base = anchors[a] * math.exp(math.log(anchors[b] / anchors[a]) * t)
        tt = idx(d) / float(idx(keys[-1]))
        noise = sum(math.sin(2 * math.pi * (k + 1) * 2.1 * tt + ph[k]) / (k + 1) for k in range(3)) * 0.04
        fade = min(1.0, min(abs(idx(d) - idx(k)) for k in keys) / 4.0)
        vals.append(base * (1 + noise * fade))
    pad_l, pad_r, pad_t, pad_b = 48, 12, 12, 24
    hi = max(vals)
    step = 200 if hi > 400 else 100
    yhi = math.ceil(hi / step) * step
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi) * (h - pad_t - pad_b)
    g = []
    for v in range(0, yhi + 1, step):
        g.append('<line class="%s" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % ("ch-axis" if v == 0 else "ch-grid", pad_l, w - pad_r, Y(v), Y(v)))
        if v:
            g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(v) + 4, n(money_b(v))))
    for i, d in enumerate(months):
        if d.month == 1:
            g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
            g.append('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="middle">%d</text>' % (X(i), h - 4, d.year))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def sec(title, inner):
    return '<div class="cd-sec"><div class="h t-label">%s</div>%s</div>' % (title, inner)


def card(r, hist, about):
    sector = r["sector_tr"] if gen.common.LANG == "tr" else r["sector_en"]
    p = r["pct_4w"]
    move = ('<span class="cd-move t-data%s">%s%s · %s</span>'
            % (" up" if p > 0 else "", ic("tri_up" if p > 0 else "tri_down", 12), n(pct_txt(p)), L("dört haftada", "in four weeks")))
    eoy = "".join('<div class="yr"><span class="y t-caption">%d</span><span class="n t-data">%s</span></div>' % (y, n(money_b(hist[y])))
                  for y in sorted(hist)[1:])
    return ('<aside class="cd">'
            '<div class="cd-head"><h2 class="t-h2">%s</h2>%s</div>'
            '<div class="cd-who t-caption"><span class="k">%s</span><span class="n">%s</span></div>'
            '<div class="cd-val"><span class="t-hero">%s</span>%s</div>'
            '%s%s%s</aside>'
            % (r["name"], tag(sector, "outline"), gen.s("founder"), r["person"], n(money_b(r["value_b"])), move,
               sec(L("Değer · beş yıl", "Value · five years"), chart5(hist, r["value_b"])),
               sec(L("Yıl sonu", "Year end"), '<div class="eoy">%s</div>' % eoy),
               sec(gen.s("about"), '<p class="t-body">%s</p>' % about)))


# ------------------------------------------------------------------ window and page
CSS = """
.win-head .ctx { margin-left: var(--sp-8); color: var(--ink-3); white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.ld-body { display: flex; flex: 1; min-height: 0; }
/* the ladder: five bands on alternating grounds, a 112 px axis column with the band label on the band's top line */
.ld { flex: 1; min-width: 0; display: flex; flex-direction: column; position: relative; }
.band { position: relative; display: flex; flex: none; border-top: var(--bw-1) solid var(--line-1); }
.band.b1 { background: var(--surface-2); }
.band .ax { flex: none; width: 112px; position: relative; }
.band .tick { position: absolute; right: var(--sp-16); top: -10px; color: var(--ink-3); white-space: nowrap; }
.band .tick.last { top: auto; bottom: -10px; }
.band .items { flex: 1; min-width: 0; display: flex; flex-wrap: wrap; align-content: flex-start; column-gap: var(--sp-24); row-gap: var(--sp-2); padding: var(--sp-16) var(--sp-24) var(--sp-12) var(--sp-16); }
/* a step: name · value · move glyph; one rect for hover border and selected ground (rule 3) */
.it { position: relative; display: inline-flex; align-items: baseline; gap: var(--sp-8); padding: 0 var(--sp-8); margin-left: calc(-1 * var(--sp-8)); border-radius: var(--r-1); border: var(--bw-1) solid transparent; white-space: nowrap; }
.it.is-hover { border-color: var(--line-hover); }
.it.is-selected { background: var(--surface-4); }
.it.is-selected::after { content: ""; position: absolute; left: 0; top: 6px; bottom: 6px; width: var(--bw-3); background: var(--selected-mark); border-radius: 0 2px 2px 0; }
.it .nm { font-family: var(--f-cond); }
.nm-1 { font-weight: 700; font-size: var(--fs-30); line-height: var(--lh-30); color: var(--ink-1); }
.nm-2 { font-weight: 600; font-size: var(--fs-22); line-height: var(--lh-22); color: var(--ink-2); }
.nm-3 { font-weight: 600; font-size: var(--fs-18); line-height: var(--lh-18); color: var(--ink-2); }
.nm-4 { font-weight: 600; font-size: var(--fs-16); line-height: var(--lh-16); color: var(--ink-3); }
.it .v { font-family: var(--f-sans); font-weight: 500; color: var(--ink-3); }
.v-1 { font-size: var(--fs-15); line-height: var(--lh-15); } .v-2 { font-size: var(--fs-14); line-height: var(--lh-14); }
.v-3, .v-4 { font-size: var(--fs-13); line-height: var(--lh-13); }
.it-1 { height: 44px; align-items: center; } .it-2 { height: 36px; align-items: center; } .it-3, .it-4 { height: 28px; align-items: center; }
.mv { display: inline-flex; color: var(--ink-3); } .mv.up { color: var(--pos); } .mv .ic { width: 12px; height: 12px; }
/* the player: a 2 px ink-1 line at the valuation's own height, the label on the line's left end */
.you { position: absolute; left: 112px; right: var(--sp-24); height: var(--bw-2); background: var(--ink-1); }
.you-l { position: absolute; left: var(--sp-16); bottom: var(--sp-8); display: flex; align-items: baseline; gap: var(--sp-8); white-space: nowrap; }
.you-l .t-data-strong { color: var(--ink-1); } .you-l .t-caption { color: var(--ink-3); }
.ld-top { flex: none; height: var(--sp-24); }
.ld-key { position: absolute; left: 128px; bottom: var(--sp-12); display: flex; align-items: center; gap: var(--sp-4); color: var(--ink-4); }
.ld-key .ic { width: 12px; height: 12px; }
/* the card: the selected step, inset column on the right */
.cd { flex: none; width: 480px; display: flex; flex-direction: column; gap: var(--sp-20); padding: var(--sp-24); background: var(--surface-2); border-left: var(--bw-1) solid var(--line-1); overflow: hidden; }
.cd-head { display: flex; align-items: center; gap: var(--sp-12); color: var(--ink-1); }
.cd-who { display: flex; gap: var(--sp-6); margin-top: calc(-1 * var(--sp-12)); color: var(--ink-3); }
.cd-who .n { color: var(--ink-2); font-weight: 500; }
.cd-val { display: flex; flex-direction: column; gap: var(--sp-2); color: var(--ink-1); }
.cd-move { display: inline-flex; align-items: center; gap: var(--sp-4); color: var(--ink-2); }
.cd-move.up { color: var(--pos); } .cd-move .ic { width: 12px; height: 12px; }
.cd-sec { display: flex; flex-direction: column; gap: var(--sp-12); }
.cd-sec .h { height: 28px; display: flex; align-items: center; color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
.cd-sec p { color: var(--ink-2); text-wrap: pretty; }
.eoy { display: grid; grid-template-columns: repeat(4, 1fr); }
.eoy .yr { display: flex; flex-direction: column; gap: var(--sp-2); }
.eoy .y { color: var(--ink-3); } .eoy .n { color: var(--ink-2); }
.ch-last { fill: var(--ink-1); stroke: var(--surface-2); stroke-width: 3; paint-order: stroke; }
"""


def window(rows, ctx, value_m, selected, hover, card_html):
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><span class="ctx t-body">%s</span><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (gen.s("tab_piyasa"), ctx, ic("close")))
    return ('<section class="win" style="left:208px;top:88px;width:1424px;height:928px">%s<div class="ld-body">%s%s</div></section>'
            % (head, ladder(rows, value_m, selected, hover), card_html))


def build():
    rows = gen.listed()
    ctx = L("Nisan 2012 · %d halka açık şirket · telefon dalgası cihaz devlerini taşıyor, trilyon dolarlık şirket henüz yok",
            "April 2012 · %d listed companies · the phone wave carries the device giants, no company is worth a trillion yet") % len(rows)
    about = L("Cihazı ve yazılımını tek çatıda yapan tüketici elektroniği devi; gelirinin yarısından çoğu 2007'deki tek telefondan.",
              "A consumer electronics giant that builds the device and its software under one roof; more than half its revenue is the one phone of 2007.")
    malus = next(r for r in rows if r["name"] == "Malus")
    win = window(rows, ctx, gen.SEED["player"]["seed_post_money_m"], "Malus", "Orinoco", card(malus, gen.POMELO_HIST, about))
    html = gen.page(gen.screen(gen.topbar(gen.TOP_SEED), gen.rail("piyasa", gen.B_THEME), win, gen.news_market()))
    return html.replace("</head>", "<style>%s</style></head>" % CSS, 1)


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    out = os.path.join(gen.BUILD, "dir_merdiven.html")
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(build())
    print("built", out)
