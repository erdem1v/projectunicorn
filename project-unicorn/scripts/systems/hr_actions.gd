class_name HRActions
extends RefCounted

# The employee-card actions: ZAM YAP (§9.2), TERFİ ETTİR (§9.3), İŞTEN ÇIKAR (§11.1/§11.2).
# Player-triggered only, never ticked: every consequence is applied by the system that owns it.
#
# Each action is a trio — can_* (validation), preview_* (exactly what the confirm card prints),
# and the applier — so the number on the card is the number the action produces.
#
# FRANK VE KURUCU DOKUNULMAZ: every entry point checks category == "employee" on the Character
# the UI hands over, not trusting the caller's filters.
#
# Write-through: the salary goes through CharacterRegistry.set_salary and reaches burn via
# Finance's daily payroll PULL (no push, no signal needed); severance through
# FinanceSystem.apply_one_time_cost; morale through HRMoraleSystem.apply_delta; removal through
# CharacterRegistry.remove.


# ============================== §9.2 ZAM ====================================

static func can_raise(emp: Character, pct: int) -> bool:
	# `pct` is CLAMPED rather than rejected, so the slider never produces a refusal the player
	# cannot understand. Refusing a raise that rounds to nothing here lets apply_raise trust
	# that true means a real rise.
	if _block_reason(emp) != "" or emp.monthly_salary <= 0:
		return false
	# §9.2: "Aynı çalışana ALTI AY geçmeden yeni zam verilemez."
	if raise_cooldown_left(emp) > 0:
		return false
	return _raised_salary(emp.monthly_salary, _clamp_pct(pct)) > emp.monthly_salary


## §9.2 bekleme süresinden KALAN gün. 0 = zam verilebilir.
static func raise_cooldown_left(emp: Character) -> int:
	if emp == null or emp.last_raise_day <= 0:
		return 0
	return maxi(HRConstants.RAISE_COOLDOWN_DAYS - (GameState.day - emp.last_raise_day), 0)


static func preview_raise(emp: Character, pct: int) -> Dictionary:
	var reason: String = _block_reason(emp)
	if reason == "" and emp.monthly_salary <= 0:
		reason = TranslationServer.translate("HR_ERR_NO_SALARY")
	if reason != "":
		return _refusal(reason)
	var p: int = _clamp_pct(pct)
	var before: int = emp.monthly_salary
	var after: int = _raised_salary(before, p)
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	# The morale apply_delta will really write (traits + Liderlik iklimi + tavan), so the card
	# cannot over-promise.
	var gain: int = HRMoraleSystem.scaled_delta(emp, HRConstants.raise_morale_gain(p))
	return {
		"ok": true,
		"reason": "",
		"pct": p,
		"salary_after": after,
		"morale_after": emp.morale + gain,
		"rows": [
			_salary_row(before, after),
			_delta(TranslationServer.translate("HR_ROW_MORALE"), str(emp.morale), str(emp.morale + gain)),
			_delta(TranslationServer.translate("HR_ROW_PAYROLL"), _money(payroll), _money(payroll + after - before)),
			_rule(TranslationServer.translate("HR_RAISE_PERMANENT")),
		],
	}


static func apply_raise(emp: Character, pct: int) -> bool:
	if not can_raise(emp, pct):
		_refuse_loudly(emp, "apply_raise")
		return false
	var p: int = _clamp_pct(pct)
	var before: int = emp.monthly_salary
	var after: int = _raised_salary(before, p)
	CharacterRegistry.set_salary(emp.id, after)
	# §9.1 "Maaş hiçbir koşulda düşürülemez" — kuralı taşıyan alan da yükselir.
	emp.salary_floor = maxi(emp.salary_floor, after)
	emp.last_raise_day = GameState.day
	emp.employment_history.append({
		"day": GameState.day, "kind": "raise", "old": before, "new": after,
	})
	HRMoraleSystem.apply_delta(emp, HRConstants.raise_morale_gain(p), HRConstants.REASON_RAISE)
	return true


# ============================== §9.3 TERFİ ==================================
# Terfi TEK ADIMLIK bir seviye atlamasıdır ve Kıdemli tavandır. Maaş yeni seviyenin bandına
# oturmaz, yalnız seçilen oranda artar: içeriden terfi dışarıdan almaktan ucuzdur ve oyuncuya
# gerçek bir "yetiştir mi, satın al mı" kararı veren bu farktır.

static func can_promote(emp: Character) -> bool:
	return promotion_block_reason(emp) == ""


## Kilitli satırın gerekçesi (§13.3: "Kilitli olan görünür kalır ve gerekçesini gösterir").
static func promotion_block_reason(emp: Character) -> String:
	var shared: String = _block_reason(emp)
	if shared != "":
		return shared
	if emp.level >= HRConstants.LEVEL_SENIOR:
		return TranslationServer.translate("HR_ERR_TOP_LEVEL")
	return ""


static func preview_promotion(emp: Character, pct: int) -> Dictionary:
	var reason: String = promotion_block_reason(emp)
	if reason != "":
		return _refusal(reason)
	var p: int = _clamp_promotion_pct(pct)
	var before: int = emp.monthly_salary
	var after: int = _raised_salary(before, p)
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	var gain: int = HRMoraleSystem.scaled_delta(emp, HRConstants.promotion_morale_gain(p))
	return {
		"ok": true,
		"reason": "",
		"pct": p,
		"rows": [
			_delta(TranslationServer.translate("HR_ROW_TITLE"),
				HRConstants.job_title(emp.role, emp.level),
				HRConstants.job_title(emp.role, emp.level + 1)),
			_salary_row(before, after),
			_delta(TranslationServer.translate("HR_ROW_MORALE"), str(emp.morale), str(emp.morale + gain)),
			_delta(TranslationServer.translate("HR_ROW_PAYROLL"), _money(payroll), _money(payroll - before + after)),
			_rule(TranslationServer.translate("HR_PROMOTION_PERMANENT")),
		],
	}


static func apply_promotion(emp: Character, pct: int) -> bool:
	if not can_promote(emp):
		_refuse_loudly(emp, "apply_promotion")
		return false
	var p: int = _clamp_promotion_pct(pct)
	var before_level: int = emp.level
	var after_salary: int = _raised_salary(emp.monthly_salary, p)
	emp.level = before_level + 1
	CharacterRegistry.set_salary(emp.id, after_salary)
	emp.salary_floor = maxi(emp.salary_floor, after_salary)
	emp.last_promotion_day = GameState.day
	# Terfi bir zammı içerir; §9.2'nin bekleme süresi de kurulur, yoksa ertesi gün üstüne
	# ayrı bir zam almak bekleme süresini anlamsız kılardı.
	emp.last_raise_day = GameState.day
	emp.employment_history.append({
		"day": GameState.day, "kind": "promotion", "old": before_level, "new": emp.level,
	})
	HRMoraleSystem.apply_delta(emp, HRConstants.promotion_morale_gain(p), HRConstants.REASON_RAISE)
	EventBus.employee_promoted.emit(emp.id, emp.level)
	return true


# ============================== İŞTEN ÇIKAR ================================

static func can_fire(emp: Character) -> bool:
	# Deliberately NOT gated on affordability: severance may push cash negative like any
	# other one-time cost. The preview carries the number; the decision is the player's.
	return _block_reason(emp) == ""


static func preview_fire(emp: Character) -> Dictionary:
	var reason: String = _block_reason(emp)
	if reason != "":
		return _refusal(reason)
	var days_served: int = maxi(GameState.day - emp.hire_day, 0)
	# The note's months and the charged amount come from the same rule (§15.2).
	var multiple: float = HRConstants.severance_multiple(days_served)
	var severance: int = HRConstants.severance_amount(emp.monthly_salary, days_served)
	var payroll: int = CharacterRegistry.get_total_monthly_salaries()
	var cash_after: int = GameState.cash - severance
	return {
		"ok": true,
		"reason": "",
		"severance": severance,
		"cash_after": cash_after,
		"rows": [
			# OLGU: tazminatın "önce"si yok; ok bir geçiş iddiası olurdu.
			_fact(HRConstants.cost_label_severance(), _money(severance),
				TranslationServer.translate("HR_ROW_MONTHS_NOTE").format({
					"months": Fmt.number(multiple, 1)})),
			# `negative_after` lets the UI flag a negative balance without parsing formatted text.
			_delta(TranslationServer.translate("HR_ROW_CASH"), _money(GameState.cash),
				_money(cash_after), "", cash_after < 0),
			_delta(TranslationServer.translate("HR_ROW_PAYROLL"), _money(payroll), _money(payroll - emp.monthly_salary)),
			_fact(TranslationServer.translate("HR_ROW_TEAM_MORALE"), str(-HRConstants.MORALE_FIRE_TEAM)),
		],
	}


static func fire(emp: Character) -> bool:
	if not can_fire(emp):
		_refuse_loudly(emp, "fire")
		return false
	var days_served: int = maxi(GameState.day - emp.hire_day, 0)
	# Charged before the removal so the ledger line and the roster change cannot come apart.
	FinanceSystem.apply_one_time_cost(
		HRConstants.severance_amount(emp.monthly_salary, days_served), "severance")
	# get_employees(), not the active list: someone on leave hears about it too.
	for other in CharacterRegistry.get_employees():
		if other.id != emp.id:
			HRMoraleSystem.apply_delta(other, -HRConstants.MORALE_FIRE_TEAM, HRConstants.REASON_TEAMMATE_FIRED)
	# Drop the HR-side latches while the id still means something.
	HRMoraleSystem.forget_employee(emp.id)
	CharacterRegistry.remove(emp.id)
	return true


# ============================== Internals ===================================

static func _block_reason(emp: Character) -> String:
	# The refusals every action shares, as a printable reason so preview_* can say WHY.
	if emp == null:
		return TranslationServer.translate("HR_ERR_NO_RECORD")
	if emp.category != "employee":
		return TranslationServer.translate("HR_ERR_EMPLOYEES_ONLY")
	if CharacterRegistry.get_character(emp.id) == null:
		# A double-clicked confirm still holds a live reference to someone already removed;
		# without this a second fire() would charge severance twice.
		return TranslationServer.translate("HR_ERR_NO_RECORD")
	if HRMoraleSystem.has_pending_departure(emp.id):
		return TranslationServer.translate("HR_ERR_LEAVING")
	return ""


static func _refuse_loudly(emp: Character, where: String) -> void:
	# A can_* returning false is normal (the button is greyed out); an APPLIER reached with a
	# non-employee is a wiring bug, so it screams.
	if emp != null and emp.category != "employee":
		push_error("[HRActions] %s refused for '%s' (category '%s') — the founder and the mentor are never targets" % [where, emp.id, emp.category])


static func _refusal(reason: String) -> Dictionary:
	# Same spine as a successful preview so the UI binds one card to both.
	return {"ok": false, "reason": reason, "rows": [_rule(reason)]}


static func _clamp_pct(pct: int) -> int:
	return clampi(pct, HRConstants.RAISE_MIN_PCT, HRConstants.RAISE_MAX_PCT)


static func _clamp_promotion_pct(pct: int) -> int:
	return clampi(pct, HRConstants.PROMOTION_MIN_PCT, HRConstants.PROMOTION_MAX_PCT)


static func _raised_salary(monthly_salary: int, pct: int) -> int:
	return int(round(float(monthly_salary) * (1.0 + pct / 100.0)))


# --- Kayıt kurucuları: delta (önce → sonra), fact (tek rakam), rule (sayısız kural) ---

static func _delta(label: String, before: String, after: String, note: String = "",
		negative_after: bool = false) -> Dictionary:
	return {"kind": "delta", "label": label, "before": before, "after": after,
		"note": note, "negative_after": negative_after}


static func _fact(label: String, value: String, note: String = "") -> Dictionary:
	return {"kind": "fact", "label": label, "value": value, "note": note}


static func _rule(text: String) -> Dictionary:
	return {"kind": "rule", "text": text}


static func _salary_row(before: int, after: int) -> Dictionary:
	# `note` is the monthly difference beside the result: "(aylık +$1.470)".
	return _delta(TranslationServer.translate("HR_ROW_SALARY"), _money(before), _money(after),
		TranslationServer.translate("HR_ROW_MONTHLY_NOTE").format({"delta": _signed_money(after - before)}))


static func _money(amount: int) -> String:
	# Fmt.money_exact under money_tr already prints its own minus sign.
	return HRConstants.money_tr(amount)


static func _signed_money(amount: int) -> String:
	return ("+%s" % _money(amount)) if amount >= 0 else _money(amount)
