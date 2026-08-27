# FRANK · UNWIRED SURFACES

Open work left by the Frank v6 landing pass (2026-08-20). Every text in
`docs/content/events_draft/Frank Diyalogları · v6.md` is now in the repo, both locales, final.
Some of it belongs to systems that do not exist yet. **That text is landed anyway** — in the
right file, under the right key, complete — and held so it cannot fire. When the system ships,
the wiring attaches to text that is already sitting there. Nobody re-authors anything.

This file is the list of what is still waiting. It is written for someone who was not in the
room.

Two rules that shaped every entry below, so they do not get relitigated:

- **Replace, do not run in parallel.** The new text took the old cards' place. The old copy is
  gone from the surfaces it used to occupy; the old *card* is what is closed, never the ending
  behind it. `docs/writing/FRANK_ORPHANS.md` lists everything left standing.
- **"Cannot fire" is demonstrated, not assumed.** A condition that happens to be false today is
  luck, not inertness. Every entry states the structural reason, and most carry a falsification
  test in the smoke suite.

---

## 1 · Surface 12 · Seed kapısı — no text yet

**Where the text lives.** Nowhere. The document contains no body for this card, deliberately.
The surface in the build is untouched: `ev_phase_gate_series_a`, built by
`PhaseGateSystem._build_gate_event` from `GATE_SERIES_A_TITLE` / `GATE_SERIES_A_BODY_0..2` /
`GATE_ADVANCE` / `GATE_DECLINE` (`localization/strings.csv`, both locales).

**Waiting on.** The seed round's *design* — the threshold, how many tables, and whether Series A
remains a separate gate — none of which is decided.

**How it is held.** It is not held; it is the shipped Series A gate, still firing with its
shipped copy. It is listed here because the document names it as awaiting design, not because it
is inert.

**Attaching it.** A design session first, then one body rewrite. Note that this card still
carries em dashes (`GATE_ADVANCE` "Hazırız — geçelim", `GATE_SERIES_A_BODY_0`); the dash ban
applies to whatever key is touched, so they clear when this surface is rewritten.

---

## 2 · Surface 12b · Seed kapandı — **WIRED 2026-08-27**

The round exists. `data/events/unwired/ev_seed_closed.json` was ported field by field into
`data/events/cards/funding/seed_closed.json` and the unwired copy retired; the four sealed
strings moved into the CSV as `SEED_CLOSED_TITLE` / `_BODY` / `_OK` and are byte-exact
(asserted, not asserted-in-a-comment: the applier read them out of the JSON rather than
retyping them). Five fields had to change shape — `character_id`→`speaker`,
`one_shot`→`latch.one_shot`, `category: reactive`→`funding`, inline text→CSV keys — and one
mattered: **`"trigger_conditions": []` means ALWAYS ELIGIBLE**, which is why `unwired/` is
excluded structurally rather than merely left unconditioned. Ported as written, this card
would have fired on day 1, before there was a round to confirm. It now waits on
`funding.seed_taken` and `funding.seed_days_since_close <= 1`.

### The original entry, for the record


**Where the text lives.** `data/events/unwired/ev_seed_closed.json` — `title` / `title_en`,
`body_text` / `body_text_en`, and its single option's `label` / `label_en`. Complete and final.

**Waiting on.** The seed round: there is no funding rung between Frank's $25,000 angel cheque
and Series A, so there is no moment for this card to confirm.

**How it is held inert.** `EventManager.EVENTS_DIR` is a single constant pointing at
`res://data/events/reactive/` (`scripts/autoload/event_manager.gd`), the directory scan does not
recurse, and nothing else in the codebase opens `data/events/`. A file in `unwired/` never
reaches `_all_events`, so it never reaches the eligibility pass, the queue, or `_history`. That
is structural, not conditional. It is still gated as shipped content: the
`loc_event_en_coverage` smoke case scans `unwired/` alongside `reactive/`, so a TR-only card
cannot sit here quietly and surface in English the day someone wires it.

**Attaching it.** Small, once the round exists: move the file into `data/events/reactive/` and
give it a trigger, or inject it from the seed-close seam the way `AngelRoundSystem` injects the
cheque. One file moved, one enqueue site.

---

## 3 · Surfaces 17 + 18 · Satın alma teklifi — **WIRED 2026-08-27**

All four blockers are answered. **The trigger** is `funding.acq_road_over`: the founder faced
the Series A decision by a decline or a walk AND nothing is left to walk to — the second half
is what keeps the sealed first sentence ("Series A turu kapandı, ortada anlaşma yok") true,
and stops one walked table from resolving a run with three funds still on the board. **The
valuation** is `EndingsSystem.acquisition_valuation()` — ARR × a multiple adjusted for growth
and brand, clamped — with the founder's share as `{offer}`, which is the only mapping under
which the shipped sentence is true. **`{investor}`** resolves through a new `seed_lead` scope
selector, so the caller is the fund that led the seed; with no seed round the card does not
fire, because there is nobody to make the call. **"Sat" is labelled**: `trigger_ending` now
has a `_describe_modifier` row (`EFFECT_RUN_ENDS`), and `decline_buyout` has its own
(`EFFECT_VC_ROAD_CLOSES`) — the smoke case `event_chip_coverage` fails the build otherwise.

The detail this file said not to lose is kept: **"Kendi paramla devam" carries both**
`on_pivot_accepted()` and `acquisition_offer_rejected`, behind one atomic verb, and
`buyout_needs_the_road_over` asserts both after resolving that option.

### The original entry, for the record


Pivot and acquisition were two cards asking one question. The document merged them into a single
moment: the Series A round closes with no deal, the investor who led the **seed** round brings a
ready buyer, Frank says the last word. Sell, or carry on with your own money.

**Where the text lives.** `localization/strings.csv`, both locales — `END_EV_ACQ_TITLE`
("Devralma teklifi" / "Acquisition offer"), `END_EV_ACQ_BODY`, `END_EV_ACQ_ACCEPT` ("Sat" /
"Sell"), `END_EV_ACQ_DECLINE` ("Kendi paramla devam" / "Carry on with my own money"). The card
object is `EndingsSystem._build_buyout_offer_event()`, carrying both options wired to their real
modifiers.

**Waiting on.** Four things, and it needs all four:

1. **The merged trigger** — "the Series A round closed with no deal", however that is expressed.
2. **A valuation** to feed `{valuation}` and `{offer}`. There is no company valuation in normal
   play: a number exists frozen per investor in `InvestorRegistry.opening_terms`, and live only
   inside a term-sheet sitting. `GameState.run_valuation_m` is write-only, set at signing.
3. **`{investor}` resolving to the seed investor.** No seed round means no seed investor, and
   `vc_states` has no "seeded you" status to hold one.
4. **"Sat" labelled as terminal.** It ends the run, and `EventModal._describe_modifier` returns
   `{}` for `accept_acquisition`, so today that click would be blind.

**How it is held inert.** Nothing calls `_build_buyout_offer_event`. `grep -rn
"_build_buyout_offer_event" scripts/` returns the definition and its own comment, nothing else.
Both former injection sites (`_check_vc_cascade`, `_check_acquisition_offer`) keep only their
latch writes. Falsification: the `buyout_card_is_inert` smoke case builds the exact world-state
that used to open **both** old cards at once — phase 3, brand 40, MRR 3000, three closed tables
— runs thirty days, and asserts that no card id reaches the queue and no ending fires.

**No ending was touched.** "Şirket satıldı" (`acquisition`) and the profitable-bootstrap path
are in the build exactly as they were; `accept_acquisition` and `accept_pivot` both still work.
Only the door is shut. `vc_rejection_cascade` also stays reachable, through the metrics-dead
branch of `_check_vc_cascade` that this pass deliberately left alone. The latches still burn, so
a run that would have been offered the card continues to another terminal instead of stalling.

**One detail not to lose when wiring.** "Kendi paramla devam" carries **two** modifiers:
`accept_pivot` *and* `set_flag acquisition_offer_rejected`. The second is the memory the
document rules must be preserved — refusing to sell is remembered and thrown back at the founder
in a later VC meeting (the refused-acq interrogation in `vc_pitch_system.gd`). Dropping it
silently deletes a beat.

**Attaching it.** Roughly a day, plus whatever the valuation formula costs.
`scripts/systems/endings_system.gd` (the trigger and one enqueue), a valuation source, and one
row in `scripts/modals/event_modal.gd`'s `_describe_modifier` so the terminal option is labelled.

---

## 4 · Surface 24 · Teklif e-postası geldi — text complete, old edge refused

**Where the text lives.** `localization/strings.csv`, both locales — `VC_EV_DEAL_TITLE`
("Yatırımcıdan teklif" / "The investor's offer"), `DEAL_PROMPT_LINE`, and the option
`VC_EV_GO_FUNDING`. The card object is `VCPitchSystem._build_deal_prompt_event()`.

**Waiting on.** The new offer flow, which is four steps and none of them exist: the investor
leaves the table promising the offer **by email**; the card fires when the email **arrives**;
the player has **three days** to enter the term-sheet negotiation; only afterwards does the
funding tab show the offer with a **30-day answer counter**. The only offer clock in the engine
today is `PitchConstants.SHEET_VALIDITY_DAYS` (14 days), and it starts the instant the sheet is
granted.

**How it is held inert.** Both call sites of `_offer_deal_prompt` — in `_grant_sheet` and in
`_deliver_pending_sheet` — are removed, with a comment left in place at each. A granted sheet
therefore cannot summon the card. Riding that old edge would have been an approximate trigger,
which ships and lies. Falsification: `deal_prompt_is_inert` grants a sheet, runs five days, and
asserts no `ev_vc_deal_prompt_<vc>` id reaches the queue while the sheet economy stays intact.
The player is not stranded — Finance › Yatırım still opens the table on its own (`hunt_tab.gd`).

**Attaching it.** A day or two, mostly new mechanic rather than wiring:
`scripts/systems/vc_pitch_system.gd` (the email delay, the 3-day window, the answer counter),
`scripts/tabs/hunt_tab.gd` (the counter's display), and one enqueue site.

**Document correction owed.** This surface's `{yatırımcı}` / `{investor}` token was **removed**
from both the title and the body, and the v6 document should be corrected to match rather than
left to drift. Turkish suffixes take vowel harmony and consonant assimilation from the word
before them, so `{investor}'dan` produces the wrong suffix for most of the roster and the engine
cannot inflect; `loc_csv_integrity` then forces the token out of the English column too, because
the two locales must carry an identical token set. The ruled replacement text is what is in the
CSV today.

---

## 5 · The navigation modifier — seven cards want one mechanism

**Where the text lives.** Already landed, in seven option labels, both locales:
`data/events/reactive/ev_ps_frank_intro_b2b.json` ("Satış'a git" / "Go to Sales") ·
`data/events/reactive/ev_ps_b2c_paid_tier.json` ("Ürüne git" / "Go to Product") ·
`ANGEL_NUDGE_ACK` ("İK'ya git" / "Go to HR") · `VC_EV_GO_FUNDING` ("Yatırım'a git" / "Go to
Funding", used by surfaces 14, 15 and 24) · `END_EV_GO_FINANCE` ("Finans'a git" / "Go to
Finance").

**Waiting on.** One generic `navigate_to_tab` modifier. **These labels are live today and the
buttons go nowhere** — that is the visible cost of landing the text ahead of the mechanism, and
it is the highest-value dev item the Frank pass produced.

**How it is held.** Not held. These cards fire; only the routing is missing.

**Attaching it.** Hours, with a precedent to copy exactly: `open_term_table`
(`event_manager.gd`) is a one-line modifier arm that emits an existing `EventBus` signal. An
`{"type": "open_tab", "tab_id": …, "subpage": …}` arm would emit `EventBus.tab_changed` and,
for the funding case, `EventBus.finance_subpage_requested` immediately after — `finance_tab.gd`
documents that the two emits are safe in that order. Files: `event_manager.gd` (the arm),
`event_modal.gd` (`_describe_modifier`, or the option renders no effect chip), then one modifier
added per card. **Do not special-case Sales**; build it once, as the document says.

---

## 6 · Tab naming — Funding, not Investment

**Where the text lives.** One CSV row: `FIN_SUBTAB_INVESTMENT`, currently `Yatırım,Investment`.

**Waiting on.** Nothing technical. It is a naming decision the document already made, which this
pass deliberately did not execute because "the tab itself changes accordingly" is more than a
label. Turkish stays **Yatırım**; English becomes **Funding**.

**Where the English label appears.** `FIN_SUBTAB_INVESTMENT` is the only place the tab is named
to the player. It is a **sub-page of Finance**, not a rail tab — `finance_tab.gd` builds the
segment, and the standalone rail entry was retired earlier. Keys that read like the tab but are
**not** it, listed so a careless sweep does not catch them: `ODA_PAPER_TAG_FUNDING`,
`ODA_FRAME_FIRST_FUNDING`, `HUNT_SEC_INVESTORS`, `TERM_INVESTMENT`, `FIN_CAPTABLE_INVESTORS`,
`END_STAT_INVESTMENT`, `ONB_SKILL_NEGOTIATION_DESC`.

**Note.** The option labels landed by this pass already say **"Go to Funding"**, so until this is
done the English build points the player at a tab it does not call by that name.

**Attaching it.** Minutes for the label. The open question is whether any other English copy on
the Funding page moves with it.

---

## 7 · The soft cap has no telegraph — **CLOSED**

A three-rung ladder was built during the event-engine rebuild and this file predates it:
`world.final_stretch_press` (day ≥ 640, a paper) → `world.final_stretch_comment` (day ≥ 700)
→ `world.final_stretch_verdict` (day ≥ 729, Frank, the D-1 beat ch. 13 §1 asks for), tied
together by `arc_final_stretch` and all three stamping `soft_cap_telegraphed`. It is
sheet-independent, so it reaches a player with no offer — the case the ending is named for.

**One hole remained, and was closed 2026-08-27.** The opener also required
`phase.series_a_signal != "open"`, which reads as "do not nag a company whose door is open".
True of a company that walks THROUGH the door; false of one that leaves it standing open —
that run kept phase 2, never started the arc, and still reached day 730 in silence. The leaf
is now an `any` that also admits phase 2. Measured in a played run
(`--run-log=full_run:730:sim`): press, comment and verdict each fire once.

### The original entry, for the record


**What happened.** Surface 15's card used to be a calendar warning on the eve of the soft cap
(and, before that, on day 179 of the retired 180-day wall). The document moved it onto a
different moment entirely — the last day to answer the last live **offer** — and that is where
it fires now. The old warning was retired rather than duplicated, by ruling.

**The gap.** A run can now reach `EndingsSystem.SOFT_CAP_DAY` (730) with **no prior warning at
all**. `PitchConstants.SOFT_CAP_WARN_DAY` and the `vc_soft_cap_warned` flag are gone with it,
and the comment in `endings_system.gd` that called that warning "the telegraph" has been
corrected so the code stops claiming a surface it no longer has.

**Waiting on.** A "final stretch" surface. **Author and voice undecided** — most likely not
Frank's. The document rules the calendar-expiry case a separate design topic.

**Attaching it.** Small once the design exists: a day check in `EndingsSystem` or
`VCPitchSystem`, and one card. The soft cap itself is untouched and still fires.

---

## Smoke cases repointed (listed, not deleted)

Every case that reached a behaviour through a card this pass retired was **repointed at the
behaviour**, so nothing lost coverage.

| case | why it moved | where it points now |
|---|---|---|
| `pivot_accept` | drained to `ev_pivot_offer` | drives `EndingsSystem.on_pivot_accepted()` directly, and additionally asserts the retired id never reaches the queue |
| `pivot_decline` | resolved the retired card's option 1 | reaches `vc_rejection_cascade` through the surviving metrics-dead branch. Seeded **below** `PIVOT_MRR_MIN` through a real customer record, because the slot-4 MRR bridge rewrites `GameState.mrr` every day and a bare `set_mrr(0)` is clobbered before the endings scan reads it |
| `gate_decline_reminder` | the Traction gate lost its decline | drives `ev_phase_gate_series_a`, which keeps both options. Its old body assertion read `PhaseGateSystem.GATES[0].bodies`, **a key the GATES table has never had** — a latent runtime error sitting inside a passing-looking case. It now reads the escalated copy through the CSV key |
| `soft_cap_warning_day` → `last_answer_warning` | the trigger moved off day 729 | asserts the card fires on the last day to answer the last live offer |
| `shutter_recovery`, `bankruptcy`, `terminal_kills_gate` | `SHUTTER_DAYS` 7 → 30 | expectations and drive loops now derive from the constant instead of being typed, so the next retune does not re-break them |
| `loc_event_en_coverage` | a new directory, and a blind spot | scans `data/events/unwired/` as well, and now audits `mentor_advisory` **modifier payloads** — player-facing prose the old field-only scan never looked at |

New cases: `traction_gate_one_option`, `last_answer_warning`, `last_answer_warning_suppressed`,
`buyout_card_is_inert`, `deal_prompt_is_inert`.
