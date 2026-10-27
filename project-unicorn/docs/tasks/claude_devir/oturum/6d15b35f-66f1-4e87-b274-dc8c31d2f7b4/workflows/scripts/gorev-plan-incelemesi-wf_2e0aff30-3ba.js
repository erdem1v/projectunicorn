export const meta = {
  name: 'gorev-plan-incelemesi',
  description: 'Review two new task briefs and the 3-session coordination for executability without asking Erdem',
  phases: [{ title: 'Review', detail: 'three independent Opus reviewers verify claims against the repo' }],
}

const ROOT = 'C:/Users/erdem/Desktop/Project Unicorn/project-unicorn'
const FINDINGS = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          doc: { type: 'string', description: 'file the finding is in' },
          quote: { type: 'string', description: 'verbatim quote from the doc (short)' },
          problem: { type: 'string', description: 'what is wrong, missing, contradictory or unverifiable; Turkish' },
          category: { type: 'string', enum: ['answer_exists', 'small', 'erdem', 'factual_error'] },
          proposed_fix: { type: 'string', description: 'exact replacement text or decision to write into the doc; Turkish' },
          evidence: { type: 'string', description: 'file:line or command output proving the claim' },
          severity: { type: 'string', enum: ['blocker', 'major', 'minor'] },
        },
        required: ['doc', 'quote', 'problem', 'category', 'proposed_fix', 'evidence', 'severity'],
      },
    },
    verdict: { type: 'string', description: 'one paragraph: can a fresh session execute this without returning to Erdem? Turkish' },
  },
  required: ['findings', 'verdict'],
}

const COMMON = `You are a senior reviewer for Project Unicorn (Godot 4.6 game, Turkish docs). Working dir: ${ROOT}.
Read-only: do NOT edit any file. Verify every factual claim you rely on by reading code/data (Grep/Read/Bash), cite file:line.
Question to answer: "Can a fresh Claude Code session execute this brief end-to-end without coming back to Erdem (the owner)?"
Classify each finding:
- answer_exists: the answer is already in the repo/PRD/decision log; give the exact text to add and where it is.
- small: a reasonable implementer would decide it; propose the decision text (the co-director will mark it as her/his ruling).
- erdem: only the owner can answer AND the answer changes the outcome. Use sparingly.
- factual_error: the brief states something false about the code/data (wrong path, key, function, flag, count).
Ignore style nits. Max 15 findings, most severe first. Write problem/proposed_fix in Turkish.
Context files: decision log docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md (section "2026-10-26"), CLAUDE.md is already in your context.`

const UI = `${COMMON}
Review target: docs/tasks/GOREV_URUN_ARAYUZU_DEVAM.md and the new last section of docs/tasks/PRD_URUN_SPRINT_ARAYUZU.md
("Erdem'in A4 cevabı ve Faz D ekleri (yardımcı yönetmen, 2026-10-26)"), plus docs/tasks/GOREV_URUN_ARAYUZU.md which it builds on.
Specifically verify: data/product/sprint.json pm.low_skill_* and sprint_catalog.gd pm_plans keep factor (UD2); the D8a suggestion
code path (lead / _suggest / apply_lead / capacity_of) and whether UD1's rule ("continue the same ordered list into the next column,
D8a limits counted separately, delegated PM plan wins") is implementable and consistent with how the next column and PM prep work today
(sprint_system.gd, sprint_catalog.gd, SprintPrep); that live:a4_run_w2 exists; D_FS_12 token exists; the A4 local copy path;
the Pazar 2 synthesis path; PROD_LINE_* key families; whether UK conflicts with existing PRD rows (durum yuvası, A6, KR24);
whether N2 contradicts the PRD's existing chip spec; whether the step order/durations are coherent with PRD §13.`

const EV = `${COMMON}
Review target: docs/tasks/GOREV_OLAY_UYGULAMA.md. Inputs it cites: revize.json at
C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5ad1dc82-4870-4507-b82a-591327527a0f/scratchpad/revize.json,
docs/tasks/GOREV_OLAY_REVIZYON.md, docs/content/events_draft/_vocabulary.md, scripts/events/**, data/events/cards/** (incl. unwired/).
Verify: the 24 bind / 6 park / delete lists match revize.json ids and Erdem's 2026-10-26 table (every numbered comment is covered by a step
or a ruling); the gates/flags named exist (--event-lint, loc_residue, loc_csv_integrity, event_chip_coverage smoke, --why-fire,
tools/plausibility_run.sh, --event-harness=random:seeds=N:weeks=M, --event-shot); how unwired/ cards are treated by lint/loader;
version_scope semantics; HRConstants.leave_week_for and leave rules for ruling 4; trust_offset seam; existing verbs vs kod_notu gaps
(spot-check at least 8 gaps: which verbs already exist, e.g. sprint_card_test, sprint_fix_first, promise_extend, promise_create,
b2b_month_discount, productivity_mod, set_timed_flag, odds/check branches); whether ruling 1 (#23 provider lock + capacity floor)
is buildable via InfraSystem seams; whether the modifier rules are concrete enough to execute; save-schema implications.`

const X = `${COMMON}
Review target: the coordination between three sessions that will run IN PARALLEL in the same folder, same git index, same machine:
docs/tasks/GOREV_TEMIZLIK.md (cleanup: inventory, deletions, review-report fixes A1-A8/B1-B6/C1,C4-C9, dead-code sweep, code-map regen,
HARITA.md retirement + CLAUDE.md map references), docs/tasks/GOREV_URUN_ARAYUZU_DEVAM.md (sprint UI U2-U8 + model steps),
docs/tasks/GOREV_OLAY_UYGULAMA.md (event cards + new verbs/seams). Find races, deadlocks and lost-work risks. Check especially:
generated code-map files (docs/kod_haritasi/DIZIN.md, SEMBOLLER.tsv, KALITE.md) regenerated by tools/kod_haritasi/uret.py on every commit
by every session; docs/HARITA.md and kod_haritasi/sistemler pages edited by all three while Temizlik retires HARITA.md; CLAUDE.md edits;
strings.csv; SaveManager.SCHEMA_VERSION; theme regeneration and THEME_STAMP; the mkdir lock protocol (is rmdir allowed under auto mode?
stale lock if a session dies); git index staging via update-index --cacheinfo from private trees; Temizlik deleting files/keys that the others'
uncommitted copies still read; Temizlik moving untracked files to an archive while others' scratch outputs live in the tree; the run_gate
three long runs vs memory; the dirty files rule. Propose concrete rule text to add to the briefs (Turkish).`

phase('Review')
const [ui, ev, x] = await parallel([
  () => agent(UI, { label: 'review:urun-gorevi', phase: 'Review', schema: FINDINGS }),
  () => agent(EV, { label: 'review:olay-gorevi', phase: 'Review', schema: FINDINGS }),
  () => agent(X, { label: 'review:uc-oturum-cakisma', phase: 'Review', schema: FINDINGS }),
])
return { ui, ev, x }
