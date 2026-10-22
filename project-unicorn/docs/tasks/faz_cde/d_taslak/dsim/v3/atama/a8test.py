# A8 dogrulama.  python -I a8test.py regress [tohum_sayisi] | micro | react | determ | dogrula
#   regress : a8plan yuklu, atama kipi "p8" degilken R, T, T_plan, A6/A3 kayitlariyla (out6/ana/H, out6/ana/0) 0 fark
#   micro   : alloc_p8 ve yardimcilari elle kurulmus durumlarda
#   react   : plan sapinca (kisi plandan yavas) onbellek tutmaz ve plan o anda yeniden kurulur
#   determ  : ayni kosu iki kez ayni sonuc
#   dogrula : out8 sonuclarinda tahmin = sonuc, gereksinim alti is, dogan >= bulunan, tohum sayisi
import os, sys, pickle, math, glob
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
H, A, D, CFG2, P, R6 = R8.H, R8.A, R8.D, R8.CFG2, R8.P, R8.R6


def same(a, b):
    if isinstance(a, float) or isinstance(b, float):
        return a is not None and b is not None and abs(a - b) <= 1e-9 * max(1.0, abs(a), abs(b))
    if isinstance(a, (list, tuple)):
        return len(a) == len(b) and all(same(x, y) for x, y in zip(a, b))
    if isinstance(a, dict):
        return a.keys() == b.keys() and all(same(a[k], b[k]) for k in a)
    return a == b


def regress(nseed=3):
    """a8plan yuklu ve p8 kapali: R, T, T_plan kollari A6'nin kayitli sonuclariyla (K-H ve bugunku model) ayni."""
    bad = tot = 0
    plan = []
    for cal in ("H", "0"):
        for arm in ("R", "T") + (("T_plan",) if cal == "H" else ()):
            for s in ("S1", "S2", "S3", "S4", "S5", "S6", "PR|S2", "PR|S3", "PR|S4"):
                plan.append((cal, arm, s))
    for cal, arm, scen in plan:
        rec = R6.load(R6.fname("ana", cal, arm, scen))
        for sd in range(1, nseed + 1):
            if sd not in rec:
                continue
            if scen in ("S5", "S6", "PR|S5", "PR|S6") and sd > 1:
                continue
            _, _, _, _, m = R8.run_task((arm, scen, sd, cal))
            for k, v in rec[sd].items():
                if k not in R8.KEEP and k not in ("detail", "wkwin", "pm_aud", "born", "born_feat", "found", "H", "esc", "wdev", "wbelow", "wdelta", "pts_win", "cal"):
                    continue
                tot += 1
                if not same(m[k], v):
                    bad += 1
                    print("FARK", cal, arm, scen, sd, k, str(m[k])[:60], "|", str(v)[:60])
        print(cal, arm, scen, "tamam", flush=True)
    print("REGRESS metrik=%d fark=%d" % (tot, bad))
    return bad


# ------------------------------------------------------------------ mikro testler
def _mkteam(devs, sw=2):
    ppl = [D.Person(n, "dev", {"eng": int(round(2 * s)), "qa": max(0, int(round(2 * s)) - 1), "design": 0, "product": 0}) for n, s in devs]
    return D.Team(ppl, sw)


def _mkcard(need, rq, pos, kadro=None):
    c = D.Card("feature", 0, 1, "logic")
    c.base_need = [0.0, float(need), 0.0, 0.0]
    c.need = list(c.base_need)
    c.size = float(need)
    c.fixed = True
    c.kadro = [1, kadro or max(1, int(math.ceil(need / D.SLICE))), 1, 1]
    c._rq = [0, rq, 0, 0]
    c.pos = pos
    c.tested = False
    return c


def _dispatch(team, cards, th, k=0, t=0.0):
    """Tek atama ani: tum kisiler bos, alloc_p8 dogrudan cagrilir; doner {kart pos: [kisi]}."""
    P.CUR[0] = th
    A.CTX[0], A.CTX[1] = k, 2
    A.CFG.assign, A.CFG.stick = "p8", 1
    st = D.WSt(team.n, len(cards))
    st.t = t
    rows = [[D.card_key(c, 1), i, 1, c.kadro[1], 0] for i, c in enumerate(cards)]
    es = list(range(team.n))
    take = P.alloc_p8(team, cards, st, 1, es, rows, 2 - (k + t))
    return {cards[ci].pos: sorted(team.ids[pi] for pi in pis) for ci, pis in take.items()}


def micro():
    ok = n = 0

    def chk(name, cond, info=""):
        nonlocal ok, n
        n += 1
        ok += 1 if cond else 0
        print(("GECTI " if cond else "KALDI ") + name, info)
    A.ARZ_L[0] = 12
    A.CFG.req = "data"
    TH = dict(mode="min", beta=1.0, help="plan", swap=1)
    # 1. Erdem'in ornegi: 3 gelistirici (4, 3, 3 yildiz), buyuk kart 100 puan (2 kisiyle 2 sprintte), iki kucuk kart 10 puan; buyuk plan sirasinda ilk
    team = _mkteam([("A", 4), ("B", 3), ("C", 3)])
    cards = [_mkcard(100, 2, 0), _mkcard(10, 1, 1), _mkcard(10, 1, 2)]
    got = _dispatch(team, cards, TH)
    chk("Erdem ornegi: buyuk kart 2 kisi (A ve bir 3 yildiz), kucuk kart 1 kisi, 3. kart bekler", len(got.get(0, [])) == 2 and "A" in got[0] and len(got.get(1, [])) == 1 and 2 not in got, str(got))
    # 2. buyuk kart 120 puan: 4 haftada A+B (27/hf) yetmez, uc kisi (38,6/hf) 3,1 haftada bitirir -> 3 kisi ister, kucuk kartlar bekler
    cards = [_mkcard(120, 2, 0), _mkcard(10, 1, 1), _mkcard(10, 1, 2)]
    got = _dispatch(team, cards, TH)
    chk("Buyuk is 4 haftada 2 kisiye sigmiyorsa 3 kisi alir; kucuk kartlar sonra bekler", len(got.get(0, [])) == 3 and 1 not in got, str(got))
    # 3. gereksinim: 3 yildiz isteyen kart 2 yildizliya gitmez
    team = _mkteam([("S", 4), ("T", 2), ("U", 2)])
    cards = [_mkcard(20, 3, 0)]
    got = _dispatch(team, cards, TH)
    chk("Gereksinimin altindaki kisi karta girmez", got.get(0) == ["S"], str(got))
    # 4. ilke: karmasik kart (puan x gereksinim buyuk) en iyi kisiyi, basit kart en zayifi alir (plan sirasi tersi olsa da)
    team = _mkteam([("G5", 5), ("G3", 3), ("G2", 2)])
    cards = [_mkcard(8, 1, 0), _mkcard(40, 2, 1)]                     # basit kart plan sirasinda once, karmasik ikinci
    got = _dispatch(team, cards, dict(TH, beta=0.45))
    top = got.get(1, [])
    chk("Karmasik kart en iyi kisiyi alir, basit kart zayifi (yer degisimi)", "G5" in top and "G5" not in got.get(0, []), str(got))
    # 5. yer degisimi plan hizini bozmuyorsa ancak: basit kart yalniz guclu kisiyle yetiyorsa degismez
    team = _mkteam([("G5", 5), ("G2", 2)])
    cards = [_mkcard(30, 1, 0), _mkcard(40, 2, 1)]
    got = _dispatch(team, cards, TH)
    chk("Her kart kendi ufkunu tutturacak kadar kisi alir (toplam kisiyi asmaz)", sum(len(v) for v in got.values()) <= 2, str(got))
    # 5b. yer degisimi: artan en iyi kisi plan sirasinda onde gelen basit karta dusmusse, hizi bozmadan karmasik kartin ekibine gecer
    team = _mkteam([("P1", 5), ("P2", 4), ("P3", 3)])
    cards = [_mkcard(20, 1, 0), _mkcard(20, 2, 1)]                    # basit kart plan sirasinda once; karmasik kartin (puan x gereksinim) 2 kati
    got = _dispatch(team, cards, TH)
    chk("Yer degisimi: en iyi kisi (P1) karmasik karta gecer, basit kart P2 ve P3 ile kalir", "P1" in got.get(1, []) and "P1" not in got.get(0, []), str(got))
    # 6. havuz bitince kalan kart bekler (plan sirasi)
    team = _mkteam([("A", 3), ("B", 3)])
    cards = [_mkcard(24, 1, 0), _mkcard(24, 1, 1), _mkcard(24, 1, 2)]
    got = _dispatch(team, cards, TH)
    chk("Plan sirasi: ilk iki kart kisi alir, ucuncu bekler", 0 in got and 1 in got and 2 not in got, str(got))
    # 7. t_full: tek kart, tek kisi
    team = _mkteam([("A", 3)])
    c = _mkcard(23.2, 1, 0)
    chk("t_full: 23,2 puan / 11,6 puan/hf = 2 hafta", abs(P.t_full(team, c, 1) - 2.0) < 1e-9, "%.4f" % P.t_full(team, c, 1))
    # 8. _pick_crew: tek yeten en zayif, cift en kucuk toplam
    rt = {0: 12.0, 1: 9.0, 2: 6.0, 3: 5.0}
    chk("_pick_crew: 5,5 hiz isteyen tek kisi -> yetenlerin en zayifi (6)", P._pick_crew([0, 1, 2, 3], 5.5, 4, rt) == [2])
    chk("_pick_crew: 13 hiz isteyen cift -> toplami en kucuk yeten cift (9+5 = 14)", sorted(P._pick_crew([0, 1, 2, 3], 13.0, 4, rt)) == [1, 3], str(P._pick_crew([0, 1, 2, 3], 13.0, 4, rt)))
    chk("_pick_crew: yetmeyen istek -> None", P._pick_crew([0, 1, 2, 3], 40.0, 4, rt) is None)
    # 9. hold: asil satirinda is bekleyen ikincil kisi (tester dev satirinda) tutulur
    ppl = [D.Person("D1", "dev", {"eng": 6, "qa": 5, "design": 0, "product": 0}), D.Person("T1", "test", {"qa": 6, "eng": 5, "design": 0, "product": 0}, ("build", "test"))]
    team = D.Team(ppl, 2)
    cards = [_mkcard(20, 1, 0), _mkcard(8, 1, 1)]
    cards[1].base_need = [0.0, 8.0, 6.0, 0.0]
    cards[1].need = list(cards[1].base_need)
    got = _dispatch(team, cards, dict(TH, sec="hold"))
    chk("hold: testci (sinif 2 gelistirme) test isi beklerken yazilima kilitlenmez", all("T1" not in v for v in got.values()), str(got))
    got = _dispatch(team, cards, dict(TH))
    print("   (hold kapaliyken:", got, ")")
    P.CUR[0] = dict(P.DEF)
    A.CFG.assign = "k4"
    print("MICRO %d/%d" % (ok, n))
    return ok == n


# ------------------------------------------------------------------ tepki: plan sapinca yeniden kurulur
def _ex_cards():
    D.Card._n = 0
    cards = []
    for pos, (nm, need, rq) in enumerate((("Buyuk", 100.0, 2), ("Kucuk1", 10.0, 1), ("Kucuk2", 10.0, 1))):
        c = D.Card("feature", 0, 1, "logic")
        c.base_need = [0.0, need, 0.5, 0.0]
        c.need = list(c.base_need)
        c.size = need + 0.5
        c.fixed = True
        c.kadro = [1, max(1, int(math.ceil(need / D.SLICE))), 1, 1]
        c.t0 = c.need[2]
        c._rq = [0, rq, 0, 0]
        c.pos = pos
        cards.append(c)
    return cards


def react(verbose=True):
    """Erdem'in ornegi (A 4 yildiz, B ve C 3 yildiz; buyuk 100 puan, iki kucuk 10 puan). Plan oynatmasi sonra gercek oynatma ayni kodla: tum haftalar
    onbellekten gelir ve ilerleme ayni. Sapma: gercek oynatmada ikinci hafta A'nin hizi %40 dusuk (plan bilmiyordu) -> o hafta onbellek tutmaz,
    planlayici A'nin gercek hiziyla yeniden kurar."""
    import a8iz as Z
    A.ARZ_L[0] = 12
    res = {}
    for mode in ("sapma_yok", "sapma"):
        R8.set_cfg8(R6.ARMS["P"], 7, "H")
        P.reset_stats()
        Dsave = D.H0
        D.H0 = 0.0
        CFG2.hata = "bugun"
        ppl = [D.Person(n, "dev", {"eng": 2 * s, "qa": max(0, 2 * s - 1), "design": 0, "product": 0}, ("build", "test")) for n, s in (("A", 4), ("B", 3), ("C", 3))]
        team = D.Team(ppl, 2)
        cards = _ex_cards()
        plan_cards = [c.clone() for c in cards]
        Z.TR["events"].clear()
        Z.TR["on"] = False
        for k in range(2):
            Z._w8(team, plan_cards, D.WSt(3, 3), 7, k, 2, k, (), (), True, None, False, None, None, False, (False, False), None)
        miss0 = P.STATS["miss"]
        team2 = D.Team(ppl, 2)
        team2.rate[0][1] *= 0.6                             # A plandan %40 yavas
        Z.TR["on"] = True
        Z.TR["base"] = 0.0
        for k in range(2):
            tm = team2 if (mode == "sapma" and k == 1) else team
            Z._w8(tm, cards, D.WSt(3, 3), 7, k, 2, k, (), (), True, None, True, None, None, False, (False, False), None)
        Z.TR["on"] = False
        D.H0 = Dsave
        segs = Z.seg_table(Z.TR["events"], team.ids, 2.0)
        cname = {c.id: nm for c, nm in zip(cards, ("Buyuk", "Kucuk1", "Kucuk2"))}
        res[mode] = dict(hits=P.STATS["hits"], replans=P.STATS["miss"] - miss0, prog=[round(sum(c.prog), 3) for c in cards], plan=[round(sum(c.prog), 3) for c in plan_cards], segs=segs, cname=cname)
        if verbose:
            print("--", mode, "onbellekten gelen hafta", res[mode]["hits"], "yeniden kurulan hafta", res[mode]["replans"], "| gercek ilerleme", res[mode]["prog"], "| plan ilerlemesi", res[mode]["plan"])
            print(Z.fmt_segs(segs, {}, cname))
    ok = (res["sapma_yok"]["replans"] == 0 and res["sapma_yok"]["hits"] == 2 and res["sapma_yok"]["prog"] == res["sapma_yok"]["plan"]
          and res["sapma"]["hits"] == 1 and res["sapma"]["replans"] == 1)
    print("REACT", "GECTI" if ok else "KALDI")
    return ok


def kalir():
    """"Kalir": asamasi suren kartin kisisi, sonraki haftanin basinda ayni kartta (sprint ici ve sprint siniri). a3run.stability ile P ve R kollarinda sayilir."""
    import a3run as R3
    out = {}
    for arm in ("P", "R"):
        R8.set_cfg8(R6.ARMS[arm], 1, "H")
        sim = R6.make_sim("S4", 1)
        sim.run()
        out[arm] = R3.stability(A.WSE, sim.sw)
    p, r = out["P"], out["R"]
    print("P: sprint ici %d/%d degisti, sprint siniri %d/%d; R: sprint ici %d/%d, sprint siniri %d/%d" % (
        p["in_ch"], p["in_total"], p["bd_ch"], p["bd_total"], r["in_ch"], r["in_total"], r["bd_ch"], r["bd_total"]))
    ok = p["in_ch"] == 0 and p["bd_ch"] == 0 and p["in_total"] > 0 and r["in_ch"] > 0
    print("KALIR", "GECTI" if ok else "KALDI")
    return ok


def tekrar(nseed=3):
    """Kayitli P ve P_sabit sonuclari, planlayici kodunun son hâliyle yeniden koşulunca ayni mi (kodda sonradan yapilan duzenlemeler sonuclari oynatmadi)."""
    bad = tot = 0
    for arm, scens in (("P", ("S2", "S3", "S4", "PR|S2", "PR|S3", "PR|S4")), ("P_sabit", ("S3", "PR|S3"))):
        for scen in scens:
            rec = R6.load(R8.fname("ana", "H", arm, scen))
            for sd in range(1, nseed + 1):
                if sd not in rec:
                    continue
                m = R8.run_task((arm, scen, sd, "H"))[4]
                for k in R8.KEEP + ("born", "found", "H", "esc"):
                    if k in rec[sd]:
                        tot += 1
                        if not same(m[k], rec[sd][k]):
                            bad += 1
                            print("FARK", arm, scen, sd, k)
        print(arm, "tamam", flush=True)
    print("TEKRAR metrik=%d fark=%d" % (tot, bad))
    return bad == 0


def determ():
    R8.set_cfg8(R6.ARMS["P"], 3, "H")
    r1 = R8.run_task(("P", "S3", 3, "H"))[4]
    r2 = R8.run_task(("P", "S3", 3, "H"))[4]
    bad = [k for k in R8.KEEP if k in r1 and not same(r1[k], r2[k])]
    print("DETERM", "GECTI" if not bad else "KALDI %s" % bad)
    return not bad


def dogrula():
    files = sorted(glob.glob(os.path.join(HERE, "out8", "*", "*", "*.pkl")))
    bad_n = bad_pred = bad_born = bad_below = 0
    maxpred = 0.0
    nrun = 0
    hitbad = 0
    for f in files:
        d = pickle.load(open(f, "rb"))
        arm = os.path.basename(f).split("__")[0]
        if len(d) != 20:
            bad_n += 1
            print("TOHUM EKSIK", f, len(d))
        for sd, m in d.items():
            nrun += 1
            maxpred = max(maxpred, m["pred"])
            bad_pred += 1 if m["pred"] > 1e-6 else 0
            bad_born += 1 if m["found"] > m["born"] + 1e-9 else 0
            if arm.startswith("P") and "np" not in arm and m["wbelow"] > 1e-9:
                bad_below += 1
            p = m.get("p8", {})
            if arm == "P" and p.get("epochs", 0) and p["hits"] * 2 != p["epochs"]:
                hitbad += 1
    # P_r85 = P'nin ayni ayari (rho 0,85) ayri kosuda: sonuclar ayni olmali (kosu tekrarlanabilirligi)
    diff85 = tot85 = 0
    for f in glob.glob(os.path.join(HERE, "out8", "ana", "H", "P_r85__*.pkl")):
        a = pickle.load(open(f, "rb"))
        b = pickle.load(open(f.replace("P_r85__", "P__"), "rb"))
        for sd in a:
            for k in R8.KEEP:
                if k in a[sd]:
                    tot85 += 1
                    if not same(a[sd][k], b[sd][k]):
                        diff85 += 1
    print("P_r85 (ayni ayar, ayri kosu) ile P: metrik %d, fark %d" % (tot85, diff85))
    print("dosya %d, kosu %d, tohumu 20'den az dosya %d" % (len(files), nrun, bad_n))
    print("tahmin = sonuc: en buyuk fark %.2e, 1e-6 ustu %d" % (maxpred, bad_pred))
    print("bulunan > dogan olan kosu: %d; P kollarinda gereksinim alti Yazilim isi olan kosu: %d; P'de onbellek tutmayan hafta olan kosu: %d" % (bad_born, bad_below, hitbad))
    return diff85 == 0 and bad_n == 0 and bad_pred == 0 and bad_born == 0 and bad_below == 0


def falsify():
    """Testler bos degil: dort kasitli bozma, her biri micro()'da en az bir vakayi dusurmeli."""
    import io, contextlib

    def run_micro():
        buf = io.StringIO()
        with contextlib.redirect_stdout(buf):
            micro()
        lines = buf.getvalue().splitlines()
        return [ln for ln in lines if ln.startswith("KALDI")]
    base = run_micro()
    print("bozmasiz: dusen vaka", len(base))
    res = []
    # 1. gereksinim kapisi kapali
    old = A._hard
    A._hard = lambda v: 0
    f1 = run_micro()
    A._hard = old
    res.append(("gereksinim kapisi kapali", len(f1)))
    # 2. ilke yer degisimi hep kapali
    oldp = P.alloc_p8

    def noswap(team, cards, st, r, es, rr, tl):
        old_th = P.CUR[0]
        P.CUR[0] = dict(old_th, swap=0)
        try:
            return oldp(team, cards, st, r, es, rr, tl)
        finally:
            P.CUR[0] = old_th
    P.alloc_p8 = noswap
    f2 = run_micro()
    P.alloc_p8 = oldp
    res.append(("ilke yer degisimi kapali", len(f2)))
    # 3. saklama (hold) etkisiz
    oldh = P._hold_sec
    P._hold_sec = lambda *a: False
    f3 = run_micro()
    P._hold_sec = oldh
    res.append(("saklama etkisiz", len(f3)))
    # 4. en az kisilik ekip yerine hep en guclu kisi
    oldpk = P._pick_crew
    P._pick_crew = lambda cands, need, cap, rt: ([cands[0]] if cands and rt[cands[0]] >= need - 1e-9 else oldpk(cands, need, cap, rt))
    f4 = run_micro()
    P._pick_crew = oldpk
    res.append(("tek yeten kisi hep en guclu", len(f4)))
    ok = len(base) == 0 and all(n > 0 for _, n in res)
    for nm, n in res:
        print("bozma: %-34s dusen vaka %d" % (nm, n))
    print("FALSIFY", "GECTI" if ok else "KALDI")
    return ok


if __name__ == "__main__":
    c = sys.argv[1]
    if c == "regress":
        sys.exit(1 if regress(int(sys.argv[2]) if len(sys.argv) > 2 else 3) else 0)
    elif c == "micro":
        sys.exit(0 if micro() else 1)
    elif c == "react":
        sys.exit(0 if react() else 1)
    elif c == "falsify":
        sys.exit(0 if falsify() else 1)
    elif c == "kalir":
        sys.exit(0 if kalir() else 1)
    elif c == "tekrar":
        sys.exit(0 if tekrar() else 1)
    elif c == "determ":
        sys.exit(0 if determ() else 1)
    elif c == "dogrula":
        sys.exit(0 if dogrula() else 1)
