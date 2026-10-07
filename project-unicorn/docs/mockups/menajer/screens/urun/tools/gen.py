"""Ürün rev 7 in Menajer Masası: builds every frame of group "urun" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css, icons,
crop rule, top bar geometry) is read from ../../../system through the copies in syskit/, whose caches live in
this folder, so nothing is written into the system folder. Player-visible text comes from
localization/strings.csv (read only) or from the fixture (scripts/debug/product_fixtures.gd, TR and EN pairs);
strings this group proposes are in NEW below and listed in INDEX.md.
"""
import csv
import datetime
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
from common import T, ic, set_lang  # noqa: E402
from kit import at, tag, pill, stamp  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src
common.ICON_FILES.update({"sparkle": "util/sparkle"})

LANG = "tr"


def L(tr, en):
    return tr if LANG == "tr" else en


# ------------------------------------------------------------------ CSV (read only)
CSV = {}
with open(os.path.join(MEN, "..", "..", "..", "localization", "strings.csv"), encoding="utf-8", newline="") as _f:
    for _row in csv.reader(_f):
        if len(_row) >= 3:
            CSV[_row[0]] = (_row[1], _row[2])


# Keys this group proposes to recase (INDEX "yeniden harf"): the CSV stores these sprint labels in caps typed by hand
# ("SPRINT", dotless), while every other caps label comes from Fmt.upper. Drawn from sentence case, the page's
# text-transform (lang tr) is Fmt.upper, so the head, the tab and the card tag all read SPRİNT (one path, finding 19).
RECASE = {
    "PRODUCT_SPRINT_TITLE": ("Sprint {n}", "Sprint {n}"),
    "PRODUCT_VIEW_SPRINT": ("Sprint", "Sprint"),
    "PRODUCT_THIS_SPRINT": ("Bu sprint", "This sprint"),
    "PRODUCT_AT_SPRINT_END": ("Sprint sonunda", "At sprint end"),
    "HR_SEARCH_START": ("İşe alım başlat", "Start recruitment"),  # SPEC §13 recase; the plus becomes an icon
}


def K(key, **kw):
    tr, en = RECASE.get(key) or CSV[key]
    v = tr if LANG == "tr" else en
    return v.format(**kw) if kw else v


def KC(key, n, **kw):
    """Fmt.count_key: the _ONE twin when n == 1."""
    k = key + "_ONE" if n == 1 and key + "_ONE" in CSV else key
    return K(k, n=n, **kw)


def money(n):
    s = "{:,}".format(n)
    return "$" + (s.replace(",", ".") if LANG == "tr" else s)


# ------------------------------------------------------------------ strings this group proposes (EN first; INDEX.md)
NEW = {
    "version_k": ("Version", "Sürüm"),
    "decision_in_inbox": ("Waiting in Events", "Olaylar'da bekliyor"),
    "go_decision": ("Go to the decision", "Karara git"),
    "apply_lead": ("Apply", "Uygula"),
    "release_hold": ("Paused while the release note is open", "Sürüm notu açıkken oyun durur"),
    "over_note": ("Over capacity · {n} cards carry over", "Kapasite aşıldı · {n} kart devreder"),
    "over_note_one": ("Over capacity · {n} card carries over", "Kapasite aşıldı · {n} kart devreder"),
    "add_closed": ("Adding closes above 125%", "%125'in üstünde kart eklenmez"),
    "done_stamp": ("Done", "Bitti"),
    # Sıradaki slot for a sprint decision: sprint decisions are papers (one week), so the slot names the week, not
    # an hour; same shape as SPEC §13 "Offer · final week" (proposed SPEC §10 amendment, INDEX)
    "slot_sprint": ("Sprint decision · final week", "Sprint kararı · bu hafta son"),
}


def s(key, **kw):
    en, tr = NEW[key]
    v = tr if LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ dates (GameState.get_date_dict: day 1 = 1 Jan 2026, a tick = 7 days)
MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


def _d(week):
    d = datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))
    return d, (d - datetime.date(d.year, 1, 1)).days // 7 + 1


def date(week):
    d, w = _d(week)
    return L("Hafta %d · %s %d" % (w, MON_TR[d.month - 1], d.year), "Week %d · %s %d" % (w, MON_EN[d.month - 1], d.year))


def date_c(week):
    d, w = _d(week)
    return L("H%d · %s" % (w, MON_TR[d.month - 1][:3]), "W%d · %s" % (w, MON_EN[d.month - 1][:3]))


# ------------------------------------------------------------------ people and faces
FACE = {
    "founder": os.path.join(MEN, "portraits", "founder_01.png"),
    "frank": os.path.join(MEN, "portraits", "frank_cand_a.png"),
    "elif": os.path.join(MEN, "art", "bust_elif.png"),
    "deniz": os.path.join(MEN, "art", "bust_deniz.png"),
    "selin": os.path.join(MEN, "art", "bust_selin.png"),
    # the fixture's Ece and Kaan have no look: the crowd40 people with the same first name lend a face
    "ece": os.path.join(MEN, "art", "busts", "crowd40", "bust64_18_char_crowd_12.png"),
    "kaan": os.path.join(MEN, "art", "busts", "crowd40", "bust64_19_char_crowd_13.png"),
}


def av(key, size):
    return common.avatar(FACE[key], size)


def fixture_team():
    eng = L("Yazılım", "Engineering")
    return [("founder", L("Kurucu", "Founder"), L("Ürün · Yazılım", "Product · Engineering")),
            ("deniz", "Deniz", eng), ("ece", "Ece", L("Tasarım", "Design")), ("kaan", "Kaan", eng)]


def live_team():
    return [("founder", L("Kurucu", "Founder"), K("HR_ROLE_FOUNDER") if "HR_ROLE_FOUNDER" in CSV else ""),
            ("elif", "Elif Demir", T("r_pm")), ("deniz", "Deniz Arslan", T("r_design")), ("selin", "Selin Kaya", T("r_qa"))]


# ------------------------------------------------------------------ top bar (system geometry; brand block per decision 14 option (a))
HARNESS = dict(cash="$10.000", net="−$1,5K", net_cls="tb-v", run=("7 ay", "7 mo"), run_cls="tb-v", mrr="$0", brand="50", burn="$1,5K", rep="0")


def topbar(v, week, clock, slot, speed, compact=False, W=1920, marks=()):
    """slot: ("next", text[, kind]) or ("gate", sub); kind "warn" | "neg" colours the line (base.css .nx-s).
    speed: "II" | "1x" ... ; every column fixed (SPEC §10)."""
    num = common.num
    col, g, time_w = kit.tb_layout(compact)
    gated = slot[0] == "gate"
    out = []
    if compact:
        out.append('<span class="brand-sq" style="left:22px;top:22px"></span>')
    else:
        out += ['<span class="brand-sq" style="left:20px;top:13px"></span>',
                at(48, 31, "t-subhead", "Project Unicorn", "tb-co", width=g["brand"] - 48 - 12),
                at(48, 50, "t-micro", T("phase"), "tb-k")]
        for i in range(3):
            out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i == 0 else "", 48 + kit.TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"), at(col["B"], b1, "t-hero", num(v["cash"]), "tb-hero"),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", num(v["net"]) + '<span class="tb-u">%s</span>' % T("per_mo"), v["net_cls"]),
            at(col["C"], b1, "t-label", T("runway"), "tb-k"), at(col["D"], b1, "t-value", L(*v["run"]), v["run_cls"]),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", num(v["mrr"]), "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", v["brand"], "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", num(v["burn"]) + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", v["rep"], "tb-v")]
    gate_x = W - time_w - g["gate"]
    d0 = col["metrics_end"]
    pad = 16 if compact else 20
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + pad, 28, "t-body", date_c(week) if compact else date(week), "tb-date"))
    out.append(kit.week_bar(d0 + pad, min(gate_x - pad, d0 + pad + 720), now_h=clock, marks=marks))
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"]))
    if gated:
        tx = gate_x + g["gate_pad"] + 10 + (10 if compact else 12)
        out.append('<span class="gate-dot" style="position:absolute;left:%dpx;top:19px"></span>' % (gate_x + g["gate_pad"]))
        out.append(at(tx, 30, "t-gate", T("gate"), "gate-l"))
        out.append(at(tx, 51, "t-key", slot[1], "gate-s", width=g["gate"] - (tx - gate_x) - g["gate_pad"]))
    else:
        tx = gate_x + g["gate_pad"]
        out.append(at(tx, 29, "t-micro", T("next"), "nx-l"))
        kind = slot[2] if len(slot) > 2 else ""
        out.append(at(tx, 50, "t-key", slot[1], ("nx-s " + kind).strip(), width=g["gate"] - 2 * g["gate_pad"]))
    tx0 = W - time_w
    out.append('<div class="tb-time" style="left:%dpx;width:%dpx"></div>' % (tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "%02d:00" % int(clock), "tb-clock"))
    kx = tx0 + g["time_pad"][0] + kit.TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if k == speed else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    if gated:
        out.append('<div class="tb-gated-frame" style="left:%dpx;width:%dpx"></div>' % (gate_x, W - gate_x))
    style = (' style="width:%dpx;right:auto"' % W) if W != 1920 else ""
    return '<header class="topbar%s%s"%s>%s</header>' % (" is-gated" if gated else "", " is-compact" if compact else "", style, "".join(out))


def slot_end(clock):
    return ("next", L("Mesai bitimi · %d saat" % (17 - clock), "Workday ends · %d h" % (17 - clock)))


def slot_sprint():
    """A sprint decision paper is waiting (SPEC §10 priority: above the fallback). No week-bar diamond: the diamond
    marks an hour, a paper has none; it runs until the week ends."""
    return ("next", s("slot_sprint"), "warn")


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]


def rail(active, badges=None, icons=False):
    badges = badges or {}
    rows = []
    for key, name in RAIL:
        b = "lock" if key == "pazarlama" else badges.get(key)
        cls = "rr" + (" is-active" if key == active else "") + (" is-locked" if b == "lock" else "")
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), T("soon"))
            right = '<span class="lk">%s</span>' % ic("lock", 12) if icons else ""
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    return ('<nav class="rail%s">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", "".join(rows), ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ page and screen
OFFICE = {"ishani": "art/office_safe_1920.png", "home": "art/office_safe_1920_home.png", "1536": "art/office_safe_1536.png"}


def page(body, title="Ürün", w1536=False, css_extra=()):
    links = "".join('<link rel="stylesheet" href="%s">' % c for c in css_extra)
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '%s<link rel="stylesheet" href="../urun.css"></head><body%s>%s</body></html>'
            % (LANG, title, common.FONTS, REL, REL, links, ' class="w1536"' if w1536 else "", body))


def screen(top, rail_html, window, office="ishani", floats=""):
    off = '<div class="office is-dimmed" style="background-image:url(%s%s)"></div>' % (REL, OFFICE[office])
    return '<div class="screen">%s%s%s%s%s%s</div>' % (off, floats, window, top, rail_html, kit.ticker())


def sb(top, height, thumb_top, thumb_h, right=2):
    return ('<div class="sb" style="right:%dpx;top:%dpx;height:%dpx"><div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>'
            % (right, top, height, thumb_top, thumb_h))


# ------------------------------------------------------------------ product vocabulary
LEVEL_KEYS = {"strong": "PRODUCT_LEVEL_STRONG", "enough": "PRODUCT_LEVEL_ENOUGH", "weak": "PRODUCT_LEVEL_WEAK", "none": "PRODUCT_LEVEL_NONE"}
WORDS = ["none", "weak", "enough", "strong"]
KIND_IC = {"feature": "k_feature", "polish": "k_polish", "fix": "k_fix", "research": "k_research"}
ROLE_IC = {"design": "sk_design", "dev": "sk_eng", "test": "sk_qa", "product": "sk_product"}
AREAS = {  # id -> (name TR, EN, short TR, short EN)
    "core": ("Çekirdek", "Core", "Çekirdek", "Core"),
    "onboarding": ("Onboarding & Erişim", "Onboarding & Access", "Onboarding", "Onboarding"),
    "growth": ("Büyüme", "Growth", "Büyüme", "Growth"),
    "integrations": ("Entegrasyonlar", "Integrations", "Entegrasyonlar", "Integrations"),
    "trust": ("Güven & Ölçek", "Trust & Scale", "Güven", "Trust"),
    "revenue": ("Gelir", "Revenue", "Gelir", "Revenue"),
}


def aname(a):
    return L(AREAS[a][0], AREAS[a][1])


def ashort(a):
    return L(AREAS[a][2], AREAS[a][3])


def word(w):
    return K(LEVEL_KEYS[w])


def lw(level):
    """Word of a level when the expectation is 1 (Bootstrap): a half square is already below it."""
    return "none" if level <= 0 else ("weak" if level < 1 else WORDS[int(level)])


def slices(level, w, sm=False, count=3, cls=""):
    cells = []
    for i in range(count):
        fill = max(0.0, min(1.0, level - i))
        cells.append('<i class="%s"></i>' % ("f" if fill >= 1 else ("h" if fill > 0 else "")))
    return '<span class="sl%s w-%s %s">%s</span>' % (" sm" if sm else "", w, cls, "".join(cells))


def arrow(cls="ar"):
    return '<span class="ic %s">%s</span>' % (cls, common.raw_svg("arrow"))


# effect parts (ProductModel part dictionaries)
def P_level(a, f, t):
    return {"k": "level", "area": a, "from": f, "to": t}


def P_cap(name, f, t):
    return {"k": "cap", "name": name, "from": f, "to": t}


def part_html(p, forecast=False):
    k = p["k"]
    if k == "level":
        fw, tw = lw(p["from"]), lw(p["to"])
        if forecast:
            return ('<span class="a">%s</span><span class="w-%s">%s</span>%s<span class="w-%s">%s</span>'
                    % (ashort(p["area"]), fw, word(fw), arrow(), tw, word(tw)))
        return '<span class="a">%s</span>%s%s%s' % (ashort(p["area"]), slices(p["from"], fw, True), arrow(), slices(p["to"], tw, True))
    if k == "cap":
        fw, tw = WORDS[int(p["from"])], WORDS[int(p["to"])]
        return '<span class="a">%s</span>%s%s%s' % (L(*p["name"]) if isinstance(p["name"], tuple) else p["name"],
                                                     slices(p["from"], fw, True), arrow(), slices(p["to"], tw, True))
    if k == "holds":
        return '<span class="a">%s</span>%s' % (ashort(p["area"]), K("PRODUCT_FX_HOLDS", level=word(p["word"])))
    if k == "alert_clear":
        return '<span class="a">%s</span><span class="ic al">%s</span>%s' % (ashort(p["area"]), common.raw_svg("warn"), K("PRODUCT_FX_ALERT_CLEARS"))
    if k == "tickets":
        return KC("PRODUCT_FX_TICKETS_CLOSED" if forecast else "PRODUCT_FX_TICKETS_CLOSE", p["n"])
    if k == "voices":
        return KC("PRODUCT_FX_VOICES_CLOSED" if forecast else "PRODUCT_FX_VOICES_CLOSE", p["n"])
    if k == "request":
        return "%s · %s" % (K("PRODUCT_FX_REQUEST", customer=p["customer"]), K("PRODUCT_PER_YEAR", amount=money(p["value"])))
    if k == "rival_gap":
        return K("PRODUCT_FX_RIVAL_GAP")
    if k == "research":
        return '<span class="a">%s</span>%s' % (ashort(p["area"]), K("PRODUCT_FX_RESEARCH"))
    if k == "request_on_time":
        return '<span class="a">%s</span>%s' % (p["customer"], K("PRODUCT_FX_ON_TIME"))
    raise KeyError(k)


def effect_line(parts):
    """Parts sit 12 px apart with no separator glyph, so a wrapped line never starts or ends on a dot."""
    return '<div class="fxl">%s</div>' % "".join('<span class="p">%s</span>' % part_html(p) for p in parts)


def forecast(parts):
    chips = "".join('<span class="fx"><span class="ic" style="color:var(--pos)">%s</span>%s</span>'
                    % (common.raw_svg("up"), part_html(p, True).replace('class="a"', 'class="a" style="color:var(--ink-2)"'))
                    for p in parts)
    return '<div class="fc">%s</div>' % chips


# ------------------------------------------------------------------ fixture deck (scripts/debug/product_fixtures.gd _deck_table)
def deck():
    founder = L("Kurucu", "Founder")
    return {
        "kesinti": ("fix", "trust", ["dev"], 2, ("Kesinti düzeltmesi", "Outage fix"), [{"k": "alert_clear", "area": "trust"}], [("Kaan", 1)]),
        "kisa_kayit": ("feature", "onboarding", ["design", "dev"], 3, ("Kısa kayıt", "Short sign-up"),
                       [P_level("onboarding", 1, 2), {"k": "tickets", "n": 3}], [("Ece", 1), ("Kaan", 1)]),
        "ilk_tur": ("feature", "onboarding", ["design", "dev"], 2, ("İlk tur rehberi", "First-run guide"),
                    [P_level("onboarding", 1, 2), {"k": "tickets", "n": 1}], [("Ece", 1), ("Kaan", 1)]),
        "mobil_giris": ("feature", "onboarding", ["dev", "test"], 4, ("Mobil giriş", "Mobile login"),
                        [P_level("onboarding", 1, 2), {"k": "rival_gap"}], [("Kaan", 2)]),
        "gorusme": ("research", "onboarding", ["product"], 1, ("5 kullanıcıyla görüş", "Talk to 5 users"),
                    [{"k": "research", "area": "onboarding"}], [(founder, 1)]),
        "filtreli": ("polish", "core", ["dev"], 5, ("Filtreli arama", "Filtered search"),
                     [{"k": "holds", "area": "core", "word": "strong"}, P_cap(("Arama", "Search"), 2, 3)], [("Deniz", 2)]),
        "oto_yedek": ("feature", "trust", ["dev"], 3, ("Otomatik yedekleme", "Automatic backups"),
                      [P_level("trust", 1, 2)], [("Deniz", 1), ("Kaan", 1)]),
        "etiketler": ("feature", "core", ["design", "dev"], 4, ("Etiketler", "Tags"), [P_cap(("Etiketler", "Tags"), 0, 1)],
                      [("Ece", 1), ("Deniz", 1)]),
        "baglanti": ("feature", "growth", ["dev"], 4, ("Bağlantıyla paylaşım", "Share by link"), [P_level("growth", 2, 3)], [("Kaan", 2)]),
        "ucretli": ("feature", "revenue", ["design", "dev"], 6, ("Ücretli plan", "Paid plan"), [P_level("revenue", 0, 1)],
                    [("Ece", 1), ("Deniz", 2)]),
        "akilli_arama": ("feature", "core", ["dev"], 8, ("Akıllı arama", "Smart search"), [P_cap(("Arama", "Search"), 2, 3)], []),
        "sso": ("feature", "trust", ["dev", "test"], 5, ("SSO (Nordica)", "SSO (Nordica)"),
                [P_level("trust", 1, 2), {"k": "request", "customer": "Nordica", "value": 12000}], [("Kaan", 2)]),
        # fixture "Excel dışa aktarma": a real brand (CLAUDE §5); the fixture string needs the same change (INDEX)
        "excel": ("feature", "integrations", ["dev"], 3, ("Tablo dışa aktarma (Palmiye)", "Spreadsheet export (Palmiye)"),
                  [P_level("integrations", 1, 2), {"k": "request", "customer": "Palmiye", "value": 4000}], [("Deniz", 1)]),
        "efatura": ("feature", "integrations", ["dev", "test"], 5, ("e-Fatura entegrasyonu", "e-Invoice integration"),
                    [P_level("integrations", 1, 2), {"k": "voices", "n": 2}], [("Deniz", 2)]),
    }


def D(cid, state, **extra):
    k, area, roles, effort, name, effect, split = deck()[cid]
    c = {"id": cid, "name": L(*name), "kind": k, "area": area, "roles": roles, "effort": effort, "state": state,
         "effect": effect, "tag_sprint": -1, "phases": [], "assignees": [], "decision": None, "locked_node": "",
         "remaining": -1, "spills": False, "urgent": False, "split": split}
    c.update(extra)
    return c


# ------------------------------------------------------------------ sprint card
def btn_icon(icon, disabled=False, kind="btn-secondary"):
    return '<span class="btn %s btn-sm btn-icon%s">%s</span>' % (kind, " is-disabled" if disabled else "", ic(icon))


def phase_steps(phases):
    out = []
    keys = ["PRODUCT_PHASE_DESIGN", "PRODUCT_PHASE_DEV", "PRODUCT_PHASE_TEST"]
    for i, ph in enumerate(phases):
        if i:
            out.append('<span class="ln"></span>')
        out.append('<span class="sc-step %s"><i></i>%s</span>' % ({"done": "done", "active": "now"}.get(ph, ""), K(keys[i])))
    return "".join(out)


def card(c, can_add=True, raised=False, hover=False, mini=False, tip_above=True, narrow=False):
    st = c["state"]
    pts = c["remaining"] if c["remaining"] >= 0 else c["effort"]
    cls = ["sc"]
    if raised:
        cls.append("on-raised")
    if st in ("planlanan", "devreden"):
        cls.append("is-planned")
    if st == "alinmis":
        cls.append("is-taken")
    if st == "kilitli":
        cls.append("is-locked")
    if st == "bitti":
        cls.append("is-done")
    if hover:
        cls.append("is-hover")
    if narrow:
        cls.append("narrow")
    if mini:
        cls.append("mini")
        return ('<div class="%s"><div class="sc-top"><span class="ic kind">%s</span><span class="t">%s</span><span class="pts">%d</span></div></div>'
                % (" ".join(cls), common.raw_svg(KIND_IC[c["kind"]]), c["name"], pts))
    head = []
    if st == "kilitli":
        head.append('<span class="ic lk">%s</span>' % common.raw_svg("lock"))
    head.append('<span class="ic kind">%s</span>' % common.raw_svg(KIND_IC[c["kind"]]))
    head.append('<span class="t">%s</span>' % c["name"])
    tags = []
    if st == "devreden":
        tags.append(tag(K("PRODUCT_CARRIED"), "outline"))
    if st == "beta":
        tags.append(tag(K("PRODUCT_BETA_WAITING"), "outline"))
    if c["urgent"]:
        tags.append('<span class="tag tag-warn">%s%s</span>' % (ic("warn", 12), L("Acil", "Urgent")))
    if c["spills"]:
        tags.append(tag(K("PRODUCT_CARD_SPILLS"), "warn"))
    if not narrow:
        head += tags
    if st == "bitti":
        head.append(stamp(s("done_stamp")))
    else:
        head.append('<span class="roles">%s</span>' % "".join(ic(ROLE_IC[r], 16) for r in c["roles"]))
    head.append('<span class="pts">%d</span>' % pts)
    if st == "alinmis":
        head.append(tag(K("PRODUCT_TAG_SPRINT", n=c["tag_sprint"]), "outline"))
    elif st in ("aday", "kilitli"):  # a locked card can go to neither sprint: both actions off
        head.append('<span class="acts">%s%s</span>' % (btn_icon("plus", st == "kilitli" or not can_add), btn_icon("arrow", st == "kilitli")))
    body = []
    if narrow and tags:
        body.append('<div class="sc-tags">%s</div>' % "".join(tags))
    if st in ("aktif", "bitti"):
        who = "".join(av(a, 24) for a in c["assignees"])
        body.append('<div class="sc-steps">%s<span class="sc-who">%s</span></div>' % (phase_steps(c["phases"]), who))
    else:
        body.append(effect_line(c["effect"]))
    if st == "kilitli":
        body.append('<div class="sc-why">%s</div>' % c["locked_node"])
    if c["decision"]:
        d = c["decision"]
        body.append('<div class="sc-dec">%s<span class="who-n">%s</span><span class="dot" style="color:var(--ink-4)">·</span>'
                    '<span class="subj">%s</span><span class="btn btn-secondary btn-sm">%s%s</span></div>'
                    '<div class="sc-dec2">%s<span>%s</span><span class="dot" style="color:var(--ink-4)">·</span>'
                    '<span class="lw" style="display:inline-flex;align-items:center;gap:4px">%s%s</span></div>'
                    % (av(d["face"], 24), d["speaker"], d["text"], ic("inbox"), s("go_decision"),
                       ic("inbox"), s("decision_in_inbox"), ic("clock"), T("wk_this")))
    extra = ""
    if hover:
        acts = {"plan": btn_icon("arrow") + '<span class="btn btn-ghost btn-sm">%s</span>' % L("Çıkar", "Remove"),
                "planlanan": btn_icon("chevup") + '<span class="btn btn-ghost btn-sm">%s</span>' % L("Çıkar", "Remove")}.get(st, "")
        if acts:
            extra += '<span class="hacts">%s</span>' % acts
        if c["split"]:
            parts = [KC("PRODUCT_EFFORT_POINTS", pts)] + [K("PRODUCT_EFFORT_PERSON", name=n, weeks=KC("PRODUCT_WEEKS", w)) for n, w in c["split"]]
            pos = "bottom:calc(100% + 6px)" if tip_above else "top:calc(100% + 6px)"
            extra += '<span class="tip" style="position:absolute;right:12px;%s;z-index:6;white-space:nowrap">%s</span>' % (pos, " · ".join(parts))
    return '<div class="%s"><div class="sc-top">%s</div>%s%s</div>' % (" ".join(cls), "".join(head), "".join(body), extra)


# ------------------------------------------------------------------ area panel
def capability(name, tier, have, total=3):
    return ('<span class="k%s">%s</span>%s<span class="r">%s</span>'
            % ("" if tier > 0 else " off", name, slices(tier, "enough", True), K("PRODUCT_RIVALS_HAVE", have=have, total=total)))


def voice_chip(n, new):
    nw = ('<span class="dot">·</span><span class="nw">%s</span>' % K("PRODUCT_NEW_COUNT", n=new)) if new else ""
    return '<span class="vc">%s<span>%d</span>%s</span>' % (ic("voices", 14), n, nw)


def level_line(a, chips=""):
    """Second line: level squares and word; the voices count and the rival flag ride on its right, so a long
    area name keeps the first line to itself."""
    if a.get("level_to", -1) >= 0:
        lv = ('%s%s%s<span class="was">%s</span>%s<span class="w-%s">%s</span>'
              % (slices(a["level"], a["word"]), arrow(), slices(a["level_to"], a["word_to"]), word(a["word"]), arrow(),
                 a["word_to"], word(a["word_to"])))
    else:
        lv = '%s<span class="w-%s">%s</span>' % (slices(a["level"], a["word"]), a["word"], word(a["word"]))
    return '<div class="lv ar-2">%s%s</div>' % (lv, ('<span class="ar-chips">%s</span>' % chips) if chips else "")


def area_row(a, is_open=False, compact=False, can_add=True, voices_open=False, hover=None):
    l1 = ['<span class="ar-n">%s</span>' % a["name"]]
    chips = voice_chip(*a["voices"]) if a["voices"][0] else ""
    if a.get("rival") and not compact:
        chips += '<span class="flg">%s</span>' % K("PRODUCT_RIVAL_TOPIC", topic=a["rival"])
    if a.get("alert"):
        l1.append('<span class="ic alert">%s</span>' % common.raw_svg("warn"))
    if not compact:
        l1.append('<span class="ic chev">%s</span>' % common.raw_svg("chevdown" if is_open else "chev"))
    body = ""
    if is_open:
        built = "".join(capability(*cap) for cap in a["caps"])
        cards = "".join(card(c, can_add=can_add, raised=True, hover=(c["id"] == hover), narrow=True) for c in a["cands"])
        if not a["cands"]:
            cards = '<div class="empty-l">%s%s</div>' % (ic("check"), K("PRODUCT_AREA_NOTHING_LEFT"))
        parts = ['<div class="sec sub t-micro">%s</div><div class="built">%s</div>' % (K("PRODUCT_BUILT"), built),
                 '<div class="sec sub t-micro">%s</div>%s' % (K("PRODUCT_POSSIBLE"), cards)]
        if a["voices"][0]:
            n, new = a["voices"]
            nw = ('<span style="color:var(--ink-4)">·</span><span class="nw">%s</span>' % K("PRODUCT_NEW_COUNT", n=new)) if new else ""
            fold = ('<div class="vfold">%s<span>%s</span>%s<span class="ic chev" style="width:16px;height:16px;color:var(--ink-3)">%s</span></div>'
                    % (ic("voices", 16), KC("PRODUCT_VOICES_COUNT", n), nw, common.raw_svg("chevdown" if voices_open else "chev")))
            lines = ""
            if voices_open:
                lines = "".join('<div class="voice">%s<span>%s</span></div>' % (tag(K("PRODUCT_NEW_STAMP"), "outline") if v[1] else "", v[0])
                                for v in a["voices_list"])
            parts.append('<div class="sec sub t-micro">%s</div>%s%s' % (K("PRODUCT_VOICES"), fold, lines))
        body = '<div class="ar-body">%s</div>' % "".join(parts)
    cls = "ar-row" + (" is-open" if is_open else "") + (" is-compact" if compact else "")
    return ('<div class="%s"><div class="ar-1">%s</div>%s<div class="ar-3">%s</div>%s</div>'
            % (cls, "".join(l1), level_line(a, chips), a["sentence"], body))


def customers_row(customers, can_add=True, sprint=7):
    """A deadline is warn only when it ends this sprint or the next; a later one reads as plain ink (S3, finding 27)."""
    n = len(customers)
    cards = []
    for cu in customers:
        if not cu.get("request"):
            cards.append('<div class="sc"><div class="sc-top"><span class="t" style="font-weight:500;color:var(--ink-2)">%s</span></div></div>'
                         % KC("PRODUCT_CUSTOMER_TICKETS", cu["tickets"], customer=cu["name"]))
            continue
        right = tag(K("PRODUCT_TAG_SPRINT", n=cu["tag"]), "outline") if cu["tag"] >= 0 else \
            '<span class="acts">%s%s</span>' % (btn_icon("plus", not can_add), btn_icon("arrow"))
        soon = cu["due"] <= sprint + 1
        terms = ('<div class="fxl"><span class="p due%s">%s%s</span>'
                 '<span class="p a">%s</span><span class="flg">%s</span></div>'
                 % (" is-soon" if soon else "", ic("clock", 14), K("PRODUCT_DUE_SPRINT", n=cu["due"]),
                    K("PRODUCT_PER_YEAR", amount=money(cu["value"])), cu["area"]))
        cards.append('<div class="sc"><div class="sc-top"><span class="t">%s · %s</span><span style="margin-left:auto"></span>%s</div>%s</div>'
                     % (cu["name"], cu["request"], right, terms))
    return ('<div class="ar-row"><div class="ar-1"><span class="ar-n">%s</span><span class="t-caption" style="color:var(--ink-3)">%s</span></div>'
            '<div class="ar-body" style="margin-top:8px">%s</div></div>'
            % (K("PRODUCT_CUSTOMERS"), KC("PRODUCT_REQUESTS_COUNT", n) if n else K("PRODUCT_CUSTOMERS_NONE"), "".join(cards)))


def history_block(versions):
    items = []
    for label, sprint, count, rk, rtext in versions:
        res = ""
        if rtext:  # the CSV line is "Gerçekleşen: {text}": the key part reads ink-3, the sentence ink-2
            k, _, v = K("PRODUCT_RESULT_ACTUAL" if rk == "actual" else "PRODUCT_RESULT_EXPECTED", text=rtext).partition(": ")
            res = '<div class="hv-2"><span class="k">%s:</span> %s</div>' % (k, v)
        items.append('<div class="hv"><div class="hv-1"><b>%s</b><span>%s</span><span style="color:var(--ink-4)">·</span><span>%s</span></div>%s</div>'
                     % (label, K("PRODUCT_TAG_SPRINT", n=sprint), KC("PRODUCT_HISTORY_CARDS", count), res))
    if not items:
        items.append('<div class="empty-l">%s</div>' % K("PRODUCT_HISTORY_NONE"))
    return '<div class="sec t-label">%s</div><div class="hist">%s</div>' % (K("PRODUCT_HISTORY"), "".join(items))


def area_panel(areas, open_id="", can_add=True, customers=None, hover=None, voices_open=False, scroll=None, history=None, offset=0):
    rows = [history_block(history) if history is not None else "", '<div class="sec t-label">%s</div>' % K("PRODUCT_AREAS")]
    for a in areas:
        rows.append(area_row(a, a["id"] == open_id, can_add=can_add, hover=hover, voices_open=voices_open))
    if customers is not None:
        rows.append(customers_row(customers, can_add))
    bar = sb(0, *scroll) if scroll else ""
    return '<div class="pa"><div class="pa-in" style="top:%dpx">%s</div>%s</div>' % (-offset, "".join(rows), bar)


# ------------------------------------------------------------------ capacity and team
def capacity(used, total, done=0, segments=(), show_tick=False):
    span = max(total, used)
    if span == 0:
        return '<div class="capr"><div class="capb is-empty"></div><span class="capv">0/0</span></div>'
    segs = []
    acc = 0
    for pts in segments:
        # each card's points; the part past the capacity line is drawn in danger, the done part in emphasis
        start, end = acc, acc + pts
        inside = max(0, min(end, total) - start)
        over = pts - inside
        done_here = max(0, min(end, done) - start)
        if done_here:
            segs.append('<span class="s done" style="flex:%d 0 0"></span>' % done_here)
        if inside - done_here > 0:
            segs.append('<span class="s" style="flex:%d 0 0"></span>' % (inside - done_here))
        if over:
            segs.append('<span class="s over" style="flex:%d 0 0"></span>' % over)
        acc = end
    if span > used:
        segs.append('<span style="flex:%d 0 0"></span>' % (span - used))
    tick = '<span class="tick" style="left:%.2f%%"></span>' % (total / span * 100) if (show_tick or used > total) else ""
    return ('<div class="capr"><div class="capb">%s%s</div><span class="capv%s">%d/%d</span></div>'
            % ("".join(segs), tick, " over" if used > total else "", used, total))


def team_row(team, note=""):
    faces = "".join(av(k, 32).replace('class="av av-32 ', 'title="%s · %s" class="av av-32 ' % (n, r)) for k, n, r in team)
    return '<div class="team">%s%s</div>' % (faces, note)


def warn_note(text, icon="bug", kind="warn"):
    return '<span class="note %s">%s%s</span>' % (kind, ic(icon), text)


def segpick(open_):
    return ('<span class="segpick"><span class="%s">%s</span><span class="%s">%s</span></span>'
            % ("" if open_ else "is-on", K("PRODUCT_OFF"), "is-on" if open_ else "", K("PRODUCT_ON")))


def beta_row(open_, right=""):
    return '<div class="frow"><span class="k t-label">%s</span>%s%s</div>' % (K("PRODUCT_BETA_CHANNEL"), segpick(open_), right)


def lead_row(face, name, text, label_key="PRODUCT_LEAD_TIP", apply=True):
    if label_key == "PRODUCT_LEAD_TIP":
        k = '<span class="t-label">%s</span><span class="n">%s</span>' % (L("Liderin önerisi", "Lead's pick"), name)
    else:
        k = '<span class="t-label">%s</span><span class="n">%s</span>' % (L("Lider", "Lead"), name)
    btn = '<span class="btn btn-secondary btn-sm">%s</span>' % s("apply_lead") if apply else ""
    return ('<div class="lead">%s<div class="lead-w"><div class="lead-k">%s</div><div class="lead-q">%s</div></div>%s</div>'
            % (av(face, 32), k, text, btn))


# ------------------------------------------------------------------ columns
def col_head(sprint, meta, key):
    m = '<span class="m t-meta">· %s</span>' % meta if meta else ""
    return '<div class="ph"><span class="t t-tab">%s</span>%s<span class="k t-label">%s</span></div>' % (K("PRODUCT_SPRINT_TITLE", n=sprint), m, key)


def center_plan(c, hover=None, scroll=None):
    head = [col_head(c["sprint"], KC("PRODUCT_WEEKS", 2), K("PRODUCT_THIS_SPRINT")),
            capacity(c["used"], c["total"], 0, [x["remaining"] if x["remaining"] >= 0 else x["effort"] for x in c["cards"]])]
    if c["team"]:
        head.append(team_row(c["team"], warn_note(c["warning"], c.get("warning_icon", "bug")) if c["warning"] else ""))
    if c.get("over_note"):
        head.append('<div style="display:flex;gap:16px">%s%s</div>' % (warn_note(c["over_note"], "warn"), '<span class="note">%s</span>' % s("add_closed") if c.get("add_closed") else ""))
    stack = [card(x, hover=(x["id"] == hover)) for x in c["cards"]]
    if not c["cards"] and c["total"] > 0:
        stack.append('<div class="empty-l">%s%s</div>' % (ic("plus"), K("PRODUCT_START_NEED_CARD")))
    if c["total"] == 0:  # nobody can work: the system's empty state with the way out; the reason stays only by the CTA
        stack.append('<div class="empty is-col">%s<span class="empty-t">%s</span><span class="btn btn-secondary">%s%s</span></div>'
                     % (ic("ekip", 32), K("HR_EMPTY_ROW"), ic("plus"), K("HR_SEARCH_START")))
    if c["forecast"]:
        stack.append('<div class="sec t-label" style="margin-top:8px">%s</div>%s' % (K("PRODUCT_AT_SPRINT_END"), forecast(c["forecast"])))
    foot = []
    if c.get("lead"):
        foot.append(lead_row(*c["lead"]))
    start = '<span class="btn btn-primary%s">%s</span>' % ("" if c["can_start"] else " is-disabled", K("PRODUCT_START_SPRINT"))
    if not c["can_start"]:  # disabled primary: its reason sits right above it (SPEC rule 4); the failing condition names itself
        why = K("PRODUCT_TEAM_NOBODY") if c["total"] == 0 else K("PRODUCT_START_NEED_CARD")
        foot.append('<div class="frow"><span class="note" style="margin-left:auto">%s%s</span></div>' % (ic("lock"), why))
    foot.append(beta_row(c["beta"], start))
    bar = sb(*scroll, right=4) if scroll else ""
    return ('<div class="pcol is-center"><div class="pcol-h">%s</div><div class="pcol-s">%s%s</div><div class="pcol-f">%s</div></div>'
            % ("".join(head), "".join(stack), bar, "".join(foot)))


def center_active(c, scroll=None):
    head = [col_head(c["sprint"], K("PRODUCT_WEEK_OF", w=c["week"], t=2), K("PRODUCT_THIS_SPRINT"))]
    if c.get("auto"):  # util/play, never util/sparkle or kind_feature (those read as the feature card kind); kabuk's .bh-auto should match
        head.append('<div><span class="note">%s%s</span></div>' % (ic("play"), K("PRODUCT_AUTO_STARTED")))
    head += [
            capacity(c["used"], c["total"], c["done"], [x["effort"] for x in c["cards"] if x["state"] != "beta"]),
            team_row(c["team"], warn_note(c["warning"]) if c["warning"] else "")]
    stack = [card(x) for x in c["cards"]]
    st = c["status"]
    stack.append('<div class="sec t-label" style="margin-top:8px">%s</div>' % K("PRODUCT_STATUS"))
    stack.append('<div class="st"><span class="ic ok">%s</span><b>%s</b><span>%s</span><span class="sep">·</span>'
                 '<span class="dotx"></span><b>%d</b><span>%s</span><span class="sep">·</span>'
                 '%s<b>%s</b><span>%s</span></div>'
                 % (common.raw_svg("check"), KC("PRODUCT_STATUS_CARDS", st[0]), K("PRODUCT_STATUS_DONE"), st[1], K("PRODUCT_STATUS_RUNNING"),
                    ic("inbox", 16), KC("PRODUCT_STATUS_DECISIONS", st[2]), K("PRODUCT_STATUS_WAITING")))
    nv = c["next_version"]
    eta = [KC("PRODUCT_IN_WEEKS", nv[1])]
    if nv[2] >= 0:
        eta.append(KC("PRODUCT_CARDS_LEFT", nv[2]))
    foot = ['<div class="nv"><span class="k t-label">%s</span><span class="v">%s</span><span class="m">%s</span></div>'
            % (K("PRODUCT_NEXT_RELEASE"), nv[0], " · ".join(eta)), beta_row(c["beta"])]
    bar = sb(*scroll, right=4) if scroll else ""
    return ('<div class="pcol is-center"><div class="pcol-h">%s</div><div class="pcol-s">%s%s</div><div class="pcol-f">%s</div></div>'
            % ("".join(head), "".join(stack), bar, "".join(foot)))


def center_release(r, next_sprint):
    head = ['<div class="ph"><span class="t-label" style="color:var(--ink-3)">%s</span><span class="m t-meta">%s</span></div>'
            % (K("PRODUCT_RELEASE_NOTE"), K("PRODUCT_SPRINT_END", n=r["sprint"]))]
    stack = []
    if r["version"]:
        st = "" if r["beta"] else stamp(K("PRODUCT_LIVE"))
        stack.append('<div class="rn-ver"><span class="v">%s</span>%s</div>' % (r["version"], st))
        if r["beta"]:
            stack.append('<div class="rn-sub">%s</div>' % K("PRODUCT_RELEASE_BETA"))
    else:
        stack.append('<div class="rn-ver"><span class="t-subhead" style="color:var(--ink-2)">%s</span></div>' % K("PRODUCT_NO_RELEASE"))
    if r["shipped"]:
        stack.append('<div class="sec t-label" style="margin-top:4px">%s</div>' % K("PRODUCT_SHIPPED"))
        stack.append("".join('<div class="rl"><span class="ic kind">%s</span><span class="grow">%s</span><span class="ic ok">%s</span><span class="pts">%d</span></div>'
                             % (common.raw_svg(KIND_IC[x["kind"]]), x["name"], common.raw_svg("check"), x["effort"]) for x in r["shipped"]))
    if r["carried"]:
        stack.append('<div class="sec t-label" style="margin-top:4px">%s</div>' % K("PRODUCT_CARRIED_OVER"))
        for kind, name, done, total, to in r["carried"]:
            sq = "".join('<i class="%s"></i>' % ("f" if i < done else "") for i in range(total))
            stack.append('<div class="rl"><span class="ic kind">%s</span><span class="grow">%s</span><span class="prog-sq">%s</span>%s<span class="to">%s</span></div>'
                         % (common.raw_svg(KIND_IC[kind]), name, sq, arrow(), K("PRODUCT_TAG_SPRINT", n=to)))
    v = r["velocity"]
    rows = ['<span class="k t-label">%s</span><span class="v big"><b>%d/%d</b><span class="m">%s</span></span>'
            % (K("PRODUCT_VELOCITY"), v[0], v[1], KC("PRODUCT_VELOCITY_LINE", v[1], done=v[0], total=v[1]))]
    if r["result"]:  # same split as the history line: the CSV key part in ink-3, the sentence in ink-2
        rk, txt = r["result"]
        k, _, v = K("PRODUCT_RESULT_ACTUAL" if rk == "actual" else "PRODUCT_RESULT_EXPECTED", text=txt).partition(": ")
        rows.append('<span class="k t-label">%s</span><span class="v"><span class="rk">%s:</span> %s</span>' % (K("PRODUCT_RESULT"), k, v))
    if r["press"]:
        outlet, line = r["press"]
        rows.append('<span class="k t-label">%s</span><span class="v"><span class="o o-%s">%s</span> · %s</span>' % (K("PRODUCT_PRESS"), outlet[0], outlet[1], line))
    stack.append('<div class="kvg" style="margin-top:12px">%s</div>' % "".join(rows))
    stack.append('<div style="height:4px"></div>' + lead_row(*r["lead"], label_key="PRODUCT_LEAD_LINE", apply=False))
    foot = ['<div class="frow"><span class="perm">%s<span class="t-meta">%s</span></span></div>' % (ic("pause"), s("release_hold")),
            beta_row(r["beta_open"], '<span class="btn btn-primary">%s</span>' % K("PRODUCT_PLAN_SPRINT", n=next_sprint))]
    return ('<div class="pcol is-center"><div class="pcol-h">%s</div><div class="pcol-s">%s</div><div class="pcol-f">%s</div></div>'
            % ("".join(head), "".join(stack), "".join(foot)))


def next_col(n):
    head = [col_head(n["sprint"], "", K("PRODUCT_NEXT"))]
    if n["flags"]:
        head.append('<div style="display:flex;flex-wrap:wrap;gap:6px">%s</div>' % "".join(
            '<span class="flg%s">%s%s</span>' % (" warn" if k == "deadline" else "", ic("clock", 14) if k == "deadline" else "", t)
            for k, t in n["flags"]))
    stack = [card(x, hover=(x["id"] == n.get("hover")), narrow=True) for x in n["cards"]]
    if not n["cards"]:
        stack.append('<div class="empty-l">%s</div>' % K("PRODUCT_NEXT_EMPTY"))
    return ('<div class="pcol is-next"><div class="pcol-h">%s</div><div class="pcol-s">%s</div></div>'
            % ("".join(head), "".join(stack)))


# ------------------------------------------------------------------ window
def urun_window(kpis, body, view="sprint", quarter="locked", history=False, x=208, y=88, w=1424, h=928, ctl=True):
    """ctl False: no control strip (the type picker: no sprint, no quarter, no history before a product exists)."""
    k_html = "".join('<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val %s">%s</span></div>'
                     % (k, "t-kpi" if not txt else "is-text", v) for k, v, txt in kpis)
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><div class="win-kpis">%s</div><div class="grow"></div>'
            '<span class="win-close">%s</span></div>' % (T("tab_product"), k_html, ic("close")))
    tabs = '<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if view == "sprint" else "", K("PRODUCT_VIEW_SPRINT"))
    if quarter == "locked":
        tabs += ('<span class="seg-tab t-tab is-disabled">%s%s</span><span class="ctl-why t-caption" style="align-self:center">%s</span>'
                 % (ic("lock", 14), K("PRODUCT_VIEW_QUARTER"), K("PRODUCT_QUARTER_NEED_PM")))
    else:
        tabs += '<span class="seg-tab t-tab%s">%s</span>' % (" is-active" if view == "quarter" else "", K("PRODUCT_VIEW_QUARTER"))
    sw = '<span class="switch%s"><span class="switch-k">%s</span><span class="switch-t"></span></span>' % (" is-on" if history else "", K("PRODUCT_HISTORY"))
    strip = '<div class="win-ctl"><div class="seg">%s</div><div class="grow"></div>%s</div>' % (tabs, sw) if ctl else ""
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s%s<div class="win-body">%s</div></section>'
            % (x, y, w, h, head, strip, body))


def kpis_for(name, market_type, version, mvp=False):
    k = []
    if name:
        k.append((market_type, name, False))
    k.append((s("version_k"), K("PRODUCT_MVP_NOT_LIVE") if mvp else version, mvp))
    return k


# ------------------------------------------------------------------ fixture models (product_fixtures.gd)
def notly_type():
    return "B2C · " + L("Not & Bilgi Aracı", "Notes & Knowledge Tool")


def A(aid, level, sentence, voices=(0, 0), voices_list=(), caps=(), cands=(), alert=False, rival="", **kw):
    a = {"id": aid, "name": aname(aid), "level": level, "word": WORDS[int(level)], "sentence": sentence,
         "voices": voices, "voices_list": list(voices_list), "caps": list(caps), "cands": list(cands), "alert": alert, "rival": rival}
    a.update(kw)
    return a


def notly_areas(released=False, moved=()):
    """c1 / c3 areas. moved: card ids placed into sprint 7 by an action (over-capacity edge)."""
    al, ad = "alinmis", "aday"

    def st(cid, default, tag_n=-1):
        if cid in moved:
            return D(cid, al, tag_sprint=7)
        return D(cid, default, tag_sprint=tag_n) if default == al else D(cid, default)

    rivals = lambda *n: len(n)
    if released:
        ob = A("onboarding", 1, L("10 yeni kullanıcıdan 6'sı ilk hafta kalıyor", "6 of 10 new users stay past the first week"),
               (1, 0), [(L("Doğrulama e-postası geç geliyor", "The verification email arrives late"), False)],
               level_to=2, word_to="enough")
    else:
        ob = A("onboarding", 1, L("10 yeni kullanıcıdan 6'sı ilk hafta bırakıyor", "6 of 10 new users quit in the first week"),
               (4, 1), [(L("Kayıtta şifre kuralı anlaşılmıyor", "The password rule at sign-up is unclear"), True),
                        (L("Doğrulama e-postası geç geliyor", "The verification email arrives late"), False),
                        (L("Kayıt formu çok uzun", "The sign-up form is too long"), False),
                        (L("Telefondan giriş yapamıyorum", "I can't log in from my phone"), False)])
    ob.update(rival=L("mobil", "mobile"),
              caps=[(L("Kayıt", "Sign-up"), 1, rivals("Memora", "Pinbox")), (L("İlk tur", "First run"), 0, rivals("Memora")),
                    (L("Mobil", "Mobile"), 0, rivals("Pinbox"))],
              cands=[st("kisa_kayit", al, 7), st("ilk_tur", al, 8), st("mobil_giris", ad), st("gorusme", ad)])
    return [
        A("core", 3, L("Kullanıcılar arama ve editörü seviyor", "Users love the search and the editor"), (1, 0),
          [(L("Etikete göre arama olsa iyi olur", "Searching by tag would help"), False)],
          [(L("Arama", "Search"), 2, 3), (L("Editör", "Editor"), 3, 2)], [D("filtreli", al, tag_sprint=7), D("etiketler", ad)]),
        ob,
        A("growth", 2, L("Paylaşım yok, davet gelmiyor", "No sharing, no invites coming in"), (1, 0),
          [(L("Notumu paylaşamıyorum", "I can't share a note"), False)], [(L("Paylaşım", "Sharing"), 0, 2)], [D("baglanti", ad)]),
        A("trust", 1, L("Geçen hafta 2 saat kesinti oldu", "Two hours of downtime last week"), alert=not released,
          caps=[(L("Yedekleme", "Backups"), 0, 2), (L("İzleme", "Monitoring"), 1, 3)],
          cands=[D("kesinti", al, tag_sprint=7), D("oto_yedek", al, tag_sprint=8)]),
        A("revenue", 0, L("Ücretli plan henüz yok", "No paid plan yet"), caps=[(L("Ücretli plan", "Paid plan"), 0, 3)], cands=[D("ucretli", ad)]),
    ]


def plan_center(cards, total=12, forecast_parts=None, lead=True, team=None, warning=None):
    used = sum(c["remaining"] if c["remaining"] >= 0 else c["effort"] for c in cards)
    acc = 0
    for c in cards:
        acc += c["remaining"] if c["remaining"] >= 0 else c["effort"]
        c["spills"] = acc > total
    return {"sprint": 7, "cards": cards, "used": used, "total": total,
            "team": fixture_team() if team is None else team,
            "warning": K("PRODUCT_ROLE_MISSING", role=L("Test", "QA")) if warning is None else warning,
            "forecast": [P_level("onboarding", 1, 2), {"k": "alert_clear", "area": "trust"}, {"k": "tickets", "n": 3}] if forecast_parts is None else forecast_parts,
            "lead": ("deniz", "Deniz", L("Kesinti ve kayıt bu sprintte bitmeli.", "The outage fix and sign-up must land this sprint.")) if lead else None,
            "beta": False, "can_start": total > 0 and bool(cards), "can_add": total > 0 and used * 4 <= total * 5}


def notly_next(carried=False, drop=()):
    cards = [D("ilk_tur", "planlanan"), D("oto_yedek", "planlanan")]
    if carried:
        cards.insert(0, D("filtreli", "devreden", remaining=2))
    cards = [c for c in cards if c["id"] not in drop]
    return {"sprint": 8, "flags": [("rival", K("PRODUCT_RIVAL_TOPIC", topic=L("mobil", "mobile")))], "cards": cards}


def sprint_body(areas, center, nxt, open_id="", can_add=True, customers=None, hover=None, voices_open=False, area_scroll=None, history=None,
                offset=0):
    return '<div class="pb">%s%s%s</div>' % (
        area_panel(areas, open_id, can_add, customers, hover=hover, voices_open=voices_open, scroll=area_scroll, history=history,
                   offset=offset),
        center, next_col(nxt))


# ------------------------------------------------------------------ frames
def shell(window, week, clock=8, speed="II", v=HARNESS, badges=None, slot=None, active="urun"):
    top = topbar(v, week, clock, slot or slot_end(clock), speed)
    return screen(top, rail(active, badges), window)


def f_c1(hover="kisa_kayit"):
    c = plan_center([D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
    body = sprint_body(notly_areas(), center_plan(c, hover=hover), notly_next(), "onboarding", c["can_add"], area_scroll=(758, 0, 548))
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13)


def f_quarter_locked():
    c = plan_center([D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
    body = sprint_body(notly_areas(), center_plan(c), notly_next(), "", c["can_add"])
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13)


def f_history():
    c = plan_center([D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
    versions = [("v1.2", 3, 2, "actual", L("Yeni kullanıcıların yarısı ilk hafta kaldı.", "Half of new users stayed the first week.")),
                ("v1.3", 5, 3, "actual", L("Kesinti şikâyetleri durdu.", "Outage complaints stopped.")),
                ("v1.4", 6, 2, "expected", L("Kullanıcıların yarısı verisini emanet etsin.", "Half of users trust it with their data."))]
    body = sprint_body(notly_areas(), center_plan(c), notly_next(), "", c["can_add"], area_scroll=(758, 0, 620), history=versions)
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body, history=True)
    return shell(win, 13)


def f_over():
    cards = [D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli", "mobil_giris", "ilk_tur")]
    c = plan_center(cards)
    spills = sum(1 for x in cards if x["spills"])
    c["over_note"] = (s("over_note_one") if spills == 1 else s("over_note")).format(n=spills)
    c["add_closed"] = not c["can_add"]
    body = sprint_body(notly_areas(moved=("mobil_giris", "ilk_tur")), center_plan(c, scroll=(12, 440, 0, 360)), notly_next(drop=("ilk_tur",)), "onboarding",
                       c["can_add"], area_scroll=(758, 0, 548))
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13)


def f_nobody():
    # the fixture's header warning (PRODUCT_TEAM_NOBODY) moves beside the disabled CTA as its reason; the column body
    # takes the system's empty state (finding 25)
    c = plan_center([], total=0, lead=False, team=[], warning="", forecast_parts=[])
    areas = notly_areas()
    for a in areas:  # the sprint's cards went back to the candidates (product_fixtures _clear_sprint)
        a["cands"] = [D(x["id"], "aday") if x["id"] in ("kesinti", "kisa_kayit", "filtreli") else x for x in a["cands"]]
    body = sprint_body(areas, center_plan(c), notly_next(), "onboarding", False, area_scroll=(758, 0, 548))
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13)


def active_cards_c2():
    return [D("kesinti", "bitti", phases=["done", "done", "done"], assignees=["kaan"]),
            D("kisa_kayit", "aktif", phases=["done", "done", "active"], assignees=["ece", "kaan"]),
            # the row reads "sender · subject" (mail grammar): the subject is the paper's, product.sprint_two_paths
            # (the fixture's sentence "Filtreli aramayı iki şekilde yapabiliriz." is the mail body, not a subject; Q20)
            D("filtreli", "aktif", phases=["done", "active", "waiting"], assignees=["deniz"],
              decision={"face": "deniz", "speaker": "Deniz", "text": K("EV_PRODUCT_SPRINT_TWO_PATHS_TITLE")})]


def f_c2():
    cards = active_cards_c2()
    c = {"sprint": 7, "week": 1, "cards": cards, "used": 10, "total": 12, "done": 2, "team": fixture_team(),
         "warning": K("PRODUCT_ROLE_MISSING", role=L("Test", "QA")), "status": (1, 2, 1),
         "next_version": ("v1.5", 1, -1), "beta": False}
    body = sprint_body(notly_areas(), center_active(c), notly_next(), "")
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13, clock=11, speed="1x", badges={"olaylar": ("count", "1")}, slot=slot_sprint())


def f_c2_auto():
    """c2 reached without a start: a day passed in planning, the lead's pick started the sprint (PRD §3.11)."""
    cards = active_cards_c2()
    c = {"sprint": 7, "week": 1, "cards": cards, "used": 10, "total": 12, "done": 2, "team": fixture_team(),
         "warning": K("PRODUCT_ROLE_MISSING", role=L("Test", "QA")), "status": (1, 2, 1),
         "next_version": ("v1.5", 1, -1), "beta": False, "auto": True}
    body = sprint_body(notly_areas(), center_active(c, scroll=(12, 470, 0, 400)), notly_next(), "")
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13, clock=11, speed="1x", badges={"olaylar": ("count", "1")}, slot=slot_sprint())


def f_voices():
    c = plan_center([D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
    # scrolled so the open area's own row is the first thing in the panel (its name above its sections, S3 27)
    body = sprint_body(notly_areas(), center_plan(c), notly_next(), "onboarding", c["can_add"], voices_open=True,
                       area_scroll=(758, 96, 508), offset=126)
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body)
    return shell(win, 13)


def release_model(beta=False):
    return {"sprint": 7, "version": "v1.5", "beta": beta, "beta_open": beta,
            "shipped": [D("kisa_kayit", "bitti"), D("kesinti", "bitti")],
            "carried": [("polish", L("Filtreli arama", "Filtered search"), 3, 5, 8)],
            "velocity": (8, 12),
            # fixture "İlk hafta: 10 yeni ..." met the CSV's "Gerçekleşen: " as a second colon; reworded without it (INDEX)
            "result": ("actual", L("10 yeni kullanıcıdan 6'sı ilk hafta kaldı (önce 4).", "6 of 10 new users stayed the first week (4 before).")),
            "press": (("teknogundem", "TeknoGündem"), L("Notly kayıt akışını kısalttı.", "Notly shortened its sign-up flow.")),
            "lead": ("deniz", "Deniz", L("Arama bir sprint daha ister.", "Search needs one more sprint."))}


def f_c3(beta=False):
    r = release_model(beta)
    body = sprint_body(notly_areas(released=True), center_release(r, 8), notly_next(carried=True), "")
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4" if beta else "v1.5"), body)
    return shell(win, 15)


# quarter -----------------------------------------------------------------------
def cap1(text):
    """The goal sentence stands alone on the menu's second line: its first letter is raised there (TR i -> İ). The
    strip keeps the CSV's lowercase, where it follows "Onboarding ·" mid-line. Godot: a Fmt helper, not a new key."""
    head = "İ" if (LANG == "tr" and text[:1] == "i") else text[:1].upper()
    return head + text[1:]


def goal_meter(now, target, total):
    cells = []
    for i in range(total):
        cells.append('<i class="%s%s"></i>' % ("f" if i < now else "", " tg" if i == target else ""))
    x = target * 12 + 2 + 2  # squares 10 + gap 2, start pad 2, centred in the 6 px gap
    return '<span class="gm">%s<b style="left:%dpx"></b></span>' % ("".join(cells), x)


def goal_strip(open_=False):
    return ('<div class="goal%s"><span class="gk t-label">%s</span><span class="ga">%s</span><span class="g">%s</span>%s'
            '<span class="gv">%s</span><span class="ic chev">%s</span></div>'
            % (" is-open" if open_ else "", K("PRODUCT_THIS_QUARTER"), ashort("onboarding"), K("PRODUCT_GOAL_ONBOARDING"),
               goal_meter(4, 5, 10), K("PRODUCT_GOAL_PROGRESS", now=4, total=10), common.raw_svg("chevdown")))


def qcol(sprint, kind, cards, flags=(), editable=False, approved=False, total=12):
    used = sum(c["effort"] for c in cards)
    if kind == "empty":
        return ('<div class="qc is-empty"><div class="qc-h"><div class="qc-t"><span class="t-label">%s</span></div></div></div>'
                % K("PRODUCT_SPRINT_TITLE", n=sprint))
    t = '<span class="t-label">%s</span>' % K("PRODUCT_SPRINT_TITLE", n=sprint)
    if kind == "current":
        t += '<span class="k t-micro">%s</span>' % K("PRODUCT_THIS_SPRINT")
    else:
        t += tag(K("PRODUCT_PM"), "neutral")
    head = ['<div class="qc-t">%s</div>' % t, capacity(used, total, 0, [c["effort"] for c in cards])]
    for k, txt in flags:
        head.append('<div><span class="flg">%s</span></div>' % txt)
    stack = "".join(card(c, mini=True) for c in cards)
    foot = ""
    if kind == "proposed":
        if approved:
            foot = '<div class="qc-f">%s</div>' % stamp(K("PRODUCT_APPROVED"))
        else:
            b = '<span class="btn btn-secondary btn-sm">%s</span>' % K("PRODUCT_APPROVE")
            if editable:
                b += '<span class="btn btn-ghost btn-sm">%s</span>' % K("PRODUCT_EDIT")
            foot = '<div class="qc-f">%s</div>' % b
    return ('<div class="qc%s"><div class="qc-h">%s</div><div class="qc-s">%s</div>%s</div>'
            % (" is-current" if kind == "current" else "", "".join(head), stack, foot))


def f_c4(menu=False):
    areas = notly_areas()
    rows = '<div class="sec t-label">%s</div>' % K("PRODUCT_AREAS") + "".join(area_row(a, compact=True) for a in areas)
    planned = lambda *ids: [D(x, "planlanan") for x in ids]
    cols = (qcol(7, "current", [D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
            + qcol(8, "proposed", planned("ilk_tur", "mobil_giris", "oto_yedek"), [("rival", K("PRODUCT_RIVAL_TOPIC", topic=L("mobil", "mobile")))], editable=True)
            + qcol(9, "proposed", planned("etiketler", "baglanti"))
            + qcol(10, "proposed", planned("ucretli"))
            + qcol(11, "empty", []) + qcol(12, "empty", []))
    gm = ""
    if menu:
        items = []
        for aid in ("core", "onboarding", "growth", "trust", "revenue"):
            on = aid == "onboarding"
            items.append('<div class="menu-item%s"><span class="ic chk%s">%s</span><span class="mi-w"><span class="mi-n">%s</span><span class="mi-s">%s</span></span></div>'
                         % (" is-hover" if aid == "trust" else "", "" if on else " none", common.raw_svg("check"), aname(aid), cap1(K("PRODUCT_GOAL_" + aid.upper()))))
        # anchored under the strip's chevron (right edge), where the click was
        gm = '<div class="menu gmenu" style="right:0;top:64px">%s</div>' % "".join(items)
    body = ('<div class="qv"><div style="position:relative">%s%s</div><div class="qb"><div class="qa">%s</div><div class="qr"><div class="qcols">%s</div>'
            '<div class="qfoot"><span class="btn btn-primary">%s</span></div></div></div></div>'
            % (goal_strip(menu), gm, rows, cols, K("PRODUCT_APPROVE_ALL")))
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body, view="quarter", quarter="open")
    return shell(win, 13)


# B2B ---------------------------------------------------------------------------
# The fixture builds no economy, but c5 lists three paying accounts, so the harness's MRR $0 contradicts the window
# (finding 22). MRR from the two contracts on screen: $12.000/yıl + $4.000/yıl = $1.333/ay ($1,3K; Beykoz has no
# contract value in the fixture, so it is not counted). Burn and cash stay the harness's; net = MRR - burn = -$167/ay;
# runway = $10.000 / $167 = 60 ay (the live b2b seed rounds the same way: $10.000 / $300 = 33 ay).
B2B_ECON = dict(HARNESS, mrr="$1,3K", net="−$167", run=("60 ay", "60 mo"))


def f_c5():
    al, ad = "alinmis", "aday"
    areas = [
        A("core", 2, L("Fatura kesme çalışıyor, tahsilat takibi zayıf", "Invoicing works, collections tracking is weak"), (1, 0),
          [(L("Tahsilatı ayrı bir tabloda izliyoruz", "We track collections in a separate sheet"), False)]),
        A("onboarding", 2, L("Kurulum bir günde bitiyor", "Setup is done in a day")),
        A("integrations", 1, L("Muhasebe programına aktarım yok", "No export to accounting software"), (2, 0),
          [(L("Muhasebeci her ay tablo istiyor", "Our accountant asks for a spreadsheet every month"), False),
           (L("e-Fatura gönderemiyoruz", "We can't send e-invoices"), False)],
          cands=[D("excel", al, tag_sprint=7), D("efatura", al, tag_sprint=8)]),
        A("trust", 1, L("Geçen hafta 2 saat kesinti oldu · SSO yok", "Two hours of downtime last week · no SSO"), alert=True,
          caps=[(L("Kullanıcı rolleri", "User roles"), 2, 3), (L("Yedekleme", "Backups"), 0, 2), ("SSO", 0, 1)],
          cands=[D("sso", al, tag_sprint=7), D("kesinti", al, tag_sprint=7), D("oto_yedek", ad, effect=[P_level("trust", 2, 3)])]),
    ]
    customers = [{"name": "Nordica", "request": "SSO", "tag": 7, "due": 8, "value": 12000, "area": ashort("trust")},
                 {"name": "Palmiye", "request": L("Tablo dışa aktarma", "Spreadsheet export"), "tag": 7, "due": 10, "value": 4000, "area": ashort("integrations")},
                 {"name": "Beykoz", "request": "", "tickets": 2}]
    c = plan_center([D(x, "plan") for x in ("sso", "kesinti", "excel")],
                    forecast_parts=[P_level("trust", 1, 2), {"k": "request_on_time", "customer": "Nordica"},
                                    {"k": "request_on_time", "customer": "Palmiye"}, {"k": "alert_clear", "area": "trust"}])
    c["lead"] = ("deniz", "Deniz", L("SSO gecikirse Nordica yenilemez.", "If SSO slips, Nordica won't renew."))
    nxt = {"sprint": 8, "flags": [("deadline", K("PRODUCT_FLAG_DEADLINE", customer="Nordica", request="SSO"))], "cards": [D("efatura", "planlanan")]}
    # every area closed and no scroll: the Müşteriler row shows whole under the area names (an open Güven & Ölçek
    # pushed it past the panel, and scrolling to it started mid-area, S3 27); the SSO card reads in the sprint column
    body = sprint_body(areas, center_plan(c), nxt, "", c["can_add"], customers=customers)
    win = urun_window(kpis_for("Fatura", "B2B · " + L("Faturalama SaaS'ı", "Invoicing SaaS"), "v1.4"), body)
    return shell(win, 13, v=B2B_ECON)


# live run (product__live_*: the theme seed roster through the real SprintSystem) -------------------
def live_areas_none():
    return [A("core", 0, K("PRODUCT_AREA_CORE_NONE")), A("onboarding", 0, K("PRODUCT_AREA_ONBOARDING_NONE")),
            A("growth", 0, K("PRODUCT_AREA_GROWTH_NONE")), A("trust", 0, K("PRODUCT_AREA_TRUST_NONE")),
            A("revenue", 0, K("PRODUCT_AREA_REVENUE_NONE"))]


def LC(key, roles, state, effect=None, **extra):
    c = {"id": key, "name": K(key), "kind": "feature", "area": "core", "roles": roles, "effort": 3, "state": state,
         "effect": effect or [], "tag_sprint": -1, "phases": [], "assignees": [], "decision": None, "locked_node": "",
         "remaining": -1, "spills": False, "urgent": False, "split": []}
    c.update(extra)
    return c


def f_live_active():
    r3 = ["design", "dev", "test"]
    cards = [LC("PROD_STEP_NOTE_TOOL_CAPTURE_K1", r3, "bitti", phases=["done"] * 3, assignees=[]),
             LC("PROD_STEP_NOTE_TOOL_LINKING_K1", r3, "aktif", phases=["done", "done", "active"], assignees=["selin"]),
             LC("PROD_STEP_NOTE_TOOL_SEARCH_K1", r3, "aktif", phases=["active", "waiting", "waiting"], assignees=["elif", "founder"]),
             LC("PROD_STEP_NOTE_TOOL_SYNC_K1", r3, "aktif", phases=["active", "waiting", "waiting"], assignees=["deniz"]),
             LC("PROD_STEP_NOTE_TOOL_EDITOR_K1", r3, "aktif", phases=["active", "waiting", "waiting"], assignees=[],
                decision={"face": "elif", "speaker": "Elif Demir", "text": K("EV_PRODUCT_SPRINT_CONTRACTOR_TITLE")})]
    c = {"sprint": 1, "week": 2, "cards": cards, "used": 15, "total": 15, "done": 3, "team": live_team(), "warning": "",
         "status": (1, 4, 1), "next_version": ("v1.0", 1, 3), "beta": False}
    body = sprint_body(live_areas_none(), center_active(c, scroll=(12, 490, 0, 330)), {"sprint": 2, "flags": [], "cards": []}, "")
    win = urun_window(kpis_for("Notly", notly_type(), "", mvp=True), body, quarter="open")
    return shell(win, 2, badges={"ekip": ("danger", "1"), "olaylar": ("count", "1")}, slot=slot_sprint())


def f_live_b2c_mvp():
    core = A("core", 0, K("PRODUCT_AREA_CORE_WEAK"), level_to=0.5, word_to="weak")
    core["word"] = "none"
    areas = [core, A("onboarding", 0, K("PRODUCT_AREA_ONBOARDING_NONE")), A("growth", 0, K("PRODUCT_AREA_GROWTH_NONE")),
             A("trust", 0, K("PRODUCT_AREA_TRUST_NONE")), A("revenue", 0, K("PRODUCT_AREA_REVENUE_NONE"))]
    shipped = [LC(k, [], "bitti") for k in ("PROD_STEP_NOTE_TOOL_CAPTURE_K1", "PROD_STEP_NOTE_TOOL_LINKING_K1", "PROD_STEP_NOTE_TOOL_SEARCH_K1")]
    r = {"sprint": 1, "version": "v1.0", "beta": False, "beta_open": False, "shipped": shipped,
         "carried": [("feature", K("PROD_STEP_NOTE_TOOL_SYNC_K1"), 1, 3, 2), ("feature", K("PROD_STEP_NOTE_TOOL_EDITOR_K1"), 0, 3, 2)],
         "velocity": (10, 15),
         "result": ("expected", K("PRODUCT_RESULT_LEVEL_EXPECTED", area=ashort("core"), to=word("weak"))),
         "press": None,
         "lead": ("elif", "Elif Demir", K("PRODUCT_LEAD_CARRIED", card=K("PROD_STEP_NOTE_TOOL_SYNC_K1")))}
    core_fx = [{"k": "level", "area": "core", "from": 0.5, "to": 1}]
    nxt = {"sprint": 2, "flags": [], "cards": [
        LC("PROD_STEP_NOTE_TOOL_SYNC_K1", ["design", "dev", "test"], "devreden", effect=[_lv_half(), {"k": "rival_gap"}], remaining=2),
        LC("PROD_STEP_NOTE_TOOL_EDITOR_K1", ["design", "dev", "test"], "devreden", effect=[_lv_half()])]}
    body = sprint_body(areas, center_release(r, 2), nxt, "")
    win = urun_window(kpis_for("Notly", notly_type(), "v1.0"), body, quarter="open")
    return shell(win, 3, badges={"ekip": ("danger", "1")})


def _lv_half():
    return {"k": "level", "area": "core", "from": 0.5, "to": 1}




# type picker -------------------------------------------------------------------
def f_pick():
    """Selected pick card = SPEC §5's selected state: surface-4 + 3 px marker, plus a check (the one grammar shared with
    Atlas's role, level and candidate cards, finding 18)."""
    chk = '<span class="ic pk-ck">%s</span>' % common.raw_svg("check")
    paths = []
    for m, sel in (("b2c", True), ("b2b", False)):
        paths.append('<div class="choice%s"><div class="cr"><span class="ck t-label">%s</span>%s</div><span class="cn t-subhead">%s</span><span class="cd">%s</span></div>'
                     % (" is-selected" if sel else "", K("PROD_PATH_" + m.upper()), chk if sel else "", m.upper(), K("PROD_PATH_%s_DESC" % m.upper())))
    types = []
    for tid, sel in (("NOTE_TOOL", True), ("VIDEO_CLIP", False)):
        types.append('<div class="choice%s"><div class="cr"><span class="cn t-data-strong">%s</span><span class="cat t-micro">%s</span>%s</div>'
                     '<span class="ct">%s</span><span class="cd">%s</span></div>'
                     % (" is-selected" if sel else "", K("PROD_TYPE_%s_NAME" % tid), K("PROD_TYPE_%s_CATEGORY" % tid), chk if sel else "",
                        K("PROD_TYPE_%s_DESC" % tid), K("PROD_TYPE_%s_TRADEOFF" % tid)))
    # PROD_TYPE_STEP_TITLE is a four-word step title, not a label: sentence case (rule 7 caps only up to three words)
    pk = ('<div class="pk"><span class="pk-t t-h2">%s</span><span class="pk-s">%s</span><div class="pk-row">%s</div>'
          '<div class="sec is-title t-subhead">%s</div>%s'
          '<div class="sec t-label">%s</div><div class="pk-name"><span class="input">Notly</span><span class="btn btn-secondary">%s</span></div>'
          '<div class="pk-foot"><span class="btn btn-primary">%s</span></div></div>'
          % (K("PROD_PATH_TITLE"), K("PROD_PATH_SUB"), "".join(paths), K("PROD_TYPE_STEP_TITLE", market="B2C"), "".join(types),
             K("PROD_NAME_LABEL"), L("Öner", "Suggest"), L("Onayla ve başlat", "Confirm and start")))
    body = '<div class="pb"><div class="pcol is-pick" style="align-self:flex-start">%s</div></div>' % pk
    # no control strip: before a product exists there is no sprint to show, no quarter to plan, no history (Q22)
    win = urun_window(kpis_for("", "", "", mvp=True), body, ctl=False)
    return shell(win, 1)


# 1536 ---------------------------------------------------------------------------
def f_c1_1536():
    c = plan_center([D(x, "plan") for x in ("kesinti", "kisa_kayit", "filtreli")])
    body = sprint_body(notly_areas(), center_plan(c, scroll=(12, 300, 0, 230)), notly_next(), "onboarding", c["can_add"],
                       area_scroll=(542, 0, 300))
    win = urun_window(kpis_for("Notly", notly_type(), "v1.4"), body, x=88, y=88, w=1424, h=712)
    top = topbar(HARNESS, 13, 8, slot_end(8), "II", compact=True, W=1536)
    off = '<div class="office is-dimmed" style="background-image:url(%s%s)"></div>' % (REL, OFFICE["1536"])
    return '<div class="screen">%s%s%s%s%s</div>' % (off, win, top, rail("urun", None, icons=True), kit.ticker())


# card-state sheet ----------------------------------------------------------------
def f_cards():
    def g(label, meta, html, width, ground="", extra=""):
        return ('<div class="sg-c"><div class="sg-k"><span class="t-label">%s</span><span class="m">%s</span></div>'
                '<div class="sg-g %s" style="width:%dpx%s">%s</div></div>' % (label, meta, ground, width + 26, extra, html))
    cand_w, cen_w, nxt_w = 362, 550, 282
    lock = D("akilli_arama", "kilitli", locked_node=K("PRODUCT_LOCKED_NODE", node=L("Gelişmiş arama", "Advanced search")))
    cells = [
        g("ADAY", L("aday · + bu sprinte, → sonrakine", "candidate · + this sprint, → next"), card(D("mobil_giris", "aday"), raised=True, narrow=True), cand_w, "raised"),
        g("ADAY · " + L("acil", "urgent"), L("3+ ticket · listede üstte", "3+ tickets · top of the list"), card(D("gorusme", "aday", urgent=True), raised=True, narrow=True), cand_w, "raised"),
        g("ADAY_ALINMIS", L("bu ya da sonraki sprintte", "in this or the next sprint"), card(D("ilk_tur", "alinmis", tag_sprint=8), raised=True, narrow=True), cand_w, "raised"),
        g("KILITLI", L("Ar-Ge düğümü bekliyor · + ve → kapalı", "waits for an R&D node · + and → closed"), card(lock, raised=True, narrow=True), cand_w, "raised"),
        g("SPRINT_PLAN · " + L("üstünde", "hover"), L("efor dökümü · → ve Çıkar", "effort split · → and Remove"),
          card(D("kisa_kayit", "plan"), hover=True), cen_w, "", ";margin-top:44px"),
        g("SPRINT_PLAN · " + L("devreder", "spills"), L("kapasiteyi aşan kart", "a card past capacity"), card(D("mobil_giris", "plan", spills=True)), cen_w),
        g("SPRINT_AKTIF", L("fazlar · bu haftanın atananları", "phases · this week's people"),
          card(D("kisa_kayit", "aktif", phases=["done", "done", "active"], assignees=["ece", "kaan"])), cen_w),
        g("SPRINT_AKTIF · " + L("karar", "decision"), L("kağıt Olaylar'da · kart orada cevaplanmaz", "the paper waits in Events · never answered here"),
          card(active_cards_c2()[2]), cen_w),
        g("BITTI", L("üç faz dolu · damga", "three phases done · stamp"), card(active_cards_c2()[0]), cen_w),
        g("PLANLANAN", L("sonraki sütun · kesikli", "next column · dashed"), card(D("etiketler", "planlanan"), narrow=True), nxt_w, "bare"),
        g("DEVREDEN", L("kalan puanıyla", "with its remaining points"), card(D("oto_yedek", "devreden", remaining=2), narrow=True), nxt_w, "bare"),
        g("BETA_BEKLIYOR", L("kapasite tüketmez", "uses no capacity"), card(D("baglanti", "beta")), cen_w),
        g(L("ÇEYREK · MİNİ", "QUARTER · MINI"), L("bu sprint ve PM önerisi", "this sprint and the PM's proposal"),
          '<div style="display:flex;gap:12px">%s%s</div>' % (
              '<div style="width:150px">%s</div>' % card(D("kisa_kayit", "plan"), mini=True),
              '<div style="width:150px">%s</div>' % card(D("ilk_tur", "planlanan"), mini=True)), 312),
        g(L("ADAYSIZ ALAN", "NO CANDIDATES"), L("alanda yapılacak kart kalmadı", "nothing left to build in the area"),
          '<div class="empty-l">%s%s</div>' % (ic("check"), K("PRODUCT_AREA_NOTHING_LEFT")), cand_w, "raised"),
        g(L("TALEP · B2B", "REQUEST · B2B"), L("Müşteriler satırı · bu ya da sonraki sprintin son tarihi uyarı renginde", "Customers row · a deadline this sprint or next in warn"),
          customers_row([{"name": "Nordica", "request": "SSO", "tag": -1, "due": 8, "value": 12000, "area": ashort("trust")}]), cand_w + 16, "bare"),
    ]
    head = ('<div class="sheet-h"><span class="t t-h2">%s</span><span class="s">%s</span></div>'
            % (L("Sprint kartı durumları", "Sprint card states"),
               L("SprintCard.State · her kart gerçek sütun genişliğinde (aday 362, bu sprint 550, sonraki 282, çeyrek 150) · fikstür verisi",
                 "SprintCard.State · each card at its real column width (candidate 362, this sprint 550, next 282, quarter 150) · fixture data")))
    return '<div class="screen"><div class="sheet">%s<div class="sg">%s</div></div></div>' % (head, "".join(cells))


# the inbox the decision row points to (group olaylar's mail grammar) ---------------
# The mail header's date column, as group olaylar measures it: the worst TR and EN date, Godot slack included.
import measure  # noqa: E402

DATE_W = max(measure.godot(w) for w in measure.measure(
    [("tr%d" % i, "t-meta", "Hafta 52 · %s 2026 · 09:00" % m, "tr") for i, m in enumerate(MON_TR)]
    + [("en%d" % i, "t-meta", "Week 52 · %s 2026 · 09:00" % m, "en") for i, m in enumerate(MON_EN)]).values())


def f_inbox_paper():
    """Group olaylar's employee mail (DRAFTS "Mailin ortak parçaları"): greeting MAIL_GREETING_TEAM, the body, the
    structural signature, no closing line; the date sits in the To line's fixed right column. The body is the card's
    text today: the full rewrite in the PM's voice is olaylar's conversion step (Q23)."""
    to = L("Kurucu · Unicorn Inc.", "Founder · Unicorn Inc.")
    subj = K("EV_PRODUCT_SPRINT_CONTRACTOR_TITLE")
    body_txt = L("Metin Editörü burada kimsenin daha önce yapmadığı bir iş istiyor. Bir serbest çalışan o kısmı çabuk bitirir. İçeride öğrenmek daha uzun sürer.",
                 "Text Editor needs something nobody here has done before. A contractor could do that part quickly. Learning it in house takes longer.")
    rows = (kit.ib_row("Elif Demir", "product", subj, ic("clock") + T("wk_this"), body_txt, "is-unread is-lastweek is-selected")
            + '<div class="ib-day t-caption">%s</div>' % date(1)
            + kit.ib_row("Frank Köseoğlu", "mentor", L("Ben Frank", "It's Frank"), "09:00",
                         L("Eski şirketten hatırlarsın. İstifa ettin mi, yoksa hâlâ düşünüyor musun?",
                           "You'll remember me from your old company. Did you quit, or are you still thinking about it?"), ""))
    tabs = "".join('<span class="seg-tab t-tab%s">%s<span class="n">%d</span></span>' % (" is-active" if i == 0 else "", T(k), c)
                   for i, (k, c) in enumerate(zip(("f_all", "f_wait", "f_unread"), (2, 1, 1))))
    listcol = '<div class="ib-list"><div class="ib-head"><div class="seg">%s</div></div>%s</div>' % (tabs, rows)
    kicker = ('<div class="pane-kicker">%s<span class="kind t-meta">%s</span><span class="sep">·</span><span class="state t-meta is-warn">%s</span></div>'
              % (pill("product"), L("Kağıt", "Paper"), T("last_week")))
    header = ('<div class="mh">%s<div class="mh-who"><div class="mh-l1"><span class="n">Elif Demir</span><span class="r">%s</span></div>'
              '<div class="mh-l2"><span class="k">%s</span><span class="v">%s</span><span class="mh-date" style="width:%dpx">%s</span></div></div></div>'
              % (av("elif", 40), T("r_pm"), L("Kime", "To"), to, DATE_W, date(2)))
    mbody = ('<div class="mbody"><p>%s</p><p>%s</p></div><div class="msig"><span class="n">Elif Demir</span><span class="r">%s · Unicorn Inc.</span></div>'
             % (L("Merhaba,", "Hi,"), body_txt, T("r_pm")))
    pbar = ('<div class="paper-bar"><span class="when t-key is-lastweek">%s%s</span><span class="btn btn-primary">%s%s</span></div>'
            % (ic("clock"), T("last_week"), ic("reply"), T("reply")))
    reply = '<div class="reply"><div class="reply-head"><span class="lbl t-label">%s</span></div>%s</div>' % (L("Cevabın", "Your reply"), pbar)
    pane = ('<div class="pane"><div class="pane-top"><div class="pane-col">%s<div class="subj-row"><h2 class="pane-title t-h2">%s</h2></div>%s%s</div>%s</div>%s</div>'
            % (kicker, subj, header, mbody, common.portrait(FACE["elif"], 256, 320), reply))
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><div class="win-kpis"><div class="kpi"><span class="kpi-key t-label">%s</span>'
            '<span class="kpi-val t-kpi warn">%s</span></div></div><div class="grow"></div><span class="win-close">%s</span></div>'
            % (T("ev_title"), T("k_soonest"), T("this_week"), ic("close")))
    win = '<section class="win" style="left:208px;top:88px;width:1240px;height:900px">%s<div class="ib">%s%s</div></section>' % (head, listcol, pane)
    # the stack row carries the paper's time left like kabuk's ("Nordica · Bir ekip daha · 2 hafta"): final week in warn
    notice = kit.notice("position:absolute;left:1544px;top:964px", "is-info", "Elif Demir", subj,
                        more='<span class="nwk is-warn">%s</span>' % T("wk_this"))
    top = topbar(HARNESS, 2, 8, slot_sprint(), "II")
    off = '<div class="office is-dimmed" style="background-image:url(%s%s)"></div>' % (REL, OFFICE["ishani"])
    return '<div class="screen">%s%s%s%s%s%s</div>' % (off, notice, win, top, rail("olaylar", {"ekip": ("danger", "1"), "olaylar": ("count", "1")}), kit.ticker())


FRAMES = {
    "urun__sprint_planlama": ("tr", f_c1),
    "urun__sprint_planlama_en": ("en", f_c1),
    "urun__sprint_suruyor": ("tr", f_c2),
    "urun__sprint_otomatik_basladi": ("tr", f_c2_auto),
    "urun__sesler_acik": ("tr", f_voices),
    "urun__surum_notu": ("tr", f_c3),
    "urun__surum_notu_en": ("en", f_c3),
    "urun__surum_notu_beta": ("tr", lambda: f_c3(True)),
    "urun__ceyrek": ("tr", f_c4),
    "urun__ceyrek_hedef_menusu": ("tr", lambda: f_c4(True)),
    "urun__ceyrek_kilitli_pm_yok": ("tr", f_quarter_locked),
    "urun__gecmis": ("tr", f_history),
    "urun__tur_secici": ("tr", f_pick),
    "urun__mvp_oncesi_karar": ("tr", f_live_active),
    "urun__b2c_mvp_surum": ("tr", f_live_b2c_mvp),
    "urun__b2b_talepler": ("tr", f_c5),
    "urun__kapasite_asimi": ("tr", f_over),
    "urun__ekip_yok": ("tr", f_nobody),
    "urun__sprint_planlama_1536": ("tr", f_c1_1536),
    "urun__kart_durumlari": ("tr", f_cards),
    "olaylar__sprint_karari_kagit": ("tr", f_inbox_paper),
}
W1536 = {"urun__sprint_planlama_1536"}
OLAYLAR_CSS = {"olaylar__sprint_karari_kagit"}


def build(names):
    global LANG
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        lang, fn = FRAMES[n]
        LANG = lang
        set_lang(lang)
        extra = ("../../olaylar/olaylar.css",) if n in OLAYLAR_CSS else ()
        html = page(fn(), w1536=n in W1536, css_extra=extra)
        with open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8") as f:
            f.write(html)
        print(os.path.join(BUILD, n + ".html"))
    set_lang("tr")


if __name__ == "__main__":
    build(sys.argv[1:] or list(FRAMES))
