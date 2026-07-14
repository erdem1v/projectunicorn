# VC_PITCH_DESIGN.md — Series A Hunt: Pitch Meetings, Conviction & the Sheet Economy

**Status:** Hat-1 design for Erdem's approval (2026-07-14). On approval → canon, amends ENDGAME_DESIGN.md §5.
**Consumers:** Erdem + Claude (design), then Fable + developer agents (spec derives from this).
**Revision rule:** everything here is a current working answer, not a contract.

---

## 0. Design thesis & experience goals

The pitch meeting is the demo's performance climax: the player has spent ~150 days building a company, and now has to *perform* it in a room. Three feelings must land, in order:

1. **"They're judging what I actually did."** Every meeting reads the real run state — the scandal you fumbled, the engineer you never hired, the churn you ignored. No generic pitch quiz.
2. **"I lost that room, and I know exactly why."** Failure is legible: visible odds, visible conviction, visible cost of every choice. Sting without injustice.
3. **"I played the investors against each other."** The sheet economy (validity windows + leverage) turns 4 separate meetings into one meta-game. This is the mechanic players will describe in reviews.

The review-quote targets we are designing for: *"I walked out of a term sheet to chase a better one and nearly died"* / *"the VC asked about the exact scandal I thought I'd buried"* / *"turned down the acquisition, closed the round, felt like a genius."*

---

## 1. The Hunt phase loop (player's week-to-week)

Series A Hunt = a race between the **pitch calendar** and the **runway**, mediated by the **sheet clock**.

**Actions available (Hunt vocabulary):**
- **Toplantı iste** — request a meeting with any open VC. Lead time: 3 days (working). One pending request at a time (zero-gap simplicity).
- **Hazırlık** (optional, before a scheduled meeting) — 2 days, pick ONE focus: *Rakamları çalış* (+ to metric checks) / *Hikâyeyi kur* (+ to narrative checks) / *Zayıf noktayı prova et* (+ to interrogation check). Prep occupies founder capacity (couples with the capacity pool from the sprint/build task: prepping founder = product work slows — visible, honest cost).
- **Toplantıya gir** — the 4-beat meeting (§4). Single sitting.
- **Teklifler paneli** — manage active sheets (max 2), see validity countdowns, compare, **Masaya otur** (opens the Term Sheet Table per canon §5.2).

**Worked timeline (median case, proving the math fits):** enter Hunt ~D120. Request(3) + prep(2) + meeting = ~6 days per attempt. Four VCs, one callback loop, one table sitting ≈ 35-45 days of activity inside a 60-day window. Tight but fair; a player who enters Hunt late (D150+) feels real compression — intended.

---

## 2. InvestorRegistry — the roster (4 + 1 teaser)

| VC | Character (one line, Frank register) | Conviction leans toward | Term tendency at table |
|---|---|---|---|
| **Anchor Capital** | "Agresif ama cömert. Kontrolü sever." | Metrics + momentum (MRR growth rate) | High valuation, wants board+veto, mid patience |
| **Nexus Ventures** | "Temkinli. Kurucuyu sever, riski sevmez." | Team + discipline (no unmanaged scandal, hires made) | Lower valuation, clean terms, high patience |
| **Bosphorus Partners** | "İlişki adamı. Kapıyı Frank açar." | Narrative + warm intro (Frank connection = starting bonus) | Middle terms, low patience if pushed on board |
| **Meridian Growth** | "Sektörü senden iyi bilir. Sabrı yoktur." | Product depth (İnovasyon/quality dimensions, subgenre-matched) | Generous valuation, LOW patience pool |

A fifth card sits in the investor list **locked**: "— · Tier 2'de" (Coming Soon treatment, wishlist telegraph).

One registry feeds BOTH systems: archetype weights the meeting's check difficulties AND writes the table's opening offer + patience pool. Consistency is free.

Cascade math: 4 VCs, cascade at 3 closed tables → one VC always remains un-tried. The "keşke ona gitseydim" ache is designed, not accidental.

---

## 3. The conviction instrument

Visible horizontal track, three zones (working): **Soğuk 0–39 / Ilık 40–69 / Kazanıldı 70–100.** The meeting's only gauge — the patience gauge's sibling, same visual family.

**Seeding — the §10 macro moment:** starting conviction is written by run state before the first line of dialogue:
- Base 20
- + MRR vs. traction threshold (scaled)
- + brand above floor / − below
- + healthy runway / − shutter-active or thin runway
- − unmanaged major scandal
- + active leverage sheet in pocket (significant)
- + warm intro (Bosphorus via Frank)
- + archetype-matched product dimension (Meridian)

Formula centralized in one function; values are calibration items. The player SEES the starting position and a short "why" breakdown on the meeting's opening card (3 lines max, e.g. "MRR güçlü · Runway dar · Skandal izi") — legibility rule: the room's mood is never a mystery.

---

## 4. The meeting — four beats, one sitting

Left ~60% scene artwork, right ~40% dialogue column (Disco proportions). All checks: visible odds, Disco-style difficulty labels, inline resolution (no dial in meetings — the dial stays reserved for the table's big pushes; four dial spins per meeting would dilute it).

**Beat 1 — Odayı Oku (read the room).** Low-stakes perception check.
- Success: reveals the VC's **tell** — (a) their favored narrative angle (Beat 2's matching option gets a marker), (b) the interrogation topic in advance ("Skandalı soracak.").
- Failure: no penalty, no intel. You pitch blind. (Fair: the cost of failure is information, not position.)

**Beat 2 — Anlatı (the pitch).** Choose the angle: **Metrik / Vizyon / Traction hikâyesi.** Difficulty per option = archetype fit (metric pitch to Anchor: Kolay; vision pitch to Anchor: Çetin). Success moves conviction up (working +15..+25 by margin); failure small drop (−5) — the real price of failure is the spent beat.

**Beat 3 — Sorgu (the interrogation).** The meeting's heart. The VC attacks your **actual weakest point**, derived from run state by priority: unmanaged scandal > zero engineers > high churn > thin runway > rival dominance (startup league position) > generic fallback. The question names the specific thing ("Mart'taki veri sızıntısı. Anlat.").

> **Revision (Spec 4, 2026-07-14 — DOMAIN interrogation, now in force):** the global weak-point list above is superseded by **per-VC domain interrogation**. Each investor owns a domain (Anchor=metrics, Nexus=team, Bosphorus=narrative, Meridian=product); Beat 3 attacks the worst item found *within that VC's domain*, from a per-domain priority list read from real state:
> - **metrics:** churn spike > growth flat > MRR concentration
> - **team:** unmanaged scandal > zero engineers > solo-founder risk
> - **narrative:** rival league position > refused acquisition > reputation low
> - **product:** active bug count > weakest dimension > stability erosion
>
> If the VC's whole domain is clean, the VC acknowledges it (a small payoff line) and the Sorgu check drops to **Kolay**. This makes each investor read the run through their own lens — the metrics VC never grills you on the team, and vice versa — so *who* you pitch matters as much as *what* you say. (Implemented in `VCPitchSystem._pick_sorgu_target`; a few items use working proxies where no dedicated field exists yet — churn spike, MRR concentration, refused-acquisition — flagged in code for calibration.)

Player answers with one of three visible **postures** (risk profiles printed on the options):
- **Dürüst** (admit + plan): moderate check; success +20, failure −8 (honesty cushions the fall).
- **Spin** (reframe as strength): hard check; success +28, failure −15.
- **Geçiştir** (deflect): easy check; success +5, failure −5, and **visibly caps this meeting's conviction at 65** (below Kazanıldı) — printed on the option as "güvenli, ama masa buradan çıkmaz." Dodging can never win the room outright; it can only protect a callback.

**Beat 4 — Kapanış (the close).** Resolves by conviction zone:
- **Kazanıldı (≥70):** term sheet granted. VC states the flavor of the offer to come ("Sana bir teklif göndereceğim. Beğenmeyebilirsin ama ciddi.").
- **Ilık (40–69):** the player chooses —
  - **CALLBACK'i kabul et** (safe): VC names a concrete, trackable condition (§5).
  - **Masayı zorla** (push-your-luck echo): one final Zorlu check. Success → sheet. Failure → RET. The family resemblance with the table is deliberate — greed is always available, always priced, always visible.
- **Soğuk (<40):** RET. `vc_rejections += 1`. Frank line on exit, short and dry.

Interior monologue (unnamed italic voice, existing B2B register — we are NOT building Disco's 24 named skills; scope wall) runs at low frequency in beats 1–2, peaks in Beat 3 ("Skandalı soracak. Sorduğunda gözünü kaçırma."), and lands one closing observation per meeting maximum.

---

## 5. Outcomes in detail

**Term sheet = an object with a clock.** Granted sheets land in the Teklifler panel: VC name, headline terms preview (valuation band, dilution band, board demand — the table refines them), **validity 14 days** (working), countdown visible. Max 2 active sheets. The player chooses WHEN to sit at the table, inside the window.

**Sheet expiry:** VC closes permanently ("Süresi doldu" badge) but does **NOT** count as a rejection — the cost was paid in time. Warning at 3 days remaining (visible-counter principle; nothing dies unannounced).

**CALLBACK contract:** concrete condition from a small set (working): MRR +20% over meeting-day value / active bugs under N / first engineer hired / scandal resolved. Auto-checked daily; when met → "Kapı yeniden açıldı — <VC>" notification; re-request grants a conviction starting bonus (+10). **One callback per VC.** A second meeting ending Ilık → RET (no infinite lukewarm loop). Unmet by Day 180 → dies with the run, no penalty.

**RET:** VC closed ("Reddetti"), `vc_rejections += 1`, feeds the cascade exactly per canon §4.5.

**Walking the table** (existing canon): sheet destroyed, +1 rejection, VC closed ("Masadan kalktın"). Any OTHER active sheet survives — walking one table to sign the other is a legitimate power move and should feel like one.

---

## 6. Leverage — the meta-game (ENDGAME amendment)

This section AMENDS canon §5.4: leverage previously assumed "a second term sheet in hand" without a mechanism to hold one. The sheet-as-object model provides it:

Sheet from VC-A starts a 14-day clock → player races to win a second sheet from VC-B inside the window → sits at either table with leverage: **all push odds get a significant bonus**, the opening offer improves one notch, and Frank whispers the canon line. Three clocks now squeeze each other — runway (money), validity (offer), calendar (meetings) — the Frostpunk promise of the Hunt phase, delivered.

Signing any sheet = instant Hard Win (canon unchanged): `series_a_closed = true`, variant read from the signed table photo.

---

## 7. Field writes & architecture (engine contract)

- **New:** `InvestorRegistry` autoload (CustomerRegistry pattern, forward-compat fields incl. Tier 2 reserved slots). `PitchSystem` — `class_name`, static, RefCounted (system purity rules). `TermSheet` data model (Resource): vc_id, granted_day, expires_day, term bands, leverage_flag.
- **GameState additions (serialized set):** `active_sheets: Array`, `vc_states: Dictionary` (open/closed+reason/callback condition), `pending_meeting` (vc_id + day), `run_pitches: int`, `run_sheets_won: int` (run-summary counters; `run_pushes_*` already reserved).
- **Writes to existing engine fields:** table SIGN → `series_a_closed = true` (Class A). RET / walk → `vc_rejections += 1`. Callback + expiry → counter untouched.
- **Meeting-local state (conviction, beat index, intel) is NOT serialized** — single sitting, no mid-meeting save (same rule as the table).
- Signals (working set): `sheet_granted`, `sheet_expired`, `callback_ready`. Meeting/table UI mounts via the modal conventions.

---

## 8. Zero-gap ledger — additions 12–24 (copy into specs verbatim)

12. **Shutter × pitch:** meetings allowed during Kepenk — thematically right ("sinking founder fundraises"), already priced (conviction seed penalizes thin runway); Frank warns once on scheduling.
13. **Single sitting:** meeting and table are unsaveable mid-flow; speed 0 while open, restore per modal convention.
14. **Sheet expiry never surprises:** validity visible in the Teklifler panel AND a TopBar chip when ≤3 days ("Teklif: 3 gün"); expiry warning event at day 3.
15. **Max 2 active sheets** — third sheet cannot be granted while two are live (a VC who WOULD grant states it: "Önce masandakileri temizle." — meeting still counts as won; sheet delivered when a slot frees, validity starts then). *(Working call — the alternative, hard-blocking a third meeting, is simpler; Erdem picks.)*
16. **Day 180 with a live sheet:** the fork evaluates normally — no auto-sign. D179 Frank warning: "Yarın son gün. Cebinde teklif var." Ending screen references the unsigned sheet (bittersweet line).
17. **Cascade requires zero active sheets.** A player holding a live sheet cannot cascade (they hold a win path). Third rejection while a sheet lives → cascade check DEFERS until that sheet is signed/walked/expired. (Gap caught in design — without this rule, pivot could fire while the player holds victory in hand.)
18. **Pivot closes the Hunt UI:** after pivot, investor list greys out entirely ("Pivot — bootstrap yolu"), pending callbacks die, active sheets — impossible by 17.
19. **Acquisition × sheets:** acquisition offer can coexist with a live sheet (choosing the soft win over the gamble is a valid, dramatic decision — deliberate, mirrors ledger 5).
20. **Terminal mid-anything:** run_ended flush kills pending meetings, callbacks, sheet clocks (all ride GameState + queue; existing flush covers — verify in spec).
21. **Meeting × month-end same day:** meeting is player-initiated and modal; month summary queues behind per dispatch order — verify, no special code expected.
22. **Focus:** ledger 11 applies to every meeting choice list and the Beat-4 fork.
23. **Closed VCs stay visible** with reason badges (Reddetti / Süresi doldu / Masadan kalktın / Callback bekliyor) — no fake choices, the roster always tells the truth.
24. **One pending meeting request at a time;** requesting elsewhere cancels nothing silently — the UI blocks with the reason shown.

---

## 9. Win budget & pacing check (against canon §4.7)

Hard-win routes: direct Kazanıldı; Ilık→Masayı zorla; callback loop; leverage-boosted table. Loss pressure: 3-rejection cascade, sheet expiry burn, D180 wall. Rough path math at median skill keeps hard win in the ~45–50% band with callbacks as the main rescue valve and Masayı zorla as the main self-inflicted wound — matches budget. All numeric knobs (zone bounds, deltas, seeds, validity, prep bonus) are single-pass calibration items; the doc fixes STRUCTURE only.

---

## 10. Mockups & artwork needed (Erdem's build list)

**UI mockups (design-language prompts, like the previous three):**
1. **MeetingScene — ana durum.** Left artwork area (placeholder frame), right dialogue column: VC header + conviction track with zones, dialogue history (VC lines + italic interior monologue), choice list showing posture labels + visible odds ("Dürüst — Orta, %62"), Beat-1 intel marker on a favored option.
2. **MeetingScene — Kapanış çatalı (Ilık).** Same shell, the CALLBACK vs Masayı Zorla decision moment: two options with printed risk profiles, conviction sitting in the Ilık zone, tension framing. (This is the screen that teaches push-your-luck grammar — worth its own mockup.)
3. **Series A Hunt paneli / Teklifler.** Investor roster (4 cards + locked Tier-2 card) with state badges, active sheets with validity countdowns + "Masaya otur" CTA, callback condition chip, pending meeting indicator. This is effectively the Hunt-phase tab.

**Artwork packs (illustration prompts, separate style-locked set):**
4. **VC portreleri** — 4 portraits, one consistent editorial style (matte, restrained palette, our cream/charcoal world).
5. **Toplantı odası sahneleri** — 1 base meeting-room illustration + light per-VC variance (or 4 rooms if the tool cooperates). Landscape, sits in the MeetingScene left panel.

Term Sheet Table mockup: already approved (revised version). Month-End + Newspaper: already approved.

---

## 11. To-do sequence (post-approval)

1. Erdem approves/edits this doc → canon; ENDGAME_DESIGN.md §5.4 amendment noted.
2. Erdem builds mockups 1–3 (+ artwork 4–5 in parallel).
3. Claude writes Spec 4 (pitch logic: InvestorRegistry, conviction engine, beats, sheets, callbacks, field writes, ledger 12–24 guards, smoke cases) — logic is mockup-independent, can dispatch immediately after approval.
4. Mockups approved → Spec 5 (MeetingScene + Hunt panel UI) on top of real signal names.
5. Both land → full-loop windowed run (pitch → sheet → table → sign → newspaper) → **GitHub sync + the batched commits.**
6. Calibration pass LAST (single session, all knobs incl. MRR curve question).

## 12. Open working calls for Erdem (answer inline, no essays needed)

A. Ledger 15: third sheet handling — "delayed delivery" (as written) or hard-block the third meeting while 2 sheets live (simpler)?
B. Geçiştir posture's visible conviction cap at 65 — approve the "deflection can't win the room" rule?
C. Masayı zorla failure = RET (hard) — approve, or soften to "callback with worse condition"? (I recommend hard — the risk must be real.)
D. Prep occupying founder capacity (product slows during prep) — approve the coupling?
E. Sheet validity 14 days / max 2 — feel right as working values?
