class_name HRUiShared
extends RefCounted

# ============================================================================
# HR sekmesinin paylaşılan çizim parçaları (ProductUiShared deseni: class_name +
# yalnız static, hiç durum tutmaz).
#
# THE RULE FOR THIS WHOLE FOLDER: burada HİÇBİR SAYI TÜRETİLMEZ. Her değer bir
# motor çağrısından gelir; bu dosya onları düğüme çevirir, o kadar. Bir sayıya
# ihtiyaç var ve motor vermiyorsa doğru cevap burada hesaplamak değil, motora
# okuma seam'i eklemektir (task 3 planındaki "additive read seams" listesi).
#
# Para: HRConstants.money_tr — UiTokens.format_money DEĞİL. HR önizlemelerinin
# hazır `lines` dizileri money_tr ile basılıyor; kartın kendi bastığı rakam
# başka formatta olursa kart kendi metniyle çelişir (kod tabanında üç ayrı para
# biçimleyici var, bu modülün evi money_tr).
# ============================================================================

const LOCK_ICON := "res://assets/icons/lock.svg"

# Eksen çipi ölçüleri — mockup Kare 1'in çerçeveli küçük kutuları.
const CHIP_RADIUS := 3
const CHIP_PAD_X := 7
const CHIP_PAD_Y := 3
const MORALE_BAR_HEIGHT := 6
const MORALE_BAR_WIDTH := 150


static func money(amount: int) -> String:
	return HRConstants.money_tr(amount)


# --- Eksen çipleri ----------------------------------------------------------

static func axis_chips(role_stats: Dictionary, muted: bool = false) -> HBoxContainer:
	# UZMANLIK / HIZ / UYUM, kanon sırada (HRConstants.AXES). Etiketler registry'de
	# Title Case duruyor, ekranda büyük harf isteniyor → tr_upper (ham to_upper
	# noktalı İ'yi bozar).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	for axis_key in HRConstants.AXES:
		var label: String = UiTokens.tr_upper(HRConstants.axis_label(String(axis_key)))
		var value: int = int(role_stats.get(String(axis_key), 0))
		row.add_child(_bordered_chip("%s %d" % [label, value], muted))
	return row


static func _bordered_chip(text: String, muted: bool = false) -> PanelContainer:
	# Çerçeveli, dolgusuz çip. UiFactory'nin çipleri dolu zeminli; bu sayfanın imza
	# öğesi çerçeveli kutu, o yüzden stylebox kodda kuruluyor (UiFactory.make_dot ve
	# build_hud_panel._build_styles ile aynı sanksiyonlu desen — tema üretilmiş bir
	# artefakt olduğu için tek seferlik bir şekil için yeni varyasyon eklenmiyor).
	var chip := PanelContainer.new()
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0, 0, 0, 0)
	sb.border_color = UiTokens.CARD_BORDER
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(CHIP_RADIUS)
	sb.content_margin_left = CHIP_PAD_X
	sb.content_margin_right = CHIP_PAD_X
	sb.content_margin_top = CHIP_PAD_Y
	sb.content_margin_bottom = CHIP_PAD_Y
	chip.add_theme_stylebox_override("panel", sb)
	var lbl := UiFactory.make_label(text, &"BadgeLabel", UiTokens.INK_DIM if muted else UiTokens.INK_MUTED)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chip.add_child(lbl)
	return chip


# --- Moral ------------------------------------------------------------------

static func morale_color(morale: int) -> Color:
	# ÜÇ durum, ve üçü de MOTORUN kendi eşiklerinden geliyor — HRConstants'ın iki
	# karşılaştırma fonksiyonu (is_flight_risk / is_burning_out). Mockup ortada
	# dördüncü bir bant ima ediyor ama motorda öyle bir eşik yok; uydurulmuş bir
	# sayı yerine motorun bildiği ayrımlar çiziliyor (38 bu yüzden kırmızı değil
	# amber okur — done mesajında sapma olarak raporlanıyor).
	if HRConstants.is_flight_risk(morale):
		return UiTokens.negative()
	if HRConstants.is_burning_out(morale):
		return UiTokens.HEALTH_AMBER
	return UiTokens.health_green()


static func morale_row(morale: int, out_refs: Dictionary = {}, with_caption: bool = true) -> Control:
	# MORAL etiketi · bar · sayı. out_refs verilirse "bar" ve "value" anahtarlarına
	# düğümleri koyar; çağıran yerinde-repaint için saklar (kart yeniden kurulmaz).
	# Bar SABİT genişlikte ve satır sağa yapışık: EXPAND_FILL verilince bar kart
	# boyunca uzuyordu, mockup'ta ise kartın sağ üçte birinde duran kompakt bir
	# göstergedir.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	row.size_flags_horizontal = Control.SIZE_SHRINK_END
	# Defterde başlık SÜTUNUN kendisinde ("MORAL"), o yüzden hücre içi etiket
	# kapatılabilir — aynı kelimeyi iki kez basmak reçetenin yasakladığı şey.
	if with_caption:
		row.add_child(UiFactory.make_label(UiTokens.tr_upper("Moral"), &"SectionLabel"))
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(MORALE_BAR_WIDTH, MORALE_BAR_HEIGHT)
	bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	bar.min_value = float(HRConstants.MORALE_MIN)
	bar.max_value = float(HRConstants.MORALE_MAX)
	bar.value = float(morale)
	override_bar_fill(bar, morale_color(morale))
	row.add_child(bar)
	var value := UiFactory.make_label(str(morale), &"RowName", morale_color(morale))
	value.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(value)
	out_refs["bar"] = bar
	out_refs["value"] = value
	return row


static func override_bar_fill(bar: ProgressBar, c: Color) -> void:
	# BuildProgress'in amber dolgusu → moral rengi. Varyasyon atandıktan SONRA
	# çağrılmalı (detail_view._override_bar_fill ile aynı reçete).
	var fill: StyleBox = bar.get_theme_stylebox("fill")
	if fill is StyleBoxFlat:
		var f: StyleBoxFlat = (fill as StyleBoxFlat).duplicate()
		f.bg_color = c
		bar.add_theme_stylebox_override("fill", f)


static func repaint_morale(refs: Dictionary, morale: int) -> void:
	var bar: ProgressBar = refs.get("bar", null) as ProgressBar
	var value: Label = refs.get("value", null) as Label
	if bar != null and is_instance_valid(bar):
		bar.value = float(morale)
		override_bar_fill(bar, morale_color(morale))
	if value != null and is_instance_valid(value):
		value.text = str(morale)
		value.add_theme_color_override("font_color", morale_color(morale))


# --- Rozetler ---------------------------------------------------------------

static func badge_row(emp: Character) -> HBoxContainer:
	# Dikkat rozetleri motordan (HRSystem.badges_for — türetilmiş, saklanmış değil),
	# YENİ rozeti ayrı kanaldan: badges_for'a girmiş olsaydı attention_count'u
	# şişirir ve yeni bir işe alım sol rayda "dikkat" yakardı.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	if HRConstants.is_new_hire(emp.hire_day, GameState.day):
		row.add_child(UiFactory.make_badge(HRConstants.badge_label(HRConstants.BADGE_NEW), &"accent"))
	for badge_id in HRSystem.badges_for(emp):
		row.add_child(UiFactory.make_badge(HRConstants.badge_label(String(badge_id)),
			_badge_kind(String(badge_id))))
	return row


static func _badge_kind(badge_id: String) -> StringName:
	# Kaçma riski en ağırı (kırmızı), diğer iki dikkat rozeti amber. Sıralama motorun:
	# badge_severity registry'de.
	if badge_id == HRConstants.BADGE_FLIGHT_RISK:
		return &"negative"
	return &"accent"


static func worst_badge_severity(emp: Character) -> int:
	# Kart sıralaması için: dikkat isteyen satırlar üste. badges_for zaten en kötüsü
	# başta döndürüyor, ağırlık da registry'de — burada karar verilen bir şey yok.
	var badges: Array[String] = HRSystem.badges_for(emp)
	if badges.is_empty():
		return 0
	return HRConstants.badge_severity(badges[0])


# --- Huy çipleri ------------------------------------------------------------

static func trait_chip(trait_id: String, with_tooltip: bool = false) -> Control:
	# Yeşil/kırmızı huy çipi. Polarite ve etki metni registry'den; ham id ekrana
	# asla çıkmaz. Etki metni satır olarak DEĞİL, hover tooltip'inde (CLAUDE.md
	# Effect-Visibility Rule'un beklediği EU4/CK3 grameri): kart sakin kalır,
	# merak eden imleci getirir.
	var polarity: String = HRConstants.trait_polarity(trait_id)
	var kind: StringName = &"positive" if polarity == "positive" else &"negative"
	var chip: Control = UiFactory.make_badge(HRConstants.trait_label(trait_id), kind)
	if with_tooltip:
		# make_badge çipi MOUSE_FILTER_IGNORE ile verir (UiFactory çipleri varsayılan
		# inert); tooltip hover ister, o yüzden yalnız bu çip STOP'a çevrilir
		# (top_bar.gd'nin runway-notu reçetesi). İç Label IGNORE kalır, hover panele düşer.
		chip.mouse_filter = Control.MOUSE_FILTER_STOP
		chip.tooltip_text = HRConstants.trait_effect_text(trait_id)
	return chip


static func trait_row(trait_ids: Array, with_tooltip: bool = false) -> Control:
	# Hep yatay çip sırası; aday dosyasında tooltip'li, çalışan kartında düz.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	for trait_id in trait_ids:
		row.add_child(trait_chip(String(trait_id), with_tooltip))
	return row


# --- Faz okunabilirliği -----------------------------------------------------

static func phase_hint_label(role_id: String) -> Label:
	# Coupling'in UI yükümlülüğü: oyuncu "yazılımcı aldım, tasarım hızlanmadı"
	# şaşkınlığını yaşamasın. Kopya HRConstants.ROLE_PHASE_HINT'te — burada yazılmaz.
	var lbl := UiFactory.make_label(HRConstants.role_phase_hint(role_id), &"RowMeta", UiTokens.INK_DIM)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return lbl


# --- Sayfa kromu ------------------------------------------------------------

static func section_header(text: String, with_rule: bool = true) -> Control:
	# Küçük mono büyük-harf başlık, sağa doğru uzayan saç teli çizgiyle (Kare 1).
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	row.add_child(UiFactory.make_section_header(text))
	if with_rule:
		var rule := hairline()
		rule.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		rule.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(rule)
	return row


static func hairline() -> Panel:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.DIVIDER_LIGHT
	line.add_theme_stylebox_override("panel", sb)
	return line


static func lock_glyph(px: int = 11, color: Color = UiTokens.INK_DIM) -> TextureRect:
	var tex := TextureRect.new()
	tex.texture = load(LOCK_ICON)
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tex.modulate = color
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tex


static func locked_telegraph(text: String) -> Control:
	# "EĞİTİM · KİLİTLİ" — yakında-geliyor telgrafı. Tıklanamaz, soluk.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.modulate = Color(1, 1, 1, 0.55)
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lock_glyph())
	row.add_child(UiFactory.make_section_header(text))
	return row


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


static func disabled_button(label: String, reason: String) -> Button:
	# Kapalı buton + GEREKÇE. Gerekçe motorun preview_*'ından gelir (can_* yalnız
	# bool döner, sebebi taşımaz) — bu yüzden UI hiçbir zaman can_* çağırmaz.
	var btn := Button.new()
	btn.text = label
	btn.disabled = true
	btn.tooltip_text = reason
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return btn


static func lines_block(lines: Array, muted: bool = false) -> VBoxContainer:
	# Motorun hazır Türkçe `lines` dizisini basar. Bu fonksiyonun tamamı
	# "hesaplama yok" kuralının somut hali: sonucu motor yazdı, UI dizdi.
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 3)
	for line in lines:
		col.add_child(UiFactory.make_label(String(line), &"BodySerif",
			UiTokens.INK_MUTED if muted else UiTokens.INK))
	return col


static func set_mouse_ignore(n: Node) -> void:
	# Kart içi çocuklar tıklamayı yutmasın — gui_input kart kökünde (ev deseni).
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		set_mouse_ignore(c)
