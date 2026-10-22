# Rapor tablolari (hepsi out/'dan). tables() -> {anahtar: markdown}. python -I a3tablolar.py: hepsini basar.
import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a3tab as T

SC = T.SC
ALLARMS = ["R", "E", "E_np", "E_min", "E_asama", "E_gsira", "E_sert", "E_gyok", "E_pmr", "R_pme"]
_pp = lambda x: T.f1(100 * x, 1) + " pp"


def tables():
    t = {}
    for key, arms, m in (("teslim", ["L", "R", "E"], "teslim"), ("bosta", ["L", "R", "E"], "bosta"), ("bosta_pmsiz", ["R", "E"], "bosta_pmsiz"),
                         ("mvp", ["L", "R", "E"], "mvp"), ("hata", ["L", "R", "E"], "hata"), ("doluluk", ["L", "R", "E"], "doluluk"),
                         ("cekme", ["L", "R", "E"], "cekme"), ("kacan100", ["L", "R", "E"], "kacan100")):
        t["t1_" + key] = T.table("main", arms, m)
    for key, m in (("kacan_soz", "kacan_soz"), ("teslim", "teslim"), ("bosta", "bosta"), ("mvp", "mvp"), ("doluluk", "doluluk"), ("hata", "hata")):
        t["t2_" + key] = T.table("pr", ["L", "R", "E"], m, pre="PR|")
    for key, m, fm in (("teslim", "teslim", lambda x: T.f1(x, 1)), ("hata", "hata", lambda x: T.f1(x, 1)), ("bosta", "bosta", _pp)):
        t["t3_" + key] = T.paired_table("main", [("E", "R")], m, fmt=fm)
    for key, m in (("teslim", "teslim"), ("hata", "hata"), ("bosta", "bosta_pmsiz"), ("mvp", "mvp"), ("kacan100", "kacan100")):
        t["t4_" + key] = T.table("main", ALLARMS, m)
    for a in ("R", "E", "E_sert", "E_gate"):
        t["t5_" + a] = T.cause_table("main", a)
    sc9 = SC + ["S4_1PM", "S5_1PM", "S6_2PM"]
    for key, m in (("teslim", "teslim"), ("bosta", "bosta_pmsiz"), ("hata", "hata"), ("mvp", "mvp")):
        t["t6_" + key] = T.table("main", ["R", "R_gate", "E", "E_gate"], m, scens=sc9)
    t["t6_fark"] = T.paired_table("main", [("R_gate", "R"), ("E_gate", "E")], "teslim", scens=sc9)
    t["t6_fark_bosta"] = T.paired_table("main", [("R_gate", "R"), ("E_gate", "E")], "bosta_pmsiz", scens=sc9, fmt=_pp)
    t["t6_E_gate_neden"] = T.cause_table("main", "E_gate", scens=sc9)
    t["t6_R_gate_neden"] = T.cause_table("main", "R_gate", scens=sc9)
    for key, m in (("teslim", "teslim"), ("hata", "hata"), ("bosta", "bosta_pmsiz")):
        t["t7_" + key] = T.table("main", ["E", "RND", "REV"], m)
    t["t7_fark"] = T.paired_table("main", [("RND", "E"), ("REV", "E")], "teslim")
    t["t7_fark_hata"] = T.paired_table("main", [("RND", "E"), ("REV", "E")], "hata")
    t["t8_stab"] = T.stab_table("main", ["R", "E_np", "E"])
    t["t8_karar"] = T.table("main", ["R", "E_np", "E"], "karar")
    t["t9_plan"] = T.warn_table("main", "R", scens=["S2", "S3", "S4", "S5", "S6"])
    t["t9_plan_E"] = T.warn_table("main", "E", scens=["S2", "S3", "S4", "S5", "S6"])
    t["t9_pred"] = T.warn_table("main", "R", scens=["S2", "S3", "S4", "S5", "S6"], which="pred", thetas=(0.25,))
    for key, m in (("teslim", "teslim"), ("hata", "hata")):
        t["t9_uyari_" + key] = T.table("main", ["R", "R_uyari", "R_uyari2", "E", "E_uyari", "E_uyari2"], m, scens=["S2", "S3", "S4", "S5", "S6"])
    for key, m in (("teslim", "teslim"), ("hata", "hata"), ("bosta", "bosta_pmsiz")):
        t["t10_" + key] = T.table("usta", ["R", "E", "USTA", "USTA1"], m, common=True)
    t["t10_fark"] = T.paired_table("usta", [("USTA", "E"), ("USTA", "R"), ("USTA1", "E"), ("USTA1", "R")], "teslim")
    t["t10_fark_hata"] = T.paired_table("usta", [("USTA", "E"), ("USTA", "R"), ("USTA1", "E"), ("USTA1", "R")], "hata")
    t["t4_fark_teslim"] = T.paired_table("main", [("E_pmr", "R"), ("R_pme", "R"), ("E_np", "E"), ("E_min", "E"), ("E_asama", "E"), ("E_gsira", "E"), ("E_sert", "E"), ("E_gyok", "E")], "teslim")
    t["t4_fark_hata"] = T.paired_table("main", [("E_pmr", "R"), ("R_pme", "R"), ("E_np", "E"), ("E_min", "E"), ("E_asama", "E"), ("E_gsira", "E"), ("E_sert", "E"), ("E_gyok", "E")], "hata")
    t["t7_fark_R"] = T.paired_table("main", [("RND", "R"), ("REV", "R")], "teslim")
    t["t7_fark_R_hata"] = T.paired_table("main", [("RND", "R"), ("REV", "R")], "hata")
    t["t3_pr_teslim"] = T.paired_table("pr", [("E", "R")], "teslim", pre="PR|")
    t["t3_pr_hata"] = T.paired_table("pr", [("E", "R")], "hata", pre="PR|")
    t["t3_pr_soz"] = T.paired_table("pr", [("E", "R")], "kacan_soz", pre="PR|", fmt=_pp)
    t["t2_dep_teslim"] = T.table("dep", ["L", "R", "E"], "teslim", scens=["S3", "S4", "S5"], pre="DEP|")
    t["t2_dep_hata"] = T.table("dep", ["L", "R", "E"], "hata", scens=["S3", "S4", "S5"], pre="DEP|")
    t["t2_dep_fark"] = T.paired_table("dep", [("E", "R")], "teslim", scens=["S3", "S4", "S5"], pre="DEP|")
    t["t9_uyari_fark"] = T.paired_table("main", [("R_uyari", "R"), ("R_uyari2", "R"), ("E_uyari", "E"), ("E_uyari2", "E")], "teslim", scens=["S2", "S3", "S4", "S5", "S6"])
    t.update(extra())
    return t


def extra():
    import statistics, collections
    t = {}
    fam = ["R", "E", "E_pmr", "R_pme", "E_np", "E_min", "E_asama", "E_gsira", "E_sert", "RND", "REV"]
    rows = {"R ortancası": [], "Tarif (E) ortancası": [], "Seed başına en iyi kural (11 kuraldan)": []}
    rowh = {"R ortancası": [], "Tarif (E) ortancası": [], "Seed başına en az hatalı kural (11 kuraldan)": []}
    for sc in SC:
        data = {a: T.load("main", a, sc) for a in fam}
        seeds = sorted(set.intersection(*[set(d) for d in data.values()]))
        rows["R ortancası"].append(T.f1(statistics.median([data["R"][s]["deliv"] for s in seeds])))
        rows["Tarif (E) ortancası"].append(T.f1(statistics.median([data["E"][s]["deliv"] for s in seeds])))
        rows["Seed başına en iyi kural (11 kuraldan)"].append(T.f1(statistics.median([max(data[a][s]["deliv"] for a in fam) for s in seeds])))
        rowh["R ortancası"].append(T.f1(statistics.median([data["R"][s]["open_med"] for s in seeds])))
        rowh["Tarif (E) ortancası"].append(T.f1(statistics.median([data["E"][s]["open_med"] for s in seeds])))
        rowh["Seed başına en az hatalı kural (11 kuraldan)"].append(T.f1(statistics.median([min(data[a][s]["open_med"] for a in fam) for s in seeds])))
    NL = chr(10)
    hdr = "| Ölçü | " + " | ".join(SC) + " |" + NL + "|---|" + "---|" * len(SC) + NL
    t["x_bestof_teslim"] = hdr + NL.join("| %s | %s |" % (k, " | ".join(v)) for k, v in rows.items())
    t["x_bestof_hata"] = hdr + NL.join("| %s | %s |" % (k, " | ".join(v)) for k, v in rowh.items())
    names = ["Tasarım", "Geliştirme", "Test"]
    out = ["| Ölçek | Taşma yok | Tasarım | Geliştirme | Test | Plan anındaki en yüklü satır = gerçekte taşan satır |", "|---|---|---|---|---|---|"]
    for arm in ("R", "E"):
        for sc in ["S2", "S3", "S4", "S5", "S6"]:
            c = collections.Counter()
            n = nov = match = nt = 0
            for m in T.load("main", arm, sc).values():
                for row in m["rows"]:
                    n += 1
                    tr, pl = row["true"], row["plan"]
                    j = max(range(3), key=lambda i: tr[i])
                    if tr[j] >= 0.25:
                        c[names[j]] += 1
                        nt += 1
                        match += (max(range(3), key=lambda i: pl[i]) == j)
                    else:
                        nov += 1
            out.append("| %s %s | %s | %s | %s | %s | %s |" % (arm, sc, T.pct(nov / n, 0), T.pct(c["Tasarım"] / n, 0), T.pct(c["Geliştirme"] / n, 0), T.pct(c["Test"] / n, 0), T.pct(match / nt if nt else None, 0)))
    t["x_darbogaz_dagilim"] = NL.join(out)
    out = ["| Kol | " + " | ".join(["S3", "S4", "S5", "S6"]) + " |", "|---|---|---|---|---|"]
    for arm in ("R", "E"):
        row = []
        for sc in ["S3", "S4", "S5", "S6"]:
            r = T.load("main", arm, sc)
            row.append(T.pct(statistics.median([m["detail"]["pm_bosta"] / (T.NPM[sc] * m["wkwin"]) for m in r.values()]), 0))
        out.append("| %s | %s |" % (T.LAB[arm], " | ".join(row)))
    t["x_pm_bos"] = NL.join(out)
    out = ["| Kol | Medyan en düşük moral (60 hf) | En az | En çok | Teslim |", "|---|---|---|---|---|"]
    for arm in ("R", "E"):
        r = T.load("main", arm, "S3_PM_testkutulu")
        v = [min(m["morale"][0]) for m in r.values()]
        out.append("| %s | %d | %d | %d | %s |" % (T.LAB[arm], statistics.median(v), min(v), max(v), T.f1(statistics.median([m["deliv"] for m in r.values()]))))
    t["x_moral"] = NL.join(out)
    out = ["| Ölçek | Kol | Geliştirmede ≤2★ payı | 2,5-3,5★ | ≥4★ | Testte ≤2★ | 2,5-3,5★ | ≥4★ |", "|---|---|---|---|---|---|---|---|"]
    for sc in ["S3", "S4", "S5", "S6"]:
        for arm in ("R", "E"):
            r = T.load("kal", arm, sc)
            cells = []
            for kind in ("dev", "test"):
                agg = {}
                for m in r.values():
                    for k, v in m["wbs"][kind].items():
                        agg[k] = agg.get(k, 0.0) + v
                tot = sum(agg.values())
                cells += [T.pct(sum(v for k, v in agg.items() if lo <= k < hi) / tot, 0) for lo, hi in ((0, 2.01), (2.01, 3.99), (3.99, 99))]
            out.append("| %s | %s | %s |" % (sc, arm, " | ".join(cells)))
    t["x_isyildiz"] = NL.join(out)
    return t


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    for k, v in tables().items():
        print("\n### " + k + "\n")
        print(v)
