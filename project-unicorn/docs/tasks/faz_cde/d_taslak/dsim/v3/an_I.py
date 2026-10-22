exec(open("an_common.py", encoding="utf-8").read())
I = L("I")
def d5_hit(m, abs30=False):
    openw, delw, livew, mvp = m["openw"], m["delw"], m["livew"], m["mvp"]
    for i in range(len(openw)):
        wk = i + 1
        if mvp is None or wk <= mvp: continue
        d8 = statistics.mean(delw[max(0, i - 7):i + 1])
        k = 1.0 if abs30 else max(1.0, livew[i] / 9.0, math.sqrt(d8 / 55.0))
        if openw[i] >= 30 * k:
            return wk - mvp, 30 * k
    return None, None
def kfinal(m):
    d8 = statistics.mean(m["delw"][-8:]); return max(1.0, m["livew"][-1]/9.0, math.sqrt(d8/55.0))
print("== D5")
for b in ["S1","S2","S3","S4","S5","S6"]:
    for arm in ("nofix", "fix"):
        R = I["D5|%s|%s" % (b, arm)]
        hits = [d5_hit(m)[0] for m in R.values()]
        h30 = [d5_hit(m, True)[0] for m in R.values()]
        ok = [h for h in hits if h is not None]
        ok30 = [h for h in h30 if h is not None]
        peaks = [max(m["openw"]) for m in R.values()]
        ks = [kfinal(m) for m in R.values()]
        print(b, arm, "esige varan %d/20" % len(ok), "medyan hafta", statistics.median(ok) if ok else None, "(min %s max %s)" % (min(ok) if ok else None, max(ok) if ok else None),
              "| mutlak30: %d/20 medyan %s" % (len(ok30), statistics.median(ok30) if ok30 else None), "| tepe medyan %.1f max %d" % (statistics.median(peaks), max(peaks)), "k_son %.2f esik %.0f" % (statistics.median(ks), 30*statistics.median(ks)))
