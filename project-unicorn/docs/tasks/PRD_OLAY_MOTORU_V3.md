# PRD · Olay Motoru v3 · makul ateşlenme

**Kim çalıştırır:** C'nin (Açılış) geliştirici oturumu, ikinci parçası olarak, sahibin makinesinde, `PRD_ACILIS.md` bütün
commit'leri (C1-C15, H) `main`'e indikten SONRA (V0; hüküm E7). Yazar v2 bu PRD'yi ayrı cihazda yalnız OKUR (§0a).
Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_OLAY_MOTORU_V3.md dosyasını oku ve uygula."
**Durum:** yardımcı yönetmen taslağı, 2026-10-10. Sahibin bugünkü olay kuralları bağlayıcı; OWNER_RULES madde 6'daki beş
çalışma varsayımı **onay bekliyor** (§0). Kod okuması HEAD `87530c0`; `scripts/events/**`, `data/events/**` ve motor GDD'si
araştırma tabanı `ac7306a`'dan beri değişmedi (`git diff --stat ac7306a HEAD -- scripts/events data/events` boş).
**Tek cümle:** her kart hangi evrede, hangi kadroda, hangi kıdemde ve hangi ürün durumunda yaşadığını zorunlu bir makullük
bloğunda taşır; motor eşik geçildiği hafta değil, belirlenimci bir pencere içinde ateşler, aynı aileyi arka arkaya
getirmez, ilk üç haftayı korur; lint, şıkların gerçek hamle olduğunu mekanik olarak denetler.
**Çıktı:** §7'deki commit dizisi; 87 kartın şema v3 göçü (§5); makullük smoke'u 40 koşu × 16 hafta + 4 koşu × 60 hafta
(önce ve sonra çıktısı); motor GDD'si §3.1, §13, §14, §17, §25, §27.19-27.24; yeniden üretilmiş `_vocabulary.md`; ✅/⚠️/❌.

**Kanıt kaynakları repo DIŞINDA** (`research/events/*`, `tasks/OWNER_RULES_EVENTS_2026-10-10.md`, `drv-*/run.log`):
`C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-project-steam/faa4f53a-2d29-41ac-9ee2-7655fe932cd7/scratchpad/`.
Temp silinmişse PRD yeter (yeniden üretilecek desenler metinde). Ayrıca yazar pilotu (`Desktop/unicorn_writer_pilot/`) ve
2026-10-08 şık kuralları; `docs/writing/OLAY_YAZIM_YONTEMI.md` yok. Hükümler E1-E7: `tasks/RULINGS_2026-10-10.md`.

---

## 0. Sahip kararları ve bulgu → gereksinim
**Bağlayıcı (OWNER_RULES 1-5, 7; 8 için §0a):** evre ve kadro ayrımı zorunlu; aynı olay her işe alımda gelmez ("yanına
oturup ben gösteriyorum" kartı emekli, ailesi özne başına bir kez); şık gerçek hamle, bedel özneye, bedava çıkış yok, tek
kişilik olayda sprint saati yok (istisnasız), şık oyunun dünyasıyla çelişmez; yazar yalnız uygulayıcısı ve çipi olan fiili
kullanır, lint zorlar; demo penceresi 0-130. hafta.

**Çalışma varsayımları (OWNER_RULES 6; hepsi onay bekliyor, ajan uygular, raporda ⚠️ işaretler):**

| # | Varsayım | Bu PRD'de | Sahip "hayır" derse |
|---|---|---|---|
| K1 | Deterministik gecikme penceresi evet (GDD §25 "MTTH Red" gevşer) | R6, §27.19 | `delay_weeks` alanı kalır, hepsi `[0,0]`; eşikler büyür |
| K2 | Pazarlama şıkları demoda `requires` ile kilitli; dünya teklifleri kitle/nakit tabanıyla kalır | R2, F4-F7, O5 (hüküm E5: iki eski şık W kalır, yazar v2 yeniden yazar) | (b) seçilirse iki `requires` düşer; (c) hüküm E5 ile zaten yazar v2'de |
| K3 | "Çalışan para istiyor" kıdem tabanı 26 hafta | R1, F3, `outside_offer` | taban tek sabitten (`EvTuning.FAMILY_SUBJECT_TENURE`) değişir |
| K4 | Global başlangıç koruması 3 hafta; sistem ve `tutorial` kartları hariç (sessiz taban muafiyeti onaylı: hüküm E4) | R3 | `START_IMMUNITY_WEEKS = 0` |
| K5 | Makullük bloğu lint'te hata (E) | R9 (V6 adımı E'ye çevirir) | V6 atlanır, P2 W kalır |

**Bulgu → gereksinim:**

| Bulgu (kanıt) | Gereksinim |
|---|---|
| Eşik ateşlenme tarihi gibi çalışıyor: `conference_trip` 2/2 koşuda tam tenure=12'de (`audit.md` TL;DR 1); havuz düz ağırlık, "hiçbir şey" sonucu yok (`engine.gd:278-308`, `catalog.gd:109`) | R4, R6 |
| Hiçbir seam modül kilidini okumuyor (`ui_tokens.gd:300` `"lock":"ea"`, `left_tabs.gd:237-238`); `GameState.run_hires` var ama seam'i yok (`game_state.gd:194`) | R2 |
| Başlangıç koruması yok, yedi kart elle `time.week >= N` yazıyor (`ours.md` §7); aile freni yok, yalnız `min_gap` ve 2/4 haftalık özne aralığı (`tempo.gd:111-140`) | R3, R5 |
| `critical` 26 kartta, aralarında hikâye kartları (`cs_escalation`, `analyst_guide`, `newsletter_slot`) frenleri atlıyor (`tempo.gd:100-102`) | R7 |
| `customer_added` bağlı değil (`signals.gd:22-38`); modül açılışının sinyali yok (`event_bus.gd`'de `module_unlocked` yok) | R8 |
| Lint yalnız fiilin listede olmasını soruyor (`lint.gd:220-223`); 63 listeli fiilden 15'i kolsuz ya da çipsiz (§4) | R9 |
| Doğrulanmış 9 saçma ateşlenme (`EVENT_TIMING_ONERI.md` §3); `team.first_weeks` her işe alımda, kurucuyu eğitmen yapan şıkla (`strings.csv:2936-2940`) | R11, R12 |
| `--event-harness=random` çıplak koşu: 10×12'de tek kart (`audit.md` TL;DR 6); `--why-fire` yalnız açılışı görüyor | R13, R14 |

### 0a. Brief'ten ve araştırmadan farklar
| İfade | Bugünkü gerçek (kanıt) | Bu PRD'de |
|---|---|---|
| OR8: iki PRD tek yazar oturumuna; entegrasyon "burada, ayrı turda" | Bu PRD repoya kod yazar; yazar oturumu repo dışına yazar | Hüküm E7: bu PRD C oturumunun ikinci parçası (PRD_ACILIS bitince). Yazar v2 ayrı cihazda, repo salt okunur, klonu bu PRD'yi içeren push; yalnız §2, §4, §5 (yeniden yazım listesi dahil), §8'i OKUR. Entegrasyon turu burada, motor (V8) indikten sonra |
| `build.module_unlocked(<id>)` parametreli seam | Kayıt yalnız `GLOBAL` (argsız) ve `ENTITY` tanır (`seams.gd:17-20,31-36`) | Modül başına GLOBAL bool `build.module_unlocked.<id>` (R2) |
| "Sözlükteki 60 fiilden 49'u kollu" (OR5) | HEAD'de 63 fiil (`effects.gd:32,69`); `_apply` 54 kol (`effects.gd:217-556`), ikisi uygulamaz (`add_mrr` :230-235, `open_negotiation` :491); 4'ü çipsiz (`chips.gd:20-45`) | Yazılabilir küme 48 (§4); yazar kümesi 30 |
| retention'a tenure koşulu (öneri 2'nin ilk yolu) | Kart `customer_health_changed` sinyaliyle bir kez önerilir; reddedilirse yeni sinyal yok | Onboarding sesi (R12); koşul değişmez (F2); sinyal reddi ertelenir (R5) |
| G4 başlığı "phase window" der (`gate.gd:17`) | G4'te faz kodu yok (`gate.gd:167-201`) | Başlık R3'le düzelir; faz bandı G7'ye derlenir (R1) |
| `trigger.condition` "ne zaman aday olur" (GDD §3.1) | Motor yalnız `trigger.signal` okur; `trigger.condition` değerlendirilmez (`catalog.gd:127-129`) | Şema v3'te kullanılmaz; lint W (P3, §27.24) |
| Sinyal kartına gecikme | `EvSchedule.add` girdisi `{event_id, fire_on_day, context, arc_id}` (`schedule.gd:24-33`); SCHEDULE G4'te `tick: scheduled|daily` ister (`gate.gd:182-184`) | Yeni köken `SCHEDULE_DELAYED` (R6) |
| Fikstürler "`_` önekli, havuz dışı" | `_fixtures/` dizini taranır; `_` öneki DOSYA adına uygulanır ve dosyayı hiç yüklemez (`catalog.gd:17-19`); 8 fikstürü `version_scope: fixture` G2'de tutar (`_fixtures/README.md`); lint her kartı denetler (`lint.gd:78-79`) | Fikstür muafiyeti ve `_bad_*` yolu R9'da |

## 1. Kurallar
- `CLAUDE.md` bağlayıcı: §3 (doğrudan `main`, tasarım sabiti "onay bekliyor", TR metni "TR/EN onay bekliyor"), §5 (önce EN,
  tire yok, `static func` içinde `tr()` yok), §8-§9 (kısa kod; her commit öncesi diff ayrı ajanca incelenir), §10, §12.
- **Sıra kesin: A (SAAT) → B (SPRİNT) → C (AÇILIŞ) → bu PRD.** C `data/events/cards/**`, `scripts/events/core/*` (tek
  seçenek yolu, `latches.gd`, `engine.gd` `pump`), `scripts/events/present/*`, `inbox.gd`, `mail_pane.gd`, onboarding'in
  sahibidir; bu PRD C bittikten sonra, C'nin oturumunda koşar (§6, hüküm E7).
- **Ağaç paylaşımlı.** `git status --short` ile başla. Başkasının hunk'ına dokunma; kirli dosyada yalnız kendi hunk'larını
  `git apply --cached` ile stage et, commit ağacını `git checkout-index` ile geçici dizine kurup kapıları orada koş.
  `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak. Satır numaraları `87530c0`'ındır; A/B/C sonrası kayar,
  hunk'ı işlev adıyla (`_step_pool`, `_weighted_pick`, `_step_floor`, `_step_signal_drain`, `_propose`, `_g4_window`,
  `pool_blocked_reason`, `_normalise_card`, `_lint_card`, `pick_request_kind`, `risk_voice`) yeniden bul.
- **Alt ajanlar Opus ya da Sonnet** (`model: "sonnet"` varsayılan); yalnız parse kontrolü ve hedefli vaka; tam smoke
  yalnız entegrasyonda bir kez. **OS düzeyinde fare/klavye girdisi yok**; ekransız koşu `--headless`, shot'lar pencereli ve
  sırayla, her koşu kendi `APPDATA`'sında; önce `tasklist | grep -i godot`, yalnız kendi süreçlerini kapat.
- `export GODOT=/c/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`; komutlar `project-unicorn/`'dan. Yeni
  `class_name` (`EvDelays`) eklenince sıra: `--import` → bir ısınma koşusu → kapılar. **Push yok**; yalnız sahip "push et"
  derse ve o zaman doğrudan (tam smoke ön koşulu yok).
- Smoke koşucusu yalnız ilk argümanı koşar (`tools/smoke_run.sh:80`): `for c in <vakalar>; do bash tools/smoke_run.sh "$c" ||
  exit 1; done`; çıktı ayrıca `Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR` ile kapılanır. `strings.csv`:
  yalnız bu PRD'nin anahtarları, bayt-span ekleme (dosya yeniden yazılmaz).

## 2. Kart şeması v3
Mantık bloğuna eklenen alanlar (GDD §3.1'e işlenir). Motor alanları yüklemede derler; yazar yalnız JSON yazar.

| Alan | Tür | Zorunlu | Anlam ve derleme |
|---|---|---|---|
| `schema` | `3` | evet | Göç işareti; yoksa lint P2 (V2-V5 W, V6'dan sonra E) |
| `system` | bool | hayır (`false`) | Kartın zamanını bir oyun sistemi verir (kapı, Frank, seed, sheet, kepenk, istifa, sistem istekleri). Yalnız `system` ya da `terminal_warning` kart `critical` taşıyabilir ve ayrılmış fiil kullanabilir (§4) |
| `plausibility.phase_band` | liste ⊂ {`bootstrap_solo`, `bootstrap_team`, `traction`, `series_a`} | evet, boş olamaz | `bootstrap_solo` = `phase.current==1 ∧ hr.headcount==0`; `bootstrap_team` = `phase.current==1 ∧ hr.headcount>=1`; `traction` = `phase.current==2`; `series_a` = `phase.current==3`. Koşul ağacına `any` olarak eklenir |
| `plausibility.headcount` | `[min, max]` (`max` `null` = sınırsız) | evet | `hr.headcount` aralığı (kurucu ve mentor hariç, `seams_hr.gd:124-126`). "1-2 çalışan" = `bootstrap_team` + `[1,2]` |
| `plausibility.subject_tenure_weeks` | int ≥ 0 | `system` olmayan kartta `select`li her employee/customer slotu varsa evet | Slot `where`'ine `hr.tenure_weeks >=` / `musteri.tenure_weeks >=` (aile tabanıyla `maxi`, R1); seçici yalnız kıdemli adaydan seçer. Slot başına: `subject_tenure_by_slot: {rep: 4}`. `system` kartta ve `select`siz verilen slotta istenmez, DERLENMEZ (§5 "—"): verilen özne G5'te reddedilirse istek kaybolur (`hr_morale_system.gd:327-329` istifa isteği yeniden denenmez) |
| `plausibility.fresh_reason` | string | `subject_tenure_weeks == 0` ise evet | Neden taze özne makul (ör. retention'ın onboarding sesi) |
| `plausibility.product` | `pre_launch` \| `live` \| `any` | evet | `urun.is_live` yaprağı; `guards.product_live` varsa aynı değeri söylemeli (lint E) |
| `plausibility.modules` | liste (`UiTokens.TABS` id'leri) | evet (boş olabilir) | Her biri `build.module_unlocked.<id> == true` yaprağı |
| `plausibility.min_week` | int ≥ 0 | evet | `time.week >= N`; > 130 ise lint W (demo penceresi dışı) |
| `family` | string | evet | Aile kimliği (§5); aile freni (R5) |
| `family_subject` | `{"once": true}` \| `{"cooldown_weeks": N}` | hayır | Aynı aileden bir kart aynı özne için bir kez / N haftada bir |
| `follows` | kart id | hayır | Zincir düğümü: ebeveyn ya kartı `schedule_event` ile zamanlar ya da kartın koşulu ebeveynin `history`/flag yaprağını okur; aile aralığından muaf |
| `delay_weeks` | `[N, M]`, 0 ≤ N ≤ M ≤ 26 | `system` değilse evet | Koşul ilk tuttuğu hafta kurulur, `N..M` hafta sonra aday (R6). Sessiz taban kartı (`tags: quiet`) `[0,0]` + `delay_reason: "floor"` |
| `delay_reason` | string | `delay_weeks == [0,0]` ise evet | Neden anında (sinyal tepkisi, sprint haftası, dar pencere, zincir, taban) |
| `delay_mult` | `[{<koşul yaprağı>, "factor": f}]` | hayır | Kurulum anında tutan her yaprak gecikmeyi `f` ile çarpar (ör. moral < 40 → 0,5) |
| `weight` | float | hayır (1,0) | Değişmez; `funding.portfolio_vendor_trial` 3,0 |
| seçenek `status_quo_reason` | string | etkisiz seçenekte evet | "Hiçbir şey değiştirme" seçeneğinin neden gerçek hamle olduğu (O1) |
| `version_scope` | + `retired` | | Hiçbir build'de gönderilmez (G2), katalogda kalır: eski kayıtların geçmiş satırı ve mandalı çözülür (GDD §22.1) |

Derlenen yapraklar `"_from": "plausibility"` taşır; `--why-fire` ve lint onları yazılmış yapraklardan ayırır.

## 3. Gereksinimler
### R1 · Şema v3 derleyicisi (`scripts/events/catalog/catalog.gd`, `tuning.gd`)
- **Ne:** `_normalise_card` (101-114) `plausibility`'yi §2'deki yapraklara derler: `condition` `{"all": [<yazılmış ağaç>,
  <makullük yaprakları>]}` olur; kıdem yaprakları slot `where`'ine `all` ile eklenir ve
  `maxi(card.subject_tenure_weeks, EvTuning.FAMILY_SUBJECT_TENURE.get(family, 0))` yazar
  (`FAMILY_SUBJECT_TENURE = {"employee_asks_money": 26}`, K3'ün tek sabiti). Derleme `_coerce_conditions`'dan (123-147) ÖNCE
  koşar ki derlenen değerler de tiplensin. `schema` yoksa kart bugünkü gibi yüklenir (V2-V5 geçişi).
- **Kabul:** smoke `event_plausibility_compiles` (yeni; `_fixtures/v3_compile.json`, normal adlı, `version_scope: fixture`;
  vaka `SHIPPED_SCOPES`'u README'deki üç vaka gibi genişletip aynı fonksiyonda geri alır): beş yaprak türü `_from` ile var;
  `bootstrap_team` kartı `phase=1, headcount=0`'da G7'de ret, `headcount=1`'de geçer; `tenure 3` aday seçilmez, `tenure 5`
  seçilir; aile `employee_asks_money` fikstüründe kart 4 yazsa da yaprak 26.

### R2 · Yeni seam'ler
- **Ne:**
  - `build.module_unlocked.<id>` (GLOBAL, TYPE_BOOL, `seams_world.gd`), `UiTokens.TABS`'taki her `id` için, `rnd` dahil
    (`ui_tokens.gd:293-303`; `rnd` kilitsiz, hep true; Ar-Ge ağacının açıklığını yazar `arge.tree_open`'dan okur). Değer
    yeni `scripts/systems/module_locks.gd`'den (`class_name` YOK, `preload`): `static func is_open(id) -> bool`,
    `LeftTabs._is_locked` kuralının (`left_tabs.gd:237-238`) ve C'nin R9 `live` kapısının tek evi; yalnız smoke için
    `static var _override := {}`, `set_override(id, open)`, `clear_overrides()` (`is_open` önce `_override`'a bakar).
    `LeftTabs._is_locked` tek satırla ona devreder (C14'ten sonra ayrı hunk).
  - `hr.weeks_since_last_hire` (GLOBAL, TYPE_INT, `seams_hr.gd` `_install_company`): etkin çalışanların en küçük
    `hr.tenure_weeks`'i, yoksa −1 (kadrodan türetilir). `hr.run_hires` (GLOBAL, TYPE_INT): `GameState.run_hires`.
- **Kabul:** smoke `event_v3_seams` (yeni): demo build'de `marketing == false`, `product == true`, `rnd == true`;
  `set_override("marketing", true)` → true, `clear_overrides()` → false; çalışan yokken `hr.weeks_since_last_hire == -1`,
  işe alımdan sonra 0, bir tik sonra 1; `hr.run_hires` +1. `--event-probe` `- seams` bölümü yeşil (`engine_probe.gd:60-66`).
  `--event-vocab` farkı yalnız yeni seam satırları ve sayım tablosunun `Seams (read)`/`Cards in the catalogue` satırları
  (`vocab_gen.gd:41-43`).

### R3 · Başlangıç koruması (`scripts/events/gate/gate.gd`)
- **Ne:** `_g4_window` (167-201) başına: `GameState.day <= EvTuning.START_IMMUNITY_WEEKS` (3) ve kart `system` değil,
  `tags` `tutorial` taşımıyor (`gate.gd:161`'in etiketi; `guided` kart etiketi değil, harness kipidir), `terminal_warning`
  değil ise ret `"start immunity: week %d"`. Muaf kökenler: FORCE, REQUEST (isteyen sistem zamanı biliyor), ARC_STEP, FLOOR
  (hüküm E4, onaylı: koruma sessiz taban notunu kapsamaz, 1-3. haftada görünebilir; aksi hâlde `_floor_empty_streak` 3'e
  varır: `tuning.gd:69`, `endgame_smoke.gd:17231`). SIGNAL/SCHEDULE reddi kaybolmaz, R5'in ertelemesine gider. `gate.gd:17`
  başlığı "tick, allowed_hours" olur. `time.week` 1'den başlar (`seams_world.gd:48-50`): 1-3. haftalar korunur.
- **Geçiş kolu (V3-V6):** `system` V4'e dek hiçbir kartta yok; alanı OLMAYAN kartta `EvTempo.budget_exempt(card)` de muaf.
- **Kabul:** smoke `event_start_immunity` (yeni): hikâye fikstürü gün 1-3 G4 "start immunity", gün 4 kabul; `system`, FLOOR
  ve `system`'siz `critical` fikstürü gün 1 kabul. Vakalar gün 1'de başlar (`endgame_smoke.gd:49-58`): V3'te gün ≤3'te
  öneri yapan mevcut vakalar tek tek koşulur, en az `scope_given_subject_gone_refused` (`:5619`, G5 bekler; G4 önce koşar,
  `gate.gd:100-104`), `quiet_cards_fill_empty_floor`, `angel_*`, `gate1_*`; kırılan vaka `day = 4` ile kurulur, rapora.

### R4 · "Bu hafta hiçbir şey" ağırlığı (`engine.gd` `_weighted_pick`, 296-308)
- **Ne:** imza `_weighted_pick(candidates, nothing_weight := 0.0)`; ağırlık çekiliş toplamına sanal aday olarak eklenir,
  zar ona düşerse boş döner. Yalnız `_step_pool("daily")` `EvTuning.POOL_NOTHING_WEIGHT[GameState.phase]` geçirir (onay
  bekliyor: 1 → 1,5 · 2 → 1,0 · 3 → 0,6); `_step_floor` (`engine.gd:347`) ve saatlik havuz 0. Zar aynı: `EvDice.unit("pool",
  day)`. **"Hiçbir şey" tikinde taban atlanmaz (hüküm E1):** `_step_floor` aynı tikte yine koşar, masa boşsa sessiz kart
  doldurur (`FLOOR_QUIET_WEEKS = 1`, `tuning.gd:65`); "hiçbir şey" yalnız havuzun hikâye kartını keser.
- **Kabul:** smoke `event_pool_nothing_weight` (yeni): `GameState.day` 1..200 için
  `EvEngine._weighted_pick([{card:{weight:1.0}}], 1.0)` doğrudan çağrılır (mandal ve `min_gap` devrede değil); boş dönüş
  oranı 0,40-0,60; iki koşu bayt bayt aynı. R13 `PLAUS RATE` faz başına `pool_weeks`, `nothing=`, `empty=` (o hafta hiç
  kabul yok: oyuncunun gördüğü boş hafta) basar.

### R5 · Aile ve özne başına frenler (`scripts/events/present/tempo.gd`, `engine.gd`)
- **Ne:** `pool_blocked_reason` (111-140) Katman 1'den önce:
  - **1b aile aralığı:** aynı `family`'den BAŞKA bir kart son `EvTuning.family_gap(family)` hafta içinde ateşlendiyse ret
    (kartın kendi aralığı `latch.cooldown_weeks`'te kalır). Varsayılan 6, tablo §8. `follows` muaf.
  - **2b aile × özne:** `family_subject.once` ise aynı özne için aileden ikinci kart yok; `cooldown_weeks` ise o kadar ara.
  - Kayıt `_record`'un yanına `{family: day}`, `{family|subject: day}`; `to_dict`/`from_dict` (225+), eski kayıtta boş.
  - **Köken kuralı:** `_propose` (`engine.gd:372`) `EvTempo.family_blocked_reason(card, subject)`'i yalnız SIGNAL, SCHEDULE,
    SCHEDULE_DELAYED için sorar; `_step_floor` (333-348, `_propose` kullanmaz) aday döngüsünde `verdict.admitted and
    family_blocked_reason(...) == ""` ister; ARC_STEP (`engine.gd:171,178,241`) muaf; REQUEST ve FORCE `EvGate.propose`'u
    doğrudan çağırır (`engine.gd:564,583`), muaf (reddedilen istek her hafta yeniden açılır).
  - **Erteleme:** SIGNAL/SCHEDULE/SCHEDULE_DELAYED önerisi 1b, 2b ya da R3 korumasıyla reddedilirse düşmez:
    `EvSchedule.add(id, kalan_hafta, payload, "", true)` ile freninin bittiği güne kurulur. Sinyal bir kez önerilir
    (`engine.gd:251-257`); düşürmek §0a'nın retention kaybını yeniden üretir (`customer_risk` aralığı 2: A'nın kartından
    bir hafta sonra riske giren B kartsız gider; `b2c_floor_signal` → `b2c_floor_churn` aynı).
- **Kabul:** smoke `event_family_gap` (yeni): aynı aileden iki fikstür; ilki gün 10, ikincisi 10+aralık−1'de "layer 1b",
  10+aralık'ta kabul; kartın kendisi 1b'ye takılmaz; `follows` fikstürü aynı gün kabul; `once` ailede aynı çalışana ikinci
  kart ret, başkasına kabul; 1b'nin reddettiği sinyal fikstürü aralık bittiği gün `SCHEDULE_DELAYED` ile kabul; kayıt
  gidiş-dönüşünden sonra aynı ret. R13'te kural 5 ve 8.

### R6 · Gecikme penceresi (yeni `scripts/events/core/delays.gd`, `class_name EvDelays`; `schedule.gd`, `gate.gd`)
- **Ne:**
  - `_step_pool` (278-294): kapıyı ve frenleri geçen aday için anahtar (`EvLatches.key_of`) kurulu değilse kurulur:
    `d0 = day`, `D = N + floor(EvDice.unit("delay", d0, event_id, subject_id) × (M−N+1))`, kurulumda tutan `delay_mult`
    yaprakları çarpar, `round`, `[N, M]` dışına taşmaz. `day < d0 + D` ise aday değil. `[0,0]` bugünkü davranış.
  - Koşul art arda `EvTuning.DISARM_WEEKS` (4) hafta tutmazsa anahtar sökülür; vade dolmuş ama koşul o hafta tutmuyorsa
    tuttuğu ilk hafta aday olur (sprint haftası gibi gidip gelen koşullar pencereyi kaybetmez).
  - **Tesisat:** `EvSchedule.add(event_id, delay_weeks, context = {}, arc_id = "", delayed := false)`, girdi `delayed` taşır
    (eski kayıtta yoksa false). `_step_signal_drain` (251-257) `delay_weeks` M > 0 olan sinyal kartını önermez, aynı `D`
    ile `delayed: true` girdi kurar. `_step_schedule` (214-217) `delayed` girdiyi yeni `EvGate.Origin.SCHEDULE_DELAYED`
    ile önerir; `_g4_window` kolu: `Origin.SCHEDULE_DELAYED: if tick != "signal" and tick != "scheduled" and tick !=
    "daily": return ...`; R3 ve R5'te SCHEDULE gibidir. `EvDelays.to_dict/from_dict` `EvSave` listesinde, eski kayıtta boş.
- **Kabul:** smoke `event_delay_window` (yeni): `[2,5]` fikstürü `d0`'da kurulur, `d0+D`'de kabul, `D` formülle eşit; aynı
  tohum aynı `D`; vade öncesi `to_dict → reset → from_dict` sonra aynı vade; 4 hafta tutmayan koşulda söküm; sinyal fikstürü
  `D` hafta sonra `SCHEDULE_DELAYED` ile kabul; `delayed`siz eski girdi false. `hr.tenure_weeks` mock'uyla
  `conference_trip` biçimli fikstür kıdem 26'da kurulur, ≥ 28'de kabul. `PLAUS LONG`'da `conference_trip` FIRE'ı kıdem ≥ 28.

### R7 · `critical` yalnız sistem ve terminal kartlarında
- **Ne:** lint E (C1). Göçte `customer.cs_escalation`, `world.analyst_guide`, `world.newsletter_slot` `critical`'i bırakır;
  kalan 23 `critical` kartın hepsi `system` ya da `terminal_warning` (§5). `analyst_guide` ve `newsletter_slot`'un
  `weeks_since funding.gate_series_a <= 2` yaprağı `<= 4` olur (havuz rekabetinde pencere kaçmasın; onay bekliyor).
- **Kabul:** `--event-lint` temiz; `grep -rl '"critical"' data/events/cards --exclude-dir=_fixtures` listesinin her dosyası
  `"system": true` ya da `terminal_warning` taşır, sayı 23 (komut çıktısı rapora).

### R8 · on_action kancaları (`signals.gd`, `engine.gd`, `scripts/autoload/event_bus.gd`)
- **Ne:**
  - `BINDINGS`'e `"customer_added": {"slots": {"customer": 0}}` (`event_bus.gd:97`, tek yayan `customer_registry.gd:102`;
    geri yükleme yaymaz :106). "İlk müşteri" deseni `trigger.signal: customer_added` + `musteri.count == 1` (B2B'de
    `sales.account_count == 1`).
  - **Modül açıldı:** `event_bus.gd`'ye `signal module_unlocked(module_id: String)` (yoksa `_lint_signals` 17.1 E verir,
    `lint.gd:545-553`, `EvSignals.install` bağlamaz, `signals.gd:64-68`). `daily_tick`'e (59-75), sinyal boşaltmadan önce
    `_step_module_watch()`: `ModuleLocks.is_open` görüntüsü dünküyle karşılaştırılır, kapalıdan açığa dönen her id için
    `EventBus.module_unlocked.emit(id)` (normal bağlama yoluyla tamponlanır). Görüntü `EvDelays` bloğunda; boşsa (yeni
    koşu, eski kayıt) ilk tik onu sessizce tohumlar, yaymaz. Modül kimliği GLOBAL TYPE_STRING `build.last_unlocked_module`
    seam'iyle okunur (kart: `latch: one_shot` + `== "marketing"`). Manifest `gen_signal_manifest.py` ile yeniden üretilir.
- **Kabul:** smoke `event_on_action_bindings` (yeni): `_fixtures/first_customer.json` (`fixture`, R1'deki gibi açılır) ilk
  `CustomerRegistry.add`'de kabul, ikincide G7 ret; `ModuleLocks.set_override("marketing", true)` günü `module_unlocked`
  bir kez yayılır, fikstür bir kez önerilir; boş görüntüyle ilk tik yaymaz. Manifestte `module_unlocked` yayanı `engine.gd`.

### R9 · Lint (`scripts/events/tools/lint.gd`, `tools/lint_baseline.json`, `tools/lint_v3_frozen.json`)
Kimlikler (`_fingerprint` = `rule|where|message`, `lint.gd:690-691`; mevcutlar "17.1"…"17.11", 17.12 kapsam slotları):
P1-P3 → `"17.13"`, C1 ve V1-V3 → `"17.14"`, O1-O5 ve T1-T3 → `"17.15"`; mesaj kural adıyla başlar ("O2: ...").
**Muafiyet:** `version_scope` `fixture` ya da `retired` kart P, C1, V2, O, T kurallarından muaftır, yalnız bugünkü §17.1 yapı
kuralları koşar (HEAD fikstürlerinden 5'i `critical`, 3'ü `start_arc`/`end_arc` taşır, hiçbiri `schema` taşımaz).
- **P1 (E):** `schema: 3` kartında §2'nin zorunlu alanları; bilinmeyen `phase_band`; `system` olmayan kartta `select`li
  employee/customer slotu olup `subject_tenure_weeks` yok; 0 ama `fresh_reason` yok; `product` ↔ `guards.product_live`
  çelişkisi; `modules`'ta TABS dışı id; `system` değil ve `delay_weeks` yok; `[0,0]` ama `delay_reason` yok; `follows`
  bilinmeyen id ya da id ne bir `schedule_event`'te ne kartın koşulundaki bir `history` yaprağında; `family` yok.
- **P2 (W → V6'da E):** `schema` alanı olmayan kart. **P3 (W):** `min_week > 130`; `trigger.condition` dolu. **C1 (E):**
  `critical` etiketi `system: true` ya da `terminal_warning` olmadan.
- **V1 (E):** fiil yazılabilir 48'in dışında (§4); "unknown verb" kuralı (`lint.gd:220-223`) yerinde kalır. **V2 (E):**
  ayrılmış 18 fiil `system` olmayan kartta. **V3 (E):** `sprint_card_*` `tick: request` olmayan kartta (`cardcheck.py:626`).
- **O1 (E):** `system` olmayan, iki ya da daha çok seçenekli kartta etkisiz seçenek, `status_quo_reason` yoksa.
- **O2 (E):** seçeneğin hiçbir etkisi bedel taşımıyor (bedava çıkış). Bedel = çip kutbu `cost`/`danger` (`chips.gd`) ya da
  sonuç fiili (`sprint_card_carry`, `fix_run_start`, `b2b_retain_delay`, `b2b_retain_ignore`, `b2b_expand_decline`,
  `promise_create`). `system` ve not kartları (`EvPresenter.is_note`, C'nin R5'i) muaf; etkisiz seçenek O1'indir.
- **O3 (E):** tek kişilik kartta (tek employee slotu ya da `category: founder`) `sprint_hours` ya da negatif `morale_all`;
  istisna YOK (OR4; kadro `[0,0]` dahil).
- **O4 (E):** slotlu kartın HERHANGİ bir seçeneği o slota ya da kartın kaynağına etki düşürmüyor (işarete bakılmaz; employee: `change_morale`,
  `productivity_mod`, `employee_leaves` `scope: <slot>`; customer: `satisfaction_delta`, `customer_mrr_delta`, `seats`,
  `churn_customer`, `promise_create`, `b2b_*`; çok slotlu kartta en az birine; `scope`'suz etki türünün ilk slotuna düşer).
- **O5 (E):** `version_scope: demo` kartta `marketing_push` (OR4: pazarlama demoda yok); EA kartında `requires`'ta
  `build.module_unlocked.marketing == true` yok (`EvLint.MODULE_VERBS = {"marketing_push": "marketing"}`).
- **T1 (E):** `trigger.signal: employee_hired` olup koşu kapsamlı `one_shot` (`latch_key: entity` değil) ya da `hr.run_hires`
  yaprağı yok. **T2 (E):** employee slotlu kartın ailesinde `family_subject.once` yok ve `cooldown_weeks < 26`.
  **T3 (E):** `select: newest_hire` ve `subject_tenure_weeks < 8`.
- **Dondurulmuş liste:** `tools/lint_v3_frozen.json` göç anındaki 56 hikâye kartının id'leri (büyümez); O2, O4, O5, T2, T3
  bu kartlarda W'ye iner, yeni kart hep E (O5 hatası yalnız yeni kartta, hüküm E5). W taşıyan kart yazar v2'nin yeniden
  yazım listesine gider (hüküm E3, §5 sonu): yeniden yazılır, 9/10'u geçemeyen emekli olur; yeniden yazılan kart listeden
  düşer. **Baseline** E almaz; V6'da yalnız listenin W'leri yazılır, her biri Done mesajında ⚠️.
- **Kabul:** kötü fikstürler katalog DIŞINDA: `data/events/cards/_fixtures/lint_v3/_bad_<kural>.json` (`_` önekli, yüklenmez,
  `--event-lint` görmez). Smoke `event_lint_v3_rules` (yeni) her dosyayı `JSON.parse_string` ile okur,
  `EvCatalog._normalise_card`'dan geçirir, `EvLint._lint_card` çağırır, beklenen kural kimliğini doğrular (falsifikasyon
  çıktısı rapora). Göç sonrası `--event-lint` "0 error(s)".

### R10 · Göç: 87 kart şema v3'e (§5)
- **Ne:** her kart §5 satırındaki blokla. Yazılmış koşul korunur; makullük bloğuyla çakışan elle yaprak (`time.week >= N`,
  `phase.current`, `hr.headcount`, `guards.product_live`) SİLİNMEZ (silmek davranış değiştirir; temizlik ayrı tur).
- **Kabul:** lint 0 error; `--event-harness=random:seeds=10:weeks=12` `HARNESS PASS`; `bash tools/run_gate.sh` 3/3; R13 PASS;
  `--why-fire` beş kartta (`team.conference_trip`, `customer.cs_escalation`, `world.b2c_creator_feature`,
  `founder.side_contract`, `rival.price_cut`) `PLAUSIBILITY` bölümü (R14) derlenen yaprakları gösterir.

### R11 · Doğrulanmış dokuz kart ve emeklilik (veri)
| # | Kart | Değişiklik | Kanıt |
|---|---|---|---|
| F1 | `customer.cs_escalation` | `critical` düşer; `subject_tenure_weeks: 4` (müşteri ve `rep` slotu) | `verify-cs_escalation.md`; `drv-b2b/run.log:165` |
| F2 | `customer.retention` | koşul aynı; `fresh_reason` + R12 onboarding sesi; reddi ertelenir (R5) | `verify-customer-retention.md`; `strings.csv:635-638` |
| F3 | `team.conference_trip` | kıdem 12 → 26 (K3); `delay_weeks [2,8]`; aile `employee_asks_money`, `once` | `verify-conference-trip.md` |
| F4 | `funding.portfolio_vendor` | `own_ads` → `requires build.module_unlocked.marketing`, `locked_reasons` `EV_LOCK_MARKETING_EA` | `verify-portfolio_vendor.md` |
| F5 | `rival.shutdown_notice` | `more_marketing` aynı kilit | `verify-rival-shutdown-notice.md`; `strings.csv:3399` |
| F6 | `world.b2c_creator_feature` | `sales.b2c_audience >= 3000`, `finance.cash >= 10000` (onay bekliyor), `min_week 8` | `verify-b2c_creator_feature.md` |
| F7 | `world.app_placement` | dünya teklifi kalır (K2); `sales.b2c_audience >= 2000` (onay bekliyor) | `verify-world-app_placement.md` |
| F8 | `rival.price_cut` | customer slotu `subject_tenure_weeks: 4` (derlenen `where`) | `verify-rival-price_cut.md`; `scope.gd:75-84` |
| F9 | `customer.request_renewal` | kart değişmez; sistem tabanı R12 | `verify-request-renewal.md` |
| E1 | `team.first_weeks` | `version_scope: retired`; aile `new_hire_onboarding` emekli, yeni üye yok | `first_weeks.json:1-40`; `strings.csv:2936-2940` |
- **Emekli kartın izleri:** `endgame_smoke.gd:16548` ve `main.gd:2236` id'yi ve `EV_TEAM_FIRST_WEEKS_TITLE`'ı yalnız verim
  satırı başlığı olarak kullanır; CSV anahtarları silinmez, iki çağıran değişmez.
- **O3 düzeltmeleri:** `founder.side_contract` (`take`, `half`), `founder.meetup_talk` (`talk`): `sprint_hours` →
  `productivity_mod scope: founder` (kart `founder` slotu kazanır), bant `[0,2]` korunur. `team.lead_overtime` ekip kartı
  sayılmaz, sprint saati geri gelmez (hüküm E2): `carry` ve `bonus`'taki `sprint_hours` SİLİNİR (aynı slota ikinci
  `productivity_mod` birinciyi ezer: `add_productivity_mod` aynı `card_id`'li satırı değiştirir,
  `character_registry.gd:574-578`); kişiye düşen bedel mevcut `productivity_mod -20/2`; `carry`'deki ve `on_expire`'daki
  `morale_all -2` → `change_morale scope: employee -2`; `bonus` `add_cash -6000` + `change_morale +5`. Kazançsız kalan iki
  şıkkın yeni kazancını yazar v2 yazar (100 kartın içinde, §5 sonu).
- **O1:** `product.sprint_two_paths` `known_way` `status_quo_reason: "ilerlemesi yüksek kartta bilinen yol doğrudur"`.
- **Kabul:** her F satırı için R13 öngörüsü PASS (F3, F9 `PLAUS LONG`'da); `--event-shot=rival.shutdown_notice` ve
  `funding.portfolio_vendor` TR ve EN: pazarlama seçeneği gri ve gerekçeli (pencereli, sırayla, kendi `APPDATA`'sında).

### R12 · Sistem tarafı düzeltmeleri
- **Yenileme tabanı (F9):** `customer_rep_system.gd` `pick_request_kind` (318-372): hesap kıdemi
  `B2BConstants.RENEWAL_MIN_TENURE_WEEKS` (44) altındaysa `renewal` aday dışı; o durumda `last_request_kind` dışlaması yalnız
  en az iki tür kalıyorsa uygulanır (sağlıklı yeni hesaba "şikâyet" düşmesin).
- **Onboarding sesi (F2):** `b2b_sales_system.gd` `risk_voice` (470-477): `BROKEN` ve şikâyet dallarından SONRA (bilerek:
  kırılan söz ve çöken ürün tazelikten önce söylenir), `lifecycle_phase == "onboarding"` ya da kıdem <
  `B2BConstants.ONBOARDING_VOICE_TENURE_WEEKS` (4) ise `B2B_RISK_VOICE_ONBOARDING_1|2` (TR/EN onay bekliyor).
- **Kabul:** smoke `cs_renewal_floor` (yeni): kıdem 43'te `renewal` hiç seçilmez, 44'te seçilebilir; sağlıklı hesapta 0-43.
  haftalar arası hiç `complaint` yok; kıdem 1, bug ≤ `COMPLAINT_BUG_GATE` (6, `b2b_constants.gd:46`), kapasite altında
  hesabın sesi `ONBOARDING` anahtarlarından biri. Mevcut `b2b_*`/`cs_*` vakaları yeşil.

### R13 · Makullük smoke'u (yeni `scripts/events/tools/plausibility.gd`, `tools/plausibility_run.sh`)
- **Ne:**
  - Araç `RunProbe.run` (`run_probe.gd`) ile sürer, `EventBus.event_triggered`'a bağlanır; her ateşte
    `PLAUS FIRE id=<id> src=<köken> week=<w> phase=<p> hc=<n> slots=<slot:kıdem,…> req=<seçenek:açık|kapalı,…>` (RunProbe
    `PROBE FIRE src=` deseni); R5 ertelemesinde `PLAUS DEFER id=<id> src=<köken> step=<1b|2b|immunity> due=<g>`.
  - **Erken işe alım** (her hafta sinyalinde): `HRSearchSystem.has_files_ready()` ise `hire(0)`; değilse `GameState.day >=
    2 + 3k` ve `k < 3` ve `can_start()` iken `start_search(["developer","customer_rep","tester"][k], 0)`, başarıda `k += 1`.
  - Varyantlar: tohum 1-20 (tek `full_run` B2B, çift `full_run_b2c`), her tohum düz ve erken = 40 koşu × 16 hafta.
    **`PLAUS LONG`:** erken × tohum 1-4 × 60 hafta (kıdem 26/44 öngörüleri yalnız burada dolar; 16 haftalık koşuda hiçbir
    çalışan 26, hiçbir hesap 44 haftalık olamaz). `sim` kipi; her koşu ayrı süreç, kendi `APPDATA`'sı, 180 sn (uzun 600 sn).
  - Öngörüler (`PLAUS FAIL <kural> <ayrıntı>`):
    1. `system` olmayan ve kökeni REQUEST/FORCE/FLOOR olmayan kart 1-3. haftada.
    2. Ateş anında derlenen makullük yapraklarından biri tutmuyor (bant, kadro, ürün, modül, `min_week`, `select`li slot kıdemi).
    3. Dokuz kart: `cs_escalation` rep ya da müşteri kıdemi < 4 · `retention`: kıdem < 4 ve BROKEN/şikâyet dalı tutmuyorken
       ses `B2B_RISK_VOICE_ONBOARDING_*` değil · `conference_trip` kıdem < 28 · `shutdown_notice`/`portfolio_vendor`
       pazarlama seçeneği açık · `b2c_creator_feature` kitle < 3000 · `app_placement` kitle < 2000 · `price_cut` müşteri
       kıdemi < 4 · `request_renewal` müşteri kıdemi < 44.
    4. `team.first_weeks` ateşlendi. 5. Aynı aileden iki ateş aile aralığından yakın (`follows` ve REQUEST/FORCE hariç).
    6. `critical` kart `system`/`terminal_warning` değil. 7. Günlükte Parse Error kapısının dört deseni. 8. 1b/2b/immunity
       ile reddedilip `PLAUS DEFER` basmayan SIGNAL/SCHEDULE önerisi (risk sinyali kartsız kaybolmaz).
  - Özet: `PLAUS RATE phase=<p> pool_weeks=<n> nothing=<n> empty=<n>`, `PLAUS SUMMARY runs=<n> fires=<n> fails=<n>` (`fails>0` → çıkış 1).
- **Başlatma:** `main.gd` A'nın K10'undan, B'nin 1. commit'inden ve ACILIS H'den sonra serbest. O zamana dek giriş
  `-s res://scripts/events/tools/plausibility_main.gd -- <spec>` (SceneTree; sınıfları çalışma anında yükler). V7'de
  `main.gd` `valued` tablosuna `"--event-plausibility=": _run_event_plausibility` ve bir `preload`, ayrı hunk.
- **Kabul:** **falsifikasyon:** araç V2'den önce, göç edilmemiş ağaçta en az `cs_escalation`, `retention`, `price_cut` ya
  da `first_weeks` için, `PLAUS LONG`'da `conference_trip` için FAIL basar (çıktı rapora); V5 sonrası
  `PLAUS SUMMARY runs=40 fails=0` ve `PLAUS LONG runs=4 fails=0`, çıkış 0; toplam süre rapora.

### R14 · `--why-fire` makullüğü gösterir (`scripts/events/tools/why.gd`)
- **Ne:** kapı sonucundan bağımsız `PLAUSIBILITY` bölümü: `condition` ve her slot `where`'indeki `_from: plausibility`
  yapraklarını canlı değerleriyle basar (bugün ilk ret adımında durur, seam listesi yalnız `condition`/`trigger.condition`:
  `why.gd:113-133`). Ayrıca frenler ("layer 1b/2b: N hafta kaldı"), kurulu gecikme (`armed d0=<g> due=<g> D=<n>`), bekleyen
  `SCHEDULE_DELAYED` girdisi, başlangıç koruması. Probe spec önerisi (araştırma 11) R13'ün `PLAUS FIRE`'ıyla karşılanır.
- **Kabul:** `--why-fire=team.conference_trip` açılışta G4 "start immunity" ve `PLAUSIBILITY` bölümünde slot kıdem yaprağını
  `[plausibility]` etiketiyle basar.

### R15 · Belgeler
- **Ne:** motor GDD'si: §3.1 şema v3 (§2 tablosu); §13.3'e Katman 1b/2b ve erteleme; §14.1'e "hiçbir şey"; §17'ye
  17.13-17.15; §25 MTTH "Red" → "Kısmen: deterministik gecikme penceresi (§27.19); haftalık şans yok"; yeni §27.19 gecikme
  ve `SCHEDULE_DELAYED`, §27.20 makullük bloğu, §27.21 aile frenleri ve koruma, §27.22 seam'ler, `module_unlocked`,
  kancalar, §27.23 `critical` daraltması ve `retired`, §27.24 lint ve dondurulmuş liste (C §27.17-18'i alır).
  `_vocabulary.md` (`vocab_gen.gd` iki yeni bölüm: "Şema v3" alanları, §4'ün yazar / ayrılmış fiilleri). HARITA olay satırına
  `delays.gd`, `module_locks.gd`, `plausibility.gd`; `CLAUDE.md` §12'ye `--event-plausibility` (C10'dan sonra, hunk bazlı).
- **Kabul:** `git show --stat` yalnız belgeler ve üretilmiş dosyalar; `_vocabulary.md` farkı yalnız yeni seam/bölüm satırları.

## 4. Yazılabilir fiiller (HEAD'den türetildi; yazar PRD'si bunu kopyalar)
Kural: fiil `EvEffects._apply`'da çalışan bir kola (`effects.gd:217-556`) VE `EvChips`'te bir etikete ya da `SILENT_VERBS`'e
(`chips.gd:20-45` ve `describe` kolları) sahip olmalı. 63 listeli fiilden:
- **Yazar fiilleri (30):** `add_cash` (etiket `ONE_TIME_LABELS`'tan), `add_brand`, `add_reputation`, `customer_mrr_delta`,
  `seats`, `churn_customer`, `audience_delta`, `add_prospect`, `employee_leaves`, `b2b_retain_discount`, `b2b_expand`,
  `change_morale`, `morale_all`, `satisfaction_delta`, `promise_create`, `sprint_hours`, `sprint_card_effort`,
  `sprint_card_progress`, `sprint_card_carry`, `fix_run_start`, `b2b_retain_delay`, `b2b_retain_ignore`,
  `b2b_expand_decline`, `set_flag`, `stamp_day`, `schedule_event`, `cancel_scheduled`, `productivity_mod`,
  `investor_strain`, `marketing_push` (`cardcheck.py` `SAFE` kümesiyle bire bir).
- **Ayrılmış, yalnız `system` kartı (18):** `advance_phase`, `phase_gate_decline`, `angel_accept`, `open_term_table`,
  `open_seed_table`, `decline_offer`, `decline_buyout`, `trigger_ending`, `mentor_advisory`, `goto_tab`, `unlock_content`,
  `spend_budget`, `set_game_flag`, `start_arc`, `advance_arc`, `end_arc`, `abort_arc`, `set_arc_var`.
- **Yazılamaz (15):** kolsuz `assign_to`, `send_on_leave`, `start_training`, `damage_product`, `add_customer`,
  `convert_audience`, `open_paid_tier`, `change_salary`, `fire_employee`; uygulamayan `add_mrr`, `open_negotiation`; çipsiz
  `clear_flag`, `set_timed_flag`, `ticker_push`, `notify`.
- **Ek kısıtlar:** `sprint_card_*` yalnız `tick: request` sprint karar kartında; `productivity_mod scope: founder` `founder`
  slotu ister, kadrosuz kurucuda eksi satır −30 ve 2 haftaya kırpılır (`hr_system.gd:376-382`, `hr_constants.gd:842-843`);
  aynı slota tek `productivity_mod` (kart id'siyle değiştirilir); `marketing_push` demo kartında yok, EA'da kilitli (O5);
  `sprint_hours` ve negatif `morale_all` tek kişilik kartta yok (O3); ekonomik fiil `on_expire`'da yalnız negatif (I2).
- **Okunabilir durum:** 179 kayıtlı seam (`_vocabulary.md` §b) + R2'nin üçü + `build.last_unlocked_module`. Makullük için:
  `phase.current`, `hr.headcount`, `hr.tenure_weeks`, `musteri.tenure_weeks`, `urun.is_live`, `urun.weeks_since_launch`,
  `time.week`, `hr.weeks_since_last_hire`, `hr.run_hires`, `build.module_unlocked.<id>`.
- **Yeni CSV anahtarları (TR/EN onay bekliyor, EN önce):** `EV_LOCK_MARKETING_EA` "Marketing opens in Early Access." /
  "Pazarlama Erken Erişim'de açılır."; `B2B_RISK_VOICE_ONBOARDING_1` "We're still setting it up, and my team is already asking
  if this was the right call." / "Hâlâ kurulumdayız ve ekibim şimdiden doğru karar mıydı diye soruyor.";
  `B2B_RISK_VOICE_ONBOARDING_2` "Getting started has been harder than your demo made it look." / "Başlamak, demonuzda
  göründüğünden zor oldu."

## 5. Göç tablosu (87 kart: HEAD'in 86'sı + C6'nın `funding.frank_v1`'i)
**Bant, kadro, kıdem, gecikme ve aile değerleri tasarım sabitidir: onay bekliyor.** Bant **S** `bootstrap_solo`, **E**
`bootstrap_team`, **T** `traction`, **A** `series_a`. Kadro `[min,max]` (`*` = `[0,null]`). Kıdem `m` müşteri, `ç` çalışan
slotu; `—` = alan yazılmaz ve derlenmez (slot yok, yatırımcı, aday ya da `select`siz verilen slot; §2). Ürün **P**
`pre_launch`, **L** `live`, `*` `any`. Gecikme `[N,M]`; `0` = `[0,0]`, gerekçe parantezde. **SİS** = `system: true`.
`min_week` yazılmadıysa 0. Employee slotlu ailede `family_subject` notta yoksa `cooldown_weeks: 26` (T2). `/` aynı satırı
paylaşan kartlar.

| Kart | Bant | Kadro | Kıdem | Ürün | Aile | Gecikme | Not |
|---|---|---|---|---|---|---|---|
| customer.b2c_refunds | S E T A | * | m 4 | L | customer_money_dispute | 1-4 | min_week 8 |
| customer.chargeback | S E T | * | m 8 | L | customer_money_dispute | 1-4 | |
| customer.cs_escalation | E T A | [1,null] | m 4, ç 4 | L | customer_escalation | 0-1 | F1; `critical` düşer |
| customer.expansion | S E T A | * | m 12 | L | customer_growth | SİS | B2B yaşam döngüsü verir |
| customer.frank_intro | S E T | * | — | L | frank_mentor | SİS | critical |
| customer.leak_questions | T | * | — | L | leak_story | 0 (zincir) | follows named_in_leak (history) |
| customer.named_in_leak | T | [1,null] | m 8, ç 8 | L | leak_story | 1-4 | |
| customer.new_owner | T A | * | m 12 | L | customer_ownership | 1-4 | |
| customer.new_owner_group | T A | * | — | L | customer_ownership | 0 (zincir) | follows new_owner (zamanlar) |
| sales.price_break | S E T A | * | — | * | sales_negotiation | SİS | istek |
| customer.request_complaint / request_feature | S E T A | * | m 2 | L | customer_requests | SİS | istek |
| customer.request_renewal | S E T A | * | m 2 | L | customer_requests | SİS | F9 (R12 tabanı) |
| customer.retention | S E T A | * | m 0 | L | customer_risk | 0 (sinyal tepkisi) | F2; `fresh_reason`; reddi ertelenir |
| customer.security_review | T A | * | m 8 | L | customer_security | 1-4 | 6 → 8 |
| founder.company_of_one | S | [0,0] | — | P | founder_solitude | 0 (taban) | quiet; not (C R5) |
| founder.domain_name | S E | [0,2] | — | P | founder_setup | 1-3 | |
| founder.friends_test | S E | [0,2] | — | P | founder_network | 1-3 | |
| founder.meetup_talk | S E | [0,2] | — | P | founder_network | 1-3 | O3: `productivity_mod founder` |
| founder.savings_note | S E | [0,2] | — | P | founder_money | 0 (taban) | quiet; not |
| founder.side_contract | S E | [0,2] | — | P | founder_money | 1-3 | O3: `productivity_mod founder` |
| founder.unseen_build | S E | [0,2] | — | P | founder_solitude | 0 (taban) | quiet; not |
| funding.acquisition_offer | T A | * | — | * | series_a_table | SİS | critical, terminal |
| funding.closing_docs / closing_docs_series_a | T / A | [1,null] | — | * | funding_paperwork | 0 (sinyal) | |
| funding.closing_docs_diligence | A | [1,null] | — | * | funding_paperwork | 0 (sinyal) | follows closing_docs (koşul) |
| funding.frank_approach_close / _half / _near | T | * | — | * | frank_mentor | SİS | critical |
| funding.frank_cheque | S E | * | — | L | frank_mentor | SİS | critical |
| funding.frank_door_open | T | * | — | * | frank_mentor | SİS | critical |
| funding.frank_office_move | S E | * | — | * | frank_mentor | SİS | critical; scope `ea` |
| funding.frank_v1 | S E T | * | — | L | frank_mentor | SİS | C6; scope `draft` |
| funding.gate_series_a | T | * | — | * | phase_gate | SİS | critical |
| funding.gate_traction | S E | * | — | L | phase_gate | SİS | critical |
| funding.hire_nudge | S | [0,0] | — | * | frank_mentor | SİS | critical |
| funding.last_answer / funding.shutter_warning | S E T A | * | — | * | run_end | SİS | critical, terminal |
| funding.monthly_update | T A | [2,7] | — | L | investor_pressure | 1-3 | |
| funding.portfolio_vendor | T | * | — | L | investor_favor | 0-3 | F4; pencere 2-8 |
| funding.portfolio_vendor_trial | T | * | — | L | investor_favor | 0 (zincir) | follows portfolio_vendor (koşul) |
| funding.seed_closed / seed_door / seed_offer | T | * | — | * | seed_round | SİS | critical |
| funding.seed_stalled | T A | * | — | * | seed_round | SİS | |
| funding.sheet_decision / sheet_expiry | A | * | — | * | series_a_table | SİS | critical |
| product.b2c_floor_churn | S E T A | * | — | L | product_floor | 0 (sinyal) | reddi ertelenir (R5) |
| product.b2c_floor_signal | S E T A | * | m 4 | L | product_floor | 0-1 | |
| product.bug_pile | S E T A | * | — | L | product_quality | 1-3 | |
| product.launch_leak | S E T | * | — | L | product_security | 0-2 | pencere 2-6 |
| product.outage | T A | * | — | L | product_ops | 0-2 | |
| product.paid_tier | S E T | * | — | L | frank_mentor | SİS | critical; C15 koşulu |
| product.repeat_reminders | S E T | * | m 4 | L | customer_feedback | 0 (`version_age==1`) | 2 → 4 |
| product.sprint_colors_again | T A | * | m 12 | L | sprint_scope_creep | 0 (istek) | follows sprint_hardcoded_colors (koşul) |
| product.sprint_contractor | S E T A | * | — | * | sprint_capacity | 0 (istek) | |
| product.sprint_hardcoded_colors | T | * | m 8 | L | sprint_scope_creep | 0 (istek) | |
| product.sprint_late | S E T A | * | — | * | sprint_capacity | 0 (istek) | C9, C15'ten sonra |
| product.sprint_rewrite_bugs / _reader | T A | [3,null] | ç 15 | L | sprint_rewrite | 0 (zincir) | follows sprint_unasked_rewrite (zamanlar) |
| product.sprint_rewrite_owner | T A | [3,null] | ç 16 | L | sprint_rewrite | 0 (zincir) | aynı |
| product.sprint_two_paths | S E T A | * | — | * | sprint_capacity | 0 (istek) | O1 `status_quo_reason` |
| product.sprint_unasked_rewrite | T A | [3,null] | ç 12 | L | sprint_rewrite | 0 (istek) | |
| product.support_overflow | S T | [0,0] | m 4 | L | product_support | 1-3 | |
| product.working_parts | S E | [0,2] | — | P | product_progress | 0 (taban) | quiet; not |
| rival.copycat | S E T | * | — | L | rival_imitation | 1-4 | |
| rival.copycat_reply | S E T | * | — | L | rival_imitation | 0 (zincir) | follows copycat (koşul) |
| rival.false_partner / price_cut | T / T A | * | m 4 | L | rival_poaching | 1-4 | price_cut: F8 |
| rival.funding_round | A | * | — | L | rival_funding | 1-4 | |
| rival.shutdown_notice | T A | * | — | L | rival_exit | 1-4 | F5 |
| team.conference_trip | E T | [1,null] | ç 26 | * | employee_asks_money | 2-8 | F3; `once` |
| team.demo_day | E T A | [3,null] | — | L | team_ritual | 0 (sprint haftası) | quiet |
| team.first_weeks | — | — | — | — | new_hire_onboarding | — | E1: `retired` |
| team.lead_overtime | T | [3,null] | ç 12 | L | team_overload | 0 (sprint haftası) | O3 düzeltmesi |
| team.outside_offer | T A | [3,null] | ç 26 | * | employee_asks_money | 2-8 | K3: 12 → 26; `once` |
| team.password_rule | E T | [1,null] | ç 8 | L | team_security | 0 (sprint haftası) | |
| team.resignation | S E T A | [1,null] | — | * | hr_departure | SİS | critical, istek (verilen) |
| team.wiped_table | T | [3,null] | ç 4 | L | employee_mistake | 1-3 | `newest_hire` bilerek (T3: dondurulmuş) |
| world.app_placement / b2c_creator_feature | T A / S E T A | * | — | L | world_offer_b2c | 1-6 | F7 / F6 |
| world.final_stretch_comment / _press / _verdict | S E T A | * | — | * | run_end | SİS | critical, terminal |
| world.analyst_guide / newsletter_slot | A | * | — | L | world_offer_b2b / _b2c | 0-1 | R7; pencere ≤ 4 |
| world.trade_fair | T A | * | — | L | world_offer_b2b | 1-6 | |

Sayım: 30 SİS (23'ü `critical`), 56 hikâye kartı (dondurulmuş liste), 1 emekli. `bootstrap_solo` ürün öncesi yalnız 8 kart
(7'si kurucu; 4'ü not, 4'ü karar), `bootstrap_team`'de çalışan öznesi taşıyan hikâye kartı 3 (`conference_trip`,
`password_rule`, `cs_escalation`). Sahibin asgari sayıları (çalışansız 10-15, evre başına 20) için eksik yazar PRD'sine.

**Yazar v2 yeniden yazım listesi** (R9; hüküm E2, E3, E5; HEAD + R11 düzeltmeleri; O2/T2 yok; nihai olan V6'nın W'leri):

| Kart | Uyarı | Şık |
|---|---|---|
| customer.chargeback / customer.named_in_leak / customer.new_owner_group | O4 | `keep` / `lawyer` / `pitch` |
| product.sprint_colors_again / product.sprint_rewrite_bugs / product.sprint_rewrite_owner / product.sprint_rewrite_reader | O4 | `by_hand`, `one_file`, `freelancer` / `freeze` / `trainer` / `peer` (son üçü `scope: team`, slota düşmez) |
| funding.portfolio_vendor / rival.shutdown_notice | O5 (hüküm E5: kilitli, yeniden yazılana dek W) | `own_ads` / `more_marketing` |
| team.wiped_table | T3 (`newest_hire`, kıdem 4) | özne seçimi |
| team.lead_overtime | hüküm E2 (lint dışı) | `carry`, `bonus` kazançsız |

## 6. Dosya sahipliği ve ortak hunk'lar
| Dosya | Önce gelen | Bu PRD'nin hunk'ı | Sıra |
|---|---|---|---|
| `scripts/events/core/engine.gd` | C2 `_admit` not yolu, C12 `pump` mandal iadesi | `_step_pool`/`_weighted_pick` (R4, R6), `_step_floor`, `_step_schedule`, `_step_signal_drain`, `_step_module_watch`, `_propose` aile sorusu ve erteleme | C12'den sonra (V3) |
| `gate.gd`, `tempo.gd` (ACILIS dokunmuyor), `signals.gd`, `schedule.gd`, `tuning.gd`, `save.gd`, yeni `delays.gd` | — | `_g4_window` koruma ve `SCHEDULE_DELAYED`, Katman 1b/2b, R4-R8 | V3 |
| `scripts/autoload/event_bus.gd` | A (saat sinyalleri olabilir) | `signal module_unlocked(module_id: String)` tek satır, uygun `# --- X ---` bölümünde | V3 |
| `catalog.gd`; `lint.gd`, `tools/lint_baseline.json`, `tools/lint_v3_frozen.json`; `why.gd`, `vocab_gen.gd` | — | R1; R9; R14, R15 | V2, V6; V3, V8 |
| `presenter.gd`, `harness.gd`, `seams_product.gd` | C2 `is_note`, `freeze_seams`, `BEAT_MODAL`; B commit 6 | dokunulmaz; lint `is_note`'u okur | — |
| `scripts/events/seams/seams_world.gd`, `seams_hr.gd` | — | R2, `build.last_unlocked_module` | V1, V3 |
| `data/events/cards/**` | C6 `frank_v1.json`; C9+C15 `sprint_late.json`; C15 `paid_tier.json` | 87 kartın göçü; `_fixtures/v3_compile.json`, `first_customer.json`, `lint_v3/_bad_*.json` | fikstür V2/V3; göç V4, V5 |
| `founder/company_of_one.json`, `meetup_talk.json` | C §7.4'te sahip kuyruğunda | göç bloğu + `meetup_talk` O3 | V4; §7.4 kararı gelmişse üstüne, gelmemişse yalnız v3 bloğu |
| `scripts/ui/components/left_tabs.gd`; `ui_tokens.gd` | C4/C14 | `_is_locked` → `ModuleLocks.is_open` tek satır; `ui_tokens.gd` yalnız okunur | C14'ten sonra (V1) |
| `scripts/main/main.gd` | A K1-K10 (şu an A düzenliyor), B commit 1, ACILIS H kolları | bir `preload` + `valued` satırı + `_run_event_plausibility` | A K10, B1, ACILIS H'den sonra (V7) |
| `scripts/debug/endgame_smoke.gd` | A, B, C vakaları | 9 yeni vaka (`event_plausibility_compiles`, `event_v3_seams`, `event_start_immunity`, `event_pool_nothing_weight`, `event_family_gap`, `event_delay_window`, `event_on_action_bindings`, `event_lint_v3_rules`, `cs_renewal_floor`) sona; R3'ün kırdığı vakalarda `day = 4` | her vaka kendi commit'inde |
| `_vocabulary.md`, `docs/EVENT_SIGNAL_MANIFEST.md` (üretilmiş) | B commit 6 yeniden üretir | yeniden üretim | B6'dan sonra (V1, V8) |
| Motor GDD'si; `docs/HARITA.md`, `CLAUDE.md` §12 | C §27.17-18; A, C10 | §3.1, §13, §14, §17, §25, §27.19-24; olay ve bayrak satırı | C10'dan sonra (V8) |
| `customer_rep_system.gd`, `b2b_sales_system.gd`, `b2b_constants.gd`, yeni `module_locks.gd`; `strings.csv` | sahipsiz; C anahtarları | R2, R12; 3 anahtar, bayt-span | V1, V5 (C'nin CSV commit'lerinden sonra) |

## 7. Commit sırası ve kapılar
Her commit: `"$GODOT" --headless --path . --event-lint` → (CSV varsa) `-s res://scripts/debug/loc_residue.gd` ve
`bash tools/smoke_run.sh loc_csv_integrity` → hedefli smoke (tek tek) → Parse Error kapısı → ayrı ajan diff incelemesi →
commit. Motor commit'inde ek: harness `HARNESS PASS`, `run_gate.sh` 3/3. Mesaj: "TR/EN onay bekliyor" / "onay bekliyor".

| # | İçerik | Bağımlılık | Kapı |
|---|---|---|---|
| V0 | Ön koşul: PRD_SAAT K1-K10, PRD_SPRINT 1-11 (hepsi; 7 botun sprint başlatması, R13 bunu sürer), PRD_ACILIS C1-C15 + H + C10 `main`'de; `git status --short` | — | rapora `git log --oneline` kesiti |
| V1 | R2 seam'ler + `module_locks.gd` (override dahil) + `left_tabs.gd` tek satır; `_vocabulary.md` yeniden üretim | V0 | smoke `event_v3_seams`, `rail_tabs_match_scene_order`; `--event-probe` `- seams`; `--event-vocab` farkı (R2) |
| V1b | R13 aracı (`plausibility.gd`, `plausibility_main.gd`, `tools/plausibility_run.sh`) + **falsifikasyon koşusu** göç öncesi ağaçta | V1 | araç çalışır, en az dört FAIL türü basar (çıktı rapora; bu commit FAIL'i beklenen sayar) |
| V2 | R1 derleyici + `FAMILY_SUBJECT_TENURE` + R9 kuralları (P2 W, fikstür muafiyeti) + `_fixtures/v3_compile.json`, `_fixtures/lint_v3/_bad_*.json`, `tools/lint_v3_frozen.json` | V1b | smoke `event_plausibility_compiles`, `event_lint_v3_rules`; `--event-lint` HEAD fikstürlerinde yeni bulgu yok, P2 W dışında eski sayıda |
| V3 | R3-R8 motor: koruma (geçiş kolu dahil), "hiçbir şey", aile frenleri ve erteleme, gecikme + `SCHEDULE_DELAYED` (`delays.gd`, `EvSave`), `customer_added`/`module_unlocked` (`event_bus.gd`), R14; `--import` + ısınma | V2 | beş yeni motor vakası + `awk` `event_*` listesinin TAMAMI (ACILIS §6 C2 komutu; sayı C2 sonrası değişir) + R3 kabulündeki gün ≤3 vakaları + `quiet_cards_fill_empty_floor`, `cheque_read_steps`, `save_roundtrip_fingerprint`, `save_double_load_no_residue`, `legacy_v12_save_opens_live_table`; harness; run_gate 3/3 |
| V4 | R10 göç: 87 kartın v3 bloğu (§5), `critical` daraltması (R7), O3 ve O1 düzeltmeleri | V3 | lint 0 error (P2 dahil 0 uyarı; fikstürler muaf); harness; run_gate 3/3; `--why-fire` beş kart; R13 (F satırları henüz FAIL olabilir: listesi rapora) |
| V5 | R11 F1-F9 + E1 emeklilik + R12 + 3 CSV anahtarı; `event_start_immunity`'ye E1 doğrulaması (§11.6) | V4 | smoke `cs_renewal_floor`, `event_start_immunity`, `b2b_*`/`cs_*` dokunulan vakalar, `event_chip_coverage`; loc kapıları; iki `--event-shot` TR ve EN; **R13 `fails=0`, `PLAUS LONG` `fails=0`** |
| V6 | Lint P2 → E (K5), R3 geçiş kolu silinir, dondurulmuş listenin W'leri baseline'a | V5 | `--event-lint` 0 error; `lint_baseline.json` farkı yalnız liste W'leri, W'li kartlar §5 sonundaki listeyle karşılaştırılır (fark Done mesajına); `event_start_immunity` |
| V7 | `main.gd` `--event-plausibility=` bayrağı (ayrı hunk) | V6; SAAT K10, B1, ACILIS H | smoke `all_scripts_load`; `--event-plausibility=seeds=20:weeks=16` ile `-s` girişi aynı `PLAUS SUMMARY` |
| V8 | R15 belgeler, `_vocabulary.md` ve sinyal manifesti yeniden üretimi, HARITA, CLAUDE §12 | V7 | `git show --stat` yalnız belgeler ve üretilmiş dosyalar; tam smoke paketi entegrasyonda bir kez |

## 8. Tasarım sabitleri (hepsi onay bekliyor; `EvTuning`'de, tek ayar yüzeyi)
| Sabit | Değer | Gerekçe |
|---|---|---|
| `START_IMMUNITY_WEEKS` | 3 | K4; 1×'te ~67 sn (22,5 sn/hafta, `time_model.gd:9`) |
| `POOL_NOTHING_WEIGHT` | {1: 1,5, 2: 1,0, 3: 0,6} | Bootstrap havuzu ince; Series A haftası doludur |
| `FAMILY_GAP_WEEKS_DEFAULT` / tablo | 6 / `employee_asks_money` 12, `world_offer_b2c` 8, `world_offer_b2b` 8, `founder_solitude` 3, `founder_network` 4, `customer_risk` 2, `product_floor` 4 | CK3 1.12.5 cooldown dersi; ritim kartları kısa, para kartları uzun |
| `DISARM_WEEKS` | 4 | Sprint döngüsü (~4 hafta) bir kez geçebilsin |
| `FAMILY_SUBJECT_TENURE` | `{"employee_asks_money": 26}` | K3; 1×'te ~10 dk; R1 derleyicisi okur |
| `RENEWAL_MIN_TENURE_WEEKS`, `ONBOARDING_VOICE_TENURE_WEEKS` (`B2BConstants`) | 44, 4 | 12 aylık sözleşmenin son iki ayı; ilk ay taze hesap |
| Kitle/nakit tabanları | creator 3000 kitle + 10000 nakit; app_placement 2000 kitle | "Büyük takipçili" yaratıcı ve mağaza vitrini küçük tabanda yalan |
| O3 eşdeğer büyüklükleri | `side_contract` `take` −30%/2 (kadrosuz kurucu tavanı, `hr_constants.gd:842`), `half` −15%/2; `meetup_talk` `talk` −20%/1 | Bugünkü `sprint_hours` çarpanlarının kurucu karşılığı; sınırlar −50..+30, kadrosuz kurucuda −30/2 hafta |
| `analyst_guide`/`newsletter_slot` penceresi | ≤ 4 hafta | `critical` düşünce havuz rekabeti |

## 9. Sahibe bırakılan kararlar
Hükümle kapananlar gövdede: E1 → R4 · E2 → R11 · E3 → R9, §5 sonu · E4 → R3 · E5 → R9, K2 · E7 → üst bilgi, §0a.
1. K1-K5 (§0), onay bekliyor. Reddedilen varsayımın geri dönüş yolu tabloda; ajan uygular, raporda ⚠️.
2. §5 ve §8'in bütün sayıları (bant, kadro, kıdem, gecikme, aile, aralık, taban), onay bekliyor.
3. `bootstrap_team` = faz 1 ∧ kadro ≥ 1 ("1-2 çalışan" `headcount`'ta; bölmek isterse beşinci bant). F2'nin yolu: koşul
   değil ses (0a) ve sinyal ertelemesi; iki onboarding dizesi TR/EN onay bekliyor.
4. Emeklilik yolu `retired` (dosya ve CSV kalır; CLAUDE §8 "ölü anahtar" gerilimi) mi, silip `main.gd:2236`/smoke 16548'i
   başka karta yöneltmek mi; yazar v2'de 9/10'u geçemeyen kart da bu yoldan emekli olur.

## 10. Erdem'in bakacakları
- İki `--event-shot` (`rival.shutdown_notice`, `funding.portfolio_vendor`) TR/EN: pazarlama şıkkı gri, gerekçe okunur.
- `PLAUS SUMMARY`/`PLAUS RATE` (`nothing`, `empty`): 1-3. hafta yalnız not, Bootstrap'te kaç hafta boş; `PLAUS LONG`'da
  `conference_trip`'in ilk kıdemi, aynı çalışana ikinci para kartı ve "ilk haftalar" kartı yok. §5'in bant sütunu doğru mu.

## 11. Doğrulama listesi
1. 87 kartın hepsi `schema: 3`; lint 0 error; baseline'a yalnız dondurulmuş listenin W'leri girdi, kartları §5 sonunda.
2. `critical` taşıyan her kart (fikstürler hariç) `system` ya da `terminal_warning`; sayı 23.
3. Yazar fiilleri 30, ayrılmış 18; kolsuz/çipsiz 15 fiil hiçbir kartta yok (V1); her `_bad_*` kendi kimliğini üretir.
4. Koruma, frenler, erteleme ve gecikme kayıt gidiş-dönüşünde aynı kararı verir; aynı tohum aynı `PLAUS FIRE` dizisi.
5. R13 falsifikasyonu göç öncesi FAIL, göç sonrası 40 + 4 koşuda `fails=0`; Parse Error kapısı temiz.
6. `team.first_weeks` hiç ateşlenmez; V5'te `event_start_immunity`: `EvHistory.record("team.first_weeks", ...)` → `EvSave`
   gidiş-dönüşü → `EvCatalog.card("team.first_weeks")` boş değil, öneri G2'de "version_scope 'retired'" reddi.
7. Sinyal gecikmesi `SCHEDULE_DELAYED` ile gelir, G4 reddetmez; frene ya da korumaya takılan sinyal ertelenir; REQUEST muaf.
8. Üretilmiş dosyalar elle düzenlenmedi; GDD §25 ve §27.19-24 kodla aynı; kirli dosyalarda yalnız bu PRD'nin hunk'ları.
9. Kayıt şeması (GameState 15, olay bloğu 1) değişmedi; yeni anahtarlar (`delayed` dahil) eski kayıtta boş/false açılır.

## 12. Done mesajı
Erdem'e ✅/⚠️/❌ listesi: R1-R15 ve F1-F9/E1, her biri commit kimliği ve kapı çıktısıyla (smoke vaka ve sonucu, `LINT`
satırı, `HARNESS PASS`, `run_gate` 3/3, `PLAUS SUMMARY` ve `PLAUS LONG` önce/sonra); K1-K5 ⚠️; §5 ve §8 "onay bekliyor";
TR/EN onay bekleyen üç anahtar; V6 W'leri ile §5 sonundaki listenin farkı (⚠️); `day = 4`'e alınan vakalar; bant dağılımı ve
yazar PRD'sine devredilen açık; kırılıp düzeltilen başka task vakaları; commit listesi; push yapılmadı.

## 13. Öğretici notlar
- **Eşik bir tarih değil, bir kapıdır.** Paradox her olayı "ancak şu varsa ve şu kadar süre geçtiyse" diye yazar,
  zamanlamayı ayrı katmana bırakır. İnce havuzda bizim kart kapı açıldığı hafta geliyordu; gecikme penceresi kapıyı tarih
  olmaktan çıkarır, zar `EvDice` hash'i olduğu için kayıt-yükle hilesi açmaz. MTTH'nin haftalık şansı yerine tek sayı.
- **Makullük yazarın değil şemanın işi.** Blok zorunlu olunca unutmak lint hatasıdır; kural motorda tek yerde yaşar.
- **Sinyal bir kez gelir; istek her hafta yeniden gelir.** Sinyali reddeden kural onu ertelemeli; isteği reddetmek onu
  yeniden açtırır, bu yüzden istek kartı frenlerden muaftır ve düzeltme sistemde yapılır.
- **Fikstür de karttır.** Lint ve katalog dizini değil dosyayı görür: muafiyet `version_scope` ile, katalog dışılık `_` öneki
  ile verilir. İkisini karıştıran kabul kapısı kendi kendini düşürür.
