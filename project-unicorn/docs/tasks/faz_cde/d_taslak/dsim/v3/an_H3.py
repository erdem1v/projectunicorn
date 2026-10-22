exec(open("an_common.py", encoding="utf-8").read())
H = L("H"); H2 = L("H2"); H3 = L("H3", "_kayip0")


def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk


def wmed(R_, n, a, b):
    return statistics.median([win(m, a, b) for m in R_[n].values()])


print("kayip kapali (TEAMLOSS=0): kisi ekleme farki  [21-60 | 67-130]  (kayip acik: [21-60 | 67-130])")
for tn in ("EA3", "EA7"):
    for ak in EA_ADD:
        n = "%s %s" % (tn, ak)
        d0 = (wmed(H3, n, 20, 60) - wmed(H3, tn, 20, 60), wmed(H3, n, 66, 130) - wmed(H3, tn, 66, 130))
        d1 = (wmed(H2, n, 20, 60) - wmed(H2, tn, 20, 60), wmed(H2, n, 66, 130) - wmed(H2, tn, 66, 130))
        print("%-22s %+6.1f %+6.1f   |  %+6.1f %+6.1f" % (n, d0[0], d0[1], d1[0], d1[1]))
print("takimsiz EA0 (kayipsiz kosuda da ayni):", wmed(H3, "EA0", 20, 60), wmed(H3, "EA0", 66, 130))
print("kayip kapali EA3/EA7 teslim:", wmed(H3, "EA3", 20, 60), wmed(H3, "EA3", 66, 130), wmed(H3, "EA7", 20, 60), wmed(H3, "EA7", 66, 130))
