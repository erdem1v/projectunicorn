"""Shared ground for the sheet builders: paths, the font link, token values, the TR/EN text table, the icon
loader (the A2 family in ../icons/ plus the backlog glyphs in glyphs_local.py) and the avatar and portrait
crops (crops.py). Pages call T(key); set_lang("en") switches every builder to English for the width pass.
"""
import glob
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SYS = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "system"))  # read-only: tokens, base, icons
MENAJER = os.path.normpath(os.path.join(SYS, ".."))
sys.path.insert(0, HERE)
import contrast  # noqa: E402
import crops  # noqa: E402
from glyphs_local import GLYPHS as LOCAL_GLYPHS  # noqa: E402

FONTS = ("https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700"
         "&family=IBM+Plex+Sans+Condensed:wght@400&family=IBM+Plex+Sans:wght@400;500;600;700"
         "&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&display=block")
ART = "../art"                 # relative to components.html
PORTRAITS = "../portraits"

# ------------------------------------------------------------------ tokens
CSS_TOKENS = open(os.path.join(SYS, "tokens.css"), encoding="utf-8").read()
ROOT, CB = contrast.parse_blocks(CSS_TOKENS)
STD = contrast.Palette(ROOT, CB, False)
ALT = contrast.Palette(ROOT, CB, True)


def hx(name, pal=STD):
    return contrast.hexs(pal.colour(name))


def cr(fg, bg, pal=STD):
    return "%.1f" % contrast.ratio(*pal.pair(fg, bg))


# ------------------------------------------------------------------ text: TR and EN
# Values come from localization/strings.csv where a key exists (key in the comment); entries in NEW are
# proposals that need a new key (SPEC §13, TR/EN approval). The EN column is used by the width pass.
LANG = "tr"


def set_lang(lang):
    global LANG
    LANG = lang


def num(s):
    """Seed numbers are written in TR form ($10.000, $4,0K, %4); EN swaps the separators and moves the per cent."""
    if LANG == "tr":
        return s
    s = s.translate(str.maketrans({".": ",", ",": "."}))
    return re.sub(r"%(\d+)", r"\g<1>%", s)


def T(key, **kw):
    s = STR[key][0 if LANG == "tr" else 1]
    return s.format(**kw) if kw else s


STR = {
    # top bar (FIN_CAP_*, RUNWAY_*, DATE_LINE, FIN_PHASE_*)
    "cash": ("Kasa", "Cash"), "runway": ("Runway", "Runway"), "mrr": ("MRR", "MRR"), "burn": ("Burn", "Burn"),
    "net": ("Net", "Net"), "brand": ("Marka", "Brand"), "rep": ("İtibar", "Reputation"),
    "shutter_k": ("Kepenk", "Shutter"), "profitable": ("Artıda", "Default Alive"),
    "per_mo": ("/ay", "/mo"), "weeks_n": ("{n} hafta", "{n} weeks"), "months_n": ("{n} ay", "{n} mo"),
    "date": ("Hafta 14 · Nisan 2026", "Week 14 · April 2026"), "date_c": ("H14 · Nis", "W14 · Apr"),
    "phase": ("Bootstrap", "Bootstrap"), "phase_long": ("Series A", "Series A"),
    "gate": ("Cevap bekliyor", "Answer needed"), "gate_n": ("{n} karar bekliyor", "{n} decisions waiting"),
    "next": ("Sıradaki", "Up next"), "next_meet": ("14:00 · Karadeniz Fabrika", "14:00 · Karadeniz Fabrika"),
    "next_offer": ("Teklif · 2 hafta kaldı", "Offer · 2 weeks left"),
    "next_offer_last": ("Teklif · bu hafta son", "Offer · final week"),
    "next_sprint": ("Sprint kararı · 15:00", "Sprint decision · 15:00"),
    "next_end": ("Mesai bitimi · 6 saat", "Workday ends · 6 h"),
    "frank_offer": ("Frank'in teklifi", "Frank's offer"),
    # rail (TAB_*, SYS_SOON)
    "tab_product": ("Ürün", "Product"), "tab_sales": ("Satış", "Sales"), "tab_hr": ("Ekip", "Team"),
    "tab_finance": ("Finans", "Finance"), "tab_personal": ("Kişisel", "Personal"),
    "tab_marketing": ("Pazarlama", "Marketing"), "tab_rnd": ("Ar-Ge", "R&D"), "tab_events": ("Olaylar", "Events"),
    "tab_settings": ("Ayarlar", "Settings"), "soon": ("Yakında", "Soon"),
    # Ekip (HR_*)
    "hr_title": ("Ekip", "Team"), "k_staff": ("Çalışan", "Employees"), "k_morale": ("Ortalama moral", "Average morale"),
    "k_payroll": ("Aylık maaş yükü", "Monthly payroll"), "roles": ("Roller", "Roles"),
    "main": ("ana", "main"), "secondary": ("ikincil", "secondary"),
    "tab_roster": ("Kadro", "Roster"), "tab_assign": ("Görevler", "Assignments"),
    "hours_chip": ("09:00 ile 17:00 arası", "09:00 to 17:00"), "recruit": ("İşe alım başlat", "Start recruitment"),
    "c_employee": ("Çalışan", "Employee"), "c_lead": ("Liderlik", "Leadership"), "c_task": ("Görev", "Task"),
    "c_xp": ("Deneyim", "Experience"), "c_state": ("Durum", "State"), "c_trait": ("Huy", "Trait"),
    "c_salary": ("Maaş", "Salary"), "c_morale": ("Moral", "Morale"),
    "g_pd": ("Ürün & Tasarım", "Product & Design"), "g_dev": ("Geliştirme Ekibi", "Development"),
    "g_sales": ("Satış", "Sales"), "g_cs": ("Müşteri İlişkileri", "Customer Success"),
    "nobody": ("Henüz kimse yok", "Nobody here yet"),
    "r_pm": ("Ürün Yöneticisi", "Product Manager"), "r_design": ("UX/UI Designer", "UX/UI Designer"),
    "r_dev": ("Yazılım Mühendisi", "Software Engineer"), "r_qa": ("Test Mühendisi", "QA Engineer"),
    "r_sales": ("Satış Temsilcisi", "Sales Representative"), "r_cs": ("Müşteri Temsilcisi", "Customer Success Manager"),
    "task_build": ("Yapımda görev alıyor", "Working on the build"), "task_test": ("Test ediyor", "Testing"),
    "task_sales": ("Satışta görev alıyor", "Working sales"), "task_accounts": ("Hesaplarda görev alıyor", "Working the accounts"),
    "st_new": ("Yeni", "New"), "st_risk": ("Ayrılabilir", "At risk of leaving"), "st_leave": ("İzinde", "On leave"),
    "st_leave_left": ("2 hafta", "2 weeks"), "st_training": ("Eğitimde", "In training"),
    "t_loyal": ("Sadık", "Loyal"), "t_fast": ("Çabuk kapar", "Picks It Up Fast"),
    "t_lead": ("Gerçek lider", "Takes Them Under"), "t_double": ("Titiz", "Double Checker"),
    "t_last": ("İşkolik", "Last One Out"), "t_cantsay": ("Hayır diyemez", "Can't Say No"),
    "t_bag": ("Gözü yüksekte", "Bag Packed"), "t_mood": ("Tat kaçıran", "Mood Buster"), "t_unknown": ("Belirsiz", "Unspecified"),
    "risk_morale": ("Moral", "Morale"),
    # Olaylar
    "ev_title": ("Olaylar", "Events"), "f_all": ("Tümü", "All"), "f_wait": ("Bekleyen", "Waiting"),
    "f_unread": ("Okunmamış", "Unread"), "k_soonest": ("En yakın süre", "Soonest deadline"),
    "this_week": ("Bu hafta", "This week"), "queue": ("2 karar daha sırada", "2 more decisions queued"),
    "queue_after": ("bundan sonra açılır", "open after this one"),
    "topic_mentor": ("Mentor", "Mentor"), "topic_customer": ("Müşteri", "Customer"), "topic_team": ("Ekip", "Team"),
    "topic_product": ("Ürün", "Product"), "topic_funding": ("Yatırım", "Funding"), "topic_market": ("Piyasa", "Market"),
    "topic_agenda": ("Gündem", "Agenda"),
    "s_complaint": ("Müşteri şikâyeti", "Customer complaint"), "s_renewal": ("Yenileme sinyali", "Renewal signal"),
    "s_request": ("Müşteri talebi", "Customer request"), "s_expansion": ("Büyüme talebi masada", "Expansion request waiting"),
    "risk_tag": ("Risk altında", "At risk"), "grow_tag": ("Büyümek istiyor", "Wants to grow"), "healthy_tag": ("Sağlıklı", "Healthy"),
    "weeks_2": ("2 hafta", "2 weeks"), "wk_this": ("bu hafta", "this week"),
    "kicker_decision": ("Karar · Hafta 14 · Nisan 2026", "Decision · Week 14 · April 2026"),
    "kicker_answered": ("Cevaplandı · Hafta 12 · Mart 2026", "Answered · Week 12 · March 2026"),
    "kicker_report": ("Rapor · Hafta 13 · Nisan 2026", "Report · Week 13 · April 2026"),
    "permanent": ("Seçim kalıcıdır · Oyun duraklatıldı", "The choice is permanent · Game paused"),
    "k_cash": ("Nakit", "Cash"), "k_to_frank": ("Frank'e", "To Frank"), "v_equity": ("%4 hisse", "4% equity"),
    "accept": ("Kabul et", "Accept"), "refuse": ("Reddet", "Refuse"), "refuse_lock": ("Zor modda açılır.", "Unlocks in hard mode."),
    "o_date": ("Tarih ver", "Give them a date"), "o_list": ("Listede olduğunu söyle", "Say it's on the list"),
    "o_notnow": ("Şimdilik olmaz de", "Say not now"), "o_fix": ("Düzeltme sözü ver", "Promise a fix"),
    "o_lower": ("Daha düşük fiyatla yenile", "Renew at a lower rate"),
    "lock_promise": ("Bu hesaba verilmiş, henüz tutulmamış bir söz var.", "You already owe this account a word."),
    "choose": ("Seç", "Choose"), "cancel": ("Vazgeç", "Cancel"),
    "fx_sat": ("Memnuniyet", "Satisfaction"), "fx_keeps": ("Müşteri kalır", "Account stays"), "fx_debt": ("söz borcu", "a promise owed"),
    "answered_stamp": ("Cevaplandı", "Answered"), "your_choice": ("Seçimin", "Your choice"),
    "ro_strip": ("Karar bekliyor. Bu pencere yalnız okunur.", "A decision is waiting. This window is read only."),
    "back_to_decision": ("Karara dön", "Back to the decision"),
    "reply": ("Cevapla", "Respond"), "in_weeks": ("2 hafta içinde", "Within 2 weeks"), "last_week": ("Bu hafta son", "Final week"),
    "blocked_reason": ("Önce bekleyen kararı cevapla.", "Answer the waiting decision first."),
    # toasts and floats
    "saved": ("Kaydedildi", "Saved"), "saved_sub": ("Hafta 14 · 11:00", "Week 14 · 11:00"),
    "locked_clock": ("Saat kilitli", "Clock held"), "locked_clock_sub": ("Önce Frank'in teklifini cevapla.", "Answer Frank's offer first."),
    "not_saved": ("Kaydedilmedi", "Not saved"), "not_saved_sub": ("Bir karar ekranı açıkken kaydedilemez.", "Saving is unavailable while a decision screen is open."),
    "move_office": ("Ofisi taşı", "Move the office"), "support": ("Destek", "Support"), "confirmed_0": ("Doğrulanmış 0", "Confirmed 0"),
    "start_fix": ("Düzeltme başlat", "Start a fix"),
}
NEW = {"gate", "gate_n", "next", "next_offer", "next_offer_last", "next_sprint", "next_end", "roles", "main", "secondary",
       "hours_chip", "st_leave", "st_leave_left", "f_all", "f_wait", "f_unread", "k_soonest", "queue", "queue_after",
       "kicker_answered", "kicker_report", "k_to_frank", "v_equity", "choose", "answered_stamp", "your_choice",
       "ro_strip", "back_to_decision", "reply", "in_weeks", "last_week", "blocked_reason", "locked_clock",
       "locked_clock_sub", "shutter_k", "k_morale", "k_payroll"}


# ------------------------------------------------------------------ icons
# Draft names used by the sheet -> the A2 file (../icons/<group>/<name>.svg) or a backlog glyph ("local:").
ICON_FILES = {
    "urun": "rail/product", "satis": "rail/sales", "ekip": "rail/hr", "finans": "rail/finance", "kisisel": "rail/personal",
    "pazarlama": "rail/marketing", "arge": "rail/rnd", "olaylar": "rail/events", "ayarlar": "rail/settings",
    "sk_product": "skill/product", "sk_design": "skill/design", "sk_eng": "skill/engineering", "sk_qa": "skill/qa",
    "sk_sales": "skill/sales", "sk_cs": "skill/customer_success",
    "d_pd": "dept/product_design", "d_dev": "dept/development", "d_sales": "dept/sales", "d_cs": "dept/customer_success",
    "tr_loyal": "trait/loyal", "tr_fast": "trait/picks_it_up_fast", "tr_lead": "trait/takes_them_under",
    "tr_double": "trait/double_checker", "tr_last": "trait/last_one_out", "tr_cantsay": "trait/cant_say_no",
    "tr_bag": "trait/bag_packed", "tr_mood": "trait/mood_buster", "tr_unknown": "trait/unspecified",
    "warn": "util/warn", "clock": "util/clock", "plus": "util/plus", "minus": "util/minus", "close": "util/close",
    "chev": "util/chevron_right", "chevleft": "util/chevron_left", "chevdown": "util/chevron_down", "chevup": "util/chevron_up",
    "sort_down": "util/chevron_down", "sort_up": "util/chevron_up",
    "lock": "util/lock", "pause": "util/pause", "play": "util/play", "news": "util/news", "shield": "util/shield",
    "move": "util/move", "check": "util/check", "reply": "util/reply", "dice": "util/dice", "search": "util/search",
    "filter": "util/filter", "inbox": "util/inbox", "mail_open": "util/mail_open", "calendar": "util/calendar",
    "star": "util/star_full", "star_half": "util/star_half", "star_empty": "util/star_empty", "flat": "util/flat",
    "revert": "util/revert", "arrow": "util/arrow_right", "doc": "util/doc", "queue": "util/queue", "enter": "util/enter",
    "save": "util/save", "load": "util/load", "globe": "util/language", "menu": "util/menu", "info": "util/info",
    "history": "util/history", "keyboard": "util/keyboard",
    "up": "stake/cash_in", "cost": "stake/cost", "pie": "stake/equity",
    "k_feature": "product/kind_feature", "k_fix": "product/kind_fix", "k_polish": "product/kind_polish",
    "k_research": "product/kind_research", "voices": "product/voices", "bug": "product/bug",
    "departed": "world/person_left", "training": "world/training", "raise": "world/raise", "seat": "world/seat",
    "crown": "world/crown", "milestone": "world/milestone", "termsheet": "world/term_sheet", "hourglass": "world/runway",
    "fund": "world/fund", "shutter": "world/shutter", "map": "world/map",
    "home": "place/home", "building": "place/ishani", "tower": "place/plaza", "loft": "place/loft",
    "origin_self": "origin/self_made", "origin_heir": "origin/heir", "origin_corp": "origin/corporate",
}
_svg_cache = {}


def _svg(name):
    if name in _svg_cache:
        return _svg_cache[name]
    rel = ICON_FILES.get(name)
    path = os.path.join(SYS, "icons", rel + ".svg") if rel else None
    if path and os.path.exists(path):  # A2 first; the backlog glyph only while A2 has no file
        s = open(path, encoding="utf-8").read()
        s = re.sub(r"<\?xml[^>]*>", "", s)
        s = re.sub(r'\s(width|height)="[^"]*"', "", s, count=2)
        s = s.replace("#FFFFFF", "currentColor").replace("#ffffff", "currentColor").replace("#FFF\"", "currentColor\"")
        s = s.replace("<svg ", '<svg data-src="a2:%s" ' % rel, 1)
    elif name in LOCAL_GLYPHS:
        s = '<svg data-src="local:%s" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">%s</svg>' % (name, LOCAL_GLYPHS[name])
    else:
        raise KeyError("no glyph for %r (A2 file %r missing)" % (name, rel))
    _svg_cache[name] = s.strip()
    return _svg_cache[name]


def ic(name, size=None, color=None, cls=""):
    style = []
    if size:
        style.append("width:%dpx;height:%dpx" % (size, size))
    if color:
        style.append("color:%s" % color)
    st = (' style="%s"' % ";".join(style)) if style else ""
    return '<span class="ic %s"%s>%s</span>' % (cls, st, _svg(name))


def raw_svg(name):
    return _svg(name)


def icon_sources():
    """Which glyphs the sheet drew from A2 and which from the backlog (reported in SPEC §11.3)."""
    a2 = sorted(n for n in _svg_cache if 'data-src="a2:' in _svg_cache[n])
    local = sorted(n for n in _svg_cache if 'data-src="local:' in _svg_cache[n])
    return a2, local


# ------------------------------------------------------------------ avatars and portraits
BUSTS = {k: ("art", "bust_%s.png" % k) for k in ("elif", "deniz", "mert", "selin", "burak", "kurucu")}


def frank_candidates():
    return sorted(p for p in glob.glob(os.path.join(MENAJER, "portraits", "frank_cand_*.png")) if re.search(r"frank_cand_[a-z]\.png$", p))


def founders():
    return sorted(p for p in glob.glob(os.path.join(MENAJER, "portraits", "founder_*.png")) if re.search(r"founder_\d\d\.png$", p))


def frank_path():
    """The placeholder Frank the sheets use until Erdem picks: candidate D when it exists (best ink contrast in
    the well, review finding 2), else the last candidate."""
    c = frank_candidates()
    d = [p for p in c if p.endswith("_d.png")]
    return (d or c)[-1]


def _src(path):
    return "../" + os.path.relpath(path, MENAJER).replace("\\", "/")


def menajer(rel):
    """Absolute path of a file under docs/mockups/menajer/ (art, portraits)."""
    return os.path.join(MENAJER, *rel.split("/"))


def _abs(key):
    if key == "frank":
        return frank_path()
    if os.path.isabs(key):
        return key
    return os.path.join(MENAJER, "art", "bust_%s.png" % key)


def avatar(key, size, extra_cls=""):
    """Disc avatar on the lit ground, cut by the crop rule (crops.py)."""
    p = _abs(key)
    x, y, d = crops.disc_box(p, size)
    img = crops.css_img(p, _src(p), size, size, (x, y, d, d))
    return '<span class="av av-%d %s">%s</span>' % (size, extra_cls, img)


def portrait(key, w=256, h=320, extra_cls=""):
    p = _abs(key)
    img = crops.css_img(p, _src(p), w, h, crops.card_box(p, w, h))
    return '<div class="portrait %s" style="width:%dpx;height:%dpx">%s</div>' % (extra_cls, w, h, img)
