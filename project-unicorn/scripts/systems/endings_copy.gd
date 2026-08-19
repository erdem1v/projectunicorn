class_name EndingsCopy
extends RefCounted

# ============================================================================
# Ending newspaper copy system ("Ekonomi Postası").
# ============================================================================
# The single home for every ending's editorial text, so Erdem's voice pass is one
# read-through. Strings marked `# WORKING` are drafts pending that pass.
#
# WHY a static GDScript file (not JSON / not strings.csv): the lines are grammar-
# ASSEMBLED Turkish — a ledger line enters only if its field is populated, bankruptcy
# branches its whole layout on the phase, and Series A swaps headline sets on the
# signed terms. That is imperative logic JSON cannot express. TR is canonical; EN is
# out of scope for launch content (a later locale pass adds a parallel branch). The
# fixed RAIL chrome (SIRADA NE VAR?, WISHLIST'E EKLE…) lives in ENDING_* CSV keys —
# this file is ONLY the paper prose. Mirrors the EndingsSystem/VCPitchSystem static
# pattern; reads GameState + the ledger, writes nothing.
#
# EDITORIAL RULES (all enforced below): newspaper language not stat language; NO raw
# day count in prose (calendar framing via _span_phrase); NO cash figures / "$" in
# PROSE (origin-aware founding clause) — the stat_cells row is the ONE sanctioned "$"
# surface: it is an infographic, not prose (mockup grammar, 2026-07-29); investment
# figures in prose stay spelled-out ("milyon dolar"); quote attribution goes to the
# CROWD never to one person (no "danışman"/"mentor"); no em-dash, no emoji, no English
# finance terms ("Series A" is a proper noun; stat LABELS may use the ruled loanwords
# already in game vocabulary: MRR, pitch — never ARR).

# --- Tuning / working constants (single surface) ---
const FF_MAX_EQUITY := 18          # Founder-Friendly ceiling (inclusive): equity <= 18 AND no veto
const MIN_LEDGER_LINES := 4
const MAX_LEDGER_LINES := 6
const YEAR_DAYS := 350             # >= → "bir yıla yakın" framing
const OVER_YEAR_DAYS := 380           # "bir yılı aşkın" — a run clearly past its first year
const TWO_YEAR_DAYS := 700            # "iki yıla yakın" — the soft cap's own span (730)
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
			var vs := _common(ending_id, String(ending_data.get("tone", "loss")), ledger, ending_data)
			vs.headline = String(ending_data.get("title", ""))
			vs.subhead = String(ending_data.get("frank_line", ""))
			return vs


# ============================================================================
# Per-ending builders
# ============================================================================

static func _series_a(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("series_a_close", "win", ledger, data)
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
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_SA_CUSTOMERS", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	if int(ledger.get("employees", 0)) > 0:
		pool.append(_t("END_SA_TEAM").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("pitches", 0)) > 1:
		pool.append(_t("END_SA_MANY_TABLES"))

	vs.ledger_lines = _assemble(pool, [_t("END_SA_CLOSER_1"), _t("END_SA_CLOSER_2")])
	# Stat row (mockup: 4 big figures under the photo). Set per template. # WORKING
	vs.stat_cells = [
		_stat(UiTokens.format_money(investment), _t("END_STAT_INVESTMENT")),
		_stat(UiTokens.format_money(valuation * 1_000_000), _t("END_STAT_VALUATION")),
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
		_stat(_pct(_founder_share(ledger)), _t("END_STAT_FOUNDER_SHARE")),
	]
	return vs


static func _acquisition(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("acquisition", "soft_win", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_ACQ_HEAD").format({"company": company})
	vs.subhead = _t("END_ACQ_SUB")
	vs.engraving_caption = _t("END_ACQ_CAP")

	var pool: Array = []
	pool.append(_t("END_ACQ_NEW_ROOF").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_ACQ_BOOK", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	if int(ledger.get("employees", 0)) > 0:
		pool.append(_t("END_ACQ_CORE").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_ACQ_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	if int(ledger.get("vc_rejections", 0)) > 0:
		pool.append(_t("END_ACQ_DOORS"))

	vs.ledger_lines = _assemble(pool, [_t("END_ACQ_CLOSER_1"), _t("END_ACQ_CLOSER_2")])
	# No sale price exists in the ledger — survival/team figures instead. # WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), _t("END_STAT_MONTHS_ALIVE")),
		_stat(str(int(ledger.get("customers_signed", 0))), _t("END_STAT_CUSTOMERS")),
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_MRR")),
	]
	return vs


static func _bankruptcy(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var phase := int(ledger.get("phase", 1))
	var vs := _common("bankruptcy", "loss", ledger, data)
	var company := _company(data)

	if phase <= 1:
		return _bankruptcy_quiet(ledger, data, vs)

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
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_BK_LEFT_BEHIND", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	if int(ledger.get("customers_lost", 0)) > 0:
		pool.append(_n("END_BK_LOST", int(ledger.get("customers_lost", 0))).format(
			{"n": int(ledger.get("customers_lost", 0))}))
	if int(ledger.get("hires", 0)) > 0:
		# departures reads 0 today — frame on hires, never a "1 resignation" line.
		pool.append(_t("END_BK_TEAM_SCATTERED"))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_BK_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	if phase == 3 and int(ledger.get("pitches", 0)) > 0:
		pool.append(_t("END_BK_NO_SIGNATURE"))

	vs.ledger_lines = _assemble(pool, [_t("END_BK_CLOSER_1"), _t("END_BK_CLOSER_2")])
	# Faz 2-3 only (the quiet faz-1 path returned above with no stat row). "$0" SON MRR
	# is editorially correct on a bankruptcy paper. # WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), _t("END_STAT_MONTHS_ALIVE")),
		_stat(str(int(ledger.get("customers_signed", 0))), _t("END_STAT_CUSTOMERS")),
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_LAST_MRR")),
	]
	return vs


static func _bankruptcy_quiet(ledger: Dictionary, data: Dictionary, vs: Dictionary) -> Dictionary:
	# Faz-1 "iz bırakmadan": a generic sector story runs the masthead; the player's
	# closure is a small below-the-fold notice. No engraving, no ledger box.
	var company := _company(data)
	vs.variant = "phase1_quiet"
	vs.is_quiet_closure = true
	vs.is_generic_masthead = true
	vs.engraving_path = ""
	vs.engraving_caption = ""
	vs.ledger_lines = []
	var idx: int = abs(hash(company)) % GENERIC_HEADLINE_COUNT
	vs.headline = _t("END_GENERIC_HEAD_%d" % idx)
	vs.subhead = _t("END_GENERIC_SUB_%d" % idx)
	vs.quiet_notice = _t("END_BK1_NOTICE").format({"company": company})
	return vs


static func _brand_collapse(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("brand_collapse", "loss", ledger, data)
	var company := _company(data)
	# COPY-RESTRUCTURED: was "{company}'i Devirdi" — an accusative suffix on the company
	# NAME, and the right ending depends on how the name sounds.
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
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_LAST_MRR")),
	]
	return vs


static func _vc_cascade(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("vc_rejection_cascade", "loss", ledger, data)
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
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_VC_CUSTOMERS", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	pool.append(_t("END_VC_NO_MOMENTUM"))

	vs.ledger_lines = _assemble(pool, [_t("END_VC_CLOSER_1"), _t("END_VC_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_stat(str(int(ledger.get("vc_rejections", 0))), _t("END_STAT_REJECTIONS")),
		_stat(str(int(ledger.get("pitches", 0))), _t("END_STAT_PITCHES")),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_MRR")),
		_stat(_months_figure(_day(ledger)), _t("END_STAT_MONTHS_ALIVE")),
	]
	return vs


static func _bootstrap(ledger: Dictionary, data: Dictionary) -> Dictionary:
	var vs := _common("profitable_bootstrap", "win", ledger, data)
	var company := _company(data)
	vs.headline = _t("END_BS_HEAD").format({"company": company})
	vs.subhead = _t("END_BS_SUB")
	vs.engraving_caption = _t("END_BS_CAP")

	var pool: Array = []
	pool.append(_t("END_BS_OWN_FEET").format(
		{"founding": _founding_clause(ledger), "span": _span_phrase(_day(ledger))}))
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_BS_BALANCED", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	if int(ledger.get("hires", 0)) > 0:
		pool.append(_t("END_BS_PAYROLL").format({"n": _num(int(ledger.get("employees", 0)))}))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_BS_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))
	# Calibration Round A §9: the win is a streak of Artıda months now; the paper names it.
	if int(ledger.get("profit_streak", 0)) > 0:
		pool.append(_t("END_BS_STREAK").format({"n": _num(int(ledger.get("profit_streak", 0)))}))
	else:
		pool.append(_t("END_BS_COVERS_COSTS"))

	vs.ledger_lines = _assemble(pool, [_t("END_BS_CLOSER_1"), _t("END_BS_CLOSER_2")])
	# _founder_share reads 100 here — no signed terms on a bootstrap run. # WORKING
	vs.stat_cells = [
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_MRR")),
		_stat(str(int(ledger.get("customers_active", 0))), _t("END_STAT_CUSTOMERS")),
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
		_stat(_pct(_founder_share(ledger)), _t("END_STAT_FOUNDER_SHARE")),
	]
	return vs


static func _fumes(ledger: Dictionary, data: Dictionary) -> Dictionary:
	# THE SOFT CAP's paper (Calibration Round A §2, director ruling via Y5.6: the id stays
	# running_on_fumes; the register is "yatırımcılar ilgisini kaybetti" — a company that
	# reached no goal ending inside the window investors give it. Not a failure screen:
	# the company did not close, it dropped off the agenda. Frank's verdict line is the
	# Y5.6 text (END_META_RUNNING_ON_FUMES_FRANK).
	var vs := _common("running_on_fumes", "soft_loss", ledger, data)
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
	# Ledger 16: an unsigned offer left on the table is named, never silently dropped.
	if int(ledger.get("unsigned_sheets", 0)) > 0:
		pool.append(_t("END_RF_UNSIGNED_SHEET"))
	if int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_n("END_RF_UNFINISHED", int(ledger.get("customers_signed", 0))).format(
			{"n": int(ledger.get("customers_signed", 0))}))
	if int(ledger.get("hires", 0)) > 0:
		pool.append(_t("END_RF_TEAM_STAYED"))
	# Bu satır KOŞULSUZDU: sıfır gelirli bir run'da bile "Gelir vardı" diyordu — üstelik
	# hemen yanında MRR $0 yazan istatistik hücresiyle aynı ekranda, ve _assemble havuzu
	# MIN_LEDGER_LINES'a tamamladığı için o yalan GARANTİLİ basılıyordu. Demo'nun dönüşüm
	# ekranı burası.
	# ELSE şart: satırı yalnızca koşullamak havuzu en kötü durumda 1 satır + 2 yedek = 3'e
	# düşürür ve gazete eksik dizilirdi. Her iki dal da tam bir satır ekler.
	if int(ledger.get("mrr", 0)) > 0 or int(ledger.get("customers_signed", 0)) > 0:
		pool.append(_t("END_RF_REVENUE_SOME"))
	else:
		pool.append(_t("END_RF_REVENUE_NONE"))
	if int(ledger.get("product_ships", 0)) > 1:
		pool.append(_t("END_RF_SHIPS").format({"n": int(ledger.get("product_ships", 0))}))

	vs.ledger_lines = _assemble(pool, [_t("END_RF_CLOSER_1"), _t("END_RF_CLOSER_2")])
	# WORKING
	vs.stat_cells = [
		_stat(_months_figure(_day(ledger)), _t("END_STAT_MONTHS_ALIVE")),
		_stat(UiTokens.format_money(int(ledger.get("mrr", 0))), _t("END_STAT_MRR")),
		_stat(str(int(ledger.get("customers_active", 0))), _t("END_STAT_CUSTOMERS")),
		_stat(str(int(ledger.get("employees", 0))), _t("END_STAT_EMPLOYEES")),
	]
	return vs


# ============================================================================
# Assembly helpers (all pure)
# ============================================================================

static func _common(ending_id: String, tone: String, ledger: Dictionary, data: Dictionary) -> Dictionary:
	var company := _company(data)
	return {
		"ending_id": ending_id,
		"tone": tone,
		"is_win": tone == "win" or tone == "soft_win",
		"variant": "",
		"masthead": _t("WORLD_OUTLET_EKONOMI_CAPS"),
		"date_line": _date_line(ledger),
		"headline": "",
		"subhead": "",
		"engraving_path": _engraving_path(ending_id, ledger),
		"engraving_caption": "",
		"ledger_title": _t("END_LEDGER_TITLE").format({"company": _tr_upper(company)}),
		"ledger_lines": [],
		"stat_cells": [],
		"is_quiet_closure": false,
		"is_generic_masthead": false,
		"quiet_notice": "",
	}


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
	# One stat-row cell: a big serif FIGURE over a small mono LABEL (mockup grammar).
	# Labels arrive pre-uppercased TR literals — tr_upper is only for derived text.
	return {"figure": figure, "label": label}


static func _months_figure(days: int) -> String:
	# Stat-row month count as DIGITS — the infographic surface, unlike _span_phrase
	# which frames the same span as prose (Rule 2 keeps raw day counts off the paper).
	return str(int(ceil(days / 30.0)))


static func _pct(n: int) -> String:
	# Percent SIDE is a locale property, not a mockup one: TR "%82", EN "82%".
	return Fmt.percent(n, 0)


static func _founder_share(ledger: Dictionary) -> int:
	# Founder's remaining share after the signed round; run_equity_pct reads 0 unless a
	# term sheet was signed (bootstrap → 100). NOT GameState.get_founder_equity(): hires
	# carry no equity and the investor's dilution never enters CharacterRegistry, so that
	# read would say 100 on the very paper whose headline announces the round.
	# investor_equity_pct, not equity_pct: the founder really does own Frank's 4% less,
	# even though the newspaper's valuation sentence stays about the Series A alone.
	# Falls back to the Series-A field so an older ledger dict still reads correctly.
	return maxi(0, 100 - int(ledger.get("investor_equity_pct", ledger.get("equity_pct", 0))))


static func _span_phrase(days: int) -> String:
	# Rule 2: the paper never prints a raw day count — it frames time in calendar months.
	# Goal-terminated runs reach two years (soft cap 730): two longer spans were added
	# 2026-08-19 so a 24-month run is not described as "close to a year".
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
			return _t("END_FOUNDING_MONTH").format({"month": _founding_month(ledger)})


static func _founding_month(ledger: Dictionary) -> String:
	return Fmt.month_name(clampi(int(ledger.get("start_month", 1)), 1, 12))


static func _date_line(ledger: Dictionary) -> String:
	# Masthead meta line: full calendar date + issue number ("14 KASIM 2027 · SAYI 214").
	# A date and an edition, never a day count — the raw count lives ONLY in the rail's
	# run-meta line (Rule 2). Ledger-driven (not GameState.day) so debug_all_view_states
	# renders deterministically. MONTH_NAMES_TR is already correct Turkish uppercase.
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
	# for headline-style figures (mockup: "4 milyon dolar").
	var m := int(round(dollars / 1_000_000.0))
	if m < 1:
		m = 1
	return _t("END_MILLIONS").format({"n": m})


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


static func _tr_upper(s: String) -> String:
	# Turkish-safe uppercase for the ledger title — delegates to the single home
	# UiTokens.tr_upper ("PromptPilot" → "PROMPTPİLOT"; 2026-07-21 sweep addendum).
	return UiTokens.tr_upper(s)


# ============================================================================
# Debug — full copy matrix for the voice/layout gallery (no game states needed)
# ============================================================================

static func debug_all_view_states() -> Array:
	# Every template + variant against ONE synthetic rich ledger, so Erdem can voice-pass
	# and layout-check the whole surface at once. Each entry: {label, vs}.
	var ledger := {
		"day": 156, "phase": 3, "origin": "self_made", "start_month": 1, "start_year": 2026,
		"cash": 24000, "mrr": 6400, "peak_mrr": 8200, "brand": 30, "reputation": 10,
		"customers_active": 6, "customers_signed": 9, "customers_lost": 3, "customers_expanded": 2,
		"employees": 5, "hires": 4, "departures": 0,
		"product_version": 3, "product_ships": 3,
		"pitches": 2, "sheets_won": 1, "vc_rejections": 1, "pushes_attempted": 2, "pushes_won": 1,
		"investment_amount": 3_960_000, "valuation_m": 22, "equity_pct": 18, "board_seats": 1, "board_veto": false,
		"scandals_total": 1, "scandals_managed": 0,
	}
	var data := {"company_name": "PromptPilot", "founder_name": "Deniz", "tone": "loss"}   # LOC-DATA shot fixture
	var out: Array = []
	out.append({"label": "series_a · founder_friendly", "vs": build("series_a_close", ledger, data)})   # LOC-DATA debug label
	var agg := ledger.duplicate(); agg.equity_pct = 32; agg.board_veto = true; agg.board_seats = 2
	out.append({"label": "series_a · aggressive", "vs": build("series_a_close", agg, data)})   # LOC-DATA debug label
	out.append({"label": "acquisition", "vs": build("acquisition", ledger, data)})
	for p in [1, 2, 3]:
		var bl := ledger.duplicate(); bl.phase = p
		out.append({"label": "bankruptcy · faz %d" % p, "vs": build("bankruptcy", bl, data)})   # LOC-DATA debug label
	out.append({"label": "brand_collapse", "vs": build("brand_collapse", ledger, data)})
	out.append({"label": "vc_rejection_cascade", "vs": build("vc_rejection_cascade", ledger, data)})
	out.append({"label": "profitable_bootstrap", "vs": build("profitable_bootstrap", ledger, data)})
	for p in [1, 2, 3]:
		var fl := ledger.duplicate(); fl.phase = p
		out.append({"label": "running_on_fumes · faz %d" % p, "vs": build("running_on_fumes", fl, data)})   # LOC-DATA debug label
	return out


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
