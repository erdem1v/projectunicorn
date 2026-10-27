# A8 · proaktif ve reaktif sprint planlayicisi ("P"). a3core / hata2 / dsim3 varsayilan davranisini bozmaz: atama kipi "p8" secilmedikce hicbir sey degismez
# (a8test.py regress bunu A3/A6 kayitlariyla dogrular).
#
# Fikir (A8_PROAKTIF_PLAN.md §4):
#   REAKTIF  : bir kisi bosalinca (asama bitince) o anda yeniden dagitim yapilir; her atama aninda ayni kural kosar (alloc_p8).
#   PROAKTIF : her haftanin basinda planlayici, kalan sprinti secenek kuralindan her biri icin ayni motorla ILERI OYNATIR (rollout), plan puanina gore
#              en iyi secenegi secer; secilen secenek o hafta icin gecerlidir. Plan puani: (a) plan sirasindaki kartlari sprintte bitirmek,
#              (b) kimseyi bosta birakmamak, (c) is ilerlemesi; esitlikte ILKE (zor isi en iyiler yapsin).
#   TAHMIN = SONUC: plan oynatmasi (D.Sim.predict2) ile gercek oynatma ayni kodu kosar; ikinci kosuda secimler onbellekten gelir (durum ayniysa), durum
#              sapmissa (ornegin bir kisi plandan yavas) onbellek tutmaz ve plan o an yeniden kurulur.
import os, sys, math, time
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import hata2 as H
A = H.A
D = A.D
CFG2 = H.CFG2
EPS = D.EPS
INF = 1e18
ROW = D.ROW


class P8cfg:
    search = 1          # 1 = hafta basi ileri oynatma ile secenek secimi; 0 = hep DEF
    rho = 0.85          # plan puani: i. siradaki kartin bitmesi rho_eff^i agirlik; rho_eff = rho^min(1, 8/N) (N = plan kart sayisi): ilk 8 siranin toplam dususu planin uzunlugundan bagimsiz
    tol_idle = 0.03     # bosta toleransi (kapasitenin orani); bu farkin altinda "ayni"
    tol_prog = 0.02     # ilerleme toleransi (oran)
    sets = "std"        # secenek kumesi adi
    rowrule = "need"    # birden cok satirda calisabilen kisi: need = ihtiyaci karsilanmamis kartin satirina once (min kipli secenekler); plan = plan sirasindaki en onde acik satir


P8 = P8cfg()

DEF = dict(mode="min", beta=1.0, help="plan", swap=1)
THETA_SETS = {
    "std": [dict(mode="min", beta=1.0, help="plan", swap=1), dict(mode="min", beta=0.7, help="plan", swap=1),
            dict(mode="min", beta=0.45, help="plan", swap=1), dict(mode="cap", help="plan", swap=1), dict(mode="tplan"),
            dict(mode="min", beta=1.0, help="plan", swap=1, sec="hold"), dict(mode="min", beta=0.45, help="plan", swap=1, sec="hold"),
            dict(mode="cap", help="plan", swap=1, sec="hold")],
    "core5": [dict(mode="min", beta=1.0, help="plan", swap=1), dict(mode="min", beta=0.7, help="plan", swap=1),
              dict(mode="min", beta=0.45, help="plan", swap=1), dict(mode="cap", help="plan", swap=1), dict(mode="tplan")],
    "min1": [dict(mode="min", beta=1.0, help="plan", swap=1)],
    "noswap": [dict(mode="min", beta=1.0, help="plan", swap=0)],
    "cap1": [dict(mode="cap", help="plan", swap=1)],
}
LOG = None
CUR = [dict(DEF)]
IN_ROLL = [False]
CACHE = {}
STATS = {"epochs": 0, "hits": 0, "miss": 0, "rollouts": 0, "secs": 0.0, "ev_rollouts": 0, "sprints": 0}


def reset_stats():
    CACHE.clear()
    for k in STATS:
        STATS[k] = 0.0 if k == "secs" else 0


# ------------------------------------------------------------------ kisi/kart bilgisi onbellegi
def _tdata(team):
    d = getattr(team, "_p8", None)
    if d is None:
        d = team._p8 = {"lists": {}}
    return d


def _elig_list(team, row, req, fixst):
    """(row, req) icin: bu asamada calisabilen (sinif 3 degil), yildizi >= req olan kisilerin hizlari, buyukten kucuge + onek toplamlari."""
    d = _tdata(team)
    key = (row, req, fixst)
    v = d["lists"].get(key)
    if v is None:
        st = A.tinfo(team)["stars"]
        rs = sorted((team.rate[pi][row] for pi in range(team.n)
                     if team.cls[pi][row] is not None and team.cls[pi][row] != 3 and team.rate[pi][row] > 0
                     and st[pi][row] >= req - 1e-9 and not (fixst and team.nofix[pi])), reverse=True)
        pre = [0.0]
        for x in rs:
            pre.append(pre[-1] + x)
        v = d["lists"][key] = pre
    return v


def t_full(team, c, ph0):
    """Karti, her asamada kadro tavani kadar en iyi uygun kisiyle (baska is yokmus gibi) bitirmenin en kisa suresi (hafta). Bitmez ise INF."""
    tt = 0.0
    for j in range(ph0, 4):
        if j == 3 and not c.tested:
            continue
        rem = c.need[j] - c.prog[j]
        if rem <= EPS:
            continue
        pre = _elig_list(team, ROW[j], A.creq(team, c, j), j == 3)
        cap = min(len(pre) - 1, c.kadro[j])
        if cap <= 0 or pre[cap] <= 0:
            return INF
        tt += rem / pre[cap]
    return tt


# ------------------------------------------------------------------ kisi secimi (ilke) ve asama boyutlama
def _pick_crew(cands, need, cap, rt):
    """cands: kisi indeksleri, hiza gore buyukten kucuge; hizlari toplami >= need olan EN AZ kisilik ekip. Bir kisi yetiyorsa yetenlerin en zayifi,
    iki kisi yetiyorsa toplami en kucuk yeten cift, daha fazlaysa en guclu m-1 kisi + kalani karsilayan en zayif. Yetmezse None."""
    n = len(cands)
    if n == 0 or cap <= 0:
        return None
    s = 0.0
    m = 0
    for i in range(min(n, cap)):
        s += rt[cands[i]]
        if s >= need - 1e-9:
            m = i + 1
            break
    if m == 0:
        return None
    if m == 1:
        for pi in reversed(cands):
            if rt[pi] >= need - 1e-9:
                return [pi]
    if m == 2:
        lo, hi = n - 1, 0                       # lo: en zayif uc, hi: en guclu uc
        best = None
        while hi < lo:
            sm = rt[cands[hi]] + rt[cands[lo]]
            if sm >= need - 1e-9:
                if best is None or sm < best[0]:
                    best = (sm, hi, lo)
                hi += 1                         # yetiyor: guclu tarafa daha zayif es dene
            else:
                lo -= 1                         # yetmiyor: zayif tarafa daha guclu es dene
        if best is not None:
            return [cands[best[1]], cands[best[2]]]
    sel = list(cands[:m - 1])
    rest = need - sum(rt[pi] for pi in sel)
    for pi in reversed(cands[m - 1:]):
        if rt[pi] >= rest - 1e-9:
            sel.append(pi)
            return sel
    return list(cands[:m])


def _hold_sec(team, cards, st, r, pi):
    """Bu satirda ikincil (sinif >= 2) calisan kisi, asil satirinda (sinif 0) sprintte is bekliyorsa bu satira kilitlenmez ("kalir" kilidi onu o isten alikoyar)."""
    if team.cls[pi][r] is None or team.cls[pi][r] < 2:
        return False
    for q in range(3):
        if q != r and team.cls[pi][q] == 0:
            for c in cards:
                ph = c.phase()
                if ph < 4 and D.ROW[ph] != q and c.need[q] - c.prog[q] > EPS and ph <= q:
                    return True
    return False


def alloc_p8(team, cards, st, r, es, rr, tl):
    """Bir satir, bir atama ani. 1) kartlar PLAN SIRASIYLA, her biri icin: kartin bitebilecegi ilk sprint ufku secilir (bu sprint, olmazsa sonraki...);
    asamanin o ufukta bitmesi icin gereken hiz bulunur; bu hizi tutturan EN AZ kisilik ekip havuzdan alinir (havuz biterse kalan kartlar bekler;
    kisi bosalinca yine bu sirayla dolar). 2) artan kisiler kartlari plan sirasiyla kadro tavanina kadar doldurur (kimse bosta kalmaz).
    3) ILKE: ayni ekip hizini bozmayan yer degisimleriyle daha karmasik kartin ekibi daha iyi kisilerden olur."""
    th = CUR[0]
    if th.get("mode") == "tplan":
        old = CFG2.top1
        CFG2.top1 = "plan"
        try:
            return H.alloc_gen(team, cards, st, r, es, rr, tl)
        finally:
            CFG2.top1 = old
    rate = team.rate
    rt = [rate[pi][r] for pi in range(team.n)]
    ids = team.ids
    stars = A.tinfo(team)["stars"]
    k, sw = A.CTX
    now = k + st.t
    beta = th.get("beta", 1.0)
    X = sorted(rr, key=lambda x: (cards[x[1]].pos, cards[x[1]].id))
    pool = sorted(es, key=lambda pi: (-rt[pi], ids[pi]))
    if th.get("sec") == "hold":
        pool = [pi for pi in pool if not _hold_sec(team, cards, st, r, pi)]
    elif th.get("sec") == "prim":
        sp = _tdata(team).setdefault("spec", {})
        if r not in sp:
            sp[r] = any(team.cls[q][r] == 0 for q in range(team.n))
        if sp[r]:
            pool = [pi for pi in pool if team.cls[pi][r] == 0]
    take = {}
    slots = {x[1]: x[3] for x in rr}
    info = {}
    for x in X:
        ci, ph = x[1], x[2]
        c = cards[ci]
        rq = A.creq(team, c, ph)
        rem = c.need[ph] - c.prog[ph]
        tot = 0.0
        for j in range(ph, 4):
            v = c.need[j] - c.prog[j]
            if v > 0:
                tot += v
        cr = 0.0
        for pi in (st.crews.get(ci) or ()):
            cr += rt[pi]
        info[ci] = [c, ph, rq, rem, tot, cr, c.size * max(1.0, rq), None]
    # 1) plan sirasiyla en az kisilik ekip (mode=cap: kadro tavanina kadar, en guclu uygun kisiler)
    for x in (X if th.get("mode") != "cap" else ()):
        ci = x[1]
        c, ph, rq, rem, tot, cr, kx, _ = info[ci]
        if not pool:
            break
        if rem <= EPS or slots[ci] <= 0:
            continue
        tf = t_full(team, c, ph)
        if tf >= INF:
            j0 = 0
        else:
            j0 = max(0, int(math.ceil((now + tf) / sw - 1e-9)) - 1)
        cands = [pi for pi in pool if stars[pi][r] >= rq - 1e-9 and team.cls[pi][r] != 3 and not (ph == 3 and team.nofix[pi])]
        if not cands:
            continue
        for j in range(j0, j0 + 4):
            dd = sw * (1 + j) - now
            bj = beta if j == 0 else 1.0
            ds = max(1e-3, bj * dd * rem / tot) if tot > 0 else dd
            need = rem / ds * 0.95 - cr                          # %5 pay: kisi sayisi bir tutam eksikle bir fazlaya sicramasin
            if need <= 1e-9:
                info[ci][7] = rem / ds
                break
            sel = _pick_crew(cands, need, slots[ci], rt)
            if sel is not None:
                take[ci] = list(sel)
                slots[ci] -= len(sel)
                for pi in sel:
                    pool.remove(pi)
                info[ci][5] = cr + sum(rt[pi] for pi in sel)
                info[ci][7] = rem / ds
                break
        else:
            info[ci][7] = None
    # 2) artan kisiler: plan sirasiyla kadro tavanina kadar (kimse bosta kalmasin); mode=cap'te tum havuz bu adimdan gecer
    if pool:
        left = list(pool)
        if th.get("help", "plan") == "late":
            order = sorted(X, key=lambda x: -(max(info[x[1]][3], 0.0) / max(info[x[1]][5], 1e-9)))
        else:
            order = X
        for pi in left:
            for x in order:
                ci = x[1]
                c, ph, rq, rem, tot, cr, kx, _ = info[ci]
                if slots[ci] > 0 and rem > EPS and stars[pi][r] >= rq - 1e-9 and not (ph == 3 and team.nofix[pi]) and team.cls[pi][r] != 3:
                    take.setdefault(ci, []).append(pi)
                    slots[ci] -= 1
                    info[ci][5] += rt[pi]
                    pool.remove(pi)
                    break
        # sinif 3 (uymayan is) yalniz baska hicbir is bulamayan kisiye
        for pi in list(pool):
            for x in X:
                ci = x[1]
                c, ph, rq, rem, tot, cr, kx, _ = info[ci]
                if slots[ci] > 0 and rem > EPS and stars[pi][r] >= rq - 1e-9 and not (ph == 3 and team.nofix[pi]):
                    take.setdefault(ci, []).append(pi)
                    slots[ci] -= 1
                    info[ci][5] += rt[pi]
                    pool.remove(pi)
                    break
    # 3) ilke: plan hizini bozmayan yer degisimleri
    if th.get("swap", 1) and len(take) >= 2:
        order = sorted(take, key=lambda ci: -info[ci][6])
        for _pass in range(3):
            moved = False
            for ia in range(len(order)):
                cx = order[ia]
                for ib in range(ia + 1, len(order)):
                    cy = order[ib]
                    if info[cx][6] - info[cy][6] <= 1e-9:
                        continue
                    tgt_y = info[cy][7]
                    for i, p in enumerate(take[cx]):
                        for j, q in enumerate(take[cy]):
                            if rt[q] > rt[p] + 1e-9 and stars[q][r] >= info[cx][2] - 1e-9 and stars[p][r] >= info[cy][2] - 1e-9:
                                dx = rt[q] - rt[p]
                                newy = info[cy][5] - dx
                                floor_y = min(tgt_y, info[cy][5]) if tgt_y is not None else 0.0
                                if newy >= floor_y - 1e-9:
                                    take[cx][i], take[cy][j] = q, p
                                    info[cx][5] += dx
                                    info[cy][5] = newy
                                    moved = True
                                    break
                        else:
                            continue
                        break
            if not moved:
                break
    return take


# ------------------------------------------------------------------ atama: assign_e'nin kopyasi, yalniz satir ici dagitim alloc_p8
_orig_assign_e = A.assign_e


def _deficits(team, cards, st, rows, now, sw, beta):
    """Her acik kartin bu asamasinda, ufkunu tutturmak icin ekibin hizina eklenmesi gereken hiz (satir secimi icin; havuz kisiti yok)."""
    rate = team.rate
    out = {}
    for r in (0, 1, 2):
        for x in rows[r]:
            ci, ph = x[1], x[2]
            c = cards[ci]
            rem = c.need[ph] - c.prog[ph]
            if rem <= EPS:
                continue
            tot = 0.0
            for j in range(ph, 4):
                v = c.need[j] - c.prog[j]
                if v > 0:
                    tot += v
            tf = t_full(team, c, ph)
            j0 = 0 if tf >= INF else max(0, int(math.ceil((now + tf) / sw - 1e-9)) - 1)
            dd = sw * (1 + j0) - now
            ds = max(1e-3, (beta if j0 == 0 else 1.0) * dd * rem / tot) if tot > 0 else dd
            cr = 0.0
            for pi in (st.crews.get(ci) or ()):
                cr += rate[pi][r]
            out[ci] = max(0.0, rem / ds * 0.95 - cr)
    return out


def assign_e8(team, cards, st, front, aud, alog):
    if A.CFG.assign != "p8":
        return _orig_assign_e(team, cards, st, front, aud, alog)
    free = st.free
    if not free:
        return
    t = st.t
    k, sw = A.CTX
    crews, opened = st.crews, st.opened
    if A.CFG.stick and t == 0.0 and not any(crews.values()):
        A._reseat(team, cards, st)
        if not free:
            A._keep(team, cards, crews)
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
            r = D.ROW[ph]
            rows[r].append([D.card_key(c, ph), ci, ph, sl, len(cr) if cr else 0])
            slots[r] += sl
    if not (slots[0] or slots[1] or slots[2]):
        A._keep(team, cards, crews)
        return
    rowpos = [None, None, None]
    for r in (0, 1, 2):
        if rows[r]:
            rowpos[r] = min(D.plan_key(cards[x[1]]) for x in rows[r])
    need_rule = P8.rowrule == "need" and CUR[0].get("mode") == "min"
    defi = _deficits(team, cards, st, rows, k + t, sw, CUR[0].get("beta", 1.0)) if need_rule else None
    rate = team.rate
    fset = set(free)
    ent = ([], [], [])
    got = set()
    if need_rule:
        # ihtiyac onde: asil rolu (sinif 0, kurucu 1) olan kisi once ihtiyaci karsilanmamis kartlarin satirina girer; ikincil satirdaki (sinif 2) ihtiyac sonra;
        # kalanlar eski kuralla (plan sirasindaki en onde acik satir) doldurur. Boylece "herkes buyuk kartin yazilimina yigildi, biten kartin testini yapan yok" olmaz.
        for pas in (0, 1):
            for cls, pi, rws in team.pgroups:
                if pi in got or pi not in fset:
                    continue
                best = None
                for rr_ in range(3):
                    c_ = team.cls[pi][rr_]
                    if c_ is None or c_ == 3 or (c_ < 2) != (pas == 0) or len(ent[rr_]) >= slots[rr_]:
                        continue
                    um = [x for x in rows[rr_] if defi.get(x[1], 0.0) > 1e-9 and A.eligible(team, pi, cards[x[1]], x[2])]
                    if um:
                        key = min(D.plan_key(cards[x[1]]) for x in um)
                        if best is None or key < best[0]:
                            best = (key, rr_, um)
                if best is not None:
                    xx = min(best[2], key=lambda x: D.plan_key(cards[x[1]]))
                    defi[xx[1]] -= rate[pi][best[1]]
                    ent[best[1]].append(pi)
                    got.add(pi)
    for cls, pi, rws in team.pgroups:
        if pi in got or pi not in fset:
            continue
        r = -1
        for rr_ in rws:
            if len(ent[rr_]) < slots[rr_] and (r < 0 or rowpos[rr_] < rowpos[r]) and any(A.eligible(team, pi, cards[x[1]], x[2]) for x in rows[rr_]):
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
        take = alloc_p8(team, cards, st, r, es, rows[r], tl)
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
    A._keep(team, cards, crews)


A.assign_e = assign_e8


# ------------------------------------------------------------------ ileri oynatma (rollout) ve plan puani
_w3 = A.week3


def _front(ahead, prepq):
    return (any(c.kind == "feature" and c.prep < c.prep_need() - EPS for c in prepq),
            any(c.need[0] - c.prog[0] > EPS for c in ahead))


def rollout(team, cards, ahead, prepq, puller, seed, k0, sw, th):
    """Mevcut hafta basindan sprint sonuna ayni motorla oynatir (th secenegi sabit); kopya kartlar ve haftalik WSt'ler doner."""
    mp = {}

    def cl(c):
        if c.id not in mp:
            mp[c.id] = c.clone()
        return mp[c.id]
    cc = [cl(c) for c in cards]
    aa = [cl(c) for c in ahead]
    pp = [cl(c) for c in prepq]
    pull = D.Puller(puller.sim, puller.cell, [cl(c) for c in puller.q], None) if puller is not None else None
    mor, fw = list(team.morale), list(team.fwork)
    save = CUR[0]
    CUR[0] = th
    IN_ROLL[0] = True
    sts = []
    try:
        for kk in range(k0, sw):
            st = D.WSt(team.n, len(cc))
            sts.append(st)
            _w3(team, cc, st, seed, kk, sw, kk, aa, pp, True, None, False, pull, None, False, _front(aa, pp), None)
    finally:
        IN_ROLL[0] = False
        CUR[0] = save
        team.morale, team.fwork = mor, fw
    return cc, sts


def plan_score(team, before, after, sts, nonpm, reff):
    """before: {kart kimligi: (ilerleme toplami, kalan is, log kopyasi)}; after: rollout sonu kart kopyalari."""
    F = 0.0
    prog = 0.0
    pr = 0.0
    stars = A.tinfo(team)["stars"]
    for c in after:
        b = before.get(c.id)
        w = reff ** c.pos
        if c.phase() == 4 and c.kind == "feature":
            F += w
        elif c.phase() == 4:
            F += w * 0.5
        rem0 = b[1] if b else c.remaining() + sum(c.prog)
        if rem0 > EPS:
            gain = sum(c.prog) - (b[0] if b else 0.0)
            prog += w * min(1.0, gain / rem0)
        lg0 = b[2] if b else {}
        kx = c.size * max(1.0, A.creq(team, c, 1))
        for pi, v in c.log.items():
            v0 = lg0.get(pi, (0.0, 0.0, 0.0, 0.0))
            for j in range(3):
                dw = v[j] - v0[j]
                if dw > 0:
                    pr += dw * kx * stars[pi][D.ROW[j]]
    idle = 0.0
    for st in sts:
        for pi in nonpm:
            idle += max(0.0, 1.0 - st.busy[pi])
    return dict(F=F, idle=idle, prog=prog, pr=pr)


def select(results, ncap):
    """Asamali suzme: en yuksek F -> en az bosta (tolerans) -> en cok ilerleme (tolerans) -> en yuksek ilke puani."""
    bestF = max(r[1]["F"] for r in results)
    c1 = [r for r in results if r[1]["F"] >= bestF - 1e-9]
    mi = min(r[1]["idle"] for r in c1)
    c2 = [r for r in c1 if r[1]["idle"] <= mi + P8.tol_idle * ncap + 1e-9]
    mp = max(r[1]["prog"] for r in c2)
    c3 = [r for r in c2 if r[1]["prog"] >= mp * (1.0 - P8.tol_prog) - 1e-9]
    return max(c3, key=lambda r: (r[1]["pr"], -results.index(r)))[0]


def _worse(a, b, ncap):
    """a, b'den plan puaninda (F, bosta, ilerleme sirasiyla, toleransla) gercekten kotu mu? Esitlikte ilkeyi (swap) koruruz."""
    if abs(a["F"] - b["F"]) > 1e-9:
        return a["F"] < b["F"]
    if abs(a["idle"] - b["idle"]) > P8.tol_idle * ncap:
        return a["idle"] > b["idle"]
    if abs(a["prog"] - b["prog"]) > P8.tol_prog * max(a["prog"], b["prog"], 1e-9):
        return a["prog"] < b["prog"]
    return False


def _sig(team, cards, ahead, prepq, puller):
    parts = [tuple(round(x, 9) for row in team.rate for x in row)]
    for c in cards:
        parts.append((c.id, round(c.prog[0], 7), round(c.prog[1], 7), round(c.prog[2], 7), round(c.prog[3], 7), round(c.need[3], 7), c.tested, getattr(c, "keep", None)))
    parts.append(tuple(c.id for c in (puller.q if puller is not None else ())))
    parts.append(tuple((c.id, round(c.prep, 7), round(c.prog[0], 7)) for c in list(ahead) + list(prepq)))
    return hash(tuple(parts))


def decide(team, cards, ahead, prepq, puller, seed, k, sw):
    key = (seed, k, team.n, _sig(team, cards, ahead, prepq, puller))
    th = CACHE.get(key)
    STATS["epochs"] += 1
    if th is not None:
        STATS["hits"] += 1
        return th
    STATS["miss"] += 1
    ths = THETA_SETS[P8.sets]
    pm_ = set(team.pm_order)
    if len(ths) == 1 or not any(c.phase() < 4 for c in cards) or sum(1 for pi in range(team.n) if pi not in pm_) < 2:
        th = ths[0]
    else:
        t0 = time.perf_counter()
        before = {c.id: (sum(c.prog), c.remaining(), {pi: tuple(v) for pi, v in c.log.items()}) for c in cards}
        pm = set(team.pm_order)
        nonpm = [pi for pi in range(team.n) if pi not in pm]
        res = []
        reff = P8.rho ** min(1.0, 8.0 / max(1, sum(1 for c in cards if c.phase() < 4)))
        ncap = len(nonpm) * (sw - k)
        for t_ in ths:
            cc, sts = rollout(team, cards, ahead, prepq, puller, seed, k, sw, t_)
            STATS["rollouts"] += 1
            res.append((t_, plan_score(team, before, cc, sts, nonpm, reff)))
        th = select(res, ncap)
        if th.get("swap") == 1 and th.get("mode") in ("min", "cap"):
            ns = dict(th, swap=0)
            cc, sts = rollout(team, cards, ahead, prepq, puller, seed, k, sw, ns)
            STATS["rollouts"] += 1
            sc0 = plan_score(team, before, cc, sts, nonpm, reff)
            sc1 = [sc for t_, sc in res if t_ is th][0]
            if _worse(sc1, sc0, ncap):
                th = ns
        if LOG is not None:
            LOG.append((k, [(t_, dict(sc)) for t_, sc in res], th))
        STATS["secs"] += time.perf_counter() - t0
    CACHE[key] = th
    return th


def week8(team, cards, st, seed, k, sw, off, ahead=(), prepq=(), logit=True, watch=None, track=False, puller=None, aud=None,
          probe=False, front=(False, False), alog=None):
    if A.CFG.assign == "p8":
        if probe or IN_ROLL[0] or watch is not None:
            save = CUR[0]
            if probe and not IN_ROLL[0]:
                CUR[0] = DEF
            try:
                return _w3(team, cards, st, seed, k, sw, off, ahead, prepq, logit, watch, track, puller, aud, probe, front, alog)
            finally:
                CUR[0] = save
        if st.t == 0.0:
            CUR[0] = decide(team, cards, ahead, prepq, puller, seed, k, sw) if P8.search else DEF
    return _w3(team, cards, st, seed, k, sw, off, ahead, prepq, logit, watch, track, puller, aud, probe, front, alog)


A.week3 = week8
D.week2 = week8
