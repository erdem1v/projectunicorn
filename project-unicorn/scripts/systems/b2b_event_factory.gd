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
	# "Söz ver" ancak söz verilecek bir şey KALMIŞSA masada olur — acı özelliği yoksa ya da
	# ürün onu ÇOKTAN yayınladıysa değil. Bu koşul CS taleplerinde (pick_request_kind /
	# escalation) zaten vardı, retention kartında yoktu; sonucu iki yönlü bozuktu:
	# bedava kazanç (bir sonraki herhangi bir ship sözü "tutuldu"ya çevirip +15 memnuniyet
	# / +6 güven topluyordu, yapılmış iş için) ya da haksız kayıp (14 gün içinde bir şey
	# çıkmazsa aynı söz kırılıyordu — ve modal "zaten var" demeyi hiç önermiyordu).
	# ...ve AÇIK BİR SÖZ VARKEN de masada olmaz. Bu koşul eksikti ve bedeli ölçüldü:
	# 90 günlük bir sürücü koşusunda (ürün tökezliyor, oyuncu her kartta "Söz ver" diyor)
	# 5 müşteriye 142 SÖZ verildi ve 117'si kırıldı — aynı müşteriye aynı özellik için
	# üç açık söz aynı anda duruyordu. Her yönden bozuk:
	#   · kırılırsa: tek yapılmamış iş için üç ayrı ceza (−60 memnuniyet, +15 tolerans,
	#     −9 marka). Marka 50'den 0'a 30 günde indi.
	#   · tutulursa: tek ship üçünü birden "tutuldu"ya çevirdi (+45 memnuniyet, −15
	#     tolerans) — yapılmış TEK iş için üç kat ödül.
	# Kural kardeş kanalda (pick_request_kind, has_open_for → −25) zaten vardı; niyet
	# buradaydı, kapı yoktu. Söz bir BORÇTUR: kapanmadan ikincisi verilmez.
	var live_now: Array = GameState.get_flag("mvp_components", [])
	if c.pain_feature_id != "" and not live_now.has(c.pain_feature_id) \
			and not PromiseRegistry.has_open_for(c.id):
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
	ev.character_id = cs.id  # registry character strip: "<ad> · Müşteri Temsilcisi" (role_label)
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


static func pick_request_kind(c: Customer) -> String:
	# İLGİLİLİK KURALI (Dünya İnandırıcılığı Fix 5): talebin TÜRÜ ilişkinin
	# DURUMUNDAN türer — memnuniyet/gizli tolerans dengesi, kırılmış söz, güven
	# defteri, risk izi, kıdem, açık söz ve karşılanmamış acı özelliği. Şirketin
	# sektörü/karakter çizgisi yalnız ÜSLUBU boyar (build_cs_request gövdeleri),
	# konuyu ASLA seçmez: tekstilciye satmak tekstil olayı üretmez. Eski gün
	# rotasyonu (round_no + phase) durumdan tamamen bağımsızdı — mutsuz hesap
	# özellik ister, mutlu hesap şikâyet ederdi.
	#
	# THE NO-REPEAT RULE aynen durur: aynı hesap aynı türü üst üste iki kez açmaz
	# (last_request_kind dışlaması, 2b). RNG yasağı da durur: skorlar tamsayı
	# aritmetiği, eşitlik bozucu hesabın kendi faz imzası.
	#
	# NOT: support_request_since_day burada OKUNMAZ — CustomerRepSystem talebi
	# factory'ye getirmeden önce o mandalı temizler; seçim anında değeri hep -1,
	# okuyan kod ölü koşul olurdu.
	var eligible: Array = []
	for k in B2BConstants.CS_REQUEST_KINDS:
		if k != c.last_request_kind:
			eligible.append(k)
	if eligible.is_empty():
		return B2BConstants.CS_KIND_FEATURE
	var scores: Dictionary = {}
	# Şikâyet: memnuniyet toleransa yaklaştıkça / güven kırıldıkça yükselir.
	var complaint: int = 2 * maxi(0, c.tolerance + 10 - c.satisfaction)
	if GameState.get_flag("b2b_broke_%s" % c.id, false):
		complaint += 30
	if c.trust_offset < -4.0:
		complaint += 15
	if c.risk_streak > 0 or c.churn_countdown >= 0:
		complaint += 10
	scores[B2BConstants.CS_KIND_COMPLAINT] = complaint
	# Yenileme: kıdem büyüdükçe sözleşme masası yaklaşır; sayaç/oyalama izi acilleştirir.
	var tenure_months: int = int(float(GameState.day - c.acquired_on_day) / 30.0)
	var renewal: int = 6 * tenure_months
	if c.churn_countdown >= 0:
		renewal += 20
	if c.retain_stalls > 0:
		renewal += 10
	scores[B2BConstants.CS_KIND_RENEWAL] = renewal
	# Özellik: taban istek + karşılanmamış acı özelliği + sağlıklı ilişkinin cesareti;
	# açık bir söz dururken ikinci özellik istemek doğal değildir.
	var feature: int = 20
	var live: Array = GameState.get_flag("mvp_components", [])
	if c.pain_feature_id != "" and not live.has(c.pain_feature_id):
		feature += 25
	if c.satisfaction >= c.tolerance:
		feature += 10
	if PromiseRegistry.has_open_for(c.id):
		feature -= 25
	scores[B2BConstants.CS_KIND_FEATURE] = feature
	var best: String = ""
	var best_score: int = -2147483648
	for k in eligible:
		if int(scores.get(k, 0)) > best_score:
			best = k
			best_score = int(scores.get(k, 0))
	var tied: Array = []
	for k in eligible:
		if int(scores.get(k, 0)) == best_score:
			tied.append(k)
	if tied.size() > 1:
		best = tied[c.cs_request_phase % tied.size()]
	return best


static func build_cs_request(c: Customer, cs: Character) -> GameEvent:
	# The Müşteri Temsilcisi brings a request they could not close themselves (Task 2b). Either
	# it is beyond their UZMANLIK or the queue was too long to reach it. The speaker is the REAL
	# rep, so the name appears once at the top with the portrait.
	#
	# THREE KINDS, and they are genuinely different (2b fixes). Before, one template rotated
	# forever and EVERY request defaulted to "söz ver" — so the channel read as one repeating
	# beat. Now the kind decides the body voice AND the choice set, and promising is only the
	# feature request's natural answer. A complaint wants compensation or an honest refusal; a
	# renewal signal wants a conversation or a concession.
	#
	# ZERO NEW MODIFIER TYPES: b2b_promise_create (routes to PromiseRegistry, so an accepted
	# request becomes a tracked promise that bites durably via the trust ledger),
	# satisfaction_delta (target-threaded), and b2b_retain_discount (the existing discount seam,
	# which computes the figure here so the modal can display it). All three already have badges
	# in event_modal._describe_modifier — the EFFECT-VISIBILITY RULE holds, no card renders blind.
	var ev := GameEvent.new()
	ev.id = "ev_b2b_request_%s" % c.id   # namespaced per customer; shares no prefix with a JSON id
	ev.category = "reactive"
	ev.tags = ["build_safe", "b2b_cs_request"]
	ev.character_id = cs.id

	var kind: String = pick_request_kind(c)
	CustomerRegistry.set_last_request_kind(c.id, kind)
	var label: String = B2BConstants.feature_label(c.pain_feature_id)
	var choices: Array[EventChoice] = []

	match kind:
		B2BConstants.CS_KIND_COMPLAINT:
			# The sector's own words — the same voice pool build_retention uses, so an account's
			# grievance sounds like its industry rather than like the UI. State colors the frame
			# (Fix 5): below the hidden tolerance line the rep reports a HARD tone, above it a
			# manageable one — same kind, different temperature. # WORKING TR
			var voice: String = B2BConstants.COMPLAINT_VOICE.get(c.industry,
				B2BConstants.COMPLAINT_VOICE_FALLBACK)
			ev.title = "Müşteri şikâyeti"
			if c.satisfaction < c.tolerance:
				ev.body_text = "%s hattı arıyor, ton sert: \"%s\" Kendi başıma yatıştıramadım." % [c.company_name, voice]
			else:
				ev.body_text = "%s hattı arıyor: \"%s\" Şimdilik idare ettim ama karar senin." % [c.company_name, voice]
			var cut: int = maxi(int(round(float(c.mrr) * B2BConstants.CS_DISCOUNT_PCT / 100.0)), 1)
			choices.append(_choice("İndirim ver", [
				{"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -cut},
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_DISCOUNT_SAT},
			]))
			choices.append(_choice("Düzeltme sözü ver", [
				{"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id,
					"deadline_days": B2BConstants.PROMISE_DEADLINE_DAYS},
			]))
			choices.append(_choice("Açıkla ve reddet", [
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_EXPLAIN_SAT},
			]))
		B2BConstants.CS_KIND_RENEWAL:
			ev.title = "Yenileme sinyali"
			ev.body_text = "%s sözleşme yenilemesini sorguluyor. Fiyatı gözden geçiriyorlar; masaya oturmak gerek." % c.company_name
			var cut2: int = maxi(int(round(float(c.mrr) * B2BConstants.CS_DISCOUNT_PCT / 100.0)), 1)
			choices.append(_choice("Yenilemeyi görüş", [
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_RENEWAL_TALK_SAT},
			]))
			choices.append(_choice("İndirimle bağla", [
				{"type": "b2b_retain_discount", "customer_id": c.id, "mrr_delta": -cut2},
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_DISCOUNT_SAT},
			]))
			choices.append(_choice("Beklet", [
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_RENEWAL_STALL_SAT},
			]))
		_:
			# CS_KIND_FEATURE — the only kind where promising is the natural default.
			# State colors the wording (Fix 5): an UNSHIPPED pain feature gets the customer's
			# own pain line quoted; the company background (CompanyCatalog) may add ONE color
			# clause — it flavors the file note, it never picks the subject. # WORKING TR
			ev.title = "Müşteri talebi"
			var live: Array = GameState.get_flag("mvp_components", [])
			if c.pain_feature_id != "" and not live.has(c.pain_feature_id):
				ev.body_text = "%s '%s' istiyor: \"%s\" Kendi başıma kapatamadım, karar senin." % [
					c.company_name, label, B2BConstants.pain_phrase(c.pain_feature_id)]
			else:
				ev.body_text = "%s '%s' istiyor. Kendi başıma kapatamadım, karar senin." % [c.company_name, label]
			var background: String = CompanyCatalog.background_for(c.company_name)
			if background != "":
				ev.body_text += " Dosya notu: %s" % background
			# Aynı borç kapısı retention kartındaki gibi (bkz. build_retention): açık söz
			# varken ikinci söz verilmez. pick_request_kind bu durumu −25 ile CEZALANDIRIYOR
			# ama YASAKLAMIYOR — skor yine de FEATURE'ı seçebilir, ve seçtiğinde kart
			# ikinci borcu teklif ederdi.
			if not PromiseRegistry.has_open_for(c.id):
				choices.append(_choice("Söz ver: '%s'" % label, [
					{"type": "b2b_promise_create", "customer_id": c.id, "feature_id": c.pain_feature_id,
						"deadline_days": B2BConstants.PROMISE_DEADLINE_DAYS},
				]))
			choices.append(_choice("Önceliklendir", [
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_PRIORITIZE_SAT},
			]))
			choices.append(_choice("Şimdilik olmaz", [
				{"type": "satisfaction_delta", "customer_id": c.id, "delta": B2BConstants.CS_REQUEST_IGNORE_SAT},
			]))

	ev.choices = choices
	return ev


static func _choice(label: String, modifiers: Array) -> EventChoice:
	var ch := EventChoice.new()
	ch.label = label
	ch.modifiers = modifiers
	return ch
