class_name HRLedger
extends RefCounted

# EKİP DEFTERİ — onaylı Terminal düzeni (mockup 5g/5h).
#
# Kart listesi EMEKLİ. Defter tam genişlikte tek bir tablodur: etiketli mono sütun
# başlıkları, altlarında ÇIPLAK RAKAMLAR. Kilitli reçetenin çekirdek kuralı bu —
# "hiçbir sayı, oyuncuya 'bu ne?' dedirtmeden durmaz".
#
# Sütun genişlikleri mockup'tan BİREBİR ölçüldü; eyeball yok:
#   ÇALIŞAN flex · UZMANLIK 92 · HIZ 64 · UYUM 64 · DENEYİM 110 ·
#   (adsız durum sütunu) 330 · MAAŞ 130 · MORAL 170
# Adsız 330'luk sütun mockup'ta BOŞ görünüyor çünkü ekran boş-durumu gösteriyor;
# dolu satırda DURUM ÇİPLERİ orada yaşıyor (YENİ · İzinde · Eğitimde · N gün ·
# EĞİTİME GÖNDER). Başlığı da o yüzden var: etiketsiz sütun bırakılmıyor.
#
# ROL AÇIKLAMASI ARTIK SATIRDA DEĞİL: mockup satırı tek satır yüksekliğinde ve
# açıklama metni defteri üç katına çıkarırdı. HOVER TOOLTIP'e taşındı (görev §2).

const W_EXPERTISE := 92
const W_PACE := 64
const W_RAPPORT := 64
const W_EXPERIENCE := 110
const W_STATE := 330
const W_SALARY := 130
const W_MORALE := 170
## Defterin kendi aksiyonu; HREmployeeCard'ın üçlüsüne eklenir.
const ACTION_TRAIN := "train"


## Sütun başlığı satırı. Bir kez, defterin en üstünde — her departmanda tekrar
## ETMEZ (mockup böyle: başlık tablonun başlığıdır, bölümün değil).
static func column_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	row.custom_minimum_size = Vector2(0, 26)
	row.add_child(_head(tr_key("HR_COL_EMPLOYEE"), 0, HORIZONTAL_ALIGNMENT_LEFT))
	row.add_child(_head(tr_key("HR_COL_EXPERTISE"), W_EXPERTISE))
	row.add_child(_head(tr_key("HR_COL_PACE"), W_PACE))
	row.add_child(_head(tr_key("HR_COL_RAPPORT"), W_RAPPORT))
	row.add_child(_head(tr_key("HR_COL_EXPERIENCE"), W_EXPERIENCE))
	row.add_child(_head(tr_key("HR_COL_STATE"), W_STATE))
	row.add_child(_head(tr_key("HR_COL_SALARY"), W_SALARY))
	row.add_child(_head(tr_key("HR_COL_MORALE"), W_MORALE))
	var wrap := PanelContainer.new()
	wrap.theme_type_variation = &"HeaderBand"
	wrap.add_child(row)
	return wrap


## Bir çalışan satırı. `refs` moral yerinde-boyama referanslarını doldurur
## (hr_tab'ın mevcut _morale_refs sözleşmesi korunuyor).
static func row(emp: Character, on_action: Callable, refs: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"LedgerRow"
	# HOVER = KENAR. Dolgu bayt-aynı kalır; yalnız çerçeve açılır. İki varyasyonun
	# content margin'leri de aynı, yoksa satır hover'da bir piksel zıplardı.
	card.mouse_entered.connect(func() -> void: card.theme_type_variation = &"LedgerRowHover")
	card.mouse_exited.connect(func() -> void: card.theme_type_variation = &"LedgerRow")
	card.gui_input.connect(_on_row_input.bind(emp.id, on_action, card))
	card.mouse_filter = Control.MOUSE_FILTER_STOP
	# Rol açıklaması satırdan tooltip'e taşındı (görev §2).
	card.tooltip_text = HRConstants.role_phase_hint(emp.role)

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	card.add_child(row)

	# --- ÇALIŞAN: ad + rol, tek hücrede iki satır ---
	var who := VBoxContainer.new()
	who.add_theme_constant_override("separation", 1)
	who.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var name_lbl := UiFactory.make_label(emp.character_name, &"RowName")
	who.add_child(name_lbl)
	who.add_child(UiFactory.make_label(
		UiTokens.tr_upper(HRConstants.role_label(emp.role)), &"MicroLabel"))
	row.add_child(who)

	# --- ÇIPLAK RAKAMLAR: eksen değerleri, başlıkları yukarıda ---
	var muted: bool = emp.status != HRConstants.STATUS_ACTIVE
	for pair in [[HRConstants.AXIS_EXPERTISE, W_EXPERTISE], [HRConstants.AXIS_PACE, W_PACE],
			[HRConstants.AXIS_RAPPORT, W_RAPPORT]]:
		row.add_child(_num(str(int(emp.role_stats.get(pair[0], 0))), int(pair[1]), muted))

	# --- DENEYİM: mini bar + % (onaylı [PROPOSAL] sütunu) ---
	row.add_child(_experience_cell(emp, refs))

	# --- DURUM çipleri ---
	row.add_child(_state_cell(emp, on_action))

	# --- MAAŞ ---
	row.add_child(_num(HRUiShared.money(emp.monthly_salary), W_SALARY, muted))

	# --- MORAL: bar + sayı (mevcut yerinde-boyama yolu korunuyor) ---
	var morale_cell := HRUiShared.morale_row(emp.morale, refs, false)
	morale_cell.custom_minimum_size = Vector2(W_MORALE, 0)
	morale_cell.size_flags_horizontal = Control.SIZE_SHRINK_END
	row.add_child(morale_cell)
	return card


## Boş departman satırı — mockup: kesikli kenar + "Henüz kimse yok" + satır içi hayalet.
static func empty_row(on_search: Callable) -> Control:
	var card := PanelContainer.new()
	card.theme_type_variation = &"EmptyRow"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var lbl := UiFactory.make_label(tr_key("HR_EMPTY_ROW"), &"EmptyRowLabel")
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(lbl)
	row.add_child(HRUiShared.action_button(tr_key("HR_SEARCH_START_INLINE"), on_search))
	card.add_child(row)
	return card


# --- hücreler ---------------------------------------------------------------

static func _head(text: String, width: int, align: int = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var l := UiFactory.make_label(text, &"ColumnHeader")
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	if width > 0:
		l.custom_minimum_size = Vector2(width, 0)
	else:
		l.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return l


static func _num(text: String, width: int, muted: bool) -> Label:
	var l := UiFactory.make_label(text, &"MetricValueInk")
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.custom_minimum_size = Vector2(width, 0)
	if muted:
		l.modulate = Color(1, 1, 1, 0.45)
	return l


## DENEYİM hücresi: 4px iz + amber dolgu + sağda yüzde. Dolu olduğunda amber
## metin, çünkü o an satır bir KARAR taşıyor (eğitime gönderilebilir).
static func _experience_cell(emp: Character, refs: Dictionary) -> Control:
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(W_EXPERIENCE, 0)
	box.add_theme_constant_override("separation", 3)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	var pct: int = int(round(
		float(emp.experience) / float(HRConstants.EXPERIENCE_MAX) * 100.0))
	var val := UiFactory.make_label(Fmt.percent(pct, 0), &"RowMeta")
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if emp.experience >= HRConstants.EXPERIENCE_MAX:
		val.add_theme_color_override("font_color", UiTokens.ACCENT)
	var bar := ProgressBar.new()
	bar.theme_type_variation = &"BuildProgress"
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(W_EXPERIENCE - 24, 4)
	bar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	bar.max_value = HRConstants.EXPERIENCE_MAX
	bar.value = emp.experience
	box.add_child(bar)
	box.add_child(val)
	refs["experience_bar"] = bar
	refs["experience_label"] = val
	return box


## DURUM sütunu: mockup'ın adsız 330'luk kolonu. En fazla bir çip + (uygunsa)
## EĞİTİME GÖNDER aksiyonu.
static func _state_cell(emp: Character, on_action: Callable) -> Control:
	var box := HBoxContainer.new()
	box.custom_minimum_size = Vector2(W_STATE, 0)
	box.add_theme_constant_override("separation", 6)
	box.alignment = BoxContainer.ALIGNMENT_CENTER

	# EDİLGENLİK önce: eğitim ve izin, satırın o gün ne YAPMADIĞINI söyler ve
	# dikkat rozetlerinden daha yüksek okunur.
	if emp.training_days_left > 0:
		box.add_child(_amber_chip(TranslationServer.translate("HR_STATE_TRAINING").format(
			{"days": emp.training_days_left})))
	elif emp.status == HRConstants.STATUS_ON_LEAVE:
		box.add_child(UiFactory.make_state_chip(tr_key("HR_STATE_ON_LEAVE"),
			UiTokens.INK_MUTED, UiTokens.NEUTRAL_BADGE_BG, UiTokens.BORDER_DISABLED))

	# Rozetler motorun türettiği tek kaynaktan gelir (HRSystem.badges_for): YENİ
	# bilgilendirici ve amber, gerisi dikkat çağrısı ve kırmızı.
	for badge_id in HRSystem.badges_for(emp):
		var bid: String = String(badge_id)
		var is_new: bool = bid == HRConstants.BADGE_NEW
		var text: String = UiTokens.tr_upper(HRConstants.badge_label(bid))
		if is_new:
			box.add_child(_amber_chip(text))
		else:
			box.add_child(UiFactory.make_state_chip(text,
				UiTokens.negative(), UiTokens.negative_bg(), UiTokens.negative_rule()))

	if CharacterRegistry.can_train(emp.id):
		var btn: Button = HRUiShared.action_button(tr_key("HR_TRAINING_SEND"), Callable())
		# Butonun KENDİSİ çapa: popover kendini ona göre konumluyor.
		btn.pressed.connect(func() -> void: on_action.call(emp.id, ACTION_TRAIN, btn))
		box.add_child(btn)
	return box


## Amber çip. Kehribar SEMANTİK DEĞİL (marka aksanı) ve renk körü modunda
## yerinde kalır, o yüzden sabit token'dan okunur.
static func _amber_chip(text: String) -> Control:
	return UiFactory.make_state_chip(text, UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT)


## Satır tıklaması = mevcut aksiyon popover'ı (görev §2: "per-employee actions stay
## in the existing row-click popover"). SÖZLEŞME `(emp_id, action, anchor)` — sıra
## ve çapa şart, yoksa popover kendini konumlandıramaz.
static func _on_row_input(ev: InputEvent, emp_id: String, on_action: Callable, anchor: Control) -> void:
	if ev is InputEventMouseButton and ev.pressed and ev.button_index == MOUSE_BUTTON_LEFT:
		on_action.call(emp_id, HREmployeeCard.ACTION_RAISE, anchor)


## Statik bağlamda çeviri: tr() bir Object ister, burada yok.
static func tr_key(key: String) -> String:
	return TranslationServer.translate(key)
