class_name TermSheetTableSystem
extends RefCounted

# Term Sheet Table engine (Spec 6 / ENDGAME_DESIGN.md §5). Static, pure-logic (VCPitchSystem
# pattern). The push-your-luck negotiation over a granted TermSheet: the founder pushes three
# levers (Valuation / Dilution / Board) against a finite patience pool, each push a visible-odds
# skill check resolved on the dial, until the player SIGNS (Series A Hard Win) or WALKS (+1
# rejection).
#
# TWO state homes (mirrors VCPitchSystem):
#   * The sheet's immutable opening_terms + patience_pool live on the TermSheet (GameState).
#   * The per-SITTING working state (working terms, push counts, remaining patience, selected
#     lever, current state) lives in the static vars below — NEVER serialized. Each open() is a
#     fresh sitting (a deferred sheet re-opens clean; patience is never written back to the sheet).
#
# The scene (TermSheetTableScene) is a humble view: it calls this system and paints the single
# view_state() dict through one _render(). All push/patience/decay/money math lives HERE, so the
# headless smoke suite drives the whole negotiation with no scene mounted.

# --- Seven states (§3). PUSH_RESOLVING is the scene's ~0.8s dial-spin transient; the system
# never rests in it — push() returns the already-settled SUCCESS/FAILURE/PATIENCE_ZERO. ---
enum { IDLE = 1, LEVER_SELECTED, PUSH_RESOLVING, PUSH_SUCCESS, PUSH_FAILURE, PATIENCE_ZERO, SIGN_CONFIRM }

const LEVERS := ["valuation", "dilution", "board"]
## The seed table's rows. Lever one is the MONEY here, not the valuation: a seed round is
## negotiated as "how much, for how much of the company", and the valuation is what falls
## out of those two. At Series A it is the other way round. That inversion is the only
## structural difference between the two tables — everything else is the same object.
const SEED_LEVERS := ["raise", "dilution", "board"]

# --- Table-local sitting state (never serialized) ---
static var _active: bool = false
static var _vc_id: String = ""
static var _terms: Dictionary = {}          # WORKING copy {valuation_m, dilution_pct, board_seats, board_veto}
static var _push_counts: Dictionary = {}    # {valuation, dilution, board} → decay driver
static var _patience: int = 0               # remaining, seeded from sheet.patience_pool each open()
static var _patience_max: int = 0
static var _selected_lever: String = "valuation"
static var _state: int = IDLE
static var _last_push_passed: bool = false
static var _last_lever_acted: String = ""   # the lever the last push touched ("" = none this sitting)
static var _last_move: String = ""          # "$18M → $22M" for the success caption
## Which rung this sitting is, read off the SHEET (TermSheet.stage) rather than handed in.
## The seed offer never expires, so the player can be sent the sheet on day 200 and sit down
## on day 240; a static set during the meeting is long gone by then. Cleared in _reset(),
## and forgetting that would leak a seed sitting's stage into the next Series A table.
static var _stage: String = PitchConstants.STAGE_SERIES_A


## The rows this sitting has. Every loop that used to walk the LEVERS const walks this, and
## that includes the SCENE (term_sheet_table_scene.gd binds a lever id per row at build
## time) — miss it there and the table negotiates a term that is not on the sheet.
static func levers() -> Array:
	return SEED_LEVERS if _stage == PitchConstants.STAGE_SEED else LEVERS


## The sheet this vc_id is sitting at: the seed offer if there is one, else the Series A
## sheet. Seed first because a seed offer and a Series A sheet cannot coexist for one fund
## in a legal run, and if they ever did the earlier rung is the one still unresolved.
static func _sheet_for(vc_id: String) -> TermSheet:
	var seed: TermSheet = VCPitchSystem.seed_sheet_for(vc_id)
	return seed if seed != null else VCPitchSystem.sheet_for(vc_id)


static func is_seed() -> bool:
	return _stage == PitchConstants.STAGE_SEED


static func _dil_step() -> int:
	return SeedConstants.DIL_STEP if is_seed() else PitchConstants.DIL_STEP


static func _dil_floor() -> int:
	return SeedConstants.DIL_MIN if is_seed() else PitchConstants.DIL_FLOOR


static func is_active() -> bool:
	return _active


static func reset() -> void:
	# Run-boundary reset (SaveManager.reset_all_owners) — the public door onto the private
	# _reset() the lifecycle already used. Same contract as the other three sitting-scoped
	# systems: the eleven statics are reset, never serialised, because SaveManager.can_save()
	# refuses while is_active() and a table is therefore provably closed at every save point.
	# The SHEET itself is persistent and lives in GameState.active_sheets, which the save
	# carries; what dies here is the negotiation in progress.
	_reset()


# ============================================================================
# Lifecycle
# ============================================================================

## Seat the player at the table for a live sheet. Seeds the working terms from the sheet's
## opening offer (+ leverage notch), patience from the pool, IDLE state. Returns view_state.
static func open(vc_id: String) -> Dictionary:
	_reset()
	var sheet: TermSheet = _sheet_for(vc_id)
	if sheet == null:
		return {}   # no live sheet — caller shouldn't have routed here
	_active = true
	_vc_id = vc_id
	_stage = String(sheet.stage)
	_terms = sheet.opening_terms.duplicate()
	if _stage == PitchConstants.STAGE_SERIES_A and _leverage_active():
		# Leverage improves the OPENING one notch (§8) — a better valuation to start from.
		# Series A only, and not because seed leverage is unimplemented: there is exactly one
		# seed round per run, so a second seed sheet to hold against this one cannot exist.
		_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + PitchConstants.LEVERAGE_OPEN_NOTCH
	_patience = int(sheet.patience_pool)
	_patience_max = _patience
	_push_counts = {}
	for lever in levers():
		_push_counts[lever] = 0
	_selected_lever = String(levers()[0])
	_state = IDLE
	return view_state()


## Select a lever — pure presentation (S2). No mutation; dial/caption go neutral for the new
## lever. Ignored once pushing is locked (patience zero).
static func select_lever(lever: String) -> Dictionary:
	if not _active or _state == PATIENCE_ZERO:
		return view_state()
	if lever in LEVERS:
		_selected_lever = lever
		_state = LEVER_SELECTED
		_last_lever_acted = ""   # fresh intention → dial rests, caption previews
	return view_state()


## True when the selected lever can still be pushed (patience left, room to improve).
static func can_push(lever: String) -> bool:
	if not _active or _state == PATIENCE_ZERO or _patience <= 0:
		return false
	return not _lever_at_best(lever)


## Resolve the selected lever's push. Returns the SETTLED view_state (S4 success / S5 failure,
## or S6 PATIENCE_ZERO if this drained the last pip). The scene wraps this with the dial spin.
static func push() -> Dictionary:
	if not can_push(_selected_lever):
		return view_state()
	var lever: String = _selected_lever
	var chance: float = odds_for(lever).chance
	var passed: bool = SkillCheck.roll_against(chance)
	_push_counts[lever] = int(_push_counts.get(lever, 0)) + 1   # decay applies on EVERY attempt (decision 9)
	_last_lever_acted = lever
	_last_push_passed = passed
	GameState.run_pushes_attempted += 1
	if passed:
		var before: String = _current_text(lever)
		_apply_push(lever)
		_last_move = "%s → %s" % [before, _current_text(lever)]
		GameState.run_pushes_won += 1
		_state = PUSH_SUCCESS
	else:
		_patience -= 1
		if _patience <= 0:
			_patience = 0
			_state = PATIENCE_ZERO
		else:
			_state = PUSH_FAILURE
	return view_state()


## Sign the current terms → VC seam (fires the Series A Hard Win ending). Ends the sitting.
static func sign() -> void:
	if not _active:
		return
	var vc: String = _vc_id
	var terms: Dictionary = _terms.duplicate()
	var stage: String = _stage
	_reset()
	VCPitchSystem.sign_table(vc, terms, stage)


## Walk the table → VC seam (+1 rejection, sheet destroyed, others survive). Ends the sitting.
static func walk() -> void:
	if not _active:
		return
	# THE SECOND SAFETY behind the locked row (ruling 5). The button is rendered visible and
	# disabled with its reason, exactly as Frank's cheque renders REDDET · ZOR MOD; this is
	# the belt to that pair of braces, so that even a direct call cannot destroy a round the
	# player is not allowed to refuse yet.
	if is_seed():
		push_error("[TermSheetTableSystem] walk() at a seed table — the refusal row is ZOR MOD")
		return
	var vc: String = _vc_id
	_reset()
	VCPitchSystem.walk_table(vc)


## THE INVERSION, and it is the whole shape of the seed table. At Series A the money falls
## out of valuation x dilution; at seed the money IS the lever and the valuation falls out
## of it (implied_post_money below).
static func money_raised() -> int:
	if is_seed():
		return int(_terms.get("raise", 0))
	var val: int = int(_terms.get("valuation_m", 0))
	var dil: int = int(_terms.get("dilution_pct", 0))
	return int(round(val * 1_000_000.0 * dil / 100.0))


## The seed round's implied post-money: raise / dilution. A DERIVED CAPTION, never a lever —
## and the ruling that it cannot be pushed is enforced structurally rather than by a guard,
## because levers() has no row for it. 0 at Series A, where the valuation is a lever.
static func implied_post_money() -> int:
	var dil: int = int(_terms.get("dilution_pct", 0))
	if not is_seed() or dil <= 0:
		return 0
	return int(round(float(money_raised()) * 100.0 / float(dil)))


# ============================================================================
# Odds — skill-split + leverage + per-push decay (§5)
# ============================================================================

## Composed odds for a lever: SkillCheck.breakdown (base + skill + leverage) minus this lever's
## accumulated decay, floor-clamped. Returns {chance, split_text}.
static func odds_for(lever: String) -> Dictionary:
	# The only stage-dependent lines in the whole odds computation. Everything below —
	# SkillCheck.breakdown, the leverage units, the per-lever decay, the floor clamp and the
	# split text — is shared, which is what "the negotiation grammar does not move" means.
	var skill_table: Dictionary = PitchConstants.SEED_LEVER_SKILL if is_seed() \
		else PitchConstants.LEVER_SKILL
	var diff_table: Dictionary = PitchConstants.SEED_LEVER_DIFF if is_seed() \
		else PitchConstants.LEVER_DIFF
	var skill: String = String(skill_table.get(lever, "charisma"))
	var diff: int = int(diff_table.get(lever, 1))
	var lev_units: int = PitchConstants.LEVERAGE_BONUS_UNITS if _leverage_active() else 0
	var bd: Dictionary = SkillCheck.breakdown(skill, diff, lev_units)
	var decay: float = int(_push_counts.get(lever, 0)) * PitchConstants.PUSH_DECAY
	var chance: float = clampf(
		float(bd.base) + float(bd.skill) + float(bd.bonus) - decay,
		PitchConstants.PUSH_ODDS_FLOOR, SkillCheck.MAX_CHANCE)
	return {"chance": chance, "split_text": _split_text(bd, lev_units > 0, decay)}


static func _split_text(bd: Dictionary, leverage: bool, decay: float) -> String:
	var s: String = TranslationServer.translate("TERM_SPLIT_BASE").format({"pct": Fmt.percent(_pct(bd.base), 0)})
	if float(bd.skill) > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_SKILL").format({
			"pct": Fmt.percent(_pct(bd.skill), 0),
			"skill": PitchConstants.skill_label(bd.skill_name)})
	if leverage and float(bd.bonus) > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_LEVERAGE").format({"pct": Fmt.percent(_pct(bd.bonus), 0)})
	if decay > 0.0:
		s += TranslationServer.translate("TERM_SPLIT_DECAY").format({"pct": Fmt.percent(_pct(decay), 0)})
	return s


# ============================================================================
# View state — the single dict _render() consumes (gap-free, §3)
# ============================================================================

static func view_state() -> Dictionary:
	var inv: Dictionary = InvestorRegistry.get_investor(_vc_id)
	var other_vc: String = _other_live_vc()
	var lev_active: bool = other_vc != ""
	var other_name: String = InvestorRegistry.get_investor(other_vc).get("display_name", "") if lev_active else ""
	return {
		"state": _state,
		"vc_id": _vc_id,
		"display_name": inv.get("display_name", ""),
		"archetype_line": InvestorRegistry.archetype_line(_vc_id),
		"portrait_path": inv.get("portrait_path", ""),
		"patience": {"current": _patience, "max": _patience_max},
		"levers": _lever_views(),
		"selected_lever": _selected_lever,
		"dial": _dial_view(),
		"result_caption": _result_caption(),
		"leverage": {
			"active": lev_active,
			"other_vc_name": other_name,
			"box_text": TranslationServer.translate("TERM_LEVERAGE_BOX").format({"investor": other_name}) if lev_active else "",
		},
		"frank_line": _frank_line(lev_active, other_name),
		"money_raised": money_raised(),
		"footer": {
			"kasa_runway_text": _kasa_runway_text(),
			# EMPTY AT SEED. A "0/3 tables closed" counter at a table that cannot close one would
			# tell the player the opposite of ruling 3.
			"counter_text": "" if is_seed() else TranslationServer.translate("TERM_TABLES_CLOSED").format({
				"closed": GameState.vc_rejections, "total": EndingsSystem.CASCADE_TABLES}),
		},
		"sign_enabled": _active,
		"walk_enabled": _active and not is_seed(),
		# LOCKED-VISIBLE, not hidden: the row stays on screen and says why, which is the
		# grammar every other locked door in this game uses.
		"walk_lock": {
			"locked": is_seed() and not bool(GameState.get_flag(AngelRoundSystem.HARD_MODE_FLAG, false)),
			"reason_key": "SEED_WALK_LOCK",
		},
		# The seed table's derived readout. "" at Series A, where the valuation is a lever.
		"derived_caption": TranslationServer.translate("SEED_IMPLIED_POST").format(
			{"post": Fmt.money_exact(implied_post_money())}) if is_seed() else "",
	}


static func _lever_views() -> Array:
	var out: Array = []
	for lever in LEVERS:
		var odds: Dictionary = odds_for(lever)
		out.append({
			"id": lever,
			"name_tr": _lever_name(lever),
			"current_text": _current_text(lever),
			"ghost_text": _ghost_text(lever),
			# More money or a bigger valuation is founder-good; less of the company is too.
			"good_dir": 1 if lever in ["valuation", "raise"] else -1,
			"track_fill": float(odds.chance),
			"odds": odds,
			"push_enabled": can_push(lever),
		})
	return out


static func _dial_view() -> Dictionary:
	# chance = the selected lever's current odds (arc). result colours the resting needle after a
	# push (persists until the next push or a fresh lever selection). The scene animates the spin
	# only on the push() return, since IT initiates the roll.
	var chance: float = odds_for(_selected_lever).chance
	var result: String = ""
	if _last_lever_acted != "":
		result = "success" if _last_push_passed else "failure"
	return {"chance": chance, "result": result}


static func _result_caption() -> String:
	match _state:
		PUSH_SUCCESS:
			return TranslationServer.translate("TERM_RESULT_ACCEPTED").format({"move": _last_move})
		PUSH_FAILURE:
			# COPY-RESTRUCTURED: was "{value}'de kaldı" — a locative suffix on a rendered
			# number ("$18M'de"). The value is terminal now.
			return TranslationServer.translate("TERM_RESULT_REFUSED").format(
				{"value": _current_text(_last_lever_acted)})
		PATIENCE_ZERO:
			return TranslationServer.translate("TERM_RESULT_FINAL")
		_:
			if _lever_at_best(_selected_lever):
				return TranslationServer.translate("TERM_LEVER_MAXED").format({
					"lever": _lever_name(_selected_lever), "value": _current_text(_selected_lever)})
			var od: Dictionary = odds_for(_selected_lever)
			return TranslationServer.translate("TERM_LEVER_ODDS").format({
				"lever": _lever_name(_selected_lever),
				"from": _current_text(_selected_lever),
				"to": _preview_target(_selected_lever),
				"pct": Fmt.percent(_pct(od.chance), 0)})


static func _frank_line(lev_active: bool, other_name: String) -> String:
	# THE SEED TABLE HAS ITS OWN MENTOR SET, and it is not a stylistic preference: the
	# Series A lines below talk about walking to another table (TERM_FRANK_OTHER_TABLE)
	# and about having none left to walk to (TERM_FRANK_NO_TABLE). At seed the refusal row
	# is locked and there is exactly one round, so both sentences would be false — and a
	# mentor describing a door the player cannot use is worse than a silent one.
	if is_seed():
		return _seed_frank_line()
	match _state:
		PUSH_SUCCESS:
			# COPY-RESTRUCTURED: was "{lever}'yi aldın", which needed a declined lever name.
			return TranslationServer.translate("TERM_FRANK_WON").format(
				{"lever": _lever_name(_last_lever_acted)})
		PUSH_FAILURE:
			if _patience <= 1:
				return TranslationServer.translate("TERM_FRANK_LAST_MOVE")
			# COPY-RESTRUCTURED: was "{lever}'de direniyorlar", which needed a declined name.
			return TranslationServer.translate("TERM_FRANK_RESISTED").format(
				{"lever": _lever_name(_last_lever_acted)})
		PATIENCE_ZERO:
			if lev_active:
				return TranslationServer.translate("TERM_FRANK_OTHER_TABLE").format({"investor": other_name})
			return TranslationServer.translate("TERM_FRANK_NO_TABLE")
		IDLE:
			return TranslationServer.translate("TERM_FRANK_OPENING")
		_:
			if _patience <= 1:
				return TranslationServer.translate("TERM_FRANK_LAST_MOVE")
			return TranslationServer.translate("TERM_FRANK_NEXT_MOVE")


# ============================================================================
# Term math
# ============================================================================

static func _apply_push(lever: String) -> void:
	match lever:
		"valuation":
			_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + PitchConstants.VAL_STEP
		"raise":
			# Clamped to the TOP of the band, not left open: a seed raise has a ceiling the way
			# a Series A valuation does not, because the fund sized the round before the meeting.
			_terms["raise"] = mini(
				int(_terms.get("raise", 0)) + SeedConstants.RAISE_STEP, SeedConstants.RAISE_MAX)
		"dilution":
			_terms["dilution_pct"] = maxi(
				int(_terms.get("dilution_pct", 0)) - _dil_step(), _dil_floor())
		"board":
			if bool(_terms.get("board_veto", false)):
				_terms["board_veto"] = false                                   # drop veto first
			else:
				_terms["board_seats"] = maxi(int(_terms.get("board_seats", 0)) - 1, 0)  # then the seat


static func _lever_at_best(lever: String) -> bool:
	match lever:
		"raise":
			return int(_terms.get("raise", 0)) >= SeedConstants.RAISE_MAX
		"dilution":
			return int(_terms.get("dilution_pct", 0)) <= _dil_floor()
		"board":
			return not bool(_terms.get("board_veto", false)) and int(_terms.get("board_seats", 0)) <= 0
		_:
			return false   # valuation has no ceiling


static func _current_text(lever: String) -> String:
	match lever:
		"valuation":
			return "$%dM" % int(_terms.get("valuation_m", 0))
		"raise":
			# EXACT, not abbreviated: the player is moving this in $10K steps and "$0.1M" would
			# hide the whole negotiation.
			return Fmt.money_exact(int(_terms.get("raise", 0)))
		"dilution":
			return Fmt.percent(int(_terms.get("dilution_pct", 0)), 0)
		"board":
			return _board_text(int(_terms.get("board_seats", 0)), bool(_terms.get("board_veto", false)))
	return ""


static func _ghost_text(lever: String) -> String:
	if _lever_at_best(lever):
		return ""
	match lever:
		"valuation":
			return "$%dM" % (int(_terms.get("valuation_m", 0)) + PitchConstants.VAL_STEP)
		"raise":
			return Fmt.money_exact(mini(
				int(_terms.get("raise", 0)) + SeedConstants.RAISE_STEP, SeedConstants.RAISE_MAX))
		"dilution":
			return Fmt.percent(maxi(int(_terms.get("dilution_pct", 0)) - _dil_step(), _dil_floor()), 0)
		"board":
			if bool(_terms.get("board_veto", false)):
				return _board_text(int(_terms.get("board_seats", 0)), false)
			return _board_text(maxi(int(_terms.get("board_seats", 0)) - 1, 0), false)
	return ""


static func _preview_target(lever: String) -> String:
	var g: String = _ghost_text(lever)
	return g if g != "" else _current_text(lever)


static func _board_text(seats: int, veto: bool) -> String:
	if seats <= 0 and not veto:
		return TranslationServer.translate("TERM_BOARD_CLEAN")
	# English needs a singular form; Turkish does not inflect after a numeral, so both of
	# its rows read "{n} koltuk". Two rows, not a plural engine.
	var key: String = "TERM_BOARD_SEAT_ONE" if seats == 1 else "TERM_BOARD_SEATS"
	var s: String = TranslationServer.translate(key).format({"n": seats})
	if veto:
		s += TranslationServer.translate("TERM_BOARD_VETO")
	return s


## The seed room's mentor: patience, the move in front of you, and the one thing he can
## honestly say at the end — that this round gets signed.
static func _seed_frank_line() -> String:
	match _state:
		PUSH_SUCCESS:
			return TranslationServer.translate("SEED_FRANK_WON").format(
				{"lever": _lever_name(_last_lever_acted)})
		PUSH_FAILURE:
			if _patience <= 1:
				return TranslationServer.translate("SEED_FRANK_LAST_MOVE")
			return TranslationServer.translate("SEED_FRANK_RESISTED").format(
				{"lever": _lever_name(_last_lever_acted)})
		PATIENCE_ZERO:
			return TranslationServer.translate("SEED_FRANK_FINAL")
		IDLE:
			return TranslationServer.translate("SEED_FRANK_OPENING")
	if _patience <= 1:
		return TranslationServer.translate("SEED_FRANK_LAST_MOVE")
	return TranslationServer.translate("SEED_FRANK_NEXT_MOVE")


static func _lever_name(lever: String) -> String:
	match lever:
		"valuation": return TranslationServer.translate("FIN_VALUATION")
		# EXPLICIT, and it has to be: the default arm below returns the BOARD label, so a
		# raise row without its own case would render "Board" on row one.
		"raise": return TranslationServer.translate("SEED_LEVER_RAISE")
		"dilution": return TranslationServer.translate("FIN_EQUITY")
		_: return TranslationServer.translate("TERM_LEVER_BOARD")


# _lever_name_acc / _lever_name_loc USED TO LIVE HERE. They held accusative and locative
# spellings of the three lever names, because Turkish case endings follow vowel harmony and
# "Değerleme", "Hisse" and "Board" each take a different one. Both callers were restructured
# so the lever name sits in a terminal slot and needs no ending at all, which is the only
# form that survives translation — English has no case ending to supply.


static func _kasa_runway_text() -> String:
	# GROSS runway in DAYS — deliberate table lens (VC side ignores revenue; the player
	# shell shows NET months). Days-vs-months unit deferred to the curve session.
	var burn: int = maxi(GameState.daily_burn, 1)
	var days: int = int(floor(float(GameState.cash) / float(burn)))
	return TranslationServer.translate("TERM_CASH_RUNWAY").format({
		"cash": UiTokens.format_money(GameState.cash), "days": days})


# ============================================================================
# Leverage helpers (§8)
# ============================================================================

static func _leverage_active() -> bool:
	var sheet: TermSheet = VCPitchSystem.sheet_for(_vc_id)
	if sheet == null:
		return false
	return sheet.is_leverage_active(GameState.active_sheets)


static func _other_live_vc() -> String:
	for sheet in GameState.active_sheets:
		if sheet is TermSheet and sheet.vc_id != _vc_id:
			return sheet.vc_id
	return ""


# ============================================================================
# Utility
# ============================================================================

static func _pct(f: float) -> int:
	return int(round(f * 100.0))


static func _reset() -> void:
	_active = false
	_vc_id = ""
	_terms = {}
	_push_counts = {}
	_patience = 0
	_patience_max = 0
	_selected_lever = "valuation"
	_state = IDLE
	_last_push_passed = false
	_last_lever_acted = ""
	_last_move = ""
	_stage = PitchConstants.STAGE_SERIES_A
