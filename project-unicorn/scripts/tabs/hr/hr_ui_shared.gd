class_name HRUiShared
extends RefCounted

# ============================================================================
# HR sekmesinin paylaşılan çizim parçaları (yalnız static, hiç durum tutmaz).
#
# BURADA HİÇBİR SAYI TÜRETİLMEZ. Her değer bir motor çağrısından gelir; bu dosya
# onları düğüme çevirir. Motor bir sayıyı vermiyorsa doğru cevap burada hesaplamak
# değil, motora okuma seam'i eklemektir.
#
# Para: Fmt.money_exact, UiTokens.format_money DEĞİL. HR önizlemelerinin hazır satırları
# Fmt.money_exact ile basılıyor; kart başka biçimde basarsa kendi metniyle çelişir.
# ============================================================================

const MORALE_BAR_HEIGHT := 6
const MORALE_BAR_WIDTH := 92

const TRAIT_ICON_DIR := "res://assets/icons/traits/"
const TRAIT_ICON_DRAWN := ["loyal", "picks_it_up_fast", "takes_them_under",
	"double_checker", "last_one_out", "cant_say_no", "bag_packed", "mood_buster"]
const TRAIT_BOX_PX := 26


# --- Alan yıldızları --------------------------------------------------------
# Alan adı ÜSTTE, beş yıldız ALTINDA. ÇİP DEĞİL: çip bir DURUM anlatır, yıldız bir MİKTAR.

## Çalışanın çizilen alanları, ANA + İKİNCİL: §4.4 altı alanı düz listede göstermeyi
## yasaklıyor.
static func role_areas(role_id: String) -> Array:
	return [HRConstants.role_key_area(role_id), HRConstants.role_secondary_area(role_id)].filter(
		func(key: String) -> bool: return key != "")


## Yıldız hücresinin başlığı. Karizma bir ALAN değil, kendi anahtarından okunur;
## FounderConstants.skill_label oran parçası verir ("+%15 satış"), etiket değil.
static func skill_label(key: String) -> String:
	if key == FounderConstants.SKILL_CHARISMA:
		return TranslationServer.translate("PER_CHARISMA")
	return HRConstants.area_label(key)


## Kişinin ANA + İKİNCİL alanı, yıldızla.
static func area_stars_row(role_id: String, role_stats: Dictionary, glyph_px: int = 14,
		muted: bool = false) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for key in role_areas(role_id):
		row.add_child(StarRating.labelled(HRConstants.area_label(key),
			int(role_stats.get(key, 0)), glyph_px, muted))
	return row


## Sabit genişlikte ROLLER · LİDERLİK hücresi. Liderlik bir alan değil; dikey hairline bunu söylüyor.
static func role_area_cell(emp: Character, width: int, muted: bool = false) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	box.custom_minimum_size = Vector2(width, 0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(area_stars_row(emp.role, emp.role_stats, 14, muted))
	box.add_child(v_hairline())
	box.add_child(StarRating.labelled(HRConstants.area_label(HRConstants.SKILL_LEADERSHIP),
		int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)), 14, muted))
	return box


## Kadro satırının unvanı: çalışanda seviye ön ekiyle, kurucuda yalnız "KURUCU"; kurucunun
## seviyesi yoktur, `job_title` ona ön ek takardı.
static func roster_title(c: Character) -> String:
	if c.category == "founder":
		return HRConstants.role_label(HRConstants.ROLE_FOUNDER)
	return HRConstants.job_title(c.role, c.level)


## Müsait olan kimsede boş döner. Hafta sayıları izin ve eğitim domain'lerinin kendi okuma
## seam'lerinden gelir; burada tarih aritmetiği yapılmaz.
static func availability_text(c: Character) -> String:
	if c.training_weeks_left > 0:
		return TranslationServer.translate(Fmt.count_key("PROD_TEAM_AVAIL_TRAINING",
			c.training_weeks_left)).format({"n": c.training_weeks_left})
	if c.status == HRConstants.STATUS_ON_LEAVE:
		var n: int = HRMoraleSystem.weeks_until_return(c)
		return TranslationServer.translate(Fmt.count_key("PROD_TEAM_AVAIL_LEAVE", n)).format({"n": n})
	if c.category == "founder" and HRSystem.is_busy(c):
		# Kurucunun üçüncü meşguliyeti: yatırım hazırlığı.
		return TranslationServer.translate("HR_FOUNDER_STATE_PITCH_PREP")
	return ""


static func v_hairline(height: int = 26) -> Panel:
	var line := hairline()
	line.custom_minimum_size = Vector2(1, height)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return line


# --- Trait ikonu -----------------------------------------------------------
# Çalışan trait'lerinin sekizi çizili; kurucu trait'leri ve bilinmeyen id nötr glife düşer.

static func trait_icon(trait_id: String, px: int = 18) -> TextureRect:
	var file: String = trait_id if TRAIT_ICON_DRAWN.has(trait_id) else "unspecified"
	return UiFactory.make_glyph(TRAIT_ICON_DIR + file + ".svg", px, UiTokens.INK_MUTED)


## Tooltip: ad ve etki alt alta. PASS, STOP DEĞİL: STOP tooltip'i çalıştırır ama satır
## tıklamasını yutar, ve menüyü açan tek yol o tıklama.
static func _hoverable(node: Control, trait_id: String) -> Control:
	node.tooltip_text = "%s\n%s" % [
		HRConstants.trait_label(trait_id), HRConstants.trait_effect_text(trait_id)]
	node.mouse_filter = Control.MOUSE_FILTER_PASS
	return node


## §13.3 · DURUM SÜTUNU, TEK EV: Kadro ve Görevler ikisi de buradan çizer.
## Sütun aynı anda birden fazla şey taşır (§15.1); rozetler birbirini bastırmaz.
## Sıra §13.3'ün tablosundan: rozetler (AŞIRI YÜK · Ayrılabilir · YENİ), sonra süreli
## etiketler (Eğitimde · İzinde), en sonda en sessizi (saat istisnası).
static func status_cell(emp: Character, width: int = 0) -> Control:
	var box := HBoxContainer.new()
	if width > 0:
		box.custom_minimum_size = Vector2(width, 0)
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	# Dikeyde FILL olursa çip satırın tüm yüksekliğine gerilir ve hücre gibi okunur.
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER

	if HRSystem.is_overloaded(emp):
		var over: Control = UiFactory.make_state_chip(
			UiTokens.tr_upper(TranslationServer.translate("HR_BADGE_OVERLOADED_JOBS")),
			UiTokens.ACCENT_DEEP, UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP)
		over.tooltip_text = TranslationServer.translate("HR_OVERLOAD_HINT")
		over.mouse_filter = Control.MOUSE_FILTER_PASS   # §13.3: çip tıklamayı yutmaz
		box.add_child(over)

	if emp.category == "employee" and HRConstants.is_flight_risk(emp.morale):
		# Renk körü modunda negatif palet değişiyor: sabit değil fonksiyon okunur.
		box.add_child(UiFactory.make_state_chip(
			UiTokens.tr_upper(HRConstants.badge_label(HRConstants.BADGE_FLIGHT_RISK)),
			UiTokens.negative(), UiTokens.negative_bg(), UiTokens.negative_rule()))

	if HRConstants.is_new_hire(emp.hire_day, GameState.day):
		box.add_child(UiFactory.make_state_chip(
			UiTokens.tr_upper(TranslationServer.translate("HR_BADGE_NEW")),
			UiTokens.ACCENT_DEEP, UiTokens.AMBER_BG, UiTokens.ACCENT_DEEP))

	# Süreli durumlar rozet değil, sayaçlı etiket (§13.3).
	if emp.training_weeks_left > 0:
		box.add_child(UiFactory.make_label(HRSystem.training_line(emp), &"RowMeta"))
	elif emp.status == HRConstants.STATUS_ON_LEAVE:
		box.add_child(UiFactory.make_label(HRSystem.leave_line(emp), &"RowMeta"))

	# Saat istisnası. Kurucu istisna alamaz (§2), o yüzden hiç çizilmez.
	if emp.category == "employee":
		var delta: int = WorkHoursSystem.hours_for(emp) - HRConstants.WORK_HOURS_DEFAULT
		if delta != 0:
			var key: String = "HR_STATE_HOURS_OVER" if delta > 0 else "HR_STATE_HOURS_SHORT"
			box.add_child(UiFactory.make_label(
				TranslationServer.translate(key).format({"n": absi(delta)}),
				&"MicroLabel", UiTokens.INK_DIM))

	if box.get_child_count() == 0:
		box.add_child(UiFactory.make_label(TranslationServer.translate("HR_TASK_NONE"), &"RowMeta", UiTokens.INK_DIM))
	return box


## Tek ikon, konturlu kutuda. Motor tek trait taşıyor (HRConstants.TRAIT_COUNT); eski bir
## kayıt iki taşıyorsa ilkini gösteririz.
static func trait_cell(trait_ids: Array, width: int) -> Control:
	var box := CenterContainer.new()
	box.custom_minimum_size = Vector2(width, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pick: String = String(trait_ids[0]) if not trait_ids.is_empty() else ""
	if pick == "":
		box.add_child(UiFactory.make_label("—", &"RowMeta", UiTokens.INK_FAINT))
		return box
	var frame := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.BORDER_HOVER
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.set_content_margin_all(4.0)
	frame.add_theme_stylebox_override("panel", sb)
	frame.custom_minimum_size = Vector2(TRAIT_BOX_PX, TRAIT_BOX_PX)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.add_child(trait_icon(pick, 15))
	box.add_child(_hoverable(frame, pick))
	return box


# --- Moral ------------------------------------------------------------------

## Renk §7'nin bandlarını çizer (35 altı Ayrılabilir, 50 altı DÜŞÜK). Paletin üç sağlık
## rengi var, o yüzden 50 üstü nötr ve 80 üstü İYİ aynı yeşili alır.
static func morale_color(morale: int) -> Color:
	if HRConstants.is_flight_risk(morale):
		return UiTokens.negative()
	if morale < HRConstants.MORALE_BAND_LOW:
		return UiTokens.HEALTH_AMBER
	return UiTokens.health_green()


## Bar · sayı. Başlık sütunun kendisinde ("MORAL"). `out_refs`'e "bar" ve "value" düğümlerini
## koyar; çağıran yerinde-repaint için saklar. Bar sabit genişlikte ve sayısıyla defterin MORAL
## sütununa sığar: asgari boyut sütunun custom_minimum'unu yener.
static func morale_row(morale: int, out_refs: Dictionary) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_SHRINK_END
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(MORALE_BAR_WIDTH, MORALE_BAR_HEIGHT)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.min_value = float(HRConstants.MORALE_MIN)
	bar.max_value = float(HRConstants.MORALE_MAX)
	row.add_child(bar)
	var value := UiFactory.make_label("", &"RowName")
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(value)
	out_refs["bar"] = bar
	out_refs["value"] = value
	repaint_morale(out_refs, morale)
	return row


## BuildProgress'in amber dolgusu → verilen renk. Varyasyon atandıktan SONRA çağrılmalı.
static func override_bar_fill(bar: ProgressBar, c: Color) -> void:
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = (fill as StyleBoxFlat).duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


static func repaint_morale(refs: Dictionary, morale: int) -> void:
	var bar: ProgressBar = refs.get("bar", null) as ProgressBar
	var value: Label = refs.get("value", null) as Label
	var color: Color = morale_color(morale)
	if bar != null and is_instance_valid(bar):
		bar.value = float(morale)
		override_bar_fill(bar, color)
	if value != null and is_instance_valid(value):
		value.text = str(morale)
		value.add_theme_color_override("font_color", color)


# --- Rozetler ---------------------------------------------------------------

## Kart sıralaması için: badges_for en kötüsünü başta döndürüyor, ağırlık registry'de.
static func worst_badge_severity(emp: Character) -> int:
	var badges: Array[String] = HRSystem.badges_for(emp)
	if badges.is_empty():
		return 0
	return HRConstants.badge_severity(badges[0])


# --- Huy çipleri ------------------------------------------------------------

## Tek muamele, valans yok (R4): sekizi de nötr; ayrım adda, ikonda ve etkide.
static func trait_chip(trait_id: String, with_tooltip: bool = false) -> Control:
	var p: Dictionary = UiTokens.badge_palette(&"neutral")
	var chip := PanelContainer.new()
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = p.bg
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = UiTokens.PAD_CHIP.x
	sb.content_margin_right = UiTokens.PAD_CHIP.x
	sb.content_margin_top = UiTokens.PAD_CHIP.y
	sb.content_margin_bottom = UiTokens.PAD_CHIP.y
	chip.add_theme_stylebox_override("panel", sb)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var icon: Control = trait_icon(trait_id, 14)
	icon.modulate = p.fg
	row.add_child(icon)
	var lbl := UiFactory.make_label(UiTokens.tr_upper(HRConstants.trait_label(trait_id)),
		&"BadgeLabel", p.fg)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)
	chip.add_child(row)
	if with_tooltip:
		return _hoverable(chip, trait_id)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return chip


static func trait_row(trait_ids: Array, with_tooltip: bool = false) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	for trait_id in trait_ids:
		row.add_child(trait_chip(String(trait_id), with_tooltip))
	return row


# --- Sayfa kromu ------------------------------------------------------------

## Küçük mono büyük-harf başlık, sağa uzayan saç teli çizgiyle (§13.2).
static func section_header(text: String, with_rule: bool = true, variation: StringName = &"SectionLabel") -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label := UiFactory.make_section_header(text)
	label.theme_type_variation = variation
	row.add_child(label)
	if with_rule:
		var rule := hairline()
		rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(rule)
	return row


## Renk parametre: başlık altında kart kenarı, satır altında kart içi saç teli.
static func hairline(color: Color = UiTokens.DIVIDER_LIGHT) -> Panel:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	line.add_theme_stylebox_override("panel", sb)
	return line


## Saatin moral YÖNÜ. Kademe ÇAĞIRANDA: kaç tane çizildiği kademedir (§8.5 katsayı yazdırmaz).
static func chevron(px: int = 9, color: Color = UiTokens.ACCENT, up: bool = false) -> TextureRect:
	return UiFactory.make_glyph("res://assets/icons/chevron_up.svg" if up
		else "res://assets/icons/chevron_down.svg", px, color)


## 7 saat: erime durdu ama yükselmiyor, düz çizgi.
static func chevron_flat(px: int = 9, color: Color = UiTokens.POSITIVE) -> TextureRect:
	return UiFactory.make_glyph("res://assets/icons/chevron_flat.svg", px, color)


static func revert_arrow_icon() -> Texture2D:
	return load("res://assets/icons/revert_arrow.svg")


## Uyarı "bak" der, kilit "yapamazsın": iki ayrı glif.
static func warning_glyph(px: int = 12, color: Color = UiTokens.NEGATIVE) -> TextureRect:
	return UiFactory.make_glyph("res://assets/icons/warning.svg", px, color)


static func lock_glyph(px: int, color: Color) -> TextureRect:
	return UiFactory.make_glyph("res://assets/icons/lock.svg", px, color)


static func action_button(label: String, on_press: Callable, primary: bool = false) -> Button:
	var btn := Button.new()
	btn.text = label
	if primary:
		btn.theme_type_variation = &"CommitButton"
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


## Kapalı buton + GEREKÇE. Gerekçe motorun preview_*'ından gelir: can_* yalnız bool döner.
static func disabled_button(label: String, reason: String) -> Button:
	var btn := action_button(label, Callable())
	btn.disabled = true
	btn.tooltip_text = reason
	return btn


## Personel modalları PanelLayer'a monte olur, ModalLayer'a değil: ModalLayer boşluk ve 1-4 hız
## tuşlarını yutuyor ve dimmer'ı TopBar'ı kaplıyor; saat bir kadro kararının üstünde akarken
## oyuncunun onu durduracak yolu kalmazdı. Gerçek bir modal (layer 10) hâlâ üstünü örter.
static func mount_panel_modal(host: Node, path: String, on_changed: Callable, args: Array = []) -> void:
	var layer: Node = host.get_tree().get_root().find_child("PanelLayer", true, false)
	if layer == null:
		push_error("[HRUiShared] GameShell/PanelLayer yok — modal monte edilemiyor: %s" % path)
		return
	var modal: Node = (load(path) as PackedScene).instantiate()
	layer.add_child(modal)   # önce add_child, sonra populate (ev konvansiyonu)
	modal.connect("state_changed", on_changed)
	modal.callv("populate", args)


## Kart içi çocuklar tıklamayı yutmasın; gui_input kart kökünde.
static func set_mouse_ignore(n: Node) -> void:
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		set_mouse_ignore(c)


# --- Koyu kit (Menajer Masası) ----------------------------------------------
# Ekip koyu dile taşınınca kadro tablosu, şeritleri ve hücreleri buradan çizer; krem çizenler
# yukarıda kalır. Renk D_ token'ı ya da D_ yardımcısıdır, kutu menajer_theme varyasyonudur.

const D_TRAIT_DIR := "res://assets/icons/trait/"
const D_SKILL_LOOKS := {&"": &"SkillValue", &"main": &"SkillMain", &"secondary": &"SkillSecondary"}


## Sütun başlığı: büyük harfli anahtar, başlığın tabanına yaslı.
static func D_head(text: String, width: int, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var head := UiFactory.make_label(Fmt.upper(text), &"KeyLabel")
	head.horizontal_alignment = align
	head.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	head.custom_minimum_size.x = width
	return head


## Grup başlığı: açma oku, grubun glifi, büyük harfli adı, sağa uzanan çizgi. Kapalı grup soluk okunur
## ve içindeki kişi sayısını gösterir; tıklama `on_toggle`'ı çağırır.
static func D_group(text: String, glyph_path: String, count: int, collapsed: bool,
		on_toggle: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_GROUP
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_glyph("res://assets/icons/util/chevron_%s.svg" % ("right" if collapsed else "down"),
		UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(UiFactory.make_glyph(glyph_path, UiTokens.D_ICON_GROUP, UiTokens.D_INK_3))
	row.add_child(UiFactory.make_label(Fmt.upper(text), &"GroupLabel", UiTokens.D_INK_3 if collapsed else null))
	if collapsed:
		row.add_child(UiFactory.make_label(str(count), &"Caption"))
	var rule := HSeparator.new()
	rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(rule)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	set_mouse_ignore(row)
	row.mouse_filter = Control.MOUSE_FILTER_STOP
	row.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	row.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			on_toggle.call())
	return row


## Veri satırı; hücrelerini çağıran ekler. Üstüne gelince kenarı açılır, seçili satır yükselir ve sol
## kenarında işaret taşır.
static func D_row(selected: bool) -> PanelContainer:
	var row := PanelContainer.new()
	var looks: Array = [&"TableRowSelected", &"TableRowSelectedHover"] if selected else [&"TableRow", &"TableRowHover"]
	row.theme_type_variation = looks[0]
	row.custom_minimum_size.y = UiTokens.D_H_ROW
	row.mouse_entered.connect(func() -> void: row.theme_type_variation = looks[1])
	row.mouse_exited.connect(func() -> void: row.theme_type_variation = looks[0])
	if selected:
		var layer := Control.new()
		var mark := Panel.new()
		mark.theme_type_variation = &"RailMark"
		mark.anchor_bottom = 1.0
		mark.offset_top = UiTokens.D_MARK.y
		mark.offset_right = UiTokens.D_MARK.x
		mark.offset_bottom = -UiTokens.D_MARK.y
		layer.add_child(mark)
		set_mouse_ignore(layer)
		row.add_child(layer)
	return row


## Beceri hücresi: değer rampanın renginde. `rank` "main" kalın ve altı çizili, "secondary" yarı kalın;
## `band` rolün sütununu grubun boyunca aydınlatır.
static func D_skill_cell(value: int, rank: StringName, width: int, band: bool) -> Control:
	var cell := Control.new()
	cell.custom_minimum_size.x = width
	if band:
		var ground := Panel.new()
		ground.theme_type_variation = &"RoleBand"
		ground.set_anchors_preset(Control.PRESET_FULL_RECT)
		cell.add_child(ground)
	var ink: Color = UiTokens.D_skill(value)
	var figure := UiFactory.make_label(str(value), D_SKILL_LOOKS[rank], ink)
	figure.set_anchors_preset(Control.PRESET_FULL_RECT)
	figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	figure.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(figure)
	if rank == &"main":
		var mark := ColorRect.new()
		mark.color = ink
		mark.anchor_left = 0.5
		mark.anchor_right = 0.5
		mark.anchor_top = 1.0
		mark.anchor_bottom = 1.0
		mark.offset_left = -UiTokens.D_SKILL_MARK.x / 2.0
		mark.offset_right = UiTokens.D_SKILL_MARK.x / 2.0
		mark.offset_top = -UiTokens.SPACE_S - UiTokens.D_SKILL_MARK.y
		mark.offset_bottom = -UiTokens.SPACE_S
		cell.add_child(mark)
	set_mouse_ignore(cell)
	return cell


## Başlığın beceri lejantı: rampanın beş basamağı kendi renginde, ana alanın altı çizili, ikincilin
## yalın örneği.
static func D_skill_legend() -> PanelContainer:
	var cell := PanelContainer.new()
	cell.theme_type_variation = &"KpiCell"
	var col := VBoxContainer.new()
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	cell.add_child(col)
	col.add_child(UiFactory.make_label(Fmt.upper(TranslationServer.translate("HR_COL_ROLES")), &"KeyLabel"))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(row)
	for low in [1, 3, 5, 7, 9]:
		row.add_child(UiFactory.make_label("%d-%d" % [low, low + 1], &"ValueTextStrong", UiTokens.D_skill(low)))
	for sample in [["7", "HR_SKILL_LEGEND_MAIN"], ["6", "HR_SKILL_LEGEND_SECONDARY"]]:
		var key := HBoxContainer.new()
		key.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		key.size_flags_vertical = Control.SIZE_SHRINK_END
		var figure := UiFactory.make_label(sample[0], &"CaptionStrong")
		key.add_child(figure)
		key.add_child(UiFactory.make_label(TranslationServer.translate(sample[1]), &"Caption"))
		row.add_child(key)
		if sample[1] == "HR_SKILL_LEGEND_MAIN":
			var mark := ColorRect.new()
			mark.color = UiTokens.D_INK_2
			mark.anchor_right = 1.0
			mark.anchor_top = 1.0
			mark.anchor_bottom = 1.0
			mark.offset_top = UiTokens.BORDER_HAIRLINE
			mark.offset_bottom = UiTokens.BORDER_HAIRLINE + UiTokens.D_SKILL_MARK.y
			figure.add_child(mark)
	return cell


## Moral hücresi: değer bandının renginde, sağa yaslı; yanında bar ve 35'teki kaçma çentiği. `refs`
## değeri ve dolguyu tutar, D_repaint_morale yerinde boyar.
static func D_morale(morale: int, refs: Dictionary) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var value := UiFactory.make_label("", &"MoraleValue")
	value.custom_minimum_size.x = UiTokens.D_W_MORALE
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(value)
	var track := Panel.new()
	track.theme_type_variation = &"BarTrack"
	track.custom_minimum_size = UiTokens.D_MORALE_BAR
	track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(track)
	var fill := Panel.new()
	fill.theme_type_variation = &"BarTint"
	track.add_child(fill)
	var notch := ColorRect.new()
	notch.color = UiTokens.D_INK_4
	notch.size = UiTokens.D_NOTCH
	var risk_at: float = UiTokens.D_MORALE_BAR.x * HRConstants.MORALE_FLIGHT_RISK / float(HRConstants.MORALE_MAX)
	notch.position = Vector2(roundf(risk_at), (UiTokens.D_MORALE_BAR.y - UiTokens.D_NOTCH.y) / 2.0)
	track.add_child(notch)
	set_mouse_ignore(row)
	refs["value"] = value
	refs["fill"] = fill
	D_repaint_morale(refs, morale)
	return row


static func D_repaint_morale(refs: Dictionary, morale: int) -> void:
	var ink: Color = D_morale_ink(morale)
	var value: Label = refs["value"]
	value.text = str(morale)
	value.add_theme_color_override("font_color", ink)
	var fill: Panel = refs["fill"]
	fill.self_modulate = ink
	fill.size = Vector2(UiTokens.D_MORALE_BAR.x * morale / float(HRConstants.MORALE_MAX), UiTokens.D_MORALE_BAR.y)


## §7'nin bantları: 35 altı Ayrılabilir tehlikedir, 50 altı uyarı, üstü olumlu.
static func D_morale_ink(morale: int) -> Color:
	if HRConstants.is_flight_risk(morale):
		return UiTokens.D_neg()
	if morale < HRConstants.MORALE_BAND_LOW:
		return UiTokens.D_warn()
	return UiTokens.D_pos()


## Huy hücresi: kutusunda glifi ve yanında adı; üstüne gelince adı ve etkisi. Huyu olmayanın hücresi
## boştur.
static func D_trait_cell(trait_ids: Array) -> HBoxContainer:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", UiTokens.SPACE_S)
	if trait_ids.is_empty():
		return cell
	var pick: String = String(trait_ids[0])
	var box := PanelContainer.new()
	box.theme_type_variation = &"TraitBox"
	box.add_child(UiFactory.make_glyph(D_TRAIT_DIR + (pick if TRAIT_ICON_DRAWN.has(pick) else "unspecified") + ".svg",
		UiTokens.D_ICON_ROW, UiTokens.D_INK_2))
	cell.add_child(box)
	cell.add_child(UiFactory.make_label(HRConstants.trait_label(pick), &"CondCaption"))
	for part: Control in cell.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	set_mouse_ignore(cell)
	return _hoverable(cell, pick)


## Kaçma riski şeridi: tehlike glifi, kişinin yüzü ve adı, morali ve etiketi; tıklanınca `on_open`.
static func D_risk_strip(emp: Character, on_open: Callable) -> PanelContainer:
	var strip := PanelContainer.new()
	var looks: Array = [UiTokens.D_variation(&"RiskStrip"), UiTokens.D_variation(&"RiskStripHover")]
	strip.theme_type_variation = looks[0]
	strip.custom_minimum_size.y = UiTokens.D_H_STRIP
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	strip.add_child(row)
	row.add_child(UiFactory.make_glyph("res://assets/icons/util/warn.svg", UiTokens.D_ICON_STRIP, UiTokens.D_neg()))
	row.add_child(UiFactory.make_person_avatar(emp.character_name, emp.look, UiTokens.D_AVATAR_ROW))
	row.add_child(UiFactory.make_label(emp.character_name, &"RiskName"))
	row.add_child(UiFactory.make_label(Fmt.upper(TranslationServer.translate("HR_COL_MORALE")),
		UiTokens.D_variation(&"RiskKey")))
	row.add_child(UiFactory.make_label(str(emp.morale), UiTokens.D_variation(&"RiskValue")))
	row.add_child(UiFactory.D_tag(HRConstants.badge_label(HRConstants.BADGE_FLIGHT_RISK), &"risk"))
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(gap)
	row.add_child(UiFactory.make_glyph("res://assets/icons/util/chevron_right.svg", UiTokens.D_ICON_STRIP,
		UiTokens.D_neg_ink()))
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	set_mouse_ignore(row)
	strip.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	strip.mouse_entered.connect(func() -> void: strip.theme_type_variation = looks[1])
	strip.mouse_exited.connect(func() -> void: strip.theme_type_variation = looks[0])
	strip.gui_input.connect(func(event: InputEvent) -> void:
		if UiFactory.is_left_click(event):
			on_open.call())
	return strip


## Boş grup satırı: notu ve yanında grubu dolduracak eylemin küçük düğmesi.
static func D_empty_row(note: String, action: String, on_action: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_EMPTY_ROW
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	row.add_child(UiFactory.make_label(note, &"NoteMuted"))
	var go := Button.new()
	go.theme_type_variation = &"SecondaryButtonSmall"
	go.icon = load("res://assets/icons/util/plus.svg")
	go.text = action
	go.focus_mode = Control.FOCUS_NONE
	go.pressed.connect(on_action)
	row.add_child(go)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row
