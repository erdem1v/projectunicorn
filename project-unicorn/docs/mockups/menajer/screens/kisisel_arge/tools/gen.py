"""Kişisel, Ar-Ge, araştırma kartı and Pazarlama (Faz A4, group "kisisel_arge"): builds every frame into
../build/<name>.html. Render with render_all.sh (the menajer render.sh per frame).

  python gen.py            build all frames
  python gen.py <name> ... build the named frames only

Reads (never writes):
  - the system kit through tools/syskit (copies whose caches live here);
  - the shell of group "kabuk", LIVE: ../../kabuk/tools/gen.py (top bar, rail, ticker, office plates with the A2 head
    sprites, BuildHUD, notice stack, Ofisi taşı, seed values) and ../../kabuk/kabuk.css (the research card component).
    The module is executed again whenever the frame language changes, so its import-time strings follow the language.
    No bytecode is written into the kabuk folder;
  - the mail grammar of group "olaylar" through tools/mail_gen.py (a snapshot of its generator) and ../mail.css;
  - localization/strings.csv for every existing player string.
New strings are in NEW below (EN first) and in INDEX.md.
"""
import csv
import importlib.util
import os
import sys

sys.dont_write_bytecode = True   # importing the kabuk module must not write into its folder

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, ".."))
BUILD = os.path.join(ROOT, "build")
KABUK_GEN = os.path.normpath(os.path.join(ROOT, "..", "kabuk", "tools", "gen.py"))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.join(HERE, "syskit"))

import mail_gen as mg  # noqa: E402  (also wires syskit and the image path rule)
import common  # noqa: E402
import kit  # noqa: E402
from common import T, ic, num, set_lang  # noqa: E402
from kit import tag  # noqa: E402


def _load_kabuk():
    spec = importlib.util.spec_from_file_location("kabuk_gen", KABUK_GEN)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


kb = _load_kabuk()

MEN = common.MENAJER
REPO = os.path.normpath(os.path.join(MEN, "..", "..", ".."))
FOUNDER = os.path.join(MEN, "portraits", "founder_01.png")
BUST = mg.BUST

LANG = "tr"
mg.S["k_disc"] = ("Discovery", "Keşif")          # NEW MAIL_KIND_DISCOVERY, same value
common.ICON_FILES.setdefault("sparkle", "util/sparkle")


def L(tr, en):
    return tr if LANG == "tr" else en


# ------------------------------------------------------------------ strings
# Existing player strings come from the CSV as written (read-only). C() returns the value in the frame language.
_CSV = {}
with open(os.path.join(REPO, "localization", "strings.csv"), encoding="utf-8") as f:
    for row in csv.reader(f):
        if len(row) >= 3:
            _CSV[row[0]] = (row[1], row[2])

# Proposed changes to existing CSV values (key -> (EN, TR)); INDEX.md lists them for approval.
CSV_CHANGE = {
    "ONB_ORIGIN_SELF_MADE_NAME": ("Self-Made", "Sıfırdan"),   # binding glossary (gate ruling 5)
}


def C(key, **kw):
    if key in CSV_CHANGE:
        en, tr = CSV_CHANGE[key]
        v = tr if LANG == "tr" else en
    else:
        v = _CSV[key][0 if LANG == "tr" else 1]
    return v.format(**kw) if kw else v


def up1(s):
    """Sentence case of a lowercase CSV value (buttons): Turkish i takes the dotted capital."""
    if not s:
        return s
    first = {"i": "İ", "ı": "I"}.get(s[0], s[0].upper()) if LANG == "tr" else s[0].upper()
    return first + s[1:]


# New strings this group introduces: key -> (EN, TR). Listed in INDEX.md, all awaiting approval.
NEW = {
    "PER_TENURE_KEY": ("Tenure", "Kıdem"),
    "PER_TENURE_VALUE": ("Week {n}", "{n}. hafta"),
    "PER_NO_VALUATION": ("No valuation yet. It is set at the first funding round.", "Değerleme henüz yok. İlk yatırım turunda hesaplanır."),
    "PERSONAL_MS_SHIP_NOTE": ("The product hit the shelves. Now the world plays too.", "Ürün raflara çıktı. Artık dünya da oynuyor."),
    "PHASE_NAME_BOOTSTRAP": ("Bootstrap", "Bootstrap"),
    "PHASE_NAME_TRACTION": ("Traction", "Traction"),
    "PHASE_NAME_SERIES_A_HUNT": ("Series A Hunt", "Series A Avı"),
    "RND_VIEW_TREE": ("Tree", "Ağaç"),
    "RND_VIEW_HISTORY": ("History", "Geçmiş"),
    "RND_TREE_DONE_KEY": ("Completed", "Tamamlanan"),
    "RND_TREE_DONE_VALUE": ("{done} / {total}", "{done} / {total}"),
    "RND_SWITCH_NOTE": ("Starting this stops {node}. Its progress is kept.", "Başlatınca {node} durur; ilerlemesi korunur."),
    "RND_NEED_AREA_AWAY": ("{name} is on leave · no contribution", "{name} izinde · katkı yok"),
    "MAIL_KIND_DISCOVERY": ("Discovery", "Keşif"),
    "MAIL_ROW_DISCOVERY": ("discovery", "keşif"),
    "RND_HISTORY_EMPTY": ("Nothing yet. Notes and discoveries gather here.", "Henüz bir şey yok. Notlar ve keşifler burada toplanır."),
}


def N(key, **kw):
    en, tr = NEW[key]
    v = tr if LANG == "tr" else en
    return v.format(**kw) if kw else v


def pct(n):
    return ("%%%d" % n) if LANG == "tr" else ("%d%%" % n)


def month_year(week):
    import datetime
    d = datetime.date(2026, 1, 1) + datetime.timedelta(days=7 * (week - 1))
    return "%s %d" % (L(mg.MON_TR, mg.MON_EN)[d.month - 1], d.year)


# ================================================================== shell state (group "kabuk" is the source)
# Top bar values in kabuk's format. H14 = kabuk SEED; after Frank's cheque = kabuk V_CHEQUE; H1 = kabuk V_WEEK1.
# H15 and H16 are derived on the one timeline (INDEX.md "Veri"): Frank's cheque was taken at H14 (refusing is locked),
# Burak's H15 report books Karadeniz Fabrika + Efes Emlak (+$1.620/ay) in H14, burn is held at the seed value.
def v15():
    return dict(kb.SEED, cash="$35.959", mrr="$5,6K", net="+$4,1K")


def v16():
    return dict(kb.SEED, cash="$36.918", mrr="$5,6K", net="+$4,1K")


def badges(arge=1, ekip=True, olaylar=None):
    """kabuk's B14 rail badges; Ar-Ge follows RnDSystem.attention_count() (unread note + frozen research)."""
    b = {k: v for k, v in kb.B14.items() if k != "arge"}
    if arge:
        b["arge"] = ("count", str(arge))
    if not ekip:
        b.pop("ekip", None)
    if olaylar:
        b["olaylar"] = olaylar
    return b


def rail(active=None, b=None, icons=False):
    return kb.rail(active, badges() if b is None else b, icons=icons)


# Notice stack = kabuk's inbox preview (kabuk.SEED_INBOX, kabuk.notices). H15 branch B: Nordica's paper (2 weeks at
# H14) is in its final week and Selin has left. H16 branch A: the paper ran out at the end of H15; Selin's reminder
# stays. The discovery mail is this group's proposal for the stack (question 3): an info row until it is read.
def inbox_h15():
    return [dict(kb.NORDICA, weeks=1), kb.EGE]


def inbox_h16(discovery=False):
    disc = [kb.mail("Selin Kaya", (nname("test_automation"),) * 2, "is-info", kind="message")] if discovery else []
    return disc + [kb.EGE, kb.SELIN]


def office_layer(name, dim, W):
    if W == 1536:
        return kb.office("i1536", 64, 64, 1472, 760, dim)
    return kb.office(name, 184, 64, 1736, 976, dim)


def floats(W, H, hud, research, notices, move):
    """BuildHUD and the research card share the 320 px column at (W-344, 88); notice stack bottom right; Ofisi taşı at
    (rail+24, H-108). The caller leaves out any float an open window's rect overlaps (SPEC §9)."""
    out = []
    col = []
    if hud:
        col.append(kb.buildhud(0, 0, "seed").replace("float bh abs", "float bh"))
    if research:
        col.append(research)
    if col:
        out.append('<div class="floatcol" style="left:%dpx;top:88px">%s</div>' % (W - 344, "".join(col)))
    items = kb.SEED_INBOX if notices == "seed" else notices
    if items:
        out.append(kb.notices(W, H, items))
    if move:
        out.append(kb.move_btn(208 if W == 1920 else 88, H - 108, move))
    return "".join(out)


def screen(top, rail_html, window, office="ishani", dim=True, hud=True, research=None, notices="seed", move="idle",
           W=1920, H=1080):
    return ('<div class="screen" style="width:%dpx;height:%dpx">%s%s%s%s%s%s</div>'
            % (W, H, office_layer(office, dim, W), floats(W, H, hud, research, notices, move), window, top, rail_html,
               kb.ticker()))


def page(body, W=1920, H=1080, title="Kişisel ve Ar-Ge"):
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%ssystem/tokens.css"><link rel="stylesheet" href="%ssystem/base.css">'
            '<link rel="stylesheet" href="../mail.css"><link rel="stylesheet" href="../../kabuk/kabuk.css"><link rel="stylesheet" href="../kisisel_arge.css">'
            '<style>html, body { width: %dpx; height: %dpx; }</style></head><body>%s</body></html>'
            % (LANG, title, common.FONTS, mg.REL, mg.REL, W, H, body))


def window(x, y, w, h, title, kpis=(), head_extra="", ro="", ctl="", body="", body_cls=""):
    k = ""
    if kpis:
        k = '<div class="win-kpis">%s</div>' % "".join(
            '<div class="kpi"><span class="kpi-key t-label">%s</span><span class="kpi-val t-kpi">%s</span></div>' % kv for kv in kpis)
    head = ('<div class="win-head"><h1 class="win-title t-h1">%s</h1>%s<div class="grow"></div>%s<span class="win-close">%s</span></div>'
            % (title, k, head_extra, ic("close")))
    hs = (";height:%dpx" % h) if h else ""
    return ('<section class="win" style="left:%dpx;top:%dpx;width:%dpx%s">%s%s%s<div class="win-body %s">%s</div></section>'
            % (x, y, w, hs, head, ro, ctl, body_cls, body))


def ro_strip(sub):
    return ('<div class="win-ro"><span class="gate-dot"></span><span class="t-key" style="color:var(--ink-2)">%s</span>'
            '<span class="t-caption" style="color:var(--ink-3)">%s</span><div class="grow"></div>'
            '<span class="btn btn-secondary btn-sm">%s%s</span></div>' % (T("ro_strip"), sub, ic("reply"), T("back_to_decision")))


# ================================================================== Ar-Ge data (derived; INDEX.md "Ar-Ge zaman çizelgesi")
FAMS = [("capability", "data_model", "product", "RND_FAMILY_CAPABILITY", "HR_AREA_PRODUCT"),
        ("platform", "scalable_backend", "engineering", "RND_FAMILY_PLATFORM", "HR_AREA_ENGINEERING"),
        ("practice", "bug_tracker", "qa", "RND_FAMILY_PRACTICE", "HR_AREA_QA"),
        ("design", "design_system", "design", "RND_FAMILY_DESIGN", "HR_AREA_DESIGN")]
# ResearchTree.children_of sorts ids, so branch A is the alphabetically first child
CHILD = {"data_model": ["ai_engine", "semantic_index"], "scalable_backend": ["analytics_engine", "security_cert"],
         "bug_tracker": ["cicd", "test_automation"], "design_system": ["onboarding_flow", "user_research"],
         "ai_engine": ["edge_inference"], "semantic_index": ["knowledge_graph"], "analytics_engine": ["data_warehouse"],
         "security_cert": ["model_optimization"], "cicd": ["incident_playbook"], "test_automation": ["self_service"],
         "onboarding_flow": ["personalization"], "user_research": ["accessibility"]}
CROSS = {"knowledge_graph": "design_system", "data_warehouse": "data_model", "self_service": "design_system",
         "personalization": "scalable_backend"}
# the feature line a node opens (RND_HIDDEN_LINE_OPENED)
HIDDEN_LINE = {"test_automation": "PROD_LINE_HIDDEN_SELF_SERVE"}
FAMILY_OF = {}
TIER = {}
for fam, root, _a, _f, _ar in FAMS:
    FAMILY_OF[root] = fam
    TIER[root] = "root"
    for b in CHILD[root]:
        FAMILY_OF[b] = fam
        TIER[b] = "branch"
        for c in CHILD[b]:
            FAMILY_OF[c] = fam
            TIER[c] = "cont"
AREA_KEY = {"product": "HR_AREA_PRODUCT", "design": "HR_AREA_DESIGN", "engineering": "HR_AREA_ENGINEERING", "qa": "HR_AREA_QA"}
FAM_AREA = {f[0]: f[2] for f in FAMS}

# Week 14, branch A (Selin stays): four done, test_automation running at 36 %, their children revealed.
W14 = {"data_model": "done", "bug_tracker": "done", "design_system": "done", "user_research": "done",
       "test_automation": "active", "ai_engine": "available", "semantic_index": "available",
       "scalable_backend": "available", "cicd": "available", "onboarding_flow": "available", "accessibility": "available"}
W15_FROZEN = dict(W14, test_automation="frozen")


def nname(nid):
    return C("PROD_RND_NODE_%s" % nid.upper())


def hexsvg(tier):
    return ('<svg class="hex %s" viewBox="0 0 14 14"><polygon points="7,1.2 12.2,4.1 12.2,9.9 7,12.8 1.8,9.9 1.8,4.1"/></svg>' % tier)


def tier_caption(nid, frozen=False):
    t = C({"root": "RND_PLACE_ROOT", "branch": "RND_PLACE_BRANCH", "cont": "RND_PLACE_CONT"}[TIER[nid]])
    return C("RND_TIER_FROZEN", tier=t) if frozen else t


class Geo:
    """The tree lattice (rnd_tree_view.gd): four family columns, three rows, a permanent corridor."""

    def __init__(self, width=1230, col_gap=26, corridor=20, tile_h=72, row_gap=28, head=24, lane=20):
        self.col_w = (width - 3 * col_gap) / 4.0
        self.col_gap, self.corridor, self.tile_h, self.row_gap, self.head, self.lane = col_gap, corridor, tile_h, row_gap, head, lane
        self.tile_w = (self.col_w - corridor) / 2.0
        self.top = head + 16
        self.slots = {}
        for i, (fam, root, *_r) in enumerate(FAMS):
            cx = i * (self.col_w + col_gap)
            self.slots[root] = (cx + (self.col_w - self.tile_w) / 2, self.row_y(0))
            for j, b in enumerate(CHILD[root]):
                bx = cx if j == 0 else cx + self.tile_w + corridor
                self.slots[b] = (bx, self.row_y(1))
                for c in CHILD[b]:
                    self.slots[c] = (bx, self.row_y(2))
        self.bottom = self.row_y(2) + tile_h
        self.detail_top = self.bottom + lane

    def row_y(self, r):
        return self.top + r * (self.tile_h + self.row_gap)

    def col_x(self, fam):
        return [f[0] for f in FAMS].index(fam) * (self.col_w + self.col_gap)


# Window body geometry (Ar-Ge): the tree sits 16 px in; the card strip is 286 px (fits the assignment panel); the
# footer carries the tree key (today's game keeps it there). The window's height follows its content (SPEC §9).
TREE_TOP = 16
DETAIL_H = 286
FOOT_H = 40
HEAD_CTL = 130          # 2 border + 72 head + 56 control strip


def body_h(selected):
    g = Geo()
    return TREE_TOP + (g.detail_top + DETAIL_H if selected else g.bottom + 8) + 16 + FOOT_H


def tile(g, nid, st, selected=False, progress=0):
    x, y = g.slots[nid]
    style = "left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%dpx" % (x, y, g.tile_w, g.tile_h)
    if st == "locked":
        area = C(AREA_KEY[FAM_AREA[FAMILY_OF[nid]]])
        return '<div class="rn is-locked" style="%s"><span class="lk">%s</span></div>' % (style, C("RND_LOCKED_SLOT", area=area))
    cls = {"done": "is-done", "active": "is-active", "frozen": "is-frozen", "available": "is-available"}[st]
    if selected:
        cls += " is-selected"
    right = ""
    if st == "done":
        right = '<span class="ok">%s</span>' % ic("check")
    cap = tier_caption(nid)
    if nid in CROSS:
        # the row already says "continuation"; the cross mark takes the tier word's place so it fits in EN too
        cap = '<span class="x" style="margin-left:0">%s%s</span>' % (ic("chevleft"), C(AREA_KEY[FAM_AREA[FAMILY_OF[CROSS[nid]]]]))
    if st == "frozen":
        word = C("RND_TIER_FROZEN", tier="").replace(" · ", "")
        cap = '%s · <span class="fz">%s%s</span>' % (cap, ic("pause"), word)
    bar = ""
    if st in ("active", "frozen"):
        bar = '<div class="rp"><i style="width:%d%%"></i></div>' % progress
    return ('<div class="rn %s" style="%s"><div class="hd"><span class="t">%s</span></div><div class="ft">%s<span>%s</span>%s</div>%s</div>'
            % (cls, style, nname(nid), hexsvg(TIER[nid]), cap, right, bar))


def guide_path(g, nid):
    """Selected tile -> its family's corridor -> the card strip. A branch tile leaves by the side that faces the
    corridor, so the guide never runs over the tile's own edge to its child; a continuation leaves by its foot."""
    sx, sy = g.slots[nid]
    corridor = g.col_x(FAMILY_OF[nid]) + g.col_w / 2
    if TIER[nid] == "branch":
        side = sx + g.tile_w if sx + g.tile_w / 2 < corridor else sx
        y0 = sy + g.tile_h / 2
        return "M%.1f %.1f L%.1f %.1f L%.1f %.1f" % (side, y0, corridor, y0, corridor, g.detail_top)
    scx = sx + g.tile_w / 2
    if TIER[nid] == "root":       # the root sits over the corridor: run 6 px beside its own trunk
        return "M%.1f %.1f L%.1f %.1f" % (scx + 6, sy + g.tile_h, scx + 6, g.detail_top)
    lane = g.bottom + g.lane * 0.35
    return "M%.1f %.1f L%.1f %.1f L%.1f %.1f L%.1f %.1f" % (scx, sy + g.tile_h, scx, lane, corridor, lane, corridor, g.detail_top)


def tree(g, states, selected=None, progress=36, detail_html=""):
    out = []
    for fam, root, area, fkey, akey in FAMS:
        x = g.col_x(fam)
        done = sum(1 for n, s in states.items() if FAMILY_OF.get(n) == fam and s == "done")
        fam_name = C(fkey)
        area_name = C(akey)
        a = "" if area_name.upper().replace("İ", "I") == fam_name.replace("İ", "I") or (LANG == "tr" and area_name == "Tasarım") \
            else '<span class="a t-caption">%s</span>' % C("RND_AREA_OF", area=area_name)
        out.append('<div class="rcol-h" style="left:%.1fpx;top:0;width:%.1fpx"><span class="f t-group">%s</span>%s<span class="n t-caption">%d/5</span></div>'
                   % (x, g.col_w, fam_name, a, done))
    for nid in g.slots:
        out.append(tile(g, nid, states.get(nid, "locked"), nid == selected, progress))
    # edges: drawn under the tiles; solid when the child is revealed, dashed while it is a locked slot
    lines = []

    def ln(a, b, child):
        cls = "re" if states.get(child, "locked") != "locked" else "re is-locked"
        lines.append('<path class="%s" d="M%.1f %.1f L%.1f %.1f"/>' % (cls, a[0], a[1], b[0], b[1]))

    for fam, root, *_r in FAMS:
        rx, ry = g.slots[root]
        rcx, rby = rx + g.tile_w / 2, ry + g.tile_h
        mid = rby + g.row_gap / 2
        for b in CHILD[root]:
            bx, by = g.slots[b]
            bcx = bx + g.tile_w / 2
            ln((rcx, rby), (rcx, mid), b)
            ln((rcx, mid), (bcx, mid), b)
            ln((bcx, mid), (bcx, by), b)
            for c in CHILD[b]:
                cx, cy = g.slots[c]
                ln((bcx, by + g.tile_h), (bcx, cy), c)
    if selected:
        lines.append('<path class="re-guide" d="%s"/>' % guide_path(g, selected))
    h = g.detail_top + DETAIL_H if selected else g.bottom
    svg = '<svg width="%d" height="%d">%s</svg>' % (1230, h, "".join(lines))
    det = ""
    if selected and detail_html:
        fi = [f[0] for f in FAMS].index(FAMILY_OF[selected])
        x = g.col_x(FAMS[min(fi, 2)][0])
        det = ('<div class="rdp" style="left:%.1fpx;top:%.1fpx;width:%.1fpx;height:%dpx">%s</div>'
               % (x, g.detail_top, 2 * g.col_w + g.col_gap, DETAIL_H, detail_html))
    return '<div class="tree" style="top:%dpx">%s%s%s</div>' % (TREE_TOP, svg, "".join(out), det)


def legend_foot():
    """The tree key in the window's foot (where today's game draws it); the tree hint closes the row."""
    sw = {
        "intra": '<svg width="22" height="12"><line x1="0" y1="6" x2="22" y2="6" stroke="var(--line-3)" stroke-width="1.5"/></svg>',
        "cross": '<svg width="22" height="12"><line x1="0" y1="6" x2="22" y2="6" stroke="var(--ink-4)" stroke-width="1.5" stroke-dasharray="2 4"/></svg>',
        "locked": '<svg width="22" height="12"><rect x="0.5" y="0.5" width="21" height="11" rx="2" fill="none" stroke="var(--line-2)" stroke-dasharray="3 3"/></svg>',
        "available": '<svg width="22" height="12"><rect x="0.5" y="0.5" width="21" height="11" rx="2" fill="var(--surface-3)" stroke="var(--line-hover)"/></svg>',
        "done": '<svg width="22" height="12"><rect x="0.5" y="0.5" width="21" height="11" rx="2" fill="var(--surface-5)" stroke="var(--line-3)"/></svg>',
    }
    keys = [("intra", "RND_LEGEND_INTRA"), ("cross", "RND_LEGEND_CROSS"), ("locked", "RND_LEGEND_LOCKED"),
            ("available", "RND_LEGEND_AVAILABLE"), ("done", "RND_LEGEND_DONE")]
    items = "".join('<span class="it t-caption">%s%s</span>' % (sw[k], C(t)) for k, t in keys)
    return '<div class="rfoot">%s<span class="hint t-caption">%s</span></div>' % (items, C("RND_TREE_HINT"))


def tree_body(states, selected=None, detail_html=""):
    return tree(Geo(), states, selected, detail_html=detail_html) + legend_foot()


def faces(*keys, cls=""):
    return '<span class="faces">%s</span>' % "".join(common.avatar(BUST[k], 24, cls) for k in keys)


def prog(p, cls=""):
    return ('<div class="prog %s"><div class="prog-t"><div class="prog-f" style="width:%d%%"></div></div><span class="prog-v">%s</span></div>'
            % (cls, p, pct(p)))


def weeks_left(n):
    return C("RND_WEEKS_LEFT_ONE" if n == 1 else "RND_WEEKS_LEFT", n=n)


def rnd_links(paused=False, disabled=False, hover=None, el="span", why=True):
    """The research actions as the game draws them (RND_BAR_PAUSE, RND_ASSIGN_TITLE as written): kabuk's .rb-ft links.
    A paused research has no pause link (research_bar.gd: _pause_link.visible = not m.paused). While a decision waits
    the links are off; on the float they carry the gate's reason (kabuk's held Ofisi taşı does the same), inside a
    read-only window its strip already says it."""
    dis = " is-disabled" if disabled else ""
    lk = lambda k, t: '<span class="lk%s%s">%s</span>' % (dis, " is-hover" if hover == k else "", t)
    links = lk("assign", C("RND_ASSIGN_TITLE"))
    if not paused:
        links = lk("pause", C("RND_BAR_PAUSE")) + '<span class="dot">·</span>' + links
    reason = '<span class="why">%s</span>' % T("gate") if (disabled and why) else ""
    return '<%s class="rb-ft">%s%s</%s>' % (el, links, reason, el)


def research_card(state="running", disabled=False, hover=None):
    """kabuk's research card (kabuk/buildhud__durumlar): name + area, progress, the two links. Paused states use
    kabuk's .is-paused (fill line-3, reason ink-2)."""
    st = {"running": weeks_left(2), "frozen_nobody": C("BUILD_BUSY_NOBODY"), "frozen_build": C("RND_PAUSED_BUILD"),
          "none": C("RND_WEEKS_NONE")}[state]
    return ('<div class="float rb%s"><div class="rb-hd">%s<span class="t t-label">%s</span><span class="st">%s</span></div>'
            '<div class="rb-nm"><span class="n">%s</span><span class="a">%s</span></div>%s%s</div>'
            % ("" if state == "running" else " is-paused", ic("arge", 16), C("RND_BAR_TITLE"), st, nname("test_automation"),
               C("RND_AREA_OF", area=C("HR_AREA_QA")), prog(36), rnd_links(state != "running", disabled, hover, "div")))


def rline(state="running", disabled=False):
    """The window's control strip carries the one running research (§5.6: the bar lives in the tab)."""
    nm = nname("test_automation")
    if state == "running":
        st = '<span class="wks t-meta">%s</span>' % weeks_left(2)
        who = faces("selin")
    else:
        st = '<span class="fz t-meta">%s%s</span>' % (ic("pause"), C("BUILD_BUSY_NOBODY"))
        who = ""
    return ('<div class="rline%s">%s<span class="k t-label">%s</span><span class="nm t-body-strong">%s</span>%s%s%s<span class="sep"></span>%s</div>'
            % (" is-frozen" if state != "running" else "", ic("arge", 18, "var(--ink-3)"), C("RND_BAR_TITLE"), nm, who,
               prog(36), st, rnd_links(state != "running", disabled, why=False)))


def arge_ctl(view="tree", research="running", disabled=False, hist_n=5):
    tabs = ('<div class="seg"><span class="seg-tab t-tab%s">%s</span><span class="seg-tab t-tab%s">%s<span class="n">%d</span></span></div>'
            % (" is-active" if view == "tree" else "", N("RND_VIEW_TREE"), " is-active" if view == "history" else "",
               N("RND_VIEW_HISTORY"), hist_n))
    right = rline(research, disabled) if research else ""
    return '<div class="win-ctl">%s<div class="grow"></div>%s</div>' % (tabs, right)


def arge_window(body, ctl, h, ro="", x=208, done=4):
    kpis = ((N("RND_TREE_DONE_KEY"), N("RND_TREE_DONE_VALUE", done=done, total=20)),)
    return window(x, 88, 1280, h, C("TAB_RND"), kpis, "", ro, ctl, body, "flush")


# ------------------------------------------------------------------ node card
def req_parts(nid, solo_weeks=None, cash=0):
    parts = []
    areas = {"ai_engine": ["product"], "semantic_index": ["product"], "scalable_backend": ["engineering"], "cicd": ["qa"],
             "onboarding_flow": ["design"], "accessibility": ["design", "product"], "test_automation": ["qa"]}[nid]
    stars = 1 if TIER[nid] == "root" else 2
    for a in areas:
        parts.append('<span class="req-p">%s<span class="st">%s%d</span></span>' % (C(AREA_KEY[a]), ic("star"), stars))
    if solo_weeks:
        parts.append('<span class="req-p">%s%s</span>' % (ic("clock"), C("RND_WEEKS_SOLO_ONE" if solo_weeks == 1 else "RND_WEEKS_SOLO", n=solo_weeks)))
    if cash:
        parts.append('<span class="req-p">%s%s</span>' % (ic("cost"), num("$%d" % cash)))
    return '<div class="rdp-req">%s</div>' % "".join(parts)


def card_head(nid, st):
    fam = C([f[3] for f in FAMS if f[0] == FAMILY_OF[nid]][0])
    done = ('<span class="done t-meta">%s</span>' % ic("check")) if st == "done" else ""
    return ('<div class="rdp-h"><span class="t t-subhead">%s</span>%s<span class="m t-micro">%s</span></div>'
            % (nname(nid), done, C("RND_NODE_META", family=fam, tier=tier_caption(nid))))


def card_available(nid, solo_weeks, cash=0, switch=True, readonly=False):
    h = [card_head(nid, "available"),
         '<div class="rdp-desc">%s</div>' % C("PROD_RND_NODE_%s_DESC" % nid.upper()),
         '<div class="rdp-kv"><span class="k t-label">%s</span><span class="v">%s</span></div>'
         % (C("RND_UNLOCKS_PREFIX").rstrip(":"), C("PROD_RND_NODE_%s_UNLOCK" % nid.upper())),
         req_parts(nid, solo_weeks, cash)]
    if switch:
        h.append('<div class="rdp-line">%s%s</div>' % (ic("info"), N("RND_SWITCH_NOTE", node=nname("test_automation"))))
    if readonly:
        h.append('<div class="rdp-acts"><span class="locked"><span class="why t-data">%s</span>'
                 '<span class="btn btn-primary is-disabled">%s</span></span></div>' % (T("blocked_reason"), C("RND_START")))
    else:
        h.append('<div class="rdp-acts"><span class="btn btn-primary">%s</span></div>' % C("RND_START"))
    return "".join(h)


def check(on):
    return '<span class="check%s"><span class="check-box">%s</span></span>' % (" is-on" if on else "", ic("check"))


def asg_row(key, name, role_line, v, picked=False, away_weeks=0):
    """One assignee: check, face, name (+ İzinde tag and weeks left on a leave row), role · task, the area skill in a
    fixed number column. A leave row: grey face, name ink-3, numbers unchanged (SPEC §5)."""
    av = common.avatar(FOUNDER if key == "founder" else BUST[key], 24, "is-grey" if away_weeks else "")
    leave = ""
    if away_weeks:
        leave = '%s<span class="left">%s</span>' % (tag(T("st_leave"), "neutral"), T("weeks_n", n=away_weeks))
    cls = "asg-r" + (" is-selected" if picked else "") + (" is-away" if away_weeks else "")
    return ('<div class="%s">%s<span>%s</span><div class="wholine"><span class="who"><span class="n">%s</span></span>%s'
            '<span class="rl">%s</span></div><div class="sk v%d">%d</div></div>'
            % (cls, check(picked), av, name, leave, role_line, kit.band_of(v), v))


def asg_group(area_key, n, met):
    chip = tag(C("RND_REQ_MET"), "neutral") if met else tag(C("RND_REQ_UNMET"), "warn")
    return ('<div class="asg-g t-group">%s<span>%s</span><span class="n">%s</span>%s</div>'
            % (ic("chevdown", 16, cls="tw"), C(area_key), C("PROD_TEAM_GROUP_COUNT", n=n), chip))


# ================================================================== Kişisel
SKILLS = [("product", "sk_product", "HR_AREA_PRODUCT", 2), ("design", "sk_design", "HR_AREA_DESIGN", 0),
          ("engineering", "sk_eng", "HR_AREA_ENGINEERING", 4), ("qa", "sk_qa", "HR_AREA_QA", 0),
          ("sales", "sk_sales", "HR_AREA_SALES", 4), ("customer_success", "sk_cs", "HR_AREA_CUSTOMER_SUCCESS", 0)]
EXTRA = [("HR_AREA_LEADERSHIP", 0), ("PER_CHARISMA", 2)]


def meter(v):
    cells = []
    for p in range(5):
        cells.append('<span class="p">%s</span>' % "".join('<i class="%s"></i>' % ("on" if p * 2 + k < v else "") for k in range(2)))
    return '<span class="meter v%d">%s</span>' % (kit.band_of(v), "".join(cells))


def skill_row(icon, label, v):
    return ('<div class="fsk-r"><span>%s</span><span class="l t-label">%s</span>%s<span class="v v%d">%d</span></div>'
            % (ic(icon) if icon else "", label, meter(v), kit.band_of(v), v))


def milestones(ship_week=6, invest=None):
    rows = [("MILESTONE_FOUNDING", True, month_year(1), "PERSONAL_MS_FOUNDING_NOTE"),
            ("MILESTONE_FIRST_SHIP", ship_week is not None, month_year(ship_week) if ship_week else "", "PERSONAL_MS_SHIP_NOTE"),
            ("MILESTONE_FIRST_FUNDING", invest is not None, invest or "", "PERSONAL_MS_FUNDING_NOTE")]
    out = []
    for key, earned, meta, note in rows:
        note_txt = (N(note) if note in NEW else C(note)) if earned else ""
        out.append('<div class="ms-r%s"><span class="ms-dot">%s</span><div class="ms-t"><div class="n">%s</div></div><span class="ms-m">%s</span>%s</div>'
                   % ("" if earned else " is-off", ic("milestone") if earned else "", C(key), meta,
                      ('<div class="d">%s</div>' % note_txt) if note_txt else ""))
    return '<div class="ms">%s</div>' % "".join(out)


def phases(on=1):
    names = [N("PHASE_NAME_BOOTSTRAP"), N("PHASE_NAME_TRACTION"), N("PHASE_NAME_SERIES_A_HUNT")]
    rows = "".join('<div class="phl-r%s"><i></i>%s</div>' % (" is-on" if i == on else "", n) for i, n in enumerate(names, 1))
    return ('<div class="phl">%s</div><div class="goalbox"><div class="k t-label">%s</div><div class="v">%s</div></div>'
            % (rows, C("PER_PHASE_GOAL"), C("PER_GOAL_BOOTSTRAP")))


def net_worth(founder=100, angel=0):
    bar = '<span class="f" style="flex:%d"></span>' % founder + (('<span class="o" style="flex:%d"></span>' % angel) if angel else "")
    lg = '<span>%s</span>' % C("PER_CAP_FOUNDER", pct=founder).replace("%%%d" % founder, "<b>%%%d</b>" % founder).replace("%d%%" % founder, "<b>%d%%</b>" % founder)
    if angel:
        a = C("ANGEL_CAP_ROW", pct=angel)
        lg += '<span>%s</span>' % a.replace("%%%d" % angel, "<b>%%%d</b>" % angel).replace("%d%%" % angel, "<b>%d%%</b>" % angel)
    return ('<div class="capbar">%s</div><div class="caplg">%s</div><div class="nw-note">%s</div>'
            % (bar, lg, N("PER_NO_VALUATION")))


def kisisel_window(x=208, angel=0):
    left = ('<div class="per-col">%s<div class="per-task"><span class="k t-label">%s</span><span class="v">%s</span></div>'
            '<div class="per-task" style="margin-top:12px"><span class="k t-label">%s</span>'
            '<div class="per-xp"><div class="prog-t"><div class="prog-f" style="width:0"></div></div><span class="prog-v">%s</span></div></div>'
            '<div style="margin-top:20px"><span class="btn btn-secondary">%s%s</span></div></div>'
            % (common.portrait(FOUNDER, 256, 320), C("PER_TASK_LABEL"), C("HR_TASK_ON_JOB_BUILD"),
               C("PER_EXPERIENCE"), pct(0), ic("training"), C("HR_TRAINING_PICK_TITLE")))
    sk = "".join(skill_row(icn, C(k), v) for _a, icn, k, v in SKILLS)
    sk += '<div class="fsk-sep"></div>' + "".join(skill_row(None, C(k), v) for k, v in EXTRA)
    mid = ('<div class="per-col"><h2 class="per-name t-h2">%s</h2>'
           '<div class="per-origin">%s</div><div class="per-quote">%s</div>'
           '<div class="sec t-label" style="margin-top:24px">%s</div><div class="fsk">%s</div>'
           '<div class="sec t-label" style="margin-top:20px">%s%s</div><div class="trslots">%s</div></div>'
           % (C("HR_ROLE_FOUNDER"), tag(C("ONB_ORIGIN_SELF_MADE_NAME"), "outline"), C("ONB_ORIGIN_SELF_MADE_QUOTE"),
              C("ONB_SKILLS_HEADER"), sk, C("PER_TRAITS"), tag(C("SYS_SOON"), "outline"), '<span class="trslot"></span>' * 8))
    right = ('<div class="per-col"><div class="sec t-label">%s</div>%s'
             '<div class="sec t-label" style="margin-top:24px">%s</div>%s'
             '<div class="sec t-label" style="margin-top:24px">%s</div>%s</div>'
             % (C("PERSONAL_MILESTONES_TITLE"), milestones(), C("PER_WHERE_AM_I"), phases(), C("PER_NET_WORTH"),
                net_worth(100 - angel, angel)))
    body = '<div class="per">%s%s%s</div>' % (left, mid, right)
    kpis = ((N("PER_TENURE_KEY"), N("PER_TENURE_VALUE", n=14)),)
    return window(x, 88, 1000, 680, C("TAB_PERSONAL"), kpis, "", "", "", body, "flush")


def f_kisisel():
    return screen(kb.topbar(), rail("kisisel"), kisisel_window(), research=research_card())


def f_kisisel_frank():
    return screen(kb.topbar(kb.V_CHEQUE), rail("kisisel"), kisisel_window(angel=4), research=research_card())


def f_kisisel_1536():
    """The window spans x 88-1088, y 88-768: BuildHUD (1192), the research card and the stack (1160) stay clear of it;
    Ofisi taşı (88, 756) is under it and hides."""
    return screen(kb.topbar(W=1536, compact=True), rail("kisisel", icons=True), kisisel_window(x=88), research=research_card(),
                  move=None, W=1536, H=864)


# ================================================================== Ar-Ge frames
def f_agac():
    win = arge_window(tree_body(W14), arge_ctl(), body_h(False) + HEAD_CTL)
    return screen(kb.topbar(), rail("arge"), win, research=research_card())


def f_detay(readonly=False):
    card = card_available("ai_engine", 7, 600, readonly=readonly)
    body = tree_body(W14, "ai_engine", card)
    h = body_h(True) + HEAD_CTL
    if readonly:
        win = arge_window(body, arge_ctl(disabled=True), h + 40, ro=ro_strip("Frank Köseoğlu · %s" % L("Teklif", "An offer")))
        return screen(kb.topbar(slot=("gate", "Frank Köseoğlu")), rail("arge", badges(olaylar=("gate", ""))), win,
                      research=research_card(disabled=True), move="held")
    return screen(kb.topbar(), rail("arge"), arge_window(body, arge_ctl(), h), research=research_card())


def f_atama():
    head = card_head("ai_engine", "available")
    task = C("HR_TASK_ON_JOB_BUILD")
    rows = (asg_row("founder", C("HR_ROLE_FOUNDER"), task, 2)
            + asg_row("elif", "Elif Demir", "%s · %s" % (T("r_pm"), task), 7, picked=True)
            + asg_row("deniz", "Deniz Arslan", "%s · %s" % (T("r_design"), task), 5))
    foot = ('<div class="asg-f"><span class="est">%s<span class="k">%s</span><span>·</span><span>%s</span></span><div class="grow"></div>'
            '<span class="btn btn-ghost">%s</span><span class="btn btn-primary">%s</span></div>'
            % (ic("clock", 16, "var(--ink-3)"), C("RND_AREA_OF", area=C("HR_AREA_PRODUCT")), C("RND_WEEKS_EST", n=2),
               up1(C("RND_ACTION_BACK")), C("RND_START")))
    sw = '<div class="rdp-line">%s%s</div>' % (ic("info"), N("RND_SWITCH_NOTE", node=nname("test_automation")))
    card = head + '<div class="asg">%s%s</div>%s%s' % (asg_group("HR_AREA_PRODUCT", 3, True), rows, sw, foot)
    win = arge_window(tree_body(W14, "ai_engine", card), arge_ctl(), body_h(True) + HEAD_CTL)
    return screen(kb.topbar(), rail("arge"), win, research=research_card())


def f_donmus():
    """Branch B (olaylar's departure frames): Selin left at week 14, the research froze at 36 %."""
    head = card_head("test_automation", "frozen")
    rows = (asg_row("founder", C("HR_ROLE_FOUNDER"), C("HR_TASK_ON_JOB_BUILD"), 0)
            + asg_row("mert", "Mert Yıldız", T("r_dev"), 7, away_weeks=1))
    star = '<span class="st">%s2</span>' % ic("star", 14)
    refusal = C("RND_NEED_AREA", area=C("HR_AREA_QA"), stars="★2").replace("★2", star)
    foot = ('<div class="asg-f"><span class="est">%s<span class="k">%s</span><span>·</span><span>%s</span></span><div class="grow"></div>'
            '<span class="btn btn-ghost">%s</span><span class="btn btn-primary is-disabled">%s</span></div>'
            '<div class="asg-why"><span class="away">%s</span><span class="sep"></span><span class="need">%s</span></div>'
            % (ic("clock", 16, "var(--ink-3)"), C("RND_AREA_OF", area=C("HR_AREA_QA")), C("RND_WEEKS_NONE"),
               up1(C("RND_ACTION_BACK")), up1(C("RND_ACTION_APPLY")), N("RND_NEED_AREA_AWAY", name="Mert Yıldız"), refusal))
    card = head + '<div class="asg">%s%s</div>%s' % (asg_group("HR_AREA_QA", 2, False), rows, foot)
    body = tree(Geo(), W15_FROZEN, "test_automation", detail_html=card) + legend_foot()
    win = arge_window(body, arge_ctl(research="frozen"), body_h(True) + HEAD_CTL)
    top = kb.topbar(v15(), slot=("next", T("next_end"), ""), speed="1x", week=15, marks=())
    return screen(top, rail("arge", badges(arge=2, ekip=False)), win, research=research_card("frozen_nobody"),
                  notices=inbox_h15())


DISC = {
    "design_system": ("deniz", 8), "user_research": ("deniz", 10), "data_model": ("elif", 11), "bug_tracker": ("selin", 13),
    "test_automation": ("selin", 16),
}
WHO = {"elif": ("Elif Demir", "r_pm"), "deniz": ("Deniz Arslan", "r_design"), "selin": ("Selin Kaya", "r_qa")}


def disc_mail(nid):
    k, wk = DISC[nid]
    name, role = WHO[k]
    beat = C("PROD_RND_NODE_%s_DISCOVERY" % nid.upper())
    return mg.M(frm=name, role=T(role), av=common.avatar(BUST[k], 40), well=BUST[k], topic="product", kind="k_disc", week=wk,
                subject=nname(nid), body=[beat], sig=(name, "%s · Unicorn Inc." % T(role)), to=mg.s("founder_to"),
                preview=beat.split(". ")[0] + ".")


def disc_pane(nid, acts):
    m = disc_mail(nid)
    unlock = C("PROD_RND_NODE_%s_UNLOCK" % nid.upper())
    box = '<div class="disc-box"><div class="k t-label">%s</div><p>%s</p>' % (C("RND_UNLOCKS_PREFIX").rstrip(":"), unlock)
    kids = CHILD.get(nid, [])
    if len(kids) == 1:
        box += '<p>%s</p>' % C("RND_COMPLETED_UNLOCKED_ONE", node=nname(kids[0]))
    elif len(kids) == 2:
        box += '<p>%s</p>' % C("RND_COMPLETED_UNLOCKED_TWO")
    line_key = HIDDEN_LINE.get(nid)
    if line_key and C(line_key) not in unlock:   # the unlock text already names the line: no second row saying it
        pre, _sep, nm = C("RND_HIDDEN_LINE_OPENED", line=C(line_key)).partition(": ")
        box += '<div class="line">%s<span>%s:</span><b>%s</b></div>' % (ic("sparkle", 16, "var(--ink-3)"), pre, nm)
    box += "</div>"
    return mg.pane(m, acts, extra_body=box)


def r_disc(nid, cls=""):
    return mg.r_mail(disc_mail(nid), cls, ic("sparkle") + N("MAIL_ROW_DISCOVERY"))


def r_note(cls="is-unread"):
    return mg.r_mail(mg.mails()["rnd"], cls, ic("doc") + L("rapor", "report"))


def f_gecmis():
    mm = mg.mails()
    rows = (mg.r_day(14) + r_note("is-unread is-selected") + mg.r_day(13) + r_disc("bug_tracker") + mg.r_day(11) + r_disc("data_model")
            + mg.r_day(10) + r_disc("user_research") + mg.r_day(8) + r_disc("design_system"))
    acts = '<div class="reply"><div class="reply-acts"><span class="btn btn-secondary">%s</span></div></div>' % C("RND_NOTE_GO_PRODUCT")
    pane = mg.pane(mm["rnd"], acts)
    body = '<div class="ib hist" style="height:100%%"><div class="ib-list">%s</div>%s</div>' % (rows, pane)
    win = arge_window(body, arge_ctl(view="history"), 780)
    return screen(kb.topbar(), rail("arge"), win, research=research_card())


# The H16 inbox, newest first, from the one timeline (INDEX.md): attention rows on top (olaylar grammar), then the days.
# Rows are 96 px, day bars 28; the list scrolls under its 44 px filter head.
def kesif_rows(mm):
    return [(mg.r_notice("ege"), 96), (mg.r_notice("selin"), 96),
            (mg.r_day(16), 28), (r_disc("test_automation", "is-unread is-selected"), 96),
            (mg.r_day(15), 28), (mg.r_mail(mm["weekly"], "", ic("doc") + L("rapor", "report")), 96),
            (mg.r_day(14), 28), (mg.r_history(mm["offer"], T("answered_stamp"), T("accept")), 96), (r_note(""), 96),
            (mg.r_report(mm["summary"]), 96),
            (mg.r_day(13), 28), (r_disc("bug_tracker"), 96), (mg.r_day(11), 28), (r_disc("data_model"), 96),
            (mg.r_day(10), 28), (r_disc("user_research"), 96), (mg.r_day(8), 28), (r_disc("design_system"), 96),
            (mg.r_day(1), 28), (mg.r_intro(mm["intro"]), 96)]


def f_kesif_inbox():
    mm = mg.mails()
    acts = ('<div class="reply"><div class="reply-acts"><span class="btn btn-secondary">%s</span><span class="btn btn-secondary">%s</span></div></div>'
            % (C("RND_NOTE_GO_TREE"), C("RND_NOTE_GO_PRODUCT")))
    p = disc_pane("test_automation", acts)
    rows = kesif_rows(mm)
    content = sum(h for _r, h in rows)
    view = 900 - 2 - 72 - 44
    track = view - 16
    sb = ('<div class="sb" style="right:2px;top:52px;height:%dpx"><div class="sb-thumb" style="top:0;height:%dpx"></div></div>'
          % (track, round(track * view / content)))
    n_items = sum(1 for _r, h in rows if h == 96)
    win = mg.olay_window("".join(r for r, _h in rows) + sb, p, (n_items, 0, 1))
    top = kb.topbar(v16(), slot=("next", T("next_end"), ""), speed="1x", week=16, marks=())
    # the window (88-988) reaches Ofisi taşı's rect (972): the button hides
    return screen(top, rail("olaylar", badges(arge=0)), win, notices=inbox_h16(), move=None)


def f_kesif_ofis():
    top = kb.topbar(v16(), slot=("next", T("next_end"), ""), speed="1x", week=16, marks=())
    return screen(top, rail(None, badges(arge=0)), "", dim=False, notices=inbox_h16(discovery=True))


def f_cubuk_ofis():
    return screen(kb.topbar(), rail(None), "", dim=False, research=research_card())


def f_kapali():
    body = '<div class="wait">%s<span class="t t-body">%s</span></div>' % (ic("arge", 32), C("RND_TREE_CLOSED"))
    win = window(208, 88, 1280, 320, C("TAB_RND"), (), "", "", "", body, "flush")   # height follows content (SPEC §9)
    top = kb.topbar(kb.V_WEEK1, slot=("next", L("Mesai bitimi · 7 saat", "Workday ends · 7 h"), ""), week=1, clock=10, marks=())
    return screen(top, rail("arge", {}), win, office="home", hud=False, notices=None)


def f_arge_1536():
    """1536: the window (88-1368 × 88-800) covers BuildHUD (1192), the stack and Ofisi taşı: all hide. The body scrolls
    above the fixed foot."""
    g = Geo()
    card = card_available("ai_engine", 7, 600)
    view = 712 - HEAD_CTL - FOOT_H
    content = TREE_TOP + g.detail_top + DETAIL_H + 16
    track = view - 16
    body = ('<div style="position:absolute;left:0;right:0;top:0;height:%dpx;overflow:hidden">%s</div>'
            '<div class="sb" style="right:4px;top:8px;height:%dpx"><div class="sb-thumb" style="top:0;height:%dpx"></div></div>%s'
            % (view, tree(g, W14, "ai_engine", detail_html=card), track, round(track * view / content), legend_foot()))
    win = arge_window(body, arge_ctl(), 712, x=88)
    return screen(kb.topbar(W=1536, compact=True), rail("arge", icons=True), win, hud=False, notices=None, move=None,
                  W=1536, H=864)


def f_parcalar():
    """Parts sheet (no shell): the research card in every state, the control-strip line, the tile states."""
    out = []
    cap = lambda x, y, t: '<div class="cap t-label" style="left:%dpx;top:%dpx">%s</div>' % (x, y, t)
    note = lambda x, y, w, t: '<div class="note" style="left:%dpx;top:%dpx;width:%dpx">%s</div>' % (x, y, w, t)
    out.append('<div style="position:absolute;left:48px;top:36px"><span class="t-h2" style="color:var(--ink-1)">%s</span>'
               '<span class="t-meta" style="margin-left:16px;color:var(--ink-3)">%s</span></div>'
               % (L("Ar-Ge parçaları", "R&amp;D parts"), L("araştırma kartı, pencere şeridi, düğüm durumları · 1:1", "research card, strip, node states · 1:1")))
    states = [(dict(state="running", hover="assign"), L("Sürüyor (ata üstünde)", "Running (hover on assign)")),
              (dict(state="frozen_nobody"), L("Donmuş · kimse yok", "Frozen · nobody on it")),
              (dict(state="frozen_build"), L("Donmuş · ekip yapımda", "Frozen · team on a build")),
              (dict(state="none"), L("Atanmış, katkı yok", "Assigned, no contribution")),
              (dict(state="running", disabled=True), L("Karar beklerken", "While a decision waits"))]
    for i, (kw, lbl) in enumerate(states):
        x = 48 + i * 352
        out.append(cap(x, 112, lbl))
        out.append('<div style="position:absolute;left:%dpx;top:140px">%s</div>' % (x, research_card(**kw)))
    out.append(note(48, 300, 1700, L(
        "Kart kabuğun bileşenidir (kabuk/buildhud__durumlar, kabuk.css .rb): ad + alan, ilerleme, oyunun iki bağı (duraklat · ata). "
        "Duraklamış hallerde dolgu line-3, gerekçe ink-2. Atanan herkes izinde ya da eğitimdeyse hafta tahmini yerine \"katkı yok\" (RND_WEEKS_NONE). "
        "Karar beklerken bağlar kapalı, gerekçe \"Cevap bekliyor\" (kabuğun tutulan Ofisi taşı düğmesi gibi; kabuk soru 19).",
        "The card is the shell's component (kabuk/buildhud__durumlar, kabuk.css .rb): name + area, progress, the game's two links (pause · assign). "
        "Paused states fill line-3 with the reason in ink-2. With everyone on leave or in training no week figure is printed: \"no contribution\" (RND_WEEKS_NONE). "
        "While a decision waits the links are off with the reason \"Answer needed\" (like the shell's held move button; kabuk question 19).")))
    out.append(cap(48, 372, L('<span lang="en">BuildHUD</span> ile birlikte (1920, sağ üst)', "With BuildHUD (1920, top right)")))
    out.append('<div class="floatcol" style="left:48px;top:400px">%s%s</div>' % (kb.buildhud(0, 0, "seed").replace("float bh abs", "float bh"), research_card()))
    out.append(cap(424, 372, L("Pencere şeridindeki satır (Ar-Ge kontrol şeridi)", "The line in the window's control strip")))
    out.append('<div class="win" style="position:absolute;left:424px;top:400px;width:1280px;height:58px;box-shadow:none">%s</div>' % arge_ctl())
    out.append('<div class="win" style="position:absolute;left:424px;top:476px;width:1280px;height:58px;box-shadow:none">%s</div>' % arge_ctl(research="frozen"))
    out.append(cap(424, 560, L("Düğüm durumları", "Node states")))
    g = Geo()
    tw, th = g.tile_w, g.tile_h
    demo = [("done", "design_system", L("Bitti", "Done")), ("active", "test_automation", L("Sürüyor", "Running")),
            ("frozen", "test_automation", L("Donmuş", "Frozen")), ("available", "ai_engine", L("Araştırılabilir", "Can be researched")),
            ("available_sel", "ai_engine", L("Seçili", "Selected")), ("locked", "edge_inference", L("Kilitli yuva", "Locked slot")),
            ("cross", "self_service", L("Başka aileden gereksinim", "Needs another family"))]
    for i, (st, nid, lbl) in enumerate(demo):
        x = 424 + i * 176
        g.slots = {nid: (0, 0)}
        real = {"available_sel": "available", "cross": "available"}.get(st, st)
        t = tile(g, nid, real, selected=(st == "available_sel"), progress=36)
        out.append('<div class="t-caption" style="position:absolute;left:%dpx;top:588px;color:var(--ink-3)">%s</div>' % (x, lbl))
        out.append('<div style="position:absolute;left:%dpx;top:612px;width:%.0fpx;height:%dpx">%s</div>' % (x, tw, th, t))
    out.append(note(424, 708, 1400, L(
        "Altıgen düğümün kimliği: çizgi kalınlığı mertebeyi taşır (kök 2, dal 1,5, devam 1); aile rengi yok. Amber yok: araştırma bir zaman durumu değil. "
        "Donmuş düğüm kesik kenar, duraklat glifi ve \"donmuş\" sözcüğüyle (ink-2; kartın duraklamış haliyle aynı). "
        "Seçili düğüm mürekkep ve 3 px imle; kılavuz çizgisi ink-2, dal düğümünden koridora bakan yanından çıkar. "
        "Çapraz işaret (RND_CROSS_MARK) util/chevron_left ikonuyla; glifinin yüzü yok (SPEC §3.1).",
        "The hexagon is the node's identity: stroke weight carries the tier (root 2, branch 1.5, continuation 1); no family colour. No amber: research is not a time state. "
        "A frozen node has a dashed edge, the pause glyph and the word \"frozen\" (ink-2, as the card's paused state). "
        "The selected node is ink with the 3 px marker; the guide line is ink-2 and leaves a branch tile by the side facing the corridor. "
        "The cross mark (RND_CROSS_MARK) uses util/chevron_left, its glyph has no face (SPEC §3.1).")))
    out.append(cap(48, 780, L("Ar-Ge sekmesinin geçmişi boşken", "R&amp;D history before anything happened")))
    out.append('<div class="win" style="position:absolute;left:48px;top:808px;width:400px;height:200px;box-shadow:none;background:var(--surface-2)">'
               '<div class="empty" style="height:100%%">%s<span class="empty-t">%s</span></div></div>' % (ic("history"), N("RND_HISTORY_EMPTY")))
    out.append(cap(480, 780, L("Ağacın ayağı (anahtar + ipucu)", "The tree's foot (key + hint)")))
    out.append('<div class="win" style="position:absolute;left:480px;top:808px;width:1280px;height:42px;box-shadow:none">%s</div>' % legend_foot())
    return '<div class="sheet">%s</div>' % "".join(out)


# ================================================================== Pazarlama
def f_pazarlama():
    """Harness-only surface: no build opens it (the rail row is locked); --tab-shot=marketing draws it."""
    body = ('<div class="wait">%s<span class="t t-body-strong">%s</span></div>' % (ic("pazarlama", 32), C("WIN_PAGE_PLACEHOLDER")))
    win = window(208, 88, 720, 400, C("TAB_MARKETING"), (), "", "", "", body, "flush")
    win = win.replace('</h1>', '</h1>%s' % tag(C("SYS_SOON"), "outline"), 1)
    return screen(kb.topbar(), rail(None), win, research=research_card())


FRAMES = {
    "kisisel__normal": ("tr", f_kisisel, (1920, 1080)),
    "kisisel__normal_en": ("en", f_kisisel, (1920, 1080)),
    "kisisel__frank_sonrasi": ("tr", f_kisisel_frank, (1920, 1080)),
    "kisisel__1536": ("tr", f_kisisel_1536, (1536, 864)),
    "arge__agac": ("tr", f_agac, (1920, 1080)),
    "arge__detay": ("tr", f_detay, (1920, 1080)),
    "arge__detay_en": ("en", f_detay, (1920, 1080)),
    "arge__atama": ("tr", f_atama, (1920, 1080)),
    "arge__donmus": ("tr", f_donmus, (1920, 1080)),
    "arge__gecmis": ("tr", f_gecmis, (1920, 1080)),
    "arge__salt_okunur": ("tr", lambda: f_detay(readonly=True), (1920, 1080)),
    "arge__kapali": ("tr", f_kapali, (1920, 1080)),
    "arge__1536": ("tr", f_arge_1536, (1536, 864)),
    "arge__parcalar": ("tr", f_parcalar, (1920, 1080)),
    "olaylar__arge_kesif": ("tr", f_kesif_inbox, (1920, 1080)),
    "ofis__kesif_bildirimi": ("tr", f_kesif_ofis, (1920, 1080)),
    "ofis__arastirma_cubugu": ("tr", f_cubuk_ofis, (1920, 1080)),
    "pazarlama__yer_tutucu": ("tr", f_pazarlama, (1920, 1080)),
}


def build(names):
    global LANG, kb
    os.makedirs(BUILD, exist_ok=True)
    for n in names:
        lang, fn, (W, H) = FRAMES[n]
        LANG = lang
        mg.LANG = lang
        set_lang(lang)
        kb = _load_kabuk()          # any import-time string of kabuk's in the frame language
        html = page(fn(), W, H)
        bad = [c for c in html if c in "–—"]
        if bad:
            sys.exit("dash in %s" % n)
        with open(os.path.join(BUILD, n + ".html"), "w", encoding="utf-8", newline="\n") as f:
            f.write(html)
        print("%s %dx%d" % (n, W, H))
    set_lang("tr")
    mg.LANG = "tr"


if __name__ == "__main__":
    build(sys.argv[1:] or list(FRAMES))
