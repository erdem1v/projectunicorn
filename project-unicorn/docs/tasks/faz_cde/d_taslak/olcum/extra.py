import sys
sys.path.insert(0, sys.argv[1])
import analyze as a
from collections import Counter
bo=a.load_dir(a.B6M/"logs_B_open"); bf=a.load_dir(a.B6M/"logs_B_free")
allr={**{"open_"+k:v for k,v in bo.items()},**{"free_"+k:v for k,v in bf.items()}}
rows=[]
for n,r in allr.items():
    c=Counter(e["id"] for e in r["fires"] if e["id"] in a.CARDS)
    if c: rows.append((c.most_common(1)[0][1],n))
print("B 28 koşu: aynı kâğıt en çok:",max(rows)[0],sorted(Counter(x for x,_ in rows).items()))
for n,r in bo.items():
    em=[e["day"] for e in r["fires"] if e["id"] in a.EMERG]
    print(n,len(em),[b-x for x,b in zip(em,em[1:])])
