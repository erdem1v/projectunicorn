import math, statistics
names=["S1","S2","S3","S4","S5","S6"]
def full(task):
    pass
from concurrent.futures import ProcessPoolExecutor
res={}
for n in names:
    rows=[]
    for sd in range(1,11):
        s=Sim(SCEN[n](), sd, weeks=80); s.run()
        rows.append((s.mvp_week,[(x["end"],x["open"],x["delivered"]/x["weeks"]) for x in s.rec]))
    res[n]=rows
for n in names:
    rows=res[n]
    # haftalik teslim ortalamasi (pencere 21-60) ve esige varis
    out=[]
    for mvp,rec in rows:
        d=statistics.mean(r[2] for r in rec if 20<r[0]<=60)
        for name,T in (("30",30),("sqrt",30*max(1,math.sqrt(d/55))),("lin110",30*max(1,d/110))):
            hit=next((r[0]-mvp for r in rec if r[1]>=T and r[0]>mvp), None)
            out.append((name,T,hit))
    for nm in ("30","sqrt","lin110"):
        xs=[o for o in out if o[0]==nm]
        hits=[o[2] for o in xs if o[2] is not None]
        print(n, nm, "esik~%.0f"%statistics.median(o[1] for o in xs), "MVP'den sonra hafta (medyan): %s"%(statistics.median(hits) if hits else None), "vardi %d/10"%len(hits))
