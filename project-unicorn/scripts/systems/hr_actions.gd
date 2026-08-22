class_name HRActions
extends RefCounted

# The three employee-card actions (design doc §7): ZAM YAP, TATİLE GÖNDER, İŞTEN ÇIKAR.
# PLAYER-TRIGGERED ONLY — this file has no dispatch slot and is never ticked. HRSystem's daily
# order does not include it on purpose: an action is a played decision, not a daily rule, and
# every consequence it has (morale, capacity, burn, severance) is applied by the system that
# owns that consequence.
#
# Each action is a TRIO — can_* (validation), preview_* (exactly what the UI prints before the
# player confirms), and the applier — so task 3's UI never recomputes a consequence the engine
# already knows, and the number on the confirm card is the number the action produces.
#
# Owns: nothing but Character.monthly_salary (the raise). Leave goes to HRMoraleSystem,
# severance to Finance, removal to the registry, morale to the morale seam.
#
# FRANK IS UNTOUCHABLE. Every entry point guards on category == "employee": the mentor
# ("mentor") and the founder ("founder") are never fireable, raisable or sendable on holiday.
# The guard is verified here on the Character the UI hands over, NOT trusted to the registry
# filters — get_employees() never touched that reference.
#
# WRITE-THROUGH LAW: the raise reaches burn through the EXISTING Finance salary PULL
# (FinanceSystem.daily_tick reads CharacterRegistry.get_total_monthly_salaries at slot 5) and
# is never pushed; severance leaves through FinanceSystem.apply_one_time_cost with
# HRConstants.COST_LABEL_SEVERANCE; morale moves only through HRMoraleSystem.apply_delta;
# leave only through HRMoraleSystem.send_on_leave; removal only through
# CharacterRegistry.remove (run_departures++ and character_removed). Every tunable comes from
# HRConstants — there is no number in this file.
#
# No raw cross-domain writes: the raise goes through CharacterRegistry.set_salary, the seam
# added for exactly this action. It emits no signal because Finance PULLS payroll every daily
# tick, so burn follows without one.


# --- Local, non-tunable constant (a percent denominator, not a knob) ---
const PCT_DIVISOR := 100.0


# ============================================================================
#  ZAM YAP
# ============================================================================

static func can_raise(emp: Character, pct: int) -> bool:
	# `pct` is CLAMPED rather than rejected (HRConstants.RAISE_MIN_PCT..RAISE_MAX_PCT), so the
	# slider can never produce a refusal the player cannot understand. What still CAN refuse:
	# a target who is not staff, no salary to raise, or a salary so small that the clamped
	# percentage would round to nothing — refusing that last one here is what lets apply_raise
	# trust that a true means a real rise.
	if _block_reason(emp) != "":
		return false
	if emp.monthly_salary <= 0:
		return false
	return _raised_salary(emp.monthly_salary, _clamp_pct(pct)) > emp.monthly_salary


static func preview_raise(emp: Character, pct: int) -> Dictionary:
	var reason: String = _block_reason(emp)
	if reason == "" and emp.monthly_salary <= 0:
		reason = TranslationServer.translate("HR_ERR_NO_SALARY")
	if reason != "":
		return _refusal(reason)
	var p: int = _clamp_pct(pct)
	var before: int = emp.monthly_salary
	var after: int = _raised_salary(before, p)
	var payroll_before: int = CharacterRegistry.get_total_monthly_salaries()
	var payroll_after: int = payroll_before + (after - before)
	# The morale figure is the one apply_delta will really write (trait multiplier + Liderlik
	# iklimi + tavan), not the nominal design number, so the card cannot over-promise.
	var gain: int = HRMoraleSystem.scaled_delta(emp, HRConstants.raise_morale_gain(p))
	return {
		"ok": true,
		"reason": "",
		"pct": p,
		"pct_requested": pct,
		"salary_before": before,
		"salary_after": after,
		"salary_delta": after - before,
		"payroll_before": payroll_before,
		"payroll_after": payroll_after,
		"morale_before": emp.morale,
		"morale_after": emp.morale + gain,
		"morale_gain": gain,
		"permanent": true,
		"rows": [
			# DELTA — maaşın kendisi. `note` sonucun YANINDA duran ikincil rakam:
			# aylık fark, sayfanın "(aylık +$1.470)" parantezi.
			_delta(TranslationServer.translate("HR_ROW_SALARY"), _money(before), _money(after),
				TranslationServer.translate("HR_ROW_MONTHLY_NOTE").format({
					"delta": _signed_money(after - before)})),
			_delta(TranslationServer.translate("HR_ROW_MORALE"), str(emp.morale), str(emp.morale + gain)),
			_delta(TranslationServer.translate("HR_ROW_PAYROLL"), _money(payroll_before), _money(payroll_after)),
			# KURAL — sayısı yok, o yüzden delta da olgu da değil. Üçüncü tür bunun için var.
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
	# can_raise already refused a rounding no-op, so `after > before` holds here.
	# KALICI maaş artışı. It reaches daily_burn on the NEXT FinanceSystem.daily_tick (slot 5),
	# which pulls get_total_monthly_salaries — no push, no second burn home, no stale mirror.
	CharacterRegistry.set_salary(emp.id, after)
	HRMoraleSystem.apply_delta(emp, HRConstants.raise_morale_gain(p), HRConstants.REASON_RAISE)
	if OS.is_debug_build():
		print("[HRActions] zam %s: %%%d, %d → %d" % [emp.id, p, before, after])
	return true


# ============================================================================
#  TATİLE GÖNDER — EMEKLİ (H5, 2026-08-22)
# ============================================================================
# `can_send_on_vacation` · `preview_vacation` · `send_on_vacation` KALDIRILDI.
#
# Sebep zincirlemeydi. R3 "tatile göndermek yıllık izin sayacına dokunmasın" dedi;
# ama `leave_taken_year` bir sayaç değil bir YIL MANDALI ve manuel tatili SıNIRLAYAN
# tek şeydi. Mandalı kaldırmak eylemi sınırsız tekrarlanabilir yapıyordu, yani
# +MORALE_VACATION_RETURN kapasiteyle ödenen bir moral çeşmesine dönüşüyordu —
# Kalibrasyon Yasası 1'in adıyla yasakladığı şekil. Erdem eylemin KENDİSİNİ kaldırdı.
#
# OTOMATİK YILLIK İZİN DURUYOR: HRMoraleSystem.tick_leave_departures → send_on_leave(
# emp, LEAVE_DAYS, false). `send_on_leave`'in `is_manual` dalı ve MORALE_VACATION_RETURN
# de duruyor — gelecek olay kanalı (kapsam dışı) onları yeniden kullanacak.


# ============================================================================
#  İŞTEN ÇIKAR
# ============================================================================

static func can_fire(emp: Character) -> bool:
	# Deliberately NOT gated on affordability: severance can push cash negative, the same
	# channel every other one-time cost uses. The preview carries the number; the decision is
	# the player's.
	return _block_reason(emp) == ""


static func preview_fire(emp: Character) -> Dictionary:
	var reason: String = _block_reason(emp)
	if reason != "":
		return _refusal(reason)
	var days_served: int = maxi(GameState.day - emp.hire_day, 0)
	var months: int = HRConstants.severance_months(days_served)
	var severance: int = HRConstants.severance_amount(emp.monthly_salary, days_served)
	var payroll_before: int = CharacterRegistry.get_total_monthly_salaries()
	var payroll_after: int = payroll_before - emp.monthly_salary
	var remaining: int = maxi(CharacterRegistry.get_employees().size() - 1, 0)
	return {
		"ok": true,
		"reason": "",
		"days_served": days_served,
		"severance_months": months,
		"severance": severance,
		"cash_before": GameState.cash,
		"cash_after": GameState.cash - severance,
		"payroll_before": payroll_before,
		"payroll_after": payroll_after,
		"team_size_after": remaining,
		"team_morale_drop": HRConstants.MORALE_FIRE_TEAM,
		"rows": [
			# OLGU — tazminatın bir "önce"si yok, tek bir rakam. Sayfa buna ok ÇİZMİYOR
			# ve ok çizmemek bir üslup tercihi değil: ok bir GEÇİŞ iddiasıdır.
			_fact(HRConstants.cost_label_severance(), _money(severance),
				TranslationServer.translate("HR_ROW_MONTHS_NOTE").format({"months": months})),
			# Nakit sıfırı geçebilir; `negative_after` onu UI'ya SÖYLER, UI kendi
			# karşılaştırmasını yapmaz (biçimlenmiş metinden işaret okumak zorunda kalırdı).
			_delta(TranslationServer.translate("HR_ROW_CASH"), _money(GameState.cash),
				_money(GameState.cash - severance), "", GameState.cash - severance < 0),
			_delta(TranslationServer.translate("HR_ROW_PAYROLL"), _money(payroll_before), _money(payroll_after)),
			_fact(TranslationServer.translate("HR_ROW_TEAM_MORALE"),
				str(-HRConstants.MORALE_FIRE_TEAM)),
		],
	}


static func fire(emp: Character) -> bool:
	if not can_fire(emp):
		_refuse_loudly(emp, "fire")
		return false
	var days_served: int = maxi(GameState.day - emp.hire_day, 0)
	var severance: int = HRConstants.severance_amount(emp.monthly_salary, days_served)
	# ONCE, through the Finance seam. Charged before the removal so the ledger line and the
	# roster change cannot come apart if anything below screams.
	if severance > 0:
		FinanceSystem.apply_one_time_cost(severance, "severance")
	# Kalan ekip görür ve hisseder. get_employees() (not the active list) on purpose: someone
	# on leave hears about it too. The leaver is skipped — their own morale is moot.
	for other in CharacterRegistry.get_employees():
		if other.id == emp.id:
			continue
		HRMoraleSystem.apply_delta(other, -HRConstants.MORALE_FIRE_TEAM, HRConstants.REASON_TEAMMATE_FIRED)
	# Drop the HR-side latches while the id still means something, then remove through the
	# registry seam (run_departures++ and character_removed).
	HRMoraleSystem.forget_employee(emp.id)
	if OS.is_debug_build():
		print("[HRActions] işten çıkarma %s: kıdem %d gün, tazminat %d" % [emp.id, days_served, severance])
	CharacterRegistry.remove(emp.id)
	return true


# ============================================================================
#  Internals
# ============================================================================

static func _block_reason(emp: Character) -> String:
	# The refusals every action shares, as a printable Turkish reason so preview_* can say WHY
	# instead of returning a silent empty dict.
	if emp == null:
		return TranslationServer.translate("HR_ERR_NO_RECORD")
	if emp.category != "employee":
		# FRANK VE KURUCU DOKUNULMAZ. Frank is category "mentor" and the founder is "founder";
		# neither is staff, neither draws a staff salary, neither can be fired, raised or sent
		# on holiday. Checked here rather than assumed of the caller's Character.
		return TranslationServer.translate("HR_ERR_EMPLOYEES_ONLY")
	if CharacterRegistry.get_character(emp.id) == null:
		# Idempotency guard against a stale reference, the same race EventManager.resolve_choice
		# blocks: a Character is a Resource, so a double-clicked confirm still holds a live
		# reference to someone already removed. Without this, a second fire() would charge
		# severance twice for a person who is already gone.
		return TranslationServer.translate("HR_ERR_NO_RECORD")
	if HRMoraleSystem.has_pending_departure(emp.id):
		return TranslationServer.translate("HR_ERR_LEAVING")
	return ""


static func _refuse_loudly(emp: Character, where: String) -> void:
	# A can_* returning false is normal (the UI greys the button out). An APPLIER reached with
	# a non-employee is a wiring bug, and Frank silently surviving a fire() call would hide it,
	# so it screams. Non-blocking: the action already returned false.
	if emp != null and emp.category != "employee":
		push_error("[HRActions] %s refused for '%s' (category '%s') — the founder and the mentor are never targets" % [where, emp.id, emp.category])


static func _refusal(reason: String) -> Dictionary:
	# Same keys as a successful preview's spine, so the UI can bind one card to both.
	# The reason travels as a RULE record (`rows`): it has no number and no before/after,
	# which is exactly what that kind means. It used to travel as `lines`, the shape that
	# no longer has a renderer.
	return {"ok": false, "reason": reason, "rows": [_rule(reason)]}


static func _clamp_pct(pct: int) -> int:
	return clampi(pct, HRConstants.RAISE_MIN_PCT, HRConstants.RAISE_MAX_PCT)


static func _raised_salary(monthly_salary: int, pct: int) -> int:
	return int(round(float(monthly_salary) * (1.0 + float(pct) / PCT_DIVISOR)))


static func _current_year() -> int:
	return int(GameState.get_date_dict().year)


# --- Kayıt kurucuları -------------------------------------------------------
# Üç tür, üç kurucu. Sözlükleri çağrı yerinde elle kurmak, alan adlarının zamanla
# ayrışmasının en kısa yolu; kurucular sözleşmeyi TEK yerde tutar.

static func _delta(label: String, before: String, after: String, note: String = "",
		negative_after: bool = false) -> Dictionary:
	return {"kind": "delta", "label": label, "before": before, "after": after,
		"note": note, "negative_after": negative_after}


static func _fact(label: String, value: String, note: String = "") -> Dictionary:
	return {"kind": "fact", "label": label, "value": value, "note": note}


static func _rule(text: String, pause: bool = false) -> Dictionary:
	# `pause` = sayfanın 12px kırmızı durdurma glifi. Bugün hiçbir kayıt istemiyor;
	# alan sözleşmede DURUYOR çünkü onu isteyen kayıt (üretimi durduran eylem)
	# tasarım sayfasında var ve bu turun dışında.
	return {"kind": "rule", "text": text, "pause": pause}


static func _money(amount: int) -> String:
	# HRConstants.money_tr → Fmt.money_exact ve o KENDİ işaretini kendi basıyor
	# ("-$4.878"). Burası üstüne BİR EKSİ DAHA ekliyordu → "--$4.878", ve işten
	# çıkarma nakdi eksiye geçirebildiği için bu tasarlanmış-ulaşılabilir bir hâldi.
	# "only the sign is added here" yorumu, money_tr ÖZEL ve İŞARETSİZ bir gruplayıcıyken
	# doğruydu; Fmt'ye bağlanınca sessizce yanlış oldu. İşaret artık TEK yerde eklenir.
	return HRConstants.money_tr(amount)


static func _signed_money(amount: int) -> String:
	return ("+%s" % _money(amount)) if amount >= 0 else _money(amount)
