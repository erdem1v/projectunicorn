# Ilke olcusu (Karar 19): teslim edilen ozellik kartlarinda kartin karmasikligi (puan x Yazilim gereksinimi) ile kartin Yazilim isini yapanlarin
# is payi agirlikli ortalama yildizi arasindaki korelasyon, ve en karmasik / en basit ceyrekteki kartlarin ortalama yildizi. python -I a8ilke.py <senaryo> [tohum_sayisi] [kol,kol]
import os, sys, statistics, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
H, A, D = R8.H, R8.A, R8.D


def corr(xs, ys):
    mx, my = sum(xs) / len(xs), sum(ys) / len(ys)
    sx = math.sqrt(sum((x - mx) ** 2 for x in xs))
    sy = math.sqrt(sum((y - my) ** 2 for y in ys))
    return sum((x - mx) * (y - my) for x, y in zip(xs, ys)) / (sx * sy) if sx > 0 and sy > 0 else float("nan")


if __name__ == "__main__":
    scen = sys.argv[1]
    ns = int(sys.argv[2]) if len(sys.argv) > 2 else 5
    arms = sys.argv[3].split(",") if len(sys.argv) > 3 else ["R", "T", "T_plan", "P"]
    for arm in arms:
        cs, ds, top, bot = [], [], [], []
        for sd in range(1, ns + 1):
            R8.set_cfg8(R8.R6.ARMS[arm], sd, "H")
            fn, kw = D.SCEN[scen]
            kw = dict(kw)
            kw.setdefault("weeks", 60)
            sim = H.A6Sim(fn(), sd, trace=True, **kw)
            sim.run()
            rec = [r for r in sim.cardrec if r["kind"] == "feature" and r["done_w"] > A.LO and r["dev"]]
            K, S = [], []
            for r in rec:
                w = sum(v[0] for v in r["dev"].values())
                if w <= 0:
                    continue
                K.append(r["size"] * max(1.0, r["R"]))
                S.append(sum(v[0] * v[1] for v in r["dev"].values()) / w)
            if len(K) >= 8:
                cs.append(corr(K, S))
                srt = sorted(zip(K, S))
                q = max(1, len(srt) // 4)
                bot.append(statistics.mean(s for _, s in srt[:q]))
                top.append(statistics.mean(s for _, s in srt[-q:]))
        print("%-7s %s: karmasiklik-yildiz korelasyonu %.3f | en karmasik ceyrek ortalama yildiz %.2f, en basit ceyrek %.2f (fark %+.2f) | tohum %d" % (
            arm, scen, statistics.mean(c for c in cs if c == c), statistics.mean(top), statistics.mean(bot), statistics.mean(top) - statistics.mean(bot), len(cs)))
