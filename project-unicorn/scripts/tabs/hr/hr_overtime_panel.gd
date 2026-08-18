class_name HROvertimePanel
extends RefCounted

# ============================================================================
# Ek mesai paneli — ana departman başlığındaki EK MESAİ aksiyonundan açılır
# (HRPopover içine dizilir).
#
# Üç blok kartı (3 GÜN / 1 HAFTA / 2 HAFTA), her birinin altında MOTORUN
# önizlemesi: hız etkisi, tahmini ek ücret, moral bedeli, Ürün Geliştirme'de bug
# etkisi. Dördü de HROvertimeSystem.preview_block'un beş anahtarından geliyor;
# panel hiçbirini kendisi türetmiyor.
#
# İki bilinçli sapma, done mesajında raporlanıyor:
#   - preview_block'un `speed_bonus_pct` değeri yalnız BLOĞUN AÇILIŞ oranı. Azalan
#     verim (8. günden sonra) HRConstants.overtime_speed_bonus(day)'dan okunup ayrı
#     satır olarak yazılıyor — bu da motor fonksiyonu, hesap değil.
#   - `morale_cost` HAM: huy/Liderlik ölçeklemesi uygulanmamış, oysa preview_raise ve
#     preview_vacation ölçeklenmiş moral döndürüyor. Panel motorun verdiğini basıyor.
#
# # WORKING TR — oyuncuya görünen tüm metin çalışma metni; ses geçişi sonra.
# ============================================================================


static func fill(dept_id: String, body: VBoxContainer, on_change: Callable) -> void:
	var dept_label: String = HRConstants.department_label(dept_id)
	body.add_child(UiFactory.make_section_header(
		TranslationServer.translate("HR_OT_TITLE").format({"dept": dept_label})))

	if HROvertimeSystem.is_active(dept_id):
		_fill_active(dept_id, body, on_change)
		return

	if not HROvertimeSystem.can_start(dept_id):
		# can_start yalnız bool döner (bu modülde gerekçe dizesi yok), ve tek sebebi
		# katılımcısız departman — cümle burada kuruluyor, sayı değil.
		body.add_child(UiFactory.make_label(
			TranslationServer.translate("HR_OT_EMPTY"), &"BodySerif", UiTokens.INK_MUTED))
		return

	var participants: Array[Character] = HROvertimeSystem.participants(dept_id)
	var who: String = TranslationServer.translate("HR_OT_HEADCOUNT").format({"n": participants.size()})
	# `founder_participates` requires an ACTIVE block, and this panel half only ever renders
	# BEFORE one starts — so the suffix was unreachable in both branches. Left out rather
	# than made reachable: whether the founder pulls product_dev nights is a design question,
	# not a rendering one, and the active half already reports the crew.
	body.add_child(UiFactory.make_label(who, &"RowMeta", UiTokens.INK_DIM))

	for block_days in HRConstants.OVERTIME_BLOCKS:
		body.add_child(_block_card(dept_id, int(block_days), on_change))

	body.add_child(HRUiShared.hairline())
	body.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_NOTE"),
		&"QuoteSerif"))


static func _block_card(dept_id: String, block_days: int, on_change: Callable) -> Control:
	var pv: Dictionary = HROvertimeSystem.preview_block(dept_id, block_days)
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardPanelTight"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 4)
	card.add_child(col)

	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 8)
	head.add_child(UiFactory.make_label(
		Fmt.upper(HROvertimeSystem.block_label(block_days)),
		&"RowName"))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(spacer)
	head.add_child(UiFactory.make_badge(TranslationServer.translate("HR_OT_SPEED").format({"pct": int(pv.get("speed_bonus_pct", 0))}), &"positive"))
	col.add_child(head)

	col.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_EST_COST").format({"amount": HRUiShared.money(int(pv.get("est_pay", 0)))}),
		&"RowMeta", UiTokens.INK_MUTED))
	col.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_MORALE_COST").format({"delta": "−%d" % int(pv.get("morale_cost", 0))}),
		&"RowMeta", UiTokens.INK_MUTED))
	if int(pv.get("bug_pct", 0)) > 0:
		col.add_child(UiFactory.make_label(
			TranslationServer.translate("HR_OT_BUG_RATE").format({"pct": int(pv.get("bug_pct", 0))}), &"RowMeta", UiTokens.negative()))
	if block_days >= HRConstants.OVERTIME_DIMINISH_DAY:
		# Azalan verim yalnız bloğun o güne uzadığı hallerde anlamlı.
		col.add_child(UiFactory.make_label(
			TranslationServer.translate("HR_OT_LATE_SPEED").format({
				"day": HRConstants.OVERTIME_DIMINISH_DAY,
				"pct": int(round(HRConstants.overtime_speed_bonus(HRConstants.OVERTIME_DIMINISH_DAY) * 100.0)),
			}), &"RowMeta", UiTokens.INK_DIM))

	# Lambda YEREL DEĞİŞKENE alınıyor: çok satırlı bir lambda'dan SONRA argüman gelemez
	# (gövde satırın kalanını yutar), o yüzden `, true` ile aynı çağrıya sığmaz.
	var on_start: Callable = func() -> void:
		if HROvertimeSystem.start(dept_id, block_days) and on_change.is_valid():
			on_change.call()
	var start := HRUiShared.action_button(TranslationServer.translate("HR_OT_START"), on_start, true)
	start.size_flags_horizontal = Control.SIZE_SHRINK_END
	col.add_child(start)
	return card


static func _fill_active(dept_id: String, body: VBoxContainer, on_change: Callable) -> void:
	var day_index: int = HROvertimeSystem.day_index(dept_id)
	var total: int = HROvertimeSystem.current_block_days(dept_id)
	body.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_PROGRESS").format({"day": day_index, "len": total}), &"RowName"))
	# Bugünün oranı motorun kendi basamak fonksiyonundan. speed_multiplier'dan
	# 1.0 çıkarmak bir TÜRETME olurdu; overtime_speed_bonus zaten kazancı veriyor,
	# kesir → yüzde çevrimi yalnız biçimleme.
	body.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_TODAY_SPEED").format({"pct": int(round(
			HRConstants.overtime_speed_bonus(day_index) * 100.0))}),
		&"RowMeta", UiTokens.INK_MUTED))
	# Bu cümle eskiden "durdurulan blok O GÜNDEN SONRA bedel üretmez" diyordu ve doğruydu —
	# fazlasıyla: durdurulan gün de bedelsizdi, çünkü kazanç saatlik, bedel günlük
	# işliyordu. Motor artık başlanan günü faturalıyor; kopya da onu söylüyor.
	body.add_child(UiFactory.make_label(
		TranslationServer.translate("HR_OT_EARLY_STOP"),
		&"QuoteSerif"))
	var on_stop: Callable = func() -> void:
		if HROvertimeSystem.stop(dept_id) and on_change.is_valid():
			on_change.call()
	var stop := HRUiShared.action_button("DURDUR", on_stop, true)
	stop.size_flags_horizontal = Control.SIZE_SHRINK_END
	body.add_child(stop)
