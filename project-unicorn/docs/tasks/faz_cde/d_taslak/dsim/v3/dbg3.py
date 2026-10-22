import statistics
LOG = []
_orig = Card.fix_start
def fs(self):
    was = self.fixed
    _orig(self)
    if not was and self.fixed and self.kind == "feature":
        pn = self.prep_need()
        LOG.append((self.size, self.prepb / pn, self.preph / pn, self.preparer))
Card.fix_start = fs
for nm in ("C36", "C37"):
    for sd in (1, 2, 3):
        LOG.clear()
        fn, kw = SCEN[nm]
        kw = dict(kw); kw["weeks"] = 60
        sim = Sim(fn(), sd, **kw); sim.run()
        pms = sorted([(p.sk["product"], p.id) for p in sim.cells[0].people if p.role == "pm"], reverse=True)
        sb = [x[1] for x in LOG[len(LOG)//3:]]; hc = [x[2] for x in LOG[len(LOG)//3:]]
        by = {}
        for sz, b, h, pr in LOG[len(LOG)//3:]:
            by.setdefault(pr, []).append(sz)
        m = metrics(sim)
        print(nm, sd, "PMs", pms, "n=%d" % len(sb), "mean sb %.3f hcut %.3f" % (statistics.mean(sb), statistics.mean(hc)), "deliv %.1f" % m["deliv"],
              {k: (len(v), round(statistics.mean(v), 1)) for k, v in sorted(by.items(), key=lambda kv: str(kv[0]))})
