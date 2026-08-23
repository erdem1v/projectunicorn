# FRANK v6 — RUNTIME VERIFICATION

**Date:** 2026-08-21 · **Type:** READ-ONLY verification (nothing fixed, nothing rewritten) · **Tree:** working tree at `9908a8b`, audited as it stands · **Sibling report:** `EVENT_INVENTORY_2026-08-21.md`

## What this report is for

The Frank v6 landing pass proved 128 strings byte-exact in `localization/strings.csv` and every gate green. That is a claim about **text**. This report is the claim about **behaviour**: which card a player actually sees, on which day, in which phase, and what the rendered frame looks like. The two are different claims and they needed different instruments.

## Method

**Eight played runs**, all through `RunProbe` (`--run-log=<preset>:<days>:sim`, seed pinned 424242), which answers every modal through `EventManager.resolve_choice` — the same seam the real modal calls.

| preset | days run | terminal | fires |
|---|---|---|---|
| **`full_run:730`** *(the primary run, log attached)* | **1 → 275** | **`profitable_bootstrap`** | **62** |
| `full_run_weak:730` | 1 → 245 | `profitable_bootstrap` | 78 |
| `b2c_keep:365` | 1 → 183 | `profitable_bootstrap` | 35 |
| `b2c_neglect:365` | 1 → 365 | none — run still active | 47 |
| `b2b_solo:365` | 1 → 365 | none — run still active | 116 |
| `b2b_slip:180` · `b2b_risk:180` · `b2c:180` | 1 → 180 | none — run still active | 56 · 61 · 31 |

Log: `FRANK_VERIFY_2026-08-21_full_run_730.log` (6,388 lines) beside this file.

**Shots.** Sixteen Frank cards and every standing strip were rendered at 1920×1080 in **both locales**. Surfaces with an existing harness flag went through it (`--modal-shot=mentor|month`, `--event-shot=<id>`, `--b2b-shot=angel|deal`, `--finance-shot=uyari|kepenk`, `--product-shot=detail_b2b`, `--tab-shot=events`). The twelve Frank surfaces with **no** shot path went through a scratchpad `-s` driver that reproduces the in-tree idiom at `main.gd:592-600` — build the `GameEvent` from its real factory, mount the real `EventModal.tscn`, `populate()`, capture. **No project file was created, edited or deleted to obtain any frame.**

The frames live where every other harness writes them, `%APPDATA%\Godot\app_userdata\Project Unicorn\` — the Frank set under `frank_verify\` (`s03_…` … `s25_…`, `_tr` and `_en`), the rest at the top level under their harness names. They are deliberately **not** committed: they are ~1 MB each and regenerable from the two scratchpad drivers.

*Exactly what "read" means here, so the evidence can be weighed:* the **pixels** were read for every card that fired (3, 4, 5, 6, 7, 9, 10, 11, 12), for two of the three inert cards (12b and the token-bearing 17+18), for the wired-but-unfired shutter card (16), for every standing strip (1, 19, 20 in both bands, 21, 22 in both hosts, 23, 25), and for surface 1 in **both** locales. For the remaining frames — 13, 14, 15, 24, and the rest of the English pass — the evidence is the driver's **resolved-text dump**, which walks the mounted modal and prints every `Label` / `RichTextLabel` / `Button` string with its node path. That dump proves tokens, missing-key fallbacks, badge text and option labels; it does **not** prove clipping or overflow, and this report never claims it does.

**Six falsification smoke cases** run and gated on `SMOKE PASS` *and* the absence of `Parse Error|Compile Error|Failed to instantiate`: `buyout_card_is_inert`, `deal_prompt_is_inert`, `loc_event_en_coverage`, `traction_gate_one_option`, `last_answer_warning`, `last_answer_warning_suppressed` — **6/6 PASS, 0 fatal lines**.

### One correction recorded against my own method

My text-dump walker printed `Label.text`, and Godot's Control auto-translate resolves the key **at draw time without rewriting `.text`**. So the Hunt page dumped `HUNT_PAGE_TITLE` / `HUNT_SEC_PENDING` / `HUNT_SEC_OFFERS` as if they were missing keys. Reading the PNG settled it: the page renders **"Series A Avı"**, **"TEKLİFLER"**, **"BEKLEYEN"** correctly. Three false findings were killed by looking at the picture instead of the dump — which is the argument of this whole report in miniature.

---

## 0 · The numbering trap (read this before the tables)

**Two incompatible surface-numbering schemes exist in this repo and they collide.** `FRANK_VOICE_INVENTORY.md` numbers 26 occurrences run-chronologically (pre-pass snapshot, `1867213`). `Frank Diyalogları · v6.md` numbers cards 1–18 and standing strips 19–25. They agree through 12 and then swap blocks: v6 13–18 = inventory 20–25, and v6 19–25 = inventory 13–19.

Inventory row 24 is `ev_pivot_offer`. **v6 surface 24 is `DEAL_PROMPT_LINE`.** This report uses v6 numbering throughout, as the task does.

A correction to the task's own framing: **"the standing strips 19 through 25" is not uniformly live.** Surface 24 sits in Bölüm 2 but is a card, not a strip, and it is one of the three inert ones. Strips 19, 20, 21, 22, 23 and 25 are live; 24 is not.

---

## 1.1 · Every Frank card that fired

Ordered by first appearance in the primary run. "State" is that day's `PROBE STATE` row.

| v6 | id | day · hour | phase | player state at that moment |
|---|---|---|---|---|
| **3** | `ev_mvp_iter_decision_intro` | **d7 · h10** | 1 | cash $7,900 · MRR 0 · brand 50 · 0 customers · 0 employees |
| **4** | `ev_mvp_ship_moment` | **d24 · h00** | 1 | cash $6,870 · MRR 0 · brand 50 · 0 cust · bugs 1 · q 38.0 |
| **6** | `ev_ps_frank_intro_b2b` | **d25 · h00** | 1 | cash $6,820 · MRR 0 · brand 50 · 0 cust |
| **9** | `ev_phase_gate_traction` | **d33 · h00** | 1 → **2** | cash $6,034 · MRR $425 · 1 cust |
| **10** | `ev_angel_frank_seed` | **d53 · h00** | 2 | cash $29,948 *(includes the $25,000)* · MRR $3,125 · 4 cust |
| **11** | `ev_angel_hire_nudge` | **d55 · h00** | 2 | cash $29,111 · MRR $3,125 · 4 cust · 1 employee |
| **5** | `ev_mvp_version_ship_moment` | **d63 · h00**, **d96 · h00**, **d119 · h00** | 2 | MRR $3,550 → $9,405 → $17,665 |

From the other runs, two more:

| v6 | id | where | day |
|---|---|---|---|
| **7** | `ev_ps_b2c_paid_tier` | `b2c`, `b2c_keep`, `b2c_neglect` | **d2 · h00** in all three |
| **12** | `ev_phase_gate_series_a` | `b2c_keep` only | **d125 · h00** |

Answers the probe gave, verbatim from `PROBE PICK`: `Turlar sürsün` · `Yayınla` · `Satış'a git` · `Tamam` · `Kabul et` · `İK'ya git` · `Yayına devam` ×3 · `Ürüne git` · `Hazırız — geçelim`.

### Every wired Frank surface that did NOT fire, and why

| v6 | id | verdict |
|---|---|---|
| **1** · Açılış | `MentorIntroModal` | **Cannot appear in any `--run-log` run.** It is not an `EventManager` card; it mounts from `main.gd:2013→2024` when onboarding completes, and `RunProbe` never mounts the shell. Verified by shot instead. **Not a defect.** |
| **13** · Toplantı günü | `ev_vc_meeting_prompt` | **Never fired in any of the eight runs.** It needs `pending_meeting` to reach its booked day, and `_play_the_founder` never books a VC meeting. |
| **14** · Teklif süresi doluyor | `ev_sheet_expiry_warning` | **Never fired.** Needs a granted term sheet at `days_left == 3`; no run ever held a sheet. |
| **15** · Son gün hatırlatması | `ev_vc_last_answer_day` | **Never fired.** Same gate — it needs a live offer for today to be the last day to answer. |
| **16** · Kepenk uyarısı | `ev_shutter_warning` | **Never fired, in 2,290 simulated days.** It needs the first day of `cash < 0`; cash never went negative in any preset, including `b2c_neglect`, which finished day 365 with **$42,225 in the bank and MRR 0**. |
| **12** · Seed kapısı | `ev_phase_gate_series_a` | Fired **once**, in `b2c_keep` only. The B2B path never reaches it: `full_run` plateaus at MRR $32,495 against a $40,000 bar. |

**This is the headline of Part 1.** Four of the eleven wired cards — the entire VC arc plus the shutter warning — are **unreachable by a played run that does not hand-drive the world**, and a fifth (12) is reachable on one preset out of eight. The Frank pass landed their text correctly; the run cannot get to them.

### Two surfaces that are live, undocumented, and still in the pre-v6 voice

Neither has a v6 entry, and neither was rewritten:

- **`PROD_MENTOR_LINE`** (+ `PROD_MENTOR_TAG` = `FRANK KÖSEOĞLU · MENTOR`), the Frank strip in the B2C/B2B path picker, `creation_flow.gd:300-302`. It fires on the first build a player ever starts. It never appears in a run log because `RunProbe` calls `start_build` directly, bypassing the picker.
- **`PROD_EV_VERSION_SHIP_BODY`**, surface 5, which **fired three times in the primary run** and carries an em dash in both locales (see 1.4).

Bölüm 3 of the v6 document says Frank was removed from both. He was not.

---

## 1.2 · What the frames actually show

Every frame below was rendered at 1920×1080 and read. Common to **all sixteen** Frank cards: no literal `{token}` except where noted in 1.3, no missing-key fallback, no clipped or badly wrapped title, no text overflowing its panel, every option label rendered, and correct modal chrome (`KARAR · GÜN {day}` / `SEÇİM KALICIDIR · OYUN DURAKLATILDI`, and the EN equivalents `DECISION · DAY` / `THE CHOICE IS PERMANENT · GAME PAUSED`).

### Three defects visible on every single Frank surface

**F-1 · The role line reads "Operating Partner" in the Turkish build.** Every Frank card, and the intro modal, renders the speaker strip as `Frank Köseoğlu · Operating Partner`. The renderer is `HRConstants.role_label(c.role)` (`event_modal.gd:262`, `mentor_intro_modal.gd:20`), which derives `HR_ROLE_MENTOR` — and that CSV row is `Operating Partner,Operating Partner`, English in both columns. One row away sits `MENTOR_ROLE` = `OPERASYON ORTAĞI` / `OPERATING PARTNER`, correctly translated. Its only reference is `MentorIntroModal.tscn:90`, where the scene text is **overwritten at runtime** by line 20 of the script. So the properly-Turkish string is authored, localized, and unreachable, while an English literal renders in its place on every Frank surface in the game. *Language Integrity Law, visible on the first screen a player ever sees.*

**F-2 · A raw English enum sits beside Frank's name on every card.** The relationship pill renders **`NEUTRAL`** — `event_modal.gd:214-215`, field `character.gd:60`. Filed as S3-20 in the 2026-08-06 audit; still live, and now confirmed on all sixteen frames.

**F-3 · The three inert-card frames prove the "landed and final" text is not render-ready.** See 1.3.

### Per surface

**1 · Açılış — `--modal-shot=mentor`.** Clean: FK avatar, `Frank Köseoğlu` / `Operating Partner`, title `İlk sabah`, ten paragraphs, no scrollbar, CTA `Hadi başlayalım`. **But the body's last line is** *"Kapatıyor. Saat onu beş geçiyor, günün başka planı yok."* — and the TopBar **in the same frame** reads **09:00**. Day 1 starts at `TimeManager.INITIAL_HOUR := 9`, so a card that always fires at 09:00 asserts 10:05, 40 px from a clock that contradicts it. This is the defect class Bölüm 3's own ruling ("Bütün günlük event'ler gece yarısı patlıyor") exists to prevent, and it is on the first screen of the game.

**3 · Tasarım masasında karar.** Badge **MENTOR** (amber). Body clean. Two options: `Turlar sürsün` renders **with no effect chip at all**, `Geliştirmeye geç` renders `GELİŞTİRME BAŞLAR`. The chip-less row is the one that has no modifiers — the frame shows the player a two-option card where one option visibly promises nothing, which is honest, and does nothing, which is not a choice.

**4 · İlk sürüm.** Badge reads **ÜRÜN**, not MENTOR. This is deliberate — `event_modal._source_tag` puts the `ship_moment` tag ahead of the speaker check at `:230`, with a comment saying a version moment is a product beat even when Frank narrates. Recorded because the task asks that the badge read MENTOR where Frank speaks, and here the card's only voice is Frank's *("Bugün müydü?")*. The single option `Yayınla` carries **no chip** and publishes the product irreversibly. Layout note: with a two-line body the panel leaves roughly 100 px of empty space above the speaker row.

**5 · v2 yayında.** Badge **ÜRÜN**. Body carries an **em dash**: *"Yeni özellikler tuttu — ama yeni yüzey, yeni hata demek."* Option `Yayına devam`, no chip. Fired three times in the primary run.

**6 · Eski bir dost.** Badge **MENTOR**, subtitle `TELEFON` right-aligned with **no clock** — correct for an hour-00 beat. One option, `Satış'a git`, chip `YENİ ADAY`. The `mentor_advisory` modifier correctly renders no chip.

**7 · Fiyat meselesi.** Badge **MENTOR**, subtitle `MUTFAK MASASI`, no clock. One option `Ürüne git`, **no chip and no modifier except `mentor_advisory`** — the card that says *"bir noktada ücret almaya başlasak iyi olur"* does not open the paid tier and its button goes nowhere.

**9 · İlk ödeme.** Badge **MENTOR**. One option `Tamam` → `advance_phase`, **no chip**. The card that permanently moves the run from Bootstrap to Traction tells the player nothing about what the button does.

**10 · Frank'in teklifi.** Badge **MENTOR** — the old PİYASA mis-badge is fixed and the ordering guard at `endgame_smoke.gd:3017` holds. Accent chip renders `NAKİT +$25K · FRANK'E %4 HİSSE`. The locked `Reddet` row renders dimmed, non-interactive, with its reason `ZOR MODDA AÇILIR.` — exactly the treatment a permanently-locked row should have. **The best-rendered card in the set.**

**11 · Tek kişilik şirket.** Badge **MENTOR**. One option `İK'ya git`, no chip, no modifiers.

**12 · Series A masası.** Badge **MENTOR**. **Two em dashes on screen**: the body's *"Runway'in dar mı geniş mi — girebilirsin"* and the option label **`Hazırız — geçelim`**. Both options (`Hazırız — geçelim` → `advance_phase`, `Henüz değil` → `phase_gate_decline`) render **with no chip**.

### The standing strips

**19 · Ay sonu satırı — `--modal-shot=month`.** FK avatar circle, italic *"Bir ay daha geride."*, caption `FRANK KÖSEOĞLU · MENTOR`. Clean, no token, no clipping.

**20 · Runway uyarısı — both bands read.** `--finance-shot=uyari` renders the `MENTOR UYARISI` card with *"Runway 6 ayın altında. Ya gideri kıs ya geliri bul; ikisi de karar ister."* — `{months}` resolves to 6, so the old hardcoded "altı ay" is genuinely fixed. `--finance-shot=kepenk` renders the shutter band: *"Runway diye bir şey kalmadı. Sayaç işliyor; bugün ne kestiğin önemli."* Both clean. Observation: the `ERTELE` snooze button is offered in the **shutter** band too.

**21 · Ürün ipuçları — `--product-shot=detail_b2b`.** Bottom strip: *"Zayıf yanın Deneyim. v3 sürümünde onu güçlendir; Adımla önünde."* Italic, **no attribution** — the "Frank kalkıyor" ruling was executed correctly.

**22 · Telefondaki not — driven through the real seam.** `EventBus.mentor_advisory_changed` emitted with the exact payload `ev_ps_frank_intro_b2b` carries. **Host A (ODA):** the desk phone shows a red dot and an in-glass `FRANK` notification — small, legible, correct. **Host B (Events page):** section header `FRANK'TEN NOT` and the italic quote *"Görüşme ayarlandı. Hazırlıklı git."* Clean. Observation: the note sits underneath the page's own `OLAYLAR / İçerik yolda` placeholder, so Frank's line is currently the only real content on that page.

**23 · Hunt şeridi.** Renders top-right: *"Av açık. Kapanan masa: 2. Üçüncüde yol biter."* — `{n}` resolved to the live `vc_rejections`. The old "dört masa" copy-lie is gone.

**25 · Masa satırları — term sheet table.** Frank's line renders unattributed in italic under the odds dial: *"İlk teklifleri bu. Zorla."* (`TERM_FRANK_OPENING`). Clean. **But the investor name renders `ANCHOR CAPİTAL`** — the Turkish-locale uppercase transform turned the `i` of "Capital" into a dotted `İ`. Proper nouns do not localize; this one is being mangled by the uppercase pass under the `tr` locale.

---

## 1.3 · Are the inert ones still inert? — YES, all three

| v6 | id | mechanism | evidence |
|---|---|---|---|
| **12b** | `ev_seed_closed` | **Outside the scanned directory.** `EVENTS_DIR` is one non-recursive constant (`event_manager.gd:32`, scan `:872-891`); nothing else opens `data/events/`. | Absent from all eight run logs. `loc_event_en_coverage` PASS (it scans `unwired/`, so the card cannot go TR-only). |
| **17+18** | `ev_buyout_offer` | **Builder with no caller.** `_build_buyout_offer_event` (`endings_system.gd:355`) is referenced only by its own definition and three of its own comments; both former injection sites keep their latch writes and return. | Absent from all eight logs. `buyout_card_is_inert` **PASS**. |
| **24** | `ev_vc_deal_prompt_<vc>` | **Builder with no caller, two levels deep.** Both call sites of `_offer_deal_prompt` (`vc_pitch_system.gd:263`, `:473`) are removed with comments left in place. | Absent from all eight logs. `deal_prompt_is_inert` **PASS**. |

**Nothing reached any of them.** Two traps worth naming so nobody later mistakes a harness for a regression: `--b2b-shot=deal` calls `_build_deal_prompt_event("anchor")` directly, and the debug hotkeys **F4** and **F10** (`game_shell.gd:239`, `:275`) still seed the preconditions of the retired buyout and pivot cards. Seeing surface 24, or the acquisition state, under any of those is not evidence the card is live.

### F-3 · What the inert frames show — and why it matters now

I mounted all three anyway, because "held so it cannot fire" is a claim about the trigger, not about the text.

**Surface 17+18 renders three literal tokens on screen, in both locales.** `_build_buyout_offer_event` calls `TranslationServer.translate("END_EV_ACQ_BODY")` with **no `.format()`**, and the body declares `{investor}`, `{valuation}` and `{offer}`. The rendered frame reads:

> `{investor} arıyor.`
>
> `"Şirketi almak isteyen biri var. {valuation} değerleme ile sana düşen miktar bu: {offer}. Karar senin, ben sadece masaya koyuyorum."`

and in English, `{investor} calls.` / `At a {valuation} valuation, your share comes to {offer}.` Both of its options — `Sat` (terminal) and `Kendi paramla devam` (also terminal, via `accept_pivot`) — render **with no chip**, so both irreversible endings are blind clicks. The v6 document's own note already says the tokens have no feeder; this report adds that **the card is not one wiring step from shipping** — it needs a formatter plus three data sources before it can be shown to anyone.

Surfaces **12b** and **24** render clean, with no tokens.

---

## 1.4 · Old Frank text still standing

A second sweep over the same ground, done while playing. 102 Frank-family CSV keys checked against every `.gd`, `.tscn` and `.json` in the tree.

### Superseded bodies and dead twins

| key | what it is | status |
|---|---|---|
| `PROD_SHIP_FIRST_BODY` | the **old** eight-line first-ship scene that surface 4 replaced with a two-line confirmation card. Puts Frank physically in the room, which Bölüm 3's channel rule forbids. | zero references · **leftover** |
| `PROD_SHIP_VERSION_BODY` | dead twin of `PROD_EV_VERSION_SHIP_BODY` (carries the same em dash) | zero references · **leftover** |
| `PROD_DESIGN_DECISION_BODY` | dead twin of `PROD_EV_ITER_DECISION_BODY` | zero references · **leftover** |
| `PROD_DESIGN_CEILING_NOTE` | dead twin of `PROD_ITER_CEILING_NOTE` | zero references · **leftover** |
| `END_EV_PIVOT_TITLE` / `_BODY` / `_ACCEPT` / `_DECLINE` | the retired pivot card, merged into 17+18 | zero references · **deliberate orphan** (the merge is documented) |
| `VC_EV_ACK` | the acknowledgment label the VC cards used before they took `VC_EV_GO_FUNDING` | zero references anywhere, including comments · **leftover** |
| `VC_EV_SKIP_MEETING` | `Bugün değil (randevu yanar)` — the removed second option of surface 13 | named only in the comment at `vc_pitch_system.gd:861` · **deliberate orphan** |
| `DEAL_PROMPT_SIT` / `_VALIDITY` / `_DEFER` | the FrankPopup two-option shape, retired | named only in the comment at `vc_pitch_system.gd:925-926` · **deliberate orphan, self-declared** |
| `MENTOR_ROLE` | `OPERASYON ORTAĞI` / `OPERATING PARTNER` | referenced at `MentorIntroModal.tscn:90` but **overwritten at runtime** — see F-1. **Leftover, and the live bug's fix is sitting inside it.** |
| `END_META_*_FRANK` ×7 | Frank's one-line verdict per ending | built into `ending_data.frank_line` (`endings_system.gd:293`) but every known ending takes its subhead from its own `END_*_SUB*` key; `frank_line` is read only in the unknown-id fallback. **Authored, localized, rendered by nothing on any ending.** `END_META_BANKRUPTCY_FRANK` additionally still says *"Yedi gün kırmızıda kaldın"* while `SHUTTER_DAYS` moved 7 → 30 — it must not be given a surface in that state. |

**Not orphans, do not sweep them:** `GATE_TRACTION_BODY_0`, `GATE_SERIES_A_BODY_0`, `GATE_SERIES_A_BODY_2` show zero literal grep hits because `phase_gate_system.gd:297-300` builds `GATE_%s_BODY_%d` dynamically. All three were verified rendering on screen.

### Hardcoded Frank text outside the localization system

| location | content | status |
|---|---|---|
| `scenes/ui/components/RightPanel.tscn:80,85,88` | `Frank Köseoğlu` · `OPERATING PARTNER` · `"Most founders die from indigestion, not starvation. Pick your bets."` | **English-only Frank aphorism, no key, no Turkish.** The scene is retired and never instantiated, and it is on `loc_residue.gd:49`'s explicit skip list — so no gate can ever see it. Its script still connects to `mentor_advisory_changed`. |
| `scripts/systems/month_summary_system.gd:133` | `"İyi bir ay. Not al — nadir gelirler."` | `LOC-DATA` layout fixture for the `--modal-shot=month` extreme branch; not a player path. Contains an em dash. |
| `data/events/reactive/ev_debug_003_cash_warning.json` | a Frank-attributed card, Turkish only | never loaded (`event_manager.gd:886` skips the `ev_debug_` prefix). |

**Zero player-facing hardcoded Turkish** was found in any of the seven event-building scripts.

### The dash ban, measured against what renders

Eight Frank-family keys carry an em dash. Four of them are **live**:

| key | rendered | where |
|---|---|---|
| `GATE_ADVANCE` | `Hazırız — geçelim` / `We are ready — let us move` | surface 12, **read on screen** |
| `GATE_SERIES_A_BODY_0` | *"Runway'in dar mı geniş mi — girebilirsin…"* | surface 12, **read on screen** |
| **`PROD_EV_VERSION_SHIP_BODY`** | *"Yeni özellikler tuttu — ama yeni yüzey…"* | surface 5, **fired 3× in the primary run** |
| **`ANGEL_MONTH_HIGHLIGHT`** | `Frank çeki yazdı — melek turu kapandı` | the month-summary "AYIN OLAYI" line after the angel round |

The first two are already named in `FRANK_UNWIRED.md` §1 as clearing when surface 12 is rewritten. **The last two are not on that list** and are the more urgent pair, because surface 5 fires three times a run.

---

## 1.5 · Anything that behaves wrong

**B-1 · Two Frank cards on one day boundary — reproduced.** `b2c_keep`, **day 2, hour 0**: `ev_ps_b2c_paid_tier` (surface 7, slot 7) and `ev_phase_gate_traction` (surface 9, slot 8) both fire on the same tick. The player answers `Ürüne git`, and the next mandatory modal is already up. The slot order 7 → 8 → 8a → 8b makes this structural, not a coincidence, and the queue never re-sorts a pumped card.

```
PROBE FIRE day=2 hour=0 id=ev_ps_b2c_paid_tier src=pool
PROBE FIRE day=2 hour=0 id=ev_phase_gate_traction src=factory:phase_gate_system:130 (gate)
```

**B-2 · Three mandatory modals in one day.** Primary run, **day 55**: a retention card and Frank's hire nudge both at hour 0, then a build event at hour 22.

```
PROBE FIRE day=55 hour=0  id=ev_b2b_retain_co_lead_51_13
PROBE FIRE day=55 hour=0  id=ev_angel_hire_nudge
PROBE FIRE day=55 hour=22 id=ev_mvp_iter_001_scope_creep
```

**B-3 · Seven navigation options go nowhere.** `Satış'a git` (6), `Ürüne git` (7), `İK'ya git` (11), `Yatırım'a git` (14, 15 and 24), `Finans'a git` (16). No `navigate_to_tab` modifier exists in `_apply_modifiers`; the labels are live and the buttons only dismiss. Two of these — 6 and 11 — **fired in the primary run**, so this is not theoretical: on days 25 and 55 a real player is told to go somewhere and the button does not take them there. Already filed as open work in `FRANK_UNWIRED.md` §5; recorded here with the days it happened.

**B-4 · An option whose label does not match its modifiers.** Surface 7 says *"bir noktada ücret almaya başlasak iyi olur"* and its only option is `Ürüne git` — carrying `mentor_advisory` and nothing else. No `open_paid_tier`, no navigation. The card announces a decision, takes none, and goes nowhere.

**B-5 · Permanent, irreversible clicks with no chip.** Surfaces 9 and 12 (`advance_phase`, `phase_gate_decline`) render no effect chip because `_describe_modifier` returns `{}` for both. Same for surface 4's `ship_active_build`, which publishes the product. Three run-shaping clicks, all blind.

**Nothing fired twice that should not have.** `ev_mvp_version_ship_moment` fired three times by design (once per version ship, `one_shot = false`). Every other Frank id shows `fires=1 picks=1` in `PROBE TALLY`. **No wrong-phase fire was observed.** Zero `Dedupe-rejected` lines in the primary run.

---

## 2 · Verdict

**The text landed. The wiring is thinner than the text.**

What the pass genuinely fixed, confirmed here at runtime: the MENTOR badge now beats the generic `endgame` tag (surface 10 reads MENTOR, not PİYASA); `HUNT_FRANK_LINE` counts real closed tables instead of asserting "dört masa"; `FIN_MENTOR_QUOTE` takes a live `{months}`; the product tips lost their attribution as ruled; the three inert surfaces are provably inert by two independent mechanisms with three falsification cases behind them; and every one of the sixteen rendered frames is free of missing-key fallbacks, clipping and overflow.

What is not true yet:

1. **Four wired cards cannot be reached by playing** — the whole VC arc (13, 14, 15) and the shutter warning (16). A fifth (12) needs one preset out of eight.
2. **An English literal renders on every Frank surface** while its Turkish translation sits unreachable one CSV row away.
3. **The "landed and final" acquisition text prints three raw tokens** and needs a formatter plus three data sources before it can be shown.
4. **Live copy defects the pass's own rulings forbid**: a clock in the opening card that the TopBar contradicts, and four em dashes in live copy, two of which are not on the known list.
5. **Seven navigation labels promise a destination the engine has no verb for**, and two of them fire in a normal run.

None of this is a regression from the pass; it is the gap between a landed script and a wired game. The cheapest items on the list — F-1 (one CSV row or one script line) and the two unlisted dashes — are worth more per keystroke than anything else in this report.
