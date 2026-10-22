# Tani: demo olcegindeki uc bedelin nedeni icin karsi-olgusal kollar (kayitli degil; 20 tohum). python -I a6tani.py <kal>
#   T_np  = tarif, "kart bitene kadar kalir" kapali (kisi her hafta basi yeniden)    T_min = en yuksek gereksinimli karta yetecek kadar en iyi kisi
import sys, statistics, json, os
sys.path.insert(0, ".")
sys.stdout.reconfigure(encoding="utf-8")
import a6iz as Z
R6, A, D = Z.R6, Z.A, Z.D
R6.ARMS["T_np"] = dict(R6.ARMS["T"], stick=0)
R6.ARMS["T_min"] = dict(R6.ARMS["T"], top="min")
R6.ARMS["T_np_min"] = dict(R6.ARMS["T"], stick=0, top="min")
R6.ARMS["T_plan_np"] = dict(R6.ARMS["T"], top1="plan", stick=0)
cal = sys.argv[1]
print("| Kol | MVP haftası (3 kişi, sınırsız) | Açık hata (3 kişi, kaynaklı) | Düzeltme kartı girişten teslime (hf) | Kaçan söz (6 kişi, kaynaklı) |")
print("|---|---|---|---|---|")
for arm in sys.argv[2].split(","):
    mv, op, fw, sz = [], [], [], []
    for sd in range(1, 21):
        R6.set_cfg6(R6.ARMS[arm], sd, cal)
        sim, alog, w = Z.run_trace("S2", sd, arm, cal)
        mv.append(sim.mvp_week)
        sim, alog, w = Z.run_trace("PR|S2", sd, arm, cal)
        m = D.metrics(sim, A.LO)
        op.append(m["open_med"])
        fx = [r for r in sim.cardrec if r["kind"] == "fix" and r["done_w"] > 20]
        fw.append(statistics.mean([r["done_w"] - r["enter"] for r in fx]) if fx else 0.0)
    miss = due = 0
    for sd in range(1, 21):
        R6.set_cfg6(R6.ARMS[arm], sd, cal)
        sim = R6.make_sim("PR|S3", sd)
        sim.run()
        p = D._prom(sim)
        miss += p["late"] + p["undel"]
        due += p["due"]
    JF = os.path.join("out6", "a6tani.json")
    J = json.load(open(JF, encoding="utf-8")) if os.path.exists(JF) else {}
    J["%s|%s" % (cal, arm)] = {"mvp": statistics.mean(mv), "acik": statistics.mean(op), "fixwait": statistics.mean(fw), "soz": 100 * miss / due}
    json.dump(J, open(JF, "w", encoding="utf-8"), indent=1)
    print("| %s | %.1f | %.1f | %.1f | %.1f%% |" % (arm, statistics.mean(mv), statistics.mean(op), statistics.mean(fw), 100 * miss / due), flush=True)
