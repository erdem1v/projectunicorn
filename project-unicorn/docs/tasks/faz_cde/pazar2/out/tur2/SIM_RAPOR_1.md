# SIM1 · Pazar 2 simülasyonunun ilk turu (G1, G5, G8)

Tarih: 2026-10-21. Betik ve veri: `docs/tasks/faz_cde/pazar2/sim/` (README, DEVIR). Sonuç verisi: `out/tur2/sim1_sonuc.json` (resmî ayar) ve
`out/tur2/sim1_sonuc_aday.json` (iki KURAL adayıyla). Oyun kodu okunmadı; kodun sabitleri `constants.json`'da kaynağıyla elle aktarıldı.
Girdi: SENTEZ §3.3, §4, §6, §7, §8, §9, §11, §13; K kod haritası; profil verisi P kolunun `P_profiles.json`'ı (9 profil, 13 sektör,
sektör hücreleri Z/S/N/-, önemli modül adayları, 7 ve 5 modül katlaması; SENTEZ'in 7 profili yerine). Uydurma dünyadır: biçim gösterir, kalibrasyon değildir.

Komut: `python -I sim.py --mod tam --isci 8` · 20 tohum · 3 N × 4 ölçek × 20 tohum = 240 rakip dünyası, 5.040 oyuncu koşusu ·
**3 dk 50 sn** (8 süreç). Aday koşusu 3 dk 20 sn. Aynı tohumla çıktı bayt düzeyinde aynı (2 ve 7 süreçle denendi).

---

## 0. Özet

1. **G1 ❌, ama tek bir yerde.** Ayardan sonra modül standardı (medyan) 2015-2035 boyunca her yıl dönem tavanının en az 1 kademe altında (0 düşen yıl, 6 N×bitiş hücresinin hepsinde). Kapıyı düşüren ikinci şart: dev 2015'te hatlarının %62'sinde (N=10), %81-82'sinde (N=5, 7) tavanda; N=5 ve 7'de 2017'de de (%68-75). 2016'dan sonra dev hiç %60'a çıkmıyor.
2. **Ayarın bedeli büyük.** Kodun bugünkü kademe eforuyla (K1 5,5 puan) standart 2015-2027 boyunca tavana yapışık (14-15 yıl). Kapıyı açan efor **×8**: tek kişilik kurucunun ilk K1'i 4 haftadan ~29 haftaya çıkıyor. Bu ayar demo temposunu bozar.
3. **KURAL adayı (iki parçalı efor):** K1 bugünkü gibi 5,5 puan, K1-K3 dik (×4,5), sonrası yumuşak (×1,2). N=10'da G1 ✅ (2015'te dev %59), tek kurucunun K1'i yine ~4 hafta. N=5 ve 7'de ❌ kalıyor (2015'te %77-82).
4. **G5 ❌.** Haftalık müşteri maili medyanı 0 ✅. Tepe: en kötü tohumun p99'u N=7 ve 10'da 5 (sınırda ✅), N=5'te 6-7 ❌; mutlak en çok 8-12. Açık istek kartı sprint başına p95 8-10 ❌ (sınır 3). Şartlı yenilenen hesap güçlü botlarda yılda %0-0,4 ❌ (bant %5-25). G10 ön okuması ❌ (oranlar kollar arasında %59-288 sapıyor).
5. **İstek kartının nedeni tek:** "bir adım derinlik" isteği oyuncunun o anki seviyesinin bir üstünü istiyor; geç kademeler 6 kişilik kartla 1-4 yıl sürdüğü için istek bitmeden ömrü doluyor ve kartlar birikiyor. **KURAL adayı:** istek yalnız pazarda var olan seviyeyi istesin (en iyi ikinci rakibin seviyesi). Bu tek değişiklikle kart p95 9'dan 3'e iniyor (N=10, 5 tohum).
6. **G8 ✅.** Resmî koşuda 0 ihlal: rakip ekibi her yıl 1 ile tavanı arasında, Σ hesap ≤ havuz, negatif sayı yok, havuz her yıl büyüyor. Aday koşusunda 1 hücre ihlali var: büyüyen hesaplar oyuncunun Gayrimenkul 5★ hücresini 2023'te havuzdan 0,2 hesap aşıyor.
7. **Soru 2 (modül sayısı):** 5 modülde 9 profilden yalnız 5'i ayrı modül ister; 2015'te dev hatlarının %82'sinde tavanda. Odaklı oyuncu devi 2030'da hatların %64'ünde geçiyor. 10 modülde 9 profilin 9'u ayrı, dev %62'de tavanda, odaklı oyuncu %42'sinde öne geçiyor. Yazılacak kademe adı 149'a karşı 209 (2030). Rakam ayrıntısı §6.
8. **Soru 3 (bitiş yılı):** 2035 koşusu 2030'un uzantısıdır, ilk 992 haftası aynıdır. Son 5 yılda standart yılda ~0,2 kademe yürüyor (N=5'te hiç). Dev bakım yükü altında neredeyse duruyor; odaklı oyuncu onu hatların %64-91'inde geçmiş oluyor. Bu dönem için 2 kurgu dönem hattı ve +40-50 kademe adı gerekiyor. 1×'te 6,2 saate karşı 7,8 saat (22,5 sn/hafta); 40-50 sn/hafta kalibrasyonunda 11-14 saate karşı 14-17 saat.
9. **Geç oyun durgunluğu:** rakip ekipleri 2026'da tavanlarına (30/15/12) varıyor, bakım yükü hesap sayısıyla doğrusal büyüyor (devde 2035'te ~11.400 hesap). Sonuç: standart 2030'da K6-K7, tavan K12. Tavan 2020'den sonra kimseyi bağlamıyor; "o dönemin tavanı"na yalnız erken yıllarda varılıyor.

---

## 1. Kapı tablosu

Resmî ayar (§3 sonrası), 20 tohum, ölçek 330. Kapı hücreleri: G1 için rakip dünyası; G5 için takım 25, 50 ve büyüyen × durgun dışı 5 bot (en kötü hücre).

| Kapı | Alt şart | N=5 2030 | N=5 2035 | N=7 2030 | N=7 2035 | N=10 2030 | N=10 2035 |
|---|---|---|---|---|---|---|---|
| **G1** | modül medyanı tavanın ≥1 altında (2015+ her yıl) | ✅ 0 yıl düşer | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 |
| | dev hatlarının ≤%60'ı tavanda | ❌ 2015 %82, 2017 %75 | ❌ aynı | ❌ 2015 %81, 2017 %68 | ❌ aynı | ❌ 2015 %62 | ❌ aynı |
| | **G1 sonucu** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **G5** | haftalık müşteri maili medyanı ≤2 | ✅ 0 | ✅ 1 | ✅ 0 | ✅ 0 | ✅ 0 | ✅ 0 |
| | en çok 5 (en kötü tohumun p99'u) | ❌ 6 | ❌ 7 | ✅ 5 | ✅ 5 | ✅ 5 | ✅ 5 |
| | en çok 5 (harfiyen, mutlak tepe) | ❌ 12 | ❌ 12 | ❌ 8 | ❌ 9 | ❌ 11 | ❌ 11 |
| | sprint başına ayrı istek kartı ≤3 (p95) | ❌ 8 (9) | ❌ 10 (10) | ❌ 8 (9) | ❌ 9 (10) | ❌ 9 (10) | ❌ 9 (10) |
| | yılda şartlı yenilenen %5-25 | ❌ %0-0,4 | ❌ %0 | ❌ %0 | ❌ %0 | ❌ %0-0,2 | ❌ %0 |
| | G10 ön okuma ±%30 (N=10, 2030) | | | | | ❌ %59-288 | |
| | **G5 sonucu** | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| **G8** | ekip 1..tavan · Σ hesap ≤ havuz · negatif yok · havuz büyür | ✅ 0 ihlal | ✅ | ✅ | ✅ | ✅ | ✅ |

Okuma notları:
- G1'in "dev tavanda" payı açık hatların hepsi üstündendir: modül, platform ve açılmış dönem hatları. Tavan, modülde dönem tavanı, platformda bir altı, dönem hattında kendi tavanıdır.
- Mail sayısı istek, şart ve 3★+ hesabın adlı ayrılmasıdır. Mutlak tepe kısmen düzenektendir: portföy rampada haftada 10 hesap imzalıyor, bunların yenileme kontrolü aynı haftaya düşüyor (§8).
- Kart sayısı sprint başında istek ya da şart bekleyen ayrı modül sayısıdır; istekler modül kartında birleşmiş sayılır.
- G10 ölçekler arasında (büyüyen takım) istekte %62, şartta %59; takım kolları arasında (ölçek 330) %177 ve %288 sapıyor. Ayrıntı §5.4.

---

## 2. Model (kısaca; ayrıntı `sim/DEVIR.md`)

- **Hatlar:** N modül + 4 platform hattı (Entegrasyonlar, Güvenlik ve Yetki, Dayanıklılık, Mobil ve Erişim). Dönem hatlarında herkes 0'dan başlar: mobil 2014, e-Belge 2015, KVKK 2016, API 2019, YZ 2023 ve 2035 bitişinde iki **kurgu** hat (Otonom Süreç Ajanları 2031, Kuantum Güvenli Şifreleme 2033).
- **Tavan:** modülde K3 2012 … K14 2034, iki yılda bir. Platformda bir altıdır. Dönem hattı açılışta K3'tür, sonra iki yılda bir +1 artar ve modül tavanını aşmaz.
- **Kademe eforu:** taban × çarpan × g^(k-1). Kodun bugünkü değeri taban 5,5 ve g 1,4'tür (EFFORT_BANDS K1 5-6, K2 7-8, K3 9-11 ile tutar). Kişi haftada 2 puan üretir, %25'i ek yüke gider. Bir kartta en çok 6 kişi çalışır (D yer tutucusu); bu, bir hatta haftada en çok 9 puan demektir.
- **Hata yükü (oyuncu ve rakip aynı kural):** haftada 0,7 × (1 + hesap/80) hata, hata başına 0,4 puan. Yeni kod puan başına 0,09 hata getirir.
- **Rakipler:** 1 dev (18 geliştirici, tavan 30), 2 yerleşik (6, tavan 15), 5 girişim (1,5, tavan 12). Hepsi oyun ölçeğinde, ±%15 tohum payıyla. Kart sırası SENTEZ §8.1: önce mevzuat; sonra odakta standarda yetiş; girişim dönem hattına hemen girer; sonra odakta lider ol (L+1); dönem hattı (yerleşik açılıştan 26 hafta sonra, dev ilk K1'den 52 hafta sonra); genişlik; en son tavana doldur.
- **Standart:** S = yayımlayan rakiplerin üst medyanı, L = en iyi ikinci. Oyuncu bu hesaba girmez. Havuz 2012'de 12.000 hesaptır, yılda %6 büyür; %80'i 9 şirketindir. Pay yılda %12 el değiştirir, çekime (seviye − standart + genişlik) göre. Girişim satın alınıp yerine yenisi girebilir.
- **Hesap:** yıldız 1-5, koltuk (Erdem 6-A bantları), çalışan, gidiş. Profil, sektör, önemli modül ve modüller P'den gelir. İmzadaki göreli yer `o` sabittir: 1★ S−2, 2★ S−1, 3★ S, 4★ min(S+1, L), 5★ L.
  - Yenilemeden 8 hafta önce: 3★+ hesap bir adımlık açıkta memnunsa istek, orta memnuniyetteyse şart söyler; iki adım ya da düşük memnuniyet ayrılma demektir. 1★-2★ çoğu zaman sessiz gider.
  - Yıllık istek yalnız 3★+'tan gelir: %25 / %40 / %60. Şartın süresi 26 haftadır; istek 26 haftada düşer.
- **Oyuncu botları:** durgun, dağınık, odaklı, öncü, satışçı, verimli. Takım kolları 1, 3, 6, 12, 25, 50 ve büyüyen (1 → 3 → 6 → 12 2016 → 25 2019 → 50 2023). Ölçekler 10, 100, 330, 600.
- **Portföy düzeneği:** portföy 3 yılda ölçeğe çıkar ve orada tutulur; giden hesabın yerine uygun aday imzalanır. Aday ancak her hattaki açığı en çok 1 kademe ve önemli modülde 0 ise imzalanır. **Satış zarı SIM2'nin işidir.** Ses ölçüsü 2015'ten başlar.

---

## 3. Ayar günlüğü

### 3.1 G1 (doygunluk)

| Tur | Sabit | Önce → sonra | Neden | Sonuç (20 tohum, P verisi, ölçek 330; "dev" = dev hatlarının >%60'ı tavanda olan yıl) |
|---|---|---|---|---|
| 0 | (kod değerleri) | efor_carpani 1, efor_g 1,4, havuz 5.000 | taban | ❌ medyan tavanda: N=5 15 yıl (2015-2029), N=7 ve 10 14 yıl (2015-2027, 2029); dev 15-16 yıl; tavan yılı 2012 ve 2015 |
| 1 | `efor_carpani` (ve `efor_g`) | 1 → **8**; g 1,4 kaldı | rakip kapasitesi ilk kademelere göre çok büyük | ❌ medyan 0 yıl; dev N=5 5 yıl (2015-17, 2019, 2021), N=7 4 yıl, N=10 3 yıl (2015, 2017, 2019) |
| 2 | `havuz_2012` | 5.000 → **12.000** | devin bakım yükü hesap sayısıyla büyür (aynı kural); dev erken yıllarda tavanı tutamasın | ❌ medyan 0 yıl; dev N=5 ve 7 2 yıl (2015, 2017), N=10 1 yıl (2015, %62) |

- Tur 1'in taraması: efor_carpani 2, 4, 6, 8 × g 1,3, 1,4, 1,45 (6 tohum, SENTEZ'in 7 profiliyle; P verisi gelmeden).
  - ×2'de medyan 10-12 yıl tavanda, ×4'te 4-6 yıl, ×6 ve g 1,4'te 0-2 yıl, ×8'de 0 yıl.
  - g 1,45 biraz iyi, 1,3 kötü. Seçilen ×8 / g 1,4, ardından 20 tohumla P verisinde yeniden ölçüldü (tablodaki satırlar).
- Tur 2'nin taraması: havuz 8.000 ve 12.000 × (×6 / 1,4), (×6 / 1,45), (×8 / 1,4); ayrıca (×6-12 / g 1,25-1,3). Hiçbirinde N=5 ve 7'nin 2015 düşüşü gitmedi.
- Resmî ayar bu iki turun sonucudur: `efor_carpani` 8, `havuz_2012` 12.000 (`constants.json`'da not düşüldü).

### 3.2 G5 (ses yükü)

Değerler N=10 kapı hücrelerinden (5 tohum, P verisi, resmî G1 ayarı).

| Tur | Sabit | Önce → sonra | Neden | Kart p95 (en kötü) | Şartlı yenilenen |
|---|---|---|---|---|---|
| 0 | `istek_omur_hafta` | 52 | SENTEZ "fırsat kaçar" | 11 (12) | %0-0,3 |
| 1 | `istek_omur_hafta` | 52 → **26** | bekleyen istek kart listesini şişiriyor | 9 (10) | %0-0,6 |
| 2 | `istek_omur_hafta`, `istek_yeni_modul_payi` | 26 → 13, 0,5 → 0,8 | daha kısa ömür, daha çok "zaten var" genişlemesi | 7-8 (8) | %0-0,7 |
| 2b | `yenileme_kontrol_hafta`, `memnun_esik` | 8 → 4, 70 → 80 | şartın düzeltilecek zamanı kısalsın, daha az hesap "memnun" sayılsın | 9 (10) | %0-0,8 |

- Tur 2 ve 2b geçmediği için geri alındı. Resmî ayarda yalnız `istek_omur_hafta` 26 kaldı.
- Mail medyanı bütün turlarda 0; p99 4-5.

---

## 4. KURAL düşüncesi (ayar iki turda geçmedi)

### 4.1 G1: neden düşüyor

- Dev 2012'de tavanda başlıyor (SENTEZ §8.1). 2014'ün K4'ü bütün eğrinin en ucuz dönem adımı. Ekip büyüdükçe dev 2015 sonunda hatlarının çoğunda yine tavanda oluyor.
- 2016'dan sonra her açılışta kademe pahalılaştığı için geride kalıyor: 2016 %12, 2019 %6, 2020'den sonra %0 (N=10).
- Az modülde dev, daha dar bir genişliği daha çabuk kapatıyor. Bu, SENTEZ §11.4'teki biçim denetimi bulgusunun aynısı: tavanı derinlik değil genişlik uzaklaştırıyor.

| Aday | Ne değişir | N=5 | N=7 | N=10 | Yan etki |
|---|---|---|---|---|---|
| Dev 2012'de tavanın bir altında | `rivals.turler.dev.*_tavanda_olasilik` 0 | ❌ 2015, 2017 | ❌ 2015, 2017 | ❌ 2015 | Etkisiz: dev K3 ve K4'ü 2015'e kadar zaten bitiriyor |
| Kuvvet eforu (taban×1,5×k^2,5) | eğri biçimi | ✅ | ✅ | ✅ | Standart donuyor: 0,10-0,14 kademe/yıl, 2030'da tavana 8 kademe; K2 47 puan |
| **İki parçalı efor** (K1 5,5; K1-K3 ×4,5; sonra ×1,2) | eğri biçimi | ❌ 2015 %82, 2017 %75 | ❌ 2015 %77, 2017 %64 | **✅ 2015 %59** | Standart 0,24-0,31/yıl (resmîyle aynı), tek kurucunun K1'i ~4 hafta (bugünkü gibi) |
| Rakip tavanları ×1,5 (10 tohum, SENTEZ'in 7 profiliyle) | `rivals.rakipler.*.tavan` | ❌ 2015, 2017 | ❌ 2015, 2017 | ✅ | Geç oyunda standart biraz hızlanıyor (0,41-0,44/yıl, 2030); oyun ölçeğinin dışına çıkıyor |

Kademe eforu (puan), tek kurucunun ilk K1'i ve 6 kişilik bir kartın kademe süresi:

| Eğri | K1 | K3 | K5 | K8 | K10 | K12 | K14 | Tek kurucu K1 | 6 kişi K5 / K10 / K14 |
|---|---|---|---|---|---|---|---|---|---|
| Kod bugün (×1, g 1,4) | 6 | 11 | 21 | 58 | 114 | 223 | 437 | 3,7 hf | 2,3 / 12,6 / 48,5 hf |
| **SIM1 resmî (×8, g 1,4)** | 44 | 86 | 169 | 464 | 909 | 1.782 | 3.492 | **29 hf** | 19 / 101 / 388 hf |
| İki parçalı aday | 6 | 111 | 160 | 277 | 399 | 575 | 828 | 3,7 hf | 18 / 44 / 92 hf |
| Kuvvet adayı | 8 | 129 | 461 | 1.493 | 2.609 | 4.115 | 6.050 | 5,5 hf | 51 / 290 / 672 hf |

**Benim çıkarımım (aday, karar değil):**
- "Yumuşak g≈1,3-1,45" görev modeli, oyun ölçeğindeki rakiplerle iki işi birden yapamıyor: hem tek kurucunun erken temposunu korumak, hem 2015'ten itibaren doygunluğu önlemek.
- İki parçalı eğri ikisini de yapıyor: giriş kademeleri ucuz ama dik, sonrası yumuşak. N=10'da G1'i geçiyor.
- 5 ve 7 modülde hiçbir eğri G1'in dev şartını 2015-2017'de tutturmuyor. Bu, eğriden değil genişlikten geliyor (Soru 2).

### 4.2 G5: neden düşüyor

- **Kart:** "bir adım derinlik" isteği oyuncunun seviyesinin bir üstünü istiyor.
  - Güçlü oyuncu pazarın önündeyken bu, kimsenin yapmadığı ve 6 kişilik kartla bir yıldan uzun süren bir kademe demek. İstek bitmeden ömrü doluyor.
  - Sprint başında bekleyen istek sayısı: 50 kişilik kolda 6-7, büyüyende 0,4-1,9. Şartlı kart yalnız 0,1-0,3.
  - **Aday:** derinlik isteği yalnız pazarda var olan seviyeyi istesin (L ya da hesabın kendi standardı): `istek_derinlik_hedefi = "piyasa"`. Erdem K6'nın "rakiplerde olan şu alanınız zayıf" cümlesiyle de örtüşüyor.
  - Sonuç: tek başına N=10 kart p95 9'dan **3'e** (en kötü 4) iniyor. İki parçalı eğriyle birlikte N=5 ve 7'de 2-3 ✅, N=10'da 4 ❌. Hızlı oyuncu daha çok 3★+ imzalıyor (%18-35).
  - İkinci aday olan isteği hesabın önemli modülüne yoğunlaştırma (`istek_onemli_modul_payi` 1) yetmedi: 8 (9).
- **Şartlı yenileme:**
  - Şart ancak standart oyuncuyu geçince doğuyor. 12 kişi ve üstü her bot (durgun hariç) her hatta standardın önünde kalıyor, şartı da 8 hafta içinde kapatıyor: yılda %0-1,5.
  - Bandın içine yalnız durgun kol (%4-16) ve 1-3 kişilik ekipler (%0,3-14) düşüyor.
  - Kural seviyesinde düşünülecekler, denenmedi: profilin istediği ama oyuncunun hiç sunmadığı modülün de şart konusu olması; ya da bandın yalnız üst sınır olarak okunması (güçlü oyuncunun ödülü şartsızlıktır).
- **G10:**
  - Hesap başına istek, portföyün 3★+ payıyla değişiyor; o da takımın gücüyle (%0-16). Şart ise takımın gücüyle ters orantılı: 1 kişide 0,16, 50 kişide 0,01 hesap-yılı başına.
  - Kural "oranla ölçeklenmiyor"; oran ekibin kapasite/genişlik oranına bağlı.
  - İki aday birlikteyken yalnız ölçekler arası şart oranı ±%30'a giriyor (%24).

---

## 5. N × bitiş tabloları (resmî ayar, 20 tohum)

### 5.1 G1 özeti

| N | bitiş | kapı | medyan tavana <1 yıl | dev >%60 tavanda yıl | medyanın tavana eşitlendiği ilk yıl | tavanda yıl | S artış/yıl (ort.) | son yıl tavana kalan | son yıl dev tavanda pay |
|---|---|---|---|---|---|---|---|---|---|
| 5 | 2030 | ❌ | 0 | 2: 2015, 2017 | hiç | 0 | 0,31 | 5 | 0,00 |
| 5 | 2035 | ❌ | 0 | 2: 2015, 2017 | hiç | 0 | 0,24 | 7 | 0,00 |
| 7 | 2030 | ❌ | 0 | 2: 2015, 2017 | hiç | 0 | 0,31 | 6 | 0,00 |
| 7 | 2035 | ❌ | 0 | 2: 2015, 2017 | hiç | 0 | 0,29 | 7 | 0,00 |
| 10 | 2030 | ❌ | 0 | 1: 2015 | hiç | 0 | 0,25 | 6 | 0,00 |
| 10 | 2035 | ❌ | 0 | 1: 2015 | hiç | 0 | 0,24 | 7 | 0,00 |

"Tavan yılı" (medyanın tavana ilk eşitlendiği yıl) resmî ayarda yok: medyan 2012'de bile tavanın 1-2 altında, çünkü girişimler K1'de ve yerleşikler K2'de başlıyor. Tur 0'da (kod eforu) bu yıl 2012'dir (2015 sonrası ilk: 2015).

### 5.2 Yıl sonu eğrisi (tohum medyanı; "tavana kalan" medyan / en kötü tohum)

**N=10**

| yıl | tavan | modül S | L | tavana kalan | platform tavana kalan | dev tavanda hat | dev tavanda modül | rakip geliştirici (dev) | dev hesap |
|---|---|---|---|---|---|---|---|---|---|
| 2012 | K3 | 2,0 | 2,0 | 1,0 / 1,0 | 0,5 | 14/14 | 10/10 | 37 (17) | 4.032 |
| 2013 | K3 | 2,0 | 2,0 | 1,0 / 1,0 | 0,0 | 14/14 | 10/10 | 41 (18) | 4.233 |
| 2014 | K4 | 2,0 | 2,5 | 2,0 / 2,0 | 1,0 | 5/15 | 1/10 | 45 (19) | 4.420 |
| 2015 | K4 | 2,0 | 3,0 | 2,0 / 1,0 | 1,0 | 10/16 | 6/10 | 51 (20) | 4.603 |
| 2016 | K5 | 2,2 | 3,0 | 2,8 / 2,0 | 1,5 | 2/17 | 0/10 | 59 (21) | 4.914 |
| 2017 | K5 | 3,0 | 3,0 | 2,0 / 2,0 | 1,0 | 6/17 | 1/10 | 68 (23) | 5.238 |
| 2018 | K6 | 3,0 | 3,8 | 3,0 / 2,5 | 2,0 | 1/17 | 0/10 | 79 (24) | 5.550 |
| 2020 | K7 | 4,0 | 4,0 | 3,0 / 3,0 | 2,0 | 0/18 | 0/10 | 106 (27) | 6.117 |
| 2022 | K8 | 5,0 | 5,0 | 3,0 / 3,0 | 3,0 | 0/18 | 0/10 | 115 (29) | 6.570 |
| 2024 | K9 | 5,0 | 5,0 | 4,0 / 4,0 | 3,0 | 0/19 | 0/10 | 118 (30) | 6.936 |
| 2026 | K10 | 6,0 | 6,0 | 4,0 / 4,0 | 4,0 | 0/19 | 0/10 | 120 (30) | 7.527 |
| 2028 | K11 | 6,0 | 6,0 | 5,0 / 5,0 | 4,2 | 0/19 | 0/10 | 120 (30) | 8.208 |
| 2030 | K12 | 6,0 | 6,0 | 6,0 / 6,0 | 5,0 | 0/19 | 0/10 | 120 (30) | 8.956 |
| 2032 | K13 | 6,0 | 6,5 | 7,0 / 6,0 | 6,0 | 0/20 | 0/10 | 120 (30) | 9.892 |
| 2035 | K14 | 7,0 | 7,0 | 7,0 / 7,0 | 7,0 | 0/21 | 0/10 | 120 (30) | 11.384 |

**N=7**

| yıl | tavan | modül S | L | tavana kalan | dev tavanda hat | dev tavanda modül | dev hesap |
|---|---|---|---|---|---|---|---|
| 2012 | K3 | 1,0 | 2,0 | 2,0 / 2 | 11/11 | 7/7 | 4.032 |
| 2014 | K4 | 1,0 | 3,0 | 3,0 / 2 | 6/12 | 2/7 | 4.442 |
| 2015 | K4 | 2,0 | 3,0 | 2,0 / 2 | 10/13 | 6/7 | 4.691 |
| 2016 | K5 | 2,0 | 3,0 | 3,0 / 3 | 6/14 | 0/7 | 5.082 |
| 2017 | K5 | 2,0 | 3,0 | 3,0 / 2 | 10/14 | 2/7 | 5.493 |
| 2018 | K6 | 3,0 | 4,0 | 3,0 / 3 | 3/14 | 0/7 | 5.990 |
| 2020 | K7 | 4,0 | 4,0 | 3,0 / 3 | 4/15 | 0/7 | 6.857 |
| 2022 | K8 | 5,0 | 5,0 | 3,0 / 3 | 1/15 | 0/7 | 7.415 |
| 2026 | K10 | 6,0 | 6,0 | 4,0 / 4 | 0/16 | 0/7 | 8.298 |
| 2030 | K12 | 6,0 | 7,0 | 6,0 / 5 | 0/17 | 0/7 | 9.547 |
| 2035 | K14 | 7,0 | 7,0 | 7,0 / 7 | 0/18 | 0/7 | 12.130 |

**N=5**

| yıl | tavan | modül S | L | tavana kalan | dev tavanda hat | dev tavanda modül | dev hesap |
|---|---|---|---|---|---|---|---|
| 2012 | K3 | 1,0 | 2,0 | 2,0 / 2 | 9/9 | 5/5 | 4.032 |
| 2014 | K4 | 2,0 | 3,0 | 2,0 / 2 | 6/10 | 2/5 | 4.384 |
| 2015 | K4 | 2,0 | 3,0 | 2,0 / 2 | 9/11 | 5/5 | 4.584 |
| 2016 | K5 | 2,0 | 3,0 | 3,0 / 2 | 6/12 | 0/5 | 4.946 |
| 2017 | K5 | 2,5 | 3,0 | 2,5 / 2 | 9/12 | 3/5 | 5.309 |
| 2018 | K6 | 3,0 | 4,0 | 3,0 / 2 | 4/13 | 0/5 | 5.661 |
| 2020 | K7 | 4,0 | 5,0 | 3,0 / 2 | 4/13 | 0/5 | 6.324 |
| 2022 | K8 | 5,0 | 6,0 | 3,0 / 3 | 2/14 | 0/5 | 6.696 |
| 2026 | K10 | 6,0 | 6,0 | 4,0 / 4 | 0/14 | 0/5 | 7.933 |
| 2030 | K12 | 7,0 | 7,0 | 5,0 / 5 | 0/15 | 0/5 | 9.313 |
| 2035 | K14 | 7,0 | 8,0 | 7,0 / 7 | 0/16 | 0/5 | 11.833 |

Rakip geliştirici toplamı her N'de aynı yolu izliyor: 37 (2012) → 106 (2020) → 120 (2026, hepsi tavanda). Hiçbir girişim satın alınmadı (hesabı 10'un altına inen girişim olmadı); 8 rakip baştan sona aktif.

### 5.3 G5 kapı hücreleri

| N | bitiş | mail medyan | mail p99 (en kötü tohum) | mail mutlak tepe | açık kart medyan | kart p95 (en kötü) | şartlı yenilenen (hücre aralığı) |
|---|---|---|---|---|---|---|---|
| 5 | 2030 | 0 | 6 | 12 | 5 | 8 (9) | %0-0,4 |
| 5 | 2035 | 1 | 7 | 12 | 5 | 10 (10) | %0 |
| 7 | 2030 | 0 | 5 | 8 | 4 | 8 (9) | %0 |
| 7 | 2035 | 0 | 5 | 9 | 5 | 9 (10) | %0 |
| 10 | 2030 | 0 | 5 | 11 | 5 | 9 (10) | %0-0,2 |
| 10 | 2035 | 0 | 5 | 11 | 5 | 9 (10) | %0 |

N=10, ölçek 330, 2030; seçilmiş kollar (tohum medyanı; "özete kalan" = haftalık mail bütçesi 2'yi aşan mail):

| bot | takım | mail/hafta ort. | özete kalan/hafta | kart p95 | bekleyen istek (ort.) | şartlı yenilenen | istek / şart / adlı gidiş / sessiz gidiş (hesap-yılı başına) | ortalama hesap | 3★+ payı |
|---|---|---|---|---|---|---|---|---|---|
| dağınık | büyüyen | 0,25 | 0,01 | 4 | 1,9 | %0 | 0,022 / 0,017 / 0,000 / 0,013 | 330 | %16 |
| dağınık | 50 | 0,55 | 0,04 | 9 | 7,4 | %0 | 0,073 / 0,013 / 0,002 / 0,001 | 330 | %16 |
| odaklı | büyüyen | 0,13 | 0,01 | 2 | 0,4 | %0 | 0,007 / 0,009 / 0,007 / 0,092 | 296 | %7 |
| odaklı | 50 | 0,52 | 0,04 | 8 | 6,1 | %0 | 0,062 / 0,013 / 0,003 / 0,000 | 330 | %4 |
| verimli | büyüyen | 0,18 | 0,01 | 3 | 1,0 | %0 | 0,014 / 0,007 / 0,005 / 0,015 | 330 | %10 |
| satışçı | 25 | 0,52 | 0,05 | 7 | 4,3 | %0,1 | 0,048 / 0,017 / 0,017 / 0,002 | 330 | %11 |
| dağınık | 1 | 0,18 | 0,01 | 5 | 0,0 | %14,0 | 0,002 / 0,161 / 0,137 / 0,487 | 59 | %0 |
| durgun | büyüyen | 0,37 | 0,04 | 6 | 0,1 | %15,6 | 0,001 / 0,173 / 0,176 / 0,449 | 115 | %0 |

Bütün kolların tablosu (42 satır × 2 bitiş) sim çıktısında ve JSON'da.

### 5.4 G10 ön okuma (N=10, 2030, durgun dışı 5 botun medyanı)

| kol | ölçü | değerler | ortalama | en büyük sapma |
|---|---|---|---|---|
| ölçek 10 / 100 / 330 / 600 (büyüyen takım) | istek | 0,006 / 0,019 / 0,020 / 0,020 | 0,016 | %62 ❌ |
| aynı | şart | 0,019 / 0,007 / 0,009 / 0,013 | 0,012 | %59 ❌ |
| takım 1 / 3 / 6 / 12 / 25 / 50 / büyüyen (ölçek 330) | istek | 0,001 / 0,004 / 0,014 / 0,026 / 0,042 / 0,071 / 0,020 | 0,025 | %177 ❌ |
| aynı | şart | 0,160 / 0,059 / 0,021 / 0,019 / 0,008 / 0,013 / 0,009 | 0,041 | %288 ❌ |
| köşegen 1-10, 3-10, 6-100, 12-100, 25-330, 50-600 | istek | 0,000 / 0,000 / 0,014 / 0,040 / 0,042 / 0,060 | 0,026 | %130 ❌ |
| aynı | şart | 0,169 / 0,050 / 0,023 / 0,024 / 0,008 / 0,009 | 0,047 | %258 ❌ |

---

## 6. Soru 2 ve Soru 3 için sim ne gösterdi

### 6.1 Soru 2: 5, 7 ya da 10 modül oyunda neyi değiştiriyor

Oyuncu kolları: büyüyen takım, ölçek 330, 20 tohum.

| Ölçü | 5 modül | 7 modül | 10 modül | Oyunda ne demek |
|---|---|---|---|---|
| Hat (modül + 4 platform + açık dönem) 2030 / 2035 | 14 / 16 | 16 / 18 | 19 / 21 | Sprint ekranında yarışılan hat sayısı |
| Yazılacak kademe adı (TR+EN çifti) 2030 / 2035 | 149 / 189 | 173 / 217 | 209 / 259 | İçerik bedeli; 10 modülde 5'e göre +60 / +70 |
| 9 profilden ayrı modül isteyen ("her zaman" kümesi farklı) | 5 | 7 | 9 | 5'te İmalat, Dağıtım, Perakende, Sağlık aynı 5 modülü ister: sektör seçimi kararı kaybolur (P §7) |
| Profil başına istenen modül (Z+S) | 4,7 | 5,4 | 6,3 | Büyük hesabın "çok modül ister"i 5'te tavana çarpar |
| Kod eforunda doygun yıl (tur 0, 2015-2030) | 15 | 14 | 14 | Ayarsız her sayı doygun |
| 2015'te dev hatlarının tavanda payı (resmî / iki parçalı aday) | %82 / %82 | %81 / %77 | %62 / %59 | Az modülde dev erken yıllarda sınırda; yalnız 10'da G1 aday kuralla geçer |
| 2017'de aynı pay | %75 | %68 | %35 | |
| Standart artışı/yıl 2015-2030 | 0,31 | 0,31 | 0,25 | Fark küçük |
| Odaklı botun devi geçtiği hat 2022 / 2030 / 2035 | 0 / 9 / 14,5 | 0 / 9 / 15,5 | 0 / 8 / 13,5 | 2030'da hatların %64 / %56 / %42'si |
| Verimli botun devi geçtiği hat 2030 | 14 (14'ün hepsi) | 15 (16'nın) | 15 (19'un) | 5 modülde verimli oyuncu 2030'da devi her yerde geçmiş |
| Dağınık bot şart / hesap-yılı (2030) | 0,005 | 0,007 | 0,017 | Çok modülde oyuncu her yere yetişemiyor, şart doğuyor |
| G5 kart p95, en kötü hücre (resmî / piyasa adayıyla) | 8 / 2 | 8 / 3 | 9 / 4 | İstek kartı sayısı modül sayısından çok istek kuralına bağlı |
| G5 mail p99, en kötü tohum | 6 ❌ | 5 | 5 | 5 modülde ses aynı modüllere yığılıyor |

**Okunuş (yorumum):**
- 5 modülde dev erken yıllarda tavanı tutuyor; oyuncu da 2030'a doğru onu çoğu hatta geçmiş oluyor. Sektör seçimi anlamını yitiriyor.
- 10 modül G1'in "tavanı genişlik uzaklaştırır" şartını tek başına sağlayan sayı: aday eğriyle ✅. Dev geç oyunda ancak yarı yarıya geçilebiliyor (Erdem 9'un "geç oyunda geçilebilir" hedefiyle uyumlu).
- 10 modülün bedeli içerik (+60-70 kademe adı) ve daha çok şart. 7 modül arada kalıyor: sektör ayrımı 7/9, G1 5'le aynı yerde düşüyor.

### 6.2 Soru 3: 2030 mu 2035 mi

Aynı koşu: 2035'in ilk 992 haftası 2030'la aynı. Fark son 5 yılda.

| Ölçü | 2030 bitiş | 2035 bitiş | Oyunda ne demek |
|---|---|---|---|
| Hafta | 992 | 1.253 (+261, +%26) | |
| Süre 1×'te 22,5 sn/hafta | 6,2 sa | 7,8 sa | Erdem'in 40-50 sn kalibrasyonunda 11,0-13,8 sa / 13,9-17,4 sa |
| Son tavan | K12 | K14 | |
| Standart (N=10) son yıl | K6 | K7 | Son 5 yılda +1 kademe (0,2/yıl); N=5'te 0 |
| Tavana kalan son yıl (N=5 / 7 / 10) | 5 / 6 / 6 | 7 / 7 / 7 | Tavan 2020'den sonra kimseyi bağlamıyor; 2035'te iyice anlamsız |
| Dev tavanda pay (her N) | 0 | 0 | |
| Devin hesabı (N=10) | 8.956 | 11.384 | Bakım yükü: 2030'da haftada ~32 puan, 2035'te ~40 puan; brüt 45 puanlık ekipten 2035'te ~5 puan yeni işe kalıyor (hesap) |
| Odaklı bot devi geçen hat (N=5 / 7 / 10) | 9 / 9 / 8 | 14,5 / 15,5 / 13,5 | 2035'te hatların %91 / %86 / %64'ü |
| Verimli bot devi geçen hat (N=10) | 15 | 18 (21'in) | |
| Rakip ekipleri | 2026'dan beri tavanda (120) | aynı | Son 9 yıl rakip büyümesi yok |
| Dönem hattı | 5 gerçek | + 2 kurgu (2031, 2033) | Kurgu hatlarda ilk K1'i girişimler alıyor (tohum 0: Ardenna 2031, Thymeworks 2033) |
| Yazılacak kademe adı (N=10) | 209 | 259 (+50) | |

**Okunuş (yorumum):**
- 2031-2035'te bugünkü kurallarla standart neredeyse duruyor; dev de bakım yükünden ötürü duruyor. İyi oyuncu devi çoğu hatta geçmiş oluyor.
- Bu "kasa artıyor, karar kalmadı" riskine yakın (CLAUDE.md §1).
- 2035'in işe yaraması için rakiplerin geç oyunda büyümeye devam etmesi gerekiyor: ekip tavanı gelirle büyür, ya da kasa modeli (SENTEZ §8.1). Ya da 2031-35 dönem hatları daha çok iş açmalı. Sim bunu kurmadı.
- 2030'da odaklı oyuncu devi hatların %42-64'ünde geçmiş oluyor: "uzun bir son hedef" hâlâ açık.

---

## 7. Öbür kapılar için ön okuma (gate değil, SIM2'ye not)

| Konu | Ne çıktı |
|---|---|
| **G2** dev geç geçilir | Odaklı bot 2022'de 0 hatta, 2030'da 8-9 hatta devi geçiyor; verimli 2022'de 0-1, 2030'da 14-15. Erken geçmek imkânsıza yakın, geç oyunda mümkün (Erdem 9 yönünde) |
| **G3** öncülük | Öncü bot dönem hatlarının 1-2'sinde ilk K1 (6-7 açık hattan), hedef ≥%50. Girişimler hat açıldığı hafta başlıyor; mevzuat hatlarında dev ilk (tohum 0: e-Belge duyurudan 4, KVKK 6 hafta sonra). Öncü politikası yeniden kurulmalı |
| **G4** durgunluk | Durgun kolda hesap-yılı başına adlı gidiş 0,10-0,18, sessiz gidiş 0,30-0,48; şartlı yenilenen %4-16. Portföy ölçekte tutulduğu için MRR kaybı ölçülmedi |
| **G6** koltuk | Yenilemelerin %11-19'unda koltuk değişiyor (hedef %20-50, düşük). Yıldız değişimi %2-3 ✅ (≤%10). 1★ büyüme %2-3 ✅ (≤%10). 50 kişilik kollarda 1.000 koltuğu aşmak isteyen 28-46 yenileme var: 1.000'de kesildi |
| **G12** maliyet | Rakip adımı hafta başına ~55 işlem (8 rakip), bir dünya 0,08 sn |

---

## 8. Sınırlamalar

- **Uydurma dünya, kalibrasyon değil.** Ekip sayıları, havuz (12.000), pay devri, memnuniyet dağılımı ve yıldız karışımı kaynaksızdır ([WORKING], `constants.json`). Sonuçlar biçimi gösterir: hangi kural doygunluk ya da kart birikimi üretiyor.
- **Satış yok.** İmza bir süzgeçtir (her hatta açık ≤1, önemli modülde 0). Portföy ölçekte tutulur: giden hesabın yerine uygun aday gelir. Bu yüzden G4'ün MRR kaybı, G7 ve G11 ölçülmedi. 4★-5★ hesaplar süzgeçte çoğu zaman eleniyor (portföyde 3★+ %0-16).
- **Ses patlaması kısmen düzenekten.** Rampa sırasında haftada 10 hesap imzalanıyor; yenileme kontrolleri aynı haftalara yığılıyor. Mutlak tepe (8-12) bundan şişiyor; p99 daha sağlam okuma. Satış zarıyla imza yayılınca yeniden ölçülmeli.
- **Botlar kusursuz önceliklendiriyor** (şart önce, istek sonra). İnsan oyuncu şartı kaçırabilir; şartlı yenileme oranı gerçek oyunda daha yüksek çıkabilir.
- **Kart başına 6 kişi D'nin yer tutucusudur.** Geç kademelerde bağlayıcıdır (hat başına haftada 9 puan); atama araştırması bu sayıyı değiştirirse G1, G5 ve geç oyun değişir.
- **Rakip modeli eksik.** Kasa yok, ekip tavanı geliri izlemiyor. Rakip hesapları profil başına değil havuz bütününde. Girişim çıkış ve girişi hiç tetiklenmedi.
- **2030 ve 2035 aynı koşudur.** Tavan takvimi bitiş yılından bağımsız verildiği için 2030, 2035'in kesilmiş hâlidir. Bitişe göre sıkıştırılmış bir takvim denenmedi.
- **Profil verisi P kolunundur** (tek dosya, `P_profiles.json`). 7 ve 5 modülde katlama P'nin kuralıdır: 5'te Üretim, Depo, Mağaza, Proje ve Varlık düşer; 7'de Tedarik = Üretim ile Depo'nun yükseği, Mağaza ve Varlık düşer.
- **Mevzuat tarihleri** V #2'nin düzelttiği takvimdir (e-Belge 2016 3★+, 2019 2★, 2022 1★; sağlık 2016). KVKK şart tarihi 2018 ve sağlıkta 2017 [WORKING].
- **SENTEZ §11.4'teki biçim denetimi bulguları** (dik efor ve sert tavan doygunluk üretir; oyun ölçeğinde rakip, yumuşak efor ve iki yılda bir açılan tavan istenen biçimi verir) sim'in doğruluk testidir. Tur 0 doygunluğu üretti; tur 1-2 ve iki parçalı aday istenen biçime yaklaştı. Erken yıllardaki doygunluk bulgusu da tekrarlandı (dev 2015-2017).

---

## 9. Tekrar ve çalıştırma

- Resmî: `python -I sim.py --mod tam --isci 8` → 3 dk 50 sn, `out/tur2/sim1_sonuc.json`.
- İki KURAL adayıyla: `python -I sim.py --mod tam --isci 8 --ayar efor_bicim='"iki_parca"' --ayar efor_carpani=1 --ayar efor_g_giris=4.5 --ayar efor_g=1.2 --ayar istek_derinlik_hedefi='"piyasa"' --cikti ../out/tur2/sim1_sonuc_aday.json` → 3 dk 20 sn.
  - Bu dosyadaki 2 G8 satırı aynı olaydır: eski toplayıcı iki bitiş penceresini ayrı saydı, kod düzeltildi.
- Yalnız G1: `python -I sim.py --mod g1` → 3 N × 20 tohum, ~3 sn. Ayar taraması bununla yapıldı.
- Tek komut 10 dakikanın altında; arka planda koşuldu.
