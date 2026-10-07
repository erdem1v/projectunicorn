# Strategy / management game UI research (panel-heavy, window-over-live-world)

Researcher notes, 2026-10-01. Scope: CK3, Victoria 3, EU4/EU5, Stellaris, HOI4, Frostpunk 1/2, Against the Storm,
Anno 1800/117, Terra Invicta, Old World, Humankind.
Method: primary sources (Paradox dev diaries read in full through a real browser because forum blocks bots; Game UI
Database full-size screenshots opened and inspected by eye; ArtStation project JSON; Steam pages; reviews).
Marking: [SEEN] = I looked at the screenshot myself and describe what is visible. [DD] = stated by the developer.
[REVIEW] = stated by press/players. [UNSURE] = not verified.

Project context: Project Unicorn today = dark mono top bar + left icon rail + fixed-slot cream windows over a live
isometric 3D office, centred event modal, bottom ticker. Owner calls it generic: default panels, flat chrome,
characterless type, no material. Paper-folder metaphor (3 variants) rejected.

---

## 1. Victoria 3 (Paradox Development Studio, 2022)

### Primary sources
- DD #29 User Experience (Henrik, UX Designer, with Aron):
  https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-29-user-experience.1506484/
- DD #30 User Interface Overview (Kenneth, 2D Art Lead):
  https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-30-user-interface-overview.1507166/

### UX pillars [DD, #29, verbatim list]
1. "The right information at the right time"
2. "Clear feedback about cause and effect"
3. "Clearly separate Actions from Information"
Goal statement [DD]: complexity "should not come from not knowing where to find something and why something
happened, but from the deep simulation". "The more accessible the information and interactions can be, the more
complex we can make that information and those interactions."

### Tools named in #29 [DD]
- Nested tooltips (from CK3), used for Game Concepts AND for number breakdowns. Lock modes are player-configurable:
  "Mouse Tendency, Timer Lock, or Action Lock", with adjustable timer.
- Line graphs inside tooltips for value-over-time; area chart and pie chart alternatives.
- Real-time predictions: effects of an action shown the moment you consider it (e.g. predicted Weekly Balance when
  switching Production Method, predicted earnings if you expand a building), each prediction itself tooltip-breakable.
- Map focus: every event has a map location; hovering a State name in any text highlights it on the map. Map modes
  auto-trigger when you open the related panel. Every map mode also exists as a sortable list ("a visual Ledger").
- Five "Lenses" (Production, Political, Diplomatic, Military, Trade): every map action reachable from them.
- Right-click context menus on States, Markets, Characters, Buildings, Interest Groups, Goods (entity -> action),
  complementing Lenses (action -> entity).
- Empty states: "A useful empty state will let the player know what's happening, why it's happening, and what to
  do about it." Example: a state with no urban buildings lists the urban buildings you could build there.
- Colour-blind modes for text (Tritanopia, Protanopia/Deuteranopia).
- Images (DD #29): https://forumcontent.paradoxplaza.com/public/780903/DD29%2001%20concept%20v2.png ,
  https://forumcontent.paradoxplaza.com/public/780905/DD29%2002%20numbers%20v2.png ,
  https://forumcontent.paradoxplaza.com/public/780906/DD29%2003%20menu%20tooltip.png ,
  https://forumcontent.paradoxplaza.com/public/780907/DD29%2004%20Graph.png ,
  https://forumcontent.paradoxplaza.com/public/780910/DD29%2005%20area%20chart.png ,
  https://forumcontent.paradoxplaza.com/public/780912/DD29%2007%20Building%20details.png ,
  https://forumcontent.paradoxplaza.com/public/780913/DD29%2008%20Production%20Methods%20tooltip.png ,
  https://forumcontent.paradoxplaza.com/public/780916/DD29%2010%20Fabric%20goods%20heatmap.png

### Art direction for the UI [DD, #30]
- UI = three categories: Panels, Buttons, Icons. "If it's not on the map, it's on an UI panel."
- Three art pillars: Prestigious ("elegant and exquisite"), Vintage and Idyllic (Romanticism), Detailed yet
  Approachable ("intricate elements but used sparingly").
- Panels: Art Nouveau ornament, BUT "we focus the rich details on frames and borders of the panels as well as
  headers where the title of the menu resides" -- the data area stays plain. Panel caption in the diary:
  "Elaborate patterns with a touch of gold and faded fabric textures".
- Buttons: wood texture; all buttons emerald, two shades = Navigation vs Action; Action buttons also get a thin gold
  border; high-priority buttons get extra Art Nouveau corner ornament. (Button role is encoded in material+colour.)
- Icons, three tiers by size/role: (a) buildings & goods = "mini illustrations" for immersion; (b) technologies,
  events = realistic rendered real-world objects (Protest = hand holding a loudhailer); (c) mechanic/stat icons =
  drastically reduced detail, "a few choice colours and the silhouettes", green = positive / red = negative,
  colour-coded families (Interest Groups, Lenses).
- Tutorial infographics deliberately NOT modern flat infographics: styled after Victorian newspaper and blueprint
  illustrations, overlaid on aged paper.
- Images (DD #30): https://forumcontent.paradoxplaza.com/public/783323/DD30%201.png through
  https://forumcontent.paradoxplaza.com/public/783334/DD30%2011.png (panel, buttons, icons, infographic plates).

### What the screens show [SEEN]
- Layout: fixed-width panel docked LEFT (about a third of 1920), map live in the centre, a permanent "outliner"
  column docked RIGHT (journal entries, markets, interest groups, armies, companies), dense top bar, round lens
  buttons along the bottom. The map is never fully covered by a routine panel.
  Steam: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/677898aa35dbc404ac08a23c190f7534c547b80a/ss_677898aa35dbc404ac08a23c190f7534c547b80a.1920x1080.jpg
- Panel anatomy (Pop panel "HAN MAHAYANA CLERKS"): crimson damask header plate, small-caps serif title, subtitle
  made of links ("Pop in Urban Center in Shandong" with a go-to arrow), round emerald back and close buttons in the
  header corners; then a large illustrated SCENE of the subject (3D characters in their setting) with a status
  pill over it ("Impoverished (14)"); trapezoid tabs; a two-column key/value sheet with labels in salmon serif and
  values in white, linked entities as emerald chips; a "needs" row of goods tiles.
- Buildings panel (DD #30 image 1): each row = illustrated building tile with a count, a darker name bar with the
  money figure right-aligned, a row of small status icons, round action buttons (+, pound+); below, "Potential
  Urban Buildings" grid where unavailable ones are dimmed instead of hidden (the empty-state principle drawn).
  https://forumcontent.paradoxplaza.com/public/783323/DD30%201.png
- Tooltip colour grammar (DD #29 image 2, "Texas"): dark plum box; salmon/orange = game concept (hoverable), pale
  yellow = named entity, bold white = value, green = positive delta, red = bad state ("Struggling"); a real button
  inside the tooltip ("Go to Details screen").
  https://forumcontent.paradoxplaza.com/public/780905/DD29%2002%20numbers%20v2.png
- Top bar: nation flag at far left; top row = five headline RATES as big signed green numbers (+2.98K, +60.5,
  +682, +1.40K, +47.1K) each with a thin bar; second row = smaller stock totals (113.6M, 17.0%...). Centre: round
  medallion with the pending-alerts count. Right: date, the weekday as a filling green bar ("Sunday"), and a
  clock-face speed dial with Roman numerals I to V (time control drawn as an instrument).
- Event window ("The Nile Expedition"): crimson title plate with location link ("Event in Ile-de-France"), a
  full-bleed painting fills the window, text sits on a semi-transparent slate card on one half: bold serif
  question first, ornament divider, italic quoted speech in grey, then emerald choice button(s) with gold edge.
  There is a MINIMISE button: events can be parked and resumed.
  https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/529340/ee3c20b6e34c83fa3f0784ec890e98214cb1affb/ss_ee3c20b6e34c83fa3f0784ec890e98214cb1affb.1920x1080.jpg

### Criticism [REVIEW]
- Blog "Victoria 3 has the worst UI I've ever seen" (player blogger, 2025-02-24):
  https://streamsofconsciousness.blog/2025/02/24/victoria-3-has-the-worst-ui-ive-ever-seen/ -- information split
  across "dozens and dozens of disconnected screens", tooltips that tell you about an effect but no route to the
  place that changes it ("no way to stop paying"), several different diplomacy menus. Lesson: a beautiful panel
  system still fails if information and the action that changes it live in different windows.
- Font family names not verified [UNSURE]; visually a book serif for titles/body.

---

## 2. Frostpunk 2 (11 bit studios, 2024)

### Sources
- ArtStation "UX/UI behind Frostpunk 2" (Feature UX Owner Wix Polojko; UI art Bartosz Sobolewski, Szymon Sobanski;
  UX design Daniel Janczewski, Krzysztof Michalak, Jakub Galanciak; UI VFX; UI sound design Krzysztof Lipka;
  4 UI programmers; art direction Lukasz Juszczyk): https://www.artstation.com/artwork/RKX6Re
  Clips in the project: "PROXIMITY SYSTEM", "COMMUNITY PANEL", "BUILDING TRACKERS", "COUNCIL LORE PANEL and DELEGATE
  PANEL", "IDEA TREE NODES", "BOTTOM BAR". Note: the credits list a dedicated UI sound designer and UI VFX artists.
- Game UI Database, Frostpunk 2 (86 screens): https://www.gameuidatabase.com/gameData.php?id=1965
- PCGamesN on the post-beta UI rework: https://www.pcgamesn.com/frostpunk-2/ui-improvements -- 11 bit quote: "The
  game is challenging enough already, so it came as no surprise to us that you want the interface to be as
  user-friendly as possible. That's why we're making changes to the UI and UX." Promised: clearer HUD, new
  construction menu, Idea Tree "clarity, readability, and look and feel". Release was delayed partly for this.
- gagadget summary of game director video: "overhauled the design, fonts, and layout of many of the interface
  elements" vs FP1: https://gagadget.com/en/494135-intuitive-and-clear-frostpunk-2s-game-director-talked-about-the-main-changes-in-the-interface-and-visual-design-of-the-game/

### What the screens show [SEEN]
- Whole screen framed by a thin brushed-steel bezel with notches: top-centre notch houses the heat/deficit readout
  (e.g. "-191" with a red bar), bottom-centre notch houses an advisor/steward figure. The HUD reads as one
  machined instrument frame around the world, not floating boxes.
  https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-43620.jpg
- Top bar, left to right: city name + date in small caps ("THE OLD DREADNOUGHT"), speed controls, "WEEK: 53 DAY: 7"
  in amber; population groups as icon+number; resource stock icon+number; centre notch heat; right side net
  deltas as signed numbers (+15, +4, -52) each with a tiny bar underneath coloured by sign; far right a temperature
  forecast strip (-30C and a row of small thermometer marks along a timeline).
- Objectives stack top-left: circular medallion icon (scroll), uppercase condensed title, big amber serif
  countdown ("36 WEEKS"), plain grey sub-line with the computed consequence ("Stockpiles ready in 1,422 weeks at
  current rate"), then checklist items with (x/y) counts; done items dim with a tick.
- Context panel for a selected district is anchored to the district in the world (not a docked window): frosted
  translucent light-grey glass, dark tab-shaped title plate ("EXTRACTION DISTRICT"), small condensed caps labels
  (REQUIREMENTS / DEPOSIT / TOTAL OUTPUT / TOTAL DEMAND / AREA EFFECTS), numbers coloured by meaning (blue output,
  red demand), a 6-stop workforce slider 0%-100%, a small dark tab at the bottom with demolish/power toggles.
- Tooltip: flat light-grey box, one sentence, values in blue with icons ("+45", "+105 Prefabs").
  https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104957-45092.jpg
- Event / decision modal: a full-height vertical frosted-ice column in the centre, painterly character
  illustration at top dissolving into frosted glass, serif caps title ("AGAINST THE ELEMENTS") + condensed caps
  category ("SQUALOR"), serif body text (2 short paragraphs), one bold sans line stating the concrete stake, then
  choices as centred condensed-caps text buttons framed by dashes. The world behind is blurred and brightened.
  https://www.gameuidatabase.com/uploads/Frostpunk-209262024-104909-89990.jpg
- Hint at the bottom right in widely tracked caps: "LEFT ALT: ECONOMY OVERLAY" (overlay as a hold-key mode).
- ArtStation cover frame [SEEN]: objectives panel, world full of round white icon pins over districts, thin top
  bar; the HUD leaves the city as the dominant image.

### Criticism and praise [REVIEW]
- New Game Network review (SpectralShock, 2024-09-30):
  https://www.newgamenetwork.com/article/2813/frostpunk-2-review/
  * Build menu along the bottom has "small icons grouped too closely", horizontal pop-up that later needs sideways
    scrolling, easy to mis-click.
  * "the entire UI has a white tint to it" which is poor contrast "with the endless snow" -- the material matched
    the world TOO well and lost figure/ground.
  * Effects described with words only ("tension greatly decreased", "production slightly decreased") "without
    using numbers" -> hard to judge a law's impact.
  * Praised: "cool bleeding effects of the menu icons and shifts in contrast from white to black when things are
    going sideways" (the UI's own contrast state reports the city's condition).
  * Suggests research/law availability should have stronger indicators (e.g. a pause), while some narrative
    events pause the game "that don't even matter that much".

---

## 3. Crusader Kings III (Paradox, 2020)

### Primary sources
- CK3 Dev Diary #16 "Tutorials and Tooltips and Encyclopedias, Oh My!" (Matthew, programmer):
  https://forum.paradoxplaza.com/forum/developer-diary/ck3-dev-diary-16-tutorials-and-tooltips-and-encyclopedias-oh-my.1345581/
  Images: https://forumcontent.paradoxplaza.com/public/537566/tooltip_in_tooltip.png ,
  https://forumcontent.paradoxplaza.com/public/537567/tooltips_4_days.png ,
  https://forumcontent.paradoxplaza.com/public/537569/alert.png ,
  https://forumcontent.paradoxplaza.com/public/537570/issues.png ,
  https://forumcontent.paradoxplaza.com/public/537574/notifications.gif ,
  https://forumcontent.paradoxplaza.com/public/537575/toasts.gif ,
  https://forumcontent.paradoxplaza.com/public/537571/encyclopedia.png
- Game Developer deep dive (Valeska Martins, UX Design Lead; Ellinor Zetterman, UX Designer, PDS Black):
  https://www.gamedeveloper.com/design/deep-dive-refreshing-the-crusader-kings-iii-tutorial-mode-through-optimized-ux
- Philip Ardeljan (web designer) on why nested tooltips work: https://philip.design/blog/tooltips-in-tooltips/
- Counterpoint thread: https://forum.paradoxplaza.com/forum/threads/reminder-to-the-devs-that-nested-tooltips-is-bad-ux-design.1702017/
  (title only verified; I did not read the body) [UNSURE on arguments]

### Facts [DD, #16]
- Motivation, verbatim: CK2 "had a UI with what one might describe as questionable usability"; goal: "the strategy
  and challenge of the game should come from mastering its systems not finding which button you need to click or
  which number you need to tooltip".
- Tooltips in Tooltips: any "blue highlighted text" is a Game Concept you can hover; nesting is unlimited. Two lock
  modes: timer lock (default, timer set in settings) and action lock (middle mouse). Action lock exists so experts
  can make it opt-in.
- Tiered attention system, each tier with a distinct visual and rule:
  * Alerts (top bar): only things the player can FIX by an action; clicking goes to the action. Explicitly not
    status reminders ("being at war" is not an alert because you cannot click it away).
  * Issues tab: situation summaries you may act on but not urgent ("mini-alerts": claims to press, bankruptcy).
  * Suggestions: periodic "things you could do", dismissable, can be disabled.
  * Reactive Advice: purple info icon, context mini-tutorials that highlight the relevant UI element.
  * Notifications: small feed items about other characters; only a few visible, they minimise and auto-dismiss.
  * Toasts: "slightly more bombastic", top of screen, one at a time in a timed queue, hover pauses the timer; used
    for event outcomes and action feedback "without throwing up a huge event window".
- Encyclopedia generated from script data (never out of date), searchable, with history.
- Modal events are therefore reserved for real decisions; outcomes go to toasts.

### Facts [Game Developer deep dive]
- Old tutorial = 67 sequential text boxes; cut to about 22 (a third). Principle named: progressive disclosure,
  applied to the character panel as well. Fixed a bug where GUI windows did not resize dynamically, which made the
  UI feel "unnecessarily cluttered". Competitive analysis included Against the Storm.

### What the screens show [SEEN]
- Character panel (Steam shot): docked full height on the LEFT, about 600 px of 1920. The top third is a live 3D
  STAGE: the ruler and spouse standing in their throne room, heir portrait inset in the corner; the panel header is
  a lit scene, not a title bar. Below: name line with age and a health heart; traits as small painted square
  illustrations; skills as icon + number; culture/faith in italic fields; big coat of arms on the right; a
  resource strip; realm block; tabs WITH COUNTS ("Family 12 / Relationships 0 / Courtiers 19 / Subjects 62");
  portrait grid where every portrait carries micro-badges (opinion +23 green / -36 red, skull for dead, tiny coat
  of arms). Charcoal panels with a faint image of the room bleeding through behind the realm block.
  https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46/ss_0ed600e9f23f5fd9eebaa4bc16e883b5fbc12d46.1920x1080.jpg
- Top bar: segments split by thin vertical rules; each = icon + large value + SMALL GREY monthly delta directly
  under it (+9.2, +4.4); the delta turns red only when negative (-0.1). Calm by default, colour only on trouble.
- Crusade window: the WINDOW SILHOUETTE IS A HERALDIC SHIELD (shape carries meaning); serif title with an
  underlined concept link; versus layout (attacker portrait left, defender right, sigil in the middle, "Launches
  in 5 months"); a single tug-of-war bar for relative strength with the two numbers at its ends (25735 vs 12355);
  "War Chest" drawn as an illustrated chest with three values beside it; thin gold-outline buttons.
  https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1158310/927b699bb755884d14c31ccdfc7ffe2211730ca7/ss_927b699bb755884d14c31ccdfc7ffe2211730ca7.1920x1080.jpg
- Bookmark/start screen: the map is a physical parchment lying on a table in a room (diegetic framing of a menu).

### Praise and criticism [REVIEW]
- PCGamesN review: https://www.pcgamesn.com/crusader-kings-3/review-ck3 -- "discarded the busy stonework-and-
  stained-glass aesthetic of Crusader Kings II in favour of a simpler, less distracting system"; "uses subtle
  colour coding to help keep you focused on what matters"; nested tooltips "prevents new players from feeling
  overwhelmed". Criticised: key decisions pop up over what you are tracking and "crucial text will be obscured by
  overlapping information boxes"; right-click dismissing of top "announcement scrolls" caused mistaken commands.
- NME, PC Gamer and others (via search summaries, not all opened [UNSURE on wording]) call CK3 the most
  accessible Paradox GSG thanks to the UI rework.

---

## 4. Anno 1800 (Ubisoft Blue Byte, 2019) and Anno 117: Pax Romana (Ubisoft Mainz, 2025)

### Anno 1800 sources
- Anno Union DevBlog "User Interface" (Khajag Jabaghchourian, UI Designer), June 2018:
  https://www.anno-union.com/devblog-user-interface-2/
  HUD before/after image: https://www.anno-union.com/wp/wp-content/uploads/2018/06/DevBlog_UI_UX_HUD-1.jpg
- Game UI Database, Anno 1800: https://www.gameuidatabase.com/gameData.php?id=1118

### Anno 1800 facts
- [DD] "form follows function"; "minimal amount of ornamentation, materials, and textures" because otherwise the "UI
  itself would start competing with the actual game for the player's attention".
- [DD] Colour rule by persistence: persistent HUD in darker colours (less eye fatigue); pop-up windows and
  notifications in brighter colours to pull attention. (Direct precedent: dark frame + bright transient cards.)
- [DD] Process: pen-and-paper wireframes -> interactive prototypes for UX tests -> mock-ups -> dedicated icon
  designers -> implementation; After Effects for UI animation.
- [SEEN] New HUD (DevBlog image): three separate dark-navy capsules with thin gold rim floating at the top edge,
  not a full-width bar. Left capsule: player portrait medallion, then icon-over-number stacks (money 43,589 with
  balance +942 beneath, influence, etc.). Centre capsule: island name plate hanging below ("GLAMOROUS MINOR
  MEGAPOLIS / ANNO UNION"), population per tier (4800, 1800...) with a second row of signed deltas (+375, +580)
  each with a tiny resident-portrait icon. Right: round menu buttons. The world shows between the capsules.
- [SEEN] Statistics screen (full-screen, pauses nothing): parchment over a faded sepia harbour illustration; dark
  wooden title plaque hanging from the top edge ("Statistics"); tan tab buttons (Production / Storage / Finance /
  Population / Items); left island list; table rows each led by a large illustrated goods icon, two stacked
  mini-bars per row (blue = buildings 13/13, green = productivity 12/12), then numeric columns headed by icons not
  words; selected row inverts to dark navy; right side a line chart "Production over time" on the parchment.
  https://www.gameuidatabase.com/uploads/Anno-180008172021-101846-68526.jpg
- [SEEN] Diplomacy screen: relationships are SPATIAL. Concentric parchment arcs = tiers (Alliance / Trade Rights /
  Peace / War, tinted blue, green, neutral, orange); each rival is a round portrait placed in its band with a small
  numeric badge; your own portrait sits in a medallion with a ribbon banner and money/influence under the name.
  https://www.gameuidatabase.com/uploads/Anno-180008172021-101846-10131.jpg
- [SEEN] Trade Routes: split screen, parchment list left (serif headings, route rows as tan strips with goods
  icons), sea-chart map right with portraits on islands; wooden title plaque; purple primary button "Create Route".
  https://www.gameuidatabase.com/uploads/Anno-180008172021-101847-15561.jpg
- [SEEN] Dialogue: big 3D bust portrait bottom-right, overlapping the frame edge; subtitle in a translucent dark box
  bottom-centre; speaker name small above the text. Game keeps running behind.
  https://www.gameuidatabase.com/uploads/Anno-180008172021-101843-29830.jpg

### Anno 117 sources
- Anno Union DevBlog "The User Interface Team and a deeper dive into the visuals" (2026-03):
  https://www.anno-union.com/devblog-the-user-interface-team-and-a-deeper-dive-into-the-visuals/
  Images: https://www.anno-union.com/wp/wp-content/uploads/2026/03/Image_1.png (Miro board: UI research,
  buttons, motion design, visual design, font family) ; .../Image_9.png (three tonal navy fabric swatches) ;
  .../Image_13.png (layered portrait frame: backplate, animated meander ring, seam-hiding ring, portrait layer)
- Accessibility spotlight: https://news.ubisoft.com/en-us/article/2FfSSEUp1jtg9isC9NxowP/anno-117-pax-romana-accessibility-spotlight
- Player criticism threads: https://steamcommunity.com/app/3274580/discussions/0/604166319349331285/ ,
  https://steamcommunity.com/app/3274580/discussions/0/505068966120582687/

### Anno 117 facts
- [DD] UI team of about 13, split into sub-teams: visual design, interaction design, tech implementation,
  accessibility. Pillars: elegance, polished, delicate, refined. UI should feel "integrated rather than appearing as
  a separate overlay".
- [DD] Went DARK on purpose: dark blue base because it "complemented the in-game world", "elegance and clarity
  while providing strong contrast for key elements".
- [DD] One rare accent with one job: Tyrian purple "reserved ... exclusively for significant moments ...
  specifically as the selected state for buttons".
- [DD] Material: subtle fabric texture so panels are not flat; tonal fabric variations carry hierarchy; blue marble
  with purple veins as secondary material; mosaic patterns built as vectors so ornaments are cheap to vary.
- [DD, via search summary] Active pause (interact with UI while paused); 5 UI scales. [UNSURE: exact wording]
- [REVIEW, Steam players] Criticised: nested build sub-menus hide buildings; no at-a-glance, sortable resource
  overview; "black and white" icons feel like placeholder widgets; tooltip font size; notification panel closes and
  marks all read on one click. Players explicitly contrast with Anno 1800's "usefull info quickly".
  Lesson: material/elegance does not rescue weak information access; monochrome icons read as unfinished.


---

## 5. Against the Storm (Eremite Games, 2023) -- the "we went too minimal" case

### Sources
- "Interface Update is here!": https://eremitegames.com/interface-update/
- "Devlog - Updated UI preview and Deeds Update teaser" (April 2022): https://eremitegames.com/devlog-april-2022/
  Before/after: https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-Before.jpg ,
  https://eremitegames.com/wp-content/uploads/2022/04/UI-Improvements-After.jpg
  Interface-update gallery: https://eremitegames.com/wp-content/uploads/2022/04/General-UI-on-Marshlands.webp ,
  https://eremitegames.com/wp-content/uploads/2022/04/Smithy-Before.webp ,
  https://eremitegames.com/wp-content/uploads/2022/04/Smithy-After.webp
- Steam screenshot: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1336490/ss_c5e7f55444d87f26921736f2d228c092f4dda5f2.1920x1080.jpg

### Sequence of events [DD]
1. Original UI: ornate, "pretty, but a bit unreadable in places, and not very well optimized"; "a patchwork of
   various ideas and styles ... more and more inconsistent".
2. Interface Update: "Most backgrounds (in panels, tooltips, windows) are now dark"; "Most fonts in the game have
   been changed to improve readability"; "fewer big decorative elements"; building icons zoomed in; calendar at
   the top made more concise; big windows got tabs on top; construction panel switched from big building cards to
   smaller icons; species panels show exact Resolve and Target Resolve; UI lighter on CPU.
3. Player response and correction (April 2022 devlog), verbatim: "Cleaning up the UI from heavy ornaments was one
   of the principles we agreed on. We now know that the 'handcrafted', warm feeling is what you miss the most from
   the previous UI." "we want to meet you halfway." Fixes: "Window and panel backgrounds will receive an earthy
   green texture and new leatherwork decorations"; frames widened and more decorated; "Some vibrant colors will
   be toned down".

### What the before/after shows [SEEN]
- BEFORE (the stripped version): flat navy panel, thin gold hairline frame, small-caps gold title, plain dark
  rows. Readable but anonymous: it could belong to any fantasy game.
- AFTER: same layout and type, but the panel is a dark green textured leather surface, a wider frame with
  corner ornaments, crimson tabs with icon only, recipe rows as recessed leather slots, ingredient icons in round
  frames. Readability kept, character returned. The fix was MATERIAL + FRAME, not layout.
- In-game HUD [SEEN, Steam]: resource counters in a strip at top-left, a central medallion with the season/storm
  clock, species portraits with resolve at the left edge, bottom build bar of round icons with a large skull
  medallion (Queen's Impatience) and hostility bars; building panels dock right with tabbed headers.

### Relevance
- Closest documented analogue to Erdem's complaint: clean dark minimal panels felt generic and players said so;
  the studio did not revert to clutter, it added one material (leather), one richer frame, and toned colour.
  Warmth came from surface and edge treatment while the data area stayed plain.

---

## 6. Frostpunk (11 bit studios, 2018)

### Sources
- Steam screenshots (app 323190): event https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_03fc3089daf0785e3bf34b32c385e80defefaeb4.1920x1080.jpg ;
  Book of Laws https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_680799fc8f335607924c5703e10eb62780f91d97.1920x1080.jpg ;
  HUD + building panel https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/323190/ss_5f9c9d5944a98b68b3b57c418f4267a459c757f8.1920x1080.jpg
- Game UI Database Frostpunk entry (id 38 per search listing) [UNSURE which id is FP1]:
  https://www.gameuidatabase.com/gameData.php?id=38
- Console-port UI article (title only verified): https://www.gamedeveloper.com/design/the-simple-most-difficult-challenge-of-bringing-frostpunk-to-consoles

### What the screens show [SEEN]
- HUD is one continuous piece of wrought-iron filigree: thin line frame with Victorian curl ornaments at the ends,
  a central round temperature gauge ("-70 C") at the top, resource counters left and right in a condensed
  digital face WITH DIM LEADING ZEROS (odometer look: "0 1535", "00272"), speed buttons and "FREE TIME 07:25",
  "DAY 22" followed by a forecast ruler (23, 24, 25, 26 with weather icons). Bottom: frosted-metal round buttons,
  the two society meters Discontent (red) and Hope (blue) as long bars in the centre, population/housing pill
  "124/578" at right.
- Building panel docks right: photographic header image of the building interior, status line ("Functioning"),
  tabs, workforce table (Engineers 10/10 with min/max steppers), passive effects.
- Event takeover: full-screen, frost-and-ink vignette edges, photoreal group of the people concerned on the right,
  small serif category ("Protest"), big slab-serif title ("Facing starvation") between ornamental rules, body text
  with key nouns in cyan ("a crowd", "angrily", "hunger"), the player's own voiced resolve in cyan caps, the
  concrete consequence in small bold cyan ("I'll have to feed everyone in 3 days..."), choices as long dark teal
  bars staggered like a cascade, each tagged "Quest".
- Book of Laws: ink-splatter full screen; law tree nodes drawn as filigree medallions marked "SIGNED"; selected
  law card on the right with a character illustration, a quill-and-"SIGNED" stamp button, and effects as a bullet
  list: positives in cyan, negatives in red ("prisoners may get hurt or killed", "discontent will rise").

---

## 7. Europa Universalis V (Paradox Tinto, 2025) and EU4

### Sources
- Tinto Talks #77 (UI building blocks), 20 Aug 2025:
  https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-77-20th-of-august-2025.1856053/
  Images: https://forumcontent.paradoxplaza.com/public/1344483/tooltip_concepts.png ,
  https://forumcontent.paradoxplaza.com/public/1344484/tooltip_table.png ,
  https://forumcontent.paradoxplaza.com/public/1344485/tooltip_action.png ,
  https://forumcontent.paradoxplaza.com/public/1344486/tooltip_conditions.png ,
  https://forumcontent.paradoxplaza.com/public/1344487/outliner.png ,
  https://forumcontent.paradoxplaza.com/public/1344492/alerts.png ,
  https://forumcontent.paradoxplaza.com/public/1344493/message.png ,
  https://forumcontent.paradoxplaza.com/public/1344495/filter.png ,
  https://forumcontent.paradoxplaza.com/public/1344497/hints.png
- Tinto Talks #76 (UIs iterated after influencer feedback), 13 Aug 2025:
  https://forum.paradoxplaza.com/forum/developer-diary/tinto-talks-76-13th-of-august-2025.1855048/
  Images: https://forumcontent.paradoxplaza.com/public/1339294/country_list.png ,
  https://forumcontent.paradoxplaza.com/public/1339295/diplomacy.png ,
  https://forumcontent.paradoxplaza.com/public/1339296/battle_1.png ,
  https://forumcontent.paradoxplaza.com/public/1339299/war_overview.png
- Player criticism threads (read only via search summary [UNSURE]):
  https://steamcommunity.com/app/3450310/discussions/0/667222787666165479/ ,
  https://steamcommunity.com/app/3450310/discussions/0/667222425710107354/ -- "3 sub menus and 4 tooltips" to
  reach one fact; UI does not scale well on QHD.
- EU5 Steam shot (left panel + map): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3450310/6959abf137586597c9b7843111a26ba13aa86665/ss_6959abf137586597c9b7843111a26ba13aa86665.1920x1080.jpg

### Facts [DD, Tinto Talks #77]
- Tooltips built on CK3's nested system; game concepts coloured blue. New: values with many sources shown as
  TABLES inside tooltips; tooltips list what left-click and right-click will do (mouse icons); if an action is not
  possible, "a small condition block in the tooltip showing why".
- Two outliner versions (full and simpler) with toggles for what it shows.
- Right-click context menus on locations, countries, characters, units; unit menu stays open when you flip a toggle.
- Alerts, now six colours: yellow, orange (between yellow and red), red, blue (pure UI hints such as tutorial,
  no control group), purple (situations and disasters). Any alert can be discarded and "will only appear again if
  the conditions change".
- Messages: every message type configurable as log entry / pop-up with pause / pop-up without pause / floating
  text on the map; each message has a category.
- Search and filters on every list; clicking a number (a location's population) opens the matching list
  pre-filtered.
- Colour ledger for map modes.
- Hints: shift-click an alert to get a hint; the top of a hint shows flavour quotes from YOUR best-stat characters
  giving advice (inspired by Civilization 2's advisors); then the reason and suggested actions; "Any yellow text
  here is clickable and will take you to the panel where you can do something about it".

### Facts [DD, Tinto Talks #76]
- Diplomacy list rebuilt as "cards": top row = rank badge, flag, full name, bookmark star (bookmarking adds it to
  the outliner and news); bottom row = six BUTTONS that each show a value (Opinion, Trust, Favours, Spy network)
  and clicking one performs the matching action (e.g. send a diplomat to improve opinion); plus casus belli and
  war/peace buttons. [SEEN in country_list.png: negative values red, positive green, war button red.]
- Diplomacy "split mode": actions and target info visible together, next/previous country card at the top.
- Battle UI rebuilt because it "was not easily decipherable"; after playtests "it's actually fun to follow the
  progress". Battlefield drawn as two facing rows (reserves, centre, flanks) with morale bars and per-regiment
  icons in country colours.
- War overview moved from a cramped side window with "two big portraits taking up large parts of the screen" to a
  sortable full screen.

### Tooltip anatomy [SEEN, tooltip_conditions.png "Manorial Courts"]
Header (icon, title, italic blue category "Estate Privilege", corner icon) -> two big signed summary numbers
(+5% green, +50% red) -> "Modifiers" table (icon, label, right-aligned signed value) -> "Cannot be removed due to:"
block -> italic flavour paragraph -> action line with mouse icon and cost ("Revoke Privilege 231.90") -> red
failure bar at the bottom ("We can't afford 231.90" with an X).

### What the screens show [SEEN, Steam]
- EU5: left-docked panel about 350 px wide, each panel headed by an illustrated vignette (army portraits, market
  scene, city vista, throne room); dense stacked alert icons down the right edge; dense top bar; "Game is Paused"
  ribbon at top centre. Event windows: illustration header and blue option bars.
- EU4 event: title bar, sepia engraving illustration inside a parchment inset, flavour text on parchment, choices
  as two dark blue bars; option effects in tooltips.

---

## 8. Hearts of Iron IV (Paradox, 2016)

### Sources
- Dev Diary #53 "2D Art" (mirror): https://thearmoredpatrol.com/2016/04/22/hearts-of-iron-iv-development-diary-53-2d-art/
  Early UI concepts image: https://i.imgur.com/LmoT5Sf.jpg
- UI artist portfolio (title only; ArtStation blocked fetch): https://www.artstation.com/artwork/zAQWRL [UNSURE contents]

### Facts [DD]
- First Paradox project with a UX designer from the start; lessons from EU4.
- "We skipped the fullscreens and went for smaller windows instead for example, this way you can still keep an
  eye on the map." "icon+tooltip solution instead of excel-sheets filled with text". "less clicks to reach
  important screens, trying to show more info from the map itself, using alerts".
- Art direction: 1930s-40s music and wartime posters; windows "gritty and dark" so that "saturated or detailed
  icons will pop out more". All main windows use a tiling background (solved EU4 window sizing).
- Scale: 1200+ tech/idea/focus icons, 420+ leader portraits, about 1600 UI elements.
- [SEEN] Early concept sheet: scuffed dark gunmetal panels, a glowing orange active pill button, a beige paper
  label slot in the top bar; the artist labelled one over-bevelled frame "UGGLY" -- heavy chrome was tried and
  rejected during exploration.

---

## 9. Stellaris (Paradox, 2016-2026)

### Sources
- Dev Diary #417 "Situation Log Updated" (UX designer Doga), Steam mirror:
  https://steamstore-a.akamaihd.net/news/externalpost/steam_community_announcements/1830797770232806
  Forum original (bot-guarded, not read): https://forum.paradoxplaza.com/forum/developer-diary/stellaris-dev-diary-417-situation-log-updated.1918530/
- Steam screenshots app 281990: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/281990/ss_ee82888c27afb4174cf4cae6298b54c7c1e2a682.1920x1080.jpg (event "The Unbidden")

### Facts [DD #417]
- Pain points named: navigation, lack of ordering, lack of grouping and hierarchy, desire for personalisation.
- Multi-entry events unified into one entry. Collapsible categories ordered by urgency: Tutorial, Crises,
  Priority (player-pinned), Urgent (deficits, time-sensitive), Empire Concerns, Precursors, Developments.
- High-volume, low-urgency items (First Contacts, Dig Sites, Anomalies, Astral Rifts) moved to a separate
  "Findings" tab "So no longer will crises be hidden under many many first contacts".
- [SEEN, Steam] Base look: dark translucent teal-green panels with thin bevel lines; event windows small, image
  header + text + one button, the galaxy stays visible around them.

---

## 10. Old World (Mohawk Games, 2021)

### Sources
- Steam screenshots app 597180: Marriage Offer event https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/597180/ss_beac7b76f069fa349b4c0821923467fe7b7af04c.1920x1080.jpg ;
  tech card draw https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/597180/ss_0575d38f40f4f991a9c3946b9fbf56d5865bfb2f.1920x1080.jpg
- Ancient World Magazine review (critical): https://www.ancientworldmagazine.com/reviews/old-world-2021/

### What the screens show [SEEN]
- Event ("Marriage Offer"): dark panel with a red lacquer title plaque in small-caps serif; the two people
  concerned as stacked portraits on the left; text with inline entity names in gold/purple each followed by a
  small identity icon; minimise and close buttons; choices as full-width dark bars.
- Technology is a CARD DRAW: "Phalanx Discovered" shows a hand of 4-5 tech cards (painted illustration, name
  plate, unlock list with small icons, years to research), a "Redraw" button, and a tooltip listing "Available"
  and "Discard Pile". The deck metaphor is literal and the UI shows the deck's state.
- Bottom-left: the current character portrait with stats is always present.

### Criticism [REVIEW, Ancient World Magazine]
- "The interface is wretched: a mess of small fonts and tiny icons." "Most of the details are stuffed into
  tooltips". "At some points, most of my screen was filled with tooltips!" On events: "You have to hover over each
  option to see what the effect will be: I have no idea why this information is not simply included on the
  relevant button instead." "It's simply not easy to look at the screen and gain a good idea of the current status
  of your game." (Other reviews praise the freezable tooltips; per search summaries [UNSURE wording].)

---

## 11. Terra Invicta (Pavonis Interactive, 2022; 1.0 in 2025)

### Sources
- Steam screenshot app 1176470: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1176470/2fc05e2ce502d85a0bb46acf260896b24cd5ae7e/ss_2fc05e2ce502d85a0bb46acf260896b24cd5ae7e.1920x1080.jpg
- Turn Based Lovers 1.0 review: https://turnbasedlovers.com/review/terra-invicta-1-0-impressions/

### What the screens show [SEEN]
- Modal "MISSION CONTROL REPORTS" (khaki strip header) -> 3D render of the object -> title in caps geometric sans
  ("PROBE LAUNCHED") -> faction crest left, planet right, body text -> a note that "Future notifications like this
  will not trigger an alert nor pause the game" and will go to the news feed or event summary -> three buttons
  that each state their TIME consequence with an icon: "CONTINUE" (play icon), "CLOSE" (pause icon), "TAKE ME
  THERE" (locate + pause icon).
- Very dense top bar of resource icons with values and deltas; thin-line translucent sci-fi panels; councillor
  portrait card bottom-right.

### Criticism [REVIEW]
- "Terra Invicta's UI is less a tool and more a stress test"; "Public opinion swings that will cost you control of
  a nation hide behind tiny icons"; "the tech tree itself looks like it was organized by someone allergic to
  folders". 1.0 improved: interface "finally starts acting like it wants you to succeed".

---

## 12. Humankind (Amplitude, 2021)

### Sources
- Game UI Database, Humankind (96 screens): https://www.gameuidatabase.com/gameData.php?id=1154
  HUD + army panel: https://www.gameuidatabase.com/uploads/Humankind08292021-083721-22032.jpg
  Research side panel: https://www.gameuidatabase.com/uploads/Humankind08292021-083719-68013.jpg
  Narrative event: https://www.gameuidatabase.com/uploads/Humankind11212021-124347-65155.jpg
- Amplitude forum UI thread (title only): https://community.amplitude-studios.com/amplitude-studios/humankind/forums/169-game-design/threads/43919-my-biggest-gripe-is-the-ui
- Cultured Vultures review (search summary only [UNSURE]): https://culturedvultures.com/humankind-pc-review/ --
  "sleek and responsive", collapsible menus, mechanics insufficiently explained.

### What the screens show [SEEN]
- Panels are translucent frosted blue glass over the map, with small-caps gold serif titles ("Egyptians",
  "Hunting Party", "Progress"); top-left empire medallion with era stars; big circular buttons bottom-left
  (research flask teal, civics scroll magenta, hands navy); "MAP FOCUS on/off" toggle bottom-right; turn button a
  large round dial.
- Terrain tooltip: compact dark card with centred small-caps section rules ("TERRAIN DETAILS", "EFFECTS") and
  icon-prefixed signed values.
- Unexplored map drawn as a pale hand-sketched chart (fog is an illustration style, not black).
- Narrative event: small window whose painted illustration BREAKS OUT above the panel's top edge, small-caps serif
  title ("A Fresh Start"), serif body, a magnifier button for detail; the map stays visible.

---

## Note on image licensing
Game UI Database states its content must not be used for AI asset generation or machine learning. The URLs above
are for human reference only (look, compare, discuss); do not feed them to image generators.

Extra screenshot URLs resolved from the Steam API (index checked):
- EU4 event "Growth of the Murano Glass Industry": https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/236850/ss_5f121c7e811451deee1fa15b3fcfd95ea072f6b2.1920x1080.jpg
- EU5 colony event: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3450310/33a7a520661dcedca6c80a774462b28ed02350bd/ss_33a7a520661dcedca6c80a774462b28ed02350bd.1920x1080.jpg
- HOI4 country select: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/394360/ss_679ae0d56f3a3b33591262839588c4b1dc6bef12.1920x1080.jpg

---

# CROSS-GAME PATTERNS (with the games that show them)

P1. Ornament and material live on the FRAME and HEADER; the data area stays plain.
    Victoria 3 (DD #30: "we focus the rich details on frames and borders ... as well as headers"), Against the
    Storm (after-fix: leather surface + decorated frame, rows unchanged), Anno 117 (subtle fabric texture on panels,
    tonal variants for hierarchy), HOI4 (gritty dark frames so icons pop), CK3 (dropped CK2 stonework for calm
    panels). Counter-examples: Anno 1800 chose minimal ornament on purpose; ATS's fully stripped version was judged
    characterless by players.

P2. The big panels open on a STAGE: an illustration or a live 3D scene of the subject in its setting.
    CK3 character panel (ruler and spouse rendered in their throne room), Victoria 3 pop panel (the pop's people in
    their town), EU5 (each panel headed by a painted vignette), Frostpunk 1 building panel (interior photo), Anno
    Statistics (sepia harbour behind the parchment). The header is a picture, not a label.

P3. Top-bar numbers are instruments, not labels: value + signed delta, rates vs stocks, forecast, time as a dial.
    CK3 (grey delta under each value, red only when negative), Victoria 3 (row 1 = rates in big green signed
    figures, row 2 = stocks; weekday as a filling bar; speed as a Roman-numeral clock dial), Frostpunk 1 (odometer
    digits with dim leading zeros; a day ruler with weather icons for the coming days), Frostpunk 2 (net deltas with
    tiny signed bars; temperature forecast strip; heat in a centre notch), Anno 1800 (separate capsules with a delta
    row under population), Vic3/EU5 (a central alert medallion with a count).

P4. A tiered attention system; the modal is reserved for real decisions.
    CK3 (alerts only for fixable things, issues, suggestions, notifications that auto-minimise, toasts one at a time
    for outcomes "without throwing up a huge event window"), EU5 (six alert colours, discard until conditions change,
    per-message choice of log / pop-up with pause / without pause / map text), Stellaris (log grouped by urgency,
    pinning, high-volume "Findings" moved out so crises are not buried), Terra Invicta (a first-time modal tells you
    future ones of this kind go to the feed), Anno 117 criticism (notification panel marks all read on one click).

P5. Event windows: picture of who/what is involved dominates; question first; stakes in one line; choices show
    their effect on the button; the window can be parked.
    Frostpunk 2 (full-height frosted column, illustration dissolving into glass, one bold stake line, caps choices),
    Frostpunk 1 (full takeover, key nouns highlighted, consequence line in bold), Victoria 3 (painting fills the
    window, text on a slate card, question in bold, quote in italics; MINIMISE button), Old World (two portraits of
    the people involved; minimise), Humankind (illustration breaks out of the window's top edge), EU4 (engraving on
    parchment). Criticism: Old World hides option effects in tooltips; Frostpunk 2 states effects in words
    ("greatly decreased") without numbers; CK3 decision pop-ups cover what you were tracking.

P6. Every modal button states what happens to TIME.
    Terra Invicta ("Continue" = play icon, "Close" = stays paused, "Take me there" = jump + pause), EU5 message
    settings (pause vs no pause per message type), Anno 117 active pause, CK3 toast timer pauses on hover.

P7. A strict text colour grammar with hyperlinked concepts (nested tooltips).
    CK3 (blue = concept, infinite nesting, timer or action lock), Victoria 3 (orange = concept, yellow = entity,
    white bold = value, green/red = sign; buttons inside tooltips), EU5 (blue concepts, yellow = clickable jump,
    tables inside tooltips, action + cost + why-blocked blocks), Frostpunk 1 (cyan = key noun / positive, red =
    negative). Criticism: Old World and Terra Invicta show that tooltips cannot carry the core status of the game.

P8. Values are actions: the number you read is the button that changes it.
    EU5 country cards (Opinion/Trust/Favours/Spy chips are buttons), Victoria 3 (right-click menus on every entity;
    "Go to Details" inside tooltips; state names in text highlight the map), EU5 (click a population number -> the
    pre-filtered list). Criticism that motivates it: Victoria 3 blog ("no way to stop paying" from where you read it).

P9. Relationships and contests are drawn spatially, not tabled.
    Anno 1800 diplomacy (rivals as portraits placed in concentric arcs: Alliance / Trade Rights / Peace / War), CK3
    crusade (versus layout + one tug-of-war strength bar), EU5 battle (two facing rows, morale bars, regiments as
    coloured pips), Old World tech (a hand of cards with a visible discard pile).

P10. Windows keep the world visible; the world reacts to the open window.
    HOI4 ("skipped the fullscreens ... so you can still keep an eye on the map"), Victoria 3 (left panel + right
    outliner; opening a panel switches the MAP MODE to that panel's data), Frostpunk 2 (district panel anchored to the
    district in the world; ALT holds an economy overlay), Humankind (translucent side panels, MAP FOCUS toggle).
    Full-screen is kept for ledgers and comparison (Anno Statistics, EU5 war overview moved TO full screen).

P11. Window silhouette and title plate tell you the kind of thing.
    CK3 (crusade window is a heraldic shield), Anno (dark wooden plaque hanging from the top edge), Victoria 3
    (crimson damask header, emerald round back/close), Old World (red lacquer plaque), Terra Invicta (khaki
    "MISSION CONTROL REPORTS" strip).

P12. One rare accent with one job; role encoded in colour + material.
    Anno 117 (Tyrian purple only for the selected state), Victoria 3 (every button emerald wood; two shades =
    navigation vs action; action buttons add a thin gold border; priority buttons get corner ornament), Anno 1800
    (persistent HUD dark, transient pop-ups bright).

P13. Icons in tiers: illustrated for things, silhouette for stats; monochrome reads as placeholder.
    Victoria 3 (goods/buildings = mini illustrations; techs/events = rendered objects; stats = silhouettes with a
    few colours), Anno 1800 (large illustrated goods icons leading each table row), Old World (painted tech cards).
    Criticism: Anno 117 "black and white" icons felt like "place holders widgets".

P14. Material must separate from the world (figure/ground).
    Frostpunk 2 criticised for a white-tinted UI over white snow; Anno 117 went dark blue because it
    "complemented the in-game world" with strong contrast; HOI4 dark gritty windows over a colourful map.

P15. The UI state itself reports the situation.
    Frostpunk 2 (icons bleed and the UI shifts from white to black "when things are going sideways"), Victoria 3
    (weekday bar filling), Frostpunk 1 (temperature gauge at the top centre dominates when it matters).

P16. Empty and locked states teach instead of hiding.
    Victoria 3 (empty state names what could be here; unavailable buildings shown dimmed in a "Potential" grid),
    EU5 (condition block says why an action is blocked), CK3 (alerts link straight to the fixing action).

P17. Tabs and portraits carry counts and micro-badges.
    CK3 (tabs "Family 12 / Courtiers 19"; portrait badges for opinion +23 / -36, death, title), Victoria 3 (status
    pill over the scene "Impoverished (14)"), Anno (portrait badge with a number).

---

# APPLICABILITY TO PROJECT UNICORN (which screen, what to borrow)

Top bar (Kasa, MRR, Burn, Net, Runway, Marka, Itibar, date, speed):
- CK3 delta-under-value (grey, red only when negative) instead of separate NET column; Vic3 split into a rates row
  (MRR, burn, net) and a stocks row (cash, brand, reputation). Runway as a Frostpunk-style forward ruler in weeks
  (the weeks ahead with marks for payroll, known events, the 4-week shutter countdown). Speed as one instrument
  (Vic3 clock dial) rather than five equal buttons. Frostpunk 1 odometer digits for Kasa would fit mono type.
  Anno 1800 capsules instead of a full-width black bar would let the office show through.

Ekip (roster table):
- Open on a STAGE like CK3/Vic3: a live crop of the team's area of the 3D office (the office is already rendered)
  or the selected employee's bust in their seat; below it the table.
- Row anatomy from Anno Statistics: large portrait leads the row, stacked mini-bars (e.g. skill vs workload),
  numeric columns headed by icons, selected row inverts.
- CK3 portrait micro-badges (morale delta, "leaving" risk, new) and tabs with counts ("Kadro 5 / Gorevler 3").
- Vic3 lens idea: opening Ekip switches the office into a "morale view" (people tinted or tagged by morale), the
  way Vic3 opens a panel and the map mode follows.

Satis (pipeline + customer cards):
- Anno diplomacy arcs: prospects as portraits/logos placed in stage bands (lead -> meeting -> negotiation ->
  signed / churn risk). Relationship becomes a place on screen, not a column.
- EU5 cards: each customer card's satisfaction / seats / MRR chips are also the buttons that act on them.
- CK3 crusade versus layout + tug-of-war bar for a negotiation or a VC meeting (you vs them, one strength bar).
- Vic3 empty state: an empty pipeline names who could be here and how to get them.

Event cards (Frank and others):
- Picture first (Frank's bust or the scene) as in Frostpunk 1/2, Vic3, Old World; category + title; the question
  up top; one bold stakes line; effect chips stay ON the choice buttons (Old World was criticised for hiding them;
  Unicorn already does this). Numbers not words (FP2 criticism).
- Vic3/Old World minimise button to park an event; Terra Invicta-style time icons on buttons (resume vs stay paused).
- Outcomes as CK3-style toasts, not a second modal.
- Old World shows how a literal card metaphor can work (hand, redraw, discard pile) if "event card" is meant as a
  card.

Ticker and notifications:
- CK3 split: notifications (auto-minimise, a few at a time) vs toasts (one at a time, hover pauses). EU5: alerts
  only while a condition holds, discardable, colour-tiered; per-type pause setting. Stellaris: urgency-ordered log
  with a separate tab for high-volume low-urgency items.

Window system over the live office:
- HOI4/Vic3: keep windows narrower and docked so the office stays readable; full screen only for ledgers
  (Anno Statistics, EU5 war overview). Frostpunk 2: small panels anchored to objects in the 3D office (a desk, the
  meeting room) for contextual detail.
- Give each window family its own title plate / silhouette (P11) and put material only on shell and header (P1).
- Figure/ground warning (P14): cream windows over a warm brick-and-cream office risk the Frostpunk 2 white-on-snow
  problem; Anno 1800's rule (persistent chrome dark, transient cards bright) is a tested alternative.

Tone warning from the record:
- Stripping to minimal made Against the Storm feel anonymous; players asked for the "handcrafted, warm feeling";
  the fix was one material + a richer frame, not a new metaphor.
- Heavy chrome is not the answer either: HOI4's artist marked an over-bevelled frame "UGGLY"; CK3 was praised for
  dropping CK2's stonework; Anno 117's elegance did not save weak information access.
