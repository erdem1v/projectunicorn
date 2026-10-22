# A8 kosu surucusu (a6run.py'nin uzantisi). python -I a8run.py run <etiket> <kol[,kol]> <senaryo[,senaryo]> <kalibrasyon> [butce_sn] [tohum_sayisi]
#   python -I a8run.py one <kol> <senaryo> <tohum> <kalibrasyon>
# Sonuc: out8/<etiket>/<kalibrasyon>/<kol>__<senaryo>.pkl = {tohum: sonuc}; eksik tohumlar sonraki cagrida tamamlanir (onbellek).
# R, T, T_plan kollari A6'nin kayitlarindan (out6/ana/H) okunur; burada koşturulursa ayni sonucu verir (a8test.py regress dogrular).
import os, sys, time, pickle
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6run as R6
import a8plan as P
H, A, D, CFG2 = R6.H, R6.A, R6.D, R6.CFG2
from concurrent.futures import ProcessPoolExecutor, FIRST_COMPLETED, wait

_P = dict(R6._T, assign="p8")
ARMS = dict(R6.ARMS)
ARMS["P"] = dict(_P)                                              # ana kol: tam planlayici (hafta basi ileri oynatma)
ARMS["P_sabit"] = dict(_P, p8_search=0)                           # ileri oynatma yok: tek secenek (beta 1,0, en az kisilik ekip)
ARMS["P_min1"] = dict(_P, p8_sets="min1")                         # tek secenek kumesi (arama kapali ayni)
ARMS["P_cap"] = dict(_P, p8_sets="cap1")
ARMS["P_core5"] = dict(_P, p8_sets="core5")                       # saklama (hold) secenekleri olmadan
ARMS["P_rp"] = dict(_P, p8_rr="plan")                              # satir secimi eski kuralla (plan sirasindaki en onde acik satir)
ARMS["P_ns"] = dict(_P, p8_sets="noswap")                         # ilke degisimi kapali
ARMS["P_r5"] = dict(_P, p8_rho=0.5)                               # plan puani sirasi sert (rho 0,5)
ARMS["P_r1"] = dict(_P, p8_rho=1.0)                               # plan puani her kart esit
ARMS["P_r85"] = dict(_P, p8_rho=0.85)                             # plan puani sirasi 0,85 (ana kolun degeri; P ile ayni sonuc)
ARMS["T_plan_np"] = dict(R6._T, top1="plan", stick=0)               # tani: T_plan, "kalir" kapali
ARMS["P_gyok"] = dict(_P, req="yok")                               # tani: P, gereksinim kapisi yok (ilkenin kisitini kaldirir)
ARMS["P_np"] = dict(_P, stick=0)                                   # tani: P, "kalir" kapali
R6.ARMS.update(ARMS)
KEEP = R6.KEEP


def set_cfg8(d, seed, cal):
    base = {k: v for k, v in d.items() if not k.startswith("p8_")}
    R6.set_cfg6(base, seed, cal)
    P.P8.search, P.P8.rho, P.P8.sets, P.P8.rowrule = d.get("p8_search", 1), d.get("p8_rho", 0.85), d.get("p8_sets", "std"), d.get("p8_rr", "need")
    P.reset_stats()


def run_task(task):
    arm, scen, seed, cal = task
    set_cfg8(R6.ARMS[arm], seed, cal)
    t0 = time.perf_counter()
    sim = R6.make_sim(scen, seed)
    sim.run()
    wall = time.perf_counter() - t0
    m = D.metrics(sim, A.LO)
    out = {k: m[k] for k in KEEP if k in m}
    out["pm_aud"] = dict(sim.aud)
    out["detail"] = dict(A.DETAIL)
    out["wkwin"] = sum(x["weeks"] for x in sim.rec if x["end"] > A.LO)
    bl = [b for b in sim.born_log if b["end"] > A.LO]
    for k in ("born", "born_feat", "found", "H", "esc", "wdev", "wbelow", "wdelta"):
        out[k] = sum(b[k] for b in bl)
    out["pts_win"] = sum(x["delivered"] for x in sim.rec if x["end"] > A.LO)
    out["cal"] = cal
    out["p8"] = dict(P.STATS)
    out["p8"]["wall"] = wall
    out["p8"]["nsprints"] = len(sim.rec)
    # boşta (PM dahil): dsim metrics idle_pct zaten PM dahil; PM haric a6tab.idle_nonpm
    return arm, scen, seed, cal, out


def fname(tag, cal, arm, scen):
    return os.path.join(HERE, "out8", tag, str(cal), arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")


def load(f):
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def main_run(tag, arms, scens, cal, budget, nseeds):
    t0 = time.time()
    tasks = []
    for a in arms:
        for s in scens:
            have = load(fname(tag, cal, a, s))
            for sd in range(1, nseeds + 1):
                if sd not in have:
                    tasks.append((a, s, sd, cal))
    print("gorev", len(tasks), flush=True)
    done = 0
    buf = {}

    def flush():
        for (a, s), res in buf.items():
            f = fname(tag, cal, a, s)
            os.makedirs(os.path.dirname(f), exist_ok=True)
            d = load(f)
            d.update(res)
            pickle.dump(d, open(f, "wb"))
        buf.clear()
    if tasks:
        with ProcessPoolExecutor(max_workers=int(os.environ.get("A8_WORKERS", "2"))) as ex:
            it = iter(tasks)
            pend, stop, last = {}, False, time.time()
            while True:
                while not stop and len(pend) < 4:
                    if time.time() - t0 > budget:
                        stop = True
                        break
                    try:
                        t = next(it)
                    except StopIteration:
                        stop = True
                        break
                    pend[ex.submit(run_task, t)] = t
                if not pend:
                    break
                dn, _ = wait(list(pend), return_when=FIRST_COMPLETED)
                for fu in dn:
                    pend.pop(fu)
                    a, s, sd, _c, m = fu.result()
                    buf.setdefault((a, s), {})[sd] = m
                    done += 1
                if time.time() - last > 20:
                    flush()
                    last = time.time()
    flush()
    left = len(tasks) - done
    print("bitti %d/%d, kalan %d, %.0f sn" % (done, len(tasks), left, time.time() - t0), flush=True)
    print("KALDI" if left else "TAMAM")


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "run":
        main_run(sys.argv[2], sys.argv[3].split(","), sys.argv[4].split(","), sys.argv[5], float(sys.argv[6]) if len(sys.argv) > 6 else 420.0,
                 int(sys.argv[7]) if len(sys.argv) > 7 else 20)
    elif cmd == "one":
        t = time.time()
        _, _, _, _, m = run_task((sys.argv[2], sys.argv[3], int(sys.argv[4]), sys.argv[5]))
        print({k: (round(v, 3) if isinstance(v, float) else v) for k, v in m.items() if k in ("n", "mvp", "deliv", "open_med", "born", "esc", "pred", "p8")}, "%.1fs" % (time.time() - t))
