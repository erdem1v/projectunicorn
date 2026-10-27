# SPRINT_DUZENI icin arz deneyi: D modeli (dsim.py) + sonlu katalog ya da sinirli aday havuzu.
# Calistirma: python -I ../dsim/dsim.py exec arz.py   (dsim globalleri icinde calisir)
import statistics as _st

PROFS = ["ui", "logic", "risk"]


class ArzSim(Sim):
    def __init__(self, people, seed, L=9, mode="cat", P=None, weeks=60):
        super().__init__(people, seed, weeks=weeks, check_pred=False, lines=L)
        self.mode, self.P = mode, P
        self.prof = {i: PROFS[min(2, i * 3 // L)] for i in range(L)}
        m = [0, L // 3, 2 * L // 3]
        Card._n += 0
        self.stream = [Card("feature", l, 1, self.prof[l]) for l in m]
        self.mvp_ids = {c.id for c in self.stream}
        self.next_tier = {i: (2 if i in m else 1) for i in range(L)}
        self.issued = {i: (1 if i in m else 0) for i in range(L)}
        self.vis = 10 ** 9
        self.new_log = []
        self.exhaust = None

    # katalog: hattin sonraki kademesi ancak oncekinin kapanisindan sonra aday olur
    def _issue(self):
        if self.mode != "cat":
            return
        elig = [l for l in range(self.lines) if self.issued[l] < 3 and self.issued[l] == self.tier[l]]
        elig.sort(key=lambda l: (self.issued[l], l))
        for l in elig:
            self.issued[l] += 1
            self.stream.append(Card("feature", l, self.issued[l], self.prof[l]))

    def peek(self, k):
        if self.mode == "cat":
            self._issue()
            return self.stream[:k]
        k = min(k, self.vis)
        while len(self.stream) < k:
            self.stream.append(self.gen())
        return self.stream[:k]

    def take(self):
        self.vis -= 1
        return self.stream.pop(0)

    def plan(self):
        self.vis = self.P if self.mode == "pool" else 10 ** 9
        cards = []
        if self.live:
            have = {c.line for c in self.carried if c.kind == "fix"}
            due = sorted([(b, l) for l, b in enumerate(self.bugs) if b >= FIX_DUE_MIN and l not in have], key=lambda t: (-t[0], t[1]))
            fl = sum(c.remaining() for c in self.carried if c.kind == "fix")
            for b, l in due:
                c = Card("fix", l, bugs=b)
                c.fix_start()
                if fl > EPS and fl + c.remaining() > FIX_SHARE_MAX * self.team.cap + EPS:
                    continue
                fl += c.remaining()
                cards.append(c)
        cards += self.carried
        self.carried = []
        for c in cards:
            c.fix_start()
        cap = self.team.cap
        fix_load = sum(c.remaining() for c in cards if c.kind == "fix")
        new = 0
        for _ in range(1000):
            pk = self.peek(1)
            if not pk:
                break
            trial = pk[0].clone()
            trial.fix_start()
            if cards:
                if sum(c.remaining() for c in cards) + trial.remaining() > CEIL * cap:
                    break
                stop = False
                for i in range(3):
                    tn = trial.need[i] - trial.prog[i]
                    if tn > EPS and sum(max(0.0, c.need[i] - c.prog[i]) for c in cards) + tn > PHASE_K * self.team.pcap[i]:
                        stop = True
                        break
                if stop or not self.play_copy_gets_work(cards, trial):
                    break
            c = self.take()
            c.fix_start()
            self.ready_log.append(c.ready)
            cards.append(c)
            new += 1
        self.new_log.append(new)
        if self.mode == "cat" and self.exhaust is None and all(t >= 3 for t in self.tier):
            self.exhaust = self.rec[-1]["end"] if self.rec else 0
        return cards, fix_load, cap


TEAMS = ["S1", "S2", "S3", "S4", "S5", "S6"]


def one(task):
    name, seed, L, mode, P, weeks = task
    sim = ArzSim(SCEN[name](), seed, L=L, mode=mode, P=P, weeks=weeks)
    sim.run()
    n = sim.team.n
    r = sim.rec
    ex = sim.exhaust
    pre = [x for x in r if ex is None or x["end"] <= ex]
    wk = sum(x["weeks"] for x in pre) or 1
    win = [x for x in r if x["end"] > 20] or r
    wkw = sum(x["weeks"] for x in win) or 1
    return {
        "ex": ex,
        "idle_pre": sum(x["idle"] for x in pre) / wk / n,
        "cards_pre": _st.mean([x["ncards"] for x in pre]) if pre else 0,
        "new_pre": _st.mean(sim.new_log[:len(pre)]) if pre else 0,
        "idle_win": sum(x["idle"] for x in win) / wkw / n,
        "deliv_win": sum(x["delivered"] for x in win) / wkw,
        "cards_win": _st.mean([x["ncards"] for x in win]),
        "new_win": _st.mean(sim.new_log[-len(win):]),
        "mvp": sim.mvp_week,
    }


def med(xs):
    xs = [x for x in xs if x is not None]
    return _st.median(xs) if xs else None


def table(rows, keys):
    for row in rows:
        print(" | ".join(str(v) for v in row))


SEEDS = range(1, 6)
out = {}
tasks = []
for nm in TEAMS:
    for L in (9, 14):
        tasks += [(nm, s, L, "cat", None, 140) for s in SEEDS]
for nm in TEAMS:
    n = len(SCEN[nm]())
    for P in sorted({3, 6, 9, 14, max(1, round(0.5 * n)), max(1, round(0.75 * n)), n, round(1.25 * n)}):
        tasks += [(nm, s, 9, "pool", P, 60) for s in SEEDS]
res = [one(t) for t in tasks]
agg = {}
for t, m in zip(tasks, res):
    agg.setdefault((t[0], t[2], t[3], t[4]), []).append(m)
print("KATALOG (sonlu, kademe zinciri; 5 tohum medyani)")
print("ekip | hat | katalog biter (hf) | biter kadar bosta % | sprintteki kart | sprintte yeni kart | MVP")
for nm in TEAMS:
    for L in (9, 14):
        ms = agg[(nm, L, "cat", None)]
        print(nm, len(SCEN[nm]()), "|", L, "|", med([m["ex"] for m in ms]), "|", "%.0f" % (100 * med([m["idle_pre"] for m in ms])),
              "|", "%.1f" % med([m["cards_pre"] for m in ms]), "|", "%.1f" % med([m["new_pre"] for m in ms]), "|", med([m["mvp"] for m in ms]))
print()
print("HAVUZ (sonsuz akis, plan basina P yeni aday; 21-60. hafta)")
print("ekip | P | bosta % | teslim/hf | sprintteki kart | sprintte yeni kart")
for nm in TEAMS:
    for key in sorted(k for k in agg if k[0] == nm and k[2] == "pool"):
        ms = agg[key]
        print(nm, len(SCEN[nm]()), "|", key[3], "|", "%.0f" % (100 * med([m["idle_win"] for m in ms])), "|", "%.1f" % med([m["deliv_win"] for m in ms]),
              "|", "%.1f" % med([m["cards_win"] for m in ms]), "|", "%.1f" % med([m["new_win"] for m in ms]))
