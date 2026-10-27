---
name: github-repo-projectunicorn
description: "Project Unicorn GitHub repo location, structure quirk, and how local syncs to it"
metadata: 
  node_type: memory
  type: project
  originSessionId: 056369b3-7d80-4913-ab6b-0f7f859946b9
  modified: 2026-10-27T16:15:06.359Z
---

Project Unicorn (Godot 4 startup-sim) GitHub remote: `https://github.com/erdem1v/projectunicorn` (branch `main`).

**2026-10-27: the repo is PUBLIC** (verified with an unauthenticated GitHub API call; this file used to say private).
Erdem's answer: "Repo'nun public olması hiçbir şey değiştirmiyor... Uğraştırma beni." Put his own material in the repo
(docs/tasks, memory, session transcript) and do not hold a push because the repo is public. He will make it private
himself. `docs/tasks/` is tracked again since this push. Decision 23 is on hold. `gh` is not installed on the desktop.

**TESLİM YASASI 2026-08-20 (bu dosyadaki her şeyin üstünde):** dal yok, worktree yok, merge yok. İş doğrudan `main`'e commit edilir, uzakta yalnız `main` durur ve **push YALNIZ Erdem "push et" deyince** yapılır. Aşağıdaki push günlüğü tarihseldir; hâlâ geçerli tek kalıp `git add -A -- project-unicorn/` + `git commit -F <utf8-dosya>` (PowerShell 5.1 TR karakterleri bozmasın diye). Bkz. [[single-folder-single-remote-rule]].

**Yapı tuzağı:** Repo kökü TÜM workspace'i kapsıyor (`.agents/`, `.claude/`, `.gitignore`, `skills-lock.json` + `project-unicorn/` Godot projesi). Yani git repo kökü = `C:\Users\erdem\Desktop\project steam` workspace'inin kendisi; Godot projesi onun altında `project-unicorn/` alt klasöründe (`project-unicorn/project.godot`). `project-unicorn` klasörünün İÇİNE klonlamak çift-iç-içe yapı yaratır — köke klonlanmalı.

2026-06-26'da sync yapıldı: bu PC'deki local eskiydi (en yeni dosya 18 May), GitHub güncel. "Yedekle + temiz klonla" ile senkronlandı; eski Godot projesi `project-unicorn-OLD-backup/` olarak duruyordu — **2026-08-20'de Erdem onayıyla DİSKTEN SİLİNDİ** (git'e hiç girmemişti).

**2026-07-02 push (local → GitHub):** local'deki tüm birikmiş iş tek commit'te push'landı. `origin/main` HEAD artık `aab3497` "Local sync: UI açık-tema geçişi, rival/quality sistemleri, ses + ayarlar menüsü" (üstünde `d28d3d5` Faz 1 bug-fix + `dafd33c` initial). Author/committer = `erdem1v <erdemsalman1@gmail.com>` (git config). **Bilerek staging DIŞI tutulanlar:** `project-unicorn-OLD-backup/` (geçici yedek) + `.claude/settings.local.json` (makine-yerel Claude ayarı). `git add -- project-unicorn/` ile sadece Godot projesi commit'lendi. Not: Türkçe commit mesajı için `git commit -F <utf8-file>` kullanıldı (PowerShell 5.1 kod sayfası ö/ü'yü bozmasın diye).

**2026-07-03 push:** `aab3497..8577529` → `origin/main`. İçerik: 37b5a00 (akıcı build + Space), audit doc, B1 dil, Blok D event'ler, fac923c görsel paketi + 8c41f3d/5ab5bdb revert'leri, 8577529 (Fiyatlandır default-turuncu salt-fix'i — Erdem isteğiyle bu commit'te Co-Authored-By YOK, author erdem1v). Ağdaki net görsel durum ≈ aab3497 UI + turuncu fix.

**2026-07-14 push:** `8577529..445ac60` → `origin/main`. Tek büyük sync commit (115 dosya, +8739/−1558): 8577529 sonrası TÜM birikmiş iş — endgame motorları (slot 8/9, 7 ending, Kepenk), Ay Sonu özeti, kapasite havuzu + canlı-sürüm kanonu, ConfirmModal, **Spec 5** (MeetingScene + FrankPopup sinematik kabuk + 3 bileşen + koyu theme register + görseller), **Spec 4** (VCPitchSystem + InvestorRegistry/TermSheet/PitchConstants + Yatırım tab/HuntTab + placeholder masa modalı + TopBar chip), ENDGAME_DESIGN + VC_PITCH_DESIGN kanon dokümanları, 30-case smoke harness. Author erdem1v; Co-Authored-By Claude var. `git add -A -- project-unicorn/` (OLD-backup yine staging DIŞI, hâlâ diskte untracked). Bash tool + `git commit -F <utf8-file>` ile TR mesaj bozulmadı. Görsel katman (Yatırım tab, MeetingScene §8) Erdem F5 bekliyor.

**2026-07-21 push:** `c4eba05..3ee3963` → `origin/main` (aradaki 919cc7a/c4eba05 başka oturumlarca zaten push'lanmıştı — 445a... "son push" notu bayattı). Tek sync commit (90 dosya, +7313/−5461): Ürün Rev3 (scripts/tabs/product/ + TriangleRadar), Ending Screen "Ekonomi Postası" (EndingScene/EndingsCopy; EndingModal + PitchDialogueModal silindi, b2b_pitch_meeting.gd geldi), kalibrasyon merkezileştirme sweep'i + tr_upper eki (CustomerArchetypes, fmt_probe + scenes/debug/), iki audit dokümanı. Kalıp aynen işledi: `git add -A -- project-unicorn/`, Bash + `git commit -F <utf8-file>` (TR mesaj bozulmadı), Co-Authored-By Claude var. OLD-backup artık status'ta GÖRÜNMÜYOR (diskten silinmiş ya da ignore edilmiş — dışlama derdi kalmadı).

**2026-08-08 push (Erdem isteği "localdeki güncel sürümün tamamı"):** `c069b56..a71d762` → `origin/main`. Üç commit gitti: cf48c92 (prospect id fix) + cb20a18 (Font Duruşması) zaten localdeydi, üstüne tek sync commit a71d762 (116 dosya, +11.122/−1.043): Tema Çekirdeği kapanışı, ODA merkez görünüm + kalite fix v2, dünya inandırıcılığı (CompanyCatalog/NewsFeed), HR/Finans F5 fix'leri, otonom satış task 2b, tam-oyun auditi + lokalizasyon Faz 1 raporu. Kalıp aynen: `git add -A -- project-unicorn/`, Bash + `git commit -F <utf8-file>`, Co-Authored-By Claude. Push sonrası tree TEMİZ (0 kirli giriş) — paralel oturumların tüm birikmiş işi artık committed.

**2026-08-08 ikinci push (Erdem: "şu anda lokaldeki güncel sürümü pushla"):** `a71d762..6edace1` → `origin/main`. Tek commit 6edace1 (70 dosya, +3409/−360, 12 yeni dosya): Ayarlar genişletmesi + Save/Load sistemi. Kalıp yine aynı ve yine işledi: `git add -A -- project-unicorn/` (staging dışında hiçbir şey kalmadı — kök dosyaları zaten temizdi), Bash + `git commit -F <utf8-file>` (TR karakterler bozulmadı), Co-Authored-By Claude. Push sonrası tree TEMİZ. **Not: push, tam smoke süiti HÂLÂ KOŞARKEN yapıldı** (Erdem "şu anda" dedi; o ana kadar 0 hata + üç yeni case tek tek yeşildi) — süit sonra 147/147 PASS ile kapandı. Ardından küçük bir takip commit'i: `6edace1..3b3cf29` (F9 guard'ı). Ders: "şu anda pushla" denince süit bitmesini beklemek yerine push edip durumu açıkça söylemek doğru oldu, ama takip commit'i kaçınılmaz oldu — mümkünse süiti push'tan ÖNCE bitir.

İlgili: [[project-unicorn-current-stage]]
