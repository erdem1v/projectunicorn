class_name ProductTeamPanel
extends VBoxContainer

# ============================================================================
# ÜRÜN → sürüm planı · EKİP PANELİ (onaylı S4 / S4a'nın SAĞ YARISI).
#
# S4'ün sol yarısı (kart ızgarası) emekli oldu; BU YARI AYNEN DURUYOR ve burada
# birebir uygulanıyor. Gramerin sekiz maddesi, tasarımın kendi cümleleriyle:
#
#   · SORUMLU DROPDOWN'I GİTTİ. Yerinde ÇOKLU SEÇİM satırları var.
#   · Satırlar ANA ALANA göre gruplanır; grup başlığı açılır/kapanır akordeondur
#     ("▾ Yazılım (4)" · "▸ Müşteri İlişkileri (1)").
#   · SEÇİLİLER EN ÜSTE SABİTLENİR, kendi "SEÇİLİ (n)" grubunun altında.
#   · KURUCU HER ZAMAN LİSTEDE. Rolü olmadığı için kendi anahtar alanı da yok;
#     en yüksek alanının grubunda durur (aşağıdaki `_primary_area`).
#   · MİNİ YILDIZLAR — StarRating, beş glif, yarımlar gerçek.
#   · MÜSAİTLİK BAYRAKLARI: "Eğitimde · 4g sonra katılır" / "İzinde · 12g sonra
#     katılır". Meşguliyetin cevabı `HRSystem.is_busy`; gün sayıları izin ve
#     eğitim domain'lerinin kendi okuma seam'lerinden gelir.
#   · LİDER SATIRI: ad + Liderlik yıldızı.
#   · YÜZDE YOK. Hiçbir yerde. (GDD açık.)
#
# MİNİ FİLTRE SATIRI YALNIZ 10+ ÇALIŞANDA görünür — onaylı kare bunu [PH] ile
# işaretliyor; yer tutucu olan İÇERİK SETİ, eşik değil. Üç filtre de canlı
# bağlandı: ölü bir kontrol, olmayan bir kontroldan kötüdür.
#
# İK FORMÜLÜ BURADA TÜRETİLMEZ. Kadro `CharacterRegistry`den, yetenek
# `HRSystem.skill`ten, meşguliyet `HRSystem.is_busy`tan okunur. Bu dosya sayı
# üretmez, düğüm üretir (HRUiShared'ın kendi yasası).
#
# YERLEŞİM BU DOSYANIN, RENK VE BOY TEMANIN: ham `Color(...)` ve ham font boyutu
# yok. Grup başlığı ile satırın stylebox'ları kodda kuruluyor — tek seferlik
# şekiller için tema öğesi EKLEMEMEK sanksiyonlu desendir (HRUiShared._bordered_chip,
# UiFactory.make_dot), ve THEME_STAMP bu yüzden yerinde duruyor.
#
# Sahne DEĞİL, kod. PAUSE: GameShell alt ağacında mount edildiği için
# PROCESS_MODE_ALWAYS MİRAS ALINIR; burada ayrıca set edilmez.
# ============================================================================

## Seçili kişi kimlikleri değişti (kurucu dahil).
signal selection_changed(ids: Array)
## Lider değişti. "" = lider yok (seçili kişi kalmadığında da bu yayılır).
signal lead_changed(id: String)

const MARK_MET := "✓"

# --- Ölçüler. Onaylı 1920'lik kareden: satır 8/12 padding, alan hücresi 140,
# müsaitlik hücresi 180, onay kutusu 14×14.
const W_AREA := 148
const W_AVAIL := 186
const CHECK_PX := 14
const ROW_PAD_X := 12
const ROW_PAD_Y := 8
const SELECT_BAR_W := 2
const STAR_PX := 12
const CHEVRON_PX := 9

## Onaylı kare: filtre satırı 10+ çalışanda görünür. Kurucu SAYILMAZ — cümle
## "10+ çalışan" diyor ve `count_employees` tam olarak onu sayıyor.
const FILTER_MIN_EMPLOYEES := 10

## Başlangıçta AÇIK gruplar — onaylı karede Ürün · Yazılım · Tasarım açık,
## Test · Satış · Müşteri İlişkileri kapalı ("kurucu ve ürün tarafı grupları açık").
const DEFAULT_OPEN_AREAS := ["product", "design", "engineering"]

## Soluk satırın alfası. Evin sayısı (HRLedger._num, StarRating muted).
const DIM_ALPHA := 0.45

var _selected: Array[String] = []
var _lead_id: String = ""
var _open_areas: Dictionary = {}          # area_id -> bool
var _selected_group_open: bool = true

# Filtre durumu (yalnız 10+ çalışanda görünür, ama durumu her zaman geçerli).
var _filter_text: String = ""
var _filter_area: String = ""             # "" = tüm alanlar
var _filter_available_only: bool = false

var _count_label: Label = null
## Kabuk (başlık · filtre · lider yuvası) BİR KEZ kurulur; yalnız bu iki kap
## yeniden doldurulur. Sebep somut: her tuş vuruşunda paneli baştan kurmak arama
## alanının odağını ve imlecini götürüyordu — oyuncu tek harf yazıp yazmayı bırakır.
var _list: VBoxContainer = null
var _lead_holder: VBoxContainer = null


# ------------------------------------------------------------------ public API

## `preselected` kadroda BULUNMAYAN kimlikleri sessizce düşürür; `lead_id` seçili
## değilse lider boş doğar (bir kimsenin lideri olamaz).
func setup(preselected: Array, lead_id: String) -> void:
	_selected.clear()
	for raw in preselected:
		var cid: String = String(raw)
		if cid == "" or _selected.has(cid):
			continue
		if CharacterRegistry.get_character(cid) == null:
			continue
		_selected.append(cid)
	_lead_id = lead_id if _selected.has(lead_id) else ""
	_open_areas.clear()
	for area in HRConstants.AREAS:
		_open_areas[String(area)] = DEFAULT_OPEN_AREAS.has(String(area))
	_rebuild()


func selected_ids() -> Array:
	return _selected.duplicate()


func lead_id() -> String:
	return _lead_id


func repaint() -> void:
	_rebuild()


# ------------------------------------------------------------------ çizim

func _rebuild() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	_count_label = null
	add_theme_constant_override("separation", 0)

	add_child(_make_header())
	add_child(HRUiShared.hairline())
	if CharacterRegistry.count_employees() >= FILTER_MIN_EMPLOYEES:
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


## Kadro listesi — akordeon grupları ve satırlar. Kabuğa dokunmaz.
func _refresh_list() -> void:
	if _list == null or not is_instance_valid(_list):
		return
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()

	var roster: Array[Character] = _roster()

	# --- SEÇİLİ grubu: en üste sabitlenmiş satırlar ------------------------
	var picked: Array[Character] = []
	for c in roster:
		if _selected.has(c.id):
			picked.append(c)
	if not picked.is_empty():
		_list.add_child(_make_group_header(_t("PROD_TEAM_GROUP_SELECTED"), picked.size(),
			_selected_group_open, _on_selected_group_toggled))
		if _selected_group_open:
			for c in picked:
				_list.add_child(_make_person_row(c))

	# --- Alan grupları. Sıra HRConstants.AREAS'ın; ikinci bir sıralama tablosu
	# tutmak §15.2'nin yasakladığı şeydir.
	for area_raw in HRConstants.AREAS:
		var area: String = String(area_raw)
		var members: Array[Character] = []
		var visible_members: Array[Character] = []
		for c in roster:
			if _primary_area(c) != area:
				continue
			members.append(c)
			# SEÇİLİ satır yukarı taşındı — grup SAYISI onu yine de sayar (onaylı
			# karede "Yazılım (3)" üç kişiyi sayıyor ama iki satır çiziyor).
			if not _selected.has(c.id) and _passes_filter(c):
				visible_members.append(c)
		if members.is_empty():
			continue
		var is_open: bool = bool(_open_areas.get(area, false))
		_list.add_child(_make_group_header(HRConstants.area_label(area), members.size(),
			is_open, _on_area_group_toggled.bind(area)))
		if not is_open:
			continue
		for c in visible_members:
			_list.add_child(_make_person_row(c))
		# Kurucunun grubu onun dışında kimseyi taşımıyorsa ve kurucu yukarı
		# taşındıysa grup boş görünürdü; onaylı kare oraya bir hayalet satır koyuyor.
		if visible_members.is_empty() and _founder_pinned_in(members):
			_list.add_child(_make_pinned_ghost_row(area))


## LİDER satırı yuvası. Seçim değiştiğinde tek başına tazelenir.
func _refresh_lead() -> void:
	if _lead_holder == null or not is_instance_valid(_lead_holder):
		return
	for child in _lead_holder.get_children():
		_lead_holder.remove_child(child)
		child.queue_free()
	_lead_holder.add_child(_make_lead_row())


## Kadro: KURUCU HER ZAMAN LİSTEDE, sonra çalışanlar. Mentor ve npc kadro değildir
## ve `get_employees` zaten onları getirmez (LineGates.roster ile aynı kapsam).
func _roster() -> Array[Character]:
	var out: Array[Character] = []
	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		out.append(founder)
	for c in CharacterRegistry.get_employees():
		out.append(c)
	return out


func _make_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_section_header(_t("PROD_TEAM_HEADER")))
	row.add_child(UiFactory.make_label(_t("PROD_TEAM_HEADER_SUB"), &"MicroLabel", UiTokens.INK_FAINT))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)
	_count_label = UiFactory.make_label("", &"RowMeta")
	row.add_child(_count_label)
	var wrap := MarginContainer.new()
	wrap.add_theme_constant_override("margin_left", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_right", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_top", 11)
	wrap.add_theme_constant_override("margin_bottom", 11)
	wrap.add_child(row)
	return wrap


## Mini filtre satırı — ad · alan · müsaitlik. Yalnız 10+ çalışanda kurulur.
func _make_filter_row() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)

	var search := LineEdit.new()
	search.placeholder_text = _t("PROD_TEAM_FILTER_SEARCH")
	search.text = _filter_text
	search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search.text_changed.connect(_on_filter_text_changed)
	row.add_child(search)

	# Sıfırıncı kalem NÖTR DURUMDUR ve sözlükteki adı "ALAN" — onaylı karedeki
	# "ALAN ▾" çipinin ta kendisi. Bir alan seçilince düğme o alanın adını gösterir,
	# yani filtre kendi durumunu söyler ve ayrıca bir etiket gerekmez.
	var areas := OptionButton.new()
	areas.add_item(_t("PROD_TEAM_FILTER_AREA_ALL"), 0)
	var idx: int = 1
	for area_raw in HRConstants.AREAS:
		areas.add_item(HRConstants.area_label(String(area_raw)), idx)
		areas.set_item_metadata(idx, String(area_raw))
		if String(area_raw) == _filter_area:
			areas.select(idx)
		idx += 1
	areas.item_selected.connect(_on_filter_area_selected.bind(areas))
	row.add_child(areas)

	var avail := Button.new()
	avail.text = _t("PROD_TEAM_FILTER_AVAILABLE")
	avail.toggle_mode = true
	avail.button_pressed = _filter_available_only
	avail.toggled.connect(_on_filter_available_toggled)
	row.add_child(avail)

	var wrap := MarginContainer.new()
	wrap.add_theme_constant_override("margin_left", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_right", ROW_PAD_X)
	wrap.add_theme_constant_override("margin_top", 9)
	wrap.add_theme_constant_override("margin_bottom", 9)
	wrap.add_child(row)
	return wrap


## Akordeon başlığı: şevron + ad + (n). Açıkken ad daha parlak — kapalı grup
## sessizleşir, onaylı karenin tek ayrımı bu.
func _make_group_header(title: String, count: int, is_open: bool,
		on_toggle: Callable) -> Control:
	var bar := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.set_border_width_all(0)
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.content_margin_left = ROW_PAD_X
	sb.content_margin_right = ROW_PAD_X
	sb.content_margin_top = ROW_PAD_Y
	sb.content_margin_bottom = ROW_PAD_Y
	bar.add_theme_stylebox_override("panel", sb)
	bar.mouse_filter = Control.MOUSE_FILTER_STOP
	bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	bar.gui_input.connect(_on_group_input.bind(on_toggle))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 9)
	row.add_child(_chevron(is_open))
	var tint: Color = UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM
	row.add_child(UiFactory.make_label(title, &"RowMeta", tint))
	row.add_child(UiFactory.make_label(
		_t("PROD_TEAM_GROUP_COUNT").format({"n": count}), &"MicroLabel", UiTokens.INK_FAINT))
	bar.add_child(row)
	HRUiShared.set_mouse_ignore(row)
	return bar


## ▾ / ▸ — evde YALNIZ aşağı/yukarı şevron var, sağa bakanı yok. Kapalı durum
## aşağı şevronun ÇEYREK TUR döndürülmüşüdür; ikinci bir ikon dosyası eklemek
## yerine aynı glif kullanılıyor (HRUiShared.chevron tek kaynak kalıyor).
func _chevron(is_open: bool) -> Control:
	var glyph: TextureRect = HRUiShared.chevron(CHEVRON_PX,
		UiTokens.INK_MUTED if is_open else UiTokens.INK_DIM)
	if not is_open:
		glyph.pivot_offset = Vector2(CHEVRON_PX, CHEVRON_PX) * 0.5
		glyph.rotation = -PI * 0.5
	return glyph


func _make_person_row(c: Character) -> Control:
	var picked: bool = _selected.has(c.id)
	var available: bool = not HRSystem.is_busy(c)

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _row_box(picked, false))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	card.mouse_entered.connect(_on_row_hover.bind(card, picked, true))
	card.mouse_exited.connect(_on_row_hover.bind(card, picked, false))
	card.gui_input.connect(_on_row_input.bind(c.id))

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	row.add_child(_check_box(picked))

	# --- kim: ad (+ LİDER rozeti) ve unvan --------------------------------
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var name_row := HBoxContainer.new()
	name_row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	name_row.add_child(UiFactory.make_label(c.character_name, &"RowName",
		UiTokens.INK if picked else UiTokens.INK_MUTED))
	if c.id == _lead_id:
		name_row.add_child(UiFactory.make_state_chip(_t("PROD_TEAM_LEAD"),
			UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT))
	who.add_child(name_row)
	who.add_child(UiFactory.make_label(Fmt.upper(_title_of(c)), &"MicroLabel"))
	row.add_child(who)

	# --- ANA alan + mini yıldızlar ----------------------------------------
	row.add_child(_area_cell(c))

	# --- müsaitlik bayrağı -------------------------------------------------
	var flag := UiFactory.make_label(_availability_text(c), &"MicroLabel", UiTokens.ACCENT)
	flag.custom_minimum_size = Vector2(W_AVAIL, 0)
	flag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	flag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(flag)

	if not available:
		# SOLUK = yalnız ALFA; palet tablosu dışına ham renk çıkmıyor.
		who.modulate.a = DIM_ALPHA
	HRUiShared.set_mouse_ignore(row)
	return card


## Grubun tek üyesi yukarı sabitlenmiş kurucuysa çizilen hayalet satır: tire,
## boş unvan satırı ve sağda "yukarıda". Tıklanmaz, ama HOVER'ı sebebini söyler.
##
## Onaylı karede unvan yuvasında "KURUCU SEÇİLİ" yazıyordu; sözlükte o cümlenin
## anahtarı YOK ve buraya uydurma bir metin yazılmaz. Yerine iki mevcut anahtar
## kendi adlarının söylediği işi yapıyor: CAPTION sağdaki tek kelime ("yukarıda"),
## HINT ise satırın hover cümlesi ("Seçilenler üste sabitlenir.").
func _make_pinned_ghost_row(area: String) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _row_box(false, false))
	card.mouse_filter = Control.MOUSE_FILTER_PASS
	card.tooltip_text = _t("PROD_TEAM_PINNED_HINT")

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)
	row.add_child(_check_box(false))

	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 2)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	who.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	who.add_child(UiFactory.make_label("—", &"RowName", UiTokens.INK_MUTED))
	# Boş ama VAR: unvan satırı düşerse hayalet satır komşularından kısa kalır.
	who.add_child(UiFactory.make_label("", &"MicroLabel"))
	row.add_child(who)

	var founder: Character = CharacterRegistry.get_founder()
	if founder != null:
		row.add_child(_area_cell(founder, area))

	var hint := UiFactory.make_label(_t("PROD_TEAM_PINNED_CAPTION"), &"MicroLabel", UiTokens.ACCENT)
	hint.custom_minimum_size = Vector2(W_AVAIL, 0)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(hint)
	HRUiShared.set_mouse_ignore(row)
	return card


## LİDER satırı: ad + Liderlik yıldızı, YÜZDE YOK. Tıklanınca seçililer arasından
## lideri değiştiren menü açılır ("lider seçici v1 gibi").
func _make_lead_row() -> Control:
	var bar := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.CARD_BG
	sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.set_border_width_all(0)
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 11
	sb.content_margin_bottom = 11
	bar.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_section_header(_t("PROD_TEAM_LEAD")))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_child(spacer)

	var lead: Character = CharacterRegistry.get_character(_lead_id) if _lead_id != "" else null
	if lead == null:
		row.add_child(UiFactory.make_label(_t("PROD_TEAM_LEAD_NONE"), &"RowMeta", UiTokens.INK_DIM))
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
	bar.tooltip_text = _t("PROD_TEAM_LEAD_PICK")
	bar.gui_input.connect(_on_lead_row_input.bind(bar))
	return bar


# ------------------------------------------------------------------ hücreler

## Kişinin ANA alanı + beş glif. `override_area` hayalet satır için: orada
# çizilen alan grubun alanıdır, kişinin değil.
func _area_cell(c: Character, override_area: String = "") -> Control:
	var area: String = override_area if override_area != "" else _primary_area(c)
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
	var tick := UiFactory.make_label(MARK_MET if picked else "", &"BadgeLabel", UiTokens.ACCENT)
	tick.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tick.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(tick)
	return box


## Satır kutusu. SOL ŞERİT seçimi söyler (2px amber), ALT SAÇ TELİ satırları ayırır,
## HOVER YALNIZ KENARI AÇAR — dolgu kıpırdamaz ve kalınlık üç durumda da aynı, o
## yüzden satır hover'da bir piksel bile oynamaz.
func _row_box(picked: bool, hovered: bool) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_WASH if picked else UiTokens.CARD_BG
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.border_width_left = SELECT_BAR_W
	sb.border_width_top = UiTokens.BORDER_HAIRLINE
	sb.border_width_right = UiTokens.BORDER_HAIRLINE
	sb.border_width_bottom = UiTokens.BORDER_HAIRLINE
	# Godot tek bir kenar rengi taşır; şerit ile saç teli aynı rengi paylaşamaz.
	# Seçim şeridi amberi kazanır (onaylı karenin okunuşu), hover kenarı onun üstünü
	# yalnız seçili DEĞİLKEN alır.
	if picked:
		sb.border_color = UiTokens.ACCENT
	elif hovered:
		sb.border_color = UiTokens.BORDER_HOVER
	else:
		sb.border_color = UiTokens.DIVIDER_LIGHT
	sb.content_margin_left = ROW_PAD_X
	sb.content_margin_right = ROW_PAD_X
	sb.content_margin_top = ROW_PAD_Y
	sb.content_margin_bottom = ROW_PAD_Y
	return sb


## Kişinin grubu = ANA ALANI. Kurucunun rolü yoktur, dolayısıyla ROLE_AREAS'ta
## satırı da yoktur; en yüksek alanına yerleştirilir (eşitlikte AREAS sırası).
## Bu bir GÖRÜNTÜ kararıdır, bir İK formülü değil — hiçbir sayı türetilmiyor.
func _primary_area(c: Character) -> String:
	if c == null:
		return String(HRConstants.AREAS[0])
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


## Unvan: çalışanda seviye ön ekiyle ("KIDEMLİ YAZILIM MÜHENDİSİ"), kurucuda
## yalnız "KURUCU" — kurucunun seviyesi yoktur ve `job_title` ona ön ek takardı.
func _title_of(c: Character) -> String:
	if c.category == "founder":
		return HRConstants.role_label(HRConstants.ROLE_FOUNDER)
	return HRConstants.job_title(c.role, c.level)


## "Eğitimde · 4g sonra katılır" / "İzinde · 12g sonra katılır". Müsait olan
## kimsede BOŞ döner, yani çağıran koşulsuz basabilir. Gün sayıları domain'in
## kendi okuma seam'lerinden; burada tarih aritmetiği yapılmıyor.
func _availability_text(c: Character) -> String:
	if c == null:
		return ""
	if c.training_days_left > 0:
		return _t("PROD_TEAM_AVAIL_TRAINING").format({"n": c.training_days_left})
	if c.status == HRConstants.STATUS_ON_LEAVE:
		return _t("PROD_TEAM_AVAIL_LEAVE").format({"n": HRMoraleSystem.days_until_return(c)})
	if c.category == "founder" and HRSystem.is_busy(c):
		# Kurucunun üçüncü meşguliyeti: yatırım hazırlığı. Cümlesi İK'nın evinde.
		return _t("HR_FOUNDER_STATE_PITCH_PREP")
	return ""


func _passes_filter(c: Character) -> bool:
	if _filter_available_only and HRSystem.is_busy(c):
		return false
	if _filter_area != "" and _primary_area(c) != _filter_area:
		return false
	if _filter_text != "" and not c.character_name.to_lower().contains(_filter_text.to_lower()):
		return false
	return true


func _founder_pinned_in(members: Array[Character]) -> bool:
	for c in members:
		if c.category == "founder" and _selected.has(c.id):
			return true
	return false


# ------------------------------------------------------------------ etkileşim

func _on_group_input(ev: InputEvent, on_toggle: Callable) -> void:
	if _is_left_click(ev) and on_toggle.is_valid():
		on_toggle.call()


func _on_selected_group_toggled() -> void:
	_selected_group_open = not _selected_group_open
	_refresh_list.call_deferred()


func _on_area_group_toggled(area: String) -> void:
	_open_areas[area] = not bool(_open_areas.get(area, false))
	_refresh_list.call_deferred()


func _on_row_hover(card: PanelContainer, picked: bool, entered: bool) -> void:
	if card != null and is_instance_valid(card):
		card.add_theme_stylebox_override("panel", _row_box(picked, entered))


func _on_row_input(ev: InputEvent, character_id: String) -> void:
	if not _is_left_click(ev):
		return
	if _selected.has(character_id):
		_selected.erase(character_id)
		if _lead_id == character_id:
			# Lider seçimden çıktı: bir kimsenin lideri olamaz.
			_lead_id = ""
			lead_changed.emit(_lead_id)
	else:
		_selected.append(character_id)
	# ERTELENMİŞ: satırı, kendi `gui_input`'ı hâlâ akarken silmek Godot'ta düğümü
	# sinyalin altından çeker. Aynı ihtiyat lider menüsünde de var.
	_refresh_list.call_deferred()
	_refresh_lead.call_deferred()
	_refresh_count()
	selection_changed.emit(selected_ids())


func _on_lead_row_input(ev: InputEvent, anchor: Control) -> void:
	if _is_left_click(ev):
		_open_lead_menu(anchor)


## Lider menüsü: YALNIZ seçili kişiler. Seçili olmayan biri lider olamaz, çünkü
## sürümde çalışmıyor.
func _open_lead_menu(anchor: Control) -> void:
	var ids: Array[String] = []
	var menu := PopupMenu.new()
	for cid in _selected:
		var c: Character = CharacterRegistry.get_character(String(cid))
		if c == null:
			continue
		menu.add_item(c.character_name, ids.size())
		ids.append(String(cid))
	if ids.is_empty():
		menu.free()
		return
	add_child(menu)
	menu.id_pressed.connect(_on_lead_menu_picked.bind(ids))
	menu.popup_hide.connect(menu.queue_free, CONNECT_ONE_SHOT)
	menu.position = Vector2i(anchor.get_screen_position()) + Vector2i(0, int(anchor.size.y))
	menu.popup()


func _on_lead_menu_picked(index: int, ids: Array) -> void:
	if index < 0 or index >= ids.size():
		return
	var pick: String = String(ids[index])
	if pick == _lead_id:
		return
	_lead_id = pick
	# Menü BU düğümün çocuğu; kapları ertelenmiş tazelemek onu kendi
	# sinyalinin ortasında serbest bırakmaktan kaçınır.
	_refresh_list.call_deferred()
	_refresh_lead.call_deferred()
	lead_changed.emit(_lead_id)


func _on_filter_text_changed(text: String) -> void:
	_filter_text = text
	_refresh_list()


func _on_filter_area_selected(index: int, source: OptionButton) -> void:
	_filter_area = "" if index <= 0 else String(source.get_item_metadata(index))
	_refresh_list()


func _on_filter_available_toggled(on: bool) -> void:
	_filter_available_only = on
	_refresh_list()


func _is_left_click(ev: InputEvent) -> bool:
	if not (ev is InputEventMouseButton):
		return false
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT


func _refresh_count() -> void:
	if _count_label != null and is_instance_valid(_count_label):
		_count_label.text = _t("PROD_SELECTED_COUNT").format({"n": _selected.size()})


func _t(key: String) -> String:
	return TranslationServer.translate(key)
