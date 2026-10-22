# ----------------------------------------------------------------------------------- rapor (2. yarı)
ROLE_TR = {"founder": "kurucu", "dev": "geliştirici", "test": "testçi", "des": "tasarımcı", "pm": "PM"}

w("## 4. Kişi ekleme eğrisi (1-50 kişi, sabit rol karışımı)")
w("Karışım S6'nın oranı (kurucu + %12 PM, %16 tasarımcı, %51 geliştirici, %20 testçi). Her satır bir öncekinin üstüne tek kişi ekler. "
  "Sprint çıktısı = sprint başına biten özellik kartlarının puanı. Marjinal = bir önceki satıra göre sprint çıktısı farkı (haftalık hâli yarısıdır).")
w()
roles = R["C50"][1]["role"]
rows = []
prev = None
by_role = {}
for n in range(1, 51):
    a = A["C%d" % n]
    m = None if prev is None else a["sprint_out"] - prev["sprint_out"]
    if m is not None:
        by_role.setdefault(roles[n - 1], []).append(m / 2)
    rows.append((n, ROLE_TR[roles[n - 1]], f(a["deliv"]), f(a["sprint_out"]), "-" if m is None else "%+.1f" % m, f(a["per_person"], 2), f(a["esc_card"], 2),
                 f(a["idle_w"]), f(a["open_med"]), pc(a["fix_late"]), a["bott"], pc(a["ready"])))
    prev = a
table(["Kişi", "Eklenen", "Teslim/hf", "Sprint çıktısı", "Marjinal (puan/sprint)", "Kişi başı", "Kaçan hata/kart", "Boşta", "Açık hata", "Düzeltme payı", "Darboğaz", "Hazır kart"], rows)
w("Eklenen role göre ortalama marjinal getiri (puan/hafta):")
w()
table(["Eklenen rol", "Adım sayısı", "Ortalama", "En küçük", "En büyük"],
      [(ROLE_TR[r], len(v), "%+.1f" % statistics.mean(v), "%+.1f" % min(v), "%+.1f" % max(v)) for r, v in sorted(by_role.items(), key=lambda t: -statistics.mean(t[1]))])
pos = sum(1 for v in curve_m.values() if v > 0)
zero = sum(1 for v in curve_m.values() if v == 0)
negs = sorted([(k, v) for k, v in curve_m.items() if v < 0], key=lambda t: t[1])
w("49 adımın %d'si artı, %d'si sıfır, %d'si eksi. Eksiler: %s. Kişi başı teslim n ≥ 5 için %.1f ile %.1f arasında; 1-4 kişide (tasarımcısız) 5,4-6,2." % (
    pos, zero, len(negs), ", ".join("%d. kişi %+.1f" % kv for kv in negs),
    min(A["C%d" % n]["per_person"] for n in range(5, 51)), max(A["C%d" % n]["per_person"] for n in range(5, 51))))
w()
des_steps = [(n, curve_m[n]) for n in range(2, 51) if roles[n - 1] == "des"]
oth_steps = [curve_m[n] for n in range(2, 51) if roles[n - 1] in ("dev", "test")]
w("Eğri düzgün değil, merdiven: tasarım aşamasını yalnız tasarımcılar (ve kurucu) yapıyor, bu yüzden tasarımcı adımları (n = %s) haftada %+.1f ile %+.1f puan getiriyor (ortalama %+.1f); "
  "geliştirici ve testçi adımları ortalama %+.1f (en büyüğü %d. kişi, %+.1f: 48. kişideki kaybı geri alan testçi). Marjinal getiri 48. kişi dışında hiçbir yerde eksi değil. Basamak yüksekliği ekip büyüdükçe küçülmüyor, 50 kişide de tasarımcı eklemek en çok kazandıran adım." % (
      ", ".join(str(n) for n, _ in des_steps), min(v for _, v in des_steps), max(v for _, v in des_steps), statistics.mean(v for _, v in des_steps),
      statistics.mean(oth_steps), max((v, n) for n, v in curve_m.items() if roles[n - 1] in ("dev", "test"))[1], max(oth_steps)))
w()

w("## 5. Marjinal getiri tablosu")
w("Taban ekibe bir kişi eklenince teslim farkı (puan/hafta); parantezde ekli ekibin kart başı kaçan hatası. Her hücre: bu koşu / belge §4.4.")
w()
DOC44 = {"S2": [12.1, 9.1, 0.6, 7.4, 8.8], "S3": [12.0, 6.0, 0, 0, 9.0], "S4": [4.0, 5.0, 0, 3.0, 2.0], "S5": [2.0, 5.0, 4.0, 12.0, 2.0], "S6": [0, 7.0, 14.0, 12.0, -1.0]}
rows = []
for b in ("S2", "S3", "S4", "S5", "S6"):
    r_ = [LBL[b]]
    for i, ad in enumerate(adds):
        r_.append("%+.1f / %+.1f (%s)" % (marg[(b, ad)], DOC44[b][i], f(A["%s %s" % (b, ad)]["esc_card"], 2)))
    rows.append(r_)
table(["Taban"] + [a.replace("*", "★") for a in adds], rows)
w("En düşük hücre -1,0 (S4'e 3★ tasarımcı), tolerans sınırında; belgedeki tek eksi (S6'ya 1★ geliştirici -1) bu koşuda +1,0 çıktı. "
  "Fark en çok 3,5 puan/hafta (S6 +3★ tasarımcı: +17,5 ve +14), teslimin %0,7'si. Sıfır getiri, o rolün darboğaz olmadığını gösteriyor (S3'e tasarımcı ve PM). 1★ geliştirici hız getiriyor, kart başı hatayı artırıyor (S2: 0,78 → 0,88; S3: 0,57 → 0,62).")
w()

w("## 6. Rol karışımı karşılaştırması (baskın strateji var mı)")
w("Kurucu hep var. Sayılar: PM / tasarımcı / geliştirici / testçi. 'Ref'e göre' teslimin aynı kişi sayısındaki ref karışıma oranı.")
w()
rows = []
for nn in MIX_N:
    ref = A["M|%s|%d" % (refk, nn)]
    for mname in mixn:
        a = A["M|%s|%d" % (mname, nn)]
        c_ = alloc(MIXES[mname][0], nn - 1)
        rows.append((nn, mname, "%d / %d / %d / %d" % (c_["pm"], c_["des"], c_["dev"], c_["test"]), f(a["deliv"]), "%+.0f%%" % ((a["deliv"] / ref["deliv"] - 1) * 100),
                     f(a["esc_card"], 2), f(a["idle_w"]), a["bott"], f(a["open_med"])))
table(["Kişi", "Karışım", "PM/Tas/Gel/Test", "Teslim/hf", "Ref'e göre", "Kaçan hata/kart", "Boşta", "Darboğaz", "Açık hata"], rows)
w("Baskın strateji (bütün boyutlarda ref'ten teslim ≥ ve hata ≤): **yok**. Okuma:")
w("- Hepsi testçi (Yapım+Test kutulu): 12 kişide teslim ref'in %%%d'i, 50 kişide %%%d'i; 12 ile 50 kişi arasında teslim değişmiyor (22,6 → 23,0): tasarımı yalnız kurucu yapıyor. Hata ise kart başı 0,50 (ref 0,57-0,63). Çökmüyor, darboğaz görünüyor." % (
    round(A["M|hepsi testci, Yapim+Test|12"]["deliv"] / A["M|%s|12" % refk]["deliv"] * 100), round(A["M|hepsi testci, Yapim+Test|50"]["deliv"] / A["M|%s|50" % refk]["deliv"] * 100)))
w("- Hepsi geliştirici (Yapım+Test) aynı sebeple 38'de takılıyor. Testçisiz ve kutusuz karışım 41'de takılıyor (test yalnız kurucuda; 50 kişide 39,5 kişi-hafta/hafta boşta).")
w("- Çok testçi (%50) kaçan hatayı en çok düşüren karışım (0,47-0,49) ama teslimi ref'in %72 ile %60'ına indiriyor. Hızla kalite arasında gerçek bir takas var.")
w("- Testçisiz ama geliştiricilere Test kutusu: ref'ten 12 kişide %2, 25 kişide %10, 50 kişide %9 geride, kart başı hata aynı (0,58-0,64 ve 0,57-0,63). Yani ek bir uzman testçi alma kararı yalnız %2-%10 teslim kazandırıyor; belirgin ama baskın değil.")
w("- PM'siz: kişi sayısı büyüdükçe aradaki fark açılıyor (12 kişide -%1, 25'te -%9, 50'de -%9); kaçan hata 0,57 → 0,67.")
w("- Çok PM, çok tasarımcı ve eşit dört rol ref'ten düşük teslim veriyor (50 kişide -%17, -%28, -%39) ve boşta kişi var; ref'e göre kaybettiği tek şey teslim, hata bakımından (0,47-0,52) daha iyi.")
w()

w("## 7. Testçi yıldızı ve PM'in değeri")
w("### 7.1 Testçi yıldızı (K7)")
rows = []
for k in (2, 4, 6, 8, 10):
    rows.append(("%g★" % (k / 2), f(A["T3_%d" % k]["esc_card"], 2), f(A["T3_%d" % k]["deliv"]), f(A["T4_%d" % k]["esc_card"], 2), f(A["T4_%d" % k]["deliv"])))
table(["Testçi", "S3: kaçan hata/kart", "S3: teslim", "S4 benzeri: kaçan hata/kart", "S4 benzeri: teslim"], rows)
w("Kaçan hata yıldızla tek yönde azalıyor: 1★ 0,62 → 5★ 0,43 (yaklaşık -%30). Yakalama oranının üst sınırı hiçbir kartta aşılmadı (0 ihlal).")
w()
w("Aynı deney ölçekte (eğrinin 12, 25 ve 50 kişilik ekipleri; bütün testçiler 1★ ya da 5★):")
w()
rows = []
for nn in (12, 25, 50):
    for k in (2, 10):
        a = A["TS%d_%d" % (nn, k)]
        rows.append((nn, "%g★" % (k / 2), f(a["esc_card"], 2), f(a["deliv"]), f(a["open_med"]), f(a["open_max"], 0), pc(a["fix_late"]), f(a["fixes"])))
table(["Kişi", "Testçiler", "Kaçan hata/kart", "Teslim/hf", "Açık hata (med)", "Açık max", "Düzeltme payı", "Düzeltme kartı/sprint"], rows)
w("Kart başı hata yaklaşık %32 iniyor (0,62 → 0,42 / 50 kişide) ve teslim %" + str(round((A["TS50_10"]["deliv"] / A["TS50_2"]["deliv"] - 1) * 100)) +
  " artıyor (50 kişide), ama **açık hata sayısı ve düzeltme payı değişmiyor** (50 kişide açık hata 16,2 ve 16,0; düzeltme kartı sprint başına 4,7 ve 4,7). "
  "Sebep: 5★ testçi aynı zamanda daha hızlı, ekip daha çok kart teslim ediyor; haftalık toplam kaçan hata iki durumda da aynı kalıyor. Bu kırılma değil, gözlem olarak 13. bölümde.")
w()
w("### 7.2 PM'in değeri ve uymayan iş")
rows = []
for n in ("S3_PMsiz", "S3", "S3_PM_testkutulu", "S4_PMsiz", "S4_1PM", "S4", "S5_1PM", "S5", "S10"):
    a = A[n]
    rows.append((LBL[n], a["n"], f(a["deliv"]), f(a["per_person"], 2), f(a["esc_card"], 2), pc(a["ready"]), f(a["idle_w"])))
table(["Ekip", "Kişi", "Teslim/hf", "Kişi başı", "Kaçan hata/kart", "Hazır kart", "Boşta"], rows)
w("PM eklemek her yerde hem kaçan hatayı düşürüyor hem teslimi artırıyor (K8 geçti). 25 kişide tek PM kartların %24'ünü, üç PM %69'unu hazırlıyor (belgedeki sayılar). PM'in Test kutusu işaretlenirse (S3): teslim 55 → 50, hazırlık %100 → %68, PM'in 60 haftalık moral kaybı medyan " + str(round(pmm)) + " (en az " + str(min(R["S3_PM_testkutulu"][s_]["morale"][1] for s_ in SEEDS)) + ", en çok " + str(max(R["S3_PM_testkutulu"][s_]["morale"][1] for s_ in SEEDS)) + "); kural 'bu böyle çalışmaz'ı sayıyla söylüyor.")
w()

w("## 8. A'nın hedefleri (E1 §9)")
w("Hedefler: düzeltme payı erken ≤ %30 (tek kurucu ≤ %50), geç ≤ %20; hata sprinti erken ≤ %15, geç ≤ %5; üst üste iki hata sprinti yok.")
w()
rows = []
for n in ("S1", "S2", "S3", "S4", "S5", "S6", "S10"):
    a = A[n]
    ok_ = ((a["fix_early"] <= (0.5 if a["n"] == 1 else 0.3)) and a["fix_late"] <= 0.2 and a["bs_early"][0] / a["bs_early"][1] <= 0.15 and
           a["bs_late"][0] / a["bs_late"][1] <= 0.05 and a["consec"] == 0)
    rows.append((LBL[n], pc(a["fix_early"]), pc(a["fix_late"]), "%s (%.1f%%)" % (hs(a, "early"), a["bs_early"][0] / a["bs_early"][1] * 100),
                 "%s (%.1f%%)" % (hs(a, "late"), a["bs_late"][0] / a["bs_late"][1] * 100), a["consec"], "tutuyor" if ok_ else "TUTMUYOR"))
table(["Ekip", "Düzeltme payı erken", "geç", "Hata sprinti erken", "geç", "Üst üste (tohum)", "Hedef"], rows)
w("Eğri dahil, n ≥ 2 olan bütün %d senaryoda: en yüksek erken pay %s, en yüksek geç pay %s, en yüksek hata sprinti oranı %.1f%%, üst üste hata sprinti yok. Yani A'nın hedefleri ≥2 kişide ölçekle bozulmuyor; payı ölçek küçültüyor (%s → %s)." % (
    len(multi), pc(worst_e[0]), pc(worst_l[0]), max(worst_bl[0], worst_be[0]) * 100, pc(A["C2"]["fix_late"]), pc(A["C50"]["fix_late"])))
w("Tek kurucu hedefi tutmuyor (yukarıdaki satır): düzeltme payı sabit %25 (20 puanlık sprintte 5 puanlık düzeltme kartı) ve bir hat için ikinci bir 5 puanlık kart daha gelince sprint yarıdan fazla düzeltmeye gidiyor.")
w()

w("## 9. MVP haftası")
rows = [(LBL[n], f(A[n]["mvp"], 0), "%s-%s" % (A[n]["mvp_min"], A[n]["mvp_max"])) for n in ("S1", "S2", "S3", "S4", "S5", "S6", "S7", "S8", "S9a", "S10", "S11", "S12")]
table(["Ekip", "MVP haftası (medyan)", "20 tohumda aralık"], rows)
w("Tek kurucu her tohumda 6. haftada (üç K1 kartı 45 puan, sprint 1,5 + 2 + 2 hafta). Ekipler 4 ve 2. haftada; bunlar tam ekiple 0. haftadan başlayan yapay senaryo, oyunda ekip MVP'den sonra büyür.")
w()

w("## 10. Akış: sprintteki kart, bekleme")
w("Sprintteki kart = sprint başında planlanan toplam kart (devredenler ve düzeltme dahil). Bekleme = bir özellik kartının sprinte girişinden bitişine geçen hafta. Bir kartın en kısa süresi 3★ ekiple K1 için yaklaşık 1 hafta, K3 için 1,8 hafta (§3.4).")
w()
rows = []
for n in ("S2", "S3", "S4", "S5", "S6", "S10", "S8", "S11", "C47", "C48"):
    a = A[n]
    rows.append((LBL.get(n, "Eğri · %s kişi" % n[1:]), f(a["wip"]), f(a["cards_sprint"] + a["fixes"]), f(a["lead"], 1), f(a["open_max"], 0)))
table(["Ekip", "Sprintteki kart", "Biten kart/sprint (düzeltme dahil)", "Ortalama bekleme (hf)", "Açık max"], rows)
w("Sağlıklı ekiplerde bekleme 3,5 hafta (yaklaşık iki sprint) ve sprintteki kartların yaklaşık üçte biri yarım kalıp sonraki sprinte devrediyor. Testçisiz S11'de bekleme 27,7 hafta: kartlar test aşamasında birikiyor, plan ekranının göstermesi gereken şey bu.")
w()
