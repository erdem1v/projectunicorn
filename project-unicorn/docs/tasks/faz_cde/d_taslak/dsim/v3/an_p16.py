exec(open("an_common.py", encoding="utf-8").read())
G = L("G"); R0 = L("R")
base = {}
for n in ("A|S5|kaynakli|2", "A|S6|kaynakli|2", "GC|kaynakli"): base[n] = G[n]
for n in ("R|S5|330", "R|S6|330"): base[n] = R0[n]
import os
def show(tag, R_):
    for n in ("A|S5|kaynakli|2", "A|S6|kaynakli|2", "R|S5|330", "R|S6|330", "GC|kaynakli"):
        if n not in R_: continue
        print("%-12s %-18s teslim %6.1f idle %.3f pool_ok %.2f nocard %.2f derinlik karti %s istek %s" % (tag, n, md(R_, n, "deliv"), md(R_, n, "idle_pct"), md(R_, n, "pool_ok"), md(R_, n, "nocard"), md(R_, n, "req", 5), md(R_, n, "req", 4)))
show("taban", base)
for t in ("p16_d8", "p16_dinf", "p16_div5", "p16c_d8div5", "p16d_dinfdiv5", "p16b_d8skip"):
    if os.path.exists("out/P_%s.pkl" % t):
        show(t, L("P_" + t))
