exec(open("an_common.py", encoding="utf-8").read())
A = L("A"); D = L("D")
# havuzlanmis soru payi: sprint serisinden (x[8] asked) pencere end>20
def pooled(R_, n):
    a = b = 0
    for m in R_[n].values():
        for x in m["series"]:
            if x[1] > 20:
                b += 1; a += 1 if x[8] else 0
    return a / b
for n in ("S1","S2","S3","S4","S5","S6","S7","S10","S11b"):
    print(n, "havuz %.1f%%" % (100*pooled(A, n)), "medyan %.1f%%" % (100*md(A, n, "asked")))
print("12 kisi 2x5*", "havuz %.1f%%" % (100*pooled(D, "T4_5")))
