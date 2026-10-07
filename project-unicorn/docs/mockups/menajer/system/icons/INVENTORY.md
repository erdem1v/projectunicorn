# Icon inventory, Menajer Masası (Faz A2, second pass)

The review sheet is `../icons.html`, rendered as `../icons_p1.png` to `../icons_p8.png`.

## Files in this folder

| File | What it is |
|---|---|
| `glyphs.py` | The single source of every glyph (geometry, 24 grid). |
| `kit.py` | Geometry kit and SVG export. It needs shapely 2.x (`pip install shapely`, or `ICON_PYLIB=<dir>`). |
| `build_icons.py` | Writes the 98 UI SVGs, the 9 office head icons and the 3 theme SVGs. |
| `run_all.py` | Rebuilds everything: SVGs, office composite, sheet and page PNGs. |
| `godot_check.gd` | Rasterises every SVG with Godot 4.6.2's own loader. The result is sheet page 8. |
| `icons_a2.py` | Drop-in for `../tools/icons.py`. It has the same `ICON` names and `ic()` signature and needs no shapely. A1 pages switch with `from icons_a2 import ICON, ic`. |
| `proof.py` | Iteration proofs: 4x cells plus a 1:1 strip at 16 and 20 px. |
| `office_test.py` | Pastes the head icons onto the game's own renders at the real head positions. |
| `rounds/` | Iteration renders and the variant trials (`try_variants*.py`). |
| `rounds/v1/` | The first pass's source and sheet, kept for comparison. |
| `review/` | Images the sheet uses. |

## What changed in the second pass (art-direction review)

| Finding | Change |
|---|---|
| 9: the family read as Phosphor Duotone, lighter than v0 on the rail | The whole family moved to the office head-icon dialect: a solid primary shape, knock-out detail and a 2.6 line. The head icons now use the same glyph files as the UI. The signature is the paper notch (see the rules). |
| 15: Finans cylinder read as "database" | The finance glyph is now a coin with the dollar knocked out. Two candidates failed first: an offset coin stack still read as a database, and two banknotes read as a camera (`rounds/variants*.png`). |
| 15: Gözü yüksekte A read as promotion | The suitcase, which was candidate B, is now the only glyph. The steps glyph is deleted. |
| 15: Gerçek lider mortarboard collides with "Eğitime gönder" | The glyph is an umbrella over a small figure. A wing did not read at 16 px. The mortarboard is now `world/training`. |
| 15: Hayır diyemez thumbs-up read as approval | The glyph is a speech bubble with a check, over a stack of papers ("söz birikir"). |
| 15: Test = bug means "bug count" | The Test skill is a bug with a check through it (`skill/qa`). The plain bug is `product/bug`, for the sprint-card chip and the live bug count. |
| 15: Ürün = target collides with the quarter "hedef" goal | The Ürün skill is a signpost: choosing a direction, that is, feature decisions. |
| 21: rail rules conflicted with SPEC | SPEC wins: idle icon `ink-4` and name `ink-3`; selected icon `ink-2` and name `ink-1`; locked icon and name `ink-off`, with "Yakında" in `ink-4`. In icon mode the numbered badge moves to the icon corner with a 2 px cut-out ring in the row's ground colour (`surface-1` idle, `surface-4` selected). A locked row shows a 12 px lock in the corner. |
| 27: head-icon ring hues echoed pos and warn | The rings are gone. A break flips the disc: dark disc for work, cream disc for a break. The colours are named scene constants (see below). |
| 13: Plex lacks ★ ▲ ▼ ✦ ⏎ ✕ | Each symbol now has an icon, and the table below lists every key and code literal. |
| 10: ink outline vanished on charcoal | The sheet's avatars sit on a lit ground: a `line-2` centre fading to `surface-3`, with a 1 px `line-3` rim. |
| A4 list: missing glyphs | Added: document, departed person, seat, milestone, shutter, term sheet, fund, runway, save/load/menu/language, three origins, four office places, training, raise, crown, map. Also added the A1 drafts' history, info, queue and keyboard glyphs. |
| Godot claims | All 98 files were rasterised by Godot 4.6.2's `Image.load_svg_from_string` (ThorVG) at 96, 24, 20 and 16 px. Knock-outs, tone and evenodd match Chrome, and no file failed (page 8). |

## Family rules (what an implementer must keep)

- **Grid.**
  - The grid is 24 x 24 with a 20 px live area (2 px margin).
  - Every glyph is drawn for 24, 20 and 16 px.
  - 12 px is only for plain marks: chevrons, play, and the lock in the rail corner.
- **Solid shape, knock-out detail.**
  - The primary shape is filled. Its details are cut through to the ground.
  - Every cut, and every gap between two pieces, is 2 px at 24. That is 1.33 px at 16.
  - Line glyphs (chevrons, plus, minus, close, check, arrows, revert, reply, menu) use a 2.6 line, the same as the office head icons.
- **Two tones.**
  - Both tones use one colour. The second plane is at 40 %: the person behind, the empty half, the shade face, a secondary part.
  - The meaning always sits in the solid shape, so the glyph still reads if the tone is lost.
- **Paper notch (the family's signature).**
  - Every paper object has its top-right corner cut at 45°: envelope, document, newspaper, term sheet, and the paper in the inbox tray.
  - The cut is the same one the review proposes for the UI's paper rows and stake box.
- **File format.**
  - Files are `#FFFFFF`, so the game colours them with `modulate`. The tone is `fill-opacity="0.4"`.
  - The files contain plain filled paths with `fill-rule="evenodd"`.
  - There are no strokes, masks, filters, CSS, classes, `<use>`, text or transforms.
  - The office head icons are 128 px files with a baked disc (see below). The theme SVGs bake their colours.
- **Colour.**
  - Gain is `pos` with the up arrow. A cost is ink with the minus or the slice. Danger is `neg` with the triangle. Chance is the die (SPEC rule 5).
  - Traits are never coloured.
  - Amber never colours an icon, except as the time-state dot.
- **Sizes.**
  - 16: traits, sprint card, inline.
  - 18: departments, primary plus, clock.
  - 20: skill column heads, close, news.
  - 22 to 24: warn and the rail.
  - 32: stake glyphs next to the 36 px figures. At 28 the glyph looks smaller than the figure.
  - The sprint card's 12 px icons (`UiTokens.PRODUCT_ICON_PX`) move to 16.
- **Godot raster (to verify in Faz B).**
  - Raster once per (icon, px) with `Image.load_svg_from_string(svg, px / 24.0)` into a cached `ImageTexture`, in one home such as UiFactory.
  - Shrinking a 24 px texture to 16 without mipmaps closes the cuts.
  - Godot 4.5's `DPITexture` is a candidate, not yet checked.

## A. Every existing SVG in the repo (52 files plus the Lucide licence)

The proposed repo layout mirrors this folder: `assets/icons/{rail,skill,dept,trait,product,stake,util,world,place,origin,theme}/`. The office icons stay at `assets/art/office/icons/` with the same nine names.

| Existing file | Where it is used today | Decision | New file |
|---|---|---|---|
| `assets/icons/tabs/product.svg` (Lucide) | `scenes/ui/components/LeftTabs.tscn:4` | redraw | `rail/product.svg` (box, shade face in tone; also the BuildHUD head) |
| `assets/icons/tabs/sales.svg` (Lucide handshake) | `LeftTabs.tscn:7` | redraw, new metaphor | `rail/sales.svg` (funnel with two stages and a closed-deal dot) |
| `assets/icons/tabs/hr.svg` (Lucide users) | `LeftTabs.tscn:5` | redraw | `rail/hr.svg` |
| `assets/icons/tabs/finance.svg` (Lucide bank) | `LeftTabs.tscn:6` | redraw, new metaphor | `rail/finance.svg` (coin with the dollar knocked out) |
| `assets/icons/tabs/personal.svg` (Lucide) | `LeftTabs.tscn:10` | redraw | `rail/personal.svg` |
| `assets/icons/tabs/marketing.svg` (Lucide megaphone) | `LeftTabs.tscn:8` | redraw | `rail/marketing.svg` |
| `assets/icons/tabs/rnd.svg` (Lucide flask) | `LeftTabs.tscn:9` | redraw | `rail/rnd.svg` |
| `assets/icons/tabs/events.svg` (Lucide inbox) | `LeftTabs.tscn:11` | redraw, new metaphor | `rail/events.svg` (envelope with the paper notch) |
| `assets/icons/tabs/settings.svg` (Lucide) | `LeftTabs.tscn:12` | redraw | `rail/settings.svg` |
| `assets/icons/tabs/LICENSE-lucide.txt` | `docs/HARITA.md:306` | delete | Delete it in the commit that replaces the last Lucide-derived SVG (9 tabs and 9 office icons). If the office set lands later, move the licence to `assets/art/office/icons/` and fix HARITA:306. |
| `assets/icons/traits/loyal.svg` | `scripts/tabs/hr/hr_ui_shared.gd:18-20` (`TRAIT_ICON_DIR`, `TRAIT_ICON_DRAWN`), `:101-103` (`trait_icon`, called at `:187`, `:278`) | redraw | `trait/loyal.svg` (anchor) |
| `assets/icons/traits/picks_it_up_fast.svg` | same | redraw | `trait/picks_it_up_fast.svg` (bolt) |
| `assets/icons/traits/last_one_out.svg` | same | redraw | `trait/last_one_out.svg` (crescent and star) |
| `assets/icons/traits/takes_them_under.svg` | same | redraw, new metaphor | `trait/takes_them_under.svg` (umbrella over a small figure). **Meaning to confirm.** |
| `assets/icons/traits/double_checker.svg` | same | redraw | `trait/double_checker.svg` (double check, first pass in tone) |
| `assets/icons/traits/cant_say_no.svg` | same | redraw, new metaphor | `trait/cant_say_no.svg` (bubble with a check over papers). **Meaning to confirm.** |
| `assets/icons/traits/bag_packed.svg` | same | redraw | `trait/bag_packed.svg` (rolling suitcase) |
| `assets/icons/traits/mood_buster.svg` | same | redraw | `trait/mood_buster.svg` (rain cloud) |
| `assets/icons/traits/unspecified.svg` | same (fallback for founder traits and unknown ids) | redraw | `trait/unspecified.svg` (diamond, centre knocked out) |
| `assets/icons/product/kind_feature.svg` | `scripts/tabs/product/sprint_card.gd:143`, `sprint_panel.gd:259` (via `sprint_ui_shared.gd:9,112-115`) | redraw | `product/kind_feature.svg` |
| `assets/icons/product/kind_polish.svg` | same | redraw | `product/kind_polish.svg` |
| `assets/icons/product/kind_fix.svg` | same | redraw | `product/kind_fix.svg` (bandage, pad in tone) |
| `assets/icons/product/kind_research.svg` | same | redraw, meaning fixed | `product/kind_research.svg` (person in a lens: "{n} kullanıcıyla görüş") |
| `assets/icons/product/role_product.svg` | `sprint_card.gd:88` (`"role_" + role`) | delete | `skill/product.svg` |
| `assets/icons/product/role_design.svg` | same | delete | `skill/design.svg` |
| `assets/icons/product/role_dev.svg` | same | delete | `skill/engineering.svg` |
| `assets/icons/product/role_test.svg` | `sprint_card.gd:88`; bug warning chip `sprint_panel.gd:78` | delete | role: `skill/qa.svg`; bug chip: `product/bug.svg` |
| `assets/icons/product/bubble.svg` | `area_panel.gd:181`, `sprint_panel.gd:120`, `sprint_ui_shared.gd:279` | redraw, renamed | `product/voices.svg` |
| `assets/icons/product/tick.svg` | `sprint_card.gd:197`, `sprint_panel.gd:117,173` | delete | `util/check.svg` |
| `assets/icons/product/arrow.svg` | `area_panel.gd:108,112`, `sprint_panel.gd:183`, `sprint_ui_shared.gd:300` | delete | `util/arrow_right.svg` |
| `assets/icons/build/monitor.svg` | `scripts/ui/components/build_bar.gd:103` (via `bar_kit.gd:13,43`) | delete | `rail/product.svg` |
| `assets/icons/build/phase_support.svg` | `build_bar.gd:124` | delete | `util/shield.svg` |
| `assets/icons/build/decision.svg` | `build_bar.gd:144` | delete | `util/play.svg` |
| `assets/icons/chevron_up.svg` | `hr_ui_shared.gd:331` (`chevron`, called at `work_hours_modal.gd:404`, `area_panel.gd:278`, `rnd_assign_panel.gd:151`) | redraw | `util/chevron_up.svg` |
| `assets/icons/chevron_down.svg` | `hr_ui_shared.gd:332` (`work_hours_modal.gd:400`, `area_panel.gd:278`, `rnd_assign_panel.gd:151`) | redraw | `util/chevron_down.svg` |
| `assets/icons/chevron_right.svg` | `area_panel.gd:272` | redraw | `util/chevron_right.svg` (and new `util/chevron_left.svg`) |
| `assets/icons/chevron_flat.svg` | `hr_ui_shared.gd:337` (`work_hours_modal.gd:402`) | redraw, renamed | `util/flat.svg` |
| `assets/icons/clock.svg` | `scripts/tabs/hr_tab.gd:268` (mesai button) | redraw | `util/clock.svg` |
| `assets/icons/lock.svg` | `hr_ui_shared.gd:362` (`lock_glyph`: `ending_scene.gd:419`, `training_modal.gd:92`, `hr_atlas_modal.gd:187`, `hr_ledger.gd:291`, `sprint_card.gd:82`, `product_tab.gd:185`, `meeting_panel_option.gd:95`); `ending_scene.gd:36,495` | redraw | `util/lock.svg` |
| `assets/icons/revert_arrow.svg` | `hr_ui_shared.gd:341` (`work_hours_modal.gd:328`) | redraw, renamed | `util/revert.svg` |
| `assets/icons/warning.svg` | `hr_ui_shared.gd:358` (`hr_tab.gd:435`) | redraw | `util/warn.svg` |
| `assets/icons/slider_grabber.svg` | `scripts/theme/build_theme.gd:400`, `themes/master_theme.tres:11,2525-2527` | redraw dark | `theme/slider_grabber.svg` |
| `assets/icons/switch_off.svg` | `build_theme.gd:413`, `master_theme.tres:13,2393-2394` | redraw dark | `theme/switch_off.svg` |
| `assets/icons/switch_on.svg` | `build_theme.gd:412`, `master_theme.tres:12,2391-2392` | redraw dark | `theme/switch_on.svg` (ink, not amber) |
| `assets/art/office/icons/code.svg` (Lucide) | `scripts/ui/office/office_actor.gd:10` | redraw | `office/code.svg` (glyph = `skill/engineering`) |
| `assets/art/office/icons/test.svg` (Lucide check) | `office_actor.gd:11` | redraw, new metaphor | `office/test.svg` (glyph = `skill/qa`) |
| `assets/art/office/icons/research.svg` (Lucide search) | `office_actor.gd:12-13` (`research`, `plan`) | redraw | `office/research.svg` (glyph = `util/search`) |
| `assets/art/office/icons/design.svg` (Lucide pen) | `office_actor.gd:14` | redraw, new metaphor | `office/design.svg` (glyph = `skill/design`) |
| `assets/art/office/icons/phone.svg` (Lucide) | `office_actor.gd:15` (also the call blink, `:108`) | redraw | `office/phone.svg` |
| `assets/art/office/icons/coffee.svg` (Lucide) | `office_actor.gd:16` | redraw | `office/coffee.svg` (break disc) |
| `assets/art/office/icons/wc.svg` (Lucide door) | `office_actor.gd:17` | redraw, new metaphor | `office/wc.svg` (the letters WC, break disc) |
| `assets/art/office/icons/meeting.svg` (Lucide users) | `office_actor.gd:18-19` (`visit`, `meeting`) | redraw | `office/meeting.svg` (glyph = `rail/hr`, break disc) |
| `assets/art/office/icons/food.svg` (Lucide utensils) | `office_actor.gd:20` | redraw | `office/food.svg` (break disc) |

### Office head icons

- **Contract (unchanged from today).**
  - Each file is 128 x 128, with shadow, disc, edge and glyph.
  - `pixel_size = 1 / height` (`office_actor.gd:97`).
  - The sprite is tinted by `ICON_TINT` #d2d2d2. Mipmaps are on in the existing `.import`.
  - `office_actor.gd` needs no change.
- **Scheme.**
  - A working person gets a dark disc #1E1B18 with edge #0E0C0A and glyph #F1ECE2.
  - A person on a break (coffee, food, meeting, WC) gets the disc flipped: cream #F1ECE2, edge #2B2722, glyph #1E1B18.
  - These are scene data. They should live in `OfficeConstants` as `HEAD_DISC`, `HEAD_EDGE`, `HEAD_GLYPH`, `HEAD_BREAK_DISC`, `HEAD_BREAK_EDGE` and `HEAD_BREAK_GLYPH`.
  - The first pass's four ring hues (#A58FDB, #D39A66, #7DBE72, #72AEDD) are retired. `build_icons.HEAD_RING_HUES` keeps them only for the comparison row on page 7.
- **Evidence.**
  - Page 7 shows the icons on the game's own renders (`art/office_safe_1920*_noicons.png`), at the real head positions and sizes from `*_heads.json`: 32 px in the iş hanı and 26 px in the loft.
  - It also shows the first-pass rings and today's icons for comparison.

## B. New files with no repo predecessor

| New file | Purpose |
|---|---|
| `rail/rivals.svg` | Optional ninth rail tab if the rival world (c706349 PRD) gets one: a podium. |
| `skill/sales.svg`, `skill/customer_success.svg` | Ekip column heads: tag and headset. |
| `dept/product_design.svg`, `dept/development.svg`, `dept/sales.svg`, `dept/customer_success.svg` | Roster group headers: bulb, terminal, briefcase, two bubbles. |
| `product/bug.svg` | Sprint-card bug chip and live bug count. |
| `stake/cash_in.svg`, `stake/cost.svg`, `stake/equity.svg` | Gain, cost and equity. Danger is `util/warn` and chance is `util/dice`. |
| `util/plus`, `minus`, `close`, `chevron_left`, `pause`, `play`, `news`, `shield`, `move`, `search`, `filter`, `inbox`, `mail_open`, `reply`, `calendar`, `dice`, `star_full`, `star_half`, `star_empty` | Utility glyphs from the v0 frames and the inbox. `filter` is now sliders; the funnel belongs to Satış. |
| `util/tri_up`, `tri_down`, `sparkle`, `enter` | Replacements for ▲ ▼ ✦ ⏎ (table D). |
| `util/history`, `info`, `queue`, `doc`, `keyboard`, `save`, `load`, `menu`, `language` | Glyphs from the A1 drafts plus save/load/menu/language. |
| `world/person_left`, `seat`, `milestone`, `shutter`, `term_sheet`, `fund`, `runway`, `crown`, `training`, `raise`, `map` | Game concepts. The milestone is a flag on a summit ("Kilometre Taşları", the milestone ending). The training glyph is the mortarboard ("Eğitime gönder"). The raise is the Finans coin with an arrow up. |
| `place/home`, `ishani`, `plaza`, `loft` | Office places for the map chips and office card ("Ev", "İş hanı", "Plaza katı", "Depo loft"). |
| `origin/self_made`, `heir`, `corporate` | Onboarding origin cards: a seedling, a key, a necktie. |

The optional `skill/leadership` flag from the first pass is gone. Liderlik stays a text column head as SPEC has it, and the flag now marks the milestone.

## C. The v0 draft glyphs (`v0/build2.py`, `../tools/icons.py`)

`icons_a2.py` maps every name `../tools/icons.py` uses to a family file:

| v0 / A1 draft | Family file |
|---|---|
| `urun`, `satis`, `ekip`, `finans`, `kisisel`, `pazarlama`, `arge`, `olaylar`, `ayarlar` | `rail/*`. `satis` is the funnel; the tag stays `skill/sales`. |
| `tasarim`, `kod`, `test`, `kulak` | `skill/design`, `skill/engineering`, `skill/qa` (bug with check), `skill/customer_success` |
| `lider`, `iskolik`, `sadik`, `titiz`, `cabuk`, `hayir`, `bavul`, `bulut`, `belirsiz` | `trait/*`. `lider` is the umbrella. |
| `up`, `pie`, `minus` | `stake/cash_in`, `stake/equity`, `stake/cost` |
| `warn`, `clock`, `plus`, `close`, `chev`, `chevdown`, `lock`, `pause`, `news`, `shield`, `play`, `move`, `check`, `dice`, `search`, `reply` | `util/*` (`chev` is `chevron_right`) |
| `doc`, `info`, `stack`, `history`, `kbd`, `save` | `util/doc`, `util/info`, `util/queue`, `util/history`, `util/keyboard`, `util/save` |
| `left`, `flag` | `world/person_left`, `world/milestone` |

The A1 pages (`pages/04` to `08`) are not in my folder, so I did not rebuild them. Switching their generator to `icons_a2` puts the family on them, which is the icon half of review finding 3.

## D. Symbols IBM Plex lacks once Noto Symbols 2 leaves the chain (finding 13)

| Symbol | Where today | Decision | Icon |
|---|---|---|---|
| ★ | `scripts/ui/components/star_rating.gd:16` (five glyphs, the half by clipping); `scripts/systems/sprint_catalog.gd:16`; `scripts/systems/sales_ledger.gd:399`; CSV `SALES_BAND_STAR` "{n}★" | StarRating draws five TextureRects, using `star_half` for the half. The "{n}★" text uses a RichTextLabel `[img]`. | `util/star_full`, `star_half`, `star_empty` |
| ▲ ▼ | `scripts/events/core/dice.gd:65` (odds row sign); `scripts/tabs/finance/finance_ozet_view.gd:569` (trend) | Code puts an icon beside the label instead of a symbol in the text. No CSV change. | `util/tri_up`, `util/tri_down` |
| ✦ | CSV `MONTH_EVENT_OF_THE_MONTH`, `SUMMARY_EVENT_WEEK`, `SUMMARY_EVENT_QUARTER`, `SUMMARY_EVENT_YEAR` ("✦ AYIN OLAYI") | The symbol leaves the string and the label gets a leading icon. The four rows need TR/EN approval. | `util/sparkle` |
| ⏎ | `scripts/ui/meeting/meeting_panel.gd:57` (`ENTER_MARK`) | Icon after the option label | `util/enter` |
| ✕ | `meeting_panel.gd:55` (`RESULT_GLYPHS` negative) | 16 px icon in the result colour. ✓ is in Plex, but it can be the icon too, for symmetry. | `util/close` (`util/check`) |
| ⋯ | not used (only a smoke comment) | nothing to do | |

✓ → × − · ⅓ are in Plex and stay text.

## Code that reads icon paths (for the Faz F commit that swaps them)

- **Rail and traits.**
  - `scenes/ui/components/LeftTabs.tscn:4-12`.
  - `scripts/tabs/hr/hr_ui_shared.gd:18-20` (trait dir and drawn list), `:331-362` (chevrons, revert, warning, lock).
- **Product and BuildHUD.**
  - `scripts/tabs/product/sprint_ui_shared.gd:9,112-115`. The ids `role_*`, `bubble`, `tick` and `arrow` change, and the bug chip moves to `product/bug`.
  - `scripts/tabs/product/area_panel.gd:272`.
  - `scripts/ui/components/bar_kit.gd:13`.
  - `scripts/ui/components/build_bar.gd:103,124,144`.
- **Other screens.**
  - `scripts/tabs/hr_tab.gd:268`.
  - `scripts/modals/ending_scene.gd:36`.
- **Theme.**
  - `scripts/theme/build_theme.gd:400,412-413`. The theme is regenerated and `THEME_STAMP` is bumped.
- **Office.** `scripts/ui/office/office_actor.gd:9-20`, plus the six scene constants in `OfficeConstants`.
- **Smoke.**
  - `rail_tabs_match_scene_order` pins the rail order, not the files.
  - Grep for any other case that loads these paths before the swap.

## Meanings for Erdem to confirm (orange on sheet page 3, plus two more)

1. **Gerçek lider:** an umbrella over a small figure ("takes them under"). It may read as insurance. The wing, the review's first choice, did not read at 16 px (`rounds/variants.png`).
2. **Hayır diyemez:** a bubble with a check over piled papers ("says yes, promises pile up"). At 16 px it can read as a checklist.
3. **Ürün skill:** a signpost (choosing a direction). It is the least conventional skill head.
4. **Test skill:** a bug with a check through it. The check is clear at 20 px and only just visible at 16 px.
5. **İşkolik and Titiz:** the glyphs are fine, but the engine does not read their effects today (`overtime_morale_mult`, `bug_rate_mult`).
6. **Head icons:** the flipped disc for a break replaces the four ring hues. That is a design call for the 3D office.
7. **Founder traits:** these were not drawn and fall back to "belirsiz".
