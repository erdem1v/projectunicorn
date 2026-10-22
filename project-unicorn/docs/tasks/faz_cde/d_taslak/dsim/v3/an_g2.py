exec(open("an_common.py", encoding="utf-8").read())
E = L("E")
FN = ["orta","gel4","gel5","tasarim_test"]
SQ = ["gel-tas-test","tas-gel-test","test-gel-tas","pm-gel-tas","1yildiz","uc-gel"]
for f in FN:
    for s in SQ:
        for k in range(1, 4):
            n = "G|%s|%s|%d" % (f, s, k); p = "G|%s|%s|%d" % (f, s, k-1)
            fw, pf = md(E, n, "founder_w"), md(E, p, "founder_w")
            if fw < pf * 0.98:
                fa = [md(E, p, "founder_st", i) for i in range(4)]; fb = [md(E, n, "founder_st", i) for i in range(4)]
                sa = [md(E, p, "stage_w", i) for i in range(4)]; sb = [md(E, n, "stage_w", i) for i in range(4)]
                ta = sum(fa); tb = sum(fb)
                dom_a = fa.index(max(fa)); dom_b = fb.index(max(fb))
                shA = [x/ta for x in fa]; shB = [x/tb for x in fb]
                big = max(abs(a-b) for a, b in zip(shA, shB))
                print(f, s, k, "%.1f%%" % (100*(fw/pf-1)), "dom", dom_a, ">", dom_b, "dpay %.2f" % big,
                      "kurucu payi (asama):", ["%.2f>%.2f" % (fa[i]/sa[i] if sa[i] else 0, fb[i]/sb[i] if sb[i] else 0) for i in range(3)])
