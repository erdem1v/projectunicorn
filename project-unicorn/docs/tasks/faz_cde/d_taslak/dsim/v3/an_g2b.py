exec(open("an_common.py", encoding="utf-8").read())
E = L("E")
FN = ["orta","gel4","gel5","tasarim_test"]
SQ = {"gel-tas-test": ["dev","des","test"], "tas-gel-test": ["des","dev","test"], "test-gel-tas": ["test","dev","des"], "pm-gel-tas": ["pm","dev","des"], "1yildiz": ["dev","des","test"], "uc-gel": ["dev","dev","dev"]}
cnt = {"asama": 0, "bolundu": 0, "hazirlik": 0, "aciklanamayan": 0}
rows = []
worst = 0
for f in FN:
    for s, seq in SQ.items():
        base = md(E, "G|%s|%s|0" % (f, s), "founder_w")
        for k in range(1, 4):
            n = "G|%s|%s|%d" % (f, s, k); p = "G|%s|%s|%d" % (f, s, k - 1)
            fw, pf = md(E, n, "founder_w"), md(E, p, "founder_w")
            worst = min(worst, fw / base - 1)
            if fw < pf * 0.98:
                fa = [md(E, p, "founder_st", i) for i in range(4)]; fb = [md(E, n, "founder_st", i) for i in range(4)]
                sa = [md(E, p, "stage_w", i) for i in range(4)]; sb = [md(E, n, "stage_w", i) for i in range(4)]
                ta, tb = sum(fa), sum(fb)
                shA = [x / ta for x in fa]; shB = [x / tb for x in fb]
                dom = fa.index(max(fa)) != fb.index(max(fb)); big = max(abs(a - b) for a, b in zip(shA, shB)) >= 0.20
                ss = min(range(4), key=lambda i: fb[i] - fa[i])
                shared = sb[ss] > 0 and fb[ss] / sb[ss] < fa[ss] / sa[ss] - 0.02
                if dom or big: cnt["asama"] += 1; r = "asama"
                elif seq[k - 1] == "pm": cnt["hazirlik"] += 1; r = "hazirlik"
                elif shared: cnt["bolundu"] += 1; r = "bolundu"
                else: cnt["aciklanamayan"] += 1; r = "?"
                rows.append((f, s, k, round(100 * (fw / pf - 1), 1), r))
print(cnt, "toplam", sum(cnt.values()), "en kotu tabana gore %.1f%%" % (100 * worst))
for r in rows: print(r)
