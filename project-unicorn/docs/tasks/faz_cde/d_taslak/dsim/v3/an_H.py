exec(open("an_common.py", encoding="utf-8").read())
H = L("H")
def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    if not wk: return None
    dl = sum(x[2] for x in ser) / wk
    idle = sum(x[7] * (x[1] - x[0]) for x in ser) / wk
    nocard = sum(1 for x in ser if x[4]) / len(ser)
    return dl, idle, nocard
def wmed(R, n, a, b, i):
    return statistics.median([win(m, a, b)[i] for m in R[n].values()])
names = ["EA0","EA1","EA3","EA3_lidersiz","EA7","EA7_lidersiz"]
print("EA: teslim/hf (21-60 | 67-130), bosta oran, kart-yok sprint payi")
for n in names:
    print("%-14s" % n, "teslim %6.1f | %6.1f" % (wmed(H, n, 20, 60, 0), wmed(H, n, 66, 130, 0)), " idle %.3f | %.3f" % (wmed(H, n, 20, 60, 1), wmed(H, n, 66, 130, 1)), " nocard %.2f | %.2f" % (wmed(H, n, 20, 60, 2), wmed(H, n, 66, 130, 2)),
          "hucre n", H[n][1]["cell_n"], "carpan", ["%.2f" % x for x in H[n][1]["cell_mult"]], "pool_ok %s" % md(H, n, "pool_ok"))
print("EA kisi ekleme (130 hafta tum pencere teslim, 66-130)")
for tn in ("EA3","EA7"):
    for ak in ("+3* gelistirici","+3* testci","+3* tasarimci","+3* PM"):
        n = "%s %s" % (tn, ak)
        print(n, "%+.1f | %+.1f" % (wmed(H, n, 20, 60, 0) - wmed(H, tn, 20, 60, 0), wmed(H, n, 66, 130, 0) - wmed(H, tn, 66, 130, 0)))
print("pred max", max(m["pred"] for n in H for m in H[n].values()))
