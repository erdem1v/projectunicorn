import sys
nm = sys.argv[3]
fn, kw = SCEN[nm]
kw = dict(kw); kw["weeks"] = int(sys.argv[4])
sim = Sim(fn(), 1, **kw)
op = sim.plan2
def p2(cell, w):
    nc = len(cell.carried)
    r = op(cell, w)
    cap = cell.team.cap
    pred = sim.predict2(cell)
    unf = [(c.kind[0], c.line, c.tier, round(c.remaining(), 1)) for c in pred if c.phase() < 4]
    print("w%2d carried_in=%d cards=%d load=%.0f%% stop=%s predicted_unfinished=%d %s pullq=%d" % (w, nc, len(cell.cards), 100 * sum(c.remaining() for c in cell.cards) / cap, cell.stop, len(unf), unf, len(cell.pullq)))
    return r
sim.plan2 = p2
sim.check_pred = False
sim.run()
for x in sim.rec:
    print("sprint %2d-%2d cards=%d pulled=%d unfin_real=%d idle=%.1f" % (x["start"], x["end"], x["cards"], x["pulled"], x["unfin"], x["idle"]))
