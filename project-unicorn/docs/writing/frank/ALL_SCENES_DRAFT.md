# Frank Voice Pass · Phase 2 · ALL SCENES DRAFT (raw material for editorial)

Rows 7 to 25 in Erdem's numbering, run-chronological. Rows 4 and 6 are delivered in their own files; row 3 is blocked on the Build Bar tree; rows 2, 5 and 26 are cut. Plain text on purpose: the skeleton and the whitelist are the deliverable, the prose says what the card needs and nothing more, and Erdem and the director rewrite it. **Aphorism ledger: 0 / 2 spent across this whole draft.**

Standing rules applied throughout: no dashes in any body (em, en, or hyphen between clauses); no time of day in any hour-00 daily beat (that is every row here except none; all are daily beats or standing strips); no weekdays, minutes, weather, seasons, neighbourhoods, schedules; Frank never names the founder; Frank holds 0 % before row 10 and exactly 4 % after, equity never debt; Frank is never in "ekip"; every number is a constant or a live value (placeholders only where the builder already formats them, otherwise flagged `[COND?]`); TR first, EN mirrors the images.

Surface classes: **Scene** (a real decision, 4 to 8 lines) · **Confirmation card** (confirms something already chosen, 3 lines including the option) · **Gift card** (the player did nothing, the card opened, the world changed, 4 to 6 lines) · **Standing strip** (repaints on every visit or lever pull; one or two sentences; true across the whole band).

---

## 7 · `ev_ps_b2c_paid_tier`

**Class:** gift card in shape; structurally defective (A: says without doing, B: gives without placing). 4 lines + option.

**Skeleton.** JSON beat, daily slot 7, hour 00. Trigger `market_type == "b2c" ∧ audience_above 15` (float), one_shot live. Speaker Frank, subtitle "Mutfak masası" (clock-free). Options today: 1 → `mentor_advisory` only (no chip, no price, no tier). Render risks: the paid tier being still closed is not provable (no `flag_unset`); audience is "> 15", not "a few hundred"; MRR is 0 while the tier is closed.

**Whitelist used.** Product live (`mvp_shipped`); market B2C; `b2c_audience > 15.0` (live float, not printed); the price ruler exists in Product and the default price constant is 15 (`B2C_PRICE_DEFAULT`, not asserted as set). Not used: the exact audience, hour, day, founder name, MRR.

**TR**
Ürün yayında; deneyenler var, sayfada görüyorsun.

Telefon, Frank.

"Kullananlar var, ödeyen yok. Fiyat koymayacak mısın?"

→ **Fiyatı koy**

**EN**
The product is live; people are trying it, you can see them on the page.

The phone. Frank.

"People are using it and nobody is paying. Aren't you going to put a price on it?"

→ **Set the price**

**Notes.** Ledger 0/2. Option: `[VOCAB?] navigate_to_tab{tab: "product"}` (the ruler lives there) + `mentor_advisory` (payload in row 22); the alternative that exists today is `open_paid_tier{price: 15}`, which sets the default price without the ruler. `[COND?]` "ödeyen yok" needs `b2c_paid_tier_open == false` at fire (not provable today).

---

## 8 · `ev_ps_first_revenue`

**Class:** confirmation card (the revenue came from the player's sale or price; the card acknowledges). 3 lines including the option.

**Skeleton.** JSON beat, daily slot 7, hour 00. Trigger `mrr_above 0`, one_shot live, priority 8. Subtitle "Kasadar bildirimi" (clock-free). Options today: 1 → `mentor_advisory` only. Render risk: collides the same morning with the Traction gate (both need MRR > 0); this card wins the modal and the gate queues behind it, so two Frank cards in a row.

**Whitelist used.** MRR > 0 for the first time; ≥ 1 active customer record (B2B account or the B2C userbase record); market known but not printed; Kasadar is the payment provider (canon). Not used: amount, payer's name, hour, counts.

**TR**
Kasadar bildirimi: ilk ödeme geldi. Frank'ten mesaj var.

"Gördüm. Aynısını bir daha yapabilir misin?"

→ **Tamam**

**EN**
A Kasadar notice: the first payment is in. There's a message from Frank.

"I saw it. Can you do the same again?"

→ **All right**

**Notes.** Ledger 0/2. The question is the Traction gate's question and the gate fires the same morning; see STRUCTURAL_DEFECTS (G, collision). `mentor_advisory` payload in row 22; `[COND?]` `_en` sibling.

---

## 9 · `ev_phase_gate_traction` (3 bodies)

**Class:** scene (a real decision: advance or not). Body 0: 5 lines + options. Bodies 1 and 2: 3 lines + options.

**Skeleton.** `PhaseGateSystem`, daily slot 8, hour 00. Open when `mvp_shipped ∧ customer_count_min 1 ∧ mrr_above 0`; held while the shutter runs; re-prompt every 5 days (`REMIND_INTERVAL_DAYS`); body index = `gate_declines` clamped to 2. Options: `GATE_ADVANCE` → `advance_phase` (no chip) · `GATE_DECLINE` → `phase_gate_decline` (`gate_declines += 1`, re-prompt; no chip, no penalty). Badge MENTOR (`phase_gate` tag). Title `GATE_TRACTION_TITLE`.

**Whitelist used.** Product shipped; at least one customer; MRR > 0; phase 1; `gate_declines` (0, 1, 2+) selects the body; Frank holds 0 %. Not used: employees, cash, runway, customer count beyond one, hour, day.

**TR · body 0**
İlk müşteri listede, MRR sıfırın üstünde.

Telefon, Frank.

"Bir şey sattın. Bundan sonrası Traction: daha çok müşteri, daha çok iş, geri dönüşü yok. Geçiyor muyuz?"

→ **Geçelim** · → **Henüz değil**

**TR · body 1** (one decline)
Frank yine arıyor.

"Rakamlar aynı, soru aynı. Geçiyor muyuz?"

→ **Geçelim** · → **Henüz değil**

**TR · body 2** (two or more declines)
Frank.

"Beklemek de karar. Geçiyor muyuz?"

→ **Geçelim** · → **Henüz değil**

**EN · body 0**
The first customer is on the list, MRR is above zero.

The phone. Frank.

"You sold something. From here it's Traction: more customers, more work, no way back. Are we going?"

→ **Let's go** · → **Not yet**

**EN · body 1**
Frank is calling again.

"Same numbers, same question. Are we going?"

→ **Let's go** · → **Not yet**

**EN · body 2**
Frank.

"Waiting is a decision too. Are we going?"

→ **Let's go** · → **Not yet**

**Notes.** Ledger 0/2 ("Beklemek de karar" is the shipped line's idea kept flat; if editorial reads it as an aphorism, replace with "Karar senin."). Option labels replace the shipped dashed label on `GATE_ADVANCE`. Body 1 does not say how many days passed (5 is a constant but the shutter can hold it longer).

---

## 10 · `ev_angel_frank_seed`

**Class:** scene (one real option; REDDET visible and locked). 6 lines + options.

**Skeleton.** `AngelRoundSystem`, daily slot 8a, hour 00. Trigger `mvp_shipped ∧ mrr_above 2499` (MRR ≥ $2.500, constant `MRR_THRESHOLD`); latch `angel_seed_offered` set before enqueue. Options: `KABUL` → `angel_accept` (atomic: +$25.000 cash, 4 % to Frank, ledger row, chip "Nakit +$25.000 · Frank'e %4 hisse") · `REDDET` locked on `hard_mode_unlocked` (no writer), reason line "Frank'siz yol. Zor mod, henüz değil." Badge today PİYASA (fix pending). Title `ANGEL_EVENT_TITLE`.

**Whitelist used.** MRR ≥ 2.500 (constant threshold, guaranteed crossed); product shipped; ≥ 1 customer; Frank holds 0 % at this instant; $25.000 and 4 % are constants; the cheque is written only on accept. Not used: employees, phase, cash, hour, day.

**TR**
MRR iki bin beş yüzü geçti; rakam ekranda.

Telefon, Frank.

"Buraya kadar kendi paranla geldin. Yirmi beş bin koyuyorum, yüzde dört alıyorum. Pazarlık yok. Bir kere soruyorum: alıyor musun?"

Cevap bekliyor.

→ **Kabul et** · → **Reddet** (kilitli: "Frank'siz yol. Zor mod, henüz değil.")

**EN**
MRR has passed two thousand five hundred; the number is on the screen.

The phone. Frank.

"You got this far on your own money. I'm putting in twenty-five thousand and taking four percent. No haggling. I'm asking once: do you want it?"

He waits for an answer.

→ **Accept** · → **Refuse** (locked: "The road without Frank. Hard mode, not yet.")

**Notes.** Ledger 0/2. "Kendi paranla" is true in the demo (self_made is the only origin and no other money exists before this card). "Cevap bekliyor" is the one narration line and can be cut.

---

## 11 · `ev_angel_hire_nudge`

**Class:** gift card in shape; structurally defective (A: advice only, B: should place the player in HR). 4 lines + option.

**Skeleton.** `AngelRoundSystem`, daily slot 8a, hour 00, priority 3. Trigger `angel_seed_accepted_day > 0 ∧ day ≥ accepted + 2 ∧ employees == 0`; latch `angel_nudge_shown`; burned silently if a hire happened. Option today: `Bakacağım`, no modifiers. Render risks: an Atlas search may already be open (not checked); the p3 card can take the modal ahead of a p10 gate.

**Whitelist used.** The cheque was taken; the $25.000 is in the till; Frank holds 4 %; employees == 0; the HR rail badge is lit. Not used: HR search state (unknown), exact cash, hour, day.

**TR**
Para kasada. Çalışan listesi boş.

Frank'ten mesaj.

"Hâlâ tek başınasın. Kiminle konuştun?"

→ **İK'ya git**

**EN**
The money is in the till. The staff list is empty.

A message from Frank.

"You're still on your own. Who have you talked to?"

→ **Go to HR**

**Notes.** Ledger 0/2. Option: `[VOCAB?] navigate_to_tab{tab: "hr"}`. `[COND?]` HR search state: if a search is already open or files are waiting, "Kiminle konuştun?" is wrong; the scene needs `hr_search.state` readable at fire, or the nudge skipped when a search exists. Frank's 4 % is not mentioned; it is equity, not a reason to nag.

---

## 12 · `ev_phase_gate_series_a` (3 bodies)

**Class:** scene. Body 0: 5 lines + options; bodies 1 and 2: 3 lines + options.

**Skeleton.** `PhaseGateSystem`, daily slot 8, hour 00. Open when `mrr_above 4999 ∧ brand_above 24` (MRR ≥ $5.000, brand ≥ 25; runway deliberately excluded); held while the shutter runs; re-prompt every 5 days; body index = `gate_declines` clamped to 2. Options as row 9. Title `GATE_SERIES_A_TITLE`.

**Whitelist used.** MRR ≥ 5.000; brand ≥ 25; phase 2; decline count; four VC tables exist in the roster once the hunt opens (`InvestorRegistry`, 4 pitchable + 1 locked). Not used: runway, employees, angel state, hour, day.

**TR · body 0**
MRR beş bini geçti, marka yirmi beşin üstünde; ikisi de ekranda.

Telefon, Frank.

"Series A avı açılıyor. Dört masa var, takvim işliyor. Gidiyor muyuz?"

→ **Gidelim** · → **Henüz değil**

**TR · body 1**
Frank yine arıyor.

"Masalar sonsuza kadar açık kalmaz. Gidiyor muyuz?"

→ **Gidelim** · → **Henüz değil**

**TR · body 2**
Frank.

"Beklemek de karar. Gidiyor muyuz?"

→ **Gidelim** · → **Henüz değil**

**EN · body 0**
MRR has passed five thousand, the brand is above twenty-five; both are on the screen.

The phone. Frank.

"The Series A hunt is opening. Four tables, and the calendar is running. Are we going?"

→ **Let's go** · → **Not yet**

**EN · body 1**
Frank is calling again.

"Tables don't stay open forever. Are we going?"

→ **Let's go** · → **Not yet**

**EN · body 2**
Frank.

"Waiting is a decision too. Are we going?"

→ **Let's go** · → **Not yet**

**Notes.** Ledger 0/2. "Dört masa" is the roster constant (4 pitchable VCs), not the cascade rule (3 closed tables end the road); the two numbers must not be confused in one line. "Takvim işliyor" refers to the Day 180 fork, not to a time of day. Body 2 repeats row 9's body 2 by design (shipped escalation reuse); editorial may want them to differ.

---

## 13 · `ev_vc_meeting_prompt`

**Class:** scene (enter or forfeit). 4 lines + options. Structural defect C (investor line quoted inside a Frank card) removed in this draft.

**Skeleton.** `VCPitchSystem`, daily slot 8b, hour 00. Trigger: a booked meeting for `{investor}` whose day has come; `prompted` latch. Options: `VC_EV_ENTER_MEETING` → `start_vc_meeting{vc_id}` (opens MeetingScene; no chip) · `VC_EV_SKIP_MEETING` → `decline_vc_meeting` (clears the meeting; **no chip**). Builder formats `{investor}`. Title `VC_EV_MEETING_TITLE`.

**Whitelist used.** A meeting with a named VC is booked for today; prep state exists but is not printed. Not used: hour, readiness, outcome.

**TR**
Takvimde bugün: {investor}.

Frank'ten mesaj.

"Randevu günü. Giriyor musun?"

→ **Toplantıya gir** · → **Bugün değil** (randevu yanar)

**EN**
On the calendar today: {investor}.

A message from Frank.

"It's the day. Are you going in?"

→ **Go into the meeting** · → **Not today** (the meeting is forfeit)

**Notes.** Ledger 0/2. The investor's archetype line (`{line}`) is removed from the body; if editorial wants it, it belongs on the MeetingScene as the investor's own voice. "Bugün değil" needs a chip or a visible consequence (see defects D/blind). Candidate for class H (Frank has no stake here).

---

## 14 · `ev_sheet_expiry_warning`

**Class:** confirmation card (a notification with one acknowledgement). 3 lines including the option.

**Skeleton.** `VCPitchSystem`, daily slot 8b, hour 00, priority 9. Trigger: a sheet at `days_left == 3` (`WARNING_DAYS`). Option: `VC_EV_ACK`, no modifiers. Builder formats `{investor}`, `{days}`. Render risk: one shared id for up to two sheets; a second same-day warning is dropped.

**Whitelist used.** The named VC's sheet has exactly `{days}` (3) days left. Not used: the other sheet, hour.

**TR**
{investor} teklifi: {days} gün kaldı.

Frank: "Otur ya da bırak. Bekleme."

→ **Anlaşıldı**

**EN**
The offer from {investor}: {days} days left.

Frank: "Sit down or walk away. Don't wait."

→ **Understood**

**Notes.** Ledger 0/2. Candidate for class H (a calendar notice; Frank adds nothing the counter does not). `[COND?]` per-sheet id so both warnings fire.

---

## 15 · `ev_vc_d179_warning`

**Class:** confirmation card. 3 lines including the option.

**Skeleton.** `VCPitchSystem`, daily slot 8b, hour 00. Trigger `day == 179 ∧ active_sheets ≠ ∅`; latch `vc_d179_warned`. Option `VC_EV_ACK`, no modifiers. Title `VC_EV_LAST_DAY_TITLE`.

**Whitelist used.** Today is day 179; the fork is at day 180 (`RUN_END_DAY`); at least one offer is in hand. Not used: hour, which way the fork goes.

**TR**
Takvimde bir gün kaldı; cebinde teklif var.

Frank: "İmzalayacaksan bugün imzala."

→ **Anlaşıldı**

**EN**
One day left on the calendar; there's an offer in your pocket.

Frank: "If you're going to sign, sign today."

→ **Understood**

**Notes.** Ledger 0/2. "Bugün" is a calendar fact (day 179), not a time of day. Candidate for class H.

---

## 16 · `ev_shutter_warning`

**Class:** gift card (the world changed: a counter started). 4 lines + option. Structural defect B (should place the player in Finance).

**Skeleton.** `EndingsSystem`, daily slot 9, hour 00. Trigger: `cash < 0` on the first crossing since the last recovery; `shutter_days_left` set to 7 (`SHUTTER_DAYS`); re-arms after recovery by design. Option `VC_EV_ACK`, no modifiers. Builder formats `{days}`. Badge today PİYASA.

**Whitelist used.** Cash below zero; the counter reads `{days}` (7) and is on the top bar; it stops if cash goes back to zero or above; a queued gate card was pulled. Not used: MRR, cause, hour.

**TR**
Kasa eksiye düştü. Üst barda sayaç: {days} gün.

Frank: "Ya bir şey sat, ya bir şey kes. Kasa artıya dönerse sayaç durur."

→ **Finans'a git**

**EN**
The till has gone negative. On the top bar, a counter: {days} days.

Frank: "Sell something or cut something. The counter stops if the till goes positive again."

→ **Go to Finance**

**Notes.** Ledger 0/2. Option: `[VOCAB?] navigate_to_tab{tab: "finance"}` (the levers are there). The second Frank sentence states the rule the counter already follows; editorial may cut it.

---

## 17 · `ev_pivot_offer`

**Class:** scene (accept the pivot or end the run). 5 lines + options.

**Skeleton.** `EndingsSystem`, daily slot 9, hour 00. Trigger `vc_rejections ≥ 3 ∧ no active or pending sheet ∧ no pending meeting ∧ pivot_used false ∧ mrr ≥ 2000 ∧ cash > 0`; latch `pivot_offer_made`. Options: `END_EV_PIVOT_ACCEPT` → `accept_pivot` (closes the VC road; run continues to day 180) · `END_EV_PIVOT_DECLINE` → `decline_pivot` (**terminal**: `vc_rejection_cascade`; no chip). Builder formats `{day}` = 180. Badge today PİYASA.

**Whitelist used.** Three tables closed (`CASCADE_TABLES`); no offer and no meeting pending; MRR ≥ 2.000 and cash above zero (live, not printed); the run can continue to day `{day}`. Not used: which VCs, hour.

**TR**
Üçüncü ret geldi. Masa kalmadı.

Telefon, Frank.

"VC yolu kapandı. Gelirin var, kasa sıfırın üstünde. {day}. güne kadar kendi paranla gidebilirsin. Devam ediyor musun?"

→ **Devam** · → **Hayır, bitti**

**EN**
The third rejection is in. There are no tables left.

The phone. Frank.

"The VC road is closed. You have revenue, the till is above zero. You can go on your own money to day {day}. Are you carrying on?"

→ **Carry on** · → **No. It's over**

**Notes.** Ledger 0/2. "Hayır, bitti" ends the run with no chip; see defects (blind terminal). "Gelirin var, kasa sıfırın üstünde" states the two gate conditions without numbers.

---

## 18 · `ev_acquisition_offer`

**Class:** scene (sell and end, or decline). 5 lines + options.

**Skeleton.** `EndingsSystem`, daily slot 9, hour 00, not shutter-gated. Trigger `phase == 3 ∧ 30 ≤ brand ≤ 50 ∧ vc_rejections ≥ 1`; latch `acquisition_offer_made`. Options: `END_EV_ACQ_ACCEPT` → `accept_acquisition` (**terminal**; no chip) · `END_EV_ACQ_DECLINE` → `set_flag acquisition_offer_rejected` (read later by a VC attack line; no chip). Badge today PİYASA.

**Whitelist used.** Phase 3; at least one VC has said no; a buyer's offer exists as an event, **with no amount in state**; accepting ends the run as `acquisition`; declining is remembered by the VCs. Not used: weekday, evening, figure, team size, hour.

**TR**
Bir alıcı yazdı. Şirketi istiyorlar.

Telefon, Frank.

"Satarsan bitiyor. Satmazsan yatırımcılar bunu hatırlar. Satmak istiyor musun?"

→ **Sat** · → **Satma**

**EN**
A buyer has written. They want the company.

The phone. Frank.

"If you sell, it ends. If you don't, the investors will remember it. Do you want to sell?"

→ **Sell** · → **Don't sell**

**Notes.** Ledger 0/2. No figure, no weekday, no "evening" (the shipped "cuma akşamı" is defect E). "Yatırımcılar bunu hatırlar" is engine-true (`acquisition_offer_rejected` feeds a VC attack line, `vc_pitch_system.gd:667`). `[COND?]` an offer amount in state if editorial wants a number.

---

## 19 · `MONTH_FRANK_*` (5 standing strips)

**Class:** standing strip (month-summary modal, one line each, first-match selector).

**Skeleton.** `MonthSummarySystem._pick_frank_line`: 1 shutter active → SHUTTER · 2 Δcash < 0 ∧ ΔMRR > 0 → BURNING_BUT_SELLING · 3 ΔMRR < 0 → SHRINKING · 4 all four deltas > 0 (MRR, cash, team, brand) → GOOD · 5 else → ANOTHER. Fires on the 1st of a calendar month, slot 10, hour 00; the modal stacks on top of any event modal.

**Whitelist used.** Only the ledger deltas and the shutter flag; nothing else. Each line must be true for every month in its band.

| key | TR | EN |
|---|---|---|
| `MONTH_FRANK_SHUTTER` | Kepenk sayacı işliyor; ay nasıl geçerse geçsin. | The shutter counter is running, whatever the month looked like. |
| `MONTH_FRANK_BURNING_BUT_SELLING` | Para yakıyorsun ama gelir büyüyor. | You're burning money, but revenue is growing. |
| `MONTH_FRANK_SHRINKING` | Gelir düştü. Sebebini bul. | Revenue fell. Find out why. |
| `MONTH_FRANK_GOOD` | Dört rakam da yukarı. İyi bir ay. | All four numbers up. A good month. |
| `MONTH_FRANK_ANOTHER` | Bir ay daha geride. | Another month behind you. |

**Notes.** Ledger 0/2. GOOD counts "team" as founder + employees (Frank excluded) and requires all four to rise, so "dört rakam" is exact. ANOTHER covers every month that is not shutter, not burning-but-selling, not shrinking, not all-up (including flat and mixed months), so it cannot praise or blame.

---

## 20 · `FIN_MENTOR_QUOTE`

**Class:** standing strip (Finance › Özet card; visible while runway < `RUNWAY_WARN_MONTHS` and not snoozed; one option `FIN_SNOOZE` → 14-day snooze flag).

**Skeleton.** `finance_ozet_view.gd:346-366, 595-606`. Shown when runway is finite and below 6.0 months (constant). Wrapped by `FIN_MENTOR_QUOTE_WRAPPED`.

**Whitelist used.** Runway below the constant; the live runway, KASA and BURN are on the same page. Not used: the cause.

**TR**
Runway {months} ayın altında. Ya gideri kıs ya geliri bul; ikisi de karar ister.

**EN**
Runway is under {months} months. Cut costs or find revenue; either one takes a decision.

**Notes.** Ledger 0/2. `[COND?]` `{months}` must be formatted from `RUNWAY_WARN_MONTHS` (today the key has no placeholder and the body says "altı ay" as a literal). True across the band 0 to 6 months, including a shutter month.

---

## 21 · `PROD_TIP_*` (3 standing strips)

**Class:** standing strip (Product Detail, `QuoteSerif`, repainted every visit). Selector: bug risk `yuksek` → BUGS · else a quality passer exists → WEAK · else GOOD.

**Whitelist used.** Bug-risk band; the quality passer's name `{rival}`; weakest axis `{axis}`; next version `{version}` (all formatted by the builder today).

| key | TR | EN |
|---|---|---|
| `PROD_TIP_BUGS` | Hata riski yüksek. Sprint yap. | Bug risk is high. Run a sprint. |
| `PROD_TIP_WEAK` | Zayıf yanın {axis}. v{version} sürümünde onu güçlendir; {rival} önünde. | Your weak side is {axis}. Strengthen it in v{version}; {rival} is ahead of you. |
| `PROD_TIP_GOOD` | Sorun yok. Zayıf yanın {axis}. | Nothing wrong. Your weak side is {axis}. |

**Notes.** Ledger 0/2. WEAK names the quality passer, not the share neighbour; the line must not imply market share. GOOD covers every state that is neither high bug risk nor passed; "sorun yok" is the widest true claim. Candidate for class H (a system tip; Frank's name on it is optional).

---

## 22 · mentor-advisory payloads (the phone note)

**Class:** standing strip (ODA phone dot + Events page "Frank'ten not"; one sentence; latched until the next advisory; not persisted today).

**Skeleton.** Set by the `mentor_advisory` modifier on rows 6, 7, 8 and by `VC_CALLBACK_REOPENED` (`vc_pitch_system.gd:463`). Rendered by `center_viewport.gd:139-150` under `ODA_EVENTS_FRANK_HEADER`. Raw TR literals today, no `_en`.

**Whitelist used.** Each payload repeats a fact its card already established; nothing new.

| source | TR | EN |
|---|---|---|
| row 6 (`ev_ps_frank_intro_b2b`) | Görüşme ayarlandı. Hazırlıklı git. | The meeting is set. Go prepared. |
| row 7 (`ev_ps_b2c_paid_tier`) | Fiyat koy. | Put a price on it. |
| row 8 (`ev_ps_first_revenue`) | İlk ödeme geldi. Aynısını bir daha yap. | The first payment is in. Do the same again. |
| `VC_CALLBACK_REOPENED` | Kapı yeniden açıldı: {investor}. Tekrar iste. | The door reopened: {investor}. Ask again. |

**Notes.** Ledger 0/2. `[COND?]` `_en` siblings (JSON carries TR literals; the VC one is a CSV key and can take EN directly). `[COND?]` persist the latch across load. The VC line replaces the shipped dash with a colon.

---

## 23 · `HUNT_FRANK_LINE`

**Class:** standing strip (Hunt tab title bar; overwritten by any advisory; reverts to default on tab rebuild).

**Skeleton.** `hunt_tab.gd:28, 51-57`. Static key today. `TERM_TABLES_CLOSED` already formats `{closed}/{total}` elsewhere.

**Whitelist used.** Phase 3; `vc_rejections` (closed tables) live; the cascade rule is 3 closed tables (`CASCADE_TABLES`).

**TR**
Av açık. Kapanan masa: {closed}. Üçüncüde yol biter.

**EN**
The hunt is open. Tables closed: {closed}. The third one ends the road.

**Notes.** Ledger 0/2. `[COND?]` the strip must format `{closed}` from `vc_rejections` (today static; defect E "dört masa" and F no variation). If formatting is not built, the fallback is "Av açık. Üç masa kapanırsa yol biter."

---

## 24 · `DEAL_PROMPT_LINE` (FrankPopup)

**Class:** scene (sit now or defer). 4 lines + options.

**Skeleton.** `main.gd:2297-2344`, FrankPopup on `sheet_granted`, `phase ≥ 3`, the sheet exists, no other modal up. Builder formats `{investor}`, `{days}`. Options: `DEAL_PROMPT_SIT` → `term_table_requested` (marked, with `DEAL_PROMPT_VALIDITY {days}`) · `DEAL_PROMPT_DEFER` → nothing (the sheet keeps ticking). Not persisted; portrait missing (FK fallback).

**Whitelist used.** A named VC just granted a sheet; it is valid `{days}` days (14, `SHEET_VALIDITY_DAYS`); the table can be opened now; a second sheet may or may not exist (not stated). Not used: runway, hour.

**TR**
{investor} teklif verdi; {days} gün geçerli.

Frank:

"Şimdi oturursan şartları zorlarsın. Beklersen başka masalara da bakarsın. Hangisi?"

→ **Masaya şimdi otur** (Geçerlilik: {days} gün) · → **Sonra. Teklifi al, başkalarıyla görüş**

**EN**
{investor} has made an offer; it's good for {days} days.

Frank:

"Sit down now and you push the terms. Wait and you can look at other tables too. Which is it?"

→ **Sit down at the table now** (Valid for {days} days) · → **Later. Take the offer, see the others**

**Notes.** Ledger 0/2. Leverage (a second live sheet strengthens pushes) is engine-true but is not stated as a rule here; editorial may add "İkinci bir teklif elini güçlendirir" if the lesson is wanted. Defer's "sheet keeps ticking" has no chip (FrankPopup has none).

---

## 25 · `TERM_FRANK_*` (7 standing strips, written as one set)

**Class:** standing strip (term-table Frank label; repaints on every lever pull). One man reacting to one table; each line true for its whole state.

**Skeleton.** `term_sheet_table_system.gd:270-291`: IDLE → OPENING · PUSH_SUCCESS → WON{lever} · PUSH_FAILURE ∧ patience ≤ 1 → LAST_MOVE · PUSH_FAILURE → RESISTED{lever} · PATIENCE_ZERO ∧ another live sheet → OTHER_TABLE{investor} · PATIENCE_ZERO → NO_TABLE · default ∧ patience ≤ 1 → LAST_MOVE · default → NEXT_MOVE.

**Whitelist used.** Table state, last lever, patience, whether another live sheet exists and its investor name.

| key | TR | EN |
|---|---|---|
| `TERM_FRANK_OPENING` | İlk teklifleri bu. Zorla. | This is their opening offer. Push. |
| `TERM_FRANK_WON` | {lever} sende. Dur, ya da başka kola bas. | {lever} is yours. Stop, or lean on another lever. |
| `TERM_FRANK_RESISTED` | {lever} vermiyorlar. Başka kola geç. | They won't give on {lever}. Move to another lever. |
| `TERM_FRANK_LAST_MOVE` | Bir hamlen kaldı. | You have one move left. |
| `TERM_FRANK_OTHER_TABLE` | Sabırları bitti. {investor} masası duruyor; oraya bak. | Their patience is gone. There's still a table at {investor}; look at that one. |
| `TERM_FRANK_NO_TABLE` | Sabırları bitti. Başka masa yok. | Their patience is gone. There's no other table. |
| `TERM_FRANK_NEXT_MOVE` | Sıradaki hamle senin. | Next move is yours. |

**Notes.** Ledger 0/2. LAST_MOVE fires in two states (after a failed push at patience ≤ 1, and as the default at patience ≤ 1), so it names no lever. NEXT_MOVE is the widest default and carries no judgment.

---

## Ledger and gates for this draft
- Aphorism ledger: 0 / 2.
- Dash gate: zero em dashes, en dashes, or hyphens between clauses in any TR/EN body above (checked by script; see the report).
- Time-of-day gate: none in any body; "bugün" in rows 13 and 15 is a calendar-day fact (the meeting day; day 179), not a time of day.
- Numbers: constants (2.500, 25.000, 4 %, 5.000, 25, 3 tables, 7 days, 180, 14) or builder-formatted live values (`{investor}`, `{days}`, `{day}`, `{lever}`, `{axis}`, `{version}`, `{rival}`); new placeholders flagged `[COND?]` (`{months}`, `{closed}`).
