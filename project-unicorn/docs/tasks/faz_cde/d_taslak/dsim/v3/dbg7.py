exec(open("dan.py", encoding="utf-8").read())
for n in range(36, 50):
    r = curve_roles(n)[-1]
    a, b = "C%d" % (n - 1), "C%d" % n
    da, db = D("R", a), D("R", b)
    sd = sorted(set(da) & set(db))
    diff = [db[s]["deliv"] - da[s]["deliv"] for s in sd]
    print(n, r, "med %.1f mean %.2f se %.2f neg %d/20  idle %.3f -> %.3f  deliv %.1f -> %.1f  open %.1f -> %.1f" % (statistics.median(diff), statistics.mean(diff), statistics.stdev(diff)/len(diff)**0.5, sum(1 for d in diff if d<0),
          md("R", a, "idle_pct"), md("R", b, "idle_pct"), md("R", a, "deliv"), md("R", b, "deliv"), md("R", a, "open_med"), md("R", b, "open_med")))
