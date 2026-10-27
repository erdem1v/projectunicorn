---
name: feedback-event-names-from-system
description: "Erdem 2026-10-26 — event cards never hardcode employee, customer, prospect or rival names; every person/company is a scope slot filled by a selector (random or state-based); events make offers, not signatures"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 6d15b35f-66f1-4e87-b274-dc8c31d2f7b4
  modified: 2026-10-26T14:36:24.906Z
---

**Kural:** olay kartında çalışan, müşteri, aday ya da rakip adı sabit yazılmaz.
- Her kişi ve şirket bir `scope` yuvasıdır (`employee`, `customer`, `prospect`, `founder`; rakip `RivalRegistry`'den).
- Yuva motorun seçicisiyle dolar: uygun olanlar arasından tohumlu rastgele ya da duruma bağlı (memnuniyeti en düşük, en büyük
  hesap, kartın geliştiricisi).
- Metin adı `{slot}` ile okur.
- Taslaklardaki adlar (Mert, Bilge, Anadolu Market…) yalnız örnektir.
- Sabit kalabilenler basın ve yayın gibi kurgusal kurum adlarıdır.

**Aynı gün ikinci kural:** olay bir adayı imzalatmaz, ona teklif verir (indirim ya da söz). Aday satış akışının kendi yolunda
imzalarsa sözleşme o koşulla açılır.

**Why:** Erdem, olayın sistemden beslenmesini istiyor, kart elle bir dünyaya yazılmasın. Motor da bu yüzden yuva ve
seçiciyle kuruldu ("Engine'i buna göre yaptığımızı hatırlıyorum"). Olaydan doğrudan imza da satış akışını atlatıyor.

**How to apply:**
- Olay taslağı yazdırırken ya da incelerken her özel adın bir yuvadan gelip gelmediğine bak. Gerekli seçici yoksa seçici
  yazılır, ad sabitlenmez.
- Görsel kabulde kartı iki tohumla çek; adlar değişmeli.
- İlgili: [[card-text-token-rules]], [[feedback-event-option-quality]], [[feedback-incident-and-card-writing]].
