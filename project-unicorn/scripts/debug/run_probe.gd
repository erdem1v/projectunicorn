class_name RunProbe
extends RefCounted

# Headless RUN LOG harness — event fire log, churn-chain autopsy and the played run.
# Debug builds only; main.gd runs it for --run-log=<preset>:<weeks>:<mode>.
#
# The probe is "the player". It mounts no shell and no modals: it drives the real tick
# dispatch and answers every decision through the seam the modal calls (EventGate.resolve),
# so the engine cannot tell it apart from a human except by the choice policy, which is
# deterministic and printed.
#
# Not a smoke case: it asserts nothing. It EMITS A LEDGER (every event fire with its source,
# every choice, daily economy state) that a human reads to find out what the game actually
# does over a run.
#
# Drive modes:
#   sim     — the game's clock without the wall clock: every visible hour is its own one-hour
#             TimeManager.advance_hours batch, answered before the next, and the night is one
#             skip_night batch (the rollover and the daily tick inside it). Deterministic, instant.
#   1|2|3|4 — the REAL clock at that speed index (TimeManager._advance_real, frame pacing and
#             all). The only mode that can catch a real-time-only defect. It rolls no night
#             emergency: one holds the clock until its card is answered, and this mode answers
#             at the hour boundary the hold would never reach.
# In both the founder sits the sales meetings when the week opens (the first 08:00, then every
# night_skipped) and takes the desk decisions at every visible hour, as a player at the keyboard.
#
# Output contract — one line per record, all prefixed PROBE so a grep separates them
# from the engine's own log lines:
#   PROBE BEGIN preset=<p> weeks=<n> mode=<m> seed=<s>
#   PROBE FIRE  day=<d> hour=<h> id=<id> src=<src>
#   PROBE PICK  day=<d> id=<id> choice=<i> label=<label>
#   PROBE STATE day=<d> cash=<n> mrr=<n> brand=<n> burn=<n> runway=<f|INF> cust=<n> emp=<n> promises=<n>
#   PROBE B2C   day=<d> aud=<f> paying=<n> price=<n> conv=<f> sat=<n> sat_target=<n> open_bugs=<n>
#               lost=<f> q=<f> interest=<f> occ=<f> desk=<n> incoming=<n> inflow_day=<f>
#               validation_day=<f> u=<n> aud_star=<f>
#                                           (every week a consumer product is live; desk = the
#                                           support desk's roster, inflow and validation per day;
#                                           lost = the users the audience has lost to erosion and bug churn;
#                                           sat_target = the fit of the core and the way in, the number the
#                                           record drifts toward; q = the B2C quality term the audience and the
#                                           price read, the product's fit to its audience x 5/7; u = that fit
#                                           itself, 0-100; aud_star = where the audience stands on the star rows,
#                                           1.00-3.00; occ = the servers' load as a ratio)
#   PROBE SERVER day=<d> units=<n> tier=<local|cloud|enterprise> load=<pct> bill=<monthly $> auto=<0|1>
#                                           (every week a product is live: the servers the founder runs, the units
#                                           bought, the tier, the load in whole percent, the monthly bill and whether
#                                           Auto adjust is on)
#   PROBE DECISION week=<w> surface=<tier|capacity|move|hire> target=<what>
#                                           (a decision the founder takes at a surface of the game: the servers' tier
#                                           (target = the tier) and capacity (the units they end the week on, or auto),
#                                           a move (the office), a hire (the role whose search starts, or desks_full
#                                           once a wanted hire waits on an office with no free desk))
#   PROBE CHURN day=<d> id=<cid> ...        (customer_churned — the autopsy's terminal)
#   PROBE PROMISE day=<d> id=<pid> status=<s> ...
#   PROBE LEAD  day=<d> id=<pid> arch=<archetype> sector=<sector> star=<n> phase=<p> u=<n|-> loss=<area|->
#                                           (every B2B lead the faucet or an event puts on the desk, as it arrives;
#                                           u is the lead's fit the day it arrives, loss the area it would miss;
#                                           - on a product without line content, which has no core to fit)
#   PROBE SIGN  day=<d> hour=<h> id=<cid> by=<founder|rep> star=<n> weeks=<w> mrr=<n> sector=<s> arch=<a> tol=<n> phase=<p>
#               areas=<area>:<level>,...
#                                           (every B2B signing; weeks is the deal's planned length,
#                                           0 for a fixture account; mrr is the account's; arch is the lead's,
#                                           - for a fixture account, which has no lead; tol is the account's
#                                           seeded tolerance, the floor its satisfaction is held against;
#                                           areas are the market's unrounded area levels at the signature)
#   PROBE FIT   day=<d> hour=<h> id=<cid> phase=<p> sector=<s> star=<n> by=<founder|rep> u=<n> capped=<b>
#               loss=<area|-> tol=<n>
#                                           (beside every PROBE SIGN that has a lead: u is the lead's fit at the
#                                           signature, read before the lead leaves the registry; capped = the
#                                           core ceiling held it, loss the area it would miss; tol the account's
#                                           seeded tolerance. A fixture account has no lead and prints none, nor
#                                           does a product without line content)
#   PROBE REPLOSS day=<d> hour=<h> id=<pid> phase=<p> sector=<s> star=<n> u=<n> capped=<b> loss=<area>
#                                           (every B2B deal a desk seller loses at the close, read as PROBE FIT reads a
#                                           signature: u is the lead's fit the moment it is lost, before it leaves the
#                                           registry, loss the area it lacked. The share of a seller's closes that is
#                                           lost counts from these lines against PROBE FIT by=rep. The founder's own
#                                           lost sittings print none)
#   PROBE MLOSS day=<d> hour=<h> id=<pid> sector=<s> star=<n> phase=<p> reason=<SalesLedger reason> target=<area|line|-> u=<n|-> capped=<b|->
#               loss=<area|->
#                                           (every B2B deal the founder loses, at a sitting or at a table that ran out of
#                                           patience, as it is lost: reason and target are the account memory's, u, capped
#                                           and loss the lead's fit before it leaves the registry. A desk seller's loss
#                                           also reaches the meeting_lost signal and prints PROBE REPLOSS instead; - on a
#                                           product without line content)
#   PROBE FIXTURE preset=<p> bugs=<n> under_live=<n> under_clear=<n> slack=<n> book=<id>:<clear>/<live>/<bar>,...
#                                           (the b2b_* presets, once, after the book signs: each account's target with no
#                                           bug open (clear) and with the backlog open (live) against its tolerance (bar);
#                                           under_* count the accounts under their bar, slack is the least a clear target
#                                           clears its bar by. A PROBE ERROR follows when the preset's intent no longer holds)
#   PROBE UFLUX day=<d> changed=<n> release=<b> renewal=<n> unexplained=<n>
#                                           (every week the B2B book is not empty, on a product with line
#                                           content: the accounts whose fit moved since last week's reading or
#                                           their signature; release = a version shipped meanwhile, renewal =
#                                           the changed accounts whose renewal window opened this week,
#                                           unexplained = the changed accounts with neither. One reading a
#                                           week, because every account's fit is read)
#   PROBE TALLY <id> fires=<n> picks=<n>    (one per id, at the end)
#   PROBE WEEK  w=<w> fires=<n> meetings=<n> signs=<n>   (one per week, at the end: card fires,
#                                           the founder's sittings, B2B signings)
#   PROBE END   day=<d> run_active=<b> ending=<id> finite_runway_p<1|2|3>=<finite weeks>/<weeks>
#               min_cash_pre_seed=<n> seed_day=<n|-1> first_sign_day=<n|-1> first_revenue_day=<n|-1>
#               cheque_day=<n|-1> open_w1_12=<n> idle_w1_12=<n> u_unexplained_weeks=<n> server_clicks=<n>
#               auto_grows=<n> outage_eko=<n> outage_std=<n> outage_kur=<n> clause_ended=<n> first_hire_week=<n|-1>
#               first_hire_runway=<months|-> move_weeks=<w,w,...|-> support_reports=<n>/<n>
#               support_news=worst:<n>,cleared:<n>,shipped:<n>,priority:<n>,behind:<n>
#                                           (the weeks are the weekly STATE readings, by phase;
#                                           seed_day is the day the seed was signed; first_revenue_day
#                                           the first daily tick that closed with MRR; cheque_day the
#                                           day Frank's cheque was taken; open_w1_12 the weeks 1-12
#                                           whose 08:00 found the B2B market open, idle_w1_12 those
#                                           of them without a sitting; u_unexplained_weeks the weeks
#                                           whose PROBE UFLUX counted an unexplained account; server_clicks the founder's
#                                           Increase and Decrease presses, auto_grows the automatic increases, outage_* the
#                                           night outages by the tier the servers were on: Economy, Standard, Enterprise;
#                                           clause_ended the contracts the server clause ended; first_hire_week the tick of
#                                           the first hire and first_hire_runway the months of that week's costs, the new
#                                           salary in, the cash covered, revenue left out; move_weeks the ticks a move was decided on;
#                                           support_reports the weeks the support report came over the weeks a live product had a
#                                           rep at the desk, support_news the reports each news line was in)
#   PROBE HR    hires=<n> emp=<n> payroll=<n> morale_avg=<f|-> below50=<n> min=<n|->
#   PROBE GATE  day=<d> emp=<n> roles=<role:total/j-m-s,...> payroll_monthly=<n> <burn id>=<n>... ...
#                                           (full_run*: once, the day the Series A door opens)
#   PROBE MONTH_BURN day=<d> n=<n> ticks=<n> <burn id>=<n>... one_time=<n>   (full_run*: beside each PROBE MONTH)
#               The burn ids are FinanceSystem.BURN_IDS, in its order.
#   PROBE SPRINT day=<d> n=<n> label=<v1.x|-> shipped=<card ids> carried=<n> velocity=<done>/<capacity>
#   PROBE SHIP  day=<d> version=<n> ...      (a public release: the MVP and every version after it; escaped = the
#                                           bugs that escaped the release's testing, one per bug on its card's line)
#   PROBE FIX   day=<d> sprint=<n> weeks=<n> fix_load=<f> capacity=<f> share=<f> cards=<fix card ids|-> bug_sprint=<b> k=<f>
#                                           (every sprint start: the fix cards' remaining points over the plan's
#                                           capacity; a bug sprint spends more than half the capacity on fixes; k is
#                                           SprintCatalog.limit_k, the factor of the neglect threshold and DUE_BUGS)
#   PROBE STOP  day=<d> sprint=<n> id=<emergency card> fix_load=<f> capacity=<f> share=<f> cards=<fix card ids|-> bug_sprint=<b>
#                                           (an emergency answered with its line's fix card first: the fix cards'
#                                           remaining points over the sprint's capacity, as PROBE FIX reads them at
#                                           a sprint's start, so the fix a sprint takes on mid-week counts too)
#   PROBE BUGS  day=<d> new=<n> open=<n> pre=<n>   (every week a product is live: bugs that arrived, open bugs now,
#                                           and open bugs just before this week's sprint close)
#   PROBE LINES day=<d> <line>=<n>,...      (beside PROBE BUGS: the open bugs line by line, - with none)
#   PROBE AREAS day=<d> market=<b2b|b2c> <area>=<level>/<lines>/<launches>,...
#                                           (beside PROBE BUGS: every area of the market, level = the unrounded
#                                           SprintCatalog level (the screen shows it rounded to halves), lines =
#                                           the area's capabilities, launches = the rival launches on them that
#                                           the rival window still counts)
#   PROBE VCQ   day=<d> investor=<id> key=<query key> dim=<area id|->
#                                           (every Beat-3 question, as the meeting put it up: the key VCPitchSystem
#                                           chose, seed or Series A; dim the weakest product area behind a product
#                                           fund's question (weak_dim names it, seed how_big does not), - for any
#                                           other fund and for the clean question)
#   PROBE MARKET day=<d> total=<$M> leader=<id> leader_value=<$M> listed=<n> player=<valuation $M>
#               (the Piyasa list at the week's open, every MARKET_LOG_WEEKS weeks from week 1;
#               a pure read of MarketCatalog, so the line is byte-identical for one seed)
#   PROBE MILESTONE day=<d> id=<milestone>
#                                           (build=ea runs only: a win the EA build lives through, the bootstrap one, as the run goes on)
#   PROBE VC_*  (the presets with a Series A policy): VC_CONFIG, VC_BOOK, VC_MEET,
#               VC_TABLE_OPEN, VC_PUSH, VC_TABLE_END, VC_REPLAY, VC_REPLAY_SUM

## Every preset. The fixture presets ({}) seed their world in _seed_world. The played runs
## (full_run*) seed nothing and carry what the founder picks and plays by:
##   subtype   — the product chosen in the Product tab on the first morning;
##   policy    — the event answers (default "sensible", below);
##   vc        — the Series A policy, sim only (none: the run never sits at a Series A table); "product" signs
##               the opening terms like "cautious" and sits at the product fund first, at the seed and at Series A;
##   staff_cap — the employees the B2B staffing ladder stops at (default: its thirteen STAFF_LADDER rungs; full_run_staff25
##               and full_run_staff50 go on up the growth rungs to 24 and 49, 25 and 50 people with the founder);
##   k1_only   — the founder never plans a K2 or K3 step;
##   fix       — the sprint's fix cards (default: whatever the lead plans): "none" takes no fix card, "worst" the
##               line with the most open bugs, "due" every line with DUE_BUGS × k or more (B2B: a line an active or
##               trial account uses), "off" is "worst" with the cost of open bugs switched off (the baseline).
##               It also decides the answer to an emergency card: "none" leaves the fix for the next sprint, every
##               other arm stops the sprint for it;
##   no_stop   — the arm never stops the sprint for an emergency (the same run with that answer left out);
##   core_only — rides the fix arm: no feature or request card outside the core area stays in a sprint, fix and
##               research cards are kept, and the lead fills what is left from the rest of the pool;
##   desk      — with a rep on the Satış job the founder sits only the leads above the reps' band, the rest are
##               the reps' (the game's own pick_lead_for); with no rep he sits every lead, as the other arms do;
##   server    — how the founder runs the servers at each week's open: by default he presses Increase while the load is
##               over 90%; "lean" holds it near 95% and "wide" near 60% (pressing Decrease too, while a step would still
##               leave the load under the line); "auto" switches Auto adjust on and never presses;
##   cash      — when the first person is hired and how freely the company moves: "spend" hires once the cash covers two
##               months of the costs the hire leaves and moves on two months of today's costs, "hoard" waits for 6.7
##               months and never moves; every other arm hires and moves at six months. A company that moves goes up a step
##               (the flat to the business block once the seed is in, then whenever its desks are full) once the cash
##               covers the up-front rent and those months of today's costs; short of that it stays, and a full office
##               hires nobody;
##   accounts, staff — the scale fixtures (b2b_book20, b2b_book330): the live ERP with that many B2B accounts signed and that
##               many people (the founder among them) on the sprint engine, which the lead plans from the first morning
##               (_seed_book); their morale stays where it was seeded (_pin_the_morale), or the unmanaged roster would resign in one week.
const PRESETS := {
	"b2b_reps": {}, "b2b_solo": {}, "b2b_risk": {}, "b2b_slip": {}, "b2c": {}, "b2c_neglect": {},
	"full_run": {"subtype": "erp"},
	"full_run_naive": {"subtype": "erp", "policy": "naive"},
	"full_run_discount": {"subtype": "erp", "policy": "discount"},
	"full_run_vc_naive": {"subtype": "erp", "vc": "naive"},
	"full_run_vc_cautious": {"subtype": "erp", "vc": "cautious"},
	"full_run_lean": {"subtype": "erp", "vc": "walk", "staff_cap": 7},
	"full_run_b2c": {"subtype": "note_tool"},
	"full_run_b2c_video": {"subtype": "video_clip"},
	"full_run_b2c_vc_cautious": {"subtype": "note_tool", "vc": "cautious"},
	"full_run_b2c_vc_walk": {"subtype": "note_tool", "vc": "walk"},
	"full_run_b2c_k1": {"subtype": "note_tool", "k1_only": true},
	"full_run_fix_none": {"subtype": "erp", "fix": "none"},
	"full_run_fix_worst": {"subtype": "erp", "fix": "worst"},
	"full_run_fix_due": {"subtype": "erp", "fix": "due"},
	"full_run_fix_off": {"subtype": "erp", "fix": "off"},
	"full_run_b2c_fix_none": {"subtype": "note_tool", "fix": "none"},
	"full_run_b2c_fix_worst": {"subtype": "note_tool", "fix": "worst"},
	"full_run_b2c_fix_due": {"subtype": "note_tool", "fix": "due"},
	"full_run_b2c_fix_off": {"subtype": "note_tool", "fix": "off"},
	"full_run_fix_worst_free": {"subtype": "erp", "fix": "worst", "no_stop": true},
	"full_run_fix_due_free": {"subtype": "erp", "fix": "due", "no_stop": true},
	"full_run_fix_off_free": {"subtype": "erp", "fix": "off", "no_stop": true},
	"full_run_b2c_fix_worst_free": {"subtype": "note_tool", "fix": "worst", "no_stop": true},
	"full_run_b2c_fix_due_free": {"subtype": "note_tool", "fix": "due", "no_stop": true},
	"full_run_b2c_fix_off_free": {"subtype": "note_tool", "fix": "off", "no_stop": true},
	"full_run_fix_worst_desk": {"subtype": "erp", "fix": "worst", "desk": true},
	"full_run_quality_core": {"subtype": "erp", "fix": "worst", "core_only": true},
	"full_run_quality_core_desk": {"subtype": "erp", "fix": "worst", "core_only": true, "desk": true},
	"full_run_vc_product": {"subtype": "erp", "vc": "product"},
	"full_run_b2c_vc_product": {"subtype": "note_tool", "vc": "product"},
	"full_run_server_lean": {"subtype": "erp", "server": "lean"},
	"full_run_server_wide": {"subtype": "erp", "server": "wide"},
	"full_run_server_auto": {"subtype": "erp", "server": "auto"},
	"full_run_b2c_server_lean": {"subtype": "note_tool", "server": "lean"},
	"full_run_b2c_server_wide": {"subtype": "note_tool", "server": "wide"},
	"full_run_b2c_server_auto": {"subtype": "note_tool", "server": "auto"},
	"full_run_cash_spend": {"subtype": "erp", "cash": "spend"},
	"full_run_cash_hoard": {"subtype": "erp", "cash": "hoard"},
	"full_run_b2c_cash_spend": {"subtype": "note_tool", "cash": "spend"},
	"full_run_b2c_cash_hoard": {"subtype": "note_tool", "cash": "hoard"},
	"full_run_staff25": {"subtype": "erp", "staff_cap": 24},
	"full_run_staff50": {"subtype": "erp", "staff_cap": 49},
	"b2b_book20": {"accounts": 20, "staff": 6},
	"b2b_book330": {"accounts": 330, "staff": 50},
}
## The load, in percent, a manual founder holds the servers under (the default is the amber line).
const SERVER_LINES := {"lean": 95, "wide": 60}
## The most presses a founder makes on the servers in one week.
const SERVER_PRESSES := 40
## The months of costs the cash must leave for a hire, and for the first hire by the cash arm.
const HIRE_MONTHS := 6.0                                   # [WORKING]
const FIRST_HIRE_MONTHS := {"spend": 2.0, "hoard": 6.7}    # [WORKING]
## The months of today's costs the cash must keep once a move's up-front rent is paid (by the cash arm), and the office a
## move goes up to.
const MOVE_MONTHS := {"": 6.0, "spend": 2.0}               # [WORKING]
const NEXT_OFFICE := {"home": "ishani", "ishani": "plaza", "plaza": "loft"}
const PRODUCT_NAMES := {"erp": "Sahra", "note_tool": "Notly", "video_clip": "Klipo"}
## The employees of a probe company up to six people (the founder is the n-th), in turn.
const SMALL_CREW := [HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_DESIGNER, HRConstants.ROLE_TESTER,
	HRConstants.ROLE_DEVELOPER, HRConstants.ROLE_PRODUCT_MANAGER]
## The larger companies: how many employees of each CREW_ROLES role beside the founder.
const CREW_ROLES := [HRConstants.ROLE_PRODUCT_MANAGER, HRConstants.ROLE_DESIGNER, HRConstants.ROLE_DEVELOPER,
	HRConstants.ROLE_TESTER]
const CREW_MIX := {12: [2, 2, 5, 2], 25: [3, 4, 12, 5], 50: [6, 8, 25, 10]}
## What one person of a larger company draws for the stat (0 to 10) of their role: 1.5 to 4 stars, 2.7 on average.
const STAT_SPREAD := [6, 4, 8, 5, 3, 6, 7, 4, 5, 6]
# The played run has three answer policies on one world, a controlled experiment on what
# the event cards do to the revenue curve:
#   full_run          — "sensible": a promise when one is open, then a stall, and a
#                       discount only when nothing else is left.
#   full_run_naive    — always the first unlocked row.
#   full_run_discount — the discount first, every time it is offered.
# The Series A policies sit on top of the sensible answers (sim only): only what happens once
# the door is open differs — see "The Series A hunt". An optional fifth spec part `replay=<K>`
# sets the naive table's per-fund replays (default 20; 0 turns them off).
#   full_run_lean     — B2B that stops hiring at seven people and walks the table: the bootstrap
#                       road, since profitable_bootstrap needs the Series A decision faced.
#   full_run_b2c*     — the consumer runs: the founder takes the support desk once anyone pays,
#                       and hires on B2C_LADDER beside the reps the desk needs.
#   full_run_b2c_k1   — the consumer run that stops at the K1 steps: how far K1 alone carries.
# Every played run takes the seed round the week its door opens — see "The seed round".
# The fixtures:
#   b2c           — a consumer product the sprint engine builds itself, the lead planning every
#                   sprint; its MVP release brings the launch audience and opens the paid tier.
#   b2c_neglect   — a note app nobody tends, at its MVP with a bug backlog: it grows until its audience
#                   expects more than the MVP gives, then erodes.
#   The B2B fixtures seed the live ERP at a fixed ladder of line tiers (B2B_PRODUCTS) and start no sprint, so the
#   product alone decides the book; b2c_neglect has the lines but starts none.

static var _fires: Dictionary = {}      # id -> fire count
static var _picks: Dictionary = {}      # id -> resolve count
static var _stop_day: int = 0              # the tick (week) the run stops on
static var _stopped: bool = false
static var _preset: String = ""
static var _mode: String = ""
static var _wired: bool = false
static var _full_run: bool = false         # "full_run": day 1, nothing seeded, the founder plays it
static var _hire_started: bool = false
static var _last_appetite: String = ""     # PROBE SIGNAL on change
static var _discount_uses: Dictionary = {}  # customer id -> discounts taken
static var _policy: String = "sensible"     # full_run answer policy: sensible | naive | discount
static var _subtype: String = ""            # full_run*: the product chosen on the first morning
static var _staff_cap: int = 0              # full_run*: the headcount the B2B ladder stops at
static var _k1_only: bool = false           # full_run*: never plan a K2 or K3 step
static var _fix_arm: String = ""            # full_run*: "" | none | worst | due | off (see PRESETS)
static var _no_stop: bool = false           # full_run*: an emergency never stops the sprint for its fix
static var _core_only: bool = false         # full_run*: the sprint keeps no feature or request card outside the core
static var _plan_actions: int = 0           # the plan's Sprint-tab actions: apply the lead, each add and remove, start (the arms' parking is not one)
static var _desk: bool = false              # full_run*: the founder leaves the reps' band to the reps
static var _release_seen: bool = false      # PROBE UFLUX: a version shipped since the last weekly reading
static var _account_u: Dictionary = {}      # PROBE UFLUX: account id -> its fit at the last reading or its signature
static var _u_unexplained_weeks: int = 0    # PROBE END: the weeks PROBE UFLUX counted an unexplained account
static var _server_policy: String = ""      # full_run*: "" | lean | wide | auto (see PRESETS)
static var _server_clicks: int = 0          # PROBE END: the founder's Increase and Decrease presses
static var _auto_grows: int = 0             # PROBE END: the automatic increases
static var _units_seen: int = 0             # the units bought at the last change of the servers
static var _outages: Dictionary = {}        # PROBE END: tier -> night outages
static var _clause_ended: int = 0           # PROBE END: the contracts the server clause ended
static var _cash_arm: String = ""            # full_run*: "" | spend | hoard (see PRESETS)
static var _first_hire_day: int = -1        # PROBE END: the tick of the first hire
static var _first_hire_runway: float = 0.0  # PROBE END: the months of that week's costs the cash covered
static var _move_days: Array[int] = []      # PROBE END: the ticks a move was decided on
static var _desks_full: bool = false        # PROBE DECISION: a wanted hire is already waiting on a full office
static var _lost_lead: Prospect = null      # PROBE REPLOSS: the lead the last reported loss took off the registry
static var _bugs_open: int = 0              # PROBE BUGS: the open bugs at the last weekly line
static var _bugs_cleared: int = 0           # PROBE BUGS: bugs a fix card cleared since then
static var _support_weeks: int = 0          # PROBE END: the weeks a live product had a rep at the support desk
static var _support_reports: int = 0        # PROBE END: the weeks among them that mailed a report
static var _support_news: Dictionary = {}   # PROBE END: news kind -> reports it was in
static var _support_at: int = -1            # the arrival minute of the last report counted
const SUPPORT_NEWS := {"SUPPORT_RPT_NEW_WORST": "worst", "SUPPORT_RPT_NEW_CLEARED": "cleared",
	"SUPPORT_RPT_SHIPPED": "shipped", "SUPPORT_RPT_NEW_PRIORITY": "priority", "SUPPORT_RPT_BEHIND": "behind"}
static var _runway_weeks: Dictionary = {}   # phase -> Vector2i(weeks with a finite runway, weeks)
static var _min_cash_pre_seed: int = 0      # the lowest weekly cash before the seed round closed
static var _run_seed: int = 424242
static var _fires_by_day: Dictionary = {}   # tick -> card fires that week, for PROBE WEEK
static var _meetings_by_day: Dictionary = {}  # tick -> the founder's sittings that week, for PROBE WEEK
static var _signs_by_day: Dictionary = {}   # tick -> B2B signings that week, for PROBE WEEK
static var _first_sign_day: int = -1        # PROBE END: the tick of the run's first B2B signing
static var _first_revenue_day: int = -1     # PROBE END: the first daily tick that closed with MRR
static var _open_weeks: Array[int] = []     # weeks 1-12 whose 08:00 found the B2B market open
static var _gate_day: int = -1              # the day phase_gate_reached(3) fired (PROBE GATE)
static var _gate_logged: bool = false
static var _mb_acc: Dictionary = {}         # burn id -> realised sum over the open fiscal month
static var _mb_ticks: int = 0               # dispatched ticks folded into _mb_acc
static var _vc_policy: String = ""          # "" | "naive" | "cautious" | "walk" | "product"
static var _replay_k: int = -1              # naive only: table replays per fund; -1 = not given
static var _window: Vector2i = Vector2i.ZERO   # the company's start hour and hours; zero = the default workday
static var _vc_done: bool = false           # the one table this run gets has been played
static var _vc_booked: String = ""          # the fund the current booking is with
static var _vc_meet_day: int = -1           # the day the last meeting was played
const TABLE_PUSH_CAP := 64                  # runaway backstop for a push loop, never reached in play
const DUE_BUGS := 2                         # the "due" arm fixes every line with this many open bugs, times k
const FIXTURE_BUG_LINE := "line_erp_ledger"   # the ERP core line the fixture presets put their bugs on (every B2B account uses it)


# ============================================================================
#  Entry
# ============================================================================

static func run(spec: String, payload: Dictionary) -> void:
	# spec = "<preset>:<weeks>:<mode>", e.g. "b2b_solo:13:sim" or "b2c:9:3".
	var parts: PackedStringArray = spec.split(":", false)
	if parts.size() < 2:
		print("PROBE ERROR bad spec '%s' (want <preset>:<weeks>[:<mode>])" % spec)
		return
	_preset = String(parts[0])
	_stop_day = int(parts[1])
	_mode = String(parts[2]) if parts.size() > 2 else "sim"
	# Optional 4th part: the run seed, so one preset can be sampled across seeds.
	_run_seed = int(parts[3]) if parts.size() > 3 else 424242
	# Optional 5th+ parts: named options. replay=<K> (full_run_vc_naive), window=<start hour>-<hours>, the
	# company's workday (11-13 is 11:00 to 24:00), and build=<demo|ea|full>, the build whose cards and endings the run
	# plays (the demo unless named; sim only, as a milestone's paper stops the real clock).
	_replay_k = -1
	_window = Vector2i.ZERO
	var build: String = EndingsSystem.BUILD_DEMO
	for idx in range(4, parts.size()):
		var extra: String = String(parts[idx])
		if extra.begins_with("replay="):
			_replay_k = maxi(0, int(extra.trim_prefix("replay=")))
		elif extra.begins_with("window="):
			var hours: PackedStringArray = extra.trim_prefix("window=").split("-")
			_window = Vector2i(int(hours[0]), int(hours[1]))
		elif extra.begins_with("build="):
			build = extra.trim_prefix("build=")
	if not PRESETS.has(_preset):
		print("PROBE ERROR unknown preset '%s' (have %s)" % [_preset, ", ".join(PRESETS.keys())])
		return
	if build not in EndingsSystem.SHIPPED_SCOPES_BY_BUILD or (build != EndingsSystem.BUILD_DEMO and _mode != "sim"):
		print("PROBE ERROR bad build '%s' (have %s, sim only past the demo)" % [build, ", ".join(EndingsSystem.SHIPPED_SCOPES_BY_BUILD.keys())])
		return

	_fires.clear()
	_picks.clear()
	_full_run = false
	_fix_arm = ""
	_no_stop = false
	_core_only = false
	_desk = false
	_release_seen = false
	_account_u = {}
	_u_unexplained_weeks = 0
	_server_policy = ""
	_server_clicks = 0
	_auto_grows = 0
	_units_seen = 0
	_outages = {}
	_clause_ended = 0
	_cash_arm = ""
	_first_hire_day = -1
	_first_hire_runway = 0.0
	_move_days = []
	_desks_full = false
	_bugs_open = 0
	_bugs_cleared = 0
	_support_weeks = 0
	_support_reports = 0
	_support_news = {}
	_support_at = -1
	ProductState.bugs_free = false
	_hire_started = false
	_gate_day = -1
	_gate_logged = false
	_stopped = false
	_mb_acc = {}
	_mb_ticks = 0
	_vc_policy = ""
	_vc_done = false
	_vc_booked = ""
	_vc_meet_day = -1
	_runway_weeks = {}
	_fires_by_day = {}
	_meetings_by_day = {}
	_signs_by_day = {}
	_first_sign_day = -1
	_first_revenue_day = -1
	_open_weeks = []
	# The presets measure the demo unless the spec names a build. A --build=ea in Main Run Args would otherwise turn the
	# bootstrap win into a non-terminal milestone and a real-clock run would sit on its paper.
	EndingsSystem.build_scope_override = build
	# The summary frequency is the player's setting; the probe logs the monthly cadence.
	SummarySystem.frequency_override = "monthly"
	GameState.initialize_run(payload)
	# Pin the seed so two probe runs of the same preset are comparable line for line, as
	# main.gd's _seed_run_reproducible does for the shots. initialize_run seeds from
	# Time.get_ticks_msec(), which would make every fire table a one-off.
	GameState.run_seed = _run_seed
	seed(GameState.run_seed)
	RngStreams.reseed(GameState.run_seed)   # the named streams, not just the global generator
	if _window != Vector2i.ZERO:
		WorkHoursSystem.set_company_start_hour(_window.x)
		WorkHoursSystem.set_company_hours(_window.y)
	_wire_log()
	_seed_world(_preset)
	_min_cash_pre_seed = GameState.cash
	if _vc_policy == "naive":
		_replay_k = 20 if _replay_k < 0 else _replay_k
	else:
		_replay_k = 0
	if _vc_policy != "" and _mode != "sim":
		# The policies are defined and measured on sim only.
		print("PROBE ERROR %s is sim-only" % _preset)
		Engine.get_main_loop().quit()
		return

	print("PROBE BEGIN preset=%s weeks=%d mode=%s seed=%d" % [_preset, _stop_day, _mode, GameState.run_seed])
	if _vc_policy != "":
		print("PROBE VC_CONFIG policy=%s replay=%d" % [_vc_policy, _replay_k])
	_log_state()
	_log_market()
	_play_the_week()                # the run opens at the first week's 08:00

	if _mode == "sim":
		_run_sim()
	else:
		_run_realtime(int(_mode))


# ============================================================================
#  Logging seams
# ============================================================================

static func _wire_log() -> void:
	if _wired:
		return
	_wired = true
	# event_triggered fires once for every card the engine puts up (EvEngine._announce),
	# resolved or not, so it and not the history is the fire log's source.
	EventBus.event_triggered.connect(_on_fire)
	EventBus.customer_churned.connect(_on_churn)
	EventBus.promise_created.connect(func(pid: String) -> void: _log_promise(pid, "created"))
	EventBus.promise_kept.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))
	EventBus.promise_broken.connect(func(pid: String) -> void: _log_promise(pid, "resolved"))
	EventBus.build_phase_changed.connect(_on_build_phase)
	EventBus.sprint_closed.connect(_on_sprint_closed)
	EventBus.sprint_started.connect(_on_sprint_started)
	EventBus.line_bugs_cleared.connect(func(_line: String, n: int) -> void: _bugs_cleared += n)
	EventBus.month_ended.connect(_on_month_ended)
	EventBus.phase_gate_reached.connect(_on_gate_reached)
	EventBus.day_tick_completed.connect(_on_day_tick_completed)
	EventBus.night_skipped.connect(_on_week_start)
	EventBus.meeting_entered.connect(func(_lead_id: String) -> void:
		_meetings_by_day[GameState.day] = int(_meetings_by_day.get(GameState.day, 0)) + 1)
	EventBus.deal_signed.connect(_on_signed)
	EventBus.meeting_lost.connect(_on_lost)
	EventBus.rep_deal_lost.connect(_on_rep_lost)
	EventBus.prospect_arrived.connect(_on_lead)
	EventBus.version_shipped.connect(func(_n: int) -> void: _release_seen = true)
	EventBus.infra_changed.connect(_on_infra_changed)
	EventBus.milestone_reached.connect(func(id: String, _data: Dictionary) -> void:
		print("PROBE MILESTONE day=%d id=%s" % [GameState.day, id]))


static func _on_month_ended(_data: Dictionary) -> void:
	# The calendar-month ledger: the entry SummarySystem just pushed.
	if GameState.month_history.is_empty():
		return
	var e: Dictionary = GameState.month_history[GameState.month_history.size() - 1]
	var n: int = GameState.month_history.size()
	var growth: String = "n/a"
	if n >= 2:
		var prev: int = int(GameState.month_history[n - 2].get("mrr_close", 0))
		if prev > 0:
			growth = "%.1f" % ((float(int(e.get("mrr_close", 0))) / float(prev) - 1.0) * 100.0)
	print("PROBE MONTH day=%d n=%d mrr_close=%d income=%d expense=%d net=%d red=%d growth_pct=%s streak=%d profit_streak=%d" % [
		GameState.day, n, int(e.get("mrr_close", 0)), int(e.get("income", 0)), int(e.get("expense", 0)),
		int(e.get("net", 0)), int(e.get("red_weeks", 0)), growth,
		GameState.get_mrr_growth_streak(PhaseGateSystem.GROWTH_MIN_PCT), GameState.get_profitable_month_streak()])
	if _full_run:
		_log_month_burn(e, n)


static func _on_build_phase(new_phase: String) -> void:
	# A public release. open_bugs is the product's bug store after the close.
	if new_phase != "shipped":
		return
	print("PROBE SHIP day=%d version=%d label=%s open_bugs=%d escaped=%d" % [
		GameState.day, ProductState.version(), SprintSystem.version_label(ProductState.version()),
		ProductState.open_bugs(), (GameState.product.release.get("escaped", []) as Array).size()])


## Every sprint start: the fix cards in the plan against the capacity it was planned for (stored when the sprint
## began, before the hours decision could move it).
static func _on_sprint_started(number: int) -> void:
	print("PROBE FIX day=%d sprint=%d weeks=%d %s k=%.3f" % [GameState.day, number, SprintSystem.sprint_weeks(), _fix_ledger(),
		SprintCatalog.limit_k()])


## The sprint's fix cards (ids, or "-") and their remaining points against the sprint's capacity; a bug sprint spends
## more than half the capacity on fixes.
static func _fix_ledger() -> String:
	var p: Dictionary = GameState.product
	var fixes: Array = p.sprint.cards.filter(func(id: String) -> bool: return p.cards[id].kind == "fix")
	var fix_load: float = 0.0
	for id in fixes:
		fix_load += SprintSystem.remaining(p.cards[id])
	var capacity: float = float(p.sprint.capacity)
	var share: float = fix_load / capacity if capacity > 0.0 else 0.0
	return "fix_load=%.2f capacity=%.2f share=%.3f cards=%s bug_sprint=%s" % [fix_load, capacity, share,
		",".join(fixes) if not fixes.is_empty() else "-", str(share > 0.5)]


## Every sprint close, released or not: what shipped, how much carried and the velocity.
static func _on_sprint_closed(number: int) -> void:
	var r: Dictionary = GameState.product.release
	print("PROBE SPRINT day=%d n=%d label=%s shipped=%s carried=%d velocity=%d/%d" % [
		GameState.day, number, SprintSystem.version_label(int(r.number)) if int(r.number) > 0 else "-",
		",".join(r.shipped.map(func(c: Dictionary) -> String: return c.id)), r.carried.size(),
		int(r.velocity.done), int(r.velocity.total)])


# ============================================================================
#  Gate-day measurement: the gate-open day and the realised month (all full_run presets)
# ============================================================================
#
# Read-only lines. They draw no randomness and write no state, so every other PROBE line
# of a full_run is byte-identical with or without them.

static func _on_gate_reached(next_phase: int) -> void:
	# The Series A door is the gate whose next phase is 3. It fires in the phase-check slot of
	# the daily dispatch; the snapshot is printed with that day's PROBE STATE (_log_state), so
	# both lines describe the same moment — after the day's cards and the founder's moves.
	if next_phase == 3 and _gate_day < 0:
		_gate_day = GameState.day


static func _on_day_tick_completed(day: int) -> void:
	if _first_revenue_day < 0 and GameState.mrr > 0:
		_first_revenue_day = day
	if _full_run:
		_mb_add_tick()


const MARKET_LOG_WEEKS := 4

## PROBE MARKET — the Piyasa list this week: its total, its leader and the founder's valuation
## beside them. Once every MARKET_LOG_WEEKS weeks keeps the ledger short; the list changes slowly.
static func _log_market() -> void:
	var week: int = GameState.day
	var leader: Dictionary = MarketCatalog.leader(week)
	print("PROBE MARKET day=%d total=%d leader=%s leader_value=%d listed=%d player=%.1f" % [
		week, roundi(MarketCatalog.list_total(week)), String(leader["id"]),
		roundi(MarketCatalog.value(leader, week)), MarketCatalog.listed(week).size(),
		GameState.get_valuation_m()])


## This tick's burn, by category. The breakdown holds daily rates written in the finance slot,
## which applies them for the tick's DAYS_PER_TICK days. The month closes in slot 0, before the
## finance slot, so a tick's burn always belongs to the month it is folded into here.
static func _mb_add_tick() -> void:
	var bd: Dictionary = FinanceSystem.get_burn_breakdown()
	for raw in FinanceSystem.BURN_IDS:
		var k: String = String(raw)
		_mb_acc[k] = int(_mb_acc.get(k, 0)) + TimeModel.DAYS_PER_TICK * int(bd.get(k, 0))
	_mb_ticks += 1


## PROBE MONTH_BURN — the closed month's expense split into the burn categories. one_time is
## what the categories do not explain: the one-off charges (hire commission, severance,
## training, the licences a sprint start pays, an event card's cash) that accrue straight into
## the month's expense.
static func _log_month_burn(e: Dictionary, n: int) -> void:
	var cat: int = 0
	for raw in FinanceSystem.BURN_IDS:
		cat += int(_mb_acc.get(String(raw), 0))
	var s0: int = int(e.get("start_day", 0))
	var e0: int = int(e.get("end_day", 0))
	var exp: int = int(e.get("expense", 0))
	print("PROBE MONTH_BURN day=%d n=%d start=%d end=%d ticks=%d ticks_expected=%d %s cat_sum=%d expense=%d one_time=%d income=%d" % [
		GameState.day, n, s0, e0, _mb_ticks, e0 - s0, _burn_fields(_mb_acc), cat, exp, exp - cat, int(e.get("income", 0))])
	_mb_acc = {}
	_mb_ticks = 0


## "<burn id>=<n>" for every burn category, 0 for one nothing has written yet.
static func _burn_fields(by_id: Dictionary) -> String:
	return " ".join(FinanceSystem.BURN_IDS.map(func(k: String) -> String: return "%s=%d" % [k, int(by_id.get(k, 0))]))


## PROBE GATE — the company on the day the Series A door opens: who is on the payroll, what
## a month costs at today's rate, what the last closed month actually cost, and the margins.
## Every burn category is printed as the finance system holds it; nothing is assumed.
static func _log_gate() -> void:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var by_role: Dictionary = {}          # role -> [total, junior, mid, senior]
	var on_leave: int = 0
	for c in staff:
		var r: String = String(c.role)
		var row: Array = by_role.get(r, [0, 0, 0, 0])
		row[0] = int(row[0]) + 1
		var lv: int = clampi(int(c.level), HRConstants.LEVEL_JUNIOR, HRConstants.LEVEL_SENIOR)
		row[1 + lv] = int(row[1 + lv]) + 1
		by_role[r] = row
		if String(c.status) == HRConstants.STATUS_ON_LEAVE:
			on_leave += 1
	var order: Array = HRConstants.EMPLOYEE_ROLES.duplicate()
	for r in by_role.keys():
		if not order.has(r):
			order.append(r)
	var parts: Array[String] = []
	for r in order:
		var row: Array = by_role.get(r, [0, 0, 0, 0])
		parts.append("%s:%d/%d-%d-%d" % [String(r), int(row[0]), int(row[1]), int(row[2]), int(row[3])])
	var bd: Dictionary = FinanceSystem.get_burn_breakdown()
	var bd_sum: int = 0
	for raw in FinanceSystem.BURN_IDS:
		bd_sum += int(bd.get(String(raw), 0))
	var runrate: int = GameState.daily_burn * TimeModel.DAYS_PER_MONTH
	var rr_margin: String = "n/a"
	if GameState.mrr > 0:
		rr_margin = str(int((GameState.mrr - runrate) * 100 / GameState.mrr))
	var last_n: int = GameState.month_history.size()
	var last: Dictionary = GameState.month_history[last_n - 1] if last_n > 0 else {}
	var last_income: int = int(last.get("income", 0))
	var last_expense: int = int(last.get("expense", 0))
	var last_net: int = int(last.get("net", 0))
	var last_margin: String = "n/a"
	if last_income > 0:
		last_margin = str(int(last_net * 100 / last_income))
	print("PROBE GATE day=%d emp=%d on_leave=%d roles=%s payroll_monthly=%d %s bd_sum=%d daily_burn=%d expense_runrate=%d mrr=%d runrate_margin_pct=%s cust=%d accounts=%d cash=%d last_n=%d last_start=%d last_end=%d last_income=%d last_expense=%d last_net=%d last_margin_pct=%s win3_margin_pct=%d win6_margin_pct=%d profit_streak=%d growth_avg_pct=%d" % [
		GameState.day, staff.size(), on_leave, ",".join(parts), CharacterRegistry.get_total_monthly_salaries(),
		_burn_fields(bd), bd_sum, GameState.daily_burn, runrate, GameState.mrr, rr_margin,
		CustomerRegistry.get_all().size(), CustomerRegistry.account_count(), GameState.cash,
		last_n, int(last.get("start_day", -1)), int(last.get("end_day", -1)), last_income, last_expense, last_net, last_margin,
		GameState.get_window_margin_pct(3), GameState.get_window_margin_pct(6),
		GameState.get_profitable_month_streak(), GameState.get_mom_growth_avg_pct(PitchConstants.ARR_WINDOW_MONTHS)])


## An increase while Auto adjust is on is the automatic one: the founder's own presses are made with it off or on a policy
## that never switches it on.
static func _on_infra_changed() -> void:
	if ProductState.infra_auto() and InfraSystem.units() > _units_seen:
		_auto_grows += 1
	_units_seen = InfraSystem.units()


static func _on_fire(event_id: String) -> void:
	if event_id.begins_with("product.incident_outage_"):
		_outages[InfraSystem.provider()] = int(_outages.get(InfraSystem.provider(), 0)) + 1
	_fires[event_id] = int(_fires.get(event_id, 0)) + 1
	_fires_by_day[GameState.day] = int(_fires_by_day.get(GameState.day, 0)) + 1
	print("PROBE FIRE day=%d hour=%d id=%s src=%s" % [
		GameState.day, GameState.current_hour, event_id, _source_of(event_id)])


static func _source_of(event_id: String) -> String:
	return "pool" if EventGate.is_catalogued(event_id) else "factory:UNMAPPED"


static func _on_churn(customer_id: String) -> void:
	# The autopsy's terminal line. B2BSalesSystem emits the signal before
	# CustomerRegistry.remove(), so the record is still readable.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	if c == null:
		print("PROBE CHURN day=%d id=%s (record already gone)" % [GameState.day, customer_id])
		return
	if c.notice_end_day >= 0 and GameState.day >= c.notice_end_day:
		_clause_ended += 1
	print("PROBE CHURN day=%d id=%s sat=%d tol=%d trust=%.1f phase=%s streak=%d countdown=%d mrr=%d" % [
		GameState.day, customer_id, c.satisfaction, c.tolerance, c.trust_offset,
		c.lifecycle_phase, c.risk_streak, c.churn_countdown, c.mrr])


static func _on_signed(customer_id: String, _seats: int, _seat_price: int) -> void:
	# SalesSystem.add_b2b_customer emits once the account is on the books and before its lead leaves the
	# registry, so both records are readable. A fixture account signs without a lead.
	var c: Customer = CustomerRegistry.get_customer(customer_id)
	var lead: Prospect = ProspectRegistry.get_prospect(customer_id.trim_prefix("co_"))
	_signs_by_day[GameState.day] = int(_signs_by_day.get(GameState.day, 0)) + 1
	if _first_sign_day < 0:
		_first_sign_day = GameState.day
	var levels: Array = SprintCatalog.area_ids().map(func(a: String) -> String:
		return "%s:%.3f" % [a, ProductQuality.level(a)])
	var by: String = "founder" if c.acquisition_source == "founder_pitch" else "rep"
	print("PROBE SIGN day=%d hour=%d id=%s by=%s star=%d weeks=%.1f mrr=%d sector=%s arch=%s tol=%d phase=%d areas=%s" % [
		GameState.day, GameState.current_hour, customer_id, by, c.scale,
		lead.deal_halfweeks / 2.0 if lead != null else 0.0, c.mrr, c.industry,
		lead.archetype_id if lead != null else "-", c.tolerance, GameState.phase, ",".join(levels)])
	if not _fit_readable():
		return
	if lead != null:
		var fit: Dictionary = ProductQuality.prospect_fit(lead)
		print("PROBE FIT day=%d hour=%d id=%s phase=%d sector=%s star=%d by=%s u=%d capped=%s loss=%s tol=%d" % [
			GameState.day, GameState.current_hour, customer_id, GameState.phase, c.industry, c.scale, by,
			fit.value, str(fit.capped), fit.loss_area if fit.loss_area != "" else "-", c.tolerance])
	_account_u[customer_id] = ProductQuality.account_fit(c).value


## A loss is reported before its lead leaves the registry (SalesFinalizer.lose) and the desk seller's signal comes after it,
## so the lead is kept here until PROBE REPLOSS reads its fit. The founder's loss is the one lost at the sitting still open on
## that lead (a lost answer, or the table after it that ran out of patience): PROBE MLOSS prints it at once.
static func _on_lost(account: String, reason: String) -> void:
	_lost_lead = null
	for lead: Prospect in ProspectRegistry.get_all():
		if lead.company_name == account:
			_lost_lead = lead
	if not SalesMeetingSystem.is_active() or SalesMeetingSystem.active_lead_id() != _lost_lead.id:
		return
	var fit: Dictionary = _lead_fit(_lost_lead)
	var target: String = SalesLedger.loss_target(account)
	print("PROBE MLOSS day=%d hour=%d id=%s sector=%s star=%d phase=%d reason=%s target=%s u=%s capped=%s loss=%s" % [
		GameState.day, GameState.current_hour, _lost_lead.id, _lost_lead.industry, _lost_lead.star, GameState.phase, reason,
		target if target != "" else "-", fit.value, str(fit.capped), fit.loss_area if fit.loss_area != "" else "-"])


static func _on_rep_lost(_rep_id: String, lead_id: String, area: String) -> void:
	var fit: Dictionary = ProductQuality.prospect_fit(_lost_lead)
	print("PROBE REPLOSS day=%d hour=%d id=%s phase=%d sector=%s star=%d u=%d capped=%s loss=%s" % [
		GameState.day, GameState.current_hour, lead_id, GameState.phase, _lost_lead.industry, _lost_lead.star,
		fit.value, str(fit.capped), area])


static func _on_lead(lead_id: String) -> void:
	var p: Prospect = ProspectRegistry.get_prospect(lead_id)
	var fit: Dictionary = _lead_fit(p)
	print("PROBE LEAD day=%d id=%s arch=%s sector=%s star=%d phase=%d u=%s loss=%s" % [
		GameState.day, lead_id, p.archetype_id, p.industry, p.star, GameState.phase,
		fit.value, fit.loss_area if fit.loss_area != "" else "-"])


## A product with no line content (no type picked yet) has no core area to fit: its leads read `u=-` and its
## signatures and accounts print no fit.
static func _fit_readable() -> bool:
	return not SprintCatalog.capabilities("core").is_empty()


static func _lead_fit(lead: Prospect) -> Dictionary:
	return ProductQuality.prospect_fit(lead) if _fit_readable() else {"value": "-", "capped": "-", "loss_area": ""}


static func _log_promise(promise_id: String, stage: String) -> void:
	var p: Promise = PromiseRegistry.get_promise(promise_id)
	if p == null:
		return
	var c: Customer = CustomerRegistry.get_customer(p.customer_id)
	var sat: int = c.satisfaction if c != null else -1
	var tol: int = c.tolerance if c != null else -1
	var cd: int = c.churn_countdown if c != null else -99
	var ph: String = c.lifecycle_phase if c != null else "(gone)"
	print("PROBE PROMISE day=%d stage=%s id=%s status=%s feature=%s deadline=%d cust=%s sat=%d tol=%d countdown=%d phase=%s" % [
		GameState.day, stage, promise_id, p.status, p.feature_id, p.deadline_day,
		p.customer_id, sat, tol, cd, ph])


static func _log_state() -> void:
	var runway: float = GameState.get_runway_months()
	_runway_weeks[GameState.phase] = _runway_weeks.get(GameState.phase, Vector2i.ZERO) + Vector2i(int(not is_inf(runway)), 1)
	if GameState.seed_closed_day < 0:
		_min_cash_pre_seed = mini(_min_cash_pre_seed, GameState.cash)
	# The B2C aggregate (audience, its satisfaction, open bugs) and the quality term q that the
	# audience formula actually reads — the numbers the B2C growth verdicts are read from. q is -1
	# off a live consumer product (nothing to read).
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	var q: float = SalesSystem.b2c_quality() if ProductState.is_live() and not SalesSystem.is_b2b_market() else -1.0
	var sig: Dictionary = PhaseGateSystem.series_a_signal()
	var appetite: String = String(sig.get("state", "closed"))
	# The Series A door is MRR only, so the gate reading is the signal state plus
	# Frank's approach step (0-4, phase.series_a_approach) — the growth streak is no
	# longer a gate half. It is still logged on the PROBE MONTH line, where it feeds the
	# valuation band rather than the door.
	print("PROBE STATE day=%d cash=%d mrr=%d brand=%d burn=%d runway=%s cust=%d emp=%d promises=%d phase=%d aud=%d sat=%d open_bugs=%d q=%.1f appetite=%s approach=%d gate_ready=%s profit_streak=%d lost=%d" % [
		GameState.day, GameState.cash, GameState.mrr, GameState.brand, GameState.daily_burn,
		("INF" if is_inf(runway) else "%.2f" % runway),
		CustomerRegistry.get_all().size(), CharacterRegistry.get_employees().size(),
		PromiseRegistry.get_all().size(), GameState.phase,
		int(GameState.get_flag("b2c_audience", 0)), (ub.satisfaction if ub != null else -1),
		ProductState.open_bugs(), q,
		appetite, int(sig.get("approach", 0)), str(GameState.phase_gate_ready), GameState.get_profitable_month_streak(),
		GameState.run_customers_lost])
	if appetite != _last_appetite:
		print("PROBE SIGNAL day=%d appetite=%s->%s mrr=%d approach=%d" % [
			GameState.day, _last_appetite, appetite, GameState.mrr, int(sig.get("approach", 0))])
		_last_appetite = appetite
	if _full_run and _gate_day == GameState.day and not _gate_logged:
		_gate_logged = true
		_log_gate()


static func _log_customers() -> void:
	# The churn autopsy's raw material. TARGET is the number each account drifts toward
	# (B2BSalesSystem.satisfaction_target), and it is printed beside satisfaction and tolerance
	# because "why did nobody slide" and "why did everybody slide" are the same question asked
	# of these three numbers. The SAT line's target is the book's mean fit, the product term alone.
	var book: Array = CustomerRegistry.get_by_market("b2b")
	var satisfied: int = 0
	var fit_sum: int = 0
	for c in book:
		fit_sum += ProductQuality.account_fit(c).value
		if c.satisfaction >= c.tolerance:
			satisfied += 1
		print("PROBE CUST day=%d id=%s sat=%d tol=%d target=%d trust=%.1f phase=%s streak=%d cd=%d mrr=%d bugs=%d" % [
			GameState.day, c.id, c.satisfaction, c.tolerance,
			B2BSalesSystem.satisfaction_target(c), c.trust_offset,
			c.lifecycle_phase, c.risk_streak, c.churn_countdown, c.mrr, B2BSalesSystem.account_bugs(c)])
	# The fraction of the book at or above its bar — the number the
	# tolerance re-seat is judged by ("~60-70% of a 5-account book for a good v1, ~20% bad").
	if not book.is_empty():
		print("PROBE SAT day=%d satisfied=%d/%d target=%d" % [GameState.day, satisfied, book.size(),
			roundi(float(fit_sum) / book.size())])


## PROBE UFLUX — the B2B book's fit read once a week against the last reading (or the account's signature). A
## fit moves only when a version ships or the account's renewal window opens (Customer.market_ref is copied
## then); a change with neither is counted as unexplained. A window opens on the day next_renewal_day minus the
## request lead falls on, so a copy at any other time is unexplained too.
static func _log_uflux() -> void:
	var released: bool = _release_seen
	_release_seen = false
	var book: Array = CustomerRegistry.get_by_market("b2b")
	if book.is_empty() or not _fit_readable():
		return
	var lead: int = TimeModel.ticks(int(SprintCatalog.cfg("request.before_renewal_weeks")))
	var now: Dictionary = {}
	var changed: int = 0
	var renewal: int = 0
	var unexplained: int = 0
	for c in book:
		now[c.id] = ProductQuality.account_fit(c).value
		if now[c.id] == _account_u.get(c.id, now[c.id]):
			continue
		changed += 1
		if SprintBridges.next_renewal_day(c) - lead == GameState.day:
			renewal += 1
		elif not released:
			unexplained += 1
	print("PROBE UFLUX day=%d changed=%d release=%s renewal=%d unexplained=%d" % [
		GameState.day, changed, str(released), renewal, unexplained])
	_u_unexplained_weeks += int(unexplained > 0)
	_account_u = now


## PROBE B2C — the consumer week: the audience and who pays it at what price, the userbase's
## satisfaction beside the target it drifts toward, open bugs, the users lost so far, the
## quality term q the audience formula reads (and the fit u it is made of, with the audience's
## place on the star rows), interest, server occupancy, and the support desk: who is on it, the
## reports waiting, and how many arrive and get validated a day.
static func _log_b2c() -> void:
	if not ProductState.is_live() or ProductState.market_type() != "b2c":
		return
	var ub: Customer = CustomerRegistry.get_customer(SalesSystem.B2C_USERBASE_ID)
	var price: int = int(GameState.get_flag("b2c_price", 0)) if GameState.get_flag("b2c_paid_tier_open", false) else 0
	print("PROBE B2C day=%d aud=%.1f paying=%d price=%d conv=%.3f sat=%d sat_target=%d open_bugs=%d lost=%.1f q=%.1f interest=%.1f occ=%.2f desk=%d incoming=%d inflow_day=%.2f validation_day=%.2f u=%d aud_star=%.2f" % [
		GameState.day, SalesSystem.b2c_audience(), SalesSystem.b2c_paying_users(), price,
		SalesSystem.conversion_rate(price) if price > 0 else 0.0, ub.satisfaction if ub != null else -1,
		SalesSystem.b2c_satisfaction_target(),
		ProductState.open_bugs(), SalesSystem.b2c_users_lost(),
		SalesSystem.b2c_quality(), ProductRead.interest(),
		InfraSystem.load_percent() / 100.0, SupportSystem.desk_roster().size(), ProductState.reports_incoming(),
		SupportSystem.reports_per_day(), SupportSystem.validation_per_day(),
		ProductQuality.fit(SalesSystem.B2C_FIT_CTX).value, ProductQuality._audience_star()])


## PROBE SERVER — the servers this week, as the Sunucu block reads them.
static func _log_server() -> void:
	if not ProductState.is_live():
		return
	print("PROBE SERVER day=%d units=%d tier=%s load=%d bill=%d auto=%d" % [GameState.day, InfraSystem.units(),
		InfraSystem.provider(), InfraSystem.load_percent(), InfraSystem.monthly_bill(), int(ProductState.infra_auto())])


## PROBE BUGS — the week's bugs: how many arrived (the change in the store plus what fix cards cleared), the store
## now, and the store just before this week's sprint close (the snapshot the weekly tick took first).
static func _log_bugs() -> void:
	if not ProductState.is_live():
		return
	var open: int = ProductState.open_bugs()
	print("PROBE BUGS day=%d new=%d open=%d pre=%d" % [GameState.day, open - _bugs_open + _bugs_cleared, open,
		open - ProductState.open_bugs_delta()])
	var by_line: Dictionary = ProductState.open_bugs_by_line()
	var lines: Array = by_line.keys()
	lines.sort()
	print("PROBE LINES day=%d %s" % [GameState.day, ",".join(lines.map(func(l: String) -> String:
		return "%s=%d" % [l, by_line[l]])) if not lines.is_empty() else "-"])
	_bugs_open = open
	_bugs_cleared = 0


## PROBE END's support report counters: a week with a rep and a live product is a week the report could come; the
## report the tick just wrote waits in the outbox or is already delivered, and its arrival minute tells it from
## the ones counted before. Read before the founder plays the week, so the desk is the one the tick saw.
static func _count_support_report() -> void:
	if not ProductState.is_live() or CustomerRepSystem.ranked_reps().is_empty():
		return
	_support_weeks += 1
	for m in GameState.mail_outbox + GameState.messages:
		if m.kind == SupportSystem.REPORT_KIND and int(m.at) > _support_at:
			_support_at = int(m.at)
			_support_reports += 1
			var kinds: Array = m.args.news.map(func(item: Dictionary) -> String: return SUPPORT_NEWS[item.key])
			for kind in SUPPORT_NEWS.values():
				if kinds.has(kind):
					_support_news[kind] = int(_support_news.get(kind, 0)) + 1


## PROBE AREAS — the live product's areas this week. ProductQuality.level is read because the screen's
## area_level rounds to halves; the launches are the rival_hits on the area's lines inside the rival window.
static func _log_areas() -> void:
	if not ProductState.is_live():
		return
	var areas: PackedStringArray = []
	for area_id in SprintCatalog.area_ids():
		var caps: Array[String] = SprintCatalog.capabilities(area_id)
		var launches: int = SprintCatalog.recent_hits(caps).size()
		areas.append("%s=%.3f/%d/%d" % [area_id, ProductQuality.level(area_id), caps.size(), launches])
	print("PROBE AREAS day=%d market=%s %s" % [GameState.day, ProductState.market_type(), ",".join(areas)])


static func _log_tally() -> void:
	var ids: Array = _fires.keys()
	ids.sort()
	print("PROBE TALLY_BEGIN")
	for id in ids:
		print("PROBE TALLY %s fires=%d picks=%d src=%s" % [
			id, int(_fires[id]), int(_picks.get(id, 0)), _source_of(String(id))])
	print("PROBE TALLY_END")


# ============================================================================
#  The player: drain every modal the engine puts up
# ============================================================================

static func _drain_modals() -> void:
	# resolve_choice() ends in _pump_queue(), which mounts the next event synchronously —
	# so this loop walks the whole queue. Then the desk's papers are opened, most urgent first,
	# and answered by the same policy: a paper left to lapse would pay an on_expire no policy
	# chose. The guard is a runaway backstop, not a cap: if it ever trips, that IS a finding
	# (an event re-queueing itself inside its own resolution) and it says so instead of
	# hanging the probe.
	var guard: int = 0
	while EventGate.active_id() != "" or not EventGate.desk_papers(1).is_empty():
		guard += 1
		if guard > 64:
			print("PROBE ERROR drain guard tripped at day %d on id=%s — an event is re-queueing inside its own resolution" % [
				GameState.day, EventGate.active_id()])
			return
		if EventGate.active_id() == "":
			# A paper the world has moved past is dropped off the desk instead of opening.
			EventGate.open_paper(String(EventGate.desk_papers(1)[0].id))
			continue
		var id: String = EventGate.active_id()
		var ev: GameEvent = EventGate.active_card()
		if ev == null:
			print("PROBE ERROR active id=%s with null event object" % id)
			return
		var idx: int = _pick_choice(ev)
		if idx < 0:
			print("PROBE ERROR day=%d id=%s has NO unlocked choice — the player would be stuck" % [GameState.day, id])
			return
		var label: String = ev.choices[idx].label
		print("PROBE PICK day=%d id=%s choice=%d label=%s" % [GameState.day, id, idx, label])
		_picks[id] = int(_picks.get(id, 0)) + 1
		# Count discounts BY MODIFIER TYPE (labels are player-facing text).
		for m in ev.choices[idx].modifiers:
			if String(m.get("verb", m.get("type", ""))) == "b2b_retain_discount":
				var cid: String = str(EventGate.active_context().get("customer", m.get("customer_id", "")))
				_discount_uses[cid] = int(_discount_uses.get(cid, 0)) + 1
				print("PROBE DISCOUNT day=%d cust=%s uses=%d" % [GameState.day, cid, int(_discount_uses[cid])])
		EventGate.resolve(id, idx)
		if ev.choices[idx].modifiers.any(func(m: Dictionary) -> bool: return String(m.get("verb", "")) == "sprint_fix_first"):
			print("PROBE STOP day=%d sprint=%d id=%s %s" % [GameState.day, SprintSystem.sprint_number(), id, _fix_ledger()])


# Retention preference, BY MODIFIER TYPE rather than by row index or label. Index is wrong
# because the card's rows are conditional (the promise row vanishes once the pain feature
# ships, so "choice 0" silently becomes a different decision); label is wrong because labels
# are player-facing text. Order = strongest genuine rescue first: a promise and a discount
# both run _recover, a stall only postpones twice, and ignoring is a documented no-op.
#
# This is the probe PLAYING COMPETENTLY, and it matters for what the log proves: picking
# index 0 blindly had it answer "Oyala" on every post-delivery risk card, so the run
# measured a bad player rather than the engine.
const RETAIN_PREFERENCE := ["promise_create", "b2b_retain_delay", "b2b_retain_discount", "b2b_retain_ignore"]
const DISCOUNT_PREFERENCE := ["b2b_retain_discount", "promise_create", "b2b_retain_delay", "b2b_retain_ignore"]


static func _pick_choice(ev: GameEvent) -> int:
	# Runs the modal's OWN gate (EventGate.condition_met on unlock_condition), not a mirror of
	# it, so the probe can never pick a row a human is forbidden to click.
	if _policy != "naive" and ev.tags.has("incident"):
		var emergency: int = _pick_emergency(ev)
		if emergency >= 0:
			return emergency
	# Account cards (retention, the three requests, the CS warning): the policy picks by
	# EFFECT VERB, never by row index or label — rows are conditional and labels are
	# player-facing text. `naive` skips this and takes the first unlocked row below.
	if _policy != "naive" and ev.id.begins_with("customer.") and ev.id != "customer.expansion":
		var order: Array = DISCOUNT_PREFERENCE if _policy == "discount" else RETAIN_PREFERENCE
		for want_verb in order:
			for idx in ev.choices.size():
				if not EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
					continue
				for m in ev.choices[idx].modifiers:
					if String(m.get("verb", m.get("type", ""))) == want_verb:
						return idx
	var first_unlocked: int = -1
	for idx in ev.choices.size():
		if EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
			first_unlocked = idx
			break
	if first_unlocked < 0:
		return -1

	# AFFORDABILITY. The preferred row is taken only if the founder can plausibly pay for
	# it; otherwise the cheapest unlocked row wins. Without this the probe answers every
	# B2C card with its paid option and goes bankrupt on principle: the live pool's cash
	# choices are −$1,500 (bug refund), −$800 (launch push) and −$600 (power-user piece)
	# against an opening balance of $10,000, so three refunds and three launches are most
	# of the company. A founder watching that balance does not do this; neither should the
	# thing standing in for one.
	var budget: float = float(maxi(GameState.cash, 0)) * AFFORDABLE_FRACTION
	if float(-_cash_delta_of(ev.choices[first_unlocked])) <= budget:
		return first_unlocked
	var best: int = first_unlocked
	var best_cost: int = -_cash_delta_of(ev.choices[first_unlocked])
	for idx in ev.choices.size():
		if not EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()):
			continue
		var cost: int = -_cash_delta_of(ev.choices[idx])
		if cost < best_cost:
			best_cost = cost
			best = idx
	return best


## An emergency card is answered by what an option DOES, never by its place or its label: the arm that leaves the
## bugs alone (fix_none) leaves the fix for the next sprint, every other arm stops the sprint for it (unless it
## never does: no_stop). The row the card locks, or the one the arm does not want, falls to the first row left
## open; -1 when no row is open at all (the caller's error).
static func _pick_emergency(ev: GameEvent) -> int:
	var open: Array = range(ev.choices.size()).filter(func(idx: int) -> bool:
		return EventGate.condition_met(ev.choices[idx].unlock_condition, EventGate.active_context()))
	var does := func(idx: int, wanted: Callable) -> bool:
		return ev.choices[idx].modifiers.any(wanted)
	var stops := func(m: Dictionary) -> bool: return String(m.get("verb", "")) == "sprint_fix_first"
	var defers := func(m: Dictionary) -> bool:
		return String(m.get("verb", "")) == "incident" and String(m.get("act", "")).begins_with("defer")
	var wanted: Callable = defers if _fix_arm == "none" else stops
	for idx in open:
		if does.call(idx, wanted) and not (_no_stop and does.call(idx, stops)):
			return idx
	for idx in open:
		if not (_no_stop and does.call(idx, stops)):
			return idx
	return -1


# Fraction of the current balance the founder will spend on any single event choice.
const AFFORDABLE_FRACTION := 0.12


static func _cash_delta_of(choice: EventChoice) -> int:
	var total: int = 0
	for m in choice.modifiers:
		if String(m.get("verb", "")) == "add_cash":
			total += EvEffects.amount(m)
		elif String(m.get("type", "")) == "cash":
			total += int(m.get("delta", 0))
	return total


# ============================================================================
#  Drive mode: sim (deterministic)
# ============================================================================

static func _run_sim() -> void:
	# The game's clock, hour by hour: a visible hour is its own batch, so its cards are shown at
	# that hour and answered before the next, as a player answers them; an unanswered modal
	# would hold every later card behind it. The night is one batch that ends at 08:00, where
	# night_skipped opens the week (_on_week_start). A sprint waiting on its plan holds the clock until the
	# founder starts it; any other hold is an error.
	while GameState.run_active and not _stopped:
		if SprintSystem.awaits_plan():
			if _full_run:
				_plan_the_sprint()
			else:
				_start_on_lead()
			if SprintSystem.awaits_plan():
				print("PROBE ERROR day=%d plan unstartable" % GameState.day)
				break
		if TimeManager.is_clock_held():
			print("PROBE ERROR day=%d the clock is held" % GameState.day)
			break
		if TimeManager.is_night() or GameState.current_hour == TimeModel.HOURS_PER_DAY - 1:
			TimeManager.skip_night()
			# An emergency stops the night at its hour and waits for the founder's answer.
			if EventGate.active_id() != "":
				_answer()
		else:
			TimeManager.advance_hours(1)
			_answer()
			_play_the_hour()
	_finish()


## 08:00, the week opens (night_skipped, both modes): the founder plays the week, the week's
## ledger lines print, and the run stops on its last week.
static func _on_week_start() -> void:
	_count_support_report()
	_play_the_week()
	_log_state()
	_log_customers()
	_log_uflux()
	_log_b2c()
	_log_server()
	_log_bugs()
	_log_areas()
	if (GameState.day - 1) % MARKET_LOG_WEEKS == 0:
		_log_market()
	if GameState.day >= _stop_day or not GameState.run_active:
		_stopped = true
		if _mode != "sim":
			_finish()
			Engine.get_main_loop().quit()


## Answer every card on screen and the fund's call, then play the VC meeting that seated: in the
## game its panel holds the clock from the hour it opens.
static func _answer() -> void:
	_drain_modals()
	var caller: String = VCPitchSystem.call_waiting()
	if caller != "":
		VCPitchSystem.begin_meeting(caller)
	if VCPitchSystem.is_active():
		_play_the_hunt()


# ============================================================================
#  Drive mode: real clock
# ============================================================================

static func _run_realtime(speed_idx: int) -> void:
	if speed_idx <= 0 or speed_idx >= TimeModel.SECONDS_PER_HOUR.size():
		print("PROBE ERROR bad speed index %d" % speed_idx)
		Engine.get_main_loop().quit()
		return
	# A night emergency holds the clock until it is answered, which stops the hour boundary this mode answers at.
	IncidentSystem.rolls = false
	# Nothing pauses the clock in probe mode (main.gd's modal pause is shell wiring that
	# is not mounted), so the drain has to ride the hour boundary or a stuck active event
	# would silently block every later fire while the weeks kept rolling past it. The desk rides
	# it too, outside a batch: the night's and a meeting's hours are not the player's, and
	# night_skipped opens the week (_on_week_start).
	EventBus.hour_changed.connect(func(_h: int) -> void:
		_drain_modals()
		if not TimeManager.is_batching():
			_play_the_hour()
	)
	# A run that ends inside the night batch never reaches night_skipped: the ending closes it.
	EventBus.run_ended.connect(func(_id: String, _data: Dictionary) -> void:
		_finish()
		Engine.get_main_loop().quit(), CONNECT_ONE_SHOT)
	EventBus.speed_change_requested.emit(speed_idx)


static func _log_weeks() -> void:
	# Verdict lines, one tick each: card fires, the founder's sittings and the B2B signings.
	for w in range(1, GameState.day + 1):
		print("PROBE WEEK w=%d fires=%d meetings=%d signs=%d" % [w, int(_fires_by_day.get(w, 0)),
			int(_meetings_by_day.get(w, 0)), int(_signs_by_day.get(w, 0))])


static func _finish() -> void:
	if _vc_policy != "" and not _vc_done:
		_vc_end("UNRESOLVED", "phase<3" if GameState.phase < 3 else "run_over")
	_log_weeks()
	_log_tally()
	var runway: Array = [1, 2, 3].map(func(ph: int) -> String:
		var w: Vector2i = _runway_weeks.get(ph, Vector2i.ZERO)
		return "finite_runway_p%d=%d/%d" % [ph, w.x, w.y])
	print("PROBE END day=%d run_active=%s ending=%s %s min_cash_pre_seed=%d seed_day=%d first_sign_day=%d first_revenue_day=%d cheque_day=%d open_w1_12=%d idle_w1_12=%d u_unexplained_weeks=%d server_clicks=%d auto_grows=%d outage_eko=%d outage_std=%d outage_kur=%d clause_ended=%d first_hire_week=%d first_hire_runway=%s move_weeks=%s support_reports=%d/%d support_news=%s" % [
		GameState.day, str(GameState.run_active), GameState.ending_id, " ".join(runway), _min_cash_pre_seed,
		GameState.seed_closed_day, _first_sign_day, _first_revenue_day,
		int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, -1)), _open_weeks.size(),
		_open_weeks.filter(func(w: int) -> bool: return not _meetings_by_day.has(w)).size(), _u_unexplained_weeks,
		_server_clicks, _auto_grows, int(_outages.get(InfraSystem.PROVIDER_LOCAL, 0)),
		int(_outages.get(InfraSystem.PROVIDER_CLOUD, 0)), int(_outages.get(InfraSystem.PROVIDER_ENTERPRISE, 0)), _clause_ended,
		_first_hire_day, "%.1f" % _first_hire_runway if _first_hire_day >= 0 else "-",
		",".join(_move_days.map(func(d: int) -> String: return str(d))) if not _move_days.is_empty() else "-",
		_support_reports, _support_weeks, ",".join(SUPPORT_NEWS.values().map(func(kind: String) -> String:
			return "%s:%d" % [kind, int(_support_news.get(kind, 0))]))])
	_log_hr()


## PROBE HR — üç sayı: kaç işe alım, aylık maaş yükü, kaç kişi §7'nin 50 bandının altında.
## Sıfır işe alım bir hata değil bulgudur: probe'un işe alım yolu (`_hire_the_team`)
## kapılıdır ve koşu İK'yı hiç egzersiz etmeyebilir.
static func _log_hr() -> void:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	# `average_morale()` kimse yokken 0.0 döner ve "moral çöktü" diye okunurdu; kadro boşken
	# tire yazılır.
	var avg: String = "-"
	var below: int = 0
	var lowest: int = -1
	if not staff.is_empty():
		avg = "%.1f" % HRMoraleSystem.average_morale()
		lowest = HRConstants.MORALE_MAX
		for emp in staff:
			if emp.morale < HRConstants.MORALE_BAND_LOW:
				below += 1
			lowest = mini(lowest, emp.morale)
	print("PROBE HR hires=%d emp=%d payroll=%d morale_avg=%s below%d=%d min=%s" % [
		GameState.run_hires, staff.size(), payroll, avg,
		HRConstants.MORALE_BAND_LOW, below,
		"-" if lowest < 0 else str(lowest)])


# ============================================================================
#  The founder's own moves (the played run; inert for the fire-log presets)
# ============================================================================

## The week's 08:00: the night's cards are answered, the desk looked at, the sprint planned,
## the seed round taken once its door opens, then the sales meetings sat back to back and the
## Series A hunt played. Every move goes through the seam the corresponding tab button calls —
## the probe has no privileged path into the engine. Before any move, an open B2B market in the
## first twelve weeks is noted for PROBE END.
static func _play_the_week() -> void:
	if GameState.day <= 12 and SalesFaucetSystem.market_open():
		_open_weeks.append(GameState.day)
	_answer()
	_play_the_hour()
	if not _full_run:
		return
	_plan_the_sprint()
	_take_the_seed()
	_move_the_company()
	if GameState.get_flag("mvp_shipped", false):
		_run_the_servers()
		_answer_the_clause()
		_work_the_pipeline()
	if _vc_policy != "":
		_play_the_hunt()


## Every visible hour: the desk decisions a player takes whenever a gate opens — a hire,
## research, the roster.
static func _play_the_hour() -> void:
	if not GameState.run_active or TimeManager.is_night():
		return
	if _full_run:
		_hire_the_team()
		_run_the_company()
	elif PRESETS[_preset].has("staff"):
		_pin_the_morale()


## The Product tab at the week's 08:00. Sprints close in the night's daily tick, so the morning
## finds either a running sprint or the release note: at the MVP gate the founder ships, then the
## note is read, the next sprint planned on the lead's suggestion alone (promised steps and the paid plan
## are its first steps) and started; the arms below edit it. A decision paper waiting on a card was already
## answered off the desk (_drain_modals).
static func _plan_the_sprint() -> void:
	if not SprintSystem.is_typed():
		SprintSystem.choose_type(_subtype, PRODUCT_NAMES[_subtype])
		print("PROBE PLAY day=%d choose_type %s market=%s" % [GameState.day, _subtype, ProductState.market_type()])
	if GameState.product.release.get("gate", false):
		print("PROBE PLAY day=%d publish" % GameState.day)
		SprintSystem.publish()
	if SprintSystem.mode() == "release":
		SprintSystem.plan_next()
	if SprintSystem.mode() != "plan":
		return
	SprintSystem.apply_lead()
	_plan_actions = 1
	if _fix_arm != "":
		_plan_fix_arm()
	if _k1_only:
		for id in GameState.product.sprint.cards.duplicate():
			if not _plannable(GameState.product.cards[id]):
				SprintSystem.remove(id)
				_plan_actions += 1
	# With no K1 step or fix left to plan, a research sprint; a plan that still cannot start is _run_sim's error.
	if _k1_only and not SprintSystem.can_start():
		for area in SprintCatalog.areas_for(ProductState.subtype(), ProductState.market_type()):
			var research: Array = SprintCatalog.candidates(area.id).filter(func(c: Dictionary) -> bool: return c.kind == "research")
			if not research.is_empty():
				SprintSystem.add(research[0].id)
				_plan_actions += 1
				break
	_plan_actions += 1
	if SprintSystem.start():
		print("PROBE PLAY day=%d sprint %d start cards=%s used=%.2f capacity=%.2f actions=%d" % [GameState.day,
			SprintSystem.sprint_number(), ",".join(GameState.product.sprint.cards), SprintSystem.used(),
			SprintSystem.capacity(), _plan_actions])


## The fix arms on top of the lead's plan: every fix card out, the arm's cards in first (past the capacity ceiling
## when `add` refuses them), then the lead fills what is left. The fix cards the arm does not take wait in the next
## column meanwhile, where the lead never suggests them; so do the cards outside the core when the arm is core-only.
static func _plan_fix_arm() -> void:
	var p: Dictionary = GameState.product
	for id in p.sprint.cards.duplicate():
		if p.cards[id].kind == "fix" or _outside_core(p.cards[id]):
			SprintSystem.remove(id)
			_plan_actions += 1
	var bugs: Dictionary = ProductState.open_bugs_by_line()
	var due: Array = bugs.keys()
	due.sort_custom(func(a: String, b: String) -> bool: return bugs[a] > bugs[b] if bugs[a] != bugs[b] else a < b)
	if _fix_arm == "due":
		var due_at: float = DUE_BUGS * SprintCatalog.limit_k()
		due = due.filter(func(line: String) -> bool: return bugs[line] >= due_at and (
			ProductState.market_type() != "b2b" or not SprintCatalog.line_accounts(line).is_empty()))
	else:
		due = due.slice(0, 0 if _fix_arm == "none" else 1)
	for line in due:
		SprintSystem.add("fix:" + line)
		_plan_actions += 1
		if not p.sprint.cards.has("fix:" + line):
			SprintSystem._place(SprintCatalog.card_by_id("fix:" + line), true)
	var parked: Array = bugs.keys().filter(func(line: String) -> bool: return not due.has(line)).map(
		func(line: String) -> String: return "fix:" + line)
	parked.append_array(SprintCatalog.open_cards([]).filter(_outside_core).map(
		func(c: Dictionary) -> String: return c.id))
	for id in parked:
		SprintSystem.send_next(id)
	SprintSystem.apply_lead()
	for id in parked:
		SprintSystem.remove(id)
	_plan_actions += 1


## A feature or request card of another area than the core, which the core-only arm never plans. Fix and research
## cards are the arm's too, whatever their area.
static func _outside_core(c: Dictionary) -> bool:
	return _core_only and c.area != "core" and (c.kind == "feature" or c.kind == "request")


## A sprint waiting on its plan starts on the lead's plan the morning its note opens, as the Product page
## starts it: at the MVP gate the founder ships first, then the next sprint is planned. The presets that
## seed a product and --tick-probe play it so; the sprint that cannot start is the caller's error.
static func _start_on_lead() -> void:
	SprintSystem.publish()
	SprintSystem.plan_next()
	SprintSystem.apply_lead()
	SprintSystem.start()


## The K1-only founder plans no step past K1: fixes, research and the paid plan stay open.
static func _plannable(c: Dictionary) -> bool:
	return not _k1_only or int(c.target_tier) <= 1


static func _work_the_pipeline() -> void:
	# The founder's sales week (Satış §3, §5.0): leads arrive on their own and the throttle is
	# the entry gate (the hour budget and the week's cap), asked through the same seam the tab
	# asks, so the probe gets no faster a pipeline than a player at the same keyboard. Each
	# sitting's close runs its hours, so the loop meets until the gate shuts, back at the desk
	# between sittings.
	if SalesMeetingSystem.is_active() or NegotiationSystem.is_active():
		return
	for i in SalesConstants.MEETINGS_PER_WEEK + 1:
		# The first lead the founder is allowed to sit with, not only the head of the queue: a
		# blocked returning company at leads[0] would idle the meeting. The desk arm leaves the reps' band to them.
		var reps_band: int = _desk_ceiling() if _desk else 0
		var table: Prospect = null
		for raw in ProspectRegistry.get_all():
			var lead: Prospect = raw as Prospect
			if lead != null and lead.star > reps_band and SalesLedger.meeting_block_reason(lead.id) == "":
				table = lead
				break
		if table == null or not GameState.run_active:
			return
		_meet(table)
		_answer()
		_play_the_hour()


## The highest star a rep on the Satış job works (the game hands them every lead up to it); 0 with nobody there.
static func _desk_ceiling() -> int:
	var best: int = 0
	for rep in HRSystem.assigned_to(HRConstants.AREA_SALES):
		best = maxi(best, SalesRepSystem.band_ceiling(rep))
	return best


static func _meet(p: Prospect) -> void:
	# One sitting, played straight: always the FIRST OPEN answer at every probe, then the
	# stance anchor at the table. That is a DELIBERATELY UNSKILLED line — it takes whatever
	# is on top rather than the highest-EV route — so the run's revenue curve is a floor on
	# what a player can do here, never a ceiling flattered by optimal play.
	var mrr_before: int = GameState.mrr
	var vs: Dictionary = SalesMeetingSystem.open(p.id)
	if vs.is_empty():
		return
	for i in SalesConstants.SAFETY_CAP_PROBES + 2:
		if String(vs.get("outcome", "")) != "":
			break
		var answers: Array = vs.get("answers", []) as Array
		var picked: String = ""
		for a in answers:
			if bool((a as Dictionary).get("open", false)):
				picked = String((a as Dictionary).get("id", ""))
				break
		if picked == "":
			vs = SalesMeetingSystem.skip_to_offer()
			break
		vs = SalesMeetingSystem.choose(picked)
	var outcome: String = String(vs.get("outcome", "lost"))
	if outcome == "won":
		# §5.3 — Perde 2, sessiz. The probe offers at the stance anchor and takes whatever
		# the customer counters with; a walk would be the skilled move and this line is not.
		NegotiationSystem.open(NegotiationSystem.TYPE_B2B, {
			"account": p.company_name, "lead_id": p.id, "star": p.star,
			"archetype": p.archetype_id, "promised": SalesMeetingSystem.promised_feature(),
			"is_whale": p.is_whale,
		})
		for j in SalesConstants.PATIENCE_MAX + 1:
			var nvs: Dictionary = NegotiationSystem.offer()
			if String(nvs.get("state", "")) == "accepted":
				break
			if String(nvs.get("state", "")) == "closed":
				break
			if int(nvs.get("counter", -1)) >= 0:
				NegotiationSystem.accept_counter()
				break
		SalesFinalizer.apply(NegotiationSystem.result())
	SalesMeetingSystem.close()
	# A won table carries the deal's planned length (PROBE SIGN's weeks).
	print("PROBE PLAY day=%d meeting %s -> %s (mrr %d -> %d)%s" % [GameState.day, p.company_name, outcome,
		mrr_before, GameState.mrr, " weeks=%.1f" % (p.deal_halfweeks / 2.0) if outcome == "won" else ""])


## The B2B run's staffing ladder: a founder who is growing
## hires the desk the growth needs — a developer on Frank's money, a support rep once a
## few accounts are live, sales reps as MRR climbs. Each rung only when the payroll it
## adds leaves six months of runway.
const STAFF_LADDER := [
	{"role": "developer", "min_customers": 0, "min_mrr": 0},
	{"role": "customer_rep", "min_customers": 3, "min_mrr": 0},
	# QA early: the test lines' K2/K3 gate on QA stars, and B2B satisfaction drifts
	# toward the product's fit. A run without a tester cannot hold its accounts.
	{"role": "tester", "min_customers": 0, "min_mrr": 3000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 4000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 12000},
	{"role": "developer", "min_customers": 0, "min_mrr": 15000},
	{"role": "customer_rep", "min_customers": 12, "min_mrr": 0},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 30000},
	{"role": "product_manager", "min_customers": 0, "min_mrr": 30000},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 50000},
	{"role": "developer", "min_customers": 0, "min_mrr": 60000},
	{"role": "customer_rep", "min_customers": 25, "min_mrr": 0},
	{"role": "sales_rep", "min_customers": 0, "min_mrr": 80000},
]
## The consumer run's ladder: no sales desk to staff, so the rungs follow MRR alone, and beside
## them the support reps the desk needs.
const B2C_LADDER := [
	{"role": "developer", "min_mrr": 0},
	{"role": "designer", "min_mrr": 8000},
	{"role": "tester", "min_mrr": 15000},
	{"role": "developer", "min_mrr": 25000},
	{"role": "product_manager", "min_mrr": 40000},
]
## Past STAFF_LADDER (the presets with a staff_cap above its thirteen rungs) the B2B run hires the mix of a larger
## company, developers half, in turn, each head when the MRR is GROWTH_MRR_PER_HEAD for every head it will then count.
const GROWTH_ROLES := ["developer", "developer", "tester", "designer", "developer", "product_manager", "developer", "tester",
	"designer", "developer"]
const GROWTH_MRR_PER_HEAD := 6200   # [WORKING] the last STAFF_LADDER rung asks 80,000 for the 13th head


## The B2B rung that hires the next head of `heads` employees: STAFF_LADDER, then the growth rungs.
static func _rung(heads: int) -> Dictionary:
	if heads < STAFF_LADDER.size():
		return STAFF_LADDER[heads]
	return {"role": GROWTH_ROLES[(heads - STAFF_LADDER.size()) % GROWTH_ROLES.size()], "min_customers": 0,
		"min_mrr": GROWTH_MRR_PER_HEAD * (heads + 1)}


## The role the ladder hires next, or "" while it waits. B2B climbs the rungs (_rung) by headcount up
## to the preset's cap. B2C first hires a support rep whenever someone pays, reports are waiting
## and the desk validates fewer a day than arrive: the release-to-release swing in the inflow
## alone does not hire while the desk keeps the queue empty, and a rep away on leave or in
## training is waited for, not replaced. Then the first B2C_LADDER rung whose role the staff is
## short of.
static func _next_role() -> String:
	var staff: Array[Character] = CharacterRegistry.get_employees()
	if SalesSystem.is_b2b_market():
		if staff.size() >= _staff_cap:
			return ""
		var want: Dictionary = _rung(staff.size())
		if CustomerRegistry.account_count() < int(want.min_customers) or GameState.mrr < int(want.min_mrr):
			return ""
		return String(want.role)
	var reps: Array = staff.filter(func(c: Character) -> bool: return c.role == HRConstants.ROLE_CUSTOMER_REP)
	if SalesSystem.b2c_paying_users() > 0 and ProductState.reports_incoming() > 0 \
			and reps.all(func(c: Character) -> bool: return c.status == HRConstants.STATUS_ACTIVE) \
			and SupportSystem.validation_per_day() < SupportSystem.reports_per_day():
		return HRConstants.ROLE_CUSTOMER_REP
	# The first rung whose role is short of what the ladder wants up to it: a departure is refilled
	# with the role that left, not with whatever rung the smaller headcount points at.
	var spare: Dictionary = {}
	for c in staff:
		spare[c.role] = int(spare.get(c.role, 0)) + 1
	for want in B2C_LADDER:
		spare[want.role] = int(spare.get(want.role, 0)) - 1
		if int(spare[want.role]) < 0:
			return String(want.role) if GameState.mrr >= int(want.min_mrr) else ""
	return ""


## The hires, driven through HRSearchSystem exactly as the HR tab does it: start a search, wait for the files to
## arrive, hire the first one. A person is hired when the cash covers six months of the costs they leave (the first
## one by the preset's cash arm); an office with no free desk starts no search and hires nobody off the files already on
## the table, so its hires wait for a bigger office.
static func _hire_the_team() -> void:
	if OfficeSystem.hiring_closed():
		if not _desks_full and (HRSearchSystem.has_files_ready() or _next_role() != ""):
			_desks_full = true
			_decide("hire", "desks_full")
		return
	_desks_full = false
	if HRSearchSystem.has_files_ready():
		var preview: Dictionary = HRSearchSystem.preview_hire(0)
		var hired: Character = HRSearchSystem.hire(0)
		if hired != null:
			_hire_started = false
			if _first_hire_day < 0:
				_first_hire_day = GameState.day
				_first_hire_runway = float(GameState.cash) / float(int(preview.burn_after) * TimeModel.DAYS_PER_MONTH)
			print("PROBE PLAY day=%d hire %s salary=%d burn=%d" % [
				GameState.day, hired.role, hired.monthly_salary, GameState.daily_burn])
		return
	if _hire_started or not HRSearchSystem.can_start():
		return
	var role: String = _next_role()
	if role == "":
		return
	# The month's costs with the hire in, the hire at the ceiling of the Junior band (what the first file asks at most).
	var cost: int = GameState.daily_burn * TimeModel.DAYS_PER_MONTH \
		+ int(HRConstants.salary_band_for_level(role, HRConstants.LEVEL_JUNIOR)[1])
	if CharacterRegistry.get_employees().is_empty():
		# The first hire waits for the cash alone, revenue left out: nothing has been earned yet.
		if GameState.cash < cost * float(FIRST_HIRE_MONTHS.get(_cash_arm, HIRE_MONTHS)):
			return
	elif cost > GameState.mrr and GameState.cash < (cost - GameState.mrr) * HIRE_MONTHS:
		return
	if HRSearchSystem.start_search(role, HRConstants.LEVEL_JUNIOR):
		_hire_started = true
		print("PROBE PLAY day=%d start_search %s/junior" % [GameState.day, role])
		_decide("hire", role)


## The office, as the map's card lets a player decide it at the week's open: from the seed round on, the company goes up
## a step when the cash covers the up-front rent and the arm's MOVE_MONTHS of today's costs (the flat, whose team has no
## desk to outgrow, as soon as the seed is in; an office once its desks are full). The "hoard" arm never moves.
static func _move_the_company() -> void:
	var next: String = NEXT_OFFICE.get(OfficeSystem.current(), "")
	if next == "" or _cash_arm == "hoard" or GameState.run_seed_amount <= 0:
		return
	if OfficeSystem.current() != "home" and not OfficeSystem.hiring_closed():
		return
	var months: float = MOVE_MONTHS.get(_cash_arm, MOVE_MONTHS[""])
	if GameState.cash < OfficeSystem.upfront(next) + months * GameState.daily_burn * TimeModel.DAYS_PER_MONTH:
		return
	if OfficeSystem.move_to(next):
		_move_days.append(GameState.day)
		_decide("move", next)
		print("PROBE PLAY day=%d move %s cash=%d burn=%d" % [GameState.day, next, GameState.cash, GameState.daily_burn])


## A decision at a surface of the game, for PROBE DECISION.
static func _decide(surface: String, target: String) -> void:
	print("PROBE DECISION week=%d surface=%s target=%s" % [GameState.day, surface, target])


## The servers, as the Sunucu block lets a player run them, at the week's open: the default founder presses Increase while
## the load is over the amber line, "lean" and "wide" hold it near their own line (Decrease too, while a step would still
## leave the load under it), "auto" switches Auto adjust on once and never presses. A press is a click, counted for PROBE END.
static func _run_the_servers() -> void:
	if _server_policy == "auto":
		if not ProductState.infra_auto():
			ProductState.set_infra_auto(true)
			_decide("capacity", "auto")
		return
	var line: int = int(SERVER_LINES.get(_server_policy, InfraSystem.LOAD_AMBER))
	var presses: int = 0
	while InfraSystem.load_percent() > line and presses < SERVER_PRESSES:
		InfraSystem.adjust_capacity(1)
		presses += 1
	while _server_policy != "" and InfraSystem.units() > 1 and presses < SERVER_PRESSES \
			and InfraSystem.load_percent(InfraSystem.units() - InfraSystem.capacity_step()) <= line:
		InfraSystem.adjust_capacity(-1)
		presses += 1
	_server_clicks += presses
	if presses > 0:
		_decide("capacity", str(InfraSystem.units()))


## The server clause, as a player reads the Sunucu block's row: the move to Enterprise once the MRR of the accounts waiting on
## it outgrows what Enterprise adds to the bill.
static func _answer_the_clause() -> void:
	if InfraSystem.provider() == InfraSystem.PROVIDER_ENTERPRISE:
		return
	var waiting: int = 0
	for c: Customer in CustomerRegistry.get_by_market("b2b"):
		if c.clause_due_day >= 0:
			waiting += c.mrr
	if waiting > InfraSystem.monthly_bill(InfraSystem.PROVIDER_ENTERPRISE) - InfraSystem.monthly_bill():
		InfraSystem.set_provider(InfraSystem.PROVIDER_ENTERPRISE)
		_decide("tier", InfraSystem.PROVIDER_ENTERPRISE)


## The played run's operations — the things any player does once the product is live: research,
## look after the roster. The price follows the releases on its own.
static func _run_the_company() -> void:
	if not ProductState.is_live():
		return
	# Once anyone pays for the consumer product the founder takes the support desk (§8.2) next to
	# his build job: the two jobs split his focus, so the sprint counts him at half a share and the
	# desk gets half his customer_success for validation (0 in the debug payload, so the first rep
	# is still needed).
	var founder: Character = CharacterRegistry.get_founder()
	if ProductState.market_type() == "b2c" and SalesSystem.b2c_paying_users() > 0 \
			and not founder.assigned_job_ids.has(HRConstants.JOB_SUPPORT):
		if CharacterRegistry.assign_job(founder.id, HRConstants.JOB_SUPPORT) == "":
			print("PROBE PLAY day=%d founder takes the support desk" % GameState.day)
	_run_research()
	_keep_the_team()


## A player watching the roster does something before a person walks: a raise first, the
## year's holiday if a raise is not on the table. Nothing fancier: without it the run
## measures a founder who never looks at morale.
static func _keep_the_team() -> void:
	for emp in CharacterRegistry.get_employees():
		if emp.category != "employee" or emp.status != HRConstants.STATUS_ACTIVE:
			continue
		if emp.morale >= 40:
			continue
		if HRActions.can_raise(emp, 10) and HRActions.apply_raise(emp, 10):
			print("PROBE PLAY day=%d raise %s morale=%d" % [GameState.day, emp.role, emp.morale])
		elif emp.leave_taken_year != int(GameState.get_date_dict().year):
			HRMoraleSystem.send_on_leave(emp, HRConstants.LEAVE_WEEKS, true)
			print("PROBE PLAY day=%d holiday %s morale=%d" % [GameState.day, emp.role, emp.morale])


## Research the next gated step needs (or any open node): a player who wants K2/K3 does
## Ar-Ge. Never the founder, whose seat is the build and the sales desk.
static func _run_research() -> void:
	if not RnDSystem.tree_open() or RnDSystem.active() != "":
		return
	var wanted: Array = []
	for tier in range(1, ProductLines.TIER_MAX + 1):
		for raw_line in ProductLines.line_ids(ProductState.subtype()):
			var line_id: String = String(raw_line)
			if ProductState.line_tier(line_id) + 1 != tier:
				continue
			var st: Dictionary = ProductLines.step_at(line_id, tier)
			var node: String = String((st.get("requires", {}) as Dictionary).get("research", ""))
			if node != "" and not RnDSystem.node_completed(node) and not wanted.has(node):
				wanted.append(node)
	for id in ResearchSeam.NODES.keys():
		if not wanted.has(String(id)):
			wanted.append(String(id))
	var founder_id: String = CharacterRegistry.get_founder().id
	# Research takes the whole person (Ar-Ge §5.0). Keep one developer on the sprint: a company
	# with a single developer does not research, it ships.
	var devs: int = 0
	for e in CharacterRegistry.get_employees():
		if e.role == HRConstants.ROLE_DEVELOPER:
			devs += 1
	for node in wanted:
		if not RnDSystem.available(String(node)):
			continue
		for c in RnDSystem.eligible_assignees(String(node)):
			if c.id == founder_id:
				continue
			if c.role == HRConstants.ROLE_DEVELOPER and devs < 2:
				continue
			if RnDSystem.start(String(node), [c.id]) == "":
				print("PROBE PLAY day=%d research %s by %s" % [GameState.day, node, c.role])
				return


# ============================================================================
#  The seed round (every played run)
# ============================================================================
#
# The seed door opens in Traction at its MRR bar and closes on entering phase 3; the run gets
# one pitch, and the seed room cannot say no (ch. 09 §3). Every played run takes it the week the
# door opens: the first fund in the registry's order that takes the pitch, the meeting played by
# the Series A rule (_meeting_pick), then the offer signed at the table by the preset's Series A
# table policy. naive pushes random levers until the final counter; cautious, and the runs with
# no Series A policy, sign the opening terms; walk signs them too, because the seed table has no
# walk (TermSheetTableSystem.walk refuses it at seed).

## The funds the founder tries, in the registry's order; the product policy tries the product fund first.
static func _funds() -> Array:
	var funds: Array = InvestorRegistry.get_active()
	if _vc_policy == "product":
		funds = funds.filter(func(f: Dictionary) -> bool: return f.domain == "product") \
			+ funds.filter(func(f: Dictionary) -> bool: return f.domain != "product")
	return funds.map(func(f: Dictionary) -> String: return String(f.id))


static func _take_the_seed() -> void:
	if GameState.seed_sheet == null and SeedRoundSystem.door_open() \
			and WorkHoursSystem.sitting_open(TimeModel.SITTING_HOURS["vc"]):
		for fund in _funds():
			if SeedRoundSystem.begin_pitch(fund):
				var path: String = _sit_the_meeting()
				print("PROBE PLAY day=%d seed meeting fund=%s path=%s" % [GameState.day, fund, path])
				break
	var sheet: TermSheet = GameState.seed_sheet
	if sheet == null or not WorkHoursSystem.sitting_open(TimeModel.SITTING_HOURS["table"]):
		return
	TermSheetTableSystem.open(sheet.vc_id, PitchConstants.STAGE_SEED)
	var pushes: int = 0
	if _vc_policy == "naive":
		pushes = int(_push_until_done("probe_seed_lever", sheet.vc_id, sheet.vc_id, false).pushes)
	TermSheetTableSystem.sign()           # → SeedRoundSystem.accept: the money in, the run goes on
	TermSheetTableSystem.end_sitting()
	print("PROBE PLAY day=%d seed signed fund=%s band=%s pushes=%d raise=%d equity=%d cash=%d" % [
		GameState.day, sheet.vc_id, sheet.band, pushes, GameState.run_seed_amount,
		GameState.run_seed_equity_pct, GameState.cash])


# ============================================================================
#  The Series A hunt (the presets with a Series A policy)
# ============================================================================
#
# What share of term-sheet tables end in a signature, a final offer or the fund walking
# out when a naive founder plays them? The bot never met a VC, so
# these policies are the working definitions the owner wrote:
#   naive    — once the door is open, book the first fund that will meet; at the table push
#              a random lever until patience runs out; sign a final offer.
#   cautious — the same meeting; sign the opening terms without a single push (the baseline).
#   walk     — the same meeting; walk the first table through its own walk (VCPitchSystem.
#              walk_table): the Series A decision faced and refused, the bootstrap road.
#   product  — cautious, but the product fund is tried first at the seed and at Series A, so
#              the area it names (PROBE VCQ dim) can be counted; its run parts from the others
#              at the seed round.
# The meeting is played identically by all, so the runs are the same run up to the
# table. The lever draw comes from a probe-local generator seeded per table with an EvDice
# hash of seed/day/ids — never a stream the game draws from — and nothing acts before
# phase 3: until the door opens a VC preset is the same run without the policy, except naive,
# whose seed table is pushed (see "The seed round").

static func _play_the_hunt() -> void:
	if _vc_done or not GameState.run_active or GameState.phase < 3 or TermSheetTableSystem.is_active():
		return
	# 1. The founder answered the fund's call, which seated the meeting. Play it.
	if VCPitchSystem.is_active():
		_play_the_meeting()
		_vc_meet_day = GameState.day
	# 2. A live Series A sheet: sit down the week it arrives (so the decision card never comes).
	if not GameState.active_sheets.is_empty():
		var ts: TermSheet = GameState.active_sheets[0] as TermSheet
		_play_the_table(String(ts.vc_id))
		return
	# 3. Waiting on a booked meeting or a queued sheet.
	if not GameState.pending_meeting.is_empty() or EndingsSystem._any_pending_sheet():
		var pm_day: int = int(GameState.pending_meeting.get("day", -1))
		if not GameState.pending_meeting.is_empty() and pm_day >= 0 and pm_day < GameState.day - 1:
			print("PROBE ERROR day=%d booked meeting (day %d) never started" % [GameState.day, pm_day])
		return
	if _vc_meet_day == GameState.day:
		return                          # a refusal this week: the next fund is booked next week
	# 4. Book the first fund that will meet, in _funds' order.
	for vc in _funds():
		var st: Dictionary = GameState.vc_states.get(vc, {}) as Dictionary
		if String(st.get("status", "open")) == "callback":
			continue
		if VCPitchSystem.meeting_blocked_reason(vc) != "":
			continue
		if VCPitchSystem.request_meeting(vc):
			_vc_booked = vc
			print("PROBE VC_BOOK day=%d fund=%s meet_day=%d meetings=%d rejections=%d mrr=%d brand=%d" % [
				GameState.day, vc, int(GameState.pending_meeting.get("day", 0)),
				int((GameState.vc_states.get(vc, {}) as Dictionary).get("meeting_count", 0)),
				GameState.vc_rejections, GameState.mrr, GameState.brand])
			return
	# Nothing left to book: no table this run. The replays still sample the four funds.
	if _vc_policy == "naive" and _replay_k > 0:
		_run_replays()
	_vc_end("NO_TABLE", "road_closed" if VCPitchSystem.series_a_road_closed() else "none_bookable")


static func _choice_ids(vs: Dictionary) -> Array[String]:
	var out: Array[String] = []
	for c in (vs.get("choices", []) as Array):
		out.append(String((c as Dictionary).get("id", "")))
	return out


## The meeting rule, the same for both policies: read the room; take the angle with the best
## odds the room shows (then the easier one, then list order); answer the question honestly;
## at a lukewarm fork, press for the sheet.
static func _meeting_pick(ids: Array[String]) -> String:
	var best: String = ""
	var best_c: float = -1.0
	var best_d: int = 99
	for id in ids:
		if not id.begins_with("b2_"):
			continue
		var a: String = id.trim_prefix("b2_")
		var d: int = VCPitchSystem._angle_diff(a)
		var c: float = SkillCheck.chance_for(VCPitchSystem._angle_skill(a), d)
		if c > best_c or (c == best_c and d < best_d):
			best = id
			best_c = c
			best_d = d
	if best != "":
		return best
	for want in ["b1_read", "b3_durust", "b4_zorla"]:
		if ids.has(want):
			return String(want)
	return ids[0]


static func _play_the_meeting() -> void:
	var fund: String = VCPitchSystem._vc_id
	if fund != _vc_booked:
		print("PROBE ERROR day=%d meeting fund %s is not the booked %s" % [GameState.day, fund, _vc_booked])
	var conv0: int = VCPitchSystem._conviction
	var path: String = _sit_the_meeting()
	var st: Dictionary = GameState.vc_states.get(fund, {}) as Dictionary
	print("PROBE VC_MEET day=%d fund=%s n=%d conv0=%d path=%s result=%s sheet_conv=%d rejections=%d brand=%d" % [
		GameState.day, fund, int(st.get("meeting_count", 0)), conv0, path,
		String(st.get("status", "?")), int(st.get("sheet_conviction", -1)), GameState.vc_rejections, GameState.brand])


## The seated meeting, Series A or seed, played to its end by _meeting_pick and its hours run.
## Returns the path: "<pick>:<conviction before>><after>" per beat.
static func _sit_the_meeting() -> String:
	var trace: Array[String] = []
	var ids: Array[String] = ["b1_read"]   # Beat 1 has one row, and its resolver ignores the id
	var guard: int = 0
	while VCPitchSystem.is_active() and guard < 8:
		guard += 1
		var pick: String = _meeting_pick(ids)
		var before: int = VCPitchSystem._conviction
		var res: Dictionary = VCPitchSystem.advance(pick)
		if pick.begins_with("b2_"):
			_log_vcq()
		if bool(res.get("done", false)):
			trace.append("%s:%d>end" % [pick, before])
			break
		trace.append("%s:%d>%d" % [pick, before, VCPitchSystem._conviction])
		ids = _choice_ids(res.get("view_state", {}) as Dictionary)
		if ids.is_empty():
			print("PROBE ERROR day=%d meeting view has no choices after %s" % [GameState.day, pick])
			break
	if VCPitchSystem.is_active():
		print("PROBE ERROR day=%d meeting did not finish" % GameState.day)
	VCPitchSystem.end_sitting()     # the sitting's hours run once the panel is gone
	return ",".join(trace)


## PROBE VCQ — the Beat-3 question the angle pick just put up, the key read from the meeting itself. Only the
## product fund's question turns on an area (_sorgu_product, seed how_big), so the weakest area is read for it
## alone and is "-" when it asked its clean question.
static func _log_vcq() -> void:
	var product_fund: bool = InvestorRegistry.get_investor(VCPitchSystem._vc_id).get("domain", "") == "product"
	var weak: String = ProductQuality.weakest_area() if product_fund else ""
	print("PROBE VCQ day=%d investor=%s key=%s dim=%s" % [
		GameState.day, VCPitchSystem._vc_id, VCPitchSystem._sorgu.get("key", "-"), weak if weak != "" else "-"])


static func _pushable_levers() -> Array[String]:
	var out: Array[String] = []
	for l in TermSheetTableSystem.levers():
		if TermSheetTableSystem.can_push(String(l)):
			out.append(String(l))
	return out


## Push random levers until patience is gone (final offer or walk-out) or nothing can move.
## A fresh lever is drawn on EVERY push from a probe-local generator seeded once per table
## (run seed, kind, day, key) — never a stream the game draws from. Not EvDice per push: its
## hash keeps the low bits, so keys that differ only in a trailing push index land on nearly
## the same number and every push would pick the same lever.
static func _push_until_done(kind: String, key: String, fund: String, log_each: bool) -> Dictionary:
	var pushes: int = 0
	var wins: int = 0
	var state: int = TermSheetTableSystem.IDLE
	var seq: Array[String] = []
	var pick := RandomNumberGenerator.new()
	pick.seed = EvDice.fnv1a("%d|%s|%d|%s" % [GameState.run_seed, kind, GameState.day, key])
	while pushes < TABLE_PUSH_CAP:
		var pl: Array[String] = _pushable_levers()
		if pl.is_empty():
			break
		var lever: String = pl[pick.randi_range(0, pl.size() - 1)]
		seq.append(lever.substr(0, 1))
		TermSheetTableSystem.select_lever(lever)
		var pv: Dictionary = TermSheetTableSystem.push()
		pushes += 1
		state = int(pv.get("state", 0))
		var ok: bool = state == TermSheetTableSystem.PUSH_SUCCESS
		if ok:
			wins += 1
		if log_each:
			print("PROBE VC_PUSH day=%d fund=%s n=%d lever=%s success=%s e=%d patience=%d band=%s state=%d" % [
				GameState.day, fund, pushes, lever, str(ok), TermSheetTableSystem.eagerness(),
				int((pv.get("patience", {}) as Dictionary).get("current", -1)), String(pv.get("eagerness_band", "")), state])
		if state == TermSheetTableSystem.PATIENCE_ZERO or state == TermSheetTableSystem.FUND_WALKED:
			break
	if pushes >= TABLE_PUSH_CAP:
		print("PROBE ERROR day=%d fund=%s push cap reached" % [GameState.day, fund])
	return {"pushes": pushes, "wins": wins, "state": state, "levers": "".join(seq)}


static func _play_the_table(vc: String) -> void:
	var sheet: TermSheet = VCPitchSystem.sheet_for(vc)
	if sheet == null:
		_vc_end("NO_TABLE", "no_sheet")
		return
	if _vc_policy == "naive" and _replay_k > 0:
		_run_replays()                  # the table is still closed: same company, same day
	var ov: Dictionary = TermSheetTableSystem.open(vc, PitchConstants.STAGE_SERIES_A)
	if ov.is_empty():
		_vc_end("NO_TABLE", "open_failed")
		return
	var e0: int = TermSheetTableSystem.eagerness()
	var fit: int = TermSheetTableSystem._domain_fit()
	var thr: int = TermSheetTableSystem.walk_threshold()
	var t0: Dictionary = TermSheetTableSystem._terms.duplicate()
	print("PROBE VC_TABLE_OPEN day=%d fund=%s conv=%d fit=%d e0=%d patience=%d thr=%d band=%s val_m=%d dil=%d board=%d veto=%s" % [
		GameState.day, vc, sheet.conviction, fit, e0, int((ov.get("patience", {}) as Dictionary).get("max", 0)), thr,
		String(ov.get("eagerness_band", "")), int(t0.get("valuation_m", 0)), int(t0.get("dilution_pct", 0)),
		int(t0.get("board_seats", 0)), str(bool(t0.get("board_veto", false)))])
	var r: Dictionary = {"pushes": 0, "wins": 0, "levers": ""}
	if _vc_policy == "naive":
		r = _push_until_done("probe_vc_lever", vc, vc, true)
	# Read BEFORE sign(): signing resets the table's state.
	var ev: Dictionary = TermSheetTableSystem.view_state()
	var walked: bool = bool(ev.get("fund_walked", false))
	var outcome: String = "SIGNED_NO_FINAL"
	if walked:
		outcome = "FUND_WALKED"
	elif _vc_policy == "walk":
		outcome = "FOUNDER_WALKED"
	elif int(ev.get("state", 0)) == TermSheetTableSystem.PATIENCE_ZERO:
		outcome = "SIGNED_FINAL"
	var t1: Dictionary = TermSheetTableSystem._terms.duplicate()
	# A walked table raised nothing: its working terms are printed, its money is not.
	var money: String = "-" if walked or _vc_policy == "walk" else str(TermSheetTableSystem.money_raised())
	print("PROBE VC_TABLE_END day=%d fund=%s policy=%s outcome=%s e0=%d e_end=%d thr=%d pushes=%d wins=%d levers=%s patience_left=%d val_m=%d dil=%d board=%d veto=%s money=%s rejections=%d" % [
		GameState.day, vc, _vc_policy, outcome, e0, TermSheetTableSystem.eagerness(), thr, int(r.pushes), int(r.wins),
		String(r.get("levers", "")), int((ev.get("patience", {}) as Dictionary).get("current", 0)), int(t1.get("valuation_m", 0)),
		int(t1.get("dilution_pct", 0)), int(t1.get("board_seats", 0)), str(bool(t1.get("board_veto", false))),
		money, GameState.vc_rejections])
	_vc_done = true
	if walked:
		TermSheetTableSystem.leave()    # the closure is already written by the fund's walk-out
	elif _vc_policy == "walk":
		TermSheetTableSystem.walk()     # → VCPitchSystem.walk_table: the decision faced, the run goes on
	else:
		TermSheetTableSystem.sign()     # → EndingsSystem.trigger_ending("series_a_close")
	TermSheetTableSystem.end_sitting()  # a run-ending signature owes no hours


static func _vc_end(outcome: String, reason: String) -> void:
	print("PROBE VC_TABLE_END day=%d fund=- policy=%s outcome=%s reason=%s pushes=0 rejections=%d" % [
		GameState.day, _vc_policy, outcome, reason, GameState.vc_rejections])
	_vc_done = true


# --- Replays (naive only) ------------------------------------------------------
#
# One run gives at most one table: signing ends the run, and a fund walking out marks the
# Series A decision faced, which a profitable company at the door turns into the bootstrap
# ending the next day. So each naive run also replays the table, from the SAME company on
# the SAME day, K times per fund: a fresh sheet stamped at the win line (70), the fund's real
# fit, a reseeded skill stream. Nothing is signed. Afterwards every touched field and the
# skill stream go back exactly, and a fingerprint of everything a save carries (GameState, the
# registries, every system block incl. the event engine and the RNG streams) plus the event
# engine's pending signal buffer proves it.

static func _vc_capture() -> Dictionary:
	return {
		"sheets": GameState.active_sheets.duplicate(),          # the same TermSheet objects
		"vc_states": GameState.vc_states.duplicate(true),
		"rej": GameState.vc_rejections,
		"faced": GameState.faced_series_a,
		"faced_by": GameState.faced_series_a_by,
		"pa": GameState.run_pushes_attempted,
		"pw": GameState.run_pushes_won,
	}


static func _vc_restore(s: Dictionary) -> void:
	GameState.active_sheets.clear()
	GameState.active_sheets.append_array(s["sheets"] as Array)
	GameState.vc_states.clear()
	GameState.vc_states.merge((s["vc_states"] as Dictionary).duplicate(true))
	GameState.vc_rejections = int(s["rej"])
	GameState.faced_series_a = bool(s["faced"])
	GameState.faced_series_a_by = String(s["faced_by"])
	GameState.run_pushes_attempted = int(s["pa"])
	GameState.run_pushes_won = int(s["pw"])


static func _state_fingerprint() -> Dictionary:
	return {"gs": SaveCodec.capture_game_state(), "reg": SaveCodec.capture_registries(),
		"sys": SaveManager._capture_systems(), "ev_buf": EvEngine._signal_buffer.size()}


static func _run_replays() -> void:
	if TermSheetTableSystem.is_active() or VCPitchSystem.is_active() or not GameState.run_active:
		print("PROBE ERROR day=%d replays need a closed table and a live run" % GameState.day)
		return
	var fp0: Dictionary = _state_fingerprint()
	var snap: Dictionary = _vc_capture()
	var rng: RandomNumberGenerator = RngStreams.get_stream(RngStreams.STREAM_SKILL)
	var seed0: int = rng.seed
	var state0: int = rng.state
	for raw in InvestorRegistry.get_active():
		var fund: String = String((raw as Dictionary).get("id", ""))
		var nf: int = 0
		var nw: int = 0
		var nx: int = 0
		var e0_f: int = -1
		var fit_f: int = 0
		var thr_f: int = -1
		for i in _replay_k:
			rng.seed = EvDice.fnv1a("%d|probe_vc_replay_rng|%s|%d" % [GameState.run_seed, fund, i])
			GameState.active_sheets.clear()               # ONE sheet: no leverage from another
			var sh: TermSheet = VCPitchSystem._make_sheet(fund, GameState.day)
			sh.conviction = TermSheetTableSystem.E_FALLBACK_CONV_SERIES_A
			GameState.active_sheets.append(sh)
			TermSheetTableSystem.open(fund, PitchConstants.STAGE_SERIES_A)
			var e0: int = TermSheetTableSystem.eagerness()
			var fit: int = TermSheetTableSystem._domain_fit()
			var thr: int = TermSheetTableSystem.walk_threshold()
			var r: Dictionary = _push_until_done("probe_vc_replay_lever", "%s#%d" % [fund, i], fund, false)
			var st: int = int(r.state)
			var outcome: String = "EXHAUSTED"
			if st == TermSheetTableSystem.PATIENCE_ZERO:
				outcome = "FINAL_OFFER"
				nf += 1
			elif st == TermSheetTableSystem.FUND_WALKED:
				outcome = "FUND_WALKED"
				nw += 1
			else:
				nx += 1
			print("PROBE VC_REPLAY day=%d fund=%s i=%d outcome=%s e0=%d fit=%d thr=%d pushes=%d wins=%d levers=%s e_end=%d" % [
				GameState.day, fund, i, outcome, e0, fit, thr, int(r.pushes), int(r.wins), String(r.levers), TermSheetTableSystem.eagerness()])
			e0_f = e0
			fit_f = fit
			thr_f = thr
			TermSheetTableSystem.reset()      # not leave(): leave() only closes a walked-out table
			_vc_restore(snap)
		print("PROBE VC_REPLAY_SUM day=%d fund=%s n=%d final=%d walked=%d exhausted=%d walk_pct=%.1f e0=%d fit=%d thr=%d" % [
			GameState.day, fund, _replay_k, nf, nw, nx, 100.0 * float(nw) / float(maxi(_replay_k, 1)), e0_f, fit_f, thr_f])
	rng.seed = seed0          # seed first: setting it resets state
	rng.state = state0
	var fp1: Dictionary = _state_fingerprint()
	if fp1 != fp0:
		var bad: Array[String] = []
		var g0: Dictionary = fp0["gs"] as Dictionary
		var g1: Dictionary = fp1["gs"] as Dictionary
		for k in g0.keys():
			if g0[k] != g1.get(k):
				bad.append(String(k))
		if fp0["reg"] != fp1["reg"]:
			bad.append("registries")
		var s0: Dictionary = fp0["sys"] as Dictionary
		var s1: Dictionary = fp1["sys"] as Dictionary
		for k in s0.keys():
			if s0[k] != s1.get(k):
				bad.append("sys." + String(k))
		if int(fp0["ev_buf"]) != int(fp1["ev_buf"]):
			bad.append("ev_signal_buffer")
		print("PROBE ERROR day=%d replay left a trace: %s" % [GameState.day, ",".join(bad)])


# ============================================================================
#  World presets
# ============================================================================

static func _seed_world(preset: String) -> void:
	if preset.begins_with("full_run"):
		# THE PLAYED RUN. Nothing is seeded: no product, no customers, no money beyond the
		# origin's opening cash. Everything the log shows was earned by the founder's moves
		# through the same seams the tabs call.
		_full_run = true
		var spec: Dictionary = PRESETS[preset]
		_subtype = String(spec.subtype)
		_policy = String(spec.get("policy", "sensible"))
		_vc_policy = String(spec.get("vc", ""))
		_staff_cap = int(spec.get("staff_cap", STAFF_LADDER.size()))
		_k1_only = bool(spec.get("k1_only", false))
		_fix_arm = String(spec.get("fix", ""))
		_no_stop = bool(spec.get("no_stop", false))
		_core_only = bool(spec.get("core_only", false))
		_desk = bool(spec.get("desk", false))
		_server_policy = String(spec.get("server", ""))
		_cash_arm = String(spec.get("cash", ""))
		ProductState.bugs_free = _fix_arm == "off"
		return
	GameState.set_cash(60000)   # deep enough that the Kepenk shutter never confounds a 90-day log
	match preset:
		"b2c":
			_seed_b2c_world()
		"b2c_neglect":
			_seed_b2c_neglect()
		"b2b_solo", "b2b_reps", "b2b_risk", "b2b_slip":
			_seed_b2b_world(preset)
		"b2b_book20", "b2b_book330":
			_seed_book(PRESETS[preset])


## A product already live on day 1. mvp_launch_day is stamped here because the fixture skips
## the sprint close, its only writer, and every weeks_since_flag trigger reading it would
## otherwise stay false forever.
static func _seed_live_product(market: String, subtype: String, product_name: String) -> void:
	GameState.set_flag("mvp_shipped", true)
	GameState.set_flag("mvp_launch_day", GameState.day)
	GameState.set_flag("mvp_market_type", market)
	GameState.set_flag("mvp_sub_product_type_id", subtype)
	GameState.set_flag("mvp_version", 1)
	GameState.set_flag("mvp_product_name", product_name)


## The tended consumer product, built by the sprint engine itself: the note app and the founder
## alone, Sprint 1 started on the lead's plan; every later sprint is started on it by _start_on_lead.
## The release brings the launch audience and opens the paid tier.
static func _seed_b2c_world() -> void:
	SprintSystem.choose_type("note_tool", PRODUCT_NAMES["note_tool"])
	SprintSystem.apply_lead()
	SprintSystem.start()
	EventBus.version_shipped.connect(func(_n: int) -> void:
		SalesSystem.add_b2c_audience(200)
		SalesSystem.open_b2c_paid_tier(15), CONNECT_ONE_SHOT)


## The UNTENDED consumer product: the note app at its MVP (its first Core lines at K1), a bug backlog eating the
## audience, and nobody sprints. The audience outgrows what the MVP gives and the product falls behind it: the
## "declining" arm of the B2C growth measurement.
static func _seed_b2c_neglect() -> void:
	_seed_live_product("b2c", "note_tool", "Nova")
	for line_id in SprintCatalog.capabilities("core").slice(0, int(SprintCatalog.cfg("mvp_lines"))):
		ProductState.set_line_tier(line_id, 1)
	ProductState.add_bugs(FIXTURE_BUG_LINE, 12)
	SalesSystem.add_b2c_audience(200)
	SalesSystem.open_b2c_paid_tier(15)


# --- The B2B presets' world ---

## The B2B presets' ERP, shipped line by line: the tiers of the five core lines, the tier of every other line, the open bugs
## on the core line (`FIXTURE_BUG_LINE`, which every account uses) and whether the book is settled (its onboarding floors
## have lifted, so the product alone decides). The pressure of each preset is DERIVED from the accounts' own fit and bars:
## `_check_b2b_fixture` prints it at seed time and answers a PROBE ERROR when the intent no longer holds.
##   b2b_solo, b2b_reps: every line at K1. The 1★ and 2★ accounts are steady, the 3★ one slides.
##   b2b_risk: UNSALVAGEABLE. One core line at K1 and nothing else, so every account's target sits under its bar even with no
##             bug open.
##   b2b_slip: RECOVERABLE. The K1 ladder with four core lines at K2. With the backlog open the 3★ account sits just under its
##             bar; cleared, every account sits over it. A founder who answers the demand AND cleans up keeps the account,
##             and one who ignores it does not.
const B2B_PRODUCTS := {
	"b2b_solo": {"core": [1, 1, 1, 1, 1], "rest": 1, "bugs": 4, "settled": false},
	"b2b_reps": {"core": [1, 1, 1, 1, 1], "rest": 1, "bugs": 4, "settled": false},
	"b2b_risk": {"core": [1, 0, 0, 0, 0], "rest": 0, "bugs": 14, "settled": true},
	"b2b_slip": {"core": [2, 2, 2, 2, 1], "rest": 1, "bugs": 24, "settled": true},
}
## b2b_slip: the points every account clears its bar by once the backlog is cleared.
const SLIP_CLEAR_MARGIN := 3


## The preset's intent, read off the signed book: each account's target with the backlog open and with none, against its bar
## (`book` lists id:clear/live/bar). The product alone decides the book, so a table or tolerance move that breaks the intent
## prints a PROBE ERROR instead of silently measuring another world.
static func _check_b2b_fixture(preset: String) -> void:
	var book: Array = CustomerRegistry.get_by_market("b2b")
	var rows: PackedStringArray = []
	var under_live: int = 0
	var under_clear: int = 0
	var slack: int = 100   # the least a cleared target clears its bar by
	for c in book:
		var clear: int = ProductQuality.account_fit(c).value
		var live: int = B2BSalesSystem._target_on(c, B2BSalesSystem.onboarding_floor_until(c), 0.0)   # the target once its floor lifts, no trust
		under_live += int(live < c.tolerance)
		under_clear += int(clear < c.tolerance)
		slack = mini(slack, clear - c.tolerance)
		rows.append("%s:%d/%d/%d" % [c.id, clear, live, c.tolerance])
	var ok: bool = false
	match preset:
		"b2b_solo", "b2b_reps":
			ok = under_live > 0 and under_live < book.size()
		"b2b_risk":
			ok = under_clear == book.size()
		"b2b_slip":
			ok = under_live > 0 and slack >= SLIP_CLEAR_MARGIN
	print("PROBE FIXTURE preset=%s bugs=%d under_live=%d under_clear=%d slack=%d book=%s" % [
		preset, ProductState.open_bugs(), under_live, under_clear, slack, ",".join(rows)])
	if not ok:
		print("PROBE ERROR fixture drifted: %s no longer satisfies its intent (re-derive after a table or tolerance move)" % preset)


## The ERP's lines shipped to `spec`'s tiers: every line at `rest`, the core lines at `core`.
static func _ship_erp_lines(spec: Dictionary) -> void:
	for line_id in ProductLines.line_ids("erp"):
		ProductState.set_line_tier(String(line_id), int(spec.rest))
	var core: Array[String] = SprintCatalog.capabilities("core")
	for i in core.size():
		ProductState.set_line_tier(core[i], int(spec.core[i]))


static func _seed_b2b_world(preset: String) -> void:
	var spec: Dictionary = B2B_PRODUCTS[preset]
	_seed_live_product("b2b", "erp", "Sahra")
	_ship_erp_lines(spec)
	ProductState.add_bugs(FIXTURE_BUG_LINE, int(spec.bugs))

	# Five accounts through the real signing seam (SalesSystem.add_b2b_customer — the
	# sole B2B signing path), spread across archetypes so tolerance seeds differ and the
	# CS request cadence phases apart (cs_request_phase strides by 9 per signing).
	# Total MRR is deliberately ~2.7K: a young book that is PAST the traction gate
	# (mvp_shipped + 1 customer + mrr > 0) and well SHORT of Series A (MRR at the
	# SalesSystem.TRACTION_MRR_TARGET bar — MRR only). Seeded higher, the run rockets to
	# phase 3 in two days and the log stops describing the early game it is supposed to
	# describe.
	#
	# Satisfaction seeds straddle the tolerance seeds on purpose: probe_c and probe_e open at
	# the neutral signing start (their bar + SIGNING_SAT_OVER_TOL), the lowest a signing allows,
	# so the target can pull them under once their onboarding floor has lifted, which
	# is the only way the retention → promise → churn chain is reachable without hand-forcing it.
	var specs := [
		{"id": "probe_a", "name": "Kuzey Lojistik", "industry": "logistics", "star": 1, "seats": 7, "price": 50, "sat": 72},
		{"id": "probe_b", "name": "Ege Sağlık", "industry": "health", "star": 2, "seats": 16, "price": 50, "sat": 64},
		{"id": "probe_c", "name": "Marmara İnşaat", "industry": "construction", "star": 2, "seats": 14, "price": 50, "sat": 57},
		{"id": "probe_d", "name": "Toros Sigorta", "industry": "insurance", "star": 1, "seats": 6, "price": 50, "sat": 68},
		{"id": "probe_e", "name": "Anadolu Üretim", "industry": "manufacturing", "star": 3, "seats": 11, "price": 50, "sat": 61},
	]
	for s in specs:
		var p := Prospect.new()
		p.id = String(s["id"])
		p.company_name = String(s["name"])
		p.industry = String(s["industry"])
		# Satış §2 — the STAR is the size; `add_b2b_customer` copies it into `Customer.scale`,
		# which seeds the hidden tolerance.
		p.star = int(s["star"])
		# §5.3 — the deal is SEATS x SEAT PRICE: seat counts inside each star's band at the
		# Standard price anchor (MRR 350 / 800 / 700 / 300 / 550).
		SalesSystem.add_b2b_customer(p, int(s["seats"]), int(s["price"]), int(s["sat"]))
	if spec.settled:
		for c in CustomerRegistry.get_by_market("b2b"):
			c.acquired_on_day = GameState.day - TimeModel.ticks(B2BConstants.ONBOARDING_GRACE_WEEKS)
	_check_b2b_fixture(preset)

	for i in (2 if preset == "b2b_reps" else 0):
		var c := Character.new()
		c.id = "probe_cs_%d" % i
		c.character_name = "Temsilci %d" % (i + 1)
		c.role = HRConstants.ROLE_CUSTOMER_REP
		c.category = "employee"
		c.monthly_salary = 6000
		c.morale = 60
		# A junior rep, MÜŞTERİ İLİŞKİLERİ 2: the desk absorbs every request up to
		# CustomerRepSystem.absorb_ceiling(), so a strong rep would swallow the whole request
		# channel and the escalation path would never be observed. The trait touches only
		# overtime morale, so it does not move the rep's output or growth.
		c.role_stats = HRConstants.seed_skills(c.role, 2, 2)
		c.traits = ["last_one_out"]
		CharacterRegistry.add(c)


# --- The scale fixtures' world (the sprint probe and --tick-probe seed their companies here too) ---

## What b2b_book20 and b2b_book330 start with in cash: some three years of the 50-person payroll less the book's MRR.
const BOOK_CASH := 5_000_000   # [WORKING]
## The morale a probe employee is seeded with.
const SEED_MORALE := 60


## The live ERP, every line at K1, with `accounts` B2B accounts signed through the signing seam (the sectors in turn, the stars
## the bot's signing mix of 56% one, 42% two and 2% three, spread over every fifty so a small book has it too, the seat
## band's low end at the lowest seat price so the MRR stays under the Traction bar, settled past onboarding) and `staff`
## people (the founder among them, the rest on the junior salary) on the sprint engine, which the lead plans from the first
## morning.
static func _seed_book(spec: Dictionary) -> void:
	SprintSystem.choose_type("erp", PRODUCT_NAMES["erp"])
	_seed_live_product("b2b", "erp", PRODUCT_NAMES["erp"])
	_ship_erp_lines(B2B_PRODUCTS["b2b_solo"])
	var sectors: Array = B2BConstants.SECTORS
	for i in int(spec.accounts):
		var lead := Prospect.new()
		lead.id = "book_%03d" % i
		lead.company_name = "Book %03d" % i
		lead.industry = String(sectors[i % sectors.size()])
		var slot: int = (i * 37) % 50
		lead.star = 1 if slot < 28 else (2 if slot < 49 else 3)
		var account: Customer = SalesSystem.add_b2b_customer(lead, int(SalesConstants.seat_band(lead.star).low),
			SalesConstants.SEAT_PRICE_MIN, 85)
		account.acquired_on_day = GameState.day - TimeModel.ticks(B2BConstants.ONBOARDING_GRACE_WEEKS)
	seed_crew(int(spec.staff), _run_seed)
	for employee in CharacterRegistry.get_employees():
		employee.monthly_salary = int(HRConstants.salary_band_for_level(employee.role, HRConstants.LEVEL_JUNIOR)[1])
	GameState.set_cash(BOOK_CASH)


## The employees of an `n`-person probe company (the founder is the n-th), hired past the desk cap the way
## OfficeCrowdProbe seeds its staff. Up to six people they are SMALL_CREW in turn at stat 5; 12, 25 and 50 people are
## CREW_MIX, each drawing the stat of their role from `rng_seed` (every draw is made, so pinning a role leaves the others'
## stars alone). `tester_star` and `pm_star` (1 to 5; 0 leaves them to the draw) pin those two roles' stars.
static func seed_crew(n: int, rng_seed: int, tester_star := 0, pm_star := 0) -> void:
	var roles: Array = SMALL_CREW.slice(0, n - 1)
	var drawn: bool = n > SMALL_CREW.size() + 1
	if drawn:
		if not CREW_MIX.has(n):
			push_error("[RunProbe] no company of %d people (have 1 to %d and %s)" % [n, SMALL_CREW.size() + 1, str(CREW_MIX.keys())])
			return
		roles = []
		for i in CREW_ROLES.size():
			for _k in int(CREW_MIX[n][i]):
				roles.append(CREW_ROLES[i])
	var rng := RandomNumberGenerator.new()
	rng.seed = rng_seed
	for i in roles.size():
		var stat: int = int(STAT_SPREAD[rng.randi() % STAT_SPREAD.size()]) if drawn else 5
		if roles[i] == HRConstants.ROLE_TESTER and tester_star > 0:
			stat = HRConstants.POINTS_PER_STAR * tester_star
		elif roles[i] == HRConstants.ROLE_PRODUCT_MANAGER and pm_star > 0:
			stat = HRConstants.POINTS_PER_STAR * pm_star
		seed_hire("char_probe_%d" % i, roles[i], stat)


## One probe employee at mid morale, `stat` (0 to 10) in their role's area, hired past the desk cap.
static func seed_hire(id: String, role: String, stat: int) -> void:
	var c := Character.new()
	c.id = id
	c.character_name = id
	c.role = role
	c.category = "employee"
	c.morale = SEED_MORALE
	c.role_stats = HRConstants.seed_skills(role, stat, 3, 2)
	c.traits = ["picks_it_up_fast"]
	CharacterRegistry.add(c)


## The scale fixtures' people stay as content as they were seeded: the morale of a company nobody looks after drifts down in
## step and the whole roster resigns in a single week.
static func _pin_the_morale() -> void:
	for employee in CharacterRegistry.get_employees():
		employee.morale = SEED_MORALE
		employee.morale_target = float(SEED_MORALE)
