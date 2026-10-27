# Faz D · Ekip modeli v2
Hazırlayan: yardımcı yönetmenin alt ajanı (Opus), 17 Ekim 2026. Repo kodu değişmedi.

**Kaynaklar.** Erdem'in birebir yorumu `ERDEM_CD_YORUM.md`; tur 2 yorumu ve A/B cevapları (`faz_ab/ek/`); karar defteri
(Faz D bölümü); araştırma R1–R5 ve R8 (her raporun "Tamamlama" bölümü önceliklidir); paralel belge `X_URUN_EKSENLERI.md`;
A'nın kodu (`main` @ `26b60da`) ve `RAPOR_A.md`; eski `D_PLAN.md` ve `D_INCELEME.md`.

**Etiketler.**
- **Erdem'in kararı (17 Ekim):** yalnız yorum metninde açıkça kabul ettiği şey.
- **Karar defteri (tur 2):** karar defterindeki onaylı madde.
- **Öneri:** bu belgenin önerisi; Erdem'in onayını bekler.
- **[ÇALIŞMA]:** tasarım sabiti; onay bekliyor.
- Araştırma iddiası rapor ve bölüm adıyla verilir ("R4 §2.3"). Kaynaksız bilgi "(model bilgisi)" diye işaretlidir.

**Ön hesap.** Bu belgedeki bütün tablo sayıları, §6'daki tanımın birebir uygulaması olan bir prototip simülatörden
gelir (zaman sıralı hafta açık, tasarımcının hazırlığa katılması kapalı; senaryo betikleri aynı klasörde `run2.py`,
`final.py`, `detail.py`, `early.py`, `predcheck.py`): `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/dmodel2/sim2.py`
(5 tohum, 60 hafta, 21–60. haftaların medyanı). Simülasyonu yazacak ajan bu dosyayı başlangıç olarak kullanabilir;
bağlayıcı olan §6'dır.

**Simülasyon sonrası düzeltme turu (17 Ekim).** §6'nın 20 tohumluk simülasyonu (`D_SIM.md`) iki kırılma buldu: K1, kişi
ekleme eğrisinde 48. kişi teslimi düşürüyordu (belge ölçütü 1); K2, tek kurucuda A'nın hata sprinti hedefi tutmuyordu.
İkisi de modelde düzeltildi: aşama tavanı (§3.11 a) ve düzeltme payı tavanı (§3.11 b). Değişen her yer "(simülasyon
sonrası)" diye işaretlidir. Düzeltilmiş modelin ölçümü `D_SIM.md` §15'tedir; 10 ölçütün 10'u geçiyor.

---

## 0. Özet
1. Eski D planının ölçekte kırılan üç sabiti kalkar: şirket çapında "kişi başı %1 ekip kaybı", "kart başına %2–14
   hata zarı" ve "3★ PM küçük işi 1 günde, büyük işi 1 haftada" tablosu. Yerlerine iş büyüklüğünden ve yıldızdan
   türeyen kurallar gelir.
2. Kart üç aşama puanı ister: Tasarım, Geliştirme, Test. Pay, hattın kendi "iş profili" verisinden gelir; eksen kararı
   ne olursa olsun çalışır.
3. Kişi ana alanında haftada 10 × yıldız çarpanı üretir. İkincil alanda 0,7 × o alandaki yıldız, uymayan işte (yalnız
   Test) 0,4 × o alandaki yıldız. Tasarım ile kod arası kapalıdır.
4. Hafta zaman sırasıyla oynanır: bir kartın tasarımı bitmeden geliştirmesi başlamaz, hafta içinde de. Bir aşamada aynı
   anda en çok "kadro" kadar kişi çalışır; kadro her 8 puanlık iş için bir kişidir. Karta kişi eklemenin getirisi
   kendiliğinden azalır, büyük ekip daha çok kart yürütür.
5. Hata: kartın hata yükü büyüklüğüyle orantılıdır. Testi yapanın yıldızı, yükün ne kadarının yakalandığını verir
   (%28 ile %57 arası). En iyi testçi bile yükün yaklaşık %43'ünü kaçırır (R4 §2.3). Kaçan hata kartın hattına düşer.
   A'nın "yeni kod" hata terimi bu kuralın içine taşınır, ikinci kez sayılmaz.
6. Küçük karta 5 testçi: kartın testine bir kişi girer, öbürleri başka karta geçer ya da plan ekranında boşta görünür.
   Kalite, testi gerçekten yapanınkidir.
7. PM önden hazırlar. Hazırlık işi kartın büyüklüğünün %20'sidir, süre PM'in yıldızından çıkar; sabit gün yoktur. Hazır
   kart %20 az iş ister ve hata yükü ×0,75 olur. 3★ PM kendiliğinden yaklaşık 5 kişiyi besler (gerçek şirketlerde 5:1,
   R4 §2.5).
8. Tasarımcı sprintin içindedir; boş kalınca sonraki sprintin tasarımına geçer. PM'in hazırlığına katılması
   simülasyonda fark yaratmadı, bu yüzden kural eklenmez.
9. Kurucu her alanda en az orta seviye (2,5★) biri kadar hızlıdır, alanında daha iyiyse kendi yıldızıyla çalışır. Hatada
   gerçek yıldızı sayılır. Tek kurucunun MVP'si 6. haftada kalır. (inceleme) Eski plan bugünkü oyunda tek kurucunun
   MVP gününü 7 diye ölçmüştü (`D_PLAN.md` §7 MVP ölçütü); 6 ile 7 arasındaki fark D0'ın ölçümüyle kapanır, ölçüt 6–7'dir.
10. Plan ekranı, sonucu üreten oynatmanın kendisini gösterir. Darboğaz için dört gösterim yönü var (R5); öneri aşama
    şeridi ile darboğaz cümlesi.
11. Ön hesap: kişi başı teslim 1'den 50 kişiye haftada 6 ile 10,5 puan arasında kalıyor (inceleme: kişi ekleme eğrisinde
    tasarımcısız 2 ile 4 kişilik ekiplerde 5,4'e iniyor, `D_SIM.md` §4), düzeltme payı %10'un altında,
    hata sprinti yok, bir rolü eklemek teslimi düşürmüyor. Kırık bileşimler (testçisiz 20 geliştirici gibi) çökmüyor,
    darboğaz olarak görünüyor.
    (simülasyon sonrası) 20 tohumluk simülasyon iki kırılma buldu ve ikisi de modelde düzeltildi: plan bir aşama
    satırına ekibin o aşamadaki iki sprintlik işinden fazlasını koymaz (48. kişinin teslimi düşürmesi bu yüzden
    kalktı), planın kendiliğinden aldığı düzeltme işi kapasitenin yarısını aşmaz (tek kurucuda hata sprinti %5,6'dan
    %0'a). İkisi de oran kuralıdır ve 2 ile 50 kişilik ekiplerin sonuçlarını değiştirmez (§3.11, `D_SIM.md` §15).
12. Bedel büyük: sprint motorunun hafta oynatması yeniden yazılır. 7 commit ve bir ölçüm turu, 30–35 saat. 6 açık soru.

---

## 1. Erdem'in D yorumları ve karşılıkları
Sözler `ERDEM_CD_YORUM.md`'den kısaltılmış alıntıdır.

| # | Erdem'in sözü | Karşılık | Nerede | Etiket |
|---|---|---|---|---|
| 1 | "Ekip kısmını da zamanında yeterince iyi tasarlamamışız… diğer oyunlar nasıl ele alıyor… iyice araştırmamız lazım" | Sekiz tasarım sorusu için dört oyun ve gerçek pratik yan yana; her soruda seçim ve gerekçe | §2 | |
| 2 | "Bu oyun böyle kurgulamış… hangisini örnek almamız ya da minik modifikasyonlarla nasıl ilerlememiz" | Her soruda "aldık / uyarladık / almadık" ayrımı | §2 | |
| 3 | "Deneyim kartı, inovasyon kartı, kararlılık kartı… oyuncuya hiçbir yerde görünmüyor… neyi temsil ettiğini ben bile bilmiyorum" | Kart artık eksen adı taşımaz. Aşama payı hattın "iş profili"nden okunur (X §8.3 ile aynı sözleşme). Oyuncu yalnız "Tasarım 9 · Geliştirme 11 · Test 5" görür | §3.2, §5 X | Öneri |
| 4 | "Kişinin haftalık puanı ölçek falan okey" | 2,5★ kişi ana alanında haftada 10 puan; kartlar 15 / 25 / 40 | §3.1 | Erdem'in kararı (17 Ekim) |
| 5 | "0.7 çarpı eğer yıldızı varsa yıldızı kadar… bu şekilde olmalı" | İkincil alanda hız = 10 × 0,7 × o alandaki yıldız çarpanı | §3.3 | Erdem'in kararı (17 Ekim) |
| 6 | "Hiç yıldızı yoksa 0.4… ya da 0.3 gibi bir verimde çalışması daha mantıklı. Aynen" | Uymayan iş = 0,4 × o alandaki yıldız çarpanı. (inceleme) Sonuç orta seviye birinin 0,20 (o alanda hiç puanı yok) ile 0,40 (o alanda orta seviye) arası; senin "hiç yıldızı yoksa 0,3–0,4" sözünün altına iner. Öneri (inceleme): en az 0,3 tabanı (§3.3) | §3.3 | Erdem'in kararı (0,4 ya da 0,3); biçim ve taban öneri |
| 7 | "Uyumsuz olduğu her hafta için sprint sonunda eksi 2 moral okey" | Sprint kapanışında, uymayan işte çalıştığı hafta başına −2 | §3.3 | Erdem'in kararı (17 Ekim) |
| 8 | "Geliştirici tasarım, tasarımcı kod yapmaz. Bu doğru" | Tasarım ile Geliştirme arasında uyum yok, kutu da yok | §3.3 | Erdem'in kararı (17 Ekim) |
| 9 | "Tavanda %25… PM kapsamındakilere %12,5'a mı düşüyor… değerlendirelim" | Eski kural: 3 kişiden sonraki her kişi %1, tavan %25; PM'in kapsadığı 8 kişinin kaybı yarıya iniyordu. Bu kural kalkar (madde 10) | §3.5 | Öneri |
| 10 | "Software Inc'te var diye mi ekliyoruz? Eklenmeli mi eklenmemeli mi?" | Şirket çapında kayıp eklenmez. Kanıt kaybın aynı iş üzerinde doğduğunu söylüyor (R4 §2.5, QSM ve Brooks); oyunlar da onu iş başına koyuyor (R1 §2.3, R3 §7.1). Kayıp kart başına kadroda ve aşama sırasında yaşar | §2.4, §3.4, §3.5 | Öneri; açık soru 1 |
| 11 | "5 yıldız %2… çok düşük geldi" | En iyi tek test aşaması hataların yarısından biraz fazlasını yakalar (R4 §2.3: ort. %40, en çok %55). 5★ testçi yükün %57'sini yakalar, %43'ü kaçar | §3.6 | Öneri; açık soru 2 |
| 12 | "5 tane testçim var… küçük bir iş… beşi de o kartta aktif görev alabiliyor mu? Alıyorsa çıktılar nasıl olacak?" | Hayır. Küçük kartın testi 3 puandır, kadrosu 1 kişidir; en iyi testçi alır, haftanın küçük bir kısmında bitirir. Öbür dördü başka karta geçer ya da boşta görünür. Kalite onun yakalama oranıdır; kalabalık kaliteyi artırmaz. (inceleme) Kaynak bunu yarım destekler: R4 §2.4'te Porter "1 kişi < 2 kişi, ama 2 = 4" der, Nielsen eğrisi de ikinci kişinin ek bulduğunu söyler. Model 1'den 2'ye kazancı bilerek almaz (sadelik); 2'den sonrasının kazanç getirmemesi kaynakla uyumludur | §3.4, §3.6, §4.3 | Öneri |
| 13 | "Burada çok sığ planlama yapılıyor… başka bir şey olduğunda patlıyor" | Her kural için "neden var"; 12 senaryo ve kırılma ölçütleri | §3, §4, §6 | |
| 14 | "PM önden gider… sıkıntı yok. PM sprint puanı üretmez. Okey" | PM sprint kapasitesine girmez; önden hazırlar | §3.7 | Erdem'in kararı (17 Ekim) |
| 15 | "3 yıldız bir PM küçük işi bir günde büyük işi 1-2 haftada… bu kadar sabite bağlamamalıyız" | Hazırlık işi kartın büyüklüğünün %20'si; süre PM'in yıldızından çıkar. Tablo yoktur, süreler sonuçtur (§3.7 örnekleri) | §3.7 | Öneri |
| 16 | "Hazır kart %20 daha az iş… 0.75… gayet iyi bir buff" | Kalır; kısmi hazırlık orantılı fayda verir | §3.7 | Erdem'in kararı (17 Ekim); orantılılık öneri |
| 17 | "PM'siz ekibe ceza yok. Bu da okey" | Kalır | §3.7 | Erdem'in kararı (17 Ekim) |
| 18 | "PM tek başına yazmıyor, tasarımcıyla beraber… tasarımcı sprintte mi olmalı, PM gibi önden mi?" | Araştırma: keşif PM, tasarımcı ve mühendisin ortak işi (R4 §2.1 Cagan, Torres); ayrıntılı tasarım teslimde, tasarımcı sprint planlamasında (Gothelf). Öneri: tasarımcı sprintte, boşta kalınca sonraki sprintin tasarımına. PM'in hazırlığına katılma kuralı simülasyonda fark yaratmadı | §2.6, §3.7 | Öneri; açık soru 3 |
| 19 | "10 çalışanı aldığı zaman aynı rolde… oyun bozuluyor… sabitlerle mi, dinamik mi" | Kişi başı sabit yüzde yok. Her sabit ya kişinin kendisine, ya kartın büyüklüğüne bağlı; ölçek tablosu ve 10 geliştirici senaryosu | §4 | |
| 20 | "Her aşamada en az bugünkü hızında çalışır… bunu anlayamadım" | Yeni anlatım: "Kurucu her alanda en az orta seviye (2,5★) biri kadar hızlı çalışır. Alanında daha iyiyse kendi yıldızıyla." Hatada gerçek yıldızı sayılır | §3.8 | Öneri; açık soru 4 |
| 21 | "Hata ihtimalinde gerçek test yıldızı okunur demişiz. Tamam" | Kalır; kurucu dahil | §3.6, §3.8 | Erdem'in kararı (17 Ekim) |
| 22 | "Plan ekranı… tahmin sonuçla aynı çıkmak zorunda" | Plan ekranı ile kapanış aynı oynatma fonksiyonunu çalıştırır; yeni girdilerin hepsi sprint başında sabitlenir | §3.10 | Erdem'in kararı (17 Ekim) |
| 23 | "Bu işler yapılır ama testleri yetişmez çünkü yeterli testçimiz yok… nasıl gösterim… araştıralım" | Dört yön: aşama şeridi, darboğaz cümlesi, kart zinciri (R5 §7'nin A, B, C yönleri) ve kişi yük şeridi (R5 §8.1, §8.3). (inceleme) R5 §7'nin dördüncü yönü Linear'ın kapasite kadranıdır ve alınmadı (§3.9). Öneri ilk ikisi ekranda, üçüncüsü kart ipucunda, dördüncüsü avatarlarda | §3.9 | Öneri; açık soru 6 |
| 24 | "20-30 çalışan… early access… infinite run… belki 50… geriye dönüp fixlemekle uğraşmamalıyız" | 1, 3, 6, 12, 25 ve 50 kişide ön hesap; uç bileşimler; 50 kişide sınırın ne olduğu (kart arzı, PM sayısı, test oranı) | §4 | |
| 25 | "Şu anda… faz C'yi ve faz D'yi production'a alsak başka yerler patlayacak" | A, B, C, X ve E ile her temas noktası; bilinen kırılma riskleri (A'nın sabit itibar eşiği gibi) | §5 | |

---

## 2. Oyun oyun karşılaştırma
Her soru için: oyunlar ne yapıyor, gerçek pratik ne diyor, bizim seçimimiz ve nedeni.

### 2.1 Rol çıktısı: kim ne üretir, beceri neyi değiştirir
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Tasarımcı, programcı, sanatçı ayrı iş yapar. Hız memnuniyetten, kalite taban beceriden gelir. Uzmanlık yıldızı (3 kademe) hangi özelliğe dokunulabileceğini belirleyen bir kapıdır (R1 §1 madde 2, §2.1) |
| Startup Company | Her rol kendi parça türünü üretir; kişinin hızı tek bir yüzdedir (Beginner, Intermediate, Expert, tavan). Expert kalemi yalnız Expert çalışan yapar (R2 §2.1, §7.2) |
| Game Dev Tycoon | Herkes Design ve Tech puanı üretir. Kişinin kalite faktörü hem puan miktarını hem hata olasılığını belirler; sorumlu olmadığı alanda ×0,7 çalışır (R3 §7.1) |
| Mad Games Tycoon 2 | Oda meslek kabul eder; geliştirme odasında yalnız geliştirici ve programcı tam hızdadır, başkası ilgili puanı biraz artırır ama hızı düşürür (R3 §7.3) |
| Gerçek pratik | Kapasite kişi başına ve aktivite başına girilir (Azure DevOps, R5 §2.1). Ayrı test rolü olan ve olmayan ekipler var; oran sektöre bağlı (R4 §2.2) |

**Seçimimiz.** Rol kendi aşamasının puanını üretir; yıldız hızı onaylı tabloyla, kaliteyi bu tablonun karekökü kadar
değiştirir (§3.3, §3.6). İkincil alan ×0,7, uymayan iş ×0,4, tasarım ile kod arası kapalı.
**Neden.** GDT'nin "aynı beceri hem hızı hem hatayı belirler" kuralı, kişiyi iki yönden değerli kılar ve 50 kişide "çok
sayıda ucuz 1★ geliştirici" stratejisinin bedelini hata olarak öder (R3 §7.1). Software Inc.'in yıldız kapısı küçük
ekipte kilitler (R1 §5 "Alınmayacak" 2); bizde kapı yalnız hattın bugünkü kademe koşullarında kalır.

### 2.2 Kartın ihtiyacı
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Özellik süresi (ay) ve kod/sanat oranı; tasarım belgesinde pasta grafiği (R1 §2.2, §7.1) |
| Startup Company | Özellik = adet × parça × rol × taban saat; ekranda "adet (stok)"; rol başına toplam saat ayrıca yazılır (R2 §7.2, §7.7) |
| Game Dev Tycoon | 3 aşama × 3 alan; türün tasarım/teknoloji oranı (R3 §2.1, §7.1) |
| Mad Games Tycoon 2 | Dört puan türünün her biri ayrı eşik ister; biri öbürünü kapatmaz (R3 §2.4) |
| Gerçek pratik | Aktivite başına kalan iş (R5 §2.1) |

**Seçimimiz.** Kart üç aşama puanı ister. Büyüklük kademeden (K1 15, K2 25, K3 40), pay hattın iş profilinden gelir.
**Neden.** Startup Company'nin "rol başına toplam" gösterimi Erdem'in tur 2 sorusunun ("bu kart şu kadar tasarım
puanı istiyor…") birebir cevabıdır. Profil eksenden ayrı tutulur çünkü hattın hangi işi istediği ile müşterinin ondan
ne beklediği ayrı sorulardır (X §8.3).

### 2.3 Karta kaç kişi
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Proje başına önerilen kadro; özellik sayısıyla 4–6 kat büyür; üstü azalan getiri. Ekranda "Recommended designers 6/3" (R1 §2.3, §7.2, §7.4) |
| Startup Company | Kişi tek parçada çalışır; paralellik parça sayısındadır (R2 §2.2) |
| Game Dev Tycoon | Oyun boyutuna göre en iyi ekip: küçük 1, orta 2–3, büyük 3–5, AAA 6. Fazla yük boşta kalmaktan üç kat pahalıdır (R3 §7.1) |
| Mad Games Tycoon 2 | Kişi sayısıyla doğrusal puan; sınır oda başı yaklaşık 10 kişi (R3 §7.3) |
| Gerçek pratik | Amdahl: sıralı kısım hızlanmayı sınırlar. Porter: 2 gözden geçirici = 4. Brooks: iş bölünebildiği kadar. Öneri: 2. kişi ≤ %40, 3. kişi ≤ %10 ek hız (R4 §2.4, §5 madde 6) |

**Seçimimiz.** Kart aşamasının kadrosu = her 8 puan için bir kişi. Kadro dolunca o aşamaya kimse girmez. Aşamalar
hafta içinde de sırayla akar.
**Neden.** Kadro işin büyüklüğünden gelir, şirketin büyüklüğünden değil; 50 kişilik şirket de 3 kişilik şirket de aynı
kartta aynı tavanı görür. K1'in geliştirme kadrosu 1–2, K3'ünkü 3–4; GDT'nin boyut tablosuyla aynı aralık. Aşama sırası
Amdahl'ı kendiliğinden getirir: geliştirmeye kişi eklemek tasarımı ve testi kısaltmaz (§3.4 örneği).
**Almadığımız.** GDT'nin "alan başına tek kişi" katı kuralı (R3 §5) ve MGT2'nin cezasız doğrusal modeli.
(inceleme) **Kaynaktan ayrıldığımız yer.** R4 §5 madde 6, kartın 2. geliştiricisine en çok %40, 3.'süne en çok %10 ek hız
önerir. Bizim kadroda her kişi tam hızdadır; kayıp yalnız kadro tavanından ve aşama sırasından gelir. Sonuç olarak kartın
süresi R4'ün önerisinden daha hızlı kısalır (§3.4 örneğinde 2. geliştirici süreyi 3,45'ten 2,33 haftaya indiriyor, yani
kart düzeyinde %48 hızlanma). Gerekçe §3.4'ün son maddesinde; bu bir uyarlamadır, kaynakla birebir değildir.

### 2.4 Ekip büyüklüğü ve koordinasyon
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | 10–12 kişilik takım ideal; büyük projede etkinlik 25 civarında doyar; 30'dan 150'ye çıkınca bazı işler uzadı. Geliştirici: "Genel ilerleme yavaşlarsa bu hatadır; eklenen kişilerin eskisi kadar etkili olmaması normaldir" (R1 §1 madde 5, §2.3) |
| Startup Company | Ekip cezası yok; yöneticinin bonusu yönettiği kişi sayısına bölünür (R2 §7.1) |
| Game Dev Tycoon | Yapısal tavan (alan sayısı) ve fazla yük cezası (R3 §7.1) |
| Mad Games Tycoon 2 | Ceza yok; hedef yılla büyür (R3 §7.3) |
| Gerçek pratik | QSM: küçük ekip aynı işi 3–4 kat ucuza, 2–3 kat az hatayla yapar; büyük ekip süreyi yalnız %6–30 kısaltır. Kayıp ekip içinde n(n−1)/2 kanalla büyür; şirketler ekibi böler (Amazon "iki pizza"). Ekipler arası kayıp doğrusal ya da daha yavaştır (R4 §2.5) |

**Seçimimiz.** Şirket çapında kayıp yok. Kayıp aynı işin üzerinde yaşar: kart kadrosu ve aşama sırası.
**Neden.** Eski kural ("3 kişiden sonra her kişi %1") ayrı kartlarda çalışan 20 kişiyi de cezalandırıyordu; kanıt bunu
desteklemiyor. Software Inc.'in geliştiricisi bile genel yavaşlamayı hata sayıyor. Kadro kuralı Erdem'in "kademeli
olsun" isteğini (karar defteri, tur 2) şirket büyüklüğüne değil iş büyüklüğüne bağlayarak karşılar.
(inceleme) R4 §2.5 ekipler arası kaybın "sıfır olmadığını" da yazar (örgüt yapısı hatayı öngörür; yönetici katmanı
eklenir) ve bu cümle raporun kendi türetimidir. Biz onu bilerek modellemiyoruz: oyuncunun göremeyeceği ve tek bir
karara bağlayamayacağı bir çarpan olurdu. 50 kişide yönetim yükü gerekirse ayrı ve görünür bir kural olarak gelir (EA).
**Almadığımız.** Startup Company'nin yönetici bonusu: oyuncunun göremediği bir hız çarpanı olurdu.

### 2.5 Test ve hata
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Hata sayısı gizli ve ürün büyüklüğüyle büyür; düzeltme kapasitesi en yetenekli kişiye bağlı; hata kaliteyi değil destek yükünü ve satışı etkiler (R1 §2.4) |
| Startup Company | Hata mekaniği yok (R2 §7.4) |
| Game Dev Tycoon | Doğan her puan, kişinin kalite faktörüne bağlı olasılıkla hata olur (%6–31); hata toplam puanın yüzdesi olarak incelemeye girer (R3 §7.1) |
| Mad Games Tycoon 2 | QA odası; Game Tester en iyi hata avcısı, başkası QA'da yavaş (R3 §2.4) |
| Gerçek pratik | Tek test aşaması ortalama %40, en çok %55 yakalar; dört aşama %85. Hata potansiyeli işin büyüklüğüyle orantılı. Birden çok gözden geçirici hızla azalan getiri verir (R4 §2.3, §2.4) |

**Seçimimiz.** Kartın hata yükü büyüklüğüyle orantılı; yapan geliştiricinin yıldızı yükü azaltır; testi yapanın yıldızı
yakalama oranını verir (%28–57). Kaçan = yük × (1 − yakalama). Testi birden çok kişi yaparsa kalite, yaptıkları payla
ağırlıklı ortalamadır.
**Neden.** Hata sayısı işle büyür (Jones, GDT), test yalnız bir kısmını yakalar (Jones); sabit bir "kart başı zar"
büyük kartı ve küçük kartı aynı sayardı. Yakalama oranı araştırmanın en düşük ve en yüksek değerleri arasında kalır.
**Almadığımız.** Software Inc.'in gizli hata sayısı (A'nın "N açık hata" gösterimine ters, R1 §5).

### 2.6 Ön hazırlık ve tasarımcının yeri
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Tasarım fazı önce, %100'de biter; proje yönetimi otomasyonu tartışmalı (R1 §2.2, §2.6) |
| Startup Company | Üretim planını yönetici yürütür; tasarımcı ayrı parça üretir (R2 §2.2, §2.3) |
| Game Dev Tycoon | Algoritmada "Hazırlık" aşaması var; tasarım alanları ilk aşamada (R3 §7.1) |
| Mad Games Tycoon 2 | Kaynak yok |
| Gerçek pratik | Keşif teslimin 1–2 sprint önünde (geçiş modeli); keşfi PM, tasarımcı ve mühendis birlikte yapar; Gothelf tasarımcıyı sprint planlamasında ister; Patton tasarımcının taktik tasarım için biraz önde çalışmasını kabul eder; iyileştirme kapasitenin ≤ %10'u (R4 §2.1) |

**Seçimimiz.** PM önden hazırlar (keşif). Tasarımcı sprintin tasarım aşamasında çalışır, sprintte işi kalmayınca sonraki
sprintin tasarımına geçer (taktik tasarım). Hazırlık her aşamanın işini %20 azalttığı için PM'in işi tasarımcının işini
de kısaltır; "birlikte" etkisi buradan gelir.
**Neden.** Simülasyonda tasarımcının PM'in hazırlığına katılması teslimi değiştirmedi (12 kişi: 116 ile 116; 25 kişi,
tek PM: 234 ile 233), çünkü tasarımcı nadiren boş kalıyor. Fark yaratmayan kural eklenmez.

### 2.7 Darboğaz gösterimi
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Önerilen kadro ve aşım için kırmızı gösterge; üstte "Issues" listesi; verim nedenleri cümleyle (R1 §7.4, R5 §8.2) |
| Startup Company | Beta 22'de "bottleneck alert": "neyi artırırsam üretim artar" (inceleme: sunucu kapasitesi üretimi için, sprint için değil); çalışanın üstünde durum ve yüzde; "adet (stok)" (R5 §2.7, §8.1) |
| Game Dev Tycoon | Çalışanın altında yük çubuğu; aşırı yük ve boşta kalma ayrı cezalı (R5 §8.3) |
| Gerçek pratik | Azure DevOps aktivite başına kapasite çubukları ve aşım; Kanban WIP; kısıtlar teorisi (R5 §2.1, §2.5; R4 §2.6) |

**Seçimimiz.** Dört yön (§3.9). Öneri: aşama şeridi ve darboğaz cümlesi ekranda; kart zinciri kartın ipucunda; kişi yük
şeridi avatar satırında.
**Neden.** Software Inc.'te süre tahmini varsayımı gizlediği için tutmuyor ve oyuncu "neyi değiştireyim" bilemiyor
(R5 §2.6, §4). Bizim tahminimiz sonucun kendisidir; göstermesi gereken şey nedendir.

### 2.8 50 kişide yönetim
| Kaynak | Nasıl yapıyor |
|---|---|
| Software Inc. | Lider, İK ve proje yönetimi otomasyonu; mikro yönetim şikâyeti; 200 kişide kim hangi ekipte izlenemiyor (R1 §2.6, §4) |
| Startup Company | Yönetici 3 / 5 / 8 kişi, İK yöneticisi yöneticileri yönetir; toplu işlemler; 180 kişiye tek tek ikramiye şikâyeti (R2 §2.3, §4) |
| Game Dev Tycoon | Büyük şirket modeli yok (R3 §4) |
| Mad Games Tycoon 2 | 500 çalışana kadar oynanıyor; sınır oda ve performans (R3 §4) |
| Gerçek pratik | Mühendis:PM 5:1'den 11:1'e; 10–15 mühendiste ilk yönetici (R4 §2.5) |

**Seçimimiz.** Oyuncu kişi değil kart sırası ve iş kutusu yönetir; atamayı motor yapar. PM oranı sabit değildir:
hazırlık işi kart büyüklüğüyle, PM'in hızı yıldızıyla geldiği için 3★ PM yaklaşık 5, 5★ PM yaklaşık 8 kişiyi besler.
Plan ekranı bütün ekibi üç aşama satırına toplar.
**Neden.** Startup Company'nin şikâyetleri, kişi başına tıklanan her kararın 50 kişide angaryaya döndüğünü gösteriyor.
50 kişide oyunun sınırı kişi sayısı değil: kart arzı (hat ve kademe içeriği), PM sayısı, tasarım ve test oranı.

---

## 3. Önerilen model
Her kuralın altında "Neden var" satırı vardır.

### 3.1 Birimler
- **Puan.** 2,5★ (alan puanı 5) bir kişi, 8 saatlik haftada, verimi 1 iken ana alanında **haftada 10 puan** üretir.
  Bugünkü ölçeğin 5 katıdır. Erdem'in kararı (17 Ekim): "kişinin haftalık puanı ölçek falan okey".
- **Kart büyüklüğü (S).** K1 15, K2 25, K3 40; araştırma kartı 5; ücretli plan 15; düzeltme kartı 5 (1–4 hata) ya da
  10 (5 ve üstü hata). Bugünkü 3 / 5 / 8 / 1 / 3 / 1–2 değerlerinin 5 katı.
- **Sprint.** 1 ya da 2 hafta (bugünkü gibi). Kapasite tavanı %125 kalır. (simülasyon sonrası) Yanına aşama başına
  ikinci bir tavan ve düzeltme payı tavanı gelir (§3.11).
- Neden var: aşama ihtiyaçları ve yarım yıldızların haftalık farkı tam sayıyla okunur ("Tasarım 2" yerine "Tasarım 0,4"
  yazmamak için). Oranlar değişmez; tek kurucunun hızı aynıdır.

### 3.2 Kartın ihtiyacı
Her hattın veride bir **iş profili** alanı olur: tasarım ağırlıklı, geliştirme ağırlıklı ya da test ağırlıklı. Başlangıç
değeri bugünkü eksenden bir kez kopyalanır (Deneyim → tasarım, İnovasyon → geliştirme, Kararlılık → test). Bu, X
belgesinin önerdiği sözleşmedir (X §8.3).

| Kart (Tasarım / Geliştirme / Test) | Tasarım ağırlıklı (35/45/20) | Geliştirme ağırlıklı (15/65/20) | Test ağırlıklı (10/55/35) |
|---|---|---|---|
| K1 · 15 | 5 / 7 / 3 | 2 / 10 / 3 | 2 / 8 / 5 |
| K2 · 25 | 9 / 11 / 5 | 4 / 16 / 5 | 3 / 13 / 9 |
| K3 · 40 | 14 / 18 / 8 | 6 / 26 / 8 | 4 / 22 / 14 |

- **Düzeltme kartı:** 5 → 0 / 3 / 2; 10 → 0 / 7 / 3 (A'nın 0,7 / 0,3 payı).
- **Araştırma kartı:** yalnız Ürün aşaması, 5 puan. PM yapar (×1,0), tasarımcı yapar (ikincil, ×0,7), kurucu yapar.
- **Ücretli plan:** 2 / 10 / 3 (geliştirme ağırlıklı K1 gibi).
- **Ar-Ge "Tasarım sistemi":** bugün Deneyim kademelerinin eforunu %20 indiriyor; bundan sonra aynı indirimi tasarım
  ağırlıklı hatların kartlarına uygular (X §8.3). Değeri değişmez.
- Oyuncu profili adıyla görmez; kart "Tasarım 9 · Geliştirme 11 · Test 5" yazar.
- **Eksen kararı iki yöne giderse:** X (b) eksenleri gösterir ya da (c) alanları tek kalite yapar. İkisinde de profil
  ayrı bir veri alanıdır, değerleri aynı kalır; D'nin sayıları değişmez. Eksen tamamen silinirse yalnız ilk kopyalama
  adımı kalkar, profil durur. Yeni hatlar (E'nin pazaryeri hatları) profili kendileri taşır.
- Neden var: rol kendi aşamasının puanını üretiyorsa kart her aşamadan ne istediğini söylemeli; aksi hâlde testçinin ve
  tasarımcının değeri hesaplanamaz. Profil eksenden ayrı olduğu için bir hat "Güven alanında ama tasarım ağırlıklı"
  (yetki ekranı gibi) olabilir.

### 3.3 Kişinin katkısı
**Haftalık aşama hızı** = 10 × Y(s) × U × verim × saat × pay × huy

| Terim | Değer | Neden var |
|---|---|---|
| Y(s), yıldız çarpanı | s = kişinin o aşamanın alanındaki puanı (0–10); Y = 0,5 + 0,05·s + 0,01·s². Karar defteri (tur 2) tablosu | Yıldız gerçekten fark eder; bugün 4, 5 ve 6 puanlık kişiler aynı hızda |
| U, uyum | Ana alan 1,0 · ikincil 0,7 · uymayan 0,4 · kurucu her aşamada 1,0 | Erdem'in kararı (17 Ekim): ikincil "0,7 × yıldızı kadar", uymayan 0,4 ya da 0,3. (inceleme) 0,4 × Y(0) = 0,2: o alanda hiç puanı olmayan kişi Erdem'in "hiç yıldızı yoksa 0,3–0,4" tabanının altına iner. Öneri: uymayan işte Y × U en az 0,3 [ÇALIŞMA]; simülasyonda yalnız "S3 + PM'in Test kutusu" senaryosuna dokunur |
| verim | Bugünkü verim (moral payı ve olay satırları) | Verim eğrisi yeniden tasarlanmaz (D görevinin kapsamı dışında) |
| saat | Bugünkü çalışma saati çarpanı | Aynı |
| pay | A K1'in sprint payı: tek iş 1; Yapım ve Test 1; Yapım ve Destek 0,5; yalnız Destek ya da Ar-Ge 0 | İki işli kişi iki yerde sayılmaz |
| huy | TİTİZ hız ×0,85; GÖZÜ YÜKSEKTE ×1,15. Değerler bugün huy tablosunda duruyor ama sprint okumuyor | Dosyada yazan huy etkisi sprintte de olur; "oyuncunun göremediği model" değil, gördüğü vaadin karşılığı |

Yıldıza göre haftalık puan (ana alan, verim 1, 8 saat):

| Yıldız (puan) | 1★ (2) | 1,5★ (3) | 2★ (4) | 2,5★ (5) | 3★ (6) | 3,5★ (7) | 4★ (8) | 4,5★ (9) | 5★ (10) |
|---|---|---|---|---|---|---|---|---|---|
| Ana alan | 6 | 7 | 9 | 10 | 12 | 13 | 15 | 18 | 20 |
| İkincil (×0,7) | 4 | 5 | 6 | 7 | 8 | 9 | 11 | 12 | 14 |
| Uymayan (×0,4) | 3 | 3 | 3 | 4 | 5 | 5 | 6 | 7 | 8 |

**Kim hangi aşamada çalışır (Görevler matrisi aşama kapısıdır).**

| Rol | Yapım kutusu | Test kutusu |
|---|---|---|
| Kurucu | Her aşama ×1,0 (matriste değil) | |
| Ürün yöneticisi | Sprint puanı yok: hazırlık (§3.7) ve araştırma kartı ×1,0 | Test ×0,4 (uymayan), dosyada uyarı stiliyle |
| Tasarımcı | Tasarım ×1,0, araştırma kartı ×0,7 | Test ×0,4 (uymayan) |
| Geliştirici | Geliştirme ×1,0 | Test ×0,7 (ikincil) |
| Testçi | Geliştirme ×0,7 (ikincil) | Test ×1,0 |

- İşe alımda bugünkü varsayılan iş gelir (geliştirici Yapım, testçi Test). İkincil kutuyu oyuncu işaretler (tur 2:
  "ikinci role verirse"). Darboğaz satırı oyuncuya nerede eksik olduğunu söyler (§3.9).
- Tasarım ile Geliştirme arasında hiç uyum yoktur: geliştirici tasarım, tasarımcı kod yapmaz (Erdem'in kararı, 17 Ekim).
  Tasarımcısız ekipte tasarımı kurucu yapar.
- **Moral:** Uymayan işte çalıştığı her hafta için kişi sprint kapanışında −2 moral alır (Erdem'in kararı, 17 Ekim).
  Moral sprint içinde değişmez; tahmin bozulmaz.
- **Ön hesap:** 6 kişilik ekipte PM'in Test kutusu işaretlenirse teslim haftada 55'ten 50'ye düşer, PM'in hazırlığı
  %100'den %70'e iner ve PM 60 haftada yaklaşık 76 moral kaybeder. Kural "bu böyle çalışmaz"ı sayıyla söyler.

### 3.4 Hafta: aşama sırası ve kadro
**Kadro.** Kartın her aşamasının kadrosu = ⌈aşama ihtiyacı ÷ 8⌉, en az 1. Sprint başında sabitlenir.

| Kart | Tasarım | Geliştirme | Test |
|---|---|---|---|
| K1 tasarım ağırlıklı (5 / 7 / 3) | 1 | 1 | 1 |
| K1 geliştirme ağırlıklı (2 / 10 / 3) | 1 | 2 | 1 |
| K2 test ağırlıklı (3 / 13 / 9) | 1 | 2 | 2 |
| K3 geliştirme ağırlıklı (6 / 26 / 8) | 1 | 4 | 1 |
| K3 test ağırlıklı (4 / 22 / 14) | 1 | 3 | 2 |

**Hafta nasıl oynanır.**
1. Hafta 0 anında başlar, 1 anında biter.
2. Kartın sıradaki aşaması açıktır. Bir aşama bittiği an kartın sonraki aşaması açılır; aynı hafta içinde de.
3. Boştaki bir kişi, o an açık aşaması olan ve kadrosu dolmamış **ilk karta** (sprint sırasıyla) geçer. Aynı aşamaya
   aday birden çoksa sıra: ana alanı o aşama olan çalışan, sonra kurucu, sonra ikincil alanlı, en son uymayan; eşitlikte
   o aşamada hızlı olan, sonra kimlik.
4. Kişi aşama bitene ya da hafta bitene dek orada kalır. Aşamadaki herkes kendi hızıyla aynı anda çalışır.
5. Haftada boş kalan süre önden işlere gider: PM hazırlığa, tasarımcı sonraki sütunun tasarımına (§3.7). Kalan süre
   "boşta"dır ve plan ekranında görünür.

**Örnek: karta geliştirici eklemek** (K3 geliştirme ağırlıklı 6 / 26 / 8; 3★ tasarımcı, 3★ testçi, 3★ geliştiriciler):

| Geliştirici | 1 | 2 | 3 | 4 | 5 ve üstü |
|---|---|---|---|---|---|
| Kartın süresi (hafta) | 3,45 | 2,33 | 1,96 | 1,77 | 1,77 |
| Bir öncekine göre kazanç | | 1,12 | 0,37 | 0,19 | 0 |

- Neden var (kadro): aynı işe sınırsız kişi koymak gerçekte hızlandırmaz (R4 §2.4 Brooks, Amdahl; R1 §2.3; R3 §7.1).
  Tavan işin büyüklüğünden geldiği için şirket büyüdükçe kaymaz.
- Neden var (aşama sırası): tasarım bitmeden geliştirme başlayamaz; bugünkü motor bunu hafta içinde atlıyor ve büyük
  ekip her kartı bir haftada bitiriyor. Sıra, kartın en kısa süresini işin kendisine bağlar: 50 kişi bir K3'ü 1,77
  haftadan kısa bitiremez (3★ kişilerle), ama aynı anda 25 kart yürütebilir.
- **Bedel ölçüldü:** teslim neredeyse değişmiyor (aynı ekip, kart ve 3 tohumla bugünkü gibi bütçe hafta ile zaman
  sıralı hafta: 3 kişi 22,9 ile 22,1; 6 kişi 57 ile 55; 12 kişi 115 ile 116). Değişen, kartın süresi ve ekiplerin MVP
  haftası (3 ve 6 kişide 2'den 4'e). Tek kurucu değişmez: zaten sırayla çalışıyor.
- **Azalan getiri ayrı bir çarpan değildir.** Kadro içinde her kişi tam hızdadır; getiri, kartın diğer aşamaları sabit
  kaldığı için kendiliğinden azalır (yukarıdaki tablo). Kadro üstüne azalan hızla (0,5, 0,25…) ek kişi koymak da
  düşünüldü; bir haftalık tikte kadronun dolduğu durum seyrek (tek karta yığılma), sert tavan hem yeterli hem
  anlatması kolay.

### 3.5 Ekip, takım ve koordinasyon
- **Şirket çapında kayıp yoktur.** Eski kural (3 kişiden sonra her kişi %1, tavan %25; PM'in kapsadığı en çok 8 kişinin
  kaybı yarıya, yani tavanda %12,5'e iniyordu) kalkar.
- **Neden.** QSM, Scrum, Amazon ve Brooks'un söylediği kayıp aynı iş üzerindeki kalabalıktır (R4 §2.5). Ayrı işlerde
  çalışan ekipler arasında kayıp doğrusal ya da daha yavaştır; şirketler bunu ekibi bölerek aşar. Bizde "ekip" kartın
  kadrosudur ve sınır orada yaşar (§3.4). Software Inc.'in geliştiricisi de genel yavaşlamayı hata sayıyor (R1 §2.3).
- **Takım nesnesi yok.** Oyuncu takım kurmaz; kart sırası ve iş kutusu yeter. 50 kişide bu, Startup Company'nin
  mikro yönetim şikâyetinden kaçınır (R2 §4).
- **PM'in değeri.** Koordinasyon kaybını azaltmak yerine hazırlıktır (§3.7). Karar defterindeki "PM koordinasyon kaybını
  azaltır" maddesinin yerine geçer; açık soru 1.
- **Ölçeğin gerçek sınırları** (simülasyonda görülen): kart arzı, PM sayısı, tasarım ve test oranı. Hepsi plan ekranında
  boşta kişi ve darboğaz olarak görünür (§4.3).

### 3.6 Test ve hata
**Kartın hata yükü** H = 0,03 × S × tür × (1 − 0,25 × hazırlık) × yapım kalitesi

| Terim | Değer | Neden var |
|---|---|---|
| 0,03 | Puan başına hata yükü [ÇALIŞMA] | Kalibrasyon sabiti; A'nın E1 §9 hedeflerine göre seçilir (§5 A) |
| S | Kartın büyüklüğü (15 / 25 / 40, düzeltme 5 / 10) | Hata potansiyeli işin büyüklüğüyle orantılıdır (R4 §2.3 Jones) |
| tür | Özellik, istek, ücretli plan 1,0; düzeltme 0,3; araştırma 0 | Düzeltme yeni hata sokar ama azını (R4 §2.3 "kötü düzeltme"); araştırma kod yazmaz |
| hazırlık | 0 ile 1 arası, sprint başında sabitlenir (§3.7) | Hazır kart ×0,75 (Erdem'in kararı, 17 Ekim); hataların yaklaşık %45'i gereksinim ve tasarımdan doğar (R4 §2.3) |
| yapım kalitesi | Geliştirme aşamasını yapanların, yaptıkları payla ağırlıklı ortalaması: 1 ÷ √Y(Yazılım puanı); TİTİZ olanınki ×0,5 | İyi geliştirici az hata yazar (R3 §7.1 GDT kalite faktörü; R1 §2.1 "kalite = taban beceri"). Karekök, hızdaki farkın yarı ölçeği kadar etki verir |

**Yakalama** C = Σ (kişinin yaptığı test puanı ÷ kartın test ihtiyacı) × 0,40 × √Y(Test puanı), en çok 1.
- Test ihtiyacı sprint başındaki değerdir (hazırlık sonrası, B'nin "Testi kısalt" kesintisi öncesi). Test kısaltılırsa
  pay küçülür, yakalama düşer; B ayrı bir ihtimal yazmaz.
- Test ihtiyacı 0'a inmişse (B'nin kesintisiyle) C = 0. Testi yapabilecek kimse yoksa (kurucu Ar-Ge'de, ekipte Test
  kutusu olan yok) kart testte bekler ve plan ekranı "Testi yapacak kimse yok" yazar; bugünkü davranış budur.
- Uyum (0,7, 0,4) hızı keser, kaliteyi kesmez; kalite yalnız yıldızdır. Kurucu dahil herkesin gerçek Test yıldızı
  okunur (Erdem'in kararı, 17 Ekim).

| Testi yapan | Kurucu 0★ | 1★ | 2★ | 2,5★ | 3★ | 4★ | 5★ |
|---|---|---|---|---|---|---|---|
| Yakalama | %28 | %32 | %37 | %40 | %43 | %50 | %57 |

**Kaçan hata** E = H × (1 − C). Kapanışta kaçan hata sayısı, ortalaması E olan Poisson dağılımından deterministik
(kart ve sprint kimliğinden türeyen) bir çekilişle tam sayıya iner ve kartın hattına düşer (A'nın kuralı). v1.0'dan
önce A'nın bekleme listesinde durur.

**Ekranda.** Kartın ipucu "Hata ihtimali %35" yazar: en az bir hatanın kaçma ihtimali, 1 − e^(−E). Test satırı sprintin
toplamını tam sayıyla yazar: "Beklenen hata 2".
(inceleme) Kapanıştaki hata sayısı çekilişle bu ortalamadan farklı çıkar (2 beklenirken 0 ya da 4). Erdem'in "tahmin
sonuçla aynı çıkmak zorunda" kuralı ekranın verdiği her sayıya uygulanacağı için tam sayı bir vaat gibi okunmamalı:
ekran ihtimal ya da "ortalama" diliyle yazar, kesin sayı yazmaz. Metin maket turunda seçilir; §3.10'un "çekiliş
karşılaştırılmaz" kuralının ekrandaki karşılığı budur.

**K2 kart (25 puan), 2,5★ geliştirici, hazırlıksız:**

| Testi yapan | Yok | Kurucu 0★ | 1★ | 2★ | 3★ | 4★ | 5★ |
|---|---|---|---|---|---|---|---|
| Kaçan hata (E) | 0,75 | 0,54 | 0,51 | 0,47 | 0,43 | 0,38 | 0,33 |
| Hata ihtimali | %53 | %42 | %40 | %38 | %35 | %31 | %28 |

En iyi durum (hazır, 4★ geliştirici, 5★ testçi): K1 0,12 (%11), K2 0,20 (%18), K3 0,32 (%27).

**Küçük karta 5 testçi** (ön hesap; kurucu, 2 geliştirici, 3★, 2,5★, 2★, 4★, 1,5★ testçi):
- Tek K1 kart (2 / 10 / 3): testin kadrosu 1. 4★ testçi testi haftanın beşte birinde bitirir; öbür dördü boştadır.
  Hata ihtimali %20.
- Tek K3 test ağırlıklı kart (4 / 22 / 14): testin kadrosu 2. 4★ ve 3★ testçi birlikte test eder (8 ve 6 puan); kalite
  ikisinin ağırlıklı ortalaması; hata ihtimali %47.
- 60 haftalık akışta 5 testçili ekip 1 testçili ekipten haftada yalnız 4 puan fazla teslim eder, haftada 5,4 kişi-hafta
  boştadır. Plan ekranı bunu "4 kişi boşta" diye yazar.

**Bugünkü "yeni kod" terimi.** A'nın akışı bugün iki kaynaktan hata doğurur: taban (kullanım) ve yeni kod
(0,03 × yeni kodun eforu, 3 haftada söner). D'nin kaçan hatası "yeni kod" kaynağının kendisidir; o
terim silinir, taban kalır. Yoksa yeni kod iki kez sayılırdı (eski D_INCELEME bulgu 21).

- Neden var: test etkisi kartın büyüklüğüne ve testçinin becerisine bağlıysa 1 kişide de 50 kişide de aynı okunur;
  sabit "kart başı zar" büyük ve küçük kartı aynı sayardı. Hata ekiple orantılı büyür, düzeltme payı ekiple küçülür
  (§4.2), A'nın "sürekli hata sprinti yok" hedefi ölçekte bozulmaz.

### 3.7 Hazırlık: PM ve tasarımcı
- **Hazırlık işi** = 0,20 × S (K1 3, K2 5, K3 8 puan). Düzeltme ve araştırma kartı hazırlanmaz.
- **PM'in hazırlık hızı** = 10 × Y(Ürün puanı) × verim × saat × pay × huy. PM'in haftasında önce sprintteki araştırma
  kartları, sonra (işaretliyse) Test, kalan zaman hazırlığa gider.
- **Sıra:** sonraki sprint sütunu, sonra onaylı Çeyrek planlarının kartları, sonra PM'in kendi önerisi. Bir kartı aynı
  anda tek PM hazırlar; birden çok PM ayrı kartlara gider.
- **Fayda sprint başında sabitlenir:** hazırlık oranı r = yapılan ÷ gereken (0–1). Her aşamanın ihtiyacı × (1 − 0,20 r),
  hata yükü × (1 − 0,25 r). Tam hazır kart "Hazır" etiketi alır; yarım hazır kart yarım fayda alır.
- **Ortaya çıkan süreler** (tablo değil, sonuç; tek PM):

| Kart | 1★ PM | 3★ PM | 5★ PM |
|---|---|---|---|
| K1 (3 puan) | 0,5 hafta | 0,3 hafta | 0,2 hafta |
| K3 (8 puan) | 1,3 hafta | 0,7 hafta | 0,4 hafta |

- **PM oranı kendiliğinden çıkar:** bir hazırlık puanı sprintte bir puan kazandırır. 3★ PM haftada 12 hazırlık puanı
  üretir, bu da haftada yaklaşık 46 puanlık ekibi (orta seviyede ~5 kişi) besler; 5★ PM ~8 kişiyi. Gerçek şirketlerde
  5:1'den 11:1'e (R4 §2.5 Pave), Startup Company'de 3 / 5 / 8 (R2 §7.1).
- **Ön hesap:** 6 kişilik ekipte PM teslimi haftada 43'ten 55'e çıkarır, kart başı kaçan hatayı 0,77'den 0,57'ye
  indirir. 25 kişide tek PM kartların %24'ünü, üç PM %69'unu hazırlar.
- **PM'siz ekip:** hazırlık yok, ceza yok (Erdem'in kararı, 17 Ekim). Tek kurucunun hızı aynıdır.
- **Tasarımcı:** sprint kartlarının tasarım aşaması önce; sprintte tasarım işi kalmayınca sonraki sprint sütununun
  tasarımına geçer ("Tasarım %40" etiketi, bugünkü davranış). PM'in hazırlığına katılmaz (§2.6 gerekçesi; açık soru 3).
- **Sözcük:** PM'in işi "Hazırlık"tır. B yatırımcı hazırlığını kaldırdığı için çakışma kalmaz.
- Neden var: Erdem'in "PM önden gider" kuralına somut bir karşılık. Sürenin sabit gün değil işin büyüklüğü ve
  becerinin sonucu olması, büyük EA kartlarında da kuralın değişmeden çalışmasını sağlar.

### 3.8 Kurucu
- **Hız:** "Kurucu her alanda en az orta seviye (2,5★) biri kadar hızlı çalışır. Alanında daha iyiyse kendi yıldızıyla
  çalışır." Formülde Y = en az 1,0. Örnek: Yazılım 4★ kurucu geliştirmede haftada 15, tasarımda 10 puan.
- **Kalite:** Test ve Yazılım yıldızı gerçek değeriyle okunur (Test 0★ kurucunun yakalaması %28).
- **Sprint payı:** 1 − (o haftanın toplantı saati ÷ 40). Bu saat bugün zaten tutuluyor (Ar-Ge okuyor). (inceleme) C'nin
  güncel içeriği yenileme için kurucuya saat yazmıyor (`C_ICERIK_v2.md` §2.6.4, Erdem'in "mail üzerinden… counter offer"
  isteği); payı yalnız satış ve VC toplantıları düşürür. Yatırımcı hazırlığı B'de kalkıyor.
- **Atama sırası:** kurucu, ana alanı o aşama olan çalışandan sonra gelir. Uzman varken boşluğu kurucu doldurur.
- Neden var (taban): erken oyunda tek başına kurucu, oyuncunun seçtiği kurucu yapısı ne olursa olsun MVP'ye 6. haftada
  varmalı. Gerçek yıldız okunsaydı tasarımı ve testi 0★ olan kurucu MVP'ye 9. haftada varırdı.
- Neden var (kalite): kurucu hızlı test eder ama iyi test etmez; testçi almanın karşılığı budur.

### 3.9 Plan ekranı ve darboğaz bilgisi
Ekran her şeyi tek kaynaktan okur: sprint başında çalışan oynatma (§3.10). Gösterim Claude Design'da maketlenecek;
burada yalnız içerik ve kaba taslak var. Taslaklardaki sayılar örnektir [ÇALIŞMA]; ekip §6.10'daki S3 (6 kişi).

**Yön A · Aşama şeridi** (Azure DevOps aktivite kapasitesi, R5 §2.1).
```
BU SPRINT 7 · 2 hafta
TASARIM      ███████████░░░░░   17 iş · ekip 24     7 boş
GELİŞTİRME   ████████████████   46 iş · ekip 46
TEST         ████████████▓▓▓▓   26 iş · ekip 20     6 sonraki sprinte kalır
```
Güçlü: Erdem'in cümlesinin birebir karşılığı; yüzde gibi okunur, 3 ve 30 testçide aynı ekran. Zayıf: hangi kartın
yetişmeyeceğini söylemez.

**Yön B · Darboğaz cümlesi** (Startup Company "bottleneck alert", R5 §2.7).
```
Test yetişmiyor: Hesap Planı ve Stok Sayacı testte kalır. Testi yapan: Ayşe, Kurucu.
Mert 1. haftanın yarısında boşta: geliştirmeye açık kart yok.
Test satırı dolu. Yeni kart sonraki sprinte kalır.
```
(simülasyon sonrası) Üçüncü satır aşama tavanının (§3.11 a) cümlesidir; plan o sprintte kart almayı bu yüzden
bıraktıysa görünür.
Güçlü: nedeni ve kişiyi söyler. Zayıf: tek başına bırakılırsa Startup Company'deki gibi "ne eksik"i söyleyip derin
nedeni gizleyebilir (R5 §2.7). Kural: cümle gözlem yazar, öneri yazmaz ("testçi al" yazmaz).

**Yön C · Kart zinciri** (Gantt benzeri; referans yok, R5 §7).
```
                  1. hafta          2. hafta       │ sonraki
Toplu Fatura      [Tas][Gel····][Test]             │
Hesap Planı             [Tas][Gel··········][Test··│··]
```
Güçlü: "bu iş yapılır ama testi yetişmez"i kart başına gösterir; aşama sırasıyla doğal. Zayıf: kart çoğalınca kalabalık.

**Yön D · Kişi yük şeridi** (GDT çalışan yük çubuğu, Startup Company çalışan durumu; R5 §8.1, §8.3).
```
Kurucu ████████ Test   Ayşe ████████ Test   Deniz ████████ Gel   Mert ████░░░░ boşta 0,5 hf
```
Güçlü: boştaki kişiyi gösterir. Zayıf: 50 kişide sığmaz; aşama başına özetlenmesi gerekir.

**Öneri.** A ve B ekranda her zaman; C kartın üstüne gelince; D avatar satırında (bugün avatar satırı var). Linear'ın
"hızdan türeyen kapasite kadranı" (R5 §2.3) alınmaz: bizim tahminimiz sonucun kendisi, ayrı bir tahmine gerek yok.

(inceleme) **Darboğaz hangi aşamadır: ölçü düzeltmesi.** §4 ve `D_SIM.md` tablolarının "Darboğaz" sütunu, devreden
kartların aşamada kalan işini mutlak puanla toplar (§6.8). Geliştirme her kartta en büyük pay olduğu için bu ölçü hemen
her ekipte "Geliştirme" der; oysa marjinal getiri başka yeri gösteriyor: 50 kişiye 3★ geliştirici +2,5, testçi +7,
tasarımcı +16,5 puan/hafta (`D_SIM.md` §15.5). İnceleme ölçümü (aynı betik, 5 tohum, kalan iş ÷ o aşamanın kapasitesi):
S2, S4, S5 ve S6'da darboğaz Test, S3'te Geliştirme, S11b'de Tasarım (mutlak ölçü dördünde de "Geliştirme" diyordu).
Ekran "Geliştirme yetişmiyor" der de oyuncu geliştirici alırsa teslim neredeyse artmaz; bu, Erdem'in "oyuncu optimize
etmeye çalışmalı" isteğini boşa çıkarır. Kural: darboğaz satırı ve cümlesi aşama yükünü o aşamanın kapasitesine oranla
okur (Yön A'nın çubuğu zaten "iş ÷ ekip"tir). İki ölçü de S6'da tasarımcının büyük getirisini tam yakalamıyor (önden
tasarım tasarım işini sonraki sprinte taşıyor); D7'nin ölçümü darboğaz satırını marjinal getiriyle karşılaştırır.

**Kartın üstünde.**
```
┌ Hesap Planı                                     HAZIR ┐
│ Tasarım 2 · Geliştirme 10 · Test 7                     │
│ Ece ▸ Deniz, Mert ▸ Ayşe              test 2. haftada  │
└───────────────────────────────────────────────────────┘
ipucu: Hazır · 25 → 20 puan · hata ihtimali %36 → %29 · geliştirme en çok 2 kişi
```
- Uymayan biri test edecekse kartta "TEST ×0,4" etiketi; ipucu "Selin (Ürün yöneticisi) testte ×0,4 hızla çalışır,
  haftada 2 moral kaybeder." Uymayan atamanın bedeli atama anında görünür (karar defteri).
- Ekranda ondalık yok: yapılan aşağı, kalan yukarı yuvarlanır; yüzde tam sayıdır (eski D_INCELEME bulgu 10).

### 3.10 Tahmin = sonuç nasıl korunur
- Plan ekranı, "+" düğmesi, lider ve PM önerisi, MVP tahmini ve kapanış aynı oynatma fonksiyonunu çalıştırır (bugün
  de öyle).
- **Sprint başında sabitlenenler:** kişilerin aşama hızları (yıldız, uyum, iş kutusu, pay, huy, kurucu tabanı),
  kartların hazırlık oranı, ihtiyacı, kadrosu ve test ihtiyacı.
- **Haftadan haftaya:** kurucunun toplantı payı yalnız içinde bulunulan haftaya uygulanır; plan bilinmeyen toplantıyı 0
  sayar (eski D_INCELEME bulgu 4).
- **Kapanışta yazılanlar:** uymayan işin morali, kaçan hatanın tam sayısı. Sprint içinde verim değişmez.
- **Kaçan hata:** E, oynatmanın kim ne yaptı kaydından hesaplanır; plan ve kapanış aynı E'yi bulur. Tam sayıya
  çeviren çekiliş karşılaştırılmaz.
- **Adlı uyuşmazlık nedenleri:** B'nin karar kâğıdı, işe alım ya da ayrılık, izin ve eğitim, kurucu toplantısı.
  Sprint probu bunları adıyla geçirir, adsız uyuşmazlıkta 1 ile çıkar (bugünkü kural).
- Probun tahmin ve kapanış satırlarına kart başına E ve aşama başına iş eklenir.

### 3.11 Sprint alımı: aşama tavanı ve düzeltme payı tavanı (simülasyon sonrası)
İki kural da planın sprinte kart alırken uyguladığı sınırdır; hafta oynatmasına, hıza ve hataya dokunmaz. Plan sprint
başında kurulduğu için tahmin = sonuç korunur (simülasyonda en büyük fark 3,6e-15).

**(a) Aşama tavanı.** Plan sprinte kart eklerken bugünkü toplam tavanın (sprintin işi ≤ 1,25 × kapasite) yanında her
aşama satırını ayrıca sınar. Yeni kartın işi olan bir aşamada, sprintteki kartların o aşamada kalan işi ile yeni kartın
işinin toplamı ekibin o aşamadaki kapasitesinin 2 katını aşıyorsa plan yeni kart almaz.
- **Aşama kapasitesi** = o aşamada çalışabilen herkesin o aşamadaki hızı × sprint haftası. Birden çok aşamada çalışabilen
  kişi her birinde sayılır (tek kurucu her satırda 20 puan); bu yüzden tek kurucuda aşama tavanı toplam tavandan önce
  hiç bağlamaz.
- **Neden var:** simülasyonda 47 kişilik ekibe bir geliştirici eklemek teslimi haftada 470'ten 467'ye düşürdü
  (`D_SIM.md` §12 K1). Toplam kapasite her kişinin en iyi aşamasını toplar. Darboğaz olmayan geliştirme aşamasına kişi
  ekleyince toplam tavan yükseliyor, plan daha çok kart alıyor (sprintteki kart 58,5 → 62,4), kartlar test satırında
  birikiyor ve kartın bekleme süresi 4,45'ten 4,78 haftaya uzuyordu. Aşama tavanı alımı darboğaz satırına bağlar:
  darboğaz olmayan aşamaya kişi eklemek artık yığını büyütmez.
- **Neden 2 kat:** kart aşamalarından sırayla geçtiği için sağlıklı ekiplerde ortalama iki sprint sürer (`D_SIM.md` §10:
  bekleme 3,5 hafta). Bir satırda ekibin iki sprintte bitirebileceğinden fazla iş varsa en az bir kart üçüncü sprinte
  kalır. Denenen öbür değerler: 1,25 kat S2, S4, S5 ve S6'da teslimi %4 ile %9 düşürdü (S2 22,5 → 20,5; S6 496,5 → 477);
  1,5 kat S2'de %3 düşürdü ve 48. kişide −1,0 bıraktı (tolerans sınırında). 2 katla S1–S6'nın teslimi, hatası ve
  bekleme süresi birebir aynı kaldı, 48. kişinin farkı 0'a çıktı. [ÇALIŞMA] onay bekliyor.
- **Neden ölçekte kırılmaz:** tavan ekibin kendi aşama kapasitesinin oranıdır; 3 kişide de 50 kişide de "o aşamanın iki
  sprintlik işi" demektir. Sabit kart sayısı ya da kişi başı pay yoktur.
- **Oyuncu nerede görür:** aşama şeridinin satırı (§3.9 Yön A) zaten "iş · ekip" yazar; tavan o satırın iki sprintlik
  işle dolmasıdır. Plan kart almayı bıraktığında darboğaz cümlesi (Yön B) nedenini yazar, örnek: "Test satırı dolu.
  Yeni kart sonraki sprinte kalır." Oyuncu "+" ile kart eklemek isterse aynı satır ve aynı cümle görünür.
- **Yan etki (ölçüldü):** testi yetişmeyen bileşimlerde yığın küçülür, teslim düşmez. Testçisiz 25 kişide (S11)
  sprintteki kart 64,5'ten 5,9'a, kartın bekleme süresi 27,7'den 4,3 haftaya iner; teslim 41'den 42'ye çıkar, darboğaz
  yine Test. Boşta süre 17,2'den 20,8 kişi-hafta/haftaya çıkar: boştaki kişi artık birikmiş kartların değil dolu test
  satırının arkasında görünür. 145 senaryonun 32'sinde kural en az bir kez bağladı; S1–S6 ve dengeli ekiplerin hiçbirinde
  bağlamadı.

**(b) Düzeltme payı tavanı.** Plan açık hatalı hatların düzeltme kartlarını (en çok hatalı hat önce) sprinte
kendiliğinden alırken, devreden ve yeni düzeltme kartlarının toplam işi kapasitenin yarısını aşacaksa o kartı almaz.
Kart sonraki sprintin sütununda bekler, hattın hatası açık kalır. Sprintte henüz düzeltme kartı yoksa ilk kart her zaman
girer, kapasitenin yarısından büyük olsa da.
- Kural lider önerisinin ve botun düzeltme kollarının kuralıdır. Oyuncu kalan kartı elle ekleyebilir; o zaman hata
  sprinti oyuncunun bilerek seçtiği şeydir.
- **Neden var:** tek kurucuda kapasite 20 puan. Bir 10 puanlık ve bir 5 puanlık düzeltme kartı birlikte payı 0,75
  yapıyor ve sprint hata sprintine dönüyordu (`D_SIM.md` §12 K2: geç pencerede 28/497 = %5,6, hedef ≤ %5; 20 tohumun
  2'sinde üst üste iki hata sprinti). A'nın hedefi "sürekli hata sprinti yok"tur (Erdem, 16 Ekim: "Oyuncuyu sürekli bug
  sprint koşarken görmeyelim"); kural planın kendi önerisini bu hedefe bağlar.
- **Neden 0,5:** A'nın "hata sprinti" tanımıdır (düzeltme payı %50'nin üstü). Yeni bir sayı değildir.
- **Neden ölçekte kırılmaz:** kapasitenin oranıdır. 2 ve daha büyük ekiplerde düzeltme payı zaten en çok %12 olduğu için
  kural neredeyse hiç bağlamaz: 145 senaryonun yalnız 3'ünde devreye girdi (S1 ve eğrinin 1 ile 2 kişilik adımları).
- **Bedel (ölçüldü, tek kurucu):** ertelenen hat bir sprint daha açık kalır. Açık hata medyanı 6,0'dan 6,5'e, pencere
  maksimumu 11'den 11,5'e çıkar; son 20 haftanın eğimi +0,07 hata/hafta (sınır 0,2). Hata sprinti erken 13/218'den
  0/221'e, geç 28/497'den 0/506'ya iner; üst üste hata sprinti kalmaz. Teslim 6,2'den 6,4'e çıkar, MVP 6. haftada kalır.
- **Oyuncu nerede görür:** ertelenen kart sonraki sprint sütununda hata sayısıyla durur ve ipucu nedenini yazar, örnek:
  "Bu sprintin yarısı zaten düzeltmeye gidiyor." (metin önerisi, TR/EN onay bekliyor). Düzeltme payı plan ekranında
  yüzde olarak görünür.
- **A'ya dokunduğu yer:** A'nın lider önerisi "Öncelikli" kartları (5 ve üstü hata) zorunlu listesine alıyor
  (`sprint_catalog.gd`, `_suggest`). Tek kurucuda iki Öncelikli hat aynı anda açılırsa ikincisi bu kuralla bir sprint
  bekler. Bu A'nın kuralında bir değişikliktir; onay bekliyor (§5 A, §7).

---

## 4. Ölçek güvencesi

### 4.1 Her sabit neden ölçekte kırılmıyor
| Sabit | Değer | Neye bağlı | Neden kırılmaz |
|---|---|---|---|
| Puan tabanı | 10 | Kişinin kendisi | Toplam kişi sayısıyla doğrusal; çarpan kişiye ait |
| Yıldız eğrisi | 0,64 … 2,0 | Kişinin alanı | Aynı |
| Uyum | 1,0 / 0,7 / 0,4 | Kişi × aşama | Aynı |
| Kart büyüklüğü ve profil | 15 / 25 / 40 | Kartın kendisi | Ekipten bağımsız |
| Kadro dilimi | 8 puan | Aşamanın ihtiyacı | Tavan iş büyüklüğünde; 50 kişilik şirket aynı kartta 3 kişilik şirketle aynı tavanı görür |
| Hata yükü | 0,03 / puan | Teslim edilen iş | Hata işle orantılı büyür; düzeltme eforu hat başına en çok 10 olduğu için düzeltme payı ekip büyüdükçe küçülür |
| Yakalama | 0,40 × √Y | Testi yapanın yıldızı | Kart başına; kişi sayısıyla birikmez; en çok %57 |
| Hazırlık oranı | 0,20 | Kartın büyüklüğü | PM oranı kendiliğinden çıkar; sabit "PM başına N kişi" yok |
| Hazır faydası | −%20 iş, ×0,75 hata | Kartın kendisi | Aynı |
| Kurucu tabanı | Y ≥ 1,0 | Tek kişi | Ekip büyüdükçe kurucunun payı küçülür |
| Uymayan moral | −2 / hafta | Kişinin kendisi | Aynı |
| Şirket çapı kayıp | yok | | Kişi başı yüzde olmadığı için 10 kişilik aynı rol çökmez |
| Aşama tavanı (simülasyon sonrası) | aşama kapasitesinin 2 katı | Ekibin o aşamadaki hızı | Ekibin kendi oranı; darboğaz olmayan aşamaya kişi eklemek yığını büyütmez (§3.11 a) |
| Düzeltme payı tavanı (simülasyon sonrası) | kapasitenin yarısı; ilk kart her zaman girer | Kapasite | Oran; 2 ve daha büyük ekipte pay zaten en çok %12 olduğu için bağlamaz (§3.11 b) |

### 4.2 1, 3, 6, 12, 25 ve 50 kişide beklenen davranış
Ön hesap, 5 tohum, 21–60. haftalar. Teslim = biten özellik kartlarının hazırlıksız büyüklüğü (PM'in kazancı dahil).
Ekipler §6.10'da.

| Ekip | Teslim / hafta | Kişi başı | Kart / sprint | Kart başı kaçan hata | Açık hata (medyan) | Düzeltme payı | Hata sprinti | MVP haftası | Darboğaz | Hazır kart |
|---|---|---|---|---|---|---|---|---|---|---|
| S1 · 1 | 6,1 | 6,1 | 0,4 | 0,49 | 6,5 | %25 | 1 / 28; (simülasyon sonrası) 0 / 506 | 6 | Her aşama kurucuda | yok |
| S2 · 3 | 21,9 | 7,3 | 1,2 | 0,78 | 8 | %8 | 0 | 4 | Geliştirme | yok |
| S3 · 6 | 55 | 9,2 | 2,8 | 0,57 | 8 | %10 | 0 | 4 | Geliştirme | %100 |
| S4 · 12 | 116 | 9,7 | 5,8 | 0,57 | 8,5 | %5 | 0 | 2 | Geliştirme | %87 |
| S5 · 25 | 257 | 10,3 | 12,9 | 0,57 | 13,5 | %4 | 0 | 2 | Geliştirme | %69 |
| S6 · 50 | 498 | 10,0 | 24,9 | 0,57 | 19 | %3 | 0 | 2 | Geliştirme | %64 |

- Kişi başı teslim 6 ile 10,5 arasında. Tek kurucunun düşüklüğü düzeltme kartlarından ve tek kişinin her aşamayı
  sırayla yapmasından; 25 ve 50 kişide yükselme PM'in hazırlık kazancından.
- Tek kurucunun düzeltme payı %25: 20 puanlık sprintte 5 puanlık düzeltme kartı. A bunu yapısal saydı (RAPOR_A §1
  madde 2, öneri (a): erken dönemde ≤ %50). D bu oranı değiştirmez.
- (simülasyon sonrası) 20 tohumda tek kurucunun hata sprinti oranı geç pencerede %5,6 çıktı (hedef ≤ %5); sebep bir
  10 ve bir 5 puanlık düzeltme kartının aynı sprinte girmesi. Düzeltme payı tavanıyla (§3.11 b) 0 / 506; medyan pay
  yine %25.
- Açık hata ekiple büyür (50 kişide medyan 19), düzeltme payı küçülür. A'nın itibar eşiği (4 hafta üst üste 30
  açık hata) mutlak bir sayı olduğu için 50 kişide düzenli düzelten oyuncuya yaklaşır: §5 A.
- MVP haftası 2–4: tam ekiple 0. haftadan başlayan yapay bir senaryo; oyunda ekip MVP'den sonra büyür.
- (inceleme) "Darboğaz" sütunu mutlak kalan işle ölçüldü; kapasiteye oranla S2, S4, S5 ve S6'da Test çıkıyor (§3.9 sonu).
- (inceleme) Açık hata sütunu A'nın mutlak hedeflerini 12 kişiden sonra aşıyor (A'nın B2B geç dönem hedefi sürüm anında
  ≤ 8, sprint sonu tepesi ≤ 16; `D_SIM.md` §3.2: 12 kişide 9,2 / 16, 25 kişide 13 / 20, 50 kişide 19 / 28). §5 A.
- (inceleme) 25 ve 50 kişinin sonuçları sonsuz kart akışına dayanır (§6.4: K3'ten sonra 40 puanlık kartlar sürer). Oyunun
  kataloğunda K3'ten sonra kart yoktur; bu sonuçlar EA için içerik koşuluyla geçerlidir (§5 E).

### 4.3 Uç bileşimler
| Senaryo | Teslim / hafta | Boşta (kişi-hafta / hafta) | Darboğaz | Okunuş |
|---|---|---|---|---|
| S7 · küçük kartlara 5 testçi (8 kişi) | 25,9 | 5,4 | Geliştirme | 1 testçili aynı ekipten (22,1) yalnız 4 fazla; 4 testçi çoğunlukla boşta |
| S8 · aynı rolde 10 geliştirici (11 kişi) | 19,4 | 9,1 | Test | Tasarımı ve testi yalnız kurucu yapıyor; Test kutusu işaretlenince test açılır |
| S9a · hepsi testçi, yalnız Test kutusu | 10,4 | 7,8 | Geliştirme | Yapımı yalnız kurucu yapıyor |
| S9b · hepsi testçi, Yapım ve Test | 22,6 | 6,4 | Geliştirme | Testçi ikincil hızla geliştirir; tasarım yalnız kurucuda |
| S10 · PM'siz 30 kişi | 307 | 0,3 | Geliştirme | Çökmez: kişi başı 10,2. Bedeli hatada: kart başı kaçan hata 0,67 (PM'li 50 kişide 0,57). Hazırlık yok, ceza yok |
| S11 · 2 PM, 2 tasarımcı, 20 geliştirici, 0 testçi | 41 | 17,2 | Test | Testi yalnız kurucu yapıyor; 17 kişi boşta. "Testleri yetişmez" senaryosunun kendisi |
| S11b · aynı, geliştiricilerde Test kutusu | 160 | 7,9 | Geliştirme; (inceleme) kapasiteye oranla Tasarım | Test açılır; tasarım iki kişide kaldığı için hâlâ 8 kişi boşta |
| S12 · tek karta 12 kişi | 11,8 | 10,7 | yok | Kart kadrosu dolu, öbürleri boşta; teslim tek kartın süresiyle sınırlı |
| S3 + PM'in Test kutusu | 50 | 0,5 | Geliştirme | PM testte ×0,4 çalışıyor, hazırlık %70'e iniyor; teslim 55'ten 50'ye; PM 60 haftada ~76 moral kaybeder |

Hiçbirinde model çökmüyor ya da patlamıyor: kırık bileşim boşta kişi ve darboğaz olarak görünüyor. Oyuncunun düzeltme
yolu her birinde bir iş kutusu ya da bir işe alım.

### 4.4 Kişi eklemenin marjinal getirisi
Ekibe bir kişi eklenince teslimdeki değişim (haftada puan; parantezde kart başı kaçan hata).

| Taban | +3★ geliştirici | +3★ testçi | +3★ tasarımcı | +3★ PM | +1★ geliştirici |
|---|---|---|---|---|---|
| S2 · 3 | +12,1 (0,80) | +9,1 (0,70) | +0,6 (0,77) | +7,4 (0,60) | +8,8 (0,88) |
| S3 · 6 | +12,0 (0,59) | +6,0 (0,54) | 0 (0,57) | 0 (0,57) | +9,0 (0,62) |
| S4 · 12 | +4,0 (0,57) | +5,0 (0,55) | 0 (0,57) | +3,0 (0,55) | +2,0 (0,59) |
| S5 · 25 | +2,0 (0,57) | +5,0 (0,56) | +4,0 (0,57) | +12,0 (0,54) | +2,0 (0,58) |
| S6 · 50 | 0 (0,56) | +7,0 (0,56) | +14,0 (0,57) | +12,0 (0,55) | −1,0 (0,57) |

- Tek bir eksi değer var: 50 kişiye 1★ geliştirici −1 (teslimin %0,2'si). Nedeni zaman sıralı atamanın bilinen bir
  yan etkisi: aşama açıldığı an boşta olan yavaş kişi kadroyu doldurur, bir an sonra boşalan hızlı kişi o karta
  giremez. Etki küçük ve gerçek hayatta da olur; kırılma ölçütündeki −1 toleransının içinde. D2'nin ölçümü bunu ayrıca
  izler; büyürse kural "kadro doluyken boşalan daha hızlı kişi yavaşla yer değiştirir" olur.
- (simülasyon sonrası) 20 tohumda bu hücre +1,0 çıktı; yerine iki başka bulgu geldi (`D_SIM.md` §4, §5, §15):
  - Kişi ekleme eğrisinde 48. kişi (geliştirici) −3,0; 20 tohumun 16'sında. Sebep atama değil sprint alımıydı; aşama
    tavanıyla (§3.11 a) fark 0,0, tohumların 7'sinde aşağı, 9'unda yukarı (gürültü). Eğrinin 49 adımının hiçbiri eksi değil.
  - 12 kişiye 3★ tasarımcı −1,0, toleransın tam sınırında ve sistematik (20 tohumun 16'sında). Aşama tavanı bu hücreyi
    değiştirmedi; tavan bu ekipte hiç bağlamıyor. Ek deney (10 tohum): iki ekibe aynı planlama kapasitesi verilince fark
    yine −1, tasarımcıların önden tasarımı kapatılınca tasarımcı eklemek +11 getiriyor ve hiçbir tohumda düşürmüyor.
    Kayıp önden tasarım kuralının içinde; ölçüt sınırı içinde kaldığı için bu turda değiştirilmedi, D2'nin ölçümü izler.
- Öbür bütün eklemelerin getirisi sıfır ya da artı.
- Sıfır getiri, o rolün darboğaz olmadığını söyler (6 kişide ikinci PM: kartların hepsi zaten hazır). Plan ekranı bunu
  aşama şeridinde boş kapasite olarak gösterir.
- 1★ geliştirici hız getirir ama kart başı hatayı artırır (0,57 → 0,59 ve 0,62): ucuz kadronun bedeli hatadır.

---

## 5. Bağlar

### A · hatalar (koda girdi, `26b60da`)
- **Hata deposu:** kaçan hata `ProductState.add_bugs(kartın hattı, n)` ile yazılır; v1.0'dan önce A'nın
  `pending_faulty` listesinde bekler. Kartın `faulty` bayrağı, `faulty_chance` (0,4) ve `_work`'teki "uymayan test
  → hatalı" dalı silinir. A'nın "hatalı kapanan kartın hatası kendi hattına" kuralı korunur, yalnız sayı 1 değil
  Poisson çekilişidir.
- **Yeni kod terimi:** `SupportSystem.reports_per_day`'in `INFLOW_NEWCODE_COEF × yeni kod` terimi ve `INFLOW_TAU`,
  `mvp_new_code_effort` bayrağı silinir (okuyucusu yalnız bu terim). Taban (kullanım) aynen kalır. A sabiti olduğu için
  onay bekliyor.
- **Düzeltme kartı eforu:** A'nın 1–4 hata 1 puan, 5+ hata 2 puan kuralı ×5 olur (5 ve 10); aşama ihtiyacı 0 / 3 / 2 ve
  0 / 7 / 3. Öncelikli eşiği (5 hata) değişmez. Düzeltme kartının kendi kaçışı, A'nın hattı sıfırlamasından sonra yazılır
  (sıra bugün doğru, korunur).
- **"Sürekli hata sprinti yok":** düzeltme payı = sprint başındaki düzeltme işi ÷ kapasite (A'nın tanımı). Hata teslimle
  orantılı, düzeltme eforu hat başına en çok 10 olduğu için pay ekip büyüdükçe küçülür. Ön hesap (medyan):

  | Ekip | MVP'den sonraki ilk 20 hafta | 21–60. hafta | Hata sprinti |
  |---|---|---|---|
  | Tek kurucu | %25 | %25 | erken 50 sprintte 2 (5 tohum), geç 28'de 1; üst üste yok. (simülasyon sonrası) 20 tohumda erken 13/218, geç 28/497 (%5,6), 2 tohumda üst üste; düzeltme payı tavanıyla erken 0/221, geç 0/506 |
  | 3 kişi | %8 | %8 | yok |
  | 6 kişi | %5 | %10 | yok |
  | 12 kişi | %4 | %5 | yok |
  | 25 / 50 kişi | | %4 / %3 | yok |

  A'nın E1 §9 hedefleri (erken ≤ %30, geç ≤ %20; hata sprinti erken ≤ %15, geç ≤ %5; üst üste iki hata sprinti yok)
  her ekipte tutuyor. Tek kurucunun %25'i A'nın yapısal saydığı sınırdır (20 puanlık sprintte 5 puanlık kart).
  (simülasyon sonrası) 20 tohumda tek kurucu geç pencerede tutmadı (%5,6). Düzeltme payı tavanıyla (§3.11 b) bütün
  ekiplerde tutuyor.
- **Düzeltme payı tavanı ve Öncelikli kartlar (simülasyon sonrası):** A'nın lider önerisi Öncelikli kartları zorunlu
  alır. §3.11 (b) ile zorunlu liste de kapasitenin yarısında durur; ilk kart her zaman girer. Pratikte yalnız tek
  kurucuda iki Öncelikli hat aynı sprintte açılınca fark eder. A'nın kuralında değişiklik, onay bekliyor. Botun
  `fix_due` ve `fix_worst` kolları aynı sınırı okur; A'nın kol tanımı ("bütün hatların kartlarını alır") buna göre
  okunur.
- **Haftalık yeni hata:** 12 kişilik ekipte kaçan hata haftada ~1,7 + taban ~1,0 = ~2,7; A'nın geç dönem hedefi
  (B2B ≤ 4, B2C ≤ 3) içinde. Hata yükü sabiti (0,03) D'nin ölçüm diliminde A'nın bot kollarıyla seçilir.
- **Ölçekte kırılma riski (A'ya not):** itibar kuralı mutlak 30 açık hataya bakıyor (`NEGLECT_BUGS`). Hata ekiple
  büyüdüğü için 50 kişilik, düzenli düzelten bir ekip eşiğe yaklaşır (ön hesap medyanı 19). Önerim: eşik canlı hat
  sayısına bağlansın (örnek [ÇALIŞMA]: canlı hat başına 3). Bu A'nın sabiti; D değiştirmez, ölçüm diliminde raporlar.
- (inceleme) **A'nın öbür hedefleri de mutlak sayı.** A'nın E1 §9 tablosu (`fix_due` kolu, B2B geç dönem): haftada yeni
  hata ≤ 4, sürüm anında açık hata ≤ 8, sprint sonu tepesi ≤ 16. D'nin modelinde düzenli düzelten ekip bunları 12 ile 25
  kişi arasında aşar: 25 kişide haftada ~4,7 yeni hata (12,8 kart/sprint × 0,57 ÷ 2 + taban ~1), açık hata medyanı 13 ve
  tepe 20; 50 kişide ~8 / 19 / 28 (`D_SIM.md` §3.2). Hedefler 1–6 kişilik bot için doğru ama Erdem'in 1–50 kişi kuralını
  geçmiyor. Önerim: açık hata hedefleri ve itibar eşiği canlı hat başına, haftalık yeni hata hedefi teslim edilen işe
  oranlansın [ÇALIŞMA]. A'nın sabiti; açık soru 5.
- **Görevler matrisi:** A K1 matrisi sprint payına bağladı. D onu aşama kapısı da yapar (§3.3). Eski kayıtta Test
  kutusu olmayan geliştirici artık test etmez; ilk plan ekranı bunu darboğaz satırıyla gösterir.

### B · olaylar (koda yeni başlıyor)
- **Bedeli ödeyen kişiler:** B'nin "olayın hattında, koşan sprintte kartı olan geliştirici ve testçiler" kuralı D'nin
  atamasından okunur: kartın şu anki ve biten aşamalarında çalışanlar. Bugünkü `assignees` alanı aşama bazında tutulur.
  (inceleme) B'nin kuralı geliştirici ve testçi der; D'nin aşama kaydı tasarımcıyı ve kurucuyu da tutar. Bedeli ödeyen
  küme yalnız Geliştirme ve Test aşamalarında çalışanlardır (kurucu bu aşamalarda çalıştıysa dahil); tasarım aşamasının
  kişileri girmez. B'nin ikinci basamağı (Görevler matrisinde Yapım ya da Test işi olan herkes) değişmez.
- **Kâğıdın konuşmacısı:** "o kartta o aşamada çalışan kişi" (B §10) aynı kaynaktan; PM kâğıdı ekipteki PM'den.
- **"Testi kısalt":** test ihtiyacını düşürür; yakalamanın paydası sprint başındaki test ihtiyacı olduğu için hata
  ihtimali kendiliğinden artar. B'nin geçici sabiti (%15) D gelince kalkar. Kesinti ihtiyaca değil ayrı bir alana yazılır.
- **Karar fiillerinin miktarları:** `sprint_card_effort` ve `sprint_card_progress` miktarları ×5 olur ve fiile isteğe
  bağlı bir aşama alanı eklenir; alan yoksa miktar kartın o anki aşamasına düşer. Dış geliştiricinin puan başı ücreti
  ×5 ölçekte beşte birine iner.
- **"Sürüm sonrası bozulma":** kartın E'sini ve kapanıştaki kaçan hata sayısını okur.
- **"Kendin bak" ve kurucu verimi:** `productivity_mod` olarak yazılır; D verimi zaten okur.
- **"Testi sen yap" (kurucu):** kurucunun gerçek Test yıldızı okunur. Test 0★ kurucu %28 yakalar, 2★ testçi %37. Seçenek
  ancak kurucunun yakalaması ekiptekinden yüksekken açılmalı ya da başka bir karşılık taşımalı (eski D_INCELEME bulgu 16).
- **Yatırımcı hazırlığı** B'de kalkıyor; kurucu payındaki "hazırlık haftası 0" terimi düşer, "Hazırlık" sözcüğü PM'e
  kalır.

### C · ürün sayfası ve B2B hesaplar
- **Kurucu saati:** (inceleme) `C_ICERIK_v2.md` §2.6.4 yenileme için kurucuya saat yazmıyor; D'ye etkisi yoktur.
- (inceleme) **Satış yıldızı ve satışçı yükü:** C, yenilemede satışçının ve kurucunun Satış yıldızını okur ve satışçıya
  hesap başına 0,25 hafta yenileme yükü yazar; "D'nin satış masası modeline uymalıdır" der (`C_ICERIK_v2.md` §3 D). D'nin
  modeli yalnız sprintin dört alanını (Ürün, Tasarım, Yazılım, Test) kapsar; satış masası yoktur. Satış yıldızı aynı
  0–10 puan ölçeğini kullanır; satışçının yükü C'nin kuralıdır ve sprint kapasitesine girmez. C'nin cümlesi buna göre
  okunmalı.
- **Ürün penceresi:** C pencereyi üç kâğıda bölüyor; D'nin plan ekranı C'den sonra Sprint kâğıdıdır, dosya adları
  uygulamadan önce tazelenir.
- **Kararlılığın görünmemesi** (Erdem'in C yorumu): X'in konusu. D'nin katkısı açık hata ve kartın hata ihtimalidir.

### X · eksenler
- D eksen okumaz; yalnız hattın **iş profili** alanını okur (X §8.3 sözleşmesi). (b) ya da (c) seçilirse D'nin
  sayıları değişmez. Profil alanı X'in fazında ya da D'nin ilk adımında eklenir (~2 saat).
- X §6.5b ile uyumlu: beceri ürün seviyesini çarpmaz, hızı ve hatayı belirler.

### E · pazaryeri
- E'nin yeni hatları iş profili ve kademe büyüklüğü taşır; D'nin tabloları değişmez.
- `--sprint-probe` bugün not uygulamasıyla koşuyor; E not ve video ürünlerini siliyor. D'nin ölçüm dilimi E'den önceyse
  ERP ve not uygulamasıyla, sonraysa pazaryeriyle koşar.
- EA'da sonsuz koşu için kart arzı (yeni hat ve kademe) gerekir; 50 kişilik ekip 60 haftada bugünkü kataloğu tüketir.
  Bu D'nin değil içerik ve E'nin konusu, ama D'nin ölçeğini sınırlayan ilk şey budur.

### Kayıt şeması
- A 16'yı kullandı; B ve C şemayı artırmıyor. D 16 → 17: kartta `need` (3 sayı), `kadro` (3 sayı), `ready` (0–1),
  `test_need0`, aşama bazında `assignees` ve `log` (kişi başına aşama işi); üründe `prep` (kart → hazırlık puanı).
  Kartın `faulty`, `shares` ve `effort_mod` alanları gider.
- Göç: saklı kartın ihtiyacı tablodan kurulur, eski ilerleme aşama payıyla taşınır, ×5. E eski kayıtları kapatırsa
  (E'nin sorusu) D'nin göçü yalnız D ile E arasında yaşar.

---

## 6. Simülasyon tanımı
Bu bölüm simülasyonu yazacak ajan içindir. Tek anlamlı olmak için her kural sayıyla yazıldı. Oyunun kodu değil,
modelin kendisidir; sonuçlar §4'teki ön hesapla aynı büyüklükte çıkmalıdır.

### 6.1 Kapsam
- Sprint motoru, hazırlık, hata yükü ve kaçışı, düzeltme kartları, taban hata akışı.
- Dışarıda: olaylar, satış, para, moral ve verimin hıza dönüşü (verim = 1, saat = 8), izin, eğitim, işe alım
  sırasında ekip değişikliği (ekip senaryo boyunca sabit), araştırma kartı ve ücretli plan.

### 6.2 Sabitler
| Ad | Değer |
|---|---|
| `BASE` | 10 |
| `Y(s)` | 0,5 + 0,05·s + 0,01·s² |
| `U` | ana 1,0 · ikincil 0,7 · uymayan 0,4 · kurucu 1,0 |
| `FOUNDER_FLOOR` | kurucunun hızında Y = max(1,0; Y(s)) |
| `SIZE` | K1 15 · K2 25 · K3 40 (K3'ten sonraki kartlar da 40) |
| `NEED` | §3.2 tablosu, birebir |
| `FIX_NEED` | 5 → [0, 3, 2] · 10 → [0, 7, 3]; 1–4 hata 5, 5+ hata 10 |
| `SLICE` | 8 (kadro = ⌈ihtiyaç ÷ 8⌉, en az 1) |
| `H0` | 0,03 |
| `KIND_H` | özellik 1,0 · düzeltme 0,3 |
| `C_REF` | 0,40 |
| `PREP_RATIO` | 0,20 |
| `READY_CUT` | 0,20 (ihtiyaç × (1 − 0,20 r)) |
| `READY_H` | 0,25 (yük × (1 − 0,25 r)) |
| `TITIZ` | hız ×0,85 · yapım kalitesi ×0,5 |
| `CEIL` | 1,25 |
| `PHASE_K` (simülasyon sonrası) | 2,0 (aşama tavanı, §3.11 a) |
| `FIX_SHARE_MAX` (simülasyon sonrası) | 0,5 (düzeltme payı tavanı, §3.11 b) |
| `SPRINT_WEEKS` | 2 |
| `FIX_DUE_MIN` | 2 |
| `FLOOR_WEEK` | 0,7 hata/hafta × `USAGE` (1,5) |
| `UNFIT_MORALE` | −2 / uymayan hafta |
| `WEEKS` | 60 · tohumlar 1–5 · ölçüm penceresi 21–60. hafta |

### 6.3 Kişi
- Alanlar: `product`, `design`, `eng`, `qa` (0–10). Rol: `founder`, `pm`, `des`, `dev`, `test`.
- Ana ve ikincil alan: PM ürün / tasarım; tasarımcı tasarım / ürün; geliştirici yazılım / test; testçi test / yazılım.
- İş kutuları: varsayılan PM `build`; tasarımcı `build`; geliştirici `build`; testçi `test`. Senaryo değiştirebilir.
- `fit(kişi, aşama)` sırası ve sınıfı (atama sırası için sınıf numarası):
  - kurucu: tasarım, geliştirme ve test, U 1,0, sınıf 1 (hazırlık yapmaz);
  - aşama `qa`: kişide `test` kutusu yoksa uymaz. Ana alanı test ise U 1,0 sınıf 0; ikincil ise 0,7 sınıf 2; değilse
    0,4 sınıf 3;
  - aşama `design` ya da `eng`: kişide `build` kutusu yoksa uymaz. Ana alan ise 1,0 sınıf 0; ikincil ise 0,7 sınıf 2;
    PM'in ikincil tasarım alanı sprintte sayılmaz (PM sprint puanı üretmez); öbür durumlarda uymaz;
  - aşama `product` (hazırlık ve araştırma): PM ana alan. Tasarımcı hazırlık yapmaz.
- Hız: `rate(kişi, aşama) = BASE × Y(s) × U × pay × (0,85 TİTİZ ise)`; kurucuda Y = max(1, Y(s)); pay = 1.
- Kalite: `catch(kişi) = C_REF × √Y(qa)`; `build_q(kişi) = 1 ÷ √Y(eng) × (0,5 TİTİZ ise)`. Kurucuda taban yok.
- Kapasite (planlama için): Σ kişi × max(rate(design), rate(eng), rate(qa)) × `SPRINT_WEEKS`. PM sıfır katar.
- (simülasyon sonrası) Aşama kapasitesi `pcap[i]` = Σ kişi × rate(kişi, aşama i) × `SPRINT_WEEKS` (kişi çalışabildiği her
  aşamada sayılır).

### 6.4 Kart ve kart akışı
- 12 hat: 0–3 tasarım ağırlıklı, 4–7 geliştirme ağırlıklı, 8–11 test ağırlıklı.
- MVP kartları: hat 0, 4 ve 8'in K1'i, akışın ilk üç kartı (bu sırayla).
- Sonsuz akış: MVP kartlarından sonra hatlar 0, 1, …, 11, 0, … sırayla dolaşılır; her hatta sıradaki kademe (hat
  0, 4 ve 8 K2'den başlar), K3'ten sonra 40 puanlık kartlar sürer. Kademe kilidi yoktur.
- Kart alanları: `need[3]`, `base_need[3]`, `prog[3]`, `prep`, `ready`, `kadro[3]`, `t0`, `log` (kişi → [d, e, q]),
  `fixed` (hazırlık bir kez sabitlenir).
- `phase(c)`: `need[i] − prog[i] > 1e-6` olan ilk i; yoksa 3 (bitti).
- `fix_start(c)` (karta sprinte ilk girişinde, bir kez): özellik kartında `ready = min(1, prep ÷ (0,20 × S))`,
  `need = base_need × (1 − 0,20 × ready)`. Her sprint başında: `kadro[i] = max(1, ⌈need[i] ÷ 8⌉)`, `t0 = need[2]`.

### 6.5 Sprint planlama (her sprintin başında)
1. Ürün canlıysa düzeltme kartları: açık hatası ≥ 2 olan her hat için (devreden düzeltme kartı olan hat hariç) bir kart;
   sıra hata sayısı azalan, eşitlikte hat numarası artan. Kartın büyüklüğü o anki hata sayısından.
   (simülasyon sonrası) `fl` = devreden düzeltme kartlarının kalan işi. Sırayla her kart için: `fl` > 0 ve
   `fl` + kartın işi > `FIX_SHARE_MAX` × kapasite ise kart bu sprint açılmaz (sonraki planda yeniden değerlendirilir),
   sıradakine geçilir; değilse kart eklenir, `fl` += kartın işi.
2. Devreden kartlar, önceki sıralarıyla.
3. Bunların hepsine `fix_start`.
4. `düzeltme payı` = düzeltme kartlarının kalan işi ÷ kapasite (kayda geçer).
5. Akıştan kart ekleme: sıradaki kartın bir kopyasına `fix_start` uygulanır. Sprintte en az bir kart varsa şu iki
   koşuldan biri tutmazsa durulur: (a) sprintin kalan işi + kopyanın işi ≤ 1,25 × kapasite; (b) sprintin kartlarının ve
   kopyanın kopyaları, ekibin kopyasıyla, 2 hafta (§6.6 ile, önden iş olmadan) oynatılınca kopya > 0 iş alır. Tutarsa
   kart akıştan alınır, `fix_start` uygulanır, sprinte eklenir. Sprint boşsa ilk kart koşulsuz alınır.
   (simülasyon sonrası) Koşul (a) ile (b) arasına (a2): kopyanın işi > 1e-6 olan her aşama i için, sprintin kartlarının
   i aşamasında kalan işi + kopyanınki ≤ `PHASE_K` × `pcap[i]`. Tutmazsa durulur; duran aşama kayda geçer.
6. Tek kart senaryosu (S12): düzeltme ve devreden kart yoksa akıştan tek kart alınır, başka kart eklenmez.
7. Önden işler: `n` = bu sprintteki özellik kartı sayısı (en az 1). Ekipte tasarımcı varsa sonraki sütun = akışın
   sıradaki `n` kartı; PM varsa hazırlık kuyruğu = akışın sıradaki `3n` kartı.

### 6.6 Hafta oynatma (zaman sıralı)
```
t = 0; ekipler = {} (kart → aşamasında çalışan kişiler); açılış = {kart: 0}; meşgul = {kişi: 0}
döngü:
  çalışanlar = ekiplerdeki herkes
  her kart için sprint sırasıyla:
    ph = phase(kart); ph = 3 ya da açılış[kart] > t ise geç
    ekip[kart] dolmadıkça (uzunluk < kadro[ph]):
      aday = çalışanlar dışındaki, fit(kişi, ph) olan ve rate > 0 olanlar
      aday yoksa çık
      seç = sınıfı en küçük, sonra rate en büyük, sonra kimlik en küçük
      ekibe ekle, çalışanlara ekle; sınıf 3 ise kişiyi "uymayan işte çalıştı" diye işaretle
  sonraki = min(1, her dolu ekip için t + (need[ph] − prog[ph]) ÷ Σ rate)
  dt = sonraki − t
  her dolu ekip için her kişi: iş = min(rate × dt, need[ph] − prog[ph]); prog[ph] += iş; log[kişi][ph] += iş;
    meşgul[kişi] += dt
    aşama bittiyse (kalan ≤ 1e-6): prog[ph] = need[ph]; ekip boşalır; açılış[kart] = sonraki
  t = sonraki; t ≥ 1 ise döngüden çık
kalan[kişi] = 1 − meşgul[kişi]
hazırlık: PM'ler hazırlık hızı büyükten küçüğe, eşitlikte kimlik; her PM kuyruğu sırayla gezer; bu hafta başka PM'in
  aldığı ya da tamamlanmış kartı atlar; iş = min(gereken − prep, kalan × hız); prep += iş; kalan −= iş ÷ hız
önden tasarım: sonraki sütunun kartları sırayla; tasarım kalanı varken tasarımcılardan (kalanı > 0) tasarım hızı en
  büyük olan çalışır: iş = min(need[0] − prog[0], kalan × hız)
boşta += Σ kalan; uymayan işaretli her kişi moral −2
```

### 6.7 Kapanış
- Sprint, bir haftanın sonunda kartlarının hepsi bitmişse ya da 2 hafta dolmuşsa kapanır. Bitmeyenler devreder.
- Taban hata akışı her haftanın sonunda (kapanıştan önce) işler: ürün canlıysa Poisson(0,7 × 1,5) hata, her biri canlı
  hatlardan (kademesi ≥ 1) eşit olasılıkla birine.
- Biten her kart için:
  - düzeltme kartı: hattın açık hatası 0 olur;
  - özellik kartı: hattın kademesi = max(kademe, kartın kademesi);
  - E hesaplanır (§3.6 formülleri): `q = Σ log[k][eng] × build_q(k) ÷ Σ log[k][eng]` (geliştirme işi yoksa 1);
    `H = 0,03 × S × tür × (1 − 0,25 × ready) × q`; `C = min(1, Σ log[k][qa] ÷ t0 × catch(k))` (t0 = 0 ise 0);
    `E = H × (1 − C)`;
  - n = Poisson(E) (ters dağılım: u ~ U(0,1); k = 0, p = e^(−E), s = p; u > s oldukça k += 1, p ×= E ÷ k, s += p);
  - ürün canlıysa n hata kartın hattına; değilse n kez bekleme listesine.
- MVP: üç MVP kartı da bitmişse ürün canlı olur; bekleme listesindeki her kayıt hattına 1 hata yazar; MVP haftası o
  kapanışın haftası.
- RNG: senaryo tohumuyla tek bir `random.Random`; çekiliş sırası: haftalık taban akışı, sonra kapanışta kartlar sprint
  sırasıyla.

### 6.8 Ölçümler (21–60. haftalar)
| Ölçü | Tanım |
|---|---|
| Teslim / hafta | Biten özellik kartlarının `S`'leri toplamı ÷ hafta |
| Puan / hafta | Sprint kartlarına eklenen `prog` ÷ hafta |
| Kişi başı | Teslim ÷ kişi sayısı (kurucu dahil) |
| Kart / sprint | Biten özellik kartı ÷ sprint |
| Kart başı kaçan hata | Biten özellik kartlarının E ortalaması |
| Açık hata | Her kapanıştan sonra toplam açık hata; medyan |
| Düzeltme payı | §6.5 adım 4; medyan. Ayrıca MVP'den sonraki ilk 20 hafta için ayrı medyan |
| Hata sprinti | Düzeltme payı > 0,5 olan sprint sayısı; üst üste iki tane var mı |
| Boşta | Σ kalan ÷ hafta (kişi-hafta / hafta) |
| Darboğaz | Her kapanışta devreden kartların, bekledikleri aşamadaki kalan işi o aşamaya eklenir; pencerede en büyüğü. Hiçbiri 1 puanı geçmiyorsa "yok". (inceleme) D2'den itibaren kalan iş o aşamanın kapasitesine (`pcap`) bölünür, en büyük oran darboğazdır; mutlak hâli yalnız karşılaştırma için basılır (§3.9 sonu) |
| Hazır kart | Sprinte giren özellik kartlarının `ready` ortalaması (ilk üçte bir atılır) |
| MVP haftası | §6.7 |
| Marjinal getiri | Ekip + 1 kişi ile ekibin teslim farkı (5 tohum medyanı) |
| Moral | Kişi başına toplam uymayan moral |

Her ölçü 5 tohumun medyanıdır.

### 6.9 Kartlarla elle doğrulanacak örnekler
| Örnek | Beklenen |
|---|---|
| K1 geliştirme ağırlıklı (2 / 10 / 3), kurucu + 3★ ve 2,5★ geliştirici + 3★, 2,5★, 2★, 4★, 1,5★ testçi, tek kart | Kadro [1, 2, 1]; 1. haftada biter; testi 4★ testçi yapar; E ≈ 0,22; boşta ≈ 6,7 kişi-hafta |
| K3 test ağırlıklı (4 / 22 / 14), aynı ekip, tek kart | Kadro [1, 3, 2]; 2. haftada biter; test 4★ ve 3★ testçide; E ≈ 0,64 |
| K3 geliştirme ağırlıklı (6 / 26 / 8), 3★ tasarımcı, 3★ testçi, 1–6 adet 3★ geliştirici | Süre (kesirli) 3,45 · 2,33 · 1,96 · 1,77 · 1,77 · 1,77 hafta |
| K2 kart, 2,5★ geliştirici, hazırlıksız, testi tek kişi | E: test yok 0,75; kurucu 0★ 0,54; 3★ 0,43; 5★ 0,33 |
| Hazırlık süresi, 3★ PM | K1 0,26 hafta; K3 0,69 hafta |

### 6.10 Senaryolar
Puanlar 0–10 (yıldız = puan ÷ 2). Kurucu her senaryoda: ürün 4, tasarım 0, yazılım 4, test 0. "Dağılım" listesi
[6, 4, 8, 5, 3, 6, 7, 4, 5, 6] her rol grubunda baştan başlayarak kişilere sırayla verilir (ana alan puanı); PM'in tasarımı ve testi ana alan − 1 ve 2, tasarımcının ürünü
ana alan − 1, geliştiricinin testi ana alan − 1, testçinin yazılımı ana alan − 1.

| # | Ekip | Not |
|---|---|---|
| S1 | Kurucu | |
| S2 | Kurucu + Deniz (geliştirici: yazılım 6, test 5) + Ece (tasarımcı: tasarım 4, ürün 3) | |
| S3 | Kurucu + Selin (PM: ürün 6, tasarım 5, test 2) + Ece (tasarım 6, ürün 5) + Deniz (yazılım 7, test 6) + Mert (yazılım 3, test 2) + Ayşe (testçi: test 5, yazılım 4) | |
| S4 | Kurucu + 2 PM + 2 tasarımcı + 5 geliştirici + 2 testçi (dağılımla) | 12 kişi |
| S5 | Kurucu + 3 PM + 4 tasarımcı + 12 geliştirici + 5 testçi | 25 kişi |
| S6 | Kurucu + 6 PM + 8 tasarımcı + 25 geliştirici + 10 testçi | 50 kişi |
| S7 | Kurucu + 2 geliştirici (6, 5) + 5 testçi (6, 5, 4, 8, 3); karşılaştırma: aynı ekip tek testçiyle (6) | Küçük karta 5 testçi; ayrıca §6.9'un tek kart örnekleri |
| S8 | Kurucu + 10 geliştirici | Aynı rolde 10 kişi |
| S9 | Kurucu + 8 testçi; (a) yalnız Test kutusu, (b) Yapım ve Test kutusu | Hepsi testçi |
| S10 | Kurucu + 6 tasarımcı + 16 geliştirici + 7 testçi | PM'siz 30 kişi |
| S11 | Kurucu + 2 PM + 2 tasarımcı + 20 geliştirici + 0 testçi; (b) geliştiricilerde Yapım ve Test kutusu | |
| S12 | S4'ün ekibi, tek kart kipi (§6.5 adım 6) | Tek karta tüm ekip |
| Ek | S3'te PM'siz; S3'te Selin'e Test kutusu; S4'te PM'siz; S5'te tek PM | PM'in değeri ve uymayan iş |
| Marjinal | S2–S6'ya ayrı ayrı +3★ geliştirici, +3★ testçi, +3★ tasarımcı, +3★ PM, +1★ geliştirici | |

### 6.11 Beklenen sonuçlar
§4.2, §4.3 ve §4.4'teki tablolar. Simülasyon bunlardan ±%10 sapabilir (tohum ve uygulama farkı); daha büyük sapmada
önce bu tanımla uygulama karşılaştırılır.

### 6.12 Kırılma ölçütleri (model kırık sayılır)
1. Herhangi bir senaryoda herhangi bir rolü eklemek teslimi düşürür (marjinal getiri < 0; tohum gürültüsü için −1
   puan/hafta tolerans).
2. Tek kurucunun MVP haftası 6–7 dışına çıkar.
3. Kişi başı teslim, 25 ya da 50 kişilik dengeli ekipte (S5, S6) 6 kişilik ekibin (S3) %70'inin altına iner ya da %150'sini
   aşar.
4. Darboğaz rolüne bir kişi eklemek teslimi artırmaz (S8'e Test kutulu geliştirici, S11'e testçi, S9a'ya geliştirici).
5. ≥ 2 kişilik ekiplerde düzeltme payı medyanı MVP'den sonraki ilk 20 haftada %30'u, sonrasında %20'yi aşar; hata
   sprinti oranı %5'i aşar ya da üst üste iki hata sprinti olur (A'nın E1 §9 hedefleri). Tek kurucuda ilk 20 hafta için
   sınır %50.
6. `fix_due` politikasıyla açık hata 60 haftada sınırsız büyür: son 20 haftanın doğrusal eğimi > 0,2 hata/hafta.
7. Kart başı kaçan hata testçi yıldızıyla azalmaz (aynı ekip, yalnız testçi 1★ → 5★) ya da bir kartın yakalaması en iyi
   testçisininkini aşar.
8. PM'siz bir ekibe PM eklemek kart başı kaçan hatayı düşürmez ya da teslimi artırmaz (S3, S4).
9. Boşta süre kişi-haftanın %10'unu aşar ama darboğaz "yok" ve kart arzı sınırı da yok (neden gösterilemeyen boşluk).
10. Tahmin ≠ sonuç (§6.13).

### 6.13 Tahmin = sonuç denetimi
Her sprintin başında, planlamadan sonra kartların ve ekibin kopyası 2 hafta oynatılır (önden işlerle birlikte).
Kapanışta gerçek sonuçla karşılaştırılır: kart başına biten puan (aşama aşama), bitiş haftası ve E. Olay olmadığı için
fark 1e-6'yı aşamaz. Prototipte S3, S4 ve S11b için 40 haftada en büyük fark 0 çıktı. Taban akışın düşürdüğü hata planı değiştirmez (düzeltme kartı sprint başında kilitlenir).

### 6.14 Çıktı
Senaryo başına bir satır (§6.8 ölçüleri) ve kırılma ölçütlerinin her biri için GEÇTİ / KIRIK ve kanıt satırı.

---

## 7. Onay bekleyen sabitler
| # | Sabit | Değer | Not |
|---|---|---|---|
| 1 | Kart büyüklüğü ×5 | K1 15 · K2 25 · K3 40 · araştırma 5 · ücretli plan 15 · düzeltme 5 / 10 | Ölçek Erdem'in kararı; değerler mekanik ×5 |
| 2 | İş profili payları | 35/45/20 · 15/65/20 · 10/55/35 ve §3.2 tablosu | [ÇALIŞMA] |
| 3 | Uymayan işin biçimi | 0,4 × o alandaki yıldız çarpanı; (inceleme) en az 0,3 | 0,4 ya da 0,3 Erdem'in kararı; biçim ve 0,3 tabanı öneri [ÇALIŞMA] |
| 4 | Kadro dilimi | 8 puan | [ÇALIŞMA] |
| 5 | Hata yükü | 0,03 / puan; düzeltme ×0,3 | [ÇALIŞMA]; ölçüm diliminde A'nın hedefleriyle seçilir |
| 6 | Yakalama | 0,40 × √Y (Test yıldızı) | [ÇALIŞMA]; R4 §2.3 aralığı |
| 7 | Yapım kalitesi | 1 ÷ √Y (Yazılım yıldızı) | [ÇALIŞMA] |
| 8 | Hazırlık işi | kartın %20'si; kısmi hazırlık orantılı | [ÇALIŞMA]; −%20 iş ve ×0,75 Erdem'in kararı |
| 9 | Kurucu tabanı | her aşamada Y en az 1,0; kalitede gerçek yıldız | [ÇALIŞMA] |
| 10 | Huyların sprintte okunması | TİTİZ hız ×0,85 ve yapım kalitesi ×0,5; GÖZÜ YÜKSEKTE ×1,15 | Değerler bugün var, ilk kez sprintte okunur |
| 11 | A'nın yeni kod terimi | silinir | A'nın sabiti |
| 12 | Yıldız eğrisinin 5★ ucu (×2,0) | Ölçüm diliminde 5★ ile 3★ geliştiricinin maaş başına teslimi karşılaştırılır | Karar defteri "kalibrasyonda bakılır" |
| 13 | Aşama tavanı (simülasyon sonrası) | Bir aşama satırındaki iş ≤ ekibin o aşamadaki kapasitesinin 2 katı | [ÇALIŞMA]; 1,25 ve 1,5 teslimi düşürdü (§3.11 a) |
| 14 | Düzeltme payı tavanı (simülasyon sonrası) | Planın kendiliğinden aldığı düzeltme işi ≤ kapasitenin yarısı; ilk kart her zaman girer; Öncelikli kartlar da bu sınıra uyar | Değer A'nın hata sprinti tanımı; A'nın zorunlu listesini değiştirdiği için onay bekliyor (§3.11 b) |
| 15 | (inceleme) Darboğaz ölçüsü | Aşamada kalan iş ÷ o aşamanın kapasitesi | [ÇALIŞMA]; mutlak ölçü ekranı yanlış role yöneltiyordu (§3.9 sonu) |
| 16 | (inceleme) A'nın mutlak hata hedefleri ve itibar eşiği | Canlı hat başına ve teslim edilen işe oranlı | A'nın sabiti; açık soru 5 |

Silinen sabitler: `person_points_week`, `skill` bantları, `founder_mult`, `no_role_speed` (0,5), `faulty_chance` (0,4),
`shares`; eski D planının koordinasyon kaybı (%1, tavan %25, PM kapsamı 8, kesinti 0,5) ve hazırlık tablosu.

---

## 8. Açık sorular
1. **Ekip kaybı:** Şirket çapındaki "kişi başı ekip kaybı" hiç eklenmesin; yerine kartın kadrosu (her 8 puan için bir
   kişi) ve aşamaların hafta içinde de sırayla akması gelsin; PM'in değeri koordinasyon değil hazırlık olsun mu?
   **Öneri: evet.** Kanıt kaybın aynı işte doğduğunu söylüyor; ön hesapta 50 kişide de kişi başı teslim düşmüyor ve
   kırık bileşimler boşta kişi olarak görünüyor.
2. **Hata modeli:** Kartın hata yükü büyüklükle, testçinin yakaladığı oran yıldızla (%28–57) belirlensin; en iyi testçi
   bile yükün yaklaşık %43'ünü kaçırsın; kart "hata ihtimali %35" yazsın; bugünkü "yeni kod" hata akışı bunun yerine
   kalksın mı? **Öneri: evet.**
3. **Hazırlık ve tasarımcı** (inceleme: eski 3. ve 5. soru birleşti): PM önden hazırlasın (iş kartın %20'si, süre PM'in
   yıldızından, yarım hazır kart yarım fayda); tasarımcı sprintte çalışsın, boş kalınca sonraki sprintin tasarımına
   geçsin, PM'in hazırlığına katılmasın mı? **Öneri: evet.** Katılma kuralı ön hesapta teslimi değiştirmedi.
4. **Kurucu:** "Kurucu her alanda en az orta seviye (2,5★) biri kadar hızlı çalışır, alanında daha iyiyse kendi
   yıldızıyla; hata hesabında gerçek yıldızı sayılır." Bu kural kalsın mı? **Öneri: evet.** Yoksa tasarımı ve testi
   zayıf kurucu MVP'ye 6. değil 9. haftada varır.
5. **Büyük ekipte hata hedefleri** (inceleme, yeni): Faz A'nın "en çok 8 açık hata", "haftada en çok 4 yeni hata" ve
   "30 açık hatada itibar düşer" sınırları sabit sayı; düzenli düzelten 25 ve 50 kişilik ekip bunları aşıyor. Bu sınırlar
   yayındaki özellik grubu sayısına ve teslim edilen işe oranlansın mı? **Öneri: evet.**
6. **Plan ekranı:** Aşama şeridi ve darboğaz cümlesi ekranda, kart zinciri kartın üstüne gelince, kişi yük şeridi
   avatar satırında olsun ve Claude Design'da bu birleşim maketlensin mi? **Öneri: evet.** (inceleme) Darboğaz, kalan işin
   o aşamanın gücüne oranıyla seçilir; böylece ekran "Test yetişmiyor" dediğinde testçi almak gerçekten teslimi artırır.

---

## 9. Kaba hacim
| Dilim | Ne | Bedel |
|---|---|---|
| D0 | Ölçüm altyapısı: `--sprint-probe`'a ekip listesi (rol ve puan), aşama satırı, kart başı E; bugünkü modelle taban tablo | Orta, 2 sa |
| D1 | Ölçek ×5 ve kart ihtiyacı: iş profili alanı (X yapmadıysa), ihtiyaç tablosu, düzeltme, karar fiillerinde aşama alanı ve ×5, kayıt göçü | Orta, 3 sa |
| D2 | Hafta oynatması: zaman sıralı atama, kadro, kişi hızı (yıldız, uyum, kurucu tabanı, huy), Görevler matrisi aşama kapısı, PM sprint dışında; tahmin = sonuç. (simülasyon sonrası) Plana aşama tavanı ve düzeltme payı tavanı (§3.11), lider önerisi ve "+" düğmesi dahil | Büyük, 6,5 sa |
| D3 | Hata: yük, yakalama, Poisson, kartın hattına, yeni kod teriminin silinmesi, B için hata ihtimali okuma noktası | Orta, 2,5 sa |
| D4 | Hazırlık: kuyruk, sabitleme, sonraki sütun ve Çeyrek etiketleri, kayıt | Orta, 3 sa |
| D5 | Ekip ekranları: Görevler matrisinde uymayan kutu ve ipuçları, Atlas'ta aşama hızları, moral satırı | Orta, 2,5 sa |
| D6 | Plan ekranı (Claude Design maketinden sonra): aşama şeridi, darboğaz cümlesi, kart ipucu ve zinciri | Büyük, 4 sa |
| D7 | Ölçüm ve kalibrasyon raporu: bot kolları, A'nın hedefleri, 5★ ile 3★, hata yükü sabiti (commit yok) | Orta, 2 sa |

- Dilimler ~25 saat; kapılar, çekimler ve commit başına incelemelerle 30–35 saat. Öncesinde Claude Design maket turu
  (Erdem'le) ve simülasyon ajanının §6 koşusu (~2 saat).
- Yeni durum: kartta kadro, hazırlık, aşama bazında kişi kaydı; üründe hazırlık sözlüğü; şema 17. Yeni ekran yok; plan
  ekranı ve Görevler matrisi değişir.
- En büyük risk D2: zaman sıralı oynatma tahmin = sonuç kapısının en çok yük taşıyan parçası. Önlem: D0'ın ekip listeli
  probu ve §6.13'ün denetimi D2'nin kapısıdır.

---

## İnceleme notu
Kıdemli inceleme, 17 Ekim 2026 (Opus). Repo kodu değişmedi. Belgedeki her değişiklik "(inceleme)" diye işaretli.
Simülasyon betiği (`dsim/dsim.py`) okundu: `fit`, `rate`, kadro, zaman sıralı hafta, hata yükü, yakalama, hazırlık ve iki
tavan §6 ile birebir; tablolar modelin yazdığı formülle üretilmiş. Darboğaz ölçümü için ek betik:
`scratchpad/inceleme_d/darbogaz.py`.

1. **Darboğaz ölçüsü yanlış role yöneltiyordu (en önemli bulgu).** Mutlak kalan iş hemen her ekipte "Geliştirme" diyor,
   marjinal getiri ise Test ve Tasarım diyor. Ölçü kapasiteye oranlandı (§3.9 sonu, §6.8, §7 #15); §4 tablolarına not
   düşüldü. Açık: S6'da tasarımcının büyük getirisini iki ölçü de tam yakalamıyor; D7 marjinal getiriyle doğrular.
2. **A'nın mutlak hata hedefleri ölçekte kırılıyor.** İtibar eşiği yanında açık hata (≤ 8 / ≤ 16) ve haftalık yeni hata
   (≤ 4) hedefleri de 25 kişide aşılıyor. §5 A, §4.2, §7 #16; açık soru 5 olarak eklendi.
3. **Uymayan iş Erdem'in tabanının altına iniyordu.** "0,3'ün kendiliğinden çıkar" cümlesi yanlıştı (hiç puanı olmayan
   kişide 0,2). 0,3 tabanı öneri olarak eklendi (§1 #6, §3.3, §7 #3).
4. **Kaynakla ayrılan yerler adıyla yazıldı.** Kadroda tam hız R4 §5 madde 6'nın %40 / %10 önerisinden ayrılıyor (§2.3);
   Porter "1 < 2 = 4" der, model 1'den 2'ye kazancı almaz (§1 #12); R4 §2.5 ekipler arası kaybın sıfır olmadığını yazar
   (§2.4); R5 §7'nin dördüncü yönü kişi yük şeridi değil Linear kadranıdır (§1 #23); Startup Company'nin uyarısı sunucu
   içindir (§2.7).
5. **Rastgele 8 araştırma iddiası kontrol edildi.** R4 §2.3 (%40, %55, %45'lik gereksinim ve tasarım payı), R4 §2.5 (QSM,
   Pave 5:1–11:1), R3 §7.1 (×0,7, %6–31, ekip 1/2–3/3–5/6, fazla yük 3 kat), R1 §2.3 (geliştiricinin sözü), R2 §7.1
   (3/5/8, bonus bölünür), R4 §2.1 (Gothelf, Patton, %10) doğru. Yanlış ya da eksik aktarım 4. maddedekiler.
6. **Tahmin = sonuç.** Modelde tutuyor (3,6e-15); tek istisna kapanıştaki hata sayısı (çekiliş). Ekranın "Beklenen hata
   2" yazması vaat gibi okunur; ihtimal diliyle yazılması kuralı eklendi (§3.6).
7. **Fazlar arası.** B'nin bedeli ödeyen kümesi tasarımcıyı almıyor, D'nin okuması alıyordu; Geliştirme ve Test'e
   daraltıldı (§5 B). C'nin güncel içeriği yenilemeye kurucu saati yazmıyor; §3.8 ve §5 C güncellendi. C'nin "D'nin satış
   masası modeli" beklentisinin D'de karşılığı yok; not düşüldü (§5 C).
8. **Küçük karta 5 testçi, aynı rolde 10 kişi, 50 kişi.** Üçü de makul ve görünür: 5 testçide 4'ü boşta görünür; 10
   geliştiricide tasarım ve test kurucuya kalır, teslim 19 (Test kutusuyla 37); 50 kişide kişi başı ~10. Ama 25 ve 50
   kişinin sonuçları sonsuz kart akışına dayanıyor, oyunda K3'ten sonra kart yok (§4.2 notu).
9. **Tek kurucunun MVP haftası** 20 tohumda 6. Eski plan bugünkü oyunu 7 diye ölçmüştü; ölçüt 6–7, D0 kapatır (§0 #9).
10. **Açık kalan (gözlem, değiştirilmedi):** testçi yıldızı kart başı hatayı %32 azaltıyor ama açık hata sayısını ve
    düzeltme payını değiştirmiyor; testçinin ek değeri %2–10 (`D_SIM.md` §13 g3, g6). Erdem'in "testçi önemli olmalı"
    beklentisi yalnız kart ipucunda görünür kalıyor. Düzeltme kartının hat başına en çok 10 puan olması (A'nın kuralı)
    büyük ekipte hatanın bedelini neredeyse sıfırlıyor.
11. **Açık kalan:** S4'e tasarımcı eklemek −1 (tolerans sınırında, önden tasarım kuralında); hazırlık oranı ölçekle
    düşüyor (%100 → %64). İkisi D2/D7 ölçümünde izlenir.
12. **Sorular** 6'da kaldı: eski 3 ve 5 birleşti, yerine büyük ekipte hata hedefleri geldi (§8).
