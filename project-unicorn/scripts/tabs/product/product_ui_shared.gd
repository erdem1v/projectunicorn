class_name ProductUiShared
extends RefCounted

# ============================================================================
# Product tab Rev3 — görünümler arası paylaşılan saf yardımcılar (plan Step 9).
# Tamamı static; state tutmaz. id→TR eşlemeleri BURADA yaşar (engine id döner,
# UI TR'ler); para/tarih biçimleri Rev3 mockup sözleşmesidir.
#
# NOT (bayraklı sapma): money_tr, Rev3 mockup'larındaki TAM nokta-gruplu rakamı
# basar ("$1.800", "$5.000") — UiTokens.format_money'nin "$1.8K" stilinden
# bilinçli ayrılır; ekran görüntüleri yerleşimde kazanır (plan verification §4).
# ============================================================================

const AXIS_KEYS := ["innovation", "stability", "experience"]
const MONTH_ABBR_TR := ["Oca", "Şub", "Mar", "Nis", "May", "Haz", "Tem", "Ağu", "Eyl", "Eki", "Kas", "Ara"]

# Eksen renk üçlüsü (legend dot + ince bar; creation önizleme ve Ürün Detayı aynı
# üçlüyü kullanır). Deneyim için token yok — tek yeni mavi, Rev3 mockup rengi.
const AXIS_COLORS := {
	"innovation": UiTokens.ACCENT_DEEP,
	"stability": UiTokens.POSITIVE,
	"experience": Color("#3b5b92"),
}


## Gün N → "Oca 2026" (SÜRÜMLER satırı). GameState.get_date_dict gerçek takvimi verir.
static func month_year(day: int) -> String:
	var d: Dictionary = GameState.get_date_dict(day)
	return "%s %d" % [MONTH_ABBR_TR[clampi(int(d.month) - 1, 0, 11)], int(d.year)]


## Eksen id → TR görünen ad (evrensel üçlü).
static func axis_label(axis_id: String) -> String:
	match axis_id:
		"innovation": return "İnovasyon"
		"stability": return "Kararlılık"
		"experience": return "Deneyim"
		_: return axis_id


## ProductSystem.health_state() id'si → rozet metni.
static func health_label(id: String) -> String:
	return "SAĞLIKLI" if id == "saglikli" else "RİSKLİ"


## ProductSystem.bug_trend() id'si → rozet metni.
static func trend_label(id: String) -> String:
	match id:
		"artiyor": return "ARTIYOR"
		"azaliyor": return "AZALIYOR"
		_: return "SABİT"


## Risk bandı id'si (ProductCatalog.*_risk_band) → TR etiket.
static func risk_label(id: String) -> String:
	match id:
		"dusuk": return "Düşük"
		"yuksek": return "Yüksek"
		_: return "Orta"


## Rev3 para biçimi: "$" + nokta-gruplu tam sayı ("$1.800", "$5.000", "-$450").
static func money_tr(amount: int) -> String:
	var digits: String = str(absi(amount))
	var grouped: String = ""
	var n: int = digits.length()
	for i in n:
		if i > 0 and (n - i) % 3 == 0:
			grouped += "."
		grouped += digits[i]
	return ("-$" + grouped) if amount < 0 else ("$" + grouped)


## Feature satırının bilgi şeridi — Efor önce, sonra katkılar, risk, maliyet:
## "Efor 8 · İnovasyon +5 · Kararlılık +4 · Hata riski: Orta · $1.800 · Lisans".
## Maliyet bloğu YALNIZ cost > 0 iken eklenir (kaynak: "API" | "Lisans").
static func feature_info_line(f: Dictionary) -> String:
	var fid: String = String(f.get("id", ""))
	var parts: Array[String] = ["Efor %d" % ProductCatalog.get_feature_efor(fid)]
	var dc: Dictionary = f.get("dimension_contribution", {})
	for axis in AXIS_KEYS:  # sıra: İnovasyon → Kararlılık → Deneyim; sıfır eksen atlanır
		var v: int = int(dc.get(axis, 0))
		if v != 0:
			parts.append("%s %+d" % [axis_label(String(axis)), v])
	var band: String = ProductCatalog.feature_risk_band(int(f.get("complexity", 0)))
	parts.append("Hata riski: %s" % risk_label(band))
	var cost: Dictionary = ProductCatalog.get_feature_cost(fid)
	if int(cost.get("amount", 0)) > 0:
		parts.append(money_tr(int(cost.get("amount", 0))))
		parts.append("API" if String(cost.get("source", "")) == "api" else "Lisans")
	return " · ".join(parts)


## "Bittiğinde kasada $X kalır" — kasa − maliyet + süre × günlük net akış.
## Mockup doğrulaması: 10000 − 1800 + 9 × (0 − 50) = 7750.
static func cash_after_build(total_cost: int, duration_days: int) -> int:
	return GameState.cash - total_cost \
		+ duration_days * (GameState.get_daily_revenue() - GameState.daily_burn)


## Ürün Detayı Frank şeridi — tam 3 şablon (kuru Register A, tören yok).
static func frank_line(weakest_axis_id: String, next_version: int, rival_above: String, bugs_heavy: bool) -> String:
	if bugs_heavy:
		return "Kan kaybediyorsun · hata sprinti vakti."
	if rival_above != "":
		return "Zayıf yanın %s · v%d'te onu güçlendir, %s'i yakala." \
			% [axis_label(weakest_axis_id), next_version, rival_above]
	return "İyi gidiyor · büyümeyi bırakma, zayıf yanın %s." % axis_label(weakest_axis_id)
