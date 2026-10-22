# A7 inceleme: elle kart hesabi ve kapi kirpmasi. python -I a7el.py
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__)); sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a6run as R6
H, A, D, CFG2 = R6.H, R6.A, R6.D, R6.CFG2
print("dev kapilari:", {ln: {t: v[1] for t, v in d.items()} for ln, d in A.GATES.items()})
for sc in ("S1", "S2", "S3", "S4", "S5", "S6"):
    fn, kw = D.SCEN[sc]
    ppl = fn()
    team = D.Team(ppl, 2)
    ti = A.tinfo(team)
    print(sc, "n=%d" % team.n, "en iyi [tas, yaz, test] =", ti["best"], "PM yildizlari", sorted(ti["pstars"].values(), reverse=True),
          "yazilim yildizlari", sorted((s[1] for i, s in enumerate(ti["stars"]) if team.cls[i][1] is not None and team.cls[i][1] < 3), reverse=True))
# elle: K-H c=0,212
CFG2.hata, CFG2.c, CFG2.p = "yeni", 0.212, 1.0
for size, R, stars in ((15, 1, (1, 5)), (40, 3, (3, 5)), (25, 2, (2, 3, 4)), (40, 3, (2.5,)), (69.6, 3, (3, 5))):
    T = CFG2.c * size * R
    print("K-H puan %.1f R=%d tavan %.3f :" % (size, R, T), ", ".join("%.1f yildiz -> %.3f" % (s, T * H.mfun(s - R)) for s in stars))
for size, R, stars in ((69.6, 3, (3, 5)), (40, 3, (3, 5)), (15, 1, (1, 5)), (10.44, 1, (1, 5))):
    T = H.C_E * size * R
    print("K-E puan %.2f R=%d tavan %.3f :" % (size, R, T), ", ".join("%.1f yildiz -> %.3f" % (s, T * H.mfun(s - R)) for s in stars))
# bugunku model ayni kartlar
for size, s in ((15, 1), (15, 5), (40, 3), (40, 5)):
    print("bugun puan %d %d yildiz: %.3f" % (size, s, D.H0 * size / D.Y(2 * s) ** 0.5))
