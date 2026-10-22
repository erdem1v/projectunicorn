exec(open("analyze.py", encoding="utf-8").read())
import json, datetime

L = []
def w(s=""):
    L.append(s)

def table(head, rows):
    w("| " + " | ".join(head) + " |")
    w("|" + "|".join("---" for _ in head) + "|")
    for r in rows:
        w("| " + " | ".join(str(x) for x in r) + " |")
    w()

def rng(a):
    return "%s-%s" % (f(a["deliv_min"]), f(a["deliv_max"]))

DOC42 = {"S1": (6.1, 0.49, 6.5), "S2": (21.9, 0.78, 8), "S3": (55, 0.57, 8), "S4": (116, 0.57, 8.5), "S5": (257, 0.57, 13.5), "S6": (498, 0.57, 19)}
DOC43 = {"S7": (25.9, 5.4), "S8": (19.4, 9.1), "S9a": (10.4, 7.8), "S9b": (22.6, 6.4), "S10": (307, 0.3), "S11": (41, 17.2),
         "S11b": (160, 7.9), "S12": (11.8, 10.7), "S3_PM_testkutulu": (50, 0.5)}
LBL = {"S1": "S1 · kurucu", "S2": "S2 · 3 kişi", "S3": "S3 · 6 kişi", "S4": "S4 · 12 kişi", "S5": "S5 · 25 kişi", "S6": "S6 · 50 kişi",
       "S7": "S7 · küçük kartlara 5 testçi (8)", "S7_1test": "S7 karşılaştırma · tek testçi (4)", "S8": "S8 · 10 geliştirici (11)",
       "S8_ek_testkutulu_gel": "S8 + 1 geliştirici (Yapım+Test)", "S8_hepsi_testkutulu": "S8 · 10 geliştiricinin hepsinde Test kutusu",
       "S9a": "S9a · 8 testçi, yalnız Test (9)", "S9a_ek_gel": "S9a + 1 geliştirici", "S9b": "S9b · 8 testçi, Yapım+Test (9)",
       "S10": "S10 · PM'siz 30 kişi", "S11": "S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi (25)", "S11_ek_testci": "S11 + 1 testçi",
       "S11b": "S11b · S11, geliştiricilerde Test kutusu", "S12": "S12 · tek karta 12 kişi", "S3_PMsiz": "S3 PM'siz (5)",
       "S3_PM_testkutulu": "S3 + PM'e Test kutusu (6)", "S4_PMsiz": "S4 PM'siz (10)", "S4_1PM": "S4 tek PM (11)", "S5_1PM": "S5 tek PM (23)"}
MAIN = ["S1", "S2", "S3", "S4", "S5", "S6", "S7", "S7_1test", "S8", "S8_ek_testkutulu_gel", "S8_hepsi_testkutulu", "S9a", "S9a_ek_gel", "S9b",
        "S10", "S11", "S11_ek_testci", "S11b", "S12", "S3_PMsiz", "S3_PM_testkutulu", "S4_PMsiz", "S4_1PM", "S5_1PM"]

def hs(a, which):
    t = a["bs_" + which]
    return ratio(t)

# ----------------------------------------------------------------------------------- kirilma hesaplari
V = []   # (no, ad, durum, kanit)
KIR = []  # kirilma listesi (metin)
OBS = []  # olcut disi gozlemler

# K1 marjinal
adds = ["+3* gelistirici", "+3* testci", "+3* tasarimci", "+3* PM", "+1* gelistirici"]
marg = {}
for b in ("S2", "S3", "S4", "S5", "S6"):
    for ad in adds:
        marg[(b, ad)] = A["%s %s" % (b, ad)]["deliv"] - A[b]["deliv"]
curve_m = {}
for n in range(2, 51):
    curve_m[n] = A["C%d" % n]["deliv"] - A["C%d" % (n - 1)]["deliv"]
neg_t = [(k, v) for k, v in marg.items() if v < -1 - 1e-9]
neg_c = [(k, v) for k, v in curve_m.items() if v < -1 - 1e-9]
edge_t = [(k, v) for k, v in marg.items() if -1 - 1e-9 <= v < 0]
edge_c = [(k, v) for k, v in curve_m.items() if -1 - 1e-9 <= v < 0]
k1_ok = not neg_t and not neg_c
ev = "Marjinal tablo (25 hücre) en düşük %+.1f; eğri (49 adım) en düşük %+.1f (n=%d)." % (
    min(marg.values()), min(curve_m.values()), min(curve_m, key=curve_m.get))
V.append((1, "Bir rol eklemek teslimi düşürür (tolerans -1 puan/hafta)", "GEÇTİ" if k1_ok else "KIRIK", ev))
if not k1_ok:
    for k, v in neg_c:
        KIR.append("K1 (belge ölçütü 1): kişi ekleme eğrisinde %d. kişi (geliştirici) teslimi %+.1f puan/hafta değiştiriyor "
                   "(%.1f → %.1f, 20 tohumun %d'sinde 48. kişi aynı tohumdaki 47. kişinin altında); tolerans -1. Sebep atamada değil sprint alımında: kapasite tavanı "
                   "(1,25 × kapasite) yeni kişiyle büyüyor, sprint daha çok kart alıyor ve yarım kalan kart yığını büyüyor." % (
                       k, v, A["C%d" % (k - 1)]["deliv"], A["C%d" % k]["deliv"], sum(1 for s in SEEDS if R["C%d" % k][s]["deliv"] < R["C%d" % (k - 1)][s]["deliv"])))
    for k, v in neg_t:
        KIR.append("K1: marjinal tabloda %s %s: %+.1f." % (k[0], k[1], v))

# K2
mv = A["S1"]
k2_ok = all(6 <= m <= 7 for m in vals("S1", "mvp"))
V.append((2, "Tek kurucunun MVP haftası 6-7", "GEÇTİ" if k2_ok else "KIRIK",
          "S1 MVP haftası: medyan %d, 20 tohumun en küçüğü %d, en büyüğü %d." % (mv["mvp"], mv["mvp_min"], mv["mvp_max"])))
if not k2_ok:
    KIR.append("K2: tek kurucunun MVP haftası %s-%s." % (mv["mvp_min"], mv["mvp_max"]))

# K3
r5, r6 = A["S5"]["per_person"] / A["S3"]["per_person"], A["S6"]["per_person"] / A["S3"]["per_person"]
k3_ok = 0.7 <= r5 <= 1.5 and 0.7 <= r6 <= 1.5
V.append((3, "S5 ve S6 kişi başı teslim S3'ün %70-%150'si", "GEÇTİ" if k3_ok else "KIRIK",
          "Kişi başı: S3 %.2f, S5 %.2f (%%%d), S6 %.2f (%%%d)." % (A["S3"]["per_person"], A["S5"]["per_person"], round(r5 * 100), A["S6"]["per_person"], round(r6 * 100))))
if not k3_ok:
    KIR.append("K3: kişi başı teslim S3'e göre S5 %%%d, S6 %%%d." % (round(r5 * 100), round(r6 * 100)))

# K4
c4 = [("S8", "S8_ek_testkutulu_gel", "S8'e Test kutulu geliştirici"), ("S11", "S11_ek_testci", "S11'e testçi"), ("S9a", "S9a_ek_gel", "S9a'ya geliştirici")]
k4_ok = all(A[b]["deliv"] < A[a]["deliv"] for a, b, _ in [(x[0], x[1], x[2]) for x in c4])
k4_ok = all(A[a]["deliv"] < A[b]["deliv"] for a, b, _ in c4)
V.append((4, "Darboğaz rolüne kişi eklemek teslimi artırır", "GEÇTİ" if k4_ok else "KIRIK",
          "; ".join("%s: %.1f → %.1f" % (t, A[a]["deliv"], A[b]["deliv"]) for a, b, t in c4) + "."))
if not k4_ok:
    KIR.append("K4: darboğaz rolüne kişi eklemek teslimi artırmıyor (" + "; ".join(t for a, b, t in c4 if not A[a]["deliv"] < A[b]["deliv"]) + ").")

# K5
multi = {n: a for n, a in A.items() if a["n"] >= 2}
worst_e = max(((a["fix_early"], n) for n, a in multi.items() if a["fix_early"] is not None))
worst_l = max(((a["fix_late"], n) for n, a in multi.items()))
worst_bl = max(((a["bs_late"][0] / a["bs_late"][1], n) for n, a in multi.items() if a["bs_late"][1]))
worst_be = max(((a["bs_early"][0] / a["bs_early"][1], n) for n, a in multi.items() if a["bs_early"][1]))
consec_n = [(n, a["consec"]) for n, a in multi.items() if a["consec"]]
k5_ok = worst_e[0] <= 0.30 and worst_l[0] <= 0.20 and worst_bl[0] <= 0.05 and worst_be[0] <= 0.05 and not consec_n
s1 = A["S1"]
s1_seed_bad = sum(1 for s in SEEDS if R["S1"][s]["bs_late"][1] and R["S1"][s]["bs_late"][0] / R["S1"][s]["bs_late"][1] > 0.05)
V.append((5, "≥2 kişilik ekipler: düzeltme payı ilk 20 hafta ≤ %30, sonra ≤ %20; hata sprinti ≤ %5; üst üste iki hata sprinti yok; tek kurucu ilk 20 hafta ≤ %50",
          "GEÇTİ" if k5_ok and s1["fix_early"] <= 0.5 else "KIRIK",
          "≥2 kişilikte en kötü: erken pay %s (%s), geç pay %s (%s), hata sprinti geç %s (%s), erken %s, üst üste: %s. Tek kurucu erken pay %s." % (
              pc(worst_e[0]), worst_e[1], pc(worst_l[0]), worst_l[1], "%.1f%%" % (worst_bl[0] * 100), worst_bl[1], ("en çok %.1f%% (%s)" % (worst_be[0] * 100, worst_be[1])) if worst_be[0] else "hiçbirinde yok",
              "yok" if not consec_n else str(consec_n), pc(s1["fix_early"]))))
if not k5_ok:
    KIR.append("K5: ≥2 kişilikte A hedefi aşılıyor: " + str((worst_e, worst_l, worst_bl, consec_n)))
if s1["bs_late"][0] / s1["bs_late"][1] > 0.05 or s1["consec"]:
    OBS.append("Tek kurucu (S1) hata sprinti: geç pencerede %s sprint (%.1f%%), erken pencerede %s (%.1f%%); 20 tohumdan %d'sinde üst üste iki hata sprinti var, "
               "%d tohumda geç oran %%5'i aşıyor. Belgenin 5. ölçütü bunu yalnız ≥2 kişilik ekipler için sayıyor; A'nın E1 §9 hedefi ise 'her ekipte' diyor." % (
                   ratio(s1["bs_late"]), s1["bs_late"][0] / s1["bs_late"][1] * 100, ratio(s1["bs_early"]), s1["bs_early"][0] / s1["bs_early"][1] * 100, s1["consec"], s1_seed_bad))

# K6
mx_slope = max(((a["slope"], n) for n, a in A.items() if a["slope"] is not None))
V.append((6, "Açık hata sınırsız büyümez (son 20 hafta eğimi ≤ 0,2 hata/hafta)", "GEÇTİ" if mx_slope[0] <= 0.2 else "KIRIK",
          "Bütün senaryolarda en büyük medyan eğim %+.2f hata/hafta (%s)." % mx_slope))
if mx_slope[0] > 0.2:
    KIR.append("K6: açık hata eğimi %.2f (%s)." % mx_slope)

# K7
def mono(prefix):
    xs = [A["%s_%d" % (prefix, k)]["esc_card"] for k in (2, 4, 6, 8, 10)]
    return xs, all(a > b for a, b in zip(xs, xs[1:]))
x3, m3 = mono("T3"); x4, m4 = mono("T4")
cv = sum(a["cviol"] for a in A.values())
k7_ok = m3 and m4 and cv == 0
V.append((7, "Kart başı kaçan hata testçi yıldızıyla azalır; yakalama en iyi testçisininkini aşmaz", "GEÇTİ" if k7_ok else "KIRIK",
          "S3 (1★→5★ testçi): %s; S4: %s; yakalama tavanı aşımı: %d kart (bütün koşular)." % (
              " → ".join("%.2f" % x for x in x3), " → ".join("%.2f" % x for x in x4), cv)))
if not k7_ok:
    KIR.append("K7: testçi yıldızı kaçan hatayı düzgün azaltmıyor ya da yakalama tavanı aşılıyor.")

# K8
c8 = [("S3_PMsiz", "S3"), ("S4_PMsiz", "S4_1PM"), ("S4_PMsiz", "S4")]
k8_ok = all(A[b]["esc_card"] < A[a]["esc_card"] and A[b]["deliv"] > A[a]["deliv"] for a, b in c8)
V.append((8, "PM'siz ekibe PM eklemek kaçan hatayı düşürür ve teslimi artırır", "GEÇTİ" if k8_ok else "KIRIK",
          "; ".join("%s → %s: teslim %.1f → %.1f, kaçan hata %.2f → %.2f" % (a, b, A[a]["deliv"], A[b]["deliv"], A[a]["esc_card"], A[b]["esc_card"]) for a, b in c8) + "."))
if not k8_ok:
    KIR.append("K8: PM eklemek kaçan hatayı düşürmüyor ya da teslimi artırmıyor.")

# K9
k9 = [(n, a) for n, a in A.items() if a["idle_w"] / a["n"] > 0.10 and a["bott"] == "yok"]
V.append((9, "Boşta > %10 ise darboğaz ya da kart arzı sınırı görünür", "GEÇTİ" if all(n == "S12" for n, a in k9) else "KIRIK",
          "Boşta > %10 ve darboğaz 'yok' olan tek senaryo: " + (", ".join("%s (boşta %.1f/%d)" % (n, a["idle_w"], a["n"]) for n, a in k9) if k9 else "yok") +
          ". S12 tek kart kipidir, kart arzı sınırı senaryonun tanımıdır."))
if any(n != "S12" for n, a in k9):
    KIR.append("K9: " + str([n for n, a in k9 if n != "S12"]))

# K10
pm = max(a["pred"] for a in A.values())
V.append((10, "Tahmin = sonuç (fark ≤ 1e-6)", "GEÇTİ" if pm <= 1e-6 else "KIRIK",
          "Her sprintte planlama anında alınan 2 haftalık kopya, kapanıştaki gerçek sonuçla kart-aşama ilerlemesi, bitiş zamanı ve E bakımından karşılaştırıldı; %d senaryo × 20 tohumda en büyük fark %.1e." % (
              sum(1 for n in A if not n.startswith("M|")), pm)))
if pm > 1e-6:
    KIR.append("K10: tahmin ≠ sonuç, fark %g." % pm)

# genel olcutler: baskin strateji
mixn = list(MIXES)
refk = mixn[0]
dom = {}
for mname in mixn[1:]:
    ok = True; better = False
    for nn in MIX_N:
        a, r_ = A["M|%s|%d" % (mname, nn)], A["M|%s|%d" % (refk, nn)]
        if a["deliv"] < r_["deliv"] or a["esc_card"] > r_["esc_card"] + 0.005:
            ok = False
        if a["deliv"] > r_["deliv"] * 1.02:
            better = True
    dom[mname] = ok and better
gen_dom = [m for m, v in dom.items() if v]
