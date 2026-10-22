import statistics
def run(name, seed, cap=None, noahead=False):
    sim = Sim(SCEN[name](), seed, check_pred=False)
    if cap is not None:
        sim.team.cap = cap
    if noahead:
        sim.has_des = False
    sim.run()
    return metrics(sim, name)
capS4 = Team(SCEN["S4"]()).cap
capD = Team(SCEN["S4 +3* tasarimci"]()).cap
print("cap", capS4, capD)
for lbl, kw0, kw1 in (("normal", {}, {}), ("ayni kapasite", {}, {"cap": capS4}), ("onden tasarim yok", {"noahead": True}, {"noahead": True})):
    d = []
    for s in range(1, 11):
        a = run("S4", s, **kw0); b = run("S4 +3* tasarimci", s, **kw1)
        d.append(b["deliv"] - a["deliv"])
    print(lbl, "med", statistics.median(d), "lower", sum(1 for x in d if x < 0), "/10")
