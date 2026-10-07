"""Satış and Finans (Özet, Yatırım): builds every frame of group "satis_finans" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css, icons, the
crop rule, the top-bar geometry, measure.py) is read from ../../../system through the copies in syskit/; their caches
live in this folder so nothing is written into the system folder. Every number on a frame is a seed value
(data/screens.md, baseline/INDEX.md and the shot seeds in main.gd) or is derived from the game's rules here, in the
open; INDEX.md says which. Frames named *_en are the same builders in English (the width pass of SPEC §3.4).

The shell (top bar slot and marks, rail badges, notice stack, BuildHUD, office plate and head icons) is kabuk's: the
per-seed state below copies screens/kabuk/tools/gen.py (SEED, B14, SEED_NOTICES, office(), buildhud(), notices()).
"""
import datetime
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
import measure  # noqa: E402
from common import T, ic, set_lang  # noqa: E402
from kit import at, tag, stars  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src  # avatar() and portrait() resolve image paths through this
common.ICON_FILES.update({"tri_up": "util/tri_up", "tri_down": "util/tri_down"})

FRANK = os.path.join(MEN, "portraits", "frank_cand_a.png")
BUST = {k: os.path.join(MEN, "art", "bust_%s.png" % k) for k in ("burak",)}
VC_LEAD = {f: os.path.join(MEN, "art", "busts", "vc", "bust_%s_0_vc_lead.png" % f) for f in ("anchor", "nexus", "bosphorus", "meridian")}


def L(tr, en):
    """An existing CSV value in both languages (key in a comment where it helps)."""
    return tr if common.LANG == "tr" else en


def n(v):
    """Seed numbers are written in TR form ($10.000, $4,0K, %4, %0,1); EN swaps the separators and moves the per cent."""
    if common.LANG == "tr":
        return v
    v = v.translate(str.maketrans({".": ",", ",": "."}))
    return re.sub(r"%(\d+(?:\.\d+)?)", r"\g<1>%", v)


# ------------------------------------------------------------------ new strings (EN first, TR second; INDEX.md lists them for approval)
NEW = {
    "brand": ("Project Unicorn", "Project Unicorn"),
    "today": ("Today · W{n}", "Bugün · H{n}"),
    "zero": ("Cash hits zero · W{n}", "Kasa sıfır · H{n}"),
    "below": ("Below zero", "Sıfırın altı"),
    "tip_cash": ("Cash {amount}", "Kasa {amount}"),
    "tip_flow": ("Net {net}/mo · Runway {runway}", "Net {net}/ay · Runway {runway}"),
    "shutter_k": ("Shutter", "Kepenk"),
    "est_val": ("Est. valuation", "Tahmini değerleme"),
    "est_eq": ("Est. equity", "Tahmini pay"),
    "val_range": ("${lo}M to ${hi}M", "${lo}M ile ${hi}M"),
    "eq_range": ("{lo}% to {hi}%", "%{lo} ile %{hi}"),
    "tier2": ("Tier 2 fund", "2. kademe fonu"),
    "next_end": ("Workday ends · {n} h", "Mesai bitimi · {n} saat"),
    "next_offer": ("Offer · {n} weeks left", "Teklif · {n} hafta kaldı"),
    "next_meet": ("{time} · {company}", "{time} · {company}"),
    "no_bugs": ("No confirmed bugs.", "Doğrulanmış hata yok."),
    "confirmed": ("Confirmed {n}", "Doğrulanmış {n}"),
    "flow_pace": ("at the current pace", "mevcut gidişle"),
    "acct_sat": ("Satisfaction", "Memnuniyet"),
    "lead_meet": ("Meeting · {time}", "Görüşme · {time}"),
    "b2c_note": ("Consumer revenue counts in MRR. Accounts and leads come with a B2B product.",
                 "Kitleden gelen gelir MRR'da sayılır. Hesaplar ve adaylar B2B ürünle gelir."),
    "tab_locked": ("Opens in the Series A Hunt", "Series A Avı'nda açılır"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if common.LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ dates (GameState.get_date_dict: day 1 = Thu 1 Jan 2026, a tick = 7 days)
MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
MON_AB_TR = ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]
MON_AB_EN = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]


def _d(week):
    return datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))


def mon_ab(week):
    return L(MON_AB_TR, MON_AB_EN)[_d(week).month - 1]


def date(week):
    d = _d(week)
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    return L("Hafta %d · %s %d", "Week %d · %s %d") % (w, L(MON_TR, MON_EN)[d.month - 1], d.year)


def date_c(week):
    return L("H%d · %s", "W%d · %s") % (week, mon_ab(week))


def tx_date(week):
    return L("H%d · %s %d", "W%d · %s %d") % (week, mon_ab(week), _d(week).year)   # FIN_TX_DATE


# ------------------------------------------------------------------ money readouts and their colour rule
# Rule 2 + kabuk (ustbar__runway_ay, ustbar__runway_kirmizi, ustbar__kepenk): runway is red only under 3 months
# (RUNWAY_ALERT_MONTHS[0], the Finans badge's own threshold); a negative NET is ink while cash is above zero and
# red only under KEPENK; negative cash is red.
def runway_v(months):
    """months: int, "profitable" or ("shutter", weeks). Returns (key, value text, class)."""
    if months == "profitable":
        return "Runway", T("profitable"), "pos"
    if isinstance(months, tuple):
        return s("shutter_k"), L("%d hafta", "%d weeks") % months[1], "neg"
    return "Runway", L("%d ay", "%d mo") % months, "neg" if months < 3 else ""


def net_cls(net, shutter=False):
    return "pos" if not net.startswith("−") else ("neg" if shutter else "")


# ------------------------------------------------------------------ top bar (system geometry, brand block = decision 14 option (a))
PHASES = {1: "Bootstrap", 2: "Traction", 3: "Series A"}


def topbar(v, compact=False, W=1920):
    """v: week, clock, phase, cash, net, run (see runway_v), mrr, burn, slot=(text, cls), marks, end (workday end hour)."""
    col, g, time_w = kit.tb_layout(compact)
    shutter = isinstance(v["run"], tuple)
    rk, rv, rc = runway_v(v["run"])
    nc = net_cls(v["net"], shutter)
    out = []
    if compact:
        out.append('<span class="brand-sq" style="left:22px;top:22px"></span>')
    else:
        # the phase is a proper name: caps in the EN locale, so "Series A" never takes the TR dotted İ (SERİES)
        out += ['<span class="brand-sq" style="left:20px;top:13px"></span>',
                at(48, 31, "t-subhead", s("brand"), "tb-co", width=g["brand"] - 48 - 12),
                at(48, 50, "t-micro", PHASES[v["phase"]], "tb-k").replace('<span class=', '<span lang="en" class=', 1)]
        for i in range(3):
            out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i < v["phase"] else "", 48 + kit.TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"),
            at(col["B"], b1, "t-hero", n(v["cash"]), "tb-hero neg" if v["cash"].startswith("−") else "tb-hero"),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", n(v["net"]) + '<span class="tb-u">%s</span>' % T("per_mo"),
               {"pos": "tb-d", "neg": "tb-d neg", "": "tb-v"}[nc]),
            at(col["C"], b1, "t-label", T("shutter_k") if shutter else T("runway"), "tb-k"),
            at(col["D"], b1, "t-value", rv, "tb-v " + rc),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", n(v["mrr"]), "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", "50", "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", n(v["burn"]) + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", "0", "tb-v")]
    gate_x = W - time_w - g["gate"]
    d0 = col["metrics_end"]
    pad = 16 if compact else 20
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + pad, 28, "t-body", date_c(v["week"]) if compact else date(v["week"]), "tb-date"))
    out.append(kit.week_bar(d0 + pad, min(gate_x - pad, d0 + pad + 720), now_h=v["clock"], marks=v.get("marks", ()), end=v.get("end", 17)))
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


def end_slot(clock, end=17):
    return (s("next_end", n=end - int(clock)), "")


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]


def rail(active, badges, icons=False):
    rows = []
    for key, name in RAIL:
        b = "lock" if key == "pazarlama" else badges.get(key)
        cls = "rr" + (" is-active" if key == active else "") + (" is-locked" if b == "lock" else "")
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), T("soon"))
            right = ('<span class="lk">%s</span>' % ic("lock", 12)) if icons else ""
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    return ('<nav class="rail%s">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", "".join(rows), ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ ticker (each seed's own order as the baseline shows it)
TICKER = {  # localization/strings.csv
    "TICKER_01": ("Tohum yatırımcıları takvim dolduruyor; erken aşamada trafik yoğun.", "Seed investors are booking out their calendars; early-stage traffic is heavy."),
    "TICKER_02": ("Kurumsal alım listeleri kısalıyor; alıcılar az ama kararlı.", "Enterprise shortlists are getting shorter; fewer buyers with firmer intent."),
    "TICKER_03": ("Genç girişimlerde kurucu maaşı tartışması yeniden alevlendi.", "The founder-salary debate flares up again among young startups."),
    "TICKER_04": ("Teknoloji kampüslerinde staj kontenjanları rekor kırdı.", "Internship quotas hit a record across tech campuses."),
    "TICKER_05": ("Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta.", "Discount season on server leases; infrastructure teams are negotiating."),
    "TICKER_06": ("Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi.", "Digital transformation tenders are queuing up in industrial zones."),
    "TICKER_07": ("Melek yatırım ağları yeni dönem başvurularını açtı.", "Angel networks open applications for the new season."),
    "TICKER_08": ("Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu.", "Software exporters hunt for new markets; the trade-fair calendar is full."),
    "TICKER_09": ("Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu.", "Office downsizing continues; shared floors are full."),
    "TICKER_10": ("Teknoloji basınında değerleme sohbeti hiç bitmiyor.", "Valuation chatter never stops in the tech press."),
}
PUB = {"sektor": "Sektör Telgrafı", "ekonomi": "Ekonomi Postası", "teknogundem": "TeknoGündem", "girisim": "Girişim Bülteni"}
NEWS_THEME = [("sektor", "TICKER_04"), ("ekonomi", "TICKER_05"), ("teknogundem", "TICKER_06"), ("girisim", "TICKER_07")]
NEWS_FIN = [("sektor", "TICKER_08"), ("ekonomi", "TICKER_09"), ("teknogundem", "TICKER_10"), ("ekonomi", "TICKER_01")]
NEWS_VC = [("teknogundem", "TICKER_02"), ("girisim", "TICKER_03"), ("sektor", "TICKER_04"), ("ekonomi", "TICKER_05")]


def ticker(items):
    out = []
    for i, (k, key) in enumerate(items):
        if i:
            out.append('<span class="tk-sep">   ·   </span>')
        out.append('<span class="tk-pub %s">%s</span><span class="tk-hl">%s</span>' % (k, PUB[k], L(*TICKER[key])))
    return '<footer class="ticker"><div class="tk-toggle">%s</div><div class="tk-run">%s</div></footer>' % (ic("news"), "".join(out))


# ------------------------------------------------------------------ office layer (kabuk office(): noicons plate + A2 head sprites)
PLATES = {
    1920: ("art/office_safe_1920_noicons.png", "art/office_safe_1920_heads.json", 1736, 976, (184, 64, 1736, 976)),
    1536: ("art/office_safe_1536_noicons.png", "art/office_safe_1536_heads.json", 1352, 760, (64, 64, 1472, 760)),
}
HEAD_FILE = {"plan": "research", "research": "research", "test": "test", "design": "design", "phone": "phone", "code": "code",
             "coffee": "coffee", "wc": "wc", "visit": "meeting", "meeting": "meeting", "food": "food"}


def office(W, dim=True):
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
    return '<div class="office-layer"%s>%s</div>' % (' style="filter:brightness(var(--dim))"' if dim else "", "".join(out))


# ------------------------------------------------------------------ office floats (kabuk buildhud("seed"), notices(), move_btn(); hidden when a window overlaps them)
def buildhud(x, y, name):
    return ('<div class="float bh abs" style="left:%dpx;top:%dpx"><div class="bh-hd">%s<span class="t">%s v1</span></div>'
            '<div class="bh-rw">%s<span class="k t-label">%s</span><span class="v">%s</span></div>'
            '<div class="bh-act"><span class="btn btn-ghost btn-sm is-disabled">%s%s</span><span class="why">%s</span></div></div>'
            % (x, y, ic("urun", 20, "var(--ink-3)"), name, ic("shield", 16, "var(--ink-3)"), T("support"), s("confirmed", n=0),
               ic("play", 12), L("Düzeltme başlat", "Start a fix run"), s("no_bugs")))   # PROD_FIX_RUN_START


# The stack is the inbox preview (kabuk stack_row): sender · subject · time left. A paper's time is ink-3 (warn in its
# last week); a term sheet reminder reads like its slot: warn dot and time, red in the final week.
def mail(sender, subject, dot="", weeks=None, kind="paper"):
    return dict(sender=sender, subject=subject, dot=dot, weeks=weeks, kind=kind)


NORDICA = mail("Nordica", ("Bir ekip daha", "One more team"), weeks=2)                                   # customer.expansion paper
EGE = mail("Ege Sigorta", ("Risk altında", "At risk"), "is-risk", kind="reminder")                       # SALES_CHIP_RISK
SELIN = mail("Selin Kaya", ("Ayrılabilir", "At risk of leaving"), "is-risk", kind="reminder")            # HR risk state
INBOX_THEME = [NORDICA, EGE, SELIN]   # kabuk SEED_INBOX, H14 11:00
INBOX_WORLD = [NORDICA, EGE]          # sales world: nobody on the roster at risk (no Ekip badge in the baseline)
INBOX_VC = [mail("Anchor Capital", ("Teklif", "Offer"), weeks=2, kind="sheet"), mail("Meridian Growth", ("Teklif", "Offer"), weeks=3, kind="sheet")]


def notices(inbox):
    cards = []
    for m in inbox:
        w = m["weeks"]
        time = "" if w is None else (L("bu hafta", "this week") if w == 1 else L("%d hafta", "%d weeks") % w)   # DESK_PAPER_*
        if m["kind"] == "sheet":
            dot, tcls = ("is-risk", "is-neg") if w == 1 else ("is-warn", "is-warn")
        else:
            dot, tcls = m["dot"], ("is-warn" if w == 1 else "")
        wk = '<span class="nwk %s">%s</span>' % (tcls, time) if time else ""
        cards.append('<div class="float notice"><span class="dt %s"></span><span class="co">%s</span><span class="tx">%s</span>%s</div>'
                     % (dot, m["sender"], L(*m["subject"]), wk))
    return ('<div class="abs" style="right:24px;bottom:64px;width:352px;display:flex;flex-direction:column;gap:8px">%s</div>'
            % "".join(cards)) if cards else ""


def move_btn(x, y):
    return '<div class="float fbtn" style="left:%dpx;top:%dpx">%s%s</div>' % (x, y, ic("move"), T("move_office"))


def floats(company=None, items=()):
    """1920 only: BuildHUD at (W-344, 88) when a product is live, the notice stack, Ofisi taşı at (rail+24, H-108)."""
    return (buildhud(1576, 88, company) if company else "") + notices(items) + move_btn(208, 972)


# per-seed shell state, kabuk's (B14, SEED_INBOX): one source for every group drawing the theme seed
B_THEME = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


# ------------------------------------------------------------------ page and screen
PICKER_JS = ('<script>document.fonts.ready.then(function(){var b=document.querySelector("[data-anchor]"),m=document.querySelector(".menu.picker");'
             'if(!b||!m)return;var r=b.getBoundingClientRect();m.style.left=Math.round(r.left)+"px";m.style.top=Math.round(r.bottom+4)+"px";});</script>')


def page(body, w1536=False, cb=False, js=""):
    return ('<!doctype html><html lang="%s"%s><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../satis_finans.css"></head><body%s>%s%s</body></html>'
            % (common.LANG, ' class="w1536"' if w1536 else "", L("Satış ve Finans", "Sales and Finance"), common.FONTS, REL, REL,
               ' class="cb"' if cb else "", body, js))


def screen(top, rail_html, window, fl="", news=NEWS_THEME, w=1920, overlay=""):
    return '<div class="screen">%s%s%s%s%s%s%s</div>' % (office(w), fl, window, top, rail_html, ticker(news), overlay)


def window(x, y, w, h, title, kpis, ctl, body):
    """h: an int fixes the height (a body that scrolls); ("fit", cap) lets it follow the content up to cap (SPEC §9)."""
    k = "".join('<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi %s">%s</span></div>' % (a, c, v)
                for a, v, c in kpis)
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><div class="win-kpis">%s</div><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (title, k, ic("close")))
    size = ("height:%dpx" % h) if isinstance(h, int) else ("height:auto;max-height:%dpx" % h[1])
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;%s">%s%s<div class="win-body">%s</div></section>'
            % (x, y, w, size, head, ctl or "", body))


def scrollbar(top, height, thumb_top, thumb_h, right=0):
    return ('<div class="sb" style="right:%dpx;top:%dpx;height:%dpx"><div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>'
            % (right, top, height, thumb_top, thumb_h))


# ================================================================== SATIŞ
def stance_ctl(current="standard"):
    names = [("competitive", L("Rekabetçi", "Competitive")), ("standard", L("Standart", "Standard")), ("premium", "Premium")]
    hints = {"competitive": L("Koltuk fiyatı bandın altında. Masa kolay açılır.", "Seat price sits low in the band. Tables open easily."),
             "standard": L("Koltuk fiyatı bandın ortasında.", "Seat price sits mid band."),
             "premium": L("Koltuk fiyatı bandın üstünde. Temsilcinin işlemesi uzar.", "Seat price sits high in the band. A rep takes longer to work it.")}
    pick = "".join('<span class="%s">%s</span>' % ("is-on" if k == current else "", t) for k, t in names)
    return ('<div class="win-ctl"><span class="lbl t-label">%s</span><span class="segpick">%s</span>'
            '<span class="hint t-caption">%s</span></div>' % (L("Fiyat duruşu", "Price stance"), pick, hints[current]))


# SALES_ARCH_*_LINE: still "PH:" placeholders in the CSV; the prefix is stripped here and INDEX.md flags them
LINE = {"ops": ("Ölçülü bir alıcı. Önce kararlılığı sorar.", "A measured buyer. Stability comes first."),
        "fin": ("Hızlı konuşur, rakama erken gelir.", "Talks fast, gets to the number early."),
        "tech": ("Teknik taraf soruyor. Merdivenin nerede bittiğini bilmek ister.", "The technical side is asking. They want to know where the ladder ends.")}


def lead(name, star, weeks, line, work=None, meeting=None):
    w = '<span class="w">%s%s</span>' % (ic("clock"), L("%d hafta", "%d week") % weeks)   # SALES_DAYS_LEFT_ONE
    extra = ""
    if work:   # SALES_REP_WORKING
        extra = '<div class="work">%s<b>%s</b> · %s</div>' % (ic("clock", 14), work[0], L("%s ile görüşüyor · %d. hafta", "Working %s · week %d") % (name, work[1]))
    if meeting:
        extra = '<div class="work meet">%s%s</div>' % (ic("calendar", 14), s("lead_meet", time=meeting))
    meet_btn = "" if meeting else '<span class="btn btn-secondary btn-sm">%s%s</span>' % (ic("arrow", 16), L("Görüşmeye git", "Go to the meeting"))
    acts = ('<div class="acts"><span class="btn btn-secondary btn-sm">%s</span><span class="btn btn-secondary btn-sm">%s</span>%s</div>'
            % (L("Ayır", "Reserve"), L("Temsilciye ver", "Give to a rep"), meet_btn))
    return ('<div class="deal"><div class="deal-top"><span class="t">%s</span>%s%s</div><div class="line">%s</div>%s%s</div>'
            % (name, stars(star), w, L(*LINE[line]), extra, acts))


def sat(v):
    c = "lo" if v < 35 else "mid" if v < 50 else "hi"
    return '<div class="sat %s"><span class="sat-v">%d</span><div class="sat-t"><div class="sat-f" style="width:%d%%"></div></div></div>' % (c, v, v)


def acct_meta(mrr, seats, months):
    ten = L("%d aydır müşteri", "customer for %d mo") % months if months else L("yeni müşteri", "new customer")
    return "%s%s · %s · %s" % (n(mrr), L("/ay", "/mo"), L("%d koltuk", "%d seats") % seats, ten)


def account(name, kind, meta, satv, steward=None, line=None, churn=None, action=None, delegated=False, armed=False):
    tagh = {"risk": tag(L("Risk altında", "At risk"), "risk"), "grow": tag(L("Büyümek istiyor", "Wants to grow"), "pos"),
            "ok": tag(L("Sağlıklı", "Healthy"), "outline"), "new": tag(L("Yeni", "New"), "neutral")}[kind]
    ln = '<div class="line"><i>%s</i></div>' % line if line else ""
    ch = ""
    if churn:   # SALES_CHURN_COUNTDOWN
        ch = '<span class="churn">%s<span class="pips">%s</span></span>' % (L("Churn'e ~%d hafta", "~%d weeks to churn") % churn, '<i class="on"></i>' * churn)
    act = '<span class="btn btn-secondary btn-sm act">%s%s</span>' % (ic("mail_open", 16), action) if action else ""
    cls = "deal acct" + (" is-risk" if kind == "risk" else "") + (" is-delegated" if delegated else "")
    change = ('<span class="btn btn-secondary btn-sm%s"%s>%s</span>'
              % (" is-pressed" if armed else "", ' data-anchor="1"' if armed else "", L("Değiştir", "Change")))
    return ('<div class="%s"><div class="deal-top"><span class="t">%s</span>%s%s</div><div class="line">%s</div>%s'
            '<div class="acct-sat"><span class="k t-label">%s</span>%s%s</div>'
            '<div class="acct-foot"><span class="stew">%s<b>%s</b></span>%s%s</div></div>'
            % (cls, name, stars(3), tagh, meta, ln, s("acct_sat"), sat(satv), ch,
               L("Müşteri temsilcisi: ", "Account manager: "), steward or L("Kurucu", "Founder"), change, act))


def desk(rep_name, rep_av, star, band_opts, working=None):
    pick = "".join('<span class="%s">%s</span>' % ("is-on" if o == "own" else "", L("Kendi ligi", "Own league") if o == "own" else ("%d%s" % (o, ic("star"))))
                   for o in band_opts)
    sub = ('<span class="r work">%s%s</span>' % (ic("clock"), L("<b>%s</b> ile görüşüyor · %d. hafta", "Working <b>%s</b> · week %d") % working)) if working \
        else '<span class="r">%s</span>' % L("Satış Temsilcisi", "Sales Representative")
    return ('<div class="rep"><div class="rep-top">%s<div class="who"><span class="n">%s %s</span>%s</div></div>'
            '<div class="rep-band"><span class="k t-caption">%s</span><span class="segpick">%s</span></div></div>'
            % (rep_av, rep_name, stars(star), sub, L("Çalıştığı bant:", "Working band:"), pick))


def lane(title, meta, inner):
    m = ('<span class="n">%s</span>' % meta) if meta else ""
    return '<div class="lane"><div class="lane-h t-label">%s%s</div>%s</div>' % (title, m, inner)


def placeholder_av(size):
    return '<span class="av av-%d is-loading">%s</span>' % (size, ic("head"))


def sales_kpis(world):
    if world:
        return [(L("Müşteri", "Customers"), "5", ""), (L("Ort. memnuniyet", "Avg. satisfaction"), n("%63"), ""),
                (L("Bu ay kazanılan", "Gained this month"), "+1", "pos"), (L("Bu ay net", "Net this month"), "−1", "neg")]
    return [(L("Müşteri", "Customers"), "3", ""), (L("Ort. memnuniyet", "Avg. satisfaction"), n("%56"), ""),
            (L("Bu ay kazanılan", "Gained this month"), "0", "dim"), (L("Bu ay net", "Net this month"), "0", "dim")]


def flow_rate():
    return L("Akış: %s/hafta", "Flow: %s/week") % n("6,5")   # SALES_FLOW_RATE


# theme seed (data/screens.md, kabuk SEED): week 14, 11:00, the 14:00 meeting with Karadeniz Fabrika is the slot's next item
TOP_THEME = dict(week=14, clock=11, phase=1, cash="$10.000", net="+$2,5K", run="profitable", mrr="$4,0K", burn="$1,5K", marks=(14,))
TOP_WORLD = dict(week=14, clock=8, phase=1, cash="$48.000", net="+$4,7K", run="profitable", mrr="$6,2K", burn="$1,5K")


def theme_slot():
    return (s("next_meet", time="14:00", company="Karadeniz Fabrika"), "")


def satis_theme_body():
    left = (lane(L("Boru hattı", "Pipeline"), flow_rate(),
                 lead("Karadeniz Fabrika", 2, 1, "ops", meeting="14:00")
                 + lead("Efes Emlak", 1, 1, "fin"))
            + lane(L("Satış masası", "Sales desk"), "", desk("Burak Şahin", common.avatar(BUST["burak"], 40), 3, [1, 2, 3, "own"])))
    right = lane(L("Müşteri portföyü", "Customer portfolio"), L("%d müşteri", "%d customers") % 3,
                 account("Ege Sigorta", "risk", acct_meta("$1,0K", 12, 2), 25,
                         line=L("Sebep: sık kesinti şikayeti", "Reason: frequent outage complaints"), action=L("İlgilen", "Check in"))
                 + account("Nordica", "grow", acct_meta("$2,0K", 20, 6), 72,
                           line=L("Başka departmana yaymak istiyor.", "Wants to roll it out to another department."), action=L("Değerlendir", "Evaluate"))
                 + account("Kuzey İnşaat", "ok", acct_meta("$1,0K", 12, 3), 72))
    return '<div class="cols"><div class="col" style="width:584px">%s</div><div class="col" style="flex:1">%s</div></div>' % (left, right)


def f_satis_boru_hatti():
    win = window(208, 88, 1280, ("fit", 760), L("Satış", "Sales"), sales_kpis(False), stance_ctl(), satis_theme_body())
    top = topbar(dict(TOP_THEME, slot=theme_slot()))
    fl = floats("Unicorn Inc.", INBOX_THEME)
    return page(screen(top, rail("satis", B_THEME), win, fl))


def satis_world_body():
    left = (lane(L("Boru hattı", "Pipeline"), flow_rate(),
                 lead("Adria Kargo", 3, 1, "ops")
                 + lead("Karadeniz Emlak", 2, 1, "fin", work=("Kerem Aydın", 1))
                 + lead("Efes Yatırım", 1, 1, "tech"))
            + lane(L("Satış masası", "Sales desk"), "", desk("Kerem Aydın", placeholder_av(40), 2.5, [1, 2, "own"], working=("Karadeniz Emlak", 1))))
    return left


def satis_world_cards(picker):
    return (account("Ege Sigorta", "risk", acct_meta("$1,0K", 12, 2), 25,
                    line=L("Sebep: sık kesinti şikayeti", "Reason: frequent outage complaints"), churn=2, action=L("İlgilen", "Check in"), armed=picker)
            + account("Nordica", "grow", acct_meta("$2,0K", 20, 6), 72,
                      line=L("Başka departmana yaymak istiyor.", "Wants to roll it out to another department."), action=L("Değerlendir", "Evaluate"))
            + account("Kuzey İnşaat", "ok", acct_meta("$1,0K", 12, 3), 72)
            + account("Palmiye Holding", "ok", acct_meta("$1,5K", 16, 4), 72, "Burcu Çetin", delegated=True)
            + account("Aras Klinik", "new", acct_meta("$700", 6, 0), 72))


def picker_width():
    """SPEC §3.4: the menu fits the worst TR and EN row (Godot slack) beside the load readout, never by eye."""
    rows = [("Burcu Çetin", None, "1/9"), (("Kurucu (kendim tutayım)", "Founder (keep it myself)"), ("zaten sorumlu", "already assigned"), "4/4")]
    items = []
    for i, (nm, why, ld) in enumerate(rows):
        for j, lg in enumerate(("tr", "en")):
            items.append(("n%d%s" % (i, lg), "t-data", nm if isinstance(nm, str) else nm[j], lg))
            items.append(("l%d%s" % (i, lg), "t-caption", ld, lg))
            if why:
                items.append(("w%d%s" % (i, lg), "t-caption", why[j], lg))
    m = measure.measure(items)
    g = lambda k: measure.godot(m[k])
    best = 0
    for i in range(2):
        for lg in ("tr", "en"):
            # menu padding 4+4, item padding 8+8, borders 2; flex gap 8 + the reason's 12 on each side of the reason
            why = (8 + 12 + g("w%d%s" % (i, lg)) + 8 + 12) if ("w%d%s" % (i, lg)) in m else 32
            best = max(best, 4 + 4 + 8 + 8 + 2 + g("n%d%s" % (i, lg)) + why + 48 + 8 + g("l%d%s" % (i, lg)))
    return -(-best // 8) * 8


def picker_menu():
    return ('<div class="menu picker" style="left:0;top:0;width:%dpx"><div class="menu-head t-micro">%s</div>'
            '<div class="menu-item is-hover">Burcu Çetin<span class="load"><span class="lt"><span class="lf" style="width:11%%"></span></span>1/9</span></div>'
            '<div class="menu-sep"></div>'
            '<div class="menu-item is-disabled">%s<span class="why">%s</span><span class="load is-full"><span class="lt"><span class="lf" style="width:100%%"></span></span>4/4</span></div>'
            '</div>' % (picker_width(), L("Sorumlu ata", "Assign account manager"), L("Kurucu (kendim tutayım)", "Founder (keep it myself)"),
                        L("zaten sorumlu", "already assigned")))


def f_satis_masa_portfoy(picker=False, cb=False):
    body = ('<div class="cols"><div class="col" style="width:584px">%s</div><div class="col scroll" style="flex:1">%s%s</div></div>'
            % (satis_world_body(), lane(L("Müşteri portföyü", "Customer portfolio"), L("%d müşteri", "%d customers") % 5, satis_world_cards(picker)),
               scrollbar(36, 556, 0, 316)))
    win = window(208, 88, 1280, 760, L("Satış", "Sales"), sales_kpis(True), stance_ctl(), body)
    top = topbar(dict(TOP_WORLD, slot=end_slot(8)))
    fl = floats("Unicorn Inc.", INBOX_WORLD)
    return page(screen(top, rail("satis", {"satis": ("danger", "1")}), win, fl, overlay=picker_menu() if picker else ""),
                cb=cb, js=PICKER_JS if picker else "")


def f_satis_b2c():
    """One B2C state: the reason (SALES_LOCKED_NO_B2B) and where consumer revenue shows; no B2B strip to report."""
    body = ('<div class="b2c empty">%s<span class="empty-t"><b>%s</b>%s</span></div>'
            % (ic("satis"), L("Canlı B2B ürün yok.", "No live B2B product."), s("b2c_note")))
    win = window(208, 88, 1280, ("fit", 760), L("Satış", "Sales"), [], "", body)
    top = topbar(dict(TOP_WORLD, slot=end_slot(8)))
    return page(screen(top, rail("satis", {}), win, floats("Unicorn Inc.")))


def f_satis_1536():
    win = window(88, 88, 1280, ("fit", 712), L("Satış", "Sales"), sales_kpis(False), stance_ctl(), satis_theme_body())
    top = topbar(dict(TOP_THEME, slot=theme_slot()), compact=True, W=1536)
    return page(screen(top, rail("satis", B_THEME, icons=True), win, "", w=1536), w1536=True)


# ================================================================== FİNANS · ÖZET
def money_k(v):
    return ("$%dK" % (v // 1000)) if v != 0 else "$0"


def nice_step(span):
    for st in (5000, 10000, 20000, 25000, 50000, 100000):
        if span / st <= 6:
            return st
    return 100000


RANGE_WEEKS, HORIZON = 26, 9   # finance_ozet_view.gd RANGES["6ay"]: window 26, horizon 9


def cash_chart(hist, today, cash_now, cur_wk, opt_wk, w=544, h=216, hover=None):
    """hist: [(week, cash)]. cur_wk/opt_wk: net per tick. The domain follows the range, today - 26 weeks to the
    projection horizon, so every 6 AY chart has one scale; weeks before the run (or before the seed wrote cash) are
    an empty past. The second projection is drawn only when it reads apart from the first (>= 2 px at the horizon)."""
    pad_l, pad_r, pad_t, pad_b = 52, 12, 22, 26
    d0, d1 = today - RANGE_WEEKS, today + HORIZON
    hist = [(d, c) for d, c in hist if d >= d0]
    end_cur = cash_now + cur_wk * HORIZON
    end_opt = cash_now + opt_wk * HORIZON
    show_cur = cur_wk < 0   # Artıda: no melt line
    vals = [c for _, c in hist] + ([end_cur] if show_cur else []) + [end_opt]
    lo, hi = min([0] + vals), max([1] + vals)
    st = nice_step(hi - lo)
    ylo = (lo // st) * st if lo < 0 else 0
    yhi = -(-hi * 1.08 // st) * st
    X = lambda d: pad_l + (d - d0) / float(d1 - d0) * (w - pad_l - pad_r)
    Y = lambda c: pad_t + (yhi - c) / float(yhi - ylo) * (h - pad_t - pad_b)
    show_opt = not show_cur or abs(Y(end_cur) - Y(end_opt)) >= 2
    g = []
    v = ylo
    while v <= yhi + 1:
        g.append('<line class="%s" x1="%d" x2="%d" y1="%.1f" y2="%.1f"/>' % ("ch-axis" if v == 0 else "ch-grid", pad_l, w - pad_r, Y(v), Y(v)))
        lbl = ("−$%dK" % (-v // 1000)) if v < 0 else money_k(v)
        g.append('<text class="ch-lbl" x="%d" y="%.1f" text-anchor="end">%s</text>' % (pad_l - 10, Y(v) + 4, lbl))
        v += st
    for d in range(d0 + 1, d1 + 1):
        if _d(d).month != _d(d - 1).month:
            g.append('<line class="ch-axis" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (X(d), X(d), h - pad_b, h - pad_b + 4))
            g.append('<text class="ch-lbl" x="%.1f" y="%d" text-anchor="middle">%s</text>' % (X(d), h - 6, mon_ab(d)))
    pts = [(X(d), Y(c)) for d, c in hist]
    line = " ".join("%.1f,%.1f" % p for p in pts)
    if len(pts) > 1:
        g.append('<polygon class="ch-pos" points="%.1f,%.1f %s %.1f,%.1f"/>' % (pts[0][0], Y(max(0, ylo)), line, pts[-1][0], Y(max(0, ylo))))
    zero_x = None
    series = list(hist) + ([(d1, end_cur)] if show_cur else [])
    for (da, ca), (db, cb) in zip(series, series[1:]):
        if ca >= 0 > cb:
            zero_x = da + (db - da) * ca / float(ca - cb)
    if lo < 0:
        neg = []
        for (da, ca), (db, cb) in zip(series, series[1:]):
            if cb < 0:
                xa = da if ca < 0 else da + (db - da) * ca / float(ca - cb)
                neg.append((xa, db, max(ca, 0) if ca >= 0 else ca, cb))
        if neg:
            poly = ["%.1f,%.1f" % (X(neg[0][0]), Y(0))]
            for xa, db, ca, cb in neg:
                poly.append("%.1f,%.1f" % (X(xa), Y(min(ca, 0))))
                poly.append("%.1f,%.1f" % (X(db), Y(cb)))
            poly.append("%.1f,%.1f" % (X(neg[-1][1]), Y(0)))
            g.append('<polygon class="ch-neg" points="%s"/>' % " ".join(poly))
    if len(pts) > 1:
        g.append('<polyline class="ch-line" points="%s"/>' % line)
    tx, ty = X(today), Y(cash_now)
    if show_cur:
        g.append('<line class="ch-proj cur" x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f"/>' % (tx, ty, X(d1), Y(end_cur)))
    if show_opt:
        g.append('<line class="ch-proj2" x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f"/>' % (tx, ty, X(d1), Y(end_opt)))
    g.append('<line class="ch-now" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (tx, tx, pad_t - 4, h - pad_b))
    anchor = "start" if tx < w * 0.5 else "end"
    if zero_x is not None:
        zx = X(zero_x)
        wk = int(-(-zero_x // 1))
        za = "start" if zx > tx else "end"          # the zero label points away from today
        if za == "start" and zx + 6 + 104 > w - pad_r:
            za = "end"                              # no room on the right: it turns back toward today
        if za == "end" and zx > tx:
            anchor = "start" if (zx - 116) > (tx + 84) else "end"
        else:
            anchor = "end" if zx > tx else "start"
        g.append('<line class="ch-zero-mark" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (zx, zx, pad_t - 4, h - pad_b))
        g.append('<text class="ch-lbl neg" x="%.1f" y="%d" text-anchor="%s">%s</text>' % (zx + (6 if za == "start" else -6), pad_t - 8, za, s("zero", n=wk)))
    g.append('<text class="ch-lbl ink" x="%.1f" y="%d" text-anchor="%s">%s</text>' % (tx + (6 if anchor == "start" else -6), pad_t - 8, anchor, s("today", n=today)))
    tip = ""
    if hover:
        hd, hc, hc_txt, net, run = hover
        hx, hy = X(hd), Y(hc)
        g.append('<line class="ch-hover" x1="%.1f" x2="%.1f" y1="%d" y2="%d"/>' % (hx, hx, pad_t, h - pad_b))
        g.append('<circle class="ch-dot" cx="%.1f" cy="%.1f" r="5"/>' % (hx, hy))
        tw = 216
        tl = hx + 14 if hx + 14 + tw <= w else hx - 14 - tw   # the tip turns back when it would leave the card
        tip = ('<div class="tip rich" style="left:%dpx;top:%dpx;width:%dpx"><span class="tip-t">%s</span>'
               '<span class="tip-b" style="color:var(--ink-2)">%s</span><span class="tip-b">%s</span></div>'
               % (tl, hy + 40, tw, date(hd), s("tip_cash", amount=n(hc_txt)), s("tip_flow", net=n(net), runway=run)))
    g.append('<circle class="ch-today" cx="%.1f" cy="%.1f" r="5"/>' % (tx, ty))
    svg = '<svg width="%d" height="%d">%s</svg>' % (w, h, "".join(g))
    return '<div class="chart" style="position:relative;width:%dpx;height:%dpx">%s%s</div>' % (w, h, svg, tip), lo < 0, show_cur, show_opt


def chart_card(hist, today, cash_now, cur_wk, opt_wk, notes=(), hover=None, h=216):
    ch, below, show_cur, show_opt = cash_chart(hist, today, cash_now, cur_wk, opt_wk, hover=hover, h=h)
    leg = ['<span><i></i>%s</span>' % L("Gerçekleşen nakit", "Actual cash")]
    if show_cur:
        leg.append('<span><i class="proj"></i>%s</span>' % L("Projeksiyon · mevcut gidiş", "Projection · current course"))
    if show_opt:
        leg.append('<span><i class="proj2"></i>%s</span>' % L("Projeksiyon · satış hedefi tutarsa", "Projection · if the sales target holds"))
    if below:
        leg.append('<span><i class="neg"></i>%s</span>' % s("below"))
    nl = "".join('<div class="note-line t-caption">%s</div>' % x for x in notes)
    head = ('<div class="chart-h"><div>%s</div><span class="segpick sm"><span class="is-on">%s</span><span>%s</span><span>%s</span></span></div>'
            % (nl, L("6 ay", "6 mo"), L("12 ay", "12 mo"), L("Tümü", "All")))
    return ('<div class="card" style="padding:12px 20px 16px">%s<div style="margin-top:8px">%s</div><div class="chart-legend ch-legend t-caption">%s</div></div>'
            % (head, ch, "".join(leg)))


def tx_card(rows):
    if rows:
        body = "".join('<div class="txn"><span class="d">%s</span><span class="l">%s</span><span class="a%s">%s%s</span></div>'
                       % (d, l, " pos" if a.startswith("+") else "", "" if a.startswith("+") else ic("cost", 14), n(a)) for d, l, a in rows)
    else:
        body = '<div class="empty-row t-meta">%s%s</div>' % (ic("doc"), L("Henüz işlem yok", "No transactions yet"))
    return '<div class="card"><div class="card-h t-label">%s</div><div class="card-b">%s</div></div>' % (L("Son işlemler", "Recent transactions"), body)


APPETITE = {"closed": (("Kapalı", "Closed"), "outline"), "warming": (("Isınıyor", "Warming"), "warn"), "open": (("Açık", "Open"), "pos")}
APP_LINE = {"too_early": ("Series A henüz masada değil", "Series A is not on the table yet"),
            "below_bar": ("Gelir henüz çıtanın altında", "Revenue is still under the bar")}


def goal_card(phase, met=3, appetite=("closed", "too_early")):
    """Phase 2 carries the title only, as finance_ozet_view.gd _refresh_goal does: the gate's gauge is the appetite
    readout under it, and the revenue bar's figure is never printed."""
    (chip_t, kind) = APPETITE[appetite[0]]
    app = ('<div class="appetite%s"><div class="appetite-r"><span class="k t-label">%s</span>%s</div><div class="l t-caption">%s</div></div>'
           % (" lead" if phase == 2 else "", L("Yatırımcı iştahı", "Investor appetite"), tag(L(*chip_t), kind), L(*APP_LINE[appetite[1]])))
    if phase == 1:
        return ('<div class="card goal-card"><div class="card-h t-label"><span class="ph">%s</span><span class="m ink">%d/3</span></div>'
                '<div class="goal-v t-body">%s</div>'
                '<div class="prog%s"><div class="prog-t"><div class="prog-f" style="width:%d%%"></div></div></div>%s</div>'
                % (L("Traction'a", "To Traction"), met, L("Sürüm + ilk müşteri + ilk gelir", "Ship + first customer + first revenue"),
                   " is-done" if met == 3 else "", met * 100 // 3, app))
    return '<div class="card goal-card"><div class="card-h t-label"><span class="ph">%s</span></div>%s</div>' % (L("Series A'ya", "To Series A"), app)


def flow_card(inc, exp, net, inc_w, net_w, shutter=False):
    """Income is a gain (green); expense and a negative net are costs: ink with the cost glyph (rule 2), red only under KEPENK."""
    nneg = net.startswith("−")
    ncls = "neg" if (nneg and shutter) else ("pos" if not nneg else "")
    cost = lambda v: '<span class="v cst">%s%s</span>' % (ic("cost", 14), n(v))
    netv = cost(net) if (nneg and not shutter) else '<span class="v %s">%s</span>' % (ncls, n(net))
    return ('<div class="card"><div class="card-h t-label">%s<span class="cap">%s</span></div><div class="card-b share flow">'
            '<span class="k">%s</span><span class="t"><span class="pos" style="width:%s%%"></span></span><span class="v%s">%s</span>'
            '<span class="k">%s</span><span class="t"><span style="width:100%%"></span></span>%s'
            '<span class="k">%s</span><span class="t"><span class="%s" style="width:%s%%"></span></span>%s'
            '</div></div>' % (L("Aylık akış", "Monthly flow"), s("flow_pace"),
                              L("Gelir", "Income"), inc_w, "" if inc == "$0" else " pos", n(inc),
                              L("Gider", "Expense"), cost(exp),
                              L("Net", "Net"), ncls, net_w, netv))


COST_NAMES = {"sal": ("Maaşlar", "Salaries"), "ot": ("Ek mesai", "Overtime"), "tools": ("Araçlar", "Tools")}


def cost_card(total, rows):
    bar = "".join('<span style="width:%d%%;background:var(--%s)"></span>' % (p, "bar-emph" if i == 0 else "bar-fill") for i, (_, _, p) in enumerate(rows))
    rs = "".join('<span class="k">%s</span><span class="t"><span class="%s" style="width:%d%%"></span></span><span class="a">%s</span><span class="v">%s</span>'
                 % (L(*COST_NAMES[k]), "emph" if i == 0 else "", p, n(a), n("%%%d" % p)) for i, (k, a, p) in enumerate(rows))
    return ('<div class="card"><div class="card-h t-label">%s<span class="m">%s</span></div>'
            '<div class="card-b"><div class="stackbar thin">%s</div><div class="share cost">%s</div></div></div>'
            % (L("Gider dağılımı", "Expense breakdown"), L("%s / ay", "%s / mo") % n(total), bar, rs))


def cap_card(founder=100):
    return ('<div class="card"><div class="card-h t-label">%s</div><div class="card-b">'
            '<div class="stackbar thin" style="margin-bottom:0"><span style="width:%d%%;background:var(--bar-emph)"></span></div>'
            '<div class="cap-row"><span>%s</span></div></div></div>'
            % (L("Hisse dağılımı", "Cap table"), founder, L("Kurucu · <b>%s</b>", "Founder · <b>%s</b>") % n("%%%d" % founder)))


def share_txt(v):
    return n("&lt;%0,1") if v < 0.1 else n("%%%s" % ("%.1f" % v).replace(".", ","))


def league_card(head, rows):
    """Rank, name, trend, share. No bars (Q20): the shares are ranked and labelled, so the name cell keeps its full
    width. A rule marks every jump in rank; your row is ink-1 with the SEN tag, not the selection grammar."""
    out = []
    prev = None
    for rank, name, share, trend, you in rows:
        if rank == "…":
            out.append('<div class="lg-row others"><span class="r">…</span><span class="n">%s</span><span></span><span class="v">%s</span></div>'
                       % (L("diğerleri", "others"), n(name)))
            continue
        if prev is not None and rank != prev + 1:
            out.append('<div class="lg-gap"></div>')
        prev = rank
        tr = ic("tri_up" if trend > 0 else "tri_down", 12, cls="tr") if trend else "<span></span>"
        nm = ('<span class="nm">%s</span>%s' % (name, tag(L("Sen", "You"), "neutral"))) if you else '<span class="nm">%s</span>' % name
        out.append('<div class="lg-row%s"><span class="r">%d</span><span class="n">%s</span>%s<span class="v">%s</span></div>'
                   % (" is-you" if you else "", rank, nm, tr, share_txt(share)))
    return ('<div class="card"><div class="card-h t-label">%s<span class="m ink">%s</span></div><div class="card-b lg">%s</div></div>'
            % (L("Pazar payı", "Market share"), n(head), "".join(out)))


LEAGUE_LOW = [(1, "FlowSuite", 34.0, 0, False), (2, "Prosedo", 16.4, 1, False), (3, "Operanda", 11.2, 1, False),
              (11, "Adımla", 0.5, 0, False), (12, "Unicorn Inc.", 0.05, 0, True), ("…", "%14,7", 0, 0, False)]
LEAGUE_OZET = [(1, "FlowSuite", 34.0, 0, False), (2, "Prosedo", 16.4, 1, False), (3, "Operanda", 11.2, 1, False),
               (11, "Adımla", 0.5, 0, False), (12, "Unicorn Inc.", 0.1, 0, True), ("…", "%14,6", 0, 0, False)]
LEAGUE_ARTIDA = [(1, "FlowSuite", 34.0, 0, False), (2, "Prosedo", 16.4, 1, False), (3, "Operanda", 11.2, 1, False),
                 (5, "Yalçın Teknoloji Holding", 5.3, 0, False), (6, "Unicorn Inc.", 4.0, 0, True), ("…", "%10,7", 0, 0, False)]
LEAGUE_SIGNAL = [(1, "FlowSuite", 34.0, 0, False), (2, "Prosedo", 16.4, 1, False), (3, "Operanda", 11.2, 1, False),
                 (5, "Yalçın Teknoloji Holding", 5.3, 0, False), (6, "Unicorn Inc.", 3.9, 0, True), ("…", "%10,8", 0, 0, False)]


def mentor_card(shutter=False):
    q = (L("Runway diye bir şey kalmadı. Sayaç işliyor; bugün ne kestiğin önemli.",
           "There's no runway left to speak of. The counter is running. What matters is what you cut today.") if shutter
         else L("Runway 6 ayın altında. Ya gideri kıs ya geliri bul; ikisi de karar ister.",
                "Runway is under 6 months. Cut what you spend or bring in more; either way it's a decision."))
    return ('<div class="fnote%s"><div class="card-h t-label">%s</div>'
            '<div class="fnote-who">%s<div><div class="n">Frank Köseoğlu</div><div class="r">Operating Partner</div></div></div>'
            '<div class="fnote-q">"%s"</div><div class="fnote-f"><span class="btn btn-ghost btn-sm">%s</span></div></div>'
            % (" is-danger" if shutter else "", L("Mentor uyarısı", "Mentor warning"), common.avatar(FRANK, 64), q, L("Ertele", "Snooze")))


def finans_ctl(active="ozet"):
    if active == "ozet":   # FIN_SUBTAB_LOCKED
        return ('<div class="win-ctl"><div class="seg"><span class="seg-tab t-tab is-active">%s</span><span class="seg-tab t-tab is-disabled">%s%s</span></div>'
                '<span class="seg-why t-caption">%s</span></div>' % (L("Özet", "Summary"), ic("lock", 16), L("Yatırım", "Funding"), s("tab_locked")))
    return ('<div class="win-ctl"><div class="seg"><span class="seg-tab t-tab">%s</span><span class="seg-tab t-tab is-active">%s</span></div></div>'
            % (L("Özet", "Summary"), L("Yatırım", "Funding")))


def fin_kpis(cash, net, run):
    shutter = isinstance(run, tuple)
    rk, rv, rc = runway_v(run)
    nc = net_cls(net, shutter)
    netv = ('<span class="cst">%s</span>%s' % (ic("cost", 20), n(net))) if nc == "" else n(net)
    return [(L("Nakit", "Cash"), n(cash), "neg" if cash.startswith("−") else ""), (L("Aylık net", "Monthly net"), netv, nc),
            (rk, rv, rc)]


def ozet_body(chart, txs, colB, colC):
    """Column C keeps Frank's note and the league; when it holds a single card, the cap table moves under it so
    no column ends in a void (the window then fits the tallest column)."""
    left = [chart, tx_card(txs)]
    if len(colC) > 1:
        left.append(cap_card())
    else:
        colC = list(colC) + [cap_card()]
    return ('<div class="cols"><div class="col" style="width:584px">%s</div><div class="col" style="width:320px">%s</div>'
            '<div class="col" style="width:360px">%s</div></div>' % ("".join(left), "".join(colB), "".join(colC)))


def fin_frame(top, kpis, body, rail_b, w1536=False, ctl=None, company="Unicorn Inc.", items=()):
    if w1536:
        win = window(88, 88, 1344, ("fit", 712), L("Finans", "Finance"), kpis, ctl or finans_ctl(), body)
        return page(screen(topbar(top, compact=True, W=1536), rail("finans", rail_b, icons=True), win, "", news=NEWS_FIN, w=1536), w1536=True)
    win = window(208, 88, 1344, ("fit", 720), L("Finans", "Finance"), kpis, ctl or finans_ctl(), body)
    return page(screen(topbar(top), rail("finans", rail_b), win, floats(company, items), news=NEWS_FIN))


TOP_FIN = dict(week=7, clock=8, phase=1, burn="$45,8K")
COST_STD = [("sal", "$43,6K", 95), ("tools", "$2,3K", 5)]

# The finance shot's six real weeks (main.gd _run_finance_shot), derived tick by tick from the rule
# cash += MRR×7/30 − burn×7 (burn 1.528/gün = maaşlar 1.453 + araçlar 75); the last point is the seed's own.
HIST_OZET = [(1, 300000), (2, 289304), (3, 278864), (4, 268424), (5, 257984), (6, 247731), (7, 237483)]
HIST_ARTIDA = [(1, 300000), (2, 289304), (3, 283275), (4, 281912), (5, 285216), (6, 288520), (7, 291824)]
HIST_UYARI = [(1, 150000), (2, 139304), (3, 128864), (4, 118424), (5, 107984), (6, 97544), (7, 87119)]
HIST_KEPENK = HIST_UYARI + [(8, 76689), (9, 66259), (10, 55829), (11, 45399), (12, 34969), (13, 24539), (14, 14109),
                            (15, 3679), (16, -6751), (17, -17181)]


def signal_hist():
    """Phase 2, derived (INDEX.md): MRR climbs from $1,1K (week 1) to $50,0K (week 10), then to $58,0K (week 30);
    burn 10.696/week. March to June close in the black (4/6 months), July is open; cash never dips below zero."""
    mrr = lambda w: round(1100 + (50000 - 1100) * (w - 1) / 9) if w <= 10 else round(50000 + 8000 * (w - 10) / 20)
    out, c = [(1, 300000)], 300000
    for w in range(1, 30):
        c += round(mrr(w) * 7 / 30) - 10696
        out.append((w + 1, c))
    return out


HIST_SIGNAL = signal_hist()   # week 30: $288.833


def f_finans_ozet(w1536=False):
    top = dict(TOP_FIN, cash="$237.483", net="−$44,0K", run=5, mrr="$1,9K", slot=end_slot(8))
    chart = chart_card(HIST_OZET, 7, 237483, -10255, -10078, hover=(4, 268424, "$268.424", "−$44,7K", L("6 ay", "6 mo")))
    body = ozet_body(chart, [], [goal_card(1), flow_card("+$1,9K", "−$45,8K", "−$44,0K", 4, 96), cost_card("$45,8K", COST_STD)],
                     [mentor_card(), league_card("%0,1", LEAGUE_OZET)])
    return fin_frame(top, fin_kpis("$237.483", "−$44,0K", 5), body, {"ekip": ("danger", "1")}, w1536)


def f_finans_artida():
    top = dict(TOP_FIN, cash="$291.824", net="+$14,2K", run="profitable", mrr="$60,0K", slot=end_slot(8))
    chart = chart_card(HIST_ARTIDA, 7, 291824, 3304, 3479,
                       notes=(L("Gider gelirin altında; kasa erimiyor. Sayaç, net akış eksiye dönerse işler.",
                                "Expenses run below revenue; the treasury holds. The clock starts only if net flow turns negative."),))
    body = ozet_body(chart, [], [goal_card(1), flow_card("+$60,0K", "−$45,8K", "+$14,2K", 100, 24), cost_card("$45,8K", COST_STD)],
                     [league_card("%4,0", LEAGUE_ARTIDA)])
    return fin_frame(top, fin_kpis("$291.824", "+$14,2K", "profitable"), body, {"ekip": ("danger", "1")})


def f_finans_uyari():
    top = dict(TOP_FIN, cash="$87.119", net="−$44,7K", run=2, mrr="$1,1K", slot=end_slot(8))
    chart = chart_card(HIST_UYARI, 7, 87119, -10430, -10264)
    body = ozet_body(chart, [], [goal_card(1), flow_card("+$1,1K", "−$45,8K", "−$44,7K", 2, 98), cost_card("$45,8K", COST_STD)],
                     [mentor_card(), league_card("&lt;%0,1", LEAGUE_LOW)])
    return fin_frame(top, fin_kpis("$87.119", "−$44,7K", 2), body, {"ekip": ("danger", "1"), "finans": ("danger", "1")})


def f_finans_kepenk():
    top = dict(TOP_FIN, week=17, cash="−$17.181", net="−$44,7K", run=("shutter", 3), mrr="$1,1K", slot=end_slot(8))
    chart = chart_card(HIST_KEPENK, 17, -17181, -10430, -10264)
    body = ozet_body(chart, [], [goal_card(1), flow_card("+$1,1K", "−$45,8K", "−$44,7K", 2, 98, shutter=True), cost_card("$45,8K", COST_STD)],
                     [mentor_card(shutter=True), league_card("&lt;%0,1", LEAGUE_LOW)])
    return fin_frame(top, fin_kpis("−$17.181", "−$44,7K", ("shutter", 3)), body, {"ekip": ("danger", "1"), "finans": ("danger", "1")})


def f_finans_sinyal():
    top = dict(TOP_FIN, week=30, phase=2, cash="$288.833", net="+$12,2K", run="profitable", mrr="$58,0K", slot=end_slot(8))
    chart = chart_card(HIST_SIGNAL, 30, 288833, 2837, 3012,
                       notes=(L("Gider gelirin altında; kasa erimiyor. Sayaç, net akış eksiye dönerse işler.",
                                "Expenses run below revenue; the treasury holds. The clock starts only if net flow turns negative."),
                              L("Artıda · 4/6 ay", "Default Alive · 4/6 mo")))
    body = ozet_body(chart, [], [goal_card(2, appetite=("closed", "below_bar")),
                                 flow_card("+$58,0K", "−$45,8K", "+$12,2K", 100, 21), cost_card("$45,8K", COST_STD)],
                     [league_card("%3,9", LEAGUE_SIGNAL)])
    return fin_frame(top, fin_kpis("$288.833", "+$12,2K", "profitable"), body, {"ekip": ("danger", "1")})


def f_finans_gider():
    # hr__gider seed (main.gd _run_hr_shot "gider"): week 10, ten-hour workday 09:00 to 19:00 (Ek mesai), one hire
    # commission. The product is not live yet (Traction'a 0/3), so there is no BuildHUD (kabuk ustbar__runway_ay).
    top = dict(TOP_FIN, week=10, cash="$211.744", net="−$62,4K", run=3, mrr="$0", burn="$62,4K", slot=end_slot(8, 19), end=19)
    chart = chart_card([(10, 211744)], 10, 211744, -14560, -14560)
    body = ozet_body(chart, [(tx_date(10), L("İşe alım", "Hire"), "−$3.000")],
                     [goal_card(1, met=0), flow_card("$0", "−$62,4K", "−$62,4K", 0, 100),
                      cost_card("$62,4K", [("sal", "$43,6K", 70), ("ot", "$16,6K", 26), ("tools", "$2,3K", 4)])],
                     [mentor_card()])
    return fin_frame(top, fin_kpis("$211.744", "−$62,4K", 3), body, {"ekip": ("danger", "1")}, company=None)


def f_finans_1536():
    return f_finans_ozet(w1536=True)


# ================================================================== FİNANS · YATIRIM (Series A hunt)
FUNDS = {  # InvestorRegistry (INV_ARCH_*, INV_CHIP_*) + art/busts/counterparts.json (the fund's lead partner, INV_ROLE_*)
    "anchor": ("Anchor Capital", ("Metrik", "Metrics"), ("Agresif ama cömert. Kontrolü sever.", "Aggressive but generous. Likes control."),
               "Kerem Kaya", ("Kıdemli Ortak", "Senior Partner")),
    "nexus": ("Nexus Ventures", ("Ekip", "Team"), ("Temkinli. Kurucuyu sever, riski sevmez.", "Cautious. Likes the founder, dislikes the risk."),
              "Nehir Şahin", ("Yönetici Ortak", "Managing Partner")),
    "bosphorus": ("Bosphorus Partners", ("Anlatı", "Narrative"), ("İlişki adamı. Kapıyı Frank açar.", "A relationship man. Frank opens the door."),
                  "Tolga Polat", ("Kurucu Ortak", "Founding Partner")),
    "meridian": ("Meridian Growth", ("Ürün", "Product"), ("Sektörü senden iyi bilir. Sabrı yoktur.", "Knows the sector better than you do. Has no patience."),
                 "Tolga Erdem", ("Büyüme Ortağı", "Growth Partner")),
}
STATUS = {"offered": (("Teklif var", "Offer in"), "pos"), "pending_sheet": (("Teklif bekliyor", "Offer pending"), "neutral"),
          "rejected": (("Reddetti", "Declined"), "risk"), "walked": (("Masadan kalktın", "You walked"), "neutral"),
          "expired": (("Süresi doldu", "Expired"), "neutral")}


def fund_row(fid, status):
    name, chip, arch, who, role = FUNDS[fid]
    closed = status in ("rejected", "walked", "expired")
    av = common.avatar(VC_LEAD[fid], 40, "is-grey" if closed else "")
    label, kind = STATUS[status]
    return ('<div class="fund%s">%s<div class="fund-b"><div class="fund-l1"><span class="n">%s</span>%s</div>'
            '<div class="fund-arch">%s</div><div class="fund-who">%s · %s</div></div><span class="st">%s</span></div>'
            % (" is-closed" if closed else "", av, name, tag(L(*chip), "outline"), L(*arch), who, L(*role), tag(L(*label), kind)))


def tier2_row():
    return ('<div class="fund is-locked"><span class="lockdisc">%s</span><div class="fund-b"><div class="fund-l1"><span class="n">%s</span></div>'
            '<div class="fund-who">%s</div></div></div>' % (ic("lock"), s("tier2"), L("Yakında", "Soon")))


def offer(fid, weeks, val, eq):
    """The countdown is the token table's: warn, neg only in the final week (one threshold with the Sıradaki slot).
    The deadline sits under the fund's name and the two actions take the header's right side, so the estimate row
    never runs into a button. Equity is a cost: ink with the slice glyph (rule 2, Frank's stake grammar)."""
    name = FUNDS[fid][0]
    cls = "neg" if weeks <= 1 else "warn"
    left = L("Teklifin son haftası", "Final week of the offer") if weeks <= 1 else L("Teklifte %d hafta kaldı", "%d weeks left on the offer") % weeks
    return ('<div class="offer"><div class="offer-h">%s<div class="offer-who"><span class="n">%s</span><span class="w %s">%s%s</span></div>'
            '<div class="acts"><span class="btn btn-ghost btn-sm">%s</span><span class="btn btn-secondary btn-sm">%s</span></div></div>'
            '<div class="offer-p"><div class="part"><span class="part-k">%s</span><span class="part-v">%s</span></div>'
            '<span class="part-sep"></span><div class="part cost"><span class="part-k">%s</span><span class="part-v">%s%s</span></div></div></div>'
            % (common.avatar(VC_LEAD[fid], 32), name, cls, ic("clock"), left, L("Masadan kalk", "Walk away"), L("Masaya otur", "Sit down"),
               s("est_val"), s("val_range", lo=val[0], hi=val[1]), s("est_eq"), ic("pie", 20), s("eq_range", lo=eq[0], hi=eq[1])))


def tables_row(k):
    pips = "".join('<i class="%s"></i>' % ("on" if i < k else "") for i in range(3))
    return ('<span class="tables"><span class="k t-caption">%s</span><span class="v">%d/3</span><span class="pips">%s</span></span>'
            % (L("Kapanan masa:", "Tables closed:"), k, pips))


def frank_strip(k):   # HUNT_FRANK_LINE
    return ('<div class="fstrip">%s<div class="w"><span class="n">Frank Köseoğlu</span><span class="q">%s</span></div></div>'
            % (common.avatar(FRANK, 40), L("Av açık. Kapanan masa: %d. Üçüncüde yol biter.", "The hunt is on. Tables closed: %d. The third one ends it.") % k))


def hunt_body(closed=False):
    k = 2 if closed else 1
    top = '<div class="hunt-top"><h2 class="t-h2">%s</h2>%s</div>' % (L("Series A Avı", "The Series A Hunt"), frank_strip(k))
    if closed:
        rows = fund_row("anchor", "rejected") + fund_row("nexus", "walked") + fund_row("bosphorus", "expired") + fund_row("meridian", "rejected")
    else:
        rows = fund_row("anchor", "offered") + fund_row("nexus", "rejected") + fund_row("bosphorus", "pending_sheet") + fund_row("meridian", "offered")
    rows += tier2_row()
    left = ('<div class="card" style="padding:12px 20px 4px"><div class="card-h t-label">%s%s</div><div class="card-b" style="margin-top:4px">%s</div></div>'
            % (L("Yatırımcılar", "Investors"), tables_row(k), rows))
    if closed:
        offers = ('<div class="card"><div class="card-h t-label">%s</div><div class="card-b road-closed">%s<span>%s</span></div></div>'
                  % (L("Teklifler", "Offers"), ic("termsheet"),
                     L("Series A için kapısı açık fon kalmadı. Bu yolda oturulacak masa yok.", "No fund is left open for a Series A. There is no table left on this road.")))
    else:
        offers = ('<div class="card" style="padding:12px 16px 16px"><div class="card-h t-label" style="padding-left:4px">%s</div><div class="card-b">%s%s'
                  '<div class="queued">%s<span>%s</span></div></div></div>'
                  % (L("Teklifler", "Offers"), offer("anchor", 2, (12, 17), (20, 28)), offer("meridian", 3, (11, 16), (16, 22)), ic("queue"),
                     L("<b>Bosphorus Partners</b> · sırada. Bir teklif kapanınca masaya gelir; süresi o hafta başlar (3 hafta).",
                       "<b>Bosphorus Partners</b> · queued. It arrives when an offer slot frees up, with a fresh 3 weeks.")))
    pend = ('<div class="card"><div class="card-h t-label">%s<span class="empty-m">%s%s</span></div></div>'
            % (L("Bekleyen", "Pending"), ic("calendar"), L("Bekleyen yok.", "Nothing pending.")))
    return ('%s<div class="cols" style="height:auto;margin-top:16px"><div class="col" style="width:704px">%s</div>'
            '<div class="col" style="flex:1">%s%s</div></div>' % (top, left, offers, pend))


def f_yatirim(closed=False):
    slot = end_slot(8) if closed else (s("next_offer", n=2), "warn")
    top = dict(week=1, clock=8, phase=3, cash="$330.000", net="+$124K", run="profitable", mrr="$125K", burn="$1,5K", slot=slot)
    win = window(208, 88, 1344, ("fit", 720), L("Finans", "Finance"), fin_kpis("$330.000", "+$124K", "profitable"), finans_ctl("yatirim"), hunt_body(closed))
    # the stack in the inbox grammar (kabuk ustbar__teklif_sayaci): sender · Teklif · weeks left
    items = () if closed else INBOX_VC
    return page(screen(topbar(top), rail("finans", {}), win, floats("PromptPilot", items), news=NEWS_VC))


# ================================================================== frames
FRAMES = {
    "satis__boru_hatti": f_satis_boru_hatti,
    "satis__masa_ve_portfoy": f_satis_masa_portfoy,
    "satis__temsilci_secici": lambda: f_satis_masa_portfoy(picker=True),
    "satis__b2c_bos": f_satis_b2c,
    "satis__renk_koru": lambda: f_satis_masa_portfoy(cb=True),
    "satis__1536": f_satis_1536,
    "finans__ozet": f_finans_ozet,
    "finans__artida": f_finans_artida,
    "finans__uyari": f_finans_uyari,
    "finans__kepenk": f_finans_kepenk,
    "finans__sinyal": f_finans_sinyal,
    "finans__gider_dokumu": f_finans_gider,
    "finans__1536": f_finans_1536,
    "finans__yatirim_av_acik": f_yatirim,
    "finans__yatirim_av_kapali": lambda: f_yatirim(closed=True),
}
EN = ["satis__temsilci_secici", "satis__masa_ve_portfoy", "finans__ozet", "finans__yatirim_av_acik"]


def main(names):
    os.makedirs(BUILD, exist_ok=True)
    jobs = [(k, "tr") for k in FRAMES] + [(k + "_en", "en") for k in EN]
    for name, lang in jobs:
        if names and name not in names:
            continue
        set_lang(lang)
        html = FRAMES[name[:-3] if lang == "en" else name]()
        with open(os.path.join(BUILD, name + ".html"), "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print("built", name)


if __name__ == "__main__":
    main(sys.argv[1:])
