# Y · Oyun hangi yılda bitsin: 2030 sonu mu, 2035 sonu mu (Erdem soru 3)

Tarih: 2026-10-20 (oturum gece yarısını geçti; bazı çağrılar 2026-10-21'e düşmüş olabilir, sicilde erişim "2026-10-20/21"). Oyun koduna ve repo dosyalarına dokunulmadı.
Süre betiği: `tur2/y_sure_hesabi.py` (python -I ile koşar, bu belgedeki bütün süre sayıları ondan).
Etiketler: [BOŞLUK] kanıtsız yük taşıyan iddia ya da bulunamayan, [SIÇRAMA] kanıttan çıkmayan sonuç, [GÖRÜŞ] benim yargım, (varsayım) kaynaksız kabul.
`[S#]` bu belgenin sonundaki sicildir; `[A1-S#]`, `[B2-S#]`, `[V #n]` önceki turların belgelerinden devralınan kaynak ya da doğrulamadır.
Arama: 8 WebSearch (bütçe doldu). Ek olarak serbest WebFetch. Gartner, Oracle ve Microsoft'un bazı sayfaları 403/404 verdi; ne okunduğu en sonda.

---

## ÖZET (bulgular ve oyuna dersler)

**Süre (düzeltme dahil)**
1. 2012-01-01 bir Pazar. 2030 sonuna (31 Ara 2030) **991 hafta**, 2035 sonuna **1.252 hafta** var. SENTEZ §15 Soru 3 ve §9.3'teki "2030 ~940 hafta" YANLIŞ ETİKETLİ: 939 hafta, 2030'un 1 Ocak'ına kadar olan 18 yıldır. 2030 SONU 991 hafta; 1×'te 6,2 saat (5,9 değil). SENTEZ'in "YZ yarışı 7 yıl" da 2030 başına göredir; 2023'ten 2030 sonuna 8 yıl.
2. 1×'te (hafta 22,5 sn, duraklamasız): 2030 sonu 6,2 sa, 2035 sonu 7,8 sa. Hafta 40 sn ise 11,0 sa ve 13,9 sa; 50 sn ise 13,8 sa ve 17,4 sa. 3×'te 2,1 sa / 2,6 sa (40 sn: 3,7 / 4,6; 50 sn: 4,6 / 5,8).
3. 2035'in farkı yalnız **261 hafta**: 1×'te +1,6 sa, 40 sn'de +2,9 sa, 50 sn'de +3,6 sa, 3×'te +0,5 ile +1,2 sa. Süre artışı %26.
4. Demo (104 hafta, 28 Ara 2013'te biter): 2030 sonunda oyunun %10,5'i, 2035 sonunda %8,3'ü.
5. Game Dev Tycoon 35 yıl, oyuncu beyanına göre ~5 saat [B2-S3] ve Steam'de %94 olumlu, 22.236 yorum [S24]. Unicorn 1×'te yıl başına 19,5 dk, GDT yıl başına 8,6 dk: Unicorn yılı 2,3 kat yavaş; 3×'te 6,5 dk, yani GDT'den biraz hızlı. OpenTTD 100 yıl ~24 saat [S25].

**Gerçek ve ilan edilmiş takvim (2027-2035)**
6. 2030 sonu penceresi (2027-2030) sağlam çıpalı: AI Act Ek III yüksek risk 2 Ara 2027, Ek I 2 Ağu 2028 [S2]; Siber Dayanıklılık Yasası tam uygulama 11 Ara 2027 [S3]; ViDA dijital raporlama 1 Tem 2030 [S1]; SAP ECC ana bakım sonu 2027, uzatılmış 2030 [S11][S12]; Dynamics GP 31 Ara 2029 [V #11]. 11 ilan edilmiş satır, 0 saf kurgu.
7. 2031-2035 çok seyrek çıpalı: ViDA ulusal sistemlerin AB modeline hizası 1 Oca 2035 [S1]; SAP'nin RISE'a bağlı özel uzatması ~2033 [S11]; Oracle EBS 12.2 ve JD Edwards "en az 2036" taahhüdü, her yıl bir yıl uzuyor [S13][S14]. Bunlar satıcı takvimi; mevzuat olarak yalnız ViDA 2035. Türkiye için 2028 sonrası adım **bulunamadı** [BOŞLUK].
8. Bu yüzden ek beş yılın dönem maddelerinin yarısı kurgu olur (6 ilan edilmiş madde, 6 kurgu/varsayım madde); kurgu+öngörü oranı 2027-2030'da %21 (3/14), 2031-2035 ekinde %50 (6/12), 2027-2035 toplamında %35 (9/26). Sayma yöntemi §5.4'te [GÖRÜŞ].

**Öngörüler ve başarısızlar**
9. Kredibil öngörü ufku 2028'de bitiyor: Gartner 2028'e kadar kurumsal yazılımın %33'ü ajan YZ içerecek, günlük iş kararlarının %15'i özerk olacak [S17]; aynı rapor ajan projelerinin %40'tan fazlasının 2027 sonuna kadar iptal edileceğini söylüyor [S17]. 2030/2035'e kadar ERP için analist öngörüsü **bulunamadı**; bulunan tek "2030'da harcamanın %45-60'ı yerinden olur" iddiası kaynaksız bir blog [S22, reddedildi]. 2031-2035 içeriği kurgudur ve "öngörü" diye etiketlenemez.
10. "ERP ölüyor" tahminleri tutmadı: Gartner Ocak 2014'te "2016'ya kadar özelleştirilmiş ERP 'legacy' sayılır, 5 yılda melez norm olur" dedi [S19]; sekiz yıl sonra SAP ECC bakımı 2025'ten 2027'ye ertelendi [S11], 35.000 ECC müşterisinin %39'u 2024 sonunda geçmişti [V #3], SAP Cloud ERP Suite geliri 2024'te +%33 [V #4]. Yani ERP ölmedi, yer değiştirdi ve yavaş; ERP'nin sistem yaşı ortalama 11,3 yıl [S20].
11. Kurguyu geleceğe uzatan oyunlarda tepki kaynakları zayıf: Game Dev Tycoon'un "2042" yılı doğrulanamadı (kaynaklar 35 yıl varsayılan, 42 yıl seçenek diyor [B2-S1][B2-S4], "42" süredir, bitiş yılı değil [SIÇRAMA]). OpenTTD 2050'de yeni teknolojiyi keser ama oyun sürer [S25]. Gelecek kurgusuna oyuncu talebi/şikâyeti bulunamadı [BOŞLUK].

**Oyuna ders (özet)**
- 2035 sonu, oyuncunun hiç görmeyeceği bir kısmı değil; **ek 1,6-3,6 saat** ve ek ~%26 süre demektir. Bu süre, oyunun en az çıpalı ve en çok kurgulanmak zorunda olan dilimidir.
- 2030 sonu, bütün YZ-dönemi mevzuat başlıklarını (AI Act, CRA, ViDA DRR, ECC bitişi) içerir; 2035 sonu bunların **oturduğunu** gösterir ama yeni mevzuat çıpası eklemez (yalnız ViDA 2035).
- İçerik bedeli: 2035 için modül başına +2 kademe; 5 modülde +60, 7 modülde +84, 10 modülde +120 dizge (TR+EN) ve ~4 kurgu dönem satırı (+16 dizge) [formül §6].
- YZ penceresi 8 yıl (2030) ya da 13 yıl (2035); "öncü olma" penceresi ikisinde de aynı ~2023-2027/28 (4-5 yıl), fark öncü sonrası doygunluk süresidir (3 yıl mı, 8 yıl mı) [§7].
- Karar sıklığı: bitiş yılı oyun başına bir kez seçilir (Game Dev Tycoon gibi, kayıtta kilitli) ya da sabittir; bu belge ikisini de destekler, seçim Erdem'de.
- Erdem'e açılacak soru için bu belgede yeterli veri var; ajanın görüşü §8'de, soru §8.3'te.

---

## 1. Süre hesabı

Yöntem: `tur2/y_sure_hesabi.py`. 2012-01-01 Pazar [betik çıktısı]. Tik = hafta = günler/7. CLAUDE.md'ye göre bir oyun yılı 52 tik (SENTEZ §9.3'ün de yaptığı gibi); gerçek takvim yılı 52,14-52,29 hafta, fark ±4 hafta, saat farkı ≤0,03 sa. Duraklama, olay kartı okuma, menü süresi dahil DEĞİL (alt sınır).

### 1.1 Hafta (tik) sayısı

| Bitiş | Gün | Takvim hafta | 52 tik/yıl kuralı | Not |
|---|---|---|---|---|
| 2025 sonu | 5.114 | 730,6 | 728 | SENTEZ'in "730" hesabı doğru |
| 2030 başı (31 Ara 2029) | 6.575 | **939,3** | 936 | SENTEZ'in "2030 ~940" bu: 18 yıl |
| **2030 sonu** | 6.940 | **991,4** | 988 | 19 yıl |
| **2035 sonu** | 8.766 | **1.252,3** | 1.248 | 24 yıl |
| Fark (2031-2035) | 1.826 | **260,9** | 260 | 5 yıl |

### 1.2 Toplam saat (duraklamasız, takvim hafta)

| Hız / hafta süresi | 2025 sonu | **2030 sonu** | **2035 sonu** | Fark (5 yıl) |
|---|---|---|---|---|
| 1× (22,5 sn) | 4,6 | **6,2** | **7,8** | +1,6 |
| 2× (11,25 sn) | 2,3 | 3,1 | 3,9 | +0,8 |
| 3× (7,5 sn) | 1,5 | 2,1 | 2,6 | +0,5 |
| Hafta 40 sn, 1× | 8,1 | **11,0** | **13,9** | +2,9 |
| Hafta 50 sn, 1× | 10,1 | **13,8** | **17,4** | +3,6 |
| Hafta 40 sn, 3× (13,3 sn) | 2,7 | 3,7 | 4,6 | +1,0 |
| Hafta 50 sn, 3× (16,7 sn) | 3,4 | 4,6 | 5,8 | +1,2 |

Dilimler (1×, 22,5 sn): 2012-2026 (783 hafta, bugüne dek gerçek) 4,9 sa; 2027-2030 (209 hafta) 1,3 sa, 40 sn'de 2,3 sa; 2031-2035 (261 hafta) 1,6 sa, 40 sn'de 2,9 sa, 50 sn'de 3,6 sa.

### 1.3 Yıl başına hafta

Artık yıllar (2012, 2016, 2020, 2024, 2028, 2032) 52,29 hafta, diğerleri 52,14 hafta. Oyun yılı 52 tik sayıldığı için yıl sınırları takvimden yıl başına ~0,14-0,29 hafta kayar; 19 yılda birikimi ~4 hafta, dönem satırlarının tik'e düşmesini ±1 ay oynatmaz (önemsiz).

### 1.4 Demo payı

Demo 104 hafta, 28 Aralık 2013'te biter. Oyunun payı: 2030 sonunda **%10,5**, 2035 sonunda **%8,3**. Demo oyuncusu gövdeye dokunmaz (2012-2013, K1-K3 civarı): bitiş yılı demoda görünmez, yalnız mağaza sayfası "19 yıl" mı "24 yıl" mı diyecek.

### 1.5 Game Dev Tycoon kıyası

- GDT 35 yıl ≈ 5 saat (oyuncu beyanı, 2013) [B2-S3] → yıl başına 8,6 dk, tik başına ~9,9 sn (35×52=1.820 tik). Oyuncular o zaman "daha yavaşsa sıkıcı olurdu" ile "çok hızlı, düşünmeden tıklıyorum" diye bölünmüş [B2-S3]. Steam'de bugün %94 olumlu, 22.236 yorum [S24]: kısa tempolu bir tarih oyunu sevilebilir.
- Unicorn 1×: yıl başına 19,5 dk → **2,3 kat daha yavaş yıl**; 3×: 6,5 dk (GDT'den %24 hızlı). 40 sn / 1×: 34,7 dk/yıl (4,0 kat). Ölçü oyuncu beyanıdır; kıyas kaba. Unicorn yılında ekip 1-50 kişi, yüzlerce hesap var: yılın karar yoğunluğu daha yüksek [GÖRÜŞ].
- OpenTTD: 100 yıl (1950-2050) tam seyir ~24 saat [S25]; 100 yıllık oyunun bile oynandığını gösterir, ama GDT'nin "düşünmeden tıklama" şikâyetinin (geç oyun) OpenTTD'de bulunmaması geç oyunun içeriği/karar değişkenliğiyle ilgili olabilir [BOŞLUK; kaynak yok].

**Oyuna ders:** Süre kararı bir "saat" kararı değil, bir "hafta başına süre" kararıyla birlikte verilir: 2035 sonu 1×'te 7,8 saattir ama Erdem hafta süresini 50 sn'ye çekerse 17,4 saate çıkar; aynı kalibrasyon 2030 sonunu 13,8 saate çıkarır. Yani bitiş yılı seçimi ile hafta süresi seçimi birlikte oyuncunun kaç saat oynayacağını belirler; ayrı sorulmamalı. Demoda hiçbir fark yoktur.

---

## 2. Gerçek ve önceden ilan edilmiş olaylar, 2027-2035 (ERP ve yazılım pazarı)

Güven: Yüksek = resmî AB/üretici sayfası okundu; Orta = ikincil/üçüncü aktarım; Düşük = satıcı blogu ya da arama özeti. Bugün 2026-10-20: 2026'ya kadar olanlar yürürlükte, 2027'den itibaren "ilan edilmiş" ya da "öngörü".

### 2.1 Tablo

| Tarih | Olay | ERP'ye yansıma (modül/kademe) | Kaynak | Güven |
|---|---|---|---|---|
| 11 Ara 2027 | Siber Dayanıklılık Yasası tam uygulama (bildirim yükümlülüğü 11 Eyl 2026'dan) | Güvenlik ve Yetki: açık zafiyet/olay bildirimi, ürün güvenliği kademesi | [S3] AB Komisyonu | Yüksek |
| 2 Ara 2027 | AI Act Ek III yüksek risk yükümlülükleri ("AI Omnibus" ile ertelendi, 27 Tem 2026'da yürürlüğe girdi) | İK (işe alım, performans YZ), kredi/ödeme; YZ hattında uyum kademesi | [S2] AB Komisyonu | Yüksek (sayfa özgün tarihleri vermiyor) |
| 2 Ağu 2028 | AI Act Ek I (düzenlenmiş ürünlere gömülü YZ) | Üretim/Stok ürünleri | [S2] | Yüksek |
| 1 Oca 2027 | OSS/IOSS küçük açıklamalar (ViDA) | Fatura (vergi) küçük | [S1] | Yüksek |
| 1 Tem 2028 | ViDA: tek KDV kaydı reformu, platform kuralları (üye devlet 1 Oca 2030'a erteleyebilir) | Fatura/Vergi: tek kayıt | [S1] | Yüksek |
| **1 Tem 2030** | ViDA: sınır ötesi B2B dijital raporlama (DRR), e-faturaya dayalı | Fatura: e-fatura + gerçek zamanlı raporlama kademesi; Entegrasyonlar | [S1] | Yüksek |
| **1 Oca 2035** | ViDA: ulusal gerçek zamanlı raporlama sistemleri AB modeline hizalanmak zorunda | Fatura: yerel yazılımların hizası; tek mevzuat dalgasının "son teslim" günü | [S1] | Yüksek |
| FY2024 raporu 2025; dalga 2-3 ertelendi (stop-the-clock, siyasi anlaşma 14 Nis 2025; Omnibus I anlaşma 9 Ara 2025); ESRS sadeleştirme 3 Tem 2026 | CSRD sürdürülebilirlik raporlaması | Finans/Raporlama: sürdürülebilirlik raporu kademesi; eşikler ve nihai metin DOĞRULANMADI | [S5] | Yüksek (tarihler), nihai eşik [BOŞLUK] |
| 2028 (ertelenen dalga) | CSRD dalga 2-3 iki yıl ertelendi, "2028'e" | Aynı | [S27] | Orta (Wikipedia, teklif cümlesi) |
| 17 Oca 2025 | DORA uygulama başladı | Güvenlik, üçüncü taraf yönetimi; yalnız finans müşterileri | [S8] ESMA | Yüksek |
| 18 Eki 2024 | NIS2 yürürlükte (aktarım son tarihi 17 Eki 2024) | Güvenlik ve Yetki kademesi | [S6] | Yüksek |
| 2025: bilanço esası mükellef e-Defter; 1 Oca 2026: e-Fatura parasal sınır genel kural olarak kalktı, e-Defter ≥3 milyon TL (2022 hasılatı) için zorunlu; 1 Tem 2026: e-İrsaliye ≥10 milyon TL (2025 hasılatı); 1 Oca 2027: e-Arşiv tam zorunluluk (3.000 TL'ye kadar kâğıt istisnası 31 Ara 2026'da biter) | Türkiye e-Dönüşüm genişlemesi | Fatura, Stok/Sevkiyat (e-İrsaliye), Finans (e-Defter) | [S15] Sovos blogu (5 Mayıs 2026) | Düşük-Orta (satıcı blogu; Tebliğ no yok; kaynaklar kendi arasında 2025/2026 e-Defter için çelişiyor) |
| 2028-2030 | Türkiye için yeni e-Dönüşüm adımı | - | bulunamadı | [BOŞLUK] |
| Aralık 2027 / 2030 / 2033 | SAP ECC 6.0: ana bakım sonu, uzatılmış bakım (+%2 prim), RISE'a bağlı özel uzatma 2033'e [V2 uyarı, KISMEN: The Register'da 2033'ü SAP değil bir danışman söylüyor ("özel koşullarda", NDA olasılığı); ilan edilmiş sayılmaz]; "2031-2033 arasında S/4HANA'ya geçiş" seçeneği | Eski çekirdek bitişi: büyük hesapların yeniden ihalesi | [S11] The Register 2025-06-20; [S12] d-velop blogu; [S7] Wikipedia | Orta; SAP'nin kendi sayfası 403 verdi |
| 2040 | ECC/S/4HANA için üçüncü taraf destek (Rimini Street) | - | [S11][S12] | Düşük (satıcı iddiası, SAP tarihi DEĞİL) |
| ≥2033 / ≥2036 | JD Edwards "en az 2033" [S9, eski]; Oracle EBS 12.2 ve JDE EnterpriseOne Premier Support "en az 2036", yıllık gözden geçirilir ve uzatılır | Eski çekirdek yaşı: Oracle tarafında bitiş yılı kayıyor | [S13] Oracle yol haritasının arama özeti (PDF 403), [S14] DSP, [S9] | Orta-Düşük |
| 11 Tem 2028 | Dynamics SL genişletilmiş (güvenlik) destek sonu | Eski çekirdek | [V #11] | Orta-Yüksek |
| 31 Ara 2029; 30 Nis 2031 | Dynamics GP geliştirme/teknik destek; güvenlik yamaları | Eski çekirdek | [V #11] | Orta-Yüksek (arama özeti) |
| 1 Kas 2016 - süresiz | Business Central "Modern Lifecycle", sürekli güncelleme, emeklilik tarihi yok | Satıcı ritmi: yılda iki dalga; "bitiş" yok, güncelleme zorunluluğu var | [S4] Microsoft Learn | Yüksek (retirement tarihi "In Support") |

### 2.2 Çıkarım

- **2027-2030 dörtlüsü** AB tarafında çok yoğun: CRA (Ara 2027), AI Act ertelenmiş tarihleri (Ara 2027/Ağu 2028), ViDA (Tem 2028/Tem 2030), CSRD ertelemesi (2028), SAP ECC bitişi (2027/2030). 2030 sonu bu dört yılı tam kapsar; ViDA'nın başlık maddesi (DRR) ise **1 Tem 2030'da**, yani oyun bitmeden yalnız 6 ay önce; oyuncu mevzuatın "oturmasını" görmez (güncel kullanıcı olarak yalnız duyuruyu ve ilk yılın başında ilk yenileme tartışmasını yaşar) [GÖRÜŞ].
- **2031-2035** gerçek çıpa: ViDA 2035 hizası (mevzuat), SAP 2031-2033 geçiş seçeneği ve özel uzatma (satıcı), Oracle ≥2036 ve GP 2031 (satıcı). Kendi eski çekirdek bitişi olmayan Microsoft Business Central "bitmeyen" model olduğu için oyuncu için "Business Central kademesi" bir tarih değil sürekli güncelleme. Kısacası ek beş yılda **tek mevzuat çıpası** var.
- Oracle'ın Premier Support taahhüdü her yıl bir yıl uzuyor [S14]: 2033 → 2034 → 2036 tarihleri aynı belgenin sürümleri [S13 arama sonucu: "ebs 122 premier support extended through at least 2033/2034/2036"]. Bu, "bitiş tarihi" gerçek bir yazılım olgusudur ve oyunda da bitiş tarihinin **kayabilmesi** için gerçeğe uygun bir tohumdur (SAP 2025 → 2027 → 2030 → 2033 aynı örüntü) [S11].
- Türkiye tarafı: 2027'ye kadar belli, 2028 sonrası **hiçbir kaynakta yok**. Oyunun ülkesi parodi bir dünya ise (SENTEZ §9.1 kararı) "e-Belge" genel adı kalır; 2028+ satırları kurgu olur.

**Oyuna ders:** Soru: 2030 mu 2035 mi. Etki: 2027 sonrası dönem maddelerinin 2030 sonunda %79'u (11/14), 2035 sonunda %65'i (17/26) ilan edilmiş çıpalıdır (öngörü dahil %86 ve %69) [§5.4]. Oyuncunun karar sıklığı: "mevzuata yetişeyim mi" kararı mevzuat maddesi başına bir; 2027-2030 arasında 7 mevzuat maddesi (CRA, AI Act Ek III ve Ek I, e-Arşiv, ViDA tek kayıt ve DRR, CSRD) var, 2031-2035 ekinde 1 gerçek (ViDA 2035) ve 1 kurgu. Yani ek beş yıl oyuncuya **yeni mevzuat kararı vermez**, yalnız eski çekirdek bitişlerinde "yeniden ihale fırsatı" (devin hesabını kapma) verir.

---

## 3. 2031-2035 için kredibil öngörüler ve başarısızlar

### 3.1 Bulunanlar

- **Gartner (Ekim 2024 / Haziran 2025):** 2028'e kadar kurumsal yazılım uygulamalarının %33'ü ajan YZ içerecek (2024'te <%1) ve günlük iş kararlarının %15'i özerk alınacak (2024'te %0) [S17]. Aynı raporda: ajan YZ projelerinin %40'tan fazlası 2027 sonuna kadar iptal edilecek (maliyet, belirsiz değer, güvenlik); binlerce "ajan" satıcısının yalnız ~130'u gerçekten üretiyor ("agent washing") [S17]. 3.412 web semineri katılımcısı anketi: %19 önemli yatırım, %42 temkinli, %8 hiç, %31 bekle-gör [S17] (Düşük-Orta: seçilim yanlılığı olası).
- **ERP yenileme döngüsü:** Avrupa kullanıcı çalışması Trovarit 2020: kullanımdaki ERP'nin ortalama yaşı 11,3 yıl (2018: 11,7) [S20]; "7-10 yıl" satıcı çerçevesi ve eleştirmenler satış taktiği diyor, imalatçıda "çoğu 15. yılda geçti" bir uygulayıcının anekdotu [S20 derlemesi]. Panorama 2026'da ortanca proje 9 ay, %25+ bütçe aşımı [V #7: AÇILAMADI]; Birmingham Belediyesi Oracle Fusion 19 milyon → 144,4 milyon pound [A1].
- **2030 öngörüsü (A1 §0, §8):** SAP "her kullanıcı %30 daha verimli" hedefi; IDC "2027'ye kadar ajan iş akışları" [A1, Düşük, satıcı beyanı].
- **MIT Technology Review (20 Ocak 2026):** "bileşenlenebilir mimari" ve ajanların eski sistemleri koordine etmesi [S23, yalnız arama özeti; sayfa açılmadı; Orta-Düşük]. Rimini Street 2026 öngörüleri: "monolitik ERP, ajanlarla yönetilen dağıtık hizmetler ağına dönüşür" (satıcı) [S23].

### 3.2 Bulunamayanlar

- Forrester, IDC ve McKinsey'den **2030/2035'e uzanan ERP, otonom finans kapanışı ya da düşük kod** öngörüsü bulunamadı [BOŞLUK]. Arama 8 sorguyla sınırlandı; bu üç firmanın ham raporları ücretli/403.
- 2031-2035 için "kredibil öngörü" kategorisinde somut bir yıllı sayı yok; **2028 öngörü ufkunun sonu**. Bu belgedeki 2031-2035 içeriği, kaynaklı öngörü değil kurgudur ve tabloda öyle etiketlenmiştir.

### 3.3 Başarısız ya da abartılı çıkan öngörüler (ayrı arama, #5)

| Öngörü | Ne söylendi | Ne oldu | Kaynak |
|---|---|---|---|
| "Postmodern ERP" (Gartner, 29 Oca 2014) | 2016'ya kadar özelleştirilmiş ERP "legacy" sayılacak, melez ortam 5 yılda norm olacak | ECC bakımı 2025 → 2027 → 2030 → özel 2033; 2024 sonunda ECC müşterilerinin %39'u geçmişti; yani eski çekirdeklerin süresi tahminden çok uzun [S19][S11][V #3] | [S19] (yalnız arama özeti; sayfa 403) |
| Gartner'ın kendi itirafı, *Predicts 2014*: "sosyal teknolojilerin uygulamalara girişi çok daha hızlı olacağını sandık" | Zamanlama hatası | bu bir ERP tahmini değil [SIÇRAMA uyarısı] | [S19] arama özeti |
| "Megasuit öldü" (Gartner 2015, Denise Ganly) | ERP'nin bütünleşik paketi biter | SAP Cloud ERP Suite geliri 2024'te 14,17 milyar € ve +%33 [A1-S5, V #4]: ERP paketi büyüdü, buluta taşındı | [S19] arama özeti; [V #4] |
| Bulut ERP hızı | Panorama 2015: SaaS payı %4 → %33 | [V #21]: açılamadı | [A1-S34] |
| Ajan YZ projeleri | %40+ iptal (2027'ye kadar) | henüz sonuç yok (ileri tarih) | [S17] |

**Oyuna ders:** Soru: 2031-2035 içeriği nasıl yazılır? Bulgu: ERP öngörüleri sistematik biçimde **hızı abarttı**, yön doğru çıktı. Oyuncu kararı: "yeni teknolojiye erken mi gireyim" (dönem başına 1 kez). Etki: 2031-2035 kurgusunda yeni teknoloji "1-2 yılda herkese yayılır" değil "8-12 yılda yayılır" olmalı (eski çekirdekler 2033'ten sonra da yaşar); yoksa oyuncu "devi geçmek" için 2031'de bir pencere görür ama dev yerine 2035'te hâlâ eski çekirdekle yaşıyor. Kolaylık: bu bir veri (yayılma hızı) kararıdır, kod değil.

### 3.4 Eski çekirdek yaşı ve oyun süresi

Ortalama ERP yaşı ~11 yıl [S20]: 2012-2030 (19 yıl) oyunda bir rakip/müşteri çekirdeğinin ortalama **1,7 kez** el değiştirmesi, 2035 sonunda (24 yıl) **2,1 kez** (24/11,3) demek [hesap, varsayım]. Yani 2035'te bir müşterinin üçüncü ERP'si ilk kez oyunda görünür; 2030 sonunda görünmez. Bu "yenileme şartı" mekaniğinin (Erdem K1: yenileme şartı) oyunda 2 turdan 3 tura çıkması anlamına gelir [GÖRÜŞ].

---

## 4. Oyunlarda geleceğe uzanan yıllar ve uzun oyunun geç oyun boşluğu

B2 belgesinde ayrıntılı (`B2_donem_kilit.md`); buradaki yeni bulgu ve özet:

- **Game Dev Tycoon:** 35 yıl varsayılan, 42 yıl seçenek; süre dolunca puan hesaplanır, platform çıkışı durur, oynamaya devam edilir [B2-S1]; yapımcı kodda 301. yılda platformların kaybolabileceğini yazdı [B2-S5]; oyuncular 33. yılda bırakmış, "7'nin üstünde oyun yapamıyordum" [B2-S5]. Mağaza: 80'lerde başlar; %94 olumlu / 22.236 yorum [S24]. Brief'teki "1980-2042 (sonrası kurgu)": 2042 yılı bu kaynaklarda **yok**; "42" süre seçeneği [SIÇRAMA uyarısı]. Kurgu-sonrası oyuncu tepkisi bulunamadı [BOŞLUK].
- **Mad Games Tycoon 2:** 1976 başlangıç, yüzyıl+; konsollar gerçek tarihin parodisi ("gerçek olanlara çok yakın ama dava edilmeyecek kadar farklı") ve oyuncular kendi uydurma konsolunun gerçek satış geçmişine karşı yarıştığını, pazarın rekabetçi modellenmediğini söylüyor [S26, arama özeti, Düşük]. Mağazada "Very Positive, 7.370 yorum" [S26]. **Gelecek yıllar için talep/şikâyet bulunamadı** [BOŞLUK]. Parodi adlar ders: kurgu, gerçekle yan yana çalışabilir (SENTEZ §9.1: parodi dünya).
- **Software Inc.:** bitiş yılı bulunamadı [B2 BOŞLUK]; endgame oyuncu raporunda ~16. saat, tam oyun ~45 saat [B2-S14, Düşük, LLM özet]. Bu arama turunda yeni veri **bulunamadı**.
- **OpenTTD:** 1950-2050, tam seyir ~24 saat, 2050 sonrası yeni teknoloji yok, oyun sürer [S25]. Kurgu-gelecek değil: 2050 gelecek ama oyunun varsayılan "bitişi", yeni içeriğin kesildiği çizgi.
- **Civilization VII/VI:** VII'de ağaç ~1960'larda bitiyor, çağ geçişi eleştirildi, Steam %51 [B2-S27][B2-S29]; VI'da ağaç bitince "Future Tech" tekrarı angarya [B2-S26]. İkisi de "içeriğin bittiği yerde oyun hâlâ sürüyor" sorununun örneği.
- **Geç oyun boşluğu bulguları:** GDT'de 20. yılda "artık düşünmüyorum, tıklıyorum" [B2-S3]; MGT2'de para anlamsız, rakip satın almak kolay [B2-S12 Düşük]; Football Manager'da bırakma 2-5 sezonda [B2-S39].

**Oyuna ders:** Soru: ek 5 yıl içerik açığını nasıl taşır? Bulgu: hiçbir referans oyun gelecek kurgusunun **iyi ya da kötü** hissettirdiğini göstermiyor (kanıt yok). Gösterilen şey, içerik **bittiği yerde** oyuncunun angarya yaşadığı (Civ VI Future Tech, GDT 20. yıl, MGT2 geç oyun). Oyuncunun kararı: ekran başında kaç dakika "gerçek karar"sız geçirdiği. Etki: 2035 sonu seçilirse son 5 yılda (261 hafta, 1×'te 1,6 sa) gerçek karar yoğunluğu 2012-2030'a eşit tutulmalı; yoksa GDT'deki "düşünmeden tıklama" kaçınılmaz. OpenTTD çözümü (2050 sonrası içerik yok ama oyun serbest) 2030 sonu için ucuz bir kapanış verir.

---

## 5. Dönem tablosu taslağı: iki seçenek

Sınıf: **G** gerçek (yürürlükte/geçmiş), **İ** önceden ilan edilmiş (tarihi bilinen gelecek), **Ö** analist öngörüsü, **K** kurgu ya da oyun-tasarımı varsayımı. Kademe satırları (Kn) SENTEZ §9.1'in "yaklaşık iki yılda bir kademe" varsayımıdır; K3 2012 ... K12 2030, 2035'te K13 2032, K14 2034 [hesap, betik]. Bütün yıllara ±2 çeyrek pay (teknoloji), mevzuat sabit [SENTEZ §9.1].

### 5.1 Ortak çekirdek (iki seçenekte de), 2012-2026

| Yıl | Tür | Açılan (modül kademesi / hat) | Sınıf | Kaynak |
|---|---|---|---|---|
| 2012 | başlangıç | Modül K1-K3, platform K1-K2 | G | SENTEZ §9.1 |
| 2014 | teknoloji | K4; Mobil | G | (varsayım A3) |
| 2015 Haz duyuru → 2016 Oca | mevzuat | Fatura: e-Belge | G | [V #2] |
| 2016 | teknoloji+pazar | K5; devin "yeni çekirdek" haberi (S/4HANA 2015); Business Central 1 Kas 2016 | G | [A1-S2] [S4] |
| 2016-2018 | mevzuat | Güvenlik: veri koruma (KVKK, GDPR) | G | [A1-S26,S27] |
| 2018 | teknoloji | K6 | G | [A1-S11] |
| 2018-2022 | mevzuat | e-Belge eşiği iner (2★ 2019, 1★ 2022) | G | [V #2] (Düşük-Orta) |
| 2020 | teknoloji | K7; uzaktan çalışma (Mobil/Erişim) | G | (varsayım A3) |
| 2022 | teknoloji | K8 | G | (varsayım) |
| 2023 | teknoloji | YZ Yardımcısı hattı (herkes sıfırdan) | G | [A1-S12][A1-S8] |
| 2024 | mevzuat+teknoloji | K9; NIS2 (18 Eki 2024) | G | [S6] |
| 2025 | mevzuat | DORA (17 Oca 2025); CSRD ilk rapor (FY2024) | G | [S8][S5] |
| 2026 | mevzuat+teknoloji | K10; AI Act genel uygulama (2 Ağu 2026); CRA bildirim (11 Eyl 2026); TR e-Defter/e-İrsaliye genişlemesi | G | [S2][S3][S15] |

### 5.2 Yalnız-2030 ve ortak 2027-2030 dilimi

| Yıl | Tür | Açılan | Sınıf | Kaynak |
|---|---|---|---|---|
| 2027 | mevzuat | CRA tam uygulama (11 Ara); AI Act Ek III (2 Ara); TR e-Arşiv tam (1 Oca) | İ | [S3][S2][S15] |
| 2027 | pazar | SAP ECC ana bakım sonu: büyük hesaplarda yeniden ihale penceresi | İ | [S11][S12] |
| 2028 | teknoloji | K11 | K (varsayım) | SENTEZ §9.1 |
| 2028 | mevzuat | ViDA tek KDV kaydı (1 Tem); AI Act Ek I (2 Ağu); CSRD ertelenen dalga | İ | [S1][S2][S27] |
| 2028 | pazar | Dynamics SL genişletilmiş destek sonu (11 Tem) | İ | [V #11] |
| 2028 | pazar+öngörü | "Kurumsal yazılımın üçte biri ajan YZ içerir" | Ö | [S17] |
| 2029 | pazar | Dynamics GP geliştirme sonu (31 Ara) | İ | [V #11] |
| 2030 | teknoloji | K12 | K (varsayım) | SENTEZ §9.1 |
| 2030 | mevzuat | ViDA DRR (1 Tem) | İ | [S1] |
| 2030 | pazar | SAP ECC uzatılmış bakım sonu | İ | [S11] |
| 2030 sonu | | Tablo donar, standart sabitlenir | | [B2-S18] OpenTTD |

### 5.3 Yalnız-2035 ek dilimi (2031-2035)

| Yıl | Tür | Açılan | Sınıf | Kaynak |
|---|---|---|---|---|
| 2031 | pazar | Dynamics GP güvenlik sonu (30 Nis); SAP "2031-2033 geçiş seçeneği" başlar | İ | [V #11][S7][S11] |
| 2031 | teknoloji | **Otonom kapanış / ajan finans** hattı (YZ hattının ikinci kademesi): "YZ Yardımcısı"ndan "YZ Ajanı"na | K | seed: [S17] ajan yaygınlaşması, hızı abartı eğilimli [S19] |
| 2032 | teknoloji | K13 | K | |
| 2032 | mevzuat | Kurgusal "YZ denetim/kayıt" yasası (AI Act'in ikinci dalgası), parodi adla | K | seed: AI Act'in aşamalı yapısı [S2] |
| 2033 | pazar | SAP özel uzatma sonu (RISE'a bağlı); JD Edwards "en az 2033"; yeni "eski çekirdek bitti" yeniden ihale dalgası | İ [V2 uyarı: SAP 2033 danışman iddiası, SAP duyurusu değil; bu satır İ yerine "doğrulanmamış" sayılırsa ek dilimde çıpalı madde 6/12 yerine 5/12, toplamda %65 yerine ~%62 (16/26)] | [S11][S9] |
| 2033 | teknoloji | Ajanlar arası fatura/ödeme standardı (ViDA DRR'nin sonraki aşaması) | K | seed: [S1] |
| 2034 | teknoloji | K14 | K | |
| 2034 | pazar | Rakip ajan paketi "standart" olur (YZ standardı 5★'tan 3★'a iner) | K | seed: [S17] yaygınlaşma |
| 2035 | mevzuat | ViDA ulusal sistemlerin hizası (1 Oca) | İ | [S1] |
| 2035 | pazar | Oracle EBS 12.2 ve JDE "en az 2036" (tarih kayıyor); GP, SL gitmiş; Business Central "bitmeyen" model | İ | [S13][S14][S4] |
| 2035 sonu | | Tablo donar | | |

### 5.4 Kurgu oranı (sayma birimi: tablodaki madde; aynı satırda "ve" ile birleşik her ayrı olay ayrı sayılır, 2027 ve sonrası; [GÖRÜŞ])

| | İ (ilan) | Ö | K (kademe varsayımı + kurgu) | Toplam | K+Ö oranı |
|---|---|---|---|---|---|
| 2027-2030 | 11 | 1 | 2 (K11, K12) | 14 | **%21** (K+Ö 3/14) |
| 2031-2035 ek | 6 | 0 | 6 (K13, K14, 4 kurgu hat) | 12 | **%50** (6/12) |
| 2027-2035 toplam | 17 | 1 | 8 | 26 | **%35** (9/26) |

(Yalnız K sayılırsa 2030: %14 (2/14), toplam 2035: %31 (8/26).) İlan edilmiş (İ) çıpalı madde oranı: **2030 sonu %79 (11/14), 2035 sonu %65 (17/26)**; öngörü (Ö) dahil %86 ve %69.

**Oyuna ders:** Soru: 2035'te dönem tablosunun yarısı kurgu olur mu? Etki: ek beş yılda 12 satırın 6'sı kurgu; bu satırların hepsi "teknoloji/pazar" türünde (mevzuat çıpası yalnız ViDA 2035). Oyuncu kararı: "erken gireyim mi bekleyeyim mi" dönem başına 1 kez, ek 5 yılda 4 kurgu hat için 4 kez. Kolaylık: kurgu satırı veri satırıdır (SENTEZ §9.1 `eras.json`), kodda yeni mekanik gerektirmez (varsayım; kod haritası bu turda yeniden okunmadı).

---

## 6. Ek içerik bedeli: modül sayısı N=5/7/10 için formül

Girdi: modül sayısı N, kademe sayısı K (2030: 12, 2035: 14; K1-K3 başlangıçta var). Her kademe: ad + açıklama, 2 dil → 4 dizge. Rakip kademe açılış haberi: modül başına K3'ten sonrası, 1 anahtar × 2 dil. Dönem satırı: duyuru + bitiş haberi = 2 anahtar × 2 dil = 4 dizge.

- Kademe dizgesi = **4 · N · K**
- Rakip sürüm haberi dizgesi = **2 · N · (K − 2)**
- Dönem haberi = **4 · D** (D = §5'teki 2027 sonrası madde sayısı: 2030 sonu 14, 2035 sonu 26)
- 2035'in 2030'a ek bedeli = 4·N·2 (iki ek kademe) + 2·N·2 (iki ek rakip haberi) + 4·D_ek = **12·N + 4·D_ek**, burada D_ek = §5.3'teki 12 madde → **12·N + 48**

| N | 2030 sonu: kademe dizgesi (K=12) | + rakip haber | 2035 sonu: kademe dizgesi (K=14) | + rakip haber | **2035 ek dizge** (kademe + haber, dönem hariç) |
|---|---|---|---|---|---|
| 5 | 240 | 100 | 280 | 120 | **60** |
| 7 | 336 | 140 | 392 | 168 | **84** |
| 10 | 480 | 200 | 560 | 240 | **120** |

Dönem maddesi haberi: D=14 madde → 56 dizge (2030), D=26 → 104 dizge (2035); fark **48 dizge** (D_ek=12). (Dönem haberini her madde için ayrı yazmak üst sınırdır; aynı satırdaki maddeler tek habere girerse düşer [GÖRÜŞ].) Toplam 2035 ek içerik: N=5 → 60 + 48 = **108**, N=7 → 84 + 48 = **132**, N=10 → 120 + 48 = **168** dizge (TR+EN), artı 2 kademe adı/metin yazım ve doğrulayıcı turu. (İki hat için sayı: 2030 sonu N=10 toplam 480+200+56 = **736** dizge; 2035 sonu N=10 toplam 560+240+104 = **904**.)

Not: sentez ajanı bu formülü K2 kod kolunun `K2_kod_fiyat_icerik.md` bulgularıyla çakıştıracak; o dosya bu turda yoktu (klasörde yalnız bu belge), çakıştırma yapılmadı.

**Oyuna ders:** Soru 2 (kaç modül) ile Soru 3 (hangi yıl) ayrı sorular değil, çarpılır: içerik bedeli ~N·K. 10 modül ve 2035 en pahalı seçenek (904 dizge), 5 modül ve 2030 en ucuz (340+56 = 396). Oyuncunun görmediği kalan etki: kademe başına metin yoksa oyuncu "bu kademe ne yaptı" diye soramaz, şablon metinle ilk sürüm çıkar (SENTEZ §15 Soru 2 görüşü) ama 14 kademe × 10 modül = 140 kademe adı oyuncuya her yenilemede görünür; kalite için ayrı yazar turu gerekir.

---

## 7. YZ dönemi payı: "ilk atılımı yapan" (YZ hattı 2023'te açılır)

| | 2030 sonu | 2035 sonu |
|---|---|---|
| YZ dönemi (2023-başlangıç → bitiş) | 8 yıl, 417 hafta | 13 yıl, 678 hafta |
| Oyunun payı | **%42** | **%54** |
| 1× (22,5 sn) | 2,6 sa | 4,2 sa |
| 3× | 0,9 sa | 1,4 sa |
| Hafta 40 sn, 1× | 4,6 sa | 7,5 sa |

YZ hattı 2023'te açıldığında oyuncu oyunun 574. haftasındadır: 1×'te 3,6 sa, 40 sn'de 6,4 sa oynamış.

**"Öncü" penceresi (hem 2030 hem 2035 için aynı):** SENTEZ'in standartı ~2027'de 5★ için şart yapması (SENTEZ §9.1) ve Gartner'ın 2028 %33 öngörüsü [S17] ile birlikte öncü olmak = 2023-2027/28, yani **4-5 yıl (~210-260 hafta; 1×'te 1,3-1,6 sa)**. Gerçek örnek hızı: S/4HANA 2015 çıktı, 2024 sonunda ECC müşterilerinin %39'u geçmişti [V #3] (~9 yılda %39); NetSuite buluta 1999-2007 [A1] (8 yıl); yani "ilk atılımın standart olması" gerçekte 8-9 yıl sürdü, 4-5 yıl değil. Bu iki yönlü bir uyarı: öncü penceresi oyunda gerçeğin yarısına sıkıştırılırsa oyuncu hızlı yarışır, gerçek hıza sadık kalınırsa 2030 sonu penceresi bitmeden kapanır (2023+8 = 2031).

**Doygunluk riski:** YZ standart olduktan sonra (2028 civarı) oyuncu için "YZ'yi alsam mı" kararı kalmaz; kalan kararlar kademe/maliyet. 2030 sonunda bu doygun dilim 2-3 yıl (2028-2030, ~104-156 hafta, 1×'te 0,7-1,0 sa). 2035 sonunda 7-8 yıl (2028-2035, ~365-417 hafta, 1×'te 2,3-2,6 sa). Civ VI "Future Tech" ve GDT "düşünmeden tıklama" bulguları [B2-S26][B2-S3] bu doygunluk diliminin sorunlu kısım olduğunu söylüyor (kanıt oyun-oyun, ERP'ye değil [SIÇRAMA uyarısı]).

**Oyuna ders:** Soru: YZ penceresi kaç yıl olsun? Oyuncu kararı: YZ'ye erken mi geç mi girmek; bir kez, 2023-2027 arasında. Etki 2030 sonunda: kararın sonucu (öncü/geç) 3 yıl içinde görülür ve oyun biter; 2035 sonunda sonuç 8 yıl görülür (öncü olan oyuncu devlere karşı 8 yıl avantajı taşır ya da kaybeder). Kolaylık: iki seçenekte de YZ hattı aynıdır; fark yalnız tablonun kaç satır daha uzadığı. Risk: 2035'te YZ standardı olduktan sonra 8 yıl "YZ kademesi bitti, sıradaki ne" boşluğu; bu yüzden §5.3'teki 4 kurgu hattın hepsinin YZ ekseninde olması gerekir (K13/K14 ile birlikte).

---

## 8. Oyuna ders: 2030 sonu mu 2035 sonu mu neyi değiştirir

### 8.1 Karşılaştırma

| Eksen | 2030 sonu | 2035 sonu | Fark oyunda ne değiştirir |
|---|---|---|---|
| Hafta (tik) | 991 | 1.252 | +261 hafta (+%26) |
| Süre 1× / 40 sn / 50 sn | 6,2 / 11,0 / 13,8 sa | 7,8 / 13,9 / 17,4 sa | +1,6 / +2,9 / +3,6 sa |
| Demo payı | %10,5 | %8,3 | mağaza sayfası "19 yıl" mı "24 yıl" mı |
| İlan edilmiş çıpalı madde (2027+) | %79 (11/14) | %65 (17/26) | ek 5 yılda 6 çıpa, 6 kurgu |
| Mevzuat çıpası, 2027+ | AI Act (2), CRA, ViDA (SVR+DRR), CSRD, e-Arşiv = 7 madde | + yalnız ViDA 2035 (+1 kurgu yasa) | "mevzuata yetişeyim mi" kararı 7 → 8 (9 kurguyla) |
| Eski çekirdek bitişi | ECC 2027 ve 2030, SL 2028, GP 2029 (4 madde) | + GP güvenlik 2031, SAP 2033, JDE ≥2033, Oracle ≥2036 (8 madde) | yeniden ihale fırsatı 4 → 8 |
| Kademe | K12 | K14 | modül başına +2 |
| İçerik (TR+EN), N=10 | 736 dizge | 904 dizge | +168 (+%23); N=5 için +108 (+%27) |
| YZ dönemi | 8 yıl, oyunun %42'si | 13 yıl, %54'ü | öncü sonrası doygun dilim 3 mü 8 yıl mı |
| Yenileme turu (ERP yaşı 11,3 yıl) | ~1,7 | ~2,1 | üçüncü ERP el değiştirmesi yalnız 2035'te görülür |
| Geç oyun boşluğu riski | düşük-orta: 2028-2030 doygunluk 3 yıl | orta-yüksek: 2028-2035 doygunluk 8 yıl; içerik kurguya yaslanır | kanıt: Civ VI, GDT, MGT2 [B2] |
| ViDA DRR (başlık madde) | 1 Tem 2030: oyunun son 6 ayı | 1 Tem 2030 + 1 Oca 2035 hizası: oturduğu görülür | 2030 sonunda mevzuat "yeni geldi, bitti" |
| Kurgu oranı | %14-21 | %31-35 (ek 5 yılda %50) | 2035'te her 2 dönem satırından 1'i kurgu |

### 8.2 Ajanın görüşü [GÖRÜŞ]

- **2030 sonu**, kanıt dayanağı daha güçlü (11/14 çıpalı) ve içerik daha ucuz; zayıf yanı ViDA başlık maddesinin oyun bitmeden 6 ay önce gelmesi ve YZ penceresinin sonucunu görmeye 3 yıl kalması.
- **2035 sonu**, YZ sonrasını ve eski çekirdek bitişlerini (SAP 2033) oyuna sokar ama ek 5 yılın yarısı kurgu olur; geç oyun doygunluk riski kanıtlı bir şikâyet türü (Civ VI Future Tech, GDT 20. yıl, MGT2).
- **Game Dev Tycoon örneği**: bitiş yılı oyuncuya bırakılabilir (35/42), kayıtta kilitlenir [B2-S1][B2-S4]. Bu, "2030 varsayılan, 2035 uzun mod" olarak uygulanabilir ama her bitiş ayrı denge testi ister [SENTEZ §15 Soru 3 C notu]; ek bedeli ayrı ölçülmedi [BOŞLUK].
- Görüşüm: 2030 sonu varsayılan; 2035 ancak §5.3'teki 4 kurgu hat yazıldıktan ve 261 haftalık dilimin karar yoğunluğu sınandıktan sonra eklenir. Bu bir tasarım görüşü, kanıt değil; karar Erdem'in.

### 8.3 Erdem'e sorulacak soru (co-director için taslak, sade dil)

"Oyun 2030 sonunda mı bitsin, 2035 sonunda mı? **Bulduğumuz şey:** 2012'den 2030 sonuna 991 hafta var; normal hızda yaklaşık 6 saat 10 dakika, hafta 40 saniye olursa 11 saat. 2035 sonuna 1.252 hafta: 7 saat 50 dakika, hafta 40 saniye olursa 14 saat. İlk 104 hafta demo. **Sorunun nereden çıktığı:** gerçek dünyada 2027 ile 2030 arası çok sayıda tarih belli (yapay zekâ yasası, siber güvenlik yasası, AB e-faturalama 2030, SAP eski sürümünün bitişi); 2031 ile 2035 arası neredeyse hiç belli değil. **Seçenek A, 2030 sonu:** oyuncunun gördüğü olayların yaklaşık yüzde 80'i gerçek ya da önceden ilan edilmiş; yapay zekâ dönemi 8 yıl; içerik en az. Örnek: AB e-faturalama raporlama kuralı 1 Temmuz 2030'da başlar; oyuncu buna yetişir ve oyun altı ay sonra biter. **Seçenek B, 2035 sonu:** 261 hafta daha (normal hızda 1 saat 40 dakika, 40 saniyede 3 saat); yapay zekâ dönemi 13 yıl; eski SAP sürümünün 2033'teki sonu ve AB kuralının 2035 son günü oyuna girer; ama ek beş yılın yaklaşık yarısı uydurma olur. 5 modül için yaklaşık 108, 10 modül için yaklaşık 168 yeni metin (Türkçe ve İngilizce). Örnek: 2033'te büyük bir müşteri üçüncü ERP'sini seçiyor; oyuncu bunu 2030 sonu seçeneğinde hiç görmez. **Üçüncü yol:** oyuncu bitiş yılını yeni oyunda seçer (Game Dev Tycoon gibi), ama her biri ayrı denge testi ister."

---

## 9. Boşluklar ve ne okundu

- Okundu (açık sayfa): AB ViDA sayfası [S1], AB AI Act sayfası [S2], AB CRA özeti [S3], Microsoft Business Central yaşam döngüsü [S4], AB CSRD sayfası [S5], AB NIS2 sayfası [S6], SAP ERP Wikipedia [S7], ESMA DORA [S8], JD Edwards Wikipedia [S9], Oracle EBS Wikipedia [S10], The Register 2025-06-20 [S11], Sovos TR 2026 takvimi [S15], SD Times (Gartner) [S17], organisator.ch (Trovarit) yalnız arama özeti, Steam GDT sayfası [S24], OpenTTD Wikipedia [S25], CSRD Wikipedia (ilk 100.000 karakter) [S27].
- Açılmadı/403/404: SAP'nin kendi bakım sayfası, Oracle roadmap PDF [S13], Gartner basın bültenleri (2024-10-21, 2025-06-25, 2014-01-29), Microsoft GP ve BC "release" yaşam döngüsü ayrıntı sayfaları, GİB e-Dönüşüm sayfası, Konsey Omnibus basın bülteni, dutchitchannel. Bu kaynaklardan gelen bilgi yalnız arama özetidir ve öyle etiketlendi.
- [BOŞLUK] Forrester/IDC/McKinsey 2030-2035 ERP öngörüsü; Türkiye 2028+ e-Dönüşüm adımı; CSRD nihai eşikleri (1.000 çalışan / 450 milyon € Omnibus I metninde); Oracle'ın 2036 taahhüdünün özgün PDF'i; Game Dev Tycoon'un yıl-konu tablosu ve gelecek-kurgu tepkisi; Software Inc. bitiş yılı; "2042" iddiası; AI Omnibus'tan önceki özgün AI Act tarihleri (sayfa vermiyor; 2 Ağu 2026 ve 2 Ağu 2027 olduğu model bilgisidir, kaynaklı değil, tabloya konmadı).
- [DEĞERLENDİREMEM] ERP dışı ürün türleri (SaaS CRM vs.) için 2030-2035 etkileri.
- `K2_kod_fiyat_icerik.md` yok; §6 formülü çakıştırılmadı.

---

## 10. Kaynak sicili

Erişim tarihi: 2026-10-20/21. Güven: Y/O/D = Yüksek/Orta/Düşük.

| S# | URL | Yayıncı | Yayın tarihi | Güven |
|---|---|---|---|---|
| S1 | https://taxation-customs.ec.europa.eu/taxation/vat/vat-digital-age-vida_en | AB Komisyonu, Vergilendirme | güncel (OJ 25 Mar 2025) | Yüksek |
| S2 | https://digital-strategy.ec.europa.eu/en/policies/regulatory-framework-ai | AB Komisyonu | güncel (AI Omnibus yürürlük 27 Tem 2026'yı anıyor) | Yüksek |
| S3 | https://digital-strategy.ec.europa.eu/en/policies/cra-summary | AB Komisyonu | güncel | Yüksek |
| S4 | https://learn.microsoft.com/en-us/lifecycle/products/dynamics-365-business-central | Microsoft Learn | sayfa 2022-10-25, "In Support" | Yüksek (resmî; satıcı) |
| S5 | https://finance.ec.europa.eu/capital-markets-union-and-financial-markets/company-reporting-and-auditing/company-reporting/corporate-sustainability-reporting_en | AB Komisyonu | güncel (3 Tem 2026 delege tüzük anılıyor) | Yüksek |
| S6 | https://digital-strategy.ec.europa.eu/en/policies/nis2-directive | AB Komisyonu | güncel | Yüksek |
| S7 | https://en.wikipedia.org/wiki/SAP_ERP | Wikipedia | güncel | Orta |
| S8 | https://www.esma.europa.eu/esmas-activities/digital-finance-and-innovation/digital-operational-resilience-act-dora | ESMA | güncel | Yüksek |
| S9 | https://en.wikipedia.org/wiki/JD_Edwards | Wikipedia | güncel ("en az 2033" eski cümle) | Orta-Düşük |
| S10 | https://en.wikipedia.org/wiki/Oracle_E-Business_Suite | Wikipedia | güncel (R12 Şubat 2007) | Orta |
| S11 | https://www.theregister.com/2025/06/20/rimini_street_sap_ecc/ | The Register | 2025-06-20 | Orta |
| S12 | https://blog.d-velop.com/software-in-use/important-news-sap-support-for-ecc-6-0-ends-in-2030/ | d-velop (satıcı blogu), arama sonucu özeti | tarih görülmedi | Düşük-Orta |
| S13 | https://www.oracle.com/cis/a/ocom/docs/applications/ebusiness/ebs-continuous-innovation-on-release-12-2.pdf (+ ebs-122-premier-support-extended-through-at-least-2033/2034.pdf) | Oracle | Ekim 2025 yol haritası (arama özeti; PDF 403) | Orta-Düşük (resmî ama açılamadı) |
| S14 | https://content.dsp.co.uk/ebs-12.2-premier-support-extended-through-at-least-2036 | DSP (Oracle ortağı) | 2025 | Düşük (satıcı) |
| S15 | https://sovos.com/tr/blog/kdv/sirketler-icin-2026-e-donusum-takvimi-ve-zorunluluklar/ | Sovos Türkiye (e-fatura çözüm satıcısı) | 2026-05-05 | Düşük-Orta |
| S17 | https://sdtimes.com/agentic-ai/gartner-more-than-40-of-agentic-ai-projects-will-be-canceled-in-next-few-years/ (+ Gartner basın bülteni 2025-06-25: https://www.gartner.com/en/newsroom/press-releases/2025-06-25-gartner-predicts-over-40-percent-of-agentic-ai-projects-will-be-canceled-by-end-of-2027, 403) | SD Times (Gartner aktarımı) | 2025-06-30 | Orta |
| S19 | https://www.gartner.com/en/newsroom/press-releases/2014-01-29-gartner-says-by-2016-the-impact-of-cloud-and-emergence-of-postmodern-erp-will-relegate-highly-customized-erp-systems-to-legacy-status | Gartner | 2014-01-29 | Orta (yalnız arama özeti; sayfa açılmadı) |
| S20 | https://www.organisator.ch/en/?p=7297 | organisator.ch (Trovarit 2020 çalışmasını aktarıyor) | 2020 | Orta (ikincil) |
| S22 | https://sparkco.ai/blog/the-coming-collapse-of-traditional-erp-systems | Sparkco blogu | tarih görülmedi | Düşük (kaynaksız sayı; KULLANILMADI, yalnız reddedildiği belirtildi) |
| S23 | https://www.technologyreview.com/2026/01/20/1129965/reimagining-erp-for-the-agentic-ai-era/ | MIT Technology Review | 2026-01-20 | Orta-Düşük (arama özeti) |
| S24 | https://store.steampowered.com/app/239820/Game_Dev_Tycoon/ | Steam/Greenheart Games | güncel | Düşük (satıcı sayfası; yorum oranı veridir: %94 / 22.236) |
| S25 | https://en.wikipedia.org/wiki/OpenTTD | Wikipedia | güncel | Orta |
| S26 | https://steamcommunity.com/app/1342330/discussions/0/3052863612114765482 (+ ilgili MGT2 tartışmaları, arama özeti) | Steam Topluluğu | 2022-2024 | Düşük |
| S27 | https://en.wikipedia.org/wiki/Corporate_Sustainability_Reporting_Directive | Wikipedia | güncel | Orta |

Devralınan: [A1-S#], [B2-S#], [V #n] = `A1_erp_evrimi.md`, `B2_donem_kilit.md`, `V_dogrulama.md` sicilleri (S16, S18, S21 boş: kullanılmadı).
