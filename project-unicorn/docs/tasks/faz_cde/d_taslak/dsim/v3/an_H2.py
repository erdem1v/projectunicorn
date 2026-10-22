exec(open("an_common.py", encoding="utf-8").read())
H = L("H"); H2 = L("H2")
def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk
def wmed(R, n, a, b):
    return statistics.median([win(m, a, b) for m in R[n].values()])
print("taban tutarlilik EA3:", wmed(H, "EA3", 20, 60), wmed(H2, "EA3", 20, 60), " EA7:", wmed(H, "EA7", 66, 130), wmed(H2, "EA7", 66, 130))
for tn in ("EA3","EA7"):
    for ak in ("+3* gelistirici","+3* testci","+3* tasarimci","+3* PM"):
        n = "%s %s" % (tn, ak)
        print(n, "%+.1f | %+.1f" % (wmed(H2, n, 20, 60) - wmed(H2, tn, 20, 60), wmed(H2, n, 66, 130) - wmed(H2, tn, 66, 130)))
