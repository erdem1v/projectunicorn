import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bot, k5, model as M
arm, seed = sys.argv[1], int(sys.argv[2])
run = k5.load(bot.run_name(arm, seed))
w = bot.build_world(run, arm)
accts = bot.build_accounts(run, seed)
signs = {a.id: a.sign for a in accts}
first = min(signs.values())
out = bot.gen_outages(w, 0.5, 1.0, seed, first)
print("outages", [(t, round(h,1)) for t,h in out])
for label, mode, kw in [("eski", "old", {}), ("eski+yeni esik", "old", {"tol_new_for_old": True}), ("yeni", "new", {}), ("yeni kapisiz", "new", {"gate": False})]:
    res = bot.run_arm(run, w, accts, mode, outages=out, **kw)
    print("==", label)
    for ag,(n,mean,med,p10,p90) in bot.age_summary(res, signs).items():
        print("  age", ag, n, None if mean is None else round(mean,1), med, p10, p90)
    print("  loss", bot.loss_stats(res, signs))
    print("  renew", bot.renew_stats(res))
    print("  nedensiz/drop", bot.nedensiz_total(res), "mean sat", round(bot.mean_sat(res),1), "rejected", sum(1 for r in res.values() if r.get('rejected')))
rs = bot.real_series(run)
print("== gercek K5")
v = {}
for aid, r in rs.items():
    for ag in bot.AGES:
        t = r["sign"] + ag
        if t in r["sat"]:
            v.setdefault(ag, []).append(r["sat"][t])
for ag in bot.AGES:
    x = sorted(v.get(ag, []))
    if x: print("  age", ag, len(x), round(sum(x)/len(x),1), x[len(x)//2], x[int(.1*(len(x)-1))], x[int(.9*(len(x)-1))])
print("real churn", len(run["churn"]))
