# DEFECT · `b2c_satisfaction_gate_experience` — a second daily writer of B2C satisfaction

**Filed 2026-08-26 by the event-engine rebuild. Owner: Ops / Support (`support_system.gd`),
with `infra_system.gd` as a contributing source.** Not an event-engine defect; filed here
because the diagnosis names a module and the case does not belong to whoever finds it failing.

## The symptom

`endgame_smoke.gd` → `_case_b2c_satisfaction_gate_experience`, three legs against
`SalesSystem.SATISFACTION_QUALITY_GATE` (40) and `SATISFACTION_BUG_GATE` (5):

| leg | setup | expected | observed |
|---|---|---|---|
| 1 | experience 25 → axis 50, bugs 0 | 50 → **51** | 51 ✓ |
| 2 | experience 10 → axis 28.6, bugs 0 | 50 → **50** | **49** ✗ |
| 3 | experience 25, bugs over the gate | 50 → 50 | not reached |

`experience 10 (axis 28.6) moved satisfaction (49)`.

## What it is not

It is **not** the experience gate. Leg 2 falls through `_tick_satisfaction` with `delta == 0`:
`exp_axis` is under 40 so no `+1`, `bugs` is 0 so no `-1`. The observed value is one point
**below** the seeded 50, which no branch of that function can produce.

It is also not live-bug accrual, which was this rebuild's first (wrong) guess.
`ProductSystem._post_ship_wear_hourly` is the only writer of `mvp_live_bug_count`, it runs on
the **hourly** path, and the case drives `_sim_day()` — daily slots only.

## What it is

`SalesSystem._tick_satisfaction` is no longer the only thing that writes the B2C aggregate's
satisfaction on a daily tick. `SupportSystem.daily_tick` (`support_system.gd:169`) calls
`apply_daily_satisfaction_damage()`, which for a B2C market targets
`SalesSystem.B2C_USERBASE_ID` — the same record — and writes through
`CustomerRegistry.set_satisfaction` (`support_system.gd:371`).

The damage is **fractional and carried**. `_bleed` keeps a residue per customer and applies a
whole point only when the carry crosses:

```gdscript
var carried: float = float(_damage_residue.get(c.id, 0.0)) + share
var whole: int = int(ceil(carried))       # damage is negative; rounds toward zero
_damage_residue[c.id] = carried - float(whole)
```

**That is exactly the shape of the symptom.** A sub-1.0 daily bleed leaves leg 1 untouched —
which is why leg 1 passes and reads as a clean +1 — and lands its whole point on the next day,
which is leg 2. A case that seeds satisfaction to 50 and asserts it is still 50 after a day is
measuring the sum of two systems while believing it measures one.

Contributing sources feeding `daily_satisfaction_damage()`:

- `unvalidated_damage_per_day()` — scales with `ProductState.reports_incoming()`.
- `confirmed_damage_per_day()` — scales with confirmed reports.
- `InfraSystem.satisfaction_delta_per_day()` — `OVERAGE_SATISFACTION` (−0.8/day) when the live
  product is over capacity.

**Which of the three supplies the point was not pinned in this pass**, and pinning it is the
owning module's call, not the finder's. `_seed_b2c` adds 200 audience against a B2C unit of
1000 users, so infra overage is unlikely to be it on its own; the report-driven terms are the
first place to look.

## Age

**Red in the P0 baseline of the event-engine rebuild** — `SMOKE SUMMARY 267/278`, eleven reds,
this among them — taken before that task's first edit. Eight of the other ten went green during
the task without being touched, which says other work was landing in the shared tree; it says
nothing about this one.

## What the fix probably is

Not a change to `SalesSystem`. Either:

1. the case seeds a support-quiet world (`REPORTS_INCOMING` = 0, confirmed = 0, capacity
   headroom) and states in a comment that it is isolating the quality gate from the support
   bleed; **or**
2. the case asserts the *delta the quality gate contributes* rather than the record's absolute
   value, which is what it actually means to test.

(1) is smaller. (2) is what the case is for. Either is a two-line change in the owning module's
own test, and neither should be made by a task that does not own the satisfaction model.

## Cross-reference

`docs/EVENT_ENGINE_QUESTIONS.md` § C1 — where the event-engine rebuild's original, incorrect
attribution is recorded and corrected.
