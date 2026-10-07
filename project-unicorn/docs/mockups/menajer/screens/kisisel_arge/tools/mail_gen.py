"""SNAPSHOT of ../../olaylar/tools/gen.py (2026-10-02 20:39, md5 c296f1c6), imported by gen.py of group
"kisisel_arge" for the shell (top bar, rail, floats) and the mail grammar; never run directly here.

Olaylar as mail: builds every frame of group "olaylar" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with ../tools/render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css,
icons, crop rule, top bar geometry) is read from ../../../system through the copies in syskit/, whose caches
live in this folder so nothing is ever written into the system folder.
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
from common import T, ic, num, set_lang  # noqa: E402
from kit import at, tag, pill, stamp, fx  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src  # avatar() and portrait() resolve image paths through this

FRANK = os.path.join(MEN, "portraits", "frank_cand_a.png")
FOUNDER = os.path.join(MEN, "portraits", "founder_01.png")
BUST = {k: os.path.join(MEN, "art", "bust_%s.png" % k) for k in ("elif", "deniz", "mert", "selin", "burak")}
OFFICE = {"ishani": "art/office_safe_1920.png", "home": "art/office_safe_1920_home.png"}

LANG = "tr"


def L(tr, en):
    return tr if LANG == "tr" else en


# ------------------------------------------------------------------ dates (GameState.get_date_dict: day 1 = 1 Jan 2026, a tick = 7 days)
MON_TR = ["Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran", "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık"]
MON_EN = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]


def date(week, hour=None):
    """`week` is the tick (GameState.day); the line prints the week of the year, as get_date_dict does."""
    import datetime
    d = datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    s = L("Hafta %d · %s %d" % (w, MON_TR[d.month - 1], d.year), "Week %d · %s %d" % (w, MON_EN[d.month - 1], d.year))
    return s + (" · %02d:00" % hour if hour is not None else "")


def date_c(week):
    import datetime
    d = datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))
    return L("H%d · %s" % (week, MON_TR[d.month - 1][:3]), "W%d · %s" % (week, MON_EN[d.month - 1][:3]))


# ------------------------------------------------------------------ new strings this group introduces (EN first; listed in INDEX.md)
S = {
    "brand": ("Project Unicorn", "Project Unicorn"),
    "reply": ("Your reply", "Cevabın"),
    "to": ("To", "Kime"),
    "founder_to": ("Founder · Unicorn Inc.", "Kurucu · Unicorn Inc."),
    "k_decision": ("Decision", "Karar"), "k_paper": ("Paper", "Kağıt"), "k_report": ("Report", "Rapor"),
    "k_message": ("Message", "Mesaj"), "k_attention": ("Attention", "Dikkat"),
    "st_waiting": ("Answer needed", "Cevap bekliyor"), "st_answered": ("Answered", "Cevaplandı"),
    "st_in_weeks": ("Within {n} weeks", "{n} hafta içinde"), "st_final": ("Final week", "Bu hafta son"),
    "st_left": ("Left", "Ayrıldı"),
    "accounts": ("Accounts", "Muhasebe"),
    "list_empty": ("Nothing waiting.", "Bekleyen bir şey yok."),
    "pane_empty": ("No message selected.", "Seçili mesaj yok."),
    "rpt_customer": ("Customer", "Müşteri"), "rpt_stars": ("Stars", "Yıldız"), "rpt_seats": ("Seats", "Koltuk"),
    "rpt_price": ("Price", "Fiyat"), "rpt_mrr": ("MRR", "MRR"),
    "rpt_total": ("Total", "Toplam"),
    "part_team": ("Team", "Ekip"),
}


def s(key, **kw):
    en, tr = S[key]
    v = tr if LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ top bar (system kit geometry; brand block per decision 14 option (a))
SEED14 = dict(cash="$10.000", net="+$2,5K", net_cls="tb-d", run_k="runway", run_v="profitable", run_cls="tb-v pos",
              mrr="$4,0K", brand="50", burn="$1,5K", rep="0")
SEED1 = dict(cash="$10.000", net="−$1,5K", net_cls="tb-v", run_k="runway", run_v="7m", run_cls="tb-v",
             mrr="$0", brand="50", burn="$1,5K", rep="0")


def topbar(v, week, clock, slot, speed, marks=()):
    """slot: ("gate", sub) | ("next", text, kind). speed: "II" | "1x" | None (gated)."""
    col, g, time_w = kit.tb_layout(False)
    W = 1920
    gated = slot[0] == "gate"
    out = ['<span class="brand-sq" style="left:20px;top:13px"></span>',
           at(48, 31, "t-subhead", s("brand"), "tb-co", width=g["brand"] - 48 - 12),
           at(48, 50, "t-micro", T("phase"), "tb-k")]
    for i in range(3):
        out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i == 0 else "", 48 + kit.TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    run_v = T("profitable") if v["run_v"] == "profitable" else L("7 ay", "7 mo")
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"), at(col["B"], b1, "t-hero", num(v["cash"]), "tb-hero"),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", num(v["net"]) + '<span class="tb-u">%s</span>' % T("per_mo"), v["net_cls"]),
            at(col["C"], b1, "t-label", T(v["run_k"]), "tb-k"), at(col["D"], b1, "t-value", run_v, v["run_cls"]),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", num(v["mrr"]), "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", v["brand"], "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", num(v["burn"]) + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", v["rep"], "tb-v")]
    gate_x = W - time_w - g["gate"]
    d0 = col["metrics_end"]
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + 20, 28, "t-body", date(week), "tb-date"))
    out.append(kit.week_bar(d0 + 20, min(gate_x - 20, d0 + 20 + 720), now_h=clock, marks=marks))
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"]))
    if gated:
        tx = gate_x + g["gate_pad"] + 10 + 12
        out.append('<span class="gate-dot" style="position:absolute;left:%dpx;top:19px"></span>' % (gate_x + g["gate_pad"]))
        out.append(at(tx, 30, "t-gate", T("gate"), "gate-l"))
        out.append(at(tx, 51, "t-key", slot[1], "gate-s", width=g["gate"] - (tx - gate_x) - g["gate_pad"]))
    else:
        tx = gate_x + g["gate_pad"]
        out.append(at(tx, 29, "t-micro", T("next"), "nx-l"))
        out.append(at(tx, 50, "t-key", slot[1], "nx-s " + slot[2], width=g["gate"] - 2 * g["gate_pad"]))
    tx0 = W - time_w
    out.append('<div class="tb-time" style="left:%dpx;width:%dpx"></div>' % (tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "%02d:00" % int(clock), "tb-clock"))
    kx = tx0 + g["time_pad"][0] + kit.TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if k == speed else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    if gated:
        out.append('<div class="tb-gated-frame" style="left:%dpx;width:%dpx"></div>' % (gate_x, W - gate_x))
    return '<header class="topbar%s">%s</header>' % (" is-gated" if gated else "", "".join(out))


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]


def rail(active, badges):
    rows = []
    for key, name in RAIL:
        b = "lock" if key == "pazarlama" else badges.get(key)
        cls = "rr" + (" is-active" if key == active else "") + (" is-locked" if b == "lock" else "")
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), T("soon"))
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    return ('<nav class="rail">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % ("".join(rows), ic("ayarlar", 24), T("tab_settings")))


B14 = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


def badges(olaylar=None, ekip=True):
    b = dict(B14)
    if not ekip:
        b.pop("ekip")
    if olaylar:
        b["olaylar"] = olaylar
    return b


# ------------------------------------------------------------------ office floats
def floats(hud=True, notices=()):
    out = []
    if hud:
        out.append(kit.buildhud("position:absolute;left:1576px;top:88px"))
    y = 1080 - 40 - 24 - 52
    for kind, co, tx in reversed(notices):
        out.append(kit.notice("position:absolute;left:1544px;top:%dpx" % y, kind, co, tx))
        y -= 60
    return "".join(out)


def page(name, body, title="Olaylar"):
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../olaylar.css"></head><body>%s</body></html>'
            % (LANG, title, common.FONTS, REL, REL, body))


def screen(top, rail_html, window, office="ishani", dim=True, hud=True, notices=()):
    off = '<div class="office%s" style="background-image:url(%s%s)"></div>' % (" is-dimmed" if dim else "", REL, OFFICE[office])
    return '<div class="screen">%s%s%s%s%s%s</div>' % (off, floats(hud, notices), window, top, rail_html, kit.ticker())


# ------------------------------------------------------------------ sender tiles
def av_person(path, size=40, cls=""):
    return common.avatar(path, size, cls)


def av_mono(text, cls=""):
    return '<span class="mono m40 t-subhead %s">%s</span>' % (cls, text)


def av_doc():
    return '<span class="mono m40">%s</span>' % ic("doc")


# ------------------------------------------------------------------ the mails (EN first in DRAFTS.md; here both, picked by LANG)
def M(**kw):
    return kw


def mails():
    to = s("founder_to")
    return {
        "offer": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                   kind="k_decision", week=14, subject=L("Teklif", "An offer"), serif=True,
                   body=[L("Ürün para kazandırmaya başladı.", "The product has started making money."),
                         L("Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar "
                           "koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?",
                           "You got this far on your own savings and your own work. I'll put in twenty-five thousand to "
                           "speed things up, and I'll take four percent. No haggling. I'm asking once: do you want it?")],
                   sig=("Frank Köseoğlu", "Operating Partner"), to=to),
        "risk": M(frm="Ege Sigorta", role=L("BT Müdürü", "IT Manager"), av=av_mono("ES"), topic="customer",
                  kind="k_decision", week=14, subject=L("Konuşmamız gerek", "We need to talk"),
                  body=[L("Merhaba,", "Hello,"),
                        L("Ekibim sistemin içinde çalışmaktan çok etrafından dolanıyor. Bu böyle sürmez.",
                          "My team works around it more than they work in it. That has to stop."),
                        L("Saygılarımla,", "Regards,")],
                  greet=True, sig=(L("BT Müdürü", "IT Manager"), "Ege Sigorta"), to=to),
        "risk_broken": M(frm="Ege Sigorta", role=L("BT Müdürü", "IT Manager"), av=av_mono("ES"), topic="customer",
                         kind="k_decision", week=14, subject=L("Konuşmamız gerek", "We need to talk"),
                         body=[L("Merhaba,", "Hello,"),
                               L("Olacak dediniz, olmadı. Başka seçeneklere bakmaya başladık.",
                                 "You said it would be there. It isn't. We've started looking at other options."),
                               L("Saygılarımla,", "Regards,")],
                         greet=True, sig=(L("BT Müdürü", "IT Manager"), "Ege Sigorta"), to=to),
        "expansion": M(frm="Nordica", role=L("Operasyon Müdürü", "Operations Manager"), av=av_mono("N"), topic="customer",
                       kind="k_paper", week=14, subject=L("Bir ekip daha", "One more team"),
                       body=[L("Merhaba,", "Hello,"),
                             L("Sistemi bir ekibimize daha açmak istiyoruz. Koltukları aynı fiyattan ekleyebilir misiniz?",
                               "We'd like to roll the system out to another team. Could you add the seats at the same price?"),
                             L("Saygılarımla,", "Regards,")],
                       greet=True, sig=(L("Operasyon Müdürü", "Operations Manager"), "Nordica"), to=to),
        "resign": M(frm="Selin Kaya", role=L("Test Mühendisi", "QA Engineer"), av=av_person(BUST["selin"]), well=BUST["selin"],
                    topic="team", kind="k_decision", week=14, subject=L("İstifa dilekçem", "My notice"),
                    body=[L("Merhaba,", "Hi,"),
                          L("Başka bir yerden teklif geldi. Doğrusunu istersen, aramayı ben yaptım.",
                            "I got an offer from somewhere else. Honestly, I made the call myself."),
                          "Selin"],
                    greet=True, sig=("Selin Kaya", L("Test Mühendisi · Unicorn Inc.", "QA Engineer · Unicorn Inc.")), to=to),
        "rnd": M(frm="Elif Demir", role=L("Ürün Yöneticisi", "Product Manager"), av=av_person(BUST["elif"]), well=BUST["elif"],
                 topic="product", kind="k_report", week=14, subject=L("Aylık ürün notu", "Monthly product note"),
                 body=[L("Bu ay kimse bir şey istemedi.", "Nobody asked for anything this month."),
                       L("Operanda yeni sürümünde toplu yetkilendirme çıkardı. Bizde yok.",
                         "Operanda shipped bulk permissions in its latest release. We do not have it."),
                       L("Ekipte konuşulan şey model tarafı. Herkes o yöne bakıyor.",
                         "What the team is talking about is the model side. Everyone is looking that way.")],
                 sig=("Elif Demir", L("Ürün Yöneticisi · Unicorn Inc.", "Product Manager · Unicorn Inc.")), to=to),
        "summary": M(frm=s("accounts"), role="Unicorn Inc.", av=av_doc(), topic="agenda", kind="k_report", week=14,
                     subject=L("2. Çeyrek 2026", "Q2 2026"), body=[], sig=(s("accounts"), "Unicorn Inc."), to=to,
                     preview=L("MRR $0 → $4,0K · Ekip 1 → 6", "MRR $0 → $4.0K · Team 1 → 6")),
        "weekly": M(frm="Burak Şahin", role=L("Satış Temsilcisi", "Sales Representative"), av=av_person(BUST["burak"]),
                    well=BUST["burak"], topic="customer", kind="k_report", week=15,
                    subject=L("Haftanın satışları", "The week in sales"),
                    body=[L("Geçen hafta kapananlar:", "Closed last week:")],
                    sig=("Burak Şahin", L("Satış Temsilcisi · Unicorn Inc.", "Sales Representative · Unicorn Inc.")), to=to,
                    preview=L("Karadeniz Fabrika, Efes Emlak · $1.620/ay", "Karadeniz Fabrika, Efes Emlak · $1,620/mo")),
        "intro_b2b": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                       kind="k_decision", week=14, subject=L("Eski bir dost", "An old friend"), serif=True,
                       body=[L("Eski bir dostuma senin üründen bahsettim. İşine yarayabileceğini düşünüyor. Bir görüşme "
                               "ayarladım. Hazırlıklı git.",
                               "I told an old friend of mine about what you've built. He thinks it might be useful to him. "
                               "I've set up a meeting. Go in prepared.")],
                       sig=("Frank Köseoğlu", "Operating Partner"), to=to),
        "press": M(frm="Sektör Telgrafı", role="", av=av_mono("ST", "outlet sektor"), topic="agenda", kind="k_paper", week=91,
                   subject=L("Yıllık dosya", "The annual file"),
                   body=[L("Yıllık dosya çıktı: seninle aynı yıl kurulan şirketlerin listesi.",
                           "This year's annual file is out: every company founded the same year as yours."),
                         L("Çoğunun yanında bir tur, bir satış ya da bir kapanış yazıyor. Seninkinin yanında ilk gün "
                           "yazdığımız satır duruyor.",
                           "Most have a round, a sale or a closure next to the name. Next to yours is the line we ran on day one."),
                         L("Dosya yorum yapmaz. Yalnız sıralar.", "The file does not comment. It only lists.")],
                   sig=("Sektör Telgrafı", ""), to=to),
        "intro": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                   kind="k_message", week=1, hour=9, subject=L("Ben Frank", "It's Frank"), serif=True,
                   body=[L("Eski şirketten hatırlarsın. İstifa ettin mi, yoksa hâlâ düşünüyor musun?",
                           "You'll remember me from your old company. Did you quit, or are you still thinking about it?"),
                         L("Elinde ne var şu an, fikir mi yoksa çalışan bir şey mi? Fikirse ilk sürümü yazacak kimse yok. "
                           "Sen yazacaksın, muhtemelen kötü olacak ama normal olan bu zaten.",
                           "So what have you actually got, an idea or something that works? If it's an idea, there's nobody "
                           "to write the first version. You'll write it, and it'll probably be bad.")],
                   sig=("Frank Köseoğlu", "Operating Partner"), to=to),
    }


def preview_of(m):
    if m.get("preview"):
        return m["preview"]
    body = m["body"]
    return body[1] if m.get("greet") and len(body) > 1 else body[0]


# ------------------------------------------------------------------ inbox rows
def r_mail(m, cls="", right="", hover=False, stamp_html="", gone=False):
    frm = m["frm"] + ((' <span class="gone">· %s</span>' % s("st_left")) if gone else "")
    return kit.ib_row(frm, m["topic"], m["subject"], right, preview_of(m), cls, hover, stamp_html)


def r_paper(m, weeks, cls="is-unread", blocked=False):
    last = weeks == 1
    right = ic("clock") + (T("wk_this") if last else T("weeks_n", n=weeks))
    return r_mail(m, cls + (" is-lastweek" if last else "") + (" is-blocked" if blocked else ""), right)


def r_notice(key, cls=""):
    if key == "ege":
        return kit.ib_row("Ege Sigorta", "customer", tag(T("risk_tag"), "risk"), num("$1,0K") + T("per_mo"),
                          "<i>%s</i>" % L("Sebep: sık kesinti şikayeti", "Reason: frequent outage complaints"), "is-notice " + cls)
    if key == "selin":
        mv = '<span class="t-label" style="color:var(--ink-3)">%s</span><b style="color:var(--neg)">22</b>' % T("risk_morale")
        return kit.ib_row("Selin Kaya", "team", tag(T("st_risk"), "risk"), mv,
                          L("Test Mühendisi · Test ediyor", "QA Engineer · Testing"), "is-notice " + cls)
    if key == "nordica":
        return kit.ib_row("Nordica", "customer", tag(T("grow_tag"), "pos"), num("$2,0K") + T("per_mo"),
                          "<i>%s</i>" % L("Başka departmana yaymak istiyor.", "Wants to roll it out to another department."),
                          "is-notice " + cls)


def r_queue(n):
    return ('<div class="ib-queue">%s<span class="t-meta">%s</span><span class="t-caption" style="margin-left:auto;color:var(--ink-3)">%s</span></div>'
            % (ic("queue", 18), L("%d karar daha sırada" % n, "%d more decisions queued" % n), T("queue_after")))


def r_day(week):
    return '<div class="ib-day t-caption">%s</div>' % date(week)


def r_report(m, cls=""):
    return r_mail(m, cls, ic("doc") + L("rapor", "report"))


def r_intro(m, cls=""):
    return r_mail(m, cls, "09:00")


def r_history(m, stamp_txt, choice, cls="", gone=False):
    frm = m["frm"] + ((' <span class="gone">· %s</span>' % s("st_left")) if gone else "")
    pre = '<span class="ch-k">%s:</span> %s' % (T("your_choice"), choice)
    return kit.ib_row(frm, m["topic"], m["subject"], "", pre, "is-history " + cls, False, stamp(stamp_txt))


# ------------------------------------------------------------------ reading pane
def kicker(m, state=None, state_cls=""):
    st = ('<span class="sep">·</span><span class="state t-meta %s">%s</span>' % (state_cls, state)) if state else ""
    return '<div class="pane-kicker">%s<span class="kind t-meta">%s</span>%s</div>' % (pill(m["topic"]), s(m["kind"]), st)


def header(m, gone=False):
    av = m["av"]
    if gone:
        av = av.replace('class="av av-40 ', 'class="av av-40 is-gone ')
    l1 = '<span class="n">%s</span><span class="r">%s</span>' % (m["frm"], m["role"])
    if gone:
        l1 += '<span class="gone">· %s</span>' % s("st_left")
    return ('<div class="mh">%s<div class="mh-who"><div class="mh-l1">%s</div>'
            '<div class="mh-l2"><span class="k">%s</span><span class="v">%s</span></div></div>'
            '<div class="mh-date">%s</div></div>' % (av, l1, s("to"), m["to"], date(m["week"], m.get("hour"))))


def body_html(m, extra=""):
    ps = []
    for i, p in enumerate(m["body"]):
        ps.append("<p>%s</p>" % p)
    cls = "mbody" + (" serif" if m.get("serif") else "")
    sig = '<div class="msig"><span class="n">%s</span>%s</div>' % (m["sig"][0], ('<span class="r">%s</span>' % m["sig"][1]) if m["sig"][1] else "")
    return '<div class="%s">%s%s</div>%s' % (cls, "".join(ps), extra, sig)


def pane(m, reply="", state=None, state_cls="", stamp_html="", gone=False, extra_body="", well=True):
    w = m.get("well") if well else None
    subj = '<div class="subj-row"><h2 class="pane-title t-h2">%s</h2>%s</div>' % (m["subject"], stamp_html)
    col = '<div class="pane-col">%s%s%s%s</div>' % (kicker(m, state, state_cls), subj, header(m, gone), body_html(m, extra_body))
    port = ""
    if w:
        port = common.portrait(w, 256, 320, "is-gone-well" if gone else "")
        if gone:
            port = port.replace("<img ", '<img class="gone-img" ')
    return '<div class="pane"><div class="pane-top">%s%s</div>%s</div>' % (col, port, reply)


def perm():
    return '<span class="perm">%s<span class="t-meta">%s</span></span>' % (ic("pause"), T("permanent"))


def reply(inner, show_perm=True, label=None):
    return ('<div class="reply"><div class="reply-head"><span class="lbl t-label">%s</span>%s</div>%s</div>'
            % (label or s("reply"), perm() if show_perm else "", inner))


def fx_flat(text):
    return '<span class="fx neutral">%s</span>' % text


def answered(label, chips, stamp_html):
    return ('<div class="answered"><div class="answered-l"><span class="opt-label">%s</span><div class="chosen-fx">%s</div></div>%s</div>'
            % (label, chips, stamp_html))


def opt_locked(label, why):
    return kit.opt(label, state="is-locked", why=why)


# ------------------------------------------------------------------ window
def olay_window(rows, pane_html, counts, active=0, kpi=None):
    kpi_html = ""
    if kpi:
        kpi_html = ('<div class="win-kpis"><div class="kpi"><span class="kpi-key t-label">%s</span>'
                    '<span class="kpi-val t-kpi%s">%s</span></div></div>' % (T("k_soonest"), " warn" if kpi[1] else "", kpi[0]))
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1>%s<div class="grow"></div><span class="win-close">%s</span></div>'
            % (T("ev_title"), kpi_html, ic("close")))
    tabs = "".join('<span class="seg-tab t-tab%s">%s<span class="n">%d</span></span>' % (" is-active" if i == active else "", T(k), c)
                   for i, (k, c) in enumerate(zip(("f_all", "f_wait", "f_unread"), counts)))
    listcol = '<div class="ib-list"><div class="ib-head"><div class="seg">%s</div></div>%s</div>' % (tabs, rows)
    return ('<section class="win" style="left:208px;top:88px;width:1240px;height:900px">%s<div class="ib">%s%s</div></section>'
            % (head, listcol, pane_html))


# ------------------------------------------------------------------ frames
def frank_offer_reply():
    return reply(kit.stake_frank() + '<div style="height:8px"></div>' + opt_locked(T("refuse"), T("refuse_lock")))


def list_A(sel="offer", gate=True, queue=0, paper_sel=False):
    mm = mails()
    rows = []
    if gate:
        rows.append(r_mail(mm["offer"], "is-gate" + (" is-selected" if sel == "offer" else "")))
    if queue:
        rows.append(r_queue(queue))
    rows.append(r_paper(mm["expansion"], 2, "is-unread" + (" is-selected" if paper_sel else ""), blocked=gate))
    rows.append(r_notice("ege"))
    rows.append(r_notice("selin"))
    rows.append(r_day(14))
    rows.append(r_mail(mm["rnd"], "is-unread" + (" is-selected" if sel == "rnd" else ""), ic("doc") + L("rapor", "report")))
    rows.append(r_report(mm["summary"], " is-selected" if sel == "summary" else ""))
    rows.append(r_day(1))
    rows.append(r_intro(mm["intro"]))
    return "".join(rows)


GATE_SUB = "Frank Köseoğlu"


def f_frank_offer():
    mm = mails()
    p = pane(mm["offer"], frank_offer_reply(), state=s("st_waiting"), state_cls="is-gate")
    win = olay_window(list_A(), p, (8, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", GATE_SUB), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_kuyruk():
    mm = mails()
    p = pane(mm["offer"], frank_offer_reply(), state=s("st_waiting"), state_cls="is-gate")
    win = olay_window(list_A(queue=2), p, (8, 4, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", T("gate_n", n=3)), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def retention_opts(armed="discount", locked=None, focus=None):
    sat_keep = L("Müşteri kalır", "The customer stays")
    rep = T("rep")
    o = []
    defs = [
        ("promise", L("Söz ver", "Promise it"), [fx("cost", L("Müşteri kalır · söz borcu", "The customer stays · a promise owed")),
                                                 fx("gain", "%s +1" % rep)],
         [("cost", sat_keep, "cost", L("söz borcu", "a promise owed")), ("gain", rep, "up", "+1")]),
        ("stall", L("Oyala", "Stall them"), [fx_flat(L("Kısa vadeli hamle", "A short-term move")), fx("cost", "%s −1" % rep)],
         [("cost", L("Kısa vadeli", "Short-term"), "flat", L("hamle", "move")), ("cost", rep, "cost", "−1")]),
        ("discount", L("İndirim ver", "Offer a discount"), [fx("cost", "%s · MRR −$150" % sat_keep), fx("cost", "%s −1" % rep)],
         [("cost", sat_keep, "cost", "MRR −$150"), ("cost", rep, "cost", "−1")]),
        ("leave", L("Kendi haline bırak", "Let it go"), [fx_flat(L("müdahale yok · sayaç işlemeye devam eder",
                                                                 "no intervention · the counter keeps running"))], None),
    ]
    for key, label, chips, parts in defs:
        if locked and key == locked[0]:
            o.append(opt_locked(label, locked[1]))
        elif key == armed:
            o.append(kit.opt_armed(label, parts))
        else:
            o.append(kit.opt(label, "".join(chips), "is-focus" if key == focus else ""))
    return "".join(o)


def list_B(active="risk", hist=False, sel=None):
    mm = mails()
    rows = [r_mail(mm[active], "is-gate" + ("" if sel else " is-selected"))]
    rows.append(r_paper(mm["expansion"], 2, "is-unread", blocked=True))
    rows.append(r_notice("selin"))
    rows.append(r_day(14))
    rows.append(r_mail(mm["rnd"], "is-unread", ic("doc") + L("rapor", "report")))
    rows.append(r_report(mm["summary"]))
    if hist:
        rows.append(r_day(11))
        h = dict(mm["risk"], week=11)
        rows.append(r_history(h, T("answered_stamp"), L("Söz ver", "Promise it"), " is-selected" if sel == "hist" else ""))
    rows.append(r_day(1))
    rows.append(r_intro(mm["intro"]))
    return "".join(rows)


def f_musteri_secenek_acik():
    mm = mails()
    p = pane(mm["risk"], reply(retention_opts(armed="discount")), state=s("st_waiting"), state_cls="is-gate")
    win = olay_window(list_B(), p, (7, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", "Ege Sigorta"), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win)


def f_kilitli_secenek():
    mm = mails()
    lock = (L("Söz ver", "Promise it"), L("Bu hesaba verdiğin son söz tutulmadı.", "Your last promise to them was not kept."))
    p = pane(mm["risk_broken"], reply(retention_opts(armed=None, locked=("promise", lock[1]), focus="stall")),
             state=s("st_waiting"), state_cls="is-gate")
    win = olay_window(list_B("risk_broken", hist=True), p, (8, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", "Ege Sigorta"), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win)


def f_gecmis_karar():
    mm = mails()
    h = dict(mm["risk"], week=11)
    chosen = answered(L("Söz ver", "Promise it"), fx("cost", L("Müşteri kalır · söz borcu", "The customer stays · a promise owed"))
                      + fx("gain", L("İtibar +1", "Reputation +1")), stamp(T("answered_stamp"), "H11"))
    p = pane(h, reply(chosen, show_perm=False, label=T("your_choice")))
    win = olay_window(list_B("risk_broken", hist=True, sel="hist"), p, (8, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", "Ege Sigorta"), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win)


def paper_bar(weeks, gated=False):
    last = weeks == 1
    when = s("st_final") if last else s("st_in_weeks", n=weeks)
    if gated:
        return ('<div class="paper-bar"><span class="when t-key" style="color:var(--ink-3)">%s%s</span>'
                '<span class="locked" style="margin-left:auto"><span class="why t-data">%s</span>'
                '<span class="btn btn-primary is-disabled">%s%s</span></span></div>'
                % (ic("clock"), when, T("blocked_reason"), ic("reply"), T("reply")))
    return ('<div class="paper-bar"><span class="when t-key%s">%s%s</span><span class="btn btn-primary">%s%s</span></div>'
            % (" is-lastweek" if last else "", ic("clock"), when, ic("reply"), T("reply")))


def list_C(paper_weeks=2, sel="paper", notices=("ege", "selin")):
    mm = mails()
    rows = []
    if paper_weeks:
        rows.append(r_paper(mm["expansion"], paper_weeks, "is-unread" + (" is-selected" if sel == "paper" else "")))
    for n in notices:
        rows.append(r_notice(n, "is-selected" if sel == n else ""))
    rows.append(r_day(14))
    rows.append(r_mail(mm["rnd"], ("" if sel == "rnd" else "is-unread") + (" is-selected" if sel == "rnd" else ""),
                       ic("doc") + L("rapor", "report")))
    rows.append(r_report(mm["summary"], " is-selected" if sel == "summary" else ""))
    rows.append(r_day(1))
    rows.append(r_intro(mm["intro"]))
    return "".join(rows)


def f_kagit_onizleme():
    mm = mails()
    p = pane(mm["expansion"], reply(paper_bar(2), show_perm=False), state=s("st_in_weeks", n=2))
    win = olay_window(list_C(), p, (7, 1, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, rail("olaylar", badges(("count", "1"))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_kagit_son_hafta():
    mm = mails()
    m = dict(mm["expansion"])
    p = pane(m, reply(paper_bar(1), show_perm=False), state=s("st_final"), state_cls="is-warn")
    win = olay_window(list_C(paper_weeks=1), p, (7, 1, 2), kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, rail("olaylar", badges(("count", "1"))), win,
                  notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_kagit_karar_beklerken():
    mm = mails()
    p = pane(mm["expansion"], reply(paper_bar(2, gated=True), show_perm=False), state=s("st_in_weeks", n=2))
    win = olay_window(list_A(sel=None, paper_sel=True), p, (8, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", GATE_SUB), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_bildirimler():
    rec = ('<div class="pane"><div class="pane-col">'
           '<div class="pane-kicker">%s<span class="kind t-meta">%s</span></div>'
           '<div class="rec-head"><span class="mono" style="width:48px;height:48px;font-size:var(--fs-18)">ES</span>'
           '<h2 class="pane-title t-h2">Ege Sigorta</h2>%s</div>'
           '<div class="rec-facts">'
           '<div class="part"><span class="part-k">MRR</span><span class="part-v">%s</span></div><span class="part-sep"></span>'
           '<div class="part"><span class="part-k">%s</span><span class="part-v">12</span></div><span class="part-sep"></span>'
           '<div class="part"><span class="part-k">%s</span><span class="part-v">25</span></div><span class="part-sep"></span>'
           '<div class="part"><span class="part-k">%s</span><span class="part-v">%s</span></div></div>'
           '<div class="rec-line"><i>%s</i></div>'
           '<div class="rec-line"><span class="k">%s</span></div>'
           '<div class="reply" style="margin-top:24px"><div class="reply-acts"><span class="btn btn-primary">%s</span></div></div>'
           '</div></div>'
           % (pill("customer"), s("k_attention"), tag(T("risk_tag"), "risk"),
              num("$1,0K") + '<span class="tb-u">%s</span>' % T("per_mo"),
              L("Koltuk", "Seats"), L("Memnuniyet", "Satisfaction"), L("Müşteri", "Customer"),
              L("2 aydır", "2 mo"),
              L("Sebep: sık kesinti şikayeti", "Reason: frequent outage complaints"),
              L("Müşteri temsilcisi: atanmadı", "Account manager: not assigned"),
              L("İlgilen", "Check in")))
    rows = list_C(paper_weeks=None, sel="ege", notices=("ege", "selin", "nordica"))
    win = olay_window(rows, rec, (7, 0, 1))
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, rail("olaylar", badges()), win,
                  notices=(("is-risk", "Ege Sigorta", T("risk_tag")), ("", "Nordica", T("s_expansion"))))


def f_calisan_ayrilik():
    mm = mails()
    stake = ('<div class="stake"><div class="part danger"><span class="part-k">%s</span><span class="part-v txt">%s%s</span></div>'
             '<span class="btn btn-primary btn-lg">%s</span></div>'
             % (s("part_team"), ic("warn"), L("Selin ayrılıyor", "Selin is leaving"), L("Anlaşıldı", "Understood")))
    p = pane(mm["resign"], reply(stake), state=s("st_waiting"), state_cls="is-gate")
    rows = [r_mail(mm["resign"], "is-gate is-selected"),
            r_paper(mm["expansion"], 2, "is-unread", blocked=True), r_notice("ege"),
            r_day(14), r_mail(mm["rnd"], "is-unread", ic("doc") + L("rapor", "report")), r_report(mm["summary"]),
            r_day(1), r_intro(mm["intro"])]
    win = olay_window("".join(rows), p, (7, 2, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", "Selin Kaya"), None, marks=(14,))
    return screen(top, rail("olaylar", badges(("gate", ""))), win)


def f_ayrilmis_gonderici():
    mm = mails()
    m = mm["resign"]
    chosen = answered(L("Anlaşıldı", "Understood"), fx("danger", L("Selin ayrılıyor", "Selin is leaving")), stamp(s("st_left"), "H14"))
    p = pane(m, reply(chosen, show_perm=False, label=T("your_choice")), gone=True)
    rows = [r_paper(mm["expansion"], 1, "is-unread"), r_notice("ege"),
            r_day(14), r_history(m, s("st_left"), L("Anlaşıldı", "Understood"), " is-selected is-gone", gone=True),
            r_mail(mm["rnd"], "", ic("doc") + L("rapor", "report")), r_report(mm["summary"]),
            r_day(1), r_intro(mm["intro"])]
    win = olay_window("".join(rows), p, (7, 1, 1), kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, rail("olaylar", badges(("count", "1"), ekip=False)), win,
                  notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_donem_ozeti():
    mm = mails()
    m = mm["summary"]
    up = ic("up", 14)

    def row(k, a, b, d, kind):
        cls = {"gain": "color:var(--pos)", "flat": "color:var(--ink-3)"}[kind]
        g = up if kind == "gain" else ""
        return ('<div class="td k">%s</div><div class="td strong">%s<span class="ar">→</span>%s</div>'
                '<div class="td r" style="%s;gap:6px">%s%s</div>' % (k, a, b, cls, d, g))

    grid = ('<div class="rpt"><div class="t-meta" style="color:var(--ink-3)">%s</div>'
            '<div class="rpt-grid" style="grid-template-columns:140px 1fr 120px;margin-top:8px">%s%s%s%s'
            '<div class="td k">Runway</div><div class="td strong" style="color:var(--pos)">%s</div><div class="td r"></div></div>'
            '<div class="hl"><span class="k t-label">%s</span><span class="v">%s</span></div></div>'
            % (L("Hafta 1-14 · Bootstrap", "Weeks 1-14 · Bootstrap"),
               row("MRR", "$0", num("$4,0K"), num("+$4,0K"), "gain"),
               row(L("Kasa", "Cash"), num("$10,0K"), num("$10,0K"), "±0", "flat"),
               row(L("Ekip", "Team"), "1", "6", "+5", "gain"),
               row(L("Marka", "Brand"), "50", "50", "±0", "flat"),
               T("profitable"),
               L("Çeyreğin olayı", "Event of the quarter"),
               L("Sakin bir çeyrek. Sakin çeyrekler ucuz değildir.", "A quiet quarter. Quiet quarters are not cheap.")))
    acts = ('<div class="reply"><div class="reply-acts"><span class="t-meta" style="color:var(--ink-3)">%s</span>'
            '<span class="btn btn-primary">%s</span></div></div>'
            % (L("Otomatik özet · her çeyrek sonu", "Automatic summary · at each quarter end"), L("Devam et", "Continue")))
    p = pane(m, acts, extra_body=grid)
    win = olay_window(list_C(sel="summary"), p, (7, 1, 3), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 8, ("next", T("next_meet"), ""), "II", marks=(14,))
    return screen(top, rail("olaylar", badges(("count", "1"))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_frank_tanisma():
    mm = mails()
    m = mm["intro"]
    acts = '<div class="reply"><div class="reply-acts"><span class="btn btn-primary btn-lg">%s</span></div></div>' % L("Hadi başlayalım", "Let's get started")
    p = pane(m, acts, state=None)
    rows = r_day(1) + r_intro(m, "is-selected")
    win = olay_window(rows, p, (1, 0, 0))
    top = topbar(SEED1, 1, 9, ("next", L("Mesai bitimi · 8 saat", "Workday ends · 8 h"), ""), "II")
    return screen(top, rail("olaylar", {}), win, office="home", hud=False)


def f_arge_notu():
    mm = mails()
    acts = ('<div class="reply"><div class="reply-acts"><span class="btn btn-secondary">%s</span><span class="btn btn-secondary">%s</span></div></div>'
            % (L("Ar-Ge'ye git", "Go to R&D"), L("Ürün sayfasına git", "Go to the product page")))
    p = pane(mm["rnd"], acts)
    win = olay_window(list_C(sel="rnd"), p, (7, 1, 2), kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, rail("olaylar", badges(("count", "1"))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_haftalik_satis():
    mm = mails()
    m = mm["weekly"]
    st = '<span class="stars">%s</span>'

    def stars(n):
        return st % ("".join(ic("star") for _ in range(n)) + "".join('<span class="off">%s</span>' % ic("star_empty") for _ in range(5 - n)))

    grid = ('<div class="rpt"><div class="rpt-grid" style="grid-template-columns:1fr 104px 64px 64px 112px">'
            '<span class="th t-label">%s</span><span class="th t-label">%s</span><span class="th t-label r">%s</span>'
            '<span class="th t-label r">%s</span><span class="th t-label r">%s</span>'
            '<div class="td strong">Karadeniz Fabrika</div><div class="td">%s</div><div class="td r">12</div><div class="td r">$85</div>'
            '<div class="td r" style="color:var(--pos)">+%s</div>'
            '<div class="td strong">Efes Emlak</div><div class="td">%s</div><div class="td r">8</div><div class="td r">$75</div>'
            '<div class="td r" style="color:var(--pos)">+%s</div></div>'
            '<div class="rpt-total"><span>%s: <b>%s</b></span><span>%s: <b>5</b></span></div></div>'
            % (s("rpt_customer"), s("rpt_stars"), s("rpt_seats"), s("rpt_price"), s("rpt_mrr"),
               stars(2), num("$1.020") + T("per_mo"), stars(1), num("$600") + T("per_mo"),
               s("rpt_total"), L("2 anlaşma · $1.620/ay", "2 deals · $1,620/mo"), L("Defterdeki hesap", "Accounts on the books")))
    p = pane(m, "", extra_body=grid, well=False)
    mm2 = mails()
    rows = [r_paper(mm2["expansion"], 1, "is-unread"), r_notice("ege"), r_notice("selin"),
            r_day(15), r_mail(m, "is-selected", ic("doc") + L("rapor", "report")),
            r_day(14), r_mail(mm2["rnd"], "", ic("doc") + L("rapor", "report")), r_report(mm2["summary"]),
            r_day(1), r_intro(mm2["intro"])]
    win = olay_window("".join(rows), p, (8, 1, 1), kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, rail("olaylar", badges(("count", "1"))), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_bos_kutu():
    rows = ('<div class="empty ib-empty">%s<span class="empty-t">%s</span></div>' % (ic("inbox"), s("list_empty")))
    p = '<div class="pane"><div class="pane-empty">%s<span class="t">%s</span></div></div>' % (ic("mail_open"), s("pane_empty"))
    win = olay_window(rows, p, (6, 0, 0), active=1)
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, rail("olaylar", badges()), win, notices=(("is-risk", "Ege Sigorta", T("risk_tag")),))


def f_ekip_salt_okunur():
    w = kit.ekip_window(208, 88, readonly=True)
    w = w.replace(T("frank_offer"), "Frank Köseoğlu · %s" % L("Teklif", "An offer"))
    w = w.replace('<span class="btn btn-secondary btn-sm">%s%s</span></div></div></div></section>' % (ic("plus"), T("recruit")),
                  '<span class="btn btn-secondary btn-sm is-disabled">%s%s</span></div></div></div></section>' % (ic("plus"), T("recruit")))
    top = topbar(SEED14, 14, 11, ("gate", GATE_SUB), None, marks=(14,))
    return screen(top, rail("ekip", badges(("gate", ""))), w)


def gallery():
    """Sender types as mail headers (SENDERS.md); the named contact shows the proposal with a real counterpart bust."""
    to = s("founder_to")
    vc = os.path.join(MEN, "art", "busts", "vc", "bust_anchor_0_vc_lead.png")
    buyer = os.path.join(MEN, "art", "busts", "prospect", "bust_lead_14_2_0_buyer.png")
    cards = [
        (L("Frank", "Frank"), av_person(FRANK), "Frank Köseoğlu", "Operating Partner", to),
        (L("Çalışan", "Employee"), av_person(BUST["elif"]), "Elif Demir", L("Ürün Yöneticisi", "Product Manager"), to),
        (L("Muhatap · imzadan sonra masadaki alıcı (öneri)", "Contact · after signing, the buyer from the table (proposal)"),
         av_person(buyer), "Elif Yıldız", L("Satın Alma Sorumlusu · Karadeniz Fabrika", "Procurement Lead · Karadeniz Fabrika"), to),
        (L("Muhatap · lead'i olmayan hesap", "Contact · an account with no lead"), av_mono("ES"), "Ege Sigorta",
         L("BT Müdürü", "IT Manager"), to),
        ("VC", av_person(vc), "Kerem Kaya", L("Kıdemli Ortak · Anchor Capital", "Senior Partner · Anchor Capital"), to),
        (L("Basın", "Press"), av_mono("GB", "outlet girisim"), "Girişim Bülteni", "", to),
        (L("Şirket masası", "Company desk"), av_doc(), L("Destek", "Support"), "Unicorn Inc.", to),
        (L("Kurucunun notu", "The founder's note"), av_person(FOUNDER), L("Kurucu", "Founder"), L("Kendine not", "Note to self"), None),
        (L("Dış gönderen", "Outside sender"), av_mono("AA"), L("Alan adı aracısı", "Domain reseller"), "", to),
    ]
    out = []
    for i, (lbl, av, n, r, t) in enumerate(cards):
        x, y = 40 + (i % 3) * 620, 640 + (i // 3) * 132
        l2 = ('<div class="mh-l2"><span class="k">%s</span><span class="v">%s</span></div>' % (s("to"), t)) if t else ""
        out.append('<div class="gal" style="left:%dpx;top:%dpx"><div class="gal-k t-caption">%s</div>'
                   '<div class="mh" style="margin-top:8px;padding-bottom:0;border:0">%s<div class="mh-who"><div class="mh-l1">'
                   '<span class="n">%s</span><span class="r">%s</span></div>%s</div></div></div>' % (x, y, lbl, av, n, r, l2))
    head = ('<div style="position:absolute;left:40px;top:604px"><span class="t-data-strong" style="color:var(--ink-2)">%s</span>'
            '<span class="t-caption" style="margin-left:12px;color:var(--ink-3)">%s</span></div>'
            % (L("Gönderen türleri", "Sender types"), L("SENDERS.md · onay bekliyor", "SENDERS.md · awaiting approval")))
    return head + "".join(out)


def f_taslak():
    """Drafts sheet: the two converted cards no shell frame shows (Frank's one-option beat, the press paper)."""
    mm = mails()
    stake = ('<div class="stake sm"><div class="opt-fx">%s%s</div><span class="btn btn-primary btn-lg">%s</span></div>'
             % (fx("gain", L("Yeni aday", "A new prospect")), fx_flat(L("Seni oraya götürür", "Takes you there")),
                L("Satış'a git", "Go to Sales")))
    p1 = pane(mm["intro_b2b"], reply(stake), state=s("st_waiting"), state_cls="is-gate")
    pbar = ('<div class="paper-bar"><span class="when t-key">%s%s</span><span class="btn btn-primary">%s%s</span></div>'
            % (ic("clock"), s("st_in_weeks", n=4), ic("reply"), T("reply")))
    p2 = pane(mm["press"], reply(pbar, show_perm=False), state=s("st_in_weeks", n=4))
    cap = ('<div style="position:absolute;left:%dpx;top:28px;color:var(--ink-3)">'
           '<span class="t-data-strong" style="color:var(--ink-2)">%s</span><span class="t-caption" style="margin-left:12px">%s</span></div>')
    win = ('<section class="win" style="left:%dpx;top:72px;width:900px">%s</section>')
    gal = gallery()
    return ('<div class="screen" style="background:var(--surface-0)">%s%s%s%s%s</div>'
            % (gal, cap % (40, "customer.frank_intro", L("Frank'in tek seçenekli anı · taslak · tarih tohum haftasında tutuldu",
                                                     "Frank's one-option beat · draft · date held at the seed week")),
               win % (40, p1),
               cap % (980, "world.final_stretch_press", L("Basın kağıdı · taslak · en erken tik 91 · açınca tek seçenek: Dosyayı kenara koy, etkisiz",
                                                          "Press paper · draft · earliest tick 91 · once opened, one option: Set the file aside, no effect")),
               win % (980, p2)))


FRAMES = {
    "olaylar__frank_teklif": ("tr", f_frank_offer),
    "olaylar__frank_teklif_en": ("en", f_frank_offer),
    "olaylar__musteri_secenek_acik": ("tr", f_musteri_secenek_acik),
    "olaylar__musteri_secenek_acik_en": ("en", f_musteri_secenek_acik),
    "olaylar__kilitli_secenek": ("tr", f_kilitli_secenek),
    "olaylar__kagit_onizleme": ("tr", f_kagit_onizleme),
    "olaylar__kagit_son_hafta": ("tr", f_kagit_son_hafta),
    "olaylar__kagit_karar_beklerken": ("tr", f_kagit_karar_beklerken),
    "olaylar__bildirimler": ("tr", f_bildirimler),
    "olaylar__gecmis_karar": ("tr", f_gecmis_karar),
    "olaylar__calisan_ayrilik": ("tr", f_calisan_ayrilik),
    "olaylar__ayrilmis_gonderici": ("tr", f_ayrilmis_gonderici),
    "olaylar__donem_ozeti": ("tr", f_donem_ozeti),
    "olaylar__frank_tanisma": ("tr", f_frank_tanisma),
    "olaylar__arge_notu": ("tr", f_arge_notu),
    "olaylar__haftalik_satis": ("tr", f_haftalik_satis),
    "olaylar__bos_kutu": ("tr", f_bos_kutu),
    "olaylar__kuyruk": ("tr", f_kuyruk),
    "ekip__salt_okunur_karar_bekliyor": ("tr", f_ekip_salt_okunur),
    "olaylar__taslak_frank_ani_basin": ("tr", f_taslak),
    "olaylar__taslak_frank_ani_basin_en": ("en", f_taslak),
}


def build(names):
    global LANG
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        lang, fn = FRAMES[n]
        LANG = lang
        set_lang(lang)
        html = page(n, fn())
        with open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8") as f:
            f.write(html)
        print(os.path.join(BUILD, n + ".html"))
    set_lang("tr")


if __name__ == "__main__":
    build(sys.argv[1:] or list(FRAMES))
