# A6 · karmasikliga olceklenen hata modeli + PM okumalari + "kalan kartlar buyukten kucuge" kolu. a3core'u genisletir, dsim3.py'ye dokunmaz.
# Varsayilan davranis A3 ile ayni (CFG2.hata = "bugun", pmh = "bugun", rest = "yeten", CFG.pm k4h/erdem): a6test.py regress bunu A3 kayitlariyla dogrular.
# Model (A6_HATA_MODELI.md §0):  H = T x tur x (1 - h) x toplam( is payi_k x m(delta_k) x TITIZ_k ),  T = c x puan x R^p,
#   m(delta) = M0 x 0.5^(delta / M_YARI),  delta = kisinin Yazilim yildizi - R,  R = max(R_TABAN, kartin Gelistirme kapisi).
import os, sys, math, random
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3core as A
D = A.D
EPS = D.EPS


class Cfg2:
    hata = "bugun"       # bugun = D.on_test_done (yapim kalitesi 1/sqrt(Y)) | yeni = karmasikliga olceklenen
    c = 0.0              # tavan katsayisi (K-E: 100 / (69.6 x 3); K-H: kalibrasyon)
    p = 1.0              # gereksinim kuvveti
    m0 = 0.20            # delta = 0'da oran
    half = 2.0           # her 'half' yildizda oran yariya
    rfloor = 1.0         # kilitsiz kart = 1 yildiz
    pmh = "bugun"        # PM hata azaltmasi: bugun (mutlak yildiz) | delta (yildiz - kartin Urun kapisi)
    pm_base = 0.10
    pm_slope = 0.075
    rest = "yeten"       # tarifin 2. adimi: yeten (tarif) | bk (kalan kartlar buyukten kucuge, siradaki en iyi kisi)
    top1 = "gereksinim"  # tarifin 1. adimi: gereksinim (tarif) | plan (yalniz tani kolu)


CFG2 = Cfg2()
C_E = 100.0 / (69.6 * 3.0)       # K-E: "3 sprintlik is" = 69,6 puan, gereksinim 3 yildiz, tavan 100


def mfun(delta):
    return CFG2.m0 * 0.5 ** (delta / CFG2.half)


def req_dev(team, c):
    """Kartin Gelistirme asamasindaki gereksinimi (yildiz): kapi verisi, ekibin en iyisiyle sinirli (A.creq), en az R_TABAN."""
    return max(CFG2.rfloor, A.creq(team, c, 1))


def kappa(team, c):
    """Karmasiklik = hata tavaninin c'siz hali: puan x R^p."""
    return c.size * req_dev(team, c) ** CFG2.p


def ceiling(team, c):
    return CFG2.c * kappa(team, c)


# ------------------------------------------------------------------ hata modeli
_orig_on_test_done = D.on_test_done


def _tail(card, team, seed, aud):
    """D.on_test_done'in card.H'tan sonrasi (yakalama, hata sayisi, bulunanlar): bayt bayt ayni, H disaridan gelir."""
    card.C = 0.0
    cov = 0.0
    if card.t0 > EPS:
        for k, v in card.log.items():
            if v[2] > 0:
                c = team.p[k].catch()
                if v[1] > 0:
                    c *= D.SELF_TEST
                cov += v[2] / card.t0 * c
    card.C = min(1.0, cov)
    if aud is not None:
        selfp = [k for k, v in card.log.items() if v[2] > 0 and v[1] > 0]
        aud["tested"] += 1
        aud["selft"] += 1 if selfp else 0
        aud["selft_founder"] += 1 if any(team.p[k].role == "founder" for k in selfp) else 0
    best = max([team.p[k].catch() for k, v in card.log.items() if v[2] > 0], default=0.0)
    card.cviol = card.C > best + 1e-9
    r = random.Random("%s:%d" % (seed, card.id))
    card.nbugs = D.poisinv(r.random(), card.H)
    costs = []
    for _ in range(card.nbugs):
        u, v = r.random(), r.random()
        if u < card.C:
            costs.append(D.FIX_HEAVY if v < D.HEAVY_P else D.FIX_LIGHT)
    card.found, card.costs = len(costs), costs
    card.need[3] = sum(costs)
    card.kadro[3] = max(1, math.ceil(card.need[3] / D.SLICE - EPS))


def quality(team, card, eng=None):
    """Yapim kalitesi yerine gecen terim: is payi agirlikli m(delta) x TITIZ."""
    if eng is None:
        eng = {k: v[1] for k, v in card.log.items() if v[1] > 0}
    tot = sum(eng.values())
    if tot <= 0:
        return mfun(0.0)
    st = A.tinfo(team)["stars"]
    R = req_dev(team, card)
    return sum(w * mfun(st[k][1] - R) * (D.TITIZ_Q if team.p[k].titiz else 1.0) for k, w in eng.items()) / tot


def on_test_done2(card, team, seed, aud=None):
    if CFG2.hata != "yeni":
        return _orig_on_test_done(card, team, seed, aud)
    card.tested = True
    card.H = ceiling(team, card) * D.KIND_H[card.kind] * (1.0 - card.hcut) * quality(team, card)
    _tail(card, team, seed, aud)


D.on_test_done = on_test_done2


# ------------------------------------------------------------------ PM: hazirlik, okumalar
def prep_h_card(team, c, s_):
    if CFG2.pmh != "delta":
        return D.prep_h(s_)
    rq = max(1.0, A.creq_pm(team, c))
    return min(0.40, max(0.05, CFG2.pm_base + CFG2.pm_slope * (s_ / 2.0 - rq)))


def prep_generic2(team, prepq, left, k, sw, mode, times=None, plan_order=False):
    """A.prep_generic'in kopyasi; tek fark: hata azaltmasi kartin Urun kapisina gore olculebilir (CFG2.pmh = delta)."""
    todo = [c for c in prepq if c.kind == "feature" and c.prep < c.prep_need() - EPS] if plan_order else A._pm_order_todo(team, prepq, mode)
    if not todo:
        return
    A._pm_owners(team, todo, left, sw - k - 1, mode)
    for pi in team.pm_order:
        pr = team.prate[pi]
        s_ = team.p[pi].sk.get("product", 0)
        for c in todo:
            if left[pi] <= EPS:
                break
            need = c.prep_need()
            if c.preparer != team.ids[pi] or c.prep >= need - EPS:
                continue
            w = min(need - c.prep, left[pi] * pr)
            c.prep += w
            c.prepb += w * D.prep_b(s_)
            c.preph += w * prep_h_card(team, c, s_)
            dt = w / pr
            if times is not None:
                times[c.id] = (1.0 - left[pi]) + dt
            left[pi] -= dt


_orig_order = A._pm_order_todo
_orig_owners = A._pm_owners


def pm_order_todo2(team, prepq, mode):
    if mode in ("basit", "zor"):
        todo = [(c, i) for i, c in enumerate(prepq) if c.kind == "feature" and c.prep < c.prep_need() - EPS]
        todo.sort(key=lambda x: (-kappa(team, x[0]), x[1]))
        return [c for c, _ in todo]
    return _orig_order(team, prepq, mode)


def pm_owners2(team, todo, left, weeks_after, mode):
    if mode not in ("basit", "zor"):
        return _orig_owners(team, todo, left, weeks_after, mode)
    pm_ids = {team.ids[pi]: pi for pi in team.pm_order}
    budget = {pi: team.prate[pi] * (left[pi] + weeks_after) for pi in team.pm_order}
    for c in todo:
        if c.preparer in pm_ids:
            budget[pm_ids[c.preparer]] -= c.prep_need() - c.prep
    ti = A.tinfo(team)
    unass = [c for c in todo if c.preparer not in pm_ids]
    if not unass:
        return
    if mode == "zor":                                         # (ii) zor karta en iyi PM, kalanlari bostaki en iyi PM sirayla
        for c in unass:
            rq = A.creq_pm(team, c)
            el = [pi for pi in team.pm_order if ti["pstars"][pi] >= rq - 1e-9 and budget[pi] > EPS]
            if not el:
                continue
            c.preparer = team.ids[el[0]]
            budget[el[0]] -= c.prep_need() - c.prep
        return
    act = [pi for pi in team.pm_order if budget[pi] > EPS]    # (i) karmasiklik sirasi ile PM kalitesi sirasi eslenir, dilim = PM kapasitesi payi
    if not act:
        return
    totb = sum(budget[pi] for pi in act)
    needs = [c.prep_need() - c.prep for c in unass]
    totn = sum(needs)
    cumf, s = [], 0.0
    for pi in act:
        s += budget[pi]
        cumf.append(s / totb)
    cum = 0.0
    for c, nd in zip(unass, needs):
        x = (cum + nd / 2.0) / totn if totn > 0 else 0.0
        cum += nd
        j = next((i for i, f in enumerate(cumf) if x <= f + 1e-12), len(act) - 1)
        rq = A.creq_pm(team, c)
        order = sorted(range(len(act)), key=lambda i: (abs(i - j), i))
        pick = None
        for i in order:
            pi = act[i]
            if ti["pstars"][pi] >= rq - 1e-9 and budget[pi] > EPS:
                pick = pi
                break
        if pick is None:
            continue
        c.preparer = team.ids[pick]
        budget[pick] -= nd


A._pm_order_todo = pm_order_todo2
A._pm_owners = pm_owners2
A.prep_generic = prep_generic2


# ------------------------------------------------------------------ atama: tarifin 2. adimi "kalan kartlar buyukten kucuge" (BK)
_orig_alloc = A._alloc_erdem


def alloc_gen(team, cards, st, r, es, rr, tl):
    """A._alloc_erdem'in kopyasi (top = cap, req/order/suff A.CFG'den). Secenekler: CFG2.rest = bk (2. adim: kalan kartlar o asamadaki kalan ise gore
    buyukten kucuge, her karta siradaki en hizli uygun kisi); CFG2.top1 = plan (tani: 1. adimdaki 'en onde' kart gereksinim yerine plan sirasiyla secilir)."""
    ti = A.tinfo(team)
    rate = team.rate
    order = sorted(rr, key=lambda x: (-A.creq(team, cards[x[1]], x[2]), -cards[x[1]].need[x[2]], cards[x[1]].pos, cards[x[1]].id))
    if CFG2.top1 == "plan":
        order = sorted(rr, key=lambda x: (cards[x[1]].pos, cards[x[1]].id))
    pool = sorted(es, key=lambda pi: (-rate[pi][r], team.ids[pi]))
    take = {}
    left_slots = {x[1]: x[3] for x in rr}
    crewrate = {x[1]: sum(rate[pi][r] for pi in (st.crews.get(x[1]) or ())) for x in rr}

    def el(pi, x):
        return A.eligible(team, pi, cards[x[1]], x[2])

    def put(x, pis):
        take.setdefault(x[1], []).extend(pis)
        left_slots[x[1]] -= len(pis)
        crewrate[x[1]] += sum(rate[pi][r] for pi in pis)
        for pi in pis:
            pool.remove(pi)

    def rem(x):
        c = cards[x[1]]
        return c.need[x[2]] - c.prog[x[2]]

    def bud(x):
        if A.CFG.suff != "kart":
            return tl
        c = cards[x[1]]
        tot = sum(max(0.0, c.need[j] - c.prog[j]) for j in range(x[2], 4))
        return tl * rem(x) / tot if tot > 1e-9 else tl

    top = None
    for x in order:
        cand = [pi for pi in pool if team.cls[pi][r] != 3 and el(pi, x)]
        if not cand:
            continue
        put(x, cand[:left_slots[x[1]]])
        top = x
        break
    if top is None:
        return take
    if CFG2.rest == "bk":
        for x in sorted(rr, key=lambda x: (-rem(x), cards[x[1]].pos, cards[x[1]].id)):
            if x is top or left_slots[x[1]] <= 0 or not pool or crewrate[x[1]] > 0 or rem(x) <= 1e-9:
                continue
            cand = [pi for pi in pool if team.cls[pi][r] != 3 and el(pi, x)]
            if cand:
                put(x, [cand[0]])
    else:
        order2 = sorted(rr, key=lambda x: (cards[x[1]].pos, cards[x[1]].id)) if A.CFG.order == "plan" else order
        for x in order2:
            if x is top or left_slots[x[1]] <= 0 or not pool:
                continue
            bx_ = bud(x)
            need = rem(x) - crewrate[x[1]] * bx_
            if need <= 1e-9:
                continue
            cand = [pi for pi in pool if team.cls[pi][r] != 3 and el(pi, x)]
            if not cand:
                continue
            alone = [pi for pi in cand if rate[pi][r] * bx_ >= need - 1e-9]
            if alone:
                put(x, [min(alone, key=lambda pi: (rate[pi][r], team.ids[pi]))])
                continue
            if left_slots[x[1]] >= 2 and len(cand) >= 2:
                cs = sorted(cand, key=lambda pi: (rate[pi][r], team.ids[pi]))
                best = None
                for i in range(len(cs)):
                    for j in range(i + 1, len(cs)):
                        s_ = rate[cs[i]][r] + rate[cs[j]][r]
                        if s_ * bx_ >= need - 1e-9 and (best is None or (s_, team.ids[cs[i]], team.ids[cs[j]]) < best[0]):
                            best = ((s_, team.ids[cs[i]], team.ids[cs[j]]), [cs[i], cs[j]])
                        if s_ * bx_ >= need - 1e-9:
                            break
                if best:
                    put(x, best[1])
    while pool:
        bx, bu = None, -1.0
        for x in order:
            if left_slots[x[1]] <= 0 or not any(el(pi, x) for pi in pool):
                continue
            u = max(rem(x), 0.0) / max(crewrate[x[1]], 1e-9)
            if u > bu + 1e-12:
                bx, bu = x, u
        if bx is None:
            break
        cand = [pi for pi in pool if el(pi, bx)]
        fitc = [pi for pi in cand if team.cls[pi][r] != 3]
        cand = fitc or cand
        put(bx, [cand[0]])
    return take


def alloc_dispatch(team, cards, st, r, es, rr, tl):
    if (CFG2.rest == "bk" or CFG2.top1 == "plan") and A.CFG.assign == "erdem" and A.CFG.top == "cap":
        return alloc_gen(team, cards, st, r, es, rr, tl)
    return _orig_alloc(team, cards, st, r, es, rr, tl)


A._alloc_erdem = alloc_dispatch


# ------------------------------------------------------------------ simulasyon: doguan/kacan hata, gereksinimin altinda calisan is
class A6Sim(A.A3Sim):
    def __init__(self, people, seed, trace=False, **kw):
        super().__init__(people, seed, **kw)
        self.born_log = []           # sprint basina: dict
        self._esc = 0
        self.trace = trace
        self.cardrec = []

    def release(self, c, extra_known=0):
        nn = super().release(c, extra_known)
        self._esc += nn
        return nn

    def close(self, start_w, w, *a):
        born = bornf = found = 0
        hsum = 0.0
        wdev = wbelow = wdelta = 0.0
        self._esc = 0
        for cell in self.cells:
            ti = A.tinfo(cell.team)
            for c in cell.cards:
                if c.tested and not c.counted:
                    born += c.nbugs
                    if c.kind == "feature":
                        bornf += c.nbugs
                    found += c.found
                    hsum += c.H
                    R = req_dev(cell.team, c)
                    for k, v in c.log.items():
                        if v[1] > 0:
                            d = ti["stars"][k][1] - R
                            wdev += v[1]
                            wdelta += v[1] * d
                            if d < -1e-9:
                                wbelow += v[1]
        r = super().close(start_w, w, *a)
        self.born_log.append({"start": start_w, "end": w, "born": born, "born_feat": bornf, "found": found, "H": hsum, "esc": self._esc,
                              "wdev": wdev, "wbelow": wbelow, "wdelta": wdelta})
        if self.trace:
            for cell in self.cells:
                for c in cell.cards:
                    if c.delivered_s == self.sidx:
                        self.cardrec.append(card_record(self, cell.team, c, start_w, w))
        return r


def card_record(sim, team, c, start_w, w):
    st = A.tinfo(team)["stars"]
    devs = {team.ids[k]: (round(v[1], 2), st[k][1]) for k, v in c.log.items() if v[1] > 0}
    tests = {team.ids[k]: (round(v[2], 2), st[k][2]) for k, v in c.log.items() if v[2] > 0}
    dess = {team.ids[k]: (round(v[0], 2), st[k][0]) for k, v in c.log.items() if v[0] > 0}
    return {"id": c.id, "kind": c.kind, "line": c.line, "tier": c.tier, "src": c.src, "size": c.size, "promise": c.promise, "due_s": c.due_s,
            "enter": c.enter, "done_w": w, "sprint": sim.sidx, "pos": c.pos, "preparer": c.preparer, "ready": round(c.ready, 3), "hcut": round(c.hcut, 3),
            "R": req_dev(team, c), "req": list(A.req_raw(c)), "H": round(c.H, 3), "nbugs": c.nbugs, "found": c.found, "C": round(c.C, 3),
            "dev": devs, "test": tests, "des": dess, "need": [round(x, 1) for x in c.need], "done_at": c.done_at}
