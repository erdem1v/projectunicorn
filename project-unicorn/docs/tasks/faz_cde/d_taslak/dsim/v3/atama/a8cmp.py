import os, sys, time, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
from concurrent.futures import ProcessPoolExecutor


def main():
    arms = sys.argv[1].split(","); scen = sys.argv[2]; ns = int(sys.argv[3])
    tasks = [(a, scen, sd, "H") for a in arms for sd in range(1, ns + 1)]
    res = {}
    with ProcessPoolExecutor(max_workers=2) as ex:
        for a, s, sd, _c, m in ex.map(R8.run_task, tasks, chunksize=1):
            res.setdefault(a, {})[sd] = m

    def mean(a, fn):
        return statistics.mean(fn(m) for m in res[a].values())
    for a in arms:
        print("%-7s deliv %.1f cards/sp %.2f wip %.2f lead %.2f idle_w %.2f pulls %.2f unfin %.2f found_sp %.2f stage_w %s infix %.3f tot_fix %.3f fix_late %.3f" % (
            a, mean(a, lambda m: m["deliv"]), mean(a, lambda m: m["cards_sprint"]), mean(a, lambda m: m["wip"]), mean(a, lambda m: m["lead"] or 0), mean(a, lambda m: m["idle_w"]),
            mean(a, lambda m: m["pulls"]), mean(a, lambda m: m.get("unfin_mean", 0)), mean(a, lambda m: m["found_sp"]),
            [round(statistics.mean(m["stage_w"][i] for m in res[a].values()), 1) for i in range(4)], mean(a, lambda m: m["infix"]), mean(a, lambda m: m["tot_fix"]), mean(a, lambda m: m["fix_late"] or 0)))


    for a in arms:
        det = {}
        for m in res[a].values():
            for k_, v in m["detail"].items():
                det[k_] = det.get(k_, 0.0) + v / len(res[a])
        wk = statistics.mean(m["wkwin"] for m in res[a].values())
        print("%-7s bosta nedeni (kisi-hafta / hafta): %s" % (a, {k_: round(v / wk, 2) for k_, v in sorted(det.items())}))


if __name__ == "__main__":
    main()
