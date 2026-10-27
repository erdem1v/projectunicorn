---
name: build-bar-segment-grammar
description: "Build Bar built 2026-08-19 + same-day fix (ONE refilling TASARIM bar, cap 4) — one BuildBar scene in HUD/tracker/ODA monitor, TASARIM auto-continue + GELİŞTİRME park (enter_beta) mechanics, harness flags, gates"
metadata: 
  node_type: memory
  type: project
  originSessionId: 7a112815-d2a2-49f0-86be-c3db70c63eee
  modified: 2026-08-19T08:34:55.839Z
---

**Build Bar KURULDU 2026-08-19 (uncommitted, Fable commit'ler):** `scenes/ui/components/BuildBar.tscn` + `scripts/ui/components/build_bar.gd` (custom `_draw`, class_name YOK — preload) + `build_bar_model.gd` (türetilmiş model, `derive()` instance metodu, `fingerprint()`). Üç ev sahibi aynı sahne: BuildHUDPanel (`BodyRow/BuildBar`), tracker kartı (`creation_flow._status_bar`), ODA monitör (`oda_view._mon_bar`, `_mon_progress_block` içinde, eski Track/Fill+tween silindi; `--theme-audit=oda` 122→121, yalnız monitör alt ağacı). Widget sinyalleri KENDİ dinler (stored callables + `unbind(1)`); ev sahipleri `refresh()` ÇAĞIRMAZ (smoke falsification bunu gerektirir).

**İki mekanik değişiklik (Erdem onayı, plan Q&A):** (1) TASARIM turları kendiliğinden zincirlenir (`_end_round`/`_start_next_round`, tavanda `_pend_iteration_decision`); `advance_iteration`/`can_advance_iteration` SİLİNDİ; `can_enter_development()` tur 1 bitince; yarım tur kazançsız terk (tooltip `BUILD_HALF_ROUND_TOOLTIP`). (2) GELİŞTİRME %80'de PARK eder — `can_enter_beta()`/`enter_beta()` yeni seam (eski otomatik dev→beta gövdesi); parkta dev-bug birikmez (`working` kapısı). Consult "do not touch #2" bilerek aşıldı (görev metni). `run_probe` politikası + `--tempo-probe` + smoke helper'ları (`_drive_to_round_end`, `_run_iteration_round`, `_run_build_to_phase`) güncellendi — **kalibrasyon worktree'si `run_probe.gd` hunk'ını almazsa `--run-log` dev'de takılır.**

**FİX aynı gün (yönetmen 12 hücreyi "loading bar" diye reddetti):** TASARIM TEK çubuk — turla dolar, tur sonunda boşalıp yeniden dolar (Software Inc.); hücre YOK. `ITER_MAX_ROUNDS` 12→4 (yönetmen kararı; gün/kazanç dokunulmadı). Etiket `BUILD_ROUND_OF`="Tur {n}", tavanda `BUILD_ROUND_LAST`="Tur {n} · son". `iter_ceiling_founder_vs_designer` "plato" yerine "tavana bağlı azalan getiri + işe alım son turu kaldırır" biçimine döndü (cap 4'te plato yok). Fikstür `r4` = tavan parkı.

**Harness:** `--product-shot=tracker --build-state=<r1|r3|dev|devpark|beta|beta0>` (tracker kartı + HUD aynı karede), `--oda-shot=build --build-state=…`, `_seed_build_state()` main.gd'de; settle sonrası `call_group("build_bar","debug_print")` → `[BuildBar] path= rect= model=` satırları (HUD==monitör parmak izi textual kanıt). Dikkat: aynı state için aspect koşusu (`--shot-size`) user:// PNG'sini ÜSTÜNE YAZAR — 1080p'yi sonra yeniden çek. Shot'lar makinedeki renk-körü palet ayarıyla koşar (çipler CB-turuncu/mavi).

**Font gerçeği:** tema MicroLabel FontVariation `get_height(10)=18` (sembol fallback şişiriyor) — BuildBar satır adımı `fs+4`. Smoke 178 case (`build_bar_hosts_agree` eklendi, GameShell'i headless mount eden ilk case — host `EventBus`).

İlgili: [[project-unicorn-current-stage]], [[product-lifecycle-consult]], [[concurrent-session-hazard]], [[smoke-verification-cadence]]


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Build Bar segment grammar](build-bar-segment-grammar.md) — 2026-08-19: tek BuildBar sahnesi ×3 ev sahibi; TASARIM TEK yeniden-dolan çubuk (hücre YOK), cap 4; TASARIM auto-continue + GELİŞTİRME park/enter_beta; --build-state harness; advance_iteration silindi · **2026-08-20 main'e girdi: run_probe merdiveni can_enter_development → can_enter_beta → bugfix(beta-bekleyişi) üç basamağıyla çözüldü; orta basamak düşseydi full_run geliştirmede sonsuza dek asılı kalırdı**
