"""Audit of the built frames in headless Chrome.

  python audit.py [name ...]

1. Godot width pass (SPEC §3.4): every text run is widened by 8 % (letter spacing + 0.04 em per glyph, as Ürün's
   overflow.py) and the tool lists text that is then (a) ellipsised or clipped by its own box, (b) spills out of its
   grid cell, or (c) runs past the window, panel, dossier, menu, modal or float it sits in. Intended clips are skipped:
   the ticker's run, a scrolled table view, a window cut by the 1536 area (is-clipped).
2. Floats (SPEC §9): reports whether the notice stack or BuildHUD rect overlaps an open window, panel or dossier
   (then the frame must hide it) and prints the rects, so INDEX.md can say why a frame shows or hides them.
"""
import glob
import html
import json
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "..", "build")
CHROME = r"C:/Program Files/Google/Chrome/Application/chrome.exe"
JS = r"""<script>document.fonts.ready.then(()=>{
const texts=[];const tw=document.createTreeWalker(document.body,NodeFilter.SHOW_TEXT);let t;
while(t=tw.nextNode()){if(t.textContent.trim()&&t.parentElement.tagName!=='SCRIPT'&&t.parentElement.tagName!=='STYLE')texts.push(t);}
const done=new Set();
texts.forEach(n=>{const e=n.parentElement;if(done.has(e))return;done.add(e);const cs=getComputedStyle(e);
 e.style.letterSpacing=((parseFloat(cs.letterSpacing)||0)+parseFloat(cs.fontSize)*0.04)+'px';});
const has=(el,c)=>el.classList&&el.classList.contains(c);
const skip=(el,rr)=>{for(let a=el;a&&a!==document.body;a=a.parentElement){if(has(a,'tk-run')||has(a,'is-clipped')||has(a,'sheet'))return true;
 if(has(a,'tbl-view')){const v=a.getBoundingClientRect();if(rr.top<v.top||rr.bottom>v.bottom)return true;}}return false;};
const label=(e,n)=>(e.className&&typeof e.className==='string'?e.className:e.tagName)+' :: '+n.textContent.trim().slice(0,50);
const out=[];const seen=new Set();
texts.forEach(n=>{const e=n.parentElement;
 const r=document.createRange();r.selectNodeContents(n);const rr=r.getBoundingClientRect();if(!rr.width||skip(e,rr))return;
 for(let a=e;a&&a!==document.body;a=a.parentElement){const cs=getComputedStyle(a);
  if((cs.textOverflow==='ellipsis'||cs.overflowX==='hidden'||cs.overflowX==='clip')&&a.scrollWidth>a.clientWidth+1&&!has(a,'win')&&!has(a,'screen')&&!has(a,'office')&&!has(a,'av')&&!has(a,'ticker')&&!has(a,'tbl-view')&&!has(a,'win-body')){
   const k='clip '+label(a,n);if(!seen.has(k)){seen.add(k);out.push(k);}break;}
  if(a.parentElement&&getComputedStyle(a.parentElement).display==='grid'){const b=a.getBoundingClientRect();
   const pl=parseFloat(cs.paddingLeft)||0,pr=parseFloat(cs.paddingRight)||0;
   if(rr.right>b.right-pr+0.5||rr.left<b.left+pl-0.5){const k='spill '+label(e,n)+' (cell '+Math.round(b.width)+', text '+Math.round(rr.width)+')';if(!seen.has(k)){seen.add(k);out.push(k);}}
   break;}}
 const box=e.closest('.win,.dos,.modal,.menu,.float,.tip,.topbar,.rail');
 if(box){const b=box.getBoundingClientRect();if(rr.right>b.right+0.5||rr.left<b.left-0.5){const k='past '+box.className.split(' ')[0]+' '+label(e,n);if(!seen.has(k)){seen.add(k);out.push(k);}}}
});
const R=el=>{const b=el.getBoundingClientRect();return [Math.round(b.left),Math.round(b.top),Math.round(b.right),Math.round(b.bottom)];};
const hit=(a,b)=>a[0]<b[2]&&b[0]<a[2]&&a[1]<b[3]&&b[1]<a[3];
const wins=[...document.querySelectorAll('.screen > .win, .screen > .dos')].map(R);
const fl={};[['stack','.nstack'],['hud','.bh']].forEach(([k,s])=>{const el=document.querySelector(s);if(el){const r=R(el);fl[k]={rect:r,over:wins.filter(w=>hit(w,r))};}});
const p=document.createElement('pre');p.id='aud';p.textContent=JSON.stringify({text:out,floats:fl,wins:wins});document.body.appendChild(p);});</script>"""

names = sys.argv[1:] or [os.path.splitext(os.path.basename(p))[0] for p in sorted(glob.glob(os.path.join(BUILD, "*.html")))]
sizes = {}
if os.path.exists(os.path.join(BUILD, "sizes.txt")):
    for line in open(os.path.join(BUILD, "sizes.txt"), encoding="utf-8"):
        k, w, h, _ = line.split()
        sizes[k] = (w, h)
for n in names:
    src = open(os.path.join(BUILD, n + ".html"), encoding="utf-8").read().replace("</body>", JS + "</body>")
    fd, path = tempfile.mkstemp(suffix=".html", dir=BUILD)
    os.write(fd, src.encode("utf-8"))
    os.close(fd)
    prof = tempfile.mkdtemp()
    w, h = sizes.get(n, ("1920", "1080"))
    try:
        out = subprocess.run([CHROME, "--headless=new", "--virtual-time-budget=10000", "--no-first-run", "--hide-scrollbars",
                              "--window-size=%s,%s" % (w, h), "--user-data-dir=" + prof, "--dump-dom",
                              "file:///" + path.replace("\\", "/")], capture_output=True, timeout=120).stdout.decode("utf-8", "replace")
    finally:
        os.remove(path)
    m = re.search(r'<pre id="aud">(.*?)</pre>', out, re.S)
    if not m:
        print("%-32s (no report)" % n)
        continue
    rep = json.loads(html.unescape(m.group(1)))
    fl = " ".join("%s %s%s" % (k, v["rect"], " OVER " + str(v["over"]) if v["over"] else "") for k, v in rep["floats"].items())
    print("%-32s %-10s %s | windows %s" % (n, "clean" if not rep["text"] else "%d issue(s)" % len(rep["text"]), fl, rep["wins"]))
    for it in rep["text"]:
        print("    " + it)
