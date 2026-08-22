# Tema süpürme ledger'ı — Tema Çekirdeği Step 9 (2026-08-06)

Bu dosya süpürmenin **bilinçli olarak dokunmadığı** siteleri kayda geçirir. Polish dalgası
avlanmaya buradan başlar; UI/STYLE LAW'un "grandfathered" hükmünün somut envanteridir.
Satır numaraları 2026-08-06 anlık görüntüsüdür — çevresi değiştikçe kayar, desen kalır.

## A. Runtime `StyleBoxFlat.new()` siteleri (sanksiyonlu desen)

Bu desen SANKSİYONLUDUR: state'e bağlı stil, UiTokens renklerinden runtime'da kurulur
(`build_hud_panel._build_styles` emsali; hr_ui_shared.gd:51 yorumu aynı emsale atıf yapar).
Süpürme bunları SİLMEZ — yalnız kayda geçirir.

| Site | Ne kuruyor | Not |
|---|---|---|
| `scripts/ui/components/build_hud_panel.gd:_build_styles` | 3 mini-phase state kutusu (track/fill 2026-08-19'da BuildBar'a taşındı) | state paleti UiTokens'tan; kalır |
| `scripts/ui/components/build_bar.gd:_build_styles` | Build Bar (2026-08-19): segment dolu/boş kutuları + HATA çipi, `_draw` içinde `draw_style_box` | UiTokens ACCENT/BORDER_HOVER + negative()/positive() accessor'ları; ÜÇ ev sahibinde aynı (HUD/tracker/ODA monitörü — ODA'da bilerek ODA_* register'ı DEĞİL, piksel-aynılık emri); kalır |
| `scripts/ui/components/right_panel.gd:155-160` | `_paint_dot` sağlık noktası | state rengi (`UiTokens.health_color` ailesi); kalır |
| `scripts/ui/components/logo_emblem.gd:58` | logo plakası | boyuta bağlı radius; kalır |
| `scripts/theme/ui_factory.gd:_make_chip / make_dot` | çip + nokta | fabrikanın kendisi; token'ları UiTokens'tan (B6) |
| `scripts/onboarding/onboarding_flow.gd:75,100,122` | koyu zemin, ayraç, stepper noktaları | koyu register, UiTokens renkleri; kalır |
| `scripts/onboarding/steps/origin_traits_step.gd:37,40,197` | trait check on/off + ayraç | kalır |
| `scripts/modals/month_summary_modal.gd:104,158,172` | pill, highlight şeridi, bant | kalır (pill için bkz. C) |
| `scripts/tabs/product/creation_flow.gd:256` | seçim kartı | kalır |
| `scripts/tabs/product/detail_view.gd:354` | özellik kartı | kalır |
| `scripts/tabs/hr/hr_ui_shared.gd:57,227` | HR chip + satır kutusu | 2b yüzeyi — bkz. B |
| `scripts/debug/font_specimen.gd:225` | specimen plakası | debug aracı; kapsam dışı |

`add_theme_stylebox_override` ile UiTokens'tan kurulan diğer siteler (finance_ozet_view.gd:460,
hr_atlas_modal.gd:335, detail_view.gd:624, hr_ui_shared.gd:123) aynı sanksiyonlu desendir.

## B. 2b-yüzeyi adayları (bu süpürmede DOKUNULMADI — paralel oturum sahipliği)

- **`scripts/tabs/hr/hr_ui_shared.gd:22-24` CHIP_* çakışması**: `CHIP_RADIUS:=3,
  CHIP_PAD_X:=7, CHIP_PAD_Y:=3` — UiFactory'nin (artık `UiTokens.PAD_CHIP`) 6/2 pad'inden
  FARKLI; HR chip'leri 1px daha geniş dolgulu. Karar (7,3'ü PAD_CHIP'e indirmek mi, ayrı
  `PAD_CHIP_HR` token'ı mı) polish dalgasının; radius zaten RADIUS_S ile eş değerli.
- **`scripts/tabs/hr/hr_popover.gd`**: `CardFloating` varyasyonunun doğal ikinci kullanıcısı —
  2b oturumu kapandıktan sonra geçirilebilir.
- `scripts/tabs/hr_tab.gd`, `scripts/tabs/sales_tab.gd`, `scripts/tabs/hr/*` içindeki
  override/`modulate` siteleri bu süpürmede taranmadı — 2b sahipliği.

## C. Grandfather'lananlar (görünür hareket = polish dalgasının kararı)

- **BuildHUD `CancelBtn`** (`BuildHUDPanel.tscn`, Button, font_size 11 + INK_DIM renk
  override'ları): base Button 15'e pinli; 11→15 = +4px görünür büyüme. Kalır.
- **`scenes/onboarding/OnboardingFlow.tscn` LoadingLabel** (`font_size = 18`, koyu
  DialogueCard üstünde): 18 = SIZE_TITLE ama koyu register'da o adımda varyasyon yok;
  loading overlay'i için varyasyon açmak süpürmenin işi değil. Kalır.
- **`scripts/modals/month_summary_modal.gd:_build_chip`** (BadgeLabel + `font_size=12`,
  radius 10, pad 12/4): ay-sonu töreninin büyük pili — 12 skala dışı, ama tören
  register'ının kendi çip ölçüsü. Varyasyonlaşması (örn. CeremonyChip) polish dalgasının.
- **Disabled/muted `modulate` alfa savrukluğu**: 0.4 / 0.45 / 0.5 / 0.55 / 0.6 / 0.62
  dağınık (hunt_tab:69, sales_tab:254, hr_tab:329, hr_employee_card:39,
  finance_ozet_view:155,408, finance_tab:84-99, detail_view:601, portfolio_view:187,
  creation_flow:485-538, hr_ui_shared:250, dialogue_choice_card:53). Tek DISABLED_ALPHA
  token'ına toplanması görünür bir normalizasyon — polish dalgası.
- **Grandfathered display boyutları**: ui_tokens.gd'deki liste aynen geçerli
  (creation_flow:214=34, origin_traits_step:350=30/:320=20, month_summary_modal:168=26,
  term_sheet_table_scene:264=24, pricing_panel:70=24, detail_view:141=20).
- **`scripts/tabs/hunt_tab.gd:289-290`** değişken boyutlu etiket kurucusu (`fsize`
  parametreli): çağrı sitelerinin rolleri netleşince skala adımlarına bağlanır.
- **`addons/godot_mcp_editor/plugin.gd`**: editör eklentisi, oyun teması kapsamı dışı.

## D. Bu süpürmede taşınanlar (referans)

- ConfirmModal.tscn 4 ölü font-rengi override'ı silindi (B1).
- BuildHUDPanel.tscn: `Val` etiketlerinin default'a eşit size/renk override'ları silindi (B1);
  6× `font_size=8` + MetaLabel → `MicroLabel` varyasyonu, 8→9 +1px sanksiyonlu (B3);
  `PhaseName` 10→SectionLabel(11), `PhaseStatus` → `RowMeta` (B4); el yapımı panel
  SubResource'u → `CardFloating` (B5). Not: fixture'da aktif build olmadığından BuildHUD
  görünmez — B3/B4/B5'in BuildHUD kısmı audit'le kanıtlandı, piksel kanıtı canlı build'de.
- detail_view.gd: lig satırı 12→default(13); legend `aval` ve söz `days_lbl` →
  `RowName` (B4).
- segment_bar.gd:42 → `UiTokens.VEIL_FAINT`; product_ui_shared "experience" →
  `UiTokens.AXIS_EXPERIENCE` (B2).
- ui_factory CHIP_* statikleri → `UiTokens.RADIUS_S` / `UiTokens.PAD_CHIP` (B6).

## E. Canlı bırakılan state-encoding override'ları (tasarım gereği)

Ray sekme etiketi renkleri (left_tabs.gd:113), top_bar delta renkleri (top_bar.gd:73,135,146,190
— `UiTokens.delta_color_bright`), BuildHUD faz vurgusu (build_hud_panel.gd:150-151) ve
`BetaRow` Val POSITIVE/NEGATIVE renkleri, sağlık noktaları (`UiTokens.health_color`).
Bunlar RUNTIME STATE'tir, ölü override değildir; UiTokens helper'larından beslendikleri
sürece yasaldır (UI/STYLE LAW).

## F. İK eylem modalı — bilinçli doğrudan override'lar (2026-08-22)

`scripts/modals/hr_action_modal.gd` ve `scripts/ui/components/value_slider.gd`
yazı YÜZÜNÜ ve BOYUTUNU `theme_type_variation` yerine doğrudan override ile takıyor.
Bu bir savrukluk değil, tarif edilmiş bir istisna — gerekçesi dosya başlığında da duruyor:

- Onaylı sayfa mono gövdeyi **12px'te** (`SIZE_DATA`) ve sonucu **semibold** istiyor.
  Temada mono + `SIZE_DATA` + semibold bir varyasyon YOK; açmak `build_theme.gd`'ye
  dokunmak, yani `THEME_STAMP` 6→7 ve `master_theme.tres` regen'i demek.
- Kural kaydının **eğik sans** yüzü aynı gerekçeyle TÜRETİLDİ
  (`assets/fonts/variations/sans_it.tres`, `variation_transform` shear'ı). Dosya bir
  tema öğesi DEĞİL; `build_theme.gd` onu okumuyor.
- Slider `_draw` ile çiziliyor (HSlider'ın `grabber`'ı bir DOKU ister; onaylı tutamaç
  14×18 kutu + iki 1×8 çizgi). `_draw` hiçbir tema öğesi çözmez.

RENK VE BOYUT YİNE TOKEN'DAN: iki dosyada da ham `Color(...)` ve skala dışı sayı yok.
30px'lik yüzde okunuşu `SIZE_ED_HEADLINE`'a (32) iniyor — ui_tokens.gd:433'ün belgeli
"path-card display 30 rounds here" precedent'i.

Bir sonraki tema dalgası bu üçünü (mono-data-semibold · eğik sans · slider) varyasyona
çevirmek isterse yeri burası; bugün çevirmemenin bedeli üç override, çevirmenin bedeli
üretilmiş artefaktın yeniden doğması.
