---
name: godot-theme-engine-facts
description: "Godot 4.6.2 Theme/Font davranışları (kaynaktan ve koşularla doğrulandı, 2026-09-30 UI Lab): ata tema önceliği, has_font varsayılan tuzağı, get_height fallback, uid/bayt-eş kaydetme, MCP 7777 çakışması"
metadata:
  node_type: memory
  type: reference
  originSessionId: 0e406678-a661-4d23-90af-2e43deb375cc
  modified: 2026-09-30T18:15:47.984Z
---

2026-09-30 UI Lab'da Godot 4.6.2-stable kaynağına bakılarak ve koşularla ölçüldü. Tema işi yapan her task bilmeli.

- **Öncelik:** düğüm override'ı her şeyi ezer → ata temaları (Control/Window zinciri) TÜM tip bağımlılık listesi boyunca
  → proje teması → varsayılan tema (`theme_owner.cpp` get_theme_item_in_types). Bağımlılık zincirini varyasyonu İLK
  bildiren tema kurar. Sonuç: yalnız temel tip tanımlayan ata tema master'ın her varyasyonunu ezer; varyasyon tabanını
  yeniden bağlamak işe yaramaz (hedefin kendi öğeleri gölgeler) → görünüm hedefe DÜZLEŞTİRİLİR.
- **Kalıtım CanvasLayer ve SubViewport'ta kopar** (theme_owner.cpp:134). Modal/popover temayı ancak tema taşıyan
  Control'ün altındaysa alır.
- **`Theme.has_font` / `has_font_size` / `has_theme_item(FONT|FONT_SIZE)` tema varsayılan font/boyut taşıyorsa HER ad
  için true döner** (theme.cpp:550, 668). Saklı öğeyi sormak için `name in th.get_theme_item_list(dt, type)`; saklı
  null font denetimi için varsayılanı geçici null yap. `get_font` saklı null'da varsayılanı, o da yoksa ThemeDB
  fallback'ini döner (asla null değil).
- **`Font.get_height` fallback dahil bütün rid'lerin en büyüğü:** projede NotoSansSymbols2 fallback'i Label satır
  yüksekliğini belirler, yüz değişse de Label boyu kıpırdamaz; RichTextLabel satırı ise çizen yüzü izler (olay modalı
  boyu değişir). Genişlikler her zaman değişir.
- **`Font.has_char` fallback'leri sayar** ve içe aktarma `allow_system_fallback=true` → glif denetimi
  `TextServerManager.get_primary_interface().font_has_char(base.get_rids()[0], c)` ile.
- **FontVariation eksen anahtarı INT etiket** (wght 2003265652, opsz 1869640570, wdth 2003072104); "weight" gibi
  kayıtlı okunur adlar da eşleşir, "wght" metni eşleşmez. `opentype_features` hem "tnum" metnini hem INT'i kabul eder.
- **StyleBox content_margin -1 → stil marjına düşer** (Flat: kenar kalınlığı, Texture: texture_margin). Yeniden
  giydirirken `new.set_content_margin(side, old.get_margin(side))` açık yaz.
- **Bayt-eş .tres:** gömülü kaynaklara `resource_scene_unique_id`, dış kaynaklara `Resource.set_id_for_path(out,id)`
  (yalnız tools build); `ResourceLoader.get_resource_uid` editörsüz -1 döner → uid başlıktan regex ile okunup
  `ResourceSaver.set_uid` ile korunur (user:// yolunda .uidren bırakır).
- **Control kökünde `set_theme(String)` yazılamaz** (Control.set_theme(Theme) ile çakışır, derleme hatası) → MCP
  metodu `set_theme` isteniyorsa kök düz Node olmalı.
- **Başsız `-s` koşuları da MCPRuntime autoload'unu açar ve ~4 sn TCP 7777'yi tutar:** aynı anda başlayan pencereli
  oyun MCP köprüsüz kalır. MCP oturumuyla başsız koşuları çakıştırma.
- **capture-viewport'un gerçek baytları:** Claude Code her görüntü bloğunu `~/.claude/projects/<proj>/tool-results/
  mcp-godot-blob-*.png` olarak tutar; hash için onları kullan (MCP sunucusu kendi geçici PNG'sini siler).

İlgili: [[ui-lab-task-2026-09-30]] · [[font-durusmasi-specimen]] · [[godot-mcp-runtime-verification]] · [[ui-design-system]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Godot theme engine facts](godot-theme-engine-facts.md) — 4.6.2 kaynağından: ata tema önceliği + düzleştirme, CanvasLayer kalıtım kırığı, has_font varsayılan tuzağı, get_height fallback, INT eksen etiketi, bayt-eş .tres, Control kökünde set_theme(String) yasağı, başsız -s koşusu 7777'yi tutar
