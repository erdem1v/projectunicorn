| Key (proposal) | EN | TR | Kind | Where |
|---|---|---|---|---|
| `agency` | Atlas Recruitment | Atlas Recruitment | recase | HR_AGENCY_NAME is a proper noun: no caps |
| `arrival` | Candidates arrive within {span} | Adaylar {span} içinde gelir | recase | HR_ATLAS_ARRIVAL, capital first letter |
| `atlas_sender` | Atlas | Atlas | recase | DESK_PAPER_TAG_ATLAS as the notice stack's sender: the full agency name ellipsises EN '3 candidate files ready' in the 352 card under the 8 % pass |
| `brand` | Project Unicorn | Project Unicorn | new | top bar brand block, decision 14 (a), as group olaylar |
| `build_team` | Build team | Yapım ekibi | recase | HR_JOB_BUILD TR 'Build ekibi' is English in TR text; the task line already says 'Yapımda' |
| `cancel` | Cancel | Vazgeç | recase | HR_ATLAS_CANCEL / UI_DISMISS as a button, sentence case |
| `commission_once` | one-off | tek seferlik | new | after the commission figure in a file |
| `file_n` | File {i}/{n} | Dosya {i}/{n} | recase | HR_ATLAS_FILE_N as a caps kicker via Fmt.upper |
| `fire_neg` | Cash goes below zero. The {n}-week shutter countdown starts. | Kasa eksiye düşer. {n} haftalık kepenk sayacı başlar. | new | fire dialog when cash_after < 0 (bedel görünür) |
| `founder_build` | Working on the build | Yapımda görev alıyor | change | HR_FOUNDER_STATE_BUILD takes the employees' sentence (HR_TASK_ON_JOB_BUILD); today TR 'Bir yapımda çalışıyor', EN 'Working on a build' |
| `free_note` | The search is free · commission is paid on the hire | Arama ücretsiz · komisyon işe alımda ödenir | recase | HR_ATLAS_FREE_NOTE, capital first letter |
| `hire` | Hire · {amount}/mo | İşe al · {amount}/ay | recase | HR_ATLAS_HIRE, sentence case; one amber button for the selected file |
| `hours_band` | Office day | Ofis günü | new | Mesai panel: caption of the day band |
| `hours_over` | {n} on overtime | {n} çalışan mesaide | split | chip tail; HR_HOURS_CHIP_OVERTIME cut after {window} |
| `hours_win` | {start} to {end} | {start} ile {end} arası | new | hours chip, SPEC §13 (HR_HOURS_WINDOW carries an en dash) |
| `idle_n` | {n} idle | {n} boşta | recase | HR_CHIP_IDLE_COUNT as a tag (caps by Fmt.upper) |
| `idle_tag` | Idle | Boşta | recase | HR_BADGE_IDLE as the idle row's Durum tag (caps by Fmt.upper) |
| `legend_locked` | locked | kilitli | new | Görevler legend: dashed box with a lock; lower case like the head legend's 'ana / ikincil' |
| `legend_noarea` | no area | alanı yok | split | HR_LEGEND_NO_AREA cut at the dot, lower case like the head legend; 'atanamaz' is the dashed box |
| `open_file` | Open file | Dosyayı aç | new | row menu first item (system page 03 shows it) |
| `open_files` | Open the files | Dosyaları aç | recase | HR_OPEN_FILES button, sentence case |
| `over_n` | {n} overloaded | {n} aşırı yük | recase | HR_CHIP_OVERLOAD_COUNT as a tag |
| `overload` | Overloaded | Aşırı yük | recase | HR_BADGE_OVERLOADED_JOBS tag (caps by Fmt.upper) |
| `raise_apply` | Apply raise · +{pct} | Zammı uygula · +{pct} | recase | HR_APPLY_RAISE_PCT, sentence case |
| `recruit` | Start recruitment | İşe alım başlat | recase | HR_SEARCH_START / _INLINE, plus becomes an icon (SPEC §13) |
| `role_col` | Role | Rol | new | compact roster column head (sıkı kip) |
| `search_cancel` | Cancel search | Arayışı iptal et | recase | HR_SEARCH_CANCEL, sentence case |
| `start_search` | Start search | Arayış başlat | recase | HR_ATLAS_START, sentence case |
| `train_cta` | Send to training · {fee} | Eğitime gönder · {fee} | recase | HR_TRAINING_CTA, sentence case |
| `training_tag` | In training | Eğitimde | split | Durum tag; HR_STATE_TRAINING split into tag + {n} weeks like the leave tag |
