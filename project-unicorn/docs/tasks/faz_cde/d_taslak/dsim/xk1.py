import statistics, pickle
names = ["S1","S2","S3","S4","S5","S6","S4 +3* tasarimci","S11","S8","S10"] + ["C%d" % n for n in range(40,51)]
res = run_many(names, range(1,21))
pickle.dump(res, open("xk1_%s_%s.pkl" % (os.environ.get("DSIM_PHASE_CEIL","1"), os.environ.get("DSIM_PHASE_K","1.25")), "wb"))
for n in names:
    d = [res[n][s]["deliv"] for s in range(1,21)]
    print(n, statistics.median(d), "lead", round(statistics.median([res[n][s]["lead"] for s in range(1,21)]),2),
          "wip", round(statistics.median([res[n][s]["wip"] for s in range(1,21)]),1),
          "idle", round(statistics.median([res[n][s]["idle_w"] for s in range(1,21)]),1),
          "stop", [sum(res[n][s]["stop_phase"][i] for s in range(1,21)) for i in range(3)])
