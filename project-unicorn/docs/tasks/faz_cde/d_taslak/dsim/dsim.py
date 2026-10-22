# Faz D ekip modeli simulasyonu. D_MODEL_v2.md "6. Simulasyon tanimi"nin uygulamasi.
# Calistirma:  python -I dsim.py <komut>     (komutlar dosyanin sonunda)
import math, random, statistics, sys, os, json, time
from concurrent.futures import ProcessPoolExecutor
sys.stdout.reconfigure(encoding="utf-8")

# ---------------------------------------------------------------- sabitler (6.2)
BASE = 10.0
SIZE = {1: 15, 2: 25, 3: 40}
NEED = {
    ("ui", 1): [5, 7, 3], ("ui", 2): [9, 11, 5], ("ui", 3): [14, 18, 8],
    ("logic", 1): [2, 10, 3], ("logic", 2): [4, 16, 5], ("logic", 3): [6, 26, 8],
    ("risk", 1): [2, 8, 5], ("risk", 2): [3, 13, 9], ("risk", 3): [4, 22, 14],
}
FIX_NEED = {5: [0, 3, 2], 10: [0, 7, 3]}
SLICE = 8.0
H0 = 0.03
KIND_H = {"feature": 1.0, "fix": 0.3}
C_REF = 0.40
PREP_RATIO = 0.20
READY_CUT = 0.20
READY_H = 0.25
TITIZ_SPEED, TITIZ_Q = 0.85, 0.5
CEIL = 1.25
# (simulasyon sonrasi) K1: tavan her asama satirinda ayrica; K2: planin kendiliginden aldigi duzeltme isi <= kapasitenin yarisi
PHASE_CEIL = os.environ.get("DSIM_PHASE_CEIL", "1") == "1"
PHASE_K = float(os.environ.get("DSIM_PHASE_K", "2.0"))
FIX_SHARE_MAX = float(os.environ.get("DSIM_FIX_SHARE_MAX", "0.5"))
SPRINT_WEEKS = 2
FIX_DUE_MIN = 2
FLOOR_WEEK, USAGE = 0.7, 1.5
UNFIT_MORALE = -2
EPS = 1e-6
AREA = ["design", "eng", "qa"]
MAIN = {"pm": "product", "des": "design", "dev": "eng", "test": "qa"}
SECN = {"pm": "design", "des": "product", "dev": "qa", "test": "eng"}
DIST = [6, 4, 8, 5, 3, 6, 7, 4, 5, 6]
FOUNDER_SK = {"product": 4, "design": 0, "eng": 4, "qa": 0}


def Y(s):
    return 0.5 + 0.05 * s + 0.01 * s * s


# ---------------------------------------------------------------- kisi (6.3)
def fit(role, boxes, area):
    """(U, sinif) ya da None."""
    if role == "founder":
        return (1.0, 1) if area in AREA else None
    if area == "qa":
        if "test" not in boxes:
            return None
        if MAIN[role] == "qa":
            return (1.0, 0)
        if SECN[role] == "qa":
            return (0.7, 2)
        return (0.4, 3)
    if area in ("design", "eng"):
        if "build" not in boxes:
            return None
        if MAIN[role] == area:
            return (1.0, 0)
        if SECN[role] == area and role != "pm":
            return (0.7, 2)
        return None
    if area == "product":
        return (1.0, 0) if role == "pm" and "build" in boxes else None
    return None


class Person:
    def __init__(self, pid, role, sk, boxes=None, titiz=False):
        self.id, self.role, self.sk, self.titiz = pid, role, sk, titiz
        dflt = {"founder": ("build", "test"), "pm": ("build",), "des": ("build",), "dev": ("build",), "test": ("test",)}
        self.boxes = tuple(boxes) if boxes is not None else dflt[role]

    def rate(self, area):
        f = fit(self.role, self.boxes, area)
        if f is None:
            return 0.0
        y = Y(self.sk.get(area, 0))
        if self.role == "founder":
            y = max(1.0, y)
        r = BASE * y * f[0]
        return r * TITIZ_SPEED if self.titiz else r

    def catch(self):
        return C_REF * math.sqrt(Y(self.sk.get("qa", 0)))

    def build_q(self):
        q = 1.0 / math.sqrt(Y(self.sk.get("eng", 0)))
        return q * TITIZ_Q if self.titiz else q


class Team:
    def __init__(self, people):
        self.p = people
        self.n = len(people)
        self.rate = [[p.rate(a) for a in AREA] for p in people]
        self.key = []
        for i, p in enumerate(people):
            row = []
            for j, a in enumerate(AREA):
                f = fit(p.role, p.boxes, a)
                row.append((f[1], -self.rate[i][j], i) if f and self.rate[i][j] > 0 else None)
            self.key.append(row)
        self.cap = sum(max(r) for r in self.rate) * SPRINT_WEEKS
        self.pcap = [sum(r[i] for r in self.rate) * SPRINT_WEEKS for i in range(3)]
        pr = [(-p.rate("product"), i) for i, p in enumerate(people) if p.rate("product") > 0]
        pr.sort()
        self.pms = [(i, -r) for r, i in pr]
        ds = [(-self.rate[i][0], i) for i, p in enumerate(people) if p.role == "des" and "build" in p.boxes and self.rate[i][0] > 0]
        ds.sort()
        self.des = [(i, -r) for r, i in ds]
        self.morale = [0] * self.n


# ---------------------------------------------------------------- kart (6.4)
class Card:
    _n = 0

    def __init__(self, kind, line, tier=None, prof=None, bugs=0):
        Card._n += 1
        self.id = Card._n
        self.kind, self.line, self.tier, self.prof = kind, line, tier, prof
        if kind == "fix":
            self.size = 5 if bugs <= 4 else 10
            self.base_need = list(map(float, FIX_NEED[self.size]))
        else:
            self.size = SIZE[min(tier, 3)]
            self.base_need = list(map(float, NEED[(prof, min(tier, 3))]))
        self.need = list(self.base_need)
        self.prog = [0.0, 0.0, 0.0]
        self.prep = 0.0
        self.ready = 0.0
        self.kadro = [1, 1, 1]
        self.t0 = 0.0
        self.fixed = False
        self.log = {}
        self.done_at = None
        self.enter = None

    def clone(self):
        c = Card.__new__(Card)
        c.__dict__.update(self.__dict__)
        c.base_need, c.need, c.prog, c.kadro = list(self.base_need), list(self.need), list(self.prog), list(self.kadro)
        c.log = {k: list(v) for k, v in self.log.items()}
        return c

    def prep_need(self):
        return 0.0 if self.kind == "fix" else PREP_RATIO * self.size

    def phase(self):
        n, p = self.need, self.prog
        if n[0] - p[0] > EPS: return 0
        if n[1] - p[1] > EPS: return 1
        if n[2] - p[2] > EPS: return 2
        return 3

    def remaining(self):
        return sum(max(0.0, self.need[i] - self.prog[i]) for i in range(3))

    def fix_start(self):
        if not self.fixed and self.kind == "feature":
            self.fixed = True
            self.ready = min(1.0, self.prep / self.prep_need())
            self.need = [x * (1 - READY_CUT * self.ready) for x in self.base_need]
        self.kadro = [max(1, math.ceil(self.need[i] / SLICE - EPS)) for i in range(3)]
        self.t0 = self.need[2]


def expected(card, team):
    """(E, H, C_ham, en_iyi_yakalama). 6.7."""
    if card.kind not in KIND_H:
        return 0.0, 0.0, 0.0, 0.0
    eng = {k: v[1] for k, v in card.log.items() if v[1] > 0}
    tot = sum(eng.values())
    q = sum(w * team.p[k].build_q() for k, w in eng.items()) / tot if tot > 0 else 1.0
    h = H0 * card.size * KIND_H[card.kind] * (1 - READY_H * card.ready) * q
    cov = 0.0
    best = 0.0
    if card.t0 > EPS:
        for k, v in card.log.items():
            if v[2] > 0:
                cov += v[2] / card.t0 * team.p[k].catch()
                best = max(best, team.p[k].catch())
    return h * (1 - min(1.0, cov)), h, cov, best


# ---------------------------------------------------------------- hafta oynatma (6.6)
def run_week(team, cards, off=0.0, ahead=(), prepq=(), logit=True, watch=None):
    """Bir hafta zaman siralı oynatir. (bosta, uymayan_kisiler) doner.
    watch: kart; bu kart > EPS is alirsa erken doner (planlama kontrolu)."""
    n = team.n
    free = list(range(n))
    crews = {}
    opened = [0.0] * len(cards)
    busy = [0.0] * n
    unfit = set()
    keys, rate = team.key, team.rate
    t = 0.0
    wprog = sum(watch.prog) if watch is not None else 0.0
    for _ in range(200000):
        if free:
            for ci, c in enumerate(cards):
                ph = c.phase()
                if ph >= 3 or opened[ci] > t + 1e-12:
                    continue
                crew = crews.get(ci)
                if crew is None:
                    crew = crews[ci] = []
                kd = c.kadro[ph]
                while len(crew) < kd and free:
                    best, bk = None, None
                    for pi in free:
                        k = keys[pi][ph]
                        if k is not None and (bk is None or k < bk):
                            bk, best = k, pi
                    if best is None:
                        break
                    crew.append(best)
                    free.remove(best)
                    if bk[0] == 3:
                        unfit.add(best)
        nxt = 1.0
        for ci, crew in crews.items():
            if crew:
                c = cards[ci]
                ph = c.phase()
                r = 0.0
                for pi in crew:
                    r += rate[pi][ph]
                tt = t + (c.need[ph] - c.prog[ph]) / r
                if tt < nxt:
                    nxt = tt
        dt = nxt - t
        for ci, crew in crews.items():
            if not crew:
                continue
            c = cards[ci]
            ph = c.phase()
            for pi in crew:
                w = min(rate[pi][ph] * dt, c.need[ph] - c.prog[ph])
                c.prog[ph] += w
                if logit:
                    lg = c.log.get(pi)
                    if lg is None:
                        lg = c.log[pi] = [0.0, 0.0, 0.0]
                    lg[ph] += w
                busy[pi] += dt
            if c.need[ph] - c.prog[ph] <= EPS:
                c.prog[ph] = c.need[ph]
                free.extend(crew)
                crews[ci] = []
                opened[ci] = nxt
                if c.phase() == 3:
                    c.done_at = off + nxt
        t = nxt
        if watch is not None and sum(watch.prog) - wprog > EPS:
            return 0.0, unfit
        if t >= 1.0 - 1e-9:
            break
    left = [max(0.0, 1.0 - b) for b in busy]
    # hazirlik
    taken = set()
    for pi, pr in team.pms:
        for c in prepq:
            if left[pi] <= EPS:
                break
            need = c.prep_need()
            if c.id in taken or c.prep >= need - EPS:
                continue
            w = min(need - c.prep, left[pi] * pr)
            c.prep += w
            left[pi] -= w / pr
            taken.add(c.id)
    # onden tasarim
    for c in ahead:
        while c.need[0] - c.prog[0] > EPS:
            pick = None
            for pi, dr in team.des:
                if left[pi] > EPS:
                    pick = (pi, dr)
                    break
            if pick is None:
                break
            pi, dr = pick
            w = min(c.need[0] - c.prog[0], left[pi] * dr)
            c.prog[0] += w
            left[pi] -= w / dr
    return sum(left), unfit


def poisson(rng, lam):
    if lam <= 0:
        return 0
    u, k, p = rng.random(), 0, math.exp(-lam)
    s = p
    while u > s:
        k += 1
        p *= lam / k
        s += p
    return k


# ---------------------------------------------------------------- sim (6.5, 6.7)
class Sim:
    def __init__(self, people, seed, weeks=60, one_card=False, check_pred=True, lines=12):
        self.team = Team(people)
        self.rng = random.Random(seed)
        self.weeks, self.one_card, self.check_pred = weeks, one_card, check_pred
        self.lines = lines
        self.prof = {i: ("ui" if i < 4 else "logic" if i < 8 else "risk") for i in range(lines)}
        self.next_tier = {i: (2 if i in (0, 4, 8) else 1) for i in range(lines)}
        self.stream = [Card("feature", l, 1, self.prof[l]) for l in (0, 4, 8)]
        self.mvp_ids = {c.id for c in self.stream}
        self.rr = 0
        self.tier = [0] * lines
        self.bugs = [0] * lines
        self.live = False
        self.pending = []
        self.mvp_week = None
        self.carried = []
        self.done_ids = set()
        self.rec = []
        self.ready_log = []
        self.pred_maxdiff = 0.0
        self.catch_viol = 0
        self.cov_max_ratio = 0.0
        self.has_des = any(p.role == "des" and "build" in p.boxes for p in people)
        self.has_pm = any(p.role == "pm" and "build" in p.boxes for p in people)
        self.fix_deferred = 0
        self.stop_phase = [0, 0, 0]

    def gen(self):
        l = self.rr % self.lines
        self.rr += 1
        t = self.next_tier[l]
        self.next_tier[l] += 1
        return Card("feature", l, min(t, 3), self.prof[l])

    def peek(self, k):
        while len(self.stream) < k:
            self.stream.append(self.gen())
        return self.stream[:k]

    def take(self):
        self.peek(1)
        return self.stream.pop(0)

    def play_copy_gets_work(self, cards, trial):
        cc = [c.clone() for c in cards]
        tr = trial.clone()
        cc.append(tr)
        start = sum(tr.prog)
        for k in range(SPRINT_WEEKS):
            run_week(self.team, cc, k, logit=False, watch=tr)
            if sum(tr.prog) - start > EPS:
                return True
            if all(c.phase() == 3 for c in cc):
                break
        return sum(tr.prog) - start > EPS

    def plan(self):
        cards = []
        if self.live:
            have = {c.line for c in self.carried if c.kind == "fix"}
            due = sorted([(b, l) for l, b in enumerate(self.bugs) if b >= FIX_DUE_MIN and l not in have], key=lambda t: (-t[0], t[1]))
            fl = sum(c.remaining() for c in self.carried if c.kind == "fix")
            for b, l in due:
                c = Card("fix", l, bugs=b)
                c.fix_start()
                if FIX_SHARE_MAX > 0 and fl > EPS and fl + c.remaining() > FIX_SHARE_MAX * self.team.cap + EPS:
                    self.fix_deferred += 1
                    continue
                fl += c.remaining()
                cards.append(c)
        cards += self.carried
        self.carried = []
        for c in cards:
            c.fix_start()
        cap = self.team.cap
        fix_load = sum(c.remaining() for c in cards if c.kind == "fix")
        if self.one_card:
            if not cards:
                c = self.take()
                c.fix_start()
                self.ready_log.append(c.ready)
                cards.append(c)
            return cards, fix_load, cap
        for _ in range(1000):
            nxt = self.peek(1)[0]
            trial = nxt.clone()
            trial.fix_start()
            if cards:
                load = sum(c.remaining() for c in cards) + trial.remaining()
                if load > CEIL * cap:
                    break
                if PHASE_CEIL:
                    stop = None
                    for i in range(3):
                        tn = trial.need[i] - trial.prog[i]
                        if tn > EPS and sum(max(0.0, c.need[i] - c.prog[i]) for c in cards) + tn > PHASE_K * self.team.pcap[i]:
                            stop = i
                            break
                    if stop is not None:
                        self.stop_phase[stop] += 1
                        break
                if not self.play_copy_gets_work(cards, trial):
                    break
            c = self.take()
            c.fix_start()
            self.ready_log.append(c.ready)
            cards.append(c)
        return cards, fix_load, cap

    def run(self):
        w = 0
        team = self.team
        while w < self.weeks:
            start_w = w
            cards, fix_load, cap = self.plan()
            for c in cards:
                if c.enter is None:
                    c.enter = start_w
            nfeat = max(1, sum(1 for c in cards if c.kind == "feature"))
            ahead = self.peek(nfeat) if self.has_des else []
            prepq = self.peek(3 * nfeat) if self.has_pm else []
            pred = None
            if self.check_pred:
                pred = self.predict(cards, ahead, prepq)
            before = sum(sum(c.prog) for c in cards)
            idle = 0.0
            weeks_run = 0
            for k in range(SPRINT_WEEKS):
                i, unfit = run_week(team, cards, w, ahead, prepq, True)
                idle += i
                for pi in unfit:
                    team.morale[pi] += UNFIT_MORALE
                w += 1
                weeks_run += 1
                if self.live:
                    for _ in range(poisson(self.rng, FLOOR_WEEK * USAGE)):
                        lv = [l for l in range(self.lines) if self.tier[l] >= 1]
                        self.bugs[self.rng.choice(lv)] += 1
                if all(c.phase() == 3 for c in cards):
                    break
            pts = sum(sum(c.prog) for c in cards) - before
            done = [c for c in cards if c.phase() == 3]
            self.carried = [c for c in cards if c.phase() < 3]
            esc, delivered, ndone, lead = [], 0, 0, []
            for c in done:
                if c.kind == "fix":
                    self.bugs[c.line] = 0
                else:
                    self.tier[c.line] = max(self.tier[c.line], c.tier)
                e, h, cov, best = expected(c, team)
                if c.kind == "feature":
                    esc.append(e)
                    delivered += c.size
                    ndone += 1
                    lead.append(w - c.enter)
                capc = min(1.0, cov)
                if capc > best + 1e-9:
                    self.catch_viol += 1
                nn = poisson(self.rng, e)
                if self.live:
                    self.bugs[c.line] += nn
                else:
                    self.pending += [c.line] * nn
                self.done_ids.add(c.id)
            if pred is not None:
                self.compare_pred(cards, pred, w - weeks_run)
            if not self.live and self.mvp_ids <= self.done_ids:
                self.live = True
                self.mvp_week = w
                for l in self.pending:
                    self.bugs[l] += 1
                self.pending = []
            left = [0.0, 0.0, 0.0]
            for c in self.carried:
                ph = c.phase()
                left[ph] += c.need[ph] - c.prog[ph]
            self.rec.append({"start": start_w, "end": w, "weeks": weeks_run, "pts": pts, "cards": ndone,
                             "fixes": sum(1 for c in done if c.kind == "fix"), "share": fix_load / cap if cap else 0.0,
                             "open": sum(self.bugs), "esc": esc, "left": left, "idle": idle,
                             "ncards": len(cards), "delivered": delivered, "live": self.live, "lead": lead})
        return self

    # 6.13: tahmin = sonuc
    def predict(self, cards, ahead, prepq):
        mp = {}
        def cl(c):
            if c.id not in mp:
                mp[c.id] = c.clone()
            return mp[c.id]
        cc = [cl(c) for c in cards]
        aa = [cl(c) for c in ahead]
        pp = [cl(c) for c in prepq]
        mor = list(self.team.morale)
        for k in range(SPRINT_WEEKS):
            run_week(self.team, cc, k, aa, pp, True)
            if all(c.phase() == 3 for c in cc):
                break
        self.team.morale = mor
        return cc

    def compare_pred(self, cards, pred, start_w):
        for c, p in zip(cards, pred):
            d = max(abs(a - b) for a, b in zip(c.prog, p.prog))
            if (c.done_at is None) != (p.done_at is None):
                d = max(d, 1.0)
            elif c.done_at is not None:
                d = max(d, abs((c.done_at - start_w) - p.done_at))
                d = max(d, abs(expected(c, self.team)[0] - expected(p, self.team)[0]))
            self.pred_maxdiff = max(self.pred_maxdiff, d)


# ---------------------------------------------------------------- takim kurucu (6.10)
def founder():
    return Person("Kurucu", "founder", dict(FOUNDER_SK))


def mk(role, j, pid=None):
    m = DIST[j % 10]
    if role == "pm":
        sk = {"product": m, "design": max(0, m - 1), "eng": 0, "qa": 2}
    elif role == "des":
        sk = {"design": m, "product": max(0, m - 1), "eng": 0, "qa": 0}
    elif role == "dev":
        sk = {"eng": m, "qa": max(0, m - 1), "design": 0, "product": 0}
    else:
        sk = {"qa": m, "eng": max(0, m - 1), "design": 0, "product": 0}
    return Person(pid or "%s%d" % (role, j + 1), role, sk)


def group(pm=0, des=0, dev=0, test=0, dev_boxes=None, test_boxes=None, pm_boxes=None):
    ppl = []
    for r, k, bx in (("pm", pm, pm_boxes), ("des", des, None), ("dev", dev, dev_boxes), ("test", test, test_boxes)):
        for j in range(k):
            p = mk(r, j)
            if bx is not None:
                p.boxes = tuple(bx)
            ppl.append(p)
    return ppl


def spec_of(people):
    return [(p.id, p.role, dict(p.sk), p.boxes, p.titiz) for p in people]


def people_of(spec):
    return [Person(i, r, dict(s), b, t) for i, r, s, b, t in spec]


def S3():
    return [founder(),
            Person("Selin", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0}),
            Person("Ece", "des", {"design": 6, "product": 5, "eng": 0, "qa": 0}),
            Person("Deniz", "dev", {"eng": 7, "qa": 6, "design": 0, "product": 0}),
            Person("Mert", "dev", {"eng": 3, "qa": 2, "design": 0, "product": 0}),
            Person("Ayse", "test", {"qa": 5, "eng": 4, "design": 0, "product": 0})]


def S2():
    return [founder(),
            Person("Deniz", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}),
            Person("Ece", "des", {"design": 4, "product": 3, "eng": 0, "qa": 0})]


ADD = {  # marjinal eklenenler
    "+3* gelistirici": lambda: Person("EK", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}),
    "+3* testci": lambda: Person("EK", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0}),
    "+3* tasarimci": lambda: Person("EK", "des", {"design": 6, "product": 5, "eng": 0, "qa": 0}),
    "+3* PM": lambda: Person("EK", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0}),
    "+1* gelistirici": lambda: Person("EK", "dev", {"eng": 2, "qa": 1, "design": 0, "product": 0}),
}

BASES = {
    "S1": lambda: [founder()],
    "S2": S2,
    "S3": S3,
    "S4": lambda: [founder()] + group(2, 2, 5, 2),
    "S5": lambda: [founder()] + group(3, 4, 12, 5),
    "S6": lambda: [founder()] + group(6, 8, 25, 10),
}
SCEN = dict(BASES)
SCEN.update({
    "S7": lambda: [founder(), Person("G1", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), Person("G2", "dev", {"eng": 5, "qa": 4, "design": 0, "product": 0})]
    + [Person("T%d" % (i + 1), "test", {"qa": q, "eng": max(0, q - 1), "design": 0, "product": 0}) for i, q in enumerate([6, 5, 4, 8, 3])],
    "S7_1test": lambda: [founder(), Person("G1", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), Person("G2", "dev", {"eng": 5, "qa": 4, "design": 0, "product": 0}),
                         Person("T1", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0})],
    "S8": lambda: [founder()] + group(dev=10),
    "S8_ek_testkutulu_gel": lambda: [founder()] + group(dev=10) + [Person("EK", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}, ("build", "test"))],
    "S8_hepsi_testkutulu": lambda: [founder()] + group(dev=10, dev_boxes=("build", "test")),
    "S9a": lambda: [founder()] + group(test=8),
    "S9a_ek_gel": lambda: [founder()] + group(test=8) + [Person("EK", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0})],
    "S9b": lambda: [founder()] + group(test=8, test_boxes=("build", "test")),
    "S10": lambda: [founder()] + group(0, 6, 16, 7),
    "S11": lambda: [founder()] + group(2, 2, 20, 0),
    "S11_ek_testci": lambda: [founder()] + group(2, 2, 20, 0) + [Person("EK", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0})],
    "S11b": lambda: [founder()] + group(2, 2, 20, 0, dev_boxes=("build", "test")),
    "S3_PMsiz": lambda: [p for p in S3() if p.role != "pm"],
    "S3_PM_testkutulu": lambda: [Person(p.id, p.role, p.sk, ("build", "test") if p.role == "pm" else None) for p in S3()],
    "S4_PMsiz": lambda: [founder()] + group(0, 2, 5, 2),
    "S4_1PM": lambda: [founder()] + group(1, 2, 5, 2),
    "S5_1PM": lambda: [founder()] + group(1, 4, 12, 5),
})
# S12: S4 ekibi, tek kart kipi (secenekle)
ONE_CARD = {"S12"}
SCEN["S12"] = SCEN["S4"]
for b in ("S2", "S3", "S4", "S5", "S6"):
    for a in ADD:
        SCEN["%s %s" % (b, a)] = (lambda bb, aa: (lambda: BASES[bb]() + [ADD[aa]()]))(b, a)

# kisi ekleme egrisi: S6 orani, en buyuk eksik kurali
CURVE_MIX = {"pm": 6, "des": 8, "dev": 25, "test": 10}


def curve_roles(n):
    """n kisilik (kurucu dahil) takim icin rol listesi; her n bir oncekinin ustune bir kisi ekler."""
    tot = sum(CURVE_MIX.values())
    cnt = {r: 0 for r in CURVE_MIX}
    order = ["dev", "test", "des", "pm"]
    seq = []
    for k in range(1, 50):
        best = max(order, key=lambda r: (CURVE_MIX[r] / tot * k - cnt[r], -order.index(r)))
        cnt[best] += 1
        seq.append(best)
    return seq[:n - 1]


def curve_team(n):
    seq = curve_roles(n)
    idx = {r: 0 for r in CURVE_MIX}
    ppl = [founder()]
    for r in seq:
        ppl.append(mk(r, idx[r]))
        idx[r] += 1
    return ppl


for n in range(1, 51):
    SCEN["C%d" % n] = (lambda nn: (lambda: curve_team(nn)))(n)


# 6.12 madde 7: testci yildizi deneyi
for k in (2, 4, 6, 8, 10):
    SCEN["T3_%d" % k] = (lambda kk: (lambda: [Person(p.id, p.role, ({"qa": kk, "eng": max(0, kk - 1), "design": 0, "product": 0} if p.id == "Ayse" else p.sk)) for p in S3()]))(k)
    SCEN["T4_%d" % k] = (lambda kk: (lambda: [founder()] + group(2, 2, 5, 0) + [Person("test%d" % (j + 1), "test", {"qa": kk, "eng": max(0, kk - 1), "design": 0, "product": 0}) for j in range(2)]))(k)


# olcek: ayni karisim, butun testciler ayni yildizda
for nn in (12, 25, 50):
    for k in (2, 10):
        SCEN["TS%d_%d" % (nn, k)] = (lambda n_, kk: (lambda: [Person(p.id, p.role, ({"qa": kk, "eng": max(0, kk - 1), "design": 0, "product": 0} if p.role == "test" else p.sk)) for p in curve_team(n_)]))(nn, k)

# rol karisimi karsilastirmasi (n kisi, kurucu dahil)
MIXES = {
    "ref (PM12 Tas16 Gel51 Test20)": ({"pm": 6, "des": 8, "dev": 25, "test": 10}, {}),
    "PM'siz": ({"pm": 0, "des": 8, "dev": 29, "test": 12}, {}),
    "testcisiz, gelistirici Yapim+Test": ({"pm": 6, "des": 8, "dev": 35, "test": 0}, {"dev_boxes": ("build", "test")}),
    "testcisiz, kutu yok": ({"pm": 6, "des": 8, "dev": 35, "test": 0}, {}),
    "cok testci (%50)": ({"pm": 5, "des": 7, "dev": 12, "test": 25}, {}),
    "hepsi testci, Yapim+Test": ({"pm": 0, "des": 0, "dev": 0, "test": 49}, {"test_boxes": ("build", "test")}),
    "hepsi gelistirici, Yapim+Test": ({"pm": 0, "des": 0, "dev": 49, "test": 0}, {"dev_boxes": ("build", "test")}),
    "cok tasarimci (%40)": ({"pm": 6, "des": 20, "dev": 15, "test": 8}, {}),
    "cok PM (%30)": ({"pm": 15, "des": 6, "dev": 20, "test": 8}, {}),
    "esit dort rol": ({"pm": 12, "des": 12, "dev": 12, "test": 13}, {}),
}


def alloc(shares, m):
    tot = sum(shares.values())
    if tot == 0:
        return {r: 0 for r in shares}
    raw = {r: shares[r] / tot * m for r in shares}
    cnt = {r: int(raw[r]) for r in shares}
    rest = m - sum(cnt.values())
    for r in sorted(shares, key=lambda r: (-(raw[r] - cnt[r]), r)):
        if rest <= 0:
            break
        cnt[r] += 1
        rest -= 1
    return cnt


def mix_team(name, n):
    shares, kw = MIXES[name]
    c = alloc(shares, n - 1)
    return [founder()] + group(c["pm"], c["des"], c["dev"], c["test"], **kw)


MIX_N = (12, 25, 50)
for mname in MIXES:
    for nn in MIX_N:
        SCEN["M|%s|%d" % (mname, nn)] = (lambda a, b: (lambda: mix_team(a, b)))(mname, nn)


# ---------------------------------------------------------------- olcum (6.8)
def metrics(sim, name):
    r = sim.rec
    win = [x for x in r if x["end"] > 20]
    if not win:
        win = r
    wk = sum(x["weeks"] for x in win)
    n = sim.team.n
    deliv = sum(x["delivered"] for x in win) / wk
    esc = [e for x in win for e in x["esc"]]
    mvp = sim.mvp_week
    early = [x for x in r if mvp is not None and mvp <= x["start"] < mvp + 20]
    post = [x for x in r if mvp is not None and x["start"] >= mvp]
    def med(xs):
        return statistics.median(xs) if xs else None
    bs_flags = [x["share"] > 0.5 for x in post]
    consec = any(a and b for a, b in zip(bs_flags, bs_flags[1:]))
    lastw = [x for x in r if x["end"] > 40]
    # son 20 hafta acik hata egimi
    slope = None
    if len(lastw) >= 3:
        xs = [x["end"] for x in lastw]; ys = [x["open"] for x in lastw]
        mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
        den = sum((a - mx) ** 2 for a in xs)
        slope = sum((a - mx) * (b - my) for a, b in zip(xs, ys)) / den if den > 0 else 0.0
    left = [sum(x["left"][i] for x in win) / len(win) for i in range(3)]
    rl = sim.ready_log[len(sim.ready_log) // 3:]
    return {
        "n": n, "mvp": mvp, "deliv": deliv,
        "pts": sum(x["pts"] for x in win) / wk,
        "per_person": deliv / n,
        "cards_sprint": sum(x["cards"] for x in win) / len(win),
        "sprint_out": sum(x["delivered"] for x in win) / len(win),
        "sprint_weeks": wk / len(win),
        "esc_card": statistics.mean(esc) if esc else 0.0,
        "open_med": med([x["open"] for x in win]),
        "fix_late": med([x["share"] for x in win]),
        "fix_early": med([x["share"] for x in early]),
        "bs_late": (sum(1 for x in win if x["share"] > 0.5), len(win)),
        "bs_early": (sum(1 for x in early if x["share"] > 0.5), len(early)),
        "consec": consec, "slope": slope,
        "idle_w": sum(x["idle"] for x in win) / wk,
        "left": left,
        "ready": statistics.mean(rl) if rl else 0.0,
        "morale": list(sim.team.morale),
        "pred": sim.pred_maxdiff, "cviol": sim.catch_viol,
        "fixes": sum(x["fixes"] for x in win) / len(win),
        "wip": sum(x["ncards"] for x in win) / len(win),
        "lead": statistics.mean([l for x in win for l in x["lead"]]) if any(x["lead"] for x in win) else None,
        "open_max": max(x["open"] for x in win),
        "fix_deferred": sim.fix_deferred, "stop_phase": list(sim.stop_phase),
        "bs_post": [x["share"] > 0.5 for x in post],
    }


def run_one(task):
    name, seed = task
    ppl = SCEN[name]()
    sim = Sim(ppl, seed, one_card=(name in ONE_CARD), check_pred=not name.startswith("M|"))
    sim.run()
    m = metrics(sim, name)
    m["names"] = [p.id for p in ppl]
    m["role"] = [p.role for p in ppl]
    return name, seed, m


def run_many(names, seeds, workers=None):
    tasks = [(n, s) for n in names for s in seeds]
    out = {}
    with ProcessPoolExecutor(max_workers=workers or os.cpu_count()) as ex:
        for name, seed, m in ex.map(run_one, tasks, chunksize=1):
            out.setdefault(name, {})[seed] = m
    return out


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "quick"
    if cmd == "quick":
        t = time.time()
        for nm in sys.argv[2:] or ["S1", "S3"]:
            _, _, m = run_one((nm, 1))
            print(nm, {k: v for k, v in m.items() if k not in ("names", "role", "morale")}, "%.1fs" % (time.time() - t))
            t = time.time()
    elif cmd == "exec":
        exec(open(sys.argv[2], encoding="utf-8").read(), globals())
