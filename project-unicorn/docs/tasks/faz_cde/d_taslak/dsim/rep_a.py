# ----------------------------------------------------------------------------------- rapor (1. yarı)
nsc = len(R)
nrun = nsc * len(SEEDS)
nmain = sum(1 for n in A if not n.startswith("M|"))
w("# Faz D · Ekip modeli simülasyon raporu")
w("Hazırlayan: simülasyon alt ajanı, 17 Ekim 2026. Repo kodu değişmedi. Kaynak: `D_MODEL_v2.md` §6 (\"Simülasyon tanımı\"), birebir uygulandı.")
w()
w("Betik: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim/dsim.py` "
  "(sonuç toplama `collect.py` ve `collect2.py`, §6.9 doğrulaması `check69.py`, rapor üretimi `x_rapor.py`; hepsi aynı klasörde, `python -I dsim.py exec <dosya>` ile koşar).")
w()
w("## 0. Özet")
w("1. §6 uygulandı: %d senaryo × 20 tohum = %d koşu, her koşu 60 hafta. Ölçüm penceresi 21-60. hafta, ölçüler 20 tohumun medyanı." % (nsc, nrun))
w("2. Belgenin 5 tohumluk ön hesabı 20 tohumla yeniden üretildi. S1-S6 teslimi: 6,2 / 22,5 / 55 / 116 / 256 / 496,5 (belge 6,1 / 21,9 / 55 / 116 / 257 / 498). "
  "Uç bileşimlerde teslim ve boşta belgeyle uyumlu (en büyük fark S9a, %8).")
w("3. §6.9'un elle doğrulama örneklerinin hepsi tutuyor (kadro, bitiş süresi, E, hazırlık süresi).")
w("4. 10 kırılma ölçütünden 9'u GEÇTİ, **1'i KIRIK**: kişi ekleme eğrisinde 48. kişi (geliştirici) teslimi 470'ten 467'ye düşürüyor "
  "(-3,0 puan/hafta, tolerans -1; teslimin %0,6'sı; 20 tohumun 16'sında aynı yön). Neden atama değil sprint alımı: kapasite tavanı yeni kişiyle büyüyor, sprint daha çok kart alıyor, yarım kalan kart yığını büyüyor.")
w("5. Tek kurucuda A'nın hata sprinti hedefi tutmuyor: geç pencerede %%%.1f (hedef ≤ %%5), 20 tohumun 2'sinde üst üste iki hata sprinti var. "
  "Belgenin 5. ölçütü tek kurucuyu bu hedefe bağlamıyor; ayrı not olarak Kırılmalar'da." % (s1["bs_late"][0] / s1["bs_late"][1] * 100))
w("6. Baskın rol karışımı yok. Testçisiz (kutu işaretsiz), hepsi testçi ve hepsi geliştirici karışımları 12 kişide bile teslimin büyük kısmını kaybediyor ve 50 kişiye çıkınca teslim artmıyor "
  "(tasarımı ve testi yalnız kurucu yapıyor). Geliştiricilere Test kutusu verip testçi almamak ref karışımdan %2 (12 kişi) ile %10 (25 kişi) geride kalıyor: testçi rolünün ek değeri küçük.")
w("7. Hata ve düzeltme payı ölçekle patlamıyor, küçülüyor: kart başı kaçan hata 6 ile 50 kişi arasında 0,52-0,63 (S3-S6'da hep 0,57), düzeltme payı %5 → %3. "
  "Açık hata ekiple büyüyor (8 → 19 medyan); 50 kişide 400 kapanışın 6'sında ≥ 30, yani A'nın mutlak itibar eşiğine yakın.")
w("8. Tek kurucunun MVP'si 20 tohumun hepsinde 6. haftada. Tahmin = sonuç denetimi %d senaryo × 20 tohumda en çok 3,6e-15 fark verdi." % nmain)
w()

w("## 1. Yöntem ve yorumlar")
w("- **Tohum ve pencere.** Tohum 1-20; her koşu 60 hafta (son sprint 61. haftaya taşabilir); ölçü penceresi kapanışı 20. haftadan sonra olan sprintler. Ölçüler tohum medyanı; hata sprinti oranı ve üst üste denetimi 20 tohum toplanarak.")
w("- **Süre.** %d koşu 12 çekirdekte yaklaşık 4 dakika; S6 (50 kişi) tek tohumda yaklaşık 2 saniye." % nrun)
w("- **Uygulama.** `fit`, `rate`, kadro, zaman sıralı hafta, planlama adım 1-7, kapanış, Poisson çekilişi, MVP bekleme listesi ve RNG sırası §6'daki gibi. Kod modelin kopyasıdır, motor kodu değildir.")
w()
w("**Yorumlar** (§6'nın tek anlamlı olmadığı yerlerde seçilen en makul okuma):")
YOR = [
    "PM'in hazırlık yapması için Yapım kutusunun açık olması gerekir (§6.3 hazırlığı 'PM ana alan' diye tanımlıyor, kutu söylemiyor). Bu, 'S3'te Selin'e Test kutusu' senaryosunun belge sonucuyla (hazırlık %70'e iner, teslim 55'ten 50'ye) uyumlu.",
    "Planlama 5(b) 'kopya > 0 iş alır': kopyanın o 2 haftalık oynatmada aldığı ilerleme artışı sayılır. Tasarımcının önden yaptığı tasarım ilerlemesi sayılmaz.",
    "Darboğaz: her kapanışta devreden kartların bekledikleri aşamadaki kalan işi aşama başına toplanır, pencere sprintleri üzerinden sprint başına ortalaması alınır, tohum medyanı en büyük olan aşama darboğazdır; hiçbiri 1 puanı geçmezse 'yok'.",
    "Düzeltme payı penceresi: 'erken' = MVP haftasında ya da sonra başlayıp MVP'den sonraki ilk 20 haftada başlayan sprintler; 'geç' = kapanışı 20. haftadan sonra olanlar. Hata sprinti: pay > 0,5. Üst üste denetimi MVP sonrası bütün sprintlerde.",
    "Dağılım listesi [6,4,8,5,3,6,7,4,5,6] 10 kişiden uzun rol grubunda başa sarar (S5'te 12, S6'da 25 geliştirici).",
    "Eşitlikte 'kimlik' = takım listesindeki sıra. Taban hata akışı hatlara `rng.choice` ile (canlı hatlar numara sırasıyla) dağılır.",
    "Kişi ekleme eğrisi: S6'nın oranı (6 PM, 8 tasarımcı, 25 geliştirici, 10 testçi) sabit karışımdır. Kurucudan sonra her yeni kişi hedef orandan en çok geri kalan rolden seçilir (eşitlikte geliştirici, testçi, tasarımcı, PM sırası). Her n bir öncekinin üstüne bir kişi ekler; eğri tek bir büyüyen ekibin tarihçesidir. 50. kişide S6 ile aynıdır.",
    "Marjinal getiri = ekip+1 ile ekibin tohum medyanlarının farkı. Eklenen kişiler: 3★ = ana puan 6, ikincil 5 (PM: tasarım 5, test 2); 1★ geliştirici = yazılım 2, test 1.",
    "K4 deneyleri: 'S8'e Test kutulu geliştirici' = ek 1 geliştirici (3★, Yapım+Test); ayrıca bütün 10 geliştiricinin Test kutusu işaretli hâli. 'S11'e testçi' ve 'S9a'ya geliştirici' = 1 kişi, 3★.",
    "K8 için S4'e hem 1 PM (dağılım başı, puan 6) hem 2 PM (belgenin S4'ü) eklendi. 'S5'te tek PM' = 3 PM yerine 1.",
    "K7 deneyi: S3'te Ayşe'nin test puanı 2/4/6/8/10 (yazılım = test-1); S4 benzeri ekipte (2 PM, 2 tasarımcı, 5 geliştirici) iki testçi de aynı puanda.",
    "Genel ölçütler için eklenenler (§6'da yok): rol karışımı karşılaştırması (12/25/50 kişide 10 karışım, kurucu hep var, oran en büyük kalan kuralıyla yuvarlanır), 12/25/50 kişide tüm testçilerin 1★ ya da 5★ olduğu deneyler, akış ölçüleri (sprintteki kart sayısı ve bekleme süresi).",
    "Tahmin = sonuç (§6.13): kopya önden tasarım ve hazırlık kuyruğuyla birlikte oynatılır; kapanışta kart başına aşama ilerlemesi, bitiş zamanı (kesirli hafta) ve E karşılaştırılır.",
]
for i, t in enumerate(YOR, 1):
    w("%d. %s" % (i, t))
w()

w("## 2. §6.9 elle doğrulama")
chk = json.load(open("check69.json", encoding="utf-8"))
table(["Örnek", "Beklenen (§6.9)", "Bulunan"], [(a, b, c_.replace("*", "★")) for a, b, c_ in chk])
w("S7 testçileri: T1 = 3★, T2 = 2,5★, T3 = 2★, T4 = 4★, T5 = 1,5★.")
w()
w("Hepsi tutuyor. Tek ince fark: 3. dizide 3 geliştiricide 1,95 çıktı (belge 1,96; yuvarlama).")
w()

w("## 3. Senaryo tabloları (§6.8, 21-60. hafta, 20 tohum medyanı)")
w("Teslim = biten özellik kartlarının büyüklükleri toplamı ÷ hafta. Boşta = kişi-hafta/hafta. Kaçan hata = biten özellik kartı başına E. 'Açık hata' her kapanıştan sonraki toplam açık hatanın medyanı; 'açık max' pencerede görülen en yüksek değerin tohum medyanı.")
w()
w("### 3.1 Hız ve boşta")
rows = []
for n in MAIN:
    a = A[n]
    rows.append((LBL[n], a["n"], "%s (%s)" % (f(a["deliv"]), rng(a)), f(a["pts"]), f(a["per_person"], 2), f(a["cards_sprint"]), f(a["idle_w"]), a["bott"], pc(a["ready"]), f(a["mvp"], 0)))
table(["Senaryo", "Kişi", "Teslim/hf (en az-en çok)", "Puan/hf", "Kişi başı", "Kart/sprint", "Boşta", "Darboğaz", "Hazır kart", "MVP hf"], rows)
w("### 3.2 Hata")
rows = []
for n in MAIN:
    a = A[n]
    rows.append((LBL[n], f(a["esc_card"], 2), f(a["open_med"]), f(a["open_max"], 0), pc(a["fix_early"]), pc(a["fix_late"]), hs(a, "early"), hs(a, "late"), a["consec"], f(a["slope"], 2), f(a["morale"], 0)))
table(["Senaryo", "Kaçan hata/kart", "Açık hata (med)", "Açık max", "Düzeltme payı erken", "geç", "Hata sprinti erken", "geç", "Üst üste (tohum)", "Eğim/hf", "Moral"], rows)
pmm = statistics.median(R["S3_PM_testkutulu"][s]["morale"][1] for s in SEEDS)
w("Moral = uymayan işte çalışanların 60 haftalık toplamı (-2/hafta). Yalnız 'S3 + PM'e Test kutusu'nda anlamlı: PM tek başına %d kaybediyor (belge: yaklaşık -76). Öbür senaryolarda testi geliştirici (ikincil, uymayan sayılmaz) ya da kurucu yaptığı için moral kaybı yok." % pmm)
w()

w("### 3.3 Belgenin ön hesabıyla fark")
rows = []
for n in ("S1", "S2", "S3", "S4", "S5", "S6"):
    a = A[n]; d = DOC42[n]
    rows.append((LBL[n], "%s / %s (%+.0f%%)" % (f(d[0]), f(a["deliv"]), (a["deliv"] / d[0] - 1) * 100),
                 "%s / %s" % (f(d[1], 2), f(a["esc_card"], 2)), "%s / %s" % (f(d[2]), f(a["open_med"]))))
table(["Ekip", "Teslim: belge / bu koşu", "Kart başı hata: belge / bu koşu", "Açık hata: belge / bu koşu"], rows)
rows = []
for n, d in DOC43.items():
    a = A[n]
    rows.append((LBL[n], "%s / %s (%+.0f%%)" % (f(d[0]), f(a["deliv"]), (a["deliv"] / d[0] - 1) * 100), "%s / %s" % (f(d[1]), f(a["idle_w"]))))
table(["Uç bileşim", "Teslim: belge / bu koşu", "Boşta: belge / bu koşu"], rows)
w("Hepsi belgenin ±%10 payı içinde. Küçük sayılı ölçülerde (S1 kart/sprint, kaçan hata) göreli fark büyük görünse de mutlak fark küçüktür.")
w()
