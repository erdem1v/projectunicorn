Research report: capturing art for the HTML mockups (Project Unicorn, Godot 4.6.2). Read-only; nothing was modified or run.

```
=====================================================================
REPORT: capture plan for the art behind the HTML mockups
=====================================================================
Repo root: C:\Users\erdem\Desktop\project steam\project-unicorn
Labels: VERIFIED = read in code, data or pixels. INFERRED = reasoned from code, not run.
UNCERTAIN = open question.

---------------------------------------------------------------------
0. BASELINE CONTEXT (what the three screens show today)
---------------------------------------------------------------------
- Baseline shots viewed:
  sandbox\ui_lab\shots\baseline\ekip.png, satis.png, olay.png (all 1920x1080).
- Shell geometry in those frames (VERIFIED):
  - TopBar 0..54 px high (GameShell.tscn MidRow offset_top=54).
  - NewsTicker is the bottom 34 px (GameShell.tscn:58).
  - LeftTabs is 84 px wide (LeftTabs.tscn:15).
  - So the office (CenterViewport, then OfficeView) sits at x=84, y=54, size 1836x992.
- The office pixels are the same in all three baseline frames (VERIFIED):
  office_hash=bd3e56ba9d0ff5bca7ba31aa52900373be5d7229 in every SHOT line.
  Evidence file: scratchpad\ui_lab\evidence\shots_base1.txt.
  The hash is the SHA1 of the raw bytes of the office SubViewport image, not of the PNG (ui_lab.gd:407-409).
- Colour-blind palette: every baseline SHOT line has cb=1 (shots_base1.txt).
  - The player's settings have the colour-blind palette ON, which is why the morale bars are blue.
  - This does not affect the 3D office or the busts (scene data, CLAUDE.md §7).
- Data source: main.gd `_seed_theme_surface` (main.gd:636-652). It sets:
  - seed 424242 (main.gd:449-452), week 14;
  - B2B saas_ops with mvp flags;
  - `_seed_hr_roster` (main.gd:1332-1372);
  - 3 customers through `_shot_customer` (main.gd:647-649, 1822-1846). All have cs=false, so no extra CS employee;
  - 2 prospects (main.gd:650-651).
- The payload is `_debug_payload` (main.gd:224-235): portrait "founder_01", company "Unicorn Inc.", empty founder_name.
- The event card is funding.frank_cheque (ui_lab.gd:19), rendered unscoped (ui_lab.gd:256).

---------------------------------------------------------------------
1. CLEAN OFFICE RENDER (OfficeView.tscn alone, no GameShell, no UI)
---------------------------------------------------------------------
1.1 What OfficeView is (VERIFIED, scenes\office\OfficeView.tscn)
- Root "OfficeView":
  - a Control, process_mode=3 (ALWAYS), group "office_view", full-rect anchors (lines 38-47);
  - script scripts\ui\office\office_view.gd.
- Viewport3D: a SubViewportContainer with stretch=true (49-56).
  Its SubViewport (58-63) has:
  - own_world_3d=true
  - gui_disable_input=true
  - msaa_3d=2 (4x)
  - screen_space_aa=1 (FXAA)
- World: Camera3D (office_camera.gd), WorldEnvironment, Sun, TopFill, lamps and screen lights, SceneRoot, Glows,
  InkPass (full-screen ink/vignette quad, 118-122), People (office_people.gd, 124-125), City (office_city.gd).
- Overlay (130-137) is a sibling of Viewport3D. It is drawn in the parent canvas, NOT inside the 3D SubViewport.
  - Children in the .tscn: NoticeStack (139-141), Tooltip (143-151, hidden by default).
  - Added at runtime:
    - OfficeTravel and MeetingInvite (office_view.gd:53-56);
    - OfficeHud, the "Ofisi taşı" button and the move toast (office_city.gd:107-111).
- The "Unicorn Inc. v1" panel at the top right of the baselines is BuildHUDPanel. It belongs to GameShell
  (GameShell.tscn ext_resource 6_buildhud), not to OfficeView, so it is absent automatically.

1.2 What OfficeView needs before it is instanced (VERIFIED)
- `_ready` calls `load_layout(OfficeSystem.current())` (office_view.gd:52). OfficeSystem.current() returns
  GameState.office_id (office_system.gd:9-10).
  -> Set GameState.office_id = "ishani" BEFORE instantiate(). ui_lab does this at ui_lab.gd:75; the debug
  path writes it directly.
- load_layout loads:
  - res://art/office3d/ishani.glb (office_view.gd:65)
  - res://art/office3d/ishani_nav.tres (office_view.gd:77)
  - the people (93), the meeting cast (94), the city (95)
- Lighting is applied every frame from TimeManager.day_minute() (office_view.gd:141-142). So:
  GameState.set_current_hour(11) (game_state.gd:339), then TimeManager.sync_to_current_hour()
  (time_manager.gd:209-210). day_minute() is then 660 (time_manager.gd:215-216).
- No dependency on GameShell or WindowLayer except on a click (office_view.gd:171) and a call_group
  (office_view.gd:182), which is harmless with no members. VERIFIED by grep:
  office_travel, meeting_invite, office_lighting, office_city and office_people only look up nodes inside the view.
- Proven sequence in sandbox\ui_lab\core\ui_lab.gd (_ready, lines 59-90):
  1. TimeManager.hold_clock("ui_lab")  (line 60)
     - Sets speed 0 (time_manager.gd:307-310), and speed 0 means get_tree().paused = true (time_manager.gd:302).
     - OfficeView is ALWAYS, so lighting and placement still run.
     - People get k=0 while paused, so they are frozen (office_people.gd:199-203).
  2. TranslationServer.set_locale("tr")  (71)
     - Not Localization.set_language, which writes the player's Settings.
  3. var seeder = load("res://scripts/main/main.gd").new(); seeder._seed_theme_surface(); seeder.free()  (72-74)
  4. GameState.office_id = "ishani"  (75)
  5. GameState.set_current_hour(11); TimeManager.sync_to_current_hour()  (76-77)
  6. Instance the scene (78). For the clean plate, instance OfficeView.tscn instead of GameShell.tscn.
- The seed also runs GameState.initialize_run (game_state.gd:881-884). That adds:
  - Frank (ensure_mentor);
  - the founder, whose look is stamped on add (character_registry.gd:448-449, 524-531);
  - CounterpartSystem.fill_investor_people (the investors' looks).

1.3 Waiting for people placement (VERIFIED)
- OfficePeople._placed (office_people.gd:63):
  - set false in set_layout (150-158, process disabled);
  - set true in _on_map_changed once the navigation floor is ready (674-685, process re-enabled, `_sync(true)`
    places everyone for the current minute).
- ui_lab's settle check, ui_lab.gd:340-358:
  - people placed;
  - >= 60 warm frames since mount (WARM_FRAMES=60, line 23);
  - >= 3 frames and 0.4 s since the last change;
  - no running tween;
  - bust studio idle.
  - _settle (320-337) also waits until the Control rects are stable for 3 consecutive frames, with a 10 s timeout (line 24).
- The game's own --office-shot (main.gd:678-760):
  - polls `while not people._placed: await get_tree().physics_frame` (main.gd:721-722, 739-740);
  - then 1.2 s plus 60 frames before saving (750-759).
- Recommendation for the office-only plate: wait for _placed, then about 60 process frames, then
  `await RenderingServer.frame_post_draw`, then read the image.
- Placement is deterministic: the README says the baseline is byte-identical across three runs
  (sandbox\ui_lab\README.md:109-112).

1.4 Camera fit (VERIFIED, office_camera.gd)
- Orthographic camera, 35 deg elevation, 45 deg yaw, FH=20 world units of frame height at zoom 1 (lines 10-12, 25).
- OfficeView._fit_once (office_view.gd:157-162) runs once, on the first non-zero container size:
  - it is connected to the container's `resized` with CONNECT_DEFERRED (office_view.gd:47-48), because the
    SubViewport resizes after the container;
  - camera.fit(layout.bounds, _lowest) (office_camera.gd:36-55): fit_zoom = min(FH*w/h / dx, FH / dy) * 0.9,
    with w and h taken from get_viewport().get_visible_rect(), i.e. the office SubViewport size;
  - camera.frame(layout.thumb_targets) (60-67): moves to the design's snapshot target and sets zoom =
    fit_zoom * framing.zoom.
  - For ishani the framing is target [10,0,7.5], zoom 2.1 (art\office3d\ishani.json "thumbTargets", read by
    office_layout.gd:83).
- Consequence (INFERRED):
  - Vertical world span is FH/zoom regardless of pixel height.
  - At full 1920x1080 the office appears about 1080/992 = 1.089x larger than in today's 1836x992 frame, and the
    horizontal crop also changes (aspect 1.778 vs 1.851).
  - To get today's exact office pixels, mount OfficeView as a 1836x992 Control at (84,54) inside a 1920x1080 stage.
  - Parity test: SHA1 of `office SubViewport.get_texture().get_image().get_data()` should equal
    bd3e56ba9d0ff5bca7ba31aa52900373be5d7229 (INFERRED, untested).

1.5 Hiding the office's own UI (VERIFIED structure, INFERRED effect)
- Best option, no hiding needed: read the inner 3D SubViewport texture
  (OfficeView/Viewport3D/SubViewport, the same node ui_lab hashes at ui_lab.gd:89, 407-409).
  Overlay is outside it, so NoticeStack, Tooltip, OfficeHud ("Ofisi taşı"), toast, invite and travel can never
  appear in it.
- If you read the stage or root texture instead: `office.get_node("Overlay").visible = false`. One switch hides
  all five Overlay children.
- The group route is incomplete: call_group("office_overlays","set_map_open",true) only hides the HUD's button
  row (office_hud.gd:73-74) and the NoticeStack (office_notice_stack.gd:39-40). It does not hide the HUD toast
  (office_hud.gd:57-62) or the Tooltip.
- Things that ARE part of the 3D world and will appear in the plate:
  - Sprite3D status icons over heads (office_actor.gd:10-20, 92-98; drawn per frame in decorate, 104-115,
    called from office_people.gd:218-224);
  - the founder floor ring (office_actor.gd:99, 106);
  - the select ring, only when someone is selected (107).
  Optional removal (INFERRED): after _placed, `people.set_process(false)` (the pattern at main.gd:742), then set
  each actor's `_icon.visible = false` and `_founder_ring.visible = false` (office_actor.gd:78-80). Note this
  departs from today's look.
- The InkPass vignette (office_ink.gdshader:16, default 0.22) is baked into the office image; busts set it to 0
  (person_bust.gd:86). It could be zeroed through the InkPass material_override parameter "vignette"
  (INFERRED; also a departure from today's look).
- assets\art\office\thumb_ishani.jpg (480x300) is NOT a Godot render: it is the design's web snapshot at 10:15
  (assets\art\office\README.md). Do not use it as the plate.

1.6 Reading the image
- Option A, robust, proven by ui_lab:
  - Own SubViewport "Stage", 1920x1080, render_target_update_mode=4 (ALWAYS), gui_disable_input=true, inside a
    SubViewportContainer (sandbox\ui_lab\UiLab.tscn).
  - Add OfficeView (full rect, or a 1836x992 child Control at (84,54)).
  - Read `office.get_node("Viewport3D/SubViewport").get_texture().get_image()`, or the Stage texture.
  - The window size does not matter (README.md:22-23, 96-97); the lab runs in a 1280x720 window.
- Option B, the game's own shot harness: root viewport.
  - window_set_mode(WINDOWED), then window size 1920x1080 (main.gd:416-421), then
    `get_viewport().get_texture().get_image().save_png()` (main.gd:477-480).
  - Depends on the real window size.
- Common to both:
  - `await RenderingServer.frame_post_draw` before get_image (ui_lab.gd:390-391).
  - Refuse a minimized window: Windows does not draw then (ui_lab.gd:387-389, README.md:22-23).
  - ui_lab also rejects a single-colour frame (ui_lab.gd:395-399).
  - Image.save_png accepts an absolute scratchpad path (INFERRED; the game saves to user://, ui_lab to res://).

---------------------------------------------------------------------
2. CHARACTER BUSTS AND PORTRAITS
---------------------------------------------------------------------
2.1 PersonBust (scripts\ui\office\person_bust.gd), VERIFIED
- API: `static func texture(look: Dictionary, px: int) -> ImageTexture` (35-46).
  - Returns null when the look is empty or the display is headless (36). Busts therefore need a WINDOWED run.
  - Cache key "signature@px" (38); the texture is created at n = px * SUPERSAMPLE (40-41), with SUPERSAMPLE = 2 (11).
  - It is an empty RGBA8 ImageTexture, filled later.
  - The studio is a static singleton `_studio` (23), added to root with call_deferred (43-45).
- Studio (_ready 49-89):
  - own-world SubViewport, transparent_bg=true, msaa_3d=4X, UPDATE_DISABLED (51-55);
  - orthographic camera, FRAME=0.5 m tall (14, 60-61);
  - noon lighting row NOON=780 (20, 64-76);
  - ink quad with vignette=0 and cutout=true (77-89);
  - process_mode ALWAYS (50), so it works while the tree is paused.
- Render (_process 92-94, _render 97-120), one portrait per frame:
  - viewport size = texture size (100);
  - OfficeBody.build(look) (101);
  - pose "ual1/Idle" at 0.4 s (18, 106-109);
  - camera aimed at the head bone minus HEAD_DROP 0.03, turned by TURN 0.42, raised by RISE 0.12 (14-17, 110-114);
  - await process_frame, then UPDATE_ONCE, then await frame_post_draw, then tex.set_image(viewport image) (115-118).
  - Done when `not _studio._busy and _studio._queue.is_empty()` (ui_lab.gd:355-357).
- Display path:
  - UiFactory.make_person_avatar(name, look, d) = make_avatar(initials, d, PersonBust.texture(look, d))
    (ui_factory.gd:102-103).
  - make_avatar: a Panel with variation "Avatar" (ui_factory.gd:108-123), a BG_AVATAR #1B232B disc with
    RADIUS_PILL (build_theme.gd:155, ui_tokens.gd:56).
  - make_bust: a TextureRect with LINEAR filter (127-141) and scenes\ui\components\avatar_bust.gdshader.
    The shader UN-PREMULTIPLIES (rgb / a, because "a transparent viewport's pixels carry their colour already
    multiplied by their alpha") and cuts an anti-aliased circle.
- Sizes used in the game today (VERIFIED):

  | Where | Size |
  |---|---|
  | Ekip ledger | 32 (hr_ledger.gd:80) |
  | Assignments | 30 (hr_assignments.gd:71) |
  | Dossier | 44 (hr_dossier.gd:71) |
  | Atlas candidate | 34 (hr_atlas_modal.gd:295) |
  | Training | 34 (training_modal.gd:59) |
  | Event speaker | 24 (event_modal.gd:252) |
  | Meeting panel | 96 portrait, 38 transcript (meeting_panel.gd:24-25) |
  | Term sheet lead | 64 (term_sheet_table_scene.gd:17, 305) |
  | founders sheet | 88 (office_crowd_probe.gd:18) |

  In-game renders are therefore 48 to 192 px square.

2.2 Can a 256-512 px bust be rendered and saved as PNG from an -s script?
- Yes in principle (INFERRED, untested). Call PersonBust.texture(look, 256) for a 512x512 render, or 512 for 1024x1024.
- Wait until the studio is idle and one frame_post_draw has passed, then tex.get_image().save_png(path).
- Caveats:
  - (a) The image is premultiplied. Un-premultiply on the CPU before saving (rgb /= a where a > 0, as
    avatar_bust.gdshader does). Otherwise the PNG shows dark fringes on any HTML background.
    The circle cut, if wanted, is the shader's job; or do it in CSS (border-radius:50%) over a #1B232B disc to
    match the "Avatar" look.
  - (b) The ink edge width is in pixels: office_ink.gdshader `texel = 1.15` (line 15). At 512-1024 px the lines
    are relatively much thinner than in the 48-64 px game renders (INFERRED from the shader).
    If parity with the in-game look matters, also render at the true in-game px and compare. Raising "texel" on
    the studio's ink material is possible but changes the look.
  - (c) Headless returns null (person_bust.gd:36), so the run must be windowed and not minimized.
- Existing in-repo example that renders busts next to portraits: OfficeCrowdProbe.founder_sheet()
  (office_crowd_probe.gd:228-242, used by --office-shot=...:founders, main.gd:732-733).

2.3 Which looks, after the seed (VERIFIED)
- Employees: ids char_emp_shot_0..4 (main.gd:1357). Names and roles (main.gd:1337-1353):

  | id | Name | Role | Note |
  |---|---|---|---|
  | char_emp_shot_0 | Elif Demir | product manager | |
  | char_emp_shot_1 | Deniz Arslan | designer | |
  | char_emp_shot_2 | Mert Yıldız | developer | sent on leave (main.gd:1370) |
  | char_emp_shot_3 | Selin Kaya | tester | |
  | char_emp_shot_4 | Burak Şahin | sales rep | hire_day = today, "YENİ" (main.gd:1372) |

  - Look: CharacterRegistry.get_character(id).look, stamped on add() from SalesConstants.mix(id, SALT_LOOK),
    kept apart from looks_around() (character_registry.gd:448-449, 524-531).
- Founder: CharacterRegistry.get_founder().
  - Look = LookSystem.founder("founder_01") (look_system.gd:103-105, character_registry.gd:526-527).
  - Name = tr("HR_ROLE_FOUNDER") = "Kurucu" in TR (game_state.gd:899-902, strings.csv:463). The locale and
    the CSV must be loaded before seeding.
- Investors: GameState.investor_people[vc_id] is an array of {role, name, look}: lead, partner, analyst
  (counterpart_system.gd:32-47, 64-81).
  - Filled in initialize_run (game_state.gd:884).
  - Active funds (investor_registry.gd:105-106 filters out locked): anchor (:20), nexus (:33), bosphorus (:46),
    meridian (:61). locked_tier2 (:75) is excluded.
  - So 12 investor looks. Names come from the run's name language.
- Frank: char_mentor_frank has NO look. ensure_mentor does not go through add(), so no stamp
  (character_registry.gd:396-408). He is drawn only from his painted portrait; no bust exists for him.

2.4 Frank's portrait and the founder portraits (VERIFIED)
- res://assets/art/investors/portrait_frank.webp is 1408x1760 px.
  - Size from the VP8X header (canvas 0x57F+1 by 0x6DF+1; `file` reports 1407+1x1759+1).
  - Path set at character_registry.gd:407.
  - Imported lossless (compress/mode=0), no mipmaps (portrait_frank.webp.import).
- Event modal use (event_modal.gd:247-263):
  - an Avatar Panel with default diameter 24 and clip_contents=true;
  - a TextureRect with STRETCH_KEEP_ASPECT_COVERED.
  - Observed in baseline\olay.png by pixel sampling: the 24x24 portrait (about x 598-621, y 597-621) is drawn
    SQUARE, with portrait pixels in its corners, even though the comment at event_modal.gd:244-246 says it is
    clipped round.
- Office notice stack: Frank's line uses an initials-only avatar, not the portrait
  (office_notice_stack.gd:59-60).
- Founder portraits: res://assets/art/founders/founder_01.webp .. founder_11.webp, all 1408x1760
  (`file` on each; ids in FounderConstants.PORTRAIT_IDS, founder_constants.gd:80-83; path helper :185-186).
  The seed uses founder_01.

---------------------------------------------------------------------
3. ICONS
---------------------------------------------------------------------
- Rail icons:
  - Files: assets\icons\tabs\{product,hr,finance,sales,marketing,rnd,personal,events,settings}.svg, wired in
    scenes\ui\components\LeftTabs.tscn:4-12.
  - Display: TextureRect 26x26, expand_mode=1, stretch_mode=5 (LeftTabs.tscn:53-58).
  - The SVGs are white-stroke Lucide icons (24x24 viewBox, stroke #ffffff, width 2, round caps/joins; e.g. hr.svg),
    imported at svg/scale=2.0 (hr.svg.import:41).
  - Tint comes from code via modulate (left_tabs.gd:104-105): active = ACCENT_DEEP #9A6A12, idle = INK_DIM #8A8175
    (ui_tokens.gd:97, 83). Settings icon is INK_DIM (left_tabs.gd:54). Locked tab alpha 0.45
    (left_tabs.gd:43, ui_tokens.gd:359).
  - License: assets\icons\tabs\LICENSE-lucide.txt (ISC, "Lucide Icons and Contributors", includes the Feather note).
- Other icon sets in the repo (VERIFIED file lists):
  - assets\icons\traits\: bag_packed, cant_say_no, double_checker, last_one_out, loyal, mood_buster,
    picks_it_up_fast, takes_them_under, unspecified. Used by the Ekip TRAIT column (hr_ui_shared.gd:18).
    White stroke, 28x28 viewBox. No license header.
  - assets\icons\product\: arrow, bubble, kind_feature, kind_fix, kind_polish, kind_research, role_design,
    role_dev, role_product, role_test, tick (sprint_ui_shared.gd:9). 20x20 viewBox, white stroke. No license header.
  - assets\icons\build\: decision, monitor, phase_support (bar_kit.gd:13).
  - assets\icons\ root: chevron_down/flat/right/up, clock, lock, revert_arrow, slider_grabber, switch_on,
    switch_off, warning.
  - assets\art\office\icons\: code, coffee, design, food, meeting, phone, research, test, wc. These are the 3D
    head-top status icons (office_actor.gd:10-20). 128x128: a Lucide glyph on a cream disc, with a comment citing
    Lucide ISC (e.g. code.svg line 2).
  - UNCERTAIN: provenance of the traits, product and build sets. They have no header and may be hand-drawn.
- Not icons, but local art the mockups may want: sandbox\ui_lab\themes\{dosya,evrak,gazete}\assets\*.png
  (tab, window, chip and stamp textures from the rejected directions).

---------------------------------------------------------------------
4. FONTS IN THE REPO (local files for the mockups)
---------------------------------------------------------------------
- Game master theme, each folder with OFL.txt:
  - assets\fonts\mono\JetBrainsMono-Regular.ttf, -Medium.ttf, -SemiBold.ttf
  - assets\fonts\sans\IBMPlexSans-Regular.ttf, -SemiBold.ttf
  - assets\fonts\serif\SourceSerif4-Regular.ttf, -Semibold.ttf, -It.ttf
  - assets\fonts\fallback\NotoSansSymbols2-Regular.ttf (the fallback on every role)
- Role variations (assets\fonts\variations\*.tres):

  | Role | File | Note |
  |---|---|---|
  | mono_reg | JetBrainsMono-Regular | |
  | mono_label | JetBrainsMono-Regular | spacing_glyph=1 |
  | mono_sb | JetBrainsMono-SemiBold | spacing_glyph=1 |
  | sans_reg | IBMPlexSans-Regular | |
  | sans_sb | IBMPlexSans-SemiBold | |
  | sans_it | IBMPlexSans-Regular | synthetic slant variation_transform (1,0,0.21,1); not a theme item |
  | serif_reg | SourceSerif4-Regular | |
  | serif_sb | SourceSerif4-Semibold | |
  | serif_it | SourceSerif4-It | |

- Sandbox direction fonts (sandbox\ui_lab\themes\<dir>\fonts\..., OFL.txt in each family folder):
  - dosya: IBMPlexMono-Regular/Medium/SemiBold.ttf; IBMPlexSans-VF.ttf, IBMPlexSans-Italic-VF.ttf;
    SpaceGrotesk-VF.ttf
  - evrak: IBMPlexMono-Regular/SemiBold.ttf; IBMPlexSans-VF.ttf; SourceSerif4-VF.ttf, SourceSerif4-Italic-VF.ttf
  - gazete: IBMPlexMono-Regular/SemiBold.ttf; LibreFranklin-VF.ttf; Newsreader-VF.ttf, Newsreader-Italic-VF.ttf
- Notes:
  - VF files need font-variation-settings / font-weight ranges in CSS.
  - Libre Franklin digits are proportional; IBM Plex Sans digits are equal width (README.md:309-311).
- No .otf or .woff anywhere in the repo, outside .godot (find).

---------------------------------------------------------------------
5. -s WINDOWED HARNESS TRAPS (repo plus memory notes)
---------------------------------------------------------------------
1. Compile-pass autoload trap.
   - The -s script compiles before autoload globals exist. An autoload name, a preload() of a game scene, or even
     a project class_name that pulls in autoload-using code kills the run with
     "Compile Error: Identifier not found: <Autoload>".
   - Sources: memory godot-mcp-runtime-verification.md ("-s script-mode, tur 2", trap 1, which names ProductSystem,
     a class_name, as a killer); sandbox\ui_lab\core\build_direction.gd:8-9; scratchpad\ui_lab\check.gd and
     keys_probe.gd headers.
   - Do everything at runtime: load(...), root.get_node("/root/GameState"), calls on loaded scripts
     (load("res://scripts/ui/office/person_bust.gd").texture(look, px), or .call("texture", ...)).
   - Proven alternative: load a normal scene or script at runtime. keys_probe.gd loads UiLab.tscn, whose script uses
     TimeManager and PersonBust freely.
   - UNCERTAIN: a worker .gd loaded by absolute path from the scratchpad should compile the same way, since -s
     itself accepts absolute paths (memory, -s round 1, point 2). Not separately verified.
2. Autoload _ready runs AFTER your _initialize, on the first frame (memory, round 1, point 1).
   - Defer the work with `_run.call_deferred()` then `await process_frame` (pattern in keys_probe.gd).
   - Localization loads the CSV in _ready (localization.gd:18-23), so seeding before that gives raw keys
     (for example the founder's name).
3. The window starts borderless fullscreen: project.godot:40 window/size/mode=3.
   - A size assignment is silently swallowed in that mode (main.gd:413-414).
   - Do DisplayServer.window_set_mode(WINDOW_MODE_WINDOWED) first, then set the size (main.gd:419-421; memory trap 2).
   - Or launch with `--windowed --resolution 1280x720`, as the ui_lab batch does (README.md:15).
   - Stretch is canvas_items with base 1920x1080 (project.godot:38-42).
4. Pass a flag containing "-shot", for example --mockup-shot=art, BEFORE any "--":
   - SaveManager._is_harness_arg matches "--" flags containing smoke, -shot, audit, probe or run-log
     (save_manager.gd:372-378).
   - It turns autosave off (save_manager.gd:55-57, which reads cmdline and user args).
   - DisplaySettings.is_inert() reads ONLY OS.get_cmdline_args() (display_settings.gd:84-92), so a flag after "--"
     would leave DisplaySettings managing the window.
   - CLAUDE.md §12 Tuzaklar: never put flags after "--". ui_lab refuses with exit 2 (ui_lab.gd:61-65).
   - run_godot.sh refuses a bare "--".
5. Hold the clock first: TimeManager.hold_clock("<reason>").
   - Without it the run autosaves into the player's slot after about 90 s (memory ui-lab-task-2026-09-30).
   - It also pauses the tree, which OfficeView, PersonBust and the people survive (sections 1.3 and 2.1).
6. Force the locale with TranslationServer.set_locale("tr") or `--lang=tr` (localization.gd:34-48).
   Never Localization.set_language, which writes Settings (memory trap 3; README.md:121-122).
7. Busts need a real display: headless returns null (person_bust.gd:36). Never minimize the window
   (ui_lab.gd:387-389).
8. Windowed runs go one at a time, never in parallel (CLAUDE.md §12 "Ekran kartı").
   - Every run opens the MCPRuntime autoload on TCP 7777 (log header in scratchpad\ui_lab\logs\render_gazete_s1.log).
   - An MCP editor session running at the same time loses its bridge (memory godot-theme-engine-facts.md:37).
9. User data lane:
   - The lab's windowed runs used the real APPDATA. Settings and saves were unchanged afterwards (memory: S-6 unchanged).
   - A separate APPDATA lane loses the player's settings: colour-blind and language defaults change. That is
     irrelevant to the 3D plate and busts, but use --lang=tr.
   - Write PNGs to absolute scratchpad paths, not user://.
10. Do not add a class_name in scratch scripts. If one is ever added in-repo, run `--headless --import` first
    (memory godot-import-cache-gotchas.md). `--check-only` does not see autoloads (memory weekly-time-model-task.md:17).
11. Wrapper scratchpad\ui_lab\run_godot.sh:
    - adds a process marker;
    - sets the APPDATA lane;
    - enforces a timeout;
    - scans the log for error lines;
    - runs a git-status guard (allow-list is the sandbox paths only).
    Reusable with UILAB_ALLOW set to empty or tightened, since the new script lives outside the repo.

---------------------------------------------------------------------
6. SKELETON OF THE THROWAWAY -s SCRIPT (INFERRED, untested; every step taken from the cited code)
---------------------------------------------------------------------
Run from the project directory:
  "$GODOT" --path . -s "C:/.../scratchpad/<dir>/mockup_art.gd" --mockup-shot=art --lang=tr --windowed --resolution 1280x720 --audio-driver Dummy

extends SceneTree
func _initialize() -> void:
    _run.call_deferred()
func _run() -> void:
    await process_frame                                   # autoload _ready done
    var tm := root.get_node("/root/TimeManager"); tm.hold_clock("mockup")
    TranslationServer.set_locale("tr")
    var seeder = load("res://scripts/main/main.gd").new(); seeder._seed_theme_surface(); seeder.free()
    var gs := root.get_node("/root/GameState"); gs.office_id = "ishani"; gs.set_current_hour(11); tm.sync_to_current_hour()
    # stage: SubViewportContainer > SubViewport(size 1920x1080, render_target_update_mode=4, gui_disable_input=true)
    # office = load("res://scenes/office/OfficeView.tscn").instantiate(); add under the stage
    #   (full rect, or a Control at (84,54) size (1836,992) for today's framing)
    # office.get_node("Overlay").visible = false   (optional when reading the inner SubViewport)
    # var people = office.get_node("Viewport3D/SubViewport/World/People"); while not people._placed: await process_frame
    # for i in 60: await process_frame; await RenderingServer.frame_post_draw
    # var img = office.get_node("Viewport3D/SubViewport").get_texture().get_image(); img.save_png(<abs path>)
    # parity: img.get_data() SHA1 == bd3e56ba9d0ff5bca7ba31aa52900373be5d7229 at 1836x992
    # busts: var PB = load("res://scripts/ui/office/person_bust.gd")
    #   looks: char_emp_shot_0..4 via /root/CharacterRegistry.get_character(id).look; get_founder().look;
    #   gs.investor_people[vc][i].look for anchor, nexus, bosphorus, meridian
    #   tex = PB.texture(look, 256); wait until PB._studio is idle, then frame_post_draw;
    #   im = tex.get_image(); un-premultiply rgb/a; im.save_png(...)
    #   (reading the static PB._studio through a Script reference is UNCERTAIN; fallback: poll until the
    #    texture image is non-transparent, or move this into a runtime-loaded worker Node script)
    # Frank: copy res://assets/art/investors/portrait_frank.webp (1408x1760) directly; there is no bust
    quit(0)
```