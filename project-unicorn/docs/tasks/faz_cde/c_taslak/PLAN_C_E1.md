# Faz C · E1 cevabıyla plan (PLAN_C_E1)

2026-10-20 · Taban `main` @ `e4e7e9b` (Q K11). Kod satırları HEAD'e göredir (`git show HEAD:<yol>`), çalışma ağacı okunmadı.
Girdiler: `ERDEM_KARARLAR_2026-10-20.md` (K1 ile K16 bu belgede "Karar n"), Erdem'in C9 cevabı (bu oturum), `PLAN_C.md`,
`C0v_ADIM_EKLERI.md`, `C0q_TAZELEME.md`, `C0S_SONUC.md`, `C0m/C0M_KARELER.md`, `W1_METINLER.json`, `arastirma/RUNWAY_GOSTERIM.md`.
PLAN_C'nin akışı (Sonnet kodlar, Haiku kapı, Opus inceler, commit'i ana oturum yapar) ve korumaları aynen geçerlidir.
Bu belge yalnız farkı yazar.

**Q'nun yeni commit'leri ve C'ye etkisi** (`git diff --stat 910ad1f..HEAD`: 18 dosya, +60 −104)
- K10 (takvim 2012): `game_state.gd` 676. satırdan sonrası −1 kaydı (`initialize_run` `:895`); `finance_ozet_view.gd:252`,
  `inbox.gd:515`, `fmt.gd:77-80` tek satır. C2 ve C9'un satırları (`finance_ozet_view.gd:383-400`, `game_state.gd:48,95-96,299`)
  yerinde. Kurumsal madde etiketi ve takvim `Fmt.date_line` ile 2012'den sayar; ek iş yok.
- K11 (14 CSV anahtarı): `strings.csv` satırları C0v'den kaydı. HEAD'de: `ONB_DOC_BURN :101`, `PROD_RND_NODE_INCIDENT_PLAYBOOK
  :572, :2202-2203`, `OFFICE_REQ_* :2701-2707`, `OFFICE_CARD_DESKS :2715`, `OFFICE_HOVER_LINE :2727`, `FIN_BURN_TOOLS :3008`,
  `FIN_BURN_SERVICE :3009`, `HR_ROW_TOOLS :3019`, `SALES_LOCK_PROVIDER :2465`. `hr_constants.gd` yalnız `:1086` sonrası
  değişti (bantlar `:591-598` yerinde). `endgame_smoke.gd` `:7895` sonrası −8 kaydı; aşağıdaki vaka satırları HEAD'dendir.
- Outsource silmesi (Karar 24) çalışma ağacında sürüyor (`sprint.json`, `seams_product.gd`, `sales_meeting_system.gd`): C1
  bu dosyalara dokunduğu için C, Q "bitti" demeden başlamaz (Kod sırası 2).

## 1. Karar → adım

| Karar | Erdem'in sözü | Adım | Ne değişir (PLAN_C'ye göre) |
|---|---|---|---|
| 1 | "A: dolu sunucu yalnız kesinti ihtimalini artırır; tavan çarpanı yutmaz" | C1 | Yük katı yalnız kesinti türünün payına ve `p_max` kırpmasından sonra işler (C0v soru 1 ve 2'nin önerisi). |
| 2 | "bugünkü kalsın: Standart $120 / 50 koltuk, $250 / 1.000 kullanıcı" | C1 | K2 onaylı: B2B 60/120/240, B2C 125/250/500. M12'nin %8 ile %12 hedefi kapı değil, yalnız raporlanır. |
| 3 | "peşin bedel iki aylık kira; ofisin tek şartı para" | C9a | Şart listesi (çek, ekip, nakit eşiği, marka) silinir. Tek kapı: kasa ≥ 2 × kira; taşınma kararında bir kez ödenir, aylık kira varış haftası başlar (benim okumam). Plaza "10 kişi" şartı ve C0v Özel doğrulama 6 düşer. |
| 4 | "incident_playbook kalksın" | C1 | Düğüm, katsayısı, metni silinir; eski kayıt için yükleme süzgeci (§2 C1 Kayıt). |
| para notu | "evde 2 uzaktan, kirasız kuralıyla C yeniden ölçer" | C2 ön adımı | C9 cevabıyla "evde sınırsız" ölçülür (§4). |
| 5 | "satın alınan kapasite = kullanılabilen; etkin kapasite farkı kalkar" | C1 | `load_factor`, `effective_capacity`, `scalable_backend`'in `load_divisor` etkisi ve sürüm satırı silinir. C1 küçülür: sürüm kaydına alan yazılmaz. |
| 6 | "3B esas: 12 / 38 / 70; evden uzaktan sınırı kalkar; MRR ya da seed sonrası Frank maili" | C9a, C9a-3B, C9b | Katalog 10/36/64 → 12/38/70 (kurucu dahil); 3B İş hanı 11 → 12 masa noktası; "ilk işe alım taşınmadır" akışı düşer. Frank C9b'de. |
| 7 | "gider $0; runway sonsuz yazmaz; nasıl gösterileceği araştırılır" | C2 | İlk hafta belgesi ve Finans runway sözü; araştırma bitti, seçim Erdem'de (§7 madde 3). |
| 8 | "hatırlatıcı kalır" | bekler: C8 | C8 `inbox.gd:114-126`'ya dokunmaz; `SALES_CHIP_RISK/_EXPANSION`, `SALES_EXPANSION_FICTION` silinmez. |
| 9 | "temsilci şartı kalkar; yoksa müşterinin maili, varsa temsilcinin ağzından" | bekler: C6 | C7'nin "En çok istenen" bölümü de C6'ya kalır. |
| 10 | "kayıp kayıptır; yatırımcı tutma oranını sorar" | bekler: C5 (VC sorgusu) | |
| 11 | "Müşteri İlişkileri'nin en yüksek puanlı temsilcisi gönderir; yoksa rapor yok" | C7 | Gönderen `CustomerRepSystem.ranked_reps()[0]`, Destek işi değil (§7 madde 4). |
| 12 | "Yerel adı kalkar; verilerimiz kurumsal sunucuda şartı ucuzda ve Standart'ta geçerli" | C1 (ad), C4 (imza) | Kademe adı Ekonomik (W1 zaten). Ekonomik'in imza engeli ve ona bağlı satış yolları silinir; 3★ her iki kademede maddeyle imzalar. C0v soru 18 kapanır. |
| 13 | "Standart ×0,5; Kurumsal'a geçiş sözleşmeyle bağlanır, geri dönüş yok" | C1 (seçici), C4 | ×0,5 kodda var (`sprint.json:50` `tier.cloud 0.5`). Kurumsal'dan iniş yok, her pazarda: kural `InfraSystem.set_provider`'dadır (seçici, bot ve debug aynı kapıdan geçer). PRD Karar 4'ün "inilirse süre yeniden başlar" kuralı ve W1 `clause.downgrade_*` düşer (§7 not). |
| 14 | "satışçı raporu: bütün satırlar" | bekler: C5 | |
| 15 | "Atlas şeridi sarı uyarı rengi" | C9a | `D_warn` tonu; şeridin metni §7 madde 1'e bağlı. |
| 16 | "onay bekleyen sabitler PRD değerleriyle; sorunlu çıkan Erdem'e" | hepsi | Kod PRD değeriyle yazılır, commit mesajı "sabitler onay bekliyor" der. |
| C9 cevabı | "evde limit yok; ofisi çeken seed'le Frank'in yönlendirmesi ve buff'lar; uzaktan debuff sonra" | C9a, C9b | C9 ikiye bölünür (§3). Uzaktan debuff `docs/ACIK_ISLER/ISLER.md`'ye açık iş. |
| 10-19 notu | "ofis yalnız paraya; çek şartı kalkar; kredi seçeneği" (→ C9) | C9a; kredi bekler: Erdem | Para kapısı C9a'da. Kredi kararda C9'a bağlı, ama tutarı, faizi, vadesi hiç konuşulmadı: tasarımsız yeni sistem yazılmaz (Genel kural), §7 madde 5. |
| Genel kural | "eski kod silinir ya da düzeltilir; olabildiğince basit" | hepsi | Her adımın "silinecek" listesi §2'de. |
| Pazar K8, K9 | "%60 tabanı kalkar"; "yıldız 5'e çıkar" | C3b; C4 | Zar tabanı yok (C0v soru 27 kapanır). C4'ün "3★ ve üstü" eşiği tek sabittir, 5 yıldızda yeniden okunur. |

## 2. Şimdi yürüyen adımlar

Ortak: kapı sırası C0v §0; yeni smoke vakası yalnız çekirdek mantıkta ve falsification ile (bozulmada düşmeli); PROBE biçimi
`run_probe.gd:27-133` başlık yorumuna yazılır. Hiçbir adım şema numarası değiştirmez (§2 sonu).

### C2 · Giderler (önce koşar, §6)
- **Kapsam:** PLAN_C ile aynı, artı: Karar 7 (ilk hafta belgesi, runway sözü) ve gider 0'ın açtığı iki sapma (VC masasının
  "333 ay"ı, "Gider gelirin altında" cümlesi). Ofis ipucu `fin.office_tip` C9a'ya geçer (kira orada doğar).
- **Dokunulan:** `finance_system.gd` `STARTING_BURN_BREAKDOWN :23-33`, `BURN_IDS :36-38`, `daily_tick :135-137`, `from_dict
  :104-115` (son satır `GameState.set_daily_burn(compute_total_burn())`, C0v Özel doğrulama 2), yorumlar; `infra_system.gd`
  `daily_tick :347-349`; `hr_search_system.gd:252-256` `preview_hire`; `hr_actions.gd:247-248`; `finance_ozet_view.gd:383-400`
  `_refresh_burn`; `first_week_doc.gd:225-229` (gider "$0", runway Erdem'in seçimi); `ui_tokens.gd:403-420` `net_runway_parts`
  (seçim F-A ise "Gider yok" hâli); `vc_pitch_system.gd:1200-1204`, `term_sheet_table_system.gd:957-961` (gider 0 iken ay
  yazmaz); `run_probe.gd` `MONTH_BURN :487-517`, `GATE :520-568`, başlık `:103-106`.
- **Silinecek:** `TOOLS_BASE_MONTHLY`, `TOOLS_PER_EMPLOYEE_MONTHLY`, `monthly_tools_for` (`finance_system.gd:13-14`, `:219-222`);
  `SERVICE_*`, `ONBOARDING_MRR_MULT`, `SERVICE_BURN_CATEGORY`, `monthly_service`, `gross_margin_monthly` (okuyucusuz)
  (`infra_system.gd:82-93`, `:266-281`). `monthly_service` `load_factor`'ü okur: C2 önce koşunca C1'in silmesi temiz kalır.
- **Smoke:** `burn_day1_breakdown` (2791) `burn_lines_visible` adıyla yeniden yazılır (gün 1 gideri 0, beş kalem, toplam =
  `daily_burn`, yüklemeden sonra `daily_burn` taze; falsification: `from_dict`'in son satırı silinince düşer). PRD'nin ayrı
  vakası yazılmaz, bu vaka onun yerini tutar (benim kararım: aynı şeyi iki vaka sınamaz). Sil: `burn_tools_and_service` (2856).
  Sayı için gözden geçir: `burn_refresh_same_tick` 2826, `marketing_push_burns_and_ends` 2958, `runway_net_status` 3036 (`:3043`,
  `:3073-3079` "Default Alive" metnini bekler), `gross_runway_months` 3057, `hr_search_cycle` 7237,
  `hire_preview_counts_inherited_overtime` 7314, `hr_leave_cycle` 7464, `hr_raise_and_leave` 7633, `summary_frequency_ticks`
  1481, `save_v13_day_stamps_migrate` 2169, `loc_b4_derived_keys` 12367.
- **PROBE:** `MONTH_BURN` ve `GATE`'ten `tools=`, `service=` kendiliğinden düşer; evre 1'de `GATE runway=inf`.
- **Bot:** değişmez.
- **W1:** kalan `fin.row_*` (beş mevcut anahtar), `fin.empty`. Taşınan `fin.office_tip` → C9a. Yeni ve değişen:

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `fin.onb_burn` (`ONB_DOC_BURN` değişir) | Monthly costs | Aylık gider | Karar 7 |
| `fin.runway_none` (yeni) | No costs yet | Gider yok | İH-B ve F-A seçilirse; seçim §7 madde 3 |
| `fin.runway_none_note` (yeni) | The clock starts with your first cost. | İlk giderle sayaç başlar. | Araştırma "ilk işe alımla" diyordu; MVP'den sonra ilk gider sunucudur |
| `RUNWAY_PROFITABLE` (EN değişir) | In the black | Artıda (aynı) | F-A seçilirse |
| `RUNWAY_PROFITABLE_NOTE` (değişir) | Revenue covers costs, so cash is not shrinking. The clock starts if net flow turns negative. | Gelir giderleri karşılıyor; kasa erimiyor. Sayaç, net akış eksiye dönerse işler. | F-A seçilirse |

  Sil: `FIN_BURN_TOOLS` (:3008), `FIN_BURN_SERVICE` (:3009), `HR_ROW_TOOLS` (:3019).
- **Sabitler:** yok (silme adımı).
- **Kapılar:** `burn_lines_visible`; `loc_residue`; `run_gate`; görsel: `--finance-shot=gider` ve yeni `gider_empty`, ilk hafta
  belgesi (`--onboard-shot`), üst bar runway hücresi gider 0 iken.
- **Kayıt:** göçsüz. Eski kaydın `tools`/`service` kalemi `from_dict`'te düşer (`finance_system.gd:111-115`), `daily_burn`
  yüklemede tazelenir.

### C1 · Sunucu, Genel Bakış iskeleti, kademe, bot kapasite politikası
- **Kapsam:** PLAN_C C1 eksi sürüm satırı ve sürüm kaydı alanı (Karar 5), eksi kademe fiyatı tartışması (Karar 2); artı
  Karar 4 (Ar-Ge düğümü), Karar 5 (etkin kapasite silinir), Karar 13 (Kurumsal'dan iniş yok), Karar 12 (ad).
- **Dokunulan:**
  - `infra_system.gd`: `CAPACITY_STEP :50` ve `adjust_capacity :245-246` (birimin %10'u, en az 1); `UNIT_PRICE_* :26, :28`;
    `OCCUPANCY_AMBER :60` 0,90; `occupancy :190-194`, `is_over_capacity :203-208`, `units_for_occupancy :198-199` satın
    alınan kapasiteyi okur; otomatik ayar okuması; `report_inflow_multiplier :297-305` aşım dalı silinir; başlık yorumu
    `:4-13` ("rastgele kesinti yok") bugünkü kurala düzelir. Yeni `outage_load_mult()` yazılmaz: yükün katı bugün 1,0 dönen
    `IncidentSystem.load_mult()`'ın (`incident_system.gd:69-71`) gövdesine girer (CLAUDE.md §8, aynı işi yapan ikinci işlev yok).
  - `incident_system.gd`: `load_mult` yük basamağını döndürür ve `hazard :75-78` onu kırpmadan sonra ve yalnız kesinti payına
    uygular; zar anındaki yük `GameState.incident.pending`'e (`:117-120`); yeni seam `olay.outage_load` (TYPE_INT, yük yüzdesi,
    `seams_incident.gd`, `olay.*` ailesinin yanında); `incident_outage_b2b/b2c.json` `by_seam` gövdesi.
  - `negotiation_system.gd:267` `capacity_total` `purchased_capacity()` okur.
  - `sprint_bridges.gd:75` kapasite satırı silinir (`on_release :71-76` istek kısmı kalır; `on_mvp :125` kalır).
  - `product_state.gd:26-27, :274-297` ve `game_state.gd:48` `FLAG_TYPES`: `mvp_infra_auto` (bool), `mvp_infra_auto_last`
    (dict), `mvp_infra_served_weeks` (array) (C0v Özel doğrulama 1).
  - `time_manager.gd:436-442` saatlik tek otomatik ayar çağrısı.
  - `product_tab.gd` `VIEW_KEYS :16`, `_build_ctl :192-207` (v1.0 kilidi ÇEYREK'le aynı kalıp, gerekçe ipucunda: benim kararım,
    C0m'nin açık sorusu); `product_model.gd` `overview`; yeni görünüm dosyası `scripts/tabs/product/` (class_name'siz).
  - `UiFactory.D_load_bar`; yeni token (`D_BAR_TICK`) gerekirse `THEME_STAMP` ve iki tema aynı commit'te (CLAUDE.md §7).
  - Kademe seçici: Kurumsal'dayken alt kademeler kilitli ve gerekçeli (Karar 13). Kural seçicide değil
    `InfraSystem.set_provider` (`infra_system.gd:229-233`) içindedir: geçerli kademe Kurumsal ise başka kademeye `false` döner;
    `:225-227` "her an değiştirilebilir" yorumu düzelir.
  - Ar-Ge: `rnd_tree.json:17` `scalable_backend`'in `effect` alanı silinir (düğüm Dayanıklılık hattını açtığı için kalır),
    `:26` `incident_playbook` satırı silinir; `research_tree.gd:47-53` `COEFFICIENT_EFFECTS` 10'dan 8'e (`load_divisor`,
    `overage_satisfaction` çıkar, `:47` "on katsayısı" yorumu); `research_tree.gd:188-190` biçim denetimi 8 devamdan 7'ye
    (yoksa ağaç açılışta `_fail` ile bağırır); `rnd_tree_view.gd:44` `FAMILY_SIZE := 5` sabiti silinir, `:155` ve `:202`
    sayacı ailenin kendi düğüm sayısını `ResearchSeam.NODES`'tan okur (yoksa Pratik ailesi "4/5"te kalır);
    `research_seam.gd:42` silinir, `:10` "20 düğüm" yorumu; `rnd_system.gd:779-800` `from_dict` bilinmeyen düğümü düşürür,
    `:760` "yirmi düğüm" yorumu; `rnd_tab.gd:24` ve `hr_assignments.gd:117` "yirmi" yorumları. GUNCELLEMELER: Ar-Ge ağacı 19
    düğüm (Karar 4).
  - `run_probe.gd` `PRESETS :154` (`server_lean`, `server_wide`, `server_auto`, anahtar `server`), `_seed_world` spec,
    `_run_the_company :1438` kapasite politikası ve `:1436-1437` yorumu; `main.gd:3013-3014`, `:3742-3743`, `:4030` fikstürleri.
- **Silinecek:** `OVERAGE_* :66-69`, `overage_satisfaction`, `satisfaction_delta_per_day :286-292`, `acquisition_multiplier
  :309-312`; uyarı mandalı ve kartı `:98-115`, `:327-340` (`reset/to_dict/from_dict` dahil); `LOAD_DIVISOR*`, `LOAD_BASE`,
  `load_divisor`, `load_factor`, `effective_capacity` (`:43-47`, `:157-175`); `support_system.gd:248` aşım payı ve `:163-165`
  yorumu; `sales_system.gd:195` edinim çarpanı (Q dosyası); `endgame_smoke.gd:14312` `InfraSystem.reset()`.
- **Smoke:** yeni `capacity_step_immediate`, `load_mult_steps` (0,90 ve 1,00 sınırı, kırpmadan sonra katın tam işlediği),
  `auto_capacity_grows_only`. PRD'nin `no_hidden_overage`'ı ayrı yazılmaz: aşımda Destek akışının ve B2C ediniminin
  değişmediği satırı `infra_capacity_moves_both_ways` taşır (benim kararım). Yeniden yaz: `infra_capacity_moves_both_ways`
  (14505), `infra_local_provider_tradeoff` (14637, aşım satırları), `incident_gap_and_spread` (17174, `_incident_world`
  kapasite alır), `rnd_tree_loads_and_validates` (16065, 19 düğüm, 8 katsayı), `save_v10_product_state` (15942). Sil:
  `infra_overage_applies_and_stops` (14588), `infra_heavy_step_costs_capacity` (14552; konusu Karar 5'le kalktı).
- **PROBE:** haftalık `PROBE SERVER day= units= tier= load= bill= auto=`; `PROBE END`'e `u_unexplained_weeks`'ten sonra
  `server_clicks= auto_grows= outage_eko= outage_std= outage_kur=`.
- **Bot:** varsayılan "elle oynayan": yük %90'ı geçince bir adım; `server_lean` yükü %95'te, `server_wide` %60'ta tutar,
  `server_auto` anahtarı açar. Kademe Standart kalır (`on_mvp`).
- **W1** (38 öğe): kalan 33. Değişen ve yeni:

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `server.warn_high` (değişir) | Load {load}%. Above {edge}%, the chance of an outage is {mult} times higher. | Yük %{load}. %{edge} üstünde kesinti ihtimali {mult} katına çıkar. | C0m: TR "Yük"ü iki kez söylüyordu |
| `server.load_over_seats` (yeni) | Load {load}% · {short} seats over capacity | Yük %{load} · kapasitenin {short} koltuk üstünde | C0m metin eksiği 5 |
| `server.load_over_users` (yeni) | Load {load}% · {short} users over capacity | Yük %{load} · kapasitenin {short} kullanıcı üstünde | |
| `server.tier_tip_final` (yeni) | There is no moving back down from Enterprise. | Kurumsal kademeden geri dönülmez. | Karar 13 |
| `server.tier_locked` (yeni) | You are on Enterprise servers; there is no moving back. | Kurumsal sunucudasın; geri dönüş yok. | alt kademenin kilit gerekçesi |
| `PROD_RND_NODE_SCALABLE_BACKEND_UNLOCK` (değişir) | The last tier of the Durability line · collection in ERP, shared editing in Video Clip. | Dayanıklılık hattının son kademesi · ERP'de tahsilat, Video Klip'te ortak kurgu. | "aynı donanım daha çok kullanıcı taşıyor" artık yalan |
| `PROD_RND_NODE_SCALABLE_BACKEND_DESC` (değişir) | The load is spread across many machines. | Yük birçok makineye dağıtılır. | "Kalabalık gün artık bir kaza değil" etki iddiası; etki kalktı |
| `PROD_RND_NODE_SCALABLE_BACKEND_DISCOVERY` (değişir) | On Tuesday everyone came in at the same hour and the page would not open. On Friday the same crowd arrived and nobody noticed. | Salı günü herkes aynı saatte girdi ve sayfa açılmadı. Cuma günü aynı kalabalık geldi, kimse fark etmedi. | son cümle çıkar |

  Düşen: `server.release_drop_seats/_users` (Karar 5), `server.tier_tip_no_enterprise` (Karar 12). CSV sil:
  `PROD_RND_NODE_INCIDENT_PLAYBOOK` (:572), `_DESC` (:2202), `_UNLOCK` (:2203).
- **Sabitler (PRD değeriyle, onay bekliyor):** adım %10 en az 1 birim; otomatik eşik %80, hedef yük ~%65, küçültmez (C0r
  doğruladı); yük katı ≤0,90 1,0 · ≤1,00 1,5 · üstü ya da kapasitesiz 2,5; büyüme satırı 4 hafta geçmiş, 1 ile 4 hafta ufuk,
  %90; sarı %90, kırmızı %100; bot payları %5 / %40. Fiyatlar onaylı (Karar 2).
- **Kapılar:** §4.4 m.4; hedefli smoke; `--tick-probe=3:accounts=330` (saatlik çağrı Q'nun 148,2 ms kapısının içinde);
  `run_gate`; görsel `--product-shot=live:` `overview_pre`, `server_80`, `server_94`, `server_104`, `server_growth`,
  `server_auto` ve kesinti kartı yük %90 üstünde `--event-shot` (TR, EN, cb, 1,25); Ar-Ge ağacı `--rnd-shot` (Pratik
  sütununda `cicd`'nin altı boş, sayaç "n/4").
- **Kayıt:** göçsüz. Üç bayrak `FLAG_TYPES`'ta varsayılanla (eski kayıt anahtar kapalı okur). Sağlayıcı kimliği `local` kayıtta
  kalır, yalnız görünen ad değişir. `incident_playbook`: kayıttaki `states/progress/paid/note_pending` girdisi yüklemede
  süzülür, `active` o düğümse boşalır (nakit bedeli 0, iade yok); şema değişmez. Ağır kademe yayınlamış eski kayıtta birim
  aynı kalır, yük düşer (oyuncu lehine; nedensiz düşüş değil).

### C4 · Kurumsal madde ve imza engelinin kalkışı
- **Kapsam:** PLAN_C C4 artı Karar 12 (Ekonomik'in imza engeli ve bağlı satış yolları silinir), Karar 13 (iniş yok). Eksi:
  "−10 durum terimi" (defter C3a'da kurulur; terim C3a'ya geçer, `sat.term_clause` onunla) ve iniş kuralı.
- **Dokunulan:** `sales_system.gd:344` `add_b2b_customer` (3★ ve kademe Kurumsal değilse madde yazar); `customer.gd` `:79`
  sonrası `clause_due_day := -1`, `notice_end_day := -1`; `EventBus.month_ended` tikinde kural (C0v soru 17: benim kararım);
  fesih sonunda hesap `_remove_lost` yolundan düşer ve kayıp sayılır (Karar 10); mailler `MessageSystem.post`; Sunucu
  bloğunda "Kurumsal sunucu bekleyen N hesap"; Kurumsal'a geçiş açık maddeleri kapatır ve bildirimleri geri aldırır; bugünkü
  hesap kartında (`sales_tab.gd:530` `_account_card`) tarihli etiket (C8 tabloya taşır). Madde yalnız `provider() ==
  enterprise` ile karşılanır, sertifika karşılamaz (PRD Karar 4).
- **Silinecek (Karar 12):** `infra_system.gd:322-324` `blocks_enterprise_signature`; `sales_faucet_system.gd:271-275` dalı,
  `sales_constants.gd:185, :188` `WHALE_COND_PROVIDER` (sıradan çıkar), `sales_archetypes.gd:58, :76`. CSV
  `SALES_WHALE_PROVIDER_OR_CERT` (:2416).
- **Düzeltilecek:** `blocks_enterprise_signature`'ın kalan dört okuyucusu `InfraSystem.provider() != InfraSystem.PROVIDER_LOCAL`
  okur (sarmalayıcı yazılmaz): görüşmenin kademe sinyali (`sales_meeting_system.gd:157`), altyapı sorusunun kapısı
  (`sales_probes.gd:75, :196-201`; `provider_enterprise_ok` adı `provider_not_economy` olur) ve kayıp nedeninin kapı okuması
  (`sales_ledger.gd:359-360`). Altyapı sorusu kaldığı için onun kayıp nedeni de kalır: `LOSS_PROVIDER_TRUST`,
  `sales_meeting_system.gd:346-347, :362`, `main.gd:3888` görüşme karesi ve CSV `SALES_LOSS_PROVIDER_TRUST`,
  `SALES_MEMORY_PROVIDER_TRUST` (metinleri "altyapı" der, "yerel" demez). Soru kalıp nedeni silinirse Ekonomik'te soruyu
  soran müşteri fiyat yüzünden gitti der: yanlış neden. Sayılar bugünküyle aynı, Q'nun görüşme kalibrasyonu değişmez.
  `seams_product.gd:121` `urun.enterprise_trust` açıklaması ("before it signs") ve `research_tree.gd:47-48` "balina imza
  koşulu" yorumu bugünkü anlama düzelir; seam beş kartta okunduğu için kalır (C0v C4).
- **Smoke:** yeni `enterprise_clause_timeline` (madde, ay başı kuralı, +20 eşiği, 4 haftalık fesih, geçişle geri alma,
  Kurumsal'dan `set_provider("cloud")` `false`; falsification: geçişte bildirim kalkmazsa ya da iniş kabul edilirse düşer).
  Yeniden yaz: `infra_local_provider_tradeoff` (14646, 14662 imza satırları); `sales_loss_reason_from_asked` (3733-3740)
  yalnız olgu adını değiştirir.
- **PROBE:** `PROBE END`'e `clause_ended=`. **Bot:** madde bekleyen hesapların MRR'ı Kurumsal'ın ek faturasını geçince geçer.
- **W1:** kalan `clause.*` 16 öğe. Düşen `clause.downgrade_fact`, `clause.downgrade_fact_one` (Karar 13). C3a'ya giden `sat.term_clause`. Değişen:

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `SALES_LOCK_PROVIDER` (değişir) | Your servers are on the Economy tier. | Sunucuların Ekonomik kademede. | Karar 12: "yerel" sözcüğü kalkar |

- **Sabitler:** süre 8 hafta, fesih 4 hafta, eşik + 20 (PRD Karar 4, onay bekliyor); madde yıldızı 3★ tek sabitte.
- **Kapılar:** §4.4 m.6 (madde kısmı); `run_gate`; görsel `--inbox-shot=<madde>`, Sunucu bloğu satırı.
- **Kayıt:** göçsüz; eski kayıtta açık madde yok (PLAN_C "Kayıt").
- **Risk:** kural memnuniyet ile eşiği okur; beklenti tasarımı bunları değiştirirse tek işlev değişir.

### C7 · Haftalık destek raporu
- **Kapsam:** PLAN_C C7 eksi "En çok istenen" bölümü ve yeni istek satırı (istek tasarımı bekliyor, C6'ya); düğme bugünkü
  `open_area` kalıbıyla en kötü hattın alanını SPRINT'te açar, kart vurgusu C6 ile gelir (benim kararım).
- **Dokunulan:** `SupportSystem`'e haftalık rapor işlevi, kalıp `sales_rep_system.gd:301` `_tick_weekly_summary`; mesaj türü
  `mail_pane.gd:137, :148`, `inbox.gd:18-19, :311-316`; gönderen `CustomerRepSystem.ranked_reps()` (`customer_rep_system.gd:41-58`),
  boşsa rapor yok; haftalık gelen sayacı `support_system.gd:113-117`; önceki raporun durumu bayrakta (`FLAG_TYPES`, kalıp
  `game_state.gd:95-96`); düğme `build_bar.gd:170` kalıbı. "Okunmamış eski rapor düşer": `MessageSystem`'de yalnız `post`
  var (`message_system.gd:19`), tek silme işlevi eklenir.
- **Silinecek:** yok.
- **Smoke:** yeni `support_report_quiet_week` (yeni yoksa gelmez, temsilci yoksa gelmez; falsification: "yeni mi" hep doğru
  dönünce düşer).
- **PROBE ve bot:** yok.
- **W1:** kalan 10 öğe (`support.subject`, `sender`, `sec_trouble`, `sec_week`, `new_priority`, `new_cleared`, `new_worst`,
  `shipped`, `behind`, `btn_fix`). C6'ya ertelenen `support.sec_asked`, `support.new_request`. Yeni ve değişen yok.
- **Sabit:** "Yetişemedim" eşiği haftanın gelenlerinin beşte biri (PRD, onay bekliyor).
- **Kapılar:** §4.4 m.7 (rapor kısmı); `run_gate`; görsel `--inbox-shot=<destek raporu>`.
- **Kayıt:** göçsüz; iki bayrak varsayılanla, yüklemeden sonraki ilk rapor boş öncekiyle kıyaslanır (bir kez fazladan rapor).

### C9a · Maaş, masa, para kapısı, kira, bot (C9'un şimdi yürüyen yarısı)
- **Dokunulan:**
  - `hr_constants.gd:591-598` bantlar ×1,5 (komisyon `:717`, `:837-838` kendiliğinden büyür).
  - `office_constants.gd`: `desks` `:19, :28, :40, :54` → 1 / 12 / 38 / 70; yeni `rent` 0 / 4.000 / 8.000 / 18.000 ve
    `UPFRONT_MONTHS 2`; `reqs` alanı silinir; başlık yorumu `:4-6` ("a move costs nothing") düzelir.
  - `office_system.gd`: `requirement_state :21-35` silinir; `can_move_to :40-43` kasa ≥ peşin; `move_to :48-54` peşini
    `FinanceSystem.apply_one_time_cost` ile keser (yeni kimlik `office_upfront` `finance_system.gd:42` `ONE_TIME_LABELS`'a,
    etiketi `FIN_ONETIME_OFFICE`); `daily_tick :58-64` her tik geçerli ofisin kirasını `office` kalemine yazar (maaş gibi
    çekilir; yalnız varışta yazılsaydı C9a'dan önce taşınmış kayıt hiç kira ödemezdi);
    `time_manager.gd:407-409` sırası: `OfficeSystem.daily_tick` Finance'ten önce (kira varış haftasına girer, C0v A10).
  - `office_map_card.gd`: `:55-57` durum rozeti, `:63` masa hücresi → `office.card_line*`, `:74-77` ve `:121-144` şart satırları
    → tek peşin satırı, `:103` "şart karşılanmadı" metni; `office_city.gd:169-170` hover aynı.
  - `office_hud.gd:92-98` nefes: Frank'in çeki yerine seed alınmış ve evdeyken (Erdem'in C9 sözü; Frank'in kartı değil).
  - Atlas (`scripts/tabs/hr/hr_atlas_modal.gd:52-123`): ofisteyken "Masa N · boş M" ve dolunca sarı şerit (`D_WARN`,
    `ui_tokens.gd:500`; renk körü ikizi `D_WARN_CB` soluk sarı) ve "Ofisleri gör"; evde şerit yok. İşe alımı engellemez (§7
    madde 1'in önerisi). Tavan olmadığı için kadro masayı aşabilir: `atlas.desks`'in `free`'si ve `office.card_line_current`'ın
    `taken`'ı masaya oturanı yazar (en çok masa sayısı), "12 masa · 15 dolu" çizilmez.
  - `run_probe.gd` `_hire_after_the_seed :1410-1433` (`+6000` tahmini gerçek bant ×1,5 ve kirayla), taşınma politikası,
    `cash_spend`/`cash_hoard` kolları (anahtar `cash`), `PROBE DECISION`; `main.gd:3165` komisyon fikstürü.
- **Silinecek:** `OfficeConstants.CATALOG.*.reqs`, `requirement_state`, `_requirement_row`'un çek dalı (`ChequeRead`),
  `office_system.gd:46-47` "No money moves" yorumu, `finance_system.gd:28` TODO yorumu. CSV `OFFICE_REQ_ANGEL` (:2701),
  `OFFICE_REQ_TEAM` (:2702), `OFFICE_REQ_BRAND` (:2704), `OFFICE_REQ_NOW_CLOSED/_OPEN` (:2706-2707), `OFFICE_CARD_UNMET` (:2721;
  tek şartla yalnız `_ONE` kalır).
- **Smoke:** yeni yok. `desk_cap_blocks_hire` yazılmaz (tavan yok, §7 madde 1 aksini derse C9b'de gelir). Yeniden yaz:
  `office_move_gates_and_save` (19820: para kapısı, peşinin bir kez kesilmesi, kiranın varış haftası başlaması, kayıt;
  falsification: peşin kesilmezse düşer). Bant: `hr_candidate_invariants` (6942), `hr_constants_contract` (7873),
  `promotion_and_raise_gate` (11589). Gözden geçir: `hr_leave_cycle` 7464, `hr_raise_and_leave` 7633. Evde işe alan vakalar
  (`hr_search_cycle` vb.) değişmez.
- **PROBE:** `PROBE DECISION week= surface= target=` (kademe, kapasite, taşınma, işe alım; C1 ve C4'ün bot kararları da basar);
  `PROBE END`'e `first_hire_week= first_hire_runway= move_weeks=`.
- **Bot:** seed alınınca kasa ≥ peşin + 6 aylık gider ise İş hanı'na taşınır; kadro masaları aşınca bir üst ofise aynı kuralla.
  `cash_spend` ilk işe alımı kasa ≥ 2 aylık gider olunca yapar ve seed'de taşınır; `cash_hoard` 6,7 ay bekler, taşınmaz.
- **W1:** kalan `atlas.desks`, `atlas.btn_offices`, `office.card_line`, `card_line_current`, `card_line_home`, `fin.office_tip`.
  Düşen `atlas.home`, `atlas.moving` (evde tavan yok), `office.req_team` (ekip şartı yok). Değişen ve yeni:

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `atlas.full` (değişir) | Every desk in the office is taken. New hires work remotely. | Ofisteki bütün masalar dolu. Yeni gelenler uzaktan çalışır. | §7 madde 1 önerisiyle; sarı |
| `office.move_tip` (değişir) | Rent is {rent} a month, {upfront} paid up front. Monthly costs {old} → {new}. The move takes a week; rent starts the week you arrive. | Kira ayda {rent}, peşin {upfront}. Aylık gider {old} → {new}. Taşınma bir hafta sürer; kira taşındığın hafta başlar. | Karar 3 |
| `office.req_upfront` (`OFFICE_REQ_CASH` değişir) | Up front: {money}, two months' rent | Peşin: {money}, iki aylık kira | sağda `OFFICE_REQ_NOW` kasayı yazar |
| `FIN_ONETIME_OFFICE` (yeni) | Office move, two months' rent up front | Ofis taşınması, iki aylık peşin kira | Finans işlem listesindeki tek seferlik satır |

- **Sabitler:** kira 4.000 / 8.000 / 18.000 (Erdem, 10-18), peşin 2 ay (Karar 3), masa 12 / 38 / 70 (Karar 6), bant ×1,5
  (Erdem); bot eşikleri (6 ay, k = 2, 6,7) onay bekliyor.
- **Kapılar:** `office_move_gates_and_save`; `run_gate`; görsel `--office-shot=city:<saat>:card_ishani`, `card_home`, Atlas ofis
  dolu (`--hr-shot=<yeni tür>`), Finans ofis ipucu.
- **Kayıt:** göçsüz. Kayıttaki maaşlar değişmez; taşınma ortasındaki eski kayıt eski kuralla bedelsiz iner (peşin geriye
  yazılmaz). Ofiste duran eski kayıt yüklemeden sonraki ilk tikte kirasını öder ve Finans'ta Ofis kalemi görünür (görünen
  gider, nedensiz düşüş değil).
- **Belge:** C9a commit'i `docs/ACIK_ISLER/ISLER.md`'ye açık işi yazar: "Uzaktan çalışmanın ekip büyüdükçe bedeli (Erdem,
  2026-10-20: şimdilik yok)"; HARITA `:126` (Ofis "kasa hareketi yok") düzelir.

### C9a-3B · İş hanı 12 masa (ayrı commit)
- `tools/office3d` zinciri (`README.md`): kaynakta İş hanı'na bir masa, yarım görünen masa düzelir; tam dışa aktarma,
  `check_export.py`, `--import`, `bake_nav.gd ishani`. Sonuç `art/office3d/ishani.json` `maxN` 10 → 11, `desk` 11 → 12
  (bugün HEAD'de 10 ve 11). Görsel: `--office-shot=ishani:<saat>:full` ve `--office-crowd-probe=ishani:11:1`.

## 3. C9'u bölmek

| | C9a (şimdi) | C9b (bekler) |
|---|---|---|
| İçerik | §2 C9a ve C9a-3B | Ofis buff'ları (itibar, verim, ekip büyüdükçe koordinasyon kaybının azalması), ofisten ofise artış; seed'de Frank'in "ofis tutalım" yönlendirmesi |
| Girdi | Kararlar 3, 6, 15 ve C9 cevabı | `c_taslak/arastirma/OFIS_BUFF.md` (yazıldı, 2026-10-20) ve Erdem'in seçimi (§7 madde 6); verim buff'ı D'nin atama ve verim araştırmasına dokunur; koordinasyon kaybı kodda yok, önce D kurar |
| Frank | dokunulmaz | `funding/frank_office_move.json`: koşul `investor.angel_taken` → `funding.seed_taken` (`seams_ported.gd:143`), `version_scope` `ea` → demo (seed demoda); metin (`FRANK_OFFICE_MOVE_BODY` :2751) Erdem'in külliyatıdır, değişirse yalnız taslak (Karar 30: var olan kart küçük değişiklikle kullanılır) |
| Uzaktan debuff | yok | yok; `ISLER.md`'ye açık iş |

**Masa tavanı:** evde yok (Karar 6, C9 cevabı). Ofiste kalıp kalmadığını kararlar söylemiyor: Karar 15 (sarı şerit) tavanlı metin
için verilmişti, C9 cevabı "sınırsız kalsın" diyor. C9a tavansız yazılır; Erdem tavan derse C9b'de `desk_cap_blocks_hire` ile
gelir (§7 madde 1).

## 4. C2'nin ön adımı: para ölçümü (koşan ajan; ben koşmadım)
Betik `c_taslak/msim/c0s_econ.py`, `python -I`, yeni dosya `c0s_econ_e1.py` (eskisi kanıt olarak kalır). Değişen girdiler:
- Ev kirasız ve sınırsız: K9 botunun işe alımları aynen, maaş ×1,5, evde kira 0 (`econ()`'un `rent_policy`'sine `home`).
- Taşınma iki kolla: `home` (hiç taşınmaz) ve `seed` (seed haftası kasa ≥ peşin + 6 ay gider ise İş hanı; peşin = 2 × kira tek
  sefer; kira varış haftası). Plaza ve Loft yalnız para kuralıyla, kadro masayı aşınca.
- İlk işe alım kuralı (`variants()`): Frank şartı yok (V1/V2 ayrımı kalkar); gider = maaş ×1,5 + sunucu (kira yok); k = 1, 2,
  6, 6,7.
- Sunucu fiyatı Karar 2 (`NEW_UNIT` 120/250, zaten), `auto` politikası.

| Ölçülen | Hedef (PRD §4.3) | Sonuç böyleyse |
|---|---|---|
| İlk işe alım haftasında runway | ≥ 6,7 ay | geçer: değişiklik yok. Kalırsa: Erdem'e sayı ve iki yol (kapının tanımı ya da başlangıç kasası, ANA_RESIM §3.6) |
| İlk 40 haftada en derin açık (hf > 30) | 25 ile 45 bin | 25 binin altı "ilk yıl fazla kolay" (Risk 2) bulgusudur: Erdem'e, C9b buff'ları taşınmayı çekince `seed` kolunun açığıyla birlikte. 45 binin üstü: Erdem'e |
| 52. hafta kümülatif net; evre 3 aylık net; evre 2'de runway < 4 ay | ≤ 80 bin; ≤ 2 × bugün; en az bir kez | tutmazsa Erdem'e; sabit değişmez |
| `cash_spend` ile `cash_hoard` farkı | ≥ 6 hafta | fark yoksa kasa karar doğurmuyor: raporun Risk 2 bulgusu |
| `seed` kolunda taşınma haftası ve o haftanın runway'i; Plaza'ya varış haftası | rapor | C9a botunun eşiği (6 ay) için girdi |
| B2C açık ve 101. hafta net | ≤ ×1,5; ≥ %80 | C0s §3.4: göreli hedef kırılgan; mutlak sayı da yazılır |
| M12 sunucu payı (fiyat sabit) | rapor | Karar 2: kapı değil |

Ölçüm C2'yi durdurmaz (PRD §4: ajan durmaz, sonuç Erdem'e). Runway gösterimi: `arastirma/RUNWAY_GOSTERIM.md`'nin
seçenekleri C2'nin ilk hafta belgesine ve Finans metnine girer; Erdem seçmeden önerilen (İH-B, F-A) metinler "TR/EN onay
bekliyor" ile yazılır.

## 5. Eski E1 soruları (C0v 1 ile 31)

| # | Konu | Durum |
|---|---|---|
| 1, 2 | yük katı yalnız kesintiye; tavan yutmaz | Karar 1 |
| 3 | satın alınan mı etkin mi | Karar 5 (konusuz kaldı) |
| 4 | `incident_playbook` | Karar 4 |
| 5 | masa katalog/3B | Karar 6 |
| 6 | aday taşınma bitmeden başlamaz | benim kararım: konusuz; evde tavan yok, evde alınan uzaktan başlar, `hire()`'a kod yok |
| 7 | Plaza/Loft sayımı | Karar 3 (ekip şartı yok) |
| 8 | ilk hafta belgesi | Karar 7; gösterim seçimi Erdem'de (§7 madde 3) |
| 9 | gelen kutusu hatırlatıcısı | Karar 8 |
| 10 | iki pencere, iki koltuk yolu | bekler: C5 (yenileme tasarımı) |
| 11 | istek kartının yolu | Karar 9; uygulama bekler: C6 |
| 12 | ürün dışı kayıp VC'de | Karar 10; uygulama bekler: C5 |
| 13 | B2C destek zararı | bekler: C3a |
| 14 | destek raporunu kim gönderir | Karar 11 (§7 madde 4) |
| 15 | `per_sprint` −3 süresi | bekler: C3a |
| 16 | satış hatayı okur | benim kararım: vaka VC yarısıyla kalır, satış yarısı `sign_gate_reason`'a geçer, GUNCELLEMELER ikinci sapmayı yazar; uygulama C3b |
| 17 | maddenin tiki | benim kararım: `month_ended` tiki, etiket takvim tarihi (C4) |
| 18 | balina sağlayıcı koşulu | Karar 12 (koşul kalkar) |
| 19 | "Müşteriler · N talep" şeridi | benim kararım: C6 dokunmaz, D plan ekranında değiştirir |
| 20 | atanmamış PROBE alanları | benim kararım: satışçı payı `PROBE SIGN by=` ile ölçülür, yeni alan yok; saat durması C5'te |
| 21, 22 | "Hayır diyemez"; "Söz ver" +8 | bekler: C3a |
| 23 | kapı hangi U'yu okur | bekler: C3b (beklenti tasarımı) |
| 24, 25 | gizli hat U düşüşü; C3a ile C3b arası | bekler: C3a, C3b |
| 26 | B2C kalibrasyonu | bekler: C3a |
| 27 | zar tabanı %60 | Pazar K8: taban kalkar; satışçı yıldızı araştırması C3b |
| 28 | `risk_reason` alanı | bekler: C3a, C8 |
| 29 | `area_row` 0 beklenti | benim kararım: gri boş işaret, kare yok; C6'da, tasarım değişmezse |
| 30 | görsel kabul aracı | benim kararım: `--product-shot=live:<tür>`; `--tab-shot=product` kırığı C'de onarılmaz, `ISLER.md`'ye |
| 31 | aday kartı sözcüğü | bekler: C3b |

## 6. Sıra ve modeller

Sıra **C2 → C1 → C4 → C7 → C9a → C9a-3B** (PLAN_C'de C1 önceydi). Gerekçe: C2, `load_factor` okuyan `monthly_service`'i siler,
C1'in silmesi temiz kalır; C2 küçük ve C9a'nın kira kalemi ona dayanır. C1 sürüm ve bot kapasite politikasını kurar, C4 onun
Sunucu bloğuna ve kademe seçicisine yazar. C7 bağımsız. C9a sonda: `PROBE DECISION` önceki adımların bot kararlarını da basar.
3B ayrı commit (sanat hattı, oyun mantığından ayrı inceleme). Ön koşul: Q "bitti" ve `git log`'da son commit'i.

| Adım | Kod | Kapı ve kare | İnceleme | Süre |
|---|---|---|---|---|
| C2 ölçüm | Sonnet · yüksek (betik) | yok | Opus okur, Erdem'e özet | 45 dk |
| C2 | Sonnet · xhigh | Haiku · düşük | Opus · yüksek | 2 sa 30 dk |
| C1 | Sonnet · xhigh | Haiku · düşük | Opus · yüksek | 5 sa 30 dk |
| C4 | Sonnet · xhigh | Haiku · düşük | Opus · yüksek | 3 sa 30 dk |
| C7 | Sonnet · xhigh | Haiku · düşük | Opus · yüksek | 2 sa |
| C9a | Sonnet · xhigh | Haiku · düşük | Opus · yüksek | 3 sa |
| C9a-3B | Sonnet · yüksek | Haiku · düşük (kare) | Opus · yüksek | 1 sa 30 dk |

Commit başına bir Opus incelemesi ve en çok bir düzeltme turu; kapı yeşile dönmezse commit yok. C3a, C3b, C5, C6, C8 ve C9b
beklenti tasarımını (ve C9b ofis araştırmasını) bekler; E2 bunlardan sonra.

**Kayıt ve şema:** C2, C1, C4, C7, C9a ve 3B göç istemez (her adımın Kayıt satırı); şema 18 kalır. 19 ve tek göç C3a'nındır.
D 20'yi C3a'dan önce isterse sıra yardımcı yönetmenin kararıdır; C bu adımlarda numara almaz.

## 7. Erdem'e

1. **Ofiste masa tavanı kalsın mı?** Evde sınır yok dedin. Ofiste tavan kalırsa: 14 kişilik ekiple İş hanı'na (12 masa) taşınan
   oyuncu orada kimseyi alamaz, evde kalsaydı alabilirdi; taşınmak cezalandırır. Öneri: tavan hiçbir yerde yok; masa ofisin
   sığdırdığı kişidir, masası olmayan uzaktan çalışır (3B bugün de fazlasını çizmez, `office_people.gd:594-633`). Atlas'taki
   sarı şerit engel değil bilgi olur: "Ofisteki bütün masalar dolu. Yeni gelenler uzaktan çalışır." C9a böyle yazılır;
   "kalsın" dersen tavan C9b'ye girer.
2. **Not, soru değil (Karar 13 açık):** "geri dönüş yok" her pazarda uygulanır; seçici geçişten önce "Kurumsal kademeden
   geri dönülmez." yazar. Oynanışta izlenecek: maddeli müşterisi olmayan B2C oyuncusu kesintiden korkup Kurumsal'a geçerse
   faturası kalıcı 2 katına çıkar. Playtest'te sorun çıkarsa Erdem'e gelir.
3. **Runway gösterimi** (araştırma `arastirma/RUNWAY_GOSTERIM.md`). Örnek: oyuncu ilk haftada kasada $10.000, gider $0 görür;
   runway satırına ne yazsın? Öneri İH-B: "Gider yok", altında "İlk giderle sayaç başlar." Kârdaki şirkette üst bar "Artıda"
   kalır, EN "Default Alive" yerine "In the black" (F-A). Seçmezsen C2 bunları "onay bekliyor" ile yazar.
4. **Destek raporunu kim yazar** (zaten soruldu). Kodda Destek işine atanan ile Müşteri İlişkileri alanına atanan ayrı
   listelerdir (`hr_system.gd:279-288`). Örnek: Destek işinde iki kişin var ama Müşteri İlişkileri'nde kimse yok; 11. kararla
   rapor gelmez. C7 kararı aynen uygular; "Destek işi" dersen tek satır değişir.
5. **Kredi seçeneği nerede?** 10-19 kararı "oyuncuya kredi seçeneği sunulur" diyor ve C9'a bağlı
   (`ERDEM_KARARLAR_2026-10-20.md:12`), ama tutarı, faizi, vadesi ve kimin verdiği hiç konuşulmadı. Örnek: kasası $3.000'a inen
   oyuncu bankadan $20.000 çeker; ayda kaç ödeyecek, ödeyemezse ne olur? Öneri: C9a kredisiz yürür; kredi ayrı tasarım
   turuyla (C9b ya da yol haritası) gelir. Bu cevap C9a'yı durdurmaz.
6. **C9b için, şimdi değil: ofis buff'ı.** Araştırma hazır (`arastirma/OFIS_BUFF.md`). Önemli bulgu: "ekip büyüdükçe
   koordinasyon kaybı" kodda bugün yok (`hr_constants.gd:1030` "Bugün okuyucusu yok: sprint motoru koordinasyon çarpanı
   uygulamaz"; `OFIS_BUFF.md` §0 madde 7); ofis onu azaltamaz, önce kayıp kurulmalı (Faz D'nin işi). Araştırmanın önerisi
   ofis kademesi başına tek sayı (gün içi verim düşüşü ve moral aşınmasını ölçekler, §0 madde 8). Seçim C9b'nin girdisidir.

## 8. Erdem'in ek cevapları (2026-10-20, §7'nin 1, 3, 5, 6. maddeleri) · bu bölüm yukarıdakini ezer

| Soru | Erdem'in seçimi | Ne değişir |
|---|---|---|
| §7-1 Ofiste masa tavanı | **Ofiste tavan var** ("evde sınırsız, ofiste masa kadar; evden büyük ekiple taşınan oyuncu cezalanır") | C9a |
| §7-3 Runway gösterimi | **Yalnız eksideyken** ("gider yokken ve kârdayken satır hiç çıkmaz") | C2 |
| §7-5 Kredi | **Sonra, ayrı tasarım** | C9a kredisiz; kredi `docs/ACIK_ISLER/ISLER.md`'ye açık iş |
| §7-6 Ofis buff'ı (C9b) | **Yalnız itibar sıçraması** (marka bir kez yükselir; örnek İş hanı +3, Plaza +6, Loft +10) | C9b; "Mesai az yorar" ve "kalabalık kaybı" seçilmedi |

**C2 (runway yalnız eksideyken):**
- Bir tek kural: net akış ≥ 0 (gider 0 dahil) iken runway okuması BOŞ döner ve satır, hücre, ipucu çizilmez. Okuyanlar:
  `ui_tokens.gd:403-420` `net_runway_parts` / `D_runway_reading` (üst bar runway hücresi, Finans, ay özeti), `first_week_doc.gd:225-229`
  (gider satırı "$0" kalır, runway satırı çizilmez), VC masası ve term sheet (gider 0 iken ay yazmaz). İşe alım önizlemesi
  (`hr_search_system.gd:252-256`, `hr_actions.gd:247-248`) runway'i yalnız işe alımdan sonra net eksiye dönüyorsa yazar.
- Genel kural: `RUNWAY_PROFITABLE`, `RUNWAY_PROFITABLE_NOTE` ve "Gider gelirin altında" cümlesi (okuyucusu kalmazsa) silinir;
  §2 C2'nin W1 tablosundaki `fin.runway_none`, `fin.runway_none_note` ve `RUNWAY_PROFITABLE*` değişiklikleri DÜŞER, yalnız
  `fin.onb_burn` kalır. `runway_net_status` vakası "net ≥ 0 → okuma boş, net < 0 → ay" diye yeniden yazılır (falsification:
  boş dönüş kaldırılınca düşer). Kare: üst bar ve Finans kârdayken ve eksideyken, ilk hafta belgesi.
- Oyuncu ne görür: ilk haftada ve kârdayken runway yok; para kaybetmeye başladığı hafta runway belirir (kırmızı/sarı tonuyla).

**C9a (ofiste masa tavanı):**
- Evde tavan yok. Ofiste kadro (kurucu dahil) masa sayısına ulaşınca işe alım kapanır: `hr_search_system`/Atlas'ın işe alım
  kapısı `OfficeSystem` masasını okur (evde okumaz). Taşınma yalnız para kapısıyla serbesttir; kadrosu masadan büyük ekip de
  taşınabilir, herkes gelir, masa boşalana ya da daha büyük ofise geçene dek işe alım kapalı kalır (Erdem: "cezalanır").
- Görünürlük (ekonomi merceği): ofis kartı, kadro masadan büyükse taşınmadan önce söyler: yeni W1 `office.move_over_cap`
  (aşağıda). Atlas'ta `atlas.full` W1'deki tavanlı metne döner, sarı (`D_WARN`); evde şerit yok.
- Smoke: `desk_cap_blocks_hire` yazılır (evde 15. kişi alınır; ofiste masa dolunca alınamaz; daha büyük ofiste açılır;
  falsification: kapı kaldırılınca düşer). §2 C9a'daki "tavan yok" satırları ve `free`/`taken` kesme notu bu kuralla
  okunur (dolu sayısı kadroyu yazar, "12 masa · 14 dolu" taşınma sonrası doğru bilgidir, çizimi kesilmez).
- Bot: evde sınırsız işe alır; seed alınınca kasa ≥ peşin + 6 aylık gider ise İş hanı'na taşınır; ofiste masalar dolunca ve
  para yetince bir üst ofise, yetmezse işe alım bekler. `PROBE DECISION` taşınma ve "masa dolu, işe alım bekledi" kararını basar.

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `atlas.full` (W1'deki gibi kalır) | W1 metni | W1 metni | §2 C9a'daki değişiklik DÜŞER |
| `office.move_over_cap` (yeni) | Your team is {team}, this office has {desks} desks. After the move you cannot hire until a desk frees up or you move to a bigger office. | Ekibin {team} kişi, bu ofiste {desks} masa var. Taşındıktan sonra bir masa boşalana ya da daha büyük bir ofise geçene kadar işe alamazsın. | taşınma ipucunun altında, yalnız kadro > masa iken |

**C9b (yalnız itibar sıçraması; şimdi yürür, C9a'dan sonra):**
- Taşınma tamamlanınca o ofis kademesine koşuda İLK kez varıldıysa `GameState.set_brand(brand + n)`; n İş hanı 3, Plaza 6, Loft 10
  (Erdem'in seçtiği seçeneğin örnek değerleri; tek ayar sabiti, "sabitler onay bekliyor"). Benim kararım: her kademe koşuda bir
  kez verir (ileri geri taşınıp marka toplanmaz), aşağı taşınınca marka geri alınmaz. "İtibar" = marka (`GameState.brand`;
  seçeneğin metni "marka bir kez yükselir" diyordu). Varılan kademeler `GameState` bayrağında (`FLAG_TYPES` varsayılanı boş;
  göçsüz).
- Ofis kartı tek satır söyler (yeni W1 `office.card_brand`); taşınma bitince gelen var olan bildirim satırına "Marka +n" eklenir
  (yeni bildirim yok).
- Frank: `funding/frank_office_move.json` koşulu `investor.angel_taken` → `funding.seed_taken`, `version_scope` `ea` → demo. Metin
  Erdem'in külliyatı (ACIK_KARARLAR 43): kaldırılan şartları (çek, ekip, marka) anıyorsa yalnız taslak yazılır ve "TR/EN onay
  bekliyor" denir; anmıyorsa dokunulmaz.
- Silinmez ve kurulmaz: verim/moral çarpanı, kalabalık kaybı (seçilmedi), uzaktan çalışma bedeli (açık iş), kredi (açık iş).
- Smoke: `office_brand_once` (ilk varışta +n, ikinci varışta 0, aşağı taşınmada marka aynı; falsification: bayrak yazılmazsa düşer).

| id (anahtar) | EN | TR | Not |
|---|---|---|---|
| `office.card_brand` (yeni) | Moving here raises your brand by {n}, once. | Buraya taşınmak markanı bir kez {n} puan yükseltir. | yalnız henüz varılmamış kademede |

**Oynanış uyarısı (Erdem'e bilgi, soru değil):** bu seçimlerle evde kalmak baskın stratejidir: ev kirasız ve tavansız, ofis
kira, peşin ve masa tavanı getirir, karşılığında bir kez marka verir. Oyuncuyu ofise çekecek asıl şey uzaktan çalışmanın bedeli
(açık iş) olacak. O gelene kadar bot ve oyuncu ofise yalnız Frank'in yönlendirmesi ve marka için geçer; C2 ölçümünün `home` ve
`seed` kolları farkı sayıyla gösterir, E2 raporu yazar.

**Sıra:** C2 → C1 → C4 → C7 → C9a → C9b → C9a-3B.

## 9. E2 ölçüm listesi (adımlardan biriken; E2 her satırı gerçek koşuyla ölçer ve Erdem'e yazar)
1. Evre 2 ve 3 ekonomisi: araç ve servis gideri silinince kasa daralıyor mu (C2 ölçümü: evre 2'de runway hiç < 4 ay değil, evre 3
   neti bugünün 2-5 katı; bot işe alımları sabitti). Kollar: kira, maaş bandı, sunucu fiyatı.
2. `full_run_vc_cautious`'un sonu C1'de `series_a_close`'dan `running_on_fumes`'a döndü (Series A kapısı 102. hafta): neden fiyat
   ×2-3 mü, botun sunucu politikası mı, gece kesintileri mi.
3. Sunucu faturasının gelire payı (Karar 2: kapı değil, rapor): `server_lean`, `server_wide`, `server_auto` kolları.
4. Evde kalmanın baskınlığı: `seed` kolunda İş hanı'nda masa tavanı işe alımı ne kadar kapatıyor (C2 ölçümü ~30 hafta), `home`
   koluyla Series A Avı'na varış farkı.
5. Gider 0'da `founder.savings_note` ve `side_contract` gelmiyor (runway_weeks 9999): ilk haftalarda boşluk kartı açığı.
6. Geç B2C'de memnuniyet dibe oturuyor mu (eski ACIK 99'un belirtisi; yeni modelde ölçülmedi; yardımcı yönetmen kararıyla ACIK 99
   silindi, belirtisi buraya taşındı).

## İnceleme (Opus)

2026-10-20, tek tur. Kod `git show HEAD` (`e4e7e9b`) ile okundu; Godot koşmadı, oyun dosyasına ve git'e yazılmadı.

**Sorulara cevap**
1. Kararlar adıma düşüyor mu: evet, 16 karar ve C9 cevabı §1'de bir adıma ya da "bekler"e düşüyor. Söz korunmuş: fiyat
   $120 / $250 ve 1 : 2 : 4 oranı (PRD Karar 2 satır 113: oran Erdem'in), Standart ×0,5 (`sprint.json:50` `cloud 0.5`), Kurumsal'dan
   dönüş yok, rapor Müşteri İlişkileri'nin en yüksek puanlısı (`customer_rep_system.gd:40-58` `ranked_reps` puana göre sıralar),
   evde limit yok (bugün de tavan yok: `hr_search_system` masa okumaz, `desks` yalnız `office_map_card.gd:63` ve
   `office_city.gd:170`'te). Yanlış okunan: 10-19'un "kredi seçeneği → C9" sözü kaynaksız "C dışı" yazılmıştı (düzeltildi).
2. Erdem'e dönmeden yürür mü: evet. C2 runway metnini "onay bekliyor" ile yazar, C9a tavansız yazar, C7 Karar 11'i uygular;
   §7'nin hiçbir maddesi bu beş adımı durdurmaz. Karar vermeyen satır yok; "yeni `olay.*` seam'i" adsızdı (adı verildi).
3. Kapsam: kararların istemediği yeni sistem yok. PLAN_C'nin yeni `outage_load_mult()`'ı bugün 1,0 dönen
   `IncidentSystem.load_mult()`'ın (`incident_system.gd:69-71`) kopyası olurdu: tek işlevde kaldı. Genel kural adım adım
   yazılı; eksik iki silme okuyucusu eklendi (aşağıda 2 ve 3).
4. Kayıt: göç gerekmez, doğru. Yeni bayraklar `FLAG_TYPES`'la varsayılan okur (`game_state.gd:42-48` yorumu); `tools`/`service`
   kalemi `finance_system.gd:104-115` başlangıç şekline geri yüklendiği için kendiliğinden düşer; `InfraSystem` kayda girmez
   (`to_dict/from_dict` yalnız uyarı mandalı, çağıranı yok). Şema 18 kalır (`save_manager.gd:16`); 19 C3a'nın. D, D1'de 19
   bekler (`AJAN_MESAJLARI.md:81`, `D0t_HARITA.md:223`): C3a beklerken D1 başlarsa durur; plan bunu §6'da yazıyor, çakışma yok.
5. "Erdem'e" listesi: madde 1, 3, 4 gerçek açık (Karar 15 tavanlı metne verildi; Karar 7 araştırma sonrası seçim ister;
   Karar 11'in notu "Erdem'e soruldu" der). Madde 2 çelişki değildi (Karar 13 "geri dönüş yok" açık): nota çevrildi. Eksik
   olan iki madde eklendi: 5 kredi, 6 C9b buff seçimi ve kodda olmayan koordinasyon kaybı.
6. W1: `W1_METINLER.json`'un 242 öğesi ve bu belgenin metin tabloları `python -I` ile denetlendi: tire yok, TR ve EN yer
   tutucuları aynı, yer tutucular `[a-z_]+`, Türkçede yer tutucuya bitişik ek yok.

**Düzeltilen (11)**
1. §1 10-19 notu: kredi "C dışı" yerine "bekler: Erdem", §7 madde 5.
2. C1: Ar-Ge düğümü silinince `research_tree.gd:188-190` "4 / 8 / 8" biçim denetimi açılışta bağırırdı; `rnd_tree_view.gd:44`
   `FAMILY_SIZE := 5` Pratik ailesini "4/5"te bırakırdı. İkisi ve "yirmi düğüm" yorumları (`research_seam.gd:10`,
   `rnd_tab.gd:24`, `hr_assignments.gd:117`) eklendi, `--rnd-shot` karesi kapıya girdi.
3. C1: Karar 13'ün kuralı yalnız seçicide (UI) yazılıydı; `InfraSystem.set_provider` (`infra_system.gd:229-233`) inişi
   reddeder, bot ve debug da aynı kapıdan geçer; smoke'a iniş satırı ve falsification eklendi.
4. C1: `outage_load_mult()` yerine var olan `load_mult()`; seam adı `olay.outage_load`.
5. C1 W1: `PROD_RND_NODE_SCALABLE_BACKEND_DESC` "Kalabalık gün artık bir kaza değil" etki iddiası taşıyordu, etki kalkınca
   yalan olurdu; ikinci cümle düştü.
6. C4: altyapı sorusu (`sales_probes.gd:196-201`) kalırken onun kayıp nedeni `LOSS_PROVIDER_TRUST` siliniyordu; Ekonomik'te
   soruyu soran ve giden müşteri fiyatı söylerdi (`sales_meeting_system.gd:343-353` kalan dallar). Kayıp nedeni, iki CSV
   anahtarı ve `main.gd:3888` görüşme karesi kalır, yalnız okuma değişir; silinen CSV yalnız `SALES_WHALE_PROVIDER_OR_CERT`.
7. C4: `urun.enterprise_trust` seam açıklaması (`seams_product.gd:121`) ve `research_tree.gd:47-48` yorumu madde kuralından
   sonra yanlış anlam taşır; düzeltilecekler listesine girdi.
8. C9a: kira yalnız varışta yazılsaydı C9a'dan önce taşınmış kayıt hiç kira ödemezdi (`burn_breakdown` kayıtta,
   `finance_system.gd:104-115`); her tik geçerli ofisin kirası çekilir, Kayıt satırı yazıldı.
9. C9a: peşin `apply_one_time_cost`'a etiket kimliği ister (`finance_system.gd:42` `ONE_TIME_LABELS`); `office_upfront` ve
   W1 satırı `FIN_ONETIME_OFFICE` eklendi.
10. C9a: tavansız dünyada kadro masayı aşar; `free` ve `taken` masaya oturanı yazar ("12 masa · 15 dolu" çizilmez).
11. §7 madde 2 nota çevrildi; madde 6 (C9b) eklendi; C9a'ya `ISLER.md` açık işi ve HARITA `:126` belge payı yazıldı.

**Düzeltemediğim**
- Karar 15 "sarı": oyunun uyarı rengi `D_WARN` `#E8913A` (`ui_tokens.gd:500`) kehribar turuncusudur, renk körü ikizi soluk
  sarıdır. Yeni renk yazılmaz (UI kanunu); Erdem C9a karesinde görür, "daha sarı" derse token kararıdır.
- Karar 1'in bilgi notu "Yerel'de 12 hata ve %104 yükte haftalık kesinti %75" HEAD sayılarıyla tutmuyor: 0,1 × (1 + 12 / 8) =
  0,25 (`p_max` 0,3 altında), × 2,5 = 0,625; yalnız kesinti payına uygulanınca daha düşük. Kural (A) değişmez; C1'in
  `load_mult_steps` vakası gerçek sayıyı basar, E2 raporu yazar.
- Satır numaraları HEAD'e göredir; Q'nun çalışma ağacındaki outsource silmesi (`sales_meeting_system.gd` dahil) C4'ün
  satırlarını kaydırabilir: C0q tazelemesi C başlarken yeniden okur.
