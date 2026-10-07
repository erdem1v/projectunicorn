# Satır içi tema override haritası

UI LAB'ın ürettiği denetim (`sandbox/ui_lab/core/override_audit.gd`). Laboratuvar her açılışta yeniden üretir, içerik değişmediyse dosyaya dokunmaz; elle düzenlenmez. Taşıma görevinin iş listesidir: bu görevde hiçbir override kaldırılmaz.

- Veri: `main.gd` `_seed_theme_surface` tohumu 424242, gün 14, ofis ishani, saat 11:00.
- Renk körü paleti: açık. Oyuncunun ayarıdır; koddan basılan anlamsal renkler ona göre yazılır.
- Tema: mevcut. Laboratuvar kökünde tema yok, her şey proje temasından (`themes/master_theme.tres`) çözülür.
- Gezilen ekranlar: ekip, satis, olay, bos. Yalnız oyun düğümleri: GameShell alt ağacı ve olay modalı, Window'lar dahil.
- Yoklama: düğüm API'si override listesi vermez. Her Control ve Window'a sınıf zincirinin Godot varsayılan temasındaki öğe adları, master temadaki bütün öğe adları ve `scripts/` ile `scenes/` içinde `add_theme_*_override("…")` ya da `theme_override_*/…` olarak geçen her sabit ad sorulur. Zincir dışı ortak ad sayısı: renk 14, font 6, font boyutu 6, sabit 17, kutu 14, ikon 7.
- Değer: renk `#RRGGBBAA`; font ve ikon kaynak yolu (yolsuzsa sınıfı); boyut ve sabit sayı; kutuda dolgu, kenar, köşe, gölge, taşma ve etkin iç boşluk (sol, üst, sağ, alt).
- Sınıf: `separation`, `h_separation`, `v_separation` ve `margin_*` sabitleri yerleşimdir (UI yasası izinli); gerisi görseldir (temaya taşınacak).
- Sahne: düğümün ait olduğu sahne dosyası; kodla kurulan düğümde `kod · <script>`, yani onu taşıyan en yakın script. Düğüm yolu gezinin kökünden başlar; adsız düğüm `Sınıf#sıra` yazılır, çünkü Godot'un verdiği `@Sınıf@N` adı koşudan koşuya değişir.

## Satırlar

### `kod · res://scripts/modals/event_modal.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `EventModal/CenterPanel/Body` | sabit | `separation` | 10 | yerleşim |
| `EventModal/CenterPanel/Body/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `EventModal/CenterPanel/Body/HBoxContainer#0/PanelContainer#0` | kutu | `panel` | Flat dolgu #9A6A121A köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `EventModal/CenterPanel/Body/HBoxContainer#0/PanelContainer#0/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `EventModal/CenterPanel/Body/HBoxContainer#4` | sabit | `separation` | 8 | yerleşim |
| `EventModal/CenterPanel/Body/HBoxContainer#4/PanelContainer#2` | kutu | `panel` | Flat dolgu #EFE8DAFF köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `EventModal/CenterPanel/Body/HBoxContainer#4/PanelContainer#2/Label#0` | renk | `font_color` | #5B544AFF | görsel |
| `EventModal/CenterPanel/Body/Panel#2` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `EventModal/CenterPanel/Body/Panel#6` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `EventModal/CenterPanel/Body/VBoxContainer#5` | sabit | `separation` | 8 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#0/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#0/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 3 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#0/HBoxContainer#0/VBoxContainer#1/PanelContainer#0` | kutu | `panel` | Flat dolgu #9A6A121A köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#0/HBoxContainer#0/VBoxContainer#1/PanelContainer#0/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 3 | yerleşim |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1/HBoxContainer#0/VBoxContainer#1/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1/HBoxContainer#0/VBoxContainer#1/PanelContainer#0/Label#0` | renk | `font_color` | #5B544AFF | görsel |

### `kod · res://scripts/tabs/hr_tab.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 14 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | renk | `font_hover_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | renk | `font_pressed_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | renk | `icon_hover_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | renk | `icon_normal_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | sabit | `h_separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | sabit | `icon_max_width` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | kutu | `focus` | Flat dolgu #FFFFFF00 kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 14,10,14,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | kutu | `hover` | Flat dolgu #FFFFFF00 kenar #9A6A12FF 1,1,1,1 köşe 2,2,2,2 iç 14,10,14,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | kutu | `normal` | Flat dolgu #FFFFFF00 kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 14,10,14,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/Button#2` | kutu | `pressed` | Flat dolgu #FFFFFF00 kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 14,10,14,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 14 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#0/HBoxContainer#1/HBoxContainer#1` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 28 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | renk | `font_hover_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | kutu | `focus` | Flat dolgu #FFFFFF00 kenar #9A6A12FF 0,0,0,2 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | kutu | `hover` | Flat dolgu #FFFFFF00 kenar #9A6A12FF 0,0,0,2 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | kutu | `normal` | Flat dolgu #FFFFFF00 kenar #9A6A12FF 0,0,0,2 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#0` | kutu | `pressed` | Flat dolgu #FFFFFF00 kenar #9A6A12FF 0,0,0,2 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | renk | `font_hover_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | kutu | `focus` | Flat dolgu #FFFFFF00 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | kutu | `hover` | Flat dolgu #FFFFFF00 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | kutu | `normal` | Flat dolgu #FFFFFF00 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/HBoxContainer#1/Button#1` | kutu | `pressed` | Flat dolgu #FFFFFF00 iç 2,0,2,10 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/Panel#2` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/PanelContainer#4/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#0/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#3` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#3/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#6` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#6/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#8` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/HBoxContainer#8/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/CenterContainer#5/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 4,4,4,4 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#4/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#7` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#7/Label#1` | renk | `font_color` | #C9962EFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/HBoxContainer#7/ProgressBar#0` | kutu | `fill` | Flat dolgu #C9962EFF köşe 2,2,2,2 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 3 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/CenterContainer#5/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 4,4,4,4 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#4/PanelContainer#0` | kutu | `panel` | Flat dolgu #9A6A121A kenar #9A6A12FF 1,1,1,1 köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#4/PanelContainer#0/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#7` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#7/Label#1` | renk | `font_color` | #2C6FAEFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/HBoxContainer#7/ProgressBar#0` | kutu | `fill` | Flat dolgu #2C6FAEFF köşe 2,2,2,2 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 3 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/CenterContainer#5/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 4,4,4,4 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#4/PanelContainer#0` | kutu | `panel` | Flat dolgu #F1E4D1FF kenar #B36B0073 1,1,1,1 köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#4/PanelContainer#0/Label#0` | renk | `font_color` | #B36B00FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#7` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#7/Label#1` | renk | `font_color` | #B36B00FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/HBoxContainer#7/ProgressBar#0` | kutu | `fill` | Flat dolgu #B36B00FF köşe 2,2,2,2 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 3 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/CenterContainer#5/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 4,4,4,4 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#7` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#7/Label#1` | renk | `font_color` | #2C6FAEFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#7/ProgressBar#0` | kutu | `fill` | Flat dolgu #2C6FAEFF köşe 2,2,2,2 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 3 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/CenterContainer#5/PanelContainer#0` | kutu | `panel` | Flat dolgu #EFE8DAFF kenar #C4B79FFF 1,1,1,1 köşe 2,2,2,2 iç 4,4,4,4 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/Panel#1` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1/Label#0` | font boyutu | `font_size` | 14 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#4/PanelContainer#0` | kutu | `panel` | Flat dolgu #9A6A121A kenar #9A6A12FF 1,1,1,1 köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#4/PanelContainer#0/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#7` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#7/Label#1` | renk | `font_color` | #2C6FAEFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/HBoxContainer#7/ProgressBar#0` | kutu | `fill` | Flat dolgu #2C6FAEFF köşe 2,2,2,2 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 3 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#9/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/VBoxContainer#3` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/VBoxContainer#3/PanelContainer#0/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/VBoxContainer#3/PanelContainer#0/HBoxContainer#0/Label#2` | renk | `font_color` | #B36B00FF | görsel |

### `kod · res://scripts/tabs/sales_tab.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0` | sabit | `separation` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 16 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#2` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Label#1` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#3` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#1/VBoxContainer#3/Label#1` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3` | sabit | `separation` | 24 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/HBoxContainer#1/Label#2` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#0/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#0/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#1/Label#1` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#3` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Control#1/Label#0` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Control#0/Label#0` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#1/Label#1` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#3` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#1` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#0/VBoxContainer#0/PanelContainer#4/VBoxContainer#0/VBoxContainer#1/HBoxContainer#1/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/HBoxContainer#0/Label#2` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#0/Label#0` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/HBoxContainer#4/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/PanelContainer#1` | kutu | `panel` | Flat dolgu #F1E4D1FF köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#1/VBoxContainer#0/PanelContainer#1/Label#0` | renk | `font_color` | #B36B00FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#0/Label#0` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#4` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/HBoxContainer#4/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/PanelContainer#1` | kutu | `panel` | Flat dolgu #9A6A121A köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#2/VBoxContainer#0/PanelContainer#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | renk | `font_color` | #C4B79FFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font | `font` | res://assets/fonts/variations/mono_reg.tres | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Control#1/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#0/Label#0` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#3` | sabit | `separation` | 6 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/HBoxContainer#3/Label#0` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/PanelContainer#1` | kutu | `panel` | Flat dolgu #D9E5F0FF köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/HBoxContainer#3/ScrollContainer#1/VBoxContainer#0/PanelContainer#3/VBoxContainer#0/PanelContainer#1/Label#0` | renk | `font_color` | #2C6FAEFF | görsel |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/SalesTab/VBoxContainer#0/Panel#2` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |

### `kod · res://scripts/ui/components/build_bar.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0` | kutu | `panel` | Flat dolgu #FBF7EEFF kenar #D9D0BFFF 1,1,1,1 köşe 0,0,2,2 iç 1,1,1,1 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1` | sabit | `margin_left` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1` | sabit | `margin_right` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | renk | `font_color` | #2C6FAEFF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | font boyutu | `font_size` | 10 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#5` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#5` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#5` | font boyutu | `font_size` | 15 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/Panel#0` | kutu | `panel` | Flat dolgu #2C6FAE1A iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1` | sabit | `margin_left` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1` | sabit | `margin_right` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#3` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#3` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#3` | font boyutu | `font_size` | 10 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Panel#0` | kutu | `panel` | Flat dolgu #2C6FAEFF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Panel#2` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Panel#4` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5` | kutu | `panel` | Flat dolgu #FFFFFF00 iç 0,0,0,0 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0` | sabit | `margin_left` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0` | sabit | `margin_right` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0/HBoxContainer#0` | sabit | `separation` | 10 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0/HBoxContainer#0/Label#1` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0/HBoxContainer#0/Label#1` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0/HBoxContainer#0/Label#1` | font boyutu | `font_size` | 11 | görsel |

### `kod · res://scripts/ui/components/left_tabs.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn/Stack/PanelContainer#2` | kutu | `panel` | Flat dolgu #EFE8DAFF köşe 2,2,2,2 iç 6,2,6,2 | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn/Stack/PanelContainer#2/Label#0` | renk | `font_color` | #5B544AFF | görsel |

### `kod · res://scripts/ui/components/research_bar.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0` | kutu | `panel` | Flat dolgu #FBF7EEFF kenar #D9D0BFFF 1,1,1,1 köşe 0,0,2,2 iç 1,1,1,1 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0` | sabit | `separation` | 0 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1` | sabit | `margin_left` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1` | sabit | `margin_right` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#0` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#0` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#0` | font boyutu | `font_size` | 12 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#1` | font boyutu | `font_size` | 9 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#2` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#2` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#2` | font boyutu | `font_size` | 15 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#3` | font boyutu | `font_size` | 10 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#4` | renk | `font_color` | #9A6A12FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#4` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/Label#4` | font boyutu | `font_size` | 10 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1` | sabit | `margin_left` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1` | sabit | `margin_right` | 12 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | renk | `font_color` | #2B2722FF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#1` | font boyutu | `font_size` | 13 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#2` | renk | `font_color` | #5B544AFF | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#2` | font | `font` | res://assets/fonts/variations/mono_label.tres | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/Label#2` | font boyutu | `font_size` | 10 | görsel |
| `GameShell/MidRow/CenterViewport/BuildHUD/Root/ResearchBar/PanelContainer#0/VBoxContainer#0/Panel#2` | kutu | `panel` | Flat dolgu #E3DAC9FF iç 0,0,0,0 | görsel |

### `kod · res://scripts/ui/components/window_frame.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0` | sabit | `margin_bottom` | 22 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0` | sabit | `margin_left` | 28 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0` | sabit | `margin_right` | 64 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0` | sabit | `margin_top` | 22 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#1` | sabit | `margin_right` | 28 | yerleşim |
| `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#1` | sabit | `margin_top` | 22 | yerleşim |

### `kod · res://scripts/ui/office/meeting_invite.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/Control#4/PanelContainer#1/VBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/Control#4/PanelContainer#1/VBoxContainer#0/HBoxContainer#2` | sabit | `separation` | 8 | yerleşim |

### `kod · res://scripts/ui/office/office_hud.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/Control#2/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/Control#2/HBoxContainer#0/PanelContainer#0/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |

### `kod · res://scripts/ui/office/office_notice_stack.gd`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/NoticeStack/PanelContainer#0/HBoxContainer#0` | sabit | `separation` | 8 | yerleşim |
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/NoticeStack/PanelContainer#0/HBoxContainer#0/Panel#0` | kutu | `panel` | Flat dolgu #2C6FAEFF köşe 4,4,4,4 iç 0,0,0,0 | görsel |

### `res://scenes/main/GameShell.tscn`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow` | sabit | `separation` | 0 | yerleşim |

### `res://scenes/office/OfficeView.tscn`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/OfficeView/Overlay/NoticeStack` | sabit | `separation` | 8 | yerleşim |

### `res://scenes/ui/components/BuildHUDPanel.tscn`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/CenterViewport/BuildHUD/Root` | sabit | `separation` | 8 | yerleşim |

### `res://scenes/ui/components/LeftTabs.tscn`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/MidRow/LeftTabs/Margin` | sabit | `margin_bottom` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin` | sabit | `margin_left` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin` | sabit | `margin_right` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin` | sabit | `margin_top` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/EventsBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/EventsBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/FinanceBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/FinanceBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/HRBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/HRBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF; #9A6A12FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn/Stack` | sabit | `separation` | 2 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/PersonalBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/PersonalBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/ProductBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/ProductBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/RnDBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/RnDBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/SalesBtn/Stack` | sabit | `separation` | 4 | yerleşim |
| `GameShell/MidRow/LeftTabs/Margin/Col/SalesBtn/Stack/NameLabel` | renk | `font_color` | #8A8175FF; #9A6A12FF | görsel |
| `GameShell/MidRow/LeftTabs/Margin/Col/SettingsBtn/Stack` | sabit | `separation` | 4 | yerleşim |

### `res://scenes/ui/components/TopBar.tscn`

| Düğüm | Tür | Öğe | Değer | Sınıf |
|---|---|---|---|---|
| `GameShell/TopBar/Margin` | sabit | `margin_bottom` | 0 | yerleşim |
| `GameShell/TopBar/Margin` | sabit | `margin_left` | 20 | yerleşim |
| `GameShell/TopBar/Margin` | sabit | `margin_right` | 20 | yerleşim |
| `GameShell/TopBar/Margin` | sabit | `margin_top` | 0 | yerleşim |
| `GameShell/TopBar/Margin/Row` | sabit | `separation` | 26 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup` | sabit | `separation` | 28 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Burn` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Burn/ValueRow` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Cash` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_MRR` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Net` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Net/ValueRow` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Net/ValueRow/ValueLabel` | renk | `font_color` | #56B4E9FF | görsel |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Runway` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Runway/ValueRow` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/FinanceGroup/StatCol_Runway/ValueRow/ValueLabel` | renk | `font_color` | #56B4E9FF | görsel |
| `GameShell/TopBar/Margin/Row/IdentityGroup` | sabit | `separation` | 10 | yerleşim |
| `GameShell/TopBar/Margin/Row/ReputationGroup` | sabit | `separation` | 28 | yerleşim |
| `GameShell/TopBar/Margin/Row/ReputationGroup/StatCol_Brand` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/ReputationGroup/StatCol_Rep` | sabit | `separation` | 2 | yerleşim |
| `GameShell/TopBar/Margin/Row/TimeGroup` | sabit | `separation` | 16 | yerleşim |
| `GameShell/TopBar/Margin/Row/TimeGroup/PhaseGroup` | sabit | `separation` | 4 | yerleşim |
| `GameShell/TopBar/Margin/Row/TimeGroup/PhaseGroup/PhaseDots` | sabit | `separation` | 6 | yerleşim |
| `GameShell/TopBar/Margin/Row/TimeGroup/ShutterLabel` | renk | `font_color` | #E69F00FF | görsel |
| `GameShell/TopBar/Margin/Row/TimeGroup/SpeedControls` | sabit | `separation` | 4 | yerleşim |

## Sahne başına sayım

| Sahne | Görsel | Yerleşim | Toplam |
|---|---:|---:|---:|
| `kod · res://scripts/tabs/hr_tab.gd` | 158 | 69 | 227 |
| `kod · res://scripts/tabs/sales_tab.gd` | 61 | 34 | 95 |
| `kod · res://scripts/ui/components/build_bar.gd` | 24 | 10 | 34 |
| `kod · res://scripts/ui/components/research_bar.gd` | 23 | 7 | 30 |
| `res://scenes/ui/components/TopBar.tscn` | 3 | 22 | 25 |
| `res://scenes/ui/components/LeftTabs.tscn` | 8 | 14 | 22 |
| `kod · res://scripts/modals/event_modal.gd` | 10 | 10 | 20 |
| `kod · res://scripts/ui/components/window_frame.gd` | 0 | 6 | 6 |
| `kod · res://scripts/ui/components/left_tabs.gd` | 2 | 0 | 2 |
| `kod · res://scripts/ui/office/meeting_invite.gd` | 0 | 2 | 2 |
| `kod · res://scripts/ui/office/office_hud.gd` | 0 | 2 | 2 |
| `kod · res://scripts/ui/office/office_notice_stack.gd` | 1 | 1 | 2 |
| `res://scenes/main/GameShell.tscn` | 0 | 1 | 1 |
| `res://scenes/office/OfficeView.tscn` | 0 | 1 | 1 |
| `res://scenes/ui/components/BuildHUDPanel.tscn` | 0 | 1 | 1 |
| **Toplam** | 290 | 180 | 470 |

## En çok override taşıyan üç sahne

1. `kod · res://scripts/tabs/hr_tab.gd`: 227 (görsel 158, yerleşim 69)
2. `kod · res://scripts/tabs/sales_tab.gd`: 95 (görsel 61, yerleşim 34)
3. `kod · res://scripts/ui/components/build_bar.gd`: 34 (görsel 24, yerleşim 10)

## Ek A: tema dışında kalan görünüm (gezide görülen)

Tema değişince bunlar değişmez: kodda boyanan `ColorRect`, beyaz olmayan `modulate`, BBCode rengi taşıyan metin.

- BBCode · `GameShell/NewsTicker/Stream` · `[color=`
- ColorRect · `EventModal/Dimmer` · #0507099E
- ColorRect · `GameShell/TopBar/Margin/Row/IdentityGroup/LogoSquare` · #FFA028FF
- modulate · `EventModal/CenterPanel/Body/VBoxContainer#5/PanelContainer#1` · #FFFFFF80
- modulate · `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/TextureRect#0` · #2C6FAEFF
- modulate · `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/Control#3/MarginContainer#1/HBoxContainer#0/TextureRect#2` · #B36B00FF
- modulate · `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/MarginContainer#1/HBoxContainer#0/TextureRect#0` · #9A6A12FF
- modulate · `GameShell/MidRow/CenterViewport/BuildHUD/Root/BuildBar/PanelContainer#0/VBoxContainer#0/PanelContainer#5/MarginContainer#0/HBoxContainer#0/TextureRect#0` · #8A8175FF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#1/HBoxContainer#0/CenterContainer#5/PanelContainer#0/TextureRect#0` · #5B544AFF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#2/HBoxContainer#0/CenterContainer#5/PanelContainer#0/TextureRect#0` · #5B544AFF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#4/HBoxContainer#0/CenterContainer#5/PanelContainer#0/TextureRect#0` · #5B544AFF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/CenterContainer#5/PanelContainer#0/TextureRect#0` · #5B544AFF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#0/Control#1` · #FFFFFF73
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/HBoxContainer#0/VBoxContainer#1/Control#1` · #FFFFFF73
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/HBoxContainer#1/VBoxContainer#2/Control#1` · #FFFFFF73
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/Label#2` · #FFFFFF73
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#5/HBoxContainer#0/Label#6` · #FFFFFF73
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/ScrollContainer#5/VBoxContainer#0/PanelContainer#7/HBoxContainer#0/CenterContainer#5/PanelContainer#0/TextureRect#0` · #5B544AFF
- modulate · `GameShell/MidRow/CenterViewport/PanelContainer#1/MarginContainer#0/HRTab/VBoxContainer#0/VBoxContainer#3/PanelContainer#0/HBoxContainer#0/TextureRect#0` · #B36B00FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/EventsBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/FinanceBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/HRBtn/Stack/Icon` · #8A8175FF; #9A6A12FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/MarketingBtn` · #FFFFFF73
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/PersonalBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/ProductBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/RnDBtn/Stack/Icon` · #8A8175FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/SalesBtn/Stack/Icon` · #8A8175FF; #9A6A12FF
- modulate · `GameShell/MidRow/LeftTabs/Margin/Col/SettingsBtn/Stack/Icon` · #8A8175FF

## Ek B: temayı kodda okuyan ya da tema dışında çizen yerler (statik, `scripts/`)

`get_theme_*()` okuması yapıldığı andaki temayı dondurur; düğüm ağaca girmeden okuyan kurulum kodu (ör. `hr_ui_shared.gd` moral çubuğu) laboratuvar temasını hiç görmez. `ThemeDB.get_project_theme()` okuyan her zaman master'ı görür.

### `ThemeDB.get_project_theme()`

- `res://scripts/main/main.gd:86`
- `res://scripts/ui/components/bar_kit.gd:21`

### `get_theme_*()`

- `res://scripts/main/main.gd:1104`
- `res://scripts/main/main.gd:1106`
- `res://scripts/main/main.gd:1125`
- `res://scripts/main/main.gd:1134`
- `res://scripts/onboarding/onboarding_flow.gd:111`
- `res://scripts/tabs/hr/hr_ui_shared.gd:230`
- `res://scripts/tabs/product/detail_view.gd:603`
- `res://scripts/tabs/product/feature_lines_view.gd:352`

### `_draw / draw.connect`

- `res://scripts/tabs/hr/hr_assignments.gd:164`
- `res://scripts/tabs/rnd/rnd_tree_view.gd:451`
- `res://scripts/tabs/rnd/rnd_ui_shared.gd:224`
- `res://scripts/tabs/rnd/rnd_ui_shared.gd:255`
- `res://scripts/ui/components/bar_kit.gd:95`
- `res://scripts/ui/components/cash_curve.gd:51`
- `res://scripts/ui/components/logo_emblem.gd:32`
- `res://scripts/ui/components/radial_dial.gd:104`
- `res://scripts/ui/components/segment_bar.gd:30`
- `res://scripts/ui/components/triangle_radar.gd:82`
- `res://scripts/ui/components/value_slider.gd:62`
- `res://scripts/ui/meeting/meeting_panel.gd:234`
- `res://scripts/ui/meeting/meeting_panel.gd:250`
- `res://scripts/ui/meeting/meeting_panel.gd:538`
- `res://scripts/ui/meeting/meeting_panel.gd:719`
- `res://scripts/ui/meeting/meeting_panel_option.gd:107`
- `res://scripts/ui/meeting/meeting_panel_option.gd:172`
- `res://scripts/ui/meeting/meeting_ruler.gd:57`
- `res://scripts/ui/office/meeting_invite.gd:56`
- `res://scripts/ui/office/office_city.gd:436`

### `[color=`

- `res://scripts/ui/components/news_ticker.gd:132`

## Ek C: `add_theme_*_override` çağrı yerleri (statik, `scripts/`)

Gezinin görmediği ekranlar dahil bütün scriptler. Çağrı yeri sayılır: döngüdeki tek çağrı bir kez sayılır, çalışma anında birçok düğüme düşebilir.

| Script | renk | font | font boyutu | sabit | kutu | ikon | Toplam |
|---|---:|---:|---:|---:|---:|---:|---:|
| `res://scripts/modals/ending_scene.gd` | 0 | 0 | 0 | 17 | 0 | 0 | 17 |
| `res://scripts/modals/event_modal.gd` | 0 | 0 | 0 | 7 | 0 | 0 | 7 |
| `res://scripts/modals/hr_action_modal.gd` | 3 | 3 | 3 | 1 | 1 | 0 | 11 |
| `res://scripts/modals/month_summary_modal.gd` | 1 | 0 | 2 | 1 | 4 | 0 | 8 |
| `res://scripts/modals/rnd_card_modal.gd` | 0 | 0 | 0 | 8 | 0 | 0 | 8 |
| `res://scripts/modals/save_load_modal.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| `res://scripts/modals/settings_modal.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| `res://scripts/modals/term_sheet_table_scene.gd` | 2 | 0 | 1 | 17 | 0 | 0 | 20 |
| `res://scripts/modals/training_modal.gd` | 0 | 0 | 0 | 8 | 0 | 0 | 8 |
| `res://scripts/modals/work_hours_modal.gd` | 4 | 0 | 1 | 17 | 3 | 0 | 25 |
| `res://scripts/onboarding/language_gate.gd` | 0 | 0 | 0 | 0 | 1 | 0 | 1 |
| `res://scripts/onboarding/onboarding_flow.gd` | 1 | 0 | 0 | 2 | 2 | 0 | 5 |
| `res://scripts/onboarding/steps/character_step.gd` | 0 | 0 | 0 | 6 | 0 | 0 | 6 |
| `res://scripts/onboarding/steps/company_step.gd` | 0 | 0 | 0 | 9 | 0 | 0 | 9 |
| `res://scripts/onboarding/steps/origin_traits_step.gd` | 1 | 0 | 2 | 14 | 3 | 0 | 20 |
| `res://scripts/tabs/events_tab.gd` | 0 | 0 | 0 | 3 | 0 | 0 | 3 |
| `res://scripts/tabs/finance/finance_ozet_view.gd` | 4 | 0 | 0 | 28 | 0 | 0 | 32 |
| `res://scripts/tabs/finance_tab.gd` | 0 | 0 | 0 | 3 | 0 | 0 | 3 |
| `res://scripts/tabs/hr/hr_assignments.gd` | 0 | 0 | 0 | 9 | 2 | 0 | 11 |
| `res://scripts/tabs/hr/hr_atlas_modal.gd` | 0 | 0 | 0 | 17 | 3 | 0 | 20 |
| `res://scripts/tabs/hr/hr_dossier.gd` | 0 | 0 | 0 | 9 | 0 | 0 | 9 |
| `res://scripts/tabs/hr/hr_ledger.gd` | 0 | 0 | 0 | 9 | 0 | 0 | 9 |
| `res://scripts/tabs/hr/hr_popover.gd` | 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| `res://scripts/tabs/hr/hr_ui_shared.gd` | 1 | 0 | 0 | 7 | 4 | 0 | 12 |
| `res://scripts/tabs/hr_tab.gd` | 7 | 0 | 0 | 15 | 2 | 0 | 24 |
| `res://scripts/tabs/hunt_tab.gd` | 1 | 0 | 1 | 2 | 0 | 0 | 4 |
| `res://scripts/tabs/personal_tab.gd` | 0 | 0 | 0 | 26 | 5 | 0 | 31 |
| `res://scripts/tabs/product/capacity_block.gd` | 0 | 0 | 0 | 8 | 0 | 0 | 8 |
| `res://scripts/tabs/product/creation_flow.gd` | 1 | 0 | 1 | 24 | 1 | 0 | 27 |
| `res://scripts/tabs/product/detail_view.gd` | 3 | 0 | 1 | 25 | 3 | 0 | 32 |
| `res://scripts/tabs/product/feature_lines_view.gd` | 2 | 0 | 0 | 7 | 1 | 0 | 10 |
| `res://scripts/tabs/product/portfolio_view.gd` | 0 | 0 | 0 | 6 | 0 | 0 | 6 |
| `res://scripts/tabs/product/pricing_panel.gd` | 0 | 0 | 1 | 7 | 0 | 0 | 8 |
| `res://scripts/tabs/product/publish_flow.gd` | 0 | 0 | 0 | 10 | 3 | 0 | 13 |
| `res://scripts/tabs/product/team_panel.gd` | 0 | 0 | 0 | 15 | 5 | 0 | 20 |
| `res://scripts/tabs/rnd/rnd_assign_panel.gd` | 1 | 0 | 0 | 9 | 4 | 0 | 14 |
| `res://scripts/tabs/rnd/rnd_detail_panel.gd` | 0 | 0 | 0 | 5 | 1 | 0 | 6 |
| `res://scripts/tabs/rnd/rnd_tree_view.gd` | 0 | 0 | 0 | 7 | 4 | 0 | 11 |
| `res://scripts/tabs/rnd/rnd_ui_shared.gd` | 1 | 0 | 0 | 1 | 1 | 0 | 3 |
| `res://scripts/tabs/rnd_tab.gd` | 2 | 0 | 0 | 6 | 1 | 0 | 9 |
| `res://scripts/tabs/sales_tab.gd` | 0 | 0 | 0 | 19 | 0 | 0 | 19 |
| `res://scripts/theme/ui_factory.gd` | 1 | 0 | 0 | 3 | 3 | 0 | 7 |
| `res://scripts/ui/components/bar_kit.gd` | 1 | 1 | 1 | 0 | 2 | 0 | 5 |
| `res://scripts/ui/components/build_bar.gd` | 4 | 0 | 0 | 4 | 3 | 0 | 11 |
| `res://scripts/ui/components/desk_papers.gd` | 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| `res://scripts/ui/components/left_tabs.gd` | 1 | 0 | 0 | 1 | 0 | 0 | 2 |
| `res://scripts/ui/components/radial_dial.gd` | 1 | 0 | 0 | 0 | 0 | 0 | 1 |
| `res://scripts/ui/components/research_bar.gd` | 2 | 0 | 0 | 7 | 2 | 0 | 11 |
| `res://scripts/ui/components/star_rating.gd` | 1 | 1 | 1 | 1 | 0 | 0 | 4 |
| `res://scripts/ui/components/top_bar.gd` | 4 | 0 | 0 | 3 | 0 | 0 | 7 |
| `res://scripts/ui/components/window_frame.gd` | 0 | 0 | 0 | 6 | 0 | 0 | 6 |
| `res://scripts/ui/meeting/meeting_panel.gd` | 1 | 0 | 0 | 32 | 0 | 0 | 33 |
| `res://scripts/ui/meeting/meeting_panel_option.gd` | 2 | 0 | 0 | 3 | 0 | 0 | 5 |
| `res://scripts/ui/meeting/meeting_ruler.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| `res://scripts/ui/office/meeting_invite.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| `res://scripts/ui/office/office_city.gd` | 0 | 0 | 0 | 1 | 0 | 0 | 1 |
| `res://scripts/ui/office/office_hud.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| `res://scripts/ui/office/office_map_card.gd` | 0 | 0 | 0 | 6 | 0 | 0 | 6 |
| `res://scripts/ui/office/office_notice_stack.gd` | 0 | 0 | 0 | 2 | 0 | 0 | 2 |
| **Toplam** | 53 | 5 | 15 | 465 | 64 | 0 | 602 |
