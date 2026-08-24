extends Control

# ÇALIŞMA SAATLERİ — §8.5, ONAYLI 19a–19d'DEN KURULDU.
#
# LEDGER (2026-08-24): bu dosyanın bir önceki hâli §8.5'in METNİNDEN türetilmişti ve
# reddedildi. Proje kuralı: tasarım kaynağı Claude Design çıktısıdır, yerleşim metinden
# türetilmez. Bu sürüm `Unicorn Skins.dc.html` turu 19'un dört kaltasından okundu (canlı
# çekildi ve önbellek anlık görüntüsüyle BAYT-AYNI çıktığı doğrulandı). Metinden türetilen
# hâlin yanlış tahmin ettiği şeyler, sırayla:
#
#   · Modalin BAŞLIĞI yoktu. 19a'da var: "Çalışma saatleri", serif, altında 1px kural.
#   · Başlangıç stepper'ı BAŞLIKTAYDI. 19a'da o bir SÜTUN (BAŞLANGIÇ) ve yalnız Şirket
#     satırında dolu; grup ve çalışan satırları o hücreyi BOŞ çiziyor (§8.1: başlangıç
#     yalnız şirket kapsamı).
#   · Sütun sırası KAPSAM · BAŞLANGIÇ · SÜRE · DURUM · KAYNAK · MORAL. Eskisinde ayrı bir
#     "Kendi" sütunu ve ayrı bir geri-al sütunu vardı; 19b geri dönüş EYLEMİNİ KAYNAK
#     hücresinin İÇİNE koyuyor — devralan satır "şirketten"/"gruptan" yazıyor, karar veren
#     satır geri-ok çipiyle "şirkete dön" taşıyor. Aynı hücre, iki hâl.
#   · Alt barda yalnız "Kapat" vardı. 19a'da sessiz "Vazgeç" + amber dolu "Uygula" var,
#     yani modal TAAHHÜTLÜDÜR. Bu bir kozmetik fark değil: §8.5'in "maliyet TAAHHÜTTEN
#     ÖNCE okunur" cümlesi ancak taahhüt varsa harfi harfine doğru olur.
#   · Sütun başlıkları boştu ("" iki sütun için). 19a hepsini adıyla yazıyor.
#   · Kurucu bu listede GÖRÜNMEZ (§2, §8.1) — bu doğruydu ve korundu.
#
# TAAHHÜTLÜ MODAL. Düzenlemeler `_draft`'a yazılır; `Uygula` WorkHoursSystem.apply_state'i
# çağırır, `Vazgeç` taslağı atar. Çözümleme İKİNCİ KEZ YAZILMADI: taslak da canlı durum da
# WorkHoursSystem'in aynı `_resolve` gövdesinden geçer (§15.2), yoksa önizleme ile tahakkuk
# ayrışırdı — bu modülün geçmişindeki tam olarak o yalan.
#
# MORAL SÜTUNU İKİ ŞEY TAŞIR: kişinin morali (çubuk + sayı, kadro defteriyle aynı gramer)
# ve saatin moral YÖNÜ — kademeli şevron. Mesaide amber aşağı (9s bir · 10s iki · 11s üç),
# kısa günde yeşil yukarı, 7 saatte düz çizgi. HİÇBİR YERDE KATSAYI YOK (§8.5); kademe
# glifin kendisinden okunur, cümlesi glifin tooltip'inde durur.
#
# İKİ BİLİNÇLİ SAPMA, ikisi de Erdem'in bu turdaki hükmü:
#   · BİTİŞ SAATİ. Artboard'da hiç yok (yalnız başlık çipinde). Şirket satırının BAŞLANGIÇ
#     hücresine, stepper'dan sonra sönük "→ 17:00" olarak eklendi. BAŞLANGIÇ sütunu bunun
#     için 150→190 genişledi; ÖTEKİ BEŞ SÜTUN KIPIRDAMADI — esneyen KAPSAM sütunu 40px
#     verdi, yani ızgara yeniden akmadı. (168 denendi ve ÇEKİMDE "→ 17" diye kesildi;
#     ölçü tahminle değil kareyle bulundu.)
#   · BOŞ SÜTUN BAŞLIKLARI. Yalnız kadro TAMAMEN boşken DURUM ve MORAL başlıkları
#     çizilmez. Kadro doluyken 19a korunur (DURUM boş olsa da başlığı durur) — tablo
#     hiçbir durumda yeniden akmaz.
#
# TİP REGİSTER'I: artboard kartın tamamını mono çiziyor; proje Terminal register'ında ad
# sans, veri mono. Ekip sayfası aynı artboard ailesinden bu eşlemeyle KABUL EDİLDİ, o yüzden
# modal ona uyuyor — yoksa aynı kadro iki farklı yüzle çizilirdi.
#
# PanelLayer'da yaşar, ModalLayer'da DEĞİL: HRAtlasModal'ın kalıbı (gerekçe hr_tab._open_atlas).

signal state_changed

const PANEL_MIN := Vector2(1000, 0)

## onaylı 19a ölçüleri. KAPSAM esner (artboard'da flex:1), kalan beşi sabit.
const W_START := 190      # 19a'da 150; +40 bitiş saati şeridi için (yukarıdaki sapma)
const W_HOURS := 150
const W_STATE := 110
const W_SOURCE := 120
const W_MORALE := 110
const H_HEAD := 30
const H_COMPANY := 52
const H_ROW := 42
const PAD_ROW := 14
const INDENT_GROUP := 26
const INDENT_PERSON := 46
const STEP_BTN := Vector2(22, 24)
const STEP_VALUE_W := 56
const MORALE_METER := Vector2(44, 4)

var _draft: Dictionary = {}
var _root_box: VBoxContainer = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP

	var dim := ColorRect.new()
	dim.color = UiTokens.SCRIM_MODAL
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var panel := PanelContainer.new()
	panel.theme_type_variation = &"ModalPanel"
	panel.custom_minimum_size = PANEL_MIN
	center.add_child(panel)

	var margin := MarginContainer.new()
	# 19a: padding 22px 24px.
	margin.add_theme_constant_override("margin_left", 24)
	margin.add_theme_constant_override("margin_right", 24)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	_root_box = VBoxContainer.new()
	_root_box.add_theme_constant_override("separation", 0)
	margin.add_child(_root_box)


## Ev sahibi ÖNCE add_child eder, SONRA burayı çağırır (ev kuralı).
func populate() -> void:
	if not is_node_ready():
		await ready
	# TASLAK AÇILIŞTA BİR KEZ ALINIR. Sonraki her çizim ondan okur; motora ancak `Uygula`
	# dokunur.
	_draft = WorkHoursSystem.draft_state()
	_rebuild()


func _rebuild() -> void:
	for c in _root_box.get_children():
		_root_box.remove_child(c)
		c.queue_free()

	# BAŞLIK (19a): serif, altında 1px kural. Alt başlık yok, kapatma X'i yok.
	_root_box.add_child(UiFactory.make_label(tr("HR_HOURS_TITLE"), &"TitleSerif"))
	_root_box.add_child(_gap(14))
	_root_box.add_child(HRUiShared.hairline())
	_root_box.add_child(_gap(14))

	var roster: Array[Character] = CharacterRegistry.get_employees()
	_root_box.add_child(_column_head(roster.is_empty()))
	_root_box.add_child(_company_row(roster.size()))

	for group_id in HRConstants.ROSTER_GROUPS:
		var gid: String = String(group_id)
		# Boş bir grup da satırını taşır: grup istisnası, o gruba SONRADAN KATILAN herkesi
		# kapsar (§8.1), yani boşken yazılan bir istisna anlamlıdır.
		_root_box.add_child(_group_row(gid))
		for emp in roster:
			if String(HRConstants.ROLE_GROUP.get(emp.role, "")) == gid:
				_root_box.add_child(_person_row(emp))

	var cost: Control = _cost_block()
	if cost != null:
		_root_box.add_child(cost)
	_root_box.add_child(_footer())


func _gap(h: int) -> Control:
	var pad := Control.new()
	pad.custom_minimum_size = Vector2(0, h)
	pad.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return pad


## SÜTUNU ÇİVİLER. Bir HBoxContainer çocuğunun ASGARİ boyutunu asla kırpmaz, yani içeriği
## bütçesini aşan tek bir hücre bütün satırı kaydırır — ilk kurulumda tam olarak bu oldu ve
## SÜRE kutuları satırdan satıra 50–200px kaydı (çekimden okundu). Düz bir `Control` çocuk
## yerleşimi YAPMAZ, dolayısıyla asgari boyutu yalnız kendi `custom_minimum_size`'ıdır;
## çocuk tam-dikdörtgen çapalanır ve `clip_contents` taşan pikseli keser.
##
## Yani sütun genişliği bir DİLEK değil bir SÖZLEŞME: ne yazarsak yazalım ızgara akmaz.
func _pin(width: int, child: Control) -> Control:
	var cell := Control.new()
	cell.custom_minimum_size = Vector2(width, 0)
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(child)
	child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return cell


## Esneyen KAPSAM sütunu — aynı sözleşme, sabit genişlik yerine EXPAND.
func _flex(child: Control) -> Control:
	var cell := Control.new()
	cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cell.clip_contents = true
	cell.mouse_filter = Control.MOUSE_FILTER_PASS
	cell.add_child(child)
	child.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	return cell


# --- Satır kabuğu -------------------------------------------------------------
# 19a'nın satırları TEK bir HBox: sol kenar boşluğu girintiyi taşır, sağ kenar boşluğu
# sabit, altında hairline. Yükseklikler artboard'dan: başlık 30 · şirket 52 · diğer 42.

func _row(height: int, indent: int, tint: bool, divider: Color) -> HBoxContainer:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	var body := PanelContainer.new()
	if tint:
		var sb := StyleBoxFlat.new()
		sb.bg_color = UiTokens.SURFACE_ROW_TINT
		body.add_theme_stylebox_override("panel", sb)
	else:
		body.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	wrap.add_child(body)
	var mg := MarginContainer.new()
	mg.add_theme_constant_override("margin_left", PAD_ROW + indent)
	mg.add_theme_constant_override("margin_right", PAD_ROW)
	body.add_child(mg)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, height)
	mg.add_child(row)
	wrap.add_child(HRUiShared.hairline(divider))
	return row


func _finish(row: HBoxContainer) -> Control:
	return row.get_parent().get_parent().get_parent()


# --- Sütun başlıkları ---------------------------------------------------------

## 19a altı başlığı da yazar. TEK İSTİSNA (Erdem, bu tur): kadro TAMAMEN boşken DURUM ve
## MORAL'ın söyleyeceği bir şey yoktur ve başlıkları çizilmez. Kadro doluyken 19a birebir
## korunur — DURUM'un o an boş olması başlığı kaldırmaz, yoksa ilk istisnada tablo
## yeniden akardı.
func _column_head(roster_empty: bool) -> Control:
	var row := _row(H_HEAD, 0, false, UiTokens.CARD_BORDER)
	row.add_child(_head_cell(tr("HR_HOURS_COL_SCOPE"), 0))
	row.add_child(_head_cell(tr("HR_HOURS_COL_START"), W_START))
	row.add_child(_head_cell(tr("HR_HOURS_COL_HOURS"), W_HOURS))
	row.add_child(_head_cell("" if roster_empty else tr("HR_HOURS_COL_STATE"), W_STATE))
	row.add_child(_head_cell(tr("HR_HOURS_COL_SOURCE"), W_SOURCE))
	row.add_child(_head_cell("" if roster_empty else tr("HR_COL_MORALE"), W_MORALE,
		HORIZONTAL_ALIGNMENT_RIGHT))
	return _finish(row)


func _head_cell(text: String, width: int,
		align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Control:
	var lbl := UiFactory.make_label(text, &"ColumnHeader")
	lbl.horizontal_alignment = align
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _flex(lbl) if width <= 0 else _pin(width, lbl)


# --- Satırlar -----------------------------------------------------------------

func _company_row(headcount: int) -> Control:
	var row := _row(H_COMPANY, 0, true, UiTokens.CARD_BORDER)
	var hours: int = int(_draft["company"])
	var start: int = int(_draft["start"])

	# KAPSAM: ad + altında kadro sayısı (19a).
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(UiFactory.make_label(tr("HR_HOURS_SCOPE_COMPANY"), &"RowName"))
	col.add_child(UiFactory.make_label(
		tr("HR_HOURS_COMPANY_SUB").format({"n": headcount}), &"ColumnHeader"))
	row.add_child(_flex(col))

	# BAŞLANGIÇ — YALNIZ ŞİRKET KAPSAMINDA (§8.1): "Ofis tek saatte açılır; değişen, kimin
	# ne zaman çıktığıdır." Yanında bitiş saati, sönük (bilinçli sapma, başlıkta anlatıldı).
	var start_cell := HBoxContainer.new()
	start_cell.add_theme_constant_override("separation", 6)
	start_cell.alignment = BoxContainer.ALIGNMENT_BEGIN
	var start_step: Control = _stepper(
		"%02d:00" % start, start > HRConstants.START_HOUR_MIN, start < HRConstants.START_HOUR_MAX,
		_on_start.bind(start - 1), _on_start.bind(start + 1), UiTokens.INK, false)
	start_step.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	start_cell.add_child(start_step)
	var window: Dictionary = WorkHoursSystem.company_window(hours, start)
	var end_lbl := UiFactory.make_label("→ %s" % String(window["end_text"]),
		&"ColumnHeader", UiTokens.INK_FAINT)
	end_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	start_cell.add_child(end_lbl)
	row.add_child(_pin(W_START, start_cell))

	row.add_child(_hours_cell(hours, false, false, _on_company_hours))
	row.add_child(_state_cell(hours))
	# ŞİRKET SATIRININ KAYNAĞI "temel" (19a): üstünde devralacağı bir kapsam yok, dolayısıyla
	# dönülecek bir yer de yok.
	row.add_child(_source_text(tr("HR_HOURS_SOURCE_BASE")))
	row.add_child(_pin(W_MORALE, Control.new()))   # şirketin morali yoktur (§2)
	return _finish(row)


func _group_row(group_id: String) -> Control:
	var row := _row(H_ROW, INDENT_GROUP, false, UiTokens.DIVIDER_LIGHT)
	var owns: bool = WorkHoursSystem.group_has_override_in(_draft, group_id)
	var hours: int = int((_draft["groups"] as Dictionary).get(group_id, _draft["company"]))

	var name_cell := UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.group_label(group_id)), &"SectionAmber")
	name_cell.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(_flex(name_cell))

	row.add_child(_pin(W_START, Control.new()))  # §8.1: başlangıç yalnız şirket kapsamı
	row.add_child(_hours_cell(hours, not owns, false, _on_group_hours.bind(group_id)))
	row.add_child(_state_cell(hours))
	row.add_child(_source_cell(owns, tr("HR_HOURS_SOURCE_FROM_COMPANY"),
		_on_clear_group.bind(group_id)))
	row.add_child(_pin(W_MORALE, Control.new()))  # grubun morali yoktur; kişilerinki satırlarında
	return _finish(row)


func _person_row(emp: Character) -> Control:
	var row := _row(H_ROW, INDENT_PERSON, false, UiTokens.DIVIDER_LIGHT)
	var owns: bool = WorkHoursSystem.person_has_override_in(_draft, emp)
	var hours: int = WorkHoursSystem.hours_in(_draft, emp)
	var short_day: bool = HRConstants.is_short_day_hours(hours)

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 2)
	col.alignment = BoxContainer.ALIGNMENT_CENTER
	col.add_child(UiFactory.make_label(emp.character_name, &"RowName"))
	col.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.job_title(emp.role, emp.level)), &"ColumnHeader"))
	row.add_child(_flex(col))

	row.add_child(_pin(W_START, Control.new()))
	row.add_child(_hours_cell(hours, not owns, short_day, _on_person_hours.bind(emp.id)))
	row.add_child(_state_cell(hours))
	# KAYNAK, kelimeyle. `inherited_from_in` KAPSAM SÖZCÜĞÜ döner ("group"/"company"), grup
	# id'si DEĞİL — bu satır bir kez o ayrımı kaçırdı ve istisnası olan bir GRUPTAN devralan
	# herkesi "Şirket" diye etiketledi, yani okunur kılmak için var olan sütun kararı veren
	# satırı yanlış gösterdi.
	var from_key: String = "HR_HOURS_SOURCE_FROM_GROUP" \
		if WorkHoursSystem.inherited_from_in(_draft, emp) == "group" \
		else "HR_HOURS_SOURCE_FROM_COMPANY"
	row.add_child(_source_cell(owns, tr(from_key), _on_clear_person.bind(emp.id)))
	row.add_child(_morale_cell(emp, hours))
	return _finish(row)


# --- Hücreler -----------------------------------------------------------------

## Satır içi dikey ortalama: çivilenmiş hücre tam yükseklik alır, içerik ortada durur.
func _centered(child: Control) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	child.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	box.add_child(child)
	return box


## SÜRE hücresi (19a/19b). DÖRT GİYSİ, tamamı KUTUDA — dolgu değil çerçeve taşır:
##   devralan          kesikli kenar · şeffaf · sönük yazı
##   şirket tabanı     düz kenar · çok hafif dolgu · kalın ink
##   kendi kararı · mesai      amber kenar + %10 amber dolgu · kalın amber
##   kendi kararı · kısa gün   yeşil kenar + %10 yeşil dolgu · kalın yeşil
## Stepper düğmeleri HER SATIRDA çizilir (19a'nın kendisi öyle) — devralan satırda da,
## çünkü basmak o satıra bir istisna YAZAR; hover değeri değiştirmez, yalnız
## dokunulabilirliği söyler (19c).
func _hours_cell(hours: int, inherited: bool, short_day: bool, on_set: Callable) -> Control:
	var color: Color = UiTokens.INK
	if inherited:
		color = UiTokens.INK_DIM
	elif HRConstants.is_overtime_hours(hours):
		color = UiTokens.ACCENT
	elif short_day:
		color = UiTokens.POSITIVE
	return _pin(W_HOURS, _centered(_stepper(
		tr("HR_HOURS_VALUE").format({"n": hours}),
		hours > HRConstants.WORK_HOURS_MIN, hours < HRConstants.WORK_HOURS_MAX,
		on_set.bind(hours - 1), on_set.bind(hours + 1), color, inherited)))


func _stepper(text: String, can_down: bool, can_up: bool, on_down: Callable, on_up: Callable,
		color: Color, dashed: bool) -> Control:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_BEGIN
	box.add_child(_step_button("−", can_down, on_down))

	var value := PanelContainer.new()
	var sb := StyleBoxFlat.new()
	sb.border_width_left = 1
	sb.border_width_right = 1
	sb.border_width_top = 1
	sb.border_width_bottom = 1
	sb.corner_radius_top_left = 2
	sb.corner_radius_top_right = 2
	sb.corner_radius_bottom_left = 2
	sb.corner_radius_bottom_right = 2
	if dashed:
		# Godot'un StyleBoxFlat'inde KESİKLİ KENAR YOKTUR. Devralan satırın "ödünç alınmış"
		# okunuşu bu yüzden alfayla veriliyor: aynı kenar rengi, yarı saydam — çizgi
		# zayıflar, dolgu hiç gelmez. (Bir doku ya da özel _draw kesikli çizgi çizebilirdi;
		# tek bir kutu kenarı için ikisi de bu dosyaya bir çizim katmanı sokardı.)
		sb.border_color = Color(UiTokens.BORDER_HOVER, 0.55)
		sb.bg_color = Color(0, 0, 0, 0)
	elif color == UiTokens.ACCENT or color == UiTokens.POSITIVE:
		sb.border_color = color
		sb.bg_color = Color(color, 0.10)
	else:
		sb.border_color = UiTokens.BORDER_STEPPER_OWN
		sb.bg_color = Color(UiTokens.INK, 0.05)
	value.add_theme_stylebox_override("panel", sb)
	var lbl := UiFactory.make_label(text, &"StepperValue" if not dashed else &"RowMeta", color)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(STEP_VALUE_W, STEP_BTN.y)
	value.add_child(lbl)
	box.add_child(value)

	box.add_child(_step_button("+", can_up, on_up))
	return box


## SESSİZ düğme: kenarlıklı temanın varsayılan butonu, dar min-size'la. Dolu bir buton
## burada yanlış olurdu — bir satırda iki taahhüt rengi taşımak, 19a'nın tek amber
## öğesinin `Uygula` olması kuralıyla çelişir.
func _step_button(glyph: String, enabled: bool, on_press: Callable) -> Button:
	var btn := Button.new()
	btn.text = glyph
	btn.custom_minimum_size = STEP_BTN
	btn.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	btn.disabled = not enabled
	if enabled and on_press.is_valid():
		btn.pressed.connect(on_press)
	return btn


## §8.5 DURUM DİLİ: 8 saat nötr ve SÜSLEMESİZ · üstü amber "+Ns mesai" · altı yeşil
## "−Ns kısa". Sayı yok, çarpan yok.
func _state_cell(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return _pin(W_STATE, Control.new())
	var text: String = TranslationServer.translate("HR_STATE_HOURS_OVER").format({"n": delta}) \
		if delta > 0 else TranslationServer.translate("HR_STATE_HOURS_SHORT").format({"n": -delta})
	var lbl := UiFactory.make_label(text, &"RowMeta",
		UiTokens.ACCENT if delta > 0 else UiTokens.POSITIVE)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _pin(W_STATE, lbl)


## KAYNAK — 19b'nin bulduğu şey: devir dili ve geri dönüş eylemi AYNI HÜCREDE yaşar.
## Devralan satır nereden aldığını yazar; karar veren satır geri-ok çipiyle "şirkete dön"
## taşır. Ayrı bir geri-al sütunu yoktur.
func _source_cell(owns: bool, from_text: String, on_revert: Callable) -> Control:
	if not owns:
		return _source_text(from_text)
	# ÇİP KENDİ ÖLÇÜSÜNÜ TAŞIR. Temanın varsayılan buton dolgusu bu hücrede ~190px eder ve
	# 120px'lik sütun bütçesini aşardı (ilk çekimde ızgarayı akıtan iki şeyden biri buydu).
	# 19b'nin ölçüsü: 1px kenar, radius 2, dolgu 7×3, 10px geri-ok, mikro yazı.
	var chip := Button.new()
	chip.text = tr("HR_HOURS_BACK_TO_COMPANY")
	chip.icon = HRUiShared.revert_arrow_icon()
	chip.add_theme_constant_override("icon_max_width", 10)
	chip.add_theme_constant_override("h_separation", 5)
	chip.add_theme_font_size_override("font_size", UiTokens.SIZE_META)
	chip.add_theme_color_override("font_color", UiTokens.INK_DIM)
	chip.add_theme_color_override("font_hover_color", UiTokens.INK_MUTED)
	chip.add_theme_color_override("icon_normal_color", UiTokens.INK_DIM)
	chip.add_theme_color_override("icon_hover_color", UiTokens.INK_MUTED)
	for state in ["normal", "hover", "pressed", "focus"]:
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color(0, 0, 0, 0)
		sb.set_border_width_all(1)
		sb.border_color = UiTokens.BORDER_HOVER if state == "hover" else UiTokens.CARD_BORDER
		sb.set_corner_radius_all(2)
		sb.content_margin_left = 7
		sb.content_margin_right = 7
		sb.content_margin_top = 3
		sb.content_margin_bottom = 3
		chip.add_theme_stylebox_override(state, sb)
	chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	if on_revert.is_valid():
		chip.pressed.connect(on_revert)
	return _pin(W_SOURCE, _centered(chip))


func _source_text(text: String) -> Control:
	var lbl := UiFactory.make_label(text, &"ColumnHeader", UiTokens.INK_FAINT)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	return _pin(W_SOURCE, lbl)


## MORAL — sağa dayalı, iki parça: YÖN göstergesi, sonra kadro defterinin moral satırı.
## §8.5: "oyuncu eğriyi tek bir sayı görmeden okur." Yön kademeli şevronla verilir ve
## kademenin CÜMLESİ glifin tooltip'inde durur (altı hover satırı, §8.5'in kendi listesi).
func _morale_cell(emp: Character, hours: int) -> Control:
	var cell := HBoxContainer.new()
	cell.add_theme_constant_override("separation", 8)
	cell.alignment = BoxContainer.ALIGNMENT_END

	var dir: Control = _morale_direction(hours)
	if dir != null:
		cell.add_child(dir)

	# ÖLÇÜ MODALİN KENDİSİNİN (19b: 44×4 çubuk + 7px + sayı). `HRUiShared.morale_row`
	# DEFTERİN çubuğunu taşıyor (124–150px) ve bu hücrenin 110px'lik bütçesini aşıyordu —
	# ızgarayı akıtan ikinci şey oydu. Aynı gramer, modalin ölçüsünde.
	var meter := ProgressBar.new()
	meter.theme_type_variation = &"BuildProgress"
	meter.show_percentage = false
	meter.custom_minimum_size = MORALE_METER
	meter.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	meter.min_value = float(HRConstants.MORALE_MIN)
	meter.max_value = float(HRConstants.MORALE_MAX)
	meter.value = float(emp.morale)
	HRUiShared.override_bar_fill(meter, HRUiShared.morale_color(emp.morale))
	cell.add_child(meter)

	var value := UiFactory.make_label(str(emp.morale), &"StepperValue",
		HRUiShared.morale_color(emp.morale))
	value.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cell.add_child(value)
	return _pin(W_MORALE, cell)


## Kademeli şevron. 9s bir · 10s iki · 11s üç amber aşağı · 7s düz çizgi · 5-6s yeşil yukarı ·
## 8s hiç (söyleyecek şeyi olmayan satır yoktur). Çizim HRUiShared'de değil burada: tek
## okuyucusu bu sütun ve şekli §8.5'in kademe cümlesine bağlı.
func _morale_direction(hours: int) -> Control:
	var delta: int = hours - HRConstants.WORK_HOURS_DEFAULT
	if delta == 0:
		return null
	var line: String = TranslationServer.translate("HR_HOURS_HOVER_%d" % hours)
	if line == "HR_HOURS_HOVER_%d" % hours:
		line = ""
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", 1)
	box.alignment = BoxContainer.ALIGNMENT_END
	box.tooltip_text = line
	box.mouse_filter = Control.MOUSE_FILTER_STOP
	if delta > 0:
		for _i in delta:
			box.add_child(HRUiShared.chevron(9, UiTokens.ACCENT, false))
	elif delta == -1:
		box.add_child(HRUiShared.chevron_flat(9, UiTokens.POSITIVE))
	else:
		box.add_child(HRUiShared.chevron(9, UiTokens.POSITIVE, true))
	return box


# --- §14 bedel bloğu ----------------------------------------------------------

## §8.5: "Kimse mesaide ve kimse kısa günde değilken bedel listesi TAMAMEN KAPANIR: ne
## delta, ne olgu, ne kural." 19a bunu birebir gösteriyor — o kaltada blok HİÇ YOK.
## null döner ve çağıran hiçbir şey çizmez.
func _cost_block() -> Control:
	var counts: Dictionary = WorkHoursSystem.counts_in(_draft)
	var over: int = int(counts["overtime"])
	var short_day: int = int(counts["short_day"])
	if over == 0 and short_day == 0:
		return null

	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", 9)
	col.add_child(_gap(18))

	# DELTA — bloğun en ağır elemanı (19b). "Önce" bugün YAYINLANMIŞ günlük burn; "sonra"
	# TASLAĞIN ima ettiği burn. Modal taahhütlü olduğu için bu artık gerçekten bir ÖNİZLEME:
	# oyuncu rakamı ödemeden önce DEĞİL, taahhüt etmeden önce okuyor.
	var published: int = int(FinanceSystem.get_burn_breakdown().get("overtime", 0))
	var before: int = GameState.daily_burn
	var after: int = before - published + WorkHoursSystem.daily_overtime_in(_draft)
	var delta := HBoxContainer.new()
	delta.add_theme_constant_override("separation", 10)
	delta.add_child(UiFactory.make_label(tr("HR_HOURS_COST_BURN"), &"RowMeta", UiTokens.INK_MUTED))
	delta.add_child(UiFactory.make_label(HRUiShared.money(before), &"RowMeta", UiTokens.CREAM_DIM))
	delta.add_child(UiFactory.make_label("→", &"RowMeta", UiTokens.INK_DIM))
	delta.add_child(UiFactory.make_label(HRUiShared.money(after), &"MetricValueInk",
		UiTokens.NEGATIVE if after > before else UiTokens.INK))
	col.add_child(delta)

	# OLGU — kaç kişi hangi kademede. Sıfır olan yarım hiç yazılmaz.
	var facts: Array[String] = []
	if over > 0:
		facts.append(tr("HR_HOURS_FACT_OVER").format({"n": over}))
	if short_day > 0:
		facts.append(tr("HR_HOURS_FACT_SHORT").format({"n": short_day}))
	col.add_child(UiFactory.make_label(" · ".join(facts), &"RowMeta", UiTokens.CREAM_DIM))

	# KURAL — yalnız geçerli olanı, italik (19b). Kısa gün kuralı §8.3'ün adıyla istediği
	# satırdır: "Maaş yükü düşmez ... ve bu modalde AÇIKÇA YAZILIR — yoksa oyuncu tasarruf
	# bekler ve sistemi bozuk sanır."
	var rules := VBoxContainer.new()
	rules.add_theme_constant_override("separation", 3)
	if over > 0:
		rules.add_child(UiFactory.make_label(tr("HR_HOURS_RULE_OVERTIME"), &"QuoteSerif",
			UiTokens.INK_MUTED))
	if short_day > 0:
		rules.add_child(UiFactory.make_label(tr("HR_HOURS_RULE_SHORT"), &"QuoteSerif",
			UiTokens.INK_MUTED))
	col.add_child(rules)
	return col


# --- Alt bar ------------------------------------------------------------------

## 19a: solda sessiz "Tümünü şirkete eşitle" · esneyen boşluk · sessiz "Vazgeç" · amber
## DOLU "Uygula". Karttaki TEK dolu amber öğe budur.
func _footer() -> Control:
	var wrap := VBoxContainer.new()
	wrap.add_theme_constant_override("separation", 0)
	wrap.add_child(_gap(20))
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	# İstisna yokken eşitlenecek bir şey de yoktur; düğme çizilmez (§8.5, "söyleyecek şeyi
	# olmayan satır yoktur").
	if WorkHoursSystem.override_count_in(_draft) > 0:
		row.add_child(HRUiShared.action_button(tr("HR_HOURS_EQUALISE"), _on_equalise))
	var pad := Control.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(pad)
	row.add_child(HRUiShared.action_button(tr("HR_HOURS_CANCEL"), _close))
	row.add_child(HRUiShared.action_button(tr("HR_HOURS_APPLY"), _on_apply, true))
	wrap.add_child(row)
	return wrap


# --- Taslak yazma (motora DOKUNMAZ; yalnız `Uygula` dokunur) -------------------

func _on_company_hours(hours: int) -> void:
	_draft["company"] = clampi(hours, HRConstants.WORK_HOURS_MIN, HRConstants.WORK_HOURS_MAX)
	_rebuild()


func _on_start(hour: int) -> void:
	_draft["start"] = clampi(hour, HRConstants.START_HOUR_MIN, HRConstants.START_HOUR_MAX)
	_rebuild()


func _on_group_hours(hours: int, group_id: String) -> void:
	(_draft["groups"] as Dictionary)[group_id] = clampi(
		hours, HRConstants.WORK_HOURS_MIN, HRConstants.WORK_HOURS_MAX)
	_rebuild()


func _on_person_hours(hours: int, id: String) -> void:
	(_draft["people"] as Dictionary)[id] = clampi(
		hours, HRConstants.WORK_HOURS_MIN, HRConstants.WORK_HOURS_MAX)
	_rebuild()


func _on_clear_group(group_id: String) -> void:
	(_draft["groups"] as Dictionary).erase(group_id)
	_rebuild()


func _on_clear_person(id: String) -> void:
	(_draft["people"] as Dictionary).erase(id)
	_rebuild()


func _on_equalise() -> void:
	(_draft["groups"] as Dictionary).clear()
	(_draft["people"] as Dictionary).clear()
	_rebuild()


func _on_apply() -> void:
	WorkHoursSystem.apply_state(_draft)
	state_changed.emit()
	_close()


func _unhandled_input(ev: InputEvent) -> void:
	if ev.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


## VAZGEÇ = KAPAT. Taslak yerel; serbest bırakmak onu atmaya yeter, geri alınacak bir motor
## yazması yok. Esc de buraya düşer.
func _close() -> void:
	queue_free()
