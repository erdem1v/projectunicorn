---
name: vocab-verbs-without-executor
description: "_vocabulary.md 60 fiil listeler ama 11'inin EvEffects._apply'da kolu yok; lint yalnız liste üyeliğini denetler → kart lint'i geçer, oyunda \"not implemented\" hatası verir"
metadata:
  node_type: memory
  type: reference
  originSessionId: cc9c6a29-a48a-47bf-aca8-bd3f54f34d01
  modified: 2026-10-08T01:48:03.427Z
---

2026-10-08 (yazar pilotu bağlam turu, `scripts/events/core/effects.gd` okundu): `NEUTRAL_VERBS`/`ECONOMIC_VERBS`
listeleri 60 fiil taşır, `_apply` match'i 49'unu uygular. **Kolu olmayanlar:** `change_salary`, `fire_employee`,
`assign_to`, `send_on_leave`, `start_training`, `damage_product`, `add_customer`, `convert_audience`,
`open_paid_tier` (hepsi `push_error "no application for verb"`); `add_mrr` bilerek reddedilir (MRR defterden
türer → `customer_mrr_delta`/`seats`); `open_negotiation` ertelenmiş no-op. Lint (`lint.gd:220`) yalnız listede
olmayı sorar, bu yüzden bu fiillerle yazılan kart lint'ten geçer ve smoke'un `^ERROR:` kapısında düşer.

Çip tarafı (`chips.gd`): `clear_flag`, `set_timed_flag`, `ticker_push`, `notify` ne etiketli ne `SILENT_VERBS`'te →
`event_chip_coverage` düşer. `set_game_flag` sessizdir (çip yok), beyaz liste yalnız `tech_debt_birikti`,
`critical_bug_unfixed`.

**Nasıl uygula:** olay kartı yazdırırken ya da gözden geçirirken fiil listesini `_vocabulary.md`'den değil
`effects.gd` match'inden doğrula; kolsuz fiil `[VOCAB?]` sayılır. Kod değişmiş olabilir: kullanmadan önce yeniden grep et.

İlgili: [[writer-agent-pilot-2026-10-08]] · [[unresolvable-card-token-class]]
