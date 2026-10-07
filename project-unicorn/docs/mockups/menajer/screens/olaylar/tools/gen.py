"""Olaylar as mail: builds every frame of group "olaylar" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Render with ../tools/render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css,
icons, crop rule, top bar geometry) is read from ../../../system through the copies in syskit/, whose caches
live in this folder so nothing is ever written into the system folder.

The shell (top bar and brand block, rail, ticker, office layer, BuildHUD, notice stack, Ofisi taşı) is single
sourced: it is built by the kabuk group's tools/gen.py (loaded read only below) and styled by its kabuk.css, so
every frame here shows the same shell the kabuk frames show. This file builds the inbox and the reading pane.
"""
import importlib.util
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
sys.path.insert(0, os.path.join(HERE, "syskit"))

import common  # noqa: E402
import kit  # noqa: E402
import measure  # noqa: E402
from common import T, ic, num, set_lang  # noqa: E402
from kit import tag, pill, stamp, fx  # noqa: E402

MEN = common.MENAJER
REL = "../../../"  # build/ -> menajer/


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


def _load_kabuk():
    path = os.path.normpath(os.path.join(ROOT, "..", "kabuk", "tools", "gen.py"))
    spec = importlib.util.spec_from_file_location("kabuk_gen", path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


K = _load_kabuk()      # the shell builders (read only; kabuk owns them)
common._src = _src     # avatar() and portrait() resolve image paths through this (same value as kabuk's)

FRANK = os.path.join(MEN, "portraits", "frank_cand_a.png")
FOUNDER = os.path.join(MEN, "portraits", "founder_01.png")
BUST = {k: os.path.join(MEN, "art", "bust_%s.png" % k) for k in ("elif", "deniz", "mert", "selin", "burak")}

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


# The mail header's date column: one fixed width, the worst TR and EN value with an hour, Godot slack included.
DATE_W = max(measure.godot(w) for w in measure.measure(
    [("tr%d" % i, "t-meta", "Hafta 52 · %s 2026 · 09:00" % m, "tr") for i, m in enumerate(MON_TR)]
    + [("en%d" % i, "t-meta", "Week 52 · %s 2026 · 09:00" % m, "en") for i, m in enumerate(MON_EN)]).values())


# ------------------------------------------------------------------ new strings this group introduces (EN first; listed in INDEX.md)
S = {
    "reply": ("Your reply", "Cevabın"),
    "to": ("To", "Kime"),
    "founder_to": ("Founder · Unicorn Inc.", "Kurucu · Unicorn Inc."),
    "k_decision": ("Decision", "Karar"), "k_paper": ("Paper", "Kağıt"), "k_report": ("Report", "Rapor"),
    "k_message": ("Message", "Mesaj"), "k_attention": ("Attention", "Dikkat"),
    "st_waiting": ("Answer needed", "Cevap bekliyor"),
    "st_in_weeks": ("Within {n} weeks", "{n} hafta içinde"), "st_final": ("Final week", "Bu hafta son"),
    "st_left": ("Left", "Ayrıldı"),
    "accounts": ("Accounts", "Muhasebe"),
    "row_report": ("report", "rapor"),
    "list_empty": ("Nothing waiting.", "Bekleyen bir şey yok."),
    "pane_empty": ("No message selected.", "Seçili mesaj yok."),
    "rpt_customer": ("Customer", "Müşteri"), "rpt_stars": ("Stars", "Yıldız"), "rpt_seats": ("Seats", "Koltuk"),
    "rpt_price": ("Price", "Fiyat"), "rpt_mrr": ("MRR", "MRR"), "rpt_total": ("Total", "Toplam"),
    "rpt_closed": ("Closed last week:", "Geçen hafta kapananlar:"),
    "rpt_books": ("Accounts on the books: {n}", "Defterdeki hesap: {n}"),
    "part_team": ("Team", "Ekip"),
    "reason": ("Reason:", "Sebep:"),
    "am": ("Account manager:", "Müşteri temsilcisi:"), "am_none": ("not assigned", "atanmadı"),
    "sum_team": ("Team · incl. founder", "Ekip · kurucu dahil"),
    "set_aside": ("Set aside", "Kenara koy"),
    "draft": ("Draft", "Taslak"),
    # the chance decision (a state example: no shipped card carries a check today)
    "o_raise": ("Offer a raise", "Zam teklif et"), "o_case": ("Make the case to stay", "Kalması için konuş"),
    "p_stays": ("Stays", "Kalır"), "p_if": ("If she stays", "Kalırsa"), "p_ifnot": ("If not", "Kalmazsa"),
    "fx_salary": ("Salary +$700/mo", "Maaş +$700/ay"), "fx_stays": ("{who} stays", "{who} kalır"),
    "m_raise": ("A raise on the table", "Zam teklifi"), "m_morale": ("Low morale", "Morali düşük"),
    "m_offer": ("An offer from elsewhere", "Elinde başka teklif var"),
}


def s(key, **kw):
    en, tr = S[key]
    v = tr if LANG == "tr" else en
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ the shell, from the kabuk group
def topbar(v, week, clock, slot, speed="II", marks=()):
    """slot: ("gate", sub) | ("next", text, kind)."""
    return K.topbar(v=v, week=week, clock=clock, slot=slot, speed=speed, marks=marks)


B14 = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


def badges(olaylar=None, ekip=True):
    b = dict(B14)
    if not ekip:
        b.pop("ekip")
    if olaylar:
        b["olaylar"] = olaylar
    return b


GATE = ("gate", "")


def page(name, body, cb=False):
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>Olaylar</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../../kabuk/kabuk.css"><link rel="stylesheet" href="../olaylar.css"></head><body%s>%s</body></html>'
            % (LANG, common.FONTS, REL, REL, ' class="cb"' if cb else "", body))


def screen(top, rail_html, window, items, office="ishani", hud=True, extra=""):
    """The notice stack is the inbox's preview: the papers and reminders of `items`, in inbox order, as kabuk's mail
    records (the list already leaves out the reminder about the active decision)."""
    stack = [it["stack"] for it in items if it.get("stack")]
    fl = (K.buildhud(1576, 88) if hud else "") + K.notices(1920, 1080, stack) + extra
    return '<div class="screen">%s%s%s%s%s%s</div>' % (K.office1920(office, dim=True), fl, window, top, rail_html, K.ticker())


# ------------------------------------------------------------------ sender tiles
def av_person(path, size=40, cls=""):
    return common.avatar(path, size, cls)


def initials(name):
    return "".join(w[0] for w in name.split()[:2]).upper()


def av_mono(name, cls=""):
    return '<span class="mono m40 t-subhead %s">%s</span>' % (cls, initials(name))


def av_doc():
    return '<span class="mono m40">%s</span>' % ic("doc")


# ------------------------------------------------------------------ the mails (EN first in DRAFTS.md; here both, picked by LANG)
def M(**kw):
    return kw


def mails():
    to = s("founder_to")
    return {
        "offer": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                   kind="k_decision", week=14, subject=L("Teklif", "An offer"), serif=True, draft=True,
                   body=[L("Ürün para kazandırmaya başladı.", "The product has started making money."),
                         L("Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar "
                           "koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?",
                           "You got this far on your own savings and your own work. I'll put in twenty-five thousand to "
                           "speed things up, and I'll take four percent. No haggling. I'm asking once: do you want it?")],
                   sig=("Frank Köseoğlu", "Operating Partner"), to=to),
        "risk": M(frm="Ege Sigorta", role=L("BT Müdürü", "IT Manager"), av=av_mono("Ege Sigorta"), topic="customer",
                  kind="k_decision", week=14, subject=L("Konuşmamız gerek", "We need to talk"),
                  body=[L("Merhaba,", "Hello,"),
                        L("Ekibim sistemin içinde çalışmaktan çok etrafından dolanıyor. Bu böyle sürmez.",
                          "My team works around it more than they work in it. That has to stop."),
                        L("Saygılarımla,", "Regards,")],
                  greet=True, sig=(L("BT Müdürü", "IT Manager"), "Ege Sigorta"), to=to),
        "risk_broken": M(frm="Ege Sigorta", role=L("BT Müdürü", "IT Manager"), av=av_mono("Ege Sigorta"), topic="customer",
                         kind="k_decision", week=14, subject=L("Konuşmamız gerek", "We need to talk"),
                         body=[L("Merhaba,", "Hello,"),
                               L("Olacak dediniz, olmadı. Başka seçeneklere bakmaya başladık.",
                                 "You said it would be there. It isn't. We've started looking at other options."),
                               L("Saygılarımla,", "Regards,")],
                         greet=True, sig=(L("BT Müdürü", "IT Manager"), "Ege Sigorta"), to=to),
        "expansion": M(frm="Nordica", role=L("Operasyon Müdürü", "Operations Manager"), av=av_mono("Nordica"), topic="customer",
                       kind="k_paper", week=14, subject=L("Bir ekip daha", "One more team"), dot="",
                       body=[L("Merhaba,", "Hello,"),
                             L("Sistemi bir ekibimize daha açmak istiyoruz. Koltukları aynı fiyattan ekleyebilir misiniz?",
                               "We'd like to roll the system out to another team. Could you add the seats at the same price?"),
                             L("Saygılarımla,", "Regards,")],
                       greet=True, sig=(L("Operasyon Müdürü", "Operations Manager"), "Nordica"), to=to),
        "resign": M(frm="Selin Kaya", role=L("Test Mühendisi", "QA Engineer"), av=av_person(BUST["selin"]), well=BUST["selin"],
                    topic="team", kind="k_decision", week=14, subject=L("İstifa dilekçem", "My notice"),
                    body=[L("Merhaba,", "Hi,"),
                          L("Başka bir yerden teklif geldi. Doğrusunu istersen, aramayı ben yaptım.",
                            "I got an offer from somewhere else. Honestly, I made the call myself.")],
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
                     subject=L("1. Çeyrek 2026", "Q1 2026"), body=[], sig=(s("accounts"), "Unicorn Inc."), to=to,
                     preview=L("MRR $0 → $4,0K · Kasa ±0", "MRR $0 → $4.0K · Cash ±0")),
        "weekly": M(frm="Burak Şahin", role=L("Satış Temsilcisi", "Sales Representative"), av=av_person(BUST["burak"]),
                    well=BUST["burak"], topic="customer", kind="k_report", week=15,
                    subject=L("Haftanın satışları", "The week in sales"),
                    body=[s("rpt_closed")],
                    sig=("Burak Şahin", L("Satış Temsilcisi · Unicorn Inc.", "Sales Representative · Unicorn Inc.")), to=to,
                    preview=L("Karadeniz Fabrika, Efes Emlak · $1.620/ay", "Karadeniz Fabrika, Efes Emlak · $1,620/mo")),
        "intro_b2b": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                       kind="k_decision", week=14, subject=L("Eski bir dost", "An old friend"), serif=True, draft=True,
                       body=[L("Eski bir dostuma senin üründen bahsettim. İşine yarayabileceğini düşünüyor. Bir görüşme "
                               "ayarladım. Hazırlıklı git.",
                               "I told an old friend of mine about what you've built. He thinks it might be useful to him. "
                               "I've set up a meeting. Go in prepared.")],
                       sig=("Frank Köseoğlu", "Operating Partner"), to=to),
        "press": M(frm="Sektör Telgrafı", role="", av=av_mono("Sektör Telgrafı", "outlet sektor"), topic="agenda", kind="k_paper", week=91,
                   subject=L("Yıllık dosya", "The annual file"),
                   body=[L("Yıllık dosya çıktı: seninle aynı yıl kurulan şirketlerin listesi.",
                           "This year's annual file is out: every company founded the same year as yours."),
                         L("Çoğunun yanında bir tur, bir satış ya da bir kapanış yazıyor. Seninkinin yanında ilk gün "
                           "yazdığımız satır duruyor.",
                           "Most have a round, a sale or a closure next to the name. Next to yours is the line we ran on day one."),
                         L("Dosya yorum yapmaz. Yalnız sıralar.", "The file does not comment. It only lists.")],
                   sig=("Sektör Telgrafı", ""), to=to),
        "intro": M(frm="Frank Köseoğlu", role="Operating Partner", av=av_person(FRANK), well=FRANK, topic="mentor",
                   kind="k_message", week=1, hour=9, subject=L("Ben Frank", "It's Frank"), serif=True, draft=True,
                   body=[L("Eski şirketten hatırlarsın. İstifa ettin mi, yoksa hâlâ düşünüyor musun?",
                           "You'll remember me from your old company. Did you quit, or are you still thinking about it?"),
                         L("Elinde ne var şu an, fikir mi yoksa çalışan bir şey mi? Fikirse ilk sürümü yazacak kimse yok. "
                           "Sen yazacaksın, muhtemelen kötü olacak ama normal olan bu zaten.",
                           "So what have you actually got, an idea or something that works? If it's an idea, there's nobody "
                           "to write the first version. You'll write it, and it'll probably be bad.")],
                   sig=("Frank Köseoğlu", "Operating Partner"), to=to),
        # history only (the long inbox): the card's title stands in for a subject not drafted yet
        "request": M(frm="Nordica", topic="customer", subject=L("Müşteri talebi", "Customer request"), week=13),
        "complaint": M(frm="Ege Sigorta", topic="customer", subject=L("Müşteri şikâyeti", "Customer complaint"), week=11),
        "paid": M(frm="Frank Köseoğlu", topic="mentor", subject=L("Fiyat meselesi", "About the price"), week=5),
    }


def preview_of(m):
    if m.get("preview"):
        return m["preview"]
    body = m["body"]
    return body[1] if m.get("greet") and len(body) > 1 else body[0]


# ------------------------------------------------------------------ inbox items: each row says what it counts as and what it puts on the stack
def It(html, kind, unread=False, stack=None, n=1, h=96):
    """kind: gate | paper | notice | mail | history | queue | day. n counts the queue row's folded decisions."""
    return dict(html=html, kind=kind, unread=unread, stack=stack, n=n, h=h)


def counts(items):
    """Tümü: every item (queued decisions included); Bekleyen: decisions and papers; Okunmamış: unread dots and
    the queued decisions nobody has opened."""
    tot = sum(i["n"] for i in items if i["kind"] != "day")
    wait = sum(i["n"] for i in items if i["kind"] in ("gate", "paper", "queue"))
    unread = sum(i["n"] for i in items if i["unread"] or i["kind"] == "queue")
    return tot, wait, unread


def _from(m, gone=False):
    return m["frm"] + ((' <span class="gone">· %s</span>' % s("st_left")) if gone else "")


def r_gate(m, selected=True):
    return It(kit.ib_row(m["frm"], m["topic"], m["subject"], "", preview_of(m), "is-gate" + (" is-selected" if selected else "")), "gate")


def r_mail(m, unread=False, selected=False, right=""):
    cls = ("is-unread" if unread else "") + (" is-selected" if selected else "")
    return It(kit.ib_row(m["frm"], m["topic"], m["subject"], right, preview_of(m), cls), "mail", unread=unread)


def r_report(m, unread=False, selected=False):
    return r_mail(m, unread, selected, ic("doc") + s("row_report"))


def r_intro(m, selected=False):
    return r_mail(m, False, selected, "09:00")


def r_paper(m, weeks, unread=True, selected=False, blocked=False):
    last = weeks == 1
    left = T("wk_this") if last else T("weeks_n", n=weeks)
    cls = ("is-unread" if unread else "") + (" is-lastweek" if last else "") + (" is-blocked" if blocked else "") + (" is-selected" if selected else "")
    html = kit.ib_row(m["frm"], m["topic"], m["subject"], ic("clock") + left, preview_of(m), cls)
    return It(html, "paper", unread=unread, stack=K.mail(m["frm"], (m["subject"], m["subject"]), m["dot"], weeks=weeks))


def _key_line(k, v):
    return '<span class="rk">%s</span> %s' % (k, v)


def r_notice(key, selected=False):
    sel = " is-selected" if selected else ""
    if key == "ege":
        html = kit.ib_row("Ege Sigorta", "customer", tag(T("risk_tag"), "risk"), num("$1,0K") + T("per_mo"),
                          _key_line(s("reason"), L("sık kesinti şikayeti", "frequent outage complaints")), "is-notice" + sel)
        return It(html, "notice", stack=K.EGE)
    if key == "selin":
        mv = '<span class="t-label" style="color:var(--ink-3)">%s</span><b style="color:var(--neg)">22</b>' % T("risk_morale")
        html = kit.ib_row("Selin Kaya", "team", tag(T("st_risk"), "risk"), mv,
                          L("Test Mühendisi · Test ediyor", "QA Engineer · Testing"), "is-notice" + sel)
        return It(html, "notice", stack=K.SELIN)
    if key == "nordica":
        html = kit.ib_row("Nordica", "customer", tag(T("grow_tag"), "pos"), num("$2,0K") + T("per_mo"),
                          L("Başka departmana yaymak istiyor.", "Wants to roll it out to another department."), "is-notice" + sel)
        return It(html, "notice", stack=K.mail("Nordica", (T("grow_tag"), T("grow_tag")), kind="reminder", about="co_nordica"))


def r_queue(n):
    html = ('<div class="ib-queue">%s<span class="t-meta">%s</span><span class="t-caption" style="margin-left:auto;color:var(--ink-3)">%s</span></div>'
            % (ic("queue", 18), L("%d karar daha sırada" % n, "%d more decisions queued" % n), T("queue_after")))
    return It(html, "queue", n=n, h=44)


def r_day(week):
    return It('<div class="ib-day t-caption">%s</div>' % date(week), "day", h=28)


def r_history(m, stamp_txt, choice, selected=False, gone=False):
    pre = '<span class="ch-k">%s:</span> %s' % (T("your_choice"), choice)
    cls = "is-history" + (" is-selected" if selected else "") + (" is-gone" if gone else "")
    return It(kit.ib_row(_from(m, gone), m["topic"], m["subject"], "", pre, cls, False, stamp(stamp_txt)), "history")


def tail14(mm, sel=None, rnd_read=False):
    return [r_day(14), r_report(mm["rnd"], unread=not (rnd_read or sel == "rnd"), selected=sel == "rnd"),
            r_report(mm["summary"], selected=sel == "summary")]


def tail1(mm, sel=False):
    return [r_day(1), r_intro(mm["intro"], sel)]


# ------------------------------------------------------------------ reading pane
def kicker(m, state=None, state_cls=""):
    st = ('<span class="sep">·</span><span class="state t-meta %s">%s</span>' % (state_cls, state)) if state else ""
    return '<div class="pane-kicker">%s<span class="kind t-meta">%s</span>%s</div>' % (pill(m["topic"]), s(m["kind"]), st)


def header(m, gone=False):
    """Line 1 is the sender's (name, then the role, which ellipsizes); line 2 is To and the date, the date in a fixed
    right column measured for the worst TR and EN value, so a long role never meets it."""
    av = m["av"]
    if gone:
        av = av.replace('class="av av-40 ', 'class="av av-40 is-gone ')
    l1 = '<span class="n">%s</span><span class="r">%s</span>' % (m["frm"], m["role"])
    if gone:
        l1 += '<span class="sep">·</span><span class="gone">%s</span>' % s("st_left")
    return ('<div class="mh">%s<div class="mh-who"><div class="mh-l1">%s</div>'
            '<div class="mh-l2"><span class="k">%s</span><span class="v">%s</span>'
            '<span class="mh-date" style="width:%dpx">%s</span></div></div></div>'
            % (av, l1, s("to"), m["to"], DATE_W, date(m["week"], m.get("hour"))))


def body_html(m, extra=""):
    ps = "".join("<p>%s</p>" % p for p in m["body"])
    cls = "mbody" + (" serif" if m.get("serif") else "")
    sig = '<div class="msig"><span class="n">%s</span>%s</div>' % (m["sig"][0], ('<span class="r">%s</span>' % m["sig"][1]) if m["sig"][1] else "")
    if m.get("draft"):
        sig = '<div class="msig-row">%s<span class="draft-mark t-micro">%s</span></div>' % (sig, s("draft"))
    return '<div class="%s">%s%s</div>%s' % (cls, ps, extra, sig)


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


def acts(*buttons, note=""):
    """One action row for messages, reports and records: right aligned, the primary rightmost, 40 px buttons.
    (A decision's single open option keeps the system's armed stake box and its 56 px button.)"""
    n = '<span class="note t-meta">%s</span>' % note if note else ""
    return '<div class="reply"><div class="reply-acts">%s%s</div></div>' % (n, "".join(buttons))


def btn(label, kind="primary"):
    return '<span class="btn btn-%s">%s</span>' % (kind, label)


def fx_flat(text):
    return '<span class="fx neutral">%s</span>' % text


def answered(label, chips, stamp_html):
    return ('<div class="answered"><div class="answered-l"><span class="opt-label">%s</span><div class="chosen-fx">%s</div></div>%s</div>'
            % (label, chips, stamp_html))


def opt_locked(label, why):
    return kit.opt(label, state="is-locked", why=why)


# ------------------------------------------------------------------ window
def olay_window(items, pane_html, active=0, kpi=None, scroll=0):
    kpi_html = ""
    if kpi:
        kpi_html = ('<div class="win-kpis"><div class="kpi"><span class="kpi-key t-label">%s</span>'
                    '<span class="kpi-val t-kpi%s">%s</span></div></div>' % (T("k_soonest"), " warn" if kpi[1] else "", kpi[0]))
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1>%s<div class="grow"></div><span class="win-close">%s</span></div>'
            % (T("ev_title"), kpi_html, ic("close")))
    tabs = "".join('<span class="seg-tab t-tab%s">%s<span class="n">%d</span></span>' % (" is-active" if i == active else "", T(k), c)
                   for i, (k, c) in enumerate(zip(("f_all", "f_wait", "f_unread"), counts(items))))
    rows = "".join(i["html"] for i in items) if isinstance(items, list) else items
    sb = ""
    if scroll:
        # the list scrolls inside its 12 px gutter: an 8 px bar 2 px from the edge, 8 px in from the head and the foot
        view, track = 900 - 72 - 44 - 2, 900 - 72 - 44 - 2 - 16
        full = sum(i["h"] + 1 for i in items)
        rows = '<div class="ib-scroll"><div class="ib-rows" style="margin-top:-%dpx">%s</div></div>' % (scroll, rows)
        sb = ('<div class="sb" style="right:2px;top:52px;height:%dpx"><div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>'
              % (track, round(track * scroll / full), round(track * view / full)))
    listcol = '<div class="ib-list"><div class="ib-head"><div class="seg">%s</div></div>%s%s</div>' % (tabs, rows, sb)
    return ('<section class="win" style="left:208px;top:88px;width:1240px;height:900px">%s<div class="ib">%s%s</div></section>'
            % (head, listcol, pane_html))


# ------------------------------------------------------------------ frames
SEED14 = K.SEED     # the shell's seed values (kabuk owns them; INDEX.md says what is not recomputed)
SEED1 = K.V_WEEK1
GATE_SUB = "Frank Köseoğlu"
# A day-boundary card (tick daily, or a request or signal raised inside the daily tick) is proposed at the 00:00
# rollover inside the night batch and opens when the batch reaches 08:00 (TimeManager._drain_boundaries,
# skip_night); the gate then holds the clock there. Every gated frame of such a card reads 08:00.
ARRIVAL = 8


def frank_offer_reply():
    return reply(kit.stake_frank() + '<div style="height:8px"></div>' + opt_locked(T("refuse"), T("refuse_lock")))


def list_A(mm, queue=0, paper_sel=False):
    items = [r_gate(mm["offer"], selected=not paper_sel)]
    if queue:
        items.append(r_queue(queue))
    items += [r_paper(mm["expansion"], 2, selected=paper_sel, blocked=True), r_notice("ege"), r_notice("selin")]
    return items + tail14(mm) + tail1(mm)


def f_frank_offer():
    mm = mails()
    p = pane(mm["offer"], frank_offer_reply(), state=s("st_waiting"), state_cls="is-gate")
    items = list_A(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", GATE_SUB), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_kuyruk():
    mm = mails()
    p = pane(mm["offer"], frank_offer_reply(), state=s("st_waiting"), state_cls="is-gate")
    items = list_A(mm, queue=2)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", T("gate_n", n=3)), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


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
        ("leave", L("Kendi haline bırak", "Let it go"), [fx_flat(L("Müdahale yok · sayaç işlemeye devam eder",
                                                                 "No intervention · the counter keeps running"))], None),
    ]
    for key, label, chips, parts in defs:
        if locked and key == locked[0]:
            o.append(opt_locked(label, locked[1]))
        elif key == armed:
            o.append(kit.opt_armed(label, parts))
        else:
            o.append(kit.opt(label, "".join(chips), "is-focus" if key == focus else ""))
    return "".join(o)


def list_B(mm, active="risk", hist=False, hist_sel=False):
    items = [r_gate(mm[active], selected=not hist_sel), r_paper(mm["expansion"], 2, blocked=True), r_notice("selin")]
    items += tail14(mm)
    if hist:
        h = dict(mm["risk"], week=11)
        items += [r_day(11), r_history(h, T("answered_stamp"), L("Söz ver", "Promise it"), selected=hist_sel)]
    return items + tail1(mm)


def f_musteri_secenek_acik():
    mm = mails()
    p = pane(mm["risk"], reply(retention_opts(armed="discount")), state=s("st_waiting"), state_cls="is-gate")
    items = list_B(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", "Ege Sigorta"), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_kilitli_secenek():
    mm = mails()
    lock = L("Bu hesaba verdiğin son söz tutulmadı.", "Your last promise to them was not kept.")
    p = pane(mm["risk_broken"], reply(retention_opts(armed=None, locked=("promise", lock), focus="stall")),
             state=s("st_waiting"), state_cls="is-gate")
    items = list_B(mm, "risk_broken", hist=True)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", "Ege Sigorta"), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_gecmis_karar():
    mm = mails()
    h = dict(mm["risk"], week=11)
    chosen = answered(L("Söz ver", "Promise it"), fx("cost", L("Müşteri kalır · söz borcu", "The customer stays · a promise owed"))
                      + fx("gain", L("İtibar +1", "Reputation +1")), stamp(T("answered_stamp"), "H11"))
    p = pane(h, reply(chosen, show_perm=False, label=T("your_choice")))
    items = list_B(mm, "risk_broken", hist=True, hist_sel=True)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", "Ege Sigorta"), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


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


def list_C(mm, paper_weeks=2, sel="paper", notices=("ege", "selin")):
    items = []
    if paper_weeks:
        items.append(r_paper(mm["expansion"], paper_weeks, selected=sel == "paper"))
    items += [r_notice(n, selected=sel == n) for n in notices]
    return items + tail14(mm, sel) + tail1(mm)


def f_kagit_onizleme():
    mm = mails()
    p = pane(mm["expansion"], reply(paper_bar(2), show_perm=False), state=s("st_in_weeks", n=2))
    items = list_C(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def f_kagit_acik():
    """The player pressed Cevapla at 11:00: the paper is now the waiting decision (clock held), its options open;
    Esc sets it aside again with its time still running."""
    mm = mails()
    opts = (kit.opt(L("Koltukları ekle", "Add the seats"), fx("gain", L("Koltuk +3 · MRR +$360", "Seats +3 · MRR +$360")), "is-focus")
            + kit.opt(L("Şimdi değil", "Not now"), fx_flat(L("Değişiklik yok", "No change"))))
    aside = ('<div class="reply-foot"><span class="btn btn-ghost btn-sm">%s<kbd>Esc</kbd></span>'
             '<span class="t-meta when">%s%s</span></div>' % (s("set_aside"), ic("clock"), s("st_in_weeks", n=2)))
    p = pane(mm["expansion"], reply(opts + aside), state=s("st_waiting"), state_cls="is-gate")
    items = [r_gate(mm["expansion"]), r_notice("ege"), r_notice("selin")] + tail14(mm) + tail1(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("gate", "Nordica"), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_kagit_son_hafta():
    mm = mails()
    p = pane(mm["expansion"], reply(paper_bar(1), show_perm=False), state=s("st_final"), state_cls="is-warn")
    items = list_C(mm, paper_weeks=1)
    win = olay_window(items, p, kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def f_kagit_karar_beklerken():
    mm = mails()
    p = pane(mm["expansion"], reply(paper_bar(2, gated=True), show_perm=False), state=s("st_in_weeks", n=2))
    items = list_A(mm, paper_sel=True)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", GATE_SUB), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def rec_line(k, v):
    return '<div class="rec-line t-meta"><span class="t-key">%s</span> %s</div>' % (k, v)


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
           '%s%s%s</div></div>'
           % (pill("customer"), s("k_attention"), tag(T("risk_tag"), "risk"),
              num("$1,0K") + '<span class="tb-u">%s</span>' % T("per_mo"),
              L("Koltuk", "Seats"), L("Memnuniyet", "Satisfaction"), L("Müşteri", "Customer"),
              L("2 aydır", "2 mo"),
              rec_line(s("reason"), L("sık kesinti şikayeti", "frequent outage complaints")),
              rec_line(s("am"), s("am_none")),
              acts(btn(L("İlgilen", "Check in")))))
    mm = mails()
    items = list_C(mm, paper_weeks=None, sel="ege", notices=("ege", "selin", "nordica"))
    win = olay_window(items, rec)
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, K.rail("olaylar", badges()), win, items)


def stake_departure(label):
    return ('<div class="stake"><div class="part danger"><span class="part-k">%s</span><span class="part-v txt">%s%s</span></div>'
            '<span class="btn btn-primary btn-lg">%s</span></div>'
            % (s("part_team"), ic("warn"), L("Selin ayrılıyor", "Selin is leaving"), label))


def f_calisan_ayrilik():
    mm = mails()
    p = pane(mm["resign"], reply(stake_departure(L("Anlaşıldı", "Understood"))), state=s("st_waiting"), state_cls="is-gate")
    items = [r_gate(mm["resign"]), r_paper(mm["expansion"], 2, blocked=True), r_notice("ege")] + tail14(mm) + tail1(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", "Selin Kaya"), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_ayrilmis_gonderici():
    mm = mails()
    m = mm["resign"]
    chosen = answered(L("Anlaşıldı", "Understood"), fx("danger", L("Selin ayrılıyor", "Selin is leaving")), stamp(s("st_left"), "H14"))
    p = pane(m, reply(chosen, show_perm=False, label=T("your_choice")), gone=True)
    items = [r_paper(mm["expansion"], 1), r_notice("ege"),
             r_day(14), r_history(m, s("st_left"), L("Anlaşıldı", "Understood"), selected=True, gone=True),
             r_report(mm["rnd"]), r_report(mm["summary"])] + tail1(mm)
    win = olay_window(items, p, kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, K.rail("olaylar", badges(("count", "1"), ekip=False)), win, items)


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
            '<div class="rpt-grid" style="grid-template-columns:180px 1fr 120px;margin-top:8px">%s%s%s%s'
            '<div class="td k">Runway</div><div class="td strong" style="color:var(--pos)">%s</div><div class="td r"></div></div>'
            '<div class="hl"><span class="k t-label">%s</span><span class="v">%s</span></div></div>'
            % (L("Hafta 1-13 · Bootstrap", "Weeks 1-13 · Bootstrap"),
               row("MRR", "$0", num("$4,0K"), num("+$4,0K"), "gain"),
               row(L("Kasa", "Cash"), num("$10,0K"), num("$10,0K"), "±0", "flat"),
               row(s("sum_team"), "1", "6", "+5", "gain"),
               row(L("Marka", "Brand"), "50", "50", "±0", "flat"),
               T("profitable"),
               L("Çeyreğin olayı", "Event of the quarter"),
               L("Sakin bir çeyrek. Sakin çeyrekler ucuz değildir.", "A quiet quarter. Quiet quarters are not cheap.")))
    p = pane(m, acts(btn(L("Devam et", "Continue")), note=L("Otomatik özet · her çeyrek sonu", "Automatic summary · at each quarter end")),
             extra_body=grid)
    items = list_C(mm, sel="summary")
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 8, ("next", T("next_meet"), ""), "II", marks=(14,))
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def f_frank_tanisma():
    mm = mails()
    m = mm["intro"]
    p = pane(m, acts(btn(L("Hadi başlayalım", "Let's get started"))))
    items = tail1(mm, sel=True)
    win = olay_window(items, p)
    top = topbar(SEED1, 1, 9, ("next", L("Mesai bitimi · 8 saat", "Workday ends · 8 h"), ""), "II")
    return screen(top, K.rail("olaylar", {}), win, items, office="home", hud=False)


def f_frank_ani():
    """customer.frank_intro in the shell: one open option, presented armed with its worded parts."""
    mm = mails()
    stake = ('<div class="stake sm"><div class="opt-fx">%s%s</div><span class="btn btn-primary btn-lg">%s</span></div>'
             % (fx("gain", L("Yeni aday", "A new prospect")), fx_flat(L("Seni oraya götürür", "Takes you there")),
                L("Satış'a git", "Go to Sales")))
    p = pane(mm["intro_b2b"], reply(stake), state=s("st_waiting"), state_cls="is-gate")
    items = [r_gate(mm["intro_b2b"]), r_paper(mm["expansion"], 2, blocked=True), r_notice("ege"), r_notice("selin")] + tail14(mm) + tail1(mm)
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", GATE_SUB), marks=(14,))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_arge_notu():
    mm = mails()
    p = pane(mm["rnd"], acts(btn(L("Ürün sayfasına git", "Go to the product page"), "secondary"), btn(L("Ar-Ge'ye git", "Go to R&D"), "secondary")))
    items = list_C(mm, sel="rnd")
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False))
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def f_haftalik_satis():
    mm = mails()
    m = mm["weekly"]

    def star(n):
        return '<span class="star1">%d%s</span>' % (n, ic("star"))

    grid = ('<div class="rpt"><div class="rpt-grid" style="grid-template-columns:1fr 56px 64px 64px 112px">'
            '<span class="th t-label">%s</span><span class="th t-label">%s</span><span class="th t-label r">%s</span>'
            '<span class="th t-label r">%s</span><span class="th t-label r">%s</span>'
            '<div class="td strong">Karadeniz Fabrika</div><div class="td">%s</div><div class="td r">12</div><div class="td r">$85</div>'
            '<div class="td r" style="color:var(--pos)">+%s</div>'
            '<div class="td strong">Efes Emlak</div><div class="td">%s</div><div class="td r">8</div><div class="td r">$75</div>'
            '<div class="td r" style="color:var(--pos)">+%s</div></div>'
            '<div class="rpt-total"><span>%s: <b>%s</b></span><span>%s</span></div></div>'
            % (s("rpt_customer"), s("rpt_stars"), s("rpt_seats"), s("rpt_price"), s("rpt_mrr"),
               star(2), num("$1.020") + T("per_mo"), star(1), num("$600") + T("per_mo"),
               s("rpt_total"), L("2 anlaşma · $1.620/ay", "2 deals · $1,620/mo"),
               s("rpt_books", n="<b>5</b>")))
    p = pane(m, "", extra_body=grid, well=False)
    items = [r_paper(mm["expansion"], 1), r_notice("ege"), r_notice("selin"),
             r_day(15), r_report(m, selected=True), r_day(14), r_report(mm["rnd"]), r_report(mm["summary"])] + tail1(mm)
    win = olay_window(items, p, kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, 11, ("next", T("next_end"), ""), "1x")
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def f_bos_kutu():
    """The Waiting filter, empty. The inbox behind it holds the three reminders and this week's two reports."""
    mm = mails()
    items = [r_notice("ege"), r_notice("selin"), r_notice("nordica"), r_day(14), r_report(mm["rnd"]), r_report(mm["summary"])] + tail1(mm)
    rows = '<div class="empty ib-empty">%s<span class="empty-t">%s</span></div>' % (ic("inbox"), s("list_empty"))
    p = '<div class="pane"><div class="pane-empty">%s<span class="t">%s</span></div></div>' % (ic("mail_open"), s("pane_empty"))
    win = olay_window(items, p, active=1).replace("".join(i["html"] for i in items), rows)
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, K.rail("olaylar", badges()), win, items)


def f_ekip_salt_okunur():
    mm = mails()
    w = kit.ekip_window(208, 88, readonly=True)
    w = w.replace(T("frank_offer"), "Frank Köseoğlu · %s" % L("Teklif", "An offer"))
    w = w.replace('<span class="btn btn-secondary btn-sm">%s%s</span></div></div></div></section>' % (ic("plus"), T("recruit")),
                  '<span class="btn btn-secondary btn-sm is-disabled">%s%s</span></div></div></div></section>' % (ic("plus"), T("recruit")))
    top = topbar(SEED14, 14, ARRIVAL, ("gate", GATE_SUB), marks=(14,))
    return screen(top, K.rail("ekip", badges(GATE)), w, list_A(mm), extra=K.move_btn(208, 972, "held"))


def chance_reply():
    """GDD §9.2 / §9.6 drawn on a resignation: each option carries its own odds; the odds are always shown, in the
    info tone with a dotted rule (hoverable); the hover lists the signed modifiers, no numbers, at most four. The
    hover is drawn on the second option's chip so the list covers no option label."""
    lines = [("chevdown", "down", s("m_offer")), ("chevdown", "down", s("m_morale"))]
    tip = '<span class="tip rich odds-tip">%s</span>' % "".join(
        '<span class="mod %s">%s<span>%s</span></span>' % (k, ic(g, 12), t) for g, k, t in lines)
    armed = ('<div class="opt is-armed"><div class="opt-armed-head"><span class="opt-label">%s</span><span class="btn btn-ghost btn-sm">%s</span></div>'
             '<div class="opt-armed-body">'
             '<div class="part chance"><span class="part-k">%s</span><span class="part-v">%s<span class="odds">%s</span></span></div><span class="part-sep"></span>'
             '<div class="part cost"><span class="part-k">%s</span><span class="part-v">%s%s</span></div><span class="part-sep"></span>'
             '<div class="part danger"><span class="part-k">%s</span><span class="part-v txt">%s%s</span></div>'
             '<span class="btn btn-primary btn-lg">%s</span></div></div>'
             % (s("o_raise"), T("cancel"), s("p_stays"), ic("dice"), L("%58", "58%"), s("p_if"), ic("cost"), s("fx_salary"),
                s("p_ifnot"), ic("warn"), L("Selin ayrılıyor", "Selin is leaving"), T("choose")))
    chip = ('<span class="fx chance has-tip">%s<span class="odds is-hover">%s</span> · %s%s</span>'
            % (ic("dice"), L("%31", "31%"), s("fx_stays", who="Selin"), tip))
    case = kit.opt(s("o_case"), chip + fx("danger", L("Kalmazsa ayrılıyor", "If not, she leaves")))
    ack = kit.opt(L("Anlaşıldı", "Understood"), fx("danger", L("Selin ayrılıyor", "Selin is leaving")))
    return reply(armed + case + ack)


def f_zar(cb=False):
    mm = mails()
    m = dict(mm["resign"], week=15)
    p = pane(m, chance_reply(), state=s("st_waiting"), state_cls="is-gate")
    items = [r_gate(m), r_paper(mm["expansion"], 1, blocked=True), r_notice("ege"),
             r_day(15), r_report(mm["weekly"], unread=True)] + tail14(mm, rnd_read=True) + tail1(mm)
    win = olay_window(items, p, kpi=(T("this_week"), True))
    top = topbar(SEED14, 15, ARRIVAL, ("gate", "Selin Kaya"))
    return screen(top, K.rail("olaylar", badges(GATE)), win, items)


def f_uzun_gecmis():
    """A long inbox from the seed week back to week 1, scrolled: the bar sits in the list's 12 px gutter."""
    mm = mails()
    m = dict(mm["intro_b2b"], week=7)
    chosen = answered(L("Satış'a git", "Go to Sales"), fx("gain", L("Yeni aday", "A new prospect")) + fx_flat(L("Seni oraya götürür", "Takes you there")),
                      stamp(T("answered_stamp"), "H7"))
    p = pane(m, reply(chosen, show_perm=False, label=T("your_choice")))
    items = ([r_paper(mm["expansion"], 2), r_notice("ege"), r_notice("selin")] + tail14(mm, rnd_read=True)
             + [r_day(13), r_history(mm["request"], T("answered_stamp"), L("Listede olduğunu söyle", "Say it's on the list")),
                r_day(11), r_history(mm["complaint"], T("answered_stamp"), L("Durumu açıkça anlat", "Tell them the truth")),
                r_day(7), r_history(m, T("answered_stamp"), L("Satış'a git", "Go to Sales"), selected=True),
                r_day(5), r_history(mm["paid"], T("answered_stamp"), L("Ürüne git", "Go to Product"))]
             + tail1(mm))
    win = olay_window(items, p, kpi=(T("weeks_n", n=2), False), scroll=236)
    top = topbar(SEED14, 14, 11, ("next", T("next_meet"), ""), "1x", marks=(14,))
    return screen(top, K.rail("olaylar", badges(("count", "1"))), win, items)


def gallery():
    """Sender types as mail headers (SENDERS.md); the named contact shows the proposal with a real counterpart bust."""
    to = s("founder_to")
    vc = os.path.join(MEN, "art", "busts", "vc", "bust_anchor_0_vc_lead.png")
    buyer = os.path.join(MEN, "art", "busts", "prospect", "bust_lead_14_2_0_buyer.png")
    outside = L("Alan adı aracısı", "Domain reseller")
    cards = [
        (L("Frank", "Frank"), av_person(FRANK), "Frank Köseoğlu", "Operating Partner", to),
        (L("Çalışan", "Employee"), av_person(BUST["elif"]), "Elif Demir", L("Ürün Yöneticisi", "Product Manager"), to),
        (L("Muhatap · imzadan sonra masadaki alıcı (öneri)", "Contact · after signing, the buyer from the table (proposal)"),
         av_person(buyer), "Elif Yıldız", L("Satın Alma Sorumlusu · Karadeniz Fabrika", "Procurement Lead · Karadeniz Fabrika"), to),
        (L("Muhatap · lead'i olmayan hesap", "Contact · an account with no lead"), av_mono("Ege Sigorta"), "Ege Sigorta",
         L("BT Müdürü", "IT Manager"), to),
        ("VC", av_person(vc), "Kerem Kaya", L("Kıdemli Ortak · Anchor Capital", "Senior Partner · Anchor Capital"), to),
        (L("Basın", "Press"), av_mono("Girişim Bülteni", "outlet girisim"), "Girişim Bülteni", "", to),
        (L("Şirket masası", "Company desk"), av_doc(), L("Destek", "Support"), "Unicorn Inc.", to),
        (L("Kurucunun notu", "The founder's note"), av_person(FOUNDER), L("Kurucu", "Founder"), L("Kendine not", "Note to self"), None),
        (L("Dış gönderen", "Outside sender"), av_mono(outside), outside, "", to),
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
    """Drafts sheet: the press paper no shell frame shows, next to Frank's one-option beat (also olaylar__frank_ani)."""
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
    "olaylar__kagit_acik": ("tr", f_kagit_acik),
    "olaylar__kagit_son_hafta": ("tr", f_kagit_son_hafta),
    "olaylar__kagit_karar_beklerken": ("tr", f_kagit_karar_beklerken),
    "olaylar__bildirimler": ("tr", f_bildirimler),
    "olaylar__gecmis_karar": ("tr", f_gecmis_karar),
    "olaylar__calisan_ayrilik": ("tr", f_calisan_ayrilik),
    "olaylar__ayrilmis_gonderici": ("tr", f_ayrilmis_gonderici),
    "olaylar__zar_secenegi": ("tr", f_zar),
    "olaylar__zar_secenegi_renk_koru": ("tr", lambda: f_zar(cb=True)),
    "olaylar__donem_ozeti": ("tr", f_donem_ozeti),
    "olaylar__frank_tanisma": ("tr", f_frank_tanisma),
    "olaylar__frank_ani": ("tr", f_frank_ani),
    "olaylar__arge_notu": ("tr", f_arge_notu),
    "olaylar__haftalik_satis": ("tr", f_haftalik_satis),
    "olaylar__bos_kutu": ("tr", f_bos_kutu),
    "olaylar__uzun_gecmis": ("tr", f_uzun_gecmis),
    "olaylar__kuyruk": ("tr", f_kuyruk),
    "ekip__salt_okunur_karar_bekliyor": ("tr", f_ekip_salt_okunur),
    "olaylar__taslak_frank_ani_basin": ("tr", f_taslak),
    "olaylar__taslak_frank_ani_basin_en": ("en", f_taslak),
}
CB = {"olaylar__zar_secenegi_renk_koru"}


def build(names):
    global LANG
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        lang, fn = FRAMES[n]
        LANG = lang
        set_lang(lang)
        html = page(n, fn(), cb=n in CB)
        with open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8") as f:
            f.write(html)
        print(os.path.join(BUILD, n + ".html"))
    set_lang("tr")


if __name__ == "__main__":
    build(sys.argv[1:] or list(FRAMES))
