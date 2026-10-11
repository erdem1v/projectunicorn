# Onboarding · notes

Files: `01`–`07` `.html` + `.png`, `onb2.css` (only what the system lacks), `gen.py` (all frames, TR/EN, 1920/1536),
`render_all.sh`. System CSS (`tokens.css`, `base.css`, `modallar_acilis/modallar.css`) is linked by relative path; the A2
icons are `icons.json`; the evening plate `art/ev_aksam.png` is baked by `bake_plate.py` from the approved Ev plate (`art/` and the
frame PNGs stay local). The logo lock-up comes from `../ana_menu/tools/lockup.py`.

## Concept (5 lines)
1. Setup happens in the founder's flat on the first evening: the home plate is the stage, the UI is papers on the desk.
2. The chosen founder stands in that room behind the papers; picking a face on step 1 changes who stands there (no preview widget).
3. The three steps are three tabbed papers (C); the raised one holds the step, the others carry their summary on the tab.
4. One right-hand document, İlk hafta, is the company's first-week sheet: letterhead (empty until step 3), founder summary
   (A's file: portrait, origin, trait chips, eight skills), difficulty, week-1 money, guided start.
5. It fills as you go: step 1 face and name, step 2 origin, traits and skills, step 3 emblem and name; the curtain shows the same emblem.

## Character art on the stage
**No standing figure exists** under `docs/mockups/menajer/art/` (busts, plates, and the in-game founder seated at the desk in
`office_safe_1920_home.png` only). So the stage uses **the bust over the plate**: the transparent portrait
`docs/mockups/menajer/portraits/founder_05.png` (640×800 RGBA) placed in the living room at 384×480 over the evening home
plate (a no-icons bake, so the seated founder is not doubled), its chest cut by the raised paper, as in direction C. In Godot
this should become the real character: the founder model in a `SubViewport` playing idle, or the live office (MenuBackdrop
option A) with the founder standing in the living room and the camera pushed in. Owner call (open question 5).

## Reused vs new
- Reused: C's header, tabs, raised paper and foot; C's three step-2 columns and every r5 string; last night's portrait crop,
  Rastgele/Sıfırla, name input, cancel modal + copy, curtain layout; the evening home bake; system `.switch`, `.tag-pos/-risk`, `.modal`.
- New: the İlk hafta document (letterhead slot, founder summary, compact two-column skills, difficulty, numbers, toggle at the
  foot); 16-slot face grid with 5 dashed "Yeni portre" slots (16 fits cleanly at 152×190); the logo generator and its
  12-tile grid with "Yeniden üret"; a 1536 geometry that needs no scroll; the curtain with the generated emblem.
- Removed per owner: Frank's cheque list; the separate preview widget; also the slogan field (read by nothing), the cash row
  on the origin card (difficulty owns cash now) and C's name plate on the bust (the document carries the name).

## Logo system
Monogram (1 letter "U" or 2 letters "UI" from the company name's initials) × shape (circle, hexagon, square, shield, tag,
diamond) × colour (8) × style (filled: shape in colour, letter in surface-1; outline: 5/100 stroke, letter in colour;
split: a slanted cut, light half with a dark letter, dark half at 26 % of the colour with a light letter) = 2 × 6 × 8 × 3 = 288.
A set of 12 is drawn so every shape appears twice, every style four times and every colour at least once; "Yeniden üret"
draws another 12 from a seed (company name + reroll count), so the same name always opens on the same first set.
Palette (proposed new tokens `--emb-*`; mid-light so they sit on charcoal; none reads as the amber primary or the #FFA028
game mark): Kemik/Bone #E6DED0, Kiremit/Brick #D9704E, Zeytin/Olive #A9B25E, Adaçayı/Sage #82BD9B, Petrol/Teal #4BA8B0,
Çelik/Steel #7FA2DE, Leylak/Lilac #AC8EDB, Gül/Rose #DE8DAB. Drawn sizes: tile 104, letterhead 56, curtain 112.

## Godot feasibility
- Stage: `TextureRect` of a baked evening plate (`--office-shot=home:19:30`, nobody in it) with `self_modulate`, or the live office.
  Papers are `PanelContainer`s with the existing document StyleBoxes (raised = `shadow_window`); tabs as in C's notes.
- İlk hafta: one flow-level `PanelContainer` listening to `draft_changed`; values come from constants before a run exists
  (difficulty table, `TOOLS_BASE_MONTHLY[1]`), never from GameState. Toggle = system switch (`CheckButton` skin).
- Difficulty needs a new constant table (cash per difficulty) and a persistent "a run was finished" flag in the profile or
  settings file (not the run save) to unlock Zor. Both are design constants: pending approval.
- Logo: `LogoEmblem._draw()` per the INDEX row; no textures; deterministic from (name, reroll).
- Dashed placeholders: no dashed StyleBoxFlat; 9-slice dashed texture or `draw_dashed_line` in `_draw`.
- 1536: fits without scrolling (locked origin quotes hidden below a width threshold, condensed skill reasons).

## Open questions
1. Difficulty numbers $15.000 / $10.000 / $6.000 are the owner's example: approve or replace. Does difficulty set cash for every
   origin, or scale each origin's own cash once Mirasyedi / Kurumsal Firari exist?
2. Does difficulty change anything besides cash? The frame says only "Başlangıç kasasını belirler" (Software Inc. style).
3. Zor unlock: "finish a run" = any ending (bankruptcy too) or only a win (Series A)?
4. Guided toggle default: on for the first run, remembered after? Still tied to O11 and to tutorial content existing.
5. Stage figure: the bust over the plate (this mockup) vs the real 3D founder standing idle in the live office.
6. The 5 "Yeni portre" placeholders: ship them visible (a promise of more faces) or show only the 11 real faces?
7. Emblem palette as new tokens; does the company emblem appear anywhere in the run's chrome (top bar, Finans)?
8. Runway unit: months like the top bar ($1,5K/ay, 7 ay) as in last night's final set; C used weeks.
