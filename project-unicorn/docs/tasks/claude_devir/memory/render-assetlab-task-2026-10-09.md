---
name: render-assetlab-task-2026-10-09
description: "PRD_RENDER_ASSETLAB uygulaması (oturum 30c68c34): sahibin 2 kararı, plan yolu, PRD'yi düzelten motor bulguları, tasarım notlarının yeri, commit sırası"
metadata:
  node_type: memory
  type: project
  originSessionId: 30c68c34-40f9-4fe4-9685-b6948fe3a152
  modified: 2026-10-09T20:46:37.092Z
---

Erdem 2026-10-09'da `docs/tasks/PRD_RENDER_ASSETLAB.md`'yi (`f035743`) "oku ve uygula" dedi; ultracode açık, alt
ajanlar Sonnet. Onaylı plan: `~/.claude/plans/project-unicorn-docs-tasks-prd-render-as-zippy-tide.md`.

**Sahibin kararları:** (1) denetim PNG'leri git'e girmez, `docs/audits/{render,asset_lab}/**/*.png` gitignore, md
raporlar commit'lenir, kilit kareler SendUserFile; (2) Bölüm 2 PRD'nin TAM seti (6 kamera × 3 varyant × gündüz/gece),
kademeli kapı önerisi reddedildi.

**PRD'yi düzelten bulgular (Godot 4.6.2 kaynağı):** gölge kutusu genişliği `2r = (N/2)·unit` ile sabit, aday 2
aritmetikle elenir; TAA yokken PCF deseni salt ekrana yapışık (beklenen kök neden, `soft=0` sıfırlamalı);
`glow_hdr_scale` düşürmek parlamayı ARTIRIR (eşik yükselt / yoğunluk indir); `_lowest` sınırdan alınırsa plaza ve
meet'te görünen geometri kesilir (kazanç kesmesiz %8-13 → commit kapılı); isimsiz parlayanlar taksi levhası, WC
tabelası, asansör göstergesi, TV, arcade, LED (emission imzasıyla); 19:25 için `min` düğmesi; iki gölgeli yönlü ışık
atlası böler.

**Notlar** (keşif, tasarım, eleştirmen; ajanlara verilir): oturum scratchpad'i `notes/` (explore.json, design.json,
design_part1_probe.md, design_part2_lab.md, critic.md, inst.mjs). Kenney zip'leri araştırma oturumu scratchpad'inde
`2a632836-…/scratchpad/dl/`.

**Commit sırası:** 0 (gitignore + 3 .gdignore) → a (prob) → b/c/d1-d4 (render) → Bölüm 1 md → e1/e2 (sandbox). Push yok.
Paralel oturum aynı gün ofis kişileri dosyalarında (office_people/person, office_constants) çalışıyordu.

**Durum 2026-10-09 22:40:** main'de `a6b4592` (0) · `293d14e` (e1) · `a878ce3` (a) · `0d17090` (b1 döşeme z-çatışması,
toon `inset`) · `d580b66` (b2 Hard filtre) · `a64bfe7` (d4 akşam geçişi) · `d9931dc` (d2 TOP_FILL_NIGHT 0,5) · `ec5895a`
(prob lowest/topk + çıkış çökmesi onarımı). c (`_lowest`) commit YOK: kesme testi geçmedi, sahip kararı. d1 (glow)
değişiklik YOK: glow yalnız ışık kaynaklarında. d3 `e78b922` (EMITTERS: taksi post_on, cihazlar ofis elektriği).
**Bölüm 1 TAMAM** `d4cc9fb` (TESHIS/AYARLAR/PERFORMANS; sayılar ayrı ajanla ham kayıtlara karşı doğrulandı, kilit
kareler SendUserFile ile gönderildi). **Bölüm 2 TAMAM** `1e2d9a0` (laboratuvar + tarifler + KARSILAMA + HUKUM; hüküm
"kısmen": iç mekân Kenney + B kurulur, kabuk/şehir bağlamı yok, palet boyanmalı; sanatçı ~80-110 sa, paket hattı
32-50 sa). TASK BİTTİ 2026-10-09 ~23:55, push yok. Onay bekleyenler (F5): Hard, TOP_FILL_NIGHT 0,5 (alt. 0,3), akşam
penceresi 1150-1200, EMITTERS rolleri, `_lowest` seçenekleri (öneri: kalsın), aile/varyant (öneri Kenney + B).
Laboratuvar oyunun 3B görüntüsünü 1736×976 çeker (ACIK_KARARLAR 70'teki 1836×992 eski).
Kök neden iki mekanizma: ev döşemesi-cephe z-çatışması + Soft Low PCF deseni ekrana yapışık. Gece parlaması TopFill
(glow değil). Laboratuvar kalibrasyonu LABCAL 0 (bit bit). Stil testi: ana aile Kenney. B3 tarif workflow'u
`wf_40721dc1-26e`. A6 yeniden çekim betiği scratchpad `tools/a6_capture.sh`; taslak md'ler `docs/`.
**Tuzak:** prob düğmesi script lambdasını `RenderingServer.frame_pre_draw`'a bağlı bırakırsa Godot çıkışta segfault
(139) verir; düğmeler PANDONE'dan önce geri alınmalı.

İlgili: [[partial-staging-shared-tree]] · [[godot-mcp-runtime-verification]] · [[codirector-session-2026-10-07]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Render + asset lab task 2026-10-09](render-assetlab-task-2026-10-09.md) — PRD_RENDER_ASSETLAB **TAMAM 2026-10-09** (11 commit `a6b4592`…`1e2d9a0`, push yok): kök neden ev z-çatışması + Soft Low PCF deseni; gece parlaması TopFill (glow değil); hüküm Kenney+B 'kısmen'; F5 onayları ve `_lowest` sahip kararı bekliyor; prob lambdası çıkışta bağlı kalırsa segfault
