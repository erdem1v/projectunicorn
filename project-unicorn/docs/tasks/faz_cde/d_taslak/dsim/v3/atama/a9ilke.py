# A9 (Opus incelemesi): a8ilke.py'nin olcusu Yazilim disindaki satirlarda (Test, Tasarim). Kartin karmasikligi (puan x Yazilim gereksinimi) ile o satirin
# isini yapanlarin is payi agirlikli ortalama yildizi arasindaki korelasyon.  python -I a9ilke.py <senaryo> <tohum_sayisi> <kol,kol> <satir: test|des|dev>
import os, sys, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8run as R8
import a8ilke as I
H, A, D = R8.H, R8.A, R8.D

if __name__ == "__main__":
    scen, ns, arms, row = sys.argv[1], int(sys.argv[2]), sys.argv[3].split(","), sys.argv[4]
    for arm in arms:
        cs, top, bot, nk = [], [], [], 0
        for sd in range(1, ns + 1):
            R8.set_cfg8(R8.R6.ARMS[arm], sd, "H")
            fn, kw = D.SCEN[scen]
            kw = dict(kw)
            kw.setdefault("weeks", 60)
            sim = H.A6Sim(fn(), sd, trace=True, **kw)
            sim.run()
            K, S = [], []
            for r in sim.cardrec:
                if r["kind"] != "feature" or r["done_w"] <= A.LO or not r[row]:
                    continue
                w = sum(v[0] for v in r[row].values())
                if w <= 0:
                    continue
                K.append(r["size"] * max(1.0, r["R"]))
                S.append(sum(v[0] * v[1] for v in r[row].values()) / w)
            if len(K) >= 8 and len(set(S)) > 1:
                nk += len(K)
                cs.append(I.corr(K, S))
                srt = sorted(zip(K, S))
                q = max(1, len(srt) // 4)
                bot.append(statistics.mean(s for _, s in srt[:q]))
                top.append(statistics.mean(s for _, s in srt[-q:]))
        print("%-7s %s satir=%s: korelasyon %.3f | en karmasik ceyrek yildiz %.2f, en basit %.2f (fark %+.2f) | tohum %d, kart %d" % (
            arm, scen, row, statistics.mean(c for c in cs if c == c), statistics.mean(top), statistics.mean(bot), statistics.mean(top) - statistics.mean(bot), len(cs), nk), flush=True)
