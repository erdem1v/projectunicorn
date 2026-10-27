# Olay motoru ve kartlar

Dizin sürümü: git f3113fa4 (DIZIN.md başlığı, 2026-10-22; yollar ve satırlar kirli ağaçtan okundu). Kapsam: `scripts/events/`, `data/events/`, lint ve sözlük araçları.

Ne yapar: Olay motoru autoload değildir; statik `EventGate` cephesi ve `Ev*` sınıfları JSON kartları (`data/events/cards`, `arcs`) yükler, her kartı tek kapıdan (G1-G8) geçirir, kuyruğa ya da masaya koyar.
Oyuncu seçince etkileri (`EvEffects`) uygular, geçmişe yazar. Sistemler kartı kimliğiyle ister, kuramaz; durum yalnız `scripts/events/seams/` adlı okumalarından gelir. Motor md: `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`.
Kaynak: Olay motoru için GDD Olay Motoru rev 2 (.md); olay içeriği (`data/events`) için GDD ch11.
Sahipler (motor): sınıf `EventGate` (statik cephe, autoload değil), `EvCatalog`; `core/` `EvEngine`, `EvQueue`, `EvHistory`, `EvFlags`, `EvLatches`, `EvSchedule`, `EvWatch`, `EvDelays`, `EvArcs`, `EvEffects`, `EvCondition`, `EvDice`, `EvBudgets`,
  ↳ `EvSignals`, `EvSave`, `EvTuning`; `gate/` `EvGate`, `EvScope`; `present/` `EvPresenter`, `EvPapers`, `EvTempo`, `EvTicker`, `EvChips`; `seams/` `EvSeams` ve `EvSeams*`; model `GameEvent`, `EventChoice`. Sahipler (içerik):
  ↳ yükleyici `EvCatalog`; `cards/` altında özyinelemeli yürür.

## Dosyalar
- `scripts/events/event_gate.gd` (227): `EventGate`, motorun tek dış cephesi (statik); her çağrıyı `EvEngine/EvQueue/EvPapers/EvPresenter`'a iletir
- `scripts/events/catalog/catalog.gd` (309): `EvCatalog`, kart ve ark JSON'larını yükler, varsayılanları doldurur, şema v3 `plausibility` bloğunu koşul yapraklarına derler
- `scripts/events/core/engine.gd` (794): `EvEngine`, günlük/saatlik tik sırası (a-l adımları), `_admit`, `pump`, `resolve`, `request`, `force_fire`, `open_paper`, `set_aside`
- `scripts/events/core/effects.gd` (1056): `EvEffects`, fiil sözlüğü (NEUTRAL/ECONOMIC/TERMINAL) ve `_apply`; I2/I3/I6 kuralları köken başına (`_permitted`)
- `scripts/events/core/condition.gd` (377): `EvCondition`, koşul ağacı (`all/any/none/not` + seam, flag, history, arc, entity yaprakları); `eval`, `explain`
- `scripts/events/core/queue.gd` (252): `EvQueue`, kabul edilmiş ama gösterilmemiş kartlar ve etkin kart; öncelik `PRIORITY`, görünürlük süzgeci `_shown`
- `scripts/events/core/history.gd` (200): `EvHistory`, çözüm satırları (chosen/expired/dropped), yalnız kimlik saklar; geriye bakan sorgular
- `scripts/events/core/latches.gd` (143): `EvLatches`, one_shot / max_fires / cooldown_weeks mandalları, anahtar `run` ya da `entity`
- `scripts/events/core/flags.gd` (131): `EvFlags`, motorun kendi bayrak, süreli bayrak ve damga deposu (`GameState.flags`'tan ayrı)
- `scripts/events/core/schedule.gd` (161): `EvSchedule`, ertelenmiş sonuçlar (saf veri, Callable yok); `delayed` girdileri
- `scripts/events/core/watch.gd` (56): `EvWatch`, `after_test`in bekleyen girdileri (saf veri); kartın testi bitince `EventBus.card_phase_changed` ile iner, `EvSave` bloğunda `watch`
- `scripts/events/core/arcs.gd` (230): `EvArcs`, canlı arklar (promise/character/world/assignment), konu, adım, politika reassign/close/fade
- `scripts/events/core/delays.gd` (140): `EvDelays`, sinyal kartının gecikme penceresi ve modül açılış gözlemi
- `scripts/events/core/signals.gd` (109): `EvSignals`, `EventBus` sinyallerinin izinli listesi (`BINDINGS`), kartları dinlenen sinyale bağlar; `EvWatch.on_phase`i de bağlar (tetik değil)
- `scripts/events/core/tuning.gd` (169): `EvTuning`, tek ayar yüzeyi (aralıklar, kotalar, bütçeler, `SHIPPED_SCOPES`)
- `scripts/events/core/dice.gd` (65): `EvDice`, FNV-1a ile belirlenimci zar (`unit`, `check`); `core/budgets.gd` (53): `EvBudgets`, adlı bütçeler
- `scripts/events/core/save.gd` (108): `EvSave`, motorun `event_engine` kayıt bloğunu tüm depolardan toplar ve geri yükler
- `scripts/events/gate/gate.gd` (288): `EvGate`, tek kabul kapısı `propose` (G1-G8), `revalidate`, `Verdict`, başlangıç bağışıklığı
- `scripts/events/gate/scope.gd` (408): `EvScope`, adlı kapsam slotları (employee/founder/customer/prospect/rival/investor) ve seçiciler
- `scripts/events/present/presenter.gd` (306): `EvPresenter`, kart sözlüğünden `GameEvent` görünümü, metin çözme, ad ve seam dondurma, masa satırları
- `scripts/events/present/chips.gd` (437): `EvChips`, etki ve delta çiplerinin tek kurucusu (`describe`), kaynak rozeti `source_tag`
- `scripts/events/present/papers.gd` (206): `EvPapers`, masa (süreli kâğıtlar); süre dolumu, son uyarı, `desk_changed`
- `scripts/events/present/tempo.gd` (316): `EvTempo`, dört katmanlı fren (kart, aile, konu, kategori kotası), sınıf atama `assign`
- `scripts/events/present/ticker.gd` (60): `EvTicker`, haber bandına itme sözleşmesi (`push`, player/world önceliği)
- `scripts/events/seams/seams.gd` (161): `EvSeams`, adlı salt okunur sorgular kaydı; `register`, `read`, `read_for`, `mock`
- `scripts/events/seams/seams_{hr,product,finance,sales,world,ported,incident}.gd` (191/343/66/132/160/194/45): seam alanları (hr+founder, urun+arge+paper, finance, musteri+sales+destek,
  ↳ phase+rival+investor+time+office+build, funding+port, olay)
- `scripts/events/tools/lint.gd` (1186): `EvLint`, içerik denetçisi (§17: yapı, marka, tire, saat, v3 kuralları P/C/V/O/T, ulaşılabilirlik, sinyal)
- `scripts/events/tools/engine_probe.gd` (700): `EvProbe`, motor öz denetimi tek açılışta (seam, koşul, bayrak, geçmiş, mandal, kapsam, kuyruk, etki, kayıt, tez testi, ark)
- `scripts/events/tools/harness.gd` (424): `EvHarness`, otomatik oynatma (random ve guided), her 7 haftada kayıt/yükle
- `scripts/events/tools/why.gd` (266): `EvWhy`, "bu kart neden gelmedi" raporu; kapıyla aynı `EvGate.propose` yolunu çağırır
- `scripts/events/tools/vocab_gen.gd` (351): `EvVocabGen`, `docs/content/events_draft/_vocabulary.md`'yi motordan üretir (KEEP bloğu elle kalır)
- `scripts/events/tools/plausibility.gd` (396, class_name yok) ve `plausibility_main.gd` (41, SceneTree girişi): makullük defteri, oynanan koşularda ekrana gelen her kartı v3 kurallarına göre yargılar
- `scripts/data_models/event.gd` (21) `GameEvent`, `event_choice.gd` (11) `EventChoice`: kartın çizilebilir görünümü, kaydedilmez; `scripts/systems/module_locks.gd` (35): `ModuleLocks` (delays ve seams_world okur)
- `data/events/cards/<kategori>/*.json`: 146 yüklenen kart (customer 17, founder 7, funding 25, product 57, rival 6, team 9, world 8, `_fixtures` 17 üst düzey); `unwired/` 3 kart yüklenmez
- `data/events/arcs/*.json`: 3 ark (`fixture_subject`, `fixture_thesis`, `soft_cap_stretch`); `cards/_fixtures/README.md` motor test içeriğini anlatır
- `tools/lint_baseline.json` (kabul edilmiş bulgular, 7 kayıt), `tools/lint_v3_frozen.json` (v3 öncesi hikâye kartları), `tools/plausibility_run.sh`, `tools/gen_signal_manifest.py` (-> `docs/EVENT_SIGNAL_MANIFEST.md`)
- Tüketiciler (başka sistem sayfasında): `scripts/tabs/events/mail_pane.gd` (885, okuma bölmesi), `scripts/ui/components/inbox.gd` (570), `scripts/tabs/events_tab.gd` (369), `scripts/systems/mail_clock.gd` (121)

## Giriş noktaları
- `EventGate.request(id, ctx, immediate, stamp)` `scripts/events/event_gate.gd:19` -> `EvEngine.request` `core/engine.gd:715`: bir sistem kartı adıyla ister; masada beklenen örnek varsa onu açar · kim çağırır:
  ↳ `customer_rep_system.gd:304`, `hr_morale_system.gd:93,341`, `incident_system.gd:268`
- `EventGate.request` çağıranlar devamı: `sprint_system.gd:976,1091,1221`, `sprint_bridges.gd:199`, `endings_system.gd:121` (SHUTTER_CARD), `main.gd:1160`, `mail_pane.gd:794` (immediate=true, oyuncunun isteği)
- `EventGate.daily_tick()` `event_gate.gd:171` -> `EvEngine.daily_tick` `engine.gd:68` · `TimeManager` günlük dağıtım, Finans ve Faz kapısından sonra, `IncidentSystem`'den önce (`scripts/autoload/time_manager.gd:417`)
- `EventGate.hourly_tick(hour)` `event_gate.gd:175` -> `EvEngine.hourly_tick` `engine.gd:90` · `TimeManager._dispatch_hourly_tick`, `MailClock.hourly_tick`'ten sonra (`time_manager.gd:451`)
- `EvEngine.pump()` `engine.gd:554`: kuyruktaki en önemli kartı §4.4 yeniden doğrulamasından (`EvGate.revalidate`) geçirip gösterir · tik sonu, `resolve`, `clock_batch_ended` (`signals.gd:54`), `main.gd:5211` (yükleme sonrası)
- `EventGate.resolve(id, option)` `event_gate.gd:26` -> `EvEngine.resolve` `engine.gd:613`: seçenek id ya da indeksi; etkiler, geçmiş satırı, ark ilerletme · çağıran: `mail_pane.gd:492`, bot ve smoke
- `EventGate.open_paper(key)` `event_gate.gd:145` -> `engine.gd:759`, `EventGate.set_aside()` `event_gate.gd:151` -> `engine.gd:785`: masadaki kâğıdı aç ve cevapsız geri koy · `mail_pane.gd:529,542`
- `EventGate.force_fire(id, ctx)` `event_gate.gd:40` -> `engine.gd:738`: yalnız debug build; G3, G4, G8'i atlar, satırı `forced: true` yazar · smoke ve `main.gd:1200,1419`
- `EventGate.flush()` `event_gate.gd:136`: bekleyen sahneleri öldürür · `endings_system.gd:481`; `EventGate.reset()` `event_gate.gd:167` · `save_manager.gd:344` (yeni oyun)
- `EvGate.propose(id, origin, given)` `gate/gate.gd:71`, `EvGate.revalidate` `gate.gd:122`: G1-G8 kapısı · yalnız `EvEngine._propose` (`engine.gd:433`), `EvWhy.report`, `EventGate.condition_*` çağırır
- `EvEngine.on_signal` `engine.gd:276`: sinyal tamponu, adım (g)'de boşalır · `EvSignals._relay` (`signals.gd:99`); `EvSignals.install()` `signals.gd:50` her `EvCatalog.reload()`'da (`catalog.gd:47`) bağlanır
- `EvCatalog.ensure_loaded()` `catalog.gd:32` / `reload()` `catalog.gd:37`: kartları ve arkları yükler, seam'leri kurar (`EvSeams.ensure_installed` `seams.gd:39`) · `main.gd:4682` (`_warm_catalogs`)
- `EvSave.to_dict()` `save.gd:20` / `from_dict()` `save.gd:39` · `save_manager.gd:382,400`; `EvLint.run` `lint.gd:79`, `EvProbe.run` `engine_probe.gd:16`, `EvHarness.run` `harness.gd:84`, `EvWhy.report` `why.gd:28`,
  ↳ `EvVocabGen.run` `vocab_gen.gd:20`
  ↳ `from_dict` geçmişten ve saatten sonra `EvEngine.restore_unannounced()` `engine.gd:683` çağırır:
  ↳ motorun adını anacağı not listesi (`_unannounced`, kaydedilmez) kaydın geçmiş satırlarından yeniden kurulur (`EvHistory.notes_awaiting_arrival()` `history.gd:174`: okunmamış ve geliş saati şimdiden sonra not),
  ↳ yoksa yüklemede unutulan not yeniden doğrulamasız ve `event_triggered`'siz gelen kutusuna düşerdi
- Bayrak yönlendirmesi `scripts/main/main.gd:226-251`: `--event-probe`, `--event-lint[=baseline]`, `--event-vocab`, `--why-fire=` (`_run_why_fire`), `--event-harness=`, `--event-plausibility=`,
  ↳ `--event-shot=` (`_run_event_shot` `main.gd:764`)
- Sunum yolu: `EvPresenter.build_view` `present/presenter.gd:40` -> `EventBus.modal_requested` -> `main.gd:4723` (`hold_clock("event")`, Olaylar kutusu açılır) -> `mail_pane.gd` -> `EventGate.resolve`

## Sinyaller
- `event_triggered(event_id)` `scripts/autoload/event_bus.gd:118`: yayan `core/engine.gd:565` (not geldi), `engine.gd:606` (kart gösterildi) · dinleyen: `top_bar.gd:113`, `left_tabs.gd:111`, `research_bar.gd:60`,
  ↳ `window_frame.gd:56`, `office_hud.gd:58`
- `event_resolved(event_id, choice_index)` `event_bus.gd:119`: yayan `engine.gd:631` (-1: varlık gitti), `engine.gd:672` · dinleyen: `main.gd:4692` (kapı kapanır), `save_manager.gd:63` (kirli işareti),
  ↳ `incident_system.gd:313`, `sprint_system.gd:1279`, `game_shell.gd:29`
- `modal_requested(event: GameEvent)` `event_bus.gd:120`: yayan `engine.gd:607` · dinleyen `main.gd:4691` (`_on_event_modal_requested` `main.gd:4723`), `harness.gd:99`
- `event_set_aside(event_id)` `event_bus.gd:122`: yayan `engine.gd:792` · dinleyen `main.gd:4693`, `save_manager.gd:66`, `top_bar.gd:114`, `left_tabs.gd:113`
- `desk_changed()` `event_bus.gd:125`: yayan `present/papers.gd:44,49,60,98` ve `systems/mail_clock.gd:72,108` · dinleyen `top_bar.gd:116`, `left_tabs.gd:114`, `product_tab.gd:114`
- `module_unlocked(module_id)` `event_bus.gd:135`: yayan yalnız `engine.gd:270` (`_step_module_watch`) · dinleyen kart tetikleri (`EvSignals.BINDINGS`); `goto_tab_requested(tab_id, subpage)` `event_bus.gd:34`:
  ↳ yayan `effects.gd:536` · dinleyen `main.gd:4694`
- Motorun DİNLEDİĞİ sinyaller `EvSignals.BINDINGS` `core/signals.gd:22` (17 ad, izin listesi): customer_added/_health_changed/_churned/_expanded, employee_hired/_departed, promise_broken, version_shipped, build_phase_changed
- BINDINGS devamı: sheet_expired, sheet_granted, seed_sheet_granted, meeting_day (investor slotu), phase_gate_reached, axis_floor_warning, axis_floor_crossed, module_unlocked;
  ↳ listede olmayan sinyal kartı tetikleyemez (`EvLint._lint_signals` `lint.gd:979` EventBus'ta var mı diye bakar)
- Yayanlar: `customer_registry.gd:102,186`, `b2b_sales_system.gd:308,449`, `character_registry.gd:462,561`, `promise_registry.gd:183`, `sprint_system.gd:304,305,1496,1497`, `vc_pitch_system.gd:405,417,644,872,903`,
  ↳ `phase_gate_system.gd:85`, `product_read.gd:165,167`
- `clock_batch_ended()` `event_bus.gd:25`: yayan `time_manager.gd:203` · `EvSignals.install` `EvEngine.pump`'a bağlar (`signals.gd:54`); tam liste `docs/EVENT_SIGNAL_MANIFEST.md` (`tools/gen_signal_manifest.py` üretir)

## Durum ve veri
- Motor durumu GameState'te değil, `Ev*` sınıflarının statik değişkenlerindedir; tek kayıt bloğu `EvSave.BLOCK_KEY = "event_engine"`, `BLOCK_VERSION = 1` (`save.gd:16-17`); `SaveManager._capture_systems` `save_manager.gd:382`
- Blok anahtarları (`save.gd:20-36`): `flags/timed_flags/stamps` (EvFlags), `rows` (EvHistory), `latches`, `schedule`, `watch`, `arcs`, `queue/active_event_id/active_context`, `papers`, `budgets`, `held` (EvTicker), `tempo_*`,
  ↳ `delays/modules_open/last_unlocked_module`, `run_seed`
- Katalog kayda girmez; kartlar her açılışta diskten okunur (`save.gd:6-7` yorumu); kayıtta yalnız kimlik ve skaler tutulur (`EvSave.verify_no_resources` `save.gd:81`)
- Komşu GameState alanları: `messages` `game_state.gd:318`, `mail_outbox` `:320`, `desk_arrivals` `:322`, `mentor_line_at` `:314`, `run_seed` `:24`, `run_active` `:132` (motor `run_active` false iken tik atmaz)
- Kart şeması alanları (kodda okunanlar): id, version_scope, category, tick, class, tags, schema, family, family_subject, plausibility, scope, guards, condition, latch, latch_key, min_gap_weeks, weight, allowed_hours, expires_weeks
- Kart alanları devamı: expire_note, on_expire, delay_weeks, delay_reason, follows, trigger.signal, arc, options[id, outcome_id, effects, requires, check], speaker, speaker_role, stage, pool_group, sender, system, text.tr/en
- `tick` değerleri: `daily`, `hourly`, `signal`, `scheduled`, `request` (kapı `_g4_window` `gate.gd:171`; `request` tikli kartı hiçbir saat taramaz); `class`: `interrupt`, `paper`, `info` (+ `ambient` kuyruk önceliğinde)
- Kapsam: `version_scope` değerleri `demo` (130 dosya), `ea`, `draft`, `retired`, `fixture`; G2 `EvTuning.SHIPPED_SCOPES` `tuning.gd:169` içinde mi diye bakar, değeri `EndingsSystem.shipped_scopes()` (`endings_system.gd:366,408`) verir
- Ayar sabitleri `scripts/events/core/tuning.gd`: `MIN_GAP_WEEKS_DEFAULT` 4 (`:14`), `FAMILY_GAP_WEEKS` (`:33`), `CATEGORY_QUOTA_WEEK` (`:61`), `MAX_INTERRUPTS_PER_DAY` 2 (`:80`), `START_IMMUNITY_WEEKS` 3, `DISARM_WEEKS` 4, `BUDGETS`
- Kapı sabitleri: `EvGate.DEFAULT_ALLOWED_HOURS` [8, 20] (`gate.gd:39`), `EvQueue.PRIORITY` (`queue.gd:23`), `EvLatches.DEFAULT_COOLDOWN_WEEKS` 4 (`latches.gd:21`), `EvCatalog.EXCLUDED_DIRS/EXCLUDED_PREFIXES` (`catalog.gd:17,19`)
- Fiil sözlüğü `core/effects.gd`: `NEUTRAL_VERBS` (`:32`, 59), `ECONOMIC_VERBS` (`:77`, 27), `TERMINAL_VERBS` (`:88`, 1) = 87 fiil; `_apply` kolu 81 fiile var (aşağıda Dikkat)
- Lint taban dosyaları: `tools/lint_baseline.json` (parmak izi listesi `accepted`), `tools/lint_v3_frozen.json` (`cards`: O2, O4, O5, T2, T3 bu kartlarda uyarı); `EvLint.BASELINE_PATH/FROZEN_PATH` `lint.gd:36-37`
- Sözlük çıktısı `docs/content/events_draft/_vocabulary.md` (844 satır; 293 seam, 87 fiil, 146 kart, 3 ark; elle yazılan blok 836-844); fikstür kartları `version_scope: "fixture"` taşır

## Metin anahtarları
- Kart metni `text.tr` / `text.en` bloklarında düz metin ya da anahtardır (`EvPresenter.is_key` `presenter.gd:232`: `^[A-Z][A-Z0-9_]{2,}$`); `product/sprint_*` kartları satır içi TR/EN taşır, öbürleri `strings.csv` anahtarı
- Kart anahtar aileleri: `EV_<KATEGORİ>_*` (TEAM, FOUNDER, CUSTOMER, RIVAL, PRODUCT, WORLD, FUNDING), `B2B_EV_*`, `B2B_CHOICE_*`, `FRANK_*` (APPROACH, OFFICE, DOOR, ADVISORY), `ANGEL_*`, `VC_EV_*`, `SEED_*`, `GATE_*`,
  ↳ `PROD_*`, `END_EV_*`, `HR_EV_*`
- Çip metinleri: `EFFECT_*` (okuyan `present/chips.gd`, ör. `EFFECT_NAMES_MORE` `chips.gd:382`), kaynak rozeti `EVENT_TAG_*` (`chips.gd:60`, ayrıca `ui_tokens.gd`, `inbox.gd`), `EV_MODIFIERS_MORE`
- Masa ve gelen kutusu: `DESK_PAPER_*` (`events_tab.gd`, `inbox.gd`), `INBOX_*`, `EVENT_CHOICE_*` (`mail_pane.gd`); haber bandı `TICKER_SRC_*` (`present/ticker.gd`); anahtarlar `localization/strings.csv`'de (3330 satır)
- Gövdede yalnız `{slot}` ve `{seam:ns.ad}` çözülür (`EvPresenter.SEAM_RE` `presenter.gd:27`, `_interpolate` `:270`); değişken metin `{by_seam, variants}` (`leaf_text` `:241`); iki dilde aynı id kümesi (`EvLint` §17.8)

## Testler
- Motor öz denetimi: `godot --headless --path . --event-probe` -> `PROBE PASS/FAIL n passed, m failed` (`engine_probe.gd:34`); fikstür kapsamını genişletir ve geri yükler (`:482-573`, `:584-700`)
- İçerik kapısı: `--event-lint` -> `LINT PASS/FAIL` (`lint.gd:1182`); yeni hata çıkışı 1; `--event-lint=baseline` tabanı yeniden yazar (dosya yazar, doğrulamada koşulmaz)
- Neden gelmedi: `--why-fire=<kart id>` (`why.gd`); otomatik oynatma: `--event-harness=random:seeds=N:weeks=M` ya da `guided[:seeds=N:weeks=M]` (`harness.gd:84`); sözlük: `--event-vocab` (dosya yazar)
- Makullük defteri: `--event-plausibility=<spec>` kabuk içinden ya da `tools/plausibility_run.sh` (koşu başına süreç ve kullanıcı dizini; `PLAUS FIRE/FAIL/RATE/SUMMARY`); spec `seeds=<N|A-B>:weeks=<N>:variant=<plain|early|both>:preset=`
- Smoke (`tools/smoke_run.sh <vaka>`, vakalar `scripts/debug/endgame_smoke.gd`): `event_*` 33 vaka (ör. `event_i1_single_gate` `:325`, `event_critical_drop_refunds_latch` `:294`, `event_lint_v3_rules` `:580`, `event_delay_window` `:584`)
- Smoke devamı: `event_check_with_effects` (şıkta etki ve zar birlikte, zar çipi, yükle-tekrar aynı dal), `event_after_test` (testi bekleyen etki: hata bulunursa iner ve `<sonuç>_tested` satırı yazılır, bulunmazsa düşer, izleme kayıttan geçer), `event_year_roll` (yıl zarı, tohumlu `random` ve rakip seçicileri, `{rival}` adı),
  ↳ `card_body_tokens_resolve` `endgame_smoke.gd:490`, `loc_event_en_coverage` `:318`, `event_chip_coverage` `:335`, `quiet_cards_fill_empty_floor` `:542`, `event_no_double_resolution_after_load` `:355`,
  ↳ `event_thesis_day10_to_day90` `:333`, `harness_sniffer_matches_run_log` `:368`
- Oynanan koşu: `--run-log=<preset>:<hafta>:sim` `PROBE FIRE/PICK/TALLY/WEEK` basar (`run_probe.gd:30-99`); `tools/run_gate.sh` üç koşu; görsel: `--event-shot=<kart id>[:<slot>=<varlık id>]` (`main.gd:764`, pencereli)
- Probe kayıt türleri: `FIRE`, `PICK`, `TALLY_BEGIN` / `TALLY` / `TALLY_END`, `WEEK`, `ERROR` (drain koruması, kilitsiz seçeneği olmayan kart)
- Görsel: `--event-shot=<kart id>[:<slot>=<varlık id>...]`: her çift bir slotu seçicisiz o varlığa bağlar (ör. `investor=anchor`); bağlanamayan çift ve hiçbir dünyada bağlanmayan zorunlu slot kareyi düşürür, çiftler PNG adına girer;
  ↳ çekilen kartın seam sayıları kartın tuttuğu adlarla okunur (`EvPresenter.freeze_seams`).
  ↳ Slotlarını çıplak tohum bağlayamayan kart ve her `rival.` kartı tema tohumunun şirketinde çekilir (`main._seed_company_world`: 14. hafta, kurulu ERP, `--hr-shot` kadrosu, üç hesap; kadronun kimliği `char_emp_shot_<n>`:
  ↳ `team.burnout:employee=char_emp_shot_1`); `open_request` ve `escalated` seçicileri Müşteri İlişkileri temsilcili bir hesap, `seed_lead` imzalı bir tohum turu, `customer.release_thanks` bir sürümün teşekkürü,
  ↳ `product.support_overflow` sıcak bir destek yığını ekler; bir slotun `where`'ini bu şirket karşılamıyorsa slot seçicinin seçtiğini `where`'siz bağlar;
  ↳ `founder.savings_note` ve `founder.side_contract` birikimi biten kurucuda çekilir (`main._seed_savings_ground`: 5. hafta, kasa $5.000, günlük gider 50; `--inbox-shot=beat` aynı zemini kullanır);
  ↳ `funding.monthly_update` imzalı tohum turlu şirketin kasası aylık akışının 8,5 haftasına indirilmiş hâlinde (gövde '8 hafta' yazar), `:runway=profit` ile aynı şirket giderini karşılarken (gövde runway'den söz etmez).
  ↳ Acil durum kartları (`main.gd` `INCIDENT_SHOTS` `:838`) kendi dünyalarını kurar: `product.incident_outage_b2b` ve `_b2c` gece 03:00'te, kesinti 02:10'da başlamış (B2B'de gece vardiyalı iki hesapla, B2C'de kitle ve ücretli planla),
  ↳ gönderen için `:employee=char_emp_shot_2`, `:load=<yüzde>` kesintinin zarının atıldığı sunucu yükü (kart %90 üstünde yük cümlesini söyler).
  ↳ Öbür dördü (`customer.incident_month_close` 23:00, `product.incident_checkout`, `product.incident_regression`, `product.incident_review_storm` gündüz) dolu bir sprintin koştuğu canlı üründe kurulur,
  ↳ düzeltme kartı sprintten bir kartı kaydırır (`fix_effort.per_bug` bu çekim için büyütülür), çip adını yazar; bozulma B2B'de, `:market=b2c` ile B2C'de çekilir; `product.promise_due` sprintin son haftasının başında kurulur:
  ↳ Nordica'ya bu sprint için verilmiş söz, testteki tek kart, `customer=co_nordica`; `product.b2c_floor_signal` ve `product.b2c_floor_churn` (`main._seed_floor_world` `:935`) 20.000 kitleli bir not uygulamasında çekilir,
  ↳ Güven & Ölçek'in iki hattından biri kurulu, öbür alanlar kurulu: merdiven Güven'de uyarı tutar ve gövde alanın adını yazar; `funding.sheet_expiry` (`main._seed_expiring_sheet` `:957`, `--b2b-shot=deal`'ın dünyası da) Series A'da,
  ↳ uyarının girdiği ilk haftada (iki hafta kalmış) bir teklifle çekilir ve gövde 14 gün yazar (`investor=` teklifin fonunu seçer, verilmezse anchor);
  ↳ `funding.sheet_decision` aynı teklifin süresinin dolduğu günde çekilir (`--vc-shot=k10`'un dünyası); `founder.unseen_build` türü seçilmiş, hiç yayınlanmamış ürünün ikinci sprintinde çekilir;
  ↳ kâğıt kartlarının hepsi (`pool_group` taşıyan sprint kâğıtları: pm, tasarımcı, geliştirici, testçi, testçisiz, sistem, kurucu) `_seed_paper_world`'de kurulur; `--b2b-shot=<tür>` kartı okuma bölmesinde önizler,
  ↳ `--inbox-shot=<durum>` gelen kutusunu çeker (08_sekmeler.md)
- Kural: yeni smoke vakası yalnız çekirdek mantık için; tam süit yalnız entegrasyonda (CLAUDE.md "Smoke ve probe"); bayrak `--` ayıracının ARKASINA konmaz

## Dikkat
- Tek kapı (I1): kartı yalnız `EvGate.propose` kabul eder; `EvEngine` verdikten sonra kuyruk girdisi kurar. Bir sistem kart KURMAZ, `EventGate.request("kart.id", {slot: id})` der;
  ↳ kapıyı atlayan her yol lint 17.9 hatasıdır (`lint.gd:992`)
- Tik sırası tasarımdır (`engine.gd:1-34`): süre dolumu, ark geçersizlendirme, takvim, ark adımı, modül gözlemi, sinyal boşaltma, süpürme, havuz, taban, sınıf ataması, pump;
  ↳ sinyaller slot sırasında TAMPONLANIR (`engine.gd:276`), `day_advanced`'e bağlanma
- Sınıf ataması (G8 tempo) `propose` içinde değil adım (k)'dedir: gün sonunda önem sırasıyla demote eder (`engine.gd:413`); G3 ve G8 gösterimde yeniden koşmaz, G5/G6/G7 koşar (§4.4)
- Mandal kabul anında harcanır (`engine.gd:517`); `pump` G7'de düşen `critical` + `one_shot` kartın mandalını iade eder (`engine.gd:592`), G5/G6 düşüşü ve `open_paper` düşüşü iade etmez
- Not kartı (`EvPresenter.is_note` `presenter.gd:132`): tek seçenekli, etkisiz, critical olmayan, paper olmayan kart modal açmaz; `_admit` onu doğrudan geçmişe yazar (`engine.gd:484-507`), `pump` `event_triggered` ile duyurur
- Katalog `_` ile başlayan dosyaları ve `unwired/`, `drafts/` dizinlerini HİÇ yüklemez (`catalog.gd:17-19,61-63`); `lint_v3/_bad_*.json` yalnız `event_lint_v3_rules` vakasınca doğrudan okunur. `_fixtures/` dizini yüklenir,
  ↳ `version_scope: fixture` ile G2'de kesilir
- Kapsam tuzağı: `EvTuning.SHIPPED_SCOPES` statik değişken; probe ve bazı smoke vakaları `fixture` ekler ve aynı fonksiyonda geri yükler. Geri yüklemeyi unutmak sonraki vakaya fikstür kartı sızdırır
- Şıkta `effects` ve `check` birlikte yazılabilir: `EvEngine.resolve` önce `effects`'i (`run_played`), sonra zarın seçtiği dalı (`run_check_branch`, I6) koşar; geçmiş satırının `deltas`'ı ikisini taşır. Zar `EvDice.check(oran, kart, şık)`:
  ↳ aynı gün, kart ve şık aynı dalı verir. Risk dalı `on_pass`a yazılır, oran o dalın oranıdır (`on_fail` = 100 - oran); `EvChips.describe_check` boş olmayan her dalı kendi oranıyla çizer,
  ↳ bedel ya da tehlike taşıyan dalın başlığı tehlike renginde
- Sabit oran `EvTuning.ODDS` ve `olay.odds_10/15/20/25` seam'leridir; kartta sayı yazılmaz. Lint 17.11 sabit oranlı zardan `modifier_lines` istemez (arkasında durum yok); durumdan gelen oran (`olay.award_live_odds`) ister
- `schedule_event.delay_weeks` sayı ya da `[lo, hi]`; aralığın haftası `EvDice.unit("schedule", gün, zamanlayan kart, hedef kart)`'tan çekilir.
  ↳ Çip hedef kartın her yolda (bütün şıklarda ve süre dolumunda) birebir aynı indirdiği etkileri bekleme başlığıyla yazar
  ↳ (`EvChips.landing`); ortak etki yoksa ya da hepsi sessizse çipsizdir. Lint dalda ve `on_expire`da zamanlananı da "referanslı" sayar (`_card_effects`)
- `amount_slot`: `amount_seam` bir ENTITY seam ise tutar o yuvanın varlığı için okunur (`EvEffects.amount(e, ctx)`); çip, geçmiş satırı ve bot aynı `ctx` ile okur (bot `EventGate.active_context()`). Lint seam'in türünü yuvanın türüyle eşler
- Seçiciler `EvScope.SELECTORS` listesindedir; lint 17.12 listede olmayan `select`i reddeder (`:` ile biten ad önektir, `market_rival:giant`). `random` ve rakip seçicileri tohumludur: `EvScope.resolve(yuvalar, verilen, kart_id)` gün,
  ↳ kart ve yuvanın hash'iyle
  ↳ sıralı adaylardan birini seçer; kart kimliği geçilmezse çekiliş kartın gerçek çekilişinden farklı çıkar. Rakip havuzu `RivalRegistry.get_by_type(ProductState.subtype())`, `select`siz rakip yuvası havuzun ilk boş id'sini alır;
  ↳ `{rival}` ürün adını okur
- `year_roll` yaprağı: `{"year_roll": 0.5}` takvim yılı başına bir zardır, anahtarı yükleme sırasında kartın kimliğine damgalanır (`EvCatalog._coerce_conditions`); `key` yazılırsa kartlar aynı zarı paylaşır
- Kişi seçicileri: `top_skill:<alan>` (havuzda `role_stats[alan]` en büyük, eşitlikte id), `leave_pair` (yaz izni başka birininkiyle örtüşen, partnerinden geç başlamayan,
  ↳ partnerinin izni arkasına sığacak kadar erken başlayan en kıdemli çalışan) ve `leave_partner` (yuvası `employee` olan kartın o kişisinin partneri; `HRMoraleSystem.leave_partner`). Seam `hr.role` (rol kimliği), `hr.leave_weeks_left`
- İnsan fiilleri: `summer_leave {scope, other, apart}` (iki yuvanın bu yılki yaz izni haftası: `apart` geç başlayanı iki hafta arkaya alır, değilse ikisi erken başlayanın haftasına sabitlenir;
  ↳ çipi planı `EvEffects.summer_leave_plan`dan okur, geçmiş satırı planın kendisidir), `sick_leave {scope, weeks}` (yaz iznini yemeyen yokluk), `promote {scope, pct}` (`HRActions.apply_promotion`, EKONOMİK listede;
  ↳ dosyanın reddettiği terfide kart çipi reddin nedenini yazar). `top_skill:` alanı lint 17.12'de `HRConstants.EMPLOYEE_SKILL_KEYS`e karşı denetlenir. Üçü de `WRITER_VERBS` ve `SUBJECT_VERBS`te;
  ↳ `summer_leave` `CONSEQUENCE_VERBS`te ve lint `other`ın bir çalışan yuvası olmasını ister
- Satış ve hesap fiilleri: `account_notice {scope, reason, mail}` (`B2BSalesSystem.give_notice`; sebebi postalı bildirim `B2BConstants.EXIT_NOTICE_MAILS`ta olmalı, `mail: false` kartın kendisi bildirimse),
  ↳ `prospect_offer {scope, discount_pct, discount_weeks, promise_step, promise_weeks}` (`ProspectRegistry.set_offer`, yeni teklif eskisinin yerine geçer; lint: `discount_pct` > 0 ile `discount_weeks` >= 1 birlikte;
  ↳ `promise_step` kart verisinde temel kimlikle yazılır, fiil `SprintCatalog.in_product` ile ürünün kimliğine çevirir), `drop_prospect {scope}` (`SalesFinalizer.lose`, sebep `event`), `take_account {scope}` (`assign_customer("", true)`),
  ↳ `pitch_focus {area, weeks}` (`SalesMeetingSystem.set_pitch_focus`; terim yalnız o alanı bekleyen ve ürünün karşıladığı masada, `sales.pitch_focus`). `account_notice`, `prospect_offer`,
  ↳ `drop_prospect` EKONOMİK listede (işaretsiz tutar = bedel, `on_expire`da yasal). `promise_extend` / `promise_break` `scope`lu yazılırsa o hesabın sözlerine iner (oldest-first;
  ↳ uzatmada en eskisine) ve SYSTEM kartı gerektirmez (lint V2 `SCOPED_VERBS`)
- Altyapı fiilleri: `server_price {mult, tiers?}` (`InfraSystem.scale_price`; çarpan birim fiyata biner, `tiers` yoksa her kademeye, varsa yalnız adlı kademelere;
  ↳ EKONOMİK listede, `mult` > 1 bedel, `on_expire`da yalnız zam yasal; çipi ve satırı `EvEffects.server_price_plan`ın `{before, after}` faturasıyla yazar; lint: `mult` > 0,
  ↳ `tiers` yalnız `["cloud", "enterprise"]` ve `mult` < 1, çünkü çip o ikiliyi ve ucuzlamayı yazar), `server_lock {weeks}` (`InfraSystem.lock`: `weeks` hafta kademe sabit,
  ↳ kapasite bugünkü birimin altına inmez; NÖTR, çip bedel; satır imzadaki kapasiteyi koşucu pazarının koltuğu ya da kullanıcısı olarak tutar). Sözleşme kuralı
  ↳ `InfraSystem.set_provider` / `set_capacity`dedir, olay yalnız imzalar
- Sprint fiilleri: `assign_to {card: "decision" | "promise", scope, weeks | weeks_seam}` (`SprintSystem.pin_card`: kişi `weeks` hafta yalnız o karta gider, kişi başına tek kilit; `decision` bekleyen kararın kartı,
  ↳ `promise` `customer` yuvasının en eski açık sözünün kademesini yapan ilk sprint kartı (`SprintBridges.promise_cards`); `weeks_seam` GLOBAL INT seam; çip ve satır `EvEffects.pin_plan`ın
  ↳ `{employee, weeks, card, of}` planıdır, kart bulunamazsa çip çizilmez ve satır reddedilir, bu yüzden fiil `SILENT_VERBS`te), `queue_card {area | line, scope?}` (sonraki sprinte kart: `scope`suz
  ↳ alanın ya da hattın adaylarından kimsenin planlamadığı ve kapısı açık ilk `feat:` kartı `SprintSystem.send_next`le; `scope`lu hesabın o hat için yeni talebi `SprintBridges.open_request`le açılıp kartı gider, hesabın
  ↳ ya da kademenin açık talebi varsa reddedilir; çip `EvEffects.queue_plan`dan, `CONSEQUENCE_VERBS`te ve `SILENT_VERBS`te), `after_test {card: "decision", effects}` (bekleyen kararın kartının testi bitince ve
  ↳ en az bir hata bulduysa `effects` `run_check_branch` köküyle iner ve geçmişe izlemeyi kuran seçimin satırının yanına (deltasında aynı kartın `after_test`i olan son seçim, kâğıt arada yeniden cevaplanmış olabilir) `<sonuç>_tested` satırı yazılır; izleme `EvWatch`ta durur ve her durumda silinir; lint: yalnız tick:request kartında,
  ↳ iç etkiler EKONOMİK ve TERMİNAL olamaz, çip başlığı `EFFECT_AFTER_TEST` iç çiplerin başındadır). Üçü de `WRITER_VERBS`te; `assign_to` `SUBJECT_VERBS`te (employee)
- `trust_delta accounts`: `slots` (+ `slots: [yuva...]`), `others` (kartın müşteri yuvaları dışındaki bütün B2B hesaplar; `line` verilirse o hattı kullananlar), `all`, `onboarding` (`day < onboarding_until`);
  ↳ çip grubu plan satırının `group` alanı (`all` / `other` / `new`)
- Aday ve hesap seam'leri: `aday.sector` (ad alanı `aday` → `prospect` yuvası), `musteri.sector`, `musteri.bugs`, `musteri.onboarding_short`, `musteri.promise_late` (en eski açık sözün kademesi koşan sprintte ve hiçbir kartı yetişmiyor;
  ↳ kartlar `SprintBridges.promise_cards`tan), `musteri.promise_extended`, `musteri.promise_card` (kademenin ad ANAHTARI: geçmiş satırı donar, ekran çevirir), `musteri.has_notice`, `sales.big_accounts`,
  ↳ `time.quarter_start`. Seçiciler `rep_lead` (bir çalışanın işlediği aday) ve `lead_rep` (bağlı adayı işleyen çalışan; kurucunun masasındaki aday kimseyi adlandırmaz). Sprint seçicileri `decision_dev` (bekleyen karar kartının atananlarından ilk geliştirici; kâğıt kart doluyken istenir)
  ↳ ve `quarter_pm` (`SprintCatalog.quarter_pm`); kimse yoksa yuva bağlanmaz. Seam `urun.line_tier.<hat>` (GLOBAL INT; her hat için kayıtlı, paylaşılan hat temel kimliğiyle, `ProductState.line_tier`)
- Kart nakdinin etiketleri `ONE_TIME_LABELS`ta; `equipment`, `gift` ve `award` (pozitif `add_cash`) bu yüzden ekranda sözcük olarak çıkar
- Yuva `"subject": false` (yalnız lint): çalışan yuvası gönderen ya da anılan kişidir, kartın öznesi değildir; O4 o yuvayı özne saymaz

- Fiil sözlüğü ile `_apply` ayrışık: `start_training`, `add_customer`, `convert_audience`, `open_paid_tier`, `change_salary`, `fire_employee` listelerde var ama `_apply` kolu YOK;
  ↳ çağrı `not implemented` döner (`effects.gd:663-665`)
- Bu altı fiil `_vocabulary.md`'de de görünür; `add_customer` yalnız `_fixtures/lint_v3/_bad_v1.json`'da geçer, gerçek kartta kullanımı yok; yeni fiil yazarken sözlükte olması uygulandığını GÖSTERMEZ
- I2/I3: ekonomik fiil yalnız oyuncunun oynadığı seçenekten (`run_played`); `on_expire` yalnız negatif, ambient hiçbiri; `trigger_ending` telegraph ister (`effects.gd:165-208`). Reddedilen fiil `push_error` basar ve smoke'u düşürür
- Ekonomik etkinin kazanç mı maliyet mi olduğu yazarın işaretinden okunur: `EvEffects.is_authored_gain(effect)` `effects.gd:772` (seam'li tutarda `amount_mult`'un işareti, düz tutarda `amount` ya da `delta`; ikisi de yoksa maliyet);
  ↳ lint 17.3 ve süre dolumunun denetimi aynı yardımcıyı sorar, böylece sıfıra yuvarlanan seam değeri maliyeti kazanca çevirmez
- Lint süre dolumunun haber bandı satırını da (`expire_note`: kartın metin bloğundaki bir ad ya da satırın kendisi) marka yasağı ve saat denetiminden geçirir (`EvLint._lint_text` `lint.gd:775`)
- Kayıt: etkin kartın `from_desk` ve `at` değeri kayda yazılmaz (`queue.gd:230-235`); yüklemeden sonra masadan açılmış kart kesinti gibi davranır (`set_aside` false döner). Bkz. `event_no_double_resolution_after_load`
- Kaldırılan kart kayıtta yetim kalır: `SaveManager._REMOVED_CARD` (`save_manager.gd:906`, süzme `:958-967`) `product.bug_pile` için kuyruk, takvim, satır ve masayı temizler;
  ↳ kart silince benzer göç gerekir. `SCHEMA_VERSION` 19 (`save_manager.gd:16`)
- Lint kuralları içerik ayrıntısıdır: marka listesi `FORBIDDEN_TERMS` (`lint.gd:44`), tire yasağı `DASH_CHARS` (`:55`), günlük kartta saat yasağı (`_clock_re` `:66`),
  ↳ yüklenmeyen seam/fiil hatası (`17.x`). Kabul edilen bulgu gerekçesiyle taban dosyasına gider
- Aynı sabit iki yerde: `plausibility.gd` (`FAMILY_GAP_WEEKS`, `START_IMMUNITY_WEEKS`, satır 52-54) `EvTuning` değerlerinin kopyasıdır (KALITE.md de işaretler); `EvTuning` ayarlanınca defter bayat yargılar.
  ↳ `team_summer_leave: 52` iki yerde de yazılıdır
- `catalog.gd:18` yorumu ("Fixtures reachable by --event-shot") yanlış: `_` önekli dosyalar katalogda yoktur, `--event-shot` onlara ulaşamaz. Sürekli koşan `plausibility_main.gd` `-s` girişidir, `--import` istemez
- Kart sayısı (146) `_vocabulary.md`, lint çıktısı ve `find` ile tutuyor; kategori sahipleri: customer Satış, funding Fonlama, product Ürün, team ve founder Ekip, rival Dünya, world Sonlar (pazar harcaması kartları Satış)
- Smoke vakaları `EvSeams.mock`, `EvTuning` ve statik Ev* durumlarına dokunur; paylaşılan kayıt yuvasına yazan vakalar paralel koşmaz (CLAUDE.md); `run_case` her vakada build kapsamını demo'ya sabitler

## Bir değişiklik yaparken
- Yeni seçici: `EvScope._select*` kolu + `EvScope.SELECTORS` listesi (lint 17.12 buradan okur); tohumlu çekiliş `_first_free(ids, used, roll)`'dur
- Yeni seam: ilgili `seams/seams_*.gd` dosyasına `EvSeams.register(ad, kind, type, fn, owner, note)`; ad tek yerde tanımlı olmalı (çift kayıt hata). Sonra `--event-vocab` koş, `_vocabulary.md` değişir,
  ↳ `--event-lint` ile kartları denetle
- Yeni etki fiili: `NEUTRAL_VERBS`/`ECONOMIC_VERBS` listesi + `_apply` kolu (`effects.gd`) + çip (`EvChips.describe`) ya da `EvChips.SILENT_VERBS` + `EvLint.WRITER_VERBS` ya da `SYSTEM_VERBS`; sonra `--event-vocab`,
  ↳ `event_chip_coverage`
- Yeni sinyal tetikli kart: sinyali `event_bus.gd`'ye ekle, `EvSignals.BINDINGS`'e satır yaz (slot-argüman eşlemesi), kartta `tick: signal` + `trigger.signal`; sonra `python tools/gen_signal_manifest.py` ve `--event-lint`
- Yeni kart ya da metin: `data/events/cards/<kategori>/`, `text.tr` ve `text.en` aynı seçenek id'leriyle; CSV anahtarı kullanılırsa `localization/strings.csv`'ye iki dilde (bayt-span splice, bkz. hafıza); `--event-lint`,
  ↳ `card_body_tokens_resolve`, `--event-shot`
- Kart silmek ya da yeniden adlandırmak: kayıtlı kuyruk, takvim, satır ve masa temizliği için `save_manager.gd` göçü ekle (`_REMOVED_CARD` örüntüsü); `unwired/` yalnız yüklemeyi durdurur, kayıttaki kimliği temizlemez
- Yeni sürüm kapsamı ya da yapı: `EndingsSystem.SHIPPED_SCOPES_BY_BUILD` (`endings_system.gd:366`); `EvTuning.SHIPPED_SCOPES` onu izler; `version_scope` değeri değişen kartın lint tabanı ve demo kapısı etkilenir
- Tempo sabitlerini (`tuning.gd`) değiştirirsen `plausibility.gd` kopyalarını, `tools/plausibility_run.sh` ve `EvHarness` çıktılarını (§13.7 çıpası) birlikte kontrol et
- Sunum alanı (başlık, çip, gönderen) değişirse `present/presenter.gd`, `present/chips.gd`, `mail_pane.gd`, `inbox.gd` ve `office_notice_stack.gd` birlikte okunur; geçmiş satırı çipi `EvChips.describe(...,
  ↳ true)` ile canlı çip aynı olmalı (`event_history_chip_matches_live`)
- Kayıt bloğuna yeni depo eklersen `EvSave.to_dict/from_dict/reset` üçünü birden yaz, `BLOCK_VERSION`'ı göz önünde tut ve `verify_no_resources` skaler kuralına uy
