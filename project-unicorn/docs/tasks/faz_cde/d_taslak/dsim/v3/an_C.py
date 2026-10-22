exec(open("an_common.py", encoding="utf-8").read())
C = L("C")
prev = None; worst = (0, None); neg = 0
rows = []
for n in range(1, 51):
    nm = "C%d" % n
    d = md(C, nm, "deliv")
    mg = None if prev is None else d - prev
    if mg is not None and mg < worst[0]: worst = (mg, n)
    if mg is not None and mg < -1.0: neg += 1
    rows.append((n, d, mg, md(C, nm, "esc_card"), md(C, nm, "open_med"), md(C, nm, "idle_pct"), md(C, nm, "bott") if False else None))
    prev = d
print("en kotu adim", worst, " (-1'den kotu adim sayisi %d)" % neg)
for r in rows:
    if r[2] is None or r[2] < 0.5 or r[0] in (1,2,3,6,12,25,37,50):
        print(r[0], "%.1f" % r[1], None if r[2] is None else "%+.1f" % r[2], "esc %.2f open %.1f idle %.3f" % (r[3], r[4], r[5]))
# genel A hedefleri: n>=2
mx = {"fe": (0, None), "fl": (0, None), "hs": (0, None)}
for n in range(2, 51):
    nm = "C%d" % n
    for k, key in (("fe", "fix_early"), ("fl", "fix_late")):
        v = md(C, nm, key)
        if v is not None and v > mx[k][0]: mx[k] = (v, n)
    hsv = tsum(C, nm, "bs_late", 0) / max(1, tsum(C, nm, "bs_late", 1))
    if hsv > mx["hs"][0]: mx["hs"] = (hsv, n)
print("curve n>=2 en yuksek", mx, "ust uste:", [n for n in range(2,51) if consec(C, "C%d"%n)])
print("pred max", max(m["pred"] for nm in C for m in C[nm].values()))
