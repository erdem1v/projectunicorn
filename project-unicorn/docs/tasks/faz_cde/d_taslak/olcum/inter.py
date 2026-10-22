import sys
sys.path.insert(0, sys.argv[1])
import analyze as a
from collections import Counter
def comp(runs):
    tot=Counter();n=0;trailing=Counter()
    for r in runs.values():
        bucket=[]
        for e in r["order"]:
            if e["t"]=="fire": bucket.append(e["id"])
            else:
                n+=1
                kinds=["paper" if i in a.CARDS else ("promise" if i=="product.promise_due" else "emerg:"+i.split(".")[-1]) for i in bucket if i in a.CARDS or i=="product.promise_due" or i in a.EMERG]
                tot["+".join(sorted(kinds)) or "(yok)"]+=1
                bucket=[]
        for i in bucket:
            if i in a.CARDS or i in a.EMERG or i=="product.promise_due": trailing[i]+=1
    return n,tot,trailing
A=a.load_dir(a.B6M/"logs_A")
n,t,tr=comp(A)
print("A 20 koşu kapanan sprint",n)
for k,v in t.most_common(): print("  ",k,v)
print("  son SPRINT'ten sonra kalan (sayılmayan) kesinti:",dict(tr))
B=a.load_dir(a.B6M/"logs_B_open")
n,t,tr=comp(B)
print("B açık 16 koşu kapanan sprint",n)
for k,v in t.most_common(): print("  ",k,v)
