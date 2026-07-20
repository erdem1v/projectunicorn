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


static func is_active() -> bool:
	return _active


# ============================================================================
# Lifecycle
# ============================================================================

## Seat the player at the table for a live sheet. Seeds the working terms from the sheet's
## opening offer (+ leverage notch), patience from the pool, IDLE state. Returns view_state.
static func open(vc_id: String) -> Dictionary:
	_reset()
	var sheet: TermSheet = VCPitchSystem.sheet_for(vc_id)
	if sheet == null:
		return {}   # no live sheet — caller shouldn't have routed here
	_active = true
	_vc_id = vc_id
	_terms = sheet.opening_terms.duplicate()
	if _leverage_active():
		# Leverage improves the OPENING one notch (§8) — a better valuation to start from.
		_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + PitchConstants.LEVERAGE_OPEN_NOTCH
	_patience = int(sheet.patience_pool)
	_patience_max = _patience
	_push_counts = {"valuation": 0, "dilution": 0, "board": 0}
	_selected_lever = "valuation"
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
	_reset()
	VCPitchSystem.sign_table(vc, terms)


## Walk the table → VC seam (+1 rejection, sheet destroyed, others survive). Ends the sitting.
static func walk() -> void:
	if not _active:
		return
	var vc: String = _vc_id
	_reset()
	VCPitchSystem.walk_table(vc)


static func money_raised() -> int:
	var val: int = int(_terms.get("valuation_m", 0))
	var dil: int = int(_terms.get("dilution_pct", 0))
	return int(round(val * 1_000_000.0 * dil / 100.0))


# ============================================================================
# Odds — skill-split + leverage + per-push decay (§5)
# ============================================================================

## Composed odds for a lever: SkillCheck.breakdown (base + skill + leverage) minus this lever's
## accumulated decay, floor-clamped. Returns {chance, split_text}.
static func odds_for(lever: String) -> Dictionary:
	var skill: String = PitchConstants.LEVER_SKILL[lever]
	var diff: int = int(PitchConstants.LEVER_DIFF[lever])
	var lev_units: int = PitchConstants.LEVERAGE_BONUS_UNITS if _leverage_active() else 0
	var bd: Dictionary = SkillCheck.breakdown(skill, diff, lev_units)
	var decay: float = int(_push_counts.get(lever, 0)) * PitchConstants.PUSH_DECAY
	var chance: float = clampf(
		float(bd.base) + float(bd.skill) + float(bd.bonus) - decay,
		PitchConstants.PUSH_ODDS_FLOOR, SkillCheck.MAX_CHANCE)
	return {"chance": chance, "split_text": _split_text(bd, lev_units > 0, decay)}


static func _split_text(bd: Dictionary, leverage: bool, decay: float) -> String:
	var s: String = "temel %%%d" % _pct(bd.base)
	if float(bd.skill) > 0.0:
		s += " · +%%%d %s" % [_pct(bd.skill), PitchConstants.skill_label(bd.skill_name)]
	if leverage and float(bd.bonus) > 0.0:
		s += " · +%%%d kaldıraç" % _pct(bd.bonus)
	if decay > 0.0:
		s += " · −%%%d tekrar" % _pct(decay)
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
		"archetype_line": inv.get("archetype_line", ""),
		"portrait_path": inv.get("portrait_path", ""),
		"patience": {"current": _patience, "max": _patience_max},
		"levers": _lever_views(),
		"selected_lever": _selected_lever,
		"dial": _dial_view(),
		"result_caption": _result_caption(),
		"leverage": {
			"active": lev_active,
			"other_vc_name": other_name,
			"box_text": ("Cebinde 2. term sheet var — %s. Bunu onlar da biliyor." % other_name) if lev_active else "",
		},
		"frank_line": _frank_line(lev_active, other_name),
		"money_raised": money_raised(),
		"footer": {
			"kasa_runway_text": _kasa_runway_text(),
			"counter_text": "Kapanan masa: %d/%d" % [GameState.vc_rejections, EndingsSystem.CASCADE_TABLES],
		},
		"sign_enabled": _active,
		"walk_enabled": _active,
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
			"good_dir": 1 if lever == "valuation" else -1,   # arrow toward the founder-good end
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
			return "Kabul ettiler. %s." % _last_move
		PUSH_FAILURE:
			return "Reddettiler. %s'de kaldı." % _current_text(_last_lever_acted)
		PATIENCE_ZERO:
			return "Son teklifim bu. İmzala, ya da masadan kalk."
		_:
			if _lever_at_best(_selected_lever):
				return "%s: %s · itilecek yer yok." % [_lever_name(_selected_lever), _current_text(_selected_lever)]
			var od: Dictionary = odds_for(_selected_lever)
			return "%s: %s → %s · %%%d" % [
				_lever_name(_selected_lever), _current_text(_selected_lever),
				_preview_target(_selected_lever), _pct(od.chance)]


static func _frank_line(lev_active: bool, other_name: String) -> String:
	match _state:
		PUSH_SUCCESS:
			return "%s aldın. İyi. Şimdi dur, ya da başka bir kaldıraca bas. Sabırları sonsuz değil." % _lever_name_acc(_last_lever_acted)
		PUSH_FAILURE:
			if _patience <= 1:
				return "Gerginleşiyorlar. Bir hamlen kaldı. Dikkatli seç."
			return "Olmadı. %s direniyorlar. Israr etme, başka yere geç." % _lever_name_loc(_last_lever_acted)
		PATIENCE_ZERO:
			if lev_active:
				return "Masada bir teklifin daha var — %s. Kalk, değerlendir, sonra dön." % other_name
			return "Başka masan yok. Bu teklif, ya da hiçbir şey."
		IDLE:
			return "İlk teklifleri bu. İlk teklif hiçbir zaman son teklif değildir. Zorla."
		_:
			if _patience <= 1:
				return "Gerginleşiyorlar. Bir hamlen kaldı. Dikkatli seç."
			return "Sıradaki hamleni seç. Sabırları sonsuz değil."


# ============================================================================
# Term math
# ============================================================================

static func _apply_push(lever: String) -> void:
	match lever:
		"valuation":
			_terms["valuation_m"] = int(_terms.get("valuation_m", 0)) + PitchConstants.VAL_STEP
		"dilution":
			_terms["dilution_pct"] = maxi(
				int(_terms.get("dilution_pct", 0)) - PitchConstants.DIL_STEP, PitchConstants.DIL_FLOOR)
		"board":
			if bool(_terms.get("board_veto", false)):
				_terms["board_veto"] = false                                   # drop veto first
			else:
				_terms["board_seats"] = maxi(int(_terms.get("board_seats", 0)) - 1, 0)  # then the seat


static func _lever_at_best(lever: String) -> bool:
	match lever:
		"dilution":
			return int(_terms.get("dilution_pct", 0)) <= PitchConstants.DIL_FLOOR
		"board":
			return not bool(_terms.get("board_veto", false)) and int(_terms.get("board_seats", 0)) <= 0
		_:
			return false   # valuation has no ceiling


static func _current_text(lever: String) -> String:
	match lever:
		"valuation":
			return "$%dM" % int(_terms.get("valuation_m", 0))
		"dilution":
			return "%%%d" % int(_terms.get("dilution_pct", 0))
		"board":
			return _board_text(int(_terms.get("board_seats", 0)), bool(_terms.get("board_veto", false)))
	return ""


static func _ghost_text(lever: String) -> String:
	if _lever_at_best(lever):
		return ""
	match lever:
		"valuation":
			return "$%dM" % (int(_terms.get("valuation_m", 0)) + PitchConstants.VAL_STEP)
		"dilution":
			return "%%%d" % maxi(int(_terms.get("dilution_pct", 0)) - PitchConstants.DIL_STEP, PitchConstants.DIL_FLOOR)
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
		return "temiz"
	var s: String = "%d koltuk" % seats
	if veto:
		s += " + veto"
	return s


static func _lever_name(lever: String) -> String:
	match lever:
		"valuation": return "Değerleme"
		"dilution": return "Hisse"
		_: return "Board"


static func _lever_name_acc(lever: String) -> String:
	# Accusative form for Frank's "%s aldın" line — the Turkish suffix follows vowel
	# harmony per lever name, so one shared "'ı" template can't fit all three.
	match lever:
		"valuation": return "Değerleme'yi"
		"dilution": return "Hisse'yi"
		_: return "Board'u"


static func _lever_name_loc(lever: String) -> String:
	# Locative form for Frank's "%s direniyorlar" line (see _lever_name_acc note).
	match lever:
		"valuation": return "Değerleme'de"
		"dilution": return "Hisse'de"
		_: return "Board'da"


static func _kasa_runway_text() -> String:
	# GROSS runway in DAYS — deliberate table lens (VC side ignores revenue; the player
	# shell shows NET months). Days-vs-months unit deferred to the curve session.
	var burn: int = maxi(GameState.daily_burn, 1)
	var days: int = int(floor(float(GameState.cash) / float(burn)))
	return "Kasa: %s · Runway: %d gün" % [UiTokens.format_money(GameState.cash), days]


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
