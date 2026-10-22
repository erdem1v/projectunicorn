Card._n = 0
class FakeSim:
    seed = 1
pp = [Person("dv", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), Person("ds", "des", {"design": 6, "product": 5, "eng": 0, "qa": 0}),
      Person("tt", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0})]
Sim._uniq(pp)
tm = Team(pp, 2)
cell = Cell(pp, 2)
def K(prof, tier, line=0, pos=0):
    c = Card("feature", line, tier, prof); c.pos = pos; c.fix_start(); return c
c1 = K("ui", 1, 0, 0)
nxt = [K("ui", 1, 1, 1), K("ui", 1, 2, 2)]
pl = Puller(FakeSim, cell, nxt, None)
cards = [c1]
for k in range(2):
    st = WSt(tm.n, len(cards))
    r = week2(tm, cards, st, 1, k, 2, k, puller=pl, alog=[])
    print("week", k, "idle", r[0], [(c.id, c.phase(), [round(x,2) for x in c.prog], [round(x,2) for x in c.need]) for c in cards], "rate", tm.rate)
