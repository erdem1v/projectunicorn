---
name: weekly-time-model-task
description: "Haftalık zaman modeli (bir oyun günü = bir hafta): COMMIT'LENDİ 2026-09-28 (1b8f2f3 kod + d57bdb2 belgeler, PUSH YOK); Erdem'in kararları, mimari, açık maddeler 75–90, doğrulama araçları"
metadata:
  node_type: memory
  type: project
  originSessionId: 2be5b45c-bcd4-4d00-b350-f631c86f5411
  modified: 2026-10-09T19:43:15.768Z
---

**Durum 2026-09-28:** main'de `1b8f2f3` (kod, "TR/EN onay bekliyor") + `d57bdb2` (belgeler). Push edilmedi. Tek kaynak `GDDs/GDD — ZAMAN MODELİ.md` (§4 çeviri tablosu = dönüştürülen her sabit, "Açık" 1–4). Plan: `C:\Users\erdem\.claude\plans\pasted-content-id-c587-g-rev-haftal-k-flickering-pizza.md`.

**Hız merdiveni 2026-10-09 (Erdem: "4x kaç saniye sürüyorsa onu 1x yapalım"):** `TimeModel.SECONDS_PER_HOUR` [0, 2.5, 1.25, 2.5/3, 0.625], hafta 1× 22,5 sn / 4× 5,625 sn. `a90d910` merdiven + ofis `k`'sı saatin hızından (`OfficeConstants.PACE_MINUTES` 6; yeni 1× = eski 4× ofisi); `9404b5d` ajan kararları (satış telefonu saati durdurur, Ev'de kurucu masada kalır; revert edilebilir, onay bekliyor). Açık: ACIK_KARARLAR 104 — demo 60–90 dk artık 104 hafta tavanını aşar (104 hafta ≈ 39 dk), olay çapası, 2×–4×'te ofis donuk tablo (kapı sayaçları 0, toplantı yok), 4× gerçekte 3,85× (gece kesmesinin 0,25 sn kararması).
**Ofis temposu kararı 2026-10-09:** Erdem 2×–4×'te donuk ofisi KABUL ETMEDİ, Software Inc. modelini istedi (her şey hızla doğrusal) ve "eski 90 sn haftanın ritmi"ni seçti: `PACE_MINUTES` 6 her hızda, `VISUAL_CAP` kalkar, k 4/8/12/16 (yürüyüş 9,6–38,4 m/sn). Plan `~/.claude/plans/peppy-doodling-canyon.md`; workflow `wf_c857ae8e-64e`. Software Inc. sayıları zayıf kaynaklı: 1× ≈60 sn/oyun saati (geliştirici "1 year would take 144 hours"), en hızlısı ~3×. Hepsi 2026-10-09'da push edildi (`9404b5d`'ye kadar). **Uygulama COMMIT'LENDİ `74d0b8b` (push yok):** AVOID_MAX_K 6 (2×+ kaçınmasız düz yürüyüş, mesafe bütçesi), ANIM_LOOP_MAX 3, TRIP_K 2, STALL_MIN_S, MEETING_RETRY, CUT_FADE hızla kısalır (4× = 3,96×) — hepsi ACIK 91'de onay bekliyor. Ölçüm: hareket hatası 0, kapı sayaçları hızdan bağımsız; Plaza 40 akşamı 10 çıkış / 29 kesme (eski 22/18) → **Faz 3 (akşam kapı sırası) bekliyor**: `_head_out`'ta `_door_turn` tek yönlü, erken rezerve edilen geç tur aradaki boş turları yakıyor; turları boşluk dolduracak şekilde ayır (sabit değil), `DOOR_S` 0,375 ayrıca onay bekliyor. Son inceleme düzeltmelerinden (FOLLOW adım payı vb.) sonra crowd probe bellek baskısıyla biçildi, yeniden koşulmadı.

**Erdem'in kararları:** para haftalık pay (aylık × 7/30), ay kapanışı sessiz (şerit satırı MRR + nakit farkı); gece ofis boşalınca atlanır, hafta 08:00; satış toplantısı saat bütçesi, 2 saat atlama, kurucu payı saat/40, haftada en fazla 4; temsilci kapanma ihtimali %50/%75/%100, CHURN 2 hafta; istifa 2/3 hafta, zar KALIR; kart başına bekleme süresi; Series A teklifi 3 hafta, uyarı ≤2; üst bar /ay canlı hız; özet sıklığı varsayılan çeyrek; eski kayıt v13→v14 göçüyle açılır.

**Açık (ACIK_KARARLAR 75–90):** temsilci çıktısı–süre bağı, HAYIR DİYEMEZ, alt-hafta çöküşü, kartlar hafta başında, lead ömrü sırası (79), Frank taslakları (90), ölü gün anahtarları (89). Kalibrasyon: ort. son MRR 167K (eski 281K), fark çoğunlukla haftada 4 toplantı tavanı. Tam smoke commit öncesi 347/350 → 3 bayat beklenti düzeltildi; tam süit sonradan YENİDEN KOŞULMADI (commit ağacında 15 hedefli vaka PASS).

**Araçlar:** `--day-shot=<ofis>:<hız>`, `--travel-shot=<ofis>`, `--tempo-probe=<hız>:shell`, `--hr-shot=saatler-gece`. `--check-only` autoload görmez: `-s load_check.gd -- res://a.gd`. Workflow betiği ASCII olmalı. Commit ağacı doğrulaması: `git checkout-index -a --prefix=<dir>/` → import → ısınma → kapılar ([[partial-staging-shared-tree]]).

**Why:** Sonraki oturum push, TR/EN onayı ya da açık maddeler için buraya döner. **How to apply:** 3B karakter ajanının dosyaları (look_system, people_parts, office_gesture, person_bust, ui_factory PersonBust, bake_nav, shaders, avatar_bust, office_body/person, people_lab, tools/people) bu commit'lere GİRMEDİ, onlarındır. Push öncesi [[single-folder-single-remote-rule]]; smoke [[smoke-verification-cadence]].


## Dizinden taşınan not (2026-10-16)
MEMORY.md'deki eski dizin satırı, olduğu gibi:
- [Weekly time model task](weekly-time-model-task.md) — oyun günü = hafta; COMMIT'LENDİ 2026-09-28 (1b8f2f3 + d57bdb2, push yok); kararlar, açık 75–90, 3B ajanın dosyaları hariç tutuldu; **2026-10-09 merdiven ×4 hızlandı (`a90d910` + `9404b5d`), açık 104; ofis temposu hızla doğrusal `74d0b8b` (push yok), Faz 3 akşam kapı sırası bekliyor**
