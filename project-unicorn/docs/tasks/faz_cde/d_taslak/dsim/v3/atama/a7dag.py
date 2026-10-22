# A7 inceleme: teslim edilen kartlarin gereksinim (R) ve buyukluk dagilimi, dogan hata payi. python -I a7dag.py <kol> <senaryo> <tohum>
import os, sys, collections
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6run as R6
H, A, D = R6.H, R6.A, R6.D
arm, scen, seed = sys.argv[1], sys.argv[2], int(sys.argv[3])
R6.set_cfg6(R6.ARMS[arm], seed, "H")
sim = R6.make_sim(scen, seed, trace=True)
sim.run()
agg = collections.defaultdict(lambda: [0, 0.0, 0, 0.0])
for r in sim.cardrec:
    if r["done_w"] <= A.LO:
        continue
    k = (r["kind"], r["size"] if r["kind"] == "feature" else "fix", r["R"])
    a = agg[k]
    a[0] += 1; a[1] += r["H"]; a[2] += r["nbugs"]; a[3] += sum(v[0] for v in r["dev"].values())
tot = sum(a[2] for a in agg.values()); totw = sum(a[3] for a in agg.values())
print(arm, scen, seed, "kart turu, puan, R | adet, beklenen H, dogan, yazilim isi payi, dogan payi")
for k in sorted(agg, key=str):
    a = agg[k]
    print(k, "| %d  H=%.1f  dogan=%d  is=%.0f%%  hata=%.0f%%" % (a[0], a[1], a[2], 100 * a[3] / totw, 100 * a[2] / tot if tot else 0))
