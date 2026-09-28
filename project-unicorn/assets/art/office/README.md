# Ofis görünümü varlıkları

## `thumb_home.jpg`, `thumb_ishani.jpg`, `thumb_plaza.jpg`, `thumb_loft.jpg`

- Şehir haritasındaki ofis kartlarının küçük resimleri, 480×300 JPEG.
- Tasarımın kendi `createOffice(...).snapshot(k)` fonksiyonu üretir (k = 0..3: ev, İş hanı, plaza, depo
  loft): saat 10:15, Xbot karakterlerle, 2× piksel yoğunluğunda çizilip kırpılır. Çerçeve bilgisi
  `art/office3d/<id>.json` → `thumbTargets`.
- Yeniden üretim: `project-unicorn` kökünden `bash tools/office3d/run_export.sh` (tam koşu; ağ gerekir).
  Hat ve tuzaklar: `tools/office3d/README.md`.
