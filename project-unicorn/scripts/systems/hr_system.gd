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
	#  AŞIRI YÜKLENME sayacı moralden ÖNCE: tick_thresholds ve trait etkileri o günün
	#  yükünü okur, sayaç sonra artarsa bir gün geriden gelir (deneyim/eğitim sırasında
	#  ölçülen aynı tuzak).
	tick_overload()
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

## Günlük deneyim birikimi — rev 2 §8 "learn-by-doing: ATANDIĞI ALANIN deneyimi yavaş
## yükselir". YALNIZ gerçekten çalışanlar: izindeki ya da eğitimdeki biri edilgendir ve
## get_active_employees zaten ikisini de dışarıda bırakır. Kurucu bu listede hiç yok.
##
## BOŞTAKİ KİŞİ ÖĞRENMEZ. Bu, "atanmamış kişi boşta durur ve maaş yer" cümlesinin
## (§4) ikinci yarısıdır: boşta durmak yalnız bugünü değil, yarını da kaybettirir.
##
## Birden fazla işi olan kişi deneyimi BÖLÜŞTÜRMEZ, her işin alanına ayrı ayrı yazar —
## ama aşırı yük çarpanıyla. §5'in "verimi düşer" cümlesi öğrenmeye de uygulanır, yoksa
## iki işe koşmak öğrenme sömürüsü olurdu.
static func tick_experience() -> void:
	var base: int = HRConstants.EXPERIENCE_PER_DAY
	if _build_phase_running():
		base = HRConstants.EXPERIENCE_PER_BUILD_DAY
	for emp in CharacterRegistry.get_active_employees():
		if emp.assigned_jobs.is_empty():
			continue
		var lead_mult: float = HRConstants.experience_gain_mult(job_lead_leadership_for(emp))
		var load_mult: float = 1.0 if emp.assigned_jobs.size() <= 1 else HRConstants.OVERLOAD_OUTPUT_MULT
		for job_id in emp.assigned_jobs:
			var area_key: String = HRConstants.area_for_job(emp.role_stats, String(job_id))
			if area_key == "":
				continue
			var gain: int = int(round(float(base) * lead_mult * load_mult))
			CharacterRegistry.add_area_experience(emp.id, area_key, maxi(gain, 1))


# ======================= Görev ataması: okuma seam'leri ======================
# rev 2 §4. CharacterRegistry TEK YAZARDIR; burası okuma tarafı ve dışarıya açılan yüz.
# Ürün, Satış ve Operasyon "kim meşgul" sorusunu buradan sorar.

static func assigned_to(job_id: String) -> Array[Character]:
	## O işe atanmış, BUGÜN ÇALIŞABİLİR herkes. İzindeki ve eğitimdeki dışarıda: ataması
	## durur (dönünce işine döner) ama bugünkü hiçbir formüle girmez.
	var out: Array[Character] = []
	for c in CharacterRegistry.get_all():
		if c == null or c.status != HRConstants.STATUS_ACTIVE:
			continue
		if c.category != "employee" and c.category != "founder":
			continue
		if c.assigned_jobs.has(job_id):
			out.append(c)
	return out


static func is_idle(c: Character) -> bool:
	## "Boşta" — atanmamış çalışan durur ve maaş yer (§4). Kurucu maaş almadığı için
	## boştalığı bir GİDER değil, kaybedilmiş zamandır; rozet yine de aynı.
	return c != null and c.category == "employee" and c.assigned_jobs.is_empty()


static func is_overloaded(c: Character) -> bool:
	return c != null and c.assigned_jobs.size() > 1


static func overload_bites(c: Character) -> bool:
	## §5: "Aşırı yük kısa süre tolere edilir, uzun sürerse moral düşer." Rozet ilk günden
	## çıkar (oyuncu ne yaptığını görmeli), bedel toleranstan SONRA başlar.
	return is_overloaded(c) and c.overload_days > HRConstants.OVERLOAD_TOLERANCE_DAYS


static func idle_count() -> int:
	var n: int = 0
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_jobs.is_empty():
			n += 1
	return n


static func covering_heads() -> int:
	## ch. 06 §1.3'ün okuyucusu: "covering head = anyone assigned to support/CS, founder
	## included". Kapsam oranı bu turda HESAPLANMIYOR (Operasyon turunun işi) ama payda
	## burada doğuyor, çünkü "kim destekte" sorusunun tek cevabı burası.
	var seen: Dictionary = {}
	for job_id in [HRConstants.JOB_SUPPORT, HRConstants.JOB_ACCOUNTS]:
		for c in assigned_to(job_id):
			seen[c.id] = true
	return seen.size()


static func unstaffed_jobs() -> Array[String]:
	## §4: "Hangi işin boş kaldığı bu ekranda görünür (ör. 'Destek: kimse yok')."
	var out: Array[String] = []
	for job_id in HRConstants.JOBS:
		if assigned_to(String(job_id)).is_empty():
			out.append(String(job_id))
	return out


static func job_lead(job_id: String) -> Character:
	## rev 2 §2 + Erdem 2026-08-21: lider İŞ BAŞINA. Açık seçim kazanır; yoksa o işteki en
	## yüksek Liderlik; hiç kimse yoksa kurucu. Türetilmiş olması bilinçli — saklanan bir
	## lider işe alım ve ayrılmayla bayatlar, türetilmiş olan kendiliğinden doğrudur.
	var picked_id: String = String(GameState.job_leads.get(job_id, ""))
	if picked_id != "":
		var picked: Character = CharacterRegistry.get_character(picked_id)
		if picked != null and picked.status == HRConstants.STATUS_ACTIVE \
				and picked.assigned_jobs.has(job_id):
			return picked
	var best: Character = null
	var best_v: int = -1
	for c in assigned_to(job_id):
		var v: int = int(c.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0))
		if v > best_v:
			best_v = v
			best = c
	if best != null:
		return best
	return CharacterRegistry.get_founder()


static func job_lead_leadership_for(c: Character) -> int:
	## Bu kişinin ÜSTÜNDEKİ liderin Liderlik'i — birden fazla işi varsa en yükseği, çünkü
	## §5 aşırı yükü zaten cezalandırıyor; ikinci bir ceza olarak en kötü lideri seçmek
	## aynı kararı iki kez faturalandırırdı.
	if c == null:
		return 0
	var best: int = 0
	for job_id in c.assigned_jobs:
		var lead: Character = job_lead(String(job_id))
		if lead == null or lead.id == c.id:
			continue
		best = maxi(best, int(lead.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)))
	return best


static func tick_overload() -> void:
	## §5 sayacı. Yalnız aktif çalışanlar sayar: izindeyken aşırı yük birikmez, ama
	## SIFIRLANMAZ da — dönen kişi bıraktığı yerden devam eder (kaçma-riski sayacının
	## izinde donması ile aynı gramer, HRMoraleSystem.tick_flight_risk).
	for c in CharacterRegistry.get_active_employees():
		if c.assigned_jobs.size() > 1:
			CharacterRegistry.set_overload_days(c.id, c.overload_days + 1)
		elif c.overload_days != 0:
			CharacterRegistry.set_overload_days(c.id, 0)


static func output_mult_for_area(c: Character, area_key: String) -> float:
	## Çıktı çarpanı, ÇALIŞILAN ALAN bilindiğinde. Bir iş birden fazla alanla beslenebilir
	## (Build'i Ürün · Tasarım · Yazılım besliyor) ve kişi o işin FAZINA göre farklı bir
	## alandan katkı verebilir — bir yazılımcı TASARIM fazına Tasarım'ından katılır. Yorgunluk
	## o zaman GERÇEKTEN çalışılan alandan ölçülmeli, işin genel alanından değil, yoksa
	## §5'in "ikincil alanında çalışmak daha yorucudur" cümlesi tam da ısırması gereken yerde
	## ısırmaz. (Ölçüldü: `speed_tracks_team_change` bunu yakaladı.)
	if c == null:
		return 0.0
	var m: float = 1.0 if area_key == HRConstants.role_key_area(c.role) else HRConstants.SECONDARY_AREA_MULT
	if overload_bites(c):
		m *= HRConstants.OVERLOAD_OUTPUT_MULT
	return m


static func output_mult_for(c: Character, job_id: String) -> float:
	## Bir kişinin BİR İŞTEKİ çıktı çarpanı. İki §5 cümlesi tek yerde:
	##   "ikincil alanında çalışmak daha yorucudur"  -> job_fatigue_mult
	##   "birden fazla alan -> verimi düşer"          -> OVERLOAD_OUTPUT_MULT
	## Her formül bu çarpanı uygular; kimse kendi versiyonunu icat etmez.
	if c == null:
		return 0.0
	var m: float = HRConstants.job_fatigue_mult(c.role, job_id, c.role_stats)
	if overload_bites(c):
		m *= HRConstants.OVERLOAD_OUTPUT_MULT
	return m


static func area_sum_for_job(job_id: String) -> float:
	## O işe atanmış herkesin, o işi çalıştıkları alandaki puanlarının ÇARPANLI toplamı.
	## Ürün ve Satış formüllerinin yeni ortak girdisi — eski `_active_role_sum`ın yerine
	## geçer, farkı: rol değil ATAMA sayar.
	var total: float = 0.0
	for c in assigned_to(job_id):
		var area_key: String = HRConstants.area_for_job(c.role_stats, job_id)
		if area_key == "":
			continue
		total += float(int(c.role_stats.get(area_key, 0))) * output_mult_for(c, job_id)
	return total


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


## Oyuncunun kararı: birini eğitime gönder, HANGİ ALANDA olduğunu söyleyerek (rev 2 §8:
## "Oyuncu hangi alanın yükseleceğini seçer"). Ücreti HR gider hattından TAHSİL EDER ve
## ancak ödeme geçtiyse eğitimi başlatır — §10: bedeli olan, oynanmış bir karar.
## Ücret kademelidir ve aynı alandaki tekrarda artar (HRConstants.training_fee), yani
## "azalan getiri" fiyat tarafından ödenir: kazanç hep +1, pahalılaşan aynı +1'dir.
## `false` döner uygun değilse ya da kasa yetmiyorsa (çağıran düğmeyi kapatır).
static func send_to_training(id: String, area_key: String) -> bool:
	if not CharacterRegistry.can_train(id, area_key):
		return false
	var fee: int = CharacterRegistry.training_fee_for(id, area_key)
	if GameState.cash < fee:
		return false
	# Tek seferlik gider, HR gider hattına — işe alım retainer'ıyla aynı sızdırmazlık.
	FinanceSystem.apply_one_time_cost(fee, "training")
	CharacterRegistry.begin_training(id, area_key)
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


static func leave_line(emp: Character) -> String:
	# "İzinde · 4 gün kaldı" for the ledger's on-leave chip. Empty for anyone at work, so the
	# caller can render it unconditionally and get nothing when there is nothing to say.
	# (It was written for the Kare 7 card and went unowned when that card was retired; the
	# training chip beside it counts down, so the leave chip counting down too is the point.)
	# WORKING TR.
	if emp == null or emp.status != HRConstants.STATUS_ON_LEAVE:
		return ""
	return TranslationServer.translate("HR_STATE_ON_LEAVE_DAYS").format({"n": HRMoraleSystem.days_until_return(emp)})
