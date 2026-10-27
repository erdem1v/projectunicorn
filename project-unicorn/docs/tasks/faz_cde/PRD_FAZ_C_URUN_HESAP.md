# Faz C · Görev · Ürün sayfası, sunucu, giderler, B2B hesaplar ve memnuniyet
2026-10-18 · Sahip: Erdem · Yazan: yardımcı yönetmen (oturum 3ef3b847) · Kod `main` @ `889b9b8` (A ve B bitti).
Güncelleme 2026-10-18 akşam: Erdem'in cevabı işlendi (`ERDEM_QCD_CEVAP.md` §2.2, C1 ile C6).
Bu belge **ne beklediğimizi** söyler: çıktı ne olmalı, oyuncu ne görmeli, nasıl görmeli, neyle kabul edilir. Nasıl
yapılacağına uygulayıcı ajan karar verir.

## Bu belgeyi alan ajana
- Faz C'nin uygulama sorumlusu sensin; alt ajanlarla yürütürsün, modeller §8'de. **İlk iş:** bu belgeyi ve §0'ın eklerini
  oku; Erdem'e adım tablonu ver (Adım | Ne | Kim | Model | Düşünme | Süre | Neden), onayını bekle.
- **Erdem'e döndüğün yerler:** adım tablosu; E1 (araştırma, simülasyon, Menajer dilinde ekranlar, metin dalgası); E2 (bot
  ölçümü); son rapor (R). Bunların dışında sormadan ilerlersin.
- **İşaretler:** "(Erdem)" onaylı karardır (18 Ekim dahil). "onay bekliyor" önerilmiş kuraldır; kodda ve raporda aynı
  işaretle yazılır (CLAUDE.md §3). İşaretsiz sayılar da onay bekler.
- **Playtest üç faz bitince** (Erdem). Her dilim oyunu bozmadan, kendi kapılarıyla kapanır: commit'ten sonra `run_gate`'in
  üç koşusu bir sonla biter, her yüzey çalışır.
- **Faz Q önce gelir.** Memnuniyet, imza kapısı ve Genel Bakış'ın Sürüm bloğu Q'nun sözleşmesini okur; Q'nun raporu
  gelmeden oyun koduna, `strings.csv`'ye ve `data/`'ya yazmazsın (§8 Başlama koşulu).
- **Oynanış önce gelir.** Erdem'in çıtası Steam'de %90 üstü olumlu yorum. Bir kural kapıyı tutup oyunu sıkıcı yapıyorsa
  kapı tutmamış sayılır. Her dilimin raporu §4.3'ün oynanış kapılarını ayrıca yazar.

## 0. Ekler ve öncelik
Ekler `docs/tasks/faz_cde/` altındadır (izlenmiyor).

| Ek | Ne işe yarar |
|---|---|
| `ERDEM_QCD_CEVAP.md` | **Bağlayıcı.** Erdem'in 18 Ekim akşam cevabı (§1 birebir) ve onayladığı okuma (§2.2 C1 ile C6). Bu belgenin bütün yeni kararları buradan |
| `ACIK_ISLER.md` | Bu turda yapılmayacak işler; C onlara iş sokmaz (§7) |
| `C_ICERIK_v3.md` | Ana tasarım girdisi: sunucu, giderler, bütçe kesintisi, memnuniyet modeli, simülasyon tanımı. Sonundaki inceleme notu gövdeden önce gelir |
| `C_ICERIK_v2.md` | v3'ün "değişmeyen" dediği kısımlar: Genel Bakış (§2.1), Kurumsal madde (§2.3), HESAPLAR (§2.4), yenileme (§2.6), destek raporu (§2.7), gelir ve adlar (§2.8 ile §2.10) |
| `C_PLAN.md` §2.1, §2.2, §2.8 | v2'nin "değişmedi" dediği Genel Bakış blokları, istekler ve destek raporu örnekleri |
| `MEMNUNIYET_SIM.md` | v3 modelinin ölçümü (13 kapı). Betikler bu oturumun scratchpad'inde: `.../3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/msim/` |
| `KALITE_v2.md` §3 ile §6 | Ürün uyumu U'nun tanımı ve Q'nun C'ye verdiği sözleşmeler. Q'nun PRD'si `PRD_FAZ_Q_KALITE.md` |
| `OYNANIS_HUKMU.md` | Her mekaniğin oynanış hükmü ve kapıları. Bu belgenin "Oynanışa etkisi" satırları ondan gelir |
| `ERDEM_CDQ_CEVAP.md`, `ERDEM_CD_YORUM.md`; `arastirma/R6`, `R7`, `R9`, `R15` | Erdem'in 17 Ekim sözleri; sunucu, yenileme, memnuniyet araştırması ve bugünkü döngünün bot ölçümü |
| `../faz_ab/RAPOR_A.md`, `../faz_ab/RAPOR_B.md` | A ve B'nin gerçek okuma ve yazma noktaları |

**Öncelik:** `ERDEM_QCD_CEVAP.md` (§1, sonra §2), Erdem'in öbür sözleri, bu belge, OYNANIS_HUKMU, v3'ün inceleme notu,
v3 gövdesi, v2, C_PLAN. Erdem'in cevabı hükmü aştığı yerde (sunucu, yenileme zammı, istekler) Erdem geçerlidir. Satır
numaraları `889b9b8`'e göredir; C0 haritası tazeler.
Q1 ile Q6 ve C1 ile C6, `ERDEM_QCD_CEVAP.md` §2.1 ve §2.2'nin karar numaralarıdır; D4 aynı belgenin §2.3'üdür.

**v3 ve v2'de geçersiz olanlar** (oradan alınıp kodlanmaz)
1. Kademe çarpanı B'nin işi olarak (v3 §2.6): B uyguladı (`incident_system.gd:75-78`); C yalnız `load_mult()`'u doldurur.
2. Bütçe kesintisinin kâğıdı, ayda üç yenileme kâğıdı, yaşın Çekirdek'i sayması: yerlerine Karar 9, 8 ve 7.
3. **Reddedilenler:** "en az 70" satırı, 70 tabanı ve sönümü, kendiliğinden ölçekleme, "toplam gider değişmesin" (v3 §6),
   Claude Design maketi. v3'ün "15 kart"ı bugün 13 kart dosyasıdır.
4. **Erdem'in 18 Ekim cevabıyla kalkanlar:** kurucu satırı ($1.500) ve İş hanı'nın $1.500 kirası (v3 §3.4); yenileme
   bantlarının kaydırılması ve "en çok %50 zam, en az %15 indirim" kapısı (v3 Soru 5, hüküm satır 8); hükmün "Yükü %70'e
   indir" ve "Payı %30'da tut" önerileri (hüküm satır 9, İtiraz 1); istek kesintisinin "MRR'da ilk çeyrek" kolu ve 1★, 2★
   hesapların istekleri (hüküm satır 18); evreyle yükselen pazar beklentisi, evre rampası ve evre maili (Q3).

## 1. Amaç
Erdem'in sözleri (17 Ekim, `ERDEM_CDQ_CEVAP.md`): "oyuncunun göremediği, yönetemediği bir şeyi oraya gider olarak
koymayalım" · "memnuniyet durup dururken niye düşsün" · "direkt o şekilde başlasın" · "amacımız oyuncuyu gerçekten gerçek
hayat gibi aşırı zorlamak değil ... sağlıklı bir şekilde büyüyüp o top tier'a ulaşması".
18 Ekim (`ERDEM_QCD_CEVAP.md` §1): "Kurucu maaşı ... gerek yok" · "4000, 8000, 18000" · "ofisteki masa sayısı kadar
çalışan olabilir" · "%100 zamla bitmesinde bir sakınca görmüyorum" · "Kimisi seat sayısını arttırır ... farklı bir ürüne
geçiyoruz diyebilir" · "otomatik ayarla gibi bir buton" · "yalnızca 3 yıldız ve üzeri hesaplar ... talepte bulunur".

Bu fazdan sonra oyuncu yayındaki ürünü tek kâğıtta okur (Genel Bakış); sunucuyu kendisi yönetir ya da otomatik ayara
bırakır ve iki yolda da payın parasını ve kesinti riskini görür; giderde yalnız gördüğü kalemleri bulur ve ilk çalışanı için
evden İş hanına taşınır; her hesabın memnuniyetini satır satır okur; zayıf ürünle adı yazan bir nedenle imza kaybeder;
yenilemede zam, koltuk artışı ya da azalışı ve seyrek, adlı bir ayrılma görür; istekle ve sözle ilk kez 3★ hesapla tanışır.

**Bugün (`main` @ `889b9b8`)**
- **Sunucu:** kararı yok; MVP bulut ve 1 birimle açılır, her sürümde kapasite kendiliğinden büyür (`sprint_bridges.gd:73`,
  `:131-133`). Aşımın üç gizli cezası var (`infra_system.gd:66-69`); kesinti zarı yükü okumaz (`incident_system.gd:70-71`).
- **Gider:** yedi kalem (`finance_system.gd:38`); tek kurucunun gideri araç tabanı $1.500, runway 6,7 ay (`:13`); servis
  bot kaydında giderin %47 ile %57'si (v3 §3.1). Ofis kalemi 0, taşınma bedelsiz, masa gösterim (`office_map_card.gd:63`).
  Ev 1 masa; İş hanı 10, şart Frank'in çeki ve $6.500; Plaza 36, şart 12 çalışan, $45.000, marka 40
  (`office_constants.gd:15-62`); kişi şartı kurucuyu saymaz (`office_system.gd:26`).
- **Memnuniyet:** imzada `max(eşik + 10, 50)` (`sales_system.gd:373-374`), sonra gizli hedefe kayar
  (`b2b_sales_system.gd:149-162`); destek zararı adsız (`support_system.gd:243-268`); `fix_none`'da %87'si ilk hafta ≥ 5 düşer.
- **Ekranlar:** hesaplar kart listesi (`sales_tab.gd:511-560`); Ürün SPRINT | ÇEYREK (`product_tab.gd:16`). **Yenileme**
  kaydı ve zam yok; **istek** koşuda 113,8 kesinti (R15 §8.2); **destek raporu** yok; **şema** 17 (`save_manager.gd:16`).

## 2. Kararlar (bağlayıcı)
Her kararın **Oynanışa etkisi** OYNANIS_HUKMU §2'nin satırıdır; Erdem'in 18 Ekim cevabı hükmü aştığı yerde yeniden yazıldı.
Sınıflar R15 §6: S gerçek ödünleşim, T tek doğru cevap, B boş tık; C'nin her karar yüzeyi S olmalı (§4.3).

### Karar 1 · Sunucu kapasitesi oyuncuda, otomatik ayar oyuncunun seçimi, yük kesintiye girer
- **Kapasite oyuncudadır** (Erdem). Sürümdeki kendiliğinden büyüme silinir (`sprint_bridges.gd:73`); kapasiteyi yalnız
  oyuncunun düğmeleri ve oyuncunun açtığı otomatik ayar değiştirir.
- **Tek gösterge "Yük %"** (Erdem): hizmet edilen koltuk (B2C'de canlı kitle) ÷ etkin kapasite (`infra_system.gd:174-195`).
  Yanında **boş pay**, koltuk ve aylık para olarak: payın bedeli görünürse karardır, görünmezse kayıptır.
- **Artır ve Azalt oyuncuda kalır** (Erdem: oyuncu gidip kapasiteye baksın). Adım mevcut birimin %10'u, en az 1 birim
  (onay bekliyor). Hemen işler; o haftanın gece zarı yeni kapasiteyle okunur. İpucu yeni faturayı ve yükü önceden yazar.
  Taban 0, MVP'de 1 birim (`infra_system.gd:51-54`).
- **"Otomatik ayarla" anahtarı** (Erdem). Düğmelerin yanında, varsayılanı kapalı; oyuncu istediği an açar, kapatır; üstüne
  gelince kuralı tek cümleyle yazar. Önerilen varsayılan (onay bekliyor; §5'in araştırmasıyla E1'de kesinleşir): yük
  **%80** olunca kapasite bir adım büyür, adım yükü yaklaşık **%65**'e indirecek kadardır (yaklaşık ×1,25). Anahtar
  küçültmez; küçültmek oyuncunun Azalt kararıdır, çünkü küçülten otomasyon payı oyuncunun görmediği anda eritir. Eşik
  büyüme anında okunur (imza, kitle değişimi); büyüme blokta tek satır yazar, mail ve kart yoktur. **Bedeli görünür kalır:**
  yük, boş pay ve payın parası anahtar açıkken de yazar; büyüme satırının yerini son otomatik büyüme alır.
- **Yük kesinti ihtimaline girer** (Erdem: "%90'ı geçince kesinti ihtimali artsın"; basamaklar onay bekliyor).
  `IncidentSystem.load_mult()` (bugün 1, `incident_system.gd:70-71`) `InfraSystem.outage_load_mult()`'u okur: yük ≤ %90 1,0;
  %90 ile %100 arası 1,5; %100 üstü ya da kapasitesiz canlı ürün 2,5; gece zarı anındaki yük, yalnız "kesinti" türüne.
- **Gizli ceza yok.** Aşımın üç etkisi silinir (`infra_system.gd:66-69` ve okurları). Ekonomik'in görünür iki bedeli kalır ve
  kademe ipucunda yazar: bildirim akışı ×1,25 (`:35`), kurumsal hesap imzalayamaz (`:323-324`).
- **Büyüme satırı** (onay bekliyor; yalnız anahtar kapalıyken): son 4 haftanın büyümesiyle yük 1 ile 4 hafta içinde %90'ı
  geçecekse tek satır. Ağır kademe yayını kapasiteyi düşürürse sürüm notunda bir satır. Bağlanmamış uyarı kartı silinir.
  %90 üstü sarı, %100 üstü kırmızı; renk körü ikizi helper'dan.

**Oynanışa etkisi**
- Karar: ne kadar boş pay (para mı, kesinti riski mi); elle mi yönetmeli, otomatiğe mi bırakmalı. Şans oyuncunun elindedir
  (R13 §6 madde 6). Okunuş: "Yük %80 · boş pay 1.300 koltuk · ayda $3.120". Saat durmaz.
- Sıklık: elle oynayan oyuncu büyüme satırı göründükçe bakar (10 kat büyüyen üründe yaklaşık 24 tık, B2C'de yaklaşık 54;
  hüküm satır 9). Erdem bunu oyuncunun küçük meşgalesi olarak istiyor; sıkılan oyuncu anahtarı açar ve tık sıfıra iner.
- Otomatik ayar her durumda en iyiyse elle yönetim boş tıktır (T). Önleyen şey eşiğin bedelidir: %80 eşiği hep yaklaşık %20
  pay bırakır ve bu pay para olarak yazar; payı %5'e indiren oyuncu daha ucuza çalışır, kesinti riskini kendisi alır (§4.3).
- 1 kişi: MVP'den önce canlı ürün yok, sonra nadir karar. 50 kişi: oran adımı ve anahtarla tık hesap sayısıyla büyümez.
- Hüküm: İtiraz 1 Erdem'in anahtarıyla kapandı; "Yükü %70'e indir" ve "Payı %30'da tut" yoktur.

### Karar 2 · Kademe ve fiyat
- Üç kademe kalır; geçiş anında ve bedavadır (Erdem). Fiyat oranı 1 : 2 : 4 (Erdem). Standart'ta sunucu 26. haftadan
  sonra B2B gelirinin %8 ile %12'si (Erdem'in bandı %8 ile %15).
- Değerler (onay bekliyor): B2B 50 koltuk başına ayda $60 / $120 / $240 (bugün $30 / $45 / $70, `infra_system.gd:28`);
  B2C 1.000 kullanıcı başına $125 / $250 / $500 (bugün $35 / $55 / $85, `:26`). Simülasyonda Standart B2B gelirin %9,1'i,
  B2C %9,8'i (MEMNUNIYET_SIM M12). Dayanak: https://a16z.com/the-cost-of-cloud-a-trillion-dollar-paradox/ ,
  https://www.bvp.com/atlas/scaling-to-100-million (R6 §2.5). Kademe Sunucu bloğunda seçilir.

**Oynanışa etkisi:** ucuz ve riskli mi, pahalı ve güvenli mi; Kurumsal 3★ maddeyi kapatır (Karar 4). Koşuda 1 ile 3 kez. 1
kişi: MVP'de bulut seçili gelir. 50 kişi: son oyunun stratejik kararı. Hüküm: tut; kapı §4.3.

### Karar 3 · Giderler: yalnız görünen ve yönetilen kalem
- **Araç gideri kalkar** (Erdem: "tool'u koymamalıyız"); HR önizlemelerindeki araç satırı da. **Servis maliyeti kalkar**
  (Erdem; "gizli gider yok"): oyuncunun tek kolu "daha az müşteri"dir. `gross_margin_monthly` yalnız sunucuyu düşer.
- **Kurucu maaşı yoktur** (Erdem): maaş olsaydı artırılıp azaltılabilmeli ve harcanacak yeri olmalıydı (GDT, MGT2 ve
  Startup Company'de yok; `ERDEM_QCD_CEVAP.md` §2.4 [kanıtsız: kaynak taraması yok]).
- **Kalan liste:** Maaşlar, Ek mesai, Sunucular, Ofis, Pazarlama; sıfır kalem çizilmez. Evdeki tek kurucunun MVP'den önce
  gideri yoktur, sonra yalnız Sunucular.
- **Ofis kirası** (Erdem): Ev kirasız, İş hanı ayda $4.000, Plaza $8.000, Loft $18.000 (`OfficeConstants.CATALOG`'da yeni
  alan); taşınma tamamlandığı hafta başlar (`office_constants.gd:9`). **Maaş bantları ×1,5** (Erdem;
  `hr_constants.gd:591-598`): kayıttaki maaşlar değişmez, yeni teklif, terfi ve zam yeni bandı okur.
- **Masa sayısı işe alım tavanıdır** (Erdem). Masalar Ev 1, İş hanı 10, Plaza 36, Loft 64 (`office_constants.gd:19`, `:28`,
  `:40`, `:54`). Kurucu bir masa tutar; boş masa = masa − kurucu − çalışanlar (izindeki masasını korur). Boş masa yoksa
  arama açılmaz; Atlas tavanı ve nedenini tek cümleyle yazar ve ofis haritasına götürür (§3). Masayı aşan kadro çıkarılmaz.
- **Plaza şartı 10 kişi** (Erdem): kurucu dahil, yani İş hanı'nın bütün masaları dolu. Kod bugün çalışanları sayar
  (`office_system.gd:26`); şart 9 çalışan diye yazılır ya da sayım kurucuyu katar, metin "10 kişi (sen dahil)" der. Nakit
  ($45.000) ve marka (40) şartları kalır; C0s bunların İş hanı dolduktan ne kadar sonra tuttuğunu ölçer.
- **İlk işe alım taşınmadır.** Ev 1 masa olduğu için ilk çalışan İş hanına taşınmayı ister; $4.000 kira ilk çalışanla başlar.
  Akış: Atlas'ta arama kilitli ve nedenini yazar → "Ofisleri gör" şehir haritasında İş hanı kartını açar → kart masa, kira
  ve şartları yazar, "Taşın"ın ipucu yeni aylık gideri söyler → taşınma kararı verildiği anda tavan yeni ofisin masasıyla
  okunur ve arama başlayabilir; aday taşınma bitmeden işe başlamaz (onay bekliyor). **Bilinen bağ:** İş hanı'nın şartı
  Frank'in çekidir (`office_constants.gd:32`); tavanla ilk işe alım çeki bekler (bot çeki B2B'de 12 ile 13., B2C'de 22 ile
  24. haftada alıyor; R15 §3.1). Şartın kalıp kalmayacağı C0s'in iki hâlli ölçümüyle E1'de Erdem'e gider.
- **Kapılar yeniden ölçülür:** Bootstrap runway (6,7 ay) ve ilk 40 haftanın açığı (25 ile 45 bin) bu giderlerle yeniden
  ölçülür (C0s, E2); tutmazsa sabit sessizce değişmez, ölçüm ve öneri Erdem'e gider (§4.3 Risk 2).

**Oynanışa etkisi**
- Karar: ne zaman taşınıp ilk çalışanı almalı; sonra kimi almalı, ne zaman büyük ofise geçmeli. Para ilk kez karar doğurur
  (bugün ofis bedelsiz, R15 §8.8). Okunuş: beş kalemli liste ve Atlas'ta "Masa 10 · boş 2". Taşınma koşuda 2 ile 3 kez.
- 1 kişi: evde gider yok; Bootstrap'ın baskısı para değil zamandır (MVP, ilk imza, Frank). İlk işe alım aylık gideri tek
  adımda yaklaşık $7.000 ile $8.500'e çıkarır (kira ve ×1,5 ile junior geliştirici $3.000 ile $4.500) [hesap]: oyunun ilk
  büyük para kararı. Risk: ilk haftalarda para hissi yok; para baskısı ayrı kalibrasyon işidir (`ACIK_ISLER.md` 3).
- 10 ve 36 kişide tavan büyümeyi durdurur: oyuncu taşınır ya da kadroyu değiştirir; Plaza'nın marka şartı İş hanı'nı uzun
  süre dolu tutarsa büyüme duvarı hissi verir (C0s ölçer). 50 kişi: maaş en büyük kalem, Loft $18.000.
- **Oynanış riski 2:** servis kalkınca B2B'de en derin açık 41 binden 13 bine iniyordu (MEMNUNIYET_SIM §4.1; eski kurucu
  satırı ve kirayla, yeni tahmin C0s'te). Sorun harcanacak yerin yokluğu (R15 §4.6); kasa işe alıma, taşınmaya ve Kurumsal
  kademeye dönüşür.
- Hüküm: tut, güçlendir. Kapılar §4.3 Risk 2.

### Karar 4 · Kurumsal sunucu maddesi (Erdem, v2 §2.3)
- 3★ ve üstü hesap Kurumsal değilken imzalanabilir; şart sözleşmeye yazılır. Süre 8 hafta (onay bekliyor; Erdem'in örneği
  "iki ay").
- Süre dolunca zarsız kural: memnuniyet eşiğin 20 puandan az üstündeyse fesih bildirimi, sözleşme 4 hafta sonra biter; bu
  sürede Kurumsal'a geçiş bildirimi geri aldırır. 20 ve üstündeyse hakkını saklı tutar; "Kurumsal sunucu maddesi −10" durum
  terimi madde açık kaldıkça durur, birikmez. Kural her ay başı yeniden işler. Kurumsal'dan inilirse süre yeniden başlar.
  Güvenlik sertifikası maddeyi karşılamaz.
- Etiketler "Sunucu maddesi · 12 Mar", "Fesih bildirimi · 9 Nis"; Genel Bakış'ta "Kurumsal sunucu bekleyen 1 hesap".

**Oynanışa etkisi:** büyük hesabı Kurumsal'ın parasıyla tutmak mı, maddeyi koz bırakmak mı; okunuş tarihli etiket ve −10.
Mail saat durdurmaz. 1 kişi: 3★ aday yok. 50 kişi: tek geçiş bütün maddeleri kapatır. Hüküm: tut (hüküm satır 10).

### Karar 5 · Memnuniyet satırların toplamıdır
- **Kayma yok; memnuniyet satırların toplamıdır** (Erdem, 17 ve 18 Ekim: "memnuniyet kesinlikle öyle olmalı"). Memnuniyet
  her tik yeniden toplanır, hedefe yürümez:
  `Memnuniyet = Ürün uyumu − Açık hata terimi + Defter + Durum terimleri − Güncelleme yaşı`, 0 ile 100 arasında.
- **Ürün uyumu** Q'nun `ProductQuality.account_fit(c).value`'sudur (`PRD_FAZ_Q_KALITE.md` Karar 5); C yeniden tanımlamaz.
  Ürün iyileşince hemen artar. Hesabın beklentisi yıldızına bağlıdır, evreye değil (Q3); evre değişince memnuniyet
  kaymaz. Beklentiyi Q okur; C beklenti tutmaz.
- **Açık hata terimi** (Erdem): min(3 × H, 60); H, hesabın kullandığı alanlarda (Q'nun `uses_area`'sı: Çekirdek ve
  iki vurgu alanı; Q Karar 10) alan ağırlığıyla canlı hat başına açık hata. Kalan alanın hatası terime girmez. Adet yerine
  yoğunluk: ekip ve ürün büyüklüğünden bağımsız. `fix_worst` geç dönemde yaklaşık −4 (v3 §5.2). Tavan 60 kalır; Q'dan
  sonra M5 tutmazsa 62 ve 64 ölçümüyle Erdem'e dönülür (Erdem onayladı).
- **Defter** (onay bekliyor; tutarlar v3 §5.3): söz zamanında +6 kalıcı, geç −3 (8 hafta), tutulmadı −12 (13 hafta);
  isteği yayına girdi +4 kalıcı (yalnız 3★, Karar 11); kesinti ve ertelenen hata B'nin sayılarıyla (13 ve 8 hafta); olay
  kartının `satisfaction_delta`'sı (8 hafta). Olumlu kalıcılar en çok +10 (`b2b_constants.gd:267`). Olumsuz satır
  doğrusal söner; sahibin Müşteri İlişkileri çıktısı süreyi kısaltır (`cs_dampen`, `b2b_constants.gd:184-190`).
- **Durum terimleri** (onay bekliyor): indirim +8, zam −2, gönülsüz yenileme −6 (sonraki yenilemeye kadar), Kurumsal madde −10.
- **Silinenler** (v3 §5.7): kayma, gizli hedef, tabanlar, anlık sıçramalar, tek sayılık güven defteri. Risk makinesi ve
  ayrılma eşiği formülü kalır.
- **Adsız destek zararı kalkar** (Erdem; `support_system.gd:243-268`); bedeli açık hata terimi taşır. A'nın Karar 9'undan
  sapma raporda yazılır.
- **B'nin bağları:** çip satır eklenmiş toplamı okur; B'nin kalıcı izi, kesinti ve `trust_delta` deftere satır yazar;
  `satisfaction_delta` 8 haftalık satır olur (iz 1,1 haftadan 4,9 haftaya uzar; 13 kart dosyası, v3 §8 madde 4).

**Oynanışa etkisi**
- Karar: hangi sözü vermeli, hangi hattı düzeltmeli. Okunuş: ipucu en çok 5 satır; tabloda en büyük olumsuz satırın adı.
- Her düşüşün adı vardır (R13 Ders 2): adsız düşüş simülasyonda 0, bugünkü kodda 1.450 (MEMNUNIYET_SIM M1); RAPOR_B soru
  2 defterle çözülür.
- **Oynanış riski 1:** bakımlı üründe ortalama memnuniyet 92 ile 96 (MEMNUNIYET_SIM §0 madde 4): U doyumu, Q kalibre eder
  (Q4). Yenilemenin zamla bitmesi sorun değildir (Erdem); çeşitliliği koltuk sonuçları verir (Karar 8).
- 1 hesap ile 330 hesap aynı çalışır; defter hesap başına en çok 6 ile 8 satır. Hüküm: tut (hüküm satır 4).

### Karar 6 · İmza gerçek değerle açılır; zayıf ürün imza kaybeder
- **İmza değeri gerçektir** (Erdem: "direkt o şekilde başlasın"): aynı formül, defter boş, yaş 0. Beklentiyi karşılayan,
  hatası az üründe 65 ile 70.
- **İmza kapısı** (Erdem): aday, imzada memnuniyeti eşiğinin en az 10 puan üstünde olmayacaksa imzalamaz. Kapı hesabın
  yıldızına göre okunan ürün uyumunu kullanır (Q3), evreye bakmaz.
- **Q'nun satışçı zarıyla tek kayıp, çift ceza yok** (Q2; tanım Q Karar 14). Satışçının kapanışında (`_close`,
  `sales_rep_system.gd:232-245`) önce C'nin kapısı bakılır: geçemeyen aday zarsız kaybedilir; geçen aday yalnız Q'nun
  zarını atar ve zar kapıyı geçen anlaşmada en az %60'tır (onay bekliyor). C ikinci zar ya da ret eklemez. Kurucu yolunda
  kapı görüşmenin sonucunda okunur: kapının altındaki görüşme Q'nun kayıp nedeni satırıyla biter (Q §3.1), mail gelmez;
  imza değeri anlaşma planı dolunca `sales_finalizer.gd:84`'te yazılır. Kaybın alanı iki yolda da Q'nun `loss_area`'sıdır
  (tavan devredeyse Çekirdek, değilse en düşük oranlı beklenen alan). Kayıp maili tek ve Q'nundur (`Patron, {company} ile
  anlaşamadım. {area} tarafını eksik buldular.`). `loss_area` boşken kapı açık hata yüzünden reddederse neden, hesabın
  kullandığı alanlardan en çok açık hatası olanıdır; C yalnız bu biçimi yazar (§3). Satış günlüğünde tek satır.
- Aday kartı U sözcüğünü görüşmeden önce yazar (hüküm satır 5); sözcük Q'nun, yeri C'nin. Tavanın kuralı ekranda cümle
  olarak yazmaz (Q2).

**Oynanışa etkisi**
- Karar: önce ürünü güçlendirmek mi, o sektöre şimdi satmak mı. Okunuş: mail ya da itiraz, zayıf alanı adıyla.
- Oyunun ilk açıklanmış kaybıdır (R13 Ders 10); bugün görüşmeler %98 kazanılıyor (R15 §8.3). Simülasyonda kapı
  `fix_worst`'te imzaların %13,6'sını çeviriyor (MEMNUNIYET_SIM §2.9; evre beklentisiyle, C0s yıldızla yeniden koşar).
- 1 kişi: kapıya ilk 1★ KOBİ'ler gelir ve MVP onlara yeter (Q3); kapı ilk kez 2★ adaylarla ısırır, reddin nedeni hangi
  kartı açacağını söyler. 50 kişi: satışçıların kayıpları tek mailde ve Satış günlüğünde nedeniyle görünür.
- Hüküm: güçlendir. Kapı (Q ile ortak): ürün kaynaklı kayıp (kapı ve Q'nun zarı birlikte) bakımlı üründe imza denemelerinin
  %5 ile 20'si, bakımsızda en az %25.

### Karar 7 · Uzun süre güncelleme almayan ürün
- **Ölçü** (Erdem): hesabın sektörünün **iki vurgu alanına** dokunan son yayından bu yana geçen hafta; Çekirdek sayılmaz.
  Dokunmak: o alanların bir hattında yayına giren herhangi bir kart (kademe, cila, istek, düzeltme). Neden: Çekirdek her
  hesabın alanıdır ve D'den sonra sprint sabit 2 haftadır (D4): sprint 2 haftada bir kapanır ve çoğunlukla sürüm çıkarır;
  v3'ün tanımıyla sayaç hiç işlemez.
- **Terim** (onay bekliyor): 26 haftaya kadar 0; sonra her tam 4 haftada −1; en çok −12. Dokunan ilk yayın sıfırlar ve
  defterde bir kez yazar. Sayaç 20. haftadan itibaren ipucunda.

**Oynanışa etkisi:** tek alana yüklenmek mi, ihmal edilen sektörün alanına dokunmak mı; aylar içinde, saat durmaz. 1 kişi:
nadiren görür. 50 kişi: çok sektörlü defterde ihmali söyleyen tek sinyal. Hüküm: güçlendir; kapı §4.3 Risk 1.

### Karar 8 · Sözleşme yenileme (Erdem, v2 §2.6 ve 18 Ekim)
- **Akış değişmez** (Erdem: "C5, okey"). Sözleşme 12 ay; yenileme dönemi bitişe 8 hafta kala açılır. Tutum görünür iki
  sayıdan (memnuniyet ve eşik) ve görüşenin Satış yıldızından gelir; fiyatta zar yok. Basamaklar +%8, aynı, −%10, −%15.
  Satışçı yolunda rapor (iki seçenek, gruba göre); kurucu yolunda mail teklifi, tek karşı teklif turu, kurucu saati yok.
  Cevapsız kâğıt aynı fiyatla yenilenir.
- **Zam normaldir** (Erdem: "%100 zamla bitmesinde bir sakınca görmüyorum"; enflasyon). Tutum bantları v2 §2.6.1'deki gibi
  kalır, kaydırılmaz. "En çok %50 zam, en az %15 indirim" kapısı kalktı.
- **Sonuç çeşitlidir** (Erdem). Fiyat tutumdan gelir; koltuk ve ürün dışı ayrılma ayrı sonuçtan. Yenileme dönemi açılınca
  hesap başına tek zar (bütçe kesintisiyle aynı RNG akışı, Karar 9); aşağıdakilerden en çok biri olur, çoğu hesapta hiçbiri.
  Memnun hesap: memnuniyet ≥ eşik + 12 (Karar 9'un ölçüsü). Sonuçlar memnuniyete dokunmaz.

| Sonuç | Kime | Neye bağlı | İhtimal ve miktar (onay bekliyor) |
|---|---|---|---|
| Koltuk artışı | Memnun hesap | Hesabın büyümesi (küçük şirket hızlı büyür: yıldız); sektörün eğilimi (büyüyen, olağan, durağan); memnuniyet (eşik + 25 ve üstünde ×1,5) | Taban 1★ %25, 2★ %20, 3★ %15; sektör ×1,25 / ×1 / ×0,75; koltuk %10 ile %30 artar |
| Mali koltuk azalışı | Memnun hesap | Maliyet kısması; memnuniyetten bağımsız; durağan sektörde ×1,5 | 1★ %5, 2★ %4, 3★ %3; koltuk %10 ile %25 azalır |
| Başka ürüne geçiş | "Yenilemeyecek" dışındaki her hesap | En zayıf vurgu alanının sözcüğü (Q): Zayıf ×2, Güçlü ×0,5 | 1★ %1,5, 2★ %1, 3★ %0,5; yenilemez, sözleşme sonuna kadar öder |
| Bütçe kesintisi | Her hesap | Karar 9 | Karar 9 |

- **Her sonucun nedeni yazar:** satışçı raporunda bir satır, sonuç mailinde hesabın cümlesi (§3). Başka ürüne geçişin
  cümlesi zayıf alanı adıyla söyler; durup dururken düşüş yasağına uyar (paket §4).
- Yeni koltuk sayısı fiyat basamağıyla birlikte yeni sözleşmede işler; koltuk artışı sunucu yükünü büyütür (Karar 1). Yıldız
  imzada sabittir, koltuk artışı 2★ hesabı 3★ yapmaz (onay bekliyor). **Sektörün eğilimi** C'nin verisinde sektör
  kimliğiyle durur (Q'nun tablosuna yazılmaz); 13 sektörün eğilimini C0s önerir. Yenileme ipucunda tek sözcükle yazar.
- **Kesinti kuralı** (onay bekliyor; v2 §2.6.5'in ayda üç kâğıdı yerine): ayda en çok bir yenileme kâğıdı; satışçı raporu ve
  masası taşan hesapların kurucu kâğıdı tek kâğıtta birleşir; karşı teklif kâğıdı ertesi haftaya düşer. Kâğıt haftalık
  kesinti bütçesine sayılır (haftada en çok 1). Sıra: acil durum > söz olayı > yenileme kâğıdı > sprint kâğıdı > gönder
  sorusu > istek kartı. Sıraya giremeyen kâğıt 2 haftalık süresi içinde sonraki haftaya kalır, giremezse cevapsız kâğıdın
  kuralı işler (aynı fiyat).
- **Kesinti tablosunu C5 kurar** (tek yer; D gönder sorusunu sprint kâğıdıyla istek kartı arasına ekler): yenileme ve istek kesintisi
  `SprintSystem.record_interrupt` ile yazılır, `_paper_blocked`'ın tür listesine girer (`sprint_system.gd:564-567`,
  `:1270-1274`); servisin çöktüğü acil durum her zaman gelir.
- **Kâğıt yalnız oyuncunun vereceği bir karar varsa gelir** (Erdem, v2 §2.6.5): en az bir hesap "İndirim ister" ya da daha
  kötüyse (satışçı yolu) ya da Yenilemeyebilir etiketliyse (kurucu yolu; ilk yenileme her durumda kâğıtla). Koltuk
  sonuçları, başka ürüne geçiş ve bütçe kesintisi karar değildir: kâğıt getirmez, raporda ya da sonuç mailinde satırdır.
  Bütçe haftada en çok 1 ve sprintte en çok 1 durmadır (hüküm risk 5; D'nin 2 haftalık sprintinde ikisi birlikte işler).
- **Beklenti:** hesabın beklentisi yıldızınındır (Q3). Yenileme dönemi açılınca Q'nun hesap okuması (`market_ref`, Q'nun
  seam'i) tazelenir; değer değişirse defterde adıyla bir satır yazar. C5 yalnız tetikleyiciyi sözleşme kaydının açılışına
  taşır (Q'nun PRD'si §9).
- **Silinen:** temsilcinin "yenileme sinyali" kâğıdı (`customer/request_renewal.json`, `customer_rep_system.gd:341-345`).

**Oynanışa etkisi**
- Karar: satışçının raporunu onaylamak mı, indirim isteyene aynı fiyatı teklif etmek mi; kurucu yolunda hangi teklif.
  Bakımlı üründe kâğıt seyrek gelir (Erdem kabul etti); yenileme çoğu ay haberdir: "Kuzey Lojistik %8 zamla ve 12 koltuk
  daha ekleyerek yeniledi." Karar ihmal edilen üründe kalır; zayıf vurgu alanı başka ürüne geçişi iki katına çıkarır;
  koltuk artışı yenileme ayını sunucu kararına bağlar.
- **Oynanış riski 1:** yenileme orta oyunun karar kaynağı değildir; bakımlı üründe karar imza kapısından, sprintten,
  sözden, kademeden ve ofisten gelir (§4.3 pencere kapısı). **Demo:** ilk yenileme yaklaşık 53. hafta, bot Series A'yı 57
  ile 71. haftada imzalıyor (hüküm §0 madde 4); yenileme EA ve tam oyunun işidir.
- 1 kişi: 5 ile 20 hesap, yılda 1 ile 5 koltuk sonucu [hesap]. 50 kişi: 330 hesapta ayda yaklaşık 27 yenileme, tek kâğıt.
  Satışçı masası hesap başına 0,25 hafta (onay bekliyor); büyük ölçekte kırılmaya en açık sabit, §4.2 ölçer.
- Hüküm: hükmün "bantlar kaysın" önerisi kalktı; çeşitliliği koltuk sonuçları verir (hüküm satır 8'in yerine).

### Karar 9 · Ürün dışı yenilememe (bütçe kesintisi), kâğıtsız (Erdem)
- **Olay kalır** (Erdem: "düşük de bir ihtimal olsa ... harcamalarımızı azaltmaya gidiyoruz"). Yenileme dönemi açılınca hesap
  başına bir kez: 1★ %2, 2★ %1,5, 3★ %1; Karar 8'in koltuk sonuçlarıyla aynı zar; memnuniyete dokunmaz.
- **Kâğıt yok** (Erdem). Memnun hesap (memnuniyet ≥ eşik + 12) koltuğunu yarıya indirerek yeniler; mail nedeni ve yeni ücreti
  yazar. Memnun olmayan yenilemez; Satış günlüğünde neden "Bütçe kesintisi". Sözleşme sonuna kadar ödeme sürer. Dayanak:
  https://stealthagents.com/research/saas-churn-rate-statistics-2026 (v3 §4).

**Oynanışa etkisi:** v3'ün kâğıdı sahte seçimdi (T, R14 T07); kol sonucun ağırlığındadır: memnun tutulan hesap küçülür,
tutulmayan gider. 330 hesapta yılda 5,75 olay (MEMNUNIYET_SIM §2.11), 20 hesapta 0,3; saat durmaz. Hüküm: sadeleştir.

### Karar 10 · Genel Bakış kâğıdı ve Kararlılık satırı
- **Ürün penceresi üç kâğıt** (C_PLAN §2.1): GENEL BAKIŞ | SPRINT | ÇEYREK. Genel Bakış v1.0'dan önce kilitli ("v1.0
  yayınlanınca açılır."). Pencere son açık kâğıdı hatırlar; sürüm notu açıkken SPRINT'te açılır; kâğıt kendiliğinden öne
  çıkmaz. ÇEYREK'in PM kilidi (`product_tab.gd:199-200`) D'nindir.
- **Beş blok, açıklama satırı yok:** Sürüm, Kararlılık, İstekler, Sunucu, İş. **Sürüm:** sürüm, yaşı, sonraki sürüm ve
  sprinti; altında Q'nun ürün durumu satırları (kelime ve kareyle, çıplak sayı yok; KALITE_v2 §5.1).
- **Kararlılık** (Erdem, 17 Ekim: "açık hata kesiminin başlığı olarak kalsın"): eski Destek bloğunun başlığı. İlk satır
  `Kararlılık · 7 açık hata ▲2 · son 4 haftada 1 kesinti`; ▲ son haftalık tike göre değişim (Erdem: "2 yükseldiği
  anlamındaysa okey"). Altında en kötü iki hat, A'nın biçimiyle; tıklanınca SPRINT'te hattın düzeltme kartı bir kez
  vurgulanır. Temsilci varken adı yazar.
- **İş:** tek satır, Satış'a gider. Bloklar Karar 11 ve 1'dedir.

**Oynanışa etkisi:** karar doğurmaz, kararların okuma yeridir (Erdem: "ürün kararlılığını ... oyuncu hiçbir yerde
görmüyor"). Her blok tek satırla bir karara bağlanır: Kararlılık düzeltme kartına, Sunucu Karar 1'e, İstekler sprinte, İş
Satış'a. 1 kişi: v1.0 sonrası, az satır; 3★ yokken İstekler tek satır. 50 kişi: taşmaz. Hüküm: tut.

### Karar 11 · İstekler yalnız büyük hesaplardan (Erdem)
- **İstekleri yalnız 3★ ve üstü hesaplar yapar** (Erdem: "yalnızca 3 yıldız ve üzeri hesaplar talepte bulunur"). 1★ ve 2★
  istek açmaz; yenilemeden önceki istek penceresi de (`sprint_bridges.gd:21-55`) yalnız 3★ ve üstünde açılır, yani 1★ ve
  2★ yenilemede geri bildirim vermez. 1★ ve 2★ söz almaya devam eder (satış görüşmesinin sözü, şikâyet ve elde tutma
  kartları); hata şikâyeti istek değildir. B2C değişmez.
- **Her istek kesinti olarak gelir ve yalnız söz sorar** (hüküm satır 18'in kalanı): "Söz ver" ya da "Listeye al". Listedeki
  istek plandaki istek listesine düşer (D'nin); yayına girerse defterde +4, girmezse etkisiz (SPRINT_DUZENI K8).
  `request_feature.json`'un "şimdi değil" −4'ü ve süre dolumu −5'i kalkar. Kesinti sırasında en alttadır (Karar 8); sıraya
  giremeyen istek süresi içinde sonraki haftaya kalır, giremezse sessizce listeye düşer.
- **İstekler bloğu** (Erdem: "İstekler kısmı okey"): en çok üç istek; B2B "<özellik> · <hesaplar> · ayda $<n>", B2C
  "<özellik> · <n> yorum"; tıklanınca SPRINT'te kart vurgulanır. B2B'de istek kartla geldiği için temsilci şartı kalkar; 3★
  hesap yokken blok tek satırdır (§3). B2C'de temsilci şartı kalır (veri türetilir, C_PLAN §2.2); temsilci yokken 1 ile 2
  kullanıcı alıntısı (Erdem; metinler E'de). B'nin uykudaki üç B2C PM kâğıdı bununla uyanır; "iki hesap aynı kartı istedi"
  (RAPOR_B soru 14) artık iki 3★ hesap ister.
- Destek raporunun "En çok istenen" bölümü, HESAPLAR'ın İstek sütunu, sürüm anının "isteği karşılandı" notu ve PM
  kâğıdının istek konusu B2B'de yalnız 3★ isteğiyle çalışır.

**Oynanışa etkisi**
- Bugün en büyük angarya kaynağı: haftada 1,1 kesinti, üç şıktan ikisi aynı sonuç (R15 §8.2). Kalan kesintide tek gerçek
  ödünleşim kalır: sprint kapasitesi mi, sözün kalıcı +6'sı mı. Okunuş: "Ege Sigorta istiyor: aylık rapor aktarımı."
- **Erken oyunda B2B isteği yoktur.** Kapıya önce 1★ ve 2★ hesaplar gelir (Q3); istek büyük müşteriyle gelen yeni kuraldır
  (R13 Ders 8). İlk 3★ imzası yeni bir karar türü açar: söz ver ve sprint kapasitesini ona ayır. Erken oyunun B2B kararları
  satış, imza kapısı, sprint ve acil durumdur.
- 1 kişi: istek yok. 50 kişi: istek yalnız 3★ sayısıyla büyür, kesinti bütçesi haftada 1. Hüküm: sadeleştir; "ilk çeyrek"
  kolu kalktı. Kapı: istek kesintisi koşuda en çok 25.

### Karar 12 · Haftalık destek raporu (Erdem, v2 §2.7)
- Destek işindeki en iyi temsilci gönderir; haftada en çok bir. **Yeni bir şey yoksa gelmez**; okunmamış eski rapor yenisi
  gelince düşer (Erdem). Mail saat durdurmaz. Kalıp satışçının haftalık özetidir (`sales_rep_system.gd:271-286`).
- **Yeni:** bir hat Öncelikli eşiğine (5, `sprint.json:7`) ulaştı ya da sıfırlandı; en kötü hat değişti; yeni istek
  bilindi (B2B'de yalnız 3★); bir düzeltme yayına girdi; temsilci yetişemedi. B2B "En çok istenen" bölümü yalnız 3★
  isteklerini yazar; 3★ isteği yoksa bölüm çizilmez.
- **"Yetişemedim"** (onay bekliyor): cevapsız bildirim haftanın gelenlerinin beşte biri ya da fazlası; metin sayıyı söyler.
  Düğme en kötü hattın düzeltme kartını SPRINT'te açar.

**Oynanışa etkisi:** karar ikinci temsilci ve en kötü hattın kartıdır. 1 kişi: rapor yok. 50 kişi: rapor tek. Hüküm: tut.

### Karar 13 · HESAPLAR tablosu (Erdem, v2 §2.4)
- Satış'ta ADAYLAR | HESAPLAR. Sütunlar (Erdem: "sütunları okey"): Firma ★, Koltuk, Aylık, Memnuniyet, Durum, Yenileme,
  İstek, Temsilci. Para hücresi aylık; kalan sözleşme değeri Yenileme ipucunda.
- **Her başlık sıralar** (Erdem); ilk tık v2 §2.4.3'teki yön, ikinci tık tersi. Dört görünüm (Tümü, Durumu olan, Yenilemesi
  yakın, Temsilcisi olmayan) sayılarıyla; firma araması. Sıra ve görünüm pencere açılıp kapanınca hatırlanır, kayda yazılmaz.
- **Durum** (en ağırı yazar): Yenilemeyecek, Fesih bildirimi, Ayrılabilir, Yenilemeyebilir, Sunucu maddesi; "Onboarding",
  "Risk", "Büyümeye açık" yok. Kart listesi (`sales_tab.gd:511-560`) tabloya döner; "İlgilen" yalnız Ayrılabilir ve
  Yenilemeyebilir satırında. İstek sütunu 1★ ve 2★'ta boştur.

**Oynanışa etkisi:** kimle ilgilenmeli, kime temsilci atamalı; 330 hesapta "Durumu olan" yalnız kararı olan hesabı getirir.
Hüküm: tut (OYNANIS_HUKMU §1.3).

### Karar 14 · Değişmeyenler (Erdem, v2 §2.8 ile §2.10)
MRR ortak dil; koltuk fiyatı aylık; sözleşme 12 ay; nakit aylık. Alanın ve Ar-Ge düğümünün TR adını Q değiştirir (Q K6);
Satış'taki "Onboarding" etiketi ve "Onboarding gelecek hafta bitiyor" satırı C8'de kalkar. Rakip analizi kapsam dışı.

## 3. Oyuncu ne görecek
Sayılar örnektir. Metinler TR ve EN, tiresiz, tam cümle; hepsi "TR/EN onay bekliyor". Ekranlar Menajer dilindedir
(koyu sıcak zemin, Barlow Condensed başlık, IBM Plex Sans gövde; `docs/mockups/menajer/screens/urun`, `satis_finans`).

**Ürün penceresi · Genel Bakış (B2B)**
```
 GENEL BAKIŞ | SPRINT | ÇEYREK                                              Geçmiş ○
┌ SÜRÜM ───────────────────────────────┐┌ KARARLILIK ────────────────────────────────┐
│ v1.4 · 3 hafta önce                  ││ 7 açık hata ▲2 · son 4 haftada 1 kesinti   │
│ Çekirdek       Yeterli  ■■■■■□□□□□   ││ Fatura · 4 açık hata · 3 hesap          ↑ ›│
│ Entegrasyonlar Zayıf    ■■□□□□□□□□   ││ Stok   · 2 açık hata · 1 hesap          ↓ ›│
│ Güven & Ölçek  Yeterli  ■■■■■□□□□□   ││ Temsilci Selin K.                          │
│ Sonraki v1.5 · Sprint 9              │└────────────────────────────────────────────┘
└──────────────────────────────────────┘
┌ İSTEKLER ─────────────────────────────────────┐┌ SUNUCU ─────────────────────────────┐
│ Toplu fatura onayı · Kuzey, Yelken · ayda $1.800 ›││ [Ekonomik │ Standart │ Kurumsal] │
│ Aylık rapor aktarımı · Poyraz · ayda $600       ›││ Kapasite 6.500 koltuk · ayda $15.600│
└───────────────────────────────────────────────┘│ Yük %80 · boş pay 1.300 koltuk     │
┌ İŞ ─────────────────────────────────────────────┐│   · ayda $3.120                    │
│ MRR $14.200 · Yıllık $170.400 · 9 hesap · +2 −1 ›││ [Azalt · 650]   [Artır · 650]      │
└─────────────────────────────────────────────────┘│ Otomatik ayarla ○                  │
                                                   │ Kurumsal sunucu bekleyen 1 hesap   │
                                                   └────────────────────────────────────┘
```
B2C'de "koltuk" yerine "kullanıcı" yazar; madde satırı çizilmez; İstekler "Kargo takibi · 38 yorum" biçimindedir. B2B
İstekler bloğundaki hesaplar 3★'tır (Karar 11). Alan kareleri Q'nun `area_row`'udur.

**Sunucu bloğunun satırları**

| Yer | TR | EN |
|---|---|---|
| Artır ipucu | `650 koltuk ekle · ayda $15.600 → $17.160 · yük %80 → %73` | `Add 650 seats · $15,600 → $17,160 a month · load 80% → 73%` |
| Azalt ipucu | `650 koltuk çıkar · ayda $15.600 → $14.040 · yük %80 → %89` | `Remove 650 seats · $15,600 → $14,040 a month · load 80% → 89%` |
| Azalt yetmezse | `Yük %112 olur. Kapasite yetmez.` | `Load becomes 112%. Capacity falls short.` |
| Büyüme | `Bu büyüme hızıyla yük 3 hafta sonra %90'ı geçer.` | `At this growth rate, load passes 90% in 3 weeks.` |
| Yük %90 üstü | `Yük %94. %90'ın üstünde kesinti ihtimali 1,5 katına çıkar.` | `Load 94%. Above 90%, the chance of an outage is 1.5 times higher.` |
| Yük %100 üstü | `Yük %104. Kapasite yetmiyor; kesinti ihtimali 2,5 katına çıkar.` | `Load 104%. Capacity falls short; the chance of an outage is 2.5 times higher.` |
| Sürüm notu | `v1.7 ile kapasite 7.000 koltuktan 6.300 koltuğa indi. Yük %78 → %87.` | `With v1.7, capacity fell from 7,000 seats to 6,300. Load 78% → 87%.` |
| Otomatik ayarla ipucu | `Açıkken yük %80 olunca kapasite bir adım büyür ve yük yaklaşık %65 olur. Kapasiteyi küçültmez; boş payın parası bu blokta yazar.` | `When on, capacity grows one step once load reaches 80%, bringing load to about 65%. It never shrinks capacity; the cost of the spare room is shown in this block.` |
| Son otomatik büyüme | `Otomatik büyüme 12 Mar · 5.200 → 6.500 koltuk` | `Automatic increase 12 Mar · 5,200 → 6,500 seats` |

Büyüme satırı yalnız anahtar kapalıyken, son otomatik büyüme yalnız açıkken çizilir. Kademe ipucu: `Standart · 50 koltuk
başına ayda $120 · Kesinti ihtimali ×0,5 · Kurumsal sözleşme şartını karşılamaz` / `Standard · $120 a month per 50 seats ·
Outage chance ×0.5 · Does not meet the enterprise contract clause`.

**Finans:** beş kalem, sıfırı çizilmez, kurucu satırı yok. Hiç kalem yokken `Bu ay gider yok.` / `No expenses this month.`
Ofis ipucu `İş hanı kirası · ayda $4.000` / `İş hanı rent · $4,000 a month`.

**Ekip · Atlas ve ofis haritası (masa tavanı)**

| Yer | TR | EN |
|---|---|---|
| Atlas, evde | `Evde tek masa var, o da senin. İlk çalışanını almak için İş hanına taşınman gerekiyor.` | `There is one desk at home, and it is yours. You need to move to the İş hanı to hire your first employee.` |
| Atlas, ofis dolu | `Ofiste boş masa yok. Daha büyük bir ofise taşınınca işe alabilirsin.` | `There is no free desk in the office. You can hire once you move to a bigger one.` |
| Atlas, tavan satırı ve düğme | `Masa 10 · boş 2` · `Ofisleri gör` | `Desks 10 · 2 free` · `See offices` |
| Ofis kartı | `10 masa · ayda $4.000 kira` (bulunulan ofiste `10 masa · 8 dolu · ayda $4.000`); ev `1 masa · kira yok` | `10 desks · $4,000 rent a month` (current office `10 desks · 8 taken · $4,000 a month`); home `1 desk · no rent` |
| Taşın ipucu | `Kira ayda $4.000. Aylık gider $120 → $4.120. Taşınma 1 hafta sürer; kira taşındığın hafta başlar.` | `Rent is $4,000 a month. Monthly costs $120 → $4,120. The move takes a week; rent starts the week you arrive.` |
| Plaza şartı | `En az 10 kişi (sen dahil)` | `At least 10 people (you included)` |

**Satış · hesap memnuniyeti ipucu** (HESAPLAR v2 §2.4.3'ün taslağıdır; memnuniyetin yanında en büyük olumsuz satırın adı:
`41 · Kesinti`)
```
Memnuniyet 61 · ayrılma eşiği 36                         Satisfaction 61 · leaves under 36
  Ürün uyumu (Çekirdek Yeterli, Entegrasyonlar Zayıf) 66   Product fit (Core Solid, Integrations Weak)  66
  Açık hata (baktığı alanlarda 9)                     −4   Open bugs (9 in the areas it uses)           −4
  Kesinti 12 Mar, 5 saat · 9 Nis'te silinir           −2   Outage 12 Mar, 5 hours · gone by 9 Apr       −2
  Söz tutuldu: Stok Sayacı                            +4   Promise kept: Stock Count                    +4
Yenileme döneminde ürün uyumu 58 okunur.                 At renewal, product fit reads 58.
```
Sıfır terim çizilmez; son satır yalnız Q'nun yenileme okuması bugünkünden farklıysa çizilir. Yaş satırı 20. haftadan sonra:
`Son güncelleme 22 hafta önce. 26 haftadan sonra her ay 1 puan düşer.` / `Last update 22 weeks ago. After 26 weeks it drops 1
point a month.` İmza maili satırı: `Memnuniyet 68 ile başlıyor: ürün uyumu 72, açık hata −4.` / `Satisfaction starts at 68:
product fit 72, open bugs −4.` Kayıp maili ve itiraz Q'nundur (Karar 6). C'nin açık hata biçimi ve kısa satırlar:

| Yer | TR | EN |
|---|---|---|
| Kayıp, açık hata (satışçı) | `Patron, {company} ile anlaşamadım. {area} tarafındaki açık hataları sordular, ikna edemedim.` | `Boss, I could not close {company}. They asked about the open bugs in {area} and I could not win them over.` |
| Kayıp, açık hata (görüşme) | `{area} tarafındaki açık hatalar bizi düşündürüyor. Onlar kapanınca yeniden konuşalım.` | `The open bugs on your {area} side worry us. Let us talk again once they are closed.` |
| Genel Bakış kilidi | `v1.0 yayınlanınca açılır.` | `Opens when v1.0 ships.` |
| İstekler, 3★ yok | `İstekleri büyük hesaplar (3★) yapar. Henüz böyle bir hesabın yok.` | `Requests come from large accounts (3★). You have none yet.` |
| İstek kesintisi | `Ege Sigorta istiyor: aylık rapor aktarımı.` | `Ege Sigorta is asking for monthly report export.` |
| Kurumsal etiketler | `Sunucu maddesi · 12 Mar` · `Fesih bildirimi · 9 Nis` · `Kurumsal sunucu bekleyen 1 hesap` | `Server clause · 12 Mar` · `Termination notice · 9 Apr` · `1 account waiting for Enterprise servers` |
| Yenileme haberi | `Kuzey Lojistik %8 zamla ve 12 koltuk daha ekleyerek yeniledi.` | `Kuzey Lojistik renewed with an 8% increase and 12 more seats.` |

**Yenileme kâğıtları:** satışçı raporu v2 §2.6.3, kurucu kâğıdı, cevaplar maili ve karşı teklif kâğıdı v2 §2.6.4'teki
gibidir (gövde en çok 6 hesap satırı; fazlası tek satır). Satışçı raporuna sonucu olan her hesap için bir satır eklenir
(Karar 8 ve 9); kâğıtsız aylarda aynı satırlar sonuç mailindedir, kurucu yolunda cevaplar mailinde hesabın ağzındandır.

| Sonuç | TR | EN |
|---|---|---|
| Koltuk artışı | `Koltuk ekliyor: Kuzey Lojistik. Ekipleri büyüdü; 60 koltuktan 72 koltuğa çıkıyor.` | `Adding seats: Kuzey Lojistik. Their team grew; going from 60 seats to 72.` |
| Mali azalış | `Koltuk azaltıyor: Poyraz Lojistik. Maliyetleri kısıyorlar; 40 koltuktan 32 koltuğa iniyor.` | `Cutting seats: Poyraz Lojistik. They are cutting costs; going from 40 seats to 32.` |
| Başka ürüne geçiş | `Yenilemeyecek: Ege Gıda. Entegrasyonlar tarafını daha güçlü buldukları bir ürüne geçiyorlar.` | `Not renewing: Ege Gıda. They are moving to a product with stronger Integrations.` |
| Bütçe kesintisi | `Bütçesini küçültüyor: Kuzey Sigorta. 60 koltuktan 30 koltuğa iniyor.` | `Cutting its budget: Kuzey Sigorta. Going from 60 seats to 30.` |
| Yenileme ipucu | `Yenileme 12 Mar · Büyüyen sektör` | `Renews 12 Mar · Growing sector` |

**Bütçe kesintisi maili (kâğıt yok):** Deniz Aras · Kuzey Lojistik, konu "Sözleşme yenileme": `Bu yıl bütçemizi küçültüyoruz
ve yazılım harcamalarımızı azaltıyoruz. Karar ürününüzle ilgili değil; ekibimiz ürünü kullanmaktan memnun. Sözleşmemizi Mart
sonunda 60 yerine 30 koltukla yeniliyoruz. Aylık ücret $2.100 yerine $1.050 olacak.` / `We are cutting our budget this year
and spending less on software. This is not about your product; our team is happy with it. We will renew at the end of March
with 30 seats instead of 60. The monthly fee goes from $2,100 to $1,050.` Memnun olmayan hesabın son cümlesi: `Bu dönemde
devam edemeyeceğiz. Sözleşme Mart sonunda bitiyor.` / `We cannot continue this year. The contract ends at the end of March.`

**Kurumsal madde mailleri** v2 §2.3'teki, **haftalık destek raporu** C_PLAN §2.8'deki gibidir (Karar 4 ve 12). EN metinleri
W1'de önce yazılır (CLAUDE.md §5).

## 4. Kabul ölçütleri
Ölçüm kötü çıkarsa sabit sessizce değiştirilmez. Ajan durmaz; ölçüm ve öneri raporda "onay bekliyor" altında Erdem'e
gider (A ve B'nin kuralı).

### 4.1 Simülasyon kapıları (koddan önce, C0s; v3 §7.4'ün güncel hâli)
Q'nun raporu geldikten sonra `MEMNUNIYET_SIM` betikleri yıldıza bağlı beklentiyle (Q3) yeniden koşulur.

| Kapı | Hedef | Bugünkü sonuç |
|---|---|---|
| M1 Nedensiz düşüş | adlı olay olmayan haftada 1 puan ya da fazla düşüş: 0 | geçti (0) |
| M2 İlk 12 hafta | imza değerinin altına inmez; imza ≥ eşik + 10 | geçti |
| M3, M4 Düzelten kollar | `fix_due` geç kayıp ≤ `fix_off` + 2; `fix_worst` geç ≤ off + 3, toplam ≤ off + 10 | geçti |
| M5 Hiç düzeltmeyen | geç kayıp ≥ %10 ve ≥ 2 × off | kaldı (%1,4 / %6,9); yeniden. Tavan 60 kalır; tutmazsa 62 ve 64 sonuçları Erdem'e |
| M6 Söz | tutulmayan söz eşiğe 8 puan yakında Risk, 20'de değil; iz 13 haftada kalkar | geçti |
| M7 Kesinti kademesi | her basamakta ≥ %25 az; yük %95 ≥ 1,3 × yük %70 | B'nin sırasıyla 9 / 9 (MEMNUNIYET_SIM §5.2 öneri c); yeniden doğrulanır |
| M8 Güncellenmeyen ürün | 26: 0; 52: −6; tavan −12; 52 haftada kayıp 0 | geçti; Karar 7'nin vurgu alanı tanımıyla yeniden |
| M9 Ürün dışı kayıp | bütçe kesintisi ve başka ürüne geçişle tam kayıp yılda hesapların ≤ %2,5'i [hedef önerisi]; bütçe olaylarının ≥ %50'si küçülme | bütçe kesintisi yeni okumayla geçer (MEMNUNIYET_SIM §5.3 seçenek 1); geçiş yeni |
| M10 İmza kapısı | `fix_worst` imza sayısı bugünün ≥ %80'i | geçti (%86,4); yıldız beklentisiyle yeniden |
| M11, M12 Gider ve fatura | §4.3 Risk 2; Standart sunucu gelirin %8 ile %12'si | M12 geçti; M11 kurucu maaşsız, $4.000 kira ve masa tavanıyla yeniden |
| M13 Yenileme sonuçları | bakımlı üründe yenileyen ≥ %90; koltuk artışı ve azalışı ikisi de görülür [hedef önerisi] | yeni |

### 4.2 Bot ölçümleri (uygulamadan sonra, gerçek koşu)
- Kollar A'nınkiler: `fix_none`, `fix_worst`, `fix_due`, `fix_off`; B2B ve B2C; tohum 7 ve 11; 104 hafta.
- Ek kollar (onay bekliyor): `server_lean` (elle, pay %5), `server_wide` (elle, pay %40), `server_auto` (anahtar açık),
  `cash_spend`, `cash_hoard`. Ofis taşıma politikası artık her kolda vardır: masa tavanıyla bot taşınmadan işe alamaz
  (bugün hiç taşımaz, R15 §1.2).
- Ölçülenler (`PROBE` satırıyla): sunucu tıkı, otomatik büyüme, yük, kademe başına kesinti; ilk işe alım ve taşınma
  haftaları ve o haftanın runway'i; en derin açık, 52. hafta ve evre 3 net; ürün kaynaklı kayıp (kapı ve zar ayrı);
  yenileme sonuçları ve kâğıtlı ay sayısı; istek kesintisi ve ilk 3★ isteği; saat durması; satışçı masasının payı.

### 4.3 Oynanış kapıları
Her kapı bot sayısıdır; insan oturumu değildir (OYNANIS_HUKMU §6 madde 1). "Gerçek karar": iki farklı bot politikasının
farklı sonuç aldığı karar. Sayım (Q, C ve D'de aynı): önce her karar yüzeyi iki politikayla sınanır ve S sınıfı kanıtlanır;
sonra pencerede oyuncunun önüne gelen S yüzeylerinin olayları sayılır (her biri bir `PROBE DECISION` satırı: hafta, yüzey,
hesap ya da kart). Hedef önerileri ölçülmemiştir ve onay bekler.

**Risk 1 · Bakımlı üründe karar kalmıyor**
- Yenileme (Erdem: zam normaldir, zam payına kapı yok): `fix_worst` kolunda yenileme dönemindeki hesapların en az %90'ı
  yeniler; 104 haftalık B2B koşusunda (tohum 7 ve 11) koltuk artışı da mali azalış da en az birer kez görülür; her koltuk
  sonucunun ve ürün dışı ayrılmanın mailde adlı nedeni vardır [hedef önerisi].
- `fix_none` kolunda geç kayıp en az %10 (M5). Ürün kaynaklı kayıp (kapı ve Q'nun zarı birlikte) bakımlı üründe imza
  denemelerinin %5 ile 20'si, bakımsızda en az %25 (Q ile ortak).
- Traction ve Series A'da, B2B ve B2C'de her 10 haftalık pencerede en az 3 gerçek karar; bakımlı üründe yılda en az 15
  [hedef önerisi] (Q, C, D ortak; C'nin payı: imza kapısı, kademe, kapasite, taşınma ve işe alım, yenileme).
- Yalnız Çekirdek'e yüklenen bot kolunda 52. haftada vurgu alanı ihmal edilen hesapların en az yarısında yaş terimi en az
  −3; dengeli kolda %10'dan azında.
- Kapasite: `server_lean`, `server_wide`, `server_auto`'dan en az ikisi farklı sonuç alır (kesinti, net); `server_auto` her
  yerde en iyiyse elle yönetim boş tıktır (T), eşik E2'de Erdem'e. Kademe: üç kademe birer senaryoda en iyi sonucu alır.

**Risk 2 · Servis gideri kalkınca ilk yıl fazla kolay**
- Bootstrap runway (6,7 ay) yeniden tanımlanır: evdeki tek kurucunun gideri MVP'den önce 0, sonra yalnız sunucudur ve bu
  dönemin runway'i sonsuz yazılır. Kapı ilk çalışanın işe başladığı haftadadır: kasa ÷ aylık gider (kira, maaş, sunucu;
  gelir hariç) en az 6,7 ay [hedef önerisi]. B2B `fix_worst` ilk 40 haftada en derin kümülatif açık 25 ile 45 bin, 30.
  haftadan sonra. İkisi de yeni giderlerle yeniden ölçülür; tutmazsa ölçüm ve öneri Erdem'e.
- B2B 52. hafta kümülatif net en çok 80 bin; evre 3 aylık net en çok bugünün 2 katı (M11). Evre 2'de en düşük runway en az
  bir kez 4 ayın altında (tohum 11 bugün de tutmuyor, 9,8 ay; MEMNUNIYET_SIM §4.1).
- `cash_spend` ile `cash_hoard` arasında Series A kapısına varış farkı en az 6 hafta [hedef önerisi]; fark yoksa kasa karar
  doğurmuyordur ve rapor bunu Risk 2'nin asıl bulgusu olarak yazar.
- B2C: en derin açık bugünkünden en çok %50 derin; 101. hafta net bugünün %80'inden az değil [hedef önerisi]. 20 koşuda
  iflas sayısı ve tek cümlelik nedeni raporda.

**Risk 4 ve 5 · Kalabalık ve akış**
- C'nin eklediği her karar yüzeyi S; T ya da B yüzey 0. Bütçe kesintisi ve koltuk sonuçları kâğıtsız; istek kesintisi
  koşuda en çok 25; yenileme kâğıdı ayda en çok 1 (330 hesapta kâğıt gelen ay sayısı raporda).
- B2B Traction'da saat durması haftada en çok 1,2 (bugün 1,72, R15 §4.4; C ve D ortak). İki kesintili hafta en çok %2.
- Sunucu tıkı: anahtar kapalı kolda koşu boyunca tık sayısı raporda (Erdem bunu oyuncunun meşgalesi olarak istiyor);
  anahtar açık kolda 0. B2C'de kartsız en uzun seri en çok 4 hafta (bugün 6 ile 11, R15 §3.2; C ve E ortak).

### 4.4 Davranış kapıları (smoke vakaları, falsification ile)
Yalnız çekirdek mantık için (CLAUDE.md §10); arayüz görsel kabulle doğrulanır.
1. `sat_total_is_sum`, `sat_no_silent_drop`: memnuniyet ipucundaki terimlerin toplamıdır; olaysız 12 haftada değişmez.
2. `sign_gate_reason`, `sign_single_loss`: kapının reddi Q'nun `loss_area`'sını (boşsa en çok açık hatalı alanı) Q'nun
   mailine verir; kapıyı geçen aday yalnız Q'nun zarını atar, zar en az %60.
3. `ledger_fade`, `chip_matches_ledger`: olumsuz satır süresinde söner, olumlu kalıcılar +10'da durur; çip kapanışla aynı.
4. `capacity_step_immediate`, `load_mult_steps`, `no_hidden_overage`, `auto_capacity_grows_only`: ipucunun fatura ve yükü
   gerçekleşir, gece zarı yeni yükü okur; 0,90 ve 1,00 sınırları; aşım gizli ceza yazmaz; anahtar eşikte büyür, küçültmez.
5. `burn_lines_visible`, `desk_cap_blocks_hire`: Finans kalemlerinin toplamı günlük burn'e eşittir; araç, servis ve kurucu
   anahtarı hiçbir yerde yok; boş masa yokken arama açılmaz, taşınma kararıyla açılır.
6. `enterprise_clause_timeline`, `renewal_paper_once_a_month`, `renewal_outcome_named`: madde takvimi ve −10 birikmez; ayda
   bir kâğıt, cevapsız aynı fiyat; hesap başına en çok bir koltuk ya da ürün dışı sonuç, mailde nedeniyle; kâğıtsız.
7. `update_age_emphasis_only`, `support_report_quiet_week`, `requests_three_star_only`: Çekirdek'e dokunan yayın sayacı
   sıfırlamaz; yeni yoksa rapor gelmez; 1★ ve 2★ hesap istek açmaz.

### 4.5 Kayıt
- C şema 19'u alır (Q 18, D 20). C3a başlarken `save_manager.gd:16`'yı okur; farklıysa raporda yazar.
- Göç: `trust_offset` defterde 4 haftalık tek satır olur; `market_ref` Q'nun göçünden; `last_touch_day` göç günü;
  sözleşme bitişi imza gününden; açık Kurumsal madde yoktur; araç ve servis anahtarları `burn_breakdown`'dan düşer;
  otomatik ayar kapalı doğar; masayı aşan kadro çıkarılmaz; 1★ ve 2★ hesapların açık istekleri cezasız düşer.
- Kanıt: göç vakaları (`save_v17_*` ya da `save_v18_*`), eski kayıt yükleme sonrası nedensiz düşüş 0.

### 4.6 Olay ve görsel kapıları
- `--event-lint`, `loc_residue`, `plausibility_run.sh` (`fails=0`), `run_gate.sh` (üç koşu bir sonla biter, sıfır `ERROR`).
- Görsel kabul (CLAUDE.md §11): TR, EN, renk körü, 1,25 ölçek. Fikstürler HARITA'ya: Genel Bakış (B2B, B2C, 3★'sız, v1.0
  öncesi), Sunucu bloğu (yük %80, %94, %104; büyüme satırı; anahtar açık), memnuniyet ipucu, HESAPLAR (330 satır), satışçı
  raporu (koltuk satırlarıyla), kurucu kâğıdı, destek raporu, Finans (boş ve dolu), Atlas (evde, dolu), ofis kartı.

## 5. Araştırma
R6, R7 ve R9 yeterlidir; tek yeni dış araştırma otomatik ölçeklemedir. Koddan önce üç iş:
- **Otomatik ölçekleme (C0r, en çok 45 dakika):** oyunlarda (Startup Company, Software Inc., Mad Games Tycoon 2) ve gerçek
  bulutta (AWS Auto Scaling, Google Cloud örnek grupları, Kubernetes HPA) eşik ve büyüme adımı: varsayılan hedef kullanım,
  adım oran mı sabit mi, küçültme ve bekleme süresi. Çıktı: kaynaklı tek tablo. Öneri eşik %80, adım yükü yaklaşık %65'e
  indirecek kadar, küçültme yok (onay bekliyor); araştırma doğrular ya da gerekçeyle değiştirir, E1'de Erdem'e gider.
- **C0s simülasyonu:** Q'nun raporundan sonra `MEMNUNIYET_SIM` betiklerini yıldız beklentisiyle yeniden koşar; yenileme
  sonuç dağılımını (tutum, koltuk artışı ve azalışı, başka ürüne geçiş, bütçe kesintisi) Karar 8'in oranlarıyla ölçer ve M13
  ile M9'u okur; 13 sektörün eğilimini (büyüyen, olağan, durağan) önerir; hata terimi tavanını (60, 62, 64) M5 ile yeniden
  okur; Karar 7'nin vurgu alanı tanımını M8 ile ölçer.
- **Ekonomi tahmini:** yeni giderlerle (kurucu maaşsız, kira, ×1,5, masa tavanı, Plaza 10 kişi) M11'i, Bootstrap runway'ini
  ve ilk 40 haftanın açığını hesaplar; İş hanı'nın Frank şartını iki hâliyle ölçer (kalır ya da kasada $6.500 yeter);
  Plaza'nın nakit ve marka şartlarının İş hanı dolduktan ne kadar sonra tuttuğunu yazar. Sonuç E1'de Erdem'e.

## 6. Bağlantılar: kopukluk olmayacak
Uygulayıcı kod yazmadan önce bağlantı haritası çıkarır (C0): aşağıdakilerin her okuyucusu ve yazıcısı, satır satır ve yeni
karşılığıyla. Opus haritayı kodla karşılaştırarak doğrular (C0v).

| Konu | Bugün (`889b9b8`) |
|---|---|
| Kapasite, yük, otomatik ayar | `infra_system.gd:50`, `:130-249`; sürüm büyümesi `sprint_bridges.gd:73`; MVP açılışı `:131-133`; büyüme anları imza (`CustomerRegistry.add`) ve B2C kitle tiki |
| Aşım etkileri | `infra_system.gd:66-69`, `:286-314`; okurlar `support_system.gd:165`, `:248`; `sales_system.gd:184` |
| Uyarı kartı | `infra_system.gd:98-116`, `:333-341` (mandal kayda girmiyor) |
| Kesinti zarı | `incident_system.gd:70-78`, `:128`; smoke `endgame_smoke.gd:15778-15779`. Yük sebep cümlesi yalnız yük %90 üstündeyken (v3 §8 madde 1) |
| Gider | `finance_system.gd:13-38`, `:136`, `:219-222`, `:250`; `infra_system.gd:77-93`, `:256-282`, `:347-349`; HR `hr_search_system.gd:248-256`, `hr_actions.gd:247-248`; metin `strings.csv:1447-1448`, `:3036-3037`, `:3047`; Finans `scripts/tabs/finance/` |
| Ofis, masa, maaş | `office_constants.gd:6-62`; `office_system.gd:26`, `:48`; `office_map_card.gd:63`; `office_layout.gd:15`; arama kapısı `hr_search_system.gd:96-145` ve Atlas `hr_atlas_modal.gd`; `character_registry.gd:378-379`; `hr_constants.gd:591-598`; başlangıç nakdi `founder_constants.gd:56`, `:187-188` |
| Memnuniyet | `b2b_sales_system.gd:20-96`, `:144-191`, `:197-217`, `:220-260`, `:422-489`; `b2b_constants.gd:15-31`, `:39-45`, `:57-68`, `:139-142`, `:163-190`, `:260-272`; `customer.gd:30-61`; `customer_registry.gd:219-226`; destek zararı `support_system.gd:132`, `:243-268` |
| İmza | `sales_system.gd:362-378`, `:421-426`; `sales_finalizer.gd:84`; `_close` `sales_rep_system.gd:232-245` (Q'nun satışçı zarıyla aynı nokta); görüşme ve kayıp nedeni `sales_meeting_system.gd:134-141`, `:338`; `sales_ledger.gd:338` |
| Olay motoru | `effects.gd:48`, `:420-436`, `:681-720`; `chips.gd:80`, `:88`; `incident_system.gd:465-493`, `:575-590`; `lint.gd:305-306`; 13 `satisfaction_delta` kartı; `_vocabulary.md`, sinyal manifesti |
| Yenileme, koltuk, istek | `sprint_bridges.gd:21-63` (istek penceresi, 3★ süzgeci); `sprint.json:39`; `customer_rep_system.gd:192-365`; `b2b_constants.gd:250-253`; koltuk `CustomerRegistry.set_seats`; `customer/request_feature.json`, `request_renewal.json`, `request_complaint.json`, `retention.json`, `expansion.json`; teşekkür notu `SprintBridges.thank`; `plausibility.gd:364`; sözler `b2b_sales_system.gd:312-330`, `:437-489` |
| Destek raporu | kalıp `sales_rep_system.gd:271-286` ve `SALES_WEEKLY_*`; temsilci sırası `customer_rep_system.gd:41` |
| Arayüz | `product_tab.gd:16`, `:127-200`, `:228`; `scripts/tabs/product/`; `sales_tab.gd:109-200`, `:511-665`; TopBar MRR ipucu. Build bar Destek satırı A'nındır |
| Araçlar, belgeler | `run_probe.gd:92-102`; `MONTH_BURN` ve `GATE`'in tools ve service alanları; smoke'taki tools ve servis vakaları; `HARITA.md`, `CLAUDE.md` §1 ve §6, `GUNCELLEMELER.md`, Glossary |

## 7. Kapsam dışı
- Ürün uyumu U, sektör tablosu, yıldıza bağlı beklenti ve kalibrasyonu, satışçı zarı ve kayıp maili (Q).
- Ekip modeli, atama, sabit 2 haftalık sprint, çeyrek hedefi, plan ekranının istek listesi, gönder sorusu (D).
- Pazaryeri ekonomisi, B2C fiyat kolu ve B2C alıntı metinleri (E). Kesinti tabanı, tavanı ve kademe çarpanı (B).
- `ACIK_ISLER.md`: para baskısı ve pazarlama (3), saatin kararlardan sonra sürmesi (4), Seed ve Series A (5), kayıp ekranı
  (7), ERP modülleri (11), zorluk kadranı (14). Rakip analizi (Erdem). 1★ ve 2★ hesabın yenileme geri bildirimi (Erdem: iş
  büyür).

## 8. Çalışma biçimi ve adım tablosu
**Kurallar** (A ve B ile aynı)
- Önce adım tablosu ve Erdem'in onayı. Tek klasör, doğrudan `main`, worktree yok; commit mesajı `Faz C Cn: ...`. Push
  yalnız Erdem "push et" deyince, öncesinde tam smoke yok. `git checkout --` yasak; yalnız kendi değişikliğin commit'lenir;
  editörün `project.godot` ve tema farkı, `docs/tasks/faz_cde/` commit edilmez. Erdem oynarken ağır iş yok. Tek göç C3a.
- **Her commit'in akışı:** Sonnet kodlar (xhigh, büyük dilimde max) → Haiku kapıları koşar ve ekranı çeker → Opus kıdemli
  inceleme, en çok bir düzeltme → commit. Ayrı delta ya da ölçüm turu yok. Yazım dalgasını Opus yazar, E1'e toplu gider.

**Başlama koşulu.** C oyun koduna, `strings.csv`'ye ve `data/`'ya Q'nun raporu (`RAPOR_Q.md`) gelip son commit'i `git log`'da
görünene kadar yazmaz; RAPOR_B §1 madde 7'nin üç dosyası (`sprint_system.gd`, `sprint_probe.gd`, `endgame_smoke.gd`)
`git status`'ta kirliyse durur, Erdem'e sorar. Q kod yazarken yürüyenler Godot koşturmaz: C0, C0v, C0r, W1. Q'nun raporundan
sonra, C1'den önce: C0s (yalnız `python -I`) ve C0m (ekranlı, `docs/tasks/faz_cde/c_taslak/`); C0m D'nin M'siyle aynı anda
değil sırayla koşar. D, C'nin raporundan sonra koda başlar. **Q, C ve D'nin ortak dosyaları:** `save_manager.gd` (şema 18, 19, 20), `strings.csv`, `data/product/sprint.json`,
`sprint_bridges.gd`, `b2b_sales_system.gd`, `incident_system.gd`, `effects.gd` ve `chips.gd`, `product_tab.gd`, `run_probe.gd`,
`endgame_smoke.gd`. **Q ile C:** `sales_system.gd`, `sales_finalizer.gd`, `sales_rep_system.gd`, `sales_meeting_system.gd`,
`sales_ledger.gd`, `b2b_constants.gd`, `customer.gd`. **C ile D:** `sprint_system.gd` (kesinti tablosu), `support_system.gd`,
`hr_constants.gd` (maaş bandı C, rol D), `hr_atlas_modal.gd` (masa tavanı C), `customer_rep_system.gd`.

| Adım | Ne | Kim | Model | Düşünme | Süre | Kapı bütçesi | Neden |
|---|---|---|---|---|---|---|---|
| C0 | Bağlantı haritası (§6) | Alt ajan | Sonnet | yüksek | 45 dk | yok | Kod tarama |
| C0v | Haritanın doğrulanması | Alt ajan | Opus | yüksek | 15 dk | yok | Kopukluk kod yazılmadan yakalanır |
| C0r | Otomatik ölçekleme araştırması (§5) | Alt ajan | Sonnet | yüksek | 45 dk | yok | Anahtarın eşiği ve adımı |
| C0s | Simülasyon ve ekonomi tahmini (§5); Q'nun raporundan sonra | Alt ajan | Sonnet | yüksek | 1 sa 45 dk | yalnız `python -I` | Yenileme oranları, kira, runway ve Frank şartı buna dayanır |
| W1 | Yazım dalgası: sunucu ve anahtar satırları, gider ipuçları, Atlas ve ofis kartı, memnuniyet satırları, imza maili, yenileme kâğıtları ve koltuk satırları, bütçe maili, Kurumsal mailleri, destek raporu, İstekler bloğu | Alt ajan | Opus | yüksek | 1 sa 15 dk | yok | Yazım kalitesi |
| C0m | Ekranlar oyunun kendi arayüzüyle (Erdem: "Direkt oyunun UI'yla"): Genel Bakış, Sunucu bloğu, Atlas tavanı, HESAPLAR, memnuniyet ipucu, satışçı raporu. `UiFactory` ve `menajer_theme` ile kurulan, `class_name` taşımayan, `-s` ile koşan betik `c_taslak/` altında; oyun dosyasına yazmaz. Q'nun raporundan sonra, C1'den önce; D'nin M'siyle sırayla, Erdem oynamıyorken | Alt ajan | Sonnet | yüksek | 2 sa | yok | UI koddan önce gösterilir |
| E1 | **Erdem durağı:** C0r ve C0s sonuçları, ekranlar, W1, §10'un E1 maddeleri | Ana | Opus (ana) | orta | Erdem'e bağlı | yok | Eşik, oranlar, Frank şartı. C1 bu sırada ilerleyebilir |
| C1 | Sunucu: kapasite oyuncuda, Yük, boş pay, büyüme ve sürüm satırları, Otomatik ayarla anahtarı (E1'in eşiğiyle), `outage_load_mult`, aşım etkilerinin ve sürüm büyümesinin silinmesi | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 5 sa | §4.4 madde 4; `run_gate` | Kesinti ve satış okurları |
| C2 | Giderler: araç ve servisin silinmesi, sunucu fiyatı, ofis kirası, boş gider listesi, HR önizlemeleri, metinler | aynı | aynı | xhigh / düşük / yüksek | 3 sa 30 dk | §4.4 madde 5; `loc_residue` | Ekonomi ve metin |
| C3a | Memnuniyet defteri: terimler, satırlar, destek zararının kalkması, B'nin çipi ve izleri, şema ve göç | aynı | aynı | **max** / düşük / yüksek | 6 sa | §4.4 madde 1 ve 3; göç vakaları; `--event-lint` | En büyük dilim, kayıt riski |
| C3b | İmza değeri ve kapısı (Q'nun zarının tabanı), güncelleme yaşı, yenilemede beklenti okuma | aynı | aynı | xhigh / düşük / yüksek | 4 sa | §4.4 madde 2 ve 7 | Q'nun sözleşmesine dayanır |
| C4 | Kurumsal madde | aynı | aynı | xhigh / düşük / yüksek | 3 sa | §4.4 madde 6 | Takvim ve mail |
| C5 | Yenileme: satışçı ve kurucu yolu, koltuk sonuçları ve başka ürüne geçiş (E1'in oranlarıyla), sektör eğilimi, kesinti kuralı, bütçe kesintisi; yenileme sinyali kâğıdının silinmesi | aynı | aynı | **max** / düşük / yüksek | 7 sa | §4.4 madde 6; `plausibility` | Akış ve kâğıt motoru |
| C6 | Genel Bakış kâğıdı, Kararlılık satırı, İstekler bloğu, isteklerin 3★'a daralması ve söz kesintisi | aynı | aynı | **max** / düşük / yüksek | 5 sa | §4.4 madde 7; görsel kabul | UI kanunu |
| C7 | Haftalık destek raporu | aynı | aynı | xhigh / düşük / yüksek | 2 sa | §4.4 madde 7 | Küçük |
| C8 | HESAPLAR tablosu | aynı | aynı | **max** / düşük / yüksek | 4 sa 30 dk | görsel kabul (330 satır) | UI ve ölçek |
| C9 | Maaş ×1,5, masa tavanı, Plaza şartı 10, ilk işe alımın taşınma akışı, İş hanı şartı (E1'in cevabıyla), botun taşınma politikası ve bot kolları (§4.2), tek commit | aynı | aynı | **max** / düşük / yüksek | 4 sa | §4.4 madde 5; `run_gate` | Tavan botun taşınmasıyla aynı commit'te girer, yoksa koşu işe alamaz |
| E2 | **Erdem durağı:** §4.2 ve §4.3 ölçümleri (tohum 7 ve 11, B2B ve B2C); tutmayan kapı ve önerisi | Alt ajan → Ana | Haiku koşar, Opus okur | düşük / orta | 2 sa | bot koşuları | Oynanış kapıları gerçek koşuyla |
| R | Sonuç raporu (§9) | Ana | Opus (ana) | orta | 30 dk | yok | Rapor kuralı ve D'nin girdisi |

Toplam yaklaşık 53 saat ajan süresi (E1 ve E2 beklemesi hariç). Sıra: C0, C0v, C0r, W1 (Q kod yazarken) → Q'nun
raporu → C0s ve C0m → E1 → C1 → C2 → C3a → C3b → C4 → C5 → C6 → C7 → C8 → C9 → E2 → R. C1 anahtarsız kısmıyla ve C2 E1'i beklemez.

## 9. Aynı ağaçtaki öbür fazlarla kurallar
**Q (önce gelir)**
- C, Q'nun raporu ve son commit'i gelene kadar koda yazmaz (§8 Başlama koşulu): aynı ağaçta iki fazın aynı anda
  commit'lemesi sahipsiz değişiklik ve sınıf önbelleği riski taşır.
- C'nin Q'dan okudukları: `account_fit(c)` ve `prospect_fit(p)` ile dönen alanlar (`value`, `market_value`, `label_key`,
  `note`, `capped`, `weakest_emphasis`, `loss_area`), `area_row`, sektör cümleleri, `weights`, `emphasis`, `uses_area`, `market_ref`'in
  seam'i. Adlar Q'nun raporundan alınır. C U'yu hesaplamaz, beklenti tutmaz, evreye bakmaz (Q3). "Kararlılık" satırı C'nindir.
- Satışçı zarı ve kayıp maili Q'nundur; C'nin imza kapısı o zarın tabanıdır ve aynı noktaya (`_close`,
  `sales_rep_system.gd:232-245`) bağlanır (Karar 6). Q'nun raporu zarın adını ve kapının bağlanacağı yeri söyler.

**D (sonra gelir)**
- D, C'nin raporu gelmeden koda başlamaz. D'nin okudukları: istek listesi verisi (yalnız 3★, Karar 11), düzeltme kartına
  giden yol (Karar 10 ve 12), defter satırı yazma noktası, kesinti tablosu (Karar 8), şema numarası. Plan ekranının istek
  listesi D'nindir; C veriyi kurar. D sprinti sabit 2 hafta yapar (D4); C'nin hiçbir kuralı sprint süresine bağlı değildir.

**B'nin dosyaları:** B bitti. C, `incident_system.gd`'de yalnız `load_mult()`'un gövdesini ve kesinti satırlarının deftere
yazımını değiştirir. Kademe, tavan ve kart metinleri değişmez.

**R raporu** `docs/tasks/faz_cde/RAPOR_C.md`'ye: (1) ✅ / ⚠️ / ❌ ve kanıt, §4.3'ün oynanış kapıları ayrı tabloda; (2) onay
bekleyen sabitler ve metinler; (3) commit listesi, son satır C'nin son kod commit'i; (4) D için adlı okuma ve yazma
noktaları (`B2BSatisfaction.terms`, `total`, `preview`; `CustomerRegistry.add_ledger_entry`; istek listesi; düzeltme kartı
yolu; şema numarası); (5) bot kollarının preset adları ve komutları; (6) A'nın Karar 9'undan sapma (destek zararı, Erdem
onayladı) ve RAPOR_B soru 2 ile 14'ün durumu.

## 10. Erdem'in cevapları (2026-10-18)
1. **Memnuniyet modeli:** onaylandı. Satır toplamı, kayma yok, imza gerçek değerle, kapı eşik + 10, hata terimi 3 × yoğunluk
   ve tavan 60, yaş yalnız iki vurgu alanı, adsız destek zararı kalkar (Karar 5, 6, 7).
2. **Giderler:** kurucu maaşı yok; kira İş hanı $4.000, Plaza $8.000, Loft $18.000, ev kirasız; maaş ×1,5; masa sayısı işe
   alım tavanı; Plaza şartı 10 kişi; servis gideri kalkar (Karar 3).
3. **Bütçe kesintisi:** onaylandı, kâğıtsız; 1★ %2, 2★ %1,5, 3★ %1 (Karar 9).
4. **Yenileme bantları:** zam normaldir, bantlar kaymaz, zam payı kapısı kalkar; sonuç koltuk artışı, azalışı ve seyrek
   adlı ayrılmayla çeşitlenir (Karar 8).
5. **Sunucu kapasitesi:** Artır ve Azalt oyuncuda; yanına "Otomatik ayarla", eşik ve adım araştırmayla (Karar 1, §5).
6. **İstek kartı:** yalnız 3★ ve üstü istek yapar, her istek söz sorar; 1★ ve 2★ geri bildirim de vermez (Karar 11).

**Kalan sorular:** yok. Kararların doğurduğu üç konu E1 durağına ölçümle gider:
- **İş hanı'nın Frank şartı.** Masa tavanıyla ilk işe alım Frank'in çekini bekler (bot B2C'de 22. haftaya kadar tek başına).
  Öneri: şart kalkar, kasada $6.500 yeter; oyuncu ilk işe alımı kendi birikimiyle erken yapmayı ya da çeki beklemeyi seçer.
  Oynanış etkisi: ilk büyük para kararı Bootstrap'ın içine girer ve gerçek bir ödünleşim olur.
- **Otomatik ayarın eşiği ve adımı** (öneri %80, yük %65'e inecek kadar, küçültmez; C0r doğrular).
- **Koltuk sonuçlarının oranları ve 13 sektörün eğilimi** (C0s önerir, M13 ve M9 ile).
