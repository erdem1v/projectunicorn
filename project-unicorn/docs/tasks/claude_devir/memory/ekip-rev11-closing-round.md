---
name: ekip-rev11-closing-round
description: Ekip rev 11 kapanış turu (5 iş) 2026-08-24 push edildi; artboard kaynağı ve iki ölçülmüş Godot tuzağı
metadata:
  type: project
---

**2026-08-24 · Ekip rev 11 KAPANIŞ TURU tamam ve PUSH edildi** (`3f23d16`, 17 commit uzağa gitti).
Beş iş: kurucu cetveli 0–10 (şema 8) · ghost code · saatler modali (artboard'dan) · üç karar · probe HR ölçümü.
Kapılar: smoke 230/237 · loc_residue 0 (1.882 anahtar) · `--theme-audit=oda` 147 · THEME_STAMP 7.

**ARTBOARD KAYNAĞI NEREDE:** Claude Design projesi `467a4852-6e13-423a-9e00-805980b1678c`
("Project Unicorn Visual Skins"), dosyalar `Unicorn Skins.dc.html` (turu 19 = saatler modali,
kaltalar 19a–19d) ve `Trait Icons.dc.html`. DesignSync `get_file` ile CANLI çekilir.
Ekip/Finans/Olay sayfalarının ESKİ artboard'ları ayrı bir projede
(`1a3d47b2-…`, `ui/ekip.html`) ve orası rev 2 çağından — kaynak olarak KULLANMA.

**İKİ GODOT TUZAĞI, İKİSİ DE ÖLÇÜLDÜ:**
1. `ResourceLoader.load(path, "Script", CACHE_MODE_IGNORE)` KOŞAN bir script üzerinde
   motoru düşürür (`signal 11`, "Internal script error! Opcode: 0"). `all_scripts_load`
   ayrık kopya + `reload()` ile kalmalı. Bkz. [[godot-import-cache-gotchas]].
2. `HBoxContainer` bir çocuğun ASGARİ boyutunu asla kırpmaz — bütçesini aşan tek bir hücre
   bütün satırı kaydırır. Sabit sütun istiyorsan hücreyi düz bir `Control`'e koy
   (`custom_minimum_size` + `clip_contents`, çocuk full-rect çapalı); container koyarsan
   ızgara akar. `work_hours_modal._pin` bunun kanonu.

**PARK EDİLENLER (silinmedi, gerekçeli):** `Character.assigned_jobs` aynası (12 canlı okuyucu) ·
`HRSystem.area_sum_for` §4.5'i atlıyor (moral bandı + huy çarpanları okunmuyor) ·
`MORALE_VACATION_RETURN` + `is_manual` (gelecek olay kanalı) · B4 · B6.

**AÇIK KUSUR (Ürün sekmesi, bu turda düzeltilmedi):** `creation_draft_survives_navigation`
artık dürüst düşüyor — "ProductTab did not re-open the creation flow (view )". Çıplak
instantiate edilen ProductTab hiç görünüm monte etmiyor.

Bkz. [[ekip-rev11-rebuild]] · [[project-unicorn-current-stage]] · [[smoke-verification-cadence]]
