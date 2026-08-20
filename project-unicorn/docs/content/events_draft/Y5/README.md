# Y5 · Frank (mentor) · 6 nodes · revision 3 (A/B/C bodies, director picks)

**Payoff in one line:** a relationship, not a tutorial: Frank shows up, pays once, nags once, calls once, opens one door, and says one sentence at the end; the player never hears him explain the game and never sees him do anything with his body.

Files: `Y5.1.md` intro · `Y5.2.md` seed offer · `Y5.3.md` nudge (= Y4.1, sealed) · `Y5.4.md` after the first churn (sealed) · `Y5.5.md` at the Series A threshold · `Y5.6.md` verdict ×5 lines. Read `../_vocabulary.md` first. Mechanics (headers, options, effects, memory) were accepted in revision 1 and are unchanged except the rulings below; every non-sealed body is new and comes in three forms (A = a message, B = a record/count the game already knows, C = a voice: a call or a line at the door). Options and effects are identical across A/B/C. The director picks one per node.

## Rulings applied in revisions 2 and 3
- Y5.4b deleted; Y5.4 is a pure beat (single option "Tamam"); the "sayı olduğu gün" concept moves to **Y7 as a diagnostic beat, no lead**.
- Y5.3 single option "Bakacağım"; sealed body untouched; TR typo flag kept in notes.
- Y5.5 two options (Tanıştır `[VOCAB?] vc_warm_intro`, Kendim giderim); **not wired until `vc_warm_intro` exists**.
- Y5.6 five lines only; optional variant lines deleted; the two sealed sentence pairs stay byte-exact.
- Y5.2 locked reason: "Frank'siz yol. Zor mod, henüz değil." / "The road without Frank. Hard mode, not yet."
- Y5.1 `[COND?] origin` header line dropped.
- `_vocabulary.md` §a.4: `advance_iteration` marked retiring (Build Bar task).
- Voice (rev 2): nothing performed; no body narration of Frank; Frank ≤3 sentences per node and ≤10 words each; sealed texts byte-exact; no dashes.
- Writing (rev 3, after the director rejected rev 2 as dead): every sentence is a specific fact that implies more than it says (a minute, a count, a day, a name, a line on the record); the sting is an absence or a detail, never a mood; Frank has one turn per node (the sealed voicemail's "bir şey olmayacak, biri olacak" is the measure); details may be invented if they are facts, never if they are atmosphere; EN is its own piece with its own turn, not the TR carried over. Each node's three variants share one implication (Y5.1: he watched the pitch more closely than you did; Y5.2: he has been watching your numbers; Y5.5: he spoke to the man before he spoke to you).

## Memory chain (what each node writes and who reads it)

| node | writes | read by |
|---|---|---|
| Y5.1 | nothing | nobody (a boot modal) |
| Y5.2 | existing `angel_seed_offered`, `angel_seed_accepted_day` | Y5.3 (two-day clock), Y5.5/Y5.6 (Frank as shareholder, stated) |
| Y5.3 | existing `angel_nudge_shown` | Y4.2 The search (tone) |
| Y5.4 | `y5.4.choice = "heard"` | Y2.x (tone after the first loss); Y5.6 only if the rebuild adds variant picks |
| Y5.5 | `y5.5.choice = "intro" \| "cold"` | Y6.3 / Y6.4 (one line at the Bosphorus table) |
| Y5.6 | nothing (terminal) | the ending surface |

Flag keys use the Pool §7 form (`y5.4.choice`); registration in `GameState.FLAG_TYPES` is optional (unregistered keys are legal, `game_state.gd:56-57`).

## Cross-reads
- **Y5.3 ↔ Y4.1**: same node, cross-listed; Y4.2 The search reads `angel_nudge_shown`.
- **Y5.4 ← Y2.4 Goodbye**: Y5.4 is the call after the loss; today's edge is `EventBus.customer_churned`; the interim JSON path is `flag_set y2.4.outcome`.
- **Y5.4 → Y7**: the third-loss diagnostic ("sayı olduğu gün") is Y7's, not Frank's; no lead is given.
- **Y5.5 → Y6**: `y5.5.choice` gives the Bosphorus table one line; `VC_WHY_WARM_INTRO` becomes conditional on the flag the rebuild introduces.
- **Y5.6 ← endings**: reads the ending id and, for Series A, the ending's own founder-friendly / aggressive fork.
- **Frank outside Y5** (so the voice stays one man; not rewritten here, but the same rules will apply when they are): Traction and Series A gate scenes (`GATE_TRACTION_BODY_0..2`, `GATE_SERIES_A_BODY_0..2`, all of which currently carry body narration), shutter warning, pivot offer, acquisition offer, D-179, month-end lines, hunt line, product-detail tips, the B2B door-opener (`ev_ps_frank_intro_b2b`, retires into Y1's first-customer node), first revenue (`ev_ps_first_revenue`, unassigned).

## `[VOCAB?]` / `[COND?]` for the engine rebuild
Conditions:
- `[COND?] customers_lost_min 1` (Y5.4) on `GameState.run_customers_lost`
- `[COND?] employee_count_max 0` and `[COND?] day_since_flag(angel_seed_accepted_day) ≥ 2` (Y5.3, if it moves from system code to JSON)
- `[COND?] audience_drop_edge` (a B2C Y5.4; not written)
Effects:
- `[VOCAB?] vc_warm_intro{vc_id}` (Y5.5 option 1; today `warm_intro` is a static registry field always on for Bosphorus; the node is not wired until it exists)
- `[VOCAB?]` ending Frank surface (Y5.6: a strip on EndingScene or a pre-terminal beat)
- `[VOCAB?] mentor_advisory` `_en` sibling (no Y5 node relies on it; listed so the gap stays visible)
Trigger hooks the rebuild must expose as on_actions for this arc: `customer_churned` (with count), `phase_changed`, `run_ended` (a surface, not an event); the two system polls (`angel_offer`, `angel_nudge`) stay system-owned or migrate with the two conditions above.

## Where the Pool Design and the engine disagree (recorded, not resolved)
1. **Y5.1 is a boot modal**, not an event; the file is a rewrite of `MENTOR_INTRO_BODY` / `MENTOR_INTRO_CTA`.
2. **Y5.2 has one real option**: REDDET is locked on a flag with no writer, by design (hard mode ships later).
3. **Y5.6 cannot be an event**: the queue is flushed at a terminal, and Frank's ending lines are not rendered by the newspaper today. It is a surface task.
4. **Y5.5's warm intro is unconditional** today; not wired until `[VOCAB?] vc_warm_intro`.
5. **Y5.4 has no first-churn condition and no B2C edge**; the interim path is a flag written by Y2.4.

## Ruled out in revision 2 (so they are not proposed again)
Y5.4b "Sayı" (a Frank-sourced lead on the third loss) · Y5.4 locked "Ara" door · Y5.3 option "Aramayı başlat" (`hr_start_search`) · Y5.5 option "Ne isterler?" (`vc_intel`) · Y5.6 optional variant lines · every staged gesture, simile and mood sentence of revision 1.

## Follow-ups
- Verdicts for `acquisition`, `brand_collapse`, `vc_rejection_cascade` (EA). Their shipped `END_META_*_FRANK` lines stay until then.
- Y7: the "sayı olduğu gün" diagnostic beat, no lead.
- Homes for two legacy Frank functions the Pool node list does not name: **first revenue** ("Artık bir şirketsin.") and the **B2B door-opener** (`add_prospect{mid, frank_intro}`); see `_vocabulary.md` §f.
- The shipped gate scenes and other Frank surfaces carry body narration and will need the same pass when their arcs come up.

## Five lines for the director
1. Hardest: the writing. Rev 1 performed Frank, rev 2 obeyed the rules and died on the page; rev 3 tries to do what the sealed texts do: a fact that implies, a sting that is a detail, a Frank who has a tongue. Judge it against the four sealed texts, not against the rules.
2. Where the law bends: inside the two sealed Y5.6 pairs the last sentence is not the shortest ("Sabırlıdır." follows a three-word sentence; "Sadece kazanmadın." follows one word); the seal wins. Y5.3 and Y5.4 bodies are sealed, so their A/B/C is title/subtitle only.
3. Sealed texts are byte-verified (Y5.3 and Y5.4 both locales; the two Y5.6 TR pairs in all three variants). The TR voicemail's fourth sentence ("Kimse bu hafta bilmek isterim.") is still flagged for your ear only.
4. Read first: Y5.2 A/B/C (the sample you approved), then Y5.1 (the minute you don't remember / the word he counted), then Y5.5 (the lunch before the gate), then Y5.6 (fifteen lines).
5. Structural checks (Frank sentence counts, sealed match, dashes) are in the report; the real check is your read. If rev 3 fails, you write the bodies and I keep headers, effects, memory, EN skeleton and the sealed checks.
