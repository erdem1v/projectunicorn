# Rapor tablolari 1: olcek, testci, uc durumlar. python -I dsim3.py exec tb1.py
exec(open("an_common.py", encoding="utf-8").read())
A, B, C, D, E, F = (L(x) for x in ("A", "B", "C", "D", "E", "F"))


def n1(x, d=1):
    return ("%." + str(d) + "f") % x if x is not None else "-"


def tr(x, d=1):
    return n1(x, d).replace(".", ",")


def pc(x, d=0):
    return "%" + tr(100 * x, d)


def sp(x, d=0):
    v = 100 * x
    return ("+%" if v >= 0 else "−%") + tr(abs(v), d)


OUT = {}

# ---- olcek tablosu
rows = ["| Ekip | Haftalık iş (puan) | Kişi başı | Kart / sprint | Kaçan / kart | Açık hata (medyan) | Düzeltme payı (geç) | Hata sprinti | MVP (hf) |", "|---|---|---|---|---|---|---|---|---|"]
rows2 = ["| Ekip | Bulunan / sprint | Bilinen / sprint | Bilinen hata sorusu (sprintlerin payı) | Sprint içi düzeltme | Toplam hata işi | Boşta (kişi-hf / hf) | Boşta payı | Darboğaz |", "|---|---|---|---|---|---|---|---|---|"]
names = [("S1", 1), ("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)]
for n, k in names:
    hsn = tsum(A, n, "bs_late", 0)
    hst = tsum(A, n, "bs_late", 1)
    rows.append("| %s · %d | %s | %s | %s | %s | %s | %s | %d/%d | %d |" % (n, k, tr(md(A, n, "deliv")), tr(md(A, n, "per_person")), tr(md(A, n, "cards_sprint"), 2), tr(md(A, n, "esc_card"), 2),
                                                                   tr(md(A, n, "open_med")), pc(md(A, n, "fix_late"), 1), hsn, hst, md(A, n, "mvp")))
    bott = max(set(m["bott"] for m in A[n].values()), key=lambda b: sum(1 for m in A[n].values() if m["bott"] == b))
    rows2.append("| %s · %d | %s | %s | %s | %s | %s | %s | %s | %s |" % (n, k, tr(md(A, n, "found_sp"), 2), tr(md(A, n, "K_sp"), 2), pc(pooled_asked(A, n), 1), pc(md(A, n, "infix"), 1),
                                                                    pc(md(A, n, "fix_late") + md(A, n, "infix"), 1), tr(md(A, n, "idle_w"), 1), pc(md(A, n, "idle_pct")), BOTT[bott]))
OUT["scale1"] = "\n".join(rows)
OUT["scale2"] = "\n".join(rows2)

# ---- belge ile karsilastirma (D_MODEL_v3 §4.2)
doc = {"S1": (4.5, 0.78, 6.75, 0.29), "S2": (19.6, 1.09, 8, 0.095), "S3": (48, 0.68, 8, 0.066), "S4": (107, 0.58, 9.5, 0.051), "S5": (265.5, 0.44, 12, 0.034), "S6": (539, 0.44, 17, 0.030)}
rows = ["| Ekip | Teslim: belge / bu koşu | Kaçan / kart: belge / bu koşu | Açık hata: belge / bu koşu | Düzeltme payı: belge / bu koşu |", "|---|---|---|---|---|"]
for n, k in names:
    d = doc[n]
    rows.append("| %s · %d | %s / %s (%s) | %s / %s | %s / %s | %s / %s |" % (n, k, tr(d[0]), tr(md(A, n, "deliv")), sp(md(A, n, "deliv") / d[0] - 1, 1), tr(d[1], 2), tr(md(A, n, "esc_card"), 2), tr(d[2]), tr(md(A, n, "open_med")),
                                                                  pc(d[3], 1), pc(md(A, n, "fix_late"), 1)))
OUT["vsdoc"] = "\n".join(rows)

# ---- testcinin etkisi
rows = ["| Ekip | Testçisiz → 3★ testçi (aynı kişi sayısı) | 1★ testçi | 3★ testçi | 5★ testçi | 1★ → 5★: kaçan / 100 puan, bulunan / sprint |", "|---|---|---|---|---|---|"]
# 1 kisi ve 3 kisi: kurucuya / S2'ye testci eklemek
s1 = md(A, "S1", "deliv"), md(A, "S1", "esc100")
g1 = md(E, "G|orta|test-gel-tas|1", "deliv"), md(E, "G|orta|test-gel-tas|1", "esc100")
s2 = md(A, "S2", "deliv"), md(A, "S2", "esc100")
s2t = md(B, "S2 +3* testci", "deliv"), md(B, "S2 +3* testci", "esc100")
rows.append("| 1 kişi (kurucu) | yok (4,5 · 3,89) → +2,5★ testçi (%s · %s) | | | | testçi yıldızı kuruculu ekipte ölçülmedi |" % (tr(g1[0]), tr(g1[1], 2)))
rows.append("| 3 kişi (S2) | yok (%s · %s) → +3★ testçi (%s · %s) | | | | |" % (tr(s2[0]), tr(s2[1], 2), tr(s2t[0]), tr(s2t[1], 2)))
for lab, pre in (("6 kişi (S3)", "T3"), ("12 kişi (2 testçi)", "T4"), ("25 kişi (5 testçi)", "T5")):
    y, t3 = (md(D, pre + "_yok", "deliv"), md(D, pre + "_yok", "esc100")), (md(D, pre + "_3", "deliv"), md(D, pre + "_3", "esc100"))
    cells = []
    for st in (1, 3, 5):
        cells.append("%s · %s" % (tr(md(D, pre + "_%d" % st, "deliv")), tr(md(D, pre + "_%d" % st, "esc100"), 2)))
    e1, e5 = md(D, pre + "_1", "esc100"), md(D, pre + "_5", "esc100")
    f1_, f5_ = md(D, pre + "_1", "found_sp"), md(D, pre + "_5", "found_sp")
    rows.append("| %s | %s · %s → %s · %s (teslim %s, kaçan %s) | %s | %s | %s | −%s; %s → %s (×%s) |" % (lab, tr(y[0]), tr(y[1], 2), tr(t3[0]), tr(t3[1], 2), sp(t3[0] / y[0] - 1),
                                                                                                sp(t3[1] / y[1] - 1), cells[0], cells[1], cells[2], pc(1 - e5 / e1), tr(f1_, 2), tr(f5_, 2), tr(f5_ / f1_)))
OUT["tester"] = "\n".join(rows)

# ---- uc durumlar
ucs = [("S7 · küçük kartlara 5 testçi", "S7", "S7_1test"), ("S8 · 10 geliştirici, Test kutusu yok", "S8", None), ("S8 + 1 Test kutulu geliştirici", "S8_ek_testkutulu_gel", None),
       ("S8 · 10 geliştiricinin hepsinde Test kutusu", "S8_hepsi_testkutulu", None), ("S9a · 8 testçi, yalnız Test", "S9a", None), ("S9a + 1 geliştirici", "S9a_ek_gel", None),
       ("S9b · 8 testçi, Yapım ve Test", "S9b", None), ("S10 · PM'siz 30 kişi", "S10", None), ("S11 · testçisiz 25 kişi, kutu yok", "S11", None), ("S11 + 1 testçi", "S11_ek_testci", None),
       ("S11b · aynı, geliştiricilerde Test kutusu", "S11b", None), ("S12 · tek karta 12 kişi", "S12", None),
       ("S3 PM'siz (5 kişi)", "S3_PMsiz", None), ("S3 + PM'e Test kutusu", "S3_PM_testkutulu", None), ("S4 PM'siz (10 kişi)", "S4_PMsiz", None), ("S5 tek PM (23 kişi)", "S5_1PM", None)]
doc3 = {"S7": 22.1, "S8": 17.0, "S8_hepsi_testkutulu": 31.0, "S9a": 7.9, "S9b": 19.6, "S10": 283, "S11": 36, "S11b": 162, "S12": 11.5}
rows = ["| Senaryo | Kişi | Teslim (belge) | Boşta (kişi-hf / hf) | Kaçan / kart | Açık hata | Darboğaz | Okunuş |", "|---|---|---|---|---|---|---|---|"]
read = {"S7": "Tek testçiyle %s; dört testçi az teslim, belirgin kalite getirir" % tr(md(A, "S7_1test", "deliv")),
        "S8": "Tasarımı ve testi yalnız kurucu yapıyor", "S8_ek_testkutulu_gel": "Test açılınca teslim artar", "S8_hepsi_testkutulu": "Kendi kartını test edenler az yakalar",
        "S9a": "Yapımı yalnız kurucu yapıyor", "S9a_ek_gel": "Yapım rolü eklenince teslim iki katı", "S9b": "Testçi ikincil hızla geliştirir",
        "S10": "Çökmez; bedeli hatada ve hızda", "S11": "Darboğaz Test; testi yetişmez", "S11_ek_testci": "Bir testçi teslimi iki buçuk kat yapar", "S11b": "Test açılır",
        "S12": "Kadro dolu, öbürleri boşta", "S3_PMsiz": "PM'siz ceza yok ama hazır kart yok", "S3_PM_testkutulu": "PM uymayan işte moral kaybeder (kapı 23)", "S4_PMsiz": "PM'siz: kaçan hata artar", "S5_1PM": "Tek PM ekibin yarısını hazırlar (hazır kart %" + str(int(100 * md(A, "S5_1PM", "ready"))) + ")"}
for lab, n, _ in ucs:
    bott = max(set(m["bott"] for m in A[n].values()), key=lambda b: sum(1 for m in A[n].values() if m["bott"] == b))
    dd = (" (%s)" % tr(doc3[n])) if n in doc3 else ""
    rows.append("| %s | %d | %s%s | %s | %s | %s | %s | %s |" % (lab, md(A, n, "n"), tr(md(A, n, "deliv")), dd, tr(md(A, n, "idle_w")), tr(md(A, n, "esc_card"), 2), tr(md(A, n, "open_med")), BOTT[bott], read.get(n, "")))
OUT["uc"] = "\n".join(rows)

# ---- marjinal
rows = ["| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |", "|---|---|---|---|---|---|"]
for base, k in (("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)):
    bd = md(A, base, "deliv")
    cells = []
    for add in ADD:
        n = "%s %s" % (base, add)
        cells.append(("%+.1f" % (md(B, n, "deliv") - bd)).replace(".", ",") + " (%s)" % tr(md(B, n, "esc_card"), 2))
    rows.append("| %s · %d (%s) | %s |" % (base, k, tr(bd), " | ".join(cells)))
OUT["marj"] = "\n".join(rows)

# ---- kisi ekleme egrisi (secili satirlar)
rows = ["| Kişi | Eklenen | Teslim | Marjinal | Kişi başı | Kaçan / kart | Açık hata | Boşta payı |", "|---|---|---|---|---|---|---|---|"]
roles = curve_roles(50)
lab = {"dev": "geliştirici", "test": "testçi", "des": "tasarımcı", "pm": "PM"}
prev = None
cs = []
for n in range(1, 51):
    d = md(C, "C%d" % n, "deliv")
    cs.append((n, d, None if prev is None else d - prev))
    prev = d
for n, d, mg in cs:
    if n in (1, 2, 3, 4, 5, 6, 7, 12, 13, 25, 31, 37, 38, 47, 48, 49, 50) or (mg is not None and mg < 0):
        rows.append("| %d | %s | %s | %s | %s | %s | %s | %s |" % (n, "kurucu" if n == 1 else lab[roles[n - 2]], tr(d), "-" if mg is None else ("%+.1f" % mg).replace(".", ","), tr(md(C, "C%d" % n, "per_person"), 2),
                                                                  tr(md(C, "C%d" % n, "esc_card"), 2), tr(md(C, "C%d" % n, "open_med")), pc(md(C, "C%d" % n, "idle_pct"))))
OUT["curve"] = "\n".join(rows)
by = {}
for n, d, mg in cs:
    if mg is not None:
        by.setdefault(lab[roles[n - 2]], []).append(mg)
rows = ["| Eklenen rol | Adım | Ortalama | En küçük | En büyük |", "|---|---|---|---|---|"]
for r_, v in by.items():
    rows.append("| %s | %d | %s | %s | %s |" % (r_, len(v), ("%+.1f" % statistics.mean(v)).replace(".", ","), ("%+.1f" % min(v)).replace(".", ","), ("%+.1f" % max(v)).replace(".", ",")))
OUT["curve_role"] = "\n".join(rows)
OUT["curve_neg"] = "Negatif adım: %d; sıfır adım: %d; en kötü %s" % (sum(1 for _, _, m in cs if m is not None and m < 0), sum(1 for _, _, m in cs if m is not None and abs(m) < 1e-9), ("%+.1f" % min(m for _, _, m in cs if m is not None)).replace(".", ","))

# ---- politika
rows = ["| Ekip | Politika | Teslim | Kaçan / 100 puan | Açık hata (medyan) | Kartın bekleme süresi (hf) | Düzeltme payı (geç) | Soru gelen sprint | Gönderilen bilinen hata / sprint |", "|---|---|---|---|---|---|---|---|---|"]
pn = {"birak": "bırak", "gonder": "gönder", "esikli": "eşikli", "hep_gonder": "hep gönder"}
for n in ("S1", "S3", "S4", "S5", "S6", "S10"):
    for p in F:
        R_ = F[p]
        rows.append("| %s | %s | %s | %s | %s | %s | %s | %s | %s |" % (n, pn[p], tr(md(R_, n, "deliv")), tr(md(R_, n, "esc100"), 2), tr(md(R_, n, "open_med")), tr(md(R_, n, "lead"), 2), pc(md(R_, n, "fix_late"), 1), pc(pooled_asked(R_, n), 1), tr(md(R_, n, "shipped_k"), 2)))
OUT["pol"] = "\n".join(rows)

import json
json.dump(OUT, open("out/tb1.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for k, v in OUT.items():
    print("##", k)
    print(v)
