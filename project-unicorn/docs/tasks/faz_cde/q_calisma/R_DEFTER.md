# Faz Q · R defteri (RAPOR_Q'nun girdisi; commit'lenmez)

## Commit'ler
| Adım | Commit | Ne |
|---|---|---|
| K0 | `beb797e` | Taban harness'i: PROBE LEAD, PROBE SIGN'a sector/arch/tol/phase/areas, PROBE AREAS, PROBE VCQ, `--tick-probe=…:accounts=<n>` |
| K1 | `d211d65` | ProductQuality (weights, emphasis, level, ratio, fit, fit_from_levels), 13 sektör tablosu, hat `profile` + `ProductLines.work_profile`; smoke product_fit_table, product_quality_sector_table, product_line_profiles |
| K6 | `1ba4a69` | Onboarding alanının TR adı İlk Kullanım ve Erişim (kısa İlk kullanım), Ar-Ge düğümü İlk Açılış Akışı (Erdem 17 Ekim onayı) |
| K2 | `9a0dff9` | Yıldız beklentisi, B2C kitle bağlamı, rakip penceresi, Customer.market_ref + set_market_ref, şema 18 (_migrate_17), SprintCatalog → ProductQuality, yıldız cümleleri, sıradaki yıldız; smoke fit_star_context, fit_account_ref, save_v17_market_ref; fikstür live:b2b_mvp, b2b_mature, b2b_quarter |
| K4v | `2af6eef` | VC ve yatırım masası alan dili: ProductQuality.weakest_area, VC_Q_WEAK_DIM `{area}`, E_FIT_PRODUCT_DIM_FLOOR silindi; smoke vc_weakest_area (paralel; sahnelenmiş ağaçta doğrulandı) |
| K5 | `f549597` | B2C taban merdiveni alanlara, sinyaller alan kimliği, urun.floor_state/floor_area/trust_level, altı kart, lint_v3_frozen, vocab + manifest; smoke floor_ladder_areas; plausibility fails=0 (paralel; sahnelenmiş ağaçta doğrulandı) |
| K4c | `fb0372f` | B2C kitle/aşınma/fiyat B2C U × 5/7 (b2c_quality, yayın öncesi 0), memnuniyet hedefi Çekirdek+Onboarding (ctx.areas), _rival_relative_quality silindi; smoke b2c_satisfaction_drifts_to_fit, b2c_audience_reads_fit (paralel; ana oturum sahnelenmiş ağaçta event_chip_coverage çökmesini yakalayıp düzeltti) |
| K3a | `3f988dc` | Satış görüşmesi U'yu okur (urun.product_fit), vurgu sorusu üç biçim, itiraz, LOSS_WEAK_AREA + geri dönüş kapısı, SalesFinalizer.lose, _migrate_17 eski stability kaybı, Kararlılık temizliği, _seed_b2b ERP K2; smoke sales_meeting_reads_fit, sales_emphasis_question, sales_weak_area_loss; shot emph_*, weak_core, die, returning |
| K8a | `75041f6d` | Ölçüm harness'i: PROBE FIT, PROBE LEAD u=/loss=, PROBE UFLUX + u_unexplained_weeks, PROBE B2C u=/aud_star=; kollar full_run_fix_worst_desk, full_run_quality_core(_desk), full_run_vc_product, full_run_b2c_vc_product (paralel; sahnelenmiş ağaçta doğrulandı) |
| K3b | `85603d5` | Satışçı zarı (close_chance, CLOSE_CURVE, lost_area), kayıp SalesFinalizer.lose + rep_deal_lost, kayıp maili haftada 1 + özet satırı, yıldız karışımı market_fit(3)÷70, 13 sektör satışta + sektör çekimi ikinci karıştırma turu, istek alanı vurgu 1, üyelik used_areas/uses_area 0,15, ölü arketip/eksen parçaları; 7 yeni smoke; shot rep_lost/weekly_lost/weekly_lost_only. Ana oturum 3 hatsız fikstürü ERP'ye çevirdi |
| K7a | `02d22dc` | Ar-Ge Tasarım sistemi indirimi iş profilini okur (step_effort, effort_of, _migrate_15), RND_DESIGN_EFFORT_MULT; İK tasarım/ürün alan anlamı metinleri; smoke rnd_design_discount_reads_profile. Ana oturum: save_v13_day_stamps_migrate (K3a'dan beri kırmızı) ERP fikstürüne göre |
| K4b | `31f962c` | B2B memnuniyet hedefi account_fit, imza tohumu adayın U'su (masa ve satışçı), area_row + WORD_TONES, PROBE REPLOSS/SAT target/FIXTURE, b2b_* preset'leri ERP; smoke b2b_account_reads_fit, product_area_row; 12 vaka hat kademesine. Ana oturum: fikstür çağıranlarının 11'i sahnelenmiş ağaçta. Tik +%60 → K9 |
| K8b | `6e33b56` | PROBE MLOSS (kurucunun görüşme/pazarlık kaybı; SalesMeetingSystem.active_lead_id ile satışçı kaybından ayrılır), _lead_fit; ölçüm betiği scratchpad/k8_tables.py (repo dışı). Paralel K7b ağacı kırdığı için kanıt HEAD kopyasında; ana oturum sahnelenmiş ağaçta lint, all_scripts_load, full_run 30 hf |
| K7b | `bd7ed53` | Eksen zinciri silindi: hat JSON eksen alanları, ProductLines/ResearchTree eksen doğrulamaları (profil şekli denetimi geldi), KANO, 1,6 kuralı, push_axes, mvp_* bayrakları (RETIRED_PRODUCT_FLAGS her yüklemede düşer), damga zinciri, above_gate_bonus, QualityModel'in ürün kısmı, QUALITY_AXES → RivalCatalog.COMPOSITE_AXES (rakip sayıları aynı), PROD_AXIS_*; PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK; smoke save_retired_product_flags, rival_composite_table, 4 silindi, 13 yeniden yazıldı. Ana oturum: sahnelenmiş ağaçta 54 vaka |
| K9d | `350ba3b` | Belge kapanışı: ACIK_KARARLAR 52 ve 59 silindi (sahip onayı RAPOR_Q'da), 10 bugünkü gerçeğe yeniden yazıldı; ISLER C-09/C-10 yeniden yazıldı, C-13 onaydan sonra silinecek; GUNCELLEMELER eksen dönemi bayat satırları; sözlük; motor md §27.39 (K3a); HARITA QualityModel → Dünya (rakip) |
| K9a | `9221d00` | E1 kararları: CORE_2 1,5, EMPHASIS_2 1; B2C ürün sayfası max(kitle yıldızı, 2★) okur (ekonomi ve taban merdiveni kitlenin kendi satırı, ctx audience); capabilities önbelleği ProductLines.memo (tik 160,7 → 134,8 ms); smoke fit_scale, 6 vaka yeni sayılarla. B2C eğri sabitleri yazılmadı (aday 24/24 tutmadı); ana oturum floor_ratios belge cümlesini düzeltti |
| K9b | `bd9a5ed` | B2C ağızdan ağıza C10 (WOM_MULT_PIVOT 233, WOM_SAT_GATE 65, WOM_COEF 0,00103; onay bekliyor); kayıt yokken iki terim yok (tuzak düzeltmesi); smoke b2c_wom_needs_satisfaction, b2c_growth_multiplier_floor yeniden yazıldı; eğri 19/24 |
| K9c | `910ad1f` | 2★ Çekirdek beklentisi CORE_2 1,5 → 1,25 (Erdem, kapanış ölçümünden sonra); smoke fit_star_context, product_area_row, floor_ladder_areas yeni sınıra (1,2 Zayıf / 1,4 Yeterli); HARITA onay bekleyen listesinden CORE_2 çıktı |

## Q0b taban bulguları (`Q0b_TABAN.md`)
- Bugünkü ürün, yeni formül: imzalarda U = 100 payı bütün imzalarda %68-77, 2★+3★'ta %36-59 (kapı ≤ %25). Traction U ortancası
  bütün imzalarda 99-100, 2★+3★'ta 72-77 (kapı 70-85; 2★+3★ satırı bugün zaten bant içinde).
- 3★ imzalarda Traction U ortancası 35-62: botun ürününde İlk kullanım hep 0 (mobil hat yapılmıyor), Series A Avı'nda 1.
- Satışçı kapanışı: 20 koşuda `by=rep` 0. Bot kurucusu her adayla görüşüyor; temsilciler (65. haftada 5 kişi) aday almıyor.
  Karar 14'ün satışçı zarı kapıları bu botla ölçülemez → K8: botun temsilcilere aday bırakması (harness, ayrı raporlanır).
- VC "zayıf alan" sorusu: hiç gelmiyor (`weak_dim` 0); cautious bot ürün fonuna (Meridian) oturmuyor. Kapı (≤ 3) önemsiz tutar → K8.
- B2C: kitleden gelen haftalık U kayması en çok 12 (kapı önerisi ≤ 5); 1.000/10.000/50.000 log-doğrusal geçiş dik → E1.
- Aday yıldız karışımı: Series A Avı'nda 3★ payı ~%15.
- Sprint probu: b2c 191/199, b2b 155/162 eşleşme; bütün uyuşmazlıklar adlı (cause=team/team.burnout/kâğıt).
- Tik: tempo dünyası gece karesi ortanca ~20,5 ms; 330 hesaplı dünya ~141 ms (3 koşu ortanca). §4.6'nın tabanı 141 ms.
- `fix_due` kolu üyelikten (`uses_axis`) okur; K3b'de üyelik değişince bot politikası da kayar → E1'de birincil kollar fix_worst ve fix_none.

## Adım notları
### K0
- PROBE AREAS rakip sayımı pencereli; bugünkü `SprintCatalog.expectation` penceresiz sayıyor (PRD §0 madde 3).
- `_log_vcq` `VCPitchSystem._weakest_dimension()`'ı okuyor → K4'te `weakest_area`'ya taşınır. `main._seed_accounts_state`'teki
  `mvp_*` satırları K7'de silinir.
### K1
- Sözleşme adları: `ProductQuality.weights(market, sector)` (sıra core, v1, v2, kalan; yarım puan hücreleri bu sıraya bağlı),
  `emphasis(sector)`, `level(area)`, `ratio(area, expect)`, `fit(ctx)` → {value, match, capped, weakest_emphasis, loss_area,
  note [{area, word}], label_key}, ctx = {market, sector, ref}; `fit_from_levels(levels, ctx)`; `ProductLines.work_profile(line)`;
  `ResearchTree.hidden_line_profile(id)`.
- Onay bekleyen: `RATIO_CAP` 1,5; `TABLE.textile`, `TABLE.media`. Onaylı (işaret kaldırıldı): `CORE_LEAD` 0,25, `W_CORE`, `W_B2B`, `FIT_SCALE` 70.
- PRD düzeltmesi: Karar 5 `match` aralığı "0,0-1,43" değil "0,0-1,5 (U 1,43'te 100'e varır)".
- `label_key` = mevcut `SALES_MOD_PRODUCT_FIT` (küçük harf "ürün uyumu"); büyük harf kararı K3a'da.
- K2'ye: `level()` `SprintCatalog._raw_level`'i okur, K2 gövdeyi taşır (run_probe.gd:539, :673 de okuyor). fit ref'te core ister.
### K6
- GDDs/GUNCELLEMELER.md:212 alanı hâlâ "Onboarding & Erişim" diye anlatıyor → K9 belge işi. ACIK_KARARLAR.md:1203 K9'un.
- Satış'taki SALES_CHIP_ONBOARDING (:139) ve SALES_ONBOARDING_ENDS (:148) bilerek değişmedi (C8; "onboarding" artık TR'de yalnız
  hesabın ilk haftaları). Ar-Ge düğüm detay kartı ekranla doğrulanmadı (--rnd-shot'ta onboarding_flow'u seçen tür yok).
### Süreç
- 2026-10-18 ~20:00: K6 commit'i sonrası otomatik `git gc` bellek baskısında biçildi (commit sağlamdı). Erdem'in onayıyla
  `git gc` ön planda koşuldu (52 → 2 paket, gevşek nesne 0); yarıda kalan gc'nin 3,8 GB'lık `tmp_pack` çöpü silindi. Bundan
  sonra commit'ler `git -c gc.auto=0 commit`.
### C ve D'nin RAPOR_Q'dan istedikleri (haberleşme, 18 Ekim)
- C (project-unicorn-12) ve D (project-unicorn-48) sözleşmesi: Q bitince "Q bitti, son commit <sha>, RAPOR_Q var, ❌ var/yok";
  ağır iş başlarken ve bitince üç oturuma tek satır; aynı anda tek ağır iş.
- D: (1) `level` biriminin tek satırlık tanımı (derinlik kartı kazancı için): seviye = alanın hatlarının (kademe + cila) ortalaması,
  1 = her hattın K1'i yayında; (2) `area_row`'un son imzası. D1 profili `ProductLines.work_profile` / `ResearchTree.hidden_line_profile`'dan
  okur; D8a önerisi `ProductQuality.next_star` / `next_ratio`'yu okur.
- **Sözleşme açığı:** Karar 5'in `area_row(area)` ({area, word, tone, sentence, squares 0-10, faint_from 8}) henüz yok → K4'te
  yazılır (smoke ile). K9 sözleşme tablosunun bütün fonksiyonlarının var olduğunu doğrular (close_chance, market_fit, uses_area K3b).
### K2
- Onay bekleyen sabitler: `CORE_2` 1, `CORE_3` 2, `EMPHASIS_3` 1,5, `REST_3` 1 (hesaplanan: 1★ Çekirdek = mvp_lines ÷ hat, 2★ vurgu
  = 1 ÷ hat); `AUDIENCE_STARS` [1000, 10000, 50000]; `PAGE_STAR` 2; rival_bump/max/window anlam değişti (aday ve ekonomi bağlamı,
  çıkış kaydı başına, pencere sprint cinsinden); Gelir sözcüğü B2C vurgu sütunu, üst kademede kesik.
- Onay bekleyen kurallar (PRD'de yok): B2C'de U iki komşu yıldız satırının U'sunun kitle payıyla karışımı (eşikte sıçramaz;
  fit_star_context %2 kitle adımında ≤ 1 puan); B2C ürün yayından önce alan cümlesi yazmaz (Opus incelemesi).
- Metinler (TR/EN onay bekliyor): PRODUCT_STAR_NONE, _SKIPPED, _SERVES, _TOP, PRODUCT_AUDIENCE_ENOUGH, _OUTGROWN. 19 eski alan×söz
  cümlesi silindi (alanlara özgü tat yitti: "Veri elle taşınıyor" vb.) → E1/Erdem'e not.
- **E1'e (kare: k2mine b2c_live):** B2C kitle 1.000 altındayken Çekirdek dışı beklenti 0 → tek K1 "Güçlü", Çekirdek "Yeterli";
  sürüm notunda "Beklenen: Büyüme Güçlü olmalı". PRD'ye harfiyen uygun, oyuncuya şişkin. §10 kalan soru 1 ile birlikte sorulur
  (öneri: B2C sözcüğü en az 2★ satırına göre).
- Açık risk: Ar-Ge gizli hattı İlk kullanım'ı iki hatlı yapınca hesabın donuk market_ref'i (1,0) yenilemeye kadar kalır → hesap
  U'su nedensiz düşer (K4 bağlayınca görünür). Çözüm C'nin ya da K4'ün (gizli hat açılışında referansı yeniden kopyala).
- account_fit hesap başına 4 beklenti + 2 fit_from_levels; 330 hesap × tik ölçülmedi (taban 141 ms) → K4/K9.
- Kayıttan dönen market_ref int değer taşıyabilir (SaveCodec); karşılaştırma sayısal yapılmalı.
- Kart etkisi "Çekirdek Zayıf kalır" ile sol panel "Yok" çelişebilir (sözcük ham, kare yuvarlanmış) → C-09'un kardeşi, K9/Erdem.
- ISLER C-09 açık; C-13 konusunu yitirdi → K9 kapanış satırı. `_migrate_17` adı zincir adlandırmasına uymuyor (bilerek).
- Sözleşme (K2): prospect_fit(p), account_fit(c) → +market_value, fit(ctx), fit_from_levels, expectation(area, ctx), word(area, ctx),
  word_for, serves(area), next_star(), next_ratio(area, star), market_ref_for(star, sector, subtype), level(area, tiers);
  CustomerRegistry.set_market_ref(id, ref); SprintCatalog.recent_hits, display_level, max_tier, capabilities(area, subtype).
- Süreç: Haiku kapısı yarıda kesildi; ana oturum bağımsız kapıyı koştu (sprint probu 191/199, 155/162 birebir; full_run/b2c 30 hf
  temiz; 45 hedefli vakanın hepsi PASS, son üçü ön planda; 10 kare). Arka plan smoke bellek baskısında bir kez biçildi.
### Süreç: paralel parti (19 Ekim, Erdem: "diğer steplerini de paralelde başlatsana")
- K4 üçe bölündü: **K4v** (VC + yatırım masası + weakest_area; ACIK #59, #10 metni), **K4c** (B2C kitle, memnuniyet, fiyat; ctx.areas),
  **K4b** (B2B ara bağ + area_row; K3b'den sonra). Paralel parti: K3a ∥ K4v ∥ K4c ∥ K5 (bağımsız dosya kümeleri; ortak dosyalarda
  yalnız kendi satırı, aynı anda ≤ 2 Godot, class_name yok, own_markers → parça düzeyinde commit, `stage_step.py`). Sonra K3b → K4b →
  K7 → K8 (harness) → ölçüm → E1. K3a eski (paralelsiz) kurallarla başlamıştı.
- Commit doğrulaması: her adımın sahnelenmiş ağacı `git checkout-index --prefix` ile ayrı dizine çıkarılıp all_scripts_load ve
  adımın vakalarıyla koşulur (öbür adımların sahnelenmemiş değişikliklerine dayanmadığı kanıtlanır).
### K4v (onaylı, commit bekliyor)
- `ProductQuality.weakest_area(ctx = {})` (ctx.areas yoksa U'nun alanları, Gelir girmez). VC ürün fonu sorusu ve seed how_big
  weakest_area'dan; `_weakest_dimension` ve E_FIT_PRODUCT_DIM_FLOOR (40) silindi; E_FIT_PRODUCT_DIMS (+4) anlamı değişti
  (yayındaki ürünün sayfasında eksik alan yok) → sabit onay bekliyor. Metin: VC_Q_WEAK_DIM `{area}`, _MONO "En zayıf alanı bulacak."
- **E1'e:** MVP'den sonra B2B Çekirdek 0,6 < 1 (2★ referansı) → seed how_big ve Series A weak_dim Çekirdek 1'e varana kadar hep
  açık, masa +4 o zamana kadar yok (Q0'ın K4 sorusu gerçekleşti). Ürün yokken weakest_area "" → seed sorusu clean.
- Bayat kalan: GUNCELLEMELER.md:310 (_weakest_dimension, ACIK 59) → K9; ProductCatalog.axis_label, PROD_AXIS_* CSV (smoke
  :11627 okuyor) → K7. TR sorgu ekranında "Odayı oku — karşındakini tart." satırında tire var (K4v'nin değil, ayrıca bakılmalı) → K9/rapor.
- HARITA ProductQuality satırındaki weakest_area sözü K4c/K5 commit'iyle girer (aynı satır).
### K5 (onaylı, commit bekliyor)
- Merdiven: ProductRead.floor_ratios/floor_state/worst_floor; FLOOR_WARNING_RATIO 0,6, FLOOR_CROSSED_RATIO 0,4 (onay bekliyor);
  sinyaller axis_floor_warning(area)/crossed(area); phase_bar_raised silindi; seam'ler urun.floor_state ('' | warning | crossed),
  urun.floor_area (PRODUCT_AREA_*_SHORT), urun.trust_level (float, yarım adım; kapı == 0) → "seviye 0" tanımı onay bekliyor.
- Metinler: floor_signal "Son yorumlar hep {seam:urun.floor_area} tarafına dönüyor." (ikinci cümle "Henüz bu yüzden giden
  olmadı" düştü); floor_churn "Ayrılış anketi iptallerin sebebi olarak {seam:urun.floor_area} tarafını gösteriyor." (TR/EN onay bekliyor).
- **E1'e:** seviyesi 0 olan alan, kitle 1.000'i geçince beklentisi 0'dan yükselir ve oranı 0 → doğrudan crossed; uyarı kartı
  atlanır, churn kartı uyarı geçmişi istediği için hiç gelmez; shutdown_notice ve b2c_creator_feature o alan kurulana kadar susar.
  44 plausibility koşusunda iki taban kartı hiç ateşlenmedi ("sıklık bugünküyle aynı" ölçülmedi).
- PRD düzeltmeleri: §3.5 `{area}` → `{seam:urun.floor_area}`; lint_v3_frozen elle tutulur (iki kart çıktı); urun.product_fit olay
  motoruna kayıtlı değil (açık iş, gerekirse K9).
### K4c
- **E1'in birincil sorusu:** B2C kitle eğrisi tabanın çok üstünde: full_run_b2c:52:7 hf26 6.166 (taban 754-1.231), hf52 189.188
  (taban 4.343-7.965); MRR hf52 1,36 M$; Series A kapısı hf34. Nedenler: Deneyim tuzağı kalktı (memnuniyet 14 → 78-82, WOM hf19'dan
  beri ~%10/hafta) ve rakibe göre aşınma kalktı; PRD'nin "beklentide 50 = bugünkü başa baş" varsayımı tutmuyor (tabanda q 12,6 / 28,8).
  Duyarlılık (ayrı kopya): WOM_SAT_GATE 60 → hf52 32 bin; 75 → 20 bin; WOM_COEF ÷3 → 24 bin; B2C_QUALITY_PER_FIT 0,5 → 94 bin;
  EROSION_THRESHOLD 40 etkisiz; kapı 60 + eşik 40 → 34 bin. Hiçbir tek sabit tabana indirmiyor; birincil kol WOM ailesi. §4.4 "%20 sapar" tutmaz.
- Onay bekleyen: B2C_QUALITY_PER_FIT 5/7; anlamı kayan WOM_SAT_GATE 30, WOM_COEF, WOM_MULT_PIVOT, EROSION_THRESHOLD 25, CHURN_COEF,
  VALUE_QUALITY_COEF (kalite terimi 0-71, memnuniyet hedefi 70-100).
- Ana oturum düzeltmesi: ürün yayında değilken b2c_quality() 0 (seam'ler yayın öncesi de okur, fit boş referansla çöküyordu).
- K7'ye ölü: QualityModel.normalized_quality_rival, RIVAL_TEMPLATE_HALF_SAT, shipped_normalized, shipped_composite (smoke
  quality_half_sat_25 okuyor); _seed_tempo_state mvp_* satırları. K9: GUNCELLEMELER.md:262 "B2C memnuniyeti deneyim ekseni puanına kayar".
- run_probe b2c_neglect açık hataları FIXTURE_BUG_LINE (line_erp_ledger) üstüne koyuyor, ürün note_tool (önceden de vardı) → K8.
### K3a
- Onay bekleyen: EMPHASIS_ANSWERS deltaları (a_strength 1,0 / a_admit 0,35 / a_charisma 0,8, eski kararlılık satırından devralındı);
  davranış: eksik alan varsa kayıp nedeni hep weak_area (provider_trust, missing_tier, switching_risk'in önüne geçer).
- Metinler (TR/EN onay bekliyor): SALES_MEETING_OBJECTION, SALES_PROBE_PROBE_EMPHASIS_*, SALES_ANS_PROBE_EMPHASIS_A_*, SALES_LOCK_EMPHASIS_ENOUGH,
  SALES_LOCK_ONBOARDING_ENOUGH, SALES_LOSS_WEAK_AREA, SALES_MEMORY_WEAK_AREA, SALES_ARCH_OPS_CAUTIOUS_LINE; ajanın yazımı:
  SALES_REASON_STABILITY ("ürün yeterince güvenilir değil (Güven & Ölçek)"), PROD_TYPE_ERP_TRADEOFF, PROD_PATH_B2B_DESC,
  PROD_RND_NODE_BUG_TRACKER_UNLOCK. Zar ipucu küçük harf "ürün uyumu · Çekirdek Zayıf" (öbür zar satırları gibi); PRD büyük harf → soru.
- Kalan: 1★ adayda vurgu alanı beklenmiyor ve seviye 0 ise sözcük "Yok" → güçlü cevap kilitli, geri dönüş kapısı kapalı (PRD harfiyen) → E1.
  Kayıp alanı tavan dışında en düşük oranlı alan (MVP'li üründe 3★ Finans Güven'i söyler). last_loss_reason ve returning olguları ölü → K7.
- K3b sözleşmesi: SalesFinalizer.lose(lead_id, account, reason, target, lock_weeks); SalesLedger._blocker_cleared(p); memory_line.
- C/D: ProductQuality.is_enough(area, ctx), prospect_ctx(p).
### Süreç
- Paralel parti K3a ∥ K4v ∥ K4c ∥ K5 dört ayrı commit oldu (parça düzeyinde ayrım; her biri sahnelenmiş ağaçta doğrulandı).
  Sonraki paralel parti: K3b ∥ K8a (harness). HR_AREA_MEANING_*_DESIGN ("Deneyim ekseninin tavanı") → K7.
### K8a
- Masa kolu (desk): temsilci varken kurucu yalnız temsilci bandının üstündeki adaylarla görüşür → 60 haftada 48 satışçı imzası (Q0b'de 0).
- **E1'e:** quality_core kolu kendini besleyemiyor: Çekirdek K2 kartları kişi yıldızıyla kapılı, lider yalnız Çekirdek kartı alınca
  sprintler hf15'ten sonra fix + research'e iniyor, Çekirdek 1,2'de kalıyor; 40 hf'de MRR 23k → 7k, 43 churn, satışçı alınmıyor.
  §4.5 "Karar var" (quality_core vs fix_worst 2★/3★ U farkı ≥ 10) ve "3★ aday payı farkı ≥ 5" bu kolla anlamlı mı → Erdem.
  core_only süzgeci talep kartlarını da çıkarıyor.
- VC ürün fonu kolu: weak-area cümlesi koşu başına 2 (kapı ≤ 3); B2C kolunda Meridian clean soruyor.
- UFLUX 104 hf'de nedensiz 0, yenileme dalı hiç tetiklenmedi (bugünkü tabloda ref aynı); Ar-Ge gizli hattı açılırsa unexplained beklenir.
- Satışçı kaybı satırı yok → K4b (K3b sinyaline bağlanır). Kıyas deseni: FIT/UFLUX satırlarını at, LEAD/B2C/END kuyruklarını kırp.
- K3b yarım kodu: hatsız saas_ops fikstürleri (b2b_solo/risk/reps/slip) market_fit yolunda çöküyordu → K3b'de kontrol.
### K3b
- Onay bekleyen sabitler: CLOSE_CURVE (U ≤40 %30 · 55 %60 · 70 %85 · ≥80 %95), QUALITY_STRENGTH_HIGH 1,6 → 1,0 (LOW 0,6 aynı).
  SALT_REP_CLOSE 449 yalnız tuz. USE_AREA_MIN 0,15 Erdem onaylı.
- Metinler (TR/EN onay bekliyor): SALES_REP_LOST_TITLE, SALES_REP_LOST_BODY, SALES_WEEKLY_LOST (§3.4 birebir).
- Sunum kararları (PRD sessiz): masadaki kurucunun kaybı mail değil özet satırı; yalnız kayıplı haftada defter satırı kayıpların
  üstünde; Temsilciye ver geri dönüş kapısı kapalı lead'de kapalı (Opus düzeltmesi, route_block_reason).
- **E1'e:** zar hedefi tutmuyor: tohum 7, 104 hf fix_worst_desk 1/112 (%0,9), quality_core_desk 2/27 (%7); hedef %5-15 ve ≥%20.
  Eğri sertleşmeli ya da kayıp alanı geniş okunmalı.
- **RAPOR_Q'ya:** sektör çekimindeki gizli hata düzeldi (tek tur karıştırmada finance_brisk'e Sigorta ve Hukuk hiç gelmiyordu);
  aday akışı bütün tohumlarda kaydı, Q0b/K0 tabanıyla bot kıyası geçersiz (K3a'dan beri zaten kaymıştı).
  Sprint probu adlı uyuşmazlık 7 → 10 (team, team.burnout, product.sprint_dev_backfill; dünya kayması), adsız 0.
  Tik: açık hatalı 330 hesapta account_bugs 9,1 → 12,0 ms, star_mix_now 0,2 → 2,4 ms (+%3-5; K9 tik kapısında sınırda
  ise used_areas'ı sektör başına önbellekle). ProductRead.market_floors silindi (K7 listesinde yoktu); axis_reading ve market_word K7'de.
  brifin `_stamp_keys` maddesi geçersizdi (yalnız _migrate_14 koşar).
- Sözleşme (C/D): close_chance(p), SalesRepSystem.lost_area(lead) (C'nin imza kapısı buraya zardan önce), rep_deal_lost(rep_id,
  prospect_id, area), rep_deal_closed(rep_id, customer_id); meeting_lost masa kaybında da ateşlenir (rep_deal_lost ile ayır);
  used_areas(sector), uses_area(sector, area), market_fit(star), SalesLedger.repitch_blocked/record_loss/lost_week; mesaj türü
  sales_loss {rep, company, area}; bayraklar sales_weekly_loss_rows, sales_loss_mail_day.
- Ana oturum taraması (hatsız alt türü kuran 58 vaka): 11 düştü (b2b_cs_escalation_refuse, event_history_names_survive, 9 seed_*:
  market_fit 'core' çökmesi) → üç fikstür ERP'ye, 11 yeşil. run_probe b2b_solo/reps/risk/slip (saas_ops) ilk günlük tikte çöker,
  hiçbir kapıda yok → K4b. main.gd _run_b2b_shot (ai_vector_search), _run_finance_shot / _seed_rnd / _seed_theme_surface (saas_ops)
  günlük tik koşarsa aynı çökme → K4b görsel kabulünde bak.
### Süreç (19 Ekim, K3b sonrası)
- Paralel parti 3: K4b (B2B ara bağ, area_row, PROBE REPLOSS, b2b_* preset'leri ERP'ye) ∥ K7a (Ar-Ge indirimi profile, HR tasarım
  alanı metni). K7 ikiye bölündü: K7a K4b'den bağımsız; K7b (geniş eksen silmesi) K4b'den sonra.
- K8 harness'inde kurucu kaybı satırı yoktu (§4.5 "açıklanmış kayıp" ölçülemezdi) → K8b (PROBE MLOSS + k8_tables.py), K7b ile paralel.
  Ölçüm koşusu scratchpad/k8_run.sh (15 kol × tohum 7, 11 × 104 hf, sprint probları, tik probları Q0b'nin iki tanımıyla).
### K7a
- Metinler (TR/EN onay bekliyor): HR_AREA_MEANING_PRODUCT_MANAGER_PRODUCT, _PRODUCT_MANAGER_DESIGN, _DESIGNER_DESIGN, _DESIGNER_PRODUCT.
- **RAPOR_Q sorusu:** on HR_AREA_MEANING_* anahtarının oyunda okuyucusu yok (HRConstants.role_area_meaning'i yalnız smoke okuyor;
  okuyucu Ekip rev 11 Faz 5b'de kalkmış). §8 siler, bir ekrana bağlanırsa kalır; Erdem'in kararı. Görsel kabul bu yüzden yok.
- Eşdeğerlik: 19 hat + 4 gizli hatta experience ⇔ design birebir; sprint probu 156/166 aynı.
- K7b'ye: experience_effort iç adı, PROD_DESIGN/ITER_CEILING_NOTE, PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK. K9'a: Ar-Ge GDD §4.4 (docx)
  "Deneyim ekseni" diyor → GUNCELLEMELER girişi.
- **Süreç dersi:** K3a'nın ortak fikstür değişikliği (_seed_b2b ERP) save_v13'ü kırdı ve K3a'nın hedefli kapısı görmedi; K3b ve K7a'nın
  hatsız fikstür taramalarında çıkan 14 vaka da aynı sınıf. Ortak fikstür değiştiren dilimde fikstürün bütün çağıranları koşulmalı.
### K4b
- Sözleşme (C/D): B2BSalesSystem.satisfaction_target(c) = account_fit(c).value − hesabın hatlarındaki açık hata bedeli + trust_offset
  (taban, kayma, ceza aynı); SalesSystem.signing_satisfaction_seed(prospect) = prospect_fit.value (taban tol + 10, en az 50 kalır;
  masa ve satışçı aynı tohum); ProductQuality.area_row(alan) = {area, word, tone, sentence, squares 0-10, faint_from 8}, WORD_TONES
  (pos/neutral/warn), okuyan ekran yok (C çizer). PROBE REPLOSS (day hour id phase sector star u capped loss), PROBE SAT target =
  defterin ortalama uyumu, PROBE FIXTURE (hata açık/kapalı hedef çıtaya karşı; niyet tutmazsa PROBE ERROR).
- **E1 / C3a'ya (ölçek çarpışması):** çıtalar 1★ 33-36, 2★ 47, 3★ 51; U MVP'de 1★ 70 / 2★ 23 / 3★ 10, her hat K1'de 100 / 76-80 / 43,
  her hat K2'de 100 / 100 / 83. Zayıf ürünle imzalanan 2★ ve 3★ hesap tabanla açılır, 4 hf sonra Risk'e girer (fix_worst_desk 60 hf
  tohum 7: gün 27'de 3★ hesap sat 43 / tol 51 churn). Değeri aynı, ölçeği değişen sabitler onay bekliyor: TOLERANCE_BASE 33,
  TOLERANCE_PER_SCALE 9, SECTOR_TOLERANCE_BONUS, SIGNING_SAT_OVER_TOL 10, SIGNING_SAT_MIN 50, B2B_BUG_SAT_PER 0,3, B2B_BUG_SAT_CAP 20,
  ONBOARDING_GRACE_MARGIN 2.
- **K9 tik kapısı ❌ (şimdilik):** 330 hesapta gece tiki 98,7 / 88,4 / 105,9 → 158,9 / 147,5 / 163,5 ms (+%60). account_fit 175 µs/hesap,
  maliyetin ~%75'i SprintCatalog.capabilities (hesap başına 8 çağrı). Öneri: capabilities önbelleği (alan × alt tür; ProductLines.reload
  ve register_runtime_line'da düşer) + gece başına bir seviye hesabı. 40 hf full_run'da 62 hesap ≈ 11 ms.
- E1'e: satışçı kaybı fix_worst_desk 60 hf 1/39 (%2,5), K3b bulgusuyla aynı yön.
- RAPOR_Q'ya: Inbox.risk_reason hata kapısı altında güven defteri ≥ 0 iken hâlâ "Güven & Ölçek" diyor, hesabın düşük uyumu başka
  alandan olabilir (mekanizma C'nin). area_row beklentisi 0 olan alanda kare 0 ama word_for "Güçlü" (C'nin çizim kararı).
  risk_exit_stamps_day uyum terimine duyarsız (yalnız sağlıklı ürün ister).
- Ana oturum: ortak fikstür çağıran kapanışı (scratchpad/callers.py; _seed_b2b, _seed_risk_account, _seed_b2b_lines) 149 vaka;
  K4b taraması 138'ini koşmuştu, kalan 11'i sahnelenmiş ağaçta koşuldu.
### K8b
- Sözleşme: PROBE MLOSS day hour id sector star phase reason target u capped loss (u/capped/loss '-' hatsız üründe); RunProbe._lead_fit.
- k8_tables.py notları (E1 okurken): §4.4-4 ve §4.5-5'te Q0b'de karşılığı olmayan kollar (_desk, quality_core, vc_product)
  BASELINE_ALIAS ile fix_worst / vc_cautious tabanına bağlanır, kıyas iki değişkenlidir; §4.4-5 "mail" üst sınırdır (REPLOSS
  kurucunun masa kaybını da sayar); §4.5-3 "zayıf alan" yaklaşık (o hafta bir 2★ adayın loss alanı); §4.5-4 capped kayıpların
  Çekirdek payı MLOSS'ta target'tan, REPLOSS'ta loss'tan okunur.
- Örnek (fix_worst_desk 60 hf tohum 7, tek koşu): U=100 payı %34,0 (2★+3★ %13,2), Traction imza U ortancası 76 (2★+3★ 68),
  ilk 12 hf 2★ aday U ortancası 58, satışçı kaybı %2,5, sektör farkı ortancası 17, vurgu 1 zayıf alan farkı 22,5, MLOSS weak_area
  %54,8 fiyat %28,6, nedensiz U haftası 0.
### K7b
- Metin (TR/EN onay bekliyor): PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK "Mobil & Erişim hattının son kademesi ve ürünün kendi tasarım
  kademelerinden biri. Tasarım ağırlıklı kademeler artık daha az efor istiyor, çünkü onları hazır parçalardan kuruyoruz." / EN aynı.
- Onay bekliyor (Karar 1, 11): damga zinciri ve kapı üstü bonusunun gerçekleşmeye etkisi; UPGRADE_RATIO_MIN 1,6 ve yükleme denetimi;
  PHASE_BAR 12,0/13,2/14,5, BASELINE_LINES_PER_AXIS, EMPTY_AXIS_PENALTY 0,6, READING_MIN/MAX, NORMALIZE_HALF_SAT 25,
  RIVAL_TEMPLATE_HALF_SAT 50, KANO_COEF. GUNCELLEMELER: "Ters çevrilme yasağı", §11.3, yeni §11.2 "Okuma zinciri", Ar-Ge §4.4.
- §4.1 sayımı: on belirteç + push_axes + JSON eksen alanı → 2 satır (save_codec.gd:25 RETIRED_PRODUCT_FLAGS ve
  endgame_smoke fikstürü; PRD §4.1 "kayıt göçlerinin eski alan adları" istisnası). Geniş desen: rakip modeli, İK deneyim çubuğu,
  eski göçler, chips.gd EFFECT_AXIS (morale çipinin ad yuvası), axis_floor_* sinyal adları (Karar 12 korur).
- **RAPOR_Q sorusu:** Frank anahtarları PROD_TIP_WEAK, PROD_TIP_GOOD, PROD_DESIGN_CEILING_NOTE, PROD_ITER_CEILING_NOTE okuyucusuz ve
  eksen dili taşıyor ({axis}, "İnovasyon {inn}"); ACIK_KARARLAR 43 gereği silinmedi. Sil mi, yeniden yaz mı? Erdem'in.
- **Rakip modeli de elden geçmeli:** Rival.composite(), COMPOSITE_AXES, composite_quality, DEFAULT_AXES üretimde okunmuyor (yalnız
  rival_composite_table). Aynı türden okuyucusuz: LineGates.speed_bonus_for + ABOVE_GATE_* (GDD §12.8, D'nin), ResearchTree
  hidden_line_ids/hidden_line_profile (yalnız smoke).
- K9'a bayat belge: GUNCELLEMELER ~262 (B2C memnuniyeti "deneyim ekseni"), ~311, Ekip "Kaldıraç tablosu" ~700; glossary
  "Kararlılık (monitör)" (C'nin başlığıyla); ACIK_KARARLAR #52 kapanış satırı; HARITA Ürün sahip listesinde QualityModel → Rakip.
- Fikstür kayması: tema tohumu, finans ve Ar-Ge kareleri ERP hatlarıyla (Finans pazar payında ERP rakipleri). --tab-shot=product
  tema tohumunda HEAD'de de kırık (tür seçilmemiş, sprint durumu yok): ayrı iş.
- Kanıt: full_run 30 hf bayt-aynı, SHIP eksen alanı ve MLOSS ayıklanınca HEAD ile 1025/1025; sprint probu b2b 156/166 (adlı 10),
  b2c 212/220 (adlı 8) HEAD ile bayt-aynı.
- D'nin cevabı (19 Ekim): LineGates.speed_bonus_for ve ABOVE_GATE_* D'de bağlanmıyor (D'nin hızı yalnız Y(s) eğrisi; bağlansa aynı
  Yazılım yıldızı hızı iki kez artırır). Kod CLAUDE.md §2 gereği yerinde; D bunu RAPOR_D'ye ⚠️ ve ACIK_KARARLAR'a ayrılık satırı
  olarak yazıyor. RAPOR_Q'da yalnız atıf: "okuyucusuz, D'nin kararıyla bağlanmadı".
### K8 ölçümü ve E1 (19 Ekim)
- HEAD bd7ed53'te scratchpad/k8_run.sh: 30 bot koşusu + 2 sprint probu + 6 tik probu, hepsi exit 0, PROBE ERROR 0 (koşu ~60 sn).
  Tablolar q_calisma/K8_TABLOLAR.md, tanı K8_TANI.txt, durak belgesi E1_OLCUM.md. Tik kıyası Q0b tabanına göre (141,1 → 157,2 ms,
  +%11); K4b'nin "+%60"ı K3b HEAD'ine göreydi.
- E1'de Erdem'e dört soru: kapı kapsamı 2★+3★, 2★ satırı (CORE_2 1,5 + vurgu tam 1), imza düşüşü kabulü, B2C eğrisi tabana + §10 soru 1.
- E1 kararları (Erdem, 19 Ekim): kapsam 2★+3★; CORE_2 1,5 + 2★ vurgu tam 1; imza düşüşü kabul (kapı %55-65); B2C tabana çek, kitleye
  bağlı, B2C sözcüğü en az 2★. Kapsam sorusunu anlamadı: RAPOR_Q'da ve son mesajda sade anlatım (ne idi, nasıl değişti, şimdi ne).
  İkinci tur (beklentisi 0 alan Yeterli sayılsın, taban merdiveninde önce uyarı) onaysız → RAPOR_Q onay bekliyor.
### K9d
- RAPOR_Q'ya: 52 ve 59'un silinmesinin sahip onayı; #59 artığı (MVP sonrası Çekirdek 1'e varana kadar VC weak_dim açık, Meridian +4 yok;
  E1 bilgisi); C-13 onaydan sonra silinir (yerine gelen PRODUCT_STAR_* TR/EN onay bekliyor); C-10'un %14 ölçüsü eksen dönemine ait,
  yeniden ölçülmedi. Dokunulmayan bayatlar: ACIK_KARARLAR #39 (SALES_REASON_STABILITY "ürünün kararlılığı"), #45
  (QualityModel.economy_dims_from_flags), #96 (above_gate_bonus). Motor md §27.36-38 ve GUNCELLEMELER K7b girdileri izlenmeyen
  PRD_FAZ_Q_KALITE.md'ye atıf yapıyor (CLAUDE.md §13 gri alan, sahibe sor).
### K9a
- E1 sonrası B2B tek ölçüm (scratchpad/k9a/b2b_tables.md; fix_worst, fix_worst_desk, quality_core, quality_core_desk × 7, 11 × 104 hf):
  2★+3★ U = 100 payı %45 → %0 (masalı %26,7 → %0) ✅; Traction imza ortancası 2★+3★ 72 (masalı 67, bant 70-85) ✅/⚠️; MVP sonrası
  26 hf imza ÷ Q0b %61,2 (masalı %60,6) ✅; nedensiz U 0 hafta ✅; sektör farkı 18, vurgu farkı 28 ✅; açıklanmış kayıp %74,8 (2★+3★ %100) ✅.
  **Bedeller ❌:** Traction ilk 12 hf 2★ aday U ortancası 60 → 45 (hedef ≥ 48); masalı fix_worst satışçı kaybı %0,3 (1/312; 2★+3★ %1,7;
  hedef %5-15); quality_core_desk %10,1 (2★+3★ %54,8 ✅). C'nin girdisi: imzada U < tol + 10 fix_worst 2★ %17,5, 3★ %50 (n = 10).
- Yan etki (Erdem bilmeli): 2★ vurgu tam 1 → Ar-Ge gizli hat açınca alanın beklentisi inmez, seviyesi (boş hat) yarıya iner, 2★ U düşer.
- B2C sayfa referansı küçük kitlede 2★: MVP Çekirdek "Zayıf · Kitlen büyüdükçe kullanıcılar bu alanda daha fazlasını ister" (672
  kullanıcıda da; "büyüdükçe" biraz ileriyi söylüyor, metin notu). VC weakest_area ve yatırım masası da sayfa referansını okur (PRD
  satır 259) → küçük kitlede az alanlı B2C ürün zayıf sayılır, masa +4'ü yok.
- PRD düzeltmesi: Karar 12 "oran ürün sayfasının referansına göredir" → "kitlenin kendi referansına" (E1 sayfayı 2★'a tabanladığı için ayrıştı).
- Ayrı iş (ISLER adayı, motorda doğrulanmadı): `ProductLines.reload()` çağrısı GDScript'in Script.reload'una gidiyor olabilir (gövde ölü,
  statikler yeniden ilkleniyor); memo iki yolda da boşaldığı için zararsız.
- B2C aday araması (10 küme, scratchpad/k9a/cand_tables.txt): başlangıç 0/24 (hf52 +%246..+%3339); C10 233/65/0,00103 17/24 (en büyük
  %63); C6 16/24 (%98); C3 16/24 (%353). 24/24 olmaz: Q0b'de none kolları fix kollarından %36-52 yüksekti (eski U hatayı okuyordu),
  yeni modelde bu sıra yok; hf104 kaotik (destek masası çökme zamanlaması).
### B2C eğrisi kararı (Erdem, 19 Ekim, K9a sonrası)
- Soru sade dille: kitle 52. hf'de 130-175 bin (eski 5-8 bin), Series A Avı hf 38-42 (eski 73-79); C10'un bedeli ücretli plan açılınca
  temel geliş ~⅓, memnuniyet yalnız 65 üstünde ağızdan ağıza. Erdem: **"C10'u yaz"** (sabitler onay bekliyor kalır).
- Ana oturum bulgusu → K9b brifi: kayıt yokken (ücretli plan kapalı) memnuniyet WOM_MULT_PIVOT okunuyordu; pivot 233'te ağızdan
  ağıza haftada ~%30 verirdi. Düzeltme: kayıt yokken iki terim de yok (bugünkü davranış). Eğri son kodla yeniden ölçülür.
- Kapanış ölçümü (k8_run.sh → scratchpad/k9_logs) K9b'den sonraya alındı; ilk deneme 8 koşuda durduruldu.
### K9b
- Eğri (son kod, scratchpad/k9a/cand/k9b): 24 okumanın 19'u Q0b ± %20, ortanca sapma %9. Dışarıda: none-7 hf26 −%27, hf52 −%26,
  hf104 +%382 (13.137 → 63.311; memnuniyet 87-100'de kalıyor, kapı üstü bileşik büyüme tavansız), due-7 hf104 +%36, off-11 hf104 +%35.
  52. hf MRR 40-52 bin (taban 25-38 bin); Series A Avı girişi 65-76 (taban 73-79, none-7 tabanda yoktu → 76).
- K9a'nın C10 tablosu (17/24) tuzaklı kodla ölçülmüştü (ücretli plan öncesi pivot okunuyordu); tuzak kapanınca hf26 aşağı indi.
- Fikstür notu: _seed_b2c kapasiteyi 0 bırakıyor, kitlesi olan her okuma Infra aşım çarpanı (×0,6) taşıyor; smoke yardımcısı
  _b2c_delta set_capacity(100) kuruyor.
- ACIK_KARARLAR 1303-1305 eski turun WOM değerlerini (0,005 → 0,0012, 60 → 30, 50 → 15) tarihçe olarak tutuyor: dokunulmadı, RAPOR_Q'da not.
- Haiku kapısı iki Godot'u aynı anda koşturdu (lint ∥ loc_residue); sonuç geçerli, kural ihlali notu.
### Kapanış ölçümü bd9a5ed ve B2B hız kararı (Erdem, 19 Ekim)
- scratchpad/k9_logs_bd9a5ed, tablolar scratchpad/K9_tables_bd9a5ed.md. §4.4-2 masalı ortanca 67 ❌, §4.4-3 erken 2★ U 45 ❌, §4.4-5
  masalı fix_worst %0,3 ❌; öbürleri ✅ (U = 100 %0, imza %61,2, VCQ en çok 2, §4.5 yön ve farklar).
- B2B yavaşladı: kurucu kollarında 52. hf MRR 38-63 bin (Q0b 63-110, E1 63-82); fix kolları Series A Avı'na 94-99. hf'de ya da hiç
  (8 koşunun 3'ü); vc_cautious 89 / hiç (Q0b 64-67). Erdem: **"2★ Çekirdek'i 1,25 yap"** → K9c.
- Görsel kabul (cb + 1,25): 22 kare temiz. Taban kartı karesi yanlış kimlikle çekildi (`b2c_floor_signal` → `product.b2c_floor_signal`).
### K9c
- Kapılar Haiku: lint, loc_residue, all_scripts_load, loc_csv_integrity; aile + doğrudan çağıran 123/123; falsification (1,5'te üç
  vaka FAIL); full_run ve full_run_b2c_fix_none 30 hf temiz. Opus onay, kodda düzeltme yok, GUNCELLEMELER:161 cümlesi netleşti.
- Ana oturum: HARITA'nın onay bekleyen listesinde CORE_2 duruyordu (K9a'dan beri onaylı) → "yıldız tablosunun 3★ satırı".
- Kapanış ölçümü 910ad1f'te yeniden: scratchpad/k9_logs → q_calisma/K9_TABLOLAR.md.
### Kapanış ölçümü 910ad1f (RAPOR_Q §3)
- 38 koşu temiz; K9_TABLOLAR.md, K9_HIZ.md. 1,25'in bedeli: §4.4-1 2★+3★ U = 100 %40,3 (masalı %27,4) ❌, §4.4-2 86 ❌ (masalı 74 ✅);
  kazancı: §4.4-3 50 ✅, kurucu fix kolları 52. hf MRR 52-66 bin (1,5'te 38-63), Avı 88-98 / 1 hiç. 26. hf MRR 1,25 ve 1,5'te aynı.
- §4.4-5 masalı fix_worst 0/328 ❌; B2C 18/24 ❌; tik 133,6 ms ✅; sprint probu b2c 8, b2b 10 adlı, adsız 0; run_gate 3/3 ✅;
  plausibility 40 + 4 koşu fails=0 ✅; taban kartı cb ve 1,25 karesi temiz.
- RAPOR_Q §9 soru 1 önerisi: 1,5'e dön (hız kazancı küçük, doyum %40); karar Erdem'in.
