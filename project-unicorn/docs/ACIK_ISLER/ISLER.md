# Açık işler

Açık işlerin tek yeri bu klasördür.
- `ACIK_KARARLAR.md`: sahibin kararını bekleyen maddeler. Ajan bunlara karar gelmeden dokunmaz.
- Bu dosya: yapılması kararlaştırılmış ama henüz yapılmamış işler. Biten iş, onu bitiren commit'te buradan silinir.

## Test paketi
- Smoke ve probe paketi yalın bir paketle değiştirilecek (CLAUDE.md "Test"). Bugün `scripts/debug/endgame_smoke.gd`
  345 vaka taşıyor. Yalnız smoke, probe ya da `main.gd` debug harness'larının eriştiği üretim kodu ve CSV'de yalnız
  smoke'un okuduğu türetilmiş anahtar aileleri bu işle birlikte ele alınır; temizlik raporlarında "yalnız test" diye
  ayrılan maddeler de buraya girer.

## Olay motoru
- Lint kuralı: bir arkın `reassign_event` / `close_event` kartı öznenin slotunu bildirirse, özne `entity_exists` ile
  geçersizlendikten sonra G5'i hiç geçemez (§10.6'nın yasakladığı sessiz ölüm). Bugünkü kartlarda yok; kural eklenmeli.
- "Kâğıt masada mı" okuması yok: `SprintSystem` bekleyen karar kâğıdını bulmak için `EventGate.desk_papers`'ı
  `DESK_SCAN` (64) kâğıda kadar tarıyor. `EventGate.has_paper(event_id)` gibi bir okuma kurulunca sabit silinir.
- G6'nın faz koruması hiç geçmiyor: `EvGate._g6_guards` `guards.phase`'i JSON'un float dizisinde `Array.has` ile
  arıyor ve Godot 4.6.2'de `[2.0, 3.0].has(2)` false döner (`scripts/events/gate/gate.gd`). Bugün kullanan kart yok;
  kartlar evreyi `phase.current` seam'iyle okuyor. Karşılaştırma tam sayıyla yapılır.
- `min_gap_weeks` 4'ün üstünde 4 gibi davranıyor: `EvTempo._prune` geçmişi `MIN_GAP_WEEKS_DEFAULT` ile özne
  boşluklarının en büyüğü kadar (4 hafta) tutuyor (`scripts/events/present/tempo.gd`). `customer.security_review` ve
  `team.outside_offer` 8 der. Budama kartların en büyük `min_gap_weeks`'ini de kapsar.

## Arayüz yeniden yapılırken
Temizlikte görülen ama arayüz yeniden yapılacağı için dokunulmayan noktalar:
- Ham stil değerleri (UI/STYLE LAW; her biri yeni token ister): `month_summary_modal.gd` font, yarıçap, margin;
  `finance_ozet_view.gd` modulate'ları; `hunt_tab.gd` `_label` boyutları (11–14; 14 merdivende yok)
  ve disabled alfaları; `OnboardingFlow.tscn` LoadingLabel 18, `origin_traits_step.gd` ve `character_step.gd`
  modulate'ları; bir yerde ham 24 punto ve CREAM rengi.
- `hr_tab.gd` saat çipini (`_paint_hours_control`) ve Kadro/Görevler segmentini (`_paint_segments`) elle kurduğu
  StyleBoxFlat'lerle çiziyor; ikisi de tema varyasyonu ister (UI/STYLE LAW 4).
- Çubukların tema bağımsızlığı: `bar_kit.gd`, `build_bar.gd` ve `research_bar.gd` bilerek tema varyasyonu kullanmıyor,
  yazdıkları gerekçe (ODA alt ağacının donmuş teması) ağaçta yok. Karar: varyasyonlara taşınırlar ya da bağımsızlık
  bugünkü bir gerekçeyle kalır.
- Ar-Ge atama panelindeki ayraç `HRUiShared.hairline` ile çiziliyor (eski kopya `anti_aliasing = false` diyordu).
- Oyuncu metinlerinde tire (— –) kalan CSV satırları var (CLAUDE.md §5); mühürlü metinlerde sahibin kararı gerekir.
- EN çoğul ikizleri: `DESK_PAPER_ATLAS_TITLE` ("{n} candidate files ready") ve `FIN_GOAL_P3_HUNT` ("{n} offers on the
  table") n=1'de çoğul okunuyor; tekil ikiz anahtar ve seçimi gerekir (TR sayıdan sonra çoğul eki almaz).

## Ofis ve pencereler
- İlk açılış rehberi yok: mentor modalı kapanınca oyuncu ofise düşer, ofis, pencereler, not yığını ve "Ofisi taşı"
  düğmesi tanıtılmaz. İstenirse ayrı iş.
- Ofis 1080p'nin üstünde konteyner ölçüsünde çiziliyor (`scenes/office/OfficeView.tscn`, `stretch`); doğal
  çözünürlükte çizim, karar ACIK_KARARLAR 70.
- 70 kişilik Depo loft 4×'te kare ~8,4 ms (eski Xbot kadrosu ~6 ms); LOD turu, karar ACIK_KARARLAR 71.
- Harita kartı küçük resimleri hâlâ tasarımın Xbot figürleriyle (`assets/art/office/thumb_*.jpg`); Quaternius
  karakterleriyle yeniden çekim, karar ACIK_KARARLAR 72.
- Huylar ofis ritmini etkilemiyor (kahveci, İŞKOLİK, düşük moral kahve ve mola sıklığını değiştirmiyor); trait
  task'ına bırakıldı (ofis karakterleri kararı 4).
- Şehir haritası ana iş parçacığında yükleniyor (`OfficeCity.open` → `OfficeView.load_layout("city")`): ~130 ms
  takılma, önünde "hazırlanıyor" perdesi. Arka planda ya da önceden yükleme.
- Export ön ayarı kurulunca `art/office3d/*.json`'ın pakete girdiği doğrulanır: `OfficeLayout.load` onları
  `FileAccess` ile okur; gerekirse include filtresine eklenir.
- `project.godot` `rendering/reflections/sky_reflections/roughness_layers=7`: ofisin gökyüzü (REALTIME) yedi katman
  istiyor; proje ayarı farkı sahibin onayıyla commit'lenir (CLAUDE.md §12).

## Ürün rev 7
- **Görsel kabul (CLAUDE.md §11).** Canlı sprint ekranı oyunda görsel olarak doğrulanmadı: tür seçici, planlama,
  karar bekleyen kartla sprint içi, sürüm notu, beta sürümü, B2B talepleri, ÇEYREK (PM'li ve PM'siz). Kareler
  `--product-shot=live:<pick|plan|active|b2c_mvp|b2b_requests>` ve fikstürle `--product-shot=<c1..c5|edge:<ad>>`;
  PRD §7.24'ün kareleri `docs/audits/urun_rev7/` altına, §8'in kontrolleri sahibin.
- **"Sprint otomatik başladı" notunun Ürün penceresindeki yeri.** Not BuildHUD'ın DESTEK kartındadır
  (`build_bar.gd`). Kart yalnız ürün yayındayken vardır ve bir pencere üstüne gelince gizlenir
  (`BuildHUDPanel.set_window_cover`); ürün yayına çıkmadan not hiç görünmez, Ürün penceresi açıkken de görünmez.
  Notun ikinci yeri Ürün penceresidir; Ürün ekranı koyu dile taşınırken kurulur (`product_tab.gd`).
- **Yeniden yuva listesi (PRD §5.9, §7.23).** GDD'de adı geçtiği ya da sahip tuttuğu için kalan, sprint geçişiyle
  oyun içi çağıranı kalmayan öğeler; her biri sprint ekranında bir yere bağlanır ya da sahibin kararıyla silinir:
  - Hata trendi zinciri (ch03 §8.4 yön okları; sahip): `ProductSystem.bug_trend`, `health_state`, `product_bug_risk`,
    `mvp_bug_history` penceresi; etiketleri `PROD_TREND_RISING`, `PROD_TREND_FALLING`, `PROD_RISK_LOW`, `PROD_RISK_MID`,
    `PROD_RISK_HIGH`, `PROD_HEALTHY`, `PROD_RISKY`, `PROD_FLAT`.
  - Tip ekranının kilitli üçlüsü (ch03 §12.11, GUNCELLEMELER ch14 §2): `ProductCatalog.locked_type_ids`,
    `TYPE_SCREEN` kilitli listesi, `type_sector_labels`; tür seçici yalnız oynanabilir türleri çiziyor
    (ACIK_KARARLAR 96).
  - Hat okumaları (ch03 §12.9): `ProductLines.net_gain`, `is_complete`; kapı üstü bonus (ch03 §12.8):
    `LineGates.above_gate_bonus` (yalnız smoke; çıkan kademeye damga vurulmuyor, ACIK_KARARLAR 96).
  - Altyapı ve fiyat (ch03 §10): `InfraSystem.gross_margin_monthly` (brüt marjın yüzeyi yok), `adjust_capacity` ve
    `SalesSystem.estimate_price_change` (yalnız smoke).
  - Pazar payı merdiveni (ch03 §12.11; sahip): `RivalRegistry.get_player_rank_in_startup_league`.
  - Merdiven reddi (ch03 §12.3): `ProductLines.ladder_refusal` (yalnız smoke `line_ladder_rules`; aday kartlar
    sıradaki kademeyi `next_tier`'dan okur).
  - Liderlik ve koordinasyon çıktısı (Ekip §4.2, §17.2): `HRSystem.leadership_output_mult`,
    `HRConstants.LEAD_OUTPUT_PER_POINT`, `HRConstants.coordination_for_founder` / `coordination_for_lead` ve `COORD_*`,
    `HRSystem.output_mult_for_area` (yalnız smoke; sprint puanı liderliği ve koordinasyonu okumaz, ACIK_KARARLAR 96).
  - İş ataması ve odak (Ekip §12.1): Ekip sekmesinin Yapım iş sütunu ve iki işte 0,50 odak katsayısı sprint işini
    etkilemiyor (`SprintSystem.team`, `_points`; ACIK_KARARLAR 96 (5)); `HRConstants.GROUP_PRODUCT_DESIGN` (okuyanı
    eski `capacity_total`'dı).
  - Satış okuma eşiği (Satış GDD): `SkillCheck.can_read_prospect`, `SALES_READ_THRESHOLD` (yalnız smoke; okuyanı fiyat
    paneliydi).
  - Kritik hata bayrağı: `critical_bug_unfixed` (`GameState.FLAG_TYPES`, `EvEffects.GAME_FLAG_WHITELIST`; okuyanı
    `launch()`'tı).
  - Okuyanı olmayan anahtarlar: `PROD_DEV_VERSION` (yalnız `loc_language_switch` smoke örneği), `PROD_MARKET_SHARE`
    (yalnız bir smoke yorumu anıyor).
- **Ar-Ge derin bağının `open_assign` argümanı.** `EventBus.rnd_node_requested`'ı artık yalnız Ar-Ge çubuğunun
  "ata"sı yayıyor ve hep `true` gönderiyor; Konsept'in `false` gönderen "→ Araştır" bağı silindi. Argüman sinyalden
  kalkabilir (`research_bar.gd`, `rnd_tab.select_node`).

## Ürün rev 7 kalibrasyon turu
- **Bayrakla ulaşılamayan görsel kabul yüzeyleri.** Turun görsel kabulü altı durumu repoda olmayan bir sürücüyle
  kurdu; mevcut shot bayrakları bu durumlara gelemiyor. Her biri için bir shot türü yazılır (`--product-shot=live:`,
  `--finance-shot=`, `--meeting-shot=`, `--event-shot=` ailelerinde):
  - Sözlü sprint kartı ("söz verildi" damgası, öngörüde "{müşteri} sözü tutulur") ve Satış kartındaki "Sprint N sonuna
    kadar" satırı.
  - Canlı sürümlerin Geçmiş'teki gerçekleşen satırları (iki sürüm kapanmış koşu).
  - Planlamadan sonra kapısı kapanan kart: başlatmada sonraki sütuna geçer, KİLİTLİ ve yalnız Çıkar.
  - Finans gider dökümünde Servis maliyeti satırı (canlı ürün ve B2B defteri).
  - Satış toplantısında "yer yok" gerekçesiyle kilitli söz cevabı.
  - Koşan sprintte sprint karar kartları ve B2B söz satırının iki kilidi (kırık söz, yer yok); `--event-shot`'un
    fikstür dünyasında bu kilitler doğmuyor.
- **Ürün rev 7 denetiminin plan dışı bulguları.** Kalibrasyon turu bunlara dokunmadı:
  - C-05: Penceresinde yapılabilir adım olmayan B2B talebi, adım açılınca aynı pencerenin sonraki bir tikinde doğuyor
    (ACIK_KARARLAR 96 (28) ve PRD'nin zamanlamasıyla çelişir).
  - C-07: Planlanmış düzeltme kartı, ticket sayısı acil eşiğini geçince planlama anındaki eforunda kalıyor (3 ticket'ta
    efor 1); tersi de var.
  - C-09: Öngörü durum sözcüğü değişmeyen seviye geçişini de yazıyor ("Çekirdek Yeterli → Yeterli").
  - C-10: Ücretli plan özelliklerle aynı sürümde çıkınca fiyat sürüm öncesi eksenlerden kuruluyor (~%14 düşük).
  - C-11: Müşteriler satırı betada bekleyen talep kartına "+" ve "→" gösteriyor; düğmeler bir şey yapmıyor.
  - C-13: Alan cümlelerinin alt-tür boyutu yok: her alt-tür aynı Çekirdek cümlesini okuyor (PRD §2.1 "şablon alan ×
    durum × alt-tür").
  - INT-6: Koşan kartı "Çıkar"mak atananlarını haftanın kalanında boşta bırakıyor ve yapılmış puanı HIZ satırından
    düşürüyor (`SprintSystem.remove` `_restaff` çağırmıyor).
  - INT-9: v14 göçünden sonra ilk günlük tike kadar ticket defteri boş: yüklemede düzeltme kartı ve "!" yok.
  - INT-10: Eski yapım motorunun bayrak artıkları: ölü bir bayrak türü öneki ve tek okuyucusu silinen iki beyaz
    listeli bayrak.
  - LC-9: PM kovulunca ya da izne çıkınca onaylı planları sprintleri yönlendirmeyi sürdürüyor; ÇEYREK kilitli, planlar
    görünmüyor ve geri alınamıyor.
- **Harness notları** (`scripts/debug/run_probe.gd`):
  - Botun B2B işe alım kapısı (kasa ≥ 6 × (burn·30 + 6.000 − MRR), `_hire_after_the_seed`) Traction'ın erken
    sonucunu belirliyor; `ONBOARDING_MRR_MULT` Traction düzeltmesi bu kapının etrafından dolandı (ACIK_KARARLAR 97,
    98).
  - `--event-harness=guided` yalnız `EvEngine`'i tikler: ürün türü seçilmez, sprint koşmaz; MVP öncesi ritmi ölçemez.
    Ritim probe günlüklerinden okundu.
  - Probe kurucusunun Müşteri İlişkileri'si 0'dır (`main.gd` debug yükü): masadaki kurucu doğrulama yapmaz, yalnız
    düzeltir (ACIK_KARARLAR 99).
  - Bot `rival.funding_round`'da hep ilk seçeneği alır: "bekle"nin zamanladığı `rival.price_cut` yolu hiçbir probe'da
    koşmuyor. Sensible politika `founder.side_contract`'ta hep "al"ı seçer.
  - Faz 3 giriş kartlarının (`world.analyst_guide`, `world.newsletter_slot`) ve sözün beta payının smoke vakası yok;
    ilkini yalnız probe ve lint koruyor.
  - `min_cash_pre_seed` haftalık `STATE` okumasından alınır, hafta içi dip değildir.
