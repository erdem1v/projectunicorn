---
name: satisfaction-delta-drift
description: "Olay kartının satisfaction_delta etkisi bir tik içinde silinir — B2B memnuniyeti günde 3 (tikte 21) puan ürün sağlığı hedefine kayar; kalıcı iz yalnız hedefi kaydıran trust_offset'le (söz sistemi) olur"
metadata:
  node_type: memory
  type: reference
  originSessionId: cc9c6a29-a48a-47bf-aca8-bd3f54f34d01
  modified: 2026-10-08T05:30:55.776Z
---

2026-10-08 (yazar pilotu; birkaç kör eleştirmen "memnuniyet kazancı bir tikte siliniyor" dedi, koddan doğrulandı):
`EvEffects.satisfaction_delta` → `CustomerRegistry.set_satisfaction` yalnız GÖRÜNEN değeri yazar. `B2BSalesSystem.
_tick_satisfaction` her tik o değeri `_satisfaction_target(c)`'ye `B2BConstants.SAT_DRIFT_STEP` (3/gün, ×7 = 21/tik)
adımıyla geri çeker (aşağı yönde temsilci sönümlemesiyle). B2C'de `SalesSystem.SATISFACTION_DRIFT_PER_DAY` 1,5/gün
(~10/tik) deneyim eksenine kayar. Yani olay kartlarındaki ±3..±12'lik memnuniyet çipleri çoğunlukla bir hafta içinde
iz bırakmadan kaybolur; etkisi yalnız o tikte tolerans eşiğini geçirirse (risk/churn sayacı) kalır.

Söz sistemi bunu bilerek çözmüş: `Customer.trust_offset` HEDEFİ kaydırır ve günde 0,4 söner (`b2b_constants.gd`
"Söz dayanıklılığı" bloğu: "Without this the -20 of PROMISE_BROKEN_SAT is erased by SAT_DRIFT_STEP inside one tick").
Olay fiillerinde hedefi kaydıran bir kapı YOK.

**Nasıl uygula:** müşteri kartında kalıcı bedel isteniyorsa memnuniyet tek başına yetmez (MRR, koltuk, churn, söz,
itibar daha kalıcı); geliştiriciye öneri: `trust_offset`'e yazan bir olay fiili ya da `satisfaction_delta`'nın hedefe
yazması. Kod değişmiş olabilir; kullanmadan önce `_tick_satisfaction`'ı yeniden oku.

İlgili: [[writer-agent-pilot-2026-10-08]] · [[vocab-verbs-without-executor]] · [[b2b-sales-system]]
