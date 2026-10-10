extends RefCounted

# Koşunun adlı hedefi iki listedir: önce Frank'in çeki (beş adım), çek cevaplanınca seed kapısı (iki
# adım). Hedefi gösteren her yüzey yalnız buradan okur; her yüzey kendisi türetirse yüzeyler ayrışır.
# Durum tutmaz, kayda girmez: her okuma koşunun durumundan türer, eşikler sahiplerinde kalır. Metin
# anahtardır, tr() çağıran arayüzdür.
#
# class_name yok, okuyanlar preload eder: paylaşılan checkout'ta yeni bir class_name, öteki
# oturumların headless koşularını global class-cache yarım kalınca düşürüyor.

## B2C'de para adımlarının (ödeyen, aylık gelir, Traction) sekmesi: Satış'ın B2C sayfası yok, kitle ve
## fiyat Ürün'de.
const B2C_MONEY_TAB := "product"


## "cheque", "seed" ya da "". Çek listesi kabul, ret ya da süre dolumuyla cevaplanana dek açıktır; düşen
## satır cevap değildir, kart gösterilmeden koşulu bozulmuştur. Seed listesi Series A Avı'na, imzaya ya
## da teklifsiz yanan pitch'e dek açıktır.
static func list() -> String:
	if GameState.run_angel_amount == 0 and EvHistory.last_resolution("funding.frank_cheque") \
			not in [EvHistory.RESOLUTION_CHOSEN, EvHistory.RESOLUTION_EXPIRED]:
		return "cheque"
	var burned: bool = GameState.seed_pitch_used and GameState.seed_sheet == null and not VCPitchSystem.is_active()
	if GameState.phase <= 2 and GameState.seed_lead == "" and not burned:
		return "seed"
	return ""


## Etkin listenin adımları sırayla, [{id, done, text_key, tab}]; MRR adımları canlı `value` ve `target`
## da taşır. Ödeyen ve gelir adımları canlıdır: müşteri giderse ya da MRR düşerse adım yeniden açılır.
static func steps() -> Array:
	var b2b: bool = SalesSystem.is_b2b_market()
	var money_tab: String = "sales" if b2b else B2C_MONEY_TAB
	match list():
		"cheque":
			# Tür seçimi Sprint 1'i planlamada açar; sonraki her kip ya da sprint ilkinin başladığını söyler.
			var started: bool = SprintSystem.is_typed() \
				and (SprintSystem.mode() != "plan" or SprintSystem.sprint_number() > 1)
			var paying: bool = CustomerRegistry.account_count() > 0 if b2b else SalesSystem.b2c_paying_users() > 0
			return [
				{"id": "type", "done": SprintSystem.is_typed(), "text_key": "CHEQUE_STEP_TYPE", "tab": "product"},
				{"id": "sprint", "done": started, "text_key": "CHEQUE_STEP_SPRINT", "tab": "product"},
				{"id": "ship", "done": ProductState.is_live(), "text_key": "CHEQUE_STEP_SHIP", "tab": "product"},
				{"id": "paying", "done": paying, "text_key": "CHEQUE_STEP_PAYING", "tab": money_tab},
				{"id": "mrr", "done": GameState.mrr >= AngelRoundSystem.MRR_THRESHOLD, "text_key": "CHEQUE_STEP_MRR",
					"tab": money_tab, "value": GameState.mrr, "target": AngelRoundSystem.MRR_THRESHOLD},
			]
		"seed":
			return [
				{"id": "traction", "done": GameState.phase >= 2, "text_key": "GOAL_STEP_TRACTION", "tab": money_tab},
				{"id": "seed", "done": SeedRoundSystem.page_unlocked(), "text_key": "GOAL_STEP_SEED", "tab": "finance",
					"value": GameState.mrr, "target": SeedConstants.DOOR_MRR},
			]
	return []


## {list, title_key, done, total, next}: `next` ilk bitmemiş adım, hepsi bittiyse {}. Liste yokken {}.
static func summary() -> Dictionary:
	var all: Array = steps()
	if all.is_empty():
		return {}
	var open: Array = all.filter(func(s: Dictionary) -> bool: return not s.done)
	var which: String = list()
	return {"list": which, "title_key": "CHEQUE_TITLE" if which == "cheque" else "SEED_SECTION_TITLE",
		"done": all.size() - open.size(), "total": all.size(), "next": {} if open.is_empty() else open[0]}
