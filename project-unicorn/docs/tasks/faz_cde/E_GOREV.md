# Faz E görev yazısı · Pazaryeri (B2C'nin tek ürünü)
Önce `ORTAK.md`'yi oku. Model: Opus, yüksek. Önce `E_ARASTIRMA.md` gelir; onu oku.

**Durum:** A ve B şu an uygulanıyor. Senin planın A ile B bittikten sonra değerlendirilecek. C, D ve E bundan sonra
sırayla uygulanır.
- C: ürün penceresi, Genel Bakış, sunucu.
- D: ekip modeli.

C'nin sunucu ve Genel Bakış kararlarına dayanan her varsayımı "A/B/C varsayımı" diye işaretle.

## 1. Amaç (Erdem'in sözleriyle)
**Tur 1**
- B2C tarafı yalnız e-ticaret pazaryeri olsun: "Amazon/Trendyol gibi; tek bir mağaza değil".
- Üçüncü taraf satıcılar ve alıcılar olsun.
- İstenenler:
  - mağaza sayısı,
  - komisyon yönetimi,
  - dönen hacim,
  - ücretli katman kullanıcıları (premium payı kaliteye bağlı),
  - birden çok gelir türü.
- B2C seçilince Satış sekmesi boş kalıyor.

**Tur 2**
- "B2C'de satış sekmesinin adını pazar yeri yapmak çok mantıklı."
- "Komisyonu arttırırsak aktif mağaza sayısı ve mağazalardaki memnuniyet düşer, churn'e sebep olabilir. Ama bunların
  iyi detaylı kurgulanması lazım."
- "Aktif user 12 bin, paid user 1050 falan fena olmayabilir. Üyelik ücretini ön izlemeyle ayarlayabiliriz. Gelir kısmı
  fena değil."
- "Pazar yerinin tamamen yeniden yapılması gerekecek."

## 2. Bugünkü akış
**Ürün tipleri**
- B2C ürün tipleri bugün not uygulaması ve video uygulaması: `data/product/lines/note_tool.json`,
  `video_clip.json`.
- Paylaşılan hatlar `shared.json`.
- Alanlar `data/product/sprint.json:46-51`. B2C'ye özel `growth` ve `revenue` var; ödeme planı `cap_paid_plan`.

**B2C ekonomisi**
- `SalesSystem`:
  - `b2c_audience`, `b2c_paying_users`, `b2c_price`.
  - Tek yazar `apply_b2c_price`.
  - Kitle her oyun saatinde iki yönlü değişir.
  - MRR = ödeyen × fiyat, saatlik türetilir.
- Bunlar CLAUDE.md §6'da.

**Satış sekmesi B2C**
- `_paint_b2c` (`sales_tab.gd:259-289`) şunları gösterir: kullanıcı, ödeyen, dönüşüm, plan fiyatı, 26 haftalık eğri.
- Canlı ürün yokken sekme boş.

**Sol menü**
- Sıra `UiTokens.TABS` (`ui_tokens.gd:294-304`).
- Etiket tek anahtar `TAB_<ID>`. Pazara göre etiket için yeni anahtar gerekir.
- Satır yalnız kilitlenebilir, gizlenemez.
- `LeftTabs.tscn` sırası smoke ile kilitli (`rail_tabs_match_scene_order`).

**Geçmiş sahip kararları** (`../sprint/BRIEF.md` 1b)
- B2C yalnız pazaryeri.
- Mağaza puanı yok.
- Depo, 3PL ve dropship yok. Kargo satıcının işi (açık soru).
- Sezonluk tepeler beğenildi.
- İki taraflı geliştirme: alıcı ve satıcı.
- Birden çok gelir türü var; oyuncu odak seçer, finans raporu hissi olur.
- Ücretsiz ve ücretli katmanlar: oyuncu hangi özelliklerin ücretli olacağını seçer.
- Satış sekmesi B2C'de pazaryerinin satıcı ve alıcı tarafını yönetir.

**Eski çalışmalar** (reddedilmedi, yetersiz bulundu)
- `docs/tasks/PRD_URUN_DERINLIK.md`:
  - §3.1 pazaryeri ağacı: alıcı 5 hat, satıcı 5 hat, 4 ortak hat; `groups[]` biçimi.
  - §3.5 dört gelir türü: komisyon, üyelik, premium satıcı, öne çıkan ilan. Kurallar:
    - üyelik temel alışverişi asla kilitlemez,
    - önizleme ve Uygula,
    - "önerilen" etiketi yok,
    - tek bir gelir türü toplamın %65'ini geçmez.
  - §3.6 Paketler ekranı.
- Tur 2 tasarımı: `../sprint/T2_5b_product.md`.
  - §3B: MAĞAZALAR, ALICILAR ve GELİR. Tek sayfaya indirilecek.
  - §7: çekirdek formüller.
    - Sabitler: `SELLER_SEED` 12, `C_REF` %10, sepet ortalaması $38, F 0,41, `MEMBER_SCALE` 0,25, `S_CHURN` haftada
      %0,8.
    - Bunlar [ÇALIŞMA] değerleridir.

## 3. Hedef akış
**Oyuncu ne kurar**
- Ürünü bir pazaryeri olarak kurar. Sprintte hem alıcı hem satıcı tarafı geliştirilir.

**v1 sonrası Pazaryeri sayfası** (B2C'de Satış sekmesinin yerinde)
- **Mağazalar:** aktif, katılan ve ayrılan mağaza sayısı, mağaza memnuniyeti.
  - Komisyon önizlemeyle ayarlanır ve "Uygula" ile kesinleşir.
- **Alıcılar:** aktif alıcı, üye (ücretli) ve ücretsiz alıcı.
  - Üyelik ücreti önizlemeyle ayarlanır.
  - Üye oranı ürün kalitesine bağlıdır.
- **Gelir:**
  - komisyon, üyelik ve toplam; bu ay, geçen ay ve değişim,
  - toplam satış hacmi (GMV),
  - sepet ortalaması.

**İstekler**
- Satıcı istekleri alıcı isteklerinden ayrı yazar. İstek verisinin sahibi C'dir.

## 4. Bağlayıcı kararlar (karar defteri, Faz E)
- Satış sekmesinin adı B2C'de "Pazaryeri" olur (onaylı). Yeni anahtar ve ikon gerekir; menü sırası değişmez.
- Pazaryeri sıfırdan kurulur. Bugünkü not ve video tiplerinin ne olacağını öner: silinir mi, EA'ya mı kalır?
  - CLAUDE.md §2: GDD'de adı geçen ve bağlı olmayan kod silinmez. GDD'ye bak; gerekiyorsa sahibe soru olarak yaz.
- **Mağazalar:**
  - aktif, katılan ve ayrılan mağaza sayısı,
  - komisyon önizlemeli.
  - Komisyon artarsa mağaza girişi ve mağaza memnuniyeti düşer, mağaza kaybı (churn) olur. Kurgusu detaylı olmalı.
- **Alıcılar:**
  - aktif alıcı, üye (ücretli) ve ücretsiz alıcı,
  - üyelik ücreti önizlemeli,
  - üye oranı kaliteye bağlı.
- **Gelir:**
  - komisyon, üyelik ve toplam; bu ay, geçen ay ve değişim,
  - GMV ve sepet ortalaması.
- Satıcı istekleri ayrı tutulur.
- **Kapsam:**
  - Demo: komisyon ve üyelik.
  - EA: premium mağaza, reklam, paketler.
- **Yeniden kullanılır:**
  - eski PRD'nin pazaryeri ağacı ve gelir kuralları,
  - tur 2'nin pazaryeri bölümü.

## 5. Araştırılacaklar
**Web: `E_ARASTIRMA.md` (ayrı Sonnet ajanı yazar)**
1. **Komisyon oranları:** Pazaryerlerindeki tipik komisyon aralıkları; kategoriye göre farklar; yeni ya da küçük
   pazaryerinin başlangıç oranları. Örnekler: Trendyol, Hepsiburada, Amazon, Etsy, eBay, Mercado Libre.
2. **Komisyon artışına tepki:** Komisyon artınca satıcı kaybı, satıcıların başka platforma geçmesi ve ilan düşüşü
   için bilinen vakalar ve kaba esneklikler. Örnek: Etsy 2022 ücret artışı ve satıcı grevi.
3. **Üyelik programları:** Amazon Prime, Hepsiburada Premium, Trendyol Plus, Walmart+. Üye oranları, fiyatları ve
   üyeliğin alışveriş sıklığına etkisi. Sonuç ilkemizi doğrulamalı: üyelik temel alışverişi kilitlemez.
4. **Pazaryeri metrikleri:**
   - GMV, take rate, aktif alıcı ve satıcı, sepet ortalaması, tekrar alım oranı.
   - Erken evre pazaryerinin tipik sayıları.
   - İki taraflı soğuk başlangıç (tavuk ve yumurta) ve likidite.
5. **Yönetim ve tycoon oyunlarında pazaryeri ya da platform ekonomisi:** Örneğin Big Ambitions, Startup Company. Oyuncu
   hangi kolları çeker?

**Senin cevaplayacakların**
- **Çekirdek ekonomi modeli:**
  - mağaza girişi ve çıkışı,
  - alıcı kitlesi,
  - GMV = siparişler × sepet,
  - gelir = komisyon + üyelik.
- **Kalite bağları:** Kalite hangi sayılara bağlanır? Var olan B2C kitle modeliyle nasıl birleşir? `SalesSystem`'i mi
  genişletirsin, yeni bir sistem mi kurarsın? Gerekçesini yaz.
- **İki taraflı hat ağacı:** Hangi hatlar demo, hangileri EA? Sprint ve aşama sistemine nasıl oturur?
- **Pazaryeri sayfası** (tek sayfa, ASCII taslak):
  - komisyon önizlemesi,
  - üyelik önizlemesi,
  - v1 öncesi hâli.
- **Var olan sistemlerin pazaryeri sayılarını okuması:**
  - B'nin "Ödeme alınamıyor" ve "Yorum fırtınası" olayları,
  - A'nın etkilenen kullanıcı sayısı: E'nin kitle sayısından türetilebilsin diye bir okuma noktası sağla,
  - C'nin Genel Bakış İş özeti ve sunucu birimi.
- **Aylık gelir:** Komisyon ve üyelik aylık gelire nasıl çevrilir? Bu yalnız sayı hesabıdır. Üst bar ve Finans'taki
  MRR gösteriminin biçimi C'nindir; sen yalnız aylık gelir sayısını sağlarsın.
- **Kayıt şeması.**
- **Bot ve probe:** `full_run_b2c` koşusu (CLAUDE.md §12) pazaryeriyle nasıl uyarlanır?

## 6. Kapsam dışı
- **EA'ya kalanlar:** premium mağaza, öne çıkan ilan ve reklam, Paketler ekranı.
- **Mağaza puanı:** yok (sahip kararı).
- **Lojistik:** depo, 3PL ve dropship.
- **Diğer fazlar:** pazarlama, acil durum olaylarının yazımı (B), ürün penceresinin kâğıtları (C), ekip modeli (D).

## 7. Sınırlar
`ORTAK.md` "Fazlar arası sınırlar".
- E, sol menüdeki "Pazaryeri" adının ve sayfasının sahibidir.
- E, pazaryeri sayılarının (mağaza, alıcı, GMV) tek yazarıdır. B, C ve A bunları okur.

## 8. Çıktı
`fazlar/E_PLAN.md`, `ORTAK.md`'deki şablonla.
- Büyük iş olduğu için dilimleri iki parçaya ayır:
  1. ekonomi çekirdeği ve kayıt,
  2. sayfa ve kollar.
- Sonra ağaç ve içerik gelir.
- Her dilimin sonunda bir B2C bot koşusu ölçüm kapısı olsun.
