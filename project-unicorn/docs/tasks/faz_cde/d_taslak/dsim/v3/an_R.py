exec(open("an_common.py", encoding="utf-8").read())
R = L("R")
print("istek payi: (made, merged, dropped, done, new_req, new_depth, new_tier); pts_src (req, depth, tier)")
for b in ("S3","S4","S5","S6"):
    for acc in (100, 330):
        n = "R|%s|%d" % (b, acc)
        rq = [md(R, n, "req", i) for i in range(7)]
        ps = [md(R, n, "pts_src", i) for i in range(3)]
        totc = rq[4] + rq[5] + rq[6]
        print(n, "teslim %.1f" % md(R, n, "deliv"), "req", rq, "kart payi %.0f%%" % (100*rq[4]/totc), "puan payi %.0f%%" % (100*ps[0]/sum(ps)), "istek tamam %.0f%%" % (100*rq[3]/rq[4]), "idle %.2f" % md(R,n,"idle_pct"), "pool_ok %s" % md(R,n,"pool_ok"), "cand?")
