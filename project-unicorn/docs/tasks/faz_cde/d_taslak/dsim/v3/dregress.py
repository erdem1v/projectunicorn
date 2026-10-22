# D0s regresyon: D3_LEGACY=1 iken dsim3.py, dsim3_orig.py ile ayni metrikleri vermeli. python -I dsim3.py exec dregress.py <senaryo,senaryo> <tohum_sayisi>
import importlib.util, json, math, sys
spec = importlib.util.spec_from_file_location("orig", "dsim3_orig.py")
orig = importlib.util.module_from_spec(spec)
spec.loader.exec_module(orig)
names = sys.argv[3].split(",")
nseed = int(sys.argv[4])
SKIP = {"series", "aud", "prom", "depth_seq", "depth_fin", "leads", "fillplan", "fillplan_all", "pulls", "unfin_gt1", "unfin_mean", "early_closed", "linked_q",
        "pulled_pts", "weeks_run", "sprints"}


def same(a, b):
    if isinstance(a, float) or isinstance(b, float):
        return a is not None and b is not None and abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    if isinstance(a, (list, tuple)):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


bad = 0
tot = 0
for nm in names:
    for sd in range(1, nseed + 1):
        mn = run_one((nm, sd))[2]
        mo = orig.run_one((nm, sd))[2]
        for k, v in mo.items():
            if k in SKIP or k in ("founder_w", "founder_st", "founder_st", "stage_w"):
                continue
            tot += 1
            if not same(mn[k], v):
                bad += 1
                print("FARK", nm, sd, k, str(mn[k])[:80], "|", str(v)[:80])
        for k in ("founder_w", "founder_st", "stage_w"):
            v = mo[k]
            if not (all(abs(x - y) < 1e-6 for x, y in zip(mn[k], v)) if isinstance(v, list) else abs(mn[k] - v) < 1e-6):
                bad += 1
                print("FARK", nm, sd, k)
    print(nm, "tamam", flush=True)
print("karsilastirilan metrik %d, fark %d" % (tot, bad))
