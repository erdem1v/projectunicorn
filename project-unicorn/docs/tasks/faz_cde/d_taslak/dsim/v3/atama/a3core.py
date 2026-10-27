# A3 · Erdem'in atama tarifi: dsim3.py'ye dokunmadan yama + alt sinif. Calistirma: a3run.py (bu dosya yalniz modul).
# dsim3 sabitleri ortam degiskeniyle ice aktarilirken okunur; R okumasi (D3_KEYMODE=plan D3_SHIELD=0 D3_PMRULE=karar4h) burada varsayilir,
# D3_LEGACY=1 ise (eski kural kolu) hicbir sey set edilmez. Yeni kod: week3 (D.week2'nin kopyasi + kancalar), atama kipleri, PM kurali, kapi, ustalik aramasi.
import os, sys, json, math, random

HERE = os.path.dirname(os.path.abspath(__file__))
V3 = os.path.dirname(HERE)
sys.path.insert(0, V3)
if os.environ.get("D3_LEGACY") != "1":
    for _k, _v in (("D3_KEYMODE", "plan"), ("D3_SHIELD", "0"), ("D3_PMRULE", "karar4h")):
        os.environ.setdefault(_k, _v)
sys.stdout.reconfigure(encoding="utf-8")
import dsim3 as D

EPS = D.EPS
ROW = D.ROW
INF = 1e18
LO = 20                                   # D.metrics penceresi: sprint sonu > 20. hafta


class Cfg:
    """Kosu ayari (gorev basina set edilir; tahmin ve gercek ayni degeri okur)."""
    assign = "k4"      # k4 (D0s) | erdem | rnd | rev | manual
    pm = "k4h"         # k4h (D0s) | erdem
    gate = 0           # 1 = hazirliksiz kart Gelistirmeye giremez (PM'li ekipte)
    stick = 0          # 1 = kisi asama bitene dek kartinda kalir (hafta ve sprint sinirini asar)
    suff = "kart"      # "yeten": kart = asamanin sprint payi icinde bitirebilen (kart sprintte bitsin) | asama = sprintin kalan suresinde bitirebilen
    order = "plan"     # kalan kartlar (adim 2) sirasi: plan = sprint plani sirasi (oncelik) | gerek = gereksinim, sonra buyukluk
    top = "cap"        # en yuksek gereksinimli karta: cap = kadro tavani kadar en iyi kisi | min = sprintte yetecek en az sayida en iyi kisi
    req = "data"       # data = kapi verisi aynen | sert = her sifirdan buyuk kapi bir yildiz yukari | yok = gereksinim yok (karsilastirma)
    rkey = ""          # rnd tohumu
    master = 0         # 1 = ustalik aramasi
    mit = 60           # arama yineleme sayisi
    mobj = 2           # ustalik olcusu: 1 = teslim agirlikli | 2 = net is (hata maliyetli)
    warn = 0.0         # >0: uyari esigi (satir yuku / kapasite) -> "dinleyen oyuncu" bir kart degistirir


CFG = Cfg()
CTX = [0, 2]                              # (hafta indeksi k, sprint haftasi sw) week3 -> atama
DETAIL = {}                               # off >= LO gercek haftalarda kisi-hafta olarak boslugun nedeni
WLOG = []                                 # (hafta, k, kisi, kart, pay, asama_acik) gercek oynatma
WSE = []                                  # (hafta, k, {kisi: kart} hafta basi, {kisi: kart} hafta sonu: asamasi acik kalanlar)
ARZ_L = [9]

# ------------------------------------------------------------------ kapi verisi -> kart gereksinimi
GATES = {}                                # satir kimligi -> {kademe: [tasarim, yazilim, test, urun] yildiz}
GROUPS_REAL = {"ui": ["line_erp_stock", "line_erp_invoicing", "line_shared_mobile"],
               "logic": ["line_erp_cashflow", "line_erp_intake", "line_shared_integrations"],
               "risk": ["line_erp_ledger", "line_shared_security", "line_shared_durability"]}
_AREAIDX = {"design": 0, "engineering": 1, "qa": 2, "product": 3}


def _load_gates():
    erp = json.load(open(os.path.join(HERE, "veri", "erp.json"), encoding="utf-8"))
    sh = json.load(open(os.path.join(HERE, "veri", "shared.json"), encoding="utf-8"))
    ov = erp.get("shared_gate_overrides", {})
    for ln in erp["lines"] + sh["lines"]:
        d = {}
        for s in ln["steps"]:
            rq = ov.get(s["id"], s["requires"])
            v = [0, 0, 0, 0]
            for e in rq.get("person", []):
                i = _AREAIDX[e["area"]]
                v[i] = max(v[i], int(e["stars"]))
            d[int(s["id"][-1])] = v
        GATES[ln["id"]] = d


_load_gates()
D.reg("S6_2PM", lambda: [D.founder()] + D.group(2, 8, 25, 10))        # PM'i az ekipler: PM kapisi okumasinin gercek sinavi


def real_line(c):
    prof = c.prof
    j = (c.line % 4) % 3 if ARZ_L[0] == 12 else c.line % 3
    return GROUPS_REAL[prof][j]


def req_raw(c):
    """Kart gereksinimi (yildiz) [tasarim, yazilim, test, urun]. Kapisi olmayan kartlar: duzeltme = yazilim 1, derinlik = hattin K3 kapisi,
    istek = hesabin kademesinin (koltuk boyutu) kapisi (kart kademesi zaten oyle kurulu)."""
    r = getattr(c, "_rq", None)
    if r is None:
        if c.kind == "fix":
            r = [0, 1, 0, 0]
        else:
            tier = 3 if c.src == "depth" else min(c.tier, 3)
            r = GATES[real_line(c)][tier]
        c._rq = r
    return r


def tinfo(team):
    """Ekip basina bir kez: kisi yildizlari [tasarim, yazilim, test], satir basina uygun en iyi yildiz, kimlik indeksi."""
    ti = getattr(team, "_a3", None)
    if ti is None:
        stars = []
        for p in team.p:
            row = []
            for a in D.AREA:
                s = p.sk.get(a, 0) / 2.0
                if p.role == "founder":
                    s = max(2.0, s)               # kurucu en az 2 yildiz hizinda calisir (FOUNDER_FLOOR); gereksinimde de oyle sayilir
                row.append(s)
            stars.append(row)
        best = []
        for r in range(3):
            v = [stars[i][r] for i in range(team.n) if team.cls[i][r] is not None and team.cls[i][r] < 3]
            best.append(max(v) if v else 0.0)
        pstars = {i: team.p[i].sk.get("product", 0) / 2.0 for i in team.pm_order}
        pbest = max(pstars.values()) if pstars else 0.0
        ti = team._a3 = {"stars": stars, "best": best, "idx": {team.ids[i]: i for i in range(team.n)}, "pstars": pstars, "pbest": pbest}
    return ti


def _hard(v):
    if CFG.req == "yok":
        return 0
    return v + 1 if (CFG.req == "sert" and v > 0) else v


def creq(team, c, ph):
    """Kartin bu asamadaki gereksinimi (yildiz); ekibin o satirdaki en iyisini asamaz (kapi sirket duzeyinde zaten gecilmis sayilir)."""
    r = ROW[ph]
    return min(_hard(req_raw(c)[r]), tinfo(team)["best"][r])


def creq_pm(team, c):
    return min(_hard(req_raw(c)[3]), tinfo(team)["pbest"])


def eligible(team, pi, c, ph):
    r = ROW[ph]
    return tinfo(team)["stars"][pi][r] >= creq(team, c, ph) - 1e-9 and not (ph == 3 and team.nofix[pi])


# ------------------------------------------------------------------ kapi (PM hazirligi)
def has_gate(team):
    return CFG.gate and bool(team.pm_order)


def is_gated(team, c, k, t):
    return (CFG.gate and c.kind == "feature" and c.phase() == 1 and c.prep < c.prep_need() - EPS
            and k + t < getattr(c, "gate_t", INF) - 1e-12 and bool(team.pm_order))


def apply_benefit(c):
    """Hazirlik tamamlaninca fayda: kalan isin oranini koruyarak ihtiyaci dusurur (fix_start'in gec ve tam hali)."""
    pn = c.prep_need()
    sb = c.prepb / pn
    for i in range(3):
        if c.base_need[i] > 0 and c.need[i] > 0:
            frac = c.prog[i] / c.need[i]
            nn = c.base_need[i] / (1.0 + sb)
            c.need[i] = nn
            c.prog[i] = frac * nn
    c.hcut = c.preph / pn
    c.ready = min(1.0, c.prep / pn)
    c.t0 = c.need[2]


# ------------------------------------------------------------------ PM kurali
def _pm_order_todo(team, prepq, mode):
    todo = [(c, i) for i, c in enumerate(prepq) if c.kind == "feature" and c.prep < c.prep_need() - EPS]
    if mode == "erdem":
        todo.sort(key=lambda x: (-creq_pm(team, x[0]), -x[0].size, x[1]))
    else:
        todo.sort(key=lambda x: (-x[0].size, x[1]))
    return [c for c, _ in todo]


def _pm_owners(team, todo, left, weeks_after, mode):
    pm_ids = {team.ids[pi]: pi for pi in team.pm_order}
    budget = {pi: team.prate[pi] * (left[pi] + weeks_after) for pi in team.pm_order}
    for c in todo:
        if c.preparer in pm_ids:
            budget[pm_ids[c.preparer]] -= c.prep_need() - c.prep
    if mode == "k4h":
        for pi in team.pm_order:
            for c in todo:
                if budget[pi] <= EPS:
                    break
                if c.preparer is None:
                    c.preparer = team.ids[pi]
                    budget[pi] -= c.prep_need() - c.prep
        return
    ti = tinfo(team)
    unass = [c for c in todo if c.preparer not in pm_ids]
    for n, c in enumerate(unass):
        need = c.prep_need() - c.prep
        rq = creq_pm(team, c)
        el = [pi for pi in team.pm_order if ti["pstars"][pi] >= rq - 1e-9 and budget[pi] > EPS]
        if not el:
            continue
        if n == 0:
            pick = el[0]                                       # en yuksek gereksinimli (ve buyuk) kart: en iyi PM, bitene kadar
        else:
            suff = [pi for pi in el if budget[pi] >= need - EPS]
            pick = min(suff, key=lambda pi: (ti["pstars"][pi], team.ids[pi])) if suff else el[0]   # yeten en dusuk yildizli PM
        c.preparer = team.ids[pick]
        budget[pick] -= need


def prep_generic(team, prepq, left, k, sw, mode, times=None, plan_order=False):
    """k4h: D.prep_k4h'in aynisi. erdem: yuksek gereksinimli karta en iyi PM, kucuk kartlara yeten en dusuk yildizli PM, kart bitince siradaki.
    times: kart -> hazirligin bittigi an (hafta icinde), kapi icin."""
    todo = [c for c in prepq if c.kind == "feature" and c.prep < c.prep_need() - EPS] if plan_order else _pm_order_todo(team, prepq, mode)
    if not todo:
        return
    _pm_owners(team, todo, left, sw - k - 1, mode)
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
            c.preph += w * D.prep_h(s_)
            dt = w / pr
            if times is not None:
                times[c.id] = (1.0 - left[pi]) + dt
            left[pi] -= dt


def gate_schedule(team, cards, st, k, sw):
    """Kapi okumasi: haftanin basinda PM'ler sprintteki hazirliksiz kartlari once hazirlar; kart bitince Gelistirme acilir (an: gate_t)."""
    if not has_gate(team) or st.t != 0.0 or any(st.busy):
        return
    left = [max(0.0, 1.0 - b) for b in st.busy]
    pend = [c for c in cards if c.kind == "feature" and c.phase() < 4 and c.prep < c.prep_need() - EPS]
    if not pend:
        return
    times = {}
    used = list(left)
    prep_generic(team, pend, left, k, sw, CFG.pm, times, True)          # sprintteki kartlar plan sirasiyla: ilk siradaki kart ac kalmasin
    for pi in range(team.n):
        st.busy[pi] += used[pi] - left[pi]
    for c in pend:
        if c.prep >= c.prep_need() - EPS:
            c.gate_t = k + times.get(c.id, 0.0)
            apply_benefit(c)
        else:
            c.gate_t = INF


# ------------------------------------------------------------------ atama
def _reseat(team, cards, st):
    ti = tinfo(team)
    for ci, c in enumerate(cards):
        ph = c.phase()
        if ph >= 4 or st.opened[ci] > st.t + 1e-12:
            continue
        kp = getattr(c, "keep", None)
        if not kp or c.keep_ph != ph:
            continue
        r = ROW[ph]
        crew = []
        for pid in kp:
            pi = ti["idx"].get(pid)
            if pi is None or pi not in st.free or team.cls[pi][r] is None or team.rate[pi][r] <= 0 or (ph == 3 and team.nofix[pi]):
                continue
            if len(crew) >= c.kadro[ph]:
                break
            crew.append(pi)
        if crew:
            st.crews[ci] = crew
            for pi in crew:
                st.free.remove(pi)
                if team.cls[pi][r] == 3:
                    st.unfit.add(pi)


def _alloc_erdem(team, cards, st, r, es, rr, tl):
    """Tarif (bir satir, bir atama ani): kartlar gereksinime ve buyuklugune gore dizilir. En yuksek gereksinimli (ve uygun kisisi olan) karta
    o gereksinimi karsilayan en iyi kisiler (kadro tavani kadar; top=min ise sprintte yetecek en az sayida) gider. Kalan kartlara bu sprintte
    asamayi tek basina bitirmeye yeten en dusuk hizli kisi; tek kisi yetmiyorsa en dusuk yeten ikili; yetmeyen kart yardim adimina kalir.
    Kalan kisiler yardim adiminda: kalan isi en gec bitecek (kalan is / eldeki hiz en buyuk) karta, en iyiden baslayarak."""
    ti = tinfo(team)
    stars, rate = ti["stars"], team.rate
    order = sorted(rr, key=lambda x: (-creq(team, cards[x[1]], x[2]), -cards[x[1]].need[x[2]], cards[x[1]].pos, cards[x[1]].id))
    pool = sorted(es, key=lambda pi: (-rate[pi][r], team.ids[pi]))
    take = {}
    left_slots = {x[1]: x[3] for x in rr}
    crewrate = {x[1]: sum(rate[pi][r] for pi in (st.crews.get(x[1]) or ())) for x in rr}
    mode = CFG.assign

    def el(pi, x):
        return eligible(team, pi, cards[x[1]], x[2])

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
        """Asamayi bitirmek icin ayrilan sure (hafta): kart sprintte bitsin diye kalan sprint suresi, asamanin kalan is payiyla bolusulur."""
        if CFG.suff != "kart":
            return tl
        c = cards[x[1]]
        tot = sum(max(0.0, c.need[j] - c.prog[j]) for j in range(x[2], 4))
        return tl * rem(x) / tot if tot > 1e-9 else tl

    done_top = False
    for x in order:                                           # 1) en yuksek gereksinimli kart (uymayan is yalniz yardim adiminda, kimse bosta kalacaksa)
        cand = [pi for pi in pool if team.cls[pi][r] != 3 and el(pi, x)]
        if not cand:
            continue
        if mode == "rev":
            cand = cand[::-1]
        n = left_slots[x[1]]
        if CFG.top == "min":
            acc, nn = crewrate[x[1]] * bud(x), 0
            for pi in cand:
                if acc >= rem(x) - 1e-9 and nn >= 1:
                    break
                acc += rate[pi][r] * bud(x)
                nn += 1
            n = max(1, min(n, nn))
        put(x, cand[:n])
        top = x
        done_top = True
        break
    if not done_top:
        return take
    order2 = sorted(rr, key=lambda x: (cards[x[1]].pos, cards[x[1]].id)) if CFG.order == "plan" else order
    for x in order2:                                          # 2) kalan kartlar: yeten en dusuk kisi / ikili
        if x is top or left_slots[x[1]] <= 0 or not pool:
            continue
        bx_ = bud(x)
        need = rem(x) - crewrate[x[1]] * bx_
        if need <= 1e-9:
            continue
        cand = [pi for pi in pool if team.cls[pi][r] != 3 and el(pi, x)]
        if not cand:
            continue
        if mode == "rev":
            suff = [pi for pi in cand if rate[pi][r] * bx_ >= need - 1e-9]
            if suff:
                put(x, [max(suff, key=lambda pi: (rate[pi][r], team.ids[pi]))])
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
                    s = rate[cs[i]][r] + rate[cs[j]][r]
                    if s * bx_ >= need - 1e-9 and (best is None or (s, team.ids[cs[i]], team.ids[cs[j]]) < best[0]):
                        best = ((s, team.ids[cs[i]], team.ids[cs[j]]), [cs[i], cs[j]])
                    if s * bx_ >= need - 1e-9:
                        break
            if best:
                put(x, best[1])
    while pool:                                               # 3) yardim: kimse bosta kalmaz
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
        if mode == "rev":
            cand = cand[::-1]
        put(bx, [cand[0]])
    return take


def _alloc_rnd(team, cards, st, r, es, rr, tl):
    rng = random.Random("%s:%d:%.9f:%d:%d" % (CFG.rkey, CTX[0], st.t, r, len(es)))
    left_slots = {x[1]: x[3] for x in rr}
    take = {}
    pool = list(es)
    rng.shuffle(pool)
    for pi in pool:
        opts = [x for x in rr if left_slots[x[1]] > 0 and eligible(team, pi, cards[x[1]], x[2])]
        if opts:
            x = opts[rng.randrange(len(opts))]
            take.setdefault(x[1], []).append(pi)
            left_slots[x[1]] -= 1
    return take


def _alloc_manual(team, cards, st, r, es, rr, tl):
    pref = team.pref
    byid = {cards[x[1]].id: x for x in rr}
    left_slots = {x[1]: x[3] for x in rr}
    take = {}
    for pi in sorted(es, key=lambda i: team.ids[i]):
        lst = pref.get(team.ids[pi], ())
        for cid in lst:
            x = byid.get(cid)
            if x is None or left_slots[x[1]] <= 0 or not eligible(team, pi, cards[x[1]], x[2]):
                continue
            take.setdefault(x[1], []).append(pi)
            left_slots[x[1]] -= 1
            break
    return take


def assign_e(team, cards, st, front, aud, alog):
    """assign_k4'un iskeleti (kim hangi satira girer) + tarifin satir ici dagitimi."""
    free = st.free
    if not free:
        return
    t = st.t
    k, sw = CTX
    crews, opened = st.crews, st.opened
    if CFG.stick and t == 0.0 and not any(crews.values()):
        _reseat(team, cards, st)
        if not free:
            _keep(team, cards, crews)
            return
    rows = ([], [], [])
    slots = [0, 0, 0]
    for ci, c in enumerate(cards):
        ph = c.phase()
        if ph >= 4 or opened[ci] > t + 1e-12:
            continue
        cr = crews.get(ci)
        sl = c.kadro[ph] - (len(cr) if cr else 0)
        if sl > 0:
            r = ROW[ph]
            rows[r].append([D.card_key(c, ph), ci, ph, sl, len(cr) if cr else 0])
            slots[r] += sl
    if not (slots[0] or slots[1] or slots[2]):
        _keep(team, cards, crews)
        return
    rowpos = [None, None, None]
    for r in (0, 1, 2):
        if rows[r]:
            rowpos[r] = min(D.plan_key(cards[x[1]]) for x in rows[r])
    fset = set(free)
    ent = ([], [], [])
    got = set()
    for cls, pi, rws in team.pgroups:
        if pi in got or pi not in fset:
            continue
        r = -1
        for rr_ in rws:
            if len(ent[rr_]) < slots[rr_] and (r < 0 or rowpos[rr_] < rowpos[r]) and any(eligible(team, pi, cards[x[1]], x[2]) for x in rows[rr_]):
                r = rr_
        if r < 0:
            continue
        if cls == 3:
            fk = team.front[pi]
            if D.UNFITCOND and fk is not None and front[fk]:
                continue
        ent[r].append(pi)
        got.add(pi)
    tl = sw - (k + t)
    for r in (0, 1, 2):
        es = ent[r]
        if not es:
            continue
        rr = rows[r]
        if CFG.assign in ("erdem", "rev"):
            take = _alloc_erdem(team, cards, st, r, es, rr, tl)
        elif CFG.assign == "rnd":
            take = _alloc_rnd(team, cards, st, r, es, rr, tl)
        else:
            take = _alloc_manual(team, cards, st, r, es, rr, tl)
        placed = []
        for ci, pis in take.items():
            for pi in pis:
                crews.setdefault(ci, []).append(pi)
                free.remove(pi)
                if team.cls[pi][r] == 3:
                    st.unfit.add(pi)
                placed.append((team.ids[pi], cards[ci].id))
        if alog is not None and placed:
            alog.append((round(t, 9), r, tuple(placed)))
    _keep(team, cards, crews)


def _keep(team, cards, crews):
    for ci, cr in crews.items():
        if cr:
            c = cards[ci]
            c.keep_ph = c.phase()
            c.keep = tuple(team.ids[pi] for pi in cr)


def assign_dispatch(team, cards, st, front, aud, alog):
    """k4 (D0s) ya da tarif; kapali kartlar (hazirliksiz, Gelistirme) atama boyunca 'acilmamis' sayilir."""
    k = CTX[0]
    masked = []
    if CFG.gate and team.pm_order:
        for ci, c in enumerate(cards):
            if is_gated(team, c, k, st.t):
                masked.append((ci, st.opened[ci]))
                st.opened[ci] = INF
    if CFG.assign == "k4":
        D.assign_k4(team, cards, st, front, aud, alog)
    else:
        assign_e(team, cards, st, front, aud, alog)
    for ci, o in masked:
        st.opened[ci] = o


# ------------------------------------------------------------------ bosluk nedeni (kisi basina, her aralikta)
DREASONS = ("kart_yok", "uyan_is_yok", "gereksinim", "hazirlik", "kadro", "kural")
_MAP = {"kart_yok": "kart_yok", "uyan_is_yok": "rol_uymuyor", "gereksinim": "asama_dolu", "hazirlik": "asama_dolu", "kadro": "asama_dolu", "kural": "asama_dolu"}


def why_free(team, cards, st, pi, k):
    t = st.t
    fit = [r for r in range(3) if team.cls[pi][r] is not None]
    unfinished = False
    cand = []
    for ci, c in enumerate(cards):
        ph = c.phase()
        if ph >= 4:
            continue
        unfinished = True
        if st.opened[ci] <= t + 1e-12 and ROW[ph] in fit:
            cand.append((ci, ph, c))
    if not unfinished:
        return "kart_yok"
    if not cand:
        return "uyan_is_yok"
    inel = gat = False
    anyopen = False
    for ci, ph, c in cand:
        cr = st.crews.get(ci)
        if c.kadro[ph] - (len(cr) if cr else 0) <= 0:
            continue
        if is_gated(team, c, k, t):
            gat = True
            continue
        if not eligible(team, pi, c, ph):
            inel = True
            continue
        anyopen = True
    if anyopen:
        return "kural"
    if inel:
        return "gereksinim"
    if gat:
        return "hazirlik"
    return "kadro"


# ------------------------------------------------------------------ week3 = D.week2 + kancalar
def week3(team, cards, st, seed, k, sw, off, ahead=(), prepq=(), logit=True, watch=None, track=False, puller=None, aud=None,
          probe=False, front=(False, False), alog=None):
    rate = team.rate
    crews, opened = st.crews, st.opened
    wprog = sum(watch.prog) if watch is not None else 0.0
    CTX[0], CTX[1] = k, sw
    gated = bool(CFG.gate and team.pm_order)
    if gated:
        gate_schedule(team, cards, st, k, sw)
    fr2 = [dict.fromkeys(DREASONS, 0.0) for _ in range(team.n)] if track else None
    wl = {} if (track and not probe) else None
    wstart = None
    for _ in range(200000):
        assign_dispatch(team, cards, st, front, aud, alog)
        if puller is not None and st.free and not probe:
            c = puller.pull(team, cards, st, k, front)
            if c is not None:
                c.pos = len(cards)
                cards.append(c)
                opened.append(st.t)
                continue
        t = st.t
        if wl is not None and wstart is None:
            wstart = {team.ids[pi]: cards[ci].id for ci, crew in crews.items() for pi in crew}
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
        if gated:
            for c in cards:
                gt = getattr(c, "gate_t", INF) - k
                if t + 1e-12 < gt < nxt and c.kind == "feature" and c.phase() == 1:
                    nxt = gt
        dt = nxt - t
        if track and st.free and dt > 0:
            for pi in st.free:
                fr2[pi][why_free(team, cards, st, pi, k)] += dt
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
                    if not probe and team.p[pi].role == "founder":
                        team.fwork[ph] += w
                st.busy[pi] += dt
                if wl is not None:
                    key = (pi, ci)
                    e = wl.get(key)
                    if e is None:
                        wl[key] = [dt, ph]
                    else:
                        e[0] += dt
                        e[1] = ph
            if c.need[ph] - c.prog[ph] <= EPS:
                c.prog[ph] = c.need[ph]
                st.free.extend(crew)
                crews[ci] = []
                opened[ci] = nxt
                if ph == 2:
                    D.on_test_done(c, team, seed, aud)
                if c.phase() == 4:
                    c.done_at = off + nxt
        st.t = nxt
        if watch is not None and sum(watch.prog) - wprog > EPS:
            return 0.0, st.unfit, None
        if st.t >= 1.0 - 1e-9:
            break
    if probe:
        return None
    if wl is not None:
        WSE.append((off, k, wstart or {}, {team.ids[pi]: cards[ci].id for ci, crew in crews.items() for pi in crew}))
    left = [max(0.0, 1.0 - b) for b in st.busy]
    prep_generic(team, prepq, left, k, sw, CFG.pm)
    for c in ahead:
        while c.need[0] - c.prog[0] > EPS:
            pick = None
            for pi in team.des_order:
                if left[pi] > EPS:
                    pick = pi
                    break
            if pick is None:
                break
            dr = rate[pick][0]
            w = min(c.need[0] - c.prog[0], left[pick] * dr)
            c.prog[0] += w
            left[pick] -= w / dr
    why = None
    if track:
        why = dict.fromkeys(D.REASONS, 0.0)
        det = off >= LO and not probe
        pmset = set(team.pm_order)
        for pi in range(team.n):
            if left[pi] <= EPS:
                continue
            if pi in pmset:
                why["hazirlik_yok"] += left[pi]
                if det:
                    DETAIL["pm_bosta"] = DETAIL.get("pm_bosta", 0.0) + left[pi]
                continue
            tot = sum(fr2[pi].values())
            if tot <= EPS:
                why["kart_yok"] += left[pi]
                if det:
                    DETAIL["kart_yok"] = DETAIL.get("kart_yok", 0.0) + left[pi]
                continue
            for kk, v in fr2[pi].items():
                x = left[pi] * v / tot
                why[_MAP[kk]] += x
                if det:
                    DETAIL[kk] = DETAIL.get(kk, 0.0) + x
        if wl is not None:
            best = {}
            for (pi, ci), (dt_, ph) in wl.items():
                if pi not in best or dt_ > best[pi][0]:
                    best[pi] = (dt_, ci, ph)
            for pi, (dt_, ci, ph) in best.items():
                WLOG.append((off, k, team.ids[pi], cards[ci].id, dt_, 1 if cards[ci].phase() == ph else 0))
    return sum(left), st.unfit, why


# ------------------------------------------------------------------ ustalik aramasi
def frac3(c):
    tot = sum(c.need[:3])
    return sum(c.prog[:3]) / tot if tot > 0 else 0.0


def exp_bugs(team, c):
    """O ana kadarki ise gore beklenen dogan ve kacan hata (rastgele cekimi degil beklenen deger: ustalik aramasi hata zarini kollamasin)."""
    eng = {k: v[1] for k, v in c.log.items() if v[1] > 0}
    tot = sum(eng.values())
    if tot <= 0 or c.need[1] <= 0:
        return 0.0, 0.0
    q = sum(w * team.p[k].build_q() for k, w in eng.items()) / tot
    h = D.H0 * c.size * D.KIND_H[c.kind] * (1.0 - c.hcut) * q * min(1.0, c.prog[1] / c.need[1])
    cov = 0.0
    if c.t0 > EPS:
        for k, v in c.log.items():
            if v[2] > 0:
                cc_ = team.p[k].catch()
                if v[1] > 0:
                    cc_ *= D.SELF_TEST
                cov += v[2] / c.t0 * cc_
    return h, h * (1.0 - min(1.0, cov))


def sprint_score(team, cc, c0):
    """Sprintte yapilan net is: aşama ilerlemesi (kart buyuklugu cinsinden, kismi ilerleme tam sayilir: teslim zamani degil is korunur)
    eksi dogan hatalarin duzeltme maliyeti (2 puan / hata) ve kacan hatalarin ikinci bedeli (2 puan / hata)."""
    v = 0.0
    for i, c in enumerate(cc):
        if c.kind != "feature":
            continue
        z = c0[i] if i < len(c0) else None
        h1, e1 = exp_bugs(team, c)
        h0, e0 = exp_bugs(team, z) if z is not None else (0.0, 0.0)
        v += c.size * (frac3(c) - (frac3(z) if z is not None else 0.0)) - 2.0 * (h1 - h0) - 2.0 * (e1 - e0)
    return v


def sprint_score1(team, cc, c0):
    """Ustalik olcusu 1 (teslim agirlikli): sprintte bitirilen kartin buyuklugu + yarim kartin 0,5 x ilerlemesi - 3 x beklenen kacan hata."""
    v = 0.0
    for i, c in enumerate(cc):
        if c.kind != "feature":
            continue
        z = c0[i] if i < len(c0) else None
        f0 = frac3(z) if z is not None else 0.0
        v += c.size * (1.0 - f0 if c.phase() == 4 else 0.5 * (frac3(c) - f0)) - 3.0 * (exp_bugs(team, c)[1] - (exp_bugs(team, z)[1] if z is not None else 0.0))
    return v


class A3Sim(D.Sim):
    def __init__(self, people, seed, **kw):
        ARZ_L[0] = 12 if kw.get("arz", "sinirsiz") == "sinirsiz" else 9
        super().__init__(people, seed, **kw)
        self.plan_log = []
        self.warned = 0
        self.warn_swaps = 0
        self.master_stats = {"sprints": 0, "gain_e": 0.0, "gain_r": 0.0, "evals": 0, "manual_best": 0}
        self.base_assign = CFG.assign
        self.wbs = {"dev": {}, "test": {}}

    def plan2(self, cell, w):
        cell.team.pref = None
        CFG.assign = self.base_assign
        r = super().plan2(cell, w)
        team = cell.team
        load, rowl, flr, req = D.load_of(cell.cards)
        if CFG.warn > 0:
            self._warn_swap(cell, w)
            load, rowl, flr, req = D.load_of(cell.cards)
        self.plan_log.append({"w": w, "load": load, "rowl": list(rowl), "pcap": list(team.pcap), "cap": team.cap, "n": team.n, "ncards": len(cell.cards)})
        return r

    def close(self, start_w, w, *a):
        """Teslim edilen kartlarin isini yildiza gore topla (kalite aciklamasi): Gelistirme isi yazilim, Test isi test yildizina yazilir."""
        for cell in self.cells:
            for c in cell.cards:
                if c.kind == "feature" and c.phase() == 4 and start_w >= LO:
                    for pi, v in c.log.items():
                        p = cell.team.p[pi]
                        if v[1] > 0:
                            k = p.sk.get("eng", 0) / 2.0
                            self.wbs["dev"][k] = self.wbs["dev"].get(k, 0.0) + v[1]
                        if v[2] > 0:
                            k = p.sk.get("qa", 0) / 2.0
                            self.wbs["test"][k] = self.wbs["test"].get(k, 0.0) + v[2]
        return super().close(start_w, w, *a)

    # --- "uyariyi dinleyen oyuncu": en yuklu satir esigi asarsa o satiri en cok yukleyen yeni karti cikarir, o satirda en az yukleyen adayi alir
    def _warn_swap(self, cell, w):
        team = cell.team
        load, rowl, flr, req = D.load_of(cell.cards)
        ratios = [rowl[i] / team.pcap[i] if team.pcap[i] else 0.0 for i in range(3)]
        wr = max(range(3), key=lambda i: ratios[i])
        if ratios[wr] <= CFG.warn:
            return
        self.warned += 1
        cands = [c for c in cell.cards if c.kind == "feature" and c.enter is None and not c.promise and c.src != "req" and sum(c.prog) <= EPS]
        if not cands:
            return
        out = max(cands, key=lambda c: (c.row_left()[wr], c.pos))
        pool = [c for c in cell.pullq if c.kind == "feature" and not c.promise]
        base = [c for c in cell.cards if c is not out]
        for cand in sorted(pool, key=lambda c: (c.row_left()[wr], c.seq))[:12]:
            if cand.row_left()[wr] >= out.row_left()[wr]:
                break
            trial = cand.clone()
            trial.fix_start()
            ok, _ = self._admit(cell, base, trial)
            if not ok:
                continue
            cell.cards = base
            if out.src != "fix":
                self.cands.insert(0, out)
            if cand in self.cands:
                self.cands.remove(cand)
            cand.fix_start()
            cand.pos = len(cell.cards)
            cell.cards.append(cand)
            cell.pullq = [c for c in cell.pullq if c is not cand]
            for i, c in enumerate(cell.cards):
                c.pos = i
            self.warn_swaps += 1
            return

    # --- tahmin = sonuc; ustalik kolunda atama burada aranir
    def _play(self, cell, want_log=False):
        mp = {}

        def cl(c):
            if c.id not in mp:
                mp[c.id] = c.clone()
            return mp[c.id]
        cc = [cl(c) for c in cell.cards]
        aa = [cl(c) for c in cell.ahead]
        pp = [cl(c) for c in cell.prepq]
        pq = [cl(c) for c in cell.pullq]
        pull = D.Puller(self, cell, pq, None) if D.PULL else None
        mor, fw = list(cell.team.morale), list(cell.team.fwork)
        alog = [] if want_log else None
        for k in range(cell.sw):
            week3(cell.team, cc, D.WSt(cell.team.n, len(cc)), self.seed, k, cell.sw, k, aa, pp, True, None, False, pull, None, False,
                  self._front(aa, pp), alog)
            if D.EARLY and all(c.phase() == 4 for c in cc):
                break
        cell.team.morale = mor
        cell.team.fwork = fw
        return cc, alog

    def _val(self, cell, pref, mode):
        saved = (CFG.assign, cell.team.pref)
        CFG.assign, cell.team.pref = mode, pref
        try:
            cc, _ = self._play(cell)
        finally:
            CFG.assign, cell.team.pref = saved
        self.master_stats["evals"] += 1
        return (sprint_score1 if CFG.mobj == 1 else sprint_score)(cell.team, cc, cell.cards)

    def predict2(self, cell):
        cc = self._master(cell) if CFG.master else super().predict2(cell)
        pl = [0.0, 0.0, 0.0]
        for c in cc:
            if c.phase() < 4:
                for i, v in enumerate(c.row_left()):
                    pl[i] += v
        self.plan_log[-1]["pred_left"] = pl
        return cc

    def _master(self, cell):
        """Ustalik: sprint basina, eldeki plan icin kisi -> kart tercih listeleri uzerinde rastgele yeniden baslamali tepe tirmanma.
        Baslangic: tarifin kendi izi; sonuc, tarifin ve R'nin otomatik atamasindan kotu olamaz (hepsi ayni planda, ayni kesin tahminle sinanir)."""
        team = cell.team
        rng = random.Random("%s:master:%d" % (self.seed, self.sidx))
        v_e = self._val(cell, None, "erdem")
        v_r = self._val(cell, None, "k4")
        saved = CFG.assign
        CFG.assign = "erdem"
        _, alog = self._play(cell, True)
        CFG.assign = saved
        order = {}
        for (_, _, pl) in alog:
            for pid, cid in pl:
                lst = order.setdefault(pid, [])
                if cid not in lst:
                    lst.append(cid)
        allc = [c.id for c in sorted(cell.cards, key=lambda c: c.pos)]
        aset = set(allc)
        best = {}
        for p in team.ids:
            lst = [x for x in order.get(p, []) if x in aset]
            best[p] = tuple(lst + [x for x in allc if x not in lst])
        vb = self._val(cell, best, "manual")
        pool = list(team.ids)
        for it in range(CFG.mit):
            cand = dict(best)
            mv = rng.random()
            if mv < 0.45:
                p = pool[rng.randrange(len(pool))]
                lst = list(cand[p])
                j = rng.randrange(len(lst))
                lst.insert(0, lst.pop(j))
                cand[p] = tuple(lst)
            elif mv < 0.8 and len(pool) > 1:
                a, b = rng.sample(pool, 2)
                la, lb = list(cand[a]), list(cand[b])
                ca, cb = la[rng.randrange(min(3, len(la)))], lb[rng.randrange(min(3, len(lb)))]
                la.insert(0, la.pop(la.index(cb)))
                lb.insert(0, lb.pop(lb.index(ca)))
                cand[a], cand[b] = tuple(la), tuple(lb)
            else:
                p = pool[rng.randrange(len(pool))]
                lst = list(cand[p])
                if len(lst) > 1:
                    i, j = rng.sample(range(len(lst)), 2)
                    lst[i], lst[j] = lst[j], lst[i]
                cand[p] = tuple(lst)
            v = self._val(cell, cand, "manual")
            if v >= vb - 1e-12:
                best, vb = cand, v
        ms = self.master_stats
        ms["sprints"] += 1
        top = max(v_e, v_r, vb)
        if vb >= max(v_e, v_r) - 1e-12:
            team.pref, CFG.assign = best, "manual"
            ms["manual_best"] += 1
        elif v_e >= v_r:
            team.pref, CFG.assign = None, "erdem"
        else:
            team.pref, CFG.assign = None, "k4"
        ms["gain_e"] += top - v_e
        ms["gain_r"] += top - v_r
        return self._play(cell)[0]


# D.week2 -> week3 (D'nin tum cagiranlari global ad uzerinden bulur)
D.week2 = week3
