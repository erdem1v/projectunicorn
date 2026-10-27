---
name: concurrent-session-hazard
description: "Bu workspace'te aynı working tree'ye paralel oturumlar yazabilir — git/screenshot işine başlamadan önce tree'nin canlı olup olmadığını ölç"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 84c47643-80cf-4f1a-947e-47b6f5afb869
  modified: 2026-08-17T08:10:33.542Z
---

Erdem bu projede **aynı checkout'ta birden fazla Claude oturumu** çalıştırıyor. 2026-08-03'te Tema Çekirdeği'ne başlarken tree temiz göründü; 3 dakika içinde önce 2, sonra 7 dosya "modified" oldu — başka bir oturum task 2b'yi (SalesRepSystem) yazıyordu. Daha önce de olmuş: kalibrasyon audit'i (2026-07-17) ve skill audit'i (2026-07-21) notları da "audit sırasında paralel oturum işi belirdi" diyor. Yani bu **tekrar eden bir durum, tek seferlik kaza değil**.

**2026-08-08 (Terminal UI) — en pahalı tekrarı.** Oturum başında tree `6edace1`'de TEMİZDİ ve ben bunu "precondition sağlandı, tek yazar" diye plana yazdım. ~40 dk sonra Step 0'ı (baseline hash gate) koşarken 10 dosya modified çıktı: Settings oturumu ikinci bir batch'e (Native-Resolution + Ultrawide, `task-settings-sunny-adleman.md`) başlamıştı ve **`oda_layout.gd`/`oda_view.gd` dahil ODA yerleşimini yeniden yazıyordu** — yani benim "ODA byte-sabit" gate'imin baseline'ı daha alınırken geçersizdi. Çakışan 7 dosya: `display_settings.gd`, `settings_modal.gd`, `main.gd`, `endgame_smoke.gd`, `project.godot`, `strings.csv`, `oda_*`. Ders: **temiz tree başlangıçta bir kanıt değil, yalnız bir anlık ölçüm** — plan onaylandıktan SONRA, ilk yazmadan hemen önce tekrar ölç.

**2026-08-17 (ODA mühürlü sanat turu) — YENİ ZARAR BİÇİMİ: paylaşılan `.godot/` sınıf önbelleği.** Görev metni "Playable Run Sprint paralel koşuyor; SIFIR paylaşılan dosya" diyordu; DOĞRU DEĞİLDİ. Öteki oturum `main.gd` (bana ait `--oda-shot` bloğuyla aynı dosya), `endgame_smoke.gd`, `strings.csv`, dört autoload (`event_bus/event_manager/game_state/time_manager`) ve beş system'i yazıyordu; `angel_round_system.gd` + `run_probe.gd`'yi YENİ ekledi. Smoke case sayısı benim oturumumun ortasında **153 → 164** oldu (ben o dosyaya dokunmadım). Yeni ve sinsi olan kısım: paralel oturum `class_name` ekleyip/taşıyınca `.godot/global_script_class_cache.cfg` **yarım kalıyor** ve benim koşularım `Parse Error: Identifier "AngelRoundSystem"/"SalesTab" not declared` + `Failed to instantiate an autoload` ile patlıyor — **kendi değişikliğimle hiç ilgisi yok.** Üstelik case yine `SMOKE PASS` basıyor, yani sayı yalan söylüyor. Sonuç: **hareketli tree'de tüm-proje smoke gate'i SERTİFİKA EDİLEMEZ**; ODA-kapsamlı gate'ler (`--theme-audit=oda`, `oda_anchors_stay_in_band`) hâlâ okunabilir çünkü tek alt ağaca bakıyorlar. Ayrıca kendi asılı smoke'umu temizlerken `--endgame-smoke=` ile eşleşen süreçleri öldürdüm ve **öteki oturumun smoke koşusunu da vurmuş olabilirim** — filtreyi komut satırıyla değil kendi tuttuğun PID'le kur.

**Why:** İki somut zarar var. (1) Hash-eşit before/after screenshot'a dayanan her doğrulama (Tema Çekirdeği'nin tüm gate'leri) hareketli tree'de okunamaz — regresyon mu, öteki oturumun commit'i mi ayırt edilemez. (2) `git switch -c` HEAD'i TÜM checkout için taşır; öteki oturum farkında olmadan başka branch'e commit eder. Ayrıca sahipsiz görünen uncommitted değişiklik senin işin olmayabilir — 2026-08-03'te prospect id fix'ini "tree'de duruyordu" diye commit'ledim, meğer 2b'nin altyapısıymış.

**How to apply:**
- Ekran görüntüsü/hash gate'ine dayanan bir işe başlamadan önce tree'nin **canlı olup olmadığını ölç**, tek `git status` ile yetinme: `git status --short` + değişen dosyaların mtime'ı + `date`. 10-15 sn arayla iki snapshot al. Saniyeler önce yazılmış dosya = başka oturum çalışıyor.
- Üç sinyalli hızlı teşhis (2026-08-08'de işe yarayan reçete): (1) `git diff --name-only | while read f; do stat -c '%y %n' "$f"; done | sort -r` → en yeni mtime `date` ile kaç dk farklı; (2) `tasklist | grep -i godot` → editör örnekleri açık mı; (3) headless koşuda **`[MCP Runtime] Failed to start server on port 7777`** → port dolu, yani MCP eklentili bir editör ZATEN çalışıyor. Bu satır tek başına "paralel oturum var" demektir. Ayrıca `ls -lt ~/.claude/plans/` öteki oturumun plan dosyasını ve saatini verir — ne yaptığını oradan oku.
- Aynı addon yüzünden headless koşular **çıkışta asılıyor** (port 7777 thread'i). `timeout 90 <godot> ...` ile sar ve çıktıyı dosyaya yaz; exit 124 tek başına başarısızlık demek değil, `SMOKE` satırını dosyada ara.
- Beklemediğin `M` dosyaları görürsen **diff'e bak, commit etme.** Yorumlar genelde hangi task'a ait olduğunu söylüyor (2b örneğinde `prospect.gd`'de düpedüz "Task 2b: ... SalesRepSystem owns it" yazıyordu).
- Branch açmadan önce düşün: `git switch -c` paylaşılan checkout'ta öteki oturumu da taşır. Geri almak gerekirse `git branch -f main <branch>` (fast-forward, rewrite DEĞİL) + `git switch main` + `git branch -d` sıfır dosya kıpırdatmadan toparlar — `git switch main` ile başlama, o öteki oturumun dosyalarını tree'den siler.
- Çakışma varsa **Erdem'e sor, kendi başına çözme.** 2026-08-03'te "ben çekilirim, 2b insin" dedi.
- **Godot süreçlerini TOPTAN ÖLDÜRME** (`Get-Process *Godot* | Stop-Process`). 2026-08-06'da asılı smoke sürecimi temizlerken iki *editör* örneğini de öldürdüm — büyük ihtimalle paralel ODA oturumunun/MCP'nin editörüydü (isim ayrımı: benim headless koşularım `_console` exe'si, editör düz `Godot_v*_win64`). Yalnız kendi başlattığın, PID'ini `-PassThru` ile tuttuğun süreci öldür.
- **Paylaşılan `user://` AYARLARI da tema denetimini oynatır (2026-08-19, Kalibrasyon Turu A):** `--theme-audit=oda` stylebox renklerini yürürlükteki paletle basar; öteki oturum (ya da Erdem) `settings.json`'daki `colorblind_palette`'i çevirince dökümde iki `bg:` satırı (`oda_health_green()` okuyucuları) değişti — tema değil, ayar. Hüküm verme: tabanı aynı ayar altında yeniden çek (**2026-08-20'den beri worktree ile DEĞİL** — teslim yasası yasakladı: düzenlemeye başlamadan ÖNCE aynı ağaçta dökümü al, değişikliği yap, tekrar al) ve md5 karşılaştır; paylaşılan `settings.json`'ı elle çevirme (eşzamanlı çekimleri kirletir).
- Paralel oturumun YARIM dosyası (2026-08-06: `oda_view.gd` parse hatası) senin headless koşunu her zaman düşürmez — smoke shell'i mount etmez; ama `--import` çıktısında hata olarak görünür. Kendi hatanla karıştırma: dosya sahipliğine bak.

**2026-08-20 — BU TEHLİKE SıNıFı KURALLA KAPATILDI.** Erdem artık ayrı worktree/klasör açılmasını yasakladı: tek klasörde çalışılır, gerçekten gerekiyorsa ÖNCE SORULUR — bkz. [[single-folder-single-remote-rule]]. Yukarıdaki teşhis reçeteleri hala geçerli (aynı checkout'ta iki Claude oturumu hâlâ mümkün), ama worktree kaynaklı biçimleri — paylaşılan `.godot/` sınıf önbelleği, geçici `git worktree add` ile taban çekme — artık reddedilmeli. Tema tabanını worktree ile değil, aynı ağaçta merge ÖNCESİ döküm alarak kur (2026-08-20 birleştirmesinde böyle yapıldı: A/B/C dökümü).

İlgili: [[project-unicorn-current-stage]], [[smoke-verification-cadence]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Concurrent session hazard](concurrent-session-hazard.md) — aynı checkout'ta paralel oturumlar yazıyor; screenshot/hash gate'li işe başlamadan tree'nin canlı olup olmadığını ölç, sahipsiz uncommitted değişikliği commit etme · **2026-08-20'den itibaren büyük ölçüde KAPANDI — worktree yasak, tek klasör**
