# Kol 1: Paradox büyük strateji oyunlarında zamanla değişen, nedenlerine ayrılmış değerler

Erişim tarihi (tüm kaynaklar): 2026-11-18. Tasarım önerisi yoktur; olgu, sayı, ekran yapısı, şikâyet.

## 0. Okuma notları (önce bunlar)

- **WebSearch**: 22 çağrının 22'si kullanıldı (hepsi "standard"). Kota hatası yok. WebFetch ile sürdürüldü.
- **Wiki sayfaları nasıl okundu**: WebFetch sayfayı küçük bir model üzerinden özetletiyor. Sayılar wiki'nin kendi tablolarından geliyor ama çıkarma hatası olasılığı var. Bu yüzden her wiki olgusunun yanına wiki'nin kendi "doğrulandığı yama" notunu yazdım. Birçok EU4 bölümü "potentially outdated" bayrağı taşıyor (aşağıda belirtildi). Güncel EU4 yaması sayfaların doğruladığı 1.25–1.30'dan yeni olabilir; sayıları oyunda yeniden denemek gerekir.
- **Forum, Reddit ve Steam sayfaları açılamadı**: forum.paradoxplaza.com ve admin-forum "Validating browser" ekranı veya HTTP 500 verdi; Reddit yansıları TLS hatası verdi; Steam tartışmaları yaş kapısında kaldı; Overclockers 403 verdi. Bu yüzden oyuncu şikâyeti alıntılarının **tamamı arama sonucu özetinden** alındı (özet tırnak içinde aktarıyor); sayfa kendisi açılmadı. Bunları "Düşük" güvenle işaretledim ve her alıntının yanına "arama özeti" yazdım. Yazar adı ve tam tarih çoğunda bilinmiyor.
- **Harfi harfine tam ipucu (ekran görüntüsü) bulunamadı.** Hiçbir sayfa metin olarak tam bir EU4/CK3 ipucu dökümü vermiyor; wiki'ler ipucunu görsel olarak gösteriyor ve metne çevirmiyor. Bölüm 2'de üç ipucunun satır yapısını kaynaklı parçalarla veriyorum, tam satır dizisini ise "(model bilgisi, kaynak açılmadı)" etiketiyle ayrı bir blokta yeniden kurdum. Bu blok doğrulanmadı; oyunu açıp ekran görüntüsü almak gerekiyor.
- **Sahibin iki varsayımı düzeltildi**: (a) Imperator: Rome'da "mana" (Monarch Power) 2.0'da değil **1.2 (Cicero, Eylül 2019)** ile kaldırıldı; yerine Political Influence geldi ve 2.0 wiki'sinde hâlâ duruyor (Bölüm 3.2). (b) CK3 Legitimacy, aramaların gösterdiğine göre Legends of the Dead'in ücretli parçası değil; ücretsiz güncellemeyle geldi, DLC yalnız ek kaynak (Legend etkinlikleri) ekliyor (Bölüm 1.2).
- Aşağıda `(hesaplama)` işareti benim aritmetiğim demektir; kaynaktaki sayılardan türetildi.

---

## 1. Değer değer döküm

### 1.1 EUROPA UNIVERSALIS IV

#### 1.1.1 Gelir/gider dökümü (Economy paneli, "monthly balance")

- **Ne ölçer**: aylık para akışı. Geliştirici günlüğü (EU4 Dev Diary 4) yıllık ve aylık bütçeyi bırakıp tek aylık akışa geçtiğini söylüyor: "Treasury" harcanabilir parayı ve varsa fazlayı gösterir (arama özeti, günlüğün kendisi açılamadı) [S29]. GamePressure rehberinin ekran altı yazısı: "The budget boils down to the monthly balance only." [S29]
- **Ölçek ve gösterim**: Economy sekmesi iki sütun. Sol sütun gelir akışları ve değiştiricileri, gri orta sütun verimlilik (efficiency); sağ sütun giderler. Giderler iki türlü: otomatik düşülenler ("automatically deducted from the treasury", panelden değiştirilemez; tek istisna Interest, Loans arayüzünden) ve sürgülü ayarlanabilirler (adjustable, "shown with sliders") [S4].
- **Girdiler ve sıklık**: aylık. Hazine her ay "toplam gelir eksi önceki ayın gideri" kadar değişir [S4]. Geliştirici günlüğü gelir kategorilerini sayıyor: ticaret düğümlerindeki tüccarlardan gelir, altın madenleri (enflasyonu etkilediği için ayrı izlenir), denizaşırı eyalet ve koloni tarifeleri, geçici gelir (kredi, olay, hediye) [S29, arama özeti].
- **Erime/taban**: yok; bir akış, sayaç değil.
- **Neyi etkiler**: hazine, borç (hazine 0'a inince otomatik kredi: GamePressure) [S29].
- **Döküm nasıl gösterilir**: gelir satırına gelince ipucu "modifiers or a breakdown of income by province" gösterir [S4]. Danışman (Advisors) gider satırının ipucu "other modifiers, including Inflation" listeler [S4]. Diplomatic Expenses ipucu şu kalemleri (wiki'nin listeleme sırası, oyun içi görünme sırası olduğu doğrulanmadı) sayar: Our Cities Looted / Our Ports Blockaded (yalnız geçerliyse), Subsidies, Vassal fee, Outgoing tariffs (koloni ulusları), War reparations, Support loyalists, Send officers, Knowledge sharing, Condottieri fees [S4]. Wiki bir "Balance" satırı tarif etmiyor; toplam satırının yeri ve renkleri **bulunamadı**.
- **Kaldıraç ve bedel**: giderlerde sürgüler; kredi; enflasyon.
- **Başta/sonda**: bulunamadı (model bilgisi: küçük ülkede birkaç kalem, büyükte onlarca; kaynak açılmadı).
- Wiki sürüm notu: Overview/Income/Loans/Inflation 1.24, Expenses 1.28, Debase/Bankruptcy 1.29 [S4].

#### 1.1.2 Prestige

- **Ne ölçer**: ulusun saygınlığı; hem istatistik taşıyıcı hem harcanabilir para birimi [S1].
- **Ölçek ve gösterim**: −100…+100; 0'da etki yok; etkiler doğrusal, −100'de aynı etkilerin tersi. Wiki etkileri "icon + kalın değer + bağlantılı ad" biçiminde sıralıyor; oyun dosyası kaynağı `common/static_modifiers/00_static_modifiers.txt` [S1].
- **Girdiler (yıllık)**: +1 yıllık: Philosopher danışmanı, Defender of the Faith, curia controller, Holy Roman Emperor; +0.5: kürk ticareti, kutsal eyalet; güç projeksiyonu başına +0.005 (tavan +0.5) [S1]. Savaş: kara/deniz muharebelerinden ödül, başarılı barış anlaşması, keşif, koloni büyümesi. Kayıp: yıllık −0.1 her başka ulusun elindeki çekirdek eyalet için; −2 aforoz; tek seferlik: muharebe kaybı, olumsuz barış, çağrıya uymamak (genelde −25), din değiştirmek (−100), veliaht reddi (−50) [S1].
- **Erime**: "base decay of 5% prestige per year", mutlak değerin yüzdesi; sıfıra doğru. İndirimler: Patron of the Arts ve bazı gelenek/fikirler −1%; Great Power −1%; bazı olaylar −2% [S1]. Yıllık +1'lik bir kaynağın dengesi: wiki "yıllık ±1 başına denge ±20" diyor (±25 Patron of the Arts ile) [S1]; bu 1/0,05 = 20 ile tutarlı (hesaplama).
- **Neyi etkiler (100'de)**: küresel ticaret gücü +15%, ordu ve donanma morali +10%, yabancı casus tespiti +10%, yıllık legitimacy +1, Improve relations +50%, aylık fervor +1%, aggressive expansion etkisi −10%, kurum benimseme maliyeti −10%, veliaht talep artışı +0.05/ay; çeşitli estate sadakatleri +5% [S1]. Wiki: "At −100 prestige a country has the reverse of these benefits as penalties." [S1]
- **Harcama (kaldıraç ve bedel)**: Placate local rulers −20 (özgürlük arzusu −%10), harita almak −15, veliaht dışlamak/tahttan çekilmek −50, yerel veliaht desteği −10 [S1].
- **Başta/sonda**: küçük ulusta ana kaynaklar muharebe ve barış; büyükte Great Power erime indirimi ve HRE gibi sabit kaynaklar (kısmen S1; "başta/sonda" yorumu model bilgisi, kaynak açılmadı).
- **Oyuncu notu**: eski bir rehber (EU4 1.2x öncesi) güç projeksiyonu etkilerini "Morale of Armies +0,5" ve "+1 legitimacy, per annum" diye yazıyor; wiki sayısı bugün +10% [S29 vs S1]. Etki sayıları yamalar arasında kaymış.
- Wiki sürüm notu: 1.26; "Increasing/Losing" bölümleri "potentially outdated"; son düzenleme 2025-09-22 [S1].

#### 1.1.3 Stability

- **Ne ölçer**: ulusun iç düzeni; sıçramalı düzey (tam sayı) [S2].
- **Ölçek**: üst sınır +3 ("cannot go higher than 3"); −3'te savaş ilanı mümkün değil [S2]. Eski rehber ölçeği −3…+3 diye veriyor [S29].
- **Girdiler (maliyet)**: yükseltme bedeli taban 100 yönetim puanı (en az 10); ek yüzdeler: pozitif düzey başına +%50, sows discontent +%50, +Overextension/2 %, +(100 − dini birlik)%, +2×(100 − cumhuriyet geleneği)%, naiplikte +%25, felakette artış [S2]. Düşüş sebepleri wiki'de **listelenmiyor**; yalnız bunun olay ve ölümle olabileceğini eski rehber söylüyor ("the game has the tendency for quick decreasing of maximum stability") [S2, S29].
- **Erime**: yok (kendiliğinden eriyen bir sayaç değil; yükseltilen yerde durur).
- **Neyi etkiler (düzey başına, pozitif)**: ulusal huzursuzluk −1, küresel ticaret gücü +1%, vergi +5%, kurum yayılımı +5%, yıllık yolsuzluk −0.02, yıllık devotion +0.5, aylık fervor +1%, casus tespiti +5%; negatif düzeyde: ulusal huzursuzluk +2, yıllık legitimacy −1, faiz +%1, ticaret gücü −1%, yıllık devotion −1 [S2].
- **Döküm**: wiki ipucu metni vermiyor [S2].
- **Kaldıraç ve bedel**: yönetim puanı (yukarıdaki formül); bedel ölçekle artıyor (Overextension ve dini birlik terimleri) [S2].
- **Başta/sonda**: bulunamadı. Forum şikâyeti Bölüm 3'te.
- Wiki sürüm notu: çoğu bölüm 1.25; Effects ve cost "potentially outdated"; sayfa son düzenleme 2026-08-28 [S2].

#### 1.1.4 Legitimacy ve muadilleri (republican tradition, devotion, horde unity)

**Legitimacy (monarşi)** [S3]
- **Ölçek**: 0–100; etkiler doğrusal; 0 / 50 / 100: ulusal huzursuzluk +2 / 0 / −2, dini hoşgörü −1 / 0 / +1, diplomatik itibar −1 / 0 / +1, tabi gelirinden pay −5% / 0 / +5%, maksimum absolutism −10 / 0 / +10.
- **Yıllık girdiler**: +0.1 kraliyet evliliği başına; +1 Righteous ruler; +1 Lucky nation; −2 naiplik; +1 meşruti monarşi; −1 negatif düzey başına (en çok −3); güç projeksiyonu başına +0.005; Sow Discontent hedefi −1; prestige doğrusal: −100'de −1, +100'de +1. Etkin harcama: Strengthen Government 100 askeri puanla +10.
- **Erime**: yok; yıllık toplam akış.
- **Sürüm**: legitimacy bölümü 1.27 ("potentially outdated"); wiki sayfası "Monarchy" sayfasının parçası.

**Republican tradition** [S12]: 0–100; yeni cumhuriyet 100'de başlar; yıllık taban +1 + fikir/gelenek eklemeleri; erime yok, kayıplar eylemle (aynı hükümdarı yeniden seçmek seçim döngüsü başına −2.5; akrabayı seçmek −1); etkiler: huzursuzluk 0 / −1 / −2, reform ilerleme büyümesi 0 / +%50 / +%100, stability maliyet çarpanı +%200 / +%100 / 0 (0 / 50 / 100'de). Eşikler: 40 altında hükümdar yeni hükümet türü ilan edebilir; 20 altında olay kayması [S12]. Sürüm 1.30.

**Devotion (teokrasi)** [S14]: 0–100 ima; başlangıç değeri dini birliğe eşit; yıllık: taban −0.5; +1 dindar hükümdar; +0.5 pozitif stability başına; −1 negatif stability başına; −5 aforoz. 0 / 50 / 100: vergi −25% / 0 / +25%, yıllık prestige −1 / 0 / +1, kilise gücü −25% / 0 / +25%. Sürüm 1.23, "outdated". Wiki 50'ye doğru erimeyi anmıyor.

**Horde unity (Cossacks DLC)** [S13]: 0–100; yıllık taban −2; toplam gelişmişlik −0.01 / 2 gelişmişlik (−3'e kadar); yağma +1 / 4 duka; yıkım +1 / 2 gelişmişlik; revanşizm +0.1 / puan; 100 askeri puan harcamak +10. Etkiler 0 / 50 / 100: huzursuzluk +2 / 0 / −2, disiplin −5% / 0 / +5%. Veliaht değişiminde 50 altında ise veraset krizi.

- **Hepsi için ortak yapı (hesaplama)**: dört sayacın hepsi (legitimacy, republican tradition, devotion, horde unity) 0–100 aralıklı, doğrusal etkili ve **yıllık** toplanan akışlıdır; hiçbirinde prestige gibi yüzde erime yok [S3, S12, S13, S14]. Horde unity'nin taban −2'si bir tür sabit erime.
- **Başta/sonda**: bulunamadı.

#### 1.1.5 Power Projection ve Army Tradition

**Power projection** [S5]
- **Ne ölçer**: rakiplere karşı saldırgan hareketin ödüllendirilmesi ("a mechanic which rewards nations for acting aggressively towards their Rivals").
- **Ölçek**: 0–100.
- **Girdiler**: uzun süreli rakip +1/yıl (rakip başına en çok +5); savaş ilanı +10 (en çok +20); rakipten eyalet almak +0.5 gelişmişlik başına (en çok +100); Great Power +10…+25; Hegemon +25; çağ hedefi +3; rakiple ilgili hakaret +5/+10; boş rakip yuvası −1/yıl (yuva başına −20'ye kadar); çağrıya uymamak −20; rakibe eyalet kaybı −0.5 gelişmişlik başına.
- **Erime**: olay kaynaklı değiştiriciler yılda 1 puan eriyor; her rakip için ayrı izlenir; sabit etkiler iptal edilene kadar sürer; üst sınırı aşan fazla kaybolur.
- **Neyi etkiler (puan başına)**: kale savunması +0.1%, küresel ticaret gücü +0.2%, yıllık prestige +0.005, ordu/donanma morali +0.1%, yıllık legitimacy +0.005, republican tradition +0.002, devotion +0.005, horde unity +0.005. Eşikler: 25'te +1 bedava lider, 50'de her puan türünden +1 aylık.
- Sürüm 1.30 (Modifiers/Effects bölümleri "potentially outdated"); düzenleme 2025-07-17.

**Army tradition** [S7]
- **Ölçek**: 0–100 (navy tradition de 0–100).
- **Erime**: "The base tradition decays at 5% of the current tradition annually." Azaltıcılar: fikirler/politikalar −0.5…−1.0%, Innovativeness en çok −1%.
- **Girdiler**: muharebe (küçük ve orta uluslar için ana kaynak): 20 × ordu kaybı × katılımcı sayısı ÷ toplam savaş-müttefik kuvvet sınırı; sıfır kayıplı yok etme +0.2; kuşatma +2; yıllık +1.00/+0.50/+0.25 fikirlerden; kale başına +1/50 gelişmişlik'e kadar.
- **Neyi etkiler (100'de)**: ordu morali +%25, manpower toparlama +%10, kuşatma +%5, lider ortalama +3.6 ateş/şok/manevra.
- **Gösterim**: muharebe sonuç ekranı kazancı gösterir; mevcut değerin arayüzde gösterimi wiki'de tarif edilmemiş.
- Sürüm 1.26.
- **Ortak ilke (hesaplama)**: ikisi de "kendiliğinden eriyen, oyuncunun eylemle yukarıda tuttuğu" değer örnekleridir: tradition yüzde 5/yıl, prestige yüzde 5/yıl, power projection yıllık −1 olay erimesi [S1, S5, S7].

#### 1.1.6 Opinion (ülkeler arası görüş)

- **Ne ölçer**: her ulusun bildiği her ulus hakkındaki sayısal görüşü; karşılıklı değil [S6].
- **Ölçek ve gösterim**: −200…+200; "Reasons for a nation's opinion of another are displayed in tooltips wherever opinion is shown. The total is capped at +200/−200." [S6]
- **Girdiler**: diplomatik eylemler, göreli güç, yakınlık, yakın savaşlar, din, casus belli, olaylar. Zamanlı örnekler: Insulted −50, yıllık +5 erime, 10 yıl; Declared War −25, yıllık +1; hediye +25, 5 yıl, yalnız son hediye sayılır; Competent/Incompetent Diplomacy ±10%, 5 yıl; Royal Marriage +25 "while in effect"; Performed a Grand Hajj +30, yıllık −3 erime [S6].
- **Erime**: "Many modifiers fade over time"; hız değiştirici türüne bağlı; Improve relations yalnız olumsuz görüşte erimeyi hızlandırır, olumlu görüş sabit hızla erir; Aggressive expansion "decays by 2 per year by default" [S6].
- **Neyi etkiler**: diplomatik eylemlerin kabul edilmesi (kabul tabloları; ör. Friendly, Hostile gibi tutumlar) [S6]; koalisyon eşiği AE üzerinden [S8].
- **Kaldıraç ve bedel**: hediye (+25), kraliyet evliliği (+25), Improve relations eylemi (diplomat süresi harcar; model bilgisi, kaynak açılmadı).
- **Başta/sonda**: bulunamadı.
- Sürüm: Attitude/Decay bölümleri 1.24; Relation modifiers 1.25; wiki düzenlemesi 2025-08-12 [S6].

#### 1.1.7 Olumsuz sayaçlar: Aggressive Expansion, Overextension, War Exhaustion, Corruption

| Sayaç | Ölçek | Girdi ve sıklık | Erime ve azaltma | Etki | Kaynak |
|---|---|---|---|---|---|
| Aggressive Expansion (AE) | alt sınır −1000 (modifier); koalisyon eşiği −50 | barış şartı, antlaşma bozma, casus belli'siz savaş; taban fethedilen gelişmişliğe bağlı (eyalet için tavan 30), şart katsayıları: eyalet talebi %60, zorla vasallaştırma %50, zorla kişisel birlik %20 | yılda 2 ("2 per year by default"), Improve relations hızlandırır | ihlalci ulusa karşı görüş düşer; −50'de en az 4 ulus koalisyon kurabilir; barış ekranı −50'yi aşan AE'yi ve koalisyona katılabilecek ülkeleri listeler | S8 |
| Overextension | sınırsız (100% üstü olur) | her çekirdeksiz eyalet = gelişmişliğin %80'i; formül: (çekirdeksiz gelişmişlik/100) × %80 × (%100 − idari verimlilik) | aylık değişim yok; çekirdekleme, eyalet satma, vasal serbest bırakma ile azalır | 100%'de: yurtdışı ticaret gücü −100%, stability maliyeti +%50, huzursuzluk +5, yıllık yolsuzluk +0.5; 100% üstünde isyan ilerlemesi 3× üstü (tavan %75), kötü olaylar yılda ~1 | S9 |
| War Exhaustion | 0–20 | aylık: abluka +0.1 (%100'de), işgal +0.5 (%100'de), yıpranma en az +0.01; savaşı stability kaybettiren eylemler tek seferlik ekler (casus belli'siz savaş +2) | aylık −0.10 barışta, −0.10 hegemon; 75 diplomatik puanla −2 (ve absolutism −1) | puan başına: huzursuzluk +1%, çekirdekleme maliyeti +3%, manpower toparlama −1%, kuşatma −1%, üretim −2%; 20'de: huzursuzluk +20%, çekirdekleme +60% | S10 |
| Corruption | 0–100 (ima) | yıllık: overextension +0.005/puan (en çok +0.5), dini birlik eksiği +0.001/puan, dengesiz araştırma en çok +0.5, Debase Currency +2 tek sefer | yıllık: stability −0.02/puan, "rooting out corruption" sürgüsü en çok −1/yıl, teknoloji öne olmak −0.05 | 100'de: tüm puan maliyetleri +%100, minimum otonomi %50, huzursuzluk −20 [wiki satırı böyle, işareti belirsiz], casus tespiti −%25 | S11 |

- Bu dört sayacın ipucu satır yapısı wiki'de tarif **edilmemiş**; sürümler: AE 1.25/1.24 (mesafe 1.31 notu), Overextension 1.29, WE 1.30, Corruption 1.27 [S8–S11].
- AE sayfasında iç çelişki: bir yerde "−50 AE" koalisyon eşiği, bir yerde "50 AE" yazıyor; wiki kendisi "verify it in-game" diyor [S8].

### 1.2 CRUSADER KINGS III

#### 1.2.1 Prestige ve Piety (ve Level of Fame / Level of Devotion)

- **Ne ölçer**: Prestige = dünyevi saygınlık ve harcanabilir para birimi; Piety = dini saygınlık [S15].
- **Birikim modeli**: harcanan ve kazanılan miktar ikiz saklanır. "Each prestige gained also grants the same amount of fame"; her piety kazancı devotion da kazandırır; piety bedeli devotion ile de ödenebilir [S15]. Yani harcanabilir değer (prestige) ve ömür boyu birikim (fame) ayrı sayaçlar.
- **Erime**: wiki prestige veya piety erimesi tarif etmiyor [S15]; fame "rarely decreases", yalnız utanç verici eylemler seviye düşürebilir [S15]. Tavsiye amaçlı oyuncu önerisi "decay" bunun tersini ister (Bölüm 3.4).
- **Girdiler**: prestige: unvanlar (üst rütbe), Diplomacy becerisi, olaylar; piety: dini ilişkiler, Learning becerisi, erdem özellikleri: Theology odağı, Head of Faith, her erdem özelliği +1.0/ay; Humble +0.5; Learning +0.1/seviye; her günah özelliği −1.0 [S15]. Birim zamanlı yüzde değiştiriciler: Pilgrim +25/+15/+5%, Zealous +%20, Cynical −%20, Excommunicated −%50 [S15]. Üçüncü taraf rehber: rütbeye göre unvan başına aylık prestige: kontluk 0.05, dukalık 0.2, krallık 0.8, imparatorluk 1.6 (Düşük, model bilgisi ile uyumlu, kaynak: gamerempire, arama özeti; kayıt dışı).
- **Level of Fame eşikleri ve etkileri** [S15]: Disgraced 0, Established 1000, Distinguished 2000, Illustrious 5000, Exalted among Men 10000, The Living Legend 25000. Seküler görüş (Feudal): −10 / 0 / +5 / +10 / +20 / +30; şövalye sayısı: −1 / 0 / +1 / +2 / +3 / +4; kabile vergisi 0 / 8 / 16 / 24 / 32 / 40%; kabile levy 0 / 15 / 30 / 45 / 60 / 75%. Ek: Feudal/Clan Ways benimseme, daha yüksek özel unvan rütbesi gibi kilitler açılır. "A Life of Glory" perki seküler görüş ve şövalye etkilerini (cezalar dahil) ikiye katlar.
- **Level of Devotion eşikleri** [S15]: Sinner 0, Dutiful 1000, Faithful 1500, Devoted Servant 2500, Paragon of Virtue 4500, Religious Icon 8500, Divine 13000, Demigod 17000, Godlike 22500. Din adamı vergisi 0 / 15 / 25 / 35 / 45 / 55 / 65 / 75 / 85%; kutsal savaş azami rütbe: yok / kontluk / dukalık / dukalık / krallık...; Divine'dan itibaren aylık renown +0.1, aylık legitimacy +0.2 (Godlike'ta +0.2 ve +0.4), vasal sınırı +15…+35.
- **Döküm (ipucu)**: bu iki sayacın aylık kazanç dökümünün satır yapısı **bulunamadı**. Oyuncu hata raporu (CK3 1.0.3, "1.3.1'de de görüldü" iddiası) tooltipin üst çubukla tutarsız olduğunu söylüyor, bkz. Bölüm 3.5 [S25].
- **Kaldıraç ve bedel**: prestige ve piety harcanır (vasal etkileşimleri, kararlar, gayrimeşru olmayan savaş; Piety: kilise etkileşimleri, kutsal savaş) [S15]. CK3 Dev Diary #164: "prestige is easier for players to spend, but there were few prestige sinks before" (özet; yeni görevler prestige, altın veya piety'ye mal olur) [S28].
- **Başta/sonda**: bulunamadı (oyuncu raporu: "lots of it without trying" geç oyunda birikir; Bölüm 3.4) [S26].
- Wiki sürümü 1.21 [S15].

#### 1.2.2 Renown / Dynasty Splendor

- **Renown** [S19]: hanedan üyelerinden gelir; ünvan rütbesine göre: barony +0.12 … Hegemony +4; hanedan başkanı prestige'i +0.01…+0.06; ev başkanı +0.02…+0.12; sınırlar: hane üyesi başına +2, hanedan başkanı prestige'i +3, ev başkanı +5. Harcama: hanedan başkanı etkileşimleri, miras (legacy) ilkine 250, sonrakilere +500'er (250, 750, 1250, 1750, 2250).
- **Level of Splendor** [S19]: eşikler Base Origins 0, Obscure 300, Insignificant 1,000, Noteworthy 2,000, Reputable 4,000, Well-known 7,000, Significant 11,000, Famous 16,000, Glorious 22,000, Fabled 29,000, Legendary 37,000. Etkiler: doğum prestige'i 0…+1,000, doğum legitimacy'si 0…+500, evlilik prestige'i −100…+900, ittifak kabulü −5…+45. "Splendor decreases only if a player character attempts suicide." Yani **erimeyen** eşikli bir itibar basamağı.
- Sürüm 1.21 [S19].

#### 1.2.3 Dread

- **Ölçek**: 0–100; göçebe ve Meritocratic Khanate hükümdarlarında tavan 150 [S17].
- **Erime**: "Dread drifts toward the character's Dread Baseline at a base rate of 0.5 per month, in either direction." Forever Infamous perki erimeyi engeller. Taban değiştiricileri: Intimidation odağı +30, Greatest of Khans +50, Sadistic +35, Wrathful +20, Compassionate −15, Sickly −20 [S17].
- **Girdiler**: korku veren eylemler (mahkûm işkence ve idam); kayıp: mahkûmu şartsız bırakmak, hizip talebini kabul etmek; eylem başına sayı wiki'de yok [S17].
- **Neyi etkiler (puan başına)**: Popular Opinion tabanı −0.2, Control tabanı +0.2, ticaret rekabetçiliği +0.2% [S17]. Korkutulmuş karakter kabul oranları: evlilik ayarlama +75/+150, ittifak +50/+100, esir bırakma +25/+50 (korkmuş / dehşete düşmüş) [S17]; "a terrified character will never join factions or schemes against them." [S17]
- **Döküm**: wiki ipucu metni vermiyor.
- **Başta/sonda**: bulunamadı.
- Sürüm 1.21 [S17].

#### 1.2.4 Opinion

- **Ölçek**: karakter başına karakter görüşü; kaynaklar işaretli sayı: Diplomacy becerisi +1/puan; Friend +60, Best Friend +120, Rival −60, Nemesis −120 [S18].
- **Zamanlı değiştiriciler**: Attacked An Ally −25 ve Broke Truce −50, her biri 3 yıl; "most opinions decay to 0" ama genel hız verilmemiş; yalnız Tyranny: aylık −0.25 (Soon Forgiven ile −0.15, Venial ile −0.05) [S18].
- **Döküm**: wiki her kaynağı "ikon + işaretli kalın değer + etiket" olarak gösteriyor; tek harfi harfine satır: "**+5** Glory dynasty legacy tier 5" [S18]. Wiki toplamanın toplamsal olduğunu açıkça yazmıyor. Bir forum hata raporu (arama özeti): "The breakdown only counts for permanent Opinion modifiers and not temporary" [S25].

#### 1.2.5 İç içe ipucu (nested tooltips)

- **Nasıl çalışır**: CK3 Dev Diary #16 ("tutorials and tooltips and encyclopedias oh my") oyun kavramlarının açıklamasını imleç altında vermek için "tooltips in tooltips" sistemini anlatıyor; iki kilit modu: zamanlı kilit (varsayılan) ve eylem kilidi; modcular yeni kavram ekleyince ipuçlarına otomatik bağlanıyor (arama özeti; sayfa HTTP 500 verdi, doğrudan okunamadı) [S28]. Victoria 3 Dev Diary #29 sistemin CK3'ten geldiğini, kavramlar ve sayı dökümleri için kullanıldığını yazıyor (arama özeti) [S28]. Bir tasarımcı blogu (Philip Ardeljan, 2020) erişilebilirlik, dokunmatik girdi ve iç içe derinlik sorularını açıyor (arama özeti) [S28].
- **Basında/oyuncuda karşılanış**: bulunamadı. Denenen sorgular Bölüm 5'te.
- **Dev Diary #164 (CK3 Realm Maintenance, "over 1 year ago", 2025 etiketi)**: "most of what you don't need to see at all times has just moved into the tooltip"; erişilemeyen pozisyonlar için "The tooltips will tell you what you can do in order to get them." [S28] (sayfa devtrackers aynasından açıldı).

#### 1.2.6 Legitimacy

- **Hangi sürümde**: Reddit başlığı "Is legitimacy broken without DLC" (arama özeti): "The only Legitimacy source locked behind Legends of the dead is the Legends themselves Activities - Other DLC" [S26]. Yani sistem ücretsiz güncellemeyle geldi; Legends of the Dead ek kaynak ekliyor. Doğrudan kaynak (yama notu) açılmadı.
- **Ölçek**: 0–2800; 8 seviye: Illegitimate, Aspiring, Recognized, Rightful, True, Ordained, Destined, Celestial; gereken değer ana unvan rütbesi ve çağla ölçeklenir; Kabile çağında seviye başına: Aspiring 30, Recognized 70, Rightful 120, True 200, Ordained 300, rütbe katsayısıyla çarpılır (Count için ×2: Aspiring 60) [S16].
- **Girdiler (olgusal liste, sayısız)**: unvan yaratmak, ünlü esirleri şartsız bırakmak, bazı kararlar, Legend yaratmak, saray tutmak, etkinliklere katılmak, Seneschal, Court Musician "Bolster Legitimacy" görevi, savaş kazanmak (özellikle daha yüksek rütbeli hükümdara karşı); kayıp: unvan kaybı, hizip talebini kabul, tiranca eylemler, ifşa olan komplo, aforoz, "Lowborn" ile evlilik, ölümlü salgın, savaş kaybı [S16]. Hükümdar ölünce varis akrabalık derecesine göre bir kısmını devralır. Başlangıç değeri hanedanın Splendor seviyesine ve Court Grandeur'a bağlı.
- **Etkiler**: Illegitimate: kısa saltanat riski +25%, claim CB maliyeti +50%, ittifak ve evlilik kabulü −25, Popular Opinion −10, aylık Renown −0.1; Rightful: claim CB maliyeti −75/−50%, kabul +25, Popular Opinion +10; Ordained: Popular Opinion +10…+30, Renown +0.25…+0.5; unvan oluşturmak için gereken kont sayısı −%15…−%25 [S16].
- **Erime**: wiki erime tarif etmiyor [S16].
- **Döküm**: wiki ipucu metni vermiyor.
- **Oyuncu tepkisi**: Bölüm 3.4. Özet: "pay2win" tartışması, Legend olaylarını geçme, DLC "Mostly Negative" (1,630 inceleme; arama özeti) [S26, S27, S29].
- Sürüm 1.21; wiki 2024 DLC'sini anmıyor ve sayfa uzun, son 44 bin karakter okunmadı [S16].

### 1.3 Kısa notlar

**Victoria 3: Prestige** [S21]. Tanım: "the sum total of a country's economic, military, and social influence on the world." Kaynaklar: ülke kademesi (Hegemony 50 … City-State 0), ordu ve donanma gücü, GDP (£1M başına 3; tabi için 1.5), belirli malların ilk üç üreticisi, anıtlar. Etki: sıralama; Great Power için küresel ortalamanın 5 katı veya en yüksek prestige'in %75'i. Prestige %90 eşiğin altına düşerse 365 gün toparlanma süresi var. Wiki erime tanımlamıyor; "actual prestige number never went down" ama rütbe düşebilir (göreli). Gösterim arayüzde tarif edilmemiş. Sürüm 1.13, "potentially outdated".
**Victoria 3: Legitimacy** [S21]. 0–100; beş kademe: Illegitimate <25 (yalnız destekçi hareketi olan yasalar; devam eden yasa çıkarma durur), Unacceptable 25–49, Contested 50–74, Legitimate 75–89, Righteous 90+. Kaynak: hükümetteki çıkar gruplarının toplam gücü (clout) ve seçimli ülkelerde oy payı; hükümet boyutu cezası (izin verilen üstü her grup −20); ideoloji uyumsuzluğu cezası (−5 / adım). Değer arayüzde yuvarlanıp gösterilir (2.5 → 3). Aylık/yıllık erime yok: düzey hükümet yapısından türetiliyor. Sürüm 1.13.
**Stellaris: Stability** [S22]. 0–100, taban 50. 50 üstü puan başına +0.6% iş kaynağı; altı puan başına −1%. 25 altında bir yıl kalırsa "Planetary Revolt" durumu. Kaynaklar sabit bonuslar ve gezegen binalarından (Democratic Interlink +15 gibi); konut açığı en çok −40. Happiness (pop approval) ölçeği yok; konforlar (amenities) üzerinden: fazla konfor en çok +%20, açık −%50. Dökümün arayüzde nasıl gösterildiği wiki'de yok. Sürüm 4.5.
**Imperator: Rome Stability / Political Influence** [S20]. Stability 0–100, taban 50; "base value of 50 that the stability value will naturally decay to" (kendiliğinden 50'ye eriyor, EU4'ten farklı). Artış: Divine Sacrifice için PI harcamak (bedeli 50); düşüş: antlaşma bozmak, yasa/hükümet değişikliği, yüksek AE, senato onayı düşük, açık. 20 altında "Disorganized": görev devri ve savaş ilanı yok. 50 üstünde puan başına +0.5% araştırma, +0.2% pop mutluluğu; 50 altında puan başına −1% pop mutluluğu. PI: "an abstract currency generated by loyal members of your government over time", ofis başına en çok +0.25/ay, sadakate bağlı; AE 50 üstünde puan başına −0.10%; yasa 35, fikir 20, Divine Sacrifice 50, şehir kurmak 50, Legitimacy artırmak 10 PI [S20]. Sürüm 2.0.

---

## 2. Üç döküm ipucunun satır yapısı

Bu bölümdeki "KAYNAKLI" parçalar wiki'lerden; "YENİDEN KURULMUŞ" bloklar harfi harfine değildir.

### 2.A EU4 ekonomi paneli ve Diplomatic Expenses ipucu [S4]

KAYNAKLI yapı:
1. Panel: sol sütun gelir (kalem + değiştirici), gri orta sütun verimlilik, sağ sütun gider.
2. Gider satırları: otomatik (düzenlenemez, Interest hariç) ve sürgülü.
3. Gelir satırı ipucu: değiştiriciler veya eyalet başına döküm.
4. Danışman gideri ipucu: "other modifiers, including Inflation".
5. Diplomatic Expenses ipucu, wiki'deki sıra: Our Cities Looted / Our Ports Blockaded → Subsidies → Vassal fee → Outgoing tariffs → War reparations → Support loyalists → Send officers → Knowledge sharing → Condottieri fees.
6. Toplam ve renk: **bulunamadı** (wiki tarif etmiyor).

YENİDEN KURULMUŞ blok (model bilgisi, kaynak açılmadı, doğrulanmadı): üstte "Treasury"; altında yeşil "+" ile gelir kalemleri (Tax, Production, Trade, Tariffs, Gold...), kırmızı "−" ile gider kalemleri (Army, Navy, Advisors, Interest...), en altta "Balance" toplamı. Satır adları ve sıra kesin değil.

### 2.B EU4 görüş (opinion) ipucu [S6]

KAYNAKLI yapı: görüş toplamı −200…+200 arasında kırpılır; "Reasons for a nation's opinion of another are displayed in tooltips wherever opinion is shown." Her neden bir ad + işaretli değer; zamanlı olanlar yıllık erime ve süre taşır. Wiki'deki tam kalem örnekleri: Insulted −50 (yıllık +5, 10 yıl); Declared War −25 (yıllık +1); Royal Marriage +25; hediye +25 (5 yıl); Performed a Grand Hajj +30 (yıllık −3); Aggressive Expansion: "decays by 2 per year by default" [S6, S8]. Satır sırası wiki'de yok.

YENİDEN KURULMUŞ blok (model bilgisi, kaynak açılmadı, doğrulanmadı): üstte tutum etiketi (ör. "Friendly"), altta "Royal Marriage: +25" gibi kalemler, "Aggressive Expansion: −x" ve "Insulted: −50 (yılda +5 erir)" gibi zamanlı kalemler, en altta "Total" ve +200/−200 kırpması.

### 2.C CK3 görüş (opinion) ipucu [S18]

KAYNAKLI yapı: her kaynak "ikon + işaretli kalın değer + etiket"; wiki'nin tek harfi harfine satırı: "**+5** Glory dynasty legacy tier 5". Bir hata raporu: dökümün yalnız kalıcı görüş değiştiricilerini saydığı, geçicilerin sayılmadığı (arama özeti) [S25]. Wiki zamanlı kalemlerin süre ve erime bilgisini ayrı bir tabloda veriyor, ipucu satırında nasıl göründüğünü vermiyor.

### 2.D EU4 prestige bilgi satırları (ek) [S1]

KAYNAKLI yapı: her etki "ikon + kalın değer + bağlantılı ad" (ör. "**+15%** Global trade power"). Kazanç/erime satırlarının oyun içi ipucu metni **bulunamadı**. İkon adları wiki'de: "Yearly prestige", "Prestige decay".

### 2.E Eşikli basamak biçimi (CK3 Fame/Devotion/Splendor, Vic3 Legitimacy) [S15, S19, S21]

Fame, Devotion, Splendor satır başına bir seviye adı, eşik ve etki sütunlarıyla veriliyor; Vic3 Legitimacy'de beş adlı kademe, her kademede "oy/onay, radikal ve sadık etkisi, hareket ve aylık etkiler" sütunu var [S21]. Bu yapı (ad + eşik + etkiler) wiki tablosudur, oyun içi ipucu değil.

---

## 3. Şikâyetler ve başarısızlar

Hepsi arama özetinden; sayfalar açılamadı (Bölüm 0). Alıntılar özetin tırnak içi aktarımıdır; yazım hataları kaynaktandır.

### 3.1 EU4 "monarch points / mana"

- Forum, "Mana pools" konusu (yazar ve tarih bilinmiyor) [S25]: "For me the "mana pools" design is what kills the fun. Because they are essentially buit on random modifiers."
- Aynı kaynak kümesi: puanların hükümdarın niteliğine bağlı olduğunu söyleyen bir yazı: "the quality of your nation's ruler is a big factor in how many monarch points you earn" [S25]; ölçekle maliyet artışı: "Corruption/unrest/rebels/AE/monarch point cost/diplo relations/diplomat time etc all become more strained the faster you go" [S25]. Savunma: bir inceleme "Monarch points turn administrative, diplomatic and military resources into pure opportunity cost" der [S29]; bir forum yazarı mana'nın iyi uygulandığını savunur [S25].
- Reddit, "Johan on mana in EU5(?)" (r/eu4, 2024-03-08) [S26]: başlık altındaki üst yorum: "Johan says that the upcoming Project Ceasar (likely to be EU5) will not have mana or abstract capacities." (ikinci el aktarım; özgün Johan metni açılmadı). Tepkiler: "one of, if not the, most hated mechanic in EU4"; savunma: "mana has been called gamey or unrealistic which imo is a fair criticism but is still one of the game's most rewarding parts"; "the Victoria 3 system of capacities is a lot better than mana"; bir başkası: "Mana is one way to do it, but that's the lazy, unengaging way to do it."
- Bret Devereaux (acoup.blog, 2025-10-31, EU5 ilk izlenimleri; sayfa açıldı) [S24]: "monarch points (“mana”) are gone, but this isn’t a full switch back to" EUIII'ün "gold does everything" sistemine; "monarch points have been replaced by a _bunch_ of interacting systems"; "abstract game mechanics have been mostly replaced by interwoven systems"; "the player influences only slowly and often indirectly".
- Tinto Talks #72 (2025-07-16), arama özeti: ekibin EU5'te EU4'ün en önemli mana temelli mekaniğinden (monarch points) simülasyoncu sistemlere kaydığı yazılı; yazar ve tam metin doğrulanmadı (sayfa HTTP 500) [S25].

### 3.2 Imperator: Rome "mana" ve neden kaldırıldığı

- **Düzeltme**: kaldırma 2.0'da değil **1.2 (Cicero, Eylül 2019)** ile. PC Gamer: Monarch Power, "the resource nicknamed 'mana'"; "Spending Monarch Power is one of the main ways you interact with the game, turning all your political influence into a single, simple resource"; "In 1.2, it will be completely flung out and replaced. Instead of mana, you'll generate political influence based on how loyal the movers and shakers in your nation are." [S23, arama özeti; makale gövdesi WebFetch'te kesildi]
- Cicero 1.2 beta notları (arama özeti): "Monarch power has been removed as a concept. A new currency, Political Influence, is now generated by loyal members of your Government over time." [S23]
- Bir geliştirici yazısı (Overclockers forumu, yazar ve tarih doğrulanmadı, 403 ile açılamadı; arama özeti): "the design we've been working on right now have been to remove the four types of monarch power from the game, and replace their costs with other impacts, and also introduce a new currency which we call Political Influence" [S23]. **Geliştirici günlüğünün kendisinde "neden" gerekçesi bulunamadı.**
- Wiki 2.0: PI hâlâ var: "an abstract currency generated by loyal members of your government over time" [S20]. Yani mana tipi tek değer gitti, yerine tek bir "soyut para" daha geldi ama girdisi dünyaya (ofis sahiplerinin sadakati) bağlandı.
- Tepki (arama özeti): PCWorld (Hayden Dingman): oyun "pretty good at teaching you how to press its buttons, not so much why you should press them" [S29]; Gamereactor: karakter sirkülasyonu yüzünden "harder to grow attached to the characters under our charge" [S29]; Marius sonrası bir forum incelemesi: "the whole challenge in IR is still about balancing AE, senate approval, stability, political influence. And how you gain/ lose them don't make sense for the era." [S25]

### 3.3 Stability / Prestige "anlamsız" şikâyeti

- Forum, "stability should be inverse of eu4" (EU5 dönemi konusu; yazar/tarih bilinmiyor) [S25]: "it can swing wildly from -1 to +3 with the click of a few buttons is meaningless"; "the stability mechanic in eu4 just needs to go"; "you can just 'boost' stability"; "EU4 stability is largely static, which causes this de-connection from the rest of the game"; "where you can just buy it with magic is very lackluster".
- Steam, EU5 tartışması (bu EU5; EU4 değil) [S27]: "it is trivially easy to keep Stability and Legitimacy high as both are simple functions of money".
- EU4 prestige için "anlamsız / umursamıyorum / angarya" türü şikâyet **bulunamadı** (sorgular Bölüm 5). Bulunan tek eleştiri bir öneri başlığı: ülke prestige'inin "too impersonal" olduğu ve hükümdara bağlanması ("Personal Prestige") [S25].

### 3.4 CK3 prestige, piety, legitimacy

- r/CrusaderKings, 2024-06 (arama özeti; yazar yok) [S26]: biriken bol prestige konusunda "when you have lots of it without trying, and the only time you need more than the usual it can require a whole character lifestyle to get it, it feels like prestige and piety are useless at best and a nuisance at worst"; bir yanıt itiraz ediyor: "this isn't an issue, it's a framing of what the game systems are actually built for."
- Steam (arama özeti) [S27]: etkinlikler "will shower you with prestige, piety, lifestyle experience, free traits, free lifestyle perks, and as many friendships as you care for"; öneriler arasında prestige ve piety için erime ve sonsuz birikim yasağı. Legitimacy üzerine: "only the Legends of the Dead DLC offers additional options to gain legitimacy. This makes it de facto a "pay2win" mechanic." [S27]
- Geliştirici günlüğü #147 (arama özeti; oyun yönetmeni yazısı, sayfa açılamadı) [S28]: ekip bazı değerler için görüşlerin "underpowered and useless" ile "too overpowered" arasında dağıldığını söylüyor ve AI'nin "Prestige debt" yüzünden savaş ilan edememesine baktığını, bir sonraki yazı da prestige gibi kaynaklara denge geçişi yapıldığını belirtiyor.
- Legends of the Dead: ggrecon incelemesi (puan 4/5; yayın tarihi görünmüyor; sayfa açıldı) [S29]: legitimacy "another new mechanic that measures your right to reign as a ruler"; Legends'ın "can produce so many events that the reviewer ended up skipping them" (özet; ilgili özgün alıntı: "constant events that I ended up skipping through after a while" arama özetinde). Steam mağaza sayfasında "Mostly Negative (1,630 reviews)" etiketi (arama özeti; tarih yok) [S29].

### 3.5 Dökümün okunmaz ya da yanlış olduğu şikâyetler

- CK3 hata raporu (1.0.3, "1.3.1'de de görüldü" iddiası) [S25]: net prestige tabanı negatifken prestige değiştiricilerinin etkisiz kalması; aynı konuda: "even if you DO get the Prestige Gain to be positive - by raiding - (as it shows at the top of the screen) the tooltip still shows as negative". Bir Steam yorumcusu hesabı şöyle açıklıyor: "it should calculate gain * perks - loss but it does gain-loss and if the result is negative it simply doesn't add perks." [S27]
- Bir forum hata raporu (CK3 şef/aptitude ipucu, arama özeti) [S25]: ipucundaki değiştiriciler toplanınca gösterilen düzeyle tutmuyor: "if you add up the modifiers on the tooltip they are less than 80".
- EU5 subreddit yorumu (arama özeti) EU4'ün karmaşıklığı üzerine: değiştirici sayısından çok "how they are presented and displayed to the player" önemli [S26].
- "Çok satır / gizli çarpan" tipi doğrudan şikâyet için genel arama sonuç vermedi (Bölüm 5).

---

## 4. Karşılaştırma tablosu

| Değer | Ölçek | Erime | Girdi sayısı | Etkisi | Dökümün biçimi | Oyuncu ne diyor |
|---|---|---|---|---|---|---|
| EU4 Prestige | −100…+100 | yılda %5 (mutlak değerin) [S1] | 10+ yıllık, 10+ tek sefer, harcama 5 [S1] | 100'de ticaret gücü +15%, moral +10%, legitimacy +1/yıl [S1] | ikon + kalın değer + ad [S1]; tam ipucu bulunamadı | "too impersonal" önerisi [S25]; anlamsız şikâyeti bulunamadı |
| EU4 Stability | −3…+3 [S2, S29] | yok | tek harcama (100 yönetim puanı) [S2] | düzey başına huzursuzluk −1, vergi +5% [S2] | ipucu metni bulunamadı | "meaningless", "buy it with magic" [S25] |
| EU4 Legitimacy | 0–100 [S3] | yok (yıllık akış) | 15+ yıllık [S3] | huzursuzluk +2/−2, absolutism ±10 [S3] | bulunamadı | bulunamadı |
| EU4 Rep. tradition / Devotion / Horde unity | 0–100 [S12–S14] | yok; horde taban −2/yıl [S13] | 10+ her biri | huzursuzluk ±2 gibi; devotion vergi ±25% [S14] | bulunamadı | bulunamadı |
| EU4 Power projection | 0–100 [S5] | olay etkisi yılda 1 [S5] | 18 satır [S5] | 25'te +1 lider, 50'de +1 puan/ay [S5] | bulunamadı | bulunamadı |
| EU4 Army tradition | 0–100 [S7] | yılda %5 [S7] | muharebe + 5 yıllık [S7] | 100'de moral +%25 [S7] | savaş sonu ekranı [S7] | bulunamadı |
| EU4 Opinion | −200…+200 [S6] | modifier başına; AE yılda 2 [S6, S8] | çok | diplomatik kabul [S6] | tooltip'te "neden" listesi [S6]; satır dizisi bulunamadı | koalisyon, "AE" tartışması [S26] |
| EU4 AE/OE/WE/Corruption | −1000/sınırsız/0–20/0–100 [S8–S11] | AE 2/yıl; WE −0.1/ay barışta [S8, S10] | 5–10 [S8–S11] | koalisyon, huzursuzluk, maliyet [S8–S11] | bulunamadı | bulunamadı |
| CK3 Prestige/Piety → Fame/Devotion | 6 / 9 basamak, 0–25000 / 0–22500 [S15] | erime tarif yok; fame nadiren düşer [S15] | 6–8 [S15] | seküler görüş −10…+30, devotion → vergi, legitimacy [S15] | eşikli tablo [S15] | "useless at best, nuisance at worst" [S26] |
| CK3 Splendor | 11 basamak, 0–37000 [S19] | yok (yalnız intihar) [S19] | renown (hane üyesi) [S19] | doğum prestige'i, evlilik, ittifak [S19] | tablo [S19] | bulunamadı |
| CK3 Dread | 0–100 (150) [S17] | tabana ayda 0.5 [S17] | 2 eylem tipi [S17] | Popular Opinion −0.2/puan [S17] | bulunamadı | bulunamadı |
| CK3 Legitimacy | 0–2800, 8 seviye [S16] | tarif yok [S16] | 14 madde [S16] | saltanat, CB maliyeti, kabul, Popular Opinion [S16] | bulunamadı | pay2win, Legend olayları geçilir [S27, S29] |
| Imperator Stability / PI | 0–100, 50'ye erir [S20] | 50'ye kendiliğinden [S20] | 10+ [S20] | +0.5% araştırma/puan, mutluluk [S20] | bulunamadı | "don't make sense for the era" [S25] |
| Vic3 Prestige / Legitimacy | sıralama / 0–100, 5 kademe [S21] | yok (türetilir) [S21] | 6 / 4 [S21] | rütbe / sadakat-radikalizm [S21] | kademe tablosu; yuvarlanmış değer [S21] | bulunamadı |
| Stellaris Stability | 0–100, taban 50 [S22] | yok | bina ve ulus kaynakları [S22] | iş kaynağı +0.6% / −1% [S22] | bulunamadı | bulunamadı |

---

## 5. "Bulunamadı" listesi

1. **Harfi harfine EU4/CK3 ipucu dökümü** (aylık denge, prestige, opinion): wiki'ler görsel kullanıyor; wiki/forum/Steam/Reddit sayfalarının metin dökümü yok ya da açılamadı. Denenen sorgular: "EU4 prestige tooltip Yearly prestige Prestige decay Reddit what does prestige actually do"; "EU4 monthly income tooltip Monthly balance breakdown lines forum"; "EU4 opinion tooltip Aggressive Expansion Royal Marriage Trade Power Same religion Their opinion of us breakdown"; "CK3 monthly prestige tooltip breakdown Monthly Prestige Title Rank Diplomacy Domain tooltip lines"; "EU4 treasury tooltip Estimated Monthly Income ..."; "Crusader Kings 3 opinion tooltip Opinion of breakdown Recently lines Attraction Same Faith forum post pasted tooltip"; "eu4 localisation l_english aggressive_expansion ..."; "EU4 yearly prestige tooltip Prestige decay per year from Great Power pasted tooltip text". Ayrıca kurulan WebFetch'ler: wiki sayfalarındaki görsel adresleri (ipucu ekran görüntüsü yok).
2. **Toplam satırının yeri ve renkleri (EU4 "monthly balance" ipucu)**: wiki ve rehberler tarif etmiyor.
3. **EU4 prestige için "anlamsız / umursamıyorum / angarya / yalnız bekliyorum" şikâyeti** (harfi harfine): sorgular: "EU4 prestige don't care OR never matters OR useless OR irrelevant prestige mechanic forum"; "EU4 stability pointless OR just click OR boring OR chore ...". Stability için forum alıntıları bulundu (Bölüm 3.3); prestige için yalnız "Personal Prestige" önerisi.
4. **CK3 legitimacy için "angarya / sevildi" ölçütlü doğrudan oyuncu alıntısı**: sorgu "CK3 Legends of the Dead legitimacy reddit tedious OR pointless OR don't care". Bulunan: pay2win tartışması ve Legend olaylarını geçme şikâyeti.
5. **CK3 iç içe ipucunun basın ve oyuncu karşılanışı**: sorgu "CK3 nested tooltips dev diary tooltips inside tooltips". Yalnız tasarım günlüğü ve bir tasarımcı blogu bulundu, karşılanış yok.
6. **Imperator 2.0'da mana'nın neden kaldırıldığına dair geliştirici günlüğü metni**: kaldırma 1.2'de olmuş ve Dev Diary metni açılamadı (forum doğrulama ekranı, Overclockers 403). Denenen: "Imperator Rome 2.0 dev diary removal of political points mana"; "Imperator Rome developer diary political influence replaced loyalty offices ... Andersson"; "In 1.2, it will be completely flung out and replaced ...".
7. **Tooltip "çok satır / gizli çarpan" şikâyeti**: sorgu "Paradox game tooltip modifier breakdown unreadable wall of text OR too many modifiers OR hidden modifiers ..."; yalnız tutarsız ipucu hata raporları (Bölüm 3.5).
8. **Johan'ın EU5 "mana yok" ifadesinin özgün metni**: Reddit yansıları TLS hatası verdi; aktarım ikinci el.
9. **CK3 Legitimacy'nin hangi yamayla geldiğine dair doğrudan yama notu**: açılmadı; yalnız Reddit özeti.
10. **Başlangıç (küçük ülke) ve son (büyük imparatorluk) davranış** değer değer: wiki'ler bunu vermiyor; olduğu yerde yalnız tek cümle kaynaklı (Army tradition: küçük/orta uluslar için muharebe ana kaynak [S7]).
11. **CK3 prestige ve piety aylık kazanç ipucunun satır yapısı**, **Victoria 3 ve Stellaris dökümü ipucu metni**, **Dread vasal etkilerinin sayısal tabloları** (wiki'de "vasal" etkisi yok, korkutma yoluyla): bulunamadı.

---

## 6. Kaynak sicili

Not: S23–S29 grup kayıtlarıdır (bir kimlik altında birkaç URL). Wiki "yayın" sütunu = "güncel wiki" + wiki'nin gösterdiği doğrulama yaması. Erişim hepsi 2026-11-18.

| ID | URL | Yayıncı | Yayın | Erişim | Güven | Not |
|---|---|---|---|---|---|---|
| S1 | https://eu4.paradoxwikis.com/Prestige | EU4 Wiki (Paradox) | güncel wiki, doğrulama 1.26, rev 175147, düzenleme 2025-09-22 | 2026-11-18 | Yüksek | Açıldı. "Increasing/Losing" bölümleri outdated |
| S2 | https://eu4.paradoxwikis.com/Stability | EU4 Wiki | güncel wiki, doğrulama 1.25, düzenleme 2026-08-28 | 2026-11-18 | Yüksek | Açıldı. Düşüş sebepleri listelenmemiş |
| S3 | https://eu4.paradoxwikis.com/Legitimacy (Monarchy sayfasına yönlendi) | EU4 Wiki | güncel wiki, legitimacy bölümü 1.27 | 2026-11-18 | Yüksek | Açıldı; sayfanın son 407 bin karakteri okunmadı |
| S4 | https://eu4.paradoxwikis.com/Economy | EU4 Wiki | güncel wiki, 1.24–1.29 | 2026-11-18 | Yüksek | Açıldı; ipucu satırı tarif etmiyor |
| S5 | https://eu4.paradoxwikis.com/Power_projection | EU4 Wiki | güncel wiki, doğrulama 1.30, rev 174644, 2025-07-17 | 2026-11-18 | Yüksek | Açıldı |
| S6 | https://eu4.paradoxwikis.com/Relations ; https://eu4.paradoxwikis.com/Diplomacy | EU4 Wiki | güncel wiki, 1.24–1.25, düzenleme 2025-08-12 | 2026-11-18 | Yüksek | Açıldı; Diplomacy sayfasının son 104 bin karakteri okunmadı |
| S7 | https://eu4.paradoxwikis.com/Army_tradition | EU4 Wiki | güncel wiki, doğrulama 1.26, düzenleme 2025-07-30 | 2026-11-18 | Yüksek | Açıldı |
| S8 | https://eu4.paradoxwikis.com/Aggressive_expansion | EU4 Wiki | güncel wiki, 1.24–1.25 (1.31 notu) | 2026-11-18 | Yüksek | Açıldı; −50/50 iç çelişki |
| S9 | https://eu4.paradoxwikis.com/Overextension | EU4 Wiki | güncel wiki, 1.29, düzenleme 2025-12-30 | 2026-11-18 | Yüksek | Açıldı |
| S10 | https://eu4.paradoxwikis.com/War_exhaustion | EU4 Wiki | güncel wiki, 1.30 | 2026-11-18 | Yüksek | Açıldı |
| S11 | https://eu4.paradoxwikis.com/Corruption | EU4 Wiki | güncel wiki, 1.27 | 2026-11-18 | Yüksek | Açıldı |
| S12 | https://eu4.paradoxwikis.com/Republic | EU4 Wiki | güncel wiki, 1.30 | 2026-11-18 | Yüksek | Açıldı; sayfa uzun, ilk 100 bin karakter |
| S13 | https://eu4.paradoxwikis.com/Steppe_hordes | EU4 Wiki | güncel wiki, bölüm sürümü etiketsiz (sayfa 1.23–1.36) | 2026-11-18 | Yüksek | Açıldı |
| S14 | https://eu4.paradoxwikis.com/Theocracy | EU4 Wiki | güncel wiki, devotion bölümü 1.23 (outdated) | 2026-11-18 | Yüksek | Açıldı; tablo düzeni belirsiz |
| S15 | https://ck3.paradoxwikis.com/Resources | CK3 Wiki | güncel wiki, doğrulama 1.21 | 2026-11-18 | Yüksek | Açıldı |
| S16 | https://ck3.paradoxwikis.com/Legitimacy | CK3 Wiki | güncel wiki, doğrulama 1.21 | 2026-11-18 | Yüksek | Açıldı; son 44 bin karakter okunmadı; ipucu metni yok |
| S17 | https://ck3.paradoxwikis.com/Dread | CK3 Wiki | güncel wiki, doğrulama 1.21 | 2026-11-18 | Yüksek | Açıldı |
| S18 | https://ck3.paradoxwikis.com/Opinion | CK3 Wiki | güncel wiki, doğrulama 1.21 | 2026-11-18 | Yüksek | Açıldı; son 30 bin karakter okunmadı |
| S19 | https://ck3.paradoxwikis.com/Dynasty | CK3 Wiki | güncel wiki, doğrulama 1.21 | 2026-11-18 | Yüksek | Açıldı |
| S20 | https://imperator.paradoxwikis.com/Political_influence ; https://imperator.paradoxwikis.com/Stability | Imperator Wiki | güncel wiki, doğrulama 2.0, düzenleme 2022-02-07 (PI) | 2026-11-18 | Yüksek | Açıldı; Stability sayfasının son 33 bin karakteri okunmadı |
| S21 | https://vic3.paradoxwikis.com/Prestige ; https://vic3.paradoxwikis.com/Legitimacy | Victoria 3 Wiki | güncel wiki, doğrulama 1.13 (outdated) | 2026-11-18 | Yüksek | Açıldı; bazı tablo sütunları okunaksız |
| S22 | https://stellaris.paradoxwikis.com/Stability (Colony management'a yönlendi) | Stellaris Wiki | güncel wiki, doğrulama 4.5 | 2026-11-18 | Yüksek | Açıldı |
| S23 | https://www.pcgamer.com/how-paradox-is-rebuilding-imperator-rome ; https://www.gamewatcher.com/imperator-rome-cicero-patch-1-2-beta-notes ; https://forums.overclockers.co.uk/posts/32724346 | PC Gamer; GameWatcher (yama notu aktarımı); Overclockers forumu (geliştirici metnini aktaran yazı) | 2019 (Cicero 1.2 Eylül 2019); tam tarih görünmedi | 2026-11-18 | Orta (Overclockers ve notlar Düşük) | Yalnız arama özeti; PC Gamer gövdesi kesik geldi, Overclockers 403 |
| S24 | https://acoup.blog/2025/10/31/miscellania-europa-universalis-v-confirmed-first-impressions/ | acoup.blog (Bret Devereaux) | 2025-10-31 | 2026-11-18 | Orta | Açıldı (ilk 100 bin karakter) |
| S25 | https://admin-forum.paradoxplaza.com/forum/threads/stability-should-be-inverse-of-eu4.1647856 ; .../mana-pools.1170505 ; .../plz-dont-do-the-power-system-in-the-next-eu-game.1568255 ; .../come-eu5-what-would-you-do-with-mana.1558752 ; .../ck-iii-1-0-3-prestige-and-piety-modifiers-have-no-effect-when-the-net-base-prestige-piety-is-negative.1422519 ; .../vassal-stance-totals-skip-over-some-actions.1591366 ; .../missing-modifiers-in-camp-officers-aptitude-tooltips-camp-stooge-aptitude-calculation-is-possibly-incorrect.1748438 ; .../minor-mechanic-to-make-rulers-more-personal-personal-prestige.1453991 ; Tinto Talks #72 https://admin-forum.paradoxplaza.com/forum/developer-diary/tinto-talks-72-16th-of-july-2025.1846292/page-5 | Paradox forumu (kullanıcı yazıları; Tinto Talks geliştirici günlüğü) | çeşitli, tarihler bilinmiyor (Tinto Talks #72: 2025-07-16) | 2026-11-18 | Düşük (forum anekdotu); Tinto Talks Yüksek ama içerik doğrulanmadı | Sayfalar açılamadı (500/doğrulama ekranı); yalnız arama özeti |
| S26 | r/CrusaderKings "Is legitimacy broken without DLC" (lr.in.psf.lt/r/CrusaderKings/comments/1dsdie6) ; r/CrusaderKings prestige/piety (lr.in.psf.lt/r/CrusaderKings/s/y5Bpu1Dunt, 2024-06-11) ; r/eu4 "Johan on mana in EU5(?)" (lr.in.psf.lt/r/eu4/comments/1ba13ep, 2024-03-08) ; r/EU5 UI comment (redlib.ssps.io/r/EU5/comments/1kqn6dd/..., 2025-05-19) | Reddit (kullanıcılar) | 2024-03 … 2025-05 | 2026-11-18 | Düşük | Yansı siteleri TLS hatası; yalnız arama özeti, yazar adı yok |
| S27 | Steam tartışmaları: https://steamcommunity.com/app/1158310/discussions/0/4295942652152847229 ; https://steamcommunity.com/app/1158310/discussions/0/6348431004286890080 ; https://steamcommunity.com/app/3450310/discussions/0/570426104667463268/ ; https://steamcommunity.com/workshop/filedetails/discussion/2222896774/2943621444608103765 | Steam Community (kullanıcılar) | tarihler bilinmiyor | 2026-11-18 | Düşük | Yaş kapısı; yalnız arama özeti |
| S28 | CK3 Dev Diary #164 Realm Maintenance: https://devtrackers.gg/crusader-kings/p/069ed67e-dev-diary-164-realm-maintenance ; CK3 Dev Diary #16: https://admin-forum.paradoxplaza.com/forum/developer-diary/ck3-dev-diary-16-tutorials-and-tooltips-and-encyclopedias-oh-my.1345581 ; Victoria 3 Dev Diary #29: https://admin-forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-29-user-experience.1506484/page-3 ; CK3 Dev Diary #147: https://admin-forum.paradoxplaza.com/forum/developer-diary/dev-diary-147-some-words-from-our-game-director.1673686/page-2 ; Philip Ardeljan blogu: https://hn.jakechampion.name/reader/https://philip.design/blog/tooltips-in-tooltips | Paradox Interactive (geliştirici günlükleri); tek blog | #164: "over 1 year ago" (2025 etiketi); #16: ~2020; #29: ~2022; #147: 2024; blog 2020 | 2026-11-18 | Yüksek (günlükler); Düşük (blog) | Yalnız #164 açıldı (devtrackers aynası); diğerleri arama özeti (500) |
| S29 | https://www.ggrecon.com/reviews/crusader-kings-3-legends-of-the-dead-review/ ; https://www.pcworld.com/article/3391337/imperator-rome-review.html ; https://www.gamereactor.eu/?p=55423 ; https://www.gamepressure.com/europauniversalisiv/important-terms-and-factors/z15471 ; https://www.gamepressure.com/europauniversalisiv/treasury/z2547b ; https://www.gamepressure.com/europauniversalisiv/the-budget/z1547a ; https://forum.paradoxplaza.com/forum/threads/europa-universalis-iv-developer-diary-4-your-economy-is-about-to-change.634853/post-14402349 ; https://store.steampowered.com/sub/956998 ; https://gamerempire.net/crusader-kings-3-how-to-gain-prestige/ | GGRecon, PCWorld (Hayden Dingman), Gamereactor, GamePressure, Paradox (EU4 Dev Diary 4), Steam mağazası, GamerEmpire | ggrecon tarih görünmüyor; PCWorld/Gamereactor 2019; GamePressure rehberleri eski EU4 yamaları; EU4 DD4 ~2013; Steam etiketi tarihsiz | 2026-11-18 | Orta (basın); Yüksek (EU4 DD4 ama gövde açılamadı); Düşük (GamerEmpire) | ggrecon ve GamePressure açıldı; diğerleri arama özeti |
