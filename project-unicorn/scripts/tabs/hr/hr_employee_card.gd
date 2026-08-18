class_name HREmployeeCard
extends RefCounted

# ============================================================================
# Çalışan kartı — Kare 1 anatomisi, Kare 6 aksiyon satırı, Kare 7 izinde hali,
# Kare 5 YENİ etiketi.
#
# Kart TAMAMEN görsel: hiçbir sonucu kendisi hesaplamaz, aksiyon akışlarını da
# yürütmez. Her rakam bir motor çağrısından gelir, her buton `on_action`
# Callable'ını çağırır ve akışı sekme yürütür (onay modalı, popover, repaint).
#
# Aksiyon butonlarının açık/kapalı hali ve kapalıysa GEREKÇESİ preview_*'tan
# okunur, can_*'tan DEĞİL: can_* yalnız bool döner, sebep dizesi yalnız
# preview_*'ın `reason` anahtarında yaşıyor. Bu yüzden bu dosya can_* çağırmaz.
#
# # WORKING TR — oyuncuya görünen tüm metin çalışma metni; ses geçişi sonra.
# ============================================================================

const AVATAR_PX := 30
const ACTION_RAISE := "raise"
const ACTION_VACATION := "vacation"
const ACTION_FIRE := "fire"


static func build(emp: Character, on_action: Callable, expanded: bool, refs: Dictionary) -> Control:
	# refs: yerinde-repaint referansları buraya yazılır (moral barı/sayısı). Kart
	# kümesi değişmediği sürece sekme kartları yeniden kurmaz, yalnız bunları tazeler.
	var on_leave: bool = emp.status == HRConstants.STATUS_ON_LEAVE
	# Amber çerçeveli dikkat kartı YALNIZ kaçma riskinde. TÜKENİYOR da bir dikkat rozeti
	# ama rozetin kendisi zaten amber; her rozetli kartı boyamak sayfayı pembeye çeviriyor
	# ve "gerçekten şimdi bakılmalı" sinyalini ucuzlatıyordu (mockup'ta 38 morallı kart
	# normal kart + rozet).
	var urgent: bool = HRConstants.is_flight_risk(emp.morale) and not on_leave
	var card := PanelContainer.new()
	card.theme_type_variation = &"CardAttention" if urgent else &"CardPanel"
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if on_leave:
		# Kare 7: sönük kart. Moral barı YOK (izindeyken moral yönetilmez), eksenler soluk.
		card.modulate = Color(1, 1, 1, 0.62)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 6)
	card.add_child(col)

	# --- kimlik satırı ---
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 10)
	head.add_child(UiFactory.make_avatar(UiFactory.initials_of(emp.character_name), AVATAR_PX))
	var id_col := VBoxContainer.new()
	id_col.add_theme_constant_override("separation", 2)
	id_col.add_child(UiFactory.make_label(emp.character_name, &"NameSerif"))
	id_col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"RowMeta", UiTokens.INK_DIM))
	id_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(id_col)
	var money_col := VBoxContainer.new()
	money_col.add_theme_constant_override("separation", 2)
	money_col.alignment = BoxContainer.ALIGNMENT_END
	var salary := UiFactory.make_label(
		"Maaş %s/ay" % HRUiShared.money(emp.monthly_salary), &"RowMeta")
	salary.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	money_col.add_child(salary)
	var tenure := UiFactory.make_label(HRSystem.tenure_line(emp), &"RowMeta", UiTokens.INK_DIM)
	tenure.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	money_col.add_child(tenure)
	head.add_child(money_col)
	col.add_child(head)

	# --- faz okunabilirliği (Coupling yükümlülüğü) + moral, aynı satırın iki ucunda ---
	# Kart sayfa genişliğinde olduğu için moral barı kendi satırında sağa yapışınca
	# boşlukta yüzüyordu; faz satırının sağ ucuna oturunca hem kompakt kalıyor hem de
	# okunacak iki bilgi aynı hizada duruyor.
	var mid := HBoxContainer.new()
	mid.add_theme_constant_override("separation", 12)
	var hint: Label = HRUiShared.phase_hint_label(emp.role)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mid.add_child(hint)
	if on_leave:
		mid.add_child(UiFactory.make_label(
			UiTokens.tr_upper(HRSystem.leave_line(emp)), &"SectionLabel"))
	else:
		mid.add_child(HRUiShared.morale_row(emp.morale, refs))
	col.add_child(mid)

	# --- eksenler + rozetler ---
	var bottom := HBoxContainer.new()
	bottom.add_theme_constant_override("separation", 8)
	bottom.add_child(HRUiShared.axis_chips(emp.role_stats, on_leave))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom.add_child(spacer)
	bottom.add_child(HRUiShared.badge_row(emp))
	col.add_child(bottom)

	# Müşteri Temsilcisi'nin yükü. Kart hiçbir sayıyı kendi hesaplamaz (dosya başlığındaki
	# kural) — ikisi de motor çağrısı. Bu satır olmadan kapasite görünmez bir sayıydı:
	# oyuncu ne kadar hesap taşındığını da, bir MT daha almanın ne açacağını da göremiyordu.
	if emp.role == HRConstants.ROLE_CUSTOMER_REP:
		var load: int = CustomerRepSystem.roster_size(emp.id)
		var cap: int = B2BConstants.cs_capacity(int(emp.role_stats.get(HRConstants.AXIS_PACE, 0)))
		# TranslationServer, not tr(): build() is static and statics cannot call tr()
		# (same reason UiTokens.net_runway_parts does it this way).
		var fmt: String = TranslationServer.translate("HR_CS_LOAD")
		col.add_child(UiFactory.make_label(fmt.format({"n": load, "cap": cap}), &"RowMeta", UiTokens.INK_DIM))

	if not emp.traits.is_empty():
		col.add_child(HRUiShared.trait_row(emp.traits))

	# Buraya kadarki her şey tıklamayı geçirir — gui_input kart kökünde (ev deseni).
	# Aksiyon satırı BUNDAN SONRA eklenir, çünkü butonları ignore yapmak onları öldürür.
	HRUiShared.set_mouse_ignore(col)

	if expanded:
		col.add_child(HRUiShared.hairline())
		col.add_child(_action_row(emp, on_action))

	card.gui_input.connect(_on_card_input.bind(emp.id, on_action))
	return card


static func _action_row(emp: Character, on_action: Callable) -> Control:
	# Kare 6: ZAM YAP · TATİLE GÖNDER · İŞTEN ÇIKAR. Her butonun hali motorun
	# önizlemesinden; kapalıysa tooltip motorun gerekçesi.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)

	var raise_pv: Dictionary = HRActions.preview_raise(emp, HRConstants.RAISE_MIN_PCT)
	row.add_child(_maybe_button("ZAM YAP", raise_pv, emp, ACTION_RAISE, on_action, true))

	var vac_pv: Dictionary = HRActions.preview_vacation(emp)
	row.add_child(_maybe_button("TATİLE GÖNDER", vac_pv, emp, ACTION_VACATION, on_action, false))

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(spacer)

	var fire_pv: Dictionary = HRActions.preview_fire(emp)
	row.add_child(_maybe_button("İŞTEN ÇIKAR", fire_pv, emp, ACTION_FIRE, on_action, false))
	return row


static func _maybe_button(label: String, preview: Dictionary, emp: Character,
		action: String, on_action: Callable, primary: bool) -> Button:
	if not bool(preview.get("ok", false)):
		return HRUiShared.disabled_button(label, String(preview.get("reason", "")))
	var btn := HRUiShared.action_button(label, Callable(), primary)
	# Çapa olarak butonun kendisi geçiyor: popover ondan çıkar (Kare 6'daki çentik).
	btn.pressed.connect(func() -> void:
		if on_action.is_valid():
			on_action.call(emp.id, action, btn))
	return btn


static func _on_card_input(ev: InputEvent, emp_id: String, on_action: Callable) -> void:
	if ev is InputEventMouseButton and (ev as InputEventMouseButton).pressed \
			and (ev as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		if on_action.is_valid():
			on_action.call(emp_id, "toggle", null)
