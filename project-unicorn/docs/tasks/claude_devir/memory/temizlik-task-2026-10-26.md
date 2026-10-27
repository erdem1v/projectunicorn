---
name: temizlik-task-2026-10-26
description: "GOREV_TEMIZLIK oturumu (project-unicorn-1c, c722dc4c) — 11 adım, commit'ler, kopya ağaç + kapı düzeni, scratchpad betikleri, üç oturumlu ORTAK_CALISMA kuralları"
metadata:
  node_type: memory
  type: project
  originSessionId: c722dc4c-f020-4ba9-84b5-360c34f86ff2
  modified: 2026-10-26T14:53:38.227Z
---

Görev `docs/tasks/GOREV_TEMIZLIK.md` (Erdem onayı 2026-10-26, 11 adım). Oturum `project-unicorn-1c`, scratchpad
`c722dc4c…/scratchpad/temizlik/` (bin/, briefs/, envanter/, adim2/, adim3/, msgs/, patches/, logs/), ağaçlar `…/scratchpad/trees/`.

- **Commit'ler:** Temizlik 1 `f21b961` (docs/tasks, mockups renderları, docs/audits, sandbox; arşiv
  `Desktop/Unicorn_arsiv/2026-10-26/`; `/docs/tasks/` .gitignore'da), Temizlik 2 `ccb1677` (29 okunmayan asset, portre
  pişirme boyları, raw Quaternius paketinin 208 dosyası diskten). Push yok.
  Temizlik 3–10 = §3a (A2 aafcc4e, A4 a8c8dc6, A7 24ab32a, A8 5d02d99, A1 d7525a3 yalnız yorum, A3 10e4eee, A5 31861c7,
  A6 1d92180); 11–14 = B1 a068c6c, B2 e6b7894, B3 1ea8081, B4 41650e9. K18 (get_by_type) YAPILMAZ: OLAYLAR kullanıyor.
  C2/C3 U1'de; S7b (_suggest) yeniden üretilemedi. CLAUDE.md §6 kâğıt parantezi isteği (co-director) Erdem onayı bekliyor.
  15–33: B5 23bbc57, B6 afdad51, C4 d8f21ae, C5 89be9aa, C7 6f1cd7b, C9 e54999e, S7a 7059e7e, S7c (Chrome*) 9d5cd3b, C1 a80a608,
  C6 74674f4, ölü kod D01 8edf5c3 · D03 199e41f · D04 e11e414 · D05 1853589 · D10 925748a · D09 74f8e04 (29 boş), HARITA (a)
  06e1f48 ve (b) 6aa4584 (docs/HARITA.md SİLİNDİ, içerik kod haritası sistem sayfalarında). **GÖREV BİTTİ 2026-10-27**, son kapı
  yeşil, rapor https://claude.ai/artifact/HcupSgdpAcuqLhVPypeNTQ. Erdem'de 5 karar (git geçmişi ~300 MB, §6 parantez, taşınma
  rozet metni, type_sector_labels, 132x165 kırpımlar). C8 U7'den sonra; D02 ISLER.md yüzünden yapılmadı.
- **Üç oturum aynı anda** (2026-10-26): URUN_ARAYUZU `project-unicorn-c7`, OLAYLAR `project-unicorn-d5`, yardımcı yönetmen
  `co-director`. Kurallar `docs/tasks/ORTAK_CALISMA.md`: kod kendi `git archive` kopyanda; commit özel index + `update-ref`
  karşılaştırması; kilitler `…/C--Users-erdem-Desktop-Project-Unicorn/kilit/{kapi,ekran,sessiz}`; ortak alanda silmeden önce
  "kullandığınız var mı?" (30 dk); sahipli alanda yalnız C1, A7, B1, B2, Chrome*; C8 U7'den sonra; HARITA emekliliği iki commit.
- **Betikler:** `bin/g.sh` (ağaca özel APPDATA, sessiz/ekran kilidi, MemFree ≥ 2.000 MB), `bin/gates.sh` (lint + residue +
  loc_csv + vakalar paralel, GATE_JOBS=2), `bin/refresh_base.sh` (base = HEAD), `bin/mktree.sh`, `bin/mkpatch.sh`,
  `bin/kapi_commit.sh <konu> <mesaj> [vakalar]` (§3'ün 8 adımı). Kod haritası üçlüsü her kod commit'inde birleşik ağaçta üretilir.
- **Tuzaklar (bu oturumda yaşandı):** koşan bir bash betiğini yerinde düzenleme — bash ofsetten okumaya devam eder; yeni dosya
  yaz + `mv -f`. Git Bash'in `/proc/meminfo`'sunda `MemAvailable` yok, `MemFree` var. `git rm --pathspec-from-file`
  burada "pathspec arguments" hatası verdi; parça parça argümanla geç. `python -I` PYTHONIOENCODING'i yok sayar:
  `sys.stdout.reconfigure(encoding='utf-8')`.
- **Kararlar:** C2/C3 (K02, K13, K14) U1'de yapılmış (`29ae999`). D0b_TABAN ve D_SON_OLCUM yerinde (Faz D'nin 6–8 acil durum kararı).

İlgili: [[codirector-state-2026-10-26]] · [[partial-staging-shared-tree]] · [[godot-import-cache-gotchas]] · [[strings-csv-surgery]]
