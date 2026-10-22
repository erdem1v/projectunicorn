import sys
for nm in ("G|gel4|tas-gel-test|0", "G|gel4|tas-gel-test|1"):
    fn, kw = SCEN[nm]; kw = dict(kw); kw["weeks"] = 12; kw["check_pred"] = False
    al = []; kw["alog"] = al
    sim = Sim(fn(), 1, **kw)
    op = sim.plan2
    def p2(cell, w, op=op, sim=sim):
        r = op(cell, w)
        print(" w%2d plan: %s" % (w, [(("F" if c.kind == "fix" else "K%d" % c.tier), c.line, c.id, round(c.remaining(), 1), c.id in sim.mvp_ids) for c in cell.cards]))
        return r
    sim.plan2 = p2
    sim.run()
    print(nm, "mvp", sim.mvp_week, [(x["start"], x["delivered"], round(x["idle"], 2)) for x in sim.rec])
