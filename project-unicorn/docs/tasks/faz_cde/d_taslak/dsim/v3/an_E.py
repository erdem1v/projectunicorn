exec(open("an_common.py", encoding="utf-8").read())
E = L("E")
FN = ["orta","gel4","gel5","tasarim_test"]
SQ = ["gel-tas-test","tas-gel-test","test-gel-tas","pm-gel-tas","1yildiz","uc-gel"]
print("== 0. haftadan; teslim / kurucunun isi / MVP")
bad = []
for f in FN:
    for s in SQ:
        row = []
        prev = None; prevmvp=None; prevf=None
        for k in range(4):
            n = "G|%s|%s|%d" % (f, s, k)
            d = md(E, n, "deliv"); fw = md(E, n, "founder_w"); mv = md(E, n, "mvp")
            row.append("%.1f/%.1f/%s" % (d, fw, mv))
            if prev is not None:
                if d <= prev + 1e-9: bad.append(("teslim artmadi", f, s, k, prev, d))
                if mv > prevmvp: bad.append(("MVP gecikti", f, s, k, prevmvp, mv))
                if fw < prevf*(0.9): bad.append(("kurucu isi >%10 dustu", f, s, k, prevf, fw))
            prev, prevmvp, prevf = d, mv, fw
        print("%-13s %-13s" % (f, s), " | ".join(row))
print("sorunlar:", len(bad))
for b in bad: print(b)
