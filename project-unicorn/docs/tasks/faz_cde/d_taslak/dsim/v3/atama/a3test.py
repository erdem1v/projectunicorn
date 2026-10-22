# A3 dogrulama: (1) week3 = D.week2 (R ayariyla), (2) tarifin mikro testleri, (3) ayni girdi ayni atama, (4) tahmin = sonuc.
#   python -I a3test.py regress | micro | det | pred
import os, sys, json, importlib.util, random
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3run as R
A = R.A
D = A.D


def load_orig():
    """dsim3.py'nin yamasiz ikinci kopyasi (kendi week2'siyle)."""
    spec = importlib.util.spec_from_file_location("dsim3_plain", os.path.join(A.V3, "dsim3.py"))
    m = importlib.util.module_from_spec(spec)
    sys.modules["dsim3_plain"] = m
    spec.loader.exec_module(m)
    return m


def same(a, b):
    if isinstance(a, float) or isinstance(b, float):
        return a is not None and b is not None and abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    if isinstance(a, (list, tuple)):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def regress(scens, nseed):
    plain = load_orig()
    bad = tot = 0
    for nm in scens:
        for sd in range(1, nseed + 1):
            mo = plain.run_one((nm, sd))[2]
            R.set_cfg(R.ARMS["R"], sd)
            sim = R.make_sim(nm, sd)
            sim.run()
            mn = D.metrics(sim, A.LO)
            for k, v in mo.items():
                tot += 1
                if not same(mn[k], v):
                    bad += 1
                    print("FARK", nm, sd, k, str(mn[k])[:70], "|", str(v)[:70])
        print(nm, "tamam", flush=True)
    print("REGRESS metrik=%d fark=%d" % (tot, bad))
    return bad


def mkteam(devs, sw=2):
    ppl = [D.Person("d%d" % i, "dev", {"eng": s, "qa": max(0, s - 1), "design": 0, "product": 0}) for i, s in enumerate(devs)]
    return D.Team(ppl, sw), ppl


def mkcard(need_dev, req_eng=0, prog_dev=0.0, pos=0):
    c = D.Card("feature", 0, 2, "logic")
    c.base_need = [0.0, float(need_dev), 0.0, 0.0]
    c.need = list(c.base_need)
    c.prog = [0.0, prog_dev, 0.0, 0.0]
    c.size = need_dev
    c.fix_start()
    c.kadro = [1, max(1, -(-int(need_dev) // 8)), 1, 1]
    c.pos = pos
    c._rq = [0, req_eng, 0, 0]
    return c


def run_assign(team, cards, mode="erdem", top="cap", t=0.0, k=0, order="plan"):
    R.set_cfg(R.ARMS["E"], 1)
    A.CFG.assign, A.CFG.top, A.CFG.order = mode, top, order
    st = D.WSt(team.n, len(cards))
    st.t = t
    A.CTX[0], A.CTX[1] = k, 2
    A.assign_e(team, cards, st, (False, False), None, None)
    return {cards[ci].pos: sorted(team.ids[pi] for pi in cr) for ci, cr in st.crews.items() if cr}, st


def micro():
    res = []

    def chk(name, exp, got):
        ok = exp == got
        res.append(ok)
        print(("GECTI  " if ok else "KALDI  ") + name, "| beklenen", exp, "| bulunan", got)
    # kisiler puan olarak (yildiz = puan / 2); hiz = 10 x Y(puan): 10 -> 20,0/hf, 8 -> 15,4, 6 -> 11,6, 4 -> 8,6, 2 -> 6,4. Sprint: 2 hafta (yeten = hiz x 2 >= kalan is)
    # T1: gereksinim 4 yildiz olan A (ihtiyac 16, kadro 2): gereksinimi karsilayan en iyi iki (5 ve 4 yildiz). C (10): yeten en dusuk (1 yildiz: 12,8 >= 10). B (3): kalan.
    team, ppl = mkteam([10, 8, 6, 2])
    A_, B_, C_ = mkcard(16, 4, pos=0), mkcard(3, 0, pos=1), mkcard(10, 0, pos=2)
    got, _ = run_assign(team, [A_, B_, C_])
    chk("T1 gereksinim 4 yildiz: en iyi 2 gelistirici A'ya; kalan kartlar plan sirasiyla: B'ye (3) yeten en dusuk (1 yildiz), C'ye (10) kalan", {0: ["d0", "d1"], 1: ["d3"], 2: ["d2"]}, got)
    A_, B_, C_ = mkcard(16, 4, pos=0), mkcard(3, 0, pos=1), mkcard(10, 0, pos=2)      # kartlar kimlik hatirlar (kalir kurali): yeni kartlar
    got, _ = run_assign(team, [A_, B_, C_], order="gerek")
    chk("T1b ayni girdi, kalan kartlar gereksinim/buyukluk sirasiyla (E_gsira): C'ye (10) yeten en dusuk, B'ye kalan", {0: ["d0", "d1"], 2: ["d3"], 1: ["d2"]}, got)
    # T2: gereksinim ekibin en iyisini (3 yildiz) asarsa ona iner; 2 yildiz yetmez, bosta kalir (gereksinim)
    team, ppl = mkteam([6, 4])
    got, _ = run_assign(team, [mkcard(16, 5, pos=0)])
    chk("T2 gereksinim ekibin en iyisini asarsa ona iner; 2 yildiz giremez", {0: ["d0"]}, got)
    # T3: kart 8 puan (kadro 1) gereksinim 4 yildiz: tek en iyi; 20'lik kart: tek 1 yildiz 12,8 yetmez, ikili 25,6 yeter
    team, ppl = mkteam([10, 2, 2])
    got, _ = run_assign(team, [mkcard(8, 4, pos=0), mkcard(20, 0, pos=1)])
    chk("T3 tek kisi yetmez: en dusuk yeten ikili (iki 1 yildiz); buyuk gereksinimli karta en iyi", {0: ["d0"], 1: ["d1", "d2"]}, got)
    # T4: tek buyuk kart (kadro 3), uc kisi: kimse bosta kalmaz
    team, ppl = mkteam([10, 8, 6])
    got, _ = run_assign(team, [mkcard(24, 0, pos=0)])
    chk("T4 tek buyuk kart (kadro 3): uc kisi de girer", {0: ["d0", "d1", "d2"]}, got)
    # T5: T(8, gereksinim 4, kadro 1) en iyiyi alir; C1 (10, kadro 2) icin yeten en dusuk 2 yildiz (17,2 >= 10); C2 (3) yeten en dusuk 3 yildiz; artan 4 yildiz C1'e yardim
    team, ppl = mkteam([10, 8, 6, 4])
    got, _ = run_assign(team, [mkcard(8, 4, pos=0), mkcard(10, 0, pos=1), mkcard(3, 0, pos=2)])
    chk("T5 yeten en dusuk + yardim: T:[5 yildiz], C1:[2 yildiz, yardim 4 yildiz], C2:[3 yildiz]", {0: ["d0"], 1: ["d1", "d3"], 2: ["d2"]}, got)
    # T6: ters kip: buyuk karta en zayiflar, kucuge en guclu
    team, ppl = mkteam([10, 8, 6])
    got, _ = run_assign(team, [mkcard(16, 0, pos=0), mkcard(3, 0, pos=1)], mode="rev")
    chk("T6 ters kip: buyuk karta en zayiflar, kucuge en guclu", {0: ["d1", "d2"], 1: ["d0"]}, got)
    # T7: top=min: 16'lik karta sprintte yetecek en az sayida en iyi kisi (tek: 20 x 2 = 40 >= 16); artan yardima gider (kadro 2)
    team, ppl = mkteam([10, 8, 6])
    got, _ = run_assign(team, [mkcard(16, 0, pos=0)], top="min")
    chk("T7 top=min: ilk adimda tek kisi; artan yardima gider (kadro 2)", {0: ["d0", "d1"]}, got)
    # T8: uymayan is (PM, Test kutulu) yalniz uyan kisi kalmayinca: bir test karti, bir testci, bir PM
    ppl2 = [D.Person("t0", "test", {"qa": 8, "eng": 7, "design": 0, "product": 0}), D.Person("pm0", "pm", {"product": 6, "design": 5, "qa": 2, "eng": 0}, ("build", "test"))]
    team2 = D.Team(ppl2, 2)
    c = D.Card("feature", 0, 2, "risk")
    c.base_need = [0.0, 0.0, 12.0, 0.0]
    c.need = list(c.base_need)
    c.prog = [0.0, 0.0, 0.0, 0.0]
    c.size = 12
    c.fix_start()
    c.kadro = [1, 1, 3, 1]
    c.pos = 0
    c._rq = [0, 0, 0, 0]
    c.prog[1] = 0.0
    got, st = run_assign(team2, [c])
    chk("T8 uymayan is (PM) yalniz yardim adiminda ve yer varsa: testci once, PM yardima", {0: ["pm0", "t0"]}, got)
    bad = res.count(False)
    print("MIKRO %d/%d" % (len(res) - bad, len(res)))
    return bad


def perm_det():
    """Ayni girdi (kisi listesi ters ve karisik) ayni atama: 6 koskosu, tarif ve R."""
    bad = 0
    for arm in ("E", "R"):
        for nm in ("S3", "S4", "S5"):
            outs = []
            for variant in range(3):
                R.set_cfg(R.ARMS[arm], 1)
                fn, kw = D.SCEN[nm]
                kw = dict(kw)
                kw["weeks"] = 16
                ppl = fn()
                if variant == 1:
                    ppl = ppl[::-1]
                elif variant == 2:
                    random.Random(5).shuffle(ppl)
                alog = []
                sim = A.A3Sim(ppl, 1, **kw)
                sim.alog = alog
                sim.run()
                outs.append((len(alog), sorted(alog), round(sum(c for c in [sim.rec[i]["delivered"] for i in range(len(sim.rec))]), 6), sim.pred_maxdiff))
            ok = outs[0][1] == outs[1][1] == outs[2][1] and outs[0][2] == outs[1][2] == outs[2][2]
            bad += 0 if ok else 1
            print("ayni girdi ayni atama" if ok else "FARKLI", arm, nm, "atama satiri", outs[0][0], "teslim", outs[0][2], "tahmin farki", outs[0][3])
    print("DET kalan fark", bad)
    return bad


def pred_check(scens, nseed, arms):
    worst = 0.0
    n = 0
    for arm in arms:
        for nm in scens:
            for sd in range(1, nseed + 1):
                _, _, _, m = R.run_task((arm, nm, sd))
                worst = max(worst, m["pred"])
                n += 1
    print("TAHMIN=SONUC kosu=%d en buyuk fark=%.3g" % (n, worst))
    return worst


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "regress":
        regress(sys.argv[2].split(","), int(sys.argv[3]))
    elif c == "micro":
        micro()
    elif c == "det":
        perm_det()
    elif c == "pred":
        pred_check(sys.argv[2].split(","), int(sys.argv[3]), sys.argv[4].split(","))


def gate_inv(scens, nseed, arms=("E_gate", "R_gate")):
    """Kapi okumasi degismezi: PM'li ekipte hazirligi bitmemis ozellik kartinin Gelistirme ilerlemesi sifirdir; kapi acik oldugunda PM payi bitmistir."""
    orig = A.week3
    viol = []
    nchk = [0]

    def wrapped(team, cards, st, seed, k, sw, off, *a, **kw):
        r = orig(team, cards, st, seed, k, sw, off, *a, **kw)
        if team.pm_order and not kw.get("probe", False):
            for c in cards:
                if c.kind == "feature":
                    nchk[0] += 1
                    if c.prog[1] > A.EPS and c.prep < c.prep_need() - A.EPS:
                        viol.append((off, c.id, c.prog[1], c.prep, c.prep_need()))
        return r
    D.week2 = wrapped
    try:
        for arm in arms:
            for nm in scens:
                for sd in range(1, nseed + 1):
                    R.run_task((arm, nm, sd))
    finally:
        D.week2 = orig
    print("KAPI degismezi: kontrol=%d ihlal=%d" % (nchk[0], len(viol)), viol[:3])
    return len(viol)


if __name__ == "__main__" and sys.argv[1] == "gate":
    gate_inv(sys.argv[2].split(","), int(sys.argv[3]), tuple(sys.argv[4].split(",")) if len(sys.argv) > 4 else ("E_gate", "R_gate"))
