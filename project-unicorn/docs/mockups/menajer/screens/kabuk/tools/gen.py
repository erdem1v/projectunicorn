"""Kabuk ve ofis katmanı: builds every frame of group "kabuk" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with tools/render_all.sh (calls the menajer render.sh per frame with each frame's size). The system kit
(tokens.css, base.css, icons, crop rule, top bar geometry) is read from ../../../system through the copies in
syskit/, whose caches live in this folder, so nothing is ever written into the system folder.
"""
import datetime
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import crops  # noqa: E402
import kit  # noqa: E402
from common import T, ic, num, set_lang  # noqa: E402
from kit import at, tag  # noqa: E402

MEN = common.MENAJER
REL = "../../../"          # build/ -> menajer/
REPO = "../../../../../../"  # build/ -> project-unicorn/ (office thumbnails, read only)


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src

FRANK = os.path.join(MEN, "portraits", "frank_cand_a.png")
FOUNDER = os.path.join(MEN, "portraits", "founder_01.png")
BUST = {k: os.path.join(MEN, "art", "bust_%s.png" % k) for k in ("elif", "deniz", "mert", "selin", "burak")}


def L(tr, en):
    return tr if common.LANG == "tr" else en


# ------------------------------------------------------------------ new strings this group introduces (EN first; INDEX.md lists them)
S = {
    "brand": ("Project Unicorn", "Project Unicorn"),
    "now": ("Now", "Şimdi"),
    "skip": ("Click or press Esc to skip the trip.", "Yolu geçmek için tıkla ya da Esc'ye bas."),
    "no_bugs": ("No confirmed bugs.", "Doğrulanmış hata yok."),
    "start_fix": ("Start a fix run", "Düzeltme başlat"),  # PROD_FIX_RUN_START (CSV), kept here so other groups importing buildhud() get it
    "move_started": ("Move started", "Taşınma başladı"),
    "moving_tag": ("Moving", "Taşınıyor"),
    "weeks": ("{n} weeks", "{n} hafta"),        # DESK_PAPER_WEEKS
    "week_one": ("1 week", "1 hafta"),
    "this_week": ("this week", "bu hafta"),     # DESK_PAPER_THIS_WEEK
    "postponed": ("Postponed", "Ertelendi"),
    "postponed_sub": ("The phone keeps ringing.", "Telefon çalmaya devam ediyor."),
    "postponed_vc_sub": ("The meeting moved to next week. It can't be put off again.",
                         "Toplantı gelecek haftaya ertelendi. Bir daha ertelenemez."),
    "loaded": ("Loaded", "Yüklendi"),
    "loaded_sub": ("Quicksave · Week 14 · 11:00", "Hızlı kayıt · Hafta 14 · 11:00"),
    "not_saved_sub": ("Not while a decision is waiting.", "Karar beklerken kaydedilemez."),  # SAVE_ERR_DECISION_WAITING, modallar_acilis' EN
    "clock_sub": ("Answer the waiting decision first.", "Önce bekleyen kararı cevapla."),
    "risk_line": ("Morale {n} · at risk of leaving", "Moral {n} · ayrılabilir"),
    "internal": ("Internal", "İçeriden"),
    "current_chip": ("Current · {name}", "Mevcut · {name}"),
    "confirmed": ("Confirmed {n}", "Doğrulanmış {n}"),
}


def s(key, **kw):
    en, tr = S[key]
    v = tr if common.LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ dates (GameState.get_date_dict: day 1 = 1 Jan 2026, a tick = 7 days)
MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


def _d(week):
    return datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))


def date(week):
    d = _d(week)
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    return L("Hafta %d · %s %d" % (w, MON_TR[d.month - 1], d.year), "Week %d · %s %d" % (w, MON_EN[d.month - 1], d.year))


def date_c(week):
    d = _d(week)
    return L("H%d · %s" % (week, MON_TR[d.month - 1][:3]), "W%d · %s" % (week, MON_EN[d.month - 1][:3]))


# ------------------------------------------------------------------ avatars at any size (crop rule of SPEC §3.5)
def av(path, size, cls=""):
    x, y, d = crops.disc_box(path, size)
    img = crops.css_img(path, _src(path), size, size, (x, y, d, d))
    return '<span class="av %s" style="width:%dpx;height:%dpx">%s</span>' % (cls, size, size, img)


# ------------------------------------------------------------------ brand block, decision 14
def emblem(style, letter, size=32):
    """LogoEmblem (logo_emblem.gd) in SVG: r = size/2 - 2, letter at int(r*1.05), centred on its ascent-descent."""
    c = size / 2.0
    r = c - 2
    orange, cream, ground = "var(--brand-mark)", "var(--emblem-cream)", "var(--emblem-ground)"
    fs = int(r * 1.05)
    ty = c + (1.025 - 0.275) / 2 * fs
    letter_c = cream
    if style == "minimalist":
        shape = '<circle cx="%.1f" cy="%.1f" r="%.1f" fill="none" stroke="%s" stroke-width="1.5"/>' % (c, c, r, orange)
    elif style == "tech":
        import math
        pts = " ".join("%.2f,%.2f" % (c + math.cos(math.tau * i / 6 - math.pi / 2) * r, c + math.sin(math.tau * i / 6 - math.pi / 2) * r) for i in range(6))
        shape = '<polygon points="%s" fill="none" stroke="%s" stroke-width="1.5" stroke-linejoin="round"/>' % (pts, orange)
        letter_c = orange
    elif style == "playful":
        shape = '<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" rx="%d" fill="%s"/>' % (c - r, c - r, 2 * r, 2 * r, int(r * 0.45), orange)
        letter_c = ground
    else:  # serious
        shape = '<rect x="%.1f" y="%.1f" width="%.1f" height="%.1f" fill="%s"/>' % (c - r, c - r, 2 * r, 2 * r, cream)
        letter_c = ground
    return ('<svg class="emblem" width="%d" height="%d" viewBox="0 0 %d %d">%s<text x="%.1f" y="%.2f" text-anchor="middle" '
            'font-size="%d" fill="%s">%s</text></svg>' % (size, size, size, size, shape, c, ty, fs, letter_c, letter))


def brand_block(brand, compact, phase=1, company="Unicorn Inc."):
    """brand: "a" (orange square + Project Unicorn) or "b:<style>" (the player's company and LogoEmblem)."""
    out = []
    if brand == "a":
        if compact:
            out.append('<span class="brand-sq" style="left:22px;top:22px"></span>')
            return "".join(out)
        out.append('<span class="brand-sq" style="left:20px;top:14px"></span>')
        tx, name, w = 48, s("brand"), 184 - 48 - 12
    else:
        style = brand.split(":")[1]
        letter = company.strip()[:1].upper()
        if compact:
            return '<div style="position:absolute;left:16px;top:16px">%s</div>' % emblem(style, letter)
        out.append('<div style="position:absolute;left:20px;top:16px">%s</div>' % emblem(style, letter))
        tx, name, w = 64, company, 184 - 64 - 12
    out.append(at(tx, 31, "t-subhead", name, "tb-co", width=w))
    ph = [T("phase"), "Traction", "Series A"][phase - 1]
    out.append(at(tx, 50, "t-micro", ph, "tb-k"))
    for i in range(3):
        out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i < phase else "", tx + kit.TB_PHASE_W + 8 + i * 12))
    return "".join(out)


# ------------------------------------------------------------------ top bar values (seed and the derived states; INDEX.md says where each comes from)
SEED = dict(cash="$10.000", hero="tb-hero", net="+$2,5K", net_cls="tb-d", run_k="runway", run="profitable", run_cls="tb-v pos",
            mrr="$4,0K", brand="50", burn="$1,5K", rep="0")
V_SHUTTER = dict(SEED, cash="−$4.200", hero="tb-hero neg", net="−$3,1K", net_cls="tb-d neg", run_k="shutter_k", run=("3 hafta", "3 weeks"),
                 run_cls="tb-v neg", burn="$7,1K")
V_WEEK1 = dict(SEED, net="−$1,5K", net_cls="tb-v", run=("7 ay", "7 mo"), run_cls="tb-v", mrr="$0")
V_RED = dict(SEED, cash="$6.200", net="−$3,1K", net_cls="tb-v", run=("2 ay", "2 mo"), run_cls="tb-v neg", burn="$7,1K")
V_REDW = dict(V_RED, cash="$2.200", run=("3 hafta", "3 wk"))
V_CHEQUE = dict(SEED, cash="$35.000")


def _run_text(v):
    r = v["run"]
    return T("profitable") if r == "profitable" else L(*r)


def topbar(v=SEED, W=1920, compact=False, slot=None, speed="II", week=14, clock=11, marks=(14,), brand="a", phase=1, held=False, godot_fit=False):
    """slot: ("next", text, kind) | ("gate", sub) | ("now", text). godot_fit narrows the slot text box by the Godot
    slack (measure.py: a Label needs Chrome width x 1.08 + 2), so a text that clips in the game clips here too."""
    slot = slot or ("next", T("next_meet"), "")
    col, g, time_w = kit.tb_layout(compact)
    gated = slot[0] == "gate"
    out = [brand_block(brand, compact, phase)]
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"), at(col["B"], b1, "t-hero", num(v["cash"]), v["hero"]),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", num(v["net"]) + '<span class="tb-u">%s</span>' % T("per_mo"), v["net_cls"]),
            at(col["C"], b1, "t-label", T(v["run_k"]), "tb-k"), at(col["D"], b1, "t-value", _run_text(v), v["run_cls"]),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", num(v["mrr"]), "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", v["brand"], "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", num(v["burn"]) + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", v["rep"], "tb-v")]
    d0 = col["metrics_end"]
    pad = 16 if compact else 20
    # The week bar stops at 720 px; past that (2560) the slot and the time block stay next to the day block and the
    # slack falls after the time block, so nothing sits 300 px away from the bar it belongs to (Q21).
    gate_x = min(W - time_w - g["gate"], d0 + pad + 720 + pad)
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + pad, 28, "t-body", date_c(week) if compact else date(week), "tb-date"))
    out.append(kit.week_bar(d0 + pad, gate_x - pad, now_h=clock, marks=marks))
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"]))
    if gated:
        tx = gate_x + g["gate_pad"] + 10 + (10 if compact else 12)
        out.append('<span class="gate-dot" style="position:absolute;left:%dpx;top:19px"></span>' % (gate_x + g["gate_pad"]))
        out.append(at(tx, 30, "t-gate", T("gate"), "gate-l"))
        out.append(at(tx, 51, "t-key", slot[1], "gate-s", width=g["gate"] - (tx - gate_x) - g["gate_pad"]))
    else:
        tx = gate_x + g["gate_pad"]
        lab = s("now") if slot[0] == "now" else T("next")
        kind = "now" if slot[0] == "now" else slot[2]
        out.append(at(tx, 29, "t-micro", lab, "nx-l"))
        box = g["gate"] - 2 * g["gate_pad"]
        out.append(at(tx, 50, "t-key", slot[1], "nx-s " + kind, width=int((box - 2) / 1.08) if godot_fit else box))
    tx0 = gate_x + g["gate"]
    slack = " has-slack" if tx0 + time_w < W else ""
    out.append('<div class="tb-time%s" style="left:%dpx;width:%dpx"></div>' % (slack, tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "%02d:00" % int(clock), "tb-clock"))
    kx = tx0 + g["time_pad"][0] + kit.TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if (k == speed and not (gated or held)) else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    if gated:
        out.append('<div class="tb-gated-frame" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"] + time_w))
    cls = "topbar" + (" is-gated" if gated else "") + (" is-held" if held else "")
    return '<header class="%s" style="width:%dpx;right:auto">%s</header>' % (cls, W, "".join(out))


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]
B14 = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


def rail(active=None, badges=None, icons=False, hover=None, focus=None, style="", bottom=None, build="demo", lock_why=None):
    """build: demo (Pazarlama's "ea" gate shut, reason lock_why or today's SYS_SOON) | ea (the gate open)."""
    badges = B14 if badges is None else badges
    rows = []
    for key, name in RAIL:
        b = "lock" if (key == "pazarlama" and build == "demo") else badges.get(key)
        cls = ("rr" + (" is-active" if key == active else "") + (" is-hover" if key == hover else "")
               + (" kfocus" if key == focus else "") + (" is-locked" if b == "lock" else ""))
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), lock_why or T("soon"))
            if icons:
                right = '<span class="lk">%s</span>' % ic("lock", 12)
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    pos = "" if bottom is None else "bottom:%dpx;" % bottom
    return ('<nav class="rail%s" style="%s%s">%s<div class="rail-bottom"%s><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", pos, style, "".join(rows),
               ' style="bottom:52px"' if bottom == 0 else "", ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ ticker
NEWS_TR = [("sektor", "Sektör Telgrafı", "TICKER_04"), ("ekonomi", "Ekonomi Postası", "TICKER_05"),
           ("teknogundem", "TeknoGündem", "TICKER_06"), ("girisim", "Girişim Bülteni", "TICKER_07"),
           ("sektor", "Sektör Telgrafı", "TICKER_08"), ("ekonomi", "Ekonomi Postası", "TICKER_09")]
TICKER_TEXT = {  # localization/strings.csv
    "TICKER_04": ("Teknoloji kampüslerinde staj kontenjanları rekor kırdı.", "Internship quotas hit a record across tech campuses."),
    "TICKER_05": ("Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta.", "Discount season on server leases; infrastructure teams are negotiating."),
    "TICKER_06": ("Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi.", "Digital transformation tenders are queuing up in industrial zones."),
    "TICKER_07": ("Melek yatırım ağları yeni dönem başvurularını açtı.", "Angel networks open applications for the new season."),
    "TICKER_08": ("Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu.", "Software exporters hunt for new markets; the trade-fair calendar is full."),
    "TICKER_09": ("Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu.", "Office downsizing continues; shared floors are full."),
}


def ticker(live=(), collapsed=False, hover=False, style=""):
    if collapsed:
        return ('<footer class="ticker is-collapsed" style="%s"><div class="tk-toggle%s">%s</div></footer>'
                % (style, " is-hover" if hover else "", ic("news")))
    items = []
    for cls, src, txt in list(live) + [(c, p, L(*TICKER_TEXT[k])) for c, p, k in NEWS_TR]:
        if items:
            items.append('<span class="tk-sep">   ·   </span>')
        items.append('<span class="tk-pub %s">%s</span><span class="tk-hl">%s</span>' % (cls, src, txt))
    return ('<footer class="ticker" style="%s"><div class="tk-toggle%s">%s</div><div class="tk-run">%s</div></footer>'
            % (style, " is-hover" if hover else "", ic("news"), "".join(items)))


def live_runway():
    return ("internal", s("internal"), L("Runway 3 ayın altına indi", "Runway fell below 3 months"))


# ------------------------------------------------------------------ office layer
PLATES = {
    "ishani": ("art/office_safe_1920_noicons.png", "art/office_safe_1920_heads.json", 1736, 976),
    "home": ("art/office_safe_1920_home_noicons.png", "art/office_safe_1920_home_heads.json", 1736, 976),
    "i1536": ("art/office_safe_1536_noicons.png", "art/office_safe_1536_heads.json", 1352, 760),
    "i2560": ("art/office_safe_2560_noicons.png", "art/office_safe_2560_heads.json", 2376, 976),
    "city": ("art/office_safe_1920_city.png", None, 1736, 976),
}
HEAD_FILE = {"plan": "research", "research": "research", "test": "test", "design": "design", "phone": "phone", "code": "code",
             "coffee": "coffee", "wc": "wc", "visit": "meeting", "meeting": "meeting", "food": "food"}


def heads(name):
    p = PLATES[name][1]
    return json.load(open(os.path.join(MEN, p), encoding="utf-8"))["people"] if p else []


def office(name, x, y, w, h, dim=False):
    """The plate fills the safe rect (x, y, w, h) by cover; the head icons are the A2 office sprites at the plate's own
    head positions (the 'noicons' plates have the old Lucide sprites removed)."""
    f, _, pw, ph = PLATES[name]
    k = max(w / pw, h / ph)
    ox, oy = x + (w - pw * k) / 2, y + (h - ph * k) / 2
    out = ['<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;overflow:hidden">' % (x, y, w, h),
           '<div class="abs" style="left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%.1fpx;background:url(%s%s) 0 0/100%% 100%%"></div>'
           % (ox - x, oy - y, pw * k, ph * k, REL, f)]
    for p in heads(name):
        if not p.get("icon_visible"):
            continue
        sz = p["icon_px"] * k
        cx, cy = ox + p["icon_xy"][0] * k - x, oy + p["icon_xy"][1] * k - y
        out.append('<img class="head-ic" src="%ssystem/icons/office/%s.svg" style="left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%.1fpx">'
                   % (REL, HEAD_FILE[p["status"]], cx - sz / 2, cy - sz / 2, sz, sz))
    out.append("</div>")
    return '<div class="office-layer"%s>%s</div>' % (' style="filter:brightness(var(--dim))"' if dim else "", "".join(out))


def plate_xy(name, x, y, w, h, px, py):
    """Screen position of a plate pixel under the cover placement used by office()."""
    _, _, pw, ph = PLATES[name]
    k = max(w / pw, h / ph)
    return x + (w - pw * k) / 2 + px * k, y + (h - ph * k) / 2 + py * k


# ------------------------------------------------------------------ floats
def buildhud(x, y, state="seed", hover=False, auto=False, split=False):
    """state: seed (0 confirmed, decision off) | ready (3 confirmed) | run (fix run under way, 2 of 5 fixed)."""
    note = '<span class="note">%s</span>' % L("Ekip iki işte.", "The team is on two jobs.") if split else ""
    n = {"seed": 0, "ready": 3, "run": 3}[state]
    pct = ""
    prog = ""
    if state == "run":
        pct = '<span class="pct">%s</span>' % L("%40", "40%")
        prog = '<div class="prog"><div class="prog-t"><div class="prog-f" style="width:40%"></div></div></div>'
    phase = ('<div class="bh-rw bh-phase">%s<span class="k t-label">%s</span><span class="v">%s</span>%s%s</div>'
             % (ic("shield", 16, "var(--ink-3)"), T("support"), s("confirmed", n=n), pct, prog))
    if state == "seed":
        act = ('<div class="bh-act"><span class="btn btn-ghost btn-sm is-disabled">%s%s</span><span class="why">%s</span></div>'
               % (ic("play", 12), s("start_fix"), s("no_bugs")))
    else:
        label = L("Koşuyu bitir", "End the run") if state == "run" else s("start_fix")
        act = ('<div class="bh-act"><span class="btn btn-ghost btn-sm%s">%s%s</span></div>'
               % (" is-hover" if hover else "", ic("pause" if state == "run" else "play", 12), label))
    foot = ""
    if auto:
        foot = '<div class="bh-auto">%s<span>%s</span></div>' % (ic("k_feature"), L("Sprint otomatik başladı", "Sprint started automatically"))
    return ('<div class="float bh abs" style="left:%dpx;top:%dpx"><div class="bh-hd">%s<span class="t">Unicorn Inc. v1</span>%s</div>%s%s%s</div>'
            % (x, y, ic("urun", 20, "var(--ink-3)"), note, phase, act, foot))


def research(x, y, paused=False, hover=None):
    st = L("Ekip yapımda.", "The team is on a build.") if paused else L("~1 hafta kaldı", "~1 week left")
    lk = lambda k, t: '<span class="lk%s">%s</span>' % (" is-hover" if hover == k else "", t)
    # research_bar.gd hides the pause link while paused (_pause_link.visible = not m.paused): only "ata" is left
    links = lk("assign", L("ata", "assign"))
    if not paused:
        links = lk("pause", L("duraklat", "pause")) + '<span class="dot">·</span>' + links
    return ('<div class="float rb abs%s" style="left:%dpx;top:%dpx"><div class="rb-hd">%s<span class="t t-label">%s</span><span class="st">%s</span></div>'
            '<div class="rb-nm"><span class="n">%s</span><span class="a">%s</span></div>'
            '<div class="prog"><div class="prog-t"><div class="prog-f" style="width:35%%"></div></div><span class="prog-v">%s</span></div>'
            '<div class="rb-ft">%s</div></div>'
            % (" is-paused" if paused else "", x, y, ic("arge", 16), L("Araştırma", "Research"), st, L("Veri Modeli", "Data Model"),
               L("Ürün alanı", "Product area"), L("%35", "35%"), links))


FRANK_LINE = ("Görüşme ayarlandı. Hazırlıklı git.", "Meeting's set. Go in prepared.")


# ------------------------------------------------------------------ notice stack = the inbox preview
# One list feeds every stack (plan: "Bildirim yığını: kutunun önizlemesi"): the waiting mail of the seed inbox in the
# olaylar group's inbox order (papers by time left, the newer first on a tie, then reminders). A reminder hides while a
# decision about the same subject is active; the Nordica growth reminder hides while its paper is on the desk (olaylar
# rule). The active decision itself sits in the gate slot, queued ones are a count there: neither is a stack row.
# Row = sender · subject · time left (mail grammar, DESK_PAPER_WEEKS / DESK_PAPER_THIS_WEEK); reminders carry no time.
def mail(sender, subject, dot="", weeks=None, kind="paper", about=None):
    return dict(sender=sender, subject=subject, dot=dot, weeks=weeks, kind=kind, about=about)


NORDICA = mail("Nordica", ("Bir ekip daha", "One more team"), weeks=2)                               # customer.expansion paper
EGE = mail("Ege Sigorta", ("Risk altında", "At risk"), "is-risk", kind="reminder", about="co_ege")       # SALES_CHIP_RISK
SELIN = mail("Selin Kaya", ("Ayrılabilir", "At risk of leaving"), "is-risk", kind="reminder", about="selin")  # HR st_risk
ANCHOR = mail("Anchor Capital", ("Teklif", "Offer"), weeks=2, kind="sheet")                             # term sheet reminder
SEED_INBOX = [NORDICA, EGE, SELIN]


def stack_row(m):
    """dot class, sender, subject, time text and time class of one waiting mail."""
    w = m["weeks"]
    time = "" if w is None else (s("this_week") if w == 1 else s("weeks", n=w))
    if m["kind"] == "sheet":  # the offer countdown reads like its slot: warn, neg in the final week
        dot, tcls = ("is-risk", "is-neg") if w == 1 else ("is-warn", "is-warn")
    else:
        dot, tcls = m["dot"], ("is-warn" if w == 1 else "")
    return dot, m["sender"], L(*m["subject"]), time, tcls


def notices(W, H, inbox, active=None, frank=False, more=0, hover=None):
    """The stack grows up from the bottom right: Frank's latest line (derived frames only), then the inbox's waiting
    mail, a reminder about the active decision's subject left out. hover counts cards from the top."""
    cards = []
    rows = [stack_row(m) for m in inbox if not (active and m["about"] == active)]
    n = len(rows) + (1 if frank else 0)
    if frank:
        cards.append('<div class="float notice frank%s">%s<div class="fq"><span class="co">Frank Köseoğlu</span><span class="q">"%s"</span></div>%s</div>'
                     % (" is-hover" if hover == 0 else "", av(FRANK, 32), L(*FRANK_LINE),
                        '<span class="badge badge-count">+%d</span>' % more if (more and n == 1) else ""))
    for i, (dot, co, tx, wk, tcls) in enumerate(rows, start=1 if frank else 0):
        w = '<span class="nwk %s">%s</span>' % (tcls, wk) if wk else ""
        badge = '<span class="badge badge-count">+%d</span>' % more if (more and i == n - 1) else ""
        cards.append('<div class="float notice%s"><span class="dt %s"></span><span class="co">%s</span><span class="tx">%s</span>%s%s</div>'
                     % (" is-hover" if hover == i else "", dot, co, tx, w, badge))
    return ('<div class="abs" style="right:%dpx;bottom:%dpx;width:352px;display:flex;flex-direction:column;gap:8px">%s</div>'
            % (24, 40 + 24, "".join(cards))) if W else "".join(cards)


def move_btn(x, y, state="idle"):
    """state: idle | hover | breath | held (decision waiting) | moving."""
    cls = "float fbtn" + {"hover": " is-hover", "breath": " is-breath-peak", "held": " is-disabled"}.get(state, "")
    extra = ""
    if state == "moving":  # split like İzinde: the caps tag says what, the time left is plain text (OFFICE_MOVING_BADGE in two)
        extra = tag(s("moving_tag"), "neutral") + '<span class="left">%s</span>' % s("week_one")
    if state == "held":
        extra = '<span class="why">%s</span>' % T("gate")
    return '<div class="%s" style="left:%dpx;top:%dpx">%s%s%s</div>' % (cls, x, y, ic("move"), T("move_office"), extra)


def toast(x, y, kind, glyph, head, sub):
    return ('<span class="toast at %s" style="left:%dpx;top:%dpx"><span class="well">%s</span><span class="head">%s</span><span class="sub">%s</span></span>'
            % (kind, x, y, ic(glyph), head, sub))


def ptip(x, y, path, name, role, status, risk=None):
    rl = '<div class="risk-l">%s</div>' % s("risk_line", n=risk) if risk is not None else ""
    return ('<span class="ptip" style="left:%dpx;top:%dpx">%s<span><div class="n">%s</div><div class="r">%s · %s</div>%s</span></span>'
            % (x, y, av(path, 32), name, role, status, rl))


CURSOR = ('<svg class="cursor" style="left:%dpx;top:%dpx" viewBox="0 0 20 24"><path d="M1.5 1.5 L1.5 19 L6 14.8 L9.2 22 L12.4 20.6 '
          'L9.3 13.6 L15.6 13.6 Z" fill="#FFFFFF" stroke="#000000" stroke-width="1.5" stroke-linejoin="round"/></svg>')


# ------------------------------------------------------------------ the Ekip window (system kit), dimmed office, halo
def ekip(x, y, readonly=False):
    return kit.ekip_window(x, y, readonly=readonly)


# ------------------------------------------------------------------ page and screen
def page(body, W=1920, H=1080, title="Kabuk", lang="tr"):
    """lang sets the caps rule for the whole page: tr gives the dotted İ, en the plain I (REPUTATION, TRACTION)."""
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../kabuk.css"><style>html,body{width:%dpx;height:%dpx}</style></head><body>%s</body></html>'
            % (lang, title, common.FONTS, REL, REL, W, H, body))


def screen(W, H, layers):
    return '<div class="screen" style="width:%dpx;height:%dpx">%s</div>' % (W, H, "".join(layers))


FRAMES = {}  # name -> (builder, css_w, css_h, scale, lang)


def frame(name, w=1920, h=1080, scale=None, lang="tr"):
    def deco(fn):
        FRAMES[name] = (fn, w, h, scale, lang)
        return fn
    return deco


def std_screen(top, office_html, floats="", window="", rail_html=None, tick=None, W=1920, H=1080):
    return screen(W, H, [office_html, floats, window, top, rail_html if rail_html is not None else rail("ekip" if window else None),
                         tick if tick is not None else ticker()])


def office1920(name="ishani", dim=False):
    return office(name, 184, 64, 1736, 976, dim)


def seed_floats(hud=True, notes=None, btn="idle", extra=""):
    out = []
    if hud:
        out.append(buildhud(1576, 88))
    out.append(notices(1920, 1080, SEED_INBOX if notes is None else notes))
    if btn:
        out.append(move_btn(208, 972, btn))
    return "".join(out) + extra


# ================================================================== frames: shell at 1920
@frame("kabuk__normal")
def f_normal():
    return std_screen(topbar(), office1920(), seed_floats(), rail_html=rail(None))


@frame("kabuk__pencere_acik")
def f_window():
    return std_screen(topbar(), office1920(dim=True), seed_floats(), ekip(208, 88), rail_html=rail("ekip"))


# funding.frank_cheque is tick: daily, so it fires at the 00:00 rollover inside the night step; the gate frames hold the
# clock where the week starts (08:00), assuming the night step reaches the week start before hold_clock("event") stops
# it (INDEX open question). The plate is the 11:00 office.
GATE_CLOCK = 8


@frame("ustbar__karar_bekliyor")
def f_gate1():
    b = dict(B14, olaylar=("gate", ""))
    t = toast(1052, 968, "hold", "pause", T("locked_clock"), s("clock_sub"))
    return std_screen(topbar(slot=("gate", "Frank Köseoğlu"), clock=GATE_CLOCK), office1920(), seed_floats(btn="held", extra=t), rail_html=rail(None, b))


@frame("ustbar__karar_bekliyor_3")
def f_gate3():
    b = dict(B14, olaylar=("gate", ""))
    t = toast(1052, 968, "warn", "save", T("not_saved"), s("not_saved_sub"))
    return std_screen(topbar(slot=("gate", T("gate_n", n=3)), clock=GATE_CLOCK), office1920(), seed_floats(btn="held", extra=t), rail_html=rail(None, b))


@frame("ustbar__kepenk")
def f_shutter():
    b = dict(B14, finans=("danger", "1"))
    return std_screen(topbar(V_SHUTTER, slot=("next", T("next_end"), ""), marks=()), office1920(), seed_floats(), rail_html=rail(None, b))


@frame("ustbar__runway_ay")
def f_week1():
    hud = notices(1920, 1080, [])
    return std_screen(topbar(V_WEEK1, slot=("next", L("Mesai bitimi · 6 saat", "Workday ends · 6 h"), ""), week=1, marks=()),
                      office1920("home"), hud + move_btn(208, 972), rail_html=rail(None, {}))


@frame("ustbar__runway_kirmizi")
def f_red():
    b = dict(B14, finans=("danger", "1"))
    return std_screen(topbar(V_RED), office1920(), seed_floats(), rail_html=rail(None, b), tick=ticker(live=[live_runway()]))


@frame("ustbar__teklif_sayaci")
def f_offer():
    notes = [ANCHOR] + SEED_INBOX
    return std_screen(topbar(slot=("next", T("next_offer"), "warn"), phase=2, marks=()), office1920(), seed_floats(notes=notes), rail_html=rail(None))


@frame("ustbar__sprint_otomatik")
def f_auto():
    fl = buildhud(1576, 88, auto=True) + notices(1920, 1080, SEED_INBOX) + move_btn(208, 972)
    return std_screen(topbar(), office1920(), fl, rail_html=rail(None))


@frame("ustbar__yolculuk")
def f_trip():
    return std_screen(topbar(slot=("now", T("next_meet")), clock=14, held=True), trip_map(), "", rail_html=rail(None))


@frame("marka__b_kabukta")
def f_brand_b():
    return std_screen(topbar(brand="b:minimalist"), office1920(), seed_floats(), rail_html=rail(None))


# ------------------------------------------------------------------ city map: the trip and the office card
CITY = json.load(open(os.path.join(MEN, "art", "office_safe_1920_city_chips.json"), encoding="utf-8"))["chips"]
PIN = (650, 321)            # İş hanı pin top, plate px (read from the plate)
TOWER = (1061, 430)         # meeting tower roof, plate px (the tower the baseline trip ends at)


def trip_map():
    ox, oy = 184, 64
    layer = office("city", ox, oy, 1736, 976)
    a = (ox + PIN[0], oy + PIN[1])
    b = (ox + TOWER[0], oy + TOWER[1])
    c = ((a[0] + b[0]) / 2, min(a[1], b[1]) - 120)
    path = "M%.1f %.1f Q%.1f %.1f %.1f %.1f" % (a[0], a[1], c[0], c[1], b[0], b[1])
    road = ('<svg class="road" style="left:0;top:0" width="1920" height="1080" viewBox="0 0 1920 1080"><path class="casing" d="%s"/>'
            '<path class="dash" d="%s"/></svg>' % (path, path))
    t = 0.36
    px = (1 - t) ** 2 * a[0] + 2 * (1 - t) * t * c[0] + t ** 2 * b[0]
    py = (1 - t) ** 2 * a[1] + 2 * (1 - t) * t * c[1] + t ** 2 * b[1]
    disc = '<div class="road-disc" style="left:%dpx;top:%dpx">%s</div>' % (px - 24, py - 24, av(FOUNDER, 48))
    cur = next(ch for ch in CITY if ch["office"] == "ishani")
    chips = ('<span class="mchip is-current" style="left:%dpx;top:%dpx">%s%s</span>'
             % (ox + cur["xy"][0], oy + cur["xy"][1], ic("crown"), s("current_chip", name=L("İş hanı", "Business block"))))
    chips += ('<span class="mchip is-dest" style="left:%dpx;top:%dpx">%s%s</span>'
              % (b[0], b[1] - 30, ic("building"), "Karadeniz Fabrika · Elif Yıldız"))
    skip = '<span class="skip" style="left:1052px;top:972px">%s%s</span>' % (ic("keyboard"), s("skip"))
    return layer + road + disc + chips + skip


def office_card(oid, x, y, situation):
    """situation: current | movable | moving | blocked. Values: office_constants.gd CATALOG; requirements against the seed
    (team 5, cash $10.000, brand 50) except movable/moving (home after Frank's cheque: cash $35.000)."""
    cat = {
        "ishani": dict(tier=L("Başlangıç", "Starter"), name=L("İş hanı", "Business block"), desc=L("Dört katlı eski bir iş hanının 3. katı", "3rd floor of an old four-storey business block"),
                       desks="10", rent="$2,5K", move="$6,5K", note=L("Depozito $5,0K + nakliye $1,5K", "Deposit $5.0K + movers $1.5K"),
                       rooms=[L("Açık ofis", "Open-plan office"), L("Toplantı odası", "Meeting room"), L("Kurucu cam ofisi", "Founder's glass office"), L("Mutfak", "Kitchen"), L("Tuvalet", "Restroom")]),
        "plaza": dict(tier=L("Orta", "Mid"), name=L("Plaza katı", "Plaza floor"), desc=L("Cam bir plaza kulesinin tam katı", "A full floor of a glass office tower"),
                      desks="36", rent="$18,0K", move="$45,0K", note=L("Depozito $36,0K + nakliye $9,0K", "Deposit $36.0K + movers $9.0K"),
                      rooms=[L("Resepsiyon", "Reception"), L("2 toplantı odası", "2 meeting rooms"), L("Yönetim kurulu salonu", "Board room"), L("Departman adaları", "Department pods"), L("Telefon kabinleri", "Phone booths"), L("Kafe ve oyun alanı", "Cafe and games area")]),
        "loft": dict(tier=L("Yüksek", "High"), name=L("Depo loft", "Warehouse loft"), desc=L("Dönüştürülmüş tuğla depo · zemin ve asma kat", "A converted brick warehouse · ground floor and mezzanine"),
                     desks="64", rent="$45,0K", move="$110,0K", note=L("Depozito $90,0K + nakliye $20,0K", "Deposit $90.0K + movers $20.0K"),
                     rooms=[L("Resepsiyon ve güvenlik", "Reception and security"), L("Amfi ve sahne", "Amphitheatre and stage"), L("3 toplantı odası", "3 meeting rooms"), L("Telefon kabinleri", "Phone booths"), L("Oyun alanı", "Games area"), L("VP odaları", "VP offices"), L("Yönetim salonu", "Executive room"), L("Kurucu ofisi", "Founder's office")]),
    }[oid]
    reqs = {
        "ishani": [(True, L("Frank'in çeki alındı", "Frank's cheque taken"), L("alındı", "taken")),
                   (True, L("Kasada $6,5K", "$6.5K in the bank"), L("şu an $35,0K", "now $35.0K") if situation != "current" else L("şu an $10,0K", "now $10.0K"))],
        "plaza": [(False, L("Ekip en az 12 kişi", "Team of at least 12"), L("şu an 5", "now 5")), (False, L("Kasada $45,0K", "$45.0K in the bank"), L("şu an $10,0K", "now $10.0K")),
                  (True, L("Marka en az 40", "Brand at least 40"), L("şu an 50", "now 50"))],
        "loft": [(False, L("Ekip en az 35 kişi", "Team of at least 35"), L("şu an 5", "now 5")), (False, L("Kasada $110,0K", "$110.0K in the bank"), L("şu an $10,0K", "now $10.0K")),
                 (False, L("Marka en az 70", "Brand at least 70"), L("şu an 50", "now 50"))],
    }[oid]
    unmet = sum(1 for r in reqs if not r[0])
    if situation == "current":
        status = tag(L("Mevcut", "Current"), "neutral")
        go = '<span class="btn btn-primary btn-sm is-disabled">%s</span>' % L("Buradasınız", "You are here")
    elif situation == "movable":
        status = tag(L("Taşınabilir", "Can move"), "pos")
        go = '<span class="btn btn-primary btn-sm">%s</span>' % L("Taşın · %s", "Move · %s") % cat["move"]
    elif situation == "moving":
        status = tag(L("Taşınabilir", "Can move"), "pos")
        go = '<span class="btn btn-primary btn-sm is-disabled">%s</span>' % L("Taşınıyor · 1 hafta", "Moving · 1 week")
    else:
        status = tag(L("Şartlar karşılanmadı", "Requirements not met"), "outline")
        go = '<span class="btn btn-primary btn-sm is-disabled">%s</span>' % (L("%d şart karşılanmadı", "%d requirements unmet") % unmet)
    kv = "".join('<div><div class="k t-micro">%s</div><div class="v t-value">%s</div></div>' % (k, v)
                 for k, v in ((L("Masa", "Desks"), cat["desks"]), (L("Kira / ay", "Rent / mo"), cat["rent"]), (L("Taşınma", "Move"), cat["move"])))
    rooms = "".join(tag(r, "neutral") for r in cat["rooms"])
    rq = "".join('<div class="req %s">%s%s<span class="now">%s</span></div>' % ("ok" if ok else "no", ic("check" if ok else "close"), t, now)
                 for ok, t, now in reqs)
    return ('<div class="mcard" style="left:%dpx;top:%dpx"><div class="img" style="background-image:url(%sassets/art/office/thumb_%s.jpg)"></div><div class="b">'
            '<div class="head"><span class="t-micro">%s</span>%s</div><div class="nm t-subhead">%s</div><div class="ds t-caption">%s</div>'
            '<div class="kv">%s</div><div class="mv">%s</div><div class="sec t-label">%s</div><div class="rooms">%s</div>'
            '<div class="sec t-label">%s</div>%s<div class="acts"><span class="btn btn-secondary btn-sm">%s</span>%s</div></div></div>'
            % (x, y, REPO, oid, cat["tier"], status, cat["name"], cat["desc"], kv, cat["note"], L("Getirdikleri", "What you get"), rooms,
               L("Şartlar", "Requirements"), rq, L("Vazgeç", "Cancel"), go))


def city_chips(current="ishani", locked=("plaza", "loft")):
    ox, oy = 184, 64
    icon = {"ishani": "building", "home": "home", "plaza": "tower", "loft": "loft"}
    names = {"ishani": L("İş hanı", "Business block"), "home": L("Ev", "Home"), "plaza": L("Plaza katı", "Plaza floor"), "loft": L("Depo loft", "Warehouse loft")}
    out = []
    for c in CITY:
        cur = c["office"] == current
        txt = s("current_chip", name=names[c["office"]]) if cur else names[c["office"]]
        cls = "mchip" + (" is-current" if cur else "") + (" is-locked" if c["office"] in locked else "")
        out.append('<span class="%s" style="left:%dpx;top:%dpx">%s%s</span>'
                   % (cls, ox + c["xy"][0], oy + c["xy"][1], ic("crown" if cur else icon[c["office"]]), txt))
    return "".join(out)


def map_panel(x, y):
    return ('<div class="float doc-sm mpanel" style="left:%dpx;top:%dpx"><div><div class="t t-subhead">%s</div><div class="s t-caption">%s</div></div>'
            '<span class="win-close">%s</span></div>' % (x, y, L("Ofis seç", "Choose an office"), L("3 kademe · taşınma bir hafta sürer", "3 tiers · moving takes a week"), ic("close")))


def map_hover(x, y, name, line):
    return '<span class="tip rich mhover" style="left:%dpx;top:%dpx"><span class="tip-t">%s</span><span class="tip-b">%s</span></span>' % (x, y, name, line)


@frame("harita__ofis_karti")
def f_map():
    layer = office("city", 184, 64, 1736, 976) + city_chips()
    loft = next(c for c in CITY if c["office"] == "loft")
    hx, hy = 184 + loft["xy"][0] + 40, 64 + loft["xy"][1] + 60
    fl = (office_card("plaza", 1556, 88, "blocked") + map_panel(208, 952)
          + CURSOR % (hx - 24, hy - 24) + map_hover(hx, hy, L("Depo loft", "Warehouse loft"), L("64 masa · $45,0K/ay", "64 desks · $45.0K/mo")))
    return std_screen(topbar(), layer, fl, rail_html=rail(None))


# ------------------------------------------------------------------ office layer: person tooltip, move countdown, notice stack, ticker closed
@frame("ofis__kisi_ipucu")
def f_ptip():
    sx, sy = plate_xy("ishani", 184, 64, 1736, 976, 875, 557)
    fl = seed_floats() + CURSOR % (sx - 2, sy - 6) + ptip(sx + 16, sy + 16, BUST["selin"], "Selin Kaya", L("Test Mühendisi", "QA Engineer"),
                                                      L("Test ediyor", "Testing"), 22)
    return std_screen(topbar(), office1920(), fl, rail_html=rail(None))


@frame("ofis__tasinma_sayaci")
def f_moving():
    fl = (buildhud(1576, 88) + move_btn(208, 972, "moving")
          + toast(1052, 968, "", "move", s("move_started"), L("İş hanı", "Business block")))
    return std_screen(topbar(V_CHEQUE), office1920("home"), fl, rail_html=rail(None, {}))


@frame("bildirim__yigin")
def f_stack():
    # derived desk: Frank's advisory line on top and Atlas's candidate files as the hidden fifth item (+1); the three
    # inbox rows are the seed stack of every other frame, in the same order
    fl = buildhud(1576, 88) + notices(1920, 1080, SEED_INBOX, frank=True, more=1, hover=1) + move_btn(208, 972)
    return std_screen(topbar(), office1920(), fl, rail_html=rail(None))


@frame("serit__kapali")
def f_ticker_closed():
    layer = office("ishani", 184, 64, 1736, 1016)
    fl = (buildhud(1576, 88) + '<div class="abs" style="right:24px;bottom:24px;width:352px;display:flex;flex-direction:column;gap:8px">%s</div>'
          % notices(0, 0, SEED_INBOX) + move_btn(208, 1012))
    return screen(1920, 1080, [layer, fl, topbar(), rail(None, bottom=0), ticker(collapsed=True, style="z-index:5")])


# ------------------------------------------------------------------ 1536 compact and 2560 ultrawide
def office1536(dim=False):
    return office("i1536", 64, 64, 1472, 760, dim)


@frame("ustbar__1536", 1536, 864, 1.25)
def f_1536():
    fl = buildhud(1536 - 344, 88) + notices(1536, 864, SEED_INBOX) + move_btn(88, 864 - 108)
    return screen(1536, 864, [office1536(), fl, topbar(W=1536, compact=True), rail(None, icons=True), ticker()])


@frame("ustbar__1536_pencere", 1536, 864, 1.25)
def f_1536_win():
    return screen(1536, 864, [office1536(dim=True), ekip(88, 88), topbar(W=1536, compact=True), rail("ekip", icons=True), ticker()])


@frame("ustbar__1536x960", 1536, 960, 1.25)
def f_1536_960():
    # 1920x1200 physical at 125 %: the compact bar and icon rail of 1536x864, the office 96 px taller (1472x856)
    fl = buildhud(1536 - 344, 88) + notices(1536, 960, SEED_INBOX) + move_btn(88, 960 - 108)
    return screen(1536, 960, [office("i1536", 64, 64, 1472, 856), fl, topbar(W=1536, compact=True), rail(None, icons=True), ticker()])


@frame("ustbar__2560", 2560, 1080)
def f_2560():
    fl = buildhud(2560 - 344, 88) + notices(2560, 1080, SEED_INBOX) + move_btn(208, 972)
    return screen(2560, 1080, [office("i2560", 184, 64, 2376, 976, True), fl, ekip(208, 88), topbar(W=2560), rail("ekip"), ticker()])


# ================================================================== sheets
def sheet(num_, title, desc, body, W=1920, H=1080):
    return ('<div class="sheet" style="width:%dpx;height:%dpx"><div class="sh-h"><span class="n t-label">%s</span><span class="t t-h2">%s</span>'
            '<span class="d t-meta">%s</span></div>%s</div>' % (W, H, num_, title, desc, body))


def bar_rows(rows, y0=104, step=104):
    out = []
    for i, (cap, bar, w) in enumerate(rows):
        y = y0 + i * step
        out.append('<div class="sh-lab t-caption" style="left:48px;top:%dpx">%s</div>' % (y, cap))
        out.append('<div class="abs" style="left:0;top:%dpx;width:%dpx;height:64px;overflow:hidden">%s</div>' % (y + 24, w, bar))
    return "".join(out)


def ustbar_rows():
    gate1 = topbar(slot=("gate", "Frank Köseoğlu"), clock=GATE_CLOCK)
    return [
        (L("Normal · Sıradaki: görüşme (14:00 elmas)", "Normal · Up next: a meeting (diamond at 14:00)"), topbar(), 1920),
        (L("Sıradaki: sprint kararı (15:00 elmas)", "Up next: sprint decision (diamond at 15:00)"), topbar(slot=("next", T("next_sprint"), ""), marks=(15,)), 1920),
        (L("Sıradaki: yedek, yuva hiç boş kalmaz", "Up next: the fallback, the slot is never empty"), topbar(slot=("next", T("next_end"), ""), marks=()), 1920),
        (L("Cevap bekliyor · tek karar: alt satır gönderen (gelen kutusu grameri)", "Answer needed · one decision: the subline is the sender (inbox grammar)"), gate1, 1920),
        (L("Cevap bekliyor · birden çok karar", "Answer needed · several decisions"), topbar(slot=("gate", T("gate_n", n=3)), clock=GATE_CLOCK), 1920),
        (L("Kepenk: kasa eksi, RUNWAY hücresi KEPENK olur", "Shutter: cash below zero, the RUNWAY cell becomes SHUTTER"), topbar(V_SHUTTER, slot=("next", T("next_end"), ""), marks=()), 1920),
        (L("Runway ay olarak (Hafta 1): mürekkep", "Runway in months (week 1): ink"), topbar(V_WEEK1, slot=("next", L("Mesai bitimi · 6 saat", "Workday ends · 6 h"), ""), week=1, marks=()), 1920),
        (L("Runway 3 ayın altında: kırmızı (Finans rozeti ve şerit satırıyla aynı eşik)", "Runway under 3 months: red (same threshold as the Finance badge and the ticker line)"), topbar(V_RED), 1920),
        (L("Runway bir ayın altında: hafta olarak, kırmızı", "Runway under a month: in weeks, red"), topbar(V_REDW), 1920),
        (L("Teklif sayacı: uyarı rengi", "Offer countdown: warning colour"), topbar(slot=("next", T("next_offer"), "warn"), phase=2, marks=()), 1920),
        (L("Teklif son haftasında: kırmızı", "Offer in its final week: red"), topbar(slot=("next", T("next_offer_last"), "neg"), phase=2, marks=()), 1920),
        (L("Yolculuk: saat yolculukta duruyor, tuşlar kapalı, amber yok", "Trip: the clock stands still, keys off, no amber"), topbar(slot=("now", T("next_meet")), clock=14, held=True), 1920),
        (L("Sıkışık 1536 mantıksal (ölçek 1,25): marka yalnız logo, kısa tarih", "Compact 1536 logical (125 %): logo only, short date"), topbar(W=1536, compact=True), 1536),
        (L("Sıkışık 1536 · Cevap bekliyor (tek karar)", "Compact 1536 · Answer needed (one decision)"),
         topbar(W=1536, compact=True, slot=("gate", "Frank Köseoğlu"), clock=GATE_CLOCK), 1536),
        (L("En uzun gerçek şirket adı (CompanyCatalog, Godot genişliği 216 > kutu 208): ad üç noktayla kısalır, saat kalır",
           "Longest real company name (CompanyCatalog, Godot width 216 > box 208): the name ellipsizes, the hour stays"),
         topbar(slot=("next", WORST_MEET, ""), godot_fit=True), 1920),
        (L("Aynısı sıkışık 1536'da (kutu 184)", "The same at compact 1536 (box 184)"), topbar(W=1536, compact=True, slot=("next", WORST_MEET, ""), godot_fit=True), 1536),
    ]


WORST_MEET = "14:00 · Metrekare Danışmanlık"   # the longest of the 65 names in company_catalog.gd
TB_SHEET_H = 104 + 16 * 104 + 40               # 16 rows of ustbar_rows()


def overflow():
    """The overflow pass: every slot text against its box, TR and EN, as a Godot Label needs it (measure.py: Chrome
    width x 1.08 + 2). Prints one line per text; the INDEX quotes the result."""
    import measure
    out = []
    for compact in (False, True):
        _, g, _ = kit.tb_layout(compact)
        nx_w = g["gate"] - 2 * g["gate_pad"]
        gs_w = g["gate"] - (g["gate_pad"] + 10 + (10 if compact else 12)) - g["gate_pad"]
        rows = [("t-key", nx_w, t) for k in ("next_meet", "next_offer", "next_offer_last", "next_sprint", "next_end") for t in common.STR[k]]
        rows += [("t-key", nx_w, WORST_MEET)]
        rows += [("t-gate", gs_w, t) for t in common.STR["gate"]]
        rows += [("t-key", gs_w, t) for t in common.STR["gate_n"]] + [("t-key", gs_w, "Frank Köseoğlu"), ("t-key", gs_w, "Metrekare Danışmanlık")]
        items = [("%d%s" % (i, lg), c, t.format(n=3), lg) for i, (c, _, t) in enumerate(rows) for lg in ("tr", "en")]
        got = measure.measure(items)
        for i, (c, box, t) in enumerate(rows):
            w = max(measure.godot(got["%d%s" % (i, lg)]) for lg in ("tr", "en"))
            out.append("%-7s %-7s box %3d  need %3d  %s  %s" % ("1536" if compact else "1920", c, box, w, "fits" if w <= box else "CLIPS", t.format(n=3)))
    print("\n".join(out))


@frame("ustbar__durumlar", 1920, TB_SHEET_H)
def f_tb_sheet():
    rows = ustbar_rows()
    return sheet("Kabuk", L("Üst bar · bütün durumlar", "Top bar · every state"),
                 L("Sabit sütunlar; hafta çubuğu 1920'de 354 px, 1536'da 252 px. Marka bloğu (a) seçeneğiyle.", "Fixed columns; week bar 354 px at 1920, 252 at 1536. Brand block option (a)."),
                 bar_rows(rows), 1920, TB_SHEET_H)


@frame("ustbar__durumlar_en", 1920, TB_SHEET_H, lang="en")
def f_tb_sheet_en():
    return f_tb_sheet()


# ------------------------------------------------------------------ logo: (a) and (b) side by side
def zoombox(inner_html, w, h, k, x, y, inner_w=None, inner_h=None, bg="var(--surface-1)"):
    iw, ih = inner_w or w, inner_h or h
    return ('<div class="zoom abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;background:%s"><div class="inner" style="width:%dpx;height:%dpx;transform:scale(%s)">%s</div></div>'
            % (x, y, w * k + 2, h * k + 2, bg, iw, ih, k, inner_html))


def brand_only(brand, compact=False, company="Unicorn Inc."):
    w = 64 if compact else 184
    return '<div class="topbar" style="position:relative;width:%dpx;height:64px;border-right:1px solid var(--line-1)">%s</div>' % (w, brand_block(brand, compact, 1, company))


@frame("marka__secenekler")
def f_brand():
    out = []
    colx = (48, 984)
    out.append('<div class="sh-lab t-subhead" style="left:48px;top:100px;color:var(--ink-1)">%s</div>' % "(a) Turuncu kare + Project Unicorn")
    out.append('<div class="sh-lab t-subhead" style="left:984px;top:100px;color:var(--ink-1)">%s</div>' % "(b) Oyuncunun şirketi + kendi logosu")
    # 1:1 left part of the real bar
    for x, br in zip(colx, ("a", "b:minimalist")):
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:140px">Üst barın sol yarısı, 1:1</div>' % x)
        out.append('<div class="abs" style="left:%dpx;top:162px;width:888px;height:64px;overflow:hidden;border:1px solid var(--line-1)">%s</div>' % (x, topbar(brand=br)))
    # (a) 3x
    out.append('<div class="sh-lab t-caption" style="left:48px;top:250px">Marka bloğu, 3 kat (vektör büyütme)</div>')
    out.append(zoombox(brand_only("a"), 184, 64, 3, 48, 272))
    out.append('<div class="sh-lab t-caption" style="left:48px;top:490px">Sıkışık 1536: yalnız kare, 3 kat</div>')
    out.append(zoombox(brand_only("a", True), 64, 64, 3, 48, 512))
    out.append('<div class="sh-lab t-caption" style="left:296px;top:490px">1:1</div>')
    out.append('<div class="abs" style="left:296px;top:512px">%s</div>' % brand_only("a", True))
    out.append('<div class="sh-lab t-caption" style="left:48px;top:740px">Bugünkü bar (baseline/office__ishani_11.png, 1:1): eski kare ve şirket adı</div>')
    out.append('<div class="abs" style="left:48px;top:762px;width:420px;height:54px;border:1px solid var(--line-1);background:url(%sbaseline/office__ishani_11.png) 0 0/1920px 1080px"></div>' % REL)
    out.append('<div class="abs sh-note" style="left:48px;top:840px;width:860px">'
               '<b>Ne:</b> eski TopBar\'ın 18 px <b>LogoSquare</b> karesi (ACCENT_CHROME #FFA028) 64 px bara göre 20 px; yanında oyunun adı "Project Unicorn" '
               '(Barlow Condensed 700, 20). Altında evre ve üç nokta kalır. Kare marka sabiti, UI amberi değil: amber kuralı onu saymaz (#FFA028 amber #F2B53A\'dan ayrı). '
               '<b>Artı:</b> her koşuda aynı, oyunun kimliği; açılıştaki "PROJECT UNICORN" damgasıyla aynı ad. <b>Eksi:</b> oyuncunun kurduğu şirket barda hiç görünmez '
               '(adı yalnız pencerelerde ve gazetede); turuncu kare amberin yanında ikinci bir sıcak leke.</div>')
    # (b) three styles 2x
    styles = [("minimalist", L("Minimalist (varsayılan)", "Minimalist (default)")), ("tech", L("Tekno", "Tech")), ("playful", L("Oyuncul", "Playful"))]
    for i, (st, lab) in enumerate(styles):
        y = 272 + i * 160
        out.append('<div class="sh-lab t-caption" style="left:984px;top:%dpx">%s · 2 kat</div>' % (y - 22, lab))
        out.append(zoombox(brand_only("b:" + st), 184, 64, 2, 984, y))
        out.append('<div class="abs" style="left:1376px;top:%dpx">%s</div>' % (y + 32, brand_only("b:" + st)))
    out.append('<div class="sh-lab t-caption" style="left:1376px;top:250px">1:1</div>')
    # compact emblems + a different company name
    out.append('<div class="sh-lab t-caption" style="left:1600px;top:250px">Sıkışık 1536, 1:1</div>')
    for i, (st, _) in enumerate(styles):
        out.append('<div class="abs" style="left:1600px;top:%dpx">%s</div>' % (304 + i * 160, brand_only("b:" + st, True)))
    out.append('<div class="sh-lab t-caption" style="left:984px;top:730px">Başka bir ad: "Synaptik" (ONB_COMPANY_PLACEHOLDER örneği), Ciddi stili</div>')
    out.append('<div class="abs" style="left:984px;top:752px">%s</div>' % brand_only("b:serious", False, "Synaptik"))
    out.append('<div class="abs" style="left:1184px;top:752px">%s</div>' % brand_only("b:serious", True, "Synaptik"))
    out.append('<div class="abs sh-note" style="left:984px;top:836px;width:888px">'
               '<b>Ne:</b> açılışta seçilen <b>LogoEmblem</b> (logo_emblem.gd, GameState.logo_style) 32 px ve şirketin adı (GameState.company_name; '
               'tohumda "Unicorn Inc."), 108 px\'te üç noktayla kısalır. Şekil ve harf renkleri bugünkü kod gibi: ACCENT_CHROME, CREAM, DIALOGUE_BG; harf temanın '
               'varsayılan yüzü, r × 1,05. <b>Artı:</b> oyuncunun şirketi her an önünde; açılıştaki seçim oyunda bir karşılık bulur. <b>Eksi:</b> dört stil, '
               'dört farklı turuncu yoğunluğu (oyuncul dolu turuncu kare amber birincil düğmeyle yarışır); oyunun kendi adı barda yok.</div>')
    return sheet("Karar 14", L("Marka bloğu · iki seçenek", "Brand block · two options"),
                 L("Erdem seçer. Bütün kabuk çerçeveleri şimdilik (a) ile; (b) tam ekranda: marka__b_kabukta.png.", ""), "".join(out))


# ------------------------------------------------------------------ rail sheet
def rail_box(x, y, h, html, w=184):
    return '<div class="abs" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;overflow:visible">%s</div>' % (x, y, w, h, html)


@frame("ray__durumlar")
def f_rail():
    H = 900
    st = "top:0;bottom:0;"
    out = []
    cols = [
        (48, 184, L("Etiketli · normal (tohum)", "Labelled · normal (seed)"), rail("ekip", style=st)),
        (288, 184, L("Karar bekliyor · Finans'ta kenar", "Decision waiting · hover on Finans"),
         rail(None, dict(B14, olaylar=("gate", "")), hover="finans", style=st)),
        (528, 184, L("Klavye odağı (F6 ile raya)", "Keyboard focus (F6 into the rail)"), rail("olaylar", focus="urun", style=st)),
        (768, 64, L("Simge kipi (1536)", "Icon mode (1536)"), rail("ekip", icons=True, style=st)),
        (888, 64, L("Simge kipi · karar", "Icon mode · decision"), rail(None, dict(B14, olaylar=("gate", "")), icons=True, hover="satis", style=st)),
    ]
    for x, w, cap, html in cols:
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:100px;width:%dpx">%s</div>' % (x, w + 56 if w == 64 else w, cap))
        out.append(rail_box(x, 152, H - 152, '<div style="position:relative;width:%dpx;height:%dpx">%s</div>' % (w, H - 152, html), w))
    # icon-mode tooltip for the hovered Satış row (row 2: top 12 + 48)
    out.append('<span class="tip rail-tip" style="left:%dpx;top:%dpx"><span class="tip-t">%s</span></span>' % (888 + 64 + 8, 152 + 12 + 48 + 10, T("tab_sales")))
    # 2x row states
    out.append('<div class="sh-lab t-label" style="left:1056px;top:100px;color:var(--ink-2)">%s</div>' % L("Satır durumları, 2 kat", "Row states, 2x"))
    states = [
        ("rr", L("boşta", "idle"), "finans", None),
        ("rr is-hover", L("üstünde: kenar", "hover: a border"), "finans", None),
        ("rr is-active", L("etkin: zemin, işaret, ink-1", "active: ground, marker, ink-1"), "ekip", ("danger", "1")),
        ("rr kfocus", L("odak: 2 px halka", "focus: 2 px ring"), "urun", None),
        ("rr is-locked", L("kilitli: yalnız ikon ve ad soluk", "locked: icon and name off"), "pazarlama", "lock"),
        ("rr", L("sayılı rozet, nötr", "numbered badge, neutral"), "arge", ("count", "2")),
        ("rr", L("karar bekliyor: amber nokta", "decision waiting: amber dot"), "olaylar", ("gate", "")),
    ]
    names = dict(RAIL)
    for i, (cls, cap, key, b) in enumerate(states):
        y = 140 + i * 112
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(names[key]), T("soon"))
            right = ""
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(names[key])
            right = '<span class="badge badge-%s">%s</span>' % b if b else ""
        row = '<div class="%s" style="width:184px">%s%s%s</div>' % (cls, '<span class="rr-ic">%s</span>' % ic(key, 24), txt, right)
        inner = '<div style="background:var(--surface-1);width:184px;height:48px;position:relative">%s</div>' % row
        out.append(zoombox(inner, 184, 48, 2, 1056, y, bg="var(--surface-1)"))
        out.append('<div class="sh-lab t-caption" style="left:1440px;top:%dpx;width:420px">%s</div>' % (y + 38, cap))
    out.append('<div class="abs sh-note" style="left:48px;top:%dpx;width:1000px">%s</div>' % (H + 16, L(
        "Ray opak, ofisin üstüne biner. Rozetler bugünkü kaynaklardan: Satış ve Ekip dikkat sayısı (kırmızı), Ar-Ge sayısı (nötr), Finans runway 3 ayın altında (kırmızı, "
        "FinanceSystem.RUNWAY_ALERT_MONTHS[0]), Olaylar karar beklerken amber nokta. Pazarlama bugün her yapıda kilitli (TABS lock \"ea\"); gerekçe \"Yakında\". "
        "Simge kipinde ad ipucuya, sayılı rozet ikonun köşesine, kilit 12 px köşeye iner.", "")))
    return sheet("Kabuk", L("Ray · bütün durumlar", "Rail · every state"), L("184 px etiketli, 1536'da 64 px simge kipi.", ""), "".join(out))


# ------------------------------------------------------------------ ticker sheet
# ------------------------------------------------------------------ rail by build: Pazarlama's "ea" gate
@frame("ray__yapilar")
def f_rail_builds():
    H = 860
    st = "top:0;bottom:0;"
    ea_why = L("Erken Erişim'de", "In Early Access")  # ENDING_BADGE_EA, recased
    out = []
    cols = [
        (48, 184, L("Demo · bugün: kilitli, \"Yakında\"", "Demo · today: locked, \"Soon\""), rail(None, style=st)),
        (288, 184, L("Demo · öneri: kilitli, \"Erken Erişim'de\"", "Demo · proposal: locked, \"In Early Access\""), rail(None, style=st, lock_why=ea_why)),
        (528, 184, L("EA: kapı açık, Pazarlama boşta", "EA: the gate open, Pazarlama idle"), rail(None, style=st, build="ea")),
        (768, 184, L("EA: Pazarlama etkin", "EA: Pazarlama active"), rail("pazarlama", style=st, build="ea")),
        (1008, 64, L("Simge · demo", "Icons · demo"), rail(None, icons=True, style=st)),
        (1128, 64, L("Simge · EA", "Icons · EA"), rail(None, icons=True, style=st, build="ea")),
    ]
    for x, w, cap, html in cols:
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:100px;width:%dpx">%s</div>' % (x, 220 if w == 184 else 110, cap))
        out.append(rail_box(x, 152, H - 152, '<div style="position:relative;width:%dpx;height:%dpx">%s</div>' % (w, H - 152, html), w))
    names = dict(RAIL)
    out.append('<div class="sh-lab t-label" style="left:1272px;top:100px;color:var(--ink-2)">%s</div>' % L("Pazarlama satırı, 2 kat", "The Pazarlama row, 2x"))
    rows = [("rr is-locked", T("soon"), L("demo · bugün", "demo · today")), ("rr is-locked", ea_why, L("demo · öneri", "demo · proposal")),
            ("rr", None, L("EA · boşta", "EA · idle")), ("rr is-hover", None, L("EA · üstünde", "EA · hover"))]
    for i, (cls, why, cap) in enumerate(rows):
        y = 140 + i * 112
        sub = '<span class="rr-why t-micro">%s</span>' % why if why else ""
        row = ('<div class="%s" style="width:184px"><span class="rr-ic">%s</span><span class="rr-txt"><span class="rr-n t-nav">%s</span>%s</span></div>'
               % (cls, ic("pazarlama", 24), T(names["pazarlama"]), sub))
        out.append(zoombox('<div style="background:var(--surface-1);width:184px;height:48px;position:relative">%s</div>' % row, 184, 48, 2, 1272, y))
        out.append('<div class="sh-lab t-caption" style="left:1656px;top:%dpx;width:220px">%s</div>' % (y + 38, cap))
    out.append('<div class="abs sh-note" style="left:1272px;top:600px;width:600px">%s</div>' % L(
        "Pazarlama'nın kilidi bir yapı kapısıdır: UiTokens.TABS satırında lock \"ea\", LeftTabs._is_locked. Demo yapısında kapı kapalı, satır soluk ve "
        "gerekçesi altında; bugünkü gerekçe SYS_SOON \"Yakında\" yalnız \"bu yapıda yok\" der. Öneri: kapı adını söyleyen \"Erken Erişim'de\" "
        "(ENDING_BADGE_EA, cümle düzeninde; son ekranının demo rozetiyle aynı söz). EA yapısında (--build=ea) kapı açık: satır öteki sekmeler gibi "
        "boşta, üstünde ve etkin olur; Pazarlama sayfası yer tutucudur (plan madde 13). Simge kipinde kilit 12 px köşe ikonu, EA'da yok. "
        "Kabuk sorusu 15 açık: EA'da sayfa hazır değilse satır EA'da da mı kilitli kalır?", ""))
    return sheet("Kabuk", L("Ray · yapıya göre Pazarlama", "Rail · Pazarlama by build"), L("Demo ve EA yan yana; rozetler tohumdan.", ""), "".join(out), 1920, 1080)


@frame("serit__durumlar", 1920, 860)
def f_ticker():
    out = []
    rows = [
        (L("Açık · tohum akışı (yayın adları kendi tokenında)", "Open · the seed stream (outlet names in their own token)"), ticker()),
        (L("Aç/kapa hücresinin üstünde: kenar", "Hover on the toggle: a border"), ticker(hover=True)),
        (L("Canlı satırlar önde: şirket içinden (İçeriden) ve bir kişinin satırı", "Live lines first: from inside the company and a person's line"),
         ticker(live=[live_runway(), ("person", "Elif Demir", L("Nasıl geçti?", "How did it go?"))])),
    ]
    for i, (cap, html) in enumerate(rows):
        y = 104 + i * 92
        out.append('<div class="sh-lab t-caption" style="left:48px;top:%dpx">%s</div>' % (y, cap))
        out.append('<div class="abs" style="left:0;top:%dpx;width:1920px;height:40px">%s</div>' % (y + 24, html))
    # collapsed in context: rail foot, the 57x40 tab, the office gaining 40 px
    y = 104 + 3 * 92
    out.append('<div class="sh-lab t-caption" style="left:48px;top:%dpx">%s</div>' % (y, L("Kapalı: 57×40 düğme sol altta, ray sona kadar iner, ofis 40 px kazanır (sol alt köşe, 1:1)", "Closed: the 57x40 tab bottom left, the rail runs to the bottom, the office gains 40 px")))
    inner = ('<div class="screen" style="width:1920px;height:1080px">%s%s%s%s</div>'
             % (office("ishani", 184, 64, 1736, 1016), move_btn(208, 1012), rail(None, bottom=0), ticker(collapsed=True, style="z-index:5")))
    out.append('<div class="abs" style="left:48px;top:%dpx;width:720px;height:300px;overflow:hidden;border:1px solid var(--line-2)">'
               '<div class="abs" style="left:0;top:-780px">%s</div></div>' % (y + 24, inner))
    inner_h = inner.replace('class="tk-toggle"', 'class="tk-toggle is-hover"')
    out.append('<div class="sh-lab t-caption" style="left:800px;top:%dpx">%s</div>' % (y, L("Kapalı, üstünde (2 kat)", "Closed, hover (2x)")))
    out.append('<div class="zoom abs" style="left:800px;top:%dpx;width:362px;height:242px"><div class="inner" style="transform:scale(2)">'
               '<div style="position:relative;width:180px;height:120px;overflow:hidden"><div class="abs" style="left:0;top:-960px">%s</div></div></div></div>' % (y + 24, inner_h))
    # 2x zoom of the open ticker start
    out.append('<div class="sh-lab t-caption" style="left:1200px;top:%dpx">%s</div>' % (y, L("Açık, başlangıç (2 kat)", "Open, the start (2x)")))
    out.append('<div class="zoom abs" style="left:1200px;top:%dpx;width:672px;height:82px"><div class="inner" style="transform:scale(2)">'
               '<div style="position:relative;width:336px;height:40px;overflow:hidden">%s</div></div></div>' % (y + 24, ticker(live=[live_runway()])))
    out.append('<div class="abs sh-note" style="left:1200px;top:%dpx;width:672px">%s</div>' % (y + 130, L(
        "Yayın adı 600 kendi tokenında, başlık ink-3, ayraç \"   ·   \" ink-4, sağda 48 px solma. Canlı satırların kaynağı (İçeriden, kişi adı) yayın değil: ink-1, "
        "renk yok. TICKER_SRC_INTERNAL büyük harften cümle düzenine (\"İçeriden\"). Kapalı ya da açık oyuncu ayarıdır (SPEC §10).", "")))
    # EN
    y2 = y + 360
    set_lang("en")
    try:
        en = ticker(live=[live_runway()])
    finally:
        set_lang("tr")
    out.append('<div class="sh-lab t-caption" style="left:48px;top:%dpx">EN</div>' % y2)
    out.append('<div class="abs" style="left:0;top:%dpx;width:1920px;height:40px" lang="en">%s</div>' % (y2 + 24, en))
    return sheet("Kabuk", L("Haber şeridi · açık ve kapalı", "News ticker · open and closed"), L("40 px, surface-0.", ""), "".join(out), 1920, 860)


# ------------------------------------------------------------------ BuildHUD sheet
def office_bg(x, y, w, h, px, py):
    """A crop of the dimmed-off ishani plate as the ground behind a float sample."""
    return ('<div class="abs cell-box" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx;background:url(%sart/office_safe_1920_noicons.png) -%dpx -%dpx/1736px 976px"></div>'
            % (x, y, w, h, REL, px, py))


@frame("buildhud__durumlar")
def f_hud():
    out = []
    samples = [
        (L("Tohum: doğrulanmış hata yok, düğme kapalı ve gerekçesi yanında", "Seed: no confirmed bugs, the button is off with its reason"), buildhud(0, 0, "seed")),
        (L("Doğrulanmış 3: Düzeltme başlat açık (üstünde)", "Confirmed 3: Start a fix run is open (hover)"), buildhud(0, 0, "ready", hover=True)),
        (L("Koşu sürüyor: 5 hatanın 2'si çözüldü, %40; düğme Koşuyu bitir", "Fix run under way: 2 of 5 fixed, 40 %; the button ends the run"), buildhud(0, 0, "run")),
        (L("Bölünmüş odak: masadaki biri iki işte", "Split focus: someone on the desk is on two jobs"), buildhud(0, 0, "ready", split=True)),
        (L("Sprint otomatik başladı: üst bardan buraya, ink-3 satır", "Sprint started automatically: from the top bar to here, an ink-3 line"), buildhud(0, 0, "seed", auto=True)),
    ]
    for i, (cap, html) in enumerate(samples):
        x = 48 + (i % 3) * 432
        y = 104 + (i // 3) * 300
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:%dpx;width:400px">%s</div>' % (x, y, cap))
        out.append(office_bg(x, y + 44, 400, 220, 1300, 30))
        out.append('<div class="abs" style="left:%dpx;top:%dpx">%s</div>' % (x + 40, y + 64, html.replace("float bh abs", "float bh")))
    # research card under the BuildHUD, running and paused (right column)
    x, y = 1344, 104
    out.append('<div class="sh-lab t-caption" style="left:%dpx;top:%dpx;width:528px">%s</div>' % (x, y, L("Araştırma kartı BuildHUD'ın altında: sürüyor (ata üstünde), sonra duraklamış (duraklat bağı gizli, yalnız ata)", "Research card under the BuildHUD: running (hover on assign), then paused (the pause link hides, assign stays)")))
    out.append(office_bg(x, y + 44, 528, 560, 1100, 30))
    out.append('<div class="abs" style="left:%dpx;top:%dpx;display:flex;flex-direction:column;gap:8px">%s%s</div>'
               % (x + 104, y + 64, buildhud(0, 0, "seed").replace("float bh abs", "float bh"), research(0, 0, hover="assign").replace("float rb abs", "float rb")))
    out.append('<div class="abs" style="left:%dpx;top:%dpx">%s</div>' % (x + 104, y + 440, research(0, 0, paused=True).replace("float rb abs", "float rb")))
    out.append('<div class="abs sh-note" style="left:48px;top:720px;width:1240px">%s</div>' % L(
        "<b>Pencere kuralı.</b> BuildHUD pencerelerin altında çizilir; açık pencerenin dikdörtgenine değerse gizlenir (araştırma kartı, bildirim yığını ve Ofisi taşı da). "
        "1920'de Ekip (1352) 1560'ta biter, kart 1576'da başlar: görünür, 16 px boşluk (kabuk__pencere_acik). 1536'da Ekip 88 ile 1440 arası, kart 1192'de: gizli "
        "(ustbar__1536_pencere). 2560'ta pencereler solda kalır, kart sağ kenarda (ustbar__2560). Harita açıkken ve yolculukta gizli. "
        "<b>Veri.</b> Tohum: Unicorn Inc. v1, Doğrulanmış 0 (SupportSystem.fix_run_refusal = no_confirmed_bugs). Doğrulanmış 3 ve koşu türetildi: fill = çözülen / "
        "(açık + çözülen) = 2 / 5 (build_bar_model.gd). Araştırma: Veri Modeli (rnd_tree.json, efor 40), Elif Demir atanmış: ürün 7 × 8/8 saat × 7 gün = 49/hafta; %35'te "
        "26 efor kalır, ~1 hafta. Duraklama gerekçesi RND_PAUSED_BUILD.", ""))
    return sheet("Kabuk", L("BuildHUD · DESTEK kartı ve araştırma", "BuildHUD · the SUPPORT card and research"), L("320 px, sağ üstte (W−344, 88).", ""), "".join(out))


# ------------------------------------------------------------------ toast sheet
@frame("toast__durumlar")
def f_toasts():
    out = []
    rows = [
        ("ok", "check", T("saved"), T("saved_sub"), L("F5 hızlı kayıt", "F5 quicksave")),
        ("warn", "save", T("not_saved"), s("not_saved_sub"), L("F5, karar beklerken", "F5 while a decision waits")),
        ("ok", "load", s("loaded"), s("loaded_sub"), L("F9 hızlı yükleme", "F9 quickload")),
        ("hold", "pause", T("locked_clock"), s("clock_sub"), L("Space ya da 1-4, saat kilitliyken (en çok 3 sn'de bir)", "Space or 1-4 while the clock is held")),
        ("", "move", s("move_started"), L("İş hanı", "Business block"), L("Taşınma başladı (öneri: bugünkü OFFICE_TOAST_MOVED \"Yeni ofis: {name}\" taşınmanın başında varış gibi okunuyor)", "A move starts")),
        ("", "calendar", s("postponed"), s("postponed_sub"), L("Satış görüşmesi ertelendi (MEETING_POSTPONED ikiye bölündü)", "A sales meeting postponed")),
        ("", "calendar", s("postponed"), s("postponed_vc_sub"), L("VC görüşmesi ertelendi (MEETING_POSTPONED_VC)", "A VC meeting postponed")),
    ]

    def col(x, lang):
        set_lang(lang)
        try:
            items = []
            for i, (kind, g, h, sub, cap) in enumerate(rows if lang == "tr" else [
                    ("ok", "check", T("saved"), T("saved_sub"), ""), ("warn", "save", T("not_saved"), s("not_saved_sub"), ""),
                    ("ok", "load", s("loaded"), s("loaded_sub"), ""), ("hold", "pause", T("locked_clock"), s("clock_sub"), ""),
                    ("", "move", s("move_started"), L("İş hanı", "Business block"), ""), ("", "calendar", s("postponed"), s("postponed_sub"), ""),
                    ("", "calendar", s("postponed"), s("postponed_vc_sub"), "")]):
                y = 140 + i * 84
                if cap:
                    items.append('<div class="sh-lab t-caption" style="left:%dpx;top:%dpx">%s</div>' % (x, y, cap))
                items.append('<span class="toast %s" style="position:absolute;left:%dpx;top:%dpx"><span class="well">%s</span><span class="head">%s</span><span class="sub">%s</span></span>'
                             % (kind, x, y + 22, ic(g), h, sub))
            return "".join(items)
        finally:
            set_lang("tr")
    out.append('<div class="sh-lab t-label" style="left:48px;top:104px;color:var(--ink-2)">TR</div>' + col(48, "tr"))
    out.append('<div class="sh-lab t-label" style="left:984px;top:104px;color:var(--ink-2)">EN</div><div lang="en">%s</div>' % col(984, "en"))
    out.append('<div class="abs sh-note" style="left:48px;top:740px;width:1824px">%s</div>' % L(
        "Tek bileşen: 48 px, surface-4, küçük kesik köşe, 32 px ikon kuyusu, kalın baş + ink-3 alt. Ofisin ortasında, şeridin 24 px üstünde; bir seferde bir tane "
        "(200 ms gir, 2400 ms dur, saat kilidinde 3200, 200 ms çık). İkon rengi anlamı taşır: olumlu (kaydedildi, yüklendi), uyarı (kaydedilmedi), amber yalnız saat kilidi "
        "(zaman durumu), ötekiler ink-3. Bugünkü üç ayrı uygulama (OfficeHud, MeetingInvite, son ekranı paylaşımı) bunda birleşir. "
        "Saat kilidi alt satırı SPEC'in \"Önce {başlık} cevapla.\" kalıbı yerine bekleyen kararın genel cümlesi: kart başlığı (\"Frank'in teklifi\") yükleme ekiyle "
        "(\"teklifini\") yer tutucuya giremez.", ""))
    return sheet("Kabuk", L("Tek toast · bütün kullanımlar", "One toast · every use"), "", "".join(out))


# ------------------------------------------------------------------ move button sheet
@frame("ofis__tasi_dugmesi", 1920, 840)
def f_movebtn():
    out = []
    samples = [
        (L("Boşta", "Idle"), "idle"), (L("Üstünde: kenar", "Hover: a border"), "hover"),
        (L("Frank'in çekinden sonra nefes alır (tepe: ölçek 1,04 + üstünde kenarı; opaklık 1, yüzen öğe opaktır)", "Breathes after Frank's cheque (peak: scale 1.04 + the hover border; alpha stays 1)"), "breath"),
        (L("Karar beklerken kapalı, gerekçesi yanında", "Off while a decision waits, its reason beside it"), "held"),
        (L("Taşınırken sayaç etiketi", "Moving: the countdown tag"), "moving"),
    ]
    for i, (cap, st) in enumerate(samples):
        y = 104 + i * 128
        out.append('<div class="sh-lab t-caption" style="left:48px;top:%dpx;width:700px">%s</div>' % (y, cap))
        out.append(office_bg(48, y + 26, 640, 92, 0, 860))
        out.append('<div class="abs" style="left:72px;top:%dpx">%s</div>' % (y + 50, move_btn(0, 0, st).replace("float fbtn", "float fbtn").replace('style="left:0px;top:0px"', 'style="position:relative"')))
        out.append(zoombox('<div style="position:relative;padding:4px">%s</div>' % move_btn(0, 0, st).replace('style="left:0px;top:0px"', 'style="position:relative"'),
                           420, 52, 2, 760, y + 22, bg="var(--surface-0)"))
    out.append('<div class="abs sh-note" style="left:48px;top:760px;width:1600px">%s</div>' % L(
        "44 px yüzen düğme, (ray + 24, H − 108); 1536'da (88, 756). Harita açıkken haritanın Ofis seç paneli bu köşeyi alır, yolculukta gizli. Taşınma bir hafta "
        "(OfficeConstants.MOVE_WEEKS): OFFICE_MOVING_BADGE ikiye bölündü, İzinde gibi büyük harfli etiket + düz metin süre. Karar beklerken taşınma ve harita kapalı (karar 5); gerekçe kapı yuvasının etiketi, \"Cevap bekliyor\". "
        "Taşınma başlayınca toast \"Taşınma başladı · İş hanı\" (ofis__tasinma_sayaci). Nefes bugün opaklığı 0,8'e indiriyor (office_hud.gd PULSE_ALPHA); "
        "yüzen öğe opak kuralı için tepe ölçek 1,04 ve üstünde kenarıyla çizildi, opaklık 1.", ""))
    return sheet("Ofis katmanı", L("Ofisi taşı · düğme durumları", "Move the office · button states"), "", "".join(out), 1920, 840)


# ------------------------------------------------------------------ office card states sheet
@frame("harita__kart_durumlari")
def f_cards():
    out = []
    cards = [
        ("ishani", "current", L("Mevcut ofis (tohum: İş hanı)", "The current office (seed: İş hanı)")),
        ("ishani", "movable", L("Evden ilk taşınma: şartlar tamam (Frank'in çeki sonrası kasa $35.000)", "First move from home: requirements met")),
        ("ishani", "moving", L("Taşınma sürerken", "While the move runs")),
        ("loft", "blocked", L("Yüksek kademe: üç şart da tutmuyor", "High tier: all three unmet")),
    ]
    for i, (oid, sit, cap) in enumerate(cards):
        x = 48 + i * 372
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:100px;width:340px">%s</div>' % (x, cap))
        out.append('<div class="abs" style="left:%dpx;top:140px">%s</div>' % (x, office_card(oid, 0, 0, sit).replace('class="mcard" style="left:0px;top:0px"', 'class="mcard" style="position:relative"')))
    out.append('<div class="sh-lab t-caption" style="left:1552px;top:100px;width:320px">%s</div>' % L("Haritada üstünde kartı (bina adı ve bir satır)", "Map hover card"))
    out.append('<div class="abs" style="left:1552px;top:140px;display:flex;flex-direction:column;gap:12px;align-items:flex-start">%s%s%s</div>'
               % (map_hover(0, 0, L("Plaza katı", "Plaza floor"), L("36 masa · $18,0K/ay", "36 desks · $18.0K/mo")).replace('style="left:0px;top:0px"', 'style="position:relative"'),
                  map_hover(0, 0, L("İş hanı", "Business block"), L("10 masa · $2,5K/ay", "10 desks · $2.5K/mo")).replace('style="left:0px;top:0px"', 'style="position:relative"'),
                  map_hover(0, 0, L("Ev", "Home"), L("Kurucunun dairesi", "The founder's flat")).replace('style="left:0px;top:0px"', 'style="position:relative"')))
    out.append('<div class="abs sh-note" style="left:1552px;top:420px;width:320px">%s</div>' % L(
        "Değerler OfficeConstants.CATALOG; şartlar requirement_state. Sıfır bedel boş hücre. Durum etiketi: mevcut nötr, taşınabilir olumlu, şart tutmuyor çerçeve (tehlike değil). "
        "Düğme metni bugünkü anahtarlar: Taşın · {para}, Buradasınız, Taşınıyor · 1 hafta, {n} şart karşılanmadı. Oda adları dört kelimeye varabildiği için büyük harf değil. "
        "<b>Açık:</b> Ev kartı (geri dönüş yok) bugün \"0 şart karşılanmadı\" basar; çizilmedi.", ""))
    return sheet("Ofis katmanı", L("Harita · ofis kartı durumları", "City map · office card states"), L("340 px belge kartı, sağ üstte.", ""), "".join(out))


# ------------------------------------------------------------------ tooltip sheet
@frame("ipucu__cesitleri", 1920, 520)
def f_tips():
    out = []
    people = [
        ("selin", 875, 557, "Selin Kaya", L("Test Mühendisi", "QA Engineer"), L("Test ediyor", "Testing"), 22, L("Riskte: tek tehlike satırı", "At risk: one danger line")),
        ("deniz", 814, 592, "Deniz Arslan", "UX/UI Designer", L("Çizim yapıyor", "Sketching"), None, L("Normal: ad, unvan (CSV), iş", "Normal: name, title (CSV), activity")),
        ("burak", 711, 447, "Burak Şahin", L("Satış Temsilcisi", "Sales Representative"), L("Müşteriyle görüşüyor", "On a customer call"), None, L("Telefonda", "On the phone")),
    ]
    for i, (k, hx, hy, n, r, st, risk, cap) in enumerate(people):
        x = 48 + i * 560
        out.append('<div class="sh-lab t-caption" style="left:%dpx;top:100px">%s</div>' % (x, cap))
        icon = next(p for p in heads("ishani") if p["name"].startswith(n.split()[0]))
        ix, iy = icon["icon_xy"][0] - (hx - 150), icon["icon_xy"][1] - (hy - 110)
        img = ('<img class="head-ic" src="%ssystem/icons/office/%s.svg" style="left:%dpx;top:%dpx;width:32px;height:32px">'
               % (REL, HEAD_FILE[icon["status"]], ix - 16, iy - 16))
        out.append('<div class="abs cell-box" style="left:%dpx;top:124px;width:520px;height:260px;background:url(%sart/office_safe_1920_noicons.png) -%dpx -%dpx/1736px 976px">%s%s%s</div>'
                   % (x, REL, hx - 150, hy - 110, img, CURSOR % (148, 104), ptip(166, 126, BUST[k], n, r, st, risk)))
    out.append('<div class="abs sh-note" style="left:48px;top:404px;width:1700px">%s</div>' % L(
        "Bugün tek satır \"{ad} · {iş}\" (OFFICE_TOOLTIP). Sistem s3'ün önerisi: 32 px yüz, ad, unvan · iş (OFFICE_ACT_*), yalnız riskte tehlike satırı. Konum imleç + 16 px, "
        "ofis sınırına kenetli; surface-0 zemin, opak.", ""))
    return sheet("Ofis katmanı", L("İpuçları · kişi", "Tooltips · person"), "", "".join(out), 1920, 520)


# ================================================================== build
def build(names=None):
    os.makedirs(BUILD, exist_ok=True)
    for name, (fn, w, h, scale, lang) in FRAMES.items():
        if names and name not in names:
            continue
        set_lang(lang)
        try:
            body = fn()
        finally:
            set_lang("tr")
        with open(os.path.join(BUILD, name + ".html"), "w", encoding="utf-8") as f:
            f.write(page(body, w, h, lang=lang))
        print(name, w, h, scale or 1)


def sizes():
    for name, (fn, w, h, scale, lang) in FRAMES.items():
        print(name, w, h, scale or 1)


if __name__ == "__main__":
    if sys.argv[1:] == ["--sizes"]:
        sizes()
    elif sys.argv[1:] == ["--overflow"]:
        overflow()
    else:
        build(sys.argv[1:] or None)
