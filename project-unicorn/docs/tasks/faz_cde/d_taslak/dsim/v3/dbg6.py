import sys
nm = sys.argv[3]
fn, kw = SCEN[nm]
kw = dict(kw); kw["weeks"] = int(sys.argv[4]); kw["check_pred"] = False
al = []
kw["alog"] = al
sim = Sim(fn(), 1, **kw)
sim.run()
cells = {}
for x in sim.rec:
    print("sprint %2d-%2d deliv=%s cards=%d idle=%.2f" % (x["start"], x["end"], x["delivered"], x["cards"], x["idle"]))
for t, r, asg in al[:int(sys.argv[5])]:
    print(t, "row", r, asg)
