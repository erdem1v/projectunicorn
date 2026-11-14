# Pazaryeri

Ne yapar: B2C ürünün pazaryeri ekonomisinin saf çekirdeği: mağaza ve kullanıcı akışı, dört adım, iade, gelir, iki memnuniyet defteri, dört kural, Premium, dört haftalık önizleme, Talepler'in konu ve biletleri, Pazarlama'nın iki okuması.
Henüz oyuna bağlı değil: sistemlere ve arayüze dokunmaz; yalnız başsız probe ve `marketplace_save_roundtrip` çağırır.
Sistem paketi `GameState.marketplace`'i `state` diye verecek, arayüzün önizlemeleri aynı işlevleri okuyacak.
Kaynak: `docs/tasks/PRD_PAZARYERI.md` §3 (ekonomi), §9 (sabitler), §10 (test). Sahip: `MarketplaceModel` (statik, durumsuz).

## Dosyalar

- `systems/marketplace_model.gd` (897): `MarketplaceModel`; yalnız `static` işlevler. `state` ve `world` sözlüklerinin alanları dosya başındaki yorumda.
- `debug/marketplace_probe.gd` (825): `-s` betiği; oynanan çizelge ve 31 mekanik denetimi, `MPPROBE ...` satırları.
- `data/product/categories.json` (16): altı kategori ve sütunları: sepet, ziyaret sıklığı, kâr payı, sektör iadesi, gereken mağaza, başlangıç komisyonu, taban ilgi, büyük sepet payı, reklam havuzu (`ad_pool`, haftalık arama).
- `data/product/lines/marketplace.json` (153): modül verisi; 5 kimlik hattı (Ürün Yükleme, Vitrin, Sepet ve Ödeme, Siparişler, Yorum ve Güvence)
  ↳ Mobil, Entegrasyonlar, Kullanıcılar ve Yetki, Yedekleme `shared.json`'dan; Üyelik, Gelir alanının `cap_paid_plan`'ı.
  ↳ Yayın şartının dört adlı modülü (Ürün Yükleme, Vitrin, Sepet ve Ödeme, Siparişler) `sprint.json` `mvp_named["marketplace"]`'da.
  ↳ Tür `ProductCatalog`'ta kayıtlı ama `TYPE_SCREEN`'de yok: seçilemez. Rakipler `RivalCatalog.NAMES` ve `rivals.json`, Piyasa yuvaları (Orinoco, Bidwell, Dealflock) `companies.json` `sector_slots`.
- `data/product/marketplace.json` (118): öbür bütün sabitler, gruplu: `visits`, `steps`, `stores`, `rules`, `commission`, `store_terms`, `premium`, `ledger`, `income`, `preview`, `topics` (konu kataloğu ve mağaza dertleri).

## Giriş noktaları

- Kurma: `new_state()`, `new_world()` (varsayılanlı dünya; verilmeyen alan `WORLD`'den okunur), `cat_ids()`, `cat_def(kategori)`, `open_ids(state)`.
- Haftalık kapanış: `close_week(state, world)` bağlayıcı sırayla `state`'i değiştirir (mağaza akışı, ziyaret ve adımlar, iade, kullanıcı, gelir ve gider, Premium, defter); sinyal ve kayıt çağıranındır.
  ↳ Kapanış `state.lost`'a kaybı ekler (`users` += kullanıcı × (1 − elde tutma), `stores` += ayrılan mağaza); iki sayı birikmiş toplamdır.
- Biletler: `tick_topics(state, world)` kapanıştan sonra, haftada bir koşar; her konunun o haftaki biletini son dört haftaya yazar. Konu durumu (`waiting`, `planned`, `shipped`) ve defter satırları kapanışın 7. adımında dünyadan okunur.
- Yazan işlevler (`true` uygulandı, `false` reddedildi): `open_category`, `set_commission`, `set_policy`, `set_fee`, `set_perk`, `set_trial`, `open_premium`, `set_store_terms`,
  ↳ `add_users(state, n)` (olayın kullanıcı ekleyişi ya da çıkarışı, `n` eksi olabilir; kullanıcı sayısı değişmediyse false); kilit `lock_left(gün, world)`.
- Okuyanlar: `policy_value` (kampanyanın ezmesi önce), `store_keep` ve `zone` ve `zone_limits` (mağazaya kalan, bölge, çubuğun iki sınırı), `variety`, `acquisition` ve `acquisition_of`, `return_rate`, `price_pass`,
  ↳ `step_factors` ve `weakest_step`, `gain(state, world, kategori, değişiklik)`, `monthly_revenue` ve `monthly_cost`, `target_sat`, `premium_pull`, `returning_share`, `retention`.
- Pazarlama'nın okuması: `channel_read(state, world, kategori)` = `conversion` (ziyaretten teslim edilen siparişe), `monthly_commission` (bir kullanıcının aylık net komisyonu),
  ↳ `organic` (kendiliğinden haftalık ziyaret), `margin`, `base_interest`, `ad_pool`;
  ↳ `source_revenue(state, world, kaynak)` = kaynaktan son on iki haftada gelenlerin (elde tutmayla küçülmüş) son dört haftada bıraktığı net komisyon;
  ↳ kullanıcı o dört haftanın burada olduğu kadarıyla sayılır (bu hafta gelen dörtte bir), yani yeni kanalın satırı küçük başlar.
- Talepler: `topic_rows(state, world)` ilk isteği gelmiş her konunun satırı (`id`, `side`, `module`, `tickets`, `affected`, `reason`, `status`, `age`, `source`); konu kimlikleri `marketplace.json` `topics.catalog`'ta, metin yok.
- Önizleme: `project(state, world)` kopyada dört kapanış koşar; `preview_commission`, `preview_policy`, `preview_premium` değişiklikli ve değişiklikssiz farkı döndürür (`metrics` anahtarları; `store_earnings` oran, öbürleri fark);
  ↳ reddedilen değişiklikte `{}`.

## Sinyaller

Yok.

## Durum ve veri

- Durumun evi `GameState.marketplace` (`initialize_run` boşaltır, ERP koşusunda boş kalır; kodlayıcı `GameState` alanlarını kendisi bulur, göç yok: şema 20); `marketplace_save_roundtrip` `retention`'ın bölmesini gerçek kayıt yolunda sınar.
- `state` dosya başındaki yorumda sayılır; `sat[taraf]` iki memnuniyettir (sistem paketi `CustomerRegistry` kaydına yansıtır), `burn[kalem]` son kapanışın haftalık `pazaryeri` giderinin adlı kalemleri,
  ↳ `premium.orders` son dört haftanın üye siparişidir, `lost` birikmiş kayıp, `topics[konu]` (`tickets` son dört hafta yeni önde, `since_day`, `status`, `source`).
- Talepler: bilet kullanıcı konusunda bağlı adımda sayılan büyüklük × oran, mağaza konusunda derdi olan mağazaların payı × oran; yayındaki konuya bilet gelmez.
  ↳ Kademe konusu `tier`'ı modülün kademesi tutunca yayındadır, ek özellik `world.features`'ta adı geçince. `world.planned` planda olanı işaretler.
  ↳ Konu ilk biletiyle ya da isteğiyle satır olur (`since_day`); yaşı o haftadan sayılır.
- Ek özellik adım çarpanıdır: kullanıcı özelliği (`missing_mult` alanı, bağlı adım `link`) yayında değilken adımı o kadar kısar (`_feature_mult`, `step_factors`);
  ↳ yayında olmayan her kullanıcı konusu adımı kıstığı için, adım ulaşılabilir oranda iken konu zaten yayındadır.
- Defter: istenmiş konu ilk kez yayına çıkınca tarafa `met` satırı (8 hafta); taraf başına tek `late_topic` satırı, `topics.late_weeks`'i geçmiş en eski yayında olmayan konunun kimliğiyle (planda olan dahil).
- Etkilenen sipariş: kademe konusunda `gain({"tier": …})`, ek özellik konusunda `gain({"features": [konu]})` (çıkınca gerçekten kazanılan teslim edilmiş sipariş);
  ↳ Yorum ve Puan (`link` = `returning`) kademeyle haftada iade edilmeyecek sipariş (teslim × iade oranı farkı); mağaza konusunda derdi olan mağazaların siparişi × `_leave_rate`.
- Sayılar ondalıklı kalır; defter satırı `{key, arg, points, weeks}` (`weeks` WHILE=-1 koşul sürdükçe), metin değil kimlik. Gün alanları hafta sayısıdır, hiç değişmemişin günü `NEVER`.
- Ayarı değişebilecek seçimler tek sabitte: fiyata yansıma `stores.pass_through` (0 = komisyon siparişi düşürmez), gelir penceresi `income.window_weeks` (1 = bu hafta × 4,33), iade kargosu seçenekleri `rules.options.return_shipping`,
  ↳ mağaza kazanımının yayınla başlaması `acquisition_of` içindeki `published` kapısı.

## Metin anahtarları

- Çekirdek oyuncuya görünen metin üretmez; arayüz kimlikten kurar.
- Tür ve modül verisi: `PROD_TYPE_MARKETPLACE_*`, `PROD_DESK_*` (beş masa), `PROD_CONCEPT_*` (ağ etkisi, tavuk ve yumurta), `PROD_LINE_MARKETPLACE_*`, `PROD_STEP_MARKETPLACE_*`, paylaşılan hatların `_MARKETPLACE_DESC` satırları.

## Testler

- Probe: `"$GODOT" --headless --path . -s res://scripts/debug/marketplace_probe.gd -- --marketplace-probe=weeks=<n>` (varsayılan 40); `MPPROBE WEEK` hafta başına, `MPPROBE CHECK <ad> PASS|FAIL`, son satır `MPPROBE SUMMARY`.
  ↳ FAIL varsa süreç 1 ile, argüman hatasında 2 ile çıkar. `class_name` eklendiği için önce `--import`.
- Denetimler: `empty_category_no_orders`, `acquisition_waits_for_publish`, `leaving_zone_stores_fall`, `lock_rejects`, `campaign_override_expires`, `revenue_window_spike`, `premium_closed_no_perk_cost`,
  ↳ `campaign_free_shipping_single_write`, `preview_figures`, `known_store_earnings`, `known_return_rate`, `known_order_rate`, `json_roundtrip`, `ledger_expiry`, `zone_limits_consistent`, `constants_switch`,
  ↳ `gain_and_weakest`, `acquisition_multipliers`, `store_terms_discount`, `premium_members`, `zone_rows_need_stores`, `add_users_bounds`, `lost_counters`, `channel_read_values`, `source_revenue_values`, `state_survives_codec`,
  ↳ `topic_rows_known`, `topic_ticket_gates`, `topic_ledger_rows`, `feature_gain_matches_close`, `reviews_affected_is_return_gap`.

## Dikkat

- `Dictionary.merged(x)` varsayılanda var olan anahtarı ezmez; dünya ve durum birleştirmelerinde hep `merged(x, true)`.
- `:=` Dictionary erişiminden tür çıkaramaz (Variant); bu dosyada her sözlük okuması açık türle (`var x: float = ...`) yazılır.
- "Sipariş" teslim edilendir; "Sipariş verdi" adımı `order` ayrıdır. "Geç teslimat" satırı teslim ÷ verilen oranına bakar: 0,97 × Siparişler çarpanı × Entegrasyonlar çarpanı × hata çarpanı, eşik 0,90.
  ↳ Bu yüzden satır v1.0'dan beri açık kalır ve ancak Siparişler 2 + Entegrasyonlar 2 (0,912) ya da Siparişler 3 + Entegrasyonlar 1 ile kalkar; üç açık hata yeniden açar.
- Kargo bedava ayrıcalığının payı saklı kuraldan okunur (`state.policy.shipping.pick`), kampanyanın ezmesinden değil: "Hep mağaza öder"de 0, "Büyük sepette mağaza öder"de büyük sepetler sayılmaz. Kampanya haftasında kalan siparişin kargosu
  ↳ kampanya satırına yazılır; iki satırın toplamı her zaman teslim × kargo bedelidir.
- "Zorlanıyor" ve "Kazancı yetmiyor" defter satırları yalnız mağazası olan kategoriye yazılır; "Seçenek az" tersine mağazası azken yanar.
- Önizleme çipleri `world.week`'ten başlayan dört kapanışın sonudur (kilit süresi); olay, acil durum ve kampanya kaybı koşulmaz, Pazarlama'nın değerleri sabit kalır.
- `world.features` katalogdaki konu kimliğini taşır; sistem ürünün ek özellik kartını bu kimliğe eşler. Kimlikler eşleşmezse konu hiç yayına çıkmış sayılmaz,
  ↳ adımı kısmaya ve "Geciken talep" satırı kalıcı olmaya devam eder.
- JSON turundan sayılar float, anahtarlar metin döner; model gün ve sayaçları `int(...)` ile okur. Kişi kimlikleri `assign` ve `stars` anahtarıdır, metin olmalı.
- Kodlayıcı tam değerli ondalığı tam sayıya çevirir (`SaveCodec._normalize_number`): iki durum değerini bölen yer bir tarafı `float(...)` okur (`retention`, `returning_share`, `_leave_rate`);
  ↳ yeni bölme de öyle yazılır, `state_survives_codec` (probe) ve `marketplace_save_roundtrip` (`retention`'ın bölmesi, gerçek kayıt yolu) sınar.
- Sabitler `static var _c` ve `_cats`'ta durur (dosya yüklenince okunur); probe `constants_switch` sabiti çalışırken değiştirip geri koyar.
- Probe çıkışında motor bazen `ObjectDB instances leaked` ve `resources still in use` satırı basar; sonuçları ve çıkış kodunu etkilemez. Probe bir kapıya bağlanırsa (`ERROR:` satırı vakayı düşürür) bu satır bağışlanmalı.

## Bir değişiklik yaparken

- Yeni defter satırı: sayı `marketplace.json` `ledger.rows`'ta, koşulu `_settle`'da; süreli satır yazan işlev `_add`'i çağırır.
- Yeni konu: `topics.catalog`'a kayıt (`side`, `module`, kademe konusuysa `tier`, kullanıcı ek özelliğiyse `missing_mult`, bağlı adım ya da mağaza derdi `link`, `base`, `rate`);
  ↳ kodda değişiklik gerekmez. Yeni mağaza derdi `topics.pains`'e girer.
- Yeni ayrıcalık ya da kural: `premium.perks` ya da `rules.options` kaydı, `_close_category` (kullanım ve gider), `premium_pull` ve `set_*` şartları.
- Yeni önizleme büyüklüğü `metrics`'e girer; `_preview` hepsini otomatik fark alır. Önizleme `set_*` işlevlerini kopyada çağırır;
  ↳ probe'daki `preview_figures` çipleri bağımsız sayılarla (`store_keep` oranı, defter puanı ve haftada 5 puan tavanı) karşılaştırır.
- Modül ekle ya da değiştir: `lines/marketplace.json` (kimlik hattı sayısı 5, dağılım tasarım 2, geliştirme 2, test 1; test hattının K3'ü `bug_tracker`), CSV'de ad, kademe adları ve `_DESC`, `rivals.json` `tiers`.
- Sistem paketi bağlarken: çekirdek `GameState`'i okumaz; `world`'ü o hafta kurup `close_week`'i çağırır, sonra `monthly_revenue` ve `monthly_cost`'u kayıtlara ve Finans'a yansıtır.
