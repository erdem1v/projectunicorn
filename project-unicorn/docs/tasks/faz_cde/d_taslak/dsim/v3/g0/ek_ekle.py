# D0t.2 ek: D0t_G0.md'ye "## 9. Ek kollar" bolumunu ekler (varsa degistirir); govde (9'dan onceki kisim) bayt bayt korunur.
# Calistirma: python -I ek_ekle.py <p9.md> <D0t_G0.md>
import sys, re, os
sys.stdout.reconfigure(encoding="utf-8")
HERE = os.path.dirname(os.path.abspath(__file__))
tables = {}
for f in ("ek_sim.md", "ek_u.md"):
    txt = open(os.path.join(HERE, "out", f), encoding="utf-8").read()
    for m in re.finditer(r"<!-- T:(\S+) -->\n(.*?)\n<!-- /T:\1 -->", txt, re.S):
        tables[m.group(1)] = m.group(2)
sec = open(sys.argv[1], encoding="utf-8").read()
sec = re.sub(r"\{\{T:(\S+?)\}\}", lambda m: tables[m.group(1)], sec)
assert "{{" not in sec
doc = open(sys.argv[2], encoding="utf-8", newline="").read()
i = doc.find("\n## 9. Ek kollar")
body = doc if i < 0 else doc[:i]
open(sys.argv[2], "w", encoding="utf-8", newline="\n").write(body.rstrip("\n") + "\n" + sec)
print("govde", len(body), "bayt; bolum eklendi")
