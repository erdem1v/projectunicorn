# Kalite v2 · Ürün kalitesi ve ürün uyumu
Yazan: Opus planlayıcı · 2026-10-17 akşam · `X_URUN_EKSENLERI.md`'nin halefi. Kaynak: Erdem'in cevabı (`ERDEM_CDQ_CEVAP.md`,
birebir), X, araştırma R8, R9, R11. Kod `f4a623b` üstünde okundu; koda dokunulmadı.

Bu belge ürün uyumu U'nun **tek tanımıdır**. `C_ICERIK_v3.md` U'yu buradaki anlamla okur. Etiketler `C_ICERIK_v3.md` ile
aynı: Erdem'in kararı, Öneri, [ÇALIŞMA].

---

## 0. Özet
1. Ürünün tek kalitesi sprint ekranındaki alanlardır: Çekirdek, Onboarding & Erişim, Entegrasyonlar, Güven & Ölçek (B2C'de
   ayrıca Büyüme). Üç gizli eksen ekonomiden çıkar. Erdem'in kararı (Q1).
2. "Kararlılık" açık hata ve kesinti satırının başlığıdır. Erdem'in kararı (Q2).
3. Kalite işi C'den önce, ekransız ayrı bir fazdır. Erdem cevaplamadı, öneri olduğu gibi yürür (Q4).
4. **Q3 yeniden:** her sektör Çekirdek'e ağır bakar; sektör iki alana ek ağırlık verir (R11'in sektör tablosu). "Bir sektör
   tek alanı önemser" kalkar. Lojistik ve teknoloji eşlemesi değişir, sigorta kalır.
5. **Çekirdek baskın kuralı tavan biçimindedir:** öteki alanlar uyumu Çekirdek oranının en çok 0,25 üstüne taşıyabilir.
   Çekirdeği zayıf ürün (Çekirdek 0,4) güveni ve entegrasyonu ne kadar iyi olursa olsun 46'yı geçemez; sabit ağırlıkta 63
   olurdu.
6. **U** 0 ile 100 arası bir sayıdır, beklentiyi tam karşılayan üründe 70. Hesap pazarın beklentisini imzada ve yenilemede
   okur; ürün değişince U hemen değişir.
7. Hacim: yaklaşık 48 saat (X: 36-49).

---

## 1. Onaylananlar

**Q1 · Tek kalite alanlardır.** Erdem: "çekirdek, güven ölçek, entegrasyonlar, onboarding vesaire gibi şeyler fena değil
bence ... ürün kalitesini buna bağlamakta bir sakınca görmüyorum."
- Gerçek adlar (`sprint.json:56-63`, `strings.csv:2913-2924`): Çekirdek / Core; Onboarding & Erişim / Onboarding & Access
  (kısa Onboarding); Entegrasyonlar / Integrations (yalnız B2B); Büyüme / Growth (yalnız B2C); Güven & Ölçek / Trust &
  Scale (kısa Güven); Gelir / Revenue (yalnız B2C, ücretli plan; kaliteye girmez, fiyatın konusudur).
- Deneyim, İnovasyon, Kararlılık eksenleri ve eksen puanları ekonomiden çıkar (X §2.2'deki 16 okuyucu, §6 tablosu).
- Ekip becerisi kaliteyi çarpmaz; hızı ve hata ihtimalini belirler (X §6.5b, değişmedi).

**Q2 · "Kararlılık" bir başlıktır.** Erdem: "Kararlılığı yeni bir özellik grubu olarak değil, açık hata kesiminin başlığı
olarak kalsın demişsin. Okey."
- Genel Bakış'ta: `Kararlılık · 7 açık hata ▲2 · son 4 haftada 1 kesinti` / `Stability · 7 open bugs ▲2 · 1 outage in
  the last 4 weeks`. Hata ve kesinti zaten ölçülen kararlılıktır (A'nın deposu, B'nin olayı).

**Q4 · Ayrı faz.** Sıra A → B → Kalite → C → D → E. Ekransızdır: görünür kısımları C (Genel Bakış, ipucu) ve D (kart)
çizer.

---

## 2. Q3 · Sektör ve alan

### 2.1 Erdem ne dedi
"Her B2B müşteri için tek bir alanı önemsesin kısmı bence doğru değil ... lojistik güvene, teknoloji çekirdeğe, sigorta
entegrasyona baksın gibi ayrımların önce bir doğru yapıldığından emin ol ... Daha ağırlıklı baktığı olmalı ... çekirdeği bok
gibi olan bir ürünü sırf güven ölçeği iyi diye satamamalıyız."

### 2.2 Bugünkü eşleme neden yanlış
- Eşleme sektörde değil üç alıcı tipindedir (`sales_archetypes.gd:51`, `:76`, `:99`; `sprint.json:55`). On üç sektörün onu
  üç tipe dağılmış; aynı tipin içindeki sektörlerin kanıtlı vurguları farklıdır (R11 §1.1, §5).
- Lojistik bugün Güven okur; kanıt Entegrasyonlar'ı (ERP, depo ve taşıyıcı bağlantısı) öne koyar (R11 §5). Teknoloji bugün
  Çekirdek okur; Çekirdek herkesin tabanı olduğu için bu bir vurgu değildir. Sigorta Entegrasyonlar okur; kanıt bunu destekler.
- Sağlık, Tekstil ve Medya hiçbir tipte yok ve hiç aday üretmiyor (`sales_faucet_system.gd:212`, R11 §1.2). Soru 4.

### 2.3 Çekirdek her sektörde ilk mi
Alıcı anketlerinde beyan edilen öncelik olarak hayır: G2 EMEA 2024'te ilk üç güvenlik, entegrasyon, kullanım kolaylığı
(https://company.g2.com/news/whats-top-of-mind-for-emea-software-buyers-in-2024); Gartner 2024'te fiyat %49, güvenlik %48
(arama özeti, sayfa açılmadı). Eleme koşulu olarak büyük olasılıkla evet: alıcıların %62'si son kararı deneme sürümüne
bağlıyor (Gartner 2025, https://2wtech.com/navigating-the-competitive-software-market/), deneme ürünün temel işini sınar.
Yani Çekirdek "en yüksek ağırlık" değil, "giriş bileti"dir (R11 §4; bu son cümle R11'in çıkarımıdır, kaynakta açık cümle
yok). Bu, Erdem'in cümlesinin birebir karşılığıdır ve kuralın biçimini (§2.5) belirler.

### 2.4 Sektör → alan tablosu
Öneri. Çekirdek her sektörde tabandır. Her sektör iki ek vurgu taşır. Güven: orta = en az bir anket ya da düzenleme;
düşük = uzman rehberi ya da kaynaksız (tasarım tahmini).

| Sektör | Vurgu 1 | Vurgu 2 | Kalan | Güven | Dayanak |
|---|---|---|---|---|---|
| Sağlık | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta | HIPAA 45 CFR 164.306(a), https://www.law.cornell.edu/cfr/text/45/164.306 |
| Finans | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta | AB DORA md. 2 ve 28, https://www.digital-operational-resilience-act.com/Article_28.html |
| Sigorta | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta | Celent, 141 sigortacı, https://celent.com/insights/443658002 ; DORA md. 2 |
| Hukuk | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta-düşük | MyCase 2022, 2.300+ katılımcı, https://www.mycase.com/reports/2022-legal-industry-report/ |
| Lojistik | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta-düşük | TMS rehberi, https://logisticsviewpoints.com/2026/10/07/choosing-a-tms-what-logistics-leaders-should-evaluate-beyond-features/ |
| İnşaat | Onboarding & Erişim | Güven & Ölçek | Entegrasyonlar | düşük-orta | JBKnowledge 786 yüklenici, https://nrca.net/RoofingNews/survey-examines-construction-industry-progress-with-adopting-technology.10-16-2018.7174/details/story |
| E-ticaret | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta-düşük | Google/Deloitte, https://web.dev/case-studies/milliseconds-make-millions |
| Perakende | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | düşük | aynı çalışmanın perakende kolu |
| Teknoloji | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | düşük | G2 genel sıralaması (sektör kırılımı yok) |
| Üretim | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | düşük | kaynaksız (makine ve planlama arası veri) |
| Tekstil | Entegrasyonlar | Onboarding & Erişim | Güven & Ölçek | düşük | kaynaksız (üretimle aynı aile) |
| Emlak | Onboarding & Erişim | Entegrasyonlar | Güven & Ölçek | düşük | kaynaksız (saha ve mobil) |
| Medya | Güven & Ölçek | Onboarding & Erişim | Entegrasyonlar | düşük | kaynaksız (yayın anı) |

- Bugünden fark: lojistik Güven → Entegrasyonlar (Güven ikinci), teknoloji Çekirdek → Entegrasyonlar, finans ve e-ticaret
  Çekirdek → Güven, inşaat Güven → Onboarding, perakende Entegrasyonlar → Güven; sigorta aynı.
- "Güven & Ölçek" iki kaygıyı taşır: uyum ve gizlilik (sağlık, finans, sigorta, hukuk) ile kesintisizlik ve yük
  (e-ticaret, perakende, medya). Alan tek olduğu için tablo tek ad yazar; oyuncuya giden cümle sektörün kaygısını söyler
  (§4). Hat düzeyine inmek daha fazla veri ve ekran ister; bu fazda yok.
- Düşük güvenli satırlar tasarım tahminidir. Ağırlıkları bütün sektörlerde aynı olduğu için yanlış bir tahminin bedeli
  küçüktür: en çok %25'lik payın yeri değişir.
- **İstek alanı da bu tablodan gelir:** hesabın isteği vurgu 1 alanından seçilir (bugün `sprint.json:55` tipten). Böylece
  istek ve memnuniyet aynı hikâyeyi anlatır.
- Müzakere mizacı (sabır, hakaret payı, yıldız aralığı) alıcı tipinde kalır; tip yalnız alan seçmeyi bırakır.

### 2.5 "Çekirdek baskın" kuralının biçimi
R11 §7 üç biçimi sayıyla karşılaştırdı. Ortak tanım: r = alan oranı (§3.1).

| Biçim | Kural | Çekirdek 0,3, öteki 1,5 iken | Zayıf yanı |
|---|---|---|---|
| A sabit yüksek ağırlık | uyum = Σ w r | 63 | Zayıf Çekirdek'i öteki alanların fazlası kapatır. Erdem'in itirazı tam bu. |
| **B tavan (öneri)** | uyum = min(Σ w r, r_Çekirdek + 0,25) | **38,5** | Tavan devredeyken öteki alana yatırım karşılıksız kalır; oyuncuya bir cümle gerekir (§4). |
| C çarpımsal | Çekirdek^0,5 × (öteki ort.)^0,5 | 47 | Bir alan 0 iken uyum 0; MVP'de her şey 0 olur. Anlatması zor. |

**Seçim: B, pay 0,25 [ÇALIŞMA].**
- Neden var: Çekirdek giriş biletidir (§2.3). Çekirdek iyi iken B ile A aynı sonucu verir; fark yalnız Çekirdek'i geride
  kalan üründedir. Bu, Erdem'in cümlesinin tam kapsamıdır, fazlası değil.
- Neden 0,25: öteki alanlar Çekirdek'in bir çeyrek basamak ötesine taşıyabilsin; sektör vurgusu hissedilsin ama zayıf
  Çekirdek'i örtmesin. Pay büyüdükçe B, A'ya yaklaşır.

**Ağırlıklar** [ÇALIŞMA]: Çekirdek 0,50 · vurgu 1 0,25 · vurgu 2 0,15 · kalan 0,10.
- Neden Çekirdek yarısı: alanların hat sayısı eşit değil (Çekirdek 5 hat, Güven 2, Entegrasyonlar 1, Onboarding 1; R11
  §6.3). Tek hatlı alanda bir kart oranı tam basamak oynatır, Çekirdek'te beş kart gerekir. Yarım ağırlık ve tavan,
  ucuz alanla uyum "satın almayı" sınırlar.

### 2.6 Ölçüt: çekirdeği zayıf ürün güveni iyi diye satılamaz
Sayısal örnek (`python -I`, U = 70 × uyum, 100'de kesik; parantezde A biçimi; yuvarlama Godot'nun `round`'u gibi yarım
yukarı, inceleme: P1 inşaat 80,5 → 81, taslakta Python yuvarlamasıyla 80):

| Ürün (Çekirdek · Onboarding · Entegrasyonlar · Güven oranı) | Finans | Lojistik | İnşaat |
|---|---|---|---|
| P1 güçlü Çekirdek, Entegrasyonlar yok (1,5 · 1 · 0 · 1) | 77 (77) | 70 (70) | 81 (81) |
| P2 zayıf Çekirdek, Güven ve Entegrasyonlar güçlü (0,4 · 1 · 1,5 · 1,5) | 46 (63) | 46 (63) | 46 (58) |
| P3 Çekirdek beklentide, Onboarding yok (1 · 0 · 1,5 · 1) | 68 (68) | 72 (72) | 56 (56) |

- İmza için gereken (C v3 §5.4: eşik + 10): 2★ finans ve lojistik 43, 2★ inşaat 45,5, 3★ 46 ile 48,5.
- P2'yi 3★ hesap yalnız hiç açık hata yokken ve sınırda alır, 2★ hesap da sınırda; A biçiminde herkes rahatça alırdı. Çekirdek 0,2'de (P4) U 32 olur,
  kimse almaz (A'da 60).
- Sektör farkı yalnız Çekirdek tamamken görünür: P1'i inşaat sever (Onboarding vurgusu), lojistik daha az (Entegrasyonlar
  vurgusu); P3'ü tersine.

---

## 3. Ürün uyumu U (sözleşme)

### 3.1 Alan oranı
- r_a = min(seviye_a ÷ beklenti_a, 1,5) [ÇALIŞMA], yalnız beklentisi 0'dan büyük alanlar için.
- Seviye bugünkü tanımdır: alandaki hatların kademe ortalaması ve cila (`sprint_catalog.gd:644-651`). Ekonomi
  yuvarlanmamış seviyeyi okur; ekran yarıma yuvarlanmışı ve kelimeyi gösterir.
- Neden 1,5'te kesik: bir alana aşırı yatırım sınırsız getirmesin (R8 §2.3; X §6.1).

### 3.2 Pazar beklentisi
Bugün her alanda evre 1'de 1, evre 2 ve 3'te 2; alanda son 6 haftada çıkış yapan rakip başına +0,5, en çok +1; alanın
tavanını aşmaz (`sprint.json:30-33`, `sprint_catalog.gd:117-125`). Bugünkü tabloyla MVP (Çekirdek'in 5 hattından 3'ü K1, seviye
0,6) Bootstrap'ta "Zayıf" okunur ve U 21 çıkar; hiçbir hesap imza kapısını geçemez (X §9'un uyarısı).

Öneri [ÇALIŞMA]:

| Evre | Çekirdek | Öteki alanlar |
|---|---|---|
| Bootstrap | MVP seviyesi (`mvp_lines` ÷ Çekirdek hat sayısı; ERP'de 0,6) | beklenmez |
| Traction | 1 | 0,5 |
| Series A Hunt | 1,5 | 1 |

- Rakip çıkışı bugünkü kuralla kalır (+0,5, en çok +1, 6 hafta), ama yalnız **aday** bağlamında (§3.3).
- Evre geçişinde aday bağlamının beklentisi 8 haftada doğrusal yükselir. Neden: R9 gözlem 3, beklentinin tek haftada
  zıplaması 47 puanlık uçurum üretti.
- (inceleme) Beklentisi 0'dan açılan alan (Bootstrap → Traction'da Onboarding, Entegrasyonlar, Güven) için beklentiyi
  rampalamak işe yaramaz: oran seviye ÷ beklentidir, seviye 0 ise oran her beklentide 0'dır. Bu alanlarda rampa alanın
  ağırlığına uygulanır: ağırlık 8 haftada 0'dan tam değerine çıkar (öneri, ölçülmedi; simülasyon bu alanları rampasız
  aldı, `MEMNUNIYET_SIM.md` §7 yorum 4).
- Beklenmeyen alan (beklenti 0) U'ya girmez; ağırlığı öteki alanlara oranla dağılır. Ekranda o alan "Henüz beklenmiyor"
  yazar.
- Neden bu tablo: Bootstrap'ın ürünü MVP'dir ve pazar ondan fazlasını beklememelidir; aksi hâlde ilk müşteriler imzadan
  önce kaybedilir. Traction "Çekirdek tam, öteki alanlar başlamış" ister. Series A "Çekirdek derin, öteki alanlar yerinde"
  ister. Tek hatlı alanlarda 0,5 beklenti tek kartla karşılanır (R11 §6.3), iki hatlı Güven'de bir hat yeter.

### 3.3 Bağlam
U iki bağlamda okunur:
- **Hesap:** beklenti, hesabın referansıdır (`market_ref`: imzada, sonra her yenileme dönemi açılışında bugünkü değerin
  kopyası; rakip etkisi yok). Neden: sözleşmeli müşteri pazarla kıyaslamayı yenileme masasında yapar (R7 §2.2); arada
  pazarın yükselişi bu hesabın memnuniyetini düşürmez (Erdem'in "durup dururken düşmesin" kuralı).
- **Aday:** bugünkü beklenti, rakip çıkışı ve evre rampası dahil. Satış görüşmesi, imza kapısı, aday yıldız karışımı ve
  yatırımcı okur.
- Hesap bağlamında bir de **pazar değeri** döner: aynı hesabın bugünkü beklentiyle U'su. C bunu "yenilemede bu okunur"
  satırında gösterir.

### 3.4 Formül
```
m     = Σ w_a × r_a ÷ Σ w_a          (yalnız beklenen alanlar; w sektör tablosundan, §2.4-2.5)
uyum  = min(m, r_Çekirdek + 0,25)
U     = min(100, yuvarla(70 × uyum))
```
- B2B ağırlıkları §2.5. B2C: Çekirdek 0,50; Onboarding & Erişim, Büyüme, Güven & Ölçek kalanı eşit böler; Gelir girmez.
- 70 = her beklenen alan tam beklentide. Neden 70: Erdem'in "yeni müşteri %70'lerden başlasın" isteği, beklentiyi
  karşılayan üründe gerçek değer olarak tutar; sabit bir başlangıç ya da taban gerekmez (C v3 §5.4).

### 3.5 Dönen değer
`ProductQuality.fit(bağlam) -> Dictionary`:

| Alan | Tür | Anlam |
|---|---|---|
| `value` | int, 0-100 | U |
| `market_value` | int, 0-100 | yalnız hesap bağlamında: bugünkü beklentiyle U |
| `label_key` | String | "Ürün uyumu" metin anahtarı (C'nin ipucu bunu yazar, kendi sabitlemez) |
| `note` | Array | en çok iki {alan, kelime}: Çekirdek ve en zayıf vurgu alanı |
| `capped` | bool | tavan devrede mi (Çekirdek uyumu sınırlıyor) |
| `weakest_emphasis` | String | vurgu alanlarından oranı en düşük olanın kimliği |

Bağlam: {`sector`, `market_ref` (aday için boş), `rivals`: bool}.

**Ne zaman değişir:**
- Alan seviyesi değişince: sprint kapanışında yayına giren kademe ya da cila (sürüm).
- Hesap bağlamında: `market_ref` değişince (imza, yenileme dönemi açılışı).
- Aday bağlamında ayrıca: evre rampası ve rakip penceresi.
- Hata, kesinti, söz U'yu değiştirmez; onlar C'nin terimleridir.

**Aralık ve uçlar:** MVP Bootstrap'ta 70 (yalnız Çekirdek beklenir, oran 1). Çekirdek oranı 0 ise U en çok 17,5. Uyum
1,43'ü geçince U 100'de kesilir (örnek: bütün alanlar 1,5'te).

**(inceleme) Doyum ölçüldü.** `MEMNUNIYET_SIM.md` §2.9: botun ürünüyle imzaların %75'inde U = 100 (evre 2'de ortanca 100,
evre 3'te p10 96). İki neden: (1) Bootstrap'ta imzalayan hesabın referansı MVP'dir (Çekirdek 0,6); Çekirdek 0,9'a çıkınca
oran 1,5'te kesilir ve U yenilemeye kadar 100 kalır; (2) Traction beklentisi (1 / 0,5) botun 30. haftadaki ürününün çok
altında (Çekirdek 1,5, Entegrasyonlar 3, Güven 2). Sonuç: bakımlı üründe memnuniyet 91 ile 96, yenileme tutumunun %100'ü
"Zamma açık" (§8'in kapısı ve Erdem'e soru 5). Formül değişmez; beklenti tablosu Q6'da bot ürününe göre kalibre edilir.

### 3.6 Ölçek
Formül yalnız oran okur. Ekip 1 ya da 50 kişi, 6 ya da 330 hesap: değişmez. Uç bileşimler (hepsi testçi, PM'siz, aynı rolde
10 kişi) bu katmanda görünmez, çünkü U yalnız yayındaki kademeye bakar; onlar D'nin konusudur. 50 kişilik ekip bütün
alanları üst kademeye çıkarınca U doyar (100 ya da beklenti tavanda iken 70); yeni kademe içeriği EA'nın konusu (X §9).

---

## 4. Oyuncuya gösterim
Sayı yerine söz; sektör satırı her hesapta ve adayda aynı cümledir. Metin TR ve EN, tiresiz; `{sector}` ve `{area}` ek
almaz (CLAUDE.md §5).

| Yer | TR | EN |
|---|---|---|
| Aday kartı ve hesap ipucu | `{sector} hesapları önce Çekirdek'e, sonra en çok {area} alanına bakar.` | `{sector} accounts look at Core first, then mostly at {area}.` |
| En zayıf vurgu | `Bu hesap için en zayıf yer: {area} ({word}).` | `Weakest spot for this account: {area} ({word}).` |
| Tavan devredeyken | `Çekirdek zayıfken öteki alanlar ürün uyumunu yukarı taşıyamaz.` | `While Core is weak, the other areas cannot lift product fit.` |
| Güven & Ölçek, uyum kaygılı sektör | `Sağlık hesapları verinin korunmasına bakar.` | `Healthcare accounts care about keeping data safe.` |
| Güven & Ölçek, yük kaygılı sektör | `E-ticaret hesapları yoğun saatte ayakta kalmaya bakar.` | `E-commerce accounts care about staying up at peak hours.` |
| Beklenmeyen alan (Bootstrap) | `Henüz beklenmiyor` | `Not expected yet` |
| Satış görüşmesi zar ipucu | `Ürün uyumu 46 · Çekirdek Zayıf` | `Product fit 46 · Core Weak` |

Neden sektör cümlesi: oyuncu "bu hesap neden böyle" sorusunu sektörün adıyla cevaplar (R11 §9 madde 8); aynı cümle satış
görüşmesinde ve memnuniyet ipucunda durur, iki yerde tek kural.

---

## 5. Sözleşmelerin güncel hâli (X §8)

### 5.1 Ürün durumu satırları (X §8.1, C'nin Genel Bakış Sürüm bloğu)
- Her satır: alan adı, kelime (Yok, Zayıf, Yeterli, Güçlü ya da Henüz beklenmiyor), ton, kısa neden cümlesi, kareler.
- Kareler 0-10; beşinci kare beklentidir; kare = yuvarla(5 × seviye ÷ beklenti), en çok 10. Ekonominin okuduğu oran 1,5'te
  kesildiği için 8. kareden sonrası soluk çizilir; ipucu "Fazlası uyuma eklenmez" / "Anything above this adds no fit" der.
  Görünen ile hesaplanan böylece aynı kalır.
- Kelime ve kare **pazarın bugünkü beklentisiyle** çizilir (aday bağlamı, rakip dahil). Hesabın kendi referansı yalnız onun
  ipucundadır.
- Ayrı ve tek satır: `Kararlılık · 7 açık hata ▲2 · son 4 haftada 1 kesinti` (Q2).
- Bir "en zayıf yer" cümlesi: en çok hesabın (aylık gelire göre) vurguladığı zayıf alan. Örnek: `En zayıf yer Entegrasyonlar.
  Lojistik ve sigorta hesapları (aylık $14.200) buna ayrıca bakıyor.` / `The weakest spot is Integrations. Logistics and
  insurance accounts ($14,200 a month) look at it too.`
- Satır sayısı pazara göre 3 ile 5 arası; C sabit varsaymaz.

### 5.2 Ürün uyumu terimi (X §8.2, C'nin memnuniyet ipucu)
- Hesap başına kalite terimi tek fonksiyondan gelir: `ProductQuality.fit` (§3.5). C'nin memnuniyet terim listesinin ilk
  elemanıdır; etiket ve not buradan gelir.
- U başlangıç ya da taban değildir; memnuniyetin bir terimidir. İmza değeri C'nin toplamıdır (C v3 §5.4).

### 5.3 İş profili (X §8.3, D'nin aşama payı)
Değişmedi. Her hattın veride bir iş profili alanı olur (tasarım, geliştirme ya da test ağırlıklı); D bunu okur. Başlangıç
değerleri bugünkü eksen eşlemesinden bir kez kopyalanır (Deneyim → tasarım, İnovasyon → geliştirme, Kararlılık → test), sonra
eksen alanları silinir. Ar-Ge "Tasarım sistemi" indirimi de bu alanı okur.

### 5.4 Dokunulmayacaklar
Yeni oyuncu metnine eksen adı yazılmaz. `QualityModel` ve `mvp_*` bayrakları yeni kodda okunmaz.

---

## 6. Okuyucular (X §6.5'in güncel hâli)
| Bugün | Kalite fazından sonra |
|---|---|
| B2B memnuniyet hedefi (gizli Kararlılık, `b2b_sales_system.gd:140-153`) | U, hesap bağlamı; C v3 §5 (C3a dilimi) |
| B2B imza memnuniyeti (eksen tohumu, `sales_system.gd:415-419`) | C'nin toplamı ve imza kapısı (C3b) |
| Açık hatanın etkilediği hesaplar (eksen üyeliği ≥ 0,25, `sales_archetypes.gd:141`) | alan ağırlığı × hat başına yoğunluk (C v3 §5.2) |
| Satış görüşmesi ürün uyumu (`sales_meeting_system.gd:134-141`) | adayın U'su |
| Kayıp nedeni "Kararlılık" (< 40) ve kapısı (≥ 55) (`sales_meeting_system.gd:338`, `sales_ledger.gd:338`) | imza kapısı ve en zayıf vurgu alanı: `Entegrasyonlar sizde henüz zayıf. O taraf güçlenince yeniden konuşalım.` |
| Aday yıldız karışımı (`sales_faucet_system.gd:166-174`) | pazarın ortalama U'su (aday bağlamı) |
| VC sorusu ve yatırım masası (`vc_pitch_system.gd:1329-1338`, `term_sheet_table_system.gd:548`) | en zayıf alan Zayıf ya da Yok ise o alanın adı |
| B2C kitle büyümesi ve aşınma (`sales_system.gd:177`, `:202`) | B2C U; rakip baskısı beklentiden gelir |
| B2C memnuniyeti (Deneyim ekseni, `sales_system.gd:423-433`) | B2C U'nun Çekirdek ve Onboarding kısmı; kayma C'nin ilkesiyle kalkar |
| Ürün değeri, fiyat önerisi (`sales_system.gd:441`) | B2C U |
| Taban merdiveni (`product_read.gd:116-136`) | alan oranı 0,6 altı uyarı, 0,4 altında 4 hafta kayıp [ÇALIŞMA] |
| "Kararlılık < 10" kapıları (`password_rule.json:82`, `launch_leak.json:39`) | Güven & Ölçek seviyesi 0 |
| B2B istek alanı (`sprint.json:55`, `sprint_bridges.gd:32-39`) | sektörün vurgu 1 alanı |
| Ar-Ge Tasarım sistemi (`sprint_catalog.gd:190`) | iş profili |
| Ölü parçalar: gerçekleşme damgası, kapı üstü bonusu, rakip sıralaması (X §2.1) | silinir |

---

## 7. Ölçek ve uç durumlar
| Kadro ya da durum | Ne değişir | Neden kırılmaz |
|---|---|---|
| 1 kişi | Sprintte 1-2 kart; Bootstrap'ta yalnız Çekirdek beklenir | U MVP'de 70 |
| 3-12 kişi | Öteki alanlar ilerler | Oran; beklenti evreyle yükselir |
| 25-50 kişi | Kademeler tavana yaklaşır | Oran 1,5'te, U 100'de kesik; tavan biçimi yalnız Çekirdek'e bakar |
| 330 hesap | Her hesap kendi sektörüyle okur | Hesap başına sabit yok; `market_ref` hesap başına tek sözlük |
| Tek hatlı alana yığılma | Entegrasyonlar tek kartla 1,5'e çıkar | Ağırlık en çok 0,25 ve tavan |
| Çekirdek'siz ürün | Öteki her şey güçlü | U en çok 17,5 |

---

## 8. Kalite fazının hacmi
| Dilim | İçerik | Saat |
|---|---|---|
| Q1 | `ProductQuality`: oran, beklenti tablosu ve rampası, bağlam, tavan, dönen değer; sektör tablosu verisi ve doğrulayıcı | 8 |
| Q2 | Okuyucuların taşınması (satış görüşmesi, aday karışımı, VC, yatırım masası, B2C büyüme ve memnuniyet, fiyat önerisi, istek alanı) | 12 |
| Q3 | Olaylar ve kapılar (taban merdiveni, iki "Kararlılık < 10" kapısı, kayıp nedeni metinleri TR ve EN) | 4 |
| Q4 | Ölü sektörler (Soru 4'ün cevabına göre ekle ya da sil) | 1,5 |
| Q5 | İş profili alanı ve eksenin veri alanlarının silinmesi; eksen zinciri ve ölü parçalar (C3a'dan sonra, çünkü B2B memnuniyeti C3a'da U'ya geçer) | 5 |
| Q6 | Bot kalibrasyonu: B2B ve B2C, A'nın sekiz düzeltme kolu; ilk ölçüm Traction geçişinde imza ve U | 10 |
| Q7 | Smoke (`endgame_smoke.gd`'deki 101 eksen satırının yerine) | 7 |
| | **Toplam** | **yaklaşık 48** |

Kapılar (Q6): MVP sonrası 26 haftada imza sayısı bugünün en az %80'i (C v3 M10); Traction geçişinden sonraki 12 haftada
aday U medyanı imza kapısının üstünde; B2C kitle eğrisi bugünkünden en çok %20 sapar; VC sorusunun "zayıf alan" cümlesi
koşu başına en çok 3 kez. (inceleme) Ek kapı: `fix_worst` kolunda imza anındaki U'nun en çok %25'i 100'dür ve evre 2
imzalarının U ortancası 70 ile 85 arasındadır [ÇALIŞMA]. Neden: U doyunca ürün kalitesi memnuniyette ayrım yapmaz, yenileme
kararı anlamını yitirir (`MEMNUNIYET_SIM.md` §2.10). Kapı tutmazsa beklenti tablosu (§3.2) Erdem'e ölçümle gider.

---

## Erdem'e sorular

1. **Sektör tablosu.** Her sektör Çekirdek'e ağır baksın ve iki alana ek ağırlık versin (§2.4): örneğin lojistik ve sigorta
   önce Entegrasyonlar'a, sonra Güven'e; finans ve sağlık önce Güven'e, sonra Entegrasyonlar'a; inşaat önce Onboarding'e.
   Kanıtı zayıf satırlar tasarım tahmini olarak işaretli. **Öneri:** evet. Alternatif: 13 sektör yerine dört aile
   (düzenleme, sistem zinciri, saha, yoğun saat).
2. **Çekirdek baskın.** Öteki alanlar ürün uyumunu Çekirdek'in en çok bir çeyrek basamak ötesine taşıyabilsin; ağırlıklar
   Çekirdek %50, birinci vurgu %25, ikinci vurgu %15, kalan %10. Çekirdeği zayıf ürün (oran 0,4) güveni ne kadar iyi olursa
   olsun 46'yı geçmez. **Öneri:** evet.
3. **Pazar beklentisi.** Bootstrap'ta yalnız Çekirdek beklensin ve MVP onu karşılasın; Traction'da Çekirdek 1, öteki alanlar
   0,5; Series A'da 1,5 ve 1. Mevcut müşteri pazarın beklentisini yalnız imzada ve yenilemede okusun; rakip çıkışı yalnız yeni
   adayın gözünde beklentiyi yükseltsin. **Öneri:** evet. Bugünkü tabloyla MVP'den sonra hiçbir müşteri imza atamaz.
4. **Ölü sektörler.** Sağlık, Tekstil ve Medya bugün hiç müşteri adayı üretmiyor. **Öneri:** üçü de satışa eklensin
   (Sağlık ve Tekstil operasyon alıcısı, Medya teknik alıcı); Sağlık'ın kanıtı en güçlü sektördür. Alternatif: silinsin.
5. (inceleme) **Pazar beklentisi botun ürününe göre düşük.** Ölçümde imzaların %75'inde ürün uyumu 100; bakımlı üründe
   memnuniyet 91 ile 96 ve her yenileme %8 zamla bitiyor. **Öneri:** Kalite fazının kalibrasyonunda beklenti tablosu, evre 2
   imzalarında ürün uyumunun ortancası 70 ile 85 arasında kalacak biçimde ayarlansın; yenileme bantları C'de yeni dağılıma
   göre kaydırılsın (`C_ICERIK_v3.md` §6).

---

## Hacim (saat)
Kalite fazı yaklaşık 48 saat (§8). C'nin memnuniyet dilimleri (C3a, C3b) bu fazdan sonra gelir ve `C_ICERIK_v3.md`'nin
hacmindedir.

---

## İnceleme notu (Opus)
Kıdemli inceleme, 17 Ekim 2026 gecesi. Tanım değişmedi; U'nun tanımı C v3 ve memnuniyet simülasyonuyla birebir aynı
(`MEMNUNIYET_SIM.md` `model.py` `fit()`: oran 1,5'te kesik, tavan payı 0,25, 70 × uyum, 100'de kesik; §2.6 tablosunun 9
hücresinin 8'i aynı, dokuzuncusu yuvarlama). Değişenler:
1. §2.6 P1 inşaat 80 → 81: oyun Godot'nun yarım yukarı yuvarlamasını kullanır.
2. §3.5 doyum notu ve §8 Q6'ya U doyum kapısı: simülasyonda imzaların %75'i U = 100 çıktı; ürün kalitesi memnuniyette
   ayrım yapmıyor ve yenileme hep zamla kapanıyor. Formül aynı kaldı; kalibrasyon beklenti tablosunun işidir.
3. Soru 5 eklendi (pazar beklentisi).
4. §3.2: 0'dan açılan alanın rampası ağırlığa uygulanır. Neden: belge sessizdi; seviye 0 iken beklentiyi rampalamak oranı
   değiştirmez ve R9'un evre uçurumu aday bağlamında geri gelirdi.
Kanıt kontrolü: §2.3 ve §2.4'teki bağlantıların hepsi R11'de geçiyor. Etiketler: "Erdem'in kararı" yalnız Q1, Q2'de;
Q3 tablosu ve tavan biçimi öneri olarak işaretli. Reddedilenlerden hiçbiri dönmedi.
