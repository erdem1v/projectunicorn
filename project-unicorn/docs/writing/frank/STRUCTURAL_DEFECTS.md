# Frank surfaces · STRUCTURAL DEFECTS (report only, nothing fixed)

Every Frank surface in the shipped build, read against what the engine actually does. Classes are Erdem's. Per finding: row, class, what the text promises, what the engine does, the smallest fix. **Nothing here is implemented.** Read-only pass; line refs are the working tree at `1867213`, 2026-08-19.

Counts: **34 findings** across 8 classes, plus one corpus-wide sweep item. By class: A 7 · B 5 · C 1 · D 4 · E 9 · F 6 · G 5 · H 5 (some rows appear in two classes; a row is counted once per class).

---

## A · Says without doing
*The card gives an instruction and changes no state. The player agrees, and the world is exactly where it was.*

**A1 · Row 7 `ev_ps_b2c_paid_tier`, type specimen.**
Promises: "Parayı masaya koyma vakti… fiyat cetveli ürünün ederini sana gösteriyor, istediğin yere koy, istediğin an değiştir", option "Cetveli aç, fiyatımı koyacağım".
Engine: one modifier, `mentor_advisory`. No price is set, the paid tier is not opened, no ruler is opened, the player is not moved. `open_paid_tier` exists in the vocabulary and is not used here.
Smallest fix: give the option `open_paid_tier{price: 15}` (sets the default, honest but blunt) **or** `[VOCAB?] navigate_to_tab{tab: "product"}` (puts the player on the ruler, which is what the text says). Pick one; the text must match whichever.

**A2 · Row 11 `ev_angel_hire_nudge`.**
Promises: "Git kendine bir çalışan al."
Engine: `modifiers = []`. The HR rail badge that makes this visible is lit by `HRSystem.attention_count()` (`hr_system.gd:176-182`) from the same two facts, independently of the card. The card itself does nothing.
Smallest fix: `[VOCAB?] navigate_to_tab{tab: "hr"}`. (A second option starting the Atlas search would need `[VOCAB?] hr_start_search{role, band}` and costs the $600 retainer, which is a real decision and belongs to a scene, not a nudge.)

**A3 · Row 14 `ev_sheet_expiry_warning`.**
Promises: "Karar ver. Masaya otur ya da bırak."
Engine: one ack, no modifiers. The table is two clicks away in Finance › Yatırım and the card does not open it.
Smallest fix: `[VOCAB?] navigate_to_tab{tab: "finance"}` on the ack, or a second option carrying the existing `term_table_requested` route (the same route row 24's FrankPopup already uses).

**A4 · Row 15 `ev_vc_d179_warning`.**
Promises: "İmzalayacaksan bugün imzala."
Engine: one ack, no modifiers.
Smallest fix: same as A3; this card and A3 want the identical route.

**A5 · Row 16 `ev_shutter_warning`.**
Promises: "Ya bir şey sat, ya bir şey kes."
Engine: one ack, no modifiers. Both levers live in other tabs.
Smallest fix: `[VOCAB?] navigate_to_tab{tab: "finance"}`.

**A6 · Row 20 `FIN_MENTOR_QUOTE` (standing strip).**
Promises: "Ya gideri kısarsın ya geliri bulursun; ikisi de karar ister."
Engine: the card's only control is `FIN_SNOOZE`, which hides Frank for 14 days. The one action the surface offers is silencing the warning.
Smallest fix: accept it as a warning and keep Snooze, or move the strip next to the burn breakdown so the "gideri kıs" half is one click away. No new vocabulary needed.

**A7 · Row 8 `ev_ps_first_revenue`, reported then dismissed.**
Promises: "Artık bir şirketsin", option "Bir nefes al".
Engine: `mentor_advisory` only.
Judgment: **not a defect.** A milestone acknowledgement is a confirmation card by definition, and the state change it acknowledges (first MRR) already happened. The real problem on this row is G5 (it collides with the gate). Listed so the sweep is complete.

---

## B · Gives without placing
*The card hands the player something and leaves them to go find where it lives. Every instance wants one generic modifier, built once.*

`[VOCAB?] navigate_to_tab{tab}` is required by B1 to B5. Do not special-case Sales.
Precedent that proves it is buildable: row 13's `start_vc_meeting` already opens the MeetingScene straight from a card, and row 24's `term_table_requested` opens the table from FrankPopup. The routing exists; it is not generalised.

**B1 · Row 6 `ev_ps_frank_intro_b2b`, type specimen.** Spawns a `mid` prospect and leaves the player on the modal. Ruled: option becomes "Satış'a git" + `navigate_to_tab{tab: "sales"}`.
**B2 · Row 7.** Names the pricing ruler in Product and does not go there. → `tab: "product"`.
**B3 · Row 11.** Tells the founder to hire and does not open HR. → `tab: "hr"`.
**B4 · Row 16.** Tells the founder to sell or cut and does not open Finance. → `tab: "finance"`.
**B5 · Rows 14 and 15.** Tell the founder to sit at the table or sign, and do not open it. → `tab: "finance"` or the term-table route.

---

## C · Two voices on one card

**C1 · Row 13 `ev_vc_meeting_prompt`.**
The event carries `character_id = "char_mentor_frank"`, so the modal prints Frank's speaker strip and the MENTOR badge; the body then interpolates `{line}` = `InvestorRegistry.archetype_line` (`INV_ARCH_*`) inside quotation marks (`vc_pitch_system.gd:801-803`). The card shows Frank and quotes the investor.
Smallest fix: drop `{line}` from the body (the draft in `ALL_SCENES_DRAFT.md` does this) and let the investor speak in the MeetingScene, which is his surface.
No other Frank card mixes speakers; row 8 mixes narrator + Kasadar notification + Frank, which is one voice plus the world and is fine.

---

## D · No-op or fake option

**D1 · Row 3 `ev_mvp_iter_decision_intro`, option 1 `PROD_ITER_KEEP_GOING`, known.**
`modifiers = []` (`product_system.gd:1396-1397`) since `advance_iteration` was retired by the Build Bar task. The rounds continue whether or not the player picks it; round 2 has already started when the modal renders. A two-option card where one option is a spectator.
Smallest fix: make it a one-option confirmation card ("Geliştirmeye geç" is the only real choice), or give option 1 a real effect if "keep iterating" is meant to cost something.

**D2 · Row 24 `DEAL_PROMPT_DEFER`.**
Label promises "teklifi al, başka VC'lerle de görüş". Engine: no modifier; the popup closes and the sheet keeps ticking. Deferring is a legitimate do-nothing choice, but the second half of the label (go see others) is an action the game does not then assist.
Smallest fix: shorten the label to the part that is true ("Sonra"), or route it to the Hunt page.

**D3 · Row 10 `ANGEL_CHOICE_REFUSE`, deliberate, listed for completeness.**
Locked on `flag_equals hard_mode_unlocked == true`, a key with no writer anywhere (`game_state.gd:119-122`). It can never be taken. This is the documented visible-locked-door pattern, not a defect; it does mean row 10 is a one-real-option card and should be sized as one.

**D4 · Rows 9 and 12 `GATE_DECLINE`, real but invisible.**
It increments `gate_declines`, re-stamps `gate_prompt_day`, escalates the body, and re-prompts in 5 days. No chip, no penalty, so on screen it reads as "nothing happened". Not a fake option; a blind one.
Related blind choices (no effect chip, real consequence): row 13 "Bugün değil" forfeits the meeting; row 17 "Hayır, bitti" **ends the run**; row 18 "Sat" **ends the run** and "Satma" writes a flag a VC later throws back at the player (`vc_pitch_system.gd:667`); row 4 "Yayınla" publishes the product. `event_modal._describe_modifier` returns `{}` for all of these types.
Smallest fix: chips for `advance_phase`, `phase_gate_decline`, `decline_vc_meeting`, `accept_pivot`, `decline_pivot`, `accept_acquisition`, `set_flag` where the flag is player-visible, and `ship_active_build`. That is one table in one file.

---

## E · Copy asserting facts the engine cannot prove

The four already being fixed:
**E1 · Row 18 `END_EV_ACQ_BODY`.** "Mail bir cuma akşamı geliyor; büyük oyuncular hep cuma yazar." The card fires from the daily tick at hour 00 on whatever calendar day the brand band and rejection count line up. The weekday is computable and shown in the top bar, so this is falsifiable on screen.
**E2 · Row 7.** "Birkaç yüz kişi deniyor." The gate is `audience_above 15`; the live value at fire is typically ~16.
**E3 · Row 23 `HUNT_FRANK_LINE`.** "Dört masa; üçü kapanırsa yol biter." Four is the roster count, three is the cascade rule; the line reads as one fact and is two.
**E4 · Row 20 `FIN_MENTOR_QUOTE`.** "Altı aydan az yolun kaldı" is a literal; the threshold is `RUNWAY_WARN_MONTHS`. Moving the constant makes Frank lie silently.

Found in this pass:
**E5 · Row 4 `PROD_EV_FIRST_SHIP_BODY`.** "depo herkese açık, küçük bir açılış sayfası canlı". There is no repository and no landing page in state. (Row 4 is rewritten; noting the pattern.)
**E6 · Frank's physical presence, corpus-wide.** `ANGEL_EVENT_BODY` (chequebook out of his inside pocket), `PROD_EV_FIRST_SHIP_BODY` ("arkanda duruyor"), `VC_EV_LAST_DAY_BODY` ("Frank kapıda"), `END_EV_ACQ_BODY` ("omuz silkiyor"), `GATE_*_BODY_*` (sits, stands in the doorway, turns his phone face down). Frank has no location in state; the only channel the game models is the phone (the ODA phone anchor is described as where events arrive and where his last word waits). Every "Frank is in the room" line is an assertion the engine never makes.
Smallest fix: the phone is the default channel; physical presence only where a scene has a reason the state supports. This is a rewrite rule, not a code fix.
**E7 · Row 11 `ANGEL_NUDGE_BODY`.** "Git kendine bir çalışan al" assumes the founder has done nothing. `HRSearchSystem` may be `searching` or holding `files_ready` at that moment; the trigger only checks `employees == 0`.
Smallest fix: read the search state in the trigger, or write the line so it is true in all three states.
**E8 · Row 17 `END_EV_PIVOT_BODY`.** "Üçüncü ret maili kısa. Hepsi kısadır." There is no mail object; rejections are a counter. Harmless colour, but it is the same habit as E1.
**E9 · Row 1 `MENTOR_INTRO_BODY`.** "Vitrin'deki sunumun fena değildi" asserts a pre-game pitch no state records. Resolved by the approved row 1 rewrite, which replaces the backstory with the resignation morning.
Low severity, listed for completeness: `MONTH_FRANK_GOOD` "nadir gelirler" (asserts rarity across a five-month run); `PROD_TIP_WEAK` names the **quality** passer while the same page shows market share, so the player reads it as a share claim.

---

## F · Standing strip with no variation
*One string firing dozens of times over state that has bands underneath it.*

**F1 · Row 23 `HUNT_FRANK_LINE`.** One static line for the entire Series A hunt. `vc_rejections` moves 0 → 1 → 2 → 3 underneath it and the strip never changes; `TERM_TABLES_CLOSED` already formats `{closed}/{total}` elsewhere, so the data is there and formatted for free.
**F2 · Row 20 `FIN_MENTOR_QUOTE`.** One string across runway 6 months down to 0, including while the shutter counter runs. A player at 5.9 months and a player two days from the shutter read the same sentence.
**F3 · Row 21 `PROD_TIP_GOOD`.** The default branch covers every state that is neither high bug risk nor passed on quality, i.e. most of the run. It cannot say anything specific, and it repaints on every visit to Product.
**F4 · Row 19 `MONTH_FRANK_ANOTHER`.** The month-summary fallback covers flat months and mixed months alike (MRR up but cash down and team flat, etc.), so it can neither praise nor blame. Correct as written; noted because it is the line the player sees most often.
**F5 · Row 25 `TERM_FRANK_LAST_MOVE`.** Fires from two distinct states (a failed push at patience ≤ 1, and the default at patience ≤ 1) with one string. Acceptable; it just cannot name a lever.
**F6 · Row 22, the phone note (staleness rather than variation).** The latch holds one advisory until the next one overwrites it, so a line from the first B2B intro can sit on the phone for the rest of the run; and it is not serialized, so a save load empties it. Two opposite failures on one surface.
Smallest fixes: F1 format `{closed}` from `vc_rejections`; F2 split at the shutter boundary (the shutter case already has its own month line, so the pattern exists); F3 accept; F6 serialize the latch and expire it on a day count or on the next event.

---

## G · Wrong surface class

**G1 · Row 4 `PROD_EV_FIRST_SHIP_BODY`.** Four paragraphs with staging for a card that confirms a button the player just pressed. Already ruled: 3 lines including the option; row 4 is now the reference for the class.
**G2 · Row 8 `ev_ps_first_revenue`.** A milestone acknowledgement written as a scene with a stage direction ("Frank başını sallıyor"). It is a confirmation card.
**G3 · Rows 14 and 15.** Countdown notifications written as scenes with Frank physically present. They are confirmation cards at most, and see H1/H2 for whether they are Frank's at all.
**G4 · Row 7, inverted.** A real decision (what to charge) compressed into an advisory card with no decision in it. Either it becomes a scene with a real option (A1's fix) or it becomes a pure signpost and stops pretending to be a moment.
**G5 · Rows 8 and 9 collide, and the collision is structural.** `ev_ps_first_revenue` needs `mrr_above 0`; the Traction gate needs `mvp_shipped ∧ customer_count_min 1 ∧ mrr_above 0`. The first sale satisfies both on the same tick, and the JSON beat (slot 7) wins the modal while the gate (slot 8) queues behind it: the player gets two Frank cards back to back, the first asking "can you do it again" and the second asking the same thing as a decision. Row 11 makes it worse in the other direction: a priority-3 advisory can take the modal ahead of a priority-10 gate because the queue never re-sorts after a card is pumped.
Smallest fix: delay the gate by one day when a Frank beat fired the same tick, or fold the first-revenue beat into the gate's body 0.

---

## H · Frank has no stake
*He speaks, but nothing about the moment involves him. Candidates for removal rather than rewriting.*

**H1 · Row 14 `ev_sheet_expiry_warning`.** A countdown the top bar already renders (`TEKLİF: {n} GÜN`). Frank adds "decide". He did not source the offer, holds no position on this VC, and gains nothing either way.
Recommendation: **remove the Frank framing**, keep the card as a neutral notification. If the arc wants a Frank line here, it belongs on the one sheet he actually opened a door for, which the engine cannot currently distinguish.

**H2 · Row 15 `ev_vc_d179_warning`.** Same shape: a calendar fact one day before the fork. Recommendation: **remove the Frank framing**, keep the card.

**H3 · Row 13 `ev_vc_meeting_prompt`.** The player booked this meeting. Frank did not arrange it, is not in the room, and the card's real content is the investor's line plus a route into the MeetingScene. Recommendation: **remove the Frank framing** (which also resolves C1), keep the card.

**H4 · Row 21 `PROD_TIP_*`.** A system tip derived from bug risk, the quality passer and the weakest axis, rendered under an "FK" avatar and a "FRANK" label (`detail_view.gd:320-340`). Nothing about the strip is his.
Recommendation: keep it if Frank-as-dashboard-voice is wanted deliberately, drop the attribution if not. Not a rewrite question; a design one.

**H5 · Row 23 `HUNT_FRANK_LINE`.** Standing decoration on a page Frank has no relationship to, and it is overwritten by whatever advisory fired last, so it is not reliably his either.
Recommendation: make it state-fed (F1) and unattributed, or cut it.

The three surfaces already cut (rows 2, 5, 26) were cut for exactly this reason, which is the class working as intended: Frank commenting on the market choice, on every version ship, and on the ending were all places where he had nothing at stake.

---

## Sweep item (not one of the classes)

**Dashes in the shipped Frank corpus.** 15 of the Frank keys contain an em or en dash in TR, EN, or both: `MENTOR_INTRO_BODY`, `ANGEL_EVENT_BODY`, `GATE_TRACTION_BODY_0`, `GATE_SERIES_A_BODY_0`, `GATE_ADVANCE`, `MONTH_FRANK_GOOD`, `TERM_FRANK_RESISTED`, `TERM_FRANK_OTHER_TABLE`, `DEAL_PROMPT_LINE`, `DEAL_PROMPT_DEFER`, `VC_EV_MEETING_BODY`, `VC_EV_OFFER_EXPIRING_BODY`, `END_EV_PIVOT_BODY`, `END_EV_ACQ_BODY`, `END_EV_ACQ_DECLINE`. Every one is a clause joint that a full stop, comma or colon would carry. The standing rule bans them in new bodies; the existing corpus needs the same sweep when these keys are replaced.

## Cross-cutting notes for the dev track
1. `[VOCAB?] navigate_to_tab{tab}` unblocks B1 to B5 (five cards) and is the single highest-value item in this report.
2. Effect chips for the eight blind modifier types (D4) turn four run-ending or irreversible clicks from blind into readable.
3. The queue's "first enqueue owns the modal" rule (`time_manager.gd:344-355`) is what produces G5 and the row 11 pre-emption. A priority sort at pump time, or a one-Frank-card-per-day budget, fixes both.
4. Two persistence gaps touch Frank alone: the advisory latch (F6) and a pending FrankPopup (dropped on save).
