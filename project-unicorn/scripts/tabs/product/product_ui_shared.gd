class_name ProductUiShared
extends RefCounted

# Ürün sekmesi görünümlerinin paylaştığı yardımcılar. Tamamı static, state tutmaz.
# Motor id döndürür; id'nin görünen ada çevirisi burada yaşar.

const AXIS_KEYS := ["innovation", "stability", "experience"]


## Eksenin legend rengi (creation önizlemesi ve Ürün Detayı aynı üçlüyü kullanır).
## Const değil çağrı: renk körü paleti "stability"yi (semantik POSITIVE) çalışma zamanında
## maviye çevirir, "experience" de o yüzden mora kayar; const bir kopya ilk renge çakılırdı.
static func axis_color(axis_id: String) -> Color:
	match axis_id:
		"innovation": return UiTokens.ACCENT_DEEP
		"stability": return UiTokens.positive()
		"experience": return UiTokens.axis_experience()
	return UiTokens.INK_MUTED


## Gün N → "Oca 2026" (SÜRÜMLER satırı).
static func month_year(day: int) -> String:
	var d: Dictionary = GameState.get_date_dict(day)
	return Fmt.month_abbr(int(d.month)) + " " + str(int(d.year))


static func axis_label(axis_id: String) -> String:
	match axis_id:
		"innovation": return TranslationServer.translate("PROD_AXIS_INNOVATION")
		"stability": return TranslationServer.translate("PROD_AXIS_STABILITY")
		"experience": return TranslationServer.translate("PROD_AXIS_EXPERIENCE")
	return axis_id


## ProductSystem.health_state() id'si → rozet metni.
static func health_label(id: String) -> String:
	return TranslationServer.translate("PROD_HEALTHY" if id == "saglikli" else "PROD_RISKY")   # LOC-DATA health band id


## ProductSystem.bug_trend() id'si → rozet metni.
static func trend_label(id: String) -> String:
	match id:
		"artiyor": return TranslationServer.translate("PROD_TREND_RISING")   # LOC-DATA trend id
		"azaliyor": return TranslationServer.translate("PROD_TREND_FALLING")
	return TranslationServer.translate("PROD_FLAT")


## Risk bandı id'si (ProductSystem.product_bug_risk) → etiket.
static func risk_label(id: String) -> String:
	match id:
		"dusuk": return TranslationServer.translate("PROD_RISK_LOW")   # LOC-DATA risk band id
		"yuksek": return TranslationServer.translate("PROD_RISK_HIGH")   # LOC-DATA risk band id
	return TranslationServer.translate("PROD_RISK_MID")


## "$" + yerel gruplu tam sayı (TR "$1.800", EN "$1,800").
static func money_tr(amount: int) -> String:
	return Fmt.money_exact(amount)


## §17 ÜCRETSİZ KULLANICI = kitle − ödeyen. Kitle ödeyeni de kapsar; aynı kişi iki hücrede
## sayılmasın diye kitlenin kendisi basılmaz.
static func b2c_free_users() -> int:
	return maxi(0, int(floor(SalesSystem.b2c_audience())) - CustomerRegistry.get_total_users())


## Çocukları hemen ağaçtan çıkarır (aynı karede kurulan yenileriyle çakışmasın) ve serbest bırakır.
static func clear(node: Node) -> void:
	for ch in node.get_children():
		node.remove_child(ch)
		ch.queue_free()


## "Bittiğinde kasada $X kalır" — kasa − maliyet + süre × günlük net akış.
static func cash_after_build(total_cost: int, duration_days: int) -> int:
	return GameState.cash - total_cost \
		+ duration_days * (GameState.get_daily_revenue() - GameState.daily_burn)


## Ürün Detayı ipucu şeridi: tam üç şablon, sistem ipucu (Frank'in sözü değil).
static func product_tip(weakest_axis_id: String, next_version: int, rival_above: String, bugs_heavy: bool) -> String:
	if bugs_heavy:
		return TranslationServer.translate("PROD_TIP_BUGS")
	if rival_above != "":
		return TranslationServer.translate("PROD_TIP_WEAK").format({
			"axis": axis_label(weakest_axis_id), "version": next_version, "rival": rival_above})
	return TranslationServer.translate("PROD_TIP_GOOD").format({"axis": axis_label(weakest_axis_id)})
