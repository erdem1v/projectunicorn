---
name: ekip-rev11-rebuild
description: Ekip modülü rev 11 yeniden inşası — GDD .docx'te (.md YOK), tasarım Claude Design projesinde, plan docs/plans/'da, 7 hüküm
metadata:
  type: project
---

**Ekip (HR) modülü rev 11'e göre yeniden inşa ediliyor.** Plan yazıldı ve onaylandı 2026-08-23; **uygulama başlamadı**.

**Üç konum — hiçbiri tahmin edilebilir değil:**
- **Otorite:** `project-unicorn/GDDs/GDD — EKİP MODÜLÜ vson.docx` (rev 11 · İNŞA SÜRÜMÜ). Task metni `GDDs/GDD_EKIP_rev11_INSA.md` diyor — **öyle bir dosya yok**, arama zaman kaybı. Docx'i okumak için `zipfile` ile `word/document.xml` çıkar, `<w:tbl>` bloklarını satır satır render et (tablolar içeriğin yarısı).
- **Tasarım:** Claude Design projesi `467a4852-6e13-423a-9e00-805980b1678c` ("Unicorn Skins"), `DesignSync` `list_files` / `get_file` ile okunur. Artboard haritası: **9b** Kadro · **turn 14** Görevler (beş iş sütunu, kurucusuz) · **turn 16** Atlas · **11b** aday dosyaları · **11c** eğitim modali · **2a/2b/2c** zam/terfi/çıkarma · **1a–1e** bileşenler · **10a** Kişisel · **19a–19d** çalışma saatleri modali. Proje kökündeki `CLAUDE.md` ve `team-strings.csv` de okunabilir.
- **Plan:** `project-unicorn/docs/plans/EKIP_REBUILD_2026-08-23.md` (647 satır) — konformans deltası, silme listesi, göç, seam'ler, faz sırası, 18 kalibrasyon sayısı.

**Yedi hüküm (planın §9a'sı):** R1 kurucu cetveli 0–5 → 0–10 bu turda, C18a okuyucu denetimi kapısıyla · R2 izin ve ayrılmalar olay motoruna kadar otomatik kalır · R3 turn 19 çalışma saatleri tasarımıdır · R4 ch01/ch02/ch06/ch12 ve PROJECT_SPEC §4 borcu yalnız işaretlenir, .docx'e dokunulmaz · R5 göç geçersiz atamayı **düşürür** (sessiz taşıma/onarım yok, düşen sayılır) · R6 kurucu görev durumu türetilir, saklanmaz · R7 `MORALE_BASE_DRIFT_PER_DAY` 0,25.

**Yapısal olarak en pahalı üç değişiklik:** atama birimi alan→iş (5 iş, §12.0; save göçü + 8 uzak çağrı yeri) · moralin ilk kez çıktıyı etkilemesi (bugün hiçbir üretim formülü `Character.morale` okumuyor) · §9.1 maaş bantlarının bordroyu ~yarıya indirmesi.

İlgili: [[project-unicorn-current-stage]] · [[smoke-verification-cadence]] (240 case, PASS-on-throw kapısı Faz 0'da) · [[github-repo-projectunicorn]]
