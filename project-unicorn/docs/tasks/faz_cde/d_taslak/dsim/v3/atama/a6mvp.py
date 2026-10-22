# MVP kartlari asama baslangiclari (ortalama, 20 tohum). python -I a6mvp.py <kal> <senaryo>
import sys, statistics
sys.path.insert(0, ".")
sys.stdout.reconfigure(encoding="utf-8")
import a6iz as Z
R6 = Z.R6
cal, scen = sys.argv[1], sys.argv[2]
for arm in ("R", "T", "BK"):
    acc = {"d0": [], "y0": [], "t0": [], "bit": [], "mvp": [], "ilk_test": [], "son_test": [], "kisi": []}
    for sd in range(1, 21):
        sim, alog, weeks = Z.run_trace(scen, sd, arm, cal)
        pls = Z.placements(alog)
        acc["mvp"].append(sim.mvp_week)
        starts = {0: [], 1: [], 2: []}
        for cid in sorted(sim.mvp_ids):
            for row in (0, 1, 2):
                ts = [t for t, r, ps in pls.get(cid, []) if r == row]
                if ts:
                    starts[row].append(min(ts))
        acc["d0"].append(statistics.mean(starts[0]) if starts[0] else None)
        acc["y0"].append(statistics.mean(starts[1]) if starts[1] else None)
        acc["t0"].append(statistics.mean(starts[2]) if starts[2] else None)
        acc["ilk_test"].append(min(starts[2]) if starts[2] else None)
        acc["son_test"].append(max(starts[2]) if starts[2] else None)
    f = lambda k: statistics.mean(x for x in acc[k] if x is not None)
    print("%-3s MVP haftasi %.1f | MVP kartlarinin ortalama ilk Tasarim h%.1f, ilk Yazilim h%.1f, ilk Test h%.1f (ilk Test h%.1f, son Test h%.1f)" % (arm, f("mvp"), f("d0"), f("y0"), f("t0"), f("ilk_test"), f("son_test")))
