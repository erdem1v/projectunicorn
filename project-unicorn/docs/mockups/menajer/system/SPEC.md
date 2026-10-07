# Menajer Masası: tasarım sistemi (Faz A1, revizyon 2)

Status: proposal for Erdem's review. Nothing here is in the game yet. Every screen mockup in Faz A4 imports
`tokens.css` and `base.css` from this folder; Faz B turns the same tables into `D_*` tokens and
`menajer_theme.tres`.

Revision 2 answers the art-direction review of 2026-10-02 (findings 1 to 27 and the A4 gap list). §0.1 maps
every finding to the change and the page that shows it. Starting values: `../v0/build2.py`; first-pass open
issues: `../ref/explore_spec.md` §1.1-1.5 and §3.

## 0. Dosyalar ve nasıl yeniden üretilir

| File | What it is |
|---|---|
| `tokens.css` | Every colour, size, space, radius, border, shadow, height, baseline and motion token by role; the colour-blind palette (`[data-palette="cb"]` or `body.cb`); one class per type role (`.t-*`). Size tokens are numeric steps (`--fs-12` .. `--fs-40`). |
| `base.css` | Every component with explicit state classes (`.is-hover`, `.is-pressed`, `.is-focus`, `.is-disabled`, `.is-selected`, `.is-locked`, `.is-armed`). Paddings and gaps use the spacing scale only (`tools/lint_spacing.py`). |
| `components.html` | All 16 sheet pages stacked; the overflow report runs on load. Generated. |
| `build/page_NN.html`, `build/screen_*.html` | One file per page (render input) and three full screens. Generated. |
| `pages/01..16_*.png` | The sheet pages (list in §0.2). |
| `pages/s1_ekran_1920.png`, `s2_ekran_1536.png`, `s3_ofis_katmani.png` | The shell with the Ekip window at 1920×1080 and at 1536×864 (the narrowest logical size), and the office layer (city map). |
| `pages/l1_*`, `l2_*` | 1280×720 legibility checks: s1 at 100 % (×2/3) and s2 at 125 % (×5/6). |
| `pages/sim_*_deutan.png`, `pages/halo_check.png` | Colour-vision previews (page 8) and the halo banding probe (§2.8). |
| `assets/halo_9patch.png` | Fallback 9-patch for the window halo, only if Faz B sees banding (§2.8). |
| `rounds/r1..r4` (first pass), `r5..r8` (this pass) | Every render round, kept for comparison. |
| `tools/` | `build_components.py` (assembles), `common.py` (paths, TR/EN text table, icon loader, crops), `kit.py` (component builders), `pages_core.py` (pages 1-9), `pages_more.py` (pages 10-16 and the city screen), `measure.py` (Chrome text widths, cached), `crops.py` (avatar and portrait crop rule), `glyphs_local.py` (A2 backlog glyphs; today only `head`), `contrast.py`, `type_metrics.py`, `glyph_inventory.py`, `lint_spacing.py`, `halo.py`, `simulate_cvd.py`, `render_pages.sh`, `split_pages.py`. `tools/fonts/` caches the static Barlow Condensed and Plex files for the inventory. |

```
cd docs/mockups/menajer/system
python tools/build_components.py && bash tools/render_pages.sh r8   # pages, screens, overflow report
python tools/contrast.py --write-spec          # exit 1 on a failing check
python tools/type_metrics.py --write-spec      # exit 1 if a CSS line is shorter than Godot's
python tools/glyph_inventory.py --write-spec   # every glyph the text faces lack, with its decision
python tools/lint_spacing.py                   # exit 1 on an off-scale padding, margin or gap
python tools/halo.py                           # halo banding probe and the 9-patch fallback
```

The icons are read from `icons/` (A2) and the portraits from `../portraits/` (A3) at build time, so their
re-shoots flow into the sheets on the next build. The overflow report widens every text run by about 8 %
(Godot draws text wider than Chrome), lists any fixed box that starts to clip, and prints the week-bar length of
every top bar ("one length" per bar width). The final report lists only documentation notes.

Pages load the faces with:
`<link href="https://fonts.googleapis.com/css2?family=Barlow+Condensed:wght@600;700&family=IBM+Plex+Sans+Condensed:wght@400&family=IBM+Plex+Sans:wght@400;500;600;700&family=Source+Serif+4:ital,opsz,wght@0,8..60,400;0,8..60,600;1,8..60,400&display=block" rel="stylesheet">`
then `tokens.css`, then `base.css`. `<html lang="tr">` gives the Turkish İ in CSS caps; the English pages set
`lang="en"`.

### 0.1 Art-direction review: what changed

| # | Finding | Change | Shown on |
|---|---|---|---|
| 1 | Frank A shares head and hair with a hire and a VC | Rule: Frank's chosen head + hair pair is reserved in `LookSystem` and `CounterpartSystem`, not only the full look signature (§3.5). The pick itself stays A3's and Erdem's. | 10 |
| 2 | Candidates shown out of context | All candidates found in `../portraits/` are composited into the real 256×320 well on the lit ground, cut by the crop rule (0.48 m framing), with 48/32/24 crops beside each. Light rig and suit colours are A3's. | 10 |
| 3 | Sheets showed retired art and draft glyphs | Every glyph comes from `icons/` (A2, 69 files used; one backlog glyph, `head`, drawn to A2's rules). The painted Frank is gone: the placeholder is candidate D (best ink contrast), labelled as a placeholder. | all |
| 4 | Week bar changed length | The metric grid has fixed columns sized by `measure.py` for the worst TR and EN value; the gate slot and time block are fixed. The bar is 354 px at 1920 and 252 px at 1536 in every state and language (overflow report). | 7, 15 |
| 5 | Top bar had no slack and used baseline alignment | Labels are placed by baseline (row 1 at 33, row 2 at 54), not stacked; row 2 is `.t-data`/`.t-micro`. Godot: `position.y = baseline - font.get_ascent(size)` in a small MetricGrid script (§10). | 7 |
| 6 | EN overflowed fixed boxes | Two English pages run through the same overflow pass. Ekip widened to 1352 with a re-cut grid; gate key EN "Answer needed" (13 chars); row-2 keys at 12 px. | 15, 16 |
| 7 | On-leave row failed 4.5:1 | Numbers stay at full ramp. Leave reads as a grey face (`avatar_grey.gdshader`), an ink-3 name and a neutral "İzinde" tag with the weeks left. | 4 |
| 8 | Permanent choice without confirm; Enter twice picks option 1 | Arm and confirm: a click or Enter arms an option (it opens into its stake parts with one amber "Seç"); "Vazgeç" or Esc disarms. Enter is ignored 400 ms after a decision opens and after arming. No chevron. Overflow: chips wrap, bar 88 px. | 6 |
| 9 | Reads as admin software | One desk motif: every document has its top-right corner cut (12 px bevel, Godot `corner_detail 1`), and a finished document is stamped (2 px stamp ink, -3°). A2 adopted the same notch as the icon family's signature and moved to the solid head-icon dialect. | 3, 5, 6, 12 |
| 10 | Ink outline vanished on charcoal | Avatars and the portrait well sit on a lit radial ground (`--portrait-lit` → `--portrait-edge`), with a 1 px `--av-rim`. Darkest hair against the ground: 2.45:1 (checked by `contrast.py`). | 10 |
| 11 | Delivered crops were mini-busts | Crop table (§3.5): ≤48 px is head and neck with the head about 70 % of the disc; 64/96 head and shoulders; the card uses a 0.48 m frame. `crops.py` applies it to any render. | 10 |
| 12 | Portrait light flattens skin | A3's (light rig, exposure on skin tones 0-1, pose). §3.5 records the requirement. | |
| 13 | Removing Noto leaves glyphs without a face | `glyph_inventory.py` lists every character the text faces lack with every CSV key and code literal and a decision (§3.1). Found on the way: `RND_CROSS_MARK` "⇠" is in no shipped face today. | 2 |
| 14 | 1280×720 question rested on a wrong gate | `_fits_chrome` divides the physical window by the step; under `canvas_items` + `expand` the logical viewport is the base size over the step. Recommendation: gate on the logical 1536×864 minimum (§8). At 1280×720 the 125 % step then draws 12 px text at 10 px (`l2_*`). | 9, l2 |
| 15 | Misread icons | A2's second pass (coin for Finans, suitcase, umbrella, bubble over papers, bug with check, signpost). The sheets read whatever A2 ships. | all |
| 16 | Off-scale spacing | `base.css` uses only the scale; `lint_spacing.py` enforces it (hairline centring offsets listed with reasons). | |
| 17 | Three left edges per row | One row rect: hover box, selected fill and marker share the row's edges; the inbox list keeps a 12 px scrollbar gutter so rows end before the bar. | 4, 5 |
| 18 | Colour collisions | Focus is a 2 px `ink-1` ring with a 2 px gap; CB `info` is its own pale blue (#C0E2F6); `topic-product` moved to sage (#9EB18C), 14.5 ΔE from the lime skill step. | 1, 3, 8 |
| 19 | Size tokens named by role | Numeric steps `--fs-12`..`--fs-40`, `--lh-*`. | 2 |
| 20 | Caps rule contradicted | Rule 7 reworded (labels of up to three words); kickers, day separators and dates are sentence case. | 2, 5 |
| 21 | Rail rules conflicted with A2 | One rule set (§10), the one A2 now follows: idle icon ink-4, name ink-3; active icon ink-2, name ink-1; locked ink-off with the reason in ink-4; icon mode keeps numbered badges with a 2 px cut-out ring. | 7 |
| 22 | Slot priority contradicted the alarm mock; empty slot dead | The shutter countdown lives in the RUNWAY cell (key becomes KEPENK), so it leaves the slot priority; the slot is never empty (fallback "Mesai bitimi · 6 saat"). | 7 |
| 23 | Halo banding risk | `halo.py`: over the dimmed office the 96 px linear feather spans 92-97 eight-bit levels (no band wider than 2 px); at night 4 px. Bands of 15 px appear only over `surface-1`, which the rail and top bar cover. Keep StyleBoxFlat; the dithered 9-patch is a fallback (§2.8). | |
| 24 | Paper island used variable opsz | The repo's Source Serif 4 files are static opsz 20 (verified against the variable font by advance widths); the island renders at opsz 20 everywhere (§12). | 1 |
| 25 | Inbox header duplicated the filter counts | The header carries one non-count KPI, "En yakın süre: Bu hafta" (warn); counts stay on the filters. | 5 |
| 26 | Missing 1920×1200, 1536×960, 32:9 | Page 9 has all five frames plus 32:9; §8 lists 32:9. | 9 |
| 27 | Head-icon ring hues baked | A2 removed the rings (dark disc for work, cream disc for a break). Any remaining office colours are named scene constants, not UI tokens (§2.9). | |
| A4 | Missing components | Added: chart kit (CashCurve, stat tile and sparkline, ranked shares, monthly flow), progress, BuildBar, research bar, loading curtain, sprint card states, quarter goal strip, R&D nodes and edges, pipeline and deal card, account card with satisfaction, promise and churn, sales desk band picker, meeting dock (seats, dialogue, stepper, lever, numbered options), invite ring, travel chips, crown, onboarding (language, founder card, origin, skill step, logo), Onay with 2 and 3 buttons, save slots, sortable head and group collapse, 13-column compact table (16 of 40), avatar loading placeholder, pane speaker variants, text conventions, person tooltip, map chips and card. Still missing: §11.4. | 4, 6, 10-14, s3 |

### 0.2 Pages

| Page | Content |
|---|---|
| 01 Renk | Surfaces, lines, ink, accent, meaning with CB twins, data-viz tokens, skill ramp, topics, outlets, overlays, portrait ground, desk motif, newspaper island. |
| 02 Yazı | The 12-step ladder by role, serif, caps rule, figures. |
| 03 Kontroller | Buttons × states, locked, segment tab, tags, pills, badges, relationship chip, desk motif, spacing, radii, shadows, fields, check, switch, slider, select, menus, toast, tooltip, empty state. |
| 04 Veri | Ekip window (1352): header KPIs, legend, control strip, risk strip, table with groups, band, hover, selected, on-leave; morale, XP, traits; sort and group collapse; column ruler. |
| 05 Gelen kutusu | Olaylar window with Frank's offer, row types, paper bars, keyboard, read-only window strip. |
| 06 Karar | Stake parts, arm-and-confirm options, wrap and locked, history with stamp, Frank moment, report, speaker variants, intro and departed rows. |
| 07 Kabuk | Top bar: normal, gated, gated2, alarm, fallback slot, compact; rails labelled and icon-only; floats, toasts, collapsed ticker. |
| 08 Renk körü | The same components under `[data-palette=cb]`, plus deuteranopia previews. |
| 09 Yerleşim | 1920×1080, 1536×864, 1536×960, 1920×1200, 2560×1080, 32:9 frames; window size table. |
| 10 Portre | Crop rule, avatar ladder on lit and flat ground, states, Frank candidates in the well. |
| 11 Grafik | Cash curve with hover readout, stat tiles, shares, monthly flow, progress, BuildBar, research bar, curtain. |
| 12 Alan | Sprint cards, R&D tree, quarter goal, pipeline, account card, sales desk. |
| 13 Toplantı ve açılış | Meeting dock, invite, travel chips; founder card, language gate, origin, skill step, logo. |
| 14 Diyalog | Onay 2 and 3 buttons, save slots, compact table, text conventions. |
| 15, 16 EN | The shell, inbox rows, options, toasts, Ekip window and reading pane in English. |
| s1, s2, s3 | Full screens: 1920, 1536, city map with the office card and a person tooltip. |

## 1. Kurallar (her ekran için)

1. **Amber has one job.** Fill: only the single primary action of the open surface. Outline or text: only the
   time state (the active speed key, the "Cevap bekliyor" slot, the decision-waiting dot in the inbox, rail and
   read-only strip, the meeting invite ring). Selected is never amber. A decision with two or more open options
   shows no amber until the player arms one; the armed option's "Seç" is then the one primary. A decision with
   one open option is presented armed (Frank's offer: "Kabul et").
2. **Red is danger only:** negative cash, departure, shutter, customer loss, morale under 35, churn countdown,
   area below zero on a chart, destructive actions. Equity, discounts and drops are costs: ink with the cost
   glyph (disc with a minus) or the slice.
3. **Hover is a border** (`--line-hover`), never a fill. **Selected is ink:** `--surface-4` plus a 3 px
   `--selected-mark` inset 8 px from top and bottom, on the row's own left edge. **Focus** is a 2 px `--focus`
   (ink-1) ring with a 2 px gap.
4. **Locked:** only the label and glyph go to `--ink-off`; the reason stays at `--ink-3` or better and is always
   shown next to the control (rail: under the name).
5. **Every meaning has a second channel:** shape or text (up arrow gain, cost disc, triangle danger, die chance,
   35 notch on morale, words on every tag and pill, the İzinde tag on a leave row).
6. **Text over the office always sits on an opaque ground** (`--surface-0..5`). Floats are opaque.
7. **Caps only for short labels:** a CSV label of at most three words used as a key, column head, tab, rail name,
   tag or pill, produced by `Fmt.upper`. Never proper nouns (company, person, product, publication), titles,
   buttons, sentences, dates or kickers, never `Label.uppercase`. ("Karar · Hafta 14 · Nisan 2026" is sentence
   case, like the top-bar date.)
8. **Text comes from data as written:** straight quotes in Frank's lines stay straight; role titles in CSV case;
   trait labels sentence case (TR approval).
9. **No data is an empty cell**, never a dash.
10. **Desk motif:** a document (decision stake, armed option, paper bar, report, history card, dossier, toast,
    notice, deal and sprint card, save slot, map card, origin card, the founder's line in a meeting) has its
    top-right corner cut (`--cut` 12 px, small documents `--cut-sm` 8 px). Furniture (window, rail, bars, table,
    controls) does not. A finished document carries a stamp ("Cevaplandı", "Bitti", "Ayrıldı", "İmzalandı").

## 2. Renk

### 2.1 Roller

| Group | Tokens | Use |
|---|---|---|
| Surfaces | `surface-0` ground (ticker, tooltip, page) · `surface-1` chrome (top bar and rail) · `surface-2` inset column (inbox list, stuck table head, input) · `surface-3` window body · `surface-4` raised (window header, selected row, active rail row, time block, menu, stake box, armed option) · `surface-5` control fill (idle speed key, trait box, switch track, count badge) | Six steps. |
| Lines | `line-1` rules · `line-2` component borders · `line-3` strong outline (tag, chip, scrollbar thumb, avatar rim) · `line-hover` | `row-rule` softer. |
| Ink | `ink-1` emphasis, focus · `ink-2` primary text · `ink-3` secondary, keys, column heads, idle rail name, stamp · `ink-4` tertiary, idle rail icon, rail lock reason · `ink-off` disabled label or glyph only | |
| Accent | `accent`, `accent-hover`, `accent-pressed`, `on-accent`, `accent-glow` | Rule 1. |
| Meaning | `pos`, `neg`, `warn`, `info` and their tag, ink and ground variants | Rule 2. |
| Skill ramp | `skill-1..5`, `role-band` | §2.4. |
| Topics | `topic-mentor`, `-customer`, `-team`, `-product`, `-funding`, `-market`, `-agenda` | §2.6. |
| Outlets | `outlet-sektor`, `-ekonomi`, `-teknogundem`, `-girisim` | Ticker. |
| Data viz | `chart-grid`, `chart-axis`, `chart-line`, `chart-proj`, `chart-neg-area`, `chart-pos-area`, `bar-track`, `bar-fill`, `bar-emph` | §11.2. No categorical hues: shares are ranked and labelled. |
| Portrait ground | `portrait-lit`, `portrait-edge`, `av-rim` | §3.5. |
| Desk motif | `stamp`, `cut`, `cut-sm` | Rule 10. |
| State, overlay | `focus`, `selected-mark`, `scrim`, `dim`, `halo`, shadow colours, `zebra` | §2.8. |
| Paper island | `paper-*` | §12. |

Godot names (Faz B): the same roles with a `D_` prefix (`D_SURFACE_3`, `D_INK_2`, `D_SKILL_4`, `D_TOPIC_TEAM`,
`D_PORTRAIT_LIT`, ...); colour-blind twins sit behind accessors as today (`UiTokens.positive()` style).
`--dim` is a scene constant next to `OfficeView.FADE_DARK`.

### 2.2 Token tablosu, kontrast ve renk görüşü

Generated by `tools/contrast.py` from `tokens.css`. Grounds listed per token are the grounds it is used on.

<!-- contrast:begin -->
### Token tablosu (hesaplanmış)

Contrast is WCAG 2.x. "cb" is the colour-blind twin (`[data-palette=cb]`); a dash-free "=" means the twin keeps the value.

| Token | Hex | cb | Role | Grounds and ratio (standard / cb) |
|---|---|---|---|---|
| `--surface-0` | #100E0B | = | ground: ticker, tooltip, page |  |
| `--surface-1` | #15120F | = | chrome: top bar and rail |  |
| `--surface-2` | #1A1714 | = | inset column inside a window: inbox list, sticky table head, input field |  |
| `--surface-3` | #1E1B18 | = | window body |  |
| `--surface-4` | #27231F | = | raised: window header, selected row, active rail row, time block, menu, stake box |  |
| `--surface-5` | #2E2924 | = | control fill: idle speed key, trait box, switch track, count badge |  |
| `--line-1` | #3A342D | = | rules, separators, row rules | surface-3 1.39 |
| `--line-2` | #4A4239 | = | component borders: window, outline button, input, tracks | surface-3 1.74 |
| `--line-3` | #6A5F52 | = | strong outline: tag, relation chip, scrollbar thumb, avatar rim | surface-3 2.75 |
| `--line-hover` | #958C7E | = | hover is a border, never a fill | surface-3 5.17; surface-4 4.70 |
| `--ink-1` | #FFFFFF | = | emphasis: KASA, window title, row name, active label | surface-1 18.66; surface-3 17.14; surface-4 15.60 |
| `--ink-2` | #E9E4DA | = | primary text | surface-0 15.21; surface-1 14.73; surface-2 14.09; surface-3 13.53; surface-4 12.31; surface-5 11.36 |
| `--ink-3` | #B3AA9E | = | secondary text, keys, column heads, idle rail name | surface-0 8.41; surface-1 8.14; surface-2 7.79; surface-3 7.48; surface-4 6.80; surface-5 6.28 |
| `--ink-4` | #9A9184 | = | tertiary: idle rail icon, lock reason on the rail, separators that carry meaning | surface-1 6.00; surface-2 5.74; surface-3 5.52; surface-4 5.02 |
| `--ink-off` | #6B6358 | = | disabled and locked label or glyph only (exempt, never a reason) | surface-1 3.16; surface-3 2.90; surface-4 2.64 |
| `--accent` | #F2B53A | = | the single primary action fill; time-state outline and text | surface-1 10.17; surface-4 8.50 |
| `--accent-hover` | #F7C65F | = | primary button hover |  |
| `--accent-pressed` | #DDA12D | = | primary button pressed |  |
| `--on-accent` | #17130A | = | text and glyph on amber | accent 10.09; accent-hover 11.64; accent-pressed 8.12 |
| `--accent-glow` | #F2B53A @0.24 | = | gate dot ring, time-state only |  |
| `--pos` | #4FD27A | #56B4E9 | gain, Artıda, moral 50+, healthy dot | surface-1 9.63 / 8.09; surface-2 9.21 / 7.73; surface-3 8.84 / 7.43; surface-4 8.04 / 6.76 |
| `--neg` | #EC6A5E | #F07A3C | danger only: negative cash, departure, shutter, moral under 35 | surface-1 6.03 / 6.71; surface-2 5.77 / 6.42; surface-3 5.54 / 6.17; surface-4 5.04 / 5.61; neg-bg 5.38 / 5.81 |
| `--warn` | #E8913A | #F6EA85 | attention, not danger: moral 35 to 49, last-week paper, offer countdown | surface-1 7.59 / 15.13; surface-2 7.26 / 14.47; surface-3 6.97 / 13.90; surface-4 6.34 / 12.65 |
| `--info` | #8CC2EC | #C0E2F6 | neutral notice dot, report rows | surface-2 9.39 / 13.13; surface-3 9.01 / 12.61 |
| `--neg-bg` | #2B1A17 | #2E1D12 | danger strip fill |  |
| `--neg-line` | #6E3129 | #7A4522 | danger strip border |  |
| `--neg-ink` | #F4A39A | #F7B48C | soft danger text on neg-bg or in a risk tag | neg-bg 8.36 / 9.12; neg-tag-bg on surface-3 6.88 / 7.57; neg-tag-bg on surface-2 7.20 / 7.92 |
| `--neg-tag-bg` | #EC6A5E @0.16 | #F07A3C @0.16 | risk tag and danger effect part fill |  |
| `--neg-tag-line` | #EC6A5E @0.60 | #F07A3C @0.60 | risk tag border, danger button border |  |
| `--pos-tag-bg` | #4FD27A @0.12 | #56B4E9 @0.12 | opportunity tag fill (Büyümek istiyor) |  |
| `--pos-tag-line` | #4FD27A @0.55 | #56B4E9 @0.55 | opportunity tag border |  |
| `--pos-ink` | #8FE3A8 | #A6D6F5 | soft positive text inside a pos tag | pos-tag-bg on surface-3 8.92 / 9.02 |
| `--warn-tag-bg` | #E8913A @0.12 | #F6EA85 @0.10 | last-week and countdown tag fill |  |
| `--warn-tag-line` | #E8913A @0.55 | #F6EA85 @0.50 | last-week and countdown tag border |  |
| `--on-neg` | #1B0F0D | #1F1206 | text on a solid danger badge |  |
| `--row-rule` | #3A342D @0.75 | = | data row separator, softer than line-1 |  |
| `--zebra` | #E9E4DA @0.03 | = | optional zebra stripe (density: Ayrıntılı) |  |
| `--skill-1` | #A09789 | = | 1-2 | surface-3 5.94; surface-4 5.41; role-band on surface-3 5.28; role-band on surface-4 4.76 |
| `--skill-2` | #B4AB9B | = | 3-4 | surface-3 7.54; role-band on surface-3 6.70; role-band on surface-4 6.04 |
| `--skill-3` | #C9C3B4 | = | 5-6 | surface-3 9.75; role-band on surface-3 8.67; role-band on surface-4 7.81 |
| `--skill-4` | #BCDF72 | #A3D2F7 | 7-8 | surface-3 11.38 / 10.71; role-band on surface-3 10.11 / 9.51; role-band on surface-4 9.11 / 8.57 |
| `--skill-5` | #86F7A0 | #D4EEFF | 9-10 | surface-3 12.92 / 14.26; role-band on surface-3 11.48 / 12.67; role-band on surface-4 10.34 / 11.42 |
| `--role-band` | #E9E4DA @0.05 | = | the role's columns inside its group |  |
| `--topic-mentor` | #C9A8E6 | #A985E0 | MENTOR · EVENT_TAG_MENTOR | surface-2 8.69 / 6.05; surface-4 7.60 / 5.29; pill fill on surface-2 6.97 / 5.10 |
| `--topic-customer` | #6FC9B6 | #B6EDED | MÜŞTERİ · EVENT_TAG_CUSTOMER | surface-2 9.10 / 13.88; surface-4 7.95 / 12.12; pill fill on surface-2 7.28 / 10.31 |
| `--topic-team` | #7FB6DE | #85C5E0 | EKİP · EVENT_TAG_TEAM | surface-2 8.20 / 9.40; surface-4 7.17 / 8.21; pill fill on surface-2 6.65 / 7.47 |
| `--topic-product` | #9EB18C | #B6D175 | ÜRÜN · EVENT_TAG_PRODUCT; sage, kept 15 ΔE from the lime skill-4 | surface-2 7.75 / 10.51; surface-4 6.77 / 9.18; pill fill on surface-2 6.31 / 8.18 |
| `--topic-funding` | #E6A2C2 | #C9945E | YATIRIM · DESK_PAPER_TAG_FUNDING | surface-2 8.76 / 6.70; surface-4 7.66 / 5.85; pill fill on surface-2 7.02 / 5.57 |
| `--topic-market` | #D4BD8E | #DAC7A9 | PİYASA · EVENT_TAG_MARKET | surface-2 9.75 / 10.81; surface-4 8.52 / 9.45; pill fill on surface-2 7.67 / 8.37 |
| `--topic-agenda` | #B3AA9E | = | GÜNDEM · EVENT_TAG_AGENDA, the generic topic stays neutral | surface-2 7.79; surface-4 6.80; pill fill on surface-2 6.33 |
| `--outlet-sektor` | #7FB6DE | #85C5E0 | Sektör Telgrafı | surface-0 8.85 / 10.15 |
| `--outlet-ekonomi` | #E6A2C2 | #C9945E | Ekonomi Postası | surface-0 9.46 / 7.23 |
| `--outlet-teknogundem` | #6FC9B6 | #B6EDED | TeknoGündem | surface-0 9.82 / 14.98 |
| `--outlet-girisim` | #C2ABEA | #A985E0 | Girişim Bülteni | surface-0 9.46 / 6.53 |
| `--chart-grid` | #2F2A25 | = | gridline, one step above the window body | surface-3 1.21 |
| `--chart-axis` | #6A5F52 | = | zero line and axis | surface-3 2.75 |
| `--chart-line` | #E9E4DA | = | the measured series | surface-3 13.53 |
| `--chart-proj` | #9A9184 | = | projection, dashed | surface-3 5.52 |
| `--chart-neg-area` | #EC6A5E @0.12 | #F07A3C @0.12 | area below zero (danger) |  |
| `--chart-pos-area` | #E9E4DA @0.05 | = | area above zero, neutral |  |
| `--bar-track` | #3A342D | = | progress and meter track | surface-3 1.39 |
| `--bar-fill` | #B3AA9E | = | progress that is neither good nor bad | surface-3 7.48; surface-4 6.80 |
| `--bar-emph` | #E9E4DA | = | the one share a part-to-whole bar highlights; the rest is bar-fill | surface-3 13.53 |
| `--focus` | #FFFFFF | = | keyboard focus ring: 2 px ink-1 ring, 2 px gap | surface-1 18.66; surface-3 17.14; surface-4 15.60; surface-5 14.40 |
| `--selected-mark` | #FFFFFF | = | 3 px inset marker on the selected row |  |
| `--scrim` | #0A0806 @0.62 | = | true modals only (Ayarlar, Sistem, Kayıt, Onay) |  |
| `--halo` | #0A0806 @0.66 | = | window shadow colour = the halo |  |
| `--shadow-float-c` | #000000 @0.42 | = | float shadow colour |  |
| `--tooltip-shadow-c` | #000000 @0.45 | = | tooltip shadow colour |  |
| `--portrait-lit` | #574B3F | = | radial centre behind the head (avatar disc, portrait well) | darkest hair #060100 2.45 |
| `--portrait-edge` | #2A2520 | = | radial edge |  |
| `--av-rim` | #6A5F52 | = | 1 px avatar rim (line-3) | surface-3 2.75 |
| `--stamp` | #B3AA9E | = | stamp ink (ink-3): Cevaplandı, İmzalandı, Ayrıldı | surface-2 7.79; surface-3 7.48; surface-4 6.80 |
| `--paper-bg` | #EFE9DC | = | newsprint |  |
| `--paper-edge` | #3A342A | = | sheet border |  |
| `--paper-rule` | #2A241C | = | masthead and section rules |  |
| `--paper-ink` | #262019 | = | headline, stat figures | paper-bg 13.32 |
| `--paper-ink-body` | #3E362B | = | body copy | paper-bg 9.82 |
| `--paper-ink-deck` | #6B6252 | = | italic deck | paper-bg 4.97 |
| `--paper-ink-mast` | #4A4238 | = | masthead | paper-bg 8.16 |
| `--paper-ink-meta` | #6E6553 | = | meta line; was #988E7B (2.95:1), darkened to pass 4.5 | paper-bg 4.76 |

### Kategori denetimi

Minimums: body text 4.5, large text 3.0, non-text UI 3.0, disabled label 1.6 to 4.5 (exempt, must still be seen and must read as off), decorative not checked.

| Check | Palette | Worst pair | Ratio | Result |
|---|---|---|---|---|
| `--ink-1` body | standard | surface-4 | 15.60 | pass |
| `--ink-1` body | cb | surface-4 | 15.60 | pass |
| `--ink-2` body | standard | surface-5 | 11.36 | pass |
| `--ink-2` body | cb | surface-5 | 11.36 | pass |
| `--ink-3` body | standard | surface-5 | 6.28 | pass |
| `--ink-3` body | cb | surface-5 | 6.28 | pass |
| `--ink-4` body | standard | surface-4 | 5.02 | pass |
| `--ink-4` body | cb | surface-4 | 5.02 | pass |
| `--ink-off` off | standard | surface-4 | 2.64 | pass |
| `--ink-off` off | cb | surface-4 | 2.64 | pass |
| `--accent` body | standard | surface-4 | 8.50 | pass |
| `--accent` body | cb | surface-4 | 8.50 | pass |
| `--on-accent` body | standard | accent-pressed | 8.12 | pass |
| `--on-accent` body | cb | accent-pressed | 8.12 | pass |
| `--pos` body | standard | surface-4 | 8.04 | pass |
| `--pos` body | cb | surface-4 | 6.76 | pass |
| `--neg` body | standard | surface-4 | 5.04 | pass |
| `--neg` body | cb | surface-4 | 5.61 | pass |
| `--warn` body | standard | surface-4 | 6.34 | pass |
| `--warn` body | cb | surface-4 | 12.65 | pass |
| `--info` ui | standard | surface-3 | 9.01 | pass |
| `--info` ui | cb | surface-3 | 12.61 | pass |
| `--neg-ink` body | standard | neg-tag-bg on surface-3 | 6.88 | pass |
| `--neg-ink` body | cb | neg-tag-bg on surface-3 | 7.57 | pass |
| `--pos-ink` body | standard | pos-tag-bg on surface-3 | 8.92 | pass |
| `--pos-ink` body | cb | pos-tag-bg on surface-3 | 9.02 | pass |
| `--skill-1` body | standard | role-band on surface-4 | 4.76 | pass |
| `--skill-1` body | cb | role-band on surface-4 | 4.76 | pass |
| `--skill-2` body | standard | role-band on surface-4 | 6.04 | pass |
| `--skill-2` body | cb | role-band on surface-4 | 6.04 | pass |
| `--skill-3` body | standard | role-band on surface-4 | 7.81 | pass |
| `--skill-3` body | cb | role-band on surface-4 | 7.81 | pass |
| `--skill-4` body | standard | role-band on surface-4 | 9.11 | pass |
| `--skill-4` body | cb | role-band on surface-4 | 8.57 | pass |
| `--skill-5` body | standard | role-band on surface-4 | 10.34 | pass |
| `--skill-5` body | cb | role-band on surface-4 | 11.42 | pass |
| `--topic-mentor` body | standard | pill fill on surface-2 | 6.97 | pass |
| `--topic-mentor` body | cb | pill fill on surface-2 | 5.10 | pass |
| `--topic-customer` body | standard | pill fill on surface-2 | 7.28 | pass |
| `--topic-customer` body | cb | pill fill on surface-2 | 10.31 | pass |
| `--topic-team` body | standard | pill fill on surface-2 | 6.65 | pass |
| `--topic-team` body | cb | pill fill on surface-2 | 7.47 | pass |
| `--topic-product` body | standard | pill fill on surface-2 | 6.31 | pass |
| `--topic-product` body | cb | pill fill on surface-2 | 8.18 | pass |
| `--topic-funding` body | standard | pill fill on surface-2 | 7.02 | pass |
| `--topic-funding` body | cb | pill fill on surface-2 | 5.57 | pass |
| `--topic-market` body | standard | pill fill on surface-2 | 7.67 | pass |
| `--topic-market` body | cb | pill fill on surface-2 | 8.37 | pass |
| `--topic-agenda` body | standard | pill fill on surface-2 | 6.33 | pass |
| `--topic-agenda` body | cb | pill fill on surface-2 | 6.33 | pass |
| `--outlet-sektor` body | standard | surface-0 | 8.85 | pass |
| `--outlet-sektor` body | cb | surface-0 | 10.15 | pass |
| `--outlet-ekonomi` body | standard | surface-0 | 9.46 | pass |
| `--outlet-ekonomi` body | cb | surface-0 | 7.23 | pass |
| `--outlet-teknogundem` body | standard | surface-0 | 9.82 | pass |
| `--outlet-teknogundem` body | cb | surface-0 | 14.98 | pass |
| `--outlet-girisim` body | standard | surface-0 | 9.46 | pass |
| `--outlet-girisim` body | cb | surface-0 | 6.53 | pass |
| `--focus` ui | standard | surface-5 | 14.40 | pass |
| `--focus` ui | cb | surface-5 | 14.40 | pass |
| `--stamp` body | standard | surface-4 | 6.80 | pass |
| `--stamp` body | cb | surface-4 | 6.80 | pass |
| `--chart-line` ui | standard | surface-3 | 13.53 | pass |
| `--chart-line` ui | cb | surface-3 | 13.53 | pass |
| `--chart-proj` ui | standard | surface-3 | 5.52 | pass |
| `--chart-proj` ui | cb | surface-3 | 5.52 | pass |
| `--bar-fill` ui | standard | surface-4 | 6.80 | pass |
| `--bar-fill` ui | cb | surface-4 | 6.80 | pass |
| `--bar-emph` ui | standard | surface-3 | 13.53 | pass |
| `--bar-emph` ui | cb | surface-3 | 13.53 | pass |
| `--portrait-lit` sil | standard | darkest hair #060100 | 2.45 | pass |
| `--portrait-lit` sil | cb | darkest hair #060100 | 2.45 | pass |
| `--line-hover` ui | standard | surface-4 | 4.70 | pass |
| `--line-hover` ui | cb | surface-4 | 4.70 | pass |
| `--paper-ink` body | standard | paper-bg | 13.32 | pass |
| `--paper-ink` body | cb | paper-bg | 13.32 | pass |
| `--paper-ink-body` body | standard | paper-bg | 9.82 | pass |
| `--paper-ink-body` body | cb | paper-bg | 9.82 | pass |
| `--paper-ink-deck` body | standard | paper-bg | 4.97 | pass |
| `--paper-ink-deck` body | cb | paper-bg | 4.97 | pass |
| `--paper-ink-mast` body | standard | paper-bg | 8.16 | pass |
| `--paper-ink-mast` body | cb | paper-bg | 8.16 | pass |
| `--paper-ink-meta` body | standard | paper-bg | 4.76 | pass |
| `--paper-ink-meta` body | cb | paper-bg | 4.76 | pass |

### Beceri rampası: parlaklık sırası

Relative luminance Y must rise from 1-2 to 9-10 in both palettes, so the order survives greyscale and every colour-vision type. Step = (Y[n+1]+0.05)/(Y[n]+0.05).

| Palette | 1-2 | 3-4 | 5-6 | 7-8 | 9-10 | Steps | Monotonic in all simulations |
|---|---|---|---|---|---|---|---|
| standard | #A09789 Y0.314 | #B4AB9B Y0.412 | #C9C3B4 Y0.547 | #BCDF72 Y0.647 | #86F7A0 Y0.741 | 1.27 1.29 1.17 1.14 | yes |
| cb | #A09789 Y0.314 | #B4AB9B Y0.412 | #C9C3B4 Y0.547 | #A3D2F7 Y0.606 | #D4EEFF Y0.824 | 1.27 1.29 1.10 1.33 | yes |

### Renk görüşü simülasyonu (Machado 2009, şiddet 1.0)

Smallest CIEDE2000 distance between any two members of a set after simulation. Floors: meaning 12, meaning+accent 8, outlets 8, topics 6 (topic pills always carry their word, so hue is the second channel).

| Set | Palette | normal | deutan | protan | tritan | Closest pair (worst view) |
|---|---|---|---|---|---|---|
| meaning (pos, warn, neg) | standard | 22.5 | 7.7 | 12.3 | 7.9 | pos/neg in deutan |
| meaning (pos, warn, neg) | cb | 37.6 | 17.3 | 24.3 | 28.8 | warn/neg in deutan |
| dots (unread ink-2, info, pos, warn, neg) | standard | 22.5 | 7.7 | 12.3 | 7.9 | pos/neg in deutan |
| dots (unread ink-2, info, pos, warn, neg) | cb | 16.1 | 17.1 | 14.8 | 8.6 | ink-2/warn in tritan |
| topic-product against skill-3..5 and pos | standard | 14.5 | 7.3 | 9.0 | 10.9 | topic-product/pos in deutan |
| meaning + accent | standard | 13.1 | 6.8 | 8.6 | 7.9 | warn/accent in deutan |
| meaning + accent | cb | 16.9 | 9.3 | 12.0 | 13.8 | neg/accent in deutan |
| topics | standard | 12.4 | 2.2 | 2.7 | 5.4 | topic-customer/topic-funding in deutan |
| topics | cb | 10.3 | 9.7 | 10.1 | 9.8 | topic-product/topic-funding in deutan |
| outlets | standard | 14.9 | 2.2 | 3.1 | 5.4 | outlet-ekonomi/outlet-teknogundem in deutan |
| outlets | cb | 13.7 | 12.2 | 13.2 | 9.8 | outlet-sektor/outlet-teknogundem in tritan |

The standard palette is required to hold only for normal vision (its row is informative for the other views); the cb palette must hold in every view.


**Result:** all required checks pass.
<!-- contrast:end -->

### 2.3 Kontrast kategorileri

| Category | Minimum | Applies to |
|---|---|---|
| Body text | 4.5:1 | Everything under 19 px bold or 24 px regular: all table data, labels, captions, tags, skill numbers, reasons, stamps. Live data on a leave row too (finding 7). |
| Large text | 3:1 | 19 px bold or 24 px regular and larger. No token relies on this. |
| Non-text UI | 3:1 | Focus ring, hover border, a bar fill or chart line that carries the value. |
| Portrait silhouette | 2:1 | `portrait-lit` against the darkest hair the characters wear (#060100). |
| Disabled | exempt, but 1.6 to 4.5 | `ink-off` labels and glyphs on locked or disabled controls. The reason next to them is body text. |
| Decorative | exempt | Rules, separators, tracks, grid lines, borders that only group. |
| Over the office | opaque ground | No text sits directly on the 3D office. |

### 2.4 Beceri rampası

`band(v)`: 1-2 → `skill-1`, 3-4 → `skill-2`, 5-6 → `skill-3`, 7-8 → `skill-4`, 9-10 → `skill-5`, on all seven
cells. Luminance rises with the value in both palettes and every simulated colour-vision type; the CB twin turns
7-8 and 9-10 blue. Role band alpha 0.05: 1-2 on the band 5.3:1, on a selected row's band 4.8:1. Main skill 700
with a 16×2 underline; secondary 600; the legend writes "ana" and "ikincil".

**Leave rows keep full colour** (finding 7): the numbers are live data the player plans with. Leave reads from the
grey face, the ink-3 name and the "İzinde" tag (onay noktası 3 now has a passing option).

### 2.5 Anlam renkleri ve renk körü paleti

Standard: `pos` green, `neg` red, `warn` orange, `info` sky. CB: `pos` sky blue #56B4E9, `neg` vermilion #F07A3C,
`warn` pale yellow #F6EA85, `info` pale blue #C0E2F6 (was ink-2, the same as the unread dot; finding 18). The
dots set (unread ink-2, info, pos, warn, neg) stays at least 8.6 ΔE apart in every view of the CB palette.
Amber never changes between palettes.

### 2.6 Konu etiketleri

| Pill | Key | Source today | Token |
|---|---|---|---|
| MENTOR | `EVENT_TAG_MENTOR` | Frank speaks, phase gate | `topic-mentor` lilac |
| MÜŞTERİ | `EVENT_TAG_CUSTOMER` | `b2b_*` tags, category customer | `topic-customer` teal |
| EKİP | `EVENT_TAG_TEAM` | `hr_*` tags, category team | `topic-team` sky |
| ÜRÜN | `EVENT_TAG_PRODUCT` | `ship_moment`, category product | `topic-product` sage (rev 2; was lime, 4.3 ΔE from skill 7-8) |
| YATIRIM | `DESK_PAPER_TAG_FUNDING` | category funding, term sheet | `topic-funding` rose |
| PİYASA | `EVENT_TAG_MARKET` | `endgame` topic | `topic-market` sand |
| GÜNDEM | `EVENT_TAG_AGENDA` | everything else | `topic-agenda` neutral |

EŞİK and ATLAS reminders take the outline tag. Pill = 1 px hue border + 12 % fill + 13 px Barlow 700 caps.

### 2.7 Yayınlar

Sektör Telgrafı sky, Ekonomi Postası rose, TeknoGündem teal, Girişim Bülteni lilac, weight 600 on `surface-0`;
replaces `ACCENT_HEX` amber in `news_ticker.gd`.

### 2.8 Örtüler ve hale

| Overlay | Value | Godot |
|---|---|---|
| Office dim while a window is open | multiply 0.84 [WORKING] | `OfficeView.set_dimmed(on)` tweening `_container.self_modulate`, 120 ms. Off during travel and on the city map. |
| Halo | the window's own shadow: `rgba(10,8,6,.66)`, size 96, offset (0,12) | `WindowPanel` StyleBoxFlat `shadow_*`. |
| Modal scrim | `rgba(10,8,6,.62)` | Only true modals. |
| Read-only window | no overlay | 40 px `win-ro` strip; controls disabled; wheel and scroll pass. |

**Banding (finding 23).** `tools/halo.py` repeats Godot's linear feather (vertex alpha from 0.66 to 0 over
96 px, 8-bit blend) over the most common office colours dimmed by 0.84:

| Ground | Widest 8-bit band | Levels across 96 px |
|---|---|---|
| floor #BDA076 | 1 px | 97 |
| wall #829896 | 2 px | 92 |
| office at night (×0.35) #423829 | 4 px | 33 |
| `surface-1` #15120F (rail, top bar) | 15 px | 8 |

Over the office the linear feather does not band; the only banding ground is chrome, which the rail and top bar
cover (they draw above the window layer). Keep the StyleBoxFlat shadow. Faz B checks it once with
`--render-probe` on a dark night shot; if a band shows, `assets/halo_9patch.png` (smoothstep falloff, 4×4 ordered
dither, margins 96) goes into a NinePatchRect behind the window.

### 2.9 Amber istisnaları ve sahne renkleri

| Today | Where | Recommendation |
|---|---|---|
| Founder floor ring `#f0b429e6` | `office_constants.gd:116` | AD position: a charcoal ring with a warm-white inner line, not amber (the founder is not a time state). Erdem decides (onay noktası 12). |
| Office head-icon rings (#A58FDB, #7DBE72, orange, #72AEDD) | `office_actor.gd` | Gone in A2's second pass: a dark disc while working, a cream disc on a break. Any office colour that stays is a named constant in `OfficeConstants` (`HEAD_DISC_WORK`, `HEAD_DISC_BREAK`, `FOUNDER_RING`, `SELECT_RING`), never a UI token. |
| Notice stack "+N" | `office_notice_stack.gd` | `badge-count` neutral. |
| Offer countdown | `top_bar.gd:189` | Into the Sıradaki slot in `warn`; `neg` in the last week. |
| Sprint auto-start note | `top_bar.gd:198` | Leaves the top bar: an `ink-3` line on BuildHUD and in Ürün. |
| TopBar logo square | `top_bar.gd:53` | `LogoEmblem` with `logo_style`. |
| Ticker outlet names | `news_ticker.gd` | Outlet tokens. |
| `ACCENT_DEEP`, 79 reads | cream screens | Map by role when each screen migrates: active tab, stance, open card → `ink-1` + marker; `SectionAmber` → `ink-3` caps label; deadline dots → `warn`; decision-waiting dots → `accent`; `ChipAmber` → `tag-warn` or neutral; `GoalStrip`, `DecisionRow` → ink + tag; work-hours chevron → ink. |
| Meeting panel 3.9:1 amber text | `meeting_panel` | `ink-1` / `ink-2`. |
| Allowed (time family) | gate slot, active speed key, decision dots, invite ring and its kicker | Keep. |

## 3. Yazı

### 3.1 Yüzler, yedek zinciri ve glif envanteri

| Family | Godot files (static) | Roles |
|---|---|---|
| Barlow Condensed | SemiBold, Bold | titles, navigation, caps labels, tags, buttons, option labels, stamps |
| IBM Plex Sans | Regular, Medium, SemiBold, Bold | data, body, numbers, captions |
| IBM Plex Sans Condensed | Regular | narrow columns (task, role title, trait label) |
| Source Serif 4 | Regular, Semibold, It (static, opsz 20) | Frank's words, origin quotes, the paper island |

- **Fallback chains:** Barlow → Plex; Plex alone; Plex Condensed → Plex; Serif alone. **Noto Sans Symbols 2 stays
  out of every text chain:** `Font.get_height` takes the tallest face, and Noto turns a 15 px row into 27 px.
- Barlow lacks the arrows and ✓; they fall back to Plex inside the chain, so they stay text.
- Every other symbol has a decision below (generated by `tools/glyph_inventory.py`; "icon" means an `[img]` of an
  A2 glyph in a RichTextLabel, or a TextureRect beside the Label).

<!-- glyph:begin -->
| Char | Plex | Plex C | Barlow | Serif | Noto S2 | CSV keys | Code literals | Decision |
|---|---|---|---|---|---|---|---|---|
| ↑ U+2191 | yes | yes | **no** | yes | no |  | `scripts/modals/month_summary_modal.gd:123`, `scripts/tabs/product/sprint_ui_shared.gd:20` | keep: in Plex |
| → U+2192 | yes | yes | **no** | yes | no | `MEETING_RES_RELATION_LINE`, `PRODUCT_NEXT_EMPTY`, `TERM_LEVER_ODDS` | `scripts/main/main.gd:431`, `scripts/modals/hr_action_modal.gd:20`, `scripts/modals/month_summary_modal.gd:53`, `scripts/modals/month_summary_modal.gd:56` (+14) | keep: in Plex |
| ↓ U+2193 | yes | yes | **no** | yes | no |  | `scripts/modals/month_summary_modal.gd:123` | keep: in Plex |
| ⇠ U+21E0 | **no** | **no** | **no** | **no** | no | `RND_CROSS_MARK` |  | icon: RND_CROSS_MARK: util/chevron_left (or an A2 dashed arrow) as [img] before {area} |
| ⏎ U+23CE | **no** | **no** | **no** | **no** | yes |  | `scripts/ui/meeting/meeting_panel.gd:57` | icon: meeting_panel ENTER_MARK: a key-cap glyph (A2 backlog: util/enter) beside the Devam label |
| ▲ U+25B2 | **no** | **no** | **no** | yes | yes |  | `scripts/events/core/dice.gd:65`, `scripts/tabs/finance/finance_ozet_view.gd:569`, `scripts/ui/meeting/sales_meeting_adapter.gd:39` | icon: finance_ozet_view league trend: util/chevron_up at 12 px (dice.gd and sales_meeting_adapter use it as an internal sign token mapped to +/−, never drawn) |
| ▼ U+25BC | **no** | **no** | **no** | yes | yes |  | `scripts/events/core/dice.gd:65`, `scripts/systems/sales_constants.gd:182`, `scripts/tabs/finance/finance_ozet_view.gd:569`, `scripts/ui/meeting/sales_meeting_adapter.gd:39` | icon: finance_ozet_view league trend: util/chevron_down at 12 px (same internal sign token note) |
| ★ U+2605 | **no** | **no** | **no** | **no** | yes | `SALES_BAND_STAR` | `scripts/systems/research_tree.gd:171`, `scripts/systems/research_tree.gd:173`, `scripts/systems/sprint_catalog.gd:16`, `scripts/ui/components/star_rating.gd:16` | icon: util/star_full, star_half, star_empty as [img=14] on the text baseline; SALES_BAND_STAR becomes "{n}" + icon; star_rating.gd and sprint_catalog STAR draw icons (research_tree.gd hits are validation messages, never drawn) |
| ✓ U+2713 | yes | yes | **no** | yes | yes |  | `scripts/tabs/hr/hr_assignments.gd:149`, `scripts/tabs/rnd/rnd_assign_panel.gd:25`, `scripts/tabs/rnd/rnd_ui_shared.gd:47`, `scripts/ui/meeting/meeting_panel.gd:55` (+1) | keep: in Plex; Barlow lacks it, so never in a caps label |
| ✕ U+2715 | **no** | **no** | **no** | **no** | yes |  | `scripts/ui/meeting/meeting_panel.gd:55` | icon: meeting_panel RESULT_GLYPHS negative: util/close at 14 px |
| ✗ U+2717 | **no** | **no** | **no** | **no** | yes |  | `scripts/systems/sprint_catalog.gd:17`, `scripts/ui/office/office_map_card.gd:130` | icon: sprint_catalog MARK_UNMET and the office map card: util/close at 14 px in neg |
| ✦ U+2726 | **no** | **no** | **no** | **no** | yes | `MONTH_EVENT_OF_THE_MONTH`, `SUMMARY_EVENT_QUARTER`, `SUMMARY_EVENT_WEEK`, `SUMMARY_EVENT_YEAR` |  | rewrite: drop the ornament: "Ayın olayı" in caps label style is enough (MONTH_EVENT_OF_THE_MONTH, SUMMARY_EVENT_*) |
<!-- glyph:end -->

### 3.2 Yazı merdiveni ve Godot eşlemesi

Twelve sizes, 12 to 40, tokens named by size (`--fs-12` .. `--fs-40`, `--lh-*`; `--lh-16p` and `--lh-20q` are the
paragraph and quote lines). "CSS line" is what the mockups use; "Godot line" is what a Label measures with the
recommended chain. Paragraphs add `line_spacing` +2.

<!-- type:begin -->
| Class | Face file (Godot) | Size | spacing_glyph | Case | CSS line | Godot line (chain) | With Noto Symbols 2 | Paragraph line_spacing |
|---|---|---|---|---|---|---|---|---|
| `.t-h1` | BarlowCondensed-Bold.ttf | 40 | 1 | caps | 52 | 52 (barlow+plex) | 69 (+17) | 0 |
| `.t-h2` | BarlowCondensed-Bold.ttf | 30 | 0 | as typed | 40 | 40 (barlow+plex) | 52 (+12) | 0 |
| `.t-cta` | BarlowCondensed-Bold.ttf | 22 | 0 | as typed | 30 | 30 (barlow+plex) | 38 (+8) | 0 |
| `.t-subhead` | BarlowCondensed-Bold.ttf | 20 | 0 | as typed | 27 | 27 (barlow+plex) | 35 (+8) | 0 |
| `.t-button` | BarlowCondensed-Bold.ttf | 18 | 0 | as typed | 24 | 24 (barlow+plex) | 32 (+8) | 0 |
| `.t-button-sm` | BarlowCondensed-SemiBold.ttf | 16 | 0 | as typed | 22 | 22 (barlow+plex) | 29 (+7) | 0 |
| `.t-tab` | BarlowCondensed-SemiBold.ttf | 18 | 1 | caps | 24 | 24 (barlow+plex) | 32 (+8) | 0 |
| `.t-gate` | BarlowCondensed-Bold.ttf | 18 | 1 | caps | 24 | 24 (barlow+plex) | 32 (+8) | 0 |
| `.t-nav` | BarlowCondensed-SemiBold.ttf | 16 | 1 | caps | 22 | 22 (barlow+plex) | 29 (+7) | 0 |
| `.t-group` | BarlowCondensed-SemiBold.ttf | 15 | 1 | caps | 21 | 21 (barlow+plex) | 27 (+6) | 0 |
| `.t-label` | BarlowCondensed-SemiBold.ttf | 14 | 1 | caps | 19 | 19 (barlow+plex) | 24 (+5) | 0 |
| `.t-tag` | BarlowCondensed-Bold.ttf | 13 | 1 | caps | 18 | 18 (barlow+plex) | 23 (+5) | 0 |
| `.t-micro` | BarlowCondensed-SemiBold.ttf | 12 | 1 | caps | 17 | 17 (barlow+plex) | 21 (+4) | 0 |
| `.t-stamp` | BarlowCondensed-Bold.ttf | 14 | 1 | caps | 19 | 19 (barlow+plex) | 24 (+5) | 0 |
| `.t-stake` | IBMPlexSans-Bold.ttf | 36 | 0 | as typed | 47 | 47 (plex) | 62 (+15) | 0 |
| `.t-hero` | IBMPlexSans-SemiBold.ttf | 30 | 0 | as typed | 40 | 40 (plex) | 52 (+12) | 0 |
| `.t-kpi` | IBMPlexSans-SemiBold.ttf | 26 | 0 | as typed | 35 | 35 (plex) | 45 (+10) | 0 |
| `.t-clock` | IBMPlexSans-SemiBold.ttf | 22 | 0 | as typed | 30 | 30 (plex) | 38 (+8) | 0 |
| `.t-value` | IBMPlexSans-Medium.ttf | 18 | 0 | as typed | 24 | 24 (plex) | 32 (+8) | 0 |
| `.t-body` | IBMPlexSans-Regular.ttf | 16 | 0 | as typed | 22 | 22 (plex) | 29 (+7) | 0 |
| `.t-para` | IBMPlexSans-Regular.ttf | 16 | 0 | as typed | 24 | 22 (plex) | 29 (+7) | +2 |
| `.t-body-strong` | IBMPlexSans-SemiBold.ttf | 16 | 0 | as typed | 22 | 22 (plex) | 29 (+7) | 0 |
| `.t-skill` | IBMPlexSans-Medium.ttf | 16 | 0 | as typed | 22 | 22 (plex) | 29 (+7) | 0 |
| `.t-data` | IBMPlexSans-Regular.ttf | 15 | 0 | as typed | 21 | 21 (plex) | 27 (+6) | 0 |
| `.t-data-strong` | IBMPlexSans-SemiBold.ttf | 15 | 0 | as typed | 21 | 21 (plex) | 27 (+6) | 0 |
| `.t-data-med` | IBMPlexSans-Medium.ttf | 15 | 0 | as typed | 21 | 21 (plex) | 27 (+6) | 0 |
| `.t-meta` | IBMPlexSans-Regular.ttf | 14 | 0 | as typed | 19 | 19 (plex) | 24 (+5) | 0 |
| `.t-key` | IBMPlexSans-Medium.ttf | 14 | 0 | as typed | 19 | 19 (plex) | 24 (+5) | 0 |
| `.t-caption` | IBMPlexSans-Regular.ttf | 13 | 0 | as typed | 18 | 18 (plex) | 23 (+5) | 0 |
| `.t-badge` | IBMPlexSans-Bold.ttf | 13 | 0 | as typed | 18 | 18 (plex) | 23 (+5) | 0 |
| `.t-small` | IBMPlexSans-Regular.ttf | 12 | 0 | as typed | 17 | 17 (plex) | 21 (+4) | 0 |
| `.t-cdata` | IBMPlexSansCondensed-Regular.ttf | 15 | 0 | as typed | 21 | 21 (plexc+plex) | 27 (+6) | 0 |
| `.t-ccaption` | IBMPlexSansCondensed-Regular.ttf | 13 | 0 | as typed | 18 | 18 (plexc+plex) | 23 (+5) | 0 |
| `.t-quote` | SourceSerif4-Regular.ttf | 20 | 0 | as typed | 30 | 28 (serif) | 35 (+7) | +2 |

Ladder in use: 12 · 13 · 14 · 15 · 16 · 18 · 20 · 22 · 26 · 30 · 36 · 40 (12 steps).
Distinct FontVariations needed (face, spacing_glyph): BarlowCondensed-Bold +1, BarlowCondensed-Bold 0, BarlowCondensed-SemiBold +1, BarlowCondensed-SemiBold 0, IBMPlexSans-Bold 0, IBMPlexSans-Medium 0, IBMPlexSans-Regular 0, IBMPlexSans-SemiBold 0, IBMPlexSansCondensed-Regular 0, SourceSerif4-Regular 0.
<!-- type:end -->

Tracking: every caps role is `spacing_glyph` +1 at every size; everything else 0.

### 3.3 Büyük harf, tırnak, unvan

| Text | Rule | Example |
|---|---|---|
| Short CSV labels (≤ 3 words) | caps via `Fmt.upper` | EKİP, KADRO, AYLIK MAAŞ YÜKÜ, AYRILABİLİR |
| Buttons, permanence line, sentences | sentence case | İşe alım başlat, Seçim kalıcıdır · Oyun duraklatıldı |
| Dates, kickers, day separators | sentence case | Karar · Hafta 14 · Nisan 2026, Hafta 13 · Nisan 2026 |
| Card and message titles | as written | Frank'in teklifi |
| Proper nouns | as written | Nordica, Unicorn Inc., Frank Köseoğlu |
| Role titles | CSV case | UX/UI Designer |
| Trait labels | sentence case (TR approval) | Gerçek lider |
| Stake keys | sentence case | Nakit · Frank'e |
| Frank's quotes, origin quotes | straight quotes from the data | "Buraya kadar..." |
| Stamps | caps (they are labels) | CEVAPLANDI, BİTTİ, AYRILDI |

### 3.4 Godot genişlik payı, TR ve EN

Every fixed box is sized from `tools/measure.py`: Chrome's width of the worst TR **and** EN value in the real
face, × 1.08, + 2 px. Pages 15 and 16 render the shell, inbox, options, toasts, Ekip window and reading pane in
English through the same overflow pass.

**Ekip grid** (window 1352, content 1302): face 48 · name 170 · six skills 44 · leadership 80 · task 172 ·
experience 88 · state 142 · trait 142 · salary 80 · morale 116. The worst values (column ruler on page 4):
"Customer Success Manager" (role, 159), "LEADERSHIP" (78), "Hesaplarda görev alıyor" (157), "EXPERIENCE" (78)
and "%100" beside a 32 px bar, "AT RISK OF LEAVING" (tag 138), "Takes Them Under" (108 beside a 24 px box),
"SALARY", morale "100" + 76 px bar.

**Top bar columns** (§10). The EN gate key is capped at 14 characters: "Answer needed" (TR "Cevap bekliyor").

### 3.5 Avatar ve portre kırpımı (Faz C bu kırpımları pişirir)

The rule is defined on the figure, so it survives any re-shoot (`tools/crops.py`):

| Measure | Definition |
|---|---|
| top | first row whose alpha passes 50 % (the hair top; 0 when the render clips the head) |
| neck | the narrowest silhouette row between 25 % and 70 % of the figure height |
| hh | neck - top (head and neck; crown to chin is about 0.91 hh) |
| centre x | mean midpoint of the rows from 30 % to 85 % of hh |

| Output | Source rectangle | Use |
|---|---|---|
| Disc 24, 32, 40, 48 | diameter hh / 0.77, centre y top + 0.55 hh (head about 70 % of the disc) | speaker strip 24, rows and inbox 32, dossier 40, intro 48 |
| Disc 64, 96 | diameter hh / 0.55, centre y top + 0.78 hh (head and shoulders) | counterpart 64, meeting 96 |
| Card 4:5 | hh = 53 % of the card height (crown to chin about 48 %: a 0.48 m studio frame), crown 6 % below the top | reading-pane well 256×320, founder pick 260×325 |

- Faz C bakes the discs and cards with the lit ground (`portrait-lit` radial to `portrait-edge`) included; the UI
  draws only the 1 px `av-rim`. Rendered at 2× and filtered down once.
- **Reserved look:** Frank's chosen head + hair pair (and hair 7 with any bearded head, if candidate A is picked)
  is excluded from `LookSystem` hires and `CounterpartSystem` VCs and prospects, not only his full signature.
- **Portrait light (A3):** 3/4 key, warm fill and a rim light; exposure checked on skin tones 0 and 1 so pale skin
  does not reach `ink-2`; one characterful UAL pose per founder.
- States: grey face for leave (`avatar_grey.gdshader`, saturation 0), grey and 55 % for a departed sender,
  loading placeholder (empty ground, head silhouette in `line-2`, no pop while busts load one per frame).

## 4. Ölçü

| Scale | Values |
|---|---|
| Spacing | 2 · 4 · 6 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 48 only (`lint_spacing.py`; hairline centring offsets such as -1, -3, 1 are listed with their reason) |
| Radii | `r-1` 2 tracks, markers, the three straight corners of a document · `r-2` 4 buttons, tags, inputs, keys, tooltip · `r-3` 6 floats, strips, option bar, portrait card, menu · `r-4` 8 windows · pill · circle for avatars · `cut` 12 and `cut-sm` 8 document bevels |
| Borders | 1 px everywhere · 2 px focus ring, time-state frame, active tab underline, main-skill underline, stamp · 3 px selection marker |
| Shadows (one per box) | window 96 / (0,12) / `halo` · float 20 / (0,6) / black .42 · tooltip 12 / (0,4) / black .45 |

**Godot shapes.** A document box is a StyleBoxFlat with `corner_detail = 1`, `corner_radius_top_right = 12` (8)
and the other three corners 2: Godot draws every corner as a bevel at detail 1, which is why the straight corners
are 2 px (indistinguishable from a 2 px round). CSS: `corner-shape: bevel` (Chrome ≥ 139).

### 4.1 Yükseklikler

| Element | px | Note |
|---|---|---|
| Top bar | 64 | labels by baseline, §10 |
| Ticker | 40 | toggle cell 56; collapsed tab 57×40 |
| Rail row | 48 | 12 top padding, Ayarlar 12 from the bottom |
| Window header / control strip | 72 / 56 | |
| Table head | 36 single, 56 two-tier | |
| Group header | 36 | chevron 16 collapses it |
| Data row / compact row | 40 / 32 | |
| Empty group row | 52 | |
| Inbox row / queue row / day separator | 96 / 44 / 28 | |
| Option bar / wrapped option / armed option | 56 / 88 / auto (about 136) | |
| Stake box / paper bar | 104 min / 72 | |
| Risk strip | 52 | |
| Button / small / large | 40 / 32 / 56 | |
| Input, select | 40 | |
| Tag / pill / badge / stamp | 22 / 20 / 20 / 26 | |
| Menu item / tooltip / toast / notice / floating button | 32 / 28+ / 48 / 52 / 44 | |
| Save slot | 72 | |
| Bars | morale 76×6 with a 1×12 notch at 35 % · XP 32×4 · week 4 (pre-hours 2) · progress 6 · BuildBar 8 | |
| Avatars | 24 · 32 · 40 · 48 · 64 · 96; well 256×320; founder card 260×325 | |

## 5. Durumlar

| Component | Hover | Pressed | Selected / active | Focus | Disabled | Locked |
|---|---|---|---|---|---|---|
| Primary button | `accent-hover` | `accent-pressed` | | ring | `surface-5`, `ink-off` | label + glyph `ink-off`, reason beside |
| Secondary / ghost | border `line-hover`, `ink-1` | `surface-2` | | ring | `line-1`, `ink-off` | same |
| Danger | border and text `neg` | `neg-bg` | | ring | as secondary | |
| Segment tab | 2 px `line-hover` underline | | `ink-1` + 2 px ink underline | ring | `ink-off` | |
| Table row / inbox row | 1 px `line-hover` box on the row rect | | `surface-4` + 3 px marker on the row rect (inbox: plus the small cut) | ring | | |
| Sortable head | `ink-1` + 2 px `line-hover` underline | | `ink-1` + 12 px direction chevron | ring | | |
| Rail row | 1 px `line-hover` inset box | | `surface-4` + marker, name `ink-1`, icon `ink-2` | ring | | icon + name `ink-off`, reason `ink-4` |
| Option bar | border `line-hover` | | **armed**: `surface-4`, `line-hover` border, cut corner, parts at 26 px, ghost "Vazgeç" + amber "Seç" | ring | | lock + label `ink-off`, reason `ink-3` right |
| Speed key | 1 px `line-hover` inset | | 2 px amber inset (time state) | ring | gated: `surface-2`, `ink-off` | |
| Menu item | 1 px `line-hover` box | | check glyph | | `ink-off`, short reason right in `ink-3` | |
| Input | `line-hover` | | | `ink-3` + ring | `line-1`, `ink-off` | |
| Data row on leave | | | | | | face grey, name `ink-3`, "İzinde" tag; numbers unchanged |
| Window, read-only | | | | | buttons disabled, `win-ro` strip | |

## 6. Klavye

**Inbox.** ↑ ↓ move the selection; the pane previews; selecting never stops the clock. Home / End, PageUp /
PageDown jump. Enter on a paper row = "Cevapla" (opens it, the clock stops). Enter on the active decision moves
focus to its first open option. ← → or Tab move between options. **Enter on a focused option arms it; Enter on an
armed option's "Seç" chooses.** Esc disarms. **Enter is ignored for 400 ms** (`--dur-debounce`) after a decision
opens and after an option arms, so no double Enter commits. **Space never chooses, number keys never choose**
(1-4 are speed keys). The meeting panel keeps its own numbered choices (1-5): it is its own scene.

**Esc,** first match wins:
1. An open popup, dropdown or tooltip: close it.
2. A focused text field: drop focus, keep the text.
3. An armed option: disarm it.
4. A ModalLayer modal (Onay, Ayarlar, Sistem, Kayıt/Yükleme, HRAction): close it; Onay means İptal.
5. A PanelLayer panel (Atlas, Eğitim, Mesai, row menu, steward picker): close it.
6. The detail window (dossier): close it.
7. The primary window: an open paper is set aside (`EventGate.set_aside`); any other window just closes. Closing
   Olaylar does not answer an interrupt; the gate slot keeps showing it.
8. No window and a decision is active: reopen Olaylar with the card selected.
9. No window and nothing active: system menu.

**Space and 1-4 while the clock is held:** no speed change; the gate slot frame blinks twice (2 × 180 ms) and one
toast says "Saat kilitli · Önce {başlık} cevapla." at most once every 3 s. A pause that is not a lock behaves as
today.

**F5 / F9.** F5 quicksaves and shows "Kaydedildi · Hafta 14 · 11:00" or "Kaydedilmedi · {neden}"; F9 asks
`SAVE_LOAD_CONFIRM_*` when progress is unsaved, then toasts "Yüklendi".

**Focus order.** Tab cycles inside the topmost surface (modal → panel → window). Inside a window: segment tabs →
control strip → body rows → reading-pane options → close. F6 moves between regions (time block, rail, window,
office). The focus ring is themed (StyleBoxFlat `draw_center=false`, border 2 `ink-1`, expand margin 4).

## 7. Hareket

| Motion | Duration | Rule |
|---|---|---|
| Tab switch, window open and close | 0 ms | instant |
| Office dim in and out | 120 ms | `self_modulate` tween |
| Hover, selection, focus | 0 ms | |
| Option arm and disarm | 120 ms | height expands, no fade; the amber button appears at the end |
| Enter debounce | 400 ms | after a decision opens and after arming |
| Gate pulse | 1600 ms period | the amber dot's ring grows 0 → 12 px while fading .55 → 0; the frame stays static |
| Blocked key feedback | 2 × 180 ms | gate frame alpha 1 → .4 → 1 |
| Count-up | 400 ms ease-out | KASA, KPI values and morale when the change happens on screen; tabular digits; the danger colour switches at the end |
| Toast | in 200 ms (rise 8 + fade), hold 2400 ms (3200 blocked), out 200 ms | one at a time |
| Tooltip | Godot delay 0.5 s, no fade | |
| Stamp | none | a stamp appears with its row, it is not animated |

## 8. Uyum (mantıksal genişlik) ve ölçek kapısı

Logical size = base viewport / UI step under `canvas_items` + `expand`: 16:9 gives 1920×1080 / step, 16:10 gives
1920×1200 / step, 21:9 2560×1080 / step, 32:9 3413×960 / step, whatever the physical window.

| Logical width W | Top bar | Rail | Window area |
|---|---|---|---|
| ≥ 1680 | full (brand 184, metric grid 759, slot 248, time 335) | labelled 184 | x 208 → W-24, y 88 → H-64 |
| < 1680 (in practice 1536) | compact (logo 64, grid 703, slot 216, time 269) | icons 64 | x 88 → W-24 |

- **1920×1080:** the design; area 1688×928; week bar 354.
- **1536×864** (1.25): area 1424×712; every window fits in width; tall bodies scroll under a fixed header; week
  bar 252 (`s2`).
- **1536×960** (16:10 at 1.25): area 1424×808. **1920×1200** (16:10): windows gain height only.
- **2560×1080** (21:9) and **32:9** (5120×1440 → 3413×960; 2731×768 at 1.25): windows keep their widths and stay
  left; the office gains the right; BuildHUD stays at the right edge; the week bar caps at 720.
- **Scale gate (finding 14).** `_fits_chrome` (`display_settings.gd:294-298`) divides the *physical* window by the
  step. Under `canvas_items` + `expand` the logical viewport is the base size over the step, whatever the window,
  so at 1280×720 the 125 % step lays out at 1536×864, which this system already designs for. Recommendation:
  `logical = BASE_VIEWPORT (expanded to the window aspect) / step`, legal when `logical >= 1536×864`. At
  1280×720 and 125 %, 12 px draws at 10 px (`l2`), against 8 px at 100 % (`l1`). Verify in Faz B (the clamp and
  the readability floor keep their current roles).

## 9. Pencere ölçüleri

Windows sit at x = rail + 24, y = 64 + 24; height follows content up to the area. BuildHUD is drawn **below**
windows and **hides while an open window's rect overlaps it**; the same rule covers the research bar, the notice
stack and the move button. The city map hides BuildHUD as today.

| Window | Today | 1920 | 1536 | BuildHUD at 1920 |
|---|---|---|---|---|
| Ekip | 1200×720 | 1352 × fit (≤928) | 1352 × ≤712 | visible (ends 1560, 16 px gap) |
| Olaylar | 900×640 | 1240 × 900 | 1240 × 712 | visible |
| Ürün | 1424×960 | 1424 × 928 | 1424 × 712, body scrolls | hidden |
| Satış | 1280×760 | 1280 × 760 | 1280 × 712, scrolls | visible |
| Finans | 1410×700 | 1344 × 720 | 1344 × 712 | visible |
| Ar-Ge | 1280×780 | 1280 × 780 | 1280 × 712, scrolls | visible |
| Kişisel | 1000×640 | 1000 × 680 | 1000 × 680 | visible |
| Pazarlama (placeholder) | 900×640 | 720 × 400 | 720 × 400 | visible |
| Dosya (detail) | 380×580 | 360 × fit, x 1576 | 360, anchored right, over Ekip | hidden while open |
| Atlas (PanelLayer) | 1440 / 1560 | 1440 / 1560 centred | ≤ 1424, fluid columns | n/a |
| Eğitim / Mesai | 760 / 1000 | same | same | n/a |
| Ayarlar | 640×820 | same | same (`ui_scale_ladder_fits_settings`: ≤ 864) | n/a |
| Sistem / Kayıt / Onay | 380×430 / 660×580 / 440-520 | same | same | n/a |
| Toplantı dock | 0.34 W | same | same | hidden (travel veil) |

## 10. Kabuk

**Top bar (64, `surface-1`).** No row is a stacked box: every label is placed by its baseline, `top =
baseline - ascent(face, size)` (Godot: `font.get_ascent(size)`; a small MetricGrid script owns the positions).
Columns are fixed, sized by `measure.py` for the worst TR and EN value, so the day block and its week bar have
one length in every state and language (the overflow report prints it).

| Block | x at 1920 (compact 1536) | Content and baselines |
|---|---|---|
| Brand | 0-184 (0-64) | `LogoEmblem` 32 at y 16; company `.t-subhead` baseline 31, ellipsis at 108; phase `.t-micro` baseline 50 + three 6 px dots at y 44. Compact: logo only. |
| Key A | 204 (76), 34 wide | row 1 KASA / CASH `.t-label`; row 2 NET `.t-micro` |
| Value B | 246 (116), 148 | row 1 KASA `.t-hero` 30 (fits "$999.999", "−$99.999"); row 2 NET `.t-data-med` + "/ay" `.t-caption` |
| Key C | 414 (276), 58 | RUNWAY, or KEPENK / SHUTTER when cash is negative |
| Value D | 480 (340), 116 | "Artıda" / "Default Alive" (pos 600, tooltip `RUNWAY_PROFITABLE_NOTE`), "14 ay", red "3 hafta" under KEPENK |
| Rule | 616 (468) | 1 px `line-1`, 12 px inset |
| Key E / value F | 637 / 684 (481 / 526) | row 1 MRR `.t-value`; row 2 MARKA `.t-data` |
| Key G / value H | 766 / 843 (600 / 675) | row 1 BURN `.t-value` + unit; row 2 İTİBAR / REPUTATION `.t-micro` (69) and value |
| Day block | 943 → slot (767 → slot) | date `.t-body` baseline 28; week bar at y 38-42 from 08:00 to the workday end, 354 px (252 compact), capped at 720; hour labels `.t-small` baseline 58 under the ends; elapsed fill `ink-3`, ticks, diamond marks for a meeting or sprint decision, now marker `ink-1` |
| Slot (always reserved) | 248 (216) | gated: dot + "Cevap bekliyor" `.t-gate` baseline 30 in amber, subline `.t-key` baseline 51 (card title or "{n} karar bekliyor"); else "Sıradaki" `.t-micro` baseline 29 + one line `.t-key` baseline 50 |
| Time block | 335 (269) | clock `.t-clock` baseline 41; keys II 1x 2x 3x 4x, 40×32 (30 compact) at y 16; active key 2 px amber inset. Node names `PauseBtn`, `Speed1Btn`..`Speed4Btn` stay. |

Gated: a 2 px amber inset frame around slot + time block, keys disabled. **Sıradaki priority:** gate > term-sheet
countdown (`warn`, `neg` in the last week) > sprint decision ("Sprint kararı · 15:00") > next meeting ("14:00 ·
Karadeniz Fabrika") > **fallback "Mesai bitimi · 6 saat"** (the slot is never empty). The shutter countdown is
not in the slot: it is the RUNWAY cell itself (key KEPENK, value in `neg`), so the two never repeat each other.
Click opens the item.

**Rail (184 / 64, `surface-1`, opaque, over the office).** Rows 48, icon 24, name `.t-nav`. Idle: icon `ink-4`,
name `ink-3`. Active: `surface-4`, 3 px marker, icon `ink-2`, name `ink-1`. Locked: icon and name `ink-off`,
reason ("Yakında" or the build's lock reason) `.t-micro` `ink-4` under the name. Badges: `badge-danger` count,
`badge-count` neutral, `badge-gate` amber dot (Olaylar while a decision waits), each with a 2 px cut-out ring in
the row's ground (`surface-1`, `surface-4` when active). Icon mode: names hidden (tooltip), numbered badges move
to the icon's top-right corner (18 px), the gate dot to the corner (8 px), a locked row shows a 12 px lock in
`ink-4` at the bottom-right of the icon. Paths `Margin/Col/<X>Btn/Stack/NameLabel` and `Badge` stay.

**Ticker (40, `surface-0`).** Toggle cell 56; outlet name 600 in its token, headline `ink-3`, separator
"   ·   " in `ink-4`, 48 px fade at the right edge. Closed: a 57×40 tab at the bottom left, the office gains 40 px,
the choice is a per-player setting.

**Inbox header.** Title + one KPI that the filters do not repeat: "En yakın süre" with the soonest deadline
("Bu hafta" in `warn`). Filters carry the counts (Tümü 9 · Bekleyen 3 · Okunmamış 4).

**Floats** (`surface-3`, `line-1`, `r-3`, float shadow, opaque). BuildHUD 320 at (W-344, 88); research bar under
it; notice stack 352 wide, bottom right (max 3, then `+N` neutral), notices are documents (cut corner); move
button 44 at (rail+24, H-108) with the weeks tag. All hide while a window overlaps them.

**Toast** (one component: save, clock lock, office move, invite postpone, share): 48 tall, `surface-4`, cut
corner, a 32 px icon well, bold head + `ink-3` sub; centred 24 above the ticker.

## 11. Bileşen kataloğu ve Godot karşılığı

### 11.1 Kabuk, kutu, veri

| base.css | Godot (Faz D6 / F) |
|---|---|
| `.win`, `.win-head`, `.kpi`, `.win-close`, `.win-ctl`, `.win-ro` | `WindowFrame` with `frame_options` {title, kpis, theme} |
| `.seg`, `.seg-tab`, `.segpick` | `SegTab` button variation (+ count label); the band picker is its small sibling |
| `.btn-*`, `.locked` | `PrimaryButtonDark`, `SecondaryButton`, `GhostButton`, `DangerButton`; locked = disabled button + reason Label |
| `.tag-*`, `.pill`, `.rel`, `.badge-*`, `.stamp` | `UiFactory.make_tag(kind)`, `make_topic_pill(topic)`, `make_relation_chip(id)`, `make_badge(kind)`, `make_stamp(key)` (PanelContainer, rotation -3) |
| `.tbl-head`, `.th.is-sorted`, `.tbl-group`, `.row`, `.row.sm`, `.sk`, `.band`, `.legend`, `.mor`, `.xp`, `.trait`, `.risk`, `.state` | `HRUiShared` dark kit |
| `.stake`, `.part`, `.fx`, `.opt`, `.opt.is-armed`, `.perm` | one signed-part model `EvChips.describe(item, ctx, names, is_delta)` → {label, value, polarity gain/cost/danger/chance, glyph}; the pane draws parts, option bars and the armed box from it |
| `.ib-row`, `.ib-queue`, `.ib-day`, `.pane`, `.portrait`, `.mono`, `.paper-bar` | Olaylar inbox scenes (Faz E) |
| `.av` (+ `.is-grey`, `.is-gone`, `.is-loading`) | baked crops (§3.5) in a TextureRect; grey and gone through `avatar_grey.gdshader` |
| `.toast`, `.tip`, `.menu`, `.select`, `.input`, `.check`, `.switch`, `.slider`, `.sb` | base types themed in `menajer_theme.tres` (switch and grabber use A2's `theme/*.svg`) plus the shared toast |
| `.topbar` (`.tb-x` by baseline), `.rail`, `.ticker`, `.bh`, `.notice`, `.fbtn` | TopBar (MetricGrid), LeftTabs, NewsTicker, BuildHUDPanel, office notice stack, OfficeHud |

### 11.2 A4 için eklenenler

| base.css | Where | Godot |
|---|---|---|
| `.chart` + `.ch-*` (grid, axis, line, proj, neg/pos area, now, zero mark, dot) | Finans CashCurve (page 11) | `cash_curve.gd` `_draw` with the chart tokens; hover: vertical line + ringed dot + tooltip |
| `.spark` | stat tiles | `_draw` polyline, `ink-3`, last point `ink-1` |
| `.share`, `.stackbar` | gider dökümü, monthly flow | HBox rows, ProgressBar-like bars; one colour, the top share `bar-emph`; values at the tip |
| `.prog`, `.bb`, `.curtain` | progress, BuildBar, research bar, loading | `ProgressBar` theme; BuildBar one bar with cap ticks |
| `.sc` (+ `.is-planned`, `.is-late`, `.is-done`), `.goal` | Ürün sprint card, quarter goal strip | `SprintCard.tscn`; 16 px kind and role icons |
| `.rn`, `.re` | Ar-Ge tree (done, active, available, discovered, locked; family, locked and cross-family edges) | `tree_view.gd` tiles + `_draw` edges |
| `.lane`, `.deal`, `.stars`, `.sat`, `.promise`, `.churn` | Satış pipeline, accounts | `sales_tab.gd`; satisfaction draws the visible layer only (tolerance stays hidden) |
| `.seat`, `.dlg`, `.stepper`, `.lever`, `.invite`, `.tchip` | meeting dock, invite, travel | `meeting_panel.gd` (TextureProgressBar radial for rings); invite ring = time state |
| `.pcard`, `.ocard`, `.sstep`, `.logo-pick`, `.lang-opt` | onboarding | `CharacterStep`, `OriginTraitsStep`, `CompanyStep`, `LanguageGate` |
| `.modal`, `.slot` | Onay, SaveLoad | `ConfirmModal` (destructive = danger button; one primary at most), `SaveLoadModal` |
| `.ptip`, `.mchip`, `.mcard`, `.req` | office tooltip, city map (screen s3) | `office_view.gd` hover tip, `office_city.gd` chips, `office_map_card.gd` |

### 11.3 İkonlar

Every glyph on the sheets is read from `icons/` (A2) at build time; `common.ICON_FILES` maps the sheet's names
to A2 files. Only one backlog glyph is still local (`head`, the avatar loading silhouette, drawn to A2's family
rules in `glyphs_local.py`). Sizes follow A2: rail 24, stake 32 beside the 36 px figures (26 in an armed option),
skill heads 20, traits and sprint card 16, chevrons and the rail lock 12.

### 11.4 Hâlâ eksik (A4'te çizilecek, sistem kuralları yeter)

Sürüm notu (release-note centre panel), quarter view columns, type picker, B2C MVP and B2B request lists, Atlas
search and candidate files, training and work-hours panels (the hours slider), dossier window, MonthSummary,
Ayarlar sections, term-sheet table, ending rail and buttons, milestone mode. Each uses only the parts above.

## 12. Gazete adası

The ending's newspaper stays cream. Its faces are the static files Godot ships: **Source Serif 4 Regular,
Semibold and It, all optical size 20** (verified: the repo's static Regular matches the variable font's
advance widths at opsz 20 exactly; every other opsz differs). The sheet pins opsz 20 everywhere, so the
masthead no longer previews a Display cut the game does not have; shipping the variable font would need the
INT-tag axis workaround (memory note) and is not recommended. Sizes are the island's own constants: masthead 600
52, headline 600 32, deck italic 16, body 15, stat figure 600 44, caption italic 12, meta 12. Meta line:
**IBM Plex Sans Condensed 12, caps, +1** (AD agrees; raise 10/11 to 12). `paper-ink-meta` #6E6553 (4.8:1).
`END_LEDGER_TITLE` uppercases the company with `Fmt.upper` ("UNİCORN INC."): fix in the Faz F ending step.

## 13. Metin (TR/EN onayı gereken)

**New keys** the system needs (EN first, TR proposal): gate label "Answer needed" / "Cevap bekliyor" (EN capped at
14 characters); "{n} decisions waiting" / "{n} karar bekliyor"; "Up next" / "Sıradaki" plus one template per
source ("Offer · {n} weeks left" / "Teklif · {n} hafta kaldı", "Offer · final week" / "Teklif · bu hafta son",
"Sprint decision · {time}" / "Sprint kararı · {time}", "{time} · {company}", "Workday ends · {n} h" / "Mesai
bitimi · {n} saat"); the shutter key split from `FIN_SHUTTER_COUNTDOWN` ("Shutter" / "Kepenk" + "{n} weeks" /
"{n} hafta"); read-only strip "A decision is waiting. This window is read only." / "Karar bekliyor. Bu pencere
yalnız okunur." and "Back to the decision" / "Karara dön"; queue row "{n} more decisions queued" / "{n} karar
daha sırada" and "open after this one" / "bundan sonra açılır"; inbox filters "All / Waiting / Unread" / "Tümü /
Bekleyen / Okunmamış"; header KPI "Soonest deadline" / "En yakın süre"; paper bar "Within {n} weeks" / "{n}
hafta içinde", "Final week" / "Bu hafta son", "Respond" / "Cevapla"; blocked reason "Answer the waiting decision
first." / "Önce bekleyen kararı cevapla."; "Choose" / "Seç" (the armed option; "Vazgeç" reuses
`HR_HOURS_CANCEL`); "Your choice" / "Seçimin"; stamps "Answered" / "Cevaplandı", "Done" / "Bitti", "Left" /
"Ayrıldı", "Signed" / "İmzalandı"; leave tag "On leave" / "İzinde" + "{n} weeks" / "{n} hafta" (split from
`HR_STATE_ON_LEAVE_WEEKS`); legend "main / secondary" / "ana / ikincil"; clock-lock toast "Clock held · Answer
{title} first." / "Saat kilitli · Önce {başlık} cevapla."; save toasts; the save-blocked reason now that decisions
live in a window ("Saving is unavailable while a decision is waiting." / "Karar beklerken kaydedilemez."); stake
keys "To Frank" / "Frank'e", "{equity}% equity" / "%{equity} hisse"; five relationship words (placeholders:
Müttefik / Dost / Nötr / Temkinli / Düşman); "Average morale" / "Ortalama moral" and "Roles" / "Roller" as separate
labels; the hours range "{start} to {end}" / "{start} ile {end} arası".

**Recase in the CSV:** `HR_COL_TRAIT` TRAIT → Huy; `HR_SEARCH_START` "+ İŞE ALIM BAŞLAT" → "İşe alım başlat" (the
plus is an icon); `HR_TRAIT_*_LABEL` → sentence case; `RND_NOTE_TITLE` → sentence case; BuildHUD actions →
sentence case; `ANGEL_NUDGE_ACK` "İK'ya git" (the tab is Ekip).

**Rewrite (symbols):** `MONTH_EVENT_OF_THE_MONTH`, `SUMMARY_EVENT_WEEK/QUARTER/YEAR` drop "✦"; `SALES_BAND_STAR`
becomes "{n}" + star icon; `RND_CROSS_MARK` "⇠" becomes an icon (it has no face today). §3.1 lists all.

**Dash law:** 36 TR strings still carry an em or en dash (`DESK_PAPER_GATE_TITLE`, `HR_TASK_NONE`,
`HR_HOURS_WINDOW`, `HR_IDLE_HINT`, `ANGEL_MONTH_HIGHLIGHT`, `HUNT_EMPTY_SLOT`, `HUNT_CB_NONE`, `HUNT_EST_*`,
`PER_NO_VALUATION`, `PERSONAL_MS_SHIP_NOTE`, `END_HL_SHUTTER_STARTED`, ...). Several are Frank's lines (Erdem's
corpus). The system's rule for empty data is an empty cell.

**Number format (code, no text):** display minus is U+2212 ("−$4.200") in `Fmt.money_exact` and `money_chip`
(same width as "+"); TR "%4", EN "4%"; cash exact, flows abbreviated (K, M).

## 14. Açık sorular (Erdem için)

AD positions from the review are noted after each question.

1. **Sıradaki yuvası** hep ayrılsın ve hiç boş kalmasın mı (yedek: "Mesai bitimi · 6 saat")? Öncelik: karar >
   teklif süresi > sprint kararı > görüşme > yedek; kepenk sayacı RUNWAY hücresinde. (AD: evet)
2. **Beceri rampası**: gri, açık gri, soluk mürekkep, limon, nane; renk körü ikizi mavi. (AD: uygun)
3. **Konu renkleri**: ÜRÜN artık adaçayı (limon beceri rengiyle çakışıyordu). EŞİK ve ATLAS renksiz. (AD: uygun)
4. **Renk körü paleti**: olumlu mavi, uyarı açık sarı, olumsuz cıva turuncusu, bilgi açık mavi. (AD: uygun)
5. **Kur ve seç**: çok seçenekli kararda seçenek önce kurulur, amber "Seç" yalnız oyuncunun seçimi üstünde;
   Enter 400 ms bekler. Düğme metni "Seç" mi, seçeneğin kendi fiili mi ("Tarih ver")? (AD: kur ve seç, "Seç")
6. **Seçeneklere sayı kısayolu yok** (1-4 hız tuşu); toplantıda 1-5 kalır. (AD: evet)
7. **Kurucu halkası** ofiste: amber mi, kömür halka ve sıcak beyaz iç çizgi mi? (AD: kömür ve beyaz)
8. **Sprint "otomatik başladı" notu** üst bardan BuildHUD'a ve Ürün'e. (AD: evet)
9. **Ölçek kapısı** mantıksal 1536×864'e göre yeniden kurulsun mu (1280×720'de %125 yasal, 12 px yazı 10 px)?
   (AD: kapıyı düzelt)
10. **Gazete** meta satırı Plex Sans Condensed büyük harf, 10 ve 11 px'ler 12'ye. (AD: evet)
11. **BuildHUD** pencerelerin altında, üstüne pencere gelince gizli; Ekip 1352 ile 1920'de görünür kalır. (AD: evet)
12. **Haber şeridi** kapatılınca 57×40 düğme, oyuncu ayarı. (AD: evet)
13. **İzindeki çalışan**: sayılar tam renk; gri yüz, ink-3 ad, İZİNDE etiketi. (AD: alfa yok)
14. **Noto Symbols 2** metin yedeğinden çıkar; §3.1'deki her sembolün kararı. (AD: evet, envanterle)
15. **Mesaj başlığı** 30 px, cümle düzeni. (AD: evet)
16. **İlişki kelimeleri**: Müttefik / Dost / Nötr / Temkinli / Düşman yer tutucu. (AD: Erdem'in sözcükleri)
17. `END_LEDGER_TITLE` düzeltmesi Faz F son ekranı adımında. (AD: evet)
18. **Masa dili**: belge köşesi ve damga sistemin imzası olsun mu (A2 ikonlarda aynı çentiği kullanıyor)?
19. **Ekip penceresi 1352** (EN sütunları için 1304'ten genişledi; 1920'de BuildHUD'a 16 px kalır).
20. **Frank adayı**: sayfalardaki yer tutucu D. A seçilirse baş ve saç çifti kadro ve VC'lerden ayrılmalı.

## 15. Doğrulama

- Rounds r5 to r8 (this pass): every page read in full and in 1:1 or 2× crops (top bar, rail, Ekip table,
  inbox, options, portraits).
- r5: 16 pages built from A2 glyphs and A3 portraits; rail overlap, controls and layout pages overflowed, the
  candidate glob picked up face crops, share bars missing.
- r6: A2's second pass landed mid-round (new dialect, renamed files); the icon map follows A2's names. Cost glyph
  switched from A2's line minus (read as a dash) to the cost disc. Read-only strip moved to page 5; office layer
  became the s3 screen.
- r7: EN numbers localised; seat, share and slot widths fixed from the overflow report; band picker selector
  scoped; layout table widened.
- r8: final.
- Checks: `contrast.py` all required checks pass; `type_metrics.py` every CSS line ≥ the Godot Label height;
  `lint_spacing.py` clean; `glyph_inventory.py` 12 characters with decisions; overflow report: documentation
  notes only, week bar one length per width (1920: 354, 1536: 252).
- Not verified here: Godot itself (line heights, the 8 % width slack, corner_detail bevels, the halo on a night
  shot, the baseline placement). Faz B measures them with the real FontVariations.
