class_name HRSystem
extends RefCounted

# Pure-logic system per TECH_SPEC §8.3 — no scene dependency, no instance.
# Driven by TimeManager.daily_tick slot 3 (TECH_SPEC §8.2 ordered dispatch).
#
# HR Core: this file is the DAILY ORCHESTRATOR only. It owns the order the HR
# sub-systems run in and nothing else; every rule lives in the system that owns it.
#   HRSearchSystem     — Atlas arayışı, aday dosyaları, işe alım
#   HRMoraleSystem     — moral, izin, eşikler, istifa, pozitif event'ler
#   HROvertimeSystem   — departman bazlı ek mesai
#   HRActions          — zam / tatil / işten çıkarma (oyuncu tetikler, tick'te değil)
#   HRConstants        — her HR sayısının TEK evi
#
# THE AUTONOMOUS MORALE DRIFT IS GONE — deleted, not tuned to zero. It used to pull every
# employee ±1/day toward 50 from here. The design says morale moves only from played
# causes: ek mesai, aşırı yük, event'ler, oyuncu aksiyonları, izin dönüşü (design doc §6).
# Dead machinery invites a future reader to switch it back on, so there is nothing left to
# switch on. That is also why this task ships the RECOVERY channel (HRMoraleSystem's
# placeholder positive events) and not only the costs — morale never self-heals, so a
# one-directional loop would be a broken demo, not a hard one.
#
# Salary→Finance link: HRSystem does NOT push payroll to Finance. FinanceSystem pulls
# CharacterRegistry.get_total_monthly_salaries() AND HROvertimeSystem.pay_accrued_today()
# at the top of its own daily_tick (slot 5, two slots later). One-way pull, single source
# of truth — nobody writes a burn category from here, which is what keeps GameState's
# daily_burn from ever publishing fresh overtime against stale salaries.
#
# Frank (category "mentor") is excluded from every one of these paths because they all
# iterate get_employees()/get_active_employees(), which filter on category == "employee".
# He is never hireable, fireable, salaried as staff, morale-managed, or on overtime.


static func daily_tick() -> void:
	# Order matters, and each step reads state the previous one settled:
	#  1. Leave RETURNS first, so anything below sees the restored `active` status.
	#  2. Leave DEPARTURES next, so today's capacity/speed/overtime already excludes them.
	#  3. Search arrival — independent, but it can add an employee, so it lands before
	#     anything that iterates the roster for morale.
	#  4. Overtime — applies today's morale cost and stamps the pay Finance pulls at slot 5.
	#  5. Thresholds AFTER overtime, so a person pushed under KAÇMA RİSKİ by tonight's
	#     mesai starts their flight-risk count today rather than tomorrow.
	#  6. Trait effects and positive events last: they read the settled morale picture.
	HRMoraleSystem.tick_leave_returns()
	HRMoraleSystem.tick_leave_departures()
	HRSearchSystem.daily_tick()
	HROvertimeSystem.daily_tick()
	HRMoraleSystem.tick_thresholds()
	HRMoraleSystem.tick_trait_effects()
	HRMoraleSystem.tick_positive_events()
	#  7. DENEYİM: bugün gerçekten ÇALIŞMIŞ olanlar biriktirir. Eğitimdekiler
	#     STATUS_TRAINING taşıdığı için get_active_employees zaten dışarıda bırakır.
	#  8. EĞİTİM en sonda. SIRA ÖNEMLİ ve tersi ÖLÇÜLDÜ: eğitim önce koşarsa
	#     bitiş günü deneyimi sıfırlar, sonra tick_experience aynı gün içinde bir
	#     puan geri verir ve "biterken sıfırlanır" sözleşmesi sessizce yalan olur
	#     (hr_training_completion tam olarak bunu yakaladı).
	tick_experience()
	tick_training()

	if OS.is_debug_build():
		print("[HRSystem] Daily tick — %d employees (%d izinde)" % [
			CharacterRegistry.count_employees(), CharacterRegistry.count_on_leave(),
		])

	# LAST LINE, and it has to be: EventBus.day_advanced fires inside GameState.advance_day(),
	# which TimeManager calls BEFORE dispatching the daily ticks — so a screen that repaints on
	# day_advanced reads HR state from BEFORE the seven steps above ran (search strip a day
	# behind, arriving files invisible until tomorrow). This is the same trap
	# build_progress_changed was added to fix for the build tracker. The HR tab listens here.
	EventBus.hr_day_processed.emit()


# --- DENEYİM / EĞİTİM (Terminal UI görevi, 2026-08-08) ---
# Onaylı defterin [PROPOSAL] DENEYİM sütunu. Tüm sayılar HRConstants'ta ve WORKING.

## Günlük deneyim birikimi. YALNIZ gerçekten çalışanlar: izindeki ya da eğitimdeki
## biri edilgendir ve get_active_employees zaten ikisini de dışarıda bırakır.
## Kurucu bu listede hiç yok (category "founder"), yani hariç tutma bedavaya geliyor.
static func tick_experience() -> void:
	var gain: int = HRConstants.EXPERIENCE_PER_DAY
	if _build_phase_running():
		gain = HRConstants.EXPERIENCE_PER_BUILD_DAY
	for emp in CharacterRegistry.get_active_employees():
		CharacterRegistry.add_experience(emp.id, gain)


## Eğitim günlerini işler; biten her eğitim bir haber satırı bırakır.
static func tick_training() -> void:
	for emp in CharacterRegistry.get_employees():
		if emp.training_days_left <= 0:
			continue
		if CharacterRegistry.tick_training(emp.id):
			# Mevcut haber grameri: "biz" kaynağı EventBus.headline_added'a yazar,
			# NewsFeedSystem kotayı kendi yürütür (HRMoraleSystem'in izin satırlarıyla
			# aynı yol).
			# TranslationServer, tr() DEĞİL: statik fonksiyonun çeviri yapacağı bir
			# Object'i yok (UiTokens.net_runway_parts ile aynı sebep).
			EventBus.headline_added.emit(HRConstants.notice_source_hr(),
				TranslationServer.translate("HR_NEWS_TRAINING_DONE").format({
					"name": emp.character_name,
				}))


## Oyuncunun kararı: birini eğitime gönder. Ücreti HR gider hattından TAHSİL EDER
## ve ancak ödeme geçtiyse eğitimi başlatır — §10: bedeli olan, oynanmış bir karar.
## `false` döner uygun değilse ya da kasa yetmiyorsa (çağıran düğmeyi kapatır).
static func send_to_training(id: String) -> bool:
	if not CharacterRegistry.can_train(id):
		return false
	if GameState.cash < HRConstants.TRAINING_FEE:
		return false
	# Tek seferlik gider, HR gider hattına — işe alım retainer'ıyla aynı sızdırmazlık.
	FinanceSystem.apply_one_time_cost(HRConstants.TRAINING_FEE, "training")
	CharacterRegistry.begin_training(id)
	return true


## Bir geliştirme fazı KOŞUYOR mu? ProductSystem'in kendi faz listesiyle aynı üçlü
## (iteration/development/bugfix) — kopya bir liste tutmamak için tek yerden okunur.
static func _build_phase_running() -> bool:
	var b: FeatureBuild = ProductSystem.get_active_build()
	if b == null:
		return false
	return b.current_phase in ["iteration", "development", "bugfix"]


# --- Run reset (called from GameState.initialize_run, after the flags clear) ---

static func reset() -> void:
	# Static state in the HR sub-systems must not survive into a fresh run (the smoke
	# harness runs one case per process, but the debug onboarding re-trigger does not — and
	# neither does a load).
	# Verified complete against the two sub-systems' statics:
	#   HRMoraleSystem  — the RNG cursor (now RngStreams' concern) + _pending. Both cleared.
	#   HROvertimeSystem — _pay_today / _pay_stamped_day / _pay_carry. All three cleared.
	# HRSearchSystem holds NO statics: its whole state machine lives on GameState.hr_search,
	# which initialize_run clears and the save carries.
	HRMoraleSystem.reset_rng()
	HROvertimeSystem.reset()


# --- Save routing (SaveManager). This file is the HR orchestrator, so it is also the one
#     door the codec knocks on; each sub-system still owns its own payload. ---

static func to_dict() -> Dictionary:
	# HROvertimeSystem's three statics are deliberately NOT here. _pay_today /
	# _pay_stamped_day are a SINGLE DAY's stamp, self-verifying against GameState.day
	# (pay_accrued_today returns 0 when the stamp is not today's), so a restored run simply
	# reads 0 until the next daily tick re-stamps — which is the same answer the stamp would
	# have given. _pay_carry only holds value between a same-day stop and the next tick, a
	# window no save can land in. The overtime BLOCKS themselves live on GameState.hr_overtime.
	return {"morale": HRMoraleSystem.to_dict()}


static func from_dict(d: Dictionary) -> void:
	if d.is_empty():
		return
	HRMoraleSystem.from_dict(d.get("morale", {}) as Dictionary)


# --- Read surface for the HR tab (task 3) and the left-rail badge ---

static func badges_for(emp: Character) -> Array[String]:
	# Badges are DERIVED, never stored: an employee can carry TÜKENİYOR and AŞIRI YÜKLÜ at
	# the same time and Character.attention_flag is a single String. Same vocabulary as
	# that field so the model does not end up with two badge concepts.
	return HRMoraleSystem.badges_for(emp)


static func attention_count() -> int:
	# What the left-rail HR badge counts: people who need looking at, plus a waiting
	# candidate file. Kept here so the UI reads one number from one place.
	var n: int = attention_people_count()
	if HRSearchSystem.has_files_ready():
		n += 1
	# Frank's hire nudge (Playable Run Sprint): the seed is in the bank and the founder is
	# still alone. A SIGNPOST, not a demand — it clears itself the moment anyone is hired,
	# and nothing anywhere reads it as a requirement. Counted here rather than in the rail
	# so the badge keeps reading one number from one place.
	if int(GameState.get_flag(AngelRoundSystem.FLAG_ACCEPTED_DAY, 0)) > 0 \
			and CharacterRegistry.get_employees().is_empty():
		n += 1
	return n


static func attention_people_count() -> int:
	# PEOPLE only — the Ekip header's "N dikkat gerektiriyor". Deliberately not the same number
	# as attention_count() above: the rail badge also counts a waiting candidate file, but on
	# the Ekip page those files have their own strip, so counting them again in a sentence about
	# the team would be a lie. Splitting it here rather than subtracting in the UI keeps the
	# rail's verified behaviour untouched.
	var n: int = 0
	for emp in CharacterRegistry.get_employees():
		if not HRMoraleSystem.badges_for(emp).is_empty():
			n += 1
	return n


static func tenure_line(emp: Character) -> String:
	# "Ocak'tan beri · 6. ay" — the employee card's tenure line, composed here because it needs
	# GameState.day and this file is already the HR read surface. Three branches, because
	# hire_day is stamped to the day AFTER the hire (a hire starts tomorrow at full performance):
	#   hire_day > today  → the player just paid; they have not started yet
	#   hire_day == today → their first day
	#   otherwise         → month name + ordinal month of tenure
	# The ordinal counts CALENDAR months (GameState.months_elapsed_since), not 30-day blocks, so
	# it cannot contradict the month name printed beside it.
	# WORKING TR.
	if emp == null:
		return ""
	if emp.hire_day > GameState.day:
		return TranslationServer.translate("HR_STATE_STARTS_TOMORROW")
	if emp.hire_day == GameState.day:
		return TranslationServer.translate("HR_STATE_STARTS_TODAY")
	var months: int = GameState.months_elapsed_since(emp.hire_day)
	return TranslationServer.translate("HR_TENURE_SINCE").format({"month": GameState.month_name_tr(emp.hire_day), "n": months + 1})


static func leave_line(emp: Character) -> String:
	# "İZİNDE · 4 gün kaldı" for the Kare 7 muted card. Empty for anyone at work, so the caller
	# can render it unconditionally and get nothing when there is nothing to say.
	# WORKING TR.
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return ""
	return TranslationServer.translate("HR_STATE_ON_LEAVE_DAYS").format({"n": HRMoraleSystem.days_until_return(emp)})
