# A8 belge uretici: a8_metin.md sablonundaki belirtecleri koşu sonuclariyla doldurur ve ATAMA/A8_PROAKTIF_PLAN.md yazar.
#   {{m:KOL:SENARYO:OLCU}}       ortalama            {{ms:KOL:SENARYO:OLCU}}   ortalama ± standart hata
#   {{d:A:B:SENARYO:OLCU}}       eslik fark (a - b) ortalama ± standart hata (negatif tohum / n)    {{dm:A:B:SENARYO:OLCU}}  yalniz fark ortalamasi
#   {{tab:AD}}                   tablo blogu        {{dosya:YOL}}  metin dosyasi (atama/ klasorune gore)
# SENARYO'da "|" yerine "_" yazilir (PR_S3 = PR|S3). OLCU: a8tab.METRICS anahtarlari.
import os, sys, re
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.stdout.reconfigure(encoding="utf-8")
import a8tab as T

OUT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "ATAMA", "A8_PROAKTIF_PLAN.md"))
NL = chr(10)


def scen(s):
    return s.replace("_", "|") if s.startswith("PR_") else s


def tables():
    t = {}
    t["tek"] = T.single_table()
    t["tek_tplan"] = T.single_table(("P", "T_plan", "R"))
    sc12 = T.SC + T.PRS
    for m in ("mvp", "acik", "soz", "bosta", "bosta_pm", "teslim", "dogan", "kacan"):
        sl = T.PRS if m == "soz" else sc12
        t["fark_%s" % m] = T.diff_table([("P", "R"), ("P", "T"), ("P", "T_plan")], m, sl)
        t["lv_%s" % m] = T.metric_table(["P", "R", "T", "T_plan"], m, sl)
    t["plan"] = T.plan_time_table()
    small = ["S2", "S3", "S4", "PR|S2", "PR|S3", "PR|S4"]
    arms = ["R", "T_plan", "T_plan_np", "P", "P_sabit", "P_core5", "P_ns", "P_np"]
    for m in ("mvp", "acik", "teslim", "dogan", "kacan"):
        t["abl_%s" % m] = T.metric_table(arms, m, small)
    t["abl_soz"] = T.metric_table(arms, "soz", ["PR|S2", "PR|S3", "PR|S4"])
    pairs = [("P", "P_sabit"), ("P", "P_core5"), ("P_sabit", "P_ns"), ("P", "P_np"), ("T_plan", "T_plan_np")]
    for m in ("mvp", "acik", "teslim", "dogan"):
        t["abl_fark_%s" % m] = T.diff_table(pairs, m, small)
    t["abl_fark_soz"] = T.diff_table(pairs, "soz", ["PR|S2", "PR|S3", "PR|S4"])
    rho = ["P", "P_r5", "P_r1"]
    for m in ("mvp", "acik", "teslim", "dogan"):
        t["rho_%s" % m] = T.metric_table(rho, m, small)
    t["rho_soz"] = T.metric_table(rho, "soz", ["PR|S2", "PR|S3", "PR|S4"])
    big = T.SC + T.PRS
    for m in ("mvp", "acik", "teslim", "dogan", "kacan"):
        t["sabit_%s" % m] = T.metric_table(["R", "P", "P_sabit"], m, big)
        t["sabit_fark_%s" % m] = T.diff_table([("P", "P_sabit")], m, big)
    t["sabit_soz"] = T.metric_table(["R", "P", "P_sabit"], "soz", T.PRS)
    t["sabit_fark_soz"] = T.diff_table([("P", "P_sabit")], "soz", T.PRS)
    t["ns_big"] = T.diff_table([("P_sabit", "P_ns")], "dogan", ["S5", "S6", "PR|S5", "PR|S6"])
    t["ns_big_k"] = T.diff_table([("P_sabit", "P_ns")], "kacan", ["S5", "S6", "PR|S5", "PR|S6"])
    g_arms = ["R", "T_plan", "P", "P_gyok", "P_kapi_k9", "P_pmZ_k9", "P_pmR_k9"]
    g_sc = ["S4", "S5", "PR|S4", "PR|S5"]
    t["gyok"] = T.metric_table(g_arms, "teslim", g_sc)
    t["gyok_dogan"] = T.metric_table(g_arms, "dogan", g_sc)
    t["gyok_fark"] = T.diff_table([("P_gyok", "R"), ("P_kapi_k9", "R"), ("P", "P_kapi_k9"), ("P", "R"), ("P_pmZ_k9", "R"), ("P_pmZ_k9", "P"), ("P_pmR_k9", "R")], "teslim", g_sc)
    t["gyok_fark_dogan"] = T.diff_table([("P_gyok", "R"), ("P_kapi_k9", "R"), ("P", "P_kapi_k9"), ("P_pmZ_k9", "P")], "dogan", g_sc)
    t["gyok_fark_bosta"] = T.diff_table([("P_kapi_k9", "R"), ("P", "P_kapi_k9")], "bosta", ["S4", "S5", "PR|S4"])
    rp_sc = ["S2", "S3", "S4", "S5", "S6", "PR|S2", "PR|S3", "PR|S4"]
    LABM = {"mvp": "MVP haftası", "acik": "açık hata", "teslim": "teslim (puan/hf)", "dogan": "doğan hata", "kacan": "kaçan hata"}
    out = ["| Ölçü | " + " | ".join(T.label(x) for x in rp_sc) + " |", "|---|" + "---|" * len(rp_sc)]
    for m in ("mvp", "acik", "teslim", "dogan", "kacan"):
        out.append("| %s | %s |" % (LABM[m], " | ".join(T.dcell("P", "P_rp", x, m) for x in rp_sc)))
    t["rp_fark"] = NL.join(out)
    return t


def render(tpl):
    tabs = tables()

    def sub(mo):
        tok = mo.group(1)
        p = tok.split(":")
        k = p[0]
        if k == "m":
            return T.cell(p[1], scen(p[2]), p[3]).replace(".", ",")
        if k == "ms":
            return T.cell(p[1], scen(p[2]), p[3], se=True).replace(".", ",")
        if k == "d":
            return T.dcell(p[1], p[2], scen(p[3]), p[4]).replace(".", ",")
        if k == "dm":
            m, se, neg, n = T.paired(p[1], p[2], scen(p[3]), p[4])
            f = T.DIFFFMT.get(p[4], lambda x: "%+.1f" % x)
            return (f(m) if m is not None else "-").replace(".", ",")
        if k == "dp":
            m, se, neg, n = T.paired(p[1], p[2], scen(p[3]), p[4])
            base = T.mean(p[2], scen(p[3]), p[4])
            return ("%+.1f%%" % (100.0 * m / base) if m is not None and base else "-").replace(".", ",")
        if k == "pl":
            r = T.load("P", scen(p[1]))
            n = sum(m["p8"]["rollouts"] for m in r.values())
            ns = sum(m["p8"]["nsprints"] for m in r.values())
            sec = sum(m["p8"]["secs"] for m in r.values())
            return {"n": "%.1f" % (n / ns), "s": "%.2f" % (sec / ns), "ms": "%.0f" % (1000.0 * sec / n)}[p[2]].replace(".", ",")
        if k == "tab":
            return tabs[p[1]]
        if k == "dosya":
            return render(open(os.path.join(HERE, p[1]), encoding="utf-8").read().rstrip(NL))
        raise KeyError(tok)
    return re.sub(r"\{\{([^}]*)\}\}", sub, tpl)


if __name__ == "__main__":
    tpl = open(os.path.join(HERE, "a8_metin.md"), encoding="utf-8").read()
    out = render(tpl)
    open(OUT, "w", encoding="utf-8", newline="\n").write(out)
    print("yazildi", OUT, len(out))
