import pickle, statistics, math
def L(b, tag=""):
    return pickle.load(open("out/%s%s.pkl" % (b, tag), "rb"))
def md(R, n, k, idx=None):
    return medof(R, n, k, idx)
def tsum(R, n, k, idx):
    return sum(m[k][idx] for m in R[n].values())
def hs(R, n):
    return "%d/%d" % (tsum(R, n, "bs_late", 0), tsum(R, n, "bs_late", 1))
def consec(R, n):
    return sum(1 for m in R[n].values() if m["consec"])
KEYS = ["deliv","per_person","cards_sprint","esc_card","esc100","open_med","open_max","fix_early","fix_late","found_sp","K_sp","asked","infix","tot_fix","idle_w","idle_pct","ready","mvp","founder_w","lead","slope","pred"]
def table(R, names, keys=KEYS):
    print("%-26s" % "senaryo", " ".join("%8s" % k[:8] for k in keys), "hata_sprinti")
    for n in names:
        row = []
        for k in keys:
            v = md(R, n, k)
            row.append("%8.3f" % v if v is not None else "%8s" % "-")
        print("%-26s" % n[:26], " ".join(row), hs(R, n), "ust%d" % consec(R, n), md(R, n, "bott") if False else "")
def pooled_asked(R, n):
    """Soru gelen sprintlerin havuzlanmis payi (21-60. hafta pencere; belgenin §4.8 olcusu)."""
    a = b = 0
    for m in R[n].values():
        for x in m["series"]:
            if x[1] > 20:
                b += 1
                a += 1 if x[8] else 0
    return a / b
BOTT = {"Tasarim": "Tasarım", "Gelistirme": "Geliştirme", "Test": "Test", "yok": "yok"}
