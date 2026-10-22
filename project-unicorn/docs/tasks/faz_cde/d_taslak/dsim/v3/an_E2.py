exec(open("an_common.py", encoding="utf-8").read())
E = L("E")
FN = ["orta","gel4","gel5","tasarim_test"]
SQ = ["gel-tas-test","tas-gel-test","test-gel-tas","pm-gel-tas","1yildiz","uc-gel"]
def fst(n):
    v = [md(E, n, "founder_st", i) for i in range(4)]
    return v
print("kurucu isi: baz (solo) ve adim adim; yuzde degisim; asama dagilimi (tas, gel, test, duz)")
for f in FN:
    for s in SQ:
        base = md(E, "G|%s|%s|0" % (f, s), "founder_w")
        out = []
        for k in range(1, 4):
            n = "G|%s|%s|%d" % (f, s, k)
            fw = md(E, n, "founder_w"); pv = md(E, "G|%s|%s|%d" % (f, s, k-1), "founder_w")
            st = fst(n); pst = fst("G|%s|%s|%d" % (f, s, k-1))
            tot = sum(st) or 1; ptot = sum(pst) or 1
            sh = [x/tot for x in st]; psh = [x/ptot for x in pst]
            ch = max(abs(a-b) for a, b in zip(sh, psh))
            dom = ["T","G","Ts","D"][sh.index(max(sh))]; pdom = ["T","G","Ts","D"][psh.index(max(psh))]
            out.append("%+.1f%%/baz %+.1f%% [%s>%s dp%.2f]" % (100*(fw/pv-1), 100*(fw/base-1), pdom, dom, ch))
        print("%-13s %-13s" % (f, s), " | ".join(out))
