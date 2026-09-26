class_name ProductTeamPanel
extends VBoxContainer

# ============================================================================
# ÜRÜN → sürüm planı · EKİP PANELİ (onaylı S4 / S4a'nın sağ yarısı). Gramer:
#   · Çoklu seçim satırları, ANA ALANA göre gruplanmış açılır/kapanır akordeon
#     ("▾ Yazılım (4)" · "▸ Müşteri İlişkileri (1)").
#   · Seçililer en üste, kendi "SEÇİLİ (n)" grubuna sabitlenir.
#   · Kurucu her zaman listede; rolü olmadığı için en yüksek alanının grubunda durur.
#   · Mini yıldızlar (StarRating, yarımlar gerçek) ve müsaitlik bayrakları
#     ("Eğitimde · 4g sonra katılır" / "İzinde · 12g sonra katılır").
#   · Lider satırı: ad + Liderlik yıldızı. YÜZDE YOK, hiçbir yerde (GDD).
# Mini filtre satırı yalnız 10+ çalışanda görünür (onaylı kare).
#
# İK formülü burada türetilmez: kadro CharacterRegistry'den, yetenek HRSystem.skill'ten,
# meşguliyet HRSystem.is_busy'den okunur. Grup başlığı ve satır stylebox'ları kodda kurulur:
# tek seferlik şekiller için tema öğesi eklememek evin desenidir.
#
# GameShell alt ağacında mount edildiği için PROCESS_MODE_ALWAYS miras alınır.
# ============================================================================

## Seçili kişi kimlikleri değişti (kurucu dahil).
signal selection_changed(ids: Array)
## Lider değişti. "" = lider yok (seçili kişi kalmadığında da bu yayılır).
signal lead_changed(id: String)

# Onaylı 1920'lik kareden ölçüler.
const W_AREA := 148
const W_AVAIL := 186
const CHECK_PX := 14
const ROW_PAD_X := 12
const ROW_PAD_Y := 8
const SELECT_BAR_W := 2
const STAR_PX := 12
const CHEVRON_PX := 9

## Filtre satırı 10+ çalışanda görünür. Kurucu sayılmaz: `count_employees` tam olarak onu sayar.
const FILTER_MIN_EMPLOYEES := 10

## Başlangıçta açık gruplar — onaylı karede kurucu ve ürün tarafı açık, gerisi kapalı.
const DEFAULT_OPEN_AREAS := ["product", "design", "engineering"]
## SEÇİLİ grubunun akordeon anahtarı; alan kimlikleriyle çakışmaz.
const GROUP_SELECTED := "_selected"

## Soluk (meşgul) satırın alfası — evin sayısı.
const DIM_ALPHA := 0.45

var _selected: Array[String] = []
var _lead_id: String = ""
var _open_groups: Dictionary = {GROUP_SELECTED: true}   # grup anahtarı -> açık mı

# Filtre durumu (yalnız 10+ çalışanda görünür, ama durumu her zaman geçerli).
var _filter_text: String = ""
var _filter_area: String = ""             # "" = tüm alanlar
var _filter_available_only: bool = false

## Kabuk (başlık · filtre · lider yuvası) yalnız `_rebuild`'de kurulur; saatlik repaint ve
## etkileşimler yalnız iki kabı yeniden doldurur. Kabuğu yeniden kurmak arama alanının
## odağını ve imlecini götürür — oyuncu tek harf yazıp yazmayı bırakır.
var _has_filter: bool = false
var _count_label: Label = null
var _list: VBoxContainer = null
var _lead_holder: VBoxContainer = null


# ------------------------------------------------------------------ public API

## `preselected` kadroda bulunmayan kimlikleri sessizce düşürür; `lead_id` seçili değilse
## lider boş doğar (bir kimsenin lideri olamaz).
func setup(preselected: Array, lead_id: String) -> void:
	_selected.clear()
	for raw in preselected:
		var cid: String = String(raw)
		if not _selected.has(cid) and CharacterRegistry.get_character(cid) != null:
			_selected.append(cid)
	_lead_id = lead_id if _selected.has(lead_id) else ""
	for area in HRConstants.AREAS:
		_open_groups[String(area)] = DEFAULT_OPEN_AREAS.has(String(area))
	_rebuild()


func lead_id() -> String:
	return _lead_id


## Saatlik/günlük tazeleme (müsaitlik İK'da değişir). Kabuk, filtre satırının varlığı
## değişmedikçe yerinde kalır.
func repaint() -> void:
	if (CharacterRegistry.count_employees() >= FILTER_MIN_EMPLOYEES) != _has_filter:
		_rebuild()
		return
	_refresh_list()
	_refresh_lead()
	_refresh_count()


# ------------------------------------------------------------------ çizim

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	add_theme_constant_override("separation", 0)
	_has_filter = CharacterRegistry.count_employees() >= FILTER_MIN_EMPLOYEES

	add_child(_make_header())
	add_child(HRUiShared.hairline())
	if _has_filter:
		add_child(_make_filter_row())
		add_child(HRUiShared.hairline())
	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 0)
	add_child(_list)
	add_child(HRUiShared.hairline())
	_lead_holder = VBoxContainer.new()
	_lead_holder.add_theme_constant_override("separation", 0)
	add_child(_lead_holder)

	_refresh_list()
	_refresh_lead()
	_refresh_count()


## Kadro listesi — akordeon grupları ve satırlar.
func _refresh_list() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	# Kurucu her zaman listede, sonra çalışanlar. Mentor ve npc kadro değildir.
	var roster: Array[Character] = []
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		roster.append(founder)
	roster.append_array(CharacterRegistry.get_employees())

	var picked: Array = roster.filter(func(c: Character) -> bool: return _selected.has(c.id))
	if not picked.is_empty() \
			and _add_group_header(tr("PROD_TEAM_GROUP_SELECTED"), GROUP_SELECTED, picked.size()):
		for c in picked:
			_list.add_child(_make_person_row(c))

	# Alan grupları, HRConstants.AREAS sırasıyla (ikinci bir sıralama tablosu tutulmaz, §15.2).
	for area_raw in HRConstants.AREAS:
		var area: String = String(area_raw)
		var members: Array = roster.filter(func(c: Character) -> bool:
			return _primary_area(c) == area)
		if members.is_empty():
			continue
		# Grup SAYISI yukarı taşınan seçilileri de sayar (onaylı kare: "Yazılım (3)" iki
		# satır çiziyor).
		if not _add_group_header(HRConstants.area_label(area), area, members.size()):
			continue
		var shown: int = 0
		for c in members:
			if not _selected.has(c.id) and _passes_filter(c):
				_list.add_child(_make_person_row(c))
				shown += 1
		# Grubun tek üyesi yukarı taşınmış kurucuysa grup boş görünmesin.
		if shown == 0 and founder != null and _selected.has(founder.id) and members.has(founder):
			_list.add_child(_make_pinned_ghost_row(founder, area))


## Lider satırı yuvası. Seçim değiştiğinde tek başına tazelenir.
func _refresh_lead() -> void:
	for child in _lead_holder.get_children():
		_lead_holder.remove_child(child)
		child.queue_free()
	_lead_holder.add_child(_make_lead_row())


func _refresh_count() -> void:
	_count_label.text = tr("PROD_SELECTED_COUNT").format({"n": _selected.size()})


func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_section_header(tr("PROD_TEAM_HEADER")))
	row.add_child(UiFactory.make_label(tr("PROD_TEAM_HEADER_SUB"), &"MicroLabel", UiTokens.INK_FAINT))
	row.add_child(_spacer())
	_count_label = UiFactory.make_label("", &"RowMeta")
	row.add_child(_count_label)
	return _padded(row, 11)


## Mini filtre satırı — ad · alan · müsaitlik.
func _make_filter_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)

	var search := LineEdit.new()
	search.placeholder_text = tr("PROD_TEAM_FILTER_SEARCH")
	search.text = _filter_text
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_changed.connect(func(text: String) -> void:
		_filter_text = text
		_refresh_list())
	row.add_child(search)

	# Sıfırıncı kalem nötr durumdur ("ALAN ▾" çipi); alan seçilince düğme o alanın adını
	# gösterir, yani filtre kendi durumunu söyler.
	var areas := OptionButton.new()
	areas.add_item(tr("PROD_TEAM_FILTER_AREA_ALL"))
	for area_raw in HRConstants.AREAS:
		areas.add_item(HRConstants.area_label(String(area_raw)))
		if String(area_raw) == _filter_area:
			areas.select(areas.item_count - 1)
	areas.item_selected.connect(func(index: int) -> void:
		_filter_area = "" if index <= 0 else String(HRConstants.AREAS[index - 1])
		_refresh_list())
	row.add_child(areas)

	var avail := Button.new()
	avail.text = tr("PROD_TEAM_FILTER_AVAILABLE")
	avail.toggle_mode = true
	avail.button_pressed = _filter_available_only
	avail.toggled.connect(func(on: bool) -> void:
		_filter_available_only = on
		_refresh_list())
	row.add_child(avail)
	return _padded(row, 9)


## Akordeon başlığını listeye ekler ve grubun açık olup olmadığını döndürür. Açıkken ad daha
## parlak; kapalı grup sessizleşir.
func _add_group_header(title: String, key: String, count: int) -> bool:
	var is_open: bool = bool(_open_groups.get(key, false))
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _band_box(UiTokens.SURFACE_FRAME, ROW_PAD_X, ROW_PAD_Y))
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	bar.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_open_groups[key] = not bool(_open_groups.get(key, false))
			_refresh_list.call_deferred())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	var tint: Color = UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM
	# Evde yalnız aşağı şevron var; kapalı hâl onun çeyrek tur döndürülmüşü.
	var chevron: TextureRect = HRUiShared.chevron(CHEVRON_PX, tint)
	if not is_open:
		chevron.pivot_offset = Vector2(CHEVRON_PX, CHEVRON_PX) * 0.5
		chevron.rotation = -PI * 0.5
	row.add_child(chevron)
	row.add_child(UiFactory.make_label(title, &"RowMeta", tint))
	row.add_child(UiFactory.make_label(
		tr("PROD_TEAM_GROUP_COUNT").format({"n": count}), &"MicroLabel", UiTokens.INK_FAINT))
	bar.add_child(row)
	HRUiShared.set_mouse_ignore(row)
	_list.add_child(bar)
	return is_open


func _make_person_row(c: Character) -> Control:
	var picked: bool = _selected.has(c.id)
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	name_row.add_child(UiFactory.make_label(c.character_name, &"RowName",
		UiTokens.INK if picked else UiTokens.INK_MUTED))
	if c.id == _lead_id:
		name_row.add_child(UiFactory.make_state_chip(tr("PROD_TEAM_LEAD"),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT))
	var card: PanelContainer = _row_card(picked, name_row, Fmt.upper(_title_of(c)),
		_area_cell(c, _primary_area(c)), _availability_text(c), HRSystem.is_busy(c))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.mouse_entered.connect(_on_row_hover.bind(card, picked, true))
	card.mouse_exited.connect(_on_row_hover.bind(card, picked, false))
	card.gui_input.connect(_on_row_input.bind(c.id))
	return card


## Yukarı sabitlenmiş kurucunun grubunda çizilen hayalet satır: tire, boş unvan, grubun
## alanında kurucunun yıldızları ve sağda "yukarıda". Tıklanmaz; hover'ı sebebini söyler.
func _make_pinned_ghost_row(founder: Character, area: String) -> Control:
	var card: PanelContainer = _row_card(false,
		UiFactory.make_label("—", &"RowName", UiTokens.INK_MUTED), "",
		_area_cell(founder, area), tr("PROD_TEAM_PINNED_CAPTION"))
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.tooltip_text = tr("PROD_TEAM_PINNED_HINT")
	return card


## Satır iskeleti: onay kutusu · kim (ad satırı + unvan) · alan hücresi · sağda amber bayrak.
func _row_card(picked: bool, name_line: Control, subtitle: String, area_cell: Control,
		flag_text: String, dim: bool = false) -> PanelContainer:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _row_box(picked, false))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	row.add_child(_check_box(picked))

	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(name_line)
	# Unvan satırı boş olsa da VAR: düşerse satır komşularından kısa kalır.
	who.add_child(UiFactory.make_label(subtitle, &"MicroLabel"))
	if dim:
		who.modulate.a = DIM_ALPHA   # soluk = yalnız alfa; palet dışına ham renk çıkmaz
	row.add_child(who)
	row.add_child(area_cell)

	var flag := UiFactory.make_label(flag_text, &"MicroLabel", UiTokens.ACCENT)
	flag.custom_minimum_size = Vector2(W_AVAIL, 0)
	flag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	flag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(flag)
	HRUiShared.set_mouse_ignore(row)
	return card


## Lider satırı: ad + Liderlik yıldızı, yüzde yok. Tıklanınca seçililer arasından lideri
## değiştiren menü açılır.
func _make_lead_row() -> Control:
	var bar := PanelContainer.new()
	bar.add_theme_stylebox_override("panel", _band_box(UiTokens.CARD_BG, 14, 11))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_section_header(tr("PROD_TEAM_LEAD")))
	row.add_child(_spacer())
	var lead: Character = CharacterRegistry.get_character(_lead_id) if _lead_id != "" else null
	if lead == null:
		row.add_child(UiFactory.make_label(tr("PROD_TEAM_LEAD_NONE"), &"RowMeta", UiTokens.INK_DIM))
	else:
		row.add_child(UiFactory.make_label(lead.character_name, &"RowName"))
		row.add_child(UiFactory.make_label(
			HRConstants.area_label(HRConstants.SKILL_LEADERSHIP), &"MicroLabel"))
		row.add_child(StarRating.make(
			HRSystem.skill(lead, HRConstants.SKILL_LEADERSHIP), STAR_PX))
	bar.add_child(row)
	HRUiShared.set_mouse_ignore(row)

	if _selected.is_empty():
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		return bar
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	bar.tooltip_text = tr("PROD_TEAM_LEAD_PICK")
	bar.gui_input.connect(func(ev: InputEvent) -> void:
		if _is_left_click(ev):
			_open_lead_menu(bar))
	return bar


# ------------------------------------------------------------------ hücreler

func _padded(content: Control, pad_y: int) -> MarginContainer:
	var wrap := MarginContainer.new()
	wrap.add_theme_constant_override("margin_left", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_right", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_top", pad_y)
	wrap.add_theme_constant_override("margin_bottom", pad_y)
	wrap.add_child(content)
	return wrap


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return spacer


## Alan etiketi + beş glif. Hayalet satırda alan grubun alanıdır, kişinin değil.
func _area_cell(c: Character, area: String) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	box.custom_minimum_size = Vector2(W_AREA, 0)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(UiFactory.make_label(HRConstants.area_label(area), &"MicroLabel"))
	box.add_child(StarRating.make(HRSystem.skill(c, area), STAR_PX))
	return box


func _check_box(picked: bool) -> Control:
	var box := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_INPUT
	sb.border_color = UiTokens.ACCENT if picked else UiTokens.BORDER_HOVER
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	box.add_theme_stylebox_override("panel", sb)
	box.custom_minimum_size = Vector2(CHECK_PX, CHECK_PX)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tick := UiFactory.make_label("✓" if picked else "", &"BadgeLabel", UiTokens.ACCENT)
	tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(tick)
	return box


## Grup başlığı ve lider bandı: düz zemin, yalnız alt saç teli.
func _band_box(bg: Color, pad_x: int, pad_y: int) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	sb.content_margin_left = pad_x
	sb.content_margin_right = pad_x
	sb.content_margin_top = pad_y
	sb.content_margin_bottom = pad_y
	return sb


## Satır kutusu. Sol şerit seçimi söyler (2px amber), saç teli satırları ayırır, hover
## yalnız kenarı açar: dolgu ve kalınlık üç durumda da aynı, satır bir piksel bile oynamaz.
## Godot tek kenar rengi taşır; seçim şeridi amberi kazanır, hover kenarı yalnız seçili
## değilken gelir.
func _row_box(picked: bool, hovered: bool) -> StyleBoxFlat:
	var sb: StyleBoxFlat = _band_box(UiTokens.AMBER_WASH if picked else UiTokens.CARD_BG,
		ROW_PAD_X, ROW_PAD_Y)
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_width_left = SELECT_BAR_W
	if picked:
		sb.border_color = UiTokens.ACCENT
	elif hovered:
		sb.border_color = UiTokens.BORDER_HOVER
	return sb


## Kişinin grubu = ANA ALANI. Kurucunun rolü yoktur (ROLE_AREAS'ta satırı yok); en yüksek
## alanına yerleşir, eşitlikte AREAS sırası. Bir görüntü kararı, İK formülü değil.
func _primary_area(c: Character) -> String:
	var key: String = HRConstants.role_key_area(c.role)
	if key != "":
		return key
	var best: String = String(HRConstants.AREAS[0])
	var best_v: int = -1
	for area_raw in HRConstants.AREAS:
		var v: int = HRSystem.skill(c, String(area_raw))
		if v > best_v:
			best_v = v
			best = String(area_raw)
	return best


## Unvan: çalışanda seviye ön ekiyle, kurucuda yalnız "KURUCU" — kurucunun seviyesi yoktur.
func _title_of(c: Character) -> String:
	if c.category == "founder":
		return HRConstants.role_label(HRConstants.ROLE_FOUNDER)
	return HRConstants.job_title(c.role, c.level)


## Müsait olan kimsede boş döner. Gün sayıları izin ve eğitim domain'lerinin kendi okuma
## seam'lerinden gelir; burada tarih aritmetiği yapılmaz.
func _availability_text(c: Character) -> String:
	if c.training_days_left > 0:
		return tr("PROD_TEAM_AVAIL_TRAINING").format({"n": c.training_days_left})
	if c.status == HRConstants.STATUS_ON_LEAVE:
		return tr("PROD_TEAM_AVAIL_LEAVE").format({"n": HRMoraleSystem.days_until_return(c)})
	if c.category == "founder" and HRSystem.is_busy(c):
		# Kurucunun üçüncü meşguliyeti: yatırım hazırlığı. Cümlesi İK'nın evinde.
		return tr("HR_FOUNDER_STATE_PITCH_PREP")
	return ""


func _passes_filter(c: Character) -> bool:
	if _filter_available_only and HRSystem.is_busy(c):
		return false
	if _filter_area != "" and _primary_area(c) != _filter_area:
		return false
	return _filter_text == "" or c.character_name.to_lower().contains(_filter_text.to_lower())


# ------------------------------------------------------------------ etkileşim

func _is_left_click(ev: InputEvent) -> bool:
	var mb := ev as InputEventMouseButton
	return mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT


func _on_row_hover(card: PanelContainer, picked: bool, entered: bool) -> void:
	card.add_theme_stylebox_override("panel", _row_box(picked, entered))


func _on_row_input(ev: InputEvent, character_id: String) -> void:
	if not _is_left_click(ev):
		return
	if _selected.has(character_id):
		_selected.erase(character_id)
		if _lead_id == character_id:
			_lead_id = ""   # lider seçimden çıktı: bir kimsenin lideri olamaz
			lead_changed.emit(_lead_id)
	else:
		_selected.append(character_id)
	# ERTELENMİŞ: satırı kendi `gui_input`'u akarken silmek düğümü sinyalin altından çeker.
	_refresh_list.call_deferred()
	_refresh_lead.call_deferred()
	_refresh_count()
	selection_changed.emit(_selected.duplicate())


## Lider menüsü: yalnız seçili kişiler — seçili olmayan sürümde çalışmıyor.
func _open_lead_menu(anchor: Control) -> void:
	var ids: Array[String] = []
	var menu := PopupMenu.new()
	for cid in _selected:
		var c: Character = CharacterRegistry.get_character(cid)
		if c != null:
			menu.add_item(c.character_name, ids.size())
			ids.append(cid)
	if ids.is_empty():
		menu.free()
		return
	add_child(menu)
	menu.id_pressed.connect(func(index: int) -> void: _set_lead(ids[index]))
	menu.popup_hide.connect(menu.queue_free, CONNECT_ONE_SHOT)
	menu.position = Vector2i(anchor.get_screen_position()) + Vector2i(0, int(anchor.size.y))
	menu.popup()


func _set_lead(pick: String) -> void:
	if pick == _lead_id:
		return
	_lead_id = pick
	# Ertelenmiş: ağaç, menünün kendi sinyali akarken değiştirilmez.
	_refresh_list.call_deferred()
	_refresh_lead.call_deferred()
	lead_changed.emit(_lead_id)
