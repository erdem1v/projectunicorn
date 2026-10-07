1. **BLOCKER: deleting the Lucide licence would leave Lucide icons in the game.**
   - **What is wrong:** Faz G deletes "Lucide ikonları ve lisansı" (plan:252-254). Only the rail icons get replacements, through A2 (plan:65-66). The nine office head icons are also Lucide glyphs, and they keep using the licence.
   - **Evidence:**
     - `docs/HARITA.md:306` says the rail icons and the office head-icon glyphs are Lucide under ISC, with the licence at `assets/icons/tabs/LICENSE-lucide.txt`.
     - The nine files are `assets/art/office/icons/{code,coffee,design,food,meeting,phone,research,test,wc}.svg`. They are drawn as Sprite3D (`office_actor.gd:9-28`).
   - **Correction:** Add the nine office activity glyphs to the A2 icon family and to approval item 16. Delete `LICENSE-lucide.txt` only in the commit that replaces the last Lucide-derived SVG, or move it to `assets/art/office/icons/` and keep it. Update HARITA:306 to match.

2. **MAJOR: open ACIK items are closed or acted on without a per-item owner ruling.**
   - **What is wrong:**
     - Faz G closes items 61, 65, 73, 74, 88, the unnumbered Chrome item, and the UI parts of 93 and 96 (plan:261-264).
     - Faz B closes 92 and 94 (plan:126).
     - Faz F "Metin düzeltmeleri" edits keys that belong to open items: `DESK_PAPER_GATE_TITLE` is ACIK 68, `HR_TASK_NONE` is ACIK 51 (plan:237-243).
   - **Evidence:**
     - `CLAUDE.md:33` says agents do not touch open items; approved ones are applied one by one.
     - 88 is a work-hours chevron cap and a text question, not visual language (`ACIK_KARARLAR.md:1192-1206`).
     - 94's subject is "single room, single tower"; only its last clause is about the portrait (`:1222-1230`).
     - 73 points at the deleted `negotiation_scene.gd` (`:1649-1659`), so it needs rewriting, not closing.
   - **Correction:**
     - Move every ACIK closure into "Onay noktaları" as its own item, with the A/B option the plan proposes.
     - Amend only the portrait clause of 94. Rewrite 73.
     - Make the dash-key and no-data-mark fixes depend on rulings for 51, 68, 35 and 95.

3. **MAJOR: the approved mockups would live only in a session scratchpad.**
   - **What is wrong:** Faz A puts every mockup in the scratchpad (plan:51-52). Faz F builds "onaylı maketten" (plan:218), probably across several sessions and Workflow agents. The scratchpad is per-session and temporary.
   - **Evidence:** The task's own scratchpad path is session-scoped (`…/0e406678-…/scratchpad`). The spec citations point into a scratchpad `build2.py`.
   - **Correction:** Name a durable, gitignored or untracked home for the approved artifacts in Faz A, for example `docs/mockups/menajer/` with a `.gdignore` like `urun_rev7`. Include `build2.py`, the PNGs per state, the token sheet and the contrast table. Faz F agents must cite those paths.

4. **MAJOR: the rival-world PRD (c706349) plans UI on the vocabulary this plan deletes.**
   - **What is wrong:** The plan only says rival UI "yeni dilde kurulur" (plan:47-48). It does not deal with any of the PRD's concrete UI.
   - **Evidence:**
     - The RAKİPLER view is specified with `FolderWindow`, `PaperCard`, `PaperCardOpen`, `Stamp`, `StampGrey`, `DataMono` and `TickerLabel` (`PRD_RAKIP_DUNYASI.md:540`). Faz G deletes these (plan:252).
     - An optional 9th rail tab (`:517`) touches TABS, LeftTabs, the icons and the `rail_tabs_match_scene_order` smoke case.
     - There are new shots `--rivals-shot=<9 states>` (`:538`) and `--meeting-shot=rival` (`:585`).
     - A `change_salary` branch is added to `event_modal._describe_modifier` (`:637`, `:1297`), the file this plan retires.
     - `rival.poach_offer` is an interrupt with no Frank speaker (`:609-626`) and becomes an inbox decision.
     - `mentor_advisory_changed` adds Frank lines in A2 (`:597-607`).
     - Schema v16 with `_migrate_16` (`:899-901`) collides with any inbox migration.
     - The PRD uses `rival_world.engine.inbox` as an internal name (`:176`, `:196`), which clashes with the player "inbox".
   - **Correction:**
     - Add a "Rakip dünyası etkisi" section.
     - Mock the RAKİPLER view states in A4 (Ürün) and decide the rail slot for a 9th tab.
     - Amend PRD §8.3 and §13 item 42 to the new variation names.
     - Fix which task lands `_describe_modifier`'s new home first.
     - Give the GameState store a non-"inbox" code name, or rename the PRD's field.
     - Order the save-schema changes.

5. **MAJOR: the migration method breaks two binding CLAUDE rules for weeks.**
   - **What is wrong:**
     - Faz C keeps the old variation family next to the new one until Faz G (plan:143-145). `CLAUDE.md:128-129` says replacing code deletes the old code in the same commit.
     - Every dark window from Faz D on breaks `CLAUDE.md:113-119` (cream body, Chrome list). That section is rewritten only in Faz G (plan:256-257).
     - GUNCELLEMELER has no ch12 §7 entry, while the .docx still mandates "mono type… no filled hover" (theme report §0.4).
   - **Correction:**
     - Rewrite CLAUDE §7 and add the GUNCELLEMELER ch12 §7 entry in the first Faz C/D commit, not in Faz G.
     - Per screen in Faz F, delete in the same commit the variations and tokens that only that screen used. Faz G then removes only what is left.
     - State explicitly that a mixed cream/dark game between commits is an accepted interim state, and get Erdem's yes as an approval point.

6. **MAJOR: phases depend on things that later phases build.**
   - **What is wrong:**
     - Faz D builds the top-bar "Cevap bekliyor" gate slot (plan:152-154) before Faz E defines the gate.
     - Faz D introduces a "tek bileşen" shared window header and says pages stop drawing their own (plan:162-164). Pages are migrated only in Faz F, so between D and F every page has two headers or none.
     - Faz B wires Frank's portrait into "kutu göndereni, okuma bölmesi" (plan:119-121), which do not exist until Faz E and F.
   - **Correction:**
     - In Faz D, either bind the gate slot to today's signal (`EventGate.has_pending()`, which is true while the EventModal is up) or defer the slot to Faz E.
     - Move header adoption into each screen's Faz F step.
     - In Faz B, list only consumers that exist then: EventModal 24 px strip, MentorIntro 48 px, MonthSummary 40 px, notice stack, CharacterStep, CompanyStep, Kişisel. Wire the inbox consumers in Faz E.

7. **MAJOR: the new shell geometry does not fit the Ürün window, and nothing covers the gap before Faz F step 3.**
   - **Evidence:**
     - Today: 1080 − 54 − 34 − 2×16 = 960 px, exactly the product height (`GameShell.tscn:25,33-34,58`; `window_layer.gd:29-33,152-156`).
     - With the new shell: 1080 − 64 − 40 − 48 = 928 px.
     - Product at x = 208 ends at 1632, past the mockup BuildHUD at x 1576. BuildHUD draws above windows, and `window_layer.gd:27-28` relies on product staying left of x ≥ 1540.
     - At UI scale 1.25 the room is about 688 px.
   - **Correction:**
     - Faz D must give interim SPECS for every window so the game stays usable until Faz F.
     - Add approval item 9's sizes for product, sales, finance and rnd at 1080p and 1.25, and cover the BuildHUD overlap.

8. **MAJOR: the newspaper "island" depends on fonts and sizes the plan retires.**
   - **What is wrong:** Decision 8 keeps the paper cream (plan:24-25) and Faz G keeps `PAPER_*` (plan:253). But the paper's faces and sizes are shared tokens:
     - `NewsMeta` uses `mono_label`, which is JetBrains Mono (`build_theme.gd:141`).
     - The paper labels use `SIZE_META` 10, `SIZE_SMALL` 11, `SIZE_BODY`, `SIZE_LEAD` and `SIZE_ED_*` (`:137-143`), all of which the new ladder replaces.
     - Decision 7 limits Source Serif to Frank's words, but the paper is all serif.
   - **Correction:** In Faz C, give the paper its own pinned face and size tokens (serif kept, a non-mono face for `NewsMeta`). Exempt it from decision 7 and from the 12 px floor change, or ask Erdem. Add a paper-unchanged check to the `--ending-shot` acceptance.

9. **MAJOR: the colour-blind acceptance shots cannot be taken; there is no harness flag.**
   - **What is wrong:** Faz F requires shots with colour-blind on and off (plan:244), but no flag exists. Toggling the setting writes `settings.json`.
   - **Evidence:**
     - The main.gd flag list has no colour-blind or palette flag.
     - `SaveManager._is_harness_arg` only matches smoke, `-shot`, audit, probe and run-log (`save_manager.gd:372-378`). A new `--theme-contrast` flag would not be inert either.
   - **Correction:** Add a `--palette=cb` shot modifier (non-persisting, applied through `UiTokens.set_colorblind`) to the missing-flags list in plan:245-247. Name new flags so `_is_harness_arg` matches them (for example `--theme-contrast-audit`), or extend the list.

10. **MAJOR: the EA/full build differences are missing everywhere.**
    - **Evidence:**
      - The ending shows Frank's strip and the Coming-Soon/WISHLIST block only in the demo (`ending_scene.gd:118-121`, `:340-343`).
      - The known problem "EA iflas gazetesinin rayı neredeyse boş" (`ACIK_KARARLAR.md:910-913`).
      - The EA milestone flow: DEVAM ET plus ANA MENÜ (`main.gd:1438-1449`).
      - Pazarlama's `"lock": "ea"` shows in every build (`ui_tokens.gd:353`; the ACIK "EA/tam'da kalan 'yakında' izleri" item, which also has a "— · Tier 2'de" dash row).
      - `CLAUDE.md:172`: the EA flow is played with `--build=ea`.
    - **Correction:**
      - Add these Son ekranı mockup states to A4: demo rail, EA/full rail, milestone (EA), and the bankruptcy variants 1-3.
      - Add the rail with Pazarlama locked per build.
      - Add `--build=ea` to the Faz F visual-acceptance matrix for the ending and the rail.

11. **MAJOR: the engine path for a non-pausing info card is unspecified.**
    - **What is wrong:** The plan says the weekly sales summary "durdurmaz" (plan:207-208) but not how. The card is class `info` with one option, `read_it`. Info goes to `EvQueue` (`engine.gd:384`), and the pump treats it as the active card and blocks the queue.
    - **Evidence:** `data/events/cards/customer/weekly_summary.json` has class `info`, option `read_it`, and a body built from `{seam:sales.weekly_closes}` and `{seam:sales.account_count}`.
    - **Correction:** Specify the engine change. For example: info is admitted straight to the inbox store, auto-resolved on admission (history `resolution` value TBD), never becomes `active_id`, and does not count against the interrupt budget. Write the motor §11.1/§27 note for it, and add a falsified smoke case: "info admission does not set active_id and does not block the pump".

12. **MAJOR: past rows will re-render with today's numbers.**
    - **What is wrong:** The store saves "anahtar + argüman" and freezes names (plan:181), but card bodies also contain `{seam:…}` tokens, which resolve live (`presenter.gd:177-199`). Old weekly summaries and past decisions would show current values.
    - **Correction:**
      - At resolution and admission time, capture every `{seam:}` value and every display name into the row's args. Re-render from the args only.
      - State that the frozen args live in the GameState store, not in `EvHistory`. `EvSave.BLOCK_VERSION` 1 refuses a mismatched block (`core/save.gd:16-17`, `:44-48`).
      - Extend the round-trip smoke case to check a seam-bearing row.

13. **MAJOR: the smoke-case list in Faz E/F/C is incomplete.**
    - **Missing cases:**
      - `audience_pct_modifier` loads `res://scripts/modals/event_modal.gd` by path (`endgame_smoke.gd:10729-10743`).
      - `event_thesis_*` listens to `EventBus.modal_requested` (`:13867-13885`).
      - `hotfix_weekly_summary_rows` pins `StarRating.FILLED` (`:4678-4705`).
      - `milestone_clock_hold` interacts with a new "event" hold (`:11227`).
      - `onboarding_pages_contract` (`:5330`).
      - `settings_language_toggle` (`:2739`).
      - `ending_paper_modes_on_screen` (`:11175`).
      - `look_registry_unique_and_saved` needs a Frank-signature-reserved assertion (`:7988`).
    - **Correction:** Add all of these to the "güncellenecek" list in plan:213-214 and to the per-screen targeted smoke lists. Name the new home of `_describe_modifier` and `SILENT_VERBS` and update all three path-loaders.

14. **MAJOR: retiring StarRating also retires a rule unit, not just a widget.**
    - **What is wrong:** The plan turns StarRating's 11 consumers into number cells (plan:174-175). But ★ is a rule unit in several places:
      - Candidates ★1–3.5 (GUNCELLEMELER Ekip §10.2).
      - Product rev 7 star gates (`GUNCELLEMELER.md:186` item 8).
      - Ar-Ge requirements (`rnd_ui_shared.gd:89,146`).
      - Prospect stars in meetings.
      - Text glyphs in `SalesLedger.weekly_close_lines` (`sales_ledger.gd:399`).
    - **Correction:** Classify each consumer as a skill reading (becomes a number) or a ★ rule unit (keep a glyph token). Add this as an approval point. Keep or move `FILLED` out of the deleted component. Update the `hotfix_weekly_summary_rows` smoke case. If the Ekip ledger drops stars, add GUNCELLEMELER Ekip entries for §13.

15. **MAJOR: the Ar-Ge note's delivery format is sealed in the GDD, and the discovery card goes further than decision 6.**
    - **Evidence:**
      - Ar-Ge GDD §6.1 "Teslim biçimi (MÜHÜRLÜ)": the first report opens once as a modal, later reports live in the Ar-Ge tab, with a silent rail badge and no desk paper.
      - The plan retires `RnDCardModal` entirely, discovery cards included (plan:206-207). Decision 6 names only "Ar-Ge notu".
      - ACIK 23 (`:320-339`) is resolved by this change.
    - **Correction:**
      - Add a GUNCELLEMELER Ar-Ge §6.1 entry for decision 6.
      - Say whether the note also stays readable in the Ar-Ge tab.
      - Add an approval point for moving discovery cards into the inbox.
      - Propose ACIK 23 (and ACIK 8, the `EvTicker` held lines) for closure through approval.

16. **MAJOR: what happens when a decision arrives over a panel, modal, menu or queue is undefined.**
    - **What is wrong:** The plan opens Olaylar in WindowLayer under `PanelLayer` (9) and `ModalLayer` (10) (plan:191-197). It does not say what happens when a card arrives while any of these is open:
      - Atlas (1560 px wide), WorkHours, Training, HRPopover, HRActionModal, Confirm, Settings, SystemMenu, SaveLoad.
    - It also leaves open:
      - Whether Esc with no window open may open the system menu during a pending decision. Today Esc never reaches it over a card (`main.gd:2196-2197`).
      - Queued decisions behind the active one. §11.3 allows one active at a time, and nothing shows queued rows as not yet actionable.
      - Opening a paper while an interrupt is active.
    - **Correction:** Specify each case: close, defer, or bring Olaylar above. Add mockup states for "queued, not yet active", "paper blocked while decision pending" and "system menu during gate, with the save-blocked reason". Add them to the Faz E MCP flow (plan:308-309).

17. **MAJOR: clock behaviour for the intro and the period summary is undefined.**
    - **What is wrong:** Decision 6 auto-opens the intro and the summary (plan:206-207), but the plan does not say whether they pause the clock or what unpauses it.
    - **Evidence:**
      - Today the summary pauses and restores, with a card and the summary sharing restore order (`main.gd:2304-2323`).
      - The intro leaves the clock paused, and its comment ("the build commit… unpauses", `main.gd:1856-1857`) is stale after rev 7.
      - The weekly summary frequency would auto-open the inbox every about 90 s.
    - **Correction:** Add approval points: whether intro and summary pause, whether the weekly frequency auto-opens, and the restore order with the release-note hold, the milestone hold, the event hold and an active card. Write the speed state machine into Faz E.

18. **MAJOR: keyboard and focus are absent.**
    - **What is wrong:** A1 lists only an "odak" state (plan:60). The plan gives no navigation scheme.
    - **Evidence:**
      - Event choices are mouse-only (`focus_mode = FOCUS_NONE`, `event_modal.gd:327-333`).
      - Keys 1-4 are speed keys (`game_shell.gd:55-58`); the meeting panel uses 1-5 and Enter (HARITA:214).
      - The focus ring is deliberately unstyled (`ui_tokens.gd:38-39`).
      - F5/F9 give no feedback (`main.gd:2271-2278`); F5 fails silently while a decision is pending.
    - **Correction:** Specify inbox keyboard use (list up and down, Enter to open, number keys for options or not, Esc semantics), focus order and a themed focus stylebox, quicksave feedback through the unified toast, and the Space/1-4 feedback while held. Add mockup states for these.

19. **MAJOR: the 12 px readability claim does not hold at the minimum window.**
    - **What is wrong:** The goal "en küçük metin 12 px" (plan:7) is in logical pixels.
    - **Evidence:**
      - 100% is always legal (`display_settings.gd:277-279`).
      - At the supported 1280×720 window, stretch 0.667 renders 12 px as 8 px (`effective_micro_px`, `:258-260`; RESOLUTIONS `:24-39`).
    - **Correction:** Define the floor in physical pixels, and decide (approval point) whether 1280×720 at 100% is acceptable or whether the window minimum or a forced scale changes. Update `MIN_READABLE_FONT_PX` together with the renamed micro token.

20. **MAJOR: rail and top-bar overlays break the office overlays, meeting framing and per-office framing.**
    - **What is wrong:** The 184 px rail and the 64/40 px bars now cover the office. Nothing is planned to re-anchor what sits under them:
      - OfficeView Overlay children: NoticeStack, OfficeHud bottom-left (now under the rail and ticker), tooltip, MeetingInvite, city chips and crown, `OFFICE_MAP_LOADING` veil (`office_city.gd:186`).
      - Meeting dock offsets and `MeetingCast.frame_table`.
      - Per-office camera framing (home, ishani, plaza, loft, city, meet).
    - **Correction:** Add these to Faz D, with `--office-shot` and `--travel-shot` acceptance for every office and the meet room.

21. **MAJOR: the icon inventory is incomplete and miscounted.**
    - **What is wrong:** A2 (plan:65-66) leaves out existing icons:
      - `assets/icons/product/*` (11), `assets/icons/build/*` (3), and the root `chevron_*` ×4, `clock`, `lock`, `revert_arrow`, `warning`.
      - The slider and switch SVGs get only a "koyu sürüm" mention.
    - The trait count is wrong: there are 8 HR traits plus `unspecified` (`assets/icons/traits/`, `hr_constants.gd:414+`), not 7. "ray 9 + ayar" double-counts Ayarlar.
    - **Correction:** List every existing SVG with a keep, redraw or delete decision, and correct the counts.

22. **MAJOR: Faz A mockup states miss many live states.**
    - **Missing:**
      - Finans: ozet, artida, uyari, kepenk, signal; gider dökümü; Yatırım hunt and hunt_closed.
      - Ürün: plan; active with a pending decision; beta; B2C MVP; B2B requests; Çeyrek with and without a PM (locked); quarter goal popup; release-note hold.
      - Toplantı: 5 sales, 7 VC and 4 negotiation states; the founder trip road, chips and crown; MeetingInvite ring and postpone toast.
      - Settings: dropdown popups, disabled UI-scale rows with notes, colour-blind toggle.
      - SaveLoad: empty, full, save blocked by an active card.
      - Confirm with 3 buttons. WorkHours at night.
      - Top bar: sprint auto-start chip, runway not "Artıda" (months, red), compact mode below 1600 at 1080p.
      - Shell under the travel veil.
      - Olaylar: single-option Frank beat (readout), Ar-Ge discovery, expiring paper in its last week, departed sender, "{n} karar bekliyor".
      - Kişisel: milestones.
      - Aspect ratios 16:10, 21:9 and 32:9, which are supported (`display_settings.gd:24-39`, stretch "expand").
    - **Correction:** Extend A4 with these, because A5 forbids code before approval (plan:106-107). Say where the seed data comes from for large states (40 people, a long inbox history).

23. **MAJOR: the docs list is incomplete.**
    - **CLAUDE.md:**
      - §5:62-63 names `event_modal._describe_modifier`.
      - §6:66 describes `main.gd`'s "modal montajını"; §6:83-84 "Özet modalı".
      - §12:173-189 shot-flag list (add `--inbox-shot` and the new flags; retire `--modal-shot=mentor|month|rnd-*` and the shell-less `--event-shot`; change `founders`).
    - **HARITA sections:**
      - Onboarding (:274, :281), Finans (:179, :183, :188), Ar-Ge (:131, :137, :141), Ekip (:145 `assets/art/founders/`), Platform, Görüşme paneli (Meeting* variations), Dünya (:230), Olay içeriği (:270), Kayıt (store field), Araçlar (bake tool, contrast flag), Üçüncü taraf (:306, Barlow/Plex OFL).
    - **GUNCELLEMELER:**
      - ch12 §3: BuildHUD above windows (`GUNCELLEMELER.md:343`).
      - ch12 §8 and §9 (.docx): events log in Kişisel; open decision "events log location" and "onboarding screen design".
      - ch08 §4 summary screen (`:265`).
      - ch14 §7 "Frank ve VC yüzeyleri değişmez" (`:377`): the VC sentence also changes.
      - Ar-Ge §6.1 (finding 15) and Ekip §13 (finding 14).
    - **Generated file:** regenerate `docs/EVENT_SIGNAL_MANIFEST.md` (`tools/gen_signal_manifest.py`) if signals change.
    - **Correction:** Add all of these to Faz G (plan:255-266) and to the per-phase Belgeler lines.

24. **MAJOR: product rev 7's pending visual acceptance and text approval are not sequenced.**
    - **What is wrong:** Faz F step 3 re-skins a screen that was never visually accepted and whose text still awaits TR/EN approval. Another session owns its audit files.
    - **Evidence:** `ISLER.md:53-56` (live sprint screen not visually accepted); commits 2b2d9b5 and 1abbb7e "TR/EN onay bekliyor"; ACIK 96; `docs/audits/urun_rev7/NOTES.md`; PRD rev 7 §2 defines the paper/folder layout.
    - **Correction:** Add an approval point: does rev 7 acceptance happen first, or is it folded into the redesign? Amend the PRD's layout section. Batch every case or wording change to the pending rev 7 and meeting (ACIK 95) keys into one TR/EN approval list.

25. **MAJOR: localization and glossary changes are underspecified.**
    - **Glossary:**
      - `localization_glossary.md:10` makes ALL-CAPS binding ("ALL-CAPS surface stays ALL-CAPS in EN"). §1 has KİLİTLİ, ÇOK YAKINDA, DEVAM ET, ANA MENÜ in caps, which conflicts with the mockup's sentence-case buttons.
      - The "FK (avatar)" row (:151) dies along with `UI_AVATAR_INITIALS` (`strings.csv:533`; `MentorIntroModal.tscn:70`, `MonthSummaryModal.tscn:128`).
      - The "Bildirim yığını" meaning changes (:148).
      - The tab name for Olaylar versus "gelen kutusu" is undecided.
    - **Dash keys missed:** `DESK_PAPER_SHEET_TITLE`, `PERSONAL_MS_SHIP_NOTE` (ACIK 68), `VC_B1_*` and `VC_B4_*` (ACIK 95), the steward "—" literal (ACIK 35).
    - **ISLER:** the EN plural twins `DESK_PAPER_ATLAS_TITLE` and `FIN_GOAL_P3_HUNT` (`ISLER.md:32-33`).
    - **New key families:** inbox senders and subjects for non-card items, the empty state, filters and counts (spec §4).
    - **Caps mechanism:** the plan says nothing about how caps are made. Never use `Label.uppercase`. Use `Fmt.upper` only on CSV labels, never on proper nouns. Collapse the `tr_upper` wrapper (`ui_tokens.gd:542`, 40 callers) per `CLAUDE.md:125`.
    - **Correction:** Add these to Faz F's text list and the approval points, plus a glossary §1/§7 rewrite.

26. **MINOR: founder portrait consumers outside the screens will break.**
    - **Evidence:**
      - `office_crowd_probe.gd:236` loads `assets/art/founders/%s.webp` for the `--office-shot=…:founders` sheet (CLAUDE §12).
      - `FounderConstants.PORTRAIT_DIR` and `portrait_path()` hard-code `.webp` (`founder_constants.gd:79,186`).
      - The `look_system.gd:19` comment refers to the webp path.
      - Dead portrait fields `b2b_rep_portrait_rotation_index` and `b2b_last_rep_portrait` (`game_state.gd:216-217`).
    - **Correction:** List these in Faz B. Decide what the founders sheet becomes (the bake tool's preview). Delete the dead fields. SaveCodec ignores unknown keys (`save_codec.gd:74-77`).

27. **MINOR: the alpha mode and sizes of the baked portraits are unspecified.**
    - **What is wrong:** Straight-alpha PNGs (plan:115) break if they pass through `make_bust`/`avatar_bust.gdshader`, which expects premultiplied input. Sizes in use are 24, 32, 40, 48, 64, 96, the 256×320 pane and the 260×325 onboarding card. Mipmaps over-blur and the default filter is LINEAR.
    - **Correction:** Pick one render path and alpha mode per consumer, and bake per-size crops (or justify mipmaps). Add Frank's signature to the PersonBust/LookSystem and CounterpartSystem uniqueness checks and to the `look_registry` smoke case.

28. **MINOR: Frank's text-only surfaces list is short one surface.**
    - **What is wrong:** The VC meeting "quiet" result line is missing from plan:120-121 and approval item 15.
    - **Evidence:** `vc_meeting_adapter.gd:145-154`.
    - **Correction:** Add it.

29. **MINOR: the "≥4,5:1 for every pair" rule contradicts the accepted exemptions.**
    - **What is wrong:** The spec accepts the dimmed "Reddet" at 4.36 and the locked rail at 2.59 (WCAG 1.4.3 exempts inactive controls). Amber also has exceptions the rule ignores: founder ring #f0b429 (`office_constants.gd:116`), the notice "+N" amber, the offer chip, and 79 `ACCENT_DEEP` reads.
    - **Correction:** State the inactive-control exemption in A1 and `--theme-contrast`. List the amber exceptions under approval item 16.

30. **MINOR: the UI Lab is deleted before its reusable code is harvested.**
    - **What is wrong:** Faz 0 deletes the lab (plan:44-45), but Faz C builds `--theme-contrast` and the override migration needs an inventory.
    - **Evidence:** The lab holds the WCAG checker (`build_direction.gd:88-99,667-707`), the `has_font` trap check and the byte-stable `.tres` writer (`:746-785`).
    - **Correction:** Move the deletion to after Faz C, or port those three pieces first. Replace `UI_OVERRIDES.md` with a fresh `--theme-audit` baseline per screen.

31. **MINOR: bar independence is left undecided.**
    - **What is wrong:** ISLER requires a decision on `bar_kit`, `build_bar` and `research_bar` theme independence (`ISLER.md:27-29`). The plan neither decides nor lists it.
    - **Correction:** Add it to Faz D or the approval points, and add the 15 `_draw` components (cash_curve, radial_dial, logo_emblem, segment_bar, value_slider, meeting_ruler, rnd tree, sprint card/quarter, meeting_invite, …) as a migration class that reads tokens and helpers.

32. **MINOR: the proposed "Esc çözmez" smoke case breaks the test rule.**
    - **Evidence:** `CLAUDE.md:147-148` says UI is accepted visually and new smoke is for core logic only.
    - **Correction:** Keep the clock-hold logic case. Move Esc behaviour to MCP visual acceptance.

33. **MINOR: a known font-height quirk can break the 40 px dense rows.**
    - **What is wrong:** With Noto Symbols 2 kept as fallback (plan:135), `Font.get_height` uses the tallest face in the chain for every Label. The mockup's line heights (14/16, 13/16) may not be reachable.
    - **Correction:** Add a Faz C measurement step and limit the fallback to the variations that need symbols if row height fails.

34. **MINOR: performance is measured only for the veil.**
    - **What is not measured:** 7 or more new font files and per-(face, size, tracking) FontVariations; the halo blur shader; count-up animations; first opening of a long inbox list, where PersonBust renders one bust per frame and faces pop in.
    - **Correction:** Add `--render-probe` checks for the inbox and Ekip at 40 people, and cap the variation count.

35. **MINOR: three scope gaps.**
    - **What is wrong:** First-run guidance (`ISLER.md:36-37`), the onboarding load path, and the disabled "Ana menü" YAKINDA button (ACIK "ANA MENÜ sonrası", `:900-903`) are not stated as out of scope, and their current appearance is not mocked.
    - **Correction:** Add them to "Kapsam dışı" by name, and include their current states in the mockups.