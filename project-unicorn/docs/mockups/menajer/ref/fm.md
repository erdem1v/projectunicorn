# Sports-management UI research: Football Manager and dense-data peers

Researcher: subagent, 2026-10-01. Area: Football Manager (FM23/FM24 lineage, FM26 redesign, FM27 correction), Out of the Park Baseball 26/27, Motorsport Manager (2016) and Motorsport Manager 2 (in development), Eastside Hockey Manager (2015), F1 Manager 24, Tennis Manager 2019 (Game UI Database).

Conventions
- Every claim carries a URL. "Observed" = I downloaded the screenshot and read it myself. Local copies: `img_fm/` (official SI blog images), `img_steam/` (Steam store screenshots, contact sheets `sheet_<appid>_<n>.jpg`, 4 per sheet: TL=idx 4n, TR=4n+1, BL=4n+2, BR=4n+3), `img_f1m/` (Frontier UI lead's ArtStation breakdown), `img_gudb/` (Game UI Database).
- "Uncertain" = not confirmed by a primary source.
- Our baseline for comparison: `project-unicorn/sandbox/ui_lab/shots/baseline/{ekip,satis,olay}.png` (dark mono top bar with 7 figures, left icon rail with 8 tabs, cream mono-typed windows over the isometric office, centred cream event modal, ticker).

---

## 1. Football Manager 2024 (and FM23): the benchmark players still defend

### Reception anchor
- FM24 holds "Very Positive" on Steam; FM26 fell to "Mostly Negative", 22% positive of 4,000+ reviews. OpenCritic FM24 83 vs FM26 72. https://gamerant.com/football-manager-26-steam-reviews-mostly-negative/
- FM26 daily players fell from ~85,000 at launch to ~32,000 by early Feb 2026, lowest since FM17. https://www.operationsports.com/football-manager-26-is-tracking-as-the-lowest-steam-performer-in-over-a-decade/
- A year later, FM27 coverage still says the community is "not really convinced", pointing out "the UI still doesn't look as good as the FM 24 one". https://realsport101.com/article/football-manager-27-deep-dive-ui-fixes-offer-hope-but-fm-24-shadows-loom

### Layout (observed)
Images (Steam, FM24 app 2252570):
- Player profile: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ce6e4238dd12ec17f43ad48882f7a72f8e10cddf/ss_ce6e4238dd12ec17f43ad48882f7a72f8e10cddf.1920x1080.jpg
- Set pieces (tactics): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ss_b2d729b4d4ac31c6f05134ab88b2b11d61f8cac8.1920x1080.jpg
- Modal over dimmed profile ("Hire an Intermediary"): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/ss_c61172e8694630ce6a22c74aa826341c80975d8d.1920x1080.jpg
- Club overview: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2252570/8fca1244111d1fde9e7793db2de60e83148a3e61/ss_8fca1244111d1fde9e7793db2de60e83148a3e61.1920x1080.jpg

Structure:
- Permanent LEFT SIDEBAR, full height, dark purple gradient, icon + text label per row, 18 destinations all visible at once: Home, Inbox, Squad, Squad Planner, Dynamics, Tactics, Data Hub, Staff, Training, Medical Centre, Schedule, Competitions, Scouting, Transfers, Club Info, Club Vision, Finances, Dev. Centre. No hover needed to see where you can go.
- TOP TITLE BAR: back/forward arrows, entity crest, entity name with a one-line context under it ("Striker (Centre) / AM (RL) - Brighton"), icon row, date block, and ONE saturated button at far right whose label changes (observed "CONTINUE", "SOCIAL FEED", "INBOX" on FM23/FM24 shots).
- SECOND ROW: horizontal sub-tabs with dropdown carets (Overview, Contract, Transfer, Development, Reports, Discuss, Comparison, History).
- Content is one full screen per entity. Pop-ups are rare; the observed modal is a centred panel with the rest of the screen dimmed to roughly 20% brightness, a compact 5-column table and Confirm (orange) / Cancel.

### Player profile (observed, FM24 Welbeck)
- Header strip: portrait, flag, age with birth date, caps/goals, value range chip ("£13M - £14.5M"), wage + expiry, coach star rating for ability and potential.
- Body is a grid of titled panels. Orange caps headings END IN A ">" LINK ("POSITIONS >", "FITNESS >", "DYNAMICS >", "PLANS >", "FORM >", "SEASON STATS >", "CAREER STATS >"): the heading is the doorway to the full screen.
- Attributes: three columns TECHNICAL / MENTAL / PHYSICAL, integers 1 to 20 right-aligned; key attributes for the chosen role are marked with a tinted row band. Position on a mini pitch.
- Micro layout everywhere: small caps grey label over a larger white value.

### Attribute colour scale (observed, FM27 preferences image; the scale itself is long-standing FM)
- Preview row in Preferences > Audio & Visual shows chips 1 (red), 4 (orange), 7 (grey), 10 (white), 12 (olive/yellow), 15 (green), 18 (green), 20 (bright green) with an "Edit Colours" button, labelled "Custom Skin Colour". Image: https://cdn.footballmanager.com/site/2026-09/6-1-Scaling.png
- Same panel: "Scaling Mode: Default / Detailed / Condensed" and toggles "Animate Menus / Animate Reports / Animate Cards".

### Typography
- Default FM24 font is "GT America Standard" according to skinner Rensie, whose skin swaps it for Source Sans Pro; delete the skin's fonts folder to return to default. https://coffeehousefm.com/fmrensieblog/fm24-rensie-custom-skin . Secondary source; GT America is a Grilli Type grotesque (https://www.grillitype.com/shops/gt-america). Treat as likely, not SI-confirmed.
- Skins are XML and user-replaceable; SI publishes base skins each year (https://community.sports-interactive.com/forums/topic/578692-fm24skin-football-manager-2024-base-skins/, title from search, not opened).
- Observed: proportional sans for everything, bold caps for section headings, tabular right-aligned numerals in tables.

### Colour
- FM21: sidebar and title bar take the PRIMARY and SECONDARY colours of whatever object is open (club, nation, competition) instead of fixed purple/black. Source: search snippet of https://www.fmscout.com/c-fm21-skins.html (page not opened; wording uncertain).
- Observed FM24: charcoal body, purple chrome, orange section headings, green/red reserved for state, crest and kit colours carry identity.

### Inbox = the event system (SI's official FM24 manual, read in browser)
https://community.sports-interactive.com/sigames-manual/football-manager-2024/inbox-and-news-r4956/
- "Your Inbox is the main 'hub' of your game world." Every event arrives as a news item.
- Priority is both visual and mechanical: important items get "a red accent colour and a 'Must Respond' label replacing the 'Continue' button". Time cannot advance until you act (confirm a transfer, submit a squad, attend a Board meeting).
- News tab: click a story on the left, it opens in a pop-out panel. Social Feed: short messages from followed objects; the club's supporter spokesperson adds fan reaction, "a distinct layer of colour".
- Volume control: follow/unfollow, frequency Minimal / Normal / Extensive, a pen icon to pick news types by subject, and each social message has a settings icon that explains why you received it.

### FM23 set-piece screens (observed, Steam app 1904540)
- Data Hub modal: radar chart of a player vs league average PLUS a prose insight column ("Marcus Thuram is performing well above average in key statistics for this role..."). https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_a10d66d39ed53279185fddb6a9d3dd22dbf0606e.1920x1080.jpg
- Champions League live draw: full-bleed stadium art, one CTA "START DRAW", and a "LIVE REACTION" strip of fan posts with like counts. https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_48ed70e7d2cceeb71a97d311dc6ee4f7a583b0e1.1920x1080.jpg
- Manager Timeline: career milestones as dated cards ("YOU'RE HIRED", "UPSET WATCH", "GIANT KILLERS") pinned to a horizontal year line over a team photo. https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/1904540/ss_649336c523b42322daf381cde1083583ad2f481a.1920x1080.jpg

### Criticisms inside the FM24-era lineage
- FM21 replaced morale words + coloured arrows with a face icon; critics said the face "means very little" compared with the old words and arrows. Search snippet of https://gamerant.com/football-manager-2021-changes-from-old-games/ (page not opened).
- FM24 was criticised for an inbox flooded with pointless mail; that is why FM25/26 planned the Portal. https://fullerfm.com/2024/07/03/football-manager-25-what-we-know-so-far/ (search snippet).

---

## 2. Football Manager 26: the redesign that failed on usability

### What SI built (official)
https://www.footballmanager.com/fm26/features/fm26s-reimagined-user-interface
- Three principles: "Efficiency, Familiarity, and Predictability".
- "tiles are the component parts of every in-game screen in FM26, providing key snapshots of relevant info. When clicked on, each tile opens up into a Card that carries more detail."
- The Portal "combines the previous Home screen and Inbox"; filters All / New / Tasks / Unread; an Advice dropdown for Coaching, Recruitment, Development, Staffing; fixtures + two-week calendar.
- Sidebar removed; navigation bar at the top with consolidated categories, each opening "an extensive sub-menu".
- Search now finds screens, tiles, messages, guides; FMPedia glossary; Bookmarks (6 curated to start, 24 options; up to 12 on high-res per https://www.footballmanager.com/the-dugout/mastering-fm26-ui).
- Accessibility intent: "correcting unreadable font sizes and defining our colour contrasts". A shared core UI system across PC, console and mobile.
- Images: https://cdn.footballmanager.com/site/inline-images/1%20Mitoma_opt.jpg (player profile), https://cdn.footballmanager.com/site/inline-images/2%20Portal%20Example_opt.jpg (portal), https://cdn.footballmanager.com/site/2025-09/UI%20Feature%20-%2016x9%20watermarked_1.jpg

### Why they changed (developer interview)
https://www.invenglobal.com/articles/23673/fm26-developer-why-we-had-to-change-the-ui
- Ant Farley, Senior Feature Designer: moving to Unity "made it nearly impossible to keep the existing UI".
- They prototyped a WhatsApp-style messenger for news, then reverted to "email on a laptop" because FM was not suited to mobile-style communication.
- The tile system "created more issues than expected regarding usability and accessibility."
- UI implementation was partly co-developed by The Knights of Unity (their portfolio lists "UI development"); SI has not commented. https://www.operationsports.com/development-on-football-manager-26s-ui-was-apparently-outsourced/ , https://theknightsofu.com/projects/football-manager-26/

### Observed (FM26 Mitoma profile and portal)
- Primary nav in a tall condensed bold display face (Portal, Squad, Recruitment, Match Day, Club, Career), sub-nav in small regular sans below. Family unknown.
- Profile keeps the FM attribute grid (Technical/Mental/Physical with coloured value bands) but moves Happiness, Fitness, Form, Discipline, Training into a bottom row of equal-size tiles, each with a coloured headline word ("Excellent", "Good") and a small number.
- Portal: messages list left (sender name small, subject large, time right), news carousel, fixture list, "Next Opposition Report" tile, calendar grid with icons, league table tile. Purple/magenta accent on near-black navy.

### Reception (reviews and players)
- "Take something as simple as checking a league table. In FM24, it took one click. Now? Hover over Competitions → Region → Country → Division → Overview." "big buttons, massive spacing, tiny text, and pop-up panels." "It's death by dropdown." Joanna Z., Absolute Geeks, 6 Nov 2025. https://www.absolutegeeks.com/reviews/football-manager-26-review-a-beautiful-game-trapped-in-an-ugly-interface/
- "Scouting reports, transfer activity, and club news feel more hidden than ever." "the UI makes everything feel distant and disconnected". Operation Sports. https://www.operationsports.com/football-manager-26-review-a-brilliant-game-trapped-in-a-clunky-shell/
- Injury icon "essentially invisible", staff attributes shown only as words ("Good", "Outstanding") preventing quick assessment, attribute graph "relegated to a tiny, useless window", home calendar gone, UI "sluggish and laggy". https://www.altchar.com/reviews/football-manager-2026-review-a-disappointing-step-backwards-a6QHj3y0USb4
- Players: text too small even at the largest setting; font size option "only changes the size of the actual text, not the UI"; "a PC spreadsheet game that is text based that doesn't have the ability to adjust the element sizes". https://steamcommunity.com/app/3551340/discussions/0/603044859897728127/
- "basic information requires too many clicks to reach"; the same button behaves differently in different places; custom skins disabled at launch. https://steamcommunity.com/app/3551340/discussions/0/670600125430831095/
- Patch 26.1.2 (19 Jan 2026) added more nav dropdowns, turned "Stages" and "Season Preview" tiles into full screens, made squad columns rearrangeable. https://www.operationsports.com/fm-26-26-1-2-patch-brings-navigation-enhancements-and-stability-fixes/

---

## 3. Football Manager 27: SI's own correction list (published 22 Sep 2026)

Official deep dive: https://www.footballmanager.com/fm27/features/fm27-clearer-interface-smoother-navigation
Official FAQ (Zachary Whyte, SI Community Team): https://community.sports-interactive.com/forums/topic/611878-fm27-uiux-faq/

- Admitted root cause: "In FM26, the tiles on each screen served two purposes: the presentation of information and navigation." FM27 makes tiles informational; navigation moves to two fixed top bars with dropdowns.
- Primary nav renamed: Portal, Squad, Tactics, Recruitment, Training, Club. Squad goes straight to the squad list, Tactics straight to tactics.
- Landing spots: in Preferences you choose which screen a primary-nav click opens.
- CONTROL PANEL: "a control panel at the top which essentially gathers the key actions you can take in that area" (Squad: Advice, Team Meeting, Responsibilities; Recruitment: staff advice, budgets, recruitment focus, scouting range, delegation).
- "Fewer cards": many cards become full screens "including clear guidance on where next to navigate to".
- Messages "colour-coded based on topic", news shown inside the message, scout reports and transfer offers actionable inside the message, duplicate offers grouped.
- Three scaling modes, Default / Detailed / Condensed, plus ultrawide support where wide tables show more columns.
- Bookmarks get text labels and drag-and-drop order; shortcuts become remappable; some tiles can be swapped for another of the same size.
- Skin colour "still finalising", "factoring in feedback from recent user testing".
- Observed FM27 images:
  - Squad with control panel (three wide action tiles above a dense squad table: checkbox, name, position, value chip, role, age, star Ability/Potential, playing time, flag, wage): https://cdn.footballmanager.com/site/2026-09/2-SquadScreen.png
  - Messages (each row: sender small, subject bold, coloured topic pill right "Transfers", "Competition", "Introduction", "Board", "Jobs", time; unread rows tinted): https://cdn.footballmanager.com/site/2026-09/4-Messages.png
  - Portal HD with tables: https://cdn.footballmanager.com/site/2026-09/EN_5-1a-TablesHD.png ; 4K: https://cdn.footballmanager.com/site/2026-09/EN_5-2a-Tables4K_0.png
  - Competition cards as full-height columns: https://cdn.footballmanager.com/site/2026-09/3-3-Cards.png
  - Scaling preferences: https://cdn.footballmanager.com/site/2026-09/6-1-Scaling.png
  - Portal overview: https://cdn.footballmanager.com/site/2026-09/1-1-portal.png ; sub-nav: https://cdn.footballmanager.com/site/2026-09/1-2-subnav.png

---

## 4. Out of the Park Baseball 26 / 27 (OOTP Developments)

Images (observed):
- OOTP26 player development lab: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_6abcee8d0289cce167f41c07995fab5f7eda27e1.1920x1080.jpg
- OOTP26 draft central: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_2469182ab55bf8c1c31ecef66938dc8a23084785.1920x1080.jpg
- OOTP26 player development plan: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_4ad1a2365e99974c7821cd8994b3ffa1f7fac4db.1920x1080.jpg
- OOTP26 manager's office with "Attention!" modal: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/3116890/ss_79f7bf887defcad981a0ac10826c6413f08bfd41.1920x1080.jpg
- OOTP27 player profile: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4045750/b32cb8827b73fb0c9bd2d4a1ef483e8b7d9c5a09/ss_b32cb8827b73fb0c9bd2d4a1ef483e8b7d9c5a09.1920x1080.jpg

Layout (observed):
- Top menu bar of dropdowns in bold caps: FILE, GAME, <manager name>, <league>, <team>, PLAY.
- Context header: big team logo, team name in large condensed caps with a caret, record line under it ("80-70, .533 PCT, 7½ GB - 2nd in the AL East Division"); a YESTERDAY / TODAY / TOMORROW mini-schedule; a big green CONTINUE button with a subline stating what it will do ("Auto-play until next week", "Play game vs. Mets..."). Header also shows "DO NOT DISTURB".
- Two tab tiers: primary tabs on a dark bar (HOME, ORGANIZATION, PITCHING, LINEUPS, STRATEGY, FRONT OFFICE, PLAYER DEVELOPMENT, SCOUTING, INFO), secondary tabs on a light bar under it. A narrow icon rail on the far right edge.
- Dense data: ratings as number + horizontal coloured bar (colour by value: green/blue high, yellow/orange mid, red low), stars for overall/potential, "Current / Potential" pairs ("55 / 55"), percentile rankings as dot-on-bar with the percentile number in a coloured circle (OOTP27).
- Modal: small centred "Attention!" box with one OK, over the dimmed office screen.

Settings (official wiki): skin ("the colors and fonts, the background"), font, font size, "Use Team Color for Interface", "Use Team Text Color on Labels", "Player Rating Bars" (coloured bars or numbers only), "Dialog Background Effect", "Semi-Transparent Background". https://wiki.ootpdevelopments.com/index.php?title=OOTP_Baseball%3AScreens_and_Menus%2FFile_Menu%2FSettings

Praise: OOTP26 review (Nathaniel Stevens, 2 May 2025): "There's so much thrown at you, yet the information is nicely organized and easily understood." "Their use of information architecture tamed my ADHD". https://digitalchumps.com/out-of-the-park-baseball-26-review-pc/

OOTP27 changes (search summary of the Road to Release ep. 4, page 403 for me): redesigned team schedule, cleaned player search with filtering/sorting, 4K scaling fixes, player profile rearranged with percentile rankings easier to see, hover player popup restyled. https://www.sportsgamersonline.com/games/baseball/ootp-27-road-to-release-episode-4-ux-difficulty-settings/ (uncertain wording).

Criticism (official forum thread "User Interface Changed for the Worse", Jul to Sep 2026, read in browser): https://forums.ootpdevelopments.com/showthread.php?p=5279128
- Custom filter changed from TABS to a DROPDOWN: "causing additional work"; tabs were "so easy to see and change" (pumph). Another user guesses the change was to fit small screens.
- Attribute order changed ("Avoid K above BABIP"): "causing me to retrain the way I look at the screen"; wants to set attribute order himself.
- Player page "a strain to read", "strange choices of color use and spacing of text"; "Colored text on backgrounds that make them unreadable"; OOTP_Classic_Light changed too.
- A moderator (kq76): a 10th of the screen "doing absolutely nothing whereas it could be used to make everything else bigger and more readable".
- Players want the "screen building options" they already have for manager and team home screens on the player card too.

---

## 5. Motorsport Manager (Playsport Games, 2016) and Motorsport Manager 2 (in development, Steam page lists 2027)

Why it matters most for us: MM's management UI sits OVER a live 3D HQ scene, exactly our office-plus-windows setup.

Images (observed):
- HQ (3D base as background, right-side stats panel, bottom nav): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_49297131e20d1919ecf867710d4c7723e823fde7.1920x1080.jpg
- Team select: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_cfa613ab902191e4c167aeb5741b38a89d12e626.1920x1080.jpg
- Part fitting: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_a18ee0c707fb2b4b3bc4ba13986b38b3ea33f085.1920x1080.jpg
- Race screen: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/415200/ss_f7204b853ff940221f8b34b8e7a487ff252f7a95.1920x1080.jpg
- MM2 Home dashboard: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/5fb3732b4891dc662e4d88241f7237500fee181a/ss_5fb3732b4891dc662e4d88241f7237500fee181a.1920x1080.jpg
- MM2 part fitting: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/5c205f6e9d162728bad223bc5416dfadc82230b5/ss_5c205f6e9d162728bad223bc5416dfadc82230b5.1920x1080.jpg
- MM2 pre-race checklist over 3D garage: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/4745600/4c0c4e61f87ccde0057bf74a997759ef6873692d/ss_4c0c4e61f87ccde0057bf74a997759ef6873692d.1920x1080.jpg

Layout (observed, MM 2016):
- Top bar: team wordmark, screen title in caps with a one-line explanation under it ("HEADQUARTERS / Build something, or upgrade your base of operations."), balance pill, standings dropdown, weather, next race countdown ("Next Race in 16 Days, Doha GP"), notification bell with count.
- BOTTOM nav bar with icon + label: Home, Player, Mail, Car, HQ, Team, Drivers, Staff, Pit Crew, Scouting, Finances, Sponsors, Standings, Calendar; red count badges on Mail/Pit Crew/Sponsors; date block and an ORANGE "Continue" button at the far right.
- HQ screen: the 3D base fills the screen; buildings carry floating labels in the scene ("DESIGN CENTRE, Max Level Reached"); a right-side panel holds "New Buildings (7)", "Upgrade Buildings (4)", a bar chart vs championship best/average, and "CURRENT PART KNOWLEDGE" rows with rarity words coloured by tier (GOOD / GREAT / EPIC) plus pip bars ("2/5").
- Race screen: standings table left, driver cards bottom with big position numbers ("3rd"), sector/pace deltas in green/red, fuel/tyre gauges, speed controls centre (pause, x2, x4, x12).
- Part fitting: car blueprint diagram centre, part cards around it with condition bars and "ORIGINAL"/"Missing" labels, radar-like reliability chart.

MM2 (observed, pre-release): Home is a card dashboard (team card with championship bars, next-race card with track art, sponsors as a row of check marks, MAIL card "New Unread Mail 2", cars and drivers cards) plus a right rail "UPCOMING EVENTS & TASKS" grouped by "In 5 Days / In 1 Week / Future"; bottom icon dock; green CONTINUE bottom right. Pre-race: accordion checklist (KNOWLEDGE, SETUP, STRATEGY each with a green check) floating over the 3D garage, progress stepper PRACTICE > QUALIFYING > RACE. Part fitting: big numerals (831, 955) per part card around the 3D car, driver mood chip ("Driver's Setup Opinion: ANGRY").

Reception:
- "With a simple black design and tabs for each department within your racing company, the menu screen looks a lot like commercial business management software rather than a game." Harvard L., 28 Nov 2016. https://www.digitallydownloaded.net/2016/11/review-motorsport-manager-pc.html (read as neutral-to-critical on look, positive on clarity).
- "All of the pertinent information is within reach, so there's never a moment of confusion." Gabriel Jones, 22 Nov 2016. https://www.cubed3.com/games/reviews/pc/motorsport-manager
- "the game interface looks really slick, very easy for a new gamer to understand and navigate". Lorenzo Bonder, 17 Nov 2016. https://www.overtake.gg/threads/motorsport-manager-the-rd-review.128483/
- Metacritic PC 81 (search snippet; https://www.metacritic.com/game/motorsport-manager/).
- Typography: caps geometric/DIN-like sans for titles, team wordmarks in bespoke logotypes. Family unknown (uncertain).

---

## 6. Eastside Hockey Manager (Sports Interactive, 2015)

Images (observed, app 301120):
- Detroit's Front Office (dashboard): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_8765aac9b2406c50eeeaa23d1d14da2c92198e65.1920x1080.jpg
- Nation overview (title bar in Sweden's yellow/blue): https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_86a158974928b74915bfdc11863fb0a42b213182.1920x1080.jpg
- Tactics: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_76a3d1c13f66785980f08b7f43fa6feb4fed5183.1920x1080.jpg
- Draft list: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_c976dc78aaa00f1f89dd317d46f397a964a381d8.1920x1080.jpg
- Calendar with flag game cards: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/301120/ss_5d08bd239fdb1e9958ee23bea49f4b5418e30bc9.1920x1080.jpg

Layout (observed): thin top toolbar (back/forward, home, inbox, manager dropdown, league, world, search, settings, date, green Continue); under it a TITLE BAND FILLED WITH THE OBJECT'S COLOURS (Detroit red, Canada red with flag, Sweden yellow with flag) with a big 3-letter code ("DET", "ST.S", "NAL") and sub-tabs with ">" arrows; content in panels with blue header strips and dropdown carets ("Player Focus", "Team Leaders", "Latest News", "Schedule", "Team Finances", "League Standings"), semi-transparent over a blurred arena photograph. Label/value rows with values coloured by type (links orange, money green, negative red).

Reception (archibalduk, 26 Mar 2015): "The left-hand menu of old has been moved to the top, meaning that each game screen now uses the full width." "The full width screens make a big difference to how the game looks and gives everything a little more breathing space." "The addition of the calendar at the top of every screen ... acts as a shortcut to your team's Schedule screen". "Financial data and player profiles are easier to read." https://gmgames.org/eastside-hockey-manager-ehm-version-1/review/
- Steam: Very Positive, 86% of 1,172. https://store.steampowered.com/app/301120/Eastside_Hockey_Manager/
- Note the contrast: EHM moved nav to the top in 2015 and was praised; FM26 did the same in 2025 and was panned. The difference is not top vs side; EHM kept flat, always-visible destinations and full-width dense screens, FM26 hid destinations behind hover menus and used tiles as navigation.

---

## 7. F1 Manager 24 (Frontier Developments): primary source from the UI lead

Designer breakdown: Aaron Rawlinson, "Associate UI Design Lead at Frontier Developments", ArtStation, 29 Jul 2024. https://www.artstation.com/artwork/XJe96L (project JSON read in browser: https://www.artstation.com/projects/XJe96L.json)
- Stated aim: "improving the UX of the game by reducing the amount of unnecessary nested levels in some of the main Team Management screens", with a very short dev cycle and a small UI team; rework "core shared components".
- Slides (read by me): "FLOATING COMPONENTS ... introduce more floating UI elements ... more dynamic and bespoke feeling layouts". "TOOLTIPS ... improving the visual heirachy of some of our common tooltip components to help present complex amounts of data". "BACKGROUND VARIANTS: shared backgrounds ... subtle animated motion as well as accent shapes"; "DARK ACCENT VISUAL: This is used to overlay a background where needed and gradiate off to transparency. It helps to create contrast or framing for bespoke content on screen...typically when a panel is floating with 3D content behind it." Facilities: "compact modal with truncated information to reduce cognitive load", "more top level state indications". Finances/Board: "Improved visual heirachy of information and organisation of how data is presented ... to make it easier to obtain vital aspects".
- Images: https://cdnb.artstation.com/p/assets/images/images/078/489/081/large/aaron-rawlinson-f1m24-cg-01.jpg (floating components), https://cdnb.artstation.com/p/assets/images/images/078/489/087/large/aaron-rawlinson-f1m24-cg-03.jpg (background variants, dark accent), https://cdna.artstation.com/p/assets/images/images/078/489/084/large/aaron-rawlinson-f1m24-cg-02.jpg (tooltips, finance/mentality components), https://cdnb.artstation.com/p/assets/images/images/078/489/091/large/aaron-rawlinson-f1m24-cg-05.jpg (facilities nesting before/after), https://cdnb.artstation.com/p/assets/images/images/078/489/093/large/aaron-rawlinson-f1m24-cg-06.jpg (finances), https://cdnb.artstation.com/p/assets/images/images/078/489/097/large/aaron-rawlinson-f1m24-cg-07.jpg (board)
- Observed in game shots: every page title is caps with a red "//" slash prefix ("// MENTALITY HUB", "// HOME") and an "?" help key; panels float over 3D rooms (Mentality Hub panel floats over a rendered engineering office); bottom icon dock; top-right "Continue" block names the NEXT STOP and distance ("Continue: To Sponsor Negotiation, 6 days"); finances as a ring gauge with "INCOMING +$10,733,333" (green) and "OUTGOING -$5,982,994" (red) itemised under it; mentality as a ring with segments and a word verdict "(Mostly Positive)", plus "Biggest Issue: Facilities" in red. Steam: https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2591280/ss_063927908ddd1ce983e5868774ae2bf9f53995f7.1920x1080.jpg (Mentality Hub), https://shared.akamai.steamstatic.com/store_item_assets/steam/apps/2591280/ss_94927e87a54233b2afee0a82c3dfd819b1661985.1920x1080.jpg (Home)
- Reception (search summaries of reviews, pages not opened): "unfussy and simple to navigate", "simple-to-read font and contrasting colours", menu-heavy but thoughtful; UI bugs (tutorial pop-ups reappearing). e.g. https://www.thesixthaxis.com/2024/07/29/f1-manager-24-review/ , https://traxion.gg/f1-manager-24-review-third-times-the-charm/ (uncertain attribution of exact quotes).
- Typography: F1 brand display face for titles (likely the Formula1 typeface; uncertain), proportional sans for data.

---

## 8. Tennis Manager 2019 (Game UI Database entry)

GUDB page: https://www.gameuidatabase.com/gameData.php?id=169 (29 screens). Developer: Rebound CG per my recollection (uncertain; GUDB's structured data showed an unrelated studio).
Images (observed):
- Mentor portrait + speech box over the 3D academy: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072923-67084.jpg
- VS pre-match screen: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072924-1933.jpg
- Player summary with radar + four big stat blocks: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073001-47367.jpg
- Home with mentor speech box over the resource bar and cards: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072926-46019.jpg
- "NEW MEMBER!" hire modal with quote, stars, specialty: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073002-76133.jpg
- Match stats mirror bars: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-073003-36075.jpg ; bracket: https://www.gameuidatabase.com/uploads/Tennis-Manager07162020-072925-65895.jpg
Observed style: broadcast graphics (slanted panels, skewed tabs, huge condensed numerals "43", "VS"), top resource bar, a named mentor character (real coach likeness) speaking through a portrait + text box with a single "OK" chevron button, hire events as a celebratory modal with the new person's quote. Reception of the UI not researched (no source).

---

## Cross-game patterns (with the games that show them)

1. ONE LOUD TIME BUTTON THAT ALSO GATES EVENTS AND SAYS WHERE IT GOES NEXT. FM24 (label changes to Inbox/Social Feed; "Must Respond" replaces Continue), OOTP (green CONTINUE + subline "Auto-play until next week"), F1M24 ("Continue: To Sponsor Negotiation, 6 days"), MM/MM2 (orange/green Continue at the end of the nav bar), EHM (green Continue). Our top bar has five equal grey speed chips and no "next stop" line.
2. IDENTITY COLOUR FROM THE OBJECT, NOT FROM THE CHROME. FM21+ recolours title bar/sidebar to the open club/nation colours; EHM title band in team/nation colours with a 3-letter code; OOTP "Use Team Color for Interface"; F1M/MM team cards in livery colours. Chrome itself stays neutral.
3. NUMBERS CARRY COLOUR BY VALUE BAND, CONSISTENTLY AND CONFIGURABLY. FM 1-20 scale (red to bright green, user-editable), OOTP rating bars + percentile dots, MM rarity words GOOD/GREAT/EPIC, F1M green income / red outgoing. Always number or word + colour, never icon alone (FM21 face-icon criticism, FM26 invisible injury icon).
4. STATE WORDS BESIDE NUMBERS AND CHARTS. FM26 tiles "Excellent / Good", FM Dynamics "Good" + one sentence, FM23 Data Hub prose insight beside the radar, F1M "(Mostly Positive)" + "Biggest Issue: Facilities", MM2 "Driver's Setup Opinion: ANGRY".
5. VISIBLE, FLAT NAVIGATION BEATS HIDDEN DEPTH. Praised: FM24 18-item sidebar, EHM full-width top menu, OOTP two tab tiers, F1M24 "reducing unnecessary nested levels". Panned: FM26 hover dropdowns and tiles-as-navigation (one click became five), OOTP27 tabs-to-dropdown. SI's own FM27 fix: tiles are information only, a control panel of the section's key actions at the top, choose your landing screen.
6. PANEL HEADINGS ARE DOORWAYS. FM24 "POSITIONS >", OOTP "[+] More", EHM header strips with carets, FM27 "clear guidance on where next to navigate to".
7. FLOATING PANELS OVER 3D NEED A DESIGNED SCRIM. F1M24 "dark accent visual ... when a panel is floating with 3D content behind it"; EHM semi-transparent panels over a blurred arena; MM2 accordions over a dark garage; OOTP "Dialog Background Effect" / "Semi-Transparent Background" settings; FM24 modal dims the rest to about 20%.
8. MESSAGES ARE THE EVENT SYSTEM, TYPED BY COLOUR, WITH IN-PLACE ACTIONS. FM24 inbox (red accent + Must Respond; News vs Social; volume controls; "why am I seeing this"), FM26 Portal filters All/New/Tasks/Unread, FM27 topic colour pills + act inside the message + grouping, MM Mail tab with badge, MM2 "Upcoming events & tasks" rail by time bucket, OOTP inbox with red "!" markers on the manager's office.
9. DENSITY IS A PREFERENCE, NOT A FIXED DESIGN. FM27 Default/Detailed/Condensed + ultrawide columns, OOTP font/skin/rating-bar settings, FM26 punished for "big buttons, massive spacing, tiny text", OOTP27 punished for dead space and extra scrolling.
10. SET-PIECE MOMENTS GET A DIFFERENT, THEATRICAL REGISTER. FM23 Champions League live draw + fan "LIVE REACTION" cards, FM23 Manager Timeline, FM26 World Cup TV graphics, Tennis Manager "VS" screen, F1M "UP NEXT" track card, MM2 team select hero. The everyday screens stay sober.
11. A NAMED PERSON DELIVERS ADVICE AND EVENTS. FM messages always show the sender's name (staff, board, scout), FM26/27 "Advice" from named backroom staff, F1M Technical Chief card with portrait + mood, Tennis Manager mentor portrait speaking over the 3D academy.
12. DON'T REORDER WHAT PLAYERS HAVE LEARNED. OOTP27 attribute order and FM26 muscle-memory complaints: fix canonical orders early (column order, figure order in the top bar) and let players customise rather than re-shuffle each release.
13. Observation on type: in every screenshot I examined from these games, body and table text is a proportional sans with right-aligned numerals; titles use bold/condensed caps display faces. I saw no monospace UI text in any of them.

## Direct pointers for Project Unicorn screens
- Top bar (KASA/MRR/BURN/NET/RUNWAY/MARKA/ITIBAR + speed chips): patterns 1, 3, 4, 12. One primary "next week" button with a subline naming the next blocking thing ("Frank waiting", "Meeting Thu 10:00"); keep the figure order fixed forever; colour the delta, add the word (runway "Artıda" is already a word; keep that approach for all figures).
- Left rail + windows over the office: patterns 5, 6, 7. Labels are already visible (good, matches FM24/MM). Each tab window could open with a control panel strip of that area's 2 to 4 key actions (FM27) and needs a scrim that separates the cream window from the busy 3D scene (F1M24 dark accent gradient, EHM blurred backdrop) instead of a flat cream sheet over bricks.
- Ekip roster: pattern 3 and FM/OOTP tables. Denser rows, right-aligned tabular numbers, coloured value bands for skills, role-relevant skills highlighted (FM role key-attribute bands), morale as number + word + trend arrow, column order fixed.
- Satis pipeline and portfolio: FM27 message rows (topic pill + one action inline), MM2 "upcoming events & tasks" rail by time bucket, EHM coloured title band per customer company.
- Olaylar and the event modal: patterns 8, 10, 11. An inbox with typed colour pills and Must-Respond gating on the time button (FM24), sender portrait and name (already present for Frank; extend), in-place actions; reserve a theatrical register (FM23 live draw, Tennis Manager VS) for Frank's cheque, VC term sheet and the ending.
- News ticker: FM social feed / FM23 live reaction cards: source name + reaction + small engagement count; "why am I seeing this" affordance.
- Ending screen: FM23 Manager Timeline (dated milestone cards on a year line) as a precedent for the run ledger.
