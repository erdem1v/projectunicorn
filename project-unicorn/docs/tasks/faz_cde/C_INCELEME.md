# Faz C planı · Kıdemli inceleme (Opus, 2026-10-16)
İncelenen: `C_PLAN.md`. Okunanlar: `ERDEM_TUR2_YORUM.md`, karar defteri (Faz C ve "Fazlar arası sınırlar"), `ORTAK.md`,
`C_GOREV.md`, `C_ARASTIRMA.md`, `A_PLAN.md`, `B_PLAN.md`, `B_INCELEME.md`, `D_PLAN.md`, `E_PLAN.md`. Kod `main` @
`1faeb82` üstünde doğrulandı; bot kayıtları (`scratchpad/c_runs/`) ve karşı olgu betiği yeniden koşuldu. Repoda hiçbir
dosya değişmedi. Plana yapılan her düzeltme `(inceleme)` işaretiyle duruyor; düzeltme öncesi hâl
`scratchpad/C_PLAN.before_inceleme.md`'de.

**Hüküm: düzeltmeyle hazır; iki tasarım konusu sahibin kararını bekliyor (yenileme sıklığı ve eşik ile A'nın hata
etkisinin çatışması).** Plan karar defterinin her maddesini tasarımın içinde karşılıyor, reddedilen fikirlerin hiçbiri
geri gelmemiş ("Büyümeye açık", hafta sayısı, "Onboarding" etiketi, kurucunun müşteri görüşmesi). Kod iddialarının
neredeyse hepsi doğru çıktı. Asıl sorunlar ölçekte: tablo 9 hesapla çizilmişti, bot 104. haftada 330 hesap tutuyor;
yenileme kâğıdı ikinci yıl her ay geliyor.

---

## 1. Bulgular

| # | Bulgu | Nerede | Düzeltme | Uygulandı mı |
|---|---|---|---|---|
| 1 | **Gerçek şirket ve oyunda olmayan rakip adları.** Ekol, Arkas gerçek Türk şirketleri; Mavi ve Nordica gerçek markalar. Rakip adları (Ledgerly, Kontora, Bilanço+) oyunda yok. | §2 bütün taslaklar, §2.7 | Kuzey Lojistik, Yelken Ofis, Poyraz Lojistik, Nehir Tekstil. Rakipler oyunun ERP rakipleri: Ardenna, Raketenhaus, Sumpter (`rival_catalog.gd` `NAMES.erp`, `rivals.json` 3/5/6). Eşik örnekleri yeni adların sektörüyle tutarlı. | Evet |
| 2 | Hat ve eksen adları oyundakilerle uyuşmuyordu: "Faturalama" (oyunda Fatura), "Senkron" (Eşitleme), "Yenilik" (İnovasyon). Genel Bakış'taki hat satırı A'nın biçiminde değildi (B2B'de kullanıcı sayısı satırda, A'da ipucunda). | §2.1, §2.8 | Adlar `strings.csv`'den; satır A'nın `ProductModel.bug_row` biçiminde. | Evet |
| 3 | Oyuncuya görünen taslaklarda tire: sonuç mailinde ve tablonun boş hücrelerinde "—" (CLAUDE.md §5). | §2.5, §2.6, §2.3 ipucu tablosu | Boş hücre boşluk, değişmeyen fiyat satırda yazmaz. | Evet |
| 4 | **Sonuç maili örneği planın kendi sonuç tablosuyla çelişiyordu:** eşiğinin 29 puan üstündeki Nehir Tekstil "zammı kabul etmedi" diyordu; tablo reddi yalnız eşiğe 5 puandan yakın hesaba veriyor. | §2.6 | Örnek Ayşe 2★ ile tablodan yeniden hesaplandı: +%3, +%5, +%8, bir hesap yenilemez; toplam ayda +$155. | Evet |
| 5 | **Hesap tablosu ölçeği.** Taslak 9 satır; bot defteri 104. haftada 327–342 hesap (tohum 7: 222/97/9, tohum 11: 156/176/10). Planda kaydırma, sabit başlık ya da kalabalık defter yoktu. | §2.5, C7 | Gövde kayar, kaydırma çubuğu her zaman görünür (Erdem'in kuralı), başlık ve alt toplam sabit; sıralama durum taşıyanları üste alır. Yeni kare `--sales-shot=accounts_many`. | Evet |
| 6 | Dokuz sütun 1280 enli Satış penceresinde planın kendi en büyük UI riskiydi; Satışçı sütunu yalnız yenileme ayında anlam taşıyor. | §2.5, C7 | Satışçı, Yenileme hücresinin ipucuna taşındı ("Yenilemeyi Ayşe Kaya yürütür."). Sekiz sütun. | Evet |
| 7 | **Yenileme hacmi bir angarya.** İlk yenileme 61. haftada; botun 328 imzasının 328'i kurucunun. İkinci yıl her ay kurucuya, satışçı varsa ona da birer kâğıt: yılda 12–24 aynı biçimli kâğıt. Erdem'in "tekrar çok seyrek" ve "angarya yok" kuralına sürtünüyor. Ayrıca kâğıdın gövdesi 21 hesaplık bir ayda bütün hesapları dökerdi. | §2.6 | Gövde: yalnız karar isteyen hesaplar adıyla (en çok 4), gerisi tek satır. Sıklık: sahip sorusu 4 (kâğıt yalnız karar isteyen ayda gelir, öteki aylarda son karar uygulanır). | Kısmen (sıklık sahibin) |
| 8 | Satışçının masası her yenileme ayında bir hafta kilitli. Masa tek anlaşma işlediği için (`SalesLedger.rep_busy`) bu, satışçının ayının dörtte biri; planda ölçülmüyordu. | §2.6, C8 | C8 kapısı ikinci yılın imza sayısını yenilemeli ve yenilemesiz ölçer; kayıp %10'u geçerse `RENEWAL_DESK_WEEKS` 0,5. | Evet |
| 9 | Kurucunun görüşme kâğıdı cevapsız kalınca ne olacağı yazılmamıştı (bedava çıkış riski). | §2.6, C8 | Görüşme yapılmamış sayılır: eşiğin üstü aynı fiyattan yeniler, altı yenilemez, saat yazılmaz. Vaka `renewal_founder_card_expires`. | Evet |
| 10 | `seller_id` eski kayıtta boş kalıp "kurucunun" sayılıyordu. `Customer.acquisition_source` zaten `"sales_rep:<id>"` tutuyor. | §5.8 | Boşsa kazanım kaynağından türetilir; ayrı alan yine gerekir (Devret satışçıyı değiştirir). | Evet |
| 11 | `blocks_enterprise_signature()` silinince satış görüşmesinin güven sinyali (`sales_meeting_system.gd:157`) girdisiz kalıyordu. `meets_enterprise_trust()` ve seam `urun.enterprise_trust`'u beş olay kartı okuyor; silinmemeli. | §5.1 | Sinyal `provider() == PROVIDER_LOCAL`'a bağlanır; ikisi açıkça "silinmez" diye yazıldı. | Evet |
| 12 | C1 dosya listesinde eksikler: `main.gd` fikstürü (`set_capacity(suggested_start_units())`), `incident_playbook`'un açılış metni ("taşan kapasite"), `endgame_smoke.gd`'de silinen API'yi okuyan 25 satır ve elle kapasite kuran 8 satır (otomatik ölçekleme bunları eziyor). | C1 | Listeye eklendi. | Evet |
| 13 | Kademe kesinti çarpanı B ile farklıydı (C ×1,6 / ×0,5, B ×1,5 / ×0,6). | §2.3 | Tek ev B'nin `IncidentSystem.tier_mult()`; ipucu onu okur. | Evet |
| 14 | Memnuniyet ipucu güven terimini "Sözler" diye adlandırıyordu; defter B'nin kesinti bedellerini de taşıyor. | §2.5, §6.2 | "Söz ve kesintiler", parantezde son kayıt. Anahtar `SAT_TERM_TRUST`. Erdem'in "sözün tutulması ya da tutulmaması" isteği satırda okunur. | Evet |
| 15 | `founder_hours` fiilini C, B'den bekliyordu; B kurmuyor (B incelemesi bulgu 11). | §5.4, §5.7 | C kurar (`add_founder_meeting_hours`, çip, `--event-vocab`). D'nin iş payı formülü bu saati okur. | Evet |
| 16 | `incident_playbook`: C, B'nin almasını bekliyordu; B aldı (süreler ×0,75). | §5.1, §5.7 | C yalnız oyuncu metnini yazar. | Evet |
| 17 | B, `SprintCatalog.known_requests()` okuyor; C ise `open_requests()`'u daraltıyordu, B'nin beklediği ad hiç doğmuyordu. | §5.5, §3 | Yeni `known_requests()`; `open_requests()` bugünkü anlamıyla kalır. | Evet |
| 18 | A adları eskiydi: `ProductSystem.open_bugs()` (A'da `ProductState`), şema "15 kalır" (A 16'ya çıkarıyor); `bug_row`, `account_bugs`, `reports_incoming` yoktu. | §5.7, §5.8, §2.8 | A planındaki adlarla eşlendi. | Evet |
| 19 | Build bar'ın Destek satırını v1 sonrası Genel Bakış'a yönlendirmek A'nın kararını değiştiriyor ve düzeltme kartına giden yolu bir tık uzatıyordu. | §2.1, §5.6 | Hedef A'nın kalır (Sprint, en kötü hat). C'nin sinyali A'nın `open_area` yolunu sarar, ikinci yol kurulmaz. | Evet |
| 20 | B2C Genel Bakış'ta "Müşteri temsilcisi yok" iki blokta birden yazıyordu. | §2.1 | Yalnız İstekler bloğunda. | Evet |
| 21 | B2C İş satırı E ile çelişiyordu (C: "Satış hacmi $193K · 184 mağaza", E: "alıcı · mağaza · aylık gelir"). | §2.1 | "MRR $57.650 · 12.400 alıcı · 184 mağaza"; biçim C'nin, sayılar E'nin `figures()`'ından. | Evet |
| 22 | Haftalık raporun "bir hattın sayısı değişti" koşulu A'da hemen her hafta doğru (her doğrulanan bildirim bir açık hata). "Yeni bir şey yoksa gelmez" kuralı hiç çalışmazdı. | §2.8 | Koşul: bir hat Acil eşiğine (3) ulaştı ya da sıfırlandı, ya da en kötü hat değişti. | Evet |
| 23 | Yazım: `SUP_RPT_NEW_ASK` TR'de iki yer tutucu yan yana ("Kuzey Lojistik, Yelken Ofis Toplu fatura onayı istedi"); kurucu kâğıdında "X için sözleşmeler" kuruluşu. | §6.3, §2.6 | "{feature} isteyen hesaplar: {accounts}." / "Şu müşterilerle sözleşmemiz {ay} ayında bitiyor: {hesaplar}. Onlarla görüşmemiz gerekiyor." | Evet |
| 24 | **Rakip gerekçesi bir gerçeği atlıyordu:** oyunda rakip zaten karar isteyen olaylarla geliyor (`data/events/cards/rival/`: `price_cut`, `copycat`, `copycat_reply`, `funding_round`, `shutdown_notice`, `false_partner`). Planın kendi kuralı ("karşılığı olmayan sinyal gösterilmez") rakip fiyat satırını da vuruyordu: fiyatlar yeni ve etkisiz veri. | §2.7, §2.5 | §2.7 bu kartlarla yeniden gerekçelendi ("duyum" bu ailenin bir kartı). Fiyat satırı kendi fiyatını da yazar; `price_cut` kâğıdının rakip fiyatını yazması sahip sorusu 3'e bağlandı. | Kısmen (bağ sahibin) |
| 25 | **Kurumsal şartın bedeli ısırmıyor.** Yeni eşikte memnuniyet 60 civarında; −10 hesabı hiç eşiğin altına itmiyor. Şartı görmezden gelmek bedava, Erdem'in istediği tek tık düğmesinin bir anlamı kalmıyor. `security_cert` araştırmasının şartla ilişkisi de yazılmamıştı. | §2.4 | Sahip sorusu 6: −10 işaret olarak kalır, şart karşılanmadan biten sözleşme yenilenmez. Sertifika şartı karşılamaz (plana yazıldı). | Kısmen (bedel sahibin) |
| 26 | **Eşik ile A'nın kararı çatışıyor.** 40. haftadan sonra memnuniyet 59–67; A'nın hesap başına cezası en çok 20. Eşik 30 + 3× olursa 3★ hesap bile 39–47'de kalır, eşiğin (36) üstünde. Erdem'in "hata churn'ü etkilemeli" kararı B2B'de ilk 30 haftadan sonra neredeyse işlemez. Ayrıca karşı olgu betiği bugünkü eşikte 22/24 kayıp sayıyor, gerçek koşu 7/24; "%5–7'den %1–1,5'e" cümlesi betiğin sayısıydı, gerçek bugünkü oran %2–7. Betik ilk 4 haftanın tabanını (eşik + 2) ve sonraki söz kaymalarını da görmüyor. | §2.11, §8 soru 1, C3 | Sınırlar ve çatışma §2.11'e yazıldı. C3 gerçek koşuyla iki kol ölçer (düzelten ve hiç düzeltmeyen bot, yeni eşikte); hata etkisi yarıdan fazla kaybolursa iki yol Erdem'e gider. | Evet (değer sahibin) |
| 27 | Masada kapanan anlaşmada toplantı çıkışı düğmesi ile imza maili aynı anlaşma için ikisi birden geliyordu. | §2.4 | Masa anlaşmasında yalnız toplantı çıkışı; mail yalnız satış masasının kapattığı anlaşmada. | Evet |
| 28 | Kurumsal'dan aşağı inen oyuncu şartlı hesapları bozduğunu görmüyordu. | §2.3 | Önizlemeye olgu satırı: "2 hesabın sözleşmesindeki sunucu maddesi karşılanmaz olur." | Evet |
| 29 | Temsilcisiz oyuncu görmediği istek yüzünden gizli ceza yer mi? Kod: geç kalan isteğin memnuniyete bedeli yok (`tick_requests` yalnız `late` yazar), bilinmeyen istek de yayında karşılanır. | §2.2 | Not olarak yazıldı; değişiklik gerekmiyor. | Evet |
| 30 | Ses satırları: E not ve video uygulamasını siliyor. 28 satırın 20'si E2'de çöpe gider. | C5, adım 5 | E'nin sorusu "evet" çıkarsa C yalnız dört ortak hattın sesini yazar (8 satır). B incelemesinin sahip sorusu 7 ile aynı karar. | Kısmen (E'ye bağlı) |
| 31 | Dilim sırası: C2'nin şart terimi ve C7'nin ipucu `target_terms`'e yazıyor, ama o liste C3'te kuruluyordu. | §7, §9 | C3a (liste, değer değişmez) C2'den önce; C3b (eşik) onaydan sonra, C8'den önce. Commit sayısı 9. | Evet |
| 32 | Adım 9 ve §7 "tam smoke push öncesi" diyordu; Erdem 2026-10-06'da bunu kaldırdı. | §7, §9 | Push yalnız Erdem'in sözüyle, tam smoke koşulmadan. | Evet |
| 33 | 4r ve 7r "en çok 2 düzeltme turu" diyordu; Erdem'in 2026-10-11 kuralı commit başına bir inceleme ve bir düzeltme. | §9 | Tek inceleme ve tek düzeltme; CLAUDE.md §11'in iki turu tavan. | Evet |
| 34 | Karar defteri "C hat satırını Genel Bakış'a taşır" diyor; plan Sprint'teki satırların kalıp kalmadığını söylemiyordu. | §2.1 | A'nın Sprint satırları kalır (düzeltme kartı orada); Genel Bakış en kötü iki hattı özetler. Erdem itiraz ederse tek satırlık değişiklik. | Evet (not) |

**Doğrulanan kod iddiaları (sorun yok):**
- `InfraSystem`'in sabitleri (35/55/85, 30/45/70, 1.000 kullanıcı, 50 koltuk, Ekonomik bildirim ×1,25, doluluk %80/%100,
  aşım −0,8 / ×1,5 / ×0,6) ve okuyucuların satırları (`support_system.gd:274`, `sales_system.gd:191`,
  `b2b_sales_system.gd:504`, `negotiation_system.gd:266-267`, `sales_probes.gd:72-74`, `sprint_bridges.gd:119`,
  `seams_product.gd` `urun.capacity_state`). `urun.capacity_state`'i okuyan tek kart `outage.json`; B onu yeniden yazıyor.
- `seed_tolerance` = 33 + 9 × (ölçek − 1) + sektör (inşaat 5, sağlık 5, sigorta 3); `ONBOARDING_GRACE_MARGIN` 2;
  `RETAIN_DISCOUNT_MAX_USES` 2; `CS_KIND_RENEWAL`, `RENEWAL_MIN_TENURE_WEEKS` 44; `request.contract_weeks` 52.
- `MessageSystem.post(kind, key, args)` ve sınır 50 (`supersede` yeni); `GameState.add_founder_meeting_hours`;
  `SalesLedger.rep_busy`; `CustomerRepSystem.ranked_reps`; satışçının `_tick_weekly_summary` kalıbı; mail bölmesinde
  düğme kalıbı var.
- Pencere boyları (Satış 1280, Ürün 1424), `VIEW_KEYS`, `D_seg_tabs`, `D_locked_tab`; `expansion.json` kartı var.
- Oyuncuya görünen beş "Onboarding" metninin beşi de §2.10'da.
- Bot ölçümleri: karşı olgu betiği yeniden koşuldu, tablodaki sayılar tutuyor; B2C doluluğu 97 haftada en çok %99.

**Kapsam:** Karar defterinin Faz C maddelerinin hepsi tasarımda karşılanıyor. Erdem'in somut cümleleri de:
- sunucuda kalite kademeleri kalır, doluluk ve ölçekleme araştırılıp kaldırıldı, birim sorusu gerekçeyle cevaplandı;
- kurumsal şart iptal değil madde, tek tık düğme bugünkü ve yeni aylık faturayı gösteriyor;
- tabloda yalnız "Ayrılabilir / Yenilemeyebilir" ve gerekçeli tek ek olgu ("Yenilemeyecek · ay"), hafta sayısı ve
  "Büyümeye açık" yok;
- yenilemeyi müşteri temsilcisi değil satışçı yürütüyor, kurucu karar veriyor, yıldız sonucu belirliyor, sonuç maille
  geliyor, kimse yoksa kurucuya kâğıt;
- yıllık ve aylık gösterim araştırmayla cevaplandı;
- haftalık destek raporu ve istekler yalnız temsilciyle;
- memnuniyet ipucu sözü ve kesintiyi gösteriyor.

**Fazla iş:** Yeni sistem yok (yenileme `SalesRepSystem`'e, rapor `CustomerRepSystem`'e ekleniyor), yeni pencere yok.
Genel Bakış beş küçük blok, sakin. Fazlalığın iki kaynağı vardı: her ay gelen yenileme kâğıdı (bulgu 7, soru 4) ve
her hafta tetiklenecek rapor (bulgu 22, düzeltildi).

**Adım tablosu:** Kurala uyuyor. Kodu Sonnet xhigh ya da max ile yazıyor, kapıları Haiku düşük düşünmeyle koşuyor,
her commit öncesi bir Opus incelemesi var, tazelemeyi Sonnet yapıyor. Değişenler: C3'ün bölünmesi, düzeltme turu
sayısı, faz sonundaki tam smoke'un kalkması, iki kapının (iki kollu ölçüm, imza kaybı) süreye eklenmesi.

---

## 2. Fazlar arası liste (tazelemede bakılacaklar)

**A ile**
- Adlar: `ProductState.open_bugs()`, `open_bugs_by_line()`, `worst_bug_line()`, `open_bugs_delta()`,
  `ProductModel.bug_row(hat)`, `SprintCatalog.line_impact(hat)`, `B2BSalesSystem.account_bugs(c)` ×
  `B2B_BUG_SAT_PER` (tavan `_CAP`), `ProductState.reports_incoming()`, düzeltme kartı `fix:<hat>`. Plana işlendi.
- Şema 16 A'nındır; C artırmaz.
- Build bar tıklaması A'nın hedefinde kalır; C'nin `product_view_requested`'ı A'nın `open_area` yolunu sarar (A
  incelemesi bunu bekliyor).
- **Çatışma:** C'nin eşiği A'nın B2B hata etkisini zayıflatır (bulgu 26). A'nın ceza tavanı ile C'nin eşiği birlikte
  karara bağlanmalı; C3'ün iki kollu ölçümü bunun için.

**B ile** (B incelemesinin "Ana oturuma not"u, dördü de alındı)
- Kademe çarpanı B'nin `IncidentSystem.tier_mult()`'ı.
- Memnuniyet ipucu güven terimini "Söz ve kesintiler" diye adlandırır.
- `founder_hours` fiilini C kurar.
- `incident_playbook`: etkisi B'de (×0,75), metni C'de.
- B, `known_requests()` ve `b2c_asks()` okur; C bu adları kurar.
- B'nin sahip sorusu 4 (erteleme 6 ve C'nin eşiği) ile C'nin sahip sorusu 1 aynı karardır.
- B'nin sahip sorusu 6 (B doluluğu okumasın) C'nin sahip sorusu 2'ye bağlı.

**D ile**
- C'de puan miktarı yok; ×5 ölçek C'ye dokunmuyor.
- Kurucu yenileme saati `add_founder_meeting_hours` ile yazılır; D'nin iş payı "1 − toplantı saati / 40" onu okur.
  24 saatlik tavan kurucunun o haftaki katkısının %60'ı.

**E ile**
- İş satırının B2C biçimi C'nin, sayıları E'nin `figures()`'ı; plana işlendi.
- MRR gösterimi C'nin; E yalnız pazaryerinin aylık gelirini sağlar. C'nin önerisi (MRR ortak dil, ARR yalnız B2B'de)
  E ile uyumlu.
- Satıcı istekleri "mağaza" birimiyle (E'nin `side_of(hat)`).
- Not ve video silinirse C'nin ses satırları 28'den 8'e iner (bulgu 30).
- "Onboarding" alanının yeni adı ("İlk Kullanım ve Erişim") E'nin B2C alan listesine de geçer.

---

## 3. Erdem'in kararı gereken sorular (planın beş sorusuyla birleşik, en çok 6)

1. **Ayrılma eşiği** 30 + 3 × (yıldız − 1) + sektörün yarısı olsun mu (1★ 30, 2★ 33, 3★ 36), ve eşik memnuniyet
   ipucunda yazsın mı? **Öneri: evet ve evet; değer A'dan sonraki iki kollu ölçümle kesinleşir.** Bedeli: eşik inince
   hataların B2B'de hesap kaybettirmesi 30. haftadan sonra neredeyse durur. Ölçüm bunu doğrularsa iki yol gelir: A'nın
   ceza tavanı artar ya da eşik daha az iner (33 + 4×).
2. **Sunucu doluluğu** tamamen kalksın, kademeler kendiliğinden ölçeklensin; oyuncu yalnız kademeyi ve aylık faturayı
   görsün mü? **Öneri: evet.** Bot ölçümünde doluluk 97 haftada en çok %99'a çıktı; oyuncuya bir karar sunmuyor.
3. **Rakip analizi** ayrı bir ekran olmasın; rakip fiyatı fiyat duruşu ipucunda kendi fiyatınla dursun ve var olan
   "rakip müşterine daha ucuz teklif verdi" kâğıdı bu fiyatı yazsın mı? **Öneri: evet.** Rakip oyunda zaten karar
   isteyen kâğıtlarla geliyor; duyum bu ailenin bir kâğıdı.
4. **Yenileme kâğıdı** yalnız karar isteyen bir hesap olan ayda mı gelsin (3★ hesap, eşiğin altında hesap ya da
   karşılanmamış sunucu maddesi), öteki aylarda satışçı son kararını uygulayıp yalnız sonuç maili mi göndersin?
   **Öneri: evet.** Yoksa ikinci yılda yılda 12 ile 24 aynı biçimli kâğıt gelir. Zam %8, indirim %10 ve zarsız tablo
   planın önerdiği gibi kalır.
5. **B2B fiyatı** aylık söylensin, sözleşme 12 ay, nakit aylık; yıllık gelir yalnız B2B'de gösterim olsun ve ana gösterim
   MRR kalsın mı? **Öneri: evet.** Yıllık peşin tahsilat runway ve tur kalibrasyonunu baştan bozar.
6. **Kurumsal sunucu şartı karşılanmazsa** sözleşme bitiminde hesap yenilemesin mi (hedefteki −10 yalnız ipucunda bir
   işaret olarak kalsın)? **Öneri: evet.** Bugünkü −10 yeni eşikte hiçbir hesabı düşürmüyor, yani şart bedava
   görmezden geliniyor. Yenileme bedeli gerçekçi, oyuncuya bir yıl tanıyor ve düğmeye anlam veriyor. Güvenlik
   sertifikası araştırması şartı karşılamaz.

---

**Tek satır hüküm:** Kapsam tam ve kod sağlam; plan düzeltmeyle hazır, uygulamaya geçmeden önce Erdem yenileme
sıklığını (4) ve eşik ile hata etkisi dengesini (1) karara bağlamalı.
