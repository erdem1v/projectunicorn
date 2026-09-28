# Açık işler

Açık işlerin tek yeri bu klasördür.
- `ACIK_KARARLAR.md`: sahibin kararını bekleyen maddeler. Ajan bunlara karar gelmeden dokunmaz.
- Bu dosya: yapılması kararlaştırılmış ama henüz yapılmamış işler. Biten iş, onu bitiren commit'te buradan silinir.

## Test paketi
- Smoke ve probe paketi yalın bir paketle değiştirilecek (CLAUDE.md "Test"). Bugün `scripts/debug/endgame_smoke.gd`
  350 vaka taşıyor. Yalnız smoke, probe ya da `main.gd` debug harness'larının eriştiği üretim kodu ve CSV'de yalnız
  smoke'un okuduğu türetilmiş anahtar aileleri bu işle birlikte ele alınır; temizlik raporlarında "yalnız test" diye
  ayrılan maddeler de buraya girer.

## Olay motoru
- Lint kuralı: bir arkın `reassign_event` / `close_event` kartı öznenin slotunu bildirirse, özne `entity_exists` ile
  geçersizlendikten sonra G5'i hiç geçemez (§10.6'nın yasakladığı sessiz ölüm). Bugünkü kartlarda yok; kural eklenmeli.

## Arayüz yeniden yapılırken
Temizlikte görülen ama arayüz yeniden yapılacağı için dokunulmayan noktalar:
- Ham stil değerleri (UI/STYLE LAW; her biri yeni token ister): `month_summary_modal.gd` font, yarıçap, margin;
  `finance_ozet_view.gd` modulate'ları; `hunt_tab.gd` `_label` boyutları (11–14; 14 merdivende yok)
  ve disabled alfaları; `OnboardingFlow.tscn` LoadingLabel 18, `origin_traits_step.gd` ve `character_step.gd`
  modulate'ları; `top_bar.gd` `_apply_density` aralıkları; `detail_view.gd` ve `feature_lines_view.gd` ham
  StyleBoxFlat'leri, `pricing_panel.gd` 24 ve `detail_view.gd` 20 punto; `creation_flow.gd` ham stil değerleri; bir yerde
  ham 24 punto ve CREAM rengi.
- `hr_tab.gd` saat çipini (`_paint_hours_control`) ve Kadro/Görevler segmentini (`_paint_segments`) elle kurduğu
  StyleBoxFlat'lerle çiziyor; ikisi de tema varyasyonu ister (UI/STYLE LAW 4).
- Çubukların tema bağımsızlığı: `bar_kit.gd`, `build_bar.gd` ve `research_bar.gd` bilerek tema varyasyonu kullanmıyor,
  yazdıkları gerekçe (ODA alt ağacının donmuş teması) ağaçta yok. Karar: varyasyonlara taşınırlar ya da bağımsızlık
  bugünkü bir gerekçeyle kalır.
- Ar-Ge atama panelindeki ayraç `HRUiShared.hairline` ile çiziliyor (eski kopya `anti_aliasing = false` diyordu).
- BETA satırı BETA'nın kaçıncı haftasında olunduğunu göstermiyor: `build_bar_model.beta_week` hesaplanıyor,
  `BUILD_BETA_WEEK` var, çizen yok (Ürün §7; haftalık hâli GUNCELLEMELER ch03 §7).
- Fiyat bandı gösterimi: eski `BAND_*` token'ları silindi; bandın ekranda nasıl okunacağı arayüz kararı.
- Oyuncu metinlerinde tire (— –) kalan CSV satırları var (CLAUDE.md §5); mühürlü metinlerde sahibin kararı gerekir.
- EN çoğul ikizleri: `DESK_PAPER_ATLAS_TITLE` ("{n} candidate files ready") ve `FIN_GOAL_P3_HUNT` ("{n} offers on the
  table") n=1'de çoğul okunuyor; tekil ikiz anahtar ve seçimi gerekir (TR sayıdan sonra çoğul eki almaz).

## Ofis ve pencereler
- İlk açılış rehberi yok: mentor modalı kapanınca oyuncu ofise düşer, ofis, pencereler, not yığını ve "Ofisi taşı"
  düğmesi tanıtılmaz. İstenirse ayrı iş.
- Ürün kurmanın 3. adımı 1280 genişliğindeki Ürün penceresini 59 px aşıyor (`creation_flow.gd`,
  `window_layer.gd` `SPECS`); pencere ya da adımın sütunları, karar ACIK_KARARLAR 65.
- Ofis 1080p'nin üstünde konteyner ölçüsünde çiziliyor (`scenes/office/OfficeView.tscn`, `stretch`); doğal
  çözünürlükte çizim, karar ACIK_KARARLAR 70.
- 70 kişilik Depo loft 4×'te kare ~8,4 ms (eski Xbot kadrosu ~6 ms); LOD turu, karar ACIK_KARARLAR 71.
- Harita kartı küçük resimleri hâlâ tasarımın Xbot figürleriyle (`assets/art/office/thumb_*.jpg`); Quaternius
  karakterleriyle yeniden çekim, karar ACIK_KARARLAR 72.
- Huylar ofis ritmini etkilemiyor (kahveci, İŞKOLİK, düşük moral kahve ve mola sıklığını değiştirmiyor); trait
  task'ına bırakıldı (ofis karakterleri kararı 4).
- Şehir haritası ana iş parçacığında yükleniyor (`OfficeCity.open` → `OfficeView.load_layout("city")`): ~130 ms
  takılma, önünde "hazırlanıyor" perdesi. Arka planda ya da önceden yükleme.
- Export ön ayarı kurulunca `art/office3d/*.json`'ın pakete girdiği doğrulanır: `OfficeLayout.load` onları
  `FileAccess` ile okur; gerekirse include filtresine eklenir.
- `project.godot` `rendering/reflections/sky_reflections/roughness_layers=7`: ofisin gökyüzü (REALTIME) yedi katman
  istiyor; proje ayarı farkı sahibin onayıyla commit'lenir (CLAUDE.md §12).
