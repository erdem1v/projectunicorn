"""Onboarding frames (direction C "Sahne"). Writes NN_<state>.html beside this file; render with render_all.sh.
Read-only use of the Menajer system (tokens.css, base.css, modallar.css), the A2 icons (icons.json), the evening home
plate (art/ev_aksam.png, baked by bake_plate.py) and the portraits in docs/mockups/menajer/portraits."""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, "..", "ana_menu", "tools"))
from lockup import lockup  # noqa: E402

MEN = os.path.normpath(os.path.join(HERE, "..", "..")).replace("\\", "/")
ICONS = json.load(open(os.path.join(HERE, "icons.json"), encoding="utf-8"))
PLATE = HERE.replace("\\", "/") + "/art/ev_aksam.png"
FONTS = ("https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700"
         "&family=IBM+Plex+Sans+Condensed:wght@400;500&family=IBM+Plex+Sans:wght@400;500;600;700"
         "&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&display=block")
LANG = "tr"


def url(p):
    return os.path.relpath(p, HERE).replace("\\", "/").replace(" ", "%20")


def L(tr, en):
    return tr if LANG == "tr" else en


def ic(name, size=None):
    st = ' style="width:%dpx;height:%dpx"' % (size, size) if size else ""
    return '<span class="ic"%s>%s</span>' % (st, ICONS["a2:" + name])


def tag(text, kind="outline"):
    return '<span class="tag tag-%s">%s</span>' % (kind, text)


def btn(label, kind="secondary", size="", icon=None, extra=""):
    return '<span class="btn btn-%s%s%s">%s<span>%s</span></span>' % (kind, (" btn-" + size) if size else "", (" " + extra) if extra else "",
                                                                    ic(icon) if icon else "", label)


def money(n):
    s = "{:,}".format(n)
    return "$" + (s.replace(",", ".") if LANG == "tr" else s)


# ------------------------------------------------------------------ fixture (the approved r5 run, founder_05 Deniz)
SEL, NAME, COMPANY = 5, "Deniz", "Unicorn Inc."
FACE = url(MEN + "/portraits/founder_%02d_face64.png" % SEL)
POS, NEG = ("visionary", "disciplined"), ("stubborn",)
ALLOC = (2, 0, 1, 0, 2, 0, 0, 1)
DIFF = [("easy", ("Kolay", "Easy"), 15000, False), ("normal", ("Normal", "Normal"), 10000, False), ("hard", ("Zor", "Hard"), 6000, True)]
DIFF_SEL = "normal"
BURN_MONTH = 1500                       # FinanceSystem.TOOLS_BASE_MONTHLY[1]; runway in months like the top bar

TRAITS_POS = [("visionary", ("Vizyoner", "Visionary"), ("Ar-Ge sıçramaları daha sık", "R&D breakthroughs come more often")),
              ("disciplined", ("Disiplinli", "Disciplined"), ("Geliştirme süreleri kısalır", "Development cycles run shorter")),
              ("networker", ("Ağ kurucu", "Networker"), ("Müşteri adayı kalitesi artar", "Prospect quality improves")),
              ("resilient", ("Dayanıklı", "Resilient"), ("Kriz sonrası hızlı toparlar", "Recovers quickly after a crisis"))]
TRAITS_NEG = [("stubborn", ("İnatçı", "Stubborn"), ("Pivot maliyeti yüksek", "Pivots cost more")),
              ("micromanager", ("Mikro yönetici", "Micromanager"), ("Ekip morali daha hızlı erir", "Team morale erodes faster")),
              ("risk_blind", ("Risk körü", "Risk-Blind"), ("Erken çıkış cazibesi artar", "Early launches tempt harder")),
              ("lone_wolf", ("Yalnız kurt", "Lone Wolf"), ("Mentor etkisi azalır", "Mentor guidance lands weaker"))]
SKILLS = [("Ürün", "Product", "Özellik kararları ve tasarım turları.", "Feature decisions and design rounds."),
          ("Tasarım", "Design", "Tasarım tavanı ve ürün deneyimi.", "The design ceiling and product experience."),
          ("Yazılım", "Engineering", "Geliştirme hızı ve hata oranı.", "Development speed and bug rate."),
          ("Test", "QA", "Hata bulma ve canlı ürünün aşınması.", "Finding bugs and live product wear."),
          ("Satış", "Sales", "Müşteri adayı kalitesi ve anlaşma kapama.", "Prospect quality and closing deals."),
          ("Müşteri Başarısı", "Customer Success", "Bilet çözümü, memnuniyet ve churn.", "Ticket resolution, satisfaction and churn."),
          ("Liderlik", "Leadership", "Ekip morali ve kriz yönetimi.", "Team morale and crisis management."),
          ("Karizma", "Charisma", "Yatırımcı ikna gücü, şartlar ve kriz anları.", "Investor persuasion, terms and moments of crisis.")]

# ------------------------------------------------------------------ geometry per logical screen
G1920 = dict(W=1920, H=1080, PX=48, PY=388, PW=1348, PH=660, WX=1428, WY=88, WW=444, WH=960, cols="352px 400px 1fr",
             plate_w=2180, plate_pos="42% 18%", fig=(930, 66, 384, 480))
G1536 = dict(W=1536, H=864, PX=24, PY=260, PW=1088, PH=588, WX=1136, WY=80, WW=376, WH=768, cols="300px 316px 1fr",
             plate_w=1760, plate_pos="42% 18%", fig=(720, 62, 300, 375))
G = G1920

# ------------------------------------------------------------------ portraits (crop logic from design/onb_final/gen.py)
_fig = {}


def figure_box(path):
    if path not in _fig:
        from PIL import Image
        im = Image.open(path).convert("RGBA")
        w, h = im.size
        a = im.split()[3].load()
        rows = []
        for y in range(h):
            xs = [x for x in range(0, w, 2) if a[x, y] > 128]
            rows.append((xs[0], xs[-1]) if xs else None)
        top = next(y for y in range(h) if rows[y])
        bot = max(y for y in range(h) if rows[y])
        span = bot - top
        lo, hi = top + int(0.25 * span), top + int(0.70 * span)
        neck = min(range(lo, hi), key=lambda y: (rows[y][1] - rows[y][0]) if rows[y] else 1e9)
        hh = neck - top
        mids = [(rows[y][0] + rows[y][1]) / 2 for y in range(top + int(0.30 * hh), top + int(0.85 * hh)) if rows[y]]
        _fig[path] = {"w": w, "h": h, "top": top, "hh": hh, "cx": sum(mids) / len(mids)}
    return _fig[path]


def founder(n):
    return MEN + "/portraits/founder_%02d.png" % n


def portrait(n, w, h, cls=""):
    p = founder(n)
    f = figure_box(p)
    s = 0.53 * h / f["hh"]
    x, y = f["cx"] - (w / s) / 2, f["top"] - 0.06 * h / s
    img = ('<img src="%s" alt="" style="position:absolute;width:%.1fpx;height:%.1fpx;left:%.1fpx;top:%.1fpx">'
           % (url(p), f["w"] * s, f["h"] * s, -x * s, -y * s))
    return '<div class="portrait %s" style="width:%dpx;height:%dpx">%s</div>' % (cls, w, h, img)


# ------------------------------------------------------------------ the emblem generator: monogram x shape x colour x style
PALETTE = {"bone": "#E6DED0", "brick": "#D9704E", "olive": "#A9B25E", "sage": "#82BD9B",
           "teal": "#4BA8B0", "steel": "#7FA2DE", "lilac": "#AC8EDB", "rose": "#DE8DAB"}
PAL_NAMES = {"bone": ("Kemik", "Bone"), "brick": ("Kiremit", "Brick"), "olive": ("Zeytin", "Olive"), "sage": ("Adaçayı", "Sage"),
             "teal": ("Petrol", "Teal"), "steel": ("Çelik", "Steel"), "lilac": ("Leylak", "Lilac"), "rose": ("Gül", "Rose")}
GROUND = (0x15, 0x12, 0x0F)            # surface-1: the letter on a filled shape
HEX = " ".join("%.1f,%.1f" % (50 + 48 * math.cos(math.tau * i / 6 - math.pi / 2), 50 + 48 * math.sin(math.tau * i / 6 - math.pi / 2)) for i in range(6))
SHAPES = {
    "circle": '<circle cx="50" cy="50" r="47"/>',
    "hexagon": '<polygon points="%s"/>' % HEX,
    "square": '<rect x="5" y="5" width="90" height="90" rx="9"/>',
    "shield": '<path d="M50 3 L92 14 V47 C92 72 74 88 50 97 C26 88 8 72 8 47 V14 Z"/>',
    "tag": '<path d="M32 7 H89 Q94 7 94 12 V88 Q94 93 89 93 H32 L5 50 Z"/>',
    "diamond": '<polygon points="50,2 98,50 50,98 2,50"/>',
}
TEXT_X = {"tag": 60}
TEXT_SIZE = {1: {"diamond": 44, "default": 58}, 2: {"diamond": 34, "circle": 46, "shield": 44, "tag": 40, "default": 48}}
_uid = [0]


def deep(hexc, k=0.26):
    c = tuple(int(hexc[i:i + 2], 16) for i in (1, 3, 5))
    g = (0x10, 0x0E, 0x0B)
    return "#%02X%02X%02X" % tuple(round(c[i] * k + g[i] * (1 - k)) for i in range(3))


def emblem(mono, shape, color, style, size):
    _uid[0] += 1
    u = "e%d" % _uid[0]
    col = PALETTE[color]
    g = "#%02X%02X%02X" % GROUND
    fs = TEXT_SIZE[len(mono)].get(shape, TEXT_SIZE[len(mono)]["default"])
    tx = TEXT_X.get(shape, 50)
    ls = ' letter-spacing="1"' if len(mono) == 2 else ""

    def text(fill, clip=""):
        return ('<text x="%d" y="51" text-anchor="middle" dominant-baseline="central" font-size="%d" fill="%s"%s%s>%s</text>'
                % (tx, fs, fill, ls, (' clip-path="url(#%s)"' % clip) if clip else "", mono))
    sh = SHAPES[shape]
    hole = '<circle cx="21" cy="50" r="5" fill="%s"/>' % g if shape == "tag" else ""
    if style == "filled":
        body = '<g fill="%s">%s</g>%s%s' % (col, sh, hole, text(g))
    elif style == "outline":
        ohole = '<circle cx="21" cy="50" r="5" fill="none" stroke="%s" stroke-width="4"/>' % col if shape == "tag" else ""
        body = ('<g fill="none" stroke="%s" stroke-width="5" stroke-linejoin="round" transform="translate(50 50) scale(0.94) translate(-50 -50)">%s</g>%s%s'
                % (col, sh, ohole, text(col)))
    else:   # split: a slanted cut, light half carries a dark letter, dark half carries a light one
        body = ('<defs><clipPath id="%sa"><polygon points="0,0 62,0 38,100 0,100"/></clipPath>'
                '<clipPath id="%sb"><polygon points="62,0 100,0 100,100 38,100"/></clipPath></defs>'
                '<g fill="%s" clip-path="url(#%sa)">%s</g><g fill="%s" clip-path="url(#%sb)">%s</g>%s%s%s'
                % (u, u, col, u, sh, deep(col), u, sh, hole, text(g, u + "a"), text(col, u + "b")))
    return '<svg class="lmark" viewBox="0 0 100 100" width="%d" height="%d">%s</svg>' % (size, size, body)


# twelve for "Unicorn Inc." (initials U, UI): every shape twice, every style four times, every colour at least once
GEN12 = [("U", "circle", "brick", "filled"), ("UI", "hexagon", "teal", "split"), ("UI", "square", "bone", "outline"),
         ("U", "shield", "steel", "filled"), ("UI", "tag", "olive", "outline"), ("U", "diamond", "rose", "filled"),
         ("UI", "circle", "lilac", "outline"), ("U", "hexagon", "sage", "filled"), ("U", "square", "rose", "split"),
         ("UI", "shield", "brick", "outline"), ("U", "tag", "bone", "filled"), ("UI", "diamond", "steel", "split")]
CHOSEN = 1


# ------------------------------------------------------------------ shared parts
def head():
    out = ('<span class="btn btn-ghost btn-sm out">%s<span>%s</span><span class="kbd">Esc</span></span>'
           % (ic("util/chevron_left"), L("Ana menüye dön", "Return to main menu")))
    return '<header class="onb-head">%s%s</header>' % (lockup(40), out)


def stage():
    fx, fy, fw, fh = G["fig"]
    return ('<div class="office" style="background-image:url(%s);background-size:%dpx auto;background-position:%s"></div>'
            '<div class="figure" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx"><img src="%s" alt=""></div>'
            % (url(PLATE), G["plate_w"], G["plate_pos"], fx, fy, fw, fh, url(founder(SEL))))


def tabs(step):
    x, y = G["PX"], G["PY"] - 44
    t = []
    names = [("Karakter", "Character"), ("Köken", "Origin"), ("Şirket", "Company")]
    hints = [None, ("Huy ve yetenek", "Traits and skills"), ("Ad ve logo", "Name and logo")]
    sums = ['<img src="%s">%s' % (FACE, NAME), ic("origin/self_made", 18) + L("Sıfırdan", "Self-Made"), None]
    for i in range(3):
        if i < step:
            t.append('<span class="dtab is-done"><span class="no">%s</span><span class="t-nav">%s</span><span class="sum t-meta">%s</span></span>'
                     % (ic("util/check", 14), L(*names[i]), sums[i]))
        elif i == step:
            t.append('<span class="dtab is-now"><span class="no">%d</span><span class="t-nav">%s</span></span>' % (i + 1, L(*names[i])))
        else:
            t.append('<span class="dtab is-next"><span class="no">%d</span><span class="t-nav">%s</span><span class="sum t-meta">%s</span></span>'
                     % (i + 1, L(*names[i]), L(*hints[i])))
    return '<div class="dtabs" style="left:%dpx;top:%dpx">%s</div>' % (x, y, "".join(t))


def col_head(k, s, right=""):
    return '<div class="col-h"><div class="k t-label">%s%s</div><div class="s t-caption">%s</div></div>' % (k, right, s)


def foot(step):
    nxt = btn(L("Kur ve başla", "Found and start"), "primary", "lg") if step == 2 else btn(L("İleri", "Next"), "primary", "lg")
    return ('<div class="sheet-foot"><span class="cnt t-meta">%s</span><span class="sp"></span>%s%s</div>'
            % (L("Adım %d / 3" % (step + 1), "Step %d / 3" % (step + 1)), btn(L("Geri", "Back"), "ghost", "lg", extra="is-disabled" if step == 0 else ""), nxt))


def paper(step, inner):
    return ('<section class="sheet is-raised" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx"><div class="sheet-body">%s</div>%s</section>'
            % (G["PX"], G["PY"], G["PW"], G["PH"], inner, foot(step)))


def tools():
    return '<div class="tools">%s%s</div>' % (btn(L("Rastgele", "Randomize"), "secondary", "sm", "util/dice"), btn(L("Sıfırla", "Reset"), "ghost", "sm", "util/revert"))


# ------------------------------------------------------------------ the first-week document
def week(step):
    # letterhead: the company, empty until step 3
    if step == 2:
        m, sh, c, st = GEN12[CHOSEN]
        lh = ('<div class="lhead">%s<div class="tx"><span class="nm t-h2">%s</span><span class="s t-meta">%s</span></div></div>'
              % (emblem(m, sh, c, st, 56), COMPANY, L("Kurucu · %s" % NAME, "Founder · %s" % NAME)))
    else:
        lh = ('<div class="lhead"><span class="ph"></span><div class="tx"><span class="nm is-empty t-h2">%s</span><span class="s t-meta">%s</span></div></div>'
              % (L("Şirket adı", "Company name"), L("3. adımda: ad ve logo", "Step 3: name and logo")))
    s1 = ('<div class="wsec"><div class="week-h t-label">%s<span class="d t-meta">%s</span></div>%s</div>'
          % (L("İlk hafta", "Week one"), L("Hafta 1 · Ocak 2026", "Week 1 · January 2026"), lh))

    # founder summary (A's founder file, compact)
    pw, ph = (64, 80) if G is G1536 else (80, 100)
    if step == 0:
        info = ('<span class="nm t-subhead">%s</span><span class="pend t-caption">%s</span>'
                % (NAME, L("Köken, huylar ve yetenekler 2. adımda.", "Origin, traits and skills come in step 2.")))
    else:
        chips = (tag(ic("util/plus", 12) + L("Vizyoner", "Visionary"), "pos") + tag(ic("util/plus", 12) + L("Disiplinli", "Disciplined"), "pos")
                 + tag(ic("util/minus", 12) + L("İnatçı", "Stubborn"), "risk"))
        info = ('<span class="nm t-subhead">%s</span><span class="og t-data">%s%s</span><div class="chips">%s</div>'
                % (NAME, ic("origin/self_made"), L("Sıfırdan", "Self-Made"), chips))
    if True:
        rows = []
        for (tr, en, _, _), v in zip(SKILLS, ALLOC if step else (0,) * 8):
            pips = "".join('<i class="%s"></i>' % ("on" if i < v * 2 else "") for i in range(6))
            rows.append('<div class="r%s"><span class="nm">%s</span><span class="pips">%s</span><span class="v">%d</span></div>'
                        % ("" if v else " is-zero", L(tr, en), pips, v))
        sk = '<div class="fsk">%s</div>' % "".join(rows[i] for i in (0, 4, 1, 5, 2, 6, 3, 7))
    s2 = '<div class="wsec"><div class="fsum">%s<div class="tx">%s</div></div>%s</div>' % (portrait(SEL, pw, ph), info, sk)

    # difficulty
    cells = []
    for did, nm, cash, locked in DIFF:
        cls = "dcell" + (" is-selected" if did == DIFF_SEL else "") + (" is-locked" if locked else "")
        cells.append('<div class="%s"><span class="n t-label">%s%s</span><span class="c">%s</span></div>'
                     % (cls, L(*nm), ic("util/lock") if locked else "", money(cash)))
    s3 = ('<div class="wsec"><div class="wk-k t-label">%s<span class="r">%s</span></div><div class="diff">%s</div>'
          '<div class="diff-why t-caption">%s%s</div></div>'
          % (L("Zorluk", "Difficulty"), L("Başlangıç kasasını belirler", "Sets your starting cash"), "".join(cells),
             ic("util/lock"), L("Zor, bir koşuyu bitirince açılır.", "Hard opens once you finish a run.")))

    # week-one numbers
    cash = [c for d, _, c, _ in DIFF if d == DIFF_SEL][0]
    runway = round(cash / BURN_MONTH)
    burn = "$1,5K" if LANG == "tr" else "$1.5K"
    kv = ('<span class="k t-label">%s</span><span class="v big t-kpi">%s</span><span class="n">%s</span>'
          '<span class="k t-label">Burn</span><span class="v t-value">%s<span class="u">/ %s</span></span><span class="n t-caption">%s</span>'
          '<span class="k t-label">Runway</span><span class="v t-value">%d<span class="u">%s</span></span><span class="n"></span>'
          '<span class="k t-label">%s</span><span class="v t-value">%s%s</span><span class="n"></span>'
          '<span class="k t-label">%s</span><span class="v t-value"><img src="%s">%s</span><span class="n"></span>'
          % (L("Kasa", "Cash"), money(cash), tag(L("Normal", "Normal")),
             burn, L("ay", "mo"), L("Geçim ve araçlar", "Living and tools"),
             runway, L("ay", "months"),
             L("Ofis", "Office"), ic("place/home"), L("Ev", "Home"),
             L("Ekip", "Team"), FACE, L("Yalnız sen", "Just you")))
    s4 = '<div class="wsec"><div class="wkv">%s</div></div>' % kv

    s5 = ('<div class="wsec is-last"><div class="guide"><span class="switch is-on"><span class="switch-t"></span></span>'
          '<div class="tx"><span class="t">%s</span><span class="s t-caption">%s</span></div></div></div>'
          % (L("Frank'le rehberli başla", "Guided start with Frank"),
             L("İlk haftalarda Frank'in notları gelen kutuna düşer, öteki olaylar bekler.",
               "In the first weeks Frank's notes reach your inbox and other events wait.")))
    return ('<section class="week" style="left:%dpx;top:%dpx;width:%dpx;height:%dpx">%s%s%s%s%s</section>'
            % (G["WX"], G["WY"], G["WW"], G["WH"], s1, s2, s3, s4, s5))


# ------------------------------------------------------------------ step 1: character
def step1():
    inner_w = G["PW"] - 48
    cw = (inner_w - 7 * 12) // 8
    chh = round(cw * 1.25)
    cells = []
    for n in range(1, 12):
        cls = "face" + (" is-selected" if n == SEL else "") + (" is-hover" if n == 9 else "")
        sel = '<span class="sel">%s</span>' % ic("util/check") if n == SEL else ""
        cells.append('<div class="%s">%s%s</div>' % (cls, portrait(n, cw, chh), sel))
    for _ in range(5):
        cells.append('<div class="face is-new"><span class="ph"></span><span class="t-micro">%s</span></div>' % L("Yeni portre", "New portrait"))
    grid = ('<div class="faces" style="grid-template-columns:repeat(8,%dpx);grid-auto-rows:%dpx;column-gap:12px;row-gap:12px">%s</div>'
            % (cw, chh, "".join(cells)))
    name = ('<div class="namerow"><span class="k t-label">%s</span><span class="input is-focus">%s<span class="caret"></span><span class="cnt">%d/40</span></span>'
            '<span class="h t-caption">%s</span></div>'
            % (L("Adın", "Your name"), NAME, len(NAME), L("Boş bırakırsan 'Kurucu' kullanılır.", "Leave it empty and you are 'Founder'.")))
    inner = ('<div class="row-h">%s%s</div>%s%s'
             % (col_head(L("Karakter", "Character"), L("Bu, aynada göreceğin yüz. Arkadaki odada seni böyle görecekler.",
                                                       "The face in the mirror. This is how they will see you in the room behind.")), tools(), name, grid))
    return head() + stage() + tabs(0) + paper(0, inner) + week(0)


# ------------------------------------------------------------------ step 2: origin, traits, skills (C)
def origin_col():
    sel = ('<div class="ocard is-selected">'
           '<div class="t">%s<span class="t-subhead">%s</span><span class="chk">%s</span></div>'
           '<div class="q">"%s"</div>'
           '<div class="tags">%s%s%s</div>'
           '<div class="kv"><span class="k t-meta">%s</span><span class="v t-data-strong">%s</span></div></div>'
           % (ic("origin/self_made", 24), L("Sıfırdan", "Self-Made"), ic("util/check", 20),
              L("Hiçbir şey yoktu. Her satırı ben yazdım.", "There was nothing. I wrote every line myself."),
              tag(L("Dayanıklı", "Resilient")), tag(ic("stake/cost", 12) + L("Düşük sermaye", "Low capital")), tag(L("Basın sempatisi", "Press sympathy")),
              L("Başlangıç yeri", "Starting place"), L("Ev", "Home")))

    def locked(glyph, nm, q, lk):
        return ('<div class="ocard is-locked"><div class="t">%s<span class="t-subhead">%s</span><span class="lk">%s%s</span></div>'
                '<div class="q">"%s"</div></div>' % (ic(glyph, 24), nm, ic("util/lock", 14), tag(lk), q))
    return ('<div class="col">%s<div class="ocards">%s%s%s</div></div>'
            % (col_head(L("Köken", "Origin"), L("Nereden geldiğin, nereden başladığını belirler.", "Where you come from decides where you start.")),
               sel,
               locked("origin/heir", L("Mirasyedi", "The Heir"), L("Aile sermayesi arkanda. Ama gözler de üzerinde.", "Family money at your back. And every eye on you."),
                      L("Tam sürümde", "In the full game")),
               locked("origin/corporate", L("Kurumsal Firari", "Corporate Refugee"), L("On yıl büyük şirkette. Şimdi kendi adına.", "Ten years in a big company. Now in your own name."),
                      L("Çok yakında", "Coming soon"))))


def trait_col():
    def tcol(title, items, chosen, cap):
        full = len(chosen) >= cap
        rows = []
        for tid, nm, ef in items:
            on = tid in chosen
            cls = "trow" + (" is-on" if on else "") + (" is-off" if full and not on else "")
            rows.append('<div class="%s"><span class="check%s"><span class="check-box">%s</span></span><span class="tx"><span class="n">%s</span><span class="e">%s</span></span></div>'
                        % (cls, " is-on" if on else "", ic("util/check", 14), L(*nm), L(*ef)))
        return ('<div class="tcol"><div class="tcol-h t-label">%s<span class="c%s">%d / %d</span></div>%s</div>'
                % (title, " is-full" if full else "", len(chosen), cap, "".join(rows)))
    return ('<div class="col">%s%s%s</div>'
            % (col_head(L("Huylar", "Traits"), L("Bir pozitif seçebilirsin. İki pozitif seçersen bir negatif seçmelisin.", "Pick one strength freely. Pick two and you owe a flaw.")),
               tcol(L("Pozitif", "Positive"), TRAITS_POS, POS, 2), tcol(L("Negatif", "Negative"), TRAITS_NEG, NEG, 1)))


def skill_col():
    left = 6 - sum(ALLOC)
    rows = []
    for (tr, en, dtr, den), v in zip(SKILLS, ALLOC):
        pips = "".join('<i class="%s"></i>' % ("on" if i < v * 2 else "") for i in range(10))
        minus = '<span class="b%s">%s</span>' % (" is-disabled" if v == 0 else "", ic("util/minus"))
        plus = '<span class="b%s">%s</span>' % (" is-disabled" if (v >= 3 or left <= 0) else "", ic("util/plus"))
        rows.append('<div class="srow%s"><span class="n">%s</span><span class="d">%s</span><div class="pips">%s</div>'
                    '<div class="stepper">%s<span class="v">%d</span>%s</div></div>' % (" is-set" if v else "", L(tr, en), L(dtr, den), pips, minus, v, plus))
    right = ('<span class="r">%s <b>%d</b> · %s%s</span>' % (L("Kalan puan", "Points left"), left, ic("util/check", 14), L("Hepsi dağıtıldı", "All spent")))
    return '<div class="col">%s<div class="srows">%s</div></div>' % (col_head(L("Yetenekler", "Skills"), L("Masaya ne getiriyorsun.", "What you bring to the table."), right), "".join(rows))


def step2():
    inner = '<div class="sheet-cols" style="grid-template-columns:%s">%s%s%s</div>' % (G["cols"], origin_col(), trait_col(), skill_col())
    return head() + stage() + tabs(1) + paper(1, inner) + week(1)


# ------------------------------------------------------------------ step 3: company
def step3():
    tiles = []
    for i, (m, sh, c, st) in enumerate(GEN12):
        cls = "ltile" + (" is-selected" if i == CHOSEN else "") + (" is-hover" if i == 7 else "")
        sel = '<span class="sel">%s</span>' % ic("util/check") if i == CHOSEN else ""
        tiles.append('<div class="%s" style="height:160px">%s%s</div>' % (cls, emblem(m, sh, c, st, 104), sel))
    inner = ('%s'
             '<div class="cfield"><span class="k t-label">%s</span><span class="input is-focus">%s<span class="caret"></span><span class="cnt">%d/40</span></span></div>'
             '<div class="logo-h"><div class="tx"><span class="k t-label">%s</span><span class="s t-caption">%s</span></div>%s</div>'
             '<div class="lgrid">%s</div>'
             % (col_head(L("Şirket", "Company"), L("Kapıya asılacak isim. Bundan sonra herkes bu adı anacak.", "The name on the door. From now on this is what they will call you.")),
                L("Şirket adı", "Company name"), COMPANY, len(COMPANY),
                L("Logo", "Logo"), L("Adın baş harflerinden üretildi. Birini seç ya da yeniden üret.", "Made from your name's initials. Pick one or make a new set."),
                btn(L("Yeniden üret", "Make new set"), "secondary", "", "util/dice"), "".join(tiles)))
    return head() + stage() + tabs(2) + paper(2, inner) + week(2)


# ------------------------------------------------------------------ 06 cancel, 07 curtain
def cancel():
    m = ('<section class="modal" style="width:480px"><div class="modal-h t-subhead" style="color:var(--ink-1)">%s</div>'
         '<div class="modal-b">%s</div><div class="modal-f">%s%s</div></section>'
         % (L("Kurulum iptal edilsin mi?", "Cancel setup?"), L("Seçimlerin kaydedilmez.", "Your choices won't be saved."),
            btn(L("Ana menüye dön", "Return to main menu")), btn(L("Kuruluma devam et", "Continue setup"), "primary", extra="is-focus")))
    return step2() + '<div class="scrim" style="z-index:5"></div><div style="position:absolute;left:720px;top:452px;z-index:6">%s</div>' % m


def curtain():
    m, sh, c, st = GEN12[CHOSEN]
    return ('<div class="curtain2">%s<span class="nm t-h2">%s</span><span class="d t-meta">%s</span>'
            '<span class="ld t-meta">%s</span><div class="prog"><div class="prog-t"><div class="prog-f ind"></div></div></div>'
            '<div class="brand">%s</div></div>'
            % (emblem(m, sh, c, st, 112), COMPANY, L("Hafta 1 · Ocak 2026", "Week 1 · January 2026"), L("Hazırlanıyor…", "Preparing…"), lockup(24)))


# ------------------------------------------------------------------ page
def page(body, title, w1536=False):
    css = "".join('<link rel="stylesheet" href="%s">' % url(p) for p in
                  (MEN + "/system/tokens.css", MEN + "/system/base.css", MEN + "/screens/modallar_acilis/modallar.css", os.path.join(HERE, "onb2.css")))
    return ('<!doctype html><html lang="%s"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet">%s</head><body%s><div class="sahne">%s</div></body></html>'
            % (LANG, title, FONTS, css, ' class="w1536"' if w1536 else "", body))


def main():
    global LANG, G
    frames = []
    LANG, G = "tr", G1920
    frames += [("01_adim1_karakter", page(step1(), "Adım 1 · Karakter")), ("02_adim2_koken", page(step2(), "Adım 2 · Köken"))]
    LANG = "en"
    frames.append(("03_adim2_koken_en", page(step2(), "Step 2 · Origin")))
    LANG, G = "tr", G1536
    frames.append(("04_adim2_koken_1536", page(step2(), "Adım 2 · 1536", w1536=True)))
    G = G1920
    frames += [("05_adim3_sirket", page(step3(), "Adım 3 · Şirket")), ("06_iptal_onay", page(cancel(), "İptal onayı")),
               ("07_yukleniyor_perde", page(curtain(), "Yükleniyor"))]
    for name, html in frames:
        open(os.path.join(HERE, name + ".html"), "w", encoding="utf-8").write(html)
        print(name)


if __name__ == "__main__":
    main()
