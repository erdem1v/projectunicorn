exec(open("an_common.py", encoding="utf-8").read())
bad = 0; tot = 0; worst = 0
Rs = []
for b in ("A","B","C","D","E","G","I","R"):
    Rs.append(L(b))
Rs += list(L("F").values())
for R in Rs:
    for n, d in R.items():
        for s, m in d.items():
            tot += 1
            diff = abs(sum(m["why"].values()) - m["idle_w"])
            worst = max(worst, diff)
            if diff > 1e-6: bad += 1
print("kosu", tot, "nedeni idle'a esit olmayan", bad, "en buyuk fark", worst)
