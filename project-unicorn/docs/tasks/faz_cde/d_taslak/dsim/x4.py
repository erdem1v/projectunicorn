for nn in (47,48):
    sim = Sim(SCEN["C%d"%nn](), 1)
    sim.run()
    print(nn, "cap", sim.team.cap)
    for x in sim.rec[10:16]:
        print("  ", x["start"], x["end"], "ncards", x["ncards"], "done", x["cards"], "fixes", x["fixes"], "deliv", x["delivered"], "left", [round(v,1) for v in x["left"]], "idle", round(x["idle"],1))
