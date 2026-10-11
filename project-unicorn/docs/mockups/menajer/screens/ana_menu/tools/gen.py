# Writes the main-menu frames (HTML) beside menu2.css. Render with tools/render_all.sh.
import os, re, math
from lockup import lockup
HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.dirname(HERE).replace("\\", "/")
V1 = HERE + "/v1"
HEAD = """<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><title>{title}</title>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&family=IBM+Plex+Sans+Condensed:wght@400&family=IBM+Plex+Sans:wght@400;500;600;700&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&display=block" rel="stylesheet">
<link rel="stylesheet" href="../../system/tokens.css"><link rel="stylesheet" href="../../system/base.css"><link rel="stylesheet" href="../modallar_acilis/modallar.css"><link rel="stylesheet" href="menu_v1.css"><link rel="stylesheet" href="menu2.css">
<style>:root{{ --plate:url("art/plate_evening_{res}.png"); }}</style>
</head><body class="{body}"><div class="pm">"""
def head(title, lang="tr", w1536=False):
    return HEAD.format(lang=lang, title=title, res="1536" if w1536 else "1920", body="w1536" if w1536 else "")
TAIL = "</div></body></html>"

# ---- emblem: monogram x shape x palette colour x style (filled / outline / split)
def shape_path(shape, s, inset):
    c = s / 2
    if shape == "hex":
        r = c - inset
        pts = [(c + r * math.cos(math.radians(60 * k - 90)), c + r * math.sin(math.radians(60 * k - 90))) for k in range(6)]
        return "M" + " L".join("%.1f %.1f" % p for p in pts) + " Z"
    if shape == "circle":
        r = c - inset
        return "M %.1f %.1f a %.1f %.1f 0 1 0 %.1f 0 a %.1f %.1f 0 1 0 %.1f 0 Z" % (c - r, c, r, r, 2 * r, r, r, -2 * r)
    a, z = inset, s - inset
    return "M %.1f %.1f H %.1f V %.1f H %.1f Z" % (a, a, z, z, a)

def emblem(mono, shape, colour, style, size):
    d = shape_path(shape, size, 2.5 if style == "outline" else 0)
    if style == "filled":
        svg = '<path d="%s" fill="%s"/>' % (d, colour); ink = "var(--surface-0)"
    elif style == "outline":
        svg = '<path d="%s" fill="none" stroke="%s" stroke-width="2.5"/>' % (d, colour); ink = colour
    else:
        cid = "c%s%d" % (mono, size)
        svg = ('<defs><clipPath id="%s"><path d="%s"/></clipPath></defs><path d="%s" fill="var(--surface-5)"/>'
               '<path d="M0 %d L%d 0 L%d %d Z" fill="%s" clip-path="url(#%s)"/>') % (cid, d, d, size, size, size, size, colour, cid)
        ink = "var(--ink-1)"
    fs = round(size * (0.50 if len(mono) == 1 else 0.40))
    return ('<span class="pm-emb" style="width:%dpx;height:%dpx"><svg viewBox="0 0 %d %d">%s</svg>'
            '<b style="font-size:%dpx;color:%s">%s</b></span>') % (size, size, size, size, svg, fs, ink, mono)
TEAL, CLAY = "#5FA8A2", "#D9825F"

# ---- Godot mark: the engine's own icon.svg head without its background square. Logo: Andrea Calabró, CC BY 4.0.
def godot(size, mono=False, hole="var(--surface-0)"):
    if mono:
        blue, jaw, white, pupil = "var(--ink-3)", "var(--ink-3)", hole, "var(--ink-3)"
    else:
        blue, jaw, white, pupil = "#478cbf", "#fff", "#fff", "#414042"
    head_d = ("m105 673 152 14q12 1 15 14l4 67 132 10 8-61q2-11 15-15h162q13 4 15 15l8 61 132-10 4-67q3-13 15-14l152-14V427"
              "q30-39 56-81-35-59-83-108-43 20-82 47-40-37-88-64 7-51 8-102-59-28-123-42-26 43-46 89-49-7-98 0-20-46-46-89"
              "-64 14-123 42 1 51 8 102-48 27-88 64-39-27-82-47-48 49-83 108 26 42 56 81zm0 33v39c0 276 813 276 814 0v-39"
              "l-134 12-5 69q-2 10-14 13l-162 11q-12 0-16-11l-10-65H446l-10 65q-4 11-16 11l-162-11q-12-3-14-13l-5-69z")
    return ('<svg width="%d" height="%d" viewBox="90 60 844 860" xmlns="http://www.w3.org/2000/svg">'
            '<path fill="%s" d="M105 673v33q407 354 814 0v-33z"/><path fill="%s" d="%s"/>'
            '<g fill="%s"><path d="M483 600c0 34 58 34 58 0v-86c0-34-58-34-58 0z"/><circle cx="725" cy="526" r="90"/><circle cx="299" cy="526" r="90"/></g>'
            '<g fill="%s"><circle cx="307" cy="532" r="60"/><circle cx="717" cy="532" r="60"/></g></svg>'
            ) % (size, round(size * 860 / 844), jaw, blue, head_d, white, pupil)

T = {
 "tr": dict(cont="Devam", new="Yeni oyun", load="Yükle", set="Ayarlar", cred="Jenerik", quit="Masaüstüne çık",
            ver="Demo · Sürüm 0.4.0", week="Hafta", cash="Kasa", cashv="$10.000", when="2 saat önce oynandı"),
 "en": dict(cont="Continue", new="New game", load="Load", set="Settings", cred="Credits", quit="Quit to desktop",
            ver="Demo · Version 0.4.0", week="Week", cash="Cash", cashv="$10,000", when="Played 2 hours ago"),
}
def menu(lang="tr", save=False, w1536=False):
    t = T[lang]
    items = []
    if save:
        items.append('<div class="pm-cont doc-sm"><div class="pm-lbl">%s<span class="u"></span></div><div class="pm-row">%s'
            '<div class="pm-who"><span class="pm-co">Unicorn Inc.</span><span class="pm-facts"><span class="k">%s</span> 14 · <span class="k">%s</span> %s</span>'
            '<span class="pm-when">%s</span></div></div></div>' % (t["cont"], emblem("U", "hex", TEAL, "filled", 64), t["week"], t["cash"], t["cashv"], t["when"]))
        items.append('<div class="pm-it">%s</div><div class="pm-it">%s</div>' % (t["new"], t["load"]))
    else:
        items.append('<div class="pm-it is-primary">%s<span class="u"></span></div>' % t["new"])
    items.append('<div class="pm-it">%s</div><div class="pm-it">%s</div><div class="pm-gap"></div><div class="pm-it">%s</div>' % (t["set"], t["cred"], t["quit"]))
    return ('<div class="pm-plate"></div><div class="pm-col">%s<div class="pm-list">%s</div></div>'
            '<span class="pm-ver t-meta">%s</span>') % (lockup(76 if w1536 else 96), "".join(items), t["ver"])

def write(name, html):
    open(os.path.join(OUT, name + ".html"), "w", encoding="utf-8").write(html)

write("01_acilis_wordmark", head("Açılış") + '<div class="pm-boot">%s</div>' % lockup(128) + TAIL)
write("01b_godot_karti", head("Godot kartı") + '<div class="pm-boot"><div class="pm-godot">%s<span class="ln">Godot Engine ile yapıldı.</span></div></div>' % godot(132) + TAIL)
write("02_ana_ilk_kosu", head("Ana menü") + menu() + TAIL)
write("03_ana_devam", head("Ana menü · Devam") + menu(save=True) + TAIL)
write("04_ana_devam_en", head("Main menu · Continue", "en") + menu("en", save=True) + TAIL)
write("10_ana_1536", head("Ana menü 1536", w1536=True) + menu(save=True, w1536=True) + TAIL)
write("11_ana_en_1536", head("Main menu 1536", "en", w1536=True) + menu("en", save=True, w1536=True) + TAIL)

# 05 Yükle: the approved SaveLoadModal block, founder dropped from the group heads, emblems in the new system
blk = open(V1 + "/06_yukle_panel.html", encoding="utf-8").read()
blk = re.sub(r'<span class="av av-24">.*?</span>Deniz · ', "", blk, flags=re.S)
embs = iter([emblem("U", "hex", TEAL, "filled", 32), emblem("PP", "circle", CLAY, "outline", 32)])
blk = re.sub(r'<span class="emb seal".*?</b></span>', lambda m: next(embs), blk, flags=re.S)
write("05_yukle_panel", head("Yükle") + menu(save=True) + blk + TAIL)

# 06 Ayarlar: the approved window, unchanged, over the new menu
write("06_ayarlar", head("Ayarlar") + menu(save=True) + open(V1 + "/07_ayarlar_giris.html", encoding="utf-8").read() + TAIL)

# 07 Jenerik
roles = [("Oyun tasarımı ve yapım", "Ad Soyad"), ("Programlama", "Ad Soyad"), ("Yazı", "Ad Soyad"),
         ("3B ofis ve karakterler", "Ad Soyad"), ("Arayüz", "Ad Soyad")]
rows = "".join('<span class="r">%s</span><span class="n">%s</span>' % r for r in roles)
W, H = 880, 700
jen = ('<div class="scrim"></div><div class="on-scrim" style="left:%dpx;top:%dpx"><section class="modal" style="width:%dpx;height:%dpx">'
       '<div class="dlg-h"><h1 class="t t-h1">Jenerik</h1></div><div class="dlg-body"><div class="cr-body">'
       '%s<span class="ver t-meta">Demo · Sürüm 0.4.0</span>'
       '<div class="cr-roles">%s</div>'
       '<div class="cr-foot"><span class="cr-made">%sGodot Engine ile yapıldı.</span>'
       '<span class="cr-copy">© 2026 Telif sahibi. Tüm hakları saklıdır.</span></div></div></div>'
       '<div class="dlg-f"><span class="btn btn-ghost">Lisanslar</span><span class="grow"></span><span class="btn btn-secondary is-focus">Kapat</span></div>'
       '</section></div>') % ((1920 - W) // 2, (1080 - H) // 2, W, H, lockup(48), rows, godot(28, mono=True, hole="var(--surface-3)"))
write("07_jenerik", head("Jenerik") + menu(save=True) + jen + TAIL)

# 08 Lisanslar: one plain scrolling text page in the original language; no folds, no index, no notes
MIT = ('Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files '
       '(the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, '
       'publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, '
       'subject to the following conditions:</p><p>The above copyright notice and this permission notice shall be included in all copies or '
       'substantial portions of the Software.</p><p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, '
       'INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL '
       'THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR '
       'OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.')
comps = [("Godot Engine logo", "2017, Andrea Calabró", "CC-BY-4.0"), ("AccessKit", "2023, The AccessKit Authors.", "Expat"),
         ("Basis Universal", "2019-2025, Binomial LLC.", "Apache-2.0"), ("Brotli", "2009, 2010, 2013-2016 by the Brotli Authors.", "Expat"),
         ("ENet", "2002-2024, Lee Salzman", "Expat"), ("Mbed TLS", "The Mbed TLS Contributors", "Apache-2.0")]
lic = ('<h2>Godot Engine</h2><p>This game uses Godot Engine, available under the following license:</p>'
       '<p>Copyright (c) 2014-present Godot Engine contributors.<br>Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.</p><p>' + MIT + '</p>'
       '<p>Portions of this software are copyright © 2025 The FreeType Project (https://freetype.org). All rights reserved.</p>'
       '<h2>Third-party notices</h2>' + "".join('<p>%s<br><span class="c">Copyright: %s · License: %s</span></p>' % c for c in comps) +
       '<h2>Fonts</h2><p>Barlow Condensed<br><span class="c">Copyright 2017 The Barlow Project Authors (https://github.com/jpt/barlow)</span></p>')
W2, H2 = 960, 920
lis = ('<div class="scrim"></div><div class="on-scrim" style="left:%dpx;top:%dpx"><section class="modal" style="width:%dpx;height:%dpx">'
       '<div class="dlg-h"><h1 class="t t-h1">Lisanslar</h1></div><div class="dlg-body"><div class="lic">%s</div>'
       '<div class="sb" style="right:6px;top:8px;height:%dpx"><div class="sb-thumb" style="top:0;height:64px"></div></div></div>'
       '<div class="dlg-f"><span class="btn btn-ghost">Geri</span><span class="grow"></span><span class="btn btn-secondary is-focus">Kapat</span></div>'
       '</section></div>') % ((1920 - W2) // 2, (1080 - H2) // 2, W2, H2, lic, H2 - 72 - 73 - 16)
write("08_lisanslar", head("Lisanslar") + menu(save=True) + lis + TAIL)
print("ok")
