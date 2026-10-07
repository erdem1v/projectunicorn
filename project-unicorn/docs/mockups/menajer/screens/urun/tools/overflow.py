"""Overflow audit: loads each build/<frame>.html in headless Chrome, widens every text run by 8 % (Godot draws
wider than Chrome, SPEC §3.4) and lists elements whose text is clipped or ellipsised.
  python overflow.py [name ...]"""
import glob
import html
import os
import re
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
BUILD = os.path.join(HERE, "..", "build")
CHROME = r"C:/Program Files/Google/Chrome/Application/chrome.exe"
JS = r"""<script>document.fonts.ready.then(()=>{
document.querySelectorAll('body *').forEach(e=>{if(e.children.length===0&&e.textContent.trim())e.style.letterSpacing=
 (parseFloat(getComputedStyle(e).letterSpacing)||0)+parseFloat(getComputedStyle(e).fontSize)*0.04+'px';});
const out=[];document.querySelectorAll('body *').forEach(e=>{const cs=getComputedStyle(e);
 if((cs.overflow==='hidden'||cs.textOverflow==='ellipsis'||cs.webkitLineClamp!=='none')&&e.textContent.trim()&&!e.classList.contains('screen')&&!e.classList.contains('win')&&!e.classList.contains('pa')&&!e.classList.contains('pcol-s')&&!e.classList.contains('qa')&&!e.classList.contains('qc')&&!e.classList.contains('tk-run')&&!e.classList.contains('portrait')&&!e.classList.contains('av')&&!e.classList.contains('ib-list')){
 if(e.scrollWidth>e.clientWidth+1||e.scrollHeight>e.clientHeight+2)out.push((e.className||e.tagName)+' :: '+e.textContent.trim().slice(0,60));}});
const p=document.createElement('pre');p.id='ovf';p.textContent=JSON.stringify(out);document.body.appendChild(p);});</script>"""

names = sys.argv[1:] or [os.path.splitext(os.path.basename(p))[0] for p in sorted(glob.glob(os.path.join(BUILD, "*.html")))]
for n in names:
    src = open(os.path.join(BUILD, n + ".html"), encoding="utf-8").read().replace("</body>", JS + "</body>")
    fd, path = tempfile.mkstemp(suffix=".html", dir=BUILD)
    os.write(fd, src.encode("utf-8"))
    os.close(fd)
    prof = tempfile.mkdtemp()
    w, h = ("1536", "864") if n.endswith("_1536") else ("1920", "1080")
    try:
        out = subprocess.run([CHROME, "--headless=new", "--virtual-time-budget=10000", "--no-first-run", "--window-size=%s,%s" % (w, h),
                              "--user-data-dir=" + prof, "--dump-dom", "file:///" + path.replace("\\", "/")],
                             capture_output=True, timeout=120).stdout.decode("utf-8", "replace")
    finally:
        os.remove(path)
    m = re.search(r'<pre id="ovf">(.*?)</pre>', out, re.S)
    items = eval(html.unescape(m.group(1))) if m else ["(no report)"]
    print("%-36s %s" % (n, "clean" if not items else "%d clipped" % len(items)))
    for it in items:
        print("    " + it)
