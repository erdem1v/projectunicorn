import sys, statistics
for nm in sys.argv[3].split(","):
    rs = []
    for sd in range(1, 21):
        _, _, m = run_one((nm, sd)); rs.append(m)
    print("%-6s deliv %.1f esc100 %.2f found_sp %.2f open %.1f idle %.3f" % (nm, statistics.median([m["deliv"] for m in rs]), statistics.median([m["esc100"] for m in rs]), statistics.median([m["found_sp"] for m in rs]), statistics.median([m["open_med"] for m in rs]), statistics.median([m["idle_pct"] for m in rs])))
