---
name: taskstop-orphan-child
description: "TaskStop arka plan kabuğunu öldürür ama içindeki `bash betik.sh` alt süreci yaşar; kilit bekleyen döngü yetim kalıp sonra kilidi alır (2026-10-26)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: cb69ca60-0d91-4669-bf47-f4c28dfeaca0
  modified: 2026-10-26T17:25:50.352Z
---

TaskStop bir arka plan Bash görevini durdurunca yalnız dış kabuk ölür; onun çağırdığı `bash land.sh …` gibi alt betik yetim
olarak sürer. 2026-10-26'da kapı kilidini bekleyen `land.sh` döngüsü böyle yetim kaldı, 57 dakika sonra kapıyı aldı ve aynı
commit'i ikinci kez kurmaya başladı (commit'e varmadan `kill` ile durduruldu; kilidi EXIT tuzağı bıraktı).

**Why:** ORTAK_CALISMA kilitleri `mkdir` klasörleridir; yetim süreç kilidi alıp başka oturumun sırasını yer, ya da çift commit
dener.

Aynı gün ikinci tuzak: koşan bir bash betiğini (`land.sh`) düzenlemek onu bozar, çünkü bash dosyayı satır satır okur; I01 commit'i
kapı içinde "unexpected EOF" ile düştü. Uzun koşan betiği her koşuda donmuş bir kopyadan çalıştır (`cp land.sh land_run_X.sh`).

**How to apply:** Arka plan görevini durdurduktan sonra `ps -ef | grep <betik adı>` ile alt süreci ara ve `kill <pid>` et; kilit
klasöründe kendi etiketli sahip dosyası kaldıysa `rm sahip && rmdir`. Uzun bekleyen döngüyü yeniden kurmak gerekirse önce eskisini
böyle temizle. İlgili: [[bg-shell-memory-reap]], [[concurrent-session-hazard]].
