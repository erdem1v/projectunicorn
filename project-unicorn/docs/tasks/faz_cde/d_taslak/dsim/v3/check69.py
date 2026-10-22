# §6.9 elle dogrulama (D_MODEL_v3.md). python -I dsim3.py exec check69.py
import json
OUT = []


def single(people, prof, tier, ready=None, maxw=14, h0=None, seed=1):
    """Tek kart, tek hucre: kartin Test'inin bittigi zamani ve sonucu doner."""
    global H0
    old = H0
    if h0 is not None:
        H0 = h0
    try:
        Card._n = 0
        team = Team(people, 2)
        c = Card("feature", 0, tier, prof)
        if ready is not None:
            c.prep = c.prep_need() * ready
        c.fix_start()
        tdone = None
        wk = 0
        idle1 = None
        while c.phase() < 4 and wk < maxw:
            i, _, _ = run_week(team, [c], seed, wk)
            if wk == 0:
                idle1 = i
            if c.tested and tdone is None:
                # test bitis zamani: log'dan degil, done_at yok; asagida zaman sirali kayit
                tdone = wk
            wk += 1
        return c, team, idle1
    finally:
        H0 = old


def pn(team, c, k):
    return ", ".join("%s %s" % (team.p[i].id, ("%.2f" % v[k]).replace(".", ",")) for i, v in c.log.items() if v[k] > 0)


# 1. K2 hata yuku ve yakalama
rows = []
for lab, tester, own in (("0* baskasi", ("test", 0), False), ("3* baskasi", ("test", 6), False), ("5* baskasi", ("test", 10), False), ("3* kendi karti", ("test", 6), True)):
    dev = P("dev", 5)
    t = Person("T", "test", {"qa": tester[1], "eng": 0, "design": 0, "product": 0}) if not own else Person("Gt", "dev", {"eng": 5, "qa": 6, "design": 0, "product": 0}, ("build", "test"))
    ppl = [dev, t] if not own else [t]
    team = Team(ppl, 2)
    c = Card("feature", 0, 2, "risk")
    c.fix_start()
    if own:
        c.log = {0: [0, c.need[1], c.t0, 0]}
    else:
        c.log = {0: [0, c.need[1], 0, 0], 1: [0, 0, c.t0, 0]}
    on_test_done(c, team, 1)
    rows.append("%s H=%.2f E=%.2f" % (lab, c.H, c.H * (1 - c.C)))
OUT.append(("K2 (25), 2,5★ geliştirici (q=1), hazırlıksız, testi tek kişi", "H=1,0; E: başkasının kartı 0★ 0,60 · 3★ 0,39 · 5★ 0,19; kendi kartı 3★ 0,63", "; ".join(rows)))

# 2. K1 gelistirme agirlikli, S7 ekibi
S7p = SCEN["S7"][0]()
c, t, i1 = single(S7p, "logic", 1)
OUT.append(("K1 geliştirme ağırlıklı (2/10/3), S7 ekibi, tek kart", "kadro [1,2,1]; test 4★ testçide; C = 0,71",
            "kadro %s; test: %s; C=%.3f" % (c.kadro[:3], pn(t, c, 2), c.C)))

# 3. K3 gelistirme agirlikli sureleri (hata yokken)
exp = [3.45, 2.33, 1.95, 1.77, 1.77, 1.77]
got = []
for k in range(1, 7):
    ppl = [Person("D", "des", {"design": 6, "product": 5}), Person("T", "test", {"qa": 6, "eng": 5})] + [Person("G%d" % j, "dev", {"eng": 6, "qa": 5}) for j in range(k)]
    c, t, i1 = single(ppl, "logic", 3, h0=0.0)
    got.append(round(c.done_at, 2))
OUT.append(("K3 geliştirme ağırlıklı (6/26/8), 3★ tasarımcı ve testçi, 1 ile 6 3★ geliştirici (süre, hafta; hata yokken)", str(exp), str(got)))

# 4. hazirlik suresi
res = []
for lab, s in (("1★", 2), ("3★", 6), ("5★", 10)):
    pm = Person("P", "pm", {"product": s})
    res.append("%s K1 %.2f K3 %.2f" % (lab, PREP_RATIO * 15 / pm.prep_rate(), PREP_RATIO * 40 / pm.prep_rate()))
OUT.append(("Hazırlık süresi, tek PM (hafta)", "K1 (3 puan): 1★ 0,20 · 3★ 0,14 · 5★ 0,12; K3 (8 puan): 1★ 0,53 · 3★ 0,36 · 5★ 0,32", "; ".join(res)))

# 5. hazir K2 tam hazir
res = []
for lab, s in (("1★", 2), ("3★", 6), ("5★", 10)):
    c = Card("feature", 0, 2, "risk")
    pn_ = c.prep_need()
    c.prep, c.prepb, c.preph = pn_, pn_ * prep_b(s), pn_ * prep_h(s)
    c.fix_start()
    res.append("%s ihtiyaç ÷ %.2f; hata ×%.3f" % (lab, c.base_need[0] / c.need[0], 1 - c.hcut))
OUT.append(("Hazır K2 (25), tam hazır", "ihtiyaç ÷ 1,10 (1★), ÷ 1,20 (3★), ÷ 1,30 (5★); H × 0,90, × 0,75, × 0,60", "; ".join(res)))

# 6. kurucu 0* tasarimda
f = founder()
OUT.append(("Kurucu 0★ tasarımda", "8,6 puan/hafta", "%.2f" % f.rate("design")))

# 7. duzeltme karti
OUT.append(("Düzeltme kartı", "1 hata 5 · 3 hata 6 · 5 hata 10 · 12 hata 24 puan", " · ".join("%d hata %g" % (b, Card("fix", 0, bugs=b).size) for b in (1, 3, 5, 12))))

# 8. ayni kart ayni ekip iki oynatma + plan = sonuc
def trace(seed):
    s = Sim(S3(), seed, weeks=24)
    s.run()
    cards = {}
    return s


a, b = trace(5), trace(5)
ra = [(x["found"], x["K"], round(x["pts"], 9), x["cards"]) for x in a.rec]
rb = [(x["found"], x["K"], round(x["pts"], 9), x["cards"]) for x in b.rec]
OUT.append(("Aynı kart, aynı ekip, iki oynatma", "Aynı n, F, costs, bitiş zamanı", "iki koşu özdeş: %s; plan-kapanış en büyük fark %.1e" % (ra == rb, a.pred_maxdiff)))
json.dump(OUT, open("out/check69.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for x, y, z in OUT:
    print(x, "|", y, "|", z)
