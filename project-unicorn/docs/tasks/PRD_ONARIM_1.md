# PRD · Onarım 1 · Üç task'ın dışında kalan pürüzler

**Kim çalıştırır:** `PRD_SAAT.md`'yi uygulayan geliştirici ajanı oturumu (A), SAAT'in K10 commit'i main'e indikten sonra
(sahip kararı 2026-10-10). B (`PRD_SPRINT.md`) ve C (`PRD_ACILIS.md`) bu sırada aynı ağaçta koşuyor olabilir.
**Durum:** yardımcı yönetmen onaylı, 2026-10-10; sahibe giden maddeler 'Sahibe bırakılan kararlar'da.
**Hükümler:** `RULINGS_2026-10-10` F1, F4, F12 ve "Onarım 1" satırları.
**Tek cümle:** üç task'ın sahip olmadığı doğrulanmış pürüzleri, onların dosyalarına çakışmadan kapatır; B2B ilk müşteri
ekonomisi (S02, blocker) en sonda, ölçüm ve sahip onayıyla.
**Çıktı:** §9'daki commit dizisi; tasarım notu ACIK 107 (a S02, b S43, c ACIK 60, d S12) ve önce/sonra ölçüm
tablosu; 1920×1080 TR ve EN ekran görüntüleri; ✅/⚠️/❌ raporu.

Kaynak: senaryo pürüzleri (`play/SCENARIO_SNAGS.md`, build `1e2d9a0`) ve `tasks/ONARIM_1_ADAYLARI.md`. Bu PRD'deki
her dosya:satır HEAD `6a82a8e`'de yeniden okundu. `strings.csv` `0fe77fc`'de 33 satır kaydı: pürüz tablosunun CSV
numaraları burada güncel. SAAT, SPRINT ve AÇILIŞ inince satırlar kayar: hunk'ı işlev ya da anahtar adıyla yeniden bul.

---

## 0. Bulgu → gereksinim

Grup sırası (sahip kararı): **B → C → D → E → A → S39**. Kimlikler `SCENARIO_SNAGS.md`'nindir.

| id | sev | kanıt (HEAD `6a82a8e`) | gereksinim |
|---|---|---|---|
| S18 | major | Yeni çalışana ana iş kendiliğinden atanır (`character_registry.gd:434-437`), `is_idle` yalnız işsizi sayar (`hr_system.gd:288-289`, `idle_count` `:305-310`); `_job_text` sprint yokken "Yapımda görev alıyor" der (`scripts/tabs/hr/hr_ledger.gd:232-245`, `strings.csv:523-527`); tür seçilmeden kimse çalışmaz (`sprint_system.gd:473-475`); destek ürün canlı değilken döner (`support_system.gd:203-205`) | §2.1 |
| S19 | major | Seviye adımında para yok, bilerek (`hr_atlas_modal.gd:12-14,71-85`); `HR_WARN_SALARY_CASHFLOW` yalnız net akış ≥ 0 iken (`hr_search_system.gd:248-249`), gelir öncesi hiç; "İşe al" onaysız `hire()` (`hr_atlas_modal.gd:234-235,364-367`), komisyon anında (`hr_search_system.gd:191`); `affordable` yalnız komisyona bakar (`:258`) | §2.2 |
| S20 | major | `preview_hire` `burn_after`'ı maaş + araçla kurar (`hr_search_system.gd:239-243`), finans her tik mesai ekler (`finance_system.gd:136`); devralınan saat `work_hours_system.gd:63-70`; run_h15: önizleme 6 → 2 ay, gerçek 0,65 ay | §2.2 |
| S43 | minor | Saatlik ücret 22 iş günü tabanı (`hr_constants.gd:758-760,784-794`), tahakkuk tik başına ×7 ve ayda ×30 (`finance_system.gd:136`, `time_model.gd:16-17`, `work_hours_modal.gd:394-396`): run_h15'te $4.920/ay, kuralla $3.609 (+%36); kurucu modalde yok (`work_hours_modal.gd:8,55-58`), bedel bloğu solo kurucuda null (`:380-385`) | §2.3, §2.5 |
| S44 | minor | `set_hours_mult` sprint geneline tek çarpan (`sprint_system.gd:252-256`, `effects.gd:414-420`), `team()` herkesi çarpar (`sprint_system.gd:394,400`); gövde "Harcadığın her saat üründen eksilecek." (`strings.csv:2911`), çip kimin saati olduğunu demez (`:2867`) | §2.4 |
| S45 | minor | TopBar BURN günlük × 30 (`finance_system.gd:286-292`), ay kapanışı takvim ayının 4 ya da 5 tikinden nakit farkı (`summary_system.gd:104-125`), satır bunu söylemez (`strings.csv:1568`) | §2.4 |
| S21 | major | Boş Ekip "0", boş moral, $0 ve boş satır "Henüz kimse yok · İşe alım başlat" (`hr_tab.gd:204-208,414-416`); bir işe alımın ne kattığı hiçbir yerde yok; Dengeli junior en pahalı ama 1,5 puan/hafta (`hr_constants.gd:624-625`, `sprint.json:19-20`) | §2.5 |
| S13 | major | 54 satış satırı ve `HR_FOUNDER_STATE_CARE` "PH:" ile başlar (`strings.csv:2353-2406,2420`), `price_break.json:70-83` de; yükleyici soymaz (`localization.gd:92-98`); smoke bunu ŞART koşar (`endgame_smoke.gd:15337-15344`, vaka `loc_sales_derived_keys`); `_derive_loss_reason` kararlılık < 40 ise ne sorulduysa `LOSS_STABILITY` (`sales_meeting_system.gd:332-341`), sorulan aileler `_used_families`'te durur (`:31,221`) | §3.1, §3.2 |
| S32 | major | Yönlendirme düğmeleri yalnız olay kapısıyla kapanır (`sales_tab.gd:169,328-335,736`), `set_routing` temsilci aramaz (`sales_ledger.gd:51-62`), bant denetimi var ama kullanılmaz (`sales_rep_system.gd:89`); `apply_discount` yalnız mrr'ı düşürür (`b2b_sales_system.gd:262-278`), kart damgalı `seat_price`'ı basar (`sales_tab.gd:480-491`): "$280/ay · 7 koltuk · $47/koltuk" | §3.3 |
| S55 | minor | `OFFICE_TIER_HOME` "Perde 1" (`strings.csv:2582`) kademe sözcüklerinin yanında (`:2583-2585`), büyük harfle çizilir (`office_map_card.gd:44`); `OFFICE_REQ_CASH` "Kasada {money}" (`:2619`) ↔ "Ekip en az" / "Marka en az" (`:2618,2620`) | §4.1 |
| S42 (D payı, F1) | minor | Ofis kartı yalnız kurulurken okur (`office_map_card.gd:16,29-33`), harita yalnız dil ve palette yeniden kurar (`office_city.gd:99-100,313-317`) | §4.1 |
| S23 (D payı, AÇILIŞ §7.4) | major | Çek şartı yalnız İş hanı kartında "Frank'in çeki alındı · henüz değil" (`office_map_card.gd:135-137`, `strings.csv:2617,2623`); "Ofisi taşı" hep görünür, çekten önce ipucu yok (`office_hud.gd:90-105`) | §4.1 |
| S24 | major | Kart KİRA/AY, TAŞINMA ve "Taşın · {money}" basar (`office_map_card.gd:33,58-69,105`; `strings.csv:2632-2635,2640`), `move_to` para oynatmaz (`office_system.gd:46-54`), "office" gider kalemi 0 (`finance_system.gd:28`); hover "{desks} masa · {money}/ay" (`office_city.gd:167-168`, `strings.csv:2646`); ACIK 60 | §4.2 |
| S16 | major | `fix_run_refusal` hata yok denetimini masa kapalıdan önce yapar (`support_system.gd:296-299`), kart "Doğrulanmış hata yok." der (`build_bar_model.gd:16-19,56-57`, `strings.csv:503`); GELEN çizilmez (`build_bar.gd:145`) ama memnuniyeti o yer (`support_system.gd:255-257`) | §5.1 |
| S34 | major | Donmuş araştırma rozete +1 (`rnd_system.gd:661-662,731-732`), vazgeç yok (`_active` yalnız `:70,276,433`'te boşalır), `pause()` `_active`'i tutar (`:321-326`); `_displace_job` hep `RND_PAUSED_BUILD` "Ekip yapımda." (`character_registry.gd:239-243`, `strings.csv:480`) | §5.2 |
| S49 | minor | Keşif notu olmayan tasarımcıyı anar (`strings.csv:2160`) ve kurucunun "Kendine not"u olarak gelir (`rnd_system.gd:434-444`); tahmin toplantı payını saymaz (`weeks_estimate` `:189-194`) ama birikim sayar (`_accrue` `:118`) | §5.3 |
| S22 (yan pay, F4) | major | `team()` araştırmadakini düşer (`sprint_system.gd:398`); atama panelinde kurucu satırı yalnız görev adı (`rnd_assign_panel.gd:178-180`), alt bant sprintten söz etmez (`:190-218`) | §5.4 |
| S48 (yan pay, F4) | minor | Yıldız reddi yalnız "{area} {stars} gerekiyor." (`rnd_ui_shared.gd:138-141`, `strings.csv:2227`; `rnd_assign_panel.gd:211-217`), işe alım yolu yok | §5.4 |
| S02 | blocker | Hedef memnuniyet = kararlılık ekseni + `trust_offset` (`b2b_sales_system.gd:124-132`); tolerans 33 + yıldız başı 9 (+ sektör) (`b2b_constants.gd:29-42`), imzada tohumlanır (`sales_system.gd:350`); v1.0 kararlılık 0 ile çıkar, üç Güven K1'i ~32; run14'te 7.–10. hafta hesaplarının hepsi ~4 haftada gitti; `quality_model.gd:25-30` v1'de ham 17-20 varsayar (rev 7 öncesi) | §6.1–6.3 |
| S12 | major | `frank_intro` "mid" aday ekler (`frank_intro.json:28-30`) → 2★ (`sales_faucet_system.gd:30,256-257`); `p.source` yazılır (`:234`), okunmaz: toplantı katkıları (`sales_meeting_system.gd:131-172`) ve kart (`sales_tab.gd:256-278`) bilmez; Satış 0'da şans `ODDS_FLOOR` 0,05, açık cevap ≤ `CUT_LOW` 0,12 (`sales_constants.gd:75,97`) | §6.4 |
| S14 | major | `risk_reason` yalnız kesinti ya da "memnuniyet düşüyor" (`inbox.gd:194-196`, `strings.csv:118-119`); risk sesi entegrasyonu ima eder (`strings.csv:635`); kararlılığı Güven hatları besler (`sprint.json:49`) | §6.4 |
| S33 | major | `PROD_TYPE_ERP_TRADEOFF` "Bir kez kurulunca kimse çıkmaz" (`strings.csv:1059`, okuyan `type_picker.gd:48`), `PROD_PATH_B2B_DESC` "Her kontrat büyük para" (`:1082`) | §6.4 |
| S17 (tetik) | major | `launch_leak` kararlılık < 10 ve yayından 2–6 hafta (`launch_leak.json:16-43`); zamanında yayınlanan 4 koşunun 4'ünde geldi | §6.5 (yalnız ölçüm) |
| S39 (F12) | minor | Düşen VC çağrısı cezasız (ve F1 gereği sessiz) yeniden çalar: `_process` VC dalı yalnız `_end_call` (`main.gd:2991-2993`), rezervasyon durur (`vc_pitch_system.gd:756-765`), ceza yalnız `postpone_call`'da (`:771-778`); istenen satış görüşmesi "Gelen arama · {hour}:00" (`strings.csv:1788`, `meeting_invite.gd:167`) | §7 |

## 1. Kurallar

- `CLAUDE.md` bağlayıcı: §3 (main'e commit, push yok; **tasarım sabiti: önce tasarım notu, uygulama onaydan sonra**;
  TR metni "TR/EN onay bekliyor"; Frank satırı yalnız taslak; ACIK maddelerine dokunulmaz), §5 (önce EN, tire yok,
  ek yer tutucuya bitişmez), §7, §8 (yerini alan eskisini siler), §9 (her commit öncesi ayrı ajan incelemesi), §10
  (yeni smoke yalnız çekirdek mantık), §11 (görsel kabul, en çok 2 tur), §12 (kapı sırası).
- **Başlama kapısı:** SAAT K1–K10 main'de.
- **Ağaç paylaşımlı, B ve C koşuyor olabilir.** Her commit `git status --short` ile başlar. Kirli dosyada yalnız
  kendi hunk'ın `git apply --cached` ile stage edilir; kapılar `git checkout-index` ile kurulan geçici ağaçta koşar.
  `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak. Başkasının commit'lenmemiş işini commit'leme.
- **Sahiplik.** B ve C'nin §1 listelerindeki dosya ve hunk'lara bu PRD yalnız §10'daki sırayla ve ayrı hunk olarak
  dokunur. `main.gd`'de saat, hız, tutuş ve çağrı yolları A'nındır (bu oturum); B ve C yalnız harness kolu ekler.
- **CSV:** `localization/strings.csv` yalnız bu PRD'nin anahtarları, bayt-span ekleme ya da değer değiştirme; dosya
  yeniden yazılmaz; token `[a-z_]+`, iki dilde aynı; `PYTHONIOENCODING=utf-8`.
- **Smoke:** `scripts/debug/endgame_smoke.gd`'de yalnız §9'da adı geçen vakalar. Başka task'ın vakası kırılırsa bu
  oturum düzeltir ve raporlar.
- **Koşular:** ekransız her koşu `--headless`; pencereli koşular sırayla, önce `tasklist | grep -i godot`. Her koşu
  kendi `APPDATA`'sında (`export APPDATA=<geçici>/<etiket>/appdata`). OS düzeyinde fare/klavye yok. Alt ajanlar Opus
  ya da Sonnet. Ölçüm betikleri (awk) repoya girmez.
- **Onay kapıları:** §2.3 (S43 para tabanı), §4.2 (ACIK 60), §6.2–6.4'ün sabitleri onaysız uygulanmaz (dördü ACIK
  107'nin alt maddeleri). Onay beklerken sıradaki gruba geç; onay gelmezse grup ⚠️ "onay bekliyor" diye raporlanır.
  §11.7'nin tasarım kuralları uygulanır ve raporda ⚠️ "onay bekliyor" listelenir.

## 2. Grup B · İşe alım ve gider tuzakları (S18, S19, S20, S43, S44, S45, S21)

### 2.1 Ürünsüz işe alım "görev alıyor" demez (S18)
- **Nasıl:** `HRSystem.is_waiting(c)`: çalışan, işi var, ama her işi uykuda. Uyku: `build`/`test` → `not
  SprintSystem.is_typed()`; `support`/`accounts` → `not ProductState.is_live()`; `sales` → `not
  SalesFaucetSystem.market_open()` (bu dal onay bekliyor, §11.7). `is_idle` ve `idle_count()` değişmez (`hr.idle_count`
  seam'i "işi olmayan" der, `seams_hr.gd:130-132`). Yeni `HRSystem.waiting_count()`. Kadro'nun "Boşta" rozeti
  (`hr_ui_shared.gd:395`) `is_idle(emp) or is_waiting(emp)` okur; Görevler çipi (`hr_tab.gd:455`) `idle_count() +
  waiting_count()`. Ray rozeti (`left_tabs.gd:266` → `attention_count`) değişmez, `left_tabs.gd` AÇILIŞ'ındır.
  `_job_text` uykudaki işte `HR_TASK_WAITING_PRODUCT` (build/test) ya da
  `HR_TASK_WAITING_LIVE` (öbürleri) döner; `founder_task_label` (`hr_system.gd:218`) tür seçilmeden aynı
  anahtarı okur (Kişisel `personal_tab.gd:89` buradan). CS kilidi geri gelmez (`endgame_smoke.gd:3820-3848` hükmü).
- **Kabul:** yeni `--hr-shot=urunsuz` (tür seçilmemiş, bir Geliştirici ve bir Müşteri Temsilcisi işe alınmış) TR/EN:
  iki satırda bekleme cümlesi ve "Boşta"; satır `HRSHOT|urunsuz|idle=0|waiting=2`. Tür seçilince aynı fikstürde
  Geliştirici "Yapımda" okunur (`waiting=1`, temsilci canlı ürün bekler). Smoke `job_assignment_and_idle` (değişmeden),
  `hr_active_filters`, `hr_overload_badge`, `hires_land_in_own_column`, `hr_search_cycle` yeşil.

### 2.2 Atlas: seviyede fiyat, gelir öncesi tehlike, onay, devralınan mesai (S19, S20)
- **Seviye adımı:** her seviye kartının altında `HR_ATLAS_LEVEL_BAND` (`HRConstants.salary_band_for_level`,
  `hr_constants.gd:601`; komisyon `commission_for` `:814-815` bandın iki ucu için). `preview_search` bandı döner;
  `hr_atlas_modal.gd:12-14` yorumu yeni kurala göre yazılır ("arama ücretsiz; fiyat seviyede okunur, komisyon
  işe alımda ödenir").
- **Önizleme mesaiyi sayar:** `WorkHoursSystem.hours_for_role(role_id)` (yeni; `hours_for`'un `_resolve` yolu, grup
  `HRConstants.ROLE_GROUP[role]`). `preview_hire` `burn_after`'a `HRConstants.overtime_pay_for_day(salary, h)`
  ekler; çıktıya `hours`, `burn_after` ve aylık `overtime` girer. Dosya kartı runway satırının üstünde `HR_ATLAS_INHERITED_HOURS`
  (yalnız h > 8).
- **Tehlike ve onay:** `runway_after < FinanceSystem.RUNWAY_ALERT_MONTHS[0]` (3, `finance_system.gd:83`; yeni sabit
  yok) ya da `GameState.mrr == 0` ise: uyarılara `HR_WARN_NO_REVENUE` (mrr 0 iken), runway satırı `D_neg()`
  mürekkebi, "İşe al" `EventBus.confirm_requested` açar (`HR_HIRE_CONFIRM_TITLE/_BODY`: maaş, komisyon, runway
  önce → sonra, mesai dahil); onayda `hire()`. Öbür durumda tek tık kalır.
- **Kabul:** yeni smoke `hire_preview_counts_inherited_overtime` (ekonomi): şirket saati 15, junior geliştirici;
  `pv := preview_hire(...)`, `hire()` + `FinanceSystem.daily_tick()`, sonra `abs(pv.burn_after - GameState.daily_burn)
  ≤ 1` (runway karşılaştırılmaz: tik bir haftalık burn'ü kasadan düşer, `finance_system.gd:142-153`, fark ~7/30 ay);
  falsifikasyon: mesai terimi silinince vaka düşer. Görsel TR/EN: `--hr-shot=atlas-secili` (bant
  satırları), yeni `dosyalar-tehlike` (mrr 0, kasa $10.000, Kıdemli dosya seçili: kırmızı runway, uyarı), yeni
  `dosyalar-onay` (aynısı, onay penceresi açık), yeni `dosyalar-mesai` (şirket 15 saat: devralınan saat satırı). Smoke
  `hr_search_cycle`, `role_locks_and_runway_pair`, `runway_net_status` yeşil.

### 2.3 Tek para tabanı (S43; onay bekliyor)
- **Tasarım notu (ACIK 107(b), O11'de yazılır):** `overtime_pay_for_day` takvim günü oranına çevrilir:
  `round(hourly_wage(s) × extra × OVERTIME_WAGE_MULT × (HOURS_PER_MONTH / WORK_HOURS_DEFAULT) / TimeModel.DAYS_PER_MONTH)`
  (22/30; yeni sabit yok, türetilir). TopBar, modal ve finans ×30'u olduğu gibi kalır, ay kuralla tutar. Etki
  run_h15: $4.920 → ~$3.609/ay. Kurucunun mesaisi bedelsiz kalır (B-K8, ACIK 106; bu PRD değiştirmez).
- **Onaydan sonra kabul:** `hr_constants_contract`'a assert: maaş 3.000, 15 saat → `overtime_pay_for_day × 30`
  = `round(3000/176 × 7 × 1,5 × 22)` ± 30. İki mevcut assert eski günlük formülü sınar ve aynı commit'te
  `× (HOURS_PER_MONTH / WORK_HOURS_DEFAULT) / TimeModel.DAYS_PER_MONTH` biçimine yeniden yazılır:
  `hr_constants_contract` (`endgame_smoke.gd:7033-7038`, `hourly × over × 1,5`) ve `work_hours_three_scopes`
  (`:10200`, `hourly × 3 × 1,5`); raporda "genişleyen vakaların falsifikasyonu" altında. `work_hours_draft_commits`,
  `burn_refresh_same_tick`, §2.2'nin vakası yeşil; `run_gate.sh` 3/3 ve fark raporu (mesai kalemi düşer; taban O17'nin
  ebeveyn ağacı, `git checkout-index` ile aynı koşuda).

### 2.4 Kopya: kimin saati, hangi ay (S44, S45)
- S44: motor değişmez (kurucuya özel çarpan `sprint_system.gd` ister, B'nin dosyası; §11). Gövdenin son cümlesi ve
  `EFFECT_SPRINT_HOURS` "ekibin saati" der (§8).
- S45: `MONTH_CLOSED_TICKER` "takvim ayında nakit" der (§8). TopBar'a dokunulmaz (SAAT ve AÇILIŞ'ın).
- **Kabul:** loc kapıları; `--event-shot=founder.side_contract` TR/EN; `--day-shot=home:1` ay kapanış satırı TR.

### 2.5 B sonrası Ekip satırları (S43 notu, S21)
- S43 notu: `HR_HOURS_INHERIT_NOTE` şirket satırının altında, B'nin `HR_HOURS_SPRINT_POINTS` satırından sonra
  (`work_hours_modal.gd`; **SPRINT commit 9 main'de**, ayrı hunk).
- S21 boş hâl: yalnız `product_design` ve `development` gruplarının boş satırının altına `HR_EMPTY_ADDS`
  (`hr_tab.gd:414-416`; satış ve CS rolleri sprint rolü tutmaz, `sprint.json:18` `role_areas`, `_fits`
  `sprint_system.gd:932-936`; o iki grup yalnız `HR_EMPTY_ROW`). `{pts}` = `person_points_week`, `{money}` grubun
  rollerinin junior bandı alt uçlarının en küçüğü (`SALARY_BANDS_BY_LEVEL`). Şimdi yapılabilir.
- S21 dosya kartı: `HR_ATLAS_WEEK_POINTS` "Sprintte haftada {pts} puan" için `SprintSystem.points_for(role_id,
  role_stats, hours) = person_points_week × beceri bandı × hours_output_mult(hours)` (kişisiz; verim yok); B'nin S9
  imzasıyla `_points(c, hours) = points_for(c.role, c.role_stats, hours) × productivity(c)`, kurucu dalı `_points`'te
  kalır, kopya yok. Saat `WorkHoursSystem.hours_for_role(role_id)` (§2.2). **SPRINT commit 9 (imza) ve 11 main'de**,
  B'nin imzası üstüne ayrı hunk.
- **Kabul:** `--hr-shot=saatler` ve B'nin `saatler-sprint` TR/EN (not satırı, taşma yok); `--hr-shot=bos` (boş hâl
  satırı yalnız iki grupta); `--hr-shot=dosyalar` (orta seviye, 8 saat: Dengeli 2,0, Uzman ve Pazarlık 2,5 puan/hafta;
  `hr_constants.gd:626`, `sprint.json:19-20`); `--hr-shot=dosyalar-mesai` (şirket 15 saat) puan
  `hours_output_mult(15)` = 1,4375 ile çarpılmış (O16 bu türe puan satırı kabulünü ekler).

## 3. Grup C · Satış penceresi: PH ve yanlış satırlar (S13, S32)

### 3.1 PH MVP ve kapı (S13)
- **Kapsam:** ilk 15 haftada ekrana çıkabilen "PH:" satırları; hepsi ilk B2B toplantısında ya da aday kartında
  erişilir, bu yüzden hepsi. 55 anahtar (`strings.csv:2353-2406,2420`; aday kartı `sales_tab.gd:278`, toplantı
  `sales_meeting_adapter.gd:148-172,253-255`), her biri adıyla:
  `SALES_ARCH_OPS_CAUTIOUS_LINE, SALES_ARCH_TECH_EXACTING_LINE, SALES_ARCH_FINANCE_BRISK_LINE,
  SALES_PROBE_PROBE_STABILITY_RECORD, SALES_PROBE_PROBE_STABILITY_BUGS, SALES_PROBE_PROBE_LADDER_REACH,
  SALES_PROBE_PROBE_LADDER_LOCKED, SALES_PROBE_PROBE_PROVIDER_TRUST, SALES_PROBE_PROBE_WHO_DO_I_CALL,
  SALES_PROBE_PROBE_SWITCHING_RISK, SALES_PROBE_PROBE_CAPACITY, SALES_INNER_VOICE_0, SALES_INNER_VOICE_1,
  SALES_INNER_VOICE_2, SALES_WIN_CUT, SALES_LOSS_STABILITY, SALES_LOSS_MISSING_TIER, SALES_LOSS_PROVIDER_TRUST,
  SALES_LOSS_PRICE, SALES_LOSS_SWITCHING_RISK, SALES_MEMORY_STABILITY, SALES_MEMORY_MISSING_TIER,
  SALES_MEMORY_PROVIDER_TRUST, SALES_MEMORY_PRICE, SALES_MEMORY_SWITCHING_RISK, SALES_LOCK_AXIS_STABILITY,
  SALES_LOCK_STEPS_SHIPPED, SALES_LOCK_PROVIDER, SALES_LOCK_CS_STAFFED, SALES_LOCK_AXIS_EXPERIENCE,
  SALES_LOCK_OPEN_PITCH_PROMISE, SALES_ANS_PROBE_STABILITY_RECORD_A_STRENGTH, SALES_ANS_PROBE_STABILITY_RECORD_A_ADMIT,
  SALES_ANS_PROBE_STABILITY_RECORD_A_CHARISMA, SALES_ANS_PROBE_STABILITY_BUGS_A_ADMIT,
  SALES_ANS_PROBE_STABILITY_BUGS_A_PROMISE, SALES_ANS_PROBE_STABILITY_BUGS_A_REFERENCE,
  SALES_ANS_PROBE_LADDER_REACH_A_STRENGTH, SALES_ANS_PROBE_LADDER_REACH_A_ADMIT, SALES_ANS_PROBE_LADDER_REACH_A_PROMISE,
  SALES_ANS_PROBE_LADDER_LOCKED_A_ADMIT, SALES_ANS_PROBE_LADDER_LOCKED_A_PROMISE, SALES_ANS_PROBE_LADDER_LOCKED_A_CHARISMA,
  SALES_ANS_PROBE_PROVIDER_TRUST_A_STRENGTH, SALES_ANS_PROBE_PROVIDER_TRUST_A_ADMIT,
  SALES_ANS_PROBE_PROVIDER_TRUST_A_REFERENCE, SALES_ANS_PROBE_WHO_DO_I_CALL_A_STRENGTH,
  SALES_ANS_PROBE_WHO_DO_I_CALL_A_ADMIT, SALES_ANS_PROBE_WHO_DO_I_CALL_A_CHARISMA,
  SALES_ANS_PROBE_SWITCHING_RISK_A_STRENGTH, SALES_ANS_PROBE_SWITCHING_RISK_A_ADMIT,
  SALES_ANS_PROBE_SWITCHING_RISK_A_PROMISE, SALES_ANS_PROBE_CAPACITY_A_ADMIT, SALES_ANS_PROBE_CAPACITY_A_PROMISE,
  HR_FOUNDER_STATE_CARE`.
- `price_break.json:70-83` (başlık, gövde, iki seçenek, iki dil, id `sales.price_break`): bağsız (`SalesRepSystem`
  `EventGate.request` çağırmaz, `sales_rep_system.gd:204-205`; `_doc` aynısını der), ekrana çıkmaz. Kapsamda yalnız
  `loc_no_placeholder_text` kapısı `data/events/cards/**`'u taradığı için; metni TR/EN onay bekliyor.
- **Nasıl:** her satır EN önce gözden geçirilir (CLAUDE §5: gözlem, hüküm yok; kilit gerekçesi kendi bilgeliğini
  söylemez; tire yok), yanlış olgu düzeltilir, "PH: " öneki kalkar; değer yerinde değişir (bayt-span). K31'in kalanı
  (~150 satırlık toplantı sesi) ayrı yazım task'ıdır, ACIK K31 açık kalır. `sales_probes.gd:18-20` yorumu bugünkü
  nedene göre yazılır.
- **Kapı:** `loc_sales_derived_keys`'in `:15337-15344` kuyruğu silinir (PH şartı); yeni vaka `loc_no_placeholder_text`:
  CSV'nin her değeri ve `data/events/cards/**` metinleri (`_fixtures/` hariç) TR ve EN'de `^PH:` ile başlamaz;
  bulursa anahtar ya da dosya adıyla FAIL. Falsifikasyon: bir satıra "PH: " geri eklenince vaka düşer.
- **Kabul:** `grep -c ',"\?PH:' localization/strings.csv` = 0; lint; loc kapıları; smoke `loc_no_placeholder_text`,
  `loc_sales_derived_keys`, `sales_inner_voice_reaches_view`, `sales_presentation_rules`; `--meeting-shot=probe`,
  `=locked`, `=lost` ve `--sales-shot=pipeline` TR/EN; `--event-shot=sales.price_break` TR/EN. Commit mesajı
  "TR/EN onay bekliyor" ve satır listesi.

### 3.2 Kayıp gerekçesi sorulan aileden (S13)
- **Nasıl:** `_derive_loss_reason` sırası aynı kalır (kararlılık → sağlayıcı → kademe → geçiş → fiyat), ama bir dal
  yalnız ailesi `_used_families`'teyse seçilebilir: `stability` → STABILITY, `provider` → PROVIDER_TRUST, `ladder` →
  MISSING_TIER, `support`/`switching` → SWITCHING_RISK. Hiçbir sorulan aile karşılanmamışsa `LOSS_PRICE` (fiyat
  her masada açıktır, `sales_meeting_system.gd:150-154`; bu geri düşüş onay bekliyor, §11.7). `_loss_target` aynı
  dalı okur.
- **Kabul:** yeni smoke `sales_loss_reason_from_asked` (toplantı motoru): kararlılık 0, yalnız `switching` sorulmuş
  masa → SWITCHING_RISK (CS yoksa) ya da PRICE; `stability` sorulmuş masa → STABILITY; falsifikasyon: aile süzgeci
  silinince ilk assert düşer. `sales_meeting_replays_identically`, `b2b_pitch_meeting_signs` yeşil;
  `--meeting-shot=lost` TR/EN: hafıza satırı sorulan konuyu anar.

### 3.3 Yönlendirme ve koltuk fiyatı (S32)
- **Nasıl:** "Temsilciye ver" yalnız `out_of_band_reason(rep, p) == ""` olan bir temsilci varsa açık; yoksa kapalı
  ve gerekçe satırı `SALES_ROUTE_NO_REP` ya da bandın üstündeyse mevcut `SALES_BAND_ABOVE_REP` (`strings.csv:2305`).
  `SalesLedger.set_routing` (tek yazma kapısı) aynı denetimle reddeder. `--sales-shot=edge` bugün temsilcisiz
  `ROUTE_REP` yazar (`main.gd:927-928`; temsilci bloğu `:904` `edge`'i almaz): `edge` o listeye girer, böylece
  `leads[1]` kapıdan geçer ve çerçevenin "Temsilciye" etiketi kalır; değişen çerçeve raporda. Hesap
  satırında koltuk fiyatı `round(mrr / seats)` (seats > 0); damga (`seat_price`) büyüme için kalır.
- **Sıra:** `sales_tab.gd` hunk'ları (`_lead_card` yönlendirme satırı, `_meta_line`) **SPRINT commit 8 main'de**
  (B o dosyanın B2C ve boş hâl dallarını yazar).
- **Kabul:** smoke `sales_rep_selection_rule`, `sales_lead_expiry_and_return_lock`, `sales_seat_price_stamp_and_expansion`,
  `sales_autonomous_close_routine` (`endgame_smoke.gd:7465`), `sales_concession_deal_surfaces` (`:7580`) yeşil;
  `--sales-shot=edge` TR/EN (temsilci satırı, "Temsilciye" etiketi); yeni `--sales-shot=norep` (aday var, temsilci
  yok: düğme kapalı, gerekçe) ve `=discounted` (indirimli hesap: koltuk × fiyat = mrr ± koltuk sayısı) TR/EN.

## 4. Grup D · Ofis kartı (S55, S42 payı, S23 payı, S24)

### 4.1 Kopya, tazelik, çek satırı (S55, S42, S23)
- S55 (adaylar "kademe sözcüğü alsın ya da kalksın" der; "kalksın" seçimi onay bekliyor, §11.7): Ev kartında
  kademe etiketi çizilmez (`office_map_card.gd:44`, `office_id == "home"`); `OFFICE_TIER_HOME`
  okuyanı kalmazsa silinir (`office_constants.gd:17` alanı da). `OFFICE_REQ_CASH` "Kasada en az {money}".
- S42: `office_city.gd` açıkken `EventBus.day_tick_completed`'a abone olur ve kartı yeniden kurar (`_rebuild_controls`
  yolu; seçim ve kamera kalır). Haritayı açmak saati tutmaz (SAAT'in kuralı değişmez).
- S23 (**AÇILIŞ C1 ve C3 main'de**): İş hanı kartının "angel" satırı çek listesi açıkken `ChequeRead.summary()`'den
  `GOAL_TOAST`'un biçimiyle "Frank'in çeki · 2/5" okur (`CHEQUE_TITLE`, `GOAL_TOAST` AÇILIŞ'ın anahtarları, yalnız
  okunur; `cheque_read.gd` `preload`, `class_name` yok). `office_hud.gd` "Ofisi taşı" düğmesinin altına
  `run_angel_amount == 0` iken `OFFICE_MOVE_AFTER_CHEQUE`.
- **Kabul:** `office_move_gates_and_save` yeşil; `--office-shot=city:11:card` (Plaza) ve yeni ekler `card_ishani`
  (İş hanı: "en az", çek satırı), `card_home` (kademe yok), `card_tick` (kart açık, bir günlük tik; satır
  `OFFICECARD|cash_now_before=|after=` iki değeri farklı ve ekrandaki ile aynı) TR/EN; `--office-shot=home:11`
  düğme notu TR/EN.

### 4.2 ACIK 60 · C (varsayılan öneri, onay bekliyor)
- **Öneri C:** taşınma bedelsiz kalır; kartın KİRA/AY ve TAŞINMA hücreleri, `OFFICE_CARD_MOVE_NOTE/_FREE` satırı ve
  CTA'daki tutar kalkar (CTA `OFFICE_CARD_MOVE_GO`); hover yalnız masa sayısı. Okuyanı kalmayan anahtarlar
  (`OFFICE_CARD_RENT`, `_MOVE`, `_MOVE_NOTE`, `_MOVE_FREE`, `_MOVE_FOR`) ve `CATALOG`'un `rent/deposit/move_cost`
  alanları (okuyan kalmazsa) silinir; kasa şartı kapı olarak kalır. **Alternatif A:** depozito + nakliye
  `FinanceSystem.apply_one_time_cost`, kira aylık "office" kalemi; sayılar kalibrasyonla; bu PRD'de uygulanmaz,
  seçilirse ayrı tasarım notu.
- Masa ve oda hapları (S24'ün ikinci yarısı, ACIK 64) bu PRD'de değişmez: §11.
- **Kabul (onaydan sonra):** `--office-shot=city:11:card` ve `card_ishani` TR/EN'de para hücresi yok, CTA "Buraya
  taşın"; hover karesi; `grep -rn "OFFICE_CARD_RENT\|OFFICE_CARD_MOVE_FOR" scripts scenes` boş; ACIK 60 sahip onayıyla
  kapanır (onay metni commit mesajında).

## 5. Grup E · Ürün/Ar-Ge artıkları (S16, S34, S49, S22 yan, S48 yan)

### 5.1 DESTEK dürüst (S16)
- `fix_run_refusal`'da `DESK_SHUT` denetimi `NO_BUGS`'tan önce (`support_system.gd:296-299`); kart böylece "Kimse
  üzerinde değil." der (`build_bar_model.gd:18`, `strings.csv:478`). Model `incoming = ProductState.reports_incoming()`
  taşır, kart `BUILD_SUPPORT_INCOMING` satırını Doğrulanmış'ın yanında çizer; `build_bar.gd:145` yorumu silinir.
  `support_overflow`'u B2C'ye açmak kapsam dışı (§11).
- **Kabul:** `destek_empty_desk_piles_up`'a assert (masa kapalı, 0 doğrulanmış → `REFUSAL_DESK_SHUT`),
  `fix_run_ships_subset` (masa dolu, 0 hata → `NO_BUGS` kalır), `destek_survives_ship` yeşil; yeni
  `--office-shot=home:11:desk_shut` (B2C canlı, kurucu yapımda, gelen 12) TR/EN.

### 5.2 Donmuş araştırma: vazgeç ve doğru neden (S34)
- `RnDSystem.abandon()`: `_active` boşalır, düğüm `STATE_REVEALED`'a döner, `_progress` ve `_paid` kalır (yeniden
  başlatmada nakit ikinci kez düşmez; bu ekonomi kuralı onay bekliyor, §11.7), `emit_edges()`; rozet düşer. Düğme `RND_ABANDON` donmuş araştırmanın kartında
  ve ayrıntı panelinde, `RND_ABANDON_NOTE` ile.
- `_displace_job(c, job_id, incoming: String)`: bugün yalnız yerinden edilen işi (araştırma) alır
  (`character_registry.gd:210-221`, çağrı `:221`), gelen işi bilmez. `:221` `_displace_job(c, d, job_id)` olur;
  neden `incoming`'den: `JOB_BUILD` → `RND_PAUSED_BUILD`, öbürleri `RND_PAUSED_JOB` (`{job}` =
  `HRConstants.job_label(incoming)`). `research_occupies_person` (`endgame_smoke.gd:13730` `_displace_job`'u anar) koşar.
- **Kabul:** yeni smoke `research_abandon_keeps_progress` (Ar-Ge ekonomisi): dondur → `attention_count` 1 → vazgeç → 0;
  aynı düğüm yeniden başlatılınca ilerleme aynı, kasa ikinci kez düşmez; falsifikasyon: `_paid` silinince düşer.
  `research_freezes_and_resumes`, `research_and_build_pause_each_other` yeşil. `--rnd-shot=frozen`, `=card_frozen`
  TR/EN (düğme, not).

### 5.3 Keşif notu ve tahmin (S49)
- `PROD_RND_NODE_DESIGN_SYSTEM_DISCOVERY` yazarsız cümle (§8). `weeks_estimate` kurucu seçiliyse
  `1.0 - GameState.founder_meeting_share()` ile hesaplar (`_accrue`'nun girdisi; aynı fonksiyon, kopya yok).
- **Kabul:** `research_occupies_person`'a assert: kurucu toplantı payı 0,2 iken tahmin, `_accrue` ile ölçülen haftayla
  ±1 tik; `rnd_note_author_and_lines` yeşil; yeni `--rnd-shot=discovery_design` TR/EN (`=discovery` 16. haftada
  `test_automation`'ı bitirir, `main.gd:1531`; `design_system` 8. hafta geçmişindedir, `:1511`): yeni tür
  `RnDSystem._complete("design_system")` ile keşfi bildirim yığınına koyar, `PROD_RND_NODE_DESIGN_SYSTEM_DISCOVERY` okunur.

### 5.4 Atama uyarısı ve işe alım işareti (S22 yan, S48 yan)
- **Sıra:** SPRINT commit 10 (Ürün→Ar-Ge yolu, `PRODUCT_TEAM_IN_RND`) main'de; metinler onunla tutarlı.
- Atama panelinde kurucu işaretli ve `SprintSystem.mode() == "active"` ya da `"plan"` ise alt bantta
  `RND_FOUNDER_LEAVES_SPRINT` (`D_warn`), Başlat açık kalır.
- Yıldız reddinde (`REFUSE_STARS`) gerekçe satırının yanında `RND_HIRE_FOR_STARS` bağlantısı:
  `EventBus.tab_changed.emit("hr")` (Atlas'ı açmak yok; Ekip penceresi). Yalnız eksik alanın sahibi kadroda yoksa.
- **Kabul:** yeni `--rnd-shot=assign_founder` (sprint aktif, kurucu işaretli) ve `=stars` (Tasarım ★1 eksik, bağlantı)
  TR/EN; MCP: bağlantı Ekip'i açar.

## 6. Grup A · B2B ilk müşteri ekonomisi (S02, S12, S14, S33, S17 tetik)

**Başlama:** SPRINT commit 1–11 main'de (artık puan S1 ve MVP kapısı S5 v1.0'ın eksenlerini değiştirir; ölçüm B'nin
motoru üstünde). Sıra: **ölç → tasarım notu → onay → uygula → yeniden ölç**. Onay beklerken §7'ye geç.

### 6.1 Önce ölçümü
- Üç run_gate preset'i: `bash tools/run_gate.sh` (gün, son, hata) ve aynı preset'ler `--run-log=<p>:730:sim`.
- **20 tohumlu B2B probe:** `for s in $(seq 1 20); do "$GODOT" --headless --path . --run-log=full_run:40:sim:$s
  --lang=tr; done` (her koşu kendi `APPDATA`'sı). Satırlar `PROBE CUST` (`run_probe.gd:471`), `PROBE CHURN` (`:406`),
  `PROBE SHIP` (`:258`), `PROBE END` (`:716`, `seed_day`, `finite_runway_p2`).
- Metrikler (awk, repoya girmez): **M1** ilk imzalanan hesabın yaşadığı hafta (40'a kadar sağsa "40+"); **M2** 7.–14.
  haftada imzalanıp 12 hafta sonra hâlâ hesapta olanların payı; **M3** imzadan sonraki 8 haftada churn eden pay; **M4**
  v1.0 yayınındaki `stability` (SHIP satırı) ve imzadaki `target`/`tol`; **M5** `seed_day`, `min_cash_pre_seed`,
  son, ACIK 98'in `finite_runway_p2` payı; **M6** üç run_gate koşusunun günü ve sonu.
- **Önce/sonra tabanı:** §6.3 kabulündeki "önce" = O19'un ebeveyn ağacı, "sonra" = O19; ikisi de `git checkout-index`
  ile kurulan geçici ağaçta ve aynı koşuda (arada O17 ve AÇILIŞ C2/C12/C15 burn'ü ve olay akışını değiştirebilir).
  O11 tablosu yalnız tasarım notunun girdisidir, kabul tabanı değildir.
- S17 tetik: `full_run_b2c`, tohum 1–8, 120 hafta; `PROBE FIRE id=product.launch_leak` sayısı ve günü, aynı koşuda
  `funding.gate_traction` günü (S26, AÇILIŞ §7.4). Yalnız rapor.

### 6.2 Tasarım notu (ACIK 107 "Onarım 1 sahip kararları", O11 commit'i; uygulama yok)
- Tek madde, dört alt madde: (a) S02 mekanizması (aşağıda), (b) S43 para tabanı (§2.3), (c) ACIK 60 C/A (§4.2),
  (d) S12 sabiti. Numara: SAAT 105, SPRINT 106 (commit 11) aldıktan sonra dosya sonundaki ilk boş numara (107).
- **Önerilen mekanizma · onboarding taban:** imzadan sonraki `ONBOARDING_GRACE_WEEKS` [ÇALIŞMA] 8 hafta boyunca
  sağlık hedefi `max(health, c.tolerance + ONBOARDING_GRACE_MARGIN)` [ÇALIŞMA] 2 olur; `trust_offset` tabandan
  SONRA eklenir (kırık söz pencerede de ısırır). Pencere `c.acquired_on_day + TimeModel.ticks(N)` (kayıt değişmez;
  `acquired_on_day` `sales_system.gd:345`). `ONBOARDING_WEEKS` 4 (salınım katı) ayrı kalır. Yer:
  `b2b_sales_system.gd:124-132` ve `b2b_constants.gd`.
- **Alternatif · toleransı rev 7 eksenlerine oturtma:** `TOLERANCE_BASE/PER_SCALE` M4'ün ölçülen v1 kararlılığına göre
  yeniden; `b2b_v1_lands_mid_band`'in `CAL_V1_*` sabitleri ve `quality_model.gd:25-30` yorumu birlikte değişir
  (Kalibrasyon A'nın dört parçalı kararı). Not iki yolun M1–M3 tahminini ve riskini yazar.
- (d) S12 sabiti `WARM_INTRO_MISMATCH_MULT` [ÇALIŞMA] 0,5 (§6.4) ve ölçümü; §6.1 tablosu.
- Commit: "Belgeler: Onarım 1 tasarım notu ACIK 107 (onay bekliyor)". Sonra **dur**, sahibe sor.

### 6.3 Uygulama (onaydan sonra)
- Onaylanan mekanizma; sabitler `[ÇALIŞMA]` yorumuyla `b2b_constants.gd`'de. `_satisfaction_target`'in açık
  sarmalayıcısı `static func satisfaction_target(c)` (`b2b_sales_system.gd:124-132`); `run_probe.gd` `_log_customers`
  hedefi satır içinde yeniden hesaplar (`:466,471-474`) ve onu çağırır, yoksa "sonra" M4 tablosu eski hedefi basar.
- Yeni smoke `b2b_onboarding_grace_floor` (ekonomi): kararlılık 0 ürün, 2★ hesap; pencerede `satisfaction ≥
  tolerance` ve `lifecycle_phase != "risk"`; N+1. haftadan sonra hedef `health + trust_offset`'e iner; kırık söz
  pencerede hedefi düşürür. Falsifikasyon: taban satırı silinince ilk assert düşer.
- Kırılabilecek vakalar (fikstür imzayı "bugün" yapıyorsa `acquired_on_day`'i geçmişe alır, iddiayı değiştirmez):
  `b2b_lifecycle_and_countdown`, `b2b_ignore_then_churn`, `b2b_retention_routes_seams`, `retention_gate_shared`,
  `b2b_promise_broken_on_deadline`, `b2b_cs_escalation_refuse`, `meeting_during_kepenk`, `b2b_v1_lands_mid_band`.
  Probe fikstürleri `b2b_risk`/`b2b_slip` (`run_probe.gd:1512-1534`) aynı biçimde; SPRINT'in `run_probe.gd` hunk'larına
  dokunulmaz, değişiklik `_seed_b2b_world`/`_seed_stability_fixture` ve `_log_customers` içinde ayrı hunk'lar.
- **Kabul (onay bekliyor değerleri):** M2 ≥ %60, M3 ≤ %20, pencere sonrası 8 haftada churn > 0 (B2B
  ölümsüz olmaz); run_gate 3/3, sonlar ve günler fark raporunda; M5 seed günü ve `finite_runway_p2` önce/sonra
  (ACIK 97/98 ile aynı set).

### 6.4 Kopya ve sıcak tanıştırma (S14, S33, S12)
- S14: `risk_reason` (`inbox.gd:194-196`) kesinti değilse ve hesabın `trust_offset >= 0` ise `SALES_REASON_STABILITY`,
  değilse `SALES_REASON_SATISFACTION` (`trust_offset` ayrımı onay bekliyor, §11.7); bunun için `risk_reason(c)` müşteri
  alır, iki çağıran (`inbox.gd:114`, `desk()` içinde; `sales_tab.gd:468`) hesabı verir. Lider önerisi değişmez (§11).
  Sıra: AÇILIŞ C2, C3, C11, C14 (`desk()`, `_history_item`, `show()`) ve SPRINT 8 (`sales_tab.gd`) main'de.
- S33: `PROD_TYPE_ERP_TRADEOFF`, `PROD_PATH_B2B_DESC` (§8; kod değişmez).
- S12: `_build_base_contributions` `p.source == "frank_intro"` ise yıldız uyumsuzluk cezasını
  `WARM_INTRO_MISMATCH_MULT` ile çarpar ve hover'a `"sales.warm_intro"` satırı koyar (karizma deseni `:163-165`;
  etiket `SALES_MOD_WARM_INTRO` `_modifier_labels`'a; `sales_meeting_adapter.gd:28-37` `CHIP_BY_SEAM`'e
  `"sales.warm_intro": "MEETING_CHIP_ROOM"`, yoksa çip kategorisiz kalır). Aday kartında `SALES_TAG_FRANK_INTRO` etiketi ve liste başı
  (`sales_tab.gd` `_lead_card`; **SPRINT commit 8 main'de**, ayrı hunk). Frank'in `FRANK_ADVISORY_MEETING_SET`
  satırına şirket adı: yalnız taslak, §11.
- **Kabul:** yeni `--sales-shot=frank` (Satış 0 kurucu, Frank'in adayı başta, etiketli) TR/EN; yeni
  `--meeting-shot=frank` (aday `source = "frank_intro"`, Satış 0; `MEETINGSHOT|frank|mods=<seam listesi>` basar,
  liste `sales.warm_intro` içerir; falsifikasyon: çarpan 1,0 iken satır yok). Hover OS faresi ister, kareden
  okunmaz (`probe` fikstürünün adayı Frank'in değil, `main.gd:2656-2660`). Smoke `sales_loss_reason_from_asked`
  genişler: Satış 0 kurucu, Frank'in 2★ masası, en iyi açık cevap yolu → iğne ≥ `CUT_LOW` (zar atılır);
  falsifikasyon: çarpan 1,0 iken düşer. Yeni `--sales-shot=risk_stability` (`_run_sales_shot` `:891`'in 12 hatasını
  ≤ `COMPLAINT_BUG_GATE` 6'ya indirir, `co_ege` risk ve `trust_offset` 0; ikinci hesap negatif `trust_offset`):
  TR/EN satırlar `SALES_REASON_STABILITY` ve `SALES_REASON_SATISFACTION`. `edge` bunu gösteremez: risk hesabı yalnız
  `elif` dalında (`main.gd:937-939`), 12 hata kesinti nedenini zorlar (`inbox.gd:195`).

### 6.5 S17 tetiği (yalnız ölçüm)
§6.1'in S17 satırları B'den sonra ve §6.3'ten sonra yan yana raporlanır. Uyarı yayma (`product_read.gd:111-114,173`)
ve `launch_leak` gövdesi sahipsiz kalır (§11).

## 7. S39 artıkları (F12)

- **VC'de cevapsız çağrı = erteleme bedeli:** `VCPitchSystem.lapse_call()`: rezervasyonu `MEETING_LEAD_WEEKS` ileri
  alır ve `MEETING_RESCHEDULE_PENALTY`'yi yazar (`_add_move_penalty`, `vc_pitch_system.gd:771-778` deseni); ilk
  düşüşte `postponed = true` olur, sonraki düşüşler de aynı cezayı öder (bedava yeniden arama yok). Koruma
  `postpone_call`'ınki DEĞİL: o `call_waiting() == ""` iken false döner (`:771-773`) ve çağrıyı bitiren koşul tam
  odur (`main.gd:2992-2993`). Koruma: `not pm.is_empty() and int(pm.day) <= GameState.day and not _active`.
  `main.gd` `_process` VC dalı (`:2991-2993`) `pending_meeting` duruyorsa önce `lapse_call()`, sonra `_end_call()`;
  **tost yok** (F1: VC dalı sessiz kalır; bedel görüşmede `VC_WHY_MOVED` satırı olarak görünür,
  `vc_pitch_system.gd:100-101,200-202`). Satış dalına dokunulmaz. Mevcut `MEETING_POSTPONED_VC` ("Bir daha
  ertelenemez", `strings.csv:1797`) tekrarlanan düşüşte yanlış olur; tost yok (hüküm F13: VC dalı sessiz, bedel `VC_WHY_MOVED` ile görünür).
- **İstenen görüşme:** satış çağrısının künyesi `MEETING_INVITE_KICKER_ASKED`; `ring(spec)` `spec.kind` taşır,
  `meeting_invite.gd:167` VC'de `MEETING_INVITE_KICKER`'ı (fon arıyor) korur. VC'nin de "istenen" sayılması §11.
- **Kabul:** `vc_call_postpones_once`'a bacak: ikinci çalıştan sonra saat `call_waiting() == ""` olana dek ilerler,
  `lapse_call()` çağrılır → `move_penalty` + `MEETING_RESCHEDULE_PENALTY` ve `pm.day == bugün +
  ticks(MEETING_LEAD_WEEKS)`; falsifikasyon: `lapse_call`'dan `_add_move_penalty` satırı silinince bacak düşer (vaka
  statiktir, `main.gd` `_process`'i koşmaz). `main.gd` kablosunu yeni `--invite-shot=lapse_vc` kanıtlar:
  `INVITESHOT|lapse_vc|penalty=2`, tost karesi yok (falsifikasyon: çağrı silinince `penalty=0`). Künye
  `--invite-shot=card` TR/EN ("İstenen görüşme · 11:00"; `ring`'de kart kapalı, `_kicker` kartın çocuğu,
  `main.gd:1305-1306`, `meeting_invite.gd:64-66`), `=vc` (değişmedi).

## 8. Metinler (TR/EN onay bekliyor; EN önce)

| Anahtar | EN | TR |
|---|---|---|
| `HR_TASK_WAITING_PRODUCT` / `_LIVE` | No product to build yet / No live product yet | Henüz yapılacak ürün yok / Henüz canlı ürün yok |
| `HR_ATLAS_LEVEL_BAND` | Monthly {min} to {max} · commission {fee_min} to {fee_max} | Aylık {min} ile {max} arası · komisyon {fee_min} ile {fee_max} |
| `HR_WARN_NO_REVENUE` | No revenue yet: this salary comes out of the treasury. | Henüz gelir yok: bu maaş kasadan ödenir. |
| `HR_HIRE_CONFIRM_TITLE` / `_BODY` | Hire {name}? / {salary} a month and a one-off commission of {commission}. Runway {before} → {after}. | İşe alım: {name} / Aylık {salary} ve tek seferlik {commission} komisyon. Runway {before} → {after}. |
| `HR_ATLAS_INHERITED_HOURS` | Takes the company's {hours} hours · overtime {money} a month | Şirketin {hours} saatini devralır · aylık mesai {money} |
| `HR_HOURS_INHERIT_NOTE` | Employees take the company hours; hours past eight are paid as overtime. | Çalışanlar şirketin saatini devralır; sekizi aşan saatler mesai olarak ödenir. |
| `HR_EMPTY_ADDS` / `HR_ATLAS_WEEK_POINTS` | Once a product is picked a hire adds {pts} sprint points a week · from {money} a month / {pts} sprint points a week | Ürün seçilince bir işe alım haftada {pts} sprint puanı ekler · aylık {money} ile başlar / Sprintte haftada {pts} puan |
| `EFFECT_SPRINT_HOURS` (değişir) | Team work hours ×{v} this sprint | Bu sprint ekibin çalışma saati ×{v} |
| `EV_FOUNDER_SIDE_CONTRACT_BODY` son cümle (değişir) | Until it is done the whole team's sprint hours shrink. | Bu iş bitene kadar bütün ekibin sprint saati kısalır. |
| `MONTH_CLOSED_TICKER` (değişir) | {month} closed · MRR {mrr} · cash over the calendar month {delta} | {month} kapandı · MRR {mrr} · takvim ayında nakit {delta} |
| 54 `SALES_*` satırı, `HR_FOUNDER_STATE_CARE`, `price_break` metni (değişir) | §3.1: "PH: " kalkar, gözden geçirilmiş metin | aynı |
| `SALES_ROUTE_NO_REP` | No rep to take it | Temsilci yok |
| `OFFICE_REQ_CASH` (değişir) / `OFFICE_MOVE_AFTER_CHEQUE` | At least {money} in the bank / After Frank's cheque | Kasada en az {money} / Frank'in çekinden sonra |
| `OFFICE_CARD_MOVE_GO` (yalnız ACIK 60 C) / `OFFICE_HOVER_LINE` (değişir, C) | Move here / {desks} desks | Buraya taşın / {desks} masa |
| `BUILD_SUPPORT_INCOMING` | Incoming {n} | Gelen {n} |
| `RND_ABANDON` / `RND_ABANDON_NOTE` | Drop it / Progress is kept and the slot clears. | Vazgeç / İlerleme korunur, araştırma yeri boşalır. |
| `RND_PAUSED_JOB` | Moved to another job: {job}. | Başka işe geçti: {job}. |
| `PROD_RND_NODE_DESIGN_SYSTEM_DISCOVERY` 2. cümle (değişir) | One afternoon all of it moved into a single file. | Bir öğleden sonra hepsi tek dosyaya taşındı. |
| `RND_FOUNDER_LEAVES_SPRINT` / `RND_HIRE_FOR_STARS` | The founder leaves the sprint; it stops until they return. / Hire: {role} | Kurucu sprintten çıkar; dönene kadar sprint durur. / İşe al: {role} |
| `SALES_REASON_STABILITY` | the product's stability falls short (Trust & Scale) | ürünün kararlılığı yetmiyor (Güven & Ölçek) |
| `PROD_TYPE_ERP_TRADEOFF` (değişir) | The first install takes long and first customers want stability; once it holds, nobody leaves. | İlk kurulum uzun sürer ve ilk müşteriler kararlılık ister; tutunca kimse çıkmaz. |
| `PROD_PATH_B2B_DESC` (değişir) | You sell to companies. Contracts are big, but first customers expect a stable product. | Şirketlere satarsın. Kontratlar büyük, ama ilk müşteriler kararlı bir ürün bekler. |
| `SALES_TAG_FRANK_INTRO` / `SALES_MOD_WARM_INTRO` | Frank's introduction / Frank's introduction | Frank'in tanıştırdığı / Frank'in tanıştırması |
| `MEETING_INVITE_KICKER_ASKED` | Requested meeting · {hour}:00 | İstenen görüşme · {hour}:00 |

Silinenler (okuyanı kalmadıysa): `OFFICE_TIER_HOME`; ACIK 60 C onaylanırsa `OFFICE_CARD_RENT/_MOVE/_MOVE_NOTE/
_MOVE_FREE/_MOVE_FOR`. Glossary: "runway" izinli ödünç kelime.

## 9. Commit dizisi ve kapılar

Her commit: `--event-lint` → `loc_residue.gd` → `smoke_run.sh loc_csv_integrity` → aşağıdaki vakalar (tek tek,
`for c in …; do bash tools/smoke_run.sh "$c" || exit 1; done`) → görsel kabul TR+EN → ayrı ajan incelemesi → commit.
TR metni taşıyan commit "TR/EN onay bekliyor" der. Yeni shot türü kendi grubunun commit'ine girer (`main.gd` ayrı hunk).

| # | Commit | Bağımlılık | Kapı |
|---|---|---|---|
| O1 | B · S18 bekleme cümlesi ve Boşta (`hr_system.gd`, `hr_ledger.gd`, `hr_ui_shared.gd`, `hr_tab.gd` çip, CSV, `--hr-shot=urunsuz`) | SAAT K10; SPRINT 9 main'de (`urunsuz` `_run_hr_shot`'un kadro kurmayan listesine girer, `main.gd:2043`, B'nin `saatler-sprint` satırı) | §2.1 kabulü |
| O2 | B · S19+S20 Atlas (`hr_search_system.gd`, `work_hours_system.gd`, `hr_atlas_modal.gd`, CSV, smoke, üç `--hr-shot` türü) | O1; SPRINT 9 | §2.2 kabulü |
| O3 | B · S44+S45 kopya (CSV) | yok | §2.4 kabulü |
| O4 | B · S21 boş hâl satırı (`hr_tab.gd`, CSV) | yok | `--hr-shot=bos` TR/EN |
| O5 | C · S13 PH MVP + `loc_no_placeholder_text` (CSV, `price_break.json`, smoke, `sales_probes.gd` yorumu) | yok | §3.1 kabulü |
| O6 | C · S13 kayıp gerekçesi (`sales_meeting_system.gd`, smoke) | O5 | §3.2 kabulü |
| O7 | D · S55 + S42 (`office_map_card.gd`, `office_city.gd`, `office_constants.gd`, CSV, `--office-shot` ekleri) | AÇILIŞ H main'de (`_run_office_shot` `match extra:`, `main.gd:1018-1080`; H oraya `cheque`, `untyped`, `v1` ekler) | §4.1 kabulü (çek satırı hariç) |
| O8 | E · S16 DESTEK (`support_system.gd`, `build_bar*.gd`, CSV, smoke, `desk_shut` eki) | AÇILIŞ H main'de (aynı `match extra:`) | §5.1 kabulü |
| O9 | E · S34 vazgeç ve neden (`rnd_system.gd`, `character_registry.gd`, Ar-Ge kartı ve paneli, CSV, smoke) | yok | §5.2 kabulü |
| O10 | E · S49 (CSV, `rnd_system.gd`, smoke assert, `--rnd-shot=discovery_design`) | O9 | §5.3 kabulü |
| O13 | C · S32 (`sales_ledger.gd`, `sales_tab.gd`, CSV, `norep`/`discounted`, `edge` temsilci bloğu) | SPRINT 8 | §3.3 kabulü |
| O14 | D · S23 çek satırı ve düğme notu (`office_map_card.gd`, `office_hud.gd`, CSV) | AÇILIŞ C1, C3; O7 | §4.1 çek kabulü |
| O15 | E · S22/S48 yan payları (`rnd_assign_panel.gd`, `rnd_ui_shared.gd`/`rnd_detail_panel.gd`, CSV, iki `--rnd-shot`) | SPRINT 10 | §5.4 kabulü |
| O16 | B · S43 notu ve S21 puan/hafta (`work_hours_modal.gd`, `sprint_system.gd` `points_for`, `hr_atlas_modal.gd`, CSV) | SPRINT 9 (imza) ve 11 | §2.5 kabulü |
| O11 | Belgeler: tasarım notu ACIK 107 (a S02, b S43, c ACIK 60, d S12), §6.1 tablosu | SPRINT 1–11 (106 alınmış); §6.1 ölçümü | not commit'te; **dur, sahibe sor** |
| O12 | S39 · VC düşüşü ve künye (`vc_pitch_system.gd`, `main.gd` `_process` VC dalı ve `_run_invite_shot`, `meeting_invite.gd`, CSV, smoke) | SAAT K10 (K4'ün `=held`/`=lapse` kolları dahil) | §7 kabulü |
| O17 | B · S43 tek para tabanı (`hr_constants.gd`, iki smoke assert'inin yeniden yazımı) | ACIK 107(b) onayı | §2.3 kabulü, run_gate 3/3 (taban O17'nin ebeveyni) |
| O18 | D · ACIK 60 C (`office_map_card.gd`, `office_city.gd`, `office_constants.gd`, CSV; ACIK 60 kapanışı) | ACIK 107(c) onayı; O14 | §4.2 kabulü |
| O19 | A · S02 uygulaması (`b2b_*.gd`, smoke, fikstürler, `run_probe.gd` `_log_customers`) | ACIK 107(a) onayı | §6.3 kabulü; §6.1 metrikleri O19'un ebeveyn ağacında yeniden + O19, aynı koşuda; run_gate 3/3, 20 tohum |
| O20 | A · S14 + S33 + S12 (`inbox.gd`, `sales_meeting_system.gd`, `sales_meeting_adapter.gd`, `sales_constants.gd`, `sales_tab.gd`, CSV, `main.gd` `--sales-shot=frank|risk_stability`, `--meeting-shot=frank`) | O19; ACIK 107(d) onayı; SPRINT 8; AÇILIŞ C2, C3, C11, C14 | §6.4 kabulü |
| O21 | Belgeler: HARITA (yeni shot türleri, smoke vakaları; 86'ya VC düşüş bedeli cümlesi, A'nın metni üstüne ayrı hunk), Zaman Modeli §8.5 (aynı cümle), CLAUDE §12 bayrak satırları, GUNCELLEMELER (Ekip §10 seviye fiyatı, Satış §11.5 PH etiketi kalktı, Ar-Ge §5.6 vazgeç, onaylandıysa B2B onboarding tabanı), ACIK 107 son hâli | SAAT K10, SPRINT 11, AÇILIŞ C10 | `git show --stat` yalnız belgeler; loc kapıları |

Sıra tablonun sırasıdır: B → C → D → E (O1–O10, O13–O16), sonra A'nın notu O11 ve **dur**. S39 (O12) A'nın onay
beklemesinde koşar; sahip sırası B→C→D→E→A→S39, tek sapma onay beklemesi. Onay gelince O17–O20, en son O21.
Bağımlılığı main'de olmayan commit atlanır, bağımlılık inince döner. Grup sonu kapıları: B sonu (O17 dahil)
`run_gate.sh` 3/3; A sonu `run_gate.sh` 3/3 + §6.1 tekrarı. Tam smoke yok (CLAUDE §10).

## 10. Dokunulacak dosyalar ve paylaşılan hunk'lar

Serbest (üç PRD'nin listesinde yok): `hr_system.gd`, `hr_ledger.gd`, `hr_search_system.gd`, `work_hours_system.gd`,
`hr_atlas_modal.gd`, `hr_tab.gd`, `hr_constants.gd`, `sales_meeting_system.gd`, `sales_constants.gd`, `sales_ledger.gd`,
`sales_probes.gd` (yorum), `price_break.json`, `office_map_card.gd`, `office_city.gd`, `office_hud.gd`,
`office_constants.gd`, `support_system.gd`, `build_bar.gd`, `build_bar_model.gd`, `rnd_system.gd`,
`character_registry.gd` (`_displace_job`), `rnd_assign_panel.gd`, `rnd_ui_shared.gd`, `rnd_detail_panel.gd`,
`research_bar.gd`, `b2b_sales_system.gd`, `b2b_constants.gd`, `vc_pitch_system.gd`, `hr_ui_shared.gd`,
`sales_meeting_adapter.gd` (`CHIP_BY_SEAM`).

| Dosya / hunk | Kimin de | Sıra |
|---|---|---|
| `scripts/tabs/sales_tab.gd` `_lead_card`, `_meta_line` | SPRINT (B2C ve boş hâl dalları, commit 8) | O13, O20 SPRINT 8'den sonra, ayrı hunk |
| `scripts/modals/work_hours_modal.gd` şirket satırı altı | SPRINT S9 (etki satırı, kurucu sayısı, commit 9) | O16, B'nin satırının altına, ayrı hunk |
| `scripts/systems/sprint_system.gd` `_points` | SPRINT (dosya sahibi; S9 `_points(c, hours)`) | O16, SPRINT 9 ve 11'den sonra, B'nin imzası üstüne tek hunk (`points_for`) |
| `scripts/ui/components/inbox.gd` `risk_reason` ve `desk()` içindeki çağıranı (`:114`) | AÇILIŞ (C2 `_history_item`/`mark_read`/`counts`, C3 ve C11 `desk()`, C14 `show()`) | O20, AÇILIŞ C2, C3, C11 ve C14 main'de olduktan sonra |
| `scripts/main/main.gd` `_run_hr_shot`, `_run_sales_shot`, `_run_office_shot`, `_run_rnd_shot`, `_run_invite_shot` | SPRINT B-D1 (`_run_sales_shot b2c_live`, `_run_hr_shot saatler-sprint`), AÇILIŞ H (`_run_office_shot` ekleri) | SAAT K10 sonrası, her tür ayrı hunk; `_run_sales_shot` SPRINT 8'den (O13, O20), `_run_hr_shot` SPRINT 9'dan (O1, O2; `:2043` listesi B'nin satırıyla aynı satır), `_run_office_shot` AÇILIŞ H'den (O7, O8), `_run_meeting_shot` (`frank`, O20) ve `_run_rnd_shot` (O10, O15) serbest |
| `scripts/main/main.gd` `_process` VC dalı | SAAT (çağrı yolu, bu oturum) | O12, SAAT K10 sonrası |
| `scripts/ui/office/meeting_invite.gd` künye | SAAT (`_accept`) | O12, ayrı fonksiyon |
| `scripts/debug/run_probe.gd` B2B fikstürleri | SPRINT (`_run_sim`, `_seed_b2c_world`, `_start_on_lead`, `_plan_the_sprint`) | O19 yalnız `_seed_b2b_world`/`_seed_stability_fixture` ve `_log_customers` (hedef `satisfaction_target(c)`), ayrı hunk'lar |
| `scripts/systems/cheque_read.gd`, `CHEQUE_TITLE`, `GOAL_TOAST` | AÇILIŞ (C1, C3) | O14 yalnız okur, C1+C3'ten sonra |
| `localization/strings.csv` | üçü | yalnız §8 anahtarları, bayt-span |
| `scripts/debug/endgame_smoke.gd` | üçü | yalnız §9 vakaları |
| `docs/HARITA.md`, `CLAUDE.md` §12, `GDDs/GUNCELLEMELER.md`, `GDDs/GDD — ZAMAN MODELİ.md` §8.5 | üçü (SAAT HARITA 86 ve §8.5'in sahibi) | O21 en son, A'nın metni üstüne ayrı hunk |
| `docs/ACIK_ISLER/ACIK_KARARLAR.md` | üçü (105 SAAT, 106 SPRINT commit 11; C10 madde 29'u kapatır) | O11 (107 ekleme, dosya sonu, ayrı hunk), O18 (60 kapanışı, onayla), O21 (107 son hâli); C10'un 29 hunk'ıyla bitişik değil |

## 11. Sahibe bırakılan kararlar

1. **S02 mekanizması (ACIK 107(a), O11):** onboarding tabanı (N 8, pay 2, [ÇALIŞMA]) ya da tolerans yeniden oturtması; kabul
   eşikleri M2 ≥ %60, M3 ≤ %20 de onay bekliyor.
2. **S12 (ACIK 107(d)):** `WARM_INTRO_MISMATCH_MULT` 0,5 [ÇALIŞMA]; Frank'in `FRANK_ADVISORY_MEETING_SET` satırına şirket adı yalnız
   taslak (Frank külliyatı).
3. **S43 (ACIK 107(b)):** tek para tabanı 22/30 (O17).
4. **ACIK 60 (ACIK 107(c)):** C varsayılan öneri, A alternatif (O18).
5. **TR/EN tablosu (§8)** ve S13'ün 55 satırı + `price_break` metni.
6. **Kapsam dışı kalanlar (bu PRD dokunmaz, sahip yön verir):** S14 lider kolu (Risk'te Güven önerisi;
   `sprint_catalog.gd`, SPRINT'in); S17 uyarı yayma ve `launch_leak` gövdesinin nedeni adlandırması (sahipsiz); S26
   `launch_leak` zamanı (§6.1 ölçer); S24 masa sayısının işe alım tavanı olup olmayacağı, oda haplarının "süs" etiketi,
   evde işe alınanların çizilmemesi (`office_people.gd:573-577`, ACIK 64); S16 `support_overflow`'un B2C'ye açılması;
   S21 kurucu satırı ya da Kişisel bağlantısı; S44 kurucuya özel saat çarpanı (`sprint_system.gd`); S45 Birikim kartının
   hafta/ay ikiliği (`seams_finance.gd:34-39`); S39 VC çağrısının da "İstenen görüşme" sayılması; S39 VC düşüşünde
   tost (F1 sessiz der; istenirse yeni anahtar, `MEETING_POSTPONED_VC` tekrarlanan düşüşte yanlış, §8'e TR/EN onay
   bekliyor).
7. **Tasarım kuralları (onay bekliyor; uygulanır, raporda ⚠️):** S18 `sales` işinin `market_open()` uykusu (§2.1);
   S13 karşılanmayan aile → `LOSS_PRICE` geri düşüşü (§3.2); S55 Ev hapında kademe sözcüğünün kalkması (§4.1); S34
   vazgeçte `_paid`'in kalması, yeniden başlatma bedelsiz (§5.2); S14 nedeninin `trust_offset >= 0` ile ayrılması
   (§6.4). ACIK 60 ve S02 kapıları bunlardan ayrıdır, onaysız uygulanmaz.

## 12. Erdem'in bakacakları
- Atlas: seviye kartlarında aylık bant ve komisyon; gelir yokken kırmızı runway, uyarı ve onay; 15 saatte mesai satırı.
- Kadro: ürün seçilmeden işe alınan "Henüz yapılacak ürün yok" ve "Boşta".
- Satış toplantısında "PH:" yok; kayıp kartı sorulan konuyu anar; temsilci yokken "Temsilciye ver" kapalı.
- Ofis kartı: "Kasada en az", Ev'de kademe yok, İş hanında "Frank'in çeki · 2/5"; C onaylanırsa fiyat hücresi yok.
- DESTEK: masa kapalıyken "Kimse üzerinde değil." ve gelen sayısı; donmuş araştırmada "Vazgeç".
- B2B: ilk hesaplar 8 hafta tutunuyor mu (M1–M3 tablosu); Frank'in adayı etiketli ve kazanılabilir.
- Fonun cevapsız çağrısı sessiz düşer ama erteleme bedelini yazar (görüşmede `VC_WHY_MOVED`); satış çağrısının
  kartı "İstenen görüşme".

## 13. Doğrulama listesi
1. O1–O21 ayrı commit; her birinde inceleme ajanının bulguları kapalı; bağımlılıklar main'deydi (`git log` kanıtı).
2. §0'ın her satırı ✅/⚠️/❌ ve kanıtıyla; "onay bekliyor" olanlar ayrı listede.
3. `grep -rc ',"\?PH:' localization/strings.csv` 0; `grep -rn '"PH:' data/events/cards` boş.
4. Yeni smoke vakaları (`hire_preview_counts_inherited_overtime`, `loc_no_placeholder_text`,
   `sales_loss_reason_from_asked`, `research_abandon_keeps_progress`, onaylandıysa `b2b_onboarding_grace_floor`) ve
   genişleyen vakaların falsifikasyonu raporda.
5. §6.1 tablosu önce/sonra; run_gate 3/3 (B sonu, A sonu); `finite_runway_p2` ve seed günü fark satırı.
6. Görsel kabul TR ve EN, 1920×1080, taşma yok, logda hata yok: §2–§7'de adı geçen her shot türü.
7. Kirli dosyalarda yalnız bu PRD'nin hunk'ları (`git show --stat` her commit); B ve C'nin vakaları yeşil ya da
   kırıldıysa düzeltildi ve raporlandı.
8. Ölü kod yok: silinen anahtarların okuyanı yok (`grep -rn`), `build_bar.gd:145` yorumu gitti, `sales_probes.gd`
   yorumu güncel.

## 14. Done mesajı
```
Onarım 1 · main'de O<n>… (<hash listesi>), push yok.
✅/⚠️/❌ B · S18 bekleme · S19 bant/tehlike/onay · S20 mesai önizlemede (Δburn ≤ 1) · S44/S45 kopya · S21 · S43 <commit | onay bekliyor>
✅/⚠️/❌ C · PH 55+price_break → 0 · kapı loc_no_placeholder_text · kayıp gerekçesi · S32 yönlendirme/koltuk
✅/⚠️/❌ D · S55 · S42 tazelik · S23 çek satırı · ACIK 60 C <commit | onay bekliyor>
✅/⚠️/❌ E · S16 DESTEK · S34 vazgeç · S49 · S22/S48 yan
✅/⚠️/❌ A · tasarım notu ACIK 107 · M1/M2/M3 önce <> sonra <> · run_gate 3/3 · S12 iğne <> · S14/S33
✅/⚠️/❌ S39 · VC düşüşü +2 · "İstenen görüşme"
Ölçüm: launch_leak <n>/8 (önce/sonra) · gate_traction ile gün farkı <>
Onay bekleyen: §11 1–5 ve 7 · TR/EN tablosu · kapsam dışı §11.6
Kırılıp düzeltilen başka task vakaları: <liste | yok>
```

## 15. Öğretici notlar
- **Taban hesabın kendi çıtasına bağlıdır.** Sabit bir taban (örneğin 33) 2★ hesabın 42'lik toleransını kurtarmaz;
  bu yüzden öneri `tolerance + pay`. `trust_offset` tabandan sonra eklenir: kırık söz pencerede de görünür kalır,
  aksi hâlde söz ekonomisi ilk 8 haftada bedavaya döner.
- **Fikstürlerin "bugün imzalandı"sı.** Pencere `acquired_on_day`'den sayılır; risk davranışını sınayan vakalar ve
  probe fikstürleri imzayı bugüne koyuyorsa taban onları susturur. Vakanın iddiasını değiştirme, imzayı geçmişe al.
- **Kalibrasyon A'nın dört parçası.** `HALF_SAT`, tolerans bandı, `saas_ops_field` ve B2C hedefi tek karardır
  (`quality_model.gd:25-30`); tolerans yolu seçilirse dördü birlikte ölçülür.
- **Para birimi.** Günlük oranlar tikte ×7, ayda ×30 işler (`TimeModel`); kural "22 iş günü" diyorsa oran takvim
  gününe çevrilir, çarpanlar değil. TopBar ve modal aynı ×30'u okur: tek yerde düzeltmek her yüzeyi düzeltir.
- **PH kapısı ters çevrildi.** `loc_sales_derived_keys` önekin VARLIĞINI şart koşuyordu (yazım turu satırları
  bulsun diye); MVP'den sonra kapı yokluğu şart koşar. İkisi aynı commit'te değişir, yoksa vaka düşer.
- **Statik metin.** Statik sistemlerde `tr()` değil `TranslationServer.translate`; yeni yardımcılar `class_name`
  almaz (`cheque_read.gd` `preload` ile), başsız koşularda class-cache yarım kalmasın.
- **Shot ve kayıt.** Her shot ve probe kendi `APPDATA`'sında; `--modal-shot=save*` gibi yazan bayraklar gerçek kaydı
  ezer (CLAUDE §12 tuzaklar).
- **Önizleme burn'le sınanır, runway'le değil.** Tik bir haftalık burn'ü kasadan düşer; tik sonrası runway önizlemeden
  hep ~7/30 ay kısadır. Aynı tuzak koruma kopyalamada: kapıyı kapatan koşulu (`call_waiting() == ""`) koruma yapma.
