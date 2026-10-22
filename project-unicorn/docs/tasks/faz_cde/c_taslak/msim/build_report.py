"""Raporu template.md'den ve out/ tablolarindan kurar. python -I. Cikti: docs/tasks/faz_cde/MEMNUNIYET_SIM.md"""
import sys, os, re, json, pickle
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
try:
    sys.stdout.reconfigure(encoding="utf-8")
except Exception:
    pass
import k5, bot, econ

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "out")
DEST = "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/MEMNUNIYET_SIM.md"
LABEL = {"none": "hiç düzeltmeyen (none)", "worst": "en kötüsünü düzelten (worst)", "due": "vadesi gelen düzelten (due)", "off": "hata bedeli kapalı (off)"}


def rd(name):
    return open(os.path.join(OUT, name), encoding="utf-8").read()


def dec(t):
    """tablolardaki ondalik noktayi virgule cevirir (rakam.rakam)."""
    return re.sub(r"(?<=\d)\.(?=\d)", ",", t)


def sec(text, head, level="### "):
    """'### <head>...' basligindan sonraki metni, sonraki ###/#### basligina kadar alir (basliksiz)."""
    lines = text.split("\n")
    out = []
    on = False
    for ln in lines:
        if ln.startswith("#"):
            if on:
                break
            if ln.lstrip("#").strip().startswith(head):
                on = True
                continue
        elif on:
            out.append(ln)
    if not on:
        raise KeyError(head)
    return "\n".join(out).strip()


def md(rows, head):
    s = "| " + " | ".join(head) + " |\n|" + "---|" * len(head) + "\n"
    for r in rows:
        s += "| " + " | ".join(str(c) for c in r) + " |\n"
    return s.strip()


def k(x):
    return "%+.0fK" % (x / 1000.0)


P = pickle.load(open(os.path.join(OUT, "p1.pkl"), "rb"))
G = json.load(open(os.path.join(OUT, "g.json"), encoding="utf-8"))
t1 = rd("p1_tables.md"); t2 = rd("p2_tables.md"); t3 = rd("p3_tables.md"); t4 = rd("p4_tables.md")
fw = G["first_week"]

fw_tab = md([[LABEL[a], fw[a]["n"], "%+.1f" % fw[a]["d1_mean"], "%d%%" % round(100 * fw[a]["d1_le5"]), "%d%%" % round(100 * fw[a]["d1_le15"]),
              "%d%%" % round(100 * fw[a]["d1_up"]), "%+.1f" % fw[a]["d4_mean"], "%d%%" % round(100 * fw[a]["d4_le15"])] for a in bot.ARMS],
            ["Kol", "hesap", "imza → 1. hafta ortalama değişim", "1. haftada ≥5 düşen", "1. haftada ≥15 düşen", "1. haftada ≥5 yükselen",
             "imza → 4. hafta ortalama değişim", "4. haftada ≥15 düşen"])
val_tab = md([[LABEL[a], "%d / %d" % tuple(G["validate"][a]), "%.1f%%" % (100 * G["validate"][a][0] / G["validate"][a][1])] for a in bot.ARMS],
             ["Kol", "tutan geçiş / toplam", "oran"])
m10_tab = md([[LABEL[a], G["M10"][a][0], G["M10"][a][1], "%.1f%%" % (100 * (G["M10"][a][0] - G["M10"][a][1]) / G["M10"][a][0])] for a in bot.ARMS],
             ["Kol", "MVP sonrası 26 haftada (hf 7-33) imza", "kapıdan dönen", "geçen pay"])
rd_rows = []
for a in bot.ARMS:
    d = G["renew_diff"][a]
    rs = bot.renew_stats(P[a]["new"]["res"])
    rd_rows.append([LABEL[a], d["n"], "%d / %d / %d" % (d["p10"], d["p50"], d["p90"]), "%d - %d" % (d["min"], d["max"]),
                    " / ".join("%d%%" % round(100 * x / max(1, rs["decisions"])) for x in rs["stances"])])
rd_tab = md(rd_rows, ["Kol", "yenileme kararı", "fark (memnuniyet - eşik + ikna) p10 / ortanca / p90", "en küçük - en büyük",
                      "tutum: Zamma açık / Aynı / İndirim ister / Ayrılmayı düşünüyor / Yenilemeyecek"])
m13_rows = []
for a in bot.ARMS:
    ps = G["per_seed"][a]
    lost = lambda m: sum(ps[s][m]["total"] for s in ("7", "11"))
    real_mean = sum(x for r in P[a]["real"]["res"].values() for x in r["sat"].values()) / sum(len(r["sat"]) for r in P[a]["real"]["res"].values())
    ned_old = bot.nedensiz_total(P[a]["old"]["res"])[0]
    ned_new = bot.nedensiz_total(P[a]["new"]["res"])[0] + bot.nedensiz_total(P[a]["new_ng"]["res"])[0]
    m13_rows.append([LABEL[a], lost("real"), lost("old"), lost("new"), lost("new_ng"), "%.1f" % real_mean, "%.1f" % bot.mean_sat(P[a]["old"]["res"]),
                     "%.1f" % bot.mean_sat(P[a]["new"]["res"]), "%d / %d" % (ned_old, ned_new)])
m13_tab = md(m13_rows, ["Kol", "kayıp: K5 gerçek", "eski, aynı U", "yeni (kapılı)", "yeni (kapısız)", "ort. memnuniyet: K5 gerçek", "eski, aynı U", "yeni (kapılı)",
                        "nedensiz düşüş: eski kopya / yeni"])

# ---- M11 tarama
scan_rows = []
for seed in (7, 11):
    run = k5.load(bot.run_name("worst", seed))
    old = econ.summarize(econ.monthly(run, "b2b", None))
    lim = 2 * old[3]["net"]
    for lab, m in (("A (maaş x1,0)", 1.0), ("C (x1,5)", 1.5), ("D (x2,0)", 2.0), ("E (x2,2)", 2.2)):
        s = econ.summarize(econ.monthly(run, "b2b", {"sal_mult": m}))
        ok_dip = (-s["dip"][0] >= 25000) and s["dip"][1] > 30
        ok_52 = s["c52"] <= 80000
        ok_3 = s[3]["net"] <= lim
        scan_rows.append([seed, lab, "%s (hf %d)" % (k(s["dip"][0]), s["dip"][1]), k(s["c52"]), "%s / sınır %s" % (k(s[3]["net"]), k(lim)),
                          "evet" if ok_dip else "hayır", "evet" if ok_52 else "hayır", "evet" if ok_3 else "hayır", k(s["mincash"][0])])
scan_tab = md(scan_rows, ["tohum", "Varyant", "en derin kümülatif açık", "52. hf kümülatif net", "evre 3 aylık net / sınır (2 x eski)",
                          "açık >= 25K ve hf > 30", "52. hf <= 80K", "evre 3 <= 2 x eski", "en düşük nakit"])
cs_rows = []
for seed in (7, 11):
    run = k5.load(bot.run_name("worst", seed))
    for d in (72, 96, 103):
        st = run["state"][d]
        cust = int(st["cust"]); reps = -(-cust // 8)
        cs_rows.append([seed, d, cust, reps, "$%s" % format(int(reps * 1875), ",").replace(",", ".")])
cs_tab = md(cs_rows, ["tohum", "hafta", "hesap", "gereken temsilci (2★: hesap kapasitesi 8)", "aylık maaş (junior bandın ortası $1.875)"])

# ---- p3 bolumleri
S4 = sec(t2, "S4")
s4a, s4b = S4.split("\n\n", 1)

PH = {
    "FW_TAB": fw_tab, "VAL_TAB": val_tab, "S1": sec(t1, "S1"), "S2": sec(t1, "S2"), "S3": sec(t1, "S3"),
    "S4A": s4a.strip(), "S4B": s4b.strip(), "M2": sec(t2, "M2"), "M6": sec(t2, "M6"), "M8": sec(t2, "M8"), "M7": sec(t2, "M7"), "M9": sec(t2, "M9"),
    "M13B": sec(t2, "M13"), "M10": m10_tab, "RENEW_TAB": rd_tab, "M13A": m13_tab,
    "E1": sec(t3, "E1"), "E2_B2B7": sec(t3, "E2 Evre başına aylık burn / gelir / net: B2B tohum 7"), "E2_B2B11": sec(t3, "E2 Evre başına aylık burn / gelir / net: B2B tohum 11"),
    "E2_B2C7": sec(t3, "E2 Evre başına aylık burn / gelir / net: B2C tohum 7"), "E2_B2C11": sec(t3, "E2 Evre başına aylık burn / gelir / net: B2C tohum 11"),
    "E3": sec(t3, "E3"), "E4": sec(t3, "E4"), "E5": sec(t3, "E5"),
    "SCAN": scan_tab, "CS": cs_tab, "O1": sec(t4, "O1"), "O2": sec(t4, "O2"), "O3": sec(t4, "O3"),
}
tpl = open(os.path.join(HERE, "template.md"), encoding="utf-8").read()
for key, val in PH.items():
    tag = "@@%s@@" % key
    if tag not in tpl:
        print("UYARI: yer tutucu yok:", key)
    tpl = tpl.replace(tag, val if key == "CS" else dec(val))
left = re.findall(r"@@[A-Z0-9_]+@@", tpl)
assert not left, left
open(DEST, "w", encoding="utf-8").write(tpl)
print("yazildi", DEST, len(tpl))
