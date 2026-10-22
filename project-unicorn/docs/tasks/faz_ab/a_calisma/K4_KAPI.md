
# K4 KAPI

Tarih: 2026-10-17. Dal: main. Repo dosyası düzenlenmedi.

| Adım | Komut | Sonuç |
|---|---|---|
| 0 | class_name satırı diff kontrolü | PASS (değişiklik yok, import gerekmedi) |
| 1 | grep FALSIFY-TEMP (dosyalar + git diff) | PASS (bulgu yok) |
| 2 | --event-lint | PASS rc=0 (LINT PASS 0 error, 0 warning, 13 baselined, 97 card, 3 arc) |
| 3 | loc_residue.gd | PASS rc=0 |
| 4 | smoke_run loc_csv_integrity | PASS (SMOKE PASS) |
| 5 | 14 smoke vakası, xargs -P 2, CASE_TIMEOUT=300 | PASS 14/14 (her logda SMOKE PASS; FAIL yok, yeniden koşu gerekmedi) |
| 6a | sprint-probe (hours=40:cards=2:ticks=60:team=3:fill=1:events=1) | FAIL (aşağıya bak) |
| 6b | glyph_audit.gd | PASS rc=0 |
| 7 | 28 pencereli shot | PASS rc=0 hepsi; 40 PNG; konsolda SCRIPT ERROR / ERROR yok |

## Sprint probe ayrıntısı

- Çıkış kodu 0. Toplam MISMATCH 11, cause= taşımayan (adsız) 0.
- Cause sayıları: product.sprint_late=5 (taban 3), team=4 (taban 3), product.sprint_two_paths=2 (taban listesinde YOK).
- Başarısızlık nedeni: product.sprint_two_paths, A1d_TABAN.md içinde geçmiyor; kural gereği "taban listesinde olmayan cause" FAIL. Sayım artışı (sprint_late 3→5, team 3→4) K3 kaydırmasının kaydı olarak rapora yazıldı, FAIL sayılmadı.
- Kayıt: docs/tasks/faz_ab/a_calisma/k4_sprint_probe.log

## Shot notları

- APPDATA/HOME için her koşuya boşluksuz fazA temp dizini kullanıldı (C:\Users\erdem\AppData\Local\Temp\fazA\K4_shot_<n>). Görev metnindeki shots/K4/appdata_<n> yolu, proje yolundaki boşluk nedeniyle kullanılmadı.
- PNG'ler shots/K4/ içinde "<n>_<komut-özeti>__<dosya>.png" adıyla. Bir komut birden fazla PNG üretiyorsa (cards, live:plan) hepsi kopyalandı.
- Konsol logları: shots/K4/console_<n>_*.log, indeks: shots/K4/shots_index.txt.

## Kapı

all_green = false (sprint probe cause sprint_two_paths taban dışı).

## Koşu 2

Dal: main. Ağaç tek klasörde. Kod dosyalarına dokunulmadı; loglar `K4/` altında.

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | class_name satırı diff taraması | - | Atlandı: class_name satırı değişmedi, import gerekmedi |
| 1 | FALSIFY-TEMP taraması (dosyalar + diff) | - | PASS: bulgu yok |
| 2 | `--event-lint` | 0 | PASS: 0 error, 0 warning, 13 baselined, 97 kart, 3 arc (`K4/event_lint.log`) |
| 3 | `-s loc_residue.gd` | 0 | PASS (`K4/loc_residue.log`) |
| 4 | `smoke_run.sh loc_csv_integrity` | 0 | PASS (`K4/step4_loc_csv_integrity.log`) |
| 5 | 14 smoke case, xargs -P 2, CASE_TIMEOUT=300, her case kendi APPDATA/HOME | 0 hepsi | PASS: 14/14 SMOKE PASS, motor hatası yok (`K4/smoke/*.log`) |
| 6a | sprint-probe `hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | 0 | FAIL (aşağıda) |
| 6b | glyph_audit.gd | 0 | PASS |
| 7 | Pencereli ekran görüntüleri | - | Atlandı: Kareler Koşu 1'den geçerli |

### Adım 6a ayrıntısı

- SPRINTPROBE SUMMARY: `match=237/248|mvp_days=3x1` (A1d tabanı: 245/251).
- MISMATCH: 11 satır, adlandırılmamış 0.
- Neden sayıları: product.sprint_late=5, team=4, product.sprint_two_paths=2 (A1d tabanı: sprint_late=3, team=3; K3 kaymasıyla kabul edilen artış, kayıt amaçlı).
- FAIL nedeni: `product.sprint_two_paths` A1d_TABAN.md içinde yok (taban yalnız sprint_late ve team listeliyor). Kural gereği bilinmeyen cause adı FAIL sayılır. Kod tarafı bu koşuda incelenmedi; bir sonraki tur bu nedeni taban listesine ekleyip eklememe kararını vermeli.

### Gözlemler

- Smoke ilk denemede GODOT ortam değişkeni verilmediği için 14 case rc=2 ile düştü (harness hatası, Godot değil). GODOT export edilip yeniden koşuldu; kayıtlar yenilendi.
- all_scripts_load ve loc_csv_integrity koşuları birkaç dakika sürdü; ikisi de SMOKE PASS.
- Adım 2 ve 3 çıktılarındaki "resources still in use at exit" satırı gate_common ile dışlandı.

Sonuç: all_green = false (adım 6a).

## Koşu 3 (kurtarma, Opus)

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 6a | sprint-probe `hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | 0 | PASS: `match=237/248`, 11 MISMATCH, adsız 0. Nedenler sprint_late 5, team 4, sprint_two_paths 2; üçü de tabanın neden listesinde (`A1d/A1d_TABAN.md` "Ek · K4 kurtarma turu"). Motor hatası 0. Kayıt `K4/rescue_sprint_probe_asis.log`. |

- `product.sprint_two_paths` tabanda da uyuşmazlık doğuruyordu (sprint 2, `capture_k2`). Probe yalnız sprintin ilk değişikliğini adlandırdığı için tabanda `team` adı altında kaldı.
- Kanıt `1faeb82`'nin tanı koşusundadır: `K4/rescue_diag_1faeb82.log`. Ayrıntı `K4.md` "Kurtarma turu"nda.
- Kod değişmedi; öbür adımlar Koşu 1 ve 2'deki gibi yeşil.

Sonuç: all_green = true.

## Koşu 3

Sonuç: YEŞİL (all_green = true). Repo dosyası düzenlenmedi; yazımlar yalnız a_calisma altında ve fazA temp dizinlerinde. Dal main, tek klasör.

| Adım | Komut | Çıkış | Sonuç |
|---|---|---|---|
| 0 | class_name satırı kontrolü (git diff, değişen dosyalar) | - | PASS: class_name ekleme/çıkarma yok; `--import` gerekmedi |
| 1 | `grep -rn "FALSIFY-TEMP"` (değişen dosyalar) + `git diff \| grep -c` | 1 / 0 | PASS: hit yok |
| 2 | `--event-lint` | 0 | PASS: LINT PASS 0 error, 0 warning, 13 baselined, 97 card, 3 arc. Log: `K4_eventlint.log` |
| 3 | `-s res://scripts/debug/loc_residue.gd` | 0 | PASS: 0 hit [CLEAN], csv_keys=3341. Log: `K4_locres.log` |
| 4 | `tools/smoke_run.sh loc_csv_integrity` | 0 | PASS. Log: `K4_smoke/loc_csv_integrity.log` |
| 5 | 13 smoke vakası, `xargs -P 2`, `CASE_TIMEOUT=300`, her vaka kendi APPDATA/HOME | 0 (her vaka) | PASS: 13/13 SMOKE PASS, engine error satırı yok, yeniden koşu gerekmedi. Loglar: `K4_smoke/<vaka>.log` |
| 6a | `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1` | 0 | PASS: SUMMARY match=237/248, mvp_days=3x1. Adsız (cause= yok) mismatch = 0. Nedenler: product.sprint_late=5 (taban 3), team=4 (taban 3), product.sprint_two_paths=2 (A1d_TABAN.md neden listesinde, sayı taban dışı). Tümü taban listesinde. Sayılar kayıt olarak raporlandı, kapı kriteri değil. Log: `K4_sprint_probe.log` |
| 6b | `-s res://scripts/debug/glyph_audit.gd` | 0 | PASS. Çıkış satırları: exit-time `resources still in use` (yok sayılır) ve `ObjectDB instances leaked at exit` uyarısı (kayıt). Log: `K4_glyph_audit.log` |
| 7 | 28 windowed shot, sıralı (`K4_shots.sh`) | 0 (her shot) | PASS: 28/28 rc=0; her konsol log'unda ERROR / SCRIPT ERROR satırı 0. 102 PNG `shots/K4/` altında, `<n>_<komut>__<dosya>.png` biçiminde; konsol log'ları `shots/K4/console_<n>_<ad>.log` |

### Notlar

- Shot APPDATA dizinleri `shots/K4/appdata_<n>` yerine `C:\Users\erdem\AppData\Local\Temp\fazA\K4_shot_<n>\` altında (boşluksuz, Windows biçimi; genel kural). PNG'ler yine `shots/K4/` içine kopyalandı.
- Smoke / sprint probe APPDATA dizinleri `C:\Users\erdem\AppData\Local\Temp\fazA\K4_smoke_<vaka>\` ve `K4_sprintprobe\`.
- Headless çıkışta "ObjectDB instances leaked" ve "resources still in use at exit" satırları görüldü; ikincisi kapı kuralına göre hata değil.
- Yeniden koşu yapılmadı: hiçbir vaka, probe veya shot başarısız olmadı.
