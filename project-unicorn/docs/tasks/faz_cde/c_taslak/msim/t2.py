import sys, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import bot, k5, model as M
for arm in bot.ARMS:
    for seed in bot.SEEDS:
        run = k5.load(bot.run_name(arm, seed)); w = bot.build_world(run, arm)
        accts = bot.build_accounts(run, seed); signs = {a.id: a.sign for a in accts}
        out = bot.gen_outages(w, 0.5, 1.0, seed, min(signs.values()))
        row = [arm, seed, "gercek", len(run["churn"])]
        r_old = bot.run_arm(run, w, accts, "old", outages=out)
        r_new = bot.run_arm(run, w, accts, "new", outages=out)
        r_ng = bot.run_arm(run, w, accts, "new", gate=False, outages=out)
        for lab, rr in (("eski", r_old), ("yeni", r_new), ("yeni-kapisiz", r_ng)):
            ls = bot.loss_stats(rr, signs); rs = bot.renew_stats(rr)
            print(arm, seed, lab, "kayip erken %d (%.1f%%) gec %d (%.1f%%) toplam %.1f%%" % (ls["early"], ls["early_pct"], ls["late"], ls["late_pct"], ls["total_pct"]),
                  "| risk", ls["risk"], "| yen karar", rs["decisions"], "ayril", rs["leave"], "stances", rs["stances"], "| ort sat %.1f" % bot.mean_sat(rr), "| red", sum(1 for r in rr.values() if r.get("rejected")))
        print(arm, seed, "gercek K5 churn", len(run["churn"]))
