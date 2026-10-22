import sys, time, statistics
names = sys.argv[3].split(",")
seeds = range(1, int(sys.argv[4]) + 1)
for nm in names:
    rows = []
    t0 = time.time()
    for sd in seeds:
        _, _, m = run_one((nm, sd))
        rows.append(m)
    med = lambda k: statistics.median([m[k] for m in rows if m[k] is not None]) if any(m[k] is not None for m in rows) else None
    print("%-18s mvp=%s deliv=%.1f open=%s idle=%.3f fillplan=%s pulls=%.2f unfin>1=%.2f pool=%s nocard=%s pred=%.0e %.1fs" % (nm, med("mvp"), med("deliv"), med("open_med"), med("idle_pct"),
          None if med("fillplan") is None else round(med("fillplan"), 2), med("pulls"), med("unfin_gt1"), med("pool_ok"), med("nocard"), max(m["pred"] for m in rows), time.time() - t0), flush=True)
