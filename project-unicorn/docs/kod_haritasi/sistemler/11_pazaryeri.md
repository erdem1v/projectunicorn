# Pazaryeri

Ne yapar: B2C ürünün pazaryeri ekonomisinin saf çekirdeği: mağaza ve kullanıcı akışı, dört adım, iade, gelir, iki memnuniyet defteri, dört kural, Premium, dört haftalık önizleme, Talepler'in konu ve biletleri, Pazarlama'nın iki okuması.
Oyuna kısmen bağlı: `MarketplaceSystem` durumu (`GameState.marketplace`, yazan seam ve kapanış ilk kez çalışınca doğar) yazar ve haftalık kapanışı `daily_tick` ile koşturur; pazaryeri türünde Satış yuvası onu haftada bir çağırır (`SalesSystem.daily_tick`), tür B2C'nin tür ekranında seçilir; Satış yuvası pazaryeri koşusunda PAZARYERİ penceresini kurar (`tabs/marketplace/marketplace_page.gd`, sayfa 08); alt sayfalar Genel, Kategoriler ve Politikalar (`tabs/marketplace/mp_overview.gd`, `mp_categories.gd`, `mp_policies.gd`; Premium sonra, ortak parçalar `mp_parts.gd`). Tür seçilince (`SprintSystem.choose_type`) Satış Temsilcisi işe alınabilir, Ekip'in Satış hücresi açılır (`ProductSystem.has_sales_desk`) ve Satış işi yayına kadar uykuda durur (`HRSystem.job_waiting_key`); vaka `marketplace_sales_role_opens`. Ürün penceresinin başlığında ikinci ölçü ve gazetenin nüfus hücresi bu türde mağaza sayısıdır (`ProductModel.live` `header.payers`, defterin `stores`'u); Ekip'te Satış Temsilcisi'nin ipucu mağaza kazanımını söyler (`HRConstants.role_phase_hint`). Frank'in çekinin dördüncü adımı bu türde "İlk sipariş" okunur ve geçen haftanın teslim edilen siparişi yuvarlanınca en az 1 olunca tamamlanır (`ChequeRead.steps`; vaka `marketplace_cheque_first_order`). Gelir alanı (tek yeteneği Ücretli plan; sayfası pazaryerinde yok) pazaryerinin alanlarında yoktur (`SprintCatalog.areas_for`; vaka `marketplace_paid_plan_waits_for_premium`): kart sprint adayında, liderin ve PM'in önerisinde ve modül listesinde çıkmaz. Vakalar ve probe çağırır; arayüzün önizlemeleri aynı model işlevlerini okur (Politikalar: `policy_open`, `lock_left`, `preview_policy`, yazan `set_policy`; oyuncu yolu vakası `mp_policy_locks_after_apply`).
Kaynak: `docs/tasks/PRD_PAZARYERI.md` §3 (ekonomi), §9 (sabitler), §10 (test). Sahip: `MarketplaceModel` (statik, durumsuz) ve onu oyuna bağlayan `MarketplaceSystem` (statik, durumun tek yazarı).

## Dosyalar

- `systems/marketplace_model.gd` (1361): `MarketplaceModel`; yalnız `static` işlevler. `state` ve `world` sözlüklerinin alanları dosya başındaki yorumda.
- `systems/marketplace_system.gd` (340): `MarketplaceSystem`; yalnız `static` işlevler. `GameState.marketplace`'in tek yazarı, yazan seam'ler, sözleşme okuyucuları, `world()` ve haftalık kapanış.
- `debug/marketplace_probe.gd` (1340): `-s` betiği; oynanan çizelge ve 46 mekanik denetimi, `MPPROBE ...` satırları.
- `data/product/categories.json` (16): altı kategori ve sütunları: sepet, sipariş sıklığı (`order_freq`: yol kusursuzken kullanıcının haftalık siparişi), kâr payı, sektör iadesi, gereken mağaza, başlangıç komisyonu, taban ilgi, büyük sepet payı, reklam havuzu (`ad_pool`, haftalık arama).
- `data/product/lines/marketplace.json` (153): modül verisi; 5 kimlik hattı (Ürün Yükleme, Vitrin, Sepet ve Ödeme, Siparişler, Yorum ve Güvence)
  ↳ Mobil, Entegrasyonlar, Kullanıcılar ve Yetki, Yedekleme `shared.json`'dan; Üyelik, Gelir alanının `cap_paid_plan`'ı.
  ↳ Yayın şartının dört adlı modülü (Ürün Yükleme, Vitrin, Sepet ve Ödeme, Siparişler) `sprint.json` `mvp_named["marketplace"]`'da.
  ↳ Tür ekranında (`ProductCatalog.TYPE_SCREEN` `b2c.playable`) dört masa sayılır: ürün geliştirme, kategoriler, politikalar, kampanyalar; Premium masasının metni CSV'de durur. Rakipler `RivalCatalog.NAMES` ve `rivals.json`, Piyasa yuvaları (Orinoco, Bidwell, Dealflock) `companies.json` `sector_slots`.
- `data/product/marketplace.json` (130): öbür bütün sabitler, gruplu: `visits`, `steps`, `stores`, `rules`, `commission`, `store_terms`, `premium`, `ledger`, `income`, `preview`, `topics` (konu kataloğu ve mağaza dertleri).

## Giriş noktaları

- Sistem (`MarketplaceSystem`): `TYPE_ID` ("marketplace"), `MODULE_LINES` (modelin dokuz modülünden oyundaki hat kimliğine; paylaşılan dört hat `@marketplace` son ekiyle; Üyelik hattı değil `SprintCatalog.PAID_PLAN`).
  ↳ `world()` her çağrıda sahiplerden kurulur: `week` `GameState.day`, `published` `ProductState.is_live()`, `tiers` ve `bugs` hat kimliğiyle, `stars` atanmışların Satış yıldızı (kurucu 1), `unanswered` Destek'in cevapsız bildirim payı (`SupportSystem.unanswered_share`), `planned` kartı koşan sprintte ya da sonraki sütunda duran kademe konularının kimliği (`_planned`); `features` bağlı değil (ek özellik kartları sonraki pakette); kalan alan modelin varsayılanında.
  ↳ `cardless` sprint kartı olmayan konuların kimliğidir (`MarketplaceModel.extra_topics()`: ek özelliklerin hepsi); model bu konulara bilet yazmaz, onları gecikmiş saymaz, adımlarını kısmaz.
  ↳ Yazan seam'ler (`true` uygulandı ve sinyal yayıldı, `false` reddedildi): `open_category`, `set_commission`, `set_policy`, `set_fee`, `set_perk`, `set_trial`, `set_store_terms`, `add_users`, `open_topic`, `assign`, `unassign`.
  ↳ Olay motorunun iki yazan seam'i (oyunda çağıranı henüz yok): `waive_commission(hafta)` (izleyen kapanışların brüt komisyonu 0; 1'den azı false), `add_satisfaction(kayıt, puan)` (kullanıcı kaydında `users`, mağaza kaydında `stores` defterine modelin `note_decision`'ıyla süreli "decision" satırı; başka kimlikte false, durum doğmaz; kaydın memnuniyeti hemen oynamaz, izleyen kapanışlarda hedefe yürür); vaka `marketplace_event_seams`.
  ↳ `assign(kişi, kategori)`: yalnız işbaşındaki (`STATUS_ACTIVE`) kurucu ya da Satış Temsilcisi (`assignable()`) ve açık kategori. Atama kişiye Ekip'te Satış işini de verir (`CharacterRegistry.assign_job`, modelden önce; iş tavanında atama reddedilir, model reddederse bu çağrının verdiği iş geri alınır); kurucunun sprint payı Satış işindeki kadar azalır. `at_job_cap(kişi)` seçicinin tavan kuralıdır (Satış yok, sürekli işler duraklamışlarla birlikte dolu; Ekip'in kaydı gibi).
  ↳ `unassign(kişi)` atamayla gelen Satış işini kaldırır; Satış Temsilcisi işi işe alımda almıştır, işi kalır ("Değiştir": yeni kişi atanır, eskisi çıkar). Pazaryerinde kategorisiz Satış işi Ekip'te bekler (`HRSystem.job_waiting_key(iş, kişi)`, `HR_TASK_WAITING_CATEGORY`). Ekip'te Satış işi kalkan ya da işten ayrılan kişinin ataması kapanış beklemeden düşer: `assignment_changed` ve `character_removed` dinlenir (`_watch_staffing`; ilk `assign`'da ya da yüklemede `fill_missing_state`'te bağlanır); Ar-Ge'nin duraklattığı Satış işi atamayı tutar ama `world().stars`a girmez, o hafta kazandırmaz.
  ↳ İzinli ve eğitimdeki kişi işini ve atamasını korur ama `world().stars`ta olmadığı için o hafta kazandırmaz. Kazanımın yıldızı `sales_stars(kişi)` (kurucu 1); arayüz aynı okuyucuyu çizer. Vakalar `marketplace_assign_next_week`, `marketplace_assign_gives_sales_job`; oyuncu yolu `mp_assign_reads_first_week`.
  ↳ `_reflect` iki toplu `CustomerRegistry` kaydını (`STORES_ID` `co_mp_stores`, `USERS_ID` `co_mp_users`; `b2c`, `individual`, yayından sonraki ilk kapanışta doğar) yalnız seam'le yazar: komisyon mağazalar kaydının, üyelik kullanıcılar kaydının MRR'ı (eksi net komisyonda MRR 0'da durur, `revenue_weeks` eksiyi saklar),
  ↳ koltuk mağaza sayısı ve ücret ödeyen üye (`MarketplaceModel.paying_members`), memnuniyet modelin `sat`'ının tam sayısı; en sonda `SalesSystem.reflect_mrr()`. `CustomerRegistry.account_count` `individual` kayıtları saymaz; yatırımcı görüşmesinin yoğunlaşma sorusu da yalnız `get_by_market("b2b")`e bakar.
  ↳ Kitle okuyucuları (Satış'ın altı kitle seam'i pazaryeri türünde bunlardan okur ve `add_users`'a yazar): `users()` aktif kullanıcı, `new_users()` geçen haftanın yeni kullanıcısı (bütün kaynakların ilk haftası), `paying_members()` ücret ödeyen üye (denemedekiler sayılmaz), `lost_users()` kapanışlarda kaybedilenin birikmiş toplamı,
  ↳ `users_change_per_hour()` aktif kullanıcının akışı, takvim saati başına: geçen haftanın yeni kullanıcısı eksi elde tutulamayan kullanıcı (`users() × (1 − elde tutma)`; kayıp bugünkü kullanıcıyla orantılıdır, bu yüzden kapanıştan sonra gelen `add_users` ve `set_policy` sonucu kaydırır). `growth_band` bunu -0,1 / 0,15 / 0,6 eşikleriyle okur; 1.000 kullanıcının (`SalesSystem.MP_BAND_PER_USERS`) üstünde akış kullanıcı sayısına oranlanır.
  ↳ Okuyucular saklanan durumdan okur, kapanış koşturmaz: `policy_value`, `channel_read`, `source_revenue`, `source_new_users`, `week_gmv` (öbür ekiplerin sözleşmesi), `week_commission()` (komisyonsuz bir haftanın bedeli: modelin `week_commission`'ı yuvarlanmış; olay motoru okuyacak) ve `stores()` (açık kategorilerin mağaza toplamı, `_reflect` kullanır). Okuyucu ve `world()` boş durumu doldurmaz: `read_state()` boşken modelin ilk durumunu saklamadan okur; arayüz modelin saf okuyucularını `read_state()` ve `world()` ile çağırır (pencerenin başlığı ve kare dünyası bugün öyle okur).
  ↳ `daily_tick()` yalnız ürün yayındayken: `world()` kurar, `close_week`, `tick_topics`, `_reflect`, Finans'ın `pazaryeri` kalemi (`daily_rate(monthly_cost)`, her kapanışta, sıfır dahil), bir `marketplace_changed`. Satış yuvası onu yalnız pazaryeri türünde çağırır (`SalesSystem.is_marketplace`). Durum yazan seam'de ve kapanışta (`_s()`) `MarketplaceModel.new_state()` ile yerinde dolar; pazaryeri koşusu olmayan oyunda hiçbiri çalışmaz, sözlük boş kalır.
  ↳ `fill_missing_state()` yüklenen durumda olmayan her anahtarı (iç içe sözlüklerde de) `new_state()`'ten tamamlar, var olan değere dokunmaz, boş durumu doldurmaz; `SaveManager.apply_loaded_state` yüklemenin sonunda çağırır, şema numarası değişmez.
- Kurma: `new_state()`, `new_world()` (varsayılanlı dünya; verilmeyen alan `WORLD`'den okunur), `cat_ids()`, `cat_def(kategori)`, `open_ids(state)`,
  ↳ `cfg("steps.reach")` `marketplace.json`'u nokta yoluyla okur (olmayan yol motor hatası verir, varsayılan dönmez; sözlük ve dizi kopya döner; arayüz ulaşılabilir oranı, komisyon sınırını ve kural seçeneklerini buradan alır).
- Haftalık kapanış: `close_week(state, world)` bağlayıcı sırayla `state`'i değiştirir (mağaza akışı, ziyaret ve adımlar, iade, kullanıcı, gelir ve gider, Premium, defter); sinyal ve kayıt çağıranındır.
  ↳ Kapanış `state.lost`'a kaybı ekler (`users` += kullanıcı × (1 − elde tutma), `stores` += ayrılan mağaza); iki sayı birikmiş toplamdır.
- Biletler: `tick_topics(state, world)` kapanıştan sonra, haftada bir koşar; her konunun o haftaki biletini son dört haftaya yazar.
  ↳ Konu durumu (`waiting`, `planned`, `shipped`) kapanışın 7. adımında dünyadan duruma yazılır (`_status`), defter satırları oradan çıkar.
- Yazan işlevler (`true` uygulandı, `false` reddedildi): `open_category`, `set_commission`, `set_policy`, `set_fee`, `set_perk`, `set_trial`, `open_premium`, `set_store_terms`,
  ↳ `add_users(state, n)` (olayın kullanıcı ekleyişi ya da çıkarışı, `n` eksi olabilir; kullanıcı sayısı değişmediyse false); kilit `lock_left(gün, world)`.
  ↳ `assign(state, kişi, kategori)` `state.assign[kişi] = {cat, live: false}` yazar (kapalı kategori ya da kişi orada zaten çalışıyorsa false; başka kategoriye taşıma `live`'ı sıfırlar), `unassign(state, kişi)`; `close_week` kazanımı hesaplayınca her atamayı `live` yapar, `acquisition` yalnız `live` ve `stars`ta olan kişiyi sayar (atamadan sonraki ilk kapanış atlar).
- Acil durum: `waive_commission(state, hafta)` bir hafta komisyon almamak (haftalar toplanır, 1'den azı false; sistemin aynı adlı seam'i çağırır); `note_outage(state, puan, bedel)` izleyen kapanışa kesinti yazar (ikisi de 0 ise false; oyunda çağıranı henüz yok);
  ↳ `week_commission(state)` geçen kapanışta alınacak komisyon (açık kategorilerin `week.due` toplamı: (teslim − iade) × sepet × komisyon, yeni mağaza şartının payı düşülmüş; kampanyanın ve üye indiriminin şirketçe karşılanan kısmı, komisyonsuz hafta ve kesinti girmez; kapanıştan sonraki komisyon değişikliği oynatmaz; ilk kapanıştan önce 0);
  ↳ `lost_commission(state, sipariş)` kaçan siparişin komisyonu (açık kategorilerin geçen haftaki teslim payıyla ağırlıklı sepet × komisyon, teslim yoksa eşit ağırlık, iade düşülmez);
  ↳ `backup_mult(world)` Yedekleme'nin kesintide kaçan siparişe çarpanı: modül yokken 1, kademeleriyle 0,7; 0,5; 0,3 (`ledger.rows.outage.backup`).
- Okuyanlar: `policy_value` (kampanyanın ezmesi önce), `store_keep` ve `zone` ve `zone_limits` (mağazaya kalan, bölge, çubuğun iki sınırı), `variety`, `acquisition_of` (bir kişi), `crew` (kategoriye atanmış kişiler: `person`, `live`, `working`, `weekly`; işbaşında olmayanın yıldızı dünyada yok, `weekly` 0, `live` olmayan getireceği sayıyı yazar) ve `acquisition` (canlı ve işbaşındaki `crew`'un `weekly` toplamı), `return_rate`, `price_pass`,
  ↳ `step_factors` (adımın modülleri `STEP_MODULES`; hata çarpanı yalnız `BUG_STEPS`'teki Sipariş verdi ve Teslim edildi adımında) ve `weakest_step`, `gain(state, world, kategori, değişiklik)`, `monthly_revenue` ve `monthly_cost`, `target_sat`, `premium_pull`, `returning_share`, `retention`.
  ↳ Genel'in okuyucuları: `funnel(state)` açık kategorilerin geçen haftaki toplamı (`visits`, `organic`, `channel`, `returning`, `cart`, `checkout`, `order`, `delivered`; ilk kapanışını bekleyen kategori 0 katar);
  ↳ `step_hint(state, world, adım)` = `module` (adımın ilk modülü, son kademedeyse sonraki), `tier`, `next_tier` (son kademede 0), `next_gain` (sıradaki kademenin açık kategorilerdeki `gain` toplamı), `bugs` (adımı kısan açık hata: `BUG_STEPS`'teki adımda modüllerindeki açık hata, Sepete ekledi ve Ödemeye geçti adımında 0), `bug_gain` (onların düzelmesinin `gain` toplamı);
  ↳ `ledger_worst(state, taraf)` tarafın en ağır olumsuz defter satırı (eşitlikte koşul sürdükçe duran, o da eşitse listede önce gelen), olumsuz satır yoksa `{}`.
- Pazarlama'nın okuması: `channel_read(state, world, kategori)` = `conversion` (ziyaretten teslim edilen siparişe), `monthly_commission` (alışverişini bu kategoride yapan kullanıcının aylık net komisyonu; kategorinin payı hesaba girmez),
  ↳ `organic` (kendiliğinden haftalık ziyaret), `margin`, `base_interest`, `ad_pool`;
  ↳ `source_revenue(state, world, kaynak)` = kaynaktan son on iki haftada gelenlerin (elde tutmayla küçülmüş) son dört haftada bıraktığı net komisyon;
  ↳ kullanıcı o dört haftanın burada olduğu kadarıyla sayılır (bu hafta gelen dörtte bir), yani yeni kanalın satırı küçük başlar;
  ↳ `source_new_users(state, kaynak)` = kaynağın geçen kapanışta getirdiği yeni kullanıcı (`sources[kaynak]`'ın ilk hücresi; hiç ziyaret getirmemiş kaynakta 0); vaka `marketplace_source_new_users`.
  ↳ `gmv(state, kategori)` = kategorinin geçen haftaki satış hacmi (teslim edilen sipariş × sepet; iade düşülmez); sistemde `week_gmv()` açık kategorilerin toplamı (Pazarlama reklam harcamasının satışlara oranını bununla yazar); vaka `marketplace_week_gmv`.
- Talepler (sistem): `request_topics()` modelin `topic_rows`'u ve her satıra `card_id`: kademe konusunda modülün o kademesinin adım kimliğiyle `feat:<adım>` (hat `MODULE_LINES`'tan, adım `ProductLines.step_at`ten; `SprintCatalog` adayının kimliğiyle aynı kalıp), ek özellikte `ext:<konu>` (kartı sonraki pakette doğar);
  ↳ `open_topic(kimlik, etkilenen)` modelin `open_topic`ini çağıran yazan seam (uygulanınca sinyal, reddedilen çağrı yaymaz).
  ↳ Satırın durumu (`waiting`, `planned`, `shipped`) okunduğu anda ürünün kademesinden ve sprint planından gelir, "Karşılandı" kapanışta yazılır.
  ↳ `MarketplaceModel.tier_topics()` kademe konularının modülünü ve kademesini verir.
  ↳ `topic_name(kimlik)` konunun oyuncuya görünen adının tek okuyucusu: kademe konusunda modülün o kademesinin adı (`SprintCatalog.step_name`), ek özellikte `MP_TOPIC_<KİMLİK>` metni; defter satırının konusu ve Talepler'in adı (`ProductModel._market_topics`) buradan okur.
- Talepler (model): `topic_rows(state, world)` ilk isteği gelmiş her konunun satırı (`id`, `side`, `module`, `tickets`, `affected`, `share`, `reason`, `status`, `age`, `source`);
  ↳ konu kimlikleri `marketplace.json` `topics.catalog`'ta, metin yok. `share` etkilenen siparişin geçen haftanın teslim edilenindeki payıdır; `status` verilen dünyadan okunur (`_status`).
- Rapordan açılan konu: `open_topic(state, world, kimlik, etkilenen)` bileti olmayan konunun satırını açar (`since_day` = hafta, `source` = `report`, haftalık etkilenen sipariş `topics[konu].affected`); katalogda olmayan ya da satırı açık konuda false.
- Önizleme: `project(state, world)` kopyada dört kapanış koşar; `preview_commission`, `preview_policy`, `preview_premium` değişiklikli ve değişiklikssiz farkı döndürür (`metrics` anahtarları; `store_earnings` oran, öbürleri fark);
  ↳ reddedilen değişiklikte `{}`.

## Sinyaller

`EventBus.marketplace_changed()`: tek yayıncı `MarketplaceSystem`; uygulanan her yazan seam, her haftalık kapanış ve atama düşüren her iş değişimi ya da işten ayrılış bir kez yayar, reddedilen çağrı yaymaz.

Hatırlatıcı: `MailClock.reminders()` pazaryeri türünde (`SalesSystem.is_marketplace()`), ürün yayındayken ve `MarketplaceModel.open_ids(read_state())` boşken `mp_no_category` satırını verir (kimliği ve türü aynı; ilk kategori açılınca kalkar, geliş saati öbür hatırlatıcılar gibi `MailClock`tan). Gelen kutusu onu gönderen "Pazaryeri" ve konu ÜRÜN olarak listeler; tıkı Satış penceresini açar, pencere kategori yokken Kategoriler'de açılır (`marketplace_page.gd` `_active`); vaka `marketplace_no_category_reminder`.

## Durum ve veri

- Durumun evi `GameState.marketplace` (`initialize_run` boşaltır, ERP koşusunda boş kalır; kodlayıcı `GameState` alanlarını kendisi bulur, göç yok: şema 20); `marketplace_save_roundtrip` `retention`'ın bölmesini, `marketplace_save_fills_missing` silinmiş anahtarların yüklemede tamamlanmasını gerçek kayıt yolunda sınar.
- `state` dosya başındaki yorumda sayılır; `sat[taraf]` iki memnuniyettir (sistem paketi `CustomerRegistry` kaydına yansıtır), `burn[kalem]` son kapanışın haftalık `pazaryeri` giderinin adlı kalemleri,
  ↳ `premium.orders` son dört haftanın üye siparişidir, `lost` birikmiş kayıp, `topics[konu]` (`tickets` son dört hafta yeni önde, `since_day`, `status`, `source`).
- Talepler: bilet kullanıcı konusunda bağlı adımda sayılan büyüklük × oran, mağaza konusunda derdi olan mağazaların payı × oran; yayındaki konuya ve `world.cardless`'taki konuya bilet gelmez.
  ↳ Kademe konusu `tier`'ı modülün kademesi tutunca yayındadır, ek özellik `world.features`'ta adı geçince. `world.planned` planda olanı işaretler.
  ↳ Konu ilk biletiyle ya da isteğiyle satır olur (`since_day`); yaşı o haftadan sayılır.
- Ek özellik adım çarpanıdır: kullanıcı özelliği (`missing_mult` alanı, bağlı adım `link`) yayında değilken adımı o kadar kısar (`_feature_mult`, `step_factors`);
  ↳ `world.cardless`'taki özellik kısmaz. Kartı olan her kullanıcı konusu yayına çıkana kadar adımı kıstığı için, adım ulaşılabilir oranda iken kartı olan konuların hepsi yayındadır.
- Bilet oranı (`rate`) olmayan konu bilet almaz (`_tickets`): `coupon_abuse` (kullanıcı, Sepet ve Ödeme, ek özellik, adım çarpanı yok) yalnız `open_topic` ile satır olur; satırın `affected`'ı verilen sayıdır ve konu
  ↳ `world.features`'ta adı geçince yayına çıkar (etkilenen 0; "Karşılandı" öbür konular gibi; kartı olmadığından `world.cardless`'tadır, gecikmez).
  ↳ Model eksik konuyu varsayılanla okumaz: yükleme `fill_missing_state` ile eksik konuyu `new_state`'ten tamamlar.
- Defter: istenmiş konu ilk kez yayına çıkınca tarafa `met` satırı (8 hafta); taraf başına tek `late_topic` satırı, `topics.late_weeks`'i geçmiş, yayında olmayan (planda olan dahil) ve `world.cardless`'ta olmayan en eski konunun kimliğiyle.
  ↳ `note_decision(state, taraf, puan)` olayın kararını tarafın defterine argümansız `decision` satırı olarak yazar (`ledger.rows.decision.weeks` = 8 hafta; her karar ayrı satır; 0 puan false); ad `MP_ROW_DECISION`.
- Etkilenen sipariş: kademe konusunda `gain({"tier": …})`, ek özellik konusunda `gain({"features": [konu]})` (çıkınca gerçekten kazanılan teslim edilmiş sipariş);
  ↳ Yorum ve Puan (`link` = `returning`) kademeyle haftada iade edilmeyecek sipariş (teslim × iade oranı farkı); mağaza konusunda derdi olan mağazaların siparişi × `_leave_rate`.
- Acil durum: `state.waive` kalan komisyonsuz hafta; kapanış alınacak komisyonu (`week.due`, yeni mağaza şartının payı düşülmüş; komisyonsuz haftada da yazılır) net'e katmaz ve birer azaltır,
  ↳ şirketin karşıladığı indirim ve kupon yine düşer, net eksiye inebilir. `state.outage` bekleyen `{points, cost}`: kapanış `points`'i kullanıcı defterine −`points` "Kesinti" satırı olarak (`rows.outage.weeks` hafta) yazar,
  ↳ `cost`'u o haftanın toplam net komisyonundan düşer (`revenue_weeks`'e giren toplam; kategori satırına bölünmez; komisyonsuz haftada düşmez, çünkü o haftanın komisyonu zaten 0), sonra ikisini sıfırlar.
  ↳ Kesinti `world`'de değil `state`'tedir: yazan tek sefer çağırır, kapanış tüketir. Model eksik alanı varsayılanla okumaz: yükleme `fill_missing_state` ile eksik `waive` ve `outage`'ı `new_state`'ten tamamlar.
- Sayılar ondalıklı kalır; defter satırı `{key, arg, points, weeks}` (`weeks` WHILE=-1 koşul sürdükçe), metin değil kimlik. Gün alanları hafta sayısıdır, hiç değişmemişin günü `NEVER`.
- Ayarı değişebilecek seçimler tek sabitte: fiyata yansıma `stores.pass_through` (0 = komisyon siparişi düşürmez), gelir penceresi `income.window_weeks` (1 = bu hafta × 4,33), iade kargosu seçenekleri `rules.options.return_shipping`,
  ↳ mağaza kazanımının yayınla başlaması `acquisition_of` içindeki `published` kapısı.

## Metin anahtarları

- Çekirdek oyuncuya görünen metin üretmez; arayüz kimlikten kurar. İki kaydın adı `MP_STORES_RECORD` ve `MP_USERS_RECORD` (`{product}` ürün adı); hatırlatıcının konusu `MP_REMINDER_NO_CATEGORY`.
- Tür ve modül verisi: `PROD_TYPE_MARKETPLACE_*`, `PROD_DESK_*` (beş masa), `PROD_CONCEPT_*` (ağ etkisi, tavuk ve yumurta), `PROD_LINE_MARKETPLACE_*`, `PROD_STEP_MARKETPLACE_*`, paylaşılan hatların `_MARKETPLACE_DESC` satırları.

## Testler

- Probe: `"$GODOT" --headless --path . -s res://scripts/debug/marketplace_probe.gd -- --marketplace-probe=weeks=<n>` (varsayılan 40); `MPPROBE WEEK` hafta başına, `MPPROBE CHECK <ad> PASS|FAIL`, son satır `MPPROBE SUMMARY`.
  ↳ FAIL varsa süreç 1 ile, argüman hatasında 2 ile çıkar. `class_name` eklendiği için önce `--import`.
- Denetimler: `empty_category_no_orders`, `acquisition_waits_for_publish`, `leaving_zone_stores_fall`, `lock_rejects`, `campaign_override_expires`, `revenue_window_spike`, `premium_closed_no_perk_cost`,
  ↳ `campaign_free_shipping_single_write`, `preview_figures`, `known_store_earnings`, `known_return_rate`, `known_order_rate`, `json_roundtrip`, `ledger_expiry`, `zone_limits_consistent`, `constants_switch`,
  ↳ `gain_and_weakest`, `acquisition_multipliers`, `store_terms_discount`, `premium_members`, `zone_rows_need_stores`, `add_users_bounds`, `lost_counters`, `channel_read_values`, `source_revenue_values`, `state_survives_codec`,
  ↳ `topic_rows_known`, `topic_ticket_gates`, `topic_ledger_rows`, `feature_gain_matches_close`, `reviews_affected_is_return_gap`, `assignment_waits_a_close`,
  ↳ `waive_zeroes_one_close`, `outage_row_and_cost`, `lost_commission_weighted`, `backup_mult_tiers`, `open_topic_report_row`, `cfg_reads_constants` (okuyanın boşalttığı kopya sabiti değiştirmez),
  ↳ `funnel_sums_categories`, `step_hint_matches_gain`, `ledger_worst_picks_heaviest`, `crew_follows_assignment`,
  ↳ `returning_orders_follow_frequency` (geri gelen kullanıcı sipariş sıklığı kadar sipariş verir; sıklık açık kategoriler arasında
  ↳ bölünür), `word_of_mouth_brings_users` (memnun kullanıcı tavsiye oranı kadar kullanıcı getirir), `decision_row_drifts` (kararın satırı, hedefe yürüyüş, süre sonu).

## Dikkat

- `SalesSystem._tick_satisfaction` her `b2c` kaydın memnuniyetini B2C hedefine sürükler: pazaryeri koşusunda koşarsa iki kaydın `sat` yansımasını ezer; bu yüzden `SalesSystem.daily_tick` pazaryeri türünde yalnız `MarketplaceSystem.daily_tick`i çağırır ve `hourly_tick` kitle akışını ve kitleden MRR türetimini koşturmaz (`SalesSystem.is_marketplace`).
- Cevapsız pay Destek'in kapanıştan önce çalışan haftalık raporundan etkilenmez: `reports_incoming` ve `reports_per_day`dan okunur, haftalık sayaçtan okunmaz. Pazaryerinde Destek kayda memnuniyet zararı yazmaz (`SupportSystem.apply_daily_satisfaction_damage` `SalesSystem.is_marketplace()`te döner); zarar kullanıcı defterinin `support_backlog` satırıdır (pay × −20, en çok −10, koşul sürdükçe her kapanışta yeniden yazılır).
- `Dictionary.merged(x)` varsayılanda var olan anahtarı ezmez; dünya ve durum birleştirmelerinde hep `merged(x, true)`.
- `:=` Dictionary erişiminden tür çıkaramaz (Variant); bu dosyada her sözlük okuması açık türle (`var x: float = ...`) yazılır.
- "Sipariş" teslim edilendir; "Sipariş verdi" adımı `order` ayrıdır. "Geç teslimat" satırı teslim ÷ verilen oranına bakar: 0,97 × Siparişler çarpanı × Entegrasyonlar çarpanı × hata çarpanı, eşik 0,90.
  ↳ Bu yüzden satır v1.0'dan beri açık kalır ve ancak Siparişler 2 + Entegrasyonlar 2 (0,912) ya da Siparişler 3 + Entegrasyonlar 1 ile kalkar; üç açık hata yeniden açar.
- Kargo bedava ayrıcalığının payı saklı kuraldan okunur (`state.policy.shipping.pick`), kampanyanın ezmesinden değil: "Hep mağaza öder"de 0, "Büyük sepette mağaza öder"de büyük sepetler sayılmaz. Kampanya haftasında kalan siparişin kargosu
  ↳ kampanya satırına yazılır; iki satırın toplamı her zaman teslim × kargo bedelidir.
- "Zorlanıyor" ve "Kazancı yetmiyor" defter satırları yalnız mağazası olan kategoriye yazılır; "Seçenek az" tersine mağazası azken yanar.
- Önizleme çipleri `world.week`'ten başlayan dört kapanışın sonudur (kilit süresi); olay, acil durum (bekleyen kesinti ve komisyonsuz hafta dahil) ve kampanya kaybı koşulmaz, Pazarlama'nın değerleri sabit kalır.
- `world.features` katalogdaki konu kimliğini taşır; sistem ürünün ek özellik kartını bu kimliğe eşler (sistem henüz bağlamadı, boş kalır). Kimlikler eşleşmezse konu hiç yayına çıkmış sayılmaz:
  ↳ `world.cardless`'tan çıkarılmış bir konu adımı kısmaya devam eder ve "Geciken talep" satırı kalıcı olur.
- JSON turundan sayılar float, anahtarlar metin döner; model gün ve sayaçları `int(...)` ile okur. Kişi kimlikleri `assign` ve `stars` anahtarıdır, metin olmalı.
- Kodlayıcı tam değerli ondalığı tam sayıya çevirir (`SaveCodec._normalize_number`): iki durum değerini bölen yer bir tarafı `float(...)` okur (`retention`, `returning_share`, `_leave_rate`);
  ↳ yeni bölme de öyle yazılır, `state_survives_codec` (probe) ve `marketplace_save_roundtrip` (`retention`'ın bölmesi, gerçek kayıt yolu) sınar.
- Sabitler `static var _c` ve `_cats`'ta durur (dosya yüklenince okunur); probe `constants_switch` sabiti çalışırken değiştirip geri koyar.
- Probe çıkışında motor bazen `ObjectDB instances leaked` ve `resources still in use` satırı basar; sonuçları ve çıkış kodunu etkilemez. Probe bir kapıya bağlanırsa (`ERROR:` satırı vakayı düşürür) bu satır bağışlanmalı.
  ↳ `cfg_reads_constants` bilerek iki `SCRIPT ERROR: Invalid access to property or key 'nope'` basar (olmayan yol hatası); kapıya bağlanırsa onlar da bağışlanmalı.

## Bir değişiklik yaparken

- Yeni defter satırı: sayı `marketplace.json` `ledger.rows`'ta, koşulu `_settle`'da; süreli satır yazan işlev `_add`'i çağırır.
- Yeni konu: `topics.catalog`'a kayıt (`side`, `module`, kademe konusuysa `tier`, kullanıcı ek özelliğiyse `missing_mult`, bağlı adım ya da mağaza derdi `link`, `base`, `rate`; bileti olmayan, rapordan açılacak konuda `base` ve `rate` yok);
  ↳ kodda değişiklik gerekmez. Yeni mağaza derdi `topics.pains`'e girer.
- Kapanışa bir kez tüketilen yeni girdi (komisyonsuz hafta, kesinti gibi): `state`'e bekleyen alan (`new_state`), `close_week`'te okuma ve sıfırlama ya da azaltma, `project`'te temizleme; `world` alanı olmaz, `state_survives_codec` yeni alanı da kapsar. Durumdaki her yeni anahtar eski kayıtta yoktur: `fill_missing_state` ilk durumun değeriyle tamamlar; ilk değer süren oyunda yanlışsa (var olan durumdan türemesi gerekiyorsa) göç gerekir.
- Yeni ayrıcalık ya da kural: `premium.perks` ya da `rules.options` kaydı, `_close_category` (kullanım ve gider), `premium_pull` ve `set_*` şartları.
- Yeni önizleme büyüklüğü `metrics`'e girer; `_preview` hepsini otomatik fark alır. Önizleme `set_*` işlevlerini kopyada çağırır;
  ↳ probe'daki `preview_figures` çipleri bağımsız sayılarla (`store_keep` oranı, defter puanı ve haftada 5 puan tavanı) karşılaştırır.
- Modül ekle ya da değiştir: `lines/marketplace.json` (kimlik hattı sayısı 5, dağılım tasarım 2, geliştirme 2, test 1; test hattının K3'ü `bug_tracker`), CSV'de ad, kademe adları ve `_DESC`, `rivals.json` `tiers`.
- Çekirdek `GameState`'i okumaz; `MarketplaceSystem.world()` o haftanın dünyasını kurup `close_week`'i çağırır. Yeni bir sahip girdisi (Pazarlama, cevapsız pay, ek özellikler) `world()`'e girer; yedek dal yazılmaz.
- Yazan seam modelin aynı adlı işlevini (`add_satisfaction` `note_decision`'ı) `_s()` ve (`set_trial`, `set_store_terms`, `add_users`, `waive_commission`, `add_satisfaction` dışında) `world()` ile çağırır; yeni yazan seam `_written` ile sarılır ki sinyal tek yerden yayılsın. Okuyucu `_s()` değil `read_state()` kullanır.
