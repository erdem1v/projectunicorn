import pickle, statistics, json
R = pickle.load(open("results.pkl", "rb"))
SEEDS = sorted(next(iter(R.values())).keys())

def vals(name, key, idx=None):
    out = []
    for s in SEEDS:
        v = R[name][s][key]
        if idx is not None and v is not None:
            v = v[idx]
        if v is not None:
            out.append(v)
    return out

def med(name, key, idx=None):
    v = vals(name, key, idx)
    return statistics.median(v) if v else None

def agg(name):
    d = {}
    for k in ("deliv", "pts", "per_person", "cards_sprint", "sprint_out", "esc_card", "open_med", "fix_late", "fix_early",
              "idle_w", "ready", "mvp", "slope", "fixes", "sprint_weeks", "wip", "lead", "open_max"):
        d[k] = med(name, k)
    d["n"] = R[name][SEEDS[0]]["n"]
    bl = [R[name][s]["bs_late"] for s in SEEDS]
    be = [R[name][s]["bs_early"] for s in SEEDS]
    d["bs_late"] = (sum(a for a, b in bl), sum(b for a, b in bl))
    d["bs_early"] = (sum(a for a, b in be), sum(b for a, b in be))
    d["consec"] = sum(1 for s in SEEDS if R[name][s]["consec"])
    left = [statistics.median(R[name][s]["left"][i] for s in SEEDS) for i in range(3)]
    d["left"] = left
    d["bott"] = ["Tasarim", "Gelistirme", "Test"][max(range(3), key=lambda i: left[i])] if max(left) > 1.0 else "yok"
    d["morale"] = statistics.median(sum(R[name][s]["morale"]) for s in SEEDS)
    d["pred"] = max(R[name][s]["pred"] for s in SEEDS)
    d["cviol"] = sum(R[name][s]["cviol"] for s in SEEDS)
    d["deliv_min"] = min(vals(name, "deliv")); d["deliv_max"] = max(vals(name, "deliv"))
    d["mvp_min"] = min(vals(name, "mvp")) if vals(name, "mvp") else None
    d["mvp_max"] = max(vals(name, "mvp")) if vals(name, "mvp") else None
    return d

A = {k: agg(k) for k in R}

def f(x, p=1):
    return "-" if x is None else ("%." + str(p) + "f") % x

def pc(x):
    return "-" if x is None else "%d%%" % round(x * 100)

def ratio(t):
    return "%d/%d" % t if t[1] else "-"
