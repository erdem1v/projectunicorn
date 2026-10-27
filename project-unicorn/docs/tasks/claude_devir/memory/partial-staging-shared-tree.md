---
name: partial-staging-shared-tree
description: How to commit only your own work when a parallel session is editing the same files, and how to prove the resulting tree is real
metadata:
  type: feedback
---

Erdem 2026-08-21: "stage only my own files — the parallel session's work is not mine to commit."
When the shared files are shared *inside*, whole-file staging cannot honour that. The working
method:

1. Classify every changed file as mine / theirs / mixed by reading the diffs, not by filename.
2. For mixed files, dump `git diff -U1` split at `^@@`, keep only my hunk indices, reassemble
   with the original file header, and `git apply --cached --recount`. Index-only — the working
   tree is never touched, so the other session keeps its edits.
3. **Re-derive the hunk indices immediately before staging.** They shift whenever either session
   edits the file, including your own later fixes.

**The verification that matters:** the suite runs against the WORKING TREE (mine + theirs), so a
partial-stage commit is unverified by construction. Extract the index into a scratch directory
with `git checkout-index -a -f --prefix=<tmp>/` — that is byte-for-byte the commit tree — then
import and actually run it there. On 2026-08-21 that pass was green (10 cases + loc_residue) and
turned "the hunks look independent" into a measurement.

Cheap pre-checks that caught nothing but would have: grep the *unstaged remainder* for your own
vocabulary (must be 0 hits), and grep the *staged* version of a shared file for THEIR symbols
(must be 0) — an orphan reference is the failure mode partial staging creates.

**Limit (2026-10-18, Faz B paralel partisi):** parça düzeyinde ayırma yalnız adımlar birbirinin SATIRINA dokunmadıysa
çalışır. Paralel adımlardan biri öbürünün yeni fonksiyonunu yeniden adlandırdı ya da aynı satırı değiştirdiyse ara ağaç
hiç var olmamıştır; parçayı seçmek onu kuramaz, ancak elle uydurulur ve koşulmamış olur. O durumda parti tek commit'tir
(mesajda adım başına paragraf); per-step commit isteniyorsa adımlar aynı dosyalarda seri koşulmalı.

Related: [[concurrent-session-hazard]] · [[single-folder-single-remote-rule]] ·
[[smoke-verification-cadence]]
