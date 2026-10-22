# A6 kosu surucusu. python -I a6run.py run <etiket> <kol[,kol]> <senaryo[,senaryo]> <kalibrasyon> [butce_sn] [tohum_sayisi]
#   kalibrasyon: 0 = bugunku hata modeli | H = hacim-notr c (CAL_H) | E = Erdem'in ornegi birebir (c = 0,4789) | sayi = o c (kalibrasyon denemesi)
#   python -I a6run.py one <kol> <senaryo> <tohum> <kalibrasyon>
# Sonuc: out6/<etiket>/<kalibrasyon>/<kol>__<senaryo>.pkl = {tohum: sonuc}; eksik tohumlar sonraki cagrida tamamlanir (onbellek).
import os, sys, time, pickle
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3run as R3
import hata2 as H
A, D, CFG2 = H.A, H.D, H.CFG2
from concurrent.futures import ProcessPoolExecutor, FIRST_COMPLETED, wait

CAL_FILE = os.path.join(HERE, "out6", "cal_h.txt")          # K-H: bulunan c (tek satir)

_T = dict(assign="erdem", pm="basit", gate=0, stick=1, suff="kart", order="plan", top="cap", req="data")
ARMS = {
    "R": dict(assign="k4", pm="k4h", gate=0, stick=0),                       # bugunku kural (D0s'un onerdigi okuma)
    "T": dict(_T),                                                           # tarif, PM okumasi (i): en basit kart en zayif PM
    "T_zor": dict(_T, pm="zor"),                                             # tarif, PM okumasi (ii): zor karta en iyi PM, kalanlar bostaki en iyi PM
    "T_d": dict(_T, pmh="delta"),                                            # (i) + PM hata azaltmasi Delta_PM'e bagli
    "T_zord": dict(_T, pm="zor", pmh="delta"),                               # (ii) + Delta_PM
    "BK": dict(_T, rest="bk"),                                               # kalan kartlar buyukten kucuge, siradaki en iyi kisi
    "T_plan": dict(_T, top1="plan"),                                         # TANI kolu (tarif degil): 1. adimda en onde duran kart gereksinim yerine plan sirasiyla secilir
    "E": dict(assign="erdem", pm="erdem", gate=0, stick=1, suff="kart", order="plan", top="cap", req="data"),   # A3'un tarifi (PM: yeten en dusuk)
}
KEEP = R3.KEEP


def cal_c(cal):
    """Kalibrasyon: 0 | H | E | <c> | <c>@<p> (duyarlilik: gereksinim kuvveti p)."""
    if "@" in cal:
        return float(cal.split("@")[0])
    if cal == "0":
        return None
    if cal == "E":
        return H.C_E
    if cal == "H":
        return float(open(CAL_FILE).read().strip())
    return float(cal)


def set_cfg6(d, seed, cal):
    base = {k: v for k, v in d.items() if k not in ("pmh", "rest", "top1")}
    R3.set_cfg(base, seed)
    CFG2.hata, CFG2.pmh, CFG2.rest, CFG2.top1 = "bugun", d.get("pmh", "bugun"), d.get("rest", "yeten"), d.get("top1", "gereksinim")
    CFG2.p = float(cal.split("@")[1]) if "@" in cal else 1.0
    c = cal_c(cal)
    if c is not None:
        CFG2.hata, CFG2.c = "yeni", c


def make_sim(scen, seed, trace=False):
    fn, kw = D.SCEN[scen]
    kw = dict(kw)
    spec = kw.pop("_hire_spec", None)
    growth = kw.pop("_growth", False)
    ppl = fn()
    if spec:
        kw["hires"] = D._ghires(spec)
    if growth:
        kw["hires"] = D.growth_hires()
    kw.setdefault("weeks", 60)
    return H.A6Sim(ppl, seed, trace=trace, **kw)


def run_task(task):
    arm, scen, seed, cal = task
    set_cfg6(ARMS[arm], seed, cal)
    sim = make_sim(scen, seed)
    sim.run()
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
    return arm, scen, seed, cal, out


def fname(tag, cal, arm, scen):
    return os.path.join(HERE, "out6", tag, str(cal), arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")


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
        with ProcessPoolExecutor(max_workers=int(os.environ.get("A6_WORKERS", "2"))) as ex:
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
        print({k: (round(v, 3) if isinstance(v, float) else v) for k, v in m.items() if k in ("n", "mvp", "deliv", "open_med", "born", "esc", "H", "found", "wdev", "wbelow", "prom", "pred")}, "%.1fs" % (time.time() - t))
