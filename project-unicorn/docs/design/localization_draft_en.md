# `[DRAFT-EN]` register — English awaiting the director's literary pass

**Companion to the BILINGUAL BIRTH LAW** (CLAUDE.md) and the glossary
(`localization_glossary.md`). Every key listed here has a **flat-correct** English value: it
says the right thing, in the right register, and it is safe to ship — but it has not had the
voice pass that Turkish got. Tier A (labels, chips, buttons) is *not* listed; those are
finished on both sides.

**Why the tag is not in the CSV.** A `[DRAFT-EN]` marker inside a value would render on
screen. The register lives here instead, so the CSV stays clean and this file is the single
list the director reads. Each batch appends its rows.

**How to use it.** Rewrite the EN column of these keys in `localization/strings.csv`. The
Turkish is canonical and should not move. Deleting a row from this table is how a key is
marked "voice-passed".

---

## B1b — Sales / B2B (2026-08-19)

### Customer + rep event voices (`b2b_event_factory`)
| Key | What it is |
|---|---|
| `B2B_EV_EXPANSION_BODY` | the customer asking to add seats |
| `B2B_EV_REP_WARN_BODY` | the account manager's escalation, in their own voice |
| `B2B_EV_COMPLAINT_HARD` · `B2B_EV_COMPLAINT_SOFT` | the rep relaying a complaint, two temperatures |
| `B2B_EV_RENEWAL_BODY` | the renewal-signal briefing |
| `B2B_EV_REQUEST_BODY_VOICE` · `B2B_EV_REQUEST_BODY_PLAIN` | a feature request, quoted and unquoted |

### Sector complaint voices (`B2B_COMPLAINT_*`, 15 rows, from B1a)
One per sector plus the fallback. Each is a customer describing a failing product in the
idiom of their own industry — the sector's texture is the whole point, so these want a
native-speaker pass more than most.

### Prospect pain lines (`B2B_PAIN_*`, 13 rows, from B1a)
One per product feature plus the fallback. In-voice statements of what the prospect lacks.

### Pitch-meeting beats (`b2b_pitch_meeting`)
| Key | What it is |
|---|---|
| `PITCH_CHECK_CRIT_SUCCESS` … `PITCH_CHECK_FAIL` | the five skill-check reaction lines |
| `PITCH_RESULT_SIGNED` · `PITCH_RESULT_CALLBACK` · `PITCH_RESULT_CLOSED` | outcome summaries |
| `PITCH_INNER_SIGNED` · `PITCH_INNER_CALLBACK` · `PITCH_INNER_CLOSED` | the founder's interior line |

### Hunt tab
| Key | What it is |
|---|---|
| `HUNT_FRANK_LINE` | Frank's standing advisory over the Series A board |
| `HUNT_WALK_CONFIRM_BODY` | the consequence sentence on walking away |
| `HUNT_COUNTER_PIVOT` | the bootstrap-road counter line |

### Price tips (`sales_system`)
`PRICE_TIP_PREMIUM` · `PRICE_TIP_VOLUME` — the two category-pricing judgements.

---

## B2 — HR (2026-08-19)

### Employee voices (`hr_constants`)
| Key | What it is |
|---|---|
| `HR_RESIGN_VOICE_1..4` | what a person says on the way out, one line each, first person |
| `HR_VALVE_VOICE_1..3` | the overtime safety-valve warning, before anyone quits |
| `HR_FILE_NOTE_1..12` | the one-line temperament note on a candidate file |

### Trait catalogue (`HR_TRAIT_*_LABEL` / `_EFFECT`, 20 rows)
Ten traits, each a name and an effect sentence. The names carry most of the character
(`Kol kanat gerer`, `Havayı bozar`, `Bir ayağı kapıda`) and are the rows most worth a
native pass — the current English is accurate but plainer than the Turkish.

### Role help copy
`HR_ROLE_HINT_*` (6) — one line per role naming what it accelerates.
`HR_AXIS_MEANING_*` (12) — what each role's expertise / pace axis drives.

### HR event bodies (`hr_event_factory`)
`HR_EV_VALVE_BODY` · `HR_EV_CALM_BODY` · `HR_EV_SIGNED_BODY` · `HR_EV_SHIPPED_BODY` —
the four morale beats. `HR_EV_CALM_BODY` in particular ("nobody is at a screen at eight in
the evening, and it is noticed") is doing real tonal work in Turkish.

### Warnings and previews
`HR_WARN_RETAINER_CASH` · `HR_WARN_COMMISSION_CASH` · `HR_WARN_SALARY_CASHFLOW` ·
`HR_OT_NOTE` · `HR_OT_EARLY_STOP` · `HR_ATLAS_QUOTE`.

### Not for the pass
`HR_AGENCY_NAME` ("Atlas Seçme & Yerleştirme") is deliberately identical in both columns —
a proper noun, on the same rule that keeps `Ekonomi Postası` untranslated. Flagging it here
only so it is not mistaken for a missed row.

---

## B3 — Product (2026-08-19)

### Product-type copy (`product_catalog`, from B3a)
Ten sub-product types, each with four Tier B fields — `PROD_TYPE_<ID>_DESC` ·
`_TRADEOFF` · `_BET` · `_PITCH` (**40 rows**). `_NAME` and `_CATEGORY` are Tier A labels and
are *not* listed.

The Turkish here was **authored, not translated**. The catalog previously stored the product
name in English (`"Workflow Automation"`) beside a Turkish description, and the creation flow
renders the two side by side — the Turkish feature picker literally read
"**Workflow Automation** Şu olunca şunu yap…". So the English column of these rows is the
draft, and the Turkish is the original.

### Feature voices (`PROD_FEAT_*_VOICE`, 61 rows, from B3a)
The wry one-liner under each feature name in the picker ("Şu olunca şunu yap" kurallarıyla
süreci otomatikleştir. Manuel takip biter.). One per feature. These carry most of the
picker's personality and want a native pass more than anything else in this batch.

### Frank's product-detail lines (`product_ui_shared`)
| Key | What it is |
|---|---|
| `PROD_TIP_WEAK` | weak-axis advice naming the rival directly above you |
| `PROD_TIP_GOOD` | the "keep going" line |
| `PROD_TIP_BUGS` | the bleeding-out line that overrides both |

`PROD_TIP_WEAK` is **`# COPY-RESTRUCTURED`**: the Turkish read "v2'te onu güçlendir,
{rival}'i yakala" — two suffixes on interpolated values, which the law forbids because the
correct suffix depends on how the *value* sounds. Rewritten so both placeholders are followed
by a fixed word instead ("v{version} sürümünde", "{rival} rakibini"). Any literary pass must
keep that property.

### Ship / iteration event bodies (`product_system`)
`PROD_EV_FIRST_SHIP_BODY` · `PROD_EV_VERSION_SHIP_BODY` · `PROD_EV_ITER_DECISION_BODY` —
three Frank scenes: the first launch, every later version, and the "one more round or move
on" decision. Multi-paragraph with quoted dialogue; the English is flat-correct and
undramatic next to the Turkish.

`PROD_ITER_CEILING_NOTE` — the teaching sentence appended to the iteration decision when a
build is active. It is doing precise mechanical work ("the ceiling comes from the team at the
table, not the number of rounds") and must stay unambiguous ahead of sounding good.

### Not for the pass
`PROD_COST_API` ("API") is identical in both columns on purpose. `PROD_DEV_VERSION`
("Geliştir · v{version}") is Tier A but was **restructured** away from "v3'ü geliştir", which
carried a hand-written vowel-harmony table for 2..9 — the number is terminal now and must
stay that way.

---

## B4 — Finance / VC (2026-08-19)

### The VC pitch scene (`vc_pitch_system`, 98 keys)
The whole four-beat encounter. Tier B throughout — this is the most performed scene in the
game and the English is a flat draft next to it.

| Family | What it is |
|---|---|
| `VC_B1_*` … `VC_B4_*` | the four beats: read the room, narrative, interrogation, close |
| `VC_Q_*` (24) | what the VC attacks — churn, flat growth, revenue concentration, an unmanaged scandal, no engineers, solo-founder risk, a rival ahead, a refused acquisition, reputation, bugs, the weakest axis, and the "I found nothing" clean read. Each is a `vc_line` (spoken) plus a `mono` (what the founder notices coming) |
| `VC_RES_*` | the four resolutions, including the callback and the two outcomes of pushing |
| `VC_REACT_*` | three one-word reactions folded onto the front of the next line |
| `VC_WHY_*` (11) | the seed read-out ("Odayı oku: MRR güçlü · Marka düşük · …") |
| `VC_EV_*` | the three calendar events — meeting day, offer expiring, last day |

**`VC_EV_OFFER_EXPIRING_BODY` is `# COPY-RESTRUCTURED`.** The Turkish read
`"{investor}'in teklifi …"` — a genitive suffix on a proper noun, where the correct ending
depends on how the *name* sounds. Rewritten so the investor is a terminal label. Any literary
pass must keep that property.

### The B2B pitch (`pitch_system`, 34 keys)
Four stages (`PITCH_S0_*` … `PITCH_S3_*`), each an NPC line, the founder's interior line, and
three answers. Plus `PITCH_BAND_*` — five one-line reads of how the last check went, in the
founder's head — and `PITCH_NEED_*` / `PITCH_REAL_NEED_*`, the prospect's stated need and the
one behind it.

### Phase gates (`phase_gate_system`, 8 keys)
`GATE_TRACTION_*` and `GATE_SERIES_A_*`: a title and three body variants each, the variant
chosen by how many times the player has declined. Frank gets colder each time; `_BODY_2` is
the same line for both gates on purpose ("Beklemek de bir karar. Kirasını sen ödüyorsun.").

### The term sheet table (`term_sheet_table_system`, 34 keys)
`TERM_FRANK_*` is Frank talking over your shoulder during the negotiation; `TERM_RESULT_*` is
the table's own voice.

**Two of these are `# COPY-RESTRUCTURED`, and this file is why the rule exists.** It carried
three parallel spellings of the same three lever names — `_lever_name`, `_lever_name_acc` and
`_lever_name_loc` — because "Değerleme", "Hisse" and "Board" take different Turkish case
endings. The file's own comment conceded that "one shared 'ı' template can't fit all three."
`TERM_FRANK_WON` and `TERM_FRANK_RESISTED` were rewritten so the lever name sits in a terminal
slot, and both helper tables were deleted. `TERM_RESULT_REFUSED` got the same treatment for a
locative ending that was landing on a rendered *number* (`"$18M'de kaldı"`).

### Finance summary (`finance_ozet_view`, `finance_system`)
Mostly Tier A labels and therefore not listed. Two exceptions want the pass:
`FIN_MENTOR_QUOTE` (the runway warning — it names its own six-month threshold in words, so it
has to move if `RUNWAY_WARN_MONTHS` moves) and `FIN_LEGEND_PROJECTION_TARGET`.

### Not for the pass
`TERM_LEVER_BOARD` ("Board") and `PITCH_BUDGET_*` are deliberately terse in both columns.
`TERM_BOARD_SEAT_ONE` and `TERM_BOARD_SEATS` are **two rows for one idea**: English needs a
singular ("1 seat"), Turkish does not inflect after a numeral, so both of its rows read
"{n} koltuk". That is a deliberate duplication, not a missed merge.

---

## B5 — Shell / World (2026-08-19)

### Company backgrounds (`COMPANY_BG_*`, 65 rows)
One line of character per company — sector feel, size feel, temperament. The company NAMES
stay in `company_catalog.gd` and are **not** listed here: they are proper nouns and the
LANGUAGE INTEGRITY LAW exempts them. The ids exist only to address these rows.

These lines do a specific job: they are quoted by the event layer to colour wording, and the
Turkish carries a lot of dry humour that the English draft flattens ("the foreman's memory is
the database", "quiet, loyal, slow"). High value for a voice pass, low risk — nothing branches
on them.

### Ticker lines (`NEWS_S_*`, 48 rows + `NEWS_RIVAL_UP_*` / `_DOWN_*`, 7 templates)
The sector climate lines that scroll along the bottom of every screen, phase-gated
(seed climate → valuation talk → regulation) and pool-gated (`ai` / `saas` / `any`). The
rival templates take `{name}` and `{share}`.

**Staleness note.** These translate at EMIT time, not at render time, so a mid-run language
switch leaves already-emitted lines in the previous language until they scroll out of the
50-line buffer. That is gate ruling 7 territory (modal staleness accepted) and the buffer is
not persisted — `GameState.news_feed` is absent from `SaveCodec`, so it never survives a
reload. Flagged rather than fixed, because rendering-time translation would mean storing
key + args for the composed rival lines.

### Month-end summary (`MONTH_*`)
`MONTH_FRANK_*` — five one-line verdicts, chosen by rule (shutter counting / burning but
selling / shrinking / good / another one). Tier B; the rest of the modal is Tier A labels.

### Not for the pass
`WORLD_OUTLET_*` (four fictional mastheads) and `PROD_MENTOR_TAG` are identical in both
columns — proper nouns. `FIN_PHASE_BOOTSTRAP` / `_TRACTION` / `_SERIES_A` likewise, by gate
ruling 3. The Shift+F11 extreme-value fixture in `month_summary_system` is `# LOC-DATA`: its
whole purpose is a long Turkish headline overflowing the band, so keying it would defeat the
test.
