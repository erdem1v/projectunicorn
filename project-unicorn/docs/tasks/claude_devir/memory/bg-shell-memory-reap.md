---
name: bg-shell-memory-reap
description: "Claude Code arka plan kabuğunu bellek baskısında biçer ama Windows'ta alt süreçler (xargs, Godot) yetim kalıp koşmayı sürdürür; komut satırından bulup kapat, sormadan yeniden başlatma"
metadata:
  node_type: memory
  type: reference
  originSessionId: bdb8d661-b2cc-40d3-a6eb-43f58d809039
  modified: 2026-10-26T14:33:06.400Z
---

2026-10-05 20:35: tam smoke gate'i (`gates.sh`, xargs -P 4, headless Godot) "system is running low on memory" notuyla
`killed` döndü. Erdem aynı anda League of Legends oynuyordu (16 GB RAM, ~4 GB boş).

- **Biçme yalnız izlenen kabuğu öldürür.** Git Bash altındaki `bash gates.sh` → `xargs` → `bash -c run_one` → Godot
  ağacı yaşamaya ve yeni vaka açmaya devam etti. Bul: `Get-CimInstance Win32_Process` + `CommandLine -match
  '<scratchpad klasörü>|run_one'`; önce ana bash ve xargs'ı, sonra kalanları `Stop-Process -Force` ile kapat.
- **Bildirim kuralı:** biçilen komut kendiliğinden yeniden başlatılmaz; ne durduğu ve neden raporlanır, Erdem isteyince
  yeniden koşulur. Aynı baskıda yeni ağır iş (workflow, pencereli shot) de başlatılmaz, önce sorulur.
- Bu makine Erdem'in oyun bilgisayarı; tam smoke 4 yerine 2 paralel koşabilir (CLAUDE §12: `xargs -P 2` + `CASE_TIMEOUT=300`).
- 2026-10-11: maç sürerken alınan zamanlama ölçümleri kanıt değildir (tick-probe p95 2,5 → 9 ms). Maç süreci
  `League of Legends.exe`'dir (lobi `LeagueClient*`, maç değil); `tasklist //FI "IMAGENAME eq League of Legends.exe"`
  ile bak. Açılış makinesinde pencereli koşular bunu `game_wait` ile bekliyor.
- 2026-10-11 09:40: `--tick-probe` iki kare arasındaki gerçek süreyi ölçer (`tick_probe.gd:48-56`).
  - Pencereli koşuda (`shot.sh`) pencere görünürken kareler ekran yenilemesine sabitlenir. Bu monitörde 180 Hz: p50 ≈
    p95 ≈ 5,5 ms, `after_hour` 5,9. Hem eski ağaç hem HEAD aynı çıkar; ölçülen kod değil yenileme aralığıdır.
  - Başsız koşu (CLAUDE §12, ayrı APPDATA) gerçek değeri verir: son main p95 2,45 / 2,34 ms, `after_hour` 0,22.
  - Gece pencereli koşudan çıkan düşük değerler büyük ihtimalle pencere örtülüyken alındı (LoL önde).
- 2026-10-18 (Faz Q): depoda ~7.000 gevşek nesne ve 52 paket var; her `git commit` arkasından otomatik `gc` başlatıyor (~365 MB).
  Bellek baskısında biçildi: commit oluşmuştu, `gc` yarıda kaldı (`.git/gc.pid` bayat, `objects/pack/tmp_pack_*` çöp).
  Önlem: `git -c gc.auto=0 commit ...` (yalnız o komut; depo ayarı değişmez). Bakım (`git gc`) Erdem'in kararı.
- 2026-10-22 (Faz Q K20): with about 3,6 GB free and no game running (Chrome and dwm were the large users), the
  reaper killed the staged gate twice in a row, the second time still at `cp -r .godot`. It reaps while the session is
  idle, no matter how small the command. Godot in the orphan tree had already started (bash → console Godot → Godot);
  kill all three. At this memory level a background run will fail again. The ways out are the user's call: free
  memory (close Chrome tabs), or run in the foreground in chunks of under 10 minutes, or set
  `CLAUDE_CODE_DISABLE_BG_SHELL_PRESSURE_REAP=1` at Claude Code startup.

- **2026-10-26: makineye RAM eklendi, şimdi 32 GB.**
  - Erdem: "bellek tarafında problem yok, testler paralel koşabilir".
  - Yukarıdaki 16 GB dönemi kısıtları gevşer: tam smoke `-P 2` sınırı ve "oturum başına tek Godot" kalktı.
  - Kalan iki kural:
    - Pencereli koşular tek (ekran kartı).
    - Süre ölçümleri sessiz makinede alınır (oyun ya da başka Godot koşarken alınan ölçüm kanıt değildir).
  - Biçme olursa yukarıdaki temizlik yolu hâlâ geçerli.

İlgili: [[smoke-verification-cadence]] · [[lost-session-recovery]] · [[acilis-task-2026-10-10]]
