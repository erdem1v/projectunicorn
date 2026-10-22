# Hizalama: en iyiler karmasik kartlara gidiyor mu? Yazilim isinin ortalama m(delta)'si, isle ve kartin tavaniyla agirlikli. python -I a6hiza.py <kal> <senaryo,...>
import sys, statistics
sys.path.insert(0, ".")
sys.stdout.reconfigure(encoding="utf-8")
import a6iz as Z
R6, H = Z.R6, Z.H
cal = sys.argv[1]
for scen in sys.argv[2].split(","):
    for arm in ("R", "T", "BK"):
        wsum = wm = tsum = tm = starw = 0.0
        hi_w = hi_n = lo_w = lo_n = 0.0
        for sd in range(1, 21):
            sim, alog, weeks = Z.run_trace(scen, sd, arm, cal)
            for r in sim.cardrec:
                if r["kind"] != "feature" or r["done_w"] <= 20:
                    continue
                w = sum(v[0] for v in r["dev"].values())
                if w <= 0:
                    continue
                mc = sum(v[0] * H.mfun(v[1] - r["R"]) for v in r["dev"].values()) / w
                avg_star = sum(v[0] * v[1] for v in r["dev"].values()) / w
                T = r["size"] * r["R"]
                wsum += w; wm += w * mc
                tsum += T; tm += T * mc
                if r["R"] >= 2:
                    hi_w += w; hi_n += w * avg_star
                else:
                    lo_w += w; lo_n += w * avg_star
        print("%-4s %-3s isle agirlikli ort. m %.4f | tavanla agirlikli ort. m %.4f | oran %.3f | Yazilim yildizi ort.: R>=2 kartlar %.2f, R=1 kartlar %.2f" % (scen, arm, wm / wsum, tm / tsum, (tm / tsum) / (wm / wsum), hi_n / hi_w if hi_w else float("nan"), lo_n / lo_w if lo_w else float("nan")))
