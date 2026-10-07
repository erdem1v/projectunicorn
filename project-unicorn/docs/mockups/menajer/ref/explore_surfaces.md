# Project Unicorn UI surface inventory (HEAD c706349, after 1abbb7e)

I only read files. Nothing was changed or run. Root is `project-unicorn/`.

## Counting method

**Paint.** These are static grep counts over each surface's scripts, in this order:
1. Visual `add_theme_*_override` call sites. Separation and margin overrides are left out because they are layout.
2. Lines that use `modulate`.
3. Raw `Color(` literals.
4. References to UiTokens colour constants.
5. Calls to colour helpers such as `positive()`, `*_ink()` or `health_color`.

Where the runtime audit has a number I give it too, as **RT**. That audit is `docs/audits/UI_OVERRIDES.md`, which is untracked. It covered only four screens (ekip, satış, olay, bos; `UI_OVERRIDES.md:8`) and its total is 470 rows, 290 of them visual (`:580`).

**Scene overrides are layout only.** Every `theme_override` in every `.tscn` is a separation or margin. TopBar has 22, LeftTabs 14, SettingsModal 14, MonthSummary 12, HuntTab 9, and the rest have fewer.

**Keys.** These count CSV keys referenced directly in each file. The total in `localization/strings.csv` is 2,623.

## Boot and onboarding

There is **no main menu or title screen.** Boot goes to LanguageGate (first boot only), then OnboardingFlow (`main.gd:99-105`). The system menu's "Ana menü" button is disabled and shows a YAKINDA pill (`system_menu_modal.gd:39-40`). The milestone ANA MENÜ button saves and restarts the process (`main.gd:2377-2387`). Onboarding has no load path.

1. **LanguageGate**
   - Files: `scenes/onboarding/LanguageGate.tscn`, `language_gate.gd`.
   - Opens: mounted by `main.gd:108-113` on first boot, or with `--force-language-gate` (`:102`).
   - Layout: full-rect, dark register.
   - Theme variations: CommitButtonDark, DialogueName.
   - Paint: 1 visual override.
   - Keys: 0. The two labels are deliberate literals (`language_gate.gd:9-13`).
   - Shot: `--onboard-shot=0` (`main.gd:1016-1021`).
2. **OnboardingFlow chrome** (header stepper, Back/Next footer, LoadingOverlay)
   - Files: `OnboardingFlow.tscn` (nodes at lines 5-98), `onboarding_flow.gd`.
   - Steps run in the order Character, Origin, Company (`:23-27`).
   - Theme variations: DialogueCard, DialogueGhost, DialogueName, DialogueNumber, ZoneLabel, CommitButtonDark.
   - Paint: 3 visual overrides, 10 colour token refs. It reads the theme with `get_theme_*` (`UI_OVERRIDES.md:637`).
   - Keys: about 8, plus the ONB_* family of 62.
   - Shot: `--onboard-shot=1..3`. The LoadingOverlay has no shot.
3. **CharacterStep** (founder name and portrait pick)
   - Files: `character_step.gd`, with the DialoguePortraitCard component.
   - Uses the 11 painted `assets/art/founders/founder_NN.webp` portraits (`:90`, `:128`).
   - Theme variations (9): Dialogue*, PortraitCell(Selected), *SerifCream, ZoneLabel.
   - Paint: 0 visual overrides, 1 modulate, 1 `Color(`.
   - Keys: 8.
   - Shot: `--onboard-shot=1`.
4. **OriginTraitsStep** (origin pick, traits, 5-skill allocation)
   - Files: `origin_traits_step.gd` (389 lines), with SegmentBar.
   - Theme variations: 12.
   - Paint: 6 visual overrides, 1 modulate, 4 `Color(`, 13 colour refs. This is the most hand-painted onboarding page.
   - Keys: 13, plus ONB_ORIGIN 11, ONB_SKILL 16, TRAIT 16.
   - Shot: `--onboard-shot=2`.
5. **CompanyStep** (name, logo, slogan, preview)
   - Files: `company_step.gd`, with LogoEmblem (`_draw`). Shows the painted founder portrait (`:186`).
   - Theme variations: 10.
   - Paint: 0 visual overrides.
   - Keys: 11, plus COMPANY 65.
   - Shot: `--onboard-shot=3`.
6. **MentorIntroModal**
   - Files: `MentorIntroModal.tscn`, `mentor_intro_modal.gd`.
   - Opens: ModalLayer, after the shell mounts (`main.gd:1853-1860`).
   - Size: 1120×680, centred (`tscn:30`).
   - Frank appears here as an **"FK" initials avatar**, not his portrait (`tscn:55-70`).
   - Theme variations: ModalPanel, Avatar, AvatarInitial, TitleSerif, SectionLabel, ModalTitleSerif, BodyRich, CommitButton.
   - Keys: 6.
   - Shot: `--modal-shot=mentor`.

## Shell (`GameShell.tscn`)

- TopBar runs from 0 to 54 px (`:25`).
- MidRow runs from 54 px to 34 px above the bottom (`:33-34`).
- NewsTicker takes the bottom 34 px (`:58`).
- PanelLayer is layer 9 (`:63`) and ModalLayer is layer 10 (`:66`).
- The centre area is 1836×992 at 1080p (`ACIK_KARARLAR.md:1619-1621`).
- Input (`game_shell.gd:32-85`):
  - Esc closes the top window. If no window is open, it opens the system menu.
  - Space and keys 1-4 are blocked whenever the ModalLayer has a child.

7. **TopBar**
   - Files: `TopBar.tscn` (52 nodes), `top_bar.gd`.
   - Layout: one row, 54 px. It shows logo, company, Cash, MRR, Burn, Net, Runway, Brand, Rep, date, shutter, offer countdown, sprint auto-start chip (duplicated in code, `:54-56`), phase name with 3 dots, and 5 speed buttons.
   - It switches to a compact layout below 1600 px (`:13`).
   - It has **no "Cevap bekliyor" block and no menu button.**
   - Theme variations (12): Chrome*, Metric*, PhaseDot*, SpeedButton*, TopBarPanel.
   - Paint: 5 visual overrides, for example `:198`. The LogoSquare is a ColorRect painted in code (`:53`). RT: 3 visual (`UI_OVERRIDES.md:569`, `:594`).
   - Keys: 18.
   - Shot: appears in every shell shot. The shutter shows in `--finance-shot=kepenk`. The offer and auto-start chips have no shot.
8. **LeftTabs rail**
   - Files: `LeftTabs.tscn` (**84 px wide**, `:15`; buttons 64 px tall, `:36`), `left_tabs.gd`.
   - Contents: 8 tabs from `UiTokens.TABS` (`ui_tokens.gd:347-356`) plus a settings gear (`left_tabs.gd:53`).
   - Badges exist for hr, sales, finance, events and rnd (`:9-14`). The events badge counts `EventGate.queue_size()` (`:138-139`), so it does **not** count papers on the desk.
   - A locked tab is drawn at alpha 0.45 with a YAKINDA pill (`:38-49`).
   - Paint: label colour overrides and icon modulate (`:103-106`). RT: 8 visual plus 10 icon modulates (`UI_OVERRIDES.md:570`, `:611-620`).
   - Keys: 10.
   - Shot: every shell shot.
9. **NewsTicker**
   - Files: `NewsTicker.tscn`, `news_ticker.gd`.
   - Scrolls at 50 px/s (`:31`). The source name is coloured with a BBCode `ACCENT_HEX` (`:132`).
   - It is the **only non-modal notification channel** (`:13-19`).
   - Theme variations: NewsPanel, NewsRich.
   - Keys: TICKER_01..10, which are a fixed contract (`:33-35`), plus NEWS 55.
   - Shot: no dedicated flag (`HARITA:230`).
10. **WindowLayer and WindowFrame**
    - Files: `window_layer.gd`, `window_frame.gd`.
    - Opens on `tab_changed` (`:61-78`). Windows sit in fixed slots, top-left, with a 16 px edge.
    - SPECS (`:29-33`):

      | Window | Size |
      |---|---|
      | finance | 1410×700 |
      | hr | 1200×720 |
      | product | 1424×960 |
      | sales | 1280×760 |
      | rnd | 1280×780 |
      | personal | 1000×640 |
      | events | 900×640 |
      | marketing | 900×640 |
      | hr_dossier | 380×580 |

    - One primary window and one detail window at a time. BuildHUD always draws above the windows (`:142-146`).
    - Windows rebuild on a language or palette change (`:54-55`). They are hidden during the founder's trip (`:109-114`).
    - The frame is a WindowPanel with a × close button and a reserved right gutter (`window_frame.gd:8`, `:17-42`). A page can set its own variation, padding and close button through `frame_options`. The frame has no title bar; each page draws its own heading.
    - Shot: `--tab-shot=<id>`.
11. **BuildBar ("DESTEK" card)**
    - Host: BuildHUDPanel, top-right, 360 px wide, draggable (`BuildHUDPanel.tscn:22-25`, `build_hud_panel.gd:1-14`). Hidden while the city map is open.
    - Files: `build_bar.gd`, `bar_kit.gd`.
    - It is **deliberately theme-independent** (`build_bar.gd:14`) and reads the project theme through `ThemeDB` (`bar_kit.gd:21`).
    - Paint: 9 visual overrides, 2 modulate, 1 `Color(`, 16 colour and 6 size token refs. RT: 24 visual.
    - Shot: incidental only, in any `_seed_theme_surface` shot (`main.gd:636-645`).
12. **ResearchBar**
    - Files: `research_bar.gd`; bar is 76 px tall.
    - Paint: 11 visual overrides, 19 colour and 6 size token refs. RT: 23 visual.
    - Shot: **none**. No shot starts a research run.

## Tab windows

13-16. **Ürün** (product tab, rev 7 sprint screen)
- Files: `product_tab.gd`, plus `product/{area_panel, sprint_panel, sprint_card + SprintCard.tscn, quarter_view, sprint_ui_shared, type_picker, product_model}`.
- Window: FolderWindow variation, its own × button (`:16`). Panel ratios 0.32 / 0.44 / 0.24 (`ui_tokens.gd:609`).
- Four views:
  - **13 Sprint view.** Areas panel, this sprint, next sprint.
  - **14 Release note.** The centre panel in "release" mode (`sprint_panel.gd:57`). It holds the clock with `HOLD_RELEASE_NOTE` (`:12`, `:128`). `sprint_closed` opens the tab automatically (`game_shell.gd:21-24`).
  - **15 Quarter view.** Goal strip, six sprint columns and a PopupMenu (`quarter_view.gd:96`).
  - **16 TypePicker.** Shown before the product type is chosen.
- A sprint decision is a DecisionRow on the card (`sprint_card.gd:95`, `:205`) and opens the EventModal (`docs/audits/urun_rev7/NOTES.md` C2-03).
- Theme variations: about 35 (Folder*, PaperCard*, Area*, Chip*, DataMono*, DecisionRow, GoalStrip, InkButton, PrimaryButton*, …).
- Paint: **67 visual overrides, 1 modulate, 112 colour refs, 21 helper calls**, plus `_draw` code (`sprint_ui_shared.gd:179`, `:241`). The UI_OVERRIDES audit predates this rework and still lists deleted files (`:702-709`).
- Keys: about 120 direct, plus the PROD_* (502) and PRODUCT_* (198) families.
- Shots: `--product-shot=c1..c5|cards|flow|edge:<name>` uses debug fixtures through `game_shell.gd:135-149`. `--product-shot=live:pick|plan|active|b2c_mvp|b2b_requests` uses the real sprint engine (`main.gd:1485-1527`).
- Approval: **TR/EN onay bekliyor** (2b2d9b5, 1abbb7e), and open decision 96.

17. **Satış**
- File: `sales_tab.gd` (607 lines).
- Layout: two columns. Left is pipeline plus sales desk; right is the account ledger (`:22`). B2C runs show an empty state with a reason (`:181`).
- The steward picker is an HRPopover (`:515-537`).
- Theme variations include ChromeTabButton, an open exception to the Chrome rule (`CLAUDE.md:118-119`).
- Paint: static count shows 0 visual overrides but 22 colour refs. **RT: 95 overrides, 61 of them visual.**
- Keys: 58 direct, plus SALES 150 and B2B 84.
- Shots: `--sales-shot=pipeline|desk|b2c`, `--tab-shot=sales`.

18. **Ekip, KADRO view (staff ledger)**
- Files: `hr_tab.gd`, `hr_ledger.gd`, `hr_ui_shared.gd`.
- Window is 1200 wide; the mockup says 1000 (open decision 65).
- Rows carry 32 px busts (`hr_ledger.gd:80`). Clicking a row opens the HRPopover menu (`hr_tab.gd:474-490`).
- Paint: 15 visual overrides, 4 modulate, 42 colour refs. **RT: 227 overrides, 158 visual, the largest measured in the game** (`UI_OVERRIDES.md:565`). The morale bar reads the theme before the node enters the tree (`UI_OVERRIDES.md:624`).
- Keys: about 51, plus HR 252.
- Shots: `--hr-shot=ekip|bos|egitim|zam|menu|cikar|cikar-eksi` (`main.gd:1212-1329`).

19. **Ekip, GÖREVLER view (task matrix)**
- File: `hr_assignments.gd`. Matrix cells are drawn in `_draw` (`:164`).
- Paint: 2 visual overrides, 10 colour refs.
- Keys: 9.
- Shots: `--hr-shot=gorevler|gorevler-bos`.

20. **Ekip dossier (detail window)**
- File: `hr_dossier.gd`. Opens with `open_detail` (`window_layer.gd:83-93`), size 380×580.
- Opened from the ledger or by clicking a person in the office. There is a founder variant (`:4-6`).
- Shot: `--office-shot=<o>:<h>:hr_dossier`. The founder variant has no shot.

21. **Finans, Özet**
- Files: `finance_tab.gd`, `finance_ozet_view.gd` (777 lines), `cash_curve.gd`, `investor_appetite_ui.gd`.
- Contains a Frank mentor card that is quote text only (`:431-442`, `:755-769`).
- The Özet/Yatırım segment buttons use modulate alpha (`finance_tab.gd:92-96`).
- Paint: 4 visual overrides, 4 modulate, 42 colour refs, 16 helper calls.
- Keys: 50, plus FIN 71.
- Shots: `--finance-shot=ozet|artida|uyari|kepenk|signal`, `--hr-shot=gider`.

22. **Finans, Yatırım (HuntTab)**
- Files: `HuntTab.tscn`, `hunt_tab.gd`.
- Has a Frank strip in its title bar (`:71`, `:85`).
- Every label goes through a local `_label(text, colour, size)` helper with raw sizes, for example 14 (`:107`, `:207`).
- Paint: 30 colour refs and **29 size refs**.
- Keys: 65, plus HUNT 58 and SEED 86.
- Shots: `--vc-shot=hunt|hunt_closed`.

23. **Kişisel**
- File: `personal_tab.gd`. Shows the **painted founder portrait** (`:200-213`).
- Paint: 5 visual overrides, 30 colour refs.
- Keys: 27.
- Shot: `--tab-shot=personal`.

24. **Ar-Ge**
- Files: `rnd_tab.gd` plus `rnd/{tree_view, detail_panel, assign_panel, ui_shared}`.
- Tiles are positioned absolutely and links are drawn in `_draw`.
- Paint: 15 visual overrides, 81 colour refs.
- Keys: about 54, plus RND 93 and PROD_RND 72.
- The Turkish text is marked "WORKING TR" (`:30-31`).
- Shot: `--tab-shot=rnd`.

25. **Olaylar** (the inbox target)
- Files: `events_tab.gd` (77 lines), `desk_papers.gd`.
- Window: 900×640.
- Contents: Frank's latest line as a quote with no portrait (`:44-49`), then rows of desk papers.
  - Engine papers come from `EventGate.desk_papers` and carry id, title, category, weeks_left and expiring (`presenter.gd:115-129`).
  - Reminders cover phase gate, term sheets, Atlas files and B2B expansion (`desk_papers.gd:30-54`).
- Clicking an engine paper opens the EventModal. Clicking a reminder jumps to its tab (`:84-93`).
- There is **no reading pane, no history or archive, no unread state and no sender avatar.**
- Live cards: 32 in total, of which 25 are interrupts, 6 are papers and 1 is info. Papers are never queued (`engine.gd:379-382`).
- Shot: `--tab-shot=events`.

26. **Pazarlama**
- Locked placeholder page "İçerik yolda" (`window_layer.gd:167-173`; locked to the EA build at `ui_tokens.gd:353`).
- Shot: `--tab-shot=marketing`.

Ayarlar is not a tab. The rail gear opens SettingsModal (item 36).

## PanelLayer (layer 9)

This layer keeps Space and 1-4 working (`hr_ui_shared.gd:385-397`).

27. **HRPopover**
    - At least 268 px wide (`:15`). Hosts the HR row menu and the Sales steward picker.
    - Shot: `--hr-shot=menu|cikar`. The steward picker has no shot.
28. **HRAtlasModal**
    - 1440 px wide for search, **1560 for candidate files**, wider than the 1200 Ekip window (`:24-25`).
    - Paint: 34 colour refs.
    - Keys: 19.
    - Shot: `--hr-shot=atlas|dosyalar`.
29. **TrainingModal**
    - 760 px wide (`tscn:35`).
    - Keys: 12.
    - Shot: `--hr-shot=egitim-modal`.
30. **WorkHoursModal**
    - 1000 px wide.
    - Paint: 9 visual overrides, 3 `Color(`, 31 colour refs, 6 helper calls.
    - Keys: 25.
    - Shot: `--hr-shot=saatler|saatler-gece`.
31. **RnDCardModal**
    - Mounted by `main.gd:2217-2236`, which queues up to 2. Width 640 for a discovery card, 720 for a note (`:35-36`).
    - Shows no effect chips, by rule (`:9-20`).
    - Keys: 13.
    - Shot: `--modal-shot=rnd-note|rnd-discovery|rnd-discovery-line`.

## ModalLayer (layer 10)

32. **EventModal**
    - Opens at `main.gd:1912-1934`. It pauses the clock and never stacks.
    - Layout: a scrim rgba(5,7,9,.62) (`ui_tokens.gd:203`) under a ModalCard 780 wide and at least 420 tall (`event_modal.gd:87-93`).
    - Speaker strip: a 24 px avatar (`:221-241`).
    - **Frank speaks on 17 of the 32 live cards. This is the only place his oil portrait renders** (`:247-263`; path set at `character_registry.gd:407`). Every other speaker gets a PersonBust.
    - Effect chips come from FIXED_CHIPS and `_describe_modifier` (`:26-43`).
    - Paint: RT 20 overrides, 10 visual. The Dimmer is a ColorRect.
    - Keys: 46, plus card text stored inline in the card JSON.
    - Shots: `--event-shot=<id>`, `--b2b-shot=retention|retention_capped|escalation|expansion|deal|angel|weekly` (deal and angel show the Frank portrait), `--vc-shot=k10`. All of these are mounted **without the shell** (`main.gd:463-468`).
33. **ConfirmModal**
    - 440×220, widening to 520 with three buttons (`confirm_modal.gd:7-8`).
    - Shot: `--modal-shot=confirm|confirm3`.
34. **HRActionModal**
    - Same host as ConfirmModal (`main.gd:2176`), at least 420 wide.
    - Fonts and sizes are overridden in code (`:9-10`). Paint: 10 visual overrides.
    - Shot: `--hr-shot=zam|cikar|cikar-eksi`.
35. **MonthSummaryModal**
    - 660×580. The dark chrome bands are StyleBoxFlat objects built in code (`:6-7`, `:145`).
    - Shows Frank as the **FK initials avatar** (`tscn:109-146`).
    - Shot: `--modal-shot=month`.
36. **SettingsModal**
    - 640×820, six sections (`:2-3`). UI scale runs from 0.75 to 1.25 (`display_settings.gd:51`).
    - Shot: `--modal-shot=settings`. The dropdown popups have no shot.
37. **SystemMenuModal** (pause/escape menu)
    - 380×430. **The only way in is Esc**; there is no on-screen button.
    - Shot: `--modal-shot=system`.
38. **SaveLoadModal**
    - 660×580.
    - Shot: `--modal-shot=saveload`, which writes a real quicksave.
    - F5 quicksave and F9 quickload give **no feedback** (`main.gd:2271-2278`).
39-41. **MeetingPanel** in three modes: **39** sales table, **40** negotiation (Perde 2), **41** VC sitting
    - Files: `meeting_panel.gd` (787 lines), `meeting_panel_option.gd`, `meeting_ruler.gd`, and the sales and VC adapters.
    - Layout: a full-screen clear shield plus a dock on the right taking 0.34 of the width (`:13-14`, `:23`). Counterpart bust is 96 px (`:24`).
    - Paint: 6 visual overrides, 3 modulate, 32 colour refs, 15 helper calls, and 7 `_draw` sites.
    - Keys: 55 in the files; MEETING_* has 59 and VC_* 112 in the CSV. There are also **55 "PH:" placeholder strings**, mostly SALES_ANS_* answer lines.
    - Shots: `--meeting-shot=probe|locked|won|lost|handoff` (sales), `--meeting-shot=open|sorgu|sheet|callback|ret|seed|long` (VC), `--negotiation-shot=open|countered|insult|confirm`, `--travel-shot`.
    - Open decisions 93 and 95.
42. **TermSheetTableScene**
    - Full-screen dark register. Lead investor bust at 64 px (`:17`, `:305`). Frank appears as a monologue line (`:230`).
    - Shots: `--vc-shot=table|table_final|table_walk|table_other|seed_table`, all standalone.
43. **EndingScene** (newspaper; also the milestone mode)
    - Full screen: about 70% paper and 30% dark rail (`:4-6`). Frank appears as a text strip (`:193-204`).
    - 18 theme variations, the best-themed large surface.
    - Shot: `--ending-shot=<id>`, including bankruptcy1, bankruptcy2, bankruptcy3 and bootstrap_milestone.
    - The shutter (kepenk) state has no surface of its own. It shows in three places: the TopBar label (`:173`), the finance mentor card (`:761-769`) and the bankruptcy paper.

## Office overlay

44. **OfficeView (3D)**
    - Its colours are scene data, not theme tokens. It renders soft above 1080p (open decision 70).
    - Shots: `--office-shot`, `--day-shot`.
45. **Head icons and floor rings**
    - Head icons are Sprite3D (`office_actor.gd:9-28`). The founder ring is #f0b429e6 and the selection ring is white (`office_constants.gd:116-117`).
    - **There are no speech or activity bubbles.** The return-trip question goes to the ticker (`office_travel.gd:97`).
46. **Person hover tooltip**
    - `OfficeView.tscn:143-151`, `office_view.gd:120-130`.
    - **No shot.**
47. **NoticeStack**
    - Bottom right, 340 px wide, at most 4 cards plus a +N badge (`:8-10`). Any open window covers it.
48. **OfficeHud**
    - Move button, move countdown and move toast (`:9-14`).
    - The toast and countdown have no shot.
49. **City map and office card**
    - The map chips use dark-on-dark pills, a Chrome-rule exception (open decision 74; `office_city.gd:330-339`). The office card is 340 px wide.
    - Shot: `--office-shot=city:<h>[:card|crown]`. The hover card has no shot.
50. **MeetingInvite**
    - 52 px ring and a 272 px call card, plus a "postponed" toast (`:15-25`).
    - Shot: `--travel-shot`.
51. **Founder trip and meeting room**
    - Shots: `--travel-shot`, `--office-shot=meet:<h>[:cast]`.

## Cross-cutting

52. **Built-in tooltips.** 24 scripts set `tooltip_text`. The tooltip style is the dark chrome one (`build_theme.gd:556-560`). The meeting die tooltip is custom (`meeting_panel.gd:681-697`).
53. **Toasts.** There are three separate ad-hoc implementations and no shared component: office move, invite postponed, and ending share (`ending_scene.gd:49`).
54. **PopupMenu and OptionButton popups.** Both use the SettingsPopup variation.

**Debug-only screens:**
- ThemeProbe (`--probe-shot`).
- The founders sheet and the navigation overlay (`main.gd:732-735`).
- F-key debug actions (`game_shell.gd:92-203`).

## Shared building blocks

- **UiTokens** (`ui_tokens.gd`): `THEME_STAMP` 16 (`:44`).
- **build_theme.gd**: about 149 named variations. Fonts are Source Serif 4, IBM Plex Sans, JetBrains Mono and Noto Symbols 2 (`:22-29`).
- **UiFactory**: makers for pill, badge, chip, label, card, avatar and bust, dot and close button (`:12-215`). Used by about 55 scripts.
- **HRUiShared**: about 30 helpers, used by 31 scripts, including the event modal, ending, R&D card, product, meeting panel and office overlays. It is effectively the global UI kit, though it lives in `tabs/hr`.
- **SprintUiShared**: used by the product tab only.
- **RnDUiShared**: used by product, sales, ResearchBar and the R&D card.
- **Components:**

  | Component | Used by |
  |---|---|
  | bar_kit | BuildBar, ResearchBar |
  | star_rating | 11 consumers |
  | value_slider | HRActionModal |
  | segment_bar | OriginTraitsStep |
  | logo_emblem | CompanyStep |
  | radial_dial | TermSheetTableScene |
  | cash_curve, investor_appetite_ui | Finans Özet |
  | dialogue_portrait_card | CharacterStep |
  | desk_papers | Olaylar, NoticeStack |
  | `avatar_bust.gdshader` | avatar busts |

- **PersonBust** (`person_bust.gd:1-46`) renders busts of the 3D characters from a `look` in an off-screen studio. With no display it returns null. **This is the existing pipeline for Frank's new portrait.** Frank has no `look` today (`character_registry.gd:396-408`). The founders follow the pattern `LookSystem.FOUNDER_LOOKS` plus `founder()` (`look_system.gd:19`, `:103`).

## Totals

- **51 surfaces plus 3 cross-cutting families, 54 rows.**

**Ten most hand-painted surfaces** (static index; RT where measured):

| Rank | Surface | Index |
|---|---|---|
| 1 | Ürün sprint screen | about 201 |
| 2 | Ar-Ge | about 99 |
| 3 | Ekip KADRO | about 78; RT 158 visual |
| 4 | BuildBar + ResearchBar | about 70; RT 47 visual |
| 5 | Finans Özet | about 67 |
| 6 | Yatırım | 38, plus 29 hand-set sizes |
| 7 | Satış | RT 61 visual |
| 8 | MeetingPanel | about 56 |
| 9 | Onboarding | about 52 |
| 10 | WorkHoursModal | about 50 |

Next after those: HRAtlasModal about 40, Kişisel about 35, office overlays about 27, HRActionModal about 24.

**Surfaces with no shot flag:**
- OnboardingFlow LoadingOverlay
- ResearchBar
- TopBar offer and auto-start chips
- Quarter goal popup
- Sales steward popover
- Person hover tooltip
- City hover card
- OfficeHud toast and countdown
- Invite postponed toast
- Ending share toast
- Founder dossier
- Settings popups
- Built-in tooltips and the meeting die tooltip
- NewsTicker (no dedicated flag)

A further problem: the EventModal, TermSheetTable, Ending and b2b shots all render without the shell.

## Half-built or flagged

- **Missing:** a main menu; Pazarlama is a placeholder; the demo WISHLIST button does nothing (`ending_scene.gd:34`); there are 55 "PH:" strings; sprint decision cards exist only as test fixtures (`HARITA:123`).
- **TR/EN onay bekliyor** in these commits: 2b2d9b5, 1abbb7e, cf80260, 4ebcc5d, eba2140, 1004b5c, 1b8f2f3, f75d3e6, c706349.
- **Open decisions affecting UI:** 61 (cream palette WORKING colours), 65 (window sizes; its reference to `creation_flow.gd` is **stale**), 70, 72, 73 (its reference to `negotiation_scene.gd` is **stale**), 74, 92 (founder painted portrait vs 3D), 93, 94 (Frank's portrait was kept), 95, 96.
- **Written rules that block the redesign as stated:**
  - `CLAUDE.md:113-119` requires a cream body and limits the dark Chrome family to TopBar, MonthSummary and NewsTicker. Charcoal windows contradict it.
  - `GUNCELLEMELER.md:377` says "Frank and VC surfaces don't change." Retiring Frank's portrait contradicts it.
- **Stale or untracked material:** `UI_OVERRIDES.md` covers only 4 screens and lists deleted files. `sandbox/ui_lab` holds the 3 rejected directions and the generator for the override audit.
- **Data sources for a "Cevap bekliyor" block:**
  - `EventGate.has_pending` and `queue_size` (`event_gate.gd:63-68`)
  - Expiring papers (`presenter.gd:126`)
  - A ringing call (`main.gd:60`, `:1962-1978`)
  - The release-note hold
  - A term sheet whose decision is due, and a ready phase gate (`desk_papers.gd:30-41`)
- **Layout limits:**
  - The centre area is 1836×992 at 1080p.
  - A 184 px rail leaves about 1736 px of width.
  - The product window is 1424 wide and BuildHUD starts at x ≥ 1540.
  - A taller two-row top bar pushes the 960 px product window past the available height.
  - At 1.25 UI scale the logical screen is 1536×864.