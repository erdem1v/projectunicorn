import sys, time, statistics
names = sys.argv[3].split(",")
n = int(sys.argv[4])
res = {}
t0 = time.time()
out = run_many(names, range(1, n + 1), workers=2)
for nm in names:
    d = [m["deliv"] for m in out[nm].values()]
    res[nm] = statistics.median(d)
    print(nm, "deliv med %.2f mean %.2f" % (res[nm], statistics.mean(d)), "ready %.2f" % statistics.median([m["ready"] for m in out[nm].values()]))
if len(names) == 2:
    print("diff %s - %s = %.2f (mean %.2f)" % (names[1], names[0], res[names[1]] - res[names[0]],
          statistics.mean([m["deliv"] for m in out[names[1]].values()]) - statistics.mean([m["deliv"] for m in out[names[0]].values()])))
print("%.0fs" % (time.time() - t0))
