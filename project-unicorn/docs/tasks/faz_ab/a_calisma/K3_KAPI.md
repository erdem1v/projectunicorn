# K3 kapı raporu

## Koşu 1

Sonuç: KAPI KAPANMADI. Sprint probe'un adlandırılmış mismatch sayısı taban çizgisini aşıyor (sprint_late 4 > 3, team 4 > 3). Diğer tüm kapılar geçti. Repo dosyası düzenlenmedi; yalnız bu klasöre yazıldı. Regenerate denetimi repo dosyalarını yeniden yazdı ama içerik byte-eş kaldı (cmp ile doğrulandı).

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | class_name satırı kontrolü (git diff) | - | PASS: class_name ekleme/çıkarma yok; `--import` gerekmedi |
| 1 | `grep -rn "FALSIFY-TEMP"` (değişen dosyalar + git diff) | 1 / 1 | PASS: hit yok |
| 2 | `--event-lint` | 0 | PASS: LINT PASS 0 error, 0 warning, 13 baselined, 97 card, 3 arc. Log: `k3_gate/step2_event_lint.log` |
| 3 | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS: 0 hit [CLEAN], csv_keys=3334. Log: `k3_gate/step3_loc_residue.log` |
| 4 | `tools/smoke_run.sh loc_csv_integrity` | 0 | PASS |
| 5 | 98 smoke case, 2 paralel, CASE_TIMEOUT=300, her case kendi APPDATA/HOME | 0 (her case) | PASS: 98/98 SMOKE PASS, FAIL yok. Log: `k3_gate/step5_smoke_all.log` |
| 6a | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | 0 | FAIL: SUMMARY match=231/239 (taban 245/251); mismatch 8 (taban 6). Adlandırılmamış (unnamed) mismatch = 0. Nedenler: product.sprint_late=4 (taban 3), team=4 (taban 3). Yeni adlandırılmış neden yok; sayılar taban üstünde. Log: `k3_gate/sprint/sprint_probe.log` |
| 6b | Regenerate: `--event-vocab` + `tools/gen_signal_manifest.py` (önce yedek, sonra cmp) | 0 / 0 | PASS: `_vocabulary.md` ve `EVENT_SIGNAL_MANIFEST.md` yeniden üretimle byte-eş (cmp IDENTICAL; sha256 öncesi/sonrası aynı). Not: üretici 196 seam, 63 verb, 97 card; manifest 145 sinyal, 2 emitter'sız, 68 listener'sız (K2'de 144 / 2 / 67). Sayı değişimi kodda yeni sinyal olduğunu gösteriyor, dosya ile üretim tutarlı. Kanıt: `k3_gate/regen/` |
| 6c | `--lang=tr --run-log=full_run:30:sim` (APPDATA ayrı) | 0 | PASS (koşullu): PROBE END 1. Motor hatası: yalnız çıkışta `ERROR: 1 resources still in use at exit` satırı (log satır 1013), script hatası yok. Bu satır kapanış gürültüsü; strict okumada "engine error line" sayılırsa FAIL. Log: `k3_gate/runs/full_run.log` |
| 6d | `--lang=tr --run-log=full_run_b2c:30:sim` (APPDATA ayrı) | 0 | PASS: PROBE END 1, ERROR/SCRIPT ERROR satırı 0. Log: `k3_gate/runs/full_run_b2c.log` |
| 6e | §4.1 grep: `mvp_bugs_confirmed\|bugs_confirmed\|ticket_seq\|sync_tickets` (scripts data tools localization) | 0 | 7 hit, hepsi izinli: save_manager.gd 896/909/921 (`_migrate_16` ve `_REMOVED_FLAGS`), endgame_smoke.gd 18872/18875/18904/18907 (save_v15 fixture). Çıktı: `k3_gate/grep_4_1.txt` |
| 7 | 20 windowed shot, sıralı; her biri kendi APPDATA dizininde | 0 (her shot) | PASS: 20/20 çıkış 0; console log'larında ERROR satırı 0. 36 PNG `shots/K3/` içinde, komut adıyla adlandırıldı |

### Sprint probe ayrıntısı

- Taban (`A1d/A1d_TABAN.md`): match=245/251, mvp_days=3x1, sprint_late=3, team=3.
- K3: match=231/239, mvp_days=3x1, sprint_late=4, team=4, toplam mismatch 8.
- Mismatch satırları: `feat:line_shared_mobile_k1@note_tool` (sprint_late), `feat:line_shared_integrations_k1@note_tool` (sprint_late), `feat:line_shared_security_k1@note_tool` (sprint_late), `plan:cap_paid_plan` (sprint_late), `feat:line_note_tool_capture_k2` (team), `feat:line_note_tool_linking_k2` (team), `feat:line_note_tool_search_k2` (team), `fix:line_note_tool_capture` (team).
- Probe log'unda tek ERROR satırı çıkış gürültüsü (`resources still in use`).

### Shot notu

- İlk shot turunda APPDATA `/c/Users/...` biçiminde verildi; Godot bunu göreli yol olarak okudu ve PNG'ler proje kökündeki `c/Users/...` ağacına yazıldı. Her shot yine kendi ayrı `appdata_<n>` dizinini kullandı ve yan etkisi yalnız bu ağaçtı. PNG'ler `shots/K3/` altına komut adıyla taşındı, geçici `c/` ağacı silindi (untracked, benim oluşturduğum). Shot'lar yeniden koşulmadı; konsol logları `shots/K3/*.console.log` altında.
- Shot PNG'leri (36 adet): office_home (tr/en/cb/scale125), product_live_plan / active / week1 (her biri tr/en/cb/scale125; her koşu birden çok kare üretti: plan/skip/start, week1/close/run), inbox_rnd_note_demand (tr/en/cb/scale125).

### Kanıt yerleri

- `docs/tasks/faz_ab/a_calisma/k3_gate/` (adım logları, regen yedekleri, sprint, runs, grep)
- `docs/tasks/faz_ab/a_calisma/shots/K3/` (PNG ve console logları)

### Açık iş

- Sprint probe: product.sprint_late ve team nedenleri taban üstünde (4/4, taban 3/3). Kodcunun ya da tasarımın bu sayıları taban üstüne itip itmediğine karar verilmeli; K3 kapısı bu yüzden kapanmadı.
- Çıkış satırı `ERROR: 1 resources still in use at exit` probe ve run loglarında bulunuyor; strict kapıda hata sayılırsa 6c ayrıca FAIL.

## Koşu 2 (Opus düzeltmesinden sonra; Haiku ajanı 0–4'ü yaptı, 5'i arka planda bıraktı, ana oturum tamamladı)
| Adım | Sonuç |
|---|---|
| 0 | class_name değişikliği yok |
| 1 | FALSIFY-TEMP artığı yok |
| 2 | `--event-lint` 0 hata, 0 uyarı (`k3r2/step2_event_lint.log`) |
| 3 | `loc_residue` 0 isabet (`k3r2/step3_loc_residue.log`) |
| 4 | `loc_csv_integrity` PASS |
| 5 | 98/98 SMOKE PASS, `xargs -P 2`, `CASE_TIMEOUT=300` (`k3r2/step5_summary.txt`, `k3r2/smoke_*.log`) |
| 6a | Sprint probe `match=231/239`, adsız uyuşmazlık 0, adlar `product.sprint_late` ×4 ve `team` ×4 (ikisi de A1d listesinde; sayı artışı Karar 5'in yörünge kayması, Opus incelemesinde açıklandı). PASS (plan ölçütü: adsız 0) |
| 6b | `--event-vocab` + `gen_signal_manifest.py` yeniden üretimi bayt aynı (md5 OK) |
| 6c/6d | `full_run:30:sim` ve `full_run_b2c:30:sim`: birer PROBE END, `engine_errors` boş |
| 6e | Kısmi §4.1 grep: kalan isabetler yalnız `save_manager.gd` `_migrate_16` (897/906/924) ve `endgame_smoke.gd` save_v15 fikstürleri |
| 7 | Opus düzeltmesi oyuncunun gördüğü dosyaya dokunmadı (göç + smoke + HARITA); kareler Koşu 1'den geçerli |

Sonuç: YEŞİL. Kayıtlar `k3r2/` altında; APPDATA `C:\Users\erdem\AppData\Local\Temp\fazA\k3r2\` altında ayrı.
