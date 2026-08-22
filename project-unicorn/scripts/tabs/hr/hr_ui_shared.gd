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
const MORALE_BAR_WIDTH_DENSE := 92


static func money(amount: int) -> String:
	return HRConstants.money_tr(amount)


# --- Alan yıldızları --------------------------------------------------------
# Onaylı tasarımın ROLLER · LİDERLİK hücresi (9b): alan adı ÜSTTE, beş yıldız ALTINDA,
# iki alan yan yana, sonra hairline, sonra Liderlik. ÇİP DEĞİL: çip bir DURUM anlatır,
# yıldız bir MİKTAR — ve tasarım alanları miktar olarak okutuyor.
static func area_stars_row(role_id: String, role_stats: Dictionary, glyph_px: int = 14,
		muted: bool = false) -> HBoxContainer:
	## Kişinin ANA + İKİNCİL alanı, yıldızla. rev 2 §3 altı alanı düz listede göstermeyi
	## yasaklıyor — rolün iki alanı yeter ve tasarım da tam olarak ikisini çiziyor.
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for area_key in [HRConstants.role_key_area(role_id), HRConstants.role_secondary_area(role_id)]:
		var key: String = String(area_key)
		if key == "":
			continue
		row.add_child(StarRating.labelled(HRConstants.area_label(key),
			int(role_stats.get(key, 0)), glyph_px, muted))
	return row


static func role_area_cell(emp: Character, width: int, muted: bool = false) -> Control:
	## Sabit genişlikte ROLLER · LİDERLİK hücresi. Liderlik alanlardan DİKEY HAIRLINE ile
	## ayrılır (9b): aynı yıldız grameri, ama bir alan değil — ayraç bunu söylüyor.
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	box.custom_minimum_size = Vector2(width, 0)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(area_stars_row(emp.role, emp.role_stats, 14, muted))
	box.add_child(_v_hairline())
	box.add_child(StarRating.labelled(HRConstants.area_label(HRConstants.SKILL_LEADERSHIP),
		int(emp.role_stats.get(HRConstants.SKILL_LEADERSHIP, 0)), 14, muted))
	return box


static func _v_hairline(height: int = 26) -> Panel:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(1, height)
	line.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SEPARATOR
	line.add_theme_stylebox_override("panel", sb)
	return line


# --- Trait ikonu -----------------------------------------------------------
# TRAIT sütunu bir çip değil bir İKON çizer, adı hover'da. ÇALIŞANIN SEKİZİ de
# çizildi (onaylı ikon sayfası 2a, 2026-08-21). KURUCUNUN sekizi hâlâ nötr glifte ve
# bilerek kapsam dışı — ama artık SESSİZCE değil: `trait_icon` hangi kataloğa
# bakacağını söylüyor, çünkü çalışan tablosunda aranan kurucu id'si HER ZAMAN
# kaçıyordu ve kimse fark etmiyordu (A5).
const TRAIT_ICON_DIR := "res://assets/icons/traits/"
const TRAIT_ICON_DRAWN := ["loyal", "picks_it_up_fast", "takes_them_under",
	"double_checker", "last_one_out", "cant_say_no", "bag_packed", "mood_buster"]

## `catalog`: "employee" (varsayılan) ya da "founder". Kurucu trait'lerinin çizilmiş
## ikonu YOK ve olmayacağını BİLEREK soruyoruz — sessiz bir kayıp değil, açık bir yer tutucu.
static func trait_icon_path(trait_id: String, catalog: String = "employee") -> String:
	if catalog == "employee" and TRAIT_ICON_DRAWN.has(trait_id):
		return TRAIT_ICON_DIR + trait_id + ".svg"
	return TRAIT_ICON_DIR + "unspecified.svg"


static func trait_icon(trait_id: String, px: int = 18, boxed: bool = false,
		catalog: String = "employee", box_px: int = 28) -> Control:
	## `boxed` = konturlu kutu. Kişisel kartı 28×28 (10a), Kadro'nun TRAIT hücresi
	## 26×26 (B4) — tek fark kutunun boyu, içindeki glif ve çerçeve aynı.
	var tex := TextureRect.new()
	tex.texture = load(trait_icon_path(trait_id, catalog))
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.modulate = UiTokens.INK_MUTED
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not boxed:
		return tex
	var frame := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.SURFACE_FRAME
	sb.set_border_width_all(UiTokens.BORDER_HAIRLINE)
	sb.border_color = UiTokens.BORDER_HOVER
	sb.set_corner_radius_all(UiTokens.RADIUS_S)
	sb.content_margin_left = 4.0
	sb.content_margin_right = 4.0
	sb.content_margin_top = 4.0
	sb.content_margin_bottom = 4.0
	frame.add_theme_stylebox_override("panel", sb)
	frame.custom_minimum_size = Vector2(box_px, box_px)
	frame.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	frame.add_child(tex)
	return frame


## TEK TOOLTIP KAYNAĞI: ad ve etki, ALT ALTA, TİRE YOK. Her iki yüzey de buradan
## okur — eskiden Kadro `ad\netki`, Atlas ise YALNIZ etki gösteriyordu.
static func trait_tooltip(trait_id: String) -> String:
	return "%s\n%s" % [
		HRConstants.trait_label(trait_id), HRConstants.trait_effect_text(trait_id)]


## HOVER HEDEFİ GEOMETRİYİ İZLER, NİYETİ DEĞİL. Tooltip HER ZAMAN VAR OLAN kaba
## takılır; ikon çizilmediyse (kurucu kataloğu) hedef yine de durur.
##
## PASS, STOP DEĞİL: STOP tooltip'i çalıştırır ama satır tıklamasını YUTAR — ve R1'den
## sonra menüyü açan TEK yol o tıklama. PASS ikisini birden verir.
static func _hoverable(node: Control, trait_id: String) -> Control:
	node.tooltip_text = trait_tooltip(trait_id)
	node.mouse_filter = Control.MOUSE_FILTER_PASS
	return node


static func trait_cell(trait_ids: Array, width: int) -> Control:
	## TEK İKON, 26×26 konturlu kutuda 15px glif (B4 · onaylı sayfa). Motor tek trait
	## taşıyor (HRConstants.TRAIT_COUNT); eski bir kayıt iki taşıyorsa İLKİNİ gösteririz.
	var box := CenterContainer.new()
	box.custom_minimum_size = Vector2(width, 0)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var pick: String = String(trait_ids[0]) if not trait_ids.is_empty() else ""
	if pick == "":
		box.add_child(UiFactory.make_label("—", &"RowMeta", UiTokens.INK_FAINT))
		return box
	box.add_child(_hoverable(trait_icon(pick, 15, true, "employee", 26), pick))
	return box


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
	# KADEMEYİ İZLER (D5). Sabit 150, `HRLedger.W_MORALE_DENSE`in 124'ünden GENİŞTİ ve
	# asgari boyut daha küçük bir custom_minimum'u yener — yani MORAL hücresi başlığın
	# bütçesinden ~66px fazla yer alıyordu ve fazlalık sayfanın sağ kenarından çıkıyordu.
	bar.custom_minimum_size = Vector2(
		MORALE_BAR_WIDTH_DENSE if HRLedger._dense else MORALE_BAR_WIDTH, MORALE_BAR_HEIGHT)
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

static func worst_badge_severity(emp: Character) -> int:
	# Kart sıralaması için: dikkat isteyen satırlar üste. badges_for zaten en kötüsü
	# başta döndürüyor, ağırlık da registry'de — burada karar verilen bir şey yok.
	var badges: Array[String] = HRSystem.badges_for(emp)
	if badges.is_empty():
		return 0
	return HRConstants.badge_severity(badges[0])


# --- Huy çipleri ------------------------------------------------------------

static func trait_chip(trait_id: String, with_tooltip: bool = false) -> Control:
	# TEK MUAMELE, VALANS YOK (R4): sekizi de nötr; ayrım adda, ikonda ve etkide.
	#
	# İKON EKLENDİ (B2, 2026-08-22). Sekiz ikon Kadro'ya ulaşmıştı ama aday kartına
	# ulaşmamıştı: bu yol `make_badge`'den geçiyor ve o yolda HİÇBİR doku yok, yani
	# rozetin duracağı yerde çıplak bir kelime duruyordu. Çip artık ikon + ad.
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
	var lbl := Label.new()
	lbl.theme_type_variation = &"BadgeLabel"
	lbl.text = UiTokens.tr_upper(HRConstants.trait_label(trait_id))
	lbl.add_theme_color_override("font_color", p.fg)
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(lbl)
	chip.add_child(row)
	if with_tooltip:
		# Hedef ÇİPİN KENDİSİ — her zaman var. İçerik artık Kadro'yla AYNI: ad + etki.
		return _hoverable(chip, trait_id)
	chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
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


## Dikkat şeridinin ⚠ işareti. Kilit glifinin yerine kendi ikonu var, çünkü kilit
## "yapamazsın" der, uyarı "bak" der — ikisi aynı şerit değil.
static func warning_glyph(px: int = 12, color: Color = UiTokens.NEGATIVE) -> TextureRect:
	var tex := TextureRect.new()
	tex.texture = load("res://assets/icons/warning.svg")
	tex.custom_minimum_size = Vector2(px, px)
	tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	tex.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	tex.modulate = color
	tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return tex


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


## `lines_block` EMEKLİ (A1, 2026-08-22). Tek işi motorun hazır cümlelerini basmaktı;
## motor artık cümle değil KAYIT döndürüyor (`rows`) ve onları üç farklı giysiyle
## dizen yer `hr_action_modal.gd`. Çağıranı kalmadı.


static func set_mouse_ignore(n: Node) -> void:
	# Kart içi çocuklar tıklamayı yutmasın — gui_input kart kökünde (ev deseni).
	if n is Control:
		(n as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for c in n.get_children():
		set_mouse_ignore(c)
