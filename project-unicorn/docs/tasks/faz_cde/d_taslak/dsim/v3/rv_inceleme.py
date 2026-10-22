# Inceleme sonrasi: kabul edilen dort oneri BIRLIKTE (derinlik 1 + hesap/5 en cok 8; atlayarak doldurma 12 aday;
# duzeltme karti alt siniri 2,5 yani "2 puan/hata"). Model baska hicbir yerde degismez. Sonuc out/P_rv_birlesik.pkl.
import pickle, time, os
exec(open("an_common.py", encoding="utf-8").read())
SEEDS = range(1, 21)
env = {"D3_DEPTHMAX": "8", "D3_DEPTHDIV": "5", "D3_FILLSKIP": "12", "D3_FIXMIN": "2.5"}
names = ["A|S%d|kaynakli|%d" % (b, sw) for b in range(1, 7) for sw in (1, 2)] + ["R|S5|330", "R|S6|330", "GC|kaynakli"]
if "run" in sys.argv[3:]:
    os.environ.update(env)
    t = time.time()
    R_ = run_many(names, SEEDS, workers=2)
    pickle.dump(R_, open("out/P_rv_birlesik.pkl", "wb"))
    print("tamam", round(time.time() - t), "sn", flush=True)
P = L("P_rv_birlesik")
G = L("G"); R0 = L("R")
def base(n):
    return R0 if n.startswith("R|") else G
print("%-18s %-22s %-22s %-22s %-22s %-24s %-14s" % ("senaryo", "aday>=hedef", "doluluk", "teslim", "bosta", "duz.payi gec", "hata sprinti"))
for n in names:
    B = base(n)
    def pair(k):
        a, b = md(B, n, k), md(P, n, k)
        return "-" if a is None or b is None else "%.3f -> %.3f" % (a, b)
    print("%-18s %-22s %-22s %-22s %-22s %-24s %s -> %s  kartyok %s" % (n, pair("pool_ok"), pair("fill_ratio"), pair("deliv"), pair("idle_pct"), pair("fix_late"), hs(B, n), hs(P, n), pair("nocard")))
print("pred max", max(m["pred"] for n in P for m in P[n].values()))
