# Yön 2 "Menajer Masası": reference notes

Written before building. Each line: what I take, and what I leave.

## Anchors

**04 FM27 squad, FM27 4-Messages, EN_5-1a-TablesHD, FM24 Steam shots (ref_fm24_sheet.jpg)**
- Take: rows about 20 px at 1080 in FM; ours go to 40 px because each row carries a two line name cell and a bust. Numbers right aligned or centred in fixed columns; the column order never moves.
- Take: FM24 player profile marks the attributes that matter for the role with a tinted band behind the cells. In a grouped table this becomes a vertical band: inside each department group the columns of that department are tinted, so the band steps down the table (Ürün and Tasarım, then Yazılım and Test, then Satış).
- Take: FM24 sidebar, full height, icon plus label per row, everything visible, no hover. Count badges in the row.
- Take: FM27 "control panel" strip at the top of a section: the window's two or three key actions live in one row with the tabs.
- Take: grey caps micro label above a larger value (FM header strip). Used for the window KPIs and the top bar.
- Leave: purple chrome, star ratings, the dropdown carets, the magenta Continue. FM's own colours are club identity, we have no equivalent yet.

**03 F1 Manager 24 panels, cg-06 Finances, 2591280_0 Car Livery**
- Take: the "dark accent visual", a dark layer that sits behind a floating panel and gradiates to transparency toward the 3D scene. Here: veil strongest behind the window, falling off to the right edge where the office stays legible.
- Take: floating components with their own small shadow (BuildHUD, notice, Ofisi taşı become small floating dark panels in one family).
- Take: income in green, outgoing in red, both large; the panel lists the cause under the figure.
- Take: "Continue: To Sponsor Negotiation, 6 days", the time button names its state. Our amber block holds the clock and the speed keys, and in the decision frame turns into "Cevap bekliyor".
- Leave: the "//" title prefix, hex and cross patterns, angled cut corners (those are F1 identity, and patterns are decoration).

**05 OOTP 26**
- Take: values coloured by band (red, orange, grey, green) as text, not as filled pills; portrait cell at the start of a row; the big CONTINUE with a subline.
- Take: header tier and table tier separated by a full width band.
- Leave: the light grey sub-nav bar, the saturated orange progress bars.

## Event card

**08 Victoria 3 event**: picture left, text right, a short rule before the quoted speech, the choice as a full width bar. Take the split and the quote treatment. Leave the damask plate and gold frame.
**07 This Is the Police**: category tab on the card, decision bar split into an action part and the numbers part, numbers big next to the action. Take the bar with the cost inside it.
**06 Frostpunk 2**: the order who, what, price. The price line is the heaviest line of the card.

## Today's screens (baseline ekip.png, olay.png)
- Ekip: 75 stars, name 13 px under a 17 px salary, risk strip at 1.3:1 edge contrast, mono caps everywhere, cream sheet on cream office with no shadow. Fix: numbers with a band, name is the heaviest text of the row, red strip with the person's face, dark panel with a real shadow over a veil.
- Ekip column set kept exactly (ÇALIŞAN, ROLLER as seven skill numbers, LİDERLİK, GÖREV, DENEYİM, DURUM, HUY, MAAŞ, MORAL) and the group order and row order from the data.
- Olay: 24 px Frank, 7 px cost chip, gain and loss in one colour, "SEÇİM KALICIDIR · OYUN DURAKLATILDI" under the buttons. Fix: Frank at 400 px wide, cost is the largest figure on the card (gain green with an up mark, equity loss red with a pie mark), the permanence and pause line sits above the choices, Reddet locked with its reason in sentence case.

## Decisions that bend the brief
- Amber is used for the time block and the one primary button of the open surface only. Selected states (rail item, KADRO tab) are white, not amber, because the shared base outranks the direction table that lists "seçili" as amber.
- Rail badges are red, not amber: both are danger (risk altında, ayrılabilir), and amber is taken.
- Moral 35 to 49 uses the value band orange, not amber.
- Ticker publication names each get their own colour (data, not tokens), amber is not used there.
- Shell grows: top bar 54 to 64 px, rail 84 to 184 px, ticker 34 to 40 px. Office image stays at today's framing (84, 54); the rail and bar sit over its edges.

## Render rounds (ekip_rN.png, olay_rN.png)
- r1: base build. Morale bar overflowed the window (grid 1290 px in a 1254 px body); "%4 HİSSE" wrapped; logo read as a brush; RUNWAY label off the KASA baseline.
- r2: grid widths fixed; off-role skills to neutral ink so colour only marks role cells and Liderlik (35 coloured numbers was an orange field); KASA and RUNWAY on one baseline grid; team lineup in the window header; choice split into a numbers row over an amber action bar.
- r3: lineup tops cut by the frame edge (source busts are flat at the top); gain and loss coded by shape too (up and down arrow); ticker tile narrowed.
- r4: veil changed from a left-to-right wash to a light overall dim plus a halo that hugs the window and falls off in every direction, so the office reads below and right of it; rows 44 to 40 px; group icons; quote wraps without a widow.
- r5: sentence case for buttons and the permanence line (caps only for one or two word labels).

## Revision 2 (after the art director's review), built by build2.py

Source of truth is now build2.py (build.py and patch*.py are revision 1). v1 frames kept as ekip_v1.png and olay_v1.png; rounds are ekip_v2_rN.png and olay_v2_rN.png; measure.sh dumps the DOM and prints overflow.

- r1: warm ramp (#1E1B18 / #27231F / lines #3A342D), dark time block with an amber outline on II, gate as amber frame + dot + amber words, NET under KASA, date and a week bar from x 887, lineup dropped, KPIs 26 px, one skill ramp on every cell, glyph skill heads under a "ROLLER" span, HUY glyph + label, MAAŞ 15/400, Mert dims only face, numbers and bars, Olay rebuilt as an FM inbox (list + reading pane, decision inside the message). Bugs: the grid's spanning separator was auto-placed into column 1; "tag risk" picked up the risk-strip styles.
- r2: both bugs fixed. Grid 6 px wider than the body (moral bar past the inner edge). Office strip mean 0.35 (baseline 0.50, v1 0.26).
- r3: grid fits (DURUM 146); legend became a KPI-style key under the existing word "ROLLER"; veil .26 to .16, strip mean 0.39 to 0.41; inbox rows got a third line from seeded strings so the list is less empty.
- r4: s1 lifted to #968D80 (legend "1-2" was 4.40:1, now 4.77:1); locked rail item dims only icon and name, "YAKINDA" readable; clearer pen-nib glyph; pie with a pulled-out 60 degree slice.

Reverted to the data: straight quotes in Frank's paragraph. Changed casing (needs TR approval): role line in CSV case ("UX/UI Designer"), trait labels in sentence case ("Gerçek lider").
