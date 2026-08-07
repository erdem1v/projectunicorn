# Localization Phase 1 — Inventory · Glossary · Schema · Law (2026-08-07)

**Type:** Phase 1 deliverable of the TR+EN localization task (inventory, glossary, schema proposals, law draft, Phase 2 plan). READ-ONLY toward the game tree — this file is the only artifact. **Phase 2 does not start before (a) the director approves this report and (b) the bug-cleanup task is committed.**

**Tree snapshot:** HEAD `cb20a18cdd6bba4e512f119589f4f19b2128b1ad` (main, "debug: Font Duruşması type specimen") + **98 uncommitted entries** (the bug-cleanup / ODA session is live in this checkout — `localization/strings.csv` was modified today at 16:35). All counts and `file:line` anchors in this report are a 2026-08-07 snapshot of the *working tree*, not HEAD; **Phase 2 Step 0 re-verifies every one of them against the committed tree.** Baseline deltas vs. the 2026-08-06 audit already observed: CSV 237→**241** keys, `get_display_date()` already deleted (S3-2 shrinks to a stale comment), S3-20's pill moved from `event_modal.gd:214` to `:245-246`.

**Coordination:** Phase 1 ran in parallel with the cleanup session under single-writer discipline — zero game-file writes, zero git writes. The one runtime experiment (§1) executed a throwaway script from the session scratchpad against the project in read-only fashion; the dirty-entry count was 98 before and 98 after, with no new paths.

---

## 0. Executive summary

1. **The load-bearing architecture question is settled by experiment, not reading** (§1): in project context, a Control whose `text` is a raw CSV key resolves at first paint **and re-resolves live on `TranslationServer.set_locale()` with zero listeners**, through nested containers, under the default `auto_translate_mode`. Two consecutive runs, all six assertions green. Consequence: `.tscn` literals become scene-baked keys (deviation from the brief's script-side assumption, flagged in §4.7), and the `language_changed` fix list shrinks to composed-text surfaces only.
2. **The real sweep size** (§2): 1,434 raw TR-literal lines in 91 of 112 scripts → **~1,130 player-visible** after noise; **~135** live baked scene literals in 16 of 33 scenes; **16 live event JSONs** (3 debug fixtures exempt) carrying ~85 live text values; plus the non-string surfaces (dates, money, percent) and two stored-state poisons.
3. **The glossary** (§3) rules ~75 terms, seeded from the 241 shipped pairs; 3 entries carry `[REVISES SHIPPED]` flags, 4 carry `[DIRECTOR]` decision flags.
4. **The law** (§5) is drafted as a sibling paragraph of LANGUAGE INTEGRITY LAW and ships with its own auditor (`loc_residue.gd`) so "residue-free" is a command, not a claim.
5. **Phase 2** (§6) is ten smoke-green commits: debris+law, infrastructure, glossary keys, then seven module batches ending in endings+residue.

---

## 1. The probe — auto-translate lever, EXECUTED

**Question under gate:** does scene text set to a raw translation key (a) resolve at first paint and (b) re-resolve on locale switch with **zero** listeners? The entire `.tscn` strategy and most of the `language_changed` coverage design hang on this.

**Method.** A throwaway `SceneTree` script (full text: Annex A) run via `godot --headless -s`, from the session scratchpad — never inside the repo. It registers a two-locale `Translation` pair through `TranslationServer.add_translation` (the loader's exact mechanism), mounts a `Label` with `text = "LOC_PROBE_KEY"` **two containers deep** (VBox→HBox, as scene keys would really sit), plus three control labels: literal TR twin, literal EN twin (auto-translate disabled), and a label whose text was **pre-resolved** via `translate()`. Because a `Label`'s minimum width is computed from the *shaped displayed* string, width equality against the twins is the observable for what is actually rendered — no windowed screenshot needed.

**Runs.** Binary: `Godot_v4.6.2-stable_win64_console.exe` (the smoke-suite binary).

Run A — standalone (`--headless -s <script>`), no project:

```
PROBE godot=4.6.2-stable (official) autoload_Localization=false locale_at_start=tr
PROBE root.auto_translate_mode=1 (0=INHERIT 1=ALWAYS 2=DISABLED)
PROBE root_node_auto_translate setting=true
PROBE frame2 (locale=tr): probe_w=132.0 always_w=132.0 twin_tr_w=233.0 twin_en_w=33.0 resolved_w=233.0 probe.text='LOC_PROBE_KEY'
PROBE frame4 (locale=en): probe_w=132.0 always_w=132.0 resolved_w=233.0 probe.text='LOC_PROBE_KEY'
PROBE RESULT: inherit=FAIL always=FAIL
```

Run B — in project context (`--headless --path <project> -s <script>`), second of two identical passes:

```
PROBE godot=4.6.2-stable (official) autoload_Localization=true locale_at_start=tr_TR
PROBE root.auto_translate_mode=1 (0=INHERIT 1=ALWAYS 2=DISABLED)
PROBE root_node_auto_translate setting=true
PROBE real-key under tr: ONB_LOCKED_CHIP = 'ONB_LOCKED_CHIP'
PROBE real-key under tr (post-ready): ONB_LOCKED_CHIP = 'KİLİTLİ'
PROBE frame2 (locale=tr): probe_w=187.0 always_w=187.0 twin_tr_w=187.0 twin_en_w=15.0 resolved_w=187.0 probe.text='LOC_PROBE_KEY'
PROBE real-key under en: ONB_LOCKED_CHIP = 'LOCKED'
PROBE frame4 (locale=en): probe_w=15.0 always_w=15.0 resolved_w=187.0 probe.text='LOC_PROBE_KEY'
PROBE A(inherit first-paint TR)=true  B(inherit live-flip EN)=true  A2(ALWAYS first-paint TR)=true  B2(ALWAYS live-flip EN)=true  C(text stays raw)=true  D(pre-resolved does NOT flip)=true
PROBE RESULT: inherit=PASS always=PASS
```

**Reading the evidence.**
- **A/B (the gate):** under locale `tr` the key-label's width equals the TR twin (187.0 = 187.0 — it *rendered the Turkish*); after `set_locale("en")` it equals the EN twin (15.0), with no listener, no repaint call, through two nested containers, in default INHERIT mode. **The lever holds.**
- **C:** `probe.text` stayed `'LOC_PROBE_KEY'` both frames — translation is display-side; the property remains the raw key (this is what makes scene keys greppable forever).
- **D (the control case):** the pre-resolved label stayed at TR width under EN — text resolved via `tr()`/`translate()` at build time does **not** flip. This is the exact behavior the composed-string policy (§4.3) rests on.
- **The real pipeline, same process:** the project's own `Localization` autoload registered the live CSV — `ONB_LOCKED_CHIP` → `'KİLİTLİ'` under tr, `'LOCKED'` under en. (The first tr-side print shows the key because `_initialize` runs before autoload `_ready` in `-s` script mode; the post-ready re-query at frame 2 closes that timing hole. Boot-order in the *real game* is not affected: autoloads complete `_ready` before `Main.tscn` instantiates — `project.godot` autoload order + engine boot contract — which the shipped game already demonstrates by rendering keyed onboarding text correctly at first frame.)
- **Anomaly, reported verbatim:** in the projectless Run A, Controls did not auto-translate even under explicit `AUTO_TRANSLATE_MODE_ALWAYS`, while server-side `translate()` worked (resolved_w=233). Root cause not chased — the decision environment is the project, where the mechanism passes end-to-end and repeatably. Recorded so nobody re-tests localization behavior in projectless `-s` mode and draws the wrong conclusion.

**Consequence — surviving branch:** scene-keyed `.tscn` text + auto-translate (§4.7). The fallback branch in the plan (script-side assignment + modal listeners) is not needed.

---

## 2. String inventory

Counting heuristic: lines containing a double-quoted literal with any of `[ğüşıöçĞÜŞİÖÇ]`. Its two blind spots (ASCII-only Turkish; live English) are covered in §2.6 — the totals below are therefore a *floor*, and the residue proof in §4.9 is what makes the sweep's end state checkable.

### 2.1 Scripts — 1,434 raw lines / 1,601 literal occurrences / 91 of 112 files

Per-directory (raw → net of full-line comments):

| Directory | Files hit | Raw | Net | Character |
|---|---:|---:|---:|---|
| `scripts/systems/` | 32 | 891 | **804** | catalogs + engines; 62% of everything; zero `tr()` |
| `scripts/tabs/` | 15 | 237 | **208** | product/hr/finance views |
| `scripts/debug/` | 2 | 86 | **72** | smoke + font specimen — **not shippable UI, excluded** |
| `scripts/modals/` | 7 | 76 | **67** | |
| `scripts/ui/` | 12 | 47 | **22** | `ui/oda/` already keyed |
| `scripts/autoload/` | 10 | 42 | **22** | |
| `scripts/main/` | 2 | 31 | **28** | mostly debug-shot fixtures |
| `scripts/theme/` | 3 | 18 | **6** | |
| `scripts/data_models/` | 3 | 4 | **2** | |
| `scripts/onboarding/` | 2 | 2 | **0** | fully converted |
| **Total** | **91** | **1,434** | **1,231** | |

Top files (net): `product_catalog.gd` 136 · `endings_copy.gd` 117 · `hr_constants.gd` 76 · `vc_pitch_system.gd` 68 · `company_catalog.gd` 68 · `b2b_constants.gd` 56 · `news_feed_system.gd` 56 · `creation_flow.gd` 42 · `pitch_system.gd` 33 · `b2b_event_factory.gd` 31 · `event_modal.gd` 29 · `detail_view.gd` 25 · `hunt_tab.gd` 25 · `hr_tab.gd` 23 · `endings_system.gd` 22 · `finance_ozet_view.gd` 20 · `pricing_panel.gd` 18 · `b2b_pitch_meeting.gd` 18 · `meeting_scene.gd` 18 · `hr_atlas_modal.gd` 15 · `term_sheet_table_system.gd` 15 · `hr_actions.gd` 15. (Full per-file counts reproduce from the §4.9 grep on demand — a 91-row table earns nothing here.)

**Noise annex — excluded with justification (≈21-22% of raw):** 203 full-line comments quoting UI strings (architectural headers — e.g. `b2b_sales_system.gd` is 10/10 comments); 17 log/print/push_warning lines; 72 non-comment lines in `scripts/debug/` (smoke fixtures + font specimen are developer surfaces; the specimen's pangrams are *deliberately* Turkish); ~18 debug-shot fixture names in `main.gd` ("Burcu Çetin", "Kuzey İnşaat"…). **Player-visible working set ≈ 1,120–1,140 lines.**

**Converted-surface baseline:** `tr()` lives in 14 files / 211 call sites (oda_view 51, sales_tab 45, onboarding steps 35, ending_scene 14…); `TranslationServer.translate()` in 4 static homes. All 14 autoloads and all 33 `scripts/systems/` files: zero.

### 2.2 Scenes — 191 string properties / 16 of 33 `.tscn`

160 non-empty; ~25-30 are glyph/numeric placeholders (`"0"`, `"—"`, `"✕"`, `"1x"`); **≈135 real literals**. By scene: RightPanel 40 (dead — §2.5), TopBar 27, LeftTabs 26, BuildHUDPanel 19, MeetingScene 10, MonthSummaryModal 9, FrankPopup 9, SalesTab 9, ThemeProbe 9 (debug), SettingsModal 7, HuntTab 6, DialogueChoiceCard 5, ConvictionTrack 5, MentorIntroModal 5 (incl. the 3-paragraph baked mentor monologue at `MentorIntroModal.tscn:101-105` — the largest single scene literal), ConfirmModal 4, DialoguePortraitCard 1. Zero-string scenes are code-built or already keyed (OdaView, EventModal, EndingScene, onboarding, all tab roots).

Design-time placeholders overwritten at runtime (e.g. TopBar `"$50,000"`, `"KEPENK: 7 GÜN"`) are keyed only where the runtime writer is also being keyed — the scene value then becomes the key too, or empties.

### 2.3 Event JSONs — 19 files, 16 live, 3 exempt

All in `data/events/reactive/`; schema ground truth `scripts/data_models/event.gd`. Text-bearing fields: `title`, `subtitle`, `body_text`, `choices[].label` (40 total), `choices[].unlock_reason_text` (all 40 empty today — gated choices fall back to the literal `"KİLİTLİ"` at `event_modal.gd:384`), `choices[].description` (2), `mentor_line` (1), `modifiers[].text` for `mentor_advisory` (3). **105 non-empty values total; the 3 `ev_debug_*` fixtures (~20 values) are exempt from `_en` authoring by director ruling → ~85 live values, ~6 KB of body prose.** Zero `*_en` fields exist anywhere under `data/`. `speaker_*` fields are populated only by code factories (`b2b_event_factory.gd`, `hr_event_factory.gd`), never from JSON — factory strings are Tier A code, not JSON content.

### 2.4 Tier classification

- **Tier A (UI/system, ≈900-950 lines + all 135 scene literals):** every label, chip, button, badge, telegraph, tooltip; composed news templates (`news_feed_system.gd`: 48 SEKTOR_POOL sentences + 7 rival templates + 4 outlet names); formatter outputs; the catalogs' *display-name/label* halves (`hr_constants` role/dept/band/badge tables, `b2b_constants` sector fiction labels, `product_catalog` feature names, `company_catalog` company descriptions — names themselves are proper nouns).
- **Tier B (narrative, `[DRAFT-EN]` register):** 16 live event JSONs (~85 values); `endings_copy.gd` — ~156 prose strings, ~6.8 KB, 8 ending branches, grammar-assembled (the hardest file in the repo, §4.6); `endings_system.gd` trigger prose (22 lines); factory-event fiction bodies (b2b complaint/expansion voices, HR events); the MentorIntroModal monologue; `main.gd:1680` mentor text.

### 2.5 Dead surfaces — excluded

`right_panel.gd` + `RightPanel.tscn`: **retired** (ODA rework 2026-08-06 — `event_bus.gd:106` "RightPanel retired", `main.gd:693`; oda_view and finance_ozet_view carry its live descendants). Its 40 scene strings + composed English (`"%d of %d"`, `"UPCOMING — DAY %d TO %d"`, `"MENTOR"`, `"CAP TABLE"`…) are **not swept**. If the cleanup task deletes the files, the point is moot; if not, they stay dead and unkeyed. Also excluded: `ThemeProbe.tscn`, `FontSpecimen`, smoke fixtures (debug surfaces).

### 2.6 Grep blind-spot annex

**(a) ASCII-only Turkish** — words whose Turkish identity lives in dotless-ı/İ collapse to plain ASCII under uppercasing and are invisible to the charclass grep. Confirmed live examples: `"SABIR"` (`term_sheet_table_scene.gd:123`), `"ILIK"`, `"KAZANILDI"` (`ConvictionTrack.tscn:40,47`), `"YATIRIMCILAR"`, `"BEKLEYEN"` (`HuntTab.tscn:66,111`), `"BULUNAN"`, `"KALAN"` (`BuildHUDPanel.tscn:185,214`), `"OCAK 2026"`, `"DEVAM ET"` (`MonthSummaryModal.tscn:62,173`), `"MASADAN KALK"` (`term_sheet_table_scene.gd:257`), `"PROVA EDİLDİ"`-siblings, plus lowercase prose words (masada, oyala, kapat…).
**(b) Live English** — TopBar captions `CASH/MRR/BURN/NET/RUNWAY/BRAND/REPUTATION` (`TopBar.tscn:64-201`, never touched by script — verified `top_bar.gd` writes only `*_value_label`); the 8 rail labels in **two** sources (`LeftTabs.tscn:66-500` + `ui_tokens.gd:343-355` — S2-34); phase names `Bootstrap/Traction/Series A` (`top_bar.gd:15`, deliberate — §3 rules on them); `"Callback"` badge (`hunt_tab.gd:265`); rival status enums rendered raw (`rival_registry.gd:99-102` `DOMINANT/SCALING/QUIET`); `"Founder"` default name ×4 live (S2-42); `"FK"` avatar initials ×4; mixed-language strings violating the INTEGRITY law as written: `"Build'i iptal et"` (`creation_flow.gd:664` + `BuildHUDPanel.tscn:74`), `"Sales sekmesine git →"` (`detail_view.gd:260`), `"CANLI V%d"` (`detail_view.gd:146,379`).
**(c) Ruled loanwords** — `MRR` (46 hits/18 files), pitch, demo, churn, runway, B2B/B2C, API, Series A: identical in both locales per the INTEGRITY whitelist; they inflate greps but are not debt.

The residue proof that closes all three: §4.9.

### 2.7 Non-string surfaces

- **Dates** — TR-only tables in ~8 homes: `game_state.gd:14-20` (canonical UPPER + Title twins, with the documented İ-mangling rationale), `top_bar.gd:179-190` (`DOW_ABBR_TR`, `"Çar, 9 Eyl 2026"`), `product_ui_shared.gd:15-29`, `endings_copy.gd:36,447-455` (third private twin; `"14 KASIM 2027 · SAYI 214"`), `hr_constants.gd:728`, `month_summary_system.gd:62`, `finance_ozet_view.gd:434-440`, `oda_view.gd:1433,1439`. The English date path is already gone (`get_display_date()` deleted; stale comment residue at `game_state.gd:336`).
- **Money** — `ui_tokens.gd` `format_money` :411 / `format_money_chip` :433 / `format_money_exact` :457 (**hardcoded US comma grouping**); deliberate divergents: `product_ui_shared.money_tr` :63 (dot-grouped `"$1.800"`), `event_modal._fmt_money_delta`, `endings_copy._valuation_tr` :458 (spelled-out Turkish, no `$`).
- **Percent** — `rival_registry.format_share` :165-170 (TR `%`-prefix + comma decimal, pinned by `endgame_smoke.gd:5084-5088`); the `"%%%d"` prefix idiom at 20+ sites (event_modal, term_sheet, hr_*, finance_ozet, vc_pitch, creation_flow).
- **Stored-state poison** — localized text written into *state*, which no locale switch can heal: `sales_system.gd:220` bakes `_product_name() + " kullanıcıları"` into `Customer.company_name` (a persisted data field); `game_state.gd:550` persists `display_name = "Founder"`. Principle for §4/§5: **store ids, render labels at display time.**
- **The one locale-aware precedent** — `ui_tokens.net_runway_parts` :491-511 (TranslationServer-driven runway text): the pattern the formatter seam generalizes.

---

## 3. Terminology glossary — the taste gate

**Ground rules.** TR canonical; EN is the game written natively in English — dry, lower-temperature than marketing copy, sales-floor and newsroom registers where the fiction lives there. The 241 shipped pairs are the default canon; a proposed change to one carries **[REVISES SHIPPED]**. Open taste decisions carry **[DIRECTOR]**. The INTEGRITY-law loanword set (`pitch, startup, demo, momentum, MRR, runway, churn` + `laptop, mail, VC` + proper nouns) is identical in both locales and never re-translated. ALL-CAPS surfaces stay ALL-CAPS in EN; chip strings are length-checked in the §6 visual pass, and the fix for a long chip is a shorter word, not a wider chip.

**Status legend:** SHIPPED = in strings.csv today, kept as-is · NEW = proposed here · REV = [REVISES SHIPPED] · DIR = [DIRECTOR] decision requested.

### 3.1 Lock & availability grammar (binding on every surface)

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| KİLİTLİ | LOCKED | SHIPPED | The one word for every gated thing — event choices (`event_modal.gd:384` fallback), portfolio slots, HR roles, onboarding. Never "UNAVAILABLE", never "DISABLED". |
| ÇOK YAKINDA | COMING SOON | SHIPPED | Standalone telegraph. |
| · YAKINDA (in compound chips) | · SOON | SHIPPED | `ZOR MOD · YAKINDA` → `HARD MODE · SOON`; the short form only ever follows a `·`. |
| TAM SÜRÜMDE | IN THE FULL GAME | **REV** | Shipped `IN FULL RELEASE` reads translated, not native — storefront EN says "full game" (`wishlist the full game`). Two keys affected (`ONB_LOCKED_FULL`, `ENDING_BADGE_FULL`). Director may keep shipped. |
| İNŞA EDİLİYOR · SEÇİM KİLİTLİ | BUILD IN PROGRESS · CHOICES LOCKED | NEW | `creation_flow.gd:410`; "UNDER CONSTRUCTION" is street-sign register, not software. |
| CANLI | LIVE | SHIPPED | Monitor chip; also `CANLI V%d` → `LIVE V%d` (fixes the mixed literal at `detail_view.gd:146`). |
| YENİ | NEW | SHIPPED | Customer chip + HR badge share it. |

### 3.2 Company arc, finance state

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| Bootstrap · Traction · Series A | *identical* | **DIR** | Deliberate English canon in TR (`top_bar.gd:15,209`); startup-Turkish genuinely says these. Ruling requested to close it forever: proper nouns of the arc, identical both locales. TR alternatives exist (Çekiş for Traction) but would break the fiction's register. |
| Faz kapısı | Phase gate | SHIPPED | ODA papers. |
| KEPENK: {n} GÜN | SHUTTER: {n} DAYS | NEW | TopBar doom counter. Keeps the shop-front image — the shutter coming down — which is the fiction's own metaphor; "CLOSURE"/"COUNTDOWN" would flatten it. |
| Artıda | Default Alive | SHIPPED | The exemplary pair — EN native genre term, not a translation of "in the plus". |
| Brüt Runway | Gross Burn Runway | SHIPPED | Canon (ENDGAME §Package 5). |
| KASA | CASH | NEW | Reverse-direction: TopBar caption is English-only today; TR side gets KASA. |
| BURN | GİDER *(or keep BURN)* | **DIR** | TopBar caption. "burn" is real founder-Turkish but **not** on the INTEGRITY whitelist. Either add `burn` to the whitelist (one-word law amendment) or caption it GİDER. Recommendation: whitelist it — the finance row (KASA · MRR · BURN · NET · RUNWAY) is jargon-register as a set. |
| NET | NET | NEW | Identical. |
| MARKA / İTİBAR | BRAND / REPUTATION | NEW | TopBar meters; TR side new. |
| TUR AÇ | OPEN ROUND | NEW | Finance CTA; `TUR AÇ · SERIES A` → `OPEN ROUND · SERIES A`. |
| Toplanan | Raised | NEW | `finance_ozet_view.gd:571`; EN one word, ledger register. |
| Ay kapanışı | Month close | SHIPPED | Board dates. |
| Pazar payı | Market share | SHIPPED | Board. |
| Değerleme | Valuation | NEW | VC flow, term sheet, endings. |
| Hisse | Equity | NEW | Term sheet, cap chart. |
| Koltuk | Seat(s) | SHIPPED | Both senses — license seats (`SALES_SEATS`) and board seats (endings) — share the word in both languages; no split needed. |
| ARTIDA (runway state, caps) | DEFAULT ALIVE | SHIPPED | Caps form follows the pair. |

### 3.3 Build & product

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| TASARIM / GELİŞTİRME / TEST / BETA | DESIGN / DEVELOPMENT / TEST / BETA | NEW | Build phases + HR sections share the words (`SECTION_LABELS`, BuildHUD, oda monitor); one ruling covers both. |
| GELİŞTİR → | BUILD → | NEW | The INTEGRITY law maps build↔geliştirme; the EN verb of the genre is "build", not "develop". |
| Yayınla → | Ship → | NEW | BuildHUD release button. "Publish" is app-store register; founders ship. |
| Sürüm / İlk sürüm | Release / First release | SHIPPED | ODA frames. |
| Özellik | Feature | NEW | Everywhere product; per INTEGRITY law feature→özellik in TR. |
| Hata / hata riski | Bug / bug risk | SHIPPED | `ODA_MON_CAP_BUGS` pair; TR never says "bug" on screen. |
| Kararlılık *(monitor)* | Stability | SHIPPED | `ODA_MON_CAP_STAB`. **Distinct sense from pitch KARARLILIK below — never share a key.** |
| Teknik borç | Tech debt | NEW | Event fiction, build telegraphs. |
| Geliştirme bekleniyor | Awaiting development | SHIPPED | Monitor idle. |

### 3.4 People — axes, roles, departments, bands, HR states

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| Uzmanlık / Hız / Uyum | Expertise / Pace / Rapport | NEW | The three axes (`AXIS_LABELS`, ids already `expertise/pace/rapport` — EN follows the ids). Caps chips: `UZMANLIK 6` → `EXPERTISE 6`. "Pace" over "Speed" (a person's working tempo, not velocity); "Rapport" over "Harmony/Fit" (it is read for coordination *and* customer stewardship). |
| Kurucu | Founder | SHIPPED | Also the S2-42 fix: the persisted default name keys to this pair. |
| Ürün Yöneticisi | Product Manager | NEW | Atlas, cards, SORUMLU dropdown. |
| Tasarımcı | Designer | NEW | |
| Yazılımcı | Developer | NEW | |
| Test Uzmanı | Tester | NEW | Role id `tester`; "QA Engineer" is org-chart register, this game's team is seven people. |
| Satış Uzmanı | Sales Rep | NEW | Genre register; matches `sales_rep` id. |
| Müşteri Temsilcisi | Account Manager | SHIPPED | `SALES_STEWARD` already rules it. |
| Operating Partner | *identical* | SHIPPED | **BYTE-EXACT both locales** — `hr_constants.gd:104-107` marks it load-bearing on live surfaces. |
| Ürün Geliştirme / Satış / Müşteri *(departments)* | Product Development / Sales / Customer Success | NEW | "Customer" alone is thin as an EN department name; CS is the term the systems already use (`HR_CS_LOAD`). Length-check the chip. |
| ekonomik / dengeli / üst segment *(salary bands)* | budget / balanced / premium | NEW | Market-register nouns; "economic/economical" is translation-smell, "top segment" is not English. Lowercase like TR. |
| Kaçma riski / Tükeniyor / Aşırı yüklü / Yeni *(badges)* | Flight risk / Burning out / Overloaded / New | NEW | `BADGE_LABELS`; EN HR-floor register. |
| İzinde / Yarın başlıyor | On leave / Starts tomorrow | NEW | Card states. |
| EK MESAİ · {n}. GÜN | OVERTIME · DAY {n} | SHIPPED | `ODA_WINDOW_OVERTIME`; HR tab's duplicate hardcode consumes the same key in Phase 2. |
| 3 gün / 1 hafta / 2 hafta *(overtime blocks)* | 3 days / 1 week / 2 weeks | NEW | `OVERTIME_BLOCK_LABELS`. |
| ARAYIŞ BAŞLAT / ARAYIŞI İPTAL ET | START SEARCH / CANCEL SEARCH | NEW | One inflection family, one key pair — today it exists in three spellings across `hr_tab.gd` and the atlas modal. |
| Aday dosyası | Candidate file | SHIPPED | `ODA_PAPER_ATLAS_TITLE`. |
| İşe alım / Kıdem tazminatı | Hiring / Severance | NEW | Cost labels. |
| ZAMMI UYGULA | APPLY RAISE | NEW | `hr_tab.gd:457`. |
| İK | HR | NEW | Ticker attribution + (post S3-30) the rail: TR says İK, EN says HR. |

### 3.5 Sales, B2B, pitch, VC

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| Müşteri | Customer | SHIPPED | |
| aday | lead | SHIPPED | Counts and flow (`%d aday` → `%d leads`). |
| prospect | prospect | SHIPPED | The entity on the board (`PROSPECT'LER` → `PROSPECTS`). Ruling: **leads arrive, prospects sit on the board** — the shipped split is correct sales-floor English; codified so it stops looking like drift. |
| Memnuniyet | Satisfaction | SHIPPED | |
| Churn'e ~{n} gün | ~{n} days to churn | SHIPPED | |
| Söz / Söz teslimi | Promise / Promise due | SHIPPED | Promise system everywhere. |
| VC görüşmesi | VC meeting | SHIPPED | |
| Teklif / TEKLİF: {n} GÜN | Offer / OFFER: {n} DAYS | SHIPPED | Papers + TopBar counter. |
| SABIR | PATIENCE | NEW | Term-sheet lever button — the negotiation virtue, single dry noun. |
| MASADAN KALK | WALK AWAY | NEW | Term sheet + hunt tab (two casings today, one key tomorrow). Not "LEAVE THE TABLE" — the EN idiom is shorter and colder. |
| SOĞUK / ILIK / KAZANILDI *(conviction zones)* | COLD / WARM / WON | NEW | Pipeline-temperature register; WON closes the arc the way sales boards say it. |
| KARARLILIK *(pitch radar)* | RESOLVE | NEW | The founder's composure stat in meetings; "DETERMINATION" is too long for the radar, "STABILITY" is the other sense (§3.3). |
| İlgilen | Check in | **REV** | Shipped `Attend` reads as attending an event; account-management EN is "check in (on the account)". One key (`SALES_ACTION_RETAIN`). Director may keep shipped. |
| Değerlendir | Evaluate | SHIPPED | |
| Görüşmeye git | Go to meeting | SHIPPED | |
| NÖTR *(relationship pill)* | NEUTRAL | NEW | The S3-20 fix's label table starts here; today the raw enum renders. Full state set gets TR labels when the table lands. |

### 3.6 World, news, endings chrome

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| Ekonomi Postası · TeknoGündem · Girişim Bülteni · Sektör Telgrafı | *identical* | NEW | Outlet names are proper nouns — mastheads do not translate (The Economist stays The Economist). The ending gazette's masthead therefore stays `Ekonomi Postası` in EN; its *subheads and body* localize. |
| SAYI {n} | No. {n} | NEW | Gazette dateline `"14 KASIM 2027 · SAYI 214"` → `"14 NOVEMBER 2027 · No. 214"`; "ISSUE" is magazine register, "No." is broadsheet. |
| Rakip | Rival | NEW | Board, news. |
| Sektör | Sector | NEW | |
| ZOR MOD | HARD MODE | SHIPPED | |
| GAZETEYİ PAYLAŞ | SHARE THE PAPER | SHIPPED | |

### 3.7 Chrome & common UI

| TR | EN | St | Rationale / screens |
|---|---|---|---|
| Ürün / İK / Finans / Satış / Operasyon / Ar-Ge / Kişisel / Olaylar *(rail)* | Product / HR / Finance / Sales / Ops / R&D / Personal / Events | NEW | Reverse-direction: rail is English-only today (S2-34). TR proposals here close S3-30 (İK, not HR, in Turkish). One `TAB_*` key set, both sources retired to it. |
| Ayarlar | Settings | NEW | The rail's one Turkish label today. |
| Tamam | OK | NEW | `creation_flow.gd:297`; the game's only confirm-word — keyed once. |
| İptal / Vazgeç | Cancel | NEW | One EN word for both TR spellings; TR itself unifies on **Vazgeç** for backing out of a flow, **İptal** for killing a running thing (`Build'i iptal et` → `Cancel the build`). |
| DEVAM ET | CONTINUE | NEW | Month summary. |
| Geri / İleri | Back / Next | SHIPPED | |
| ODAYA DÖN | BACK TO ROOM | SHIPPED | |
| Kilometre Taşları | Milestones | SHIPPED | |
| SIRADA NE VAR? | WHAT'S NEXT? | SHIPPED | |
| KURUCU *(tag)* | FOUNDER | SHIPPED | |
| Self-Made | *identical* | **DIR** | S3-21. Shipped treats it as a proper-noun-styled archetype label (identical both locales), which is defensible — its quote card is fully Turkish. TR candidate if the director wants one: **Sıfırdan**. Not invented into the tree without a ruling. |
| Frank'ten not | A note from Frank | SHIPPED | |
| FK *(avatar initials)* | FK | NEW | Identical; keyed once instead of four hardcodes. |

**Count: 78 ruled entries** (7+18+9+19+16+6+13 across §3.1-3.7, counting grouped rows once). Everything else in the sweep is sentence-level authoring bound by these terms.

---

## 4. Schema & architecture proposals

### 4.1 Placeholder convention + printf migration
Named `{x}` placeholders consumed via `tr(KEY).format(dict)`, everywhere. Rules: `{n}` only for a single bare count in chip register; two or more placeholders → all semantic names (`{company}`, `{days}`, `{amount}`) — this is what makes EN reordering free (GDScript `%` is strictly positional; no `%1$s` exists). **Values arrive pre-formatted** (`Fmt.*` — §4.5) so a placeholder is always a complete, case-neutral token; any TR sentence that would suffix one is restructured (the three live sites: `vc_pitch_system.gd:788` `%s'in`, `term_sheet_table_system.gd:239` `%s'de`, `hr_overtime_panel.gd:87` `%%%d'e` — flagged `# COPY-RESTRUCTURED` for review). EN plural without agreement: label-colon (`Days left: {n}`), invariant unit (`{n} d`, `customer for {n} mo` — already the CSV's own style), telegraphic plural on chips. Never `(s)`, never conditional strings. `String.format` has no escape syntax → law rule: no literal braces in CSV values (none exist; smoke-guarded). Side benefit: `%` becomes an ordinary character, retiring the `"%%%d"` idiom at 20+ sites.
**Migration:** the 31 existing printf keys flip to named form in **one mechanical commit** (Phase 2 Step 1) with every caller in the same commit (`rg 'tr\(' | rg '%'` finds them; ~35 sites). Doing it first means every subsequent batch authors one convention, not two.

### 4.2 Event JSON bilingual schema
**Additive sibling `*_en` fields** — `title_en`, `subtitle_en`, `body_text_en`, `mentor_line_en`, `choices[].label_en`, `choices[].description_en`, `choices[].unlock_reason_text_en`, `modifiers[].text_en` — not nested `{tr:,en:}` objects: all 19 files stay valid as they are, diffs are pure insertions, and the coming event-rebuild arc discards this schema anyway; a nested migration would be real cost spent on a condemned shape. Loader (`event_manager._build_event_from_dict`, ~:768) copies them verbatim onto `GameEvent`/`EventChoice` (7 new flat `@export` fields, defaulted `""`).
**Resolution at render time**, because the event cache is built once at boot and compared by reference: one static helper on the autoload —
```gdscript
static func pick(tr_text: String, en_text: String) -> String:
    if en_text != "" and TranslationServer.get_locale().begins_with("en"):
        return en_text
    return tr_text   # TR canonical fallback
```
Render sites: `event_modal.gd` title/body/subtitle/mentor row/choice labels/locked reasons/modifier custom text (+ any other `GameEvent.title` consumer found in Step 0's grep).
**Code-factory events** (`b2b_event_factory`, `hr_event_factory`): move to CSV keys + `.format` in their module batches; they write finished text into the TR-side fields and leave `_en` empty — `pick()`'s fallback then returns it unchanged in both locales, giving "already-localized" behavior with **no discriminator field**. Contract documented in `event.gd`'s header. Accepted edge: a factory event enqueued before a switch renders in build-time locale (same staleness class as §4.3's modal policy).

### 4.3 `language_changed` coverage
The probe (§1) reduces the policy to one line: **static label → raw key (scene or code), composed label → key + `.format` + the surface's existing repaint path.** Per surface:
- **Mounted modals — no listeners.** Once their static chrome is raw-keyed it flips free (§1); only the *composed prose* of a modal already open under SettingsModal stays pre-switch until it closes. Stated as the accepted limitation: reachable only by switching language with an event modal stacked underneath; the next modal is correct. `settings_modal` keeps its existing self-re-key (:58-63). Rebuild-in-place for 11 modals would buy exactly that one edge case.
- **left_tabs** — 8 scene-baked `TAB_*` keys; zero code. `UiTokens.TABS` drops its `label` field (kept: id/glyph); the only other label consumer, `center_viewport.gd:100`, derives `tr("TAB_" + id.to_upper())` at page mount. S2-34's two English sources both retire into the CSV. (S3-30 resolves via the glossary: TR=İK.)
- **Router dirty-guard** (~6 lines): `center_viewport` retains `_current_tab_id` and, on `language_changed`, re-runs `_on_tab_changed(_current_tab_id)` if a page is mounted — reusing its only code path; the free-and-rebuild stays untouched (the audit's constraint).
- **oda_tour** — 3-line listener re-painting the current step (its strings are already keyed; `OdaView._refresh_all()` doesn't reach it).
- **finance_ozet_view** — wiring already correct; needs keys only.
- **No boot emission** — locale is set during autoload init, before any UI instantiates; every first paint is already correct (probe + shipped onboarding both demonstrate it). `set_language` stays the sole emitter.

### 4.4 First-boot language selection
**A LanguageGate before onboarding**, not a row inside it: the gate mounts before any `tr()` in the flow runs, so the entire onboarding builds in the chosen locale with zero re-render wiring (a CharacterStep row would force flow-chrome repaint + step re-mount + draft contamination).
- `scenes/onboarding/LanguageGate.tscn` + `language_gate.gd`: dark threshold register (reuse `_apply_dark_register`'s pattern), two large buttons self-labeled in their own tongue — **"Türkçe" / "English", deliberately not keys** (each option must be readable in its own language), `signal chosen(locale)`.
- Mount: `main.gd`, immediately before `_mount_flow()` (:192): `if Localization.is_first_boot(): _mount_language_gate(); return`. New `localization.gd` helper: `is_first_boot()` = Settings has no stored `language` (verified: nothing writes the key until the first switch).
- OS-locale **preselect** (`OS.get_locale_language() == "tr"` → focus TR, else EN); the click is still explicit.
- Persistence free via existing `set_language`. `--skip-onboarding`, every shot/smoke harness, and the debug re-trigger all return before the gate by construction — only a genuine first boot sees it.

### 4.5 Locale-aware formatters — `Fmt`
New all-static `scripts/util/fmt.gd` (`class_name Fmt`); `UiTokens.format_money*` bodies become one-line delegates (≈40 call sites unmoved; the theme file stays theme — its own OWNERSHIP law argues for the eviction). Statics use `TranslationServer.translate` (the project's documented pattern).
- **Month/DOW = CSV keys** (`MONTH_1..12` Title-case, `DOW_0..6` abbreviated): one canonical form, derivations cover the rest — abbrev = `substr(0,3)` ("Eyl"/"Sep", exactly today's TopBar trick), uppercase via locale-branched `Fmt.upper` (TR → the existing İ-safe `UiTokens.tr_upper`, else `to_upper`). Retires all three twin month tables (`game_state.gd:14-20`, `endings_copy.gd:36`) plus the İ-workaround comments.
- **Date order is data:** `DATE_LINE` key = `"{dow}, {day} {mon} {year}"` (tr) / `"{dow}, {mon} {day} {year}"` (en) → "Çar, 9 Eyl 2026" ↔ "Wed, Sep 9 2026".
- **Percent:** `Fmt.percent(v, d)` — TR `%12,5` (prefix, comma) ↔ EN `12.5%` (suffix, dot), pattern from a `PCT_PATTERN` key. `RivalRegistry.format_share` keeps its `<`-floor semantics, delegates rendering (floor form via `SHARE_FLOOR` key `<%0,1` / `<0.1%`).
- **Money:** `Fmt.group/money/money_chip/money_exact` — **full locale flip proposed** (TR `$1.234.567`, `$3,5K`; EN as today; `$` prefix stays both — the fiction is USD). Consequence stated plainly: TopBar cash *changes shipped appearance in TR*. The product tab's dot-grouped `money_tr` already argues the game believes in TR grouping; it merges into `Fmt`. Endings' spelled-out numerals are untouched (§4.6). Fallback if F5 disagrees: one line in `Fmt.group`. **[DIRECTOR — decision at this gate; director leans full flip.]**
- API: `month_name/month_abbr/month_upper/dow_abbr/date_line(d)/upper(s)/number(v,d)/percent(v,d)/group(n)/money(v)/money_chip(v)/money_exact(v)`.
- Migration is per-batch (each date/percent site moves with its module); smoke pins that byte-assert TR forms (`endgame_smoke.gd:5084-5088` format_share; fmt_probe money columns) are replaced by per-locale twin assertions (§4.9).

### 4.6 Endings copy — Tier B, same file, parallel EN branch
Exactly what the file's own header reserves ("a later locale pass adds a parallel branch"): **string pools and leaf helpers fork; assembly logic never does.** `build()` computes `_en := TranslationServer.get_locale().begins_with("en")` once (ending renders once at game end — no live-flip concern). Leaf helpers gain EN twins: `NUM_EN` ("zero".."twelve") beside `NUM_TR`; `_founding_month` → `Fmt.month_name`; `_span_phrase`/`_valuation`/`_investment` get EN spelled forms preserving the file's no-digits-in-prose law. Headline/subhead/quote/ledger pools gain `*_EN` siblings tagged `# DRAFT-EN` — the director's rewrite surface is exactly the tagged constants. Where TR grammar-assembly has no EN mirror, the draft uses a simpler flat frame the same fields can fill; **flat-correct beats clever-wrong** because every line is rewritten in the editorial pass anyway. Verification: `--ending-shot` × EN per ending id + a smoke case asserting `build()` under EN emits no TR-charclass characters.

### 4.7 `.tscn` strategy — scene-baked keys (deviation from brief, probe-backed)
The brief assumed script-side keyed assignment; the executed probe (§1) proves scene `text = "KEY"` is strictly better here: zero code, correct at first paint, free live-flip, and mechanically verifiable (a scene string is either empty, a glyph, or `^[A-Z0-9_]+$` — anything else is residue). Discipline rule for the law: **a label is scene-keyed or code-driven, never both.** Keys are SCREAMING_SNAKE; prose never is — no collision risk with real text.

### 4.8 Debris + harness
- Delete `localization/strings.en.translation`, `strings.tr.translation`, `strings.csv.import`; gitignore `localization/*.translation` (S3-54 — verified inert: no `[internationalization]` section in `project.godot`; the autoload feeds TranslationServer from the CSV itself).
- `--lang=tr|en` override in `localization.gd._ready` (cmdline + `main_args` mirror, non-persisting, override beats Settings): every existing shot flag doubles into a TR/EN matrix (`--tab-shot`, `--modal-shot`, `--onboard-shot`, `--oda-shot`, `--hr-shot`, `--ending-shot`, `--event-shot`, `--sales-shot`, `--pitch-shot` ≈ 50-60 shots full pass). What the EN pass hunts: clipped/overflowing EN — fixed by rewording, not by resizing, per the brief.
- Correct the stale localization sentence in CLAUDE.md's Current Project State block, and the INTEGRITY law's mechanism parenthetical, in the same commit that lands the law.

### 4.9 Residue proof + smoke additions
Shipped as `scripts/debug/loc_residue.gd` — headless, read-only, **exits nonzero on hits**, so the law's "how a claim is proven" clause is a command:
1. TR-charclass: `[çğıöşüÇĞİÖŞÜ]` in `scripts/ scenes/` (excl. `scripts/debug/`), comment-stripped → end state: zero in scenes, comment-only in scripts, justified annex for the rest.
2. ASCII-Turkish wordlist: generated in Step 0 by tokenizing the *current* literal corpus (so it provably covers this codebase's vocabulary — SABIR, ILIK, KAZANILDI, MASADA, OYALA…), case-insensitive whole-word.
3. Scene-key check: every non-empty scene `text`/`tooltip_text`/`placeholder_text` matches `^[A-Z0-9_]+$` or the glyph whitelist.
Smoke additions (4 cases, replacing the byte-pins they obsolete): `loc_csv_integrity` (every row: both locales non-empty; no `%d/%s`; `{x}` token sets identical tr↔en; no stray braces), `loc_event_en_coverage` (every non-debug reactive JSON text field has non-empty `_en`), `loc_format_locale_flip` (per-locale `Fmt` assertions under forced locale — replaces `endgame_smoke.gd:5084-5088` and fmt_probe byte-pins), `loc_pick_fallback` (pick() TR fallback + factory contract).

---

## 5. CLAUDE.md law draft — BILINGUAL BIRTH LAW

Lands inside `## Content & Language Laws` as a sibling of LANGUAGE INTEGRITY LAW (same register, same section — the section preamble "these govern all player-facing text" already binds it). Draft:

> **BILINGUAL BIRTH LAW.** Every player-visible string is born as a localization key with **both TR and EN
> filled in the same commit** — TR canonical, EN written natively (never machine-translation register), the
> glossary (`docs/design/localization_glossary.md`) binding on every term it rules. No player-visible literal
> lives in a script or scene: static scene text carries the KEY itself (auto-translate renders it — probe-verified);
> composed text goes through `tr(KEY).format({...})` with **named placeholders only** — positional `%s`/`%d`
> are banned from player-visible strings, an interpolated value never takes a suffix or grammatical agreement
> (restructure the sentence: `Sözleşme: {company}`, never `{company}'nin sözleşmesi`), and no literal braces in
> CSV values. Proper nouns do not localize. Localized text is never written into state — store ids, render at
> display time. A task that adds a player-visible string without both locales is **incomplete — reviewers reject
> it**; agent done-messages list every key they added. Event JSON carries `*_en` sibling fields; empty `_en`
> means TR-fallback by design (factory events), absent `_en` on authored content means the task is not done.
> **Proof is a command, not a claim:** `loc_residue.gd` exits zero, `loc_csv_integrity` passes, and both stay
> green in every commit that touches strings.

(On landing: the glossary section of this report is promoted to `docs/design/localization_glossary.md` as the law's standing companion — the `theme_sweep_ledger.md` pattern; the INTEGRITY law's `TranslationServer + strings.csv` parenthetical gains the precision fix "(runtime CSV parse by the `Localization` autoload)".)

---

## 6. Phase 2 execution plan — ten smoke-green commits

Preconditions: this report approved · cleanup committed · single-writer on `strings.csv` + every keyed file for the duration.

| Step | Content | Size signal |
|---|---|---|
| 0 | Ground truth: re-verify every anchor/count against the committed tree (S3-2/S3-20 shifts already prove the need); generate the ASCII-Turkish wordlist; land `loc_residue.gd`; delete `.translation` debris + gitignore; **land the law + glossary promotion first** so parallel work is bound | small |
| 1 | Infrastructure: printf→named migration (31 keys + ~35 callers); `Fmt` + `MONTH_*/DOW_*/DATE_LINE/PCT_PATTERN/SHARE_FLOOR` keys + UiTokens delegates; `Localization.pick`/`is_first_boot`/`--lang`; LanguageGate; event `_en` schema + loader + modal pick; router dirty-guard + `TAB_*` keys; 4 smoke cases | the enabling commit |
| 2 | Glossary keys landed once (~80-120 shared-caption keys from §3) so batches consume, never re-key | mechanical |
| 3-9 | Seven module batches, systems-first, each = its systems/catalogs + tab views + modals + scene literals, one commit each: **B1** Sales/B2B (+ both stored-state fixes: `Customer.company_name` stops storing composed text; founder default name keys to Kurucu/Founder — S2-42) · **B2** HR (`hr_constants` tables via keys, factories, atlas/popover/overtime + suffix restructure) · **B3** Product (creation/detail/pricing/portfolio, `money_tr` merge, BuildHUD) · **B4** Finance/VC (`vc_pitch`, term sheet + suffix restructures, finance views) · **B5** Shell/ODA (TopBar captions+dates, oda_view residue, tour, news_feed templates, month summary) · **B6** Event content: ~85 `_en` values `[DRAFT-EN]` + event modal chrome + S3-20 label table + Frank/mentor/meeting/confirm modals · **B7** Endings (§4.6) + onboarding leftovers + residue-to-zero | ~1,130 lines + 135 scene literals across 7 commits |
| — | Full verification: complete TR+EN shot matrix (~50-60 pairs, every PNG read; EN clipping fixed by rewording); TR spot-diff vs pre-sweep baselines (TR renderings must be pixel-stable outside approved changes — money flip if ruled); mid-run switch walk; first-boot walk; full smoke suite, case count from source; `[DRAFT-EN]` inventory delivered as one list | the gate out |

Audit items closed en route: S2-34, S2-35 (the toggle finally keeps its promise), S2-42, S2-46, S3-2 residue, S3-20, S3-21 (per §3.7 ruling), S3-30, S3-54, S3-58. Not in scope: S3-44 (real brands — separate legal-surface track), K1 feature-picker (owned by product), any behavior change discovered en route (logged for cleanup, not fixed here).

---

## 7. Decisions requested at this gate

1. **Glossary** (§3) — the taste pass; specifically the three `[REVISES SHIPPED]` flags (TAM SÜRÜMDE → IN THE FULL GAME; İlgilen → Check in; plus any the director adds) and the `[DIRECTOR]` rows: phase-name ruling (Bootstrap/Traction/Series A identical both locales), BURN whitelist-or-GİDER, Self-Made TR (keep identical vs "Sıfırdan").
2. **Money grouping flip** (§4.5) — full TR flip (recommended, director leaning) vs US-both; changes shipped TopBar appearance.
3. **Modal staleness policy** (§4.3) — accepted one-edge-case limitation vs listeners on 11 modals.
4. **`.tscn` deviation** (§4.7) — scene-baked keys over the brief's script-side assignment, on the probe's evidence.
5. **Law text** (§5) — wording as drafted.

---

## 8. Self-check against the brief (§3.5)

| Deliverable | Where |
|---|---|
| Inventory grouped, counted, tiered, `.tscn` separate, non-string surfaces | §2 |
| Glossary 50-80 entries with rationale + screens | §3 (78) |
| Schema/architecture proposals incl. CSV-direct kept, key convention, event schema, `language_changed` map, first-boot | §4 |
| Law draft | §5 |
| Phase 2 plan sized against real counts | §6 |
| Probe proof (director's added condition) | §1 + Annex A |
| No game-file edits · no git writes · single-writer respected | header; dirty-count 98 before and after |

---

## Annex A — probe script (verbatim, ran from session scratchpad)

```gdscript
# LOCALIZATION PROBE — throwaway, lives in the session scratchpad, never in the repo.
extends SceneTree

const KEY := "LOC_PROBE_KEY"
const TR_VAL := "MERHABA DÜNYA UZUN METİN"
const EN_VAL := "HI"
const REAL_KEY := "ONB_LOCKED_CHIP"  # real CSV key, expected KİLİTLİ / LOCKED (autoload run only)

var probe: Label          # text = raw KEY, default auto_translate (INHERIT)
var probe_always: Label   # text = raw KEY, AUTO_TRANSLATE_MODE_ALWAYS
var twin_tr: Label        # literal TR_VAL, auto-translate DISABLED (reference width)
var twin_en: Label        # literal EN_VAL, auto-translate DISABLED (reference width)
var resolved: Label       # text = TranslationServer.translate(KEY) at build time (control case)
var frame := 0
var w := {}
var has_autoload := false

func _initialize() -> void:
	has_autoload = root.has_node("Localization")
	print("PROBE godot=%s autoload_Localization=%s locale_at_start=%s" % [
		Engine.get_version_info().string, has_autoload, TranslationServer.get_locale()])
	print("PROBE root.auto_translate_mode=%d (0=INHERIT 1=ALWAYS 2=DISABLED)" % int(root.auto_translate_mode))
	print("PROBE root_node_auto_translate setting=%s" % str(
		ProjectSettings.get_setting("internationalization/rendering/root_node_auto_translate", "<unset>")))
	var t1 := Translation.new()
	t1.locale = "tr"
	t1.add_message(KEY, TR_VAL)
	var t2 := Translation.new()
	t2.locale = "en"
	t2.add_message(KEY, EN_VAL)
	TranslationServer.add_translation(t1)
	TranslationServer.add_translation(t2)
	TranslationServer.set_locale("tr")
	probe = Label.new()
	probe.text = KEY
	probe_always = Label.new()
	probe_always.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_ALWAYS
	probe_always.text = KEY
	twin_tr = Label.new()
	twin_tr.text = TR_VAL
	twin_tr.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	twin_en = Label.new()
	twin_en.text = EN_VAL
	twin_en.auto_translate_mode = Node.AUTO_TRANSLATE_MODE_DISABLED
	resolved = Label.new()
	resolved.text = TranslationServer.translate(KEY)
	# Nest the probes two containers deep — notification must propagate like in real scenes.
	var outer := VBoxContainer.new()
	var inner := HBoxContainer.new()
	outer.add_child(inner)
	inner.add_child(probe)
	inner.add_child(probe_always)
	root.add_child(outer)
	root.add_child(twin_tr)
	root.add_child(twin_en)
	root.add_child(resolved)
	if has_autoload:
		print("PROBE real-key under tr: %s = '%s'" % [REAL_KEY, TranslationServer.translate(REAL_KEY)])

func _process(_d: float) -> bool:
	frame += 1
	if frame == 2:
		if has_autoload:
			# Re-query AFTER the autoload's _ready has run — in _initialize the CSV was
			# not yet registered (script-mode ordering).
			print("PROBE real-key under tr (post-ready): %s = '%s'" % [REAL_KEY, TranslationServer.translate(REAL_KEY)])
		w["probe_tr"] = probe.get_combined_minimum_size().x
		w["always_tr"] = probe_always.get_combined_minimum_size().x
		w["twin_tr"] = twin_tr.get_combined_minimum_size().x
		w["twin_en"] = twin_en.get_combined_minimum_size().x
		w["resolved_tr"] = resolved.get_combined_minimum_size().x
		print("PROBE frame2 (locale=tr): probe_w=%.1f always_w=%.1f twin_tr_w=%.1f twin_en_w=%.1f resolved_w=%.1f probe.text='%s'" % [
			w["probe_tr"], w["always_tr"], w["twin_tr"], w["twin_en"], w["resolved_tr"], probe.text])
		TranslationServer.set_locale("en")
		if has_autoload:
			print("PROBE real-key under en: %s = '%s'" % [REAL_KEY, TranslationServer.translate(REAL_KEY)])
	elif frame == 4:
		var probe_en: float = probe.get_combined_minimum_size().x
		var always_en: float = probe_always.get_combined_minimum_size().x
		var resolved_en: float = resolved.get_combined_minimum_size().x
		print("PROBE frame4 (locale=en): probe_w=%.1f always_w=%.1f resolved_w=%.1f probe.text='%s'" % [
			probe_en, always_en, resolved_en, probe.text])
		var a: bool = absf(float(w["probe_tr"]) - float(w["twin_tr"])) < 0.5 and float(w["probe_tr"]) > 0.0
		var b: bool = absf(probe_en - float(w["twin_en"])) < 0.5 and absf(probe_en - float(w["probe_tr"])) > 1.0
		var a2: bool = absf(float(w["always_tr"]) - float(w["twin_tr"])) < 0.5
		var b2: bool = absf(always_en - float(w["twin_en"])) < 0.5
		var c: bool = probe.text == KEY
		var d: bool = absf(resolved_en - float(w["resolved_tr"])) < 0.5
		print("PROBE A(inherit first-paint TR)=%s  B(inherit live-flip EN)=%s  A2(ALWAYS first-paint TR)=%s  B2(ALWAYS live-flip EN)=%s  C(text stays raw)=%s  D(pre-resolved does NOT flip)=%s" % [a, b, a2, b2, c, d])
		print("PROBE RESULT: inherit=%s always=%s" % [
			"PASS" if (a and b) else "FAIL", "PASS" if (a2 and b2) else "FAIL"])
		quit(0 if (a2 and b2 and c and d) else 1)
	return false
```

Commands: `Godot_v4.6.2-stable_win64_console.exe --headless -s <scratchpad>\loc_probe.gd` (Run A) · same + `--path "<project>"` (Run B, ×2 identical passes). Note the earlier single-assertion revision of Run B also passed before the post-ready re-query was added — three green in-project executions total.

