# FRANK · ORPHAN REPORT

Every Frank line in the build that does **not** appear in
`docs/content/events_draft/Frank Diyalogları · v6.md`, after the v6 landing pass (2026-08-20).

Erdem decides, per row, whether it is a surface the document missed or a duplicate of one it
already covers. A row whose key has no reader left is deleted with the key.

Method: every CSV key in the Frank families plus every key whose Turkish or English value
contains "Frank" (109 keys), each checked for a live reader across `scripts/`, `scenes/` and
`data/`; then the non-CSV surfaces by hand.

---

## A · Frank speaks, the card is live, the text is not in the document

These fire in a normal run today.

| key(s) | where it renders | what fires it | reads like |
|---|---|---|---|
| `PROD_EV_VERSION_SHIP_BODY` (+ `PROD_SHIP_VERSION_TITLE`, `PROD_SHIP_CONTINUE`) | EventModal, every v2+ ship | `ProductSystem._trigger_ship_moment(is_version = true)` | **Same shape.** Bölüm 3 lists "her sürüm yayını" as a place Frank is removed; no replacement text exists. Note the first-ship twin (surface 4) *was* rewritten, so this card now sits next to a rewritten sibling in a different voice |
| `PROD_EV_ITER_DECISION_BODY` (+ `PROD_DESIGN_DECISION_TITLE`, `PROD_ITER_KEEP_GOING`, `PROD_TO_DEVELOPMENT_PLAIN`) | EventModal, end of design round 1 | `product_system.gd` hourly build seam, latched once per run | **Explicitly deferred, not missed.** The document's closing section says the design-round card (3) is not being written until the Build Bar work is finished, and flags that one of its two options does nothing. Awaiting authoring |
| `GATE_SERIES_A_TITLE`, `GATE_SERIES_A_BODY_0/1/2`, `GATE_ADVANCE`, `GATE_DECLINE` | EventModal, the Series A gate | `PhaseGateSystem`, MRR + growth streak + brand | **Awaiting design** (surface 12). Their dashes are gone (Faz Q K20): `GATE_ADVANCE` reads "Hazırız, geçelim" / "We are ready, let us move", and `GATE_SERIES_A_BODY_0` carries "Runway'in dar da olsa girebilirsin" / "Thin runway or not, you can walk in". `GATE_SERIES_A_BODY_2` was byte-identical to the Traction gate's `_BODY_2`; that duplicate is now gone from the other side |

---

## B · Frank text with no surface at all

| key(s) | where it renders | what fires it | reads like |
|---|---|---|---|
| `END_META_SERIES_A_CLOSE_FRANK`, `END_META_ACQUISITION_FRANK`, `END_META_BANKRUPTCY_FRANK`, `END_META_BRAND_COLLAPSE_FRANK`, `END_META_VC_REJECTION_CASCADE_FRANK`, `END_META_PROFITABLE_BOOTSTRAP_FRANK`, `END_META_RUNNING_ON_FUMES_FRANK` (7) | **nowhere** | built into `ending_data.frank_line` by `EndingsSystem`, but `EndingsCopy.build` sets every subhead from its own `END_*_SUB*` keys; `frank_line` is read only in an unknown-id fallback | **Authored, localized, never rendered.** The ending newspaper bans mentor attribution by design, so these need a surface (a Frank strip on `EndingScene`, or a pre-terminal beat) before they are text at all. Bölüm 3 lists "oyun sonu hükümleri" among the places Frank is removed, which may mean these should be **deleted** rather than given a surface — that is the ruling this row is waiting for |

**CLOSED 2026-08-27 (the funding-ladder wave).** Both halves of this row are resolved, and in
the order the row itself demanded — the number first, then the surface.

*The ruling:* the seven verdict lines are **kept and given a surface**, not deleted. Ch. 13 §2
is explicit that Frank's line renders on its own strip **outside** the newspaper, which is what
reconciles it with "oyun sonu hükümleri" appearing on the removal list: what Bölüm 3 removes is
Frank *from the paper*, and the paper never carried him. `EndingScene._build_frank_strip` paints
`ending_data.frank_line` on the dark gutter beneath the page, attributed to him by name. It is
outside `_export_paper_png`'s crop by construction, so the shared image is still a newspaper.

*The number:* `END_META_BANKRUPTCY_FRANK` now says **thirty**, in both columns, and nothing else
in the line moved — not a word. The em dashes went in the later dash sweep (Faz Q K20): the line
now reads "Rakamlar kaba değildir, sadece sabırlıdır." / "Numbers are not cruel, only patient."
The smoke case `bankruptcy_frank_line_says_thirty` pins the copy to `EndingsSystem.SHUTTER_DAYS`,
so the next retune of that constant cannot silently orphan it again. The contradiction this row
sharpened — `FIN_SHUTTER_COUNTDOWN` putting `KEPENK: 30 GÜN` on the top bar for all thirty days —
is gone.

*What was true when this row was written and is now history:*
`END_META_BANKRUPTCY_FRANK` said "Yedi gün kırmızıda kaldın" / "You stayed in the red for seven
days" while `EndingsSystem.SHUTTER_DAYS` had been 30 since the v6 pass. It rendered nowhere, so
nothing was on screen — and the row's own instruction was that it must not be given a surface in
that state. It was not: the number was fixed in the same commit that built the strip.

**The 30 is already on the player's screen, which is what makes this sharp.** `FIN_SHUTTER_COUNTDOWN`
(`strings.csv:502`, rendered by `top_bar.gd:256`) puts `KEPENK: 30 GÜN` in the top bar the moment the
shutter arms, and counts down truthfully from there. So the contradiction is not two dormant strings
disagreeing — it is a live counter the player watched run for thirty days against a closing line that
tells them it was seven. Whoever takes the surface-or-delete ruling above must fix the copy in the same
pass, never after. (Observed 2026-08-25 during the shutter smoke repair; no copy was changed.)

---

## C · Orphaned by this pass

Left in place and reported. Every row is a modifier arm with no remaining caller.

| key / symbol | was used by | why it is loose now |
|---|---|---|
| modifier `decline_vc_meeting` | surface 13's skip option | no caller left. The dispatcher arm stays: it is engine vocabulary, not content |
| modifier `decline_pivot` | `ev_pivot_offer`'s option 2 | no caller left. Same reasoning |
| modifier `open_term_table` + `EFFECT_TERM_TABLE` | surface 24's "Masaya otur" | landed the day before this pass. No **event card** reaches it now; the dispatcher arm, the effect chip, the `game_shell.gd` debug driver and the `main.gd` chip fixture all remain |

**Deleted, not orphaned** (removal stayed inside the event the document rewrote):
`GATE_TRACTION_BODY_1` and `GATE_TRACTION_BODY_2` — the escalation bodies of the Traction gate,
which had nothing left to select them once that card became a one-option notification.
`data/events/reactive/ev_ps_first_revenue.json` — surface 8, deleted with its `mentor_advisory`
payload as the document instructs.

---

## D · Frank named, not Frank speaking

Listed for completeness so the sweep is provably exhaustive. These are identity strings,
captions, badges, ledger rows and other characters talking *about* him — no voice, so they are
outside the document's scope by definition.

`MENTOR_NAME` · `MENTOR_ROLE` · `HR_ROLE_MENTOR` · `UI_AVATAR_INITIALS` ("FK") ·
`PROD_MENTOR_TAG` · `ODA_TOUR_PHONE_DESC` ·
`ANGEL_TX_LABEL` · `EFFECT_TO_FRANK` · `ANGEL_MONTH_HIGHLIGHT` · `GATE_OPENED` ·
`ODA_EVENTS_FRANK_HEADER` ("Frank'ten not") · `ODA_MENTOR_TAG_FALLBACK` · `EVENT_TAG_MENTOR` ·
`INV_APPETITE_GATE_OPEN` ("Kapı açık · Frank'le konuş") ·
`VC_WHY_WARM_INTRO` · `INV_ARCH_BOSPHORUS`.

One of these is worth a second look even though it is not voice: the stake beside
`EFFECT_TO_FRANK`, `EFFECT_EQUITY`, prints `%{equity}` in Turkish and `{equity}%` in English.
Both parse as one token so the integrity gate passes, but the two columns are not symmetric.

---

## E · Frank text outside the CSV

| where | what | status |
|---|---|---|
| `data/events/reactive/ev_debug_003_cash_warning.json` | a Frank-attributed debug card, Turkish only | **never loaded** — the loader skips the `ev_debug_` filename prefix. A fixture, not content |
| `scenes/ui/components/RightPanel.tscn` | hardcoded "Frank Köseoğlu" / "OPERATING PARTNER" plus an English quote | retired scene, never instantiated; `loc_residue.gd` skips it deliberately. Its script `right_panel.gd` still connects to `mentor_advisory_changed`, so it is a second listener on that signal if anything ever mounts it |
| `scripts/systems/month_summary_system.gd` `debug_force_summary` | a hardcoded Turkish month line | LOC-DATA layout fixture for `--modal-shot=month`; not a player path |
| `scripts/debug/endgame_smoke.gd` | `frank_line` assertions | test surface only |

---

## F · Not an orphan, but the document should be corrected

Recorded here so the source document and the build do not drift apart silently.

1. **Turkish placeholder names became engine tokens** in every landed string —
   `{yatırımcı}→{investor}`, `{gün}→{days}`, `{ay}→{months}`, `{eksen}→{axis}`,
   `{sürüm}→{version}`, `{rakip}→{rival}`, `{sayı}→{n}`, `{kol}→{lever}`,
   `{değerleme}→{valuation}`, `{teklif}→{offer}`. Prose is byte-exact; only the machine token
   moved, because the gate requires `[a-z_]+` names identical across both locales, and a
   Turkish-named token is not parsed as a token at all — it would have rendered on screen as
   literal `{yatırımcı}`.
2. **Surface 17 + 18's English body carried an author's note inline**, in Turkish, glued to the
   following word: `{investor} (buradaki investor bize seed turunda yatırım yapan
   yatırımcı)calls.` The task ruled that background "for your understanding only, not for the
   text", so the note was not landed and the line reads `{investor} calls.` The document should
   be corrected so the annotation does not reappear on the next read.
