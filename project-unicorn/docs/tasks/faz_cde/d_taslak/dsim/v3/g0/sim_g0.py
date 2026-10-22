# D0t.2 · derinlik karti tuketimi: oran kesigi ve seri tavani modellenmis dsim3 kosulari. dsim3.py'ye dokunmaz, alt sinif olarak kosar.
# Calistirma (g0/ klasorunden):  python -I sim_g0.py <etiket> <varyant[,varyant...]> [grup=S1..S6] [butce_sn]
#   varyant: orig | map | cut2:<g0> | cut3:<g0> | ser:<N> | sat:<pay>   (g0 = ilk kart kazanci, alan seviyesi birimi; sat = biten kartlarin kazanci tavanin payina varinca alan kapanir)
#   Azalma carpani D3_DGAIN ortam degiskeniyle (varsayilan 0,75); ornek: D3_DGAIN=0.9 python -I sim_g0.py ek09 map,sat:0.95 S1,...,S6
# Ortam anahtarlari D0s'un R okumasidir (asagida kodla verilir). Sonuclar out/<etiket>/<varyant>__<senaryo>.pkl (tohum -> metrik).
import os, sys, time, pickle, statistics, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
for k, v in (("D3_KEYMODE", "plan"), ("D3_SHIELD", "0"), ("D3_PMRULE", "karar4h")):   # D0s R okumasi
    os.environ.setdefault(k, v)
sys.stdout.reconfigure(encoding="utf-8")
import dsim3 as D
from concurrent.futures import ProcessPoolExecutor, FIRST_COMPLETED, wait

# Gercek alan eslemesi (910ad1f: sprint.json:130-137, product_lines.gd:6): 9 hat = 5 kimlik (Cekirdek) + mobil + entegrasyon + guvenlik + dayaniklilik.
# Sim hatlari 0-4 Cekirdek, 5 Onboarding (mobil), 6 Entegrasyonlar, 7-8 Guven & Olcek.
AREA_OF = [0, 0, 0, 0, 0, 1, 2, 3, 3]
LINES_OF = [[0, 1, 2, 3, 4], [5], [6], [7, 8]]
REF = {2: [1.25, 1.0, 1.0, 1.0], 3: [2.0, 1.5, 1.5, 1.5]}      # product_quality.gd:37-41 (sayfa: sektorsuz, vurgu)
CAP = 1.5                                                          # product_quality.gd:13


class SimG(D.Sim):
    def __init__(self, people, seed, var=None, **kw):
        super().__init__(people, seed, **kw)
        self.var = var or {"rule": "none"}
        self.k3_sprint = [None] * 9
        self.first_depth = [None] * 4
        self.cut_sprint = [None] * 4
        self.base_at_first = [None] * 4

    # ---- seviye ve kesik
    def base_level(self, a):
        return sum(self.tier[l] for l in LINES_OF[a]) / len(LINES_OF[a])

    def area_level(self, a):
        g0 = self.var.get("g0", 0.25)
        return self.base_level(a) + g0 * (1 - D.DEPTH_GAIN ** self.depth_area[a]) / (1 - D.DEPTH_GAIN)

    def ref_star(self):
        return 3 if self.var["rule"] == "cut3" else 2

    def opened(self, a):
        return sum(self.depth_seq[l] for l in LINES_OF[a])

    def at_cut(self, a):
        r = self.var["rule"]
        if r in ("cut2", "cut3"):
            return self.area_level(a) / REF[self.ref_star()][a] >= CAP - 1e-9
        if r == "ser":
            return self.opened(a) >= self.var["N"]
        if r == "sat":                                   # alan basina biten kartlarin kazanci serinin tavaninin payina varinca (tavan = g0 / (1 - q), q = azalma)
            return self.depth_area[a] >= math.ceil(math.log(1 - self.var["share"]) / math.log(D.DEPTH_GAIN) - 1e-9)
        return False

    # ---- onerinin alan mantigi gercek eslemeyle
    def _impact(self, c):
        if c.kind == "fix":
            return float(max(1, c.nbug0))
        if c.src == "depth":
            return D.DEPTH_GAIN ** self.depth_area[AREA_OF[c.line]]
        return 1.0

    def _weak_area(self):
        ref = REF[self.ref_star()]
        return min(range(4), key=lambda a: (self.area_level(a) / ref[a], a))

    def suggest_order(self, cell, w, fixc, cl):
        out, used = [], set()

        def put(c, tr):
            out.append((c, tr))
            used.add(c.id)
            c.trank = tr
        for c in sorted([c for c in cl if c.promise], key=lambda c: (c.due, c.seq)):
            put(c, 1)
        horizon = w + 2 * cell.sw
        for c in sorted([c for c in cl if c.src == "req" and c.id not in used and c.due is not None and c.due <= horizon], key=lambda c: (c.due, c.seq)):
            put(c, 2)
        for c in fixc:
            if c.nbug0 >= D.PRIOFIX:
                put(c, 4)
        area = self._weak_area()
        pool = [c for c in cl if c.id not in used and AREA_OF[c.line] == area]
        if pool:
            put(min(pool, key=lambda c: (-self._impact(c) / c.size, c.seq)), 5)
        rest = [c for c in cl if c.id not in used] + [c for c in fixc if c.id not in used]
        rest.sort(key=lambda c: (-self._impact(c) / c.size, c.seq))
        for c in rest:
            put(c, 6)
        return out

    # ---- arz: derinlik kartlarini kesige gore ac
    def _issue(self):
        if self.arz == "sinirsiz":
            return
        for l in sorted(range(self.L), key=lambda x: (self.issued[x], x)):
            if self.issued[l] < 3 and self.issued[l] == self.tier[l]:
                self.issued[l] += 1
                self.cands.append(self._mk(l, self.issued[l], "tier"))
                self.new_tier += 1
        for l in range(self.L):
            if self.tier[l] >= 3 and self.k3_sprint[l] is None:
                self.k3_sprint[l] = self.sidx
        if self.arz not in ("kaynakli", "ea"):
            return
        r = self.var["rule"]
        if r in ("cut2", "cut3", "sat"):                # kesige varmis alanin acik ama planlanmamis derinlik kartlari onerilmez
            for a in range(4):
                if self.at_cut(a):
                    if self.cut_sprint[a] is None:
                        self.cut_sprint[a] = self.sidx
                    keep = []
                    for c in self.cands:
                        if c.src == "depth" and AREA_OF[c.line] == a:
                            self.depth_open[c.line] -= 1
                        else:
                            keep.append(c)
                    self.cands = keep
        for l in range(self.L):
            if self.tier[l] >= 3:
                a = AREA_OF[l]
                while self.depth_open[l] < self._users_target(l) and not self.at_cut(a):
                    k = self.depth_seq[l] % 3
                    self.depth_seq[l] += 1
                    self.depth_open[l] += 1
                    self.cands.append(self._mk(l, k + 1, "depth"))
                    self.new_depth += 1
                    if self.first_depth[a] is None:
                        self.first_depth[a] = self.sidx
                        self.base_at_first[a] = self.base_level(a)

    def release(self, c, extra_known=0):
        was = c.src == "depth"
        pre = c.line % 4
        nn = super().release(c, extra_known)
        if was:
            self.depth_area[pre] -= 1                   # taban sinifin mod-4 kaydini geri al, gercek alana yaz
            self.depth_gain[pre] -= D.DEPTH_GAIN ** self.depth_area[pre]
            a = AREA_OF[c.line]
            self.depth_gain[a] += D.DEPTH_GAIN ** self.depth_area[a]
            self.depth_area[a] += 1
        return nn


def parse(var):
    p = var.split(":")
    if p[0] in ("orig", "map"):
        return {"rule": "none"}
    if p[0] in ("cut2", "cut3"):
        return {"rule": p[0], "g0": float(p[1])}
    if p[0] == "ser":
        return {"rule": "ser", "N": int(p[1])}
    if p[0] == "sat":
        return {"rule": "sat", "share": float(p[1])}
    raise ValueError(var)


def run_task(task):
    var, name, seed = task
    fn, kw = D.SCEN[name]
    kw = dict(kw)
    kw.setdefault("weeks", 60)
    ppl = fn()
    if var == "orig":
        sim = D.Sim(ppl, seed, **kw)
        sim.run()
        extra = {}
    else:
        sim = SimG(ppl, seed, var=parse(var), **kw)
        sim.run()
        extra = {"k3_sprint": sim.k3_sprint, "first_depth": sim.first_depth, "cut_sprint": sim.cut_sprint,
                 "base_first": sim.base_at_first, "lvl_end": [sim.area_level(a) for a in range(4)],
                 "tier_end": list(sim.tier), "sprints": sim.sidx}
    m = D.metrics(sim, 20)
    keep = {k: m[k] for k in ("n", "deliv", "idle_pct", "pool_ok", "nocard", "pts_src", "req", "depth_seq", "depth_fin", "depth_area",
                              "fillplan", "mvp", "sprints", "cards_sprint", "weeks_run")}
    keep.update(extra)
    keep["depth_seq"] = keep["depth_seq"][:9]
    keep["depth_fin"] = keep["depth_fin"][:9]
    return var, name, seed, keep


def fname(tag, var, name):
    return os.path.join(HERE, "out", tag, var.replace(":", "_") + "__" + name.replace("|", "_") + ".pkl")


def load(f):
    try:
        return pickle.load(open(f, "rb"))
    except Exception:
        return {}


if __name__ == "__main__":
    tag, varlist = sys.argv[1], sys.argv[2].split(",")
    scen = sys.argv[3].split(",") if len(sys.argv) > 3 else ["S%d" % i for i in range(1, 7)]
    budget = float(sys.argv[4]) if len(sys.argv) > 4 else 420.0
    nseeds = int(os.environ.get("G0_SEEDS", "20"))
    os.makedirs(os.path.join(HERE, "out", tag), exist_ok=True)
    t0 = time.time()
    tasks = []
    for v in varlist:
        for s in scen:
            nm = "DEP|" + s
            have = load(fname(tag, v, nm))
            for sd in range(1, nseeds + 1):
                if sd not in have:
                    tasks.append((v, nm, sd))
    print("gorev", len(tasks), flush=True)
    buf = {}
    done = 0
    with ProcessPoolExecutor(max_workers=2) as ex:
        it = iter(tasks)
        pend = {}
        stop = False
        while True:
            while not stop and len(pend) < 4:
                if time.time() - t0 > budget:
                    stop = True
                    break
                try:
                    t = next(it)
                except StopIteration:
                    stop = True
                    break
                pend[ex.submit(run_task, t)] = t
            if not pend:
                break
            dn, _ = wait(list(pend), return_when=FIRST_COMPLETED)
            for fu in dn:
                pend.pop(fu)
                v, nm, sd, m = fu.result()
                buf.setdefault((v, nm), {})[sd] = m
                done += 1
    for (v, nm), res in buf.items():
        f = fname(tag, v, nm)
        d = load(f)
        d.update(res)
        pickle.dump(d, open(f, "wb"))
    left = len(tasks) - done
    print("bitti %d/%d, kalan %d, %.0f sn" % (done, len(tasks), left, time.time() - t0), flush=True)
    print("KALDI" if left else "TAMAM")
