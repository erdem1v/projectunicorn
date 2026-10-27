class_name SprintFoot
extends HBoxContainer

# Orta sütunun alt şeridi: solda planlamayı devretme (PM'in yüzüyle; PM yokken kilitli), sağda planlamada "Sprinti başlat" (kartsız
# planda yanında "0 kart" ve basınca boş sprint) ya da sprint sürerken ilerleme. Planlama PM'e devredilmişse iki kipte de solda PM'in
# yüzü, "{PM} planlıyor" ve "Planlamayı geri al", sağda planlamada "Kendiliğinden başlar" (kartlı planda ekip yokken onun yerine
# çıkış yolu), sprint sürerken ilerleme. Yalnız modeli çizer; tıklar sekmeye `action` olarak çıkar.
# Her öğe kendi Control'üdür. Saat ilerleyince `set_progress` yüzdeyi sayfa kurulmadan günceller.

signal action(kind: String, args: Dictionary)

const PLAY := "res://assets/icons/util/play.svg"

var _bar: ProgressBar
var _figure: Label


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_L)


func setup(c: Dictionary) -> void:
	UiFactory.clear(self)
	var delegate: Dictionary = c.delegate
	var planning: bool = c.mode == "plan"
	if delegate.on:
		add_child(_planner(delegate.pm))
		add_child(RnDUiShared.spacer())
		add_child(_undo())
		if not planning:
			add_child(_progress(c.progress, true))
		elif c.team_empty and not c.cards.is_empty():
			# Kimse çalışamıyorken devirli plan kendiliğinden başlamaz: kutunun yerinde çıkış yolu; ekip dönünce kutu geri gelir.
			add_child(SprintUiShared.way_out(c, &"FloatLink", action.emit))
		else:
			add_child(_auto_start())
		return
	add_child(_delegate(delegate.pm))
	add_child(RnDUiShared.spacer())
	if planning:
		_start(c)
	else:
		add_child(_progress(c.progress))


## Koşan sprintin yüzdesi: çubuk dolar, sayı yenilenir.
func set_progress(progress: Dictionary) -> void:
	var share: float = progress.done / progress.total if progress.total > SprintSystem.EPS else 0.0
	_bar.value = share
	_figure.text = Fmt.percent(roundf(share * 100.0), 0)


## Planlamayı devret: PM varken yüzü ve adıyla basılır (sprint sürerken de), PM yokken kilit ikonuyla soluk ve basılmaz.
func _delegate(pm: Variant) -> PanelContainer:
	var box := _box(&"DelegateBox" if pm != null else &"DelegateBoxLocked")
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	box.add_child(row)
	if pm == null:
		box.tooltip_text = tr("PRODUCT_DELEGATE_LOCKED")
		row.add_child(UiFactory.make_glyph(SprintUiShared.LOCK, UiTokens.D_ICON_BUTTON, UiTokens.D_INK_OFF))
		row.add_child(SprintUiShared.label(tr("PRODUCT_DELEGATE_PLAIN"), &"DataStrong", UiTokens.D_INK_OFF))
		HRUiShared.set_mouse_ignore(row)
		return box
	row.add_child(SprintUiShared.avatar(pm, UiTokens.D_AVATAR_ROW_SM))
	row.add_child(SprintUiShared.label(tr("PRODUCT_DELEGATE").format({"name": pm.name}), &"DataStrong"))
	HRUiShared.set_mouse_ignore(row)
	box.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	box.mouse_entered.connect(func() -> void: box.theme_type_variation = &"DelegateBoxHover")
	box.mouse_exited.connect(func() -> void: box.theme_type_variation = &"DelegateBox")
	box.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			action.emit("delegate", {"on": true}))
	return box


## Devirdeyken planlamayı yürüten PM: yüzü (yıldız çipiyle) ve "{PM} planlıyor".
func _planner(pm: Dictionary) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(SprintUiShared.face_slot(pm, UiTokens.D_AVATAR_ROW))
	row.add_child(SprintUiShared.label(tr("PRODUCT_DELEGATE_ON").format({"name": pm.name}), &"DataText"))
	return row


func _undo() -> Button:
	return SprintUiShared.button(tr("PRODUCT_DELEGATE_UNDO"), &"SecondaryButton", action.emit.bind("delegate", {"on": false}))


## Planlama devredilmişken başlat yerine duran kutu: sprint kendiliğinden başlar.
func _auto_start() -> PanelContainer:
	var box := _box(&"ProgressBox")
	box.custom_minimum_size.x = UiTokens.D_W_START
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(UiFactory.make_glyph(PLAY, UiTokens.D_ICON_TAG, UiTokens.D_INK_3))
	row.add_child(SprintUiShared.label(tr("PRODUCT_AUTO_START"), &"HeadMeta"))
	box.add_child(row)
	return box


## Sprinti başlat: ekip yokken basılmaz (gerekçesi ipucunda, kimse çalışamıyorken kartlı planda çıkış yolu yanında); kartsız planda
## yanında "0 kart" ve basınca boş sprint başlar.
func _start(c: Dictionary) -> void:
	if c.team_empty and not c.cards.is_empty():
		add_child(SprintUiShared.way_out(c, &"FloatLink", action.emit))
	if c.start_skips:
		add_child(SprintUiShared.label(tr(Fmt.count_key("PRODUCT_STATUS_CARDS", 0)).format({"n": 0}), &"Caption"))
	var start := SprintUiShared.button(tr("PRODUCT_START_SPRINT"), &"PrimaryButtonDark", action.emit.bind("start", {}))
	start.custom_minimum_size.x = UiTokens.D_W_START
	start.disabled = not c.can_start
	start.tooltip_text = c.start_reason
	add_child(start)


## Koşan sprintte başlat yerine: "SPRINT", çubuk, "%{n}" ve "bitti". `tight`: solda devirdeki PM'in adı durur; PM'in adı hiç
## kesilmesin diye çubuk daha kısa olabilir ve kutu yalnız içeriği kadardır (iç payı ve aralıkları aynı).
func _progress(progress: Dictionary, tight := false) -> PanelContainer:
	var box := _box(&"ProgressBox")
	box.custom_minimum_size.x = 0 if tight else UiTokens.D_W_PROGRESS
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	box.add_child(row)
	row.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_PROGRESS")), &"Eyebrow"))
	_bar = ProgressBar.new()
	_bar.theme_type_variation = &"WeekBar"
	_bar.show_percentage = false
	_bar.max_value = 1.0
	_bar.step = 0.001
	_bar.custom_minimum_size = Vector2(UiTokens.D_W_PROGRESS_BAR_TIGHT if tight else UiTokens.D_W_PROGRESS_BAR, UiTokens.D_H_BAR)
	_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(_bar)
	_figure = SprintUiShared.label("", &"ProgressFigure")
	row.add_child(_figure)
	row.add_child(SprintUiShared.label(tr("PRODUCT_STATUS_DONE"), &"HeadMeta"))
	set_progress(progress)
	return box


## Şeridin kutusu: düğme boyunda, dikeyde ortada.
func _box(variation: StringName) -> PanelContainer:
	var box := PanelContainer.new()
	box.theme_type_variation = variation
	box.custom_minimum_size.y = UiTokens.D_H_BTN
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return box
