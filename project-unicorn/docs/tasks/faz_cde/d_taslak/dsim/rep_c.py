# ----------------------------------------------------------------------------------- rapor (3. yarı)
w("## 11. Kırılma ölçütleri")
w("### 11.1 Belgenin ölçütleri (§6.12)")
table(["#", "Ölçüt", "Durum", "Kanıt"], [(n, t, "**%s**" % d if d == "KIRIK" else d, e) for n, t, d, e in V])
w("### 11.2 Genel ölçütler")
gen = [
    ("G1", "Kişi eklemek çıktıyı düşürüyor mu", "EVET, tek yerde (48. kişi)",
     "Eğrinin 49 adımının 48'i ≥ 0; 48. kişi -3,0. Marjinal tabloda en düşük -1,0 (S4 + tasarımcı, tolerans sınırında). Ayrıntı 12. bölüm K1."),
    ("G2", "Bir rol karışımı baskın strateji mi", "HAYIR",
     "10 karışım × 3 büyüklük; hiçbiri ref'ten hem teslimde hem hatada iyi değil (6. bölüm). Hepsi testçi, testçisiz ve hepsi geliştirici karışımları tasarım ya da test aşamasında kurucuya takılıp 12 kişiden sonra büyümüyor."),
    ("G3", "Hata oranı ya da düzeltme payı ölçekle patlıyor mu", "HAYIR",
     "Kart başı kaçan hata n ≥ 6 için %.2f-%.2f arasında; düzeltme payı %s (3 kişi) → %s (50 kişi); en yüksek hata sprinti oranı ≥2 kişide %%%.1f. Açık hata ekiple doğrusal büyüyor (%s → %s, 50 kişide pencere maksimumunun medyanı %s). Detay 13. bölüm g4." % (
         min(A["C%d" % n]["esc_card"] for n in range(6, 51)), max(A["C%d" % n]["esc_card"] for n in range(6, 51)), pc(A["S2"]["fix_late"]), pc(A["S6"]["fix_late"]),
         max(worst_bl[0], worst_be[0]) * 100, f(A["S3"]["open_med"], 0), f(A["S6"]["open_med"], 0), f(A["S6"]["open_max"], 1))),
    ("G4", "Bir sayı 50 kişide anlamsız mı", "KISMEN (kırılma sayılmadı)",
     "Anlamsızlaşan sayı yok; iki sayı işlevini yitiriyor: düzeltme payı %3 (testçi yıldızı açık hatayı ve düzeltme payını değiştirmiyor, 7.1) ve MVP haftası 2 (yapay senaryo). Gözlem g3, g8."),
    ("G5", "Tek kurucunun MVP'si 6-7. haftadan kayıyor mu", "HAYIR", "20 tohumun hepsinde 6. hafta (K2)."),
]
table(["#", "Soru", "Sonuç", "Kanıt"], gen)

w("## 12. Kırılmalar")
c47, c48 = A["C47"], A["C48"]
pair = sum(1 for s in SEEDS if R["C48"][s]["deliv"] < R["C47"][s]["deliv"])
w("**K1 · 48. kişiyi eklemek teslimi düşürüyor** (belge ölçütü 1; genel ölçüt 'kişi eklemek çıktıyı düşürüyor mu')")
w("- Ne: kişi ekleme eğrisinde 47 → 48. kişi (eklenen: 2,5★ geliştirici, yazılım 5, test 4). Teslim %.1f → %.1f puan/hafta (%+.1f; tolerans -1). 20 tohumun %d'sinde 48. kişi, aynı tohumdaki 47. kişinin altında. Kayıp, teslimin %%%.1f oranı." % (
    c47["deliv"], c48["deliv"], c48["deliv"] - c47["deliv"], pair, abs(c48["deliv"] - c47["deliv"]) / c47["deliv"] * 100))
w("- Ölçülen sebep: sprintteki kart sayısı %.1f → %.1f, bir kartın sprinte girişinden bitişine geçen süre %.2f → %.2f hafta, sprint başına biten özellik kartı %.1f → %.1f, düzeltme kartı %.1f → %.1f. "
  "Ek deney (5 tohum): 48 kişilik ekibe 47 kişinin planlama kapasitesi (890,4) verilince teslim 469'a dönüyor; 47 kişilik ekibe 48 kişinin kapasitesi (910,4) verilince 467'ye iniyor. "
  "Yani atama kuralı değil, planlamanın kapasite tavanı: §6.3 kapasite her kişinin en iyi aşamasının hızını topluyor, yeni geliştirici darboğaz olmayan aşamaya kapasite katıyor, tavan (1,25 × kapasite) yükseliyor, sprint daha çok kart alıyor ve yarım kalan kartlar test kuyruğunda birikiyor." % (
      c47["wip"], c48["wip"], c47["lead"], c48["lead"], c47["cards_sprint"], c48["cards_sprint"], c47["fixes"], c48["fixes"]))
w("- Boyut ve yer: yalnız bu bileşimde; 48 dışında bütün eğri adımları ≥ 0. Marjinal tabloda benzer ama tolerans içinde bir hücre var (S4 + 3★ tasarımcı, -1,0). Belgenin kendi 'S6 + 1★ geliştirici -1' bulgusu bu koşuda çıkmadı (+1,0); aynı ailenin farklı bir örneği.")
w("- Çözüm yönü (denenmedi): tavanı darboğaz aşamasının kapasitesine ya da devreden kart sayısına bağlamak. Model değişikliği olduğu için onay gerektirir.")
w()
w("**K2 · Tek kurucuda A'nın hata sprinti hedefi tutmuyor** (belge ölçütü 5 tek kurucuyu bu hedefe bağlamıyor; A'nın E1 §9 hedefi 'her ekip' diyor, bu yüzden listede)")
w("- Ne: S1, geç pencerede %s sprint hata sprinti (%%%.1f; hedef ≤ %%5), erken pencerede %s (%%%.1f; hedef ≤ %%15, tutuyor). 20 tohumun %d'sinde üst üste iki hata sprinti var; %d tohumda geç oran tek başına %%5'i aşıyor." % (
    ratio(s1["bs_late"]), s1["bs_late"][0] / s1["bs_late"][1] * 100, ratio(s1["bs_early"]), s1["bs_early"][0] / s1["bs_early"][1] * 100, s1["consec"], s1_seed_bad))
w("- Sebep: tek kurucuda kapasite 20 puan ve düzeltme payı zaten %25. Bir hatta ≥ 5 hata birikince 10 puanlık, başka bir hatta ≥ 2 hata birikince 5 puanlık kart açılıyor: 15 puan = pay 0,75 (28 hata sprintinin 25'i) ya da iki 10 puanlık kart = pay 1,0 (3'ü). Eşik 0,5'i geçince sprint düzeltmeye gidiyor.")
w("- Belgenin §4.2 tablosu bunu '1 / 28' (5 tohum) diye yazıyordu; 20 tohumda oran %5'in biraz üstünde. Büyük bir sapma değil ama A'nın hedefi tek kurucu için yapısal olarak sıkı.")
w()

w("## 13. Kırılma sayılmayan gözlemler")
w("1. **g1 Merdiven eğrisi.** Teslim, tasarımcı eklenince sıçrıyor; geliştirici ve testçi adımları çoğunlukla küçük (4. bölüm). Bu bir ekip dengesi göstergesi, hata değil; ama oyuncuya 'şimdi hangi rol?' sorusunun cevabı yalnız darboğaz satırında. Tasarımcı sayısı 50 kişide hâlâ en değerli ek kişi (S6 + 3★ tasarımcı +17,5).")
w("2. **g2 Sprintteki kartların üçte biri yarım kalıyor.** Sağlıklı ekiplerde sprintteki kartların yaklaşık üçte biri devrediyor ve bir kart ortalama 3,5 hafta (iki sprint) sürüyor. Plan ekranının 'bu sprintte biten' ile 'bu sprintte çalışılan'ı ayırması gerekir (10. bölüm).")
w("3. **g3 Kalite kaldıracı açık hatada görünmüyor.** Bütün testçiler 1★'dan 5★'a çıkınca kart başı hata %32 iniyor, ama açık hata (6, 12, 25, 50 kişide sırasıyla 8→8, 9,5→9,2, 12→12,2, 16,2→16,0) ve düzeltme payı (%5→%4 … %3→%2) değişmiyor. İki sebep: iyi testçi ekibi hızlandırıp daha çok kart teslim ettiriyor (haftalık toplam kaçan hata aynı kalıyor); düzeltme kartı bir hattaki hata sayısından bağımsız 5-10 puan (A'nın kuralı). Kalite kararı kart ipucunda (%35 → %28) görünür, sonuç ekranında görünmez. Erdem'in '%2 çok düşük' itirazının görünür tarafı bu.")
w("4. **g4 Açık hata 50 kişide A'nın itibar eşiğine yaklaşıyor.** S6'da medyan 19, pencere maksimumunun medyanı 27,5; 400 kapanışın 6'sında ≥ 30, 48'inde ≥ 25 (en yüksek 33). Eşik 4 hafta üst üste 30 olduğu için bu koşularda tetiklenmedi, ama marj dar (S5'te en yüksek 26). Belge de aynı riski yazmıştı; ölçüm doğruluyor.")
w("5. **g5 Testçisiz bileşimde kart bekleme süresi 27,7 hafta.** S11 (testçisiz 25 kişi): sprintte 64 kart, sprint başına 2 kart bitiyor; kartlar test aşamasında bekliyor. Model çökmüyor, ama 'darboğaz cümlesi'nin yakalaması gereken durum bu: kartın bekleme süresi.")
w("6. **g6 Testçinin ek değeri küçük.** Geliştiricilere Test kutusu işaretleyip testçi almamak ref karışımdan %2 (12 kişi) ile %10 (25 kişi) geride kalıyor, kaçan hata aynı. Testçi, uzman olduğu için kaliteyi artırmaktan çok yapımdan boşalttığı zamanla değer katıyor; bu amaçlandıysa sorun yok, 'testçi şart' hissi için hatanın görünürlüğü gerekir (g3).")
w("7. **g7 Hazırlık oranı ölçekle düşüyor.** Hazır kart S3'te %100, S4'te %87, S5'te %69, S6'da %64: ekip oranı sabit tutulunca (S6'nın %12'si PM) PM'in hazırlık kapasitesi ekibin tükettiği kartın gerisinde kalıyor. Kırılma ölçütü yok; 'PM oranı' yine de 50 kişide hazırlığı tam yapmıyor.")
w("8. **g8 MVP haftası 2 (ekip ≥ 5).** Tam ekiple 0. haftadan başlayan yapay senaryo; ölçü olarak anlamsız (belge de uyarıyor). Oyunda MVP'den sonra büyüyen ekip için ayrı ölçüm gerekir.")
w()

w("## 14. Yeniden üretim")
w("Klasör: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dsim/`")
w("```")
w("python -I dsim.py exec collect.py     # 139 senaryo x 20 tohum -> results.pkl (yaklasik 4 dk, 12 cekirdek)")
w("python -I dsim.py exec collect2.py    # olcekte testci deneyi (TS12/25/50)")
w("python -I dsim.py exec check69.py     # 6.9 elle dogrulama")
w("python -I dsim.py exec x_rapor.py     # D_SIM.md uretimi")
w("python -I dsim.py quick S3 S6         # tek senaryo, tohum 1")
w("```")
w("Parametreler `dsim.py` başındaki sabitlerdedir (§6.2 ile birebir). Senaryo tanımları `SCEN` sözlüğünde.")

out = post("\n".join(L) + "\n")
open("C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/D_SIM.md", "w", encoding="utf-8", newline="\n").write(out)
print("yazildi", len(out), "karakter,", len(L), "satir")
print("KIR", KIR)
