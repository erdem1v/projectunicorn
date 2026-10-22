# Faz D ekip modeli v3 simulasyonu. D_MODEL_v3.md "6. Simulasyon tanimi"nin uygulamasi.
# Temel: ../dsim/dsim.py (v2, degistirilmedi; kopyasi dsim_v2_base.py). Paragraf numaralari yorumlarda: "§6.x" = D_MODEL_v3.md,
# "§3.x" model kurali, "SD" = SPRINT_DUZENI.md. Prototip dmodel3/dsim3.py yalniz okundu; kural ayrimlarinda §6 uyuldu.
# Calistirma:  python -I dsim3.py <komut>      (komutlar dosyanin sonunda; kosu betikleri "exec" ile)
import math, random, statistics, sys, os, json, time
from concurrent.futures import ProcessPoolExecutor
sys.stdout.reconfigure(encoding="utf-8")


def _c(name, default):
    """Oneri kosulari icin ortam degiskeni ("D3_<AD>"); varsayilan belgedeki deger."""
    v = os.environ.get("D3_" + name)
    return type(default)(v) if v is not None else default


# ---------------------------------------------------------------- sabitler (§6.2)
BASE = 10.0                                   # §3.1 puan tabani
SIZE = {1: 15, 2: 25, 3: 40}                  # §6.2 SIZE
NEED = {                                      # §3.2 kart ihtiyaci (Tasarim, Gelistirme, Test)
    ("ui", 1): [5, 7, 3], ("ui", 2): [9, 11, 5], ("ui", 3): [14, 18, 8],
    ("logic", 1): [2, 10, 3], ("logic", 2): [4, 16, 5], ("logic", 3): [6, 26, 8],
    ("risk", 1): [2, 8, 5], ("risk", 2): [3, 13, 9], ("risk", 3): [4, 22, 14],
}
SLICE = 8.0                                   # §3.4 kadro: her 8 puana en cok bir kisi
H0 = _c("H0", 0.04)                           # §3.6 hata yuku / puan
KIND_H = {"feature": 1.0, "fix": _c("KIND_FIX", 0.3)}   # §3.6 tur
C_REF = _c("CREF", 0.57)                      # §3.6 yakalama c = 0,57 x sqrt(Y)
SELF_TEST = _c("SELF", 0.6)                   # §3.6 kendi gelistirdigi kart
FIX_LIGHT, FIX_HEAVY, HEAVY_P = _c("FIXL", 1.3), _c("FIXH", 5.3), _c("HEAVYP", 0.18)   # §3.6 duzeltme isi
FIX_PER_BUG, FIX_MIN = _c("FIXPB", 2.0), _c("FIXMIN", 5.0)   # §3.12 c duzeltme karti
PREP_RATIO = 0.20                             # §3.8
CEIL = _c("CEIL", 1.25)                       # §3.12 a toplam tavan
PHASE_K = _c("PHASEK", 2.0)                   # §3.12 a asama tavani
FIX_SHARE_MAX = _c("FIXSHARE", 0.5)           # §3.12 c duzeltme payi tavani
FIX_DUE_MIN = 2                               # §6.5 adim 1
Q_RATIO = _c("QRATIO", 1.0 / 3.0)             # §3.7 soru esigi
FLOOR_WEEK, USAGE = 0.7, 1.5                  # taban hata akisi
UNFIT_MORALE = -2                             # §3.3
FOUNDER_FLOOR = _c("FFLOOR", 0.86)            # §3.9 kurucu tabani
TITIZ_SPEED, TITIZ_Q = 0.85, 0.5              # §3.3 huy, §3.6 yapim kalitesi
TEAM_LEAD0, TEAM_LEAD_K = 0.85, 0.035         # §3.14 lider carpani (Liderlik 0..10)
TEAM_LOSS_K, TEAM_LOSS_FROM, TEAM_LOSS_MAX = _c("TEAMLOSS", 0.02), 8, 0.20
TEAM_LOSS_MODE = _c("TEAMLOSSMODE", "team")   # oneri: "marjinal" = kayip yalniz 8. kisiden sonra gelenlerin hizina   # §3.14 buyukluk kaybi
DEPTH_GAIN = _c("DGAIN", 0.75)                # §3.13 derinlik kazanci
DEPTH_MAX, DEPTH_DIV = _c("DEPTHMAX", 4), _c("DEPTHDIV", 10)   # §3.13 B: 1 + hesap/10, en cok 4
FILL_SKIP = _c("FILLSKIP", 0)                 # oneri: tutmayan adayi atla (varsayilan belgedeki gibi 0 = durulur)
EPS = 1e-6
AREA = ["design", "eng", "qa"]                # alan satirlari: Tasarim, Yazilim, Test
ROW = [0, 1, 2, 1]                            # asama -> alan satiri (Duzeltme Gelistirme satirinda, §3.2)
MAIN = {"pm": "product", "des": "design", "dev": "eng", "test": "qa"}
SECN = {"pm": "design", "des": "product", "dev": "qa", "test": "eng"}
DIST = [6, 4, 8, 5, 3, 6, 7, 4, 5, 6]         # §6.10 "Dagilim"
FOUNDER_SK = {"product": 4, "design": 0, "eng": 4, "qa": 0}
REASONS = ("kart_yok", "asama_dolu", "rol_uymuyor", "hazirlik_yok")   # §6.12 kapi 17 nedenleri


def Y(s):
    return 0.5 + 0.05 * s + 0.01 * s * s       # §6.2


def prep_rate(s):                              # §6.2 PREP_RATE
    return 15.0 + 10.0 * math.sqrt((s - 2) / 8.0) if s >= 2 else 7.5 * s


def prep_b(s):                                 # §6.2 PREP_B
    return min(0.30, max(0.05, 0.10 + 0.025 * (s - 2)))


def prep_h(s):                                 # §6.2 PREP_H
    return min(0.40, max(0.05, 0.10 + 0.0375 * (s - 2)))


# ---------------------------------------------------------------- kisi (§6.3)
def fit(role, boxes, area):
    """(U, sinif) ya da None. §6.3 fit()."""
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
        if SECN[role] == area and role != "pm":     # PM'in ikincil tasarimi sayilmaz
            return (0.7, 2)
        return None
    return None


class Person:
    def __init__(self, pid, role, sk, boxes=None, titiz=False, hint=None):
        self.id, self.role, self.sk, self.titiz, self.hint = pid, role, sk, titiz, hint
        dflt = {"founder": ("build", "test"), "pm": ("build",), "des": ("build",), "dev": ("build",), "test": ("test",)}
        self.boxes = tuple(boxes) if boxes is not None else dflt[role]

    def rate(self, area):
        """Haftalik asama hizi, §6.3: BASE x Y x U x huy; kurucuda Y tabani."""
        f = fit(self.role, self.boxes, area)
        if f is None:
            return 0.0
        y = Y(self.sk.get(area, 0))
        if self.role == "founder":
            y = max(FOUNDER_FLOOR, y)
        r = BASE * y * f[0]
        return r * TITIZ_SPEED if self.titiz else r

    def prep_rate(self):
        """Hazirlik hizi (puan/hafta), §6.3: yalniz Yapim kutulu PM."""
        if self.role != "pm" or "build" not in self.boxes:
            return 0.0
        r = prep_rate(self.sk.get("product", 0))
        return r * TITIZ_SPEED if self.titiz else r

    def catch(self):
        return min(1.0, C_REF * math.sqrt(Y(self.sk.get("qa", 0))))     # §6.3 c(k)

    def build_q(self):
        q = 1.0 / math.sqrt(Y(self.sk.get("eng", 0)))                    # §6.3 build_q
        return q * TITIZ_Q if self.titiz else q


class Team:
    """Bir hucrenin (tum ekip ya da EA takimi) hiz matrisi. mult: takim carpani (§3.14)."""

    def __init__(self, people, sw, mult=1.0):
        self.p = people
        self.n = len(people)
        self.sw = sw
        self.mult = mult
        mults = mult if isinstance(mult, list) else [mult] * len(people)
        self.rate = [[p.rate(a) * mults[i] for a in AREA] for i, p in enumerate(people)]
        self.prate = [p.prep_rate() * mults[i] for i, p in enumerate(people)]
        self.key = []
        for i, p in enumerate(people):
            row = []
            for j, a in enumerate(AREA):
                f = fit(p.role, p.boxes, a)
                cls = f[1] if f else None
                # §3.4 kurucunun guclu alani: puani >= 5 olan en guclu alanda sinif 0
                if f and p.role == "founder":
                    s = p.sk.get(a, 0)
                    if s >= 5 and s == max(p.sk.get(x, 0) for x in AREA):
                        cls = 0
                row.append((cls, -self.rate[i][j], i) if f and self.rate[i][j] > 0 else None)
            self.key.append(row)
        self.cap = sum(max(r) for r in self.rate) * sw                    # §6.3 kapasite (PM 0 katar)
        self.pcap = [sum(r[i] for r in self.rate) * sw for i in range(3)]
        pr = sorted((-r, i) for i, r in enumerate(self.prate) if r > 0)
        self.pms = [(i, -r) for r, i in pr]
        ds = sorted((-self.rate[i][0], i) for i, p in enumerate(people) if p.role == "des" and "build" in p.boxes and self.rate[i][0] > 0)
        self.des = [(i, -r) for r, i in ds]
        self.morale = [0] * self.n
        self.fwork = [0.0] * 4          # kurucunun asama basina isi (Tasarim, Gelistirme, Test, Duzeltme)


# ---------------------------------------------------------------- kart (§6.4)
class Card:
    _n = 0

    def __init__(self, kind, line, tier=None, prof=None, bugs=0, src="tier"):
        Card._n += 1
        self.id = Card._n
        self.kind, self.line, self.tier, self.prof, self.src = kind, line, tier, prof, src
        if kind == "fix":
            self.size = max(FIX_MIN, FIX_PER_BUG * bugs)                  # §3.12 c
            self.base_need = [0.0, 0.7 * self.size, 0.3 * self.size, 0.0]   # pay 0 / 0,7 / 0,3
        else:
            self.size = SIZE[min(tier, 3)]
            self.base_need = list(map(float, NEED[(prof, min(tier, 3))])) + [0.0]
        self.need = list(self.base_need)
        self.prog = [0.0] * 4
        self.prep = self.prepb = self.preph = 0.0
        self.ready = self.hcut = 0.0
        self.kadro = [1, 1, 1, 1]
        self.t0 = 0.0
        self.fixed = False
        self.log = {}
        self.done_at = None
        self.enter = None
        self.tested = False
        self.nbugs = self.found = 0
        self.costs = []
        self.H = self.C = 0.0
        self.counted = False
        self.cviol = False
        self.due = None
        self.seq = self.id

    def clone(self):
        c = Card.__new__(Card)
        c.__dict__.update(self.__dict__)
        c.base_need, c.need, c.prog, c.kadro = list(self.base_need), list(self.need), list(self.prog), list(self.kadro)
        c.log = {k: list(v) for k, v in self.log.items()}
        c.costs = list(self.costs)
        return c

    def prep_need(self):
        return 0.0 if self.kind == "fix" else PREP_RATIO * self.size       # §3.8: duzeltme karti hazirlanmaz

    def phase(self):
        """§6.4 phase(): 0 Tasarim, 1 Gelistirme, 2 Test, 3 Duzeltme, 4 bitti."""
        n, p = self.need, self.prog
        for i in range(3):
            if n[i] - p[i] > EPS:
                return i
        if not self.tested:
            return 2
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
        """§6.4 fix_start: ozellik kartinin sprinte ilk girisinde bir kez; kadro her sprint basinda."""
        if not self.fixed and self.kind == "feature":
            self.fixed = True
            pn = self.prep_need()
            self.ready = min(1.0, self.prep / pn)
            sb = self.prepb / pn
            self.hcut = self.preph / pn
            self.need = [x / (1.0 + sb) for x in self.base_need[:3]] + [0.0]
        self.kadro = [max(1, math.ceil(self.need[i] / SLICE - EPS)) for i in range(4)]
        self.t0 = self.need[2]

    def known(self):
        """(duzeltilmemis bulunan hata sayisi, bunlardan agir olan). §6.7: bulunus sirasi, kumulatif is <= prog[3] duzeltilmis."""
        done, m, acc = self.prog[3], 0, 0.0
        for c in self.costs:
            acc += c
            if acc <= done + EPS:
                m += 1
        return self.found - m, sum(1 for i, c in enumerate(self.costs) if i >= m and c > FIX_LIGHT + EPS)


def poisinv(u, lam):
    """Ters dagilim Poisson (§3.6: kartin ilk tohum sayisiyla)."""
    if lam <= 0:
        return 0
    k, p = 0, math.exp(-lam)
    s = p
    while u > s and k < 1000:
        k += 1
        p *= lam / k
        s += p
    return k


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


def on_test_done(card, team, seed):
    """§6.7 test_bitti(kart). Tohum: kosu tohumu ve kart kimligi; plan oynatmasi ve kapanis ayni sayiyi ceker (§3.11)."""
    card.tested = True
    eng = {k: v[1] for k, v in card.log.items() if v[1] > 0}
    tot = sum(eng.values())
    q = sum(w * team.p[k].build_q() for k, w in eng.items()) / tot if tot > 0 else 1.0
    card.H = H0 * card.size * KIND_H[card.kind] * (1.0 - card.hcut) * q
    cov = 0.0
    if card.t0 > EPS:
        for k, v in card.log.items():
            if v[2] > 0:
                c = team.p[k].catch()
                if v[1] > 0:                      # bu kartin Gelistirme asamasinda calisan kisi (§3.6 x0,6)
                    c *= SELF_TEST
                cov += v[2] / card.t0 * c
    card.C = min(1.0, cov)
    best = max([team.p[k].catch() for k, v in card.log.items() if v[2] > 0], default=0.0)
    card.cviol = card.C > best + 1e-9
    r = random.Random("%s:%d" % (seed, card.id))
    card.nbugs = poisinv(r.random(), card.H)
    costs = []
    for _ in range(card.nbugs):
        u, v = r.random(), r.random()
        if u < card.C:
            costs.append(FIX_HEAVY if v < HEAVY_P else FIX_LIGHT)
    card.found, card.costs = len(costs), costs
    card.need[3] = sum(costs)
    card.kadro[3] = max(1, math.ceil(card.need[3] / SLICE - EPS))


# ---------------------------------------------------------------- hafta oynatma (§6.6)
def run_week(team, cards, seed, off=0.0, ahead=(), prepq=(), logit=True, watch=None, track=False):
    """Bir hafta zaman sirali oynatir. (bosta, uymayan_kisiler, nedenler) doner.
    watch: kart; bu kart > EPS is alirsa erken doner (planlama kontrolu, §6.5 adim 4 b)."""
    n = team.n
    free = list(range(n))
    crews = {}
    opened = [0.0] * len(cards)
    busy = [0.0] * n
    unfit = set()
    keys, rate = team.key, team.rate
    fr = [dict.fromkeys(REASONS, 0.0) for _ in range(n)] if track else None
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
        if track and free and dt > 0:
            for pi in free:
                why = "kart_yok"
                for ci, c in enumerate(cards):
                    ph = c.phase()
                    if ph >= 4:
                        continue
                    why = "rol_uymuyor"
                    if keys[pi][ROW[ph]] is not None and opened[ci] <= t + 1e-12:
                        why = "asama_dolu"
                        break
                fr[pi][why] += dt
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
                    if team.p[pi].role == "founder":
                        team.fwork[ph] += w
                busy[pi] += dt
            if c.need[ph] - c.prog[ph] <= EPS:
                c.prog[ph] = c.need[ph]
                free.extend(crew)
                crews[ci] = []
                opened[ci] = nxt
                if ph == 2:
                    on_test_done(c, team, seed)          # test bittigi an hata sayisi belli (§3.6)
                if c.phase() == 4:
                    c.done_at = off + nxt
        t = nxt
        if watch is not None and sum(watch.prog) - wprog > EPS:
            return 0.0, unfit, None
        if t >= 1.0 - 1e-9:
            break
    left = [max(0.0, 1.0 - b) for b in busy]
    # hazirlik (§6.6): PM'ler hizli olandan yavasa; kuyruk sirasiyla; ayni hafta baska PM'in aldigi kart atlanir
    taken, alloc = set(), []
    for pi, pr in team.pms:
        for c in prepq:
            if left[pi] <= EPS:
                break
            need = c.prep_need()
            if c.id in taken or c.prep >= need - EPS:
                continue
            w = min(need - c.prep, left[pi] * pr)
            alloc.append((c, pi, w))
            left[pi] -= w / pr
            taken.add(c.id)
    if alloc:
        sbest = max(team.p[pi].sk.get("product", 0) for _, pi, _ in alloc)     # §6.4 PM_BEST (haftada payi olan en iyi PM)
        for c, pi, w in alloc:
            c.prep += w
            c.prepb += w * prep_b(sbest)
            c.preph += w * prep_h(sbest)
    # onden tasarim (v2 aynen)
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
    why = None
    if track:
        why = dict.fromkeys(REASONS, 0.0)
        pmset = {pi for pi, _ in team.pms}
        for pi in range(n):
            if left[pi] <= EPS:
                continue
            if pi in pmset:
                why["hazirlik_yok"] += left[pi]
                continue
            tot = sum(fr[pi].values())
            if tot <= EPS:
                why["kart_yok"] += left[pi]
                continue
            for k, v in fr[pi].items():
                why[k] += left[pi] * v / tot
    return sum(left), unfit, why


# ---------------------------------------------------------------- hucre ve sim (§6.5, §6.7)
class Cell:
    """Bir plan birimi: takimsiz ekipte tum ekip; EA takim kipinde her takim (§6.5 adim 7)."""

    def __init__(self, people, sw, lines=None, mult=1.0, lead=None):
        self.people = list(people)
        self.sw = sw
        self.lines = lines          # None = hepsi
        self.mult = mult
        self.lead = lead
        self.team = Team(self.people, sw, mult)
        self.carried = []
        self.cards = []
        self.ahead = []
        self.prepq = []
        self.pred = None
        self.stop = None
        self.cand_open = 0
        self.fill = None

    def rebuild(self):
        mor, fw = self.team.morale, self.team.fwork
        self.team = Team(self.people, self.sw, self.mult)
        self.team.morale[:len(mor)] = mor
        self.team.fwork = fw


def team_mult(n, lead):
    """§3.14 takim carpani = lider carpani x (1 - buyukluk kaybi)."""
    return (TEAM_LEAD0 + TEAM_LEAD_K * lead) * (1.0 - min(TEAM_LOSS_MAX, TEAM_LOSS_K * max(0, n - TEAM_LOSS_FROM)))


def deal_teams(people, t):
    """Kisileri takimlara dagit: kurucu takim 0'da; digerleri en kucuk takima (rol dengeli); ipuclu kisi dagitimdan sonra ipucundaki takima eklenir."""
    groups = [[] for _ in range(t)]
    order = {"founder": 0, "pm": 1, "test": 2, "des": 3, "dev": 4}
    rest = sorted(people, key=lambda p: (order[p.role], p.id))
    for p in rest:
        if p.role == "founder":
            groups[0].append(p)
    for p in rest:
        if p.role == "founder" or p.hint is not None:
            continue
        gi = min(range(t), key=lambda g: (len(groups[g]), sum(1 for q in groups[g] if q.role == p.role), g))
        groups[gi].append(p)
    for p in rest:
        if p.hint is not None:
            groups[p.hint % t].append(p)
    return groups


class Sim:
    def __init__(self, people, seed, weeks=60, one_card=False, check_pred=True, arz="sinirsiz", sw=2, policy="birak",
                 hires=None, teams=None, accounts_fixed=None, nofix=False, fillcheck=False, mod_week=60):
        Card._n = 0
        self.seed, self.weeks, self.one_card, self.check_pred = seed, weeks, one_card, check_pred
        self.arz, self.sw, self.policy, self.nofix, self.fillcheck = arz, sw, policy, nofix, fillcheck
        self.mod_week = mod_week
        self.rng = random.Random(seed)
        self.L = 12 if arz == "sinirsiz" else 9
        self.lines = self.L
        L = self.L
        self.prof = {}
        if arz == "sinirsiz":
            self.prof = {i: ("ui" if i < 4 else "logic" if i < 8 else "risk") for i in range(L)}
            mvp_lines = (0, 4, 8)
        else:
            self.prof = {i: ("ui", "logic", "risk")[min(2, i * 3 // L)] for i in range(L)}
            mvp_lines = (0, L // 3, 2 * L // 3)
        self.tier = [0] * L
        self.bugs = [0] * L
        self.issued = [0] * L
        self.depth_open = [0] * L
        self.depth_seq = [0] * L
        self.next_tier = {i: (2 if i in mvp_lines else 1) for i in range(L)}
        self.rr = 0
        self.cands = [Card("feature", l, 1, self.prof[l]) for l in mvp_lines]
        for l in mvp_lines:
            self.issued[l] = 1
        self.mvp_ids = {c.id for c in self.cands}
        self.live = False
        self.pending = []
        self.mvp_week = None
        self.done_ids = set()
        self.rec = []
        self.ready_log = []
        self.pred_maxdiff = 0.0
        self.fix_deferred = 0
        self.stop_phase = [0, 0, 0]
        self.hires = sorted(hires or [], key=lambda h: h[0])
        self.openw, self.delw, self.livew = [], [], []
        self.catch_viol = 0
        # arz kaynaklari (§3.13): hesaplar, istek, derinlik
        self.accounts = []
        self.users = [0] * L
        self.accounts_fixed = accounts_fixed
        self.req_made = self.req_merged = self.req_dropped = self.req_done = 0
        self.req_pts = self.depth_pts = self.tier_pts = 0.0
        self.new_req = self.new_depth = self.new_tier = 0
        self.depth_area = [0] * 4
        self.depth_gain = [0.0] * 4
        self.modules_added = False
        self.exh = None
        # hucreler
        if teams:
            t, leads = teams["t"], teams["leads"]
            groups = deal_teams(people, t)
            self.cells = []
            for g, grp in enumerate(groups):
                lead = leads[g % len(leads)]
                mult = team_mult(len(grp), lead)
                if TEAM_LOSS_MODE == "marjinal":
                    lm = TEAM_LEAD0 + TEAM_LEAD_K * lead
                    mult = [lm] * TEAM_LOSS_FROM + [mult] * max(0, len(grp) - TEAM_LOSS_FROM)
                self.cells.append(Cell(grp, sw, lines=set(), mult=mult, lead=lead))
            for l in range(L):
                self.cells[(l * t) // L].lines.add(l)
        else:
            self.cells = [Cell(people, sw)]

    # ----------------------------------------------------------- arz (§3.13)
    def _mk(self, l, tier, src, prof=None):
        c = Card("feature", l, tier, prof or self.prof[l], src=src)
        return c

    def gen(self):
        l = self.rr % self.L
        self.rr += 1
        t = self.next_tier[l]
        self.next_tier[l] += 1
        return self._mk(l, min(t, 3), "flow")

    def _users_target(self, l):
        return min(DEPTH_MAX, 1 + self.users[l] // DEPTH_DIV)  # §3.13 B (B2B)

    def _issue(self):
        """Kademe zinciri (SD arz.py) ve derinlik kartlari (§3.13 B). Sinirsiz kipte yok."""
        if self.arz == "sinirsiz":
            return
        for l in sorted(range(self.L), key=lambda x: (self.issued[x], x)):
            if self.issued[l] < 3 and self.issued[l] == self.tier[l]:
                self.issued[l] += 1
                self.cands.append(self._mk(l, self.issued[l], "tier"))
                self.new_tier += 1
        if self.arz in ("kaynakli", "ea"):
            for l in range(self.L):
                if self.tier[l] >= 3:
                    while self.depth_open[l] < self._users_target(l):
                        k = self.depth_seq[l] % 3
                        self.depth_seq[l] += 1
                        self.depth_open[l] += 1
                        self.cands.append(self._mk(l, k + 1, "depth"))
                        self.new_depth += 1

    def _add_account(self, idx, w, first_req=None):
        r = random.Random("%s:acc:%d" % (self.seed, idx))
        lines = r.sample(range(self.L), 3)
        seats = int(math.exp(r.uniform(math.log(5), math.log(150))))
        nxt = w + (first_req if first_req is not None else r.randint(1, 52))
        self.accounts.append({"lines": lines, "seats": seats, "next": nxt, "rng": r})
        for l in lines:
            self.users[l] += 1

    def _tick_accounts(self, w):
        """Her hafta sonu: yeni hesaplar (MVP'den sonra haftada 3, ya da sabit N), istekler (§6.4 kaynakli)."""
        if self.arz not in ("kaynakli", "ea") or not self.live:
            return
        if self.accounts_fixed:
            if not self.accounts:
                for i in range(self.accounts_fixed):
                    self._add_account(i, w, first_req=1 + (i * 52) // self.accounts_fixed)
        else:
            for _ in range(3):
                self._add_account(len(self.accounts), w)
        for a in self.accounts:
            while a["next"] <= w:
                a["next"] += 52
                l = a["rng"].choice(a["lines"])
                self.req_made += 1
                if self.tier[l] < 3:                        # hesabin hattinda acik kademe var: kademe kartinin yerine gecer
                    self.req_merged += 1
                    continue
                s = a["seats"]
                tr = 1 if s < 20 else 2 if s < 100 else 3
                c = self._mk(l, tr, "req")
                c.due = w + 8                                  # yorum: istek 8 hafta icinde yapilmazsa duser
                self.cands.append(c)
                self.new_req += 1

    def _add_modules(self):
        """EA: 60. haftada 4 yeni hat (modul). §6.4 ea."""
        t0 = self.L
        for j in range(4):
            l = t0 + j
            self.prof[l] = ("ui", "logic", "risk", "logic")[j]
            self.tier.append(0)
            self.bugs.append(0)
            self.issued.append(0)
            self.depth_open.append(0)
            self.depth_seq.append(0)
            self.users.append(0)
            if self.cells[0].lines is not None:
                ci = min(range(len(self.cells)), key=lambda g: (len(self.cells[g].lines), g))
                self.cells[ci].lines.add(l)
        self.L += 4
        self.modules_added = True

    def _expire_requests(self, w):
        keep = []
        for c in self.cands:
            if c.src == "req" and c.due is not None and c.due < w:
                self.req_dropped += 1
            else:
                keep.append(c)
        self.cands = keep

    def cand_list(self, cell):
        if self.arz == "sinirsiz":
            return self.cands
        lst = [c for c in self.cands if cell.lines is None or c.line in cell.lines]
        # §3.12 b: istekler (tarih), sonra kademe kartlari, sonra derinlik kartlari; icinde olusturulma sirasi
        lst.sort(key=lambda c: ((0, c.due, c.seq) if c.src == "req" else (1, 0, c.seq) if c.src in ("tier", "flow") else (2, 0, c.seq)))
        return lst

    # ----------------------------------------------------------- planlama (§6.5)
    def _take(self, cl, c):
        if self.arz == "sinirsiz":
            return self.cands.pop(0)
        cl.remove(c)
        self.cands.remove(c)
        return c

    def _head(self, cl):
        if self.arz == "sinirsiz":
            while not self.cands:
                self.cands.append(self.gen())
            return self.cands[0]
        return cl[0] if cl else None

    def _peek(self, cl, k):
        if self.arz == "sinirsiz":
            while len(self.cands) < k:
                self.cands.append(self.gen())
            return self.cands[:k]
        return cl[:k]

    def _gets_work(self, cell, cards, trial):
        """§6.5 adim 4 (b): kopya 2 hafta (onden issiz) oynatilinca > 0 is alir."""
        cc = [c.clone() for c in cards]
        tr = trial.clone()
        cc.append(tr)
        start = sum(tr.prog)
        for k in range(cell.sw):
            run_week(cell.team, cc, self.seed, k, logit=True, watch=tr)
            if sum(tr.prog) - start > EPS:
                return True
            if all(c.phase() == 4 for c in cc):
                break
        return sum(tr.prog) - start > EPS

    def _accepts(self, cell, cards, trial, count=True):
        """(a), (a2), (b) kosullari; (tutar, neden)."""
        if not cards:
            return True, None
        load = sum(c.remaining() for c in cards) + trial.remaining()
        if load > CEIL * cell.team.cap:
            return False, "tavan"
        tl = trial.row_left()
        cl = [0.0, 0.0, 0.0]
        for c in cards:
            for i, v in enumerate(c.row_left()):
                cl[i] += v
        for i in range(3):
            if tl[i] > EPS and cl[i] + tl[i] > PHASE_K * cell.team.pcap[i]:
                if count:
                    self.stop_phase[i] += 1
                return False, "asama%d" % i
        if not self._gets_work(cell, cards, trial):
            return False, "is_almaz"
        return True, None

    def plan(self, cell, w):
        cards = []
        team = cell.team
        mine = (lambda l: True) if cell.lines is None else (lambda l: l in cell.lines)
        if self.live and not self.nofix:
            have = {c.line for c in cell.carried if c.kind == "fix"}
            due = sorted([(b, l) for l, b in enumerate(self.bugs) if b >= FIX_DUE_MIN and l not in have and mine(l)], key=lambda t: (-t[0], t[1]))
            fl = sum(c.remaining() for c in cell.carried if c.kind == "fix")
            for b, l in due:
                c = Card("fix", l, bugs=b, src="fix")
                c.fix_start()
                if fl > EPS and fl + c.remaining() > FIX_SHARE_MAX * team.cap + EPS:      # §3.12 c duzeltme payi tavani
                    self.fix_deferred += 1
                    continue
                fl += c.remaining()
                cards.append(c)
        cards += cell.carried                                                            # bırakılan ve devreden (basamak 3)
        cell.carried = []
        for c in cards:
            c.fix_start()
        cap = team.cap
        fix_load = sum(c.remaining() for c in cards if c.kind == "fix")
        cl = self.cand_list(cell)
        cell.cand_open = len(cl) if self.arz != "sinirsiz" else None
        stop = None
        new = 0
        skipped = []
        if self.one_card:
            if not cards:
                c = self._take(cl, self._head(cl))
                c.fix_start()
                self.ready_log.append(c.ready)
                cards.append(c)
            stop = "tek"
        else:
            for _ in range(1000):
                nxt = self._head(cl)
                if nxt is None:
                    stop = stop or "arz"
                    break
                trial = nxt.clone()
                trial.fix_start()
                ok, why = self._accepts(cell, cards, trial)
                if not ok:
                    stop = stop or why
                    if FILL_SKIP > len(skipped) and self.arz != "sinirsiz":
                        skipped.append(cl.pop(0))
                        continue
                    break
                c = self._take(cl, nxt)
                c.fix_start()
                self.ready_log.append(c.ready)
                cards.append(c)
                new += 1
        cell.stop = stop
        if self.fillcheck and stop not in ("arz", "tek", None) and self.arz != "sinirsiz":
            # §6.12 kapi 19: oneri durdugu yerden sonraki adaylar da planin kuralina uyuyorsa onerinin dolulugu eksiktir
            tmp = list(cards)
            extra = 0.0
            for c0 in (skipped + cl)[:12 + len(skipped)]:
                tr = c0.clone()
                tr.fix_start()
                ok, _ = self._accepts(cell, tmp, tr, False)
                if ok:
                    tmp.append(tr)
                    extra += tr.remaining()
            cell.fill = (sum(c.remaining() for c in cards), extra)
        else:
            cell.fill = (sum(c.remaining() for c in cards), 0.0)
        # onden isler (§6.5 adim 6)
        nfeat = max(1, sum(1 for c in cards if c.kind == "feature"))
        has_des = any(p.role == "des" and "build" in p.boxes for p in cell.people)
        has_pm = any(p.role == "pm" and "build" in p.boxes for p in cell.people)
        cell.ahead = self._peek(self.cand_list(cell), nfeat) if has_des else []
        cell.prepq = self._peek(self.cand_list(cell), 3 * nfeat) if has_pm else []
        cell.cards = cards
        return fix_load, new

    # ----------------------------------------------------------- yayin (§6.7)
    def release(self, c, extra_known=0):
        nn = (c.nbugs - c.found) + extra_known
        if c.kind == "fix":
            self.bugs[c.line] = 0
        elif c.src in ("tier", "flow"):
            self.tier[c.line] = max(self.tier[c.line], c.tier)
        if c.src == "depth":
            self.depth_open[c.line] -= 1
            a = c.line % 4                                       # yorum: alan = hat numarasi mod 4 (B2B'de 4 alan)
            self.depth_gain[a] += DEPTH_GAIN ** self.depth_area[a]
            self.depth_area[a] += 1
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
            self.cells[0].people.append(p)
            changed = True
        if changed:
            self.cells[0].rebuild()

    def run(self):
        w = 0
        while w < self.weeks:
            self.apply_hires(w)
            start_w = w
            self._expire_requests(w)
            self._issue()
            fl_tot, new_tot, cap_tot = 0.0, 0, 0.0
            for cell in self.cells:
                fl, nw = self.plan(cell, w)
                fl_tot += fl
                new_tot += nw
                cap_tot += cell.team.cap
                for c in cell.cards:
                    if c.enter is None:
                        c.enter = start_w
                if self.check_pred:
                    cell.pred = self.predict(cell)
            before = sum(sum(c.prog) for cell in self.cells for c in cell.cards)
            idle = 0.0
            why = dict.fromkeys(REASONS, 0.0)
            weeks_run = 0
            fw0 = [list(cell.team.fwork) for cell in self.cells]
            fix0 = sum(c.prog[3] for cell in self.cells for c in cell.cards)
            st0 = [sum(c.prog[s_] for cell in self.cells for c in cell.cards) for s_ in range(4)]
            for k in range(self.sw):
                for cell in self.cells:
                    i, unfit, wh = run_week(cell.team, cell.cards, self.seed, w, cell.ahead, cell.prepq, True, track=True)
                    idle += i
                    for kk, v in wh.items():
                        why[kk] += v
                    for pi in unfit:
                        cell.team.morale[pi] += UNFIT_MORALE
                w += 1
                weeks_run += 1
                if self.live:
                    for _ in range(poisson(self.rng, FLOOR_WEEK * USAGE)):
                        lv = [l for l in range(self.L) if self.tier[l] >= 1]
                        self.bugs[self.rng.choice(lv)] += 1
                self.openw.append(sum(self.bugs))
                self.livew.append(sum(1 for t_ in self.tier if t_ >= 1))
                self._tick_accounts(w)
                if self.arz == "ea" and not self.modules_added and w >= self.mod_week:
                    self._add_modules()
                if all(c.phase() == 4 for cell in self.cells for c in cell.cards):
                    break
            self.close(start_w, w, weeks_run, fl_tot, cap_tot, idle, why, fw0, fix0, before, new_tot, st0)
        return self

    def close(self, start_w, w, weeks_run, fl_tot, cap_tot, idle, why, fw0, fix0, before, new_tot, st0):
        allcards = [c for cell in self.cells for c in cell.cards]
        pts = sum(sum(c.prog) for c in allcards) - before
        fixwork = sum(c.prog[3] for c in allcards) - fix0
        stage_pts = [sum(c.prog[s_] for c in allcards) - st0[s_] for s_ in range(4)]
        if self.check_pred:
            for cell in self.cells:
                self.compare_pred(cell, start_w)
        found_sprint = sum(c.found for c in allcards if c.tested and not c.counted)
        self.catch_viol += sum(1 for c in allcards if c.tested and not c.counted and getattr(c, "cviol", False))
        for c in allcards:
            if c.tested:
                c.counted = True
        fixing = [c for c in allcards if c.phase() == 3]
        K = sum(c.known()[0] for c in fixing)
        Kh = sum(c.known()[1] for c in fixing)
        asked = bool(fixing) and K >= max(1, math.ceil(Q_RATIO * found_sprint - EPS))     # §3.7 / §6.7 soru
        ship = []
        if fixing:
            if self.policy == "hep_gonder":
                ship = fixing
            elif asked and self.policy == "gonder":
                ship = fixing
            elif asked and self.policy == "esikli":
                ship = [c for c in fixing if c.known()[1] == 0]
        esc, delivered, ndone, lead, shipped_k = [], 0, 0, [], 0
        cell_deliv = []
        for cell in self.cells:
            cd = 0
            for c in cell.cards:
                isdone = c.phase() == 4
                if not (isdone or c in ship):
                    continue
                kk = c.known()[0] if c in ship else 0
                nn = self.release(c, kk)
                shipped_k += kk
                if c.kind == "feature":
                    esc.append(nn)
                    delivered += c.size
                    cd += c.size
                    ndone += 1
                    lead.append(w - c.enter)
                    if c.src == "req":
                        self.req_done += 1
                        self.req_pts += c.size
                    elif c.src == "depth":
                        self.depth_pts += c.size
                    else:
                        self.tier_pts += c.size
            cell_deliv.append(cd)
            cell.carried = [c for c in cell.cards if c.phase() < 4 and c not in ship]
        if self.exh is None and self.arz != "sinirsiz" and all(t_ >= 3 for t_ in self.tier[:9]):
            self.exh = w
        if not self.live and self.mvp_ids <= self.done_ids:
            self.live = True
            self.mvp_week = w
            for l in self.pending:
                self.bugs[l] += 1
            self.pending = []
        left = [0.0, 0.0, 0.0]
        for cell in self.cells:
            for c in cell.carried:
                for i, v in enumerate(c.row_left()):
                    left[i] += v
        pcap = [sum(cell.team.pcap[i] for cell in self.cells) for i in range(3)]
        fw1 = [cell.team.fwork for cell in self.cells]
        fst = [sum(fw1[ci][s] - fw0[ci][s] for ci in range(len(self.cells))) for s in range(4)]
        n_tot = sum(cell.team.n for cell in self.cells)
        nocard = any(cell.stop == "arz" for cell in self.cells) and why["kart_yok"] >= 1.0 - EPS
        cos = [(cell.cand_open, cell.team.n) for cell in self.cells]
        self.rec.append({
            "start": start_w, "end": w, "weeks": weeks_run, "pts": pts, "cards": ndone,
            "fixes": sum(1 for c in allcards if c.kind == "fix" and c.phase() == 4),
            "share": fl_tot / cap_tot if cap_tot else 0.0, "open": sum(self.bugs), "esc": esc,
            "left": left, "pcap": pcap, "idle": idle, "why": why, "ncards": len(allcards), "delivered": delivered,
            "live": self.live, "lead": lead, "found": found_sprint, "K": K, "Kh": Kh, "asked": asked,
            "shipped_k": shipped_k, "fixwork": fixwork, "stage_pts": stage_pts, "cap": cap_tot, "founder_st": fst, "n": n_tot,
            "held": sum(c.size for c in fixing if c.kind == "feature"), "new": new_tot,
            "stop": [cell.stop for cell in self.cells], "cand": cos, "nocard": nocard, "cell_deliv": cell_deliv,
            "cell_idle": None, "fill": [cell.fill for cell in self.cells], "lines_live": sum(1 for t in self.tier if t >= 1),
        })
        self.delw += [delivered / weeks_run] * weeks_run

    # ----------------------------------------------------------- tahmin = sonuc (§3.11, §6.12 kapi 14)
    def predict(self, cell):
        mp = {}

        def cl(c):
            if c.id not in mp:
                mp[c.id] = c.clone()
            return mp[c.id]
        cc = [cl(c) for c in cell.cards]
        aa = [cl(c) for c in cell.ahead]
        pp = [cl(c) for c in cell.prepq]
        mor = list(cell.team.morale)
        fw = list(cell.team.fwork)
        for k in range(cell.sw):
            run_week(cell.team, cc, self.seed, k, aa, pp, True)
            if all(c.phase() == 4 for c in cc):
                break
        cell.team.morale = mor
        cell.team.fwork = fw
        return cc

    def compare_pred(self, cell, start_w):
        for c, p in zip(cell.cards, cell.pred):
            d = max(abs(a - b) for a, b in zip(c.prog, p.prog))
            if (c.done_at is None) != (p.done_at is None):
                d = max(d, 1.0)
            elif c.done_at is not None:
                d = max(d, abs((c.done_at - start_w) - p.done_at))
            d = max(d, abs(c.found - p.found), abs(c.nbugs - p.nbugs), abs(sum(c.costs) - sum(p.costs)))
            self.pred_maxdiff = max(self.pred_maxdiff, d)


# ---------------------------------------------------------------- takim kurucular (§6.10)
def founder(sk=None):
    return Person("Kurucu", "founder", dict(sk or FOUNDER_SK))


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


def P(role, s, boxes=None, hint=None):
    """Ayni puanli kisi (alinanlar, yildiz deneyleri)."""
    if role == "dev":
        return Person("EK", "dev", {"eng": s, "qa": max(0, s - 1), "design": 0, "product": 0}, boxes, hint=hint)
    if role == "test":
        return Person("EK", "test", {"qa": s, "eng": max(0, s - 1), "design": 0, "product": 0}, boxes, hint=hint)
    if role == "des":
        return Person("EK", "des", {"design": s, "product": max(0, s - 1), "eng": 0, "qa": 0}, boxes, hint=hint)
    return Person("EK", "pm", {"product": s, "design": max(0, s - 1), "qa": 2, "eng": 0}, boxes, hint=hint)


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


BASES = {
    "S1": lambda: [founder()],
    "S2": S2,
    "S3": S3,
    "S4": lambda: [founder()] + group(2, 2, 5, 2),
    "S5": lambda: [founder()] + group(3, 4, 12, 5),
    "S6": lambda: [founder()] + group(6, 8, 25, 10),
}
ADD = {
    "+3* gelistirici": lambda: P("dev", 6),
    "+3* testci": lambda: P("test", 6),
    "+3* tasarimci": lambda: P("des", 6),
    "+3* PM": lambda: P("pm", 6),
    "+1* gelistirici": lambda: P("dev", 2),
}
SCEN = {}      # ad -> (kisi fonksiyonu, Sim kwargs)


def reg(name, fn, **kw):
    SCEN[name] = (fn, kw)


for k, f in BASES.items():
    reg(k, f)
# uc bilesimler (v2 §6.10 aynen)
reg("S7", lambda: [founder(), P("dev", 6), P("dev", 5)] + [Person("T%d" % (i + 1), "test", {"qa": q, "eng": max(0, q - 1), "design": 0, "product": 0}) for i, q in enumerate([6, 5, 4, 8, 3])])
reg("S7_1test", lambda: [founder(), P("dev", 6), P("dev", 5), P("test", 6)])
reg("S8", lambda: [founder()] + group(dev=10))
reg("S8_ek_testkutulu_gel", lambda: [founder()] + group(dev=10) + [P("dev", 6, ("build", "test"))])
reg("S8_hepsi_testkutulu", lambda: [founder()] + group(dev=10, dev_boxes=("build", "test")))
reg("S9a", lambda: [founder()] + group(test=8))
reg("S9a_ek_gel", lambda: [founder()] + group(test=8) + [P("dev", 6)])
reg("S9b", lambda: [founder()] + group(test=8, test_boxes=("build", "test")))
reg("S10", lambda: [founder()] + group(0, 6, 16, 7))
reg("S11", lambda: [founder()] + group(2, 2, 20, 0))
reg("S11_ek_testci", lambda: [founder()] + group(2, 2, 20, 0) + [P("test", 6)])
reg("S11b", lambda: [founder()] + group(2, 2, 20, 0, dev_boxes=("build", "test")))
reg("S12", BASES["S4"], one_card=True)
reg("S3_PMsiz", lambda: [p for p in S3() if p.role != "pm"])
reg("S3_PM_testkutulu", lambda: [Person(p.id, p.role, p.sk, ("build", "test") if p.role == "pm" else None) for p in S3()])
reg("S4_PMsiz", lambda: [founder()] + group(0, 2, 5, 2))
reg("S4_1PM", lambda: [founder()] + group(1, 2, 5, 2))
reg("S5_1PM", lambda: [founder()] + group(1, 4, 12, 5))
for b in ("S2", "S3", "S4", "S5", "S6"):
    for a in ADD:
        reg("%s %s" % (b, a), (lambda bb, aa: (lambda: BASES[bb]() + [ADD[aa]()]))(b, a))

# testci yildizi (§6.10): bütün testciler 1*, 3*, 5*; testcisiz (testci yerine Test kutulu gelistirici)
STAR = {1: 2, 3: 6, 5: 10}
for st, k in STAR.items():
    reg("T3_%d" % st, (lambda kk: (lambda: [Person(p.id, p.role, ({"qa": kk, "eng": max(0, kk - 1), "design": 0, "product": 0} if p.id == "Ayse" else p.sk)) for p in S3()]))(k))
    reg("T4_%d" % st, (lambda kk: (lambda: [founder()] + group(2, 2, 5, 0) + [P("test", kk), P("test", kk)]))(k))
    reg("T5_%d" % st, (lambda kk: (lambda: [founder()] + group(3, 4, 12, 0) + [P("test", kk) for _ in range(5)]))(k))
reg("T3_yok", lambda: [Person(p.id, p.role, p.sk, ("build", "test") if p.role == "dev" else None) for p in S3() if p.role != "test"] + [Person("EKG", "dev", {"eng": 5, "qa": 4, "design": 0, "product": 0}, ("build", "test"))])
reg("T4_yok", lambda: [founder()] + group(2, 2, 7, 0, dev_boxes=("build", "test")))
reg("T5_yok", lambda: [founder()] + group(3, 4, 17, 0, dev_boxes=("build", "test")))
# PM yildizi (§6.10): 11 kisi (1 PM, 2 tas, 5 gel, 2 test) ve 23 kisi (1 PM, 4, 12, 5)
for st, k in STAR.items():
    reg("PM3_%d" % st, (lambda kk: (lambda: [Person(p.id, p.role, ({"product": kk, "design": max(0, kk - 1), "qa": 2, "eng": 0} if p.role == "pm" else p.sk)) for p in S3()]))(k))
    reg("PM4_%d" % st, (lambda kk: (lambda: [founder(), P("pm", kk)] + group(0, 2, 5, 2)))(k))
    reg("PM5_%d" % st, (lambda kk: (lambda: [founder(), P("pm", kk)] + group(0, 4, 12, 5)))(k))
reg("PM5_yok", lambda: [founder()] + group(0, 4, 12, 5))
# oneri kosusu (gate 11): 25 kisi, 3 PM ayni yildizda ve 24 kisi, 2 PM
for st, k in STAR.items():
    reg("PM6_%d" % st, (lambda kk: (lambda: [founder()] + [P("pm", kk) for _ in range(3)] + group(0, 4, 12, 5)))(k))
    reg("PM7_%d" % st, (lambda kk: (lambda: [founder()] + [P("pm", kk) for _ in range(2)] + group(0, 4, 12, 5)))(k))

# kisi ekleme egrisi (S6 orani, en buyuk eksik kurali; v2 ile ayni)
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
    reg("C%d" % n, (lambda nn: (lambda: curve_team(nn)))(n))

# kurucu buyumesi (§6.10 "Kurucu buyumesi"): 4 kurucu tipi x 6 alim sirasi x +0..+3, 0. haftadan; ve 8/14/20. haftada
FOUNDERS = {
    "orta": {"product": 4, "design": 0, "eng": 4, "qa": 0},
    "gel4": {"product": 4, "design": 0, "eng": 8, "qa": 0},
    "gel5": {"product": 4, "design": 0, "eng": 10, "qa": 0},
    "tasarim_test": {"product": 4, "design": 6, "eng": 4, "qa": 6},
}
SEQS = {
    "gel-tas-test": [("dev", 5), ("des", 5), ("test", 5)],
    "tas-gel-test": [("des", 5), ("dev", 5), ("test", 5)],
    "test-gel-tas": [("test", 5), ("dev", 5), ("des", 5)],
    "pm-gel-tas": [("pm", 5), ("dev", 5), ("des", 5)],
    "1yildiz": [("dev", 2), ("des", 2), ("test", 2)],
    "uc-gel": [("dev", 5), ("dev", 5), ("dev", 5)],
}
HIRE_WEEKS = (8, 14, 20)
for fk, fsk in FOUNDERS.items():
    for sk_, seq in SEQS.items():
        for k in range(4):
            reg("G|%s|%s|%d" % (fk, sk_, k), (lambda f_, ss, kk: (lambda: [founder(f_)] + [P(r, s) for r, s in ss[:kk]]))(fsk, seq, k))
            reg("GT|%s|%s|%d" % (fk, sk_, k), (lambda f_, ss, kk: (lambda: [founder(f_)]))(fsk, seq, k),
                hires=None, _hire_spec=(fsk, seq, k), weeks=60)


def _ghires(spec):
    fsk, seq, k = spec
    return [(HIRE_WEEKS[i], P(seq[i][0], seq[i][1])) for i in range(k)]


# buyume egrisi (§6.10 "Kart sayisi olcegi"): 0-12 hf 1, 12-30 3, 30-60 6, 60-130 10 kisi
def growth_hires():
    return [(12, P("dev", 7)), (12, P("des", 6)),
            (30, Person("Selin", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0})),
            (30, Person("Mert", "dev", {"eng": 3, "qa": 2, "design": 0, "product": 0})),
            (30, Person("Ayse", "test", {"qa": 5, "eng": 4, "design": 0, "product": 0})),
            (60, P("dev", 5)), (60, P("dev", 4)), (60, P("des", 5)), (60, P("test", 4))]


# arz kipleri: S1..S6 sonlu ve kaynakli, 1 ve 2 haftalik sprint
for b in BASES:
    for arz in ("sonlu", "kaynakli"):
        for sw in (1, 2):
            reg("A|%s|%s|%d" % (b, arz, sw), BASES[b], arz=arz, sw=sw, fillcheck=True)
for arz in ("sonlu", "kaynakli"):
    reg("GC|%s" % arz, lambda: [founder()], arz=arz, weeks=130, _growth=True, fillcheck=True)
# istek payi: sabit hesap sayisi
for b in ("S3", "S4", "S5", "S6"):
    for acc in (100, 330):
        reg("R|%s|%d" % (b, acc), BASES[b], arz="kaynakli", accounts_fixed=acc)

# EA takim kipi (§6.10 "EA takim"): 50 kisi, ea arzi, 130 hafta
reg("EA0", BASES["S6"], arz="ea", weeks=130)
reg("EA1", BASES["S6"], arz="ea", weeks=130, teams={"t": 1, "leads": [6]})
reg("EA3", BASES["S6"], arz="ea", weeks=130, teams={"t": 3, "leads": [4, 6, 8]})
reg("EA7", BASES["S6"], arz="ea", weeks=130, teams={"t": 7, "leads": [2, 3, 4, 5, 6, 7, 8]})
reg("EA3_lidersiz", BASES["S6"], arz="ea", weeks=130, teams={"t": 3, "leads": [0]})
reg("EA7_lidersiz", BASES["S6"], arz="ea", weeks=130, teams={"t": 7, "leads": [0]})
EA_ADD = {"+3* gelistirici": ("dev", 6), "+3* testci": ("test", 6), "+3* tasarimci": ("des", 6), "+3* PM": ("pm", 6)}
for tn, tcount, leads in (("EA3", 3, [4, 6, 8]), ("EA7", 7, [2, 3, 4, 5, 6, 7, 8])):
    for ak, (r_, s_) in EA_ADD.items():
        reg("%s %s" % (tn, ak), (lambda rr, ss: (lambda: BASES["S6"]() + [P(rr, ss, hint=0)]))(r_, s_),
            arz="ea", weeks=130, teams={"t": tcount, "leads": leads})

# D5 (§4.9): duzeltme kapali / acik, 80 hafta
for b in BASES:
    reg("D5|%s|nofix" % b, BASES[b], weeks=80, nofix=True)
    reg("D5|%s|fix" % b, BASES[b], weeks=80)


# ---------------------------------------------------------------- olcum (§6.8)
def _tgt(n):
    """§3.13 hedef: plan aninda acik aday >= 0,75 x ekip (8 kisinin altinda >= ekip)."""
    return n if n < 8 else 0.75 * n


def _med(xs):
    xs = [x for x in xs if x is not None]
    return statistics.median(xs) if xs else None


def metrics(sim, lo=20):
    r = sim.rec
    win = [x for x in r if x["end"] > lo] or r
    wk = sum(x["weeks"] for x in win)
    n_end = sum(cell.team.n for cell in sim.cells)
    mvp = sim.mvp_week
    early = [x for x in r if mvp is not None and mvp <= x["start"] < mvp + 20]
    post = [x for x in r if mvp is not None and x["start"] >= mvp]
    bs_flags = [x["share"] > 0.5 for x in post]
    consec = any(a and b for a, b in zip(bs_flags, bs_flags[1:]))
    lastw = [x for x in r if x["end"] > sim.weeks - 20]
    slope = None
    if len(lastw) >= 3:
        xs = [x["end"] for x in lastw]
        ys = [x["open"] for x in lastw]
        mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
        den = sum((a - mx) ** 2 for a in xs)
        slope = sum((a - mx) * (b - my) for a, b in zip(xs, ys)) / den if den > 0 else 0.0
    esc = [e for x in win for e in x["esc"]]
    totdel = sum(x["delivered"] for x in win)
    capsum = sum(x["cap"] for x in win)
    nsp = len(win)
    rl = sim.ready_log[len(sim.ready_log) // 3:]
    # darbogaz: kalan is / asama kapasitesi (inceleme kurali)
    ratio = [0.0, 0.0, 0.0]
    for x in win:
        for i in range(3):
            ratio[i] += x["left"][i] / x["pcap"][i] if x["pcap"][i] else 0.0
    ratio = [v / nsp for v in ratio]
    bott = ("Tasarim", "Gelistirme", "Test")[ratio.index(max(ratio))] if max(ratio) >= 0.25 else "yok"
    why = {k: sum(x["why"][k] for x in win) / wk for k in REASONS}
    idle_sprints = [x for x in win if x["idle"] > 0.10 * x["n"] * x["weeks"]]
    f_all = [x["founder_st"] for x in win]
    fsum = [sum(f[s] for f in f_all) / wk for s in range(4)]
    # arz havuzu: plan aninda acik aday >= 0,75 x ekip (8 kisinin altinda >= ekip)
    ok_pool = tot_pool = 0
    for x in win:
        for (co, nn) in x["cand"]:
            if co is None:
                continue
            tot_pool += 1
            ok_pool += 1 if co >= _tgt(nn) - 1e-9 else 0
    fills = [(a, b) for x in win for (a, b) in x["fill"] if a + b > 0]
    fill_ratio = sum(a for a, b in fills) / sum(a + b for a, b in fills) if fills else None
    stops = {}
    for x in win:
        for s in x["stop"]:
            stops[s] = stops.get(s, 0) + 1
    return {
        "n": n_end, "mvp": mvp, "deliv": totdel / wk, "per_person": totdel / wk / n_end,
        "cards_sprint": sum(x["cards"] for x in win) / nsp,
        "esc_card": statistics.mean(esc) if esc else 0.0,
        "esc100": 100.0 * sum(esc) / totdel if totdel else 0.0,
        "open_med": _med([x["open"] for x in win]), "open_max": max(x["open"] for x in win),
        "fix_late": _med([x["share"] for x in win]), "fix_early": _med([x["share"] for x in early]),
        "bs_late": (sum(1 for x in win if x["share"] > 0.5), nsp),
        "bs_early": (sum(1 for x in early if x["share"] > 0.5), len(early)),
        "bs_all": (sum(1 for x in post if x["share"] > 0.5), len(post)),
        "consec": consec, "slope": slope,
        "idle_w": sum(x["idle"] for x in win) / wk, "idle_pct": sum(x["idle"] for x in win) / wk / n_end,
        "idle_sprint10": len(idle_sprints) / nsp, "why": why, "bott": bott, "ratio": ratio,
        "ready": statistics.mean(rl) if rl else 0.0, "pred": sim.pred_maxdiff,
        "found_sp": sum(x["found"] for x in win) / nsp, "K_sp": sum(x["K"] for x in win) / nsp,
        "asked": sum(1 for x in win if x["asked"]) / nsp,
        "infix": sum(x["fixwork"] for x in win) / capsum if capsum else 0.0,
        "tot_fix": (sum(x["fixwork"] for x in win) + sum(x["share"] * x["cap"] for x in win)) / capsum if capsum else 0.0,
        "founder_w": sum(fsum[:3]) + fsum[3], "founder_st": fsum,
        "stage_w": [sum(x["stage_pts"][s_] for x in win) / wk for s_ in range(4)],
        "wip": sum(x["ncards"] for x in win) / nsp,
        "lead": statistics.mean([l for x in win for l in x["lead"]]) if any(x["lead"] for x in win) else None,
        "shipped_k": sum(x["shipped_k"] for x in win) / nsp,
        "hel_sprint": sum(x["held"] for x in win) / nsp,
        "pool_ok": ok_pool / tot_pool if tot_pool else None,
        "nocard": sum(1 for x in win if x["nocard"]) / nsp,
        "new_sp": sum(x["new"] for x in win) / nsp,
        "fill_ratio": fill_ratio, "stops": stops,
        "req": (sim.req_made, sim.req_merged, sim.req_dropped, sim.req_done, sim.new_req, sim.new_depth, sim.new_tier),
        "pts_src": (sim.req_pts, sim.depth_pts, sim.tier_pts),
        "depth_area": list(sim.depth_area), "depth_gain": list(sim.depth_gain),
        "morale": [list(c.team.morale) for c in sim.cells], "roles": [[p.role for p in c.team.p] for c in sim.cells],
        "cell_deliv": [sum(x["cell_deliv"][i] for x in win) / wk for i in range(len(sim.cells))] if sim.cells else [],
        "cell_n": [c.team.n for c in sim.cells], "cell_mult": [(sum(c.mult) / len(c.mult) if isinstance(c.mult, list) else c.mult) for c in sim.cells],
        "series": [(x["start"], x["end"], x["delivered"], x["n"], x["nocard"], x["cand"][0][0],
                    None if x["cand"][0][0] is None else x["cand"][0][0] >= _tgt(x["cand"][0][1]) - 1e-9,
                    x["idle"] / max(1, x["n"] * x["weeks"]), x["asked"], x["share"]) for x in r],
        "openw": list(sim.openw), "delw": list(sim.delw), "live_lines": sum(1 for t in sim.tier if t >= 1),
        "stop_phase": list(sim.stop_phase), "exh": sim.exh, "fix_deferred": sim.fix_deferred,
        "catch_viol": sim.catch_viol, "livew": list(sim.livew),
    }


def run_one(task):
    name, seed = task[0], task[1]
    opt = dict(task[2]) if len(task) > 2 and task[2] else {}
    fn, kw = SCEN[name]
    kw = dict(kw)
    spec = kw.pop("_hire_spec", None)
    growth = kw.pop("_growth", False)
    kw.update({k: v for k, v in opt.items() if k not in ("lo",)})
    lo = opt.get("lo", 20)
    ppl = fn()
    if spec:
        kw["hires"] = _ghires(spec)
    if growth:
        kw["hires"] = growth_hires()
    kw.setdefault("weeks", 60)
    sim = Sim(ppl, seed, **kw)
    sim.run()
    m = metrics(sim, lo)
    return name, seed, m


def run_many(names, seeds, opt=None, workers=4):
    tasks = [(n, s, opt) for n in names for s in seeds]
    out = {}
    with ProcessPoolExecutor(max_workers=workers) as ex:
        for name, seed, m in ex.map(run_one, tasks, chunksize=1):
            out.setdefault(name, {})[seed] = m
    return out


def medof(res, name, key, idx=None):
    vals = []
    for m in res[name].values():
        v = m[key]
        if idx is not None and v is not None:
            v = v[idx]
        if v is not None:
            vals.append(v)
    return statistics.median(vals) if vals else None


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "quick"
    if cmd == "quick":
        for nm in sys.argv[2:] or ["S1", "S3"]:
            t = time.time()
            _, _, m = run_one((nm, 1))
            print(nm, {k: (round(v, 3) if isinstance(v, float) else v) for k, v in m.items() if k not in ("series", "openw", "delw", "morale", "roles", "why", "ratio")}, "%.1fs" % (time.time() - t))
    elif cmd == "exec":
        exec(open(sys.argv[2], encoding="utf-8").read(), globals())
