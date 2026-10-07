"""Toplantı (meetings): builds every frame of group "toplanti" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only
  python gen.py --sizes    print each frame's css size

Render with render_all.sh (calls the menajer render.sh per frame; 1536 frames at 1536x864, scale 1.25). The system
kit (tokens.css, base.css, icons, crop rule, top bar geometry) is read from ../../../system through the copies in
syskit/, whose caches live in this folder, so nothing is ever written into the system folder.

The shell has one implementation and one owner, group kabuk: the top bar, rail and ticker, the office plate with the
A2 head sprites, the BuildHUD, notice stack, move button and toast, and the city-map trip (road, founder disc, chips,
skip hint) are drawn by ../../kabuk/tools/gen.py with ../../kabuk/kabuk.css, read only. A change there reaches these
frames on the next build. This file draws only what the meeting adds: the phone ring and call card, the dock, the
price act and the term sheet table.

Data: the sales frames stand on the theme seed (docs/mockups/menajer/data/screens.md: week 14, Unicorn Inc., the
Karadeniz Fabrika lead and its two people from art/busts/counterparts.json); the VC frames on the --meeting-shot
harness state (week 9, Series A, MRR $125K, fund Meridian Growth); the dialogue is the game's own CSV text as the
baseline frames show it, PH: prefixes dropped, dashes rewritten (INDEX.md lists every change).
"""
import importlib.util
import math
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
from common import T, ic, num, set_lang  # noqa: E402
from kit import tag  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


def _load_kabuk():
    """Group kabuk's generator as a module. Its syskit is a byte-identical copy of this one and its modules are
    already imported from here, so its sys.path entry is dropped again once it has loaded."""
    path = os.path.normpath(os.path.join(ROOT, "..", "kabuk", "tools", "gen.py"))
    spec = importlib.util.spec_from_file_location("kabuk_gen", path)
    mod = importlib.util.module_from_spec(spec)
    saved = list(sys.path)
    spec.loader.exec_module(mod)
    sys.path[:] = saved
    return mod


kb = _load_kabuk()
common._src = _src  # avatar() and portrait() resolve image paths through this


def P(rel):
    return os.path.join(MEN, *rel.split("/"))


def L(tr, en):
    return tr if common.LANG == "tr" else en


def l(v):
    """A bilingual constant (tr, en) in the frame's language; a plain string is data (a name) and passes through."""
    return v if isinstance(v, str) else L(*v)


FRANK = P("portraits/frank_cand_a.png")
FOUNDER = P("portraits/founder_01.png")
PHONE = REL + "system/icons/office/phone.svg"

# ------------------------------------------------------------------ people (art/busts/counterparts.json; roles MEETING_ROLE_* / INV_ROLE_*)
ELIF = dict(name="Elif Yıldız", first="Elif", role=("Satın Alma Sorumlusu", "Procurement Lead"), bust=P("art/busts/prospect/bust_lead_14_2_0_buyer.png"))
SENA_U = dict(name="Sena Uysal", first="Sena", role=("Ekip Yöneticisi", "Team Manager"), bust=P("art/busts/prospect/bust_lead_14_2_1_user_lead.png"))
TOLGA = dict(name="Tolga Erdem", first="Tolga", role=("Büyüme Ortağı", "Growth Partner"), bust=P("art/busts/vc/bust_meridian_0_vc_lead.png"))
SENA_K = dict(name="Sena Koç", first="Sena", role=("Ortak", "Partner"), bust=P("art/busts/vc/bust_meridian_1_vc_partner.png"))
KAAN = dict(name="Kaan Demir", first="Kaan", role=("Analist", "Analyst"), bust=P("art/busts/vc/bust_meridian_2_vc_analyst.png"))
POLAT = dict(name="Tolga Polat", first="Tolga", role=("Kurucu Ortak", "Founding Partner"), bust=P("art/busts/vc/bust_bosphorus_0_vc_lead.png"))
KEREM = dict(name="Kerem Kaya", first="Kerem", role=("Kıdemli Ortak", "Senior Partner"), bust=P("art/busts/vc/bust_anchor_0_vc_lead.png"))
# the theme seed's founder (data/crowd40.json char_founder); in the game this is the name the player typed
FOUNDER_NAME = ("Kurucu", "Founder")
KF = "Karadeniz Fabrika"
MG = "Meridian Growth"

# ------------------------------------------------------------------ worlds: kabuk's top bar values, week, phase, rail badges
SALES = dict(tb=kb.SEED, week=14, phase=1, badges=kb.B14)
VC = dict(tb=dict(kb.SEED, cash="$48.000", net="+$124K", mrr="$125K"), week=9, phase=3, badges={})
VC_SEED = dict(VC, phase=2)
VC_RET = dict(VC, tb=dict(VC["tb"], brand="47"))


# ------------------------------------------------------------------ new strings (EN first; INDEX.md lists them for approval)
S = {
    "held_key": ("In a meeting", "Görüşmede"),
    "trip_home": ("Back to the office", "Ofise dönüş"),
    "k_sales": ("Sales meeting", "Satış görüşmesi"), "k_vc": ("Investor meeting", "Yatırımcı görüşmesi"),
    "k_seed": ("Seed meeting", "Seed görüşmesi"),
    "b1": ("Read the room · 1/4", "Odayı oku · 1/4"), "b2": ("Narrative · 2/4", "Anlatı · 2/4"),
    "b3": ("Interrogation · 3/4", "Sorgu · 3/4"), "b4": ("Closing · 4/4", "Kapanış · 4/4"),
    "price": ("The number", "Rakam"),
    "invite_kick": ("Incoming call · {h}:00", "Gelen arama · {h}:00"),
    "table_key": ("At the table", "Masada"),
    "offer_row": ("Offer · {price}", "Teklif · {price}"),
    "counter_row": ("Their number · {price}", "Karşı rakam · {price}"),
    "deal_if": ("If you accept: {line}", "Kabul edersen: {line}"),
    "spin": ("Spin: turn the weakness into a strength.", "Parlat: zayıflığı güce çevir."),
    "deflect_cap": ("Little to lose, but the table stops here ({cap} ceiling).", "Kaybı az, ama masa buradan çıkmaz ({cap} tavan)."),
    "odds_result": ("Odds and result", "Şans ve sonuç"),
    "push_chance": ("Push chance", "İtme şansı"), "last_roll": ("Last roll", "Son zar"),
    "cash_runway": ("Cash: {cash} · Runway: {runway}", "Kasa: {cash} · Runway: {runway}"),
}


def s(key, **kw):
    en, tr = S[key]
    v = L(tr, en)
    return v.format(**kw) if kw else v


def end_in(n):
    return L("Mesai bitimi · %d saat" % n, "Workday ends · %d h" % n)   # SPEC §13 "Workday ends · {n} h"


# ------------------------------------------------------------------ shell (kabuk)
def topbar(world, clock, slot, speed="II", W=1920, compact=False, marks=()):
    """kabuk's top bar. slot: ("next", text, kind) up next | ("now", text) the founder's trip | ("held", text) the
    sitting. The trip and the sitting both hold the clock: keys off, no amber (amber is the inbox gate's). The
    sitting's label says Görüşmede where the trip's says Şimdi."""
    held = slot[0] != "next"
    html = kb.topbar(world["tb"], W=W, compact=compact, slot=("now", slot[1]) if held else slot, speed=speed,
                     week=world["week"], clock=clock, marks=marks, phase=world["phase"], held=held)
    if slot[0] == "held":
        old = ">%s</span>" % kb.s("now")
        assert old in html, "kabuk's slot label markup changed"
        html = html.replace(old, ">%s</span>" % s("held_key"), 1)
    return html


def shell(world, W=1920, compact=False):
    return kb.rail(None, world["badges"], icons=compact) + kb.ticker()


def office_floats(world):
    """kabuk's office floats: BuildHUD, notice stack (the week-14 seed inbox; the VC harness world has none), move
    button."""
    return kb.seed_floats() if world is SALES else kb.seed_floats(notes=[])


def office_ishani(ring=False):
    """kabuk's İş hanı layer: the noicons plate plus the A2 head sprites. While the phone rings the founder's head slot
    carries the ring, so the founder's activity sprite is left out."""
    html = kb.office("ishani", 184, 64, 1736, 976)
    if ring:
        f = next(p for p in kb.heads("ishani") if p.get("founder"))
        key = "left:%.1fpx;top:%.1fpx;" % (f["icon_xy"][0] - f["icon_px"] / 2, f["icon_xy"][1] - f["icon_px"] / 2)
        html, n = re.subn(r'<img class="head-ic"[^>]*%s[^>]*>' % re.escape(key), "", html)
        assert n == 1, "kabuk's head sprite markup changed"
    return html


# ------------------------------------------------------------------ page
def page(body, W=1920, H=1080, title="Toplantı"):
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../../kabuk/kabuk.css"><link rel="stylesheet" href="../toplanti.css">'
            '<style>html,body{width:%dpx;height:%dpx}</style></head>'
            '<body><div class="screen" style="width:%dpx;height:%dpx">%s</div><script>%s</script></body></html>'
            % (common.LANG, title, common.FONTS, REL, REL, W, H, W, H, body, FLOW_JS))


# The transcript is a ScrollContainer that follows its newest row: the newest row always sits on the deck; when the
# rows outgrow the panel the older ones scroll away under a 24 px fade and the bar shows how much.
FLOW_JS = ("document.fonts.ready.then(function(){document.querySelectorAll('.dk-flow').forEach(function(f){"
           "var i=f.querySelector('.dk-flow-in'),sb=f.querySelector('.dk-sb'),H=f.clientHeight,h=i.scrollHeight;"
           "if(h<=H){if(sb)sb.remove();}"
           "else{f.classList.add('is-scrolled');if(sb){var r=H/h,t=sb.querySelector('.sb-thumb');t.style.height=(r*100)+'%';t.style.top=((1-r)*100)+'%';}}});});")


def meet_room(W=1920, H=1080, compact=False):
    """The meeting room plate in the safe rect. At 1536 the 1920 capture is scaled to the view's width and cropped at
    the bottom (no 1536 capture of this room exists)."""
    x = 64 if compact else 184
    vw, vh = W - x, H - 64 - 40
    sw, sh = (vw, round(976 * vw / 1736)) if compact else (1736, 976)
    return ('<div class="office" style="left:%dpx;width:%dpx;height:%dpx;background-image:url(%sart/office_safe_1920_meet_dock.png);'
            'background-size:%dpx %dpx;background-position:0 0"></div>' % (x, vw, vh, REL, sw, sh))


# ------------------------------------------------------------------ dock parts
def av(path, size, extra=""):
    return common.avatar(path, size, extra)


def kicker(*parts):
    out = []
    for i, p in enumerate(parts):
        if i:
            out.append('<span class="sep">·</span>')
        out.append('<span%s>%s</span>' % (' class="now"' if i == len(parts) - 1 and len(parts) > 1 else "", p))
    return '<div class="dk-kick t-meta">%s</div>' % "".join(out)


def who(person, company, cast, speaking, stars=None, read=None):
    rd = ""
    if stars is not None:
        rd = '<div class="dk-read t-caption">%s<span>%s</span></div>' % (kit.stars(stars), l(read) if read else "")
    seats = "".join('<span class="seat3%s">%s<span class="n">%s</span></span>' % (" is-on" if p is speaking else "", av(p["bust"], 24), p["first"])
                    for p in cast)
    return ('<div class="dk-who">%s<div class="dk-id"><div class="dk-name t-h2">%s</div><div class="dk-role t-meta">%s · %s</div>%s</div></div>'
            '<div class="dk-seats"><span class="k t-label">%s</span><div class="v">%s</div></div>'
            % (av(person["bust"], 96), person["name"], l(person["role"]), company, rd, s("table_key"), seats))


WORD = {"warm": ("sıcak", "warm"), "lukewarm": ("ılık", "lukewarm"), "wary": ("temkinli", "wary"), "cold": ("soğuk", "cold")}


def band(v, warm, lukewarm):
    return "warm" if v >= warm else "lukewarm" if v >= lukewarm else "wary" if v >= 25 else "cold"


def tutum(v, warm, lukewarm=40, odds=False):
    """One neutral fill: the band is the word tag and the notches (a cold room is not danger; only a warm room is
    tagged in pos)."""
    b = band(v, warm, lukewarm)
    notch = "".join('<i class="tut-notch" style="left:%d%%"></i>' % n for n in (25, lukewarm, warm))
    fill = '<i class="tut-fill" style="width:%d%%"></i>' % v
    now = '<i class="tut-now" style="left:%.1f%%"></i>' % min(max(v, 1.5), 98.5)
    t = tag(l(WORD[b]), "pos" if b == "warm" else "outline")
    o = '<span class="odds t-key">%s</span>' % L("İkna %%%d" % v, "Persuasion %d%%" % v) if odds else ""
    return ('<div class="tut"><span class="k t-label">%s</span><div class="tut-track">%s%s%s</div>%s%s</div>'
            % (L("Tutum", "Attitude"), fill, notch, now, t, o))


def patience(cur, mx, label=True):
    boxes = "".join('<i class="%s"></i>' % ("off" if i >= cur else ("last" if cur == 1 else "")) for i in range(mx))
    k = '<span class="k t-label">%s</span>' % L("Sabır", "Patience") if label else ""
    return '<div class="pat">%s<div class="b">%s</div></div>' % (k, boxes)


def memory(text):
    return '<div class="dk-mem"><span class="k t-label">%s</span><span class="v t-meta">%s</span></div>' % (L("Hafıza", "Memory"), l(text))


def head(kick, inner):
    return '<div class="dk-head">%s%s</div>' % (kick, inner)


# transcript rows
def cp(p, text, past=False):
    return ('<div class="tr%s">%s<div class="tr-b"><div class="tr-n t-key">%s</div><div class="tr-t t-para">%s</div></div></div>'
            % (" is-past" if past else "", av(p["bust"], 32), p["name"], l(text)))


def you(text, pill=None, ok=None, past=False):
    """The founder's line. A roll that passed carries a pos ✓ tag; one that failed a neutral ✕ outline tag (a failed
    roll is not danger)."""
    pl = ""
    if pill:
        pl = '<span class="tag %s">%s%s</span>' % ("tag-pos" if ok else "tag-outline", ic("check" if ok else "close"), l(pill))
    return ('<div class="tr is-you%s">%s<div class="tr-b"><div class="tr-n t-key">%s%s</div><div class="tr-t t-para">%s</div></div></div>'
            % (" is-past" if past else "", av(FOUNDER, 32), l(FOUNDER_NAME), pl, l(text)))


def quiet(text, past=False):
    return '<div class="tr-quiet t-meta%s">%s</div>' % (" is-past" if past else "", l(text))


def frank(text, past=False):
    return ('<div class="tr is-frank%s">%s<div class="tr-b"><div class="tr-n t-key">Frank Köseoğlu</div><div class="tr-t">%s</div></div></div>'
            % (" is-past" if past else "", av(FRANK, 32), l(text)))


def figure(p, text, past=False):
    face = av(FOUNDER, 32) if p is None else av(p["bust"], 32)
    name = l(FOUNDER_NAME) if p is None else p["name"]
    return ('<div class="tr is-figure%s">%s<div class="tr-b"><div class="tr-n t-key">%s</div><div class="tr-t">%s</div></div></div>'
            % (" is-past" if past else "", face, name, l(text)))


def R(fn, *a, **k):
    """A transcript row whose `past` is decided when its step is placed."""
    return lambda past: fn(*a, past=past, **k)


def played(*steps):
    """Rows of every step; all but the last step are past (the panel dims a played beat when the next one plays)."""
    last = len(steps) - 1
    return [r(i < last) for i, st in enumerate(steps) for r in st]


def flow(rows):
    sb = '<div class="sb dk-sb"><div class="sb-thumb"></div></div>'
    return '<div class="dk-flow"><div class="dk-flow-in">%s</div>%s</div>' % ("".join(rows), sb)


# deck
DIE = {"safe": ("güvenli", "safe"), "risky": ("riskli", "risky"), "danger": ("tehlikeli", "dangerous")}


def mo(n, label, sub=None, danger=False, die=None, marker=None, locked=False, cmd=False, cls=""):
    k = '<span class="kcap">%s</span>' % (ic("lock") if locked else n)
    parts = ['<div class="mo-l%s">%s</div>' % (" cmd" if cmd else "", l(label))]
    if marker:
        parts.append(tag(l(marker), "outline"))
    if sub:
        parts.append('<div class="mo-s%s">%s</div>' % (" danger" if danger else "", l(sub)))
    d = ""
    if die:
        d = '<span class="mo-die %s">%s%s</span>' % (die, ic("dice"), l(DIE[die]))
    return '<div class="opt mo%s%s">%s<div class="mo-c">%s</div>%s</div>' % (" is-locked" if locked else "", (" " + cls) if cls else "", k, "".join(parts), d)


def opts(items):
    return '<div class="dk-opts">%s</div>' % "".join(items)


def mres(kind, title, rows, stamp=None):
    glyph = {"pos": "check", "neg": "close", "warn": "calendar"}[kind]
    st = kit.stamp(stamp) if stamp else ""
    rs = "".join('<div class="mres-r"><span class="k t-label">%s</span><span class="v">%s</span></div>' % (l(k), l(v)) for k, v in rows if v)
    return ('<div class="mres"><div class="mres-h %s">%s<span class="t-cta">%s</span>%s</div>%s</div>'
            % (kind, ic(glyph), l(title), st, rs))


def foot(cont=None, withdraw=False):
    w = '<span class="btn btn-secondary btn-sm">%s</span>' % L("Toplantıdan çekil", "Withdraw from the meeting") if withdraw else ""
    c = ('<span class="btn btn-primary">%s%s</span>' % (l(cont), ic("enter"))) if cont else ""
    return '<div class="dk-foot">%s%s</div>' % (w, c)


def deck(*parts):
    return '<div class="dk-deck">%s</div>' % "".join(parts)


def dock(width, head_html, flow_html, deck_html):
    return '<aside class="dock" style="width:%dpx">%s%s%s</aside>' % (width, head_html, flow_html, deck_html)


CAP = ("Kapasite: 63/261", "Capacity: 63/261")


def ruler(selected, counters=(), anchor=50, insult_from=59, deal=None, lo=30, hi=70):
    pos = lambda v: (v - lo) / (hi - lo) * 100
    ins = '<i class="rul-ins" style="left:%.2f%%;right:0"></i>' % pos(insult_from) if insult_from < hi else ""
    ctr = "".join('<i class="rul-ctr%s" style="left:%.2f%%"></i>' % (" is-now" if i == len(counters) - 1 else "", pos(c)) for i, c in enumerate(counters))
    insulting = selected >= insult_from
    g = '<i class="rul-g%s" style="left:%.2f%%"></i>' % (" is-insult" if insulting else "", min(max(pos(selected), 1.2), 98.8))
    a = '<i class="rul-anchor" style="left:%.2f%%"></i>' % pos(anchor)
    return ('<div class="rul"><div class="rul-rail"><i class="rul-t"></i>%s%s%s%s</div>'
            '<div class="rul-scale"><span class="end">$%d</span><span class="held"><span class="k t-label">%s</span>'
            '<span class="v t-value%s">$%d</span></span><span class="end">$%d</span></div>'
            '<div class="rul-deal t-value">%s</div><div class="rul-cap t-caption">%s</div></div>'
            % (ins, a, ctr, g, lo, L("Koltuk fiyatı", "Seat price"), " neg" if insulting else "", selected, hi, deal, l(CAP)))


DOCK_W = {1920: 590, 1536: 500}   # 0.34 of the office view (1736 / 1472 wide)


def meeting_screen(world, clock, slot, dock_html, compact=False, W=1920, H=1080):
    return (meet_room(W, H, compact) + dock_html
            + topbar(world, clock, ("held", slot), W=W, compact=compact, marks=(clock,)) + shell(world, W, compact))


# ------------------------------------------------------------------ sales sitting: Karadeniz Fabrika, 2 stars, ops_cautious
# Each step is what one pick (or the opening) puts in the transcript; a played step stays one ink step down.
READ_KF = ("Ölçülü bir alıcı. Önce kararlılığı sorar.", "A measured buyer. Stability comes first.")
Q1 = ("Geçiş ne kadar sürer? İki kere sistem değiştirdik, ikisi de uzadı.", "How long is the switch? We have done this twice and both ran long.")
IV1 = ("Kimse acele etmiyor. Bu iyiye de kötüye de gidebilir.", "Nobody is hurrying. That can go either way.")
A1 = [("Geçiş paralel yürür. İlk hafta iki sistem birlikte çalışır.", "The switch runs in parallel. Both systems run together the first week."),
      ("Verinizi görmeden tarih vermek istemem.", "I will not give you a date before I see your data."),
      ("Geçişi biz yürütürüz ve takvimi yazılı veririm.", "We run the switch and I put the schedule in writing.")]
Q2 = ("Veri nerede duruyor? Altyapıyı kimden alıyorsunuz?", "Where does the data sit? Who do you buy infrastructure from?")
A2_LOCK = (("Altyapı kurumsal kademede. Güvence tarafı hazır.", "Infrastructure is on the enterprise tier. The assurance side is ready."),
           ("Sağlayıcın kurumsal kademede değil.", "Your provider is not on the enterprise tier."))
A2_ADMIT = ("Altyapı henüz o kademede değil. Bugünkü hâli bu.", "Infrastructure is not on that tier yet. This is where it stands.")
SKIP = ("Teklife geç", "Skip to the offer")
Q3 = "Bir sorun çıktığında kimi arıyorum?"
A3 = "Ayrı bir müşteri ekibimiz yok. Bu yüzden bizzat ben ilgileniyorum."
WIN = "Sorularım bitti. Rakamı konuşalım."
CAST_KF = [ELIF, SENA_U]
SALES_SLOT = "14:00 · %s" % KF
SS0 = [R(cp, ELIF, Q1), R(quiet, IV1)]
SS1 = [R(you, A1[0]), R(cp, SENA_U, Q2)]
SS2 = [R(you, A2_ADMIT), R(cp, ELIF, Q3)]
SS3 = [R(you, A3), R(cp, ELIF, WIN)]
SS_OFFER = [lambda past: figure(None, s("offer_row", price="$55"), past=past),
            lambda past: figure(ELIF, s("counter_row", price="$46"), past=past)]


def sales_head(speaking, tut=None, pat=None, beat=None):
    k = kicker(s("k_sales"), beat) if beat else kicker(s("k_sales"))
    inner = who(speaking, KF, CAST_KF, speaking, stars=2, read=READ_KF)
    inner += tutum(*tut, odds=True) if tut else ""
    inner += patience(*pat) if pat else ""
    return head(k, inner)


def f_satis_probe():
    d = dock(590, sales_head(ELIF, (69, 72)), flow(played(SS0)),
             deck(opts([mo(1, A1[0]), mo(2, A1[1]), mo(3, A1[2])])))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_satis_locked():
    d = dock(590, sales_head(SENA_U, (34, 72)), flow(played(SS0, SS1)),
             deck(opts([mo(0, A2_LOCK[0], A2_LOCK[1], locked=True), mo(1, A2_ADMIT), mo(2, SKIP, die="danger")])))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_satis_won():
    d = dock(590, sales_head(ELIF, (66, 72)), flow(played(SS0, SS1, SS2, SS3)), deck(foot("Rakamı konuş")))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_satis_lost():
    steps = ([R(cp, ELIF, "İhtiyacımız olan kademe listede var ama kapalı görünüyor."), R(quiet, IV1)],
             [R(you, "O kademeyi açarız ve tarihini yazılı veririm."), R(cp, ELIF, "Kararlılık bizim için birinci konu ve orası bugün açık.")])
    card = mres("neg", "Anlaşma olmadı", [("Masaya etkisi", "4 hafta bu şirkete dönülemez"),
                                         ("İlişki", "Elif Yıldız: soğuk → soğuk"),
                                         ("Hafızaya yazılan", "Geçen sefer kesintiler konuşulmuştu.")])
    d = dock(590, sales_head(ELIF, (5, 72)), flow(played(*steps)), deck(card, foot("Devam")))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


# price act: 19 seats (SEAT_BAND 2 stars 15-30, mix_unit lead_14_2), anchor $50 (standard stance), reserve $46,
# insult line $59 (ops_cautious 0.92, margin 0.28), patience 3
def deal(price):
    return "19 koltuk × $%d = $%s MRR" % (price, "{:,}".format(19 * price).replace(",", "."))


def price_opts(insult=False, accept=False):
    """An offer in the insult zone stays pickable; its reason is a persistent neg-ink line under it, not a tooltip."""
    items = [mo(1, "Teklif et", "Bu rakam masayı devirir." if insult else None, danger=insult, cmd=True, cls="is-alert" if insult else "")]
    if accept:
        items.append(mo(2, "Kabul et", cmd=True))
    items.append(mo(3 if accept else 2, "Masadan kalk", cmd=True))
    return opts(items)


def price_dock(w, pat, steps, ruler_html, opts_html):
    return dock(w, sales_head(ELIF, pat=pat, beat=s("price")), flow(played(*steps)), deck(ruler_html, opts_html))


def f_satis_handoff():
    d = price_dock(590, (3, 3), (SS0, SS1, SS2, SS3, []), ruler(50, deal=deal(50)), price_opts())
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_pazarlik_open_1536():
    d = price_dock(500, (3, 3), (SS0, SS1, SS2, SS3, []), ruler(50, deal=deal(50)), price_opts())
    return meeting_screen(SALES, 14, SALES_SLOT, d, compact=True, W=1536, H=864)


def f_pazarlik_countered():
    # the held price is your offer; the deal line is what accepting their number signs, so it says so
    d = price_dock(590, (2, 3), (SS0, SS1, SS2, SS3, SS_OFFER), ruler(55, counters=(46,), deal=s("deal_if", line=deal(46))),
                   price_opts(accept=True))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_pazarlik_insult():
    d = price_dock(590, (3, 3), (SS0, SS1, SS2, SS3, []), ruler(62, deal=deal(62)), price_opts(insult=True))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


def f_pazarlik_confirm():
    card = mres("pos", "Anlaşma imzalandı", [("Masaya etkisi", "%s · Kapasite: 63/261" % deal(46)),
                                            ("İlişki", "Elif Yıldız: ılık → ılık")], stamp="İmzalandı")
    d = dock(590, sales_head(ELIF, pat=(2, 3), beat=s("price")), flow(played(SS0, SS1, SS2, SS3, SS_OFFER, [])),
             deck(card, foot("Devam")))
    return meeting_screen(SALES, 14, SALES_SLOT, d)


# ------------------------------------------------------------------ VC sitting: Meridian Growth (moved once, rehearsed)
CAST_MG = [TOLGA, SENA_K, KAAN]
VC_SLOT = "10:00 · %s" % MG
L_B1 = ('"Meridian Growth. Otur. Vaktim kısa. Beni neden buraya çağırdığını göster."',
        '"Meridian Growth. Sit. My time is short. Show me why you called me here."')
READ = ("Odayı oku: MRR güçlü · Sektör eşleşmesi · Randevuyu kaydırdın", "Read the room: MRR is strong · Sector match · You moved the meeting")
C_B1 = ("Odayı oku: karşındakini tart.", "Read the room: take their measure.")
L_B2 = ('"Rakamları gördüm. Şimdi anlatın: bu gelirin devam etmesini sağlayan ne?"', '"I have seen the numbers. Now tell me what keeps this revenue coming."')
C_B2 = ("Metrik: rakamlar konuşsun.", "Metrics: let the numbers talk.")
GOOD = ('"İyi."', '"Good."')
Q_WEAK = ('"İnovasyon tarafın zayıf. Sektörü bilen biri bunu ilk bakışta görür."', '"Your Innovation side is weak. Anyone who knows the sector sees it at a glance."')
M_WEAK = ("En zayıf ekseni bulacak.", "They will find the weakest axis.")
HONEST = ("Dürüst: kabul et, planı göster.", "Honest: admit it, show the plan.")
HONEST_CAP = ("Düşük risk, dürüst duruş.", "Low risk, straight answer.")
SPIN_CAP = ("Yüksek risk, yüksek getiri.", "High risk, high return.")
DEFLECT = ("Geçiştir: konuyu kaydır.", "Deflect: move them off it.")
NARR = ("Anlatı", "Narrative")
MOVED = ("Randevuyu kaydırdın", "You moved the meeting")
WARM_LINE = '"Kararsızım. Bir yol var: sana bir koşul koyayım, tuttur, geri gel. Ya da şansını burada zorla."'
WARM_MONO = "Ilık. Güvenli kapı mı, açgözlü kumar mı?"
CB_CHOICE = "Geri dönüşü kabul et: koşulu tuttur."
PUSH_CHOICE = "Masayı zorla: şimdi karar ver."
V0 = [R(cp, TOLGA, L_B1), R(quiet, READ)]
V1 = [R(quiet, C_B1), R(cp, SENA_K, L_B2)]
V2 = [R(you, C_B2, NARR, True), R(cp, SENA_K, GOOD), R(cp, KAAN, Q_WEAK), R(quiet, M_WEAK)]
V2_FAIL = [R(you, C_B2, NARR, False), R(cp, SENA_K, '"Beni ikna etmedi."'), R(cp, KAAN, Q_WEAK), R(quiet, M_WEAK)]
V3_WARM = [R(you, DEFLECT, "Geçiştir", True), R(cp, TOLGA, WARM_LINE), R(quiet, WARM_MONO)]


def vc_head(beat, speaking, conv, mem=True, seed=False):
    k = kicker(s("k_seed") if seed else s("k_vc"), s(beat))
    inner = who(speaking, MG, CAST_MG, speaking) + tutum(conv, 70)
    if mem:
        inner += memory(MOVED)
    return head(k, inner)


def vc_screen(dock_html, world=VC, slot=VC_SLOT, compact=False, W=1920, H=1080):
    return meeting_screen(world, 10, slot, dock_html, compact, W, H)


def f_vc_open():
    d = dock(590, vc_head("b1", TOLGA, 46), flow(played(V0)),
             deck(opts([mo(1, C_B1, die="risky")]), foot(withdraw=True)))
    return vc_screen(d)


def f_vc_sorgu():
    # Deflect's caption speaks of the stakes (a ±5 swing under a 65 ceiling); the die speaks of the chance (60 %, risky)
    d = dock(590, vc_head("b3", KAAN, 71), flow(played(V0, V1, V2)),
             deck(opts([mo(1, HONEST, HONEST_CAP, die="safe", marker=("Prova edildi", "Rehearsed")),
                        mo(2, s("spin"), SPIN_CAP, die="danger"),
                        mo(3, DEFLECT, s("deflect_cap", cap=65), die="risky")])))
    return vc_screen(d)


def f_vc_sheet():
    v3 = [R(you, HONEST, "Dürüst", True), R(cp, TOLGA, '"Sana bir teklif göndereceğim. Beğenmeyebilirsin ama ciddi."')]
    card = mres("pos", "Teklif gelecek", [("Masaya etkisi", "Teklif var · 3 hafta geçerli"), ("İlişki", "Tolga Erdem: ılık → sıcak"),
                                         ("Hafızaya yazılan", '"Sana bir teklif göndereceğim. Beğenmeyebilirsin ama ciddi."')])
    d = dock(590, vc_head("b4", TOLGA, 91), flow(played(V0, V1, V2, v3, [R(you, "Teşekkürler. Bekliyorum.")])),
             deck(card, foot("Devam")))
    return vc_screen(d)


def f_vc_callback():
    v4 = [R(you, CB_CHOICE), R(cp, TOLGA, '"Koşulu biliyorsun. Tuttur, kapı açık."')]
    card = mres("warn", "Yeniden görüşülecek", [("Masaya etkisi", "Geri dönüş · Koşul: Aktif hata &lt; 3"), ("İlişki", "Tolga Erdem: ılık → ılık"),
                                               ("Hafızaya yazılan", '"Koşulu biliyorsun. Tuttur, kapı açık."')])
    d = dock(590, vc_head("b4", TOLGA, 65), flow(played(V0, V1, V2, V3_WARM, v4)), deck(card, foot("Devam")))
    return vc_screen(d)


def f_vc_ret():
    # the cost is MEETING_RES_COST_BRAND: the meeting-shot world has no employees, so no morale cost
    v3 = [R(you, HONEST, "Dürüst", False), R(cp, TOLGA, '"Bugün olmadı. Rakamlar beni buraya getirmedi."'),
          R(quiet, "Soğuk oda. En azından nedenini biliyorsun.")]
    v4 = [R(you, "Anladım. Çıkıyorum."), R(frank, "Ürünü açtılar, kapattılar. Toplantı bu.")]
    card = mres("neg", "Bu sefer değil", [("Masaya etkisi", "Reddetti · Marka −3"), ("İlişki", "Tolga Erdem: ılık → temkinli"),
                                         ("Hafızaya yazılan", '"Bugün olmadı. Rakamlar beni buraya getirmedi."')])
    d = dock(590, vc_head("b4", TOLGA, 33), flow(played(V0, V1, V2_FAIL, v3, v4)), deck(card, foot("Devam")))
    return vc_screen(d, world=VC_RET)


def f_vc_seed():
    s0 = [R(cp, TOLGA, '"Meridian Growth. Geç oturun, kahve söylemeyeceğim; yarım saatimiz var. Sizi anlatın."'), R(quiet, READ)]
    s1 = [R(quiet, C_B1), R(cp, SENA_K, '"Neden siz, neden şimdi? Bu iki soruya verdiğiniz cevap turun tamamı."')]
    s2 = [R(you, "Metrik: ödeyen ilk kullanıcıları göster.", NARR, True), R(cp, SENA_K, GOOD),
          R(cp, SENA_K, '"Diyelim ki her şey yolunda gitti. Bu ne kadar büyür?"'), R(quiet, "Tavanı soracak. Küçük bir cevap turu bitirir.")]
    s3 = [R(you, HONEST, "Dürüst", True), R(cp, TOLGA, '"Bu turu ben açacağım. Kâğıdı bugün gönderiyorum ve rakamlar açık olacak."'),
          R(quiet, "Odayı kazandın.")]
    card = mres("pos", "Teklif gelecek", [("Masaya etkisi", "Açık koşullar · süresiz"), ("İlişki", "Tolga Erdem: ılık → sıcak"),
                                         ("Hafızaya yazılan", '"Kâğıt yolda. İyi bir tur olacak."')])
    d = dock(590, vc_head("b4", TOLGA, 97, mem=False, seed=True),
             flow(played(s0, s1, s2, s3, [R(you, "Kâğıdı bekliyorum."), R(cp, TOLGA, '"Kâğıt yolda. İyi bir tur olacak."')])),
             deck(card, foot("Devam")))
    return vc_screen(d, world=VC_SEED)


def vc_long_dock(w):
    # failing the push closes the table: a destructive outcome, so its line stays neg-ink (rule 2)
    return dock(w, vc_head("b4", TOLGA, 65), flow(played(V0, V1, V2, V3_WARM)),
                deck(opts([mo(1, CB_CHOICE, "Güvenli. Kapı açık kalır."),
                           mo(2, PUSH_CHOICE, "Başarısızsan masa kapanır.", danger=True, die="danger")])))


def f_vc_long():
    return vc_screen(vc_long_dock(590))


def f_vc_long_1536():
    return vc_screen(vc_long_dock(500), compact=True, W=1536, H=864)


# ------------------------------------------------------------------ the call: phone ring in the founder's head slot (office_safe_1920_heads.json)
_F = next(p for p in kb.heads("ishani") if p.get("founder"))
FX, FY = 184 + _F["icon_xy"][0], 64 + _F["icon_xy"][1]


def ring(open_=False):
    return ('<div class="callring%s" style="left:%dpx;top:%dpx"><span class="ph"><img src="%s" alt=""></span></div>'
            % (" is-open" if open_ else "", FX, FY, PHONE))


def callcard(hour, person, line, note=None):
    """The card names the person and role; the line names the company (MEETING_INVITE_*)."""
    acts = ('<span class="btn btn-primary btn-sm">%s</span><span class="btn btn-secondary btn-sm">%s</span>'
            % (L("Kabul et", "Accept"), L("Ertele", "Postpone")))
    nt = '<div class="cc-note t-caption">%s</div>' % l(note) if note else ""
    return ('<div class="float doc callcard" style="left:%dpx;top:%dpx"><div class="kick t-key">%s</div>'
            '<div class="cc-who">%s<div><div class="n">%s</div><div class="r">%s</div></div></div>'
            '<div class="cc-line t-body">%s</div><div class="cc-acts">%s</div>%s</div>'
            % (FX + 34, FY - 88, s("invite_kick", h="%02d" % hour), av(person["bust"], 40), person["name"], l(person["role"]), l(line), acts, nt))


def office_screen(world, clock, slot, speed, extra, ring_on=False, marks=()):
    return (office_ishani(ring_on) + office_floats(world) + extra + topbar(world, clock, slot, speed, marks=marks) + shell(world))


def toast(head_, sub):
    return kb.toast(184 + 1736 // 2, 1080 - 40 - 24 - 48, "", "calendar", head_, sub)


INVITE_SALES = ("Karadeniz Fabrika adına Elif Yıldız görüşmeye hazır.", "Elif Yıldız of Karadeniz Fabrika is ready to meet.")


def f_davet_satis_halka():
    return office_screen(SALES, 14, ("next", SALES_SLOT, ""), "1x", ring(), True, (14,))


def f_davet_satis_kart():
    return office_screen(SALES, 14, ("next", SALES_SLOT, ""), "1x", ring(True) + callcard(14, ELIF, INVITE_SALES), True, (14,))


def f_davet_vc_kart():
    card = callcard(10, TOLGA, "Meridian Growth adına Tolga Erdem bu hafta görüşmek istiyor.",
                    "Toplantı yalnız bir kez ertelenebilir. Fonun bir sonraki toplantısında ikna −2.")
    return office_screen(VC, 10, ("next", VC_SLOT, ""), "II", ring(True) + card, True, (10,))


def f_davet_ertele_satis():
    return office_screen(SALES, 14, ("next", SALES_SLOT, ""), "1x", ring() + toast(kb.s("postponed"), kb.s("postponed_sub")), True, (14,))


def f_davet_ertele_vc():
    # the meeting left this week: the slot falls back to the workday's end and the founder's sprite is back
    return office_screen(VC, 10, ("next", end_in(7), ""), "1x", toast(kb.s("postponed"), kb.s("postponed_vc_sub")))


# ------------------------------------------------------------------ the trip over the city map: kabuk's trip_map()
def trip_map(t=None):
    """kabuk's trip (plate, road, founder disc, chips, skip hint). With t the disc is moved to t along kabuk's own
    road (the way home runs the same road, tower to office); the road itself is drawn once, by kabuk."""
    html = kb.trip_map()
    if t is None:
        return html
    m = re.search(r'class="casing" d="M([\d.]+) ([\d.]+) Q([\d.]+) ([\d.]+) ([\d.]+) ([\d.]+)"', html)
    ax, ay, cx, cy, bx, by = (float(v) for v in m.groups())
    px = (1 - t) ** 2 * ax + 2 * (1 - t) * t * cx + t * t * bx
    py = (1 - t) ** 2 * ay + 2 * (1 - t) * t * cy + t * t * by
    d = re.search(r'class="road-disc" style="left:-?\d+px;top:-?\d+px"><span class="av [^"]*" style="width:(\d+)px', html)
    r = int(d.group(1)) // 2
    html, n = re.subn(r'class="road-disc" style="left:-?\d+px;top:-?\d+px"', 'class="road-disc" style="left:%dpx;top:%dpx"' % (px - r, py - r), html)
    assert n == 1, "kabuk's road disc markup changed"
    return html


def f_yolculuk_gidis():
    # kabuk's ustbar__yolculuk exactly: the same state drawn by the same code
    return trip_map() + topbar(SALES, 14, ("now", SALES_SLOT), marks=(14,)) + shell(SALES)


def f_yolculuk_donus():
    # the way home at 16:00, a quarter of the way back; the trip holds the clock both ways
    return trip_map(0.75) + topbar(SALES, 16, ("now", s("trip_home"))) + shell(SALES)


# ------------------------------------------------------------------ term sheet table (its own full-screen scene)
def dial(chance, needle=None):
    """RadialDial: the push chance as an ink arc over the track; the needle rests at the arc's edge, or where the last
    roll landed (success: chance x 0.45, failure: chance + rest x 0.55, the dial's own landing rule). The needle is ink
    either way: the result line carries the outcome. The key under the figure names both marks."""
    cx, cy, r = 240, 228, 200

    def p(v, rr=r):
        a = math.pi + v * math.pi
        return cx + rr * math.cos(a), cy + rr * math.sin(a)
    x0, y0 = p(0)
    x1, y1 = p(1)
    xb, yb = p(chance)
    nx, ny = p(chance if needle is None else needle, r - 34)
    svg = ('<svg width="480" height="240" viewBox="0 0 480 240"><path class="trk" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>'
           '<path class="win" d="M%.1f %.1f A%d %d 0 0 1 %.1f %.1f"/>'
           '<line class="needle" x1="%d" y1="%d" x2="%.1f" y2="%.1f"/><circle class="hub" cx="%d" cy="%d" r="10"/></svg>'
           % (x0, y0, r, r, x1, y1, x0, y0, r, r, xb, yb, cx, cy, nx, ny, cx, cy))
    key = '<span class="k"><i class="sw arc"></i>%s</span>' % s("push_chance")
    if needle is not None:
        key += '<span class="k"><i class="sw ndl"></i>%s</span>' % s("last_roll")
    return ('<div class="dial">%s<div class="pct t-hero">%s</div><div class="dkey t-caption">%s</div></div>'
            % (svg, num("%%%d" % round(chance * 100)), key))


def lever(n, key, cur, ghost, odds, sel=False, push=None, locked=False):
    k = '<span class="kcap">%s</span>' % (ic("lock") if locked else n)
    v = '<span class="t-hero">%s</span>' % num(l(cur))
    if ghost:
        v += '<span class="ar t-hero">→</span><span class="gh t-hero">%s</span>' % num(l(ghost))
    btn = ""
    if sel and push is not None:
        btn = '<span class="btn btn-secondary%s">%s</span>' % ("" if push else " is-disabled", L("İtir", "Push"))
    cls = "lev" + (" is-sel" if sel else "") + (" is-locked" if locked else "")
    return ('<div class="%s">%s<div class="lev-c"><span class="lev-k t-label">%s</span><div class="lev-v">%s</div>'
            '<span class="lev-o t-meta">%s</span></div>%s</div>' % (cls, k, l(key), v, l(odds), btn))


def term_table(lead, fund, arche, pat, levers, dial_html, caption, cap_tone, say, frank_line, money, derived, tables,
               walk, sign, other=None, due=True):
    """Head: the person, then role · fund and the fund's archetype, the offer's countdown (the top bar's term-sheet
    slot text) and patience. Footer: walk, the money with the cash and tables line under it, sign."""
    due_html = ('<div class="tt-kpi tt-due">%s<span class="v t-key">%s</span></div>' % (ic("clock", 18), T("next_offer"))) if due else ""
    head_ = ('<div class="tt-head"><div class="tt-w">%s<div class="tt-id"><span class="f t-h2">%s</span><span class="p t-meta">%s · %s</span>'
             '<span class="a t-meta">%s</span></div>%s<div class="tt-kpi"><span class="k t-label">%s</span>%s</div></div></div>'
             % (av(lead["bust"], 64), lead["name"], l(lead["role"]), fund, l(arche), due_html, L("Sabır", "Patience"),
                patience(*pat, label=False)))
    left = '<div class="tt-l"><span class="tt-cap t-label">%s</span><div class="tt-sheet">%s</div></div>' % (L("Masadaki teklif", "The offer on the table"), "".join(levers))
    say_html = ""
    if say:
        say_html = ('<div class="tt-say">%s<div><div class="n t-key">%s</div><div class="t t-para">%s</div></div></div>'
                    % (av(lead["bust"], 32), lead["name"], l(say)))
    other_html = ""
    if other:
        other_html = ('<div class="tt-other-w"><div class="tt-other"><span class="v t-meta">%s</span><span class="btn btn-ghost btn-sm is-disabled">%s</span></div>'
                      '<div class="tt-why t-caption">%s</div></div>' % (other[0], L("Diğer teklifi göster", "Show the other offer"), other[1]))
    fr = ('<div class="tt-frank">%s<div><div class="n t-key">Frank Köseoğlu</div><div class="t">%s</div></div></div>' % (av(FRANK, 48), l(frank_line)))
    right = ('<div class="tt-r"><span class="tt-cap t-label">%s</span>%s<div class="tt-res t-body-strong %s">%s</div>%s%s%s</div>'
             % (s("odds_result"), dial_html, cap_tone, l(caption), say_html, other_html, fr))
    meta = s("cash_runway", cash=num("$330,0K"), runway=L("220 ay", "220 mo"))   # --vc-shot: cash 330000, 942 weeks = 220 months
    if tables:
        meta += " · " + l(tables)
    m = '<span class="v t-hero">%s</span>%s<span class="d t-caption">%s</span>' % (
        l(money), ('<span class="d t-caption">%s</span>' % derived) if derived else "", meta)
    foot_ = '<div class="tt-foot"><div class="tt-w"><div class="l">%s</div><div class="m">%s</div><div class="rr2">%s</div></div></div>' % (walk, m, sign)
    return '<div class="tt">%s<div class="tt-body"><div class="tt-stage">%s%s</div></div>%s</div>' % (head_, left, right, foot_)


def WALK():
    return '<span class="btn btn-danger">%s</span>' % L("Masadan kalk", "Walk away")


def SIGN(on=True):
    return '<span class="btn btn-primary btn-lg%s">%s</span>' % ("" if on else " is-disabled", L("İmzala", "Sign"))


BOS_ARCH = ("İlişki adamı. Kapıyı Frank açar.", "A relationship man. Frank opens the door.")
ANC_ARCH = "Agresif ama cömert. Kontrolü sever."
TABLES_0 = ("Kapanan masa: 0/3", "Tables closed: 0/3")
LEV_KEYS = (("Değerleme", "Valuation"), ("Hisse", "Equity"), ("Yönetim kurulu", "Board"))
VAL_ODDS = ("temel %45 · +%30 satış · −%12 tekrar", "base 45% · +30% sales · −12% repeat")
EQ_ODDS = ("temel %30 · +%15 karizma", "base 30% · +15% charisma")
EQ_ODDS_REP = "temel %30 · +%15 karizma · −%12 tekrar"
BOARD_ODDS = ("temel %15 · +%15 karizma", "base 15% · +15% charisma")


def lev_bos(sel, push, eq, eq_odds):
    return [lever(1, LEV_KEYS[0], "$12M", "$16M", VAL_ODDS, sel == 1, push),
            lever(2, LEV_KEYS[1], eq[0], eq[1], eq_odds, sel == 2, push),
            lever(3, LEV_KEYS[2], ("1 koltuk", "1 seat"), ("temiz", "clean"), BOARD_ODDS, sel == 3, push)]


def f_termsheet_table():
    lv = lev_bos(1, True, ("%18", "%14"), EQ_ODDS)
    return term_table(POLAT, "Bosphorus Partners", BOS_ARCH, (1, 2), lv, dial(0.63, 0.63 + 0.37 * 0.55),
                      ("Reddettiler. Olduğu yerde kaldı: $12M.", "They refused. It stays where it was: $12M."), "tone-ink",
                      ('"Peki. Listende başka ne var?"', '"All right. What else is on your list?"'), ("Bir hamlen kaldı.", "One move left."),
                      ("$2,2M yatırım", "$2.2M investment"), None, TABLES_0, WALK(), SIGN())


def f_termsheet_table_final():
    lv = lev_bos(2, False, ("%16", "%12"), EQ_ODDS_REP)
    return term_table(POLAT, "Bosphorus Partners", BOS_ARCH, (0, 2), lv, dial(0.33, 0.33 + 0.67 * 0.55),
                      "Bir kez daha esnediler: %18 → %16. Bu son teklif. İmzala ya da masadan kalk.", "tone-warn",
                      '"Bu kadar. Daha fazla esnemiyoruz."', "Sabırları bitti. Başka masa yok.",
                      "$1,9M yatırım", None, TABLES_0, WALK(), SIGN())


def f_termsheet_table_walk():
    lv = lev_bos(2, False, ("%18", "%14"), EQ_ODDS_REP)
    return term_table(POLAT, "Bosphorus Partners", BOS_ARCH, (0, 2), lv, dial(0.33, 0.33 + 0.67 * 0.55),
                      "Masadan kalktılar. Teklif gitti.", "tone-neg", '"Biz bu işte yokuz. Umarım işlerin yolunda gider."',
                      "Sabırları bitti. Başka masa yok.", "$2,2M yatırım", None, "Kapanan masa: 1/3",
                      '<span class="btn btn-secondary">Masadan ayrıl</span>', SIGN(False), due=False)


def f_termsheet_table_other():
    lv = [lever(1, LEV_KEYS[0], "$18M", "$22M", "temel %45 · +%30 satış · +%10 kaldıraç", True, True),
          lever(2, LEV_KEYS[1], "%22", "%18", "temel %30 · +%15 karizma · +%10 kaldıraç"),
          lever(3, LEV_KEYS[2], "1 koltuk + veto", "1 koltuk", "temel %15 · +%15 karizma · +%10 kaldıraç")]
    return term_table(KEREM, "Anchor Capital", ANC_ARCH, (3, 3), lv, dial(0.85),
                      "Kıpırdamadılar. Teklif aynı.", "tone-ink", '"Biz teklif yarışına girmeyiz."', "Sıradaki hamle senin.",
                      "$4,0M yatırım", None, TABLES_0, WALK(), SIGN(),
                      other=("Diğer teklif · Meridian Growth: $15M · %18 · temiz", "Diğer teklifi zaten gösterdin."))


def f_termsheet_seed_table():
    lv = [lever(1, "Yatırım", "$130.000", "$140.000", "temel %30 · +%15 karizma", True, True),
          lever(2, LEV_KEYS[1], "%16", "%14", "temel %30 · +%15 karizma"),
          lever(3, LEV_KEYS[2], "0 koltuk + veto", "temiz", "Seed turunda yönetim kurulu pazarlığa açılmıyor.", locked=True)]
    walk = ('<span class="btn btn-danger is-disabled">%sMasadan kalk</span><span class="why t-caption">Turu geri çevirmek zor modda açılır.</span>'
            % ic("lock", 16))
    return term_table(KEREM, "Anchor Capital", ANC_ARCH, (3, 3), lv, dial(0.45),
                      "Yatırım: $130.000 → $140.000 · %45", "tone-ink", None,
                      '"Teklif duruyor, kaçmıyor. Ama pazarlık ettiğin her şeyin bir bedeli var: sabırları."',
                      "$130,0K yatırım", "ima edilen değerleme $812.500", None, walk, SIGN())


# ------------------------------------------------------------------ frames
FRAMES = {
    "toplanti__satis_probe": f_satis_probe,
    "toplanti__satis_locked": f_satis_locked,
    "toplanti__satis_locked_en": f_satis_locked,
    "toplanti__satis_won": f_satis_won,
    "toplanti__satis_lost": f_satis_lost,
    "toplanti__satis_handoff": f_satis_handoff,
    "toplanti__pazarlik_open_1536": (f_pazarlik_open_1536, 1536, 864),
    "toplanti__pazarlik_countered": f_pazarlik_countered,
    "toplanti__pazarlik_insult": f_pazarlik_insult,
    "toplanti__pazarlik_confirm": f_pazarlik_confirm,
    "toplanti__vc_open": f_vc_open,
    "toplanti__vc_sorgu": f_vc_sorgu,
    "toplanti__vc_sorgu_en": f_vc_sorgu,
    "toplanti__vc_sheet": f_vc_sheet,
    "toplanti__vc_callback": f_vc_callback,
    "toplanti__vc_ret": f_vc_ret,
    "toplanti__vc_seed": f_vc_seed,
    "toplanti__vc_long": f_vc_long,
    "toplanti__vc_long_1536": (f_vc_long_1536, 1536, 864),
    "davet__satis_halka": f_davet_satis_halka,
    "davet__satis_kart": f_davet_satis_kart,
    "davet__satis_kart_en": f_davet_satis_kart,
    "davet__vc_kart": f_davet_vc_kart,
    "davet__ertele_satis": f_davet_ertele_satis,
    "davet__ertele_vc": f_davet_ertele_vc,
    "yolculuk__gidis": f_yolculuk_gidis,
    "yolculuk__donus": f_yolculuk_donus,
    "termsheet__table": f_termsheet_table,
    "termsheet__table_en": f_termsheet_table,
    "termsheet__table_final": f_termsheet_table_final,
    "termsheet__table_walk": f_termsheet_table_walk,
    "termsheet__table_other": f_termsheet_table_other,
    "termsheet__seed_table": f_termsheet_seed_table,
}


def size_of(name):
    f = FRAMES[name]
    return (f[1], f[2]) if isinstance(f, tuple) else (1920, 1080)


def build(names):
    """A name ending in _en is the same frame built in English (SPEC §3.4: the worst case in both languages)."""
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        f = FRAMES[n]
        fn = f[0] if isinstance(f, tuple) else f
        W, H = size_of(n)
        if n.endswith("_en"):
            set_lang("en")
        try:
            html = page(fn(), W, H)
        finally:
            set_lang("tr")
        open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8").write(html)
        print("built", n)


if __name__ == "__main__":
    args = sys.argv[1:]
    if args == ["--sizes"]:
        for n in FRAMES:
            print(n, *size_of(n))
    else:
        build(args or list(FRAMES))
