# Project Unicorn: exact content of the Ekip, Satış and Frank's-offer screens (seed `_seed_theme_surface`, ishani office, 11:00)

All data in this report was read from the code and from the three baseline screenshots in `sandbox\ui_lab\shots\baseline\` (ekip.png, satis.png, olay.png). Nothing was modified. Paths are relative to `C:\Users\erdem\Desktop\project steam\project-unicorn\`. Lines marked "(inference)" were derived, not read directly.

## 0. Seed and frame facts

- **Seed** (`scripts\main\main.gd:636-652`):
  - run_seed 424242, set at main.gd:449-452. `GameState.day = 14`.
  - Product: MVP shipped, B2B market, sub product `saas_ops`. Flags: innovation 45, stability 70, experience 45, `mvp_live_bug_count` 12.
  - Calls `_seed_hr_roster()` and creates three customers with `_shot_customer` (Kuzey İnşaat, Ege Sigorta, Nordica).
  - Spawns two prospects: `spawn_prospect("small","find")` and `spawn_prospect("mid","find")`. Then `SalesSystem.reflect_mrr()`.
- **Company:** "Unicorn Inc.", origin `self_made` (main.gd:224-235).
- **Window geometry** (`sandbox\ui_lab\README.md:75-81`):
  - Ekip: `scenes/tabs/HRTab.tscn`, window 1200×720 at (100,70).
  - Satış: window 1280×760.
  - Olay: `EventModal.tscn` showing card `funding.frank_cheque`. The card is 780 px wide, at least 420 px tall (event_modal.gd:91).
- **Palette:** in the baseline PNGs, "positive" colours draw blue (NET, Artıda, morale ≥50, SAĞLIKLI). This fits the colour-blind palette being on (inference; README.md:93 says the lab follows the player's palette setting).

## 1. TopBar (`scripts\ui\components\top_bar.gd`, `scenes\ui\components\TopBar.tscn`, `scripts\util\fmt.gd`)

Left to right:

1. Amber logo square (`ACCENT_CHROME`, top_bar.gd:53) and "Unicorn Inc." (`GameState.company_name`).
2. **KASA** (`FIN_CAP_CASH`, csv:428; EN CASH) = **$10.000**. Uses `Fmt.money_exact`: full number with grouping; TR separator ".", EN ","; EN "$10,000" (fmt.gd:130-131). Starting cash comes from the origin's `starting_cash` (game_state.gd:747).
3. **MRR** (csv:431) = **$4,0K**. Uses `Fmt.money_chip`: $1K up to $10K gets 1 decimal; $10K and above gets 0 decimals ("$25K"); TR decimal mark ","; EN "$4.0K" (fmt.gd:114-125). The value is 1000 + 1000 + 2000 from the three customers.
4. **BURN** (csv:429) = **$1,5K** plus unit **/ay** (`TOPBAR_UNIT_PER_MONTH`, csv:1600; EN /mo). Source is `daily_burn × DAYS_PER_MONTH` (finance_system.gd:217-224).
   - ⚠ $1,5K does not match the $43.600/month payroll. `daily_burn` is still `FinanceSystem.starting_daily_burn()` (game_state.gd:749); the clock is held so no tick recalculates it (inference).
5. **NET** (csv:430) = **+$2,5K /ay**. Explicit sign, coloured by `delta_color_bright` (top_bar.gd:127-135). 4000 − 1500 = 2500.
6. **RUNWAY** (csv:432) = **Artıda** (`RUNWAY_PROFITABLE`, csv:2; EN "Default Alive").
   - Coloured `positive_bright`; no unit.
   - Hover tooltip `RUNWAY_PROFITABLE_NOTE` (csv:3): TR "Gider gelirin altında; kasa erimiyor. Sayaç, net akış eksiye dönerse işler." EN "Expenses run below revenue; the treasury holds. The clock starts only if net flow turns negative."
   - Rules in `ui_tokens.gd:550-566`: profitable shows the word; under 1 month shows "{n} hafta"; otherwise "{n} ay".
7. **MARKA** (csv:433; EN BRAND) = **50**, plain "%d".
8. **İTİBAR** (csv:434; EN REPUTATION) = **0**.
9. Spacer.
10. **Date line:** "Hafta 14 · Nisan 2026 · 11:00".
    - `TOPBAR_CLOCK` "{date} · {hour}:00" (csv:1488), wrapping `DATE_LINE` "Hafta {week} · {mon} {year}" (csv:409).
    - EN: "Week 14 · April 2026 · 11:00".
    - Below 1600 px wide it switches to the compact form "H14 · Nis · 11:00" (`TOPBAR_CLOCK_COMPACT`, csv:1489; top_bar.gd:161-170).
11. Hidden in this seed: the shutter countdown, the offer countdown and the "PRODUCT_AUTO_STARTED" label.
12. **Phase:** "BOOTSTRAP" (`FIN_PHASE_BOOTSTRAP` "Bootstrap" with raw `to_upper`, csv:423; top_bar.gd:201-206) and three dots, the first one active.
13. **Speed keys:** "II" (`TOPBAR_PAUSE`, csv:1602), "1x", "2x", "3x", "4x" (literals in TopBar.tscn:264-297). In the shots "II" is the active one (clock held).

## 2. Ekip window

**Header row** (hr_tab.gd:86-125):

- Title **"Ekip"** (`HR_PAGE_TITLE`, csv:357; EN "Team"), style PageTitleSerif.
- Summary `HR_SUMMARY` (csv:358): **"ÇALIŞAN 5 · ORTALAMA MORAL 50 · AYLIK MAAŞ YÜKÜ $43.600"**.
  - EN: "HEADCOUNT 5 · AVERAGE MORALE 50 · MONTHLY PAYROLL $43,600".
  - Average: (72+38+61+22+55)/5 = 49.6, rounded to 50. Payroll: 9800+7400+11200+6900+8300 = 43600.
- Placement chips "{n} BOŞTA" and "{n} AŞIRI YÜK" (csv:281-282): not drawn, both counts are 0.
- Hours chip **"09:00–17:00"** (`HR_HOURS_WINDOW` "{start}–{end}", csv:489; this is an en dash), with a clock icon and outline only.
- Amber button **"+ İŞE ALIM BAŞLAT"** (`HR_SEARCH_START`, csv:359; EN "+ Start Recruitment").

**Segments:** **KADRO** (active: ink colour plus 2px amber underline) and **GÖREVLER** (csv:268-269; EN ROSTER / ASSIGNMENTS). A hairline follows.

**Risk strip** (hr_tab.gd:426-442): one strip per employee with morale under 35.

- Warning glyph, **"Selin Kaya"**, then **"MORAL 22"** in the negative colour.
- The text is `tr_upper(HR_COL_MORALE)` + " 22".

**Column headers** (hr_ledger.gd:37-52; csv:258,274,275,259,354,276,355,356):

| TR | EN |
|---|---|
| ÇALIŞAN | EMPLOYEE |
| ROLLER · LİDERLİK | ROLES · LEADERSHIP |
| GÖREV | TASK |
| DENEYİM | EXPERIENCE |
| DURUM | STATE |
| TRAIT | TRAIT |
| MAAŞ | SALARY |
| MORAL | MORALE |

Column widths: roles 256, task 150, experience 72, state 140, trait 56, salary 76, morale 124 (hr_ledger.gd:14-20).

**Groups:** amber uppercase heading plus hairline, in `ROSTER_GROUPS` order (hr_constants.gd:325; csv:270-273).

| TR | EN |
|---|---|
| ÜRÜN & TASARIM | Product & Design |
| GELİŞTİRME EKİBİ | Development |
| SATIŞ | Sales |
| MÜŞTERİ İLİŞKİLERİ | Customer Success |

- The Müşteri İlişkileri group is empty and sits below the fold in the PNG. It shows "Henüz kimse yok" (`HR_EMPTY_ROW`, csv:361) and an "İŞE ALIM BAŞLAT" button (csv:360).
- Row order inside a group: worst badge first, then oldest hire_day (hr_tab.gd:352-359). That is why Deniz comes before Elif and Selin before Mert.

**Skill numbers.** `HRConstants.seed_skills` (hr_constants.gd:274-290): main area = key, secondary = key − 1, every other area = rest, leadership = lead. Stars = points / 2, drawn in half stars (hr_constants.gd:263-265). Displayed cells are the main area, the secondary area, then Leadership (hr_ui_shared.gd:29-65). Area labels: csv:260-266.

**Experience** (hr_ledger.gd:203-220): a 4 px bar plus "%0" for everyone, because experience is 0. Threshold = 40 + 6 × sum of the 7 skill values (hr_constants.gd:903-908).

| Employee | Elif Demir | Deniz Arslan | Mert Yıldız | Selin Kaya | Burak Şahin |
|---|---|---|---|---|---|
| Role id | product_manager | designer | developer | tester | sales_rep |
| Title TR / EN (csv) | Ürün Yöneticisi / Product Manager (464) | UX/UI Designer / UX/UI Designer (465) | Yazılım Mühendisi / Software Engineer (466) | Test Mühendisi / QA Engineer (467) | Satış Temsilcisi / Sales Representative (468) |
| Shown as | ÜRÜN YÖNETİCİSİ | UX/UI DESİGNER (Fmt.upper TR dots the i) | YAZILIM MÜHENDİSİ | TEST MÜHENDİSİ | SATIŞ TEMSİLCİSİ |
| Group | Ürün & Tasarım | Ürün & Tasarım | Geliştirme Ekibi | Geliştirme Ekibi | Satış |
| Displayed skills | Ürün 7 (3.5★) · Tasarım 6 (3★) · Liderlik 6 (3★) | Tasarım 6 (3★) · Ürün 5 (2.5★) · Liderlik 2 (1★) | Yazılım 8 (4★) · Test 7 (3.5★) · Liderlik 3 (1.5★) | Test 5 (2.5★) · Yazılım 4 (2★) · Liderlik 1 (0.5★) | Satış 6 (3★) · Liderlik 2 (1★); no secondary area (hr_constants.gd:93) |
| Full seed skills | product 7, design 6, eng 4, qa 4, sales 4, cs 4, lead 6 | design 6, product 5, eng 3, qa 3, sales 3, cs 3, lead 2 | eng 8, qa 7, product 4, design 4, sales 4, cs 4, lead 3 | qa 5, eng 4, product 3, design 3, sales 3, cs 3, lead 1 | sales 6, product 3, design 3, eng 3, qa 3, cs 3, lead 2 |
| Experience threshold | 250 | 190 | 244 | 172 | 178 |
| Task (GÖREV) | "Yapımda görev alıyor" (`HR_TASK_ON_JOB_BUILD`, csv:481; EN "Working on the build") | same | same, dimmed (on leave) | "Test ediyor" (csv:482; EN "Testing") | "Satışta görev alıyor" (csv:485; EN "Working sales") |
| Status (DURUM) | YENİ chip (hire_day 14) | "—" (`HR_TASK_NONE` fallback, csv:277) | "İzinde · 2 hafta kaldı" (csv:779; EN "On leave · 2 weeks left") | AYRILABİLİR chip (red) | YENİ chip (hire_day reset to 14, main.gd:1372) |
| Trait id | takes_them_under | last_one_out | loyal | double_checker | picks_it_up_fast |
| Trait TR / EN label | GERÇEK LİDER / Takes Them Under (csv:726) | İŞKOLİK / Last One Out (csv:730) | SADIK / Loyal (csv:722) | TİTİZ / Double Checker (csv:728) | ÇABUK KAPAR / Picks It Up Fast (csv:724) |
| Salary | $9.800 | $7.400 | $11.200 (dimmed) | $6.900 | $8.300 |
| Morale | 72 | 38 | 61 | 22 | 55 |
| Morale band | ≥50: green (blue in the PNG) | <50: amber | ≥50 | <35: flight risk, negative colour | ≥50 |

Salary uses `Fmt.money_exact`. Mert's whole row is muted to `TAB_LOCKED_ALPHA` because he is not active (hr_ledger.gd:70, 149-156).

**Status chip details:**

- YENİ: `HR_BADGE_NEW` "Yeni" uppercased (csv:721). It shows while `today < hire_day + 2 weeks` (hr_constants.gd:883, 949-952).
- AYRILABİLİR: `HR_BADGE_FLIGHT_RISK` "Ayrılabilir" (csv:521; EN "At risk of leaving").
- Leave line: `HRSystem.leave_line` (hr_system.gd:424-428). Mert was sent on leave for `LEAVE_WEEKS` 2 (hr_constants.gd:1032; main.gd:1370).

**Trait cell:**

- Only a 26 px icon box is drawn, from `res://assets/icons/traits/<id>.svg` (hr_ui_shared.gd:18-21, 169-189).
- Hover tooltip is "label\neffect". Effect texts (csv:723-731):
  - GERÇEK LİDER: "Sorumlusu olduğu alanda herkes daha hızlı öğrenir; ayrılıkları ağır alır."
  - İŞKOLİK: "Mesai morali onda çok daha yavaş erir."
  - SADIK: "Moral düşükken bile kolay kolay ayrılmaz; rakip teklifine dayanır."
  - TİTİZ: "Geliştirmede çok daha az hata çıkarır, ama yavaş çalışır."
  - ÇABUK KAPAR: "Deneyimi belirgin şekilde hızlı kazanır."

**Morale:** a 92×6 bar plus the number, coloured by band (hr_ui_shared.gd:196-246). Thresholds in `hr_constants.gd`:

- `MORALE_FLIGHT_RISK` 35 (line 860): below it the employee gets the Ayrılabilir chip, the red strip, the rail badge and sorts first.
- `MORALE_BAND_LOW` 50 (line 817): below it, amber colour and −15% speed (×0.85).
- `MORALE_BAND_HIGH` 80 (line 816): at or above it, +10% speed.
- Resignation: a dice roll after 2 weeks of flight risk; certain at 3 weeks (lines 1008-1009).
- New hires start at morale 75 (line 861).
- **There is no "burning out" threshold in the engine.** The glossary has the term "Tükeniyor / Burning out" (localization_glossary.md:88), but no constant or code exists for it. The only "tükeniyor" is a comment at main.gd:1334.
- There are no CSV words for the morale bands (I searched and found none).

**Row tooltip:** the role hint, for example "Ne yapılacağına karar verir, ekibi aynı hedefe bakar tutar." (csv:738-743).

## 3. Satış window (`scripts\tabs\sales_tab.gd`)

- **Title:** "Satış" (`TAB_SALES`, csv:417).
- **KPI strip** (sales_tab.gd:120-135; csv:93-96):

| TR label | EN label | Value |
|---|---|---|
| MÜŞTERİ | CUSTOMERS | 3 |
| ORT. MEMNUNİYET | AVG. SATISFACTION | %56 (EN "56%"): (25+72+72)/3 |
| BU AY KAZANILAN | GAINED THIS MONTH | +0 |
| BU AY NET | NET THIS MONTH | 0 |

- **Price stance:** card "Fiyat duruşu" (csv:2261; EN "Price stance") with buttons Rekabetçi / **Standart** (active) / Premium (csv:2262-2264; EN Competitive / Standard / Premium). Hover hints (csv:2265-2267):
  - Rekabetçi: "Koltuk fiyatı bandın altında. Masa kolay açılır."
  - Standart: "Koltuk fiyatı bandın ortasında."
  - Premium: "Koltuk fiyatı bandın üstünde. Temsilcinin işlemesi uzar."
- **Pipeline head:** "BORU HATTI" (csv:2240; EN PIPELINE), and on the right **"Akış: 6,5/hafta"** (`SALES_FLOW_RATE`, csv:2242; EN "Flow: 6.5/week").
- **Prospects**, sorted by stars descending (sales_tab.gd:190-194). Size mapping is small = 1★, mid = 2★ (spawn_prospect, sales_faucet_system.gd:256-257).
  1. **Karadeniz Fabrika**, 2★ of 5, "1 hafta" (`SALES_DAYS_LEFT`, csv:2243; dim, not urgent).
     - Persona `ops_cautious`, which covers logistics, construction and manufacturing (inference from archetype sectors).
     - Line: **"PH: Ölçülü bir alıcı. Önce kararlılığı sorar."** / EN "PH: A measured buyer. Stability comes first." (csv:2306).
  2. **Efes Emlak**, 1★, "1 hafta".
     - Persona `finance_brisk` (real_estate sector, inference).
     - Line: **"PH: Hızlı konuşur, rakama erken gelir."** / EN "PH: Talks fast, gets to the number early." (csv:2308).
  - Buttons on each card: "Ayır", "Temsilciye ver", and amber "Görüşmeye git" (csv:2246, 2247, 2245; EN Reserve / Give to a rep / Go to the meeting).
  - No whale line, no above-league line and no routing badge appears.
- **Sales desk:** "SATIŞ MASASI" (csv:2252).
  - **Burak Şahin** 3★ (sales 6).
  - "Çalıştığı bant:" (csv:2255) followed by [1★] [2★] [3★] [**Kendi ligi**], with Kendi ligi active (csv:2256-2257; EN "Working band:" / "Own league").
  - No "ile görüşüyor" line. The "SON HAREKETLER" log is hidden because the log is empty.
- **Portfolio:** "MÜŞTERİ PORTFÖYÜ" with "3 müşteri" (csv:91-92). Order is risk, then expansion, then the rest (sales_tab.gd:28, 410-411). Card stars = `c.scale` = 3★ for all (main.gd:1833). Meta line format is `Fmt.money` + "/ay" · "{n} koltuk" · "{n} aydır müşteri" (sales_tab.gd:551-566; csv:100-102).
  1. **Ege Sigorta** (attention card).
     - Chip **RİSK ALTINDA** (csv:109; EN AT RISK).
     - Meta: "$1,0K/ay · 12 koltuk · 2 aydır müşteri". Seed: MRR 1000, 12 seats, acquired 9 weeks ago, satisfaction 25.
     - Italic line: "Sebep: sık kesinti şikayeti" (csv:115-116). Chosen because flag bugs 12 > `COMPLAINT_BUG_GATE` 6 (b2b_constants.gd:46).
     - No churn line: `set_churn_countdown` runs only in `--sales-shot`, not in this seed.
     - "Müşteri temsilcisi: —" (csv:112, dash literal at sales_tab.gd:501) with [Değiştir] (csv:133), then amber **"İlgilen →"** (csv:119; EN "Check in →").
  2. **Nordica**.
     - Chip **BÜYÜMEK İSTİYOR** (csv:110; EN WANTS TO GROW).
     - Meta: "$2,0K/ay · 20 koltuk · 6 aydır müşteri" (seed 2000, 20 seats, 26 weeks, satisfaction 72).
     - Line: "Başka departmana yaymak istiyor." (csv:118).
     - Steward line plus [Değiştir], then **"Değerlendir →"** (csv:120; EN Evaluate).
  3. **Kuzey İnşaat**.
     - Chip **SAĞLIKLI** (csv:108).
     - Meta: "$1,0K/ay · 12 koltuk · 3 aydır müşteri" (seed 1000, 12 seats, 13 weeks, satisfaction 72).
     - Steward line plus [Değiştir]. No action button.

## 4. Frank's offer card (`data\events\cards\funding\frank_cheque.json`, `scripts\modals\event_modal.gd`)

- **Header:**
  - Accent badge "MENTOR" (`EVENT_TAG_MENTOR`, csv:1527). The speaker is `char_mentor_frank` (event_modal.gd:210-211).
  - Then `tr_upper(EVENT_DECISION_DAY)` "KARAR · {date}" (csv:1521): **"KARAR · HAFTA 14 · NİSAN 2026"**.
  - EN: "MENTOR" + "DECISION · WEEK 14 · APRIL 2026".
  - The card has no subtitle.
- **Title:** `ANGEL_EVENT_TITLE` "Frank'in teklifi" / "Frank's offer" (csv:369).
- **Body** (`ANGEL_EVENT_BODY`, csv:370-382), four paragraphs:
  - TR:
    1. "Ürün para kazandırmaya başladı."
    2. "Arayan yine Frank."
    3. "Buraya kadar kendi birikimin ve emeğinle geldin. İşleri hızlandırman için yirmi beş bin dolar koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?" (inside quotes)
    4. "Cevap bekliyor."
  - EN:
    1. "The product has started making money."
    2. "Frank again."
    3. "You got this far on your own savings and your own work. I'll put in twenty-five thousand to speed things up, and I'll take four percent. No haggling. I'm asking once: do you want it?" (inside quotes)
    4. "He waits for an answer."
- **Speaker line** (event_modal.gd:221-241):
  - 24 px portrait `res://assets/art/investors/portrait_frank.webp`.
  - "**Frank Köseoğlu · Operating Partner**": `MENTOR_NAME` (csv:1559) plus `HR_ROLE_MENTOR`, which is "Operating Partner" in both TR and EN (csv:470).
  - Relation pill **"NEUTRAL"**: the raw `c.relationship` value "neutral" (character.gd:100) uppercased by `make_pill`, neutral palette.
  - Frank has no traits, so no trait badges.
- **Option 1:** "Kabul et" / "Accept" (csv:383).
  - Accent chip from `ANGEL_CHIP_ACCEPT` "Nakit {cash} · Frank'e %{equity} hisse" (csv:386), uppercased: **"NAKİT +$25K · FRANK'E %4 HİSSE"**.
  - EN: "CASH +$25K · 4% TO FRANK".
  - Values: `CASH_AMOUNT` 25_000 and `EQUITY_PCT` 4 (angel_round_system.gd:28-29), formatted by `_fmt_money_delta` (event_modal.gd:415-419, 453-454).
- **Option 2:** "Reddet" / "Refuse" (csv:384), locked.
  - Drawn at alpha 0.5. Chip `ANGEL_CHOICE_REFUSE_LOCK` "Zor modda açılır." / "Unlocks in hard mode." (csv:385), shown as **"ZOR MODDA AÇILIR."**
  - The lock requires the `funding.hard_mode` seam (frank_cheque.json:46-54; event_modal.gd:330-340).
- **Footer:** hairline, then `EVENT_CHOICE_PERMANENT` uppercased: **"SEÇİM KALICIDIR · OYUN DURAKLATILDI"** / "THE CHOICE IS PERMANENT · GAME PAUSED" (csv:1520).

## 5. Ticker, notice card, BuildHUD card, rail

- **Ticker** (news_ticker.gd:97-132):
  - The stream is empty, so the cold-start pool `TICKER_01..10` fills the loop to 8 items.
  - The starting offset depends on seed and day; it is 3 here (consistent with the PNG).
  - Outlet = `OUTLET_KEYS[k % 4]`, i.e. 0 Ekonomi Postası, 1 TeknoGündem, 2 Girişim Bülteni, 3 Sektör Telgrafı (news_feed_system.gd:60-61; csv:527-530).
  - The outlet name is drawn in the accent colour. Separator is "   ·   ".
  - Order, TR (csv:170-179):
    1. Sektör Telgrafı: "Teknoloji kampüslerinde staj kontenjanları rekor kırdı."
    2. Ekonomi Postası: "Sunucu kiralarında indirim sezonu; altyapı ekipleri pazarlıkta."
    3. TeknoGündem: "Sanayi bölgelerinde dijital dönüşüm ihaleleri sıraya girdi."
    4. Girişim Bülteni: "Melek yatırım ağları yeni dönem başvurularını açtı."
    5. Sektör Telgrafı: "Yazılım ihracatçıları yeni pazar arayışında; fuar takvimi dolu." (inference: past the edge of the PNG)
    6. Ekonomi Postası: "Ofis pazarında küçülme sürüyor; paylaşımlı katlar dolu."
    7. TeknoGündem: "Teknoloji basınında değerleme sohbeti hiç bitmiyor."
    8. Ekonomi Postası: "Tohum yatırımcıları takvim dolduruyor; erken aşamada trafik yoğun."
  - EN versions are in the same csv rows.
- **Notice card** (bottom right; desk_papers.gd:51-52):
  - A dot in `health_green`, tag `Fmt.upper("Nordica")`, which renders **"NORDİCA"**, then `DESK_PAPER_EXPANSION_TITLE` **"Büyüme talebi masada"** (csv:151; EN "Expansion request waiting").
- **"Ofisi taşı" button** (bottom left): `OFFICE_MOVE_BTN` (csv:2586; EN "Move the office").
- **BuildHUD card** (build_bar.gd:172-209; build_bar_model.gd:33-46):
  - "Unicorn Inc. v1": `mvp_product_name` is empty, so the company name is used, plus the version label.
  - "DESTEK" (`BUILD_PHASE_SUPPORT`, csv:460) and "DOĞRULANMIŞ 0" (`BUILD_SUPPORT_CONFIRMED`, csv:461). The 0 comes from `ProductState.bugs_confirmed()`.
    - ⚠ This conflicts with the flag value 12 that drives Ege's outage reason. They are two different sources.
  - "▸ DÜZELTME BAŞLAT" (`PROD_FIX_RUN_START` "Düzeltme başlat", uppercased, csv:1118).
  - EN: "SUPPORT · CONFIRMED 0 · START A FIX RUN". The "%" label is hidden.
- **Rail** (csv:414-422; left_tabs.gd):

| Tab | TR label | EN label | Badge |
|---|---|---|---|
| Product | Ürün | Product | none |
| Sales | Satış | Sales | 1 (risk accounts: Ege; b2b_sales_system.gd:322-328) |
| HR | Ekip | Team | 1 (employees with a badge: Selin; hr_system.gd:406-411) |
| Finance | Finans | Finance | none |
| Personal | Kişisel | Personal | none |
| Marketing | Pazarlama | Marketing | locked: alpha, "YAKINDA" pill (`SYS_SOON`, csv:225) |
| R&D | Ar-Ge | R&D | none |
| Events | Olaylar | Events | none |
| Settings (gear) | Ayarlar | Settings | none |

## 6. LANGUAGE INTEGRITY LAW problems on these screens today

1. **"TRAIT"** column header: `HR_COL_TRAIT` = "TRAIT" in TR (csv:276). The CSV already has `PER_TRAITS` "HUYLAR" / TRAITS (csv:307), and the code calls them "huy" (hr_constants.gd:395-398). A singular "HUY" key does not exist. The glossary has no row for this.
2. **"NEUTRAL"** relation pill: the raw enum is printed (event_modal.gd:238-239). The glossary gives **NÖTR / NEUTRAL** and notes "bugün ham enum basılıyor" (localization_glossary.md:118). No CSV key exists for any relationship value (ally, friendly, neutral, wary, hostile).
3. **"Operating Partner"**: `HR_ROLE_MENTOR` TR is "Operating Partner" (csv:470). The glossary says "BYTE-EXACT, çevrilmez" (glossary:85). But `MENTOR_ROLE` TR = **"OPERASYON ORTAĞI"** (csv:1560, used in MentorIntroModal.tscn:88), and the term is not in CLAUDE.md's loanword list. ⚠ The CSV and the glossary contradict each other, so this needs the owner's decision.
4. **"UX/UI DESİGNER"**: `HR_ROLE_DESIGNER` TR "UX/UI Designer" (csv:465), and Fmt.upper also produces a dotted İ. The glossary says **Tasarımcı** (glossary:81). Other role titles also differ from the glossary:

   | Role | CSV now | Glossary |
   |---|---|---|
   | Developer | Yazılım Mühendisi | Yazılımcı |
   | Tester | Test Mühendisi (EN "QA Engineer") | Test Uzmanı; EN "QA Engineer" explicitly rejected (glossary:82) |
   | Sales rep | Satış Temsilcisi | Satış Uzmanı (glossary:83) |
   | Customer rep, EN | Customer Success Manager | Account Manager (glossary:84) |

5. **"NORDİCA"**: `Fmt.upper` applies the Turkish i→İ rule to a proper name (desk_papers.gd:51). Proper names must not change; it should read "NORDICA" (this is an interpretation of the rule). There is no CSV entry; the fix would be in code.
6. **Other on-screen violations:**
   - Placeholder prefixes "PH:" on all three persona lines (csv:2306-2308).
   - Dashes, which no player text may contain:
     - "—" in Deniz's DURUM cell (csv:277).
     - "Müşteri temsilcisi: —" (literal at sales_tab.gd:501).
     - "09:00–17:00" (csv:489).
   - Uncertain: TR "Premium" (csv:2264) is not on the loanword list; the glossary only has "üst segment" for salary bands.
7. **Glossary mismatches** (Turkish on both sides):

   | Item | Glossary | CSV |
   |---|---|---|
   | Rail HR tab | İK (glossary:98, 136) | "Ekip" |
   | Flight risk | "Kaçma riski" (glossary:88) | "Ayrılabilir" |

8. **Allowed as written:** BURN, RUNWAY, NET, MRR, Bootstrap (gate decision 3), churn, the outlet mastheads, and company and person names.