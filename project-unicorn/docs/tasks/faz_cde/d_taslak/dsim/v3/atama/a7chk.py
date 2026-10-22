# A7 inceleme: ana tablodan sayilari ham pkl'den bagimsiz yeniden hesaplar (a6tab'i kullanmaz). python -I a7chk.py
import os, sys, pickle, math, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")


def ld(tag, cal, arm, scen):
    return pickle.load(open(os.path.join(HERE, "out6", tag, cal, arm + "__" + scen.replace("|", "_") + ".pkl"), "rb"))


def f_soz(m):
    p = m["prom"]
    return (p["late"] + p["undel"]) / p["due"] if p and p["due"] else None


GET = {"teslim": lambda m: m["deliv"], "acik": lambda m: m["open_med"], "dogan": lambda m: m["born"], "kacan": lambda m: m["esc"],
       "mvp": lambda m: m["mvp"], "soz": f_soz, "H": lambda m: m["H"]}


def per(tag, cal, arm, scen, k):
    d = ld(tag, cal, arm, scen)
    return {s: GET[k](m) for s, m in d.items() if GET[k](m) is not None}


def mean(tag, cal, arm, scen, k):
    v = per(tag, cal, arm, scen, k)
    return sum(v.values()) / len(v), len(v)


def pair(tag, cal, a, b, scen, k):
    va, vb = per(tag, cal, a, scen, k), per(tag, cal, b, scen, k)
    d = [va[s] - vb[s] for s in sorted(set(va) & set(vb))]
    n = len(d)
    m = sum(d) / n
    sd = math.sqrt(sum((x - m) ** 2 for x in d) / (n - 1))
    return m, sd / math.sqrt(n), sum(1 for x in d if x < 0), n


print("== 8 ana tablo hucresi (K-H)")
for arm, scen, k in (("T", "S5", "teslim"), ("R", "PR|S2", "acik"), ("T", "PR|S2", "acik"), ("T", "PR|S3", "soz"), ("R", "PR|S3", "soz"),
                     ("BK", "S6", "teslim"), ("R", "PR|S6", "teslim"), ("T", "S4", "acik"), ("BK", "PR|S3", "soz"), ("T", "S2", "mvp")):
    print(arm, scen, k, "%.4f n=%d" % mean("ana", "H", arm, scen, k))
print("== esli farklar (K-H)")
for a, b, scen, k in (("T", "R", "PR|S6", "teslim"), ("T", "R", "PR|S2", "acik"), ("T", "R", "S6", "dogan"), ("T", "R", "PR|S3", "soz"),
                      ("T", "R", "S4", "dogan"), ("T", "R", "S2", "mvp"), ("T_zor", "T", "S4", "teslim"), ("T", "E", "S6", "dogan")):
    print("%s-%s %s %s  %+.4f se %.4f  neg %d/%d" % ((a, b, scen, k) + pair("ana", "H", a, b, scen, k)))
print("== K-H kalibrasyonu (S3, R, 21-60)")
for tag, cal in (("kal", "0"), ("ana", "0"), ("kal", "0.212"), ("ana", "H")):
    try:
        b, n = mean(tag, cal, "R", "S3", "dogan")
        h, _ = mean(tag, cal, "R", "S3", "H")
        print(tag, cal, "dogan %.3f  beklenen %.3f  n=%d" % (b, h, n))
    except Exception as e:
        print(tag, cal, "yok", e)
print("== yeni / bugunku dogan, R kolu (K-H ve K-E), tum hucreler")
for sc in ("S1", "S2", "S3", "S4", "S5", "S6", "PR|S1", "PR|S2", "PR|S3", "PR|S4", "PR|S5", "PR|S6"):
    b0, _ = mean("ana", "0", "R", sc, "dogan")
    bh, _ = mean("ana", "H", "R", sc, "dogan")
    be, _ = mean("ana", "E", "R", sc, "dogan")
    hh, _ = mean("ana", "H", "R", sc, "H")
    h0, _ = mean("ana", "0", "R", sc, "H")
    print("%-6s bugun %.1f  K-H %.2f (beklenen %.2f)  K-E %.2f" % (sc, b0, bh / b0, hh / h0, be / b0))
