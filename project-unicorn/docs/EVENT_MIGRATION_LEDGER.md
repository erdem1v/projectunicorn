# EVENT MIGRATION LEDGER

Every card that exists today, and what happens to it. GDD §22 requires this: *"Her mevcut
kart: taşı / yeniden yaz / sil."* Nothing is deleted without a written reason, and nothing is
carried across without a decision.

**Ruling from the director, 2026-08-25:** *port and repair, delete the worst.* So a card that
is carried across also gets its copy lie closed — the label names a resource and the engine
now charges it — while cards written against a different game are removed rather than
laundered.

**The source of the verdicts** is `docs/audits/EVENT_INVENTORY_2026-08-21.md`, which graded all
28 entries against eleven flags from source and then had a second reader try to refute each
one. Its headline finding is the reason this column exists at all:

> **COPY LIE on 27 of 28 entries.** The dominant shape, found independently card after card,
> is that a label names the resource the player is being asked to spend and the engine charges
> a different one, or nothing at all. *"Çıkışı ertele, çöz"* carries no `delay_days` — the
> launch is not postponed. *"Vakit harca, cila çek"* spends no time. *"Kabul et — özellik sözü
> ver"* creates no promise.
>
> That is one defect class repeated two dozen times, and it is also the cheapest to fix,
> because in most cases the prose is right and the missing effect is one line. Which is the
> whole argument for revising these cards rather than replacing them.

---

## Summary

| verdict | count | |
|---|---|---|
| **PORT + REPAIR** | 15 | carried onto the new schema, copy lie closed |
| **DELETE** | 3 | debug fixtures written against a different game |
| **HOLD** | 1 | finished text, no mechanic — stays unwired, unchanged |
| **PORT (code-built)** | 11 families | the factories become authored cards |
| **RETIRE (code-built)** | 4 | already inert, or zero callers |

---

## A · Authored JSON — `data/events/reactive/`

### The MVP build family (9 cards) — PORT + REPAIR

`ev_mvp_dev_001..003` · `ev_mvp_iter_001..003` · `ev_mvp_bugfix_001..003`

These are the healthiest cards in the game and the port is nearly mechanical: a `build_phase`
trigger becomes a `guards.build_phase`, the `random` roll becomes a pool weight, and the
axis/bug effects map one-to-one onto `dimension_delta` and `bug_delta`.

**The repair each one needs** is the same and it is the audit's headline: several options say
they spend TIME and carry no `delay_days`. `ev_mvp_bugfix_003_final_polish`'s *"Vakit harca,
cila çek"* takes $80 and no days at all — the build finishes on exactly the day it would have.
`delay_days` exists as a verb; the fix is one line per option.

One structural note carried across: `delay_days` silently no-ops when no build is active, and
the old chip printed the day cost anyway, so post-ship the card showed a price that was never
charged. The new executor refuses it out loud and logs the refusal.

| card | repair |
|---|---|
| `ev_mvp_dev_001_integration_broken` | `set_flag tech_debt_birikti` becomes a named Product verb — a card may no longer poke another domain's state through a generic flag write |
| `ev_mvp_dev_002_tech_debt_callout` | same, both directions |
| `ev_mvp_dev_003_solo_dev_fatigue` | smallest of the family, no repair needed |
| `ev_mvp_iter_001_scope_creep` | option 1 claims scope and time; add the `delay_days` it already promises |
| `ev_mvp_iter_002_competitor_signal` | fine as written |
| `ev_mvp_iter_003_early_user_feedback` | fine as written |
| `ev_mvp_bugfix_001_critical_bug` | *"Çıkışı ertele, çöz"* — **the launch is not postponed.** Add `delay_days` |
| `ev_mvp_bugfix_002_early_launch_pressure` | same shape |
| `ev_mvp_bugfix_003_final_polish` | *"Vakit harca"* spends no time. Add `delay_days` |

### The post-ship family (6 cards)

| card | verdict | note |
|---|---|---|
| `ev_ps_frank_intro_b2b` | **PORT + REPAIR** | its `Satış'a git` button went nowhere. `goto_tab` exists now — this is one of the seven cards `FRANK_UNWIRED.md` §5 called the highest-value dev item of the Frank pass |
| `ev_ps_b2c_paid_tier` | **PORT + REPAIR** | the card that says *"bir noktada ücret almaya başlasak iyi olur"* neither opens the paid tier nor navigates anywhere. `open_paid_tier` and `goto_tab` both exist |
| `ev_ps_referral_b2b` | **PORT + REPAIR** | *"Kabul et — özellik sözü ver"* **creates no promise.** `promise_create` closes it. Its `source: "referral"` is also a dead field — one write, no readers |
| `ev_ps_bug_complaint` | **PORT + REPAIR** | the `Görmezden gel` chip reads *"Müşteri kaybı"* and on the B2C branch loses no customer at all — it erodes 15% of the audience and never touches the churn counter. Either the chip or the effect was lying; the effect is what the prose describes, so the effect wins |
| `ev_ps_b2c_producthunt` | **PORT + REPAIR** | the modifier value `"source": "producthunt"` and the card id both name a real trademark. Renamed to the canon fictional analogue **Vitrin**, which the player-facing copy already uses correctly |
| `ev_ps_power_user_b2c` | **PORT** | clean; only the schema moves |

### `ev_debug_001` · `ev_debug_002` · `ev_debug_003` — DELETE

Three fixtures the loader has never loaded — `event_manager.gd:875` skips the `ev_debug_`
prefix, so they *"did not lose the roll; they were never candidates."*

Deleted rather than ported, for reasons that compound:

- **Turkish only.** No `_en` on any of them, so they cannot ship as they stand.
- `ev_debug_003` carries a permanently-locked option whose label is literally
  `[NOT IMPLEMENTED]`, and a Frank attribution on a card Frank never approved.
- `ev_debug_002` is the worst-graded entry in the audit: eight flags, and a `+6` brand swing
  that would saturate the 0-100 band in about eight fires.
- Their one remaining job — a card to point `--event-shot` at — is served better by the three
  worked examples, which are real content, bilingual, and lint-clean.

`ev_debug_002` is the fixture `main.gd:991` mounts for the ODA screenshot, so that call site
is repointed at `world.final_stretch_press` in the same change.

### `ev_seed_closed` — HOLD, untouched

Finished text in both locales for a seed round that does not exist. It stays in
`data/events/unwired/`, and the new loader excludes that directory **by name** rather than by
accident — today it is inert only because the old loader is a single non-recursive constant,
and its cards have empty conditions, which the new evaluator reads as TRUE. A recursive loader
that did not know about the directory would fire it on day 1.

---

## B · Code-built families — PORT to authored cards

The eleven families the factories mint. Each becomes an authored card with a signal or
condition trigger, and the hand-rolled latch in the owning system is deleted in favour of the
card's own `latch`.

| family | owner | latch it hand-rolls today |
|---|---|---|
| `ev_b2b_retain_<cid>` | B2BSalesSystem | `Customer.last_risk_exit_day` + 21-day hysteresis |
| `ev_b2b_expand_<cid>` | B2BSalesSystem | `Customer.last_expansion_day` — the K2 fix |
| `ev_b2b_escalation_<cid>` | B2BSalesSystem | `Customer.cs_escalated` |
| `ev_b2b_request_<cid>` ×3 branches | CustomerRepSystem | `support_request_since_day` + a weekly cap |
| `ev_hr_resign_<id>` | HRMoraleSystem | `_pending` static array |
| `ev_angel_frank_seed` | AngelRoundSystem | flag `angel_seed_offered` |
| `ev_angel_hire_nudge` | AngelRoundSystem | flag `angel_nudge_shown` |
| `ev_phase_gate_*` ×2 | PhaseGateSystem | `phase_gate_ready` ratchet |
| `ev_mvp_ship_moment` | ProductSystem | the lifecycle edge itself |
| `ev_mvp_version_ship_moment` | ProductSystem | none — fires per ship, correctly |
| `ev_mvp_iter_decision_intro` | ProductSystem | `_iter_intro_shown` static bool |
| `ev_vc_meeting_prompt` · `ev_sheet_expiry_warning` · `ev_vc_last_answer_day` | VCPitchSystem | see below |

**`ev_sheet_expiry_warning` carries a real bug into the migration.** It is the one injection
site with no latch at all, and worse: `_build_expiry_warning_event` writes a **constant** id
while `MAX_SHEETS` allows more than one live sheet. Two sheets warning on the same day produce
**one card**, and the survivor names the wrong investor's deadline. The ported card is
namespaced per VC, which is what its sibling `_build_deal_prompt_event` already does and
documents.

### RETIRE — already inert or unreachable

| id | why |
|---|---|
| `ev_buyout_offer` | no caller; both former injection sites keep only their latch writes. `pivot_accept` **asserts it never reaches the queue**, so re-authoring it onto disk would fail a smoke case |
| `ev_vc_deal_prompt_<vc>` | no caller, two levels deep; `deal_prompt_is_inert` asserts it |
| `HREventFactory._positive` | zero callers, builds an empty shell with no body and no choices |
| `HREventFactory._money` | zero callers |

Two HR beats are **structurally unreachable** rather than merely unused — `ev_hr_ship_glow`
and `ev_hr_big_signing` never fired once across eight played runs totalling 2,290 simulated
days. They are ported anyway, because the audit shows their *gates* are wrong rather than their
content, and a working gate is a one-line condition in the new vocabulary.

---

## C · Smoke cases: repointed, never deleted

GDD §22.2: *"Emekli kartlar üzerinden sonlara ulaşan smoke case'leri yeni kartlara
yönlendirilir, silinmez."* **37 cases** reference the event layer directly. Each is repointed
at the *behaviour* it was testing rather than at the card id it happened to use.

Two cases are **red before this task started** and stay red by ruling:
`save_migration_v7_to_v8` and `trait_migration_real_load` write sub-9 save fixtures through the
real load path, which `MIN_LOADABLE_VERSION` refuses before the migration ladder runs. Out of
scope. The related finding is worth more than the repair would be: their three sibling cases
pass only by calling `_migrate_*` directly — the shortcut `endgame_smoke.gd:8758` warns
against — so **none of the five actually proves the migration ladder runs end to end.**

---

## D · Filed to the writing round, not built here

- **The Ekip raise-request card and the summer-leave card.** These are morale's only two
  recovery channels, and a 245-day probe watched a single employee drift 75 → 44 with no
  recovery at all. This rebuild opens the `raise_requested` emit site, which is the engine half;
  the cards are content and belong to the writing round. Filed explicitly so that round
  inherits them rather than rediscovering the gap.
- **Variant text per node.** `EVENT_POOL_DESIGN_v1.md` §5.7 asks for 2-3 bodies per node so a
  repeating card never reads the same twice. The engine schema does not carry it and the GDD
  does not mention it. Filed rather than silently dropped.
- **The twelve card families the audit found never appear at all** in a normal run. Their gates
  need a design pass, not an engine one.

---

# PORT COMPLETE — 2026-08-25

**40 cards** in `data/events/cards/`, replacing 15 authored JSON files and 13 code-built
families. Three of the 40 are GDD §19.5's worked examples, which are also the soft-cap
telegraph.

| directory | cards | |
|---|---|---|
| `product/` | 12 | the MVP build family plus the three ship/design beats |
| `customer/` | 11 | the B2B family, now one card each instead of one per account |
| `funding/` | 7 | angel, both gates, the VC trio, the shutter warning |
| `world/` | 3 | the soft-cap ladder |
| `_fixtures/` | 4 | engine tests, `version_scope: fixture`, G2-blocked in any real build |

## The three things the port changed structurally

### 1 · A per-account card became one card

`ev_b2b_retain_<customer_id>` minted a fresh event per account with the id carrying the
customer. That id-namespacing existed to emulate a per-account brake, which is what
`latch_key: entity` **is**. So one authored `customer.retention` now covers every account, and
the brake is declared rather than encoded in a string.

Same for expansion, escalation, the three CS request branches, and the resignation card.

### 2 · A hidden option became a locked one

The factory built the "promise it" row **only if** there was something left to promise. §3.3 is
explicit that a locked option is shown greyed with its reason and never hidden, so the three
build-time conditions became `requires` plus a `locked_reasons` line.

**This is a visible behaviour change and it is deliberate.** The player now learns the row
exists and why they cannot take it, instead of meeting a card that has three options one day
and four the next with nothing to explain the difference.

### 3 · Two mechanisms the schema gained, both because a ported card needed them

- **`{seam:name}` interpolation in body text.** §8.4 already requires it for numbers and names
  the bug it prevents — `END_META_BANKRUPTCY_FRANK` saying *"yedi gün"* while `SHUTTER_DAYS`
  is 30. The B2B family needs the same for prose: one card carries
  `{seam:musteri.complaint_voice}` instead of fifteen near-copies each hard-coding one sector's
  line.
- **`body` may be `{by_seam, variants}`.** The Series A gate already rewrites its own body by
  decline count, so variant text was shipping before the schema had a word for it. This is
  `EVENT_POOL_DESIGN_v1` §5.7 delivered narrowly, for the one card that needs it.

## A deviation recorded: ported text keeps its CSV key

§3.2 puts card text inside the card. The code-built families' text is already in
`localization/strings.csv` — about 60 rows, written, reviewed, and gated by
`loc_csv_integrity`. Copying them into JSON would give one reviewed string two homes, and the
two would drift the first time either moved.

So a text value matching `^[A-Z0-9_]+$` resolves through `TranslationServer`; anything else is
literal prose. New content writes prose inline, which is the GDD's shape. Ported content keeps
its key until the writing round rewrites it, and the linter can tell the two apart.

## What the port did NOT fix, and why

**42 dash violations** in inherited copy (16 bodies, 26 option labels). Rewriting
director-approved prose is outside this task, and baselining build-stopping errors would
manufacture an assurance that does not exist. The linter reports them as **W with the old id
named**, on a count that may only fall. See `EVENT_ENGINE_QUESTIONS.md` Q18.

**The 13 option labels shaped `action — justification`**, several of which pre-judge the choice
for the player — which the EVENT AUTHORING LAW forbids outright. Same disposition, and the
editorial reason is stronger than the punctuation one.

**Twelve card families the audit found never appear in a normal run.** Their gates need a
design pass. The engine now makes those gates visible — `--why-fire=<id>` answers exactly this
question — which is the precondition for fixing them, not the fix.

---

## What the SWAP found that the port had missed

The sections above were written while the cards were being authored, against the old engine's
source. This section was written after the facade was swapped and the suite was run against the
result, and it is the more useful half: a port reads correct until something executes it.

**Seventeen defects, in four families.**

### The trigger was wrong (4)

Four cards were given a signal emitted by their own consequence. `team.resignation` on
`employee_departed` — emitted by `CharacterRegistry.remove`, which the card's own option calls.
`product.first_ship` and `product.version_ship` on `version_shipped` — emitted at the END of
`ship_active_build`, which those cards' options call. `product.design_round_intro` on
`build_iteration_decision_pending`, which is emitted `false` at two sites and `true` only at
the round cap, i.e. at the wrong end of the ladder. All four are `tick: request` now, named by
the system that sees the edge.

### The subject was wrong (5)

- `customer.cs_escalation` selected `lowest_satisfaction` and then asked whether that account
  was escalated — two different customers on most days, and the card silently never fires.
- `funding.sheet_expiry` had no investor selector at all, so the slot bound whoever sorted
  first: the constant-id bug the port existed to fix, rebuilt in the new vocabulary.
- `funding.meeting_day` likewise.
- Four customer cards (`bug_complaint`, `power_user`, `showcase_feature`, `referral`) had no
  scope block, so every customer-scoped effect on them resolved to nothing. The old executor's
  default target — `get_lowest_satisfaction_customer(<the event's market>)`, computed at apply
  time — had not been ported with the effects.
- `customer.request_*` required `musteri.is_assigned`, which the old builder never did: it took
  the DESK LEAD, so the channel worked for founder-managed accounts and the port broke it.

### The effects were wrong (4)

- `customer.retention`'s discount row carried `add_reputation: +1`; the constant is `-1`.
- `customer.cs_escalation`'s refuse row had lost its `churn_customer` entirely and both its
  magnitudes were wrong (brand -2 for -3, morale -3 for -10) — refusing the rep's word is what
  ENDS the account, and a refuse that costs two brand points and keeps the customer is a
  different decision wearing the same label.
- `churn_customer` had been flattened to `remove`, losing the B2C branch: one consumer
  complaint would have deleted the entire userbase.
- `start_vc_meeting` read a literal `vc_id` off the effect, which no card can know at authoring
  time.

### The surface was wrong (4)

- Every promise and discount row on the request and escalation cards shipped UNLOCKED. The old
  builders withheld those rows by not building them; a card is data, so the row exists and must
  lock (§17.5).
- `product.version_ship` was classed `info` with an empty option — `active_build` would never
  have cleared after a version ship.
- `funding.hire_nudge` was classed `info` and left in the weighted pool: a deterministic
  one-shot beat arriving on some runs and not others.
- `customer.frank_intro` and `product.paid_tier`, likewise pool content — the two cards that
  hand the player their first B2B prospect and open B2C revenue.

### And one that was not the port's fault at all

**`world.final_stretch_press` was step one of its own arc AND the only thing that could start
it.** §10.10 keeps an arc step out of the pool, so the step could not fire until the arc ran
and the arc could not run until the step fired. The entire soft-cap telegraph was unreachable
content, and three gates plus a 278-case suite passed over it. §17.2's reachability rule found
it on the linter's first run.

---

## The migration's own lesson

Every one of these reads correct in the diff. The port was not careless — it was a translation,
and a translation that preserves every word can still change what the sentence does. What
caught them was not review: it was the executor refusing, a selector finding nobody, a smoke
case asserting an old behaviour, and a linter asking whether a card can fire at all.

That is the argument for building the tooling BEFORE the content it grades, which is what the
revised phase order did, and the one place where following the plan paid for itself outright.
