import json
OUT = []

def single(people, prof, tier, ready=0.0, maxw=12):
    team = Team(people)
    c = Card("feature", 0, tier, prof)
    c.prep = c.prep_need() * ready
    c.fix_start()
    wk = 0
    idle1 = None
    while c.phase() < 3 and wk < maxw:
        i, _ = run_week(team, [c], wk)
        if wk == 0:
            idle1 = i
        wk += 1
    e = expected(c, team)[0]
    return c, team, idle1, e

def pn(team, c, k):
    return ", ".join("%s %s" % (team.p[i].id, ("%.2f" % v[k]).replace(".", ",")) for i, v in c.log.items() if v[k] > 0)

S7p = SCEN["S7"]()
c, t, i1, e = single(S7p, "logic", 1)
OUT.append(("K1 geliştirme ağırlıklı (2/10/3), S7 ekibi, tek kart", "kadro [1,2,1]; 1. haftada biter; testi 4★ testçi; E≈0,22; boşta ≈6,7 kişi-hafta",
            "kadro %s; biter %.2f hf; test: %s; E=%.3f; boşta %.2f" % (c.kadro, c.done_at, pn(t, c, 2), e, i1)))
c, t, i1, e = single(S7p, "risk", 3)
OUT.append(("K3 test ağırlıklı (4/22/14), S7 ekibi, tek kart", "kadro [1,3,2]; 2. haftada biter; test 4★ ve 3★ testçide; E≈0,64",
            "kadro %s; biter %.2f hf; test: %s; E=%.3f" % (c.kadro, c.done_at, pn(t, c, 2), e)))
exp = [3.45, 2.33, 1.96, 1.77, 1.77, 1.77]
got = []
for k in range(1, 7):
    ppl = [Person("D", "des", {"design": 6, "product": 5}), Person("T", "test", {"qa": 6, "eng": 5})] + \
          [Person("G%d" % j, "dev", {"eng": 6, "qa": 5}) for j in range(k)]
    c, t, i1, e = single(ppl, "logic", 3)
    got.append(round(c.done_at, 2))
OUT.append(("K3 geliştirme ağırlıklı (6/26/8), 3★ tasarımcı ve testçi, 1-6 adet 3★ geliştirici (kartın süresi, hafta)", str(exp), str(got)))
# K2 hata
rows = []
for lab, tester in (("yok", None), ("kurucu 0*", "F"), ("1*", 2), ("2*", 4), ("3*", 6), ("4*", 8), ("5*", 10)):
    c = Card("feature", 0, 2, "risk")  # profil onemsiz: yalniz toplam hata yuku icin K2
    c.fix_start()
    dev = Person("G", "dev", {"eng": 5, "qa": 4})
    if tester == "F":
        who = founder()
    elif tester is None:
        who = None
    else:
        who = Person("T", "test", {"qa": tester, "eng": 0})
    ppl = [dev] + ([who] if who else [])
    team = Team(ppl)
    c.log = {0: [0, c.need[1], 0]}
    if who:
        c.log[1] = [0, 0, c.t0]
    rows.append("%s %.2f" % (lab.replace("*", "★").replace("yok", "yok"), expected(c, team)[0] / 1.0))
OUT.append(("K2 (25 puan), 2,5★ geliştirici, hazırlıksız, testi tek kişi: kaçan hata E", "yok 0,75; kurucu 0★ 0,54; 3★ 0,43; 5★ 0,33", "; ".join(rows)))
# hazirlik suresi
pm = Person("P", "pm", {"product": 6})
OUT.append(("Hazırlık süresi, 3★ PM", "K1 0,26 hafta; K3 0,69 hafta", "K1 %.2f hafta; K3 %.2f hafta" % (PREP_RATIO * 15 / pm.rate("product"), PREP_RATIO * 40 / pm.rate("product"))))
json.dump(OUT, open("check69.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for a, b, c_ in OUT:
    print(a, "|", b, "|", c_)
