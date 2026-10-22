# Faz C görev yazısı · Ürün sayfası (v1 sonrası) ve B2B hesaplar
Önce `ORTAK.md`'yi oku. Model: Opus, yüksek. Önce `C_ARASTIRMA.md` gelir, onu oku.

**Durum:** A ve B şu an uygulanıyor. Senin planın, A ile B bitince değerlendirilecek. A'nın tek "Açık hata" sayısını,
Hotfix'in kalkmasını ve B'nin acil durum olaylarını olmuş say. Bunlara dayanan her varsayımı "A/B varsayımı" diye
işaretle.

## 1. Amaç (Erdem'in sözleriyle)
**Tur 1:**
- v1 sonrası ürün sayfası ERP (B2B) ve e-ticaret pazaryeri (B2C) için ne gösterir, oyuncu orada ne yapar?
- Eski sayfa yüzeysel bulundu. İstenenler:
  - Sektörde gerçekten kullanılan metrikler.
  - Sekmeler pazara göre kurulsun; B2C seçilince Satış sekmesi boş kalıyor.
  - Rakip analizi: bugün Ar-Ge'de var mı, PM'in aylık analizi ne içermeli?
  - Kapasite anlaşılmadı. İsteği:
    - kalite kademeleri (ucuz, orta, kaliteli),
    - otomatik ölçekleme eşiği ya da elle ayar,
    - görünür maliyet.
  - Destek bloğu açık hataları göstersin ve Sprint'e yönlendirsin.
  - ERP'de hesap yöneticisi görünümü: hesaplar, koltuk, memnuniyet, talepler.
- "Onboarding diye bir şey ben koymayalım dedikçe inatla burada bir onboarding tanımı yapılıyor."

**Tur 2:** Yorumun tamamı `ERDEM_TUR2_YORUM.md`'de. Bu faza düşenler aşağıda.

## 2. Bugünkü akış
**Ürün penceresi**
- Başlık, SPRINT | ÇEYREK şeridi, Geçmiş, devret.
- Memnuniyet, churn, fiyat, sunucu ve destek sayacı yok (`../sprint/BRIEF.md` Adım 2).
- Eski v1 sonrası ekran `1abbb7e`'de silindi (`1abbb7e^:project-unicorn/scripts/tabs/product/detail_view.gd`,
  `capacity_block.gd`, `pricing_panel.gd`). İyi parçaları yeniden kullanılabilir.

**Sunucu** (`../sprint/T2_CONTRACT.md` 1b)
- `infra_system.gd`. Sağlayıcılar `local / cloud / enterprise`.
- Birim fiyat:
  - B2C: 1.000 kullanıcı başına 35/55/85.
  - B2B: 50 koltuk başına 30/45/70.
- Doluluk %80'de sarı, %100'de aşım. Aşımda:
  - memnuniyet günde −0,8,
  - bildirim ×1,5,
  - B2C kazanım ×0,6.
- `local` kurumsal imzayı engelliyor. Erdem'in kararı: engel değil, şart olacak.
- `adjust_capacity` oyunda çağrılmıyor. Sunucu sürümde otomatik büyüyor (`sprint_bridges.gd:119`), hiç küçülmüyor.
- Hiçbir ekran sunucuyu göstermiyor.

**Satış sekmesi**
- B2B hesap kartları; yaşam evresi çipi var: onboarding, aktif, risk, ayrılıyor, genişleme.
- B2C'de `_paint_b2c` kullanılıyor (`sales_tab.gd:259-289`).

**Veri**
- `CustomerRegistry` hesap başına şunları tutuyor:
  - koltuk,
  - memnuniyet,
  - `lifecycle_phase`,
  - `churn_countdown`,
  - `seat_price` (aylık; `b2b_constants.gd:191`).

**Yenileme**
- `customer_rep_system.gd:315-373`: müşteri temsilcisinin talep kartları (`customer.request_{complaint,feature,renewal}`).
- Yenileme masası 12 aylık sözleşmenin son iki ayı (`b2b_constants.gd:247-250`).
- İndirim kullanım sınırı `RETAIN_DISCOUNT_MAX_USES`.

**Haftalık rapor kalıbı**
- `sales_rep_system.gd:271-286`: satışçının haftalık tek raporu.
- `mail_pane.gd` `_summary` ve `_sales_report` çiziyor.
- `MessageSystem` sınırı 50.

**İstekler**
- `SprintBridges` `requests` (hesap isteği → kart).

**Rakip**
- Özellik karşılaştırması `dcf7b42`'de kaldırıldı.
- Var olanlar:
  - `rivals.json`: tür başına rakipler, sprint takvimli çıkışlar, fiyat yok.
  - `rival_hits`: beklentiyi +0,5 yükseltir.
  - Ürün alanında "Rakip: {konu}" bayrağı.
  - Piyasa penceresi ve pazar payı merdiveni (`RivalRegistry`).
  - Ar-Ge notunda rakip adları.

**"Onboarding" etiketinin geçtiği yerler**
- Satış çipi.
- "Son hafta" satırı.
- Ürün alanı adı "Onboarding & Erişim" (`PRODUCT_AREA_ONBOARDING`, `sprint.json:47`).
- Ar-Ge düğümü.
- B2B iç mekanizması `ONBOARDING_*` (`b2b_constants.gd:10-16`): kod adı kalabilir, oyuncuya görünen etiket kalkar.

**Tur 2 tasarımı**
- `../sprint/T2_5b_product.md` §2, §3A, §4, §5, §6.
- Erdem sunucu ve rakip kısmını beğenmedi. Hesap tablosunun bir kısmını düzeltti.

## 3. Hedef akış
**Ürün penceresi**
- Üç kâğıt: GENEL BAKIŞ (v1'den önce kilitli), SPRINT, ÇEYREK.
- Genel Bakış her blokta en fazla birkaç satır gösterir ve açıklama satırı taşımaz. Bloklar:
  - Sürüm ve kalite.
  - Destek: Açık hata ve en kötü hat; tıklayınca Sprint'teki düzeltme kartı açılır.
  - İstekler.
  - Sunucu: sadeleştirilmiş.
  - İş özeti: tek satır.

**Satış (B2B)**
- Hesap tablosu.
- Sözleşme yenileme akışı.

**Gelen kutusu**
- Müşteri temsilcisinin haftalık destek raporu.

## 4. Bağlayıcı kararlar (karar defteri, Faz C)
**Ürün penceresi ve sunucu**
- Üç kâğıt onaylı. Rakip bloğu, rakip analizi kararına bağlı.
- **Sunucu fazla ağır bulundu**, yeniden araştır:
  - Startup Company'nin sunucu sistemi ve diğer oyunlar.
  - Birim: kullanıcı başına mı, 1.000 kullanıcı başına mı, koltuk başına mı?
  - Doluluk ve otomatik ölçekleme gerekli mi?
- Kalite kademeleri kalır; artısı ve eksisi oyuncuya açık gösterilir.
- **Kurumsal sunucu şartı**
  - 3★ ve üstü müşteri kurumsal sunucu ister; anlaşma bu yüzden İPTAL OLMAZ.
  - Şart sözleşmeye yazılır, oyuncu imzadan sonra geçer.
  - Geçiş toplantı çıkışında ya da mailde tek tıktır. Düğme bugünkü aylık maliyeti ve artışı gösterir.

**Rakip analizi**
- Var olsun mu? Gerekçeyle cevapla.
- Tur 2 hâli yarım ve angarya bulundu ("bir kere bakarım, sonra bana ne").
- Var olacaksa oyuncu ona göre hamle yapmalı.
- Fiyat konumu (koltuk başı ortalama ya da aktif kullanıcı) fena bulunmadı. Duyum olabilir.

**ERP hesap tablosu**
- "Büyümeye açık" yok, hafta sayısı yok.
- "Onboarding" etiketi görünmez (tur 1).
- Memnuniyet eşiğin altındaysa yalnız "Ayrılabilir" ya da "Yenilemeyebilir" yazar.
- Başka bir evre etiketi (risk, ayrılıyor, genişleme) bu tek durumun yanında gerekiyorsa gerekçeyle öner. Erdem'in
  sözünün yönü: yalnız bu tek durum.
- "Onboarding" etiketi ürün ve hesap görünümünden kalkar; ürün alanı yeniden adlandırılır (tur 1 yorumu).

**Memnuniyet ipucu**
- Nedenleri gösterir: kalite, açık hata, sunucu aşımı, sözün tutulması ya da tutulmaması.

**B2B yıllık, B2C aylık gelir**
- Sektör pratiği araştırılır. Cevaplanacak sorular:
  - B2B'de satış fiyatı yıllık mı söylenmeli?
  - Üst barda ve Finans'ta MRR ile nasıl birlikte gösterilir?
  - B2C'den B2B'ye geçişte gösterim değişmeli mi, yoksa yıllık fiyat aylığa çevrilip üst barda mı gösterilmeli?
- Akış ve gösterim öner.

**Sözleşme yenileme (kurucunun müşteri görüşmesinin yerine)**
- **Hesaba bir satışçı atanmışsa:**
  1. Satışçı kurucuya mail atar: "Fiyatı artıralım mı, sabit mi tutalım?"
  2. Kurucu karar verir.
  3. Satışçı pazarlığı yürütür; sonucu satışçının yıldızı belirler.
  4. Sonuç maili gelir: "Şu fiyattan yeniledik."
- **Kimse atanmamışsa:** Kurucuya kart gelir: "Bu müşteriyle görüşmemiz gerekiyor."
- Bugünkü müşteri temsilcisi yenileme kartları bu akışla uzlaştırılır.
- Erdem burada sözü önce müşteri temsilcisi olarak söyledi, sonra **satışçı** diye düzeltti.

**Haftalık destek raporu**
- Raporu müşteri temsilcisi gönderir. Yeni bir şey yoksa rapor gelmez.
- İçerik:
  - en çok sorun çıkan hatlar (sayılarla),
  - en çok istenenler,
  - bu hafta yapılanlar,
  - yalnız gerçekten yetişemediğinde "Yetişemedim: N cevapsız" satırı.
- B2C'de en çok istenenler yorum sayısıyla gelir; satıcı istekleri ayrı yazar.
- Rapordan düzeltme kartına düğme vardır.

**Temsilci yokken**
- B2B'de hata maili gelmez; müşterinin sesi B'nin olaylarıyla gelir.
- B2C'de "Sesler" bölümünde 1–2 mağaza ya da sosyal medya alıntısı. Yerini sen öner.

**İstekler**
- B2B'de de B2C'de de yalnız müşteri temsilcisi bulunca ortaya çıkar.
- Bulunan istek karta "İstenen · 38 yorum" etiketi olarak düşer.
- Kurucunun müşteri görüşmesi yok.
- B2B'de düşük memnuniyetli müşteriyle toplantı ileride; şimdi değil.

**Ayrılma eşiği**
- B'nin erteleme bedeli ile birlikte karara bağlanır. Erdem eşiği 30 civarında istiyor. Bugün eşik hesap başına
  33, 42, 45, 51 ya da 56.
- Eşik tüm B2B ayrılmasını etkiler. Hesap tablosundaki "Ayrılabilir" de bu eşiğe bağlıdır. Önerini ve etkisini yaz;
  bot koşusuyla ayrılma oranını ölç.

## 5. Araştırılacaklar
**Web: `C_ARASTIRMA.md` (ayrı Sonnet ajanı yazar)**
1. Startup Company'nin sunucu sistemi: kiralama, kademe, kapasite, kullanıcı başına yük, kesinti, maliyet ve arayüz.
   Software Inc. ve benzer oyunlarda sunucu ve barındırma.
2. Gerçek SaaS barındırma maliyetinin birimi: kullanıcı başına, koltuk başına, istek başına. Kademeler (paylaşımlı,
   ayrılmış, kurumsal) ve kurumsal müşterinin barındırma şartları (SOC2, ayrılmış ortam, SLA).
3. B2B SaaS'ta yıllık sözleşme ile MRR ve ARR gösterimi: fiyat nasıl söylenir (yıllık peşin ya da aylık), raporlarda
   nasıl görünür, yenileme ve fiyat artışı pratikleri. Yenilemenin sahibi kimdir (account executive, account manager,
   CSM)?
4. Rakip analizi oyunlarda nasıl anlamlı yapılmış: oyuncunun karar verdiği bilgi olarak (Startup Company,
   Software Inc., Game Dev Tycoon, Big Ambitions ya da yönetim oyunlarının rakip ekranları). Gerçek PM rakip
   analizinin hangi kararı beslediği.

**Senin cevaplayacakların (kod ve tasarım)**
- Sadeleşmiş sunucu modeli:
  - kaç kademe,
  - hangi birim,
  - doluluk ve ölçekleme kalacak mı, kalacaksa en sade hâli,
  - aşımın bedeli,
  - B'nin kesinti olasılığına verdiği girdiler.
- Kurumsal sunucu şartının akışı: toplantı çıkışı, mail, tek tık, maliyet gösterimi. Şart yerine gelmezse bedeli ne?
- Hesap tablosunun sütunları ve sıralaması, memnuniyet ipucunun terimleri. Hangi veri hazır, hangisi yeni?
- Yenileme akışının bugünkü müşteri temsilcisi kartlarıyla birleşmesi. Satışçı hesaba nasıl atanır? Yıldız pazarlığı
  nasıl etkiler?
- Haftalık rapor verisinin kaynağı (A'nın hat başına sayısı, C'nin istek verisi) ve okunmamış mail yükü.
- Genel Bakış'ın yerleşimi. Var olan Ürün penceresi kâğıt yapısıyla nasıl birleşir? Onboarding'deki sekmeli kâğıtları
  örnek al.

## 6. Kapsam dışı
- Pazaryeri sekmesi ve pazaryeri ekonomisi (E). Genel Bakış'ın İş özeti satırı B2C'de E gelince dolar; o zamana kadar
  bugünkü B2C sayıları.
- Acil durum olayları (B).
- Ekip modeli (D).
- Pazarlama.
- Kurucunun müşteri görüşmesi.
- ERP modülleri ve ücretsiz deneme (EA).

## 7. Sınırlar
`ORTAK.md` "Fazlar arası sınırlar". C, ürün penceresinin üç kâğıdının ve Satış'taki ERP tablosunun sahibidir. Sol
menüdeki "Pazaryeri" E'nindir.

## 8. Çıktı
`fazlar/C_PLAN.md`, `ORTAK.md`'deki şablonla. Ekran ekran ASCII taslak ver: Genel Bakış B2B, Genel Bakış B2C, ERP
hesap tablosu, haftalık rapor maili, yenileme maili ve kartı, kurumsal sunucu geçiş düğmesi.

## 9. Erdem'in 2026-10-16 akşam eki (`ERDEM_AB_CEVAP.md`; C tazelenirken bağlayıcı)
- **Doluluk kararı açık.** `C_PLAN`'daki "doluluk tamamen kalkar" sonucu yalnız bot ölçümüne dayanıyor. Erdem bu sonucu
  onaylamadı. Kendi sözleri: "Doluluk olmalı mı olmamalı mı? Diğer oyunlarda nasıl? Doluluk olursa kesinti olasılığını
  sunucu kalitesi ve doluluk üzerinden hesaplayabiliriz, daha sağlıklı olabilir ama emin değiliz."
  - C tazelenirken bir araştırma yapılır: diğer oyunlarda doluluk ya da kapasite nasıl işliyor? Startup Company'nin
    sunucu ve kapasite yükü ayrıca incelenir.
  - "Kesinti olasılığı = kalite × doluluk" seçeneği değerlendirilir.
  - Sonuç Erdem'e soru olarak gider.
  - B, doluluğu tek bir çarpan fonksiyonundan okur. Bu fonksiyon C kararına kadar 1 döner.
- **Not ve video ürünleri silinir.** E'nin 1. sorusu kapandı. C'nin B2C ses satırları buna göre azalır.
- **Ayrılma eşiği ile hata etkisi çatışıyor.** Eşik 30 + 3× olursa A'nın hata etkisi B2B'de ayrılmayı neredeyse
  durduruyor (C incelemesinin bulgusu). Eşik değişikliği, A'nın hata cezasının yeniden ayarıyla aynı commit'te yapılır.
  Kapı:
  - A'nın `fix_none` bot kolu hesap kaybeder,
  - `fix_all` kolu kaybetmez.
