# B0 · Faz B bağlantı haritası, A'nın gerçek koduyla (PRD §6)
Salt okuma. B0t_HARITA.md'nin tazelenmişi; eski taslak silinmedi.

## 0. Kaynak ve yöntem
- **Kullanılan A raporu: `RAPOR_A.md` YOK.** A'nın taslağı okundu: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/ba70cede-e338-4013-a245-bd70af63d0d1/scratchpad/RAPOR_A_taslak.md` (§6 okuma, §7 yazma, §8 bot). Taslağın §2'sinde `%%FULLSMOKE%%` yer tutucusu dolu değil (satır 91): rapor bitmemiş. PRD §9 "koda başlama koşulu" (`RAPOR_A.md` var) şu an sağlanmıyor.
- **Kod:** `main` HEAD `26b60da`. A'nın commit'leri `e33caac` (K1) ... `26b60da` (K8); `git diff --stat 1faeb82 HEAD` 70 dosya.
- **Satır numaraları HEAD'e göre** (`project-unicorn/` altı). `=` işareti: dosya A'nın diff'inde yok, B0t numarası aynen geçerli.
- **Durum:** ✅ var ve eşleşiyor · ⚠️ eksik ya da farklı (en kısa çözüm yazılı) · ❌ oyunda yok, ilgili B adımı kurar.
- Mail ve bildirim saatlerinin ayrıntısı `B0t_MAIL_SAATLERI.md` ve sonundaki "B0 tazelemesi" bölümündedir.

### Özet: ⚠️ ve ❌ sayımı
| # | Durum | Tek satır | Bölüm |
|---|---|---|---|
| W1 | ✅ B0v | ~~`RAPOR_A.md` yok~~ B0v: `RAPOR_A.md` 13:28'de yazıldı ve B0'ın okuduğu taslakla bayt bayt aynı (`diff` boş); son commit `26b60da` git log'da, raporda ❌ yok: koda başlama koşulu (PRD §9) sağlandı | 0 |
| W2 | ⚠️ | `line_blocked` hatalı kapanışta (`_land_faulty`) okunmuyor | 1, 4 |
| W3 | ⚠️ | `fix_first` kayan kartı döndürmüyor ("Sprinti durdur" çipi için) | 1, 5 |
| W4 | ⚠️ B0v | B0v: ölçülmedi değil, **yapısal olarak hiç dolmuyor**. `c.faulty` yalnız test fazını test rolüne uymayan biri yürütürse doğar (`sprint_system.gd:813-814`), ama `ahead` olmayan herkes teste uyar: yazılımcının ikincil alanı qa, testçinin ikincili engineering (`hr_constants.gd:89-90`), kurucu dört role (`sprint.json:24`); tasarımcı ve PM `ahead` olduğu için test fazına giremez (`sprint_system.gd:808`). `release.faulty` hep `[]`, sürüm sonrası bozulma bugün hiç gelmez; yalnız B7/B6'nın "testi kısalt" yolu doğurur | 1, 4 |
| W5 | ⚠️ B0v | `hr.job` seam'i yalnız ilk işi okur. B0v çözümü: seçici gerekmez; konuşan ve gönderen `EventGate.request(id, {"employee": <id>})` ile verilir (verilen slot bağlama `scope.gd:64-72`; bugün `hr_morale_system.gd:93, 341` böyle kullanır) | 1, 7 |
| W6 | ⚠️ | `line_harden` deposu A'da yok, `line_blocked` hep `false` | 1, 3 |
| W7 | ⚠️ B0v | B0v düzeltmesi: Karar 6 küme 2 ("Yapım ya da Test işine atanmış **herkes**") harfiyen `team()`'dir, `fits` süzgeci yalnız küme 1'e ("geliştirici ve testçiler") uygulanır. Tasarımcı ve PM'in varsayılan işi Yapım (`hr_constants.gd:190-192`), yani küme 2'dedir; W1 örneği (Ece yok) bunu dışlamış: Erdem'e soru. Kurucu `team()`'de (`sprint_system.gd:536-538`) ama ödeyen değildir (Karar 7 onun yolu) | 3, 5 |
| W8 | ⚠️ B0v | Ücretli plan "hattı" sahte (`cap_paid_plan`). B0v: anahtar depoya yazılırsa `candidates()` gelir alanında `fix:cap_paid_plan` kartı kurar (`sprint_catalog.gd:237-242`, alan yetenekleri `:62-71`), B2C `line_impact` 0 pay verir: ödeme olayının tek seferlik düzeltme kartı için en kısa yol budur (B4 okuyucuları doğrular). Kupon kâğıdı W2'nin kendi geri dönüşüyle hattı olan karta bağlanır | 8 |
| W9 | ⚠️ B0v | Gönderen: B0v ek: `card_sender` `desk` dalı hep `MAIL_SENDER_SUPPORT` yazar (`inbox.gd:383-384`); bağlanmamış isteğe bağlı `employee` slotu kategoriye düşer (`product`/`customer` → `desk`, `:18-20`), "yoksa kurucunun notu" kuralını veremez | 4 |
| W10 | ⚠️ B0v | B0v: var olan etiketler yeter: `refunds` (İadeler), `contractor`, lisans için `build_commit` (`finance_system.gd:42-68`). Yeni yalnız `outage_credit` (W1'de onaylı `FIN_ONETIME_OUTAGE_CREDIT`). "İndirim" metni dalgada yok: Erdem'e soru | 3 |
| W11 | ⚠️ B0v | `--sprint-probe` dize parametreyi `to_float` yapar; B2B hesap kadrosu yok. B0v: `_hire` işi `CharacterRegistry.add` verir (`character_registry.gd:445-448`); PRD'nin rolleri (tasarımcı, geliştirici, testçi) `team=4`'tür, PM `team=6` | 4, 7 |
| W12 | ⚠️ | `RunProbe._run_sim` gece dalında `_answer()` yok | 4, 5 |
| W13 | ⚠️ B0v | B0v: botun kademesi hep cloud (`SprintBridges.on_mvp` `sprint_bridges.gd:123`), §4.1 raporu cloud'da 11,5-12,9 olay ✅. Asıl sorun smoke: "4-6 dışı ≥ %30" ancak `p ≤ 0,331` iken tutar; local + çok hata `p = 0,375`. Öneri `P_MAX` 0,30 (BASE 0,10 kalır), `B0_ESIKLER.md` §6 | 4 |
| W14 | ✅ B0v | B0v: sınıf (a). "4 hata, 2 puan" yalnız `notes_tr`'de; oyuncu metni ve çip ("+2 puan" kâğıdın kendi bedeli) etkilenmez. Kapandı | 8 |
| W15 | ⚠️ | Eski kayıttaki `pitch_prep_active` bayrağı `flags` içinde yetim kalır | 10 |
| X1 | ❌ | `IncidentSystem` (durum, zar, tutuş, kayıt) | 4 |
| X2 | ❌ | `MailClock`, `at`, `urgent`, `mail_outbox`, `desk_arrivals`, şema 17 | 2 |
| X3 | ❌ | Yeni fiiller: `incident`, `trust_delta`, `sprint_card_trim`, `sprint_card_test`, `line_harden`, `promise_extend`, `promise_break`; `amount_seam`; `morale_all {scope}` | 3 |
| X4 | ❌ | `PromiseRegistry` uzatma alanı ve kamuya açık bozma girişi | 6 |
| X5 | ❌ | Kâğıt sayacı `product.decision_sprint`, yeni `urun.decision_*` seam'leri | 7 |
| X6 | ❌ | Yenileme günü fonksiyonu (yalnız `tick_requests` içinde satır içi) | 7 |
| X7 | ❌ | Probe: `market=`, `incident=<tür>@<tik>`, `PROBE LINES`, `faulty=` | 4, 7 |
| X8 | ❌ | `HOLD_LABELS["incident"]`, teşekkür sayaçları, `EFFECT_NAMES_MORE` | 4, 9 |

**Toplam: ⚠️ 15, ❌ 8.** Hiçbiri A'nın adlı noktalarının yokluğu değil: RAPOR_A taslağı §6-§8'deki adların hepsi kodda var (§1).

**B0v toplamı:** W1 ve W14 kapandı; 9 satır düzeltildi (W4, W5, W7, W8, W9, W10, W11, W13 ve §3, §9'daki iki satır); 13 yeni ⚠️ (W16-W28, §13). Açık: ⚠️ 26, ❌ 8. Adım ataması `B0v_ADIM_EKLERI.md`'de.

## 1. A'nın adlı noktaları (RAPOR_A taslağı §6, §7, §8) kodda
| A'nın adı | Kodda | Durum |
|---|---|---|
| `ProductState.open_bugs()` | `product_state.gd:169` | ✅ |
| `open_bugs_by_line()` | `:174` (kopya) | ✅ |
| `line_bugs(line)` | `:178` | ✅ |
| `worst_bug_line()` | `:183` (eşitlik: `SprintCatalog.line_users`, sonra küçük kimlik) | ✅ |
| `open_bugs_delta(line)` | `:196`, anlık görüntü `snapshot_open_bugs` `:204` | ✅ |
| `add_bugs(line, n)` | `:208`, `build_progress_changed` yayar. Çağıranlar: `support_system.gd:126`, `sprint_system.gd:1130` | ✅ |
| `clear_line_bugs(line) -> int` | `:216`, sinyal `:222-223`. Çağıran: `sprint_system.gd:1032` | ✅ |
| `line_blocked(line)` | `:238`, gövde `return false`. Yalnız `support_system.gd:121` okur | ⚠️ W2, W6 |
| `EventBus.line_bugs_cleared(line, n)` | `event_bus.gd:140`, manifest `docs/EVENT_SIGNAL_MANIFEST.md:154`. Dinleyen: yalnız `run_probe.gd:275` | ✅ |
| seam `urun.open_bugs` | `seams_product.gd:90-91` → `product_read.gd:37-38` | ✅ |
| seam `urun.worst_line_bugs` | `seams_product.gd:92-93` → `product_read.gd:42-43` (yalnız sayı; hat kimliği seam'de yok) | ✅ |
| `SprintCatalog.line_accounts(line)` | `sprint_catalog.gd:386` (B2B, aktif ya da deneme, `uses_axis`) | ✅ |
| `line_impact(line)` | `:405` B2B `{accounts, seats, top_id, top_seats}`; B2C `{users}` (kitle × `line_share`). En büyük hesap: koltuk, MRR, kimlik | ✅ |
| `line_users(line)`, `line_share(line)` | `:421`, `:393` | ✅ |
| `SalesArchetypes.uses_axis(sector, axis)` | `sales_archetypes.gd:141`, `USE_AXIS_MIN` `:34` (0,25, onay bekliyor) | ✅ |
| `B2BSalesSystem.account_bugs(c)` | `b2b_sales_system.gd:151`; hedefe `:134-137` | ✅ |
| sürüm kaydında `faulty` | `sprint_system.gd:1089` (hatalı çıkan kartların hat kimlikleri, kart başına bir giriş); zar `:1048-1049`; v1.0 öncesi `pending_faulty` `:86`, `:1062` | ✅ (W4) |
| `SprintSystem.team()` | `sprint_system.gd:534-551`: `{id, name, points, share, fits, founder, ahead}` | ✅ |
| `role_of(person_id)` | `:1287` (yalnız `mode() == "active"`; önden hazırlanan kartı da sayar) | ✅ |
| `capacity()` | `:462` | ✅ |
| `fix_first(line)` | `:211-226`, dönüş `void` | ✅ (W3) |
| `SprintCatalog.is_priority(card)` | `:258`; eşik `data/product/sprint.json` `fix_effort.priority` 5 | ✅ |
| `SprintCatalog.fix_effort(bugs)` | `:179`: `steps [4]`, `points [1, 2]` yani 1-4 hata 1 puan, 5+ 2 puan | ✅ |
| bayraklar `mvp_open_bugs`, `mvp_open_bugs_prev`, `mvp_bug_streak`, `mvp_bug_drop_day`, `b2c_users_lost` | `game_state.gd:72-73, 88-90` | ✅ |
| `SupportSystem.neglect_drop()` / `neglect_note()` | `support_system.gd:293-299` (B kullanmaz) | ✅ |
| `VCPitchSystem.churn_callback(...)` | `vc_pitch_system.gd:519` (B kullanmaz) | ✅ |
| bot presetleri `full_run_fix_{none,worst,due,off}`, `full_run_b2c_fix_*` | `run_probe.gd:94-101`; anahtar `fix` `:143`, `:1628-1629` | ✅ |
| `PROBE FIX` / `PROBE BUGS` / `PROBE SHIP open_bugs=` | `run_probe.gd:317-329`, `:585-592`, `:309` | ✅ |
| `SCHEMA_VERSION` 16, `_migrate_16` | `save_manager.gd:16`, `:902`, zincir `:202-203`; `MIN_LOADABLE_VERSION` 10 `:23` | ✅ A 16'yı aldı, B 17 alacak |
| `hr.job` yalnız ilk iş (A'nın notu) | `seams_hr.gd:83-87` (`assigned_job_ids[0]`) | ⚠️ W5 |
| hata hattı akışı | `RngStreams.STREAM_BUG_LINE` `rng_streams.gd:21`; çekiliş `support_system.gd:117-126` | ✅ |

Bilinen davranış, B'nin dayandığı: bir hataya yalnız `SupportSystem.hourly_tick` (saatlik, gece dahil) ve `_land_faulty` (kapanışta) yazar; düzeltme kartı kapanınca hattın bütün hatası tek seferde düşer (`sprint_system.gd:1032`).

## 2. B1 · Mail ve bildirim saatleri
Ayrıntı: `B0t_MAIL_SAATLERI.md` (+ sonundaki tazeleme). A hiçbir mail üreticisi eklemedi ya da değiştirmedi; yalnız satır kayması ve bir saatlik dilim değişikliği var.
| B1'in ihtiyacı | Bugün (HEAD) | Durum |
|---|---|---|
| Mesaj kuyruğu | `MessageSystem.post` `message_system.gd:14` (=), `GameState.messages` `game_state.gd:313`, intro `game_state.gd:934` | ✅ var; saat alanı ❌ X2 |
| Mesai penceresi | `WorkHoursSystem.company_window(hours, start)` `work_hours_system.gd:112-116` (=) → `{start, end, start_text, end_text}` | ✅ |
| Geliş saati kaynağı | `TimeManager.day_minute()` `time_manager.gd:233` | ✅ |
| Gün dönümü ve günlük dağıtım | `_step_hour` `:142-157` (00:00'da `advance_day` + `_dispatch_daily_tick`), dağıtım `:373-417`, yuva sırası aynı | ✅ |
| Saatlik dağıtım | `_dispatch_hourly_tick` `:422-430`: `SupportSystem` `:426`, `SalesSystem` `:428`, `EventGate` `:430`. **`ProductSystem.hourly_tick` kalktı** | ✅ `MailClock.hourly_tick` bu üçünün öncesine/sonrasına girer |
| Gece toplu adımı | `skip_night` `:179-187`, `_run_batch` `:189-199` (`clock_batch_ended` sonda), `_can_step` `:160` | ✅ |
| Şema | `SCHEMA_VERSION` 16, B1 `if version < 17` ekler `save_manager.gd:203` altına | ✅ |
| Otomatik kayıt | `_on_day_tick_completed` `save_manager.gd:407` | ✅ |
| Kayıt sıfırlama | `reset_all_owners` `:322-371`: `MailClock` statik durum tutmazsa girmez | ✅ |
| Ekran damgası | `mail_pane.gd:121-123` (=): şimdiki saat yalnız `_item.hourly` kartta | ✅ doğrulandı |
| Hatırlatıcılar | `inbox.gd` `desk()` `:73`, `_reminder` `:314`, `date_text` `:480` (=); yığın `office_notice_stack.gd:136`; rozetler `top_bar.gd:258, 323`, `left_tabs.gd:305` | ✅ |
| Kendiliğinden açılış | `main.gd` `_open_note` `:3823-3828`, `_on_summary_ready` `:4237`, `_on_product_note_issued` `:4243` | ✅ (R9 riski sürer). B0v: `weekly_sales_report_issued`'ı oyunda dinleyen yok, yalnız smoke (`endgame_smoke.gd:16322`); salıverme anına taşınması gerekmez |
| Frank satırı | `game_state.gd:308-309, 317-319`; yayıcılar `effects.gd:526`, `sprint_bridges.gd:132`, `vc_pitch_system.gd:931` | ✅ |
| Canlı haber satırı | `ticker_live_line`: `sprint_bridges.gd:79`, `summary_system.gd:88, 92`, `news_feed_system.gd:405`; `headline_added`: `sprint_bridges.gd:107`, `hr_*`, `sales_ledger.gd:267`, `effects.gd:453`, `ticker.gd:25` | ✅ |
| `MailClock`, `at`, `urgent`, `mail_outbox`, `desk_arrivals`, `mentor_line_at` | yok | ❌ X2 |

## 3. B2 · Motor fiilleri
| İhtiyaç | Bugün | Durum |
|---|---|---|
| Bedelin olaydan türemesi (tutar seam'den) | `EvEffects._amount` `effects.gd:575-580` yalnız `amount`/`delta`/`value`; `EvChips.describe` `chips.gd:58` | ❌ X3 `amount_seam`; çip ve uygulama aynı yardımcıyı kullanmalı |
| Kalıcı B2B güven izi | `CustomerRegistry.set_trust_offset` `customer_registry.gd:219-226` (sınır `TRUST_OFFSET_MIN -25`, `MAX 10`: `b2b_constants.gd:266-267`) | ✅ yazma noktası; `trust_delta` fiili ❌ X3 |
| İzin affı | `_forgiven_trust` `b2b_sales_system.gd:145-146`; `TRUST_OFFSET_DECAY_PER_DAY` 0,4 `b2b_constants.gd:268` (×7 = 2,8 puan / tik) | ✅ risk: küçük iz görünmez (YURUTUCU_NOTU §6.8) |
| `satisfaction_delta` bir tikte silinir | `effects.gd:402-408`; hedef `b2b_sales_system.gd:127-142` | ✅ kalıcı bedel yalnız `trust_offset` |
| Kişiye moral | `change_morale` `effects.gd:342-353` (`HRMoraleSystem.apply_delta`, trait çarpanı) | ✅ |
| Kapsamlı moral | `morale_all` `effects.gd:354-357`: kapsam yok, bütün çalışanlar; çip ham miktar (`chips.gd:74`) | ⚠️ X3 `{scope}`; çip ölçekli değeri göstermiyor |
| Ödeyenler (Karar 6) | küme 1: kartı olan dev/test = `card.assignees` ∩ `team()[i].fits` ∋ `dev`/`test`; küme 2: Yapım/Test işli herkes = `team()` | ⚠️ W7. B0v: süzgeç yalnız küme 1'de; küme 2 `team()` eksi kurucu (PRD "herkes"), tasarımcı ve PM dahil; Erdem'e soru |
| Verim izi | `productivity_mod` `effects.gd:358-377`, `HRSystem.add_productivity_mod`; kurucuya `entity_id` ile | ✅ (kurucu hedefi bir vakayla doğrulanmalı) |
| Tek seferlik gider | `add_cash` `effects.gd:221-229` → `FinanceSystem.apply_one_time_cost(amount, label)` `finance_system.gd:188-195` | ✅ |
| Gider etiketi | `ONE_TIME_LABELS` `finance_system.gd:42-58`: etiket bu tablonun anahtarı; "An event card's add_cash names one of these; EvLint refuses any other" | ⚠️ W10: "Kesinti kredisi", "İndirim" için `ONE_TIME_LABELS` girdisi + CSV |
| Kitle düşüşü | `audience_delta` `effects.gd:277-282` (`pct` destekli) → `SalesSystem.add_b2c_audience` `sales_system.gd:295` | ✅ tek seferlik; kayıtlı haftalık düşüş `IncidentSystem` durumu ❌ X1 |
| Söz | `promise_create` `effects.gd:409-418` → `B2BSalesSystem.accept_promise` `b2b_sales_system.gd:266`; `PromiseRegistry.create` `promise_registry.gd:50` | ✅; `promise_extend` / `promise_break` ❌ X3, X4 |
| Sprint kartı | `sprint_card_effort/progress/carry` `effects.gd:425-431` → `SprintSystem.effort_change` `:304`, `decision_effort/progress/carry` `:294-328` | ✅; `sprint_card_trim`, `sprint_card_test` ❌ X3 |
| `line_harden` | `ProductState.line_blocked` `product_state.gd:238` stub | ⚠️ W6: depo yok. En kısa çözüm: `GameState.FLAG_TYPES`'a `mvp_line_harden: TYPE_DICTIONARY` ({hat: bitiş tiki}, `game_state.gd:72` yanına), `line_blocked` onu okur, yazan fiil `line_harden` |
| Lint kapıları | `WRITER_VERBS` `lint.gd:319-323`, `SYSTEM_VERBS` `:331-336`, C1 `:463-464`, V3 `:475-476`; `NEUTRAL_VERBS` `effects.gd:32-49`, `ECONOMIC_VERBS` `:70-73`; `SILENT_VERBS` `chips.gd:20-25`; smoke `event_chip_coverage` `endgame_smoke.gd:15201` | ✅ yeni fiiller bu dört yere girer |
| Silinenler (B bağlanmaz) | `fix_run_start` fiili, `destek.can_start_fix_run`, `destek.fix_run_active`, `SupportSystem.start_fix_run`, bilet defteri | ✅ A sildi (`effects.gd`, `chips.gd`, `lint.gd`, `seams_sales.gd`, `sprint_bridges.gd`) |

## 4. B3 · Acil durum sistemi, gece tutuşu, prob
### 4.1 A'nın deposu
| İhtiyaç | Okuma / yazma noktası | Durum |
|---|---|---|
| Açık hata, hat dökümü | `ProductState.open_bugs()`, `open_bugs_by_line()`, `worst_bug_line()` (§1) | ✅ |
| Hatta hata ekleme (regression) | `ProductState.add_bugs(line, 1)` `:208` | ✅ |
| Hattı kullanan hesaplar, en büyük hesap | `SprintCatalog.line_accounts`, `line_impact().top_id` (§1) | ✅ |
| Etkilenen kullanıcı | B2B `line_impact().seats`; B2C `line_users` | ✅ |
| Hatalı sürüm | `GameState.product.release.faulty` (`sprint_system.gd:1089`); sürüm anı sinyali `EventBus.version_shipped` | ⚠️ W4 |
| Hattı kapatma | `line_blocked` | ⚠️ W2: `_land_faulty` (`sprint_system.gd:1126-1132`) yüklemi okumaz, kapalı hatta da hata düşer. Hatalı kapanışı da kapsayacaksa `_land_faulty` içinde `line_blocked`'a sorulur (tek satır) |
| "Hat temizlendi" | `EventBus.line_bugs_cleared` | ✅; "hızla kapandı" bayrağı `IncidentSystem` içinde |
| Düzeltme kartını başa alma | `SprintSystem.fix_first(line)` | ⚠️ W3 (§5) |
| Çalışma ekibi | `SprintSystem.team()`, `role_of` | ⚠️ W7 |

**W4 ayrıntısı.** `faulty` yalnız test aşamasını test rolüne uymayan biri yürütürse doğar (`_work`, `sprint_system.gd:805-818`, `c.faulty = true` `:814`) ve sonra %40 zarı geçmelidir (`sprint.json:29`, zar `sprint_system.gd:1048`). Kurucu dört role uyar (`sprint.json:24`), `_assign` role uyan kişiyi öne alır (`:772-802`). Bot koşularında `PROBE SHIP` satırında `faulty` yok (`run_probe.gd:309`), yani regression olayının hiç gelip gelmeyeceği **ölçülmedi** (PRD §4.12 ⚠️ riski). En kısa çözüm: `PROBE SHIP` satırına `faulty=<n>` ekle (harness değişikliği, sabit değil) ve ölçümü B3 kapısında oku.

### 4.2 Sunucu, doluluk, olasılık
| Nokta | HEAD | Durum |
|---|---|---|
| Sağlayıcı | `InfraSystem.provider()` `infra_system.gd:125`, `set_provider` `:229` (=) | ✅ |
| Doluluk çarpanı | `capacity_state()` `infra_system.gd:212`; `product.outage` kartı `urun.capacity_state == over` | ✅ B tek fonksiyon (1 döner) |
| Hata terimi | `urun.open_bugs` toplamı `min(open, 12)` | ✅ A'dan sonra toplam daha büyük: bkz. W13 |
| `incident` bloğu | `data/product/sprint.json` üst anahtarlar: `decision`, `fix_effort`, ... | ❌ X1 (blok yok) |
| RNG | `RngStreams.STREAM_IDS` 3 akış (`rng_streams.gd:22`); olay zarı için `EvDice.unit` ya da yeni akış | ✅ karar B3'ün |

**W13.** A'nın ölçtüğü haftalık açık hata toplamı ile B_PLAN formülü (`p = BASE × TIER × (1 + min(açık, 12)/8)`, BASE 0,10, `MIN_GAP` 4, `v1.0`'dan 3 hafta sonra) koşu başına şu olay sayısını verir (K5 logları + hat modeli, 60 tekrar × 2 tohum; ölçüm değil model, ayrıntı `B0_ESIKLER.md` §0): cloud 11,4 (B2B fix_worst) ve 12,1 (B2C fix_worst); enterprise ×0,6 → 8,2 / 8,5; **local ×1,5 → 14,1 / 15,1**. Hedef "koşu başına 4-14 olay" (PRD §4.1) local'de aşılır. Aralık en az 4, 4-6 hafta dışı pay cloud'da %43-45, local'de %30. Çözüm B3'te: BASE 0,08'e inmeli ya da hedef yeniden konmalı (onay bekliyor); B0 sabit önermez, ölçüm ister.

### 4.3 Zaman yöneticisi, tutuş, olay kapısı
Hepsi B0t_HARITA §1.3-§1.4 ile aynı, çünkü `engine.gd`, `queue.gd`, `latches.gd`, `event_gate.gd`, `gate.gd`, `tempo.gd` A'nın diff'inde yok (=). Doğrulananlar:
| Nokta | HEAD | Durum |
|---|---|---|
| Tutuş | `hold_clock` `time_manager.gd:340`, `release_clock` `:349`, `is_clock_held` `:354`; `HOLD_LABELS` `:32-37` | ✅; `"incident"` etiketi ❌ X8 |
| Toplu adım ve tutuş | `_run_batch` `:189-199`, `_can_step` `:160`, `clock_batch_ended` `:199` | ✅ tutuşla kesilen adım kaldığı yerden sürer |
| Kart isteği | `EventGate.request` `event_gate.gd:16-17` → `EvEngine.request` `engine.gd:686-701` (G4 pencere denetlenmez, gece kabul) | ✅ |
| Sıra | `EvQueue.rank` `queue.gd:74-83`: `terminal_warning` 0, son uyarı 1, `critical` 2 | ✅ risk: son uyarı varken 03:00 acil kartı ikinci kalır (kabul 4.3); çözüm `urgent` etiketini son uyarının üstüne almak |
| Lint C1 | `lint.gd:463-464` | ✅ acil kartlar `system: true` |
| Mandal | `EvLatches.blocked_reason` `latches.gd:58-76` | ✅ |
| Kaydet | `EvSave` bloğu; `to_dict` `time_manager.gd:283`; tutuş kaydedilmez | ✅ |

### 4.4 Gönderen, kart verisi
| Nokta | HEAD | Durum |
|---|---|---|
| Gönderen türleri | `EvPresenter.SENDERS` `presenter.gd:20`; çözüm `inbox.gd` `card_sender` `:341-` | ✅ |
| B2B müşteri gönderen | `inbox.contact(c)` `inbox.gd:422-428`: lead'den geldiyse `CounterpartSystem.buyer_of(c)` `counterpart_system.gd:61` (kişinin kendi unvanı), değilse `B2BConstants.sector_contact(industry)` `b2b_constants.gd:109` | ⚠️ W9: W1 ay sonu maili sabit "Finans Müdürü" ister. En kısa çözüm: karta `sender_title` alanı ya da `contact` çözümünde override |
| "Sunucu uyarısı / Server alert" | `desk` türü `inbox._desk(MAIL_SENDER_SUPPORT, company)` sabit etiket | ⚠️ W9: yeni CSV anahtarı + `desk` varyantı |
| Yapım işindeki ilk yazılımcı gönderen | `employee` türü, kartın `employee` slotu | ✅ slot seçicisi `team()`/`job` ile (W5) |
| Kart `tick: request`, `system: true`, `tags: critical` | `lint.gd:463-464`, `:475-476` | ✅ |

### 4.5 Prob, bot
| Nokta | HEAD | Durum |
|---|---|---|
| `--sprint-probe` ayrıştırma | `main.gd:258` → `sprint_probe.gd:50-58`: `spec.split(":")`, her parça `anahtar=değer`; yalnız `gate` string, öteki hepsi `.to_float()` | ⚠️ W11: `market=b2b` 0,0 olur, `incident=outage@12` 0,0 olur. En kısa çözüm: `gate` gibi `market` ve `incident` için string dalı (`:55-56`) |
| Sabit ürün | `sprint_probe.gd:72` `choose_type("note_tool", "Notly")` | ⚠️ W11: `market=` yok. B2B kolu ERP ister (`ProductCatalog` `product_catalog.gd:29`) |
| B2B hesap kadrosu | yok; probta müşteri eklenmiyor, `line_accounts` boş kalır | ⚠️ W11: ay sonu / B2B kesinti kartı hesap ister. En kısa çözüm: `market=b2b` dalında fikstür hesap(lar) (`_shot_customer` benzeri) |
| `team=` | `HIRES` `sprint_probe.gd:40-41`: geliştirici, tasarımcı, testçi, geliştirici, PM; `team=3` kurucu + geliştirici + tasarımcı | ⚠️ W11: PRD §4.5 "tasarımcı, geliştirici, testçi" için `team=4` gerekir |
| `rate` | `sprint_probe.gd:60-61` `decision.rate`'e yazar | ⚠️ B5 `decision.rate`'i kaldırınca bu satır da değişir |
| `incident=<tür>@<tik>` | yok; `events=1` döngüsü `:80-88` | ❌ X7 |
| `RunProbe` ayrıştırma | `run_probe.gd:174-192`: `<preset>:<hafta>:<mod>[:<tohum>][:replay=K]`; adlı seçenek yalnız `replay=` | ✅ B3 gerek duyarsa `incident=` buraya eklenir |
| `RunProbe._run_sim` | `:724-751`: saat saat `advance_hours(1)` + `_answer()` (`:745-747`); gece dalında `skip_night()` (`:743`) ve `_answer()` yok; tutuşlu saat `PROBE ERROR ... the clock is held` ile biter (`:739-741`) | ⚠️ W12: gece acil kartı bu döngüyü bitirir. En kısa çözüm: `skip_night()`'in ardına `_answer()` ve tutuş varsa kart cevaplanınca `release` (kabuksuz harness'te yalnız B'nin tutuşu var) |
| Bot seçimi | `_pick_choice` `:661-708` ilk kilitsiz satır; `RETAIN_PREFERENCE` fiile göre `:657-658`; `_cash_delta_of` `:710-720` yalnız literal `add_cash` | ⚠️ B4: fiile göre seçim eklenecek (`incident {act}`); `amount_seam` tutarı `_cash_delta_of` göremez |
| `PROBE` satırları | `FIX` `:317-329`, `BUGS` `:585-592`, `SHIP` `:309` | ✅; `PROBE LINES` (hat başına döküm) ve `SHIP faulty=` ❌ X7 |

## 5. B4 · Kalan kartlar, "Sprinti durdur", botun seçimi
| İhtiyaç | HEAD | Durum |
|---|---|---|
| "Sprinti durdur, şimdi düzelt" | `SprintSystem.fix_first(line)` `sprint_system.gd:211-226`: kart sprintteyse başa taşınır, sonraki sütundaysa ya da adaysa alınır, ikinci kart açılmaz (Karar 9 ✅); koşan sprintte hemen koşar ve haftanın ataması baştan yapılır; sürüm notundayken sonraki sprintin başına girer; hatta hata yoksa ya da kart bitmişse bir şey yapmaz | ✅ |
| Çipin "kayan kart" adı | `fix_first` dönüş değeri yok, kayan kartı bulan okuma yok | ⚠️ W3. En kısa çözüm: çağrıdan önce ve sonra `SprintSystem.plan_outcome()` `:584-601` oku, `cards[id].finishes` true'dan false'a düşen kartın adı (`SprintCatalog.card_name` `:283`) çipe girer. Çip için önizleme fonksiyonu gerekir (uygulamayı çağırmadan hesap: kopya kartlarla `plan_outcome(ids)` kart sırası değişik) |
| Plan tahmini yeniden okunur | `_changed()` `sprint_system.gd:1172`, `plan_outcome` `:584`; kabul 4.7 | ✅ |
| Hat kartı var mı | `SprintCatalog.card_by_id("fix:" + line)` `:271`; aday `candidates` `:237-241` | ✅ hatta hata yoksa kart yok |
| Botun acil durum seçimi (§4.11) | `fix_none` kolu: `_plan_fix_arm` `run_probe.gd:934-960`. **Not:** B2C `fix_none` kolu da düzeltme alır (K5 logları, geç dönem: 133 sprint kapanışının 103'ünde `PROBE SPRINT shipped=` içinde `fix:` kartı var) çünkü lider düzeltme kartlarını geri getirir; B2B `fix_none` hiç almaz (142 kapanışın 0'ı) | ⚠️ B4 ölçümünde B2C `fix_none` "hiç düzeltmeyen" kol değildir |
| Eşitlik | `due.sort_custom` bug sayısı azalan, kimlik artan `:937-941` | ✅ |
| A hedefi | K5_OLCUM: 40 hedefin 38'i tuttu; iki kaçan B2C erken düzeltme payı (`fix_worst` %50, `fix_due` %50) | ✅ B4'ün yeniden ölçümüne taban |

## 6. B7 · Söz olayı
| İhtiyaç | HEAD | Durum |
|---|---|---|
| Söz modeli | `Promise` `promise.gd`; `PromiseRegistry.create` `promise_registry.gd:50`, `tick_deadlines` `:150`, `_overdue` `:158`, `_resolve` `:164` (`promise_broken` / `promise_kept` `:169, 171`); `_on_build_phase_changed` `:133` (=, A dokunmadı) | ✅ |
| Söz anı | `SprintSystem.fits_plannable(step)` `sprint_system.gd:695-715`; `urun.sprint_last_week` | ✅ |
| Uzatma | `Promise` alanı `extended`, `due_sprint +1` | ❌ X4 |
| "Söz kaçsın" girişi | `_resolve` özel (alt çizgili) | ⚠️ X4: en kısa çözüm `PromiseRegistry.break_promise(id)` (`_resolve(p, "broken")` sarar) |
| Kalıcı güven (uzatma −6) | `set_trust_offset` (§3) | ✅ |
| Söz zinciri (kopyalanmaz) | `B2BSalesSystem.on_promise_resolved` `b2b_sales_system.gd:391` | ✅ |
| "Testi kısalt" sabiti | `data/product/sprint.json`: `faulty_chance` 0,4 `:29`; `cut_test_escape` yok | ❌ B7 ekler (0,15, onay bekliyor) |
| Aynı sprintte kâğıt yok (Karar 12) | sayaç yok | ❌ X5 |

## 7. B5 · Kâğıt motoru
| İhtiyaç | HEAD | Durum |
|---|---|---|
| Seçim | `_request_decision` `sprint_system.gd:852-874`: sürüyen her kart için haftalık zar, `decision.rate` 0,35 (`sprint.json`), `decision.cards` 6 kart; çağıranlar `_begin` `:167` (1 haftalık sprint) ve `_end_week` `:763` | ✅ B5 yeniden yazar |
| Sprint başına en çok bir, boş sprint | sayaç `product.decision_sprint` yok; `new_state` `:77-91` anahtar listesinde değil | ❌ X5. Eski kayıtta `p.get("decision_sprint", -1)` ile okunmalı (`product` sözlüğü kayıtta olduğu gibi döner) |
| Kesinti sırası (Karar 12) | acil durum saatlik/gece gelir; kâğıt günlük tikte | ❌ X5: sayacın tek sahibi `SprintSystem`; `IncidentSystem` ona yazar |
| Konuşan kişi | `card.assignees` yalnız `_assign` yazar (`:772-802`); `role_of` `:1287` | ✅ |
| Seçici | `hr.job` yalnız ilk iş (`seams_hr.gd:83-87`); `hr.role` / `hr.on_decision_card` yok | ⚠️ W5. En kısa çözüm: yeni `employee` seçicisi `decision_assignee` ya da kartın `employee` slotunu `SprintSystem` bağlar; `hr.job` kullanılmaz |
| PM istisnası | `team()` PM'i alır (`ahead: true`, `fits` ürün + tasarım); `_assign` PM'i sprint kartlarının **tasarım aşamasına** da atayabilir (`(at == 0 or not p.ahead) and (p.ahead or i < cards.size())`, `:784`) | ⚠️ Karar 10 "PM sprintte kart almaz" ile çelişir. Kâğıt konuşanı için PM kuralı ayrı kalır; `paper_speaker_is_assignee` PM'i hariç tutar (PRD §4.6) |
| Tekrar kuralı | `max_fires`, `cooldown_weeks`, `latch_key: run`; `EvLatches.fires` | ✅ (B0t §2) |
| İstek kartı ve PM kâğıdı | `SprintCatalog.open_requests` `sprint_catalog.gd:709`; kart `req:<id>`, `customer_id`; istek `{id, customer_id, line, step, due_sprint, status, day}` (`sprint_bridges.gd:51-53`) | ✅ ikinci sahip alanı yok (`urun.decision_second_account` ❌ X5) |
| Yenileme günü | yalnız `tick_requests` içinde satır içi: `renewals = int((day − acquired + lead)/term)` (`sprint_bridges.gd:33-35`); `Customer` üzerinde sözleşme bitiş alanı yok | ❌ X6. En kısa çözüm: `SprintBridges.next_renewal_day(c)` aynı ifadeyle (tek yer) |
| Seçenek etiketinde seam | `choice.label = resolve_text(...)` `presenter.gd:65`; `_interpolate` seam'i çözer `:268-281` | ✅ doğrulandı (W2 `pm_two_accounts` sorusu) |
| Prob: pazar | `market=` | ⚠️ W11 (§4.5) |
| Prob: kâğıt satırı | `SPRINTPROBE PAPER|<tohum>|<sprint>|<olay>|<konuşan>` | ❌ X7 |

## 8. B6 · Kâğıt içeriği
| İhtiyaç | HEAD | Durum |
|---|---|---|
| Hat adı ve sayı belirteci | `urun.decision_line_name`, `urun.decision_root_bugs` | ❌ X5 (metin seam'i; hat adı `PROD_LINE_*` CSV, `SprintCatalog.cap_name` `sprint_catalog.gd:74`) |
| Düzeltme kartının hata sayısı | `card.bugs` (`sprint_catalog.gd:237-241`, `_refresh_fix_cards` `sprint_system.gd:1219-1230`) | ✅ |
| Hat → kullanan hesap | `uses_axis`: ops_cautious (lojistik, inşaat, üretim + sahipsiz sektörler) kararlılık ve deneyim; tech_exacting (teknoloji, e-ticaret, finans) yenilik ve kararlılık; finance_brisk (sigorta, hukuk, perakende, emlak) deneyim ve kararlılık (`sales_archetypes.gd`) | ✅ **Nakit Akışı** (yenilik) yalnız teknoloji/e-ticaret/finans hesaplarının; **Defter** (kararlılık) hepsinin; **Fatura** ve **Stok** (deneyim) tech olmayanların |
| Ücretli plan hattı | `PAID_PLAN = "cap_paid_plan"` `sprint_catalog.gd:14`, `capabilities` `:62-71` | ⚠️ W8: gerçek hat değil. `add_bugs("cap_paid_plan")` hattı olmayan bir anahtara yazar (`line_accounts` boş, `line_share` 0). En kısa çözüm: kupon kâğıdında hata `line_shared_integrations`'a yazılır |
| Dayanıklılık hattı | `line_shared_durability`: K1 "Otomatik Kayıt", K2 "Sürüm Geçmişi", K3 "Çevrimdışı Çalışma" (`strings.csv:2057-2059`); `ProductState.line_tier` `product_state.gd:76` | ✅ solo yedek kâğıdı `line_tier == 1` |
| Bedel: kaynak yüzde ve puan | W2 sabitleri | ❌ B6 (`sprint.json` `paper` bloğu) |
| Örnek sayı | `fix_effort` `sprint.json` | ⚠️ W14: W2 `dev_root_cause` örneği "4 hata, 2 puan": 4 hata 1 puandır, 2 puan 5+ hatadır |

## 9. B8 · Sürüm anı, teşekkür, yorum
| İhtiyaç | HEAD | Durum |
|---|---|---|
| Sürüm köprüsü | `_close` `sprint_system.gd:1007-1105`; `_go_public` `:1108-1123`; `version_shipped` `:1102` (v1.0: `:259`); `SprintBridges.on_release` `sprint_bridges.gd:60-64` (açık talepleri `met` yapar, A dokunmadı) | ✅ |
| Hızla kapanan acil durum | `line_bugs_cleared` (00:00 sprint kapanışında yayılır) + `IncidentSystem` bayrağı | ✅ + ❌ X1 |
| Söz çıktı | `PromiseRegistry._on_build_phase_changed` `promise_registry.gd:133`, `promise_kept` (`kept` ve `partial` aynı sinyal) | ✅ |
| İstek çıktı | `product.requests[].status == "met"` (`sprint_bridges.gd:60-64`) | ✅ |
| Sürüm notunun sonuç satırı | `_fill_actual` `sprint_system.gd:1145-1153` (sürümden bir tik sonra) | ✅ yorum satırı buraya |
| Hatalı sürüm hatları | `release.faulty` | ⚠️ W4 |
| Teşekkür sayaçları (hesap başına 1, sürümde 3) | yok | ❌ X8 |
| Gelen kutusuna yazış | ~~`MessageSystem.post` (outbox, B1)~~ B0v: teşekkür seçeneksiz bir **not kartı** olur (`customer.release_thanks`, `EventGate.request(id, {"customer": <id>})`): gönderen `contact()` ile hesabın kişisidir (`inbox.gd:422-428`), mesajda gönderen yok (`MESSAGE_TOPICS` `inbox.gd:16`); kart B1'in `at` kuralıyla mesai içinde teslim edilir. Mandal `latch_key: entity` (aynı sürümde üç hesap) | ✅ B1'e bağlı |
| Yorum: olumsuz hat eşiği | `RELEASE_REVIEW_NEG_LINE_BUGS` | `B0_ESIKLER.md` |

## 10. B9 · Yatırımcı hazırlığının kalkması (A'dan sonra satırlar)
A bu dosyaların bir kısmına yazdı; satırlar kaydı. `MEETING_CHIP_PREP` satış kullanımı kalır (`sales_meeting_adapter.gd:31-33`, `strings.csv:1908`).
| Dosya | HEAD satırları | Ne |
|---|---|---|
| `game_state.gd` | `:104` `"pitch_prep_active"`, `:244` `var prep`, `:843` `prep.clear()` | alan, bayrak türü, sıfırlama |
| `pitch_constants.gd` | `:72` `FOCUS_KEYS`, `:74-76` `PREP_WEEKS`, `PREP_MIN_WEEKS_BEFORE`, `PREP_BONUS` (=) | sabitler |
| `vc_pitch_system.gd` | `:38` `_prep_focus`; `:85` `_consume_prep` çağrısı; `:826-836` `cancel_meeting`; `:858-886` `prep_blocked_reason`, `start_prep`, `_consume_prep`; `:899` `_tick_prep()` çağrısı; `:937-942` `_tick_prep`; `:996-997` pivot; `:1057` `prova`; `:1277-1280`, `:1296` `PREP_BONUS` kolları; `:1301-1305` `_check_view` `prep` alanı; `:1376`, `:1386` reset | mantık (A'nın `+29` satırı öncesine eklendi, B0t'den kayık) |
| `hr_system.gd` | `:155` `is_busy`, `:205` `FOUNDER_STATE_PITCH_PREP`, `:224`, `:248-249` | kurucu meşguliyeti ve durumu |
| `seams_hr.gd` | `:41`, `:182` | seam açıklaması |
| `rnd_system.gd` | `:163` | yorum |
| `hunt_tab.gd` (=) | `:377-388` `_prep_row`, `:506-520` bekleyen satırı | Series A sekmesi |
| `vc_meeting_adapter.gd` (=) | `:166-168` `chk.prep` | VC "HAZIRLIK" çipi |
| `save_manager.gd` | `:693` `_stamp_keys(gs.get("prep", {}), ["done_day"], today)` (v13 göçü) | göç satırı |
| `main.gd` | `:3538` fikstür `GameState.prep = ...` | çekim fikstürü |
| `endgame_smoke.gd` | `:113` kayıt, `:2569-2590` `prep_bonus_and_capacity`, `:2601-2608` `meeting_daylock` kolları, `:10406-10422` `hr_read_catalogue`, `:14892` bayrak sıfırlaması | vakalar |
| `strings.csv` | `HR_FOUNDER_STATE_PITCH_PREP` `:449`; `HUNT_PREP_*` `:796-797, 815-816`; `HUNT_FOCUS_*` `:836-838`; `VC_PREP_*` `:1264-1267`. Kalır: `MEETING_CHIP_PREP` `:1908` | CSV (byte-span cerrahisi) |
| Belgeler | `_vocabulary.md:181`; `GDD — ZAMAN MODELİ.md:294, 639, 707, 745`; `GUNCELLEMELER.md:399, 404`; `ACIK_KARARLAR.md:157, 1015, 1023, 1219` | belge |
**W15, eski kayıt (B0t'de "DOĞRULANMADI" idi, şimdi çözüldü).** `SaveCodec.apply_game_state` (`save_codec.gd:197-215`) `GameState`'in bugünkü alanlarını gezer ve bloktaki fazlalık anahtarı yok sayar: `prep` alanı kalkınca eski kayıttaki `prep` sessizce düşer. `pitch_prep_active` ise `flags` sözlüğünün içindedir; `_decode_flags` (`:218-240`) bilinmeyen anahtarı (`flag_type_for` → `TYPE_NIL`) `from_json` ile korur. Yetim bayrak kalır ve `HRSystem.is_busy` gibi okuyucular kalkmışsa zararsızdır ama PRD §8 "her yüklemede düşürür" der: düşürme satırı `_decode_flags` ya da `read_slot` zincirine açıkça yazılmalı.

## 11. B0t_HARITA'da artık geçersiz olanlar
| B0t'deki söz | Şimdi |
|---|---|
| "[A/B]" işaretli 16 varsayım | hepsi gerçek adla çözüldü (§1); adlar B_PLAN tahminiyle uyumlu, farklı çıkan yok |
| §1.1 `SprintBridges.add_faulty_ticket`, `close_tickets`, bilet defteri (`product.tickets`) | silindi; `sprint_bridges.gd` 66 satır küçüldü. Yazma yolu `ProductState.add_bugs`, `_land_faulty` |
| `product.bug_pile` kartı, `fix_run_start`, `destek.can_start_fix_run`, `destek.fix_run_active`, `SupportSystem.start_fix_run` | silindi (`data/events/cards/product/bug_pile.json` yok; `effects.gd`, `chips.gd`, `lint.gd`, `seams_sales.gd`). B'nin kodu bunlara bağlanmaz |
| `SprintSystem.team()` "aktif çalışanlar + kurucu, Ar-Ge dışında" (§1.7) | Görevler matrisine bağlı: Yapım ya da Test işini tutan, `share > 0` (`sprint_system.gd:534-551`, `_share` `:1326-1328`) |
| §1.7 "Hatta kart ilişkisi" | doğru; `kind == "fix"` kartı `line` ve `bugs` taşır (`sprint_catalog.gd:237-241`) |
| §1.8 risk (2) "A hedefe hesap başına hata terimi ekleyecek" | eklendi: `account_bugs` × `B2B_BUG_SAT_PER` 0,3, tavan 20 (`b2b_constants.gd:58-59`) |
| §1.11 `SCHEMA_VERSION` 15 | 16 |
| §1.12 `fix_on_at` düzeltme koşusu | silindi; yerine `_plan_fix_arm` (`run_probe.gd:934`) |
| B0t_MAIL "85 kart, 71 günlük yol" | HEAD'de 84 kart, günlük 60 + takvimli 4 + sinyalli 6 = **70** (`bug_pile` gitti) |
| B0t_MAIL `_sim_day` "149 çağıran" | 160 (`endgame_smoke.gd:573`); `_sim_day_full` 43 (=) |
| B0t_MAIL `sprint_bridges.gd:134`, `:162` | `:79` (`tick_rivals`), `:107` (`press_line`) |
| B0t vc_pitch prep satırları | +29 kaydı (§10) |

## 12. Doğrulanmayanlar
- ~~RAPOR_A.md'nin nihai hâli~~ B0v: nihai rapor taslakla aynı (W1).
- ~~Kurucuya `productivity_mod`~~ B0v ✅: kartlar bunu bugün `"scope": "founder"` ile yapıyor (`customer/new_owner.json:117`, `founder/side_contract.json:67`); kurucunun verimi `HRSystem.productivity` → `event_pace` üstünden puana girer (`sprint_system.gd:1319`, `hr_system.gd:403-413`).
- `release.faulty`'nin bot koşularında kaç sürümde dolu geldiği (W4).
- Hat başına açık hata dağılımı hiçbir logda yok; `B0_ESIKLER.md` model + ölçüm koşusu isteği.
- Toast'ın gece görünürlüğü (B0t_MAIL §8, değişmedi).

## 13. B0v · Opus doğrulaması (2026-10-17, HEAD `26b60da`)
Salt okuma; Godot koşulmadı. Yukarıdaki ✅ satırların B'nin dayandıkları dosya:satır açılarak doğrulandı: `ProductState`
hata API'si (`product_state.gd:169-239`), `SprintCatalog.line_accounts/line_share/line_impact/line_users`
(`sprint_catalog.gd:386-422`), `fix_effort`/`is_priority`/`card_by_id`/`card_name` (`:179, 258, 271, 283`),
`SprintSystem.team/capacity/role_of/fix_first/plan_outcome` (`sprint_system.gd:534, 462, 1287, 211, 584`), sürüm kaydı
`faulty` (`:1089`), `EventBus.line_bugs_cleared` (`event_bus.gd:140`), `SCHEMA_VERSION` 16 ve zincir
(`save_manager.gd:16, 200-203`), `RunProbe.PRESETS` (`run_probe.gd:81-101`), `_run_sim` (`:724-751`), `sprint_probe`
ayrıştırması (`sprint_probe.gd:50-58`), saatlik ve günlük dilim sırası (`time_manager.gd:142-157, 373-430`),
`inbox.desk()` (`inbox.gd:73`), `MessageSystem.post` (`message_system.gd:14`), kart sayısı (demo 84 = günlük 60 +
takvimli 4 + sinyalli 6 + istek 13 + saatlik 1; 00:00 yolu **70**). Küçük satır kaymaları: `WRITER_VERBS`
`lint.gd:319-326`, `HRSystem.is_busy` `hr_system.gd:150`, `Promise` modeli `scripts/data_models/promise.gd`,
`_settle_decision`'ın varlık okuması `sprint_system.gd:881-882` (B0t'deki 863-864 değil; B1 süzmez).

### Yeni ⚠️ (W16-W28)
| # | Bulgu | Kanıt | Adım |
|---|---|---|---|
| W16 | Konuşan kişi isteğin anında yakalanmalı. 1 haftalık sprintte `_request_decision` `_assign`'dan önce koşar, kartların `assignees`'i boştur; kararı bekleyen kartın `assignees`'i bir sonraki `_assign`'da silinir | `sprint_system.gd:166-169, 762-764, 777-779` | B5 |
| W17 | Güven izi affı (haftada 2,8) küçük izleri siler: oyuncu −6'yı bir hafta −3,2, −8'i −5,2 görür; −3/sprint, −2, −1 hiç görünmez. Karar 8'in "alışkanlık yapan kaybedebilir"i bu sayılarla oluşmaz | `b2b_constants.gd:30, 268`, `b2b_sales_system.gd:48-54, 145-146` | B2 (+ R sorusu) |
| W18 | Yalnız ödeyeni düşüren seam yok: ödeyen = kitle × dönüşüm. W1 `EFFECT_PAYING_USERS` ("Ödeyen −7 · MRR −$56") ve W2 kupon kâğıdı bunu ister | `sales_system.gd:10, 233, 288` | R sorusu; B4 ve B6a uygular |
| W19 | `sprint_pm_two_accounts` hiç gelmez: bir kademe yalnız bir açık talepte durur | `sprint_bridges.gd:43-47` (`taken`) | R sorusu; B6a uykuda bağlar |
| W20 | A'nın `fix_off` kolu "açık hatanın hiçbir bedeli yok" der; olay tehlikesinin hata terimi ve olay bedelleri `ProductState.costed()`'tan geçmezse kol bozulur | `product_state.gd:227-235` | B3 |
| W21 | Karar 4 "gece yalnız acil durum kartı": son uyarı (sıra 1) ve kepenk (sıra 0) acil sayılıp 00:00'da kuyruktadır; 03:00 olayından sonra `pump` onları açar. Kapı `EvQueue.next()`'te: mesai penceresi dışında yalnız olay kartı | `queue.gd:60-82`, `engine.gd:536-537` | B3 |
| W22 | Onaylı metinler yalnız bazı hatlar için yazıldı: yorum fırtınası 4 ortak hat, B2C bozulma 4 ortak hat, B2B bozulma 9 hat; olumsuz sürüm yorumu 4 ortak hat artı kimlik hatları için genel grup. Not ve video hatları (`line_note_tool_*`) fırtına ve bozulma doğurmaz | W1 `body_variants`, W3 `reviews` | B4, B8 |
| W23 | "Ayın son haftası" takvim ayıdır: `SummarySystem.begin_day` ay dönümünü `GameState.get_date_dict` ile okur; `TimeModel.DAYS_PER_MONTH` 30 ekonomi ayıdır | `summary_system.gd:57-59`, `time_model.gd:17` | B4 |
| W24 | `decision.rate`'i okuyanlar: `sprint_probe.gd:60-61`, smoke `endgame_smoke.gd:5794, 5800, 18355-18398`. Mandal yorumu "alternatives, not a stack" der, kod ikisini birlikte uygular (52 hafta + en çok 3 çalışır) | `latches.gd:56-85` | B5 |
| W25 | `fix_first` yalnız düzeltme kartını taşır; W2 yenileme kâğıdı istek kartını, "Sprinti durdur" ve W2 kayıt kodu kâğıdı hattın düzeltme kartını başa ister: tek fiil `sprint_fix_first` ve ortak "başa taşı" gövdesi | `sprint_system.gd:211-225` | B4 |
| W26 | `sprint_card_trim {follow}` kartı `plan_next`'te silinmemeli (özellik ve talep kartı kademesi tutunca silinir); `{bugs}` hataları `pending_faulty`'ye girmeli, `release.faulty`'ye değil (yoksa bozulma olayı doğar). Bilgi çipleri (`EFFECT_CARD_LATE/ON_TIME`) etkisiz, etiketli bir fiil ister | `sprint_system.gd:182-185, 1048-1063` | B6a |
| W27 | Bot: `_pick_choice` `customer.` önekli kartları tutma politikasına sokar (`customer.incident_month_close` oraya düşer); `_cash_delta_of` yalnız düz `add_cash` tutarını görür | `run_probe.gd:661-720` | B4 |
| W28 | `decision_card_late` ve `crunch_finishes` karar kartına bağlı; söz olayının kartı karar kartı değildir | `sprint_system.gd:652-682` | B7 |

### Ek doğrulamalar
- `EventGate.request` istek anında `pump()` çağırır, toplu adım içinde `pump` erteler (`engine.gd:686-701, 536-537`):
  gece olayının 03:00'te görünmesi için `hold_clock("incident")` toplu adımı kesmelidir (B0 §4.3 ✅).
- Mesai penceresi `is_night()`'tan farklıdır: gece `workday_end` ile 08:00 arasıdır (`time_manager.gd:208-211`), mesai
  başı 08:00-11:00 (`work_hours_system.gd:112-116`). Teslim ve gece kapısı pencereyi okur.
- Talep: hesap başına bir açık talep, yenileme penceresi satır içi (`sprint_bridges.gd:28-35`), X6 ✅ doğru.
- Sözün `due_sprint`'i `@export`'tur; `extended` alanı `Promise`'e `@export` eklenince SaveCodec kendisi taşır.
- Kurucu `team()`'e girer (`sprint_system.gd:536-538`); `damage_product` ve `convert_audience` fiil listesinde ama
  kolsuz (`effects.gd:43, 73`, `_apply`'da yok).
