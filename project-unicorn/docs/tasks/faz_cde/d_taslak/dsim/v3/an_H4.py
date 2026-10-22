exec(open("an_common.py", encoding="utf-8").read())
H = L("H")


def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    dl = sum(x[2] for x in ser) / wk
    idle = sum(x[7] * (x[1] - x[0]) for x in ser) / wk
    return dl, idle


def med(R_, n, a, b, i):
    return statistics.median([win(m, a, b)[i] for m in R_[n].values()])


print("EA fark aciklamasi: tahmin = takimsiz x ort. carpan x (1-bosta_takim)/(1-bosta_takimsiz)")
for (a, b, lab) in ((20, 60, "21-60"), (66, 130, "67-130")):
    d0, i0 = med(H, "EA0", a, b, 0), med(H, "EA0", a, b, 1)
    for n in ("EA1", "EA3", "EA7", "EA3_lidersiz", "EA7_lidersiz"):
        d, i = med(H, n, a, b, 0), med(H, n, a, b, 1)
        m = next(iter(H[n].values()))
        mavg = sum(c * x for c, x in zip(m["cell_n"], m["cell_mult"])) / sum(m["cell_n"])
        pred = d0 * mavg * (1 - i) / (1 - i0)
        print(lab, "%-14s gercek %6.1f takimsiz %6.1f fark %5.1f%% | ort.carpan %.3f bosta %.3f (takimsiz %.3f) tahmin %6.1f aciklama %.0f%%" % (
            n, d, d0, 100 * (d / d0 - 1), mavg, i, i0, pred, 100 * (1 - abs(pred - d) / abs(d0 - d)) if d0 != d else 100))
# takim satiri: hucre basina teslim ve bosta (21-130 pencere, lo=20)
for n in ("EA3", "EA7"):
    m = next(iter(H[n].values()))
    print(n, "hucre n", m["cell_n"], "carpan", ["%.2f" % x for x in m["cell_mult"]], "hucre teslim (medyan)", ["%.1f" % statistics.median([mm["cell_deliv"][i] for mm in H[n].values()]) for i in range(len(m["cell_n"]))])
for n in ("EA0", "EA1", "EA3", "EA7"):
    print(n, "pool_ok %.2f" % md(H, n, "pool_ok"), "stops", next(iter(H[n].values()))["stops"])
