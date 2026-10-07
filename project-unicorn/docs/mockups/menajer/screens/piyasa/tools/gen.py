"""Piyasa (the Market window, PRD_RAKIP_DUNYASI §3): builds every frame of group "piyasa" into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only
  python gen.py --sizes    print "name width height scale" per frame

Render with render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css, icons, the
crop rule, the top-bar geometry, measure.py) is read from ../../../system through the copies in syskit/; their caches
live in this folder so nothing is written into the system folder. Every number on a frame comes from seed.json (the
P3 data seed: parody names, April 2012 values, shares, 4-week change) or is derived from it here, in the open (rank
moves, the 52-week sparklines, the list total, the player's virtual rank); INDEX.md says which. Frames named *_en are
the same builders in English (the width pass of SPEC §3.4).

The shell (top bar, rail, ticker, office plate and head icons) is kabuk's: the per-seed state below copies
screens/kabuk/tools/gen.py through satis_finans (office(), topbar(), rail(), ticker()). This group's run starts on
Thu 5 Jan 2012 (PRD §2), so the top-bar date reads 2012.
"""
import datetime
import json
import math
import os
import random
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
from common import T, ic, set_lang  # noqa: E402
from kit import at, tag  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src
common.ICON_FILES.update({"tri_up": "util/tri_up", "tri_down": "util/tri_down", "piyasa": "rail/rivals"})
SEED = json.load(open(os.path.join(HERE, "seed.json"), encoding="utf-8"))
SEED["player_sector"] = "erp"   # the run's sub-type (rival_catalog erp): the Sektörüm filter and the rival rows' tag


def L(tr, en):
    """An existing CSV value in both languages (key in a comment where it helps)."""
    return tr if common.LANG == "tr" else en


def n(v):
    """Seed numbers are written in TR form ($10.000, $4,2M, %4,2); EN swaps the separators and moves the per cent."""
    if common.LANG == "tr":
        return v
    v = v.translate(str.maketrans({".": ",", ",": "."}))
    return re.sub(r"%(\d+(?:\.\d+)?)", r"\g<1>%", v)


# ------------------------------------------------------------------ strings (EN first, TR second; INDEX.md lists the new ones for approval)
NEW = {
    "brand": ("Project Unicorn", "Project Unicorn"),
    "next_end": ("Workday ends · {n} h", "Mesai bitimi · {n} saat"),
    "next_meet": ("{time} · {company}", "{time} · {company}"),
    "tab_piyasa": ("Market", "Piyasa"),                                     # TAB_PIYASA (PRD §3.4)
    "kpi_list": ("List value", "Liste değeri"),
    "kpi_4w": ("4 wk", "4H"),                                               # PIYASA_COL_4W reused as the index KPI key
    "kpi_rank": ("Your rank", "Senin sıran"),
    "f_all": ("All", "Tümü"), "f_tech": ("Technology", "Teknoloji"), "f_fin": ("Finance", "Finans"), "f_mine": ("My sector", "Sektörüm"),
    "col_rank": ("#", "#"), "col_company": ("Company", "Şirket"), "col_founder": ("Founder/CEO", "Kurucu/CEO"),   # PIYASA_COL_*
    "col_value": ("Market value", "Piyasa değeri"), "col_price": ("Price", "Fiyat"), "col_4w": ("4 wk", "4H"),
    "col_52w": ("52 wk", "52H"),
    "rank_delta_tip": ("Rank change · 4 wk", "Sıra değişimi · 4H"),
    "rank_delta_tip_since": ("Rank change · since your last look", "Sıra değişimi · son bakışından beri"),   # [I4] PIYASA_COL_RANK_DELTA_TIP_SINCE
    "new": ("New", "Yeni"),
    "detail_close": ("Close", "Kapat"),                                      # PIYASA_DETAIL_CLOSE (the panel's own closer; the window keeps the ×)
    "r_13w": ("13W", "13H"), "r_1y": ("1Y", "1Y"), "r_5y": ("5Y", "5Y"), "r_all": ("All", "Tümü"),   # PIYASA_RANGE_*
    "eoy": ("End of year value", "Yıl sonu değeri"),                        # PIYASA_EOY_TITLE
    "eoy_year": ("Year", "Yıl"), "eoy_value": ("Value", "Değer"), "eoy_change": ("Change", "Değişim"),
    "today_row": ("{y} (today)", "{y} (bugün)"),
    "about": ("About", "Hakkında"), "peers": ("Peers", "Benzerler"), "products": ("Products", "Ürünleri"),   # PIYASA_PRODUCTS_TITLE
    "founder": ("Founder", "Kurucu"), "ceo": ("CEO", "CEO"),
    "player_row": ("You · {value} valuation · would sit near #{rank} on the list", "Sen · {value} değerleme · listedeki karşılığın ~#{rank}"),   # PIYASA_PLAYER_ROW
    "gap_next": ("{company} is {gap} ahead", "{company} {gap} önde"),       # PIYASA_GAP_NEXT
    "passed": ("Your virtual rank passed {company}", "{company} geride kaldı"),   # [I4] PIYASA_PASSED, the strip's second line
    "news_jump": ("{company} jumps {pct} ({why})", "{company} {pct} yükseldi ({why})"),   # PIYASA_NEWS_JUMP + {why}
    "news_drop": ("{company} drops {pct} ({why})", "{company} {pct} düştü ({why})"),
    "why_sub": ("subscription revenue", "abonelik geliri"),
    "why_layoff": ("layoffs in the phone unit", "telefon kolunda işten çıkarma"),
    "news_ipo": ("{company} IPO: {value} on day one", "{company} halka arzı: ilk gün {value}"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if common.LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ dates (PRD §2: the run starts Thu 5 Jan 2012, a tick = 7 days)
MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
MON_AB_TR = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
MON_AB_EN = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def _d(week):
    return datetime.date(2012, 1, 5) + datetime.timedelta(days=7 * (week - 1))


def mon_ab(d):
    return L(MON_AB_TR, MON_AB_EN)[d.month - 1]


def date(week):
    d = _d(week)
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    return L("Hafta %d · %s %d", "Week %d · %s %d") % (w, L(MON_TR, MON_EN)[d.month - 1], d.year)


def date_c(week):
    return L("H%d · %s", "W%d · %s") % (week, mon_ab(_d(week)))


# ------------------------------------------------------------------ number forms (TR written, n() flips for EN)
def money_b(v):
    """v in billions: $1,2T · $560B · $3,5B · $236M."""
    if v >= 1000:
        return "$%sT" % ("%.1f" % (v / 1000)).replace(".", ",")
    if v >= 10:
        return "$%dB" % round(v)
    if v >= 1:
        return "$%sB" % ("%.1f" % v).replace(".", ",")
    return "$%dM" % round(v * 1000)


def money_m(v):
    """v in millions: $4,2M · $18M · $232M."""
    return ("$%dM" % round(v)) if v >= 10 else ("$%sM" % ("%.1f" % v).replace(".", ","))


def price(p):
    return "$" + ("{:,.2f}".format(p)).translate(str.maketrans({",": ".", ".": ","}))


def pct_txt(p, dec=1):
    """TR %4,2 (gain) and −%1,5 (drop, U+2212); the sign of a gain is the glyph, not a plus. dec=0: %150."""
    body = "%%%s" % (("%.1f" % abs(p)).replace(".", ",") if dec else "%d" % round(abs(p)))
    return ("−" + body) if p < 0 else body


def signed_pct(p):
    return ("+" if p > 0 else "−" if p < 0 else "") + "%%%s" % ("%.1f" % abs(p)).replace(".", ",")


# ------------------------------------------------------------------ top bar (satis_finans copy of kabuk's geometry, brand block = decision 14 option (a))
PHASES = {1: "Bootstrap", 2: "Traction", 3: "Series A"}


def runway_v(months):
    if months == "profitable":
        return "Runway", T("profitable"), "pos"
    return "Runway", L("%d ay", "%d mo") % months, "neg" if months < 3 else ""


def topbar(v, compact=False, W=1920):
    col, g, time_w = kit.tb_layout(compact)
    rk, rv, rc = runway_v(v["run"])
    nc = "pos" if not v["net"].startswith("−") else ""
    out = []
    if compact:
        out.append('<span class="brand-sq" style="left:22px;top:22px"></span>')
    else:
        out += ['<span class="brand-sq" style="left:20px;top:13px"></span>',
                at(48, 31, "t-subhead", s("brand"), "tb-co", width=g["brand"] - 48 - 12),
                at(48, 50, "t-micro", PHASES[v["phase"]], "tb-k").replace('<span class=', '<span lang="en" class=', 1)]
        for i in range(3):
            out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i < v["phase"] else "", 48 + kit.TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"),
            at(col["B"], b1, "t-hero", n(v["cash"]), "tb-hero"),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", n(v["net"]) + '<span class="tb-u">%s</span>' % T("per_mo"), {"pos": "tb-d", "": "tb-v"}[nc]),
            at(col["C"], b1, "t-label", T("runway"), "tb-k"),
            at(col["D"], b1, "t-value", rv, "tb-v " + rc),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", n(v["mrr"]), "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", str(v.get("brandv", 50)), "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", n(v["burn"]) + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", str(v.get("repv", 0)), "tb-v")]
    gate_x = W - time_w - g["gate"]
    d0 = col["metrics_end"]
    pad = 16 if compact else 20
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + pad, 28, "t-body", date_c(v["week"]) if compact else date(v["week"]), "tb-date"))
    out.append(kit.week_bar(d0 + pad, min(gate_x - pad, d0 + pad + 720), now_h=v["clock"], marks=v.get("marks", ()), end=17))
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"]))
    tx = gate_x + g["gate_pad"]
    out.append(at(tx, 29, "t-micro", T("next"), "nx-l"))
    out.append(at(tx, 50, "t-key", v["slot"][0], "nx-s " + v["slot"][1], width=g["gate"] - 2 * g["gate_pad"]))
    tx0 = W - time_w
    out.append('<div class="tb-time" style="left:%dpx;width:%dpx"></div>' % (tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "%02d:00" % int(v["clock"]), "tb-clock"))
    kx = tx0 + g["time_pad"][0] + kit.TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if k == "II" else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    return '<header class="topbar%s"%s>%s</header>' % (" is-compact" if compact else "", (' style="width:%dpx;right:auto"' % W) if W != 1920 else "", "".join(out))


def theme_slot():
    return (s("next_meet", time="14:00", company="Karadeniz Fabrika"), "")


def end_slot(clock):
    return (s("next_end", n=17 - int(clock)), "")


# the theme seed (kabuk SEED, H14 11:00) and two derived later states for the comparison strip (INDEX.md)
TOP_THEME = dict(week=14, clock=11, phase=1, cash="$10.000", net="+$2,5K", run="profitable", mrr="$4,0K", burn="$1,5K", marks=(14,), slot=theme_slot())
TOP_SEED = dict(week=14, clock=11, phase=2, cash="$418.000", net="+$1,8K", run="profitable", mrr="$11,4K", burn="$9,6K", marks=(14,), slot=theme_slot())
TOP_A = dict(week=14, clock=8, phase=3, cash="$330.000", net="+$124K", run="profitable", mrr="$125K", burn="$1,5K", slot=end_slot(8))
B_THEME = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


# ------------------------------------------------------------------ rail: Piyasa under Finans, above Kişisel (owner decision; BRIEF §1)
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"), ("piyasa", None),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]


def rail(active, badges, icons=False):
    rows = []
    for key, name in RAIL:
        label = s("tab_piyasa") if key == "piyasa" else T(name)
        b = "lock" if key == "pazarlama" else badges.get(key)
        cls = "rr" + (" is-active" if key == active else "") + (" is-locked" if b == "lock" else "")
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (label, T("soon"))
            right = ('<span class="lk">%s</span>' % ic("lock", 12)) if icons else ""
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % label
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    return ('<nav class="rail%s">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", "".join(rows), ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ ticker: the piyasa source sends "{headline} ({why})" lines through the existing outlets (PRD §3.6)
TICKER = {  # localization/strings.csv
    "TICKER_04": ("Teknoloji kampüslerinde staj kontenjanları rekor kırdı.", "Internship quotas hit a record across tech campuses."),
    "TICKER_07": ("Melek yatırım ağları yeni dönem başvurularını açtı.", "Angel networks open applications for the new season."),
    "TICKER_10": ("Teknoloji basınında değerleme sohbeti hiç bitmiyor.", "Valuation chatter never stops in the tech press."),
}
PUB = {"sektor": "Sektör Telgrafı", "ekonomi": "Ekonomi Postası", "teknogundem": "TeknoGündem", "girisim": "Girişim Bülteni"}


def news_market(ipo=False):
    first = s("news_ipo", company="Facewall", value=n(money_b(SEED["ipo_frame"]["value_b"]))) if ipo \
        else s("news_jump", company="Cufflink", pct=n("%12"), why=s("why_sub"))
    return [("ekonomi", first), ("sektor", L(*TICKER["TICKER_04"])),
            ("teknogundem", s("news_drop", company="Nordlund Mobile", pct=n("%15"), why=s("why_layoff"))),
            ("girisim", L(*TICKER["TICKER_07"])), ("ekonomi", L(*TICKER["TICKER_10"]))]


def ticker(items):
    out = []
    for i, (k, text) in enumerate(items):
        if i:
            out.append('<span class="tk-sep">   ·   </span>')
        out.append('<span class="tk-pub %s">%s</span><span class="tk-hl">%s</span>' % (k, PUB[k], text))
    return '<footer class="ticker"><div class="tk-toggle">%s</div><div class="tk-run">%s</div></footer>' % (ic("news"), "".join(out))


# ------------------------------------------------------------------ office layer (kabuk office(): noicons plate + A2 head sprites)
PLATES = {
    1920: ("art/office_safe_1920_noicons.png", "art/office_safe_1920_heads.json", 1736, 976, (184, 64, 1736, 976)),
    1536: ("art/office_safe_1536_noicons.png", "art/office_safe_1536_heads.json", 1352, 760, (64, 64, 1472, 760)),
}
HEAD_FILE = {"plan": "research", "research": "research", "test": "test", "design": "design", "phone": "phone", "code": "code",
             "coffee": "coffee", "wc": "wc", "visit": "meeting", "meeting": "meeting", "food": "food"}


def office(W):
    f, hj, pw, ph, (x, y, w, h) = PLATES[W]
    k = max(w / pw, h / ph)
    ox, oy = x + (w - pw * k) / 2, y + (h - ph * k) / 2
    out = ['<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;overflow:hidden">' % (x, y, w, h),
           '<div class="abs" style="left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%.1fpx;background:url(%s%s) 0 0/100%% 100%%"></div>'
           % (ox - x, oy - y, pw * k, ph * k, REL, f)]
    for p in json.load(open(os.path.join(MEN, hj), encoding="utf-8"))["people"]:
        if not p.get("icon_visible"):
            continue
        sz = p["icon_px"] * k
        cx, cy = ox + p["icon_xy"][0] * k - x, oy + p["icon_xy"][1] * k - y
        out.append('<img class="head-ic" src="%ssystem/icons/office/%s.svg" style="left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%.1fpx">'
                   % (REL, HEAD_FILE[p["status"]], cx - sz / 2, cy - sz / 2, sz, sz))
    out.append("</div>")
    return '<div class="office-layer" style="filter:brightness(var(--dim))">%s</div>' % "".join(out)


# ------------------------------------------------------------------ page and screen
def page(body, w1536=False, cb=False):
    return ('<!doctype html><html lang="%s"%s><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../piyasa.css"></head><body%s>%s</body></html>'
            % (common.LANG, ' class="w1536"' if w1536 else "", s("tab_piyasa"), common.FONTS, REL, REL,
               ' class="cb" data-palette="cb"' if cb else "", body))


def screen(top, rail_html, window, news, w=1920):
    # the Piyasa window (1424×928 at 1920) overlaps BuildHUD, the notice stack and Ofisi taşı, so the floats hide (SPEC §9)
    return '<div class="screen">%s%s%s%s%s</div>' % (office(w), window, top, rail_html, ticker(news))


def scrollbar(top, height, thumb_top, thumb_h):
    return ('<div class="sb" style="top:%dpx;height:%dpx"><div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>'
            % (top, height, thumb_top, thumb_h))


# ------------------------------------------------------------------ data: the listed rows, rank moves, the sparkline series
def listed(week=14):
    rows = [dict(r) for r in SEED["rows"] if r.get("rank")]
    if week >= SEED["ipo_frame"]["week"]:   # Facewall lists in week 20 at its first-day value (seed ipo_frame)
        f = next(dict(r) for r in SEED["rows"] if r["target"] == SEED["ipo_frame"]["target"])
        f.update(value_b=SEED["ipo_frame"]["value_b"], price=SEED["ipo_frame"]["value_b"] / f["shares_b"], new=True)
        rows.append(f)
    rows.sort(key=lambda r: -r["value_b"])
    for i, r in enumerate(rows):
        r["rank"] = i + 1
    return rows


def rank_moves(rows):
    """Rank four weeks ago from value / (1 + 4-week change), compared with today's rank among the same rows: a row
    listed since then (Yeni) is left out of both orders, so its entry pushes nobody down."""
    old = [r for r in rows if not r.get("new")]
    now_rank = {r["name"]: i + 1 for i, r in enumerate(old)}
    old.sort(key=lambda r: -r["value_b"] / (1 + r["pct_4w"] / 100.0))
    return {r["name"]: (i + 1 - now_rank[r["name"]]) for i, r in enumerate(old)}


def series(r, week=14, hist=None, points=52):
    """52 weekly values ending at today's value. With hist (year → year-end value) the curve is log-interpolated between
    those anchors (PRD §3.3) and the last December tick is pinned to hist[year − 1], so the chart and the year-end table
    agree; without it (the list sparklines) the start is a seeded one-year change. The point four weeks back honours
    pct_4w. Noise fades out at every pinned point. Seeded by name: stable."""
    rnd = random.Random(r["name"])
    end = r["value_b"]
    w0 = week - points + 1
    if hist:   # the December ticks of the two years before the window's start are the anchors the 1Y curve interpolates between
        ticks = [(i, _d(w0 + i).year) for i in range(-60, points)]
        anchors = {max(i for i, y in ticks if y == year): v for year, v in hist.items() if any(y == year for _, y in ticks)}
        anchors[points - 1] = end
    else:
        anchors = {0: end / (1 + rnd.uniform(-0.2, 0.35)), points - 1: end}
    keys = sorted(anchors)
    ph = [rnd.uniform(0, 2 * math.pi) for _ in range(3)]
    amp = rnd.uniform(0.03, 0.07)
    pinned = [i for i in keys if 0 <= i < points] + [points - 5]
    out = []
    for i in range(points):
        a = max(k for k in keys if k <= i)
        b = min(k for k in keys if k >= i)
        base = anchors[a] if a == b else anchors[a] * math.exp(math.log(anchors[b] / anchors[a]) * (i - a) / float(b - a))
        t = i / float(points - 1)
        noise = sum(math.sin(2 * math.pi * (k + 1) * 1.3 * t + ph[k]) / (k + 1) for k in range(3)) * amp
        fade = min(1.0, min(abs(i - p) for p in pinned) / 6.0)
        out.append(base * (1 + noise * fade))
    out[-5] = end / (1 + r["pct_4w"] / 100.0)
    return out


def spark(vals, w=112, h=24):
    lo, hi = min(vals), max(vals)
    X = lambda i: 1 + i * (w - 2) / float(len(vals) - 1)
    Y = lambda v: 2 + (hi - v) / float(hi - lo or 1) * (h - 4)
    pts = " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals))
    return ('<svg class="spark" width="%d" height="%d"><polyline points="%s"/><circle cx="%.1f" cy="%.1f" r="2.5"/></svg>'
            % (w, h, pts, X(len(vals) - 1), Y(vals[-1])))


def company(r):
    """The listed row's name cell, one line: name · sector (ink-3). A rival of the player's sub-type carries the sector
    tag instead (the Sektörüm filter's own word), so the word is never printed twice."""
    if r["group"] == "sektor":
        return '<div class="cell co"><span class="nm t-data-strong">%s</span>%s</div>' % (r["name"], tag(SEED["player_sector"], "outline"))
    sec = r["sector_tr"] if common.LANG == "tr" else r["sector_en"]
    return '<div class="cell co"><span class="nm t-data-strong">%s</span><span class="sec t-small">· %s</span></div>' % (r["name"], sec)


def delta_cell(r, moves):
    if r.get("new"):
        return '<div class="cell c">%s</div>' % tag(s("new"), "neutral")
    d = moves.get(r["name"], 0)
    if not d:
        return '<div class="cell"></div>'
    up = d > 0
    return '<div class="cell c"><span class="dl %s">%s%d</span></div>' % ("up" if up else "", ic("tri_up" if up else "tri_down", 12), abs(d))


def pct_cell(p, cls="cell num", dec=1):
    if p is None:
        return '<div class="%s"></div>' % cls
    if p > 0:
        return '<div class="%s"><span class="pct up">%s%s</span></div>' % (cls, ic("tri_up", 12), n(pct_txt(p, dec)))
    return '<div class="%s"><span class="pct">%s</span></div>' % (cls, n(pct_txt(p, dec)))


def head(since=False):
    cols = [('<div class="th r t-label">%s</div>' % s("col_rank")),
            ('<div class="th glyph" title="%s">%s%s</div>' % (s("rank_delta_tip_since" if since else "rank_delta_tip"), ic("tri_up", 12), ic("tri_down", 12))),
            ('<div class="th t-label">%s</div>' % s("col_company")),
            ('<div class="th founder t-label">%s</div>' % s("col_founder")),
            ('<div class="th r t-label">%s</div>' % s("col_value")),
            ('<div class="th r t-label">%s</div>' % s("col_price")),
            ('<div class="th r t-label">%s</div>' % s("col_4w")),
            ('<div class="th r t-label" style="padding-right:8px">%s</div>' % s("col_52w"))]
    return '<div class="tbl-head grid">%s</div>' % "".join(cols)


def row(r, moves, week, selected=False):
    cells = [('<div class="cell rank">%d</div>' % r["rank"]), delta_cell(r, moves), company(r),
             ('<div class="cell founder t-data">%s</div>' % r["person"]),
             ('<div class="cell num hi">%s</div>' % n(money_b(r["value_b"]))),
             ('<div class="cell num">%s</div>' % n(price(r["price"]))),
             pct_cell(r.get("pct_4w")),
             ('<div class="cell spark">%s</div>' % ("" if r.get("new") else spark(series(r, week))))]
    return '<div class="row grid%s">%s</div>' % (" is-selected" if selected else "", "".join(cells))


def virtual_rank(rows, value_m):
    """PRD §3.5: 1 + the number of listed rows worth more than the player."""
    return 1 + sum(1 for r in rows if r["value_b"] * 1000 > value_m)


def you_strip(rows, value_m, passed=None):
    """The second line carries the gap to the next row up; in the [I4] pass state the passed company comes first."""
    rank = virtual_rank(rows, value_m)
    above = [r for r in rows if r["value_b"] * 1000 > value_m]
    nxt = min(above, key=lambda r: r["value_b"]) if above else None
    l2 = [s("passed", company=passed)] if passed else []
    if nxt:
        g = nxt["value_b"] * 1000 - value_m
        l2.append(s("gap_next", company=nxt["name"], gap=n(money_m(g) if g < 1000 else money_b(g / 1000))))
    return ('<div class="you"><div class="l1 t-body">%s</div><div class="l2 t-small">%s</div></div>'
            % (s("player_row", value=n(money_m(value_m)), rank=rank), " · ".join(l2))), rank


def table(rows, moves, body_h, week, narrow=False, first=0, selected=None, you=None, since=False):
    """body_h: the list column's height. The rows area is as tall as its rows and the strip follows in the flow; only a
    list that overflows fills the column, which puts the strip at the bottom, and the scrollbar reads the clipped area."""
    avail = body_h - 16 - 24 - 36 - (76 if you else 0)
    vis = avail // 40
    shown = rows[first:first + vis + 1]   # one more row than fits: the clipped row reads as a scroll
    html = "".join(row(r, moves, week, selected=(r["name"] == selected)) for r in shown)
    thumb_h = max(48, int(avail * vis / float(len(rows))))
    thumb_top = int((avail - thumb_h) * first / float(max(1, len(rows) - vis)))
    sb = scrollbar(16 + 36, avail, thumb_top, thumb_h) if len(rows) > vis else ""
    return ('<div class="mk-list"><div class="mk%s tbl">%s<div class="mk-rows" style="height:%dpx"><div class="rows">%s</div></div></div>%s%s</div>'
            % (" narrow" if narrow else "", head(since), min(avail, 40 * len(shown)), html, you or "", sb))


# ------------------------------------------------------------------ detail panel
def value_chart(vals, week, w=472, h=136):
    """The 1Y range: 52 weekly points to today; month ticks, the year named at January and at the first tick."""
    pad_l, pad_r, pad_t, pad_b = 56, 10, 10, 22
    lo, hi = min(vals), max(vals)
    span = hi - lo or hi
    base = 10 ** math.floor(math.log10(span))
    lines = 3 if h < 160 else 4   # gridlines the height can carry
    for step in (base, base * 2, base * 5, base * 10, base * 20):
        ylo, yhi = math.floor(lo / step) * step, math.ceil(hi / step) * step
        if round((yhi - ylo) / step) <= lines:
            break
    X = lambda i: pad_l + i * (w - pad_l - pad_r) / float(len(vals) - 1)
    Y = lambda v: pad_t + (yhi - v) / float(yhi - ylo) * (h - pad_t - pad_b)
    g = []
    for k in range(int(round((yhi - ylo) / step)) + 1):
        v = ylo + k * step
        g.append('<line class="ch-grid" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % (pad_l, w - pad_r, Y(v), Y(v)))
        g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 8, Y(v) + 4, n(money_b(v))))
    w0 = week - len(vals) + 1
    starts = [i for i in range(1, len(vals)) if _d(w0 + i).month != _d(w0 + i - 1).month]
    jan = next(i for i in starts if _d(w0 + i).month == 1)
    for i in starts:   # a tick per month; every second month is named, January with its year
        g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(i), X(i), h - pad_b, h - pad_b + 4))
        if (starts.index(i) - starts.index(jan)) % 2:
            continue
        d = _d(w0 + i)
        year = d.month == 1 or i == starts[0] or i == starts[1]
        g.append('<text class="ch-lbl%s" x="%.1f" y="%d" text-anchor="middle">%s</text>'
                 % (" year" if year else "", X(i), h - 4, mon_ab(d) + (" %d" % d.year if year else "")))
    g.append('<line class="ch-axis" x1="%d" x2="%d" y1="%d" y2="%d"/>' % (pad_l, w - pad_r, h - pad_b, h - pad_b))
    g.append('<polyline class="ch-line" points="%s"/>' % " ".join("%.1f,%.1f" % (X(i), Y(v)) for i, v in enumerate(vals)))
    g.append('<circle class="ch-last" cx="%.1f" cy="%.1f" r="4"/>' % (X(len(vals) - 1), Y(vals[-1])))
    return '<div class="chart"><svg width="%d" height="%d">%s</svg></div>' % (w, h, "".join(g))


def section(title, inner, right=""):
    return '<div class="dt-sec"><div class="h t-label">%s%s</div>%s</div>' % (title, right, inner)


def ranges():
    tabs = [("r_13w", False), ("r_1y", True), ("r_5y", False), ("r_all", False)]
    return '<div class="seg">%s</div>' % "".join('<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if on else "", s(k)) for k, on in tabs)


def eoy_table(hist, today_v, year=2012):
    years = sorted(hist)
    out = ['<div class="tbl-head grid"><div class="th t-label">%s</div><div class="th r t-label">%s</div><div class="th r t-label">%s</div></div>'
           % (s("eoy_year"), s("eoy_value"), s("eoy_change"))]
    for y in years[1:] + [None]:
        v = today_v if y is None else hist[y]
        p = hist[years[-1]] if y is None else hist[years[years.index(y) - 1]]
        label = s("today_row", y=year) if y is None else str(y)
        ch = (v / p - 1) * 100
        out.append('<div class="row sm grid%s"><div class="cell y t-data">%s</div><div class="cell num t-data">%s</div>%s</div>'
                   % (" is-today" if y is None else "", label, n(money_b(v)), pct_cell(ch, "cell num t-data", dec=1 if abs(ch) < 10 else 0)))
    return '<div class="eoy tbl">%s</div>' % "".join(out)


def detail(r, week, chart_h, hist, about, peers, people=(), products=()):
    sec = r["sector_tr"] if common.LANG == "tr" else r["sector_en"]
    who = "".join('<span><span class="k t-caption">%s</span><span class="n t-data">%s</span></span>' % (s(k), nm) for k, nm in people)
    # the panel's closer is a small ghost button, not a second ×: the window's × stays the only × (Esc order: panel, then window)
    head_html = ('<div><div class="dt-head"><h2 class="t t-h2">%s</h2><span class="btn btn-ghost btn-sm">%s</span></div>'
                 '<div class="dt-sub t-caption">%s%s</div></div>' % (r["name"], s("detail_close"), tag(sec, "outline"), ('<span class="whos">%s</span>' % who) if who else ""))
    val = ('<div class="dt-val"><span class="v t-hero">%s</span><span class="p t-data">%s</span>%s</div>'
           % (n(money_b(r["value_b"])), n(price(r["price"])), pct_cell(r["pct_4w"], "p t-data")))
    # peers are proper names: the chips sit beside the caps key, not inside it, and keep the data face
    chips = "".join('<span class="chip sm t-data">%s</span>' % p for p in peers)
    parts = [head_html, val,
             section(L("Değer", "Value"), value_chart(series(r, week, hist), week, h=chart_h), ranges()),
             section(s("eoy"), eoy_table(hist, r["value_b"])),
             section(s("about"), '<p class="p t-body">%s</p>' % about),
             '<div class="dt-sec inline"><div class="h t-label">%s</div><div class="chips">%s</div></div>' % (s("peers"), chips)]
    if products:
        parts.append(section(s("products"), "".join('<div class="prod-row"><span class="l t-data">%s</span><span class="s t-caption">%s</span></div>' % (a, b) for a, b in products)))
    return '<aside class="mk-detail">%s</aside>' % "".join(parts)


# detail seeds: end-of-year values (rounded real analogue for the giant, fiction for the sector tail), the parody-world paragraph, peers
POMELO_HIST = {2007: 170, 2008: 76, 2009: 190, 2010: 295, 2011: 375}
PYTHIA_HIST = {2007: 0.175, 2008: 0.14, 2009: 0.12, 2010: 0.17, 2011: 0.21}


def pomelo_detail(week):
    about = L("Cihazı ve işletim sistemini tek çatı altında yapan tüketici elektroniği devi. 2007'deki telefonu cep pazarını yeniden kurdu; "
              "gelirinin yarısından çoğu bugün o tek üründen geliyor.",
              "A consumer electronics giant that builds the device and its operating system under one roof. Its 2007 phone remade the "
              "handset market; more than half its revenue now comes from that one product.")
    return detail(next(r for r in listed(week) if r["name"] == "Malus"), week, 240, POMELO_HIST, about, ["Samdal", "Fenstra", "Gogol"],
                  people=[("founder", "Stephan Laborde"), ("ceo", "Timo Koch")])


def pythia_detail(week):
    about = L("Küçük ve orta işletmelere bulutta muhasebe ve stok satan kurumsal yazılımcı; büyümesi yavaş ama kârlı.",
              "An enterprise vendor selling cloud accounting and stock to small and mid-size firms; growth is slow but profitable.")
    products = [(L("Defter", "Ledger"), L("Hesap Planı", "Chart of Accounts")),                 # PROD_LINE_ERP_LEDGER · PROD_STEP_ERP_LEDGER_K2
                (L("Fatura", "Invoicing"), L("Toplu Fatura", "Batch Invoicing")),               # PROD_LINE_ERP_INVOICING · _K2
                (L("Nakit Akışı", "Cash Flow"), L("Nakit Akış Tablosu", "Cash Flow Statement"))]  # PROD_LINE_ERP_CASHFLOW · _K2
    # chart 104: with the products section the panel's 810 px budget holds head 56 + value 35 + 7 gaps 84 + chart 140 + year-end 232 + about 80 + peers 32 + products 132
    return detail(next(r for r in listed(week) if r["name"] == "Pythia"), week, 104, PYTHIA_HIST, about, ["Datenwald", "Venditor", "Vatic Systems"],
                  products=products)


# ------------------------------------------------------------------ window
FILTERS = [("all", "f_all"), ("tech", "f_tech"), ("fin", "f_fin"), ("sektor", "f_mine")]


def ctl(active="all"):
    return '<div class="win-ctl">%s</div>' % "".join('<span class="chip%s">%s</span>' % (" is-on" if k == active else "", s(key)) for k, key in FILTERS)


def kpis(rows, rank=None):
    total = sum(r["value_b"] for r in rows)
    old = sum(r["value_b"] / (1 + r["pct_4w"] / 100.0) for r in rows if not r.get("new"))
    now = sum(r["value_b"] for r in rows if not r.get("new"))
    idx = (now / old - 1) * 100
    return [(s("kpi_list"), n(money_b(total)), ""),
            (s("kpi_4w"), ("%s%s" % (ic("tri_up", 16), n(pct_txt(idx)))) if idx > 0 else n(pct_txt(idx)), "pos" if idx > 0 else ""),
            (s("kpi_rank"), ("~#%d" % rank) if rank else "", "")]


def window(x, y, w, h, kpi, ctl_html, body, panel=""):
    k = "".join('<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi %s">%s</span></div>' % (a, c, v) for a, v, c in kpi)
    head_html = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><div class="win-kpis">%s</div><div class="grow"></div>'
                 '<span class="win-close">%s</span></div>' % (s("tab_piyasa"), k, ic("close")))
    main = '<div class="grow" style="display:flex;flex-direction:column;min-height:0">%s<div class="win-body market">%s</div></div>' % (ctl_html, body)
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s<div style="display:flex;flex:1;min-height:0">%s%s</div></section>'
            % (x, y, w, h, head_html, main, panel))


def frame(rows, top, body_h=798, w1536=False, cb=False, active="all", since=False, panel=None, first=0, selected=None, value_m=None,
          passed=None, week=14):
    """body_h: the list column below the control strip (window 928 − border 2 − head 72 − ctl 56; 582 at 1536)."""
    moves = rank_moves(rows)
    you, rank = (you_strip(rows, value_m, passed) if value_m else ("", None))
    show = rows if active == "all" else [r for r in rows if r["group"] == active]
    body = table(show, moves, body_h, week, narrow=bool(panel), first=first, selected=selected, you=you, since=since)
    news = news_market(ipo=week >= SEED["ipo_frame"]["week"])
    if w1536:
        win = window(88, 88, 1424, 712, kpis(rows, rank), ctl(active), body)
        return page(screen(topbar(top, compact=True, W=1536), rail("piyasa", B_THEME, icons=True), win, news, w=1536), w1536=True)
    win = window(208, 88, 1424, 928, kpis(rows, rank), ctl(active), body, panel or "")
    return page(screen(topbar(top), rail("piyasa", B_THEME), win, news), cb=cb)


# ------------------------------------------------------------------ frames
def f_liste():
    return frame(listed(), TOP_THEME)


def f_detay_dev(cb=False):
    return frame(listed(), TOP_THEME, panel=pomelo_detail(14), selected="Malus", cb=cb)


def f_detay_sektor():
    return frame(listed(), TOP_THEME, panel=pythia_detail(14), selected="Pythia", first=17)


def f_seed_sonrasi():
    return frame(listed(), TOP_SEED, value_m=SEED["player"]["seed_post_money_m"])


def f_series_a():
    return frame(listed(), TOP_A, value_m=SEED["player"]["series_a_valuation_m"])


def f_filtre_sektor():
    return frame(listed(), TOP_SEED, active="sektor", value_m=SEED["player"]["seed_post_money_m"])


def f_ipo():
    wk = SEED["ipo_frame"]["week"]
    return frame(listed(wk), dict(TOP_SEED, week=wk), value_m=SEED["player"]["seed_post_money_m"], week=wk)


def f_1536():
    return frame(listed(), TOP_THEME, body_h=582, w1536=True)


def f_gecis():
    # [I4] display only: the seed's tail is Pythia at $236M, so a pass needs a valuation above it; $240M is fiction (INDEX.md)
    return frame(listed(), TOP_A, value_m=240, since=True, passed="Pythia")


FRAMES = {
    "piyasa__liste": f_liste,
    "piyasa__detay_dev": f_detay_dev,
    "piyasa__detay_sektor": f_detay_sektor,
    "piyasa__seed_sonrasi": f_seed_sonrasi,
    "piyasa__series_a": f_series_a,
    "piyasa__filtre_sektor": f_filtre_sektor,
    "piyasa__ipo": f_ipo,
    "piyasa__1536": f_1536,
    "piyasa__renk_koru": lambda: f_detay_dev(cb=True),
    "piyasa__gecis": f_gecis,
}
EN = ["piyasa__liste"]


def jobs():
    return [(k, "tr") for k in FRAMES] + [(k + "_en", "en") for k in EN]


def main(names):
    os.makedirs(BUILD, exist_ok=True)
    for name, lang in jobs():
        if names and name not in names:
            continue
        set_lang(lang)
        try:
            html = FRAMES[name[:-3] if lang == "en" else name]()
        finally:
            set_lang("tr")
        with open(os.path.join(BUILD, name + ".html"), "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print("built", name)


if __name__ == "__main__":
    if sys.argv[1:] == ["--sizes"]:
        for name, _ in jobs():
            print(name, *((1536, 864, 1.25) if name.endswith("__1536") else (1920, 1080, 1)))
    else:
        main(sys.argv[1:])
