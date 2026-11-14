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
	"reviews_affected_is_return_gap", "assignment_waits_a_close"]

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
		world.overrides = {"shipping": "free"}
		world.channel.fashion.sale_days = 5000.0
		world.campaign_discount = {"fashion": 150.0}
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
	var campaign := world.merged({"overrides": {"shipping": "free"}}, true)
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
	var campaign := world.merged({"overrides": {"shipping": "free"}}, true)
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
	return [_near(wk.net, gross - cut) and cut > 0.0,
		"gross %.2f, new-store discount %.2f (stores joined in 8 weeks %.1f of %.1f), net %.2f" % [gross, cut, joined, state.cats.fashion.stores, wk.net]]


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
		and _near(fashion.monthly_commission, 0.30 * 4.33 * conversion * (1.0 - 0.20) * 38.0 * 0.10) \
		and _near(fashion.organic, 3000.0 * 0.065 * (15.0 / 45.0) + 450.0) and _near(fashion.margin, 0.22) \
		and _near(fashion.base_interest, 450.0) and closed.conversion == 0.0 and closed.organic == 0.0 \
		and closed.monthly_commission == 0.0 and _near(closed.margin, 0.13) and _near(closed.base_interest, 250.0) and pools_ok
	return [ok, "fashion with three user features missing: conversion %.6f (%.6f), all three live %.6f (0.089628), monthly commission per user %.4f, organic visits %.1f (515); "
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
	var decoded: Dictionary = _as_loaded(JSON.parse_string(JSON.stringify(state)))
	var integral: bool = typeof(decoded.users) == TYPE_INT and typeof(decoded.members) == TYPE_INT \
		and typeof(decoded.cats.fashion.stores) == TYPE_INT
	var world := _live_world()
	var keep := MarketplaceModel.retention(decoded, world)
	var share := MarketplaceModel.returning_share(decoded, ["fashion"])
	MarketplaceModel.close_week(decoded, world)
	var ok: bool = integral and _near(keep, 0.94 + 0.03 * (300.0 / 3000.0)) and _near(share, 20.0 * 500.0 / 900.0 / 20.0) \
		and _near(decoded.lost.users, 3000.0 * (1.0 - 0.943)) \
		and _near(decoded.lost.stores, 30.0 * (0.008 + 0.07 * (1.0 - (20.0 / 30.0) / 1.2)))
	return [ok, "integral state decoded as ints=%s: retention %.4f (0.943), returning share %.4f (0.5556), lost users %.2f (171), lost stores %.4f (1.1733)"
		% [integral, keep, share, decoded.lost.users, decoded.lost.stores]]


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
	return [ok, "five weekly ticks of a fixed week: %d of 12 topics listed, tickets over the last four weeks = 4 x weekly, affected orders: "
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
	var late := func(side: String) -> Array:
		var late_rows: Array = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.key == "late_topic")
		return late_rows.map(func(r: Dictionary) -> String: return r.arg)
	var met := func(side: String) -> Array:
		var met_rows: Array = state.ledger[side].filter(func(r: Dictionary) -> bool: return r.key == "met")
		return met_rows.map(func(r: Dictionary) -> Dictionary: return r.duplicate())
	var world := _live_world(12).merged({"planned": ["size_chart"]}, true)
	_run(state, world, 1)
	var week12 := [late.call("users"), late.call("stores"), met.call("users").size()]
	_run(state, world.merged({"week": 13, "planned": [], "features": ["size_chart", "guest_checkout"]}, true), 1)
	var week13 := [late.call("users"), late.call("stores"), met.call("users")]
	_run(state, world.merged({"week": 14, "features": ["size_chart", "guest_checkout"]}, true), 1)
	var week14 := [late.call("users"), late.call("stores")]
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
