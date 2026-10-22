"""Sentetik dunyalar ve tek-hesap senaryolari. python -I."""
import sys, os, math, random
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, bot, model as M

T_LONG = 270                     # R9 §5.1 ile ayni ufuk


def base_levels():
    """A (duzenli) sekli = botun `fix_worst` tohum 7 urun serisi (gercek yayin takvimi); 104. haftadan sonra son deger."""
    run = k5.load(bot.run_name("worst", 7))
    w = bot.build_world(run, "worst")
    return run, w


def make_shape(shape, T=T_LONG):
    """R9 §5.1 oyuncu sekilleri, dort alana tasinmis: levels/live/touch botun gercek takviminden; acik hata yogunlugu R9'dan.
    A duzenli: gercek takvim, yogunluk .4 / hat. B donmus: takvim 20. haftada donar (urun hic dokunulmaz), yogunluk .1.
    C hizli ama ozensiz: A'nin takvimi, yogunluk .4'ten 3'e (0,05 / hafta). D durgun: 40'ta durur, 120'de A'nin 40. haftasindan devam (80 hafta kayik)."""
    run, w = base_levels()
    L, live, op, touch, phase, reqs = {}, {}, {}, {}, {}, {}
    def A(t):
        return min(t, 104)
    for t in range(1, T + 1):
        if shape == "B":
            src = min(t, 20); tch = set() if t > 20 else w.touch[t]
        elif shape == "D":
            if t <= 40: src = t; tch = w.touch[t]
            elif t < 120: src = 40; tch = set()
            else: src = min(t - 80, 104); tch = w.touch[A(t - 80)] if t - 80 <= 104 else {"core"}
        else:
            src = A(t); tch = w.touch[A(t)] if t <= 104 else {"core"}
        L[t] = w.levels[src]; live[t] = w.live[src]; touch[t] = tch
        phase[t] = w.phase[A(t)]
        reqs[t] = []
        d = {"A": 0.4, "B": 0.1, "C": min(3.0, 0.4 + 0.05 * max(0, t - 10)), "D": 0.4}[shape]
        op[t] = int(round(d * max(live[t], 1)))
    return M.World(T, L, live, op, touch, phase, reqs)


def r9_events():
    """R9 §5.1: kesintiler 40/90/150 (-6 -> 10 saat), 50. haftada bozulan soz (-12)."""
    return {"outage": [(40, 10.0), (90, 10.0), (150, 10.0)], "promise": [(50, "broken")]}


def run_shape(shape, star, mode, sign=10, sector="logistics", T=T_LONG, ev=None, renewals=False, risk=False):
    w = make_shape(shape, T)
    a = M.Acct("r9_%s_%d" % (shape, star), sign, star, sector, 1000)
    return M.simulate(a, w, mode, T=T, gate=False, events=ev or r9_events(), risk=risk, renewals=renewals, budget_cut=False)


def shape_summary(res, ages=(1, 4, 12, 26, 52, 104, 208), sign=10):
    ser = res["sat"]
    out = [ser.get(sign + a) for a in ages]
    ts = sorted(ser)
    big = 0
    for i in range(1, len(ts)):
        big = min(big, ser[ts[i]] - ser[ts[i - 1]])
    below = sum(1 for t in ts if ser[t] < res["tol"][t])
    return out, below, res["nedensiz"], big


# ---------------------------------------------------------------- M2: ilk 12 hafta
def m2_grid(arm="worst", seed=7):
    run = k5.load(bot.run_name(arm, seed))
    w = bot.build_world(run, arm)
    rows = []
    for t0 in range(7, 101):
        fw = M.Frozen(w, t0)
        for star in (1, 2, 3):
            for sector in ["logistics", "construction", "finance", "technology"]:
                for mode in ("new", "old"):
                    a = M.Acct("m2", t0, star, sector, 1000)
                    r = M.simulate(a, fw, mode, T=t0 + 12, gate=(mode == "new"), renewals=False, budget_cut=False, risk=False)
                    if r["rejected"]:
                        rows.append((t0, star, sector, mode, True, None, None, None, r["sat0"], 0))
                        continue
                    ser = r["sat"]
                    s0 = ser[t0]
                    mn = min(ser.values())
                    tol = r["tol"][t0]
                    rows.append((t0, star, sector, mode, False, s0, mn, ser[t0 + 12], s0 - tol, r["nedensiz"]))
    return rows


# ---------------------------------------------------------------- M6: soz
def steady_sat(mode, star, owner_output):
    w = M.Frozen(base_levels()[1], 60, touch_all=True)
    a = M.Acct("m6", 10, star, "logistics", 1000, owner_output=owner_output, tol_override=-100)
    r = M.simulate(a, w, mode, T=19, gate=False, renewals=False, budget_cut=False, risk=False)
    return r["sat"][19]


def m6_case(mode, star, owner_output, outcome, dist):
    run, ww = base_levels()
    w = M.Frozen(ww, 60, touch_all=True)
    s_ = steady_sat(mode, star, owner_output)
    tol = s_ - dist
    ev = {"promise": [(30, outcome)]} if outcome != "none" else {}
    a = M.Acct("m6", 10, star, "logistics", 1000, owner_output=owner_output, tol_override=tol)
    r = M.simulate(a, w, mode, T=110, gate=False, events=ev, renewals=False, budget_cut=False, risk=True)
    return r, s_, tol


# ---------------------------------------------------------------- M8: guncellenmeyen urun
def m8_case(freeze, sign, star, mode="new", T=200, sector="logistics"):
    run, ww = base_levels()
    L, live, op, touch, phase, reqs = {}, {}, {}, {}, {}, {}
    for t in range(1, T + 1):
        src = min(t, freeze, 104)
        L[t] = ww.levels[src]; live[t] = ww.live[src]; op[t] = ww.open[src] if False else 3
        touch[t] = ww.touch[t] if (t <= freeze and t <= 104) else set()
        phase[t] = ww.phase[min(t, 104)]; reqs[t] = []
    w = M.World(T, L, live, op, touch, phase, reqs)
    a = M.Acct("m8", sign, star, sector, 1000)
    return M.simulate(a, w, mode, T=T, gate=False, renewals=True, budget_cut=False, risk=False), w


def m8_active(sign, star, mode="new", T=200, sector="logistics"):
    run, ww = base_levels()
    L, live, op, touch, phase, reqs = {}, {}, {}, {}, {}, {}
    for t in range(1, T + 1):
        src = min(t, 104)
        L[t] = ww.levels[src]; live[t] = ww.live[src]; op[t] = 3
        touch[t] = ww.touch[src] if t <= 104 else {"core"}
        phase[t] = ww.phase[src]; reqs[t] = []
    w = M.World(T, L, live, op, touch, phase, reqs)
    a = M.Acct("m8a", sign, star, sector, 1000)
    return M.simulate(a, w, mode, T=T, gate=False, renewals=True, budget_cut=False, risk=False)


# ---------------------------------------------------------------- M7: kesinti
def m7_mc(tier, load, bugs, runs=2000, T=104, seed=1):
    rng = random.Random(seed)
    tot = 0; zero = 0; cap_hits = 0
    for _ in range(runs):
        last = -10 ** 6; n = 0
        for t in range(1, T + 1):
            u = rng.random()
            if t - 7 < 3 or t - last < 4:
                continue
            p = 0.10 * tier * load * (1 + min(bugs, 12) / 8.0)
            if p > 0.30:
                p = 0.30
            if u < p:
                n += 1; last = t
        tot += n; zero += (n == 0)
    return tot / runs, zero / runs
