# A9 (Opus incelemesi): Erdem'in ornegini (A8 iz 1) a8plan/dsim3'u IMPORT ETMEDEN, belgenin §4.1'de anlattigi kuraldan sifirdan kurar.
# Girdiler (hizlar, kadro) a8iz.py'nin kurdugu ekipten okunmus sabitlerdir: Yazilim A 15,4, B ve C 11,6 puan/hf; Test (yan is) A 9,38, B ve C 7,0;
# Yazilim yildizi 4 / 3 / 3; kadro Yazilim = tavan(puan / 8), Test 1; Test 0,5 puan; hata zari kapali; sprint 2 hafta, 4 hafta oynatilir.
# Kural (A8 §4.1, ileri oynatmasiz tek secenek = P_sabit): ufuk, en az kisilik ekip (plan sirasiyla), artanlar plan sirasiyla, "ihtiyac onde" satir secimi,
# "kalir", gereksinim kapisi, yer degisimi.  python -I a9iz1.py [buyuk_puan] [buyuk_sonda]
import sys, math
sys.stdout.reconfigure(encoding="utf-8")
EPS = 1e-9
SW = 2
PPL = [("A", 15.4, 9.38, 4.0), ("B", 11.6, 7.0, 3.0), ("C", 11.6, 7.0, 3.0)]     # ad, Yazilim hizi, Test hizi, Yazilim yildizi
RATE = {1: [p[1] for p in PPL], 2: [p[2] for p in PPL]}
CLS = {1: 0, 2: 2}                                                            # Yazilim asil is (sinif 0), Test yan is (sinif 2)
N = len(PPL)


def mkcards(big, big_last):
    spec = [("Buyuk", big, 2.0), ("Kucuk1", 10.0, 1.0), ("Kucuk2", 10.0, 1.0)]
    if big_last:
        spec = spec[1:] + spec[:1]
    return [dict(name=n, need={1: p, 2: 0.5}, prog={1: 0.0, 2: 0.0}, req={1: rq, 2: 0.0}, kadro={1: max(1, math.ceil(p / 8.0)), 2: 1}, pos=i, done=None)
            for i, (n, p, rq) in enumerate(spec)]


def phase(c):
    for j in (1, 2):
        if c["need"][j] - c["prog"][j] > EPS:
            return j
    return 3


def elig(pi, c, j):
    return j == 2 or PPL[pi][3] >= c["req"][1] - EPS


def t_full(c, j0):
    t = 0.0
    for j in range(j0, 3):
        rem = c["need"][j] - c["prog"][j]
        if rem <= EPS:
            continue
        rs = sorted((RATE[j][pi] for pi in range(N) if elig(pi, c, j)), reverse=True)[:c["kadro"][j]]
        t += rem / sum(rs)
    return t


def horizon_need(c, j, now, cr, beta=1.0):
    """(ufuk sirasi j0, ilk ufuk icin istenen ek hiz). now: sprint icindeki an (hafta)."""
    rem = c["need"][j] - c["prog"][j]
    tot = sum(max(0.0, c["need"][q] - c["prog"][q]) for q in range(j, 3))
    j0 = max(0, int(math.ceil((now + t_full(c, j)) / SW - 1e-9)) - 1)
    return j0, rem, tot


def pick(cands, need, cap, rt):
    """En az kisilik ekip: tek kisi yetiyorsa yetenlerin en zayifi, iki kisi yetiyorsa toplami en kucuk yeten cift, fazlasi: en guclu m-1 + kalani karsilayan en zayif."""
    s, m = 0.0, 0
    for i in range(min(len(cands), cap)):
        s += rt[cands[i]]
        if s >= need - EPS:
            m = i + 1
            break
    if m == 0:
        return None
    if m == 1:
        return [min((p for p in cands if rt[p] >= need - EPS), key=lambda p: (rt[p], -cands.index(p)))]
    if m == 2:
        best = None
        for a in range(len(cands)):
            for b in range(a + 1, len(cands)):
                sm = rt[cands[a]] + rt[cands[b]]
                if sm >= need - EPS and (best is None or sm < best[0] - EPS):
                    best = (sm, [cands[a], cands[b]])
        return best[1]
    sel = cands[:m - 1]
    rest = need - sum(rt[p] for p in sel)
    for p in reversed(cands[m - 1:]):
        if rt[p] >= rest - EPS:
            return sel + [p]
    return cands[:m]


def dispatch(cards, crews, free, now):
    rows = {1: [], 2: []}
    for c in cards:
        j = phase(c)
        if j < 3 and c["kadro"][j] - len(crews[c["name"]]) > 0:
            rows[j].append(c)
    slots = {j: sum(c["kadro"][j] - len(crews[c["name"]]) for c in rows[j]) for j in (1, 2)}
    # eksik hiz (satir secimi icin)
    defi = {}
    for j in (1, 2):
        for c in rows[j]:
            j0, rem, tot = horizon_need(c, j, now, 0)
            ds = max(1e-3, (SW * (1 + j0) - now) * rem / tot)
            defi[c["name"]] = max(0.0, rem / ds * 0.95 - sum(RATE[j][p] for p in crews[c["name"]]))
    groups = sorted([(CLS[j], -RATE[j][pi], pi, j) for pi in range(N) for j in (1, 2)])
    ent = {1: [], 2: []}
    got = set()
    for pas in (0, 1):                                    # ihtiyac onde: once asil satir, sonra yan satir
        for cl, _, pi, j in groups:
            if pi in got or pi not in free or (cl < 2) != (pas == 0) or len(ent[j]) >= slots[j]:
                continue
            um = [c for c in rows[j] if defi[c["name"]] > EPS and elig(pi, c, j)]
            if um:
                c = min(um, key=lambda c: c["pos"])
                defi[c["name"]] -= RATE[j][pi]
                ent[j].append(pi)
                got.add(pi)
    for cl, _, pi, j in groups:                           # kalanlar: plan sirasinda en onde acik satir
        if pi in got or pi not in free or len(ent[j]) >= slots[j] or not any(elig(pi, c, j) for c in rows[j]):
            continue
        ent[j].append(pi)
        got.add(pi)
    for j in (1, 2):
        if not ent[j]:
            continue
        rt = RATE[j]
        pool = sorted(ent[j], key=lambda p: (-rt[p], p))
        sl = {c["name"]: c["kadro"][j] - len(crews[c["name"]]) for c in rows[j]}
        take, tgt, crate = {}, {}, {c["name"]: sum(rt[p] for p in crews[c["name"]]) for c in rows[j]}
        for c in sorted(rows[j], key=lambda c: c["pos"]):      # 1) plan sirasiyla, ufku tutturan en az kisilik ekip
            if not pool:
                break
            j0, rem, tot = horizon_need(c, j, now, 0)
            cands = [p for p in pool if elig(p, c, j)]
            if not cands:
                continue
            for h in range(j0, j0 + 4):
                ds = max(1e-3, (SW * (1 + h) - now) * rem / tot)
                need = rem / ds * 0.95 - crate[c["name"]]
                if need <= EPS:
                    tgt[c["name"]] = rem / ds
                    break
                sel = pick(cands, need, sl[c["name"]], rt)
                if sel is not None:
                    take[c["name"]] = list(sel)
                    sl[c["name"]] -= len(sel)
                    for p in sel:
                        pool.remove(p)
                    crate[c["name"]] += sum(rt[p] for p in sel)
                    tgt[c["name"]] = rem / ds
                    break
        for p in list(pool):                                   # 2) artanlar plan sirasiyla kadro tavanina kadar
            for c in sorted(rows[j], key=lambda c: c["pos"]):
                if sl[c["name"]] > 0 and elig(p, c, j):
                    take.setdefault(c["name"], []).append(p)
                    sl[c["name"]] -= 1
                    crate[c["name"]] += rt[p]
                    pool.remove(p)
                    break
        cx = {c["name"]: (c["need"][1] + c["need"][2]) * max(1.0, c["req"][1]) for c in rows[j]}
        names = sorted(take, key=lambda n: -cx[n])             # 3) yer degisimi: karmasik kart daha iyi kisi, basit kartin hedef hizi bozulmadan
        for _ in range(3):
            moved = False
            for a in range(len(names)):
                for b in range(a + 1, len(names)):
                    X, Y = names[a], names[b]
                    if cx[X] - cx[Y] <= EPS:
                        continue
                    for i, p in enumerate(take[X]):
                        q = next((q for q in take[Y] if rt[q] > rt[p] + EPS), None)
                        if q is not None:
                            newy = crate[Y] - (rt[q] - rt[p])
                            if newy >= min(tgt.get(Y, 0.0), crate[Y]) - EPS:
                                take[X][i] = q
                                take[Y][take[Y].index(q)] = p
                                crate[X] += rt[q] - rt[p]
                                crate[Y] = newy
                                moved = True
                                break
            if not moved:
                break
        for n_, ps in take.items():
            for p in ps:
                crews[n_].append(p)
                free.discard(p)


def run(big=100.0, big_last=False):
    cards = mkcards(big, big_last)
    crews = {c["name"]: [] for c in cards}
    log = {pi: [] for pi in range(N)}
    for wk in range(4):
        t, tend = float(wk), float(wk + 1)
        while t < tend - EPS:
            busy = {p for ps in crews.values() for p in ps}
            free = set(range(N)) - busy
            dispatch(cards, crews, free, t - SW * (wk // SW))
            dt, ends = tend - t, []
            for c in cards:
                ps = crews[c["name"]]
                if ps:
                    j = phase(c)
                    r = sum(RATE[j][p] for p in ps)
                    dt = min(dt, (c["need"][j] - c["prog"][j]) / r)
            for c in cards:
                ps = crews[c["name"]]
                if ps:
                    j = phase(c)
                    for p in ps:
                        log[p].append((t, t + dt, c["name"], j))
                    c["prog"][j] += dt * sum(RATE[j][p] for p in ps)
                    if c["need"][j] - c["prog"][j] <= 1e-7:
                        c["prog"][j] = c["need"][j]
                        crews[c["name"]] = []                  # asama bitti: ekip bosalir ("kalir" asama bitene kadar)
                        if phase(c) == 3:
                            c["done"] = t + dt
            for p in range(N):
                if not any(p in ps for ps in crews.values()) and not (log[p] and abs(log[p][-1][1] - (t + dt)) < EPS):
                    log[p].append((t, t + dt, None, None))
            t += dt
    return cards, log


def show(cards, log):
    rown = {1: "Yazilim", 2: "Test"}
    for p in range(N):
        segs = []
        for t0, t1, n, j in log[p]:
            k = "bosta" if n is None else "%s (%s)" % (n, rown[j])
            if segs and segs[-1][2] == k and abs(segs[-1][1] - t0) < 1e-9:
                segs[-1][1] = t1
            else:
                segs.append([t0, t1, k])
        print("  %-2s %s" % (PPL[p][0], "; ".join("h%.2f-h%.2f %s" % (a, b, k) for a, b, k in segs if b - a > 1e-6)))
    print("  Kartlar: " + "; ".join("%s biter h%.3f (sprint %d)" % (c["name"], c["done"], int(c["done"] // SW) + 1) if c["done"] is not None else "%s bitmedi" % c["name"] for c in cards))


if __name__ == "__main__":
    big = float(sys.argv[1]) if len(sys.argv) > 1 else 100.0
    last = len(sys.argv) > 2 and sys.argv[2] == "1"
    print("Bagimsiz kurulum, buyuk kart %.0f puan, %s" % (big, "planda sonda" if last else "planda ilk"))
    show(*run(big, last))
