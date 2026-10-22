import sys
nm = sys.argv[3]
fn, kw = SCEN[nm]
kw = dict(kw); kw.setdefault("weeks", 24)
kw["weeks"] = int(sys.argv[4]) if len(sys.argv) > 4 else 24
sim = Sim(fn(), 1, **kw)
# wrap plan2 to print
orig_plan = sim.plan2
def p2(cell, w):
    r = orig_plan(cell, w)
    cap = cell.team.cap
    print("w%2d PLAN cap=%.1f load=%.1f (%.0f%%) stop=%s cards=%s" % (w, cap, sum(c.remaining() for c in cell.cards), 100*sum(c.remaining() for c in cell.cards)/cap, cell.stop,
          [("F" if c.kind=="fix" else "K%d"%c.tier, c.line, round(c.remaining(),1)) for c in cell.cards]), "pullq", len(cell.pullq))
    return r
sim.plan2 = p2
sim.run()
for x in sim.rec:
    print("sprint %2d-%2d deliv=%s cards=%d pulled=%d unfin=%d idle=%.2f/%d fillplan=%.2f" % (x["start"], x["end"], x["delivered"], x["cards"], x["pulled"], x["unfin"], x["idle"], x["n"]*x["weeks"], x["fillplan"]))
