# PRD — RAKİP DÜNYASI
### Yaşayan, okunur, veriyle sürülen rakipler (A1 EA asgari · A2 Sonraki · A3 Tam)

**Durum:** Taslak, yönetmen onayı bekliyor. Onaylanınca A1 uygulama görevinin tek girdisidir; A2 ve A3 kendi görevlerinde bu belgeye atıf yapar.
**Girdi:** `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md` (§3.3 statik rakip tablosu, §3.4 beklenti), Satış GDD rev 6.1 (§5.1 "Rakip seam'i açık", §16), Ekip GDD vson (§6 özellikler, §7 moral, §17.3), olay motoru GDD rev 2 (§3.1, §4.3, §9, §12, §27), `GDD v2 — 10 · Rivals & World` (yürürlükte; ayrılışlar Ek B), `RivalRegistry` / `RivalCatalog` / `Rival`, `NewsFeedSystem`, görev metninin §1 araştırma özeti.
**Okuma sırası:** §1 niyet → §2 kapsam, artırım, ön koşul → §3 saflık → §4 veri → §5–§7 kurallar → §8 yüzeyler → §9 matris → §10 kalibrasyon → §11–§12 içerik ve kayıt → §13 doğrulama → §14 yürütme → §15 açık kararlar → §16 öğretim → §17 kaynaklar → Ekler.
**Etiketler:** *[ÇD]* çalışma değeri (JSON'da, playtest sonrası oynanır) · *[A1]/[A2]/[A3]* artırım · *[çıkarım]* ölçülmemiş akıl yürütme · *[ölçüm]* bu belge için koşulmuş ölçüm · *[hesap]* repo verisinden yeniden kurulmuş tablo · *[kod]* kodda görülmüş olgu (`dosya:satır`, HEAD `6c87431`) · ⚑ Ürün rev 7'den bilinçli ayrılış.
**Adlar:** belge içi arketip adları (Lider, Kopyacı, Niş, Parayı Bulan) iç terimdir; oyuncuya görünen adları §11'dedir. Örneklerdeki rakip adları Ek A'nın taranmış setinden gelir (erp: Halvero, Stokdar, Dirhem).

---

## 1. Tek cümle ve niyet

**Tek cümle.** Rakip, oyuncunun ürün modelinin aynısıyla çalışan, adı ve kimliği olan, her hamlesini önceden belli eden ve bir sebep satırıyla yapan bir şirkettir; oyuncu her hamle için "bunu yaptı çünkü ben şunu yaptım" ya da "bunu yaptı çünkü o böyle bir şirket" diyebilir.

**Yönetmenin cümlesi.** "Gerçekten yaşayan, hareket eden rakipler lazım." Rakip çıkış yapar, tepki verir, basında görünür, müşteri kapar, insan çeler; sonraki artırımlarda para bulur, satın alınır ya da ölür. Kara kutu simülasyon yoktur: her hamle bir kural tablosu satırından, deterministik bir hash'ten ve JSON'daki bir sayıdan gelir.

**Araştırmadan kurala.** Görev metninin §1 özeti bu belgenin ilkelerine şöyle çevrildi (kaynaklar §17; "Bu PRD'deki kural" sütunu kaynağın değil bu belgenin çıkarımıdır):

| # | Ders | Kaynak (§17) | Bu PRD'deki kural |
|---|---|---|---|
| 1 | Rakipsiz ya da sahte rakipli oyun yalnız hissettirir | GDT, MGT2 | Rakipler oyuncunun hedefine (aynı yetenek, aynı müşteri tipi, aynı çalışan) dokunur; sahne rakipleri hamle yapmaz (§4.2) |
| 2 | AI farklı kuralla oynarsa güven kırılır | Software Inc, Soren Johnson | Rakip oyuncunun kademe merdivenini, alan seviyesi fonksiyonunu ve beklenti matematiğini kullanır; canlı rakipte pasif eksen büyümesi kapanır; K3 için oyuncuyla aynı haftaya çekilmiş kapı (§3.9, §5.4) |
| 3 | Okunur niyet işe yarar, savrulma bozar | Civ VI ajandaları | Her tepkinin görünür tetiği, gecikmesi, orantısı, sebep metni ve soğuması tabloda (§7); aynı çeyrekte duruş tersine dönmez (§6.3) |
| 4 | Hatırlayan ve ayırt edilen düşman akılda kalır | Nemesis (Monolith) | Rakip başına hafıza sayacı ve sabit kimlik (arketip, ev alanı, fiyat duruşu); hiyerarşi ve prosedürel düşman üretimi yok (§3.12) |
| 5 | Dolaylı çatışma birkaç doğrudan araçla canlanır | Offworld | A1'de doğrudan temas: çekişmeli görüşme ve çelme kartı; A2'de oyuncu çelmesi ve satın alma teklifi |
| 6 | Rakip parametreleri veri olarak açılmalı | Capitalism Lab | Arketip, tempo, tavan, oran `data/rivals/rules.json`'da (§4.9) |
| 7 | Sebepsiz batış ve sabit rakip sayısı şikâyet konusu | Industry Manager | Ölüm sebepli ve görünür, yerine her zaman bir giren gelir (A3, §5.5) |
| 8 | Hedefe dokunan sızıntı gerçek, ilgisiz basın gürültü | Football Manager | Çelme bir hafta önce haber satırıyla sızar; rakip haberi hamle başına en çok bir satır ve yalnız oyuncunun pazarı için (§8.1) |
| 9 | Satın alma, anlamlı bir son değilse para çukurudur | MGT, MGT2 | Oyuncunun rakip satın alması yok (açık karar 3); rakibe satılma A2'de son (açık karar 4) |
| 10 | Hamleyi önceden göstermek taktiği adil kılar | Into the Breach | Telgraflanan hamle mutlaka iner; bayrak ve "Hazırlanıyor" geri alınmaz (§6.3) |

**Okunurluk sözleşmesi.** Her inen hamlenin dört izi vardır: (1) tetik (oyuncu eylemi ya da arketip temposu), (2) telgraf (en az bir tik önce görünür: haber satırı, ürün bayrağı ya da Rakipler görünümünde "Hazırlanıyor"), (3) sebep metni (haber satırında parantez içinde, Rakipler görünümünde satırda), (4) kalıcı iz (`move_log`, alan çipi, beklenti, sayaç). Dördünden biri eksik hamle kural tablosuna giremez; §6.2'nin "Sebep kökü" ve "Orantı" sütunları her satır için doludur. Tek istisna yalnız manşet olan hamlelerdir (`press_move`, `press_mindgame`, `rival_comment`): oyuncunun hiçbir değerini değiştirmezler, manşetin kendisi hamledir ve telgraf istemez.

---

## 2. Kapsam, artırımlar, ön koşul

### 2.1 IN / OUT

**IN.** Rakip veri modeli (ürün modeli kopyası + kimlik + durum + hafıza); arketip tablosu; hamle kural tabloları (teknoloji dalgasındaki Ar-Ge yarışı dahil); tepki tablosu; tavan, soğuma, orantı; görünürlük yüzeyleri öge öge; etkileşim matrisi; kalibrasyon; içerik ihtiyaç listesi ve marka denetimi (Ek A); kayıt şeması v16 ve taşıma; A1 doğrulama listesi; alt-ajan bölünmesi; açık kararlar.

**OUT.** Kod; pazarlama sistemi; gerçek markalar; rakip ofisinin 3B'de gösterilmesi; çok oyunculu; rakiplerin kendi aralarında tam simülasyonu (rakip-rakip etkileşimi yalnız manşet düzeyinde ve kural tablosuyla, A3); segment bazlı sıfır toplamlı pay formülü (ch10 §8'in açık bıraktığı formül; A2'de pay yalnız sunum katmanında oynar, §8.10).

**Bağımlılık.** Teknoloji dalgası sistemi ayrı bir görevdir. Rakibin dalga davranışı bu belgede tam tanımlıdır (§5.1, §6.2 `wave_race`) ve o görevde bağlanır; o güne kadar `rules.json waves` okunmaz.

### 2.2 Artırımlar

| Artırım | İçerik | Neden tek göreve sığar |
|---|---|---|
| **A1 EA asgari** | Rival'e ürün modeli kopyası (kademe tablosu, alan seviyesi, beklenti) ve kimlik; `RivalSystem` (rakip saati, tempo, telgraf kuyruğu, tavan); Kopyacı kopya kuralı; Lider fiyat kırma ve geri dönüş; Ürün rev 7 rakip bağlarının RivalRegistry'ye taşınması (statik tablonun rakip seçimi ve kademeleri tohum olarak korunur); manşetler (NewsFeedSystem "rakip" türü); Satış tek dikişi (çekişme terimi); tek yönlü çelme kartı (`change_salary` fiiliyle); asgari Rakipler görünümü; kayıt v16 | Rev 7 Faz B kalıbı: 8 alt-ajan, 12 saat tavanı, 10. saatte kesme çizgisi (§14). ≈32 dosya, 6'sı yeni; tek yeni yüzey tek görünüm; görünüm 1–6 ile paralel fikstüre karşı kurulur. A2/A3'e bağımlılık yok |
| **A2 Sonraki** | Parayı Bulan ve giren (yedeğin uyanması); finansman turları ve basın hamlesi (`funding_stage`, `headcount`, `press_heat`); oyuncu çelmesi ve rakibin geri çelmesi (açık karar 5); VC karşılaştırılabilirleri (açık karar 17); rakibe satılma sonu ve satın alma teklifi (açık karar 4); rakibe giden müşterinin atfı; B2C fiyat kanalı (açık karar 6); mentor satırları; bitiş gazetesi lig satırı; pay ofseti; tavanın 4 rakibe göre ayarı (açık karar 16) | Tek sistemin genişlemesi: 5 yeni @export alan (şema artışı yok), 6 hamle türü, 3 yeni seam (`wake`, `apply_funding`, `adjust_a2`). UI: Rakipler görünümüne iki sütun, gazeteye iki satır, VC "neden" listesine bir satır, üç kart (`rival.poach_back`, `rival.player_poach`, `rival.acquisition_offer`), mentor satırları; yeni pencere ya da sekme yok |
| **A3 Tam** | Sönen ve Alıcı durumları; ölüm ve yerine giren; ortaklık teklifi; basın akıl oyunları; hafıza tırmanması; rakip-rakip manşet kuralı | Durum makinesinin iki yeni durumu, 4 hamle türü ve dört yeni @export alanı (`partner_of`, `acquired_by`, `death_day`, `name_index`; SaveCodec bunları şema artışı olmadan kabul eder) |

**A1 kesme çizgisi.** 10. saatte §14'ün 1–6. alt-ajanları bitmemişse A1-ek'e kalanlar: Rakipler görünümünün açılır paneli, "çekişmeli müşteri tipleri" bloğu ve §13 madde 43'ün B2C kıyas ölçümü. Görünümün satır hâli, Satış terimi, çelme kartı ve madde 44 (B2B ölçümü) kesilmez.

### 2.3 Bu oturumdaki yönetmen kararları (bağlayıcı)

1. **Satış tek dikiş istisnası.** `SalesMeetingSystem._build_base_contributions`'a tek katkı terimi, `_modifier_labels`'a tek etiket girişi, `sales_meeting_adapter.CHIP_BY_SEAM`'e tek satır. Değer `GameState.rival_world.push.contest_by_archetype`'tan okunur. Satış GDD §5.1'in "Rakip seam'i açık" yuvasını doldurur. `SalesRepSystem` kapsam dışı.
2. **`change_salary` fiili motorda uygulanır** (`effects.gd` + `EvChips.describe` kolu + `EFFECT_SALARY` anahtarı). Oran, seçenek metninde `{seam:}` ile görünür.
3. **"%70 kazanma hedefi"** = yetkin oyuncu koşularının yaklaşık %70'i bir zafer sonuyla (Series A ya da kârlı bootstrap) biter. §10.7 rakip kanallarının buna etkisini sınırlar.

### 2.4 Ön koşul (A1 başlamadan)
**P1 · note_tool ad taraması.** note_tool'un önerilen ad setinin adları bu oturumun web arama bütçesi dolduğu için taranamadı (Ek A). A1, note_tool adları Ek A yöntemiyle taranıp tabloya "temiz" hükmüyle işlenmeden başlamaz; doğrulanmamış ad `field.json`'a yazılmaz (§13 madde 46).

**P2 · yayın ve pazar aktörü adları (yalnız açık karar 25 "değişsin" ise).** Ekonomi Postası, TeknoGündem ve Yalçın Teknoloji Holding için ikişer yeni aday Ek A yöntemiyle taranır ve Ek A.2'ye "temiz" hükmüyle yazılır; değişiklik ayrı içerik görevinde, sözlük §6 satırı ve bitiş gazetesi künyesiyle aynı commit'te yapılır (TR/EN onay bekler). Karar "kalsın" ise bu, görevin "gerçek marka yok" kuralından bilinçli ve yazılı bir sapmadır.

### 2.5 ch10 ile ilişki
`GDD v2 — 10 · Rivals & World` yürürlüktedir ve "spec öncesi derin oturum" ister; bu belge o oturumun çıktısıdır. Yeni yön ch10'u birkaç noktada aşar (4 arketip, çeyrek tavanı, görünüm yeri, satın alma, segment payı, hamle destesi yerine kural tablosu). Satır satır karşılaştırma ve önerilen `GUNCELLEMELER.md` metni Ek B'de; yürürlüğe girmesi açık karar 18'e bağlı.

---

## 3. Sistem saflığı kuralları

1. **Tek doğruluk kaynağı.** Rakip varlıkları ve rakibe ait her durum `RivalRegistry`'dedir (`Rival` kayıtları). Statik rakip içeriği `data/rivals/*.json`'dadır ve yalnız `RivalCatalog` yükler. `data/product/rivals.json`, `SprintCatalog._rivals`, `SprintCatalog.RIVALS_PATH`, `GameState.product.rival_hits` ve `SprintBridges.tick_rivals` A1'de silinir.
2. **Mantık RefCounted'da.** Kural motoru yeni statik `RivalSystem`'dedir (`scripts/systems/rival_system.gd`, `class_name RivalSystem extends RefCounted`). `RivalRegistry` autoload kalır; durum, okuma API'si ve yazım seam'leri taşır. Sahne hesap yapmaz; görünüm sözleşmesi Dictionary'dir (Ürün rev 7 §10 kalıbı, §8.3).
3. **Yazım yasası (WRITE-THROUGH).** Rival alanlarını yalnız `RivalRegistry`'nin adlı seam'leri yazar:
   - `commit_move(rival_id, entry)` → `pending`'e ekler; `entry.kind == "price_cut"` ise o rakibin `entry.args.segment` segmentindeki `captures` girdilerini siler (telgraf süresince gelen kapmalar yeni sayaca girer, §7 satır 2).
   - `drop_move(rival_id, move_id)` → inmeden çıkarır (kapının reddettiği çelme ve kapalı yapıdan dönüşte yeniden tohumlama; §6.6, §12).
   - `land_move(rival_id, move_id, log_entry)` → `result == landed` ise etkiyi uygular (kademe: `line_tiers` + `line_since`; fiyat: `price_posture` + `posture_since`), girdiyi `pending`'den `move_log`'a taşır (8'e budar), `memory.out`'u yalnız `result == landed` iken artırır (`copy_tier` → `out.copied`, `price_cut` → `out.price_cut`; `roadmap_tier`, `price_recover` ve `poach_attempt` memory'ye yazmaz, çelme sayaçlarını yalnız `close_poach` yazar), `EventBus.rival_moved(rival_id, kind)` yayar.
   - `close_poach(rival_id, seq, outcome)` → aynı `move_log` girdisinin `args.outcome`'ını (`left` / `stayed`) yazar, `memory.out.poached` ya da `poach_failed`'i artırır; yeni girdi açmaz.
   - `set_cooldown(rival_id, key, end_rs)`.
   - `add_capture(rival_id, capture, window_start_day)` → ekler, pencereden eskiyi budar, `memory.in.captured += 1`.
   - `reseed_clock(rival_id)` → `cooldowns`'ı boşaltır, tüm `line_since` ve `posture_since` değerlerini 0 yazar (eski epoch'a göre yazılmış kilitler yeni saatte geçersizdir; `tempo:` §6.1 adım 0(d)'de yazılır) (v15 ve kapalı yapı yüklemesi, §12).
   - `apply_legacy_hit(rival_id, line, player_sprint, seq)` → hat tavanda değilse +1 kademe ve `line_since`; `move_log`'a `{seq, day: -1, player_sprint, kind: "roadmap_tier", args: {line, to_tier}, result: "landed", overtook: false, news_root: "ROADMAP", why_root: "TEMPO_<ARCH>"}`; `rival_moved` yaymaz; `seq`'i çağıran `RivalSystem.on_loaded` `engine.seq`'ten alır (§12).
   - Debug (yalnız `OS.is_debug_build()`): `RivalRegistry.debug_set(rival_id, alan, değer)` ve `RivalSystem.debug_set_engine(anahtar, değer)`; smoke ve fikstürler rakip durumunu yalnız bunlar ve adlı seam'lerle kurar.
   - A2: `wake(rival_id, archetype)` (`world_state = active` + `archetype_override`; `price_posture` her segmentte yeni `base_posture`'a, `posture_since` o anki rakip sprintine yazılır; `tempo:` §6.1.1 "İlk tempo" kuralıyla o anki rakip sprintinden kurulur), `apply_funding(rival_id)` (`funding_stage`, `headcount`, `press_heat`, `share_offset`), `adjust_a2(rival_id, alan, delta)` (`press_heat` 0..3 kırpılarak: `press_move`, `press_mindgame`, çeyrek düşüşü; `headcount`: çelme sonuçları; `share_offset`: `price_cut`, ölümde sıfırlama).
   - `fill_world()` (yükleme, §12).
   Okuma: `active(subtype) -> Array[Rival]` (sabit sıra Lider, Niş, Kopyacı; A2'de Parayı Bulan sona), `backups(subtype)`, mevcut `get_rival`, `get_by_type`, `get_player_rank_in_startup_league`.
   `GameState.rival_world`'ün tek yazarı `RivalSystem`'dir. İstisnalar: `SaveManager._migrate_16` (ham kayıt sözlüğü), `GameState.initialize_run`'daki `clear()`, `SaveCodec`'in genel geri yüklemesi; debug fikstürleri yalnız `RivalSystem.debug_set_push(arch, entry)`, `RivalSystem.debug_set_poach(pending)` ve `RivalSystem.debug_set_engine(anahtar, değer)` üzerinden yazar. `RivalSystem` her yazım dizisinin sonunda `EventBus.rival_world_changed()` yayar. CLAUDE.md §6'daki "`SprintBridges` … `rival_hits`'i yazar" cümlesi A1 commit'inde çıkar.
4. **Push / pull.** Tüketiciye giden türetilmiş değerler `GameState.rival_world.push`'a yazılır: `contest_by_archetype` (Satış) ve `expectation_bump` (Ürün). Satış ve Ürün (`SprintCatalog` beklenti ve `word_for`) bu değerleri yalnız oradan okur. Push, kayıtlı durumun saf fonksiyonudur: slot 4b'de, `price_stance_changed` ve `line_upgraded` geldiğinde senkron ve yüklemede yeniden hesaplanır; aynı kayıt aynı push'u verir. Çelme oranları push değildir: istek anında bir kez hesaplanır ve `poach_pending.odds`'ta saklanır (§6.6).
5. **Dokunulmaz kod.** İK sistemleri (`hr_*`; `character_registry.gd` yalnız mevcut seam'leri çağrılarak), Finans sistem ve görünümleri, Satış'ın onaylı tek dikiş dışındaki her yeri, VC kodu (A1). Bu sistemlerin sinyalleri dinlenir. Tam liste Ek C.
6. **Olay motoru.** Yalnız seam (`seams_world.gd`), kart JSON'u ve onaylı `change_salary` fiili. Rakip kartı daima `EventGate.request(id, {slot: id})` ile verilir; motorda rakip seçicisi yoktur ve `_first_free` tüm alt-türlerden bağlar [kod `scope.gd:189`]. `presenter.gd:92`'nin okuduğu `Rival.company_name` getter olarak eklenir; motor değişmez. Motor `rival.` ad alanındaki entity seam'lerini rakibe bağlar [kod `scope.gd:128-135`]; zar oranı seam'leri GLOBAL olmak zorundadır [kod `engine.gd:479`]. `change_salary` için `effects.gd` içindeki `_is_negative` `pct`'in yalnız işaretini okur; `lint.gd`'ye dokunulmaz.
7. **Determinizm.** RNG ve `String.hash()` yok. Her zar `EvDice.unit("rival.<kural>", day, rival_id, anahtar) < p`; her seçim `floori(EvDice.unit(...) × n)`. Anahtarda yalnız id ve tamsayı (ad, çevrilmiş metin yok). Sözlük anahtarları seçimden önce sıralanır. Rakipler sabit sırayla işlenir; inbox varış sırasıyla.
8. **Tüm içerik ve ayar JSON'da.** `data/rivals/field.json` (alan, adlar, kademe tohumları) ve `data/rivals/rules.json` (arketip, kural, tavan, oran). `RivalCatalog`'un bugünkü `TEMPLATE`, `NAMES`, `SHARE_SEED`, `MARKET_ACTORS`, `MARKET_TOTAL_MRR` sabitleri `field.json`'a taşınır; statik erişimciler yazılır (`template()`, `names(sub)`, `share_seed()`, `market_actors()`, `market_total_mrr()`), `RivalRegistry.get_market_snapshot` ve `get_player_share_pct` bunlardan okur, sabitleri okuyan smoke vakaları erişimciye çevrilir. Tek istisna: çelme kartının zam ve moral miktarları kart JSON'undadır (motor efekt miktarını yalnız sabit sayıdan okur [kod `effects.gd:509-513`]). Oyuncu metni yalnız `localization/strings.csv` anahtarlarında ve kart `text` bloklarında.
9. **Hile yok.** Canlı rakip yalnız oyuncunun kurallarıyla güçlenir: kademe merdiveni (+1, atlama yok, K3 tavanı, ücretli plan tavanı 1), aynı alan seviyesi fonksiyonu, aynı beklenti tablosu. Oyuncunun K1–K2 kademeleri ekip kapısı taşır; rakibin ekibi olmadığı için bu kapıların eşdeğeri arketip temposudur; K3 ayrıca Ar-Ge ister ve takvim kapısı alır (§5.4). Karar 10 "kademeden" iken `advance_all` canlı ve yedek startup'ların eksenlerini büyütmez. Rakip hiçbir yüzeye oyuncunun göremediği bir veriyle etki etmez.
10. **Lastik yok.** Tempo, olasılık ve güç fonksiyonları (`RivalSystem._tempo_due`, `_roll`, `_pick_line`, `_k3_open`) kasa, MRR, oyuncu sırası ya da oyuncunun kademe hızını okumaz. Oyuncu durumunu okuyan üç yer adlı ve bilinçlidir: (a) Kopyacı'nın "bir kademe eksik" tavanı (oyuncuyu geçmemek için), (b) çelme hedef süzgeci, (c) faz aralık çarpanı: faz, oyuncunun MRR kapısıyla ilerler; görevin "tempo faz saatine bağlıdır" kuralıdır ve yalnız Series A Hunt'ta rakibi hızlandırır (§5.2). (d) A2: `entry` ve `acquisition_offer` fazı, `funding_round` oyuncunun finansman aşamasını okur; üçü olay kapısıdır, tempo, olasılık ya da güç fonksiyonu değildir.
11. **Lig fonksiyonu korunur ve kullanılır.** `RivalRegistry.get_player_rank_in_startup_league(sub_type_id, player_composite)` imzası ve gövdesi değişmez. A1 kullanım yeri: Rakipler görünümü başlığı (§8.3). A2: bitiş gazetesi ve VC karşılaştırılabilirleri (§8.5, §8.8).
12. **Nemesis patent notu.** Prosedürel düşman üretimi, hiyerarşi, rütbe ve terfi yapısı yok. Kullanılan yalnız sabit kimlik (JSON'daki arketip ve ad) ve hafıza sayacıdır.
13. **Gizli simülasyon yok.** Rakibin ekonomisi, kasası, müşteri tabanı simüle edilmez. Oyuncunun göremediği rakip durumu yalnız soğuma sayaçlarıdır (tempo saati, `copy:` ve `follow:` kilitleri, fiyat soğumaları). A1'de sayı olarak gösterilmezler; her hamle en az bir tik önce telgrafla (bayrak, "Hazırlanıyor", haber) görünür.
14. **Rakip-rakip.** Rakipler birbirine hamle yapmaz; A3'te bir rakibin hamlesine başka rakibin yalnız manşetle yorum yapması kural tablosuyla (§6.2 `rival_comment`).

---

## 4. Veri modeli

### 4.1 Rakip (`Rival`)

Kaynak sütunu: **JSON** = `field.json`'dan id ile okunan getter, kayda girmez (içerik düzeltmesi eski kayda ulaşır); **@export** = durum, kayda girer; **türetilen** = hesaplanır, saklanmaz.

| Alan | Tür | Kaynak | Anlam | Art. |
|---|---|---|---|---|
| `id` | String | @export (mevcut) | `rv_<alt-tür>_<slot>`; slot 0..7, indeks kilidi korunur | — |
| `product_name` | String | @export (mevcut); `fill_world` her yüklemede JSON'dan ezer | Rakibin görünen tek adı | A1 |
| `company_name` | String | JSON getter | Tek ad kuralında (açık karar 19) `product_name` ile aynı; `presenter.gd:92` bunu okur | A1 |
| `sub_product_type_id`, `tier` | String | @export (mevcut) | Pazar ve kademe bandı (`giant/established/startup`) | — |
| `innovation`, `stability`, `experience` | float | @export (mevcut) | Sahne rakiplerinde şablon + momentum. Canlı ve yedekte `composite()` türetilen eksenleri kullanır (açık karar 10); saklı değer bunlar için okunmaz | A1 |
| `momentum`, `status` | float, String | @export (mevcut) | A1'de anlamı değişmez; `status` yazılmaz (VC `_rival_ahead` okur [kod `vc_pitch_system.gd:1302-1307`]) | — |
| `archetype` | String | JSON getter (A2'den itibaren `archetype_override` doluysa o) | `leader` / `copier` / `niche` / `funded` / "" | A1 |
| `archetype_override` | String | @export (yeni) | Boşsa `archetype` field.json'dan okunur; A2 `entry` ve A3 yerine giren `wake` ile yazar | A2 |
| `home_area`, `second_area` | String | JSON getter | Alt-tür başına tek değer (`living.<alt-tür>.niche_home`, `.niche_second`); `archetype == "niche"` olan rakip için döner, diğerlerinde "" (§5.3) | A1 |
| `base_posture` | String | rules.json getter | `archetypes[archetype].posture`; yedekte (`archetype == ""`) `standard` (§5.1) | A1 |
| `world_state` | String | @export (yeni) | `""` (doldurulmamış nöbetçi) / `scenery` / `active` / `background`; A3: `fading` / `acquirer` / `dead` | A1 |
| `line_tiers` | Dictionary | @export (yeni) | `{hat_id: 0..3}`; ortak hatlar `@<alt-tür>` ekli (oyuncunun `line_upgraded` sinyalindeki biçim); B2C'de `cap_paid_plan` (en çok 1) | A1 |
| `line_since` | Dictionary | @export (yeni) | `{hat_id: rakip_sprinti}` hattın şimdiki kademesine çıktığı rakip sprinti; tohumda 0 | A1 |
| `price_posture` | Dictionary | @export (yeni) | `{segment: SalesConstants.STANCE_*}` (`competitive` / `standard` / `premium`; oyuncu kadranıyla aynı kimlikler); B2B segment = Satış arketipi (`SalesArchetypes.ids()`: `tech_exacting`, `finance_brisk`, `ops_cautious`); B2C tek segment `audience` | A1 |
| `posture_since` | Dictionary | @export (yeni) | `{segment: rakip_sprinti}`; tohumda 0 | A1 |
| `cooldowns` | Dictionary | @export (yeni) | `{"<kural>:<anahtar>": bitiş_rakip_sprinti}`. Anahtarlar: `tempo:`, `copy:<hat>`, `follow:<hat>` (Kopyacı, §7 satır 1), `price_cut:<segment>`, `price_recover:<segment>`; A2: `funding:`, `press:`, `poach_back:` | A1 |
| `captures` | Array | @export (yeni) | `[{seq, day, segment, customer_id}]`; en uzun pencereden (`price.window_sprints`) eski girdiler budanır | A1 |
| `pending` | Array | @export (yeni) | Taahhüt edilmiş (telgraflanmış) hamleler, §4.3 | A1 |
| `move_log` | Array | @export (yeni) | İnmiş ya da boş inmiş hamleler, son 8, §4.3 | A1 |
| `memory` | Dictionary | @export (yeni) | `{"in": {"captured": n, "poached": n (A2)}, "out": {"copied": n, "price_cut": n, "poached": n, "poach_failed": n, "stole": n (A2)}}`; yalnız artar | A1 |
| `funding_stage` | String | @export (yeni) | `bootstrap` / `seed` / `series_a`; tohum `field.json living.<alt-tür>.funding.<slot>`; yalnız `funding_round` inişi bir basamak artırır | A2 |
| `headcount` | int | @export (yeni) | Tohum `field.json living.<alt-tür>.headcount.<slot>`; `funding_round` ile `+funding.headcount_step` (4), rakibin "rakibe geçti" sonuçlu çelmesiyle +1, oyuncu çelmesiyle −1; görünümde "~{n} people" · "~{n} kişi" | A2 |
| `press_heat` | int 0..3 | @export (yeni) | `funding_round` ve `press_move` +1, her rakip çeyreği −1 (taban 0); 2 ve üstündeyken o rakibin haber satırı aynı haftadaki diğer rakip satırlarından önce basılır; başka etkisi yok | A2 |
| `share_offset` | float | @export (yeni) | Pay ofseti (§8.10) | A2 |
| `partner_of`, `acquired_by`, `death_day`, `name_index` | String, String, int, int | @export (yeni) | Ortaklık, satın alan, ölüm tiki; `name_index` 0 = `names[slot]`, k = `reserve_names[k−1]` (yeniden tohumlanan slotun adı yüklemede korunur; `fill_world` adı buna göre yazar) | A3 |

`composite(axes)`: açık karar 10 "kademeden" ise ve rakip dünyası açıkken `world_state in [active, background]` olan rakipte `QualityModel.composite_quality(QualityModel.realized_dims(subtype, line_tiers, {}), axes)`; diğerlerinde saklı eksenler. `advance_all` yalnız bu durumda canlı ve yedek startup'ları atlar. Karar 10 "şablondan" ise ya da rakip dünyası kapalıyken (§6.1) her rakip saklı eksenleri kullanır ve `advance_all` hepsini büyütür (bugünkü davranış); `line_tiers` yalnız Ürün yüzeylerini, çekişmeyi ve görünümü besler. B2C kıyasının yarı doygunluğu §10.5'te.

### 4.2 Alan yapısı (alt-tür başına 8 slot)

| Slot | `tier` | Oynanabilir 3 alt-türde `world_state` | Diğer 10 alt-türde |
|---|---|---|---|
| 0 | giant | `scenery` | `scenery` |
| 1, 2 | established | `scenery` | `scenery` |
| 3–7 | startup | 3'ü `active`, 2'si `background` | `scenery` |

| Alt-tür | Pazar | Lider (aktif) | Kopyacı (aktif) | Niş (aktif) | Yedek (background) |
|---|---|---|---|---|---|
| `note_tool` | B2C | slot 3 | slot 4 | slot 6 | slot 5, 7 |
| `video_clip` | B2C | slot 3 | slot 5 | slot 6 | slot 4, 7 |
| `erp` | B2B | slot 3 | slot 5 | slot 6 | slot 4, 7 |

- Aktif slotlar bugünkü `data/product/rivals.json` sütunlarıdır (`rivals: [3,4,6]` / `[3,5,6]` / `[3,5,6]`); kademe tohumları aynen taşınır (statik tablo bozulmaz).
- **Yedek kademe tohumu [ÇD]:** her yedek slotta kimlik (alt-türe özgü, `@` eki olmayan) hatlar K1, diğer bütün hatlar ve `cap_paid_plan` 0. Yedekler A1'de hamle yapmaz; tohum B2C kıyasının beş startup ortalamasına girer [kod `sales_system.gd:190-201`] ve §10.5 bu tohumla hesaplandı.
- Canlı rakip yalnız `ProductCatalog.playable_types(market)`'teki ve oyuncunun seçtiği alt-türde çalışır; diğer alt-türlerin kayıtları sahnedir ve hamle yapmaz.
- **Yeni oynanabilir alt-tür sözleşmesi:** `field.json living.<alt-tür>` içinde 5 startup × alt-türün her katalog hattı (ortak hatlar `@<alt-tür>` ekli), `cap_paid_plan` yalnız B2C; slot → arketip haritası; ev alanı `SprintCatalog.areas_for(subtype, market)` içinde ve B2B'de sözleşme alanı (core, integrations, trust); 8 taranmış ad. Eksik veri yüklemede `push_error`; veri yoksa o alt-türde rakip dünyası boşta kalır, Ürün rakip çipleri boş, görünüm boş durumunu gösterir.

### 4.3 Hamle kayıtları

**`pending` girdisi (taahhüt):** `{id, seq, kind, args, trigger, commit_day, land_day, quarter, budget}`
- `id` = `"<rival_id>:<seq>"`; `seq` = `rival_world.engine.seq`'ten alınan tekil artan sayı.
- `kind` ∈ §6.2 hamle türleri. `args` yalnız id ve tamsayı: kademe hamleleri `{line, to_tier}` (**mutlak hedef**), `copy_tier` ayrıca `version` (taahhüt tikinin 4b'sinde `ProductState.version()`; slot 1 sprint kapanışında yazılmıştır), fiyat `{segment, to}`, çelme `{employee_id}`. `headlines` ve `move_log` girdileri hamlenin `args`'ını kopyalar. Tek istisna: çelme kapanışında ayrılan kişinin adı özel ad anlık görüntüsü olarak `move_log` girdisinde taşınır (kayıt silindikten sonra basılabilsin diye [kod `character_registry.gd:548-556`]).
- `trigger` = `{source: "tempo" | "shipped" | "capture" | "agency", ref}`; `ref` = hat id, müşteri id ya da boş.
- `budget` ∈ `tempo` / `reaction` / `none` (`none` yalnız A2/A3 bütçe dışı hamleler, §6.3). `quarter` = iniş gününün rakip çeyreği.

**`move_log` girdisi (iniş):** `{seq, day, player_sprint, kind, args, result, overtook, news_root, why_root}`
- `seq` iniş anında yeni alınır (taahhüdün seq'i yeniden kullanılmaz). Tek istisna `poach_attempt`: iniş seq'i §6.6 adım 2'de önceden alınır ve `poach_pending.seq`'te tutulur.
- `player_sprint` = iniş tikinde `SprintSystem.sprint_number()` (ürün durumu olmayan fikstür dünyasında 0) [kod `sprint_system.gd:298-299`] (Ürün'ün sprint pencereli okumaları için).
- `result` ∈ `landed` / `void`. Kademe hamlesi `land_move`'da yalnız `line_tiers[line] == to_tier − 1` ise uygulanır; değilse (başka bir hamle hattı önce yükseltti) ya da Kopyacı'nın §5.4 koşulları iniş tikinde bozulduysa ya da çelme hedefi ortadan kalktıysa `void` iner: haber, beklenti, Ses ve "Son hamle" üretmez, çeyrek yuvası harcanmış sayılır.
- `overtook` = `result == landed` ve `ProductState.is_live()` ve rakibin yeni kademesi oyuncunun o hattaki kademesinden büyük. MVP öncesi inişler `false` yazılır (oyuncunun hiç çıkarmadığı 0 kademesi "geçilmiş" sayılmaz).
- `day = -1` göç edilmiş v15 isabeti demektir (§12).

### 4.4 Tetik (inbox girdisi)
`rival_world.engine.inbox`: `[{day, kind, args}]`. Sinyal dinleyicileri yalnız rakip dünyası açık ve seçilen alt-tür oynanabilirken (`ProductCatalog.playable_types(market)` içinde ve `field.json living`'de verisi varken) yazar; push'un `price_stance_changed`/`line_upgraded` ile senkron yenilenmesi de aynı koşula bağlıdır. Slot 4b'de varış sırasıyla tüketilir ve boşaltılır.

| `kind` | Kaynak sinyal | `args` | Not |
|---|---|---|---|
| `shipped` | `line_upgraded(line_id, tier)` | `{line, tier, live}` | `live` = sinyal anında `ProductState.is_live()`. MVP sprintinin hatları `live=false` gelir, çünkü sinyal kapanış döngüsünde `mvp_shipped`'ten önce yayılır [kod `sprint_system.gd:603-617`]. Ar-Ge çalışma zamanı hatları (`ProductLines.register_runtime_line`) yazılmaz |
| `deal` | `deal_signed(customer_id, seats, seat_price)` | `{customer_id}` | Kurucu ve temsilci kapanışları aynı sinyalden gelir [kod `sales_system.gd:370`] |
| `departed` | `employee_departed(character_id)` | `{character_id}` | Yalnız açık `poach_pending` için anlamlı |
| `resolved` | `event_resolved(event_id, choice_index)` | `{event_id, choice}` | Yalnız `rival.` önekli kart id'leri |
| — | `price_stance_changed(stance)`, `line_upgraded` | — | Ayrıca push'u senkron yeniler (inbox'tan bağımsız) |

A1'de bağlanmayan sinyaller: `mrr_changed` (saatlik, inbox'ı boğar), `customer_churned` (A2), `phase_changed` (faz `GameState.phase`'ten okunur), `seed_round_closed` (A2).

### 4.5 `GameState.rival_world`
`game_state.gd`'de `news_feed` kalıbıyla tanımlanır, `initialize_run`'da `clear()` edilir. Şemayı kuran tek yer `RivalSystem._ensure_state()`'tir (`NewsFeedSystem._ensure_state` kalıbı [kod `news_feed_system.gd:194-204`]); her okuma ve dinleyici önce onu çağırır.

```
rival_world = {
  "engine": {
    "epoch_day": -1,       # rakip saatinin başladığı tik (tip seçimi; 4b örneklemesi); -1 = başlamadı
    "seq": 0,              # pending / move_log / captures / headlines için tekil sayaç
    "inbox": [],           # §4.4
    "poach_pending": {},   # §6.6; {} = yok
    "poach_seen": [],      # bu koşuda çelme kartı görmüş çalışan id'leri (motor latch'i okunmaz)
    "poach_quarter": -1,   # çelme hakkının harcandığı son rakip çeyreği
    "headlines": [],       # §8.1; en çok 12 girdi
    "legacy_hits": [],     # yalnız v15 göçü; RivalSystem.on_loaded tüketir ve siler
    "bumps": {}            # yalnız açık karar 11 "birikimli" ise şemada bulunur: {alan: 0..2}
  },
  "push": {
    "contest_by_archetype": {"<arch>": {"points": int, "rival_id": String, "area": String, "reason": "area|price|both"}},
    "expectation_bump": {"<alan>": float}
  }
}
```
- MVP günü ayrıca tutulmaz: mevcut `GameState` bayrağı `mvp_launch_day` okunur [kod `sprint_system.gd:621`].
- Çeyrek sayaçları saklanmaz; `pending` ve `move_log`'dan türetilir. Tavanlar alan geneli olduğundan (§6.3) bir rakip çeyreğinde en çok 6 iniş olur; `move_log` rakip başına 8 tutar, pencereyi karşılar.

### 4.6 Manşet ve sebep anahtarları
Haber satırı saklanmaz; `engine.headlines` girdisinden basım anında çözülür (§8.1): `{seq, day, rival_id, news_root, why_root, args}`. Anahtar `RIVAL_NEWS_<news_root>_<n>` ve `RIVAL_WHY_<why_root>_<n>`; `n = floori(EvDice.unit("rival.news", day, rival_id, news_root) × content.news_variants[news_root])`, sebep için `"rival.why"` ve `content.why_variants[why_root]`.

| Olay | Ne zaman basılır | `news_root` | `why_root` | Art. |
|---|---|---|---|---|
| `roadmap_tier` | İniş | `ROADMAP` | `TEMPO_LEADER` / `TEMPO_COPIER` / `TEMPO_NICHE` | A1 |
| `copy_tier` | Taahhüt (duyuru); iniş haber basmaz. İnişin `move_log` girdisi `news_root = ROADMAP`, `why_root = COPY` taşır (Son hamle geçmiş zamanla okunur) | `COPY` | `COPY` | A1 |
| `price_cut` | İniş (telgraf görünüm ve Rakipler "Hazırlanıyor"da) | `PRICE_CUT` | `PRICE` | A1 |
| `price_recover` | İniş | `PRICE_RECOVER` | `RECOVER` | A1 |
| `poach_attempt` | Taahhüt (sızıntı telgrafı); sonuç haber basmaz | `POACH_TELEGRAPH` | `POACH` | A1 |
| Kapma atfı (hamle değil) | Atıf; rakip başına 2 tikte en çok 1 | `CAPTURE` | `CAPTURE` | A1 |
| `entry` | İniş | `ENTRY` | `ENTRY` | A2 |
| `funding_round` | İniş | `FUNDING` | `FUNDING` | A2 |
| `press_move` | İniş | `PRESS` | `PRESS` | A2 |
| Rakibe giden müşteri | Atıf | `CHURN_TO_RIVAL` | `CHURN_TO_RIVAL` | A2 |
| `poach_back` | Taahhüt | `POACH_TELEGRAPH` | `POACHBACK` | A2 |
| `player_poach` sonucu | Kart sonucu | `PLAYER_POACH` | `PLAYER_POACH` | A2 |
| `acquisition_offer` | Kart (haber yok; satış sonu gazetede) | — | `ACQUIRE` (kart metni) | A2 |
| `death`, `fading` | İniş | `DEATH`, `FADING` | `DEATH` | A3 |
| `partnership_offer`, `press_mindgame`, `rival_comment` | İniş | `PARTNER`, `MINDGAME`, `COMMENT` | `PARTNER`, `MINDGAME`, `COMMENT` | A3 |
| `wave_race` | İniş | `WAVE` | `WAVE_<ARCHETYPE>` | Rezerve |

### 4.7 Rezerve alanlar
- `release.rival_reaction` (Ürün rev 7 §3.1 rezervi): A2'de bir sürümün tetiklediği kopya duyurusunu `{rival_id, line}` olarak taşır; C3 sürüm notunda tek satır.
- `move.counter_of` (A3 basın akıl oyunları), `memory.escalation` (A3 hafıza tırmanması).
- `rules.json waves.*` (dalga sistemi bağlanana kadar okunmaz).

### 4.8 Hafıza sayacı
`memory.in` (oyuncunun ona yaptığı: kapma) ve `memory.out` (onun oyuncuya yaptığı: kopya, fiyat kırma, çelme) koşu boyu yalnız artar. A1 tüketicisi Rakipler görünümünün açılır panelidir. A3 hafıza tırmanması bu sayılara eşik koyar (`memory.in.captured ≥ escalation.captured_min` (4) → yalnız Lider'de fiyat kırma tetiği `price.captures` (2) yerine `escalation.captures` (1) kapmayla dolar). A1'de hiçbir kural `memory`'yi okumaz. Görünüm metni: `RIVALS_MEMORY` "Memory · taken by you: {taken} · copied by it: {copies}" · "Hafıza · senin aldığın: {taken} · onun kopyaladığı: {copies}".

### 4.9 JSON dosyaları

`data/rivals/field.json` (içerik; TODO content etiketli değerler onay bekler):
```
{
  "template": [ {tier, innovation, stability, experience, momentum} × 8 ],     # bugünkü TEMPLATE
  "share_seed": [8 sayı], "market_actors": [...], "market_total_mrr": 1500000,
  "names": { "<alt-tür>": [8 ad] },                                              # Ek A
  "living": {
    "<oynanabilir alt-tür>": {
      "slots": { "3": {"archetype": "leader", "world_state": "active"}, "4": {...}, ... },
      "niche_home": "integrations", "niche_second": "core",
      "tiers": { "<hat_id>": [slot3, slot4, slot5, slot6, slot7] }
    }
  }
}
```

`data/rivals/rules.json`, **A1 blokları** (tüm sayılar [ÇD], §10.1 tablosu yollarıyla):
```
{
  "clock": {"rival_sprint_weeks": 2, "quarter_sprints": 6, "first_move_sprints": 1, "telegraph_sprints": 1},
  "archetypes": {
    "leader": {"interval": 6, "posture": "premium",     "hire_appetite": 0.5, "line_pick": "own_weakest"},
    "copier": {"interval": 4, "posture": "competitive", "hire_appetite": 1.0, "line_pick": "follow_player"},
    "niche":  {"interval": 3, "interval_after_home": 5, "posture": "premium", "hire_appetite": 0.2, "line_pick": "home_area"}
  },
  "phase_interval_mult": {"1": 1.0, "2": 1.0, "3": 0.85},
  "k3": {"min_week": 52, "k2_sprints": 8},
  "caps": {"quarter_total": 6, "quarter_tempo": 4, "quarter_reaction": 2, "per_kind_reaction": 1, "per_rival_sprint": 1},
  "copy": {"delay_sprints": 3, "line_lock_sprints": 12, "min_player_tier": 2},
  "price": {"captures": 2, "window_sprints": 6, "telegraph_sprints": 1, "cooldown_sprints": 8, "recover_every_sprints": 8},
  "contest": {"dilim": 1.0, "points": [15, 30], "niche_home_bonus_dilim": 1, "price_points": 6, "grace_weeks": 12, "cap_points": 30},
  "expectation": {"bump": 0.5, "bump_max": 1.0, "window_sprints": 6, "chip_window_player_sprints": 3},
  "poach": {"min_week": 26, "quarter_sprint": 3, "telegraph_ticks": 1, "close_timeout_ticks": 2, "morale_min": 35, "morale_max": 49,
            "key_stars_min": 3, "tenure_weeks_min": 4,
            "odds": {"counter": {"base": 0.60, "per_morale": 0.010}, "talk": {"base": 0.30, "per_morale": 0.015},
                     "trait": {"loyal": 0.15, "bag_packed": -0.20}, "min": 0.05, "max": 0.95}},
  "news": {"max_age_ticks": 2, "capture_line_gap_ticks": 2, "headlines_keep": 12},
  "content": {"news_variants": {"ROADMAP": 4, "COPY": 3, "PRICE_CUT": 3, "PRICE_RECOVER": 2, "POACH_TELEGRAPH": 2, "CAPTURE": 3},
              "why_variants": {"TEMPO_LEADER": 2, "TEMPO_COPIER": 2, "TEMPO_NICHE": 2, "COPY": 3, "PRICE": 2, "RECOVER": 2, "POACH": 2, "CAPTURE": 2}}
}
```
- `contest.points` görev değeridir; açık karar 12 öneri `[12, 20]`. `k3.min_week` açık karar 22.
- **A2'de eklenen bloklar:** `archetypes.funded` (`interval 3`, `posture competitive`, `hire_appetite 1.5`, `press_appetite 1.0`), `archetypes.<*>.press_appetite`, `caps.max_active 4`, `entry {min_phase 2, count 1}`, `funding {p_mult 0.5, cooldown_quarters 2, interval_delta -1, headcount_step 4}`, `press {cooldown_quarters 2}`, `poach.player {per_quarter 1, base 0.40, appetite_mult -0.10, premium_pct 20}`, `poach_back {per_quarter 1}`, `acquisition {archetypes ["leader","funded"]}`, `share {funding 0.02, price_cut 0.01}`, `vc {rank_mult_top 1.0, rank_mult_step 0.97, rank_mult_min 0.90}`, `mentor {per_quarter 1}`, `difficulty`, `caps` A2 değerleri (karar 16). field.json'a `living.<alt-tür>.funding` ve `.headcount` (slot başına tohum) eklenir. `content.news_variants` ve `why_variants`'a §11'deki A2 kökleri ve adetleri eklenir.
- **A3'te eklenen bloklar:** `states {fading_quarters 3, funded_fading_quarters 4, dead_after_fading_quarters 2}`, `partnership {p 0.5, cooldown_quarters 4}`, `mindgame {min_captured 3, cooldown_quarters 2}`, `comment {p 0.3, per_quarter 1}`, `escalation {captured_min 4, captures 1}`. field.json'a `living.<alt-tür>.reserve_names` (oynanabilir alt-tür başına 2 taranmış ad) eklenir. `content.news_variants` ve `why_variants`'a §11'deki A3 kökleri ve adetleri eklenir.
- **Rezerve:** `waves {delay_sprints {funded 1, copier 3, leader 4, niche 2}}`.
- A1'de zorluk okunmaz (oyunda zorluk seçici yok; §10.10).

---

## 5. Arketip tablosu

### 5.0 Ortak aday kuralı
**Aday hat** = rakibin o hattaki kademesi hattın tavanının altında (`cap_paid_plan` 1, diğerleri 3), bir sonraki kademe K3 ise §5.4 K3 kapısı açık, hat bu rakibin `pending`'inde bekleyen bir kademe hamlesinin hattı değil, Kopyacı için `follow:<hat>` soğuması bitmiş ve yalnız katalog hattı (Ar-Ge çalışma zamanı hattı değil). **Alan seçimi yalnız en az bir aday hattı olan alanlar arasında yapılır.** Bir arketipte aday yoksa hamle yok, tempo saati yeniden başlar (sebep `no_line`). Eşitlik her yerde `EvDice.unit("rival.line", day, rival_id, "")` ile, sıralı aday listesinden bozulur.

### 5.1 Ana tablo [ÇD]

| Arketip | Tempo (etkin aralık, rakip sprinti / +1 kademe) | Fiyat duruşu tabanı | İşe alım iştahı | Basın iştahı | Hat seçimi | Dalga davranışı (rezerve) | Zayıflık | Art. |
|---|---|---|---|---|---|---|---|---|
| **Lider** (`leader`) | 6 | `premium` | 0,5 | 0,2 | Aday içeren alanlardan en düşük `area_level_for`'lu alan, içinde en düşük kademeli aday hat | Dalgaya 4 rakip sprinti gecikmeyle, her dalga hattında | Yavaş; kendi alanlarını derinleştirmez; 2 müşteri kaybedince fiyat kırar (yalnız B2B) | A1 |
| **Kopyacı** (`copier`) | 4 | `competitive` | 1,0 | 0,5 | **Yalnız oyuncunun çıkardığı hatlarda:** oyuncunun en güçlü sözleşme alanından (B2B: core, integrations, trust; B2C: revenue dışı tümü) başlayarak, alan içinde §5.4 katı kuralını sağlayan en düşük Kopyacı kademeli aday hat | Oyuncunun dalga çıkışından 3 rakip sprinti sonra | Hep bir kademe geride ve gecikmeli; oyuncu durursa o da durur (simülasyonda Q3–Q5'te 2–6 bekleme [hesap]) | A1 |
| **Niş** (`niche`) | Ev alanında aday varken 3, yoksa ikinci alanda 5 | `premium` | 0,2 | 0,2 | Ev alanının en düşük kademeli aday hattı; ev alanında aday yoksa ikinci alan; ikisinde de yoksa hamle yok | Yalnız ev alanı dalgalarında, 2 rakip sprinti gecikmeyle | Ev alanı dışında zayıf; geniş müşteriye hitap etmez | A1 |
| **Parayı Bulan** (`funded`) | 3 | `competitive` | 1,5 | 1,0 | En yüksek `usage_weight`'li aday hat | Dalgada ilk: 1 rakip sprinti gecikme | Yakma hızı: 4 rakip çeyreği tur almazsa Sönen'e girer (A3) | A2 |

- Fiyat duruşu oyuncunun Satış kadranıyla aynı kimlikleri kullanır: `competitive` < `standard` < `premium` [kod `sales_constants.gd:123-125`]; oyuncuya `SALES_STANCE_` + kimlik anahtarlarıyla gösterilir (§8.3); eşleme tablosu yoktur.
- Niş'in bir sonraki aralığı taahhüt anında belirlenir: hamlenin alanı ev alanıysa `interval`, değilse ya da ev alanında aday yoksa `interval_after_home`.
- İşe alım iştahı çelme saldıranının ağırlığıdır (§6.6). Basın iştahı A2'de `funding_round` ve `press_move` olasılığıdır.
- "Zayıflık" sütunu tasarım notudur, oyuncu metni değildir (§11).

### 5.2 Faz aralık çarpanı
Etkin aralık = `maxi(1, roundi(interval × phase_interval_mult[GameState.phase] × zorluk_çarpanı))`; taahhüt anında hesaplanır, sonradan faz değişse de o hamleyi değiştirmez. A1'de zorluk çarpanı 1. Değerler: Bootstrap ve Traction 1,0, Series A Hunt 0,85 → Lider 5, Kopyacı 3, Niş 3 (ev alanı dışında 4). Faz oyuncunun MRR kapısıyla ilerlediği için bu, adlı ve bilinçli bir oyuncu durumu okumasıdır (§3.10c); görevin "tempo faz saatine bağlıdır" kuralı ve ch01 §5'in "Series A Hunt'ta pencere daralır" baskısıdır.

### 5.3 Niş ev alanı
Kural: Niş'in tohum alan seviyesi eksi diğer iki aktifin ortalaması en büyük olan alan (`area_level_for`, yuvarlamasız); B2B'de yalnız sözleşme alanları (core, integrations, trust) arasından, yoksa Niş hiçbir görüşmeye çekişme getiremez; eşitlikte alan sırası [hesap: erp'de onboarding +1,00 öndedir ama hiçbir Satış arketipine eşlenmez; sözleşme alanları içinde integrations +0,50].

| Alt-tür | Niş | Ev alanı | İkinci alan | Gerekçe (TODO content) |
|---|---|---|---|---|
| note_tool | slot 6 | trust | core | Tohumda dayanıklılık 1; "gizlilik odaklı not" nişi |
| video_clip | slot 6 | onboarding | core | Tohumda mobil 1; "telefonda kurgu" nişi |
| erp | slot 6 | integrations | core | Tohumda entegrasyon 1; "muhasebe yazılımına bağlanan" niş; `finance_brisk` görüşmelerine çekişme getirir |

Niş'in "sadık müşterisi": ev alanında rakip oyuncudan **kesin önde** iken çekişme bir dilim fazla sayılır (§8.4); eşitlikte bonus yok.

### 5.4 Ortak kurallar
- **Merdiven.** Her kademe hamlesi `to_tier = mevcut + 1`; atlama yok; tavan 3; `cap_paid_plan` tavanı 1 [kod `sprint.json paid_plan.tiers`].
- **K3 kapısı (Ar-Ge eşdeğeri).** Rakip bir hatta K3'e ancak takvim haftası ≥ `k3.min_week` ve hat K2'de ≥ `k3.k2_sprints` (8) rakip sprinti kaldıysa çıkar. Oyuncunun K3'ü Ar-Ge düğümü ve ekip kapısı ister; oyuncunun bütün K2 kademeleri (ve birkaç K1) de ekip kapısı taşır [kod `product_lines.gd:278-287`; `data/product/lines/*.json` `requires`]. Rakibin ekibi olmadığı için K1–K2 kapılarının eşdeğeri arketip temposudur; K3 ayrıca Ar-Ge düğümü istediğinden yalnız K3 takvim kapısı alır. Rakip bu bedeli ödemediği için kapı, tipik oyuncunun hesaplanan ilk K3 haftasına (52) çekilir: rakip K3'ü tipik oyuncudan önce inemez [hesap §10.3]. Açık karar 22 (40 / 52). Uygulama görevi tipik oyuncunun medyan ilk K3 haftasını `full_run` probe'unda ölçer ve raporlar (§13 madde 11).
- **Kopyacı katı kuralı.** Kopyacı'nın her hamlesi (tempo, kopya, K3) duyuru anında iki koşulu sağlar: (a) hamlenin hattında yeni kademesi ≤ oyuncunun o hattaki kademesi − 1 (oyuncunun çıkarmadığı hatta, kademe 0, Kopyacı hamle yapmaz; tohum kademeleri olduğu gibi kalır); (b) o hattın alanında yeni `area_level_for` ≤ oyuncunun gösterilen alan seviyesi − 0,5. Koşullar **iniş tikinde yeniden denetlenir**, çünkü oyuncunun gösterilen alan seviyesi bir Ar-Ge çalışma zamanı hattı kaydolunca düşebilir (`line_hidden_self_serve` onboarding ortalamasına 0 olarak girer [kod `sprint.json` areas, `sprint_catalog.gd:62-71`]); bozulan hamle `void` iner. Gevşek okuma (yalnız oyuncunun çıkardığı hatlar sınırlı) Kopyacı'nın çıkarılmamış bir hatta öne geçip alanı "Zayıf" okutmasına izin verdiği için reddedildi [hesap §10.6].
- **Çalışma zamanı hatları.** Rakip, Ar-Ge'nin oyuncu için kaydettiği gizli hatlara sahip olmaz; rakip alan seviyesi yalnız katalog hatlarından hesaplanır (`SprintCatalog.area_level_for`, §8.2).

### 5.5 Durumlar (A2 / A3)

| Durum | Giriş koşulu | Çıkış | Görünür | Art. |
|---|---|---|---|---|
| `background` | Tohum | Traction'da (`GameState.phase ≥ entry.min_phase`; kenardan değil, fazdan türetilir) bir yedek `wake(r, "funded")` ile `funded` ve `active` olur; ya da ölen rakibin yerine | Rakipler görünümünde soluk satır "Henüz hamle yok" | A2 |
| `active` | Tohum ya da uyanma | Sönen'e | Tam satır | A1 |
| `fading` (Sönen) | Art arda 3 rakip çeyreğinin her birinde ya hiç kademe hamlesi inmemiş ya da en az bir `price_cut` inmiş rakip girer. Parayı Bulan ayrıca, art arda 4 rakip çeyreği `funding_round` inmemişse de girer; iki koşuldan biri yeter | `price_cut` inmeyen bir rakip çeyreğinde en az bir kademe hamlesi inerse `active`; aktif bir Alıcı varsa 1 rakip çeyreği sonra ona katılır (haber "{acquirer} bought {rival}" · "{acquirer}, {rival} şirketini satın aldı", `acquired_by` yazılır, `dead`); yoksa 2 rakip çeyreği sonra `dead` | Damga "FADING" · "SÖNÜYOR" | A3 |
| `acquirer` (Alıcı) | Lider ya da Parayı Bulan, oyuncu Series A Hunt'ta (A2'de yalnız `acquisition_offer` koşulu olarak, durum A3'te) | Teklif reddi ya da kabul | Satın alma teklifi kartı; Sönen'i satın alır | A2 koşul, A3 durum |
| `dead` | Sönen'in çıkışı | — (kayıt silinmez; `reset()` yeniden tohumlar) | Mezar taşı satırı "Closed · {date}" · "Kapandı · {date}" | A3 |

**Yerine giren (A3).** Ölümden sonraki rakip sprintinde bir yedek (`background`) `wake(r, ölenin arketipi)` ile `active` olur. Yedek kalmadıysa ölen slot yeniden tohumlanır: `field.json living.<alt-tür>.reserve_names` listesinden sıradaki ad, yedek kademe tohumu, `world_state = active`, ölenin arketipi; haber `ENTRY`. Ölüm yüzünden aktif rakip sayısı hiçbir zaman düşmez.

---

## 6. Ajans kural tabloları

### 6.1 Tik sırası
`RivalSystem.daily_tick()`, `TimeManager._dispatch_daily_tick`'te `RivalRegistry.advance_all()`'ın hemen ardından ve `FinanceSystem.daily_tick()`'ten önce koşar (slot 4b) [kod `time_manager.gd:350-351`]. Sinyal bağlama `TimeManager._ready`'de `RivalSystem.wire()` ile yapılır.

0. **Kurulum.** (a) `_ensure_state()`. (b) Rakip dünyası kapalıysa (açık karar 9 "hayır" yapısı ya da `--rivals=off`): `push = {}` ve `epoch_day = -1` yazılır, adım 1–5 atlanır. (c) Alt-tür seçilmemişse ya da oynanabilir değilse adım 1–5 atlanır, `epoch_day` yazılmaz. (d) `epoch_day < 0` ise `epoch_day = GameState.day`, `engine.poach_quarter = -1` ve her aktif rakip için §6.1.1 "İlk tempo" değeri `set_cooldown(r, "tempo:", …)` ile yazılır (tip seçiminin ayrı sinyali yoktur [kod `sprint_system.gd:43-56`]; fikstürler de bu yoldan geçer).
1. **inbox**: varış sırasıyla tüketilir. `deal` girdisinde önce §7'deki kapma atfı yapılır (`add_capture`; atıf Lider'e ise ve o rakibin `headlines`'taki son `CAPTURE` girdisi `day − news.capture_line_gap_ticks`'ten eskiyse ya da yoksa `headlines`'a `CAPTURE`; sınır yazımda uygulanır), ardından aynı girdi için §7 satır 2 denetlenir; atıf bu tikin inişlerinden önceki kademelerle hesaplanır. Her girdi §7 tepki kurallarından geçer; uyan tepki §6.3 bütçesinde yer bulursa `pending`'e taahhüt edilir (telgraf), bulamazsa düşer (debug günlüğü ve `PROBE RIVAL_MOVE … result=dropped:budget`, iz yok). `resolved`/`departed` girdileri §6.6 çelme kapanışını işler.
2. **Tempo taahhüdü**: bu tik bir rakip sprintinin ilk tikiyse, her aktif rakip için sabit sırayla `_tempo_due(rival)` (rakip sprinti ≥ `cooldowns["tempo:"]`) true ise: Lider'de önce `price_recover` koşulu bakılır, sağlanmazsa `roadmap_tier`; diğerlerinde `roadmap_tier`. Aday yoksa ya da tempo bütçesi doluysa hamle yok, saat yine yeniden başlar (`cooldowns["tempo:"] = rs + etkin aralık`).
3. **Çelme değerlendirmesi** (§6.6).
4. **İniş**: `land_day == day` olan `pending` girdileri sabit rakip sırasıyla iner (`RivalRegistry.land_move`). İniş oyuncu durumuna göre yeniden doğrulanmaz; tek istisna Kopyacı'nın §5.4 koşullarıdır (bozulursa `void`). `poach_attempt` girdisi bu adımda §6.6 akış 2–4'e göre işlenir: hedef yoksa `land_move` ile `void`; varsa önce `poach_pending` yazılır ve `EventGate.request` çağrılır, sonuca göre `land_move` ya da `drop_move`.
5. **Push**: `contest_by_archetype` ve `expectation_bump` yeniden hesaplanır; `EventBus.rival_world_changed()` yayılır.

**Kapalı mod.** Rakip dünyası kapalıyken sinyal dinleyicileri inbox'a yazmaz, `push` boştur (Satış ve Ürün ceza ya da artış görmez), `epoch_day` −1'dir, `composite()` saklı eksenleri kullanır, `advance_all` hepsini büyütür ve B2C kıyası bugünkü yarı doygunluğu (50) kullanır (§10.5); kapalı mod Satış ve B2C ekonomisi bakımından bugünkü oyunun aynısıdır; Ürün'de rev 7'nin statik rakip çıkışları (bayrak, alan çipi, Ses, beklenti artışı, `PRODUCT_NEWS_RIVAL_LAUNCH` satırı) yoktur, `rival_gap` tohum kademesinden okunur. Rakipler görünümü durumu `off` olur ve RAKİPLER düğmesi gösterilmez. Kapalı yapıda kaydedilip açık yapıda yüklenen koşu `RivalSystem.on_loaded` içinde v15 yolu gibi ele alınır (§12).

### 6.1.1 Zaman formülleri
- `w = clock.rival_sprint_weeks`. `rs(day) = floori((day − epoch_day) / w)`; `rq(day) = floori(rs(day) / clock.quarter_sprints)`. Rakip sprintinin ilk tiki `epoch_day + w × rs`.
- **Etkin aralık** §5.2.
- **İlk tempo**: tip seçildiği tik (epoch) için `cooldowns["tempo:"] = first_move_sprints + sıra_indeksi + floori(EvDice.unit("rival.phase", 0, rival_id, "") × etkin_aralık)`; sıra indeksi Lider 0, Niş 1, Kopyacı 2. Hesaplanan değer sırada daha önce işlenen bir rakibinkiyle aynıysa farklı olana dek +1. `rs(t) < clock.first_move_sprints` iken hiçbir hamle (çelme dahil) taahhüt edilmez.
- **İniş günü**:
  - `roadmap_tier`, `price_recover`, `price_cut`: `land_day = epoch_day + w × (rs(t) + gecikme + (1 eğer (t − epoch_day) mod w ≠ 0, değilse 0))`; gecikme tempo hamlelerinde `clock.telegraph_sprints` (1), `price_cut`'ta `price.telegraph_sprints` (1). Böylece telgraf en az `w × gecikme` tik sürer ve iniş daima bir rakip sprintinin ilk tikidir.
  - `copy_tier`: aynı formül, gecikme `copy.delay_sprints` (3) → en az 6 hafta.
  - `poach_attempt`: `land_day = t + poach.telegraph_ticks` (sprint başı kuralının tek istisnası; `per_rival_sprint` sayımına girmez, kaydırılmaz).
- **Kaydırma**: aynı rakibin aynı rakip sprintinde ikinci inişi taahhüt anında bir sonraki rakip sprintine yazılır. Kaydırma tek adımdır: hedef sprintte de bu rakibin inişi varsa ya da kayma çeyreği değiştirip yeni çeyrekte yer yoksa hamle düşer, telgraf üretilmez (`dropped:shift`).

### 6.2 Hamle tablosu

| Hamle (`kind`) | Arketip | Koşul | Olasılık | Rakip tarafı bedel | Görünür çıktı | Telgraf | Orantı | Sebep kökü | Soğuma | Art. |
|---|---|---|---|---|---|---|---|---|---|---|
| `roadmap_tier` | Lider, Kopyacı, Niş | Tempo saati doldu; aday hat var (§5.0, §5.1) | 1,0; hat eşitliği hash | Tempo saati sıfırlanır; tempo bütçesinden yuva | Haber (iniş); alan çipi `PRODUCT_RIVAL_TOPIC` "Rakip: {topic}" (§7.2); beklenti (açık karar 11); Ses; Rakipler "Son hamle" | 1 rakip sprinti: bu ya da sonraki sprint bayrağı + "Hazırlanıyor" | +1 kademe | `TEMPO_<ARCH>` | Etkin aralık | A1 |
| `copy_tier` | Kopyacı | §7 satır 1 (boşluk yoksa tetik düşer) | 1,0 | Tepki yuvası; `copy:<hat>` kilidi | Haber (taahhüt); Ses "planlıyor"; bayrak; "Hazırlanıyor"; beklentiye **asla** sayılmaz | Taahhüt anı; iniş 3 rakip sprinti sonra | +1, en çok oyuncu − 1 | `COPY` | Hat başına 12 rakip sprinti | A1 |
| `price_cut` | Lider (yalnız B2B) | §7 satır 2 | 1,0 | Tepki yuvası; taahhütte `price_cut:<segment>` soğuması; `commit_move` o segmentin `captures`'ını siler | Haber (iniş); Rakipler fiyat duruşu; çekişme teriminin fiyat bileşeni | 1 rakip sprinti: Rakipler "Hazırlanıyor: fiyat değişikliği · {segment}" | Bir basamak; taban `competitive` | `PRICE` | `cooldown_sprints` (8) | A1 |
| `price_recover` | Lider | `price_cut:<segment>` soğuması bitti; son `window_sprints` (6) rakip sprintinde o segmentte yeni 2 kapma yok; duruş tabandan ucuz; `price_recover:<segment>` soğuması bitti | 1,0 | Tempo bütçesinden yuva | Haber (iniş); Rakipler fiyat duruşu | 1 rakip sprinti ("Hazırlanıyor") | Bir basamak tabana doğru | `RECOVER` | En erken `recover_every_sprints` (8) rakip sprintinde bir, yalnız Lider'in tempo tikinde (aralık 6 ile pratikte 12); aynı tikte iki segment uygunsa alfabetik ilk | A1 |
| `poach_attempt` | İşe alım iştahı > 0 olan aktif rakip | §6.6 | Saldıran iştah ağırlıklı hash; değerlendirme çeyrekte 1 | Tepki yuvası; çeyreğin çelme hakkı | Haber (taahhüt, sızıntı); ertesi tik `rival.poach_offer` kartı | 1 tik | Tek kişi | `POACH` | Çeyrekte 1; kişi başına koşuda 1 | A1 |
| `entry` | Yedek → `funded` | `GameState.phase ≥ entry.min_phase` ve henüz giren yok | 1,0 | `budget: none` | Haber; Rakipler "NEW" · "YENİ" damgası | 1 rakip sprinti ("Preparing: a new rival" · "Hazırlanıyor: yeni rakip") | Koşuda `entry.count` (1) | `ENTRY` | Koşuda 1 | A2 |
| `funding_round` | Parayı Bulan, Lider | Rakip çeyreğinin ilk rakip sprinti; `rank(rakip aşaması) ≤ rank(oyuncu aşaması) + 1` | `press_appetite × funding.p_mult` | `budget: none`; `press_heat +1`; `headcount + funding.headcount_step`; 1 rakip çeyreği etkin aralık `funding.interval_delta` (−1) | Haber; VC karşılaştırılabilirleri; pay ofseti | 1 rakip sprinti ("Preparing: a funding round" · "Hazırlanıyor: yatırım turu") | Tek basamak | `FUNDING` | `funding.cooldown_quarters` (2) | A2 |
| `press_move` | Parayı Bulan (yoksa Kopyacı) | §7 satır 4 | `press_appetite` | `budget: none`; `press_heat +1` | Haber | Yalnız manşet (§1 istisnası) | Tek manşet | `PRESS` | `press.cooldown_quarters` (2) | A2 |
| `poach_back` | Oyuncunun çeldiği rakip | §7 satır 5, açık karar 5 "evet" | `hire_appetite` | Tepki yuvası | Haber + `rival.poach_back` kartı (`rival.poach_offer` kalıbı) | 1 tik | Hedef, oyuncunun aldığı kişiyle aynı ya da düşük kıdem | `POACHBACK` | `poach_back.per_quarter` (1) | A2 |
| `player_poach` (oyuncu çelmesi) | Oyuncu → aktif rakip | Açık karar 5 "evet"; İK aday listesinde çeyrekte en çok 1 "Rakipten aday: {rival}" satırı | Kabul oranı `poach.player.base + appetite_mult × hire_appetite` [ÇD], seçenek metninde yüzde | Tepki yuvası; oyuncu: maaş primi `poach.player.premium_pct` (%20) + Finans `hire` gideri | `rival.player_poach` kartı; başarıda haber, rakibin `headcount −1`, `memory.in.poached += 1`; §7 satır 5'in tetiği | 1 tik | Tek kişi | `PLAYER_POACH` | Çeyrekte 1 | A2 |
| `acquisition_offer` | Lider, Parayı Bulan (`acquisition.archetypes`) | Açık karar 4 "evet"; oyuncu Series A Hunt'ta; mevcut `funding.acquisition_offer` kapısı (`acq_road_over`) | Kart koşulu | — | Kart; alıcı adlı rakip; satış sonu | Kart kendi telgrafını taşır (`terminal_warning`) | Koşuda 1 | `ACQUIRE` | Koşuda 1 | A2 |
| `fading` / `death` / yerine giren | Sönen rakip | §5.5 | 1,0 | — | Haber; "Sönüyor" damgası; mezar taşı; yedek uyanır ya da slot yeniden tohumlanır | Sönen dönemi (en az 2 rakip çeyreği) | Tek | `DEATH` | — | A3 |
| `partnership_offer` | Niş | Oyuncu Niş'in ev alanında ondan geride ve Niş `fading` değil | `partnership.p` (0,5) | Tepki yuvası | Kart (entegrasyon ortaklığı) | 1 rakip sprinti | Tek | `PARTNER` | `partnership.cooldown_quarters` (4) | A3 |
| `press_mindgame` | Kopyacı, Parayı Bulan | `memory.in.captured ≥ mindgame.min_captured` (3) | `press_appetite` | Tepki yuvası; `press_heat +1` | Haber + `rival.press_reply` kartı | Yalnız manşet (§1 istisnası) | Tek | `MINDGAME` | `mindgame.cooldown_quarters` (2) | A3 |
| `rival_comment` | Herhangi bir aktif | Başka rakibin `price_cut` ya da `entry` hamlesi indi | `comment.p` (0,3) | `budget: none` | Yalnız manşet (rakip-rakip) | Yalnız manşet (§1 istisnası) | Tek manşet | `COMMENT` | `comment.per_quarter` (1) | A3 |
| `wave_race` | Tüm aktifler | Dalga sistemi yeni dalga açar (rezerve sinyal `wave_opened(wave_id, lines)`); rakip dalga hatlarından birinde §5.4 merdiveniyle +1 kademe planlar | 1,0; hat `EvDice.unit("rival.wave", day, rival_id, wave_id)` | Tempo bütçesinden yuva; tempo saati sıfırlanır | Haber; dalgada ilk inen rakip için alan çipi "Dalgada ilk: {rival}" | Arketip gecikmesi (`waves.delay_sprints`) | +1 kademe | `WAVE_<ARCH>` | Dalga başına rakip başına 1 | Rezerve |

### 6.3 Tavan ve öncelik
- **Kapsam.** `caps.quarter_*` ve `per_kind_reaction` alan genelidir (oynanan alt-türün aktif rakipleri); `per_rival_sprint` rakip başınadır.
- **Çeyrek tavanı** (`caps.quarter_total` 6): bir rakip çeyreğinde inen toplam hamle. İki bütçe: **tempo ≤ 4** (`roadmap_tier`, `price_recover`) ve **tepki ≤ 2** (`copy_tier`, `price_cut`, `poach_attempt`; türü başına ≤ 1).
- **Tempo bütçesi dolarken adalet.** Aynı tikte tempo saati dolan rakip sayısı tempo bütçesinde kalan yerden fazlaysa yerler, bu rakip çeyreğine düşen tempo taahhüdü (inmiş ya da bekleyen) en az olan rakiplere verilir; eşitlikte sabit sıra. 3 aktif rakipte tempo talebi Niş'in ev alanı açıkken 4,5'tir; bu çeyreklerde bir tempo hamlesi düşer [hesap §10.3].
- **Yuva taahhüt anında tutulur.** Telgraflanan hamle iner (`void` inse bile); bayrak ve "Hazırlanıyor" geri alınmaz. İki istisna `drop_move`'dur: kapının reddettiği çelme (§6.6) ve kapalı yapıdan dönüşte yeniden tohumlama (§12).
- **Yer bulamayan tepki tetik anında düşer**, ertelenmez ve telgraf üretmez: "çünkü ben şunu yaptım" bağı haftalar sonra kurulmaz.
- **Tempo borç biriktirmez**: atlanan tempo hamlesinin saati yeniden başlar.
- **Savrulma kilidi**: taahhüt anında denetlenir; hamlenin iniş çeyreğinde aynı rakibin aynı segmentinde ters yönde inmiş ya da bekleyen bir fiyat hamlesi varsa yeni hamle düşer.
- **Rakip başına rakip sprintinde en çok 1 iniş** (çelme hariç); çakışmada §6.1.1 kaydırması.
- 4 aktif rakipte (A2) talep 6,5–7,2'dir ve tavanı aşar; açık karar 16 ("8" ise `quarter_tempo` 5, `quarter_reaction` 3).
- **A2/A3 bütçeleri.** `poach_back`, `player_poach`, `press_mindgame` ve `partnership_offer` tepki bütçesindendir; `entry`, `funding_round`, `press_move`, ölüm ve yerine giren ile `rival_comment` `budget: "none"` taşır ve `quarter_total`'a sayılmaz.

### 6.4 Hash tarifi
| Karar | Çağrı | Kullanım |
|---|---|---|
| Tempo fazı | `EvDice.unit("rival.phase", 0, rival_id, "")` | İlk tempo kaydırması |
| Hat ve alan eşitliği | `EvDice.unit("rival.line", day, rival_id, "")` | Sıralı aday listesinden `floori(u × n)` |
| Kapma eşitliği | `EvDice.unit("rival.capture", day, customer_id, "")` | Eşit seviyeli aday rakipler |
| Çelme saldıranı | `EvDice.unit("rival.poach", day, "", "")` | İştah ağırlıklı kümülatif seçim |
| Haber ve sebep varyantı | `EvDice.unit("rival.news", day, rival_id, news_root)`, `EvDice.unit("rival.why", day, rival_id, why_root)` | §4.6 |
| Çelme sonucu | Motorun `EvDice.check(odds, event_id, option_id)`'i [kod `dice.gd:39-40`] | Kartın zar seçenekleri |

### 6.5 Fiyat ve segment
B2B segment = Satış arketipi (`SalesArchetypes.ids()`). Müşterinin segmenti `Customer.industry ∈ SalesArchetypes.sectors(id)` üyeliğiyle bulunur; hiçbirine uymayan sektör sprint.json'un `default` alan geri düşüşüne (onboarding) gider ve segmentsiz kalır (fiyat sayacına girmez). Bu döngü bugün `SprintBridges` içinde talep alanı için yazılıdır [kod `sprint_bridges.gd:93-96`]; A1'de `SprintCatalog.archetype_for_industry(industry) -> String` ("" = segmentsiz) olarak tek yardımcıya çıkarılır ve iki yer onu çağırır. Not: kodda `SalesArchetypes.DEFAULT_ID` = `ops_cautious`'tur ve bilinmeyen id'ler ona düşer [kod `sales_archetypes.gd:33, 130-131`]; segment döngüsü bu yüzden yalnız `SalesArchetypes.ids()` üzerinden yürür, sprint.json'un `default` anahtarı döngüye girmez.

### 6.6 Çelme kuralı (A1, tek yön)
**Ne zaman.** Her rakip çeyreğinde bir kez değerlendirilir: `(day − epoch_day) mod w == 0` ve `rs(day) mod clock.quarter_sprints == poach.quarter_sprint − 1` olan tikte (1 tabanlı: 3 = çeyreğin üçüncü rakip sprinti). Koşullar: takvim haftası ≥ `poach.min_week` (26); `engine.poach_quarter < rq(day)`; tepki bütçesinde yer; `rs ≥ clock.first_move_sprints`; hedef kümesi boş değil. O tikte sağlanmazsa o çeyrek deneme yok.
**Hedef kümesi.** `CharacterRegistry.get_employees()` içinden: `category == "employee"` (kurucu değil); `status == HRConstants.STATUS_ACTIVE` (izin ve eğitimde değil); `poach.morale_min ≤ morale ≤ poach.morale_max` (35–49, İK'nın amber bandı; 35 altı İK'nın kendi istifa zarına bırakılır [kod `hr_constants.gd:860`]); rolünün anahtar alanında `HRConstants.stars_for(role_stats[HRConstants.role_key_area(role)]) ≥ poach.key_stars_min` (3); `GameState.day − hire_day ≥ poach.tenure_weeks_min` (4); `HRMoraleSystem.has_pending_departure(id) == false`; `id ∉ engine.poach_seen`. Sıralama: anahtar alan puanı azalan, sonra id.
**Saldıran.** Aktif rakipler `hire_appetite` ağırlığıyla `EvDice.unit("rival.poach", …)` kümülatif seçim.
**Akış.**
1. **Taahhüt** (tik `t`): `engine.poach_quarter = rq(t)`; `pending` girdisi `kind=poach_attempt`, `args={employee_id}`, `land_day = t + poach.telegraph_ticks`; `headlines`'a `POACH_TELEGRAPH` ("{rival}: recruiters met {employee}" · "{rival}: işe alım ekibi {employee} ile görüştü").
2. **İniş** (tik `t + 1`): hedef hâlâ aktif çalışan değilse `land_move` girdiyi `result: void` ile indirir (yuva harcanır, haber yok). Değilse oranlar bir kez hesaplanır: `p = clamp(odds.<seçenek>.base + odds.trait.loyal·[loyal] + odds.trait.bag_packed·[bag_packed] + odds.<seçenek>.per_morale·(morale − poach.morale_min), odds.min, odds.max)`, `counter` ve `talk` için ayrı; özellik `Character.traits`'teki mevcut id'lerden okunur (İK koduna dokunulmaz). **Önce** `poach_pending = {employee_id, rival_id, seq, day, name, role, key_area, stars, odds: {counter, talk}, pct: {counter, talk}}` yazılır (`seq` burada `engine.seq`'ten alınan yeni iniş seq'idir; adım 4'te `land_move`'un `log_entry`'si aynı seq'i taşır, adım 3'te kullanılmadan kalır) (`pct = roundi(odds × 100)`; ad, `CharacterRegistry.remove` kaydı sildikten sonra da basılabilsin diye anlık görüntü; seam'ler ve kart metni bundan okur, `request` toplu adım dışında kartı aynı çağrıda gösterebilir), **sonra** `EventGate.request("rival.poach_offer", {"employee": id, "rival": rival_id})`.
3. **Ret** (`request` false: tutorial, koruyucu): `poach_pending = {}`; girdi `drop_move` ile çıkar (tepki yuvası iadesi budur, `move_log` yok); bu çeyreğin çelme hakkı harcanmış kalır (aynı çeyrekte yeni telgraf yok); telgraf satırı arşivde kalır; hafıza değişmez; `PROBE RIVAL_MOVE … result=dropped:refused`.
4. **Kabul** (true): `land_move` girdiyi `result: landed`, `args: {employee_id, name, outcome: ""}` ile indirir; `poach_seen += employee_id`.
5. **Kapanış.** Kart `critical` etiketli bir interrupt'tır: tempo bütçesinden muaftır ve kâğıda düşmez [kod `tempo.gd:60-64, 100-102`]; `expires_weeks` yalnız kâğıtta işler [kod `papers.gd:29`] ve açık olay modalı saati durdurur [kod `main.gd:1912-1921`]; kart açıkken tik geçmez, İK istifası, kovma ya da süre dolması olamaz. Kapanış sonraki 4b'de şu girdilerden biriyle olur: `resolved` (rakip kart id'si), `poach_pending.employee_id` için `departed` (motor kuyruktaki kartı `event_resolved` yaymadan düşürebilir [kod `engine.gd:427-433`]), ya da `poach.close_timeout_ticks` (2) tik geçmesi. Aynı çözümde `departed` geldiyse (seçenek `counter` başarısız ya da `release`) `close_poach(rival_id, poach_pending.seq, "left")`, gelmediyse ya da `choice == −1` [kod `engine.gd:470`] ya da zaman aşımıysa `close_poach(rival_id, poach_pending.seq, "stayed")`; tek `move_log` girdisi vardır. Haber basılmaz (hamle başına tek satır; sonuç kartta ve Rakipler "Son hamle"de görünür). `poach_pending = {}`.
**Bilinen sınırlar.** İK'nın istifa zarı yalnız moral `MORALE_FLIGHT_RISK` (35) altında art arda en az 2 hafta kalınca atılır [kod `hr_morale_system.gd:79-84, 316-327`]; karşı teklif ya da konuşmadan sonra hedef bu eşiğin üstündedir, zar onu ancak morali yeniden 35'in altına inerse götürür. `change_morale` `HRMoraleSystem.apply_delta` üzerinden işler; kazanç özellik ve Liderlik çarpanıyla değişir [kod `effects.gd:329-332`].

---

## 7. Tepki tablosu

| # | Oyuncu eylemi (tetik) | Sinyal | Rakip tepkisi | Gecikme | Orantı | Sebep metni şablonu (EN · TR, taslak) | Soğuma | Art. |
|---|---|---|---|---|---|---|---|---|
| 1 | Canlı üründe bir hatta K2 ya da K3 çıkarır | `line_upgraded` (`live=true`, tier ≥ `copy.min_player_tier`) | Kopyacı aynı hatta +1 planlar; `to_tier = min(Kopyacı + 1, oyuncu − 1)`; §5.4 katı kural | Duyuru tetik tikinin 4b'sinde; iniş 3 rakip sprinti sonra (§6.1.1) | Tek kademe; oyuncuyu asla yakalamaz; tetik başına tek kopya | `RIVAL_WHY_COPY_0` · "{product} shipped it in {version}" · "{product} bunu {version} sürümünde çıkardı" | Hat başına 12 rakip sprinti (`copy:<hat>`). Taahhütten önce `to_tier ≤ line_tiers[hat]` ise (Kopyacı zaten oyuncu − 1'de ya da üstünde; oyuncu K1 ise tavan 0) ya da §5.4 (b) sağlanmıyorsa tetik düşer: telgraf, haber, bayrak yok, kilit ve yuva harcanmaz (`dropped:no_gap`). Kopyacı'nın `pending`'inde aynı hatta bekleyen bir kademe hamlesi varsa da tetik düşer (`dropped:no_gap`). Kopya düşse de taahhüt edilse de her canlı çıkış Kopyacı'ya `set_cooldown(kopyacı, "follow:<hat>", rs + copy.delay_sprints)` yazar: oyuncunun çıkışından sonra taahhüt edilen hiçbir Kopyacı hamlesi o hatta çıkıştan 3 rakip sprintinden önce inmez (çıkıştan önce taahhüt edilmiş bekleyen hamle yerinde iner, §6.3) | A1 |
| 2 | Lider'e atfedilen `price.captures` (2) müşteriyi aynı B2B segmentinde 6 rakip sprinti içinde kapar | `deal_signed` → atıf (aşağıda) | Lider o segmentte fiyat duruşunu bir basamak indirir (taban `competitive`); Lider zaten `competitive` ise tetik düşer, sayaç silinmez | 1 rakip sprinti | Tek basamak; tetik başına tek; `commit_move` sayacı siler, telgraf süresince gelen kapmalar yeni sayaca girer | `RIVAL_WHY_PRICE_0` · "{n} accounts changed hands" · "{n} hesap el değiştirdi" (`{n}` = `price.captures`) | 8 rakip sprinti; sonra en erken `recover_every_sprints` (8) rakip sprintinde bir, yalnız Lider'in tempo tikinde bir basamak tabana döner (aralık 6 ile pratikte 12) (`price_recover`) | A1 |
| 3 | MVP canlıya çıkar | (`mvp_launch_day` bayrağı) | Tepki yok; çekişme 12 haftalık tanışma süresinden sonra başlar (§8.4) | — | — | — | — | A1 |
| 4 | Seed imzası (Series A imzası koşuyu bitirir; EA'da koşu sürüyorsa o da) | `seed_round_closed(vc_id)` [kod `event_bus.gd:258`] | Parayı Bulan (yoksa Kopyacı) basın hamlesi | 1 rakip sprinti | Tek manşet | `RIVAL_WHY_PRESS_0` · "after your round" · "senin turunun ardından" | `press.cooldown_quarters` (2) | A2 |
| 5 | Oyuncu bir rakibin çalışanını çeler (`player_poach` başarılı) | kart sonucu | O rakip geri çelme dener | Oyuncu çelmesinden sonraki ilk `poach.quarter_sprint` tikinde (gerekirse sonraki rakip çeyreğinde); geri çelme `engine.poach_quarter` hakkını harcamaz, kendi `poach_back.per_quarter` hakkını kullanır | Hedef, oyuncunun aldığı kişiyle aynı ya da düşük kıdem | `RIVAL_WHY_POACHBACK_0` · "you hired from its team" · "onun ekibinden birini aldın" | `poach_back.per_quarter` (1) | A2 |
| 6 | Bir B2B müşteri churn eder | `customer_churned` (A2'de bağlanır) | Müşterinin öncelik alanında seviyesi oyuncununkine eşit ya da yüksek aktif bir rakip varsa atıf + haber `CHURN_TO_RIVAL`; `memory.out.stole += 1`. Churn kararı Satış'ındır, rakip yalnız atıf yapar | Aynı tik | Tek satır | `RIVAL_WHY_CHURN_TO_RIVAL_0` · "it is ahead in {area}" · "{area} alanında önde" | Rakip başına 2 tikte en çok 1 satır | A2 |
| 7 | Oyuncu bir alanda Niş'i geçer | `line_upgraded` | Niş ev alanında bir sonraki etkin aralığı 1 kısaltır | Sonraki tempo taahhüdü | Bir kez | `RIVAL_WHY_NICHE_0` · "wants its area back" · "kendi alanını geri istiyor" | 2 rakip çeyreği | A3 |
| 8 | Oyuncu Lider'den 4+ müşteri kapar | `memory.in.captured` | Hafıza tırmanması (yalnız Lider): fiyat kırma tetiği 2 kapmadan `escalation.captures` (1) kapmaya iner (tepkiye daha erken geçer) | — | Bir basamak, kalıcı | `RIVAL_WHY_GRUDGE_0` · "it remembers the lost accounts" · "kaybettiği hesapları unutmadı" | Kalıcı | A3 |

**Müşteri kapma atfı (satır 2'nin girdisi).** `deal` girdisinde müşterinin segmenti ve alanı bulunur (§6.5; `sprint.json archetypes`). Aday rakipler: o alanda `area_level_for(rakip) ≥ oyuncunun gösterilen alan seviyesi` olan aktif rakipler (müşteri yalnız rakibin en az denk olduğu yerde "ondan kapılmış" sayılır). Aday yoksa ya da müşteri segmentsizse atıf yok. Birden çoksa `EvDice.unit("rival.capture", …)`; Lider önceliği yok. Atıf (§6.1 adım 1): `add_capture(rival_id, {seq, day, segment, customer_id}, day − w × price.window_sprints)`. Görünür iz: Lider'e atıf olduysa haber `CAPTURE` ("{rival}: the {company} account changed hands" · "{rival}: {company} hesabı el değiştirdi"; rakip başına 2 tikte en çok 1, sınır yazımda) ve Rakipler görünümünde Lider satırında segment sayacı. Kurucu ve temsilci kapanışları aynı sayılır (müşterinin nereden geldiği kimin kapattığından bağımsızdır). A1'de atfedilmiş müşterinin sonradan gitmesi kapmayı geri almaz (`churn_customer` fiili `customer_churned` yaymaz [kod `effects.gd:250-263`]).

### 7.1 Orantı ve savrulma yasası
1. Tepki ≤ tetik: bir kademe çıkışı en çok bir kademe kopyası; iki kapma bir basamak fiyat; bir çelme bir geri çelme.
2. Tetik başına tek tepki; bir tepki başka bir rakibin tepkisini tetiklemez (zincir yok; A3 `rival_comment` yalnız manşet).
3. Aynı rakip aynı segmentte bir çeyrekte iki yöne dönmez (§6.3).
4. Her tepkinin görünür tetiği ve sebep metni vardır; sebebi gösterilemeyen tepki tabloya giremez.
5. Rakip hiçbir tepkiyle oyuncunun bir kararını geri almaz: kopya oyuncunun alan kelimesini düşüremez (§8.2), fiyat kırma imzalı sözleşmeleri değiştirmez, çelme kart olmadan kimseyi götürmez.

### 7.2 Metin kuralları
- Manşet ve sebep ayrı anahtardır (§4.6); satır "{headline} ({why})".
- Yer tutucu adları ASCII İngilizcedir ve TR/EN sütunlarında aynıdır: `{rival}`, `{product}`, `{company}`, `{employee}`, `{capability}`, `{segment}`, `{version}`, `{area}`, `{outlet}`, `{headline}`, `{why}`, `{market}`, `{date}`, `{rank}`, `{total}`, `{n}`, `{need}`, `{weeks}`, `{topic}`, `{taken}`, `{copies}`, `{sectors}`, `{pct}`, `{who}`, `{acquirer}` (`loc_csv_integrity` yalnız `[a-z_]+` adlarını eşleştirir [kod `endgame_smoke.gd:8456`]). Bu belgede geçen her yer tutucu bu listededir.
- Doldurma kuralları: `{topic}` = `SprintCatalog.cap_name(hat)` (ortak hatlarda `@<alt-tür>` ekli id'yi `ProductLines.line(hat).name_key` ile, `cap_paid_plan`'ı `PRODUCT_CAP_PAID_PLAN` ile çözer; `ProductLines.line_name_key` yalnız eksiz taban id alır, kullanılmaz) [kod `sprint_catalog.gd:74-77`]; `{capability}` = `SprintCatalog.step_name(ProductLines.step_at(hat, to_tier).id)`, `cap_paid_plan` için `SprintCatalog.step_name(SprintCatalog.PAID_PLAN)` (bugünkü `rival_launch_in` kalıbı [kod `sprint_catalog.gd:531-535`]); `{version}` = `SprintSystem.version_label(args.version)` (oyuncunun gördüğü "v1.4" biçimi [kod `sprint_system.gd:399-406`]); `{market}` = oynanan ürün tipinin görünen adı (mevcut ürün tipi anahtarı); `{date}` = sözlüğün kısa tarih biçimi "W{n}" · "H{n}"; `{segment}` = `RIVAL_SEGMENT_<ID>`.
- Araya giren değer ek almaz (CLAUDE.md §5): "{rival}'ın fiyatları" yazılmaz; "{rival}: fiyatlar indi · {segment}" yazılır.
- Tire yok; benzetme ve aforizma yok; hüküm yok (hüküm yalnız Frank'in ağzında).
- Önce İngilizce yazılır; Türkçe ayrı yerelleştirme adımıdır. Bu belgedeki TR satırlar taslaktır.
- Tempo hamlelerinin sebebi arketiptir: `RIVAL_WHY_TEMPO_LEADER` ("filling its own gaps" · "kendi eksiklerini kapatıyor"), `TEMPO_COPIER` ("following your strongest area" · "senin en güçlü alanını izliyor"), `TEMPO_NICHE` ("going deeper in its area" · "kendi alanında derinleşiyor").

---

## 8. Yüzeyler

Örnek metinler **EN · TR** sırasıyla ve taslaktır (TR/EN onay bekler). Oyuncu metni yalnız anahtardır; aşağıdaki tırnaklı satırlar anahtarların taslak değerleridir.

### 8.1 Haber bandı

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Rakip satırı | `{outlet} · {headline} ({why})` | `NewsFeedSystem` "rakip" türü; kaynak `rival_world.engine.headlines` (aşağıda) | Yok |
| Pay hareketi satırı | Mevcut `NEWS_RIVAL_UP/DOWN_*` | Değişmez; o hafta basılmamış rakip olayı yoksa basılır | Yok |
| Ürün sürüm canlı satırı | `PRODUCT_NEWS_RIVAL_LAUNCH_*` | **Silinir** (`SprintBridges.tick_rivals` ile); yerini arşivlenen `ROADMAP` satırı alır | — |

**Kaynak ve imleç.** `RivalSystem` her basılabilir olayı (§4.6 tablosu: hangi hamle hangi tikte basılır) `engine.headlines`'a yazar: `{seq, day, rival_id, news_root, why_root, args}`; her girdi yeni bir `engine.seq` alır; en çok `news.headlines_keep` (12) girdi tutulur. Tek yazar `RivalSystem`, okuyan `NewsFeedSystem`'dir (yazmaz, kendi imlecini kendi durumunda tutar):
- NewsFeedSystem `news_feed.last_rival_seq`'ten (`nf.get("last_rival_seq", 0)`) büyük ve `day − max_age_ticks`'ten genç girdileri `seq` sırasıyla okur; bu girdiler "rakip" havuzunu dolu sayar (`_pick_source` havuz koşulu genişler; 50/30/20 hedefleri ve yürüyüş aynı).
- Basılan girdi imleci ilerletir ve `recent_rivals[rival_id]`'i damgalar (aynı hafta aynı rakibin pay satırı basılmaz).
- Metin basım anında çözülür; akış biçimi `{day, kind, src, txt}` değişmez; dil değişiminde arşivdeki eski satırlar eski dilde kalır (mevcut davranış).
- `max_age_ticks` içinde basılamayan olay düşer; düşen olay sayısı probe'da raporlanır (`PROBE RIVAL_NEWS dropped=`).
- Kural: **her hamle haber bandına en çok bir satır düşer** (§4.6 basım anları). Kapma atfı hamle değildir; rakip başına 2 tikte en çok 1 satır.
- Tip seçilmeden rakip saati başlamaz; haber de yok.

| Olay | EN taslak · TR taslak |
|---|---|
| `ROADMAP` + `TEMPO_LEADER` | "{rival}: {capability} in its new release (filling its own gaps)" · "{rival}: yeni sürümde {capability} (kendi eksiklerini kapatıyor)" |
| `COPY` + `COPY` | "{rival}: {capability} is on the way ({product} shipped it in {version})" · "{rival}: {capability} yakında geliyor ({product} bunu {version} sürümünde çıkardı)" |
| `PRICE_CUT` + `PRICE` | "{rival}: prices cut · {segment} ({n} accounts changed hands)" · "{rival}: fiyatlar indi · {segment} ({n} hesap el değiştirdi)" |
| `PRICE_RECOVER` + `RECOVER` | "{rival}: prices back to normal · {segment} (the pressure is off)" · "{rival}: fiyatlar eski düzeyde · {segment} (baskı kalktı)" |
| `POACH_TELEGRAPH` + `POACH` | "{rival}: recruiters met {employee} (growing its team)" · "{rival}: işe alım ekibi {employee} ile görüştü (kendi ekibini büyütüyor)" |
| `CAPTURE` | "{rival}: the {company} account changed hands (moved to your product)" · "{rival}: {company} hesabı el değiştirdi (senin ürününe geçti)" |

### 8.2 Ürün sekmesi bağları (rev 7 görünüm sözleşmesi; ⚑ satırlar bilinçli ayrılıştır)

| Öge (rev 7 §2) | Bugün | A1 kaynağı / kuralı |
|---|---|---|
| Alan satırı çipi `PRODUCT_RIVAL_TOPIC` "Rakip: {topic}" | `rival_hits` son 3 oyuncu sprinti | Aktif rakiplerin `move_log`'unda bu alanın hatlarında `result == landed` olan `roadmap_tier` ya da `copy_tier` ve `player_sprint` son `expectation.chip_window_player_sprints` (3) içinde; `{topic}` §7.2 kuralıyla (`SprintCatalog.cap_name`) |
| Alan cümlesi eki `PRODUCT_AREA_RIVAL` | Aynı | Aynı kaynak |
| "n/m rakipte var" (YAPILANLAR) | Tablo kademesi ≥1 | n = aktif rakiplerden o hatta `line_tiers ≥ 1`; m = aktif rakip sayısı (3; A2'de 4) |
| ⚑ Bayrak (bu ve sonraki sprint) | Statik `launches` | Aktif rakiplerin `pending`'indeki `roadmap_tier` ve `copy_tier` girdilerinden `args.line`'ı bu alana ait olanların `land_day`'i o sütunun tik penceresine düşüyorsa; fiyat ve çelme girdileri Ürün'de bayrak üretmez. Pencere (yarı açık, iniş günü tek sütuna düşer): başlamış sprintte `[start_day, start_day + sprint_weeks)`; sonraki sprintte `[start_day + sprint_weeks, start_day + sprint_weeks + 3)` (otomatik başlangıçta döngü 3 tik [kod `sprint_system.gd:30-38, 439-440`]) |
| ⚑ ÇEYREK sütun bayrakları | Statik `launches` | İlk iki sütun dışında rakip bayrağı yok (açık karar 23); ileri hamleler yalnız telgraflandıktan sonra Rakipler "Hazırlanıyor"da görünür |
| Sesler `PRODUCT_RIVAL_VOICE` | Statik çıkışlar | İnen `roadmap_tier`/`copy_tier` + **yeni**: taahhüt edilmiş `copy_tier` için `PRODUCT_RIVAL_VOICE_PLAN_<n>` ("{rival} is planning this: {capability}" · "{rival} bunu planlıyor: {capability}") |
| Kart etkisi "rakip açığını kapatır" (`rival_gap`) | `_rival_tier` tablo | `max(aktif rakiplerin line_tiers[hat])` |
| ⚑ Beklenti | Faz değeri + 0,5 × tüm isabetler (birikimli), en çok +1 | Faz değeri + `push.expectation_bump[alan]`. "birikimli" seçilirse `engine.bumps {alan: 0..2}` tutulur: MVP sonrası inen her `roadmap_tier`'da `RivalSystem` +1 yazar (2'de durur), artış = 0,5 × `bumps[alan]` (`move_log` 8'e budandığı için koşu boyu sayaç ondan türetilmez). Kopya (`copy_tier`) iki seçenekte de sayılmaz (§10.8 madde 2); MVP öncesi inişler sayılmaz (D42); tavanı 1 olan alan (Gelir) 0. Açık karar 11: "pencereli" = 0,5 × son `expectation.window_sprints` (6) rakip sprintinde bu alanın hatlarında `overtook == true` inen `roadmap_tier`, en çok 1; "birikimli" = rev 7 kuralı: koşu boyu bu alanın hatlarına inen her `roadmap_tier` +0,5, en çok 1 |
| ⚑ Durum kelimesi | `word_for(level, expect)` | `strong` eşiği `min(expect + 1, alan_tavanı)` olur: alan tavandaysa Güçlü erişilebilir kalır |
| Lider önerisi / PM planlayıcı | `rival_gap` ağırlığı | Aynı, yeni kaynaktan |

`SprintCatalog.area_level_for(area_id, tiers) -> float` saf yeni fonksiyondur: alanın katalog (çalışma zamanı olmayan) hatları üzerinde ortalama, verilen sözlükteki `cap_paid_plan` kademesi, sıfır cila, 0,5'e yuvarlama. Oyuncunun gösterilen seviyesi mevcut `area_level` ile kalır. Ürün görünümleri `rival_world_changed`'de de yeniden boyar. Aynı tikte sprint kapanışı (slot 1) hamle inişinden (slot 4b) önce koşar; o tikin sürüm notu hamle öncesi beklentiyi okur (kabul).

### 8.3 Rakipler görünümü (asgari, A1)

**Barındırma** açık karar 7'ye bağlıdır; bileşen barındırmadan bağımsız bir görünüm sözleşmesi (`RivalsModel`) ve tek sahne (`RivalsView`) olarak yazılır.

| Seçenek | Dokunulan dosyalar | Bedel |
|---|---|---|
| **Ürün (öneri)** | `scripts/tabs/product_tab.gd` (SPRINT · ÇEYREK · RAKİPLER düğmesi `PRODUCT_VIEW_RIVALS` "RIVALS" · "RAKİPLER", `PRODUCT_VIEW_SPRINT/QUARTER` kalıbı; RAKİPLER PM kapısına bağlı değil, rakip dünyası kapalıyken gösterilmez), `ProductModel.ui.view` `rivals` değerini alır, yeni `scripts/tabs/product/rivals_view.gd` + `rivals_model.gd` | Kartlardan derin bağ yok (A1'de gerekmez); A2'de iş ve para hamleleri ürün penceresinde durur |
| Sekme | `ui_tokens.gd TABS` (9. sekme), `LeftTabs.tscn`, `left_tabs.gd`, `window_layer.gd` TAB_SCENES/SPECS, yeni `RivalsTab.tscn` + `rivals_tab.gd`, `TAB_RIVALS`, ikon | ch12'de yeni ray sekmesi tasarım kararı; ch10 §6 "yeni sekme yok" der; `goto_tab` motor değişmeden çalışır |
| Satış | `sales_tab.gd` (alt görünüm mekanizması yok) | **İkinci Satış istisnası** ister; ch10 §6 ile uyumlu |

**Görünüm sözleşmesi.**
```
RivalsModel.live() = {
  state: "off" | "no_type" | "not_playable" | "live",
  header: {market_text, league: {rank, total} | null, league_note_key},
  rows: [{
    id, name, arch_key, active: bool,
    areas: [{area_id, mark: "up" | "eq" | "down", hover}],
    price_text,
    preparing: {text, weeks} | null,
    last: {date_text, headline, why} | null,
    capture: [{segment_key, n, need, weeks_left}],           # yalnız Lider, B2B; n ≥ 1 olan segmentler, SalesArchetypes.ids() sırasıyla; yoksa []
    memory_text,
    log: [{date_text, headline, why}]                          # son 5, açılır panel
  }],
  contested: [{segment_key, rival_name, reason}]               # B2B, çizgi arkası
}
```
`--rivals-shot=<no_type|not_playable|pre_mvp|active|copy_pending|price_cut|poach|poach_card|backup_only>` fikstürleri aynı biçimi elle verir (rev 7 `ProductModel` kalıbı); `poach` fikstürü ayrıca `RivalSystem.debug_set_poach` ile `engine.poach_pending`'i kurar.

**Yerleşim.** RAKİPLER, ÇEYREK gibi sprint görünümünün yerini tam genişlikte alır. Başlık bandı, altında satır listesi. Her rakip satırı bir `PaperCard`, iki satır: üstte ad · arketip (`DataMono`), alan şeridi, fiyat duruşu (`Stamp`/`StampGrey`); altta Hazırlanıyor ve Son hamle (`TickerLabel`). Kapma, Hafıza ve son 5 hamle açılır panelde (tek seferde bir satır açık). Kullanılan variation'lar: `FolderWindow`, `PaperCard`, `PaperCardOpen`, `Stamp`, `StampGrey`, `DataMono`, `TickerLabel`, `TabLabel`, `AttentionBadge`.

| Öge | Gösterir (EN · TR taslak) | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Başlık | "{market} · League {rank}/{total}" · "{market} · Ligde {rank}/{total}" | `RivalRegistry.get_player_rank_in_startup_league(ProductState.subtype(), QualityModel.shipped_composite())`; yalnız açık karar 10 "kademeden" iken (aynı ölçek); MVP öncesi "League: product not live yet" · "Lig: ürün henüz canlı değil" | Hover: "Open bugs count toward this rank" · "Açık hatalar bu sıraya dahil" |
| Satır listesi | 5 startup | Aktifler sabit sırada önde, yedekler soluk "No moves yet" · "Henüz hamle yok"; lig toplamı satır sayısı + 1 (fonksiyon değişmez) | Tık: açılır panel; aynı anda tek satır açık |
| Ad + arketip | "Halvero · INCUMBENT" · "Halvero · YERLEŞİK" | `product_name`, `RIVAL_ARCH_<ID>` | Hover: `RIVAL_ARCH_<ID>_DESC` (§11) |
| Alan şeridi | Her alan için ▲ / = / ▼ | `area_level_for(rakip) − oyuncunun gösterilen seviyesi`: ≥ 0,5 ▲, ≤ −0,5 ▼, arası =. B2B: core, onboarding, integrations, trust; B2C: core, onboarding, growth, trust, revenue | Hover: "{rival} ■■□ · you ■□□" · "{rival} ■■□ · sen ■□□" |
| Fiyat duruşu | "Price stance: Premium" ya da "Price stance: Premium · Bureaucratic: Standard" · "Fiyat duruşu: Premium" / "Fiyat duruşu: Premium · Bürokratik: Standart" | `price_posture` → `SALES_STANCE_CAPTION` ve `SALES_STANCE_` + kimlik.to_upper() [kod `strings.csv:2261-2264`]; tabandan farklı segment ayrıca yazılır; B2C tek segment | Hover (segment adı): "Sectors: {sectors}" · "Sektörler: {sectors}" (`SalesArchetypes.sectors(id)` → `SECTOR_*`); hover (duruş): "since {date}" · "{date} tarihinden beri" (`posture_since`) |
| Hazırlanıyor | kopya/yol haritası "Preparing: {capability} · ~{n} weeks ({why})" · "Hazırlanıyor: {capability} · ~{n} hafta ({why})"; fiyat "Preparing: price change · {segment} · ~{n} weeks" · "Hazırlanıyor: fiyat değişikliği · {segment} · ~{n} hafta"; çelme "Preparing: a hiring talk · ~{n} weeks" · "Hazırlanıyor: işe alım görüşmesi · ~{n} hafta"; A2: giren "Preparing: a new rival" · "Hazırlanıyor: yeni rakip", tur "Preparing: a funding round" · "Hazırlanıyor: yatırım turu" | En yakın `pending` girdisi; `n = land_day − day`; `_ONE` tekil varyantı (sözlük kalıbı) | — |
| Son hamle | "{date} · {headline} ({why})" | `move_log`'un son `landed` girdisi (`day < 0` göç girdileri gösterilmez); çelme için "{date} · Offer to {employee}: left/stayed" · "{date} · {employee} için teklif: ayrıldı/kaldı" | — |
| Kapma sayacı (yalnız Lider, B2B, açılır panel) | `RIVALS_CAPTURE` "{segment} {n}/{need} · {weeks} weeks left" · "{segment} {n}/{need} · {weeks} hafta kaldı" (+ `_ONE`) | `captures` penceresi; `{n}` kapma sayısı, `{need}` = `price.captures`, `{weeks}` = en eski kapmanın pencereden çıkmasına kalan hafta | — |
| Hafıza (açılır panel) | `RIVALS_MEMORY` "Memory · taken by you: {taken} · copied by it: {copies}" · "Hafıza · senin aldığın: {taken} · onun kopyaladığı: {copies}" | `memory` | — |
| Son 5 hamle (açılır panel, çizgi arkası) | Her biri "{date} · {headline} ({why})" | `move_log` (`landed`; `day < 0` göç girdileri gösterilmez) | — |
| Çekişmeli müşteri tipleri (B2B, çizgi arkası) | `RIVALS_CONTEST_AREA` "{segment}: {rival} is ahead" · "{segment}: {rival} önde"; `RIVALS_CONTEST_PRICE` "{segment}: {rival} is cheaper" · "{segment}: {rival} daha ucuz"; `RIVALS_CONTEST_BOTH` "{segment}: {rival} is ahead and cheaper" · "{segment}: {rival} önde ve daha ucuz" | `push.contest_by_archetype[a].reason`; **puan basılmaz** (Satış'ın "rakam yok" kuralı [kod `sales_meeting_system.gd:182`]) | Hover: sektörler |
| Finansman (A2) | "Seed" damgası | `funding_stage` | Hover: son tur tarihi |
| Kadro (A2) | "~{n} people" · "~{n} kişi" | `headcount` | — |

**5 saniye testi.** Oyuncu görünümü açtığı 5 saniyede şu üçünü söyleyebilmelidir: (1) kim önde (alan şeritleri), (2) kim bana ne yaptı ve neden (Son hamle + sebep), (3) sırada ne var (Hazırlanıyor). Görsel kabulde 1920×1080 ve 1600×900'de, TR ve EN.

**Uç durumlar.** Tip seçilmedi: Ürün sekmesi tip seçiciyi gösterdiği için durum yalnız `--rivals-shot=no_type` fikstürüyle doğrulanır ("No product type chosen yet" · "Ürün tipi henüz seçilmedi"). Oynanabilir olmayan alt-tür: "Rivals are not tracked for this product type" · "Bu ürün tipinde rakip izlenmiyor". Rakip dünyası kapalı (`off`): RAKİPLER düğmesi yok. MVP öncesi: lig gizli, satırlar var (rakipler tip seçiminden beri hareket eder). Hiç hamle yok: "No moves yet". Uzun ad (ör. EN'de "Glyphnote" gibi uzun tek kelime): `clip_text` + hover tam ad.

### 8.4 Satış görüşmesi eki (onaylı tek dikiş)

**Hesap (RivalSystem, push).** Her `a ∈ SalesArchetypes.ids()` için (sprint.json `default` anahtarı döngüye girmez): alan `A = sprint.json archetypes[a]`. Her aktif rakip `r`:
- `gap = area_level_for(A, r) − oyuncunun gösterilen A seviyesi` (0,5 adımlı).
- `dilim = floori(gap / contest.dilim)`; Niş ve `A == home_area` ve `gap > 0` ise `dilim += contest.niche_home_bonus_dilim`.
- `area_points = contest.points[mini(dilim, 2) − 1]` (dilim ≥ 1 ise), yoksa 0.
- `price_points = contest.price_points` eğer `gap ≥ 0` ve `SalesArchetypes.is_price_sensitive(a)` ve `rank(r.price_posture[a]) < rank(SalesLedger.price_stance())` (`competitive` 0 < `standard` 1 < `premium` 2); yoksa 0.
- `points(r) = mini(area_points + price_points, contest.cap_points)`; `reason` = area / price / both.
`contest_by_archetype[a]` = en büyük `points`'lu rakip (eşitlikte sabit rakip sırası, hafta hafta ad değişmez). Tanışma süresi: `var l = GameState.get_flag("mvp_launch_day", -1)`; `l < 0` ya da `day < l + TimeModel.ticks(contest.grace_weeks)` iken tüm puanlar 0 (açık karar 13). Puan 0 ise girdi yazılmaz.

**Satış'taki tek dikiş.**
- `_build_base_contributions(p)` sonuna: `var c: Dictionary = GameState.rival_world.get("push", {}).get("contest_by_archetype", {}).get(p.archetype_id, {})`; `int(c.get("points", 0)) > 0` ise `out.append({"seam": "rival.contest", "delta": -float(c.points) / 100.0, "rival": c.rival_id, "reason": c.reason})`. Rakip id katkının içinde taşınır: kayıp görüşmede `ProspectRegistry.remove` prospect'i sildikten sonra kapanış görünümü kurulurken de etiket adı bulunur [kod `sales_meeting_system.gd:324, 381`]. `EvDice.modifier_lines` fazla anahtarları yok sayar [kod `dice.gd:48-55`].
- `_modifier_labels()`'a tek giriş: `"rival.contest"` → `_base_contributions` içindeki `rival.contest` katkısının `reason`'ına göre `SALES_MOD_RIVAL` ("{rival} is ahead here" · "{rival} bu konuda önde"), `SALES_MOD_RIVAL_PRICE` ("{rival} sells it cheaper" · "{rival} bunu daha ucuza veriyor") ya da `SALES_MOD_RIVAL_BOTH` ("{rival} is ahead and cheaper" · "{rival} hem önde hem daha ucuz"); `{rival}` = `RivalRegistry.get_rival(id).product_name`.
- `sales_meeting_adapter.CHIP_BY_SEAM`'e tek satır: `"rival.contest": "MEETING_CHIP_PREP"`.
- `rival.contest` EvSeams'e kaydolmaz: Satış katkı anahtarlarının çoğu bugün de kayıtlı seam değildir; anahtar yalnız `_modifier_labels` ve `CHIP_BY_SEAM` girdisidir; motor `rival.` ad alanını rakip varlığına bağlar ve prospect ad alanı yoktur [kod `scope.gd:128-135`].

**Görünürlük sözleşmesi.**

| Öge | Gösterir | Kaynak / kural | Etkileşim |
|---|---|---|---|
| TUTUM hover satırı | "▼ {rival} is ahead here" · "▼ {rival} bu konuda önde" (ya da fiyat / ikisi) | Açılıştan itibaren `EvDice.modifier_lines` [kod `sales_meeting_adapter.gd:130-136`]; puan basılmaz | Hover |
| Zar seçeneği çipi | `MEETING_CHIP_PREP` kategorisinde aynı etiket | "Teklife geç" 2. sorudan itibaren; 1★ tek soruluk görüşmede çip yok, yalnız hover [kod `sales_meeting_system.gd:287`, `sales_constants.gd:99, 102`] | Hover |
| Görüşme öncesi | Rakipler görünümünün "çekişmeli müşteri tipleri" bloğu | §8.3 (puansız) | — |
| Görsel kabul | — | Yeni `--meeting-shot=rival` türü (7b. ajan, `scripts/main/main.gd`): `RivalSystem.debug_set_push` ile 20 puanlık bir girdi ve 6 taban terimi (uyum, kurucu satış, kadran, sağlayıcı, lig farkı, geri dönüş) olan bir prospect kurar; kabul, rakip satırının 4 satır tavanında görünmesidir | — |

**Bilinen sınırlar (yazılı).** Kayıp nedeni rakibi anmaz (`_derive_loss_reason` değişmez); temsilci kapanışı çekişmesizdir; hafta içinde kadran değişince push senkron yenilenir ama açık görüşmenin taban terimleri açılışta donmuştur (mevcut davranış).

### 8.5 VC ekleri [A2]

| Öge | Gösterir (EN · TR taslak) | Kaynak / kural | Etkileşim |
|---|---|---|---|
| Karşılaştırılabilir | "{rival} raised last quarter" · "{rival} geçen çeyrek tur aldı" | Son 6 rakip sprintinde inen `funding_round`; `_conviction_series_a` "neden" listesine en çok 1 satır (açık karar 17) | Hover: rakibin `funding_stage` değeri |
| Değerleme çıpası | Görünür satır yok; çarpan | Lig sırası: 1. sıra × `vc.rank_mult_top`, her alt sıra × `vc.rank_mult_step`, en az `vc.rank_mult_min`; `_derive_series_a_terms`'e tek okuma | — |
| `_rival_ahead()` kaynağı | — | Bugün her koşuda true [kod `vc_pitch_system.gd:1302-1307`]; A2'de lig sırasından okunur (`rank > 1`). A1'de `status` yazılmadığından davranış değişmez | — |

### 8.6 Mentor [A2]
`RivalSystem` `EventBus.mentor_advisory_changed(key, {"rival": ad})` yayar; rakip çeyreğinde en çok `mentor.per_quarter` (1); `GameState.mentor_line_key` doluysa ezmez. Satırlar Frank'in külliyatıdır: yalnız taslak, Erdem onayı olmadan ekrana çıkmaz (CLAUDE.md §3). A1'de ekranda mentor satırı yok.

| Tetik | Anahtar | Sınır |
|---|---|---|
| İlk `copy_tier` duyurusu | `MENTOR_RIVAL_COPY` | Koşuda 1 |
| İlk `price_cut` inişi | `MENTOR_RIVAL_PRICE` | Koşuda 1 |
| İlk çelme kartı | `MENTOR_RIVAL_POACH` | Koşuda 1 |
| `entry` inişi | `MENTOR_RIVAL_ENTRY` | Koşuda 1 |
| Rakibin ilk `funding_round`'u | `MENTOR_RIVAL_FUNDING` | Koşuda 1 |
| İlk ölüm (A3) | `MENTOR_RIVAL_DEATH` | Koşuda 1 |

### 8.7 Olay kartı: `rival.poach_offer` [A1]

| Alan | Değer |
|---|---|
| Dosya | `data/events/cards/rival/poach_offer.json` |
| `id` / `category` | `rival.poach_offer` / `rival` |
| `tick` / `class` / `tags` | `request` / `interrupt` / `["critical"]` (`team.resignation` kalıbı) |
| `version_scope` | Açık karar 9'a göre `demo` ya da `ea` |
| `scope` | `employee` (önce; entity latch kişiye bağlanır), `rival` |
| `latch` / `latch_key` | `{"one_shot": true}` / `entity` |
| `expires_weeks` | 1 (lint, interrupt için ister); `on_expire` yok: kritik interrupt kâğıda düşmez ve süresi dolmaz (§6.6) |
| Başlık | `RIVAL_EV_POACH_TITLE` "An offer for {employee}" · "{employee} için teklif" |
| Gövde | "{rival} has made {employee} an offer." · "{rival}, {employee} için bir teklif yaptı." |
| Seçenek `counter` | `check: {odds_seam: "rival.poach_odds_counter", on_pass: [{verb: change_salary, scope: employee, pct: 15}, {verb: change_morale, scope: employee, amount: 15}], on_fail: [{verb: employee_leaves, scope: employee, reason: "poached"}]}`; metin "Counter: raise the salary by 15% · chance to stay {seam:rival.poach_pct_counter}%" · "Karşı teklif ver: maaşı %15 artır · kalma ihtimali %{seam:rival.poach_pct_counter}" |
| Seçenek `talk` | `check: {odds_seam: "rival.poach_odds_talk", on_pass: [{verb: change_morale, scope: employee, amount: 5}], on_fail: [{verb: employee_leaves, scope: employee, reason: "poached"}]}`; metin "Talk · chance to stay {seam:rival.poach_pct_talk}%" · "Konuş · kalma ihtimali %{seam:rival.poach_pct_talk}" |
| Seçenek `release` | `effects: [{verb: employee_leaves, scope: employee, reason: "poached"}]`; metin "Let them go" · "Gitmesine izin ver" |
| `modifier_lines` | Lint için zorunlu [kod `lint.gd:198-200, 306-310`]; bugün hiçbir yüzey çizmez [kod `presenter.gd:53-67`]. Satırlar kayıtlı seam'lerle: `hr.morale` (moral), `hr.tenure_weeks` (kıdem) |
| Konuşan | Yok (Frank değil) |

- **Seam'ler** (`seams_world.gd`, `EvSeams.Kind.GLOBAL`; değerleri `engine.poach_pending`'den, kapalıyken 0): `rival.poach_odds_counter`, `rival.poach_odds_talk` (TYPE_FLOAT; motor zar oranını `EvSeams.read` ile okur [kod `engine.gd:479`]); `rival.poach_pct_counter`, `rival.poach_pct_talk` (TYPE_INT; `{seam:}` `str()` bastığı için yüzde tamsayıdır [kod `presenter.gd:197`]).
- Zam ve moral miktarlarının tek kaynağı kart JSON'udur (motor efekt miktarını yalnız sabit sayıdan okur [kod `effects.gd:509-513`]); seçenek metnindeki "%15" aynı dosyadadır. Eşitliği `rival_poach_lifecycle` smoke'u denetler (kart JSON'unu okur, `counter` metnindeki yüzdeyi `on_pass` `change_salary.pct` ile karşılaştırır); `lint.gd`'ye kural eklenmez.
- Çip zar seçeneğinde çizilmez [kod `presenter.gd:66`]; maaş maliyetinin ve oranın tek görünür yeri seçenek metnidir.
- Efekt sırası `[change_salary, change_morale]`: İK sekmesi `morale_changed`'de yenilenir ve yapı anahtarı maaşı içerir [kod `hr_tab.gd:165-180`].
- Oranlar istek anında donar (`poach_pending.odds`), kart masadayken değişmez.

**`change_salary` fiili (onaylı motor işi).**
- `effects.gd _apply` kolu: `{verb, scope: employee, pct}` → `CharacterRegistry.set_salary(id, int(round(float(salary) * (1.0 + pct / 100.0))))`. Bu İK zammının formülüdür (`HRActions._raised_salary` [kod `hr_actions.gd:243-244`]); adım yuvarlaması yoktur; İK'nın özel fonksiyonu çağrılmaz.
- `_is_negative`: `pct`'in yalnız işaretini okur. Kart `on_expire` taşımaz (kritik interrupt süresi dolmaz).
- `EvChips.describe` kolu (`scripts/events/present/chips.gd`) + `EFFECT_SALARY` ("Salary {pct} · {who}" · "Maaş {pct} · {who}"); `{pct}` = işaret + `Fmt.percent(absi(pct), 0)`; burada `pct` yüzde puanıdır (15 = %15), `audience_delta`/`convert_audience`'taki kesir `pct`'ten (0,05) farklıdır ve ×100 yapılmaz; kalıptan yalnız işaret ve `Fmt.percent` biçimi alınır; `{who}` = çalışanın ilk adı (`EvChips._first_name`); `event_chip_coverage` smoke'u yeşil.
- Bilinen sınırlar: `salary_floor`, `last_raise_day` ve istihdam geçmişi yazılmaz (`HRActions.apply_raise`'in yaptıkları; İK koduna dokunulmaz); İK zammı hemen ardından yine yapılabilir. ACIK_KARARLAR madde 14'teki uygulanmamış fiillerden birini kapatır.

**A2/A3 kartları:** `rival.player_poach` ve `rival.poach_back` (A2; aynı kalıp), `rival.acquisition_offer` (A2; mevcut `funding.acquisition_offer`'ın alıcısı adlı rakip olur, açık karar 4), `rival.partnership` ve `rival.press_reply` (A3).

### 8.8 Bitiş gazetesi ve startup ligi

| Öge | Gösterir (EN · TR taslak) | Kaynak / kural | Art. |
|---|---|---|---|
| Lig (Rakipler görünümü başlığı) | "{market} · League {rank}/{total}" | §8.3 | A1 |
| Lig satırı (gazete) | "League position at the end: {rank} of {total}" · "Kapanışta lig sırası: {rank}/{total}" | `GameState.get_run_ledger()`'a `rival_rank {rank, total}` (koşu sonunda lig fonksiyonu); `EndingsCopy` Series A, satış ve kârlı bootstrap kurucularına tek satır | A2 |
| En çok uğraşılan rakip (gazete) | "The rival you fought most: {rival}" · "En çok uğraştığın rakip: {rival}" | `rival_most {rival_id}` = en yüksek `memory.out` toplamı | A2 |

Oyunda IPO sonu yoktur; görevin "IPO'da lig sıralaması" maddesi Series A, satış ve kârlı bootstrap gazetelerindeki lig satırıyla karşılanır.

### 8.9 Ar-Ge notu
`rnd_system._rival_name` bugün `RivalCatalog.NAMES`'ten herhangi bir dev olmayan adı seçer [kod `rnd_system.gd:534-538`]; A1'de `RivalRegistry.active(subtype)`'tan seçer (son `move_log` hamlesi olan rakip öncelikli). Notun "nitel, sayı yok" kuralı değişmez.

### 8.10 Pazar payı kartı

| Öge | Gösterir | Kaynak / kural | Art. |
|---|---|---|---|
| Pay satırı | Bugünkü snapshot | `get_market_snapshot` şablon momentumu (Finans koduna dokunulmaz) | A1 |
| Hareket haberi | Rakip satırı | `headlines` (§8.1) | A1 |
| Pay ofseti | Snapshot satırına eklenir; trend önceki tikin saklı değerinden | `share_offset`: `funding_round` `+share.funding`, `price_cut` `+share.price_cut`, ölümde 0; yalnız oynanabilir alt-türlerde (diğer 10 alt-türün saf eğrisi ve `market_share_tracks_mrr` smoke'u korunur) | A2 |

---

## 9. Etkileşim matrisi

| Sistem | Giren sinyal (rakip dinler) | Çıkan etki | Çalışma değeri | Kod dokunuşu | Art. |
|---|---|---|---|---|---|
| **Satış · B2B görüşme** | `deal_signed` (kapma atfı), `price_stance_changed` (push yenileme) | `contest_by_archetype` → görüşme iğnesine tek terim | 15/30 (açık karar 12: 12/20), fiyat 6, tavan 30, tanışma 12 hafta | Onaylı tek dikiş (§8.4) | A1 |
| **Satış · B2C kitle** | Yok (tüketici RivalRegistry'den çeker; rakip `rival_moved` yayar) | Canlı + yedek startup eksenleri `_rival_relative_quality`'ye mevcut okuma yoluyla; B2C'de kapma atfı yoktur | `RIVAL_TIER_HALF_SAT` (açık karar 21, §10.5) | Yok (Satış RivalRegistry'den zaten okur; sabit `quality_model.gd`'de) | A1 |
| **Satış · temsilci** | `deal_signed` (atıf) | Kapma sayılır; çekişme uygulanmaz (bilinen sınır) | Çekişme 0 (temsilci kapanışı terim almaz); kapma 1 sayılır ve Lider'in fiyat sayacına girer (`price.captures` 2) | Yok | A1 |
| **Satış · rakibe kayıp** | `customer_churned` | Atıf + haber `CHURN_TO_RIVAL`; `memory.out.stole` | Rakip başına 2 tikte en çok 1 satır | Yok | A2 |
| **Satış · B2C fiyat** | Yok (A2; rakip `rival_moved(price_cut)` yayar) | Fiyat baskısı | Açık karar 6 | "evet" ise ikinci Satış istisnası | A2 |
| **İK** | `employee_departed`, `event_resolved` | Çelme kartı; `change_salary`, `change_morale`, `employee_leaves` | Çeyrekte 1, hafta ≥ 26, moral 35–49, ★ ≥ 3 | Yok (motor fiili onaylı) | A1 |
| **İK · iki yönlü** | Kart sonucu | Oyuncu çelmesi ve geri çelme | Çeyrekte 1 + 1 | Açık karar 5 "evet" = İK aday üreticisi + Finans `hire` etiketi istisnası | A2 |
| **Finans** | Yok (tüketici RivalRegistry'den çeker; rakip `rival_moved` yayar) | Pay ofseti `get_market_snapshot` üzerinden (Finans kartı RivalRegistry'den çeker, kod değişmez) | `share.funding` 0,02, `share.price_cut` 0,01, ölümde 0 | Yok | A2 |
| **Finans · VC beklentisi** | Yok (VC okuması RivalRegistry'den; rakip `rival_moved(funding_round)` yayar) | Finansman haberi VC karşılaştırılabilirine girer (§8.5) | Son 6 rakip sprinti | VC'ye tek okuma (açık karar 17) | A2 |
| **Olaylar** | `event_resolved` (rakip kartları) | `EventGate.request("rival.*", {employee, rival})`; GLOBAL çelme seam'leri | Kart başına latch | Seam + kart JSON + `change_salary` | A1 |
| **VC** | `seed_round_closed` | Karşılaştırılabilir satırı + değerleme çıpası | `vc.rank_mult_*` | Açık karar 17 | A2 |
| **Fazlar** | `GameState.phase` (türetilmiş) | Series A Hunt'ta aralık × 0,85; Traction'da giren | `phase_interval_mult`, `entry.min_phase` | Yok | A1 (çarpan), A2 (giren) |
| **Sonlar** | Koşu sonu | Rakibe satılma sonu (açık karar 4); gazete lig satırı ve en çok uğraşılan rakip; IPO sonu yok (§8.8); A3 rakip çöküşü haberi | Gazetede 2 satır | `EndingsSystem`/`EndingsCopy` (yasak listesinde değil) | A2/A3 |
| **Ürün** | `line_upgraded` (beklenti ve çekişme push'u ayrıca 4b'de yenilenir) | `expectation_bump` (açık karar 11: "pencereli" yalnız `overtook`, "birikimli" her inen `roadmap_tier`; kopya ve MVP öncesi inişler sayılmaz), çip, bayrak, n/m, Ses, `rival_gap`; dalgada ilk çıkan çipi (rezerve, `waves.*`) | +0,5 / +1; "pencereli" ise pencere 6 rakip sprinti | `SprintCatalog`, `ProductModel`, `area_panel`, `product_tab` (serbest) | A1 |
| **Ar-Ge** | Yok (tüketici RivalRegistry'den çeker) | Not satırında aktif rakip adı | Son hamle önceliği | `rnd_system.gd` tek fonksiyon | A1 |
| **Haber** | Yok (NewsFeedSystem `engine.headlines`'ı kendi kaynak seçiminde okur, §8.1) | "rakip" türüne olay satırları | Hamle başına en çok 1 satır, en çok 2 tik bayat | `news_feed_system.gd` (serbest) | A1 |

---

## 10. Kalibrasyon

Sayıların kaynağı: **[ölçüm]** = bugünkü yapıda (`6c87431`, canlı rakip yok) koşulan `--run-log` taban ölçümü; **[hesap]** = repo verisinden (`rivals.json`, `sprint.json`, `lines/*.json`, `quality_model.gd`, `sales_*`) Python ile yeniden kurulan tablolar (oyuncu profilleri varsayımdır, §10.11). Ölçülmemiş her yargı **[çıkarım]** etiketlidir.

### 10.1 Çalışma değerleri (tek tablo)

| Değer | Görev değeri | Bu PRD | JSON yolu |
|---|---|---|---|
| Başlangıç aktif rakip | 3 | 3 | `field.json living.<alt-tür>.slots` |
| Traction'da giren | 1 | 1 (A2) | `rules.json entry.count`, `entry.min_phase` |
| Aynı anda en çok aktif | 4 | 4 (A2) | `rules.json caps.max_active` |
| Rakip sprinti / çeyreği | — | 2 tik / 6 rakip sprinti (12 tik) | `rules.json clock.*` |
| Tempo (rakip sprinti / +1 kademe) | Lider 6 · Kopyacı 4 · Niş 5 (ev 3) · Parayı Bulan 3 | Aynı | `rules.json archetypes.<id>.interval`, `niche.interval_after_home` |
| Faz aralık çarpanı | — | 1,0 / 1,0 / 0,85, tamsayıya yuvarlanır | `rules.json phase_interval_mult` |
| Rakip K3 kapısı | — | hafta ≥ 52 ve K2'de ≥ 8 rakip sprinti (açık karar 22) | `rules.json k3.*` |
| İlk hamle | — | tip seçiminden ≥ 1 rakip sprinti + sıra + hash fazı | `rules.json clock.first_move_sprints` |
| Kopya gecikmesi | 3 sprint | 3 rakip sprinti (≥ 6 hafta) | `rules.json copy.delay_sprints` |
| Kopya eksiği | 1 kademe | oyuncu − 1 (katı kural §5.4) | sabit kural |
| Kopya tetik kademesi | — | oyuncu K ≥ 2 | `rules.json copy.min_player_tier` |
| Kopya hat kilidi | 12 sprint | 12 rakip sprinti | `rules.json copy.line_lock_sprints` |
| Lider fiyat kırma tetiği | 2 müşteri | 2 kapma / 6 rakip sprinti, aynı segment | `rules.json price.captures`, `.window_sprints` |
| Fiyat kırma soğuması | 8 sprint | 8 rakip sprinti; sonra en erken 8 rakip sprintinde bir, Lider'in tempo tikinde bir basamak geri (pratikte 12) | `rules.json price.cooldown_sprints`, `.recover_every_sprints` |
| Çelme sıklığı | çeyrekte 1 | çeyrekte 1, çeyreğin 3. rakip sprintinde, hafta ≥ 26 | `rules.json poach.min_week`, `.quarter_sprint` |
| Çelme hedefi | moral düşük, alan yüksek | moral 35–49, anahtar alan ★ ≥ 3, kıdem ≥ 4 hafta | `rules.json poach.morale_min/max`, `.key_stars_min`, `.tenure_weeks_min` |
| Çelme oranı, karşı teklif | başarı oranı görünür | taban 0,60 + moral puanı başına 0,010 (35 üstü) | `rules.json poach.odds.counter` |
| Çelme oranı, konuş | — | taban 0,30 + moral puanı başına 0,015 | `rules.json poach.odds.talk` |
| Özellik etkisi | — | sadık +0,15 · gözü yüksekte −0,20 | `rules.json poach.odds.trait` |
| Oran sınırı | — | 0,05–0,95 | `rules.json poach.odds.min/max` |
| Karşı teklif zammı ve moral | — | %15 zam + 15 moral; konuşmada 5 moral | kart JSON (`rival.poach_offer`) |
| İşe alım iştahı | — | Lider 0,5 · Kopyacı 1,0 · Niş 0,2 · Parayı Bulan 1,5 | `rules.json archetypes.<id>.hire_appetite` |
| Basın iştahı | — | Lider 0,2 · Kopyacı 0,5 · Niş 0,2 · Parayı Bulan 1,0 (A2) | `rules.json archetypes.<id>.press_appetite` |
| Çekişme | 1 dilim −15, 2 dilim −30 | aynı (açık karar 12: 12/20 önerisi); dilim = 1,0 seviye | `rules.json contest.points`, `.dilim` |
| Niş ev alanı bonusu | — | +1 dilim, yalnız kesin öndeyken | `rules.json contest.niche_home_bonus_dilim` |
| Çekişme fiyat bileşeni | — | 6, yalnız fiyata duyarlı arketip | `rules.json contest.price_points` |
| Çekişme tavanı | — | 30 | `rules.json contest.cap_points` |
| Tanışma süresi | — | MVP + 12 hafta (açık karar 13) | `rules.json contest.grace_weeks` |
| Çeyrek tavanı | 6 | 6 = tempo ≤ 4 + tepki ≤ 2 (tür başına ≤ 1) | `rules.json caps.*` |
| ⚑ Beklenti etkisi | +0,5, en çok +1 (rev 7) | açık karar 11: "pencereli" yalnız `overtook`, 6 rakip sprinti; "birikimli" rev 7 kuralı (kopya ve MVP öncesi inişler hariç) | `rules.json expectation.*` |
| Telgraf süresi | — | Tempo ve fiyat 1 rakip sprinti; çelme 1 tik | `rules.json clock.telegraph_sprints`, `price.telegraph_sprints`, `poach.telegraph_ticks` |
| Rakip başına rakip sprintinde iniş | — | 1 (çelme hariç) | `rules.json caps.per_rival_sprint` |
| Çelme kapanış zaman aşımı | — | 2 tik | `rules.json poach.close_timeout_ticks` |
| VC lig çarpanı (A2) | — | 1,00 / her alt sıra ×0,97 / en az 0,90 | `rules.json vc.rank_mult_*` |
| Alan çipi penceresi | 3 sprint (rev 7) | 3 oyuncu sprinti | `rules.json expectation.chip_window_player_sprints` |
| Haber | hamle başına tek satır | aynı; en çok 2 tik bayat; kapma rakip başına 2 tikte 1; en çok 12 girdi tutulur | `rules.json news.*` |
| Haber varyantları | — | §11 adetleri | `rules.json content.*` |
| Sönen | 3 çeyrek gerileyen | 3 rakip çeyreği (Parayı Bulan ayrıca 4 çeyrek tursuz); ölüm Sönen'den 2 rakip çeyreği sonra (A3) | `rules.json states.*` |
| Alıcı | Lider ya da Parayı Bulan, oyuncu Series A'dayken | aynı (A2 koşul, A3 durum) | `rules.json acquisition.archetypes` |
| Finansman turu, basın, geri çelme, oyuncu çelmesi | — | Tur olasılığı `press_appetite × 0,5`, tur soğuması 2 rakip çeyreği, turdan sonra 1 çeyrek aralık −1, kadro +4; basın soğuması 2 rakip çeyreği; geri çelme çeyrekte 1; oyuncu çelmesi taban 0,40, iştah çarpanı −0,10, maaş primi %20 (A2) | `rules.json funding.*`, `press.*`, `poach_back.*`, `poach.player.*` |
| Ortaklık, akıl oyunu, yorum, tırmanma | — | Ortaklık 0,5, soğuma 4 rakip çeyreği; akıl oyunu en az 3 kapma, soğuma 2 rakip çeyreği; yorum 0,3, çeyrekte 1; tırmanma 4 kapmadan sonra fiyat tetiği 1 kapma (A3) | `rules.json partnership.*`, `mindgame.*`, `comment.*`, `escalation.*` |
| Pay ofseti, mentor | — | Tur +0,02, fiyat kırma +0,01, ölümde 0; mentor rakip çeyreğinde 1 (A2) | `rules.json share.*`, `mentor.*` |
| Zorluk | — | §10.10 (A2) | `rules.json difficulty.*` |

`data/product/sprint.json`'dan `rival_bump`, `rival_bump_max`, `rival_window_sprints` ve `content.rival_news` silinir (yerleri `expectation.bump`, `expectation.bump_max`, `expectation.chip_window_player_sprints`, `content.news_variants`); `impact.rival_gap` sprint.json'da kalır.

### 10.2 Baskı tavanları ve soğumalar

| Baskı | Tavan | Soğuma / pencere |
|---|---|---|
| Beklenti artışı | +1 alan başına | Açık karar 11: "pencereli" 6 rakip sprinti; "birikimli" pencere yok |
| Çekişme | 30 puan (iğne −0,30) | Tanışma süresi 12 hafta; push haftalık + kadran ve kademe değişiminde |
| Kopya | Hat başına 1 kademe, oyuncu − 1 | 12 rakip sprinti |
| Fiyat kırma | Segment başına 1 basamak, taban `competitive` | 8 rakip sprinti |
| Çelme | Çeyrekte 1, kişi başına koşuda 1 | Rakip çeyreği |
| Toplam hamle | Çeyrekte 6 (alan geneli), rakip başına rakip sprintinde 1 | Rakip çeyreği |

### 10.3 Tempo ve tavan hesabı [hesap]

| Alan | Faz | Toplam kademe talebi / rakip çeyreği | Tavan 6 | Tempo alt tavanı 4 |
|---|---|---|---|---|
| 3 aktif, Niş ev alanı açık | Bootstrap / Traction | 4,50 (Lider 1 · Kopyacı 1,5 · Niş 2) | uyar | **aşar** (bir tempo hamlesi düşer) |
| 3 aktif, Niş ev alanı açık | Series A Hunt (aralıklar 5 / 3 / 3) | 5,20 | uyar | **aşar** |
| 3 aktif, Niş ev alanı dolu | Bootstrap / Traction | 3,70 | uyar | uyar |
| 4 aktif (+ Parayı Bulan) | Traction | 6,50 | **aşar** | **aşar** |
| 4 aktif (+ Parayı Bulan) | Series A Hunt | 7,20 | **aşar** | **aşar** |

Gerçekleşen (simülasyon, tipik oyuncu, katı Kopyacı): rakip çeyreği başına 3–5 inen kademe hamlesi; Kopyacı Q3–Q5'te 2–6 kez "uygun hat yok" yüzünden bekler (oyuncu K2'de durur, Kopyacı her yerde K1'dedir). Tempo alt tavanı Niş'in ev alanı açıkken bağlar; adalet kuralı (§6.3) yeri bu rakip çeyreğinde en az tempo taahhüdü (inmiş ya da bekleyen) olan rakibe verir. A2'de dördüncü rakiple tavan aşılır (açık karar 16: 8 önerilir).

**Ana bulgu: görev tempolarıyla rakip, ilerleyen oyuncuyu geçmez.** Tek kişilik kurucu bile çeyrekte ≈6 K1 (≈3,6 K2) kademe çıkarabilir, iki kişilik ekip ≈14 (≈8,4); üç rakipli alan toplamda 4,5. Tipik oyuncu 26. haftada her alanda K2'dedir ve K3 için Ar-Ge bekler (tipik ilk K3 52. hafta, hızlı 40, yavaş hiç); en iyi rakip alan seviyesi 52. haftaya kadar 1,0–2,0'da kalır. Rakip baskısı bu yüzden üç yerde doğar:
1. **MVP anı:** tohum kademeleri taze MVP'yi entegrasyon ve güvende 1 dilim geçer (tanışma süresi bunu söndürür).
2. **İhmal:** oyuncunun çalışmadığı alan (ch10 §2'nin "ihmal edilen segment rakibe kayar" çerçevesi).
3. **K3 yarışı:** K3 kapısı 52'de (açık karar 22) rakip K3'ü tipik oyuncuyla aynı haftadan açılır; yavaş oyuncu ve Ar-Ge'yi erteleyen oyuncu K3'te geride kalır.
Rakip "yarış" hissi istenirse lastik olmadan tek düğme tempodur (açık karar 20: "görev" / "ikikat"); ikikatta üç rakip çeyrekte ≈9 hamle ister, tavanlar da birlikte değişmelidir [çıkarım]. Bu belge görev tempolarını korur ve ölçümü ister (§13 madde 11).

### 10.4 Çekişme matematiği

**İğne** [kod `sales_meeting_system.gd:131-179`, `sales_constants.gd:74-97`]: `R = 0,35 + uyum + kurucu Satış + kadran + sağlayıcı − lig farkı`; `0,05 ≤ iğne ≤ 0,97`; `CUT_LOW 0,12`, `CUT_HIGH 0,72`. Çekişme `P` bir katkı olarak eklenir. Bir masa ilk cevapta ancak `R − P + a ≤ 0,12` ise kaybedilir; `a` ilk cevabın katkısı (en az 0,028, en çok 0,092) [hesap]. "−30 = başlangıçta anında kayıp" ifadesi doğru değildir; doğru olan bu eşik formülüdür.

**erp'de çekişme sıklığı** (kurucu görüşmeleri; arketip karışımı 1–2★'da Bürokratik 0,50 · Hevesli 0,25 · Fiyat avcısı 0,25; 3★'da 0,67 · 0,33 · 0) [hesap]:

| Oyuncu | Zaman | Cezalı görüşme payı | Beklenen ceza 15/30 | Beklenen ceza 12/20 | Tanışma süresiyle |
|---|---|---|---|---|---|
| Yavaş / tipik / hızlı | MVP | %74,8 (hep 1 dilim) | 0,112 | 0,090 | 0 |
| Yavaş / tipik / hızlı | MVP + 6 hafta ve sonrası (52. haftaya kadar) | %0 | 0 | 0 | 0 |
| Duran (MVP'den sonra kademe yok) | MVP + 12 hafta | %74,8 | 0,112 | 0,090 | aynı |
| Duran | 52. hafta | 1 dilim %78, 2 dilim %22 | 0,183 | 0,138 | aynı |
| Duran | 78. hafta | 1 dilim %26, 2 dilim %74 | 0,261 | 0,179 | aynı |

**Ceza büyüklüğünün etkisi** (ilk cevapta kayıp payı; iki ilk cevap sınırı için) [hesap]:

| Masa | Zaman | P=0 | P=0,12 | P=0,15 | P=0,20 | P=0,30 |
|---|---|---|---|---|---|---|
| Kurucu ★1 · 1★ (denk) | MVP | %0 / %0 | %11 / %0 | %17 / %11 | %33 / %17 | %58 / %39 |
| Kurucu ★1 · 2★ (+1 lig) | MVP | %17 / %11 | %50 / %33 | %56 / %33 | %69 / %56 | %86 / %75 |
| Kurucu ★2 · 2★ (denk) | MVP | %0 / %0 | %11 / %0 | %11 / %0 | %17 / %11 | %39 / %33 |
| Kurucu ★1 · 1★ (denk) | MVP sonrası ortalama | %0 / %0 | %3 / %0 | %4 / %3 | %8 / %4 | %15 / %10 |
| Kurucu ★1 · 3★ (+2 lig) | MVP sonrası ortalama | %17 / %15 | %21 / %19 | %22 / %21 | %24 / %21 | %50 / %24 |

**Yorum.** (1) Tanışma süresi olmadan ceza en kırılgan anda (MVP masaları, uyum terimi −0,16…+0,17) görüşmelerin %75'ine iner; tanışma süresiyle ilerleyen oyuncu çekişmeyi yalnız ihmal ettiği alanda ve K3 yarışında görür. (2) MVP sonrası 0,20'ye kadar ceza ilk cevap kaybını en çok 13 puan artırır; 0,30 ise 33 puana kadar çıkarır ve iki lig yukarıdaki masada "zaten kayıp" ile ayrışmaz. Öneri **12/20**: 0,12 diğer 0,10'luk terimlerin ve 0,08'lik cevabın üstünde kalır ve 4 satırlık listede görünür; 0,20 iki lig farkının cezasının (0,34) altındadır, rakip "iki lig yukarı oturmaktan" ağır basmaz [hesap + çıkarım].

### 10.5 B2C kıyası [hesap]
Hesap `_rival_relative_quality`'nin gerçek tanımıyla yapıldı: oyuncunun alt-türündeki **5 startup'ın** ortalaması (3 aktif, katı Kopyacı ile simüle; 2 yedek §4.2 tohumuyla, hareketsiz) [kod `sales_system.gd:190-201`].

| `quality_term` (tipik oyuncu) | MVP | 26. hafta | 52. hafta |
|---|---|---|---|
| note_tool, bugün (şablon, half-sat 50) | 14,7 (<42, aşınma) | 34,5 (<42) | 31,3 (<42) |
| note_tool, kademeden, half-sat 50 / 25 / 9 | 54,4 / 44,3 / 22,2 | 80,3 / 68,8 / 45,5 | 78,7 / 66,7 / 43,1 |
| video_clip, bugün | 14,7 | 34,5 | 31,3 |
| video_clip, kademeden, half-sat 50 / 25 / 9 | 54,7 / 44,9 / 22,9 | 80,3 / 68,8 / 45,4 | 77,9 / 65,6 / 42,0 |

- Yavaş ve hızlı profillerde MVP değeri half-sat 25'te 39,8–41,1 [hesap]. Bugünkü MVP değerini tam üretmek half-sat ≈ 6,3–7,1 ister.
- Bugün her B2C ürünü aşınmayla başlar ve tipik oyuncu 52. haftada hâlâ eşiğin (42) altındadır: şablon rakipler ürün rev 7 hat modeline göre çok güçlüdür.
- "Kademeden" + half-sat 25 (oyuncunun kendi eğrisi; "aynı kural") MVP'yi eşiğin iki yanına koyar ve en okunur davranıştır; ama 26. haftadan sonra B2C'yi bugünden belirgin **kolaylaştırır** (`quality_term` ≈ 66–69). Half-sat 7 bugünkü zorluğu korur. K3 kapısının 40 ya da 52 olması bu tabloyu en çok 1 puan oynatır.
- `RIVAL_TEMPLATE_HALF_SAT` tek sabittir ve tek oyun okuyucusu Satış'ın `_rival_relative_quality`'sidir [kod `quality_model.gd:31-36, 75-83`, `sales_system.gd:197`]; değeri değiştirmek kapalı modu, oynanabilir olmayan alt-türleri ve mevcut `b2c` fikstürlerini de oynatırdı. Bu yüzden karar 21'in değeri **yeni sabit** `QualityModel.RIVAL_TIER_HALF_SAT`'tır; `RIVAL_TEMPLATE_HALF_SAT` 50 kalır. `normalized_quality_rival(composite)` oyuncunun alt-türünde rakip dünyası açık ve karar 10 "kademeden" iken (`RivalSystem.uses_tier_axes(ProductState.subtype())`) `RIVAL_TIER_HALF_SAT`'ı, değilse 50'yi kullanır; çağrı yeri (Satış) değişmez. Kapalı mod böylece bugünkü B2C'nin aynısıdır; `rival_relative_uses_template_half_sat` değişmeden yeşil kalır; açık mod için `rival_tier_half_sat` denetimi `rival_reload_equivalence` vakasına eklenir. Karar sahip kararı olduğu için ayrıca "onay bekliyor" raporlanmaz.
- **Ölçüm.** Bugünkü `b2c` probe preset'i bir fikstürdür (ai_assistant, sprint yok, 8 tohum aynı sonucu verir; 8/8 `running_on_fumes`) [ölçüm]; tam bir B2C bot politikası yoktur [kod `run_probe.gd:60-64`]. A1, bu fikstürün note_tool'a çevrilmiş kopyasıyla (`b2c_note_tool`) `--rivals=on/off` farkında MVP anı `quality_term`'ü (bant §13 madde 43'te; açık karar 10 ve 21'e bağlıdır) ve 26. hafta kitle farkını ölçer; B2C zafer oranı kıyası bot politikası gerektirdiği için A1-ek'tir.

### 10.6 Beklenti [hesap]
Tipik oyuncu, note_tool ve erp, 12/26/52/78. haftalar:
- **Eski kural** (her rakip çıkışı +0,5, birikimli): oyuncu her rakibi kademede geçtiği hâlde note_tool core, onboarding, trust (26 ve 52. hafta), growth (52) ve erp core, integrations, trust "Zayıf" okunur. Traction'da beklenti 2 + 1 = 3 olduğunda Güçlü imkânsızdır (eşik 4 > tavan 3).
- **Yeni kural** (yalnız `overtook`, 6 rakip sprinti penceresi, Güçlü eşiği tavana kırpılır, MVP öncesi inişler sayılmaz): yanlış "Zayıf" kalkar; yalnız gerçek öne geçişler işaretlenir (K3 kapısı 40 iken note_tool'da Niş'in güven K3'leri 42 ve 48. hafta; 52 iken bunlar 52'den sonraya kayar). 78. haftada K3'e çıkmış oyuncu Güçlü okur.
- Katı Kopyacı kuralı olmadan Kopyacı oyuncunun çıkarmadığı bir hatta öne geçebiliyordu (note_tool editör K2, 8. hafta → core 12. haftada "Zayıf"); katı kural bunu kapatır.

### 10.7 %70 hedefi: kanallar ve kapı
**Taban [ölçüm]** (B2B, erp, `full_run` dünyası, 8 tohum, 104 hafta):
- `full_run_vc_cautious` (Series A masasına oturan bot) 6/8 `series_a_close` (%75); imza 76–87. haftalarda. **"Yetkin koşu" bu belgede bu preset'tir.**
- `full_run` 0/8: Series A masasına hiç oturmadığı için `profitable_bootstrap` yapısal olarak kapalıdır (`faced_series_a` yazılmaz); MRR 103. haftada 149–213 bin, 12 ay kâr. Kapının dışındadır.
- Kurucu görüşmeleri 2.912, kazanılan 2.462 (%84,5); haftalık 4 görüşme tavanı her hafta bağlı; kapanışların %93'ü kurucunun; MVP 13. haftada; koşu başına ortalama 35,6 istifa, ilki 47–49. haftada.
- B2C tabanı ölçülemedi (preset fikstür, §10.5).

| Kanal (A1) | Mekanizma | Sınır | Kaynak |
|---|---|---|---|
| Çekişme | Kurucu görüşmesine −0,12…−0,30 | Tanışma süresiyle ilerleyen oyuncuda ≈0; duran oyuncuda görüşmelerin %75–100'ü; bot kapanışlarının %93'ü kurucu olduğundan bot etkiyi tam görür | [hesap] + [ölçüm] |
| Çelme | Çeyrekte en çok 1 deneme, 26. haftadan | 104 haftada ≤ 7 deneme (epoch 0–1 ile 28, 40, 52, 64, 76, 88, 100. haftalar); karşı teklifle ≈ %60 tutmada ≤ 3 ek ayrılış (tabandaki 35,6'ya karşı); her ayrılış ekibe −5 moral | [çıkarım] |
| B2C kıyası | Rakip eksenleri | Half-sat 25'te B2C kolaylaşır (zafer oranını artırır) | [hesap] |
| Kopya, beklenti | Görüntü ve öneri sırası | Doğrudan ekonomik etki yok | [kod] |
| Fiyat | Çekişme teriminde 6 | Yalnız fiyata duyarlı arketip ve Lider kırdıktan sonra | [çıkarım] |
| VC, sonlar | — | A1'de yok | [kod] |

**Tahmin [çıkarım]:** A1, B2B zafer oranını tabandan en çok birkaç puan düşürür; B2C'yi half-sat 25 seçilirse yükseltir. %70 hedefi tehlikede değildir; asıl risk B2C'nin kolaylaşmasıdır.

**Kapı (§13 madde 44).** `full_run_vc_cautious` × 8 tohum, `--rivals=on` ve `off`: zafer oranı farkı (açık − kapalı) ≥ −1/8 (≈ −5 puan) ve kurucu görüşme kazanma oranı farkı ≥ −5 puan. Tutmazsa ölçüm "onay bekliyor" diye raporlanır, `contest.points` önerisi (12/20) ve tanışma süresi yönetmene geri gelir; ajan sabiti kendiliğinden değiştirmez.

### 10.8 "Kararı geçersiz kılmama" kuralı (biçimsel)
Oyuncu bir hatta kademe `T` çıkardığında, o andan sonra hiçbir rakip hamlesi:
1. Kopyacı için o hatta `T − 1`'i aşamaz; Kopyacı'nın o alandaki seviyesi oyuncununkinin 0,5 altında kalır; iniş tikinde yeniden denetlenir (§5.4);
2. oyuncunun o alandaki durum kelimesini bir kopya hamlesiyle düşüremez (kopya `overtook` olamaz, §8.2);
3. oyuncunun ilk çıkan olduğu hatta en az 3 rakip sprinti (≥ 6 hafta) boyunca kopyalanmaz;
4. imzalı sözleşmeyi, verilmiş fiyatı, işe alınmış kişiyi kart olmadan geri almaz.
Oyuncunun avantajı görünür kalır: Rakipler görünümünde alan şeridi ▼ ve "Hazırlanıyor: … ~6 hafta".

### 10.9 Lastik yasağı
Hiçbir kural oyuncunun kasasına, MRR'ına, lig sırasına ya da kademe hızına göre rakip temposunu, olasılığını ya da gücünü ayarlamaz (`_tempo_due`, `_roll`, `_pick_line`, `_k3_open`; §13 madde 6). Takvim haftası serbesttir. Oyuncu durumunu okuyan kurallar adlıdır (§3.10): A1'de üç (Kopyacı tavanı, çelme hedef süzgeci, faz aralık çarpanı), A2'de üç olay kapısı (`entry`, `acquisition_offer`, `funding_round`).

### 10.10 Zorluk [A2]
`rules.json difficulty.<easy|normal|hard>`: tempo aralığı çarpanı (1,25 / 1,0 / 0,8), çekişme puan çarpanı (0,5 / 1,0 / 1,25), çelme başlangıç haftası (39 / 26 / 13), tanışma süresi (16 / 12 / 6) [ÇD]. ch01 §6'nın "rakip saldırganlığı" değiştiricisi budur. Oyunda zorluk seçici yoktur; zorluğun demo/EA yerleşimi ACIK_KARARLAR'daki "GDD'ler arası iki çelişki" maddesine bağlıdır. A1 zorluk okumaz.

### 10.11 Hesap varsayımları
Oyuncu profilleri: yavaş (1 kişi, 26. haftadan 2), tipik (2, 26'dan 3), hızlı (3, 13'ten 5); kapasitenin tamamı kademe kartına gider (düzeltme, araştırma, talep, cila yok) → oyuncu hızı **iyimser** okunur, gerçek rakip baskısı biraz daha yüksektir [çıkarım]. Faz takvimi: Bootstrap 0–25, Traction 26–51, Series A 52+. Rakip hamlelerinde hash yerine katalog sırası. Tablolar K3 kapısı 40 ile hesaplandı; 52'de rakip K3'leri 52. haftadan önce yoktur ve B2C tablosu en çok 1 puan değişir. Uygulama görevi ölçümü §13 maddeleriyle tekrarlar.

---

## 11. İçerik ihtiyaç listesi

Hepsi `localization/strings.csv` anahtarı (ya da kart `text` bloğu) olarak doğar (BILINGUAL BIRTH LAW), önce İngilizce yazılır, Türkçe ayrı yerelleştirme adımıdır; ajan taslağıdır, **TR/EN onay bekler**. Eksik içerikte kod çökmez, anahtar yerine `TODO content` basılır (rev 7 kalıbı).

| İçerik | Adet | Anahtar kalıbı | Not | Art. |
|---|---|---|---|---|
| Rakip adları | Oynanabilir 3 alt-tür × 8 slot | `field.json names` (özel ad, çevrilmez) | Ek A setleri: video_clip ve erp tarandı ve temiz; note_tool ön koşul P1; tek ad kuralı (açık karar 19) | A1 |
| Diğer 10 alt-türün adları | — | `field.json names` | A1'de olduğu gibi taşınır (ekrana çıkmazlar); Ek A.3 temizliği o alt-türü oynanabilir yapan görevde | — |
| Arketip adı + tek cümle | 3 × 2 (A1), +1 × 2 (A2) | `RIVAL_ARCH_<ID>`, `RIVAL_ARCH_<ID>_DESC` | Aşağıdaki taslak; tek cümle davranışı gözlemler, zayıflık yazmaz (§5.1 "Zayıflık" sütunu oyuncu metni değildir) | A1 |
| Segment adları (B2B) | 3 | `RIVAL_SEGMENT_TECH_EXACTING` "Eager" · "Hevesli"; `RIVAL_SEGMENT_FINANCE_BRISK` "Bargain hunters" · "Fiyat avcısı"; `RIVAL_SEGMENT_OPS_CAUTIOUS` "Bureaucratic" · "Bürokratik" | Oyuncuya ilk kez burada görünür; yazım "Fiyat avcısı" olarak tekleşir; hover `RIVALS_SEGMENT_HOVER` "Sectors: {sectors}" · "Sektörler: {sectors}"; B2C'de segment gösterilmez; `default` için ad yok | A1 |
| Fiyat duruşu | 0 yeni | Mevcut `SALES_STANCE_CAPTION`, `SALES_STANCE_COMPETITIVE/STANDARD/PREMIUM` | Oyuncunun kadranıyla aynı sözcükler | A1 |
| Manşet kökleri (A1) | `ROADMAP` 4 · `COPY` 3 · `PRICE_CUT` 3 · `PRICE_RECOVER` 2 · `POACH_TELEGRAPH` 2 · `CAPTURE` 3 | `RIVAL_NEWS_<KÖK>_<n>` | §4.6 tablosu; ek almayan kalıp (§7.2), tire yok | A1 |
| Sebep kökleri (A1) | `TEMPO_LEADER` 2 · `TEMPO_COPIER` 2 · `TEMPO_NICHE` 2 · `COPY` 3 · `PRICE` 2 · `RECOVER` 2 · `POACH` 2 · `CAPTURE` 2 | `RIVAL_WHY_<KÖK>_<n>` | Parantez içine girer | A1 |
| Ürün sesi (planlıyor) | 2 | `PRODUCT_RIVAL_VOICE_PLAN_<n>` | §8.2 | A1 |
| Rakipler görünümü UI | ≈ 30 (her "~{n} hafta" için `_ONE` tekili dahil; `RIVALS_CAPTURE`, `RIVALS_MEMORY`, `RIVALS_CONTEST_AREA/PRICE/BOTH`) + `PRODUCT_VIEW_RIVALS` | `RIVALS_*` | §8.3 taslakları | A1 |
| Görüşme etiketleri | 3 | `SALES_MOD_RIVAL`, `SALES_MOD_RIVAL_PRICE`, `SALES_MOD_RIVAL_BOTH` | `{rival}` argümanı | A1 |
| Etki çipi | 1 | `EFFECT_SALARY` | §8.7 | A1 |
| Çelme kartı | 1 kart (`RIVAL_EV_POACH_TITLE` başlık, gövde, 3 seçenek) | kart JSON `text.en/tr` | §8.7 | A1 |
| Silinen anahtarlar | 2 | `PRODUCT_NEWS_RIVAL_LAUNCH_0/1` | `tick_rivals` ile | A1 |
| Sözlük | — | `docs/design/localization_glossary.md` | "rakip ↔ rival · lig ↔ league (startup sıralaması; Satış'ın 'kendi ligi ↔ own league' bant anlamından ayrı anahtar ailesi) · çekişme ↔ contest · çelme ↔ poach · Yerleşik / Kopyacı / Niş / Parayı Bulan ↔ Incumbent / Copycat / Niche / Funded · Hevesli / Fiyat avcısı / Bürokratik ↔ Eager / Bargain hunters / Bureaucratic · Hafıza ↔ Memory · Hazırlanıyor ↔ Preparing · Son hamle ↔ Last move"; "lider" ve "puan" rakip yüzeyinde kullanılmaz (sözlükte başka anlamları var: `lider ↔ lead`, `puan ↔ points`) | A1 |
| Manşet + sebep (A2) | `ENTRY` 2 · `FUNDING` 3 · `PRESS` 3 · `CHURN_TO_RIVAL` 2 · `PLAYER_POACH` 2; sebep `TEMPO_FUNDED` 2 · `ENTRY` 2 · `FUNDING` 2 · `PRESS` 2 · `POACHBACK` 2 · `CHURN_TO_RIVAL` 2 · `ACQUIRE` 2 · `PLAYER_POACH` 2 | `RIVAL_NEWS_*`, `RIVAL_WHY_*` | Sebep taslakları aşağıda | A2 |
| Olay kartları (A2) | `rival.player_poach`, `rival.poach_back`, `rival.acquisition_offer` | kart JSON | | A2 |
| Görüşme karşılaştırma satırları (A2) | Arketip başına 3 | `SALES_RIVAL_LINE_<ARCH>_<n>` | Satış'ın satır seçicisi rakip olgusunu göremez [kod `sales_probes.gd:9-11`]; açık karar 24 ("kart": görüşme öncesi olay kartında) | A2 |
| Mentor satırları (A2) | 6 taslak (§8.6) | `MENTOR_RIVAL_*` | Frank'in külliyatı: yalnız taslak, Erdem onayı şart | A2 |
| Bitiş gazetesi (A2) | 2 satır | `END_RIVAL_RANK`, `END_RIVAL_MOST` | §8.8 | A2 |
| Manşet + sebep (A3) | `DEATH` 2 · `FADING` 2 · `PARTNER` 2 · `MINDGAME` 2 · `COMMENT` 3; sebep `DEATH` 2 · `PARTNER` 2 · `MINDGAME` 2 · `COMMENT` 2 · `NICHE` 2 · `GRUDGE` 2; rezerve `WAVE` 2 · `WAVE_<ARCH>` 2 | `RIVAL_NEWS_*`, `RIVAL_WHY_*` | Sebep taslakları aşağıda | A3 |
| Olay kartları (A3) | `rival.partnership`, `rival.press_reply` | kart JSON | | A3 |
| Yedek ad listesi (A3) | Oynanabilir alt-tür başına 2 | `field.json living.<alt-tür>.reserve_names` | Ek A yöntemiyle taranır | A3 |

**Arketip adları ve tek cümleler (EN · TR taslak).**
- `RIVAL_ARCH_LEADER` "INCUMBENT" · "YERLEŞİK" · açıklama `_DESC` "Fills its own gaps, one area at a time." · "Kendi eksik alanlarını sırayla tamamlar."
- `RIVAL_ARCH_COPIER` "COPYCAT" · "KOPYACI" · açıklama `_DESC` "Ships what you ship, one tier behind." · "Senin çıkardığını bir kademe geriden çıkarır."
- `RIVAL_ARCH_NICHE` "NICHE" · "NİŞ" · açıklama `_DESC` "Goes deep in one area." · "Tek bir alanda derinleşir."
- `RIVAL_ARCH_FUNDED` (A2) "FUNDED" · "PARAYI BULAN" · açıklama `_DESC` "Has the money to ship fast." · "Hızlı çıkarmaya yetecek parası var."

**A2/A3 sebep taslakları (EN · TR, `_0` varyantları).** `ENTRY` "the market is growing" · "pazar büyüyor"; `FUNDING` "to hire faster" · "daha hızlı işe almak için"; `TEMPO_FUNDED` "spending the money it raised" · "aldığı parayı harcıyor"; `PRESS` "after your round" · "senin turunun ardından"; `POACHBACK` "you hired from its team" · "onun ekibinden birini aldın"; `PLAYER_POACH` "your offer was higher" · "senin teklifin daha yüksekti"; `CHURN_TO_RIVAL` "it is ahead in {area}" · "{area} alanında önde"; `ACQUIRE` "it wants your customers" · "senin müşterilerini istiyor"; `DEATH` "no new release in {n} quarters" · "{n} çeyrektir yeni sürüm yok"; `PARTNER` "it leads in {area}" · "{area} alanında önde"; `MINDGAME` "it lost {n} accounts to you" · "sana {n} hesap kaptırdı"; `COMMENT` "answering {rival}" · "{rival} hamlesine yanıt"; `NICHE` "wants its area back" · "kendi alanını geri istiyor"; `GRUDGE` "it remembers the lost accounts" · "kaybettiği hesapları unutmadı"; `WAVE_<ARCH>` "a new technology wave opened" · "yeni bir teknoloji dalgası açıldı".

**Örnek kalıplar (EN · TR):** §8.1 haber tablosu, §8.3 görünüm öğeleri, §8.4 görüşme etiketleri, §8.7 kart metinleri, §7 sebep şablonları.

---

## 12. Kayıt şeması etkisi ve taşıma

**Şema 15 → 16.** `SaveManager.SCHEMA_VERSION = 16`; `MIN_LOADABLE_VERSION` 10 kalır (yorumu güncellenir). Zincire `if version < 16: _migrate_16(state)` eklenir [kod `save_manager.gd:139-147`].

**`_migrate_16(state)`** (saf, ucuz; canlı veri ve JSON okumaz, çünkü `read_slot` her listelemede koşar):
1. `gs = state.game_state`; `hits = gs.product.get("rival_hits", [])`.
2. Dondurulmuş sabit `_V15_RIVAL_SLOTS = {"note_tool": [3,4,6], "video_clip": [3,5,6], "erp": [3,5,6]}` (v15 `rivals.json`'ın `rivals` dizileri). Alt-tür kaydın kendi `mvp_sub_product_type_id` bayrağından.
3. Her isabet `{rival: i, line, sprint}` → `{rival_id: "rv_<sub>_<slots[i]>", line, player_sprint: sprint}`; tam şema yazılır: `gs.rival_world = {"engine": {"epoch_day": -1, "seq": 0, "inbox": [], "poach_pending": {}, "poach_seen": [], "poach_quarter": -1, "headlines": [], "legacy_hits": [...]}, "push": {}}` (karar 11 "birikimli" ise `"bumps": {}` de yazılır).
4. `gs.product.erase("rival_hits")` (ürün sözlüğü birleştirilerek yüklendiği için silinmezse kalır [kod `save_codec.gd:197-215`]).
5. `registries.rivals` satırlarına dokunulmaz.

**Yükleme sırası.** `SaveManager.apply_loaded_state`: `_restore_systems` (Ar-Ge çalışma zamanı hatları ve ürün durumu hazır) → `RivalRegistry.fill_world()` → `RivalSystem.on_loaded()` → saat bırakılır [kod `save_manager.gd:221-238`].

**`RivalRegistry.fill_world()`** (yalnız Rival kayıtlarını yazar):
1. Her rakibin `product_name`'ini `field.json`'dan yazar (marka düzeltmesi eski kayda ulaşır; A3'te `name_index`'e göre).
2. `world_state == ""` olan her kayıt için `field.json living` tohumundan `world_state` ve `line_tiers`'ı (`tiers` sütunu) yazar; `price_posture` = her segment (B2B `SalesArchetypes.ids()`, B2C `audience`) için `base_posture`; `line_since` ve `posture_since` 0. `reset()` bu adımı paylaşır.
3. v16 kayıtta (nöbetçi dolu) hiçbir şeyi değiştirmez.

**`RivalSystem.on_loaded()`** (yalnız `rival_world` ve RivalRegistry seam'leri):
1. `_ensure_state()` eksik anahtarları varsayılanla doldurur.
2. `legacy_hits`'i uygular: her isabet `RivalRegistry.apply_legacy_hit(rival_id, line, player_sprint, seq)` ile (`seq` her isabet için `engine.seq`'ten yeni alınır; tavandaki hatta isabet atlanır; `rival_moved` yayılmaz); karar 11 "birikimli" ise her isabet (tavanda atlananlar dahil) `engine.bumps[hattın alanı]`'nı +1 artırır (2'de durur; rev 7 göç edilen isabetleri zaten sayıyordu); sonra `legacy_hits` silinir.
3. **Yeniden tohumlama ölçütü:** rakip dünyası açık, oynanabilir bir alt-tür seçili ve `epoch_day < 0` (v15 kaydı, kapalı yapıda kaydedilmiş koşu ya da tip seçimi ile ilk 4b arasında kaydedilmiş koşu). O zaman inbox'tan `day < GameState.day` olan girdiler silinir (tip seçimi ile ilk 4b arasında bugün yazılmış girdiler kesintisiz koşudaki gibi ilk 4b'de işlenir); her `pending` girdisi `drop_move` ile çıkar (bayrak kalkar); her aktif rakip `reseed_clock(r)` alır; `engine.poach_quarter = -1` yazılır. `epoch_day` burada yazılmaz: saat bir sonraki 4b'de §6.1 adım 0(d) ile kurulur; kesintisiz koşu da saati o tikte kurar (`GameState.advance_day` günlük dağıtımdan önce koşar [kod `time_manager.gd:134-136`]). İlk tikte üç rakip birden hamle yapamaz.
4. Rakip dünyası kapalıysa `epoch_day = -1` yazılır, başka bir şey değişmez.
5. Push'u hesaplar.
6. v16 kayıtta (açık yapıda kaydedilmiş, `epoch_day ≥ 0`) adım 2–4 no-op'tur; `save_roundtrip_fingerprint` için yükle-kaydet bayt-eşittir.

**Diğer.**
- `GameState.rival_world` yeni değişken; `initialize_run`'da `clear()` [kod `game_state.gd:837-838` kalıbı]; taze koşuda şemayı `RivalSystem._ensure_state()` kurar.
- `SprintSystem.new_state` `rival_hits` içermez; `_migrate_15`'in ürettiği `rival_hits: []` 16. adımda silinir.
- `RivalRegistry.reset()` yeni alanları katalogdan tohumlar (`fill_world`'ün 2. adımını paylaşır; kod tekrarı yok).
- `RivalSystem` statik koşu durumu tutmaz (her şey Rival ve `GameState.rival_world`'de); `_capture_systems`'e girmez.
- Ölüm (A3) silme değildir; `reset()` silineni yeniden tohumlar [kod `rival_registry.gd:26-37`].
- A2/A3 alanları anlamlı varsayılanla eklenir; SaveCodec yeni @export alanı şema artışı olmadan kabul eder, eski kayıtta varsayılan alır [kod `save_codec.gd:62-78`]; doldurucu gerekiyorsa `fill_world`'e adım eklenir.
- Belgeler: CLAUDE.md §6 (şema 16; WRITE-THROUGH cümlesinden `rival_hits`), HARITA Kayıt bölümü, `GDD — ZAMAN MODELİ.md` §10 (bugün şema 14 der, bayat).

**Uç durumlar.** v10–v14 kayıt `_migrate_15` → `_migrate_16` zincirinden `rival_hits` yokken geçer; tip seçilmemiş v15 kaydı `epoch_day = -1` kalır; K3'teki hatta v15 isabeti tavanla kesilir ve alan kelimesi yüklemede değişebilir (beklenti kuralı değiştiği için kabul; §13 madde 36). v15 canlı koşuda tanışma süresi mevcut `mvp_launch_day` bayrağından okunur, yüklemede yeniden başlamaz.

---

## 13. Uygulama görevi için doğrulama listesi (A1)

"smoke" = çekirdek mantık vakası (CLAUDE.md §10), "kabul" = Godot MCP görsel kabulü (CLAUDE.md §11), "grep" = kaynak taraması, "probe" = `--run-log`. Vaka eşlemesi ve probe satır biçimi listenin sonunda.

**Saflık ve veri**
1. `data/product/rivals.json`, `SprintCatalog._rivals`, `RIVALS_PATH`, `SprintBridges.tick_rivals`, `product.rival_hits` yok; `grep -rn "rival_hits\|tick_rivals\|RIVALS_PATH" scripts data` yalnız `_migrate_16`'yı ve smoke'u bulur. (grep)
2. `RivalCatalog`'da `const TEMPLATE/NAMES/SHARE_SEED/MARKET_ACTORS/MARKET_TOTAL_MRR` yok; erişimciler `field.json`'dan okur; `market_share_tracks_mrr` ve `rnd_note_author_and_lines` erişimcilerle yeşil. (grep + smoke)
3. Rival alanlarını yalnız `RivalRegistry` yazar: `grep -rnE "\.(line_tiers|line_since|price_posture|posture_since|cooldowns|captures|pending|move_log|memory|world_state)((\[[^]]*\])|\.[a-z_]+)*\s*([-+*/]?=([^=]|$)|\.(append|erase|clear|push_back|merge|assign))" scripts --include=*.gd | grep -v rival_registry.gd` boş döner. (grep)
4. `GameState.rival_world`'e yazım yalnız `rival_system.gd`'de, `save_manager.gd _migrate_16`'da (ham kayıt sözlüğü) ve `game_state.gd`'nin tanımı ile `initialize_run` `clear()`'ında; `main.gd` fikstürleri ve smoke vakaları `RivalSystem.debug_set_push`/`debug_set_poach`/`debug_set_engine` ve `RivalRegistry.debug_set`'i çağırır. (grep)
5. `rival_system.gd`'de `randf`, `randi`, `RandomNumberGenerator`, `RngStreams`, `.hash()` yok. (grep)
6. Lastik yok: `_tempo_due`, `_roll`, `_pick_line`, `_k3_open` gövdelerinde `cash`, `mrr`, `get_player_rank`, `shipped_composite` yok. (grep)
7. `git diff --stat` İK sistemlerini, Finans sistem ve görünümlerini, VC dosyalarını ve Satış'ın iki onaylı dosyası dışındaki hiçbir Satış dosyasını göstermez; iki onaylı dosyadaki fark tek katkı + tek etiket + tek çip satırıdır. (diff)
8. `RivalCatalog.validate(field: Dictionary) -> Array[String]` saf fonksiyonu bozuk sözlüklerle (eksik hat, olmayan ev alanı, B2B'de `cap_paid_plan`, sözleşme alanı olmayan B2B ev alanı) hata listesi döndürür; yüklemede hata `push_error` olur; veri yoksa sistem boşta, Ürün çipleri boş, görünüm boş durumunu gösterir. (smoke)

**Saat ve motor**
9. Tip seçilmeden rakip hamlesi yok; `rs < clock.first_move_sprints` iken hamle (çelme dahil) yok; üç rakibin ilk tempo sprinti birbirinden farklı; debug `set_phase` ile faz geri alınınca aralık çarpanı fazdan türetilir. (smoke `rival_clock_caps`)
10. Oynanabilir olmayan alt-türde (`ai_vector_search`) `RivalSystem` `_ensure_state` şeması dışında hiçbir şey yazmaz, `epoch_day` −1 kalır; `news_feed_weights_and_no_repeat` ve `market_share_tracks_mrr` yeşil. (smoke `rival_clock_caps`)
10b. Kapalı mod (`--rivals=off`, 26 hafta): inbox boş, push `{}`, `epoch_day` −1, rakip haberi yok, B2C kıyası bugünküyle bayt-aynı; açık yapıda yüklenince ilk tikte toplu hamle yok ve eski `pending` kalmaz. (smoke `rival_clock_caps`)
11. Tempo: hiçbir rakibin ardışık iki tempo taahhüdü arasında etkin aralıktan az rakip sprinti yok; tavan ya da aday yokluğuyla yeniden başlayan saat `PROBE RIVAL_MOVE … result=dropped:<sebep>` satırında görünür; hiçbir hamle kademe atlamaz; K3, `k3.min_week`'ten ve K2'de `k3.k2_sprints`'ten önce yok; tipik oyuncunun medyan ilk K3 haftası (`full_run`) raporlanır. (probe)
12. Tavan: hiçbir rakip çeyreğinde alan genelinde inen hamle 6'yı, tempo 4'ü, tepki 2'yi, tür başına tepki 1'i aşmaz; rakip başına rakip sprintinde en çok 1 iniş (çelme hariç). (probe)
13. Telgraf: her `landed` ya da `void` inişin `pending`'de en az 1 tik önce görünen bir girdisi vardı; hiçbir `pending` girdisi inmeden silinmedi (istisnalar: `dropped:refused` çelmesi ve yeniden tohumlamada `drop_move`). (probe)
14. Determinizm: aynı tohumla iki koşu bayt-eşit `move_log` ve `headlines` üretir; N tik kesintisiz ile N/2'de kaydet-yükle aynı `move_log`, `pending`, `headlines` ve push'u verir; tip seçimi ile ilk 4b arasında kaydet-yükle de aynı epoch'u verir. (smoke `rival_reload_equivalence`)
14b. Rakip dünyası açık, karar 10 "kademeden", oynanabilir alt-tür: `normalized_quality_rival` `RIVAL_TIER_HALF_SAT`'ı; kapalı modda ya da oynanabilir olmayan alt-türde 50'yi kullanır. (smoke `rival_reload_equivalence`)
15. `--lang=tr` ve `--lang=en` koşuları aynı hamleleri üretir (hash anahtarında metin yok). (probe)

**Tepkiler**
16. Oyuncu canlı üründe K2 çıkarınca Kopyacı'nın aynı hatta `pending` `copy_tier`'ı aynı tikin 4b'sinde doğar, ≥ 6 hafta sonra iner, kademesi oyuncu − 1'i geçmez; aynı hatta bekleyen kopyası varken tempo o hattı seçmez, bekleyen kademe hamlesi varken kopya tetiklenmez; oyuncunun çıkışından sonra taahhüt edilen hiçbir Kopyacı hamlesi o hatta çıkıştan 3 rakip sprintinden önce inmez (`follow:<hat>`). (smoke `rival_copy_rules`)
17. Oyuncu K1 çıkarınca ya da Kopyacı zaten oyuncu − 1'deyken kopya telgrafı yok, `copy:<hat>` kilidi ve yuva harcanmaz (`dropped:no_gap`). (smoke `rival_copy_rules`)
18. MVP sprintinin üç K1 hattı kopya tetiklemez (`live=false`). (smoke `rival_copy_rules`)
19. Kopya iniş tikinde ve sonrasında oyuncunun o alandaki durum kelimesi değişmez; Ar-Ge çalışma zamanı hattı oyuncunun alan seviyesini düşürdüğünde koşulu bozan Kopyacı inişi `void` olur. (smoke `rival_copy_rules`)
20. Lider'e atfedilen 2 kapma (aynı segment, 6 rakip sprinti) fiyat kırma taahhüdü üretir; `commit_move` sayacı siler; 1 rakip sprinti sonra iner; 8 rakip sprinti boyunca ikinci kırma yok; sonra Lider'in ilk uygun tempo tikinde tabana doğru bir basamak döner; aynı çeyrekte iki yön yok. (smoke `rival_price_cycle`)
21. Kapma atfı yalnız rakibin o alandaki seviyesi oyuncununkinden düşük değilse yapılır; aday yoksa atıf yok; sektörü hiçbir arketipte olmayan müşteri segmentsizdir, fiyat sayacına girmez; `churn_customer` fiiliyle giden müşteri kapmayı geri almaz. (smoke `rival_price_cycle`)

**Satış**
22. Görüşme açılışında rakip önde ise hover listesinde "▼ {rival} …" satırı, rakip adı doğru; görüşme kaybında kapanış görünümünde de ad basılır. (kabul `--meeting-shot=rival` + smoke `rival_contest_points`)
23. Çekişme puanları: dilim 1 → `points[0]`, 2 → `points[1]`; fiyat bileşeni yalnız fiyata duyarlı arketipte, rakip daha ucuz ve en az denkken; toplam `cap_points`'i geçmez; `mvp_launch_day + grace_weeks`'ten önce ve `mvp_launch_day` yokken terim yok; en iyi rakipte eşitlikte sabit rakip sırası, hafta hafta ad değişmez. (smoke `rival_contest_points`)
24. 2. sorudan itibaren "Teklife geç" çip listesinde `MEETING_CHIP_PREP` kategorisinde rakip çipi; 1★ görüşmede yalnız hover; `--meeting-shot=rival` 6 terimli fikstürde rakip satırı 4 satır tavanında görünür. (kabul)
25. Kadran değişince (`price_stance_changed`) push aynı anda yenilenir; temsilci kapanışı çekişmeden etkilenmez; Satış smoke paketi yeşil. (smoke)

**Çelme**
26. Hedef kümesi: kurucu, izindeki, eğitimdeki, bekleyen ayrılışı olan, moral < 35 ya da ≥ 50, ★ < 3, kıdemi < 4 hafta olan ve `poach_seen`'deki seçilmez; küme boşsa deneme yok ve yuva harcanmaz. (smoke `rival_poach_lifecycle`)
27. Telgraf haber satırı karttan 1 tik önce; `EventGate.request` false dönerse telgraf satırı dışında iz kalmaz, tepki yuvası `drop_move` ile iade edilir, çeyreğin çelme hakkı harcanır (aynı çeyrekte ikinci telgraf yok). (smoke `rival_poach_lifecycle`)
28. `change_salary {pct:15}` maaşı `int(round(salary × 1,15))` yapar; `EFFECT_SALARY` çipi zar dışı kullanımda modalda "Maaş %15 · {who}" basar; `_is_negative` `pct`'in işaretini okur; `event_chip_coverage` yeşil. (smoke `event_change_salary_verb`)
29. Seçenek metinleri yüzdeyi tamsayı basar ("%62"), "0.62" değil; oranlar kart masadayken değişmez. (kabul: `--rivals-shot=poach_card` fikstürü `RivalSystem.debug_set_poach` ile `poach_pending`'i `odds {counter: 0,62, talk: 0,41}` ile kurar ve kartı aynı koşuda açar; sıra: `_seed_run_reproducible()` (`initialize_run` `rival_world`'ü temizler), tohumlanmış koşudaki bir çalışan için `debug_set_poach`, sonra `EventGate.render("rival.poach_offer", {"employee": id, "rival": rid})`; `_run_event_shot` doğrudan çağrılmaz; `main.gd` yalnız ilk eşleşen shot bayrağını koştuğu için iki bayrak birlikte verilmez; seçenek metni "%62" / "%41" basar)
30. Kart çözülünce seçenekle ayrılış "rakibe geçti" (`memory.out.poached`), kalış, `choice == −1` ve zaman aşımı `poach_failed` sayılır; tek `move_log` girdisi vardır ve `close_poach` onun `outcome`'ını yazar; telgraf ile iniş arasında hedef ayrıldıysa iniş `void`, yuva harcanmış, ek haber yok; kart metnindeki yüzde = `change_salary.pct`. (smoke `rival_poach_lifecycle`)

**Ürün ve haber**
31. Çip, bayrak, n/m, Ses, `rival_gap` yeni kaynaktan rev 7 görünüm sözleşmesiyle aynı biçimde gelir; `product_fixtures.gd` ve `--product-shot=c1..c5` yeşil. (kabul)
32. Bayrak yalnız bu ve sonraki sprint sütununda; ÇEYREK'in 3.–6. sütunlarında rakip bayrağı yok; otomatik başlayan (3 tiklik) sprintte bayrak doğru sütunda. (kabul)
33. Karar 11 "pencereli" ise beklenti yalnız `overtook` inen `roadmap_tier`'larla ve son 6 rakip sprintiyle artar; "birikimli" ise koşu boyu her inen `roadmap_tier` +0,5. İkisinde de en çok +1, kopya ve MVP öncesi inişler sayılmaz, MVP tikinde hiçbir alanın beklentisi faz değerini aşmaz, Gelir artış almaz, alan tavandaysa Güçlü erişilebilir. (smoke `rival_expectation_window`)
34. Her rakip olayı `max_age_ticks` içinde basılır ya da düşer; düşen olay sayısı `PROBE RIVAL_NEWS dropped=` satırında; haftalık satır sayısı 3–5 ve biz payı ≤ %20 korunur; bir hamle iki satır basmaz. (probe)
35. Ar-Ge notu yalnız aktif rakip adlarını kullanır. (smoke `rnd_note_author_and_lines` güncellenir)

**Kayıt**
36. v15 kaydı (rakip isabetli) yüklenir: isabetler doğru id'lere kademe olarak işlenir, `product.rival_hits` silinir, ilk tikte patlama yok. (smoke `save_v15_rival_hits_migrate`)
37. v16 kaydet-yükle-kaydet bayt-eşit (`save_roundtrip_fingerprint` genişletilir: tipli ürün + inmiş hamle + inbox girdisi + açık `poach_pending` + `headlines`). (smoke)
38. `save_double_load_no_residue`: iki yükleme arasında `rival_world` artığı yok. (smoke)

**Görünüm**
39. Rakipler görünümü 5 startup satırı gösterir; lig toplamı satır sayısı + 1; MVP öncesi lig gizli; boş durumlar (`--rivals-shot=no_type|not_playable|backup_only`) çökmez. (kabul)
40. 5 saniye testi soruları ekranda cevaplanır; 1920×1080 ve 1600×900'de taşma yok; TR ve EN; uzun ad kırpılır, hover tam ad; puan basılmaz. (kabul)
41. Sahnede ve scriptte oyuncu literal'i yok; tüm yeni anahtarlar TR+EN; `loc_residue` ve `loc_csv_integrity` yeşil. (gate)
42. Satır içi override yok; yalnız §8.3'te sayılan variation'lar; `--theme-audit` farksız ya da fark raporlanmış. (kabul)

**Kalibrasyon kapısı**
43. B2C: `b2c_note_tool` fikstür preset'i × 8 tohum, `--rivals=on/off`: karar 10 "kademeden" ve karar 21 = 25 ise MVP anı `quality_term` 35–50; karar 21 = 7 ise 10–20; karar 10 "şablondan" ise bant yoktur, değer raporlanır; kapalı kol B2C ekonomisi bakımından bugünkü oyundur; 26. hafta kitle farkı raporlanır. (probe; kesme çizgisi arkası)
44. B2B: `full_run_vc_cautious` × 8 tohum, `--rivals=on/off`: zafer oranı farkı ≥ −1/8, kurucu görüşme kazanma oranı farkı ≥ −5 puan; MVP haftası, 26/52. hafta MRR, istifa + çelme ayrılışları raporlanır. Tutmazsa "onay bekliyor" (§10.7). (probe)

**Belgeler ve adlar**
45. CLAUDE.md §6 (şema 16, WRITE-THROUGH), HARITA (Dünya ve Ürün satırları, `--rivals`, `--rivals-shot`, `--meeting-shot=rival`, `rival_*` smoke öneki), `EVENT_SIGNAL_MANIFEST.md` (yeniden üretildi; yeni sinyaller `# --- Rival signals ---` altında), `_vocabulary.md` (`--event-vocab`), `ACIK_KARARLAR.md` madde 14 (`change_salary` uygulandı) güncel. (grep)
46. `field.json names` içindeki her oynanabilir alt-tür adı Ek A'da kanıtıyla "temiz" hükmüyle listelidir; doğrulanmamış, "çakışma" ya da "çağrışım" hükümlü ad yoktur. (grep)

**Vaka eşlemesi** (ajan numarası §14): `rival_field_validation` (1; 8) · `rival_clock_caps` (2; 9, 10, 10b) · `quality_half_sat_25` ve `rival_relative_uses_template_half_sat` değişmeden yeşil (2; karar 21, §10.5) · `rival_copy_rules` (2; 16–19) · `rival_price_cycle` (2; 20, 21) · `rival_reload_equivalence` (2; 14, 14b) · `rival_expectation_window` (3; 33) · `rnd_note_author_and_lines` güncellemesi (3; 35) · `market_share_tracks_mrr` güncellemesi (1; 2) · `rival_contest_points` (4; 22, 23, 25) · `rival_poach_lifecycle` (5; 26, 27, 30) · `event_change_salary_verb` (5; 28) · `save_v15_rival_hits_migrate`, `save_roundtrip_fingerprint`, `save_double_load_no_residue` (6; 36–38). Yeni smoke vakası çekirdek mantıktır (ekonomi, kayıt, olay motoru); UI yalnız görsel kabulle doğrulanır.

**Probe satırları** (7b; `run_probe.gd`): `PROBE RIVAL_MOVE day= rival= kind= seq= commit_day= land_day= budget= result=landed|void|dropped:<sebep>` (sebep ∈ `budget`, `no_line` (hiç aday yok), `k3_gate` (adayların tamamı yalnız K3 kapısıyla elendi), `shift`, `flip_lock`, `no_gap`, `refused`) ve `PROBE RIVAL_NEWS day= printed= dropped=`; madde 11–13, 15, 34 bu satırlardan okunur. `--rivals=on|off` probe ve smoke için de geçerlidir.

---

## 14. Alt-ajan bölünmesi (A1 uygulaması)

Rev 7 Faz B kalıbı: 12 saat duvar saati tavanı, 10. saatte kesme çizgisi; ortak arayüz 1. ajanda tanımlanır ve dondurulur.

| # | Ajan | İş | Dosyalar | Bağımlılık |
|---|---|---|---|---|
| 1 | **Model ve katalog** | Sabitleri silen commit onları okuyan üç yeri de `RivalCatalog.names(sub)`'a çevirir (`sprint_catalog.gd` `rival_name`, `rnd_system.gd` `_rival_name`, `endgame_smoke.gd` `_case_rnd_note_author_and_lines`; paylaşılan dosya protokolünde sahiplik istisnası). Rival alanları (§4.1), `RivalRegistry` seam'leri ve okuma API'si (§3.3), `field.json` + `rules.json` (sprint.json'dan taşınanlar dahil, A1 blokları) + `RivalCatalog.validate`, erişimciler, `SprintCatalog.area_level_for` ve `archetype_for_industry`, `GameState.rival_world` değişkeni, EventBus sinyalleri. **Dondurduğu arayüz:** Rival alan listesi; §3.3 seam imzaları; `rival_world` şeması (§4.5); `pending`/`move_log`/`headlines` girdi şemaları (§4.3, §8.1); `RivalsModel` sözleşmesi (§8.3); `rules.json` tam A1 şeması; sinyaller `rival_moved(rival_id: String, kind: String)`, `rival_world_changed()`; `RivalSystem` genel imzaları (`daily_tick`, `wire`, `on_loaded`, `uses_tier_axes`, `debug_set_push`, `debug_set_poach`, `debug_set_engine`); `RivalRegistry.debug_set` | `rival.gd`, `rival_registry.gd`, `rival_catalog.gd`, `data/rivals/*`, `game_state.gd`, `event_bus.gd`, `sprint_catalog.gd` (iki saf fonksiyon + `rival_name` okuması), `rnd_system.gd` ve `endgame_smoke.gd` (yalnız `NAMES` okumaları) | — |
| 2 | **Motor** | `RivalSystem`: `_ensure_state`, saat, inbox, tempo, kopya, fiyat, tavan, taahhüt, iniş, push, kapalı mod, `on_loaded()` gövdesi (§12), debug yazıcıları; `TimeManager` slot 4b + `_ready`'de `wire()`; `--rivals=on/off` (`main.gd`); karar 21'in `RIVAL_TIER_HALF_SAT` sabiti ve `normalized_quality_rival` dalı | `rival_system.gd`, `time_manager.gd`, `scripts/main/main.gd` (bayrak), `quality_model.gd` | 1 |
| 3 | **Ürün bağı** | `SprintCatalog` rakip fonksiyonlarının yeni kaynağa taşınması, beklentinin `push.expectation_bump`'tan okunması ve `word_for` kuralı, bayrak pencereleri, Ses "planlıyor", `ProductModel` (`ui.view` `rivals` değeri dahil), `area_panel`, `product_fixtures`, `rnd_system._rival_name` (aktif rakipler); `tick_rivals`, `rival_hits`, `rivals.json` ve sprint.json'daki rakip anahtarlarının (okuyanlarıyla aynı commit'te) silinmesi | `sprint_catalog.gd`, `sprint_system.gd`, `sprint_bridges.gd`, `sprint.json`, `product_model.gd`, `area_panel.gd`, `product_fixtures.gd`, `rnd_system.gd`, `data/product/rivals.json` (silinir) | 1 |
| 4 | **Satış, haber, seam, metin** | Satış tek dikiş (§8.4), NewsFeed "rakip" girişi ve imleci (§8.1), `seams_world.gd`'deki tüm yeni seam'ler (5'in çelme seam'leri dahil), **`strings.csv`'nin tek yazarı** | `sales_meeting_system.gd`, `sales_meeting_adapter.gd`, `news_feed_system.gd`, `seams_world.gd`, `strings.csv` | 1 |
| 5 | **Çelme** | `change_salary` fiili + çip, `rival.poach_offer` kartı, çelme değerlendirmesi ve yaşam döngüsü (`RivalSystem` içinde 2'nin bıraktığı `_poach_*` bölümü; 2'den sonra, sıralı) | `effects.gd`, `event_modal.gd`, `data/events/cards/rival/poach_offer.json`, `rival_system.gd` (yalnız `_poach_*`) | 1, 2 |
| 6 | **Kayıt ve belgeler** | Şema 16, `_migrate_16`, `fill_world` ve `reset()` tohumu (ortak 2. adım), `apply_loaded_state`'e `fill_world()` ve ardından `RivalSystem.on_loaded()` çağrısı (gövde 2. ajanın); CLAUDE.md, HARITA, manifest, vocab, ACIK_KARARLAR madde 14; `endgame_smoke.gd` match tablosu | `save_manager.gd`, `rival_registry.gd` (yalnız `fill_world` ve `reset()` tohumu; 1'den sonra), `endgame_smoke.gd` (match tablosu), belgeler | 1 |
| 7a | **Görünüm** | `RivalsModel` + `RivalsView` dondurulmuş sözleşmeye karşı `--rivals-shot` fikstürleriyle; `product_tab.gd` düğmesi (karar 7) | `rivals_view.gd`, `rivals_model.gd` (fikstür kısmı), `product_tab.gd`, `scripts/main/main.gd` (shot) | 1 (1–6 ile paralel) |
| 7b | **Bütünleştirme** | `RivalsModel.live()` canlı bağı, `--meeting-shot=rival`, `run_probe.gd` (`--rivals`, `PROBE RIVAL_*`, `b2c_note_tool`), görsel kabul (§13 22, 24, 29, 31, 32, 39–42), probe (11–13, 15, 34, 43, 44), done mesajı | `rivals_model.gd` (canlı kısım), `scripts/main/main.gd` (meeting-shot), `run_probe.gd` | 1–6, 7a |

**Paylaşılan dosya protokolü.**
- `strings.csv`: tek yazar 4. ajan; 3, 5 ve 7a kendi anahtar listesini (anahtar, en, tr) 4'e iletir; `PRODUCT_NEWS_RIVAL_LAUNCH_*` silme satırları da 4'ün commit'indedir.
- `seams_world.gd`: `_install_rival()` 4'ündür; 5'in çelme seam'lerini (ad, tür, GLOBAL, kaynak) 4 yazar.
- `endgame_smoke.gd`: her ajan yeni `_case_*` fonksiyonlarını dosyanın sonuna ekler; mevcut bir vakayı yalnız §13 vaka eşlemesindeki sahibi, yalnız o fonksiyonun gövdesinde değiştirir; match tablosu satırlarını 6. ajan tek commit'te ekler. İstisna: 1. ajan, sabitleri silen commit'te `_case_rnd_note_author_and_lines` içindeki `RivalCatalog.NAMES` okumasını `RivalCatalog.names(sub)`'a çevirir; gövdenin geri kalanı 3'ündür. Aynı istisna `sprint_catalog.gd` `rival_name` ve `rnd_system.gd` `_rival_name` içindeki `NAMES` okumaları için geçerlidir.
- `rules.json`: tam şema 1. ajanda dondurulur; 3 bu dosyaya yazmaz.
- `rival_system.gd`: 2'nin (`on_loaded` dahil); 5 yalnız `_poach_*` bölümünü 2 bittikten sonra yazar; 6 bu dosyaya yazmaz.
- `scripts/main/main.gd`: 2 (`--rivals`), 7a (`--rivals-shot`), 7b (`--meeting-shot=rival`) ayrı bayrak blokları; sıralı commit.

**Kesme çizgisi.** 10. saatte 1–6 bitmemişse A1-ek'e kalanlar: açılır panel, çekişmeli müşteri tipleri bloğu ve §13 madde 43. Madde 44 ve 7a'nın satır hâli kesilmez. 1–6 kesilmez; aşım olacaksa smoke kapsamı daralır, kapsam değil.

**Done mesajı biçimi** (rev 7 §9 kalıbı): silinen dosya ve sınıflar; yeni sistem/sahne/JSON listesi; `rules.json`'ın güncel çalışma değerleri; ajanın verdiği ve Erdem'in onaylaması gereken kararlar; tasarım ↔ kod çelişkileri; kesme çizgisi durumu; smoke, probe, kabul kareleri, bilinen sorunlar.

---

## 15. Yönetmenin karar vereceği açık kararlar

Her biri tek kelimeyle cevaplanır. ★ = A1'i bloklar: bu kararlar verilmeden uygulama başlamaz ve ★ satırlarının varsayılanı yoktur ("—"). ★ olmayan kararlarda **varsayılan**, karar gelmeden izlenecek yoldur: görev metninin çalışma değeri varsa o, yoksa öneri; bu kuraldan sapan varsayılanın gerekçesi yazılıdır.

| # | Soru | Cevap | Öneri | Varsayılan | Gerekçe ve etki |
|---|---|---|---|---|---|
| 1 ★ | Başlangıç rakip sayısı | 3 / 4 | 3 | — | A1 tavanı 3 rakibe göre (§10.3). "4" A1'i başlatmaz, PRD revizyonu ister (dördüncü aktif slotun alt-tür başına arketipi ve tohumu, tavan 8) |
| 2 | Traction'da giren rakip | evet / hayır | evet | evet | Industry Manager dersi; A2. Hayır → Parayı Bulan yalnız tohum |
| 3 | Oyuncu rakip satın alabilsin mi | sonra / hayır | sonra | sonra | Anlamlı son değilse para çukuru (MGT); bu PRD'de yok |
| 4 | Rakibe satılma bir son mu | evet / hayır | evet | hayır | Canlı `acquisition` sonunun anonim alıcısı adlı rakip olur, ACIK_KARARLAR D1 kapanır. Varsayılan bilinçli olarak öneriden sapar: ch01, ch13 ve ch14 "CUT" der (Ek B). A2 |
| 5 | Çelme iki yönlü mü | evet / sonra | sonra | sonra | "evet" = A2'de oyuncu çelmesi ve geri çelme, İK aday üreticisi (`HRCandidateGenerator`) + `CharacterRegistry.add` + Finans `hire` etiketi istisnasıyla birlikte verilmiş olur |
| 6 | Rakip fiyatı MRR büyümesini etkilesin mi | evet / hayır | hayır | hayır | A1'de fiyat yalnız çekişme terimine girer; "evet" B2C için ikinci Satış istisnası ister (A2) |
| 7 ★ | Rakipler görünümü | sekme / Satış / Ürün | Ürün | — | Dokunuş kümeleri §8.3; "Satış" ikinci Satış istisnası ister |
| 8 ★ | Marka seti | yerli / karışık | karışık | — | video_clip ve erp için Ek A iki seçeneği de temiz adlarla karşılar; note_tool ön koşul P1 ile taranır |
| 9 ★ | A1 demoda da açık mı | evet / hayır | evet | — | ch14 demoda en az bir rakip hamlesi ister; smoke ve probe demoya sabit. "hayır" → kartlar `ea`, probe ve smoke `--rivals=on` ile; demo rev 7'nin statik rakip çıkışlarını da kaybeder (Ürün'de rakip izi kalmaz, §6.1 kapalı mod) |
| 10 ★ | Canlı rakip eksen kaynağı | kademeden / şablondan | kademeden | — | Aynı ölçek (lig başlığı anlamlı), pasif büyüme yok. "şablondan" → lig başlığı gizli, karar 21 geçersiz |
| 11 ★ | Beklenti artışı | pencereli / birikimli | pencereli | — | "pencereli" yalnız `overtook`, 6 rakip sprinti; "birikimli" rev 7 kuralı (kopya ve MVP öncesi inişler hariç); birikimli kural yanlış "Zayıf" üretir ve Traction'da Güçlü'yü imkânsız kılar (§10.6) |
| 12 ★ | Çekişme büyüklüğü | 15-30 / 12-20 | 12-20 | — | 0,30 ilk cevap kaybını MVP sonrası 33 puana kadar çıkarır (§10.4) |
| 13 ★ | MVP sonrası tanışma süresi | 12hafta / yok | 12hafta | — | Tohum kademeleri taze MVP'yi geçtiği için "yok" → görüşmelerin %75'i ilk günden cezalı (§10.4) |
| 14 ★ | Rakip çeyreği | 12hafta / takvim | 12hafta | — | 6 rakip sprinti, ürün çeyreğiyle aynı; takvim çeyreği 13–14 tik, rakip sprintini böler. "takvim" A1'i başlatmaz, PRD revizyonu ister (`rs`/`rq` formülü) |
| 15 | A1 çeyrek tavanı | 6 / 3 | 6 | 6 | 6 görev değeri; 3 = ch10'un "ayda 1"i |
| 16 | A2 çeyrek tavanı (4 aktif) | 6 / 8 | 8 | 6 | 4 aktifte talep 6,5–7,2 (§10.3); varsayılan görev değeri |
| 17 | A2 VC koduna tek okuma | evet / hayır | evet | evet | VC karşılaştırılabilirleri görev teslimatıdır; aksi hâlde kurulamaz ve `_rival_ahead` hep true kalır |
| 18 | ch10 ayrılışları GUNCELLEMELER'e | evet / hayır | evet | hayır | Varsayılan bilinçli olarak öneriden sapar: GDD değişikliği sahip onayı ister (CLAUDE.md §2) |
| 19 ★ | Tek ad kuralı | tek / çift | tek | — | Rakip her yüzeyde aynı adla; `company_name = product_name`. "çift" A1'i başlatmaz, PRD revizyonu ister (`field.json`'a taranmış `company_names`) |
| 20 | Rakip temposu | görev / ikikat | görev | görev | Görev tempolarıyla rakip ilerleyen oyuncuyu geçmez; baskı MVP, ihmal ve K3 yarışında (§10.3). "ikikat" → tavanlar da yükselmeli |
| 21 ★ | Rakip yarı doygunluğu (karar 10 "kademeden" ise; yeni sabit `RIVAL_TIER_HALF_SAT`) | 25 / 7 | 25 | — | 25 = oyuncunun eğrisi, MVP'de `quality_term` ≈ 40–45 (eşik 42) ama 26. haftadan sonra B2C bugünden kolay; 7 = bugünkü B2C zorluğu (MVP ≈ 15, aşınma). Şablon sabiti (50) ve kapalı mod değişmez (§10.5) |
| 22 | Rakip K3 kapısı | 40 / 52 | 52 | 52 | 52 = tipik oyuncunun hesaplanan ilk K3 haftası; 40 rakibe 12 hafta önce K3 verir (§5.4) |
| 23 | ÇEYREK ileri sütun rakip bayrağı | kalksın / kalsın | kalksın | kalksın | Rev 7 bayrağı statik takvimden geliyordu; canlı rakip bir sprintten ileri telgraf vermez; "kalsın" tahmin gösterir ve yalan söyleyebilir |
| 24 | A2 görüşme karşılaştırma satırları | kart / istisna | kart | kart | Satış'ın satır seçicisi rakip olgusunu göremez; "kart" = görüşme öncesi olay kartı, "istisna" = ikinci Satış dikişi |
| 25 | Çakışan yayın ve pazar aktörü adları (Ekonomi Postası, TeknoGündem, Yalçın Teknoloji Holding) | değişsin / kalsın | değişsin | kalsın | A1'de değişmez; "değişsin" ön koşul P2'nin taradığı adlarla ayrı bir içerik görevinde, sözlük §6 ve bitiş gazetesi künyesiyle aynı commit'te (mühürlü TR metni onaysız değişmez). Varsayılan bilinçli olarak öneriden sapar; "kalsın" görevin "gerçek marka yok" kuralından yazılı bir sapmadır |

---

## 16. Teaching Mode

**Ürün modeli kopyasıyla rakip.** Ne: rakip, oyuncunun hat-kademe tablosunu, alan seviyesi fonksiyonunu ve beklenti tablosunu kullanır; eksenleri aynı `realized_dims` ile türetilir. Neden: "AI aynı kuralla oynamıyor" şikâyeti (Software Inc) imkânsızlaşır; oyuncunun ekranda gördüğü karşılaştırma (■■□ · ■□□) gerçektir. Godot kavramı: Resource alanı olarak `Dictionary` (`line_tiers`) ve saf statik fonksiyon (`area_level_for`). Alternatif: rakibe ayrı bir güç sayısı vermek; karşılaştırma uydurma olur ve iki ölçek her yeni sistemde çevrilmek zorunda kalır (bugünkü 31–82 / 12–43 uyuşmazlığı).

**Kural tablosu, simülasyon değil.** Ne: hamleler tetik → koşul → olasılık → telgraf → iniş satırlarından gelir; rakibin ekonomisi simüle edilmez. Neden: her hamlenin sebebi yazılabilir ve test edilebilir; ch10 "gizli simülasyon yok" ister. Godot kavramı: JSON tablo + statik `RefCounted` sistem + tik yuvası. Alternatif: rakip başına ajan simülasyonu; açıklanamayan sonuç üretir (Industry Manager'ın "sebepsiz batış"ı).

**Deterministik hash.** Ne: her zar `EvDice.unit(kind, day, id, key)`. Neden: aynı kayıt aynı hamleleri üretir; yükle-tekrar dene hile olmaz; smoke kararlı; telgraf geleceği önceden gösterebilir. Godot kavramı: `int64` FNV-1a, sürüm ve platformdan bağımsız (`String.hash()` değil). Alternatif: konumsal RNG akışı; yükleme sonrası çekiliş sırası değişince sonuç değişir.

**Soğuma ve orantı.** Ne: her tepkinin tetik başına tek ve tetikten küçük olması, aynı kuralın bir süre tekrar edememesi, çeyrek tavanı ve "telgraflanan hamle iner" sözü. Neden: Civ VI'nın "savrulan lider"i olmaz; oyuncu rakibi okuyabilir ve ona karşı plan yapabilir. Godot kavramı: kayıtlı `cooldowns` sözlüğü ve taahhüt kuyruğu (`pending`). Alternatif: her tikte yeniden karar; aynı hafta iki zıt hamle ve geri alınan bayraklar.

**Veriyle zorluk.** Ne: tempo, tavan, çekişme puanı, çelme oranları ve (A2'de) zorluk çarpanları `rules.json`'da. Neden: ch01 §6 zorluğu "rakip saldırganlığı" gibi değiştiricilerle tarif eder; playtest değeri kod değiştirmeden oynar (Capitalism Lab dersi). Godot kavramı: `FileAccess` + `JSON.parse_string`, yüklemede şema doğrulaması (`RivalCatalog.validate`). Alternatif: GDScript sabitleri; her ayar bir kod değişikliği ve review turu ister.

---

## 17. Kaynaklar

Görev metninin §8 listesi aynen taşındı; her bağlantı 2026-10-02'de açıldı. "Destek" sütunu, sayfanın bu PRD'deki iddiayı doğrulayıp doğrulamadığıdır.

| # | Kaynak | Bağlantı | Erişim | Destek |
|---|---|---|---|---|
| 1 | Game Dev Tycoon forumu, rakip isteği ve "sahte rekabet" | https://steamcommunity.com/app/239820/discussions/0/3048356136489099772 | açık | evet: oyun "yalnız" hissettiriyor, mevcut rakipler sahte rekabet |
| 2 | Mad Games Tycoon 2, rakiplerden fark hissedilmemesi | https://steamcommunity.com/app/1342330/discussions/0/3825289852121656306 | açık | kısmen: başlık çok oyunculu üzerine; insan rakip AI'dan pek farklı hissettirmiyor, etkileşim sabotaj ve ortak işe alım havuzu |
| 3 | Mad Games Tycoon, satın alınan stüdyoların para çukuru olması | https://steamcommunity.com/app/341000/discussions/0/1742227264200594628/ | açık | evet: aylık gider payı aşıyor; "al ve kapat" önerisi |
| 4 | Mad Games Tycoon 2, satın alma değer mi | https://steamcommunity.com/app/1342330/discussions/0/6292161380826636698 | açık | evet: erken oyunda değmez; yayıncı olarak kullanılırsa kârlı |
| 5 | Software Inc, AI'nin farklı kurallarla oynaması | https://steamcommunity.com/app/362620/discussions/0/6664812048263024906 | açık | evet: AI oyuncunun kurallarına uymuyor (devam ürünü spam'i); yine de rakip oyunu sıkıcılıktan kurtarıyor |
| 6 | Civilization VI ajandaları, övgü | https://www.gamerevolution.com/?p=12915 | yönlendirme (gamerevolution.com/originals/12915-…) | evet: her liderin önceliği ve onu kızdıran şey açık |
| 7 | Civilization VI ajandaları, savrulma şikâyeti | https://steamcommunity.com/app/289070/discussions/0/340412122420976068 | açık | kısmen: övgüden kınamaya hızlı dönüş; "yapay ve sığ" ifadesi 8 numarada |
| 8 | (aynı) | https://steamcommunity.com/app/289070/discussions/0/4755222397144913773 | açık | evet: ajandalar yapay ve sığ, sebepsiz öfke, zayıflayınca dostluk bitiyor |
| 9 | Nemesis sistemi, tasarım ilkeleri (Monolith) | https://gamesbeat.com/shadow-of-mordors-nemesis-system-draws-from-burnout-football-and-an-architecture-book/ | açık | evet: ekip oyuncunun önemseyeceği ve hatırlayacağı olayları listeledi |
| 10 | Nemesis sistemi, patent | https://blog.acer.com/en/discussion/3936/the-nemesis-system-a-brilliant-idea-trapped-by-patents | açık | kısmen: ABD patenti ve "genellikle başvurudan itibaren 20 yıl" doğrulanıyor; "2036" tarihi sayfada yok (**çıkarım**) |
| 11 | Offworld Trading Company, dolaylı çatışma ve doğrudan araçlar | https://www.shacknews.com/article/93533/offworld-trading-company-taking-stock-in-space | açık | evet: doğrudan çatışma geri planda, karaborsa sabotajı var, rakibin hisselerini toplayarak kazanılıyor |
| 12 | Capitalism Lab, rakip script parametreleri | https://www.capitalismlab.com/?p=473 | yönlendirme (capitalismlab.com/scripts/script-competitors/) | evet: rakip sayısı, genişleme ve fiyat agresifliği, teknoloji avansı, uzmanlık, dostça birleşme |
| 13 | Industry Manager incelemesi, sebepsiz batış ve giren yokluğu | https://rawg.io/games/industry-manager-future-technologies/reviews | açık | evet: AI ödeyemediği kredilerle hızla batıyor, 4–5 şirket, boşluğu dolduran yeni firma yok |
| 14 | Football Manager, transfer sızıntısı ve rakip kulüpler | https://www.fmscout.com/q-5358-Transfer-stories-leaked.html | açık | evet: teklif sızıyor, büyük kulüp araya giriyor |
| 15 | Football Manager 2015, rakip menajerle akıl oyunları | https://games.softpedia.com/blog/Football-Manager-2015-Diary-Rivalries-Promises-and-Transfers-466071.shtml | canlı sayfa 403; 2023-05-18 arşiv kopyası açıldı | evet (arşivden): akıl oyunları ve basın atışmaları sezonu daha gerçek kılıyor |
| 16 | Football Manager, alakasız basın gürültüsü | https://fmprojects.substack.com/p/the-most-annoying-aspect-of-football | açık | evet: alakasız basın soruları yıllardır sürükleyiciliği kırıyor |

**Eklenen kaynaklar** (ajanın açıp okuduğu):

| Ders | Kaynak | Bağlantı | İddia |
|---|---|---|---|
| AI aynı kuralla oynamalı | Soren Johnson, "Our Cheatin' Hearts", Designer Notes | https://www.designer-notes.com/game-developer-column-7-our-cheain-hearts/ | Gizli AI bonusları bilgisayarı kara kutuya çevirir ve şüphe doğurur |
| Okunur niyet | PC Gamer, Civilization 6 incelemesi | https://www.pcgamer.com/civilization-6-review/ | Ajandalar her liderin neyi sevip sevmediğini açıkça söyler, oyuncu plan yapabilir |
| Rakip çıkışı ve doğrudan araçlar | Rock Paper Shotgun, Offworld Trading Company incelemesi | https://www.rockpapershotgun.com/offworld-trading-company-review | Karaborsa rakibi doğrudan bozar; satın alma oyuncuyu da açıkta bırakır |
| Hamleyi önceden göstermek | PC Gamer, Into the Breach incelemesi | https://www.pcgamer.com/into-the-breach-review/ | Düşmanın neye, ne kadar ve hangi sırayla vuracağı görünür; az sayıdayken bile taktik adil kalır (bu PRD'nin telgraf ilkesi, §1 ders 10) |

**İç kaynaklar.** `GDDs/GDD v2 — 10 · Rivals & World.docx` §1–§8; `GDD v2 — 01` §3, §5, §6; `GDD v2 — 13` §1, §3; `GDD v2 — 14` §2, §4, §6; `GDD — SATIŞ MODÜLÜ (rev 6 · İNŞA SÜRÜMÜ).docx` §5.1, §16; `GDD — EKİP MODÜLÜ vson.docx` §6, §7, §17.3; `GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §3.1, §4.3, §9, §12, §27; `GDD — ZAMAN MODELİ.md`; `docs/tasks/PRD_URUN_REV7_SPRINT_DONGUSU.md` §2–§4; `docs/ACIK_ISLER/ACIK_KARARLAR.md` (D1, K16, madde 14, madde 96, seam envanteri); `docs/ACIK_ISLER/ISLER.md` (pazar payı merdiveni).

**Çıkarım etiketleri.** §1 tablosundaki "Bu PRD'deki kural" sütunu kaynakların söylediği değil, bu belgenin onlardan çıkardığı kuraldır. Kaynağın doğrudan desteklemediği tek iddia Nemesis patentinin bitiş yılıdır (10 numara).

---

## Ek A — Marka denetimi

**Yöntem.** Her ad için en az iki web araması ("<ad>" + pazar kelimeleri; Türkçe adlarda "<ad>" yazılım). Hüküm: **temiz** (ilgili yazılım ya da ünlü marka yok), **çağrışım** (bilinen bir teknoloji markasının yakın varyantı ya da karıştırılacak kadar bilinen bir marka), **çakışma** (aynı ya da önemsiz yazım farkıyla yaşayan bir yazılım, uygulama, teknoloji şirketi ya da ünlü marka).

**Sınır ve kural.** Bu oturumun web arama bütçesi (200 arama) tarama sırasında doldu; note_tool'un yeni adayları ve diğer alt-türlerden birkaç ad aranamadı ve **doğrulanmadı** olarak işaretlidir (temiz sayılmaz). A1 `field.json` ad kuralı:
1. video_clip ve erp için A.1'deki önerilen setler yazılır.
2. note_tool seti A1 başlamadan taranır ve sonucu bu tabloya işlenir (ön koşul P1, §2.4); doğrulanmamış ad yazılmaz (§13 madde 46).
3. Oynanabilir olmayan 10 alt-türün adları A1'de olduğu gibi taşınır (ekrana çıkmazlar); A.3 temizliği o alt-türü oynanabilir yapan görevde yapılır.
4. Yayın adları ve pazar aktörü A1'de değişmez (açık karar 25).

### A.1 Oynanabilir alt-türler

**note_tool** (B2C), mevcut adlar:

| Slot | Ad | Hüküm | Kanıt |
|---|---|---|---|
| 0 | Kayıt | temiz ama sözlük kelimesi, özellik adı gibi okunur (A.4 gereği kullanılmaz) | arama: "Kayıt" not uygulaması / app note taking |
| 1 | Zihin Haritası | **çakışma** | Chrome Web Mağazası'nda aynı adlı eklenti; kategori adının kendisi |
| 2 | Notably | **çakışma** | notably.ai (Software Advice, Capterra, G2); Google Play "Notably" |
| 3 | Bellek | **çakışma** | bellek.app (kelime ve not uygulaması) |
| 4 | Kâğıtsız | temiz ama sözlük sıfatı ve EN okunuşu zor (A.4 gereği kullanılmaz) | arama: "Kâğıtsız" uygulama yazılım |
| 5 | Fihrist | **çakışma** | fihrist.digital; Google Play; ayrıca fihrist.io (ai_vector_search taraması) |
| 6 | Karalama | **çakışma** | TR App Store "Karalama" not uygulamaları |
| 7 | Mürekkep | **çakışma** | murekkepapp.com |

Önerilen set (karışık; * = **doğrulanmadı**, P1 kapsamında taranacak):

| Slot | Rol | Ad | Kayıt |
|---|---|---|---|
| 0 | sahne (dev) | Mecmua* | TR |
| 1 | sahne (yerleşik) | Ideafold* | uluslararası |
| 2 | sahne (yerleşik) | Satır Arası* | TR |
| 3 | **Lider** | Derkenar* | TR |
| 4 | **Kopyacı** | Margina* | uluslararası |
| 5 | yedek | Glyphnote* | uluslararası |
| 6 | **Niş** (ev alanı güven) | Tezkire* | TR |
| 7 | yedek | Corkline* | uluslararası |

"Yerli" seçeneği için ek TR adayı (taranacak): Müsvedde* (EN okunuşu zor). Yerli setin 4 uluslararası yuvası için P1 taramasında en az 4 yeni TR aday üretilir. Elenenler: Divit (**çakışma**: App Store "Divit: Agenda & Planner", erp taraması), Defterhane (**çağrışım**: Defterhane Protocol, erp taraması), Tomar (Portekiz'de şehir), Noteloom (Loom'u çağrıştırır), Penwise ("-wise" yaygın), Lumanote (Luma AI), Thinkleaf (okunuş), Kayıt ve Kâğıtsız (A.4).

**video_clip** (B2C), mevcut adlar: Kesit **çakışma** (kesitapp.com), Klipsa **çakışma** (App Store "Klipsa"), Makas **çakışma** (makasapp.com, TRA Makas), ShortForge **çakışma** (shortforge.ai, shortforge.pro), Kadraj Kesit temiz (ama "Kesit" bileşeni çakışıyor), Altyazıcı **çağrışım** (Kapwing TR arayüzündeki araç adı), Reelo **çakışma** ("Reelo: AI Video Editor"), Montajcı **çağrışım** ("Montaj" video düzenleyicileri).

Önerilen set (karışık; hepsi tarandı, temiz):

| Slot | Rol | Ad | Kayıt |
|---|---|---|---|
| 0 | sahne (dev) | Mizansen | TR |
| 1 | sahne (yerleşik) | Pivotreel | uluslararası |
| 2 | sahne (yerleşik) | Tefrika | TR |
| 3 | **Lider** | Halftake | uluslararası |
| 4 | yedek | Sahnecik | TR |
| 5 | **Kopyacı** | Shortlark | uluslararası |
| 6 | **Niş** (ev alanı onboarding, "telefonda kurgu") | Karecik | TR |
| 7 | yedek | Cutfinch | uluslararası |

Yerli seçenek: 1 Seyirlik, 3 Sinemacık, 5 Tadımlık, 7 Peşrev (hepsi temiz). Diğer temiz yedekler: Shotfern, Moxlet, Lumfold, Takefold. Temiz ama önerilmeyen: Ekran Payı (özellik adı gibi okunur), Perdecik (okunuş). Çakışan adaylar (kullanılmaz): Kurgu Masası, Kurguhane, Sekans, Hulasa, Kare Kare, Kıssa, Lahza, Anbean, Cliprook, Splicely, Vertico, Snipwell, Frameloop, Reelmint, Clipnest, Tidecut, Trimora, Loopwise, Cutlane, Tallframe, Tallshot, Moodreel; çağrışımlı: Sahnebaz, Ara Sahne, Kamera Arkası, Kamerist, Dekupaj, Matine, Brisklip.

**erp** (B2B), mevcut adlar: Defterdar **çakışma** (defterdar.com, ön muhasebe ve e-fatura), Kasa & Stok temiz (genel kategori adı; A.4 gereği kullanılmaz), Muhasip **çakışma** (muhasip.tr), Ledgero **çakışma** (ledgero.ch, aynı pazar), Envanter temiz (sözlük kelimesi; A.4 gereği kullanılmaz), Sayman **çakışma** (sayman.net muhasebe sistemi), Faturacı temiz (genel meslek adı; A.4 gereği kullanılmaz), Tezgâh **çakışma** (tezgah.co pazaryeri sipariş yönetimi).

Önerilen set (karışık; hepsi tarandı, temiz):

| Slot | Rol | Ad | Kayıt |
|---|---|---|---|
| 0 | sahne (dev) | Bezistan | TR |
| 1 | sahne (yerleşik) | Merivel | uluslararası |
| 2 | sahne (yerleşik) | Kalemiye | TR |
| 3 | **Lider** | Halvero | uluslararası |
| 4 | yedek | Veznedar | TR |
| 5 | **Kopyacı** | Stokdar | TR |
| 6 | **Niş** (ev alanı entegrasyonlar) | Dirhem | TR |
| 7 | yedek | Nolvik | uluslararası |

Yerli seçenek: 1 Senedat, 3 Tacirhane, 7 Kesedar (hepsi temiz). Uluslararası yedekler: Varelo, Ulvano. Çakışan adaylar (kullanılmaz): Endaze, Mihenk, Divit, Arasta, Bedesten, Miskal, Lonca, Tahsildar, Varak, Hesaphane, Hesapdar, Mizandar (aynı pazarda SaaS), Kalemdar, Sikke, Hazinedar, Defterzade, Numora, Merkant, Ordema, Talvera, Corvane, Tamber, Abacor, Kontora, Contavo, Bilanza, Ostrel, Inkora, Tessio, Sorvel, Molvane, Ledrin, Kortel, Dorvik, Brenmar, Vandrel, Fennaro, Kelvara, Calvane; çağrışımlı: Mutemet, Defterhane, Kasadar (gazeteci soyadı, geniş haber), Ruzname, Ambardar, Esham, Ambrel, Pelmora, Toloma, Tirvana, Ostavo, Fendor.

### A.2 Pazar aktörleri, yayınlar, örnek adlar

| Ad | Nerede | Hüküm | Kanıt | Gereken |
|---|---|---|---|---|
| Akkavak Yazılım | `MARKET_ACTORS` | temiz | arama: "Akkavak Yazılım", "Akkavak" software | — |
| Yalçın Teknoloji Holding | `MARKET_ACTORS` | **çağrışım** | yerel "Yalçın Teknoloji" işletmeleri (facebook.com/ytbsistem) | A1'de değişmez; açık karar 25 |
| Ostrand Systems | `MARKET_ACTORS` | temiz | arama: "Ostrand Systems", "Ostrand" software company | — |
| Ekonomi Postası | `WORLD_OUTLET_EKONOMI` (haber bandı), `WORLD_OUTLET_EKONOMI_CAPS` (bitiş gazetesi künyesi) | **çakışma** | ekonomipostasi.org yayında bir ekonomi haber sitesi | A1'de değişmez; açık karar 25: yeni ad ayrı içerik görevinde, sözlük §6 ("Mastheadler çevrilmez") ve künyeyle aynı commit'te, Erdem onayıyla |
| TeknoGündem | `WORLD_OUTLET_TEKNOGUNDEM`; `product_fixtures.gd` basın satırı | **çakışma** | teknogundem.com ve benzerleri | Aynı |
| Girişim Bülteni | `WORLD_OUTLET_GIRISIM` | temiz | arama: "Girişim Bülteni" | — |
| Sektör Telgrafı | `WORLD_OUTLET_SEKTOR` | temiz | arama: "Sektör Telgrafı" | — |
| Mizan | Görev metnindeki örnek rakip adı | **çakışma** | Al-Mizan ERP (Körfez), MIZAN muhasebe uygulamaları | Bu PRD'de kullanılmaz; örnekler A.1 setinden |
| Fatura | Ürün rev 7 C5 maketinde ve `product_fixtures.gd`'de oyuncunun ürün adı | **çakışma** | fatura.ma faturalama SaaS'ı | Yalnız debug fikstürü; açık karar 25'in içerik görevinde değişir |

Yayın adları TR ve EN'de aynı özel addır [kod `strings.csv:527-530`].

### A.3 Oynanabilir olmayan 10 alt-tür
Bu kayıtlar A1'de ekrana çıkmaz (rakip kartları adı verilerek istenir; pay ve haber yalnız oyuncunun alt-türünü okur). Her ad tek sütundadır; "doğrulanmadı" sütunundakiler aranamadı.

| Alt-tür | Temiz | Çağrışım | Çakışma | Doğrulanmadı |
|---|---|---|---|---|
| ai_assistant | Söyleç | Refik AI (Refik Anadol), Aselia, Pocket Aide | Perga AI, Kestrel, Kovan, Echo Desk | — |
| ai_photo_editor | Retušo, Işılt | Kolaj | PixelForge, Kadraj, GlowKit, Frame9 | Poz (tek sorgu) |
| ai_code_copilot | Zanaat | — | Kalfa, Syntaxa, PairUp, Loopcraft, Semic, Refacto, Çırak | — |
| ai_vector_search | Bulgu | — | VectorScale, Embedda, Nirengi, Fihrist | Nöronet, Simqore, İzsürer |
| saas_project_mgmt | Vardiya, Çizelge, Panoya, Tasarı | Dizge | Sprintboard, Tasket, Roadmapp | — |
| saas_crm | — | — | Sadakat, Yörünge, Pipeplus, Dealflow, CRMkolay | Leada, Rehber, Satışçı |
| saas_analytics | Grafkatör, Sağlama | — | Mercek, Metrion, Dashy, Insighta, Queryn, Panelist | — |
| saas_billing | Ödemely | Tahsila, Kasadar (erp taramasında gazeteci soyadı; bu pazarda da kullanılmaz) | Faturon, Billwise, Subskript, Oranla, Recurro | — |
| saas_dev_tools | Nöbetçi, Karakol, Kütükçü, Uçbirim | Sandboxy | CIforge, Devkit, APIgate | — |
| saas_ops | — | — | FlowSuite, Prosedo, Akista, Otomo, Rutin | Operanda, Süreçly, Adımla |

"Fihrist" iki pazarda (note_tool, ai_vector_search) kullanılıyor; tek ad iki rakibe verilmez.

### A.4 Ad kuralları (yeni adlar için)
Gerçek marka ya da çağrışım yok; şaka ad yok; tire ve "&" yok; en çok iki kelime; TR ve EN'de okunabilir; özellik ya da kategori adı gibi okunan sözlük kelimesi yok ("Envanter", "Zihin Haritası", "Kâğıtsız"); aynı pazarda aynı kökü taşıyan iki ad yok; özel ad çevrilmez. Her yeni ad bu tabloya kanıtıyla eklenmeden `field.json`'a giremez.

---

## Ek B — ch10 ile karşılaştırma ve GUNCELLEMELER önerisi

| ch10 maddesi | ch10 der | Bu PRD | Gerekçe | Açık karar |
|---|---|---|---|---|
| §1 Rakipler | 3–4 adlı şirket; tek kişilik: agresif fiyatçı / hızlı kopyacı / ağır yerleşik | 3 aktif + Traction'da 1 giren; 4 arketip: Lider (≈ ağır yerleşik; oyuncuya "Yerleşik" adıyla görünür), Kopyacı (= hızlı kopyacı), Niş (yeni), Parayı Bulan (≈ "Yatırım aldı") | Yönetmenin yeni yönü; agresif fiyatçı tek kişilik değil, Lider'in tepkisi ve Kopyacı/Parayı Bulan'ın tabanı | 1, 2 |
| §2 Pay | Segment başına sıfır toplamlı pay, gelire dokunur, Satış'ta görünür | A1'de pay değişmez; rakip baskısı gelire çekişme terimi ve B2C kıyasıyla dokunur; A2'de sunum katmanında pay ofseti | ch10 §8 formülü açık bırakır; Satış'a pay okuması ikinci istisna ister | 6 |
| §3 Hamleler | ~6 kartlık deste, ayda en çok 1 hamle, önceden telgraf | Kural tablosu (A1'de 5 hamle türü), rakip çeyreğinde en çok 6, her hamle telgraflı | Yaşayan rakip için ayda 1 seyrek; telgraf aynen | 15 |
| §3 Kahraman müşteri çalma | Adlı hesap ayrılır | A2'de churn atfı ve haber satırıyla (Satış koduna dokunmadan, §9) | Churn kararı Satış'ındır | — |
| §3 Çalışana teklif | İK olayı | A1 tek yön çelme kartı; A2 iki yönlü | Aynen | 5 |
| §3 Kriz yaşadı | Payı bize akar | A3 Sönen ve ölüm, yerine her zaman giren | Sebepli ölüm | — |
| §4 Pencere | Aciliyet, yatırımcı kapısı değil | Rakipler kapıyı etkilemez; Series A Hunt'ta aralık × 0,85 | Aynen | — |
| §5 Dünya olayları | v1'de renk | Değişmez; teknoloji dalgası ayrı görev, rakip davranışı tanımlı ve rezerve | — | — |
| §6 Yüzeyler | Satış altında rakip listesi, yeni sekme yok | Rakipler görünümü açık karar 7 (öneri Ürün içinde) | Satış koduna dokunmama | 7 |
| §7 Bağlar | Satış, Ürün, İK, Fonlama, Olaylar, Sonlar | §9 matrisi | Aynen, artırımlı | — |
| §8 Açık maddeler | Pay formülü; hamle olasılığı, telgraf süresi, rakip parası; satın alma; görünürlük | Olasılık ve telgraf §6; rakip parası A2 `funding_stage`; satın alma açık karar 3–4; görünürlük §8.3 (gizli durum yalnız soğuma sayaçları) | Bu belge o oturumdur | 3, 4 |
| ch01 §3 / ch13 §1 / ch14 §6 | Satın alma sonu CUT | Rakibe satılma A2'de son (karar 4; varsayılan "hayır") | Kod zaten canlı bir satın alma sonu taşıyor (ACIK_KARARLAR D1) | 4 |

**Önerilen `GDDs/GUNCELLEMELER.md` girdisi** (açık karar 18 "evet" ise, ajan taslağı):

> **ch10 Rakipler ve Dünya (sahip kararı, {tarih}).** Yürürlükteki tasarım `docs/tasks/PRD_RAKIP_DUNYASI.md`'dir. Rakip, oyuncunun ürün modeliyle (hat, kademe, alan seviyesi, beklenti) çalışır; kimliği arketiptir (Lider, Kopyacı, Niş; Traction'da Parayı Bulan). Hamleler kural tablosundan, deterministik hash'le, telgraflı gelir; rakip çeyreğinde (12 hafta) en çok 6 hamle iner. Rakip listesi {karar 7} içindedir. Segment payı formülü açık kalır; A1'de rakip baskısı gelire çekişmeli görüşme terimi (Satış §5.1 rakip seam'i) ve B2C kalite kıyasıyla dokunur. Satın alma: {karar 3–4}.

---

## Ek C — Dokunuş listesi (A1)

| Dosya | Değişiklik | Sınıf | Ajan |
|---|---|---|---|
| `scripts/data_models/rival.gd` | Yeni @export alanları, JSON getter'ları, `composite()` türetilmiş eksen dalı | Serbest | 1 |
| `scripts/autoload/rival_registry.gd` | §3.3 seam'leri ve okuma API'si, `advance_all` canlı/yedeği atlar (karar 10 "kademeden" ve açık modda), `get_market_snapshot` ve `get_player_share_pct` erişimcilerden okur (1); `fill_world()` ve `reset()` tohumu (6) | Serbest | 1, 6 |
| `scripts/systems/rival_catalog.gd` | `field.json` yükleyici + `validate()` + erişimciler; sabitler JSON'a | Serbest | 1 |
| `scripts/systems/rival_system.gd` | Yeni | Serbest | 2, 5 (`_poach_*`) |
| `data/rivals/field.json`, `data/rivals/rules.json` | Yeni | Serbest | 1 |
| `data/product/rivals.json` | Silinir (içeriği `field.json`'da) | Serbest | 3 |
| `data/product/sprint.json` | `rival_bump`, `rival_bump_max`, `rival_window_sprints`, `content.rival_news` silinir (okuyanlarıyla aynı commit'te) | Serbest | 3 |
| `scripts/systems/sprint_catalog.gd` | `area_level_for`, `archetype_for_industry`, `rival_name`'in `NAMES` okuması (1); rakip fonksiyonları yeni kaynaktan, beklenti push'tan, `word_for` (3) | Serbest | 1, 3 |
| `scripts/systems/sprint_system.gd`, `scripts/systems/sprint_bridges.gd` | `tick_rivals` ve `rival_hits` silinir (başlık yorumlarındaki anılışlar dahil); talep alanı döngüsü `archetype_for_industry`'yi çağırır | Serbest | 3 |
| `scripts/tabs/product/product_model.gd`, `scripts/tabs/product/area_panel.gd` | Kaynak değişimi, bayrak penceresi, `ui.view` `rivals` | Serbest | 3 |
| `scripts/tabs/product_tab.gd` | RAKİPLER düğmesi (karar 7 "Ürün") | Serbest | 7a |
| `scripts/tabs/product/rivals_view.gd`, `scripts/tabs/product/rivals_model.gd` | Yeni | Serbest | 7a, 7b |
| `scripts/systems/news_feed_system.gd` | "rakip" havuzu `headlines` girişi ve imleç | Serbest | 4 |
| `scripts/events/seams/seams_world.gd` | `rival.poach_odds_counter/talk` (TYPE_FLOAT), `rival.poach_pct_counter/talk` (TYPE_INT); hepsi GLOBAL | Serbest (motor dikişi) | 4 |
| `scripts/systems/rnd_system.gd` | `NAMES` okuması erişimciye (1); `_rival_name` aktif rakiplerden (3) | Serbest | 1, 3 |
| `scripts/autoload/game_state.gd` | `rival_world` değişkeni + `initialize_run`; 289. satırdaki `product` yorumundan `rival_hits` çıkar | Serbest | 1 |
| `scripts/autoload/save_manager.gd` | Şema 16, `_migrate_16`, `fill_world` ve `on_loaded` çağrıları | Serbest | 6 |
| `scripts/autoload/time_manager.gd` | Slot 4b satırı + `_ready`'de `RivalSystem.wire()` | Serbest | 2 |
| `scripts/autoload/event_bus.gd` | `rival_moved`, `rival_world_changed` (`# --- Rival signals ---` altında) | Serbest | 1 |
| `scripts/main/main.gd` | `--rivals=on/off` (2), `--rivals-shot` (7a), `--meeting-shot=rival` (7b) | Serbest (harness) | 2, 7a, 7b |
| `scripts/debug/run_probe.gd` | `--rivals`, `PROBE RIVAL_MOVE`, `PROBE RIVAL_NEWS`, `b2c_note_tool` fikstür preset'i | Serbest (harness, ayrı raporlanır) | 7b |
| `scripts/debug/product_fixtures.gd`, `scripts/debug/endgame_smoke.gd` | Fikstür göçü; yeni ve genişletilmiş vakalar (match tablosu 6'da) | Serbest | 1 (yalnız `NAMES` okuması ve `market_share_tracks_mrr`), 3, 6 (+ her ajan kendi `_case_*`) |
| `localization/strings.csv`, `docs/design/localization_glossary.md` | Yeni anahtarlar, iki silme, sözlük satırları (onay bekler) | Serbest | 4 |
| `data/events/cards/rival/poach_offer.json` | Yeni | Serbest | 5 |
| `scripts/systems/sales_meeting_system.gd` | Tek katkı + tek etiket | **Onaylı istisna** | 4 |
| `scripts/ui/meeting/sales_meeting_adapter.gd` | `CHIP_BY_SEAM`'e tek satır | **Onaylı istisna** | 4 |
| `scripts/events/core/effects.gd`, `scripts/modals/event_modal.gd` | `change_salary` uygulaması ve `_is_negative`'in `pct` işareti, çipi | **Onaylı istisna** | 5 |
| `scripts/systems/quality_model.gd` | Yeni `RIVAL_TIER_HALF_SAT` + `normalized_quality_rival` dalı; `:31-35` yorumu | Karar 21 ile | 2 |
| `CLAUDE.md`, `docs/HARITA.md`, `docs/EVENT_SIGNAL_MANIFEST.md`, `docs/content/events_draft/_vocabulary.md`, `docs/ACIK_ISLER/ACIK_KARARLAR.md` (madde 14), `GDDs/GDD — ZAMAN MODELİ.md` §10 | Güncelleme / yeniden üretim | Belge | 6 |
| İK sistemleri, Finans sistem ve görünümleri, Satış'ın geri kalanı (`sales_system.gd`, `sales_rep_system.gd`, `sales_tab.gd` …), VC (`vc_pitch_system.gd` …), `scripts/events/tools/lint.gd` | **Değişmez** | Yasak | — |

---

## Ek D — Uç durum listesi

| # | Durum | Beklenen davranış | §13 |
|---|---|---|---|
| D1 | Tip seçilmeden önce | Rakip saati başlamaz, inbox yazılmaz, haber yok; görünüm boş durumu yalnız fikstürle | 9, 39 |
| D2 | Oynanabilir olmayan alt-tür (smoke `ai_vector_search`) | `RivalSystem` boşta; dünya smoke'ları değişmez | 10 |
| D3 | Tip geç seçildi (ör. 30. hafta) | Saat seçimden başlar; ilk rakip sprintinde hamle yok; çelmenin hafta kapısı takvime bağlı olduğundan ilk uygun çeyrekte değerlendirilir | 9, 11 |
| D4 | MVP sprintinin hatları | `live=false`, kopya tetiklemez | 18 |
| D5 | Oyuncu K1 çıkarır | Kopya tavanı 0: telgraf yok, kilit harcanmaz | 17 |
| D6 | Aynı hat kopya inmeden ikinci kez yükseltildi | Hedef duyuruda donmuştur; ikinci yükseltme 12 sprint kilidinde tetiklemez | 16 |
| D7 | Ar-Ge çalışma zamanı hattı | Tetik yazılmaz; rakip alan seviyesi katalog hatlarından; oyuncunun alan ortalaması düşerse Kopyacı inişi yeniden denetlenir | 19, 31 |
| D8 | `cap_paid_plan` | Tavan 1; kopya tavanı 0; Gelir alanı beklenti artışı almaz; Lider Gelir'i aday hattı yoksa seçmez | 33 |
| D9 | Oyuncunun çıkarmadığı hat | Kopyacı orada hamle yapmaz (katı kural); tohum kademesi kalır; Lider ve Niş serbest | 16 |
| D10 | Kopyacı'nın K3 kapısıyla oyuncunun K3'ünü yakalaması | Katı kural K3 hamlesini de eler (oyuncu K3 ise Kopyacı en çok K2) | 16 |
| D11 | Tavan dolu, tepki tetiklendi | Tetik anında düşer, telgraf yok, `PROBE … dropped:budget` | 12 |
| D12 | Aynı rakibe aynı rakip sprintinde iki iniş | İkincisi taahhüt anında bir sonraki rakip sprintine yazılır; kayma çeyreği değiştirirse yeni çeyreğin tavanı denetlenir | 12 |
| D13 | Kaydet-yükle telgraf sırasında | `pending` ve `headlines` kayıtta; bayrak ve "Hazırlanıyor" geri gelir | 14, 37 |
| D14 | v15 kayıt, ortasında | `_migrate_16` + `fill_world` + `on_loaded`; ilk tikte patlama yok | 36 |
| D15 | v15 isabeti K3'teki hatta | Tavanla kesilir; alan kelimesi yüklemede değişebilir (kabul) | 36 |
| D16 | Dil değişimi | Hamleler aynı; arşivdeki haber satırları eski dilde; görünüm ve kart yeni dilde | 15 |
| D17 | Kurucu tek başına, çalışan yok | Çelme hedefi yok, yuva harcanmaz, telgraf yok | 26 |
| D18 | Çelme hedefi izinde ya da eğitimde | Hedef dışı | 26 |
| D19 | Çelme hedefi telgraf ile iniş arasında ayrıldı ya da kovuldu | `void` iniş, yuva harcanmış, ek haber yok | 30 |
| D20 | `EventGate.request` false | Kart açılmaz, `drop_move` ile yuva iade, hafıza değişmez, telgraf satırı kalır, çeyreğin çelme hakkı harcanır | 27 |
| D21 | Çelme kartı açıkken ya da kuyrukta düşürüldüyse | Kart kritik interrupt'tır; saat durur, kâğıda düşmez, süresi dolmaz; motor kuyruktaki kartı düşürürse kapanış `departed` ya da 2 tiklik zaman aşımıyla gelir | 30 |
| D22 | Karşı teklif kabul, moral hâlâ düşük | +15 moral (çarpanlı); İK zarı yalnız moral yeniden 35 altına iner ve 2 hafta kalırsa devreye girer | — |
| D23 | Karşı teklif bant tavanında | `change_salary` bandı gözetmez (bilinen sınır, yazılı) | — |
| D24 | Hedef PM, sorumlu ya da sprint kartında | Ayrılırsa İK ve Ürün'ün mevcut ayrılış davranışı (ÇEYREK kapanır, kartlar yeniden atanır, müşteri kurucuya döner); rakip ek davranış eklemez | — |
| D25 | Satış: 1★ tek soruluk görüşme | Rakip çipi yok, yalnız hover | 24 |
| D26 | Satış: 4 satır tavanı | Rakip terimi ≥ 0,12 ise genelde ilk dörtte; değilse "ve dahası"na katlanır (kabul fikstürü) | 24 |
| D27 | Görüşme kaybında prospect silindi | Etiket adı katkının içindeki rakip id'sinden | 22 |
| D28 | Hafta içi kadran değişti | Push senkron yenilenir; açık görüşmenin taban terimleri değişmez | 25 |
| D29 | Temsilci kapanışı | Kapma sayılır, çekişme uygulanmaz | 25 |
| D30 | Müşterinin sektörü hiçbir arketipte değil | Segmentsiz; fiyat sayacına girmez | 21 |
| D31 | En iyi çekişme rakibinde eşitlik | Sabit rakip sırası; hafta hafta ad değişmez | 23 |
| D32 | Olay `churn_customer` ile müşteri gitti | Rakip görmez (`customer_churned` yayılmaz [kod `effects.gd:250-263`]); A1'de kapma geri alınmaz | 21 |
| D33 | Aynı tikte sprint kapanışı ve rakip inişi | Sürüm notu hamle öncesini okur (kabul) | — |
| D34 | Oyuncu sprinti 3 tik (otomatik) | Bayrak penceresi gerçek döngüye göre; ileri sütunda bayrak yok | 32 |
| D35 | Beta açık sprint | Sürüm bir sprint gecikir; bayrak penceresi sürümü değil sprint tik aralığını okur | — |
| D36 | 104. hafta sonrası (EA/tam) | Rakipler hareket etmeye devam eder; tüm hatlar tavandaysa tempo hamlesi ve haber yok | 11 |
| D37 | Rakip dünyası kapalı (karar 9 "hayır" yapısı ya da `--rivals=off`) | inbox yazılmaz, push boş, `epoch_day` −1, şablon eksenler ve yarı doygunluk 50, `advance_all` hepsini büyütür, RAKİPLER düğmesi yok; açık yapıda yüklenince `pending` boşaltılır ve saat yeniden tohumlanır | 10b |
| D38 | Debug `set_phase` ile faz atlama ya da geri | Faz çarpanı ve A2 giren `GameState.phase`'ten türetilir, kenara bağlı değil | 9 |
| D39 | Aynı haftada hamle satırı ve pay satırı aynı rakip için | Hamle satırı `recent_rivals`'ı damgalar, pay satırı o hafta basılmaz | 34 |
| D40 | Rakip olayı `max_age_ticks` içinde basılamadı | Düşer, `PROBE RIVAL_NEWS dropped=` | 34 |
| D41 | Kopyacı'nın aynı hatta bekleyen kopyası varken tempo saati doldu | O hat aday değil (§5.0) | 16 |
| D42 | MVP öncesi rakip inişleri | `overtook = false`; beklentiye girmez; MVP anında beklenti faz değeridir | 33 |
| D43 | Lider tek aday alanı Gelir ve Gelir tavanda | Alan aday listesinde değil; başka aday yoksa hamle yok (`no_line`) | 11 |
| D44 | Niş ev alanı K2'de ve K3 kapısı kapalı | Ev alanında aday yok → ikinci alan (aralık 5); orada da yoksa hamle yok | 11 |
| D45 | Bütün hatlar tavanda | Tempo hamlesi yok; tepki ve çelme sürer | 11 |
| D46 | Mentor kilitli satırı doluyken (A2) | Rakip satırı ezmez | — |
| D47 | Ölü rakip (A3) için açık telgraf | İptal (`drop_move`), bayrak kalkar, push yenilenir; lig ve B2C kıyası donmuş kademeyle | — |
| D48 | İki yedek de tükendi (A3) | Ölen slot `reserve_names` ile yeniden tohumlanır; aktif rakip sayısı düşmez | — |
| D49 | Uzun rakip adı, EN | Görünüm ve haberde kırpma + hover | 40 |
| D50 | Kopyacı hatta tohumdan K1, oyuncu K2 çıkarır | Kopya tetiklenmez (`no_gap`), kilit ve yuva harcanmaz; `follow:<hat>` yine yazılır | 17 |
| D51 | Kayıt, tip seçimi ile ilk 4b arasında | Yüklemede saat kurulmaz; ilk 4b §6.1 adım 0(d) ile kurar, kesintisiz koşuyla aynı tik | 14 |

---

## Ek E — PRD doğrulama listesi (görev §7, teslim öncesi öz denetim)

| # | Kontrol | Durum | Nerede |
|---|---|---|---|
| 1 | Her rakip hamlesinin tetiği, gecikmesi, orantısı, sebep metni ve soğuması tabloda | ✅ | §6.2 (Orantı ve Sebep kökü sütunları dahil), §7, §4.6; A2/A3 sebep taslakları §11; yalnız manşet olan üç hamle telgraf istisnasıyla (§1) |
| 2 | Hiçbir kural rakibe oyuncunun ürün modeli dışında yetenek vermiyor | ⚠️ | §3.9, §5.4. Oyuncunun K1–K2 kademelerindeki ekip kapısının rakipteki eşdeğeri arketip temposudur; rakip K3'ü Ar-Ge düğümü yerine takvimle açılır, kapı tipik oyuncunun hesaplanan ilk K3 haftasına (52) çekildi ve ölçümle doğrulanacak (açık karar 22, §13 madde 11) |
| 3 | Her yüzey öge öge, paragraf yok | ✅ | §8.1–§8.8 ve §8.10 tablolar (§8.4 görünürlük dahil); §8.9 tek kural cümlesi (yeni yüzey değil, mevcut notun ad kaynağı) |
| 4 | Matrisin her hücresinde giren sinyal ve çıkan etki var; Satış/İK/Finans koduna dokunma gerektiren hücre yok | ⚠️ | §9. Satış B2B hücresi bu oturumda yönetmen onayıyla verilen tek istisnadır (§2.3). A2'nin üç hücresi (B2C fiyat, iki yönlü çelme, VC) açık karar 5, 6, 17'ye bağlıdır |
| 5 | EA asgari tek göreve sığıyor ve statik tabloyu bozmuyor | ⚠️ | Tek göreve sığma: ✅ §2.2, §14 (8 alt-ajan, paylaşılan dosya protokolü, kesme çizgisi). Statik tablo: rakip seçimi ve kademeler tohum olarak aynen taşınır (§4.2); sprint takvimli `launches` silinir ve üç ⚑ davranış (bayrak, beklenti, durum kelimesi) açık karar 11 ve 23'e bağlıdır |
| 6 | Çalışma değerleri tek tabloda, JSON yolu belirtilmiş | ✅ | §10.1 |
| 7 | Marka adları uydurma; gerçek marka aramasıyla kontrol | ⚠️ | Ek A. video_clip ve erp setleri tarandı ve temiz; note_tool seti web arama bütçesi dolduğu için doğrulanmadı (ön koşul P1); iki yayın adı ve bir pazar aktörü gerçek markayla çakışıyor (açık karar 25, ön koşul P2); oynanabilir olmayan alt-türlerin temizliği o alt-türü açan göreve kaldı |
| 8 | Açık kararlar tek kelimeyle cevaplanır | ✅ | §15 (25 karar) |
| 9 | Startup ligi fonksiyonunun kullanım yeri | ✅ | §3.11; A1 Rakipler görünümü başlığı (§8.3), A2 bitiş gazetesi ve VC (§8.5, §8.8) |
| 10 | Nemesis patent notu | ✅ | §3.12, §1 ders 4 |
| 11 | Kaynak linkleri var, çıkarımlar etiketli | ✅ | §17 (16 + 4 kaynak, erişim ve destek sütunu), §10 etiketleri |
