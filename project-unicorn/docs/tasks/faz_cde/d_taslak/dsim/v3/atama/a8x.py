# A8 hizli karsilastirma (gelistirme araci): python -I a8x.py <kollar> <senaryolar> <tohum_sayisi> [kal]
import os, sys, time, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
from concurrent.futures import ProcessPoolExecutor
import a6tab as T


def main():
    arms = sys.argv[1].split(",")
    scens = sys.argv[2].split(",")
    ns = int(sys.argv[3])
    cal = sys.argv[4] if len(sys.argv) > 4 else "H"
    tasks = [(a, s, sd, cal) for s in scens for a in arms for sd in range(1, ns + 1)]
    t0 = time.time()
    res = {}
    with ProcessPoolExecutor(max_workers=2) as ex:
        for a, s, sd, _c, m in ex.map(R8.run_task, tasks, chunksize=1):
            res.setdefault((a, s), {})[sd] = m
    print("sure %.0f sn" % (time.time() - t0))
    for s in scens:
        print("== %s" % s)
        for a in arms:
            r = res[(a, s)]
            f = lambda fn: statistics.mean(fn(m) for m in r.values() if fn(m) is not None)
            idle = f(lambda m: T.idle_nonpm(m, s))
            soz = ""
            if s.startswith("PR|"):
                due = sum(m["prom"]["due"] for m in r.values())
                bad = sum(m["prom"]["late"] + m["prom"]["undel"] for m in r.values())
                soz = " soz %.1f%% (%d/%d)" % (100.0 * bad / due if due else 0, bad, due)
            p = R8.P.STATS
            pr = [m["p8"] for m in r.values()]
            print("%-8s mvp %5.2f teslim %6.1f acik %5.1f dogan %6.1f kacan %6.1f bosta(PMsiz) %5.1f%%%s | oynatma/sprint %.1f sn/sprint %.3f" % (
                a, f(lambda m: m["mvp"]), f(lambda m: m["deliv"]), f(lambda m: m["open_med"]), f(lambda m: m["born"]), f(lambda m: m["esc"]),
                100 * idle, soz, sum(x["rollouts"] for x in pr) / max(1, sum(x["nsprints"] for x in pr)), sum(x["secs"] for x in pr) / max(1, sum(x["nsprints"] for x in pr))))


if __name__ == "__main__":
    main()
