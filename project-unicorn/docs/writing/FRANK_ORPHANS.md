# FRANK · ORPHAN REPORT

Every Frank line in the build that does **not** appear in
`docs/content/events_draft/Frank Diyalogları · v6.md`, after the v6 landing pass (2026-08-20).

**Nothing here has been deleted and nothing has been rewritten.** Erdem decides, per row,
whether it is a surface the document missed or a duplicate of one it already covers. This list
is the test of whether the document is complete, so it has not been shortened by tidying.

Method: every CSV key in the Frank families plus every key whose Turkish or English value
contains "Frank" (109 keys), each checked for a live reader across `scripts/`, `scenes/` and
`data/`; then the non-CSV surfaces by hand.

---

## A · Frank speaks, the card is live, the text is not in the document

These fire in a normal run today.

| key(s) | where it renders | what fires it | reads like |
|---|---|---|---|
| `PROD_MENTOR_LINE` (+ caption `PROD_MENTOR_TAG` "FRANK KÖSEOĞLU · MENTOR") | Frank strip in the product path picker, `creation_flow.gd` | first visit to the B2C/B2B step while `product_path_frank_seen` is false | **A surface the document intends to remove but does not replace.** Bölüm 3 lists "pazar seçimi şeridi" among the places Frank is *tamamen kaldırıldı*, but no surface in Bölüm 1 or 2 covers it and the task list does not name it. Removing it on that basis alone would be an inference, not a ruling |
| `PROD_EV_VERSION_SHIP_BODY` (+ `PROD_SHIP_VERSION_TITLE`, `PROD_SHIP_CONTINUE`) | EventModal, every v2+ ship | `ProductSystem._trigger_ship_moment(is_version = true)` | **Same shape.** Bölüm 3 lists "her sürüm yayını" as a place Frank is removed; no replacement text exists. Note the first-ship twin (surface 4) *was* rewritten, so this card now sits next to a rewritten sibling in a different voice |
| `PROD_EV_ITER_DECISION_BODY` (+ `PROD_DESIGN_DECISION_TITLE`, `PROD_ITER_KEEP_GOING`, `PROD_TO_DEVELOPMENT_PLAIN`, `PROD_ITER_CEILING_NOTE`) | EventModal, end of design round 1 | `product_system.gd` hourly build seam, latched once per run | **Explicitly deferred, not missed.** The document's closing section says the design-round card (3) is not being written until the Build Bar work is finished, and flags that one of its two options does nothing. Awaiting authoring |
| `GATE_SERIES_A_TITLE`, `GATE_SERIES_A_BODY_0/1/2`, `GATE_ADVANCE`, `GATE_DECLINE` | EventModal, the Series A gate | `PhaseGateSystem`, MRR + growth streak + brand | **Awaiting design** (surface 12). Also the last live Frank copy still carrying em dashes: `GATE_ADVANCE` "Hazırız — geçelim" and `GATE_SERIES_A_BODY_0`. The dash ban applies to whatever key is touched, so they clear when this surface is rewritten. `GATE_SERIES_A_BODY_2` was byte-identical to the Traction gate's `_BODY_2`; that duplicate is now gone from the other side |

---

## B · Frank text with no surface at all

| key(s) | where it renders | what fires it | reads like |
|---|---|---|---|
| `END_META_SERIES_A_CLOSE_FRANK`, `END_META_ACQUISITION_FRANK`, `END_META_BANKRUPTCY_FRANK`, `END_META_BRAND_COLLAPSE_FRANK`, `END_META_VC_REJECTION_CASCADE_FRANK`, `END_META_PROFITABLE_BOOTSTRAP_FRANK`, `END_META_RUNNING_ON_FUMES_FRANK` (7) | **nowhere** | built into `ending_data.frank_line` by `EndingsSystem`, but `EndingsCopy.build` sets every subhead from its own `END_*_SUB*` keys; `frank_line` is read only in an unknown-id fallback | **Authored, localized, never rendered.** The ending newspaper bans mentor attribution by design, so these need a surface (a Frank strip on `EndingScene`, or a pre-terminal beat) before they are text at all. Bölüm 3 lists "oyun sonu hükümleri" among the places Frank is removed, which may mean these should be **deleted** rather than given a surface — that is the ruling this row is waiting for |

**One of these is now factually wrong and was left alone under the do-not-rewrite rule:**
`END_META_BANKRUPTCY_FRANK` says "Yedi gün kırmızıda kaldın" / "You stayed in the red for seven
days", while this pass moved `EndingsSystem.SHUTTER_DAYS` from 7 to 30. It renders nowhere, so
nothing is on screen today, but it must not be given a surface in this state.

---

## C · Dead CSV twins — no reader anywhere

Duplicates of live keys, with zero references in `scripts/`, `scenes/` or `data/`. Two of them
carry a *different* English translation of byte-identical Turkish, which is how they were
identified as twins rather than as separate lines.

| key | twin of | note |
|---|---|---|
| `PROD_SHIP_FIRST_BODY` | `PROD_EV_FIRST_SHIP_BODY` | TR byte-identical before this pass, EN divergent. The live twin has now been replaced by surface 4, so the two no longer even match |
| `PROD_SHIP_VERSION_BODY` | `PROD_EV_VERSION_SHIP_BODY` | same pattern |
| `PROD_DESIGN_DECISION_BODY` | `PROD_EV_ITER_DECISION_BODY` | ends with a `{note}` token fed from `PROD_ITER_CEILING_NOTE` |
| `PROD_DESIGN_CEILING_NOTE` | `PROD_ITER_CEILING_NOTE` | the live one still has a reader in `product_system.gd` |

---

## D · Orphaned by this pass

Left in place and reported, per the rule that a Frank line outside the document is reported
rather than deleted. All four groups are strings and modifier arms with no remaining caller.

| key / symbol | was used by | why it is loose now |
|---|---|---|
| `VC_EV_ACK` ("Anlaşıldı" / "Understood") | the acks on surfaces 14, 15 and 16 | all three cards now carry the document's navigation option instead (`VC_EV_GO_FUNDING`, `END_EV_GO_FINANCE`) |
| `VC_EV_SKIP_MEETING` ("Bugün değil (randevu yanar)") | surface 13's second option | the document removes it: burning a booked meeting is not a choice the game offers |
| `DEAL_PROMPT_SIT`, `DEAL_PROMPT_DEFER`, `DEAL_PROMPT_VALIDITY` | surface 24's old two-option pair | replaced by the single navigation option; waiting is now the answer counter, not a card choice |
| `END_EV_PIVOT_TITLE`, `END_EV_PIVOT_BODY`, `END_EV_PIVOT_ACCEPT`, `END_EV_PIVOT_DECLINE` | `ev_pivot_offer` | that card merged into the buyout card (surfaces 17 + 18), which uses the `END_EV_ACQ_*` keys |
| modifier `decline_vc_meeting` | surface 13's skip option | no caller left. The dispatcher arm stays: it is engine vocabulary, not content |
| modifier `decline_pivot` | `ev_pivot_offer`'s option 2 | no caller left. Same reasoning |
| modifier `open_term_table` + `EFFECT_TERM_TABLE` | surface 24's "Masaya otur" | landed the day before this pass. No **event card** reaches it now; the dispatcher arm, the effect chip, the `game_shell.gd` debug driver and the `main.gd` chip fixture all remain |

**Deleted, not orphaned** (removal stayed inside the event the document rewrote):
`GATE_TRACTION_BODY_1` and `GATE_TRACTION_BODY_2` — the escalation bodies of the Traction gate,
which had nothing left to select them once that card became a one-option notification.
`data/events/reactive/ev_ps_first_revenue.json` — surface 8, deleted with its `mentor_advisory`
payload as the document instructs.

---

## E · Frank named, not Frank speaking

Listed for completeness so the sweep is provably exhaustive. These are identity strings,
captions, badges, ledger rows and other characters talking *about* him — no voice, so they are
outside the document's scope by definition.

`MENTOR_NAME` · `MENTOR_ROLE` · `HR_ROLE_MENTOR` · `UI_AVATAR_INITIALS` ("FK") ·
`PROD_MENTOR_TAG` · `PROD_READY_TALK_FRANK` ("HAZIR · FRANK'LE KONUŞ") · `ODA_TOUR_PHONE_DESC` ·
`ANGEL_TX_LABEL` · `ANGEL_CHIP_ACCEPT` · `ANGEL_MONTH_HIGHLIGHT` · `GATE_OPENED` ·
`ODA_EVENTS_FRANK_HEADER` ("Frank'ten not") · `ODA_MENTOR_TAG_FALLBACK` · `EVENT_TAG_MENTOR` ·
`EVENT_MENTOR_ADVICE` · `INV_APPETITE_GATE_OPEN` ("Kapı açık · Frank'le konuş") ·
`VC_WHY_WARM_INTRO` · `INV_ARCH_BOSPHORUS` · `PITCH_S0_NPC` · `PITCH_S0_INNER` ·
`PITCH_INNER_CLOSED`.

One of these is worth a second look even though it is not voice: `ANGEL_CHIP_ACCEPT` prints
`%{equity}` in Turkish and `{equity}%` in English. Both parse as one token so the integrity gate
passes, but the two columns are not symmetric.

---

## F · Frank text outside the CSV

| where | what | status |
|---|---|---|
| `data/events/reactive/ev_debug_003_cash_warning.json` | a Frank-attributed debug card, Turkish only | **never loaded** — the loader skips the `ev_debug_` filename prefix. A fixture, not content |
| `scenes/ui/components/RightPanel.tscn` | hardcoded "Frank Köseoğlu" / "OPERATING PARTNER" plus an English quote | retired scene, never instantiated; `loc_residue.gd` skips it deliberately. Its script `right_panel.gd` still connects to `mentor_advisory_changed`, so it is a second listener on that signal if anything ever mounts it |
| `scripts/systems/month_summary_system.gd` `debug_force_summary` | a hardcoded Turkish month line | LOC-DATA layout fixture for `--modal-shot=month`; not a player path |
| `scripts/debug/endgame_smoke.gd` | `frank_line` assertions | test surface only |

---

## G · Not an orphan, but the document should be corrected

Recorded here so the source document and the build do not drift apart silently.

1. **Surface 24 lost its `{investor}` token**, in the title and in the body, by ruling. Turkish
   suffixes take vowel harmony and consonant assimilation from the preceding word, so
   `{investor}'dan` produces the wrong suffix for most investor names and the engine cannot
   inflect; `loc_csv_integrity` then requires the token to come out of English too, since the
   two columns must carry an identical token set. The replacement text is in the CSV.
2. **Turkish placeholder names became engine tokens** in every landed string —
   `{yatırımcı}→{investor}`, `{gün}→{days}`, `{ay}→{months}`, `{eksen}→{axis}`,
   `{sürüm}→{version}`, `{rakip}→{rival}`, `{sayı}→{n}`, `{kol}→{lever}`,
   `{değerleme}→{valuation}`, `{teklif}→{offer}`. Prose is byte-exact; only the machine token
   moved, because the gate requires `[a-z_]+` names identical across both locales, and a
   Turkish-named token is not parsed as a token at all — it would have rendered on screen as
   literal `{yatırımcı}`.
3. **Surface 17 + 18's English body carried an author's note inline**, in Turkish, glued to the
   following word: `{investor} (buradaki investor bize seed turunda yatırım yapan
   yatırımcı)calls.` The task ruled that background "for your understanding only, not for the
   text", so the note was not landed and the line reads `{investor} calls.` The document should
   be corrected so the annotation does not reappear on the next read.
