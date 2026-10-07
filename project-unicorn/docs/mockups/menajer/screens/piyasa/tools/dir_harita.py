"""Yön C, blok haritası: the Piyasa window as a treemap. Area is market value, so the giants are the picture and
the player's seed valuation is the one-pixel block the map cannot even draw. Builds ../build/dir_harita.html on
gen.py's shell (top bar, rail, office plate, ticker, window frame); only the window body is new.

  python dir_harita.py
  bash ../../../tools/render.sh ../build/dir_harita.html ../directions/dir_harita.png 1920 1080 1
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

import gen  # noqa: E402
from gen import SEED, _d, listed, money_b, money_m, n, s, series  # noqa: E402
from kit import tag  # noqa: E402

MAP_W, MAP_H = 900, 722          # the map; the window body is 1422 x 854 (928 - border 2 - head 72)
CARD_W = 474                     # the right column, 24 px padding each side

# sector word -> family. The strip colour is the family's; the sector word itself is printed inside the block (rule 5).
FAMILY = {"cihaz": "hw", "elektronik": "hw", "çip": "hw", "donanım": "hw", "telefon": "hw", "ağ": "hw",
          "yazılım": "sw", "kurumsal": "sw", "veritabanı": "sw", "SaaS": "sw", "erp": "sw",
          "arama": "net", "e-ticaret": "net", "internet": "net", "sosyal ağ": "net", "yayın": "net", "oyun": "net",
          "banka": "fin", "ödeme": "fin", "otomotiv": "oth"}
FAM_COLOR = {"hw": "--topic-team", "sw": "--topic-product", "net": "--topic-mentor", "fin": "--topic-funding", "oth": "--topic-market"}
FAM_WORD = {"hw": "donanım", "sw": "yazılım", "net": "internet", "fin": "finans", "oth": "otomotiv"}

CSS = """<style>
.hm { flex: none; display: flex; flex-direction: column; gap: var(--sp-12); width: 948px; padding: var(--sp-16) 0 var(--sp-24) var(--sp-24); }
.hm-ctx { display: flex; flex-direction: column; gap: var(--sp-4); }
.hm-ctx .l1 { color: var(--ink-2); } .hm-ctx .l2 { color: var(--ink-3); }
.tm { position: relative; width: 900px; height: 722px; }
.blk { position: absolute; background: var(--surface-2); border: var(--bw-1) solid transparent; border-radius: var(--r-1); overflow: hidden; }
.blk.strip::before { content: ""; position: absolute; left: 0; top: 0; bottom: 0; width: 3px; background: var(--fam); }
.blk.is-hover { border-color: var(--line-hover); }
.blk.is-selected { background: var(--surface-4); border-color: var(--ink-1); }
.blk .in { position: absolute; left: 11px; top: 5px; right: 6px; display: flex; flex-direction: column; gap: var(--sp-2); }
.blk .nm { color: var(--ink-1); overflow: hidden; }
.blk .nm.one { white-space: nowrap; }
.blk .nm .tag { height: 18px; padding: 0 var(--sp-4); font-size: var(--fs-12); margin-left: var(--sp-6); vertical-align: 2px; }
.blk .bv { color: var(--ink-2); white-space: nowrap; }
.blk .sec { position: absolute; left: 11px; bottom: 4px; color: var(--ink-3); white-space: nowrap; }
.hm-foot { display: flex; align-items: center; width: 900px; height: 28px; color: var(--ink-3); }
.hm-foot .leg { display: flex; align-items: center; gap: var(--sp-16); }
.hm-foot .leg i { display: inline-block; width: 3px; height: 12px; margin-right: var(--sp-6); vertical-align: -1px; }
.you-sq { position: relative; flex: none; width: 12px; height: 12px; border: var(--bw-1) solid var(--ink-1); border-radius: var(--r-1); margin-right: var(--sp-8); }
.you-sq i { position: absolute; left: 5px; top: 5px; width: 1px; height: 1px; background: var(--ink-1); }
.hm-you { display: flex; align-items: center; margin-left: auto; }
.hm-you .l1 { color: var(--ink-1); white-space: nowrap; }
.hm-you .l2 { color: var(--ink-3); white-space: nowrap; margin-left: var(--sp-8); }
.hc { flex: none; width: 474px; display: flex; flex-direction: column; gap: var(--sp-16); padding: var(--sp-20) var(--sp-24) var(--sp-24); border-left: var(--bw-1) solid var(--line-1); overflow: hidden; }
.hc .kick { color: var(--ink-3); }
.hc .nm { color: var(--ink-1); margin-top: calc(-1 * var(--sp-8)); }
.hc .hc-who { display: flex; align-items: center; gap: var(--sp-12); color: var(--ink-3); margin-top: calc(-1 * var(--sp-8)); }
.hc .hc-who b { font-weight: 500; color: var(--ink-2); }
.hc .val { color: var(--ink-1); } .hc .mult { color: var(--ink-3); margin-top: calc(-1 * var(--sp-12)); }
.hc .sh { display: flex; align-items: baseline; gap: var(--sp-8); height: 28px; color: var(--ink-3); border-bottom: var(--bw-1) solid var(--line-1); }
.hc .sh .n { color: var(--ink-4); }
.hc .about { color: var(--ink-2); text-wrap: pretty; }
.ch5 .ln { fill: none; stroke: var(--ink-2); stroke-width: 1.5; stroke-linejoin: round; }
.ch5 .ax { stroke: var(--line-2); } .ch5 .tk { stroke: var(--line-2); }
.ch5 .dot { fill: var(--ink-1); stroke: var(--surface-3); stroke-width: 2; paint-order: stroke; }
.ch5 .yr { fill: var(--ink-3); font: 400 12px var(--f-sans); } .ch5 .yv { fill: var(--ink-2); font: 500 14px var(--f-sans); }
.ch5 .yr.now { fill: var(--ink-1); }
</style>"""


# ------------------------------------------------------------------ squarified layout (Bruls, Huizing, van Wijk): values in descending order
def squarify(vals, x, y, w, h):
    k = w * h / float(sum(vals))
    areas = [v * k for v in vals]
    out = []

    def worst(row, side):
        t = float(sum(row))
        return max(max(side * side * a / (t * t), t * t / (side * side * a)) for a in row)

    i = 0
    while i < len(areas):
        wide = w >= h
        side = h if wide else w
        row, j = [areas[i]], i + 1
        while j < len(areas) and worst(row + [areas[j]], side) <= worst(row, side):
            row.append(areas[j])
            j += 1
        t = sum(row)
        if wide:
            rw, yy = t / h, y
            for a in row:
                out.append((x, yy, rw, a / rw))
                yy += a / rw
            x, w = x + rw, w - rw
        else:
            rh, xx = t / w, x
            for a in row:
                out.append((xx, y, a / rh, rh))
                xx += a / rh
            y, h = y + rh, h - rh
        i = j
    return out


# ------------------------------------------------------------------ blocks
def block(r, rect, selected=False, hover=False):
    x, y, w, h = rect
    gw, gh = max(1, w - 2), max(1, h - 2)   # a 2 px gutter of the window ground between blocks
    fam = FAMILY[r["sector_tr"]]
    cls = "blk" + (" strip" if gw >= 8 else "") + (" is-selected" if selected else "") + (" is-hover" if hover else "")
    box = '<div class="%s" style="left:%.0fpx;top:%.0fpx;width:%.0fpx;height:%.0fpx;--fam:var(%s)">' % (cls, x, y, gw, gh, FAM_COLOR[fam])
    name, value = r["name"], n(money_b(r["value_b"]))
    rival = tag(SEED["player_sector"], "outline") if r["group"] == "sektor" else ""
    inner = ""
    if gw >= 200 and gh >= 120:                      # the giants: name in the display face, value, sector word at the foot
        inner = ('<div class="in"><span class="nm t-h2">%s</span><span class="bv t-value">%s</span></div><span class="sec t-caption">%s</span>'
                 % (name, value, r["sector_tr"]))
    elif gw >= 76 and gh >= 44 and max(len(w) for w in name.split()) * 8.5 <= gw - 16:   # mid: name (wraps by word), value; the sector word where a third line fits
        sec = ('<span class="sec t-small">%s</span>' % r["sector_tr"]) if gh >= 72 else ""
        inner = '<div class="in"><span class="nm t-data-strong">%s%s</span><span class="bv t-caption">%s</span></div>%s' % (name, rival, value, sec)
    elif gh >= 20 and len(name) * 7 <= gw - 14:      # small: the name alone, only when it fits on one line
        inner = '<div class="in"><span class="nm one t-caption">%s</span></div>' % name
    return box + inner + "</div>"


def treemap(rows, selected, hover):
    rows = sorted(rows, key=lambda r: -r["value_b"])
    rects = squarify([r["value_b"] for r in rows], 0, 0, MAP_W, MAP_H)
    return '<div class="tm">%s</div>' % "".join(block(r, rc, r["name"] == selected, r["name"] == hover) for r, rc in zip(rows, rects))


def foot(rows, value_m):
    smallest = min(r["value_b"] for r in rows) * 1000
    leg = "".join('<span><i style="background:var(%s)"></i>%s</span>' % (FAM_COLOR[f], FAM_WORD[f]) for f in ("hw", "sw", "net", "fin", "oth"))
    return ('<div class="hm-foot"><div class="leg t-caption">%s</div>'
            '<div class="hm-you"><span class="you-sq"><i></i></span><span class="l1 t-data-strong">Sen · %s</span>'
            '<span class="l2 t-caption">ölçekli · en küçük bloğun %d\'da biri</span></div></div>'
            % (leg, n(money_m(value_m)), round(smallest / value_m)))


def context():
    l1 = "Nisan 2012: cep telefonu dalgası listenin tepesini taşıyor, ilk sosyal ağ halka arzı yolda."
    l2 = "Bu hafta · %s · %s" % (s("news_jump", company="Cufflink", pct=n("%12"), why=s("why_sub")),
                                 s("news_drop", company="Nordlund Mobile", pct=n("%15"), why=s("why_layoff")))
    return '<div class="hm-ctx"><span class="l1 t-body">%s</span><span class="l2 t-caption">%s</span></div>' % (l1, l2)


# ------------------------------------------------------------------ the card: the selected block
def chart5(r, hist, w=426, h=156):
    """Weekly values from the first week of 2008 to today; a dot and the value at every year end, the last point is today."""
    pts = 14 - (1 - 209) + 1          # week -208 is Thu 3 Jan 2008
    vals = series(r, 14, hist, points=pts)
    w0 = 14 - pts + 1
    pl, pr, pt, pb = 8, 30, 12, 46
    hi = max(vals)
    X = lambda i: pl + i * (w - pl - pr) / float(pts - 1)
    Y = lambda v: pt + (hi - v) / hi * (h - pt - pb)
    ax = h - pb
    g = ['<line class="ax" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pl, w - pr, ax, ax)]
    ends = [(max(i for i in range(pts) if _d(w0 + i).year == y), str(y), hist[y], False) for y in sorted(hist) if y >= 2008]
    g.append('<polyline class="ln" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    for i, label, v, _ in ends:
        g.append('<line class="tk" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), ax, ax + 4))
        g.append('<circle class="dot" cx="%.1f" cy="%.1f" r="3.5"/>' % (X(i), Y(vals[i])))
        g.append('<text class="yr" x="%.1f" y="%d" text-anchor="middle">%s</text>' % (X(i), ax + 18, label))
        g.append('<text class="yv" x="%.1f" y="%d" text-anchor="middle">%s</text>' % (X(i), ax + 38, n(money_b(v))))
    g.append('<circle class="dot now" cx="%.1f" cy="%.1f" r="4"/>' % (X(pts - 1), Y(vals[-1])))
    g.append('<text class="yr now" x="%.1f" y="%.1f" text-anchor="end">bugün</text>' % (X(pts - 1) - 10, Y(vals[-1]) + 4))
    return '<svg class="ch5" width="%d" height="%d">%s</svg>' % (w, h, "".join(g))


def card(r, hist, about, people, value_m):
    who = " · ".join('%s <b>%s</b>' % (s(k), nm) for k, nm in people)
    mult = r["value_b"] * 1000 / value_m
    return ('<aside class="hc"><span class="kick t-label">Seçili blok</span><h2 class="nm t-h2">%s</h2>'
            '<div class="hc-who t-caption">%s<span>%s</span></div>'
            '<span class="val t-hero">%s</span><span class="mult t-caption">senin değerlemenin %d bin katı</span>'
            '<div><div class="sh"><span class="t-label">Değer</span><span class="n t-caption">2008\'den bugüne</span></div>%s</div>'
            '<div><div class="sh"><span class="t-label">%s</span></div><p class="about t-para" style="margin-top:var(--sp-8)">%s</p></div></aside>'
            % (r["name"], tag(r["sector_tr"], "outline"), who, n(money_b(r["value_b"])), round(mult / 1000),
               chart5(r, hist), s("about"), about))


# ------------------------------------------------------------------ frame
def f_harita():
    rows = listed()
    total = sum(r["value_b"] for r in rows)
    value_m = SEED["player"]["seed_post_money_m"]
    body = '<div class="hm">%s%s%s</div>' % (context(), treemap(rows, "Malus", "Datenwald"), foot(rows, value_m))
    about = ("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
             "gelirinin yarısından çoğu bugün o tek üründen geliyor.")
    panel = card(next(r for r in rows if r["name"] == "Malus"), gen.POMELO_HIST, about, [("founder", "Stephan Laborde"), ("ceo", "Timo Koch")], value_m)
    win = gen.window(208, 88, 1424, 928, [(s("kpi_list"), n(money_b(total)), "")], "", body, panel)
    top = dict(gen.TOP_SEED)   # the seed state: the player holds a Seed post-money of $4,2M (seed.json player)
    return gen.page(CSS + gen.screen(gen.topbar(top), gen.rail("piyasa", gen.B_THEME), win, gen.news_market()))


if __name__ == "__main__":
    os.makedirs(gen.BUILD, exist_ok=True)
    with open(os.path.join(gen.BUILD, "dir_harita.html"), "w", encoding="utf-8", newline="\n") as f:
        f.write(f_harita())
    print("built dir_harita")
