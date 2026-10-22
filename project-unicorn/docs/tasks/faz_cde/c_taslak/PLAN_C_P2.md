# Faz C · Pazar 2 modeliyle kalan adımlar (PLAN_C_P2)

> **PARK (yardımcı yönetmen, 2026-10-22).** Bu plan kodlanmaz. Erdem'in yönü: yalnız tam tanımlı işler sürer; modüller, fiyat,
> B2B pazarlık ve pazar modeli için önce Erdem'le ayrıntılı PRD yazılacak. Sentez PRD yerine geçmez. §9 ve §10'daki onayların
> hepsi (kapsam, §8 varsayılanları, 8, 13, 22, İmalat ve eskime yazımı) geri alındı. Bu plan, `C0p_HARITA.md` ve `W2_METINLER`
> o PRD'nin girdisidir.

2026-10-22 · Taban `main` @ `cf45252` (Q K22). Kod `git show HEAD` ve `git grep HEAD` ile okundu; çalışma ağacı (Q K20 ve D
farkı) okunmadı, Godot koşmadı. Kısaltmalar: `SENTEZ` = `pazar2/out/SENTEZ_ERP_PAZARI.md`, `PRD` = `PRD_FAZ_C_URUN_HESAP.md`,
`KARARLAR` = `ERDEM_KARARLAR_2026-10-20.md`, `E1` = `c_taslak/PLAN_C_E1.md`, `K` / `K2` = `pazar2/out/K_kod_haritasi.md` /
`pazar2/out/tur2/K2_kod_fiyat_icerik.md`, `DPLAN2` = Faz D'nin güncel tablosu `d_taslak/ADIM_TABLOSU_D_v2.md`
(2026-10-22, yardımcı yönetmenin §4 cevaplarıyla; `C:\Users\erdem\.claude\plans\sen-project-unicorn-da-faz-playful-bentley.md`
artık yalnız ona işaret eder, eski Dalga 0-3 tablosu silindi). DPLAN2 D8c ve D8d'yi erteler ve C ile üç sözleşme yazar
(DPLAN2:145-148; C kabul etti). Kod yolları `project-unicorn/` köklüdür.

## 1. Bağlam

1. Yeni PRD sentezdir (SENTEZ:3-5): Erdem'in 1-11 ve 24-31 cevapları işli. Tek açık soru YZ dalgası (SORU_PAKETI_3:16-52);
   hiçbir adım ona bağlanmaz, kod YZ satırlarına dokunmaz (SENTEZ:259-260).
2. §14.2'nin hükmü (SENTEZ:1181-1196): C1, C2, C4, C7, C9 aynı kalır; C3a büyük ölçüde kalır, yeni satırlar ve göç alanları
   alır; C3b, C5, C6 yeniden yazılır; C8 genişler.
3. main'de: C2 `2e8dfad` (düzeltme `ec78197`), C1 `16a0eb6`, C4 `7f4d51f`, C7 `0c13424`, C9a `395576f`, C9b `09c9101`,
   C2b `50dcb19`, C9a-3B `80cafcd`. Q K10-K24 ortak dosyaları da değiştirdi; C0v ve C0q'nun satır numaraları kaydı.
4. Şema bugün 18 (`scripts/autoload/save_manager.gd:16`, zincir `:194-205`, son kol `if version < 18: _migrate_17`).
   C'nin tek göçü C3a-2'dedir ve iniş anındaki sıradaki numarayı alır (D1 önce inerse D 19, C 20; tersi C 19).
5. Sabitler [WORKING] kalır (SENTEZ:1278-1284); her aile tek evdedir (§4'te "Ev"). Pazar 2'nin kapanış koşusu bir sayıyı
   değiştirirse yalnız o ev değişir; commit mesajı "sabitler onay bekliyor" der.
6. Akış PLAN_C.md:111-127 gibi: Sonnet kodlar, Haiku kapıyı ve kareleri koşar, Opus inceler (en çok bir düzeltme turu),
   commit'i ana oturum yapar, önek `Faz C <id>:`. Oyuncu metni TR ve EN birlikte, tiresiz, "TR/EN onay bekliyor".

## 2. Önkoşullar ve sahipleri

| # | Parça | Sentezin sahibi (kaynak) | C3a-C8'den önce şart mı | Öneri |
|---|---|---|---|---|
| 1 | 10 modül: Finans = Defter + Nakit Akışı, Veri Girişi → Satın Alma, 6 yeni hat; K1-K3 | Modül = hat (SENTEZ:120-126); sahip yazılı değil. K4-K12 kartları D (SENTEZ:1200-1201) | Evet (hesabın modülleri, uyum) | C3a-2. Birleşme kayıt kimliği sildiği için göç ister (K2:209); tek göçle aynı adımda |
| 2 | 13 sektör → 9 profil, modül sayısı yıldıza göre | Veri dosyası (SENTEZ:165-200, 1226); sahip yok | Evet | C3a-2: `data/market/sector_profiles.json` (kaynağı `tur2/P_profiles.json`) |
| 3 | 5 yıldız ve koltuk bantları | ~30 kod noktası (SENTEZ:277-302, 1221; K:130-137); sahip yok | Evet (C3b, C5) | C3b-3 |
| 4 | `Customer.modules`, çalışan, gidiş, `o`; `Prospect.modules` | C3a (SENTEZ:1190) | Evet | C3a-2 (göç) |
| 5 | Rakip şirket modeli, standart S ve kısa liste L | SENTEZ:540-551, 707-743; sahip yok (§14 rakip için satır yazmaz, SENTEZ:65 "iki ayrı rakip modeli kalkar") | Evet (eskime, uyum, şart, derinlik isteği) | C11a; havuz ve pay C11b |
| 6 | Dönem tablosu | SENTEZ:820-854; sahip yok | Yalnız tavan takvimi (2012'de modül K3, platform K2) | C10 tavan takvimi; mevzuat, dönem düğümleri, YZ, yeni girişim C sonrası dönem fazına (Sessiz 27) |
| 7 | Yıllık rapor ve modül ödülü | SENTEZ:582-627; sahip yok | Hayır | C12 (C'nin sonu, D ile paralel) |
| 8 | Önerilen fiyat ve üç düğme | C3b (SENTEZ:1191) | Evet | C3b-4 |
| 9 | Q'nun alan tabanlı beklentisinin kaldırılması | "Yeniden yazılır" (SENTEZ:1177), Q kapandı | Evet | C3a-2 (hesabın hatları), C3a-3 (hesap), C3b-1 (aday), C3b-2 (B2B ürün sayfası), C6-1 (`TABLE` ve `emphasis`'in son okuyucusu, eski istek üreticisi) |
| 10 | Ar-Ge tavanı (+1) ve dönem düğümleri | Ar-Ge (SENTEZ:224-227, 1207-1217) | Hayır: demoda dönem tavanı K3 = `TIER_MAX`, +1 K4 içeriği ister | Dönem fazı, D'nin K4+ kataloğuyla |
| 11 | K4-K12 kartları, iki parçalı efor, kadro tavanı | D (SENTEZ:1198-1205) | Hayır (demo K3'te) | D; C11a rakibi aynı `step_effort`'u okur |
| 12 | İstek kartının modül kartıyla birleşmesi | D (SENTEZ:1202, Karar 25) | C6 için evet | C6-1 tek kartı ve veriyi kurar. DPLAN2 D8d'yi erteledi (DPLAN2:24, :122): kart yenilemesine kadar kartın tek sahibi C6-1 |
| 13 | Metinler (modül ve kademe şablonu, müşteri cümleleri, rapor) | Şablonla başlar (SENTEZ:1026-1029), tek metin turu (KARARLAR:66) | Evet | W2 (koddan önce, `c_taslak/`) |

## 3. Adım tablosu

Sıra seridir: C0p ∥ W2 → C3a-1 → C10 → C3a-2 → C11a → C3a-3 → C3b-1 → C3b-2 → C3b-3 → C3b-4a → C3b-5 → C11b → C5-1 → C5-2
→ C6-1 → C6-2 → C8 → C12 → C3b-4b → E2 → R. C3b-4b satış ve pazarlık PRD'sini bekler (§9); o PRD gelmeden E2 ve R onu
beklemez, R onu açık iş olarak yazar. C3a-2 ile C3b-2 arasındaki commit'ler tek parça sayılır: aralarında push yok (§9). C3a-2 C11a'dan önce gelir: rakibin odağı profile bağlıdır (SENTEZ:720-722) ve rakip
10 modülle doğar; tersi sırada C11a'nın kaydettiği rakip durumu Finans birleşmesinde ikinci bir göç isterdi. "∥D": kodu D'nin
kod adımıyla aynı anda yazılabilir; Godot kapısı, index ve commit sırayla (makinede aynı anda tek oturum Godot koşar). "D ile
sırayla": adı yazılan D adımıyla aynı dosyaya yazar, biri bitmeden öbürü başlamaz. Ortak dosyalar her adımda:
`localization/strings.csv` (bayt kesme), `scripts/main/main.gd`, `docs/HARITA.md`, `scripts/debug/endgame_smoke.gd`,
`scripts/debug/run_probe.gd`. Her adımın ortak kapıları tabloda tekrar yazılmaz: `--event-lint`, `loc_residue`,
`loc_csv_integrity`, `all_scripts_load`; yeni `class_name` (C3a-1, C10, C3a-2, C11a, C12) gelen adımda kapılardan önce
`--headless --import`. Model sütunu: kod / kapı / inceleme.

| Adım | Ne | Dosyalar | Silinecek eski kod ve vaka | Kapı | Süre | Model | Bağımlılık | Kayıt |
|---|---|---|---|---|---|---|---|---|
| C0p | Harita tazeleme: C0v ve C0q eklerini bu plana ve `cf45252`'ye göre dosya:satır, vaka listesi | yeni `c_taslak/C0p_HARITA.md` | yok | yok (Godot yok) | 0,75 | Sonnet yüksek / yok / Opus orta okur | yok · ∥D | yok |
| W2 | Metin dalgası (önce EN, TR yeniden yazım): modül ve kademe şablonları, istenen modül sözcükleri, kayıp nedenleri, eskime, şart, yenileme, istek, fiyat paneli, HESAPLAR, rapor; W1'den düşenler işaretli | yeni `c_taslak/W2_METINLER.json`, `.md` | W1'in `renew.*`, `budget_mail.*`, `sector.trend_*`, `sign.*` gibi düşenleri (§6) | `python -I` denetimi: tire yok, TR ve EN yer tutucusu aynı, `[a-z_]+` | 3 | Opus yüksek / Haiku düşük / yok | yok · ∥D | yok |
| C3a-1 | Memnuniyet defteri, göçsüz: satır toplamı, kayma yok, adsız destek zararı yok, söz ve olay izi deftere | yeni `scripts/systems/b2b_satisfaction.gd`; `b2b_sales_system.gd`, `b2b_constants.gd`, `support_system.gd`, `customer.gd`, `customer_registry.gd`, `sales_system.gd`, `effects.gd`, `chips.gd`, `incident_system.gd`, `customer_rep_system.gd`, `inbox.gd`, `sales_tab.gd`, 13 `satisfaction_delta` kartı | `_tick_satisfaction`, `satisfaction_next_tick`, `satisfaction_after_break`, `_drift`, `onboarding_floor_until`, `onboarding_ends_under_bar`, `ONBOARDING_GRACE_*`, `DAMAGE_*`, `daily_satisfaction_damage`, `set_trust_offset`, `signing_satisfaction_seed`, anlık `RETAIN_SAT_BUMP`, `B2B_BUG_SAT_PER`, `B2B_BUG_SAT_CAP`, `COMPLAINT_BUG_GATE` (yerine k'li PRD hata terimi ve k'li eşik; Sessiz 7, 33; DPLAN2 sözleşmesi); `onboarding_ends_under_bar`'ın tek okuyucusu `sales_tab.gd:553-554` ve CSV `SALES_ONBOARDING_ENDS`; vaka `b2b_onboarding_grace_floor` | yeni `sat_total_is_sum`, `sat_no_silent_drop`, `ledger_fade`, `chip_matches_ledger`; söz, olay, `cs_*` aileleri; plausibility; `run_gate`; `full_run_fix_*` churn kapısı; kare `--sales-shot=sat_tip` (yeni tür) TR, EN | 4 | Sonnet max / Haiku düşük / Opus yüksek | W2 · D1 ve D3 ile sırayla (`effects.gd`, `chips.gd`, `support_system.gd`, `incident_system.gd`; DPLAN2:77, :80) | yok: `ledger` varsayılan `[]`, `trust_offset` kalır (yazarı yok, söner) |
| C10 | Dönem tavanı: kademenin açılacağı yıl, oyuncu ve rakip aynı okuyucudan; kilit kartta gerekçeli | yeni `data/market/eras.json`, yeni `scripts/systems/era_table.gd`; `line_gates.gd`, `sprint_catalog.gd` | yok | yeni `era_ceiling_gates`; `line_ladder_rules`, `line_k3_locked_without_research`; `run_gate`; kare `--product-shot=live:<yeni tür>` TR, EN | 2 | Sonnet xhigh / Haiku düşük / Opus yüksek | C3a-1 · D1 ile sırayla (`sprint_catalog.gd`) | yok |
| C3a-2 | 10 modül, sektör profili, hesap ve aday alanları, **tek göç** | `data/product/lines/erp.json`, `product_lines.gd` (`IDENTITY_LINE_COUNT`, `IDENTITY_PROFILE_SHAPE`, `LINES_PER_SUBTYPE`; `EFFORT_BANDS` ve `TIER_MAX` kalır, yeni altı modülün eforu banda girer), `data/product/sprint.json` (hat listeleri), `data/product/rivals.json` (eski ERP çıkış tablosunun hat kimlikleri C11a'ya kadar), 5 kâğıt (`sprint_design_color_blind`, `sprint_dev_import_tool`, `sprint_dev_multi_currency`, `sprint_test_after_midnight`, `sprint_test_readonly_delete`), yeni `data/market/sector_profiles.json`, yeni `scripts/systems/sector_profiles.gd`, `prospect.gd`, `customer.gd`, `sales_faucet_system.gd` (sektör seçiminin yıllık ağırlığı, SENTEZ:199-200), `sales_system.gd`, `b2b_sales_system.gd` (`account_bugs`), `sprint_catalog.gd` (`line_accounts`), `product_quality.gd`, `save_manager.gd`, `GDDs/GUNCELLEMELER.md`, `CLAUDE.md` §6 | `line_erp_cashflow`, `Customer.trust_offset`, `TRUST_OFFSET_DECAY_PER_DAY`, `clamp_trust`, `ProductQuality.used_areas`, `uses_area`, `USE_AREA_MIN` (iki okuyucusu `b2b_sales_system.gd:177` ve `sprint_catalog.gd:379` modül listesine geçer); `_migrate_17`'nin `_retire_stability` bloğu ve `_retire_stability` (göç alan hedefli kayıp izini kendisi temizler, §5); "9 hat × 3 = 27" mührü (`product_line_profiles`, `type_screen_matches_line_content`) yeniden | yeni `save_v<N>_market_model`, `account_modules_from_profile`; `product_lines_catalog_loads`, `loc_product_line_keys_resolve`, `bug_cost_b2b_account_lines`, `save_v10_product_state`; plausibility; `run_gate`; kare `--product-shot=live:b2b_mature` TR, EN, 1536 | 5,5 | Sonnet max / Haiku düşük / Opus yüksek | C3a-1, C10 · D1 ile sırayla (`save_manager.gd`, `sprint.json`) | **GÖÇ**: iniş anındaki sıradaki numara |
| C11a | Rakip şirketleri ve standart: ERP rakipleri 10 modülde aynı katalog, efor, Ar-Ge ve dönem kapısıyla haftalık yürür (yalnız oyuncunun alt türü ERP iken); S = medyan, L = en iyi ikinci, oyuncu dışarıda; haber satırı haftada en çok bir; VC'nin rakip karşılaştırması gerçek | `rival.gd`, `rival_catalog.gd`, `rival_registry.gd`, `data/product/rivals.json` (`erp` bloğu), yeni `scripts/systems/market_standard.gd`, `research_seam.gd` (`completed` şirket başına, SENTEZ:1216), `sprint_bridges.gd` (`tick_rivals`), `sprint_catalog.gd` (`rival_table`, `_rival_tier`), `vc_pitch_system.gd`, `time_manager.gd`, `news_feed_system.gd`, `docs/tasks/PRD_RAKIP_DUNYASI.md` (I2, I3 satırı, Sessiz 30) | `rivals.json` `erp.launches`/`erp.tiers`, ERP için `rival_hits` yazımı, `COMPOSITE_AXES`'in ERP satırı, `_rival_ahead`'in sabit `true`'su; vaka `rival_composite_table`'ın ERP satırları | yeni `rival_same_rules`, `standard_median_second`; `--tick-probe=3:accounts=330` ≤ 148,2 ms (Sessiz 35); `run_gate`; haber şeridi karesi TR, EN | 5 | Sonnet max / Haiku düşük / Opus yüksek | C3a-2 · D1 bağı ve D1 ile sırayla (`sprint_catalog.gd`; Sessiz 14) | yok: boş rakip durumu 2012 katalogundan bugüne ileri sarılır |
| C3a-3 | Hesabın istediği seviye (S + `o`, imzada sabit) ve eskime satırı; Q'nun hesap uyumu kalkar | `b2b_satisfaction.gd`, `b2b_sales_system.gd`, `market_standard.gd`, `product_quality.gd`, `customer.gd`, `customer_registry.gd`, `sprint_bridges.gd` (`:35-36`), `sales_system.gd`, `save_manager.gd`, `inbox.gd` (`risk_reason`) | `account_fit`, `market_ref_for`, `Customer.market_ref`, `set_market_ref`, `satisfaction_target`, `_migrate_17`'nin kalan `market_ref` bloğu ve `if version < 18` kolu; vakalar `fit_account_ref`, `save_v17_market_ref`, `b2b_account_reads_fit`, `fit_star_context` (hesap kolu) | yeni `wanted_level_fixed_at_signing`, `obsolete_row_named`; `sat_*` yeniden; plausibility; `run_gate`; `--tick-probe=3:accounts=330`; kare `--sales-shot=sat_tip` TR, EN | 3 | Sonnet xhigh / Haiku düşük / Opus yüksek | C11a · D1 ve D3 ile sırayla (`save_manager.gd`, `sprint_bridges.gd`) | vaka ekler |
| C3b-1 | Kapanış zarı P = yıldız tabanı × modül uyumu × satıcı × fiyat, [%3, %92]; satıcı bir üste ×0,6, iki üste gidemez (kurucu dahil); iki kat bayat aday %3; tek adlı kayıp nedeni ve kazanan rakip; "önemli modül" sorusu | `product_quality.gd`, `sales_rep_system.gd`, `sales_meeting_system.gd`, `sales_probes.gd`, `sales_ledger.gd`, `sales_constants.gd`, `sales_finalizer.gd`, `sales_faucet_system.gd`, `market_standard.gd`, `inbox.gd` | `CLOSE_CURVE`, `close_chance`, `prospect_fit`, `prospect_ctx`, `fit`, `loss_area`, `lost_area`, `rival_bump` bağlamı (`sprint.json` `rival_bump`, `rival_bump_max`), `MISMATCH_PENALTY`, `product_strength`, `LOSS_WEAK_AREA`; `probe_emphasis_*` silinmez, "önemli modül" sorusuna döner (SENTEZ:204); vakalar `sales_rep_close_chance`, `sales_rep_close_die`, `sales_weak_area_loss`, `sales_meeting_reads_fit`, `product_fit_table`, `product_quality_sector_table`, `fit_scale` | yeni `close_chance_terms`, `loss_reason_order`; `sales_loss_reason_from_asked`, `bugs_leave_sales_and_vc_alone`; plausibility; `run_gate`; kare `--meeting-shot=probe`, `lost` TR, EN | 4 | Sonnet max / Haiku düşük / Opus yüksek | C3a-3 · ∥D | vaka ekler |
| C3b-2 | B2B ürün sayfasından alan beklentisi kalkar (B2C kalır); D'nin önerisine `MarketStandard` okuyucusu | `sprint_catalog.gd` (`:125`, `:328-333`, `:672-695`, `:804`, `:818-829`), `sprint_bridges.gd` (`:109`, `:147-148`), `sprint_system.gd` (`:1548`), `product_model.gd`, `vc_pitch_system.gd` (`:1128`, `:1178`), `term_sheet_table_system.gd` (`:548`), `product_quality.gd` | `expectation`, `word`, `next_star`, `next_ratio`, `serves`, `area_row`, `weakest_area`'nın B2B kolu; yalnız B2B'nin okuduğu `CORE_2`, `EMPHASIS_2`, `CORE_3`, `EMPHASIS_3`, `REST_3`, `W_B2B` ve `weights`'in B2B kolu; vaka `product_area_row` B2B kolu. `TABLE` ve `emphasis` C6-1'e kadar kalır (son okuyucu `sprint_bridges.gd:41`) | `--sprint-probe` team 1, 3, 6 adsız uyuşmazlık 0; `run_gate`; kare `--product-shot=live:b2b_mature`, `live:plan`, `live:b2b_quarter` TR, EN | 3 | Sonnet xhigh / Haiku düşük / Opus yüksek | C3b-1 · D8a ve o anki `sprint_system.gd` adımıyla sırayla (Sessiz 17) | yok |
| C3b-3 | 5 yıldız: bantlar 3-10 / 10-30 / 30-100 / 100-300 / 300-1.000, 5 elemanlı karışım, 4-5★ muhatabı ve soru sayısı, kart eşikleri | `sales_constants.gd` (`:42-45`, `:115-119`, `:175`), `product_quality.gd` (`:21`), `sales_faucet_system.gd` (`_roll_star` `:169`), `counterpart_system.gd` (`:20`), `sales_archetypes.gd`, `negotiation_system.gd`, `sales_ledger.gd`, `b2b_constants.gd`, `sales_meeting_system.gd` (`:220`), `musteri.scale` okuyan 5 kart | iki `STAR_MAX` kopyasından biri, 3 elemanlı karışım dizileri; 1-3 ile sınırlı `PROBES_*` ve `_probes_for_star` kolları, `company_size`'ın 3 kademeli eşlemesi (`sales_faucet_system.gd:30` `SIZE_TO_STAR`, `sales_system.gd:354`; tek okuyucusu `EXPANSION_SEATS` C5-1'de gider), `sales_archetypes.gd` `star_range` [1,3] sınırları (K:132-135) | yeni `star_bands_five`; `auto_capacity_grows_only`'ye 650 koltuklu hesap; plausibility; `run_gate`; kare `--meeting-shot=probe` (4★) TR, EN | 3 | Sonnet xhigh / Haiku düşük / Opus yüksek | C3b-1 · ∥D | yok |
| C3b-4a | Önerilen fiyat formülü ve üç duruşun verisi (fiyat ve kapanış çarpanı); temsilci zaten Satış'taki duruşla satar (`sales_rep_system.gd:156`, `:265`), formülü okur; en güçlü rakibin standart teklifi (veri). Görüşme akışı değişmez (§9) | `sales_constants.gd` (`:120-133`), `sales_ledger.gd` (`seat_price_anchor` `:141`), `sales_rep_system.gd`, `sales_system.gd`, `sales_finalizer.gd`, `sales_tab.gd` (`_paint_stance` `:219`), `erp.json` (fiyat sınıfı) | `seat_price_anchor`'ın formülün yerini alan eski hesabı | yeni `suggested_price_formula`; plausibility; `run_gate`; kare `--sales-shot=<duruş>` TR, EN | 2,5 | Sonnet xhigh / Haiku düşük / Opus yüksek | C3b-3 · ∥D | yok |
| C3b-5 | Aday kartı: sektör adı, "İstediği modüller" sözcükleri, önemli modül, "soğuyor", satışçı kilidi gerekçesi; hesap kartında modül çipleri ve "N çalışan · M koltuk" | `sales_tab.gd` (`_lead_card` `:323`, `_account_card` `:532`, `_meta_line` `:565`), `scripts/theme/build_theme.gd` (varyasyon gerekirse, `THEME_STAMP` ile) | `_meta_line`'ın tek satırlık modülsüz biçimi | `theme_check.gd`, `glyph_audit.gd`, `--theme-contrast-audit`; kare `--sales-shot=<yeni türler>` TR, EN, renk körü, 1,25 | 3 | Sonnet xhigh / Haiku düşük / Opus yüksek | C3b-4 · ∥D | yok |
| C11b | Pazar havuzu: profil × yıldız hesap sayısı, yıllık büyüme, çekime göre pay, toplam korunur; rakibin hesabı, MRR'ı, kasası; kasası biten girişim satın alınır; kaybedilen aday ve ayrılan hesap adlı rakibe | `rival_registry.gd` (`get_market_snapshot` `:127`), `rival_catalog.gd`, `rivals.json`, `market_standard.gd`, `sales_finalizer.gd`, `b2b_sales_system.gd`, `news_feed_system.gd`, `scripts/tabs/finance/finance_ozet_view.gd` | ERP için `MARKET_TOTAL_MRR`, `SHARE_SEED`, momentum payı | yeni `market_pool_conserved`; `--tick-probe=3:accounts=330`; plausibility; `run_gate`; kare `--tab-shot=piyasa:sektor`, Finans pazar payı TR, EN | 3,5 | Sonnet xhigh / Haiku düşük / Opus yüksek | C11a · ∥D | yok |
| C5-1 | Yenileme: 12 ayda bir koltuk kuralı, bant aşınca yıldız, fiyat aynı; gidiş çalışanı yılda değiştirir; ürün dışı ayrılma düşük olasılıkla ve adlı; sözleşme ortası Risk ayrılması kalkar; VC tutma oranını sorar; sonuçlar haftalık satış özetinde | `b2b_sales_system.gd` (`_tick_at_risk` `:223`, `_churn` `:294`, `expand` `:437`), `b2b_constants.gd`, `customer.gd`, `customer_rep_system.gd`, `sales_rep_system.gd` (`_tick_weekly_summary` `:301`), `vc_pitch_system.gd`, `term_sheet_table_system.gd`, `sprint_bridges.gd` (`next_renewal_day`), `plausibility.gd`, `scripts/events/gate/scope.gd`, `seams_ported.gd`, `save_manager.gd` (yalnız eski göçün alan satırları), `request_renewal.json`, `expansion.json`, `retention.json` | `request_renewal.json`, `CS_KIND_RENEWAL`, `RENEWAL_MIN_TENURE_WEEKS` (iki kopya: `b2b_constants.gd:268`, `plausibility.gd:57`), `expansion.json`, `EXPANSION_SEATS`, `can_offer_expansion` (okuyucuları `scope.gd:297`, `seams_ported.gd:21`), `last_expansion_day`, Risk geri sayımı ve "Oyala" (`Customer.churn_countdown`, `risk_streak`, `retain_stalls`, `last_risk_exit_day` ve bunları adıyla taşıyan eski göç satırları `save_manager.gd:735-738`); vakalar `cs_renewal_floor` (yenileme yarısı), `cs_request_kind_state_driven`, `discount_row_locked_past_cap`, `next_renewal_day_one_place` yeniden | yeni `renewal_seats_follow_company`, `non_product_leave_named`, `no_midterm_churn`; plausibility; `run_gate`; kare `--inbox-shot=<satış özeti>` TR, EN | 4,5 | Sonnet max / Haiku düşük / Opus yüksek | C3b-5, C11b · D1 ve D3 ile sırayla (`save_manager.gd`, `sprint_bridges.gd`) | vaka ekler |
| C5-2 | Yenileme şartı: 8 hafta önce 3★+ hesabın bir adım geride modülü şart olur (etiket, tarih, fesih bildirimi, defterde "Şart: <modül>" satırı, Sessiz 34); iki adım ya da düşük memnuniyet adlı ayrılma; memnun 3★+ bir adımı istek söyler; 1★-2★ çoğunlukla sessiz (düşük olasılıkla şart, sim2 0,3) | `b2b_sales_system.gd`, `customer.gd` (şart alanları), `b2b_constants.gd`, `message_system.gd`, `scripts/tabs/events/mail_pane.gd`, `scripts/ui/components/inbox.gd`, `sales_tab.gd` | yok | yeni `renewal_condition_timeline`; plausibility; `run_gate`; yeni `full_run_idle` kolu bir koşu; kare `--inbox-shot=<şart>` TR, EN | 3,5 | Sonnet max / Haiku düşük / Opus yüksek | C5-1 · ∥D | vaka ekler |
| C6-1 | İstekler: yalnız 3★+ (yılda 3★ %25, 4★ %40, 5★ %60); yeni modül ya da pazardaki seviyeye derinlik; (modül, kademe) başına tek kart; teslimde genişleme; iki çeyrek bekleyene adlı satır; haftada en çok 2 müşteri maili | `sprint_bridges.gd` (`tick_requests` `:22`), `sprint_catalog.gd`, `b2b_sales_system.gd`, `customer_rep_system.gd`, `support_system.gd` (`weekly_report`), `b2b_satisfaction.gd`, `message_system.gd`, `mail_pane.gd`, `inbox.gd`, `request_feature.json` | `request_feature.json` (söz ve "listeye al" kesintisi), CS kanalının `feature` türü, 1★-2★ isteği, `late` durumu; eski istek üreticisinin alan seçimi (`sprint_bridges.gd:41`) ve onunla son okuyucusu kalmayan `ProductQuality.TABLE`, `_row`, `emphasis`; vakalar `sprint_request_on_time_met`, `release_thanks_*` 3★ fikstürü | yeni `requests_three_star_only`, `request_market_level_only`, `request_card_merges`, `module_add_price`; plausibility; `run_gate`; kare `--product-shot=live:b2b_requests`, `--inbox-shot=<istek>` TR, EN | 4,5 | Sonnet max / Haiku düşük / Opus yüksek | C5-2 · D3, D7, D8a ile sırayla (`support_system.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`); D8c ve D8d DPLAN2'de ertelendi | vaka ekler |
| C6-2 | Genel Bakış'ın sol sütunu: Kararlılık, İstekler (modül toplamı), İş, şart şeridi; düzeltme kartına giden tek yol | `scripts/tabs/product/overview_view.gd`, `product_model.gd`, `scripts/tabs/product_tab.gd`, `incident_system.gd`, `support_system.gd`, `build_theme.gd` | `open_area`'nın vurgusuz hâli (yol tek işleve iner) | `theme_check.gd`, `glyph_audit.gd`; kare `--product-shot=live:overview_b2b`, `overview_b2c`, `overview_no3` (yeni türler) TR, EN, renk körü, 1,25 | 3,5 | Sonnet xhigh / Haiku düşük / Opus yüksek | C6-1 · D1, D2a, D6 (`product_model.gd`) ve D8b (`product_tab.gd`) ile sırayla | yok |
| C8 | HESAPLAR tablosu: PRD sütunları ve sektör, modüller, çalışan · koltuk, gidiş, şart; "Şartlı" görünümü | `sales_tab.gd` (`_paint_portfolio` `:514`, `_account_card` `:532`), `build_theme.gd`, `main.gd` (fikstür) | kart listesi ve `PHASE_TAGS` (`SALES_CHIP_ONBOARDING`, `SALES_CHIP_HEALTHY` kolu); PRD Karar 13'ün "Onboarding, Risk, Büyümeye açık yok" kuralı; "Yenilemeyebilir" durumu (Sessiz 36) | `--tick-probe=3:accounts=330`; `theme_check.gd`; kare `--sales-shot=accounts_330` (yeni tür) TR, EN, renk körü, 1,25 | 4 | Sonnet max / Haiku düşük / Opus yüksek | C6-2 · ∥D | yok |
| C12 | Yıllık rapor ve modül ödülü (Kasım): en büyükler, en hızlı büyüyenler, B2B modül ödülü, oyuncunun modül durumu; ödül 12 ay aday akışı ×1,3 | yeni `scripts/systems/market_report.gd`; `message_system.gd`, `mail_pane.gd`, `inbox.gd`, `sales_faucet_system.gd` (`lead_rate_per_week` `:120`), `rival_registry.gd`, `game_state.gd` (`FLAG_TYPES`), `time_manager.gd` | yok | yeni `yearly_report_november`; plausibility (aday akışı ×1,3); `run_gate`; kare `--inbox-shot=<rapor>` TR, EN | 3,5 | Sonnet xhigh / Haiku düşük / Opus yüksek | C11b · ∥D | vaka ekler |
| C3b-4b | Kurucu görüşmesinin akışı: üç düğme her teklifte, gerekçe satırı, rakibin teklifi; satış ve pazarlık PRD'sinin kararına göre cetvel, sabır ve karşı teklifin yerini ne alır (Sessiz 13 o PRD'de kapanır) | `negotiation_system.gd`, `scripts/ui/meeting/sales_meeting_adapter.gd`, `scripts/ui/meeting/meeting_ruler.gd`, `sales_system.gd`, `sales_finalizer.gd` | PRD'nin silmeye karar verdiği: `SEAT_PRICE_MIN/MAX`, serbest fiyat cetveli, sabır kutusu, karşı teklif, rezerv ve hakaret eşiği, `--negotiation-shot=countered`, `insult`, `last` ve vakaları (şimdi silinmez) | plausibility; `run_gate`; kare `--negotiation-shot=open`, `confirm` TR, EN, 1,25 | 2,5 | Sonnet max / Haiku düşük / Opus yüksek | C12 ve satış ve pazarlık PRD'si · ∥D | yok |
| E2 | Ölçüm (§7), commit yok | log klasörü `c_taslak/` | yok | bot koşuları | 3 | Haiku düşük koşar / Opus orta okur | C12 | yok |
| R | `RAPOR_C.md` | `docs/tasks/faz_cde/RAPOR_C.md` | yok | yok | 0,5 | Opus orta | E2 | şemayı yazar |

Toplam yaklaşık 71 ajan saati (C1 5,5 planlanıp ~3,5'te, C9a 3'te bitti: tahminler bu oranla kırpıldı; W2 metin hacmi
yüzünden 3). D ile paralel yürüyebilenler (10): C0p, W2, C3b-1, C3b-3, C3b-4, C3b-5, C11b, C5-2, C8, C12. D ile sırayla (9):
C3a-1, C10, C3a-2, C11a, C3a-3, C3b-2, C5-1, C6-1, C6-2. Ayrım DPLAN2'nin kendi ortak dosya listesine göredir (DPLAN2:77-88,
:109-111): `sprint_bridges.gd` D3, `save_manager.gd` D1, `support_system.gd` ve `incident_system.gd` D3, `sprint_catalog.gd`
D1, D2b, D7, D8a, `product_model.gd` D1, D2a, D6 ile ortaktır.

## 4. Adım ayrıntıları

**C0p.** Q K13-K24 ve C2-C9a-3B'den sonra C0v (C3a `:211-319`, C3b `:321-364`, C5 `:402-474`, C6 `:476-530`, C8 `:566-606`) ve
C0q (§4 `:263-328`) satırlarını HEAD'e taşır, bu planın düşürdüklerini (§6) çizer. Çıktı repoya girmez.

**W2.** SENTEZ'in oyuncu cümleleri (`:202-206`, `:353-358`, `:438-440`, `:476-477`, `:593-607`, `:649-650`, `:680-684`, `:897`)
anahtar olarak yazılır. Kademe adları şablonla (SENTEZ:1028); 6 yeni modül × (ad + 3 kademe adı + 3 açıklama) = 42, Finans ve
Satın Alma 14, Stok ve Fatura'nın metni kalır (K2:152). Çıkış kapısı W1'inkiyle aynı (PLAN_C.md:28). Erdem'in tek metin turu
(KARARLAR:66) W2 üstünde yapılır; kod "TR/EN onay bekliyor" ile girer.

**C3a-1 · Defter (göçsüz).**
- Uygular: PRD Karar 5 (`:175-204`) yeni modelin dışında kalan kısmıyla; SENTEZ:652-656 "defter ilişkiyi taşır".
- Formül: memnuniyet = ürün terimi − açık hata terimi + defter + durum terimleri. Ürün terimi C3a-3'e kadar `account_fit`
  okur; durum terimleri yalnız indirim +8 ve Kurumsal madde −10 (C4'ün bıraktığı, E1:165).
- Ev: defter tutarları `B2BConstants` (PRD:186-190); hata terimi PRD'nin min(3 × H, 60)'ı (Sessiz 7).
- İmzadaki değer PRD Karar 6'nın kuralıdır (aynı formül, defter boş; PRD:208); sentez bunu değiştirmez, imza kapısı yazılmaz.
- PRD §4.4 m.1 ve m.3 sürer; Risk geri sayımı C5-1'e kadar kalır. E1'in "bekler: C3a" maddeleri (E1:326-339) Sessiz 22.
- Kabul edilmiş sözleşme (DPLAN2:83, :148): D7 `B2B_BUG_SAT_*`'ı ve `COMPLAINT_BUG_GATE`'i ölçeklemez; C3a-1 ikisini siler
  ve hata terimini ile şikâyet eşiğini `SprintCatalog`'daki k ile yeniden kurar. k'nin evi ve C3a-1'in D7'den önce inmesi
  Sessiz 33.
- Smoke: dört yeni vaka; falsification: toplamdan bir terim düşürülünce `sat_total_is_sum`, sönme kaldırılınca `ledger_fade` düşer.
- PROBE: `PROBE CUST` terim dökümü; `PROBE CHURN`'ün `trust=` alanı terimlere döner.
- Oyuncu: hesap kartının memnuniyet ipucu adlı satırları sayar; olaysız hafta sayı değişmez.

**C10 · Dönem tavanı.**
- Uygular: SENTEZ:221-223 (dönem tavanı), :830 (2012 satırı). Ev: `data/market/eras.json` (yalnız tavan takvimi; mevzuat ve YZ
  satırları yazılmaz). Kaynağı `pazar2/sim/eras.json` `tavan`, `platform_tavan_farki`.
- Okuyucu: oyuncunun kademe kapısı (`LineGates`/`SprintCatalog.gate_reason`) ve C11a'nın rakip adımı aynı `EraTable.ceiling`.
- Smoke `era_ceiling_gates`: 2013'te platform K3 kilitli, 2014'te açık; falsification: tavan okuması kaldırılınca düşer.
- Oyuncu: platform hatlarının K3 kartı 2014'e kadar kilitli ve gerekçeli ("2014'te açılır"). Modüllerde değişiklik yok
  (K3 = `TIER_MAX`).

**C3a-2 · Modüller ve tek göç.**
- Uygular: SENTEZ:129-152 (10 modül, birleşme), :171-200 (profil), :296-302 (çalışan · koltuk), :299-302 (modül sayısı),
  :310-316 (`o` imzada), :329-331 (gidiş imzada çekilir), :124 ve K:71 (hesabın hatları modül listesinden).
- Ev: profil hücreleri, sık %50 / nadir %10, yıldıza göre modül sayısı, İK 2★'tan ve sektörün yıllık aday ağırlığı
  (SENTEZ:199-200: 2012'de imalat, dağıtım, hizmet, perakende; e-ticaret 2015 sonrası) `data/market/sector_profiles.json`;
  çalışan başına koltuk oranı ve gidiş olasılıkları `B2BConstants`.
- Yeni modüller Çekirdek kimlik hattıdır (`sprint.json:131` `identity: true`); iş profilleri Sessiz 3; K3 Ar-Ge kapısı Sessiz 4.
- Hesabın hata terimi hesabın modülleri ve dört platform hattından okunur (SENTEZ:150, Sessiz 16).
- Göç ve smoke §5'te; `account_modules_from_profile`: "hiç" hücresi hiç gelmez, 1★'ta İK yok, sayı yıldız aralığında.
- Oyuncu: Ürün'de Çekirdek altında 10 modül; hesap kartı henüz değişmez (C3b-5). Uyarı: C3b-2'ye kadar Q'nun sayfa sözcüğü 10
  modülü sayar (Sessiz 5).

**C11a · Rakipler ve standart.**
- Uygular: SENTEZ:540-551 (S medyan, L en iyi ikinci, oyuncu dışarıda), :707-733 (şirket, beş basamaklı kart kuralı), :792-799
  (yalnız oyuncunun alt türü tam koşar), :571-576 (haber), :801-806 (ERP'nin iki modeli tek modele iner).
- B2C ve piyasa alt türlerinin rakipleri bugünkü modelde kalır (SENTEZ:805-806, §16 madde 10): `COMPOSITE_AXES`,
  `QualityModel.grow`, `TIER_ASYMPTOTE` onlar için durur, ERP satırı gider; `_rival_ahead` ERP'de gerçek, B2C'de bugünkü.
  Oyuncu B2C iken ERP rakipleri de bugünkü değer eğrisinde kalır (SENTEZ:797-798).
- Ev: rakip türleri, ekip başlangıcı ve tavanı, odak, jitter `data/product/rivals.json` `erp` (kaynağı `pazar2/sim/rivals.json`).
- Rakip oyuncunun iç durumunu okumaz; kart eforu `SprintCatalog.step_effort`, K3 Ar-Ge kapısı ve dönem tavanı oyuncuyla aynı.
- Smoke `rival_same_rules` (aynı efor, Ar-Ge'siz K3 yok, tavan üstü yok), `standard_median_second` (falsification: oyuncu
  hesaba katılınca ya da L en iyi olunca düşer).
- PROBE: yıl sonunda `PROBE STD year= line= s= l= giant=`. Kare: haber şeridinde "Werktag Stok'u yeniledi".

**C3a-3 · İstenen seviye ve eskime.**
- Uygular: SENTEZ:306-319 (istenen = S + `o`, en az K1, koltuk taşımaz), :653-656 ve :897 (eskime adlı satır), :1177.
- Ürün terimi = memnuniyet tabanı − Σ eskime satırları (Sessiz 6); satır "Stok 4'te kaldı, rakiplerde 5". Hesaplama haftalık.
- Ev: taban ve eskime satırının büyüklüğü `B2BConstants` (sim'de `eskime_memnuniyet`, SENTEZ:1121).
- Smoke: `wanted_level_fixed_at_signing` (yıldız değişince istenen aynı, S yürüyünce yürür), `obsolete_row_named` (adsız düşüş
  0); falsification: `o` güncel yıldızdan okununca ilki, satır adı boşalınca ikincisi düşer.
- PROBE `UFLUX` adsız memnuniyet değişimini sayar (0 beklenir); `renewal=` alanı kalkar.
- Oyuncu: memnuniyet ipucunda "Stok 4'te kaldı, rakiplerde 5" satırı.

**C3b-1 · Kapanış zarı.**
- Uygular: SENTEZ:391-408 (P ve sınırlar), :410-418 (süre ve çürüme, alt satıcıya +%20), :420-434 (bir üst kuralı, kilitli
  aday gerekçesi), :436-442 (kayıp nedeni sırası), :1303 (kurucu da satıcıdır), :204-206 ("önemli modül" sorusu).
- Ev: yıldız tabanı, uyum ve satıcı çarpanları, sınırlar, çürüme `SalesConstants`.
- PRD §4.4 m.2 (`sign_gate_reason`, `sign_single_loss`) düşer; yerine `close_chance_terms` (P'nin dört terimi ve sınırları;
  falsification: tavan kaldırılınca %100 çıkar) ve `loss_reason_order`.
- Kurucu yolu Sessiz 13; satıştaki söz Sessiz 37. Aday karışımı kısması `product_strength` kalkar (Sessiz 18).
- Kayıp nedeninin kimlikleri değişir; eski kimlik göçte temizlenmiştir (§5), C3a-2 ile C3b-1 arasında yazılmış dev kaydı Sessiz 32.
- PROBE `SIGN` `p= base= fit= seller= price=`; `REPLOSS`/`MLOSS` `reason= rival=`.
- Oyuncu: kayıp maili "Pythia'nın Stok'u daha derin" gibi tek nedenle; satışçının gidemediği aday gerekçeli kilitli.

**C3b-2 · B2B ürün sayfası.**
- Uygular: SENTEZ:1178 (ürün sayfasında sürekli modül sözcüğü yok), :65 (alan tabanlı beklenti kalkar), K1 (KARARLAR:80).
- B2B'de alan sözcüğü, kare, kart önizlemesinin "Zayıf → Yeterli"si, sürüm notunun "beklenen seviye" satırı, VC'nin en zayıf alanı
  kalkar; B2C aynen kalır. D'nin önerisi ve çeyrek şeridi B2B'de `MarketStandard`'ı okur (Sessiz 17).
- Kapı ağırlığı `--sprint-probe` (tahmin = sonuç); yeni smoke yok (arayüz).
- Oyuncu: B2B Ürün sekmesinde modül listesi ve kartlar; seviye sözcüğü yok.

**C3b-3 · 5 yıldız.**
- Uygular: SENTEZ:284-290 (bantlar), K:130-137 (dokunulacak yerler), SENTEZ:1185 (C1 notu: 5★ 6-20 birim).
- Ev: `SalesConstants.SEAT_BAND`, `STAR_MIX_*` (5 eleman, Sessiz 18), tek `STAR_MAX`. Eski 1-3★ bantları yenilerin içinde kalır
  (SENTEZ:1187): göç yok.
- Smoke `star_bands_five` (bant sınırı yıldızı belirler; falsification: 4★ bandı silinince düşer).
- PROBE `LEAD star=` 1-5. Oyuncu: 4-5★ aday seyrek gelir; muhatap ve soru sayısı Sessiz 19.

**C3b-4a · Fiyat verisi ve C3b-4b · Görüşme akışı.** Yardımcı yönetmenin 2026-10-22 cevabıyla bölündü (§9): 4a formülü, üç
duruşun verisini, temsilcinin duruşla satışını ve rakibin teklif verisini indirir; görüşmenin cetveli, sabrı ve karşı teklifi
yerinde kalır. 4b kurucu görüşmesinin akışını satış ve pazarlık PRD'sinden sonra yazar. Aşağıdaki maddeler ikisine birlikte
aittir; "Oyuncu" satırının üç düğmesi 4b'dedir.
- Uygular: SENTEZ:444-503 (formül, üç düğme, temsilci duruşu, rakip teklifi, hacim indirimi yok), :504-524 (kod haritası),
  :1304-1308 (§16 madde 15-17).
- Ev: P0, ağırlıklar, kalite primi sınırı, duruş fiyatı ve kapanış çarpanı `SalesConstants`; modülün sınıfı `erp.json`.
- Smoke `suggested_price_formula`: SENTEZ:469-471'in örnekleri (2 modül 39 $, 5 modül 57 $, 10 modül 84 $); falsification:
  sınır kaldırılınca "hepsi iyi" 71 $'ı aşar.
- Bot: varsayılan Standart; yeni preset anahtarı `stance`, değerleri koddaki `SalesConstants.STANCES` kimlikleri
  (`competitive`, `standard`, `premium`), fiyat kapısı için (SENTEZ:501-502).
- Oyuncu: üç düğme, her birinde koltuk fiyatı, aylık toplam, şans sözcüğü; tek satır gerekçe ve rakibin teklifi.

**C3b-5 · Kartlar.** SENTEZ:202-206, :418, :429-430, :297. Aday kartında modül adı ve sözcüğü, önemli modül işareti; "hiç
istemez" modül görünmez. Hesap kartında modül çipleri ayrı satırda (K2:224). Smoke yok; görsel kabul.

**C11b · Havuz.**
- Uygular: SENTEZ:776-785 (havuz, pay, toplam korunur, adlı rakip), :787-790 (satın alma), :729-733 (kasa, işe alma).
- Ev: havuz 2012, büyüme, yıldız dağılımı, hizmet payı, pay devri, çekim `rivals.json` (kaynağı `pazar2/sim/constants.json`).
- Smoke `market_pool_conserved` (Σ ≤ havuz, negatif yok; falsification: devir payı toplamı bozunca düşer).
- PROBE `POOL year= pool= share_player= rank=` (`PROBE MARKET` adı Piyasa listesinindir, `run_probe.gd:146`). Oyuncu:
  Finans'ta pazar payı gerçek pay; kayıpta "Pythia'ya geçti".

**C5-1 · Yenileme.**
- Uygular: SENTEZ:327-343 (koltuk tablosu, eşik max(1, %5), yıldız değişimi, 1★ büyümez), :350-362 (yalnız yenilemede ve adlı,
  ürün dışı düşük olasılık), :489-491 (fiyat yenilemede değişmez), KARARLAR:40 (tutma oranı), :44 (bütün satırlar).
- Ev: koltuk eşiği, gidiş, yeniden çekme, ürün dışı oranı `B2BConstants` (sim2.json).
- PRD §4.4 m.6'nın `renewal_outcome_named`'ı yeni adlarla sürer; `renewal_paper_once_a_month` düşer.
- Yenileme günü imza gününün yıldönümüdür; eski kayıtta geçmiş yıldönümü bir sonrakine düşer (toplu yenileme yok).
- PROBE `RENEW day= id= seats= star= reason=`; `PROBE END` `retention=`.
- Oyuncu: "Anadolu Gıda büyüdü (180 → 230 çalışan): +12 koltuk"; sözleşme ortasında hesap ayrılmaz.

**C5-2 · Şart.**
- Uygular: SENTEZ:649-650 (şart), :657-658 (memnun hesap istek söyler), :361-362 (büyük hesap şartla konuşur), :1187 (C4'ün düzeni).
- Ev: kontrol haftası 8, şart süresi 13 (sim2.json), düşük yıldızın şart olasılığı `B2BConstants`.
- Smoke `renewal_condition_timeline` (açılır, karşılanınca yeniler, iki adımda adlı ayrılır; falsification: süre dolumu
  okunmayınca düşer). Yeni `full_run_idle` kolu (geliştirmeyi bırakan, G4) bir koşu.
- Oyuncu: "Rakiplerde olan Depo ve Sevkiyat sizde zayıf; yenilerken bunu istiyoruz." ve hesapta tarihli "Şartlı" etiketi.

**C6-1 · İstekler.**
- Uygular: SENTEZ:649 (istek satırı), :669-676 (olasılık), :678-688 (birleştirme, mail bütçesi), :489-490 (genişleme fiyatı),
  :1309 (derinlik yalnız pazardaki seviye), KARARLAR:39 (temsilci şartı yok), :59 (kartın adı isteğin konusundan).
- Ev: olasılıklar, ömür 13 hafta (SENTEZ:1124), bekleme satırı, mail bütçesi `B2BConstants`.
- PRD §4.4 m.7'nin `requests_three_star_only`'si sürer. C7'nin ertelediği `support.sec_asked`, `support.new_request`
  (E1:201-202) burada; rapor modül toplamını yazar.
- Smoke: dört yeni vaka; falsification: L üstü derinlik istenince ya da aynı modüle iki kart açılınca düşer.
- PROBE `REQ week= cards= open= mails= queued=`. Oyuncu: sprintte "Stok 6 · 14 hesap istiyor · 3'ü şartlı · 21.000 $".

**C6-2 · Genel Bakış.** PRD Karar 10 (`:304-318`) B2B'de seviye sözcüksüz; SENTEZ:684 şart şeridi. "Son 4 haftada N kesinti"
için kayıt (C0v `:481-483`). Düzeltme kartını SPRINT'te bir kez vurgulayan tek işlev; C7'nin düğmesi ve D onu okur.

**C8 · HESAPLAR.** PRD Karar 13 (`:357-367`) ve SENTEZ:1194 (sektör, modüller, yıldız, çalışan · koltuk, gidiş, yenileme
tarihi, şart sütunları). Durum etiketlerine "Şartlı" eklenir; "Yenilemeyebilir" ve "İlgilen" Sessiz 36. Sıra ve görünüm kayda
yazılmaz. Gelen kutusu hatırlatıcısına dokunulmaz (KARARLAR:38). 330 satırın kurulma süresi tik probuyla.

**C12 · Rapor ve ödül.**
- Uygular: SENTEZ:588-616 (Kasım, 1 Ocak-31 Ekim, dört bölüm, ödül kuralı, ×1,3 / 12 ay, B2C'de ödül yok), :618 (kurallar yazılı),
  :615-616 (rakip ödül alınca aynı çarpan onun pay çekimine yazar: `rival_registry.gd`). B2C raporunun kaynağı Sessiz 38.
- Ev: ödül çarpanı ve süresi `SalesConstants` (aday akışının evi); kullanıcı eşiği N, büyüme tabanı, en az bir yıl
  `MarketReport` sabitleri.
- Smoke `yearly_report_november` (yılda bir, şirket başına modülde en çok bir ödül; falsification: ay kapısı kaldırılınca düşer).
- PROBE `REPORT year= big= fast= awards=`. Oyuncu: Kasım'da tek mail; "Yılın Stok modülü: Werktag" ve kendi modül durumu.

## 5. Kayıt ve göç

- **Tek göç adımı C3a-2.** Numara: iniş anındaki sıradaki numara (bugün 18; D1 önce inerse C'ninki 20). Zincire
  `if version < N: _migrate_<N-1>(state)` eklenir; `CLAUDE.md` §6'nın şema satırı aynı commit'te. `MIN_LOADABLE_VERSION` 10 kalır.
- **Göçün aldıkları:**
  - Finans birleşmesi: `line_erp_cashflow`'un kademesi `line_erp_ledger`'a en büyükle; açık hataları, istekleri, rakip izleri
    ve saklı kartları Finans'a taşınır; yayımlanmış hiçbir kademe kaybolmaz.
  - `Customer.modules` (profil + yıldız + kimlik özütüyle belirlenimci), çalışan sayısı (koltuk ÷ oran), gidiş (aynı özütle
    sim2 ağırlıkları), `o` için imza yıldızı (bugünkü `scale`); `Prospect.modules` ve önemli modül aynı kuralla.
  - `trust_offset` defterde 4 haftalık tek satır olur, alan silinir (PRD:564).
  - Alan hedefli kayıp izi (`weak_area` ve `_migrate_17`'nin çevirdiği `stability`): `sales_account_memory`'nin
    `loss_reason`/`loss_target`'ı ve adayın `last_loss_reason`'ı boşalır (dönen adayın engeli kalkmış sayılır),
    `sales_loss_log`'un bu satırları düşer. Neden: C3b-1'in kayıp kimlikleri modül hedeflidir, alanı modüle çeviren kural
    yoktur (Sessiz 32). `_migrate_17`'nin `_retire_stability` bloğu bu yüzden C3a-2'de gider.
- **Göçten önce inenler** (C3a-1, C10) kayda yalnız anlamlı varsayılanlı alan ekler, kimlik silmez ya da birleştirmez.
  **Göçten sonrakiler** yalnız varsayılanlı alan ve vaka ekler: rakip durumu (C11a; boş = katalogdan bugüne ileri sar), şart
  alanları (boş = şart yok), rapor bayrakları. Silinen alan göç istemez (`SaveCodec.res_from_dict` yalnız modelin `@export`
  alanlarını okur, `save_codec.gd:86-89`): `market_ref` C3a-3'te, Risk alanları C5-1'de böyle gider; `_migrate_17`'nin kalan
  `market_ref` bloğu ve `if version < 18` kolu C3a-3'te gider. 1★-2★'ın açık istekleri C6-1'in kuralıyla düşer.
- **Kanıt:** `save_v<N>_market_model`: v18 fikstüründe Finans'ın kademesi iki eski hattın büyüğü, alanlar dolu ve belirlenimci,
  `weak_area` izi temiz, defter satırı eski `trust_offset`'e eşit (defter ve hata terimi yüklemede değişmez; ürün terimi C3a-3'e kadar Sessiz 5).
  Sonraki adımlar bu vakayı genişletir, göç koduna dokunmaz.

## 6. Düşen eski plan

| Madde | Kaynak | Neden düşer | Nerede silinir ya da yazılmaz |
|---|---|---|---|
| İmza kapısı (eşik + 10), `sign_gate_reason`, `sign_single_loss` | PRD:208-218, :550-551 | P'de kesin kayıp ve kazanç yok (SENTEZ:393) | C3b-1 yazmaz |
| Zar tabanı %60 | PRD:213, E1:338 | SENTEZ:49, :402 | C3b-1 yazmaz |
| Q'nun `CLOSE_CURVE`'ü ve `loss_area` kısa devresi | `product_quality.gd:30`, `:233-241` | SENTEZ:402-403 | C3b-1 |
| Sektör `TABLE`, `emphasis`, `used_areas`, `uses_area`, `market_ref`, `account_fit`, `prospect_fit` | RAPOR_Q:243-262 | SENTEZ:75, :1177 | `used_areas`, `uses_area` C3a-2; `market_ref`, `account_fit` C3a-3; `prospect_fit` C3b-1; `TABLE`, `emphasis` C6-1 (son okuyucu) |
| B2B'nin `CORE_2`, `EMPHASIS_*`, 2★ sayfa referansı; "2★ Çekirdek 1,25 mi 1,5 mi" | `product_quality.gd:37-41` | SENTEZ:1178-1179 | C3b-2 |
| Güncelleme yaşı (26 hafta, −1 / 4 hafta, iki vurgu alanı), `update_age_emphasis_only`, `last_touch_day` | PRD:231-240, :559 | Ayrı sürüm ritmi cezası yok (KARARLAR:124, SENTEZ:53, :891) | C3a-1 yazmaz |
| Durum terimleri zam −2 ve gönülsüz yenileme −6 | PRD:190 | Yenilemede fiyat ve kâğıt yok (SENTEZ:491) | C3a-1 yazmaz |
| Yenileme tutum bantları (+%8 … −%15), satışçı raporu iki seçenek, kurucu teklifi ve karşı teklif, cevapsız kâğıt | PRD:243-246 | SENTEZ:489-491, §16 madde 16 | C5-1 yazmaz |
| Yıldız başına koltuk artış tabanları (1★ %25 …), sektör ×1,25 / 1 / 0,75, azalış %5 / 4 / 3, başka ürüne geçiş %1,5 / 1 / 0,5 | PRD:253-258 | Erdem K3 (SENTEZ:1192); gidiş ve şart yerine geçer | C5-1 yazmaz |
| 13 sektörün eğilim tablosu ve `sector.trend_*` | PRD:263-264 | Gidiş olasılığı yerine geçer (SENTEZ:329-331) | C5-1 yazmaz (Sessiz 23) |
| "Yıldız imzada sabittir" | PRD:262-263 | Bant aşınca yıldız değişir (SENTEZ:338) | C5-1 |
| Yenileme kâğıdı, ayda bir kâğıt, `renewal_paper_once_a_month`, kâğıtlı ay sayısı | PRD:265-275, :557 | Kâğıt yok; şart ve mail bütçesi (SENTEZ:680-686) | C5-1, C5-2 yazmaz |
| Bütçe kesintisinde memnun hesabın koltuğu yarıya inmesi | PRD:296-298 | Ürün dışı ayrılma ayrılır, adlı, kayıp sayılır (SENTEZ:355-356, Erdem 2026-10-17) | C5-1 yazmaz |
| `market_ref` tetikleyicisinin yenileme açılışına taşınması | PRD:277-279 | `market_ref` kalkar | C3a-3 (`sprint_bridges.gd:35-36` silinir) |
| Kesinti tablosunu C5'in kurması (sıra DPLAN2'nin tek veri satırında kalır, C5 devralır ve değiştirmez) | PRD:270-272, DPLAN2:85, :147 | Yenileme ve istek kesintisi yok | Sessiz 21 |
| İsteğin "Söz ver / Listeye al" kesintisi, decline −4, süre −5, istek kesintisi ≤ 25 kapısı | PRD:325-328, :344 | Mail ve modül kartı (SENTEZ:680-686) | C6-1 (Sessiz 20) |
| `customer.expansion` tek seferlik koltuk satışı | `b2b_constants.gd` `EXPANSION_SEATS` | Koltuk yalnız yenilemede (SENTEZ:330) | C5-1 |
| Sözleşme ortası Risk geri sayımıyla ayrılma, "Oyala" | PRD:191-192 ("Risk makinesi kalır") | Ayrılma yalnız yenilemede (SENTEZ:352) | C5-1 (Sessiz 8) |
| ERP'nin sabit çıkış tablosu (`rivals.json` `erp.launches`) ve ERP için kalite eksenli Model A | `rivals.json`, `rival_catalog.gd:33` | SENTEZ:801-806 | C11a (B2C kalır, §16 madde 10) || `MARKET_TOTAL_MRR` (ERP) | `rival_catalog.gd:144` | SENTEZ:782-785 | C11b |
| PRD §4.1 M kapıları (C0s simi), M13 | PRD:483-498 | Memnuniyet simi yeni modelden önce | E2 ölçmez |
| W1'in `renew.*`, `budget_mail.*`, `sector.trend_*`, `sign.*`, `sat.term_raise/reluctant`, `sat.renewal_reading`, `sat.term_market_moved` | `W1_METINLER.json` | Yukarıdaki satırlar | W2 işaretler, koda girmez |
| C0v E1 soruları 10, 23, 24, 25, 27, 29, 31 | E1:323-342 | U ve `area_row` B2B'de kalkar | Konusuz |

## 7. E2'ye etkisi

E1:454-464'ün listesi sürer: madde 1 (evre 2 ve 3 ekonomisi) artık yeni fiyatla gelir ve gider birlikte ölçülür (SENTEZ:1186);
2, 3, 4, 5 ve 6 aynen. Eklenenler (SENTEZ:1088-1105'in kapıları; demo dilimi 104 hafta, tohum 7 ve 11, B2B):
- G4 durgunluk: `full_run_idle` kolu B2B MRR'ının ≥ %40'ını kaybeder, kayıpların ≥ %95'i adlı, kaybedilenlerin ≤ %30'u 1★.
- G5 ses: haftalık müşteri maili medyan ≤ 2, p99 ≤ 5; sprint başı istek kartı p95 ≤ 3; şartlı yenileme yılda ≤ %25.
- G6 koltuk: koltuğu değişen yenileme %20-50, yıldız değişimi ≤ %10, 1★'ın büyüyen payı ≤ %10, 1.000 koltuk üstü yok.
- G7 satış: eşleşen satıcı ve tam uyumda 1★ %75-92, 5★ %45-60; bir alt satıcı 0,5-0,75 kat; %100 yok (`PROBE SIGN`).
- Demo: 104 haftada 5★ kapatan tohum ≤ %5; 4★ yalnız satışa yatırım yapan kolda.
- Fiyat: `stance` kollarında hiçbir duruş tohumların %80'inden fazlasında en yüksek MRR'ı vermez.
- G8 havuz ihlali 0; G12 `--tick-probe=3:accounts=330` rakiplerle ≤ 148,2 ms.
- Rapor: güçlü kolda ödül yılların bir kısmında, durgunda hiç; bilgi olarak, demo iki rapor görür (SENTEZ:590).
- G11 (50 kişide gelir / gider 1,2-2): yalnız D0a'nın 50 kişilik bot dünyası varsa; yoksa "ölçülmedi" yazılır.
Düşenler: PRD §4.3 Risk 1'in "yenileme ≥ %90" ve "yalnız Çekirdek kolunda yaş terimi" satırları (PRD:516-524), yenileme
kâğıdı ve istek kesintisi sayımları (PRD:541-542), M1-M13. G1, G2'nin geç yarısı, G3, G9 dönem fazına kalır: K4 olmadan
rakipler K3'e yapışır ve G1 bilerek düşer; E2 bunu bilinen sonuç olarak yazar.

## 8. Sessiz ya da çelişkili yerler

Numaralar sabittir (tablo ve §4 onlara atıf yapar). İnceleme turunda sentezin ya da PRD'nin zaten cevapladığı dört madde
(10, 11, 12, 28) "kapandı" diye işaretlendi; yeni bulgular 32-38.

1. **SENTEZ:1190 ve K2:209.** C3a satırı göçe Finans birleşmesini yazmıyor; birleşme kayıt kimliği sildiği için göç ister.
   Etkiler: C3a-2. Öneri: 10 modülün yeniden yapısı tek göç adımında (C3a-2), birleşme aynı göçte. Karar gerekmez (göç
   sorulmaz yapılır); bilgi olarak duruyor.
2. **SENTEZ §14.** 10 modül, profil, 5 yıldız, rakip modeli, havuz, dönem tavanı ve yıllık raporun sahibi yazılı değil.
   Etkiler: hepsi. Öneri: §2'deki gibi C adımları; Ar-Ge tavanı, dönem düğümleri, mevzuat ve K4+ C sonrası dönem fazına.
3. **SENTEZ:120-152 ve `product_lines.gd:39`.** 10 modülün iş profili (dev / test / design) yazılı değil; `IDENTITY_PROFILE_SHAPE`
   2 / 1 / 2'yi zorlar ve D'nin aşama payı profili okur. Etkiler: C3a-2, D1. Öneri: eski dört hat profilini korur, yeni altısı
   `erp.json`'da [WORKING]; doğrulayıcı yalnız her profilin en az bir modülde olmasını ister; D'ye bildirilir.
4. **`product_lines.gd` "Ar-Ge düğümü her K3'te" doğrulayıcısı (K2:199).** Yeni altı modülün K3 düğümü yazılı değil.
   Etkiler: C3a-2. Sentez yönü yazıyor (SENTEZ:1214: 14 K3 bugünkü 12 düğüme düşer), eşleme yazılı değil. Öneri: bugünkü
   12 uygun düğümden (K2:208) yakın olanı; yeni düğüm yok; eşleme commit'te HARITA'ya.
5. **Sıra sonucu (SENTEZ:1177-1178, `sprint.json:131`).** 10 modül C3a-2'de Çekirdek kimlik hattı olur; Q'nun aday uyumu
   C3b-1'e, B2B sayfa sözcüğü C3b-2'ye kadar 10 modülün ortalamasını okur ve düşük çıkar. Etkiler: C3a-2 ile C3b-2 arası
   (C11a, C3a-3, C3b-1 dahil dört commit). Öneri: bu commit'lerde `run_gate` yalnız "son var, ERROR yok" diye okunur; ekonomi ve
   kapanış ölçümü C3b-2'den sonra.
6. **SENTEZ:652-656.** Ürün terimi kalkınca memnuniyetin tabanı yazılı değil. Etkiler: C3a-3. Öneri: tek sabit taban
   `B2BConstants` [WORKING] 70 (PRD:208 "beklentiyi karşılayan üründe 65 ile 70"); eksik ve geride modül adlı eskime satırıdır.
7. **SENTEZ:896 ile PRD:182-185.** Sentez hata terimini bugünkü kodla (açık hata başına −0,3, tavan −20) anar; PRD Erdem'in
   onayıyla min(3 × H, 60) der. Etkiler: C3a-1. Öneri: PRD'nin terimi (sentez bugünü anlatıyor, değiştirmiyor).
8. **SENTEZ:352 ile PRD:191-192.** "Ayrılma yalnız yenilemede" ile "Risk makinesi kalır" çelişir. Etkiler: C5-1. Öneri:
   Risk geri sayımı ve "Oyala" C5-1'de silinir; "Ayrılabilir" etiketi memnuniyet eşiğin altındayken yenilemede ayrılacağını
   söyler; elde tutma kartının indirimi +8 durum terimiyle kalır; gelen kutusu hatırlatıcısı kalır (KARARLAR:38).
9. **SENTEZ:334-336 ile `b2b_constants.gd` toleransı.** "Memnun" ve "düşük" sim2'nin mutlak 80 / 50'siyle yazılı; kod hesap
   başına tolerans okur ve C4'ün fesih kuralı ona bağlı. Etkiler: C5-1, C5-2. Öneri: memnun = eşik + 12 (PRD:251), düşük =
   eşiğin altı; sim2 sayıları yalnız sim'de kalır.
10. Kapandı: sentez cevaplıyor. Ürün dışı ayrılan hesap ayrılır, adlı, kayıp sayılır (SENTEZ:355-356, Erdem 2026-10-17);
    PRD'nin "koltuğu yarıya indirip yeniler" kuralı düşer (§6).
11. Kapandı: Erdem 11 ve SENTEZ:53 ayrı ritim cezasını kaldırdı; güncelleme yaşı yazılmaz (§6).
12. Kapandı: PRD Karar 6'nın "aynı formül, defter boş" kuralı sentezle çelişmez ve sürer (C3a-1 ayrıntısı).
13. **SENTEZ:404 ve :483.** Kurucu görüşmesinin ibresi kalırken teklifin "kapanış zarıyla" kabulü iki zar mı tek zar mı
    yazılı değil. Etkiler: C3b-1, C3b-4. Öneri: tek zar; ibrenin ürün terimi modül uyumu, yıldız terimi satıcı çarpanı; üç
    düğme son zardan önce seçilir ve fiyat çarpanı aynı zara girer; cetvel, sabır ve karşı teklif silinir.
14. **SENTEZ:735-743 ve DPLAN2:77-78.** Rakibin haftalık puanı D'nin birimine bağlı: D1 `person_points_week`'i ×5 yapar
    (2 → 10), D2a kişinin hızını Y(s) eğrisine taşır ve kadro tavanını ⌈ihtiyaç ÷ 8⌉ yapar (D_PLAN.md:586 sonunda siler).
    Etkiler: C11a. Öneri: rakip tek yardımcıdan (kişi başı haftalık puan × ekip) okur; D1 ya da D2a C11a'dan sonra inerse o
    adım yardımcıyı bağlar; kart başına kadro tavanı [WORKING] 6 (sim) D2a'nın kuralı gelene kadar.
15. **SENTEZ:707-733 ve K:197.** Eski kayıttaki rakip durumu yazılı değil. Etkiler: C11a. Öneri: boş durum 2012 katalogundan
    `GameState.day`'e belirlenimci ileri sarılır; yeni ve eski koşu aynı işlevden geçer, göç yok.
16. **SENTEZ:150 ile :299.** Platform hatları "her hesap kullanır" ama uyum, eskime ve şart modül listesinden okunur mu yazılı
    değil. Etkiler: C3a-2, C3a-3, C3b-1, C5-2. Öneri: uyum, eskime, şart yalnız modüllerden; platform hatları hata terimine
    girer, mevzuat şartı dönem fazında.
17. **SENTEZ:1178 ile RAPOR_Q:305-306 ve DPLAN2:84 (D8a öneri).** B2B sayfa sözcüğü kalkınca D'nin önerisi ve çeyrek şeridi `next_star` /
    `next_ratio` okuyamaz. Etkiler: C3b-2, D8a. Öneri: C3b-2 B2B'de sözcüğü kaldırır, D'ye `MarketStandard` okuyucusu verir
    (modülü isteyen hesapların MRR'ı ve S'ye uzaklığı, ekranda sayı değil); D8a'dan önce inerse öneriyi geçici olarak buna bağlar.
18. **`sales_faucet_system.gd:165` `product_strength`.** Yıldız karışımını ürün uyumuyla kısan terim yeni modelde karşılıksız.
    Etkiler: C3b-1, C3b-3. Öneri: silinir; evre başına 5 elemanlı karışım [WORKING]; zayıf ürün uyum çarpanıyla kaybeder.
19. **K:112 `counterpart_system.gd:20`.** "Karşı masada yıldız kadar kişi" 3 rolle sınırlı; 4-5★ muhatabı ve soru sayısı yazılı
    değil. Etkiler: C3b-3. Öneri: muhatap en çok üç kişi; soru sayısı 4★ ve 5★'ta 5 [WORKING].
20. **SENTEZ:686 ("söz isteğe bağlı hamle").** İstek kesintisi kalkınca sözün nerede verildiği yazılı değil. Etkiler: C6-1, C8.
    Öneri: satıştaki söz kalır; açık isteği olan 3★+ hesabın satırında "Söz ver" düğmesi (C8; C6-1'de hesap kartında).
21. **PRD:270-272 ve DPLAN2:85, :147.** DPLAN2 kesinti sırasını `sprint.json`'da tek veri satırına koyar ve "C5 devralır"
    sözleşmesini yazar; yeni modelde C'nin kesinti kâğıdı yok (yenileme kâğıtsız, istek mail bütçesiyle). Etkiler: C5, D3b.
    Öneri: kabul edilen sözleşme aynen: C5 satırı devralır, sırasını değiştirmez ve ona tür eklemez (C'nin kâğıdı yok);
    D3b gönder sorusunu kendi satırıyla koyar; RAPOR_C yazar. Karar gerekmez, bilgi.
22. **E1:326-339 "bekler: C3a".** C0v soruları 13 (B2C destek zararı), 15 (her sprint −3), 21 ("Hayır diyemez"), 22 ("Söz ver"
    +8), 26, 28 hâlâ açık. Etkiler: C3a-1. Öneri: C0v'nin önerileri (C0v_ADIM_EKLERI:858-865, :871-875, :903-910, :928-939).
23. **SENTEZ:329-331.** Gidiş "sektörün dönem eğiliminden" çekilir; sektör tablosu yok. Etkiler: C3a-2, C5-1. Öneri: sim2'nin
    büyüyen / durağan / küçülen %30 / %45 / %25'i (2★-5★), 1★ çoğunlukla durağan; sektöre göre ağırlık yazılmaz.
24. **SENTEZ:649-650 ve `customer.gd:94-95`.** Şart C4'ün düzenini kullanır; aynı hesapta Kurumsal madde ve modül şartı birlikte
    olabilir. Etkiler: C5-2. Öneri: şart için ayrı alanlar (modül, seviye, son gün); aynı `month_ended` kuralı ve etiket biçimi.
25. **SENTEZ:455.** Standart S = 0 olan modülde (kimse yayımlamamış) r = q / q_std tanımsız. Etkiler: C3b-4. Öneri: q_std en az K1.
26. **SENTEZ:618.** "Kurallar yardım metninde" diyor; oyunda yardım ekranı yok. Etkiler: C12. Öneri: rapor mailinin son
    paragrafı kuralları yazar.
27. **SENTEZ:820-854 ve SORU_PAKETI_3.** Dönem tablosunun mevzuat, dönem düğümü, yeni girişim ve YZ satırlarının sahibi yok;
    `ai_engine` 2012'de açık (SENTEZ:1209). Etkiler: C10. Öneri: C10 yalnız tavan; `ai_engine` YZ cevabına kadar dokunulmaz;
    kalanı C sonrası dönem fazında (D'nin K4+ kataloğu ve Ar-Ge ile).
28. Kapandı: SENTEZ:805-806 ve §16 madde 10 B2C rakiplerini bugünkü modelde bırakır; uygulaması C11a ayrıntısında.
29. **DPLAN2:121 (D8c derinlik kartları) ile SENTEZ:217-223.** K3 sonrası arzı D'nin derinlik kartı da dönemin K4'ü de veriyor;
    standart hangisini sayar yazılı değil. DPLAN2 D8c'yi kart yenilemesine erteledi (DPLAN2:121), yani C boyunca soru
    uykuda. Etkiler: C11a, dönem fazı. Öneri: rakip yalnız kademe kartıyla yürür, standart yalnız kademeyi sayar; çakışma
    dönem fazında D'nin kart yenilemesiyle kapanır.
30. **`docs/tasks/PRD_RAKIP_DUNYASI.md` I2 ve I3.** Bu PRD'nin "hafif rakipler + kalite çıtası" ve "dönem" artırımları sentezle
    örtüşüyor; sentez onu anmıyor. Etkiler: C10, C11a. Öneri: ERP için sentez geçerli; C11a commit'i o PRD'nin I2 ve I3
    satırlarına "Pazar 2 sentezine geçti" yazar (eski belge düzeltilir).
31. **SENTEZ:1222-1223.** "9 hat × 3 kademe = 27" mührünün GDD'ye yazımı sahibin kararı deniyor; Erdem 26 10 modülü seçti.
    Etkiler: C3a-2. Öneri: C3a-2 `GUNCELLEMELER.md`'ye "ERP 10 modül + 4 platform hattı, modül başına K1-K3" yazar, smoke mührü
    yeni sayıya döner.
32. **`save_manager.gd:969-994` ve SENTEZ:436-440.** Kayıtta kayıp nedeni alan hedeflidir (`weak_area` + alan kimliği; hafıza,
    aday ve kayıp günlüğü) ve dönen adayın engelini o okur (`sales_ledger.gd:347-354`); yeni nedenler modül hedeflidir ve
    alanı modüle çeviren kural yok. Etkiler: C3a-2, C3b-1. Öneri: C3a-2'nin göçü alan hedefli izi temizler (§5); C3a-2 ile
    C3b-1 arasında yazılmış kayıt yalnız geliştirme kaydıdır, C3b-1 tanımadığı eski kimliği hafızasız okur.
33. **DPLAN2:83 ve :148 ile PRD:182-185.** Kabul edilmiş sözleşme "C3a terimi `SprintCatalog`'daki k ile kurar" der, ama k'yi
    D7 kurar ve D7 D'nin sırasında geç gelir (DPLAN2:92-93); C3a-1 C'nin ilk kod adımıdır. PRD'nin H'si hat başına yoğunluk
    olduğu için k'nin terimde nereye girdiği de yazılı değil. Etkiler: C3a-1, D7. Öneri: k'nin tek evi `sprint.json`
    `bugs` bloğudur (D3'ün c'sinin yanı); ilk ihtiyaç duyan adım onu [WORKING] 1 ile ve `SprintCatalog` okuyucusuyla kurar, D7
    yalnız değerini yazar; C3a-1 k'yi H'ye (hata terimi) ve `COMPLAINT_BUG_GATE`'in yerine gelen eşiğe çarpan olarak uygular.
34. **SENTEZ:1190 ile :897.** C3a'nın yeni satırları arasında "Şart: <modül>" var; aynı modül eskime satırıyla memnuniyeti
    zaten düşürür, şart satırının tutarı yazılı değil (ikisi birden çift sayım olur). Etkiler: C5-2. Öneri: şart satırı
    defterde tutarsız bilgi satırıdır (tarih ve modül); bedeli eskime satırı ve yenilemedeki ayrılma taşır.
35. **SENTEZ:795-797 ile DPLAN2:32, :39.** Gece tikinin 148,2 ms kapısı için sentez C1 sonrası 146,36 ms (marj 1,84) der,
    DPLAN2 RAPOR_Q'nun 133,6 ms'sini (marj ~15) taban alır. Yardımcı yönetmen planı ayrı bütçeye aldı (≤ 100 ms, DPLAN2:39);
    gecenin geri kalanı 148,2'de kalır ve C11a'nın rakip adımı ile C3a-3'ün haftalık hesap taraması o kalan payı paylaşır.
    Etkiler: C11a, C3a-3. Öneri: C3a-1'den önce HEAD'de `--tick-probe=3:accounts=330` bir kez koşulur ve taban RAPOR_C'ye
    yazılır; aşan adım commit'ten önce durur, ilk çare DPLAN2'deki gibi oynanışı değiştirmeyen yol (hesap
    karelere bölünür), yetmezse ölçümle yardımcı yönetmene gelir.
36. **PRD Karar 13 (`:357-367`) ile SENTEZ:489-491.** HESAPLAR'ın "Yenilemeyebilir" durumu ve "İlgilen" düğmesi eski yenileme
    tutum bantlarından geliyordu; bantlar düştü. Etkiler: C8. Öneri: "Yenilemeyebilir" kalkar, yerini "Şartlı" alır; "İlgilen"
    PRD'deki işiyle aynı kalır, yalnız "Ayrılabilir" ve "Şartlı" satırında görünür.
37. **SENTEZ:386-389 ve §16 madde 7 ile :393.** Satıştaki söz "kapanışı yükseltir" ama P'nin dört teriminde söz yok.
    Etkiler: C3b-1, C3b-4. Öneri: sözü verilen modül uyum teriminde "seviyede" (×1) sayılır; söz kırılırsa bugünkü
    `PromiseRegistry` defter satırı; yeni terim yok.
38. **SENTEZ:607 ve :805-806.** B2C raporu "en büyük ve en hızlı büyüyen platformlar" yazar, ama B2C rakipleri hesap ve havuz
    taşımayan bugünkü modelde kalır. Etkiler: C12. Öneri: B2C raporu bugünkü Piyasa değer eğrisinden (`rival_registry.gd`)
    sıralar; ödül bölümü yok; hesap sayısı yerine değer yazar.

## 9. Yardımcı yönetmenin cevapları (2026-10-22)

- C0p ve W2 hemen başlar: Godot yok, yalnız `c_taslak/`'a yazar, D ile paralel. Kod adımları Erdem'in iki şerit için
  "evet"ini ve Q'nun K20 commit'ini bekler.
- Sessiz 2 onaylı: 10 modül, profiller, 5 yıldız, rakip şirketler, havuz, dönem tavanı ve yıllık rapor C'nin. Ar-Ge tavanı,
  dönem düğümleri, mevzuat ve K4+ dönem fazında.
- Sessiz 13 açık kalır: B2B pazarlığının hissi Erdem'in açık konusu, satış ve pazarlık PRD'sinde kapanır. Görüşmedeki
  cetvel, sabır ve karşı teklif şimdi silinmez. C3b-4 bölündü: C3b-4a (önerilen fiyat formülü ve üç duruşun verisi) yerinde,
  C3b-4b (kurucu görüşmesinin akışı) zincirin sonunda, o PRD'den sonra.
- Sessiz 8 onaylı: Risk geri sayımı ve Oyala sentezle C5-1'de silinir (Erdem'e bilgi olarak gidiyor).
- Sessiz 22: C0v'nin önerileri [WORKING] girer; RAPOR_C'de "onay bekliyor" diye listelenir.
- Sessiz 5 onaylı, şartla: C3a-2 ile C3b-2 arasındaki commit'ler tek parça sayılır, aralarında push yok.
- Kalan maddeler (1, 3, 4, 6, 7, 9, 14-21, 23-38): önerilen varsayılanlarla.

## 10. C0p ve W2 (2026-10-22)

- `C0p_HARITA.md` (HEAD `cf452525`): her kod adımının dosya:satır eki. Plan ile C0p çelişirse kodlayıcı C0p'yi (HEAD) esas
  alır. C0p'nin bulduğu plan sapmaları (C0p'nin sonundaki §S): "9 hat × 3 = 27" mührü `product_lines_catalog_loads` ve
  `research_node_map_binds`'tadır; `IDENTITY_*` sabitleri bütün alt türlerde tek değerdir (ERP için alt tür başına değer
  gerekir); `CORE_2`, `EMPHASIS_2`, `CORE_3`, `EMPHASIS_3` B2C'de de okunur (C3b-2 yalnız `REST_3`, `W_B2B` ve `weights`'in
  B2B kolunu siler); `ProductQuality.STAR_MAX` sayfa yıldızıdır, satış yıldızı `SalesConstants.STAR_MAX`; `COMPOSITE_AXES`'te
  ERP satırı yoktur; `_rival_ahead` dev rakip yüzünden fiilen hep doğrudur; "Yenilemeyebilir" kodda yoktur (yalnız W1
  metni); C3a-1, C3a-2, C3b-1, C5-1, C6-1 ve C11b'nin eksik okuyucu ve smoke listeleri C0p'dedir.
- `W2_METINLER.json` ve `.md`: 232 metin, 97 W1 düşüşü, `w2check.py` fail=0. Aynı id ile yeniden yazılan beş W1 öğesi
  (`sat.term_bugs`, `sat.term_discount`, `support.new_request`, `ov.request_b2b`, `accounts.col_seats`) W1_E1 gibi ezer.
  Eşlik denetimi: `w1parity.py --override W1_E1.json` ve ardından W2. Erdem'in tek metin turu W2 üstünde yapılır.
