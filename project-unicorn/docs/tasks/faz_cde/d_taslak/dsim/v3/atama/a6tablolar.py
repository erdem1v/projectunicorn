# A6 rapor tablolari (hepsi out6/'dan). tables() -> {anahtar: markdown}, values() -> {ad: sayi}. python -I a6tablolar.py: hepsini basar.
import sys, os, pickle, statistics
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import a6tab as T

SC, PRS = T.SC, T.PRS
ALL = SC + PRS
PMSC = ["S3", "S4", "S5", "S6"]
PMALL = PMSC + ["PR|" + s for s in PMSC]
NL = chr(10)


def kalib():
    base = pickle.load(open(os.path.join(HERE, "out6", "kal", "0", "R__S3.pkl"), "rb"))
    out = ["| Kalibrasyon | c | p | Beklenen doğan hata (ortalama) | Gerçekleşen doğan hata (ortalama) | Bugüne göre (beklenen / gerçekleşen) |", "|---|---|---|---|---|---|"]
    mb = statistics.mean(m["born"] for m in base.values())
    mh = statistics.mean(m["H"] for m in base.values())
    out.append("| bugünkü model | - | - | %.1f | %.1f | referans |" % (mh, mb))
    for cal, lab, p in (("0.205", "deneme", 1), ("0.21", "deneme", 1), ("0.212", "**K-H (seçilen)**", 1), ("0.213", "deneme", 1), ("0.215", "deneme", 1), ("0.25", "deneme", 1), ("0.35", "deneme", 1),
                        ("0.297@0", "duyarlılık p = 0", 0), ("0.137@2", "duyarlılık p = 2", 2)):
        f = os.path.join(HERE, "out6", "kal", cal, "R__S3.pkl")
        if not os.path.exists(f):
            continue
        d = pickle.load(open(f, "rb"))
        b = statistics.mean(m["born"] for m in d.values())
        h = statistics.mean(m["H"] for m in d.values())
        out.append("| %s | %s | %d | %.1f | %.1f | %+.1f%% / %+.1f%% |" % (lab, cal.split("@")[0], p, h, b, 100 * (h / mh - 1), 100 * (b / mb - 1)))
    return NL.join(out)


def tables():
    t = {}
    t["kalib"] = kalib()
    t["sabitler"] = open(os.path.join(HERE, "a6_sabitler_onceki.md"), encoding="utf-8").read().rstrip(NL)
    t["ana_H"] = T.main_table("ana", "H")
    t["ana_E"] = T.main_table("ana", "E")
    t["ana_0"] = T.main_table("ana", "0", arms=("T", "R"))
    for cal in ("H", "E", "0"):
        arms3 = ["T", "R"] if cal == "0" else ["T", "R", "BK"]
        for m in ("teslim", "acik", "dogan", "kacan", "mvp", "bosta", "altinda"):
            t["lv_%s_%s" % (cal, m)] = T.metric_table("ana", cal, arms3, m, scens=ALL)
        t["lv_%s_soz" % cal] = T.metric_table("ana", cal, arms3, "soz", scens=PRS)
        pairs = [("T", "R")] if cal == "0" else [("T", "R"), ("BK", "R"), ("BK", "T")]
        for m in ("teslim", "acik", "dogan", "kacan", "mvp", "bosta"):
            t["df_%s_%s" % (cal, m)] = T.diff_table("ana", cal, pairs, m, scens=ALL)
        t["df_%s_soz" % cal] = T.diff_table("ana", cal, pairs, "soz", scens=PRS)
    t["oran"] = T.ratio_table("ana")
    arms = ["R", "T", "T_zor", "T_d", "T_zord", "E"]
    for m in ("teslim", "acik", "dogan", "kacan", "mvp", "bosta"):
        t["pm_%s" % m] = T.metric_table("ana", "H", arms, m, scens=PMALL)
    t["pm_soz"] = T.metric_table("ana", "H", arms, "soz", scens=["PR|" + s for s in PMSC])
    pp = [("T_zor", "T"), ("T_d", "T"), ("T_zord", "T_zor"), ("T", "E"), ("T", "R")]
    for m in ("teslim", "acik", "dogan", "kacan"):
        t["pmdf_%s" % m] = T.diff_table("ana", "H", pp, m, scens=PMALL)
    t["pmdf_soz"] = T.diff_table("ana", "H", pp, "soz", scens=["PR|" + s for s in PMSC])
    # tani kolu
    arms2 = ["R", "T", "T_plan"]
    for m in ("teslim", "acik", "dogan", "kacan", "mvp"):
        t["tani_%s" % m] = T.metric_table("ana", "H", arms2, m, scens=ALL)
    t["tani_soz"] = T.metric_table("ana", "H", arms2, "soz", scens=PRS)
    for m in ("teslim", "acik", "dogan", "mvp"):
        t["tanidf_%s" % m] = T.diff_table("ana", "H", [("T_plan", "R"), ("T_plan", "T")], m, scens=ALL)
    t["tanidf_soz"] = T.diff_table("ana", "H", [("T_plan", "R"), ("T_plan", "T")], "soz", scens=PRS)
    # duyarlilik
    for cal, lab in (("0.297@0", "p = 0"), ("0.137@2", "p = 2")):
        sc = ["S2", "S3", "S4", "S6", "PR|S2", "PR|S3"]
        for m in ("teslim", "acik", "dogan", "mvp"):
            t["duy_%s_%s" % (cal.split("@")[1], m)] = T.metric_table("duy", cal, ["R", "T", "BK", "T_plan"], m, scens=sc)
        t["duy_%s_soz" % cal.split("@")[1]] = T.metric_table("duy", cal, ["R", "T", "BK", "T_plan"], "soz", scens=["PR|S3"])
    return t


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    for k, v in tables().items():
        print(NL + "### " + k + NL)
        print(v)
