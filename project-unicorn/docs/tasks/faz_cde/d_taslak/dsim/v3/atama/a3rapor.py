# Raporu parcalardan kurar: rapor_parcalar/p0..p4.md + {{anahtar}} -> a3tablolar.tables(). Cikti: ../../../ATAMA/A3_OLCUM.md
import os, re, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3tablolar as TT

OUT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "ATAMA", "A3_OLCUM.md"))
tabs = TT.tables()
parts = []
for f in ("p0", "p1", "p2", "p3", "p4"):
    parts.append(open(os.path.join(HERE, "rapor_parcalar", f + ".md"), encoding="utf-8").read().rstrip("\n"))
txt = "\n\n".join(parts) + "\n"
missing = []


def sub(m):
    k = m.group(1)
    if k not in tabs:
        missing.append(k)
        return m.group(0)
    return tabs[k]


txt = re.sub(r"\{\{([a-zA-Z0-9_]+)\}\}", sub, txt)
if missing:
    sys.exit("eksik tablo: %s" % missing)
os.makedirs(os.path.dirname(OUT), exist_ok=True)
open(OUT, "w", encoding="utf-8", newline="\n").write(txt)
print(OUT, len(txt), "bayt")
