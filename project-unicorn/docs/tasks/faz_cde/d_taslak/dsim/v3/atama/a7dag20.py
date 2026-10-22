# A7: 20 tohumda pencerede (21. hafta sonrasi) teslim edilen ozellik kartlari: puan ve R dagilimi, dogan hata payi. python -I a7dag20.py <kol> <senaryo>
import os, sys, collections
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6run as R6
A = R6.A
arm, scen = sys.argv[1], sys.argv[2]
agg = collections.defaultdict(lambda: [0, 0, 0.0])
for sd in range(1, 21):
    R6.set_cfg6(R6.ARMS[arm], sd, "H")
    sim = R6.make_sim(scen, sd, trace=True)
    sim.run()
    for r in sim.cardrec:
        if r["done_w"] > A.LO and r["kind"] == "feature":
            a = agg[(r["size"], r["R"])]
            a[0] += 1; a[1] += r["nbugs"]; a[2] += sum(v[0] for v in r["dev"].values())
tb = sum(a[1] for a in agg.values()); tw = sum(a[2] for a in agg.values()); tn = sum(a[0] for a in agg.values())
for k in sorted(agg):
    a = agg[k]
    print(arm, scen, "puan %s R %s: kart %%%.0f, yazilim isi %%%.0f, dogan hata %%%.0f" % (k[0], k[1], 100 * a[0] / tn, 100 * a[2] / tw, 100 * a[1] / tb))
