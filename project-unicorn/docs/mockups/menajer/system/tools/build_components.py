"""Builds the Menajer Masası design-system sheet.

  ../components.html          every page stacked (open in a browser; the overflow report runs on load)
  ../build/page_NN.html       one page per file, rendered by render_pages.sh (a 16-page screenshot would pass
                              Chrome's 16384 px texture limit)
  ../build/screen_1920.html   the shell with the Ekip window over the office at 1920x1080 (100 % legibility check)
  ../build/screen_1536.html   the same at the narrowest logical size, 1536x864 (125 % at 1280x720, finding 14)

Data comes from ../../data/screens.md (seed 424242, week 14), data/crowd40.json and localization/strings.csv;
anything else is marked "örnek" on the page. Icons come from ../icons/ (A2) and glyphs_local.py (A2 backlog);
portraits from ../../portraits/ (A3), read at build time so a re-shoot flows in.

  python build_components.py && bash render_pages.sh
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import common  # noqa: E402
from common import FONTS, SYS, ART  # noqa: E402
import kit  # noqa: E402
import pages_core  # noqa: E402
import pages_more  # noqa: E402

PAGES = [("01_renk", pages_core.p1), ("02_yazi", pages_core.p2), ("03_kontroller", pages_core.p3), ("04_veri", pages_core.p4),
         ("05_gelen_kutusu", pages_core.p5), ("06_karar", pages_core.p6), ("07_kabuk", pages_core.p7), ("08_renk_koru", pages_core.p8),
         ("09_yerlesim", pages_core.p9), ("10_portre", pages_more.p10), ("11_grafik", pages_more.p11), ("12_alan", pages_more.p12),
         ("13_toplanti_acilis", pages_more.p13), ("14_diyalog_metin", pages_more.p14), ("15_en_kabuk", pages_more.p15),
         ("16_en_ekip", pages_more.p16)]
pages_core.TOTAL = len(PAGES)

DOC_CSS = r"""
html, body { width: 1920px; background: #0B0A08; }
.page { position: relative; width: 1920px; height: 1080px; overflow: hidden; background: var(--surface-0); }
.doc-h { position: absolute; left: 48px; top: 22px; display: flex; align-items: baseline; gap: 16px; }
.doc-h .no { color: var(--ink-3); }
.doc-h .t { color: var(--ink-1); }
.doc-h .s { color: var(--ink-3); }
.doc-mark { position: absolute; right: 48px; top: 30px; color: var(--ink-3); }
.cap { display: flex; align-items: center; gap: 12px; color: var(--ink-3); margin-bottom: 12px; }
.cap::after { content: ""; flex: 1; height: 1px; background: var(--line-1); }
.note { font-size: var(--fs-13); line-height: var(--lh-13); color: var(--ink-3); }
.note b { color: var(--ink-2); font-weight: 600; }
.abs { position: absolute; }
.sw-row { display: flex; align-items: center; gap: 14px; height: 50px; }
.sw { width: 96px; height: 38px; flex: none; border-radius: var(--r-2); box-shadow: inset 0 0 0 1px rgba(255,255,255,.06); }
.sw-txt { display: flex; flex-direction: column; min-width: 0; }
.sw-n { font-weight: 600; font-size: var(--fs-15); line-height: var(--lh-15); color: var(--ink-1); }
.sw-m { font-size: var(--fs-13); line-height: var(--lh-13); color: var(--ink-3); white-space: nowrap; }
.pane-demo { background: var(--surface-3); border: 1px solid var(--line-2); border-radius: var(--r-3); }
.state-grid { display: grid; align-items: center; row-gap: 14px; column-gap: 16px; }
.state-grid .h { color: var(--ink-3); }
/* measurement pass only (see MEASURE): about 8% wider text, caps keep their 1 px tracking */
.godot-wide .page * { letter-spacing: 0.045em !important; }
.godot-wide .page .t-h1, .godot-wide .page .t-tab, .godot-wide .page .t-gate, .godot-wide .page .t-nav, .godot-wide .page .t-group,
.godot-wide .page .t-label, .godot-wide .page .t-tag, .godot-wide .page .t-micro, .godot-wide .page .tag, .godot-wide .page .pill,
.godot-wide .page .rel, .godot-wide .page .t-stamp { letter-spacing: calc(1px + 0.045em) !important; }
"""

# Overflow report for --dump-dom: clipped text, and text that would not survive Godot's wider rendering
# (8 % slack) inside fixed-width boxes; plus the week-bar length of every top bar (one length per bar width).
MEASURE = r"""<script>
window.addEventListener('load',()=>{document.fonts.ready.then(()=>{
 const out=[];
 const pg=e=>{const p=e.closest('.page');return p?p.querySelector('.doc-h .no').textContent:'?';};
 document.querySelectorAll('.page *').forEach(e=>{
   if(e.closest('svg')) return;
   if(e.children.length===0 && e.textContent.trim() && getComputedStyle(e).display!=='inline' && e.scrollWidth>e.clientWidth+1 && !e.classList.contains('ell') && getComputedStyle(e).textOverflow!=='ellipsis')
     out.push('clip '+e.className+' "'+e.textContent.trim().slice(0,40)+'" '+e.scrollWidth+'>'+e.clientWidth+' (page '+pg(e)+')');
 });
 const snap=()=>{ const m=new Map(); document.querySelectorAll('.page *').forEach(e=>m.set(e,[e.scrollWidth>e.clientWidth+1,e.getBoundingClientRect().height])); return m; };
 const before=snap(); document.body.classList.add('godot-wide');
 document.querySelectorAll('.page').forEach(p=>p.querySelectorAll('*').forEach(e=>{
   if(e.closest('svg')||e.closest('.tk-run')||e.closest('.note')||e.closest('.doc-h')) return;
   const b=before.get(e); if(!b) return;
   const ellipsis=getComputedStyle(e).textOverflow==='ellipsis';
   if(e.scrollWidth>e.clientWidth+1 && !b[0] && e.clientWidth>0 && !ellipsis)
     out.push('slack '+(e.className.baseVal!==undefined?'svg':e.className)+' "'+e.textContent.trim().replace(/\s+/g,' ').slice(0,44)+'" '+e.scrollWidth+' > '+e.clientWidth+' (page '+pg(e)+')');
   const h=e.getBoundingClientRect().height;
   if(e.children.length===0 && e.textContent.trim() && h>b[1]+4)
     out.push('wrap '+e.className+' "'+e.textContent.trim().slice(0,44)+'" '+b[1].toFixed(0)+' -> '+h.toFixed(0)+' (page '+pg(e)+')');
 }));
 document.body.classList.remove('godot-wide');
 const wk={}; document.querySelectorAll('.topbar').forEach(t=>{const w=t.getBoundingClientRect().width;const b=t.querySelector('.wk');if(!b)return;(wk[w]=wk[w]||new Set()).add(Math.round(b.getBoundingClientRect().width));});
 Object.keys(wk).forEach(w=>out.push('weekbar bar-width '+w+': '+[...wk[w]].join(', ')+(wk[w].size===1?' (one length)':' **CHANGES**')));
 const pre=document.createElement('pre');pre.id='report';pre.style.display='none';pre.textContent=out.join('\n')||'clean';document.body.appendChild(pre);
});});
</script>"""


def head(title, extra_css="", base="../"):
    return ('<!doctype html>\n<html lang="tr"><head><meta charset="utf-8"><title>%s</title>'
            '<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
            '<link href="%s" rel="stylesheet"><link rel="stylesheet" href="%stokens.css"><link rel="stylesheet" href="%sbase.css">'
            '<style>%s%s</style></head>' % (title, FONTS, base, base, DOC_CSS, extra_css))


def screen(W, H, compact):
    """The shell over the dimmed office with the Ekip window: what the player sees, at one logical size."""
    rail_w = 64 if compact else 184
    win_x = rail_w + 24
    body = ('<div class="office is-dimmed" style="background-image:url(%s/office_full.png);background-size:cover;background-position:center"></div>'
            '%s%s%s%s' % (ART, kit.topbar("normal", compact=compact, W=W),
                          kit.rail("ekip", icons=compact), kit.ekip_window(win_x, 88, states={"elif": "is-selected"}),
                          kit.ticker()))
    css = "html, body { width: %dpx; height: %dpx; overflow: hidden; } .screen { position: relative; width: %dpx; height: %dpx; overflow: hidden; }" % (W, H, W, H)
    return head("Ekran %dx%d" % (W, H), css) + '<body><div class="screen">%s</div></body></html>' % body


def fix_paths(html, depth):
    """Pages are generated with paths relative to system/; build/ files sit one level deeper."""
    if depth == 0:
        return html
    html = html.replace('src="../', 'src="../../').replace("url(../", "url(../../").replace('src="pages/', 'src="../pages/')
    return html


def build():
    os.makedirs(os.path.join(SYS, "build"), exist_ok=True)
    rendered = [(name, fn()) for name, fn in PAGES]
    full = (head("Menajer Masası: tasarım sistemi", base="") + '<body>\n%s\n%s</body></html>'
            % ("\n".join(h for _, h in rendered), MEASURE))
    for name, html in [("components.html", full)]:
        bad = re.findall(r"[–—]", html)
        if bad:
            sys.exit("dash found in %s: %d" % (name, len(bad)))
        open(os.path.join(SYS, name), "w", encoding="utf-8", newline="\n").write(html)
    for i, (name, h) in enumerate(rendered):
        one = head(name) + '<body>%s</body></html>' % fix_paths(h, 1)
        open(os.path.join(SYS, "build", "page_%02d.html" % (i + 1)), "w", encoding="utf-8", newline="\n").write(one)
    for W, H, c in ((1920, 1080, False), (1536, 864, True)):
        open(os.path.join(SYS, "build", "screen_%d.html" % W), "w", encoding="utf-8", newline="\n").write(fix_paths(screen(W, H, c), 1))
    city = head("Ofis katmanı", "html, body { width: 1920px; height: 1080px; overflow: hidden; } "
                "body > .screen { position: relative; width: 1920px; height: 1080px; overflow: hidden; background: var(--surface-0); }")
    city += '<body><div class="screen">%s</div></body></html>' % pages_more.city_screen()
    for name, html in [("screen_city.html", city)] + [("page_%02d.html" % (i + 1), h) for i, (_, h) in enumerate(rendered)]:
        if re.findall(r"[–—]", html):
            sys.exit("dash found in %s" % name)
    open(os.path.join(SYS, "build", "screen_city.html"), "w", encoding="utf-8", newline="\n").write(fix_paths(city, 1))
    a2, local = common.icon_sources()
    print("components.html: %d pages, %d bytes; icons from A2: %d, backlog: %s" % (len(rendered), len(full), len(a2), ", ".join(local)))
    print("week bar: 1920 %d px, 1536 %d px, 2560 %d px" % (kit.tb_week_bar_len(False, 1920), kit.tb_week_bar_len(True, 1536), kit.tb_week_bar_len(False, 2560)))


if __name__ == "__main__":
    build()
