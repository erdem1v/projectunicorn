extends RefCounted

# Koşunun adlı hedefi üç listedir: önce Frank'in çeki (beş adım), çek cevaplanınca seed kapısı (iki adım), seed
# imzalanınca ya da yanınca Series A (iki adım). Hedefi gösteren her yüzey yalnız buradan okur; her yüzey kendisi
# türetirse yüzeyler ayrışır.
# Durum tutmaz, kayda girmez: her okuma koşunun durumundan türer, eşikler sahiplerinde kalır. Metin
# anahtardır, tr() çağıran arayüzdür.
#
# class_name yok, okuyanlar preload eder: paylaşılan checkout'ta yeni bir class_name, öteki
# oturumların headless koşularını global class-cache yarım kalınca düşürüyor.

const TITLE_KEYS := {"cheque": "CHEQUE_TITLE", "seed": "SEED_SECTION_TITLE", "series_a": "GOAL_SERIES_A_TITLE"}


## "cheque", "seed", "series_a" ya da "". Çek listesi kabul, ret ya da süre dolumuyla cevaplanana dek açıktır;
## düşen satır cevap değildir, kart gösterilmeden koşulu bozulmuştur. Seed listesi Series A Avı'na, imzaya ya
## da teklifsiz yanan pitch'e dek açıktır. Series A listesi tur imzalanana dek açıktır.
static func list() -> String:
	if GameState.run_angel_amount == 0 and EvHistory.last_resolution("funding.frank_cheque") \
			not in [EvHistory.RESOLUTION_CHOSEN, EvHistory.RESOLUTION_EXPIRED]:
		return "cheque"
	var burned: bool = GameState.seed_pitch_used and GameState.seed_sheet == null and not VCPitchSystem.is_active()
	if GameState.phase <= 2 and GameState.seed_lead == "" and not burned:
		return "seed"
	return "" if GameState.series_a_closed else "series_a"


## `which` listesinin (verilmezse etkin listenin) adımları sırayla, [{id, done, text_key, tab}]; MRR adımları canlı
## `value` ve `target` da taşır. Ödeyen ve gelir adımları canlıdır: müşteri giderse ya da MRR düşerse adım yeniden
## açılır. Üst barın merdiveni adımların tek yazı boyunu üç listenin bütün adımlarından ölçer.
static func steps(which: String = "") -> Array:
	match which if which != "" else list():
		"cheque":
			# Tür seçimi Sprint 1'i planlamada açar; sonraki her kip ya da sprint ilkinin başladığını söyler.
			var started: bool = SprintSystem.is_typed() \
				and (SprintSystem.mode() != "plan" or SprintSystem.sprint_number() > 1)
			var paying: bool = CustomerRegistry.account_count() > 0 if SalesSystem.is_b2b_market() \
				else SalesSystem.b2c_paying_users() > 0
			return [
				{"id": "type", "done": SprintSystem.is_typed(), "text_key": "CHEQUE_STEP_TYPE", "tab": "product"},
				{"id": "sprint", "done": started, "text_key": "CHEQUE_STEP_SPRINT", "tab": "product"},
				{"id": "ship", "done": ProductState.is_live(), "text_key": "CHEQUE_STEP_SHIP", "tab": "product"},
				{"id": "paying", "done": paying, "text_key": "CHEQUE_STEP_PAYING", "tab": "sales"},
				{"id": "mrr", "done": GameState.mrr >= AngelRoundSystem.MRR_THRESHOLD, "text_key": "CHEQUE_STEP_MRR",
					"tab": "sales", "value": GameState.mrr, "target": AngelRoundSystem.MRR_THRESHOLD},
			]
		"seed":
			return [
				{"id": "traction", "done": GameState.phase >= 2, "text_key": "GOAL_STEP_TRACTION", "tab": "sales"},
				{"id": "seed", "done": SeedRoundSystem.page_unlocked(), "text_key": "GOAL_STEP_SEED", "tab": "finance",
					"value": GameState.mrr, "target": SeedConstants.DOOR_MRR},
			]
		"series_a":
			# Kapı mandallıdır: kartı kuyruktayken ya da "Henüz değil"den sonra da çıta geçilmiştir.
			var hunted := GameState.phase >= 3 or (GameState.phase_gate_ready and GameState.pending_next_phase == 3)
			return [
				{"id": "hunt", "done": hunted, "text_key": "GOAL_STEP_SERIES_A_MRR", "tab": "sales",
					"value": GameState.mrr, "target": SalesSystem.TRACTION_MRR_TARGET},
				{"id": "sign", "done": GameState.series_a_closed, "text_key": "GOAL_STEP_SERIES_A_SIGN",
					"tab": "finance"},
			]
	return []


## {list, title_key, done, total, next}: `next` ilk bitmemiş adım, hepsi bittiyse {}. Liste yokken {}.
static func summary() -> Dictionary:
	var all: Array = steps()
	if all.is_empty():
		return {}
	var open: Array = all.filter(func(s: Dictionary) -> bool: return not s.done)
	var which: String = list()
	return {"list": which, "title_key": TITLE_KEYS[which],
		"done": all.size() - open.size(), "total": all.size(), "next": {} if open.is_empty() else open[0]}
