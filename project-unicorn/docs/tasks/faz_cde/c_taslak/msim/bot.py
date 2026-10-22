"""Bot kosulari (K5 kayitlari) uzerinde memnuniyet kollari. python -I; sys.path elle eklenir (kendi dizinimiz)."""
import sys, os, zlib, random, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import k5, model as M

T_BOT = 104
V1 = 7                      # v1.0 haftasi (PROBE SHIP day=7)
EARLY = 20                  # A'nin olcusu: v1.0'dan sonra ilk 20 hafta (fix_tables.py:10,26)
ARMS = ["none", "worst", "due", "off"]
SEEDS = [7, 11]
AGES = [0, 1, 4, 8, 12, 26, 52]
LIVE_SECTORS = ["logistics", "manufacturing", "retail", "real_estate", "legal", "technology", "ecommerce", "finance"]


def run_name(arm, seed, b2c=False):
    return "full_run_%sfix_%s_%d" % ("b2c_" if b2c else "", arm, seed)


def build_world(run, arm):
    ps = k5.product_series(run, T_BOT)
    last = {}
    levels, live, op, touch, phase, reqs = {}, {}, {}, {}, {}, {}
    for t in range(1, T_BOT + 1):
        stt = run["state"].get(t) or last
        last = stt
        levels[t] = ps[t]["level"]
        live[t] = sum(ps[t]["live"].values())
        op[t] = int(stt["open_bugs"])
        phase[t] = int(stt["phase"])
        touch[t] = ps[t]["touch"]
        reqs[t] = ps[t]["reqs"]
    return M.World(T_BOT, levels, live, op, touch, phase, reqs, free=(arm == "off"))


def sector_of(aid, bonus, seed):
    r = random.Random(zlib.crc32(("%s|%d" % (aid, seed)).encode()))
    if bonus == 5: return "construction"
    if bonus == 3: return "insurance"
    return r.choice(LIVE_SECTORS)


def build_accounts(run, seed, persuasion=2, owner_output=0):
    out = []
    for s in run["sign"]:
        cid = s["id"]
        c = run["cust"].get(cid, {})
        if c:
            d0 = min(c)
            bonus = c[d0]["tol"] - (33 + 9 * (s["star"] - 1))
            bugs = {d: v["bugs"] for d, v in c.items()}
        else:
            bonus, bugs = 0, None
        sector = sector_of(cid, bonus, seed)
        out.append(M.Acct(cid, s["day"], s["star"], sector, s["mrr"], owner_output=owner_output, persuasion=persuasion,
                          acct_bugs=bugs, rng_seed=zlib.crc32(("b|%s|%d" % (cid, seed)).encode())))
    return out


def gen_outages(world, tier_mult, load_mult, seed, first_sign, v1=V1, open_override=None, T=None):
    """B'nin kesinti zari [kod incident_system.gd:55-85; sprint.json:42-44]: p = 0.10 x kademe x yuk x (1 + min(acik, 12)/8), en cok 0.30;
    iki olay arasi >= 4 hafta; v1.0'dan sonra ilk 3 hafta yok; hesap yoksa yok. Sure 3-8 saat tekduze [v3 par. 7.1 varsayim]."""
    rng = random.Random(seed)
    T = T or world.T
    ev = []; last = -10 ** 6
    for t in range(1, T + 1):
        u = rng.random(); hrs = rng.uniform(3, 8)
        if t < first_sign or t - v1 < 3 or t - last < 4:
            continue
        opn = world.open[t] if open_override is None else open_override
        p = min(0.30, 0.10 * tier_mult * load_mult * (1 + min(opn, 12) / 8.0))
        if u < p:
            ev.append((t, hrs)); last = t
    return ev


def run_arm(run, world, accts, mode, gate=True, tol_new_for_old=False, outages=None, renewals=True, budget_cut=True):
    res = {}
    ev = {"outage": outages or []}
    for a in accts:
        if tol_new_for_old and mode == "old":
            a2 = M.Acct(a.id, a.sign, a.star, a.sector, a.mrr, persuasion=a.persuasion, acct_bugs=a.acct_bugs, rng_seed=a.seed,
                        tol_override=M.tol_new(a.star, a.sector))
        else:
            a2 = a
        res[a.id] = M.simulate(a2, world, mode, gate=gate, events=ev, renewals=renewals, budget_cut=budget_cut)
    return res


def real_series(run):
    """K5'in gercek (eski model, gizli eksen) hesap serileri."""
    out = {}
    for s in run["sign"]:
        c = run["cust"].get(s["id"])
        if not c: continue
        out[s["id"]] = {"sat": {d: v["sat"] for d, v in c.items()}, "sign": s["day"], "left": run["churn"].get(s["id"])}
    return out


# ------------------------------------------------------------------ ozetler
def age_summary(results, signs, ages=AGES):
    """results: id -> sim sonucu ({'sat':{t:..}, 'rejected':..}); signs: id -> sign tick. Her yasta (imzadan beri hafta) hayattaki hesaplarin
    ortalama / medyan / p10 / p90 memnuniyeti."""
    out = {}
    for ag in ages:
        v = []
        for aid, r in results.items():
            if r.get("rejected"): continue
            t = signs[aid] + ag
            if t in r["sat"]:
                v.append(r["sat"][t])
        if v:
            v.sort()
            out[ag] = (len(v), sum(v) / len(v), st.median(v), v[int(0.1 * (len(v) - 1))], v[int(0.9 * (len(v) - 1))])
        else:
            out[ag] = (0, None, None, None, None)
    return out


def loss_stats(results, signs, T=T_BOT, v1=V1):
    """A'nin tanimi: erken = v1.0'dan sonraki ilk 20 hafta, gec = sonrasi; yuzde = kayip / (kayip + donemin sonunda ayakta)."""
    cut = v1 + EARLY
    ids = [a for a, r in results.items() if not r.get("rejected")]
    def lost_at(r, lim):
        return r["left"] is not None and r["left"] <= lim
    lost_cut = sum(1 for a in ids if lost_at(results[a], cut))
    alive_cut = sum(1 for a in ids if signs[a] <= cut and not lost_at(results[a], cut))
    lost_T = sum(1 for a in ids if lost_at(results[a], T))
    alive_T = sum(1 for a in ids if not lost_at(results[a], T))
    late = lost_T - lost_cut
    return {"n": len(ids), "early": lost_cut, "early_pct": 100.0 * lost_cut / max(1, lost_cut + alive_cut),
            "late": late, "late_pct": 100.0 * late / max(1, late + alive_T), "total": lost_T,
            "total_pct": 100.0 * lost_T / max(1, len(ids)),
            "risk": sum(1 for a in ids if results[a]["left_why"] == "risk" and results[a]["left"] <= T)}


def renew_stats(results, T=T_BOT):
    n = leave = leave_budget = shrink = budget = 0
    stances = [0] * 5
    for r in results.values():
        if r.get("rejected"): continue
        for x in r["renew"]:
            if x["t"] > T: continue
            n += 1; stances[x["stance"]] += 1
            if x["budget"]: budget += 1
            if x["result"] == "leave":
                leave += 1
                if x["budget"] == "leave": leave_budget += 1
            elif x["result"] == "shrink": shrink += 1
    return {"decisions": n, "leave": leave, "leave_budget": leave_budget, "shrink": shrink, "budget_events": budget,
            "stances": stances, "leave_pct": 100.0 * leave / max(1, n)}


def nedensiz_total(results):
    n = d = 0
    for r in results.values():
        if r.get("rejected"): continue
        n += r["nedensiz"]; d += r["drop_weeks"]
    return n, d


def mean_sat(results):
    v = [x for r in results.values() if not r.get("rejected") for x in r["sat"].values()]
    return sum(v) / len(v) if v else 0.0
