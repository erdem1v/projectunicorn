exec(open("an_common.py", encoding="utf-8").read())
H = L("H"); H2 = L("H2"); P = L("P_p22b_marjinal")
def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk
def wm(R_, n, a, b): return statistics.median([win(m, a, b) for m in R_[n].values()])
print("tum-takim kaybi (taban) -> marjinal kayip (oneri)")
for n in ("EA3","EA3_lidersiz","EA7","EA7_lidersiz"):
    print("%-14s 21-60: %6.1f -> %6.1f | 67-130: %6.1f -> %6.1f | ort carpan %s -> %s" % (n, wm(H, n, 20, 60), wm(P, n, 20, 60), wm(H, n, 66, 130), wm(P, n, 66, 130),
          ["%.2f" % x for x in next(iter(H[n].values()))["cell_mult"]], ["%.2f" % x for x in next(iter(P[n].values()))["cell_mult"]]))
worst = (0, None)
for tn in ("EA3","EA7"):
    for ak in EA_ADD:
        n = "%s %s" % (tn, ak)
        d1 = (wm(H2, n, 20, 60) - wm(H2, tn, 20, 60), wm(H2, n, 66, 130) - wm(H2, tn, 66, 130))
        d2 = (wm(P, n, 20, 60) - wm(P, tn, 20, 60), wm(P, n, 66, 130) - wm(P, tn, 66, 130))
        print("%-22s %+5.1f %+5.1f -> %+5.1f %+5.1f" % (n, d1[0], d1[1], d2[0], d2[1]))
        for x in d2:
            if x < worst[0]: worst = (x, n)
print("en kotu (marjinal)", worst)
e0 = wm(H, "EA0", 66, 130)
print("takimsiz", e0, "EA3 marjinal / takimsiz", wm(P, "EA3", 66, 130)/e0, "EA7", wm(P, "EA7", 66, 130)/e0, "lidersiz3", wm(P, "EA3_lidersiz", 66, 130)/e0, "lidersiz7", wm(P, "EA7_lidersiz", 66, 130)/e0)
