class_name RnDSystem
extends RefCounted

# ============================================================================
#  AR-GE — the research module's engine. GDD "AR-GE MODÜLÜ" rev 1.4+.
#
#  Pure statics, no autoload, driven by TimeManager's slot 2 (`_tick_rnd`, reserved and
#  empty since the Ürün cutover). Matches ProductSystem / SupportSystem / InfraSystem /
#  HRSystem, which are all class_name + statics; GameState / TimeManager / CharacterRegistry
#  are autoloads because they own signals-on-write and node lifetime. Ar-Ge owns neither.
#
#  WHAT THIS MODULE IS ABOUT (§1, and the acceptance test for the whole package):
#  research is not a point economy. It is a bet paid in PEOPLE and TIME — you take someone
#  off the desk and for that time they do not make product. §5.0 is what produces that, and
#  it does not live here: it lives in HRConstants.JOB_EXCLUSIVE + CharacterRegistry's
#  displacement, so the build's own pause machine (ProductSystem.pause_kind) reports it with
#  ZERO changes. This file only starts, accrues, freezes and completes.
#
#  §9 SINGLE SOURCE, honoured here and worth naming because it is easy to break:
#    · research speed  → HRSystem.daily_contribution(). Ar-Ge keeps NO copy of the formula.
#    · node states     → `_states`, this file, one table. Ürün gates, event conditions and
#                        the screen all read it through ResearchSeam.completed / arge.*.
#    · coefficients    → applied in the system that OWNS the number (load divisor in
#                        InfraSystem, bug/effort in ProductSystem). Ar-Ge carries the flag
#                        and keeps no second arithmetic.
#    · opened lines    → ProductState.HIDDEN_LINES. Ürün's catalog is their reader, so
#                        Ürün's state block owns them; this file keeps no copy.
#
#  WRITE-THROUGH LAW: this file never writes c.assigned_job_ids / c.paused_job_ids /
#  c.assigned_jobs (→ CharacterRegistry seams), never writes GameState.cash
#  (→ FinanceSystem.apply_one_time_cost), never writes the hidden-line flag
#  (→ ProductState.open_hidden_line), never writes ProductLines' tables
#  (→ register_runtime_line).
# ============================================================================

const STATE_LOCKED := "locked"
const STATE_REVEALED := "revealed"
const STATE_ACTIVE := "active"
const STATE_DONE := "done"

const NODE_USER_RESEARCH := "user_research"

## FinanceSystem ledger label. `one_time_today` is summed per label and has NO UI consumer
## today (checked), so this needs no display string.
const COST_LABEL := "rnd"

# --- state (§8.5's save list is exactly these, minus the two derived latches) ---
static var _states: Dictionary = {}      # node_id -> STATE_*
static var _progress: Dictionary = {}    # node_id -> accrued effort (float). KEPT on freeze.
static var _active: String = ""          # §5.1 — the ONE active node; "" = none
static var _assignees: Array[String] = []
static var _paid: Dictionary = {}        # node_id -> cash already charged (no refund, no double charge)
static var _note_last_day: int = -1      # -1 = user_research not complete yet
static var _note_pending: Dictionary = {}
static var _note_unread := false
static var _note_modal_shown := false

# --- derived edge-detector memory. NOT saved, exactly like ProductRead's _prev_*: a load
#     must not fire research_frozen for a state the player already saw.
static var _was_frozen := false
static var _freeze_cause: String = ""   # "" | RND_PAUSED_BUILD
static var _seeded := false


# ============================================================================
#  Lifecycle
# ============================================================================

## §2 — the tab opens after v1 ships. Before that the rail shows YAKINDA and nothing here
## runs. `ResearchSeam.tree_available()` delegates to this.
static func tree_open() -> bool:
	return ProductState.is_live()


static func reset() -> void:
	_states.clear()
	_progress.clear()
	_active = ""
	_assignees.clear()
	_paid.clear()
	_note_last_day = -1
	_note_pending = {}
	_note_unread = false
	_note_modal_shown = false
	_freeze_cause = ""
	_was_frozen = false
	_seeded = false
	_seed_states()


## The four roots start revealed; everything else waits for its parent (§3).
static func _seed_states() -> void:
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		_states[nid] = STATE_REVEALED if ResearchSeam.placement(nid) == ResearchSeam.PLACE_ROOT \
			else STATE_LOCKED


static func _ensure_seeded() -> void:
	if _states.is_empty():
		_seed_states()


## TimeManager slot 2 — after _tick_product (so it reads today's settled build/support/infra
## state) and before _tick_hr.
##
## TWO ONE-DAY LAGS, both consistent with the tree's existing conventions, both written down
## so nobody diagnoses them twice: a node completing on day N that moves an Infra or Support
## constant lands on N+1 because slot 1 already ticked; and research speed on day N reads
## yesterday's settled morale because _tick_hr is slot 3. Do NOT reorder — slot 1's
## Support-then-Infra ordering carries its own contract.
static func daily_tick() -> void:
	if not tree_open():
		return
	_ensure_seeded()
	_prune_assignees()
	_accrue()
	_tick_note()
	emit_edges()


## §5.4 · §5.7 — accrue, or freeze. Progress is never burned and never decayed.
static func _accrue() -> void:
	if _active == "":
		return
	var rate: float = research_per_day(_active, _assignees)
	if rate <= 0.0:
		return  # §5.7 FREEZE. "Yanacak olsa kimse başlamaz (kurtarılabilir baskı)."
	_progress[_active] = float(_progress.get(_active, 0.0)) + rate
	if float(_progress[_active]) >= float(ResearchTree.effort_of(_active)):
		_complete(_active)


## §7 — a departed employee drops off the assignment. Leave and training do NOT: the
## assignment is kept and the contribution zeroes (HRSystem.is_busy handles that in
## research_per_day), so they come back to the same research.
static func _prune_assignees() -> void:
	var keep: Array[String] = []
	for cid in _assignees:
		if CharacterRegistry.get_character(String(cid)) != null:
			keep.append(String(cid))
	_assignees = keep


## The ONE door for every freeze cause — player pull, departure, a fix run stealing the
## person, a build displacing the founder. All of them route through CharacterRegistry and
## end up changing `_assignees`, so one publisher catches them all (§10's one-emitter rule).
## `_seeded` guards the first call after a load so it emits nothing.
static func emit_edges() -> void:
	var frozen: bool = is_frozen()
	if not _seeded:
		_seeded = true
		_was_frozen = frozen
		return
	if frozen == _was_frozen:
		return
	_was_frozen = frozen
	if frozen:
		EventBus.research_frozen.emit(_active)
	else:
		EventBus.research_resumed.emit(_active)


# ============================================================================
#  §5.4 — speed and the day estimate
# ============================================================================

## §5.4 [K] — araştırma/gün = Σ hr.effective_skill(atanan, gereken alan) × saat/8 × K_ARGE.
##
## HRSystem.daily_contribution IS `effective_skill × saat/8` (Ekip §4.5). It is CALLED, never
## re-derived — §9 says Ar-Ge keeps no copy of the speed formula.
##
## ONE PERSON IS COUNTED ONCE (director ruling R3), through whichever required area is
## stronger for them. This is not a new invention: ProductSystem._phase_crew:589-608 rules
## exactly this for the build and says why — "İki faz alanına birden atanmış biri toplama iki
## kez girseydi aşırı yük bir CEZA değil ÖDÜL olurdu." Ar-Ge inherits it, so a two-area
## continuation still structurally wants two PEOPLE (§5.2).
##
## HRSystem.is_busy is the freeness gate and it earns its place: effective_skill checks only
## `status`, so a founder in pitch_prep_active would otherwise keep researching at full rate.
static func research_per_day(node_id: String, ids: Array = []) -> float:
	var who: Array = ids if not ids.is_empty() else _assignees
	var areas: Array = ResearchTree.areas_of(node_id)
	if areas.is_empty() or who.is_empty():
		return 0.0
	var total: float = 0.0
	for cid in who:
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c == null or HRSystem.is_busy(c):
			continue  # §7 — izin/eğitim: katkı sıfırlanır, ATAMA SİLİNMEZ.
		var best: float = 0.0
		for area in areas:
			best = maxf(best, HRSystem.daily_contribution(c, String(area)))
		total += best
	return total * ResearchTree.k_arge()


## §5.5 — THE number, and the only one on the card. Returns -1.0 for "no contribution" so no
## caller ever divides by zero or prints ∞; the caller writes the reason line instead.
static func days_estimate(node_id: String, ids: Array = []) -> float:
	var rate: float = research_per_day(node_id, ids)
	if rate <= 0.0:
		return -1.0
	var left: float = maxf(0.0, float(ResearchTree.effort_of(node_id)) - progress_effort(node_id))
	return left / rate


## §5.5 — the estimate shown before anyone is ticked. Computed against the founder alone,
## who is the one person always in the pool (§5.3) — which is exactly what the frames'
## "~9 gün (Kurucu)" shows.
static func days_estimate_solo(node_id: String) -> float:
	var founder: Character = CharacterRegistry.get_founder()
	if founder == null:
		return -1.0
	return days_estimate(node_id, [founder.id])


# ============================================================================
#  §5.3 — starting a research
# ============================================================================

## Machine reason ids, in refusal order. "" == may start.
const REFUSE_CLOSED := "closed"
const REFUSE_LOCKED := "locked"
const REFUSE_CROSS := "cross"
const REFUSE_CASH := "cash"
const REFUSE_STARS := "stars"
const REFUSE_NOBODY := "nobody"
const REFUSE_ZERO := "zero"
const REFUSE_DONE := "done"


## §5.3 · §5.5 · §7 — why Başlat is closed, or "" if it is open. The card renders the reason
## line from this; nothing greys out silently.
static func start_refusal(node_id: String, ids: Array) -> String:
	_ensure_seeded()
	if not tree_open():
		return REFUSE_CLOSED
	if not ResearchTree.has(node_id):
		return REFUSE_LOCKED
	var st: String = String(_states.get(node_id, STATE_LOCKED))
	if st == STATE_DONE:
		return REFUSE_DONE  # §7 — "Aynı düğüm iki kez tamamlanamaz."
	if st == STATE_LOCKED:
		return REFUSE_LOCKED  # §7 — "Önce {kök adı}."
	var cross: String = ResearchTree.cross_of(node_id)
	if cross != "" and not node_completed(cross):
		return REFUSE_CROSS
	if not _cash_ready(node_id):
		return REFUSE_CASH
	if not _stars_met(node_id):
		return REFUSE_STARS
	if ids.is_empty():
		return REFUSE_NOBODY
	# §5.5 ZERO-CONTRIBUTION GUARD. Evaluated against the ACTUAL proposed set, never a
	# company-wide star scan: a company can satisfy the star gate through an employee the
	# player did not tick. A bar sitting at 0% for days is an error state, not a lesson.
	if research_per_day(node_id, ids) <= 0.0:
		return REFUSE_ZERO
	return ""


## §5.3 — commit. Returns "" or the refusal id.
static func start(node_id: String, assignee_ids: Array) -> String:
	var refusal: String = start_refusal(node_id, assignee_ids)
	if refusal != "":
		return refusal

	# §5.7 — switching is free and the previous node KEEPS its progress. Cash is not
	# refunded and `_paid` keeps the record, so a later restart is not charged twice.
	if _active != "" and _active != node_id:
		_release_assignees()
		_states[_active] = STATE_REVEALED

	_active = node_id
	_states[node_id] = STATE_ACTIVE
	_freeze_cause = ""
	set_assignees(assignee_ids)
	if _assignees.is_empty():
		# HR seated nobody (a full two-job ledger on every candidate). Starting a research
		# that is frozen from its first second is the same unwarned loss §5.5's guard
		# refuses, so roll back rather than open a bar that will never move. Progress and
		# `_paid` are untouched, and the cash below has not been charged yet.
		_states[node_id] = STATE_REVEALED
		_active = ""
		return REFUSE_NOBODY

	# §5.3 — nakit BAŞLARKEN düşer, ve yalnız gerçekten başlayan bir araştırma için.
	var cost: int = ResearchTree.cash_of(node_id)
	if cost > 0 and not _paid.has(node_id):
		FinanceSystem.apply_one_time_cost(cost, COST_LABEL)
		_paid[node_id] = cost

	EventBus.research_started.emit(node_id)
	return ""


## §5.6 — the bar's `ata`. Adding or removing a person changes the rate immediately.
static func set_assignees(ids: Array) -> void:
	if _active == "":
		return
	var want: Array[String] = []
	for cid in ids:
		want.append(String(cid))
	for cid in _assignees:
		if not want.has(cid):
			CharacterRegistry.unassign_job(cid, HRConstants.JOB_RESEARCH)
	# THE SEAT LIST IS WHAT HR ACCEPTED, NOT WHAT THE PANEL ASKED FOR. `assign_job` can
	# refuse — Ekip's two-job ledger cap is a real refusal (§5.0: "üçüncü işi reddeden kural
	# araştırma için de geçerli") — and taking `want` on faith would leave the node believing
	# it has a worker HR never seated: a bar that never moves with nobody to blame, which is
	# exactly the failure §5.5's zero-contribution guard exists to prevent.
	var seated: Array[String] = []
	for cid in want:
		if _assignees.has(cid):
			seated.append(cid)          # already holds it; assign_job would no-op anyway
			continue
		# §5.0 — this is where research OCCUPIES: assign_job displaces the person's other
		# work into paused_job_ids rather than deleting it.
		var refusal: String = CharacterRegistry.assign_job(cid, HRConstants.JOB_RESEARCH)
		if refusal == "":
			seated.append(cid)
		else:
			push_warning("[RnDSystem] '%s' could not be seated on research: %s" % [cid, refusal])
	_assignees = seated
	emit_edges()


## §5.6 — the bar's `duraklat`. People go free, progress freezes.
static func pause() -> void:
	if _active == "":
		return
	_freeze_cause = ""          # oyuncunun kendi duraklatması: "Kimse üzerinde değil."
	_release_assignees()
	emit_edges()


## Called BY CharacterRegistry when a displacement or a departure takes this person off
## research. Must not call back into assign/unassign — that is the loop.
static func drop_assignee(char_id: String, cause: String = "") -> void:
	if not _assignees.has(char_id):
		return
	_assignees.erase(char_id)
	if _assignees.is_empty() and cause != "":
		_freeze_cause = cause
	emit_edges()


## §5.7 — DONMUŞ BARIN NOTU SEBEBİNİ SÖYLER. İki sebep vardır ve ayrı cümleleri olmalı:
## oyuncu insanları çekti (bar "Kimse üzerinde değil." der, yapım barıyla AYNI cümle — ve
## aynı olması §5.0'ın öğretici anını taşıyan şeydir), ya da taşıyıcı sürekli bir işe geçti
## ve araştırma yerinden edildi ("Ekip yapımda."). İkincisi `BUILD_BUSY_RESEARCH`'ün tam
## simetriğidir.
static func freeze_note_key() -> String:
	if not is_frozen():
		return ""
	return _freeze_cause if _freeze_cause != "" else "BUILD_BUSY_NOBODY"


static func _release_assignees() -> void:
	for cid in _assignees.duplicate():
		CharacterRegistry.unassign_job(String(cid), HRConstants.JOB_RESEARCH)
	_assignees.clear()


## §5.3 — cash is charged at start and never refunded, so a node already paid for is free
## to restart.
static func _cash_ready(node_id: String) -> bool:
	var cost: int = ResearchTree.cash_of(node_id)
	if cost <= 0 or _paid.has(node_id):
		return true
	return GameState.cash >= cost


## §5.2 · §12.6 — is there ANYBODY in each required area at the node's threshold?
## Company-wide, and deliberately NOT through LineGates: Ürün §12.7 reads raw skill there so
## an on-leave person still counts, because that gate is about what the COMPANY can build.
## Ar-Ge's gate is about who can work today, so it reads effective output. Two different
## questions; they must not share a function.
static func _stars_met(node_id: String) -> bool:
	for area in ResearchTree.areas_of(node_id):
		if not _area_has_star(node_id, String(area)):
			return false
	return true


static func _area_has_star(node_id: String, area: String) -> bool:
	var want: int = ResearchTree.stars_of(node_id) * HRConstants.POINTS_PER_STAR
	for c in eligible_assignees(node_id):
		if int(c.role_stats.get(area, 0)) >= want and HRSystem.effective_skill(c, area) > 0.0:
			return true
	return false


## §5.3 — the assignment panel's pool. Employees whose ROLE can hold one of the node's
## required areas, plus the founder ALWAYS.
##
## The filter is can_hold_area, NOT "has stars": hr_candidate_generator fills every area of
## every employee with a rest value, so a raw-star filter lists the whole roster and does
## nothing. The founder passes can_hold_area for every area by construction, which is why he
## is always on the list.
static func eligible_assignees(node_id: String) -> Array[Character]:
	var out: Array[Character] = []
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		out.append(founder)
	var areas: Array = ResearchTree.areas_of(node_id)
	for c in CharacterRegistry.get_employees():
		if c.category == "founder":
			continue
		for area in areas:
			if HRConstants.can_hold_area(c.role, String(area), c.category):
				out.append(c)
				break
	return out


# ============================================================================
#  §5.8 — completion
# ============================================================================

## ORDER IS LOAD-BEARING. `_states[node] = DONE` is set FIRST, so that if hidden-line
## registration re-enters ResearchSeam.completed() through a ProductLines accessor it reads a
## settled table.
static func _complete(node_id: String) -> void:
	if String(_states.get(node_id, "")) == STATE_DONE:
		return  # §7 — the same node cannot complete twice.
	_states[node_id] = STATE_DONE
	_active = ""
	_release_assignees()
	_progress[node_id] = float(ResearchTree.effort_of(node_id))

	_reveal_children(node_id)
	_open_hidden_line_for(node_id)

	if node_id == NODE_USER_RESEARCH:
		_note_last_day = GameState.day  # §6 — the 30-day clock starts here.

	EventBus.research_completed.emit(node_id)
	# §5.8 — KISA BİR KEŞİF KARTI DÜŞER. Kart PanelLayer'a main.gd tarafından mount edilir;
	# yükü yalnız düğüm kimliğidir, çünkü kartın okuduğu her şey (beat, açtığı şey, gizli hat)
	# zaten ResearchSeam/ResearchTree'den türetilebilir ve ikinci bir kopya §9'u çiğnerdi.
	EventBus.rnd_card_requested.emit("discovery", {"node": node_id})
	# §5.8 — NO ECONOMIC DELTA. No cash, no brand, no MRR. The discovery card is
	# presentation; the door it opens is the whole reward.


## §3 — a root reveals BOTH branches at once; a branch reveals only its own continuation.
## §8.5 — the revealed set is SAVED, not recomputed, so this never runs on load.
static func _reveal_children(node_id: String) -> void:
	for child in ResearchTree.children_of(node_id):
		var cid := String(child)
		if String(_states.get(cid, STATE_LOCKED)) != STATE_LOCKED:
			continue
		_states[cid] = STATE_REVEALED
		EventBus.node_revealed.emit(cid)


## §4.5 — the line enters the catalog, starts at K1 and obeys the normal ladder.
##
## Director ruling R4: only KENDİ KENDİNE SERVİS is authored for the demo. The other three
## are recorded into mvp_hidden_lines so a future EA build opens them, and NOTHING is
## registered — their unlock line already told the player it is Erken Erişim content, so the
## node is honest rather than either blocked (§3.1) or silently empty (unwarned loss).
static func _open_hidden_line_for(node_id: String) -> void:
	var line_id: String = ResearchTree.opens_line_of(node_id)
	if line_id == "" or ProductState.hidden_lines().has(line_id):
		return
	if ResearchTree.hidden_line_authored(line_id):
		var subtype: String = ProductState.subtype()
		if subtype == "":
			return  # no live product: nothing to attach to
		if not ProductLines.register_runtime_line(ResearchTree.hidden_line_raw(line_id), subtype):
			push_error("[RnDSystem] hidden line '%s' refused by the catalog" % line_id)
			return
	ProductState.open_hidden_line(line_id)
	EventBus.hidden_line_unlocked.emit(line_id)


## After a load the runtime line table is empty — ProductLines._by_subtype is process state,
## not save state. Re-register everything the save carried. MUST run after from_dict.
static func restore_hidden_lines() -> void:
	var subtype: String = ProductState.subtype()
	if subtype == "":
		return
	for line_id in ProductState.hidden_lines():
		var lid := String(line_id)
		if not ResearchTree.hidden_line_authored(lid):
			continue
		if ProductLines.runtime_line_ids(subtype).has("%s@%s" % [lid, subtype]):
			continue
		ProductLines.register_runtime_line(ResearchTree.hidden_line_raw(lid), subtype)


# ============================================================================
#  §6 — the monthly product note
# ============================================================================

static func _tick_note() -> void:
	if _note_last_day < 0:
		return                       # user_research not complete
	if not ProductState.is_live():
		return                       # §7 — canlı ürün yokken rapor gelmez
	if GameState.day - _note_last_day < ResearchTree.report_period_days():
		return
	_note_last_day = GameState.day
	var author: Character = note_author()
	if author == null:
		return                       # §6.2 — sessizce atlanır; sayaç yine de sıfırlanır
	_note_pending = compose_note(author)
	_note_unread = true
	EventBus.product_note_issued.emit(GameState.day)


## §6.2 (MÜHÜRLÜ) — a Product Manager or a Designer.
##
## The check reads whether the ROLE CAN HOLD the area, never raw points:
## hr_candidate_generator fills EVERY area of EVERY employee, so a sales rep carries nonzero
## raw Ürün and a raw-star reading would let a customer rep write the product research note.
##
## THE FOUNDER IS EXCLUDED, and he has to be excluded BY CATEGORY, because
## HRConstants.can_hold_area returns true for the founder in every area by construction.
static func note_author() -> Character:
	for c in CharacterRegistry.get_active_employees():
		if c.category == "founder":
			continue
		if HRConstants.can_hold_area(c.role, HRConstants.AREA_PRODUCT, c.category) \
				or HRConstants.can_hold_area(c.role, HRConstants.AREA_DESIGN, c.category):
			return c
	return null


## §6.2's second layer — the node card's LIVE warning. The gate is written before the
## research, not discovered after 70 effort.
static func note_author_available() -> bool:
	return note_author() != null


## §6.3 — three signals, no verdict. §6.4: the demand generator is not built, so the demand
## slot degrades to a fixed line and fills itself when the generator lands.
## §12.1 — her havuz dört varyasyon taşır (RND_NOTE_{RIVAL,TECH}_{B2B,B2C}_0..3).
const NOTE_POOL_COUNT := 4


## RNG YASAK (ev kuralı — NewsFeedSystem aynı sebeple hash kullanıyor): seçim deterministik
## aritmetiktir. Aynı gün aynı cümleyi verir, yani kaydedip yüklemek raporun sözünü
## değiştirmez ve aynı koşu tekrar oynandığında aynı ay aynı notu getirir.
static func _pick(count: int, salt: String, day: int) -> int:
	return absi(hash("%s|%d" % [salt, day])) % maxi(1, count)


## §6.3 · §14 — rakip adı KANONİKTİR, RivalCatalog'dan gelir, uydurulmaz.
## DEV (indeks 0) HARİÇ TUTULUR: momentumu sıfırdır, yani "az önce şunu çıkardı" cümlesi
## kalıcı bir durumu bu ayın haberi gibi gösterirdi. NewsFeedSystem devi aynı sebeple eler.
static func _rival_name(day: int) -> String:
	var names: Array = RivalCatalog.NAMES.get(ProductState.subtype(), []) as Array
	if names.size() < 2:
		return ""
	return String(names[_pick(names.size() - 1, "rnd_note_rival_name", day) + 1])


## §6.3 — "beliren teknoloji" HENÜZ ARAŞTIRILMAMIŞ bir düğümü işaret eder. Motorun okumadığı
## hiçbir şey iddia edilmez (§6.4 attribution): ad gerçek bir düğümden gelir.
static func _emerging_node(day: int) -> String:
	var open_ids: Array[String] = []
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		if not node_completed(nid):
			open_ids.append(nid)
	if open_ids.is_empty():
		return ""
	open_ids.sort()   # Dictionary.keys() sırası sözleşme değil; determinizm için sırala
	return open_ids[_pick(open_ids.size(), "rnd_note_tech_node", day)]


## §6.3 — ÜÇ SİNYAL, SIFIR HÜKÜM. Kart hiçbir satırı işaretlemez, hiçbirini önermez.
##
## §6.4 ŞERHİ: talep üreteci Ürün paketinde inşa edilmedi, o yüzden `demand_key` BOŞ gelir ve
## görünüm belgelenmiş bozunmuş hâline düşer ("Bu ay kimse bir şey istemedi."). Diğer iki
## satırın havuzları YAZILDI ve buradan seçilir — seçilmeseydi on altı yazılmış cümle hiçbir
## koşuda görünmezdi.
##
## TEK BESTECİ: harness de (--modal-shot=rnd-note) bu fonksiyonu çağırır, sözlüğü elle
## kurmaz. Elle kurulan kopya tam olarak ayrışabilir, ve bir kez ayrıştı.
static func compose_note(author: Character) -> Dictionary:
	var market: String = ProductState.market_type()
	var suffix: String = "B2B" if market == "b2b" else "B2C"
	var day: int = GameState.day
	var rival: String = _rival_name(day)
	var node: String = _emerging_node(day)
	# Bir satırın anahtarı, DOLDURACAĞI DEĞER yoksa boş bırakılır: yarım bir cümle
	# basmaktansa satır hiç çizilmez (kart da bunu bekliyor, `_note_line`).
	var rival_key: String = "" if rival == "" \
		else "RND_NOTE_RIVAL_%s_%d" % [suffix, _pick(NOTE_POOL_COUNT, "rnd_note_rival", day)]
	var tech_key: String = "" if node == "" \
		else "RND_NOTE_TECH_%s_%d" % [suffix, _pick(NOTE_POOL_COUNT, "rnd_note_tech", day)]
	return {
		"day": day,
		"author_id": author.id,
		"author_name": author.character_name,
		"author_role": author.role,
		"market": market,
		"demand_key": "",   # §6.4 — degraded until the demand generator ships
		"rival_key": rival_key,
		"tech_key": tech_key,
		"rival": rival,
		"node": node,
	}


static func note_pending() -> bool:
	return _note_unread


static func pending_note() -> Dictionary:
	return _note_pending.duplicate(true)


static func mark_note_read() -> void:
	if not _note_unread:
		return
	_note_unread = false
	EventBus.product_note_read.emit()


## §6.1 — the run's FIRST report opens once as a modal and says the report now lives in the
## Ar-Ge tab. True exactly once per run; the latch is set here, not by the modal.
static func take_first_note_modal() -> bool:
	if _note_modal_shown:
		return false
	_note_modal_shown = true
	return true


## What the left rail's Ar-Ge badge counts. One number from one place, the
## HRSystem.attention_count() grammar.
##
## §5.6.2 — a FROZEN research counts alongside an unread report, numbers adding. The tracker
## hides while the ODA room is showing and the glass keeps the product bar, so the badge is
## the only surface that reaches a player sitting in the room while their research is stalled.
## A running research does NOT count: a badge that nagged about work already in progress
## would be a demand, and Ar-Ge makes none.
static func attention_count() -> int:
	var n: int = 0
	if _note_unread:
		n += 1
	if is_frozen():
		n += 1
	return n


# ============================================================================
#  §10 — read surface. Names are STABLE; each signal has exactly one publisher.
# ============================================================================

## research.completed(node_id) — the seam name Ürün rev 6 §12.5 calls. Do not rename.
static func node_completed(node_id: String) -> bool:
	_ensure_seeded()
	return String(_states.get(node_id, STATE_LOCKED)) == STATE_DONE


static func active() -> String:
	return _active


## 0.0-1.0 fraction, the ProductSystem.sprint_progress grammar. Raw effort stays internal.
static func progress(node_id: String) -> float:
	var cap: float = float(ResearchTree.effort_of(node_id))
	if cap <= 0.0:
		return 0.0
	return clampf(progress_effort(node_id) / cap, 0.0, 1.0)


static func progress_effort(node_id: String) -> float:
	return float(_progress.get(node_id, 0.0))


## Revealed AND its prerequisites met. Cash and stars are deliberately NOT here: those are
## Başlat-time refusals with their own reason lines, and a node the player cannot afford
## today is still an available node.
static func available(node_id: String) -> bool:
	_ensure_seeded()
	if String(_states.get(node_id, STATE_LOCKED)) != STATE_REVEALED:
		return false
	var cross: String = ResearchTree.cross_of(node_id)
	return cross == "" or node_completed(cross)


static func family_root_done(family: String) -> bool:
	for id in ResearchSeam.NODES.keys():
		var nid := String(id)
		if ResearchSeam.family(nid) == family and ResearchSeam.placement(nid) == ResearchSeam.PLACE_ROOT:
			return node_completed(nid)
	return false


static func revealed(node_id: String) -> bool:
	_ensure_seeded()
	return String(_states.get(node_id, STATE_LOCKED)) != STATE_LOCKED


static func hidden_line_unlocked(line_id: String) -> bool:
	return ProductState.hidden_lines().has(line_id)


static func completed_count() -> int:
	_ensure_seeded()
	var n: int = 0
	for k in _states.keys():
		if String(_states[k]) == STATE_DONE:
			n += 1
	return n


static func assigned(node_id: String) -> Array:
	return _assignees.duplicate() if node_id == _active else []


static func state_of(node_id: String) -> String:
	_ensure_seeded()
	return String(_states.get(node_id, STATE_LOCKED))


## §5.7 — frozen means an active research with nobody on it. Progress is preserved.
static func is_frozen() -> bool:
	return _active != "" and _assignees.is_empty()


# ============================================================================
#  §8.5 — save
# ============================================================================
#  Schema stays at 9: everything here is additive and default-safe. _restore_systems reads
#  sys.get("rnd", {}) and from_dict returns early on {}, so a v9 save without this block
#  loads with a fresh tree and no migration.
#
#  NOT here, each for a stated reason:
#    · opened hidden lines → ProductState.HIDDEN_LINES (mvp_hidden_lines). §9: the Ürün
#      catalog is their reader, so Ürün's state block owns them.
#    · jobs paused by research → Character.paused_job_ids, walked by SaveCodec with the
#      rest of the roster. It is per-person data and it belongs next to assigned_job_ids.
#    · _was_frozen / _seeded → derived edge memory, exactly like ProductRead's _prev_*.
#      On load the first emit_edges() seeds and emits nothing, which is correct: a load must
#      not fire research_frozen for a state the player already saw.
#
#  SaveCodec hazard, named: _progress is {node_id: float} inside an untyped bag, and
#  _normalize_number turns an integral float into an int — so {"data_model": 40.0} returns
#  as 40. Every reader goes through float(), which progress_effort() does.

static func to_dict() -> Dictionary:
	# YAKALAMA DA TOHUMLAR. `from_dict` boş bir tabloyu gördüğünde `_ensure_seeded` ile yirmi
	# düğümü dolduruyor; yakalama tarafı tohumlamazsa kaydet → yükle → kaydet ZİNCİRİ
	# BÜYÜR (ölçüldü: 34.341 → 34.855 bayt, aradaki 514 bayt tam olarak yirmi giriş) ve
	# `save_roundtrip_fingerprint` düşer. Sebep yapısal: `reset_all_owners` yalnız YÜKLEMEDE
	# çağrılıyor (save_manager.gd:339), koşu başlangıcında değil — yani v1 yayınlanmadan
	# alınan bir kayıtta `_states` gerçekten boştur.
	_ensure_seeded()
	return {
		"states": _states.duplicate(),
		"progress": _progress.duplicate(),
		"active": _active,
		"assignees": _assignees.duplicate(),
		"paid": _paid.duplicate(),
		"freeze_cause": _freeze_cause,
		"note_last_day": _note_last_day,
		"note_pending": _note_pending.duplicate(true),
		"note_unread": _note_unread,
		"note_modal_shown": _note_modal_shown,
	}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		_ensure_seeded()
		return
	_states = (d.get("states", {}) as Dictionary).duplicate()
	_progress = (d.get("progress", {}) as Dictionary).duplicate()
	_active = String(d.get("active", ""))
	_assignees.clear()
	for cid in (d.get("assignees", []) as Array):
		_assignees.append(String(cid))
	_paid = (d.get("paid", {}) as Dictionary).duplicate()
	_freeze_cause = String(d.get("freeze_cause", ""))
	_note_last_day = int(d.get("note_last_day", -1))
	_note_pending = (d.get("note_pending", {}) as Dictionary).duplicate(true)
	_note_unread = bool(d.get("note_unread", false))
	_note_modal_shown = bool(d.get("note_modal_shown", false))
	_was_frozen = false
	_seeded = false
	_ensure_seeded()
	restore_hidden_lines()
