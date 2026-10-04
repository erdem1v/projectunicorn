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

const TRAIT_ICON_DRAWN := ["loyal", "picks_it_up_fast", "takes_them_under",
	"double_checker", "last_one_out", "cant_say_no", "bag_packed", "mood_buster"]


## Çalışanın ana ve ikincil alanı.
static func role_areas(role_id: String) -> Array:
	return [HRConstants.role_key_area(role_id), HRConstants.role_secondary_area(role_id)].filter(
		func(key: String) -> bool: return key != "")


## Beceri başlığı. Karizma bir ALAN değil, kendi anahtarından okunur;
## FounderConstants.skill_label oran parçası verir ("+%15 satış"), etiket değil.
static func skill_label(key: String) -> String:
	if key == FounderConstants.SKILL_CHARISMA:
		return TranslationServer.translate("PER_CHARISMA")
	return HRConstants.area_label(key)


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


## Tooltip: ad ve etki alt alta. PASS, STOP DEĞİL: STOP tooltip'i çalıştırır ama satır
## tıklamasını yutar, ve menüyü açan tek yol o tıklama.
static func _hoverable(node: Control, trait_id: String) -> Control:
	node.tooltip_text = "%s\n%s" % [
		HRConstants.trait_label(trait_id), HRConstants.trait_effect_text(trait_id)]
	node.mouse_filter = Control.MOUSE_FILTER_PASS
	return node


## BuildProgress'in amber dolgusu → verilen renk. Varyasyon atandıktan SONRA çağrılmalı.
static func override_bar_fill(bar: ProgressBar, c: Color) -> void:
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = (fill as StyleBoxFlat).duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


## Kart sıralaması için: badges_for en kötüsünü başta döndürüyor, ağırlık registry'de.
static func worst_badge_severity(emp: Character) -> int:
	var badges: Array[String] = HRSystem.badges_for(emp)
	if badges.is_empty():
		return 0
	return HRConstants.badge_severity(badges[0])


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
# Ekip'in tablosu, şeritleri, hücreleri ve panelleri buradan çizer; krem çizenler yukarıda kalır.
# Renk D_ token'ı ya da D_ yardımcısıdır, kutu menajer_theme varyasyonudur.

const D_TRAIT_DIR := "res://assets/icons/trait/"
const D_SKILL_LOOKS := {&"": &"SkillValue", &"main": &"SkillMain", &"secondary": &"SkillSecondary"}


## Sütun başlığı: büyük harfli anahtar, hücresinin tabanında (bir Label kendiliğinden ortaya oturur;
## hücreyi dolduran başlık da metnini tabana indirir).
static func D_head(text: String, width: int, align := HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var head := UiFactory.make_label(Fmt.upper(text), &"KeyLabel")
	head.horizontal_alignment = align
	head.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	head.size_flags_vertical = Control.SIZE_SHRINK_END
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
## kenarında işaret taşır; seçim yerinde değişir (D_select_row).
static func D_row(selected: bool) -> PanelContainer:
	var row := PanelContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_ROW
	var layer := Control.new()
	layer.add_child(D_mark())
	set_mouse_ignore(layer)
	row.add_child(layer)
	row.mouse_entered.connect(_paint_row.bind(row, true))
	row.mouse_exited.connect(_paint_row.bind(row, false))
	D_select_row(row, selected)
	return row


## The selected marker on the left edge of a row or a picked card, inset from its top and bottom.
static func D_mark() -> Panel:
	var mark := Panel.new()
	mark.theme_type_variation = &"RailMark"
	mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	mark.anchor_bottom = 1.0
	mark.offset_top = UiTokens.D_MARK.y
	mark.offset_right = UiTokens.D_MARK.x
	mark.offset_bottom = -UiTokens.D_MARK.y
	return mark


static func D_select_row(row: PanelContainer, selected: bool) -> void:
	row.set_meta(&"selected", selected)
	row.get_child(0).visible = selected
	_paint_row(row, false)


static func _paint_row(row: PanelContainer, hover: bool) -> void:
	row.theme_type_variation = StringName("TableRow" + ("Selected" if row.get_meta(&"selected") else "")
		+ ("Hover" if hover else ""))


## A main area's rank in a role: "main", "secondary" or none.
static func D_rank(role_id: String, key: String) -> StringName:
	if key == HRConstants.role_key_area(role_id):
		return &"main"
	if key == HRConstants.role_secondary_area(role_id):
		return &"secondary"
	return &""


## Beceri değeri rampanın renginde: "main" kalın ve hemen altı çizili, "secondary" yarı kalın.
static func D_skill_figure(value: int, rank: StringName) -> Label:
	var ink: Color = UiTokens.D_skill(value)
	var figure := UiFactory.make_label(str(value), D_SKILL_LOOKS[rank], ink)
	figure.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	figure.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	figure.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if rank == &"main":
		var mark := ColorRect.new()
		mark.color = ink
		mark.anchor_left = 0.5
		mark.anchor_right = 0.5
		mark.anchor_top = 1.0
		mark.anchor_bottom = 1.0
		mark.offset_left = -UiTokens.D_SKILL_MARK.x / 2.0
		mark.offset_right = UiTokens.D_SKILL_MARK.x / 2.0
		mark.offset_top = UiTokens.BORDER_HAIRLINE
		mark.offset_bottom = UiTokens.BORDER_HAIRLINE + UiTokens.D_SKILL_MARK.y
		figure.add_child(mark)
	return figure


## Beceri hücresi: değer ortada; `band` rolün sütununu grubun boyunca aydınlatır.
static func D_skill_cell(value: int, rank: StringName, width: int, band: bool) -> Control:
	var cell := Control.new()
	cell.custom_minimum_size.x = width
	if band:
		var ground := Panel.new()
		ground.theme_type_variation = &"RoleBand"
		ground.set_anchors_preset(Control.PRESET_FULL_RECT)
		cell.add_child(ground)
	var centre := CenterContainer.new()
	centre.set_anchors_preset(Control.PRESET_FULL_RECT)
	centre.add_child(D_skill_figure(value, rank))
	cell.add_child(centre)
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
	var track := D_bar(UiTokens.D_MORALE_BAR, morale / float(HRConstants.MORALE_MAX), D_morale_ink(morale))
	row.add_child(track)
	var notch := ColorRect.new()
	notch.color = UiTokens.D_INK_4
	notch.size = UiTokens.D_NOTCH
	var risk_at: float = UiTokens.D_MORALE_BAR.x * HRConstants.MORALE_FLIGHT_RISK / float(HRConstants.MORALE_MAX)
	notch.position = Vector2(roundf(risk_at), (UiTokens.D_MORALE_BAR.y - UiTokens.D_NOTCH.y) / 2.0)
	track.add_child(notch)
	set_mouse_ignore(row)
	refs["value"] = value
	refs["fill"] = track.get_child(0)
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


## A meter: its track at `size` and, as the track's first child, its fill to `ratio` in `ink`.
static func D_bar(size: Vector2, ratio: float, ink: Color) -> Panel:
	var track := Panel.new()
	track.theme_type_variation = &"BarTrack"
	track.custom_minimum_size = size
	track.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var fill := Panel.new()
	fill.theme_type_variation = &"BarTint"
	fill.self_modulate = ink
	fill.size = Vector2(size.x * clampf(ratio, 0.0, 1.0), size.y)
	track.add_child(fill)
	return track


## §7'nin bantları: 35 altı Ayrılabilir tehlikedir, 50 altı uyarı, üstü olumlu.
static func D_morale_ink(morale: int) -> Color:
	if HRConstants.is_flight_risk(morale):
		return UiTokens.D_neg()
	if morale < HRConstants.MORALE_BAND_LOW:
		return UiTokens.D_warn()
	return UiTokens.D_pos()


## Deneyim: kısa bar ve yüzdesi; bar dolunca vurgulanır.
static func D_xp(c: Character) -> HBoxContainer:
	var ratio: float = CharacterRegistry.experience_ratio(c)
	var full: bool = ratio >= 1.0
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(D_bar(UiTokens.D_XP_BAR, ratio, UiTokens.D_BAR_EMPH if full else UiTokens.D_BAR_FILL))
	var share := UiFactory.make_label(Fmt.percent(int(round(ratio * 100.0)), 0), &"MetaMuted",
		UiTokens.D_INK_2 if full else null)
	share.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(share)
	set_mouse_ignore(row)
	return row


## Huy hücresi: kutusunda glifi ve yanında adı; üstüne gelince adı ve etkisi. Huyu olmayanın hücresi
## boştur. `strong`: ad, altında etkisi yazan yerde (dosya, aday dosyası) başlık gibi okunur.
static func D_trait_cell(trait_ids: Array, strong := false) -> HBoxContainer:
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
	var label := UiFactory.make_label(HRConstants.trait_label(pick), &"DataStrong" if strong else &"CondCaption",
		UiTokens.D_INK_2 if strong else null)
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.add_child(label)
	for part: Control in cell.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	set_mouse_ignore(cell)
	return _hoverable(cell, pick)


## Durum hücresi, `width` genişliğinde. Etiketlerin ağırlık sırası: kaçma riski, aşırı yük, izin ya da
## eğitim (kalan haftasıyla), yeni, boşta. Kadro'nun sütunu birini taşır (en ağırı), Görevler hepsini
## (`all`); en sonda mesai istisnası, Mesai panelinin tonunda. Sütuna bütün sığmayan parça yarım
## kesilmez, hiç çizilmez; o zaman hücrenin tamamı üstüne gelince okunur.
static func D_state_cell(emp: Character, all: bool, width: int) -> Control:
	var tags: Array = []
	for badge in HRSystem.badges_for(emp):
		if badge == HRConstants.BADGE_FLIGHT_RISK:
			tags.append([HRConstants.badge_label(badge), &"risk", 0])
		else:
			tags.append([TranslationServer.translate("HR_BADGE_OVERLOADED_JOBS"), &"warn", 0])
	if emp.status == HRConstants.STATUS_ON_LEAVE:
		tags.append([TranslationServer.translate("HR_STATE_ON_LEAVE"), &"neutral", HRMoraleSystem.weeks_until_return(emp)])
	elif emp.training_weeks_left > 0:
		tags.append([TranslationServer.translate("HR_STATE_IN_TRAINING"), &"neutral", emp.training_weeks_left])
	if HRConstants.is_new_hire(emp.hire_day, GameState.day):
		tags.append([TranslationServer.translate("HR_BADGE_NEW"), &"", 0])
	if emp.status == HRConstants.STATUS_ACTIVE and HRSystem.is_idle(emp):
		tags.append([TranslationServer.translate("HR_BADGE_IDLE"), &"outline", 0])
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", UiTokens.SPACE_S)
	var said := PackedStringArray()
	var hint: Label = null
	for tag: Array in (tags if all else tags.slice(0, 1)):
		var label := UiFactory.D_tag(tag[0], tag[1])
		if tag[1] == &"warn":
			hint = label
		cell.add_child(label)
		said.append(tag[0])
		if tag[2] > 0:
			said.append(TranslationServer.translate(Fmt.count_key("HR_DURATION_WEEKS", tag[2])).format({"n": tag[2]}))
			cell.add_child(_caption(said[-1]))
	var delta: int = WorkHoursSystem.hours_for(emp) - HRConstants.WORK_HOURS_DEFAULT
	if delta != 0:
		said.append(TranslationServer.translate("HR_STATE_HOURS_OVER" if delta > 0 else "HR_STATE_HOURS_SHORT").format(
			{"n": absi(delta)}))
		var note := _caption(said[-1])
		note.add_theme_color_override("font_color", UiTokens.D_warn() if delta > 0 else UiTokens.D_pos())
		cell.add_child(note)
	if cell.get_child_count() == 0:
		cell.add_child(_caption(TranslationServer.translate("HR_TASK_NONE")))
	set_mouse_ignore(cell)
	# The overload tag explains itself on hover; PASS keeps the row's click.
	if hint != null:
		hint.tooltip_text = TranslationServer.translate("HR_OVERLOAD_HINT")
		hint.mouse_filter = Control.MOUSE_FILTER_PASS
	# A plain Control holds the column's width: a box would grow with its tags.
	var clip := Control.new()
	clip.custom_minimum_size = Vector2(width, UiTokens.D_H_TAG)
	clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clip.add_child(cell)
	cell.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	# A part's width is known only once the box has laid it out.
	cell.sort_children.connect(func() -> void:
		var cut := false
		for part: Control in cell.get_children():
			cut = cut or part.position.x + part.size.x > width
			part.visible = not cut
		clip.tooltip_text = " · ".join(said) if cut else ""
		clip.mouse_filter = Control.MOUSE_FILTER_PASS if cut else Control.MOUSE_FILTER_IGNORE)
	return clip


static func _caption(text: String) -> Label:
	var label := UiFactory.make_label(text, &"CondCaption")
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return label


## Kim: yüzü, adı ve unvanı (kurucuda "Kurucu"); satır menüsünün, diyalogların ve eğitim panelinin başı.
static func D_who(c: Character, px: int, gap := UiTokens.SPACE_L) -> HBoxContainer:
	var who := HBoxContainer.new()
	who.add_theme_constant_override("separation", gap)
	who.add_child(UiFactory.make_person_avatar(c.character_name, c.look, px))
	var names := VBoxContainer.new()
	names.add_theme_constant_override("separation", 0)
	names.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	names.add_child(UiFactory.make_label(c.character_name, &"DataStrong"))
	names.add_child(UiFactory.make_label(roster_title(c), &"CondCaption"))
	who.add_child(names)
	return who


## Yüzü olmayan gönderen: harfi kutusunda (ajans).
static func D_mono(letter: String, px: int) -> PanelContainer:
	var box := PanelContainer.new()
	box.theme_type_variation = &"MonoBox"
	box.custom_minimum_size = Vector2(px, px)
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var label := UiFactory.make_label(letter, &"FloatTitle", UiTokens.D_INK_2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	box.add_child(label)
	return box


## Kesikli çerçeve (StyleBoxFlat kesik çizemez): kimsenin alamadığı iş kutusu, değerini devralan saat, açık söz.
static func D_dashed(box: Control, color := UiTokens.D_LINE_2) -> void:
	box.draw.connect(func() -> void:
		var dash: float = UiTokens.SPACE_XS
		var gap: float = UiTokens.SPACE_XXS
		var r := Rect2(Vector2.ONE * 0.5, box.size - Vector2.ONE)
		for edge in [[r.position, Vector2(r.end.x, r.position.y)], [Vector2(r.position.x, r.end.y), r.end],
				[r.position, Vector2(r.position.x, r.end.y)], [Vector2(r.end.x, r.position.y), r.end]]:
			var from: Vector2 = edge[0]
			var to: Vector2 = edge[1]
			var length: float = from.distance_to(to)
			var step: Vector2 = (to - from) / maxf(length, 1.0)
			var at := 0.0
			while at < length:
				box.draw_line(from + step * at, from + step * minf(at + dash, length), color, 1.0)
				at += dash + gap)


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


## Boş grup satırı: notu ve yanında grubu dolduracak eylemin küçük düğmesi, karar beklerken (`off`) kapalı.
static func D_empty_row(note: String, action: String, on_action: Callable, off: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_EMPTY_ROW
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	row.add_child(UiFactory.make_label(note, &"NoteMuted"))
	var go := Button.new()
	go.theme_type_variation = &"SecondaryButtonSmall"
	go.icon = load("res://assets/icons/util/plus.svg")
	go.text = action
	go.focus_mode = Control.FOCUS_NONE
	go.disabled = off
	go.pressed.connect(on_action)
	row.add_child(go)
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row
