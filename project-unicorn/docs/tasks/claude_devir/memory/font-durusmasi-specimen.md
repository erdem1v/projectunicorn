---
name: font-durusmasi-specimen
description: "Font Duruşması SONUÇ: SET A KANON (mevcut üçlü korundu, 2026-08-03). Harness + Godot variable-font wght tuzağı"
metadata: 
  node_type: memory
  type: project
  originSessionId: 05e380d0-0149-4372-837f-2ea52e5b43e9
  modified: 2026-10-23T02:29:21.491Z
---

**GÜNCEL (2026-10-23, `de0182ed`): koyu yüzler Archivo[wdth,wght] değişken yüzü (dar yüzler genişlik 62, gövde 500/100, tnum açık, yedek Plex) + Source Serif 4; Barlow ve Plex Medium/Condensed silindi (Barlow Bold yalnız `tools/brand/`'de lock-up aracı için). Krem master tema Plex + JetBrains Mono ile kaldı. Bkz. [[urun-arayuzu-task-2026-10-23]]. Önceki (2026-10-02): Barlow Condensed + IBM Plex Sans + Source Serif 4, [[ui-redesign-menajer-2026-10-02]]. Aşağıdaki INT-tag tuzağı U0'da uygulandı ve geçerli.**

**KARAR (Erdem, 2026-08-03): SET A KAZANDI — mevcut üçlü kanon.** Source Serif 4 / IBM Plex Sans / JetBrains Mono kalıyor; Tema Çekirdeği font ailesi değiştirmiyor, `build_theme.gd`'deki üç FONT_* sabiti aynen kalır. Pratik sonuç: aile değişimi için SIFIR kod işi. Değişken-font `wght` tuzağı (aşağıda) A için MOOT — üç aile de statik yüz taşıyor — ama ileride bir değişken font (ör. HR/Marketing için yeni bir aile) gelirse hâlâ geçerli. A'ya özgü iki açık uç: (1) **₺ JetBrains Mono'da YOK** — bugün her yer `$` olduğu için zararsız, TRY fiyatlandırma gelirse mono fallback şart; (2) `assets/fonts/mono/JetBrainsMono-Medium.ttf` repoda duruyor ama `build_theme.gd`/`master_theme.tres`/hiçbir varyasyon onu OKUMUYOR — ölü asset, ya bir varyasyona bağlanmalı ya silinmeli.

**Font Duruşması** (2026-08-03) — Tema Çekirdeği bir aileyi projeye gömmeden önce mevcut üçlüyü alternatiflere karşı görme işi. Dört render: A (mevcut: Source Serif 4 / IBM Plex Sans / JetBrains Mono), B (Spectral / Public Sans / IBM Plex Mono), C (Fraunces / Inter / Space Mono, değişken eksenler varsayılanda), C-opsz (aynı C ama `opsz` her etiketin px boyuna sabitlenmiş — Erdem "ikisini de render et" dedi).

Harness: `--font-spec=<set>` → `scripts/debug/font_specimen.gd` + `scenes/debug/FontSpecimen.tscn`, main.gd'deki mevcut shot-flag zincirine eklendi. PNG'ler `user://font_spec_<set>.png`. Aday TTF'ler **repo dışında** `user://font_spec/{a,b,c}/` altında yaşıyor ve runtime `FontFile.load_dynamic_font(path)` ile yükleniyor — bu yüzden `.import` sidecar'ı, `.godot/imported` cache girdisi ve git'e giren binary YOK. Her yüz aynı dokuz render property'sini tek kod yolundan alıyor (`_load_face`), yani "aynı import ayarları" diff'leyerek değil inşa yoluyla garanti. `allow_system_fallback=false` bilinçli: eksik glif sessizce Windows fontundan ödünç alınmasın, tofu olarak görünsün.

**GODOT TUZAĞI — Tema Çekirdeği bunu bilmeli:** `FontVariation.variation_opentype` anahtarları **INT OpenType tag** olmak zorunda. String anahtar (`{"wght": 600}`) setter tarafından sessizce kabul edilir ama hiçbir eksene eşleşmez → değişken font **varsayılan instance'ını** render eder, yani Regular ile SemiBold birebir aynı çıkar ve hiçbir hata basılmaz. İlk render'da B ve C tek ağırlıkta çıktı, gözle "Fraunces zaten kalın" diye yanlış okudum; yakalayan şey `get_string_size()` ile ölçüm oldu (delta 0.0 px). Doğrusu: `axes[_ot_tag("wght")] = 600` — tag = 4 karakterin big-endian paketlenmesi, `TextServer.name_to_tag()` ile aynı. Specimen'da kalıcı `_report_weight_separation()` guard'ı var; B veya C seçilirse tema bu tuzağa düşmeden önce aynı ölçümü yapmalı.

**Ölçülen ağırlık ayrımı** (SemiBold − Regular, aynı dize): A serif +8 / sans +10 px · B +14 / **+4** · C +19 / +5 · C-opsz +21 / +5. Yani Public Sans 600 ve Inter 600, IBM Plex SemiBold'a göre gözle görülür şekilde daha zayıf ayrışıyor — UI hiyerarşimiz `sans_reg` vs `sans_sb` farkına dayandığı için (ChoiceLabel/ChoiceLabelStrong, RowName, MetricValue) bu gerçek bir maliyet.

**Türkçe:** dört sette de altı yüzün tamamı ĞÜŞİÖÇğüşıöçÂâÎî—·'$ kapsıyor, hiç tofu yok. Tek eksik ₺ — JetBrains Mono (yani BUGÜN canlı olan set) ve Space Mono'da yok; oyunda her yer `$` olduğu için bugün zararsız, TRY fiyatlandırma gelirse sorun.

İlgili: [[project-unicorn-current-stage]], [[ui-design-system]], [[smoke-verification-cadence]]
