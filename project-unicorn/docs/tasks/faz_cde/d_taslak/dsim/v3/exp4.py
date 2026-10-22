import sys, time, statistics
names = sys.argv[3].split(",")
for nm in names:
    tot = {}
    t0 = time.time()
    for sd in range(1, int(sys.argv[4]) + 1):
        _, _, m = run_one((nm, sd))
        for k, v in m["prom"].items():
            tot[k] = tot.get(k, 0) + v
    print(nm, tot, "linked_q %.2f" % m["linked_q"], "%.1fs" % (time.time() - t0))
