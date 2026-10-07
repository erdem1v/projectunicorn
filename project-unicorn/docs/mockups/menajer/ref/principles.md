# UI research: principles and process for data-dense game UI

Area: expert principles, studio processes, typography, colour systems, hierarchy/density, visual identity; plus startup/finance software aesthetics.
Date of research: 2026-10-01. Written for Project Unicorn (Godot 4, 1920x1080 base, cream-paper windows over a live isometric 3D office).

Method: every fact below comes from a page that was actually opened (WebFetch, curl of the Steam news API, or Chrome page text), unless tagged
**[snippet only]** (seen only in a search-engine summary because the page blocked access) or **[unverified]**. Quotes are short and attributed.
Blocked / not read: Bloomberg's own UX articles (CAPTCHA wall; I did not bypass it), GDC Vault video content (YouTube transcripts would not load),
ArtStation (Cloudflare). Where I lean on those, it is marked.

---

## 0. What the current Project Unicorn UI is doing (measured, for context)

Measured from `sandbox/ui_lab/shots/baseline/ekip.png` with a pixel script (darkest ink pixel vs dominant background; WCAG formula), and from
`scripts/theme/ui_tokens.gd` / `assets/fonts/`:

- Families in use: JetBrains Mono (Regular/Medium/SemiBold) for nearly all labels and numbers, IBM Plex Sans for names/buttons, Source Serif 4 for window titles and event prose.
- Size ladder: `SIZE_MICRO 9 · META 10 · SMALL 11 · DATA 12 · BODY 13 · LEAD 15 · TITLE 16 · DISPLAY 22` at a 1920x1080 canvas_items base.
- Top-bar labels ("KASA", "MRR"...): contrast about **2.4:1**, glyphs about 8 px tall. Top-bar values: 16.9:1, about 16 px.
- Table column headers, role captions ("UX/UI DESİGNER"), skill labels: about **3.5 to 3.6:1** contrast, 8 to 10 px glyph height, all caps, letter-spaced mono.
- Names and salaries: 13.9:1.
- Against Xbox Accessibility Guideline 101/102 (below): PC minimum text body height is 18 px at 1080p, and standard text needs 4.5:1. So every
  label tier in the current UI is under the size floor, and the whole "meta label" tier is under the contrast floor. This is one concrete reason the
  UI reads as "default/characterless": the personality is carried by tiny grey letter-spaced mono caps that can barely be read.
- Structural observations: every row and card is boxed with a border, inside a bordered window; the Satış page shows five bright-yellow primary
  buttons at once; the event modal is a plain card with no image, no portrait scale, and no sense of place.

---

## 1. Game studios: what they said about their own UI

### 1.1 Victoria 3 (Paradox Development Studio): UX pillars (DD #29) + UI art pillars (DD #30)
Sources (full text pulled from the Steam news API because the Paradox forum blocks scripted fetches):
- Dev Diary #29 "User Experience", 2022-01-13, Henrik (UX Designer) and Aron. https://store.steampowered.com/news/app/529340 (gid 4224939931828485137); forum original https://forum.paradoxplaza.com/forum/developer-diary/ (thread "Victoria 3 - Dev Diary #29")
- Dev Diary #30 "User Interface Overview", 2022-01-20, Kenneth (2D Art Lead). https://store.steampowered.com/news/app/529340/view/3118180956264055546 ; forum https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/
- Dev Diary #74 "UX Improvements", 2023-02-08, Henrik. https://www.paradoxinteractive.com/games/victoria-3/news/dev-diary-74-ux-improvements

Facts:
- Goal statement: make the game "more approachable and accessible, so that we can make it even deeper". Complexity should come from simulation, not from "not knowing where to find something" (DD29).
- **Three UX pillars** (DD29): (1) The right information at the right time; (2) Clear feedback about cause and effect; (3) Clearly separate Actions from Information.
- Tools named: nested tooltips (from CK3) for game concepts and number breakdowns, with configurable lock mode (mouse tendency / timer / action lock); line graphs for "value over time" (pie charts optional); **real-time predictions** (e.g. predicted weekly balance when changing a production method, shown before you commit); map modes tied to panels; five "Lenses"; right-click context menus on entities; **designed empty states** that say what could be here and how to get it; colourblind text modes (DD29).
- **Three art pillars** (DD30): *Prestigious*; *Vintage and Idyllic*; *Detailed yet Approachable* ("High level of detail with intricate elements but used sparingly").
- Material rules (DD30): Art Nouveau ornament is concentrated on **frames, borders and headers only**, because too much pattern "will distract the main function of an UI: which is to display information". Panels = ornate frame + "faded fabric textures" + a touch of gold. Buttons = wood texture, **emerald in two shades**: one for Navigation buttons, one for Action buttons; action buttons add a thin gold border; a higher-priority button gets extra ornament at its corners.
- Icon tiers (DD30): goods/buildings = detailed mini-illustrations; events/tech = realistic objects; mechanics/stats icons that appear small = reduced detail, "a few choice colours and the silhouettes"; positive/negative condition icons coloured green/red.
- Infographics/tutorial art: borrowed Victorian **newspaper and blueprint illustration** style, drawn over aged paper (DD30).
- Post-launch (DD74): a Message Settings window let players choose which notifications show and which auto-pause; Henrik: the changes should "reduce the number of Notifications by roughly 50%". Tooltip positioning was reworked so moving into a nested tooltip does not open another one. A popular community mod ("Visual Methods") was folded into the base game.

Images (Steam clan CDN, verified 200):
- UI panel frame: https://clan.akamai.steamstatic.com/images/40579353/b8da1452f6378490650ddd090fe3639691538c46.png
- Navigation vs Action buttons: https://clan.akamai.steamstatic.com/images/40579353/6271fed92b1204691b676adde1615182dc878834.png
- Infographic on aged paper: https://clan.akamai.steamstatic.com/images/40579353/5122832498d0b8f95d805ad70bc40da51ce973d4.png
- Nested tooltip: https://clan.akamai.steamstatic.com/images/40579353/f2a14e9914a7d189ed3485ecb24188af78de623b.png
- Graphs: https://clan.akamai.steamstatic.com/images/40579353/0b5938dbf9175b540e8ddc85b0b9ba7a5cd7c8e2.png
- Building panel with predictions: https://clan.akamai.steamstatic.com/images/40579353/73e78e5d32ed23b3cf98f8b6a5c74285eb4b4747.png
- Empty state: https://clan.akamai.steamstatic.com/images/40579353/5223d4e1a25e6e49adec61975ccc10fdcc336fd6.png

Relevance: this is the closest documented precedent for "a theme-true material UI that still carries spreadsheets". The rule that matters: the
period material lives in the **frame and header**, never inside the data field; data fields stay flat and quiet. Also: action vs navigation buttons get
two distinct treatments; predictions before commit; empty states are designed.

### 1.2 Crusader Kings III (Paradox): Art Focus (DD #28) + nested tooltips (DD #16)
Sources (read in Chrome):
- CKIII Dev Diary #28 "Art Focus", 2020-05-26, written by Pontus (Art Director), posted by Joacim (Art Lead). https://forum.paradoxplaza.com/forum/threads/ckiii-dev-diary-28-art-focus.1393627/
- CK3 Dev Diary #16 "Tutorials and Tooltips and Encyclopedias, Oh My!", written by Matthew (programmer). https://forum.paradoxplaza.com/forum/threads/ck3-dev-diary-16-tutorials-and-tooltips-and-encyclopedias-oh-my.1345581/
- PCGamesN on V3 adopting it: https://www.pcgamesn.com/victoria-3/nested-tooltip-system

Facts:
- Art direction starts from **game design pillars**: CK3's UI took its cue from the "character focus" pillar and pulled visual influence from RPGs; "To make it approachable we tried to keep it clean, and give everything some breathing room." UI is "constantly iterated upon and is one of the most challenging aspects of our games" (DD28).
- Heavy use of **illustration inside UI**, with context-sensitive backgrounds (a Sultan is not shown in a western European throne room; Religion view shows imagery for the faith in question) (DD28).
- Events can be presented as **letters** (image DD28_letter.jpg in the diary).
- "Tooltips in Tooltips": any blue highlighted game concept can be hovered for an explanation, recursively; two lock modes, timer lock (default) and action lock (DD16).

Images (verified 200): character screen https://forumcontent.paradoxplaza.com/public/569145/DD28_Character_Screen.png ;
letter event https://forumcontent.paradoxplaza.com/public/569148/DD28_letter.jpg ; event art https://forumcontent.paradoxplaza.com/public/569126/DD28_events_01.jpg

Relevance: character portraits and context illustrations are what give CK3 panels "place". Our event modal and meeting flows have a real cast
(Frank, VC partners, customers) and a real place (the office, meeting rooms), but the modal shows a 24 px portrait and no scene.

### 1.3 Into the Breach (Subset Games): clarity as a design constraint
Sources:
- Game Developer, "Into the Breach dev on UI design: 'Sacrifice cool ideas for the sake of clarity every time'" https://www.gamedeveloper.com/design/-i-into-the-breach-i-dev-on-ui-design-sacrifice-cool-ideas-for-the-sake-of-clarity-every-time-
- GDC Vault, "'Into the Breach' Design Postmortem" (Matthew Davis, GDC 2019) https://www.gdcvault.com/play/1025772/-Into-the-Breach-Design (video not transcribed; facts via the article and search summaries)

Facts:
- Justin Ma: "As a game design principle, we would sacrifice cool ideas for the sake of clarity every time." Weapons and firing patterns that playtesters could not read were cut.
- The key fix was **animated tooltips** that show a weapon acting, which Ma called "the most important decision we made about this".
- [snippet only] Small, meaningful board-game-like numbers where a change of 1 is impactful; enemies telegraph their attacks.

Images (Interface In Game, verified 200): https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-combat.png ;
https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-enemy-turn.png ; https://interfaceingame.com/wp-content/uploads/into-the-breach/into-the-breach-head-office.png

Relevance: for a management sim, the equivalent of "enemy telegraph" is showing the consequence of a choice before it is made (event choice chips,
hiring cost on burn/runway). Our effect chips exist; the lesson is to make them the loudest thing on the card, not a 9 px badge.

### 1.4 Football Manager 26 (Sports Interactive): a cautionary redesign
Sources:
- SI feature: "Total Football, Total Control: FM26's Reimagined User Interface" https://www.footballmanager.com/fm26/features/fm26s-reimagined-user-interface
- Operation Sports breakdown https://www.operationsports.com/sports-interactive-breaks-down-the-football-manager-26-ui-overhaul/
- Thick Accent, "Maze of Screens" (2025-10-24) https://www.thickaccent.com/2025/10/24/maze-of-screens-fm26-beta-sparks-backlash-over-controversial-new-ui/
- [snippet only] Galaxus review "Football Manager 26 is floundering in an interface labyrinth" https://www.galaxus.at/en/page/football-manager-26-is-floundering-in-an-interface-labyrinth-40507

Facts:
- SI's stated goals: Efficiency (fewer clicks), Familiarity, Predictability. New "Tile and Card" system powers every screen: tiles are snapshots that open into cards. Home + Inbox merged into a "Portal" with filters All/New/Tasks/Unread. Top nav bar replaced the left panel; bookmarks (6 default, 24 total per SI page). SI also says it corrected "unreadable font sizes" and defined colour contrasts. Analytics showed the old Home screen was little used.
- Beta reception (Thick Accent): blurry/truncated text; "designed like a cheap mobile game"; more clicks than before; the player search lost at-a-glance nationality/star rating; one player: "I feel like I'm in a maze of screens". Miles Jacobson (via Forbes, as reported) cited 430 bugs before launch.
- [snippet only] Galaxus: information that was once visible at a glance now sits two or three levels deep; tiles "waste screen real estate".

Images (verified 200): https://cdn.footballmanager.com/site/inline-images/2%20Portal%20Example_opt.jpg ;
https://cdn.footballmanager.com/site/2025-09/UI%20Feature%20-%2016x9%20watermarked_1.jpg ; https://cdn.footballmanager.com/site/inline-images/1%20Mitoma_opt.jpg

Relevance: the most-played data-dense management game lost goodwill by converting dense tables into roomy tiles/cards. Density in the
**primary** table must be kept; "cleaner" must not mean "one more click". Our Satış page is already card-per-customer; the Ekip roster is a table.
FM26 argues for keeping the roster as a real dense table and not cardifying it.

### 1.5 Persona 5 (Atlus): how a studio builds a UI identity
Source: Persona Central report of the CEDEC+KYUSHU 2017 panel "Creative method for UI in the Persona series" (Masayoshi Sutoh, Art Director and lead UI designer; Kazuhisa Wada, producer), 2017-11-13, via Famitsu. https://personacentral.com/persona-5-panel-concept-development-ui/ (read in Chrome)
Also: Edd Coates on Persona 5 (80.lv) https://80.lv/articles/game-ui-database-collecting-references-to-inspire-designers

Facts:
- Origin: during Persona 3, Atlus was told its games "are interesting, but they do not sell"; one response was to turn the UI from an "unsung hero" into a "strong assertive hero", which also improved UX at low cost.
- **Order of decisions**: the main colour is decided first (P3 blue, P4 yellow, P5 red, Catherine shocking pink), then the title logo, then the "key font", then the sub-colour. P5 deliberately avoided sub-colours so red would dominate; except HP/MP numbers the UI "hardly adopted sub-colors".
- Concept: "pop punk" (pop = mass oriented, punk = anti-establishment).
- Legibility techniques without colour: a white line drawn through the centre of the menu to guide the eye ("line of sight"); layout angles change with depth; **lighting varies with priority**: high-priority areas are lit brighter, low-priority areas dimmer.
- Tools unchanged for 18 years: Photoshop, Illustrator, After Effects; layout in Photoshop first, then motion.
- Sutoh sees the UI's mission as "creating the package for the title".
- Edd Coates: Persona 5 shows how UI can "hijack the visual style of a game and artistically transform it".

Images (Steam, P5 Royal, verified list from store API): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1687950/ss_663171dc3afce8fe987e57e8659f91b69faa39bc.1920x1080.jpg ;
https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1687950/ss_a3258aba84ae2f2ff13a02a160f7495bfc152adb.1920x1080.jpg

Relevance: the actionable part is the **decision order** (one owned colour, then wordmark, then one key font, then at most one sub-colour),
and "brightness = priority". Our current palette has amber, yellow, blue, cyan, green, red and cream all speaking at once.

### 1.6 Hearthstone (Blizzard): material UI done on purpose
Sources:
- GDC Vault session "Hearthstone: How to Create an Immersive User Interface", Derek Sakamoto, GDC 2015 https://gdcvault.com/play/1022036/Hearthstone-How-to-Create-an ; Game Developer: https://www.gamedeveloper.com/design/video-designing-an-immersive-user-interface-for-i-hearthstone-i- ("our game is UI")
- Matthew Tsui, "Hearthstone Design: Thinking Inside the Box" (2016-08-16) https://medium.com/@matt.tsui/hearthstone-design-thinking-inside-the-box-78dbacb96040 (read in Chrome)
- Jason Perry, "On Hearthstone's UI" (2014-09-14) https://finalbossblues.com/on-hearthstones-ui/

Facts:
- Sakamoto: "our game is UI"; the talk shows designs being made, scrapped and remade in pre-alpha.
- The menu is a physical box that opens; each animation "has a deliberate impact"; every element fits the tavern theme (Tsui).
- Tsui reports Sakamoto explaining a navigation trade-off as "flavor over efficiency", and criticises that choice where it costs clicks.
- Perry: "The biggest success of Hearthstone's interface is how it feels SOLID and REAL"; cards cast shadows, big minions crack the board, each card has sound. He writes that Hearthstone made him question the idea that interfaces should be invisible.
- [snippet only, unverified] the 7-minion board limit followed from the physical board's size.

Images (Interface In Game, verified pattern): https://interfaceingame.com/wp-content/uploads/hearthstone-heroes-of-warcraft/hearthstone-heroes-of-warcraft-main-menu.jpg ;
https://interfaceingame.com/wp-content/uploads/hearthstone-heroes-of-warcraft/hearthstone-heroes-of-warcraft-my-decks.jpg

Relevance: "material" works when it is backed by **motion, sound and physical response**, and when the object is the place of play. Static textures
alone (paper colour, folder tabs) do not create materiality. This probably explains why the three paper-folder variants read as costume, not material.

### 1.7 Papers, Please (Lucas Pope): diegetic desk because paper IS the mechanic
Source: Lucas Pope's TIGSource devlog archive, Nov 2012 https://dukope.com/devlogs/papers-please/tig-00/ (plus later months tig-01, tig-02, tig-10 at the same site)

Facts:
- Resolution moved from 16:9 to 3:2 (960x640) for more room in the inspection area.
- First plan was click-to-view with documents at most 150x215 px and two visible at once; Pope found it "a bit lifeless" and switched to full drag and drop, "much more like actually inspecting a pile of papers".
- Teletext results, audio transcript and rulebook "behave just like documents" for consistency.
- Bitmap fonts instead of TTF to avoid anti-aliasing; about 3 shades per object; Pope: "I'll take a limited resolution, palette, or game mechanic over unlimited freedom any day."

Images: devlog mock by Eigen http://eigen.pri.ee/images/paperspleaselayout.png (verified 200); devlog imgur https://i.imgur.com/BhXlv19.png (verified 200, content not checked);
Steam: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/239030/ss_4cd77e3ef5b147b011a5cf8f96b8bcbcd79b3e15.1920x1080.jpg

Relevance: the paper metaphor works in Papers, Please because the player literally handles and compares documents; the documents are the
verbs. In Project Unicorn the player reads rosters and pipelines; wrapping them in folders adds a costume but no verb. That matches Erdem's rejection.

### 1.8 Frostpunk 2 (11 bit studios): a cautionary material/colour choice
Sources:
- PCGamesN, "The Frostpunk 2 dev is making some huge changes after player feedback" (2024-07-22) https://www.pcgamesn.com/frostpunk-2/ui-improvements
- New Game Network, "Frostpunk 2 Review" https://www.newgamenetwork.com/article/2813/frostpunk-2-review/ (read in Chrome)

Facts:
- After the beta, 11 bit delayed the game and reworked the HUD ("clearer and more intuitive"), construction menu, and the Idea Tree for "clarity, readability, and look and feel". Studio quote: players "want the interface to be as user-friendly as possible".
- Review: bottom menu with "small icons grouped too closely"; "the entire UI has a white tint to it, which is not exactly a good contrast with the endless snow of the game's world".

Images (Steam, verified list): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1601580/5fcef70d6bc626f4c0cfc74826c3a27125bd1376/ss_5fcef70d6bc626f4c0cfc74826c3a27125bd1376.1920x1080.jpg
Frostpunk 1 screens (for contrast): https://interfaceingame.com/wp-content/uploads/frostpunk/frostpunk-book-of-laws.jpg ; https://interfaceingame.com/wp-content/uploads/frostpunk/frostpunk-heating.jpg

Relevance: the UI surface colour must be chosen **against the world behind it**. Our office is warm (cream walls, orange brick, warm wood).
Cream windows over a cream/orange scene lose figure-ground in the same way the white UI lost it against snow.

### 1.9 Hades (Supergiant): light note
Source: MCV/Develop "Behind the art of Hades" https://mcvuk.com/business-news/behind-the-art-of-hades-we-value-artistic-integrity-and-excellence-in-artistic-craft-at-supergiant-however-were-first-and-foremost-a-game-design-lead-team/
- Jen Zee: "we're first and foremost a game design-led team"; art ideas are "disposable until the gameplay and narrative harden up". Josh Barnett did FX, UI design and animation; 194 boon icons shipped.
- I found no primary source on Hades UI typography or colour rules; treat any claim about them as unverified.
Images: https://interfaceingame.com/wp-content/uploads/hades/hades-boons-of-aphrodite.jpg

---

## 2. Principles from UI/UX experts

### 2.1 Xbox Accessibility Guidelines 101 (text) and 102 (contrast), Microsoft
- XAG 101 https://learn.microsoft.com/en-us/xbox/accessibility/xbox-accessibility-guidelines/101
- XAG 102 https://learn.microsoft.com/en-us/gaming/accessibility/xbox-accessibility-guidelines/102
Facts:
- Size is measured as **body height** (highest ascender to lowest descender, pixels with >2:1 contrast count).
- Minimum default sizes: Console 26 px at 1080p (52 at 4K); **PC/VR 18 px at 1080p** (36 at 4K). Text scaling to 200% without losing content.
- Include at least one sans-serif option; sentence case for lines of text (1-2 word labels exempt); line spacing at least 1.5 in text blocks; line width at most 80 characters.
- Contrast: standard text and important visual elements **4.5:1**; large text (PC: 36 px at 1080p) 3:1; inactive-element text 3:1; high-contrast mode 7:1; do not rely on colour alone; text over non-solid backgrounds is measured at the lowest-contrast spot.
- Related: Fire TV guidance cited by Christopher Koerner, 28 px minimum at 1080p for TV, "a minimum rather than a target" https://clkoerner.com/2019/08/02/small-type-in-a-big-game/

### 2.2 Butterick's Practical Typography (numbers, tables, mono, caps)
- Alternate figures https://practicaltypography.com/alternate-figures.html ; Grids of numbers https://practicaltypography.com/grids-of-numbers.html ; Tables https://practicaltypography.com/tables.html ; Monospaced fonts https://practicaltypography.com/monospaced-fonts.html ; All caps https://practicaltypography.com/all-caps.html
Facts:
- Tabular figures are fixed width and are "essential" for vertically aligned columns; proportional figures are better in running text; lining figures suit grids.
- "In any column, digits with the same meaning must be vertically aligned"; quantities with units align right; add leading zero below 1.
- Tables: "Turn off all the cell borders to start, and then turn them back on as needed"; increasing cell margins is "the best way to improve the legibility of a dense table"; vertical padding can exceed side padding.
- Mono: "Compared to proportional fonts, monospaced fonts are harder to read"; legitimate uses are code and aligning numbers (which most proportional fonts can do with tabular figures).
- All caps only for short labels/headings; "Always add letterspacing to caps".
- Godot side: tabular figures are enabled per `FontVariation` through `opentype_features` (e.g. `tnum`) or in import metadata overrides. https://docs.godotengine.org/en/stable/tutorials/ui/gui_using_fonts.html ; https://docs.godotengine.org/en/stable/classes/class_fontvariation.html
  (Project memory already records a Godot trap: opentype tags must be INT-encoded in `variation_opentype`.)
  The same Godot page warns MSDF is "not as clear" as rasterized fonts at small sizes due to lack of hinting.

### 2.3 Refactoring UI (Adam Wathan & Steve Schoger), "7 Practical Tips for Cheating at Design", 2018-02-20
https://medium.com/refactoring-ui/7-practical-tips-for-cheating-at-design-40c736799886 (read in Chrome)
- Hierarchy by **weight and colour, not size**: two or three text colours (dark, grey, lighter grey), two weights (400/500 and 600/700); avoid weights under 400 in UI.
- Do not put grey text on coloured backgrounds; use a same-hue colour or reduced-opacity white.
- Offset shadows vertically (light from above).
- **Use fewer borders**: separate with shadow, two background tones, or spacing.
- Do not blow up small icons; enclose them in a shape.
- Accent borders (a coloured edge on an alert, active nav, or top of layout) add identity cheaply.
- Button **hierarchy over semantics**: one primary (solid, high contrast), secondary (outline/low contrast), tertiary (link style). Destructive actions are not automatically red.

### 2.4 Celia Hodent (The Gamer's Brain; ex Epic UX director)
- https://celiahodent.com/video-game-ux-psychology/ (GDC 2015 material); summary of her usability heuristics: https://medium.com/design-bootcamp/finding-a-framework-for-ux-in-gaming-key-takeaways-for-understanding-usability-in-celia-hodents-9c0fcfee85f7
- Framework: perception, memory, attention. Gestalt proximity/similarity for grouping; "form follows function"; reduce memory load with persistent contextual info; "multitasking is a myth"; clutter dilutes critical signals (overused red weakens real alerts).
- Quote: "The workload in your game must be dedicated to the core experience you want to offer, not in figuring out menus".
- Named usability principles (per the Medium summary of her book): signs and feedback, clarity, form follows function, consistency, minimum workload, error prevention and recovery, flexibility and accessibility.

### 2.5 Steph Chow, "Immersing a Creative World into a Usable UI" (GDC 2018) and her written version
- GDC Vault https://gdcvault.com/play/1025340/Immersing-a-Creative-World-into ; Game Developer https://www.gamedeveloper.com/design/video-designing-great-ui-that-helps-immerse-players-in-your-game ; article https://www.linkedin.com/pulse/creating-functional-ui-embodies-your-games-world-steph-chow
- Process: 1 research the world (colours, shapes, textures, mood, architecture, cultural references); 2 scout competitors and analyse why; 3 wireframe with real content; 4 explore and sketch (about half the exploration time on research and mood boards); 5 execute visual direction (skeuomorphic or flat); 6 polish; 7 playtest and iterate.
- Rule: "The UI should feel of the game's world, but should not distract nor compete with it."

### 2.6 Diegetic / spatial / meta / non-diegetic (Fagerholt & Lorentzon, Chalmers, with EA DICE, 2009)
- "Beyond the HUD" https://odr.chalmers.se/server/api/core/bitstreams/fd267f70-c295-4eae-ae01-af5db676e61d/content ; https://www.researchgate.net/publication/277202228_Beyond_the_HUD_-_User_Interfaces_for_Increased_Player_Immersion_in_FPS_Games
- Two axes: is the element in the fiction? is it in the 3D space? This gives four classes: diegetic, spatial, meta, non-diegetic.
- Useful vocabulary: our office scene can carry **spatial** UI (labels, status over desks, meeting-room lights) and **diegetic** UI (whiteboard, screens) while dense data stays non-diegetic.

### 2.7 Edward Tufte, sparklines and data-ink
https://www.edwardtufte.com/notebook/sparkline-theory-and-practice-edward-tufte/
- Sparkline: "a small intense, simple, word-sized graphic with typographic resolution"; they belong "everywhere a word or number can be", beside the number, not in a boxed chart.
- "Background colors, frames and boxes don't add much. Avoid all data frames; the physical location of the numbers, words, and graphics enforces the implicit grid."

### 2.8 Colour-scale systems: Radix Colors; density: IBM Carbon
- Radix "Understanding the scale" https://www.radix-ui.com/colors/docs/palette-composition/understanding-the-scale : 12 steps per hue with fixed jobs. 1-2 app/subtle backgrounds; 3-5 component backgrounds (normal/hover/active); 6-8 borders (subtle, interactive, hover); 9-10 solid fills (9 is the purest chroma); 11-12 low- and high-contrast text.
- IBM Carbon data table https://carbondesignsystem.com/components/data-table/style/ : row heights xs 24, sm 32, md 40, lg 48, xl 64 px; column header 14 px SemiBold; row text 14 px Regular; optional zebra rows.

### 2.9 Game UI Database (Edd Coates) on research
https://80.lv/articles/game-ui-database-collecting-references-to-inspire-designers (2022-11-17)
- "There isn't always enough time to conduct proper research ... UI/UX mistakes are often made early in development, simply from a lack of useful data."
- Contrasts Persona 5 (UI as style statement) with Breath of the Wild ("transparent panels and a minimalist aesthetic" that let the world lead).

### 2.10 General strategy-game UI rules (Josh Bycer, Game Developer, 2015)
https://www.gamedeveloper.com/design/ui-strategy-game-design-dos-and-don-ts
- Centralise commands/info; hotkeys for nearly everything and show them in the UI; notify important events; do not let critical events happen off-screen; allow information depth to be adjusted.

---

## 3. Startup / finance software aesthetics

### 3.1 Linear
- "How we redesigned the Linear UI (part II)" https://linear.app/now/how-we-redesigned-the-linear-ui
- "A calmer interface for a product in motion" (2026-03-12, Charlie Aufmann, Maxime Heckel) https://linear.app/now/behind-the-latest-design-refresh ; changelog https://linear.app/changelog/2026-03-12-ui-refresh
Facts:
- 2024 redesign: goal "reduce visual noise, maintain visual alignment, and increase the hierarchy and density of navigation elements"; focus on the inverted-L chrome; themes moved from HSL to **LCH** and are generated from **3 variables (base colour, accent colour, contrast)**; the contrast variable yields high-contrast themes; less blue in chrome for "a more neutral and timeless appearance"; Inter Display for headings, Inter for body. 6 weeks kickoff to GA; hundreds of exploration screens; daily designer-engineer pairing; feature flag and private beta.
- 2026 refresh: "Don't compete for attention you haven't earned"; sidebar dimmed "a few notches" so content leads; smaller, fewer icons; removed coloured team-icon backgrounds; borders rounded and softened: "Structure should be felt not seen"; palette moved from cool blue-grey to a **warmer grey**; an internal LCH colour picker and a Figma plugin syncing values as JSON; prototypes behind feature flags for A/B comparison.
Images: https://webassets.linear.app/images/ornj730p/production/23839a6bacba4a7617728dada3d37a40dc3584aa-2352x1380.png (from the 2024 post; caption not captured)

### 3.2 Stripe: accessible colour system (Daryl Koopersmith, Wilson Miner, 2019)
https://stripe.com/blog/accessible-color-systems
- Audit: none of the default small-text colours except black met 4.5:1.
- Built a custom tool on **CIELAB** (perceptually uniform lightness); every hue follows the same lightness curve, so levels mean the same contrast across hues.
- Rule: "Any two colors are guaranteed to have sufficient contrast for small text if they are at least five levels apart, and at least four levels apart for icons and large text."
- Badges were redesigned onto tinted backgrounds using the same rule.
Images: https://images.stripeassets.com/fzn2n1nzq965/3ZPP6fI931onmKlwC7w373/c3a945f27ab6743d2fa2ca0563822729/uniform-contrast-values-text.png ;
https://images.stripeassets.com/fzn2n1nzq965/6adtkO2ouMiAMZRjBusR2C/5d6f76d0a5f8dac0a908bff95d7e63bc/badges.png ;
https://images.stripeassets.com/fzn2n1nzq965/5dAcbhS0qlqMFJdjyxbj6k/4fa90be503e5ae8adb0607491772a0fd/perceptually-uniform-color-space.png

### 3.3 Bloomberg Terminal
- Digital Content Next, "Bloomberg's customer-centric design ethos" (2017-05-15) https://digitalcontentnext.org/blog/2017/05/15/bloombergs-customer-centric-design-ethos/
- Ted Merz, "Amber on Black" (2021-06-26) https://ted-merz.com/2021/06/26/amber-on-black/
- UX Magazine, "The Impossible Bloomberg Makeover" (2010) https://uxmag.com/articles/the-impossible-bloomberg-makeover
- [snippet only; page behind CAPTCHA] "How Bloomberg Terminal UX designers conceal complexity" https://www.bloomberg.com/company/stories/how-bloomberg-terminal-ux-designers-conceal-complexity/ ; "Designing the Terminal for color accessibility" https://www.bloomberg.com/ux/2021/10/14/designing-the-terminal-for-color-accessibility/
Facts:
- Ali Jeffery: "Amber is our base font color"; "You can see it across the trading floor. You know which application is Bloomberg." Yellow keys on the keyboard are part of the identity. Mike Mallon: accessibility for power users "may sometimes lead to screens that look complicated". Customers test designs in a UX lab before build.
- Merz: amber on black came from 1980s monochrome monitors; Mike Bloomberg kept it as a brand.
- [snippet only] A 9x19 monospaced bitmap font was copied pixel by pixel from the original hardware in the late 1990s; a later font change drew "thousands of client messages" ("You changed perfection"). Bloomberg ships alternate schemes for deuteranopia and protanomaly because red/green carry down/up.
Images (Wikimedia Commons): https://upload.wikimedia.org/wikipedia/commons/d/d8/Bloomberg_Terminal.jpg ; https://upload.wikimedia.org/wikipedia/commons/c/c7/2012_Bloomberg_Terminal_by_jm3_-_Creative_Commons_licensed.jpg

### 3.4 Robinhood (two identities; do not conflate)
- 2020 (COLLINS): Robinhood newsroom https://robinhood.com/us/en/newsroom/a-visual-identity-that-better-reflects-our-vision/ : typefaces **Capsule Sans** ("warm, highly legible sans serif") and **Nib** ("whimsical serif full of personality").
- 2024 (Porto Rocha): https://www.portorocha.com/robinhood : **RH Phonic** sans ("delicate ink-traps bring personality without sacrificing precision") + **Martina Plantijn** serif for headlines; palette of black, white and "mature neutrals" plus one signature accent **Robin Neon** ("electric yellow green"); illustration "inspired by financial graphs familiar to investors"; "When it comes to standing out in a sea of fintech sameness, less is more."
Images: https://images.prismic.io/portorocha/aQohL7pReVYa4Ck1_RH.jpg ; //images.ctfassets.net/1hpl803w8xsv/4kpnzDZOCFmNu5zv3TkKc8/5393e19c7140bf4c0ed457260117883f/RH_Lists.jpg (2020, prefix https:)

---

## 4. Cross-source patterns

1. **Ornament and material live on the frame; data fields stay flat and quiet.** Victoria 3 DD30 (ornament on frames/headers only), Steph Chow ("feel of the world, but not compete"), Linear 2026 ("structure should be felt not seen"), Tufte (no data frames), Butterick (turn borders off first).
2. **Identity comes from a few owned decisions, not from texture everywhere.** Persona (main colour, then logo, then key font, then at most one sub-colour), Bloomberg (amber on black + yellow keys), Robinhood 2024 (black/white/neutrals + one Robin Neon), Linear (base + accent + contrast), Victoria 3 (emerald buttons, gold edge).
3. **Hierarchy through light/weight/contrast, not through more labels or boxes.** Persona (brighter = more important), Linear (dim the nav), Refactoring UI (weight and colour, fewer borders), Hodent (clutter dilutes signal).
4. **Depth on demand instead of more screens.** CK3/Victoria 3 nested tooltips, Victoria 3 predictions and empty states, Into the Breach animated tooltips; FM26 shows the failure mode (more clicks and levels).
5. **Keep the core table dense and right-aligned with tabular figures.** Butterick, Carbon row-height ladder, FM26 backlash when at-a-glance columns disappeared, Victoria 3 building panel.
6. **Colour systems are built in a perceptual space with fixed jobs per step.** Stripe (CIELAB, level distance = contrast), Linear (LCH), Radix (12 steps with jobs), XAG 102 (4.5:1 / 3:1).
7. **Semantic colours are few, reserved and redundant with shape/text.** Bloomberg CVD schemes, Victoria 3 colourblind text and red/green condition icons with silhouettes, XAG 102 (do not rely on colour alone), Hodent (overused red loses power).
8. **Two button classes: navigate vs act, and one primary per view.** Victoria 3 (two emerald shades, gold border for action, ornament for priority), Refactoring UI (primary/secondary/tertiary).
9. **Material/diegetic UI succeeds only when it is the verb or has physical feedback.** Papers, Please (documents are the mechanic; drag felt alive), Hearthstone (box + motion + sound = "solid and real"), Fagerholt & Lorentzon (diegetic/spatial/meta vocabulary); failure: static paper skins.
10. **Choose the UI surface against the world behind it.** Frostpunk 2 white UI on snow; Breath of the Wild transparent panels (Coates); our cream windows over a warm office.
11. **Notification discipline.** Victoria 3 DD74 (about 50% fewer notifications, player-set auto-pause), Bycer (never let critical events happen off-screen).
12. **Text size and contrast floors are concrete numbers.** XAG PC 18 px body height at 1080p and 4.5:1; FM26 had to fix "unreadable font sizes"; Frostpunk 2 delayed launch partly for readability.
13. **Iteration in the real product behind a flag, not in isolated mockups.** Linear (feature flags, private beta, hundreds of screens), Hearthstone (designed, scrapped, redesigned), Victoria 3 (100+ post-launch UX tweaks), Persona (trial-and-error layouts, over 1,000 spec sheets).

---

## 5. What translates to a startup game (research implications, not a design)

- A startup/finance identity in real products is built on: a neutral ground (black/white/warm grey or cream), **one owned accent**, one characterful display face paired with a quiet workhorse sans with tabular figures, and small in-line graphs next to numbers (Robinhood's graph-derived illustration, Tufte sparklines, Victoria 3 line graphs). Mono is used by Bloomberg for historical/hardware reasons, not as a readability choice.
- For Project Unicorn specifically: the office scene already supplies world, warmth and material. Research points toward windows that recede (neutral, calm, readable, dense tables), with identity carried by a small set of owned elements (accent, wordmark/display type, frame/header treatment, the top bar as a "terminal" with sparklines), and diegetic/spatial UI inside the office for the moments that deserve it (events, meetings), with portraits and scene at real size.
- Open question worth testing with Erdem: the dark top bar and ticker are the closest thing to a Bloomberg-like owned element already in the game; the cream windows are the generic part.

---

## 6. Uncertainty log
- Bloomberg article texts: not read (CAPTCHA). Facts tagged [snippet only] came from search summaries.
- Into the Breach GDC talk: video not transcribed; facts from Game Developer article plus search summaries.
- Hearthstone GDC talk: video not transcribed; facts via secondary writeups; "7-minion limit from box size" unverified.
- Galaxus FM26 review: timed out; facts from a search summary.
- Hodent's seven usability principles are from a third-party summary of her book, not her own page.
- The contrast/size measurements in section 0 are my own pixel measurements of one screenshot; they approximate WCAG contrast using the most-contrasting ink pixel, so real perceived contrast is at most the stated value.
