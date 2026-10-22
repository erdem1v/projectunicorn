# A9 (Opus incelemesi) kosulari. a8run'u kullanir, a8plan'a dokunmaz.
#   python -I a9run.py tekrar <kol,kol> <senaryo,senaryo> <tohum_sayisi>   kayitli A8 sonuclari son kodla ayni mi (pred ve onbellek dahil)
#   python -I a9run.py run <kol> <senaryo,senaryo> [butce_sn] [tohum]       out9/ana/H/<kol>__<senaryo>.pkl (eksik tohum sonraki cagrida)
# Yeni kol P_kapi_k9: P, gereksinim kapisi yok (P_gyok gibi), AMA hata modeli kartin gercek gereksinimini kullanir. P_gyok'ta req="yok" hata
# modelinin gereksinimini de 0 yapiyordu (dogan hata %33 dusuyor); bu kol kapinin teslim bedelini hata hacminden ayirir.
# Tani kolu P_pmR_k9: P, PM'in kart secimi R'nin kuraliyla (k4h). P_pmZ_k9: P, PM okumasi (ii) (A6 §3).
import os, sys, time, pickle
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
H, A, D, P, R6 = R8.H, R8.A, R8.D, R8.P, R8.R6
from concurrent.futures import ProcessPoolExecutor

_req_dev = H.req_dev
KAPI9 = [False]


def req_dev9(team, c):
    if not KAPI9[0]:
        return _req_dev(team, c)
    old = A.CFG.req
    A.CFG.req = "data"
    try:
        return _req_dev(team, c)
    finally:
        A.CFG.req = old


H.req_dev = req_dev9
R6.ARMS["P_kapi_k9"] = dict(R8.ARMS["P_gyok"])
R6.ARMS["P_pmR_k9"] = dict(R8.ARMS["P"], pm="k4h")                 # tani: P, PM okumasi R'ninki (k4h); teslim farkinin PM kuralindan gelip gelmedigi
R6.ARMS["P_pmZ_k9"] = dict(R8.ARMS["P"], pm="zor")                 # P, Karar 21'in (ii) okumasi: zor karta en iyi PM, kalanlar bostaki en iyi PM sirayla


def run_task(task):
    arm, scen, seed = task
    KAPI9[0] = arm == "P_kapi_k9"
    return R8.run_task((arm, scen, seed, "H"))


def same(a, b):
    if isinstance(a, float) or isinstance(b, float):
        return a is not None and b is not None and abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    if isinstance(a, (list, tuple)):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    return a == b


def tekrar(arms, scens, ns):
    tasks = [(a, s, sd) for a in arms for s in scens for sd in range(1, ns + 1)]
    bad = tot = 0
    with ProcessPoolExecutor(max_workers=2) as ex:
        for (a, s, sd), res in zip(tasks, ex.map(run_task, tasks)):
            m = res[4]
            rec = R6.load(R8.fname("ana", "H", a, s)).get(sd)
            p = m["p8"]
            print("%-9s %-6s tohum %d | pred %.1e | onbellek isabeti %d / hafta basi %d | arama %d | oynatma %d" % (
                a, s, sd, m["pred"], p["hits"], p["epochs"], p["miss"], p["rollouts"]), flush=True)
            if rec is None:
                continue
            for k in R8.KEEP + ("born", "found", "H", "esc", "wbelow"):
                if k in rec:
                    tot += 1
                    if not same(m[k], rec[k]):
                        bad += 1
                        print("   FARK", k, str(m[k])[:50], "|", str(rec[k])[:50])
    print("TEKRAR metrik=%d fark=%d" % (tot, bad))


def fname(arm, scen):
    return os.path.join(HERE, "out9", "ana", "H", arm + "__" + scen.replace("|", "_") + ".pkl")


def run(arm, scens, budget, ns):
    t0 = time.time()
    tasks = []
    for s in scens:
        f = fname(arm, s)
        have = pickle.load(open(f, "rb")) if os.path.exists(f) else {}
        tasks += [(arm, s, sd) for sd in range(1, ns + 1) if sd not in have]
    done = 0
    with ProcessPoolExecutor(max_workers=2) as ex:
        futs = []
        for t in tasks:
            futs.append(ex.submit(run_task, t))
        for fu in futs:
            if time.time() - t0 > budget:
                break
            a, s, sd, _c, m = fu.result()
            f = fname(a, s)
            os.makedirs(os.path.dirname(f), exist_ok=True)
            d = pickle.load(open(f, "rb")) if os.path.exists(f) else {}
            d[sd] = m
            pickle.dump(d, open(f, "wb"))
            done += 1
        for fu in futs:
            fu.cancel()
    print("bitti %d/%d %.0f sn" % (done, len(tasks), time.time() - t0))
    print("KALDI" if done < len(tasks) else "TAMAM")


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "tekrar":
        tekrar(sys.argv[2].split(","), sys.argv[3].split(","), int(sys.argv[4]))
    elif c == "run":
        run(sys.argv[2], sys.argv[3].split(","), float(sys.argv[4]) if len(sys.argv) > 4 else 420.0, int(sys.argv[5]) if len(sys.argv) > 5 else 20)
