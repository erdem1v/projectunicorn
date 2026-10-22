# Rapor uretimi: python -I dsim3.py exec mkreport.py   -> D_SIM_v3.md
exec(open("an_common.py", encoding="utf-8").read())
import json, os
T1 = json.load(open("out/tb1.json", encoding="utf-8"))
T2 = json.load(open("out/tb2.json", encoding="utf-8"))
A, B, C, D, E, F, G, H, H2, I, R = (L(x) for x in ("A", "B", "C", "D", "E", "F", "G", "H", "H2", "I", "R"))
CH = json.load(open("out/check69.json", encoding="utf-8"))


def tr(x, d=1):
    return (("%." + str(d) + "f") % x).replace(".", ",") if x is not None else "-"


def pc(x, d=0):
    return "%" + tr(100 * x, d)


def sp(x, d=0):
    v = 100 * x
    return ("+%" if v >= 0 else "−%") + tr(abs(v), d)


def sg(x, d=1):
    return (("%+." + str(d) + "f") % x).replace(".", ",")


def win(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk


def wm(R_, n, a, b):
    return statistics.median([win(m, a, b) for m in R_[n].values()])


X = {}
# ---- 6.9 tablosu
rows = ["| Örnek | Beklenen (§6.9) | Bulunan |", "|---|---|---|"]
for a, b, c in CH:
    rows.append("| %s | %s | %s |" % (a, b.replace("|", "/"), c.replace("|", "/").replace(".", ",")))
X["check"] = "\n".join(rows)
for a_, b_ in (("0* baskasi", "başkasının kartı 0★"), ("3* baskasi", "başkasının kartı 3★"), ("5* baskasi", "başkasının kartı 5★"), ("3* kendi karti", "kendi kartı 3★"),
               ("[3.45, 2.33, 1.95, 1.77, 1.77, 1.77]", "[3,45, 2,33, 1,95, 1,77, 1,77, 1,77]")):
    X["check"] = X["check"].replace(a_, b_)

# ---- PM yildizi tablosu
rows = ["| Ekip, tek PM | Teslim 1★ / 3★ / 5★ | Kaçan / kart | Hazır kart | PM'siz |", "|---|---|---|---|---|"]
for lab, pre, nopm in (("6 kişi (S3)", "PM3", ("S3_PMsiz", A)), ("11 kişi", "PM4", ("S4_PMsiz", A)), ("23 kişi", "PM5", ("PM5_yok", D))):
    dl = " / ".join(tr(md(D, pre + "_%d" % s, "deliv")) for s in (1, 3, 5))
    es = " / ".join(tr(md(D, pre + "_%d" % s, "esc_card"), 2) for s in (1, 3, 5))
    rd = " / ".join(pc(md(D, pre + "_%d" % s, "ready")) for s in (1, 3, 5))
    n_, R_ = nopm
    rows.append("| %s | %s | %s | %s | %s (kaçan %s, %d kişi) |" % (lab, dl, es, rd, tr(md(R_, n_, "deliv")), tr(md(R_, n_, "esc_card"), 2), md(R_, n_, "n")))
X["pm"] = "\n".join(rows)
rows = ["| Ekip | 1★ → 5★ teslim | 1★ → 5★ kaçan / kart | Hazır kart (1★ → 5★) |", "|---|---|---|---|"]
Q = L("P_p11")
for lab, pre in (("25 kişi, 3 PM", "PM6"), ("24 kişi, 2 PM", "PM7")):
    d1, d5 = md(Q, pre + "_1", "deliv"), md(Q, pre + "_5", "deliv")
    e1, e5 = md(Q, pre + "_1", "esc_card"), md(Q, pre + "_5", "esc_card")
    rows.append("| %s | %s → %s (%s) | %s → %s (%s) | %s → %s |" % (lab, tr(d1), tr(d5), sp(d5 / d1 - 1, 1), tr(e1, 2), tr(e5, 2), sp(e5 / e1 - 1, 1), pc(md(Q, pre + "_1", "ready")), pc(md(Q, pre + "_5", "ready"))))
X["pm_prop"] = "\n".join(rows)

# ---- oneri tablolari
P16 = {t: L("P_" + t) for t in ("p16_d8", "p16_dinf", "p16_div5", "p16c_d8div5", "p16d_dinfdiv5")}
names16 = (("A|S5|kaynakli|2", "S5 · 25 kişi, 3 hesap/hf"), ("A|S6|kaynakli|2", "S6 · 50 kişi, 3 hesap/hf"), ("R|S5|330", "S5, 330 hesap"), ("R|S6|330", "S6, 330 hesap"), ("GC|kaynakli", "büyüme eğrisi 1→10 kişi"))
rows = ["| Ölçüm | Taban (sınır 4, bölen 10) | Sınır 8 | Sınır yok | Bölen 5 | Bölen 5, sınır 8 | Bölen 5, sınır yok |", "|---|---|---|---|---|---|---|"]
for n, lab in names16:
    base = G if n in G else R
    cells = ["%s · %s · boşta %s" % (pc(md(base, n, "pool_ok")), tr(md(base, n, "deliv")), pc(md(base, n, "idle_pct")))]
    for t in ("p16_d8", "p16_dinf", "p16_div5", "p16c_d8div5", "p16d_dinfdiv5"):
        R_ = P16[t]
        cells.append("%s · %s · boşta %s" % (pc(md(R_, n, "pool_ok")), tr(md(R_, n, "deliv")), pc(md(R_, n, "idle_pct"))))
    rows.append("| %s (aday ≥ hedef · teslim · boşta) | %s |" % (lab, " | ".join(cells)))
X["p16"] = "\n".join(rows)

P19 = L("P_p19_skip12")
rows = ["| Ekip · sprint | Öneri doluluğu: taban → atlayarak | Teslim | Boşta payı | Sprintte kart | Düzeltme payı (geç) | Hata sprinti |", "|---|---|---|---|---|---|---|"]
for b, k in (("S2", 3), ("S3", 6), ("S4", 12), ("S5", 25), ("S6", 50)):
    for sw in (1, 2):
        n = "A|%s|kaynakli|%d" % (b, sw)
        rows.append("| %s · %d · %d hf | %s → %s | %s → %s | %s → %s | %s → %s | %s → %s | %s → %s |" % (b, k, sw, pc(md(G, n, "fill_ratio")), pc(md(P19, n, "fill_ratio")), tr(md(G, n, "deliv")), tr(md(P19, n, "deliv")),
                                                                                      pc(md(G, n, "idle_pct")), pc(md(P19, n, "idle_pct")), tr(md(G, n, "wip")), tr(md(P19, n, "wip")),
                                                                                      pc(md(G, n, "fix_late"), 1), pc(md(P19, n, "fix_late"), 1), hs(G, n), hs(P19, n)))
X["p19"] = "\n".join(rows)

P22 = L("P_p22_kayip1")
P22b = L("P_p22b_marjinal")
rows = ["| Düzen | Taban: teslim 67-130 hf | Kayıp %1 (tüm takım) | Kayıp yalnız 8. kişiden sonra gelenlere | Kişi eklemede en kötü: taban | Kayıp %1 | Marjinal kayıp |", "|---|---|---|---|---|---|---|"]


def worst_add(R_, base_R, tn):
    w = 0.0
    for ak in EA_ADD:
        n = "%s %s" % (tn, ak)
        for (a, b) in ((20, 60), (66, 130)):
            w = min(w, wm(R_, n, a, b) - wm(base_R, tn, a, b))
    return w


for tn, lab in (("EA3", "3 takım (liderli)"), ("EA7", "7 takım (liderli)")):
    rows.append("| %s | %s | %s | %s | %s | %s | %s |" % (lab, tr(wm(H, tn, 66, 130)), tr(wm(P22, tn, 66, 130)), tr(wm(P22b, tn, 66, 130)),
                                                         sg(worst_add(H2, H, tn)), sg(worst_add(P22, P22, tn)), sg(worst_add(P22b, P22b, tn))))
e0 = wm(H, "EA0", 66, 130)
X["p22"] = "\n".join(rows)
X["p22_ratio"] = "Takımsıza göre: 3 takım taban %s, marjinal %s; 7 takım taban %s, marjinal %s" % (pc(wm(H, "EA3", 66, 130) / e0), pc(wm(P22b, "EA3", 66, 130) / e0), pc(wm(H, "EA7", 66, 130) / e0), pc(wm(P22b, "EA7", 66, 130) / e0))

PF = L("P_pfix_min25")
rows = ["| Ekip · 1 hf sprint | Teslim | Düzeltme payı (geç) | Hata sprinti | Açık hata (medyan) |", "|---|---|---|---|---|"]
for n, lab in (("A|S1|kaynakli|1", "S1 · tek kurucu"), ("A|S2|kaynakli|1", "S2 · 3 kişi"), ("A|S3|kaynakli|1", "S3 · 6 kişi")):
    rows.append("| %s | %s → %s | %s → %s | %s → %s | %s → %s |" % (lab, tr(md(G, n, "deliv")), tr(md(PF, n, "deliv")), pc(md(G, n, "fix_late"), 1), pc(md(PF, n, "fix_late"), 1), hs(G, n), hs(PF, n), tr(md(G, n, "open_med")), tr(md(PF, n, "open_med"))))
X["pfix"] = "\n".join(rows)

# ---- kurucu: oneri kapi okumasi (kapi 2) sayilari
cnt = {"asama": 0, "bolundu": 0, "hazirlik": 0, "yok": 0}
SQK = {"gel-tas-test": ["dev", "des", "test"], "tas-gel-test": ["des", "dev", "test"], "test-gel-tas": ["test", "dev", "des"], "pm-gel-tas": ["pm", "dev", "des"], "1yildiz": ["dev", "des", "test"], "uc-gel": ["dev", "dev", "dev"]}
worst = 0
tot_steps = 0
for f in ("orta", "gel4", "gel5", "tasarim_test"):
    for s, seq in SQK.items():
        base = md(E, "G|%s|%s|0" % (f, s), "founder_w")
        for k in range(1, 4):
            tot_steps += 1
            n = "G|%s|%s|%d" % (f, s, k)
            p = "G|%s|%s|%d" % (f, s, k - 1)
            fw, pf = md(E, n, "founder_w"), md(E, p, "founder_w")
            worst = min(worst, fw / base - 1)
            if fw < pf * 0.98:
                fa = [md(E, p, "founder_st", i) for i in range(4)]
                fb = [md(E, n, "founder_st", i) for i in range(4)]
                sa = [md(E, p, "stage_w", i) for i in range(4)]
                sb = [md(E, n, "stage_w", i) for i in range(4)]
                shA = [x / sum(fa) for x in fa]
                shB = [x / sum(fb) for x in fb]
                dom = fa.index(max(fa)) != fb.index(max(fb))
                big = max(abs(a - b) for a, b in zip(shA, shB)) >= 0.20
                ss = min(range(4), key=lambda i: fb[i] - fa[i])
                shared = sb[ss] > 0 and fb[ss] / sb[ss] < fa[ss] / sa[ss] - 0.02
                if dom or big:
                    cnt["asama"] += 1
                elif seq[k - 1] == "pm":
                    cnt["hazirlik"] += 1
                elif shared:
                    cnt["bolundu"] += 1
                else:
                    cnt["yok"] += 1
X["g2cnt"] = cnt
X["g2worst"] = worst

# ---- EA aciklama
rows = ["| Düzen | Pencere | Gerçek | Tahmin: takımsız × ort. çarpan × (1 − boşta) ÷ (1 − takımsız boşta) | Fark açıklanan |", "|---|---|---|---|---|"]


def winb(m, a, b):
    ser = [x for x in m["series"] if a < x[1] <= b]
    wk = sum(x[1] - x[0] for x in ser)
    return sum(x[2] for x in ser) / wk, sum(x[7] * (x[1] - x[0]) for x in ser) / wk


for (a, b, lab) in ((66, 130, "67-130 hf"), (20, 60, "21-60 hf")):
    d0 = statistics.median([winb(m, a, b)[0] for m in H["EA0"].values()])
    i0 = statistics.median([winb(m, a, b)[1] for m in H["EA0"].values()])
    for n, nl in (("EA1", "1 takım"), ("EA3", "3 takım"), ("EA7", "7 takım"), ("EA3_lidersiz", "3 takım lidersiz"), ("EA7_lidersiz", "7 takım lidersiz")):
        d = statistics.median([winb(m, a, b)[0] for m in H[n].values()])
        i = statistics.median([winb(m, a, b)[1] for m in H[n].values()])
        m0 = next(iter(H[n].values()))
        mavg = sum(c * x for c, x in zip(m0["cell_n"], m0["cell_mult"])) / sum(m0["cell_n"])
        pred = d0 * mavg * (1 - i) / (1 - i0)
        rows.append("| %s | %s | %s | %s (çarpan %s, boşta %s → %s) | %s |" % (nl, lab, tr(d), tr(pred), tr(mavg, 3), pc(i0), pc(i), pc(1 - abs(pred - d) / abs(d0 - d))))
X["ea_expl"] = "\n".join(rows)

# ---- kapi tablosu icin gecti/kaldi
GJ = {g["no"]: g for g in json.load(open("out/gates.json", encoding="utf-8"))}


def st(no):
    return "GEÇTİ" if GJ[no]["gecti"] else "**KALDI**"


rows = ["| # | Kapı | Hedef | Sonuç | Değer |", "|---|---|---|---|---|"]
GV = {
    1: ("`ekleme_dusurmez`", "Bir kişi eklemek hiçbir senaryoda teslimi 1 puan/hf'den fazla düşürmez (takım kipi kapı 22'de)", "En kötü −1,0 (S3'e 3★ tasarımcı; sınırda). Marjinal tablo −1,0, kişi ekleme eğrisi −0,5 (37. kişi, PM), kurucu büyümesinin 72 adımında en küçük artış +0,2"),
    2: ("`kurucu_buyume`", "Teslim her adımda artar; MVP gecikmez; kurucunun işi en çok %10 düşer ve nedeni (aşama değişti) kayıtta", "Teslim 72 adımda da arttı (en küçük +0,2); MVP gecikmesi 0. Kurucunun işi tabana göre en çok −%10,1 (5★ kurucu, üç geliştirici); %2'den büyük 16 düşüşün 9'unda aşama değişmedi"),
    3: ("`mvp_tek_kurucu`", "6 ile 7. hafta", "20 tohumun 17'sinde 6., 3'ünde 7. hafta"),
    4: ("`kisi_basi_olcek`", "S5 ve S6 kişi başı, S3'ün %70 ile %150'si", "S5 %132,8, S6 %134,8 (kişi başı 8,0 · 10,6 · 10,8)"),
    5: ("`darbogaz_rolu`", "Darboğaz rolüne kişi eklemek teslimi artırır", "S8 + Test kutulu geliştirici 17,0 → 24,5; S11 + testçi 36,0 → 91,0; S9a + geliştirici 7,9 → 17,4"),
    6: ("`duzeltme_payi`", "≥ 2 kişi: erken ≤ %30, geç ≤ %20, hata sprinti ≤ %5, üst üste yok; tek kurucu erken ≤ %50, geç hata sprinti ≤ %5; dört politikada da", "341 senaryo: ≥ 2 kişide en yüksek erken %16,7, geç %16,7, hata sprinti %0,5; tek kurucuda erken en çok %29,1, hata sprinti en çok %1,2; üst üste hata sprinti yok"),
    7: ("`toplam_hata_isi`", "Düzeltme kartı + sprint içi düzeltme ≥ 2 kişide ≤ %20, tek kurucuda ≤ %35", "≥ 2 kişide en çok %17,4; tek kurucuda en çok %29,8 (S1 %29,6)"),
    8: ("`acik_hata_sinirli`", "`fix_due` ile son 20 haftanın eğimi ≤ 0,2 hata/hf", "En büyük medyan eğim +0,10; A senaryosunda tohum dağılımının %95'i 0,27"),
    9: ("`testci_yildizi`", "1★ → 5★: kaçan / 100 puan ≥ %40 azalır, bulunan ≥ 2 katı; C en iyi testçinin c'sini aşmaz", "6 kişi −%56,8 ve ×2,6; 12 kişi −%60,9 ve ×2,3; 25 kişi −%63,5 ve ×2,7; tavan aşımı 0 kart"),
    10: ("`testci_degeri`", "Testçisiz yerine 3★ testçi: teslim düşmez, kaçan / 100 ≥ %20 azalır", "6 kişi teslim +%8,9, kaçan −%35,8; 12 kişi +%9,1 ve −%25,9; 25 kişi +%14,3 ve −%24,9"),
    11: ("`pm_yildizi`", "Tek PM 1★ → 5★: teslim ≥ %10, kaçan / kart ≥ %25 azalır; PM'siz → PM iyileşir", "6 kişi +%22,4 ve −%43,3; 11 kişi +%23,2 ve −%33,3; **23 kişi +%11,1 ve −%19,9 (kalan)**; PM'siz → PM üç ekipte de iyileşiyor"),
    12: ("`soru_sikligi`", "S2 ile S5 ve S10: soru ≤ 1/3; 6 ve 12 kişide ≥ 1/20", "S2 %4,5 · S3 %21,5 · S4 %29,2 · S5 %18,5 · S10 %11,8; iki 5★ testçili 12 kişi %32,8"),
    13: ("`soru_politikasi`", "Dört politikada teslim farkı ≤ %2; hep gönder açık hata medyanını ≤ %20 artırır; hata sprinti yok", "Teslim farkı en çok %0,9 (S4); hep gönder açık hatayı en çok %13,8 artırır (S10); S2'de (kapsam dışı) gönder −%2,5"),
    14: ("`tahmin_sonuc`", "Plan ile kapanış: aşama ilerlemesi, bitiş, n, F farkı ≤ 1e-6", "8.220 koşuda en büyük fark 1,4e-14 (bulunan hata ve düzeltme işi dahil)"),
    15: ("`a_sinirlari_oranli`", "Hiç düzeltmeyen her ölçekte 10 ile 26 haftada k × 30'a varır; `fix_due` hiçbirinde varmaz", "Medyan varış S1 23 · S2 23,5 · S3 20,5 · S4 17 · S5 17 · S6 15 hf (9 hat: 23 · 17 · 16 · 17 · 17 · 15); `fix_due` 120 koşunun hiçbirinde varmadı"),
    16: ("`arz_havuzu`", "Kaynaklı arzda sprintlerin ≥ %90'ında açık aday ≥ 0,75 × ekip (8 kişi altında ≥ ekip)", "Büyüme eğrisi %100; S1 ile S4 %100; **S5 %80, S6 %0** (330 hesapta S5 %100, S6 %0)"),
    17: ("`bosta_nedenli`", "Boşta ≤ %10; değilse her sprintte nedeni yazılı", "7.460 koşunun 5.525'inde boşta > %10; hepsinde dört nedenin toplamı boşta'ya eşit (nedensiz 0)"),
    18: ("`kart_yok_sprinti`", "Büyüme eğrisi, 130 hf: \"planlanacak kart kalmadı\" sprinti ≤ %5", "Kaynaklı %0,0 (sonlu katalog %92,2)"),
    19: ("`oneri_dolulugu`", "Önerinin aldığı iş ÷ planın alabileceği ≥ %95; bot = öneri", "**En düşük %77,0 (S2, 1 hf); S2 %77 ile %87, S3 %89, S4 %94 ile %95**; S5 ve S6 ≥ %97,8. Bot ayrı yol kullanmıyor"),
    20: ("`derinlik_kazanci`", "Aynı alana art arda 5 derinlik kartı: 5.'nin kazancı ilkinin ≤ 1/3'ü", "%31,6 (0,75⁴); S6 kaynaklı koşuda 80 alanın 80'inde ≥ 5 derinlik kartı bitti"),
    21: ("`istek_payi`", "100 ve 330 hesapta isteğin payı raporlanır", "Teslim puanında istek payı: S3 %68,5 / %74,8 · S4 %36,9 / %83,9 · S5 %17,7 / %57,4 · S6 %13,2 / %35,0 (100 / 330 hesap)"),
    22: ("`takim_bolme`", "50 kişi 3 ve 7 takım liderli: teslim takımsızdan geri kalmaz ya da farkı takım satırında yazılı; lidersiz 7 takım takımsızdan yavaş; kişi eklemek düşürmez (−1)", "67-130. hf: takımsız 411,1; 1 takım 368,9; 3 takım 304,8; 7 takım 252,6; lidersiz 3 takım 248,3; lidersiz 7 takım 213,3. **Kişi eklemede en kötü −2,9 (7 takım, testçi)**"),
    23: ("`uymayan_moral`", "S3 + PM'in Test kutusu: PM 60 haftada 60 ile 90 moral kaybeder", "PM medyan −68 (en az −56, en çok −80)"),
}
for no in sorted(GV):
    a, b, c = GV[no]
    rows.append("| %d | %s | %s | %s | %s |" % (no, a, b, st(no), c))
X["gates"] = "\n".join(rows)
X["npass"] = sum(1 for g in GJ.values() if g["gecti"])

txt = open("rapor_taslak.md", encoding="utf-8").read()
for k, v in list(T1.items()) + list(T2.items()) + list(X.items()):
    txt = txt.replace("@@%s@@" % k, v if isinstance(v, str) else str(v))
left = [w for w in set(__import__("re").findall(r"@@(\w+)@@", txt))]
print("doldurulmayan:", left)
import re
txt = re.sub(r"(?<![\w)])-(?=\d)", "−", txt)
out = "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/D_SIM_v3.md"
open(out, "w", encoding="utf-8", newline="\n").write(txt)
print("yazildi", out, len(txt.split("\n")), "satir")
print(X["g2cnt"], X["g2worst"], X["npass"])
