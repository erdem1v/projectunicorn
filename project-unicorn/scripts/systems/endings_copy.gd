class_name EndingsCopy
extends RefCounted

# ============================================================================
# Ending newspaper copy system ("Ekonomi Postası").
# ============================================================================
# Decides which lines run on each ending's paper; the prose itself is END_* keys in
# strings.csv. It is code, not data, because the paper is ASSEMBLED: a ledger line enters
# only if its field is populated, bankruptcy branches its whole layout on the phase, and
# Series A swaps headline sets on the signed terms. The fixed RAIL chrome (SIRADA NE VAR?,
# WISHLIST'E EKLE…) is ENDING_* keys and belongs to EndingScene. Reads GameState + the
# ledger, writes nothing. `# WORKING` marks a draft choice (a stat row, a pool size)
# pending the owner's pass.
#
# EDITORIAL RULES (the END_* copy and the code below both keep them):
#   1. newspaper language, not stat language;
#   2. NO raw day count in prose (calendar framing via _span_phrase);
#   3. NO cash figures / "$" in PROSE (origin-aware founding clause); the stat_cells row
#      is the ONE sanctioned "$" surface: it is an infographic, not prose;
#   4. investment figures in prose stay spelled-out ("milyon dolar");
#   5. quote attribution goes to the CROWD, never to one person (no "danışman"/"mentor");
#   6. no em-dash, no emoji, no English finance terms ("Series A" is a proper noun; stat
#      LABELS may use the ruled loanwords already in game vocabulary: MRR, pitch, never ARR).

# --- Tuning / working constants (single surface) ---
const FF_MAX_EQUITY := 18          # Founder-Friendly ceiling (inclusive): equity <= 18 AND no veto
const MIN_LEDGER_LINES := 4
const MAX_LEDGER_LINES := 6
const YEAR_DAYS := 350             # >= → "bir yıla yakın" framing
const OVER_YEAR_DAYS := 380           # "bir yılı aşkın" — a run clearly past its first year
const TWO_YEAR_DAYS := 700            # "iki yıla yakın" — the soft cap's own span (730)
const OVER_TWO_YEAR_DAYS := 745       # "iki yılı aşkın" — only a run past its milestone gets here (EA / full: no cap)
const ISSUE_PERIOD_DAYS := 7       # weekly paper: masthead "SAYI N" = run day / 7  # WORKING
const ENGRAVING_DIR := "res://assets/endings/"

# Month words come from Fmt.month_name (the single home; it does NOT lowercase a
# Turkish month, which would mangle the dotted İ). Spelled-out numerals are NUM_0..12 in
# strings.csv — a const cannot hold them, because a const is evaluated when the file loads
# and no locale exists yet.
const NUM_MAX := 12

# Faz-1 quiet-closure generic masthead pool (the player is NOT the headline). Picked
# deterministically by hash(company) so a debug re-trigger is stable. # WORKING
# END_GENERIC_HEAD_<n> / END_GENERIC_SUB_<n> in strings.csv; only the count lives here.
const GENERIC_HEADLINE_COUNT := 3


# ============================================================================
# Entry point
# ============================================================================

static func build(ending_id: String, ledger: Dictionary, ending_data: Dictionary) -> Dictionary:
	match ending_id:
		"series_a_close": return _series_a(ledger, ending_data)
		"acquisition": return _acquisition(ledger, ending_data)
		"bankruptcy": return _bankruptcy(ledger, ending_data)
		"brand_collapse": return _brand_collapse(ledger, ending_data)
		"vc_rejection_cascade": return _vc_cascade(ledger, ending_data)
		"profitable_bootstrap": return _bootstrap(ledger, ending_data)
		"running_on_fumes": return _fumes(ledger, ending_data)
		_:
			push_warning("[EndingsCopy] unknown ending_id: %s" % ending_id)
			var vs := _common(ending_id, ledger, ending_data)
			vs.headline = String(ending_data.get("title", ""))
			vs.subhead = String(ending_data.get("frank_line", ""))
			return vs


# ============================================================================
# Per-ending builders
# ============================================================================

static func _series_a(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("series_a_close", ledger, data)
	var company := _company(data)
	var equity := int(ledger.get("equity_pct", 0))
	var veto := bool(ledger.get("board_veto", false))
	var valuation := int(ledger.get("valuation_m", 0))
	var investment := int(ledger.get("investment_amount", 0))
	var seats := int(ledger.get("board_seats", 0))
	var founder_friendly := equity <= FF_MAX_EQUITY and not veto

	if founder_friendly:
		vs.variant = "founder_friendly"
		vs.headline = _t("END_SA_HEAD_FF").format({"company": company})
		vs.subhead = _t("END_SA_SUB_FF")
		vs.engraving_caption = _t("END_SA_CAP_FF")
	else:
		vs.variant = "aggressive"
		vs.headline = _t("END_SA_HEAD_AGG").format({"company": company})
		vs.subhead = _t("END_SA_SUB_AGG")
		vs.engraving_caption = _t("END_SA_CAP_AGG")

	var pool: Array = []
	if valuation > 0:
		pool.append(_t("END_SA_TERMS").format({
			"valuation": _valuation_tr(valuation), "investment": _investment_tr(investment),
			"equity": equity}))
	if seats > 0:
		var board := _n("END_SA_BOARD", seats).format({"seats": _num(seats)})
		if veto:
			board += _t("END_SA_VETO")
		pool.append(board)
	pool.append(_t("END_SA_OPENED").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	pool.append(_people_line(ledger, "END_SA_CUSTOMERS", "END_SA_AUDIENCE"))
	if int(ledger.get("employees", 0)) > 0:
		pool.append(_t("END_SA_TEAM").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("pitches", 0)) > 1:
		pool.append(_t("END_SA_MANY_TABLES"))

	vs.ledger_lines = _assemble(pool, [_t("END_SA_CLOSER_1"), _t("END_SA_CLOSER_2")])
	# Stat row (4 big figures under the photo). Set per template. # WORKING
	vs.stat_cells = [
		_stat(Fmt.money(investment), _t("END_STAT_INVESTMENT")),
		_stat(Fmt.money(valuation * 1_000_000), _t("END_STAT_VALUATION")),
		_people_stat(ledger),
		_stat(Fmt.percent(_founder_share(ledger), 0), _t("END_STAT_FOUNDER_SHARE")),
	]
	return vs


static func _acquisition(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("acquisition", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_ACQ_HEAD").format({"company": company})
	vs.subhead = _t("END_ACQ_SUB")
	vs.engraving_caption = _t("END_ACQ_CAP")

	var pool: Array = []
	# The world is frozen by the time this renders, so this is the price the buyout card
	# showed the player. Spelled through _investment_tr (Rule 4: no "$" in prose).
	pool.append(_t("END_ACQ_PRICE").format(
		{"valuation": _investment_tr(EndingsSystem.acquisition_valuation())}))
	pool.append(_t("END_ACQ_NEW_ROOF").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	pool.append(_people_line(ledger, "END_ACQ_BOOK", "END_ACQ_AUDIENCE"))
	if int(ledger.get("employees", 0)) > 0:
		pool.append(_t("END_ACQ_CORE").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_ACQ_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	if int(ledger.get("vc_rejections", 0)) > 0:
		pool.append(_t("END_ACQ_DOORS"))

	vs.ledger_lines = _assemble(pool, [_t("END_ACQ_CLOSER_1"), _t("END_ACQ_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_stat(Fmt.money(EndingsSystem.acquisition_valuation()),
			_t("END_STAT_SALE_PRICE")),
		_people_stat(ledger),
		_employees_stat(ledger),
		_mrr_stat(ledger, "END_STAT_MRR"),
	]
	return vs


static func _bankruptcy(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var phase := int(ledger.get("phase", 1))
	var vs := _common("bankruptcy", ledger, data)
	var company := _company(data)

	if phase <= 1:
		return _bankruptcy_quiet(vs, company)

	if phase == 2:
		vs.variant = "phase2_traction"
		vs.headline = _t("END_BK2_HEAD").format({"company": company})
		vs.subhead = _t("END_BK2_SUB")
		vs.engraving_caption = _t("END_BK2_CAP")
	else:
		vs.variant = "phase3_hunt"
		vs.headline = _t("END_BK3_HEAD").format({"company": company})
		vs.subhead = _t("END_BK3_SUB")
		vs.engraving_caption = _t("END_BK3_CAP")

	var pool: Array = []
	pool.append(_t("END_BK_SHUTTERED").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	pool.append(_people_line(ledger, "END_BK_LEFT_BEHIND", "END_BK_AUDIENCE"))
	if int(ledger.get("customers_lost", 0)) > 0:
		pool.append(_n("END_BK_LOST", int(ledger.get("customers_lost", 0))).format(
			{"n": int(ledger.get("customers_lost", 0))}))
	if int(ledger.get("hires", 0)) > 0:
		# Framed on hires, never a "1 resignation" line.
		pool.append(_t("END_BK_TEAM_SCATTERED"))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_BK_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	if phase == 3 and int(ledger.get("pitches", 0)) > 0:
		pool.append(_t("END_BK_NO_SIGNATURE"))

	vs.ledger_lines = _assemble(pool, [_t("END_BK_CLOSER_1"), _t("END_BK_CLOSER_2")])
	# Faz 2-3 only (the quiet faz-1 path returned above with no stat row). "$0" SON MRR
	# is editorially correct on a bankruptcy paper. # WORKING
	vs.stat_cells = [
		_months_stat(ledger),
		_people_stat(ledger),
		_employees_stat(ledger),
		_mrr_stat(ledger, "END_STAT_LAST_MRR"),
	]
	return vs


static func _bankruptcy_quiet(vs: Dictionary, company: String) -> Dictionary:
	# Faz-1 "iz bırakmadan": a generic sector story runs the masthead; the player's
	# closure is a small below-the-fold notice. No engraving, no ledger box.
	vs.variant = "phase1_quiet"
	vs.is_quiet_closure = true
	var idx: int = abs(hash(company)) % GENERIC_HEADLINE_COUNT
	vs.headline = _t("END_GENERIC_HEAD_%d" % idx)
	vs.subhead = _t("END_GENERIC_SUB_%d" % idx)
	vs.quiet_notice = _t("END_BK1_NOTICE").format({"company": company})
	return vs


static func _brand_collapse(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("brand_collapse", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_BC_HEAD").format({"company": company})
	vs.subhead = _t("END_BC_SUB")
	vs.engraving_caption = _t("END_BC_CAP")

	var pool: Array = []
	pool.append(_t("END_BC_TRUST_LOST").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	if int(ledger.get("customers_lost", 0)) > 0:
		pool.append(_n("END_BC_ONE_BY_ONE", int(ledger.get("customers_lost", 0))).format(
			{"n": int(ledger.get("customers_lost", 0))}))
	pool.append(_t("END_BC_BELOW_THRESHOLD"))
	if int(ledger.get("hires", 0)) > 0:
		pool.append(_t("END_BC_TEAM_SCATTERED"))

	vs.ledger_lines = _assemble(pool, [_t("END_BC_CLOSER_1"), _t("END_BC_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_stat(str(int(ledger.get("brand", 0))), _t("END_STAT_BRAND")),
		_stat(str(int(ledger.get("customers_lost", 0))), _t("END_STAT_CUSTOMERS_LOST")),
		_employees_stat(ledger),
		_mrr_stat(ledger, "END_STAT_LAST_MRR"),
	]
	return vs


static func _vc_cascade(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("vc_rejection_cascade", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_VC_HEAD").format({"company": company})
	vs.subhead = _t("END_VC_SUB")
	vs.engraving_caption = _t("END_VC_CAP")

	var pool: Array = []
	pool.append(_t("END_VC_INCOMPLETE").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	if int(ledger.get("pitches", 0)) > 0:
		pool.append(_t("END_VC_NO_SIGNATURE"))
	if int(ledger.get("sheets_won", 0)) > 0:
		pool.append(_t("END_VC_OFFER_CAME"))
	pool.append(_people_line(ledger, "END_VC_CUSTOMERS", "END_VC_AUDIENCE"))
	pool.append(_t("END_VC_NO_MOMENTUM"))

	vs.ledger_lines = _assemble(pool, [_t("END_VC_CLOSER_1"), _t("END_VC_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_stat(str(int(ledger.get("vc_rejections", 0))), _t("END_STAT_REJECTIONS")),
		_stat(str(int(ledger.get("pitches", 0))), _t("END_STAT_PITCHES")),
		_mrr_stat(ledger, "END_STAT_MRR"),
		_months_stat(ledger),
	]
	return vs


static func _bootstrap(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("profitable_bootstrap", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_BS_HEAD").format({"company": company})
	vs.subhead = _t("END_BS_SUB")
	vs.engraving_caption = _t("END_BS_CAP")

	var pool: Array = []
	pool.append(_t("END_BS_OWN_FEET").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	pool.append(_people_line(ledger, "END_BS_BALANCED", "END_BS_AUDIENCE"))
	if int(ledger.get("hires", 0)) > 0:
		pool.append(_t("END_BS_PAYROLL").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_BS_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	# The win is a streak of Artıda months; the paper names it.
	if int(ledger.get("profit_streak", 0)) > 0:
		pool.append(_t("END_BS_STREAK").format({"n": _num(int(ledger.get("profit_streak", 0)))}))
	else:
		pool.append(_t("END_BS_COVERS_COSTS"))

	vs.ledger_lines = _assemble(pool, [_t("END_BS_CLOSER_1"), _t("END_BS_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_mrr_stat(ledger, "END_STAT_MRR"),
		_people_stat(ledger),
		_employees_stat(ledger),
		_audience_stat(ledger) if _is_b2c(ledger) else _stat(Fmt.percent(_founder_share(ledger), 0), _t("END_STAT_FOUNDER_SHARE")),
	]
	return vs


static func _fumes(ledger: Dictionary, data: Dictionary) -> Dictionary:
	# THE SOFT CAP's paper. Director ruling: the id stays
	# running_on_fumes; the register is "yatırımcılar ilgisini kaybetti" — a company that
	# reached no goal ending inside the window investors give it. Not a failure screen:
	# the company did not close, it dropped off the agenda. Frank's verdict line is the
	# ruling's own text (END_META_RUNNING_ON_FUMES_FRANK).
	var vs := _common("running_on_fumes", ledger, data)
	var company := _company(data)
	var phase := int(ledger.get("phase", 1))
	vs.headline = _t("END_RF_HEAD").format({"company": company})
	match phase:
		1: vs.subhead = _t("END_RF_SUB_P1")
		2: vs.subhead = _t("END_RF_SUB_P2")
		_: vs.subhead = _t("END_RF_SUB_P3")
	vs.engraving_caption = _t("END_RF_CAP")

	var pool: Array = []
	pool.append(_t("END_RF_STAYED_STANDING").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	# An unsigned offer left on the table is named, never silently dropped.
	if int(ledger.get("unsigned_sheets", 0)) > 0:
		pool.append(_t("END_RF_UNSIGNED_SHEET"))
	pool.append(_people_line(ledger, "END_RF_UNFINISHED", "END_RF_AUDIENCE"))
	if int(ledger.get("hires", 0)) > 0:
		pool.append(_t("END_RF_TEAM_STAYED"))
	# ELSE şart: satırı yalnızca koşullamak havuzu en kötü durumda 1 satır + 2 yedek = 3'e
	# düşürür ve gazete eksik dizilirdi. Her iki dal da tam bir satır ekler.
	# The consumer arm has to count paying users, or a B2C run with real revenue reads
	# as one that never earned anything.
	var had_customers: int = _people_count(ledger)
	if int(ledger.get("mrr", 0)) > 0 or had_customers > 0:
		pool.append(_t("END_RF_REVENUE_SOME"))
	else:
		pool.append(_t("END_RF_REVENUE_NONE"))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_RF_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))

	# A round was raised against a promise. Whether it was kept is the difference between
	# a company that ran out of runway and one that ran out of patience.
	if String(ledger.get("seed_lead", "")) != "":
		pool.append(_t("END_RF_SEED_STALLED"
			if int(ledger.get("seed_expectation", 0)) == SeedConstants.EXPECT_STALLED
			else "END_RF_SEED_TAKEN"))
	vs.ledger_lines = _assemble(pool, [_t("END_RF_CLOSER_1"), _t("END_RF_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_months_stat(ledger),
		_mrr_stat(ledger, "END_STAT_MRR"),
		# A CONSUMER RUN SPENDS ITS FOURTH CELL ON THE SECOND POPULATION FIGURE. Ch. 13 §2
		# asks for audience AND paying users, and the row holds four; headcount is the one
		# the prose already carries (END_RF_TEAM_STAYED), so it yields.
		_audience_stat(ledger) if _is_b2c(ledger) else _people_stat(ledger),
		_people_stat(ledger) if _is_b2c(ledger) else _employees_stat(ledger),
	]
	return vs


# ============================================================================
# Assembly helpers (all pure)
# ============================================================================

static func _common(ending_id: String, ledger: Dictionary, data: Dictionary) -> Dictionary:
	return {
		"variant": "",
		"masthead": _t("WORLD_OUTLET_EKONOMI_CAPS"),
		"date_line": _date_line(ledger),
		"headline": "",
		"subhead": "",
		"engraving_path": _engraving_path(ending_id, ledger),
		"engraving_caption": "",
		"ledger_title": _t("END_LEDGER_TITLE").format({"company": Fmt.upper(_company(data))}),
		"ledger_lines": [],
		"stat_cells": [],
		"is_quiet_closure": false,
		"quiet_notice": "",
	}


## Was this a consumer run? Ch. 13 §2: the paper must not print an account count on one.
##
## B2C keeps ONE aggregate customer record, so `customers_active` reads 1 once the paid
## tier opens, and `customers_signed` is written only by the B2B signing path, so it reads
## 0 for the whole run. The population lines and cells read `paying_users` instead.
static func _is_b2c(ledger: Dictionary) -> bool:
	return String(ledger.get("market", "b2c")) != "b2b"


## The run's population: paying users on a B2C run, signed accounts on a B2B one.
static func _people_count(ledger: Dictionary) -> int:
	return int(ledger.get("paying_users" if _is_b2c(ledger) else "customers_signed", 0))


## The population line for a template, or "" when there is nothing true to say.
## _assemble drops "", so a call site can append the result without a check.
static func _people_line(ledger: Dictionary, b2b_key: String, b2c_key: String) -> String:
	var n: int = _people_count(ledger)
	if n <= 0:
		return ""
	return _n(b2c_key if _is_b2c(ledger) else b2b_key, n).format({"n": n})


## The population CELL for the stat row: accounts on a B2B run, paying users on a B2C one.
static func _people_stat(ledger: Dictionary) -> Dictionary:
	return _stat(str(_people_count(ledger)), _t("END_STAT_PAYING" if _is_b2c(ledger) else "END_STAT_CUSTOMERS"))


static func _employees_stat(ledger: Dictionary) -> Dictionary:
	return _stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES"))


static func _mrr_stat(ledger: Dictionary, label_key: String) -> Dictionary:
	return _stat(Fmt.money(int(ledger.get("mrr", 0))), _t(label_key))


static func _months_stat(ledger: Dictionary) -> Dictionary:
	# Stat-row month count as DIGITS — the infographic surface, unlike _span_phrase
	# which frames the same span as prose (Rule 2 keeps raw day counts off the paper).
	return _stat(str(int(ceil(_day(ledger) / 30.0))), _t("END_STAT_MONTHS_ALIVE"))


## The audience cell — B2C only. The second half of ch. 13 §2's "audience AND paying".
static func _audience_stat(ledger: Dictionary) -> Dictionary:
	return _stat(str(int(ledger.get("audience", 0))), _t("END_STAT_AUDIENCE"))


static func _company(data: Dictionary) -> String:
	return String(data.get("company_name", GameState.company_name))


static func _day(ledger: Dictionary) -> int:
	return int(ledger.get("day", 0))


## Spelled-out numeral ("üç" / "three"). Above NUM_MAX the paper falls back to digits, which
## is what the editorial rule wants anyway — a headcount of 40 is a figure, not a word.
static func _num(n: int) -> String:
	if n < 0 or n > NUM_MAX:
		return str(n)
	return _t("NUM_%d" % n)


static func _stat(figure: String, label: String) -> Dictionary:
	# One stat-row cell: a big serif FIGURE over a small mono LABEL.
	# Labels arrive uppercase from their END_STAT_* keys — Fmt.upper is only for derived text.
	return {"figure": figure, "label": label}


static func _founder_share(ledger: Dictionary) -> int:
	# Founder's remaining share after every round taken (angel + seed + signed Series A).
	# investor_equity_pct, not equity_pct: the founder really does own Frank's 4% less,
	# even though the newspaper's valuation sentence stays about the Series A alone.
	return maxi(0, 100 - int(ledger.get("investor_equity_pct", 0)))


static func _span_phrase(days: int) -> String:
	# Rule 2: the paper never prints a raw day count — it frames time in calendar months.
	# The spans run past two years: a run reaches the soft cap (730), and an EA / full run
	# past the bootstrap milestone has no cap at all.
	if days >= OVER_TWO_YEAR_DAYS:
		return _t("END_SPAN_OVER_TWO_YEARS")
	if days >= TWO_YEAR_DAYS:
		return _t("END_SPAN_NEAR_TWO_YEARS")
	if days >= OVER_YEAR_DAYS:
		return _t("END_SPAN_OVER_YEAR")
	if days >= YEAR_DAYS:
		return _t("END_SPAN_NEAR_YEAR")
	var m := int(ceil(days / 30.0))
	if m <= 1:
		return _t("END_SPAN_UNDER_MONTH")
	return _t("END_SPAN_UNDER_N_MONTHS").format({"n": _num(m)})


static func _founding_clause(ledger: Dictionary) -> String:
	# Rule 3: the paper can't know the treasury — the founding is described by origin,
	# never by a cash figure.
	match String(ledger.get("origin", "self_made")):
		"self_made": return _t("END_FOUNDING_SELF_MADE")
		"heir": return _t("END_FOUNDING_HEIR")
		"corporate_refugee": return _t("END_FOUNDING_CORP")
		_:
			return _t("END_FOUNDING_MONTH").format(
				{"month": Fmt.month_name(clampi(int(ledger.get("start_month", 1)), 1, 12))})


static func _date_line(ledger: Dictionary) -> String:
	# Masthead meta line: full calendar date + issue number ("14 KASIM 2027 · SAYI 214").
	# A date and an edition, never a day count — the raw count lives ONLY in the rail's
	# run-meta line (Rule 2). Ledger-driven, not GameState.day, so the paper dates the
	# ledger it was handed (a fixture ledger included), not the live clock.
	var day := _day(ledger)
	var d: Dictionary = GameState.get_date_dict(day if day > 0 else -1)
	var issue := maxi(1, int(float(day) / ISSUE_PERIOD_DAYS))
	return _t("END_DATE_LINE").format({
		"day": int(d.day), "month": Fmt.month_upper(int(d.month)),
		"year": int(d.year), "issue": issue})


static func _valuation_tr(valuation_m: int) -> String:
	return _t("END_MILLIONS").format({"n": valuation_m})


static func _investment_tr(dollars: int) -> String:
	# Rule 4: spelled-out currency, no "$", no abbreviations. Round to nearest million
	# for headline-style figures ("4 milyon dolar").
	return _valuation_tr(maxi(1, int(round(dollars / 1_000_000.0))))


static func _engraving_path(ending_id: String, ledger: Dictionary) -> String:
	# One illustration per ending id (Series A variants share series_a_close.png). Faz-1
	# bankruptcy has NO art (a below-the-fold notice has no art slot).
	if ending_id == "bankruptcy" and int(ledger.get("phase", 1)) <= 1:
		return ""
	return ENGRAVING_DIR + ending_id + ".png"   # LOC-DATA asset path


static func _assemble(pool: Array, backups: Array) -> Array:
	# Include only populated pool lines; top up from field-independent sector backups
	# until >= MIN; cap at MAX. Guarantees the "Rakamlarla" box never reads sparse.
	var lines: Array = []
	for l in pool:
		if String(l) != "":
			lines.append(String(l))
	var i := 0
	while lines.size() < MIN_LEDGER_LINES and i < backups.size():
		lines.append(String(backups[i]))
		i += 1
	if lines.size() > MAX_LEDGER_LINES:
		lines = lines.slice(0, MAX_LEDGER_LINES)
	return lines


## Shorthand for TranslationServer.translate — this file is entirely static functions, and a
## static func has no Object, so tr() would compile here and then die at run time.
static func _t(key: String) -> String:
	return TranslationServer.translate(key)


## Count-aware row picker: "<KEY>_ONE" when n is exactly 1, "<KEY>" otherwise.
##
## English inflects a noun after a numeral and Turkish does not, so a line like
## "{n} enterprise customers were won" reads "1 enterprise customers" in English on a run
## that signed one. Two ROWS rather than a plural engine — the law wants no grammatical
## machinery around an interpolated value, and a second CSV row is something a translator
## can see. Turkish keeps the same sentence in both rows on purpose.
static func _n(key: String, count: int) -> String:
	return _t(key + "_ONE") if count == 1 else _t(key)
