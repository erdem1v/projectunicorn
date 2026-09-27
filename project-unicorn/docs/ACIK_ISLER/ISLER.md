# Açık işler

Açık işlerin tek yeri bu klasördür.
- `ACIK_KARARLAR.md`: sahibin kararını bekleyen maddeler. Ajan bunlara karar gelmeden dokunmaz.
- Bu dosya: yapılması kararlaştırılmış ama henüz yapılmamış işler. Biten iş, onu bitiren commit'te buradan silinir.

## Test paketi
- Smoke ve probe paketi yalın bir paketle değiştirilecek (CLAUDE.md "Test"). Bugün `scripts/debug/endgame_smoke.gd`
  348 vaka taşıyor. Yalnız smoke, probe ya da `main.gd` debug harness'larının eriştiği üretim kodu ve CSV'de yalnız
  smoke'un okuduğu türetilmiş anahtar aileleri bu işle birlikte ele alınır; temizlik raporlarında "yalnız test" diye
  ayrılan maddeler de buraya girer.

## Olay motoru
- Lint kuralı: bir arkın `reassign_event` / `close_event` kartı öznenin slotunu bildirirse, özne `entity_exists` ile
  geçersizlendikten sonra G5'i hiç geçemez (§10.6'nın yasakladığı sessiz ölüm). Bugünkü kartlarda yok; kural eklenmeli.

## Arayüz yeniden yapılırken
Temizlikte görülen ama arayüz yeniden yapılacağı için dokunulmayan noktalar:
- Ham stil değerleri (UI/STYLE LAW; her biri yeni token ister): `month_summary_modal.gd` font, yarıçap, margin;
  `finance_tab.gd` ve `finance_ozet_view.gd` modulate'ları; `hunt_tab.gd` `_label` boyutları (11–14; 14 merdivende yok)
  ve disabled alfaları; `OnboardingFlow.tscn` (LoadingLabel 18, Dimmer 0,72), `origin_traits_step.gd` ve
  `character_step.gd` modulate'ları; `left_tabs.gd` kilitli sekme ve hap renkleri; `center_viewport.gd` 420/520;
  `top_bar.gd` `_apply_density` aralıkları; `detail_view.gd` ve `feature_lines_view.gd` ham StyleBoxFlat'leri,
  `pricing_panel.gd` 24 ve `detail_view.gd` 20 punto; `creation_flow.gd` ham stil değerleri; bir yerde ham 24 punto ve
  CREAM rengi.
- Ar-Ge atama panelindeki ayraç `HRUiShared.hairline` ile çiziliyor (eski kopya `anti_aliasing = false` diyordu).
- BETA satırı geçen günü göstermiyor: `build_bar_model.beta_day` hesaplanıyor, `BUILD_BETA_DAY` var, çizen yok
  (Ürün §7, mühürlü: sayaçlar ve geçen gün).
- Fiyat bandı gösterimi: eski `BAND_*` token'ları silindi; bandın ekranda nasıl okunacağı arayüz kararı.
- Oyuncu metinlerinde tire (— –) kalan CSV satırları var (CLAUDE.md §5); mühürlü metinlerde sahibin kararı gerekir.
