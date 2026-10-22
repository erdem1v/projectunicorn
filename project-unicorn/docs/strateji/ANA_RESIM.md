# Project Unicorn ana resim ve yol haritası
2026-10-19 · Okuyucu: Erdem ve yardımcı yönetmen oturumu · Soru: "Biz ne yapmak istiyoruz? Amacımız ne?"

Yardımcı yönetmen notu (2026-10-19):
- ESKİDİ. Yerini İncil artifact'i aldı (kaynağı scratchpad'te `incil/index.html`). Erdem reddetti:
  - §7.3'teki olay tohumlarının tümü (evrak, hukuk ve vergi konuları).
  - §3'teki ofis şartları ve §11'deki K1–K2. Ofis yalnız paraya bağlanacak.
  
  Erdem'in yeni kararları: oyuncuya kredi seçeneği sunulacak; evde 1–2 uzaktan çalışan alınabilecek. Bu belgenin geri
  kalanı arka plan olarak durur.
- Durum: Erdem'in onayını bekliyor. §11'deki kararlar verilene kadar bu belge Q, C ve D oturumları için bağlayıcı
  değildir. C9 ve E1'deki İş hanı maddesi açık kalır.
- Bilinen çelişki: §9'daki "her fazdan sonra Erdem dilimi" satırları Erdem'in kararına aykırıdır. Erdem'in kararı Q, C ve
  D bitince tek bir uçtan uca oyun testidir. Bu karar geçerlidir; adım 4 o testtir.
- §11'deki K1–K6 bu belgenin sorularıdır. El kitabının K1–K5'iyle karıştırılmamalı.

Nasıl okunur:
- [A1 n] = A1 raporunun n numaralı kaynağı (A1 ile A4 aynı); [A1 ders n] ve [A1 Soru n] = raporun ders ve bulgu
  maddesi; [A4 Soru n] de öyle. [A5 §n] = iç inceleme, bölüm n. [EK §n] = el kitabı.
  [V] = A_V denetimi; denetimin düzelttiği iddia burada düzeltilmiş hâliyle yazıldı. [OH §n] = `faz_cde/OYNANIS_HUKMU.md`.
  [AI #n] = `faz_cde/ACIK_ISLER.md` maddesi. [PRD_C] = `PRD_FAZ_C_URUN_HESAP.md`. [PLAN_C] = `c_taslak/PLAN_C.md`.
- "Görüş:" ve "Öneri:" = benim çıkarımım, kanıt değil. [onay bekliyor] = sabit ya da kural önerisi. [hedef önerisi] = ölçülmemiş
  hedef. Bizim sayıların hepsi bot sayısıdır; 14. haftanın ötesini oynayan insan oturumu yok [A5 §0][EK §5].
- Terimler: basamak = oyuncunun rolünün değiştiği aşama. Devir = bir işi çalışana bırakmak. Şart hattı = parayı verenin
  koyduğu, ekranda hep görünen hedef listesi. hf = oyun haftası (bir tik). Saf saat = duraklamasız 1× süre.

---

## 0. Tek sayfada

**Ne yapıyoruz.** Project Unicorn, ilk kez kurucu olan birinin şirketiyle birlikte değiştiği bir girişim yönetimi
oyunudur. Oyuncu evde tek başına başlar: sprinti kendisi planlar, karta kendisi çalışır, satış görüşmesine kendisi gider,
Frank'ten ilk çeki alır. Her basamakta elindeki işin bir kısmını birine devreder ve yerine yeni bir iş alır: önce işe
alım ve uzaktan çalışan ilk ekip, sonra ofis, plan devri ve yatırımcının şartları, sonra yöneticiler, kurul ve şirketin
dışındaki insanlar. Eski iş hep elinin altında kalır ama zorunlu değildir. Amacımız türün en sık şikâyetini çözmek:
"birkaç saat sonra hep aynı iş" [A1 12][A1 14][A3 1]. Çıta Steam'de %90 üstü olumlu yorum.

**Vaat: kanca cümlesi adayları** (oyuncu metni kuralına uyar, tire yok)

| # | TR | EN |
|---|---|---|
| 1 | Birinci saatte kodu sen yazarsın. Yirminci saatte şirketi yönetirsin. | In hour one you write the code. In hour twenty you run the company. |
| 2 | Evde tek başına başla. Her işe alım senin işini değiştirir. | Start alone at home. Every hire changes your job. |
| 3 | Kurucu olarak başla, CEO olarak bitir: her basamakta yeni bir iş, eskisi hep elinin altında. | Start as a founder, finish as a CEO: a new job at every stage, the old one always within reach. |

Görüş: 1 numara en güçlüsü; Spore'un iki uçlu biçimine uyar ("From Single Cell to Galactic God") [A1 26]. Karar
vermeden önce birkaç kişiye sorulmalı [EK §2.3].

**Beş sütun (pillar)**

| Sütun | Tek cümle | Oynanışı nasıl etkiler |
|---|---|---|
| 1. Rol merdiveni | Her basamakta ana fiil değişir, eski katman açık kalır. | Birinci saatte oyuncu kart ve görüşme seçer; onuncu saatte öncelik ve kadro; yirminci saatte rapor ve insan. Zorla geçiş yok; zorla geçiren oyunlar puan kaybetti [A1 30][A1 21]. |
| 2. Devir gerçektir, bedeli vardır | Devredilen iş gerçekten gider; geri gelen yalnız kuralın dışındaki durumdur ve karar olarak gelir. | Tık azalır, karar kalır. "Hâlâ elle yapıyorum" ve "kendi kendine işliyor" hatalarının ikisinden de kaçar [A1 4]. |
| 3. Olay senin durumundan doğar | Her basamak kendi "ilk kez" sürprizlerini getirir; bedel ölçekten gelir, şıklar farklı hamledir, seçim iz bırakır. | Oyuncu her basamakta bilmediği yeni bir şeyle karşılaşır, aynı sorunu iki kez çözmez. Vaadin içerikten gelen eksenidir [A4 ders 1]. |
| 4. Para görünür bir karardır | Her gider görülür ve yönetilir; kasa hıza ya da riske çevrilir. | Runway baskısını oyuncunun seçtiği harcama kurar (işe alım, ofis, pazarlama), gizli kesinti değil. Gizli gider emsalde öfke yarattı [A3 79]. |
| 5. Sıradaki hedefin hep bir adı var | Hedefi parayı veren koyar: Frank'in şartı, seed şartları, kurul, sonra yöneticilerin raporu. | "Şimdi ne yapacağım" anı olmaz; öğretici biter, hedef sürer [A2 50][A2 97]. |

**Demonun rolü.** Demo merdivenin ilk üç basamağını oynatır ve dördüncünün kapısını aralar. Vaadin kanıtı demonun
içindedir: oyuncu bir saat içinde ana fiilinin iki kez değiştiğini yaşar (tek başına iş, ekip kurmak, planı devretmek).
Demo Series A davetiyle biter. Görüş: demo vaadi kanıtlar, satmaz; satan mağaza sayfası ve fragmandır. Bu türün iki
büyük başarısı demosuz Erken Erişim'de büyüdü [A1 46][EK §2.3].

---

## 1. Mikrodan makroya: emsal var mı

### 1.1 Kanıt
| Grup | Oyunlar (Steam İngilizce olumlu) | Ortak nokta |
|---|---|---|
| Katman ekleyip eskisini açık bırakanlar | Factorio %98, Kenshi %95, Software Inc. %94, Big Ambitions %91 [A1 5][V] | Oyuncu hiçbir yere zorlanmaz; yeni katman eskinin üstüne gelir [A1 15][A1 33][A1 8][A1 1] |
| Katmanı zorla değiştirenler | Civ VII %50, Frostpunk 2 %78 (birinci oyun %93) [V] | Oyuncunun sevdiği bir şey elinden alındı [A1 30][A1 21] |
| Hep mikroda kalanlar | Startup Company %80, Game Dev Tycoon %95, Mad Games Tycoon 2 %93 [A1 5] | Yüksek puanlılar da "aynı iş" şikâyeti alıyor [A1 12][A1 13][A1 14] |

- Geçişi çoğunlukla oyuncunun seçimi ve bir para ya da bina eşiği tetikler. Big Ambitions'ta yöneticiler masa ve
  bilgisayar ister, bu yüzden merkez ofis gerekir [A1 1][V]. Software Inc.'te lider işe alınır, İK eğitimi alır, altı
  oyun ayı beklenir [A1 9][V].
- Devredilen hep rutin iştir: fiyat, sipariş, maaş, şikâyet. Yeni fiiller atamak, kural koymak, rapor okumak [A1 Soru 2].
- Civ VII geri adım attı: 1.4 güncellemesi tüm kampanyayı tek uygarlıkla oynatıyor [A1 29][V].
- Başaranlar da geç oyun yorgunluğundan kurtulamıyor: "later on it's just doing the same stuff" (Software Inc.) [A1 10].

### 1.2 Batanların beş kalıbı [A1 Soru 3]
1. Son basamak sığ: Spore'un aşamaları "too fleeting", Bannerlord'un krallık katmanı zayıf [A1 27][A1 34].
2. Sevilen katman gidiyor: Frostpunk 2'de ızgara gitti, "politics became more intimidating than the cold" [A1 21][V].
3. Otomasyon ya çalışmıyor ya kararı siliyor: Big Ambitions'ta "hâlâ elle yapıyorum" ve "automates itself" aynı oyunda [A1 4][V].
4. Menüden yönetim: "click on a tile, click the check mark and then wait for a progress bar" [A1 21].
5. Geç oyunda para birikir, iş kalmaz: "the money keeps coming ... until there is nothing you can do anymore" [A1 4].
- Bize özel uyarı, Plutocracy (%79): siyaset var ama sonucu değiştirmiyor; olaylar zar atışı, "bribe or do nothing"
  aynı yere varıyor [A1 36][V].

### 1.3 Alan boş mu
- Kendin kodla, sonra yönet, sonra lobi ve diplomasi yap: üç adımı tek pakette veren oyun bulunamadı. Yarılar var:
  Software Inc. ve Big Ambitions (kurucu ve yönetici), Plutocracy (lobi, zayıf), Capitalism Lab (yapay zekâ CEO'lu
  iştirak, Steam dışı) [A1 Soru 4]. Mobilde Founder Sim Seed'den Series C'ye turlar anlatıyor; 26 değerlendirme,
  1.000'den az indirme [V].
- Tarama dardı; "kesin boş" denemez [A1 46]. Olumsuz iddia bu araçla kanıtlanamaz [V].
- Görüş: alan iki yarının farklı türlerde durduğu için boş: tycoon (süreç) ve büyük strateji (siyaset). Plutocracy
  birleştirmeyi denedi ve siyaset "sonuç değiştirmiyor" dendi [A1 36]. Boşluk zorluğun işareti olabilir, talepsizliğin de.

### 1.4 Bizim kurallarımız (Görüş)
1. Zorla geçiş yok. Her basamak bir seçimle açılır; eski katman oynanabilir kalır [A1 ders 3].
2. Devredilen iş gerçekten gider; geri gelen kural dışı durumdur ve karar kuyruğuna düşer [A1 ders 4].
3. Beş sığ basamak yerine üç derin basamak: demo 3 basamak, EA 4, tam oyun 5. Yeni basamak, öncekinin sığ olmadığı
   kanıtlanmadan açılmaz [A1 ders 1].
4. Kazanç bir karar olsun (risk, hisse, satın alma), sayaç değil [A1 ders 5].
5. Her diplomasi hamlesi görünür bir sonucu değiştirir; şıklar farklı yerlere varır [A1 ders 6].

---

## 2. Merdiven

Beş basamak. Demo 1 ile 3'ü oynatır; EA 4'ü ekler; tam oyun 5'i. Süreler 1×'tedir; insan süreleri [hedef önerisi].

### Basamak 1 · Ev, tek başına
| Alan | İçerik |
|---|---|
| Ana iş (fiiller) | Ürün türü seçmek, sprint planlamak, karta çalışmak, görüşmeye gitmek, fiyat söylemek. Kurucunun haftalık takası: görüşme mi, sprint mi [OH §2.1 satır 15]. |
| Devrettiği | Hiçbir şey. |
| Yeni baskı | Zaman: kurucunun saati satış ve sprint arasında bölünür. Para yok denecek kadar az: Faz C'den sonra MVP öncesi gider sıfır [A5 §5.3][PRD_C]. |
| Ödül anı | MVP yayını (bot hf 7), ilk ödeyen müşteri (hf 9), Frank'in çeki ve çerçevelenen ilk ödeme notu [A5 §7][A5 §6.3]. |
| Görev / hedef | Frank'in 5 adımlı çek listesi (tür, ilk sprint, yayın, ilk ödeyen, MRR $2.500), kodlu [A5 §0]. |
| Olaylar ve yazının rolü | Kurucunun ilkleri (alan adı, arkadaş testi, yan iş), tek kişilik işletmenin sürprizleri, B2C'de mağaza ilkleri. Yazı öğretmendir: bilgi bir ayrıntı olarak girer [A4 ders 6]. |
| Süre, sürüm | Bot B2B hf 1 ile 12, yaklaşık 4,5 dk saf saat [A5 §7]. İnsan 15 ile 20 dk [hedef önerisi]. Sürüm: Demo. |

### Basamak 2 · Ev ve uzaktan ilk ekip (1 ya da 2 kişi)
| Alan | İçerik |
|---|---|
| Ana iş (fiiller) | İşe almak, ekipman politikası koymak, uzaktan çalışmayı düzenlemek (saat, yazılı rapor), ilk maaş günü, ekiple ilk sürüm. |
| Devrettiği | Kart yapımının bir kısmı uzaktaki geliştiriciye ya da testçiye. Plan ve satış kurucuda kalır. |
| Yeni baskı | İlk sürekli gider: maaş. Junior geliştirici ×1,5 bantla ayda $3.000 ile $4.500, komisyon maaşın yarısı [A5 §5.1]. Uzaktan çalışmanın tek seferlik bedelleri olaydan gelir. |
| Ödül anı | Ekip ilk kez sensiz bir kartı bitirdi ve sürüm çıktı. |
| Görev / hedef | Seed şartları görünür olur (üç sonuç şartı; ONERI_TUR1'den, yapılmadı) [A5 §5.4]. |
| Olaylar ve yazının rolü | Uzaktan çalışma ve ilk işe alımın ilkleri: iş bilgisayarı, ev interneti, ilk gün hesapları, saat farkı, net ve brüt, ihbar süresi, deneme süresi (§7.3). Yazı maliyet dersidir. |
| Süre, sürüm | Bot B2B çekten seed'e hf 12 ile 21 [A5 §7]. İnsan 10 ile 20 dk [hedef önerisi]. Sürüm: Demo. |

### Basamak 3 · İlk ofis, Traction ve seed
| Alan | İçerik |
|---|---|
| Ana iş (fiiller) | Taşınmak, kadro karışımı seçmek, çeyrek hedefi seçmek, planlamayı PM'e devretmek, hangi sektöre satılacağını seçmek, seed pazarlığı, B2C'de pazarlama kanalı seçmek. |
| Devrettiği | Sprint planı PM'e (Faz D) [A5 §1 satır 3]. Lead'ler atanmış satış temsilcisine. Kurucu büyük adayı ve VC'yi oynar [OH §1.3]. |
| Yeni baskı | Kira (İş hanı $4.000) ve maaşlar; seed yarışı; B2C'de pazarlama harcaması [PRD_C][A3 74]. |
| Ödül anı | Seed imzası (gerçek pazarlıkla). PM'in ilk planı ("önce ve sonra"). Yıl sonunda gazetenin sektör listesinde ürünün adı (§6.3). |
| Görev / hedef | Seed'in iki dilimi ve Series A kapısı: MRR barı ve kalan yol aynı satırda [OH §6 madde 3]. |
| Olaylar ve yazının rolü | Ofis (depozito, stopaj, ek kira), ilk kurumsal müşteri (sigorta belgesi, 60 gün vade), seed'in hukuku, ilk işten çıkarma. Yazı risk ve hafıza taşır: politika bayrakları önceki seçimi anar. |
| Süre, sürüm | Bot B2B seed hf 18 ile 21, Series A kapısı hf 58 ile 60 (yaklaşık 15 dk saf) [A5 §7]. İnsan 30 ile 40 dk [hedef önerisi]. Sürüm: Demo. Series A daveti demonun sonudur. |

### Basamak 4 · Series A sonrası: departmanlar ve kurul
| Alan | İçerik |
|---|---|
| Ana iş (fiiller) | Departman kurmak, lider atamak, raporu okumak (karar kuyruğu), kurulla hedef pazarlığı, ikinci ürün açmak, küçük rakip almak. |
| Devrettiği | Departman işleri liderlere; yenileme raporu satış liderine; kurucu kurul ve büyük hesaplarla uğraşır. |
| Yeni baskı | Plaza kirası $8.000, departman bütçeleri, kurul hedefini kaçırmanın bedeli (güven), rakip saldırıları. |
| Ödül anı | Series A imzası, ilk 3★ kurumsal hesap, "Yılın Ürünü" ödülü (§6.3). |
| Görev / hedef | Çeyreklik kurul hedefleri ve kurul güveni; Football Manager'ın yönetim kurulu emsali [A2 43][A2 44]. |
| Olaylar ve yazının rolü | Yöneticinin getirdiği kural dışı durum, kurul toplantısı, rakip hamlesi, kriz arkları. Yazı gidişatı değiştirir. |
| Süre, sürüm | 3 ile 6 saat [hedef önerisi]. Rakip PRD'nin onaylı zaman kuralı: perde 2'den sonra tik kabalaşır [A5 §4]. Sürüm: EA. Bugün Series A her build'de son (`endings_system.gd:353-356`) [A5 §5.5]; EA'da geçiş olur. |

### Basamak 5 · Series B ve sonrası: dış dünya
| Alan | İçerik |
|---|---|
| Ana iş (fiiller) | Halka arz, lobi ve ilişki, birleşme, ürün portföyü, hisse ve satın alma. |
| Devrettiği | Ürün döngüsü çalışanlara; ürün penceresi gözlem modunda açık kalır, devir kademeli [A1 ders 9]. |
| Yeni baskı | Loft $18.000, halka arz beklentisi, itibar ve siyaset. |
| Ödül anı | Halka arz günü, Piyasa listesine giriş, rakibi satın almak. Piyasa'nın Perde 3 rezervleri hazır [A5 §4]. |
| Görev / hedef | Yöneticilerin raporlarındaki hedefler, halka arz şartları. |
| Olaylar ve yazının rolü | Diplomasi benzeri ilişki ağı: kurul üyesi, yönetici, büyük müşteri, rakip CEO, düzenleyici. Yazı oyunun kendisidir. |
| Süre, sürüm | 5 ile 10 saat [hedef önerisi]. Sürüm: Tam oyun (ch14 §5: IPO, Series B, makro ekonomi, diplomasi katmanı) [A5 §4]. |

### 2.6 Geçişi ne tetikler
| Geçiş | Tetik | Not |
|---|---|---|
| 1 → 2 | İlk işe alım (oyuncunun seçimi; para çekten ya da kasadan) | `funding.hire_nudge` çekten bir hafta sonra "ilk çalışanını bul" der; bugünkü kurguya uyar [A5 §5.1] |
| 2 → 3 | Üçüncü işe alım isteği (Ev dolu) ve taşınma şartı; ya da seed imzası | İkisi ayrı tetiktir; seed parası taşınmayı çeker (§3) |
| 3 içi | Planlamayı devret (aktif PM şart) | Kilometre taşı ve tören; Software Inc.'in lider eğitimi emsali [A1 9] |
| 3 → 4 | Series A imzası | EA'da geçiş |
| 4 → 5 | Series B imzası | Tam oyun |

### 2.7 Eski katman erişilebilir mi
Evet. Kurucu her basamakta görüşmeye gidebilir, sprinti kendisi planlayabilir. Devri geri almak mümkün, bedeli var (bir
sprintlik hazırlık kaybı gibi) [onay bekliyor][A1 ders 2]. Sonradan eklenen sistem kapatılabilir ya da ölçeklenir:
Software Inc.'te "no way to opt out" şikâyeti 56 oy aldı [A1 10].

### 2.8 Her basamağın sığ kalmaması için kural (çıkış kapısı)
Bir basamak şu altı şartı tutmadan "bitti" sayılmaz ve üstüne yeni basamak kurulmaz:
1. Önceki basamakta olmayan en az üç fiil.
2. En az bir yeni baskı (para nereye yanıyor) ve en az bir ödül anı.
3. Adlı bir hedef: TopBar "Sıradaki" hiç boş kalmaz.
4. En az 8 seçenekli "ilk kez" kartı; şıklar farklı türde hamle [A4 ders 7].
5. Her 10 haftalık pencerede en az 3 gerçek karar: iki farklı bot politikasının farklı sonuç aldığı karar [OH §3 Risk 1].
6. Erdem oynadı ve hissi kabul etti (Kat 2) [EK §4.3].
- Ölçek kuralı: kesinti bütçesi her basamakta haftada en çok 1; kesinti kişi ya da hesap sayısıyla doğrusal büyümez
  [OH §0 madde 5][OH §1.3].

### 2.9 Yirminci saat için gerçek
- Bugün 104 hafta 1×'te 39 dk saf saat; bot Series A'yı 21 ile 27 dk'da imzalıyor [A5 §0 madde 3]. Erdem'in andığı 10 ile
  20 saat, 104 haftalık koşunun 15 ile 30 katı [A5 §7].
- Görüş: 20. saati süre değil basamak 4 ve 5'in içeriği doldurur. Tek kişilik ekip için bu büyük bir kapsam. Bu yüzden EA
  basamak 4 ile açılır, basamak 5 EA güncellemeleriyle gelir. Big Ambitions EA'da 3,5 yıl ve 11 sürümle büyüdü [EK §2.1].

---

## 3. Erken oyun önerisi

### 3.1 Bugün ne var
- Kod: evde işe alımın masa sınırı yok; evdeyken alınan çalışan eve gelmez, uzaktan çalışır (sahip kararı 9,
  2026-09-28) [A5 §0 madde 1]. Erdem'in isteği bugünkü kodun davranışıdır.
- Plan: Faz C'nin C9'u "masa sayısı işe alım tavanı; Ev 1 masa; ilk işe alım İş hanı'na taşınmadır; $4.000 kira ilk
  çalışanla başlar" der [PRD_C]. C9 kodlanmadı ve 2026-10-19'da askıya alındı [PLAN_C].
- İş hanı şartı bugün Frank'in çeki ve kasada $6.500; taşınma bedelsiz [A5 §5.2].
- Ölçüm: çek ile seed arasına eklenen her gider en az bir tohumu seed'den önce iflas ettirdi (ACIK 98) [A5 §5.2]. Bot çeki
  B2B hf 12 ile 13, B2C hf 22 ile 24; seed B2B hf 18 ile 21, B2C hf 50 ile 55 [A5 §7].

### 3.2 Evde uzaktan çalışan: seçenekler
| Seçenek | Kural | Oynanışa etkisi | Bedel |
|---|---|---|---|
| S1 · C9 olduğu gibi | Ev 1 masa, ilk çalışan taşınmadır | İlk işe alım ilk büyük para kararı ($7.000 ile $8.500/ay) [PRD_C] | Erdem'in isteğiyle ve sahip kararı 9'la çelişir; ACIK 98'in iflas riski; ilk çalışan çeki bekler |
| S2 · Ev kapasitesi 3 (öneri) | Kurucu masası ve en çok 2 uzaktan çalışan; 3. çalışan ofis ister; ofislerde masa tavanı aynen | Basamak 2 birinci saatin içine girer; para kararı önce maaş, sonra kira | Küçük: C9 kodlanmadı; Atlas'ta tek cümle, botun taşınma politikası |
| S3 · Evde sınırsız (bugünkü kod) | Tavan yok | Ofisin anlamı kalmaz; masa tavanı ofiste bile delinir | 1 kişiden 50 kişiye kural kırılır: 20 kişilik ev ekibi |

Öneri S2. Görüş: kural "koltuk sayısı işe alım tavanıdır" diye tek cümlede kalır; Ev'in koltuğu 3'tür (1 masa ve 2
uzaktan). VIZYON yanıtında da evde uzaktan tavanı 2 yazıyordu, onaysız kalmıştı [A5 §0 madde 2].

### 3.3 Uzaktan çalışanın bedeli
- Gizli verim cezası yok. VIZYON yanıtındaki %15 koordinasyon kaybı [A5 §5.1] görünmez model olur; konmaz.
- Bedel görünürdür ve olaydan gelir: bilgisayar, internet, ilk gün, saat farkı (§7.3). Her biri oyuncunun seçtiği bir
  hamledir, kasadan kendiliğinden düşen bir kesinti değil [A4 ders 5].
- Ofise taşınınca uzaktakiler ofise gelir ve birer masa tutar. Uzaktan kalma seçeneği EA'ya kalır.
- Dönem: koşu 2012'de başlıyor; yazar brifi "2012'de uzaktan çalışma yok" diyor [A4 49]. Uzaktan çalışmanın 2012'de
  e-posta ve görüntülü aramayla yapılabildiği kaynaksız bir model bilgisidir [V]. Görüş: kartlar dönemden bağımsız yazılır
  ("sözleşmede yazmamıştın"); kod hâlâ 2026'da başlıyor [A5 §4].

### 3.4 İlk ofis şartı
| Seçenek | Oynanışa etkisi | Bedel |
|---|---|---|
| Ofis seed'e bağlı | ACIK 98 riski kalkar | B2C seed hf 50 ile 55; B2C oyuncusu bir yıl üç kişide kalır. Erken taşınma riski diye gerçek bir karar kaybolur |
| Frank çeki ve $6.500 (bugün) | Basit | $4.000 kira ile $6.500 bir aydan az; tuzak |
| Görünür runway şartı (öneri) | Erken taşınmak gerçek bir risk kararı olur | Ofis kartı bir hesap gösterir |

Öneri: İş hanı şartı "taşındıktan sonra kasa en az 3 aylık gideri karşılar" olur; Frank çeki şartı kalkar [onay
bekliyor]. Ofis kartı yeni aylık gideri ve kalan runway'i yazar [A3 ders 5]. Kanıt: Game Dev Tycoon oyuncuları erken
taşınınca aylık 32 bin ile 70 bin dolara batıyor ve milyonlar birikene kadar bekliyor (oyuncu beyanı) [A3 63][A3 64][V];
oyun yine %94,5 olumlu [A3 1]. Yani riskli taşınma eğlenceli bir baskıdır, yeter ki görünür olsun.

### 3.5 Frank çeki ve seed zamanı
- Frank aynen kalır: $25.000, %4, MRR $2.500 kapısı, 5 adımlı liste [A5 §3]. Çek ilk uzaktan işe alımın parasıdır.
- B2B'de seed zaten yakın: çekten 6 ile 8 hafta sonra [A5 §5.2]. "Seed'i yakına al" sorusu B2C'nin sorusudur.
- Öneri: B2C seed hedefi hf 35 ile 45 [hedef önerisi]. Kaldıraç iki: B2C kapısı ayrı ölçülür (bugün tek sabit
  `DOOR_MRR` $20.000) [A5 §5.2] ve pazarlama B2C büyümesini hızlandırır (§6). B2C MRR bot medyanı hf 30'da $4.000,
  hf 52'de $20.000 [A5 §7].

### 3.6 Başlangıç kasası
Gelir hariç, komisyon dahil; junior ortalama $3.750/ay, komisyon $1.875 [A5 §5.3] [hesap].

| Kasa | Gelirsiz runway, 1 uzaktan junior | 2 uzaktan junior | Frank çekiyle (+$25.000), 1 junior | Frank çekiyle, 2 junior |
|---|---|---|---|---|
| $10.000 (bugün Normal) | 2,2 ay | 0,8 ay | 8,8 ay | 4,2 ay |
| $25.000 (öneri) | 6,2 ay | 2,8 ay | 12,8 ay | 6,2 ay |
| $50.000 (Erdem'in fikri) | 12,8 ay | 6,2 ay | 19,5 ay | 9,5 ay |

- Faz C'den sonra MVP öncesi gider sıfır; kasa ancak ilk işe alımda anlam kazanır [A5 §0 madde 5].
- Botlar $10.000 ile iflas etmiyor (en düşük kasa B2B $5.800 ile $6.400) [A5 §5.3]. "Başı zor" para mı, ne yapacağını
  bilmemek mi, ölçülmedi [A5 §0 madde 5b].
- Öneri: Normal $25.000 [onay bekliyor]; zorluk çarpanları aynı (Kolay ×1,5, Zor ×0,6) [A5 §0 madde 5]. Görüş:
  Erdem'in $50.000'i ilk işe alım anında zaten elde olur ($25.000 ve Frank'in $25.000'i). Son karar C0s ölçümü, "öğreticiyi
  harfiyen izleyen bot batmaz" kapısı ve bir insan oturumundan sonra [A2 ders 3][A3 ders 6].

### 3.7 Kurucu maaşı
Yok (Erdem, Faz C). C kurucu satırını, araç ve servis giderini siliyor [A5 §0 madde 5]. Bugünkü çalışan başına $150/ay
"yazılım, lisans ve donanım" kalemi gizli bir ekipman payıdır; silinmesi bilgisayar olayıyla uyumludur: ekipman artık
oyuncunun gördüğü ve seçtiği bir giderdir [A5 §5.7].

### 3.8 C9 ile çelişki ve çözüm
- Çelişki: C9 "Ev 1 masa, ilk çalışan taşınmadır" der; Erdem "evde 1 ya da 2 uzaktan çalışan" ister. Erdem 18 Ekim'de
  "masa sayısı kadar çalışan" kuralını onayladı, "ilk çalışan taşınmadır" sonucu ayrıca konuşulmadı [A5 §5.1].
- Çözüm (C9 yeniden yazımı) [onay bekliyor]:
  1. Ev'in kapasitesi 3: kurucu masası ve 2 uzaktan koltuk. İş hanı 10, Plaza 36, Loft 64 aynen.
  2. Kira taşınmanın tamamlandığı hafta başlar, ilk çalışanla değil.
  3. İş hanı şartı: Frank çeki kalkar; "taşındıktan sonra kasa en az 3 aylık gideri karşılar".
  4. Taşınınca uzaktaki çalışanlar ofise gelir, masa tutar.
  5. Botun taşınma politikası: üçüncü işe alımı istediğinde şart tutuyorsa taşınır. Tavan ve politika aynı commit'te
     girer (PLAN_C'nin risk notu) [PLAN_C].
- Bedel: sıfıra yakın, çünkü C9 kodlanmadı [A5 §0 madde 1]. ACIK 98'in iflas ölçümü yeni kuralla yeniden koşulur.

---

## 4. Öğretici ve görev

### 4.1 Kanıt
- Big Ambitions (%91): akıl hocası Uncle Fred telefonda; görevler isteğe bağlı ve süresiz, telefonla susturulur ve geri
  çağrılır [A2 12][A2 13][V]. 2025'ten beri ilk rakip saldırısında Fred durumu anlatır [A2 2][V].
- Startup Company: yatırımcının danışmanı sıradaki kilometre taşını anlatır, "tutorial mode in disguise" [A2 18][V].
  Şikâyet: liste bitmediği için öğretici oyunun kendisi sanılıyor [A2 60]; şart öz sermaye sattırıyor [A2 24][V].
- Görünür listede isteğe bağlı hedef fiilen zorunlu olur (Murthy) [A2 45][V]. Öğretici batırıyor: dört yorumdan üçü
  iflası öğreticiye bağlıyor, biri harfiyen izlediğini söylüyor [V].
- Kilometre taşı sayı değil kaldıraç açmalı [A2 86][A2 38][V]. Öğreticiden sonra boşluk: "entirely on your own"
  [A2 50], "and then what" [A2 97].
- Bizde: Frank'in 5 adımlı listesi ve TopBar "Sıradaki" kodlu; "Frank'le rehberli başla" anahtarı kilitli, çünkü
  `tutorial` etiketli kart sıfır; seed ile Series A arası yaklaşık 40 hafta adlı hedef yok [A5 §0 madde 6].

### 4.2 Öneri: iki hat ve ilk karşılaşma olayları
1. **Şart hattı (bağlayıcı, hep görünür).** Parayı veren hedefi koyar: Frank'in çek listesi (var), seed'in üç sonuç
   şartı ve iki dilimi, Series A'da kurul hedefleri, sonra yöneticilerin raporu. TopBar "Sıradaki" bu hattı okur. Bu,
   2026-10-10'da daraltılan "görev yok; para verenin şartı serbest" kararının devamıdır [A5 §5.4].
2. **Frank'in rehberi (isteğe bağlı, süresiz).** Bir sistem ilk kez göründüğünde Frank tek cümleyle yorum yapar. Tek
   tuşla susturulur, geri çağrılır. Hüküm yalnız Frank'in ağzındadır (CLAUDE.md §5). Kilitli anahtar açılır.
3. **İlk karşılaşma olayları.** Her yeni sistemin ilk görünüşü garanti bir kartla gelir (ilk uzaktan işe alım, ilk maaş
   günü, ilk taşınma, ilk kayıp); sonrası rastgele [A2 ders 5]. Bilgisayar olayı öğretici metni olmadan bir maliyet
   dersi verir.
- İki hat ayrı görünür: şart listesi ile rehber aynı listede durmaz, yoksa isteğe bağlı olan zorunluya döner [A2 45].

### 4.3 İlk 15 dakika [hedef önerisi]
| Dakika | Oyuncu ne yapar | Ekranda ne var | Ne öğrenir |
|---|---|---|---|
| 0 ile 2 | Şirket adı, B2B ya da B2C, evde ilk sabah | Frank'in tanışma notu; çek listesi 5 adım | Hedefi parayı veren koyar |
| 2 ile 4 | Ürün türünü seçer, ilk sprinti planlar | Plan ekranı, darboğaz cümlesi | Sprint, kart, kurucunun saati |
| 4 ile 8 | Sprint akar, ilk karar kâğıdı gelir, MVP çıkar (bot hf 7) | Ofis, sürüm notu | Kâğıdın bedeli, sürüm |
| 8 ile 11 | Frank'in tanıştırdığı ilk adayla görüşür, ilk imza (hf 9) | Görüşme paneli, aday kartında ürün uyumu sözcüğü | İlk zafer |
| 11 ile 13 | İkinci görüşmede ürünün zayıf alanı yüzünden kaybedebilir | Kayıp nedeni tek cümle (Q'nun imza kapısı) [OH §2.1 satır 5] | İlk açıklanmış kayıp |
| 13 ile 15 | Traction kapısı, MRR $2.500, Frank'in çeki; "ilk çalışanını bul" | Sıradaki satırı seed şartlarına döner | Basamak 2'nin kapısı |
- Kaynak: "ilk 15 dakikada zafer, ilk saatte açıklanmış kayıp" [OH §5]. Tablo B2B akışıdır; B2C'de çek hf 22 ile 24'te
  gelir [A5 §7]. "Karar verince saat aksın" ayarı bu akışın parçasıdır [AI #4][OH §6 madde 5].

### 4.4 Öğreticiden sonra hep adlı bir hedef
| Basamak | Sıradaki satırının kaynağı | Açtığı kaldıraç |
|---|---|---|
| 1 | Frank'in 5 adımı | Çek, ilk işe alım |
| 2 | Seed'in üç sonuç şartı | Seed masası |
| 3 | Seed'in iki dilimi, sonra Series A kapısı (MRR barı ve kalan yol) | Plan devri, ofis, Series A daveti |
| 4 | Çeyreklik kurul hedefleri | Departman, ikinci ürün |
| 5 | Yöneticilerin raporu, halka arz şartları | Halka arz, birleşme |

### 4.5 Kurallar
- Hedefler dünya durumuna bakar; erken yapılan hedef kendiliğinden tamamlanır. Big Ambitions bunu yıllarca yamayla
  öğrendi [A2 ders 2][A2 4][A2 5][A2 6]. Kapı: "öğreticiyi harfiyen izleyen bot batmaz" [A2 ders 3][V].
- Şart kaçırma: ilki uyarı, ikincisi bedel; eşik görünür [A2 ders 7]. Hedef şişmesi yok: her dönem başka eksen [A2 ders 8].
- Smoke: "Frank'i izle", "Frank'i sustur", "hedefleri erken yap", "evden ofise taşın" [A2 ders 10].

---

## 5. Rakip

### 5.1 Kanıt
- Adı olan ama bir şey yapmayan rakip şikâyet alıyor: Startup Company'de rakip "satın alınmayı bekliyor"; geliştirici
  "more challenging competition" sözü verdi [A3 76][A3 54][A3 55][V].
- Big Ambitions: dört adlı rakip, her biri bir mahallede; kira reddi, fiyat kırma, benzer mağaza, çalışan çalma
  saldırıları; şiddet zorluğa bağlı [A3 14][V]. Oyuncular: dört ana rakip karakterli, 15 küçük rakip "dolgu" [A3 59].
- Rakipten söz eden yorumlar arttı ama puan belirgin değişmedi [A3 1]. Offworld'de yapay zekâ oyuncuyla aynı kurallarla
  oynar [A3 73]; Mad Games Tycoon 2'de yeni şirketler zamanla girer, yıl sonu ödüllerinde yarışır [A3 24].
- Bizde: Piyasa I1 kodlu (salt okunur); I2 hafif sektör rakipleri yazılı ama yapılmadı: lider, yerleşik, kopyacı (oyuncunun
  çıkışlarını en az 3 sprint gecikmeyle izler), niş, fonlu giren, gizli özel (Rakip PRD §4.1) [A5 §1 satır 22].
- Ölçek: seed $100.000 ile $150.000; Series A öncesi bir şirketi değeriyle almak bütçe dışı [A5 §1 satır 22]. GDD ch10 §8:
  "rakipler satın alınabilir mi: varsayılan hayır".

### 5.2 Öneri
- Series A'ya kadar değerle şirket satın alma yok. Rakip demoda vardır ama alınacak bir nesne değil, oyuncuya cevap veren
  bir karakterdir.
- I2'nin lig kadrosu demoya girer. Her lig rakibi oyuncunun bir kararına cevap veren en az bir hamle yapar [A3 ders 1]:
  kopyacı gönderdiğin özelliği izler, fonlu giren uzaktaki geliştiricini çalmaya çalışır (§7.3 tohum 16), lider satış
  itirazında anılır. Rakibin kuralı görünür olur [A3 73].
- Series A öncesinin tek alımı küçük bir ark olur [onay bekliyor]: kapanan rakip (`rival.shutdown_notice` var [A4 Soru 4])
  müşterilerini ya da iki kişilik ekibini devretmeyi önerir; bedel nakit ve masa. Bu, seed parasıyla verilen gerçek bir
  karardır ve satın almanın tadını değerleme ölçeğine çıkmadan verir.
- Kapanan rakibin yerine yeni girişim doğar [A3 59][A3 24].
- Değerle satın alma, hisse ve birleşme basamak 4 ile 5'in işidir (Piyasa Perde 3 rezervleri) [A5 §4].

---

## 6. Para ve baskı

### 6.1 Kanıt
- Pazarlama karar olduğunda sevilir (hedef kitle seçimi, söz verip tutma, açığa çıkma riski), vergi olduğunda angaryadır
  (her ay aynı reklamı yenilemek) [A3 78][A3 10][A3 74][A3 75]. Startup Company'de pazarlama maaştan sonra ikinci gider;
  kısmak öldürmez, yavaşlatır [A3 74]. Software Inc. satış sonrası pazarlamayı yıllarca yeniden yapamadı [A3 11][V].
- Para amaç olarak kalırsa oyun zenginleşince biter: "Yes, there's no endgame." [A3 40][V]. Megaquarium kalıbı: erken
  para, orta Ar-Ge, geç prestij [A3 41][V]. Yatırım ancak kayıp görünür ve geri dönüşü zorsa gerçektir; yoksa piyango
  ya da gösteriş olur [A3 72][A3 46][A3 79].
- Bizde: Traction'ın %94'ünde runway sonsuz [EK §5]. Ar-Ge'nin 20 düğümünden 4'ünün okuyucusu yok [A5 §1 satır 14].
  Pazarlama sekmesi EA'da kilitli; beş "ödemeli yer" kartı ilkel pazarlama ve dördü aynı kalıp [A5 §1 satır 12][A4 Soru 4].

### 6.2 Araçlar basamak basamak
| Araç | Basamak 1 ile 2 | Basamak 3 | Basamak 4 ile 5 | Ne zaman |
|---|---|---|---|---|
| Pazarlama | Yok (kurucu kendisi anlatır; olay kartları) | B2C: 2 ya da 3 kanal, kitle seçimi (niş, geniş), söz verme (beklentiyi de büyütür) [A3 10]; B2B: fuar ve referans olayları | Pazarlama departmanı ve lideri | B2C küçük sürüm demoya; departman EA |
| Ofis | Ev (kirasız) | İş hanı $4.000, Plaza $8.000 [PRD_C] | Loft $18.000 | İş hanı ve Plaza demo, Loft EA |
| Ar-Ge | Görünmez kalabilir | Düğüm yeni hat ve kart açar; ürün kart sayısı Ar-Ge'ye bağlanır [AI #10][AI #11]; okuyucusuz 4 düğüm bağlanır ya da demodan çıkar | Paralel araştırma, patent, rakip araştırması (Ar-Ge GDD §11) [A5 §1 satır 14] | Bağlama demo, derinlik EA |
| Yatırım araçları | Yok | Yok | Piyasa şirketlerinde hisse (kayıp görünür), rakip satın alma, halka arz | EA ve tam oyun |
| Kurucunun kişisel serveti | Yok | Yok | Zengin listesi (Piyasa rezervi) [A5 §4] | Tam oyun |

- Görüş: B2C'nin orta oyun boşluğunu (haftaların %65'i kartsız) [EK §5] pazarlama ile fiyat kolu (Faz E) birlikte doldurur.
  Pazarlamaya para yakmak runway baskısını oyuncunun kendi seçimi yapar; Erdem'in istediği baskı budur.
- Görüş: para merdiveni Megaquarium kalıbının bizdeki karşılığıdır: runway, sonra müşteri güveni ve değerleme, sonra
  insanlar ve itibar [A3 ders 3].

### 6.3 Ödül anı: "yılın en iyisi" duygusu
- Erdem'i tutan süreç değil ödül anı: yaptığı ürünün o yılın en iyisi seçilmesi.
- Kanıt: Mad Games Tycoon 2'de rakipler listelerde ve yıl sonu ödüllerinde yarışıyor [A3 24]. Bizde Piyasa'nın yıl sonu
  tablosu ve gazete var; ürün ödülü sistemi yok [A5 §1 satır 9].
- Öneri: her yıl sonunda gazete sektörün yılını yazar ve ürünün yerini adıyla verir (demoda hf 52). EA'da "Yılın Ürünü"
  ödülü: ölçütü görünür (yıldız, büyüme, müşteri memnuniyeti); gizli puan yok, çünkü gizli puanlama türün beş olumsuz
  temasından biri [EK §2.2][EK §2.3 madde 4] [onay bekliyor].

---

## 7. Olay tasarım çıtası

### 7.1 Ölçü: Erdem'in uzaktan bilgisayar olayı
Bir hafta geçer, uzaktaki çalışan yazar: "Patron, görüşmede sormayı unuttum, bana bir iş bilgisayarı göndereceksiniz,
değil mi?" Kalıbı dört satırdır [A4 ders 2]:
1. Kurucunun varsayımı: ofis her şeyi sağlar.
2. Görmediği bağımlılık: uzaktaki çalışanın ofisi yok.
3. Fatura: bir bilgisayar.
4. Farklı türde hamleler: cihaz gönder, ödenek ver, kendi cihazıyla çalışsın ve riski al.
- Gerçeklik: Türkiye'nin 2021 Uzaktan Çalışma Yönetmeliği m.7, sözleşmede aksi yoksa iş araçlarını işverenin
  sağlamasını esas alır [A4 4][V]. GitLab'ın ev ofisi ödeneği rakamı doğrulanamadı [V]; sabit ona dayanmaz.
- Plutocracy'nin "bribe or do nothing" olaylarının tersidir [A1 36][A1 ders 7].

### 7.2 İlkeler
1. **Durumdan doğar.** Olayı oyuncunun önceki kararı doğurur (uzaktan işe alım). Havadan gelmez [A4 Soru 3][A4 39].
2. **İlk kez yaşanır.** Bilgi eksikliğini kullanır; her basamakta yeni bir küme [A4 ders 1].
3. **Bedel somut ve ölçekten.** Bedel oyuncunun zaten saydığı birimde (kasa, runway haftası, kurucu saati) ve şirketin
   ölçeğinden: sabit dolar değil, aylık maaşın ya da gelirin oranı [A4 ders 4]. Bedelsiz çıkış yok.
4. **Sistem okur.** Seçim iz bırakır: "ekipman politikası" bayrağı kurulur, ikinci uzaktan çalışanda soru gelmez, politika
   uygulanır ve çip yazar [A4 ders 3]. Frostpunk'ın sıralı yasaları emsal [A4 34][A4 35].
5. **Tekrar etmez.** Her tohum bir kez, bir eşikte gelir; ikincisi kısa varyanttır [A4 ders 13]. Football Manager'da
   bile tekrarlayan basın toplantısı "autopilot"a döndü [A4 44].
- Şık testi: üç hamle farklı türde (para, zaman, ilişki); fiyat kademesi şık sayılmaz [A4 ders 7][A4 42]. Gizli gider
  testi: önceden görülebilir miydi, iki adlı seçenek var mı, sonuç sonra hatırlanıyor mu [A3 ders 7].
- Motor eksikleri: aylık sürekli gider, vadeli tahsilat ve kilitli nakit fiili yok [A4 ders 9]; "çalışan uzaktan mı"
  seam'i yok, `office.current == home` ile türetilir [A5 §6.4].
- Bugünkü envanter: 128 demo kartı; uzaktan çalışan, ekipman, bordro, sözleşme, sigorta, kira konulu kart sıfır
  [A5 §6.3]. En güçlü kartlar (`team.wiped_table`, `product.launch_leak`, `customer.new_owner`) çıtaya yakın; dört
  `world.` kartı tek kalıp [A4 Soru 4].

### 7.3 Olay tohumları (A4'ten, kaynaklı)
Tutarlar örnektir; uygulamada ölçekten gelir. Dönem: E = 2012'de de olur, U = 2012'ye uyarla [A4 Soru 2]. Taslaklar
"önce İngilizce" kuralına göre yazılacak; burada fikir taslağıdır.

| # | Basamak | TR taslak | EN taslak | Hamleler | Kaynak | Not |
|---|---|---|---|---|---|---|
| 1 | 1 | Frank'in çeki hesaba geçti, ertesi sabah avukatın faturası geldi: belgeler çekin sekizde biri. | Frank's cheque cleared, and the next morning the lawyer's invoice arrived: the paperwork costs an eighth of the cheque. | Standart belge / tam belge (seed'de iz) / avukatsız imzala (seed'de belge eksiği kartı) | [A4 12] | E |
| 2 | 1 | Bütün şirkete yayacaklarını söyleyen müşteri üç haftadır cevap vermiyor ve sen ilk işe alımı onlara göre planlamıştın. | The customer who said they would roll you out across the company hasn't answered in three weeks, and you planned your first hire around them. | Kurucu saatini takibe ver / planı küçült / yine de işe al | [A4 11] | E, B2B |
| 3 | 1 | Mağaza ilk gönderimini geri çevirdi: incelemecinin girecek hesabı yok, iki ekranda hâlâ deneme metni duruyor. | The store rejected your first submission: the reviewer had no account to log in with, and two screens still show placeholder text. | Düzelt ve gönder (bir hafta) / itiraz et (belirsiz) / önce web sürümünü aç | [A4 22] | E, B2C |
| 4 | 1 | Mağazadan ilk ödeme geldi ve satışların yüzde otuzu komisyon olarak kesilmişti. | The first store payout arrived, and thirty percent of your sales had gone to commission. | Fiyatı artır / ödemeyi siteye taşı (sprint kartı) / kabul et | [A4 22][A4 23] | E, B2C |
| 5 | 1 | Ödeme sağlayıcın yeni hesap olduğun için satışlarının onda birini doksan gün tutacağını yazdı. | Your payment provider says that since your account is new, it will hold a tenth of your sales for ninety days. | Yıllık plan indirimiyle nakdi öne çek / sağlayıcı değiştir / kabul et | [A4 26] ticari kaynak | Kilitli nakit fiili gerekir |
| 6 | 2 | Patron, görüşmede sormayı unuttum: bana bir iş bilgisayarı gönderecek misiniz, yoksa kendi bilgisayarımla mı devam edeyim? | Boss, I forgot to ask in the interview: are you sending me a work laptop, or should I keep using my own? | Cihaz gönder / ödenek ver / kendi cihazına aylık pay (veri riski bayrağı); seçim politika bayrağı kurar | [A4 4][A4 5][V] | Erdem'in örneği; U |
| 7 | 2 | Uzaktaki geliştiricin evdeki internet ve elektrik faturasını kimin ödeyeceğini soruyor, sözleşmede bu yazmıyor. | Your remote developer is asking who pays for internet and power at home, and the contract doesn't say. | Aylık sabit yardım / belgeyle toplu geri ödeme / "sözleşmede yok" (moral, ayrılma riski) | [A4 4] | Aylık gider fiili gerekir |
| 8 | 2 | Yeni geliştiricinin ilk günü: hesapları açılmamış, bilgisayarı yolda ve üç gündür koda erişemiyor. | Your new developer's first day: no accounts yet, the laptop is in transit, and three days later they still can't reach the code. | Hızlı kargo ve kurucunun bir günü / geçici kendi cihazı / başlangıcı bir hafta kaydır (maaş akar) | [A4 2] | E |
| 9 | 2 | Uzaktaki geliştiricinle aranda üç saat fark var ve haftalık görüşmeye ancak akşam dokuzda vakit çıkıyor. | There are three hours between you and your remote developer, and the only slot for your weekly call is nine in the evening. | Ortak pencere (onun hızı biraz düşer) / yazılı günlük (kurucu saati) / kurucu geceye kayar (iki hafta sprint payı düşer) | [A4 2] | E |
| 10 | 2 | Fatura keserek çalışan tasarımcın üç aydır haftada kırk saat sana çalışıyor ve aranızda yazılı bir şey yok. | The designer who invoices you has worked forty hours a week for you for three months, and nothing is in writing. | Çalışan olarak kaydet (işveren payı) / proje sözleşmesi (kapsam küçülür) / bırak (denetim kartı ihtimali) | [A4 6][A4 30] | E |
| 11 | 2 | Aday teklifini okuyunca konuştuğunuz rakamın net olduğunu, brütün dörtte bir yüksek yazılması gerektiğini söyledi. | Reading your offer, the candidate says the figure you discussed was take home pay, and the gross should be a quarter higher. | Brütü yükselt (aylık) / ortada buluş (güven düşer) / teklifi geri çek (aday gider) | [A4 6][V] satıcı kaynağı | İmzadan önce gelir; gizli gider değil [A4 ders 11] |
| 12 | 2 | Seçtiğin aday mevcut işinde ihbar süresi olduğunu ve ancak altı hafta sonra başlayabileceğini yazdı. | The candidate you picked has a notice period at their current job and can only start in six weeks. | Bekle (koltuk boş) / araya serbest çalışan / yarı zamanlı erken başlat (aday sürtüşür) | [A4 6][V] | E |
| 13 | 2 | İlk çalışanın yedinci haftasında hâlâ beklediğin hızda değil ve iki aylık deneme süresi gelecek hafta bitiyor. | Seven weeks in, your first hire still isn't at the pace you expected, and the two month trial ends next week. | Deneme bitmeden ayrıl (itibar küçük düşer) / dört hafta koçluk (kurucu saati) / devam (bir yıl dolunca kıdem) | [A4 6][A4 7][A4 13] | E |
| 14 | 2 | Eski bir arkadaşın işsiz kaldığını ve yanında çalışmak istediğini yazdı, ama kasada bir maaşa daha yer yok. | An old friend lost their job and wants to work with you, but there's no room for another salary. | Hayır de (ilişki) / proje işi ver / işe al (runway kısalır) | [A4 10] | E |
| 15 | 2 | İlk çalışanın zam yerine şirketten küçük bir pay istiyor, oysa bir hisse planın bile yok. | Your first hire wants a small stake instead of a raise, and you don't even have an equity plan. | Avukatla opsiyon havuzu (seed'de seyrelme satırı) / zam ver / reddet (istifa ihtimali) | [A4 12][A4 14] | E |
| 16 | 2 | Fonlu bir rakip uzaktaki geliştiricine yüzde yirmi fazla maaş teklif etmiş, o da sana açıkça söyledi. | A funded rival offered your remote developer twenty percent more, and they told you straight out. | Karşı teklif / unvan ya da pay / gitmesine izin ver (koltuk boşalır) | [A3 14][A3 ders 1] | Rakip hamlesi (§5) |
| 17 | 3 | İş hanının sahibi, şirketin geçmişi kısa olduğu için ya üç aylık depozito ya da senin kişisel kefaletini istiyor. | The landlord wants either three months' deposit or your personal guarantee, since the company has no track record. | Depozito (nakit kilitlenir) / kefil ol (iflas sonunun metni değişir) / paylaşımlı ofis (az masa) | [A4 21]; depozito oranı kaynaksız [V] | Kilitli nakit fiili gerekir |
| 18 | 3 | Muhasebecin, ev sahibi bir şahıs olduğu için kiranın beşte birini senin kesip vergi dairesine yatırman gerektiğini söyledi. | Your accountant says that because the landlord is an individual, you must withhold a fifth of the rent and pay it to the tax office. | Muhasebeci tut (aylık) / kendin öğren (kurucu saati) / boş ver (sonra ceza kartı) | [A4 8][V] satıcı kaynağı | E |
| 19 | 3 | Kira sözleşmesinin son sayfasında ortak giderler ve çatı tadilatının payı kiracıya yazılmış. | The last page of the lease puts shared costs and part of the roof repair on the tenant. | Tavan için pazarlık (taşınma bir hafta kayar) / kabul (aylık) / başka bina | [A4 21] | E |
| 20 | 3 | Büyük müşterinin satın alma ekibi, sorumluluk sigortası belgesi gelmeden tedarikçi kaydını açmayacağını yazdı. | The big customer's procurement team won't open your vendor account until they see a liability insurance certificate. | Poliçe al (yıllık) / limitte pazarlık (iki hafta) / vazgeç (hesap kaybı) | [A4 20] ticari kaynak | U |
| 21 | 3 | İlk büyük faturanın vadesi altmış gün ve ay sonunda kasan maaşları ancak karşılıyor. | Your first big invoice is due in sixty days, and at month end your cash barely covers payroll. | Otuz gün iste / faturayı faktoringe sat (küçük yüzde) / kabul et (runway kısalır) | [A4 19] | Vadeli tahsilat fiili gerekir |
| 22 | 3 | Yatırımcının avukatı, ilk sürümü yazan serbest geliştiricinin kodu şirkete devreden bir imzası olmadığını buldu. | The investor's lawyer found that the freelancer who wrote your first version never signed the code over to the company. | Devir imzası için öde / modülü yeniden yaz (üç hafta) / yatırımcıya açıkla (tur gecikir) | [A4 15][A4 14] | E |
| 23 | 3 | Pay tablosu belgelerle tutmuyor, çünkü aylar önce bir danışmana sözlü olarak pay sözü vermiştin. | Your cap table doesn't match the paperwork, because months ago you promised an adviser a stake over coffee. | Avukatla düzelt / yatırımcıya baştan söyle / sakla (yatırımcı ilişkisi riski) | [A4 14] | E |
| 24 | 3 | Yatırımcı toplantıda evet dedi, üç haftadır sessiz ve kasanın on dört haftası kaldı. | The investor said yes in the meeting, has been silent for three weeks, and you have fourteen weeks of cash left. | İki yeni görüşme aç / ekipten maaş ertelemesi iste (moral) / bekle | [A4 11] | `funding.seed_stalled`'ın yerine geçebilir |
| 25 | 3 | İlk kez birini işten çıkarıyorsun ve o nedenini sorduğunda elinde yazılı tek bir not yok. | You are letting someone go for the first time, and when they ask why, you have nothing in writing. | Bir aylık ayrılık paketi ve belge / yazılı uyarı ve dört haftalık plan / ertele (ekip morali) | [A4 13] | E |

Görüş: 25 tohumun 13'ü bugünkü fiillerle yazılır (tek seferlik bedel, moral, bayrak); 5'i C'nin ya da motorun yeni
fiillerini bekler (aylık gider, vadeli tahsilat, kilitli nakit) [A4 ders 9].

### 7.4 Satış ve VC görüşmeleri: derinleşme ve tekrarsızlık ilkeleri
- Bugün: satış görüşmesi en kötü cevapla %98 kazanılıyor; VC 10 tohumda 9 imza, masada 0 zorlama [A5 §8 madde 8][EK §5].
1. **Görüşme oyuncunun durumunu okur.** Ürünün en zayıf alanı, verilmiş ve tutulmuş sözler, sektör vurgusu, rakibin
   adı. Q bunun bir kısmını veriyor: imza kapısı ve VC sorgusunun en zayıf alanı okuması [A5 §1 satır 15].
2. **Kaybetmek mümkündür ve nedeni tek cümledir.** Başlarda satışta kaybetmek normaldir; neden hep yazılır [OH §2.1 satır 5].
3. **Satır koşuda bir kez.** "En uzun süredir söylenmemiş" seçimi [A5 §1 satır 15]; havuz o kadar büyük ki oyuncu bir
   koşuda yarısından azını görür [AI #12].
4. **Şıklar farklı yere varır.** Aynı sonuca giden iki cevap bir cevaptır [A1 36].
5. **Matris.** Arketip × sektör × basamak: aynı arketip seed öncesinde fiyatı, Series A'da güvenliği sorar.
6. **VC'nin kişiliği ve hafızası.** VC başına ilişki hafızası ve kalıcı kapanma zaten var [A5 §1 satır 6]; ret bir sonraki
   görüşmeyi değiştirir; seed masası en az bir zorlama içerir.
7. **Görüşme oyuncunun açtığı iştir, kesinti değildir** [OH §1.1]. Tekrarlayan etkileşim otomatik pilota döner [A4 44].

### 7.5 Geç oyunda yazı nasıl büyür
- **Yöneticinin raporu karar kuyruğudur, sayı listesi değil.** Yönetici kural dışı durumu getirir, kurucu karar verir;
  otomasyon kararı silmez, yukarı taşır [A1 ders 4].
- **Kurul.** Çeyreklik toplantı: hedef, güven, ültimatom [A2 43][A2 44]; eşik keyfî görünmesin [A2 101].
- **Diplomasi benzeri katman.** Kişiler ağı: kurul üyesi, yönetici, büyük müşteri, rakip CEO, düzenleyici; her birinin
  hafızası var. Her hamle görünür bir sonucu değiştirir [A1 ders 6]. Suzerain'in kanıtı: metin yoğunluğu yalnız yazı
  kalitesi yüksekse taşınır [A4 45]. Altyapı: VC hafızası ve tipten bağımsız pazarlık masası [A5 §1 satır 6].
- **Arklar.** Bugün GDD'nin dokuz arkından biri gerçek [A5 §0 madde 7]. Geç oyunun anlatısı arkla kurulur: sıralı,
  her adımı biraz daha ağır kararlar [A4 34][A4 35].
- Görüş, kaynaksız örnekler: "Satış liderin çeyreği tutturmak için iki hesaba yazısız indirim sözü verdiğini raporunda
  söylüyor." · "Kurul üyelerinden biri halka arzı öne çekmek, öbürü ikinci ürünü beklemek istiyor."

---

## 8. Demo

### 8.1 Kapsam ve bitiş
- Basamak 1, 2 ve 3; dördüncünün kapısı aralanır. B2B ve B2C ikisi de demoda (Erdem) [EK karar notu].
- Biter: Series A davetinin geldiği anda [EK §7.3][EK K2]. Formalite olan Series A kararı demoda görünmez; seed doruğu
  kalır ve elden geçirilmesi demo işidir. Bugün demo tanımı dört yerde dört biçim [A5 §5.5]; tek satır olmalı (K6).

### 8.2 Vaadi nasıl hissettirir
1. Demo içinde ana fiil iki kez değişir: tek başına kart ve görüşme (basamak 1), işe alım ve uzaktan ekip (basamak 2), plan
   devri ve çeyrek hedefi (basamak 3).
2. Orta nokta: planlamayı PM'e devretme töreni. Plan ekranı "önce ve sonra"yı gösterir: kurucunun tıkı azalır, kararı
   değişir [A2 ders 9].
3. Son dakika, kapıyı aralamak: Series A davetiyle birlikte baş yatırımcının mektubu gelir; kurul şartlarını (basamak 4'ün
   hedefleri) ve Plaza'daki departman odalarını kilitli ama görünür biçimde gösterir. Sonra bitiş ekranı ve wishlist
   istemi [EK §7.3].
- Kanıt sınırı: bir demonun "oyun sonra değişiyor" vaadini sattığı kanıtlı örnek bulunamadı [A1 Soru 5]. Next Fest
  gözleminde demolar uzun yatay dilim (yazarın oynadığı 10 demo); idle türü ilk 50'de yok [V]. Görüş: demo her basamaktan
  bir tat veren yatay dilim olur [A1 ders 11].

### 8.3 Süre
- Hedef 45 ile 75 dk [hedef önerisi]. Bot Series A kapısına 21 ile 27 dk saf saatte varıyor; insan kararlarla bunu uzatır
  [A5 §7]. CLAUDE.md 60 ile 90, el kitabı 40 ile 60 diyor [A5 §5.5][EK §7.3].
- Ölçüt: kapalı playtestte bitirme oranı; oyuncuların %40'ından azı bitiriyorsa demo uzundur [EK §7.3].

### 8.4 Mağaza sayfasında vaat
- Metin merdiveni sırayla anlatır: Big Ambitions kalıbı (kredi, bina, personel, sonra yöneticiler ve merkez, sonra
  imparatorluk) [A1 1][A1 ders 12].
- Ekran görüntüsü her basamaktan bir tane: evde tek masa, uzaktan ekip ve karar kâğıdı, İş hanı ve plan, kilitli kurul
  odası [A1 ders 12][EK §1.2]. EA'da yalnız mevcut özellikler gösterilir [EK §1.1].
- Fragman (~30 sn oynanış): ev, ilk çalışanın mesajı, taşınma, PM'in planı, kurul mektubu [EK §1.5].
- Kısa açıklama taslağı:
  - TR: "Evde tek başına bir yazılım şirketi kur. İlk müşterini kendin kazan, ilk çalışanını uzaktan al, sonra planı
    devret ve yatırımcının masasına otur. Şirket büyüdükçe senin işin de değişir."
  - EN: "Build a software company alone at home. Win your first customer yourself, hire your first remote developer, then
    hand off the plan and take a seat at the investor's table. As the company grows, so does your job."

---

## 9. Yol haritası

Tarih yok; sıra ve koşul var. Q, C, D sırası sürer (Q kodlanıyor). Her adım Kat 1 (ajan kapıları) ve Kat 2 (Erdem oynadı)
ile kapanır [EK §4.3].

| Adım | İş | Neden bu sırada | Çıkış ölçütü | Kapsam |
|---|---|---|---|---|
| 0 | Karar turu: §11'in altı sorusu; demo tanımı tek satır CLAUDE.md'ye; kanca cümlesi seçimi | C9 ve E1 bekliyor [PLAN_C]; kod istemez, Q sürerken yapılır | K1 ile K6 cevaplı; PLAN_C'nin C9 notu kapanır | Hepsi |
| 1 | Faz Q'nun bitişi | Kodlanıyor; imza kapısı ilk açıklanmış kaybı getirir [OH §5] | Q kapıları (U = 100 imzaların en çok %25'i, evre 2 ortancası 70 ile 85) [OH §3]; Erdem'in 10 ile 15 dk dilimi | Demo |
| 2 | Faz C, C9 yeniden yazılmış (§3.8) | Basamak 2'nin parası ve evin kuralı burada doğar | C kapıları; yeni kuralla ACIK 98 ölçümü (çek ile seed arası iflas yok); kasa üç hâlde ölçüldü; Erdem dilimi | Demo |
| 3 | Faz D | Plan devri merdivenin demodaki kanıtı | D kapıları; devir töreni ve önce/sonra satırı; Erdem dilimi | Demo |
| 4 | İlk tam insan oturumu (Erdem, hf 1 ile 60) | "Başı zor" nedenini ayırır [A5 §0 madde 5b] | Beş olumsuz tema listesinden geçildi [EK §2.2]; RAPOR_B §7 soruları kapandı [AI #17] | Hepsi |
| 5 | Öğretici ve şart hattı | Dış playtest bunsuz olmaz (Erdem); seed sonrası hedef boş [AI #6] | §4.3 akışı oynanır; TopBar Sıradaki hiç boş değil; harfiyen bot batmaz; rehber susturulur ve geri gelir; saat ayarı [AI #4] | Demo |
| 6 | Erken oyun dengesi | Kasa, B2C seed ve kira penceresi ancak C ve D'den sonra ölçülür | Kasa kararı; B2C seed hf 35 ile 45 [hedef önerisi]; zorluk kadranı en az üç basamak [AI #14][OH §6 madde 7] | Demo |
| 7 | Olay yazımı dalga 1: basamak 1 ile 3'ün ilk kez kartları | Vaadin içerik ekseni [A4 ders 1]; uzaktan işe alım kartsız gelmesin | §7.3'ten en az 20 kart, rubrik eşiğini geçmiş; her basamakta en az 8 seçenekli ilk kez kartı; havuzun yarısından azı koşuda görünür [AI #12]; B2C'de kartsız seri en çok 4 hafta [AI #1][OH §3] | Demo |
| 8 | Satış ve VC görüşmeleri, seed doruğu, kayıp ekranı | Seed demoda; formalite doruk ve %98 kazanç vaadi zayıflatır | En kötü cevap kazanmaz; seed masasında zorlama; ret sonrası adlı hedef; "ne öldürdü" ve tek tık Tekrar Dene [AI #2][AI #5][AI #7] | Demo |
| 9 | Pazarlama v1 (B2C ağırlıklı, küçük), B2C fiyat kolu (Faz E), Ar-Ge bağlama | Para baskısı ve B2C orta oyunu [AI #3]; Ar-Ge'nin boş yeri [AI #10] | Traction'da runway en az bir kez 4 ayın altında [OH §3 Risk 2]; okuyucusuz Ar-Ge düğümü sıfır; pazarlama kararı iki bot politikasında farklı sonuç | Demo |
| 10 | Rakip I2 ve kapanan rakip arkı | Rakip oyuncuya cevap vermeli [A3 ders 1] | Her lig rakibi koşuda en az bir kez oyuncunun kararına cevap verir | Demo |
| 11 | Cila: huylar [AI #8], yıl sonu gazetesi (ödül anı), ses ve vitrin [AI #15], yapay zekâ beyanı [AI #16] | Vitrin sayfadan önce gelir [EK §1.5] | Huy etkisi okunur; gazete yıl sonunda ürünün yerini yazar; SFX var | Demo |
| 12 | Kimlik kilidi, Steam sayfası, kapalı playtest, herkese açık demo, Next Fest | EK §7.1'in 3 ile 7. aşamaları | EK'in ölçütleri (bitirme oranı, demo ile wishlist dönüşümü %15 ile 25) [EK §7.1] | Demo |
| Sonra | EA: basamak 4. Tam oyun: basamak 5 | §1.4 kural 3: önceki basamak derin olmadan yenisi açılmaz | Basamak kapısı §2.8 | EA, tam |

### 9.1 ACIK_ISLER'in yeri (madde → adım)
- #1 B2C kart sayısı → 7 ve 9 · #2 satış görüşmesi → 8 · #3 para baskısı → 6 ve 9 · #4 saat elle başlıyor → 5
- #5 seed ve Series A doruğu → 8 (Series A doruğu EA'da) · #6 seed sonrası hedef, görev, rakip → 5 ve 10 · #7 kayıp ekranı → 8
- #8 huylar → 11 · #9 kilitli kökenler → iş yok, kalır · #10 Ar-Ge düğümleri → 9 · #11 ERP modülleri → 9'da tek modül, çoğu EA
- #12 kâğıt havuzu → 7 · #13 çok sprintlik işler → EA · #14 zorluk kadranı → 6 · #15 vitrin → 11
- #16 yapay zekâ beyanı → 11 (karar adım 0'da da verilebilir) · #17 RAPOR_B §7 soruları → 4

### 9.2 Next Fest ile ilişki
- El kitabının önerisi Haziran 2027 (kayıt 25 Nisan 2027, fest 14 ile 21 Haziran); Şubat 2027 Q, C, D, playtest ve kimlik
  kilidine sığmıyor [EK §7.2][EK K1].
- Bu yol haritasıyla koşul: adım 1 ile 11 bitmiş ve adım 12'nin kapalı playtesti fest kaydından önce kapanmış olmalı;
  demo festten aylar önce açık olmalı (medyanda ~2,5 kat wishlist) [EK §7]. Tutmazsa sonraki fest; hak tek [EK §1.4].
- Görüş: sayfa (Coming Soon) kimlik kilidi biter bitmez açılabilir; demoyu beklemesi gerekmez, wishlist birikir [EK §7.2].

### 9.3 EA'ya ve sonraya kalanlar
- EA (basamak 4): Series A'nın geçiş olması, Plaza'da departmanlar ve liderler, kurul hedefleri ve güven, pazarlama
  departmanı, ikinci ürün (Ürün GDD §17 slotu) [A5 §4], hisse alımı, küçük rakip alımı, ERP modülleri, çok sprintlik işler,
  zaman modelinin kabalaşması, EA takımı (gerekirse) [OH §2.2 İtiraz 3].
- Tam oyun (basamak 5): Series B, halka arz, lobi ve diplomasi benzeri katman, ürün döngüsünün devri, makro ekonomi,
  kurucunun serveti [A5 §4].

---

## 10. Q, C, D'ye etkisi

| Faz | Madde | Değişiklik | Oturuma tek satırlık not |
|---|---|---|---|
| Q | Tümü | Yok | "ANA_RESIM Q'dan değişiklik istemez; imza kapısının kayıp cümlesi demonun ilk açıklanmış kaybıdır, kapsamdan düşmesin." |
| C | C9 | Ev kapasitesi 3; kira taşınmayla; İş hanı şartı runway; uzaktakiler ofise gelir; bot 3. işe alımda taşınır | "C9 §3.8'e göre yeniden yazılır; Ev 1 masa ve 2 uzaktan koltuk, ilk çalışan taşınma değildir [onay bekliyor]." |
| C | Bootstrap runway kapısı (6,7 ay) | MVP öncesi gider sıfır olunca anlamsız [A5 §5.3] | "Bootstrap kapısı yerine 'ilk uzaktan çalışanla gelirsiz runway' ölçülür; C0s kasayı $10.000, $25.000, $50.000 ile koşar." |
| C | Gider listesi | Olayın doğurduğu aylık gider (cihaz payı, internet yardımı) adıyla görünür | "Aylık sürekli gider fiili C'nin gider evinde kurulur ya da adım 7'ye kalır; karar E1'de [onay bekliyor]." |
| C | Frank kartları | `hire_nudge` aynen; `funding.frank_office_move` çekten sonra değil üçüncü işe alım isteğinde ya da seed'den sonra | "Frank'in ofis kartının tetiği taşınma şartına bağlanır, çeke değil." |
| C | E1 | İş hanı şartı sorusu bu belgeyle cevaplanır | "E1'deki İş hanı maddesi K2'nin cevabıyla kapanır." |
| D | Planlamayı devret | Tören: ilk devirde Frank'in tek satırı, plan ekranında önce ve sonra; geri almanın bedeli var | "Devir bir kilometre taşıdır; ilk devir duyurulur, geri alınabilir, bedeli bir sprintlik hazırlık [onay bekliyor]." |
| D | Model | Uzaktan çalışan ofistekiyle aynı sayılır; verim cezası yok | "D modelinde uzaktan çalışana gizli çarpan yok." |
| D | Çeyrek hedefi | PM'siz açık (Erdem 18 Ekim, uyumlu) [A5 §1 satır 3] | "Değişiklik yok." |

---

## 11. Karar soruları

**K1. Evde uzaktan ilk ekip: Ev'in kapasitesi 3 (kurucu ve 2 uzaktan çalışan) olsun, C9 buna göre yeniden yazılsın mı?**
Öneri: Evet (§3.2, §3.8).
Oynanışa etkisi: Basamak 2 birinci saatin içine girer; ilk para kararı kira değil maaş olur; uzaktan çalışma olay kümesi
açılır; ACIK 98'in iflas penceresine kira binmez.
Satışa etkisi: Vaadin ilk kanıtı demonun ilk yarım saatine girer; "çalışan iş bilgisayarı istiyor" anı anlatılabilir ve
paylaşılabilir bir an.

**K2. İş hanı şartı: Frank çeki kalksın, yerine "taşındıktan sonra kasa en az 3 aylık gideri karşılar" gelsin; ofis
seed'e bağlanmasın mı?**
Öneri: Evet (§3.4).
Oynanışa etkisi: Erken taşınmak görünür bir risk kararı olur (Game Dev Tycoon kalıbı) [A3 63][A3 64]; B2C oyuncusu seed'i
bir yıl beklemeden ofise geçebilir.
Satışa etkisi: Dolaylı; "ofise taşındım" merdivenin ekran görüntüsüne giren görünür basamağıdır.

**K3. Başlangıç kasası: Normal $25.000 olsun (zorluk çarpanları aynı), son sayı C0s ölçümü ve bir insan oturumundan sonra
kesinleşsin mi?**
Öneri: Evet (§3.6). $50.000 doğrudan konmaz; ilk işe alım anında kasa ve Frank'in çeki zaten $50.000 eder.
Oynanışa etkisi: Tek uzaktan çalışan gelirsiz yaklaşık 6 ay yaşar; erken işe alım risklidir ama ölümcül değildir; Frank'in
çeki anlamını korur.
Satışa etkisi: Software Inc. olumsuzlarının %24'ü öğretici, %9'u iflas ya da kredi [A3 1]; bir oyuncu 1,1 saatte iade etti [A2 63].

**K4. Görev sistemi iki hat olsun mu: bağlayıcı şart hattı (Frank, seed, kurul, yöneticiler) ve isteğe bağlı, susturulan
Frank rehberi? Rakip PRD'nin "görev yok, hiçbir zaman" metni buna göre güncellensin mi?**
Öneri: Evet (§4.2).
Oynanışa etkisi: Hedef hiç boş kalmaz; öğretici zorunlu değildir; bilen oyuncu rehberi kapatır.
Satışa etkisi: İlk saat ve öğretici türün beş olumsuz temasından biri [EK §2.2]; Big Ambitions'ın isteğe bağlı akıl hocası
%91 olumlu bir oyunda [A2 1] (neden sonuç kanıtı değil, emsal).

**K5. Merdiven ve kapsam: demo basamak 1 ile 3 ve 4'ün kapısı, EA basamak 4, tam oyun basamak 5 olsun; Series A EA'da son
değil geçiş olsun mu?**
Öneri: Evet (§2, §9.3).
Oynanışa etkisi: Yirminci saat ilk kez tasarlanır; her basamak §2.8 kapısını geçmeden yenisi açılmaz.
Satışa etkisi: Vaat dürüst anlatılır; Steam sayfası yalnız mevcut özellikleri gösterir [EK §1.1]; EA güncellemeleriyle
büyüyen emsal Big Ambitions [EK §2.1].

**K6. Demo tanımı tek satır olsun mu: "Demo Bootstrap'tan başlar, B2B ve B2C, Series A davetiyle ve kurul mektubunun
açtığı kapıyla biter; hedef 45 ile 75 dk"? CLAUDE.md §1 buna göre değişsin mi?**
Öneri: Evet (§8).
Oynanışa etkisi: Formalite olan Series A kararı demoda görünmez; vaat son dakikada görünür.
Satışa etkisi: Gerilim noktasında kesen demo ve bitiş ekranındaki wishlist istemi [EK §7.3]; demo süresi bitirme oranıyla
ayarlanır.

---

## Ek: kaynak dizini

| Etiket | Dosya | Konu | Arama / kaynak |
|---|---|---|---|
| A1 | `docs/strateji/arastirma/A1_mikro_makro.md` | Birinci saat ile yirminci saatin farklı olduğu oyunlar | 13 / 46 |
| A2 | `docs/strateji/arastirma/A2_gorev_ogretici.md` | Yönetim oyunlarında öğretici ve görev | 11 / 109 |
| A3 | `docs/strateji/arastirma/A3_rakip_pazarlama_para.md` | Rakip, pazarlama, ofis, para | 9 / 82 |
| A4 | `docs/strateji/arastirma/A4_kurucu_gercekleri.md` | İlk kez kurucunun sürprizleri, olay tasarımı | 12 / 50 |
| A5 | `docs/strateji/arastirma/A5_bizde_ne_var.md` | İç inceleme: GDD, kod, açık işler | 0 / 45 |
| V | `docs/strateji/arastirma/A_V_denetim.md` | Denetim: 33 iddia, 25 doğrulandı, 7 düzeltildi, 1 doğrulanamadı | |
| EK | `docs/strateji/EL_KITABI.md` | Steam, emsaller, üretim ve ajan düzeni, Next Fest | |
| OH | `docs/tasks/faz_cde/OYNANIS_HUKMU.md` | Q, C, D oynanış hükmü | |
| AI | `docs/tasks/faz_cde/ACIK_ISLER.md` | Q, C, D dışındaki açık işler | |
| PRD_C | `docs/tasks/faz_cde/PRD_FAZ_C_URUN_HESAP.md` | Faz C kararları (ofis kirası, masa tavanı) | |
| PLAN_C | `docs/tasks/faz_cde/c_taslak/PLAN_C.md` | Faz C adımları, C9'un askı notu | |

Denetimin düzelttiği ve burada düzeltilmiş kullanılanlar: Next Fest okuması, Founder Sim, öğreticiyi izleyip batma [V].
Doğrulanamayan GitLab ödeneği hiçbir öneriye dayanak yapılmadı [V].
