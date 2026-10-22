import sys
sys.path.insert(0, sys.argv[1])
import analyze as a
from collections import Counter
A=a.load_dir(a.B6M/"logs_A")
c=Counter();cm={"b2b":Counter(),"b2c":Counter()}
for n,r in A.items():
    m="b2c" if n.startswith("full_run_b2c") else "b2b"
    for e in r["fires"]:
        if e["id"] in a.CARDS: c[e["id"]]+=1; cm[m][e["id"]]+=1
print("GELEN:")
for k,v in sorted(c.items(), key=lambda x:(a.CARDS[x[0]]["group"],x[0])): print("  %-44s %-10s %-8s B2B=%d B2C=%d toplam=%d"%(k,a.CARDS[k]["group"],a.CARDS[k]["market"],cm["b2b"][k],cm["b2c"][k],v))
print("GELMEYEN (grup, pazar):")
for k in sorted(a.CARDS, key=lambda x:(a.CARDS[x]["group"],x)):
    if k not in c: print("  %-44s %-10s %s"%(k,a.CARDS[k]["group"],a.CARDS[k]["market"]))
