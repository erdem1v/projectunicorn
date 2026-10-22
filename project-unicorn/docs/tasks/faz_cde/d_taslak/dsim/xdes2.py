import statistics
from collections import Counter
# kac tasarim puani bosa gidiyor (prog[0] > need[0] fix_start sonrasi) ve tasarimci zamani nereye gidiyor
def run(name, seed):
    sim = Sim(SCEN[name](), seed, check_pred=False)
    waste = [0.0]
    orig = Card.fix_start
    def fs(self):
        was = self.fixed
        orig(self)
        if not was and self.kind == "feature":
            waste[0] += max(0.0, self.prog[0] - self.need[0])
    Card.fix_start = fs
    sim.run()
    Card.fix_start = orig
    m = metrics(sim, name)
    return m, waste[0]
for nm in ("S4", "S4 +3* tasarimci"):
    ws, dl, rd = [], [], []
    for s in range(1, 11):
        m, w = run(nm, s); ws.append(w); dl.append(m["deliv"]); rd.append(m["ready"])
    print(nm, "deliv", statistics.median(dl), "bosa tasarim", round(statistics.median(ws),1), "hazir", round(statistics.median(rd),3))
