"""Component builders for the sheet: every function returns HTML using the classes of ../base.css and the
text table of common.py (so set_lang("en") rebuilds the same component in English for the width pass)."""
import measure
from common import T, ic, avatar, portrait, STR, ART, num

# ------------------------------------------------------------------ type metrics for baseline placement
# hhea ascent and descent per em (fontTools): CSS line box and Godot Label both centre ascent+descent in the line.
FACE = {"cond": (1.0, 0.2), "sans": (1.025, 0.275), "sansc": (1.025, 0.275), "serif": (1.036, 0.335)}
CLS = {  # class: (face, size, css line)
    "t-hero": ("sans", 30, 40), "t-kpi": ("sans", 26, 35), "t-clock": ("sans", 22, 30), "t-value": ("sans", 18, 24),
    "t-body": ("sans", 16, 22), "t-data": ("sans", 15, 21), "t-data-med": ("sans", 15, 21), "t-key": ("sans", 14, 19),
    "t-meta": ("sans", 14, 19), "t-caption": ("sans", 13, 18), "t-small": ("sans", 12, 17),
    "t-label": ("cond", 14, 19), "t-micro": ("cond", 12, 17), "t-gate": ("cond", 18, 24), "t-subhead": ("cond", 20, 27),
}


def top_for(baseline, cls):
    face, size, lh = CLS[cls]
    a, d = FACE[face]
    return baseline - ((lh - (a + d) * size) / 2 + a * size)


def at(x, baseline, cls, inner, extra="", width=None, align="left"):
    """A label placed by its baseline (Godot: position.y = baseline - font.get_ascent(size))."""
    w = "width:%dpx;" % width if width else ""
    al = "text-align:%s;" % align if align != "left" else ""
    return '<span class="tb-x %s %s" style="left:%.0fpx;top:%.1fpx;%s%s">%s</span>' % (cls, extra, x, top_for(baseline, cls), w, al, inner)


# ------------------------------------------------------------------ small parts
def tag(text, kind=""):
    return '<span class="tag %s">%s</span>' % (("tag-" + kind) if kind else "", text)


def pill(topic, text=None):
    return '<span class="pill %s">%s</span>' % (topic, text if text is not None else T("topic_" + topic))


def stamp(text, date=""):
    return '<span class="stamp t-stamp">%s%s</span>' % (text, ('<span class="d">%s</span>' % date) if date else "")


def mor_cls(m):
    return "lo" if m < 35 else "mid" if m < 50 else "hi"


def mor(m):
    return ('<div class="mor %s"><span class="mor-v">%d</span><div class="mor-track"><div class="mor-fill" style="width:%d%%"></div>'
            '<div class="mor-notch"></div></div></div>' % (mor_cls(m), m, m))


def xp(p):
    v = ("%%%d" % p) if T("c_xp") == "Deneyim" else ("%d%%" % p)
    return '<div class="xp"><div class="xp-track"><div class="xp-fill" style="width:%d%%"></div></div><span class="xp-v">%s</span></div>' % (p, v)


def trait(icon, key):
    return '<div class="trait"><span class="trait-box">%s</span><span class="trait-label">%s</span></div>' % (ic(icon), T(key))


def fx(kind, text, glyph=None):
    g = glyph or {"gain": "up", "cost": "cost", "danger": "warn", "chance": "dice"}[kind]
    return '<span class="fx %s">%s%s</span>' % (kind, ic(g), text)


def band_of(v):
    return 1 if v <= 2 else 2 if v <= 4 else 3 if v <= 6 else 4 if v <= 8 else 5


def stars(n, of=5):
    full, half = int(n), (n - int(n)) >= 0.5
    out = "".join(ic("star") for _ in range(full))
    if half:
        out += ic("star_half")
    out += "".join('<span class="off">%s</span>' % ic("star_empty") for _ in range(of - full - (1 if half else 0)))
    return '<span class="stars">%s</span>' % out


# ------------------------------------------------------------------ top bar: fixed columns from measured TR and EN text
def _w(cls, *texts):
    items = []
    for i, t in enumerate(texts):
        for lang in ("tr", "en"):
            items.append(("%d%s" % (i, lang), cls, t, lang))
    return max(measure.godot(v) for v in measure.measure(items).values())


def _both(key, **kw):
    a, b = STR[key]
    return (a.format(**kw), b.format(**kw)) if kw else (a, b)


def _tb_columns():
    unit = _w("t-caption", "/ay", "/mo")
    c = {
        "A": max(_w("t-label", *_both("cash")), _w("t-micro", *_both("net"))),
        "B": max(_w("t-hero", "$999.999", "−$99.999"), _w("t-data-med", "−$44K", "+$12K") + 2 + unit),
        "C": _w("t-label", *(_both("runway") + _both("shutter_k"))),
        "D": _w("t-value", *(_both("profitable") + _both("weeks_n", n=3) + _both("months_n", n=14))),
        "E": max(_w("t-label", *_both("mrr")), _w("t-micro", *_both("brand"))),
        "F": max(_w("t-value", "$120K", "$1,2M"), _w("t-data", "100", "−12")),
        "G": max(_w("t-label", *_both("burn")), _w("t-micro", *_both("rep"))),
        "H": max(_w("t-value", "$46K") + 2 + unit, _w("t-data", "100", "−12")),
        "gate_txt": max(_w("t-gate", *_both("gate")), _w("t-key", *(_both("next_offer") + _both("next_sprint") + _both("next_end") + _both("gate_n", n=3)))),
        "clock": _w("t-clock", "11:00", "00:00"),
        "date": _w("t-body", *_both("date")), "date_c": _w("t-body", *_both("date_c")),
    }
    return c


TB = _tb_columns()
TB_GEOM = {  # full (logical width >= 1680) and compact (1536)
    False: dict(brand=184, pad=20, kv=8, pair=20, rule=20, gate=248, gate_pad=20, time_pad=(20, 16), clock_gap=16, key_w=40),
    True: dict(brand=64, pad=12, kv=6, pair=12, rule=12, gate=216, gate_pad=16, time_pad=(12, 12), clock_gap=12, key_w=30),
}


def tb_layout(compact):
    g = TB_GEOM[compact]
    x = g["brand"] + g["pad"]
    col = {}
    for name, after in (("A", g["kv"]), ("B", g["pair"]), ("C", g["kv"]), ("D", g["rule"])):
        col[name] = x
        x += TB[name] + after
    col["rule"] = x
    x += 1 + g["rule"]
    for name, after in (("E", g["kv"]), ("F", g["pair"]), ("G", g["kv"]), ("H", g["pad"])):
        col[name] = x
        x += TB[name] + after
    col["metrics_end"] = x
    time_w = g["time_pad"][0] + TB["clock"] + g["clock_gap"] + 5 * g["key_w"] + 4 * 4 + g["time_pad"][1]
    return col, g, time_w


def week_bar(x0, x1, now_h=11.0, marks=(), start=8, mesai=9, end=17, labels=True):
    span = end - start
    pos = lambda h: (h - start) / span * 100
    ticks = "".join('<i class="wk-tick%s" style="left:%.2f%%"></i>' % (" end" if h == end else "", pos(h)) for h in range(start + 1, end + 1))
    mk = "".join('<i class="wk-mark" style="left:%.2f%%"></i>' % pos(h) for h in marks)
    bar = ('<div class="wk" style="left:%dpx;width:%dpx;top:38px"><div class="wk-pre" style="width:%.2f%%"></div>'
           '<div class="wk-run" style="left:%.2f%%"></div><div class="wk-fill" style="width:%.2f%%"></div>%s%s'
           '<div class="wk-now" style="left:%.2f%%"></div></div>' % (x0, x1 - x0, pos(mesai), pos(mesai), pos(now_h), ticks, mk, pos(now_h)))
    if labels:
        bar += at(x0, 58, "t-small", "%02d:00" % start, "tb-k")
        bar += at(x1 - 34, 58, "t-small", "%02d:00" % end, "tb-k", width=34, align="right")
    return bar


def logo():
    return ('<svg class="tb-logo" viewBox="0 0 32 32" style="position:absolute;width:32px;height:32px"><rect width="32" height="32" rx="6" fill="var(--ink-2)"/>'
            '<path d="M9.5 8 H14 V18 A2 2 0 0 0 18 18 V8 H22.5 V18.2 A6.5 6.5 0 0 1 9.5 18.2Z" fill="var(--surface-1)"/></svg>')


def topbar(state="normal", compact=False, width=None, live=False, slot="next", W=1920, week_marks=(14,)):
    """state: normal | gated | gated2 | alarm. slot (ungated): next | offer | offer_last | sprint | end.
    Every column is fixed, so the week bar has one length in every state and language."""
    col, g, time_w = tb_layout(compact)
    W = width or W
    gated = state.startswith("gated")
    cls = "topbar" + (" is-gated" if gated else "") + (" is-compact" if compact else "") + (" is-live" if live else "")
    out = []
    # brand
    out.append('<div style="position:absolute;left:%dpx;top:16px">%s</div>' % ((16 if compact else 20), logo()))
    if not compact:
        out.append(at(64, 31, "t-subhead", "Unicorn Inc.", "tb-co", width=g["brand"] - 64 - 12))
        out.append(at(64, 50, "t-micro", T("phase"), "tb-k"))
        for i in range(3):
            out.append('<i class="tb-dot%s" style="left:%dpx;top:44px"></i>' % (" on" if i == 0 else "", 64 + TB_PHASE_W + 8 + i * 12))
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % (g["brand"] - 1))
    # metrics: row 1 baseline 33, row 2 baseline 54
    neg = state == "alarm"
    b1, b2 = 33, 54
    out.append(at(col["A"], b1, "t-label", T("cash"), "tb-k"))
    out.append(at(col["B"], b1, "t-hero", num("−$4.200" if neg else "$10.000"), "tb-hero neg" if neg else "tb-hero"))
    out.append(at(col["A"], b2, "t-micro", T("net"), "tb-k"))
    out.append(at(col["B"], b2, "t-data-med", num("−$3,1K" if neg else "+$2,5K") + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-d neg" if neg else "tb-d"))
    out.append(at(col["C"], b1, "t-label", T("shutter_k") if neg else T("runway"), "tb-k"))
    out.append(at(col["D"], b1, "t-value", T("weeks_n", n=3) if neg else T("profitable"), "tb-v neg" if neg else "tb-v pos"))
    out.append('<span class="tb-rule short" style="left:%dpx"></span>' % col["rule"])
    out.append(at(col["E"], b1, "t-label", T("mrr"), "tb-k"))
    out.append(at(col["F"], b1, "t-value", num("$4,0K"), "tb-v"))
    out.append(at(col["E"], b2, "t-micro", T("brand"), "tb-k"))
    out.append(at(col["F"], b2, "t-data", "50", "tb-v"))
    out.append(at(col["G"], b1, "t-label", T("burn"), "tb-k"))
    out.append(at(col["H"], b1, "t-value", num("$7,1K" if neg else "$1,5K") + '<span class="tb-u">%s</span>' % T("per_mo"), "tb-v"))
    out.append(at(col["G"], b2, "t-micro", T("rep"), "tb-k"))
    out.append(at(col["H"], b2, "t-data", "0", "tb-v"))
    # day block
    gate_x = W - time_w - g["gate"]
    day_x0, day_x1 = col["metrics_end"], gate_x
    out.append('<span class="tb-rule" style="left:%dpx"></span>' % day_x0)
    pad = 16 if compact else 20
    out.append(at(day_x0 + pad, 28, "t-body", T("date_c") if compact else T("date"), "tb-date"))
    out.append(week_bar(day_x0 + pad, min(day_x1 - pad, day_x0 + pad + 720), marks=week_marks))
    # gate slot (always reserved)
    gx = gate_x
    out.append('<div class="tb-gate" style="left:%dpx;width:%dpx"></div>' % (gx, g["gate"]))
    tx = gx + g["gate_pad"] + 10 + (10 if compact else 12)
    tw = g["gate"] - (tx - gx) - g["gate_pad"]
    if gated:
        out.append('<span class="gate-dot" style="position:absolute;left:%dpx;top:19px"></span>' % (gx + g["gate_pad"]))
        out.append(at(tx, 30, "t-gate", T("gate"), "gate-l"))
        sub = T("frank_offer") if state == "gated" else T("gate_n", n=3)
        out.append(at(tx, 51, "t-key", sub, "gate-s", width=tw))
    else:
        tx = gx + g["gate_pad"]
        tw = g["gate"] - 2 * g["gate_pad"]
        out.append(at(tx, 29, "t-micro", T("next"), "nx-l"))
        sub, kind = {"next": (T("next_meet"), ""), "offer": (T("next_offer"), "warn"), "offer_last": (T("next_offer_last"), "neg"),
                     "sprint": (T("next_sprint"), ""), "end": (T("next_end"), "")}[slot]
        out.append(at(tx, 50, "t-key", sub, "nx-s " + kind, width=tw))
    # time block
    tx0 = W - time_w
    out.append('<div class="tb-time" style="left:%dpx;width:%dpx"></div>' % (tx0, time_w))
    out.append(at(tx0 + g["time_pad"][0], 41, "t-clock", "11:00", "tb-clock" + (" " if gated else "")))
    kx = tx0 + g["time_pad"][0] + TB["clock"] + g["clock_gap"]
    keys = "".join('<span class="spd-k%s" style="width:%dpx">%s</span>' % (" is-on" if k == "II" and not gated else "", g["key_w"], k)
                   for k in ["II", "1x", "2x", "3x", "4x"])
    out.append('<div class="spd" style="left:%dpx;top:16px">%s</div>' % (kx, keys))
    if gated:
        out.append('<div class="tb-gated-frame" style="left:%dpx;width:%dpx"></div>' % (gx, W - gx))
    style = (' style="width:%dpx;right:auto"' % W) if width else ""
    return '<header class="%s"%s>%s</header>' % (cls, style, "".join(out))


TB_PHASE_W = _w("t-micro", "Bootstrap", "Traction", "Series A")


def tb_week_bar_len(compact, W):
    """The week bar's length in px for a bar width W; the same in every state by construction."""
    col, g, time_w = tb_layout(compact)
    pad = 16 if compact else 20
    gate_x = W - time_w - g["gate"]
    return min(gate_x - pad - col["metrics_end"] - pad, 720)


# ------------------------------------------------------------------ rail
RAIL = [("urun", "tab_product", None), ("satis", "tab_sales", ("danger", "1")), ("ekip", "tab_hr", ("danger", "1")),
        ("finans", "tab_finance", None), ("kisisel", "tab_personal", None), ("pazarlama", "tab_marketing", "lock"),
        ("arge", "tab_rnd", ("count", "2")), ("olaylar", "tab_events", ("gate", ""))]


def rail(active="ekip", icons=False, hover=None, style="", top=None, bottom=None):
    rows = []
    for key, name, badge in RAIL:
        cls = "rr" + (" is-active" if key == active else "") + (" is-hover" if key == hover else "") + (" is-locked" if badge == "lock" else "")
        right = ""
        if badge == "lock":
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span><span class="rr-why t-micro">%s</span></span>' % (T(name), T("soon"))
            right = '<span class="lk">%s</span>' % ic("lock", 12) if icons else ""
        else:
            txt = '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span>' % T(name)
            if badge:
                right = '<span class="badge badge-%s">%s</span>' % (badge[0], badge[1])
        rows.append('<div class="%s"><span class="rr-ic">%s</span>%s%s</div>' % (cls, ic(key, 24), txt, right))
    pos = ""
    if top is not None:
        pos += "top:%dpx;" % top
    if bottom is not None:
        pos += "bottom:%dpx;" % bottom
    return ('<nav class="rail%s" style="%s%s">%s<div class="rail-bottom"><div class="rr"><span class="rr-ic">%s</span>'
            '<span class="rr-txt"><span class="rr-n t-nav">%s</span></span></div></div></nav>'
            % (" is-icons" if icons else "", pos, style, "".join(rows), ic("ayarlar", 24), T("tab_settings")))


# ------------------------------------------------------------------ ticker, floats, toast
NEWS = [("sektor", "Sektör Telgrafı", "Teknoloji kampüslerinde staj kontenjanları rekor kırdı.", "Internship quotas hit a record across tech campuses."),
        ("ekonomi", "Ekonomi Postası", "Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta.", "Discount season on server leases; infrastructure teams are negotiating."),
        ("teknogundem", "TeknoGündem", "Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi.", "Digital transformation tenders are queuing up in industrial zones."),
        ("girisim", "Girişim Bülteni", "Melek yatırım ağları yeni dönem başvurularını açtı.", "Angel networks open applications for the new season."),
        ("sektor", "Sektör Telgrafı", "Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu.", "Software exporters hunt for new markets; the trade-fair calendar is full."),
        ("ekonomi", "Ekonomi Postası", "Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu.", "Office downsizing continues; shared floors are full.")]


def ticker(style="", collapsed=False):
    if collapsed:
        return '<footer class="ticker is-collapsed" style="%s"><div class="tk-toggle">%s</div></footer>' % (style, ic("news"))
    import common
    items = []
    for i, (k, p, h_tr, h_en) in enumerate(NEWS):
        if i:
            items.append('<span class="tk-sep">   ·   </span>')
        items.append('<span class="tk-pub %s">%s</span><span class="tk-hl">%s</span>' % (k, p, h_tr if common.LANG == "tr" else h_en))
    return '<footer class="ticker" style="%s"><div class="tk-toggle">%s</div><div class="tk-run">%s</div></footer>' % (style, ic("news"), "".join(items))


def buildhud(style=""):
    return ('<div class="float bh" style="%s"><div class="bh-hd">%s<span class="t">Unicorn Inc. v1</span></div>'
            '<div class="bh-rw">%s<span class="k t-label">%s</span><span class="v">%s</span></div>'
            '<div class="bh-act"><span class="btn btn-ghost btn-sm">%s%s</span></div></div>'
            % (style, ic("urun", 20, "var(--ink-3)"), ic("shield", 16, "var(--ink-3)"), T("support"), T("confirmed_0"), ic("play", 12), T("start_fix")))


def notice(style="", kind="", co="Nordica", tx=None, more=""):
    return ('<div class="float notice" style="%s"><span class="dt %s"></span><span class="co">%s</span><span class="tx">%s</span>%s</div>'
            % (style, kind, co, tx if tx is not None else T("s_expansion"), more))


def toast(kind, head, sub, glyph):
    return '<span class="toast %s"><span class="well">%s</span>%s<span class="sub">%s</span></span>' % (kind, ic(glyph), head, sub)


# ------------------------------------------------------------------ Ekip window
PEOPLE = {
    "elif": dict(name="Elif Demir", role="r_pm", sk=[7, 6, 4, 4, 4, 4, 6], main=0, sec=1, task="task_build",
                 durum=("tag", "st_new"), huy=("tr_lead", "t_lead"), maas="$9.800", moral=72),
    "deniz": dict(name="Deniz Arslan", role="r_design", sk=[5, 6, 3, 3, 3, 3, 2], main=1, sec=0, task="task_build",
                  durum=None, huy=("tr_last", "t_last"), maas="$7.400", moral=38),
    "mert": dict(name="Mert Yıldız", role="r_dev", sk=[4, 4, 8, 7, 4, 4, 3], main=2, sec=3, task="task_build",
                 durum=("leave", "st_leave"), huy=("tr_loyal", "t_loyal"), maas="$11.200", moral=61, away=True),
    "selin": dict(name="Selin Kaya", role="r_qa", sk=[3, 3, 4, 5, 3, 3, 1], main=3, sec=2, task="task_test",
                  durum=("risk", "st_risk"), huy=("tr_double", "t_double"), maas="$6.900", moral=22),
    "burak": dict(name="Burak Şahin", role="r_sales", sk=[3, 3, 3, 3, 6, 3, 2], main=4, sec=None, task="task_sales",
                  durum=("tag", "st_new"), huy=("tr_fast", "t_fast"), maas="$8.300", moral=55),
}
GROUPS = [("g_pd", ["deniz", "elif"], [0, 1], "d_pd"), ("g_dev", ["selin", "mert"], [2, 3], "d_dev"),
          ("g_sales", ["burak"], [4], "d_sales"), ("g_cs", [], [5], "d_cs")]
SKILL_HEADS = [("sk_product", "Ürün"), ("sk_design", "Tasarım"), ("sk_eng", "Yazılım"), ("sk_qa", "Test"), ("sk_sales", "Satış"),
               ("sk_cs", "Müşteri İlişkileri")]
TRAITS = [("tr_loyal", "t_loyal"), ("tr_fast", "t_fast"), ("tr_lead", "t_lead"), ("tr_double", "t_double"),
          ("tr_last", "t_last"), ("tr_cantsay", "t_cantsay"), ("tr_bag", "t_bag"), ("tr_mood", "t_mood"), ("tr_unknown", "t_unknown")]
# face | name | 6 skills | liderlik | görev | deneyim | durum | huy | maaş | moral  (sum 1302 = 1352 - 2 - 48)
WID = [48, 170, 44, 44, 44, 44, 44, 44, 80, 172, 88, 142, 142, 80, 116]
XS = [0]
for _w_ in WID:
    XS.append(XS[-1] + _w_)
COLS = " ".join("%dpx" % w for w in WID)
EKIP_W = 1352


def ekip_head(sticky=False, stuck=False, sort=None):
    th = ['<div></div>', '<div class="th t-label">%s</div>' % T("c_employee")]
    for icn, name in SKILL_HEADS:
        th.append('<div class="th glyph" title="%s">%s</div>' % (name, ic(icn)))
    th.append('<div class="th t-label c" style="align-self:stretch;align-items:flex-end;border-left:1px solid var(--line-1)">%s</div>' % T("c_lead"))
    heads = [("c_task", "padding-left:12px", ""), ("c_xp", "padding-left:4px", ""), ("c_state", "", ""), ("c_trait", "padding-left:4px", ""),
             ("c_salary", "padding-right:12px", " r"), ("c_morale", "", "")]
    for key, st, extra in heads:
        srt = ""
        cl = "th t-label" + extra
        if sort and sort[0] == key:
            cl += " is-sorted"
            srt = ic("sort_down" if sort[1] == "down" else "sort_up", 12, cls="sort")
        th.append('<div class="%s" style="%s">%s%s</div>' % (cl, st, T(key), srt))
    span = '<div class="th-span t-label" style="left:%dpx;width:%dpx">%s</div>' % (XS[2] + 6, XS[8] - XS[2] - 12, T("roles"))
    cls = "grid tbl-head two" + (" tbl-sticky" if sticky else "") + (" is-stuck" if stuck else "")
    return '<div class="%s" style="grid-template-columns:%s">%s%s</div>' % (cls, COLS, "".join(th), span)


def ekip_row(key, state="", compact=False):
    p = PEOPLE[key]
    cells = ['<div class="cell face">%s</div>' % avatar(key, 24 if compact else 32)]
    if compact:
        cells.append('<div class="cell who"><span class="n">%s</span></div>' % p["name"])
    else:
        cells.append('<div class="cell who"><span class="n">%s</span><span class="r">%s</span></div>' % (p["name"], T(p["role"])))
    for i, v in enumerate(p["sk"]):
        cls = "sk v%d" % band_of(v) + (" is-main" if i == p["main"] else "") + (" is-sec" if i == p["sec"] else "") + (" sep" if i == 6 else "")
        cells.append('<div class="%s">%d</div>' % (cls, v))
    cells.append('<div class="cell cdata" style="padding-left:12px">%s</div>' % T(p["task"]))
    cells.append('<div class="cell" style="padding-left:4px">%s</div>' % xp(0))
    d = p["durum"]
    if d is None:
        cells.append('<div class="cell"></div>')
    elif d[0] == "tag":
        cells.append('<div class="cell">%s</div>' % tag(T(d[1])))
    elif d[0] == "risk":
        cells.append('<div class="cell">%s</div>' % tag(T(d[1]), "risk"))
    else:
        cells.append('<div class="cell state">%s<span class="left">%s</span></div>' % (tag(T(d[1]), "neutral"), T("st_leave_left")))
    cells.append('<div class="cell" style="padding-left:4px">%s</div>' % trait(*p["huy"]))
    cells.append('<div class="cell num t-data" style="padding-right:12px;color:var(--ink-2)">%s</div>' % num(p["maas"]))
    cells.append('<div class="cell">%s</div>' % mor(p["moral"]))
    cls = "grid row" + (" sm" if compact else "") + (" is-away" if p.get("away") else "") + ((" " + state) if state else "")
    return '<div class="%s" style="grid-template-columns:%s">%s</div>' % (cls, COLS, "".join(cells))


def ekip_table(states, zebra=False, sort=None, collapsed=()):
    out = [ekip_head(sort=sort)]
    for gname, members, cols, gic in GROUPS:
        coll = gname in collapsed
        out.append('<div class="tbl-group t-group%s">%s%s%s%s</div>' % (
            " is-collapsed" if coll else "", ic("chevdown" if not coll else "chev", 16, cls="tw"), ic(gic), T(gname),
            ('<span class="n">%d</span>' % len(members)) if coll else ""))
        if coll:
            continue
        if not members:
            out.append('<div class="tbl-empty"><span class="t-data">%s</span>'
                       '<span class="btn btn-secondary btn-sm">%s%s</span></div>' % (T("nobody"), ic("plus"), T("recruit")))
            continue
        bands = "".join('<div class="band" style="left:%dpx;width:%dpx"></div>' % (XS[2 + c], WID[2 + c]) for c in cols)
        rows = "".join(ekip_row(k, states.get(k, "")) for k in members)
        out.append('<div class="rows%s">%s%s</div>' % (" zebra" if zebra else "", bands, rows))
    return '<div class="tbl">%s</div>' % "".join(out)


def ekip_window(x, y, w=EKIP_W, states=None, readonly=False, title=True, sort=None, collapsed=()):
    states = states or {}
    kpis = ('<div class="win-kpis"><div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi">5</span></div>'
            '<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi">50</span></div>'
            '<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi">%s</span></div></div>'
            % (T("k_staff"), T("k_morale"), T("k_payroll"), num("$43.600")))
    legend = ('<div class="legend"><span class="t-label" style="color:var(--ink-3)">%s</span><div class="legend-row">%s'
              '<span class="k" style="margin-left:6px"><i class="main">7</i> %s</span><span class="k"><i>6</i> %s</span></div></div>'
              % (T("roles"), "".join('<b style="color:var(--skill-%d)">%s</b>' % (i + 1, t) for i, t in enumerate(["1-2", "3-4", "5-6", "7-8", "9-10"])),
                 T("main"), T("secondary")))
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1>%s<div class="grow"></div>%s'
            '<span class="win-close">%s</span></div>' % (T("hr_title"), kpis, legend, ic("close")))
    ro = ""
    if readonly:
        ro = ('<div class="win-ro"><span class="gate-dot"></span><span class="t-key" style="color:var(--ink-2)">%s</span>'
              '<span class="t-caption" style="color:var(--ink-3)">%s</span><div class="grow"></div>'
              '<span class="btn btn-secondary btn-sm">%s%s</span></div>' % (T("ro_strip"), T("frank_offer"), ic("reply"), T("back_to_decision")))
    ctl = ('<div class="win-ctl"><div class="seg"><span class="seg-tab t-tab is-active">%s</span><span class="seg-tab t-tab">%s</span></div>'
           '<div class="grow"></div><span class="chip%s">%s%s</span><span class="btn btn-primary%s">%s%s</span></div>'
           % (T("tab_roster"), T("tab_assign"), " is-disabled" if readonly else "", ic("clock"), T("hours_chip"),
              " is-disabled" if readonly else "", ic("plus"), T("recruit")))
    risk = ('<div class="risk">%s%s<span class="risk-name">Selin Kaya</span><span class="risk-k t-label">%s</span>'
            '<span class="risk-v">22</span>%s<span class="risk-go">%s</span></div>'
            % (ic("warn", 22, cls="ic-warn"), avatar("selin", 32), T("risk_morale"), tag(T("st_risk"), "risk"), ic("chev")))
    body = '<div class="win-body">%s<div style="height:8px"></div>%s</div>' % (risk, ekip_table(states, sort=sort, collapsed=collapsed))
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx">%s%s%s%s</section>'
            % (x, y, w, head if title else "", ro, ctl, body))


# ------------------------------------------------------------------ inbox
def ib_row(frm, topic, subj, right="", pre="", cls="", hover=False, stamp_html=""):
    return ('<div class="ib-row %s%s">%s<div class="ib-l1"><span class="ib-from">%s</span>%s</div>'
            '<div class="ib-l2"><span class="ib-subj">%s</span><span class="ib-right">%s</span></div>'
            '<div class="ib-l3">%s</div>%s</div>'
            % (cls, " is-hover" if hover else "", '<span class="hov"></span>' if hover else "", frm, pill(topic) if topic else "",
               subj, right, pre, stamp_html))


def inbox_rows():
    mv = '<span class="t-label" style="color:var(--ink-3)">%s</span><b style="color:var(--neg)">22</b>' % T("risk_morale")
    return "".join([
        ib_row("Frank Köseoğlu", "mentor", T("frank_offer"), "11:00", "Ürün para kazandırmaya başladı.", "is-gate is-selected"),
        '<div class="ib-queue">%s<span class="t-meta">%s</span><span class="t-caption" style="margin-left:auto;color:var(--ink-3)">%s</span></div>'
        % (ic("queue", 18), T("queue"), T("queue_after")),
        ib_row("Ege Sigorta", "customer", T("s_complaint"), ic("clock") + T("weeks_2"), "Ege Sigorta destek hattını aradı.", "is-unread", hover=True),
        ib_row("Kuzey İnşaat", "customer", T("s_renewal"), ic("clock") + T("wk_this"), "Yenileme görüşmesi bu hafta kapanıyor.", "is-unread is-lastweek"),
        ib_row("Selin Kaya", "team", tag(T("st_risk"), "risk"), mv, "Test Mühendisi · Test ediyor", "is-unread"),
        ib_row("Ege Sigorta", "customer", tag(T("risk_tag"), "risk"), "$1,0K/ay", "<i>Sebep: sık kesinti şikayeti</i>", "is-unread"),
        ib_row("Nordica", "customer", T("s_expansion"), "$2,0K/ay", "<i>Başka departmana yaymak istiyor.</i>", ""),
        '<div class="ib-day t-caption">Hafta 13 · Nisan 2026</div>',
        ib_row("Dönem özeti", "agenda", "Hafta 13 · 2026", ic("doc") + "rapor", "Kasa $10.000 · MRR $4,0K · 3 müşteri", "is-history"),
        ib_row("Nordica", "customer", T("s_request"), "", "%s: Listede olduğunu söyle" % T("your_choice"), "is-history",
               stamp_html=stamp(T("answered_stamp"))),
    ])


FRANK_QUOTE = ('"Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar '
               'koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?"')


def stake_frank(btn=True):
    return ('<div class="stake"><div class="part gain"><span class="part-k">%s</span><span class="part-v">%s+$25K</span></div>'
            '<span class="part-sep"></span><div class="part cost"><span class="part-k">%s</span><span class="part-v">%s%s</span></div>%s</div>'
            % (T("k_cash"), ic("up"), T("k_to_frank"), ic("pie", 32), T("v_equity"),
               ('<span class="btn btn-primary btn-lg">%s</span>' % T("accept")) if btn else ""))


def olay_window(x, y, w=1240, h=900):
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1><div class="win-kpis">'
            '<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi warn">%s</span></div></div>'
            '<div class="grow"></div><span class="win-close">%s</span></div>' % (T("ev_title"), T("k_soonest"), T("this_week"), ic("close")))
    listcol = ('<div class="ib-list"><div class="ib-head"><div class="seg"><span class="seg-tab t-tab is-active">%s<span class="n">9</span></span>'
               '<span class="seg-tab t-tab">%s<span class="n">3</span></span><span class="seg-tab t-tab">%s<span class="n">4</span></span></div></div>'
               '%s<div class="sb" style="right:2px;top:52px;height:%dpx"><div class="sb-thumb" style="top:0;height:%dpx"></div></div></div>'
               % (T("f_all"), T("f_wait"), T("f_unread"), inbox_rows(), h - 72 - 60, int((h - 132) * 0.82)))
    pane = ('<div class="pane"><div class="pane-top"><div class="pane-col">'
            '<div class="pane-kicker">%s<span class="t-meta">%s</span></div>'
            '<h2 class="pane-title t-h2">%s</h2>'
            '<div class="pane-from">%s<span class="n">Frank Köseoğlu</span><span class="r">Operating Partner</span><span class="rel">Nötr</span></div>'
            '<div class="pane-body"><p>Ürün para kazandırmaya başladı.</p><p>Arayan yine Frank.</p>'
            '<div class="quote t-quote">%s</div><p>Cevap bekliyor.</p></div></div>%s</div>'
            '<div class="pane-dec"><div class="perm">%s<span class="t-meta">%s</span></div>%s'
            '<div class="opt is-locked" style="margin-top:8px"><span class="opt-lock">%s</span><span class="opt-label">%s</span>'
            '<span class="opt-why">%s</span></div></div></div>'
            % (pill("mentor"), T("kicker_decision"), T("frank_offer"), avatar("frank", 32), FRANK_QUOTE, portrait("frank"),
               ic("pause"), T("permanent"), stake_frank(), ic("lock", 18), T("refuse"), T("refuse_lock")))
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s<div class="ib">%s%s</div></section>'
            % (x, y, w, h, head, listcol, pane))


# ------------------------------------------------------------------ option bars
def opt(label, fxs="", state="", why=""):
    if state == "is-locked":
        return ('<div class="opt is-locked"><span class="opt-lock">%s</span><span class="opt-label">%s</span><span class="opt-why">%s</span></div>'
                % (ic("lock", 18), label, why))
    return '<div class="opt %s"><span class="opt-label">%s</span><div class="opt-fx">%s</div></div>' % (state, label, fxs)


def opt_armed(label, parts):
    """parts: [(kind, key, glyph, value)]"""
    ps = []
    for i, (kind, k, g, v) in enumerate(parts):
        if i:
            ps.append('<span class="part-sep"></span>')
        ps.append('<div class="part %s"><span class="part-k">%s</span><span class="part-v%s">%s%s</span></div>'
                  % (kind, k, " txt" if kind == "danger" else "", ic(g), v))
    return ('<div class="opt is-armed"><div class="opt-armed-head"><span class="opt-label">%s</span>'
            '<span class="btn btn-ghost btn-sm">%s</span></div><div class="opt-armed-body">%s'
            '<span class="btn btn-primary btn-lg">%s</span></div></div>' % (label, T("cancel"), "".join(ps), T("choose")))
