import statistics
def runv(nn, cap=None, seeds=range(1,6)):
    out=[]
    for s in seeds:
        sim = Sim(SCEN["C%d"%nn](), s, check_pred=False)
        if cap: sim.team.cap=cap
        sim.run()
        out.append(metrics(sim,"x")["deliv"])
    return statistics.median(out)
print("C47", runv(47), "C48", runv(48), "C48 cap47", runv(48, 890.4), "C47 cap48", runv(47, 910.4))
# WIP
for nn in (12,25,47,48,50):
    sim = Sim(SCEN["C%d"%nn](), 1, check_pred=False); sim.run()
    w=[x for x in sim.rec if x["end"]>20]
    print(nn, "ncards ort", round(sum(x["ncards"] for x in w)/len(w),1), "biten ort", round(sum(x["cards"]+x["fixes"] for x in w)/len(w),1))
