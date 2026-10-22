# Acik hata nedeni: kol basina dogan/yakalanan/kacan hata ve duzeltme kartlarinin akisi. python -I a6hata.py <kal> <senaryo> [kol,kol]
import sys, statistics, json, os
sys.path.insert(0, ".")
sys.stdout.reconfigure(encoding="utf-8")
import a6iz as Z
R6, A, D = Z.R6, Z.A, Z.D
cal, scen = sys.argv[1], sys.argv[2]
arms = sys.argv[3].split(",") if len(sys.argv) > 3 else ["R", "T", "BK"]
for arm in arms:
    acc = {k: [] for k in ("open", "pts", "born", "found", "esc", "fixn", "fixpts", "fixwait", "C", "Hper100", "waitfeat")}
    for sd in range(1, 21):
        sim, alog, weeks = Z.run_trace(scen, sd, arm, cal)
        m = D.metrics(sim, A.LO)
        feat = [r for r in sim.cardrec if r["kind"] == "feature" and r["done_w"] > 20]
        fx = [r for r in sim.cardrec if r["kind"] == "fix" and r["done_w"] > 20]
        pts = sum(r["size"] for r in feat) or 1
        acc["open"].append(m["open_med"])
        acc["pts"].append(pts)
        acc["born"].append(sum(r["nbugs"] for r in feat))
        acc["found"].append(sum(r["found"] for r in feat))
        acc["esc"].append(sum(r["nbugs"] - r["found"] for r in feat))
        acc["fixn"].append(len(fx))
        acc["fixpts"].append(sum(r["size"] for r in fx))
        acc["fixwait"].append(statistics.mean([r["done_w"] - r["enter"] for r in fx]) if fx else 0)
        acc["C"].append(statistics.mean([r["C"] for r in feat]) if feat else 0)
        acc["Hper100"].append(100 * sum(r["H"] for r in feat) / pts)
        acc["waitfeat"].append(statistics.mean([r["done_w"] - r["enter"] for r in feat]) if feat else 0)
    f = lambda k: statistics.mean(acc[k])
    JF = os.path.join("out6", "a6hata.json")
    J = json.load(open(JF, encoding="utf-8")) if os.path.exists(JF) else {}
    J["%s|%s|%s" % (cal, scen, arm)] = {k: f(k) for k in acc}
    J["%s|%s|%s" % (cal, scen, arm)]["dogan100"] = 100 * f("born") / f("pts")
    json.dump(J, open(JF, "w", encoding="utf-8"), indent=1)
    print("%-3s acik hata %.1f | ozellik puani %.0f, dogan %.1f (100 puanda %.2f, beklenen %.2f), yakalanan %.1f (test kapsami C=%.2f), kacan %.1f | duzeltme karti %.1f adet %.0f puan, girisle teslim %.1f hf | ozellik girisle teslim %.1f hf" % (
        arm, f("open"), f("pts"), f("born"), 100 * f("born") / f("pts"), f("Hper100"), f("found"), f("C"), f("esc"), f("fixn"), f("fixpts"), f("fixwait"), f("waitfeat")))
