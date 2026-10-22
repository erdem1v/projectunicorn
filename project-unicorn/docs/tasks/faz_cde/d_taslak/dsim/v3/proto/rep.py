import pickle, statistics
out=pickle.load(open("big.pkl","rb"))
R,M=out["hold"]
def md(Mx,n,k):
    v=[m[k] for m in Mx[n].values() if m[k] is not None]
    return statistics.median(v) if v else float('nan')
def bs(Mx,n):
    a=sum(m["bs_late"][0] for m in Mx[n].values()); b=sum(m["bs_late"][1] for m in Mx[n].values()); 
    c=sum(m["bs_all"][0] for m in Mx[n].values()); d=sum(m["bs_all"][1] for m in Mx[n].values());
    cons=sum(1 for m in Mx[n].values() if m["consec"])
    return "%d/%d %d/%d ust%d"%(a,b,c,d,cons)
keys=["deliv","per_person","cards_sprint","esc_card","esc100","open_med","open_max","fix_early","fix_late","found_sp","K_sp","q_qr","infix","idle_w","ready","mvp","founder_w","lead","slope","pred"]
import sys
groups=sys.argv[3:] if len(sys.argv)>3 else None
print("%-26s"%"senaryo"," ".join("%8s"%k[:8] for k in keys),"hata_sprinti")
for n in M:
    if groups and not any(n.startswith(g) for g in groups): continue
    print("%-26s"%n[:26]," ".join("%8.3f"%md(M,n,k) for k in keys), bs(M,n))
