# A3 kosu surucusu. python -I a3run.py run <etiket> <kol[,kol]> <senaryo[,senaryo]> [butce_sn] [tohum_sayisi]
#                 python -I a3run.py one <kol> <senaryo> <tohum>
# Ortam: R okumasi a3core icinde varsayilir; "L" kolu D3_LEGACY=1 ile ayri surecte kosar (sabitler ice aktarmada okunur).
# Sonuc: out/<etiket>/<kol>__<senaryo>.pkl = {tohum: sonuc}; eksik tohumlar sonraki cagrida tamamlanir (onbellek).
import os, sys, time, pickle, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3core as A
D = A.D
from concurrent.futures import ProcessPoolExecutor, FIRST_COMPLETED, wait

_E = dict(assign="erdem", pm="erdem", gate=0, stick=1, suff="kart", order="plan", top="cap", req="data")
ARMS = {
    "L": dict(legacy=True),
    "R": dict(assign="k4", pm="k4h", gate=0, stick=0),
    "E": dict(_E),
    "E_asama": dict(_E, suff="asama"),
    "E_gsira": dict(_E, order="gerek"),
    "E_np": dict(_E, stick=0),
    "E_min": dict(_E, top="min"),
    "E_sert": dict(_E, req="sert"),
    "E_gyok": dict(_E, req="yok"),
    "E_pmr": dict(_E, pm="k4h"),
    "R_pme": dict(assign="k4", pm="erdem", gate=0, stick=0),
    "E_gate": dict(_E, gate=1),
    "R_gate": dict(assign="k4", pm="k4h", gate=1, stick=0),
    "RND": dict(_E, assign="rnd"),
    "REV": dict(_E, assign="rev"),
    "USTA": dict(_E, master=1, mobj=2),
    "USTA1": dict(_E, master=1, mobj=1),
    "E_uyari": dict(_E, warn=1.5),
    "R_uyari": dict(assign="k4", pm="k4h", gate=0, stick=0, warn=1.5),
    "E_uyari2": dict(_E, warn=1.25),
    "R_uyari2": dict(assign="k4", pm="k4h", gate=0, stick=0, warn=1.25),
}
MIT = {"S1": 120, "S2": 100, "S3": 100, "S4": 80, "S5": 60, "S6": 30}        # ustalik arama yinelemesi (sprint basina)
KEEP = ("n", "mvp", "deliv", "per_person", "cards_sprint", "esc_card", "esc100", "open_med", "open_max", "fix_late", "fix_early", "idle_w", "idle_pct",
        "why", "fillplan", "pulls", "new_sp", "early_closed", "prom", "pred", "sprints", "weeks_run", "stage_w", "wip", "lead", "pool_ok", "nocard",
        "req", "pts_src", "founder_w", "bott", "ratio", "morale", "found_sp", "K_sp", "asked", "infix", "tot_fix", "stop_phase", "catch_viol", "linked_q",
        "depth_seq", "depth_fin", "stops", "ready")


def set_cfg(d, seed):
    for k, v in dict(assign="k4", pm="k4h", gate=0, stick=0, suff="kart", order="plan", top="cap", req="data", rkey="", master=0, mit=60, mobj=2, warn=0.0).items():
        setattr(A.CFG, k, v)
    for k, v in d.items():
        if k != "legacy":
            setattr(A.CFG, k, v)
    A.CFG.rkey = str(seed)
    A.DETAIL.clear()
    del A.WLOG[:]
    del A.WSE[:]


def stability(wse, sw=2):
    """Tarifte 'kart bitene kadar kalir' ne kadar istikrar veriyor: hafta sonunda asamasi suren bir kartta olan kisi, sonraki haftanin basinda
    ayni kartta mi (ayni sprintin icinde ve sprint sinirinda ayri sayilir)."""
    byw = {off: (st, en) for off, k, st, en in wse}
    out = {"in_total": 0, "in_ch": 0, "bd_total": 0, "bd_ch": 0, "moved_idle": 0}
    for off in sorted(byw):
        if off < A.LO + 1 or off - 1 not in byw:
            continue
        prev_end = byw[off - 1][1]
        cur_start = byw[off][0]
        key = "bd" if off % sw == 0 else "in"
        for pid, cid in prev_end.items():
            out[key + "_total"] += 1
            if cur_start.get(pid) != cid:
                out[key + "_ch"] += 1
                if pid not in cur_start:
                    out["moved_idle"] += 1
    return out


def make_sim(scen, seed, legacy=False):
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
    return (D.Sim if legacy else A.A3Sim)(ppl, seed, **kw)


def run_task(task):
    arm, scen, seed = task
    cfg = ARMS[arm]
    set_cfg(cfg, seed)
    base = scen.split("|")[-1] if scen.startswith(("PR|", "DEP|")) else scen
    if cfg.get("master"):
        A.CFG.mit = MIT.get(base, 40)
    sim = make_sim(scen, seed, cfg.get("legacy", False))
    sim.run()
    m = D.metrics(sim, A.LO)
    out = {k: m[k] for k in KEEP if k in m}
    out["pm_aud"] = dict(sim.aud)
    if not cfg.get("legacy"):
        out["detail"] = dict(A.DETAIL)
        out["stab"] = stability(A.WSE, sim.sw)
        wkwin = sum(x["weeks"] for x in sim.rec if x["end"] > A.LO)
        out["wkwin"] = wkwin
        rows = []
        for i, x in enumerate(sim.rec):
            if x["end"] <= A.LO or i >= len(sim.plan_log):
                continue
            pl = sim.plan_log[i]
            pc = x["pcap"]
            rows.append({"plan": [pl["rowl"][j] / pl["pcap"][j] if pl["pcap"][j] else 0.0 for j in range(3)],
                         "true": [x["left"][j] / pc[j] if pc[j] else 0.0 for j in range(3)],
                         "pred": [pl.get("pred_left", [0, 0, 0])[j] / pl["pcap"][j] if pl["pcap"][j] else 0.0 for j in range(3)],
                         "load": pl["load"], "cap": pl["cap"], "ncards": pl["ncards"], "deliv": x["delivered"], "idle": x["idle"], "n": x["n"],
                         "weeks": x["weeks"], "left": list(x["left"]), "pcap": list(pc)})
        out["rows"] = rows
        out["wbs"] = sim.wbs
        out["warned"] = sim.warned
        out["warn_swaps"] = sim.warn_swaps
        out["master"] = dict(sim.master_stats)
    return arm, scen, seed, out


def fname(tag, arm, scen):
    return os.path.join(HERE, "out", tag, arm + "__" + scen.replace("|", "_").replace(" ", "_") + ".pkl")


def load(f):
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


def main_run(tag, arms, scens, budget, nseeds):
    os.makedirs(os.path.join(HERE, "out", tag), exist_ok=True)
    t0 = time.time()
    tasks = []
    for a in arms:
        for s in scens:
            have = load(fname(tag, a, s))
            for sd in range(1, nseeds + 1):
                if sd not in have:
                    tasks.append((a, s, sd))
    print("gorev", len(tasks), flush=True)
    done = 0
    buf = {}

    def flush():
        for (a, s), res in buf.items():
            f = fname(tag, a, s)
            d = load(f)
            d.update(res)
            pickle.dump(d, open(f, "wb"))
        buf.clear()
    if tasks:
        with ProcessPoolExecutor(max_workers=int(os.environ.get("A3_WORKERS", "2"))) as ex:
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
                    a, s, sd, m = fu.result()
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
        main_run(sys.argv[2], sys.argv[3].split(","), sys.argv[4].split(","), float(sys.argv[5]) if len(sys.argv) > 5 else 420.0,
                 int(sys.argv[6]) if len(sys.argv) > 6 else int(os.environ.get("A3_NSEEDS", "20")))
    elif cmd == "one":
        t = time.time()
        _, _, _, m = run_task((sys.argv[2], sys.argv[3], int(sys.argv[4])))
        print({k: (round(v, 3) if isinstance(v, float) else v) for k, v in m.items() if k in ("n", "mvp", "deliv", "idle_pct", "open_med", "fillplan", "pred", "detail", "stab", "master", "warned", "warn_swaps")}, "%.1fs" % (time.time() - t))
