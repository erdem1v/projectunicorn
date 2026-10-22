# A9 (Opus incelemesi): A8 tablolarindan secilen sayilari ham pkl'den, a8tab.py'yi kullanmadan yeniden hesaplar.  python -I a9chk.py
import os, sys, pickle, math
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
A6 = ("R", "T", "T_plan")


def rec(arm, scen, tag="ana"):
    d = "out6" if arm in A6 else ("out9" if arm.endswith("_k9") else "out8")
    return pickle.load(open(os.path.join(HERE, d, tag, "H", arm + "__" + scen.replace("|", "_") + ".pkl"), "rb"))


NPM = {"S1": 0, "S2": 0, "S3": 1, "S4": 2, "S5": 3, "S6": 6}


def val(m, scen, met):
    if met == "bosta":                          # PM haric bosta: toplam bosta insan-hafta eksi PM'in bosta zamani, PM olmayan insan-haftaya bolunur
        n = m["n"] - NPM[scen.split("|")[-1]]
        return (m["idle_w"] * m["wkwin"] - m["detail"]["pm_bosta"]) / (n * m["wkwin"])
    if met == "soz":
        p = m["prom"]
        return (p["late"] + p["undel"]) / p["due"] if p["due"] else None
    return m[met]


def stat(xs):
    n = len(xs)
    mu = sum(xs) / n
    sd = math.sqrt(sum((x - mu) ** 2 for x in xs) / (n - 1))
    return mu, sd / math.sqrt(n)


def mean(arm, scen, met):
    r = rec(arm, scen)
    xs = [val(r[s], scen, met) for s in sorted(r)]
    xs = [x for x in xs if x is not None]
    return sum(xs) / len(xs), len(xs)


def pair(a, b, scen, met):
    ra, rb = rec(a, scen), rec(b, scen)
    d = []
    for s in sorted(set(ra) & set(rb)):
        x, y = val(ra[s], scen, met), val(rb[s], scen, met)
        if x is not None and y is not None:
            d.append(x - y)
    mu, se = stat(d)
    return mu, se, sum(1 for x in d if x < 0), len(d)


if __name__ == "__main__":
    checks = [
        ("P MVP, 6 kisi sinirsiz", "mean", ("P", "S3", "mvp")),
        ("P-R MVP, 6 kisi sinirsiz", "pair", ("P", "R", "S3", "mvp")),
        ("P acik hata, kaynakli 3 kisi", "mean", ("P", "PR|S2", "open_med")),
        ("P-R acik hata, kaynakli 3 kisi", "pair", ("P", "R", "PR|S2", "open_med")),
        ("P-T acik hata, kaynakli 3 kisi", "pair", ("P", "T", "PR|S2", "open_med")),
        ("P kacan soz, kaynakli 6 kisi", "mean", ("P", "PR|S3", "soz")),
        ("P-T kacan soz, kaynakli 6 kisi", "pair", ("P", "T", "PR|S3", "soz")),
        ("P teslim, 50 kisi sinirsiz", "mean", ("P", "S6", "deliv")),
        ("P-T teslim, 50 kisi sinirsiz", "pair", ("P", "T", "S6", "deliv")),
        ("P-R bosta PM haric, 12 kisi", "pair", ("P", "R", "S4", "bosta")),
        ("P-R dogan hata, 50 kisi", "pair", ("P", "R", "S6", "born")),
        ("P-P_sabit teslim, kaynakli 50 kisi", "pair", ("P", "P_sabit", "PR|S6", "deliv")),
        ("P-R teslim, 12 kisi", "pair", ("P", "R", "S4", "deliv")),
        ("T MVP, 3 kisi sinirsiz", "mean", ("T", "S2", "mvp")),
    ]
    for name, kind, args in checks:
        if kind == "mean":
            mu, n = mean(*args)
            print("%-40s %.4f (n=%d)" % (name, mu, n))
        else:
            mu, se, neg, n = pair(*args)
            print("%-40s %+.4f +- %.4f (%d/%d)" % (name, mu, se, neg, n))
    # tutarlilik: PM dahil bosta = idle_w / n
    r = rec("P", "S4")
    print("idle_pct ile idle_w/n en buyuk fark (P, S4):", max(abs(m["idle_pct"] - m["idle_w"] / m["n"]) for m in r.values()))
    # MVP tohum tohum, 3 kisi sinirsiz (iz 2'nin tohumu)
    for arm in ("R", "T", "T_plan", "P", "P_sabit"):
        r = rec(arm, "S2")
        print("S2 MVP", arm, [r[s]["mvp"] for s in sorted(r)])
    for arm in ("R", "T", "T_plan", "P", "P_sabit"):
        r = rec(arm, "PR|S2")
        print("PR|S2 MVP", arm, [r[s]["mvp"] for s in sorted(r)])
    # P_gyok karistirici: gereksinim kapisi ile birlikte hata modelinin gereksinimi de 0 oluyor mu
    for scen in ("S4", "S5", "PR|S4"):
        for arm in ("P", "P_gyok", "R"):
            r = rec(arm, scen)
            print("%-6s %-8s dogan %.1f bulunan %.1f kacan %.1f teslim %.2f duzeltme payi %.3f" % (
                scen, arm, sum(m["born"] for m in r.values()) / len(r), sum(m["found"] for m in r.values()) / len(r),
                sum(m["esc"] for m in r.values()) / len(r), sum(m["deliv"] for m in r.values()) / len(r),
                sum(m["tot_fix"] for m in r.values()) / len(r)))
    # plan suresi: 50 kisi
    for scen in ("S6", "PR|S6", "S3"):
        r = rec("P", scen)
        ro = sum(m["p8"]["rollouts"] for m in r.values())
        ns = sum(m["p8"]["nsprints"] for m in r.values())
        sec = sum(m["p8"]["secs"] for m in r.values())
        wall = sum(m["p8"]["wall"] for m in r.values())
        miss = sum(m["p8"]["miss"] for m in r.values())
        print("plan %s: oynatma/sprint %.2f, sn/sprint %.3f, ms/oynatma %.1f, kacan (arama yapilan) hafta basi/sprint %.2f, kosu suresi ort %.1f sn" % (
            scen, ro / ns, sec / ns, 1000 * sec / ro, miss / ns, wall / len(r)))
