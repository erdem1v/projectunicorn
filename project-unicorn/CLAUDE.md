# Project Unicorn — ajan giriş noktası
Bu dosya bugün geçerli kuralları ve gerçekleri taşır. Kod haritası: `docs/kod_haritasi/README.md`.

## 1. Oyun bugün
Oyuncu bir teknoloji girişimi kurar ve onu Series A'ya taşımaya çalışır; oyun Türkçe ve İngilizce oynanır. Koşu
tek yönlü üç evreden geçer: Bootstrap → Traction → Series A Hunt. Her evre runway'i yeniden daraltır; hiçbir evrede
yetkin bir oyun "kasa artıyor, karar kalmadı" noktasına varmamalıdır. İki pazar farklı oynanır: B2B (hesaplar,
sözleşmeler) ve B2C (kitle, ağızdan ağıza). Fon merdiveni: kurucunun birikimi → Frank'in MRR eşiğinde gelen tek
çeki (tur değil, tek karar) → dört VC'den biriyle term sheet'li seed → aynı dört VC ile Series A. Series A imzası
zaferdir. Kasa eksiye düşünce 4 haftalık [WORKING] kepenk sayacı başlar; sıfıra inerse şirket iflas eder. Yumuşak
tavan 104 oyun haftasıdır ([WORKING], yaklaşık 24 ay). Demo Bootstrap'tan Series A kararının sonuçlanmasına kadar
sürer, 60 ile 90 dakika [WORKING] hedefler. Sonların tam kümesi, koşulları ve demo/EA/full farkı GDD ile kodda
ayrışıyor: `docs/ACIK_ISLER/ACIK_KARARLAR.md`.

## 2. Tasarım otoritesi
- Otorite `GDDs/`'dir: v2 bölümleri (ch01–14), modül GDD'leri (Ürün ch03 dosyasındadır; Ekip, Ar-Ge, Satış) ve
  olay motoru için `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`, zaman modeli için `GDDs/GDD — ZAMAN MODELİ.md`.
  Hangi dosyanın yürürlükte olduğu `GDDs/README.md`'de.
- GDD ile `GDDs/GUNCELLEMELER.md` çelişirse ek belge geçerlidir.
- Motor md'si makineyi, ch11 olay içeriğini yönetir; eşittirler. Kod md'den ayrılırsa ayrılık md'nin §27'sine yazılır.
- Bir GDD ötekini açıkça geçersiz kılabilir: ch09 → ch01 §4; Ekip → ch02 §2/§6/§10, ch01 §5, ch06 §1.2, ch12 §8.
- GDD sessiz, belirsiz ya da açıkça çözülmemiş biçimde çelişkiliyse **dur ve sor**. Mekanik, içerik, mimari icat edilmez.
- [ÇALIŞMA] / [WORKING] / [K] işaretli sayı kalibrasyon girdisidir; kodda tek bir ayar sabitinde durur.
- GDD'de adı ya da kuralı geçen ama henüz bağlı olmayan kod ve içerik, bağlı değil diye silinmez.
- GDD ile kod ya da sahip kararı arasındaki bilinen ayrılıklar `docs/ACIK_ISLER/ACIK_KARARLAR.md`'dedir; burada anlatılmaz.

## 3. Çalışma kuralları
- İş doğrudan `main`'e commit'lenir; dal, worktree, rebase yok. Gerekli görünürse dur ve sor. Push yalnız Erdem
  "push et" dediğinde yapılır; "geri al" revert demektir. Bir kapı, onu iddia eden commit'ten önce yeşildir.
- Tasarım sabiti (ayar değeri, eşik, isteklilik (E) modeli sabitleri, kapı ya da toplantı ağırlığı) değişikliği raporda
  **"onay bekliyor"** altında listelenir. Önce tasarım notu yazılır; uygulama, test emekliye ayırmak dahil, onaydan sonra.
- Kalibrasyonda ölç ve raporla, sabit değiştirme. Harness ya da bot değişikliği serbesttir, ayrı raporlanır.
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`'deki açık maddelere dokunulmaz; onaylananlar tek tek uygulanır.
- TR metni onaysız değişmez; onay bekleyen metin commit mesajında "TR/EN onay bekliyor" diye işaretlenir. Frank'in
  külliyatı Erdem'indir: yeni Frank satırı yalnız taslaktır, onaysız ekrana çıkmaz.
- Rapor: madde madde ✅ / ⚠️ / ❌ + kanıt (dosya:satır, commit, test adı). Tahmin yazılmaz.
- Godot MCP eklentisi ve git kökündeki `.mcp.json` kalır. `addons/` üçüncü taraf koddur, dokunulmaz.

## 4. Verimlilik
Hızlı ve doğru çalış. Süreyi uzatan ya da token harcayan gereksiz işlem yapma: ihtiyacın olmayan dosyayı okuma,
gerekmeyen testi koşma, aynı şeyi iki kez doğrulama. Bir şeyi bulmak için önce `docs/kod_haritasi/README.md`.

## 5. Oyuncuya görünen metin
- **BILINGUAL BIRTH LAW.** Oyuncuya görünen her metin bir anahtar olarak doğar. Anahtarlar
  `localization/strings.csv`'de (`keys,tr,en`); `Localization` autoload'u CSV'yi açılışta okur.
- **Önce İngilizce.** Oyuncu metni önce İngilizce yazılır. Türkçe ayrı bir yerelleştirme adımıdır: çeviri değil,
  sahneyi Türk okur için yeniden yazmak. Mühürlü Türkçe metinler olduğu gibi kalır.
- Script ve sahnede oyuncuya görünen literal yazılmaz; sahne metni anahtarın kendisidir. Birleşik metin
  `tr(KEY).format({ad})`: yalnız adlı yer tutucu, `%s`/`%d` yok, araya giren değer ek almaz (`Sözleşme: {company}`
  olur, `{company}'nin sözleşmesi` olmaz), CSV değerinde çıplak süslü parantez yok. Durumda metin değil id saklanır.
  Özel adlar çevrilmez. `static func` içindeki `tr()` derlenir ama çalışırken ölür.
- **LANGUAGE INTEGRITY LAW.** `docs/design/localization_glossary.md` bağlayıcıdır. TR metinde İngilizce yalnız izinli
  ödünç kelimelerde kalır: pitch, startup, demo, momentum, MRR, runway, churn, burn, laptop, mail, VC, hotfix, onboarding
  ve özel adlar. Türkçe büyük harfte ödünç kelime gövdesi Latin I'yı korur, ardındaki Türkçe ek Türkçe kurala uyar
  (`Fmt.upper`, gövde listesi `Fmt.LOANWORD_STEMS`: SPRINT, "İlk sprinti" → İLK SPRINTİ). Tek metinde dil karışmaz.
  Oyuncuya görünen hiçbir metinde tire (— –) yoktur (ch01 §9). Satır başında duran etiket büyük harfle başlar ve CSV'de
  öyle yazılır; cümle ortasında da okunan metin küçük kalır, satır başında büyük ikizi (beceri adı `HRUiShared.skill_label`,
  `SKILL_LABEL_*` değil) ya da `Fmt.cap_first` okunur.
- Motorun bilmediği etki ya da koşul taslakta `[VOCAB?]` / `[COND?]` kalır ve kart bağlanmaz (ch11 §3). Oyuncu
  metnini kimin yazdığı açık karardır (`docs/ACIK_ISLER/ACIK_KARARLAR.md`).
- Kartlar `text.tr` ve `text.en` bloklarını aynı id kümesiyle taşır. Her seçenek gerçek bir kaynağa mal olur ve
  sonucu arayüzde görünür bir yere düşer; bedelsiz seçenek yalnız açık bir "beat"tir. Metin gözlemler, hüküm vermez;
  hüküm yalnız Frank'in ağzındadır (ch11 §7). Kilitli seçenek gerekçesiyle görünür; gerekçe kendi bilgeliğini söylemez
  ("Fiyatlarını zaten iki kez indirdin", "Bu hesabı fiyat değil ürün tutar" değil). Gerçek marka, UI talimatı, sekme
  ya da düğüm adı yok. Gün sınırında ateşlenen kart saat yazmaz: ekrana mesai penceresinde, çekilmiş bir geliş
  saatinde gelir (§6). Seçeneğin anlattığını modifier'ları yapar.
- **EFFECT-VISIBILITY RULE.** Modifier oyuncuya okunur etiketle gösterilir, iç kodla değil. Etki çipini kuran tek yer
  `EvChips.describe` (`scripts/events/present/chips.gd`; imzalı parçalar, kırmızı yalnız tehlike); bilinçli etiketsiz
  fiiller `EvChips.SILENT_VERBS`'te, `event_chip_coverage` smoke'u zorlar. Bir fiilin tutarı seam'den gelebilir
  (`amount_seam` × `amount_mult`); çip, geçmiş satırı ve bot tutarı aynı `EvEffects.amount`'tan okur, çip uygulananı yazar.

## 6. Mimari
- Godot 4.6 (Forward Plus), yalnız GDScript. Ana sahne `scenes/main/Main.tscn`; `main.gd` açılışı, modal montajını,
  karar kapısını ve debug bayraklarını taşır. Merkez görünüm `scenes/office/OfficeView.tscn`'dir (SubViewport'ta 3B
  ofis); sekmeler üstünde `WindowLayer` pencereleridir. Tasarım tabanı 1920×1080; `DisplaySettings.BASE_VIEWPORT` bunu
  elle yansıtır.
- Autoload'lar (`project.godot` sırası): EventBus, GameState, CharacterRegistry, CustomerRegistry, ProspectRegistry,
  PromiseRegistry, RivalRegistry, InvestorRegistry, TimeManager, SaveManager, Settings, Localization, AudioManager;
  sonra `MCPRuntime` (`addons/godot_mcp_runtime`, MCP köprüsü).
- `scripts/systems/` statik `RefCounted` sınıflardır; TimeManager saatlik ve günlük tiki dağıtır, EventBus sinyal
  merkezidir.
- **Zaman.** Bir oyun günü (tik) bir haftadır; hafta sonu yoktur. `GameState.day`, sistemlerin `daily_tick`'i ve
  `EventBus.day_advanced` adlarını korur ve tik sayar; her tik 24 saatlik tik ve bir günlük tik taşır. Zaman
  sabitlerinin ve birim dönüştürücülerinin tek evi `TimeModel`'dir: süre hafta verisidir ve `TimeModel.ticks()` ile
  okunur, `*_PER_DAY` oranları gün verisi kalır ve tikte `TimeModel.per_tick()` ile ×7 uygulanır. Takvim 1 Ocak 2012
  Pazar'da başlar ve her tik bir Pazar'dır; tarihi, ayı ve yılı yalnız `GameState.get_date_dict` verir. Hız merdiveni
  `TimeModel.SECONDS_PER_HOUR = [0.0, 2.5, 1.25, 2.5 / 3.0]` saniye / oyun saati: duraklat / 1× / 2× / 3×
  [WORKING]. Hafta 08:00'de başlar; varsayılan mesaide (09:00'dan 17:00'ye) hafta 1×'te 22,5, 3×'te 7,5 saniye sürer.
  Mesai bitip ofis boşalınca gecenin saatleri tek toplu adımda koşar (`TimeManager.skip_night`); saati dışarıdan
  ileri taşıyan öbür kapı `TimeManager.advance_hours(n)`'dir (toplantı kapanışı, smoke, probe).
- **Teslim saati.** Saatin ürettiği mail, kâğıt, not, hatırlatıcı, Frank'in satırı ve haber bandının canlı satırı
  mesai penceresi dışında düşmez (gün sınırı dahil): şirketin penceresinde (`WorkHoursSystem.company_window()`) bir
  geliş saati alır ve ondan önce gösterilmez (`MailClock`; yayılım 4 saat, bir haftalık kâğıtta 1 saat [WORKING]).
  Acil olan (`terminal_warning` ya da `urgent` etiketli kart, kâğıdın son uyarısı, giriş notu) üretildiği anda gelir;
  oyuncunun kendi isteği (hatırlatıcının düğmesi) hemen gelir. Öğenin `at`'ı mutlak dakikadır (tik × 1440 + günün
  dakikası), -1 saatsizdir ve her zaman gösterilir. Mesaj dış kutuda bekler (`GameState.mail_outbox`,
  `MessageSystem.post`, `MailClock.hourly_tick` teslim eder); kart kendi deposunda (`EvQueue`, `EvPapers`,
  `EvHistory`) `at` ile bekler ve onu GÖSTEREN okuyucu `MailClock.delivered` sorar, VARLIĞINI soran (`EvQueue.has/
  holds/ids`, `EvPapers.has/keys_of`, `EventGate.instances_of/on_desk`) sormaz. Hatırlatıcılar durumdan türediği
  için geliş saatleri `GameState.desk_arrivals`'tadır. Kuyruğun görünürlük süzgeci tek yerdedir (`EvQueue._shown`) ve
  gece kapısı da oradadır: mesai penceresi dışında yalnız acil durum kartı (`urgent` etiketi) açılır; kepenk kartı ve
  kâğıdın son uyarısı da mesai başına kadar bekler.
- **Acil durum.** Acil durum bir sistemin zarıdır (`IncidentSystem`, durum `GameState.incident`; gece kesintisi, ay sonu kapanışı,
  ödeme, sürüm sonrası bozulma, yorum fırtınası): 00:00'ın günlük diliminde zar yalnız karar verir, kart damgadan sonraki ilk tam
  saatte istenir (mail kartın açılışından önceki damgayı taşıyabilir: `EventGate.request`'in `stamp`'ı) ve `TimeManager.hold_clock("incident")`
  toplu gece adımını o saatte durdurur; karar verilince tutuş kalkar ve gece kaldığı yerden sürer. Olay reddedilirse (kart kapısı)
  başlamamış sayılır: aralık sayacı, bedel ve tutuş ilerlemez. Bedel olaydan türer (`IncidentSystem.plan`): çip, geçmiş satırı
  ve uygulama aynı sayıyı okur. "Sprinti durdur" hattın düzeltme kartını koşan sprintin başına alır (`sprint_fix_first`,
  `SprintSystem.put_first`) ve çip sprintten kayan kartın adını yazar.
  Zarın ihtimali açık hatadan ve sunucu kademesinden gelir; sunucunun doluluğu (`IncidentSystem.load_mult`: yük %90'a
  kadar 1, %100'e kadar 1,5, üstü ya da kapasitesiz canlı ürün 2,5) tavandan sonra yalnız kesintinin şansını büyütür
  ve kesinti kartı zar anındaki yükü yazar. Kapasiteyi yalnız oyuncu ve açtığı Otomatik ayarla değiştirir
  (`InfraSystem`); dolu sunucunun başka bedeli yoktur. Sayılar `data/product/sprint.json` `incident` bloğunda
  [WORKING].
- **Söz olayı.** Sprintin son haftasında bu sprinte söz verilmiş kart ekibin hızıyla yetişmiyorsa sistem `product.promise_due`'yu
  ister (`SprintSystem.late_promise`, `_ask_promise`): sprintin tek kesintisi sayılır ve o hafta karar kâğıdı çekilmez. Hamleler:
  testi kısalt (`sprint_card_test`: kalan test işi yarıya iner ve test gereken testin yapılan payı kadar hata yakalar,
  `SprintBugs.catch_rate`), fazla mesai, sözü bir sprint ileri al (`PromiseRegistry.extend`, bir kez, hesabın izine bedel) ya da bırak
  (`PromiseRegistry.break_promise`). İlk ikisi kartı gönderir (`SprintSystem.send`): testi bitmişse düzeltmesi bitmese de kapanışta
  sürüme çıkar ve düzeltilmemiş bulunan hata kartın hattında açık hata olur; öbür ikisinde kart kalan düzeltmesiyle devreder. Çip yüzde
  yazmaz, sonucu yazar. Mesainin moral bedeli ve ek sürenin izi kartın (`promise_due.json`) seçeneklerinde [WORKING].
- **Hata modeli.** Kartın hatası test bittiği an belirlenir (`SprintBugs`, sayılar `data/product/sprint.json` `bugs` bloğunda
  [WORKING]): beklenen hata H = c × kartın puanı × R × tür × (1 − PM hazırlığı) × Σ iş payı × m(Δ) × TİTİZ, R kartın Geliştirme
  aşamasındaki Yazılım kapısı (kilitsiz kart 1★), Δ = kişinin Yazılım yıldızı − R, m(Δ) = 0,20 × 0,5^(Δ ÷ 2). Kartın tohumundan
  Poisson(H) çekilir (`RngStreams` ilerlemez, plan ile kapanış aynı sayıyı görür); testin yakaladığı pay 0,57 × √Y(Test), kendi
  geliştirdiğini test eden ×0,6. Bulunan her hata kartın Geliştirme satırına düzeltme işi ekler (5,3 ya da 1,3 puan), kart
  düzeltmesi de bitince biter, bitmeyen kart kalan işiyle devreder. Kaçan hata kart sürüme çıkınca kartın kendi hattında açık hata
  olur (v1.0'dan önce `pending_faulty`'de bekler, yeniden yazılmış hatta yazılmaz) ve sürüm kaydına `escaped` yazılır; "sürüm
  sonrası bozulma" acil durumu onu okur.
- **PM hazırlığı.** PM sprint puanı üretmez (`SprintSystem.team()`'de `points` 0: kapasiteye girmez, hiçbir karta atanmaz);
  haftasını sonraki sütunda bir sprintte hiç koşmamış özellik ve istek kartlarını hazırlamaya verir (`SprintPrep`, sayılar
  `data/product/sprint.json` `prep` bloğunda [WORKING]). Hazırlık işi kartın puanının %20'sidir; PM'in hızı
  P(s) = 15 + 10 × √((s − 2) ÷ 8) puan/hafta (s Ürün puanı: 1★ 15, 3★ 22, 5★ 25) çarpı çalışma saati, verim, huy ve sprint
  payıdır. Kural A: kartlar karmaşıklığa (puan × Yazılım kapısı R) göre büyükten küçüğe dizilir, PM'ler yıldızdan aza; her PM'e
  sprintin sonuna dek kalan hazırlık kapasitesiyle orantılı ardışık bir dilim düşer (en karmaşık dilim en iyi PM'e) ve kartın Ürün
  kapısını geçemeyen PM'in payı en yakın uygun PM'e kayar. Bir kartı tek PM hazırlar, hazırlayan (`prep_by`) kendisi ekipte
  durdukça değişmez. Hazırlığın biten oranıyla orantılı olarak kart hazırlayan PM'in yıldızından fayda alır: her aşamada hız
  (`prep_gain`, `SprintSystem._work`: 1★ %10, 5★ %25, arası doğrusal) ve hata yükünde azalma (`prep_cut`, H'nin (1 − PM hazırlığı)
  terimi: 1★ ×0,90, 5★ ×0,60). Sonraki sütunu oyuncunun "→"u, onaylı PM planı ve liderin önerisi doldurur (devirde de); sütun
  boşsa PM'in hazırlayacak kartı yoktur. Olayın düzeltmesinin moral bedelini hattın kartını hazırlayan PM de öder (`payers`).
- **Karar kâğıdı.** Sprint başına tek zar (`SprintSystem._request_decision`): sprint iki haftadır, zar ilk haftanın
  sonunda, `data/product/sprint.json` `decision.sprint_chance` ihtimaliyle sprintin bir kartı için `decision.cards` havuzundan bir kâğıt
  istenir, yoksa sprint kâğıtsızdır ([WORKING]: sprintlerin en az üçte biri). Havuz ağırlıklı sırayla denenir (görülmemiş kâğıt önde,
  `decision.seen_weight`) ve her kâğıt 52 haftada bir, koşuda en çok 3 kez gelir (`latch`, `latch_key: run`). Kâğıt beklerken kartı ilerlemez ve ona kimse atanmaz; cevap gelince haftanın ataması baştan yapılır ve ekip karta döner (`_clear_decision`). Kesinti sırası: söz olayı
  ya da acil durum gelen sprintte kâğıt gelmez; kâğıt gelen sprintte `IncidentSystem` yalnız servisin çöktüğü acil durumu (kesinti,
  ödeme; `IncidentSystem.SERVICE_DOWN`) yaşatır, öbür acil durum kaybolmaz, sonraki sprinte kalır (`record_interrupt("paper")`,
  `GameState.incident.shifted`). Konuşan kâğıdın kartında o fazda çalışan kişidir: kartın JSON'unda `speaker_role`, `stage`, `pool_group` yazılır, konuşan `EventGate.request(id, {"employee": id})`
  ile (kurucu `{"founder": id}`) kartın `assignees`'inden, rolü ve fazı uyan ilk kişiden bağlanır; PM kâğıdını çeyreğin PM'i söyler
  ve konusu sprintteki müşteri isteği kartıdır; payı Destek'te kalan kişi konuşmaz (ayrıntı `docs/kod_haritasi/sistemler/02_urun_sprint.md`). Kâğıdın bedeli seçeneğin kendisidir ve çipte sayıyla yazılır: kartın puanı, yapılmış işin silinmesi, hemen düşen hata (`damage_product`) ve hattın yeniden yazımı (`line_harden`: hatta 26 hafta yeni hata düşmez). PM, tasarımcı ve testçi kâğıtları bedeli ayrıca kartın işini sonraki sprinte bırakarak (`sprint_card_trim`: karttan pay çıkar, takip kartı sonraki sprinte girer), kartı bilinen hatayla çıkararak (hata kart çıkınca kendi hattında açık hata olur), hesabın memnuniyetine (`trust_delta`, kart çıkana kadar sürebilir) ya da kitleye yazar; renk kâğıdı tek karttır, iki gelişi vardır. Sistem kâğıdı `product.sprint_late` (kurucu tekken `sprint_late_solo`) yalnız kartı bekleyen biri varken gelir.
- **Sürüm anı.** Sprint kapanışı sürüm çıkardığında (`SprintBridges.thank`, sürüm kaydına `thanks`) sözü tutulan, isteği
  karşılanan ve acil durumu hızla kapanan B2B hesapları teşekkür notu yazar (`customer.release_thanks`, tek düğmeli not
  kartı): hesap sürümde en çok bir, sürüm en çok üç not alır, öncelik söz, istek, acil durum sırasıdır. B2C güncellemesinin
  notu bir tik sonra 2–3 öne çıkan yorum taşır (`SprintBridges.pick_reviews`, sürüm kaydında `reviews`, mesai içinde
  `at`). Sayılar `data/product/sprint.json` `thanks` ve `reviews` bloklarında [WORKING].
- **Destek raporu.** Müşteri İlişkileri'nin en yüksek puanlı temsilcisi (`CustomerRepSystem.ranked_reps()[0]`) haftalık tikte, haftada en
  çok bir, gelen kutusuna rapor yazar (`SupportSystem.weekly_report`, mesaj türü `support_week`, saati durdurmaz); temsilci yoksa ya da
  haftada yeni bir şey yoksa gelmez. "Yeni" bir hattın Öncelikli eşiğe varması, boşalması ya da düzeltmeyle azalması, en kötü hattın
  değişmesi (önceki en kötü hat o hafta azaldıysa ya da yeni en kötü hat onu `REPORT_WORST_LEAD` [WORKING] açık hatadan az
  geçtiyse değil) ve temsilcinin yetişememesidir (cevapsız bildirim haftanın gelenlerinin beşte biri ya da fazlası,
  `REPORT_BEHIND_ONE_IN` [WORKING]); okunmamış eski rapor yenisi gelince düşer. Düğme en kötü hattın alanını Ürün SPRINT'te açar.
- **Ofis.** Şirket Ev'de başlar (1 masa, kirasız); İş hanı 13 masa ve ayda $4.000, Plaza 38 ve $8.000, Loft 70 ve $18.000
  (`OfficeConstants.CATALOG`, kurucu bir masa tutar). Taşınmanın tek şartı paradır: kasa iki aylık kirayı karşılar
  (`OfficeSystem.can_move_to`); bu peşin kira karar anında bir kez düşer (`FinanceSystem.apply_one_time_cost`, kimlik
  `office_upfront`), taşınma bir hafta sürer ve bulunulan ofisin kirası varış haftasından her tik `office` kalemine yazılır
  (`OfficeSystem.daily_tick`, finanstan önce). Masa tavanı yalnız ofiste vardır: kadro (kurucu dahil) masaya varınca arama
  başlamaz (`HRSearchSystem.can_start`) ve masadaki dosyalar işe alınmaz (`HRSearchSystem.hire` null döner: arama sürerken
  dolu ofise taşınan şirket); evde sınır yoktur ve masadan büyük ekiple taşınmak serbesttir, herkes gelir. Ofisin ödülü marka sıçramasıdır: bir kademeye koşuda ilk varış markayı bir kez yükseltir (`OfficeConstants.CATALOG` `brand`: İş hanı 3, Plaza 6, Loft 10; `OfficeSystem.brand_jump`, varılan kademeler `offices_reached` bayrağında), aşağı taşınınca marka geri alınmaz.
- Ay kapanışı sessizdir: günlük dağıtımın 0. yuvasında ay defteri kapanır ve `EventBus.month_ended` yayılır; haber
  şeridine 10. yuvada tek satır düşer; modal açılmaz. Dönem özeti oyuncunun seçtiği sıklıkta
  gelen kutusuna mesaj olarak gelir (`summary_frequency`: haftalık, aylık, çeyreklik ya da yıllık; varsayılan
  çeyreklik; `SummarySystem`, `EventBus.summary_ready`).
- **WRITE-THROUGH LAW.** Hiçbir olay, modal ya da UI başka bir alanın durumunu doğrudan yazmaz; değişiklik durumun
  sahibinin seam'inden geçer ve UI'nin dinlediği yerde seam sinyal yayar. Seam yoksa kurulur, alan "bir kereliğine"
  yazılmaz. Seam'ler: müşteri → `CustomerRegistry.set_mrr / set_seats / set_satisfaction / add / remove` (yayar; kalıcı memnuniyet izi `set_trust_offset` ve hesabın pazar referansı `set_market_ref`, sinyalsiz);
  toplam MRR yalnız `SalesSystem.reflect_mrr()`; kasa, burn, marka, itibar → `GameState.set_*`; faz →
  `GameState.advance_phase()` (`set_phase` yalnız kayıt ve debug içindir); karakter → `CharacterRegistry.*`; ürün →
  `SprintSystem.*` (`GameState.product`'ın yazarı; köprüsü `SprintBridges` yalnız `requests`,
  `rival_hits`'i ve verilen sürüm kaydının `thanks`'ini yazar) ve `ProductState.*` (açık hata deposunun tek yazarları `add_bugs` ve `clear_line_bugs`); tek seferlik gider → `FinanceSystem.apply_one_time_cost`; gecenin acil durumu → `IncidentSystem` (`GameState.incident`'ın yazarı). `GameState.flags` sistem durumudur: içerik ona sahibin adlı fiiliyle yazar (tek
  kapı `set_game_flag` beyaz listesi); motorun kendi hafızası `EvFlags`'tadır.
- Olay motoru autoload değil; tek girişi statik `EventGate.request(event_id: String, context: Dictionary = {})`.
  Sistem kartın adını verir, kartı kurmaz. Kartlar `data/events/cards/<kategori>/` altında JSON'dur ve
  `version_scope` ile `EvTuning.SHIPPED_SCOPES`'a göre süzülür (`_fixtures/` yalnız test içindir); arklar
  `data/events/arcs/`'ta. İçerik durumu yalnız `scripts/events/seams/`'ten okur. Invariant'lar: motor GDD §0.3.
  Kart ekrana gelince `main` saati tutar (`TimeManager.hold_clock("event")`) ve Olaylar gelen kutusunu kartın
  üstünde açar; cevaba kadar başka her pencere yalnız okunur, tek yüklem `EventGate.active_id() != ""` (motor md
  §11.3). Karar olmayan anlar `MessageSystem` mesajıdır.
- Gelir: B2B hesabı kurucunun oynadığı satış toplantısı ve pazarlıkla ya da atanmış temsilcinin işlediği lead'le
  kazanılır; temsilcinin planı dolunca müşterinin baktığı bir alan ürünün beklentisinin altındaysa kapanış ürün uyumuna
  bağlı bir zarla kaybedilebilir (`ProductQuality.close_chance`) ve kayıp haftada en çok bir mailla gelir, kalanı haftalık
  özetin satırıdır. Hesap imzada adayın ürüne uyumuyla açılır (tabanlar kalır) ve memnuniyeti hesabın kendi uyumuna kayar
  (`ProductQuality.account_fit`; hesabın kullandığı hatlardaki açık hata düşer, güven defteri eklenir). 3★ ve üstü hesap
  Kurumsal olmayan sunucuda imzalarsa sözleşmesine sunucu maddesi yazılır: 8 hafta içinde Kurumsal'a geçilmezse müşteri hakkını
  kullanır; süre dolduğu tikte ve her ay başında memnuniyeti eşiğin 20 puandan az üstündeyse fesih bildirir (4 hafta sonra
  sözleşme biter, hesap kayıp sayılır), değilse hakkını saklı tutar. Yalnız Kurumsal sunucuya geçiş maddeyi karşılar ve bildirimi
  geri aldırır, güvenlik sertifikası karşılamaz; Kurumsal'dan inilmez (`B2BSalesSystem`, `InfraSystem.set_provider`). B2C'de kitle her
  oyun saatinde iki yönlü değişir; MRR ödeyen kullanıcı × fiyat olarak saatlik türetilir.
  Kitlenin büyüme ve erime terimi, B2C memnuniyetinin hedefi ve fiyat önerisi ürünün kitleye uyumunu okur
  (`ProductQuality`, kitle bağlamı; `SalesSystem.b2c_quality`): kitle büyüdükçe beklenti yükselir. Ürün sayfasının sözcüğü ve
  cümlesi B2C'de kitlenin yıldızı ile 2★'ın büyüğünü okur (küçük kitlede de 2★ satırı); ekonomi sayfanın referansını okumaz.
- Kayıt: JSON; `SaveManager.SCHEMA_VERSION` 19, `MIN_LOADABLE_VERSION` 10. `SaveCodec` GameState değişkenlerini ve
  modellerin `@export` alanlarını kendisi bulur; eski kayıtta varsayılan göç yerine geçtiği için yeni alan anlamlı
  varsayılan taşır. Tarih kayıtta saklanmaz, `GameState.day`'den türer; yıl tutan tek alan `Character.leave_taken_year`'dır ve
  2026 takvimiyle yazılmış değeri `SaveCodec.restore_registries` her yüklemede geri alır (`OLD_CALENDAR_YEAR_SHIFT`).
  Statik durum tutan sistem `SaveManager.reset_all_owners`'a girer. RNG tohumludur (`RngStreams`). Her koşunun kimliği vardır (`GameState.run_id`, metada): yuvalar koşu başınadır (`quick_<run>`, `auto_<run>_<n>`, `manual_<n>`) ve bir koşunun oto kaydı ötekininkini ezmez. Menü koşunun olmadığı yerdir: ana menüye dönüş süreç içi `SaveManager.end_run()` ile koşuyu bitirir ve kabuğu söker.

## 7. UI ve tema — UI/STYLE LAW
1. **Sözlük `UiTokens`'ındır.** Her renk palet tablosunda adlıdır; her boyut merdivendendir (`SIZE_MICRO 9 · META 10
   · SMALL 11 · DATA 12 · BODY 13 · LEAD 15 · TITLE 16 · DISPLAY 22`; editorial `SIZE_ED_* 24 · 26 · 32 · 44 · 52`).
   Ham `Color(...)` ya da ham boyut yazılmaz; duruma bağlı stil helper'dan okunur (`badge_palette`, `D_delta_color`, …).
2. **`themes/master_theme.tres` ve `themes/menajer_theme.tres` üretilmiştir.** Üretici `"$GODOT" --headless --path .
   -s res://scripts/theme/build_theme.gd` (temiz checkout önce `--import`). Token ya da `build_theme.gd` değişikliği
   aynı commit'te `UiTokens.THEME_STAMP`'i artırır ve iki temayı yeniden üretir; debug açılışı iki temadan biri
   bayat damga taşıyorsa uyarır.
3. **Token'ı tema öğesine çeviren tek dosya `build_theme.gd`'dir.** Skala boyutun, varyasyon yüz ve rengin sahibidir.
4. **Sahne ve script yalnız yerleşimin sahibidir** (anchor, separation, margin, min-size); boyut, renk, stylebox
   taşımaz, `theme_type_variation`'a uzanır ya da yenisini ekler. Mevcut literal, çevresi değişince taşınır.
- **Geçiş: iki tema.** Arayüz koyu Menajer Masası diline ekran ekran taşınıyor (sıcak kömür yüzey, açık mürekkep;
  Erdem 2026-10-02). Taşıma bitene kadar proje teması krem `master_theme.tres`'tir; krem token değerleri, `SIZE_*`
  merdiveni, helper gövdeleri ve taban tipleri değişmez. `menajer_theme.tres` taşınan her alt ağacın köküne elle
  atanır; CanvasLayer ve açılır pencere kalıtımı kestiği için her katman kökü ayrıca. Master'ın her varyasyonunu master
  ölçüleriyle koyu renkte taşır, taban tiplerini ve yeni varyasyonları yeni dille kurar; doğrulayıcı eksik varyasyonda
  ya da içerik payı açık kutuda üretimi düşürür. Koyu yüzey yalnız `D_*` token'larını ve `D_` helper'larını okur
  (renk körü ikizleri helper'dadır, merdiven `D_FS_12` … `D_FS_40`). Koyu yüzler Archivo'nun değişken yüzüdür
  (ağırlık ve genişlik ekseni, rakamlar tablo) + Source Serif 4; Archivo'da olmayan glif aynı ağırlıktaki IBM Plex
  Sans'a düşer. JetBrains Mono ve Plex'in metin yüzü yalnız krem ailede kalır, koyu yüzlerin yedek zincirinde Noto
  Sans Symbols 2 yoktur. Gazete iki temada da kremdir. Kontrast kapısı `--theme-contrast-audit`.
- Krem dil: mono yazı, hairline çizgi, amber vurgu; hover dolgu değil kenardır (`ACCENT_DEEP`, kartta `BORDER_HOVER`).
  Gövde krem kâğıttır (sayfa `#F6F1E6`, kart ve pencere `#FBF7EE`, `INK` `#2B2722`); sinematik koyu register
  (`DIALOGUE_*`) `CREAM*` ve `*_CHROME` okur. Tek ada gazetedir (`PaperPanel`, kendi `PAPER_*` merdiveni). 3B
  ofisin renkleri UI token'ı değil sahne verisidir: `OfficeConstants`, `scripts/ui/office/`, `scenes/office/shaders/`.
- **Chrome kuralı.** Çerçeve (TopBar, NewsTicker) koyu temayı okur: iki sahnenin kökünde `menajer_theme.tres`
  atanmıştır ve çerçevenin yazı ile düğme varyasyonları (`HeroValue`, `ClockLabel`, `SpeedKey`, `TickerToggle` …)
  o temada tanımlıdır.

## 8. Kod yazımı
Kod tabanı şiştiği için her iş pahalılaştı; yeni kod aynı hataları tekrarlamaz.
- Kısa ve doğrudan yaz. Tek yerde kullanılan sarmalayıcı ya da yardımcı, tek gerçeklemeli "genel" yapı, okunurluk
  kazandırmayan ara değişken yazılmaz. Uzun if/elif zinciri yerine `match` ya da sözlük.
- Aynı işi yapan ikinci fonksiyon yazılmaz: önce var olan evi ara (`Fmt`, `UiFactory`, `HRUiShared`, `UiTokens`,
  `ProductState.open_bugs`, `SalesConstants.mix` …). Kopyala-yapıştır blok yok.
- İmkânsız durum için savunma kontrolü yazılmaz; null ve sınır kontrolü yalnız gerçekten gelebilen değer içindir.
- Yerini alan kod eskisini aynı commit'te siler. Ölü fonksiyon, sabit, alan, sinyal, CSV anahtarı, asset, smoke vakası
  bırakılmaz; yoruma alınmış kod ve debug `print` commit'lenmez.
- Yorum yalnız bugünkü NEDENİ söyler. Tarihçe ("eskiden", "emekli", tarihler), görev ve karar etiketleri, satır
  numarası, ağaçta olmayan belgeye atıf, kodu tekrar eden yorum yazılmaz; tarihçe git'tedir. JSON `_` notları da öyle.
- İş bittiğinde rapor, plan ya da ölçüm dosyası repoya konmaz.

## 9. Kod review
Her commit'ten önce diff, ayrı bir agent tarafından kıdemli bir mühendis gözüyle incelenir; yalnız diff okunur. Soru:
bu kod en kısa ve en açık doğru hâlinde mi?
- İki satırda yazılabilecek şey on satırda mı yazılmış?
- Kod haritasındaki (`docs/kod_haritasi/SEMBOLLER.tsv`) mevcut bir yardımcı yeniden mi yazılmış?
- İleride lazım olur diye eklenmiş soyutlama, parametre ya da dal var mı?
- Olamayacak durumlar için savunma, tarihçe anlatan ya da kodu tekrar eden yorum var mı?

Bulgular düzeltilir, sonra commit. Neden: şişen kod bir sonraki task'ın keşfini yavaşlatır ve pahalılaştırır.

## 10. Test
Mevcut smoke ve probe paketi eski ve gereğinden büyük; yalın bir paketle değiştirilecek (ayrı bir task). O zamana kadar:
- Her commit'te yalnız dokunulan sistemin ilgili vakalarını koş; tam paketi yalnız push öncesi.
- Yeni smoke vakası yalnız çekirdek mantık için (ekonomi, kayıt, olay motoru) ve ancak gerçekten gerekiyorsa. Arayüz
  doğrulaması smoke'la değil, görsel kabulle yapılır.

## 11. Görsel kabul
Oyuncunun gördüğü bir şeyi ekleyen ya da değiştiren her task, commit'ten önce oyunda görsel olarak doğrulanır (Godot
MCP). UI'a dokunmayan mantık değişiklikleri hariç.
- Task'taki kabul senaryosunu oyna; yoksa değiştirdiğin ekran için kısa bir senaryo yaz ve rapora koy.
- Ekrana fikstürle gel, oyunu baştan oynama.
- Kontrol: öğe yerinde mi, metin taşıyor ya da kesiliyor mu, doğru dilde mi, logda hata var mı. Rapora ekran
  görüntüleriyle koy.
- En fazla 2 düzeltme turu; sonra sorunu ekran görüntüsüyle raporla, commit etme.

## 12. Kapılar ve araçlar
`export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan. CI yok.
- **Sıra:** `"$GODOT" --headless --path . --event-lint` (kabul edilen bulgu gerekçesiyle `tools/lint_baseline.json`'a;
  onu `--event-lint=baseline` yazar, doğrulamada koşulmaz)
  → `"$GODOT" --headless --path . -s res://scripts/debug/loc_residue.gd` → `bash tools/smoke_run.sh loc_csv_integrity`
  → hedefli smoke (`smoke_run.sh <vaka>`, önekler `docs/kod_haritasi/sistemler/10_test_harness.md`'de); tam smoke (`--all`) yalnız push öncesi.
- Motor: `--event-probe`, `--why-fire=<kart id>`, `--event-harness=random:seeds=N:weeks=M | guided[:seeds=N:weeks=M]`,
  `--event-vocab` (`_vocabulary.md`'yi üretir, KEEP bloğu kalır); `python tools/gen_signal_manifest.py`.
- Makullük defteri: `--event-plausibility=<spec>` (kabuğun içinden) ya da
  `-s res://scripts/events/tools/plausibility_main.gd -- --event-plausibility-probe=<spec>`; spec
  `seeds=<N|A-B>:weeks=<N>:variant=<plain|early|both>:preset=<RunProbe preset>`. Ekrana gelen her kartı şema v3'ün
  kurallarına (koruma, makullük, bilinen saçmalık, aile aralığı, `critical` kapsamı) sınar ve `PLAUS FIRE` / `PLAUS FAIL` /
  `PLAUS RATE` / `PLAUS SUMMARY` basar; kapısı `bash tools/plausibility_run.sh` (40 koşu × 16 hafta + `PLAUS LONG` 4 × 60
  hafta, koşu başına ayrı süreç ve kullanıcı dizini; `fails=0` ister).
- Probe: `--run-log=<preset>:<hafta>:sim[:<seed>][:window=<başlangıç saati>-<saat>][:build=ea|full]` (`window=11-13` şirketin mesaisini 11:00 –
  24:00 kurar; `build=` yalnız `sim`'de, EA'da bootstrap zaferi koşuyu bitirmez, `PROBE MILESTONE` basar), preset'ler `RunProbe.PRESETS`'te (ölçek fikstürleri
  `full_run_staff25/50` (B2B merdiveni kurucuyla 25 ve 50 kişiye uzar) ve `b2b_book20/330` (canlı ERP, 20 ve 330 hesap, 6 ve 50 kişi,
  moral sabit); düzeltme kolları
  `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_*`, preset anahtarı `fix`; her sprint başında `PROBE FIX`,
  her hafta `PROBE BUGS` basar; bot acil durum kartını fiile göre cevaplar, `fix_none` erteler, öbürleri sprinti durdurur ve
  durdurduğu anda `PROBE STOP` basar; `*_free` kolları sprinti hiç durdurmaz; `*_desk` kollarında (anahtar `desk`)
  masada temsilci varken kurucu yalnız temsilcilerin yıldız bandının üstündeki adaylarla görüşür; `full_run_quality_core[_desk]`
  (anahtar `core_only`) sprintte Çekirdek dışı özellik ve talep kartı bırakmaz, düzeltme ve araştırma kartları kalır;
  `full_run_vc_product` ve `full_run_b2c_vc_product` seed'de ve Series A'da önce ürün fonuyla (Meridian) oturur; lead'li her
  B2B imzada `PROBE FIT`, satışçının kaybettiği her adayda `PROBE REPLOSS`, kurucunun görüşme ve pazarlıkta kaybettiği her adayda
  `PROBE MLOSS`, her hafta `PROBE UFLUX` basılır;
  `full_run_server_{lean,wide,auto}` ve `full_run_b2c_server_*` kollarında (anahtar `server`) kurucu sunucuyu her
  haftanın açılışında Artır ve Azalt ile yönetir ya da Otomatik ayarla'yı açar, her hafta `PROBE SERVER` basılır); `full_run*`
  botu sunucu maddesi açık hesapların MRR'ı Kurumsal'ın ek faturasını geçince Kurumsal'a geçer, `PROBE END`'in `clause_ended=`
  alanı maddenin bitirdiği sözleşmeleri sayar; `full_run_cash_{spend,hoard}` ve `full_run_b2c_cash_*` kollarında (anahtar
  `cash`) ilk çalışan kasa iki aylık gidere (`spend`) ya da 6,7 aylık gidere (`hoard`, hiç taşınmaz) varınca alınır, öbür kollar
  altı ayda alır ve `full_run*` botu seed'den sonra kasa peşin kira ile bugünkü giderin altı ayını (`spend` iki ayını) karşılayınca bir
  üst ofise taşınır; her karar `PROBE DECISION` satırıdır (masa dolu ofiste bekleyen işe alım bir kez `hire desks_full`)
  ve `PROBE END` `first_hire_week=`, `first_hire_runway=`, `move_weeks=` basar); her koşunun `PROBE END`'i destek raporunun
  sıklığını da basar: `support_reports=` (rapor gelen hafta / canlı üründe temsilcisi olan hafta), `support_news=` (her haber
  türü kaç raporda).
  Karar değil defter basar;
  `^PROBE` satırları aynı seed, aynı binary ve `--lang=tr` ile bayt-deterministiktir. Oynanan üç koşunun kapısı
  `bash tools/run_gate.sh` (`full_run`, `full_run_b2c`, `full_run_vc_cautious`; `WEEKS` varsayılan 730): her koşu bir
  sonla bitmeli ve sıfır `ERROR` satırı taşımalıdır.
- Sprint planı: `--sprint-probe=hours=<h>:cards=<1|2>:ticks=<t>[:<alan>=<değer>…]` (isteğe bağlı alanlar `start`,
  `seeds`, `seed`, `events`, `rate`, `lead`, `gate`, `team` (1 ile 6, 12, 25, 50), `fill`, `market`, `incident`, `promise`, `tstar`,
  `pmstar`, `plus`, `founder`, `fixture`, `build`, `planms`, `meetings`, `queue`; anlamları `sistemler/02_urun_sprint.md`'de ve `sistemler/10_test_harness.md`'de) headless
  koşar: kurucunun (`team=` ile ekibin) koşusunda ekranın sprint planını (`plan_outcome`) kapanışla karşılaştırır,
  `SPRINTPROBE` satırları basar (`PRED`, `CLOSE`, `SKIP`, `MVP`, `LOAD`, `SUMMARY`, `LOADSUM`, `PAPER`, `PAPERSUM`; `PRED` ve `CLOSE` kartın
  testinin hatasını `bugs=<n>/<F>/<K>/<düzeltme işi>` taşır ve karşılaştırılır; MVP tahmini `mvp_eta` `PRED`'in son alanıdır, karşılaştırılmaz) ve adsız uyuşmazlıkta 1 ile çıkar; bilinmeyen alan ya da oturtulamayan `team` `SPRINTPROBE ERROR` basıp 1 ile çıkar, `LOADSUM`un `team=`i oturan sprint ekibinin büyüklüğüdür. `planms=1` tik oynamaz, plan ekranının motor
  çağrılarının ortanca ve en çok süresini `PLANMS` satırlarında basar.
- Tempo: `--tempo-probe=<hız>[:shell]` gerçek saatle koşar, her haftayı 08:00'den 08:00'e ölçer ve
  `TimeModel.seconds_per_tick` hedefinden sapmayı basar. Çıplak hâli headless'tır ve yalnız saati ölçer; `:shell`
  pencerelidir, kabuğu ve ofisi kurar, gece çıkış kapısının maliyetini de ölçer. Kare maliyeti:
  `--tick-probe=<hız>[:<pencere>][:accounts=<n>][:team=<n>]` headless'tır, kabuğu tempo dünyasıyla (`accounts=<n>` ile n B2B hesaplı
  ERP dünyasıyla, `TICK WORLD` satırı; `team=<n>` o kadar kişiyi sprinte oturtur) kurar ve beş haftayı gerçek saatle koşar; saat adımı, gece, sonraki kare ve ilk
  saat karelerinin süresini, TopBar'ın gece başına yenilemesini ve otomatik kaydın karesini `TICK` satırlarında basar.
  `auto_*` yazar: ayrı `APPDATA` ile koşulur (`TICK START udir=`); kayıt taşıyan kullanıcı dizininde çalışmaz. Üst barın saat hâlleri:
  `--clock-shot=<running|paused|held|released|gate|incident|focus_out|focus_out_off>` (`CLOCKSHOT` satırı: birincil pencere,
  sprint kipi, tutuşlar, hız; odak kollarında önce ve sonraki hız; dar bar `paused` ve `--shot-scale=1.25`).
- Smoke ve probe demo yapısına sabitlidir; `--run-log` (yalnız `sim`) ve `--sprint-probe` `build=ea|full` ile o yapının kartlarını
  ve sonlarını koşar. EA akışı editörde Main Run Args'a `--build=ea` yazılarak oynanır.
- Görsel kontrol (pencereli): `--<yüzey>-shot=<tür>` ailesi (tab, modal, onboard, office, event, ending, vc, sales,
  negotiation, meeting, invite, product, hr, finance, personal, rnd, b2b, inbox), `--probe-shot[=menajer]`,
  `--theme-audit=<sekme | modal:<tür> | onboard:<adım>>`, `--shot-size=GxY`, `--lang=tr|en` (kayıtlı dili ezer),
  `--palette=cb` (renk körü paleti, yalnız o koşu). PNG'ler `%APPDATA%\Godot\app_userdata\Project Unicorn\`'a iner;
  EN `_en`, renk körü `_cb` alır. Gelen kutusu: `--inbox-shot=<durum>` (durumlar `sistemler/08_sekmeler.md`'de); `flow` karar kapısını
  kabuğun kendi girdisiyle oynar (karar gelir, saat tutulur, Ekip yalnız okunur, hız tuşu reddedilir, Esc Olaylar'a
  döner, aynı karar için sonraki Esc sistem menüsünü açar, Ekip'in üstündeki dosyanın şeridi karara döner, karar
  verilir, saat durmuş kalır, Boşluk saati sürdürür) ve kare başına `GATEFLOW` satırı basar.
  Ofis: `--office-shot=<home|ishani|plaza|loft|city|meet>:<saat>[:<ek>]`, ek `full|card|<sekme>|hr_dossier|crowd40|
  founders|nav|crown|cast|cheque|untyped|v1|card_ishani|card_home|card_over|card_here|card_tick|card_moving|desk_shut` (`crowd40` kırk kişilik kadro,
  `LOOKS` satırı ve dört yakın kare;
  `founders` portre ile bust yan yana; `nav` fırınlanmış zemin; `meet` toplantı odası, `cast` bakış, duruş ve jest
  dizisi; `cheque` çek listesinin ilk haftası (`_01` tür seçili, `_02` ilk sprint başlamış), `untyped` aynı hafta
  tür seçilmeden, `v1` v1.0 yayınlanınca (`_01`) ve Ar-Ge açılınca (`_02`); `card_ishani` ve `card_home` yalnız
  `city`'de, şirket Ev'de iken İş hanı'nın ve Ev'in kartı açık; `card_over` aynı Ev'de on dört çalışanla İş hanı'nın kartı,
  `card_here` şirket İş hanı'nda kendi kartı; `card_tick` yalnız `city`'de, Plaza'nın kartı bir günlük
  tikten geçer (`_before` karesi, `OFFICECARD` satırı); `card_moving` yalnız `city`'de, Ev'den İş hanı'na taşınma sürerken İş hanı'nın
  kartı (`_ishani`) ve Plaza'nın kartı; `desk_shut` canlı B2C, iki hatta yedi açık hata: DESTEK
  kartının tek satırı (`_01`), kartın tıklanışı ve en çok hatalı hattın alanı açık Ürün penceresi (`_02`);
  `city:<saat>:crown` kulenin tacı). `--office-shot`'a `--pan=<adım;…>` eklenirse koşu yalnız 3B görüntüyü kamera
  ofsetlerinde kaydeder ve `PAN|` satırı basar (gölge kutusu ve ilk kareye fark; adım `dx,dy[,zm]`,
  `sweep:<baş>:<son>:<adım>:<x|y>:<zm>`, `fit[:zm]` ya da `drag:<dx>:<dy>[:olay]`); `--pan-set=<küme>|<küme>` yalıtım
  düğmeleri (ilk küme taban, `SETDIFF|`), `--pan-gpu=<A>/<B>[;…]` alt görüntünün GPU ve CPU süresi (`GPU|`, `MEM|`);
  değerlerdeki `;` ve `|` tırnaklanır, düğme listesi `scripts/debug/office_pan_probe.gd` başındadır.
  Görüşme paneli: `--meeting-shot=<tür>` (satış `probe|locked|won|lost|handoff|economy|frank|emph_trust|emph_integrations|emph_onboarding|weak_core|die|returning`,
  VC `open|sorgu|sheet|callback|ret|seed|long`; `open:tip` ve `sorgu:tip` zar ipucunu açar), `--negotiation-shot=<open|countered|insult|last|confirm>`; en dar dok
  `--shot-scale=1.25`; davet `--invite-shot=<ring|card|vc|postpone|postpone_vc|held|lapse|lapse_vc>`; term sheet masası
  kabuğun içinde `--vc-shot=<masa türü>:shell`. Ürün sekmesi: `--product-shot=<c1..c5|cards|flow|edge:<ad>>` debug
  fikstürüyle (`scripts/debug/product_fixtures.gd`; `edge:` adları `sistemler/02_urun_sprint.md`'de), `--product-shot=live:<tür>` sprint
  motoruyla kurulan koşuda
  (`pick`, `pick_named`, `pick_relang`, `plan`, `active`, `decision_paper`, `b2c_mvp`, `b2c_live`, `b2c_goal`, `b2b_mvp`, `b2b_mature`, `b2b_quarter`, `b2b_requests`,
  `gate`, `delegate`, `delegate_rehire`, `rnd`, `solo15`, `solo15_tip`, `solo12_active`, `overview_pre`, `server_80`, `server_94`,
  `server_104`, `server_growth`, `server_auto`, `server_tier`, `server_final`, `server_clause`, `server_b2c`;
  kurulumları ve ikinci, üçüncü kareleri `sistemler/02_urun_sprint.md`'de). Satış'ın B2C sayfası `--sales-shot=b2c_live` (`live:b2c_live`'ın dünyası, `SHOT|b2c` satırı), MVP öncesi
  B2B boş hâli `--sales-shot=b2b_pre`, kayıptan dönen lead'lerin kapısı `--sales-shot=returning`.
  Kişilerin bir günü gerçek saatle: `--office-crowd-probe=<ofis>:<kişi>:<hız>` (sıçrama,
  duraklatmada kıpırtı, takılma, çakışma, kapı ve kesme, kuyruk, toplantı, gece kapısı; `CROWD` satırları ve
  `crowd_<ofis>_<kişi>_<hız>_NN.png`). Kurucunun toplantı yolculuğu: `--travel-shot=<home|ishani|plaza|loft>[:vc|:night]`
  (10:00'da satış toplantısına, `:vc` ile Series A görüşmesine davet, gidiş, panel ve dönüş; `:night` toplantıyı
  kurucunun mesai bitişine indirir; `travel_shot_<ofis>[_vc|_night]_NN.png` dizisi ve kurucu masasına oturunca
  `TRAVEL|settled` satırı). Bir hafta gerçek
  saatle: `--day-shot=<ofis>:<hız>` (08:00'den çıkış ve gece atlamasıyla ertesi 08:00'e,
  `day_shot_<ofis>_<hız>_NN.png` ve kare başına `DAYSHOT` satırı).
  Ana menü: `--menu-shot=<empty|continue|first_frame|godot_card|load|settings|credits|licenses|plate|live|
  return_confirm[:gate]|all>` açılışı oyuncunun gördüğü gibi kurar ve kare başına `MENU|state=|focus=|continue=|groups=|
  paused=|joy_ui=` satırı basar (`continue` ve `load` fikstür kayıtlarının üstünde, `live` canlı sahne gelince,
  `return_confirm` kabuğun üstündeki dönüş onayı; `all` `bake_plate` dışındaki her türü kendi pencereli sürecinde
  koşar, `MENU|all|kind=|exit=` basar, biri düşerse 1 ile çıkar). `--menu-shot=bake_plate:<ofis>:<HHMM>` arka planın
  canlı sahnesini plaka olarak yazar (`backdrop_<ofis>_<HHMM>.png`, `assets/art/menu/`'ye kopyalanır). Arka plan
  ölçümü `--backdrop-probe[=<ofis>:<HHMM>]` (varsayılan menünün akşam şehri):
  `BACKDROP|plate_frame=|live_ms=|fade_ms=|gpu_ms_p50=|gpu_ms_p95=|boot_to_menu_ms=`, plakayla canlı karenin farkı
  `BACKDROP|plate_vs_live=` (≤ 6) ve YENİ OYUN'dan sonra `BACKDROP|new_game|nodes=|backdrop=|tex_pct=`; düşük ön
  ayarda yalnız plaka durur, ölçümler `n/a`.
- Tema denetçisi: `"$GODOT" --headless --path . -s res://scripts/theme/theme_check.gd [--theme=<yol>]` master'a göre
  eksik ya da boş öğede, master dışı temada içerik payı açık kutuda 1 ile çıkar, metin ve zemin kontrastını basar.
  Koyu temanın kapısı `"$GODOT" --headless --path . --theme-contrast-audit`: her metin rengi çizildiği her zeminde,
  iki palette; gövde 4,5, büyük metin ve metin dışı işaret 3, devre dışı metin 1,6 ile 4,5 arası; düşen çiftte 1 ile
  çıkar. Glif denetimi `"$GODOT" --headless --path . -s res://scripts/debug/glyph_audit.gd`: CSV'nin, kod
  literallerinin ve `data/` metninin her karakterini koyu yüzlere ve zincirlerine sorar. `--probe-shot=menajer`
  ThemeProbe'u koyu temanın altında, koyu temanın yeni varyasyonlarıyla çeker. Piyasa penceresi:
  `--tab-shot=piyasa[:<seed_oncesi|seed_sonrasi|series_a|ipo|filtre|sektor>]` (oyuncu karosunun hâlleri, halka arz
  haftası, Sektörüm filtresi, sektör rakibinin kartı) ve `--theme-audit=piyasa`.
- **Ekran kartı.** Ekranlı Godot koşuları (shot, tema denetimi, görsel kabul) paralel değil sırayla koşar; ekran
  gerektirmeyen her koşu `--headless`.
- Git kökündeki `.githooks/pre-commit` lint ve `loc_residue`'yu koşar; etkin değildir, etkinleştirmek sahibin kararıdır.

**Tuzaklar**
- Bayrak `--` ayracının arkasına konmaz: `main.gd` `OS.get_cmdline_args()` okur, `--` sonrası sessizce düşer.
- Smoke, shot ve probe `user://`'ya yazar; kayıt yuvası paylaşan vakalar paralelde çakışır (liste `sistemler/10_test_harness.md`'de).
  `APPDATA` başka bir dizine verilirse `user://` oraya taşınır: her koşuya ayrı dizin gerçek kayıtları korur ve
  paralel koşuyu güvenli kılar.
- `xargs -P 2` altında `CASE_TIMEOUT=300` verilir; varsayılan 120 sahte FAIL üretir. `--run-log` her zaman 0 ile çıkar;
  başarılı koşunun çıktısında tam olarak bir `PROBE END` satırı vardır; sonu ve hatayı `tools/run_gate.sh` çıktıdan
  okur. `class_name` eklenince, silinince ya da adı değişince headless koşulardan önce `--headless --import`
  çalıştırılır.
- Smoke koşturucu motorun `ERROR:` satırı basan vakayı düşürür. Kuralı bilerek bozan vaka match kolunda
  `# EXPECT-ERROR <ileti parçası>` der; koşturucu yalnız o parçayı bağışlar ve parça hiç basılmazsa vakayı düşürür.
- Editör `.tres` ve `project.godot`'u yeniden kaydeder (uid ekler, yorum siler); fark sahip onaylamadan commit'lenmez.
- Dosya yazan bayraklar: `--event-lint=baseline` (taban dosyası), `--event-vocab` (`_vocabulary.md`), `--display-check`
  (ayarlar), `--modal-shot=save*|load*` ve `--theme-audit=modal:save*|load*` (kayıt yazar ya da siler), `--ending-shot`
  (zaman damgalı gazete PNG'si), `--tick-probe` (`auto_*` kayıt yuvaları; kayıt taşıyan dizinde çalışmaz),
  `--menu-shot` (fikstür kayıtlarını `user://shot_menu/`'ye yazar). `--menu-shot` ve kayıt yazan `--modal-shot` türleri
  `user://saves`'te kayıt varsa `MENU|refused=user_saves` basıp 1 ile çıkar: ayrı `APPDATA` ile koşulur.
- Bazı smoke vakaları kaynak metni ve özel adları okur; ad değiştirmeden önce vakayı bul. `event_bus.gd`'deki
  `# --- X ---` başlıkları manifest bölümleri, `# LOC-DATA` işaretleri `loc_residue` istisnalarıdır; silinmez.

## 13. Belgeler
- `docs/kod_haritasi/README.md` — kod haritası girişi: dosya dizini, sembol dizini, sinyaller; `sistemler/NN_*.md` sistem başına giriş noktası, durum, test ve tuzaklar (smoke önekleri ve probe kayıt türleri `10_test_harness.md`'de).
- `docs/ACIK_ISLER/` — açık işlerin tek yeri: `ACIK_KARARLAR.md` sahip onayı bekleyen maddeler ve GDD'ye işlenmemiş
  sahip kararları, `ISLER.md` kararlaştırılmış ama yapılmamış işler.
- `docs/content/` — Frank külliyatı ve üretilmiş `events_draft/_vocabulary.md` (güncel seam ve fiil listesi).
- `docs/writing/` — Frank yazım çalışma dosyaları. `docs/design/localization_glossary.md` — TR↔EN terim kanonu.
- `docs/EVENT_SIGNAL_MANIFEST.md` — üretilmiş sinyal manifesti (motor GDD §15.1); elle düzenlenmez.
- `GDDs/README.md` — GDD otorite haritası. `tools/office3d/README.md` — ofis 3B dışa aktarım hattı ve yeniden üretimi.
- Kaynak dosya ağaçta olmayan bir belgeye atıf yapmaz (Ekip GDD §17.6).
