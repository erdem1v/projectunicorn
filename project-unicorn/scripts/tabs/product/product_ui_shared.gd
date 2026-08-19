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

## Eksen renk üçlüsü (legend dot + ince bar; creation önizleme ve Ürün Detayı aynı
## üçlüyü kullanır). Sabit DEĞİL fonksiyon: "stability" semantik POSITIVE'i taşır ve
## renk körü paleti onu ÇALIŞMA ZAMANINDA maviye çevirir — const bir sözlük paleti
## süreç ömrü boyunca ilk okunan değere çakardı (GDScript const'ı fonksiyon çağıramaz).
## "experience" de aynı sebeple accessor'dan okunur: CB modunda Kararlılık maviye
## döndüğü için Deneyim mora kayar, yoksa legend'da iki mavi yan yana gelirdi.
static func axis_colors() -> Dictionary:
	return {
		"innovation": UiTokens.ACCENT_DEEP,
		"stability": UiTokens.positive(),
		"experience": UiTokens.axis_experience(),
	}


## Tek eksenin rengi (çağıranlar sözlüğü her seferinde kurmasın diye).
static func axis_color(axis_id: String) -> Color:
	return axis_colors().get(axis_id, UiTokens.INK_MUTED)


## Gün N → "Oca 2026" (SÜRÜMLER satırı). GameState.get_date_dict gerçek takvimi verir.
static func month_year(day: int) -> String:
	var d: Dictionary = GameState.get_date_dict(day)
	return Fmt.month_abbr(int(d.month)) + " " + str(int(d.year))


## Eksen id → TR görünen ad (evrensel üçlü).
static func axis_label(axis_id: String) -> String:
	match axis_id:
		"innovation": return TranslationServer.translate("PROD_AXIS_INNOVATION")
		"stability": return TranslationServer.translate("PROD_AXIS_STABILITY")
		"experience": return TranslationServer.translate("PROD_AXIS_EXPERIENCE")
		_: return axis_id


## ProductSystem.health_state() id'si → rozet metni.
static func health_label(id: String) -> String:
	return TranslationServer.translate("PROD_HEALTHY") if id == "saglikli" else TranslationServer.translate("PROD_RISKY")   # LOC-DATA health band id


## ProductSystem.bug_trend() id'si → rozet metni.
static func trend_label(id: String) -> String:
	match id:
		"artiyor": return TranslationServer.translate("PROD_TREND_RISING")   # LOC-DATA trend id
		"azaliyor": return TranslationServer.translate("PROD_TREND_FALLING")
		_: return TranslationServer.translate("PROD_FLAT")


## Risk bandı id'si (ProductCatalog.*_risk_band) → TR etiket.
static func risk_label(id: String) -> String:
	match id:
		"dusuk": return TranslationServer.translate("PROD_RISK_LOW")   # LOC-DATA risk band id
		"yuksek": return TranslationServer.translate("PROD_RISK_HIGH")   # LOC-DATA risk band id
		_: return TranslationServer.translate("PROD_RISK_MID")


## Rev3 para biçimi: "$" + gruplu tam sayı. Ayırıcı artık yerelden gelir — TR "$1.800",
## EN "$1,800" (kapı hükmü 6). Kendi gruplayıcısını taşıyordu; Fmt.money_exact ile aynı
## işi iki yerde yapmasın diye devredildi (HRConstants.money_tr ile aynı hareket).
static func money_tr(amount: int) -> String:
	return Fmt.money_exact(amount)


## Feature satırının bilgi şeridi — Efor önce, sonra katkılar, risk, maliyet:
## "Efor 8 · İnovasyon +5 · Kararlılık +4 · Hata riski: Orta · $1.800 · Lisans".
## Maliyet bloğu YALNIZ cost > 0 iken eklenir (kaynak: "API" | "Lisans").
static func feature_info_line(f: Dictionary) -> String:
	var fid: String = String(f.get("id", ""))
	var parts: Array[String] = [TranslationServer.translate("PROD_EFFORT_N").format(
		{"n": ProductCatalog.get_feature_efor(fid)})]
	var dc: Dictionary = f.get("dimension_contribution", {})
	for axis in AXIS_KEYS:  # sıra: İnovasyon → Kararlılık → Deneyim; sıfır eksen atlanır
		var v: int = int(dc.get(axis, 0))
		if v != 0:
			parts.append(TranslationServer.translate("PROD_AXIS_DELTA").format(
				{"axis": axis_label(String(axis)), "delta": ("+" + str(v)) if v > 0 else str(v)}))
	var band: String = ProductCatalog.feature_risk_band(int(f.get("complexity", 0)))
	parts.append(TranslationServer.translate("PROD_BUG_RISK").format({"level": risk_label(band)}))
	var cost: Dictionary = ProductCatalog.get_feature_cost(fid)
	if int(cost.get("amount", 0)) > 0:
		parts.append(money_tr(int(cost.get("amount", 0))))
		parts.append(TranslationServer.translate("PROD_COST_API") if String(cost.get("source", "")) == "api"
			else TranslationServer.translate("PROD_COST_LICENSE"))
	return " · ".join(parts)


## "Bittiğinde kasada $X kalır" — kasa − maliyet + süre × günlük net akış.
## Mockup doğrulaması: 10000 − 1800 + 9 × (0 − 50) = 7750.
static func cash_after_build(total_cost: int, duration_days: int) -> int:
	return GameState.cash - total_cost \
		+ duration_days * (GameState.get_daily_revenue() - GameState.daily_burn)


## Ürün Detayı Frank şeridi — tam 3 şablon (kuru Register A, tören yok).
static func frank_line(weakest_axis_id: String, next_version: int, rival_above: String, bugs_heavy: bool) -> String:
	if bugs_heavy:
		return TranslationServer.translate("PROD_TIP_BUGS")
	if rival_above != "":
		# COPY-RESTRUCTURED: "v%d'te" ve "%s'i" araya giren değere ek getiriyordu (yasak).
		return TranslationServer.translate("PROD_TIP_WEAK").format({
			"axis": axis_label(weakest_axis_id), "version": next_version, "rival": rival_above})
	return TranslationServer.translate("PROD_TIP_GOOD").format({"axis": axis_label(weakest_axis_id)})
