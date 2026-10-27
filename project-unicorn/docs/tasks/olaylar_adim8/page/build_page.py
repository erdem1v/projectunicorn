#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""data.json + extra.json + notes.json -> index.html (statik inceleme sayfasi)."""
import os as _os
_HERE = _os.path.dirname(_os.path.dirname(_os.path.abspath(__file__)))
import difflib
import html
import json
import os
import re
import sys

P = os.path.dirname(os.path.abspath(__file__))


def load(name):
    with open(os.path.join(P, name), encoding="utf-8") as f:
        return json.load(f)


DATA = load("data.json")
EXTRA = load("extra.json")
NOTES = load("notes.json")
KARTLAR = DATA["kartlar"]
YUVA = {"tr": NOTES.get("yuva_adlari", {}), "en": NOTES.get("yuva_adlari_en", {})}
KEYS = {a["anahtar"]: a for a in EXTRA.get("anahtarlar", [])}

LANGS = ("tr", "en")
LANG_LABEL = {"tr": "TR", "en": "EN"}

# ---------------------------------------------------------------- escaping

PH_RE = re.compile(r"\{([a-z][^{}]*)\}")
TOKEN_RE = re.compile(r"\{([^{}]+)\}")


def esc(s):
    return html.escape("" if s is None else str(s), quote=True)


def esc_ph(s):
    """Escape; {param} placeholders (anahtar metinleri, md) become small 'ph' chips."""
    t = esc(s)
    return PH_RE.sub(lambda m: '<span class="ph">%s</span>' % m.group(1), t)


def card_text(s, lang):
    """Card text: escape, slot tokens -> chips labelled from yuva_adlari."""
    out = []
    pos = 0
    s = "" if s is None else str(s)
    for m in TOKEN_RE.finditer(s):
        out.append(esc(s[pos:m.start()]))
        name = m.group(1)
        label = YUVA[lang].get(name, name)
        out.append('<span class="chip" title="%s">%s</span>' % (esc(name), esc(label)))
        pos = m.end()
    out.append(esc(s[pos:]))
    return "".join(out)


# ---------------------------------------------------------------- diff


def _group(words, flags, lang, tag):
    """Render words; consecutive flagged words are wrapped once in <tag>."""
    out = []
    i = 0
    while i < len(words):
        if flags[i]:
            j = i
            while j < len(words) and flags[j]:
                j += 1
            out.append("<%s>%s</%s>" % (tag, " ".join(card_text(w, lang) for w in words[i:j]), tag))
            i = j
        else:
            out.append(card_text(words[i], lang))
            i += 1
    return " ".join(out)


def diff_pair(a, b, lang):
    """Return (before_html, after_html) with word level marks. None = absent."""
    aw = (a or "").split()
    bw = (b or "").split()
    af = [False] * len(aw)
    bf = [False] * len(bw)
    if a is None:
        bf = [True] * len(bw)
    elif b is None:
        af = [True] * len(aw)
    else:
        sm = difflib.SequenceMatcher(None, aw, bw, autojunk=False)
        for op, i1, i2, j1, j2 in sm.get_opcodes():
            if op in ("replace", "delete"):
                for i in range(i1, i2):
                    af[i] = True
            if op in ("replace", "insert"):
                for j in range(j1, j2):
                    bf[j] = True
    return _group(aw, af, lang, "del"), _group(bw, bf, lang, "ins")


def plain(s, lang):
    return " ".join(card_text(w, lang) for w in (s or "").split())


# ---------------------------------------------------------------- helpers


def slug(card):
    base = card.get("kart") or card.get("revize") or card.get("no")
    return "k-" + re.sub(r"[^a-z0-9]+", "-", base.lower()).strip("-")


def lock_text(reason, lang):
    """kilit may be a raw string-table key: resolve it from extra.anahtarlar."""
    if not reason:
        return None
    k = KEYS.get(reason)
    if k:
        return k[lang], reason
    return reason, None


def render_side(side, other, lang, which):
    """One column (Önce or Sonra). `other` = the opposite side's dict for diff, or None."""
    if side is None:
        return '<p class="muted">Metin yok.</p>'
    use_diff = other is not None

    # for sonra column: x_side=side(sonra), y_side=other(once); pair() wants (once, sonra)
    def txt(getter):
        if not use_diff:
            return plain(getter(side), lang)
        if which == "once":
            return diff_pair(getter(side), getter(other), lang)[0]
        return diff_pair(getter(other), getter(side), lang)[1]

    out = []
    out.append('<div class="sender">%s</div>' % txt(lambda s: s.get("gonderen")))
    out.append('<h5 class="ctitle">%s</h5>' % txt(lambda s: s.get("konu")))
    out.append('<p class="cbody">%s</p>' % txt(lambda s: s.get("metin")))

    mine = side.get("secenekler") or []
    theirs = (other.get("secenekler") or []) if other is not None else []
    out.append('<ol class="opts">')
    for i, o in enumerate(mine):
        t = theirs[i] if i < len(theirs) else None

        def g_et(s, i=i):
            xs = s.get("secenekler") or []
            return xs[i].get("etiket") if i < len(xs) else None

        def g_so(s, i=i):
            xs = s.get("secenekler") or []
            return xs[i].get("sonuc") if i < len(xs) else None

        if use_diff:
            if t is None:
                # extra option: fully marked
                tag = "del" if which == "once" else "ins"
                et = "<%s>%s</%s>" % (tag, plain(o.get("etiket"), lang), tag)
                so = "<%s>%s</%s>" % (tag, plain(o.get("sonuc"), lang), tag) if o.get("sonuc") else ""
            else:
                et = txt(g_et)
                so = txt(g_so)
        else:
            et = plain(o.get("etiket"), lang)
            so = plain(o.get("sonuc"), lang)
        li = ['<li><div class="olabel">%s</div>' % et]
        if so:
            li.append('<div class="oout">%s</div>' % so)
        lk = lock_text(o.get("kilit"), lang)
        if lk:
            txtlock, key = lk
            li.append(
                '<div class="olock"><span class="lockmark" aria-hidden="true">&#9632;</span> '
                'Kilitli: %s%s</div>'
                % (esc_ph(txtlock), (' <code class="key">%s</code>' % esc(key)) if key else "")
            )
        li.append("</li>")
        out.append("".join(li))
    out.append("</ol>")
    if side.get("cevapsiz"):
        out.append(
            '<div class="noans"><span class="lbl">Cevap gelmezse</span> %s</div>'
            % plain(side["cevapsiz"], lang)
        )
    return "".join(out)


def badge(onay):
    if onay == "bekliyor":
        return '<span class="badge pend">TR/EN onay bekliyor</span>'
    return '<span class="badge ok">onaylı</span>'


# ---------------------------------------------------------------- shots


def shot_pair(card, lang):
    kar = card.get("kareler") or {}
    figs = []
    bq = (card.get("baglar") or {}).get("B") or {}
    pinned_b = any(x.get("igne") for x in bq.get("yuvalar") or [])
    for fr, cap in (("A", "A · Doğal seçim"), ("B", "B · İğneli" if pinned_b else "B · Uzun adlar")):
        k = kar.get("%s_%s" % (fr, lang))
        if not k:
            continue
        src = k["yol"]
        if lang == "tr":
            imgattr = 'src="%s"' % esc(src)
        else:
            imgattr = 'data-src="%s"' % esc(src)
        figs.append(
            '<figure><a href="%s" target="_blank" rel="noopener">'
            '<img %s width="%d" height="%d" loading="lazy" alt="%s, %s karesi, %s"></a>'
            "<figcaption>%s</figcaption></figure>"
            % (esc(src), imgattr, k["w"], k["h"], esc(card.get("kart") or ""), fr, LANG_LABEL[lang], esc(cap))
        )
    if not figs:
        return ""
    return '<div class="shots%s">%s</div>' % (" one" if len(figs) == 1 else "", "".join(figs))


def has_shots(card):
    return bool(card.get("kareler"))


def pin_line(card):
    if not has_shots(card):
        return '<p class="pin none">Bu kartın oyun karesi yok.</p>'
    bg = card.get("baglar") or {}
    A = (bg.get("A") or {}).get("yuvalar") or []
    Bd = bg.get("B") or {}
    B = Bd.get("yuvalar") or []
    lab = YUVA["tr"]
    has_b = any(k.startswith("B_") for k in card["kareler"])

    def name(x):
        return esc(lab.get(x.get("yuva"), x.get("yuva")))

    def people(xs):
        return [x for x in xs if x.get("yuva") != "founder"]

    A, B = people(A), people(B)
    if not A and not B:
        if has_b:
            return ('<p class="pin">Kartta kişi ya da şirket yuvası yok (gönderen bir kurum adı); '
                    'iki kare aynıdır.</p>')
        return '<p class="pin">Kartta kişi ya da şirket yuvası yok; tek kare yeter.</p>'
    a_ids = {x["yuva"]: x.get("id") for x in A}
    parts = []
    pinned = [x for x in B if x.get("igne")]
    free = [x for x in B if not x.get("igne")]

    def same(x):
        return "aynı varlık" if a_ids.get(x["yuva"]) == x.get("id") else "başka varlık"

    if pinned:
        parts.append("B karesinde iğne: " + ", ".join(
            "%s → %s (<code>%s</code>)" % (name(x), esc(x.get("ad")), esc(x.get("id"))) for x in pinned) + ".")
        if free:
            parts.append("Seçiciden: " + ", ".join(
                "%s → %s (%s)" % (name(x), esc(x.get("ad")), same(x)) for x in free) + ".")
    elif B:
        parts.append("B karesinde iğne yok: kare seçicinin bağladığı varlıklarla çekildi, adın yuvadan okunduğunu uzun ad gösterir: "
                     + ", ".join("%s → %s (%s)" % (name(x), esc(x.get("ad")), same(x)) for x in B) + ".")
    if Bd.get("long"):
        parts.append("B'de adlar uzatıldı (<code>:long=1</code>), uzun adın taşıp taşmadığı da sınanır.")
    if Bd.get("where") == "skipped":
        parts.append("İğnelenen varlık yuvanın koşulunu karşılamıyor; kare koşulsuz bağlandı, yalnız metin ve yerleşim için.")
    if A:
        parts.append("A karesi seçicinin kendi seçimi: " + ", ".join("%s %s" % (name(x), esc(x.get("ad"))) for x in A) + ".")
    return '<p class="pin">%s</p>' % " ".join(parts)


def lang_blocks(fn):
    return "".join('<div class="langblk l-%s" lang="%s">%s</div>' % (l, l, fn(l)) for l in LANGS)


# ---------------------------------------------------------------- cards


def card_head(c, tag="h3"):
    return (
        '<header class="chead"><%s class="ctit"><span class="no">%s</span> %s</%s>'
        '<div class="cmeta"><span class="ids">%s → %s</span><span class="cat">%s</span>%s</div></header>'
        % (
            tag,
            esc(c["no"]),
            lang_blocks_inline(lambda l: card_text((c.get("sonra") or c.get("once") or {}).get(l, {}).get("konu", ""), l)),
            tag,
            esc(c.get("revize")),
            esc(c.get("kart") or "—"),
            esc(c.get("kategori") or ""),
            badge(c.get("onay")),
        )
    )


def lang_blocks_inline(fn):
    return "".join('<span class="l-%s" lang="%s">%s</span>' % (l, l, fn(l)) for l in LANGS)


def neden_block(c):
    items = c.get("neden") or []
    if not items:
        return ""
    return (
        '<details class="neden"><summary>Neden değişti</summary><ul>%s</ul></details>'
        % "".join("<li>%s</li>" % esc_ph(n) for n in items)
    )


def shots_and_pin(c):
    if not has_shots(c):
        return '<p class="pin none">Bu kartın oyun karesi yok.</p>'
    return lang_blocks(lambda l: shot_pair(c, l)) + pin_line(c)


def render_changed(c):
    def cols(l):
        once = (c.get("once") or {}).get(l)
        sonra = (c.get("sonra") or {}).get(l)
        return (
            '<div class="cols"><section class="col once"><h4>Önce</h4>%s</section>'
            '<section class="col sonra"><h4>Sonra</h4>%s</section></div>'
            % (render_side(once, sonra, l, "once"), render_side(sonra, once, l, "sonra"))
        )

    return (
        '<article class="card" id="%s">%s%s%s%s</article>'
        % (slug(c), card_head(c), neden_block(c), lang_blocks(cols), shots_and_pin(c))
    )


def render_new(c):
    def cols(l):
        sonra = (c.get("sonra") or {}).get(l)
        return '<div class="cols single"><section class="col sonra"><h4>Sonra</h4>%s</section></div>' % render_side(
            sonra, None, l, "sonra"
        )

    return (
        '<article class="card" id="%s">%s%s%s%s</article>'
        % (slug(c), card_head(c), neden_block(c), lang_blocks(cols), shots_and_pin(c))
    )


def render_unchanged(c):
    return (
        '<article class="card slim" id="%s">%s%s%s</article>'
        % (slug(c), card_head(c), neden_block(c), shots_and_pin(c))
    )


# ---------------------------------------------------------------- park


def render_park(c):
    sonra = c.get("sonra")
    once = c.get("once")
    tk = (sonra or {}).get("taslak") if sonra else None
    if c["durum"] == "sil":
        note = "silindi"
        side_src, side_label = once, "Silinmeden önceki metin"
    else:
        note = "park (unwired/, _draft)"
        if tk:
            note = "%s: %s" % (tk.get("durum", "park"), tk.get("gerekce", ""))
        side_src, side_label = sonra, "Parktaki metin"

    def body(l):
        s = (side_src or {}).get(l)
        if s is None:
            return '<p class="muted">Metin yok.</p>'
        return render_side(s, None, l, "sonra")

    title = ""
    if side_src:
        title = lang_blocks_inline(lambda l: card_text((side_src.get(l) or {}).get("konu", ""), l))
    det = '<details><summary>%s</summary>%s</details>' % (esc(side_label), lang_blocks(body)) if side_src else ""
    extra = ""
    if tk and tk.get("kaynak_kayit"):
        extra = ' <span class="muted">kaynak kayıt <code>%s</code></span>' % esc(tk["kaynak_kayit"])
    return (
        '<tr id="%s"><td class="nowrap"><strong>%s</strong></td><td><code>%s</code></td><td><code>%s</code></td>'
        "<td>%s %s%s</td><td>%s</td></tr>"
        % (slug(c), esc(c["no"]), esc(c["revize"]), esc(c["kart"] or "—"), title, esc(note), extra, det)
    )


# ---------------------------------------------------------------- markdown


def md_inline(s):
    parts = re.split(r"(`[^`]*`)", s)
    out = []
    for p in parts:
        if p.startswith("`") and p.endswith("`") and len(p) >= 2:
            out.append("<code>%s</code>" % esc_ph(p[1:-1]))
        else:
            out.append(re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", esc_ph(p)))
    return "".join(out)


def split_row(line):
    line = line.strip()
    if line.startswith("|"):
        line = line[1:]
    if line.endswith("|") and not line.endswith("\\|"):
        line = line[:-1]
    return [c.strip().replace("\\|", "|") for c in re.split(r"(?<!\\)\|", line)]


def md_blocks(lines):
    """lines -> html (no ## handling; headings # / ## / ### rendered if present)."""
    out = []
    i = 0
    n = len(lines)
    while i < n:
        line = lines[i]
        if not line.strip():
            i += 1
            continue
        m = re.match(r"^(#{1,4})\s+(.*)$", line)
        if m:
            lvl = min(len(m.group(1)) + 2, 6)
            out.append("<h%d>%s</h%d>" % (lvl, md_inline(m.group(2)), lvl))
            i += 1
            continue
        if line.lstrip().startswith("|"):
            rows = []
            while i < n and lines[i].lstrip().startswith("|"):
                rows.append(lines[i])
                i += 1
            cells = [split_row(r) for r in rows]
            if len(cells) >= 2 and all(re.fullmatch(r":?-{2,}:?", c.strip()) for c in cells[1]):
                head, body = cells[0], cells[2:]
            else:
                head, body = None, cells
            t = ['<div class="tablewrap"><table class="md">']
            if head:
                t.append("<thead><tr>%s</tr></thead>" % "".join("<th>%s</th>" % md_inline(c) for c in head))
            t.append("<tbody>")
            for r in body:
                t.append("<tr>%s</tr>" % "".join("<td>%s</td>" % md_inline(c) for c in r))
            t.append("</tbody></table></div>")
            out.append("".join(t))
            continue
        if re.match(r"^\s*[-*]\s+", line):
            # nested list, 2-space indents
            items = []
            while i < n and (re.match(r"^\s*[-*]\s+", lines[i]) or (lines[i].startswith(" ") and lines[i].strip() and items)):
                mm = re.match(r"^(\s*)[-*]\s+(.*)$", lines[i])
                if mm:
                    items.append([len(mm.group(1)) // 2, mm.group(2)])
                else:
                    items[-1][1] += " " + lines[i].strip()
                i += 1
            html_l = []
            depth = -1
            first_at = []
            for lvl, txt in items:
                if lvl > depth:
                    while depth < lvl:
                        html_l.append("<ul>")
                        depth += 1
                        if depth < lvl:
                            html_l.append("<li>")
                elif lvl < depth:
                    while depth > lvl:
                        html_l.append("</li></ul>")
                        depth -= 1
                    html_l.append("</li>")
                else:
                    html_l.append("</li>")
                html_l.append("<li>" + md_inline(txt))
            while depth >= 0:
                html_l.append("</li></ul>")
                depth -= 1
            out.append("".join(html_l))
            continue
        # paragraph
        para = []
        while i < n and lines[i].strip() and not re.match(r"^(#{1,4}\s|\s*[-*]\s|\s*\|)", lines[i]):
            para.append(lines[i].strip())
            i += 1
        out.append("<p>%s</p>" % md_inline(" ".join(para)))
    return "".join(out)


def md_to_html(md):
    lines = md.split("\n")
    # split in sections at "## "
    secs = []  # (heading or None, [lines])
    cur = (None, [])
    for ln in lines:
        if ln.startswith("## "):
            secs.append(cur)
            cur = (ln[3:].strip(), [])
        else:
            cur[1].append(ln)
    secs.append(cur)
    out = []
    in_intro = True
    for head, body in secs:
        if head is None:
            out.append('<div class="md-intro">%s</div>' % md_blocks(body))
            continue
        is_card = "(`" in head
        if is_card:
            in_intro = False
        out.append(
            '<details class="mdsec"%s><summary>%s</summary>%s</details>'
            % (" open" if in_intro else "", md_inline(head), md_blocks(body))
        )
    return "".join(out)


# ---------------------------------------------------------------- sections


def table(headers, rows, cls=""):
    th = "".join("<th>%s</th>" % h for h in headers)
    tr = "".join("<tr>%s</tr>" % "".join("<td>%s</td>" % c for c in r) for r in rows)
    return '<div class="tablewrap"><table class="%s"><thead><tr>%s</tr></thead><tbody>%s</tbody></table></div>' % (cls, th, tr)


def ilk_gelis_table():
    rows = []
    for r in EXTRA.get("ilk_gelis", []):
        if r["n"] == 0:
            cells = ["<span class=\"muted\">gelmedi</span>", "—", "—", "—"]
        else:
            cells = [esc(r["min"]), esc(r["medyan"]), esc(r["max"])]
            cells = ["%d / %d" % (r["n"], r["kosu"])] + cells
        if r["n"] == 0:
            cells[0] = "0 / %d &middot; gelmedi" % r["kosu"]
        rows.append(["<code>%s</code>" % esc(r["kart"]), "<code>%s</code>" % esc(r["preset"])] + cells)
    return table(["Kart", "Ön ayar", "Geldiği koşu", "En erken hafta", "Medyan hafta", "En geç hafta"], rows, "num")


def key_box(key):
    k = KEYS.get(key)
    if not k:
        return '<p class="muted">Anahtar bulunamadı: <code>%s</code></p>' % esc(key)
    return (
        '<div class="keybox"><div class="khead"><code>%s</code> <span class="muted">%s</span></div>'
        '<div class="kcols"><div><span class="lbl">TR</span> %s</div><div><span class="lbl">EN</span> %s</div></div></div>'
        % (esc(k["anahtar"]), esc(k["commit"]), esc_ph(k["tr"]), esc_ph(k["en"]))
    )


def notes_list(items):
    out = []
    for n in items:
        b = ['<div class="note"><h3>%s</h3><p>%s</p>' % (esc_ph(n["baslik"]), esc_ph(n["metin"]))]
        if n.get("tablo") == "ilk_gelis":
            b.append(ilk_gelis_table())
        if n.get("anahtar"):
            b.append(key_box(n["anahtar"]))
        b.append("</div>")
        out.append("".join(b))
    return "".join(out)


def build():
    bagli = [c for c in KARTLAR if c["durum"] == "bagli"]
    degisen = [c for c in bagli if c.get("degisti") and not c.get("yeni")]
    yeni = [c for c in KARTLAR if c.get("yeni")]
    degismeyen = [c for c in bagli if not c.get("degisti")]
    park = [c for c in KARTLAR if c["durum"] == "park"]
    sil = [c for c in KARTLAR if c["durum"] == "sil"]
    park_rows = [c for c in KARTLAR if c["durum"] in ("park", "sil")]

    counts = dict(degisen=len(degisen), yeni=len(yeni), degismeyen=len(degismeyen), park=len(park), sil=len(sil))

    body = []
    # head / toolbar
    toc = [
        ("s-bilgi", "Bilgi"),
        ("s-acik", "Açık noktalar"),
        ("s-degisen", "Metni değişen kartlar (%d)" % len(degisen)),
        ("s-yeni", "Yeni kartlar (%d)" % len(yeni)),
        ("s-degismeyen", "Metni değişmeyen kart (%d)" % len(degismeyen)),
        ("s-park", "Park listesi (%d)" % len(park_rows)),
        ("s-karar9", "Karar 9"),
        ("s-onay", "TR/EN onay bekliyor"),
        ("s-degistirici", "Değiştirici tablosu"),
    ]
    body.append(
        '<div class="toolbar"><div class="toolbar-in"><span class="tbl">Metin dili</span>'
        '<div class="seg" role="group" aria-label="Metin dili">'
        '<button type="button" data-lang="tr" aria-pressed="true">TR</button>'
        '<button type="button" data-lang="en" aria-pressed="false">EN</button></div>'
        '<span class="tbhint">Kart metinlerini ve kareleri çevirir</span></div></div>'
    )
    body.append('<main class="wrap">')
    body.append('<header class="top"><h1>%s</h1><p class="giris">%s</p>' % (esc(NOTES["baslik"]), esc_ph(NOTES["giris"])))
    body.append(
        '<p class="counts"><strong>%d</strong> metni değişen kart · <strong>%d</strong> yeni kart · '
        "<strong>%d</strong> metni değişmeyen oyundaki kart · <strong>%d</strong> park edilmiş kart · "
        "<strong>%d</strong> silinmiş kart</p>"
        % (counts["degisen"], counts["yeni"], counts["degismeyen"], counts["park"], counts["sil"])
    )
    body.append(
        '<nav class="toc" aria-label="İçindekiler"><ol>%s</ol></nav></header>'
        % "".join('<li><a href="#%s">%s</a></li>' % (a, esc(t)) for a, t in toc)
    )

    # 2 bilgi
    body.append('<section id="s-bilgi"><h2>Bilgi</h2>%s</section>' % notes_list(NOTES.get("bilgi", [])))
    # 3 acik
    body.append('<section id="s-acik"><h2>Açık noktalar</h2>%s</section>' % notes_list(NOTES.get("acik", [])))

    # 4 degisen
    nav = '<nav class="cardnav" aria-label="Kart listesi">%s</nav>' % "".join(
        '<a href="#%s"><span class="no">%s</span> %s</a>'
        % (slug(c), esc(c["no"]), lang_blocks_inline(lambda l, c=c: card_text(c["sonra"][l]["konu"], l)))
        for c in degisen
    )
    body.append(
        '<section id="s-degisen"><h2>Metni değişen kartlar</h2>'
        '<p class="lede">Önce = Erdem\'in okuduğu revize sayfası, sonra = oyundaki kart. Silik üstü çizili sözcük önceden vardı '
        "ve çıktı; altı çizili vurgulu sözcük sonradan geldi.</p>%s%s</section>"
        % (nav, "".join(render_changed(c) for c in degisen))
    )
    # 5 yeni
    body.append(
        '<section id="s-yeni"><h2>Yeni kartlar</h2>'
        '<p class="lede">Revize sayfasında karşılığı olmayan, şıklardan doğan ek kartlar. Yalnız sonraki metin var.</p>%s</section>'
        % "".join(render_new(c) for c in yeni)
    )
    # 6 degismeyen
    body.append(
        '<section id="s-degismeyen"><h2>Metni değişmeyen kart</h2>'
        '<p class="lede">Oyunda olan, metni revize sayfasıyla aynı kalan kart.</p>%s</section>'
        % "".join(render_unchanged(c) for c in degismeyen)
    )
    # 7 park
    body.append(
        '<section id="s-park"><h2>Park listesi</h2>'
        '<div class="tablewrap"><table class="park"><thead><tr><th>No</th><th>Revize</th><th>Kart</th><th>Not</th><th>Metin</th></tr></thead>'
        "<tbody>%s</tbody></table></div><p class=\"gerekce\">%s</p></section>"
        % ("".join(render_park(c) for c in park_rows), esc_ph(DATA.get("park_gerekce", "")))
    )
    # 8 karar9
    k9 = [
        [esc_ph(r["kart"]), esc_ph(r["kosul"]), esc_ph(r["secilen"]), esc_ph(r["reddedilen"])]
        for r in EXTRA.get("karar9", [])
    ]
    body.append(
        '<section id="s-karar9"><h2>Karar 9: oyunda karşılığı olmayan koşullar</h2>%s</section>'
        % table(["Kart", "Koşul", "Seçilen", "Reddedilen"], k9, "k9")
    )
    # 9 onay
    anchors = {c["kart"]: slug(c) for c in KARTLAR if c.get("kart")}
    li = []
    for r in EXTRA.get("onay_kartlar", []):
        a = anchors.get(r["kart"])
        label = "%s <code>%s</code>" % (esc(r["no"]), esc(r["kart"]))
        li.append('<li><a href="#%s">%s</a></li>' % (a, label) if a else "<li>%s</li>" % label)
    groups = []
    order = []
    for k in EXTRA.get("anahtarlar", []):
        if k["commit"] not in order:
            order.append(k["commit"])
    for cm in order:
        rows = [
            ["<code>%s</code>" % esc(k["anahtar"]), esc_ph(k["tr"]), esc_ph(k["en"])]
            for k in EXTRA["anahtarlar"]
            if k["commit"] == cm
        ]
        groups.append("<h3>%s</h3>%s" % (esc(cm), table(["Anahtar", "TR", "EN"], rows, "keys")))
    body.append(
        '<section id="s-onay"><h2>TR/EN onay bekliyor</h2><h3>Kartlar (%d)</h3><ul class="onaylist">%s</ul>'
        "<h3>Anahtarlar (%d)</h3>%s</section>"
        % (len(li), "".join(li), len(EXTRA.get("anahtarlar", [])), "".join(groups))
    )
    # 10 degistirici
    body.append(
        '<section id="s-degistirici"><h2>Değiştirici tablosu (bilgi)</h2><div class="md">%s</div></section>'
        % md_to_html(EXTRA["degistirici_md"])
    )
    body.append("</main>")

    doc = (
        "<!doctype html>\n"
        '<html lang="tr" class="lang-tr">\n<head>\n<meta charset="utf-8">\n'
        '<meta name="viewport" content="width=device-width, initial-scale=1">\n'
        "<title>Olaylar önce ve sonra</title>\n"
        '<meta name="color-scheme" content="light dark">\n'
        '<link rel="preconnect" href="https://fonts.googleapis.com">\n'
        '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>\n'
        '<link href="https://fonts.googleapis.com/css2?family=IBM+Plex+Mono:wght@400;500&amp;family=IBM+Plex+Sans:wght@400;500;600&amp;'
        'family=Source+Serif+4:ital,wght@0,400;0,600;1,400&amp;display=swap" rel="stylesheet">\n'
        "<style>\n" + CSS + "\n</style>\n"
        "<script>\n" + HEAD_JS + "\n</script>\n</head>\n<body>\n"
        + "\n".join(body)
        + "\n<script>\n" + BODY_JS + "\n</script>\n</body>\n</html>\n"
    )
    with open(os.path.join(P, "index.html"), "w", encoding="utf-8", newline="\n") as f:
        f.write(doc)
    return counts, len(degisen), len(yeni), len(degismeyen), len(park_rows)


# ---------------------------------------------------------------- css / js

CSS = r"""
:root{
  --bg:#f7f4ee; --surface:#fffdf8; --surface-2:#f0ebe1; --ink:#26231e; --ink-2:#5a554b; --ink-3:#847d70;
  --rule:#ddd5c6; --accent:#9a3b1f; --link:#7a2f19;
  --del-bg:#f6d9d2; --del-ink:#7d1f0e; --ins-bg:#cfe8d0; --ins-ink:#164a1d;
  --chip-bg:#e6e0d2; --chip-ink:#3a352b; --chip-line:#cfc6b2;
  --ok-bg:#dcebd8; --ok-ink:#25521d; --pend-bg:#f7e5b7; --pend-ink:#6b4a05;
  --lock:#8a5a00; --shadow:0 1px 0 rgba(0,0,0,.04);
  --sans:"IBM Plex Sans",system-ui,-apple-system,"Segoe UI",sans-serif;
  --serif:"Source Serif 4",Georgia,"Times New Roman",serif;
  --mono:"IBM Plex Mono",ui-monospace,Consolas,monospace;
}
@media (prefers-color-scheme: dark){
  :root:not([data-theme="light"]){
    --bg:#16140f; --surface:#1e1b15; --surface-2:#27231b; --ink:#ece6d8; --ink-2:#b4ad9c; --ink-3:#8b8473;
    --rule:#38332a; --accent:#e58a63; --link:#eba07f;
    --del-bg:#58211a; --del-ink:#ffc9bd; --ins-bg:#1f4a27; --ins-ink:#c4f0c8;
    --chip-bg:#332e24; --chip-ink:#e3dcc9; --chip-line:#4a4436;
    --ok-bg:#1f3a1d; --ok-ink:#b9e5b3; --pend-bg:#4a3a0c; --pend-ink:#f1d98c; --lock:#e2b252;
  }
}
:root[data-theme="dark"]{
  --bg:#16140f; --surface:#1e1b15; --surface-2:#27231b; --ink:#ece6d8; --ink-2:#b4ad9c; --ink-3:#8b8473;
  --rule:#38332a; --accent:#e58a63; --link:#eba07f;
  --del-bg:#58211a; --del-ink:#ffc9bd; --ins-bg:#1f4a27; --ins-ink:#c4f0c8;
  --chip-bg:#332e24; --chip-ink:#e3dcc9; --chip-line:#4a4436;
  --ok-bg:#1f3a1d; --ok-ink:#b9e5b3; --pend-bg:#4a3a0c; --pend-ink:#f1d98c; --lock:#e2b252;
}
*{box-sizing:border-box}
html{scroll-behavior:smooth;scroll-padding-top:64px;-webkit-text-size-adjust:100%}
body{margin:0;background:var(--bg);color:var(--ink);font-family:var(--sans);font-size:16px;line-height:1.55}
html.lang-tr .l-en{display:none !important}
html.lang-en .l-tr{display:none !important}
a{color:var(--link);text-underline-offset:2px}
code{font-family:var(--mono);font-size:.85em;background:var(--surface-2);padding:.08em .35em;border-radius:3px;overflow-wrap:anywhere}
.wrap{max-width:1120px;margin:0 auto;padding:0 16px 80px}
.toolbar{position:sticky;top:0;z-index:20;background:var(--bg);border-bottom:1px solid var(--rule)}
.toolbar-in{max-width:1120px;margin:0 auto;padding:8px 16px;display:flex;align-items:center;gap:12px;flex-wrap:wrap}
.tbl{font-size:.8rem;color:var(--ink-2);text-transform:uppercase;letter-spacing:.06em}
.tbhint{font-size:.8rem;color:var(--ink-3)}
.seg{display:inline-flex;border:1px solid var(--ink-3);border-radius:6px;overflow:hidden}
.seg button{font:inherit;font-size:.85rem;font-weight:600;padding:5px 16px;border:0;background:transparent;color:var(--ink);cursor:pointer}
.seg button+button{border-left:1px solid var(--ink-3)}
.seg button[aria-pressed="true"]{background:var(--ink);color:var(--bg)}
.seg button:focus-visible{outline:2px solid var(--accent);outline-offset:-2px}
h1{font-family:var(--serif);font-weight:600;font-size:clamp(1.9rem,5vw,2.8rem);line-height:1.15;margin:40px 0 12px;letter-spacing:-.01em}
h2{font-family:var(--serif);font-weight:600;font-size:1.7rem;line-height:1.2;margin:0 0 14px;padding-top:18px;border-top:2px solid var(--ink)}
h3{font-size:1.05rem;margin:22px 0 6px}
main>section{margin-top:64px}
.top .giris{font-family:var(--serif);font-size:1.12rem;max-width:68ch;color:var(--ink-2)}
.counts{font-size:.92rem;color:var(--ink-2);padding:10px 14px;background:var(--surface);border:1px solid var(--rule);border-radius:6px}
.counts strong{color:var(--ink)}
.toc ol{list-style:none;margin:16px 0 0;padding:0;display:flex;flex-wrap:wrap;gap:6px 8px}
.toc a{display:inline-block;padding:4px 10px;border:1px solid var(--rule);border-radius:999px;font-size:.85rem;text-decoration:none;background:var(--surface)}
.toc a:hover{border-color:var(--accent)}
.lede{max-width:70ch;color:var(--ink-2)}
.note{max-width:78ch;margin:0 0 18px}
.note h3{margin:18px 0 4px}
.note p{margin:0 0 10px}
.keybox{border:1px solid var(--rule);background:var(--surface);border-radius:6px;padding:10px 12px;margin:8px 0}
.kcols{display:grid;grid-template-columns:1fr;gap:8px;margin-top:6px;font-family:var(--serif)}
.lbl{font-family:var(--sans);font-size:.7rem;font-weight:600;letter-spacing:.06em;color:var(--ink-3);text-transform:uppercase;margin-right:6px}
.muted{color:var(--ink-3)}
.tablewrap{overflow-x:auto;max-width:100%;margin:10px 0;border:1px solid var(--rule);border-radius:6px;background:var(--surface);-webkit-overflow-scrolling:touch}
table{border-collapse:collapse;width:100%;font-size:.88rem}
th,td{text-align:left;vertical-align:top;padding:7px 10px;border-bottom:1px solid var(--rule)}
th{background:var(--surface-2);font-weight:600;font-size:.78rem;text-transform:uppercase;letter-spacing:.04em;color:var(--ink-2);white-space:nowrap}
tr:last-child td{border-bottom:0}
table.keys td:nth-child(2),table.keys td:nth-child(3){min-width:200px}
table.k9 td,table.md td{min-width:150px}
table.park td:last-child{min-width:240px}
table.park td:nth-child(-n+3){white-space:nowrap}
table.park td:nth-child(4){min-width:220px}
.nowrap,table.num code{white-space:nowrap}
.ph{font-family:var(--mono);font-size:.82em;border:1px dashed var(--ink-3);border-radius:3px;padding:0 .3em;color:var(--ink-2);white-space:nowrap}
.chip{display:inline-block;font-family:var(--sans);font-size:.78em;font-weight:500;background:var(--chip-bg);color:var(--chip-ink);border:1px solid var(--chip-line);border-radius:999px;padding:0 .55em;line-height:1.5;vertical-align:.05em;white-space:nowrap}
.cardnav{display:flex;flex-wrap:wrap;gap:6px;margin:12px 0 26px}
.cardnav a{font-size:.8rem;text-decoration:none;border:1px solid var(--rule);border-radius:4px;padding:2px 8px;background:var(--surface);color:var(--ink)}
.cardnav a:hover{border-color:var(--accent)}
.no{font-family:var(--mono);font-weight:500;color:var(--accent);margin-right:.25em}
.card{background:var(--surface);border:1px solid var(--rule);border-radius:8px;padding:18px 18px 16px;margin:0 0 28px;box-shadow:var(--shadow)}
.chead{margin-bottom:10px}
.ctit{font-family:var(--serif);font-size:1.4rem;line-height:1.25;margin:0 0 6px;font-weight:600}
.cmeta{display:flex;flex-wrap:wrap;align-items:center;gap:6px 12px;font-size:.82rem;color:var(--ink-2)}
.ids{font-family:var(--mono);font-size:.76rem;color:var(--ink-3);overflow-wrap:anywhere}
.badge{display:inline-block;font-size:.74rem;font-weight:600;padding:1px 9px;border-radius:999px;border:1px solid transparent}
.badge.pend{background:var(--pend-bg);color:var(--pend-ink);border-color:var(--pend-ink)}
.badge.ok{background:var(--ok-bg);color:var(--ok-ink);border-color:var(--ok-ink)}
.neden{margin:8px 0 14px;font-size:.9rem}
.neden summary,.mdsec summary,.park details summary{cursor:pointer;color:var(--ink-2);font-weight:500}
.neden ul{margin:8px 0 0;padding-left:20px;max-width:78ch;color:var(--ink-2)}
.neden li{margin-bottom:6px}
.cols{display:grid;grid-template-columns:1fr;gap:14px;margin:6px 0 16px}
.col{border:1px solid var(--rule);border-radius:6px;padding:12px 14px;background:var(--bg);min-width:0}
.col.sonra{border-color:var(--ink-3)}
.col h4{margin:0 0 8px;font-size:.72rem;letter-spacing:.09em;text-transform:uppercase;color:var(--ink-3)}
.sender{font-size:.85rem;color:var(--ink-2);margin-bottom:2px}
.ctitle{font-family:var(--serif);font-size:1.12rem;margin:0 0 6px;font-weight:600}
.cbody{font-family:var(--serif);font-size:1.02rem;line-height:1.6;margin:0 0 12px;max-width:62ch}
.opts{list-style:none;counter-reset:o;margin:0;padding:0}
.opts li{counter-increment:o;position:relative;padding:7px 0 7px 26px;border-top:1px solid var(--rule)}
.opts li::before{content:counter(o);position:absolute;left:0;top:7px;width:18px;height:18px;border-radius:50%;border:1px solid var(--ink-3);font-size:.7rem;text-align:center;line-height:16px;color:var(--ink-2);font-family:var(--mono)}
.olabel{font-family:var(--serif);font-weight:600;font-size:.98rem}
.oout{font-size:.86rem;color:var(--ink-3);margin-top:2px}
.olock{font-size:.82rem;color:var(--lock);margin-top:3px}
.olock .lockmark{font-size:.6em;vertical-align:.15em}
.key{font-size:.72rem}
.noans{margin-top:12px;font-size:.88rem;color:var(--ink-2);border-left:3px solid var(--rule);padding-left:10px}
del{background:var(--del-bg);color:var(--del-ink);text-decoration:line-through;text-decoration-thickness:1.5px;border-radius:2px;padding:0 1px}
ins{background:var(--ins-bg);color:var(--ins-ink);text-decoration:underline;text-decoration-thickness:1.5px;text-underline-offset:3px;border-radius:2px;padding:0 1px;font-weight:600}
.shots{display:grid;grid-template-columns:1fr;gap:12px;margin:14px 0 0}
.shots figure{margin:0;min-width:0}
.shots img{display:block;max-width:100%;height:auto;border:1px solid var(--rule);border-radius:6px;background:var(--surface-2)}
.shots figcaption{font-size:.78rem;color:var(--ink-2);margin-top:4px}
.pin{font-size:.84rem;color:var(--ink-2);margin:8px 0 0;max-width:100ch}
.pin.none{color:var(--ink-3)}
.slim .chead{margin-bottom:0}
.onaylist{columns:1;padding-left:18px;font-size:.9rem}
.onaylist li{break-inside:avoid;margin-bottom:3px}
.gerekce{margin-top:10px;color:var(--ink-2)}
.md-intro p{max-width:78ch}
.mdsec{border:1px solid var(--rule);border-radius:6px;background:var(--surface);margin:10px 0;padding:0 14px}
.mdsec summary{padding:10px 0;font-weight:600;color:var(--ink)}
.mdsec[open] summary{border-bottom:1px solid var(--rule);margin-bottom:8px}
.mdsec ul{padding-left:20px;max-width:90ch}
.mdsec ul ul{margin-top:4px}
.mdsec li{margin-bottom:4px}
.mdsec h3,.mdsec h4{font-size:1rem}
details>summary:focus-visible{outline:2px solid var(--accent);outline-offset:2px}
@media (min-width:760px){
  .wrap,.toolbar-in{padding-left:24px;padding-right:24px}
  .cols:not(.single){grid-template-columns:1fr 1fr}
  .cols.single{max-width:560px}
  .shots:not(.one){grid-template-columns:1fr 1fr}
  .shots.one{max-width:520px}
  .kcols{grid-template-columns:1fr 1fr}
  .onaylist{columns:2}
  .card{padding:22px 24px 20px}
}
@media (min-width:1100px){
  .onaylist{columns:3}
}
"""

HEAD_JS = r"""
(function () {
  var l = "tr";
  try {
    var s = localStorage.getItem("olaylar-dil");
    if (s === "en" || s === "tr") { l = s; }
  } catch (e) {}
  document.documentElement.className = "lang-" + l;
})();
"""

BODY_JS = r"""
(function () {
  var root = document.documentElement;
  var btns = document.querySelectorAll(".seg button");
  function loadImages(l) {
    var imgs = document.querySelectorAll(".l-" + l + " img[data-src]");
    for (var i = 0; i < imgs.length; i++) {
      imgs[i].src = imgs[i].getAttribute("data-src");
      imgs[i].removeAttribute("data-src");
    }
  }
  function setLang(l, save) {
    root.className = "lang-" + l;
    for (var i = 0; i < btns.length; i++) {
      btns[i].setAttribute("aria-pressed", btns[i].getAttribute("data-lang") === l ? "true" : "false");
    }
    loadImages(l);
    if (save) {
      try { localStorage.setItem("olaylar-dil", l); } catch (e) {}
    }
  }
  for (var i = 0; i < btns.length; i++) {
    btns[i].addEventListener("click", function () { setLang(this.getAttribute("data-lang"), true); });
  }
  setLang(root.className.indexOf("lang-en") >= 0 ? "en" : "tr", false);
})();
"""

if __name__ == "__main__":
    res = build()
    print("counts:", res)
    sys.exit(0)
