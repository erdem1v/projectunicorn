# A6 dogrulama.  python -I a6test.py regress [tohum_sayisi] | micro | tail | pm | bk | pred
#   regress: hata2 yuklu, anahtarlar kapali -> A3'un kayitli sonuclariyla (out/main, out/pr; kollar R ve E) 0 fark
import os, sys, pickle, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a6run as R6
H, A, D, CFG2 = R6.H, R6.A, R6.D, R6.CFG2


def same(a, b):
    if isinstance(a, float) or isinstance(b, float):
        return a is not None and b is not None and abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    if isinstance(a, (list, tuple)):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def regress(nseed=3):
    """A6 koşucusu (hata2 yuklu, anahtarlar kapali: kalibrasyon 0) = A3 kayitlari."""
    bad = tot = 0
    plan = [("main", arm, s) for arm in ("R", "E") for s in ("S1", "S2", "S3", "S4", "S5", "S6")] + [("pr", arm, s) for arm in ("R", "E") for s in ("PR|S2", "PR|S3", "PR|S4")]
    for tag, arm, scen in plan:
        rec = R6.R3.load(R6.R3.fname(tag, arm, scen))
        for sd in range(1, nseed + 1):
            if sd not in rec:
                continue
            _, _, _, _, m = R6.run_task((arm, scen, sd, "0"))
            for k, v in rec[sd].items():
                if k not in R6.KEEP and k not in ("detail", "wkwin", "pm_aud"):
                    continue
                tot += 1
                if not same(m[k], v):
                    bad += 1
                    print("FARK", tag, arm, scen, sd, k, str(m[k])[:60], "|", str(v)[:60])
        print(tag, arm, scen, "tamam", flush=True)
    print("REGRESS metrik=%d fark=%d" % (tot, bad))
    return bad


def mkteam(stars_dev, sw=2, pm=()):
    ppl = [D.Person("d%d" % i, "dev", {"eng": int(round(2 * s)), "qa": max(0, int(round(2 * s)) - 1), "design": 0, "product": 0}) for i, s in enumerate(stars_dev)]
    ppl += [D.Person("pm%d" % i, "pm", {"product": int(round(2 * s)), "design": 0, "qa": 0, "eng": 0}) for i, s in enumerate(pm)]
    return D.Team(ppl, sw), ppl


def mkcard(size=40, tier=3, prof="logic", line=3, devs=None):
    c = D.Card("feature", line, tier, prof)
    c.fix_start()
    return c


def micro():
    ok = 0
    n = 0

    def chk(name, cond, info=""):
        nonlocal ok, n
        n += 1
        ok += 1 if cond else 0
        print(("GECTI " if cond else "KALDI ") + name, info)
    # 1. m(delta): Erdem'in iki noktasi
    chk("m(0)=0,20", abs(H.mfun(0) - 0.20) < 1e-12)
    chk("m(2)=0,10", abs(H.mfun(2) - 0.10) < 1e-12)
    chk("m(4)=0,05, m(-2)=0,40", abs(H.mfun(4) - 0.05) < 1e-12 and abs(H.mfun(-2) - 0.40) < 1e-12)
    # 2. K-E: 3 sprintlik is = 69,6 puan, R=3 -> tavan 100
    chk("K-E: 69,6 puan x R=3 -> 100", abs(H.C_E * 69.6 * 3 - 100) < 1e-9, "c=%.5f" % H.C_E)
    chk("3* kisi hizi 11,6 puan/hf", abs(D.BASE * D.Y(6) - 11.6) < 1e-9)
    # 3. kartta H, elle hesapli: logic K3 (kapi: dev 0 -> R=1 taban) ve risk K? kartlarda R
    H.CFG2.hata, H.CFG2.c = "yeni", 0.30
    team, ppl = mkteam([5.0, 3.0, 1.0])
    A.ARZ_L[0] = 12
    c = D.Card("feature", 3, 2, "logic")                  # hat 3 -> logic: GROUPS_REAL["logic"][0] = erp_cashflow, K2 -> [0,2,0,1]: Yazilim 2
    c.fix_start()
    R_ = H.req_dev(team, c)
    chk("R: erp_cashflow K2 Yazilim kapisi = 2", R_ == 2.0, "R=%s" % R_)
    c.log = {0: [0, 10.0, 0, 0], 2: [0, 10.0, 0, 0]}      # d0 (5*) ve d2 (1*) esit pay
    q = H.quality(team, c)
    exp = 0.5 * H.mfun(5.0 - 2.0) + 0.5 * H.mfun(1.0 - 2.0)
    chk("quality = is payi agirlikli m(delta)", abs(q - exp) < 1e-12, "q=%.5f exp=%.5f" % (q, exp))
    c.hcut = 0.1
    c.size = 25
    c.t0 = 0.0
    H.on_test_done2(c, team, 7, None)
    exp_h = 0.30 * 25 * 2.0 * 0.9 * exp
    chk("H = c x puan x R x (1-h) x q", abs(c.H - exp_h) < 1e-9, "H=%.5f exp=%.5f" % (c.H, exp_h))
    # 4. Erdem'in ornegi: tavan 100 (c = C_E), 3* gereksinimde 3* kisi -> 20, 5* kisi -> 10
    H.CFG2.c = H.C_E
    team2, _ = mkteam([3.0, 5.0])
    c2 = D.Card("feature", 3, 2, "logic")
    c2.fix_start()
    c2.size = 69.6
    c2._rq = [0, 3, 0, 0]
    R2 = H.req_dev(team2, c2)
    chk("R=3 (ekibin en iyisi 5*)", R2 == 3.0)
    for who, star, want in ((0, 3.0, 20.0), (1, 5.0, 10.0)):
        c2.log = {who: [0, 10.0, 0, 0]}
        c2.hcut = 0.0
        c2.t0 = 0.0
        H.on_test_done2(c2, team2, 3, None)
        chk("Erdem ornegi %d* -> %.0f hata (beklenen)" % (star, want), abs(c2.H - want) < 1e-6, "H=%.4f" % c2.H)
    # 5. basit is: R=1, tavan 5 civari: 15 puanlik K1 karti (R=1) tavani
    chk("K1 karti (15 puan, R=1) tavani 7,2", abs(H.C_E * 15 * 1 - 7.1839) < 1e-3, "%.4f" % (H.C_E * 15))
    # 6. TITIZ
    team3, ppl3 = mkteam([3.0])
    ppl3[0].titiz = True
    c3 = D.Card("feature", 3, 2, "logic")
    c3.fix_start()
    c3._rq = [0, 2, 0, 0]
    c3.log = {0: [0, 10.0, 0, 0]}
    chk("TITIZ x0,5", abs(H.quality(team3, c3) - 0.5 * H.mfun(1.0)) < 1e-12)
    # 7. duzeltme karti: R=1, tur 0,3
    f = D.Card("fix", 3, bugs=4)
    f.fix_start()
    f.log = {0: [0, 5.0, 0, 0]}
    H.CFG2.c = 0.30
    H.on_test_done2(f, team3, 5, None)
    chk("duzeltme: H = c x puan x 1 x 0,3 x m", abs(f.H - 0.30 * 8 * 0.3 * 0.5 * H.mfun(3.0 - 1.0)) < 1e-9, "H=%.5f" % f.H)
    H.CFG2.hata = "bugun"
    print("MICRO %d/%d" % (ok, n))
    return ok == n


def tail():
    """_tail = D.on_test_done'in H'tan sonrasi: ayni H verilince ayni hata sayisi, bulunanlar ve maliyetler."""
    import copy
    bad = tot = 0
    for seed in range(1, 40):
        team, ppl = mkteam([5.0, 3.0, 1.0, 4.0])
        ppl.append(D.Person("t0", "test", {"qa": 7, "eng": 3, "design": 0, "product": 0}))
        team = D.Team(ppl, 2)
        for kind, bugs in (("feature", 0), ("fix", 3)):
            c = D.Card(kind, 3, 2, "logic", bugs=bugs) if kind == "feature" else D.Card("fix", 3, bugs=bugs)
            c.fix_start()
            c.log = {0: [0, 6.0, 0, 0], 1: [0, 4.0, 2.0, 0], 4: [0, 0, 6.0, 0]}
            c.t0 = 8.0
            c.hcut = 0.1
            c2 = D.Card.__new__(D.Card)
            c2.__dict__.update(c.__dict__)
            c2.need, c2.kadro, c2.log = list(c.need), list(c.kadro), {k: list(v) for k, v in c.log.items()}
            CFG2.hata = "bugun"
            D.on_test_done(c, team, seed, None)
            c2.tested = True
            c2.H = c.H
            H._tail(c2, team, seed, None)
            for k in ("H", "C", "nbugs", "found", "costs", "cviol", "need", "kadro", "tested"):
                tot += 1
                if getattr(c, k) != getattr(c2, k):
                    bad += 1
                    print("FARK", seed, kind, k, getattr(c, k), getattr(c2, k))
    print("TAIL alan=%d fark=%d" % (tot, bad))
    return bad == 0


def pm():
    """PM okumalari: 3 PM (5*, 3*, 1*), 6 hazirlanacak kart (karmasiklik 40x3, 40x2, 25x2, 25x1, 15x1, 15x1)."""
    ok = True
    A.ARZ_L[0] = 12
    ppl = [D.Person("pmA", "pm", {"product": 10, "design": 0, "qa": 0, "eng": 0}), D.Person("pmB", "pm", {"product": 6, "design": 0, "qa": 0, "eng": 0}),
           D.Person("pmC", "pm", {"product": 2, "design": 0, "qa": 0, "eng": 0}), D.Person("dv", "dev", {"eng": 8, "qa": 3, "design": 0, "product": 0})]
    team = D.Team(ppl, 2)
    cards = []
    for size, rq in ((40, 3), (40, 2), (25, 2), (25, 1), (15, 1), (15, 1)):
        c = D.Card("feature", 3, 2, "logic")
        c.size = size
        c.base_need = [0, size * 0.6, size * 0.2, 0]
        c.need = list(c.base_need)
        c._rq = [0, rq, 0, 0]
        c.pos = len(cards)
        cards.append(c)
    for mode in ("basit", "zor", "k4h"):
        for c in cards:
            c.preparer = None
        A.CFG.pm = mode
        todo = A._pm_order_todo(team, cards, mode)
        A._pm_owners(team, todo, [1.0, 1.0, 1.0, 1.0], 1, mode)
        print(mode, [(int(c.size), int(H.req_dev(team, c)), c.preparer) for c in todo])
    A.CFG.pm = "basit"
    for c in cards:
        c.preparer = None
    todo = A._pm_order_todo(team, cards, "basit")
    A._pm_owners(team, todo, [1.0, 1.0, 1.0, 1.0], 1, "basit")
    ok = ok and todo[0].preparer == "pmA" and todo[-1].preparer == "pmC"
    print("PM (i): en karmasik -> pmA, en basit -> pmC:", ok)
    for c in cards:
        c.preparer = None
    todo = A._pm_order_todo(team, cards, "zor")
    A._pm_owners(team, todo, [1.0, 1.0, 1.0, 1.0], 1, "zor")
    ok2 = todo[0].preparer == "pmA"
    print("PM (ii): en karmasik -> pmA:", ok2)
    return ok and ok2


def bk():
    """BK: 5 kisi (5*, 4*, 3*, 2*, 1* Yazilim), 3 kart; en yuksek gereksinimli kart en iyilere, kalanlar buyukten kucuge siradaki en iyi kisi."""
    A.ARZ_L[0] = 12
    ppl = [D.Person("d%d" % i, "dev", {"eng": s * 2, "qa": 0, "design": 0, "product": 0}) for i, s in enumerate((5, 4, 3, 2, 1))]
    team = D.Team(ppl, 2)
    out = {}
    for rest in ("yeten", "bk"):
        cards = []
        for size, rq, pos in ((40, 3, 0), (8, 1, 1), (24, 1, 2)):
            c = D.Card("feature", 3, 2, "logic")
            c.base_need = [0, float(size), 0, 0]
            c.need = list(c.base_need)
            c.fix_start()
            c.kadro = [1, {40: 2, 8: 1, 24: 3}[size], 1, 1]
            c._rq = [0, rq, 0, 0]
            c.pos = pos
            cards.append(c)
        A.CFG.assign, A.CFG.stick, A.CFG.order, A.CFG.top, A.CFG.req = "erdem", 1, "plan", "cap", "data"
        CFG2.rest = rest
        st = D.WSt(team.n, len(cards))
        A.CTX[0], A.CTX[1] = 0, 2
        A.assign_e(team, cards, st, (False, False), None, None)
        out[rest] = {cards[ci].pos: sorted(team.ids[pi] for pi in cr) for ci, cr in st.crews.items() if cr}
        print(rest, out[rest])
    CFG2.rest = "yeten"
    # tarif: en yuksek gereksinim (3*) kart pos0 (kadro 2) en iyi iki kisi (d0, d1); BK ayni, sonra kalan kartlar buyukten kucuge: pos2 (24) -> d2, pos1 (16) -> d3, artan d4 yardima
    good = out["bk"][0][:2] == ["d0", "d1"] and "d2" in out["bk"].get(2, []) and out["bk"].get(1) == ["d3"] and out["yeten"].get(1) == ["d4"]
    print("BK: 8 puanlik kart sıradaki en iyiye (d3), tarifte yeten en düşüğe (d4):", good)
    return good


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "regress":
        sys.exit(1 if regress(int(sys.argv[2]) if len(sys.argv) > 2 else 3) else 0)
    elif c == "micro":
        sys.exit(0 if micro() else 1)
    elif c == "tail":
        sys.exit(0 if tail() else 1)
    elif c == "pm":
        sys.exit(0 if pm() else 1)
    elif c == "bk":
        sys.exit(0 if bk() else 1)
