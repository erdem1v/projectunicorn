---
name: render-ceiling-research-2026-10-10
description: "Grafik ön ayar araştırması (oturum 04fc404d, kesilen 30c68c34'ün devamı): PC donmasının nedeni, motor bulguları, ölçülen ön ayar maliyetleri, karar bekleyenler, araçların yeri"
metadata:
  node_type: memory
  type: project
  originSessionId: 04fc404d-9e0d-4eae-a33f-340be20dda0f
  modified: 2026-10-10T02:09:03.973Z
---

Erdem 2026-10-10'da (PC donup elle yeniden başlatıldıktan sonra) yön verdi: asset lab kapandı ([[feedback-bespoke-assets-over-packs]]),
hedef **render tavanı**: Düşük/Orta/Yüksek/Ultra + tek tek seçenekler; önce araştırma (aday başına tek önce/sonra
çifti, 13:00 ve 22:00, bu makinede ms), F5'ten sonra uygulama. Sınır: oyun koduna dokunma; yalnız render ayarları,
Environment, ışıklar, proje ayarları, ayarlar UI'ı.

**PC donması:** önceki oturumun probe'a eklediği `native` düğmesi her kümede bir önceki büyümüş boyutu çarpıyordu
(2314→…→9747 px); 8x MSAA kümesinde makine dondu (Kernel-Power 41). Onarım + `native>2` reddi `7357573` (push yok).

**Motor bulguları (ölçümle):** MSAA ink konturunu yumuşatmaz (kontur MSAA çözüldükten sonra çizilir) ama ince
geometriyi yumuşatır, kapatınca merdiven artar; `ssao_light_affect` yalnız `ssao_ao_channel_affect>0` iken işler
(scene_forward_clustered.glsl:2032); kamera 120 m geride → SDFGI kademeleri ofisi kapsamaz, hacimsel sis kareyi
karartır; VoxelGI çalışırken 0,13–1 s pişer ama lamba hizasında ışık sızıntısı; yansıma sondası plaza'yı griye çeker;
DOF ortografikte gerçek tilt-shift verir; aniso etkisiz (toon örnekleyicisi anizotropik değil); ink `texel` iç
çözünürlükle çarpılmalı ve en yakın piksele yuvarlanır (1,15→1 px, 1,53→2 px); Godot 4.6'da kontakt gölge ve hareket
bulanıklığı yok. Ortam geometrisi %100 Claude Design türevi (gerçek asset yalnız Quaternius kişiler).

**Kaydırma kıpırtısı:** kamera fareyi bire bir izler (office_camera.gd:138), yerelde sürükleme tam piksel kaydırır;
1,25/1,5 kat render ölçeği her adımda kenarı farklı örnekler (probe sweep artığı 1,06–1,48 vs yerel 0,156), 2,0 kat
kararlı (0,152). Yani SSAA yalnız tam sayı kat. Ölçüm: `--pan=sweep:0:16:1:x:1` + `motion_sum.py`.
**Önerilen merdiven** (Orta = bugünkü sahne): Düşük FSR1 %67, MSAA yok, atlas 2048, glow yok; Yüksek yerel çözünürlük
+ MSAA 4x + SMAA + lamba gölgesi; Ultra yerel×2 SSAA (4K'da ölçeksiz), MSAA/FXAA yok, atlas 8192, küçük eşya gölgesi,
ayarlı SSAO, Hard + Yumuşak seçeneği. Loft 1440p GPU: 0,58 / 1,10 / 1,90 / 4,86 ms. Kalabalık ofiste darboğaz CPU
(açık karar 71, oyun kodu). Kör hakem: MSAA ince geometride işe yarar, SMAA daha keskin ama daha temiz değil, TAA kazançsız.

**Karar bekleyen (raporda 10 madde):** tablo, `office_view.gd`'ye dokunma (yerel çözünürlük + fare dönüşümü), kontur
2 px/1 px, gece kontur düzeltmesi (DARK_LINE; uygulanırsa Orta bugünkü kareyi bit bit üretmez), Ultra 2,0 kat mı
ölçeksiz mi, Ultra yumuşak gölge, tilt-shift/LUT/vinyet, Düşük'te glow, ilk açılış kuralları ve eşikleri, CPU duvarı
(açık karar 71).

**Araçlar:** scratchpad `04fc404d-…/scratchpad/tools/`: `capture.sh <grup> <saat> [ofis]` (probe koşuları), `ext.gd`
(probe `ext=` varyantları: SSAO/SSIL/SDFGI/VoxelGI/sonda/sis/DOF/glow/LUT/lamba/küçük eşya gölgesi), `frames.py` +
`cands.py` (karşılaştırma görselleri), `facts.py` (log→facts.json), `build_page.py` (rapor sayfası). Git Bash'te tek
`/`la başlayan argüman yol sanılıp bozulur: `MSYS_NO_PATHCONV=1`. Probe değişikliği `7357573`'te; push yok.

**Teslim 2026-10-10 ~03:15:** rapor sayfası https://claude.ai/artifact/TxVUSr8wewBG9KbewfQtAz (özel; 32 aday, kör hakem
çipleri, ölçülen maliyet tabloları, ilk açılış taslağı, dokunulacak dosyalar). Kör hakem: 1440p'de en büyük sıçrama
Orta→Yüksek; Yüksek→Ultra marjinal (gerçek Ultra için kenar yumuşatmalı ink gerekir, karar 11); 2048 atlas gölge
sivilcesi yapıyor (Düşük de 4096); küçük eşya gölgeleri Ultra'da leke → seçenek. F5 bekleniyor; uygulama ondan sonra.
Yardımcı yönetmen oturumu (project-steam-c4) pencereli koşularımı bekledi; bittiğini bildirdim.

**UYGULANDI ve PUSH EDİLDİ 2026-10-10** (`7357573` probe, `0fe77fc` grafik, `e1d7da9` zoom kilidi; origin/main =
e1d7da9). Erdem önerilen 11 kararın hepsini onayladı. Grafik: `data/graphics/presets.json` + `scripts/systems/graphics_settings.gd`
(yol ile preload; class_name YOK ve içinde OfficeCamera'ya da preload ile bakılır, çünkü Settings autoload'u yükler),
settings.json'da `graphics_preset` + `graphics` (ön ayardan ayrılan seçenekler), Ayarlar'da Grafik bölümü, `--gfx=<ön ayar>`
inert koşuda zorlar (ayarlara yazmaz). Yerel çözünürlük: kap fiziksel boyutta + ölçek, `size_2d_override(_stretch)`,
olaylar `xformed_by(_container.get_transform())`. Gece konturu: ink `light_line` = OfficeLighting `day_k`.
Zoom kilidi: `OfficeCamera.LOCKS` (yarı genişlik m, kaydırma m); en geniş zoom 16:9'da ev 0,79 / İş hanı 0,90 / loft 0,92 /
şehir 1,0 / plaza 0,6; yalnız oyuncu girdisine uygulanır, `focus` serbest; meet kilitsiz. Onay bekleyen: LOCKS'taki 10 sayı,
33 SET_GFX TR/EN metni, detect regex'leri.
**Asset yeniden yapımı (Erdem'in sorusu):** temizlik geçişi güvenli (kaynak/düğüm/malzeme aynı, nav aynı, -%26 GLB) ama
görüntüyü değiştirmiyor; 8x zoom'da yuvarlak kenar konturu kaybolmuyor (pahlama gerekçesiz); görünür tek aday aynı düzlemli
yüzlerin titreşmesi (evde ~1,7 m², paylaşılan ölçekli mesh'ler yüzünden basit değil). Yapılmadı; prototipler
scratchpad `agents/assets/`.

İlgili: [[render-assetlab-task-2026-10-09]] · [[godot-raster-sharpness-facts]] · [[lost-session-recovery]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Render tavanı araştırması 2026-10-10](render-ceiling-research-2026-10-10.md) — grafik ön ayar araştırması (oturum 04fc404d): PC donması probe native hatasıydı (`7357573`); MSAA ink'e dokunmaz, SSAO ao_channel_affect ister, SDFGI/sis 120 m kamerada işlemez; SSAA yalnız 2,0 kat (1,5 kaydırırken titrer); **UYGULANDI + PUSH 2026-10-10 (`0fe77fc` grafik, `e1d7da9` zoom kilidi)**; asset yeniden yapımı görüntüyü değiştirmiyor, yapılmadı
