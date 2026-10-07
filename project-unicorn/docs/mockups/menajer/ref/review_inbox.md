1. **BLOCKER: Browsing other windows while the clock is held lets the player act, and several actions break under a held clock.**
   - **What's wrong:** The plan says the player "başka pencereleri açabilir" while a decision waits (plan:192). It never says what is locked during that time.
   - **Evidence:**
     - Everything stays interactive under a paused tree: GameShell is `process_mode=3` (GameShell.tscn:12) and so is OfficeView (OfficeView.tscn:38-39).
     - Several entry points do not check for an active card:
       - Hunt "Masaya otur" emits `term_table_requested` directly (hunt_tab.gd:420).
       - The Sales buttons call `EventGate.request` (sales_tab.gd:454, :464).
       - "Görüşmeye git" runs `_on_pitch_requested`, which emits `tab_changed("")` (this closes Olaylar) and rings the phone (main.gd:1997-2005).
       - Office move (office_hud.gd:40); HR confirms and Training/WorkHours.
     - A held clock makes `_can_step()` false (time_manager.gd:142-143), so `_run_batch` breaks out (time_manager.gd:175-177). A meeting or table opened during the gate therefore loses its hours silently in `end_sitting` (main.gd:2139-2146, 2416-2424).
     - The trip's request to run the tree is swallowed (main.gd:2060; time_manager.gd:297).
     - A Series A signing could end the run with a card still active.
     - The player can also make the card's subject invalid (engine.gd:467-472) or unlock its options before answering.
   - **Correction:** Add a "Karar beklerken salt okunur" rule to Faz E/Kapı:
     - Use one predicate, `EventGate.active_id() != ""`.
     - WindowFrame puts an input shield over every non-Olaylar page body. Wheel and scroll pass through; buttons are blocked.
     - OfficeView: the person click opens the dossier read-only; the move button and the map are disabled.
     - main.gd refuses `pitch_requested`, `term_table_requested`, `confirm_requested`, sales/sprint requests and PanelLayer mounts while a card is active.
     - Add this to Onay noktaları.

2. **MAJOR: Sittings opened by a card play frozen.**
   - **What's wrong:** `open_term_table` and `open_seed_table` (seed_offer.json, sheet_decision.json) run inside `resolve`, before `event_resolved` (effects.gd:419-440; engine.gd:485-505). `_leave_office` asks for `last_running_speed` while "event" is still held, so the request is swallowed and the tree stays paused.
   - **Evidence:** People freeze (`office_people.gd:201`). The trip then waits out its timeouts: EXIT_S 1.5 s and SEAT_S 8 s (office_travel.gd:56, :69).
   - **Correction:**
     - Release the "event" hold in `_claim_pre_dialogue_speed()` (main.gd:1954-1957). Once finding 1 is in place, only card-originated sittings reach that function.
     - `_on_event_resolved` releases the hold in every branch before `_restore_speed`.

3. **MAJOR: The hidden-decision case is misidentified.**
   - **What's wrong:** The "modal taşıyıcı" for meeting, term table and trip (plan:196) and the A4 mock "pencere gizliyken karar" (plan:89) cover a state that cannot happen.
   - **Evidence that it cannot happen:**
     - No sitting system calls EventGate (grep over vc_pitch, sales_meeting, negotiation and term_sheet_table systems).
     - Sittings sit at speed 0 (main.gd:2065); their hours run in transit; and pumps during transit are deferred (main.gd:1913-1915, 2088-2090).
   - **The real hidden cases:**
     - PanelLayer residents run with a live clock and a full scrim on layer 9, above WindowLayer: TrainingModal (training_modal.gd:15-16, 27), WorkHoursModal (work_hours_modal.gd:20, 50), HRAtlasModal (hr_atlas_modal.gd:37-39), HRPopover. Guard 3 gives them Esc (game_shell.gd:71-74). A card that arrives under one of them opens Olaylar invisibly.
     - The milestone paper (finding 4).
   - **Correction:**
     - Delete the carrier and its mock.
     - When the gate opens, main frees PanelLayer children before `tab_changed("events")`.

4. **MAJOR: Milestone ordering cannot be "korunur".**
   - **Evidence:**
     - Today `move_child` places the paper under `_event_modal` inside ModalLayer (main.gd:2356-2360).
     - With the decision in WindowLayer, the paper always covers it, and ANA MENÜ refuses to save for a decision the player cannot see (main.gd:2380-2385; save_manager.gd:74-77).
     - Smoke `milestone_paper_under_card` pins `_event_modal` (endgame_smoke.gd:11263-11313).
   - **Correction:**
     - `_on_milestone_reached` stores the data and defers while `EventGate.active_id() != ""`, then mounts from `_on_event_resolved` when `!has_pending()`.
     - Rewrite the smoke case to assert the deferral.

5. **MAJOR: Paper close is underspecified, and the obvious implementation breaks Sprint.**
   - **Problems:**
     - **(a) Provenance.** The active card may be a paper opened from the desk (engine.gd:585-601) or a queued last-warning interrupt with the same key (engine.gd:120-130). EvQueue does not record which (queue.gd:99-106).
     - **(b) Signal reuse.** Reusing `event_resolved(id, -1)`, which is already the entity_gone path (engine.gd:470), would make `SprintSystem._on_event_resolved` clear the decision with no choice made (sprint_system.gd:524-527).
     - **(c) Retry.** Autosave retries only on `event_resolved` (save_manager.gd:330-333).
     - **(d) Rebuild.** `on_page_closing` also fires on language/palette rebuild (window_layer.gd:54-55, 64-66, 133-139). It would close the paper and give the speed back under Settings.
     - **(e) Browsing.** If selecting a row opens the paper, just browsing stops time and blocks saving.
   - **Correction:**
     - `EvQueue.set_active(id, ctx, from_desk)`, with only `open_paper` passing true.
     - New `EventGate.set_aside() -> bool`: works only when `from_desk`; calls `clear_active()`, writes no history, emits a new `EventBus.event_set_aside(id)`, then `pump()`. main and SaveManager listen to it.
     - Paper rows show a read-only preview; an explicit "Cevapla" calls `open_paper`.
     - Esc, × or a tab switch on an open paper calls `set_aside`. On an interrupt it only closes the window.
     - A same-id rebuild must not call `set_aside`.

6. **MAJOR: Loading with queued cards can resolve a card twice (existing bug the inbox makes reachable).**
   - **Evidence:**
     - The night autosave runs while pump is deferred (engine.gd:415; time_manager.gd:371; save_manager.gd:318-322), so saves carry queued last-warning K beside desk paper K.
     - After load nothing pumps (save.gd:38-59; time_manager.gd:283-287).
     - `open_paper(K)` does not dequeue K (engine.gd:598-600), and `resolve` does not remove queued K (engine.gd:494-495). The pump then shows K again and its effects apply twice, breaking I2.
   - **Correction:**
     - `open_paper` and `resolve` call `EvQueue.take(key)`.
     - Add `EventGate.pump()` and have main call it after `_mount_shell` on load.
     - Add an engine smoke case for this sequence.

7. **MAJOR: The non-pausing weekly summary needs an engine change, and its body cannot be stored.**
   - **Evidence:**
     - Every non-paper card is queued (engine.gd:382-385), even though the presenter says info has no queue (presenter.gd:9-11).
     - The body uses live `{seam:sales.weekly_closes}` and `{seam:sales.account_count}` (weekly_summary.json). These return prose in the current locale (sales_ledger.gd:374-386), and the wrong-week defect is already recorded as ACIK 79(2) (ACIK_KARARLAR.md:1074-1077).
   - **Correction:**
     - SalesRepSystem posts `{kind:"sales_week", day, rows:[{company, star, seats, price, mrr}]}`, snapshotted from `sales_weekly_report_rows`, rendered by a formatter that takes the rows.
     - In the same commit delete `sales.weekly_summary`, the `sales.weekly_closes` seam and `--b2b-shot=weekly` (main.gd:549-562).
     - Update `hotfix_weekly_summary_rows` (endgame_smoke.gd:4678-4713; it also pins the StarRating glyph).
     - Put ACIK 79(2) and the card deletion in Onay noktaları.

8. **MAJOR: The period summary payload is translated text.**
   - **Evidence:**
     - `_build_summary_data` translates title, range, runway_text, caption, highlight, footer, frank_line and phase_name (summary_system.gd:175-202).
     - The highlight is free text (game_state.gd:165, 400-404) from five callers: angel_round_system.gd:52, endings_system.gd:117, phase_gate_system.gd:87, seed_round_system.gd:182, sprint_system.gd:630.
   - **Correction:**
     - Store numbers plus `{freq, start_day, last_day, runway_months, shutter, highlight:{key,args}, frank_key}` and render the rest at display time.
     - `submit_month_highlight(key, args, priority)` across the five callers.
     - Update the fixture (summary_system.gd:213-235) and the smoke at endgame_smoke.gd:1175-1189.

9. **MAJOR: Pause behaviour of the auto-opened summary and intro is unstated, and a hold would stall the night.**
   - **Evidence:**
     - `summary_ready` fires inside `skip_night`'s batch (summary_system.gd:93; time_manager.gd:161-169, 369). A hold breaks the batch midway (time_manager.gd:175-177). Today speed 0 is used (main.gd:2312-2313).
     - The `_pre_summary_speed` / `_summary_modal` branches must go: main.gd:1918-1920, 1946-1948, 2372-2373.
     - Guard 2 no longer blocks Space under the intro (game_shell.gd:66-69; main.gd:1858-1860).
   - **Correction:**
     - Write: "özet asla `hold_clock` almaz; saati durdurmaz (ya da yalnız speed 0)".
     - Auto-open never takes the selection away from an active decision.
     - The intro is posted in the non-restore branch of `initialize_run` (game_state.gd:876-886).
     - Add the intro's pause to Onay noktaları.

10. **MAJOR: Past-decision rows lose names and render with today's data.**
    - **Evidence:**
      - The record is written after the effects (engine.gd:485-492), but `churn_customer` removes the account (effects.gd:260) and `employee_leaves` removes the person (effects.gd:340-345; character_registry.gd:548-556) first.
      - Variants and `{seam:}` resolve live (presenter.gd:155-172, 184-199); many seams are prose strings (seams_ported.gd:56-90).
      - The `b2b_retain_discount` and `b2b_expand` deltas carry no amount (effects.gd:473-491).
      - The B2C name is key+arg (presenter.gd:86-89).
    - **Correction:**
      - Snapshot slot names at the top of `resolve` and before `run_expire` (engine.gd:105). Store proper nouns as text and B2C names as `{key,arg}`. Pass them to `record` as an optional `names`; add §7.1 and §27 notes.
      - Rows render title + chosen option + delta chips. The body is never re-rendered.
      - Add the realized amounts to those two deltas.
      - Filter out `dropped` and `forced` rows.

11. **MAJOR: The plan stores decisions a second time beside EvHistory.**
    - **Evidence:** The planned store holds "seçenek ve sonuç" and a "geçmiş" kind (plan:179-181, 187). That copies the canonical §7 record and needs a writer outside its owner (CLAUDE §6).
    - **Correction:**
      - The inbox is a view over `EvHistory.rows()`, the active card, EvPapers and derived items.
      - A GameState `inbox` array holds only non-engine messages, written only by a static `InboxSystem.post/mark_read` that emits `inbox_changed`.
      - Ids are deterministic (`kind:day:seq`, `h:<index>`).
      - The capacity limit applies only to that array and never evicts unread messages.

12. **MAJOR: The reading pane takes its context from the active card.**
    - **Evidence:** Locks, chips and targets read `EventGate.active_context()` (event_modal.gd:285-289, 431-432). Previews, history rows and the harness renders (main.gd:568-569, 584-585, 1623-1624) are therefore wrong.
    - **Correction:** `populate(view, context, mode ∈ {live, preview, history})`; only `live` calls resolve.

13. **MAJOR: Moving the single chip builder hits two traps.**
    - **Evidence:**
      - CLAUDE §5 names `event_modal._describe_modifier`.
      - Smoke loads the script by path (endgame_smoke.gd:3516, 10743, 13458).
      - It uses `tr()` in an instance method (event_modal.gd:357-426); `tr()` dies at runtime in a static func.
    - **Correction:**
      - One static home (`EvChips.describe(item, ctx, names, is_delta)`) using `TranslationServer`, with `SILENT_VERBS`, `FIXED_CHIPS` and `_source_tag` moved there.
      - Update the three smoke pins and CLAUDE §5 in the same commit, and add §5 to Faz G.

14. **MAJOR: Esc can now reach the system menu during a decision.**
    - **Evidence:**
      - Today that cannot happen (main.gd:2196-2197; game_shell.gd:66-69).
      - Now Esc closes Olaylar (window_layer.gd:96-103), and the next Esc opens the menu.
      - "Kaydet ve çık" quits without saving when a card is active (system_menu_modal.gd:76-80).
    - **Correction:** While a card is active and no window is open, Esc reopens Olaylar with the card.

15. **MAJOR: `goto_tab` clashes with the auto-open.**
    - **Evidence:**
      - 7 live cards use it, and the effect emits `tab_changed` during resolve (effects.gd:389-395).
      - The next card then pumps (engine.gd:507) and Olaylar replaces the destination; only one primary window exists (window_layer.gd:61-78).
    - **Correction:** main keeps the goto target from the resolve and reissues it when the gate clears.

16. **MAJOR: Where the hold lives decides whether harnesses and probes still finish.**
    - **Evidence:**
      - Shot shells are not wired (main.gd:455-460 vs 1875-1894), yet real-clock harnesses run in them (main.gd:385-406).
      - A hold taken by a shell component would freeze those runs.
      - The probe drains via `active_id()` (run_probe.gd:439-469) and counts FIRE lines from `event_triggered` (run_probe.gd:178-180).
    - **Correction:**
      - Write: "`hold_clock('event')` yalnız main'in bağlı handler'ında; motor `modal_requested`'i korur".
      - Add to Faz E Doğrulama: a `--run-log` diff whose only expected change is the weekly summary FIRE/PICK/TALLY lines, and a check that `--tempo-probe=2:shell` finishes.

17. **MINOR: The rail badge needs more refresh triggers.**
    - **Evidence:** Papers also land on hourly ticks (engine.gd:78-86) and from tab requests. `desk_papers.gd:57-64` already has the same stale-badge problem.
    - **Correction:**
      - Add `EventBus.desk_changed` from EvPapers place/remove/take_expired.
      - Define the badge count.
      - Hide the gate slot when `!run_active`.

18. **MINOR: Ar-Ge leftovers.**
    - **Evidence:** `take_first_note_modal` (rnd_system.gd:607-614) and `_rnd_card_queue` (main.gd:2220-2246) become dead; Ar-Ge GDD §6.1 and §5.8 change.
    - **Correction:**
      - Read state stays with `RnDSystem.mark_note_read` (rnd_system.gd:597-602).
      - Post the `compose_note` dict at `_tick_note` (rnd_system.gd:489-500).
      - Add GUNCELLEMELER entries.

19. **MINOR: The "Esc çözmez" smoke case is a UI test.**
    - **Evidence:** CLAUDE §10 says UI is verified by visual acceptance, not smoke.
    - **Correction:** Use engine smoke cases instead:
      - `set_aside` writes no history row;
      - info never becomes active;
      - names survive churn;
      - no double resolution (finding 6);
      - the inbox store survives a save/load round trip.

20. **MINOR: Queued and derived rows.**
    - **Evidence:** Queued cards are dropped silently at pump (engine.gd:427-433).
    - **Correction:**
      - Show queued cards only as a count.
      - Reminders get no date and no unread state.
      - Hide the expansion reminder when its paper exists (desk_papers.gd:47-50).

21. **MINOR: Desk paper titles show a raw id once the person leaves.**
    - **Evidence:** presenter.gd:83-84, 121; ACIK 13 is still open.
    - **Correction:** Freeze names in `EvPapers.place` (papers.gd:22-33).

22. **MINOR: Forcing the Olaylar window open loses page state.**
    - **Evidence:** `tab_changed("events")` frees the current primary and detail windows (window_layer.gd:61-68, 124-130).
    - **Correction:** If Olaylar is already the primary window, call `select(id)` instead of re-emitting `tab_changed`.

23. **MINOR: Approval points and doc list.**
    - Onay 14 is already mandated by §11.4.
    - Add to Onay noktaları: findings 1, 7, 9 and 14, and the Ar-Ge change.
    - Docs:
      - motor md §7.1, §11.1, §11.3 ("tek etkin karar") and §27;
      - ch12 §9: the events log location is now settled;
      - CLAUDE §5;
      - HARITA.

24. **MINOR: Keep text-carrying channels out of the inbox.**
    - **Evidence:** `headline_added(source, text)` (event_bus.gd:219) and the `EvTicker._held` text (ticker.gd:20-26) are frozen-language text.
    - **Correction:** If arc fade notes should appear, store `{key, context}` instead.

25. **MINOR: Harness flags must be repointed or deleted when the modal scenes go.**
    - **Evidence:** EVENT/MENTOR/MONTH_SUMMARY/RND consts and shots, plus F11 (main.gd:15-27, 495-586, 960-1011, 1615-1624; game_shell.gd:93-95).
    - **Correction:** In the commit that retires the scenes, point them at the pane's `preview` mode or delete them.