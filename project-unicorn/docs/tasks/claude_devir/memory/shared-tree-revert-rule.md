---
name: shared-tree-revert-rule
description: Bu checkout'ta `git checkout -- <path>` YASAK — dosya zaten kirliyse başkasının commit'lenmemiş işini siler (2026-08-23'te sildim)
metadata:
  type: feedback
---

**`git checkout -- <path>` kendi düzenlemen için bir geri-al DEĞİLDİR.** Bütün working-copy
diff'ini atar; dosya zaten kirliyse o kirliliğin sahibi sen değilsen işi yok edersin.

**Why:** 2026-08-23'te tam bunu yaptım. `endgame_smoke.gd`'ye geçici bir hata probe'u
enjekte edip `git checkout --` ile geri aldım. Dosyada başka bir oturumun commit'lenmemiş
işi vardı: **6 smoke case yok oldu** (240 → 234) ve HEAD sürümü ağaçtaki kirli
`pitch_constants.gd` / `vc_pitch_system.gd` ile uyumsuz olduğu için **süit hiç derlenmez
hâle geldi**. Kayıt: `docs/audits/SMOKE_LOSS_2026-08-23.md`. Dört case'in gövdesi hiçbir
yerde tam kalmamıştı — scratchpad'lerdeki hunk dosyaları özet ve kesik.

**How to apply:**
1. Bir dosyayı düzenlemeden ÖNCE `git status --short <path>`. Çıktı varsa dosya kirli.
2. Kirliyse önce kenara kopyala (`cp <path> $SCRATCH/bak/`), geri alman gerekirse
   **kopyadan** geri yükle. Asla `git checkout --`.
3. Temizse `git checkout --` güvenli — ama yine de kopya almak ucuz.
4. Geçici probe/enjeksiyon gerekiyorsa: kopyayı al, enjekte et, ölç, kopyadan geri yükle.

Bu checkout'ta paralel oturumlar yazıyor — [[concurrent-session-hazard]] bunu zaten
kaydediyor, ama oradaki kural "sahipsiz değişikliği COMMIT etme"ydi; eksik olan yarısı
"sahipsiz değişikliği REVERT etme"ydi. İlgili: [[partial-staging-shared-tree]] ·
[[ekip-rev11-rebuild]]
