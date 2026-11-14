# Pazaryeri

Ne yapar: B2C ürünün pazaryeri ekonomisinin saf çekirdeği: mağaza ve kullanıcı akışı, ziyaretten teslimata dört adım, iade, gelir, iki memnuniyet defteri, dört kural, Premium ve dört haftalık önizleme.
Henüz oyuna bağlı değil: `GameState`'e, sistemlere ve arayüze dokunmaz; yalnız başsız probe çağırır. Sistem paketi `GameState.marketplace`'i `state` diye verecek, arayüzün önizlemeleri aynı işlevleri okuyacak.
Kaynak: `docs/tasks/PRD_PAZARYERI.md` §3 (ekonomi), §9 (sabitler), §10 (test). Sahip: `MarketplaceModel` (statik, durumsuz).

## Dosyalar

- `systems/marketplace_model.gd` (726): `MarketplaceModel`; yalnız `static` işlevler. `state` ve `world` sözlüklerinin alanları dosya başındaki yorumda.
- `debug/marketplace_probe.gd` (559): `-s` betiği; oynanan çizelge ve 21 mekanik denetimi, `MPPROBE ...` satırları.
- `data/product/categories.json` (16): altı kategori ve sütunları: sepet, ziyaret sıklığı, kâr payı, sektör iadesi, gereken mağaza, başlangıç komisyonu, taban ilgi, büyük sepet payı.
- `data/product/marketplace.json` (98): öbür bütün sabitler, gruplu: `visits`, `steps`, `stores`, `rules`, `commission`, `store_terms`, `premium`, `ledger`, `income`, `preview`.

## Giriş noktaları

- Kurma: `new_state()`, `new_world()` (varsayılanlı dünya; verilmeyen alan `WORLD`'den okunur), `cat_ids()`, `cat_def(kategori)`, `open_ids(state)`.
- Haftalık kapanış: `close_week(state, world)` bağlayıcı sırayla `state`'i değiştirir (mağaza akışı, ziyaret ve adımlar, iade, kullanıcı, gelir ve gider, Premium, defter); sinyal ve kayıt çağıranındır.
- Yazan işlevler (`true` uygulandı, `false` reddedildi): `open_category`, `set_commission`, `set_policy`, `set_fee`, `set_perk`, `set_trial`, `open_premium`, `set_store_terms`; kilit `lock_left(gün, world)`.
- Okuyanlar: `policy_value` (kampanyanın ezmesi önce), `store_keep` ve `zone` ve `zone_limits` (mağazaya kalan, bölge, çubuğun iki sınırı), `variety`, `acquisition` ve `acquisition_of`, `return_rate`, `price_pass`,
  ↳ `step_factors` ve `weakest_step`, `gain(state, world, kategori, değişiklik)`, `monthly_revenue` ve `monthly_cost`, `target_sat`, `premium_pull`, `returning_share`, `retention`.
- Önizleme: `project(state, world)` kopyada dört kapanış koşar; `preview_commission`, `preview_policy`, `preview_premium` değişiklikli ve değişiklikssiz farkı döndürür (`metrics` anahtarları; `store_earnings` oran, öbürleri fark);
  ↳ reddedilen değişiklikte `{}`.

## Sinyaller

Yok.

## Durum ve veri

- `state` dosya başındaki yorumda sayılır; `sat[taraf]` iki memnuniyettir (sistem paketi `CustomerRegistry` kaydına yansıtır), `burn[kalem]` son kapanışın haftalık `pazaryeri` giderinin adlı kalemleri,
  ↳ `premium.orders` son dört haftanın üye siparişidir.
- Sayılar ondalıklı kalır; defter satırı `{key, arg, points, weeks}` (`weeks` WHILE=-1 koşul sürdükçe), metin değil kimlik. Gün alanları hafta sayısıdır, hiç değişmemişin günü `NEVER`.
- Ayarı değişebilecek seçimler tek sabitte: fiyata yansıma `stores.pass_through` (0 = komisyon siparişi düşürmez), gelir penceresi `income.window_weeks` (1 = bu hafta × 4,33), iade kargosu seçenekleri `rules.options.return_shipping`,
  ↳ mağaza kazanımının yayınla başlaması `acquisition_of` içindeki `published` kapısı.

## Metin anahtarları

Yok: çekirdek oyuncuya görünen metin üretmez; arayüz kimlikten kurar.

## Testler

- Probe: `"$GODOT" --headless --path . -s res://scripts/debug/marketplace_probe.gd -- --marketplace-probe=weeks=<n>` (varsayılan 40); `MPPROBE WEEK` hafta başına, `MPPROBE CHECK <ad> PASS|FAIL`, son satır `MPPROBE SUMMARY`.
  ↳ FAIL varsa süreç 1 ile, argüman hatasında 2 ile çıkar. `class_name` eklendiği için önce `--import`.
- Denetimler: `empty_category_no_orders`, `acquisition_waits_for_publish`, `leaving_zone_stores_fall`, `lock_rejects`, `campaign_override_expires`, `revenue_window_spike`, `premium_closed_no_perk_cost`,
  ↳ `campaign_free_shipping_single_write`, `preview_figures`, `known_store_earnings`, `known_return_rate`, `known_order_rate`, `json_roundtrip`, `ledger_expiry`, `zone_limits_consistent`, `constants_switch`,
  ↳ `gain_and_weakest`, `acquisition_multipliers`, `store_terms_discount`, `premium_members`, `zone_rows_need_stores`.

## Dikkat

- `Dictionary.merged(x)` varsayılanda var olan anahtarı ezmez; dünya ve durum birleştirmelerinde hep `merged(x, true)`.
- `:=` Dictionary erişiminden tür çıkaramaz (Variant); bu dosyada her sözlük okuması açık türle (`var x: float = ...`) yazılır.
- "Sipariş" teslim edilendir; "Sipariş verdi" adımı `order` ayrıdır. "Geç teslimat" satırı teslim ÷ verilen oranına bakar: 0,97 × Siparişler çarpanı × Entegrasyonlar çarpanı × hata çarpanı, eşik 0,90.
  ↳ Bu yüzden satır v1.0'dan beri açık kalır ve ancak Siparişler 2 + Entegrasyonlar 2 (0,912) ya da Siparişler 3 + Entegrasyonlar 1 ile kalkar; üç açık hata yeniden açar.
- Kargo bedava ayrıcalığının payı saklı kuraldan okunur (`state.policy.shipping.pick`), kampanyanın ezmesinden değil: "Hep mağaza öder"de 0, "Büyük sepette mağaza öder"de büyük sepetler sayılmaz. Kampanya haftasında kalan siparişin kargosu
  ↳ kampanya satırına yazılır; iki satırın toplamı her zaman teslim × kargo bedelidir.
- "Zorlanıyor" ve "Kazancı yetmiyor" defter satırları yalnız mağazası olan kategoriye yazılır; "Seçenek az" tersine mağazası azken yanar.
- Önizleme çipleri `world.week`'ten başlayan dört kapanışın sonudur (kilit süresi); olay, acil durum ve kampanya kaybı koşulmaz, Pazarlama'nın değerleri sabit kalır.
- JSON turundan sayılar float, anahtarlar metin döner; model gün ve sayaçları `int(...)` ile okur. Kişi kimlikleri `assign` ve `stars` anahtarıdır, metin olmalı.
- Sabitler `static var _c` ve `_cats`'ta durur (dosya yüklenince okunur); probe `constants_switch` sabiti çalışırken değiştirip geri koyar.
- Probe çıkışında motor bazen `ObjectDB instances leaked` ve `resources still in use` satırı basar; sonuçları ve çıkış kodunu etkilemez. Probe bir kapıya bağlanırsa (`ERROR:` satırı vakayı düşürür) bu satır bağışlanmalı.

## Bir değişiklik yaparken

- Yeni defter satırı: sayı `marketplace.json` `ledger.rows`'ta, koşulu `_settle`'da; süreli satır yazan işlev `_add`'i çağırır.
- Yeni ayrıcalık ya da kural: `premium.perks` ya da `rules.options` kaydı, `_close_category` (kullanım ve gider), `premium_pull` ve `set_*` şartları.
- Yeni önizleme büyüklüğü `metrics`'e girer; `_preview` hepsini otomatik fark alır. Önizleme `set_*` işlevlerini kopyada çağırır;
  ↳ probe'daki `preview_figures` çipleri bağımsız sayılarla (`store_keep` oranı, defter puanı ve haftada 5 puan tavanı) karşılaştırır.
- Sistem paketi bağlarken: çekirdek `GameState`'i okumaz; `world`'ü o hafta kurup `close_week`'i çağırır, sonra `monthly_revenue` ve `monthly_cost`'u kayıtlara ve Finans'a yansıtır.
