---
name: feedback-push-without-full-smoke
description: "Erdem 2026-10-06: push istendiğinde tam smoke koşmadan doğrudan push et; commit'ler zaten kendi kapılarından geçti"
metadata:
  node_type: memory
  type: feedback
  originSessionId: bdb8d661-b2cc-40d3-a6eb-43f58d809039
  modified: 2026-10-05T21:49:39.769Z
---

Erdem "push et" dediğinde push öncesi tam smoke süiti KOŞULMAZ; commit'lenmiş olan doğrudan push edilir.

**Why:** 2026-10-06'da Modallar'ı push etmeden önce 351 vakalık süiti (2 paralel, ~50 dk) yeniden başlatırken
Erdem durdurdu: "smoke test yapmadan push edebilirsin, 100. kez smoke test yapılıyor bu ağaçtakilere, yalnızca push et
şu an". Her ekran commit'i hedefli smoke, event-lint, loc_residue, tema ve görsel kabul kapılarından zaten geçiyor;
push öncesi tam süit aynı ağaca tekrar bekleme ödetiyor. CLAUDE.md §10'daki "tam paketi yalnız push öncesi" cümlesini
Erdem bu talimatla aşıyor.

**How to apply:** push isteğinde: `git fetch`, uzak dal listesini göster (yalnız `main`), fast-forward olduğunu doğrula,
`git push origin HEAD:refs/heads/main`. Tam süit yalnız Erdem isterse ya da gerçek bir entegrasyon şüphesi varsa ve
önce sorarak. Commit öncesi ekran kapıları (hedefli smoke dahil) aynen sürer.

İlgili: [[smoke-verification-cadence]] · [[single-folder-single-remote-rule]] · [[bg-shell-memory-reap]]
