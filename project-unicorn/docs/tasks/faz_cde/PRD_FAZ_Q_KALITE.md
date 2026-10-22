# Faz Q · Görev · Ürün kalitesi (ekransız)
2026-10-18 · Sahip: Erdem · Güncelleme: Erdem'in 18 Ekim akşam cevabı (`ERDEM_QCD_CEVAP.md` §2.1) işlendi. Bu belge
**ne beklediğimizi** söyler: çıktı ne olmalı, oyuncu ne görmeli, C ve D neyi okuyacak, neyle kabul edilir. Nasıl
yapılacağına uygulayıcı ajan karar verir. Kod gerçekleri `main` @ `889b9b8`.

## Bu belgeyi alan ajana
- Faz Q'nun uygulama sorumlusu sensin. İşi alt ajanlarla yürütürsün; modeller §8'dedir.
- **İlk iş:** bu belgeyi ve §0'daki ekleri oku; Erdem'e adım tablonu ver (Adım | Ne | Kim | Model | Düşünme | Süre |
  Neden); onayını bekle. §8'deki tablo başlangıç noktasıdır; değiştirirsen gerekçesini yaz.
- **Erdem'e döndüğün üç yer:** adım tablosunun onayı; E1 durağı (kalibrasyon ölçümü; yıldız beklenti tablosu, satışçı
  zarı eğrisi ve B2C kitle eşikleri önerisi); son rapor (R). Bunların dışında sormadan ilerlersin.
- **İşaretler:** "(Erdem)" yazan karar onaylıdır. "onay bekliyor" yazan sabit ve kural kodda ve raporda öyle
  işaretlenir (CLAUDE.md §3). Metinler "TR/EN onay bekliyor" diye işaretlenir.
- **Sıra:** Q → C → D (görev paketi §2). C ve D ajanları senin raporun gelene kadar oyun koduna dokunmaz (§9). Erdem
  derli toplu playtest'i üç faz bitince yapar; Q oyunu bozmadan, kendi kapılarıyla kapanır.
- Bu faz ekransızdır. Yeni ekran, yeni panel, yeni düğme yazmazsın. Var olan yüzeylerde yalnız metin değişir ve gelen
  kutusuna bir mail türü eklenir (§3). Görünür kalite gösterimini C, kart sayılarını D çizer; ikisi de §2 Karar 5'teki
  sözleşmeyi okur.

## 0. Ekler ve öncelik
Ekler `docs/tasks/faz_cde/` altındadır.

| Ek | Ne işe yarar |
|---|---|
| `ERDEM_QCD_CEVAP.md` | Erdem'in 18 Ekim akşam cevabı (§1 birebir) ve onayladığı okuma (§2.1 Q). Bu turun karar kaynağı |
| `ACIK_ISLER.md` | Bu turda yapılmayacak işler (§7) |
| `KALITE_v2.md` | Tasarım girdisi: formül, sektör tablosu, okuyucular. Sonundaki "İnceleme notu (Opus)" gövdeden önce gelir |
| `X_URUN_EKSENLERI.md` | Bugünkü eksen zinciri, 16 okuyucu, C ve D sözleşmelerinin ilk hâli (§2, §6, §8) |
| `arastirma/R8_URUN_KALITESI.md`, `arastirma/R11_SEKTOR_ALAN.md` | Oyunlar kaliteyi nasıl gösteriyor; sektör kanıtı ve tavan biçiminin sayısal karşılaştırması |
| `MEMNUNIYET_SIM.md` | U doyumunun ölçümü (§2.9, §2.10), imza kapısı (§2.9) |
| `OYNANIS_HUKMU.md` | Her mekaniğin oynanış hükmü (§2.1 satır 1, 2, 3, 5), %90 kontrol listesi |
| `ERDEM_CDQ_CEVAP.md`, `ERDEM_CD_YORUM.md` | Erdem'in 17 Ekim sözleri, birebir |
| `C_ICERIK_v3.md` §5, `D_MODEL_v3.md` §3.2, §3.13 | Q'yu okuyan iki faz: memnuniyet terimi ve iş profili |

**Öncelik ve sınırlar:** Erdem'in 18 Ekim cevabı bu belgeyle çelişirse cevap, bu belge `KALITE_v2.md` ve
`OYNANIS_HUKMU.md` ile çelişirse **bu belge** geçerlidir. Bu belgedeki satır numaraları `889b9b8`'e karşı doğrulandı;
Q0 haritası yine bulur. Proje kuralları `CLAUDE.md`'de, kod haritası `docs/HARITA.md`'dedir.

**`KALITE_v2.md`'de geçersiz olanlar** (kodlanmaz)
1. **Evre tablosu, rampa ve evre duyurusu** (KALITE §3.2 ve §4'ün mail satırı). Beklenti evreye değil müşterinin
   yıldızına bağlıdır; rampa ve mail yoktur (Karar 6).
2. **Tavan cümlesi** (KALITE §4, "Çekirdek zayıfken ..."). Tavan modelde kalır, kuralı ekranda yazılmaz (Karar 4).
3. **"Son 6 haftada çıkış yapan rakip" cümlesi bugünkü kodu anlatmıyor.** Kod rakip çıkışlarını pencere uygulamadan sayar
   (`sprint_catalog.gd:119-121`); pencere yalnız cümlede vardır (`_recent_hit`, `:748-757`). Pencere Karar 6'yla eklenir.
4. **"Q5 C3a'dan sonra".** Q kendi içinde biter: B2B memnuniyet hedefi ve imza başlangıcı Q'da ürün uyumuna geçici olarak
   bağlanır (Karar 9 madde 9), eksen zinciri Q'da silinir. C bu iki yeri kendi modeliyle değiştirir.
5. **`Customer.market_ref`'in C'nin şemasında doğması** (`C_ICERIK_v3.md` §5.10). Alan Q'da, şema 18'le doğar (Karar 13).
6. **Taban merdiveninde "0,4'ün altında 4 hafta kalırsa kayıp".** Süre sayacı yok; bugünkü sıra kalır (Karar 12).
7. **Satış görüşmesi ipucundaki sayı** ("Ürün uyumu 46 · Çekirdek Zayıf"). U sayısı yazılmaz (Karar 5, hüküm satır 1).

## 1. Amaç
Erdem'in cümleleri bu fazın sebebidir:
- "deneyim kartı, inovasyon kartı, kararlılık kartı diyoruz da bunlar oyunda oyuncuya hiçbir yerde görünmüyor. Şu anda
  neyi temsil ettiğini ben bile bilmiyorum." (`ERDEM_CD_YORUM.md`)
- "çekirdek, güven ölçek, entegrasyonlar, onboarding vesaire gibi e, şeyler fena değil bence ... ürün kalitesini buna
  bağlamakta bir sakınca görmüyorum" ve "çekirdeği bok gibi olan bir ürünü sırf güven ölçeği iyi diye satamamalıyız."
  (`ERDEM_CDQ_CEVAP.md`)
- "bunu biz direkt olarak ekranda göstermek yerine ... satışçıdan bir mail gelir yani patron şu satışı kapatamadım çünkü
  işte ürünün şurasını eksik buluyorlar" ve "ilk müşteri MVP ile imzalanabilir. Evet ama ... pilot yazmadan pilot müşteri
  gibi ... Daha KOBİ gibi falan düşünmek lazım" (`ERDEM_QCD_CEVAP.md` §1)

Bugün ekonomiyi oyuncunun hiç görmediği üç eksen sürüyor (X §2.2: 16 okuyucu); sprint ekranındaki alanlar hiçbir sayıyı
değiştirmiyor (X §2.5). Bu fazdan sonra ürünün tek kalitesi **alanlar**dır ve satış, imza, yatırımcı, B2C kitle onları
okur. Her B2B sektörü önce Çekirdek'e, sonra kendi iki alanına bakar. Her müşteri büyüklüğü kadar bekler: KOBİ MVP'ye
razıdır, büyük şirket olgun ürün ister. Oyuncu zayıf alanı kuraldan değil satıştan öğrenir. C ve D bu kaliteyi tek bir
sözleşmeden okur.

Oyuncu açısından hedef (görev paketi §1): "hangi alana yatırım, hangi sektöre ve hangi büyüklükte şirkete satış" gerçek
bir karar olsun. Ürün uyumu her imzada 100'e doyarsa bu karar yoktur (hüküm §0 madde 3).

## 2. Kararlar (bağlayıcı)
Her kararın altında **Oynanışa etkisi**: oyuncunun kararı · sıklık · tek satır okunuş · angarya ya da akış riski · 1 ve 50
kişide · hüküm (`OYNANIS_HUKMU.md` §2.1). Erdem'in kararı hükmü aştığı yerde Erdem geçerlidir.

### Karar 1 · Alanlar ürünün tek kalitesidir (Erdem, Q1)
- Alanlar ve gerçek adları (`sprint.json:132-139`, `strings.csv:2900-2911`): Çekirdek / Core; Onboarding & Erişim /
  Onboarding & Access (kısa Onboarding); Entegrasyonlar / Integrations (yalnız B2B); Büyüme / Growth (yalnız B2C);
  Güven & Ölçek / Trust & Scale (kısa Güven); Gelir / Revenue (yalnız B2C, kaliteye girmez, fiyatın konusudur).
- **Onboarding alanının Türkçe adı değişir** (Erdem, 17 Ekim: "Onboarding tarafındaki önerini kabul ediyorum";
  `C_ICERIK_v2.md` §2.9): TR "İlk Kullanım ve Erişim", kısa "İlk kullanım"; Ar-Ge düğümü TR "İlk Açılış Akışı". EN ve
  iç kimlikler (`onboarding`) aynı kalır. Anahtarlar `PRODUCT_AREA_ONBOARDING`, `PRODUCT_AREA_ONBOARDING_SHORT`
  (`strings.csv:2902-2903`), `PROD_RND_NODE_ONBOARDING_FLOW` (`:586`). Q'nun yeni cümleleri alan adını `{area}` ile
  okuduğu için ad bir kez, K6'da değişir. Bu belgede "Onboarding & Erişim" iç adı anlatır. Satış'taki "Onboarding"
  etiketinin kalkması C'nindir (C8).
- İnovasyon, Kararlılık ve Deneyim eksenleri ekonomiden çıkar; eksen okuyan ekonomi satırı kalmaz (§4.1).
- Ekip becerisi kaliteyi çarpmaz; hızı ve hata ihtimalini belirler (D). Bugün de çarpmıyor: gerçekleşme damgasının canlı
  yazarı yok (`product_state.gd:96`, yalnız `main.gd:3630`), kapı üstü bonusunu çağıran yok (`line_gates.gd:132`). İkisi
  silinir. onay bekliyor (X §6.5b).
- **Oynanışa etkisi.** Karar: hangi alana kart koyacağı. Sıklık: her sprint planı. Okunuş: alan kelimesi (Yok, Zayıf,
  Yeterli, Güçlü) ve hangi büyüklükte şirkete yettiği (§3.3). Risk: yok; bugünkü "Güven Yeterli ama hesap Kararlılık
  yüzünden riskte" çelişkisi kalkar (X §2.5). 1 kişide: kurucu MVP'den sonra hangi alanı büyüteceğini kelimeden okur.
  50 kişide: aynı kelimeler, çeyrek hedefi (D) bunları okur. Hüküm: Tut (satır 1).

### Karar 2 · "Kararlılık" bir başlıktır; satırı C çizer (Erdem, Q2)
- "Kararlılık" açık hata ve kesinti satırının başlığıdır: `Kararlılık · 7 açık hata ▲2 · son 4 haftada 1 kesinti` /
  `Stability · 7 open bugs ▲2 · 1 outage in the last 4 weeks` (KALITE §1). Satırın sahibi C'dir.
- Q'nun payı temizliktir: "Kararlılık" kelimesi oyuncu metninde bu satırdan başka yerde kalmaz. Bugün kelimeyi taşıyan
  satış satırları (`strings.csv:2457`, `:2460`, `:2471`, `:2476`, `:2481`, `:2487-2489`) Karar 9'la yeniden yazılır (§3.1).
- **Oynanışa etkisi.** Karar doğurmaz, karışıklığı keser; 1 ve 50 kişide aynı. Hüküm: satır 4'ün başlık kuralı.

### Karar 3 · Sektör vurgusu ve on üç sektör (Erdem, Q1; Tekstil ve Medya satırları onay bekliyor)
- İlke (Erdem): her sektör Çekirdek'e ağır bakar; sektörün "daha ağırlıklı baktığı" alanlar yalnız ek ağırlıktır.
- **On üç sektörün hepsi satışa girer** (Erdem, 18 Ekim: "Bence tekstil medya kalabilir. ERP için konuşuyoruz."). ERP bu
  sektörlere hizmet eder. Hiçbir sektör silinmez; göç yoktur.
- Eşleme alıcı tipinden (`sales_archetypes.gd:51`, `:75`, `:99`; `sprint.json:131`) sektöre iner. Müzakere mizacı (sabır,
  hakaret payı, yıldız aralığı) alıcı tipinde kalır; tip artık alan seçmez.
- Sektör tablosu (Erdem; Tekstil ve Medya satırları KALITE §2.4'ün önerisidir, onay bekliyor; dayanaklar KALITE §2.4 ve
  R11 §5):

| Sektör | Alıcı tipi | Vurgu 1 | Vurgu 2 | Kalan | Kanıt |
|---|---|---|---|---|---|
| Sağlık (satışa girer) | ops_cautious | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta (HIPAA) |
| Finans | tech_exacting | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta (DORA) |
| Sigorta | finance_brisk | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta (Celent) |
| Hukuk | finance_brisk | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta-düşük |
| Lojistik | ops_cautious | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | orta-düşük |
| İnşaat | ops_cautious | Onboarding & Erişim | Güven & Ölçek | Entegrasyonlar | düşük-orta |
| E-ticaret | tech_exacting | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | orta-düşük |
| Perakende | finance_brisk | Güven & Ölçek | Entegrasyonlar | Onboarding & Erişim | düşük |
| Teknoloji | tech_exacting | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | düşük |
| Üretim | ops_cautious | Entegrasyonlar | Güven & Ölçek | Onboarding & Erişim | düşük [kanıtsız] |
| Emlak | finance_brisk | Onboarding & Erişim | Entegrasyonlar | Güven & Ölçek | düşük [kanıtsız] |
| Tekstil (satışa girer) | ops_cautious | Entegrasyonlar | Onboarding & Erişim | Güven & Ölçek | düşük [kanıtsız] (üretimle aynı aile, sahada ekip) |
| Medya (satışa girer) | tech_exacting | Güven & Ölçek | Onboarding & Erişim | Entegrasyonlar | düşük [kanıtsız] (yayın anında ayakta kalmak) |

- **Bugün aday üretmeyen üç sektör** (`sales_faucet_system.gd:212`; liste `b2b_constants.gd:83-85`): Sağlık, Tekstil ve
  Medya hiçbir alıcı tipinde yok; şirket havuzu (`company_catalog.gd`), ad ekleri (`sales_name_pool.gd:46-54`) ve
  metinleri (`strings.csv:669-683`, `:712-722`) zaten var. Q onları alıcı tiplerine ekler: Sağlık ve Tekstil ops_cautious,
  Medya tech_exacting. Sağlık'ın +5 tolerans payı zaten var (`b2b_constants.gd:44`).
- **İstek alanı** sektörün vurgu 1 alanıdır (bugün tipten, `sprint_bridges.gd:32`, `:39`).
- "Güven & Ölçek" iki kaygı taşır: veri ve uyum (Sağlık, Finans, Sigorta, Hukuk) ile ayakta kalma (E-ticaret, Perakende,
  Medya). Oyuncuya giden cümle sektörün kaygısını söyler (§3.2). ERP'nin yeni modülleri bu turda yok (ACIK_ISLER 11).
- **Oynanışa etkisi.** Karar: hangi sektörün adayıyla görüşmeli, hangi alanı güçlendirmeli. Sıklık: her aday kartı ve
  görüşme. Okunuş: `Lojistik hesapları önce Çekirdek'e, sonra en çok Entegrasyonlar alanına bakar.` Risk: 13 satırlık
  tablo ezber ister (R14 T06); çözümü cümlenin her aday kartında ve hesap ipucunda hep yazmasıdır (C çizer). 1 kişide:
  kurucu ilk müşterilerini cümleye bakarak seçer. 50 kişide: temsilciler satar, oyuncu Hesaplar tablosunda ve satış
  özetinde hangi sektörün ağır bastığını görür, çeyrek hedefini ona göre seçer. Hüküm: Tut; hükmün "11'e in" önerisi
  Erdem'in kararıyla düştü.

### Karar 4 · Çekirdek tavanı ve ağırlıklar; kural ekranda yazmaz (Erdem, Q2)
- B2B ağırlıkları: Çekirdek 0,50 · vurgu 1 0,25 · vurgu 2 0,15 · kalan 0,10. B2C: Çekirdek 0,50; Onboarding & Erişim,
  Büyüme ve Güven & Ölçek kalanı eşit böler; Gelir girmez.
- Tavan: uyum, Çekirdek oranının en çok **0,25** üstüne çıkabilir (R11 §7'nin B biçimi). Tavan modelin içinde kalır.
- Neden tavan: kanıt Çekirdek'i "en yüksek ağırlık" değil "giriş bileti" olarak okuyor (KALITE §2.3). Çekirdek iyi iken
  tavan hiç devreye girmez; fark yalnız Çekirdek'i geride kalan üründedir. Çekirdek oranı 0,4 olan ürün öteki alanlar ne
  kadar iyi olursa olsun 46'yı geçmez; sabit ağırlıkta 63 olurdu (KALITE §2.6).
- Neden Çekirdek yarısı: Çekirdek'in 5 hattı, Entegrasyonlar ve Onboarding'in 1, Güven'in 2 hattı var (R11 §6.3). Tek
  hatlı alanda bir kart oranı tam basamak oynatır. Yarım ağırlık ve tavan, ucuz alanla uyumu "satın almayı" sınırlar.
- **Kural ekranda yazmaz** (Erdem, 18 Ekim). Tavanı anlatan cümle hiçbir ekranda yoktur; `capped` yalnız ölçüm ve rapor
  içindir. Oyuncu zayıf alanı satıştan öğrenir: kurucunun görüşmesinde müşteri itirazını ve kayıp nedenini alanın adıyla
  söyler (Karar 9 madde 2 ve 3); satışçının kaybı mailla gelir (Karar 14). Ürün sayfasındaki sözcükler kalır.
- **Kayıp alanı:** tavan devredeyse Çekirdek'tir; değilse adayın beklediği alanlardan oranı en düşük olanıdır. Çekirdek'i
  geride bırakan oyuncu kuralı okumadan "Çekirdek tarafını eksik buldular" cümlesini duyar.
- **Oynanışa etkisi.** Karar: Çekirdek mi, ucuz vurgu alanı mı. Sıklık: her plan; kayıp anında geri bildirim. Okunuş:
  `Çekirdek tarafını eksik buldular.` Risk: tavan devredeyken öteki alana yatırım karşılıksız kalır ve "gizli formül"
  şikâyeti gelebilir (R14 T06); karşılığı her kaybın alan adı taşımasıdır, sonuç kuralı öğretir (R13 Ders 2; kapı §4.5).
  1 kişide: kurucu görüşmede "Çekirdek" itirazını duyar. 50 kişide: Çekirdek derindir, tavan sessizdir. Hüküm: Tut;
  satır 1'in "tavan kuralı tek cümle" maddesi Erdem'in kararıyla değişti: cümle yok, sonuç konuşur.

### Karar 5 · Ürün uyumu U ve sözleşme (formül Erdem, Q2; sözleşme bağlayıcı)
**Formül** (KALITE §3.4, değişmeden):
```
r_a   = min(seviye_a ÷ beklenti_a, 1,5)          yalnız beklentisi 0'dan büyük alanlar
m     = Σ w_a × r_a ÷ Σ w_a                      w: Karar 4 ağırlıkları
uyum  = min(m, r_Çekirdek + 0,25)
U     = min(100, yuvarla(70 × uyum))              yuvarlama Godot round, yarım yukarı
```
- Seviye bugünkü tanımdır: alandaki hatların kademe ve cila ortalaması (`sprint_catalog.gd:708-716`). Ekonomi
  yuvarlanmamış seviyeyi okur; ekran yarıma yuvarlanmışı ve kelimeyi gösterir (`:111`). D'nin derinlik kartı kazancı
  seviyeye eklenir (`D_MODEL_v3.md` §3.13); Q yalnız okur.
- Beklenti adayın ya da hesabın yıldızından ve sektöründen gelir (Karar 6).
- 70, her beklenen alanın tam beklentide olduğu üründür. Erdem'in "yeni müşteri %70'lerden başlasın" isteği beklentiyi
  karşılayan üründe gerçek değer olarak tutar; sabit taban gerekmez (C v3 §5.4).
- Uçlar: MVP 1★ adayda 70. Çekirdek oranı 0 iken U en çok 18. Uyum 1,43'ü geçince U 100'de kesilir.
- Hata, kesinti ve söz U'yu değiştirmez; onlar C'nin terimleridir.

**Sözleşme** (`ProductQuality`, yeni). C ve D yalnız bunu okur; `QualityModel`'ı ve `mvp_*` bayraklarını okumaz.

| Fonksiyon | Döndürdüğü | Aralık ve not |
|---|---|---|
| `fit(ctx) -> Dictionary` | `value`, `market_value`, `match`, `capped`, `weakest_emphasis`, `loss_area`, `note`, `label_key` | `value` ve `market_value` int 0-100; `match` 0,0-1,43; `note` en çok iki {alan, kelime} (Çekirdek ve en zayıf vurgu); `weakest_emphasis` ve `loss_area` (Karar 4) alan kimliği ya da "" |
| `account_fit(c)`, `prospect_fit(p)` | `fit`'in hesap ve aday bağlamı | `market_value` yalnız hesapta dolu |
| `market_fit(star) -> int` | B2B: 13 sektörün o yıldızdaki aday U ortalaması; B2C: kitle bağlamındaki U | 0-100 |
| `level(area) -> float` | yuvarlanmamış seviye | 0 ve üstü; kademe tavanı 3, D derinliği ekleyebilir |
| `expectation(area, ctx = {}) -> float` | ctx'in yıldızı ve sektörüyle beklenti (aday bağlamında rakip dahil); ctx boşsa ürün sayfasının referansı (Karar 6) | 0-3; 0 = bu müşteri bakmaz |
| `ratio(area, expect) -> float` | seviye ÷ beklenti | 0-1,5; beklenti 0 ise tanımsız, çağrılmaz |
| `word(area, ctx = {}) -> String` | `none`, `weak`, `enough`, `strong` | ctx boşsa ürün sayfasının referansı |
| `serves(area) -> int` | alanın beklentisini karşıladığı en büyük yıldız | 0-3; B2B; §3.3 cümlesi |
| `weights(market, sector) -> Dictionary` | Karar 4 tablosu, toplam 1 | durağan; beklentiden bağımsız |
| `emphasis(sector) -> Array` | [vurgu 1, vurgu 2] | B2C'de [] |
| `uses_area(sector, area) -> bool` | ağırlık ≥ 0,15 | Karar 10 |
| `weakest_area(ctx = {}) -> String` | beklenen alanlardan oranı en düşük ve kelimesi Zayıf ya da Yok olan | yoksa "" |
| `market_ref_for(star, sector) -> Dictionary` | {alan: beklenti}, rakipsiz | imzada ve yenileme açılışında kopyalanır (Karar 7) |
| `close_chance(p) -> float` | satışçı kapanışının ihtimali | 0-1; zayıf alan yoksa 1 (Karar 14) |
| `area_row(area) -> Dictionary` | C'nin "ürün durumu satırı": {area, word, tone, sentence, squares, faint_from} | `squares` 0-10, beşinci kare ürün sayfasının referansı; `faint_from` 8 (oran 1,5) |
| `ProductLines.work_profile(line) -> String` | `design`, `dev`, `test` | D'nin aşama payı (Karar 11) |

- `ctx`: {`market`, `sector` (B2C'de ""), `star` (B2B'de 1-3), `ref` (hesabın `market_ref`'i, aday için {}), `rivals`
  (bool), `areas` (boşsa hepsi; B2C memnuniyeti alt kümeyi kullanır)}.
- **Ne zaman değişir:** sürümde yayına giren kademe ya da cila; aday bağlamında rakip penceresi; B2C'de kitle; hesapta
  `market_ref`. Evre değişimi hiçbir şeyi değiştirmez. Önbellek varsa bu anlarda tazelenir. Metin anahtarları
  sözleşmeyle gelir (`label_key`, sektör, yıldız, itiraz ve kayıp cümlesi); C kendi metnini sabitlemez.
- **U sayısının göründüğü yer.** U sayıyla yalnız memnuniyetin bir terimi olarak görünür: hesabın memnuniyet ipucu ve
  imza maili (C). Toplamın okunması için sayı şarttır (hüküm satır 4). Satış görüşmesi, aday kartı, satışçı maili,
  yatırımcı ve olay kartları U'yu yalnız sözcük ve alan adıyla söyler (hüküm satır 1).
- **Oynanışa etkisi.** Q'nun kendisi karar yüzeyi eklemez; C ve D'nin göstereceği her sayı buradan gelir, yani görünen
  ile hesaplanan aynı kalır (paket §4 "görünmez model yok"). Hüküm: satır 1 "ekranda yalnız sözcük ve en zayıf alan".

### Karar 6 · Pazar beklentisi müşterinin büyüklüğüne bağlıdır (Erdem, Q3; sayılar onay bekliyor, E1'de kalibre edilir)
- Beklenti adayın ya da hesabın **yıldızına** bağlıdır, evreye değil. Bugünkü evre tablosu (`sprint.json:31`, evre başına
  1, 2, 2) kalkar. **Evre rampası ve evre maili yoktur.** Evre değişince hiçbir aday ya da hesabın U'su değişmez.
- **Sayıların anlamı.** Seviye alanın hatlarının kademe ve cila ortalamasıdır (`sprint_catalog.gd:708-716`), yani:
  - **1** = alanın her hattının ilk sürümü (K1) yayında;
  - **0,5** = alanın hatlarının yarısının ilk sürümü yayında (iki hatlı Güven'de bir hat);
  - **0,6** = Çekirdek'in 5 hattından 3'ünün ilk sürümü yayında; bu MVP'dir (`sprint.json:5`);
  - **1,5** = her hattın ilk sürümü yayında ve hatlar ikinci sürümün yarı yolunda (tek hatlı alanda K1 ve bir cila);
  - **2** = alanın her hattının ikinci sürümü (K2) yayında.
- **Başlangıç tablosu** (B2B; vurgu alanları sektörün iki alanıdır, Karar 3):

| Müşteri | Çekirdek | Vurgu 1 ve 2 | Kalan alan | Düz okunuş |
|---|---|---|---|---|
| 1★ KOBİ, az koltuk | 0,6 | 0 | 0 | MVP yeter; yalnız Çekirdek'in temel işine bakar |
| 2★ orta şirket | 1 | 1 ÷ alanın hat sayısı (Güven 0,5; Entegrasyonlar ve İlk kullanım 1) | 0 | Çekirdek'in her hattı ilk sürümde; iki vurgu alanında en az bir hat yayında |
| 3★ büyük şirket | 2 | 1,5 | 1 | Çekirdek olgun (her hattı ikinci sürümde); iki vurgu alanı tam; kalan alanda da ilk sürüm |

- Beklenti alanın ulaşabileceği kademeyi aşmaz (`sprint_catalog.gd:122-125`). MVP değeri `mvp_lines` ÷ Çekirdek hat
  sayısıdır. Oyuncuya "pilot" etiketi yazılmaz; 1★ aday kartında bugünkü gibi yıldızıyla görünür.
- **Kapıya hangi yıldız gelir:** bugünkü gibi evrenin karışımı (`sales_constants.gd:42-43`) ve ürünün gücü
  (`sales_faucet_system.gd:147-173`); güç artık ürünün 3★ beklentisine uyumudur (Karar 9 madde 4). Ürün büyüdükçe kapıya
  daha çok büyük şirket gelir: çıta takvimle değil oyuncunun kendi başarısıyla yükselir.
- **Rakip çıkışı yalnız aday bağlamında kalır** (karar): alana çıkış yapan rakip başına +0,5, en çok +1, son 6 hafta
  (`rival_window_weeks`, `sprint.json:34`; pencere yeni, §0 madde 3); yalnız o yıldızın zaten baktığı alana eklenir.
  Gerekçe: takvim çıtayı artık oynatmadığı için karşılanmış bir yıldızda çıtayı oynatan tek şey rakiptir; geçicidir,
  haber şeridinde adıyla duyurulur, hesaba dokunmaz. Kaldırılırsa olgun ürün 3★'ta da kalıcı olarak doyar.
- **B2C (yıldız yok):** beklenti kitlenin büyüklüğüne bağlıdır: küçük kitle 1★ satırını, büyük kitle 3★ satırını okur
  (Çekirdek dışındaki üç alan vurgu sütununu), arada kesintisiz geçer. Öneri: 1.000 kullanıcıya kadar 1★, 10.000'de 2★,
  50.000'de 3★, arası kitlenin logaritmasıyla doğrusal [onay bekliyor, §10 kalan soru 1; eşikler E1'de].
- **Ürün sayfasının referansı:** alan sözcüğü (Yok, Zayıf, Yeterli, Güçlü) B2B'de 2★ şirketin o alandaki en yüksek
  beklentisine, B2C'de bugünkü kitleninkine göre okunur; cümle alanın hangi büyüklüğe yettiğini yazar (§3.3). Neden 2★:
  Traction adaylarının yarısı 2★'dır (`sales_constants.gd:43`) ve sözcük ürün büyüdükçe kendi kendine düşmemelidir.
- **Lider ve PM önerisi, çeyrek şeridi** ürünün henüz karşılamadığı en küçük yıldızın beklentisini okur ("sıradaki
  yıldız"); beklentisi 0 olan alan bir üst yıldızın değeriyle tartılır. Öneri oyuncuyu sonraki müşteri büyüklüğüne hazırlar.
- **Oynanışa etkisi.** Karar: KOBİ'ye mi satmalı, büyük şirkete hazırlanmak için hangi alanı büyütmeli. Sıklık: her aday
  kartı ve plan. Okunuş: `Bu hâliyle 2★ şirketlere yeter. 3★ şirketler daha fazlasını ister.` Risk: eski tabloda evre
  geçişinde çıta tek haftada sıçrıyordu (R9: 47 puanlık uçurum); artık sıçrama ve duyuru maili yoktur. Akış: kesinti
  eklemez. 1 kişide: MVP biter bitmez KOBİ imzalar (Erdem: "ilk müşteri MVP ile imzalanabilir"); 2★ aday Çekirdek'in
  kalanını ister, ilk hedef budur. 50 kişide: kapıya 3★ gelir; fark vurgu derinliğinde ve rakip penceresinde oluşur.
  Hüküm: satır 3 "Güçlendir"; yeni kural her evrede değil, her yeni müşteri büyüklüğünde gelir (Erdem).

### Karar 7 · Bağlam: hesap referansı ve aday (Erdem, Q3: mevcut müşteri imzada ve yenilemede okur)
- **Hesap bağlamı:** hesabın beklentisi `market_ref`'tir: hesabın yıldızının (`Customer.scale`, değişmez) ve sektörünün
  satırı, rakipsiz. İmzada kopyalanır, her yenileme dönemi açılışında yeniden kopyalanır. Q'da açılış bugünkü istek
  penceresidir: yıldönümünden 12 hafta önce (`request.before_renewal_weeks`, `sprint.json:39`; `sprint_bridges.gd:30`,
  `:57-63`). C5 sözleşme kaydını kurunca açılış 8 hafta önceye iner (C v2 §2.6.1'in 44. haftası; §9).
- Neden kopya, yıldız değişmezken: tablo E1'de, bir güncellemede ya da EA'da değişebilir; hesap bunu yalnız yenileme
  masasında okur. Erdem'in kuralı: "Durup dururken düşüş yok" (paket §4). `market_value` aynı hesabın bugünkü tabloyla
  U'sudur; yalnız tablo değiştiyse farklıdır ve C onu yalnız fark varken gösterir (C v3 §5.6).
- **Aday bağlamı:** adayın yıldızı ve sektörüyle bugünkü beklenti, rakip penceresi dahil; görüşme, satışçı zarı ve yıldız
  karışımı okur. Yatırımcı, B2C kitle ve taban merdiveni ürün sayfasının referansını okur.
- **Oynanışa etkisi.** Karar doğurmaz, güvence verir: rakip çıkışı yeni adayı zorlaştırır, imzalı hesabı düşürmez.
  Nedensiz düşüş kapısı (§4.3) ölçer. Demoda ilk yenileme yaklaşık 53. haftadadır (hüküm §0 madde 4); kural asıl EA'da
  ısırır. Hüküm: satır 3 ve Erdem'in kuralı.

### Karar 8 · Doyum kalibrasyonu (Erdem, Q4; kapı yeni modelde, sayılar E1)
- Ölçüm: botun ürünüyle imzaların %75'inde U = 100; evre 2'de ortanca 100, evre 3'te p10 96 (`MEMNUNIYET_SIM.md` §2.9).
  Bakımlı üründe yenilemelerin %100'ü "Zamma açık" (§2.10); Erdem bunu enflasyonla normal sayar (C'nin işi).
- **Yeni modelde doyumu üç şey tutar:** her yıldız daha fazlasını ister (Karar 6); ürün büyüdükçe kapıya daha çok 3★
  gelir; rakip penceresi karşılanmış yıldızda çıtayı geçici yükseltir. Ürün 3★ adayda ancak 3★ beklentisini 1,43 katı
  aşınca doyar. **1★ tasarım gereği doyar:** Çekirdek'i bitiren ürün 1★ adayda U 100'e yakındır; karar 2★ ve 3★'tadır.
- **Kapılar (Erdem, Q4; metni aynen):** imzaların en çok %25'inde U = 100; Traction imzalarında U ortancası 70 ile 85;
  tutmazsa ölçümle Erdem'e. Rapor her kapıyı iki satırda yazar: bütün imzalar ve yalnız 2★ ile 3★. **Öngörü:** 1★ tasarım
  gereği doyduğu için bütün imzalarda kapı tutmayabilir; o zaman Erdem'in kuralı işler ve E1'de iki satır yan yana gider,
  öneri kapının 2★ ve 3★'a uygulanmasıdır. Neden: 1★'ı kapıya sokmak onu zorlaştırmaya iter, "MVP yeter"in tersi.
- Kalibrasyonun tek kolu **yıldız × alan tablosudur**; formül, ağırlıklar, tavan ve 70 sabittir. Karışımın eşikleri imza
  sayısı içindir, doyum için oynatılmaz. Tablo kademe tavanına (3) dayanıp hedefi tutturamazsa ölçüm E1'de Erdem'e gider.
- **Oynanışa etkisi.** Doyum kalırsa Big Ambitions kalıbı: satış ve yenileme kararsız (R14 T04, hüküm §0 madde 3).
  Kalibre edilmiş tabloda iyi ürün yine 70'in üstündedir; fark müşteri büyüklüğünde, sektör vurgusunda ve Çekirdek
  derinliğinde görünür. 1 kişide: KOBİ kolay, ilk zafer yakın. 50 kişide: büyük şirket derinlik ister. Hüküm: Tut,
  kalibre et (satır 1 ve 3).

### Karar 9 · Okuyucuların yeniden bağlanması (bağlayıcı; sayılar onay bekliyor)
Her okuyucu U'yu ya da alan kelimesini okur; ölçek dönüşümü gereken yerde dönüşüm yazılıdır.
1. **Satış görüşmesi ürün uyumu** (`sales_meeting_system.gd:134-142`): adayın U'su, `fit = clamp(U ÷ 70 − 1, −1, 1)`,
   ağırlık `W_PRODUCT_FIT` aynı. Seam `urun.axis_reading` yerine `urun.product_fit`; zar ipucu sayısız (§3.1).
2. **Görüşme sorusu ve itiraz.** `probe_stability_record` (`sales_probes.gd:129-138`) sektör vurgusu sorusuna döner: her
   alıcı tipi sorar, soru adayın vurgu 1 alanına göre üç biçimde yazılır, güçlü cevabın kapısı "vurgu 1 alanı Yeterli
   ya da üstü". `probe_switching_risk`'in kapısı (`:201`) "Onboarding & Erişim Yeterli ya da üstü, ya da bu adayın
   yıldızı o alana bakmıyor" olur. Adayın `loss_area`'sı doluysa müşteri görüşmede bir kez itiraz eder ve alanı adıyla
   söyler (§3.1).
3. **Kayıp nedeni ve geri dönüş kapısı** (`sales_meeting_system.gd:338-349`, `sales_ledger.gd:335-338`): `LOSS_STABILITY`
   yerine `LOSS_WEAK_AREA`, `loss_area`'nın adını taşır; kapı o alan adayın beklentisinde Yeterli olunca açılır.
   Satışçının kaybı da aynı yolu kullanır (Karar 14).
4. **Aday yıldız karışımı** (`sales_faucet_system.gd:147-173`): evrenin karışımı aynı kalır; güç = `market_fit(3) ÷ 70`
   (ürünün 3★ beklentisine uyumu). Eşikler `QUALITY_STRENGTH_LOW` 0,6 ve `QUALITY_STRENGTH_HIGH` 1,0
   (`sales_constants.gd:51-52`; bugün 1,6) [onay bekliyor, E1]: 3★ beklentisini karşılayan ürün büyük şirket payını tam
   açar. Kaybedilen pay bugünkü gibi 1★'a düşer.
5. **Aday üretimi** (`sales_faucet_system.gd:206-217`): sektör listeleri Karar 3 tablosundan; Sağlık ve Tekstil
   ops_cautious'a, Medya tech_exacting'e girer.
6. **Yatırımcı** (`vc_pitch_system.gd:1128`, `:1178-1182`, `:1264-1273`): en zayıf eksen yerine `weakest_area()`
   (ürün sayfasının referansı; yatırımcının dediği ile ürün sayfasının sözcüğü aynıdır). `VC_Q_WEAK_DIM` alan adını taşır
   (`strings.csv:1299-1300`). Yatırım masası (`term_sheet_table_system.gd:546-549`): `E_FIT_PRODUCT_DIMS` "ürün
   sayfasında hiçbir alan Zayıf ya da Yok değil" iken.
7. **B2C kitle büyümesi ve aşınma** (`sales_system.gd:176-209`): kalite terimi = B2C U × 5/7 (beklentide 50, bugünkü
   "rakiple başa baş" noktası; X §6.4). B2C U kitle bağlamındadır ve rakip penceresini okur; `_rival_relative_quality`
   (`:213-224`) ekonomiden çıkar. Kitle büyüdükçe beklenti yükselir; ürün büyümezse büyüme kendiliğinden yavaşlar.
8. **B2C memnuniyeti** (`sales_system.gd:240-244` tohum, `:429-438` hedef): hedef = `fit` yalnız Çekirdek ve Onboarding
   alanlarıyla, kitle bağlamında. Kayma bugünkü adımla kalır; hedef artık görünür alanlardan gelir. Neden: bugün Deneyim
   ekseni 4'te kaldığı için memnuniyet 25 hafta 14'te çakılı kalıyor (X §2.4). Fiyat önerisi (`:442-450`): kalite terimi
   B2C U × 5/7.
9. **B2B ara bağ (Erdem, Q5; C gelene kadar):** hedefin ürün terimi (`b2b_sales_system.gd:155-156`, gizli Kararlılık)
   hesabın U'su olur; imza başlangıcı (`sales_system.gd:421-424`) adayın U'su olur, bugünkü taban (`:373-374`) kalır.
   Kayma, hata cezası, onboarding tabanı dokunulmaz. C3a ve C3b ikisini kendi modeliyle değiştirir. Bedel: Q ile C3a
   arasında A'nın churn kapıları ölçülmez.
10. **Arketip sesi** (`strings.csv:2457`): ops_cautious satırı "Kararlılık" demez; sektör cümlesi alanı söyler.
11. Ölü okuyucu `SalesArchetypes.step_appetite` (`sales_archetypes.gd:185`; çağıran yok) ve `priorities` içindeki
    `axis_weights` silinir.
- **Oynanışa etkisi.** Görüşme, kayıp, satışçı ve yatırımcı artık oyuncunun gördüğü alanın adını söyler. Bugün
  "Kararlılık bizim için hâlâ açık bir soru" diyen müşteri oyuncuya bakacak bir yer göstermiyor (X §2.3). Akış: yeni
  kesinti yok. 1 kişide: kurucu itirazı ve kaybı alan adıyla duyar, sonraki sprinti ona göre kurar. 50 kişide: yatırımcı
  ve yıldız karışımı aynı kelimeleri okur; kadro büyüklüğü sonucu değiştirmez. Hüküm: satır 5 "Güçlendir".

### Karar 10 · Hesabın kullandığı hatlar (Erdem, Q6)
- Bugün hesap, alıcı tipinin eksen ağırlığı ≥ 0,25 olan eksenin hatlarını kullanır (`sales_archetypes.gd:34`, `:141-142`).
  Bu üyelik A'nın etkilenen hesap sayısını (`sprint_catalog.gd:386-390`), hesap hata cezasını (`b2b_sales_system.gd:171-177`),
  şikâyet kapısını (`:561`, `inbox.gd:215`) ve B'nin hesap başı bedelini (`incident_system.gd:341`, `:386`, `:433`,
  `:567`; `effects.gd:720`) besler.
- Yeni kural: hesap, sektör ağırlığı ≥ 0,15 olan alanların hatlarını kullanır: Çekirdek ve iki vurgu alanı. Kalan alanın
  hatası o hesaba yazılmaz. Eşik `USE_AREA_MIN` 0,15 (Erdem).
- C'ye not: C v3 §5.2'nin hata terimi bu üyeliği okur; kalan alanın hatası hesabın terimine girmez.
- **Oynanışa etkisi.** Düzeltme kartının "3 hesap · 140 kullanıcı" satırı sektöre göre değişmeye devam eder; oyuncu bir
  Entegrasyonlar hatasının lojistik ve sigortayı vurduğunu, emlağı vurmadığını görür. 1 kişide ve 5 hesapta fark
  küçüktür. 50 kişide ve 330 hesapta hangi hattın önce düzeltileceğini bu sayı belirler. Hüküm: satır 20 "Tut".

### Karar 11 · İş profili ve eksen verisinin silinmesi (bağlayıcı)
- Her hattın veride bir **iş profili** alanı olur: `design`, `dev` ya da `test`. Başlangıç değeri bugünkü eksenden bir kez
  kopyalanır: Deneyim → tasarım, İnovasyon → geliştirme, Kararlılık → test (X §8.3; D v3 §3.2'nin tablosu aynen kalır).
  Ar-Ge'nin gizli hatları da (`research_tree.gd:240`) profil taşır.
- Ar-Ge "Tasarım sistemi" indirimi profili okur: `sprint_catalog.gd:190` ve `product_lines.gd:386`.
- Sonra silinenler: hat ve kademe verisindeki `axis`, `axis_points`, `axis_points_secondary`; `IDENTITY_AXIS_SHAPE`
  doğrulaması (`product_lines.gd:49`, `:124-133`) profil doğrulamasına döner; `push_axes` (`sprint_bridges.gd:124-127`,
  çağıran `sprint_system.gd:1540`); `mvp_*` bayrakları (`game_state.gd:58-60`); `QualityModel`'ın ürün okuyan bütün
  fonksiyonları; `ProductCatalog.QUALITY_AXES` ve `axis_label` (`product_catalog.gd:266`, `:307`); `ProductRead.axis_reading`,
  `market_word`, `axis_floor_state` (`product_read.gd:14-33`, `:127-138`); sinyal `phase_bar_raised`'in eski anlamı ve
  evre beklentisi tablosu (`sprint.json:31`).
- **Kalanlar:** rakip modeli (`rival_registry.gd:76-98`, `rival.gd:34-37`) kendi eksenini, `QualityModel.grow` ve
  `composite_quality`'yi tutar; kapsam dışıdır (Erdem), ekonomiyi sürmez. `_migrate_15` (`save_manager.gd:862`, Deneyim
  hattı) profile `design` diye okur; eski kayıtlar açılır.
- **Oynanışa etkisi.** Oyuncu görmez; D'nin kartındaki "Tasarım 9 · Geliştirme 11 · Test 5" sayılarını hat profili
  belirler. Hüküm: satır 4 "görünmeyen sayı ekonomiyi sürmez".

### Karar 12 · Taban merdiveni ve olay kapıları (onay bekliyor)
- Merdiven eksenden alana geçer (`product_read.gd:113-138`, `:158-190`): oran < 0,6 uyarı, oran < 0,4 aşıldı; oran ürün
  sayfasının referansına göredir, beklentisi 0 olan alan sayılmaz. Okuyan dört kartın hepsi B2C'dir (`b2c_floor_signal`,
  `b2c_floor_churn`, `rival/shutdown_notice` `market: b2c`, `world/b2c_creator_feature`); merdiven B2C'de kitle bağlamını
  okur, B2B'de sinyal yaymaz. B2B'de geride kalmanın dili satış kaybıdır (Karar 14). B2C taban kartlarının gövdesi alanın
  adını söyler (§3.5).
- Sinyaller `axis_floor_warning` ve `axis_floor_crossed` (`event_bus.gd:152-153`) alan kimliği taşır. Seam'ler
  `urun.floor_innovation`, `urun.floor_stability`, `urun.floor_experience` (`seams_product.gd:99-107`) yerine
  `urun.floor_state` (en kötü alanın durumu) ve `urun.floor_area` (o alanın adı).
- "Kararlılık < 10" kapıları (`launch_leak.json:39`, `password_rule.json:82`) "Güven & Ölçek seviyesi 0" olur; seam
  `urun.trust_level`. `urun.axis_*` seam'leri (`seams_product.gd:91-96`) silinir.
- Üretilen dosyalar yeniden üretilir: `_vocabulary.md` (`--event-vocab`), sinyal manifesti, `tools/lint_v3_frozen.json`.
- **Oynanışa etkisi.** B2C taban kartı bugün "aynı zayıflık" der, adını söylemez (X §2.3); ad yazınca karar doğar: o
  alana kart koymak. Kart artık büyümenin doğal anına bağlanır ("kitlen ürününü aştı"). Sıklık bugünküyle aynı, yeni
  kesinti yok; 1 ve 50 kişide aynı. Hüküm: Risk 4 "her mekaniğin tek satır okunuşu".

### Karar 13 · Kayıt şeması 18 (bağlayıcı)
- Şema 17 → 18 (paket §4). Yeni alan: `Customer.market_ref` (Dictionary).
- Göç: aktif hesabın `market_ref`'i yükleme anında hesabın yıldızı ve sektörünün rakipsiz satırıyla doldurulur.
  `mvp_*` bayrakları ve `FLAG_TYPES` satırları düşer. Sektör göçü yoktur. Şema 15 ve 16 fikstürleri açılmaya devam eder.
- C'nin defteri 19, D'nin göçü 20 alır (§9).
- **Oynanışa etkisi.** Kayıt kaybı yok (R14 §8 madde 9). Yükleme sonrası ilk tik nedensiz düşüş yazmaz (§4.3).

### Karar 14 · Satışçının kapanışı ürün uyumuna bağlanır; kaybı mailla gelir (Erdem, Q2; eğri onay bekliyor)
- **Bugünkü kural** (`sales_rep_system.gd`): masa satıcısı kendi Satış yıldızına kadar olan adayı işler (kapı
  `band_ceiling` `:66-72`, `rep_star` `:74-75`; seçim `pick_lead_for` `:107-118`, `_outranks` `:121-132`). Plan
  açılışta damgalanır (`_start_processing` `:146-156`, `_desk_halfweeks` `:165-170`). Başlık yorumu kuralı söyler:
  "AN IN-LEAGUE DEAL ALWAYS CLOSES ... and nothing is drawn" (`:13-17`). Plan dolunca `sign_due` (`:194-208`) `_close`'u
  (`:232-245`) çağırır ve anlaşma her zaman imzalanır. Ürün kapanışa hiç girmez.
- **Yeni kural:** yıldız kapısı aynen kalır. Plan dolunca kapanış bir zar atar, yalnız adayın baktığı bir alan
  beklentinin altındayken (`loss_area` dolu); zayıf alan yoksa anlaşma bugünkü gibi kesin kapanır. Her kaybın adı vardır.
  - İhtimal `ProductQuality.close_chance`, adayın kapanış anındaki U'sundan: U ≥ 80 %95; U 70 %85; U 55 %60; U ≤ 40
    %30; arası doğrusal [onay bekliyor, E1]. Ürün plan sürerken büyürse kapanışta yeni hâli okunur.
  - Zar tohumludur (aday kimliği ve yeni tuz, koltuk zarı `_seats_for` `:252-257` gibi); yükleme sonucu değiştirmez.
  - Kaybedilen aday kurucunun kaybettiği adayla aynı yola girer (`LOSS_WEAK_AREA`, Karar 9 madde 3). Satıcı sıradaki
    adaya geçer; kaybın bedeli harcanan haftalardır.
- **Mail:** satıcıdan kurucuya (§3.4), saati durdurmaz, mesai saati kuralıyla gelir (`MessageSystem.post`). Haftada en
  çok bir kayıp maili; öbür kayıplar haftalık özete (`_tick_weekly_summary` `:271-286`) satır olur. Bugün özet yalnız
  kapanış varken gelir (`:282-283`); kayıp da artık özeti açar.
- **C'nin imza kapısıyla ilişki (çift ceza yok):** C'nin imza kapısı (C Karar 6, memnuniyet eşik + 10) sert tabandır ve
  zardan önce bakılır; kapının altındaki anlaşma zara gelmeden kaybedilir. Kapıyı geçen anlaşmada zar en az %60'tır
  [onay bekliyor]: kapı belirgin zayıflığı, zar sınırdaki ürünü karşılar. Kayıp metni iki yolda da Q'nundur; kapı açık
  hata yüzünden reddederse (`loss_area` boş) yalnız hata biçimini C ekler. Kapı ve zarın toplam kaybı bakımlı üründe imza
  denemelerinin %5 ile 20'sidir (C ile ortak). C gelene kadar zar tek başınadır. Sahibi Q'dur (K3); C'nin PRD'si buraya
  referans verir. Kurucunun görüşmesi bu zarı atmaz; kendi zarı U'yu zaten okur (madde 1).
- **Oynanışa etkisi.** Karar: zayıf alanı önce güçlendirmek mi, büyük adayı kurucu mu görüşsün. Sıklık: satışçının her
  kapanışı; mail haftada en çok bir. Okunuş: `Patron, Ege Lojistik ile anlaşamadım. Entegrasyonlar tarafını eksik
  buldular.` Risk: dayatılan şans (R14 T07); zar yalnız adı konmuş, düzeltilebilir zayıflıkta atılır; mail saati
  durdurmaz. 1 kişide: satışçı yok; kurucu itirazı görüşmede duyar. 3 ile 6 kişide: ilk kayıp maili hangi alanı
  büyüteceğini söyler. 50 kişide: kayıplar haftalık özette sektör ve alan adıyla birikir, çeyrek hedefi (D) oradan
  seçilir. Hüküm: satır 5 "Güçlendir": açıklanmış kayıp satışçı masasına da uzanır.

## 3. Oyuncu ne görecek
Q ekransızdır. Aşağıda (1) Q bitince var olan yüzeylerde değişen metinler, (2) C ve D'nin Q'dan okuyup çizeceği satırlar.
Bütün metinler TR/EN onay bekliyor; tire yok; `{sector}`, `{area}`, `{company}` ek almaz (CLAUDE.md §5). Görsel kabul §4.9.

### 3.1 Satış görüşmesi (Q değiştirir)
| Yer | TR | EN |
|---|---|---|
| Zar ipucu satırı | `Ürün uyumu · Çekirdek Zayıf` | `Product fit · Core Weak` |
| Vurgu sorusu, Güven | `Bizim için en önemli konu verinin güvende olması ve sistemin ayakta kalması. Bu tarafta neyiniz var?` | `What matters most to us is safe data and a system that stays up. What do you have there?` |
| Vurgu sorusu, Entegrasyonlar | `Bizim işimiz başka programlara bağlı. Ürününüz bizim programlarımızla konuşabiliyor mu?` | `Our work runs through other software. Can your product talk to ours?` |
| Vurgu sorusu, Onboarding | `Ekibimiz sahada ve telefonda çalışıyor. Ürününüzü ilk gün kullanabilirler mi?` | `Our team works in the field, on phones. Can they use your product on day one?` |
| İtiraz (kayıp alanı varken, görüşmede bir kez) | `Açık konuşayım, {area} tarafınız bize yetmiyor.` | `To be frank, your {area} side is not enough for us.` |
| Güçlü cevap | `{area} tarafı hazır. Size gösterebilirim.` | `The {area} side is ready. I can show you.` |
| Kabul cevabı | `{area} tarafı henüz eksik. Bugünkü hâlini olduğu gibi gösteririm.` | `The {area} side is not finished. I will show you where it stands.` |
| Kilit satırı | `{area} bunu henüz desteklemiyor.` | `{area} does not back that up yet.` |
| Kayıp nedeni | `{area} sizde henüz zayıf. O taraf güçlenince yeniden konuşalım.` | `Your {area} side is still weak. Let us talk again once it is stronger.` |
| Hafıza | `Geçen sefer {area} konuşulmuştu.` | `Last time we talked about {area}.` |
| Arketip sesi (ops_cautious) | `Ölçülü bir alıcı. Acele etmez, her rakamı tartar.` | `A measured buyer. Takes its time and weighs every number.` |

- Zar ipucunda U sayısı yazılmaz. Satırın ▲ ya da ▼ işareti bugünkü motordan gelir (`EvDice.modifier_lines`).
- Karizma cevabı bugünkü metinle kalır; "Kesintiyi" yerine "O tarafı" der: `O tarafı ben üstlenirim. Numaram sizde olur.`
  / `I will own that part myself. You will have my number.`

### 3.2 Aday kartı ve hesap ipucu (C çizer, Q yazar)
| Yer | TR | EN |
|---|---|---|
| Sektör cümlesi | `{sector} hesapları önce Çekirdek'e, sonra en çok {area} alanına bakar.` | `{sector} accounts look at Core first, then mostly at {area}.` |
| Güven, veri kaygılı sektör | `Sağlık hesapları verinin korunmasına bakar.` | `Healthcare accounts care about keeping data safe.` |
| Güven, yük kaygılı sektör | `E-ticaret hesapları yoğun saatte ayakta kalmaya bakar.` | `E-commerce accounts care about staying up at peak hours.` |
| En zayıf yer | `Bu hesap için en zayıf yer: {area} ({word}).` | `Weakest spot for this account: {area} ({word}).` |

- Aday kartı ürün uyumunun kelimesini görüşmeden önce yazar (hüküm satır 5); bu C'nin işidir, kaynak `prospect_fit`.
- Tavanı anlatan cümle yoktur (Karar 4).

### 3.3 Ürün penceresi, sprint görünümü (Q değiştirir)
- Alan sözcüğü ürün sayfasının referansına göredir (Karar 6): MVP'den hemen sonra B2B Çekirdek "Zayıf" okunur, cümle
  MVP'nin 1★'a yettiğini söyler. Alan cümlesi (`sprint_catalog.gd:152-176`) yıldız dilini kullanır:

| Durum (B2B, `serves`) | TR | EN |
|---|---|---|
| Hiçbir yıldıza yetmez | `Henüz hiçbir şirkete yetmez.` | `Not enough for any company yet.` |
| 1★ bu alana bakmaz, 2★ başlangıç ister | `1★ şirketler bu alana bakmaz. 2★ şirketler bir başlangıç ister.` | `1★ companies do not look at this area. 2★ companies want a start.` |
| `{star}`'a yeter, üstü ister | `Bu hâliyle {star}★ şirketlere yeter. {next}★ şirketler daha fazlasını ister.` | `As it stands it is enough for {star}★ companies. {next}★ companies want more.` |
| 3★'a yeter | `Bu hâliyle 3★ şirketlere de yeter.` | `As it stands it is enough even for 3★ companies.` |
| B2C, bugünkü kitleye yeter | `Bugünkü kitlene yeter.` | `Enough for your current audience.` |
| B2C, kitle aştı | `Kitlen büyüdükçe kullanıcılar bu alanda daha fazlasını ister.` | `As your audience grows, users want more here.` |

- `Henüz beklenmiyor` sözcüğü ve `not_expected` durumu yoktur. Çeyrek hedef şeridi (`product_model.gd:443`) "sıradaki
  yıldızın" beklentisine böler; sıfıra bölme olmaz. B2C'de kitle büyüdükçe sözcük kayabilir; nedenini cümle yazar.

### 3.4 Gelen kutusu: satışçının kayıp maili (Q ekler)
| Durum | TR | EN |
|---|---|---|
| Konu | `Kaçan satış: {company}` | `Lost deal: {company}` |
| Gövde | `Patron, {company} ile anlaşamadım. {area} tarafını eksik buldular. O taraf güçlenince yeniden denerim.` | `Boss, I could not close {company}. They found the {area} side lacking. I will try again once it is stronger.` |
| Haftalık özet satırı | `{company}: kaçtı, {area} eksik bulundu.` | `{company}: lost, {area} found lacking.` |

- Gönderen satıcıdır (bugünkü haftalık özet gibi). Mail karar düğmesi taşımaz, saati durdurmaz.

### 3.5 Yatırımcı ve olay kartları (Q değiştirir)
| Yer | TR | EN |
|---|---|---|
| VC sorusu (`VC_Q_WEAK_DIM`) | `"{area} tarafın zayıf. Sektörü bilen biri bunu ilk bakışta görür."` | `"Your {area} side is weak. Anyone who knows the sector sees it at a glance."` |
| VC iç ses (`_MONO`) | `En zayıf alanı bulacak.` | `They will find the weakest area.` |
| B2C taban uyarısı | `Son yorumlar hep {area} tarafına dönüyor.` | `The latest reviews keep coming back to {area}.` |

## 4. Kabul ölçütleri
Sayılar [hedef önerisi] ise E1'de kesinleşir. Hedef tutmazsa sabit sessizce değiştirilmez; ölçüm ve öneri R raporunda
"onay bekliyor" altında Erdem'e gider.

### 4.1 Tek kaynak
- `scripts/`, `data/` ve `tools/` altında `mvp_innovation`, `mvp_stability`, `mvp_experience`, `axis_reading`,
  `axis_score`, `dims_from_flags`, `shipped_normalized`, `uses_axis`, `urun.axis_`, `floor_innovation` eşleşmesi kalmaz.
  `sprint.json`'da evre başına `expectation` tablosu kalmaz.
- **İstisnalar:** rakip modeli (`rival_registry.gd`, `rival.gd`, `QualityModel.grow`, `composite_quality`); kayıt
  göçlerinin eski alan adları; şema 15 ve 16 fikstürleri. Kalan her eşleşme raporda gerekçesiyle listelenir. Eşleşmenin
  çoğu `endgame_smoke.gd` (117 satır) ve `run_probe.gd` (32 satır) içindedir; vakalar yeniden yazılır, silinmez.

### 4.2 Formül
- Smoke vakası `product_fit_table`: KALITE §2.6'nın dokuz hücresi birebir (Finans, Lojistik, İnşaat sırasıyla P1 77, 70,
  81; P2 46, 46, 46; P3 68, 72, 56) ve tavanın devrede olduğu hücrelerde `capped = true` ve `loss_area = core`.
- Uç vakalar: MVP 1★ adayda U = 70; aynı MVP 2★ adayda U < 70; Çekirdek oranı 0 iken U ≤ 18; bütün alanlar 1,5 oranda
  U = 100; beklentisi 0 olan alan U'ya girmez.
- Falsification: tavan kaldırıldığında P2 Finans 63 çıkar (vaka bunu kanıtlar ve geri alır).

### 4.3 Bağlam ve nedensiz düşüş
- Smoke vakası `fit_account_ref`: rakip çıkışı aday U'sunu düşürür, hesap U'sunu düşürmez; tablo değiştirilince hesabın
  U'su değişmez, yenileme açılışında `market_ref` güncellenir ve `market_value` ile `value` eşitlenir.
- Smoke vakası `fit_star_context`: evre geçişi hiçbir adayın ve hesabın U'sunu değiştirmez; aynı ürün 1★, 2★, 3★ adayda
  azalan U verir; B2C'de kitle eşiklerinden geçerken U haftada en çok 5 puan kayar [hedef önerisi].
- Hesap U'su yalnız sürüm haftasında ya da yenileme açılışında değişir. Bot kollarında bunun dışında hesap U'sunun
  değiştiği hafta sayısı 0.

### 4.4 Kalibrasyon (bot; E1'in girdisi)
- **Kollar:** A'nın sekiz düzeltme kolu (`full_run_fix_{none,worst,due,off}`, `full_run_b2c_fix_*`; `run_probe.gd:105-112`),
  tohum 7 ve 11, 104 hafta. Ek kol `full_run_quality_core`: lider yalnız Çekirdek kartı alır (oynanış kapısı için).
- Her imzada `PROBE FIT` satırı: hafta, evre, sektör, yıldız, kanal (kurucu ya da satışçı), U, `capped`, `loss_area`,
  satışçı zarının sonucu.
- **Kapılar:**
  - `fix_worst` kolunda imzaların en çok %25'inde U = 100 (bugün %75); satırlar bütün imzalar ve 2★ ile 3★ (Karar 8).
  - Traction imzalarında U ortancası 70 ile 85 arası (bugün 100); aynı iki satır.
  - Traction'ın ilk 12 haftasında 2★ aday U medyanı en az 48 (C'nin en seçici imza eşiği + 10; C v3 §5.4) [hedef önerisi].
  - MVP sonrası 26 haftada imza sayısı bugünün %80'i ile %120'si arası (bugün = Q0 tabanı; satışçı kayıpları dahil).
  - Satışçı zarı: `fix_worst`'te satışçı kapanışlarının %5 ile 15'i kaybedilir; `quality_core`'da en az %20 [hedef
    önerisi]. Kayıp maili haftada en çok bir.
  - B2C kitle eğrisi (104 hafta) bugünkünden en çok %20 sapar; sapma Deneyim tuzağının (X §2.4) kalkmasından ya da
    kitle beklentisinden geliyorsa nedeniyle rapora yazılır. VC "zayıf alan" cümlesi koşu başına en çok 3 kez.
- **Bilgi ölçümü (kapı değil, C'nin girdisi):** imza anında U'nun bugünkü `seed_tolerance` + 10'un altında kaldığı imza
  payı, kol ve yıldız başına. C'nin imza kapısı reddi hedefi (bakımlı üründe %5 ile 20, zarla birlikte) bu sayıdan okunur.

### 4.5 Oynanış kapıları
- **Karar var:** `full_run_quality_core` ile `full_run_fix_worst` arasında Traction'daki 2★ ve 3★ imzalarında U
  ortancası en az 10 puan farklı [hedef önerisi]. Aynı sonucu alıyorlarsa alan seçimi karar değildir (hüküm Risk 4).
- **Büyük şirket ürünle gelir:** Series A Avı'nda 3★ aday payı `fix_worst`'te `quality_core`'dakinden en az 5 puan
  yüksek [hedef önerisi].
- **Sektör hissedilir:** Traction'da aynı hafta içinde sektörlerin 2★ aday U'su arasındaki fark (en yüksek eksi en
  düşük) ortancada en az 8 puan [hedef önerisi]. Bir alan Zayıf iken onu vurgu 1 sayan sektörlerin aday U'su
  öbürlerinden ortancada en az 10 puan düşük. İmza oranı farkı (hüküm satır 2: en az 15 puan) imza kapısıyla C'de ölçülür.
- **Açıklanmış kayıp:** `fix_worst` kolunda görüşme kayıplarının en az yarısı alan adlı nedenle biter, fiyat nedeniyle
  değil [hedef önerisi]; satışçı kayıplarının hepsi alan adlı maille ya da özet satırıyla gelir. Tavan devredeyken
  kayıpların en az %80'i Çekirdek adını taşır [hedef önerisi]. Kayıp yoksa rapor bunu yazar (hüküm satır 5).
- **Akış:** Q saat durduran kesinti eklemez; kayıp maili saati durdurmaz; B2B Traction'da haftalık saat durması artmaz.
- **Görünür:** U'yu okuyan her okuyucunun kelimesi ya da alan adı bir metinde görünür (§3); tavan kuralı hiçbir oyuncu
  metninde yoktur.

### 4.6 Ölçek
- Smoke vakası `fit_scale`: aynı alan seviyeleriyle 1, 6, 50 kişi ve 1, 30, 330 hesapta U aynıdır.
- 330 hesaplı fikstürde hesap başına `account_fit` bir tikte 330 kez okunur; tik süresi bugünkünden %5'ten fazla artmaz
  (`--tick-probe=3`).
- Uç bileşim: bütün alanlar en üst kademede iken her yıldızda U = 100. 4★ ve 5★ demo dışıdır (`sales_constants.gd:45`);
  onların satırı EA'nın işidir (§7).

### 4.7 Kayıt
- Şema 17 kayıt açılır; `market_ref` dolar, `mvp_*` düşer; yükleme sonrası ilk tik hiçbir hesabın memnuniyetini
  yükleme öncesinden farklı yazmaz. Kanıt: `save_v17_*` göç vakaları.

### 4.8 Olay ve sprint kapıları
- `--event-lint`, `loc_residue`, `smoke_run.sh loc_csv_integrity`, `plausibility_run.sh` (`fails=0`), `run_gate.sh`
  (üç koşu bir sonla biter, sıfır `ERROR`). `loc_b2b_derived_keys` 13 sektörle geçer; Sağlık, Tekstil ve Medya aday üretir.
- Sprint probe (`--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1`) Q'dan önce bir kez koşulur. Karar 10'un
  üyelik değişikliği adlı uyuşmazlık listesini büyütmez; büyütürse gerekçe raporda.

### 4.9 Görsel kabul (CLAUDE.md §11)
Kareler TR, EN, renk körü paleti ve 1,25 ölçekte. Taşma, kesilme ve log hatası olmaz.
- Sprint görünümü: MVP'den hemen sonra Çekirdek sözcüğü ve yıldız cümlesi, olgun üründe 3★ cümlesi (`--product-shot`).
  Satış görüşmesi: vurgu sorusu üç biçimiyle, itiraz, kilit satırı, zar ipucu (`--meeting-shot`). Kayıp nedeni ve geri
  dönüş kapısı (`--sales-shot`). Satışçının kayıp maili ve kayıp satırlı özet (`--inbox-shot`). VC soru kartı
  (`--vc-shot`). B2C taban uyarı kartı (`--event-shot`). Gerekli fikstür yoksa yazılır ve adı HARITA'ya eklenir.

## 5. Araştırma
Yeni dış araştırma yok; R8 ve R11 yeterli. Q0 koddan önce bugünün tabanını çıkarır: §4.4 kollarının imza sayısı (kurucu
ve satışçı ayrı), yıldız karışımı, B2C kitle eğrisi (26., 52., 104. hafta; kitle eşikleri bundan), VC zayıf eksen cümlesi
sayısı; botun imza anındaki alan seviyeleri yıldız ve evre başına (p10, ortanca, p90; yıldız tablosu bundan). R11'in
düşük güvenli satırlarına arama bütçesi harcanmaz.

## 6. Bağlantılar: kopukluk olmayacak
Q0 her satırı yeni karşılığıyla listeler, Opus Q0v'de kodla doğrular. Satır numaraları `889b9b8`'e göredir.

| Okuyan ya da yazan | Bugün | Q'dan sonra | Dilim |
|---|---|---|---|
| Eksen köprüsü | `sprint_bridges.gd:124-127`, çağıran `sprint_system.gd:1540` | silinir | K7 |
| `mvp_*` bayrakları | `game_state.gd:58-60`; debug `main.gd:506-508`, `:1448-1450`, `:3625-3630` | silinir; fikstürler alan seviyesi kurar | K7 |
| Eksen hesabı | `quality_model.gd:85-110`, `:130-230`; `product_state.gd:96-104`, `:330-342` | ürün kısmı silinir; rakibin iki fonksiyonu kalır | K7 |
| Alan seviyesi ve beklenti | `sprint_catalog.gd:111-139`, `:708-716`; `sprint.json:5`, `:31-34` | `ProductQuality.level`, `expectation` (yıldız tablosu); `SprintCatalog` ona sorar | K2 |
| Rakip penceresi | `sprint_catalog.gd:117-125` (pencere yok), `:748-757` (cümlede var) | aday beklentisine pencere | K2 |
| Ürün sayfası sözcüğü ve cümlesi | `sprint_catalog.gd:128-139` (`word_for`), `:152-176`; `strings.csv:2783-2786` | 2★ referansı, yıldız cümlesi | K2 |
| Lider ve PM önerisi | `_weakest` `sprint_catalog.gd:832-847`; `quarter_goal` `:571-574`; şerit `product_model.gd:443` | sıradaki yıldız | K2 |
| Kart etkisi ve sürüm cümleleri | `sprint_catalog.gd:333`, `:368`; `sprint_bridges.gd:108`, `:154`; `product_model.gd:163` | aynı `expectation` | K2 |
| Evre değişimi | `game_state.gd:380-388` (`phase_changed`) | Q okumaz; beklenti değişmez | K2 |
| Görüşme ürün uyumu | `sales_meeting_system.gd:134-142`, `:197`; adaptör `sales_meeting_adapter.gd:31` | `urun.product_fit` | K3 |
| Görüşme soruları, itiraz | `sales_probes.gd:58-61`, `:129-138`, `:201` | vurgu sorusu, alan kapıları, itiraz satırı | K3 |
| Kayıp nedeni, kapı | `sales_meeting_system.gd:338-349`, `:355`; `sales_ledger.gd:335-338`; `sales_constants.gd:206` | `LOSS_WEAK_AREA` | K3 |
| Satışçı kapanışı | `sales_rep_system.gd:13-17`, `:194-208`, `:232-245`; koltuk zarı `:252-257` | `close_chance` zarı, kayıp yolu | K3 |
| Satışçı maili ve özeti | `sales_rep_system.gd:263-286`; `MessageSystem.post` | kayıp maili, özet satırı | K3 |
| Yıldız karışımı | `sales_faucet_system.gd:147-173`; `sales_constants.gd:42-52` | `market_fit(3)`, eşikler | K3 |
| Aday sektörü | `sales_faucet_system.gd:206-217`; `sales_archetypes.gd:51`, `:75`, `:99` | Karar 3 tablosu, 13 sektör | K3 |
| İstek alanı | `sprint.json:131`; `sprint_bridges.gd:32`, `:39` | vurgu 1 | K3 |
| Hesap üyeliği | `sales_archetypes.gd:34`, `:141-142`; `sprint_catalog.gd:386-390` | `uses_area` | K3 |
| Üyeliği okuyanlar | `b2b_sales_system.gd:171-177`, `:561`; `inbox.gd:215`; `incident_system.gd:341`, `:386`, `:433`, `:567`; `effects.gd:720`; `seams_incident.gd:32`; `seams_product.gd:166-167` | değişmeden, yeni üyelikle | K3 |
| VC | `vc_pitch_system.gd:1128`, `:1178-1182`, `:1264-1273` | `weakest_area` | K4 |
| Yatırım masası | `term_sheet_table_system.gd:546-549`, `:62-63` | ürün sayfasında Zayıf yok | K4 |
| B2C kitle | `sales_system.gd:176-224` | B2C U × 5/7, kitle bağlamı | K4 |
| B2C memnuniyeti | `sales_system.gd:240-244`, `:429-438` | Çekirdek ve Onboarding uyumu | K4 |
| Fiyat önerisi | `sales_system.gd:442-450`; çağıran `sprint_bridges.gd` `open_paid_plan` | B2C U × 5/7 | K4 |
| B2B ara bağ | `b2b_sales_system.gd:149-162`; `sales_system.gd:366-374`, `:421-424`; çağıranlar `sales_finalizer.gd:84`, `sales_rep_system.gd:237` | hesap ve aday U'su | K4 |
| Taban merdiveni | `product_read.gd:113-190`; `event_bus.gd:152-157`; `signals.gd:37-38` | alan oranı, yalnız B2C | K5 |
| Seam'ler | `seams_product.gd:91-107` | `urun.product_fit`, `urun.floor_state`, `urun.floor_area`, `urun.trust_level` | K5 |
| Kartlar | `launch_leak.json:39`; `password_rule.json:82`; `b2c_floor_signal.json:34-60`; `b2c_floor_churn.json:28-65`; `shutdown_notice.json:58-70`; `b2c_creator_feature.json:43-55` | yeni seam'ler | K5 |
| Sektör verisi | `b2b_constants.gd:43-45`, `:83-85`; `company_catalog.gd`; `sales_name_pool.gd:46-54`; `strings.csv:669-683`, `:712-722` | 13 sektör satışta; silme yok | K6 |
| Gece kesintisi | `sprint.json` `incident.outage.night_sectors` (Sağlık listede; bugün hesabı yok) | Sağlık hesabı artık gece kesintisini yaşar | K6 |
| Ar-Ge indirim | `sprint_catalog.gd:190`; `product_lines.gd:38`, `:386` | iş profili | K7 |
| Hat verisi | `data/product/lines/*.json`; `product_lines.gd:49`, `:124-133`, `:162-164`, `:244-250`, `:348-353`, `:375`, `:405-418`; `research_tree.gd:240` | profil; eksen alanları silinir | K7 |
| Kayıt | `save_manager.gd:16` (şema 17), `:862` (`_migrate_15`); `customer.gd:39` (`scale`) | şema 18, `market_ref` | K2, K7 |
| Araçlar | `run_probe.gd` (32 eksen satırı, `PRESETS` `:92-117`); `sales_probes.gd:59-61` fakt adları; `endgame_smoke.gd:6246` (sektör ve tip), eksen vakaları | `PROBE FIT`, `quality_core` kolu | K8, K9 |
| Belgeler | `HARITA.md`; `CLAUDE.md` §6; `GUNCELLEMELER.md`; `_vocabulary.md`; `EVENT_SIGNAL_MANIFEST.md` | güncellenir | K9 |

**Bilinen gerçekler**
- Rakibin `status`'u kademesinden gelir (`rival_registry.gd:108-114`); VC'nin `_rival_ahead`'i (`:1300-1305`) etkilenmez.
  `get_player_rank_in_startup_league` (`rival_registry.gd:75`) ve `ProductRead.market_word` (`product_read.gd:27`)
  çağrılmıyor; ikincisi silinir, birincisi rakip modelinindir.
- finance_brisk'in yıldız aralığı [1, 2]'dir (`sales_archetypes.gd:101`): Sigorta, Hukuk, Perakende ve Emlak 3★ aday
  üretmez; Q değiştirmez. B'nin B2C geriliği (RAPOR_B §1 madde 5) tabana dahildir; taban madde 7 commit'idir, A değil.

## 7. Kapsam dışı
- B2B memnuniyet makinesi: kayma, defter, imza kapısı, hata terimi, güncelleme yaşı, yenileme sonuçları (C). Q yalnız
  Karar 9 madde 9'daki ara bağı kurar; imza kapısının zarla sırası Karar 14'tedir.
- Genel Bakış'ın ürün durumu satırları, "Kararlılık" satırı, memnuniyet ipucu, aday kartındaki sektör cümlesi (C).
  Kartın aşama payları, derinlik kartı, çeyrek hedefinin herkese açılması (D).
- Rakip modeli ve Piyasa ekranı (Erdem: rakip ayrı ve sonra). 4★ ve 5★ müşteriler, EA'da yıldız tablosunun büyümesi (X §9).
- ACIK_ISLER: ERP modülleri (11), satış diyalogları ve görüşmenin zorluğu (2), Ar-Ge düğümleri (10). Pazaryeri ve B2C
  fiyat kolu (E); E'nin hatları da iş profili taşır.

## 8. Çalışma biçimi ve adım tablosu
**Genel kurallar** (paket §4)
- Tek klasörde, doğrudan `main` üzerinde; worktree yok; `git checkout -- <yol>` yasak. Push yalnız Erdem "push et"
  deyince, öncesinde tam smoke yok. Commit mesajı `Faz Q Kn: ...`; yalnız kendi değişikliğin. Sahipsiz editör farkı
  (`project.godot`) ve tema dosyaları commit edilmez. Erdem oyun oynarken ağır iş (bot koşusu, tam smoke) açılmaz.

**Her commit'in akışı:** Sonnet kodlar (xhigh, büyük dilimde max) → Haiku kapıları koşar ve ekranı çeker (CLAUDE.md
§11) → Opus diff'i ve kareleri inceler, düzeltme hakkı vardır → commit. Commit başına en çok bir inceleme ve bir
düzeltme turu.

**Başlama koşulu.** Q ilk fazdır; kod Erdem adım tablosunu onaylayınca başlar. Ağaçtaki sahipsiz fark (`sprint_system.gd`,
`endgame_smoke.gd`, `sprint_probe.gd`; RAPOR_B §1 madde 7) commit edilmeden Q hiçbir oyun dosyasına yazmaz ve Godot
koşturmaz: üç dosya `git status`'ta kirliyse durur, Erdem'e sorar. O sürede Q0'ın haritası ve Q0v yürür (salt okuma);
bot ve sprint probe tabanı o commit'ten sonra koşar. Q, C ve D'nin ortak dosyaları: `sales_rep_system.gd`, `sales_system.gd`,
`sales_meeting_system.gd`, `sales_ledger.gd`, `b2b_sales_system.gd`, `b2b_constants.gd`, `sales_finalizer.gd`,
`sales_constants.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`, `sprint_system.gd`, `product_lines.gd`, `product_model.gd`,
`data/product/`, `customer.gd`, `save_manager.gd`, `strings.csv`, `run_probe.gd`, `endgame_smoke.gd`. C ve D bunlara Q'nun
son commit'inden sonra yazar (§9).

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| Q0 | Bağlantı haritası (§6), §5 tabanı, sprint probe tabanı | Alt ajan | Sonnet | yüksek | 1 sa 30 dk | Kod tarama ve bot tabanı |
| Q0v | Haritanın doğrulanması | Alt ajan | Opus | yüksek | 20 dk | Kopukluk kod yazılmadan yakalanır |
| K1 | `ProductQuality`: oran, tavan, ağırlıklar, kayıp alanı, sözleşme (Karar 5); sektör verisi ve doğrulayıcısı; `product_fit_table` | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 6 sa | Çekirdek sözleşme |
| K2 | Yıldız beklenti tablosu, B2C kitle bağlamı, rakip penceresi, bağlam, `market_ref`, şema 18; `SprintCatalog`'un `ProductQuality`'ye bağlanması; ürün sayfası sözcüğü ve yıldız cümlesi; sıradaki yıldız | aynı | aynı | **max** / düşük / yüksek | 5 sa | Kayıt ve beklenti |
| K3 | Satış okuyucuları: görüşme, sorular ve itiraz, kayıp nedeni ve kapı, satışçı zarı ve kayıp maili, yıldız karışımı, aday sektörü, istek alanı, üyelik (Karar 10, 14) | aynı | aynı | **max** / düşük / yüksek | 7 sa | En çok okuyucu |
| K4 | VC ve yatırım masası; B2C kitle, memnuniyet, fiyat; B2B ara bağ | aynı | aynı | xhigh / düşük / yüksek | 4 sa | Ekonomi kayması |
| K5 | Taban merdiveni, sinyaller, seam'ler, altı kart, üretilen dosyalar | aynı | aynı | xhigh / düşük / yüksek | 3 sa | Olay motoru sözleşmesi |
| K6 | Sağlık, Tekstil ve Medya satışa girer; Onboarding alanının ve Ar-Ge düğümünün TR adı (Karar 1) | aynı | aynı | xhigh / düşük / yüksek | 1 sa 30 dk | Veri ve metin |
| K7 | İş profili; eksen verisi, eksen zinciri ve ölü parçaların silinmesi; `_migrate_15` | aynı | aynı | **max** / düşük / yüksek | 5 sa | Geniş silme |
| K8 | `PROBE FIT`, `quality_core` kolu, §4.4 ve §4.5 ölçümü | aynı | aynı | xhigh / düşük / yüksek | 6 sa | Kalibrasyon girdisi |
| E1 | **Erdem durağı:** ölçüm tabloları; yıldız tablosu, zar eğrisi, karışım eşikleri ve B2C kitle eşikleri önerisi; kapı sonuçları (bütün imzalar ve 2★ ile 3★); §10 kalan soru 1 | Ana | Opus (ana) | orta | Erdem'e bağlı | K9 bu cevaba dayanır |
| K9 | Onaylanan değerlerin uygulanması ve yeniden ölçüm; smoke vakaları (§4.2, §4.3, §4.6, §4.7); görsel kabul; belgeler | Sonnet → Haiku → Opus | aynı | xhigh / düşük / yüksek | 6 sa | Kapanış |
| R | Sonuç raporu (§9) | Ana | Opus (ana) | orta | 30 dk | C'nin ve D'nin girdisi |

Toplam yaklaşık 46 saat ajan süresi, E1 beklemesi hariç. E1 beklenirken K9'un smoke ve belge kısmı ilerleyebilir.

## 9. Aynı ağaçtaki öbür fazlarla kurallar
**Sıra ve bekleme**
- Q önce gelir. C ve D ajanları `docs/tasks/faz_cde/RAPOR_Q.md` gelene ve içindeki son commit `git log`'da görünene kadar
  oyun koduna, `localization/strings.csv`'ye ve `data/`'ya yazmaz. O sürede adım tablosu, yazım ve okuma işi yürür.
- Q kod yazarken Godot'u yalnız Q koşturur; C ve D'nin ekranlı taslakları (C0m, M) Q'nun raporundan sonra koşar.
- Raporda ❌ varsa C ve D önce Erdem'e sorar. Q oyunu bozmadan kapanır: `run_gate.sh` ve §4.8 yeşil değilse R yazılmaz.
- Playtest üç faz bitince yapılır (Erdem); Q ara playtest istemez.

**Şema**
- Q 18 alır (`market_ref`). C'nin defteri 19 (`C_ICERIK_v3.md` §5.10'daki "17 → 18" geçersizdir), D'nin göçü 20.

**C'ye devredilenler**
- Karar 9 madde 9'un ara bağı C3a ve C3b'de kalkar; C, `account_fit` ve `prospect_fit`'i kendi toplamının ilk terimi
  yapar. Karar 10'un üyeliği C'nin hata terimi için de geçerlidir. `area_row` Genel Bakış satırlarının tek kaynağıdır.
- `market_ref`'in tek yazarı Q'nun kurduğu seam'dir (CustomerRegistry üzerinden, WRITE-THROUGH LAW). Q onu imzada ve
  `SprintBridges.next_renewal_day`'in yenileme açılışında çağırır. C5 sözleşme kaydını kurunca tetikleyici o kaydın
  açılışına taşınır; seam aynı kalır, C yalnız defter satırını ekler.
- Satışçı zarı Q'nundur (Karar 14). C'nin imza kapısı aynı kapanış noktasında (`_close`, `sales_rep_system.gd:232-245`)
  zardan önce bakılır; kayıp nedeni, mail ve özet satırı Q'nun metnidir, C yalnız açık hata biçimini ekler. Kapı ile zarın
  toplam kaybı C'nin kapısıdır (bakımlı üründe imza denemelerinin %5 ile 20'si).
- A'nın churn kapıları Q ile C3a arasında ölçülmez; C3a yeniden kurar.

**D'ye devredilenler**
- `ProductLines.work_profile` D'nin aşama payının tek kaynağıdır. Derinlik kazancı `level`'a eklenir; Q oranı 1,5'te keser.
- Lider önerisi ve çeyrek şeridi "sıradaki yıldızın" beklentisini okur (Karar 6); D'nin çeyrek hedefi bunun üstüne kurulur.

**Ağaçta dikkat:** sana ait olmayan değişikliğe dokunma; `docs/tasks/faz_cde/` ve rapor dosyaları commit'lenmez.

**R raporu** (`docs/tasks/faz_cde/RAPOR_Q.md`): (1) ✅ / ⚠️ / ❌ ve kanıt; (2) onay bekleyen sabitler (yıldız tablosu,
B2C kitle eşikleri, rakip penceresi, satışçı zarı eğrisi ve kapı sonrası tabanı, yıldız karışımı eşikleri, oran kesiği,
taban eşikleri, B2C dönüşüm katsayısı, Tekstil ve Medya satırları) ve metinler; (3) commit listesi, son satır Q'nun son
kod commit'i; (4) C ve D için Karar 5 tablosunun gerçek adları ve imzaları; (5) bot preset adları ve §4.4, §4.5'i üreten
komutlar; (6) silinenler ve §4.1'in kalan eşleşmeleri.

## 10. Erdem'in cevapları (2026-10-18)
1. **Sektörler:** 13 sektör; Sağlık satışa girer, Tekstil ve Medya kalır, çünkü ERP bu sektörlere hizmet eder (Karar 3).
2. **Çekirdek tavanı:** modelde kalır, kuralı ekranda yazmaz; oyuncu zayıf alanı görüşmedeki itirazdan ve satışçının
   kayıp mailinden öğrenir (Karar 4, Karar 14).
3. **Pazar beklentisi:** evreye değil müşterinin büyüklüğüne bağlı (1★ MVP, 2★ Çekirdek'in her hattı ve vurgu
   başlangıcı, 3★ olgun ürün); evre rampası ve evre maili kalkar, "pilot" etiketi yazılmaz (Karar 6).
4. **Doyum kalibrasyonu:** onaylı; iki kapı Erdem'in metniyle ölçülür, 2★ ve 3★ satırı yanında yazılır; tutmazsa E1 (Karar 8).
5. **Q'nun B2B ara bağı:** onaylı (Karar 9 madde 9).
6. **Hatanın hangi hesabı vurduğu:** onaylı; Çekirdek ve iki vurgu alanının hataları (Karar 10).

**Kalan sorular** (E1 durağında, ölçümle birlikte sorulur)
1. **B2C'de beklenti neye bağlı?** B2C'de yıldız yok. **Öneri:** kitlenin büyüklüğüne bağlansın: 1.000 kullanıcıya kadar
   MVP yeter, kitle büyüdükçe beklenti 3★ satırına kesintisiz yükselir; eşikler E1'de. Alternatif: B2C hep 2★ satırını
   okur (MVP çıkışında kitle küçülür). *Oynanış:* B2C oyuncusu kitlesini büyüttükçe ürünü de büyütmek zorunda kalır ve
   taban kartı "kitlen ürününü aştı" anına bağlanır.
