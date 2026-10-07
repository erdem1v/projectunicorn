"""Ekip (team) as Menajer Masası: builds every frame of group "ekip" (Faz A4) into ../build/<name>.html.

  python gen.py            build all frames (and ../build/strings.md, the new-string table for INDEX.md)
  python gen.py <name> ... build the named frames only

Render with tools/render_all.sh (calls the menajer render.sh per frame). The system kit (tokens.css, base.css,
icons, crop rule, top bar geometry) is read from ../../../system through the copies in syskit/, whose caches
live in this folder, so nothing is ever written into the system folder. Player text comes from
localization/strings.csv (read only) in the frame's language; the strings this group adds or recases are in S.

Seeds, named per frame in INDEX.md:
  THEME  main.gd _seed_theme_surface (week 14, 11:00, the approved Ekip page and data/crowd40.json)
  HR     main.gd _run_hr_shot (week 10/11, 08:00, cash 240000 then one finance tick: the baseline hr__* frames)
"""
import csv
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
REL = "../../../"  # build/ -> menajer/
CSV_PATH = os.path.normpath(os.path.join(MEN, "..", "..", "..", "localization", "strings.csv"))


def _src(path):
    return REL + os.path.relpath(path, MEN).replace("\\", "/")


common._src = _src  # avatar() and portrait() resolve image paths through this

W, H = 1920, 1080


def L(tr, en):
    return tr if common.LANG == "tr" else en


# ------------------------------------------------------------------ CSV (read only): C(key) in the frame's language
CSVP = {r[0]: (r[1], r[2]) for r in csv.reader(open(CSV_PATH, encoding="utf-8")) if len(r) >= 3}


def C(key, **kw):
    v = CSVP[key][0 if common.LANG == "tr" else 1]
    return v.format(**kw) if kw else v


# ------------------------------------------------------------------ new player-visible strings (EN first; INDEX.md)
# kind: new = a new key; recase = an existing key's value changes case or loses a symbol; split = a joined key is cut;
# change = TR and EN text change; csv = today's value as is; kabuk = the kabuk group's string, reused verbatim
S = {
    "brand": ("Project Unicorn", "Project Unicorn", "new", "top bar brand block, decision 14 (a), as group olaylar"),
    "hours_win": ("{start} to {end}", "{start} ile {end} arası", "new", "hours chip, SPEC §13 (HR_HOURS_WINDOW carries an en dash)"),
    "hours_over": ("{n} on overtime", "{n} çalışan mesaide", "split", "chip tail; HR_HOURS_CHIP_OVERTIME cut after {window}"),
    "recruit": ("Start recruitment", "İşe alım başlat", "recase", "HR_SEARCH_START / _INLINE, plus becomes an icon (SPEC §13)"),
    "idle_n": ("{n} idle", "{n} boşta", "recase", "HR_CHIP_IDLE_COUNT as a tag (caps by Fmt.upper)"),
    "over_n": ("{n} overloaded", "{n} aşırı yük", "recase", "HR_CHIP_OVERLOAD_COUNT as a tag"),
    "overload": ("Overloaded", "Aşırı yük", "recase", "HR_BADGE_OVERLOADED_JOBS tag (caps by Fmt.upper)"),
    "idle_tag": ("Idle", "Boşta", "recase", "HR_BADGE_IDLE as the idle row's Durum tag (caps by Fmt.upper)"),
    "training_tag": ("In training", "Eğitimde", "split", "Durum tag; HR_STATE_TRAINING split into tag + {n} weeks like the leave tag"),
    "agency": ("Atlas Recruitment", "Atlas Recruitment", "recase", "HR_AGENCY_NAME is a proper noun: no caps"),
    "atlas_sender": ("Atlas", "Atlas", "recase", "DESK_PAPER_TAG_ATLAS as the notice stack's sender: the full agency name "
                     "ellipsises EN '3 candidate files ready' in the 352 card under the 8 % pass"),
    "files_desk": ("{n} candidate files on your desk.", "{n} aday dosyası masada.", "csv", "HR_FILES_ON_DESK"),
    "open_files": ("Open the files", "Dosyaları aç", "recase", "HR_OPEN_FILES button, sentence case"),
    "open_file": ("Open file", "Dosyayı aç", "new", "row menu first item (system page 03 shows it)"),
    "legend_locked": ("locked", "kilitli", "new", "Görevler legend: dashed box with a lock; lower case like the head legend's 'ana / ikincil'"),
    "legend_noarea": ("no area", "alanı yok", "split", "HR_LEGEND_NO_AREA cut at the dot, lower case like the head legend; 'atanamaz' is the dashed box"),
    "legend_main": ("main", "ana", "csv", "SPEC §13 'ana' (the head legend's word), reused in the Görevler legend"),
    "legend_sec": ("secondary", "ikincil", "csv", "SPEC §13 'ikincil'"),
    "atlas_step_role": ("Step 1 · Role", "Adım 1 · Rol", "csv", "HR_ATLAS_STEP_ROLE"),
    "start_search": ("Start search", "Arayış başlat", "recase", "HR_ATLAS_START, sentence case"),
    "cancel": ("Cancel", "Vazgeç", "recase", "HR_ATLAS_CANCEL / UI_DISMISS as a button, sentence case"),
    "take_none": ("Take none", "Hiçbirini alma", "csv", "HR_ATLAS_TAKE_NONE, no caps"),
    "hire": ("Hire · {amount}/mo", "İşe al · {amount}/ay", "recase", "HR_ATLAS_HIRE, sentence case; one amber button for the selected file"),
    "file_n": ("File {i}/{n}", "Dosya {i}/{n}", "recase", "HR_ATLAS_FILE_N as a caps kicker via Fmt.upper"),
    "commission_once": ("one-off", "tek seferlik", "new", "after the commission figure in a file"),
    "arrival": ("Candidates arrive within {span}", "Adaylar {span} içinde gelir", "recase", "HR_ATLAS_ARRIVAL, capital first letter"),
    "free_note": ("The search is free · commission is paid on the hire", "Arama ücretsiz · komisyon işe alımda ödenir", "recase",
                  "HR_ATLAS_FREE_NOTE, capital first letter"),
    "raise_apply": ("Apply raise · +{pct}", "Zammı uygula · +{pct}", "recase", "HR_APPLY_RAISE_PCT, sentence case"),
    "fire_neg": ("Cash goes below zero. The {n}-week shutter countdown starts.",
                 "Kasa eksiye düşer. {n} haftalık kepenk sayacı başlar.", "new", "fire dialog when cash_after < 0 (bedel görünür)"),
    "train_cta": ("Send to training · {fee}", "Eğitime gönder · {fee}", "recase", "HR_TRAINING_CTA, sentence case"),
    "train_sum": ("{area} · {duration}", "{area} · {duration}", "csv", "footer summary, today's code literal"),
    "hours_band": ("Office day", "Ofis günü", "new", "Mesai panel: caption of the day band"),
    "role_col": ("Role", "Rol", "new", "compact roster column head (sıkı kip)"),
    "build_team": ("Build team", "Yapım ekibi", "recase", "HR_JOB_BUILD TR 'Build ekibi' is English in TR text; the task line already says 'Yapımda'"),
    "searching": ("Searching for {role} · files arrive next week", "{role} aranıyor · dosyalar gelecek hafta gelir", "csv", "HR_SEARCHING_ONE"),
    "search_cancel": ("Cancel search", "Arayışı iptal et", "recase", "HR_SEARCH_CANCEL, sentence case"),
    "founder_build": ("Working on the build", "Yapımda görev alıyor", "change",
                      "HR_FOUNDER_STATE_BUILD takes the employees' sentence (HR_TASK_ON_JOB_BUILD); today TR 'Bir yapımda çalışıyor', EN 'Working on a build'"),
    "apply": ("Apply", "Uygula", "csv", "HR_HOURS_APPLY"),
    "equalise": ("Match everyone to the company", "Tümünü şirkete eşitle", "csv", "HR_HOURS_EQUALISE"),
    # the kabuk group's strings, drawn verbatim (kabuk/INDEX.md lists them)
    "confirmed": ("Confirmed {n}", "Doğrulanmış {n}", "kabuk", "BuildHUD support row"),
    "no_bugs": ("No confirmed bugs.", "Doğrulanmış hata yok.", "kabuk", "BuildHUD: Start a fix run's reason (fix_run_refusal = no_confirmed_bugs)"),
    "m_more_team": ("One more team", "Bir ekip daha", "kabuk", "notice stack: Nordica's expansion paper"),
    "m_at_risk": ("At risk", "Risk altında", "kabuk", "notice stack: SALES_CHIP_RISK reminder"),
}
USED = set()


def s(key, **kw):
    USED.add(key)
    v = S[key][1 if common.LANG == "tr" else 0]
    return v.format(**kw) if kw else v


def strings_table():
    rows = ["| Key (proposal) | EN | TR | Kind | Where |", "|---|---|---|---|---|"]
    for k in sorted(USED):
        en, tr, kind, where = S[k]
        if kind in ("csv", "kabuk"):
            continue
        rows.append("| `%s` | %s | %s | %s | %s |" % (k, en, tr, kind, where))
    return "\n".join(rows) + "\n"


# ------------------------------------------------------------------ dates (GameState.get_date_dict: day 1 = 1 Jan 2026, a tick = 7 days)
def _day(week):
    return datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))


def date(week):
    d = _day(week)
    w = (d - datetime.date(d.year, 1, 1)).days // 7 + 1
    return C("DATE_LINE", week=w, mon=C("MONTH_%d" % d.month), year=d.year)


def date_c(week):
    return "H%d · %s" % (week, C("MONTH_%d" % _day(week).month)[:3])


# ------------------------------------------------------------------ seeds (top bar values), built in the frame's language
def money(n):
    neg = n < 0
    s_ = "{:,}".format(abs(n)).replace(",", ".")
    return num(("−$" if neg else "$") + s_)


def months(n):
    return "%d %s" % (n, C("RUNWAY_UNIT_MONTHS"))


def end_in(h):
    return L("Mesai bitimi · %d saat" % h, "Workday ends · %d h" % h)


def THEME():
    return dict(week=14, hour=11, cash=num("$10.000"), cash_cls="tb-hero", net=num("+$2,5K"), net_cls="tb-d", run_k=T("runway"),
                run_v=T("profitable"), run_cls="tb-v pos", mrr=num("$4,0K"), brand="50", burn=num("$1,5K"), rep="0",
                nx=T("next_meet"), nx_cls="", marks=(14,), start=8, mesai=9, end=17)


def HRS(week=11):
    return dict(week=week, hour=8, cash=num("$229.304"), cash_cls="tb-hero", net=num("−$46K"), net_cls="tb-v", run_k=T("runway"),
                run_v=months(5), run_cls="tb-v", mrr="$0", brand="50", burn=num("$46K"), rep="0",
                nx=end_in(9), nx_cls="", marks=(), start=8, mesai=9, end=17)


def EMPTY(week=11):  # bos: no roster, no set_cash
    return dict(HRS(week), cash=num("$10.000"), net=num("−$1,5K"), run_v=months(7), burn=num("$1,5K"))


# ------------------------------------------------------------------ the inbox's waiting mail = the notice stack (kabuk's grammar)
# (dot class, sender, subject, time left). Papers carry their time, reminders none; a reminder's dot is its tone.
def MAIL_THEME():
    return [("", "Nordica", s("m_more_team"), C("DESK_PAPER_WEEKS", n=2)), ("is-risk", "Ege Sigorta", s("m_at_risk"), ""),
            ("is-risk", "Selin Kaya", T("st_risk"), "")]


def MAIL_HR(week=11, staff=True):
    """HR seed: Atlas's files reminder once a search has delivered (week 11), Selin's flight-risk reminder with a roster."""
    out = []
    if week >= 11:
        out.append(("is-info", s("atlas_sender"), C("DESK_PAPER_ATLAS_TITLE", n=3), ""))
    if staff:
        out.append(("is-risk", "Selin Kaya", T("st_risk"), ""))
    return out


def stack(mail):
    cards = "".join('<div class="float notice"><span class="dt %s"></span><span class="co">%s</span><span class="tx">%s</span>%s</div>'
                    % (dot, co, tx, ('<span class="nwk">%s</span>' % wk) if wk else "") for dot, co, tx, wk in mail)
    return '<div class="nstack">%s</div>' % cards


def buildhud(x, y):
    """kabuk buildhud(state="seed"): Doğrulanmış 0, Start a fix run off with its reason beside it."""
    return ('<div class="float bh abs" style="left:%dpx;top:%dpx"><div class="bh-hd">%s<span class="t">Unicorn Inc. v1</span></div>'
            '<div class="bh-rw bh-phase">%s<span class="k t-label">%s</span><span class="v">%s</span></div>'
            '<div class="bh-act"><span class="btn btn-ghost btn-sm is-disabled">%s%s</span><span class="why">%s</span></div></div>'
            % (x, y, ic("urun", 20, "var(--ink-3)"), ic("shield", 16, "var(--ink-3)"), T("support"), s("confirmed", n=0),
               ic("play", 12), C("PROD_FIX_RUN_START"), s("no_bugs")))


# ------------------------------------------------------------------ top bar
def topbar(v, compact=False, Wd=W):
    col, g, time_w = kit.tb_layout(compact)
    out = []
    if compact:
        out.append('<span class="brand-sq" style="left:22px;top:22px"></span>')
    else:
        out += ['<span class="brand-sq" style="left:20px;top:14px"></span>',
                at(48, 31, "t-subhead", s("brand"), "tb-co", width=g["brand"] - 48 - 12),
                at(48, 50, "t-micro", T("phase"), "tb-k")]
        for i in range(3):
            out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i == 0 else "", 48 + kit.TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    b1, b2 = 33, 54
    out += [at(col["A"], b1, "t-label", T("cash"), "tb-k"), at(col["B"], b1, "t-hero", v["cash"], v["cash_cls"]),
            at(col["A"], b2, "t-micro", T("net"), "tb-k"),
            at(col["B"], b2, "t-data-med", v["net"] + '<span class="tb-u">%s</span>' % T("per_mo"), v["net_cls"]),
            at(col["C"], b1, "t-label", v["run_k"], "tb-k"), at(col["D"], b1, "t-value", v["run_v"], v["run_cls"]),
            '<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"],
            at(col["E"], b1, "t-label", T("mrr"), "tb-k"), at(col["F"], b1, "t-value", v["mrr"], "tb-v"),
            at(col["E"], b2, "t-micro", T("brand"), "tb-k"), at(col["F"], b2, "t-data", v["brand"], "tb-v"),
            at(col["G"], b1, "t-label", T("burn"), "tb-k"),
            at(col["H"], b1, "t-value", v["burn"] + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"),
            at(col["G"], b2, "t-micro", T("rep"), "tb-k"), at(col["H"], b2, "t-data", v["rep"], "tb-v")]
    gate_x = Wd - time_w - g["gate"]
    d0 = col["metrics_end"]
    pad = 16 if compact else 20
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % d0)
    out.append(at(d0 + pad, 28, "t-body", date_c(v["week"]) if compact else date(v["week"]), "tb-date"))
    out.append(kit.week_bar(d0 + pad, min(gate_x - pad, d0 + pad + 720), now_h=v["hour"], marks=v["marks"],
                            start=v["start"], mesai=v["mesai"], end=v["end"]))
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gate_x, g["gate"]))
    tx = gate_x + g["gate_pad"]
    out.append(at(tx, 29, "t-micro", T("next"), "nx-l"))
    out.append(at(tx, 50, "t-key", v["nx"], "nx-s " + v["nx_cls"], width=g["gate"] - 2 * g["gate_pad"]))
    tx0 = Wd - time_w
    out.append('<div class="tb-time" style="left:%dpx;width:%dpx"></div>' % (tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "%02d:00" % v["hour"], "tb-clock"))
    kx = tx0 + g["time_pad"][0] + kit.TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if k == "II" else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    return '<header class="topbar%s" style="width:%dpx;right:auto">%s</header>' % (" is-compact" if compact else "", Wd, "".join(out))


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product"), ("satis", "tab_sales"), ("ekip", "tab_hr"), ("finans", "tab_finance"),
        ("kisisel", "tab_personal"), ("pazarlama", "tab_marketing"), ("arge", "tab_rnd"), ("olaylar", "tab_events")]
B_THEME = {"satis": ("danger", "1"), "ekip": ("danger", "1"), "arge": ("count", "2")}


def rail(active, badges, icons=False):
    rows = []
    for key, name in RAIL:
        b = "lock" if key == "pazarlama" else badges.get(key)
        cls = "rr" + (" is-active" if key == active else "") + (" is-locked" if b == "lock" else "")
        right = ""
        if b == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), T("soon"))
            if icons:
                right = '<span class="lk">%s</span>' % ic("lock", 12)
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if b:
                right = '<span class="badge badge-%s">%s</span>' % (b[0], b[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    return ('<nav class="rail%s" style="bottom:%dpx">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", 40, "".join(rows), ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ page and screen
def page(body, title="Ekip", Wd=W, Hh=H, cb=False):
    """lang sets the caps rule for the page: tr gives the dotted İ, en the plain I. cb swaps the palette (tokens.css body.cb)."""
    return ('<!doctype html><html lang="%s" style="--page-w:%dpx;--page-h:%dpx"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../ekip.css"></head><body%s>%s</body></html>'
            % (common.LANG, Wd, Hh, title, common.FONTS, REL, REL, ' class="cb"' if cb else "", body))


def office(dim=True, compact=False, plate="office_safe_1920.png"):
    if compact:  # 1536 x 864 logical: icon rail 64, the 1536 plate covers 64..1536 x 64..824
        return ('<div class="office%s" style="inset:auto;left:64px;top:64px;width:1472px;height:760px;'
                'background-image:url(%sart/office_safe_1536.png);background-size:cover;background-position:center"></div>'
                % (" is-dimmed" if dim else "", REL))
    return '<div class="office%s" style="background-image:url(%sart/%s)"></div>' % (" is-dimmed" if dim else "", REL, plate)


def screen(top, rail_html, layers, dim=True, hud=False, move=False, compact=False, Hh=H, plate="office_safe_1920.png", mail=None):
    """Floats (BuildHUD, notice stack, move button) sit under the windows; a frame passes mail=None where an open window's
    rect overlaps the stack (SPEC §9: it hides then), and an empty list when nothing waits."""
    out = [office(dim, compact, plate)]
    if hud:
        out.append(buildhud(1576, 88))
    if mail:
        out.append(stack(mail))
    if move:
        out.append('<div class="float fbtn" style="position:absolute;left:208px;top:%dpx">%s%s</div>' % (Hh - 108, ic("move"), T("move_office")))
    out.append(layers)
    out.append(top)
    out.append(rail_html)
    out.append(kit.ticker())
    return '<div class="screen">%s</div>' % "".join(out)


# ------------------------------------------------------------------ people
CROWD = json.load(open(os.path.join(MEN, "data", "crowd40.json"), encoding="utf-8"))["people"]
ROLE_KEY = {"product_manager": "HR_ROLE_PRODUCT_MANAGER", "designer": "HR_ROLE_DESIGNER", "developer": "HR_ROLE_DEVELOPER",
            "tester": "HR_ROLE_TESTER", "sales_rep": "HR_ROLE_SALES_REP", "customer_rep": "HR_ROLE_CUSTOMER_REP", "founder": "HR_ROLE_FOUNDER"}
ROLE_AREAS = {"product_manager": (0, 1), "designer": (1, 0), "developer": (2, 3), "tester": (3, 2), "sales_rep": (4, None),
              "customer_rep": (5, None)}
GROUP_OF = {"product_manager": "g_pd", "designer": "g_pd", "developer": "g_dev", "tester": "g_dev", "sales_rep": "g_sales",
            "customer_rep": "g_cs"}
GROUPS = [("g_pd", "d_pd", [0, 1]), ("g_dev", "d_dev", [2, 3]), ("g_sales", "d_sales", [4]), ("g_cs", "d_cs", [5])]
TASK_KEY = {"build": "HR_TASK_ON_JOB_BUILD", "test": "HR_TASK_ON_JOB_TEST", "support": "HR_TASK_ON_JOB_SUPPORT",
            "accounts": "HR_TASK_ON_JOB_ACCOUNTS", "sales": "HR_TASK_ON_JOB_SALES"}
JOB_KEY = {"test": "HR_JOB_TEST", "support": "HR_JOB_SUPPORT", "accounts": "HR_JOB_ACCOUNTS", "sales": "HR_JOB_SALES",
           "research": "HR_JOB_RESEARCH"}
AREA_KEY = ["HR_AREA_PRODUCT", "HR_AREA_DESIGN", "HR_AREA_ENGINEERING", "HR_AREA_QA", "HR_AREA_SALES", "HR_AREA_CUSTOMER_SUCCESS",
            "HR_AREA_LEADERSHIP"]
TRAIT = {  # id: (icon, label in common.STR (sentence case TR, SPEC §13 recase), effect key)
    "takes_them_under": ("tr_lead", "t_lead", "HR_TRAIT_TAKES_THEM_UNDER_EFFECT"),
    "last_one_out": ("tr_last", "t_last", "HR_TRAIT_LAST_ONE_OUT_EFFECT"),
    "loyal": ("tr_loyal", "t_loyal", "HR_TRAIT_LOYAL_EFFECT"),
    "double_checker": ("tr_double", "t_double", "HR_TRAIT_DOUBLE_CHECKER_EFFECT"),
    "picks_it_up_fast": ("tr_fast", "t_fast", "HR_TRAIT_PICKS_IT_UP_FAST_EFFECT"),
    "bag_packed": ("tr_bag", "t_bag", "HR_TRAIT_BAG_PACKED_EFFECT"),
}
# seed_staff leaves the crowd's salary at 0: the frames show the floor of the role's Orta band instead
# (HRConstants.SALARY_BANDS_BY_LEVEL[role][1][0]), stated in INDEX.md
FLOOR_ORTA = {"developer": 3000, "product_manager": 2700, "tester": 2700, "designer": 2250, "sales_rep": 2250, "customer_rep": 2250}
FIVE = {"char_emp_shot_0": "elif", "char_emp_shot_1": "deniz", "char_emp_shot_2": "mert", "char_emp_shot_3": "selin", "char_emp_shot_4": "burak"}


def area(i):
    return C(AREA_KEY[i])


def job(j):
    return s("build_team") if j == "build" else C(JOB_KEY[j])


def job_title(role, level=1):
    """HRConstants.job_title: level prefix + role name; Orta has no prefix."""
    pre = {0: "HR_LEVEL_PREFIX_JUNIOR", 1: "", 2: "HR_LEVEL_PREFIX_SENIOR"}[level]
    return C(ROLE_KEY[role]) if not pre else "%s %s" % (C(pre), C(ROLE_KEY[role]))


def person(e, day=14, leave_left=2):
    rs = e["role_stats"]
    sk = [rs[k] for k in ("product", "design", "engineering", "qa", "sales", "customer_success", "leadership")]
    main, sec = ROLE_AREAS[e["role"]]
    sal = e["monthly_salary"] or FLOOR_ORTA[e["role"]]
    bust = (os.path.join(MEN, "art", "bust_%s.png" % FIVE[e["id"]]) if e["id"] in FIVE
            else os.path.join(MEN, *e["bust64"].split("/")))
    st = []
    if e["morale"] < 35:
        st.append(("risk",))
    if e["hire_day"] + 2 > day and e["hire_day"] <= day:
        st.append(("new",))
    if e["status"] == "on_leave":
        st.append(("leave", leave_left))
    return dict(id=e["id"], name=e["character_name"], role=e["role"], title=job_title(e["role"]), sk=sk, main=main, sec=sec,
                jobs=list(e["assigned_job_ids"]), task=C(TASK_KEY[e["assigned_job_ids"][0]]), xp=0, st=st, huy=e["traits"][0],
                sal=sal, sal_derived=not e["monthly_salary"], moral=e["morale"], bust=bust, hire=e["hire_day"],
                group=GROUP_OF[e["role"]], away=e["status"] == "on_leave")


def roster(n=5, day=14, leave_left=2, hire_shift=None):
    """The seed roster in CharacterRegistry order. hire_shift maps id -> hire day (the HR seed hires differ)."""
    out = []
    for e in CROWD[1:1 + n]:
        e = dict(e)
        if hire_shift and e["id"] in hire_shift:
            e["hire_day"] = hire_shift[e["id"]]
        out.append(person(e, day, leave_left))
    return out


def by_id(people, pid):
    return next(p for p in people if p["id"] == pid)


def sorted_group(people, gid):
    sev = lambda p: 3 if any(x[0] == "risk" for x in p["st"]) else (1 if any(x[0] == "over" for x in p["st"]) else 0)
    g = [p for p in people if p["group"] == gid]
    return sorted(g, key=lambda p: (-sev(p), p["hire"], p["id"]))


# HR seed: day 10, hire_day = max(1, 10 - ordinal * 4), Burak hired that day; the leave was sent on day 10
HR_HIRES = {"char_emp_shot_0": 10, "char_emp_shot_1": 6, "char_emp_shot_2": 2, "char_emp_shot_3": 1, "char_emp_shot_4": 10}


def hr_roster(day=11):
    return roster(5, day, leave_left=12 - day, hire_shift=HR_HIRES)


# ------------------------------------------------------------------ table parts
WID, XS, COLS = kit.WID, kit.XS, kit.COLS


def av(path, size, cls=""):
    return common.avatar(path, size, cls)


def av_fill(path, size):
    """A source that is already a disc crop (the Atlas candidates): fill the disc."""
    return '<span class="av av-%d"><img src="%s" alt="" style="position:absolute;left:0;top:0;width:%dpx;height:%dpx"></span>' % (
        size, _src(path), size, size)


def trait_cell(tid, label=True):
    icn, lab, _ = TRAIT[tid]
    return '<div class="trait"><span class="trait-box">%s</span>%s</div>' % (
        ic(icn), ('<span class="trait-label">%s</span>' % T(lab)) if label else "")


def pct(n):
    return L("%%%d" % n, "%d%%" % n)


def xp_cell(p):
    v = p["xp"]
    return ('<div class="xp%s"><div class="xp-track"><div class="xp-fill" style="width:%d%%"></div></div><span class="xp-v">%s</span></div>'
            % (" is-full" if v >= 100 else "", v, pct(v)))


def hours_note(kind, n):
    """Durum's work-hours exception: the same sign and tone as the Mesai panel (overtime warn, short day pos)."""
    key = "HR_STATE_HOURS_OVER" if kind == "over" else "HR_STATE_HOURS_SHORT"
    return ("hours", C(key, n=n), "warn" if kind == "over" else "pos")


def state_cell(p):
    parts = []
    for x in p["st"]:
        k = x[0]
        if k == "over":
            parts.append(tag(s("overload"), "warn"))
        elif k == "idle":
            parts.append(tag(s("idle_tag"), "outline"))
        elif k == "risk":
            parts.append(tag(T("st_risk"), "risk"))
        elif k == "new":
            parts.append(tag(T("st_new")))
        elif k == "leave":
            parts.append(tag(T("st_leave"), "neutral") + '<span class="left">%s</span>' % T("weeks_n", n=x[1]))
        elif k == "training":
            parts.append(tag(s("training_tag"), "neutral") + '<span class="left">%s</span>' % T("weeks_n", n=x[1]))
        elif k == "hours":
            parts.append('<span class="left hn %s">%s</span>' % (x[2], x[1]))
    return '<div class="cell state">%s</div>' % "".join(parts)


def task_text(p):
    if len(p["jobs"]) >= 2:
        return " · ".join(job(j) for j in p["jobs"])
    if not p["jobs"]:
        return ""
    return p["task"]


def ek_row(p, state=""):
    cells = ['<div class="cell face">%s</div>' % av(p["bust"], 32),
             '<div class="cell who"><span class="n">%s</span><span class="r">%s</span></div>' % (p["name"], p["title"])]
    for i, v in enumerate(p["sk"]):
        cls = "sk v%d" % kit.band_of(v) + (" is-main" if i == p["main"] else "") + (" is-sec" if i == p["sec"] else "") + (" sep" if i == 6 else "")
        cells.append('<div class="%s">%d</div>' % (cls, v))
    cells.append('<div class="cell cdata%s" style="padding-left:12px">%s</div>' % (" is-quiet" if p.get("quiet_task") else "", task_text(p)))
    cells.append('<div class="cell" style="padding-left:4px">%s</div>' % xp_cell(p))
    cells.append(state_cell(p))
    cells.append('<div class="cell" style="padding-left:4px">%s</div>' % trait_cell(p["huy"]))
    cells.append('<div class="cell num t-data" style="padding-right:12px;color:var(--ink-2)">%s</div>' % money(p["sal"]))
    cells.append('<div class="cell">%s</div>' % kit.mor(p["moral"]))
    cls = "grid row" + (" is-away" if p["away"] else "") + ((" " + state) if state else "")
    return '<div class="%s" style="grid-template-columns:%s">%s</div>' % (cls, COLS, "".join(cells))


# compact (sıkı) grid: 32 px rows, 24 px face, the role title in its own column, no Deneyim (it lives in the dossier).
# Sized from measure.py (Chrome × 1.08 + 2, TR and EN): Rol 12 + 159 ("Customer Success Manager"), Liderlik 78
# ("LEADERSHIP"), Huy 4 + 20 + 6 + 108 ("Takes Them Under"); the room comes from the name (names only, longest
# crowd name 109) and the skill cells.
SM_W = [36, 136, 38, 38, 38, 38, 38, 38, 80, 176, 170, 142, 138, 80, 116]
SM_XS = [0]
for _w in SM_W:
    SM_XS.append(SM_XS[-1] + _w)
SM_COLS = " ".join("%dpx" % w for w in SM_W)


def head_sm(stuck=True):
    th = ['<div></div>', '<div class="th t-label">%s</div>' % T("c_employee")]
    for icn, name in kit.SKILL_HEADS:
        th.append('<div class="th glyph" title="%s">%s</div>' % (name, ic(icn, 16)))
    th.append('<div class="th t-label c" style="align-self:stretch;align-items:flex-end;border-left:1px solid var(--line-1)">%s</div>' % T("c_lead"))
    for key, st, extra in [("ROL", "padding-left:12px", ""), ("c_task", "padding-left:12px", ""), ("c_state", "", ""),
                           ("c_trait", "padding-left:4px", ""), ("c_salary", "padding-right:12px", " r"), ("c_morale", "", "")]:
        th.append('<div class="th t-label%s" style="%s">%s</div>' % (extra, st, s("role_col") if key == "ROL" else T(key)))
    span = '<div class="th-span t-label" style="left:%dpx;width:%dpx">%s</div>' % (SM_XS[2] + 6, SM_XS[8] - SM_XS[2] - 12, T("roles"))
    return '<div class="grid tbl-head two tbl-sticky%s" style="grid-template-columns:%s">%s%s</div>' % (
        " is-stuck" if stuck else "", SM_COLS, "".join(th), span)


def ek_row_sm(p, state=""):
    cells = ['<div class="cell face" style="padding-left:8px">%s</div>' % av(p["bust"], 24),
             '<div class="cell who"><span class="n">%s</span></div>' % p["name"]]
    for i, v in enumerate(p["sk"]):
        cls = "sk sm v%d" % kit.band_of(v) + (" is-main" if i == p["main"] else "") + (" is-sec" if i == p["sec"] else "") + (" sep" if i == 6 else "")
        cells.append('<div class="%s">%d</div>' % (cls, v))
    cells.append('<div class="cell cdata role" style="padding-left:12px">%s</div>' % p["title"])
    cells.append('<div class="cell cdata" style="padding-left:12px">%s</div>' % task_text(p))
    cells.append(state_cell(p))
    cells.append('<div class="cell" style="padding-left:4px">%s</div>' % trait_cell(p["huy"]))
    cells.append('<div class="cell num t-data" style="padding-right:12px;color:var(--ink-2)">%s</div>' % money(p["sal"]))
    cells.append('<div class="cell">%s</div>' % kit.mor(p["moral"]))
    cls = "grid row sm" + (" is-away" if p["away"] else "") + ((" " + state) if state else "")
    return '<div class="%s" style="grid-template-columns:%s">%s</div>' % (cls, SM_COLS, "".join(cells))


def group_head(gid, gic, collapsed=False, n=0):
    return '<div class="tbl-group t-group%s">%s%s%s%s</div>' % (
        " is-collapsed" if collapsed else "", ic("chevdown" if not collapsed else "chev", 16, cls="tw"), ic(gic), T(gid),
        ('<span class="n">%d</span>' % n) if collapsed else "")


def empty_group():
    return ('<div class="tbl-empty"><span class="t-data">%s</span><span class="btn btn-secondary btn-sm">%s%s</span></div>'
            % (T("nobody"), ic("plus"), s("recruit")))


def group_rows(members, cols, states=None, compact=False):
    states = states or {}
    xs, wid = (SM_XS, SM_W) if compact else (XS, WID)
    bands = "".join('<div class="band" style="left:%dpx;width:%dpx"></div>' % (xs[2 + c], wid[2 + c]) for c in cols)
    row = ek_row_sm if compact else ek_row
    return '<div class="rows">%s%s</div>' % (bands, "".join(row(p, states.get(p["id"], "")) for p in members))


def table(people, states=None, collapsed=()):
    out = [kit.ekip_head()]
    for gid, gic, cols in GROUPS:
        members = sorted_group(people, gid)
        coll = gid in collapsed
        out.append(group_head(gid, gic, coll, len(members)))
        if coll:
            continue
        out.append(group_rows(members, cols, states) if members else empty_group())
    return '<div class="tbl">%s</div>' % "".join(out)


def risk_strip(p):
    return ('<div class="risk">%s%s<span class="risk-name">%s</span><span class="risk-k t-label">%s</span>'
            '<span class="risk-v">%d</span>%s<span class="risk-go">%s</span></div>'
            % (ic("warn", 22, cls="ic-warn"), av(p["bust"], 32), p["name"], T("risk_morale"), p["moral"], tag(T("st_risk"), "risk"), ic("chev")))


def atlas_searching():
    return ('<div class="nstrip"><span class="mono m32">A</span><span class="nm">%s</span><span class="tx">%s</span>'
            '<span class="btn btn-ghost btn-sm">%s</span></div>' % (s("agency"), s("searching", role=C("HR_ROLE_DEVELOPER")), s("search_cancel")))


def atlas_strip(n=3):
    return ('<div class="nstrip"><span class="mono m32">A</span><span class="nm">%s</span><span class="tx">%s</span>'
            '<span class="btn btn-secondary btn-sm">%s</span></div>' % (s("agency"), s("files_desk", n=n), s("open_files")))


# ------------------------------------------------------------------ Ekip window
def kpis(n, morale, payroll):
    # no data is an empty cell (rule 9): the value line keeps its height so the key stays on the KPI baseline
    kv_ = lambda k, v: ('<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi">%s</span></div>'
                        % (T(k), v if v != "" else "&nbsp;"))
    return '<div class="win-kpis">%s%s%s</div>' % (kv_("k_staff", n), kv_("k_morale", morale), kv_("k_payroll", payroll))


def legend():
    return ('<div class="legend"><span class="t-label" style="color:var(--ink-3)">%s</span><div class="legend-row">%s'
            '<span class="k" style="margin-left:6px"><i class="main">7</i> %s</span><span class="k"><i>6</i> %s</span></div></div>'
            % (T("roles"), "".join('<b style="color:var(--skill-%d)">%s</b>' % (i + 1, t) for i, t in enumerate(["1-2", "3-4", "5-6", "7-8", "9-10"])),
               T("main"), T("secondary")))


def hours_chip(start="09:00", end="17:00", over=0):
    tail = ('<span class="t-ccaption" style="color:var(--ink-4)">·</span><span class="x">%s</span>' % s("hours_over", n=over)) if over else ""
    return '<span class="chip%s">%s%s%s</span>' % (" is-flag" if over else "", ic("clock"), s("hours_win", start=start, end=end), tail)


def ekip_win(body, x=208, y=88, w=kit.EKIP_W, h=None, n="5", morale="50", payroll=None, view="roster", ctl_tags="",
             chip=None, cls=""):
    """cls is-under: a PanelLayer panel is open over the window (the window layer dims, its primary loses the amber)."""
    payroll = money(43600) if payroll is None else payroll
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1>%s<div class="grow"></div>%s'
            '<span class="win-close">%s</span></div>' % (T("hr_title"), kpis(n, morale, payroll), legend(), ic("close")))
    tabs = ('<div class="seg"><span class="seg-tab t-tab%s">%s</span><span class="seg-tab t-tab%s">%s</span></div>'
            % (" is-active" if view == "roster" else "", T("tab_roster"), " is-active" if view == "assign" else "", T("tab_assign")))
    ctl = ('<div class="win-ctl">%s%s<div class="grow"></div>%s<span class="btn btn-primary">%s%s</span></div>'
           % (tabs, ('<div class="ctl-tags">%s</div>' % ctl_tags) if ctl_tags else "", chip or hours_chip(), ic("plus"), s("recruit")))
    hs = ("height:%dpx;" % h) if h else ""
    return ('<section class="win %s" style="left:%dpx;top:%dpx;width:%dpx;%s">%s%s<div class="win-body">%s</div></section>'
            % (cls, x, y, w, hs, head, ctl, body))


def kadro_body(people, states=None, strips=(), collapsed=()):
    strip_html = '<div class="strips">%s</div><div style="height:8px"></div>' % "".join(strips) if strips else ""
    return strip_html + table(people, states, collapsed)


# ------------------------------------------------------------------ frames: Kadro
def theme_shell(layers, active="ekip", hud=True, move=True, mail="theme", v=None):
    return page(screen(topbar(v or THEME()), rail(active, B_THEME), layers, hud=hud, move=move,
                       mail=MAIL_THEME() if mail == "theme" else mail))


def f_kadro():
    ppl = roster()
    body = kadro_body(ppl, {"char_emp_shot_0": "is-selected"}, [risk_strip(by_id(ppl, "char_emp_shot_3"))])
    return theme_shell(ekip_win(body))


def crowd39():
    return [person(e, 14, 2) for e in CROWD[1:]]


def f_kadro_40(compact=False):
    """39 employees (the founder is not on the roster): scrolled, the table head stuck, Geliştirme collapsed. The window
    reaches y 1016 over the notice stack's rect, so the stack hides (SPEC §9)."""
    ppl = crowd39()
    payroll = money(sum(p["sal"] for p in ppl))
    morale = round(sum(p["moral"] for p in ppl) / len(ppl))
    rh = 32 if compact else 40
    win_h = 928
    view_top = 16 + 52 + 8 + 56          # body padding, risk strip, gap, two-tier head
    view_h = win_h - 72 - 56 - view_top - 24
    blocks = []
    for gid, gic, cols in GROUPS:
        members = sorted_group(ppl, gid)
        coll = gid == "g_dev"
        blocks.append((36, group_head(gid, gic, coll, len(members))))
        if not coll:
            blocks.append((len(members) * rh, group_rows(members, cols, compact=compact)))
    total = sum(b[0] for b in blocks)
    first_rows = len(sorted_group(ppl, "g_pd"))
    keep = 3.5 if not compact else 4.5          # rows of Ürün & Tasarım still in view
    scroll = min(36 + int((first_rows - keep) * rh), total - view_h)
    inner = "".join(b[1] for b in blocks)
    thumb_h = int(view_h * view_h / (total + 0.0))
    thumb_top = int((view_h - thumb_h) * scroll / (total - view_h))
    sb = ('<div class="sb-track" style="right:8px;top:%dpx;height:%dpx"></div><div class="sb" style="right:8px;top:%dpx;height:%dpx">'
          '<div class="sb-thumb" style="top:%dpx;height:%dpx"></div></div>' % (view_top, view_h, view_top, view_h, thumb_top, thumb_h))
    head = head_sm() if compact else kit.ekip_head(sticky=True, stuck=True)
    body = ('<div class="strips">%s</div><div style="height:8px"></div><div class="tbl">%s'
            '<div class="tbl-view" style="height:%dpx"><div class="tbl-inner" style="top:-%dpx">%s</div></div></div>%s'
            % (risk_strip(by_id(ppl, "char_emp_shot_3")), head, view_h, scroll, inner, sb))
    return theme_shell(ekip_win(body, h=win_h, n=str(len(ppl)), morale=str(morale), payroll=payroll), mail=None)


def f_kadro_40_siki():
    return f_kadro_40(compact=True)


# ------------------------------------------------------------------ frames: Görevler
JOBS = ["build", "test", "support", "accounts", "sales", "research"]
MX_W = [48, 250, 150, 200, 104, 92, 104, 136, 92, 116]        # sum 1292 + 10 = content 1302 with the gutter below
MX_COLS = " ".join("%dpx" % w for w in MX_W)


def jb(state, hover=False):
    hv = " is-hover" if hover else ""
    if state == "on":
        return '<span class="jb on%s">%s</span>' % (hv, ic("check"))
    if state == "on2":
        return '<span class="jb on2%s">%s</span>' % (hv, ic("check"))
    if state == "can":
        return '<span class="jb can%s"></span>' % hv
    if state == "lock":
        return '<span class="jb lock%s">%s</span>' % (hv, ic("lock"))
    return '<span class="jb no"></span>'


def mx_mini(p):
    out = []
    for idx in [p["main"], p["sec"]]:
        if idx is None:
            continue
        v = p["sk"][idx]
        out.append('<span class="m"><span class="k">%s</span><span class="v v%d%s">%d</span></span>'
                   % (area(idx), kit.band_of(v), " is-main" if idx == p["main"] else "", v))
    return '<div class="mx-mini">%s</div>' % "".join(out)


def mx_row(p, cells, hover_cell=None):
    out = ['<div class="cell face">%s</div>' % av(p["bust"], 32),
           '<div class="cell who"><span class="n">%s</span><span class="r">%s</span></div>' % (p["name"], p["title"]),
           '<div class="cell">%s</div>' % mx_mini(p), state_cell(p)]
    for j, st in zip(JOBS, cells):
        out.append('<div class="cell c">%s</div>' % jb(st, hover=(j == hover_cell)))
    return '<div class="grid mx-row%s" style="grid-template-columns:%s">%s</div>' % (" is-away" if p["away"] else "", MX_COLS, "".join(out))


def mx_head():
    th = ['<div></div>', '<div class="th t-label">%s</div>' % T("c_employee"), '<div></div>', '<div class="th t-label">%s</div>' % T("c_state")]
    for j in JOBS:
        th.append('<div class="th t-label c">%s</div>' % job(j))
    return '<div class="grid tbl-head mx-head" style="grid-template-columns:%s">%s</div>' % (MX_COLS, "".join(th))


def mx_legend():
    """The head legend's case (ana, ikincil). The research lock's reason sits at the right end, under the Araştırma column."""
    items = [("on", s("legend_main")), ("on2", s("legend_sec")), ("no", s("legend_noarea")), ("lock", s("legend_locked"))]
    why = '<span class="why">%s<span>%s</span></span>' % (ic("lock"), C("HR_ASSIGN_RESEARCH_ELSEWHERE"))
    return '<div class="mx-legend">%s%s</div>' % ("".join('<span class="it">%s<span class="lg">%s</span></span>' % (jb(k), t) for k, t in items), why)


def f_gorevler():
    ppl = roster()
    elif_, deniz, mert, selin, burak = ppl
    # harness intent (main.gd "gorevler"): one person on two jobs with the third cell capped, one idle
    selin = dict(selin, jobs=["test", "build"], st=[("over",)] + selin["st"])
    deniz = dict(deniz, jobs=[], st=[("idle",)] + deniz["st"])
    rows = [
        (elif_, ["on", "no", "no", "no", "no", "lock"]),
        (deniz, ["can", "no", "no", "no", "no", "lock"]),
        (mert, ["on", "can", "can", "no", "no", "lock"]),
        (selin, ["on2", "on", "lock", "no", "no", "lock"]),
        (burak, ["no", "no", "no", "can", "on", "no"]),
    ]
    mx = mx_head() + "".join(mx_row(p, c, hover_cell=("support" if p is selin else None)) for p, c in rows) + mx_legend()
    body = ('<div class="strips">%s</div><div style="height:8px"></div><div class="tbl" style="position:relative">%s</div>'
            % (risk_strip(selin), mx))
    tags = tag(s("idle_n", n=1), "outline") + tag(s("over_n", n=1), "warn")
    win = ekip_win(body, view="assign", ctl_tags=tags)
    # Selin is row 4: window top 88 + head 72 + ctl 56 + body pad 16 + strip 52 + 8 + head 36 + 3 rows * 48
    cx = 208 + 1 + 24 + sum(MX_W[:6]) + MX_W[6] // 2
    cy = 88 + 72 + 56 + 16 + 52 + 8 + 36 + 3 * 48
    tip = ('<div class="tip at up" style="left:%dpx;top:%dpx"><span class="tip-b" style="color:var(--ink-2)">%s</span></div>'
           % (cx - 58, cy + 48 + 2, C("HR_ASSIGN_JOB_CAP")))
    return theme_shell(win + tip)


# ------------------------------------------------------------------ frames: row menu, dossier
def act_items(p, danger_sep=True, with_open=True, tall=False):
    """Each meta says the action's RESULT: the salary a raise starts from, the title a promotion gives, the training's
    length, the firing's permanence (hr_ledger._action_specs)."""
    items = []
    if with_open:
        items.append('<div class="menu-item">%s<span>%s</span></div>' % (ic("doc"), s("open_file")))
    items.append('<div class="menu-item">%s<span>%s</span><span class="meta"><span class="mk">%s</span> %s</span></div>'
                 % (ic("raise"), C("HR_CARD_RAISE"), C("HR_ROW_SALARY"), money(p["sal"])))
    items.append('<div class="menu-item">%s<span>%s</span><span class="meta"><span class="ar">→</span> %s</span></div>'
                 % (ic("chevup"), C("HR_CARD_PROMOTE"), job_title(p["role"], 2)))
    if tall:
        # the reason runs under the label and the meta at the row's full width (EN is 216 px with the Godot margin)
        items.append('<div class="menu-item is-disabled is-tall">%s<span class="lab"><span class="l1"><span>%s</span><span class="meta">%s</span></span>'
                     '<span class="why2">%s</span></span></div>' % (ic("lock"), C("HR_TRAINING_PICK_TITLE"), C("HR_DURATION_WEEKS", n=2),
                                                                 C("HR_TRAINING_NOT_EARNED")))
    else:
        items.append('<div class="menu-item is-disabled">%s<span>%s</span><span class="why">%s</span></div>'
                     % (ic("lock"), C("HR_TRAINING_PICK_TITLE"), C("HR_TRAINING_NOT_EARNED")))
    if danger_sep:
        items.append('<div class="menu-sep"></div>')
    items.append('<div class="menu-item is-danger">%s<span>%s</span><span class="meta">%s</span></div>' % (ic("departed"), C("HR_CARD_FIRE"), C("HR_MENU_PERMANENT")))
    return "".join(items)


def f_menu():
    ppl = roster()
    elif_ = by_id(ppl, "char_emp_shot_0")
    body = kadro_body(ppl, {"char_emp_shot_0": "is-anchor"}, [risk_strip(by_id(ppl, "char_emp_shot_3"))])
    # Elif's row: window top 88 + 72 + 56 + pad 16 + risk 52 + 8 + head 56 + group 36 + one row 40
    row_top = 88 + 72 + 56 + 16 + 52 + 8 + 56 + 36 + 40
    menu = ('<div class="menu" style="position:absolute;left:%dpx;top:%dpx;width:312px">'
            '<div class="menu-who">%s<span class="who"><span class="n">%s</span><span class="r">%s</span></span></div>'
            '<div class="menu-sep"></div>%s</div>'
            % (208 + 1 + 24 + 1302 - 312, row_top - 6, av(elif_["bust"], 32), elif_["name"], elif_["title"], act_items(elif_, tall=True)))
    return theme_shell(ekip_win(body) + menu)


def dossier(p, x=1576, y=88, w=320, founder=False, sub=None):
    head = ('<div class="dos-head">%s<span class="who"><span class="n">%s</span><span class="r">%s</span></span>'
            '<span class="win-close">%s</span></div>' % (av(p["bust"], 40), p["name"], sub or p["title"], ic("close")))
    sec = lambda k, inner: '<div class="dos-sec"><div class="dos-k t-label">%s</div>%s</div>' % (C(k), inner)
    now = sec("HR_DOSSIER_NOW", '<div class="dos-now">%s</div>' % p["now"])
    trait = ""
    if not founder:
        trait = '<div class="dos-trait">%s<div class="dos-eff">%s</div></div>' % (trait_cell(p["huy"]), C(TRAIT[p["huy"]][2]))
    # the table's seven columns in its order (six areas + Liderlik); the founder adds Karizma
    keys = list(range(7)) + (["charisma"] if founder else [])
    cells = []
    for k in keys:
        if k == "charisma":
            lab, v = C("PER_CHARISMA"), p["charisma"]
        else:
            lab, v = area(k), p["sk"][k]
        role = not founder and k in (p["main"], p["sec"])
        cls = "v v%d" % kit.band_of(v) + (" is-main" if (not founder and k == p["main"]) else "") + (" is-sec" if (not founder and k == p["sec"]) else "")
        cells.append('<div class="sk2%s%s"><span class="k">%s</span><span class="%s">%d</span></div>'
                     % (" is-role" if role else "", " lead" if k == 6 else "", lab, cls, v))
    skills = sec("HR_DOSSIER_SKILLS", '<div class="sk2-list">%s</div>' % "".join(cells))
    kv_ = ['<div class="dos-kv"><span class="k t-label">%s</span>%s</div>' % (C("HR_COL_EXPERIENCE"), xp_cell(p))]
    if not founder:
        kv_.append('<div class="dos-kv"><span class="k t-label">%s</span>%s</div>' % (C("HR_COL_MORALE"), kit.mor(p["moral"])))
        kv_.append('<div class="dos-kv"><span class="k t-label">%s</span><span class="vv">%s</span></div>' % (C("HR_COL_SALARY"), money(p["sal"])))
    state = sec("HR_COL_STATE", "".join(kv_))
    acts = "" if founder else '<div class="dos-acts">%s</div>' % act_items(p, with_open=False, tall=True)
    return ('<section class="dos" style="left:%dpx;top:%dpx;width:%dpx">%s<div class="dos-body">%s%s%s%s%s</div></section>'
            % (x, y, w, head, now, trait, skills, state, acts))


def f_dosya():
    ppl = roster()
    elif_ = dict(by_id(ppl, "char_emp_shot_0"), now=C("HR_TASK_ON_JOB_BUILD"))
    body = kadro_body(ppl, {"char_emp_shot_0": "is-selected"}, [risk_strip(by_id(ppl, "char_emp_shot_3"))])
    # the dossier (x 1576, ends y 939) covers the stack's rect (from y 844): the stack hides, as BuildHUD does
    return theme_shell(ekip_win(body) + dossier(elif_), hud=False, mail=None)


def f_dosya_kurucu():
    f = CROWD[0]
    rs = f["role_stats"]
    founder = dict(name=f["character_name"] or C("HR_ROLE_FOUNDER"), title=C("HR_ROLE_FOUNDER"), bust=os.path.join(MEN, "portraits", "founder_01.png"),
                   sk=[rs[k] for k in ("product", "design", "engineering", "qa", "sales", "customer_success", "leadership")],
                   charisma=rs["charisma"], main=None, sec=None, xp=0, now=s("founder_build"))
    # no name of their own in this seed: the name line falls back to the role, so the subtitle carries only the company
    d = dossier(founder, founder=True, sub="Unicorn Inc.")
    return theme_shell(d, active=None, hud=False, move=True)   # the dossier ends at y 621, above the stack


# ------------------------------------------------------------------ frames: raise and fire (ModalLayer, scrim)
def modal(title, p, inner, foot, h, w=480):
    x, y = (W - w) // 2, (H - h) // 2
    who = ('<div class="who-line">%s<span class="who"><span class="n">%s</span><span class="r">%s</span></span></div>'
           % (av(p["bust"], 32), p["name"], p["title"]))
    return ('<div class="scrim"></div><div class="modal abs" style="left:%dpx;top:%dpx;width:%dpx">'
            '<div class="modal-h"><h2 class="t-cta" style="color:var(--ink-1)">%s</h2><div style="margin-top:12px">%s</div></div>'
            '<div class="modal-b" style="padding-top:16px">%s</div><div class="modal-f">%s</div></div>'
            % (x, y, w, title, who, inner, foot))


def kv(k, b=None, a=None, n="", neg=False, fact=None):
    nn = ('<span class="n">%s</span>' % n) if n else ""
    if fact is not None:
        return '<div class="kv"><span class="k">%s</span><span class="sp"></span><span class="a">%s</span>%s</div>' % (k, fact, nn)
    return ('<div class="kv"><span class="k">%s</span><span class="sp"></span><span class="b">%s</span><span class="ar">→</span>'
            '<span class="a%s">%s</span>%s</div>' % (k, b, " neg" if neg else "", a, nn))


def cost(text):
    """A cost reads as ink with the cost glyph (rule 2), never as a gain."""
    return '<span class="cst">%s%s</span>' % (ic("cost"), text)


def f_zam():
    ppl = roster()
    elif_ = by_id(ppl, "char_emp_shot_0")
    body = kadro_body(ppl, {"char_emp_shot_0": "is-anchor"}, [risk_strip(by_id(ppl, "char_emp_shot_3"))])
    slider = ('<div class="pct"><span class="t-kpi v">%s</span></div>'
              '<div class="slider wide" style="width:432px;margin-top:8px"><div class="slider-t"></div><div class="slider-f" style="width:0"></div>'
              '<div class="slider-g" style="left:0"></div></div>'
              '<div class="sl-ticks" style="width:432px"><span class="t-small" style="left:0">%s</span><span class="t-small" style="right:0">%s</span></div>'
              % (pct(3), pct(3), pct(10)))
    rows = '<div class="kvs" style="margin-top:12px">%s%s%s</div>' % (
        kv(C("HR_ROW_SALARY"), money(9800), money(10094), cost(C("HR_ROW_MONTHLY_NOTE", delta=num("+$294")))),
        kv(C("HR_ROW_MORALE"), "72", "76"),
        kv(C("HR_ROW_PAYROLL"), money(43600), money(43894)))
    perm = '<div class="perm" style="margin-top:16px">%s<span class="t-meta">%s</span></div>' % (ic("info"), C("HR_RAISE_PERMANENT"))
    foot = '<span class="btn btn-secondary">%s</span><span class="btn btn-primary">%s</span>' % (s("cancel"), s("raise_apply", pct=pct(3)))
    m = modal(C("HR_CARD_RAISE"), elif_, slider + rows + perm, foot, 470)
    return theme_shell(ekip_win(body) + m)


def f_cikar(negative=False):
    ppl = roster()
    elif_ = by_id(ppl, "char_emp_shot_0")
    body = kadro_body(ppl, {"char_emp_shot_0": "is-anchor"}, [risk_strip(by_id(ppl, "char_emp_shot_3"))])
    cash = 1200 if negative else 10000
    rows = '<div class="kvs">%s%s%s%s%s</div>' % (
        kv(C("HR_COST_SEVERANCE"), fact=cost(money(3267)), n=C("HR_ROW_MONTHS_NOTE", months=L("0,3", "0.3"))),
        kv(C("HR_ROW_CASH"), money(cash), money(cash - 3267), neg=negative),
        kv(C("HR_ROW_PAYROLL"), money(43600), money(33800)),
        kv(C("HR_ROW_TOOLS"), money(2250), money(2100)),
        kv(C("HR_ROW_TEAM_MORALE"), fact=cost("−5")))
    note = ('<div class="negnote" style="margin-top:16px">%s<span class="t">%s</span></div>' % (ic("warn"), s("fire_neg", n=4))) if negative else ""
    foot = '<span class="btn btn-secondary">%s</span><span class="btn btn-danger">%s%s</span>' % (s("cancel"), ic("departed"), C("HR_CARD_FIRE"))
    m = modal(C("HR_CARD_FIRE"), elif_, rows + note, foot, 452 if negative else 392)
    return theme_shell(ekip_win(body) + m, v=dict(THEME(), cash=money(cash)))


def f_cikar_eksi():
    return f_cikar(True)


# ------------------------------------------------------------------ frames: training (PanelLayer)
AREA_X0, AREA_X1, AREA_Y0 = 208, W - 24, 88
OWNER_CX = AREA_X0 + kit.EKIP_W // 2   # the Ekip window's centre (884)


def panel(title, body, foot, w, sub="", x=None, y=None, h=None, close=True, mono=None):
    """PanelLayer panel: centred on the window that opened it and kept inside the window area, top at the area's top
    (y 88). Atlas (1440, 1560) then covers the window's whole width; Mesai and Eğitim leave equal margins of it on both
    sides instead of a thin sliver on one. The window under it is drawn with is-under."""
    x = max(AREA_X0, min(AREA_X1 - w, OWNER_CX - w // 2)) if x is None else x
    y = AREA_Y0 if y is None else y
    lead = ('<span class="mono m40" style="margin-right:16px">%s</span>' % mono) if mono else ""
    head = ('<div class="win-head">%s<h1 class="win-title t-h2" style="margin-right:0">%s</h1>%s<div class="grow"></div>%s</div>'
            % (lead, title, ('<span class="ttl-sub t-label">%s</span>' % sub) if sub else "",
               ('<span class="win-close">%s</span>' % ic("close")) if close else ""))
    hs = ("height:%dpx;" % h) if h else ""
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;%s">%s<div class="win-body" style="padding-bottom:24px">%s</div>%s</section>'
            % (x, y, w, hs, head, body, ('<div class="pnl-foot">%s</div>' % foot) if foot else ""))


def kadro_behind_theme(states=None, mod=None):
    ppl = roster()
    if mod:
        ppl = [mod.get(p["id"], p) for p in ppl]
    return ekip_win(kadro_body(ppl, states, [risk_strip(by_id(ppl, "char_emp_shot_3"))]), cls="is-under")


TR_COLS = "1fr 96px 120px 150px 124px"


def tr_row(area_name, cur, tgt, fee, dur, cls=""):
    lock = cls == "is-locked"
    lab = ('%s<span>%s</span>' % (ic("lock"), area_name)) if lock else area_name
    return ('<div class="grid tr-row %s" style="grid-template-columns:%s"><div class="lab">%s</div>'
            '<div class="val v%d">%d</div><div class="to"><span class="ar">→</span><span class="val v%d">%d</span></div>'
            '<div class="fee">%s</div><div class="dur">%s</div></div>'
            % (cls, TR_COLS, lab, kit.band_of(cur), cur, kit.band_of(tgt), tgt, cost(fee), dur))


def tr_head():
    hs = [("HR_TRAINING_COL_AREA", "padding-left:12px"), ("HR_TRAINING_COL_CURRENT", "justify-content:center"),
          ("HR_TRAINING_COL_TARGET", "justify-content:center"), ("HR_TRAINING_COL_FEE", "justify-content:flex-end;padding-right:20px"),
          ("HR_TRAINING_COL_DURATION", "justify-content:flex-end;padding-right:12px")]
    return '<div class="grid tbl-head" style="grid-template-columns:%s">%s</div>' % (
        TR_COLS, "".join('<div class="th t-label" style="%s">%s</div>' % (st, C(k)) for k, st in hs))


def f_egitim(locked=False):
    ppl = roster()
    elif_ = by_id(ppl, "char_emp_shot_0")
    who = ('<div class="who-line">%s<span class="who"><span class="n">%s</span><span class="r">%s</span></span>'
           '<div class="grow"></div>%s</div>' % (av(elif_["bust"], 40), elif_["name"], elif_["title"], mx_mini(elif_)))
    dur = C("HR_DURATION_WEEKS", n=2)
    fees = [money(2793), money(2116), money(2116)]
    lv = [(area(0), 7, 8), (area(1), 6, 7), (area(6), 6, 7)]
    if locked:
        # the reason is said once, beside the disabled button; the rows keep their durations
        rows = "".join(tr_row(a, c, t, f, dur, "is-locked") for (a, c, t), f in zip(lv, fees))
        foot = ('<span class="btn btn-secondary">%s</span><span class="why t-meta">%s</span><span class="btn btn-primary is-disabled">%s</span>'
                % (s("cancel"), C("HR_TRAINING_NOT_EARNED"), C("HR_TRAINING_PICK_TITLE")))
    else:
        rows = "".join(tr_row(a, c, t, f, dur, "is-selected" if i == 0 else "") for i, ((a, c, t), f) in enumerate(zip(lv, fees)))
        foot = ('<span class="btn btn-secondary">%s</span><span class="sum t-meta">%s</span><span class="btn btn-primary">%s</span>'
                % (s("cancel"), s("train_sum", area=area(0), duration=dur), s("train_cta", fee=fees[0])))
    warn = '<div class="fact" style="margin-top:16px">%s<span class="t-meta">%s</span></div>' % (ic("lock"), C("HR_TRAINING_WARNING"))
    body = who + '<div class="tr-tbl" style="margin-top:20px">%s%s</div>' % (tr_head(), rows) + warn
    pnl = panel(C("HR_TRAINING_PICK_TITLE"), body, foot, 760)
    # the egitim harness: Elif's bar full (unlocked) or the plain seed (locked)
    mod = {} if locked else {"char_emp_shot_0": dict(by_id(ppl, "char_emp_shot_0"), xp=100)}
    return theme_shell(kadro_behind_theme({"char_emp_shot_0": "is-anchor"}, mod) + pnl)


def f_egitim_kilitli():
    return f_egitim(True)


# ------------------------------------------------------------------ frames: HR seed shell (Atlas, Mesai, empty states)
def hr_shell(v, layers, badges, compact=False, Wd=W, Hh=H, mail=None, plate="office_safe_1920.png"):
    return page(screen(topbar(v, compact, Wd), rail("ekip", badges, icons=compact), layers, compact=compact,
                       move=not compact, Hh=Hh, mail=mail, plate=plate), Wd=Wd, Hh=Hh)


def hr_kadro(day=11, strips_extra=(), states=None, mod=None, x=208, w=kit.EKIP_W, chip=None, h=None, under=True):
    ppl = hr_roster(day)
    if mod:
        ppl = [dict(p, **mod[p["id"]]) if p["id"] in mod else p for p in ppl]
    strips = [risk_strip(by_id(ppl, "char_emp_shot_3"))] + list(strips_extra)
    cls = " ".join(c for c in ("is-clipped" if h else "", "is-under" if under else "") if c)
    return ekip_win(kadro_body(ppl, states, strips), x=x, w=w, chip=chip, h=h, cls=cls)


ROLES_ATLAS = [  # HRConstants.EMPLOYEE_ROLES then FUTURE_ROLES (role key, hint key, lock); locks for the HR seed (no B2B product)
    ("HR_ROLE_PRODUCT_MANAGER", "HR_ROLE_HINT_PRODUCT_MANAGER", ""),
    ("HR_ROLE_DESIGNER", "HR_ROLE_HINT_DESIGNER", ""),
    ("HR_ROLE_DEVELOPER", "HR_ROLE_HINT_DEVELOPER", "sel"),
    ("HR_ROLE_TESTER", "HR_ROLE_HINT_TESTER", "hover"),
    ("HR_ROLE_SALES_REP", "HR_ROLE_HINT_SALES_REP", "HR_ROLE_LOCK_SALES"),
    ("HR_ROLE_CUSTOMER_REP", "HR_ROLE_HINT_CUSTOMER_REP", ""),
    ("HR_ROLE_MARKETING", "HR_ROLE_HINT_MARKETING", "HR_ROLE_LOCK_FULL_VERSION"),
    ("HR_ROLE_HR_INHOUSE", "HR_ROLE_HINT_HR_INHOUSE", "HR_ROLE_LOCK_FULL_VERSION"),
]


def pick(title, desc="", lock="", selected=False, hover=False):
    """Selected = SPEC §5 (surface-4 + the 3 px marker on the card's own left edge) plus the check, the same state as
    Ürün's type picker; hover a border; locked dims only the title and glyph."""
    cls = "pick" + (" is-selected" if selected else "") + (" is-locked" if lock else "") + (" is-hover" if hover else "")
    t = '<div class="pick-t">%s%s</div>' % (title, ic("lock") if lock else "")
    d = ('<div class="pick-d">%s</div>' % desc) if desc else ""
    why = ('<div class="pick-why">%s<span>%s</span></div>' % (ic("lock"), C(lock))) if lock else ""
    chk = ('<span class="chk">%s</span>' % ic("check")) if selected else ""
    return '<div class="%s">%s%s%s%s</div>' % (cls, t, d, why, chk)


def atlas_search_panel(w, x=None, y=None, h=None):
    roles = "".join(pick(C(r), C(hnt), "" if l in ("", "sel", "hover") else l, l == "sel", hover=(l == "hover")) for r, hnt, l in ROLES_ATLAS)
    levels = "".join(pick(C(k), selected=(k == "HR_LEVEL_MID")) for k in ("HR_LEVEL_JUNIOR", "HR_LEVEL_MID", "HR_LEVEL_SENIOR"))
    meta = ('<div class="meta-line">%s<span class="t-meta">%s</span><span class="dot">·</span><span class="t-meta">%s</span></div>'
            % (ic("calendar"), s("arrival", span=C("HR_ATLAS_ARRIVAL_SPAN")), s("free_note")))
    body = ('<div class="sec-h t-group">%s</div><div class="picks">%s</div>'
            '<div class="sec-h t-group" style="margin-top:24px">%s</div><div class="picks lv">%s</div>%s'
            % (s("atlas_step_role"), roles, C("HR_ATLAS_STEP_LEVEL"), levels, meta))
    foot = ('<span class="btn btn-secondary">%s</span><span class="sum t-meta">%s</span><span class="btn btn-primary">%s</span>'
            % (s("cancel"), C("HR_ROLE_DEVELOPER"), s("start_search")))
    return panel(s("agency"), body, foot, w, mono="A", x=x, y=y, h=h)


def f_atlas_arama_1536():
    pnl = atlas_search_panel(1424, x=88, y=88, h=712)   # the whole 1536 area, as the files panel
    return hr_shell(HRS(10), hr_kadro(10, x=88, h=712) + pnl, {"ekip": ("danger", "1")}, compact=True, Wd=1536, Hh=864)


def f_atlas_arama():
    return hr_shell(HRS(10), hr_kadro(10) + atlas_search_panel(1440), {"ekip": ("danger", "1")}, mail=MAIL_HR(10))


CANDS = [  # baseline hr__dosyalar (HR seed, developer search at Orta): name, skills, trait, salary, commission
    dict(name="Deniz Aksoy", img=0, sk=(7, 2, 1), huy="loyal", sal=3850, com=1925),
    dict(name="Arda Arslan", img=1, sk=(5, 4, 3), huy="last_one_out", sal=4350, com=2175),
    dict(name="Ece Erdem", img=2, sk=(7, 1, 2), huy="bag_packed", sal=3050, com=1525),
]


def afile(i, c, selected=False, hover=False):
    path = os.path.join(ROOT, "assets", "cand_%d.png" % c["img"])
    sk = ('<div class="afile-sk"><div class="c"><span class="k">%s</span><span class="v v%d is-main">%d</span></div>'
          '<div class="c"><span class="k">%s</span><span class="v v%d is-sec">%d</span></div>'
          '<div class="c lead"><span class="k">%s</span><span class="v v%d">%d</span></div></div>'
          % (area(2), kit.band_of(c["sk"][0]), c["sk"][0], area(3), kit.band_of(c["sk"][1]), c["sk"][1],
             area(6), kit.band_of(c["sk"][2]), c["sk"][2]))
    tr = '<div class="afile-tr">%s<div class="e">%s</div></div>' % (trait_cell(c["huy"]), C(TRAIT[c["huy"]][2]))
    ask = ('<div class="afile-ask"><span class="k t-label">%s</span><span class="v">%s</span><span class="u">%s</span></div>'
           % (C("HR_ATLAS_SALARY_LABEL"), money(c["sal"]), C("HR_PER_MONTH")))
    com = ('<div class="afile-kv">%s<span class="k t-label">%s</span><span class="b">%s</span><span class="a">%s</span></div>'
           % (ic("cost"), C("HR_ATLAS_COMMISSION_LABEL"), s("commission_once"), money(c["com"])))
    # runway in the top bar's unit: 21 weeks reads "5 ay" there (21 / 4.33 = 4.8), 19 weeks "4 ay" (4.4)
    rw = ('<div class="afile-kv">%s<span class="k t-label">%s</span><span class="b">%s</span><span class="ar">→</span><span class="a">%s</span></div>'
          % (ic("hourglass"), C("HR_ATLAS_RUNWAY_LABEL"), months(5), months(4)))
    chk = '<span class="chk">%s</span>' % ic("check") if selected else ""
    return ('<div class="afile%s%s"><div class="afile-k"><span class="t-micro">%s</span>%s</div>'
            '<div class="afile-id">%s<span class="who"><span class="n">%s</span><span class="r">%s</span></span></div>'
            '<div class="afile-hint">%s</div>%s%s<div class="afile-sp"></div>%s%s%s</div>'
            % (" is-selected" if selected else "", " is-hover" if hover else "", s("file_n", i=i + 1, n=3), chk, av_fill(path, 48), c["name"],
               C("HR_ROLE_DEVELOPER"), C("HR_ROLE_HINT_DEVELOPER"), sk, tr, ask, com, rw))


def files_panel(w, x=None, y=None, h=None, cols=3):
    cards = "".join(afile(i, c, selected=(i == 0), hover=(i == 2)) for i, c in enumerate(CANDS))
    body = ('<div class="sec-h t-group">%s</div><div class="files" style="grid-template-columns:repeat(%d,1fr)">%s</div>'
            % (C("HR_ATLAS_FILES_COUNT", n=3), cols, cards))
    foot = ('<span class="btn btn-secondary">%s</span><span class="sum t-meta">%s</span><span class="btn btn-primary">%s</span>'
            % (s("take_none"), "%s · %s" % (CANDS[0]["name"], C("HR_ROLE_DEVELOPER")), s("hire", amount=money(CANDS[0]["sal"]))))
    return panel(s("agency"), body, foot, w, mono="A", x=x, y=y, h=h)


def f_atlas_dosyalar():
    # as wide as the window it covers, the panel takes the window's height too (88 to 830): no strip of it shows below
    return hr_shell(HRS(), hr_kadro(11, [atlas_strip()]) + files_panel(1560, h=742), {"ekip": ("danger", "2")}, mail=MAIL_HR(11))


def f_atlas_dosyalar_1536():
    # at 1536 the panel takes the whole window area (1424 × 712), so no sliver of the window shows under it
    k = hr_kadro(11, [atlas_strip()], x=88, h=712)
    return hr_shell(HRS(), k + files_panel(1424, x=88, y=88, h=712), {"ekip": ("danger", "2")}, compact=True, Wd=1536, Hh=864)


# ------------------------------------------------------------------ frames: Mesai (work hours)
HRS_COLS = "1fr 196px 140px 96px 136px 116px"


def stepper(val, cls="", inherited=False, dn=True, up=True):
    return ('<span class="stepper sm%s"><span class="b%s">%s</span><span class="v %s">%s</span><span class="b%s">%s</span></span>'
            % (" is-inherited" if inherited else "", "" if dn else " is-disabled", ic("minus"), cls, val, "" if up else " is-disabled", ic("plus")))


def hmor(m, dir_=None, n=0):
    band = "lo" if m < 35 else "mid" if m < 50 else "hi"
    d = ""
    if dir_ == "down":
        d = '<span class="dir warn">%s</span>' % "".join(ic("chevdown") for _ in range(n))
    elif dir_ == "up":
        d = '<span class="dir pos">%s</span>' % ic("chevup")
    return '<div class="hmor %s">%s<span class="t"><i style="width:%d%%"></i></span><span class="v">%d</span></div>' % (band, d, m, m)


def hrow(scope, start="", hours="", state="", src="", mor="", cls=""):
    return ('<div class="grid hrs-row %s" style="grid-template-columns:%s"><div class="cell scope">%s</div><div class="cell">%s</div>'
            '<div class="cell">%s</div><div class="cell">%s</div><div class="cell">%s</div><div class="cell">%s</div></div>'
            % (cls, HRS_COLS, scope, start, hours, state, src, mor))


def hrs_head():
    hs = [("HR_HOURS_COL_SCOPE", ""), ("HR_HOURS_COL_START", ""), ("HR_HOURS_COL_HOURS", ""), ("HR_HOURS_COL_STATE", ""),
          ("HR_HOURS_COL_SOURCE", ""), ("HR_COL_MORALE", "justify-content:flex-end")]
    return '<div class="grid tbl-head" style="grid-template-columns:%s;padding-left:12px;padding-right:12px">%s</div>' % (
        HRS_COLS, "".join('<div class="th t-label" style="%s">%s</div>' % (st, C(k)) for k, st in hs))


def dayband(start, end, over_from=None, width=780):
    span = 16.0
    x = lambda h: (h - 8) / span * width
    out = ['<div class="db-track"></div>']
    w_end = over_from if over_from else end
    out.append('<div class="db-win" style="left:%.1fpx;width:%.1fpx"></div>' % (x(start), x(w_end) - x(start)))
    if over_from:
        out.append('<div class="db-over" style="left:%.1fpx;width:%.1fpx"></div>' % (x(over_from), x(end) - x(over_from)))
    for h in range(8, 25):
        big = h % 4 == 0
        out.append('<i class="db-tick%s" style="left:%.1fpx"></i>' % (" big" if big else "", x(h)))
        if big and h not in (start, end):  # an hour the caption above already names is not labelled twice
            out.append('<span class="db-lbl t-small" style="left:%.1fpx">%02d:00</span>' % (x(h), h % 24))
    out.append('<span class="db-cap t-small" style="left:%.1fpx">%02d:00</span>' % (x(start), start))
    out.append('<span class="db-cap t-small" style="left:%.1fpx">%02d:00</span>' % (x(end), end % 24))
    return ('<div style="display:flex;align-items:flex-start;gap:16px;margin:0 0 16px"><span class="t-label" style="color:var(--ink-3);flex:none;padding-top:14px">%s</span>'
            '<div class="dayband" style="flex:1">%s</div></div>' % (s("hours_band"), "".join(out)))


def scope_person(p):
    return '<span class="n">%s</span><span class="r">%s</span>' % (p["name"], p["title"])


def scope_group(gid):
    return '<span class="t-group g" style="padding-left:16px">%s</span>' % T(gid)


def f_mesai(night=False):
    """The panel holds an unapplied draft (burn before → after, Uygula pending): the top bar, the hours chip and the
    roster behind keep the applied day (09:00 to 17:00, nobody on overtime) until Uygula."""
    ppl = hr_roster(11)
    E, D, M, Se, B = ppl
    rev = '<span class="rev">%s%s</span>' % (ic("revert"), C("HR_HOURS_BACK_TO_COMPANY"))
    src = lambda k: '<span class="src">%s</span>' % C(k)
    ind = lambda html: '<div style="padding-left:32px;display:flex;flex-direction:column">%s</div>' % html
    hv = lambda n: C("HR_HOURS_VALUE", n=n)
    st_ = lambda kind, n: '<span class="st %s">%s</span>' % (hours_note(kind, n)[2], hours_note(kind, n)[1])
    away = tag(T("st_leave"), "neutral")   # Mert is on leave: off the overtime count, no morale arrows
    co_sub = '<span class="n">%s</span><span class="r">%s</span>' % (C("HR_HOURS_SCOPE_COMPANY"), C("HR_HOURS_COMPANY_SUB", n=5))
    if night:
        st = st_("over", 8)
        rows = [hrow(co_sub, '<span style="display:flex;align-items:center;gap:8px">%s<span class="end">→ 00:00</span></span>' % stepper("08:00", dn=False),
                     stepper(hv(16), "warn", up=False), st, src("HR_HOURS_SOURCE_BASE"), "", "co")]
        for gid in ("g_pd", "g_dev", "g_sales", "g_cs"):
            rows.append(hrow(scope_group(gid), "", stepper(hv(16), inherited=True, up=False), st, src("HR_HOURS_SOURCE_FROM_COMPANY")))
            for p in [x for x in ppl if x["group"] == gid]:
                rows.append(hrow(ind(scope_person(p)), "", stepper(hv(16), inherited=True, up=False), away if p["away"] else st,
                                 src("HR_HOURS_SOURCE_FROM_COMPANY"), hmor(p["moral"]) if p["away"] else hmor(p["moral"], "down", 3),
                                 "is-away" if p["away"] else ""))
        costs = ('<div class="costs" style="margin-top:20px"><div class="burn">%s<span class="k">%s</span><span class="b">%s</span>'
                 '<span class="ar">→</span><span class="a">%s</span></div><div class="t-meta" style="color:var(--ink-3)">%s</div>'
                 '<div class="perm">%s<span class="t-meta">%s</span></div></div>'
                 % (ic("cost"), C("HR_HOURS_COST_BURN"), money(45840), money(112110), C("HR_HOURS_FACT_OVER", n=4),
                    ic("info"), C("HR_HOURS_RULE_OVERTIME")))
        band = dayband(8, 24, over_from=16)
        foot = ('<span class="sum"></span><span class="btn btn-secondary">%s</span><span class="btn btn-primary">%s</span>'
                % (s("cancel"), s("apply")))
    else:
        rows = [hrow(co_sub, '<span style="display:flex;align-items:center;gap:8px">%s<span class="end">→ 17:00</span></span>' % stepper("09:00"),
                     stepper(hv(8)), "", src("HR_HOURS_SOURCE_BASE"), "", "co")]
        rows.append(hrow(scope_group("g_pd"), "", stepper(hv(8), inherited=True), "", src("HR_HOURS_SOURCE_FROM_COMPANY")))
        rows.append(hrow(ind(scope_person(E)), "", stepper(hv(6), "pos"), st_("short", 2), rev, hmor(E["moral"], "up")))
        rows.append(hrow(ind(scope_person(D)), "", stepper(hv(8), inherited=True), "", src("HR_HOURS_SOURCE_FROM_COMPANY"), hmor(D["moral"])))
        rows.append(hrow(scope_group("g_dev"), "", stepper(hv(10), "warn"), st_("over", 2), rev))
        rows.append(hrow(ind(scope_person(M)), "", stepper(hv(10), inherited=True), away, src("HR_HOURS_SOURCE_FROM_GROUP"), hmor(M["moral"]), "is-away"))
        rows.append(hrow(ind(scope_person(Se)), "", stepper(hv(10), inherited=True), st_("over", 2),
                         src("HR_HOURS_SOURCE_FROM_GROUP"), hmor(Se["moral"], "down", 2)))
        rows.append(hrow(scope_group("g_sales"), "", stepper(hv(8), inherited=True), "", src("HR_HOURS_SOURCE_FROM_COMPANY")))
        rows.append(hrow(ind(scope_person(B)), "", stepper(hv(8), inherited=True), "", src("HR_HOURS_SOURCE_FROM_COMPANY"), hmor(B["moral"])))
        rows.append(hrow(scope_group("g_cs"), "", stepper(hv(8), inherited=True), "", src("HR_HOURS_SOURCE_FROM_COMPANY")))
        costs = ('<div class="costs" style="margin-top:20px"><div class="burn">%s<span class="k">%s</span><span class="b">%s</span>'
                 '<span class="ar">→</span><span class="a">%s</span></div><div class="t-meta" style="color:var(--ink-3)">%s · %s</div>'
                 '<div class="perm">%s<span class="t-meta">%s</span></div><div class="perm">%s<span class="t-meta">%s</span></div></div>'
                 % (ic("cost"), C("HR_HOURS_COST_BURN"), money(45840), money(49380), C("HR_HOURS_FACT_OVER", n=1), C("HR_HOURS_FACT_SHORT", n=1),
                    ic("info"), C("HR_HOURS_RULE_OVERTIME"), ic("info"), C("HR_HOURS_RULE_SHORT")))
        band = dayband(9, 19, over_from=17)
        foot = ('<span class="btn btn-ghost">%s%s</span><span class="sum"></span><span class="btn btn-secondary">%s</span><span class="btn btn-primary">%s</span>'
                % (ic("revert"), s("equalise"), s("cancel"), s("apply")))
    body = band + '<div class="hrs">%s%s</div>%s' % (hrs_head(), "".join(rows), costs)
    pnl = panel(C("HR_HOURS_TITLE"), body, foot, 1000)
    return hr_shell(HRS(), hr_kadro(11, [atlas_strip()]) + pnl, {"ekip": ("danger", "2")}, mail=MAIL_HR(11))


def f_mesai_gece():
    return f_mesai(True)


# ------------------------------------------------------------------ frames: empty states (founder only)
def f_kadro_bos():
    body = '<div class="strips">%s</div><div style="height:8px"></div>%s' % (atlas_strip(), table([]))
    win = ekip_win(body, n="0", morale="", payroll="$0")
    return hr_shell(EMPTY(), win, {"ekip": ("count", "1")}, mail=MAIL_HR(11, staff=False), plate="office_safe_1920_home.png")


def f_gorevler_bos():
    body = mx_head() + empty_group()
    win = ekip_win(body, n="0", morale="", payroll="$0", view="assign")
    # week 10, no search yet: nothing waits, so no stack
    return hr_shell(EMPTY(10), win, {}, mail=[], plate="office_safe_1920_home.png")


# ------------------------------------------------------------------ documentation sheet: row states at 1:1
def f_satir_durumlari():
    ppl = roster()
    E, D, M, Se, B = ppl
    items = [
        ("Varsayılan", "Burak Şahin bu hafta alındı: Yeni etiketi iki hafta durur.", ek_row(B)),
        ("Üstünde", "Satırın kendi kenarında 1 px çerçeve; dolgu yok.", ek_row(D, "is-hover")),
        ("Seçili", "Dosyası ya da menüsü açık kişi: surface-4 ve 3 px işaret.", ek_row(E, "is-selected")),
        ("İzinde", "Gri yüz, ink-3 ad, nötr İzinde etiketi ve kalan hafta. Sayılar tam renkte kalır.", ek_row(M)),
        ("Ayrılabilir", "Moral 35 altı: risk etiketi, kırmızı moral, pencerenin üstünde risk şeridi, grubunda en üstte.", ek_row(Se)),
        ("Eğitimde", "egitim fikstürü: Deniz Arslan iki haftalık eğitimde; görevi ink-4, deneyim barı dolu.",
         ek_row(dict(D, xp=100, st=[("training", 2)], quiet_task=True))),
        ("Deneyim dolu", "egitim fikstürü: Elif Demir'in barı dolu ve vurgulu; menüde Eğitime gönder açılır.", ek_row(dict(E, xp=100))),
        ("Yarı yolda", "egitim fikstürü: Mert Yıldız %42.", ek_row(dict(M, xp=42))),
        ("Aşırı yük", "İki iş (türetilmiş örnek): görev iki kısa etiket, Durum'da uyarı etiketi, amber değil.",
         ek_row(dict(B, jobs=["sales", "accounts"], st=[("over",), ("new",)]))),
        ("Mesai istisnası", "Uygulanmış saat: kişinin kısa günü olumlu, gruptan gelen mesai uyarı renginde (Mesai panelinin rengi), Durum'un sonunda.",
         ek_row(dict(E, st=E["st"] + [hours_note("short", 2)]))),
        ("Boşta", "gorevler fikstürü: hiçbir işe atanmamış; Görev hücresi boş (veri yok), Durum'da Boşta etiketi (çizgi, başlıktaki sayaçla aynı).",
         ek_row(dict(D, jobs=[], st=[("idle",)]))),
    ]
    rows = ['<div class="srow"><div class="srow-l">%s</div><div class="srow-r"></div></div>' % kit.ekip_head()]
    for k, note, row in items:
        rows.append('<div class="srow"><div class="srow-l">%s</div><div class="srow-r"><span><b class="t-label">%s</b>&nbsp; %s</span></div></div>'
                    % (row, k, note))
    chips = '<div style="display:flex;gap:12px;align-items:center">%s%s</div>' % (hours_chip(), hours_chip(over=1))
    strips = [("Risk şeridi", "Kaçma riski başına bir şerit; ok kişinin dosyasını açar.", risk_strip(Se)),
              ("Atlas, arayış sürüyor", "HR_SEARCHING_ONE; iptal hayalet düğme (arama ücretsiz, beklenen zaman yanar).", atlas_searching()),
              ("Atlas, dosyalar masada", "HR_FILES_ON_DESK; açma düğmesi ikincil, pencerenin birincili İşe alım başlat kalır.", atlas_strip()),
              ("Saat çipi", "Uygulanmış saatler: şirketin penceresi; uygulanmış bir mesai varken uyarı renginde kaç kişinin mesaide olduğu. "
                            "Mesai panelindeki taslak (Uygula basılmadan) çipi değiştirmez.", chips)]
    srows = []
    for k, note, html in strips:
        srows.append('<div class="srow srow-gap"><div class="srow-l">%s</div><div class="srow-r"><span><b class="t-label">%s</b>&nbsp; %s</span></div></div>'
                     % (html, k, note))
    head = ('<div class="sheet-h"><span class="t-label n">EKİP · A4</span><span class="t-h2 t">Kadro satırının durumları</span>'
            '<span class="t-meta s">1352 px pencerenin tablo ızgarası (SPEC §3.4), tema tohumu, hafta 14</span></div>')
    return page('<div class="sheet">%s<div class="srows">%s</div><div class="srows">%s</div></div>' % (head, "".join(rows), "".join(srows)),
                title="Satır durumları")


# ------------------------------------------------------------------ build
FRAMES = {  # name: (builder, lang, colour-blind palette)
    "ekip__kadro": (f_kadro, "tr", False),
    "ekip__kadro_40": (f_kadro_40, "tr", False),
    "ekip__kadro_40_siki": (f_kadro_40_siki, "tr", False),
    "ekip__satir_durumlari": (f_satir_durumlari, "tr", False),
    "ekip__gorevler": (f_gorevler, "tr", False),
    "ekip__menu": (f_menu, "tr", False),
    "ekip__zam": (f_zam, "tr", False),
    "ekip__cikar": (f_cikar, "tr", False),
    "ekip__cikar_eksi": (f_cikar_eksi, "tr", False),
    "ekip__dosya": (f_dosya, "tr", False),
    "ekip__dosya_kurucu": (f_dosya_kurucu, "tr", False),
    "ekip__egitim": (f_egitim, "tr", False),
    "ekip__egitim_kilitli": (f_egitim_kilitli, "tr", False),
    "ekip__atlas_arama": (f_atlas_arama, "tr", False),
    "ekip__atlas_arama_1536": (f_atlas_arama_1536, "tr", False),
    "ekip__atlas_dosyalar": (f_atlas_dosyalar, "tr", False),
    "ekip__atlas_dosyalar_1536": (f_atlas_dosyalar_1536, "tr", False),
    "ekip__mesai": (f_mesai, "tr", False),
    "ekip__mesai_gece": (f_mesai_gece, "tr", False),
    "ekip__kadro_bos": (f_kadro_bos, "tr", False),
    "ekip__gorevler_bos": (f_gorevler_bos, "tr", False),
    # colour-blind palette (plan A4: Ekip + Olaylar + Satış)
    "ekip__kadro_renk_koru": (f_kadro, "tr", True),
    "ekip__gorevler_renk_koru": (f_gorevler, "tr", True),
    # English, through the same builders (SPEC finding 6: Ekip is the EN overflow risk)
    "ekip__kadro_en": (f_kadro, "en", False),
    "ekip__kadro_40_siki_en": (f_kadro_40_siki, "en", False),
    "ekip__menu_en": (f_menu, "en", False),
    "ekip__mesai_en": (f_mesai, "en", False),
    "ekip__atlas_dosyalar_en": (f_atlas_dosyalar, "en", False),
}
SIZES = {"ekip__atlas_dosyalar_1536": (1536, 864, 1.25), "ekip__atlas_arama_1536": (1536, 864, 1.25)}


def main(names):
    os.makedirs(BUILD, exist_ok=True)
    for n in names or FRAMES:
        fn, lang, cb = FRAMES[n]
        set_lang(lang)
        html = fn()
        if cb:
            html = html.replace("<body>", '<body class="cb">', 1)
        open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8").write(html)
        print("built", n)
    set_lang("tr")
    if not names:
        open(os.path.join(BUILD, "strings.md"), "w", encoding="utf-8").write(strings_table())
        open(os.path.join(BUILD, "sizes.txt"), "w", encoding="utf-8").write(
            "".join("%s %d %d %s\n" % (k, w, h, sc) for k, (w, h, sc) in SIZES.items()))


if __name__ == "__main__":
    main(sys.argv[1:])
