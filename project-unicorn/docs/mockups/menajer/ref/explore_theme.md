# Dark "Menajer Masası" redesign: map of the theme and style infrastructure, and every rule it touches

Paths are relative to `C:/Users/erdem/Desktop/project steam/project-unicorn/`. Repo HEAD is `c706349`. `sandbox/`, `docs/audits/` and `docs/mockups/` are untracked. Read-only pass; no files were written.

## 0. Findings that change the plan

1. **The token names are tied to cream.** `INK` means "text on cream" and `CREAM` means "text on the dark frame" (`scripts/theme/ui_tokens.gd:22-29`).
   - Making the windows dark therefore reverses token meaning, not just values. The light ink needs a new home.
   - Several tokens share one value but have different jobs. `INK`, `ON_ACCENT` and `BADGE_FG` are all `#2B2722` (`ui_tokens.gd:81,101,154`). If `INK` turns light, text on the amber button and amber badge disappears unless those two split off first (`sandbox/ui_lab/README.md:276-278`).
   - Other shared-value groups:
     - `CARD_BG` = `SURFACE_HOVER` = `TAB_ACTIVE_BG` (`:61,69,157`)
     - `#EFE8DA` ×5: `SURFACE_PRESSED`, `SURFACE_DISABLED`, `SURFACE_FRAME`, `BUILD_FILL_PAUSED`, `NEUTRAL_BADGE_BG` (`:70,71,76,107,155`)
     - `#D9D0BF` ×3: `CARD_BORDER`, `BORDER_DISABLED`, `BORDER_DASHED` (`:160,163,164`)
     - `BORDER_HOVER` = `DOT_IDLE` (`:161,140`)
     - `SURFACE_SUNKEN` = `DIVIDER_LIGHT` (`:72,168`)
     - `BG_BODY` = `ON_INK` (`:85`)
     - `ACCENT` = `BADGE_BG` (`:93,153`)
     - `BG_TOPBAR` = `BG_NEWS` (`:54-55`)
     - `BG_AVATAR` = `SEPARATOR` (`:56,169`)
     - `CREAM` = `PORTRAIT_FRAME` (`:88,212`)
     - `#232C34` ×3: `CARD_BORDER_CHROME`, `DIALOGUE_CARD_BORDER`, `CONVICTION_TRACK_BG` (`:195,210,211`)
2. **The theme only reaches part of the UI.**
   - 560 runtime reads of colour constants sit in roughly 45 scripts outside `scripts/theme/` (counted by grep). The biggest are `hr_atlas_modal.gd` 34, `work_hours_modal.gd` 31, `personal_tab.gd` 30, `hunt_tab.gd` 30, `rnd_assign_panel.gd` 29 and `finance_ozet_view.gd` 29.
   - `StyleBoxFlat.new()` is called in 21 non-theme scripts. There are 47 `add_theme_color_override` calls, and `ColorRect` dimmers in 12 modals.
   - Regenerating `master_theme.tres` alone will leave much of the screen cream.
3. **The newest screen is built in a paper look.** Product rev 7 just shipped a folder-and-paper vocabulary: `FolderWindow`, `PaperCard*`, `Stamp*`, `GoalStrip`, `DecisionRow`, `InkButton`, `PrimaryButton`, `DataMono*` (`build_theme.gd:306-370`; `product_tab.gd:16`; commits `2b2d9b5`, `1abbb7e`). A dark redesign collides with the screen that shipped last.
4. **Director-approved GDD text contradicts the direction.**
   - ch12 §7 says: "Terminal language stays: mono type, hairline rules, amber accent, no filled hover rectangles (edge glow only). UI scale ladder and resolution handling stay as shipped." That is from `GDD v2 — 12 · UI Surfaces & ODA.docx` §7, and `GDDs/GUNCELLEMELER.md:329-364` has no §7 entry.
   - ch14 §7 says "Frank has a portrait", and GUNCELLEMELER says "Boyalı kurucu portresi, Frank ve VC yüzeyleri değişmez" (painted founder portrait, Frank and VC surfaces do not change; `GUNCELLEMELER.md:375-378`).
5. **The inbox decision conflicts with the event engine's presentation rules.**
   - `interrupt` is a blocking modal, and "Modal SceneTree'yi durdurur" (a modal stops the SceneTree; `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:797,824`).
   - An opened paper "modal gibi davranır (zaman durur)" (behaves like a modal, time stops; `:834`).
   - WindowLayer windows are deliberately not modal: "Pencereler ModalLayer'a ASLA gitmez … pencere açıkken hız kontrolü çalışmalı" (windows never go to ModalLayer; speed control must work while a window is open; `scripts/ui/components/window_layer.gd:5-7`).
   - ch14 §7 also says "consistency of the modal is the rule". Opening Frank's decision inside the Olaylar window needs an owner ruling and a GUNCELLEMELER / engine §27 entry.
6. **Some open-decision items point at deleted code** and must be rewritten, not just closed:
   - item 61: `BUILD_RAMP_2/3` and `OfficeConstants.ROLE_COLORS` no longer exist
   - item 73: `ChromeAlertButton` and `negotiation_scene.gd` do not exist
   - the unnumbered "Chrome* off-list" item cites `DialogueChoiceButton`, `ChromeAlertButton` and a Product Frank strip, none of which exist
   - item 65: `creation_flow.gd` is gone
   - items 51 and 52: `detail_view.gd`, `team_panel.gd`, `capacity_block.gd`, `triangle_radar.gd` are gone
7. **The UI Lab builder already fails.**
   - It expects 131 variations, 140 colours, 151 styles, 91 font sizes, 74 fonts, 14 constants and 10 icons (`sandbox/ui_lab/core/build_direction.gd:23-24`).
   - Master now holds 158 variations (`*/base_type` lines in `themes/master_theme.tres`), with roughly 162 colours, 176 styles, 108 font sizes, 90 fonts, 13 constants and 7 icons (grep estimate).
   - The lab's 11 "canonical" names (FolderWindow, PaperCard, Stamp, AttentionBadge, DataMono, TickerLabel, PrimaryButton, InkButton…) now exist in master.
   - `docs/audits/UI_OVERRIDES.md` is from 2026-09-30, before rev 7, and cites deleted files (`detail_view.gd`, `feature_lines_view.gd`, `triangle_radar.gd`).

## 1. UiTokens (`scripts/theme/ui_tokens.gd`, `class_name UiTokens`, 633 lines)

**Header**
- Ownership contract (`:4-20`). The CONTEXT RULE splits cream body from dark frame and says the dark cinematic register reads the frame's tokens (`:22-29`).
- FONT IMPORT STANDARD (`:31-36`). Not styled on purpose: the focus ring, Tree, ItemList and TabContainer (`:38-39`).

**THEME_STAMP = 16** (`:42-44`)
- `build_theme.gd:59-61` bakes it as `UiTokensStamp/constants/stamp`, which reads 16 at `master_theme.tres:2518`, so they are in sync.
- The watcher is in `scripts/main/main.gd:83-90`: debug builds only, `push_warning` only. No smoke case and no pre-commit check enforce it (grep of `endgame_smoke.gd` finds none).
- Rule (CLAUDE.md:107-109): bump the stamp and regenerate in the same commit as any token or `build_theme` change.

**Palette blocks (by line)**

| Block | Lines | Notes |
|---|---|---|
| chrome surface | 53-56 | `BG_TOPBAR`/`BG_NEWS` #07090B, `BG_AVATAR` |
| page body | 58-63 | `BG_BODY` #F6F1E6, `BG_PANEL` #ECE5D6 (rail), `CARD_BG` #FBF7EE, `CARD_ATTENTION_BG`, `CARD_FLOATING_BG` |
| control states | 65-78 | hover equals the resting fill (`:66-69`); `SHADOW_SOFT`, `SHADOW_MODAL` |
| INK ladder | 80-85 | `INK` #2B2722, `INK_MUTED`, `INK_DIM`, `INK_FAINT`, `ON_INK` |
| CREAM | 87-90 | `CREAM` #E8EDF2, `CREAM_DIM` #74828F (cool blue-grey, not warm) |
| ACCENT | 92-101 | `ACCENT` #F4C430, `_HOVER`/`_PRESSED` [WORKING], `ACCENT_DIM` #1E2730, `ACCENT_DEEP` #9A6A12 (amber text on cream), `AMBER_BG`, `AMBER_WASH` |
| bar fills | 103-108 | |
| semantic | 111-122 | `POSITIVE` #2F6B3A and `NEGATIVE` #9B3B28 are dark inks tuned for cream; `*_BRIGHT` #3FD68C / #FF5C49 exist for dark; `HEALTH_AMBER` |
| colour-blind twins | 124-139 | Okabe-Ito blue/orange, all [WORKING] |
| area slots | 141-150 | `AREA_SLOT_0..4`; slot 0 has a CB twin |
| badge | 152-157 | |
| edges | 159-169 | |
| meeting dock | 171-184 | `ATTITUDE_*`, `MEETING_SEAT_1..3`; inks tuned for cream |
| chrome twins | 186-199 | `ACCENT_CHROME` #FFA028, `INK_*_CHROME`, `CARD_BORDER_CHROME`, `VEIL_*_CHROME` |
| cinematic | 201-212 | `SCRIM_MODAL` rgba(5,7,9,.62), `ROAD_*`, `DIALOGUE_BG` #10161C (cold blue charcoal, not the warm charcoal the direction wants), `PORTRAIT_FRAME` |
| newspaper island | 214-226 | `PAPER_*` |

- `ACCENT_HEX = "#FFA028"` (`:100`) is a hand-copied string of `ACCENT_CHROME`, used as BBCode in `news_ticker.gd:132`. It must be updated by hand.

**Colour-blind switch** (`:361-405`)
- `static var _cb_palette` (`:368`) and `set_colorblind` (`:372`). Accessors: `positive`, `negative`, `*_bg`, `*_bright`, `health_green`, `*_rule` (`:378-405`). `area_color` (`:632-633`).
- The theme never bakes semantic colour; live surfaces repaint on `EventBus.palette_changed` (`ui_tokens.gd:364-367`, `event_bus.gd:45`).
- Exception: dead variations `ChipPositive` / `ChipNegative` bake `POSITIVE_BG` / `NEGATIVE_BG` into the theme (`build_theme.gd:177-178`). Grep finds no consumers. `ChromeAlert` bakes `NEGATIVE_BRIGHT` (`build_theme.gd:85`); `top_bar.gd:176` repaints it.
- Accessor call counts: `negative()` 36, `positive()` 27, `area_color` 7, `negative_rule` 6, `negative_bright` 6, `badge_palette` 6, and others.

**Helpers** (`:412-522`)
- `delta_color` and `delta_color_bright`; the "bright" variant is for chrome.
- `badge_palette` returns fixed bg/fg pairs that assume cream (`:425-431`). Also `badge_palette_for_delta`, `health_color`, `relationship_palette`.
- `risk_key` / `risk_ink`, `attitude_band` / `_word_key` / `_ink`, `seat_ring` / `seat_ink`, `tooltip_tone_ink`.
- Formatting delegates to `Fmt` (`:526-543`). `net_runway_parts` / `_text` / `_pair` (`:550-595`) read `GameState`. `build_percent` (`:601-602`).
- Every ink helper assumes a cream ground except `*_bright` and `tooltip_tone_ink`.

**Type scale** (`:228-253`)
- MICRO 9, META 10, SMALL 11, DATA 12, BODY 13, LEAD 15, TITLE 16, DISPLAY 22.
- Editorial `SIZE_ED_*`: 24, 26, 32, 44, 52 (`:255-262`).
- Rule: "a variation MAY choose another face but may NEVER override its step's size" (`:231-235`).
- `LEADING_BODY` 3 and `LEADING_RICH` 0 are pinned to engine defaults (`:264-270`).

**Spacing and shape**
- `SPACE_*` 2–24 (`:280-287`).
- Radii all 2 except `RADIUS_PILL` 999, `RADIUS_WINDOW` 4 and `RADIUS_PAPER` 3 (`:293-303,626`).
- Borders 1/2/3 (`:306-308`). `PAD_*` pairs (`:311-335`).

**Rail and product constants**
- `TABS` (8 ids) and `TAB_LOCKED_ALPHA` 0.45 (`:337-359`). Rail captions are keys `TAB_`+ID; icons live only in `LeftTabs.tscn`.
- `PRODUCT_*` layout constants (`:605-629`).

## 2. `scripts/theme/build_theme.gd` (717 lines; a `-s` SceneTree script)

- **Run**: `"$GODOT" --headless --path . -s res://scripts/theme/build_theme.gd`; a clean checkout needs `--import` first (CLAUDE.md:107-108).
- **Loading**: `UiTokens` is loaded at `_initialize`, not preloaded, because `ui_tokens.gd` names `GameState` (`:18-20,38`). `Settings.apply_all` skips `set_colorblind` under this script (`autoload/settings.gd:107-111`).
- **Fonts loaded** (`:22-29`): `SourceSerif4-{Regular,Semibold,It}`, `IBMPlexSans-{Regular,SemiBold}`, `JetBrainsMono-{Regular,SemiBold}`; fallback `NotoSansSymbols2-Regular`.
- **FontVariation wrappers**: `_mkfont` builds 8 and writes them to `assets/fonts/variations/*.tres` (`:47-55,573-585`).
  - Roles: `serif_reg`, `serif_sb`, `serif_it`, `sans_reg`, `sans_sb`, `mono_reg`, `mono_label`, `mono_sb`. `mono_label` and `mono_sb` get `spacing_glyph = 1` (`:54-55,581-582`).
  - Default font is `sans_reg` (`:58`).
- **Variation counts**:
  - 70 `_lbl` Label variations, 57 `_panel` Panel/PanelContainer variations.
  - Button families through `_tab_button` (`:659-678`), `_speed_button` (`:681-698`) and `_commit_button` (`:701-717`). Hand-built: DialogueGhost, WindowClose, ActionRow, StanceDial×2, InkButton, BodyRich, NewsRich, BuildProgress, VolumeSlider, SettingsSwitch, SettingsDropdown, SettingsPopup, DialogueInput, DialogueStepper.
  - Total: **158 variations** in master.
- **StyleBox kinds in master**: 148 `StyleBoxFlat`, 3 `StyleBoxLine` (`_rule`, `:622-627`; separators and popup), 6 `StyleBoxEmpty` (switch). No `StyleBoxTexture` anywhere.
- **Icons in the theme**: `slider_grabber.svg`, `switch_on.svg`, `switch_off.svg` (`:400,412-420`). Their colours are baked into the SVG; `switch_off.svg` is cream `#eae3d5` / `#d8d0bc`, so it needs a dark variant.
- **Groups**:
  - Label registers (`:63-143`): body, TopBar metric (chrome), meeting dock (cream), cinematic dialogue (dark), onboarding (dark), newspaper (`PAPER_*`).
  - Panels (`:145-237`): `TopBarPanel`; `SideRailPanel` (cream rail, right hairline); `NewsPanel`; `ViewportPanel` (BG_BODY, the CenterViewport ground); `ModalPanel`; `WindowPanel` (CARD_BG, RADIUS_WINDOW, SHADOW_SOFT, no margins; `:189-195`); `ModalCard` (40 px SHADOW_MODAL; `:225-230`); `MeetingDock` family (`:197-204`); `Dialogue*` / `Portrait*` / `QuoteBox` / `RailPanel` / `RailCard` (dark, cold charcoal).
  - Base-type defaults (`:516-560`): base Button is the ghost button — mono_label, edge-only hover in amber (`:463-476`). Base Label gets INK colour, no font size (`:534-535`). Base Panel and PanelContainer get CARD_BG; RichTextLabel uses serif. Tooltip is dark (`BG_TOPBAR`, `:556-560`).
  - Chrome family (`:372-379`): only `ChromeTabButton` and `ChromeTabButtonActive`, both identical to `TabButton`. Chrome-named labels are `ChromeLabel`, `ChromeValue`, `ChromeClock`, `ChromeAlert` (`:80-85`).
- **Never themed**: ScrollBar, ScrollContainer, Tree, ItemList, TabBar, CheckBox, SpinBox (0 items in master). 16 `ScrollContainer`s exist in code and scenes; scrollbars render Godot defaults.

## 3. Fonts

**Files**: `assets/fonts/{serif,sans,mono,fallback}/` each carry `OFL.txt`.
- `JetBrainsMono-Medium.ttf` is shipped but nothing reads it (dead asset; `build_theme.gd:22-29` does not load it).
- `variations/sans_it.tres` is hand-made: IBM Plex Sans Regular sheared by `variation_transform` 0.21. `build_theme.gd` does not generate it; `hr_action_modal.gd:18` preloads it directly. Its comment still says "THEME_STAMP 6'da kalıyor" (THEME_STAMP stays at 6), which is stale (`assets/fonts/variations/sans_it.tres:6-19`).
- Direct font preloads that bypass the theme: `hr_action_modal.gd:16-18`, `value_slider.gd:13`, `star_rating.gd:15`. `add_theme_font_override` is used in `hr_action_modal.gd` (3), `bar_kit.gd`, `star_rating.gd`.

**Import parameters**: every TTF uses `antialiasing=1 hinting=1 subpixel_positioning=4 oversampling=0.0 allow_system_fallback=true` (e.g. `JetBrainsMono-Regular.ttf.import:16-28`). The UiTokens note says not to change these in a theme edit (`ui_tokens.gd:31-36`).

**Set A canon** (Source Serif 4 / IBM Plex Sans / JetBrains Mono; Erdem 2026-08-03) is recorded only in owner memory (`memory/font-durusmasi-specimen.md`) and the `build_theme.gd:11-12` header. It is not in CLAUDE.md, HARITA or ACIK_KARARLAR. Known gaps:
- ₺ is missing in JetBrains Mono.
- Weight separation SemiBold vs Regular: serif +8 px, sans +10 px.

**Engine gotchas**
- `Font.get_height` takes the tallest face in the fallback chain, so Noto Symbols 2 sets every Label's line height and changing a face does not move Label heights; RichTextLabel follows the face that draws, so the event modal body resizes (`sandbox/ui_lab/README.md:242-245`).
- Variable-font axes need INT tags; a text tag silently draws the default instance (`README:306-307`; `build_direction.gd:260-276`).
- IBM Plex Sans digits are already equal width (`README:309-311`).

## 4. `master_theme.tres` and `UiFactory`

**`themes/master_theme.tres`**
- 2542 lines, generated. Project theme via `project.godot` `gui/theme/custom` (line 50).
- References the 8 FontVariations and 3 SVGs (lines 3-13). Stamp at 2518.
- The editor rewrites `.tres` files; do not commit such diffs without the owner (CLAUDE.md:202).

**`scripts/theme/ui_factory.gd`** (217 lines)
- `_chip_box` (`:12-20`). `make_pill` (`:24-34`, explicit colours). `make_badge` (`:38-40`, `badge_palette`). `make_state_chip` (`:46-53`; runtime because of the CB swap).
- `make_label` (`:57-63`, default `BodySerif`; 390 call sites). `make_section_header`, `make_stat` (`:73-86`), `make_card` (`:90-98`, `CardAttention` lives only here).
- `make_person_avatar` / `make_avatar` / `make_bust` (`:102-141`, `avatar_bust.gdshader`). `make_dot`, `make_centered_column`, `make_placeholder_column`.
- `make_close_button` (`:196-204`, `WindowClose`, `SPACE_3XL` square). `clear`, `is_left_click`.

## 5. What the theme cannot reach

- **Overrides**
  - The UI Lab inventory of code-painted surfaces is at `sandbox/ui_lab/README.md:247-268`.
  - The stale audit in `docs/audits/UI_OVERRIDES.md:561-584,669-734` counted 470 visual and layout overrides on 4 screens. The top three were `hr_tab.gd` 227, `sales_tab.gd` 95, `build_bar.gd` 34. It counted 602 static `add_theme_*_override` calls (53 colour, 5 font, 15 font size, 465 constant, 64 stylebox).
- **TopBar**: `LogoSquare` ColorRect painted `ACCENT_CHROME` (`top_bar.gd:53`). Colour overrides at `:135,146,176,189,198`. Fixed widths 104/104/210 (`TopBar.tscn:49,66,207`). Density tier `COMPACT_BELOW` 1600 with raw gaps 18/28/10/16 (`top_bar.gd:10-13,91-100`).
- **Rail**: icon and label colours by modulate and override (`left_tabs.gd:43,52-54,104-106`). Badges are `Badge` Panels with `TabBadge` (`LeftTabs.tscn:68-76`), counts in `left_tabs.gd:116-139`.
- **Raw values that break UI/STYLE LAW**:
  - font sizes 12 and 26 in `month_summary_modal.gd:103,142`; 24 in `term_sheet_table_scene.gd:268`; 20 and 30 in `origin_traits_step.gd:295,329`
  - raw `Color(` in 16 files (e.g. `origin_traits_step.gd` ×5, `work_hours_modal.gd` ×5)
  - these are already listed in `docs/ACIK_ISLER/ISLER.md:19-33` under "Arayüz yeniden yapılırken" ("when the UI is rebuilt")
- **Theme read outside the tree**: `ThemeDB.get_project_theme()` in `bar_kit.gd:21`; `get_theme_*` before the node is in the tree in `hr_ui_shared.gd:230`. Both always see master.
- **Scrims**: `SCRIM_MODAL` ColorRects in event, confirm, HR action, mentor, month summary, R&D card, save/load, settings, system, training and work-hours modals and the onboarding overlay (e.g. `event_modal.gd:78-81`).

## 6. Smoke cases and harnesses that read theme or UI

| Gate | Where | Breaks when |
|---|---|---|
| Stamp watcher | `main.gd:83-90` | Never fails; it only warns |
| `ui_scale_ladder_fits_settings` | `endgame_smoke.gd:8399-8433` | SettingsModal `CenterPanel` grows past 1080/1.25 = 864 px (today ±410 = 820, `SettingsModal.tscn:32,34`), or `UI_SCALE_STEPS` top step / `MIN_CHROME_VIEWPORT` change so 1.25 is illegal at 1920×1080 |
| `rail_tabs_match_scene_order` | `:3550-3584` | Rail no longer has nodes `./Margin/Col/*Btn/Stack/NameLabel` with `text = TAB_<ID>` in `TABS` order. A 184 px labelled rail rebuild must keep the paths or update the case |
| `rnd_rail_open_with_waiting_page` | `:13263-13324` | Names `CenterViewport`, `LeftTabs`, `get_current_page_body()`, `rail.tab_buttons[idx]/Badge`, `_refresh_rnd_badge` change |
| `topbar_speed_cluster_four_rungs` | `:11375-11396` | `TopBar.tscn` loses node names `PauseBtn`, `Speed1Btn`..`Speed4Btn` (`:264,292`), `top_bar.gd` source no longer contains "Speed4Btn", or `game_shell.gd` no longer contains `KEY_4, KEY_KP_4: speed_idx = 4`. Two-row TopBar must keep these |
| `event_chip_coverage` | `:13456` | Not colour-sensitive. Breaks if `_describe_modifier` (`event_modal.gd:357`) or `SILENT_VERBS` (`:19`) leaves `event_modal.gd` (path-loaded also at `:3516` `source_tag_speaker_wins` and `:10743`). If decisions move into the inbox, the single chip builder must stay or CLAUDE.md §5 and the case change |
| `loc_csv_integrity` | `:8442` | Not style-sensitive. New keys ("Cevap bekliyor", inbox labels) need both locales and identical `{token}` sets |
| `ending_paper_modes_on_screen` | `:11175` | Ending buttons or labels change text |
| `settings_language_toggle` | `:2739` | SettingsModal structure changes |
| `onboarding_pages_contract` | `:5330-5342` | Step scenes change |
| `milestone_paper_under_card` | `:11263` | `main.gd` names or child order change |
| `all_scripts_load` | `:9844` | Any script under `scripts/` or `scenes/` fails to compile |
| `--theme-audit=<tab>` | `main.gd:1032-1044,1063-1135` | No stored baseline; it is an operator before/after diff. Every line changes with a reskin |
| `--probe-shot` / ThemeProbe | `main.gd:1047-1060`; `scenes/debug/ThemeProbe.tscn:36,41,47` | Expectation captions are literal ("sans 13 INK", "hayalet kenar, mono 12") and go stale |
| `loc_residue` | `scripts/debug/loc_residue.gd:30-36` | Skips `scripts/debug/`, `scenes/debug/` and `language_gate.gd`. Every new scene text must be a CSV key |
| `--shot-scale` | `main.gd:422-432` | Runs `DisplaySettings.clamp_step`; follows any ladder change |
| `--render-probe` | HARITA:90 | Frame cost and texture memory shift with new textures or portraits |
| UI Lab | `sandbox/ui_lab/README.md:109-112` | Baselines and `--office-shot=ishani:11:hr/sales` parity break on any reskin (expected). Builder already FAILs on counts (see §0.7) |

CLAUDE.md §10-11 (lines 144-157): UI is accepted visually in-game through Godot MCP with at most 2 fix rounds, not by smoke.

## 7. DisplaySettings and accessibility

**Base and scale**
- `project.godot` sets viewport 1920×1080, stretch `canvas_items` / `expand`. `DisplaySettings.BASE_VIEWPORT` mirrors it (`display_settings.gd:63`).
- Minimum window 1280×720 (`main.gd:78`). `MIN_CHROME_VIEWPORT` 1280×720 (`:65-68`), smallest entry in `RESOLUTIONS` (`:24-39`).
- `UI_SCALE_STEPS` [0.75, 0.90, 1.00, 1.10, 1.25] (`:51`).
- Readability floor `MIN_READABLE_FONT_PX` = 9 = `SIZE_MICRO` (`:53-57`), computed by `effective_micro_px` (`:258-260`). Any token below 9 breaks that floor's logic.
- Gates: `is_step_allowed` (`:273-281`), `_fits_chrome` (`:294-298`), `clamp_step` (`:312-325`), `apply_ui_scale` (`:339-346`). `is_inert` (`:84-92`) disables all of it for harnesses.

**Accessibility settings that exist**
- Only `colorblind_palette` (`autoload/settings.gd:42-43`), applied at `:110-111`. UI: `settings_modal.gd:153-157,180-185,207`.
- There is no high-contrast mode and no text-size setting. `ui_scale` is the only size control (`settings.gd:32`).

**Repaint on palette change**: `window_layer.gd:54` (rebuilds open windows), `top_bar.gd:74`, `hr_tab.gd:61`, `personal_tab.gd:41`, `build_bar.gd:58`, `research_bar.gd:78`, `office_city.gd:100`, `office_notice_stack.gd:31`.

## 8. CLAUDE.md §7 (lines 103-119): what conflicts with dark windows

- **:104-106 (vocabulary and scale)**: holds. New warm-charcoal tokens and any FM-style dense-table sizes must still come from the ladder.
- **:107-112 (generated theme, single converter, scenes own layout only)**: holds. It means the reskin is a `build_theme.gd` plus override migration job.
- **:113 "mono yazı, hairline çizgi, amber vurgu; hover dolgu değil kenardır"** (mono type, hairline rules, amber accent; hover is an edge, not a fill). Conflicts:
  - "amber only for the primary action". `ACCENT_DEEP` is read 79 times in code; amber is also used for edges, active tab rule, `SectionAmber`, `StanceDialActive`, `ChipAmber`, `GoalStrip`, `DecisionRow`, `PaperCardOpen`.
  - Mail-inbox row selection or hover fills contradict "hover is edge".
  - Mono everywhere (base Button is mono, `build_theme.gd:472`) versus sans tables.
- **:114-116 "Gövde krem kâğıttır (sayfa #F6F1E6, kart ve pencere #FBF7EE, INK #2B2722); çerçeve koyudur (#07090B …) … CREAM\*, \*_CHROME, \*_BRIGHT"** (the body is cream paper; the frame is dark). This is the core conflict. The "tek ada gazetedir" (the newspaper is the one island) rule needs a ruling: does the newspaper stay cream?
- **:116-117 "3B ofisin renkleri UI token'ı değil sahne verisidir"** (the 3D office's colours are scene data, not UI tokens). A veil decides where the dim lives: a UI token scrim or scene data.
- **:118-119 Chrome rule** ("Chrome\*" only in TopBar, MonthSummary, NewsTicker; Sales' `ChromeTabButton` is open). With dark windows the chrome/body split disappears and the rule must be rewritten or retired.
- **Other CLAUDE rules touched**:
  - §5:52-54: no dashes in player text. Dense tables will want a no-data mark (item 51).
  - §5:62-63: the single chip builder.
  - §3:34-35: TR/EN approval and Frank lines are owner-only.
  - §8:128-129: the replacing commit deletes the old code — `Chrome*`, cream tokens, `ChipPositive` / `ChipNegative`, `portrait_frank.webp`, `JetBrainsMono-Medium`.
  - §11: visual acceptance.
  - §12:190-191: windowed runs are sequential.

## 9. GDD and docs that must change

**GDD .docx files**
- ch12 §7 visual language: new GUNCELLEMELER entry under `## GDD v2 — 12` (`GUNCELLEMELER.md:329`).
- ch12 §1: inbox, building on the existing entry at `:331-334`.
- ch12 §2: two-row TopBar and 184 px rail, amending `:336-338`.
- ch12 §4: rail count badges, already consistent with "a badge is a number on the tab".
- ch14 §7 portrait policy: Frank's portrait becomes a pre-render; amend `:375-378`.

**Event engine md**: §11.1, §11.3, §11.4 (`:791-837`) plus a §27 divergence entry if decisions open in a window.

**CLAUDE.md**: §6:66-68 (layout sentence, only if layering changes) and §7 entirely.

**docs/HARITA.md**
- "Tema ve UI kiti" (`:58-70`): line 66 says "pencere `WindowPanel` (krem kart …)".
- "Kabuk" (`:72-90`): TopBar, rail, Olaylar page, `DeskPapers`.
- "Ofis" (`:92-107`): veil, notice stack.
- "Fonlama" (`:192`): `assets/art/investors/` "Frank'in portresi".
- "Olay motoru" Sunum (`:252`).

**`docs/design/localization_glossary.md` §7 "Chrome & ortak UI"** (`:132-151`)
- Needs new terms ("Cevap bekliyor", inbox, rail).
- It is already stale: it lists "İK / Operasyon", but the CSV has `TAB_HR` = Ekip/Team and no Ops tab (`strings.csv` `TAB_*`).
- "mail" is an allowed loanword (CLAUDE.md:53).

**docs/ACIK_ISLER/ISLER.md:19-33**: the "Arayüz yeniden yapılırken" bucket is this task's backlog.

**Sandbox and audits**: `sandbox/ui_lab/README.md` and `build_direction.gd` (counts, ROLE_MAP, JOIN at rail x=84 `:69-71`) and `docs/audits/UI_OVERRIDES.md` are stale and untracked. Owner decides: keep and refresh, or delete.

**Not in the repo**: the "Set A canon" (memory only) needs a home if Menajer Masası changes faces.

## 10. Open decisions (ACIK_KARARLAR) touching UI, theme, fonts, colours or portraits

- **61** (`:951-962`): cream-palette [WORKING] colours awaiting F5 (`ACCENT_HOVER` / `PRESSED`, `BORDER_STEPPER_OWN`, `DOT_IDLE`, `BUILD_FILL_PAUSED`, CB backgrounds). Partly stale: `BUILD_RAMP_2/3` and `ROLE_COLORS` are gone.
- **65** (`:986-996`): window sizes. Ekip 1200 vs mockup 1000; Product overflow. `creation_flow.gd` reference is stale. `SPECS` at `window_layer.gd:26-32`; events window is 900×640.
- **70** (`:1618-1626`): 3D office renders soft above 1080p (SubViewport `stretch`).
- **73** (`:1649-1659`): `ChromeAlertButton` CB swap. Stale; the target does not exist.
- **74** (`:1661-1668`): map chips and office pill drawn with the dark pair (`BG_TOPBAR` / `CREAM`) off the Chrome list (`office_map_card.gd:48`, `office_city.gd`).
- **Unnumbered "Chrome\* liste dışı kullanım"** (`:1574-1579`): Sales `ChromeTabButton` (`sales_tab.gd:391`). Its listed surfaces are stale.
- **85** (`:1173-1190`): travel veil (`WindowLayer.set_veiled`, `OfficeView.set_veiled`).
- **88** (`:1192-1206`): amber chevron cap in the work-hours modal.
- **92** (`:1549-1556`): founder portrait (painted vs 3D look).
- **93** (`:1208-1220`): meeting panel [WORKING] values and design deviations. Includes the cream result card versus the design's dark card, and the `ACCENT_DEEP` 3.9:1 contrast.
- **94** (`:1222-1230`): "Frank'in portresi kaldı" (Frank's portrait stayed).
- **51** (`:712-731`): em-dash no-data mark; affects dense tables. File refs partly stale.
- **52** (`:733-753`): axis numbers on two rulers. Stale (triangle and detail view deleted).
- **"Series A ekranlarındaki görsel gözlemler"** (`:910-913`): dial needle overlaps the percent; Av layout.
- **96** (`:1232-1348`): Product rev 7 agent decisions, including the folder/paper UI.
- No item exists for Set A fonts or the THEME_STAMP rule.

## 11. 3D office colour sources, veil options and layering

**Layering**
- `GameShell.tscn`:
  - `TopBar` 0–54 px (`:21-26`)
  - `MidRow` HBox, 54 to −34 (`:28-37`), containing `LeftTabs` (84 px, `LeftTabs.tscn:15`; tiles 64 px at `:36`) and `CenterViewport`
  - `CenterViewport` is a Panel with `ViewportPanel` (`BG_BODY`), `clip_contents`, and is the WindowLayer script (`:42-47`)
  - `NewsTicker` bottom 34 px (`:52-60`)
  - `PanelLayer` CanvasLayer 9 (`:62-63`), `ModalLayer` CanvasLayer 10 (`:65-66`)
- `CenterViewport` children: `OfficeView` first (`:49`), window frames, then `BuildHUD` last (`:68`). `_mount` inserts each frame at `get_child_count()-2` (`window_layer.gd:140-144`).
- `_place` puts windows at `EDGE` 16 and clamps sizes to the room (`:148-161`).
- The office stays interactive behind windows (GUNCELLEMELER.md:336), and the windows take the pointer first (`office_view.gd:5-6`).
- A two-row TopBar or a 184 px rail means changing these hard-coded offsets and the `room` math. At 1280-wide logical, the centre area shrinks to about 1096 px.
- CanvasLayers break theme inheritance (memory `godot-theme-engine-facts`; `README:85-86,296`). That is harmless for the project theme but matters if a scoped theme is used.

**Colour sources**
- Office geometry and material albedo come from `art/office3d/<id>.glb/.json`, exported from the design's Three.js source (`tools/office3d/`).
- Day lighting: `OfficeLighting.CS` table, `AMBIENT`, `DESK_LAMP`, `SCREEN_LIGHT`, `STREET`, `GLOW_STOPS` (`office_lighting.gd:13-42`).
- Environment grade: `ACES_EXPOSURE`, `GRADE_CONTRAST` 1.05, `GRADE_SATURATION` 1.08 written at init (`:44-52,87-94`). `adjustment_enabled = true` is already on (`OfficeView.tscn:29`).
- Toon ramp (`office_toon.gdshader:30-35`). Sky uniforms (`office_sky.gdshader:7-10`).
- InkPass full-screen quad (`OfficeView.tscn:118-122`, `render_priority -128` at `:35`):
  - uniforms `ink` (`office_ink.gdshader:12`), `vignette = 0.22` (`:16`), `cutout` (`:18`), `DARK_LINE` (`:21`)
  - the vignette is applied through an ACES round trip (`:94-96`) that depends on `ACES_EXPOSURE` (`office_lighting.gd:44-48`)
- Rings: `FOUNDER_RING` and `SELECT_RING` (`office_constants.gd:116-117`). Icon tint (`office_actor.gd:23`).
- Night and travel fades use `OfficeView.FADE_DARK` and tween `_container.modulate` (`office_view.gd:13,109-116,185-187`).

**Veil options** (constraints only, no recommendation)

| Option | How | Constraint |
|---|---|---|
| (a) UI scrim node | A ColorRect/Panel child of `CenterViewport` at index 1, between OfficeView and the windows; the `SCRIM_MODAL` pattern | Must be `MOUSE_FILTER_IGNORE` to keep the "office interactive" ruling. It also dims OfficeView's own Overlay (NoticeStack, Tooltip, MeetingInvite, travel; `OfficeView.tscn:130-151`). It is UI-token territory |
| (b) `_container.modulate` | Tint the 3D container | Collides with the night blink and travel `fade()`, so it must compose with them |
| (c) Environment adjustment | `adjustment_brightness` / `_saturation` | 3D only. Overlays untouched, PersonBust studio untouched (own world, `person_bust.gd:59-...`). It is scene data and is applied after the tonemap |
| (d) InkPass uniform | Raise `vignette` (radial only) or add a uniform dim | The same shader serves PersonBust with `vignette` 0 and `cutout` true (`person_bust.gd:84-87`), so a new uniform must default off |

## 12. Frank portrait facts (theme-adjacent)

- Today Frank is `CharacterRegistry.ensure_mentor` with `portrait_path = res://assets/art/investors/portrait_frank.webp` and no `look` (`character_registry.gd:396-408`).
  - `portrait_path` is an `@export`, so it is saved (`character.gd:21-23`); old saves keep the path.
  - The only consumer of `portrait_path` is `event_modal._make_avatar`. It falls back to `make_person_avatar(look)`, i.e. a PersonBust render, when the path does not load (`event_modal.gd:247-262`).
  - The notice stack draws Frank's initials (`office_notice_stack.gd:60`). The mentor intro modal draws no portrait (`mentor_intro_modal.gd:14-22`).
- **Existing low-poly portrait pipeline**: `PersonBust` is an off-screen studio with noon light, toon look and ink cutout on a clear background (`person_bust.gd:3-7,10-21`).
  - Runtime only; returns null headless (`:31-44`), so a "fixed pre-render" means baking a file.
  - Harness for portraits next to busts: `--office-shot=home:14:founders` (HARITA:107).
  - Bodies are Quaternius CC0 (`assets/art/people/LICENSES/`).
  - `LookSystem.FOUNDER_LOOKS` maps 11 painted founder portraits to looks (`look_system.gd:21,103-104`; item 92).

## 13. UI Lab facts worth reusing

- **Theme precedence**: node override, then ancestor themes over the whole type chain, then project theme. A theme that defines only base types overrides every variation, so looks must be flattened onto targets, not re-based (`README:292-298`; memory `godot-theme-engine-facts`).
- **`has_font` trap**: `has_font` / `has_font_size` return true for every name when the theme has a default font; check `get_theme_item_list` and temporarily null the default (`build_direction.gd:519-521,582-593`).
- **Content margins**: `content_margin -1` falls back to the border or texture margin, so a reskin must write margins explicitly (`build_direction.gd:535-541`).
- **Contrast checker**: WCAG pairs, including the CB inks on the card ground and the bright inks on the frame (`build_direction.gd:88-99,667-707`). Directly reusable for a dark palette; today's `POSITIVE` / `NEGATIVE` on a dark card will flag LOW.
- **Hot slots** that clip or grow: `MetricValue` 104 px, `ChromeClock` 210 px, `TabLabel` 76 px (`build_direction.gd:80-86`).
- **Byte-stable `.tres` writing**: `build_direction.gd:746-785`.
- **Sandbox safety**: every runnable sandbox scene must call `TimeManager.hold_clock` first, or autosave writes into the player's slot (`README:116-117`).
- **Rejected directions**: Erdem rejected the lab's three directions for lack of reference research. Visual work starts from references and his pick (memory `feedback-design-research-first`, `design-work-lessons`).