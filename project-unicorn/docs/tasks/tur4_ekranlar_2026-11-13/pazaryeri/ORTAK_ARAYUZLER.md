# Ortak arayüzler, kayıt ve iniş sırası

TASLAK 4, 2026-11-13 gece, PAZARYERI. Kod değil, PRD değil: adlandırma ve sıra önerisi. DUZELTME (Pazarlama), OLAYLAR
(Talepler) ve URUN (ERP) görüş verdi, yardımcı yönetmen açık maddeleri karara bağladı; aşağıdakiler bu uzlaşmadır. Bu hâl
Erdem'in 13 Kasım akşam yorumuyla (`../ERDEM_YORUMU_TUR4.md`), `docs/tasks/PRD_PAZARYERI.md` taslak 2 ile ve Pazarlama'nın PRD
taslağıyla hizalandı; pazaryeri konusunda ayrışırsa PRD_PAZARYERI geçerlidir. Dayanak: `TEKNIK_KESIF.md`, HEAD `f4307fb9`.

## 1. Üç arayüz

İlke: hiçbir sistem başka bir alanın durumunu yazmaz, **okur**. Sahibi bir okuma işlevi verir; okuyan onu kendi tikinde
çağırır ve yalnız kendi durumunu yazar. Okuma hesap tetiklemez, son saklanan değeri döndürür. Her şey haftalıktır. Tik
yuvaları: Pazarlama İK'dan sonra (`time_manager.gd:408`), Pazaryeri'nin kapanışı Satış yuvasında (`:409`, sprint
kapanışından sonra), ikisi de Finans'tan önce (`:416`). Sıra doğruluğu değil, en çok bir haftalık gecikmeyi belirler.

| | Ziyaretin yazılması | Kampanyanın bir kuralı geçici ezmesi | Talepler'in dışarıdan açılması |
|---|---|---|---|
| Ad | `MarketingSystem.channel_visits(kategori)` (kanal ve kampanya kimliğiyle), `return_lift()`, `impression_share(kategori)` | `MarketingSystem.active_campaign()`: tür, kalan hafta, hazırlığın yapılan ve toplam haftası, kategoriler, derinlik, şirketin payı, `overrides`. `MarketplaceSystem.policy_value(kural)`: ezme varsa onu, yoksa saklı seçimi döndürür | `SprintUiShared.open_requests(tree, opts)`; `opts`: `status`, `side`, `sort`, `topic` |
| Sahibi ve yazarı | Pazarlama: kanal kademesi, yuvadaki kişi, içerik birikimi. Gideri her hafta, sıfır dahil, `FinanceSystem.set_burn_category("marketing", …)` ile | Pazarlama: kampanyanın ayarı, hazırlığı ve kişi tarafı. Kuralın saklı seçimine ve dört haftalık kilidine kimse dokunmaz | Talepler görünümü (OLAYLAR); durum yazılmaz |
| Okuyan | Pazaryeri, kapanışında: ziyaret = organik + kanallar; kaynak ayrımını kendi durumuna yazar. Kategoriler reklam doyumunu okur | Pazaryeri, kapanışında: sipariş artışı, çukur, mağaza tepkisi (deftere adlı satır). Politikalar satırı salt okunur ve ne olduğunu yazar: "İndirim günleri · N hafta kargo bedava" | Pazaryeri › Genel ve Destek raporu: `{status: waiting}`; taraf satırından `side` ile |
| Karşı okuma | Pazarlama ← `MarketplaceSystem.channel_read(kategori)`: dönüşüm, bir kullanıcının aylık komisyonu, organik ziyaret, kategorinin kâr payı ve reklam havuzu (haftalık arama). `source_revenue(kaynak)`: son on iki haftada o kaynaktan gelen kullanıcıların son dört haftada bıraktığı net komisyon (Pazaryeri yeni kullanıcıyı kaynağıyla saklar) | Formül Pazaryeri'nin saf işlevidir (kupon dahil); Pazarlama'nın önizlemesi ve raporu aynı işlevi okur | `ProductModel._requests` pazaryerinde `MarketplaceSystem.request_topics()`'i okur |
| Sinyal | `marketing_changed()`, `marketplace_changed()`; gider `burn_changed` ile yayılıyor | `marketing_changed()` | Var olan `tab_changed` |
| Uzlaşma | DUZELTME | DUZELTME, yardımcı yönetmen | OLAYLAR |

- **Hangi kampanya hangi kuralı ezer:** yalnız indirim günleri, yalnız kargo. Formda "Kargo: Kurala göre · Bedava"; Bedava
  seçilince `overrides = {"shipping_fee": "free"}`, kural kampanya süresince askıda, kargoyu şirket öder (Premium'un "Kargo
  bedava"sı açıksa üye siparişinin kargosu Premium'un satırına, kalanı kampanyaya yazılır; toplam aynıdır). Kupon kural ezmez.
- **Kampanyanın mağaza tarafı:** katılım indirim derinliğinin kategorinin kâr payına oranından ve şirketin payından gelir;
  memnuniyeti düşen, katılıp zarar eden mağazadır. Hazırlık Pazarlama'dadır ve pencereye göre değişir (büyük pencerede
  altı, küçükte üç, "Hemen"de bir hafta); hazırlıksız kampanyada sipariş dalgası "Teslim edildi" adımını düşürür.
- **Reklam doyumu:** tek sayı, sahibi Pazarlama: o kategorinin haftalık aramalarındaki reklam yerlerinden kaçında
  göründüğümüz. Havuz (haftalık arama sayısı) Pazaryeri'nin kategori verisindedir; Kategoriler sayıyı Pazarlama'dan okur;
  iki ekranda aynı adla yazılır. ("Raf doluluğu" Erdem'in kararıyla kalktı.)
- **Kupon:** raporundaki "Ürüne doğrulama ekle" düğmesi Pazaryeri'nin seam'inden (`open_topic`) Talepler'e kullanıcı
  tarafında bir konu açar. Kupon ve kargo eşiği kural ezmez.
- **ERP:** aday bir kayıttır, sahibin seam'iyle doğar (`SalesFaucetSystem.spawn(star, source)`, kaynak `mkt_*`); ziyaret bir
  toplamdır, okunur.
- **Bilet satırı:** pazaryerinde bilet tiki Pazaryeri'nin sistem paketindedir; alanlar `talepler/TASARIM.md` §11'deki gibi.
  Pazaryeri kapanışında sürüm kaydını okur (`GameState.product.releases`) ve kendi defterine "Karşılandı: <konu>", sekiz
  haftayı geçen konuya "Geciken talep: <konu>" yazar; `sprint_bridges.gd` pazaryerini bilmez. `tick_requests` OLAYLAR'ındır.

Yardımcı yönetmenin kararları (13 Kasım; adlar Erdem'in onayında): taraf adları her ekranda "kullanıcı" ve "mağaza"; ikinci
göstergenin adı "Reklam doyumu". Ödeyen tarafın adı açık: Pazarlama "Şirket" yazıyor, Politikalar Erdem'in önerisiyle "Biz
öderiz" (PRD_PAZARYERI §12 soru 3); cevap gelince iki ekran aynı sözü kullanır. "Yük kimde" gösterimi Erdem'in kararıyla
her ekrandan kalktı. Erdem'e giden öneri: aylık gelir son dört haftanın net komisyonu ve
üyeliktir (iadeler ve şirketin karşıladığı indirim düşülür, reklam gideri düşülmez); kanalın gelir katkısı ve kampanya bandı
aynı tanımı okur.

## 2. Kayıt: şema artışı ve sözlükler

Koddan: kayıtta olmayan `GameState` alanı varsayılanında kalır, bilinmeyen anahtar yok sayılır; şema 19'dan beri beş
`founder_*` alanı artışsız eklendi. Numara iki şeyi korur: eski sürüm yeni kaydı reddeder (`SAVE_ERR_NEWER`), göçler ona bakar.

- **Tek artış PAZARYERI'nde:** 19'dan 20'ye, sistem paketinde, tek başına bir commit (`GameState.marketplace`, emekli B2C
  bayrakları). Gerekçe: artış olmazsa eski bir sürüm pazaryeri kaydını sessizce eski B2C ekonomisiyle açar
  (`product_catalog.gd:198`).
- **Her ekip kendi durumunu kendi alanında tutar** (Pazaryeri `marketplace`, Pazarlama `marketing`); kimse öbürününkine
  yazmaz. Yeni alan ya da anahtar anlamlı varsayılanla doğar ve artış istemez.
- **Yeni numara yalnız iki durumda:** kayıtlı verinin biçimi değişirse ya da eski sürüm yeni kaydı sessizce yanlış açacaksa.
  Numara PRD'ye yazılmaz, inişte sıradaki alınır. `MIN_LOADABLE_VERSION` 10 kalır.
- **Göç bekleyen ekip yok:** Pazarlama'nın varsayılanı kendi başına anlamlı ve pazarlama kalemi her hafta yeniden yazılıyor;
  Talepler'de istek satırı hesap × kademe kalıyor, konuya gruplama okumada; ERP'nin adlı kapısı veri.

## 3. Ortak dosyalar: iniş sırası

Aynı dosyaya dokunan işler sırayla iner; ortak commit yoktur. Dalgalar birbirini bekler, dalga içi paralel yürür.

| Dalga | İş (sahibi) | Ortak dosyalar |
|---|---|---|
| 1 | Test hazırlığı: B2C test dünyaları ERP'ye çevrilir (PAZARYERI) | `endgame_smoke.gd` |
| 2 | Kilitli sıradaki kademe satırı, sonra adlı yayın kapısı ve şerit (URUN) | `product_model.gd`, `area_panel.gd`; sonra `sprint_catalog.gd`, `sprint_panel.gd`, `sprint.json` |
| 2 | Tür seçim ekranı (ARAYUZ) | `type_picker.gd`, `product_catalog.gd` |
| 3 | Pazaryeri verisi (PAZARYERI, paket 1) | `product_catalog.gd`, `sprint.json`, `sprint_catalog.gd` |
| 3 | Talepler görünümü ve isteğin ERP hâli (OLAYLAR) | `product_tab.gd`, `product_model.gd`, `area_panel.gd`, `sprint_bridges.gd`, `support_system.gd`, `sprint_catalog.gd` |
| 3 | Pazarlama'nın ERP hâli (DUZELTME) | `hr_constants.gd`, `finance_system.gd`, `game_state.gd`, `sales_system.gd` (yalnız `:204`), `ui_tokens.gd` |
| 4 | Pazaryeri sistemi ve şema commit'i (PAZARYERI, paket 2) | `sales_system.gd`, `game_state.gd`, `save_manager.gd`, `finance_system.gd`, `support_system.gd` |
| 5 | Pazarlama'nın pazaryeri hâli (DUZELTME) | `finance_system.gd` |
| 5 | Kitleyi okuyan yerler, kartlar, bilet satırları (PAZARYERI, paket 3) | `sprint_bridges.gd`, `support_system.gd`, `sprint_catalog.gd` |
| 6 | Not ve video ürünlerinin silinmesi (PAZARYERI; Erdem 13 Kasım'da kaldırdı). Tür seçiminden kalkmaları ve kayıt reddi dalga 4'te, veri ve metin silinmesi burada | `product_catalog.gd`, `endgame_smoke.gd` |
| 6 | Pazaryeri arayüzü, Politikalar, mağaza kazanımı ve Satış rolü, Premium (PAZARYERI, paket 4 ile 6) | `ui_tokens.gd`, `hr_constants.gd`, `finance_system.gd`, `sprint_panel.gd` |
| 7 | Bot, ön ayarlar, kapılar (PAZARYERI, paket 8) | `endgame_smoke.gd` |

- **Şerit:** bileşen parça başına isteğe bağlı bir not taşır (`{line, note_key, note_args}`); pazaryeri ayrı satır eklemez.
- **1★ beklentisi** (`product_quality.gd:318`) URUN'un commit'inde değişir: yayın şartı listesinin kendisidir (adlı modüllerin
  ilk kademesi; `MODUL_SEMASI.md`). "Çekirdek" ve alan katmanı kalkar; modül bugünkü hattın kendisidir.
- **Roller:** pazarlamacı `EMPLOYEE_ROLES`'un sonuna, Pazarlama'nın ilk commit'inde eklenir; önce ve sonra tam paket, `PROBE`
  farkı commit mesajında. Satış rolünü pazaryerinde PAZARYERI açar, mağaza kazanımıyla birlikte.
- **`sales_tab.gd`:** önce URUN'un akış başlığı, sonra Pazarlama'nın kaynak izi, sonra Pazaryeri gövdesi.
- **Fiiller** (OLAYLAR'ın kuralı): önce sözlük; ad alan önde (`marketplace_*`, `marketing_*`); fiil kartıyla tek commit'te.
  `effects.gd`, `chips.gd`, `lint.gd` listedir, dalga gerekmez. `marketing_push` tek commit'te gider; O5 lint fikstürleri yeni
  modül fiiline taşınır.
- **Her dalgada:** `strings.csv` (önekler `MP_`, `REQ_`, `MKT_`, şerit `LAUNCH_`) ve `endgame_smoke.gd` (her ekip kendi
  vakaları; ortak yardımcılar dalga 1'den sonra değişmez).
- **İki ekibi bekleyen dört gösterge** (Ziyaret çubuğunun Kanal payı, kampanya çipi, Kategoriler'deki reklam doyumu, Genel'deki
  "Talepleri aç" düğmesi) yedek dalla yazılmaz; sonradan inenin commit'inde bağlanır. Premium'daki "Üyelere özel indirim"in
  şartı kalktı: indirim günleri Pazarlama'da bir şablondur, ayrıca açılmaz.
- **Keşiften sonra görülen ortak dosyalar, sahibiyle:** `time_manager.gd` (Pazarlama tiki DUZELTME, Pazaryeri kapanışı
  PAZARYERI), `finance_ozet_view.gd` (gelir dökümü PAZARYERI, kanal kanal gider DUZELTME), `hr_system.gd` ve
  `hr_assignments.gd` (Satış kilidi PAZARYERI, Pazarlama alanı DUZELTME), `main.gd` ve `event_bus.gd` (her ekip kendi kare
  türü ve sinyali).

Açık (yardımcı yönetmenin dosya sahipliği tablosuna giriyor): **S1.** `run_probe.gd`'de üç botun sırası. **S2.**
`window_layer.gd`'deki pencere boylarının ve `ui_tokens.gd`'de dört ekibin eklediği sabit bloğunun sahibi yok. **S3.** Sıranın
tamamı tasarımların ve `PLAN_ERP_EKIP`'in Erdem onayına bağlı.
