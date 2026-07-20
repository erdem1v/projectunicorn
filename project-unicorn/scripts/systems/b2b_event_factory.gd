class_name B2BEventFactory
extends RefCounted

# Builds synthetic GameEvents for the B2B Sales System (the retention decision now;
# expansion / special-request / CS escalation in later stages). Mirrors the
# ship-moment synthetic pattern — events are built in code and injected via
# EventManager.enqueue, then rendered by the (widened) EventModal.
#
# Copy law: single-language TR, no raw numbers, no em-dash, no emoji. The customer
# speaks in their own SECTOR voice; the effect costs are NOT hand-authored into the
# labels — the modal derives them from the modifiers (single source of truth).
#
# The retention modal is a CREAM-SHELL register event (Register A), same EventModal
# the game already uses — no forked modal. The speaker is a Customer (not a
# CharacterRegistry character), rendered via the event's synthetic-speaker fields.

static func build_retention(c: Customer) -> GameEvent:
	var ev := GameEvent.new()
	ev.id = "ev_b2b_retain_%s" % c.id
	ev.category = "reactive"
	ev.title = "Müşteri riski"
	ev.tags = ["build_safe", "b2b_retention"]  # survives the active-build gate; cost-line render
	# Speaker = the customer, in their own voice (synthetic; no CharacterRegistry lookup).
	ev.speaker_name = c.company_name
	ev.speaker_role = B2BConstants.sector_contact(c.industry)
	ev.speaker_status = "RİSK ALTINDA"
	ev.speaker_status_kind = "negative"
	if c.churn_countdown >= 0:
		ev.speaker_chips = [{"text": "Churn'e ~%d gün" % c.churn_countdown, "kind": "accent"}]
	ev.body_text = B2BConstants.complaint_voice(c.industry)

	var label: String = B2BConstants.feature_label(c.pain_feature_id)
	var discount_cut: int = int(round(float(c.mrr) * B2BConstants.RETAIN_DISCOUNT_PCT))
	var choices: Array[EventChoice] = []
	choices.append(_choice("Söz ver: '%s'" % label, [
		{"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id,
			"deadline_days": B2BConstants.PROMISE_DEADLINE_DAYS},
		{"type": "reputation", "delta": B2BConstants.RETAIN_PROMISE_REP},
	]))
	choices.append(_choice("Oyala", [
		{"type": "b2b_retain_delay", "customer_id": c.id},
		{"type": "brand", "delta": B2BConstants.RETAIN_DELAY_BRAND},
	]))
	choices.append(_choice("İndirim ver", [
		{"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -discount_cut},
		{"type": "reputation", "delta": B2BConstants.RETAIN_DISCOUNT_REP},
	]))
	# "Kendi haline bırak" = choose NOT to intervene. No instant churn / MRR / brand hit;
	# the customer stays in Risk, keeps paying, the churn countdown keeps running. If it
	# expires the account leaves on its own (brand hit lands at that churn moment). The
	# player can reopen İlgilen before expiry and still rescue (recoverable pressure).
	choices.append(_choice("Kendi haline bırak", [
		{"type": "b2b_retain_ignore", "customer_id": c.id},
	]))
	ev.choices = choices
	return ev


static func build_expansion(c: Customer) -> GameEvent:
	# The positive family (§C/§E): a healthy, mature account wants to grow — seats up,
	# MRR up. Accepting raises support load (feeds the need for a CS rep).
	var ev := GameEvent.new()
	ev.id = "ev_b2b_expand_%s" % c.id
	ev.category = "reactive"
	ev.title = "Büyüme fırsatı"
	ev.tags = ["build_safe", "b2b_expansion"]
	ev.speaker_name = c.company_name
	ev.speaker_role = B2BConstants.sector_contact(c.industry)
	ev.speaker_status = "BÜYÜMEK İSTİYOR"
	ev.speaker_status_kind = "positive"
	ev.body_text = "Ekibimiz büyüyor, sistemi başka birimlere de yaymak istiyoruz. Koltuk ekleyelim."
	var add_seats: int = B2BConstants.expansion_seats(c.company_size)
	var choices: Array[EventChoice] = []
	choices.append(_choice("Büyüt", [
		{"type": "b2b_expand", "customer_id": c.id, "add_seats": add_seats,
			"per_seat_mrr": B2BConstants.EXPANSION_PER_SEAT_MRR},
	]))
	choices.append(_choice("Şimdilik gerek yok", [
		{"type": "b2b_expand_decline", "customer_id": c.id},
	]))
	ev.choices = choices
	return ev


static func build_cs_escalation(c: Customer, cs: Character) -> GameEvent:
	# The CS raises ONE escalation (D.4): a TWO-choice decision, not an acknowledgment.
	# The speaker is the REAL CS employee (a CharacterRegistry character), so the name
	# appears once at the top with the portrait — never repeated under the line.
	var ev := GameEvent.new()
	ev.id = "ev_b2b_escalation_%s" % c.id
	ev.category = "reactive"
	ev.title = "Müşteri temsilcisi uyarısı"
	ev.tags = ["build_safe", "b2b_escalation"]
	ev.character_id = cs.id  # registry character strip: "<CS adı> · Müşteri Başarı"
	var label: String = B2BConstants.feature_label(c.pain_feature_id)
	ev.body_text = "Patron, %s bir süredir '%s' istiyor. Oyaladım ama artık tutamıyorum. Gideceklerdi, büyük müşteri, söz vermek zorunda kaldım. En kısa sürede yapalım." % [c.company_name, label]
	var choices: Array[EventChoice] = []
	choices.append(_choice("Tamam, sözü tut", [
		{"type": "b2b_cs_promise_honor", "customer_id": c.id, "feature_id": c.pain_feature_id,
			"deadline_days": B2BConstants.PROMISE_DEADLINE_DAYS},
	]))
	choices.append(_choice("Hayır, yapmıyoruz", [
		{"type": "b2b_cs_promise_refuse", "customer_id": c.id},
		{"type": "brand", "delta": -B2BConstants.CS_REFUSE_BRAND},
		{"type": "morale", "character_id": cs.id, "delta": -B2BConstants.CS_REFUSE_MORALE},
	]))
	ev.choices = choices
	return ev


static func _choice(label: String, modifiers: Array) -> EventChoice:
	var ch := EventChoice.new()
	ch.label = label
	ch.modifiers = modifiers
	return ch
