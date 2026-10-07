**Review of Faz C/D (theme and shell migration)**

Paths are relative to `project-unicorn/` and plan line numbers refer to `pasted-content-id-37a5-task-ethereal-reef.md`. I only read files.

## Findings

**1. BLOCKER: the strangler has no way to keep base-type defaults apart, and several Faz C items are whole-game changes.**
- **What is wrong.** "A new variation family is born next to the old one" (plan:143-145) only isolates *named* variations. Anything without a variation resolves through the one project theme (`project.godot:50` → `themes/master_theme.tres`). That theme holds:
  - base Label colour `INK` (`build_theme.gd:534`);
  - base Button as the mono ghost with `INK_MUTED` text (`:466-476`, font `:472`);
  - base Panel and PanelContainer with a `CARD_BG` fill and `CARD_BORDER` (`:538,541`);
  - RichTextLabel serif in `INK` (`:543-545`), LineEdit (`:506-514`), ProgressBar (`:547-548`), separators (`:551-554`), tooltip (`:557-560`);
  - the default font and size (`master_theme.tres:1827-1828`).
- **Who depends on those defaults.** Some nodes use them in their `.tscn`:
  - ConfirmModal `CancelBtn` and `AltBtn`, HRActionModal `CancelBtn`, SaveLoadModal `CloseBtn`, five SystemMenuModal buttons;
  - HuntTab `Sep` and LeftTabs `Divider`.
  
  Some controls cannot take a variation at all: the internal scrollbars of the 16 ScrollContainers, OptionButton and PopupMenu popups, and tooltips.
- **What Faz C changes.** Faz C (plan:136-147) changes exactly these globals:
  - renames tokens to role names;
  - recomputes the helpers for a dark ground;
  - adds the new size ladder and moves the readability floor from 9 to 12;
  - retires mono;
  - themes ScrollBar, CheckBox, SpinBox, popups and tooltips as base types.
  
  Each of these hits every screen the moment it lands.
- **Correction.** Replace plan:143-145 with the mechanism in the strategy section below. `master_theme.tres` stays cream until Faz G. Faz C may only add things: new tokens, helpers, fonts and theme file. It may not change an existing token value, size step, helper body, base type or mono role. Move base-type theming, mono retirement, the floor and the helper rewrite to Faz G, or put them in the dark theme only.

**2. MAJOR: a scoped second theme has precedence traps the plan must design for.**
- **Lookup order.** Godot 4.6 checks ancestor themes across the whole type chain before it checks the project theme. The chain comes from the first theme that declares the variation (memory `godot-theme-engine-facts`; `sandbox/ui_lab/README.md:292-298`).
- **Margin collapse.** Say a dark theme defines base `PanelContainer` but not `CardPanel`. Every `CardPanel` inside a migrated window then gets the base box, whose content margin is 0. That breaks layout, not just colour.
- **Font override.** If the dark theme sets `default_font`, `has_font` answers true for every name, so the dark default face replaces every variation's face.
- **CanvasLayers.** Inheritance stops at a CanvasLayer. Children of `PanelLayer` (layer 9) and `ModalLayer` (layer 10) in `GameShell.tscn` never see a theme set on GameShell or on a window.
- **Popups.** PopupMenus parented to a Control inherit from it: `quarter_view.gd:96-100` and the OptionButton popups (`settings_modal.gd:145,267,361`). Tooltips should too, but verify that with a probe.
- **Correction (add to Faz C).**
  - `menajer_theme.tres` is complete: every master variation name (until G), all base types, and the new variations. The same `build_theme.gd` generates it.
  - A validator, ported from `sandbox/ui_lab/core/build_direction.gd:561-600`, fails generation if any master variation is missing.
  - The theme is assigned on these roots:
    - `WindowFrame`, via `frame_options`;
    - every PanelLayer and ModalLayer scene root: HRPopover, Atlas, Training, WorkHours, RnDCard, Confirm, HRAction, Settings, System, SaveLoad, MeetingPanel, TermSheet;
    - TopBar, LeftTabs, NewsTicker and BuildHUDPanel;
    - OfficeView `Overlay`;
    - OnboardingFlow, LanguageGate and EndingScene.
  - Add `--probe-shot` mounted under a dark root.

**3. MAJOR: some theme reads bypass any scoped theme. The plan lists none of them, and the exploration report lists only two.**
- **Reads of `ThemeDB.get_project_theme()`:**
  - `bar_kit.gd:19` (font for BuildBar and ResearchBar);
  - `tabs/product/area_panel.gd:65` (PaperCard alert box);
  - `tabs/product/sprint_ui_shared.gd:135` (AttentionBadge box);
  - `main.gd:86` (stamp check).
- **Read before the node is in the tree.** `hr_ui_shared.gd:229-231` is called from `:224` before the morale row is added, so it always gets master's fill shape.
- **`_draw` code painting UiTokens directly (18 scripts):** hr_assignments, area_panel, quarter_view, sprint_card, sprint_ui_shared, rnd_tree_view, rnd_ui_shared, bar_kit, cash_curve, logo_emblem, radial_dial, segment_bar, value_slider, meeting_panel, meeting_panel_option, meeting_ruler, meeting_invite, office_city.
- **Correction.** Add these to each Faz F screen checklist and to the BuildHUD step:
  - read from the host node once it is in the tree;
  - call `override_bar_fill` after `add_child`;
  - convert `_draw` colours to dark tokens.
  
  Add a per-screen grep gate: no `ThemeDB.get_project_theme` and no cream token names in the migrated files.

**4. MAJOR: ground-independent role names cannot exist while two grounds coexist, and rewriting shared helpers in place breaks cream screens.**
- **Tokens.** Tokens are `const` (`ui_tokens.gd:53-226`), with 560 reads in about 45 scripts. Semantic colour is deliberately never baked into the theme (`:364-367`).
- **Helpers.** The helpers are global (`:412-513`) and called from 25 files. HRUiShared is used by 29 scripts across ending, event, product, R&D, sales, meeting and office overlays. UiFactory is used by 57.
- **Missing helpers.** The plan's helper list (plan:141-142) leaves out:
  - `area_color` and `AREA_SLOT_*` (`:145-150,632-633`);
  - `positive_bg`, `negative_bg` and the `*_rule` accessors (`:384-405`, pastel tints tuned for cream);
  - `seat_ring`, `badge_palette_for_delta`, `delta_color_bright`;
  - `ATTITUDE_*` and `MEETING_SEAT_*`.
- **Palette repaint.** The repaint on `palette_changed` (`window_layer.gd:54`, top_bar, hr_tab, personal_tab, build_bar, research_bar, office_city, notice_stack) must call the dark helpers once each surface migrates.
- **Correction.**
  - Faz C adds dark tokens under distinct names (a `D_*` prefix or a separate block), plus dark helper twins and colour-blind twins. Cream names and helper bodies stay unchanged until G.
  - Faz G renames the dark tokens to the final role names (a mechanical step) and deletes the cream ones.
  - Shared kits get dark entry points: UiFactory, HRUiShared, RnDUiShared, DeskPapers, HRPopover, and the Confirm and HRAction hosts. Each caller switches in its own screen's commit.

**5. MAJOR: mono retirement and the new size ladder cannot land in Faz C (plan:135, 139).**
- **Mono is everywhere in master.** It is the face of base Button (`build_theme.gd:472`) and of SectionLabel, MicroLabel, TabLabel, Metric*, Chrome*, DataMono* and Stamp* (`:63-143, 328-350`).
- **Direct preloads.** `value_slider.gd:13`, `star_rating.gd:15` and `hr_action_modal.gd:16-17` preload the mono `.tres` files. Deleting them fails `all_scripts_load`.
- **Sizes.** Changing `SIZE_*` in place (`ui_tokens.gd:246-253`) resizes every cream screen. That includes the TopBar's fixed 104/104/210 px widths and the rail's 76 px TabLabel slot.
- **Correction.**
  - plan:135 becomes: new faces added; mono stays for the cream family; mono is deleted in G with its last consumer.
  - plan:139 becomes: the new ladder is new constants; `SIZE_*` is untouched until G.

**6. MAJOR: the readability floor change is either a no-op or a regression, and it does not deliver "12 px".**
- **How the floor works.** `MIN_READABLE_FONT_PX` is 9, the same as `SIZE_MICRO` (`display_settings.gd:53-57`). A step is allowed when `SIZE_MICRO × step × stretch ≥ floor` (`:257-260, 273-281`), and 100% is always allowed (`:279`).
- **Both values move together.** If the floor and the smallest token both become 12, the ladder behaves exactly as before.
- **Only the floor moves.** If the floor becomes 12 while 9 px tokens still exist, the 90% step needs about a 1600 px tall screen and 75% needs about 1920 px. Both are lost at 1440p, where they work today.
- **12 px is not physical.** At 1280×720 the stretch factor is 0.667 (canvas_items/expand, `project.godot:41-42`). A 12 px logical text draws at 8 physical px, so plan:7 ("en küçük metin 12 px") does not hold on screen.
- **Correction.** The floor stays tied to the smallest token in use. It changes only in G, when MICRO through SMALL are deleted, and `effective_micro_px` is repointed to the new smallest step. Add an approval point asking Erdem whether "12 px" means logical px. A physical floor at 1280×720 would collide with `_fits_chrome`, which blocks every step above 1.0 there (`:294-298`).

**7. MAJOR: the 1280×720 window never triggers the narrow rail or compact top bar. The real worst case is 1536 logical px.**
- **Why.** With expand stretch, logical width is 1920 divided by the UI scale, whatever the window size. The TopBar goes compact when `get_viewport_rect().size.x < 1600` (`top_bar.gd:13,88`). A 1280×720 window at 100% therefore lays out at 1920×1080.
- **Narrowest case.** The narrowest logical width is 1536: 1.25 scale on 16:9 or 16:10. `_fits_chrome` divides the window by the step and ignores stretch (`:297`), so 1600×900 at 1.25 is also 1536.
- **Atlas.** HRAtlasModal is 1560 px wide (`hr_atlas_modal.gd:25`), which is wider than 1536.
- **Correction (plan:62-63 and plan:303).** Key layout modes to logical width. The shot set becomes:
  - 1920×1080 at 1.0;
  - 1920×1080 at 1.25 (1536×864);
  - 1920×1200 at 1.25 (1536×960);
  - 2560×1080 at 1.0;
  - 1280×720 at 1.0, kept only as a physical-legibility shot.
  
  Add Atlas to the 1.25 acceptance list and fix the `MIN_CHROME_VIEWPORT` comment.

**8. MAJOR: putting the rail over the office breaks the office framing and the office overlays, so "ofis kadrajı bugünkü kalır" is false as written.**
- **Framing.** CenterViewport is today what is left of the MidRow HBox, 1836×992 (`GameShell.tscn:28-47`). Taking the rail out widens the SubViewportContainer (`stretch=true`, `OfficeView.tscn:56`). `OfficeCamera.fit` centres on the full view and zooms by its aspect ratio (`office_camera.gd:36-52`). With a 184 px rail, the office ends up about 92 px left of the visible centre, and its left edge is hidden under the rail.
- **No re-fit.** `_fit_once` fits only once (`office_view.gd:157-162`). Toggling the rail mode or changing the UI scale never re-frames the office.
- **Overlays under the rail.**
  - The move button (`office_hud.gd:87`) and the city map panel (`office_city.gd:278`) are anchored bottom-left and land under it.
  - The invite card and the person tooltip clamp to the full view (`meeting_invite.gd:155`, `office_view.gd:123`).
  - BuildHUD's drag clamps to the CenterViewport rect (`build_hud_panel.gd:88-94`).
- **Hard-coded geometry.**
  - `game_shell.gd:13` uses the path `$MidRow/CenterViewport`.
  - `window_layer.gd:151-164` places windows with a symmetric 16 px `EDGE` and `size - corner*2`.
- **Correction (Faz D).**
  - Add a seam `OfficeView.set_safe_rect(Rect2)`. The camera fit and frame use it (offset the target or `Camera3D.h_offset`), and Overlay takes its left inset from it.
  - WindowLayer insets become asymmetric and follow the rail's live width through its `resized` signal.
  - BuildHUD clamps to the safe rect.
  - The rail is opaque.
  - Otherwise keep the rail in the HBox and make office reframing an explicit approval point.
  - Verify with `--office-shot` for all four offices and the city map.

**9. MAJOR: the Faz D window insets put Product and Finance under BuildHUD.**
- **Evidence.** BuildHUD is the last child, drawn above the windows, with its left edge at x ≥ 1540 (`BuildHUDPanel.tscn` `offset_left -380`; `window_layer.gd:27-28,142-146`). Windows starting at x = 208 put Product's right edge at 1632 and Finance's at 1618. BuildHUD's decision row takes mouse input (STOP), so it covers live controls until Faz F resizes the windows.
- **Correction.** In the same Faz D commit, trim `SPECS` for product and finance or move BuildHUD. Do not defer this to the mockup decision (plan:165).

**10. MAJOR: a frame-level title component in Faz D double-titles every page that has not migrated yet.**
- **Evidence.** Each page draws its own heading today (`window_frame.gd:1-3`). Adding a frame title for all windows in D (plan:162-163) shows two titles on seven pages until their Faz F step.
- **Correction.** Make it opt-in through `frame_options` (`window_frame.gd:16-21`) with `title`, `kpi` and `theme` keys, off by default. Each F step turns it on and removes the page's own heading in the same commit.

**11. MAJOR: no gate catches collateral damage to screens that have not migrated, and the existing audit misses the margin-collapse failure.**
- **Evidence.** The C/D gates (plan:300-304) cover the stamp, contrast, shell shots and three smoke cases only. `--theme-audit` is deterministic (`main.gd:1032-1043, 1074-1129`). Its `_audit_stylebox` prints only background, border, width and radius, not content margins, so finding 2's failure would pass. Hashing PNGs is unreliable because the office animates.
- **Correction.**
  - On every commit, `--theme-audit` output for every tab and modal that has not migrated must equal the previous commit's.
  - Extend the audit to print content margins, minimum size, and which theme resolved each item.
  - Run `all_scripts_load` on every C, D and F commit.

**12. MAJOR: the THEME_STAMP rule ignores a second theme, regeneration is not byte-stable, and another session shares the checkout.**
- **Stamp check.** The watcher reads only the project theme and only warns (`main.gd:83-90`).
- **Regeneration churn.** Commit `1abbb7e` changed 626 lines of `master_theme.tres` for 37 + 43 source lines, and sub-resource ids shifted (e.g. `StyleBoxFlat_3w27j`). New `_mkfont` saves and a second theme save will shift ids further.
- **Concurrency.** Another session commits in the same folder (plan:47-48).
- **Correction.**
  - Bake the stamp into both themes and have the watcher check both.
  - Port the byte-stable writer (`build_direction.gd:746-799`) before any regeneration, and save master before the dark theme.
  - Gate commits C through F on: the `master_theme.tres` diff is only the stamp line.
  - Claim exclusive ownership of `scripts/theme/`, `themes/` and `assets/fonts/` until G. Check `git status` on those paths before every regeneration.

**13. MAJOR: Faz 0 permanently deletes tooling that Faz C needs.**
- **Evidence.** `sandbox/` is untracked (`git ls-files sandbox` returns nothing), so deleting it cannot be undone. It holds:
  - the WCAG contrast checker (`build_direction.gd:88-99, 667-707`);
  - the complete-theme copy, flatten and validate logic (`:353-600`);
  - the font width measurement (`:345`);
  - the byte-stable writer (`:746-799`);
  - `core/override_audit.gd`, which generated the override inventory that Faz F works through.
- **Correction (Faz 0).** Port these into tracked `scripts/theme/` or `scripts/debug/` and commit, then delete `sandbox/ui_lab`.

**14. MAJOR: the office veil is underspecified, and "veil" already names a different mechanism.**
- **Name clash.** `set_veiled` already means "founder's trip: hide windows, show the office alone" (`window_layer.gd:106-114`, `main.gd:2061,2087`, `office_view.gd:102-106`).
- **Fade conflict.** The night blink sets `_container.modulate` to black and tweens it back to white (`office_view.gd:111-116,185-187`). The travel and people cuts use the same tween (`office_travel.gd:117-119`, `office_people.gd:111`). A veil on `modulate` would be wiped by every skipped night.
- **Overlay conflict.** A ColorRect at WindowLayer child index 1 sits above OfficeView's whole `Overlay` (`OfficeView.tscn:130-151`). It would dim the notice stack, the invite ring and card, OfficeHud, the tooltip and the travel road, and it would have to lift during the trip.
- **Correction.**
  - Add `OfficeView.set_dimmed(on)`, which tweens `_container.self_modulate`. That multiplies with `fade()` on `modulate`, leaves `Overlay` alone, costs nothing and takes no input.
  - WindowLayer drives it on window open and close and forces it off while the trip is on.
  - The dim value is a [WORKING] scene-data constant next to `FADE_DARK`.
  - The halo is the dark `WindowPanel` shadow, with `shadow_size` no larger than the window inset, because CenterViewport clips its children (`GameShell.tscn:43`).
  - `--office-shot` without a tab shows the office undimmed, so art baselines stay valid.

**15. MINOR: the smoke constraints on the shell are not written into the plan.**
- **Cases and what they pin.**
  - `rail_tabs_match_scene_order` reads `./Margin/Col/<X>Btn/Stack/NameLabel` (`endgame_smoke.gd:3550-3584`).
  - `rnd_rail_open_with_waiting_page` needs `tab_buttons[idx]` with a direct child named `Badge`, and the function `_refresh_rnd_badge` (`:13263-13324`).
  - `topbar_speed_cluster_four_rungs` also needs the literal `KEY_4, KEY_KP_4: speed_idx = 4` in `game_shell.gd` (`:11375-11396`).
  - `ui_scale_ladder_fits_settings` needs a node named `CenterPanel` with offsets and a height of at most 864 (`:8399-8433`).
- **Correction.** List these as constraints in Faz D and F9, or update each case in the same commit. In icon mode, hide `NameLabel`; do not remove it.

**16. MINOR: two Faz D items depend on Faz E.**
- **Evidence.** The Olaylar badge counting unanswered and timed items needs the inbox store from E; today it counts `queue_size` (`left_tabs.gd:138-139`). Clicking the TopBar "Cevap bekliyor" slot cannot work before E: the EventModal's dimmer covers the TopBar, and the shell ignores keys while ModalLayer has a child (`game_shell.gd:73-75`).
- **Correction.** Move both to Faz E. Faz D ships the slot hidden.

**17. MINOR: StarRating retirement, the single toast, and surface ownership cross phase boundaries.**
- **StarRating.** It has consumers in HR, Personal, R&D, Sales, Meeting, Training, and the system script `sales_ledger.gd`. The smoke case `star_ruler_contract` is at `:8851`.
- **Toasts.** They live in OfficeHud, MeetingInvite and `ending_scene`.
- **Overlap.** BuildHUD, the notice stack, toasts and tooltips are listed both in the shell scope (plan:30-31) and in F11 (plan:231).
- **Correction.** Replace StarRating screen by screen and delete it, with the smoke update, in the commit that removes its last consumer. Unify the toasts in F11 and F12. Give each surface exactly one owning commit.

**18. MINOR: the glyph audit checks a symbol the game never draws.**
- **Evidence.** Money uses "$" in both languages (`fmt.gd:12-14`), and ₺ appears 0 times in `strings.csv`. The characters actually used are · − ✦ → × … « » ⇠ ★ in the CSV, plus ✓ ▲ ▼ ✕ ↑ ↓ ✗ ⋯ ± ⏎ ⅓ in code. Because imports set `allow_system_fallback=true`, a missing glyph silently comes from a system font.
- **Correction (plan:133).** Audit that real character list with `font_has_char(base.get_rids()[0])` for each new face and the fallback chain. Put Plex ahead of Noto Symbols 2 in Barlow's fallbacks.

**19. MINOR: font engine details that affect density and how closely the game can match the mockup.**
- **Line height.** A Label's line height is set by the tallest face in its fallback chain, which is Noto Symbols 2, not Barlow or Plex (memory; README:242-245).
- **Tracking.** `spacing_glyph` is a whole-pixel value per FontVariation (`build_theme.gd:581-582`), so one tracking value applies at every size.
- **tnum.** `opentype_features` accepts the text tag "tnum". The INT-tag trap applies only to variable-font axes, and every planned face is static. Plex digits are already equal width, so `tnum` matters only for Barlow.
- **Rendering gap.** Chrome renders the HTML mockup's text at different widths from Godot (grayscale anti-aliasing, light hinting).
- **Correction.**
  - Use one FontVariation per role and size wherever tracking differs, and use the same integer tracking in the mockup.
  - Measure Label row heights in Godot, or give table roles a fallback chain without Noto Symbols 2.
  - Budget width slack in tight columns.
  - Drop the INT-tag line from plan:134.

**20. MINOR: "every pair ≥ 4.5:1" (plan:64, 298) cannot hold as stated.**
- **Evidence.** It rules out the faint, locked and disabled tiers; `INK_FAINT` on `CARD_BG` is about 2.5:1 today. It ignores the 3:1 WCAG threshold for large text. Text drawn over the 3D office has no fixed background.
- **Correction.** Define categories: body text ≥ 4.5, large text ≥ 3, disabled exempt but distinguishable, decorative exempt. Require an opaque background under any text over the office.

**21. MINOR: locked rail tiles fade as a whole, so the lock reason cannot read at full ink.**
- **Evidence.** The whole tile gets `modulate.a = TAB_LOCKED_ALPHA` (0.45; `left_tabs.gd:43`, `ui_tokens.gd:359`). That contradicts the plan's "kilitli + gerekçe tam mürekkep" (plan:61,158).
- **Correction.** Apply alpha to the icon and label only, and draw the reason at full ink.

**22. MINOR: new TTFs need the import sequence.**
- **Correction.** Run `--import`, then a warm-up run, then the gates (memory `godot-import-cache-gotchas`). Check the `.import` diffs against the current standard: `antialiasing=1`, `hinting=1`, `subpixel_positioning=4`, `oversampling=0`, no mipmaps, no MSDF.

## Safest strategy: one shared vocabulary, two palettes, each applied per subtree

I reject a big-bang flip. It would change 51 surfaces at once: about 560 colour reads, 18 `_draw` scripts and 47 colour overrides. That cannot pass CLAUDE §11's limit of two fix rounds, and the commits in between would not be consistent.

I reject "explicit variations everywhere". Base-typed scene nodes, internal scrollbars, popups and tooltips cannot carry a variation, and flipping the base types in G would hit everything at once anyway.

Commit boundaries:
- **C1 tooling, no visual change.** Port the byte-stable writer, the validator, the contrast checker and the override audit. Extend `--theme-audit`. Gate: all audits identical.
- **C2 token split, no visual change.**
  - Split shared-value tokens: `ON_ACCENT`, `BADGE_FG` and the others listed in the theme report §0.1.
  - Derive `ACCENT_HEX`.
  - Bump the stamp and regenerate.
  - Gate: `master_theme.tres` diff is the stamp line only, and every audit is identical.
- **C3 fonts.** Add the TTFs, OFL files, imports and new FontVariation roles, none of them referenced by master. Gate: the import sequence, the glyph audit, and `all_scripts_load`.
- **C4 dark palette and theme.**
  - Add the `D_*` tokens, dark helpers and colour-blind twins.
  - Generate `menajer_theme.tres`, complete (master saved first), with the stamp in both themes and the watcher checking both.
  - Run the contrast check at build time.
  - Gate: the master diff is only the stamp line, and the validator reports nothing missing.
- **D1 shell geometry, still cream.**
  - Add the safe-rect seam and asymmetric WindowLayer insets; clamp BuildHUD.
  - Trim `SPECS` clear of BuildHUD.
  - Move to the 64 px TopBar and 40 px ticker offsets.
  - Check office framing with each office's shot.
- **D2.** Assign the dark theme to the TopBar and NewsTicker roots. Build the two-row TopBar, keeping its node names.
- **D3.** Assign the dark theme to the rail root. Make it the overlay, with icon mode keyed to logical width, keeping the smoke paths.
- **D4.**
  - Add `set_dimmed` (via `self_modulate`) and the dark `WindowPanel` halo.
  - Measure them with `--render-probe`.
- **D5.** Add the new shared components as dark-only entry points. No cream caller changes.
- **E.** As planned; the Olaylar window migrates with it.
- **F, per screen, one commit each.**
  - Each window: theme and title switched on through `frame_options`, page heading removed.
  - Colours: code colours moved to `D_*`, `_draw` sites converted, project-theme and pre-tree reads fixed.
  - The screen's own PanelLayer and ModalLayer modal roots get the theme.
  - Its StarRating uses are replaced.
  - Gates: every other surface's audit unchanged, shots in TR and EN, colour-blind on and off, scale 1.0 and 1.25.
- **G, the flip.**
  - Set `gui/theme/custom` to the dark theme and remove the per-node theme assignments.
  - Delete the cream generation, cream tokens and helpers, mono, StarRating and Chrome*.
  - Rename `D_*` to the final role names.
  - Move the readability floor and the size ladder.
  - Rewrite CLAUDE §7.
  - Gate: every surface's audit is identical before and after, so the flip must be a visual no-op.

## Remaining risks the plan does not mention

- Adding a `theme` reference to a scene through the editor rewrites `.tscn` and `.tres` files, so add theme references to scenes by hand.
- Modals on CanvasLayers do not rebuild on `palette_changed`. A dark modal left open while the colour-blind setting is toggled shows stale colours. This already happens today.
- HRPopover and ConfirmModal are shared between migrated and unmigrated callers. Either pass the register on each open call, or state that the mismatch is accepted until both callers have migrated.
- The newspaper's `PAPER_*` variations must live in the dark theme as well, so the ending screen needs no nested cream theme.
- If the rail goes over the office, the SubViewport grows from 1836×992 to about 1920×976. Re-run `--render-probe` and recheck open decision 70 (soft rendering above 1080p).