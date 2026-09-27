# Ofis görünümü varlıkları

## `xbot.glb`

- Kaynak: three.js deposundaki `examples/models/gltf/Xbot.glb`
  (`https://threejs.org/examples/models/gltf/Xbot.glb`). Tasarımın ofis sahnesi karakterlerini bu
  dosyadan kurar.
- Karakter: Adobe Mixamo "X Bot". Mixamo koşulları karakter ve animasyonların oyunlarda telif ücreti
  olmadan kullanılmasına izin verir.
- İçerik: tek iskelet (67 `mixamorig:*` eklemi; dosyada 70 düğüm), iki mesh (gövde, eklemler), yedi klip: `idle`, `walk`,
  `run`, `agree`, `headShake`, `sad_pose`, `sneak_pose`.
- 2930032 bayt, sha256 `002f8d269de68e5dce3d25195caf390d1aa359bbfaae3fcf4c8dc78ec36c3ba5`. Değiştirilmez.

## `thumb_home.jpg`, `thumb_ishani.jpg`, `thumb_plaza.jpg`, `thumb_loft.jpg`

- Şehir haritasındaki ofis kartlarının küçük resimleri, 480×300 JPEG.
- Tasarımın kendi `createOffice(...).snapshot(k)` fonksiyonu üretir (k = 0..3: ev, İş hanı, plaza, depo
  loft): saat 10:15, Xbot karakterlerle, 2× piksel yoğunluğunda çizilip kırpılır. Çerçeve bilgisi
  `art/office3d/<id>.json` → `thumbTargets`.
- Yeniden üretim: `project-unicorn` kökünden `bash tools/office3d/run_export.sh` (tam koşu; ağ gerekir).
  Hat ve tuzaklar: `tools/office3d/README.md`.
