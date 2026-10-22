exec(open("an_common.py", encoding="utf-8").read())
H = L("H"); H2 = L("H2"); P = L("P_p22_kayip1")
def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk
def wm(R_, n, a, b): return statistics.median([win(m, a, b) for m in R_[n].values()])
print("kayip %2 (taban) -> %1 (oneri)")
for n in ("EA0","EA1","EA3","EA3_lidersiz","EA7","EA7_lidersiz"):
    print("%-14s 21-60: %6.1f -> %6.1f | 67-130: %6.1f -> %6.1f | carpan %s -> %s" % (n, wm(H, n, 20, 60), wm(P, n, 20, 60), wm(H, n, 66, 130), wm(P, n, 66, 130),
          ["%.2f" % x for x in next(iter(H[n].values()))["cell_mult"]][:3], ["%.2f" % x for x in next(iter(P[n].values()))["cell_mult"]][:3]))
worst = (0, None)
for tn in ("EA3","EA7"):
    for ak in EA_ADD:
        n = "%s %s" % (tn, ak)
        d1 = (wm(H2, n, 20, 60) - wm(H2, tn, 20, 60), wm(H2, n, 66, 130) - wm(H2, tn, 66, 130))
        d2 = (wm(P, n, 20, 60) - wm(P, tn, 20, 60), wm(P, n, 66, 130) - wm(P, tn, 66, 130))
        print("%-22s %+5.1f %+5.1f -> %+5.1f %+5.1f" % (n, d1[0], d1[1], d2[0], d2[1]))
        for x in d2:
            if x < worst[0]: worst = (x, n)
print("en kotu (kayip 1)", worst)
