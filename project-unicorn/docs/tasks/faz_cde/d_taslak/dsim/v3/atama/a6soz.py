# PR|S3 (6 kisi) soz kartlari: gec kalan kartlarin nedeni. python -I a6soz.py <kal> [senaryo]
import sys, statistics, json, os
sys.path.insert(0, ".")
sys.stdout.reconfigure(encoding="utf-8")
import a6iz as Z
R6 = Z.R6
scen = sys.argv[2] if len(sys.argv) > 2 else "PR|S3"
for arm in ("R", "T", "BK"):
    rows = []
    for sd in range(1, 21):
        R6.set_cfg6(R6.ARMS[arm], sd, sys.argv[1])
        sim, alog, weeks = Z.run_trace(scen, sd, arm, sys.argv[1])
        pls = Z.placements(alog)
        made = {m[0]: m for m in sim.prom_made}
        recs = {r["id"]: r for r in sim.cardrec}
        for cid, m in made.items():
            r = recs.get(cid)
            if m[2] >= sim.sidx:
                continue                         # vadesi gelmemis
            late = r is None or r["sprint"] > m[2]
            pl = pls.get(cid, [])
            ent = r["enter"] if r else None
            tstart = min((t for t, row, ps in pl if row == 2), default=None)
            nstage = {0: 0, 1: 0, 2: 0}
            for t, row, ps in pl:
                nstage[row] = max(nstage[row], len(ps))
            rows.append({"late": late, "found": (r["found"] if r else None), "size": m[1], "plan": (r["pos"] if r else None), "ent": ent, "tstart": tstart,
                         "t_wait": (tstart - ent) if (tstart is not None and ent is not None) else None, "crew_dev": nstage[1], "crew_all": sum(nstage.values())})
    late = [x for x in rows if x["late"]]
    ok = [x for x in rows if not x["late"]]
    f = lambda xs, k: (statistics.mean(v[k] for v in xs if v[k] is not None) if any(v[k] is not None for v in xs) else float("nan"))
    fz = lambda xs: (sum(1 for v in xs if v["found"]) / len(xs)) if xs else float("nan")
    JF = os.path.join("out6", "a6soz.json")
    J = json.load(open(JF, encoding="utf-8")) if os.path.exists(JF) else {}
    J["%s|%s|%s" % (sys.argv[1], scen, arm)] = {"n": len(rows), "late": len(late), "late_pct": 100 * len(late) / len(rows), "fix_late": 100 * fz(late), "fix_ok": 100 * fz(ok), "twait_late": f(late, "t_wait"), "twait_ok": f(ok, "t_wait"),
                                                 "size_late": f(late, "size"), "size_ok": f(ok, "size"), "crew_late": f(late, "crew_dev"), "crew_ok": f(ok, "crew_dev")}
    json.dump(J, open(JF, "w", encoding="utf-8"), indent=1)
    print("%-3s vadesi gelen %3d, gec %3d (%.1f%%); gec kartlarda test bulgusu (duzeltme asamasi) payi %.0f%%, zamaninda olanlarda %.0f%%; girisle Test basi arasi (hf) gec %.1f / zamaninda %.1f; ortalama kart puani gec %.1f / zamaninda %.1f; yazilimda en cok kisi gec %.1f / zamaninda %.1f" % (
        arm, len(rows), len(late), 100 * len(late) / len(rows), 100 * fz(late), 100 * fz(ok), f(late, "t_wait"), f(ok, "t_wait"), f(late, "size"), f(ok, "size"), f(late, "crew_dev"), f(ok, "crew_dev")))
