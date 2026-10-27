---
name: browser-render-rig-hazards
description: Chrome freezes background tabs — toBlob/fetch.then never fire; drive render rigs from a foreground --app window instead of the MCP bridge
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 922f3722-628c-4b5f-b35c-ac4c09e6dd07
  modified: 2026-08-10T16:14:05.625Z
---

Bir Three.js/WebGL render rig'ini **MCP tarayıcı köprüsünden sürme** (2026-08-10, ODA sanat
migrasyonu). Chrome arka plan sekmesini DONDURUYOR ve sonuç yanıltıcı:

- `canvas.toBlob(...)` geri çağrısı **hiç ateşlenmiyor** — 8×8'lik bir kanvasta bile.
  Yani "4K encode yavaş" değil; görev kuyruğu tamamen durmuş.
- `fetch(...).then(...)` de ateşlenmiyor (POST hiç tamamlanmıyor).
- **Senkron kod çalışmaya devam ediyor** (`toDataURL`, matris matematiği), çünkü CDP
  `Runtime.evaluate` doğrudan yürütüyor. Bu yüzden sekme "canlı" görünüyor ve donma
  yavaş encode gibi okunuyor. `__RIG_READY` true, fonksiyonlar tanımlı, ama hiçbir
  asenkron iş bitmiyor.
- Sonunda `computer` screenshot'ı da "Script injection timed out" veriyor.

**Çözüm — kendi profilinde ÖN PLANDA bir Chrome penceresi:**
```
chrome.exe --user-data-dir=<rig>/chrome-profile --no-first-run \
           --no-default-browser-check --window-size=1280,760 \
           --app="http://127.0.0.1:8732/layers.html?auto=1&solve=1"
```
Sayfa kendi kendini sürer (`?auto=1`), çıktıları yerel bir Python sink'e POST eder, runner
dosya sistemini yoklar. Ön plan = donma yok; ayrı profil = kullanıcının tarayıcısına
dokunulmuyor; gerçek GPU = çıktı onaylı görünümle eşleşiyor (SwiftShader değil).
**Kullanıcının Chrome'unu `taskkill /IM chrome.exe` ile ASLA kapatma** — profil yoluna
göre `Get-CimInstance Win32_Process | Where CommandLine -like '*chrome-profile*'` filtrele.

İki ilgili tuzak aynı turda:
- **MCP `javascript_tool` büyük payload'da `-32603 Internal error` veriyor.** Sebep boyut
  ya da süre; tek tek çağrı + `window.__X`'e yazıp sonra kısa string döndürmek çözüyor.
- **Koordinat inişli optimizasyonu ölçek-değişmez ifade et.** "Frontal" kriterini
  `|pos.x − target.x|` diye yazınca çözücü hedefi 494 m öteye itip cezayı sıfırladı ve
  17k değerlendirme boyunca dolaştı. Kamerayı `[x,y,z,yawDeg,pitchDeg,fov]` ile
  parametreleyip target'ı TÜRETMEK açığı kapattı. Ayrıca her inişe `MAX_EVALS` +
  wall-clock deadline koy: kabul eşiği 1e-9 olan bir iniş kafeste sonsuza kadar yürüyebilir.

Rig ve defter: `project-unicorn/docs/design/oda_art_pipeline.md`.
İlgili: [[godot-mcp-runtime-verification]], [[project-unicorn-current-stage]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Browser render rig hazards](browser-render-rig-hazards.md) — Chrome arka plan sekmesini DONDURUYOR (toBlob/fetch.then hiç ateşlenmez, senkron kod çalışır → yavaş encode sanılır); rig'i kendi profilinde ön plan `--app` penceresinden sür; ölçek-değişmez optimizasyon kriteri + MAX_EVALS şart
