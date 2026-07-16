# Event Layer Editorial & Integrity Audit

**Date:** 2026-07-14 · **Type:** READ-ONLY audit (no copy rewrites, no modifier changes, no deletions) · **Scope:** live tree `project-unicorn\` only. Sibling report: `state_coherence_audit_2026-07-14.md` (state plumbing).

## Context & method

This audit is about **content quality**, not state plumbing. Every event is covered — no sampling: 22 JSON files in `data\events\**` (19 loaded + 3 `ev_debug_*` that the loader skips at `event_manager.gd:566-567`) and 9 synthetic events built in code. For each event: id, triggers, time-of-day firing, body text, and each choice's label + modifiers, then flagged against seven defect classes. A single event can hit several.

**Schema note (load-bearing):** `EventChoice` (`event_choice.gd:20-24`) exposes only `label`, `modifiers`, `unlock_condition`, `unlock_reason_text`; `GameEvent` (`event.gd:27-49`) has no per-choice or per-event **"outcome text"** field. The only outcome a player sees is the effect badges the modal renders from `modifiers` — and any modifier that renders no badge (notably every `set_flag`) is **invisible at decision time**.

**Firing-window baseline (Class 3):** `allowed_hours:[start,end]` exists and is honored (parsed at `event_manager.gd:593-599`, gated hourly at `:337-340`; `start>end` wraps midnight). Events with **no** `allowed_hours` always pass the time gate — so a subtitle asserting a clock time with no window can surface at any hour. All synthetic beats carry no window.

**Defect classes:** (1) fake/inert choice · (2) implies unbuilt system (deletion candidate) · (3) time-of-day mismatch · (4) raw stat codes in the effect display · (5) choice pre-judges for the player · (6) language integrity (mixed TR/EN) · (7) editorial register.

---

## 1. Per-event blocks

### GROUP A — DEBUG FIXTURES (NOT-LOADED; loader skips `ev_debug_*`)

**ev_debug_001_engineer_workload** — title "Mühendisin mola istiyor" · subtitle "Ofis · 18:30 [DEBUG]" · char char_debug_eng_a · day_min 3, random .30 · cd 14 · no window
Body: *"**Debug Engineer A** son sprint'i bitirip masada uyukladı… gözleri *biraz çukurlanmış*. [DEBUG content]"*
Choices: "Bu hafta izin ver" → morale+5, cash−2000 · "Deadline'a kadar bastır" → morale−3, brand+1 · "Yardımcı bir mühendis daha al" → cash−8000, morale+3
Flags: **C6** `sprint`, `Deadline`, `Debug Engineer A`, `[DEBUG content]` · **C3** subtitle 18:30, no window · **C7** placeholder voice.

**ev_debug_002_press_inquiry** — title "Basın arıyor" · subtitle "TechCrunch e-mail · 11:14 [DEBUG]" · day_min 5, random .20 · cd 21 · no window
Body: *"TechCrunch muhabiri bir alıntı istiyor… [DEBUG content]"*
Choices: "Açıklama gönder" → brand+3, rep+1 · "Reddet" → brand−2 · "Sıcağı sıcağına konuş" → brand+6 (locked: reputation_above 10, "Reputation 10+ gerekli")
Flags: **C1** "Sıcağı sıcağına konuş" (brand+6, no downside) strictly dominates; "Reddet" (brand−2) strictly dominated · **C6** `e-mail`, `AI startup`, `[DEBUG content]` · **C4-copy** "Reputation 10+ gerekli" (raw stat name, L40) · **C3** 11:14, no window.

**ev_debug_003_cash_warning** — title "Frank arıyor — runway" · subtitle "Telefon · 09:45 [DEBUG]" · char frank · cash_below 30000 · one_shot · pri 10 · no window
Body: *"…**Üç haftalık runway**… [DEBUG content]"*
Choices: "Tool harcamasını kıs" → cash+5000, morale_all−3 · "Küçük bir köprü turu denesem? [NOT IMPLEMENTED]" → [] (locked: phase 99, "VC sistemi henüz yok") · "Mevcut yolda devam et" → []
Flags: **C1** two empty-modifier options · **C2** bridge-round "[NOT IMPLEMENTED]" · **C6** `runway`, `Tool` · **C7** "[NOT IMPLEMENTED]" leaked into a label · **C3** 09:45, no window.

### GROUP B — LIVE MVP BUILD-PHASE EVENTS

**ev_mvp_dev_001_integration_broken** *(the scrutiny case)* — title "Bir şey çalışmıyor" · subtitle "Mutfak masası · 02:17" · build_phase development, random .30 · allowed_hours [1,4] · cd 14 · one_shot
Body (…dev_001.json:8): *"Saat ikiyi geçiyor. Üçüncü kahve soğumuş. **API tarafından dönen JSON** ile UI'da beklediğin shape arasında bir uçurum açıldı — büyük değil ama kapanmıyor.\n\nMantıklı yol: yarın taze gözle bak. Pratik yol: bir hack ile geç, sonra döner düzeltirsin.\n\n*Sonra dönüp düzeltmek.* O sözü daha önce de duymuştun."*
Choices:
- "Gece boyu uğraş, doğru yap" → stability **+6**, delay **+1**, →`founder_fatigue` *(hidden)*
- "Geçici çözüm — TODO listesine ekle" → delay **−2**, bug **+2**, →`tech_debt_birikti` *(hidden)*
Flags:
- **C1** asymmetry: slow = +6 stab / +1 day / +fatigue(hidden); fast = −2 days / +2 bug / +tech_debt(hidden, arms the punishing ev_mvp_dev_002). Both sides carry an invisible `set_flag` cost; the fast option displays only two badges (−2 days, +2 bug) and reads as a net time-saver — its real cost is unbadged.
- **C5** body pre-labels the paths: *"Mantıklı yol… Pratik yol…"*.
- **C6** `API`, `JSON`, `UI'da`, `shape`, `hack` (body); `TODO` (label).
- **C7** incoherent metaphor: *"UI'da beklediğin shape arasında bir uçurum açıldı — büyük değil ama kapanmıyor"*.
- **C3** 02:17 / "Saat ikiyi geçiyor" within [1,4] → ALIGN (mild: "just past 2" can surface up to 04:xx).

**ev_mvp_dev_002_tech_debt_callout** — title "Borç faturayı kesiyor" · subtitle "Stack overflow tab'ı · 14:33" · build_phase development + flag_set tech_debt_birikti + random .25 · [13,17] · cd 16 · one_shot
Body: *"İlk hafta açtığın o kestirme… şimdi üç ayrı yerden bağırıyor…"*
Choices: "Dur, düzelt" → stab+6, delay+2, tech_debt=false · "Üstüne build etmeye devam" → delay−1, bug+2, tech_debt=true
Flags: **C6** `Stack overflow tab'ı`, `build etmek` · **C3** 14:33 in [13,17] → ALIGN · **C1** meaningful trade (fast side re-arms the gating flag — loop by design).

**ev_mvp_dev_003_solo_dev_fatigue** — title "Tek başına ağır" · subtitle "Yatak odası · 07:48" · build_phase development + random .20 · [6,9] · cd 20 · one_shot
Body: *"Alarm çaldı, kalkmadın… Bir kullanıcı feedback'i yok, deadline yok — sadece sen ve laptop…"*
Choices: "Bugün kendine ver" → delay+1, stab+2, →founder_recovery · "Zorla, kahve yap" → delay−1, bug+2, →founder_fatigue
Flags: **C6** `feedback`, `deadline`, `laptop`, `runway` · **C3** 07:48 in [6,9] → ALIGN · **C1** meaningful trade.

**ev_mvp_iter_001_scope_creep** — title "Bu feature beklediğimden derinmiş" · subtitle "Mutfak masası · 23:14" · build_phase iteration + random .35 · [22,2] · cd 12 · one_shot
Body: *"…ya bunu **doğru** yap — birkaç gün daha. Ya da **kırp**, görsel olarak duruyor, altı boş."*
Choices: "Düzgün yap" → usab+6, delay+2 · "Kırp, yüzeyi koru" → delay−1, bug+3, →scope_creep_kirpildi
Flags: **C6** `feature`/`Feature'ı`, `tab` · **C5 (mild)** body frames the crop path as hollow (*"altı boş"*) · **C3** 23:14 in [22,2] → ALIGN.

**ev_mvp_iter_002_competitor_signal** — title "Rakip benzer şey duyurdu" · subtitle "Twitter · 11:02" · build_phase iteration + random .25 · [8,11] · cd 21 · one_shot
Body: *"…**Y Combinator W26 batch'inden bir ekip**… Onların post'u temiz, demo video pürüzsüz, comment'ler iyi…"*
Choices: "Onların eksik yerine eğ" → inno+5, delay+2, →pivot_versus_rakip · "Kendi yolundan sapma" → brand+2, inno−2
Flags: **C6 (heavy)** `feed`, `thread`, `batch`, `post`, `demo video`, `comment` · `Y Combinator W26` [PROPER] · **C3** 11:02 in [8,11] → ALIGN.

**ev_mvp_iter_003_early_user_feedback** — title "Tanıdıktan istenmemiş geri bildirim" · subtitle "WhatsApp · 16:48" · build_phase iteration + random .25 · [16,20] · cd 18 · one_shot
Body: *"…Ama söyledikleri mantıklı. Mantıklı geliyor…"*
Choices: "Önerilerini ciddiye al" → usab+6, delay+2, cash−100, →early_feedback_dinlendi · "Vizyonuna sadık kal" → delay−1, brand+1, usab−2
Flags: **C6 (light)** `demo`; `WhatsApp` [PROPER] · **C5 (mild)** *"söyledikleri mantıklı. Mantıklı geliyor"* nudges toward listening · **C3** 16:48 in [16,20] → ALIGN.

**ev_mvp_bugfix_001_critical_bug** — title "Bir bug buldun ki..." · subtitle "Mutfak masası · 19:22" · build_phase bugfix + random .40 · [18,23] · cd 14 · one_shot · pri 1
Body: *"…**Edge case**: belki kullanıcıların yüzde biri görür… launch günü forumda gözükür mü…"*
Choices: "Launch'u ertele, çöz" → bug−6, stab+4, cash−150 · "Bırak, gönder — fark eden olmaz" → →`critical_bug_unfixed` *(hidden = +5 launch bugs)*, brand−2
Flags: **C1 (hidden-cost)** the ship-it option shows only `brand −2`; its real weight (`critical_bug_unfixed`) has no badge · **C6** `bug`, `Edge case`, `launch`/`Launch'u` · **C3** 19:22 in [18,23] → ALIGN.

**ev_mvp_bugfix_002_early_launch_pressure** — title "İçeride bir ses 'şimdi çık' diyor" · subtitle "Bilanço tab'ı · 10:15" · build_phase bugfix + random .30 · [9,12] · cd 15 · one_shot
Body: *"…her gün **runway eriyor**…"*
Choices: "Bir tur daha temizlik" → bug−4, stab+2, cash−100, →polish_one_more_pass · "Hazır olmasa da çık" → brand−1, →`launch_pressure_kabul` *(hidden)*
Flags: **C6** `tab'ı`, `runway`, `Bugları`; flag key `launch_pressure_kabul` mixes EN/TR · **C1 (hidden-cost)** ship option shows only `brand −1` · **C3** 10:15 in [9,12] → ALIGN.

**ev_mvp_bugfix_003_final_polish** — title "Küçük bir cila fırsatı" · subtitle "Demo videosu · 23:51" · build_phase bugfix + random .25 · [21,1] · cd 12 · one_shot
Body: *"…Bir font hizalaması yamuk…"*
Choices: "Vakit harca, cila çek" → usab+5, cash−80 · "Yeterince iyi — devam" → usab−2, bug+1
Flags: **C1 (weak trade)** "Yeterince iyi" grants NO upside — purely negative (usab−2, bug+1), no `delay_days` saved to represent the time it fictionally buys → near-dominated by the polish option · **C6** `Demo`, `font` · **C3** 23:51 in [21,1] → ALIGN.

**ev_mvp_cofounder_offer_dev** — **DELETION CANDIDATE** — title "Ortaklık önerisi" · subtitle "Kahve · 15:30" · build_phase development + day_min 10 + random .15 · [14,17] · one_shot · pri 2
Body (…dev.json:8): *"Eski iş arkadaşın. **İki yıl önce Trendyol'da beraber çalışmıştınız** — sen front-end, o data tarafı… Kabul edersen — yarısı onun, eşit söz hakkı, yarın sabah farklı bir şirket. Etmezsen — hâlâ tek başına, hâlâ kontrol sende."*
Choices: "Kabul et — birlikte daha güçlüyüz" → →cofounder_offer_accepted, →cofounder_offer_source · "Reddet — bu benim çocuğum" → →cofounder_offer_declined
Flags: **C2** body promises equity split / co-ownership (*"yarısı onun, eşit söz hakkı"*) — no cofounder character, equity, morale, or cash is ever created; both branches write flags only · **C1** BOTH choices produce zero visible badges → the momentous decision has no observable outcome (strongest fake-choice in the set); the flags are read by nothing (state audit §A.2) → accept vs decline = identical game state · **C6** `front-end`, `data`; `Trendyol` [PROPER] · **C3** 15:30 in [14,17] → ALIGN.

**ev_mvp_cofounder_offer_iter** — **DELETION CANDIDATE** — identical copy/choices/flags to `_dev`; the only difference is trigger `build_phase iteration`. Also a byte-level duplicate of `_dev`. All flags above apply verbatim.

### GROUP C — LIVE POST-SHIP (PS) EVENTS  *(all tags: build_safe)*

**ev_ps_first_revenue** — title "Biri ödedi" · subtitle "Stripe bildirimi · 08:03" · char frank · mrr_above 0 · one_shot · pri 8 · **no window**
Body: *"Telefon titriyor. Stripe… 'İşte. Artık bir şirketsin. Küçük, ama şirket.'"*
Choice: "Bir nefes al" → →first_revenue_seen, mentor_advisory "İlk dolar geldi. Şimdi ikinciyi, üçüncüyü bul."
Flags: **C3** subtitle 08:03 (morning) but NO window → can surface at any hour · **C1** single-option beat (inert by design); `Stripe` [PROPER].

**ev_ps_frank_intro_b2b** — title "Frank bir kapı aralıyor" · subtitle "Telefon · 10:20" · char frank · mvp_shipped + market_type b2b · one_shot · pri 5 · **no window**
Body: *"…Şu yeni şeyini görmek istiyor — toplantı ayarladım. Hazırlıklı git. Yumuşatma. Sales sekmesinde seni bekliyor olacak."*
Choice: "Tamam — hazırlanayım" → add_prospect mid, mentor_advisory "İlk pitch'in Sales sekmesinde. Yumuşatma, ürünü göster."
Flags: **C6** `Sales sekmesinde`, `pitch` · **C7 / C4-copy** UI tab named in Frank's mouth (*"Sales sekmesinde seni bekliyor olacak"*) · **C3** 10:20, no window · **C1** single-option beat.

**ev_ps_b2c_paid_tier** — title "Fiyatlandırma vakti" · subtitle "Mutfak masası · 21:40" · char frank · market_type b2c + audience_above 15 · one_shot · pri 6 · **no window**
Body: *"…**Product sekmesindeki** fiyat cetveli ürünün ederini sana gösteriyor…"*
Choice: "Cetveli aç" → →pricing_prompt_seen, mentor_advisory "Fiyat cetveli Product sekmesinde…"
Flags: **C6** `Product sekmesindeki` / `Product sekmesinde` · **C7 / C4-copy** UI-tab reference / tutorial voice in narrative · **C3** 21:40, no window · **C1** single-option beat.

**ev_ps_bug_complaint** *(category scandal)* — title "Bu çalışmıyor" · subtitle "Destek kutusu · 16:48" · customer_count_min 1 + customer_satisfaction_below 60 + random .5 · [9,18] · cd 8 · pri 2
Body: *"Bir müşteri yüksek sesle şikayetçi… Diğer müşteriler de okuyor…"*
Choices: "Refund + özür dile" → cash−1500, sat+20 · "Hot-fix sözü ver" → sat+8, cash−300, →hotfix_promised · "Görmezden gel" → churn_customer, brand−2
Flags: **C6** `Refund`, `Hot-fix` (English in choice labels) · **C3** 16:48 in [9,18] → ALIGN · choices meaningful.

**ev_ps_expansion_b2b** *(category opportunity)* — title "Seat artırımı" · subtitle "Toplantı · 11:15" · market_type b2b + customer_count_min 1 + random .25 · [10,16] · cd 14 · pri 1
Body: *"Müşterilerinden biri memnun: 'Ekibimde daha çok kişi kullanmak istiyor. Koltuk ekleyebilir miyiz?'…"*
Choices: "Önerilen fiyattan ekle" → customer_mrr+600, sat−5 · "Pazarlık et" → customer_mrr+1000, sat−12 · "Bedavaya ver" → sat+10
Flags: **C6 / internal inconsistency** title uses English `Seat` while the body says Turkish `Koltuk ekleyebilir miyiz?` — one concept, two languages in one event · **C3** 11:15 in [10,16] → ALIGN · choices meaningful. *(State-side: no seat count moves — see state audit §A.1.)*

**ev_ps_referral_b2b** *(category opportunity; soft deletion candidate)* — title "Patronun arkadaşı" · subtitle "E-posta · 13:05" · market_type b2b + customer_count_min 1 + random .3 · [9,17] · cd 12 · pri 1
Body: *"…'Tek ricam, şu özelliği **roadmap'inize** almanız…' …ama **roadmap'ine** bir borç yazıyor."*
Choices: "Kabul et — feature sözü ver" → add_prospect mid, cash−400, →feature_debt · "Pazarlık et — söz verme" → add_prospect small · "Reddet — roadmap temiz kalsın" → rep+2
Flags: **C6** `roadmap` ×3, `feature` · **C2 (soft)** the "feature sözü ver" branch writes `feature_debt` (unread — state audit §A.2), implying a roadmap-promise/debt tracker not built · **C3** 13:05 in [9,17] → ALIGN.

**ev_ps_b2c_producthunt** *(category opportunity)* — title "Product Hunt penceresi" · subtitle "Slack DM · 23:11" · market_type b2c + flag_set b2c_paid_tier_open + audience_above 30 + random .4 · [20,23] · cd 10
Body: *"Bir tanıdık yazdı: 'Yarın Product Hunt'ta launch etsene…'"*
Choices: "Launch et" → convert_audience 25%, brand+3, aud+20, cash−800 · "Pas geç" → aud+6
Flags: **C6** `launch etsene`, `Launch et`, `Slack DM`; `Product Hunt` [PROPER] · **C3** 23:11 in [20,23] → ALIGN.

**ev_ps_power_user_b2c** *(category opportunity)* — title "Erken hayran" · subtitle "X / Twitter · 19:30" · market_type b2c + customer_count_min 1 + audience_above 40 + random .3 · [18,22] · cd 12
Body: *"…'Bu araç iş akışımı değiştirdi, herkes denemeli.'…"*
Choices: "Tanıtım yaz" → brand+4, aud+25, cash−600 · "Sessiz kal" → aud+5
Flags: **C6 (light)** `Momentum` [LOAN]; `X / Twitter` [PROPER] · **C3** 19:30 in [18,22] → ALIGN.

### GROUP D — SYNTHETIC EVENTS (built in code)

**ev_mvp_ship_moment** — product_system.gd:845-869 · char frank · one_shot · pri 10 · tags build_safe, ship_moment · no window
Body (`:853`): *"Demo'ya bir kez daha bakıyorsun… Birkaç dakika sonra GitHub'da repo public, küçük bir landing page canlı…"*
Choice: "Ship'le" → ship_active_build
Flags: **C6** `Demo`, `GitHub'da repo public`, `landing page`, `Ship'le` · **C7** English-laden scene-setting · **C1** single-option ship beat (inert by design).

**ev_mvp_version_ship_moment** — product_system.gd:818-842 · title "v%d yayında" · one_shot false · pri 10
Body (`:828`): *"Yeni sürümü push'luyorsun… 'Yeni feature'lar tuttu — ama yeni yüzey, yeni bug demek.'…"*
Choice: "Yayına devam" → ship_active_build
Flags: **C6** `push`, `feature`, `bug` · **C1** single-option ship beat.

**ev_phase_gate_traction** — phase_gate_system.gd:161-192 (copy L36-41) · char frank · pri 10 · tags build_safe, phase_gate
Body[0]: *"…Traction fazı vites değiştirmek demek: ölçek baskısı, churn, daha büyük masalar…"* (reminders L39-40)
Choices: "Hazırız — geçelim" → advance_phase · "Henüz değil" → phase_gate_decline
Flags: **C6** `Traction` (phase name), `churn` · choices meaningful (decline defers, no penalty).

**ev_phase_gate_series_a** — phase_gate_system.gd:161-192 (copy L50-55) · char frank · pri 10
Body[0] (`:52`): *"…**MRR tutuyor, marka ayakta**. Series A avı açık. Runway'in dar mı geniş mi…"* (reminders L53-54)
Choices: "Hazırız — geçelim" → advance_phase · "Henüz değil" → phase_gate_decline
Flags: **C4-copy** raw stat `MRR` spoken in Frank's line · **C6** `MRR`, `Runway`/`runway`, `pitch`; `Series A` [established].

**ev_shutter_warning** — endings_system.gd:271-295 · title "Kırmızıdasın" · char frank · pri 10 · tags build_safe, endgame
Body (`:281`): *"…**TopBar'daki sayaç** bugünden itibaren geri sayıyor. Kasa artıya dönerse sayaç durur."*
Choice: "Anlaşıldı" → [] (no modifiers)
Flags: **C6 / C7 / C4-copy** internal UI node `TopBar` named in narrative · **C1** single-option inert acknowledgement (warning beat, by design).

**ev_pivot_offer** — endings_system.gd:298-326 · title "Üçüncü kapı da kapandı" · char frank · pri 10
Body (`:306`): *"…VC yolu kapanıyor. Kendi paranla, kendi müşterinle, **Day %d'e kadar** — hâlâ gerçek bir şirket kurabilirsin."*
Choices: "Pivot — devam ediyoruz" → accept_pivot · "Hayır. Bitti." → decline_pivot
Flags: **C6 / C7** English `Day` embedded in a TR sentence (renders "Day 179'e kadar"); `VC` [LOAN], `Pivot` (label).

**ev_acquisition_offer** — endings_system.gd:329-359 · title "Satın alma teklifi" · char frank · pri 10
Body (`:339`): *"Mail bir cuma akşamı geliyor; büyük oyuncular hep cuma yazar. Seni satın almak istiyorlar. Ekip kalır, isim kalmaz…"*
Choices: "Kabul et — sat" → accept_acquisition · "Reddet — devam" → →acquisition_offer_rejected *(orphan; state audit §E-A.4/§E-B.2)*
Flags: **C6 (light)** `Mail` [LOAN]; register otherwise strong. Choices meaningful (accept = terminal; reject continues).

**ev_vc_meeting_prompt** — vc_pitch_system.gd:710-735 · title "Toplantı zamanı — %s" · char frank · pri 10
Body (`:719`): *"Randevu günü geldi. %s masada. … Hazırsan gir. Hazır değilsen de gir — takvim beklemez."* (interpolates investor name + `archetype_line`)
Choices: "Toplantıya gir" → start_vc_meeting · "Bugün değil (randevu yanar)" → decline_vc_meeting
Flags: mostly clean TR; `archetype_line` is external data (not statically inspectable). Choices meaningful.

**ev_sheet_expiry_warning** — vc_pitch_system.gd:738-758 · title "Teklifin süresi doluyor" · char frank · pri 9
Body (`:746`): *"%s'in teklifi %d gün sonra yanıyor. 'Karar ver. Masaya otur ya da bırak — ama sallanma.'"*
Choice: "Anlaşıldı" → [] Flags: **C1** single-option inert acknowledgement (by design). Clean TR.

**ev_vc_d179_warning** — vc_pitch_system.gd:761-780 · title "Yarın son gün" · char frank · pri 10
Body (`:768`): *"Frank kapıda. 'Yarın son gün. Cebinde teklif var. İmzalayacaksan bugün imzala.'"*
Choice: "Anlaşıldı" → [] Flags: **C1** single-option inert acknowledgement (by design). Clean TR. (Internal `d179` lives only in the id.)

---

## 2. Class-by-class synthesis

**CLASS 1 (fake / inert choice).** Strongest true defect = the two cofounder events (both branches all-flags, zero visible outcome, identical state). Hidden-cost pattern = the fast options whose only real weight is an unbadged `set_flag`: `ev_mvp_dev_001`, `ev_mvp_bugfix_001`, `ev_mvp_bugfix_002`. Weak trade = `ev_mvp_bugfix_003` "Yeterince iyi" (pure negative, no time saved). Strict dominance (debug) = `ev_debug_002`. Single-option narrator **beats** (ship moments, shutter/sheet/d179 warnings, first_revenue, frank_intro, paid_tier) are inert **by design** — a distinct "beat, not choice" category, not defects.

**CLASS 2 (unbuilt system → deletion candidate).** Cofounder events (equity/co-ownership); soft: `ev_ps_referral_b2b` (feature-debt tracker); debug `ev_debug_003` bridge-round. See §3.

**CLASS 3 (time-of-day mismatch).** The window mechanism exists and every **ambient** event that asserts a clock has a matching window. The mismatch class is **deterministic beats with a clock in the subtitle but no `allowed_hours`**: `ev_ps_first_revenue` (08:03) and `ev_ps_frank_intro_b2b` (10:20) can fire at any hour (plus the NOT-LOADED debug trio). Synthetic beats assert no clock. Mild edge: `ev_mvp_dev_001` "Saat ikiyi geçiyor" with a [1,4] window can surface up to 04:xx.

**CLASS 4 (raw stat codes in the effect display).** Primary source is the display layer and is a **single central fix** — `event_modal._describe_modifier` (`event_modal.gd:146-169`):
- `dimension_delta` → cryptic 3-letter codes **"İno / Krl / Kul"** (`:158`), e.g. "Krl +6" (Erdem's exact example; should read "Kararlılık …").
- English stat names in a Turkish UI: **"Cash"** (`:147`), **"MRR"** (`:148`), **"Brand"** (`:149`), **"Rep"** (`:150`), **"Bug"** (`:162`) — while other badges are correctly Turkish ("Müşteri MRR" `:153`, "Memnuniyet" `:154`, "Kitle" `:155`, "Ekip" `:152`, "Kalite" `:166`, "gün" `:165`). The defect is this **inconsistency**.
- Tooltip: badges render inline (`:105-110`); most choices carry 2-3 modifiers → per Erdem's "2+ effects → tooltip preferred," these are candidates for a hover reveal. Readable displays like "Kararlılık +2 · +1 gün" are **not** flagged (correct grammar).
Raw codes embedded directly in **prose/labels** — the full list — is in §4.

**CLASS 5 (choice pre-judges).** Flagship: `ev_mvp_dev_001` *"Mantıklı yol… / Pratik yol…"*. Milder: `ev_mvp_iter_001` (*"altı boş"*), `ev_mvp_iter_003` (*"söyledikleri mantıklı"*).

**CLASS 6 (language integrity).** Exhaustive inventory in §5.

**CLASS 7 (register).** Incoherent metaphor: `ev_mvp_dev_001` (*"shape… uçurum"*). UI/tutorial voice in NPC mouths/narrative: `ev_ps_frank_intro_b2b`, `ev_ps_b2c_paid_tier`, `ev_shutter_warning` (TopBar). English-laden scene-setting: `ev_mvp_ship_moment`. Placeholder voice (NOT-LOADED): debug fixtures.

---

## 3. Deletion candidates (Class 2)

| Event | file | Why |
|---|---|---|
| **ev_mvp_cofounder_offer_dev** | data/events/reactive/ev_mvp_cofounder_offer_dev.json | Cofounder/equity fiction (*"yarısı onun, eşit söz hakkı"*); both branches write ONLY `set_flag` — no character, equity, cash, or morale; no system consumes the flags. |
| **ev_mvp_cofounder_offer_iter** | data/events/reactive/ev_mvp_cofounder_offer_iter.json | Byte-identical to `_dev` (differs only in `build_phase iteration`). Same unbuilt-cofounder problem **and** a duplicate. |
| *(soft)* **ev_ps_referral_b2b** | data/events/reactive/ev_ps_referral_b2b.json | "feature sözü ver" writes `feature_debt` (unread) — implies a roadmap-promise/debt tracker not built. Keep or gut the promise mechanic; the rest of the event stands. |
| *(debug, NOT-LOADED)* ev_debug_003 ch.2 | ev_debug_003_cash_warning.json:26 | Bridge-round `[NOT IMPLEMENTED]` / "VC sistemi henüz yok". File already excluded from play. |

*(Deletions are directions only — Erdem approves separately.)*

---

## 4. Raw codes embedded in prose / labels (Class 4-in-copy)

Internal codes / UI identifiers surfaced directly in player-facing strings (distinct from ordinary English words, which are Class 6):

| Fragment | where | file:line |
|---|---|---|
| `MRR tutuyor, marka ayakta` (raw stat `MRR` spoken) | Series A gate, Frank body | phase_gate_system.gd:52 |
| `Reputation 10+ gerekli` (raw stat name) | locked-choice reason (NOT-LOADED) | ev_debug_002_press_inquiry.json:40 |
| `TopBar'daki sayaç…` (internal UI node) | shutter warning body | endings_system.gd:281 |
| `Sales sekmesinde…` (internal tab code) | Frank body + advisory | ev_ps_frank_intro_b2b.json:9 |
| `Product sekmesindeki…` (internal tab code) | body + advisory | ev_ps_b2c_paid_tier.json:9,23 |
| `[DEBUG content]` / `[NOT IMPLEMENTED]` / `[DEBUG]` | body/label/subtitle (NOT-LOADED) | ev_debug_001/002/003 |

**No event writes a numeric stat delta as a literal code into prose** (no "bug +2", no "KRL" string). All numeric deltas live in `modifiers` and render as badges. The word `bug` in prose (*"bir bug buldun"*) is a Class-6 language item, not a raw-code-in-prose item.

---

## 5. Mixed TR/EN inventory (Class 6) — exhaustive (rule seed)

Legend: **[INTRUSION]** should be Turkish · **[JARGON]** English tech term, no settled TR form (rule call needed) · **[LOAN]** accepted Turkish loanword · **[PROPER]** brand/proper noun (acceptable).

- **ev_debug_001** (NOT-LOADED): `sprint` [JARGON] · `Deadline` (label) [JARGON] · `Debug Engineer A` [INTRUSION] · `[DEBUG content]`, subtitle `[DEBUG]` [marker].
- **ev_debug_002** (NOT-LOADED): `e-mail` [INTRUSION] · `AI startup` [JARGON] · `Reputation` (reason) [INTRUSION/stat] · `TechCrunch` [PROPER] · `[DEBUG content]` [marker].
- **ev_debug_003** (NOT-LOADED): `runway` (title+body) [JARGON] · `Tool` (label) [INTRUSION] · `[NOT IMPLEMENTED]` [marker] · `VC` (reason) [LOAN] · `[DEBUG content]` [marker].
- **ev_mvp_dev_001**: `API` [JARGON], `JSON` [JARGON], `UI` [JARGON], **`shape` [INTRUSION]**, **`hack` [INTRUSION]** (body); **`TODO` [INTRUSION]** (label).
- **ev_mvp_dev_002**: `Stack overflow` [PROPER], `tab` [INTRUSION] (subtitle); `build` [JARGON] (body + label).
- **ev_mvp_dev_003**: `feedback` [JARGON], `deadline` [JARGON], `laptop` [LOAN], `runway` [JARGON] (body).
- **ev_mvp_iter_001**: `feature`/`Feature'ı` [JARGON] (title+body); `tab` [INTRUSION] (body).
- **ev_mvp_iter_002** (heaviest): `feed` [JARGON], `thread` [INTRUSION], `batch` [INTRUSION], `post` [INTRUSION], `demo` [LOAN], `comment` [INTRUSION] (body); `Y Combinator W26` [PROPER].
- **ev_mvp_iter_003**: `demo` [LOAN] (body); `WhatsApp` [PROPER] (subtitle).
- **ev_mvp_bugfix_001**: `bug` [JARGON] (title+body); `Edge case` [INTRUSION]; `launch`/`Launch'u` [JARGON].
- **ev_mvp_bugfix_002**: `tab'ı` [INTRUSION] (subtitle); `runway`, `bug` [JARGON] (body); flag key `launch_pressure_kabul` mixes EN/TR.
- **ev_mvp_bugfix_003**: `Demo` [LOAN] (subtitle); `font` [LOAN/JARGON] (body).
- **ev_mvp_cofounder_offer_dev / _iter**: **`front-end` [INTRUSION]**, **`data` [INTRUSION]** (body); `Trendyol` [PROPER].
- **ev_ps_bug_complaint**: **`Refund` [INTRUSION]**, **`Hot-fix` [INTRUSION]** (choice labels).
- **ev_ps_first_revenue**: `Stripe` [PROPER] only.
- **ev_ps_frank_intro_b2b**: **`Sales` [INTRUSION]** (TR "Satış" exists) — Frank body + advisory; `pitch` [JARGON] (advisory).
- **ev_ps_b2c_paid_tier**: **`Product` [INTRUSION]** (TR "Ürün" exists) — body + advisory.
- **ev_ps_expansion_b2b**: title **`Seat` [INTRUSION]** vs body's Turkish `Koltuk` — same concept, two languages.
- **ev_ps_b2c_producthunt**: `Product Hunt` [PROPER]; `Slack` [PROPER], `DM` [INTRUSION]; `launch`/`Launch` [JARGON].
- **ev_ps_power_user_b2c**: `Momentum` [LOAN]; `X / Twitter` [PROPER].
- **ev_ps_referral_b2b**: `roadmap` [JARGON] ×3; `feature` [JARGON].
- **ev_mvp_ship_moment** (product_system.gd:853,862): `GitHub` [PROPER], **`repo` [INTRUSION]**, **`public` [INTRUSION]**, **`landing page` [INTRUSION]**, `Demo` [LOAN]; **`Ship` [INTRUSION]** (label).
- **ev_mvp_version_ship_moment** (product_system.gd:828): `push` [JARGON/INTRUSION], `feature` [JARGON], `bug` [JARGON].
- **ev_phase_gate_traction** (phase_gate_system.gd:36,38): `Traction` [phase name], `churn` [JARGON].
- **ev_phase_gate_series_a** (phase_gate_system.gd:50,52): **`MRR` [INTRUSION/stat]**, `Runway`/`runway` [JARGON] ×2, `pitch` [JARGON]; `Series A` [established].
- **ev_shutter_warning** (endings_system.gd:281): **`TopBar` [INTRUSION/UI]**.
- **ev_pivot_offer** (endings_system.gd:306): **`Day` [INTRUSION]**; `VC` [LOAN]; `Pivot` (label) [LOAN/JARGON].
- **ev_acquisition_offer** (endings_system.gd:339): `Mail` [LOAN].

**Rule seed:** the **[INTRUSION]** items are the immediate rule-drivers (they have clean Turkish equivalents). The **[JARGON]** set (bug, launch, feature, runway, churn, build, deadline, feedback, sprint, roadmap, pitch, push, MRR) needs a designer ruling: which are accepted Turkish tech usage vs to-be-translated. The **[LOAN]/[PROPER]** items are likely fine.

---

## 6. Ranked top defects (by player-facing damage)

1. **Cofounder events = fully fake choice + unbuilt-system fiction** → delete now (both), restore with a real cofounder/equity system later. (C1 + C2)
2. **Raw-code / mixed badge vocabulary** in `_describe_modifier` (Krl/İno/Kul + Cash/MRR/Brand/Rep/Bug) — one central fix normalizes every event's effect display to readable TR. (C4)
3. **Language-integrity intrusions** across event copy (shape, hack, Refund, Hot-fix, Seat/Koltuk, Sales/Product, Ship'le, Day, repo/public/landing page) — seed the single-language-TR rule; exhaustive list in §5. (C6)
4. **`ev_mvp_dev_001` pre-judging + incoherent metaphor** ("Mantıklı/Pratik yol"; "uçurum") — the worked example for C5 + C7.
5. **Hidden-cost fast options** (dev_001 / bugfix_001 / bugfix_002) read as dominant because the punishing `set_flag` cost carries no badge. (C1 + C4-tooltip)
6. **UI-tab / TopBar references in narrative** (frank_intro, paid_tier, shutter) — break fiction/register. (C7 + C4-in-copy)
7. **Deterministic beats asserting a clock with no `allowed_hours`** (first_revenue 08:03, frank_intro 10:20) can fire at any hour. (C3)
8. **`ev_mvp_bugfix_003` weak trade** ("Yeterince iyi" purely negative, no time saved). (C1)

---
*Read-only audit. No copy rewritten, no modifiers changed, nothing deleted. Deletion candidates and fixes are directions only, pending separate approval.*
