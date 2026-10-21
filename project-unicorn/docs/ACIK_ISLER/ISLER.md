# Açık işler

Açık işlerin tek yeri bu klasördür.
- `ACIK_KARARLAR.md`: sahibin kararını bekleyen maddeler. Ajan bunlara karar gelmeden dokunmaz.
- Bu dosya: yapılması kararlaştırılmış ama henüz yapılmamış işler. Biten iş, onu bitiren commit'te buradan silinir.

## Test paketi
- Smoke ve probe paketi yalın bir paketle değiştirilecek (CLAUDE.md "Test"). Bugün `scripts/debug/endgame_smoke.gd`
  467 vaka taşıyor. Yalnız smoke, probe ya da `main.gd` debug harness'larının eriştiği üretim kodu ve CSV'de yalnız
  smoke'un okuduğu türetilmiş anahtar aileleri bu işle birlikte ele alınır; temizlik raporlarında "yalnız test" diye
  ayrılan maddeler de buraya girer.

## Olay motoru
- Lint kuralı: bir arkın `reassign_event` / `close_event` kartı öznenin slotunu bildirirse, özne `entity_exists` ile
  geçersizlendikten sonra G5'i hiç geçemez (§10.6'nın yasakladığı sessiz ölüm). Bugünkü kartlarda yok; kural eklenmeli.
- G6'nın faz koruması hiç geçmiyor: `EvGate._g6_guards` `guards.phase`'i JSON'un float dizisinde `Array.has` ile
  arıyor ve Godot 4.6.2'de `[2.0, 3.0].has(2)` false döner (`scripts/events/gate/gate.gd`). Bugün kullanan kart yok;
  kartlar evreyi `phase.current` seam'iyle okuyor. Karşılaştırma tam sayıyla yapılır.
- `min_gap_weeks` 4'ün üstünde 4 gibi davranıyor: `EvTempo._prune` geçmişi `MIN_GAP_WEEKS_DEFAULT` ile özne
  boşluklarının en büyüğü kadar (4 hafta) tutuyor (`scripts/events/present/tempo.gd`). `customer.security_review` ve
  `team.outside_offer` 8 der. Budama kartların en büyük `min_gap_weeks`'ini de kapsar.
- `info` ve `ambient` kart kategori kotası tüketiyor: `EvTempo.assign` her kabulü tempo penceresine yazar ve katman 3
  penceredeki her kaydı sayar (`scripts/events/present/tempo.gd`); motor GDD §13.2 "bütçe tüketmez" der (§27.13).
  Bugün canlı tek `info` kart `customer.release_thanks`'tir ve nottur (not yolu tempo penceresine yazmaz, §27.17); canlı
  `ambient` kart yok. Bu iki sınıf katman 3'te sayılmaz.
- B2C söz eşdeğeri açık: B2C'de söz olayı yok, çünkü şirketler sürüm çıkmadan kullanıcıya tarih vermez, sürüm çıkınca
  not paylaşır; kullanıcılara tarih duyurmak ve “kampanya aracı” ikizi reddedildi; Erdem “üstüne düşünmek lazım” dedi,
  aday yön C'nin istek verisi gelince en çok istenen şeyin sürüm yorumlarında “hâlâ yok” diye görünmesi.

## Oyuncu metni
- Oyuncu metinlerinde tire (— –) kalan yerler var (CLAUDE.md §5; Erdem 2026-10-20 kararı 14: hiçbir yerde tire yok,
  sorulmaz, yapılır; değişen metin commit mesajında "TR/EN onay bekliyor" diye işaretlenir): CSV'de iki dilden birinde
  tire taşıyan 31 satır (ör. `HR_TASK_NONE`, `HUNT_CB_NONE`, `VC_Q_CHURN`, `GATE_ADVANCE`, `END_META_*_FRANK`) ve
  `scripts/tabs/sales_tab.gd` `_account_foot`'taki "—" literal'i (sorumlu satırı, ACIK_KARARLAR 35).
- EN çoğul ikizi: `DESK_PAPER_ATLAS_TITLE` ("{n} candidate files ready") n=1'de çoğul okunuyor; tekil ikiz anahtar ve
  seçimi gerekir (TR sayıdan sonra çoğul eki almaz).

## Ofis ve pencereler
- İlk açılış rehberi yok: kurulum bitince oyuncu ofise düşer; ofis, pencereler, not yığını ve "Ofisi taşı" düğmesi
  tanıtılmaz. Kurulumun "Frank'le rehberli başla" anahtarı rehber yazılana kadar kilitli (`ONB_GUIDED_LOCKED`,
  `first_week_doc.gd`); `tutorial` etiketli kart yok. İstenirse ayrı iş.
- 70 kişilik Depo loft'ta kare ~8,4 ms (eski Xbot kadrosu ~6 ms); ölçüm eski merdivenin 4×'ünde, bugünkü 1×'in
  temposunda; LOD turu, karar ACIK_KARARLAR 71.
- Harita kartı küçük resimleri hâlâ tasarımın Xbot figürleriyle (`assets/art/office/thumb_*.jpg`); Quaternius
  karakterleriyle yeniden çekim, karar ACIK_KARARLAR 72.
- Huylar ofis ritmini etkilemiyor (kahveci, İŞKOLİK, düşük moral kahve ve mola sıklığını değiştirmiyor); trait
  task'ına bırakıldı (ofis karakterleri kararı 4).
- Şehir haritası ana iş parçacığında yükleniyor (`OfficeCity.open` → `OfficeView.load_layout("city")`): ~130 ms
  takılma, önünde "hazırlanıyor" perdesi. Arka planda ya da önceden yükleme.
- Export ön ayarı kurulunca `art/office3d/*.json`'ın pakete girdiği doğrulanır: `OfficeLayout.load` onları
  `FileAccess` ile okur; gerekirse include filtresine eklenir.

## Ürün rev 7
- **Yeniden yuva listesi (PRD §5.9, §7.23).** GDD'de adı geçtiği ya da sahip tuttuğu için kalan, sprint geçişiyle
  oyun içi çağıranı kalmayan öğeler; her biri sprint ekranında bir yere bağlanır ya da sahibin kararıyla silinir:
  - Tip ekranının kilitli üçlüsü (ch03 §12.11, GUNCELLEMELER ch14 §2): `ProductCatalog.locked_type_ids`,
    `TYPE_SCREEN` kilitli listesi, `type_sector_labels`; tür seçici yalnız oynanabilir türleri çiziyor
    (ACIK_KARARLAR 96).
  - Hat okumaları (ch03 §12.9): `ProductLines.is_complete` (yalnız smoke). Kapı üstü hız basamakları
    (`LineGates.speed_bonus_for`, `ABOVE_GATE_*`, ch03 §12.8) okuyucusuz duruyor, kararı ACIK_KARARLAR 41'de.
  - Altyapı ve fiyat (ch03 §10): `SalesSystem.estimate_price_change` (okuyanı yok, smoke da çağırmıyor; Faz E siler).
  - Pazar payı merdiveni (ch03 §12.11; sahip): oyuncunun kendi tipindeki startup rakipler arasındaki sırası; kodda ve
    ekranda yok. İstenirse rakip modeliyle birlikte kurulur.
  - Merdiven reddi (ch03 §12.3): `ProductLines.ladder_refusal` (yalnız smoke `line_ladder_rules`; aday kartlar
    sıradaki kademeyi `next_tier`'dan okur).
  - Liderlik ve koordinasyon çıktısı (Ekip §4.2, §17.2): `HRSystem.leadership_output_mult`,
    `HRConstants.LEAD_OUTPUT_PER_POINT`, `HRConstants.coordination_for_founder` / `coordination_for_lead` ve `COORD_*`,
    `HRSystem.output_mult_for_area` (yalnız smoke; sprint puanı liderliği ve koordinasyonu okumaz, ACIK_KARARLAR 96).
  - Satış okuma eşiği (Satış GDD): `SkillCheck.can_read_prospect` (yalnız smoke); `SALES_READ_THRESHOLD` yalnız
    kurulumun Satış etki cümlesini seçer (`origin_traits_step.gd`).
  - Kritik hata bayrağı: `critical_bug_unfixed` (`GameState.FLAG_TYPES`, `EvEffects.GAME_FLAG_WHITELIST`; okuyanı
    `launch()`'tı).
  - Okuyanı olmayan anahtarlar: `PROD_DEV_VERSION` (yalnız `loc_language_switch` smoke örneği), `PROD_MARKET_SHARE`
    (yalnız bir smoke yorumu anıyor).

## Ürün rev 7 kalibrasyon turu
- **Bayrakla ulaşılamayan görsel kabul yüzeyleri.** Turun görsel kabulü altı durumu repoda olmayan bir sürücüyle
  kurdu; mevcut shot bayrakları bu durumlara gelemiyor. Her biri için bir shot türü yazılır (`--product-shot=live:`,
  `--finance-shot=`, `--meeting-shot=`, `--event-shot=` ailelerinde):
  - Sözlü sprint kartı ("söz verildi" damgası, öngörüde "{müşteri} sözü tutulur").
  - Canlı sürümlerin Geçmiş'teki gerçekleşen satırları (iki sürüm kapanmış koşu).
  - Planlamadan sonra kapısı kapanan kart: başlatmada sonraki sütuna geçer, KİLİTLİ ve yalnız Çıkar.
  - Satış toplantısında "yer yok" gerekçesiyle kilitli söz cevabı.
  - Koşan sprintte sprint karar kartları ve B2B söz satırının iki kilidi (kırık söz, yer yok); `--event-shot`'un
    fikstür dünyasında bu kilitler doğmuyor.
- **Ürün rev 7 denetiminin plan dışı bulguları.** Kalibrasyon turu bunlara dokunmadı:
  - C-05: Penceresinde yapılabilir adım olmayan B2B talebi, adım açılınca aynı pencerenin sonraki bir tikinde doğuyor
    (ACIK_KARARLAR 96 (28) ve PRD'nin zamanlamasıyla çelişir).
  - C-09: Öngörü durum sözcüğü değişmeyen seviye geçişini de yazıyor ("Çekirdek Yeterli → Yeterli"):
    `SprintCatalog.card_effect` yarım adım yuvarlanmış seviye değişince `level` parçası verir, `SprintUiShared.forecast`
    iki ucun sözcüğünü eşit olsa da çizer. Faz Q K2 sözcüğü ürün sayfasının referansına göre ham seviyeden okur hâle
    getirdi (`9a0dff9`); bu davranış değişmedi. Kardeşi: `holds` parçası kartın SONRAKİ ham seviyesinin sözcüğünü
    (`level.to_word`) yazar, alan paneli bugünkü ham seviyeninkini; seviye aynı yarım adımda kalıp sözcük sınırını
    aşarsa kart "Zayıf kalır" derken panel "Yok" okur.
  - C-10: Ücretli plan özelliklerle aynı sürümde çıkınca fiyat, aynı kapanışta kart sırasında kendisinden sonra gelen
    kademeler yazılmadan kuruluyor: `SprintSystem._close` döngüsü `SprintBridges.open_paid_plan`'ı kartın sırasında
    çağırır, `SalesSystem.product_value` kalite terimini (`b2c_quality`, canlı kademelerden) ve açık hat sayısını o
    anki kademelerden okur. Eksen sayıları Faz Q K7b'de kalktı; eskiden fiyat döngüden sonra yazılan eksen
    gerçekleşmesinin bütününden önce kuruluyordu (~%14 düşük ölçüsü o dönemin), şimdi yalnız sonraki kartlar eksik.
    Yeni kalite terimiyle yeniden ölçülmedi.
  - INT-6: Koşan kartı "Çıkar"mak yapılmış puanı HIZ satırından düşürüyor (`SprintSystem.done_points` yalnız
    sprintteki ve devreden kartları sayar).
  - INT-10: Eski yapım motorunun bayrak artıkları: ölü bir bayrak türü öneki ve tek okuyucusu silinen iki beyaz
    listeli bayrak.
  - LC-9: PM kovulunca ya da izne çıkınca onaylı planları sprintleri yönlendirmeyi sürdürüyor; ÇEYREK kilitli, planlar
    görünmüyor ve geri alınamıyor.
- **Harness notları** (`scripts/debug/run_probe.gd`):
  - Botun B2B işe alım kapısı (kasa ≥ 6 × (burn·30 + 6.000 − MRR), `_hire_after_the_seed`) Traction'ın erken
    sonucunu belirliyor (ACIK_KARARLAR 98).
  - `--event-harness=guided` yalnız `EvEngine`'i tikler: ürün türü seçilmez, sprint koşmaz; MVP öncesi ritmi ölçemez.
    Ritim probe günlüklerinden okundu.
  - Probe kurucusunun Müşteri İlişkileri'si 0'dır (`main.gd` debug yükü): masadaki kurucu doğrulama yapmaz ve
    düzeltme koşusu kalktığı için düzeltme de yapmaz; düzeltme sprintin düzeltme kartındandır. B2C kolunda ödeyen
    kullanıcı gelince kurucu Destek'i Yapım'ın yanında ikinci iş olarak alır ve sprintte yarım pay sayılır.
    Faz A ile değişti (2026-10-17); sahip onayı RAPOR_A'da.
  - Bot `rival.funding_round`'da hep ilk seçeneği alır: "bekle"nin zamanladığı `rival.price_cut` yolu hiçbir probe'da
    koşmuyor. Sensible politika `founder.side_contract`'ta hep "al"ı seçer.
  - Faz 3 giriş kartlarının (`world.analyst_guide`, `world.newsletter_slot`) smoke vakası yok; onları yalnız probe
    ve lint koruyor.
  - `min_cash_pre_seed` haftalık `STATE` okumasından alınır, hafta içi dip değildir.

## VC görüşmesi · takip katmanları
- **Takip sorusu ve anlaşmanın düşmesi (Faz A Karar 10; sonraki VC işi).** Bugün yatırımcının sorgusu tek sorudur
  (`VCPitchSystem._sorgu_*`; negatif itibar için `VC_Q_REPUTATION`, "İtibarın zedeli. Bu hikâyeye kim inanır?") ve
  cevaptan sonra konu kapanır. Faz A negatif itibarı yatırımcının sorgusuna açtı ama şu iki katmanı yapmadı:
  - "Bunu düzeltmek için ne planlıyorsunuz?" türü takip sorusu: yatırımcı bulduğu zayıflığın düzeltilip
    düzeltilmeyeceğini cevaptan sonra sorar.
  - Yatırımcı ikna olmazsa anlaşmanın düşmesi: takipte ikna olmayan fon teklifini geri çeker.

## Rakip Dünyası · Piyasa I1 sonrası
- **I2 · "Ürünleri" bölümü.** Sektör rakibinin rapor kartında çıkmış 2-4 yetenek hattı (PRD Rakip Dünyası §3.4);
  `piyasa_tab.gd`'de yuva boş bırakıldı, birleşik `Rival.line_tiers` ile dolar; satış itirazının andığı listeyle aynı.
- **I4 · Son bakıştan beri.** Pencere kapanışında anlık görüntü, yeniden açılışta liste satırlarında oklar
  (`PIYASA_SINCE_LAST`); oyuncu karosuna uygulanmaz.
- **Parodi adlarının yeniden taraması** (WebSearch bütçesi yenilenince, PRD Ek A.9): `companies.json`'da
  `provisional: true` taşıyan satırlar ve `RivalCatalog.NAMES`'teki Tefrika (video_clip slot 2'nin ürün adı sahip
  kararı), Tezkire (A.4 yedeği, taranmadı), Monoline (kanıtsız); çakışma alan iki slot (video_clip 1 KineMaster hedefi,
  note_tool 6 Obsidian hedefi) tuvalde yeni seçim bekler, bugün yedek adlarını taşır. Pivotreel ile Wunderreel aynı
  pazarda aynı kökü ("reel") taşıyor (Ek A.6). Bitwaltz'ın halka açık kurgusu (hedef özel şirket) sahip kararı.
- **Eski kayıtta rakip adları.** `SaveCodec` her `Rival`'ı kaydın sözlüğünden kurar: eski kayıt `product_name`'i
  (çakışma hükümlü eski adlar) ve boş `company_id`'yi getirir. Katalog alanlarının restore'da katalogdan okunması
  (`RivalRegistry.insert_raw`) sahip onayı bekleyen küçük iş.
- **Piyasa penceresi, sahip kararına göre:** 1536 karesinde kartın tekerlekle kaymasına karşı maketin sıkıştırması
  (karo 100 / bölme 128 / grafik 140); Tümü grafiğinin başlangıç yılı (bugün halka arz yılından önceye gitmez);
  kadran ondalığı (%1 altında bir basamak, üstünde tam yüzde); `Fmt.money_market` bantlaması (999,95 → $1,0B);
  Sektörüm çipinin ürün tipi seçilmeden gizli kalması.
