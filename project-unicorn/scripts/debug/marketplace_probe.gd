extends SceneTree

# --marketplace-probe=weeks=<n> (varsayılan 40): pazaryeri ekonomisinin saf işlevlerini (MarketplaceModel) başsız koşar.
#
#   "$GODOT" --headless --path . -s res://scripts/debug/marketplace_probe.gd -- --marketplace-probe=weeks=<n>
#
# Önce oynanan bir zaman çizelgesi, hafta başına bir satır; sonra mekanik denetimleri, her biri kendi küçük dünyasında:
#
#   MPPROBE ACT w=<hafta> <ne> ok=<true|false>      çizelgenin oyuncu hamlesi
#   MPPROBE WEEK w=<hafta> visits= cart= checkout= placed= delivered= stores= users= members= revenue= sat_users= sat_stores=
#   MPPROBE CHECK <ad> PASS|FAIL <ayrıntı>
#   MPPROBE SUMMARY checks=<n> fails=<n>            bir FAIL varsa süreç 1 ile çıkar
#
# Çizelge: kurucu Moda'yı açar ve kendini atar; ürün 4. haftada yayınlanır; satışçı, Elektronik ve ikinci satışçı, Moda'da komisyon
# artışı, kargo bedava bir kampanya, Üyelik ve Premium sırayla gelir. Pazarlama'nın girdileri ve modül kademeleri çizelgenin
# kendisidir (`_world`). Rastgele sayı yoktur: aynı girdi aynı çıktıyı verir.

const ARG := "--marketplace-probe="
const DEFAULT_WEEKS := 40
const PUBLISH_WEEK := 4
const STARS := {"founder": 1, "sales_a": 2, "sales_b": 3}
const CHECKS := ["empty_category_no_orders", "acquisition_waits_for_publish", "leaving_zone_stores_fall", "lock_rejects",
	"campaign_override_expires", "revenue_window_spike", "premium_closed_no_perk_cost", "campaign_free_shipping_single_write",
	"preview_figures", "known_store_earnings", "known_return_rate", "known_order_rate", "json_roundtrip", "ledger_expiry",
	"zone_limits_consistent", "constants_switch", "gain_and_weakest", "acquisition_multipliers", "store_terms_discount",
	"premium_members", "zone_rows_need_stores", "add_users_bounds", "lost_counters", "channel_read_values", "source_revenue_values",
	"state_survives_codec", "topic_rows_known", "topic_ticket_gates", "topic_ledger_rows", "feature_gain_matches_close",
	"reviews_affected_is_return_gap", "assignment_waits_a_close", "waive_zeroes_one_close", "outage_row_and_cost",
	"lost_commission_weighted", "backup_mult_tiers", "open_topic_report_row", "cfg_reads_constants", "funnel_sums_categories",
	"step_hint_matches_gain", "ledger_worst_picks_heaviest", "crew_follows_assignment", "returning_orders_follow_frequency",
	"word_of_mouth_brings_users", "decision_row_drifts", "cardless_topics_stay_quiet"]

var _weeks := DEFAULT_WEEKS
var _printing := false
var _bad_args := false


func _initialize() -> void:
	for arg in OS.get_cmdline_user_args():
		if String(arg).begins_with(ARG):
			var spec := String(arg).trim_prefix(ARG).split("=")
			if spec.size() != 2 or spec[0] != "weeks" or not spec[1].is_valid_int():
				print("MPPROBE ERROR want %sweeks=<n>" % ARG)
				_bad_args = true
				quit(2)
				return
			_weeks = int(spec[1])


func _process(_delta: float) -> bool:
	if _bad_args:
		return true
	_printing = true
	_timeline(_weeks)
	_printing = false
	var fails := 0
	for check in CHECKS:
		var result: Array = call("_check_" + check)
		fails += 0 if result[0] else 1
		print("MPPROBE CHECK %s %s %s" % [check, "PASS" if result[0] else "FAIL", result[1]])
	print("MPPROBE SUMMARY checks=%d fails=%d" % [CHECKS.size(), fails])
	quit(1 if fails > 0 else 0)
	return true


# --- Oynanan çizelge -------------------------------------------------------------------------

func _tiers(week: int) -> Dictionary:
	var tiers := {}
	if week >= PUBLISH_WEEK:
		tiers = {"listing": 1, "storefront": 1, "checkout": 1, "orders": 1}
	if week >= 9:
		tiers.storefront = 2
	if week >= 17:
		tiers.integrations = 1
		tiers.membership = 1
	if week >= 20:
		tiers.orders = 2
	if week >= 21:
		tiers.integrations = 2
	return tiers


func _world(week: int) -> Dictionary:
	var world := MarketplaceModel.new_world()
	world.week = week
	world.published = week >= PUBLISH_WEEK
	world.tiers = _tiers(week)
	world.stars = STARS
	if week >= 7:
		world.channel = {"fashion": {"ads": 1500.0}}
	if week >= 11:
		world.channel.electronics = {"ads": 800.0}
	if week == 14 or week == 15:
		world.campaign = {"kind": "discount_days", "stage": "run", "weeks_left": 15 - week + 1, "weeks": 2,
			"prep": {"done": 6, "total": 6}, "cats": ["fashion"], "depth": 0.2, "company_share": 0.5,
			"participation_mult": 1.0, "settings": {"shipping": "free"}, "overrides": {"shipping": "free"}}
	return world


## Oyuncunun o haftaki hamleleri: kapanıştan önce yapılır.
func _play(state: Dictionary, week: int) -> void:
	var world := _world(week)
	match week:
		1:
			_act(week, "open fashion", MarketplaceModel.open_category(state, world, "fashion"))
			MarketplaceModel.assign(state, "founder", "fashion")
		6:
			MarketplaceModel.assign(state, "sales_a", "fashion")
		10:
			_act(week, "open electronics", MarketplaceModel.open_category(state, world, "electronics"))
			MarketplaceModel.assign(state, "sales_b", "electronics")
		12:
			_act(week, "fashion commission 12", MarketplaceModel.set_commission(state, world, "fashion", 12))
		18:
			_act(week, "fee 5", MarketplaceModel.set_fee(state, world, 5))
			_act(week, "free shipping for members", MarketplaceModel.set_perk(state, world, "free_shipping", "premium"))
			state.premium.trial = true
		22:
			_act(week, "fast delivery for everyone", MarketplaceModel.set_perk(state, world, "fast_delivery", "everyone"))


func _act(week: int, what: String, ok: bool) -> void:
	if _printing:
		print("MPPROBE ACT w=%d %s ok=%s" % [week, what, ok])


## Çizelgeyi `weeks` haftaya kadar oynar; basarken her hafta bir satır yazar. Son durumu döndürür.
func _timeline(weeks: int) -> Dictionary:
	var state := MarketplaceModel.new_state()
	for week in range(1, weeks + 1):
		_play(state, week)
		MarketplaceModel.close_week(state, _world(week))
		if _printing:
			_print_week(state, week)
	return state


func _print_week(state: Dictionary, week: int) -> void:
	var sum := {"visits": 0.0, "cart": 0.0, "checkout": 0.0, "order": 0.0, "delivered": 0.0, "stores": 0.0}
	for id in MarketplaceModel.open_ids(state):
		for key in sum:
			sum[key] += state.cats[id].stores if key == "stores" else state.cats[id].week[key]
	var revenue := MarketplaceModel.monthly_revenue(state)
	print("MPPROBE WEEK w=%d visits=%.0f cart=%.0f checkout=%.0f placed=%.0f delivered=%.0f stores=%.1f users=%.0f members=%.0f "
		% [week, sum.visits, sum.cart, sum.checkout, sum.order, sum.delivered, sum.stores, state.users, state.members]
		+ "revenue=%.0f sat_users=%.1f sat_stores=%.1f"
		% [revenue.commission + revenue.membership, state.sat.users, state.sat.stores])


# --- Denetim yardımcıları --------------------------------------------------------------------

## Bütün çekirdek modüller 1. kademede, ürün yayında.
func _live_world(week: int = 0) -> Dictionary:
	var world := MarketplaceModel.new_world()
	world.week = week
	world.published = true
	world.tiers = {"listing": 1, "storefront": 1, "checkout": 1, "orders": 1}
	world.stars = {"founder": 1}
	return world


## `cats` açık, mağazaları gereken sayıda (seçenek 1), `users` aktif kullanıcı.
func _store_state(cats: Array, users: float) -> Dictionary:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	for cat in cats:
		MarketplaceModel.open_category(state, world, cat)
		state.cats[cat].stores = MarketplaceModel.cat_def(cat).stores_needed
	state.users = users
	return state


## `weeks` kapanış, hafta sayacı `world.week`'ten başlar.
func _run(state: Dictionary, world: Dictionary, weeks: int) -> void:
	for i in weeks:
		MarketplaceModel.close_week(state, world.merged({"week": world.week + i}, true))


func _near(a: float, b: float, tolerance: float = 1e-9) -> bool:
	return absf(a - b) <= tolerance * maxf(1.0, absf(b))


func _equal(a: Variant, b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		if a.size() != b.size():
			return false
		for key in a:
			if not b.has(key) or not _equal(a[key], b[key]):
				return false
		return true
	if a is Array and b is Array:
		if a.size() != b.size():
			return false
		for i in a.size():
			if not _equal(a[i], b[i]):
				return false
		return true
	if (a is int or a is float) and (b is int or b is float):
		return _near(float(a), float(b))
	return a == b


# --- Denetimler ------------------------------------------------------------------------------

func _check_empty_category_no_orders() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	MarketplaceModel.open_category(state, world, "fashion")
	world.channel = {"fashion": {"ads": 2000.0}}
	var orders := 0.0
	var visits := 0.0
	for i in 6:
		_run(state, world.merged({"week": i}, true), 1)
		orders += state.cats.fashion.week.delivered
		visits += state.cats.fashion.week.visits
	var closed_blank: bool = state.cats.electronics.week.is_empty()
	return [orders == 0.0 and visits > 0.0 and state.cats.fashion.stores == 0.0 and closed_blank,
		"visits=%.0f orders=%.0f stores=%.2f closed_category_untouched=%s" % [visits, orders, state.cats.fashion.stores, closed_blank]]


func _check_acquisition_waits_for_publish() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	world.published = false
	MarketplaceModel.open_category(state, world, "fashion")
	MarketplaceModel.assign(state, "founder", "fashion")
	_run(state, world, 6)
	var before: float = state.cats.fashion.stores
	_run(state, world.merged({"published": true}, true), 1)
	var after: float = state.cats.fashion.stores
	return [before == 0.0 and _near(after, 2.0), "stores before publish=%.2f, first week after=%.2f (1-star base 2)" % [before, after]]


func _check_leaving_zone_stores_fall() -> Array:
	var state := _store_state(["fashion"], 300.0)
	var world := _live_world()
	state.cats.fashion.commission = 25
	var zone := MarketplaceModel.zone(state, world, "fashion")
	var falling := zone == "leaving"
	var path := []
	for i in 8:
		var before: float = state.cats.fashion.stores
		_run(state, world.merged({"week": i}, true), 1)
		falling = falling and state.cats.fashion.stores < before
		path.append("%.2f" % state.cats.fashion.stores)
	return [falling, "zone=%s stores 30 -> %s" % [zone, " ".join(path)]]


func _check_lock_rejects() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world(10)
	var first := MarketplaceModel.set_policy(state, world, "shipping", "store_pays")
	var left := MarketplaceModel.lock_left(state.policy.shipping.day, world)
	var again := MarketplaceModel.set_policy(state, world.merged({"week": 13}, true), "shipping", "user_pays")
	var freed := MarketplaceModel.set_policy(state, world.merged({"week": 14}, true), "shipping", "user_pays")
	var commission := MarketplaceModel.set_commission(state, world, "fashion", 12)
	var commission_again := MarketplaceModel.set_commission(state, world.merged({"week": 13}, true), "fashion", 11)
	var admission_locked := MarketplaceModel.set_policy(state, world, "admission", "registered")
	var admission_open := MarketplaceModel.set_policy(state, world.merged({"tiers": {"reviews": 2}}, true), "admission", "registered")
	var ok: bool = first and left == 4 and not again and freed and commission and not commission_again \
		and not admission_locked and admission_open
	return [ok, "first=%s lock_left=%d at+3=%s at+4=%s commission=%s commission_at+3=%s admission_without_module=%s with_module=%s"
		% [first, left, again, freed, commission, commission_again, admission_locked, admission_open]]


func _check_campaign_override_expires() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world(10)
	MarketplaceModel.set_policy(state, world, "shipping", "big_basket")
	var stored := MarketplaceModel.store_keep(state, world, "fashion", 10)
	var campaign := world.merged({"campaign": {"overrides": {"shipping": "free"}}}, true)
	var during := MarketplaceModel.policy_value(state, campaign, "shipping")
	var keep_during := MarketplaceModel.store_keep(state, campaign, "fashion", 10)
	var mult_during := MarketplaceModel.ship_mult(state, campaign, "fashion")
	var after := MarketplaceModel.policy_value(state, world, "shipping")
	var ok: bool = during == "free" and mult_during == 1.0 and keep_during > stored and after == "big_basket" \
		and MarketplaceModel.store_keep(state, world, "fashion", 10) == stored and state.policy.shipping.day == 10 \
		and MarketplaceModel.lock_left(state.policy.shipping.day, campaign) == 4
	return [ok, "during=%s ship_mult=%.2f keep %.4f -> %.4f; after=%s, kept pick and lock" % [during, mult_during, stored, keep_during, after]]


func _check_revenue_window_spike() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	_run(state, world, 6)
	var steady: float = state.cats.fashion.week.net
	state.revenue_weeks = [steady, steady, steady, steady]
	var before: float = MarketplaceModel.monthly_revenue(state).commission
	var week6 := world.merged({"week": 6}, true)
	var net_with := func(ads: float) -> float:
		var copy := state.duplicate(true)
		MarketplaceModel.close_week(copy, week6.merged({"channel": {"fashion": {"ads": ads}}}, true))
		return copy.cats.fashion.week.net
	var net0: float = net_with.call(0.0)
	var slope: float = (float(net_with.call(1000.0)) - net0) / 1000.0
	MarketplaceModel.close_week(state, week6.merged({"channel": {"fashion": {"ads": (2.0 * steady - net0) / slope}}}, true))
	var rise: float = float(MarketplaceModel.monthly_revenue(state).commission) / before - 1.0
	var doubled: float = state.cats.fashion.week.net / steady
	return [_near(doubled, 2.0, 1e-6) and rise <= 0.25 + 1e-9 and rise > 0.24,
		"net commission of the spike week / steady week = %.4f, monthly revenue %.0f -> +%.2f%%" % [doubled, before, rise * 100.0]]


func _check_premium_closed_no_perk_cost() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var world := _live_world().merged({"tiers": {"listing": 1, "storefront": 1, "checkout": 1, "orders": 2, "integrations": 2}}, true)
	var refused := not MarketplaceModel.set_perk(state, world, "free_shipping", "premium")
	_run(state, world, 6)
	var closed_cost: float = MarketplaceModel.metrics(state, world).perk_cost + MarketplaceModel.monthly_cost(state)
	var open := world.merged({"tiers": world.tiers.merged({"membership": 1}, true)}, true)
	_run(state, open, 6)
	var open_off_cost: float = MarketplaceModel.metrics(state, open).perk_cost + MarketplaceModel.monthly_cost(state)
	var granted := MarketplaceModel.set_perk(state, open.merged({"week": 6}, true), "free_shipping", "premium")
	_run(state, open.merged({"week": 6}, true), 6)
	var on_cost: float = MarketplaceModel.metrics(state, open).perk_cost
	return [refused and closed_cost == 0.0 and open_off_cost == 0.0 and granted and on_cost > 0.0,
		"closed: set_perk refused=%s cost=%.2f; open with perks off cost=%.2f; perk on cost=%.2f over 4 weeks"
		% [refused, closed_cost, open_off_cost, on_cost]]


func _check_campaign_free_shipping_single_write() -> Array:
	var world := _live_world().merged({"tiers": {"listing": 1, "storefront": 1, "checkout": 1, "orders": 1, "integrations": 1,
		"membership": 1}}, true)
	var campaign := world.merged({"campaign": {"overrides": {"shipping": "free"}}}, true)
	var fee: float = MarketplaceModel._c.rules.shipping.fee
	var freq: float = MarketplaceModel._c.visits.member_freq
	var big_share: float = MarketplaceModel.cat_def("fashion").big_basket_share
	var member_share := 300.0 * freq / (3000.0 - 300.0 + 300.0 * freq)
	var ok := true
	var shown := []
	for rule in ["user_pays", "big_basket", "store_pays"]:
		var state := _store_state(["fashion"], 3000.0)
		MarketplaceModel.open_premium(state, world)
		MarketplaceModel.set_perk(state, world, "free_shipping", "premium")
		MarketplaceModel.set_policy(state, world, "shipping", rule)
		state.members = 300.0
		MarketplaceModel.close_week(state, campaign)
		var delivered: float = state.cats.fashion.week.delivered
		var perk_share: float = {"user_pays": 1.0, "big_basket": 1.0 - big_share, "store_pays": 0.0}[rule]
		var perk: float = state.burn.perk_shipping
		var campaign_row: float = state.burn.campaign_shipping
		ok = ok and _near(perk, delivered * member_share * perk_share * fee) and _near(perk + campaign_row, delivered * fee) \
			and (rule != "store_pays" or (perk == 0.0 and _near(campaign_row, delivered * fee)))
		shown.append("%s: perk %.2f + campaign %.2f = %.2f (orders x fee %.2f)" % [rule, perk, campaign_row, perk + campaign_row, delivered * fee])
	return [ok, "stored shipping rule decides the perk's share in a free-shipping campaign week; " + "; ".join(shown)]


func _check_preview_figures() -> Array:
	var state := _timeline(24)
	var world := _world(25)
	var before := JSON.stringify([state, world])
	var rows: Dictionary = MarketplaceModel._c.ledger.rows
	var weeks := int(MarketplaceModel._c.preview.weeks)
	var at_target: bool = _near(state.sat.stores, MarketplaceModel.target_sat(state, "stores"))
	var commission := MarketplaceModel.preview_commission(state, world, "fashion", 13)
	var keep_ratio := MarketplaceModel.store_keep(state, world, "fashion", 13) / MarketplaceModel.store_keep(state, world, "fashion", 12) - 1.0
	var window := MarketplaceModel.preview_policy(state, world, "return_window", "d14")
	var leaving := MarketplaceModel.preview_commission(state, world, "fashion", 25)
	var fee := MarketplaceModel.preview_premium(state, world, {"fee": 6})
	var locked := _store_state(["fashion"], 0.0)
	MarketplaceModel.set_policy(locked, world, "return_window", "d14")
	var refused := MarketplaceModel.preview_policy(locked, world, "return_window", "d30").is_empty() \
		and MarketplaceModel.preview_commission(state, world, "fashion", 12).is_empty() \
		and MarketplaceModel.preview_premium(MarketplaceModel.new_state(), world, {"trial": true}).is_empty()
	var untouched := JSON.stringify([state, world]) == before
	var ok: bool = at_target and _near(commission.store_earnings, keep_ratio) and _near(commission.store_prices, 0.005) \
		and _near(window.store_sat, rows.return_window.stores.d14) \
		and _near(leaving.store_sat, -MarketplaceModel._c.ledger.max_step * weeks) and fee.members < 0.0 and refused and untouched
	return [ok, "commission 12->13 store earnings %+.3f%% (keep ratio %+.3f%%); 14-day window store satisfaction %+.2f (ledger %+.0f); "
		% [commission.store_earnings * 100.0, keep_ratio * 100.0, window.store_sat, rows.return_window.stores.d14]
		+ "commission 25 store satisfaction %+.2f (5 a week for %d weeks); fee 6 members %+.1f; locked or unchanged previews empty=%s; inputs untouched=%s"
		% [leaving.store_sat, weeks, fee.members, refused, untouched]]


func _check_known_store_earnings() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world()
	var before := MarketplaceModel.store_keep(state, world, "fashion", 12)
	var after := MarketplaceModel.store_keep(state, world, "fashion", 13)
	var rise := MarketplaceModel.price_pass("fashion", 13) - MarketplaceModel.price_pass("fashion", 12)
	var change := after / before - 1.0
	return [change < -0.045 and change > -0.055 and _near(rise, 0.005),
		"fashion 12 -> 13: store earnings %+.2f%% (expected about -5%%), store prices %+.2f%% (expected +0.5%%)" % [change * 100.0, rise * 100.0]]


func _check_known_return_rate() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	state.policy.return_window.pick = "d14"
	var rate := MarketplaceModel.return_rate(state, world, "fashion")
	return [_near(rate, 0.216), "fashion, 14 days, no Reviews and Protection: return rate %.4f (expected 21.6%%)" % rate]


func _check_known_order_rate() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world().merged({"bugs": {"checkout": 3}}, true)
	var factors := MarketplaceModel.step_factors(state, world, "fashion")
	var share: float = factors.order * 0.88
	return [absf(share - 0.67) < 0.005, "tier 1 Cart and Checkout with 3 open bugs: placed / reached checkout %.4f (expected 67%%), cap 88%%" % share]


func _check_json_roundtrip() -> Array:
	var state := _timeline(24)
	var world := _world(25)
	var parsed: Dictionary = JSON.parse_string(JSON.stringify(state))
	var same := _equal(MarketplaceModel.project(state, world), MarketplaceModel.project(parsed, world))
	return [same, "state after 24 weeks survives JSON; four weeks on from either copy end identical"]


func _check_ledger_expiry() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world()
	MarketplaceModel.set_commission(state, world, "fashion", 12)
	var row: Dictionary = state.ledger.stores[0]
	var weeks_written: int = row.weeks
	var steps := []
	var held_seven := false
	for i in 8:
		var before: float = state.sat.stores
		_run(state, world.merged({"week": i}, true), 1)
		steps.append(absf(state.sat.stores - before))
		if i == 6:
			held_seven = state.ledger.stores.size() == 1
	var gone: bool = state.ledger.stores.is_empty()
	return [row.points == -4.0 and weeks_written == 8 and held_seven and gone and steps.max() <= 5.0,
		"raise of 2 points: row %s %.0f for %d weeks, still there after 7 closes=%s, gone after 8=%s, biggest weekly move %.2f, sat now %.2f"
		% [row.key, row.points, weeks_written, held_seven, gone, steps.max(), state.sat.stores]]


## Verilen karar: `note_decision` tarafın defterine 8 haftalık "decision" satırı yazar, iki karar iki satırdır; hedef taban + puan
## olur, memnuniyet kapanış başına en çok 5 puan yürür; sekizinci kapanışta satırlar düşer, hedef tabana döner. Elle: taban 70,
## iki satır −6: hedef 58; kapanışlar 65, 60, 58, …, 58, dokuzuncu kapanış tabana doğru 63.
func _check_decision_row_drifts() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world()
	var refused: bool = not MarketplaceModel.note_decision(state, "stores", 0.0) and state.ledger.stores.is_empty()
	var users_side: bool = MarketplaceModel.note_decision(state, "users", 3.0) and state.ledger.stores.is_empty() \
		and _equal(state.ledger.users, [{"key": "decision", "arg": "", "points": 3.0, "weeks": 8}])
	MarketplaceModel.note_decision(state, "stores", -6.0)
	MarketplaceModel.note_decision(state, "stores", -6.0)
	var rows: Array = state.ledger.stores.duplicate(true)
	var target := MarketplaceModel.target_sat(state, "stores")
	var sats := []
	var expiry := false
	for i in 9:
		_run(state, world.merged({"week": i}, true), 1)
		sats.append(state.sat.stores)
		if i == 6:
			expiry = state.ledger.stores.size() == 2
		if i == 7:
			expiry = expiry and state.ledger.stores.is_empty() and MarketplaceModel.target_sat(state, "stores") == 70.0
	var row := {"key": "decision", "arg": "", "points": -6.0, "weeks": 8}
	return [refused and users_side and _equal(rows, [row, row]) and target == 58.0 and expiry
			and _equal(sats, [65.0, 60.0, 58.0, 58.0, 58.0, 58.0, 58.0, 58.0, 63.0]),
		"0 points refused=%s, +3 lands on users only=%s; two -6 decisions: rows %s, target %.0f (70 - 12); still there after 7 closes and gone after 8 with the target back at 70=%s; store satisfaction by close %s"
		% [refused, users_side, rows, target, expiry, sats]]


func _check_zone_limits_consistent() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	var ok := true
	var shown := []
	for cat in MarketplaceModel.cat_ids():
		var limits := MarketplaceModel.zone_limits(state, world, cat)
		var ease: int = limits.comfortable
		var strain: int = limits.strained
		ok = ok and MarketplaceModel.zone_at(state, world, cat, ease) == "comfortable" \
			and MarketplaceModel.zone_at(state, world, cat, ease + 1) != "comfortable" \
			and MarketplaceModel.zone_at(state, world, cat, strain) != "leaving" \
			and MarketplaceModel.zone_at(state, world, cat, strain + 1) == "leaving" \
			and ease >= MarketplaceModel.cat_def(cat).start_commission_pct
		shown.append("%s %d/%d" % [cat, ease, strain])
	return [ok, "highest comfortable / not-leaving commission: " + ", ".join(shown)]


## Ayarı değişebilecek iki seçim tek sabitte durur: fiyata yansıma ve gelir penceresi.
func _check_constants_switch() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	var saved: Dictionary = MarketplaceModel._c.duplicate(true)
	MarketplaceModel._c.stores.pass_through = 0.0
	var cart_before: float = MarketplaceModel.step_factors(state, world, "fashion").cart
	var raised := state.duplicate(true)
	MarketplaceModel.set_commission(raised, world, "fashion", 14)
	var cart_after: float = MarketplaceModel.step_factors(raised, world, "fashion").cart
	var prices: float = MarketplaceModel.metrics(raised, world).store_prices
	MarketplaceModel._c.stores.pass_through = saved.stores.pass_through
	MarketplaceModel._c.income.window_weeks = 1
	var spiky := state.duplicate(true)
	_run(spiky, world, 3)
	var week_net: float = spiky.cats.fashion.week.net
	var monthly: float = MarketplaceModel.monthly_revenue(spiky).commission
	MarketplaceModel._c.income.window_weeks = saved.income.window_weeks
	return [cart_before == cart_after and prices == 0.0 and _near(monthly, week_net * 4.33),
		"pass_through=0: cart factor %.4f -> %.4f at 14%%, store prices %.2f; window=1: monthly %.1f = week x 4.33 (%.1f)"
		% [cart_before, cart_after, prices, monthly, week_net * 4.33]]


func _check_gain_and_weakest() -> Array:
	var state := _store_state(["fashion"], 500.0)
	var world := _live_world().merged({"bugs": {"checkout": 10}}, true)
	_run(state, world, 3)
	var delivered: float = state.cats.fashion.week.delivered
	var worst := MarketplaceModel.weakest_step(state, world, "fashion")
	var fix := MarketplaceModel.gain(state, world, "fashion", {"bugs": {"checkout": 0}})
	var tier := MarketplaceModel.gain(state, world, "fashion", {"tier": {"storefront": 2}})
	var rule := MarketplaceModel.gain(state, world, "fashion", {"policy": {"shipping": "store_pays"}})
	var ok: bool = worst == "order" and _near(fix, delivered * (1.0 / 0.73 - 1.0)) and _near(tier, delivered * (0.96 / 0.83 - 1.0)) \
		and _near(rule, delivered * (1.0 / 0.83 - 1.0))
	return [ok, "weakest=%s (10 checkout bugs); of %.2f weekly orders gain: fix bugs %+.2f, Storefront tier 2 %+.2f, store pays shipping %+.2f"
		% [worst, delivered, fix, tier, rule]]


func _check_acquisition_multipliers() -> Array:
	var state := _store_state(["fashion"], 0.0)
	var world := _live_world()
	var got := {}
	got.base = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	got.five_stars = MarketplaceModel.acquisition_of(state, world, "fashion", 5)
	state.cats.fashion.commission = 15
	got.strained = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	state.cats.fashion.commission = 20
	got.leaving = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	state.cats.fashion.commission = 10
	state.policy.admission.pick = "registered"
	got.registered = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	state.policy.admission.pick = "open"
	got.listing_3 = MarketplaceModel.acquisition_of(state, world.merged({"tiers": {"listing": 3}}, true), "fashion", 1)
	var unknown := MarketplaceModel.set_store_terms(state, "fashion", 0.25, 8)
	MarketplaceModel.set_store_terms(state, "fashion", 0.5, 8)
	got.half_terms = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	MarketplaceModel.set_store_terms(state, "fashion", 0.0, 8)
	got.free_terms = MarketplaceModel.acquisition_of(state, world, "fashion", 1)
	got.unpublished = MarketplaceModel.acquisition_of(state, world.merged({"published": false}, true), "fashion", 1)
	var want := {"base": 2.0, "five_stars": 8.0, "strained": 1.2, "leaving": 0.4, "registered": 1.2, "listing_3": 4.0,
		"half_terms": 2.8, "free_terms": 3.6, "unpublished": 0.0}
	var shown := []
	var ok := not unknown
	for key in want:
		ok = ok and _near(got[key], want[key])
		shown.append("%s=%.2f" % [key, got[key]])
	return [ok, "stores a week for a 1-star (5-star where named): " + " ".join(shown)]


func _check_store_terms_discount() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	MarketplaceModel.assign(state, "founder", "fashion")
	MarketplaceModel.set_store_terms(state, "fashion", 0.0, 8)
	_run(state, world, 3)
	var wk: Dictionary = state.cats.fashion.week
	var gross: float = (wk.delivered - wk.returns) * MarketplaceModel.cat_def("fashion").basket * state.cats.fashion.commission / 100.0
	var joined: float = 0.0
	for n in state.cats.fashion.joined.slice(0, 8):
		joined += n
	var cut: float = gross * minf(1.0, joined / state.cats.fashion.stores)
	# Bütün mağazalar yeni ve pay 0,5: alınacak komisyon elle brütün yarısı (Moda sepeti 38, komisyonu %10), net de odur.
	var fresh := _store_state(["fashion"], 3000.0)
	MarketplaceModel.set_store_terms(fresh, "fashion", 0.5, 8)
	fresh.cats.fashion.joined = [fresh.cats.fashion.stores]
	_run(fresh, world, 1)
	var fw: Dictionary = fresh.cats.fashion.week
	var half: float = (fw.delivered - fw.returns) * 38.0 * 0.10 * 0.5
	var due_ok: bool = half > 0.0 and _near(MarketplaceModel.week_commission(fresh), half) and _near(fw.net, half)
	return [_near(wk.net, gross - cut) and cut > 0.0 and _near(MarketplaceModel.week_commission(state), wk.net) and due_ok,
		"gross %.2f, new-store discount %.2f (stores joined in 8 weeks %.1f of %.1f), net %.2f; every store new at share 0.5: commission due %.2f, half the hand gross %.2f"
		% [gross, cut, joined, state.cats.fashion.stores, wk.net, MarketplaceModel.week_commission(fresh), half]]


func _check_premium_members() -> Array:
	var world := _live_world().merged({"tiers": {"listing": 1, "storefront": 1, "checkout": 1, "orders": 1, "integrations": 1,
		"membership": 1}}, true)
	var results := []
	for variant in [{"trial": true, "fee": 4}, {"trial": false, "fee": 4}, {"trial": false, "fee": 6}]:
		var state := _store_state(["fashion"], 3000.0)
		MarketplaceModel.open_premium(state, world)
		MarketplaceModel.set_perk(state, world, "free_shipping", "premium")
		MarketplaceModel.set_fee(state, world, variant.fee)
		state.premium.trial = variant.trial
		MarketplaceModel.close_week(state, world)
		var approach: float = 0.2 if variant.trial else 0.1
		var target: float = state.users * 0.012 * 3.0 / (1.0 + 0.25 * (variant.fee - 4))
		var paying: float = 0.0 if variant.trial else state.members
		results.append(_near(state.members, approach * target) and _near(MarketplaceModel.monthly_revenue(state).membership, paying * variant.fee))
	return [results[0] and results[1] and results[2],
		"one week in: members = approach x users x 0.012 x pull 3 / (1 + 0.25 x (fee - 4)); trial %s, no trial %s, fee 6 %s; trial members pay nothing"
		% [results[0], results[1], results[2]]]


func _check_zone_rows_need_stores() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	MarketplaceModel.open_category(state, world, "fashion")
	MarketplaceModel.set_policy(state, world, "shipping", "store_pays")
	var zone := MarketplaceModel.zone(state, world, "fashion")
	MarketplaceModel.close_week(state, world)
	var empty: bool = state.ledger.stores.is_empty()
	state.cats.fashion.stores = 10.0
	MarketplaceModel.close_week(state, world.merged({"week": 1}, true))
	var keys: Array = state.ledger.stores.map(func(r: Dictionary) -> String: return r.key)
	return [zone == "leaving" and empty and keys == ["earnings_thin"],
		"store pays shipping puts fashion in the leaving zone: store ledger with no stores empty=%s, with stores %s" % [empty, keys]]


func _check_add_users_bounds() -> Array:
	var state := _store_state(["fashion"], 1000.0)
	state.members = 100.0
	var grown := MarketplaceModel.add_users(state, 250.0)
	var after_growth: float = state.users
	var members_kept: float = state.members
	var unchanged: bool = not MarketplaceModel.add_users(state, 0.0) and state.users == after_growth
	var emptied := MarketplaceModel.add_users(state, -5000.0)
	var already_empty: bool = not MarketplaceModel.add_users(state, -10.0) and state.users == 0.0
	return [grown and after_growth == 1250.0 and members_kept == 100.0 and unchanged and emptied and state.users == 0.0 \
		and state.members == 0.0 and already_empty, "1000 users +250 = %.0f (members kept %.0f); +0 refused=%s; -5000 -> users %.0f, members %.0f; "
		% [after_growth, members_kept, unchanged, state.users, state.members] + "-10 at zero refused=%s" % already_empty]


## Kayıp birikir: ilk hafta elle hesap, ikinci hafta o haftanın elde tutması ve ayrılma oranıyla eklenir.
func _check_lost_counters() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	_run(state, world, 1)
	var first: Dictionary = state.lost.duplicate()
	var users_before: float = state.users
	var stores_before: float = state.cats.fashion.stores
	var sat_before: float = state.sat.users
	var delivered: float = state.cats.fashion.week.delivered
	_run(state, world.merged({"week": 1}, true), 1)
	var week2_users := users_before * (1.0 - (0.94 + 0.0005 * (sat_before - 70.0)))
	var week2_stores := stores_before * (0.008 + 0.07 * clampf(1.0 - delivered / stores_before / 1.2, 0.0, 1.0))
	var ok: bool = _near(first.users, 3000.0 * (1.0 - 0.94)) and _near(first.stores, 30.0 * (0.008 + 0.07 * 1.0)) \
		and _near(state.lost.users, first.users + week2_users) and _near(state.lost.stores, first.stores + week2_stores)
	return [ok, "week 1: users %.2f (3000 x 6%%), stores %.3f (30 x 7.8%%); after week 2 the totals are users %.2f (+%.2f at satisfaction %.0f), stores %.3f (+%.3f)"
		% [first.users, first.stores, state.lost.users, week2_users, sat_before, state.lost.stores, week2_stores]]


func _check_channel_read_values() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	state.policy.shipping.pick = "store_pays"
	var world := _live_world().merged({"tiers": {"storefront": 3, "checkout": 3, "orders": 3, "mobile": 3, "integrations": 3}}, true)
	var fashion := MarketplaceModel.channel_read(state, world, "fashion")
	var featured := MarketplaceModel.channel_read(state, world.merged({"features": ["size_chart", "favorites", "guest_checkout"]}, true), "fashion")
	var closed := MarketplaceModel.channel_read(state, world, "electronics")
	var reach := 0.15 * 0.70 * 0.88 * 0.97
	# Üç kullanıcı ek özelliği yayında değil: Sepete ekledi 0,97 x 0,99, Ödemeye geçti 0,95.
	var conversion := reach * (0.97 * 0.99) * 0.95
	var pools := {"fashion": 82000.0, "electronics": 46000.0, "home": 38000.0, "beauty": 27000.0, "baby": 22000.0, "sports": 22000.0}
	var pools_ok := true
	for cat in pools:
		pools_ok = pools_ok and _near(MarketplaceModel.channel_read(state, world, cat).ad_pool, pools[cat])
	var ok: bool = _near(fashion.conversion, conversion) and _near(featured.conversion, reach) \
		and _near(fashion.monthly_commission, 0.30 / reach * 4.33 * conversion * (1.0 - 0.20) * 38.0 * 0.10) \
		and _near(fashion.organic, 3000.0 * 0.065 / reach * (15.0 / 45.0) + 450.0) and _near(fashion.margin, 0.22) \
		and _near(fashion.base_interest, 450.0) and closed.conversion == 0.0 and closed.organic == 0.0 \
		and closed.monthly_commission == 0.0 and _near(closed.margin, 0.13) and _near(closed.base_interest, 250.0) and pools_ok
	return [ok, "fashion with three user features missing: conversion %.6f (%.6f), all three live %.6f (0.089628), monthly commission per user %.4f, organic visits %.1f (1175.2); "
		% [fashion.conversion, conversion, featured.conversion, fashion.monthly_commission, fashion.organic]
		+ "closed electronics conversion %.1f organic %.1f; six ad pools match=%s" % [closed.conversion, closed.organic, pools_ok]]


func _check_source_revenue_values() -> Array:
	var state := MarketplaceModel.new_state()
	var world := _live_world()
	state.users = 1000.0
	state.revenue_weeks = [100.0, 100.0, 100.0, 100.0]
	state.sources = {"ads": [50.0, 40.0, 30.0], "organic": [10.0], "mail": [0.0, 0.0, 0.0, 20.0]}
	var ads := MarketplaceModel.source_revenue(state, world, "ads")
	var organic := MarketplaceModel.source_revenue(state, world, "organic")
	var mail := MarketplaceModel.source_revenue(state, world, "mail")
	var unknown := MarketplaceModel.source_revenue(state, world, "coupon")
	state.users = 0.0
	var empty := MarketplaceModel.source_revenue(state, world, "ads")
	var want := (50.0 * 0.25 + 40.0 * 0.94 * 0.5 + 30.0 * 0.94 * 0.94 * 0.75) * 400.0 / 1000.0
	var want_mail := 20.0 * 0.94 * 0.94 * 0.94 * 400.0 / 1000.0
	return [_near(ads, want) and _near(organic, 1.0) and _near(mail, want_mail) and unknown == 0.0 and empty == 0.0,
		"1000 users, 400 net commission in four weeks, retention 0.94: ads (50, 40, 30 arriving 0, 1, 2 weeks ago count 1/4, 2/4, 3/4) %.4f (expected %.4f), "
		% [ads, want] + "organic (10 this week) %.2f, mail (20 three weeks ago, counted in full) %.4f (expected %.4f), unknown %.1f, no users %.1f"
		% [organic, mail, want_mail, unknown, empty]]


## `SaveCodec.from_json`'un yükleyişi: JSON'dan dönen tam değerli ondalık tam sayı olur (SaveCodec autoload'a dayanır, `-s`
## betiğinde derlenmez).
func _as_loaded(v: Variant) -> Variant:
	if v is Dictionary:
		var out := {}
		for key in v:
			out[key] = _as_loaded(v[key])
		return out
	if v is Array:
		return v.map(_as_loaded)
	if v is float and v == floorf(v):
		return int(v)
	return v


## Yüklemede tam değerli ondalık tam sayı olur; model bölmelerinde tam sayı bölmesi doğmamalı.
func _check_state_survives_codec() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	state.members = 300.0
	state.cats.fashion.week = {"visits": 900.0, "returning": 500.0, "delivered": 20.0}
	MarketplaceModel.waive_commission(state, 2)
	MarketplaceModel.note_outage(state, 3.0, 40.0)
	MarketplaceModel.open_topic(state, _live_world(), "coupon_abuse", 42.0)
	var decoded: Dictionary = _as_loaded(JSON.parse_string(JSON.stringify(state)))
	var integral: bool = typeof(decoded.users) == TYPE_INT and typeof(decoded.members) == TYPE_INT \
		and typeof(decoded.cats.fashion.stores) == TYPE_INT and typeof(decoded.waive) == TYPE_INT and typeof(decoded.outage.cost) == TYPE_INT
	var world := _live_world()
	var keep := MarketplaceModel.retention(decoded, world)
	var share := MarketplaceModel.returning_share(decoded, ["fashion"])
	var coupon: Array = MarketplaceModel.topic_rows(decoded, world).filter(func(r: Dictionary) -> bool: return r.id == "coupon_abuse")
	var costed := decoded.duplicate(true)
	costed.waive = 0
	MarketplaceModel.close_week(costed, world)
	MarketplaceModel.close_week(decoded, world)
	var ok: bool = integral and _near(keep, 0.94 + 0.03 * (300.0 / 3000.0)) and _near(share, 20.0 * 500.0 / 900.0 / 20.0) \
		and _near(decoded.lost.users, 3000.0 * (1.0 - 0.943)) \
		and _near(decoded.lost.stores, 30.0 * (0.008 + 0.07 * (1.0 - (20.0 / 30.0) / 1.2))) \
		and decoded.waive == 1 and decoded.revenue_weeks[0] == 0.0 and decoded.outage.points == 0.0 and decoded.outage.cost == 0.0 \
		and _near(costed.revenue_weeks[0], costed.cats.fashion.week.net - 40.0) and costed.waive == 0 and costed.outage.cost == 0.0 \
		and decoded.ledger.users.any(func(r: Dictionary) -> bool: return r.key == "outage" and r.points == -3.0) \
		and coupon.size() == 1 and coupon[0].affected == 42.0 and coupon[0].source == "report" and typeof(decoded.topics.coupon_abuse.affected) == TYPE_INT
	return [ok, "integral state decoded as ints=%s: retention %.4f (0.943), returning share %.4f (0.5556), lost users %.2f (171), lost stores %.4f (1.1733); pending waive 2 -> 1: waived close revenue %.0f (no outage cost), Outage row -3; the same state without waive pays the cost: revenue %.0f; a coupon_abuse row opened by the report keeps affected 42"
		% [integral, keep, share, decoded.lost.users, decoded.lost.stores, decoded.revenue_weeks[0], costed.revenue_weeks[0]]]


## Elle konan haftalık sayılarla Moda: ziyaret 10.000, sepet 1.200, ödeme 800, sipariş 600, teslim 560, iade 100; 30 mağaza.
func _topic_state() -> Dictionary:
	var state := _store_state(["fashion"], 3000.0)
	state.cats.fashion.week = {"visits": 10000.0, "cart": 1200.0, "checkout": 800.0, "order": 600.0, "delivered": 560.0, "returns": 100.0}
	return state


## Bir haftalık tik sonrası her konunun o haftaki bileti; durum dokunulmaz.
func _tickets_of(state: Dictionary, world: Dictionary) -> Dictionary:
	var ticked := state.duplicate(true)
	MarketplaceModel.tick_topics(ticked, world)
	var out := {}
	for id in ticked.topics:
		out[id] = ticked.topics[id].tickets[0]
	return out


## Tarafın defterindeki "Geciken talep" satırlarının konuları.
func _late_args(state: Dictionary, side: String) -> Array:
	var late_rows: Array = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.key == "late_topic")
	return late_rows.map(func(r: Dictionary) -> String: return r.arg)


func _check_topic_rows_known() -> Array:
	var state := _topic_state()
	for week in range(1, 6):
		MarketplaceModel.tick_topics(state, _live_world(week))
	var rows := MarketplaceModel.topic_rows(state, _live_world(5))
	# Dünya: Vitrin, Sepet ve Ödeme, Siparişler 1. kademe (0,83); kargoyu kullanıcı öder (0,83); Mobil ve Entegrasyonlar yok (0,90);
	# üç kullanıcı ek özelliği yok (Sepete ekledi 0,97 x 0,99, Ödemeye geçti 0,95).
	var base := 10000.0 * (0.15 * 0.70 * 0.88 * 0.97) * (0.83 * 0.97 * 0.99) * (0.83 * 0.90 * 0.95) * 0.83 * (0.83 * 0.90)
	var tier := base * (0.96 / 0.83 - 1.0)
	var leave_week := 0.008
	var want := {
		"search_filter": [8800.0 * 0.001, tier], "size_chart": [8800.0 * 0.001, base * (1.0 / 0.97 - 1.0)],
		"favorites": [8800.0 * 0.001, base * (1.0 / 0.99 - 1.0)], "guest_checkout": [400.0 * 0.01, base * (1.0 / 0.95 - 1.0)],
		"one_page_checkout": [200.0 * 0.04, tier], "single_connection": [560.0 * 0.02, base * (0.95 / 0.90 - 1.0)],
		"returns_request": [100.0 * 0.08, tier], "reviews_ratings": [560.0 * 0.01, 560.0 * (0.20 - 0.20 * 0.95)],
		"bulk_upload": [30.0 * 0.34 * 0.08, 560.0 * 0.34 * leave_week], "color_size_options": [30.0 * 0.34 * 0.08, 560.0 * 0.34 * leave_week],
		"shipping_label": [30.0 * 0.22 * 0.06, 560.0 * 0.22 * leave_week], "payout_statement": [30.0 * 1.0 * 0.02, 560.0 * leave_week]}
	var ok := rows.size() == want.size()
	var wrong := []
	for row in rows:
		var good: bool = want.has(row.id) and _near(row.tickets, 4.0 * want[row.id][0]) and _near(row.affected, want[row.id][1]) \
			and row.age == 4 and row.status == "waiting" and row.source == "tickets"
		if not good:
			wrong.append(row.id)
		ok = ok and good
	return [ok, "five weekly ticks of a fixed week: %d of 12 ticketed topics listed, tickets over the last four weeks = 4 x weekly, affected orders: "
		% rows.size() + "tier gain %.2f, size_chart %.2f, favorites %.2f, guest_checkout %.2f, single_connection %.2f, reviews_ratings %.2f; age 4; wrong: %s"
		% [tier, want.size_chart[1], want.favorites[1], want.guest_checkout[1], want.single_connection[1], want.reviews_ratings[1], wrong]]


func _check_topic_ticket_gates() -> Array:
	var state := _topic_state()
	state.policy.shipping.pick = "store_pays"
	var tiers := {"storefront": 3, "checkout": 3, "orders": 3, "mobile": 3, "integrations": 3}
	var reach_world := _live_world().merged({"tiers": tiers, "features": ["size_chart", "favorites", "guest_checkout"]}, true)
	var factors := MarketplaceModel.step_factors(state, reach_world, "fashion")
	var reachable := _tickets_of(state, reach_world)
	var users := ["search_filter", "size_chart", "favorites", "guest_checkout", "one_page_checkout", "single_connection", "returns_request"]
	var all_reachable: bool = MarketplaceModel.STEPS.all(func(step: String) -> bool: return factors[step] == 1.0)
	var quiet: bool = users.all(func(id: String) -> bool: return reachable[id] == 0.0)
	var missing_world := _live_world().merged({"tiers": tiers}, true)
	var missing := _tickets_of(state, missing_world)
	var cut := MarketplaceModel.step_factors(state, missing_world, "fashion")
	var live_feature := _tickets_of(state, _live_world().merged({"tiers": tiers.merged({"storefront": 2}, true), "features": ["size_chart"]}, true))
	var raised := state.duplicate(true)
	MarketplaceModel.tick_topics(raised, _live_world())
	var settled: Array = MarketplaceModel.topic_rows(raised, reach_world).filter(func(r: Dictionary) -> bool: return r.id in users)
	var storeless := state.duplicate(true)
	storeless.cats.fashion.stores = 0.0
	var no_stores := _tickets_of(storeless, _live_world())
	var ok: bool = all_reachable and quiet and _near(reachable.reviews_ratings, 5.6) and _near(reachable.payout_statement, 0.6) \
		and _near(cut.cart, 0.97 * 0.99) and _near(cut.checkout, 0.95) and _near(missing.size_chart, 8.8) and _near(missing.favorites, 8.8) \
		and _near(missing.guest_checkout, 4.0) and missing.search_filter == 0.0 and missing.one_page_checkout == 0.0 \
		and live_feature.size_chart == 0.0 and live_feature.search_filter == 0.0 and _near(live_feature.favorites, 8.8) \
		and settled.size() == users.size() and settled.all(func(r: Dictionary) -> bool: return r.affected == 0.0) \
		and no_stores.bulk_upload == 0.0 and no_stores.color_size_options == 0.0 and no_stores.shipping_label == 0.0 \
		and no_stores.payout_statement == 0.0 and _near(no_stores.size_chart, 8.8)
	return [ok, "all steps reachable (every factor 1=%s): user topics quiet=%s, reviews_ratings %.1f and payout_statement %.2f still tick; three features missing: cart factor %.4f, checkout %.2f, "
		% [all_reachable, quiet, reachable.reviews_ratings, reachable.payout_statement, cut.cart, cut.checkout]
		+ "size_chart %.1f favorites %.1f guest_checkout %.1f; size_chart live: %.1f (favorites %.1f, search_filter %.1f live by tier); live topics affect %d rows of 0; no stores: bulk_upload %.1f payout %.1f"
		% [missing.size_chart, missing.favorites, missing.guest_checkout, live_feature.size_chart, live_feature.favorites, live_feature.search_filter,
		settled.size(), no_stores.bulk_upload, no_stores.payout_statement]]


## Satırlar konu durumundan çıkar: taraf başına tek "Geciken talep", yayına çıkan istenmiş konuya "Karşılandı", istenmemişe değil.
func _check_topic_ledger_rows() -> Array:
	var state := _store_state(["fashion"], 3000.0)
	var raised := {"size_chart": 1, "favorites": 3, "bulk_upload": 2, "payout_statement": 5}
	for id in raised:
		state.topics[id].since_day = raised[id]
	var met := func(side: String) -> Array:
		var met_rows: Array = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.key == "met")
		return met_rows.map(func(r: Dictionary) -> Dictionary: return r.duplicate())
	var world := _live_world(12).merged({"planned": ["size_chart"]}, true)
	_run(state, world, 1)
	var week12 := [_late_args(state, "users"), _late_args(state, "stores"), met.call("users").size()]
	_run(state, world.merged({"week": 13, "planned": [], "features": ["size_chart", "guest_checkout"]}, true), 1)
	var week13 := [_late_args(state, "users"), _late_args(state, "stores"), met.call("users")]
	_run(state, world.merged({"week": 14, "features": ["size_chart", "guest_checkout"]}, true), 1)
	var week14 := [_late_args(state, "users"), _late_args(state, "stores")]
	var rows := MarketplaceModel.topic_rows(state, world.merged({"week": 14}, true))
	var shipped: Array = rows.filter(func(r: Dictionary) -> bool: return r.id == "size_chart")
	var met13: Array = week13[2]
	var shipped_row: Dictionary = shipped[0] if shipped else {}
	var ok: bool = week12 == [["size_chart"], ["bulk_upload"], 0] and week13[0] == ["favorites"] and week13[1] == ["bulk_upload"] \
		and met13.size() == 1 and met13[0].arg == "size_chart" and met13[0].points == 3.0 and met13[0].weeks == 7 \
		and week14 == [["favorites"], ["bulk_upload"]] and shipped.size() == 1 and shipped_row.status == "shipped" and shipped_row.age == 13
	return [ok, "week 12 late rows users %s stores %s (size_chart is planned and still counts, payout_statement is not yet overdue); week 13 after size_chart ships: users %s, met rows %d; "
		% [week12[0], week12[1], week13[0], met13.size()] + "week 14 with two overdue store topics: stores %s; size_chart row %s age %d"
		% [week14[1], shipped_row.get("status", "missing"), shipped_row.get("age", -1)]]


## Sprint kartı olmayan konu bilet almaz ve gecikmiş sayılmaz; kartı olan konu aynı dünyada alır ve gecikir.
func _check_cardless_topics_stay_quiet() -> Array:
	var world := _live_world(12).merged({"cardless": ["size_chart", "color_size_options"]}, true)
	var state := _topic_state()
	var tickets := _tickets_of(state, world)
	for id in ["size_chart", "favorites", "color_size_options"]:
		state.topics[id].since_day = 1
	_run(state, world, 1)
	var late := [_late_args(state, "users"), _late_args(state, "stores")]
	var ok: bool = tickets.size_chart == 0.0 and tickets.color_size_options == 0.0 and _near(tickets.favorites, 8.8) \
		and _near(tickets.shipping_label, 30.0 * 0.22 * 0.06) and late == [["favorites"], []]
	return [ok, "size_chart and color_size_options have no card: weekly tickets %.1f and %.1f, favorites %.1f and shipping_label %.3f still tick; "
		% [tickets.size_chart, tickets.color_size_options, tickets.favorites, tickets.shipping_label]
		+ "all three asked in week 1, week 12 late rows users %s stores %s" % late]


## Üç kullanıcı ek özelliği ayrı sayı verir; yayına çıkınca adım tam bu `gain` kadar artar (aynı durumdan iki gerçek kapanış).
func _check_feature_gain_matches_close() -> Array:
	var start := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	var without := start.duplicate(true)
	_run(without, world, 1)
	var delivered: float = without.cats.fashion.week.delivered
	var missing := {"size_chart": ["cart", 0.97], "favorites": ["cart", 0.99], "guest_checkout": ["checkout", 0.95]}
	var gains := []
	var ok := delivered > 0.0
	for id in missing:
		var step: String = missing[id][0]
		var mult: float = missing[id][1]
		var expected := delivered * (1.0 / mult - 1.0)
		var read := MarketplaceModel.gain(without, world, "fashion", {"features": [id]})
		var lit := start.duplicate(true)
		_run(lit, world.merged({"features": [id]}, true), 1)
		var rose: float = lit.cats.fashion.week.delivered - delivered
		ok = ok and _near(read, expected) and _near(rose, read) \
			and _near(lit.cats.fashion.week[step] / float(without.cats.fashion.week[step]), 1.0 / mult)
		gains.append(read)
	ok = ok and not is_equal_approx(gains[0], gains[1]) and not is_equal_approx(gains[1], gains[2]) and not is_equal_approx(gains[0], gains[2])
	return [ok, "weekly orders %.2f; size_chart +%.3f (1/0.97), favorites +%.3f (1/0.99), guest_checkout +%.3f (1/0.95): each equals the rise after a real close with the feature live"
		% [delivered, gains[0], gains[1], gains[2]]]


## Yorum ve Puan'ın etkilenen siparişi, kademeyle iade edilmeyecek siparişe eşittir (iki gerçek kapanışın iade farkı).
func _check_reviews_affected_is_return_gap() -> Array:
	var start := _store_state(["fashion"], 3000.0)
	var world := _live_world()
	var base := start.duplicate(true)
	_run(base, world, 1)
	var tiered := start.duplicate(true)
	_run(tiered, world.merged({"tiers": world.tiers.merged({"reviews": 1}, true)}, true), 1)
	var gap: float = base.cats.fashion.week.returns - tiered.cats.fashion.week.returns
	var delivered: float = base.cats.fashion.week.delivered
	MarketplaceModel.tick_topics(base, world)
	var row: Array = MarketplaceModel.topic_rows(base, world).filter(func(r: Dictionary) -> bool: return r.id == "reviews_ratings")
	var affected: float = row[0].affected if row else -1.0
	return [_near(delivered, tiered.cats.fashion.week.delivered) and _near(affected, gap) and _near(gap, delivered * (0.20 - 0.20 * 0.95)) and gap > 0.0,
		"%.2f weekly orders: Reviews tier 1 cuts returns 20%% -> 19%%, %.3f fewer returns a week in two real closes; reviews_ratings affected %.3f"
		% [delivered, gap, affected]]


func _check_assignment_waits_a_close() -> Array:
	var state := _store_state(["fashion", "electronics"], 0.0)
	var world := _live_world(5)
	var closed := MarketplaceModel.assign(MarketplaceModel.new_state(), "founder", "fashion")
	var first := MarketplaceModel.assign(state, "founder", "fashion")
	var repeat := MarketplaceModel.assign(state, "founder", "fashion")
	var before_close := MarketplaceModel.acquisition(state, world, "fashion")
	_run(state, world, 1)
	var after_close := MarketplaceModel.acquisition(state, world, "fashion")
	var moved := MarketplaceModel.assign(state, "founder", "electronics")
	var old_category := MarketplaceModel.acquisition(state, world, "fashion")
	var new_category := MarketplaceModel.acquisition(state, world, "electronics")
	_run(state, world, 1)
	var resumed := MarketplaceModel.acquisition(state, world, "electronics")
	var absent := MarketplaceModel.acquisition(state, world.merged({"stars": {}}, true), "electronics")
	var left := MarketplaceModel.unassign(state, "founder")
	var again := MarketplaceModel.unassign(state, "founder")
	var ok: bool = not closed and first and not repeat and before_close == 0.0 and _near(after_close, 2.0) and moved \
		and old_category == 0.0 and new_category == 0.0 and _near(resumed, 2.0) and absent == 0.0 and left and not again \
		and state.assign.is_empty()
	return [ok, "closed category refused=%s, before the first close %.2f, after it %.2f (1-star base 2), same category again refused=%s, moved: old %.2f, new %.2f, one close later %.2f, not on duty %.2f, unassign=%s then %s"
		% [not closed, before_close, after_close, not repeat, old_category, new_category, resumed, absent, left, again]]


## Bir hafta komisyon: feragatli kapanışta brüt 0 (net = şirketin karşıladığı indirimin eksisi), izleyen kapanış normale döner, haftalar
## toplanır, önizleme bekleyeni görmez. Elle: Moda sepeti 38, komisyonu %10; Elektronik sepeti 95, komisyonu %6.
func _check_waive_zeroes_one_close() -> Array:
	var world := _live_world()
	var discount := world.merged({"campaign": {"kind": "coupon", "stage": "run", "weeks_left": 1, "weeks": 1, "prep": {"done": 1, "total": 1},
		"cats": ["fashion"], "depth": 0.0, "company_share": 1.0, "participation_mult": 1.0, "settings": {"amount": 10, "count": 2},
		"overrides": {}}}, true)
	var start := _store_state(["fashion", "electronics"], 3000.0)
	var normal := func(s: Dictionary) -> float:
		var f: Dictionary = s.cats.fashion.week
		var e: Dictionary = s.cats.electronics.week
		return (f.delivered - f.returns) * 38.0 * 0.10 + (e.delivered - e.returns) * 95.0 * 0.06
	var plain := start.duplicate(true)
	_run(plain, discount, 1)
	var waived := start.duplicate(true)
	var refused: bool = not MarketplaceModel.waive_commission(waived, 0) and not MarketplaceModel.waive_commission(waived, -2) and waived.waive == 0
	MarketplaceModel.waive_commission(waived, 1)
	_run(waived, discount, 1)
	var zero_nets := [waived.cats.fashion.week.net, waived.cats.electronics.week.net]
	var zeroed: bool = waived.cats.fashion.week.net == -20.0 and waived.cats.electronics.week.net == 0.0 and waived.revenue_weeks[0] == -20.0 \
		and waived.cats.fashion.week.delivered == plain.cats.fashion.week.delivered \
		and _near(plain.revenue_weeks[0], normal.call(plain) - 20.0) and plain.revenue_weeks[0] > 0.0
	# Komisyonsuz haftanın bedeli: kapanıştan önce 0; kampanyanın karşılanan kısmı, bekleyen ve geçen komisyonsuz hafta ve kapanıştan
	# sonraki komisyon değişikliği onu değiştirmez.
	var pending_waive := plain.duplicate(true)
	MarketplaceModel.waive_commission(pending_waive, 1)
	MarketplaceModel.set_commission(pending_waive, world, "fashion", 12)
	var waived_cost := MarketplaceModel.week_commission(waived)
	var cost_ok: bool = MarketplaceModel.week_commission(start) == 0.0 and _near(MarketplaceModel.week_commission(plain), normal.call(plain)) \
		and pending_waive.cats.fashion.commission == 12 and _near(MarketplaceModel.week_commission(pending_waive), normal.call(plain)) \
		and waived_cost > 0.0 and _near(waived_cost, normal.call(waived))
	_run(waived, world.merged({"week": 1}, true), 1)
	var back: bool = waived.waive == 0 and waived.revenue_weeks[0] > 0.0 and _near(waived.revenue_weeks[0], normal.call(waived))
	var twice := start.duplicate(true)
	MarketplaceModel.waive_commission(twice, 1)
	MarketplaceModel.waive_commission(twice, 1)
	var stacked: int = twice.waive
	var nets := []
	for i in 3:
		_run(twice, world.merged({"week": i}, true), 1)
		nets.append(twice.revenue_weeks[0])
	var two_weeks: bool = stacked == 2 and nets[0] == 0.0 and nets[1] == 0.0 and nets[2] > 0.0 and _near(nets[2], normal.call(twice)) and twice.waive == 0
	var pending := start.duplicate(true)
	MarketplaceModel.waive_commission(pending, 2)
	var preview_blind: bool = pending.waive == 2 and _equal(MarketplaceModel.project(pending, world), MarketplaceModel.project(start, world))
	return [refused and zeroed and back and two_weeks and preview_blind and cost_ok,
		"waive 1: rejects 0 and -2=%s; waived close net Fashion %.2f, Electronics %.2f (the company covers a 20 discount; the same week without waive %.2f), orders unchanged; "
		% [refused, zero_nets[0], zero_nets[1], plain.revenue_weeks[0]]
		+ "next close back to %.2f (hand %.2f); waive 2 stacked=%d: nets %.2f %.2f %.2f, left %d; preview ignores pending waive=%s; "
		% [waived.revenue_weeks[0], normal.call(waived), stacked, nets[0], nets[1], nets[2], twice.waive, preview_blind]
		+ "a waived week's cost: 0 before a close, gross by hand after it (the coupon's covered part left out), unchanged by a pending waive and a later raise to 12%%, the waived close's own gross %.2f=%s"
		% [waived_cost, cost_ok]]


## Kesinti: izleyen kapanışta "Kesinti" satırı `rows.outage.weeks` hafta sürer, bedel toplam net komisyondan düşer, bekleyen sıfırlanır.
func _check_outage_row_and_cost() -> Array:
	var world := _live_world()
	var start := _store_state(["fashion", "electronics"], 3000.0)
	var plain := start.duplicate(true)
	_run(plain, world, 1)
	var plain_net: float = plain.cats.fashion.week.net + plain.cats.electronics.week.net
	var hit := start.duplicate(true)
	var refused: bool = not MarketplaceModel.note_outage(hit, 0.0, 0.0)
	MarketplaceModel.note_outage(hit, 3.0, 40.0)
	MarketplaceModel.note_outage(hit, 2.0, 10.0)
	var summed: bool = hit.outage.points == 5.0 and hit.outage.cost == 50.0
	var pending := hit.duplicate(true)
	var rows := func(s: Dictionary) -> Array:
		return s.ledger.users.filter(func(r: Dictionary) -> bool: return r.key == "outage")
	var counts := []
	var first_row := {}
	var first_revenue := 0.0
	var first_drop := 0.0
	var split_kept := false
	var cleared := false
	var costless_after := true
	for i in 4:
		_run(hit, world.merged({"week": i}, true), 1)
		var found: Array = rows.call(hit)
		counts.append(found.size())
		if i == 0:
			first_row = found[0].duplicate() if found.size() == 1 else {}
			first_revenue = hit.revenue_weeks[0]
			first_drop = MarketplaceModel.target_sat(hit, "users") - MarketplaceModel.target_sat(plain, "users")
			split_kept = _near(hit.cats.fashion.week.net, plain.cats.fashion.week.net) and _near(hit.cats.electronics.week.net, plain.cats.electronics.week.net)
			# Komisyonsuz haftanın bedeli kesinti haftasında da brüttür: kesintinin bedeli ona girmez.
			split_kept = split_kept and _near(MarketplaceModel.week_commission(hit), plain_net)
			cleared = hit.outage.points == 0.0 and hit.outage.cost == 0.0
		else:
			costless_after = costless_after and _near(hit.revenue_weeks[0], hit.cats.fashion.week.net + hit.cats.electronics.week.net)
	var row_ok: bool = first_row.get("points", 0.0) == -5.0 and first_row.get("weeks", 0) == 3
	var cost_ok: bool = _near(first_revenue, plain_net - 50.0) and split_kept and first_revenue < plain_net
	var preview_blind: bool = pending.outage.cost == 50.0 and _equal(MarketplaceModel.project(pending, world), MarketplaceModel.project(start, world))
	# Komisyonsuz hafta ile kesinti aynı kapanışta: bedel düşmez (komisyon zaten 0), satır yazılır, izleyen kapanış normal.
	var covered := world.merged({"campaign": {"kind": "coupon", "stage": "run", "weeks_left": 1, "weeks": 1, "prep": {"done": 1, "total": 1},
		"cats": ["fashion"], "depth": 0.0, "company_share": 1.0, "participation_mult": 1.0, "settings": {"amount": 10, "count": 2},
		"overrides": {}}}, true)
	var both := start.duplicate(true)
	MarketplaceModel.waive_commission(both, 1)
	MarketplaceModel.note_outage(both, 3.0, 40.0)
	_run(both, covered, 1)
	var both_net: float = both.revenue_weeks[0]
	var both_rows: Array = rows.call(both)
	var both_cleared: bool = both.outage.cost == 0.0 and both.waive == 0
	_run(both, world.merged({"week": 1}, true), 1)
	var both_ok: bool = both_net == -20.0 and both_rows.size() == 1 and both_rows[0].points == -3.0 and both_cleared and rows.call(both).size() == 1
	both_ok = both_ok and both.revenue_weeks[0] > 0.0 and _near(both.revenue_weeks[0], both.cats.fashion.week.net + both.cats.electronics.week.net)
	return [refused and summed and counts == [1, 1, 1, 0] and row_ok and cost_ok and _near(first_drop, -5.0) and cleared and costless_after and preview_blind \
		and both_ok,
		"note_outage rejects 0/0=%s, 3+2 points and 40+10 cost add up=%s; closes 1-4 leave outage rows %s (written once, 4 weeks), first row %s; "
		% [refused, summed, counts, first_row] + "net commission %.2f -> %.2f (cost 50 off the total, category rows and the week's gross commission unchanged=%s), target satisfaction %+.2f, pending cleared=%s, "
		% [plain_net, first_revenue, cost_ok, first_drop, cleared] + "later weeks cost nothing=%s, preview ignores pending=%s; waive and outage in one close: month net %.2f (only the company discount), row written, next close normal=%s"
		% [costless_after, preview_blind, both_net, both_ok]]


## Kaçan siparişin komisyonu: geçen haftaki teslim payıyla ağırlıklı; teslim yoksa eşit; iade ve kapalı kategori sayılmaz.
func _check_lost_commission_weighted() -> Array:
	var state := _store_state(["fashion", "electronics"], 3000.0)
	state.cats.fashion.week = {"delivered": 600.0, "returns": 100.0}
	state.cats.electronics.week = {"delivered": 200.0, "returns": 50.0}
	state.cats.home.week = {"delivered": 1000.0}
	var weighted := MarketplaceModel.lost_commission(state, 10.0)
	state.cats.fashion.commission = 12
	var raised := MarketplaceModel.lost_commission(state, 10.0)
	state.cats.fashion.commission = 10
	state.cats.fashion.week = {}
	state.cats.electronics.week = {}
	var even := MarketplaceModel.lost_commission(state, 10.0)
	var none := MarketplaceModel.lost_commission(MarketplaceModel.new_state(), 10.0)
	# Elle: Moda 3,80 ve Elektronik 5,70 sipariş başına; payları 0,75 ve 0,25 (komisyon %12'de Moda 4,56), teslim yokken 0,5 ve 0,5.
	return [_near(weighted, 42.75) and _near(raised, 48.45) and _near(even, 47.5) and none == 0.0,
		"10 lost orders: Fashion 600 / Electronics 200 delivered %.2f (42.75), Fashion at 12%% %.2f (48.45), no deliveries last week %.2f (47.5), no open category %.1f"
		% [weighted, raised, even, none]]


func _check_backup_mult_tiers() -> Array:
	var got := []
	for tiers in [{}, {"backup": 1}, {"backup": 2}, {"backup": 3}, {"mobile": 3, "accounts": 3}]:
		got.append(MarketplaceModel.backup_mult(_live_world().merged({"tiers": tiers}, true)))
	got.append(MarketplaceModel.backup_mult(MarketplaceModel.new_world()))
	return [_equal(got, [1.0, 0.7, 0.5, 0.3, 1.0, 1.0]), "outage multiplier without Backup, tiers 1-3, other modules only, default world: %s" % [got]]


## Rapordan açılan konu: bileti olmadan satır olur, verilen etkilenen sipariş durur; ikinci çağrı, bilinmeyen kimlik ve bileti başlamış konu
## reddedilir. Sekiz haftayı geçince "Geciken talep" konunun adıyla yazılır (planda olsa da), yayına çıkınca "Karşılandı" yazılır ve etkilenen 0 olur.
func _check_open_topic_report_row() -> Array:
	var state := _topic_state()
	var world := _live_world(10)
	var silent: bool = MarketplaceModel.topic_rows(state, world).is_empty()
	var opened := MarketplaceModel.open_topic(state, world, "coupon_abuse", 42.0)
	var again := MarketplaceModel.open_topic(state, world.merged({"week": 12}, true), "coupon_abuse", 7.0)
	var unknown := MarketplaceModel.open_topic(state, world, "no_such_topic", 1.0)
	MarketplaceModel.tick_topics(state, world)
	var ticketed := MarketplaceModel.open_topic(state, world, "size_chart", 5.0)
	var rows := MarketplaceModel.topic_rows(state, world.merged({"week": 12}, true))
	var coupon: Array = rows.filter(func(r: Dictionary) -> bool: return r.id == "coupon_abuse")
	var row: Dictionary = coupon[0] if coupon.size() == 1 else {}
	var size_chart: Array = rows.filter(func(r: Dictionary) -> bool: return r.id == "size_chart")
	var row_ok: bool = row.get("side") == "users" and row.get("module") == "checkout" and row.get("source") == "report" \
		and row.get("tickets") == 0.0 and row.get("affected") == 42.0 and row.get("age") == 2 and row.get("status") == "waiting"
	var ticks_ok: bool = size_chart.size() == 1 and size_chart[0].source == "tickets" and size_chart[0].tickets > 0.0 and not state.topics.has("no_such_topic")
	var live := _store_state(["fashion"], 3000.0)
	MarketplaceModel.open_topic(live, world, "coupon_abuse", 42.0)
	_run(live, world.merged({"week": 18}, true), 1)
	var week18: Array = _late_args(live, "users")
	var planned := world.merged({"week": 19, "planned": ["coupon_abuse"]}, true)
	_run(live, planned, 1)
	var week19: Array = _late_args(live, "users")
	var waiting: Array = MarketplaceModel.topic_rows(live, planned)
	var shipped_world := world.merged({"week": 20, "features": ["coupon_abuse"]}, true)
	_run(live, shipped_world, 1)
	var week20: Array = _late_args(live, "users")
	var met: Array = live.ledger.users.filter(func(r: Dictionary) -> bool: return r.key == "met")
	var done: Array = MarketplaceModel.topic_rows(live, shipped_world)
	var life_ok: bool = week18 == [] and week19 == ["coupon_abuse"] and waiting.size() == 1 and waiting[0].status == "planned" \
		and waiting[0].affected == 42.0 and week20 == [] and met.size() == 1 and met[0].arg == "coupon_abuse" and met[0].points == 3.0 \
		and done.size() == 1 and done[0].status == "shipped" and done[0].affected == 0.0 and done[0].tickets == 0.0 and done[0].age == 10
	return [silent and opened and not again and not unknown and not ticketed and row_ok and ticks_ok and life_ok,
		"unopened topics are silent=%s; opened at week 10 with 42 affected=%s, second call %s, unknown id %s, topic already ticketed %s; row at week 12 %s; "
		% [silent, opened, again, unknown, ticketed, row] + "size_chart keeps its own tickets=%s; late rows week 18 %s, week 19 (planned) %s, week 20 (shipped) %s; met rows %d; shipped row %s"
		% [ticks_ok, week18, week19, week20, met.size(), done]]


## `cfg` marketplace.json'u nokta yoluyla okur; sözlük ve dizi kopya döner: okuyanın boşalttığı kopya sabiti değiştirmez.
func _check_cfg_reads_constants() -> Array:
	var reach: Dictionary = MarketplaceModel.cfg("steps.reach")
	var options: Array = MarketplaceModel.cfg("rules.options.shipping")
	var limits: Array = [MarketplaceModel.cfg("commission.min"), MarketplaceModel.cfg("commission.max")]
	var read := "steps.reach %s, rules.options.shipping %s, commission limits %s" % [reach, options, limits]
	var ok: bool = _equal(reach, {"cart": 0.15, "checkout": 0.70, "order": 0.88, "delivered": 0.97}) \
		and options == ["user_pays", "big_basket", "store_pays"] and _equal(limits, [1, 30])
	reach.cart = 0.0
	options.clear()
	var cart: float = MarketplaceModel.cfg("steps.reach.cart")
	var kept: Array = MarketplaceModel.cfg("rules.options.shipping")
	return [ok and _near(cart, 0.15) and kept.size() == 3,
		"%s; after the reader emptied its copies the constants read reach.cart %s and %d shipping options" % [read, cart, kept.size()]]


## `funnel` açık kategorilerin geçen haftaki satırlarının toplamıdır; ziyaret üç kaynağının toplamıdır; ilk kapanışını bekleyen açık
## kategori 0 katar.
func _check_funnel_sums_categories() -> Array:
	var state := _timeline(24)
	var total := MarketplaceModel.funnel(state)
	var fashion: Dictionary = state.cats.fashion.week
	var electronics: Dictionary = state.cats.electronics.week
	var keys := ["visits", "organic", "channel", "campaign", "returning", "cart", "checkout", "order", "delivered"]
	var summed := total.size() == keys.size()
	for key in keys:
		summed = summed and _near(total[key], fashion.get(key, 0.0) + electronics.get(key, 0.0))
	var parts: float = total.organic + total.channel + total.campaign + total.returning
	var waiting := MarketplaceModel.new_state()
	MarketplaceModel.open_category(waiting, _live_world(), "fashion")
	var nothing_open := MarketplaceModel.funnel(MarketplaceModel.new_state())
	var before_close := MarketplaceModel.funnel(waiting)
	var blank: bool = keys.all(func(key: String) -> bool: return nothing_open[key] == 0.0 and before_close[key] == 0.0)
	return [summed and _near(total.visits, parts) and total.channel > 0.0 and total.delivered > 0.0 and blank,
		"week 24, Fashion + Electronics: visits %.0f (%.0f organic + %.0f channel + %.0f returning) -> placed %.0f -> delivered %.0f, every key is the sum of the two rows=%s; no open category and an open category before its first close are all zero=%s"
		% [total.visits, total.organic, total.channel, total.returning, total.order, total.delivered, summed, blank]]


## Adımın ipucu: modül, kademe, sıradaki kademe; `next_gain` aynı değişikliğin `gain` toplamı (elle: sipariş × kademe oranı), son kademede 0 ve
## modül ikinciye geçer; `bugs` ve `bug_gain` hatanın kıstığı iki adımda açık hata ve düzelmesinin kazancı, öbür ikisinde 0 (Vitrin'in
## iki açık hatası Sepete ekledi adımında sayılmaz).
func _check_step_hint_matches_gain() -> Array:
	var state := _store_state(["fashion", "electronics"], 3000.0)
	var world := _live_world().merged({"bugs": {"storefront": 2, "checkout": 3, "orders": 2}}, true)
	_run(state, world, 3)
	var delivered: float = state.cats.fashion.week.delivered + state.cats.electronics.week.delivered
	var gain_sum := func(at: Dictionary, change: Dictionary) -> float:
		return MarketplaceModel.gain(state, at, "fashion", change) + MarketplaceModel.gain(state, at, "electronics", change)
	# Adım: [modül, kademe, sıradaki kademe, adımı kısan açık hata, sıradaki kademenin oranı, düzelmenin oranı]
	var want := {"cart": ["storefront", 1, 2, 0, 0.96 / 0.83, 1.0], "checkout": ["mobile", 0, 1, 0, 0.95 / 0.90, 1.0],
		"order": ["checkout", 1, 2, 3, 0.96 / 0.83, 1.0 / (1.0 - 0.027 * 3)],
		"delivered": ["orders", 1, 2, 2, 0.96 / 0.83, 1.0 / (1.0 - 0.027 * 2)]}
	var ok := delivered > 0.0
	var shown := []
	for step in want:
		var hint := MarketplaceModel.step_hint(state, world, step)
		var row: Array = want[step]
		ok = ok and hint.module == row[0] and hint.tier == row[1] and hint.next_tier == row[2] and hint.bugs == row[3] \
			and _near(hint.next_gain, delivered * (row[4] - 1.0)) \
			and _near(hint.next_gain, gain_sum.call(world, {"tier": {row[0]: row[2]}})) \
			and _near(hint.bug_gain, delivered * (row[5] - 1.0))
		shown.append("%s %s %d->%d +%.2f bugs %d +%.2f" % [step, hint.module, hint.tier, hint.next_tier, hint.next_gain, hint.bugs, hint.bug_gain])
	var maxed := world.merged({"tiers": world.tiers.merged({"checkout": 3, "orders": 3}, true)}, true)
	var last := MarketplaceModel.step_hint(state, maxed, "order")
	var moved := MarketplaceModel.step_hint(state, maxed, "delivered")
	var all_last := MarketplaceModel.step_hint(state, maxed.merged({"tiers": maxed.tiers.merged({"integrations": 3}, true)}, true), "delivered")
	var none_open := MarketplaceModel.step_hint(MarketplaceModel.new_state(), world, "order")
	ok = ok and last.module == "checkout" and last.tier == 3 and last.next_tier == 0 and last.next_gain == 0.0 \
		and moved.module == "integrations" and moved.tier == 0 and moved.next_tier == 1 and moved.next_gain > 0.0 \
		and _near(moved.next_gain, gain_sum.call(maxed, {"tier": {"integrations": 1}})) \
		and all_last.module == "integrations" and all_last.tier == 3 and all_last.next_tier == 0 and all_last.next_gain == 0.0 \
		and none_open.bugs == 3 and none_open.next_gain == 0.0 and none_open.bug_gain == 0.0
	return [ok, "%.2f weekly orders; " % delivered + "; ".join(shown) + "; last tier: order %s tier %d next %d +%.1f; Orders at 3 moves Delivered to %s tier %d next %d +%.2f; both at 3: %s next %d +%.1f; no open category: +%.1f +%.1f"
		% [last.module, last.tier, last.next_tier, last.next_gain, moved.module, moved.tier, moved.next_tier, moved.next_gain, all_last.module,
		all_last.next_tier, all_last.next_gain, none_open.next_gain, none_open.bug_gain]]


## `ledger_worst` en küçük puanı seçer; olumlu satırı saymaz; eşitlikte koşul sürdükçe duran satırı, o da eşitse listede öndekini seçer; olumsuz satır
## yoksa ya da defter boşsa boş sözlük. Gerçek bir defterde iade süresi satırı komisyon artışından ağır gelir.
func _check_ledger_worst_picks_heaviest() -> Array:
	var state := MarketplaceModel.new_state()
	var timed := {"key": "commission_raised", "arg": "fashion", "points": -4.0, "weeks": 5}
	var strained := {"key": "strained", "arg": "fashion", "points": -4.0, "weeks": MarketplaceModel.WHILE}
	var boost := {"key": "return_shipping_paid", "arg": "", "points": 5.0, "weeks": MarketplaceModel.WHILE}
	var thin := {"key": "earnings_thin", "arg": "electronics", "points": -10.0, "weeks": MarketplaceModel.WHILE}
	var selection := {"key": "thin_selection", "arg": "home", "points": -4.0, "weeks": MarketplaceModel.WHILE}
	var worst_of := func(rows: Array) -> String:
		state.ledger.stores = rows
		return MarketplaceModel.ledger_worst(state, "stores").get("key", "")
	var picked: Array = [worst_of.call([timed, strained, boost, thin, selection]), worst_of.call([timed, strained, boost, selection]),
		worst_of.call([strained, timed]), worst_of.call([timed, boost]), worst_of.call([boost]), worst_of.call([])]
	var full := {"key": "late_topic", "arg": "size_chart", "points": -4.0, "weeks": MarketplaceModel.WHILE}
	state.ledger.users = [full]
	var users_row := MarketplaceModel.ledger_worst(state, "users")
	var stores_row := MarketplaceModel.ledger_worst(state, "stores")
	var real := _store_state(["fashion"], 3000.0)
	var world := _live_world(10)
	MarketplaceModel.set_commission(real, world, "fashion", 12)
	MarketplaceModel.set_policy(real, world, "return_window", "d30")
	_run(real, world, 1)
	var live := MarketplaceModel.ledger_worst(real, "stores")
	var ok: bool = picked == ["earnings_thin", "strained", "strained", "commission_raised", "", ""] and users_row == full and stores_row.is_empty() \
		and live.get("key") == "return_window" and live.get("points") == -6.0 and real.ledger.stores.any(func(r: Dictionary) -> bool: return r.key == "commission_raised")
	return [ok, "rows (-4 for 5 weeks, -4 while, +5, -10, -4 while) %s; without the -10 %s; the -4 while row listed after the timed one wins the tie, and also listed before it %s; one timed -4 beside a +5 %s; only +5 '%s'; empty '%s'; "
		% [picked[0], picked[1], picked[2], picked[3], picked[4], picked[5]] + "other side holds its own row=%s, empty side is empty=%s; real ledger after a raise to 12 and a 30-day window: %s %.0f"
		% [users_row == full, stores_row.is_empty(), live.get("key"), live.get("points", 0.0)]]


## `crew` kategorideki kişileri atama sırasıyla verir: ilk kapanıştan önce `live` false, sonra true; işbaşında olmayan `working` false ve `weekly` 0;
## canlı ve işbaşındakilerin `weekly` toplamı `acquisition`'dır; `weekly` bölgeyi izler; taşınan kişi eski kategoride görünmez.
func _check_crew_follows_assignment() -> Array:
	var state := _store_state(["fashion", "electronics"], 0.0)
	var world := _live_world(5).merged({"stars": {"founder": 1, "sales_a": 3, "sales_c": 2}}, true)
	MarketplaceModel.assign(state, "founder", "fashion")
	MarketplaceModel.assign(state, "sales_a", "fashion")
	MarketplaceModel.assign(state, "sales_b", "electronics")
	var fashion_before := MarketplaceModel.crew(state, world, "fashion")
	var away := MarketplaceModel.crew(state, world, "electronics")
	var paid_before := MarketplaceModel.acquisition(state, world, "fashion")
	_run(state, world, 1)
	MarketplaceModel.assign(state, "sales_c", "fashion")
	var fashion_after := MarketplaceModel.crew(state, world, "fashion")
	var paid_after := MarketplaceModel.acquisition(state, world, "fashion")
	var counted := 0.0
	for member in fashion_after:
		counted += member.weekly if member.live and member.working else 0.0
	state.cats.fashion.commission = 20
	var leaving := MarketplaceModel.crew(state, world, "fashion").map(func(m: Dictionary) -> float: return m.weekly)
	MarketplaceModel.assign(state, "founder", "electronics")
	var moved := MarketplaceModel.crew(state, world, "electronics").map(func(m: Dictionary) -> String: return m.person)
	var stayed := MarketplaceModel.crew(state, world, "fashion").map(func(m: Dictionary) -> String: return m.person)
	moved.sort()
	var ok: bool = _equal(fashion_before, [{"person": "founder", "live": false, "working": true, "weekly": 2.0},
			{"person": "sales_a", "live": false, "working": true, "weekly": 4.0}]) \
		and _equal(away, [{"person": "sales_b", "live": false, "working": false, "weekly": 0.0}]) and paid_before == 0.0 \
		and _equal(fashion_after, [{"person": "founder", "live": true, "working": true, "weekly": 2.0},
			{"person": "sales_a", "live": true, "working": true, "weekly": 4.0}, {"person": "sales_c", "live": false, "working": true, "weekly": 3.0}]) \
		and _near(counted, 6.0) and _near(paid_after, counted) and _equal(leaving, [0.4, 0.8, 0.6]) \
		and moved == ["founder", "sales_b"] and stayed == ["sales_a", "sales_c"] and MarketplaceModel.crew(state, world, "home").is_empty()
	return [ok, "before the first close: %s; Electronics' away person %s; acquisition %.1f; after one close and a newcomer: %s, live and working add to %.1f = acquisition %.1f; "
		% [fashion_before, away, paid_before, fashion_after, counted, paid_after] + "at 20%% commission (leaving zone) weekly %s; founder moved to Electronics: Electronics %s, Fashion %s; closed Home empty"
		% [leaving, moved, stayed]]


## Yolun bütün çarpanları 1: son kademeler, kullanıcı ek özellikleri yayında.
func _perfect_world() -> Dictionary:
	return _live_world().merged({"tiers": {"storefront": 3, "checkout": 3, "orders": 3, "mobile": 3, "integrations": 3},
		"features": ["size_chart", "favorites", "guest_checkout"]}, true)


## `cats` açık ve mağazası gerekenin üstünde, geçen hafta siparişi bol (mağaza boşta sayılıp ayrılmaz), kargoyu mağaza öder.
func _busy_state(cats: Array, users: float) -> Dictionary:
	var state := _store_state(cats, users)
	state.policy.shipping.pick = "store_pays"
	for cat in cats:
		state.cats[cat].stores += 5.0
		state.cats[cat].week = {"delivered": 1000.0}
	return state


## Geri gelenin teslim edilen siparişi: kategorinin siparişi × geri gelen ziyaretin payı.
func _returning_orders(state: Dictionary, cats: Array) -> float:
	var orders := 0.0
	for cat in cats:
		orders += state.cats[cat].week.delivered
	return orders * MarketplaceModel.returning_share(state, cats)


## Geri gelen kullanıcı sipariş verir: yol kusursuzken bin kullanıcı Moda'da haftada sipariş sıklığı kadar (300) sipariş bırakır;
## Pazarlama'nın yüzde 10'luk geri dönüş katkısıyla 330, yüz üyeyle 312 (üyenin sıklığı 1,4 kat). Ev ve Yaşam da açık ve doluyken
## toplam, iki sıklığın çekicilik ağırlıklı ortalamasıdır (290,45), toplamı (570) değil. Ev ve Yaşam'ın mağazası azken payı
## seçeneğiyle küçülür.
func _check_returning_orders_follow_frequency() -> Array:
	var world := _perfect_world()
	var one := _busy_state(["fashion"], 1000.0)
	_run(one, world, 1)
	var alone := _returning_orders(one, ["fashion"])
	var lifted := _busy_state(["fashion"], 1000.0)
	_run(lifted, world.merged({"return_lift": 0.1}, true), 1)
	var members := _busy_state(["fashion"], 1000.0)
	members.members = 100.0
	_run(members, world, 1)
	var two := _busy_state(["fashion", "home"], 1000.0)
	_run(two, world, 1)
	var both := _returning_orders(two, ["fashion", "home"])
	var mixed := 1000.0 * (0.30 * 450.0 + 0.27 * 210.0) / (450.0 + 210.0)
	var thin := _busy_state(["fashion", "home"], 1000.0)
	thin.cats.home.stores = 3.0
	_run(thin, world, 1)
	var shelf: float = thin.cats.home.stores / 17.0
	var home_share: float = 210.0 * shelf / (450.0 + 210.0 * shelf)
	var home_visits: float = 1000.0 * 0.27 / (0.15 * 0.70 * 0.88 * 0.97) * home_share
	var ok: bool = _near(alone, 300.0, 1e-6) and _near(_returning_orders(lifted, ["fashion"]), 330.0, 1e-6) \
		and _near(_returning_orders(members, ["fashion"]), 312.0, 1e-6) and _near(both, mixed, 1e-6) and shelf < 0.5 \
		and _near(thin.cats.home.week.returning, home_visits, 1e-6) \
		and _near(_returning_orders(thin, ["fashion"]), 1000.0 * 0.30 * (1.0 - home_share), 1e-6)
	return [ok, "1000 users on a perfect path: Fashion alone %.2f orders a week from returning users (300 = 0.30 each), %.2f with a 10%% return lift (330), %.2f with 100 members (312); "
		% [alone, _returning_orders(lifted, ["fashion"]), _returning_orders(members, ["fashion"])]
		+ "Fashion and Home, both stocked, %.2f (%.2f, the interest-weighted mean, not 570); Home at %.2f of its stores takes %.4f of the returning users: %.1f visits (%.1f)"
		% [both, mixed, shelf, home_share, thin.cats.home.week.returning, home_visits]]


## Yol kusursuzken Moda'nın bir kapanışta kendiliğinden kazandığı yeni kullanıcı: `users` kullanıcı ve `sat` kullanıcı memnuniyetiyle.
func _organic_newcomers(users: float, sat: float) -> float:
	var state := _busy_state(["fashion"], users)
	state.sat.users = sat
	_run(state, _perfect_world(), 1)
	return MarketplaceModel.source_new_users(state, "organic")


## Memnun kullanıcı kullanıcı getirir: yol kusursuz ve seçenek tamken, memnuniyeti 100 olan bin kullanıcı bir haftada tavsiye oranı
## kadar (65) yeni kullanıcı getirir, memnuniyet 77,5'te (katsayı 0,5) yarısını; taban ilginin getirdiği bunun dışındadır.
func _check_word_of_mouth_brings_users() -> Array:
	var base := _organic_newcomers(0.0, 100.0)
	var happy := _organic_newcomers(1000.0, 100.0) - base
	var half := _organic_newcomers(1000.0, 77.5) - base
	var interest := 450.0 * 0.15 * 0.70 * 0.88 * 0.97
	return [_near(happy, 65.0, 1e-6) and _near(half, 32.5, 1e-6) and _near(base, interest, 1e-6),
		"1000 users on a perfect path bring %.2f new users a week at satisfaction 100 (65 = 0.065 each) and %.2f at 77.5 (32.5); the base interest alone brings %.2f (%.2f)"
		% [happy, half, base, interest]]
