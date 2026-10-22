import re,sys
from pathlib import Path
SP=Path(sys.argv[1]); REPO=Path(sys.argv[2])
def rd(p):
    out={}
    for l in p.read_text(encoding="utf-8").splitlines():
        m=re.match(r"^(PASS|MISS)\s+(.*?)\s{2,}(-?[\d.]+|nan)\s*(.*)$",l)
        if m: out[m.group(2).strip()]=(m.group(1),m.group(3),m.group(4))
    return out
a=rd(REPO/"docs/tasks/faz_ab/a_calisma/K5_tablolar.txt"); o=rd(SP/"tables_open.txt"); f=rd(SP/"tables_free.txt")
print("%-4s %-4s %-4s | %-8s %-8s %-8s | hedef" % ("A","açık","free","A","açık","free"))
for k in a:
    print("%-4s %-4s %-4s | %-8s %-8s %-8s | %s" % (a[k][0],o.get(k,("?",))[0],f.get(k,("?",))[0],a[k][1],o.get(k,("?","?"))[1],f.get(k,("?","?"))[1],k))
