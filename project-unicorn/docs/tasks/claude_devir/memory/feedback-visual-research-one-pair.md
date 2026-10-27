---
name: feedback-visual-research-one-pair
description: "Erdem 2026-10-10: görsel/teknik araştırmada aday başına tek önce/sonra çifti (aynı kamera, gündüz+gece) ve bu makinede ms; çok kümeli deney istemiyor"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 04fc404d-9e0d-4eae-a33f-340be20dda0f
  modified: 2026-10-09T23:10:42.552Z
---

Grafik ön ayar araştırmasında Erdem çıktı biçimini koydu: her aday için tek cümle "ne yapar", aynı kamerada 13:00 ve
22:00 **tek önce/sonra çifti**, bu makinede GPU maliyeti (ms ya da fps) ve her ön ayar için "önerim". "Dokuz kümelik
deneyler yok." Rapor gelince F5 verir, uygulama ondan sonra.

**Why:** Önceki oturumun dokuz kümelik keskinlik koşusu hem okunmaz bir çıktıydı hem de (probe hatasıyla birlikte)
makineyi dondurdu; Erdem karar vermek için yan yana iki kare ve tek bir maliyet sayısı istiyor.

**How to apply:** Ölçümü ayrı süreçlerde, küçük kümelerle koş; teslimde aday başına bir karşılaştırma görseli (önce/sonra
× gündüz/gece + gerekirse yakın plan) ve tek maliyet satırı ver. Görünürlük hükmünü kör bir hakeme de doğrulat.
İlgili: [[render-ceiling-research-2026-10-10]]
