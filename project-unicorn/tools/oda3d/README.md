# ODA 3D hattı

ODA'nın orta görünüm katmanlarını (`assets/art/center_view/*_3840x2160.png`) Godot'nun 3B
sahnesinden üretir. Geometri, kamera, ışık ve malzemenin kaynağı `tools/oda_render_rig/layers.html`
ve `desk-builders.js`'tir. Bu dizin oyuna girmez; `.gdignore` Godot'yu dışarıda tutar.

Zincir: `layers.html` → `export_glb.html` → `art/oda3d/oda3d_room.glb` + `oda3d_source_scene.json`
→ `scenes/oda3d/oda3d.tscn` → lightmap pişirme → `scenes/oda3d/oda3d_capture.tscn` → katman PNG'leri.

Komutlar `project-unicorn` kökünden, Git Bash'te koşulur.
`godot` = `C:\Users\erdem\Desktop\Godot_v4.6.2-stable_win64_console.exe`.
Adım 4 ve 5 gerçek GPU ister: pencereli koşar, hiçbir zaman `--headless` değil.

## Adımlar

| adım | komut | girdi | çıktı |
|---|---|---|---|
| 1. dışa aktarma sayfası | `python tools/oda3d/make_export_page.py` | `tools/oda_render_rig/layers.html` | `tools/oda3d/export_glb.html` |
| 2. GLB + kaynak JSON | `bash tools/oda3d/run_export.sh <durum_dizini>` | `export_glb.html`, `desk-builders.js` | `art/oda3d/oda3d_room.glb`, `art/oda3d/oda3d_source_scene.json` |
| 3. içe aktarma | `godot --headless --path . --import` | GLB + `art/oda3d/oda3d_room.glb.import` | `.godot/imported/` altında UV2'li sahne |
| 4. lightmap pişirme | `godot -e --path . --windowed -s res://scenes/oda3d/oda3d_bake_driver.gd` | `scenes/oda3d/oda3d.tscn` | `scenes/oda3d/oda3d_{day,night}.lmbake` + `.exr` atlasları, `art/oda3d/oda3d_bake_log.json` (yerel kayıt, commit'e girmez) |
| 5. katman yakalama | aşağıda | pişmiş sahne | `assets/art/center_view/*_3840x2160.png` |

**1.** `export_glb.html` üretilmiş dosyadır; elle düzenlenmez. `make_export_page.py`, `layers.html`'i
satır aralıklarıyla birebir keser. Her aralığın ilk satırında bir çapa metni aranır; `layers.html`
kaymışsa betik hata verip durur, aralıklar güncellenir. Dışa aktarma kamerası
`make_export_page.py`'deki `PINNED_CAM`'e sabittir; değiştirmeden önce
`tools/oda_render_rig/README.md`'yi oku.

**2.** `run_export.sh` `serve_glb.py`'yi `127.0.0.1:8734`'te başlatır (kök `project-unicorn`),
Chrome'u kendi profiliyle (`$TMP/oda3d_chrome_profile`) önde bir `--app` penceresi olarak açar ve
`DONE.txt`'yi bekler (en çok 120 sn). Sayfa `POST /save/<ad>` ile yazar: `.glb` ve `.json`
`art/oda3d/`'ye, `.txt` durum dizinine. Durum dizini (`DONE.txt`, `serve.log`, `chrome.log`) repo
dışında olmalı; verilmezse `$TMP/oda3d_status`. Sayfa three r0.184'ü unpkg'den yükler, ağ gerekir.
Arka plandaki sekme `fetch().then()`'i dondurur; pencere önde kalmalı. Betik yalnız kendi
Chrome'unu kapatır.

**3.** `oda3d_room.glb.import` şu değerleri taşır ve korunur: `meshes/light_baking=2`,
`meshes/lightmap_texel_size=0.008`, `meshes/generate_lods=false`, `meshes/create_shadow_meshes=false`.
Dosya yeniden oluşursa bu değerler yazılır ve `--import` tekrarlanır. `--import`'tan sonraki ilk
Godot koşusu sınıf önbelleği yüzünden hata verebilir; kapılı bir koşudan önce bir ısınma koşusu yap.

**4.** Adım `-e` ile editörü açar. Editör `project.godot`'yu yeniden kaydedebilir ve `themes/*.tres`
dosyalarına uid yazabilir; bunlar hattın çıktısı değildir, hat çıktısıyla commit'e girmez.

**5.** Her katman ayrı koşudur. `oda3d_capture` kendi bayraklarını `--`'dan sonra okur
(`OS.get_cmdline_user_args`); oyunun bayraklarından farklı olarak `--` gerekir.

```
godot --path . --windowed --resolution 960x540 res://scenes/oda3d/oda3d_capture.tscn -- \
  --oda3d-mode=<day|night> --oda3d-layer=<katman> --oda3d-size=3840x2160 \
  --oda3d-scale=1.5 --oda3d-msaa=4 --oda3d-warmup=60 \
  --oda3d-out=res://assets/art/center_view/<dosya>
```

| `--oda3d-layer` | `--oda3d-mode` | `<dosya>` |
|---|---|---|
| `room` | `day` | `room_day_3840x2160.png` |
| `room` | `night` | `room_night_3840x2160.png` |
| `monitor` | `day` | `monitor_3840x2160.png` |
| `keyboard` | `day` | `keyboard_3840x2160.png` |
| `lamp` | `day` | `lamp_3840x2160.png` |
| `lamp` | `night` | `lamp_night_3840x2160.png` |
| `mug` | `day` | `mug_3840x2160.png` |
| `phone` | `day` | `phone_3840x2160.png` |

- `room`: beş obje renk geçişinden çıkar ama gölge haritasında kalır (SHADOWS_ONLY; güneş gerçek
  zamanlıdır, gizlenen obje gölgesini de götürür). Zemin opaktır (RGB).
- `<obje>`: yalnız o obje, zemin şeffaftır (RGBA). Prop geçişlerinde TAA betik tarafından kapatılır.
- `full`: hiçbir şey gizlenmez. Katmanların üst üste bindirilmiş hâlini karşılaştırmak için referans
  karedir; `center_view`'e yazılmaz.
- `--oda3d-out` verilmezse çıktı `art/oda3d/plates/oda_<mod>_4k.png` olur ve her katman öncekinin
  üzerine yazar.

Dosyalar yerinde üzerine yazılır; `.import` yan dosyalarına dokunulmaz. Sonra
`godot --headless --path . --import` ve bir ısınma koşusu. Yeni sprite'ların alfa kutusu
`OdaLayout.REGIONS` ile karşılaştırılır; değiştiyse `REGIONS` ve `RECTS` (= `REGIONS / ART`) yeniden
ölçülür. `REGIONS` + `REGION_PAD` kanvasın içinde kalmalı (`padded_region`). ODA kapıları
CLAUDE.md'dedir.

## İsteğe bağlı: tam oda karesi

`--oda3d-layer` olmadan, örneğin `--oda3d-size=7680x4320 --oda3d-downscale=1` ile koşu
`art/oda3d/plates/oda_<mod>_{8k,4k,1080p}.png` yazar ve `art/oda3d/oda3d_camera_light.json`
kaydını günceller; `oda3d_bake_log.json`'daki o modun pişirme kaydı da bu kayda eklenir. Katman
geçişleri bu kaydı yazmaz. Bu çıktılar yereldir, commit'e girmez.

Diğer bayraklar (`--oda3d-tonemap`, `--oda3d-gi`, `--oda3d-env`, `--oda3d-exposure`,
`--oda3d-taa`, `--oda3d-sky`, `--oda3d-micro`, `--oda3d-lights`, `--oda3d-anchors-only`,
`--oda3d-preview`): `scenes/oda3d/oda3d_capture.gd` içinde `_ready()` ve `_capture()`'daki `args`
okumaları. Dosya başlığındaki liste eksiktir.
