# Ekip, işe alım, moral ve kurucu

Dizin sha: f3113fa4 (DIZIN.md başlığı; yollar:satırlar bu dizinin kirli ağaç halinden okundu). Yeniden üret: `python -I tools/kod_haritasi/uret.py`.

Ne yapar: Haftalık tikte (TimeManager yuva 3) izin, Atlas aday araması, moral, tükenmişlik, deneyim ve eğitimi sırayla işler. Oyuncu eylemlerini (zam, terfi, izin, çıkarma, eğitim, mesai) tek kapıdan yazar.
Bir kişinin etkin çıktısı, çalışma saati, görünüşü ve kurucunun onboarding dağılımı da buradadır. Tüm HR sayıları `HRConstants`'ta; durumun sahibi `CharacterRegistry` ve `GameState`.
Kaynak: GDD Ekip modülü ve GDD ch02.
Sahipler: autoload `CharacterRegistry`; sınıf `Character`, `HRSystem`, `HRConstants`, `HRActions`, `HRCandidateGenerator`, `HRSearchSystem`, `HRMoraleSystem`, `WorkHoursSystem`, `FounderConstants`; arayüz `HRUiShared`, `HRAssignments`,
  ↳ `HRLedger`, `HRPopover` (08_sekmeler.md).

## Dosyalar
- `scripts/systems/hr_system.gd` (554): günlük orkestratör + okuma yüzeyi (etkin çıktı, verim, atama sorguları, kurucu görev durumu, deneyim ve eğitim tiki)
- `scripts/systems/hr_morale_system.gd` (353): moral hedef/ease/sürüklenme, yaz izni, kaçma riski, istifa zarı, tükenmişlik, ayrılış
- `scripts/systems/hr_search_system.gd` (303): Atlas arayışı durum makinesi (idle, searching, files_ready), işe alım, aday önizlemeleri
- `scripts/systems/hr_candidate_generator.gd` (276): aday dosyası üreticisi; saf, RNG'siz, tohumdan üçlü ve baskınlık denetimi
- `scripts/systems/hr_actions.gd` (332): kart eylemleri (zam, terfi, izin, işten çıkar); her biri can_ / preview_ / apply üçlüsü
- `scripts/systems/hr_constants.gd` (1164): Ekip modülünün TEK ayar bloğu (roller, alanlar, işler, huylar, moral, izin, mesai, arama, eğitim, isim havuzları)
- `scripts/systems/work_hours_system.gd` (337): çalışma saati çözümleyicisi (kişi, grup, şirket), taslak, ek mesai tahakkuku, oturum kapısı
- `scripts/systems/founder_constants.gd` (197): kurucu becerileri, onboarding dağıtım kuralı, huy kataloğu, köken, portre yolları
- `scripts/systems/look_system.gd` (145): kişinin görünüşü; tohumdan çekilir, koşuda benzersiz, Frank'in saçına kapalı, kurucu görünüşleri
- `scripts/systems/people_parts.gd` (165): ofis kişilerinin gardırobu (Quaternius parça yüzeyleri, rol stilleri, paletler); `OfficeBody` okur
- Eğitim ve deneyim tablosu ayrı dosyada değil: `scripts/autoload/character_registry.gd:67-190` (can_train, begin_training, tick_training) ve `hr_constants.gd:937-980`.
- Dışarıda ama ayrılmaz: `scripts/autoload/character_registry.gd`, `scripts/data_models/character.gd`; UI `scripts/tabs/hr_tab.gd`, `scripts/tabs/hr/`, `personal_tab.gd`, `scripts/modals/{hr_action,training,work_hours}_modal.gd`.

## Giriş noktaları
- `HRSystem.daily_tick()` `hr_system.gd:26`: haftalık tik yuva 3 · `TimeManager` `scripts/autoload/time_manager.gd:402`
- Sıra: leave_returns, leave_departures, HRSearchSystem.daily_tick, drift, ease, thresholds, burnout, tick_experience, tick_training, sonra `hr_day_processed` (`hr_system.gd:39-51`)
- `HRSystem.tick_experience()` `hr_system.gd:66`: işi olan aktif çalışan ve kurucu deneyim biriktirir · yalnız `daily_tick`
- `HRSystem.tick_training()` `hr_system.gd:91`: eğitim haftasını düşürür, bitişte haber satırı · yalnız `daily_tick`
- `HRSystem.send_to_training(id, area)` `hr_system.gd:107`: ücreti `FinanceSystem.apply_one_time_cost("training")` ile keser · `scripts/modals/training_modal.gd:173`
- `HRSystem.effective_skill(c, area)` `hr_system.gd:376`: kanonik etkin çıktı; Liderlik burada YOK · `b2b_sales_system.gd`, `rnd_system.gd`
- `HRSystem.daily_contribution(c, area)` `hr_system.gd:491`: etkin çıktı × saat çarpanı · `customer_rep_system.gd`, `rnd_system.gd`, `support_system.gd`
- `HRSystem.productivity(c)` `hr_system.gd:397`: (1 + moral payı) × olay payı · `sprint_system.gd`, `sales_rep_system.gd`
- `HRSystem.add_productivity_mod(...)` `hr_system.gd:426`: olay kartının süreli verim satırı · `EvEffects` verbü `productivity_mod` (`scripts/events/core/effects.gd`)
- `HRSystem.is_busy(c)` `hr_system.gd:150`: izin, eğitim ya da toplantıdaki kurucu · `support_system.gd`, `rnd_system.gd`, `hr_dossier.gd`, `seams_hr.gd`
- `HRSystem.assigned_to(area)` `hr_system.gd:270` ve `assigned_to_job(job)` `:275`: bugün çalışabilir kişiler · satış, CS ve destek sistemleri
- `HRSystem.founder_task_state()` `hr_system.gd:236` ve `founder_task_label()` `:219`: türetilir, saklanmaz · `seams_hr.gd`, `hr_dossier.gd`, `personal_tab.gd`
- `HRSystem.attention_count()` `hr_system.gd:524`: sol ray Ekip rozeti · `left_tabs.gd`, `seams_hr.gd`; `HRSystem.reset()` `hr_system.gd:497` ← `game_state.gd:940`, `save_manager.gd:350`
- `HRSystem.to_dict()/from_dict()` `hr_system.gd:507/511`: kayıt kapısı (yalnız moral alt yükü) · `save_manager.gd:383/401`
- `HRSystem.founder_in_meeting` `hr_system.gd:23`: statik bayrak, kaydedilmez · toplantı sahneleri (satış, VC, seed, term sheet masası) yazar
- `HRMoraleSystem.apply_delta(emp, delta)` `hr_morale_system.gd:186`: TEK moral girişi (huy ve Liderlik ölçeklemesi burada) · `effects.gd:360-374`, `hr_actions.gd`, `vc_pitch_system.gd:548`
- `HRMoraleSystem.scaled_delta()` `hr_morale_system.gd:199`: aynı hesap, yazmadan; önizlemeler okur · `hr_actions.gd:58,119,188`
- `HRMoraleSystem.send_on_leave(emp, weeks, manual)` `hr_morale_system.gd:252`: izne tek kapı · `HRActions.apply_leave`, yaz penceresi `:66`
- `HRMoraleSystem.send_on_sick_leave(emp, weeks)` `hr_morale_system.gd:339`: hastalık yokluğu (çalışmayana false, kol `refused` yazar); status `on_leave`, `Character.leave_kind = "sick"`, dönüş `away_until_day`;
  ↳ `leave_taken_year` ve `leave_until_day` yazılmaz, gidişte haber ve dönüşte moral yok (dönüş `tick_leave_returns` `:31`, haber `HR_NEWS_BACK_TO_WORK`) · `effects.gd:418` (verb `sick_leave`)
- `HRMoraleSystem.summer_week(emp, year)` `:249` bu yılın yaz izni haftası (kayma varsa o, yoksa `leave_week`) · `tick_leave_departures` `:51`; `leave_weeks_left(emp)` `:254` (başlamasına kalan hafta,
  ↳ alınmış ya da geçmişse -1) · seam `hr.leave_weeks_left`; `leave_partner(emp)` `:264` (aynı rol, çalışan, o yıl izni yok, haftalar en çok 1 farklı) · seçiciler `leave_pair`/`leave_partner`
- `HRMoraleSystem.plan_summer_leave(a, b, apart)` `:282` yazmadan planlar (`apart` geç başlayanı iki hafta arkaya alır, arkası pencereye sığmazsa kaydırmaz; `together` ikisini erken başlayanın haftasına alır),
  ↳ `apply_summer_leave(plan)` `:305` iki haftayı da bu yıla yazar (`CharacterRegistry.set_leave_override`) · `effects.gd:411` (verb `summer_leave`) ve çipi
- `HRMoraleSystem.confirm_departure(id)` `hr_morale_system.gd:270`: istifanın kadrodan çıktığı TEK yer · `effects.gd:417` (verb `employee_leaves`)
- `HRMoraleSystem.forget_employee(id)` `hr_morale_system.gd:297`: ayrılanın latch temizliği · `confirm_departure`, `HRActions.fire`
- `HRMoraleSystem.tick_burnout()` `hr_morale_system.gd:86`: `EventGate.request("team.burnout")` · `HRSystem.daily_tick`
- `HRMoraleSystem._maybe_resign()` `hr_morale_system.gd:330`: `EventGate.request("team.resignation")`; `_pending` bu kişi için roll'u durdurur
- `HRSearchSystem.start_search(role, level)` `hr_search_system.gd:97` · `hr_atlas_modal.gd:438`; `cancel_search` `hr_search_system.gd:130` ← `hr_tab.gd:347`; `dismiss_files` `hr_search_system.gd:138`
- `HRSearchSystem.hire(index)` `hr_search_system.gd:147`: Character kurar, `CharacterRegistry.add`, komisyon keser · `hr_atlas_modal.gd:464`;
  ↳ `OfficeSystem.hiring_closed()` ise `null` döner ve dosyalar masada kalır (arama sürerken dolu ofise taşınan şirket). Atlas dosya adımı o zaman masa şeridini (`_desk_strip` `hr_atlas_modal.gd`) çizer ve İşe al kapanır;
  ↳ `can_start` (`:61`) ve `preview_search` (`:204`) aynı kapıyı okur; evde sınır yoktur
- `HRSearchSystem.preview_search()/preview_hire()` `hr_search_system.gd:200/221`: Atlas'ın basacağı rakamlar (burn, runway, mesai, uyarılar)
- `HRCandidateGenerator.generate(role, level, seed, lang)` `hr_candidate_generator.gd:64`: yalnız `HRSearchSystem._deliver_files` (`hr_search_system.gd:290`)
- `HRActions.apply_raise/apply_promotion/apply_leave/fire` `hr_actions.gd:74/136/206/251`: `hr_ledger.gd:384-433` (satır menüsü, dosya) ve `effects.gd:403` (send_on_leave), `effects.gd:427` (verb `promote` = `apply_promotion`;
  ↳ zam ayrı fiil değildir, terfi zammı ve morali getirir)
- `HRActions.preview_*` `hr_actions.gd:48,111,193,222`: onay penceresinin satırları; `{ok, reason, rows}` aynı omurga
- `WorkHoursSystem.hours_for(c)` `work_hours_system.gd:63`: zincirin canlı girişi; zincir yalnız `_resolve` `:34`'te yürür
- `WorkHoursSystem.apply_state(draft)` `work_hours_system.gd:246`: modal "Uygula" · `work_hours_modal.gd:490`
- `WorkHoursSystem.workday_end()` `:126`, `end_hour_for(c)` `:105`, `start_hour()` `:100`: gece ve ofis ritmi · `time_manager.gd`, `top_bar.gd`, `office_people.gd`
- `WorkHoursSystem.sitting_open(hours)` `:57`: kurucunun dört oturumunun giriş kapısı · `vc_pitch_system.gd`, `sales_ledger.gd`, `sales_tab.gd`, `hunt_tab.gd`
- `WorkHoursSystem.overtime_pay_accrued_today()` `:333`: Finans çeker (itme yok) · `finance_system.gd`; `company_window()` `work_hours_system.gd:112` · `mail_clock.gd`, `incident_system.gd`
- `LookSystem.for_person()` `look_system.gd:123`, `founder(portrait_id)` `:116` · `character_registry.gd:530-536`, `hr_search_system.gd:296`, `counterpart_system.gd:101`, onboarding
- `FounderConstants.validate_alloc/validate_traits` `founder_constants.gd:137/152` · `game_state.gd:966,991`, `origin_traits_step.gd`, `main.gd:5363`
- `FounderConstants.to_ruler(points)` `founder_constants.gd:33`: onboarding birimi → 0-10 cetvel (×2) · `game_state.gd:987` (`_build_founder` `:960`)
- `FounderConstants.starting_cash(origin, difficulty)` `founder_constants.gd:187` · `first_week_doc.gd`; `portrait_path()` `founder_constants.gd:192` · `ui_factory.gd:113`, `inbox.gd:467`, `personal_tab.gd:87`, onboarding
- İzin alanı yazıcıları: `CharacterRegistry.set_away(id, kind, until_day)` `character_registry.gd:613` (hastalık), `set_leave_override(id, week, year)` `:623` (kaydırılmış yaz izni haftası)
- Eğitim durumu yazıcıları: `CharacterRegistry.begin_training` `character_registry.gd:142`, `tick_training` `:158`, `add_experience` `:122`, `training_fee_for` `:134`

## Sinyaller
- `hr_day_processed`: yayan `hr_system.gd:51` (günün sonu) · dinleyen `sprint_system.gd:1315`, `hr_dossier.gd:54`
- `assignment_changed(id)`: yayan `character_registry.gd:244,285,294,311` ve `work_hours_system.gd:270-317` (her mesai yazıcısı) · `sprint_system.gd:1317`, `research_bar.gd:58`, `office_people.gd:85`
- `headline_added(source, line)`: yayan `hr_system.gd:100`, `hr_morale_system.gd:41,264`, `hr_search_system.gd:302` · `time_manager.gd:85`, `news_ticker.gd:72`
- `employee_promoted(id, level)`: yayan `hr_actions.gd:154` · dinleyen yok
- `leave_requested(id)`: yayan `hr_morale_system.gd:65` (yaz izni başlarken; izin yine de otomatik başlar) · dinleyen yok
- `employee_training_changed(id, weeks_left)`: yayan `character_registry.gd:153,164,180` · `build_bar.gd:45`, `research_bar.gd:59`
- `training_started(id, area)`: yayan `character_registry.gd:154` · `sprint_system.gd:1319`; `training_completed` `character_registry.gd:182` · dinleyen yok
- `employee_experience_changed` ve `experience_bar_full`: yayan `character_registry.gd:129-130,181` · bar_full yalnız smoke dinler
- `employee_hired(id)` `character_registry.gd:462` · `sprint_system.gd:1318`; `character_added` `character_registry.gd:460` · `left_tabs.gd:108`, `office_people.gd:83`
- `character_removed` `character_registry.gd:560` · `sprint_system.gd:1316`, `hr_dossier.gd:55`, `left_tabs.gd:109`, `office_people.gd:84`; `employee_departed` `character_registry.gd:561` · dinleyen yok
- `morale_changed` `character_registry.gd:624` · `left_tabs.gd:107`; `morale_band_changed` `character_registry.gd:627` · yalnız smoke; `productivity_changed` `:585,596` · dinleyen yok
- Tanımlı ama yayanı yok: `raise_requested`, `employee_eligible_for_promotion` (`event_bus.gd:76,73`; GDD'de adı geçtiği için silinmez)

## Durum ve veri
- `GameState.hr_search` `game_state.gd:280`: {state, role, level, seed, arrival_day, files}; boş sözlük = idle (`hr_search_system.gd:30-36`); `initialize_run` `:880` temizler
- `GameState.company_start_hour` `:285` (09), `company_work_hours` `:286` (8), `group_work_hours_override` `:288`; varsayılanlar `HRConstants.START_HOUR_DEFAULT`, `WORK_HOURS_DEFAULT`
- `GameState.issued_looks` `:203` ve `register_look` `:428`: koşuda verilmiş görünüş imzaları; `run_hires` `:200` (aday tohumu, izin haftası, kimlik)
- `GameState.founder_portrait` `:21`, `name_lang` `:27` (aday isim havuzu koşunun açıldığı dil); `get_founder_skill` `:651` (OLD_SKILLS okunursa push_error)
- `Character` alanları `scripts/data_models/character.gd`: morale `:30`, morale_target `:93`, level `:41`, salary_floor `:44`, last_raise_day `:47`, status `:51`, leave_until_day `:53`, leave_taken_year `:54`
- İzin alanları: `leave_week_override`/`leave_override_year` `character.gd:89-90` (olay kartının bu yıl için kaydırdığı hafta; ertesi yıl `leave_week` döner), `leave_kind`/`away_until_day` `:95-96` (izin dışı yokluk;
  ↳ `HRConstants.LEAVE_KIND_SICK`)
- Devamı: flight_risk_weeks `:55`, overtime_weeks `:56`, assigned_job_ids `:64`, training_weeks_left `:71`, training_area `:72`, experience_raw/threshold `:77-78`, work_hours_override `:82`, leave_week `:86`
- Devamı: productivity_mods `:99`, employment_history `:103`, look `:22`, traits `:33`, role_stats `:36`; hepsi `@export`, `SaveCodec` kendisi bulur
- Bayraklar: `hr_manual_leave_<id>` (`hr_morale_system.gd:19`; 0 = yaz izni, >0 oyuncu izninin haftası), `debug_hr_force` (`:348`, yalnız debug build)
- Statik durum: `HRMoraleSystem._pending` (bekleyen istifalar, `hr_morale_system.gd:24`); `HRSystem.founder_in_meeting`. Başka statik yok, aday dosyaları `GameState.hr_search`'te
- Kayıt: `HRSystem.to_dict` yalnız `{"morale": {"pending_departures": [...]}}` taşır (`save_manager.gd:383`); gerisi GameState ve Character alanlarıdır
- Veri dosyası YOK: `data/` altında hr dizini yoktur, sayılar kodda. Yalnız kartlar JSON'dadır: `data/events/cards/team/*.json` (burnout, resignation, lead_overtime, outside_offer, password_rule, demo_day …)
- `HRConstants` ana sabitler: roller `:304-312`, `ROLE_GROUP` `:326`, işler `:99-142` (`JOBS`, `MAX_JOBS_PER_PERSON`), `FOCUS_MULT_*` `:145`, `SECONDARY_AREA_MULT` `:236`
- Devamı: `TRAITS` `:419`, `ROLE_TRAIT_BAN` `:486`, `SALARY_BANDS_BY_LEVEL` `:586`, `ARCHETYPES` `:614`, `ARCHETYPE_SHAPE` `:619`, `SEARCH_COMMISSION_PCT` `:712`, `CANDIDATE_COUNT` `:715`
- Devamı: mesai `WORK_HOURS_*` `:720-728`, `DECAY_*`/`YIELD_FLOOR` `:767-769`, `OVERTIME_WAGE_MULT` `:756`, `BURNOUT_WEEKS` `:759`, moral `:840-910`, eşik `MORALE_FLIGHT_RISK` `:901`
- Devamı: deneyim ve eğitim `:937-962`, istifa `:1048-1051`, yaz izni `:1073-1087`, `LEAVE_COOLDOWN_WEEKS` `:1078`, tazminat `:1114-1125`, zam ve terfi `:1130-1135`, isim havuzları `:1140-1159`
- `FounderConstants`: `SKILLS` `:11`, `POINT_POOL` 6 `:19`, `ONBOARDING_CAP` 3 `:20`, `RULER_SCALE` 2 `:30`, `TRAITS` `:44`, `ORIGINS` `:64`, `PORTRAIT_IDS` (11) `:88`
- `LookSystem`: `FRANK_LOOK` `:22`, `FOUNDER_LOOKS` (11, PORTRAIT_IDS sırası) `:27`, `MIN_APART` 2 ve `TRIES` 64 `:17-18`; portre PNG'leri `assets/art/portraits/` (tools/people/bake_portraits.gd üretir)

## Metin anahtarları
- `HR_*` (yaklaşık 40 aile): `HR_ERR_`, `HR_ROW_`, `HR_RAISE_`, `HR_PROMOTION_` (hr_actions); `HR_WARN_`, `HR_ATLAS_`, `HR_NEWS_FILES_READY` (hr_search_system)
- `HR_NEWS_*` (`HR_NEWS_TRAINING_DONE`, `_BACK_FROM`, `_ON_LEAVE`, `_ON_HOLIDAY`: hr_system, hr_morale_system); `HR_PACE_*`, `HR_STATE_*`, `HR_TASK_*`, `HR_FOUNDER_STATE_*` (hr_system)
- `HR_AREA_`, `HR_ROLE_`, `HR_LEVEL_`, `HR_JOB_`, `HR_GROUP_`, `HR_TRAIT_`, `HR_BADGE_`, `HR_RESIGN_VOICE_<n>`, `HR_AGENCY_NAME` (hr_constants.gd; anahtar çoğu id'den KURULUR: grep ile bulunmaz)
- `HR_TRAINING_*` (character_registry, training_modal, hr_ledger, personal_tab); `HR_HOURS_*` (work_hours_modal, hr_tab); `OFFICE_ACT_SLEEP`, `OFFICE_ACT_PLAN` (hr_system)
- `ONB_SKILL_*`, `ONB_ORIGIN_*`, `ONB_WHY_TRAIT_POS/NEG` (founder_constants + origin_traits_step); `SKILL_LABEL_*` (kurucu beceri küçük harf parçası); `TRAIT_<AD>_NAME/EFFECT` (8 kurucu huyu)
- Kurucu huyu etki metni var, etkisi YOK (bkz. Dikkat). Aday ve çalışan huyları `HR_TRAIT_*` ailesindedir, kurucununkiler `TRAIT_*` ailesindedir; ikisi karıştırılmaz.
- CSV konvansiyonu için CLAUDE.md §5 ve hafıza notu "strings.csv surgery": byte-span splice, token'lar iki dilde aynı

## Testler
- Hedefli smoke: `bash tools/smoke_run.sh <vaka>` (`CASE_TIMEOUT=300` xargs -P 2 altında). Vakalar `scripts/debug/endgame_smoke.gd` match tablosunda
- Aday ve arama: `hr_candidate_invariants`, `hr_archetype_trio`, `hr_search_cycle`, `hr_search_cancel_dismiss`, `hr_axis_key_lock`, `hires_land_in_own_column`, `desk_cap_blocks_hire`
- Moral ve izin: `hr_morale_drift_shape`, `hr_recovery_channels`, `hr_leave_cycle`, `hr_leave_shift` (olay kartının yaz izni kaydırması), `hr_sick_leave` (hastalık yokluğu), `hr_raise_and_leave`, `hr_burnout_streak`, `hr_resignation_path`,
  ↳ `leave_does_not_pause_build`, `save_old_calendar_leave_year`
- Eylemler: `hr_fire_path`, `promotion_and_raise_gate`, `hr_frank_guard`, `money_never_double_minus`; okuma yüzeyi: `hr_read_catalogue`, `hr_active_filters`, `hr_overload_badge`, `hr_constants_contract`
- Eğitim ve deneyim: `hr_training_locks`, `hr_training_eligibility_edge`, `hr_training_blocks_and_charges_once`, `hr_training_completion`, `hr_expertise_cap_respected`, `hr_experience_accrues`, `founder_trains_and_learns`
- Çıktı formülü: `effective_skill_formula`, `overload_costs_output`, `job_assignment_and_idle`, `leadership_is_trainable`; mesai: `work_hours_three_scopes`, `work_hours_draft_commits`, `hire_preview_counts_inherited_overtime`
- Kurucu ve görünüş: `founder_5skill_init`, `alloc_guard`, `trait_formula`, `single_trait_contract`, `founder_not_double_counted`, `founder_owns_accounts_manually`, `look_registry_unique_and_saved`
- Harness: `run_probe.gd` `PLAY` (`_hire_the_team`, `_move_the_company`, `_keep_the_team`), `DECISION` ve `PROBE END first_hire_week=`; preset `full_run_staff25/50`, `b2b_book20/330`
- Probe kayıt türleri (Ekip): `HR`, `GATE` (roller ve maaş), `STATE` içinde `emp=`, `PLAY` (`_hire_the_team`, `_move_the_company`, `_keep_the_team`), `DECISION` (hafta, yüzey: kademe, kapasite, taşınma, işe alım; hedef).
  ↳ Dolu ofiste kadro masaya varınca `_hire_the_team` masadaki dosyaları da işe almaz (`PROBE DECISION … hire desks_full`), dosya ya da istenen rol bekliyorsa bir kez yazılır
- Görsel: `--hr-shot=<tür>` (`main.gd` `_run_hr_shot` `:3341`): `ekip`, `ekip-saat`, `atlas`, `atlas-secili`, `atlas-ofis`, `atlas-dolu`, `dosyalar`, `dosyalar-pm`, `dosyalar-tasarim`, `dosyalar-dolu`, `dosyalar-tehlike`,
  ↳ `dosyalar-onay`, `dosyalar-mesai`, `gider`, `saatler`, `saatler-gece`, `saatler-sprint`, `gorevler`, `gorevler-arge`, `gorevler-bos`. Ayrıca `egitim`, `egitim-modal`, `egitim-secili`, `zam`, `menu`, `menu-kilit`, `cikar`,
  ↳ `cikar-eksi`, `bos`, `dosya`, `dosya-kilit`, `dosya-kurucu`, `kalabalik`, `verim`, `urunsuz`, `izin`; kadro üç bölümden (biri izinde, biri tükenmiş, biri yeni işe alınmış); `kalabalik` kırk kişilik sıkı Kadro, Geliştirme kapalı,
  ↳ liste başlığın altına kaymış; `ekip-saat` Durum'da mesai istisnaları; `atlas-secili` rol ve seviye seçili arama; `saatler-sprint` kadro yok, kurucu tek başına, ürün türü seçili,
  ↳ mesai modalinin taslağı 15 saatte (haftalık sprint puanı satırı); `dosyalar` Orta geliştirici, `dosyalar-tasarim` tasarımcı (ikisinde haftalık sprint puanı satırı var),
  ↳ `dosyalar-pm` ürün yöneticisi dosyaları (satır yok: PM sprint puanı üretmez); `atlas-ofis` şirket İş hanı'nda, boş masalı arama (başlıkta masa satırı ve Ofisleri gör, şeritsiz); `atlas-dolu` on üç masanın hepsi dolu:
  ↳ kehribar masa satırı ve uyarı renginde neden şeridi, Arayış başlat kapalı (evde `atlas` ikisini de çizmez); `dosyalar-dolu` evde başlamış aramanın dosyaları masada, şirket İş hanı'nda ve on üç masa dolu:
  ↳ dosyaların üstünde masa şeridi, İşe al kapalı; `gorevler-arge` araştırmadaki kişiyle Görevler; `menu-kilit` ve `dosya-kilit` bugün zam almış kişiyle, Zam yap satırı bekleme gerekçesiyle kilitli;
  ↳ `izin` ilk çalışanın dosyası ve İzne gönder onay penceresi (`hr_shot_izin_onay`), sonra pencerenin kendi düğmesiyle gönderilmiş: kişi izinde, satır kalan haftayla kilitli (`hr_shot_izin`), bir hafta sonra dönmüş:
  ↳ satır sonraki izne kalan süreyle kilitli (`hr_shot_izin_donus`); `verim` düşük moralli tasarımcıda ve kurucuda olay kartı satırlarıyla Kadro satırının ipucu (`hr_shot_verim_ipucu`), izindeki geliştiricinin ipucu (`_izin`),
  ↳ tasarımcının dosyası (`_dosya`), aynı dosya izinden bugün dönmüş (`_dosya_izin`) ve kurucunun dosyası (`_kurucu`); `urunsuz` kadro yok, ürün türü seçilmeden bir Geliştirici ve bir Müşteri Temsilcisi: bekleme cümlesi ve Boşta,
  ↳ sonra tür seçili Kadro ve Görevler (`hr_shot_urunsuz`, `_tur`, `_tur_gorevler`; `HRSHOT|<durum>|idle=…|waiting=…`); `dosyalar-tehlike`, `dosyalar-onay` ve `dosyalar-mesai` kadro yok, kurucu tek başına, gelir yok, kasa 10.000,
  ↳ masada Kıdemli geliştirici dosyaları ve ilki seçili: kırmızı runway ile gelir uyarısı, İşe al onay penceresi açık, şirket 15 saat iken devralınan mesai satırı; `gider` ürünü yayında olmayan şirketin gider dökümü
- Görsel (devam): `--inbox-shot=team_read_only|team_tasks_read_only` (karar beklerken Kadro ve Görevler), `--tab-shot=hr|personal`,
  ↳ `--personal-shot=<normal|cheque|ready|training|seed>` (Kişisel; `cheque` Frank'in çeki gerçek seam'iyle alındıktan sonra, `ready` deneyim barı dolu, `training` kurucu eğitimde, `seed` çek ve imzalı seed'den sonra Series A evresi);
  ↳ `--inbox-shot=personal_read_only|personal_cheque_read_only` (karar beklerken Kişisel; ikincisi çekten sonra); ölçüm `--render-probe=hr:40:3` (kırk kişilik Kadro, saat 3×; `REBUILD_MS` tam yeniden kuruluş)
- Portre yeniden üretimi: `"$GODOT" --path . -s res://tools/people/bake_portraits.gd` (pencereli, tek Godot), sonra `--headless --import`; ayrıntı `assets/art/portraits/README.md`

## Dikkat
- Sıra sözleşmesi `hr_system.gd:26-47`: eğitim EN SONDA koşmalı, yoksa biten eğitimde sıfırlanan deneyime `tick_experience` aynı tikte puan geri verir
- `hr_day_processed` SONDA yayılır; `day_advanced` günlük tiklerden ÖNCE çıktığı için ekranlar bunu dinlemeli (`event_bus.gd:89`)
- Moral iki katmanlı: `morale_target` (sürüklenen) ve `morale` (görünen). Ham yazma yok: `CharacterRegistry.set_morale` ve `apply_delta` dışında dokunma; `apply_delta` kurucu ve Frank'i sessizce yok sayar
- `morale_target` -1 doğar, ilk dokunuşta `_seed_target` doldurur (`hr_morale_system.gd:130`); yeni moral yolu eklersen onu da çağır
- Saat/aşırı yük çarpanı YALNIZ taban sürüklenmeye uygulanır (`tick_drift`); adı olan deltalar çarpandan geçmez, hem hedefe hem morale iner
- Çalışma saati zinciri (kişi ?? grup ?? şirket) yalnız `WorkHoursSystem._resolve` içinde yürür; başka yerde kopyalama (CLAUDE.md §8 yasağı). Süre OKURKEN kırpılır (`24 - başlangıç`)
- Finans bordroyu ÇEKER: HR maaş ya da mesai itmez. `FinanceSystem.daily_tick` yuva 5, HR yuva 3; işe alım komisyonu ve tazminat `apply_one_time_cost` ile kasayı eksiye düşürebilir (kasıtlı, kilit yok)
- `HRSearchSystem.hire` kimliği `char_emp_<gün>_<run_hires>`; `add()` `hire_day=today` damgalar, hire hemen ardından `day+1` yapar (kıdem ertesi tikten). Sıra değişirse YENİ rozeti ve tazminat kayar
- Aday dosyaları tohumdan üretilir ve tohum saklanır (dosyalar değil); `generate` RNG kullanmaz, global akışı tüketirse olay ve istifa zarı kayar. Baskın aday = `push_error`, dosyalar yine döner
- `arrival_day` gün damgasıdır: kayıt göçü onu çevirir (`save_manager.gd:697-699`); `current_level` eski `band` anahtarını da okur (`hr_search_system.gd:85`)
- `HRSystem.daily_tick` kurucuyu çoğu yolda dışlar: `get_employees()` yalnız `category == "employee"` döner. Kurucu için `tick_experience` ve `tick_training` onu ayrıca ekler; yeni tik eklerken aynısını yap
- Yaz izni haftası işe alım sırasından yayılır (`leave_week_for(run_hires)`, adım 5 / 13); `leave_taken_year` takvim yılıdır, kayıtta `SaveCodec.restore_registries` düzeltir (CLAUDE.md §6)
- `FounderConstants.TRAITS` yorumu doğru: 8 kurucu huyunun etkisini hiçbir sistem tüketmez (üretim kodunda `"visionary"` vb. okuyan yok); yalnız seçim kuralı ve ekran metni çalışır
- Kurucu beceri birimi: onboarding dağıtımı 0-3 (6 puan), cetvel 0-10; `to_ruler` yazma anında çarpar, başka yerde ×2 yapma. `get_founder_skill` cetvel değeridir
- Görünüş: `LookSystem.signature` imzası `GameState.issued_looks`'ta tutulur; aday dosyası görünüşünü `_deliver_files`'ta kaydeder, işe alınca `add()` aynı imzayı yeniden kaydeder (set gibi, çift yazmaz)
- Frank'in saçı + sakallı kafa yalnız Frank'indir (`is_franks`); eski kayıtta Frank görünüşlü biri varsa `fill_missing_looks` yeniden çeker. `FRANK_LOOK` değişirse portre PNG'leri ve README tablosu yenilenir
- Olay fiilleri `change_salary`, `fire_employee`, `assign_to`, `start_training` `effects.gd:40,75` listelerinde var ama `_apply` match'inde kolu YOK (kart bu fiillerle ne yazarsa yazsın uygulama yolu yok); `summer_leave`,
  ↳ `sick_leave` ve `promote` kollu
- Hastalık yeni bir status değildir: `on_leave` + `leave_kind`. `SprintSystem.away`, `get_active_employees`, mesai ve verim okuyucuları bu yüzden değişmez; yokluğun bittiği günü `_return_day` söyler (`weeks_until_return`,
  ↳ `tick_leave_returns` ve HR sekmesi onu okur). Hasta kişinin yaz izni haftası denk gelirse o yılın yaz izni atlanır (telafi yok, eğitimdeki gibi)
- Yaz izni haftasını yalnız `summer_week` okur; `leave_week`i doğrudan okuyan yeni kod olay kaymasını görmez
- Yorum bayatlığı: `hr_morale_system.gd:268` "hr_departure modifier" der, gerçek fiil `employee_leaves` (`effects.gd:413`); `game_state.gd:280` yorumu `band` yazar, anahtar artık `level`
- Üretim kodunda çağıranı olmayan (yalnız smoke): `HRSystem.output_mult_for_area`, `HRSystem.leadership_output_mult`, `HRConstants.climate_*`, `coordination_for_*`
- Hiçbir yerde okunmayan: `HRConstants.LEAVE_MAX_DEFERRALS`, `LEAVE_DEFER_WEEKS`, `MORALE_LEAVE_DEFER`, `Character.leave_deferrals` (yalnız kayıt göçü yazar). Silmeden önce GDD'ye bak (CLAUDE.md §2)
- `MIX_*` sabitleri `hr_candidate_generator.gd:30-33` ile `sales_constants.gd:271-274`'te ikizdir (KALITE.md); birini değiştirirsen aday dosyaları baytça değişir
- Kişisel penceresi seçilen huyları yalnız huy kutusu ve adıyla çizer (`personal_tab.gd:124-134`); "yakında" etiketi kodda ve CSV'de yoktur
- Ekran karesi (görsel kabul) paralel koşmaz, `--hr-shot` pencerelidir; smoke headless

## Bir değişiklik yaparken
- Yeni HR sayısı: `HRConstants`'a koy ([WORKING] etiketli ayar sabiti), tasarım sabiti değişikliği "onay bekliyor" altında raporlanır (CLAUDE.md §3); `hr_constants_contract` vakasını koş
- Moral kaynağı ekle: ham delta ver, `HRMoraleSystem.apply_delta` çağır; önizleme gerekiyorsa `scaled_delta`; olay kartıysa fiil `change_morale`/`morale_all`/`morale_crew` (`effects.gd:354-375`) zaten geçer
- Yeni kişi alanı: `Character`'a `@export` ekle (SaveCodec bulur), anlamlı varsayılan ver, göç gerekiyorsa `save_manager.gd:1241-1274` desenine bak; `SCHEMA_VERSION` ve `reset` yolunu kontrol et
- İzin olmayan yeni yokluk türü: yeni status yerine `Character.leave_kind` + `away_until_day` ve `tick_leave_returns`ta kendi dalı (hastalık örneği)
- Yeni durum (`STATUS_*`): `HRConstants.STATUS_*`, `HRSystem.is_busy`, `_on_duty`, `effective_skill`, `HRMoraleSystem.tick_drift`, `WorkHoursSystem.in_office` ve `D_state_cell` (`hr_ui_shared.gd`) beraber ele alınır
- Çalışma saati kuralı: `_resolve` + taslak ikizleri (`*_in` işlevleri) + `HRSearchSystem.preview_hire` + `work_hours_modal.gd`; `FinanceSystem` mesai tahakkukunu `overtime_pay_accrued_today`'dan çeker
- Yeni rol/alan/iş: `HRConstants` (ROLE_*, ROLE_AREAS, JOBS, AREA_PRIMARY_JOB, ROLE_GROUP), `HR_ROLE_`/`HR_JOB_`/`HR_AREA_` CSV anahtarları (iki dil), `ROLE_STYLES` (`people_parts.gd:118`), `CharacterRegistry.assign_job`
- Yeni görünüş parçası: `PeopleParts` (SURFACES, STYLES, HEM/SHOE_TOP), `OfficeBody` yüzey eşlemesi, `LookSystem` sabitleri; kurucu/Frank portreleri etkileniyorsa `tools/people/bake_portraits.gd` ve `assets/art/portraits/README.md`
- Yeni kurucu becerisi/huyu: `FounderConstants` (SKILLS, TRAITS, üç `*_KEYS` tablosu), `ONB_SKILL_*`/`TRAIT_*`/`SKILL_LABEL_*` CSV, `origin_traits_step.gd`, `first_week_doc.gd`, `GameState._build_founder`; `alloc_guard`, `trait_formula`
- Olaya açılan okuma: `scripts/events/seams/seams_hr.gd` (adlar sözleşme, `hr.*` ve `founder.*`), fiil için `effects.gd`; `_vocabulary.md` `--event-vocab` ile yenilenir
