"""Bolum 5: kapi degerlendirmesi. p1.pkl, p2.json, p3.json, p4.json uzerinden; M1 toplami icin yeni model senaryolarini tekrar kosar. python -I."""
import sys, os, json, pickle, statistics as st
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
import k5, bot, model as M, scen, real_old, econ

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
G = {}


def pct(v, q):
    v = sorted(v)
    return v[int(q * (len(v) - 1))] if v else None


def main():
    P = pickle.load(open(os.path.join(OUT, "p1.pkl"), "rb"))
    # ---------------- M1: nedensiz dusus toplami
    n1 = {}
    n1["bot_new"] = sum(bot.nedensiz_total(P[a]["new"]["res"])[0] + bot.nedensiz_total(P[a]["new_ng"]["res"])[0] for a in bot.ARMS)
    n1["bot_old_replica"] = sum(bot.nedensiz_total(P[a]["old"]["res"])[0] for a in bot.ARMS)
    n1["bot_old_replica_nt"] = sum(bot.nedensiz_total(P[a]["old_nt"]["res"])[0] for a in bot.ARMS)
    strict = general = drops = 0
    for a in bot.ARMS:
        for s in bot.SEEDS:
            d, s1, s2 = P[a]["real_ned"][s]
            drops += d; strict += s1; general += s2
    n1["real_drops"] = drops; n1["real_strict"] = strict; n1["real_general"] = general
    nd_r9 = nd_r9_old = 0
    for shape in "ABCD":
        for star in (1, 2, 3):
            nd_r9 += scen.run_shape(shape, star, "new", renewals=True, risk=True)["nedensiz"]
            nd_r9_old += scen.run_shape(shape, star, "old", renewals=True, risk=True)["nedensiz"]
    n1["r9_new"] = nd_r9; n1["r9_old"] = nd_r9_old
    nd_m2 = nd_m2_old = 0; cells = 0
    for arm, seed in (("worst", 7), ("worst", 11)):
        for row in scen.m2_grid(arm, seed):
            if row[3] == "new": nd_m2 += row[9]
            else: nd_m2_old += row[9]
            cells += 1
    n1["m2_new"] = nd_m2; n1["m2_old"] = nd_m2_old; n1["m2_cells"] = cells
    nd_m6 = nd_m6_old = 0
    for mode in ("old", "new"):
        for owner in (0, 5):
            for outc in ("broken", "late", "kept"):
                for dist in (8, 20):
                    run, ww = scen.base_levels()
                    w = M.Frozen(ww, 22, touch_all=True)
                    a0 = M.Acct("m6", 10, 2, "logistics", 1000, owner_output=owner, tol_override=-100)
                    s19 = M.simulate(a0, w, mode, T=19, gate=False, renewals=False, budget_cut=False, risk=False)["sat"][19]
                    a = M.Acct("m6", 10, 2, "logistics", 1000, owner_output=owner, tol_override=s19 - dist)
                    r = M.simulate(a, w, mode, T=110, gate=False, events={"promise": [(30, outc)]}, renewals=False, budget_cut=False, risk=True)
                    if mode == "new": nd_m6 += r["nedensiz"]
                    else: nd_m6_old += r["nedensiz"]
    n1["m6_new"] = nd_m6; n1["m6_old"] = nd_m6_old
    nd_m8 = 0
    for freeze in (30, 20):
        for star in (1, 3):
            r, _ = scen.m8_case(freeze, 12, star, "new", T=200)
            nd_m8 += r["nedensiz"]
    n1["m8_new"] = nd_m8
    n1["new_total"] = n1["bot_new"] + n1["r9_new"] + n1["m2_new"] + n1["m6_new"] + n1["m8_new"]
    G["M1"] = n1
    # ---------------- ilk hafta: gercek K5 (Erdem'in sorusu)
    fw = {}
    for a in bot.ARMS:
        d1 = []; d4 = []
        for s in bot.SEEDS:
            run = k5.load(bot.run_name(a, s))
            for sg in run["sign"]:
                c = run["cust"].get(sg["id"])
                if not c: continue
                t0 = sg["day"]
                if t0 in c and t0 + 1 in c: d1.append(c[t0 + 1]["sat"] - c[t0]["sat"])
                if t0 in c and t0 + 4 in c: d4.append(c[t0 + 4]["sat"] - c[t0]["sat"])
        fw[a] = {"n": len(d1), "d1_mean": sum(d1) / len(d1), "d1_le5": sum(1 for x in d1 if x <= -5) / len(d1), "d1_le15": sum(1 for x in d1 if x <= -15) / len(d1),
                 "d4_mean": sum(d4) / len(d4), "d4_le15": sum(1 for x in d4 if x <= -15) / len(d4), "d1_up": sum(1 for x in d1 if x >= 5) / len(d1)}
    G["first_week"] = fw
    # kopya dogrulamasi
    val = {}
    for a in bot.ARMS:
        ok = tot = 0
        for s in bot.SEEDS:
            o, t, _ = real_old.validate(k5.load(bot.run_name(a, s)))
            ok += o; tot += t
        val[a] = (ok, tot)
    G["validate"] = val
    # ---------------- M3-M5 (per seed), kapisiz ve kapili
    ps = {}
    for a in bot.ARMS:
        ps[a] = {}
        for s in bot.SEEDS:
            ps[a][s] = {m: P[a]["per_seed"][s][m] for m in ("real", "old", "new", "new_ng")}
    G["per_seed"] = ps
    # ---------------- M10: imza kapisi, MVP sonrasi 26 hafta (7..33)
    m10 = {}
    for a in bot.ARMS:
        n = rej = 0; rej_mrr = 0; mrr = 0
        for (s, aid), r in P[a]["new"]["res"].items():
            sg = P[a]["new"]["signs"][(s, aid)]
            if 7 <= sg <= 33:
                n += 1
                if r.get("rejected"): rej += 1
        m10[a] = (n, rej)
    G["M10"] = m10
    # ---------------- yenileme tutumu: fark dagilimi
    dist = {}
    for a in bot.ARMS:
        v = [x["diff"] for r in P[a]["new"]["res"].values() if not r.get("rejected") for x in r["renew"]]
        dist[a] = {"n": len(v), "p10": pct(v, .1), "p50": pct(v, .5), "p90": pct(v, .9), "min": min(v), "max": max(v)}
    G["renew_diff"] = dist
    # ---------------- U dagilimi (imza anindaki), faz bazinda
    ud = {}
    for a in ("worst", "none"):
        v = {1: [], 2: [], 3: []}
        for (s, aid), r in P[a]["new_ng"]["res"].items():
            sg = P[a]["new_ng"]["signs"][(s, aid)]
            run = k5.load(bot.run_name(a, s))
            ph = int(run["state"].get(sg, run["state"][max(run["state"])])["phase"])
            v[ph].append(r["U0"])
        ud[a] = {ph: (len(x), pct(x, .1), pct(x, .5), pct(x, .9)) for ph, x in v.items() if x}
    G["U_at_sign"] = ud
    # urun seviyesi (kayit), tohum 7 worst
    run = k5.load(bot.run_name("worst", 7)); w = bot.build_world(run, "worst")
    G["levels_worst7"] = {t: {a: round(w.levels[t][a], 2) for a in M.AREAS} for t in (7, 15, 25, 30, 40, 60, 104)}
    G["phase_worst7"] = {t: w.phase[t] for t in (7, 15, 25, 30, 40, 60, 72, 104)}
    json.dump(G, open(os.path.join(OUT, "g.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1, default=str)
    print(json.dumps(G, ensure_ascii=False, indent=1, default=str))


if __name__ == "__main__":
    main()
