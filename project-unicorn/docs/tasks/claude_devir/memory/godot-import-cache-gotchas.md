---
name: godot-import-cache-gotchas
description: "Yeni PNG kurunca Godot bayat .ctex servis eder; --import ise sonraki koşuyu class-cache hatasıyla düşürür — sıra: --import, bir ısınma koşusu, sonra gate'li batarya"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 184c9fed-be7b-4ced-8777-2e12ecb0dd5b
  modified: 2026-08-25T10:05:57.467Z
---

Godot 4.6'da `.godot/` derleme önbelleği iki ayrı tuzak barındırıyor ve ikisi de "kod hatası" gibi okunuyor. 2026-08-17 ODA mühürlü sanat turunda ikisi de tek oturumda ısırdı.

**1. Kaynak PNG'yi üzerine yazmak yetmez — Godot bayat `.ctex`'i servis etmeye devam eder.** Sekiz yeni 3840×2160 katman kurdum, sabitleri yeni ölçümlere göre güncelledim ve dokuz shot aldım: telefon kadrajda YOKTU. Sebep kod değildi — atlas region'ı x 1976'ya taşınmıştı, önbellekteki doku ise telefonu hâlâ x 2721'de tutuyordu, yani region tamamen ŞEFFAF alanı örnekliyordu. Teşhis tek satır: kaynak `.png` mtime'ı ile `.godot/imported/<ad>.png-*.ctex` mtime'ını karşılaştır (benimkiler 7 gün ayrıydı). Çözüm `godot --headless --path . --import`.

**2. Ama `--import` de bir sonraki koşuyu bozuyor.** `global_script_class_cache.cfg`'yi EKSİK yazıyor (77 sınıf yerine 76; alfabetik ilk giren `AngelRoundSystem` düşmüş). Hemen sonraki koşu `Parse Error: Identifier "AngelRoundSystem" not declared` → `Compile Error: Failed to compile depended scripts` → `Failed to instantiate an autoload` (`event_manager`, `time_manager`) → Nil erişim hatalarıyla ölüyor: tek koşuda 34 hata, hiçbiri gerçek. O koşu çıkarken önbelleği ONARIYOR; 2. ve sonraki koşular temiz (üst üste üç kez ölçtüm).

**Why:** İkisi de sessiz. Birincisinde screenshot'lar ÜRETİLİYOR ve düzgün görünüyor — yalnız yanlış sanatla, yani contact sheet'i yönetmene yollarsan onaylanan şey ölçtüğün şey olmuyor. İkincisinde gate'li bataryanın hata sayacı ateşleniyor ve gerçek bir regresyon sanıyorsun; daha kötüsü, o pencerede üretilen kareler autoload'ları ÖLÜ hâlde render edilmiş oluyor (bu turda yedi kareyi yeniden çekmek gerekti).

**How to apply:**
- Sanat kurduktan sonraki sıra kesin: **`--import` → bir tek ATILACAK ısınma koşusu → ancak sonra gate'li shot/smoke bataryası.**
- Bataryayı koşmadan önce doğrula: `stat -c%y` ile kaynak vs `.ctex`, ve `grep -c '"class": &' .godot/global_script_class_cache.cfg` sayısını projedeki `grep -rhoE '^class_name' scripts/ | wc -l` ile karşılaştır. Eşit değilse önbellek yarım.
- `Identifier "X" not declared` + `Failed to instantiate an autoload` ikilisini gördüğünde **önce önbelleği şüphelen, kendi diff'ini değil** — özellikle X senin dokunduğun hiçbir şeyle ilgili değilse. Aynı imza paralel oturum `class_name` eklediğinde de çıkıyor ([[concurrent-session-hazard]]).
- Bu, `SMOKE PASS` yalanının bir başka kaynağı: autoload düşse bile ona dokunmayan case PASS basar ([[smoke-verification-cadence]]).

**3. ÜÇÜNCÜ TETİK (2026-08-25, Ar-Ge turu): ÖLDÜRÜLEN bir batarya arkasında Godot süreci bırakıyor ve o süreç bir sonraki bataryayla önbellek üstünde yarışıyor.** Tam bataryayı yarıda kesip (TaskStop) kod düzeltip yeniden koştum; koşu dört HR case'ini `SCRIPT ERROR: Parse Error: Identifier "EventGate" not declared` + `Failed to load script "res://scripts/ui/oda/oda_view.gd"` ile düşürdü — 72-108 hata satırı. **Dördü de TEK BAŞINA koşunca PASS.** `EventGate` benim dokunduğum hiçbir şeyle ilgili değildi ve önbellekte de mevcuttu; suçlu, öldürülen koşudan kalan süreçlerdi. Aynı pencerede shot render'ları da koşturmak riski katlıyor (port 7777 MCP çakışması aynı pencerede görünüyor).

**How to apply (3'e ek):**
- Bir bataryayı öldürdükten sonra **yenisini başlatmadan önce süreçlerin gerçekten öldüğünü doğrula**: `tasklist //FI "IMAGENAME eq Godot_v4.6.2-stable_win64_console.exe"`. Sıfır satır görmeden yeni koşu başlatma.
- **Batarya koşarken shot/audit gibi ikinci bir Godot ÇALIŞTIRMA.** Tek Godot, tek anda. Bu, "proje düzenlenmez" kuralının süreç tarafındaki ikizi.
- Tanı refleksi: batarya kırmızı ama case tek başına yeşilse, **kodu değil koşuyu şüphelen** — ve tam bataryayı temiz baştan koş, tek tek doğrulamayla yetinme.

**4. DÖRDÜNCÜ TETİK (2026-10-07, P4 taban ölçümü): commit'le gelen YENİ asset'in `.ctex`'i hiç yoksa headless koşu
temayı yükleyemez.** F9'un koyu ikonları (`assets/icons/dark/select_arrow|menu_blank|menu_check.svg`) `.import`
dosyalarıyla commit'liydi ama `.godot/imported/`'da `.ctex`'leri yoktu → `menajer_theme.tres` "referenced
non-existent resource" → `main.gd:91` null → koşu PROBE END basmadan 600 sn timeout'a kadar asılı kaldı. 33 koşunun
33'ü böyle düştü ve arka planda fark edilmedi (oturum kapanmıştı). Teşhis: logun İLK satırları ("Unable to open file:
res://.godot/imported/..."). Çözüm aynı sıra: `--import` (22 sn) → kısa ısınma (`--run-log=full_run:8:sim:1`, PROBE
END=1) → batarya. Uzun arka plan bataryası başlatmadan önce tek kısa ısınma koşusu her zaman.

İlgili: [[browser-render-rig-hazards]], [[project-unicorn-current-stage]], [[smoke-verification-cadence]]
