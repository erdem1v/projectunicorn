# Arayüz ve ODA — GDD v2 conformance

**Date:** 2026-08-20 · **Chapters:** 12 · UI Surfaces & ODA; ch. 14 §7 (portrait policy); ch. 03 rev 4 §1 (build-bar permanence)
**Baseline:** `main` @ `7687095`. Every `file:line` resolves to that commit.
**Companions:** `01_urun.md` (the build bar and DESTEK), `03_ekip.md` (the Kişisel contents), `08_event_ve_anlati.md` (the events log and the phone).

---

## Verdict

The shell is in good shape and two of the chapter requirements landed within the last two days: the **speed ladder is 1x / 2x / 3x** exactly as §2 asks (`time_manager.gd:47`, the 4x rung removed by Calibration Round A §10), and the **build bar is one widget with three hosts** with a smoke case proving they agree (§3, `build_bar.gd`, `endgame_smoke.gd:2833-2900`). ODA also already satisfies §6 the harder way: the art migrated to **baked 3D plates rendered offline** on 2026-08-20, with no real-time 3D in the game and `oda_view.gd` untouched by the migration.

Three things are off, and one is structural.

**The tab rail does not match §1.** It carries eight tabs — `product, hr, finance, sales, ops, rnd, personal, events` (`ui_tokens.gd:526-537`). Two of those are ruled out by chapters written after the rail: **Operasyon has no tab** (ch. 06 §0) and **Events has no tab** (ch. 12 §1). **Pazarlama is missing** from the locked set. **Kişisel exists but is empty and is not last.** And **no tab in the rail is locked or badged Coming Soon** — Ar-Ge is fully clickable and opens an İçerik yolda placeholder.

**Attention badges are a mechanism without producers.** The badge plumbing works, but only three tabs are ever fed — HR attention, runway under three months, and the event-queue size (`left_tabs.gd:134-149`). §4 names seven kinds, of which two are partially present and five have no producing system at all. And **no badge navigates to a row**: `tab_changed` carries only a tab id (`event_bus.gd:28`).

**Onboarding is the wrong three screens.** §5 wants founder creation → the first product Konsept → Frank intro. The flow is Karakter → Köken/Huylar → Şirket, with **no product step at all** and Frank arriving afterwards as a modal over a live shell.

One correction to the chapter: §2 says the right panel carries today items and warnings. **RightPanel is retired and mounted nowhere** — its content was dispersed to ODA and Finance months ago (`right_panel.gd:1-9`). That sentence describes a surface that no longer exists.

---

## 1. Requirements

| # | GDD asks (ch §) | Code today | Verdict | Size |
|---|---|---|---|---|
| 1.1 | Active tabs: Ürün · Satış · Ekip · Finans · Kişisel, with **Kişisel last** (§1) | All five ids exist, in the order product, hr, finance, sales, ops, rnd, personal, events (`ui_tokens.gd:526-537`). So the order is wrong on two counts: Satış sits fourth rather than second, and Kişisel is seventh of eight rather than last. The Ekip tab is labelled **İK**, not Ekip (`strings.csv:393`), though its page header does say EKİP (`hr_tab.gd:192`). | **KISMİ** | hours |
| 1.2 | Kişisel is a real tab with contents (§1, ch. 02 §10) | The tab exists and has **no page** — it falls through to `_make_placeholder_body` and renders a title plus İçerik yolda (`center_viewport.gd:100, 122-157`, `strings.csv:161`). | **YOK** | several days — contents owned by `03_ekip.md` 1.16 |
| 1.3 | **Pazarlama** locked-visible, muted, badged Coming Soon, non-interactive (§1) | **The id does not exist** — no entry in `TABS`, no button, no icon, no `TAB_MARKETING` string. | **YOK** | hours |
| 1.4 | **Ar-Ge** locked-visible, muted, badged Coming Soon, non-interactive (§1) | The `rnd` tab exists but is **unlocked and unbadged**: `_apply_visual` only swaps an active variation and tints the label (`left_tabs.gd:118-129`); nothing is disabled anywhere on the rail. It opens the generic placeholder. | **KISMİ** | hours |
| 1.5 | **Operasyon has no tab** (§1, ch. 06 §0) | An `ops` tab exists (`ui_tokens.gd:531`, button `LeftTabs.tscn:283-343`), clickable, opening the placeholder. | **ÇELİŞİYOR** | hours |
| 1.6 | **Events has no separate tab**; events arrive as modals from the room, and the log lives inside Kişisel (§1) | An `events` tab exists (`ui_tokens.gd:534`) and is **load-bearing**: it is the only rail slot showing a real queue count (`left_tabs.gd:148-149`), it is where the ODA phone click routes (`oda_view.gd:1642-1646`), and its placeholder page is the only home for Frank latched mentor line (`center_viewport.gd:143-156`). Removing it needs all three re-homed. | **ÇELİŞİYOR** | a day |
| 1.7 | Events arrive as modals **from the phone** (§1, §6) | Exactly this, and it is one of the nicest details in the build: `event_triggered` lights a red dot and buzzes the phone (`oda_view.gd:655-657, 1061-1079`), then the modal is **born from the phone anchor** with a 0.22 s scale-and-translate tween when the room is visible (`event_modal.gd:56-76`). | **VAR** | — |
| 2.1 | TopBar carries date, cash, MRR, runway, shutter countdown when active, and speed (§2) | All six present: date and clock (`top_bar.gd:218-249`), cash (`:160-161`), MRR (`:163-165`), runway with an ARTIDA branch (`:180-195`), the Kepenk chip hidden while inactive (`:251-256`), and the speed cluster. The bar ships **four extra** fields the chapter does not name — burn, net, brand, reputation — plus phase name and dots, company identity, and a term-sheet offer countdown. | **VAR (plus extras)** | — |
| 2.2 | Speed is **1x / 2x / 3x** (§2) | `SECONDS_PER_DAY := [0.0, 12.0, 6.0, 3.0]` (`time_manager.gd:47`), four buttons — pause, 1x, 2x, 3x (`TopBar.tscn:265-291`), keyboard 1-3 only (`game_shell.gd:138-147`), and a smoke guard that the 4x string is gone. Note `CLAUDE.md:57` (Calibration Law 2) still says Fast 4x — a stale law line, already open as calibration director question 4. | **VAR** | hours (the doc line) |
| 2.3 | The right panel carries today items and warnings (§2) | **RightPanel is retired and unmounted.** Not present in `GameShell.tscn`; the script carries a retirement banner and a migration table (`right_panel.gd:1-9`); it is on the localization sweep skip list (`loc_residue.gd:48-49`). Its content now lives on the ODA board (dates, post-it), the ODA phone (mentor line) and the Finance tab (cap table). | **ÇELİŞİYOR (the chapter is stale)** | zero, or a chapter edit |
| 2.4 | A news ticker at the bottom carrying rival moves and world colour (§2) | Present: `GameShell.tscn:52-60`, three feeds — live headlines, the `NewsFeedSystem` stream, and cold-start ambient keys (`news_ticker.gd:105-140`). Rival **moves** do not exist (`07_rakipler.md`), so it carries generated share commentary instead. | **KISMİ** | owned by Rakipler |
| 3.1 | One build-bar widget, three hosts: BuildHUD, tracker card, ODA monitor (§3) | Exactly this, and hosts push nothing — the widget derives its own model and subscribes to its own signals (`build_bar.gd:14-17, 52-64`). Mounted at `BuildHUDPanel.tscn:122`, `creation_flow.gd:639-642` and `oda_view.gd:385-389`. | **VAR** | — |
| 3.2 | Visible in **every phase including DESTEK**; never disappears after ship (§3, ch. 03 rev 4 §1) | It disappears in all three hosts after ship, by three different mechanisms (`01_urun.md` 1.3). | **ÇELİŞİYOR** | a day, owned by Ürün |
| 3.3 | TASARIM is one refilling bar with the round as text; BETA is a counter, not a bar (§3) | TASARIM is exactly right (`build_bar.gd:176-187`). BETA is still a **draining bar** with a bug chip (`:198-200, 228-240`). | **KISMİ** | hours, owned by Ürün |
| 4.1 | Attention badges: a **number on the tab**, and clicking goes to the exact row (§4) | The number half works — one setter, one Panel per button, hidden at zero (`left_tabs.gd:151-158`). The **click-to-row half does not exist**: `tab_changed` carries only a tab id (`event_bus.gd:28`), and the badge itself is `MOUSE_FILTER_IGNORE`. The only deep link in the shell is page-level, from the ODA papers to a Finance sub-page (`oda_view.gd:1483-1489`). | **KISMİ** | a day |
| 4.2 | Badge: **flight risk** (§4) | Computed (`hr_morale_system.gd:289-290`) but only ever surfaced as part of one summed HR number, a name on the ODA post-it, and a chip inside the HR ledger. No dedicated badge. | **KISMİ** | hours |
| 4.3 | Badge: **load over capacity** (§4) | `BADGE_OVERLOADED` is derived from the company-level `needs_engineer` flag per product-dev person (`hr_morale_system.gd:293-300`) and folded into the same HR sum. Real per-role load does not exist (`03_ekip.md` 2.12). | **KISMİ** | after Ekip |
| 4.4 | Badge: **coverage red** (§4) | Coverage does not exist (`05_operasyon.md` 1.11). | **YOK** | after Operasyon |
| 4.5 | Badge: **infra capacity full** (§4) | Infrastructure does not exist. | **YOK** | after Operasyon |
| 4.6 | Badge: **account at risk** (§4) | The state exists and drives a distinct card plus a top-sort in the Sales page (`sales_tab.gd:285-295`), and a churn countdown on the ODA board. **The Sales rail tab has no badge refresh at all.** | **KISMİ** | hours |
| 4.7 | Badge: **raise demand** (§4) | The event does not exist (`03_ekip.md` 2.19). | **YOK** | after Ekip |
| 4.8 | Badge: **locked opportunity** (Marka or infra gate) (§4) | No badge. Visible-locked telegraphs exist in five places — the Finance sub-tab, Hunt cards, onboarding origin cards, the ending hard-mode row, research-locked features — but none badges a tab. | **YOK** | a day |
| 5.1 | Onboarding step 1: **founder creation** — name, origin, skills, by archetype pick or point distribution (§5) | Split across two pages. Page 1 Karakter takes an optional name and a **required portrait** (`character_step.gd:63-69, 163-164`); page 2 Köken takes origin, traits and a six-point allocation across five skills (`origin_traits_step.gd:88-157, 276-381`). | **KISMİ** | a day |
| 5.2 | Onboarding step 2: **the first product Konsept** — market, subtype, features, price draft, team = just the founder (§5) | **Not in onboarding at all.** Product creation lives in the Product tab as its own three-step flow, reached after the shell mounts (`creation_flow.gd:3-6`). Price is not part of that flow either (`01_urun.md` 2.3). The founder-as-team is implicit: the SORUMLU dropdown defaults to him (`creation_flow.gd:717-718, 728`). | **YOK — the biggest gap in this module** | several days |
| 5.3 | Onboarding step 3: **Frank intro** (§5) | Present as the closing beat but **outside the flow**: `MentorIntroModal` is mounted into `ModalLayer` after `GameShell` paints (`main.gd:1959-1961`), after a deliberate 1.0 s loading overlay (`onboarding_flow.gd:216-217`). It stays paused on dismiss because the first decision is meant to be the build commit (`main.gd:1965-1969`) — which under §5 would already have happened. It also has two live defects: it is mounted **twice** on a new run, and it mounts on a **save load** (`08_event_ve_anlati.md` §7). | **KISMİ** | a day |
| 5.4 | Onboarding must set the founder 7+2 numbers (ch. 02 §11) | It sets five skills at 0-3 from a six-point pool (`founder_constants.gd:19-27`), which is the old model (`03_ekip.md` 1.1). Traits are collected and **consumed by nothing** (`origin_traits_step.gd:12-13`, `game_state.gd:889-890`). | **KISMİ** | after the Ekip skill model |
| 5.5 | Extra pages not in the target flow | The **Şirket page** (company name, logo style, slogan) is an entire third page the chapter does not mention, and the **portrait grid** is the only hard gate on page 1. Both may be right; they are simply not in §5. | **note** | director call |
| 6.1 | v1 ships sealed 2D plates; if the 3D spike plates are approved they replace them **as plates**, with no real-time 3D (§6) | Done on 2026-08-20. Eight PNG plates are preloaded and composed in layers (`oda_view.gd:30-45, 165-235`); the 3D scene under `scenes/oda3d/` is an **offline** pipeline that nothing in `scripts/` ever loads. | **VAR** | — |
| 6.2 | ODA hosts the monitor (build bar), the phone (events) and the day-to-night tint (§6) | All three: the monitor has three faces with the BuildBar under its glass (`oda_view.gd:312-392, 934-1020`), the phone carries the dot, the buzz and the glass notice (`:395-416, 1037-1052`), and the light machine is a four-state fade — day, evening, night, dawn, with overtime forcing night (`:833-885`). | **VAR** | — |
| 6.3 | ODA is the centre view and the default screen (§2, §6) | `center_viewport.gd:39` opens on the room; a tab page mounts over it and three separate close paths all emit the same `tab_changed("")` (`tab_page_chrome.gd:56`, `game_shell.gd:169-183`, `left_tabs.gd:85-91`). | **VAR** | — |
| 6.4 | Main menu is an ODA night scene (§6) | There is no main menu. The system menu Ana Menü slot is disabled with a YAKINDA badge (`system_menu_modal.gd:24, 36-42`), and TEKRAR DENE on the ending screen relaunches the process. | **YOK** | several days |
| 7.1 | Terminal visual language: mono type, hairline rules, amber accent, edge-glow hover only (§7) | Held, and enforced by structure: one token vocabulary, a generated theme with a stamp guard (`ui_tokens.gd:83`, `main.gd:73-78`), and border-only hover in both the shell and ODA (`oda_view.gd:1574-1610`). | **VAR** | — |
| 7.2 | The UI scale ladder and resolution handling stay as shipped (§7) | Unchanged; `--display-check` verifies the real setters against what the server reports (`main.gd:281-341`). | **VAR** | — |
| 8.1 | Portrait policy: employees have no faces, initials and colour; VCs and customer-side characters have portraits; Frank has a portrait (ch. 14 §7) | Employees: initials, correct (`event_modal.gd:282-296`). VC and customer portraits exist. Frank's portrait **does exist** — `res://assets/art/investors/portrait_frank.webp`, tracked since `919cc7a`, `.import` params identical to the four VC portraits. The gap was narrower: the event card could not render *any* portrait, because `_make_avatar` took only initials and `Character` carried no portrait field, so Frank's every event card showed initials. | **VAR** | — |
| 8.2 | Every event card shows a small circular avatar of its source; the large dedicated Frank modal is retired (ch. 14 §7) | The card grammar is uniform already. The two bespoke Frank surfaces are `MentorIntroModal` and `FrankPopup` — see `08_event_ve_anlati.md` §7. | **KISMİ** | a day |

---

## 2. Contradictions, expanded

### 2.1 The rail has eight tabs and the GDD wants seven, two of them locked

Target: **Ürün · Satış · Ekip · Finans · Kişisel** active, **Pazarlama · Ar-Ge** locked-visible, no Operasyon, no Events.

Today: `product, hr, finance, sales, ops, rnd, personal, events`, all unlocked, none badged.

The changes are: remove `ops`, remove `events`, add `marketing`, give `marketing` and `rnd` a locked treatment, move `personal` last, reorder `sales` up, and give `personal` a page.

**Two hazards make this less trivial than it looks.** First, **badge indices are hard-coded integers** — `1` for HR, `2` for Finance, `7` for Events (`left_tabs.gd:139, 146, 149`) — and the scene node array is positional (`:16-25`), so any insertion or removal above those positions silently misroutes badges. Second, removing `events` orphans three things: the queue-size badge, the ODA phone click target (`oda_view.gd:1642-1646`), and the only rendering of Frank latched mentor line (`center_viewport.gd:143-156`). §1 says the log moves into Kişisel; that has to land in the same pass, not after.

There is precedent for the removal: the standalone Yatırım rail tab was already relocated into Finance as a sub-page, and the comment recording it is still there (`ui_tokens.gd:535-536`).

### 2.2 Badges are a mechanism waiting for producers

Of §4 seven badge kinds, **two are partly present** (flight risk and load, both folded into one HR number), **one is present as state but unbadged** (account at risk), and **four have no producing system**: coverage red, infra capacity full, raise demand, locked opportunity. The two extras that do exist — runway under three months and the event queue — are not in the chapter list, and one of them sits on a tab that is being removed.

So badges are the **last** thing to build in this module: each one needs its producer first. What can be done early is the missing half of the mechanism, **click-to-row**, which is a signal-payload change (`event_bus.gd:28`) plus a receiving convention in each tab.

### 2.3 Onboarding is missing its middle

§5 is three beats. Today: founder creation is split across two pages with a portrait gate and a traits section whose effects nothing reads; **the product Konsept beat is absent entirely**; and the company-identity page occupies the slot the product beat would take.

The consequence is visible in the pacing. Onboarding ends **paused**, and `main.gd:1965-1969` explains why: the first decision is meant to be the build commit. Under §5 the build commit happens *inside* onboarding, so the run would start with the product already building and Frank speaking over it — a different opening rhythm, and a better one for a 60-90 minute demo.

Anything that changes the payload shape must also update `_debug_payload()` (`main.gd:2450-2464`) and the smoke fixture, or every harness run diverges from the real flow.

### 2.4 The chapter describes a right panel that no longer exists

§2 lists the right panel as carrying today items and warnings. It was retired months ago and its content dispersed: mentor line to the ODA phone, upcoming dates to the ODA board, the rival league to the ODA market card, the cap table to Finance, top customers to Sales (`right_panel.gd:5-8`). The scene and script are still on disk and instanced nowhere.

Either the chapter line is stale, or the intent is to bring the panel back. This report reads it as stale, because every one of its five sections now has a better home, and ch. 12 §2 says the current layout is accepted as-is.

### 2.5 The ODA plates are now baked 3D, and that constrains future room work

The migration (2026-08-20) re-rendered eight layers from a Godot 3D scene and swapped them in as plates without touching `oda_view.gd` or `oda_layout.gd`. Anyone redesigning the room needs to know the envelope:

- **Object plates must keep true alpha.** The hover rim reads `1 − texture alpha`, so an opaque plate silently kills hover everywhere.
- **`REGIONS` and `RECTS` are a contract, not a preference.** Each object rect equals its source region divided by the art canvas, which is what makes the aspect-safe placement work. Moving anything in the 3D source shifts alpha bounds and breaks hotspots, hover shape and every host-derived surface at once.
- **The camera is pinned** (`oda_layout.gd:50-52`); freeing the solver once threw the corkboard 214 px off contract.
- **Night is a two-layer model** — only the lamp has a night plate, because its channel ratio exceeds 1; everything else is a tint.
- **The verification gate is textual, not pixel:** `--theme-audit=oda` must print 121 identical `AUDIT|` lines. Pixel diffing ODA is invalid because the frames are bimodal across runs.

None of this blocks a redesign; all of it makes an unplanned one expensive.

---

## 3. Seams

| Seam | Direction | Mechanism today | State |
|---|---|---|---|
| Tab selection | Arayüz → pages | One signal, `tab_changed(tab_id)`, with the empty string meaning the room (`event_bus.gd:28`, `center_viewport.gd:73-106`). Three close paths, one channel. | **present** |
| **Badge → the exact row** | Arayüz → pages | **ABSENT** — the signal carries no payload beyond the tab id. | **absent** |
| HR attention → rail badge | Ekip → Arayüz | `HRSystem.attention_count()` (`hr_system.gd:170-183`). | **present** |
| Runway → rail badge | Finans → Arayüz | Binary under three months (`left_tabs.gd:141-146`). | **present (not in the chapter list)** |
| Event queue → rail badge | Event → Arayüz | `get_queue_size()` (`:148-149`) — on a tab being removed. | **present, needs relocating** |
| **Coverage, infra, raise demand, locked opportunity → badges** | Operasyon / Ekip → Arayüz | **ABSENT** — no producers. | **absent** |
| Event → the phone, then the modal | Event → ODA → Arayüz | Dot and buzz on `event_triggered`, then the card is born from the phone anchor (`oda_view.gd:655-657`, `event_modal.gd:56-76`). | **present** |
| Mentor advisory → the phone glass | Event → ODA | `mentor_advisory_changed` latches a line; the glass shows only the tag, the full text lives on the Events page (`oda_view.gd:662-664, 1041-1052`, `center_viewport.gd:143-156`). | **present, needs re-homing** |
| Build state → three hosts | Ürün → Arayüz | One widget, self-subscribing (`build_bar.gd:52-64`). | **present** |
| Pending decisions → ODA desk papers | Ürün / Yatırım / Ekip / Satış → ODA | Four sources, capped at three cards with an overflow chip (`oda_view.gd:1364-1436`), and a page-level deep link into Finance sub-pages (`:1483-1489`). | **present** |
| Attention person → ODA post-it | Ekip → ODA | First badged employee, worst first (`oda_view.gd:1333-1345`). | **present** |
| Dates → ODA board | many → ODA | Nearest three of VC meeting, sheet expiry, promise deadline, churn countdown, month close (`oda_view.gd:1281-1322`). | **present** |
| Overtime → ODA chip and night tint | Ekip → ODA | `oda_view.gd:1348-1357`, and an active block forces night (`:835-836`). | **present** |
| Investor appetite → three surfaces | Finans → Arayüz | Finance title row, Product traction strip, ODA goal card. Ch. 08 §5 retires the chip. | **present, being replaced** |
| Onboarding payload → run state | Arayüz → all | `initialize_run(draft)` reads nine keys (`game_state.gd:684-716`); `subgenre_id` is never sent and defaults to `ai`. | **present** |
| Theme stamp guard | Arayüz → build | `THEME_STAMP` compared against the baked value on every debug boot (`ui_tokens.gd:83`, `main.gd:73-78`). | **present** |

---

## 4. Depends on / depended on by

**Arayüz depends on:** **Ekip** (the Kişisel contents, the badge producers), **Ürün** (the DESTEK bar state, the Konsept screen that onboarding must host), **Operasyon** (four of the seven badges), **Event** (the log that moves into Kişisel), **Finans** (the Frank note that replaces the appetite chip).

**Depended on by:** every module, since ch. 12 §8 rules that a system with no surface row is not shippable.

**Can it be decided alone?** The rail is a self-contained decision and should be made **early** — it is cheap, and it stops other modules building toward tabs that are going away. Onboarding waits for Ekip (the skill model) and Ürün (the Konsept step). Badges wait for everyone.

---

## 5. UI work

**Rail**
- Five active tabs in the order Ürün · Satış · Ekip · Finans · Kişisel; two locked-visible, Pazarlama and Ar-Ge, muted with a Coming Soon badge and no interaction; no Operasyon, no Events.
- Decide whether a locked tab shows a one-line teaser of what it will contain (§9).

**Kişisel (new page)**
- Founder card, energy bar, current assignment, net worth with its all-time peak — contents specified in `03_ekip.md`.
- **The events log**, relocated from the Events tab (§1, [WORKING] whether it lives here or in the right panel — and the right panel no longer exists).

**Badges**
- The number stays; add **click-to-row**, which is the half that makes a badge useful.
- Seven kinds, each named to its producer, so it is obvious which are waiting on which module.

**Onboarding**
- Three beats: founder creation (name, origin, skills as an archetype pick or a point distribution) → first product Konsept (market, subtype, features, price draft, team = the founder) → Frank intro **inside the flow**, as the closing beat.
- Decide where company identity and portrait go — they are extra today, and the chapter does not mention them.

**ODA**
- No change requested. The monitor needs a DESTEK face once that phase exists, which is the only room work the GDD implies.

**TopBar**
- No change requested. If the extras stay (burn, net, brand, reputation), the chapter list should be amended to say so.

---

## 6. Sizing

| Item | Size | Assumes |
|---|---|---|
| Remove the `ops` tab | hours | mind the hard-coded badge indices |
| Add `marketing`, lock it and `rnd` with Coming Soon | hours | one new icon, one CSV row |
| Reorder the rail, Kişisel last | hours | badge indices must move with it |
| Relabel İK to Ekip | hours | |
| ~~Frank portrait asset~~ — the asset was always on disk; the gap was the event card's inability to render one, closed 2026-08-20 (temizlik turu §3.4) | — | |
| Fix the double MentorIntroModal mount and the load-path mount | hours | |
| `CLAUDE.md` Fast 4x line | hours | director-owned text |
| Remove the `events` tab and re-home its three consumers | a day | the log must land in Kişisel in the same pass |
| Click-to-row on badges | a day | signal payload plus a receiving convention per tab |
| **Kişisel page** | several days | contents owned by Ekip |
| **Onboarding rework** to the three-beat flow | several days | needs the Konsept screen and the new skill model |
| Badge producers | — | each owned by its module |
| Main menu with the ODA night scene | several days | not currently scheduled anywhere |

---

## 7. Open questions for the director

1. **Does the events log live in Kişisel or elsewhere?** (§9.) The chapter marks it [WORKING] and offers the right panel as an alternative — but the right panel is retired, so Kişisel is effectively the only candidate.
2. **Do locked tabs show a one-line teaser** of what they will contain? (§9.)
3. **Onboarding screen design** (§9) — a separate pass, but the flow and the payload are fixed by §5.
4. **Does the company-identity page survive?** Company name, logo style and slogan are a full page the chapter does not mention, and the logo is used across the shell and the ending newspaper.
5. **Does the portrait grid survive**, and should it be a hard gate? It is currently the only required field on page 1, while the founder name is optional.
6. **Do the TopBar extras stay** — burn, net, brand, reputation, phase dots, the offer countdown? They are useful and they are not in §2 list.
7. **Is a main menu in scope?** §6 names an ODA night scene for it; nothing exists, and TEKRAR DENE currently relaunches the process.
