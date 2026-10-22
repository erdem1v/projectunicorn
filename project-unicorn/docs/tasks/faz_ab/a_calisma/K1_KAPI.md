# K1 kapı koşusu (Faz A, koşu 1)

Koşu makinesi: gate runner. Repo dosyalarına dokunulmadı; çıktılar yalnız bu klasörde.

## Adım sonuçları

| # | Adım | Komut / kanıt | Sonuç |
|---|---|---|---|
| 0 | class_name değişikliği | `git diff` içinde class_name satırı yok | PASS (import gerekmedi) |
| 1 | FALSIFY-TEMP artığı | değişen dosyalar + diff: 0 eşleşme | PASS |
| 2 | event-lint | `--event-lint` exit 0; `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 98 card(s), 3 arc(s)` (K1_runs/event_lint.log) | PASS |
| 3 | loc_residue | exit 0; `script tr-char=0 ascii-tr=0 static-tr=0 / scene prose=0 fakekey=0 multiline=0` (K1_runs/loc_residue.log) | PASS (çıkışta "resources still in use" uyarısı, exit 0) |
| 4 | loc_csv_integrity smoke | `SMOKE PASS loc_csv_integrity` (K1_runs/smoke_loc_csv_integrity.log; ilk koşu varsayılan APPDATA ile, ayrıntı aşağıda) | PASS |
| 5 | Smoke, 65 vaka, 2 paralel | `SMOKE PASS` 65 / `SMOKE FAIL` 0 (K1_runs/smoke_all.log) | PASS 65/65 |
| 6a | Sprint probe | exit 0; 6 mismatch: `product.sprint_late`=3, `team`=3; unnamed=0; baseline ile aynı (K1_runs/sprint_probe.log) | PASS |
| 6b | tools/run_gate.sh | full_run ok (day 104, running_on_fumes), full_run_b2c ok (day 104), full_run_vc_cautious ok (day 69, series_a_close); errs=0; `RUN SUMMARY 3/3 ok` (K1_runs/run_gate.log) | PASS |
| 6c | Ekonomi kayması | aşağıda | kayıt (kapı kararı yok) |
| 7 | Windowed shot, 24 komut sıralı | SHOT_EXIT 0 hepsi; ERROR/SCRIPT ERROR satırı yok (K1_runs/shots.log, konsol logları shots/K1/console_*.log); 36 PNG shots/K1/ | PASS |

## Ekonomi kayması (6c)

Taban: `A1d/full_run_7.log`, `A1d/full_run_b2c_7.log`. Koşu: `K1_runs/full_run.log`, `K1_runs/full_run_b2c.log`.


| Koşu | Taban | K1 |
|---|---|---|
| full_run | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=9/9 finite_runway_p2=3/55 finite_runway_p3=0/39 min_cash_pre_seed=5461 seed_day=18 first_sign_day=9 first_revenue_day=10 cheque_day=13 open_w1_12=5 idle_w1_12=0` | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=9/9 finite_runway_p2=4/55 finite_runway_p3=0/39 min_cash_pre_seed=5461 seed_day=18 first_sign_day=9 first_revenue_day=10 cheque_day=13 open_w1_12=5 idle_w1_12=0` |
| full_run_b2c | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=8/8 finite_runway_p2=9/63 finite_runway_p3=0/32 min_cash_pre_seed=4936 seed_day=39 first_sign_day=-1 first_revenue_day=9 cheque_day=17 open_w1_12=0 idle_w1_12=0` | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=8/8 finite_runway_p2=14/83 finite_runway_p3=0/12 min_cash_pre_seed=4439 seed_day=49 first_sign_day=-1 first_revenue_day=9 cheque_day=21 open_w1_12=0 idle_w1_12=0` |

Not: full_run b2c için `finite_runway_p2` 9/63 → 14/83, `p3` 0/32 → 0/12, `min_cash_pre_seed` 4936 → 4439, `seed_day` 39 → 49, `cheque_day` 17 → 21. full_run için `finite_runway_p2` 3/55 → 4/55; diğer alanlar aynı. Kapı kararı verilmedi; değerlendirme insan tarafında.

PROBE STATE (son satır, day=103)

| Koşu | Taban | K1 |
|---|---|---|
| full_run | `cash=565844 mrr=186993 cust=320 emp=13 aud=0` | `cash=559458 mrr=188784 cust=314 emp=11 aud=0` |
| full_run_b2c | `cash=553316 mrr=159104 cust=1 emp=10 aud=57148` | `cash=538391 mrr=121920 cust=1 emp=7 aud=36285` |

Tam satırlar: taban `A1d/full_run_7.log`, `A1d/full_run_b2c_7.log`; K1 `K1_runs/full_run.log`, `K1_runs/full_run_b2c.log`.

## Notlar

- Smoke 65 vaka `K1_runs/cases.txt` listesinden; listede `loc_csv_integrity` iki kez koştu (adım 4 varsayılan APPDATA ile, adım 5 izole APPDATA ile). İkisi de PASS.
- Adım 4 ilk koşusu varsayılan APPDATA kullandı; izolasyon kuralına uymuyor. Vaka salt okunur görünüyor ve adım 5'te izole olarak yeniden geçti.
- Exit sonrası "ObjectDB instances leaked" ve "resources still in use" uyarıları event-lint, loc_residue ve smoke logunda görüldü; exit kodu etkilemedi.
- Economy shift: `finite_runway_p2/p3`, `aud`, `cust` ve `emp` taban ile farklı. Kapı kararı verilmedi; değerlendirme insan tarafında.

## Koşu 2

Koşu makinesi: gate runner (run 2). Repo dosyalarına dokunulmadı; çıktılar yalnız bu klasörde (K1_runs/, shots/K1/). Smoke ve gate koşuları ayrı APPDATA/HOME dizinleriyle yapıldı; MCP portu 7777 paylaşıldığı için Godot koşuları sıralı çalıştırıldı.

| # | Adım | Komut / kanıt | Sonuç |
|---|---|---|---|
| 0 | class_name değişikliği | `git diff` (12 değişen dosya) içinde class_name satırı yok | PASS (import gerekmedi) |
| 1 | FALSIFY-TEMP artığı | değişen dosyalar + `git diff`: 0 eşleşme | PASS |
| 2 | event-lint | exit 0; `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 98 card(s), 3 arc(s)` (K1_runs/event_lint.log) | PASS |
| 3 | loc_residue | exit 0; `LOC RESIDUE: 0 hit(s) [CLEAN] (csv_keys=3349)` (K1_runs/loc_residue.log) | PASS |
| 4 | loc_csv_integrity smoke | `SMOKE PASS loc_csv_integrity` (K1_runs/smoke_loc_csv_integrity.log) | PASS |
| 5 | Smoke, 65 vaka, xargs -P 2, CASE_TIMEOUT=300 | 65/65 exit 0; her logda `SMOKE PASS`; `Parse Error|Compile Error|Failed to instantiate|SCRIPT ERROR|ERROR:` eşleşmesi 0 (K1_runs/smoke/<vaka>.log, özet K1_runs/smoke/_summary.txt, vaka listesi K1_runs/smoke_cases.txt). Tekrar koşuya gerek kalmadı. | PASS 65/65 |
| 6a | Sprint probe | exit 0; 6 MISMATCH satırı, hepsi `cause=` taşıyor (unnamed=0): `product.sprint_late`=3, `team`=3. Baseline A1d_TABAN ile aynı; yeni adlandırılmış neden yok (K1_runs/sprint_probe.log) | PASS |
| 6b | tools/run_gate.sh | full_run RUN OK (day 104, running_on_fumes, errs=0); full_run_b2c RUN OK (day 104, running_on_fumes, errs=0); full_run_vc_cautious RUN OK (day 69, series_a_close, errs=0); `RUN SUMMARY 3/3 ok`; exit 0 (K1_runs/run_gate.log) | PASS |
| 6c | Ekonomi kayması | aşağıda | kayıt (kapı kararı yok) |
| 7 | Windowed shot, 24 komut sıralı, her biri kendi APPDATA'sı | 24/24 exit 0; `ERROR` içeren konsol satırı 0; 36 PNG shots/K1/ altında, ad öneki komut sırası (shots/K1/_shots_summary.txt, konsol logları shots/K1/<n>-*.console.log) | PASS |

## Ekonomi kayması (6c, koşu 2)

Koşu: `--lang=tr --run-log=<preset>:104:sim:7`. Taban: A1d/full_run_7.log ve A1d/full_run_b2c_7.log.

PROBE END:

| Preset | Taban | Koşu 2 |
|---|---|---|
| full_run | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=9/9 finite_runway_p2=3/55 finite_runway_p3=0/39 min_cash_pre_seed=5461 seed_day=18 first_sign_day=9 first_revenue_day=10 cheque_day=13 open_w1_12=5 idle_w1_12=0` | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=9/9 finite_runway_p2=4/55 finite_runway_p3=0/39 min_cash_pre_seed=5461 seed_day=18 first_sign_day=9 first_revenue_day=10 cheque_day=13 open_w1_12=5 idle_w1_12=0` |
| full_run_b2c | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=8/8 finite_runway_p2=9/63 finite_runway_p3=0/32 min_cash_pre_seed=4936 seed_day=39 first_sign_day=-1 first_revenue_day=9 cheque_day=17 open_w1_12=0 idle_w1_12=0` | `PROBE END day=104 run_active=false ending=running_on_fumes finite_runway_p1=8/8 finite_runway_p2=14/83 finite_runway_p3=0/12 min_cash_pre_seed=4439 seed_day=49 first_sign_day=-1 first_revenue_day=9 cheque_day=21 open_w1_12=0 idle_w1_12=0` |

Son PROBE STATE (day=103; cash, mrr, cust, emp, aud):

| Preset | Taban | Koşu 2 |
|---|---|---|
| full_run | cash=565844, mrr=186993, cust=320, emp=13, aud=0 | cash=559458, mrr=188784, cust=314, emp=11, aud=0 |
| full_run_b2c | cash=553316, mrr=159104, cust=1, emp=10, aud=57148 | cash=538391, mrr=121920, cust=1, emp=7, aud=36285 |

Yorum (kayıt): full_run'da sonuç ve ilk gelir/çek günleri tabanla aynı; p2 finite runway 3→4 ve son nakit/MRR/çalışan sayısı küçük oynadı. full_run_b2c'de p2 9/63→14/83, seed_day 39→49, cheque_day 17→21, emp 10→7, MRR 159 bin→122 bin, aud 57 bin→36 bin; belirgin kayma var ve ilgili preset sahibi değerlendirmeli. Her iki preset de running_on_fumes ile bitti; kapı kararı bu adımda verilmedi.

Notlar: Tüm Godot koşularında çıkışta `ObjectDB instances leaked` ve `ERROR: 1 resources still in use at exit` satırları görüldü; bunlar kapanış uyarısıdır, exit 0 ve bu sürümde hata satırı olarak sayılmadı. Smoke runner bu satırları engine error olarak yakalamadı (vaka PASS).
