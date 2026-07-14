class_name EndingsSystem
extends RefCounted

# Endings Evaluator — daily tick slot 9 per docs/ENDGAME_DESIGN.md §3-4.
#
# Scans terminal conditions daily, reading GameState FIELDS only (§7.9:
# fields, not systems — the future VC pitch / scandal systems just write the
# fields and plug in with zero retrofit). Scan order = §7.1 priority chain:
# Bankruptcy > Brand Collapse > Cascade > Time-out fork.
#
# trigger_ending() is the single terminal seam for BOTH classes:
#   Class A (instant, played moment): acquisition accept, term sheet signed,
#   debug F-keys — call it directly, no daily-tick wait.
#   Class B (scanned): the daily scan calls it.
# It is idempotent (first terminal wins, §7.1), flushes the event queue (§7.2 —
# a queued Frank gate scene dies with the run) and freezes the clock (§7.3).

# Working values — §10 calibration items, numbers last.
const SHUTTER_DAYS := 7            # §4.3 Kepenk (7 vs 10 vs 14 open)
const RUN_END_DAY := 180           # §1 hard wall
const BRAND_COLLAPSE_FLOOR := 15   # §4.4
const BRAND_COLLAPSE_WINDOW := 30  # §4.4 "no recovery for 30 days"
const CASCADE_TABLES := 3          # §4.5 closed pitch tables
const PIVOT_MRR_MIN := 2000        # §4.5 "metrics are alive" floor
const BOOTSTRAP_WIN_MRR := 5000    # §4.6 fork MRR threshold
const NET_WINDOW := 90             # §4.6 cumulative net window (Erdem 2026-07-13)

# Ending metadata — 7 endings (§4). Titles/frank_lines are working copy;
# the newspaper ending screens (content phase) replace the presentation only.
const ENDINGS := {
	"series_a_close": {
		"title": "Series A Kapandı",
		"tone": "win",
		"frank_line": "İmzaladın. Şimdi asıl iş başlıyor — ama o başka bir oyunun konusu.",
	},
	"acquisition": {
		"title": "Şirket Satıldı",
		"tone": "soft_win",
		"frank_line": "Sattın. Kazanmak değil; kaybetmek de değil. Çoğu kurucu bunu bile göremez.",
	},
	"bankruptcy": {
		"title": "Kepenk İndi",
		"tone": "loss",
		"frank_line": "Yedi gün kırmızıda kaldın. Rakamlar kaba değildir — sadece sabırlıdır.",
	},
	"brand_collapse": {
		"title": "Marka Çöktü",
		"tone": "loss",
		"frank_line": "Skandalı sen yönetmedin; o seni yönetti.",
	},
	"vc_rejection_cascade": {
		"title": "Üç Masa, Üç Ret",
		"tone": "loss",
		"frank_line": "Para bulamamak öldürmez. Vazgeçilmiş görünmek öldürür.",
	},
	"profitable_bootstrap": {
		"title": "Kendi Paranla",
		"tone": "win",
		"frank_line": "Onlara ihtiyacın yokmuş. Gerçek bir şey kurdun.",
	},
	"running_on_fumes": {
		"title": "Son Damla",
		"tone": "soft_loss",
		"frank_line": "Kaybetmedin. Sadece kazanmadın.",
	},
}


static func daily_tick() -> void:
	if not GameState.run_active:
		return
	_update_trackers()
	# Class A field backstop: the VC pitch flow (later) and debug F3 call
	# trigger_ending directly at the played moment; this catches a field set
	# through any other path (e.g. console/debug) no later than the next day.
	if GameState.series_a_closed:
		trigger_ending("series_a_close")
		return
	if _tick_shutter():
		return
	if _check_brand_collapse():
		return
	if _check_vc_cascade():
		return
	if _check_day180_fork():
		return
	_check_acquisition_offer()  # non-terminal; deliberately NOT shutter-gated (§7.5)


# --- Daily trackers (cheap, serializable — §4.6 fork inputs) ---

static func _update_trackers() -> void:
	# Cumulative 90-day net (Erdem 2026-07-13): ring buffer of daily net flow.
	GameState.net_history_90.append(GameState.get_net_daily_flow())
	while GameState.net_history_90.size() > NET_WINDOW:
		GameState.net_history_90.pop_front()
	# Brand-collapse window anchor: first day brand dipped under the floor;
	# any recovery to/above the floor resets the 30-day clock.
	if GameState.brand < BRAND_COLLAPSE_FLOOR:
		if GameState.brand_low_since_day < 0:
			GameState.brand_low_since_day = GameState.day
	else:
		GameState.brand_low_since_day = -1


# --- Bankruptcy + Kepenk (§4.3) ---

static func _tick_shutter() -> bool:
	if GameState.cash < 0:
		if GameState.shutter_days_left < 0:
			# Shutter starts: visible counter (TopBar via shutter_changed) +
			# Frank warning scene. A queued gate scene is held (§7.4).
			# Extension socket: a future loan / cash-injection mechanic resets
			# this by pushing cash ≥ 0 — no extra seam needed (DEFERRED BACKLOG).
			GameState.set_shutter_days_left(SHUTTER_DAYS)
			GameState.submit_month_highlight("Kepenk sayacı başladı — kasa ekside", 90)  # AYIN OLAYI (Spec 3 §4)
			PhaseGateSystem.on_shutter_started()
			EventManager.enqueue_front(_build_shutter_warning_event())
		else:
			GameState.set_shutter_days_left(GameState.shutter_days_left - 1)
			if GameState.shutter_days_left <= 0:
				trigger_ending("bankruptcy")
				return true
	elif GameState.shutter_days_left >= 0:
		# Cash recovered — full reset (§4.3), the held gate scene returns (§7.4).
		GameState.set_shutter_days_left(-1)
		PhaseGateSystem.on_shutter_cleared()
	return false


# --- Brand Collapse (§4.4) ---

static func _check_brand_collapse() -> bool:
	# active_scandal is a RESERVED field (no scandal system yet) — until it
	# ships, this ending is reachable only via debug. Deliberate per canon.
	if GameState.brand >= BRAND_COLLAPSE_FLOOR:
		return false
	if GameState.brand_low_since_day < 0:
		return false
	if GameState.day - GameState.brand_low_since_day < BRAND_COLLAPSE_WINDOW:
		return false
	if not GameState.active_scandal:
		return false
	trigger_ending("brand_collapse")
	return true


# --- VC Rejection Cascade + pivot escape hatch (§4.5) ---

static func _check_vc_cascade() -> bool:
	if GameState.vc_rejections < CASCADE_TABLES:
		return false
	# Ledger 17 (Spec 4): a player holding a live/pending sheet or an in-flight
	# meeting still holds a win path — cascade DEFERS until it resolves. Without
	# this, pivot could fire while victory is in hand.
	if not GameState.active_sheets.is_empty() or _any_pending_sheet() or not GameState.pending_meeting.is_empty():
		return false
	if GameState.pivot_used:
		# Erdem 2026-07-13: pivot closes the VC path permanently; the counter
		# stays at 3 but the cascade can never fire again. Only route left is
		# the Day-180 fork.
		return false
	if GameState.get_flag("pivot_offer_made", false):
		return false  # offer on the table — the player's choice resolves it
	if GameState.mrr >= PIVOT_MRR_MIN and GameState.cash > 0:
		# Metrics alive → Frank offers the hidden corridor. Played choice:
		# accept_pivot / decline_pivot modifiers resolve it (§4.5).
		GameState.set_flag("pivot_offer_made", true)
		EventManager.enqueue_front(_build_pivot_offer_event())
		return false
	trigger_ending("vc_rejection_cascade")
	return true


static func on_pivot_accepted() -> void:
	# Called via the "accept_pivot" event modifier.
	GameState.pivot_used = true
	# Ledger 18 (Spec 4): pivot closes the Hunt — cancel the pending meeting, kill
	# callbacks, remove a queued meeting prompt. Active sheets are impossible here
	# (ledger 17 defers cascade while any sheet lives), so none to clear.
	VCPitchSystem.on_pivot()
	if OS.is_debug_build():
		print("[EndingsSystem] Pivot accepted — VC path closed, bootstrap run to Day %d" % RUN_END_DAY)


# Ledger 17 helper: any VC awaiting delayed sheet delivery counts as a live win path.
static func _any_pending_sheet() -> bool:
	for st in GameState.vc_states.values():
		if st is Dictionary and st.get("pending_sheet", false):
			return true
	return false


# --- Day-180 time-out fork (§4.6) ---

static func _check_day180_fork() -> bool:
	if GameState.day < RUN_END_DAY:
		return false
	var net_sum: int = 0
	for n in GameState.net_history_90:
		net_sum += n
	var win: bool = not GameState.cash_went_negative \
		and GameState.net_history_90.size() >= NET_WINDOW \
		and net_sum > 0 \
		and not GameState.unmanaged_major_scandal \
		and GameState.mrr >= BOOTSTRAP_WIN_MRR
	trigger_ending("profitable_bootstrap" if win else "running_on_fumes")
	return true


# --- Acquisition offer (§4.2 — non-terminal; accept is the Class A win) ---

static func _check_acquisition_offer() -> void:
	if GameState.get_flag("acquisition_offer_made", false):
		return
	if GameState.phase != 3:
		return
	if GameState.brand < 30 or GameState.brand > 50:
		return  # "struggling but not failing" band
	if GameState.vc_rejections < 1:
		return
	GameState.set_flag("acquisition_offer_made", true)
	GameState.submit_month_highlight("Satın alma teklifi masada", 90)  # AYIN OLAYI (Spec 3 §4)
	EventManager.enqueue_front(_build_acquisition_offer_event())


# --- Single terminal seam (§3, §7.1-7.3) ---

static func trigger_ending(ending_id: String, extra: Dictionary = {}) -> void:
	if not GameState.run_active:
		return  # idempotent — first terminal wins (§7.1)
	if not ENDINGS.has(ending_id):
		push_warning("[EndingsSystem] Unknown ending id: %s" % ending_id)
		return
	GameState.set_run_active(false)
	GameState.ending_id = ending_id
	EventManager.flush_queue()  # §7.2 — pending scenes (incl. Frank gate) die
	if OS.is_debug_build():
		print("[EndingsSystem] RUN ENDED: %s (Day %d)" % [ending_id, GameState.day])
	EventBus.run_ended.emit(ending_id, _build_ending_data(ending_id, extra))
	EventBus.speed_change_requested.emit(0)  # §7.3 — freeze clock, pause tree


static func _build_ending_data(ending_id: String, extra: Dictionary) -> Dictionary:
	# Live snapshot — safe because trigger_ending halts the world in the same
	# frame (§7.3: no MRR accrues behind the ending screen, so these numbers
	# cannot contradict the screen).
	var meta: Dictionary = ENDINGS[ending_id]
	var data := {
		"ending_id": ending_id,
		"title": meta.title,
		"tone": meta.tone,
		"frank_line": meta.frank_line,
		"day": GameState.day,
		"cash": GameState.cash,
		"mrr": GameState.mrr,
		"brand": GameState.brand,
		"reputation": GameState.reputation,
		"phase": GameState.phase,
		"customers": CustomerRegistry.get_active().size(),
		"employees": CharacterRegistry.get_employees().size(),
		"company_name": GameState.company_name,
		"founder_name": GameState.founder_name,
	}
	data.merge(extra, true)
	return data


# --- Synthetic scenes (ship-moment pattern; EventModal renders them) ---

static func _build_shutter_warning_event() -> GameEvent:
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_shutter_warning"
	ev.category = "reactive"
	ev.title = "Kırmızıdasın"
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	# §4.3 Frank line. Loan clause ("ya da birinden borç iste") lands when the
	# deferred loan mechanic ships.
	ev.body_text = "Frank ekrana bakmıyor; sana bakıyor.\n\n\"Kırmızıdasın. %d günün var. Ya bir şey sat, ya bir şey kes.\"\n\nTopBar'daki sayaç bugünden itibaren geri sayıyor. Kasa artıya dönerse sayaç durur." % SHUTTER_DAYS
	ev.cooldown_days = 0
	ev.one_shot = false  # a NEW shutter start after a recovery warns again
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var ack: EventChoice = EventChoice.new()
	ack.label = "Anlaşıldı"
	ack.modifiers = []
	ack.unlock_condition = {}
	ack.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(ack)
	ev.choices = choices
	return ev


static func _build_pivot_offer_event() -> GameEvent:
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_pivot_offer"
	ev.category = "reactive"
	ev.title = "Üçüncü kapı da kapandı"
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	ev.body_text = "Üçüncü ret maili kısa. Hepsi kısadır.\n\nFrank uzun bir süre bir şey demiyor. Sonra:\n\n\"Belki bu yıl değil. Belki bu şirket değil. Ama sen bitmedin.\"\n\nVC yolu kapanıyor. Kendi paranla, kendi müşterinle, Day %d'e kadar — hâlâ gerçek bir şirket kurabilirsin." % RUN_END_DAY
	ev.cooldown_days = 0
	ev.one_shot = false  # one-shot enforced by the pivot_offer_made flag
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var accept: EventChoice = EventChoice.new()
	accept.label = "Pivot — devam ediyoruz"
	accept.modifiers = [{"type": "accept_pivot"}]
	accept.unlock_condition = {}
	accept.unlock_reason_text = ""
	var decline: EventChoice = EventChoice.new()
	decline.label = "Hayır. Bitti."
	decline.modifiers = [{"type": "decline_pivot"}]
	decline.unlock_condition = {}
	decline.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(accept)
	choices.append(decline)
	ev.choices = choices
	return ev


static func _build_acquisition_offer_event() -> GameEvent:
	var ev: GameEvent = GameEvent.new()
	ev.id = "ev_acquisition_offer"
	ev.category = "reactive"
	ev.title = "Satın alma teklifi"
	ev.subtitle = ""
	ev.illustration_path = ""
	ev.character_id = "char_mentor_frank"
	# §4.2: "you sold, but you didn't quite win" register. The drama is in the
	# option to refuse — reject costs nothing extra, the run just continues.
	ev.body_text = "Mail bir cuma akşamı geliyor; büyük oyuncular hep cuma yazar.\n\nSeni satın almak istiyorlar. Ekip kalır, isim kalmaz. Rakam fena değil — hayat değiştirmez, ama kepenk de indirtmez.\n\nFrank omuz silkiyor:\n\n\"Satmak yenilgi değildir. Ama bunu sana kimse imza gecesi söylemez.\""
	ev.cooldown_days = 0
	ev.one_shot = false  # one-shot enforced by the acquisition_offer_made flag
	ev.priority = 10
	ev.tags = ["build_safe", "endgame"]
	ev.trigger_conditions = []
	var accept: EventChoice = EventChoice.new()
	accept.label = "Kabul et — sat"
	accept.modifiers = [{"type": "accept_acquisition"}]
	accept.unlock_condition = {}
	accept.unlock_reason_text = ""
	var decline: EventChoice = EventChoice.new()
	decline.label = "Reddet — devam"
	decline.modifiers = [{"type": "set_flag", "key": "acquisition_offer_rejected", "value": true}]
	decline.unlock_condition = {}
	decline.unlock_reason_text = ""
	var choices: Array[EventChoice] = []
	choices.append(accept)
	choices.append(decline)
	ev.choices = choices
	return ev
