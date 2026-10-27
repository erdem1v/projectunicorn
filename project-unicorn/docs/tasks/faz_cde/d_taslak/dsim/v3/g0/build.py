# D0t.2 · D0t_G0.md'yi parcalardan kurar: sablon parcalari + out/tablolar.md + out/ozet.md. Calistirma: python -I build.py <p0.md> <p1.md> <p2.md> <p3.md> <cikti.md>
import sys, re, os
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
tables = {}
for f in ("tablolar.md", "ozet.md"):
    txt = open(os.path.join(HERE, "out", f), encoding="utf-8").read()
    for m in re.finditer(r"<!-- T:(\S+) -->\n(.*?)\n<!-- /T:\1 -->", txt, re.S):
        tables[m.group(1)] = m.group(2)
parts = [open(p, encoding="utf-8").read() for p in sys.argv[1:5]]
doc = "\n".join(parts)
used = set()


def sub(m):
    used.add(m.group(1))
    return tables[m.group(1)]


doc = re.sub(r"\{\{T:(\S+?)\}\}", sub, doc)
assert "{{" not in doc, "cozulmeyen isaret"
open(sys.argv[5], "w", encoding="utf-8", newline="\n").write(doc)
print("tablo kullanildi:", sorted(used))
print("kullanilmayan:", sorted(set(tables) - used))
