export const meta = {
  name: 'playtest-bulgu-dogrulama',
  description: 'Verify playtest findings against code and save data, with file:line evidence',
  phases: [{ title: 'Doğrula', detail: 'one read-only verifier per area' }],
}

const S = args.S
const CODE = S + '/m_c8/project-unicorn'
const COMMON = `
You verify findings from a playtest of Project Unicorn (Godot 4.6, GDScript), read-only. Code (exact build that was played,
commit b2639465): ${CODE} — read and grep it freely; do NOT read anything under "/Users/tugbauysal/Desktop/project steam" (iCloud, hangs).
Playtest material: notes ${S}/playtest/notlar.md (Turkish, week by week), game log ${S}/playtest/game.log, the final quick save
${S}/playtest/kayit/quick_mvx54wxk.json (event history at state/systems/event_engine/rows: day = game week, event_id, option_id,
resolution, at = absolute minute tick*1440+minute), earlier autosaves auto_mvx54wxk_{1,2,3}.json, frames ${S}/playtest/kareler/*.png
(you may open a frame with Read to see what the player saw). CLAUDE.md in the code root describes the systems.
For EACH finding below: find the code that produces the observed behaviour, decide the verdict, and give evidence that a reader can
check: a short exact quote of the code or CSV with file:line (path relative to the code root), and/or the save/log data. Verdicts:
"hata" (code does something the design text/comments or the player-facing text says it should not), "tasarım" (works as the code
and its comments intend; the player still saw it — say what the intent is), "tekrarlanamadı" (the code cannot produce it as described;
say what it actually does), "belirsiz" (evidence insufficient; say what is missing). Do not speculate; quote. Write in Turkish.
Never edit files.`

const SCHEMA = {
  type: 'object',
  properties: {
    findings: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          claim: { type: 'string', description: 'the finding as observed, one sentence' },
          verdict: { type: 'string', enum: ['hata', 'tasarım', 'tekrarlanamadı', 'belirsiz'] },
          mechanism: { type: 'string', description: 'what the code does, 1-3 sentences' },
          evidence: { type: 'array', items: { type: 'string', description: 'file:line — quote, or save/log fact' } },
          player_impact: { type: 'string', description: 'one sentence: what the player experiences' },
        },
        required: ['id', 'claim', 'verdict', 'mechanism', 'evidence', 'player_impact'],
      },
    },
  },
  required: ['findings'],
}

const GROUPS = [
  { key: 'olaylar', task: `
P1. world.quarterly_bulletin (sender Sektör Telgrafı) arrived week 14; when the player pressed "Cevapla" in week 15, a toast "Bu kâğıdın konusu kalmadı" appeared and the paper vanished; the save row says resolution "dropped". The playtester suspects the card's condition (time.quarter_start) is re-checked on open while the paper lives 2 weeks. Find: the card JSON, where an open/answer re-evaluates conditions and drops a paper, the toast's CSV key, and whether a time-window condition is meant to drop a paper the player already received.
P2. product.sprint_dev_backfill (speaker Arda Güneş) — save row day 30 resolution "expired" with no option. Player says it never appeared in the Olaylar (events) list; only the ticker said "Cevap gelmedi, eski kayıtlar boş kaldı", and its cost (1 bug) was applied. Find when it was requested and delivered (row 'at' vs days; MailClock delivery), why it was not listed, and the code that expires a sprint decision paper at sprint close.
P3. game.log has the warning "[EvEngine] the floor has found nothing N times running — the quiet pool is too thin (§13.6)" 11 times, N rising from 3 to 13, never reset. Explain the floor logic (scripts/events/core/engine.gd around the warning) and what resets the counter; is N never resetting expected given the history rows?
P4. product.incident_regression option "Sprinti durdur" (sprint_stop) showed no cost chip in week 22 (frame 17_h22_v17_bir_sey_bozuldu_arda.png). Check its effects and EvChips (SILENT_VERBS comment for sprint_fix_first). Is a chip-less option intended here?` },
  { key: 'satis', task: `
S1. In a sales meeting (week 24, frame 19_h24_sprintte_yer_yok_ama_sprint_bos.png) the answer "İmzalarsanız … sonraki sprintimize yazarım" was locked with "Bir sonraki sprintte buna yer yok" although the next sprint was empty. Find the lock condition and reason key.
S2. The answer "Ürün kolay öğreniliyor" was open in weeks 13 and 16 but locked in weeks 22 and 24 though the product did not change (per notes). Find its gating rule.
S3. The offer screen showed "Kapasite 79/50" with no explanation or warning. Find what this figure is.
S4. The sales panel at Monday 00:00 showed "Mesai bitiyor. Bu hafta yeni bir masaya oturulmaz." Find the key and the condition that shows it; does it fire at the week's start?
S5. A customer card said "Müşteri temsilcisi: atanmadı" while the assign dropdown said "Kurucu … zaten sorumlu". Find both strings and the logic.` },
  { key: 'ekip_fon', task: `
E1. Newly hired staff went on leave right away without any card: Arda (hired ~week 20) on 2-week leave in week 23; Selin (hired ~week 27) on 2-week leave in week 28; only the news ticker said so. Find how summer leave is scheduled for a new hire (HRMoraleSystem / leave planning), whether a fresh hire can be put on leave immediately, and whether the player is told any other way than the ticker.
E2. Frank's three "Karar" cards (customer.frank_intro week 8, funding.gate_traction week 11, funding.frank_cheque week 25) each had a single option; in frank_cheque the "Reddet" option was locked on Normal difficulty with "Zor modda açılır" (frame 21_h25_frankin_teklifi_reddet_kilitli.png). Check the card JSONs and the difficulty lock; is this by design (cite comments/GDD lines in the repo if present)?
E3. Notes mention the founder's name stayed empty and the game calls the founder "Kurucu" — check whether onboarding allows an empty founder name (validation) and what the game shows then.` },
  { key: 'arayuz', task: `
U1. Text cut with "…": in the top bar's SIRADAKİ (next) item "Çeyrek bülteni: i…", and on the Ekip screen "v1.9 üzer…". Find the components and the clipping setting (text_overrun_behavior / clip_text / max_lines) with file:line. The owner's rule: no text is cut with "…".
U2. While a paper was open, next to the globe button a label "Cevap bekliyor" rendered in a serif fallback font (frame may show it; search notes). Find the label and its theme variation / font, and why it falls back to serif.
U3. The Q1 report read "$10K→$11K (+$672)". Find the formatter used for the two values and the delta (rounding to K?), and say whether the numbers are consistent (e.g. 10.4K→11.1K).` },
  { key: 'sprint', task: `
K1. Weeks 19–25 the sprints ran nearly empty (speed 11/36, 9/36, 10/38) because new cards only open through R&D (Ar-Ge); the playtester says the sprint screen never points to Ar-Ge (only a "1" badge since week 7). Find how sprint candidates run out and what the plan screen shows then (e.g. PRODUCT_GO_RND button, live:rnd shot in main.gd, empty-state text); when is that pointer shown?
K2. Week 12: an unanswered paper's effort effect was pre-written into the sprint plan as two "DEVREDEN" rows and the Test capacity read "5/0" (frame 09_h12_sprint_devreden_onizleme.png). Find why carried rows appear for an unanswered paper and what "5/0" means.
K3. The "+" in the middle list did nothing when the module panel had no emphasis; a card that did not fit was silently not added; "Sprinti başlat" and "Cevapla" sometimes did not react to the first click; switching left-menu tabs took two clicks. For the first two find the code paths (add-card handler, capacity refusal) and whether a refusal is shown. For the click issues say only whether something in the code needs two inputs (e.g. focus-then-press) or state "belirsiz" (MCP-injected clicks may differ from a real mouse).` },
]

phase('Doğrula')
const results = await parallel(GROUPS.map(g => () =>
  agent(COMMON + '\n\nFindings to verify:\n' + g.task, { label: 'dogrula:' + g.key, phase: 'Doğrula', schema: SCHEMA })
    .then(r => ({ key: g.key, findings: r ? r.findings : [] }))))
return results.filter(Boolean)
