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
