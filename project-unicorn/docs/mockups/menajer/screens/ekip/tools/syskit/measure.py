"""Measures text runs in headless Chrome with the real faces and the type classes of ../tokens.css.

  measure([(id, css_class, text[, lang]), ...]) -> {id: width_px}   (Chrome width, no Godot slack; lang sets
                                                                    the caps rule, tr gives the dotted İ)
  godot(w) -> the width a Godot Label needs: Chrome width x 1.08, rounded up, + 2 px

Results are cached in measure_cache.json keyed by class and text, so the sheet build only starts Chrome
for strings it has not seen. Used by build_components.py to size the fixed columns of the top bar, the
Ekip grid and the gate slot for the worst TR and EN value (review finding 4 and 6).
"""
import html
import json
import math
import os
import re
import subprocess
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
SYS = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "system"))  # read-only
CACHE = os.path.join(HERE, "measure_cache.json")
CHROME = r"C:/Program Files/Google/Chrome/Application/chrome.exe"
GODOT_SLACK = 1.08


def godot(w):
    return int(math.ceil(w * GODOT_SLACK)) + 2


def _key(cls, text, lang="tr"):
    return cls + "\u241f" + text + ("" if lang == "tr" else "\u241f" + lang)


def measure(items):
    cache = json.load(open(CACHE, encoding="utf-8")) if os.path.exists(CACHE) else {}
    items = [it if len(it) == 4 else tuple(it) + ("tr",) for it in items]
    todo = [(i, c, t, lg) for i, c, t, lg in items if _key(c, t, lg) not in cache]
    if todo:
        from common import FONTS  # noqa: E402  (same link the sheet uses)
        spans = "".join('<div lang="%s"><span class="%s" data-k="%s" style="white-space:nowrap">%s</span></div>'
                        % (lg, c, html.escape(_key(c, t, lg), quote=True), html.escape(t)) for _, c, t, lg in todo)
        page = ('<!doctype html><html lang="tr"><head><meta charset="utf-8"><link href="%s" rel="stylesheet">'
                '<link rel="stylesheet" href="%s"><link rel="stylesheet" href="%s"></head><body>%s'
                '<script>document.fonts.ready.then(()=>{const o={};document.querySelectorAll("[data-k]").forEach(e=>'
                '{o[e.dataset.k]=e.getBoundingClientRect().width});const p=document.createElement("pre");p.id="out";'
                'p.textContent=JSON.stringify(o);document.body.appendChild(p);});</script></body></html>'
                % (FONTS, "file:///" + os.path.join(SYS, "tokens.css").replace("\\", "/"),
                   "file:///" + os.path.join(SYS, "base.css").replace("\\", "/"), spans))
        fd, path = tempfile.mkstemp(suffix=".html")
        os.write(fd, page.encode("utf-8"))
        os.close(fd)
        prof = tempfile.mkdtemp()
        try:
            out = subprocess.run([CHROME, "--headless=new", "--virtual-time-budget=10000", "--no-first-run",
                                  "--user-data-dir=" + prof, "--dump-dom", "file:///" + path.replace("\\", "/")],
                                 capture_output=True, timeout=120).stdout.decode("utf-8", "replace")
        finally:
            os.remove(path)
        m = re.search(r'<pre id="out">(.*?)</pre>', out, re.S)
        if not m:
            raise SystemExit("measure: Chrome returned no widths")
        cache.update(json.loads(html.unescape(m.group(1))))
        json.dump(cache, open(CACHE, "w", encoding="utf-8"), ensure_ascii=False, indent=0, sort_keys=True)
    return {i: cache[_key(c, t, lg)] for i, c, t, lg in items}
