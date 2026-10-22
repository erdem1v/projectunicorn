import io
p = "rapor_taslak.md"
s = open(p, encoding="utf-8").read()


def rep(old, new):
    global s
    assert s.count(old) == 1, ("bulunamadi ya da birden cok", old[:60], s.count(old))
    s = s.replace(old, new)


rep("Hata sprinti = düzeltme payı > %0,5 olan sprint / pencere sprinti (20 tohum toplamı).", "Hata sprinti = düzeltme payı > %50 olan sprint / pencere sprinti (20 tohum toplamı).")

rep("1 ve 3 kişide testçi eklemenin değeri 6 kişiden büyük: kurucu ve geliştirici kendi kartını test ediyor (×0,6), kaçan hata / 100 puan 3,89'dan 1,83'e (1 kişi) ve 3,00'den 1,85'e (3 kişi) iniyor.",
    "1 ve 3 kişide kurucu ve geliştirici kendi kartını test ediyor (×0,6); testçi eklemek teslimi de artırıyor (4,5 → 7,3 ve 19,6 → 26,9) ve kaçan hata / 100 puanı 3,89'dan 1,83'e (1 kişi), 3,00'den 1,85'e (3 kişi) indiriyor.")

rep("Tasarımcı adımları en değerli (ortalama +28,5), PM ve geliştirici adımları en küçük; 49 adımın 46'sı artı. 37. kişi (PM) −0,5: yeni PM kuyruğun ilerisindeki kartları daha düşük yıldızla hazırlıyor; en iyi PM kuralı bunu −2,5'ten −0,5'e indirmiş.",
    "Tasarımcı adımları en değerli (ortalama +28,5), PM (+3,7) ve geliştirici (+7,1) adımları en küçük; 49 adımın 46'sı artı. 37. kişi (PM) −0,5. Belge, en iyi PM kuralı olmadan bu adımın −2,5 olduğunu yazıyor; kural bu turda kapalı koşulmadı.")

rep("MVP hiçbir alımla gecikmedi; güçlü kuruculu ekipte 4'ten 2'ye iniyor.", "MVP hiçbir alımla gecikmedi; güçlü kuruculu ekipte üç alımdan sonra 4'ten 2'ye inen diziler var.")

rep("Dördü \"üç geliştirici\" dizisi (üçüncü geliştirici gelince teslim 11,7 → 7,5 ile 10,4 arası), biri \"testçi → geliştirici → tasarımcı\". \"Üç geliştirici\" dizisi zaten doygun: tasarım ve test kurucuda kalıyor, teslim 9,3 → 11,8 (+%27, üç kişiye).",
    "Dördü \"üç geliştirici\" dizisi (üçüncü geliştirici gelince 6 haftalık teslim %10 ile %36 düşüyor: 14,2 → 11,7, 11,7 → 7,5, 11,7 → 10,4), biri \"testçi → geliştirici → tasarımcı\". \"Üç geliştirici\" dizisi zaten doygun: tasarım ve test kurucuda kalıyor, teslim 9,3 → 11,8 (+%27, üç kişiye).")

rep("- 1★ PM bile PM'siz ekibi %7 ile %9 hızlandırıyor; 1★'dan 5★'a teslim +%11 ile +%23, kaçan hata −%20 ile −%43 (belge §4.6 ile aynı).",
    "- 1★ PM bile PM'siz ekibi 6 ve 11 kişide %7 ile %9 hızlandırıyor (23 kişide %3,8); 1★'dan 5★'a teslim +%11 ile +%23, kaçan hata −%20 ile −%43 (belge §4.6 ile aynı).")

rep("hep gönder kartı 0,1 ile 0,2 hafta erken çıkarıyor ve açık hatayı en çok %13,8 (S10), kaçan hatayı %15 ile %31 artırıyor.",
    "hep gönder kartı 0,1 ile 0,2 hafta erken çıkarıyor, açık hatayı en çok %13,8 (S10) ve kaçan hatayı %14 ile %33 artırıyor (S6 ve S10).")

rep("- S2'de (kapsam dışı) gönder teslimi 19,6'dan 19,1'e (−%2,5) düşürüyor: iki kişilik üretim ekibinde bırakılan kartın yeniden girişi tek kartlık işi etkiliyor.",
    "- S2'de (kapsam dışı) gönder teslimi 19,6'dan 19,1'e (−%2,5) düşürüyor; nedeni bu turda ayrıca ölçülmedi.")

rep("SD §4.1'in 32 · 16 · 11 · 9 · 7 değerleri v3 modelinde 1 ile 5 hafta geç (hazırlık, düzeltme ve kurucu tabanı yüzünden).",
    "SD §4.1'in 32 · 16 · 11 · 9 · 7 değerleri v3 modelinde 0 ile 5 hafta geç (tahmin: düzeltme alt aşaması ve kurucu tabanı).")

rep("- **Boşta nedenleri** kaynaklı arzda küçük ekipte \"rol uymuyor\" (3 kişi), 6 ile 25 kişide PM'in \"hazırlanacak kart yok\" payı, 50 kişide \"aşama dolu\".",
    "- **Boşta nedenleri** kaynaklı arzda: 3 kişide \"rol uymuyor\"; 6 ile 12 kişide PM'in \"hazırlanacak kart yok\" payı baskın; 25 kişide \"aşama dolu\" ile eşit; 50 kişide \"aşama dolu\".")

rep("Derinlik kartı bu büyüklükte neredeyse hiç devreye girmiyor çünkü 10 kişi 130 haftada az hattı K3'e taşıyor.",
    "Derinlik kartı bu ekip büyüklüğünde arzın küçük payı (%2 puan); kademe ve istek kartları ekibi doyuruyor.")

rep("Küçük ekipte istek akışı ekibi doyurmuyor, tersine 330 hesapta 6 kişilik ekip isteklerin yarıdan fazlasını yetiştiremiyor (101 istek düştü).",
    "330 hesapta 6 kişilik ekip 256 istek kartının yalnız 90'ını yapabiliyor, 101'i süre dolunca düşüyor: küçük ekipte istek akışı ekibi aşıyor, büyük ekipte yetmiyor.")

rep("- 17 kişilik takım ×0,81 ile ×0,95 çarpanla çalışıyor (lider 4, 6, 8);", "- 17 ve 16 kişilik takımlar ×0,81 ile ×0,95 çarpanla çalışıyor (lider 4, 6, 8);")

rep("- Mutlak 30 ile 50 kişilik ekip 5 haftada varıyordu (eşiğin 4 haftalık bekleme süresinden kısa); oranlı kuralla 15 hafta.", "- Mutlak 30 ile 50 kişilik ekip 5 haftada varıyordu; oranlı kuralla 15 hafta.")

rep("- *25 kişi:* sabit ekip 0. haftadan tam; hesap azken (21-35. hf, hat başına 1-2 derinlik kartı) açık aday 18,75'in altına iniyor; sprintlerin %20'si. 330 hesapta sorun yok (%100).",
    "- *Havuzun boşaltılması:* ekip her planda açık adayların hepsini alıyor; havuz ancak arz tüketimi aşarsa hedefin üstünde kalıyor. 25 kişide sabit ekip 0. haftadan tam: 21. haftada 57 hesapla hat başına 2 derinlik kartı var, havuz sprintlerin %20'sinde 18,75'in altında. 330 hesapta sorun yok (%100).")

rep("- Bölen 5 ve üst sınır 8 birlikte: 25 kişi %80 → %100 (teslim 217,3 → 245,6, boşta %14,6 → %7,6); 50 kişi 330 hesapta %0 → %100 (teslim 385,9 → 474,8, boşta %23,4 → %12,1); büyüme eğrisi aynı. Sabit 50 kişilik ekip 3 hesap/hf ile %0 → %65 (hâlâ < %90: 21-35. haftada hesap 57 ile 100 arası, hat başına 1 + 19÷5 = 4 kart, 36 < 37,5).",
    "- Bölen 5 ve üst sınır 8 birlikte: 25 kişi %80 → %100 (teslim 217,3 → 245,6, boşta %14,6 → %7,6); 50 kişi 330 hesapta %0 → %100 (teslim 385,9 → 474,8, boşta %23,4 → %12,1); büyüme eğrisi aynı (%100, teslim 66,6 → 66,8). Sabit 50 kişilik ekip 3 hesap/hf ile %0 → %65 (teslim 295,6 → 406,5) ama hâlâ < %90: ekip 0. haftadan tam ve hesap azken arz tüketimin gerisinde.")

rep("- Üst sınırsız ve bölen 5 sonucu (son satırlar tablo dışı not olarak §8.7'de değil, tabloda \"Üst sınır sınırsız\" sütunu üst sınırsız + bölen 10): 330 hesapta 50 kişi 482,9.",
    "- Üst sınırı tamamen kaldırmak (bölen 5, son sütun) 25 kişide aynı (%100, 245,4), sabit 50 kişide %65 (419,1), 330 hesapta 50 kişide %100 (465,8); 330 hesapta 25 kişide teslim 228,1 → 217,1'e düşüyor (derinlik kartları isteklerin yerini alıyor). Bu yüzden öneri üst sınır 8.")

rep("Sonuç: küçük ekipte planın %3-23'ü boş. Bot öneriyle aynı kodu kullanıyor (bot = öneri koşulu yapısal olarak tutuyor).",
    "Sonuç: S2'de planın %13 ile %23'ü, S3'te %11'i, S4'te %5 ile %6'sı boş; S5 ve S6'da %2'nin altında. Bot öneriyle aynı kodu kullanıyor (bot = öneri koşulu yapısal olarak tutuyor).")

rep("Doluluk 12 kişiye kadar ve 6 kişide ≥ %99,5'e çıkıyor (S2 1 hf %96,8);", "Doluluk %96,8 ile %100'e çıkıyor (en düşük S2, 1 hf);")

rep("küçük ekipte planın %3-23'ü boş (§8.4).", "S2 ile S4'te planın %5 ile %23'ü boş (§8.4).")

rep("11. **Ek gözlem (belgede yok):** 1 haftalık sprintte tek kurucu dışında 3 ve 6 kişi de gönder/bırak politikalarından bağımsız; 130 haftalık büyüme eğrisinde arzın %89'u istek kartı (derinlik %2): derinlik kartı ancak 25 kişiden sonra devreye giriyor.",
    "11. **Ek gözlem (belgede yok):** 130 haftalık büyüme eğrisinde teslim puanının %89'u istek kartı, %2'si derinlik kartı; derinlik kartı ancak 25 kişiden sonra devreye giriyor (sabit ekip koşularında 330 hesapla bile S3'te %75, S4'te %84 istek payı).")

rep("- **Süre.** 4 işçi, toplam yaklaşık 45 dakika; en ağır koşu 130 haftalık 50 kişilik EA (tohum başına 5-8 saniye).", "- **Süre.** 4 işçi; ana koşular yaklaşık 27 dakika, öneri kolları yaklaşık 25 dakika; en ağır koşu 130 haftalık 50 kişilik EA (tohum başına 5-8 saniye).")

rep("Tek PM'de ve PM'ler yıldız sırasıyla çalıştığında fark yok.", "PM'ler hazırlık hızına göre sıralı çalıştığı için en iyi PM her zaman ilk iş alır; fark ancak en iyi PM'in o hafta boşta olmadığı durumda doğar.")

rep("Takıma 8. kişiden sonra kişi eklemek teslimi 2,9 puana kadar düşürebiliyor.", "Takım büyüklüğü 8'i aşınca kişi eklemek teslimi 2,9 puana kadar düşürebiliyor.")

open(p, "w", encoding="utf-8").write(s)
print("tamam")
