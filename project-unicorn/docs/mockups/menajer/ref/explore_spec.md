# Menajer Masası: design spec extraction for the redesign plan

The source of truth is `build2.py`, revision 2 (`NOTES.md:52-54`). `ekip.html` and `olay.html` are generated from it; I checked that their CSS is the same (`ekip.html:110-112` matches B2:120-122). The final frames are `ekip.png` (832875 B) and `olay.png` (998691 B), byte-identical in size to `ekip_v2_r4.png` and `olay_v2_r4.png`.

**Citation keys:**
- **B2** = `scratchpad/mockups/menajer/build2.py`
- **N** = `mockups/menajer/NOTES.md`
- **R** = `ui_research/RAPOR.md`
- **S** = `mockups/data/screens.md`
- **FM** = `ui_research/fm.md`
- **ST** = `ui_research/strategy.md`
- **CJ** = `tasks/wml11kkqg.output`. In CJ, "F*n*" means `result.critique.directions[key=menajer].findings[n]`, "C*n*" means `result.critique.cross[n]`, and "W*n*" means `result.final.menajer.weaknesses[n]`.
- Repo paths are relative to `project-unicorn/`.
- Every contrast ratio marked "computed" is my WCAG 2.x calculation from the hex values.

---

## 1. Token set used

### 1.1 Colour

**Root tokens (B2:17-24):**

| Token | Hex | Role | Contrast (computed) |
|---|---|---|---|
| `--shell` | #14110E | Top bar background (B2:41) | |
| `--rail` | #181512 | Rail background (B2:83) | |
| `--tick` | #100E0B | Ticker background (B2:98); page background (B2:31); veil and halo base | |
| `--panel` | #1E1B18 | Window body (B2:125); option bar (B2:533) | |
| `--panel2` | #27231F | Window header (B2:126); time block (B2:67); active rail row (B2:88); selected inbox row (B2:499); stake box (B2:527) | |
| `--panel3` | #2E2924 | Idle speed key (B2:70); trait box (B2:379); face disc (B2:134, literal) | |
| `--line` | #3A342D | All 1 px rules and separators | 1.39 on panel |
| `--line2` | #4A4239 | Window border (B2:125); outline buttons; tracks; idle phase dot | 1.74 on panel |
| `--ink` | #E9E4DA | Primary text; markers; s3 | 13.53 on panel |
| `--ink2` | #B3AA9E | Secondary text and labels | panel 7.48 · panel2 6.80 · rail 7.93 · shell 8.21 · ticker 8.41 |
| `--ink3` | #9A9184 | Idle rail icon; YAKINDA; ticker separator; stake "·" | panel 5.52 · rail 5.85 |
| `--amber` | #F2B53A | Primary fill; active speed outline; gate frame, dot and words | 10.25 on shell |
| `--on-amber` | #17130A | Text on amber | 10.09 |
| `--s1`..`--s5` | #968D80 / #BDB5A9 / #E9E4DA / #9CC45A / #4FD27A | Skill value ramp: 1-2 / 3-4 / 5-6 / 7-8 / 9-10 | 5.24 / 8.44 / 13.53 / 8.54 / 8.84 on panel |
| `--pos` | #4FD27A | NET, Artıda, moral ≥50, notice dot, cash gain | Same hex as s5 |
| `--neg` | #EC6A5E | Moral <35, rail badges, risk icon, inbox MORAL 22 | 5.54 on panel |
| `--warn` | #E8913A | Moral 35-49 only (B2:320; N:41) | 6.97 |

**Literals used outside the tokens:**
- #FFFFFF: KASA value, active rail name, window h1, active tab, row name, risk name, pane h2 (B2:52, 90, 127, 342, 365, 347, 513).
- Logo: tile #E9E4DA with glyph #181512 (B2:139).
- Badge text #1B0F0D on neg (B2:94), 6.06 computed.
- Float background rgba(30,27,24,.96), which is panel at 0.96 (B2:106).
- Veil rgba(16,14,11,.16) (B2:121). Halo fill rgba(16,14,11,.6) with glow rgba(16,14,11,.55) (B2:122).
- `tag.new`: border #6A5F52, text #DCD4C8 (B2:132).
- `tag.bad`: background rgba(236,106,94,.16), border rgba(236,106,94,.6), text #F49A90 (B2:133). Text contrast 6.41.
- Risk strip: background #2B1A17, border #6E3129, label and chevron #F2A49C (8.37) (B2:346-351).
- Tooltip background #0F0D0B (B2:359).
- Row rule rgba(58,52,45,.75) (B2:364).
- Role band rgba(233,228,218,.07) (B2:371).
- Morale notch #8A8174 (B2:386). Inbox list background #1A1714 (B2:495). Portrait well #16120F (B2:522). Relation chip border #6A5F52 (B2:517).
- Warn-glyph inner stroke #2A1A17 (B2:161). Window inset highlight rgba(255,240,220,.05) (B2:125).
- Glows: amber rgba(242,181,58,.22) and .08 (gate dot, B2:77), .2 (inbox dot, B2:506); green rgba(79,210,122,.18) (notice dot, B2:115).

**Data hues (the designer marked these as "data, not tokens", N:42):**
- Topic pills (B2:488): MENTOR #C9A8E6, SATIŞ #6FC9B6, EKİP #7FB6DE. Contrast 8.69, 9.10 and 8.20 on #1A1714.
- Publications (B2:229): Sektör Telgrafı #7FB6DE, Ekonomi Postası #E3A0BE, TeknoGündem #6FC9B6, Girişim Bülteni #BCA7E8. Contrast 8.85-9.82 on tick.

The office image gets `filter: saturate(.85) brightness(.97)` (B2:38).

**Colour rules in code:**
- `band(v)`: ≤2 s1, ≤4 s2, ≤6 s3, ≤8 s4, else s5 (B2:315-316). It applies to all 35 cells, including off-role cells.
- `moral_col(m)`: <35 neg, <50 warn, else pos (B2:319-320).
- Amber covers only the time block state and the single primary action. Selected states use white or ink, not amber. Rail badges are red because both badge reasons are dangers (N:38-41).

**Problems with the ramp (computed):**
- Luminance is not monotonic. Y values are s1 .271, s2 .467, s3 .779, s4 .473, s5 .492. The ratio s4 to s5 is 1.04 and s2 to s4 is about 1. In greyscale or under colour blindness, "3-4", "7-8" and "9-10" read as the same value, and "5-6" reads as the brightest.
- s1 on the role band is 4.42:1 (<4.5). Band alpha .06 gives 4.54 and .05 gives 4.66.
- The repo has a colour-blind palette (`UiTokens` POSITIVE_CB/NEGATIVE_CB, `scripts/theme/ui_tokens.gd:131-138`). It has no twin for this ramp, warn, the topic hues or the publication hues. Its CB-negative is orange (#B36B00 / #E69F00), which would collide with warn #E8913A.

### 1.2 Typography

**Families loaded (B2:8-13):**
- Barlow Condensed 500/600/700. 500 is never used.
- IBM Plex Sans Condensed 400/500/600. Only 400 is used.
- IBM Plex Sans 400/500/600/700 and italic 400.
- Source Serif 4 (opsz) 400/600 and italic 400/500. Only regular 400 is used.

Body defaults are Plex Sans 400, `tabular-nums`, antialiased (B2:32). Families are set at B2:25-28.

**Not in the repo:** Barlow Condensed (all weights), Plex Sans Condensed, Plex Sans 500 and 700. `assets/fonts/sans/` holds only IBMPlexSans-Regular and SemiBold. `serif/` holds Regular, Semibold and It. `mono/` holds JetBrains Mono. Using these fonts reopens Set A (R:810 Q7; cost note in CJ final.menajer.cost).

**Roles.** "Cond" = Barlow Condensed, "Plex" = IBM Plex Sans, "PlexC" = IBM Plex Sans Condensed. "lh" = line height.

| Role | Family / weight | Size / lh | Tracking | Case | Colour | Ref |
|---|---|---|---|---|---|---|
| Micro label (`.lbl`: KPI keys, list header, ROLLER, kicker) | Cond 600 | 14/16 | .06em | upper (CSS) | ink2 | B2:34 |
| Top-bar key (KASA, RUNWAY, MRR...) | Cond 600 | 14 | .06em | upper | ink2 | B2:51 |
| KASA (hero) | Plex 600 | 30 | -.01em | – | #FFF | B2:52 |
| Top-bar value | Plex 500 (Runway 600) | 18 | – | – | ink, or pos for Artıda | B2:53, 189 |
| NET delta | Plex 500 | 15 | – | – | pos | B2:54 |
| Unit "/ay" | Plex 400 | 13, 3 px left margin | – | – | ink2 | B2:55 |
| Company name | Cond 700 | 20/22 | .01em | as typed | ink | B2:43 |
| Phase "BOOTSTRAP" | Cond 600 | 13/14 | .08em | literal caps | ink2 | B2:45 |
| Date line | Plex 500 | 16/20 | – | – | ink | B2:59 |
| Week-bar hour labels | Plex 400 | 12/12 | – | – | ink2 | B2:61 |
| Clock "11:00" | Plex 600 | 22/24 | -.01em | – | ink | B2:68 |
| Speed key | Cond 700 | 16 | .02em | – | ink2, or ink when active | B2:70-71 |
| Gate label "Cevap bekliyor" | Cond 700 | 19/20 | .06em | upper | amber | B2:78 |
| Gate subline | Plex 500 | 13/16, 3 px top margin | – | – | ink2 | B2:79 |
| Rail name | Cond 600 | 17/20 | .06em | upper | ink2, or #FFF when active | B2:87, 90 |
| Rail "YAKINDA" | Cond 600 | 13/14 | .08em | literal caps | ink3 | B2:93 |
| Badge | Plex 700 | 13 | – | – | #1B0F0D | B2:94 |
| Ticker | Plex 400 / publication 600 | 14/40 | – | – | headline ink2, publication in its hue | B2:100-102 |
| Window title h1 (Ekip) | Cond 700 | 40/40 | .02em | upper | #FFF | B2:127 |
| Window title h1 (Olaylar) | Cond 700 | 36/36 | .02em | upper | #FFF | B2:493 |
| KPI value | Plex 600 | 26/30 | – | – | ink | B2:335 |
| Legend range | Plex 600 | 17/24 | – | – | s1..s5 | B2:338 |
| Segment tab | Cond 600 | 18 | .07em | literal caps | ink2, or #FFF when active | B2:341-342 |
| Primary button | Cond 700 | 19 | .03em | sentence | on-amber | B2:129 |
| Ghost button | Plex 500 | 15 | – | sentence | ink | B2:130 |
| Small ghost button | Cond 600 | 17 | .03em | sentence | ink | B2:393 |
| Outline chip (mesai) | Plex 400 | 15 | – | sentence | ink | B2:344 |
| Tag / chip | Cond 700 | 13 | .07em | literal caps | per variant | B2:131 |
| Column header | Cond 600 | 14/16 | .05em | upper | ink2 | B2:354 |
| Group header | Cond 600 | 15 | .07em | literal caps | ink | B2:361 |
| Row name | Plex 600 | 15/18 | – | – | #FFF | B2:365 |
| Role line | PlexC 400 | 13/16 | – | CSV case | ink2 | B2:366 |
| Skill cell | Plex 500 (main 700 + underline, secondary 600) | 16/40 | – | – | ramp | B2:367-370 |
| Task, Durum | PlexC 400 | 15 | – | – | ink | B2:373, 377 |
| XP % | Plex 400 | 14 | – | – | ink2 | B2:376 |
| Trait label | PlexC 400 | 13 | – | sentence | ink2 | B2:380 |
| Salary | Plex 400 | 15, right-aligned | – | – | ink | B2:381 |
| Morale value | Plex 700 | 16, right-aligned in 26 px | – | – | band | B2:383 |
| Risk name / MORAL key / value | Plex 600 16 / Cond 600 14 .06em / Plex 700 18 | – | – | – | #FFF / #F2A49C / neg | B2:347-350 |
| Tooltip | Plex 400 | 13 | – | – | ink | B2:359 |
| Inbox sender | Plex 400 | 13/16 | – | – | ink2 | B2:502 |
| Topic pill | Cond 700 | 13 | .07em | literal caps | hue | B2:503 |
| Inbox subject | Plex 600 | 16 | – | – | ink | B2:505 |
| Inbox time / amount | Plex 400 | 13 | – | – | ink2 | B2:507 |
| Inbox moral value | Plex 700 | 15 | – | – | neg | B2:508 |
| Inbox preview | Plex 400 (italic for reasons) | 14/20, ellipsis | – | – | ink2 | B2:498, 553-555 |
| Pane title h2 | Cond 700 | 36/40 | .03em | upper | #FFF | B2:513 |
| Sender name / role | Plex 600 16 / Plex 400 15 | – | – | – | ink / ink2 | B2:515-516 |
| Relation chip (NÖTR) | Cond 700 | 13/20 | .08em | literal caps | ink | B2:517 |
| Narration | Plex 400 | 17/26 | – | – | ink | B2:518 |
| Frank quote | Source Serif 4, 400 | 21/31, `text-wrap: pretty` | – | – | ink | B2:520 |
| Permanence line | Plex 400 | 14 | – | sentence | ink2 | B2:526 |
| Stake key | Cond 600 | 14/16 | .07em | literal caps | ink2 | B2:529 |
| Stake value | Plex 700 | 36/44 | -.01em | – | pos / ink | B2:530 |
| Kabul et | Cond 700 | 24 | .03em | sentence | on-amber | B2:532 |
| Locked option name / reason | Cond 700 22 .03em / Plex 15 | – | – | – | ink at .5 / ink2 | B2:535-536 |
| BuildHUD title / key / value / action | Cond 700 18 .02em / Cond 600 14 .06em / Plex 14 / Cond 600 14 .06em | – | – | – | ink / ink / ink2 / ink | B2:109-113 |
| Notice tag / text | Cond 600 14 .08em / Plex 500 15 | – | – | – | ink2 / ink | B2:116-117 |
| Ofisi taşı | Plex 500 | 15 | – | – | ink | B2:118 |

**Size inventory.** The mockup uses 21 distinct sizes: 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 28, 30, 36 and 40. The repo ladder is 9/10/11/12/13/15/16/22, with editorial sizes 24/26/32/44/52 (`ui_tokens.gd:246-262`; CLAUDE.md:104-105).

**Recommendation:** consolidate to one ladder, for example MICRO 12 · CAPTION 13 · LABEL 14 · DATA 15 · BODY 16 · LEAD 17 · TITLE 18 · BUTTON 20 (19/20) · QUOTE 21 · CLOCK 22 · CTA 24 · KPI 26 · HERO 30 · H1 36 · DISPLAY 40. Retire 28, which is used only by the "·" glyph.

**Casing rule** (N:50 round 5): caps only for one- or two-word labels. Buttons and sentences use sentence case. CSS uppercase runs with `lang="tr"` (B2:280). In the game, caps must come from `UiTokens.tr_upper` or `Fmt.upper`, which are Turkish-aware.

### 1.3 Spacing, radii, borders, shadows, veil

**Spacing values used:** 2, 3, 4, 5, 6, 7, 8, 9, 10, 12, 14, 16, 18, 20, 22, 24, 28, 32 and 36 px. Examples: gaps 4/6/8/10/12/14/16; paddings 0 16 0 20 (rail row, B2:84), 0 28 (KPI, B2:334), 16 24 20 (Ekip body, B2:345), 28 32 (pane, B2:509), 14 20 0 24 (message, B2:497).

The repo scale is 2/4/6/8/12/16/20/24 (`ui_tokens.gd:280-287`). The mockup adds 10, 14, 18, 22, 28 and 32. Decide whether to extend the scale or snap these values.

**Radii:**

| Radius | Used on |
|---|---|
| 1 | Week marker, skill underline |
| 2 | Week track, XP track, active rail marker (0 2 2 0) |
| 3 | Tag, pill, relation chip, morale bar |
| 4 | Buttons, speed keys, tooltip, close button |
| 5 | Trait box |
| 6 | Risk strip, float panels, stake box, option bar, portrait |
| 8 | Window, halo |
| 11 | Badge |
| 16 | Face disc |

The repo has every RADIUS_* at 2 and RADIUS_WINDOW at 4 (`ui_tokens.gd:293-303`).

**Borders:** 1 px line or line2 everywhere. Others:
- Row rule: 1 px rgba(58,52,45,.75).
- Inset amber outline: 2 px on the active speed key (B2:71) and on the gated time group (B2:74).
- Underline: 2 px on the active tab, ink, `bottom: -1` (B2:343) and on the main skill, 16×2 (B2:369).
- Left marker: 3 px on the active rail row and the selected message (B2:89, 500).
- Span header underline: 1 px line2 (B2:357).

**Shadows:**
- Window: `0 32px 64px rgba(0,0,0,.55)`, `0 8px 16px rgba(0,0,0,.38)`, and inset `0 1px 0 rgba(255,240,220,.05)` (B2:125).
- Float: `0 10px 24px rgba(0,0,0,.42)` (B2:106).
- Tooltip: `0 6px 14px rgba(0,0,0,.45)` (B2:359).
- Gate dot rings: 4 px at .22 and 9 px at .08 (B2:77).

**Veil and scrim:**
- Overall veil rgba(16,14,11,.16) over the office area at (184,64) 1736×976, z10 (B2:121).
- Halo z11, radius 8, fill rgba(16,14,11,.6), `box-shadow: 0 0 110px 50px rgba(16,14,11,.55)`. A script snaps it to the window rect (B2:122, 483, 605). The glow fades about 160 px out from the window edge (B2:120).
- Measured office-strip brightness: 0.39-0.41, against 0.50 today (N:58; CJ final notes).

**Z order:** veil 10 < halo 11 < floats 20 < window 30 < rail 40 < top bar and ticker 50.

### 1.4 Heights, widths, icons, shell geometry

**Shell geometry:**
- Canvas 1920×1080.
- Top bar 64 px, up from 54 (B2:41).
- Rail 184 px wide at (0,64), 976 tall (B2:83).
- Ticker 40 px at y=1040 (B2:98).
- The office image keeps today's framing at (84,54), 1836×992 (B2:38). The rail and top bar overlap its edges (N:43).

**Top bar, left to right:**
1. Brand block, 184 wide with a right rule (B2:42): 20 px left padding, 32 px logo, 12 gap, name, then phase row (BOOTSTRAP plus three 6×6 dots, gap 6, 3 px top margin) (B2:44-47).
2. Metric grid, padding 0 28 0 24. Columns `40px auto 32px 58px auto 32px 1px 32px 52px auto 36px 52px auto`, rows `36px 20px`, baseline-aligned (B2:48-50).
   - Row 1: KASA $10.000 | RUNWAY Artıda | separator (column 7, spans both rows, 4 px vertical margin, B2:57) | MRR $4,0K | BURN $1,5K/ay.
   - Row 2: NET +$2,5K/ay (under KASA) | – | MARKA 50 | İTİBAR 0 (B2:187-198).
3. Day block: flex:1, min-width 300, padding 0 28, left rule (B2:58).
   - Date text starts at x 887 (N:56).
   - Week bar, 9 px top margin, gap 10 (B2:60): track flex × 4 px, line2, radius 2. Fill is ink2 up to 25% (B2:63). Seven hour ticks every 12.5%, 1×4 px, 6 px below the track (B2:64, 183). Marker 2×14 px in ink at the current hour, top -5 (B2:65).
4. Gate slot, only in the gated state: padding 0 24 0 22, gap 14, left rule (B2:73).
5. Time block: panel2, left rule, gap 16, padding 0 16 0 20 (B2:67). Clock, then five speed keys 40×32 with 4 px gap (B2:69-70).

Measured in the PNG: the time block starts near x 1592. The gated group spans about 1394-1920.

**Rail:**
- 12 px top padding. Rows 48 px tall, padding 0 16 0 20, gap 14. Icon 24 (B2:84-86).
- Ürün y76, Satış 124, Ekip 172, Finans 220, Kişisel 268, Pazarlama 316, Ar-Ge 364, Olaylar 412.
- Ayarlar sits absolutely at bottom 12, so its row spans y980-1028 (B2:95, 225).
- Badge 22 px pill, min-width 22, padding 0 6 (B2:94).

**Ticker:** a toggle cell 56×39 with a 20 px news icon and a right rule (B2:99, 247). The run has 16 px left padding and a 64 px right fade mask (B2:100). Separator is three spaces, "·", three spaces (B2:244).

**Windows:**
- Ekip at (208,88), 1304 wide (B2:331). Computed height about 714: header 84, control strip 64, body 16 + risk 52 + 8 + table header 56 + groups 40+80+40+80+40+40+40+52, bottom padding 20, borders 2.
- Olaylar at (208,88), 1240 wide, header 64 (B2:491-492), about 718 tall (PNG).
- Live office left on the right: 408 px (Ekip), 472 px (Olaylar).
- Inbox list column 400 wide (B2:495). List header 40 (B2:496). Message rows 100 (B2:497).
- Pane split: text column flex:1, gap 32, portrait 256×320 (B2:510, 522). Stake box 104 tall (B2:527). Option bar 56 tall, 8 px top margin (B2:533). Kabul et 184×56 (B2:532).

**Ekip grid** (WID, B2:324; total 1254 = 1304 − 2 border − 48 padding):

| Column | Width |
|---|---|
| Face | 44 |
| Name | 168 |
| Ürün, Tasarım, Yazılım, Test, Satış, Müşteri İlişkileri | 46 each (×6) |
| Liderlik | 70, with left rule |
| Görev | 150, left padding 16 |
| Deneyim | 68 |
| Durum | 146 |
| Huy | 128 |
| Maaş | 76, right padding 16 |
| Moral | 128 (26 value + 10 gap + 92 bar) |

Absolute x of the first column is 233. The "Roller" span sits at left 218, width 264 (B2:406). For comparison, the game today uses ÇALIŞAN · ROLLER · LİDERLİK 256 · GÖREV 150 · DENEYİM 72 · DURUM 140 · HUY 56 · MAAŞ 76 · MORAL 124 (S:97).

**Row and element heights:**
- Rows: table header 56 (B2:353), group header 40 (B2:361), data row 40 (B2:364; down from 44 in r4, N:49), empty-group row 52 (B2:391).
- Bars and strips: risk strip 52, ghost button 40, small ghost 34, chip 40, tabs strip 64.
- Rail row 48; message row 100; float notice 52; Ofisi taşı 44; tooltip 30.
- Bars: morale 92×6, XP 32×4, week 4.
- The research brief asked for 28-32 px rows (R:652). The designer chose 40 because each row has a two-line name and a face (N:8).

**Floating panels (B2:106-118):**
- BuildHUD at (1576,88), 320 wide: header padding 12 16, rows 10 16.
- Notice at (1544,968), 352×52.
- Ofisi taşı at (208,976), 44 tall.

**Icon sizes:**

| Size | Used for |
|---|---|
| 12 | Play |
| 16 | Trait glyph, shield, small plus, pause |
| 18 | Group icon, primary plus, clock, lock, move |
| 20 | Skill heads, close, chevron, news, BuildHUD head |
| 22 | Warn |
| 24 | Rail, up arrow |
| 28 | Pie |
| 32 | Logo, face |

**Glyph inventory (all quick SVG drafts, W13):**
- Rail (9): urun, satis, ekip, finans, kisisel, pazarlama, arge, olaylar, ayarlar (B2:140-148). They are two-opacity silhouettes (.45/.55/.72/.85), not Lucide.
- Skill heads (6): urun cube, tasarim pen nib, kod, test magnifier, satis tag, kulak headset (B2:150-153; SK_IC B2:296).
- Traits (5): lider flag, iskolik moon, sadik anchor, titiz double check, cabuk bolt (B2:155-159).
- Utility (11): warn, clock, plus, close, chev, lock, pause, news, shield, play, move (B2:161-171).
- Stake glyphs: up arrow and pulled-slice pie (B2:541-545).

### 1.5 Godot translation notes (mapping CSS that does not port 1:1)

- Em tracking must become per-size `FontVariation.spacing_glyph` in px (for example 14 px × .06em ≈ 0.84 px). Each (face, size, tracking) combination becomes a variation.
- `tabular-nums` needs the `tnum` OpenType feature on Plex. Watch the INT-tag `variation_opentype` trap (memory note).
- The window's double shadow plus inset highlight needs one `StyleBoxFlat` shadow approximation or a 9-patch.
- The halo blur needs a soft-edge shader or a 9-patch (the cost note says the same).
- `color-mix` pill fills become precomputed alpha tokens.
- The ticker's right fade mask needs a gradient overlay or shader.
- `text-wrap: pretty`, used to avoid a widow in the quote, has no Godot equivalent.
- The office saturate and brightness filter is office-side (shader or environment).

---

## 2. Components in the two frames

1. **Top bar, brand block.** Logo tile, company name, phase row. The "U" monogram is a stand-in (W1). The game already renders the player's logo through `LogoEmblem` (`scripts/ui/components/logo_emblem.gd:1-21`, `GameState.logo_style` at `game_state.gd:14`). Today's TopBar instead paints an amber ColorRect (`top_bar.gd:16,53`). Phase name and dots come from `top_bar.gd:201-206`. Long company names need ellipsis: about 120 px is left after logo and padding.

2. **Metric grid (flows and stocks).**
   - KASA is the only hero, in #FFF.
   - NET sits under KASA as its delta: green, label grey.
   - RUNWAY sits on KASA's baseline; "Artıda" is green 600 with tooltip `RUNWAY_PROFITABLE_NOTE` (S:43).
   - Separator, then MRR and BURN (top row), MARKA and İTİBAR (bottom row) (B2:187-198).
   - Data hooks: `top_bar.gd:118-158` (`format_money_exact`, `format_money_chip`, `get_monthly_flow`, `net_runway_parts`).

3. **Date and week bar.** Date line (`Fmt.date_line`), then a bar from the start hour to the end hour with hourly ticks, elapsed fill and a "now" marker (B2:199-200). It "fills the old 440 px of empty black with an instrument" (CJ final notes). Its length changes with state: long in Ekip, shorter when the gate is open (W6).

4. **Time block (idle).** Clock "11:00", five speed keys II/1x/2x/3x/4x. The active key is panel2 with a 2 px inset amber outline (B2:67-71). Hooks: `top_bar.gd:209-215`. Smoke pins the node names `PauseBtn` and `Speed1Btn`..`Speed4Btn` (HARITA:86) and case `topbar_speed_cluster_four_rungs` (HARITA:87).

5. **Time block, "Cevap bekliyor" (gate) state.**
   - A 2 px amber inset frame wraps the gate slot and the time block; there is no fill, and the shell background shows through (B2:74-75).
   - Amber dot 10 px with two static rings standing in for the pulse (B2:77).
   - "CEVAP BEKLİYOR" in Cond 700 19, amber, caps. The pending item's title ("Frank'in teklifi") sits under it in ink2 (B2:78-79, 182).
   - Speed keys at opacity .4 (B2:76).
   - The research brief adds a slow pulse while the gate is open (R:672) and a "Sıradaki" line when ungated (R:649). Neither is built (W6, W14).

6. **Rail row.** 24 px icon in ink3, name Cond 17 caps in ink2, badge on the right (B2:84-94).
   - Active: panel2 fill, 3 px ink left marker (inset 8 top and bottom), name #FFF, icon ink (B2:88-91).
   - Badge: red pill 22 px with #1B0F0D text (B2:94). Sources: `left_tabs.gd:126-150` (hr `HRSystem.attention_count`, sales `B2BSalesSystem.attention_count`, events `EventGate.queue_size`, finance runway, rnd).

7. **Rail row, locked.** Only the icon and name are dimmed to .45. "YAKINDA" stays below at full ink3, 13/14 caps (B2:92-93, 219). Today the whole button is dimmed (`TAB_LOCKED_ALPHA` 0.45, `ui_tokens.gd:359`; `left_tabs.gd:43`) and SOON is a pill badge (`left_tabs.gd:49`).

8. **Window frame and header.**
   - Panel body, 1 px line2 border, radius 8, deep shadow (B2:125).
   - Header in panel2 with bottom rule. Title Cond 40 caps #FFF with 36 px right margin, header 84 tall (B2:127, 332-333).
   - KPI stats: each has a left rule, padding 0 28, micro label over a 26 px value. Values: "Çalışan 5", "Ortalama moral 50", "Aylık maaş yükü $43.600" (B2:334-335, 455-457).
   - Value key at the right: label "ROLLER", then "1-2 3-4 5-6 7-8 9-10" each in its ramp colour (B2:336-338, 446-448).
   - Close button 36×36 (B2:128).
   - Today: `WindowFrame` (`window_frame.gd`), `WindowPanel` cream (HARITA:66). Windows are placed at EDGE 16 inside `CenterViewport` (`window_layer.gd:34,151-156`).

9. **Control strip and segment tabs.** 64 px strip: tabs KADRO and GÖREVLER (gap 28, Cond 18 caps). The active tab is #FFF with a 2 px ink underline (B2:340-343, 463). The game today uses an amber underline (S:94). On the right: the outline mesai chip (clock icon plus "09:00 ile 17:00 arası") and one amber primary "+ İşe alım başlat" (B2:339, 344, 465-466). FM27 "control panel" anchor: N:11, FM:111.

10. **Risk strip.** 52 px, background #2B1A17, border #6E3129, radius 6. Contents: red warn glyph 22, 32 px face, name 600 16 #FFF, "MORAL" Cond in #F2A49C plus "22" 700 18 red, the AYRILABİLİR `tag.bad`, chevron at the right (B2:346-351, 469-472). Data: flight-risk rule <35 (S:161).

11. **Table header.** 56 px with bottom rule, bottom-aligned 14 px Cond caps ink2.
    - The spanning "ROLLER" header (22 px, line2 underline) sits over six 20 px glyph heads. "LİDERLİK" is text with a left rule (B2:353-358, 399-406).
    - One tooltip is drawn open ("Müşteri İlişkileri", 132×30, background #0F0D0B, 6 px arrow) as a demonstration (B2:359-360, 407-408).

12. **Group header.** 40 px. An 18 px dept glyph in #9A9184, the name in Cond 15 caps ink, and a 1 px rule to the right edge (B2:361-362, 411). The group-to-column map for the role band is B2:309-312: Ürün&Tasarım→Ürün, Tasarım; Geliştirme→Yazılım, Test; Satış→Satış; Müşteri İlişkileri→Müşteri İlişkileri.

13. **Data row.** 40 px, rule rgba(58,52,45,.75). Cells in order: face 32 disc; name 600 15 #FFF over role PlexC 13 ink2; six skill cells; Liderlik; task; XP; Durum; Huy; Maaş; Moral (B2:364-386, 420-440).

14. **Skill cell and band.**
    - Number centred, 16 px, ramp colour.
    - Main skill: 700 plus a 16×2 underline in currentColor. Secondary: 600 (B2:367-370).
    - The role band is an absolute rgba(233,228,218,.07) column behind each group's dept columns, so the band steps down the table (B2:371, 416; N:9).
    - There is no legend for main vs secondary (W8).

15. **Status chips.**
    - `tag.new` "YENİ": outline #6A5F52, text #DCD4C8.
    - `tag.bad` "AYRILABİLİR": red 16% fill, 60% border, text #F49A90.
    - Plain text "İzinde · 2 hafta kaldı" stays at full ink (B2:131-133, 427-435).
    - All chips: 22 tall, radius 3, Cond 700 13 .07em.

16. **Trait cell.** 26×26 box (panel3, line2 border, radius 5) with a 16 px glyph in ink, plus a PlexC 13 ink2 label. Column 128 (B2:378-380, 436).

17. **Salary.** Right-aligned, 15/400 ink, so the name stays the heaviest text in the row (B2:381; CJ F8).

18. **Morale bar.** Value 700 16, right-aligned in 26 px, in the band colour. Track 92×6 line2, fill in band colour at m%, notch 1×12 #8A8174 at 35% (the flight-risk threshold) (B2:382-386, 440).

19. **XP cell.** 32×4 track plus "%0" 14 ink2 (B2:374-376). **The fill colour is not specified**: every seed value is 0.

20. **Leave row (Mert).** Face, skill numbers, XP track and morale at .45, face grayscale .8. Name, task, salary and trait box go to ink2. The Durum text stays at full ink (B2:387-390).

21. **Empty group.** "Henüz kimse yok" (15 ink2) plus a small ghost button "+ İşe alım başlat" (B2:391-393, 412-414).

22. **Inbox list row** (FM27 Messages anchor, FM:113, 119).
    - 100 px, three lines: sender 13 ink2 with the topic pill on the right; subject 600 16 with an optional amber gate dot (8 px, 3 px ring) and a right-hand value (time "11:00", "MORAL 22", "$1,0K/ay"); preview 14/20 ink2 with ellipsis, italic for reasons.
    - Selected row: panel2 fill and a 3 px ink marker (B2:497-508, 547-564).
    - List background #1A1714, header shows the date line (B2:495-496, 569).
    - The pill is a 1 px currentColor border with a 12% fill.

23. **Inbox detail (reading pane).**
    - Kicker row: MENTOR pill plus "Karar · Hafta 14 · Nisan 2026" `.lbl`.
    - h2 "FRANK'İN TEKLİFİ" Cond 36 caps.
    - Sender line: name, role, NÖTR chip, bottom rule with 18 px bottom padding.
    - Body: narration 17/26, quote in Source Serif 21/31 with straight quotes, closing "Cevap bekliyor." (B2:573-581).
    - Portrait card 256×320 on the right, radius 6, line2 border, well #16120F. The image is cropped at (-38,-4), 334×418 (B2:522-523, 583).

24. **Permanence line.** Above the choices: pause glyph 16 plus "Seçim kalıcıdır · Oyun duraklatıldı" 14 ink2, sentence case (B2:525-526, 586). Today it is uppercased under the choices (`event_modal.gd:133-138`).

25. **Stake row with primary option** (This Is the Police and Frostpunk 2 anchors, N:30-31).
    - 104 px panel2 box.
    - "NAKİT" over up arrow plus "+$25K" in green; "·" separator; "FRANK'E" over pie plus "%4 HİSSE" in ink. Both 36/700, the largest data on screen.
    - Amber "Kabul et" button 184×56 at the right (B2:527-532, 587-592).
    - Today all of this is one chip, `ANGEL_CHIP_ACCEPT` (`strings.csv:386`; `event_modal.gd:415-419`).

26. **Locked option.** 56 px panel bar, line border. Only the lock glyph and "Reddet" are at .5. The reason "Zor modda açılır." sits right-aligned at full ink2, 7.48:1 (B2:533-536, 593). Today the whole card is at .5 with the reason as a neutral badge (`event_modal.gd:330-340`).

27. **Notice card.** Float. 10 px green dot with ring, "NORDICA" Cond 14 .08em ink2, "Büyüme talebi masada" 15/500 ink (B2:114-117, 258). Game: `office_notice_stack.gd`. Today the stack's company tag goes through `Fmt.upper(c.company_name)` (`desk_papers.gd:51`), which is the source of the "NORDİCA" bug (R:38).

28. **BuildHUD card.** Float, 320 wide. Header: product glyph plus "Unicorn Inc. v1". Row: shield, "DESTEK", "DOĞRULANMIŞ 0". Action row: play glyph plus "DÜZELTME BAŞLAT" (B2:107-113, 253-257). Game: `build_hud_panel.gd`, `build_bar.gd`.

29. **"Ofisi taşı" button.** Float, 44 tall, move glyph 18 plus label 15/500 (B2:118, 259). Game: `office_hud.gd`, which also has a moving-weeks pill and a toast (lines 84-105).

30. **Ticker.** Toggle cell with news icon; each item is the publication in its hue (600) followed by the headline in ink2, separated by "·" (B2:98-103, 240-249). Today every outlet is drawn in ACCENT_HEX amber (`news_ticker.gd:131-132`). The toggle's behaviour is not defined.

---

## 3. Open issues and recommended resolutions

### 3.1 Art director findings (CJ F0-F10, on revision 1) and their status in revision 2

| # | Finding | Rev 2 status (evidence) | Residual and recommendation |
|---|---|---|---|
| F0 S2 | Full amber slab dominates; amber has three jobs | Fixed: dark block, outline-only active key, gate shown as frame, dot and words (B2:67-79) | Write the rule into `UiTokens` docs. Amber FILL appears once per surface, on the primary action only. Amber OUTLINE or TEXT is allowed only for the time state (active speed, gate). Selected = white or ink. Today TopBar also uses amber for the logo, the offer countdown and the auto-start note (`top_bar.gd:53,189,198`). Recolour them: logo becomes LogoEmblem; offer countdown becomes warn, then neg in the last week; auto-start becomes ink2. |
| F1 S2 | Red and orange in the skill grid | Fixed: one ramp on every cell (B2:23, 315) | New problem: the ramp is not monotonic in luminance (section 1.1), and s1 on the band is 4.42. Lower the band alpha to ≤.06, and either make lightness monotonic or add a second channel (weight or glyph from 7 upward). Define CB twins. |
| F2 S2 | Unlabelled trait glyph | Fixed (B2:378-380, 436) | Make glyph + label the shared base rule (C7). Effect text goes in a tooltip (S:139-145 has the effect lines). |
| F3 S2 | Sliced bust lineup | Fixed: dropped, KPIs at 26 (B2:335) | None. |
| F4 S2 | 440 px empty, NET orphaned, no "Sıradaki" | Partly: NET under KASA, week bar fills the gap. Sıradaki is missing (W6). | Needs a ruling: define "Sıradaki" with a source priority. Recommendation: gate > shutter countdown (red, `top_bar.gd:173-179`) > term-sheet countdown (`top_bar.gd:182-189`) > sprint decision or close (SprintSystem) > next scheduled meeting > hidden. Uses new keys. |
| F5 S2 | Lock reason at 2.85:1 | Fixed: reason 7.48 (computed). Dimmed label 4.36 (W10). | Accept, because inactive controls are exempt from WCAG 1.4.3. Apply the same rule to the rail lock (computed 2.59). |
| F6 S2 | Equity drawn red with a down arrow | Fixed: ink plus pulled-slice pie (B2:543-545) | Shared rule C2. Needs `_describe_modifier` to return signed parts (section 3.4). |
| F7 S2 | Cool shell, drained office | Fixed: warm ramp; halo about 160 px; veil .16 (B2:18-20, 120-122) | Window coverage remains (W11). |
| F8 S3 | Salary competes with the name | Fixed: 15/400 | None. |
| F9 S3 | Wrapped two-line column header | Fixed: glyph heads plus tooltip; headers 14 caps | Learnability (W7). |
| F10 S3 | Narration in two inks; quote marks changed | Fixed: both lines in ink; straight quotes restored (B2:518, 580) | None. |

### 3.2 Designer weaknesses for Menajer (CJ W0-W14)

- **W0. Still reads like sports-management software; no roundness and no contour shared with the office.** Accept, since this is the owner's choice. Carry the "game" identity through the Frank low-poly render, PersonBust faces, the live office behind the halo, topic and publication colours, and motion (count-ups, gate pulse). Optionally soften the window radius to 8 and the float radius to 6 (already the case).
- **W1. No owned colour; U logo; topic, publication and pill hues are ad hoc.**
  - Use `LogoEmblem` with `logo_style`.
  - Promote the topic and publication hues to named tokens with CB twins.
  - Unify the topic set with the existing event tags: MENTOR, MÜŞTERİ, EKİP, ÜRÜN, YATIRIM, GÜNDEM, PİYASA (`strings.csv:1523-1528`, 144; `desk_papers.gd:11-12`).
  - Do not invent "SATIŞ" as a topic.
- **W2. Photoreal Frank against low-poly people.** Resolved by the owner's directive. See section 3.5.
- **W3. Inbox versus the Victoria-style modal (R:653).** The owner chose the inbox. Keep the theatrical register for VC meetings, the term table, milestones and the ending (FM:243). Keep a centred modal only where the presenter has no inbox route (see the gate mechanics in section 3.4).
- **W4. Seeded rows (Selin, Ege, Nordica) are not in today's Olaylar.** Define the inbox source union:
  - engine papers and queued or active cards (`EventGate.desk_papers`, `active_id`, HARITA:251);
  - DeskPapers reminders (`desk_papers.gd:18-53`);
  - Frank's advisory line (`GameState.mentor_line_key`, `events_tab.gd:47-51`);
  - attention items behind the rail badges (HR flight risk, B2B at-risk);
  - read history of resolved cards.

  Each row needs sender, topic, week, time and read state. Cards fired at a day boundary must not show an hour (CLAUDE.md:61).
- **W5. Sparse list (about 210 px empty) and a bare OLAYLAR header.** Fill with history rows, an empty state (reuse `EVENTS_DESK_EMPTY`, `strings.csv:2620`) and optional FM26 Portal filters (All / Waiting / Unread, FM:75). Put an unread/waiting count in the header.
- **W6. The week bar carries no data, and its length depends on state.** Add marks:
  - workday end (`WorkHoursSystem.workday_end`), overtime extension, scheduled meeting hour, sprint decision hour.
  - Range: the week starts at 08:00 (`time_model.gd:10`), but the bar starts at 09.00. Show 08-09 as a pre-mesai stub, or start the bar at `WEEK_START_HOUR`.
  - Pin the gate-slot width so the bar does not jump.
- **W7. Glyph skill heads need hover to learn.** Keep the tooltips. The default density could show text heads, with glyph heads only in Condensed. Do not ship a statically open tooltip.
- **W8. 3-4 and 5-6 sit close; main and secondary are shown only by weight and underline, with no legend.** Fix the ramp (section 3.1, F1). Add "ana" and "ikincil" entries to the legend, or a tooltip on the underline.
- **W9. Leave-row dimming per element breaks the data's whole-row 0.45 rule (S:123).** Needs a ruling. Recommendation: approve per-element dimming, but at .6 or more so the dimmed numbers reach about 2.7-3.9 (computed s1 .6 = 2.72, s2 .6 = 3.87), and show "İzinde" as a chip.
- **W10. Dimmed "Reddet" (4.36) and locked Pazarlama (0.45 opacity) fall below 4.5.** Accept: inactive components are exempt from WCAG 1.4.3.
- **W11. Windows cover most of the office (408-472 px left).** Per-window width decision, plus Default / Detailed / Condensed density (R:652; FM:114). Also check the current `SPECS`: hr 1200×720, events 900×640 (`window_layer.gd:29-32`).
- **W12. Casing changes need TR approval.** Covers role title in CSV case, trait labels in sentence case and sentence-case buttons. See section 4.
- **W13. Icons are drafts; trait meanings are unchecked.** Art task: one family of about 35 glyphs (9 rail, 6 skill, 7 traits including the 2 not shown, `bag_packed` and `cant_say_no`, per `assets/icons/traits/`, 4 dept, 11 utility, 2 stake). Replace Lucide (`assets/icons/tabs/LICENSE-lucide.txt`). Review glyph meanings with the owner.
- **W14. Static frames only: no pulse, count-up, hover or density modes.** Write a motion and state spec:
  - gate pulse;
  - number count-up;
  - instant tab switch (R:672);
  - hover as border, not fill (CLAUDE.md:113);
  - focus, pressed and disabled states;
  - row hover and select;
  - scrolling with a sticky header.

### 3.3 Cross-direction rules (CJ C0-C11)

- **Equity cost is not red (C2).** Adopted in the mockup. Recommendation: a signed-part model in `_describe_modifier` (`event_modal.gd:357-422`). Each part carries {label, value, polarity (gain / cost / danger), glyph}. Only `danger` gets red: negative cash outcome, departure, shutter. Keep it the single builder (CLAUDE.md:62-63) and update smoke `event_chip_coverage`.
- **Locked reason stays readable (C3).** Adopted for the option bar and the rail. Apply it everywhere: dim only the label and glyph, keep the reason at ink2. The live reason comes from `EventGate.condition_reason` (`event_modal.gd:338-339`).
- **Mert row dimming (C4).** Per element, pending the owner. See W9.
- **Column header voice (C6).** 14 px Cond caps ink2, cap height about 10-11 (CJ final notes). Keep it.
- **Trait as icon plus label (C7).** Adopted; make it a base rule.
- **Reuse the AYRILABİLİR chip (C5).** Adopted in the risk strip and the inbox. Source: `HR_BADGE_FLIGHT_RISK` "Ayrılabilir" (`strings.csv:521`), uppercased by the chip.
- **Quote marks (C9).** Straight quotes from the data (B2:580; N:61). Keep straight quotes, and note that `FIN_MENTOR_QUOTE_WRAPPED` adds straight quotes (`strings.csv:1339`).
- **Role title casing (C9).** Mockup uses CSV case "UX/UI Designer" (B2:300). Today the game uppercases it to "UX/UI DESİGNER" (S:24, 111). Recommendation: render roles in CSV case, with no `Fmt.upper`.
  - Note that "Operating Partner" on a TR screen is a LANGUAGE INTEGRITY item (R:38). `MENTOR_ROLE` already holds "OPERASYON ORTAĞI" (`strings.csv:1560`), while `HR_ROLE_MENTOR` holds "Operating Partner" (`strings.csv:470`). The owner picks one.
- **Distinctness (C0, C1).** Resolved by the inbox and the seven-column FM grid as the signatures.
- **Frank art clash (C8).** Retired by the owner (section 3.5).
- **Data accuracy (C10).** Every value in the frames matches `screens.md`, except the casing changes already noted.

### 3.4 Further issues found in this extraction

1. **Shell structure.** `GameShell` places `LeftTabs` (84 px wide, `LeftTabs.tscn:15`) and `CenterViewport` side by side in the `MidRow` HBox, with offsets 54 and -34 (`GameShell.tscn:25,33-34,58`). A 184 px rail in the HBox would shift and shrink the office. To keep the mockup's framing (N:43), the rail, the 64 px top bar and the 40 px ticker must overlay the office, outside the HBox. Window placement must then clear the rail: x = 184 + 24, y = 64 + 24 instead of EDGE 16 (`window_layer.gd:34,151-156`).
2. **BuildHUD order.** BuildHUD is the last child, above the windows (HARITA:78; `window_layer.gd:140-145`). The mockup puts it below (z20 < 30). This matters for wide windows such as Product at 1424.
3. **Notice stack.** An open window covers it (HARITA:104). Define its relation to the inbox: the stack becomes a preview whose click opens the inbox item.
4. **Gate mechanics.**
   - Today `main.gd` mounts `EventModal` on `ModalLayer`, sets speed 0 and relies on the ModalLayer child count to block ESC and the speed keys (`main.gd:1912-1934`, comment at 1925-1927). A decision shown in a WindowLayer page needs a new block predicate (`EventGate.has_pending()` or active).
   - Also needed: ESC or × must not resolve or lose the gate; clicking the time block jumps to the inbox; decide whether a new card auto-opens Olaylar over the current window.
   - Decide whether deferral (paper with `weeks_left`) and auto-expire (`EvEffects.run_expire`, `scripts/events/core/effects.gd:12`) stay. Rows need a deadline (keys `DESK_PAPER_THIS_WEEK` / `DESK_PAPER_WEEKS`, `desk_papers.gd:79-84`).
   - Decide whether readout cards (`_is_readout`, `event_modal.gd:146-148`) should still pause the clock (R:812 Q8).
5. **Relationship chip.** It renders the raw id `c.relationship` (`event_modal.gd:238-239`; values ally / friendly / neutral / wary / hostile, `character.gd:100`), which produces "NEUTRAL" on screen. The mockup's "NÖTR" needs five new keys.
6. **Speaker row trait badges.** The modal shows up to two trait badges for the speaker (`event_modal.gd:240-241`). The mockup's sender line has none. Decide.
7. **Missing states in the top bar spec.**
   - Shutter state: cash below zero gives `KEPENK: n HAFTA`; is KASA red then?
   - Runway when not "Artıda": value plus unit, and the alert colour.
   - Offer countdown and auto-start note.
   - Compact layout below 1600 px (`top_bar.gd:13,87-100`; `TOPBAR_CLOCK_COMPACT`).
   - UI scale steps 0.75-1.25 (`display_settings.gd:51`; smoke `ui_scale_ladder_fits_settings`). At 1.25 on 1080p the logical size is 1536×864, which still fits 208 + 1304.
8. **Time format.** The bar shows "09.00" while the clock shows "11:00" (B2:200, 203). Use ":" everywhere.
9. **Ekip at scale.** The mockup has 5 people; the game must handle 40 (`--office-shot crowd40`). That needs scrolling with a sticky header, group collapse and the density modes. The `hr_dossier` detail window (380×580, `window_layer.gd:32`) is not designed.
10. **Rail badge for Olaylar.** It counts `EventGate.queue_size()` (`left_tabs.gd:139`), but the gated frame shows no Olaylar badge. Decide its colour: amber dot (time gate) or neutral, not red.
11. **Existing strings that break the dash law** (CLAUDE.md:54) and that the new screens would show:
    - `HR_HOURS_WINDOW` "{start}–{end}" (`strings.csv:489`);
    - `DESK_PAPER_GATE_TITLE` "… — …" (`strings.csv:146`);
    - `HR_TASK_NONE` "—" (`strings.csv:277`).
12. **Owner rulings and project process.**
    - Dark windows break the Chrome rule (CLAUDE.md:118-119; open item at ACIK_KARARLAR.md:1574-1579).
    - Set A fonts (R:810).
    - Every token or `build_theme.gd` change bumps `THEME_STAMP` (now 16, `ui_tokens.gd:44`; CLAUDE.md:107-109).
    - There are 290 inline visual overrides that a theme change cannot reach (`docs/audits/UI_OVERRIDES.md`, untracked; sections for `event_modal`, `hr_tab`, `sales_tab`, `build_bar`, `left_tabs`, `TopBar.tscn`, `news_ticker` BBCode colour).
    - `StarRating` is retired by the number grid; smoke `star_ruler_contract` (HARITA:68) is affected.
    - The rail order is pinned by smoke `rail_tabs_match_scene_order`.
13. **Founder portraits.** They are painted too (`assets/art/founders/founder_01..11.webp`; open item ACIK_KARARLAR.md #92 at :1549-1555). If Frank goes low-poly, the founder pages keep the same clash. Ask the owner.
14. **Screens not mocked.** They need the same language: Ürün sprint, Satış, Finans, Kişisel, Ar-Ge, Pazarlama placeholder, hr_dossier, HR Atlas / Action / Training / WorkHours modals, MonthSummary, Confirm, Settings / System / SaveLoad, MentorIntro (portrait is a placeholder Panel, `MentorIntroModal.tscn:55-61`), the meeting panel, the term-sheet table, the RnD card, MeetingInvite, the office map card, tooltips and onboarding. The ending newspaper stays as its own separate paper look (R:69).

### 3.5 Frank pre-rendered portrait (owner directive) and what the spec implies

- **Today:**
  - `ensure_mentor` sets `portrait_path = res://assets/art/investors/portrait_frank.webp` and gives Frank no `look`. The comment says "drawn with his painted portrait" (`scripts/autoload/character_registry.gd:396-408`).
  - Consumers: the event modal avatar at 24 px (`event_modal.gd:247-263`); the notice stack and MentorIntro, which show initials only (`office_notice_stack.gd:59-60`; `MentorIntroModal.tscn:55-61`).
  - `screens.md` lists `art/frank.png` at 1408×1760, 4:5 (S:208).
- **Needed sizes:**
  - pane card 256×320, 4:5, half-body, delivered at 2× (512×640, matching `PersonBust.SUPERSAMPLE` 2, `person_bust.gd:10-11`);
  - 32 px face for inbox, notice and avatars, cut at a fixed head rect like the employee faces (CJ final cost "ART");
  - 24 px speaker strip;
  - a large MentorIntro size.
- **Style and rig:** the same studio as `PersonBust`: orthographic, FRAME 0.5, TURN .42, RISE .12, idle pose, noon light, office toon and ink (`person_bust.gd:1-21`). Bake it offline as a fixed asset ("sabit") instead of rendering at runtime.
- **Look:** give Frank a fixed `look` that never enters `GameState.issued_looks`, so no hire can share it.
- **Background:** transparent over the #16120F well.
- **Cleanup:** retire the webp and its `.import`, and rewrite the comment at `character_registry.gd:406`.

---

## 4. New player-visible strings (EN first; TR needs approval per CLAUDE.md:34, 44-51)

**Genuinely new keys:**

1. "Cevap bekliyor": gate label (B2:182). EN "Awaiting your answer" or "Must respond". It cannot reuse Frank's card text "Cevap bekliyor." (`strings.csv:376`).
2. Gate subline: uses the active card's title, so no key. Add "{n} karar bekliyor" if more than one item is pending.
3. "Sıradaki" label plus one value template per source (R:583, 649). Not written yet.
4. "Ortalama moral": KPI label. It exists today only inside the composite `HR_SUMMARY` (`strings.csv:358`), which should split into three label keys.
5. "Roller": legend and span header. Today it is the composite `HR_COL_ROLES_LEADERSHIP` "ROLLER · LİDERLİK" (`strings.csv:274`). Liderlik reuses `HR_AREA_LEADERSHIP`.
6. Legend range format "{lo}-{hi}" (ASCII hyphen).
7. Mesai window "{start} ile {end} arası" / EN "{start} to {end}". Replaces `HR_HOURS_WINDOW`'s en dash (`strings.csv:489`; S:18). It feeds `HR_HOURS_CHIP_OVERTIME` and `HR_HOURS_CHIP_OVERRIDES`.
8. Standalone clock "{hour}:00" and week-bar end labels, split out of `TOPBAR_CLOCK` (`strings.csv:1488`).
9. Inbox row composite "{role} · {task}" (B2:551).
10. Stake labels and values:
    - "Nakit" (reuse `FIN_CASH` or `HR_ROW_CASH`, `strings.csv:1341, 815`);
    - "Frank'e" / "To Frank": new, and literal because the suffix rule forbids "{name}'e";
    - "%{equity} hisse" / "{equity}% equity": new.

    Together these replace `ANGEL_CHIP_ACCEPT` (`strings.csv:386`).
11. Relationship words, five new keys: Müttefik / Dost / Nötr / Temkinli / Düşman (wording is the owner's).
12. Inbox empty state, filters and counts, if adopted.

**Existing keys that need a recase or CSV fix (TR approval):**
- `HR_COL_TRAIT` "TRAIT" → "Huy" (`strings.csv:276`).
- `HR_SEARCH_START` "+ İŞE ALIM BAŞLAT" → "İşe alım başlat"; the plus becomes an icon (`strings.csv:359-360`).
- `HR_TRAIT_*_LABEL` caps → sentence case (`strings.csv:718-735`).
- `DESK_PAPER_GATE_TITLE` em dash (`strings.csv:146`).
- `HR_TASK_NONE` "—" (`strings.csv:277`).
- Mentor role choice (`strings.csv:470` vs 1560).

**Reused unchanged:** `EVENT_TAG_*` topic pills (`strings.csv:1523-1528`; use MÜŞTERİ, not "SATIŞ"), `EVENT_DECISION_DAY` (1521), `EVENT_CHOICE_PERMANENT` (1520), `ANGEL_CHOICE_REFUSE_LOCK` (385), `HR_BADGE_FLIGHT_RISK` (521), `HR_BADGE_NEW` (721), `SALES_CHIP_RISK` (109), `SALES_REASON_PREFIX` (115), `DESK_PAPER_EXPANSION_TITLE` (151), `HR_STATE_ON_LEAVE_WEEKS` (779), `HR_EMPTY_ROW` (361), `HR_COL_*`, `HR_AREA_*`, `HR_GROUP_*`, `HR_TAB_*`, `TAB_*`, `SYS_SOON`, `OFFICE_MOVE_BTN`, `RUNWAY_PROFITABLE` and its note, `TOPBAR_UNIT_PER_MONTH`, `BUILD_*`, `MENTOR_NAME`.

**Code-only fixes** (no new text):
- Stop uppercasing the permanence line (`event_modal.gd:136`).
- Stop TR-uppercasing proper nouns (`desk_papers.gd:51`).
- Render role titles in CSV case.