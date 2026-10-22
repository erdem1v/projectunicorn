# Faz D ekip modeli v3 on hesap prototipi. Temel: ../dsim/dsim.py (D_MODEL_v2 6).
# v3 farklari: kurucu tabani Y>=0.86, yakalama 0.57*sqrt(Y) ve kendi kartini test eden x0.6,
# testte bulunan hata ayni sprintte Duzeltme alt asamasinda duzeltilir, bilinen hata ve gonder/beklet,
# duzeltme karti 2 puan/hata (en az 5), PM hazirlik egrisi ve yildiza bagli fayda.
# Calistirma: python -I dsim3.py exec <dosya>
import math, random, statistics, sys, os, json, time
from concurrent.futures import ProcessPoolExecutor
sys.stdout.reconfigure(encoding="utf-8")

E = os.environ.get
BASE = 10.0
SIZE = {1: 15, 2: 25, 3: 40}
NEED = {
    ("ui", 1): [5, 7, 3], ("ui", 2): [9, 11, 5], ("ui", 3): [14, 18, 8],
    ("logic", 1): [2, 10, 3], ("logic", 2): [4, 16, 5], ("logic", 3): [6, 26, 8],
    ("risk", 1): [2, 8, 5], ("risk", 2): [3, 13, 9], ("risk", 3): [4, 22, 14],
}
SLICE = 8.0
H0 = float(E("D3_H0", "0.04"))
QR = float(E("D3_QR", "0.3"))
FCLASS = E("D3_FCLASS", "1") == "1"
PMBEST = E("D3_PMBEST", "1") == "1"
NOFIX = E("D3_NOFIX", "0") == "1"
PMOWN = E("D3_PMOWN", "0") == "1"
KIND_H = {"feature": 1.0, "fix": 0.3}
C_REF = float(E("D3_CREF", "0.57"))
SELF_TEST = float(E("D3_SELF", "0.6"))
FOUNDER_FLOOR = float(E("D3_FFLOOR", "0.86"))
FIX_LIGHT = float(E("D3_FIXL", "1.3"))
FIX_HEAVY = float(E("D3_FIXH", "5.3"))
HEAVY_P = float(E("D3_HEAVYP", "0.18"))
FIX_PER_BUG = float(E("D3_FIXPB", "2.0"))
FIX_MIN = 5.0
PREP_RATIO = 0.20
PREP_MODE = E("D3_PREP", "v3")  # v3 | v2
POLICY = E("D3_POLICY", "hold")  # hold | ship | ask
ASK_ANS = E("D3_ASKANS", "ship")
TITIZ_SPEED, TITIZ_Q = 0.85, 0.5
CEIL = 1.25
PHASE_K = 2.0
FIX_SHARE_MAX = 0.5
SPRINT_WEEKS = int(E("D3_SW", "2"))
FIX_DUE_MIN = 2
FLOOR_WEEK, USAGE = 0.7, 1.5
UNFIT_MORALE = -2
EPS = 1e-6
AREA = ["design", "eng", "qa"]
ROW = [0, 1, 2, 1]  # asama -> alan satiri (Duzeltme gelistirmedir)
MAIN = {"pm": "product", "des": "design", "dev": "eng", "test": "qa"}
SECN = {"pm": "design", "des": "product", "dev": "qa", "test": "eng"}
DIST = [6, 4, 8, 5, 3, 6, 7, 4, 5, 6]
FOUNDER_SK = dict(zip(("product", "design", "eng", "qa"), map(int, E("D3_FSK", "4,0,4,0").split(","))))


def Y(s):
    return 0.5 + 0.05 * s + 0.01 * s * s


def prep_rate(s):
    if PREP_MODE == "v2":
        return BASE * Y(s)
    return 15.0 + 10.0 * math.sqrt(max(0.0, s - 2) / 8.0)


def prep_bonus(s):
    if PREP_MODE == "v2":
        return 0.25  # 1/(1+0.25) = 0.8 -> v2'nin %20 kesintisi
    return min(0.30, max(0.05, 0.10 + 0.025 * (s - 2)))


def prep_hcut(s):
    if PREP_MODE == "v2":
        return 0.25
    return min(0.40, max(0.05, 0.10 + 0.0375 * (s - 2)))


def fit(role, boxes, area):
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
        if area == "product":
            r = prep_rate(self.sk.get("product", 0))
        else:
            y = Y(self.sk.get(area, 0))
            if self.role == "founder":
                y = max(FOUNDER_FLOOR, y)
            r = BASE * y * f[0]
        return r * TITIZ_SPEED if self.titiz else r

    def catch(self):
        return min(1.0, C_REF * math.sqrt(Y(self.sk.get("qa", 0))))

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
                cls = f[1] if f else None
                if f and p.role == "founder" and FCLASS and p.sk.get(a, 0) >= 5 and p.sk.get(a, 0) == max(p.sk.get(x, 0) for x in AREA):
                    cls = 0
                row.append((cls, -self.rate[i][j], i) if f and self.rate[i][j] > 0 else None)
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
        self.pwork = [0.0] * self.n


class Card:
    _n = 0

    def __init__(self, kind, line, tier=None, prof=None, bugs=0):
        Card._n += 1
        self.id = Card._n
        self.kind, self.line, self.tier, self.prof = kind, line, tier, prof
        if kind == "fix":
            self.size = max(FIX_MIN, FIX_PER_BUG * bugs)
            self.base_need = [0.0, 0.7 * self.size, 0.3 * self.size, 0.0]
        else:
            self.size = SIZE[min(tier, 3)]
            self.base_need = list(map(float, NEED[(prof, min(tier, 3))])) + [0.0]
        self.need = list(self.base_need)
        self.prog = [0.0, 0.0, 0.0, 0.0]
        self.prep = 0.0
        self.prepb = 0.0
        self.preph = 0.0
        self.ready = 0.0
        self.hcut = 0.0
        self.kadro = [1, 1, 1, 1]
        self.t0 = 0.0
        self.fixed = False
        self.log = {}
        self.done_at = None
        self.enter = None
        self.tested = False
        self.nbugs = 0
        self.found = 0
        self.costs = []
        self.H = 0.0
        self.C = 0.0

    def clone(self):
        c = Card.__new__(Card)
        c.__dict__.update(self.__dict__)
        c.base_need, c.need, c.prog, c.kadro = list(self.base_need), list(self.need), list(self.prog), list(self.kadro)
        c.log = {k: list(v) for k, v in self.log.items()}
        c.costs = list(self.costs)
        return c

    def prep_need(self):
        return 0.0 if self.kind == "fix" else PREP_RATIO * self.size

    def phase(self):
        n, p = self.need, self.prog
        for i in range(3):
            if n[i] - p[i] > EPS:
                return i
        if not self.tested:
            return 2  # test bitti ama sonucu islenmedi (olmaz; guvenlik)
        if n[3] - p[3] > EPS:
            return 3
        return 4

    def remaining(self):
        return sum(max(0.0, self.need[i] - self.prog[i]) for i in range(4))

    def row_left(self):
        out = [0.0, 0.0, 0.0]
        for i in range(4):
            out[ROW[i]] += max(0.0, self.need[i] - self.prog[i])
        return out

    def fix_start(self):
        if not self.fixed and self.kind == "feature":
            self.fixed = True
            pn = self.prep_need()
            self.ready = min(1.0, self.prep / pn)
            sb = self.prepb / pn
            self.hcut = self.preph / pn
            self.need = [x / (1 + sb) for x in self.base_need[:3]] + [0.0]
        self.kadro = [max(1, math.ceil(self.need[i] / SLICE - EPS)) for i in range(4)]
        self.t0 = self.need[2]

    def known(self):
        """Duzeltilmemis bulunan hata sayisi (sira: bulunus sirasi)."""
        done = self.prog[3]
        m = 0
        acc = 0.0
        for c in self.costs:
            acc += c
            if acc <= done + EPS:
                m += 1
        return self.found - m, sum(1 for i, c in enumerate(self.costs) if c > FIX_LIGHT + EPS and i >= m)


def build_quality(card, team):
    eng = {k: v[1] for k, v in card.log.items() if v[1] > 0}
    tot = sum(eng.values())
    return sum(w * team.p[k].build_q() for k, w in eng.items()) / tot if tot > 0 else 1.0


def catch_of(card, team):
    if card.t0 <= EPS:
        return 0.0
    cov = 0.0
    for k, v in card.log.items():
        if v[2] > 0:
            c = team.p[k].catch()
            if v[1] > 0:  # bu karti gelistiren kisi kendi kartini test ediyor
                c *= SELF_TEST
            cov += v[2] / card.t0 * c
    return min(1.0, cov)


def poisinv(u, lam):
    if lam <= 0:
        return 0
    k, p = 0, math.exp(-lam)
    s = p
    while u > s and k < 1000:
        k += 1
        p *= lam / k
        s += p
    return k


def on_test_done(card, team, seed):
    """Test asamasi bittigi an: hata sayisi, bulunan, duzeltme isi. Tohum kart kimliginden; plan ve kapanis ayni."""
    card.tested = True
    if card.kind not in KIND_H:
        return
    q = build_quality(card, team)
    card.H = H0 * card.size * KIND_H[card.kind] * (1 - card.hcut) * q
    card.C = catch_of(card, team)
    r = random.Random("%s:%d" % (seed, card.id))
    card.nbugs = poisinv(r.random(), card.H)
    costs = []
    for _ in range(card.nbugs):
        u, v = r.random(), r.random()
        if u < card.C:
            costs.append(FIX_HEAVY if v < HEAVY_P else FIX_LIGHT)
    card.found = len(costs)
    card.costs = costs
    card.need[3] = sum(costs)
    card.kadro[3] = max(1, math.ceil(card.need[3] / SLICE - EPS))


def run_week(team, cards, seed, off=0.0, ahead=(), prepq=(), logit=True, watch=None):
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
                if ph >= 4 or opened[ci] > t + 1e-12:
                    continue
                crew = crews.get(ci)
                if crew is None:
                    crew = crews[ci] = []
                kd = c.kadro[ph]
                rw = ROW[ph]
                while len(crew) < kd and free:
                    best, bk = None, None
                    for pi in free:
                        k = keys[pi][rw]
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
                    r += rate[pi][ROW[ph]]
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
                w = min(rate[pi][ROW[ph]] * dt, c.need[ph] - c.prog[ph])
                c.prog[ph] += w
                if logit:
                    lg = c.log.get(pi)
                    if lg is None:
                        lg = c.log[pi] = [0.0, 0.0, 0.0, 0.0]
                    lg[ph] += w
                    team.pwork[pi] += w
                busy[pi] += dt
            if c.need[ph] - c.prog[ph] <= EPS:
                c.prog[ph] = c.need[ph]
                free.extend(crew)
                crews[ci] = []
                opened[ci] = nxt
                if ph == 2:
                    on_test_done(c, team, seed)
                if c.phase() == 4:
                    c.done_at = off + nxt
        t = nxt
        if watch is not None and sum(watch.prog) - wprog > EPS:
            return 0.0, unfit
        if t >= 1.0 - 1e-9:
            break
    left = [max(0.0, 1.0 - b) for b in busy]
    taken = set()
    sbest = max((team.p[pi].sk.get("product", 0) for pi, _ in team.pms), default=0)
    for pi, pr in team.pms:
        s = sbest if PMBEST else team.p[pi].sk.get("product", 0)
        for c in prepq:
            if left[pi] <= EPS:
                break
            need = c.prep_need()
            if c.id in taken or c.prep >= need - EPS:
                continue
            w = min(need - c.prep, left[pi] * pr)
            c.prep += w
            c.prepb += w * prep_bonus(s)
            c.preph += w * prep_hcut(s)
            left[pi] -= w / pr
            taken.add(c.id)
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


class Sim:
    def __init__(self, people, seed, weeks=60, one_card=False, check_pred=True, lines=12, policy=None, hires=None):
        Card._n = 0
        self.seed = seed
        self.people_all = people
        self.hires = sorted(hires or [], key=lambda h: h[0])  # [(hafta, Person)]
        self.team = Team(people)
        self.rng = random.Random(seed)
        self.weeks, self.one_card, self.check_pred = weeks, one_card, check_pred
        self.policy = policy or POLICY
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
        self.fix_deferred = 0
        self.stop_phase = [0, 0, 0]
        self.held = []

    def has_des(self):
        return any(p.role == "des" and "build" in p.boxes for p in self.team.p)

    def has_pm(self):
        return any(p.role == "pm" and "build" in p.boxes for p in self.team.p)

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
        pw = list(self.team.pwork)
        got = False
        for k in range(SPRINT_WEEKS):
            run_week(self.team, cc, self.seed, k, logit=True, watch=tr)
            if sum(tr.prog) - start > EPS:
                got = True
                break
            if all(c.phase() == 4 for c in cc):
                break
        self.team.pwork = pw
        return got or sum(tr.prog) - start > EPS

    def plan(self):
        cards = []
        if self.live and not NOFIX:
            have = {c.line for c in self.carried if c.kind == "fix"}
            due = sorted([(b, l) for l, b in enumerate(self.bugs) if b >= FIX_DUE_MIN and l not in have], key=lambda t: (-t[0], t[1]))
            fl = sum(c.remaining() for c in self.carried if c.kind == "fix")
            for b, l in due:
                c = Card("fix", l, bugs=b)
                c.fix_start()
                c.bugs_at = b
                if fl > EPS and fl + c.remaining() > FIX_SHARE_MAX * self.team.cap + EPS:
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
                stop = None
                tl = trial.row_left()
                cl = [0.0, 0.0, 0.0]
                for c in cards:
                    for i, v in enumerate(c.row_left()):
                        cl[i] += v
                for i in range(3):
                    if tl[i] > EPS and cl[i] + tl[i] > PHASE_K * self.team.pcap[i]:
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

    def release(self, c, extra_known=0):
        """Kart yayina cikar: bulunamayan hata ve gonderilen bilinen hata hattina."""
        nn = (c.nbugs - c.found) + extra_known
        if c.kind == "fix":
            self.bugs[c.line] = 0
        else:
            self.tier[c.line] = max(self.tier[c.line], c.tier)
        if self.live:
            self.bugs[c.line] += nn
        else:
            self.pending += [c.line] * nn
        self.done_ids.add(c.id)
        return nn

    def apply_hires(self, w):
        changed = False
        while self.hires and self.hires[0][0] <= w:
            _, p = self.hires.pop(0)
            self.people_all = self.people_all + [p]
            changed = True
        if changed:
            mor, pw = self.team.morale, self.team.pwork
            self.team = Team(self.people_all)
            self.team.morale[:len(mor)] = mor
            self.team.pwork[:len(pw)] = pw

    def run(self):
        w = 0
        while w < self.weeks:
            self.apply_hires(w)
            team = self.team
            start_w = w
            cards, fix_load, cap = self.plan()
            for c in cards:
                if c.enter is None:
                    c.enter = start_w
            nfeat = max(1, sum(1 for c in cards if c.kind == "feature"))
            ahead = self.peek(nfeat) if self.has_des() else []
            prepq = self.peek(3 * nfeat) if self.has_pm() else []
            pred = self.predict(cards, ahead, prepq) if self.check_pred else None
            before = sum(sum(c.prog) for c in cards)
            idle = 0.0
            weeks_run = 0
            pw0 = list(team.pwork)
            fixw0 = sum(c.prog[3] for c in cards)
            for k in range(SPRINT_WEEKS):
                i, unfit = run_week(team, cards, self.seed, w, ahead, prepq, True)
                idle += i
                for pi in unfit:
                    team.morale[pi] += UNFIT_MORALE
                w += 1
                weeks_run += 1
                if self.live:
                    for _ in range(poisson(self.rng, FLOOR_WEEK * USAGE)):
                        lv = [l for l in range(self.lines) if self.tier[l] >= 1]
                        self.bugs[self.rng.choice(lv)] += 1
                if all(c.phase() == 4 for c in cards):
                    break
            pts = sum(sum(c.prog) for c in cards) - before
            fixwork = sum(c.prog[3] for c in cards) - fixw0
            if pred is not None:
                self.compare_pred(cards, pred, w - weeks_run)
            done = [c for c in cards if c.phase() == 4]
            fixing = [c for c in cards if c.phase() == 3]
            found_sprint = sum(c.found for c in cards if c.tested and getattr(c, "_counted", False) is False)
            for c in cards:
                if c.tested:
                    c._counted = True
            K = sum(c.known()[0] for c in fixing)
            Kh = sum(c.known()[1] for c in fixing)
            ship = []
            ask = False
            if fixing:
                if self.policy == "ship":
                    ship = fixing
                elif self.policy == "ask":
                    ask = K >= max(1, math.ceil(QR * found_sprint - EPS))
                    if ask:
                        if ASK_ANS == "ship":
                            ship = fixing
                        elif ASK_ANS == "heavy":
                            ship = [c for c in fixing if c.known()[1] == 0]
            esc, delivered, ndone, lead, shipped_k = [], 0, 0, [], 0
            for c in done + ship:
                kk = c.known()[0] if c in ship else 0
                nn = self.release(c, kk)
                shipped_k += kk
                if c.kind == "feature":
                    esc.append(nn)
                    delivered += c.size
                    ndone += 1
                    lead.append(w - c.enter)
            self.carried = [c for c in cards if c.phase() < 4 and c not in ship]
            if not self.live and self.mvp_ids <= self.done_ids:
                self.live = True
                self.mvp_week = w
                for l in self.pending:
                    self.bugs[l] += 1
                self.pending = []
            left = [0.0, 0.0, 0.0]
            for c in self.carried:
                for i, v in enumerate(c.row_left()):
                    left[i] += v
            fpw = team.pwork[0] - pw0[0]
            self.rec.append({"start": start_w, "end": w, "weeks": weeks_run, "pts": pts, "cards": ndone,
                             "fixes": sum(1 for c in done if c.kind == "fix"), "share": fix_load / cap if cap else 0.0,
                             "open": sum(self.bugs), "esc": esc, "openw": w, "left": left, "idle": idle,
                             "ncards": len(cards), "delivered": delivered, "live": self.live, "lead": lead,
                             "found": found_sprint, "K": K, "Kh": Kh, "nfix": len(fixing), "shipped_k": shipped_k,
                             "fixwork": fixwork, "cap": cap, "founder_pts": fpw, "n": team.n,
                             "Fall": found_sprint, "ask": ask,
                             "held": sum(c.size for c in fixing if c.kind == "feature")})
        return self

    def predict(self, cards, ahead, prepq):
        mp = {}
        def cl(c):
            if c.id not in mp:
                mp[c.id] = c.clone()
            return mp[c.id]
        cc = [cl(c) for c in cards]
        aa = [cl(c) for c in ahead]
        pp = [cl(c) for c in prepq]
        mor, pw = list(self.team.morale), list(self.team.pwork)
        for k in range(SPRINT_WEEKS):
            run_week(self.team, cc, self.seed, k, aa, pp, True)
            if all(c.phase() == 4 for c in cc):
                break
        self.team.morale, self.team.pwork = mor, pw
        return cc

    def compare_pred(self, cards, pred, start_w):
        for c, p in zip(cards, pred):
            d = max(abs(a - b) for a, b in zip(c.prog, p.prog))
            if (c.done_at is None) != (p.done_at is None):
                d = max(d, 1.0)
            elif c.done_at is not None:
                d = max(d, abs((c.done_at - start_w) - p.done_at))
            d = max(d, abs(c.found - p.found), abs(c.nbugs - p.nbugs))
            self.pred_maxdiff = max(self.pred_maxdiff, d)


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


def P(role, s):
    if role == "dev":
        return Person("EK", "dev", {"eng": s, "qa": max(0, s - 1), "design": 0, "product": 0})
    if role == "test":
        return Person("EK", "test", {"qa": s, "eng": max(0, s - 1), "design": 0, "product": 0})
    if role == "des":
        return Person("EK", "des", {"design": s, "product": max(0, s - 1), "eng": 0, "qa": 0})
    return Person("EK", "pm", {"product": s, "design": max(0, s - 1), "qa": 2, "eng": 0})


ADD = {
    "+3* gelistirici": lambda: P("dev", 6),
    "+3* testci": lambda: P("test", 6),
    "+3* tasarimci": lambda: P("des", 6),
    "+3* PM": lambda: P("pm", 6),
    "+1* gelistirici": lambda: P("dev", 2),
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
    "S7": lambda: [founder(), P("dev", 6), P("dev", 5)] + [Person("T%d" % (i + 1), "test", {"qa": q, "eng": max(0, q - 1), "design": 0, "product": 0}) for i, q in enumerate([6, 5, 4, 8, 3])],
    "S7_1test": lambda: [founder(), P("dev", 6), P("dev", 5), P("test", 6)],
    "S8": lambda: [founder()] + group(dev=10),
    "S8_hepsi_testkutulu": lambda: [founder()] + group(dev=10, dev_boxes=("build", "test")),
    "S9a": lambda: [founder()] + group(test=8),
    "S9b": lambda: [founder()] + group(test=8, test_boxes=("build", "test")),
    "S10": lambda: [founder()] + group(0, 6, 16, 7),
    "S11": lambda: [founder()] + group(2, 2, 20, 0),
    "S11b": lambda: [founder()] + group(2, 2, 20, 0, dev_boxes=("build", "test")),
    "S3_PMsiz": lambda: [p for p in S3() if p.role != "pm"],
    "S4_PMsiz": lambda: [founder()] + group(0, 2, 5, 2),
    "S4_1PM": lambda: [founder()] + group(1, 2, 5, 2),
    "S5_1PM": lambda: [founder()] + group(1, 4, 12, 5),
})
ONE_CARD = {"S12"}
SCEN["S12"] = SCEN["S4"]
for b in ("S2", "S3", "S4", "S5", "S6"):
    for a in ADD:
        SCEN["%s %s" % (b, a)] = (lambda bb, aa: (lambda: BASES[bb]() + [ADD[aa]()]))(b, a)

# testci yildizi: S3 ve S4 benzeri ekipte butun testciler ayni puanda; testcisiz (gelistiriciler Test kutulu)
for k in (2, 6, 10):
    SCEN["T3_%d" % k] = (lambda kk: (lambda: [Person(p.id, p.role, ({"qa": kk, "eng": max(0, kk - 1), "design": 0, "product": 0} if p.id == "Ayse" else p.sk)) for p in S3()]))(k)
    SCEN["T4_%d" % k] = (lambda kk: (lambda: [founder()] + group(2, 2, 5, 0) + [P("test", kk), P("test", kk)]))(k)
    SCEN["T5_%d" % k] = (lambda kk: (lambda: [founder()] + group(3, 4, 12, 0) + [P("test", kk) for _ in range(5)]))(k)
SCEN["T3_yok"] = lambda: [Person(p.id, p.role, p.sk, ("build", "test") if p.role == "dev" else None) for p in S3() if p.role != "test"]
SCEN["T4_yok"] = lambda: [founder()] + group(2, 2, 5, 0, dev_boxes=("build", "test"))
SCEN["T5_yok"] = lambda: [founder()] + group(3, 4, 12, 0, dev_boxes=("build", "test"))
SCEN["T3_yok_gel"] = lambda: [Person(p.id, p.role, p.sk, ("build", "test") if p.role == "dev" else None) for p in S3() if p.role != "test"] + [Person("EKG", "dev", {"eng": 5, "qa": 4, "design": 0, "product": 0}, ("build", "test"))]
SCEN["T4_yok_gel"] = lambda: [founder()] + group(2, 2, 7, 0, dev_boxes=("build", "test"))
SCEN["T5_yok_gel"] = lambda: [founder()] + group(3, 4, 17, 0, dev_boxes=("build", "test"))

# PM yildizi: S3 ve S4'te PM 1* / 3* / 5*
for k in (2, 6, 10):
    SCEN["PM3_%d" % k] = (lambda kk: (lambda: [Person(p.id, p.role, ({"product": kk, "design": max(0, kk - 1), "qa": 2, "eng": 0} if p.role == "pm" else p.sk)) for p in S3()]))(k)
    SCEN["PM4_%d" % k] = (lambda kk: (lambda: [founder()] + [P("pm", kk)] + group(0, 2, 5, 2)))(k)
    SCEN["PM5_%d" % k] = (lambda kk: (lambda: [founder()] + [P("pm", kk)] + group(0, 4, 12, 5)))(k)

# kurucu buyume: tek -> +1 -> +2 -> +3 (siralar)
GROW = {
    "g_dev": [("dev", 5), ("des", 5), ("test", 5)],
    "g_dev1": [("dev", 2), ("des", 2), ("test", 2)],
    "g_des": [("des", 5), ("dev", 5), ("test", 5)],
    "g_test": [("test", 5), ("dev", 5), ("des", 5)],
    "g_pm": [("pm", 5), ("dev", 5), ("des", 5)],
    "g_dev3": [("dev", 6), ("dev", 6), ("dev", 6)],
}
for g, seq in GROW.items():
    for k in range(4):
        SCEN["%s_%d" % (g, k)] = (lambda ss, kk: (lambda: [founder()] + [P(r, s) for r, s in ss[:kk]]))(seq, k)

CURVE_MIX = {"pm": 6, "des": 8, "dev": 25, "test": 10}


def curve_roles(n):
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


def metrics(sim, name):
    r = sim.rec
    win = [x for x in r if x["end"] > 20] or r
    wk = sum(x["weeks"] for x in win)
    n = sim.team.n
    deliv = sum(x["delivered"] for x in win) / wk
    esc = [e for x in win for e in x["esc"]]
    mvp = sim.mvp_week
    early = [x for x in r if mvp is not None and mvp <= x["start"] < mvp + 20]
    post = [x for x in r if mvp is not None and x["start"] >= mvp]
    med = lambda xs: statistics.median(xs) if xs else None
    bs_flags = [x["share"] > 0.5 for x in post]
    consec = any(a and b for a, b in zip(bs_flags, bs_flags[1:]))
    lastw = [x for x in r if x["end"] > 40]
    slope = None
    if len(lastw) >= 3:
        xs = [x["end"] for x in lastw]; ys = [x["open"] for x in lastw]
        mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
        den = sum((a - mx) ** 2 for a in xs)
        slope = sum((a - mx) * (b - my) for a, b in zip(xs, ys)) / den if den > 0 else 0.0
    rl = sim.ready_log[len(sim.ready_log) // 3:]
    totdel = sum(x["delivered"] for x in win)
    return {
        "n": n, "mvp": mvp, "deliv": deliv,
        "per_person": deliv / n,
        "cards_sprint": sum(x["cards"] for x in win) / len(win),
        "esc_card": statistics.mean(esc) if esc else 0.0,
        "esc100": 100.0 * sum(esc) / totdel if totdel else 0.0,
        "open_med": med([x["open"] for x in win]),
        "open_max": max(x["open"] for x in win),
        "fix_late": med([x["share"] for x in win]),
        "fix_early": med([x["share"] for x in early]),
        "bs_late": (sum(1 for x in win if x["share"] > 0.5), len(win)),
        "consec": consec, "slope": slope,
        "idle_w": sum(x["idle"] for x in win) / wk,
        "ready": statistics.mean(rl) if rl else 0.0,
        "pred": sim.pred_maxdiff,
        "found_sp": sum(x["found"] for x in win) / len(win),
        "K_sp": sum(x["K"] for x in win) / len(win),
        "q_any": sum(1 for x in win if x["K"] >= 1) / len(win),
        "q_ratio": sum(1 for x in win if x["K"] >= max(2, 0.25 * x["found"])) / len(win),
        "q_heavy": sum(1 for x in win if x["Kh"] >= 1) / len(win),
        "q_mix": sum(1 for x in win if x["Kh"] >= 1 or x["K"] >= max(3, 0.25 * x["found"])) / len(win),
        "q_s10": sum(1 for x in win if x["held"] >= 0.10 * x["cap"]) / len(win),
        "q_s15": sum(1 for x in win if x["held"] >= 0.15 * x["cap"]) / len(win),
        "q_s25": sum(1 for x in win if x["held"] >= 0.25 * x["cap"]) / len(win),
        "q_qr": sum(1 for x in win if x["K"] >= max(1, math.ceil(QR * x["found"] - EPS))) / len(win),
        "asked": sum(1 for x in win if x["ask"]) / len(win),
        "infix": sum(x["fixwork"] for x in win) / sum(x["cap"] for x in win),
        "founder_w": sum(x["founder_pts"] for x in win) / wk,
        "wip": sum(x["ncards"] for x in win) / len(win),
        "lead": statistics.mean([l for x in win for l in x["lead"]]) if any(x["lead"] for x in win) else None,
        "nfix_sp": sum(x["nfix"] for x in win) / len(win),
        "bs_post": [x["share"] > 0.5 for x in post],
        "shipped_k": sum(x["shipped_k"] for x in win) / len(win),
        "bs_all": (sum(1 for x in post if x["share"] > 0.5), len(post)),
    }


def run_one(task):
    name, seed = task[0], task[1]
    pol = task[2] if len(task) > 2 else None
    ppl = SCEN[name]()
    sim = Sim(ppl, seed, one_card=(name in ONE_CARD), policy=pol)
    sim.run()
    m = metrics(sim, name)
    return name, seed, pol, m


def run_many(names, seeds, pol=None, workers=None):
    tasks = [(n, s, pol) for n in names for s in seeds]
    out = {}
    with ProcessPoolExecutor(max_workers=workers or os.cpu_count()) as ex:
        for name, seed, p, m in ex.map(run_one, tasks, chunksize=1):
            out.setdefault(name, {})[seed] = m
    return out


def run_rec(task):
    name, seed = task[0], task[1]
    pol = task[2] if len(task) > 2 else None
    sim = Sim(SCEN[name](), seed, one_card=(name in ONE_CARD), policy=pol)
    sim.run()
    return name, seed, [x for x in sim.rec if x["end"] > 20], metrics(sim, name)


def rec_many(names, seeds, pol=None):
    R, M = {}, {}
    with ProcessPoolExecutor() as ex:
        for n, sd, r, m in ex.map(run_rec, [(n, s, pol) for n in names for s in seeds], chunksize=1):
            R.setdefault(n, []).extend(r)
            M.setdefault(n, {})[sd] = m
    return R, M


def medof(res, name, key):
    vals = [m[key] for m in res[name].values() if m[key] is not None]
    return statistics.median(vals) if vals else None


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "quick"
    if cmd == "quick":
        for nm in sys.argv[2:] or ["S1", "S3"]:
            t = time.time()
            _, _, _, m = run_one((nm, 1))
            print(nm, {k: (round(v, 3) if isinstance(v, float) else v) for k, v in m.items() if k not in ("bs_post",)}, "%.1fs" % (time.time() - t))
    elif cmd == "exec":
        exec(open(sys.argv[2], encoding="utf-8").read(), globals())
