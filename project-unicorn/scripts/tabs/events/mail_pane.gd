extends ScrollContainer

# Gelen kutusunun okuma bölmesi: seçili öğeyi mail olarak okur. Künye (konu, tür, durum), konu,
# başlık (gönderen, alıcı, tarih), gövde, imza, kişi yazınca portre kuyusu; sonra kararın "Cevabın"
# bloğu, geçmişin "Seçimin" belgesi, mesajın tablosu ya da eylem satırı.
#
# Kip `populate(item, mode)`: "live" etkin karardır ve seçim yalnız orada EventGate.resolve'a gider;
# "preview" kâğıdın önizlemesidir (seçenekler gizli, Cevapla açar) ya da harness'ın çizdiği karttır
# (seçenekler görünür, tıklanmaz); "history" geçmiş karardır, gövdesi yalnız sabit metinse çizilir
# ({seam:} bugünün sayısını okurdu). Bağlam her kipte öğenin kendisidir, etkin kartın değil.
#
# Seçenek grameri: tek açık seçenek kurulu gelir (bedel kutusu ve amber düğme); birden çoğunda
# oyuncu önce kurar (tık ya da Enter), kurulu seçeneğin "Seç"i seçer, Vazgeç ya da Esc çözer. Karar
# açıldıktan ve seçenek kurulduktan sonra ENTER_GUARD_MS boyunca Enter sayılmaz. Kilitli seçenek
# etiketi ve kilidi soluk, gerekçesi okunur.

const INBOX := preload("res://scripts/ui/components/inbox.gd")
const ENTER_GUARD_MS := 400
const WELL := Vector2(256, 320)
const AVATAR := 40
const GLYPHS := {"up": "res://assets/icons/stake/cash_in.svg", "cost": "res://assets/icons/stake/cost.svg",
	"warn": "res://assets/icons/util/warn.svg", "pie": "res://assets/icons/stake/equity.svg"}
const CLOCK := "res://assets/icons/util/clock.svg"
const STAR := "res://assets/icons/util/star_full.svg"

var _item: Dictionary = {}
var _mode := ""
var _col: VBoxContainer
var _options: Array = []      # [{idx, box}] of the open options
var _armed := -1              # the armed open option's place in _options, -1 none
var _guard_ms := 0
var _done := false


func _ready() -> void:
	horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var pad := MarginContainer.new()
	pad.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pad.size_flags_vertical = Control.SIZE_EXPAND_FILL
	for side in ["left", "right"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_4XL)
	for side in ["top", "bottom"]:
		pad.add_theme_constant_override("margin_" + side, UiTokens.SPACE_3XL)
	add_child(pad)
	_col = VBoxContainer.new()
	_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_col.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	pad.add_child(_col)


func populate(item: Dictionary, mode: String) -> void:
	_item = item
	_mode = mode
	_options.clear()
	_armed = -1
	_done = false
	_guard_ms = Time.get_ticks_msec()
	UiFactory.clear(_col)
	scroll_vertical = 0
	if item.is_empty():
		_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_col.add_child(_empty())
		return
	_col.size_flags_vertical = Control.SIZE_FILL
	match String(item.kind):
		"reminder":
			_record()
		"message":
			_message()
		_:
			_card()


## Esc: an armed option is disarmed first.
func on_escape() -> bool:
	if _armed < 0 or _single():
		return false
	arm(-1)
	return true


## Enter arms the first open option, or chooses the armed one; ← → move the arm.
func on_key(key: Key) -> bool:
	if _options.is_empty() or _done:
		return false
	match key:
		KEY_ENTER, KEY_KP_ENTER:
			if Time.get_ticks_msec() - _guard_ms < ENTER_GUARD_MS:
				return true
			if _armed < 0:
				arm(0)
			else:
				_choose(int(_options[_armed].idx))
			return true
		KEY_LEFT, KEY_RIGHT:
			if not _single():
				arm(posmod(_armed + (1 if key == KEY_RIGHT else -1), _options.size()))
			return true
	return false


# --- The mail ------------------------------------------------------------------------------------

func _card() -> void:
	var ev: GameEvent = _item.event
	var kind: String = "MAIL_KIND_PAPER" if _item.get("paper", false) else "MAIL_KIND_DECISION"
	var state := ""
	var ink = null
	if _mode == "live":
		state = tr("TOPBAR_GATE")
		ink = UiTokens.D_ACCENT
	elif _item.kind == "paper":
		state = _within()
		ink = UiTokens.D_warn() if _item.expiring else null
	var static_body: bool = _mode != "history" or _static_body()
	var hour: int = GameState.current_hour if _mode == "live" and _item.hourly else -1
	_mail(_kicker(kind, state, ink), ev.title, INBOX.date_text(int(_item.day), hour),
		ev.body_text if static_body else "")
	if _mode == "history":
		_answered()
	elif _item.kind == "paper":
		_reply_head(false)
		_col.add_child(_paper_bar())
	else:
		_reply()


func _message() -> void:
	var m: Dictionary = _item.msg
	var a: Dictionary = m.args
	var kind: String = {"intro": "MAIL_KIND_MESSAGE", "rnd_discovery": "RND_DISCOVERY_TITLE"}.get(m.kind, "MAIL_KIND_REPORT")
	match String(m.kind):
		"intro":
			_mail(_kicker(kind), _item.subject, INBOX.date_text(int(m.day)), tr("MENTOR_INTRO_BODY"))
			_actions("", [[tr("MENTOR_INTRO_CTA"), _close, true]])
		"summary":
			_mail(_kicker(kind), _item.subject, INBOX.date_text(int(m.day)), "", _summary(a))
			_actions(SummarySystem.display(a).footer, [[tr("MAIL_CONTINUE"), _close, true]])
		"sales_week":
			_mail(_kicker(kind), _item.subject, INBOX.date_text(int(m.day)), "", _sales_report(a))
		"rnd_note":
			_mail(_kicker(kind), _item.subject, INBOX.date_text(int(m.day)), "\n\n".join(INBOX.note_lines(a)))
			_actions("", [[tr("RND_NOTE_GO_PRODUCT"), _go.bind("product"), false],
				[tr("RND_NOTE_GO_TREE"), _go.bind("rnd"), false]])
		"rnd_discovery":
			var node: String = String(a.node)
			_mail(_kicker(kind), _item.subject, INBOX.date_text(int(m.day)),
				RnDUiShared.t_or("PROD_RND_NODE_%s_DISCOVERY" % node.to_upper(), ""), _opened(node))
			_actions("", [[tr("RND_NOTE_GO_TREE"), _go.bind("rnd"), false],
				[tr("RND_NOTE_GO_PRODUCT"), _go.bind("product"), false]])


## The mail's top: kicker, subject, header, body, an extra block (a report's table) and the
## signature, beside the portrait well when a person writes.
func _mail(kicker: Control, subject: String, date: String, body: String, extra: Control = null) -> void:
	var from: Dictionary = _item.sender
	var top := HBoxContainer.new()
	top.add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	_col.add_child(top)
	var head := VBoxContainer.new()
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_theme_constant_override("separation", UiTokens.SPACE_XL)
	top.add_child(head)
	var lead := VBoxContainer.new()
	lead.add_theme_constant_override("separation", UiTokens.SPACE_M)
	lead.add_child(kicker)
	lead.add_child(_wrapped(subject, &"TitleH2"))
	head.add_child(lead)
	head.add_child(_header(from, date))
	head.add_child(HSeparator.new())
	if body != "":
		var rich := RichTextLabel.new()
		rich.theme_type_variation = &"PaneQuoteRich" if from.serif else &"PaneBodyRich"
		rich.bbcode_enabled = true
		rich.fit_content = true
		rich.scroll_active = false
		rich.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rich.text = _bbcode(body)
		head.add_child(rich)
	if extra != null:
		head.add_child(extra)
	if from.sig_name != "":
		head.add_child(_signature(from))
	if from.well and not from.gone:
		top.add_child(_well(from))


func _kicker(kind_key: String, state := "", ink = null) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(topic_pill(String(_item.topic)))
	row.add_child(UiFactory.make_label(tr(kind_key), &"MetaMuted"))
	if state != "":
		row.add_child(UiFactory.make_label("·", &"CaptionFaint"))
		row.add_child(UiFactory.make_label(state, &"MetaMuted", ink))
	return row


## Avatar, name and title; then the recipient and, in a column of its own, the date.
func _header(from: Dictionary, date: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	row.add_child(avatar(from, AVATAR))
	var lines := VBoxContainer.new()
	lines.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lines.alignment = BoxContainer.ALIGNMENT_CENTER
	lines.add_theme_constant_override("separation", 0)
	row.add_child(lines)
	var one := HBoxContainer.new()
	one.add_theme_constant_override("separation", UiTokens.SPACE_M)
	one.add_child(UiFactory.make_label(String(from.name), &"SenderName"))
	var title := UiFactory.make_label(String(from.title), &"MetaMuted")
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	one.add_child(title)
	if from.gone:
		title.text = "%s · %s" % [from.title, tr("MAIL_STAMP_LEFT")] if from.title != "" else tr("MAIL_STAMP_LEFT")
	lines.add_child(one)
	var two := HBoxContainer.new()
	two.add_theme_constant_override("separation", UiTokens.SPACE_M)
	if from.kind != "self":
		two.add_child(UiFactory.make_label(tr("MAIL_TO"), &"MetaMuted"))
		var to := UiFactory.make_label("%s · %s" % [CharacterRegistry.get_founder().character_name,
			GameState.company_name], &"KeyText")
		to.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		to.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		two.add_child(to)
	else:
		two.add_child(RnDUiShared.spacer())
	two.add_child(UiFactory.make_label(date, &"MetaMuted"))
	lines.add_child(two)
	return row


func _signature(from: Dictionary) -> VBoxContainer:
	var sig := VBoxContainer.new()
	sig.add_theme_constant_override("separation", UiTokens.SPACE_XXS)
	var rule := HSeparator.new()
	rule.custom_minimum_size.x = UiTokens.SPACE_3XL
	rule.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	sig.add_child(rule)
	sig.add_child(UiFactory.make_label(String(from.sig_name), &"TipTitle"))
	if from.sig_line != "":
		sig.add_child(UiFactory.make_label(String(from.sig_line), &"Caption"))
	return sig


func _well(from: Dictionary) -> PanelContainer:
	var well := PanelContainer.new()
	well.theme_type_variation = &"PortraitWell"
	well.custom_minimum_size = WELL
	well.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	var face: TextureRect
	if from.well_portrait != "":
		face = TextureRect.new()
		face.texture = load(String(from.well_portrait))
		face.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	else:
		face = UiFactory.make_bust(PersonBust.texture(from.look, int(WELL.y / 2)), false)
	face.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	face.clip_contents = true
	well.add_child(face)
	return well


# --- The reply -----------------------------------------------------------------------------------

## "Cevabın", and while the decision is live the permanence line.
func _reply_head(live: bool, key := "MAIL_REPLY") -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))
	row.add_child(RnDUiShared.spacer())
	if live:
		row.add_child(UiFactory.make_glyph("res://assets/icons/util/pause.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
		row.add_child(UiFactory.make_label(tr("EVENT_CHOICE_PERMANENT"), &"MetaMuted"))
	_col.add_child(row)


func _reply() -> void:
	var ev: GameEvent = _item.event
	var ctx: Dictionary = _item.ctx
	var readout: bool = ev.choices.size() == 1 and (ev.choices[0] as EventChoice).modifiers.is_empty()
	_reply_head(_mode == "live" and not readout)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_M)
	_col.add_child(box)
	var open: Array = []
	for i in ev.choices.size():
		if EventGate.condition_met((ev.choices[i] as EventChoice).unlock_condition, ctx):
			open.append(i)
	for i in ev.choices.size():
		var c: EventChoice = ev.choices[i]
		if not open.has(i):
			box.add_child(_locked(c, ctx))
			continue
		var holder := VBoxContainer.new()
		box.add_child(holder)
		_options.append({"idx": i, "box": holder})
	for k in _options.size():
		_paint_option(k)
	if open.size() == 1:
		_armed = 0
	if _item.get("from_desk", false):
		_col.add_child(_set_aside_foot())


func _single() -> bool:
	return _options.size() == 1


## Arms the open option at `k` (-1 disarms); the Enter guard starts over.
func arm(k: int) -> void:
	var was := _armed
	_armed = k
	_guard_ms = Time.get_ticks_msec()
	for j in [was, k]:
		if j >= 0:
			_paint_option(j)


## An open option: the single one and the armed one as a stake box, the rest as a bar.
func _paint_option(k: int) -> void:
	var holder: VBoxContainer = _options[k].box
	var idx: int = _options[k].idx
	var c: EventChoice = (_item.event as GameEvent).choices[idx]
	var parts: Array = []
	for m in c.modifiers:
		parts.append_array(EvChips.describe(m, _item.ctx, {}, false))
	UiFactory.clear(holder)
	var inert: bool = _mode != "live"
	if _single() or k == _armed:
		var box := PanelContainer.new()
		box.theme_type_variation = &"StakeBox" if _single() else &"OptionArmed"
		box.custom_minimum_size.y = UiTokens.D_H_STAKE
		holder.add_child(box)
		var col := VBoxContainer.new()
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		col.add_theme_constant_override("separation", UiTokens.SPACE_L)
		box.add_child(col)
		if not _single():
			var head := HBoxContainer.new()
			head.add_child(_wrapped(c.label, &"OptionLabel"))
			var back := Button.new()
			back.text = tr("HR_HOURS_CANCEL")
			back.theme_type_variation = &"GhostButtonSmall"
			back.focus_mode = Control.FOCUS_NONE
			back.pressed.connect(arm.bind(-1))
			head.add_child(back)
			col.add_child(head)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
		col.add_child(row)
		row.add_child(_stake(parts, not _single()))
		var pick := Button.new()
		pick.text = c.label if _single() else tr("MAIL_CHOOSE")
		pick.theme_type_variation = &"PrimaryButtonDarkLarge"
		pick.focus_mode = Control.FOCUS_NONE
		pick.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		pick.disabled = inert
		pick.pressed.connect(_choose.bind(idx))
		row.add_child(pick)
		return
	var bar := PanelContainer.new()
	bar.theme_type_variation = &"OptionBar"
	bar.custom_minimum_size.y = UiTokens.D_H_BTN_LG
	holder.add_child(bar)
	var line := HBoxContainer.new()
	line.add_theme_constant_override("separation", UiTokens.SPACE_L)
	bar.add_child(line)
	var label := UiFactory.make_label(c.label, &"OptionLabel")
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	line.add_child(label)
	line.add_child(_chips(parts))
	HRUiShared.set_mouse_ignore(line)
	if inert:
		return
	bar.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	bar.mouse_entered.connect(func() -> void: bar.theme_type_variation = &"OptionBarHover")
	bar.mouse_exited.connect(func() -> void: bar.theme_type_variation = &"OptionBar")
	bar.gui_input.connect(func(e: InputEvent) -> void:
		if UiFactory.is_left_click(e):
			arm(k))


## The parts with a figure large, each over its key; the sentences as chips after them.
func _stake(parts: Array, armed: bool) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	var words: Array = []
	for p in parts:
		if String(p.value) == "":
			words.append(p)
			continue
		if row.get_child_count() > 0:
			row.add_child(VSeparator.new())
		var cell := VBoxContainer.new()
		cell.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		cell.add_child(UiFactory.make_label(String(p.label), &"MetaMuted"))
		var fig := HBoxContainer.new()
		fig.add_theme_constant_override("separation", UiTokens.SPACE_M)
		var ink: Color = _ink(String(p.polarity))
		if GLYPHS.has(p.glyph):
			fig.add_child(UiFactory.make_glyph(GLYPHS[p.glyph], UiTokens.SPACE_3XL, ink))
		fig.add_child(UiFactory.make_label(String(p.value), &"PartValueArmed" if armed else &"PartValue", ink))
		cell.add_child(fig)
		row.add_child(cell)
	if not words.is_empty():
		row.add_child(_chips(words))
	return row


func _chips(parts: Array) -> HFlowContainer:
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_M)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_M)
	for p in parts:
		flow.add_child(chip(p))
	return flow


## One part as a chip: its glyph and words in its polarity's ink; danger on its own ground.
static func chip(p: Dictionary) -> PanelContainer:
	var box := PanelContainer.new()
	var danger: bool = p.polarity == "danger"
	box.theme_type_variation = UiTokens.D_variation(&"FxChipDanger") if danger else &"FxChip"
	box.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	box.add_child(row)
	var ink: Color = UiTokens.D_neg_ink() if danger else _ink(String(p.polarity))
	if GLYPHS.has(p.glyph):
		row.add_child(UiFactory.make_glyph(GLYPHS[p.glyph], UiTokens.D_ICON_PART,
			UiTokens.D_INK_3 if p.polarity == "cost" else (UiTokens.D_neg() if danger else ink)))
	row.add_child(UiFactory.make_label(EvChips.text(p), &"KeyText", ink))
	return box


## A part's ink: gain green, danger red, a cost and a neutral part in ink.
static func _ink(polarity: String) -> Color:
	return {"gain": UiTokens.D_pos(), "danger": UiTokens.D_neg()}.get(polarity, UiTokens.D_INK_2)


func _locked(c: EventChoice, ctx: Dictionary) -> PanelContainer:
	var bar := PanelContainer.new()
	bar.theme_type_variation = &"OptionBarLocked"
	bar.custom_minimum_size.y = UiTokens.D_H_BTN_LG
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	bar.add_child(row)
	row.add_child(UiFactory.make_glyph("res://assets/icons/util/lock.svg", UiTokens.D_ICON_ROW, UiTokens.D_INK_OFF))
	var label := UiFactory.make_label(c.label, &"OptionLabelLocked")
	label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(label)
	row.add_child(RnDUiShared.spacer())
	# The live reason wins over the authored one: the condition tree knows which clause failed;
	# the authored line covers two failing at once, which one sentence cannot explain.
	var reason: String = EventGate.condition_reason(c.unlock_condition, ctx)
	reason = tr(reason) if reason != "" else c.unlock_reason_text
	var why := UiFactory.make_label(reason if reason != "" else tr("LOCK_CHIP"), &"MetaMuted")
	why.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(why)
	return bar


func _choose(idx: int) -> void:
	if _done or _mode != "live":
		return
	_done = true
	EventGate.resolve(String(_item.event_id), idx)


## The paper's clock and Cevapla, which opens it (the clock stops); refused while a decision is up.
func _paper_bar() -> PanelContainer:
	var bar := PanelContainer.new()
	bar.theme_type_variation = &"PaperBar"
	bar.custom_minimum_size.y = UiTokens.D_H_BTN_LG + UiTokens.SPACE_XL
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	bar.add_child(row)
	var ink: Color = UiTokens.D_warn() if _item.expiring else UiTokens.D_INK_2
	row.add_child(UiFactory.make_glyph(CLOCK, UiTokens.D_ICON_BUTTON, ink))
	var left := UiFactory.make_label(_within(), &"DataStrong", ink)
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(left)
	row.add_child(RnDUiShared.spacer())
	var blocked: bool = EventGate.active_id() != ""
	if blocked:
		var why := UiFactory.make_label(tr("GATE_ANSWER_FIRST"), &"MetaMuted")
		why.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		row.add_child(why)
	var go := Button.new()
	go.text = tr("MAIL_RESPOND")
	go.icon = load("res://assets/icons/util/reply.svg")
	go.theme_type_variation = &"PrimaryButtonDark"
	go.focus_mode = Control.FOCUS_NONE
	go.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	go.disabled = blocked or _mode == "history"
	go.pressed.connect(func() -> void: EventGate.open_paper(String(_item.key)))
	row.add_child(go)
	return bar


## An opened paper goes back on the desk with Esc, its clock still running.
func _set_aside_foot() -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	var back := Button.new()
	back.text = tr("MAIL_SET_ASIDE")
	back.theme_type_variation = &"GhostButtonSmall"
	back.focus_mode = Control.FOCUS_NONE
	back.pressed.connect(func() -> void: EventGate.set_aside())
	row.add_child(back)
	row.add_child(UiFactory.D_tag(tr("MAIL_KEY_ESC"), &"outline"))
	row.add_child(RnDUiShared.spacer(UiTokens.SPACE_XL))
	row.add_child(UiFactory.make_glyph(CLOCK, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	row.add_child(UiFactory.make_label(_within(), &"MetaMuted"))
	return row


func _within() -> String:
	var weeks: int = int(_item.get("weeks_left", 0))
	return tr("MAIL_FINAL_WEEK") if _item.get("expiring", false) or weeks <= 1 \
		else tr(Fmt.count_key("MAIL_WITHIN", weeks)).format({"n": weeks})


## A past decision: the option chosen and what it did, stamped.
func _answered() -> void:
	if not _item.expired:
		_reply_head(false, "MAIL_YOUR_CHOICE")
	var box := PanelContainer.new()
	box.theme_type_variation = &"NoteBox"
	_col.add_child(box)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_3XL)
	box.add_child(row)
	var col := VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(col)
	if not _item.expired:
		col.add_child(UiFactory.make_label(String(_item.option), &"OptionLabel"))
	var row_data: Dictionary = _item.row
	var parts: Array = []
	for d in row_data.deltas:
		parts.append_array(EvChips.describe(d, row_data.entities, row_data.get("names", {}), true))
	col.add_child(_chips(parts))
	row.add_child(stamp(String(_item.stamp), int(GameState.get_date_dict(int(_item.day)).week)))


## "CEVAPLANDI H11", tilted as a stamp is.
static func stamp(key: String, week: int) -> Control:
	return UiFactory.D_stamp(TranslationServer.translate("MAIL_STAMP_AT").format(
		{"stamp": Fmt.upper(TranslationServer.translate(key)), "week": week}))


## A history row's body is drawn again only when it is plain text: a {seam:} would read today.
func _static_body() -> bool:
	var body: Variant = EvPresenter.text_block(EventGate.catalogue_card(String(_item.event_id))).get("body", "")
	return body is String and not String(body).contains("{seam:")


# --- Messages ------------------------------------------------------------------------------------

func _summary(p: Dictionary) -> VBoxContainer:
	var d: Dictionary = SummarySystem.display(p)
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(UiFactory.make_label("%s · %s" % [d.range, d.phase_name], &"MetaMuted"))
	var table := VBoxContainer.new()
	table.add_theme_constant_override("separation", 0)
	col.add_child(table)
	for r in [["FIN_CAP_MRR", p.mrr, true], ["MONTH_ROW_CASH", p.cash, true],
			["SUMMARY_ROW_TEAM_FOUNDER", p.team, false], ["MONTH_ROW_BRAND", p.brand, false]]:
		var from: int = int(r[1].from)
		var to: int = int(r[1].to)
		var text: String = "%s  →  %s" % [Fmt.money_chip(from), Fmt.money_chip(to)] if r[2] else "%d  →  %d" % [from, to]
		var delta: String = INBOX.signed_money(to - from) if r[2] else ("±0" if to == from else "%+d" % (to - from))
		_summary_row(table, tr(r[0]), text, delta, UiTokens.D_delta_color(to - from))
	var artida: bool = int(p.cash.to) >= 0 and int(p.net) >= 0
	_summary_row(table, tr("FIN_RUNWAY"), d.runway_text, "", UiTokens.D_pos() if artida else UiTokens.D_INK_2)
	var note := PanelContainer.new()
	note.theme_type_variation = &"NoteBox"
	var hl := HBoxContainer.new()
	hl.add_theme_constant_override("separation", UiTokens.SPACE_L)
	hl.add_child(UiFactory.make_label(Fmt.upper(String(d.caption)), &"KeyLabel"))
	hl.add_child(_wrapped(String(d.highlight), &"DataText"))
	note.add_child(hl)
	col.add_child(note)
	if String(d.frank_line) != "":
		var frank := HBoxContainer.new()
		frank.add_theme_constant_override("separation", UiTokens.SPACE_L)
		frank.add_child(avatar(INBOX.frank(), UiTokens.SPACE_3XL))
		frank.add_child(_wrapped(String(d.frank_line), &"FrankQuote"))
		col.add_child(frank)
	return col


func _summary_row(table: VBoxContainer, label: String, values: String, delta: String, ink: Color) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size.y = UiTokens.D_H_ROW
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var name := UiFactory.make_label(label, &"DataText")
	name.custom_minimum_size.x = UiTokens.SPACE_4XL * 5
	row.add_child(name)
	var v := UiFactory.make_label(values, &"DataStrong", ink if delta == "" else null)
	v.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(v)
	if delta != "":
		row.add_child(UiFactory.make_label(delta, &"DataMedium", ink))
	for c in row.get_children():
		c.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	table.add_child(row)
	table.add_child(HSeparator.new())


func _sales_report(a: Dictionary) -> VBoxContainer:
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	col.add_child(UiFactory.make_label(tr("MAIL_RPT_CLOSED"), &"BodyLabel"))
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_4XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_L)
	col.add_child(grid)
	for key in ["MAIL_RPT_CUSTOMER", "MAIL_RPT_STARS", "MAIL_RPT_SEATS", "MAIL_RPT_PRICE", "FIN_CAP_MRR"]:
		grid.add_child(UiFactory.make_label(Fmt.upper(tr(key)), &"KeyLabel"))
	var total: int = 0
	for r in a.rows:
		total += int(r.mrr)
		var company := UiFactory.make_label(String(r.company), &"DataStrong")
		company.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(company)
		var stars := HBoxContainer.new()
		stars.add_theme_constant_override("separation", UiTokens.SPACE_XS)
		stars.add_child(UiFactory.make_label(str(int(r.star)), &"DataText"))
		stars.add_child(UiFactory.make_glyph(STAR, UiTokens.D_ICON_PART, UiTokens.D_INK_3))
		grid.add_child(stars)
		grid.add_child(UiFactory.make_label(str(int(r.seats)), &"DataText"))
		grid.add_child(UiFactory.make_label(Fmt.money_exact(int(r.price)), &"DataText"))
		grid.add_child(UiFactory.make_label("+" + Fmt.money_exact(int(r.mrr)) + tr("SALES_PER_MONTH"),
			&"DataText", UiTokens.D_pos()))
	var foot := HBoxContainer.new()
	foot.add_theme_constant_override("separation", UiTokens.SPACE_4XL)
	foot.add_child(UiFactory.make_label(tr("SALES_WEEKLY_TOTAL").format({"n": a.rows.size(),
		"mrr": Fmt.money_exact(total)}), &"KeyText"))
	foot.add_child(UiFactory.make_label(tr("MAIL_RPT_BOOKS").format({"n": int(a.accounts)}), &"KeyText"))
	col.add_child(foot)
	return col


## What a finished research opened (§5.8): no money, no chip, only the door.
func _opened(node: String) -> PanelContainer:
	var parts: PackedStringArray = []
	var unlock: String = RnDUiShared.t_or("PROD_RND_NODE_%s_UNLOCK" % node.to_upper(), "")
	if unlock != "":
		parts.append(unlock)
	if ResearchTree.children_of(node).size() == 2:
		parts.append(tr("RND_COMPLETED_UNLOCKED_TWO"))
	var box := PanelContainer.new()
	box.theme_type_variation = &"NoteBox"
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_M)
	box.add_child(col)
	col.add_child(_wrapped("%s %s" % [tr("RND_OPENED_PREFIX"), " · ".join(parts)], &"DataText"))
	var line_id: String = ResearchTree.opens_line_of(node)
	if line_id != "":
		var line_name: String = RnDUiShared.t_or(ProductLines.line_name_key(line_id), "") \
			if ResearchTree.hidden_line_authored(line_id) else ""
		col.add_child(_wrapped(tr("RND_HIDDEN_LINE_OPENED").format({"line": line_name}) if line_name != ""
			else tr("RND_EA_LINE_NOTE"), &"MetaMuted"))
	return box


# --- Reminders -----------------------------------------------------------------------------------

## A reminder reads as a record: who, its state, the facts, and where to attend to it.
func _record() -> void:
	_col.add_child(_kicker("MAIL_KIND_ATTENTION"))
	var from: Dictionary = _item.sender
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", UiTokens.SPACE_L)
	_col.add_child(head)
	var person: bool = _item.has("customer") or _item.has("employee")
	if person:
		head.add_child(avatar(from, AVATAR + UiTokens.SPACE_M))
	head.add_child(UiFactory.make_label(String(from.name) if person else String(_item.subject), &"TitleH2"))
	if _item.has("state"):
		head.add_child(UiFactory.D_tag(String(_item.state), &"risk" if _item.risk else &""))
	if _item.has("customer"):
		var c: Customer = CustomerRegistry.get_customer(String(_item.customer))
		var months: int = int(TimeModel.months(GameState.day - c.acquired_on_day))
		_col.add_child(_facts([[tr("FIN_CAP_MRR"), Fmt.money_chip(c.mrr) + tr("SALES_PER_MONTH")],
			[tr("MAIL_RPT_SEATS"), str(c.seats)], [tr("REC_SATISFACTION"), str(c.satisfaction)],
			[tr("MAIL_RPT_CUSTOMER"), tr("REC_TENURE").format({"n": months})]]))
		_col.add_child(UiFactory.make_label(String(_item.line), &"DataText"))
		var am: Character = CharacterRegistry.get_character(c.assigned_to)
		_col.add_child(UiFactory.make_label(tr("SALES_STEWARD").format(
			{"name": am.character_name if am != null else tr("REC_AM_NONE")}), &"DataText"))
	elif _item.has("employee"):
		_col.add_child(_facts([[tr("HR_COL_MORALE"), str(int(_item.morale))]]))
		_col.add_child(UiFactory.make_label(String(_item.line), &"DataText"))
	var request: String = String(_item.get("request", ""))
	var go: Callable = _attend.bind(request) if request != "" else _go.bind(String(_item.tab), String(_item.subpage))
	if _item.has("employee"):
		go = func() -> void: get_tree().call_group(&"window_layer", &"open_detail", "hr_dossier",
			{"character_id": String(_item.employee)})
	_actions("", [[tr("SALES_ACTION_EXPAND" if _item.get("grow", false) else "SALES_ACTION_RETAIN"), go, true]],
		request != "" and EventGate.active_id() != "")


func _facts(rows: Array) -> PanelContainer:
	var box := PanelContainer.new()
	box.theme_type_variation = &"NoteBox"
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 0)
	box.add_child(row)
	for f in rows:
		row.add_child(UiFactory.D_kpi(String(f[0]), String(f[1])))
	return box


## The card about this subject, as the Sales tab's button names it.
func _attend(event_id: String) -> void:
	EventGate.request(event_id, {"customer": String(_item.customer)})


# --- Shared --------------------------------------------------------------------------------------

## The one action row: a note on the left, the buttons on the right, the primary last.
func _actions(note: String, buttons: Array, blocked := false) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_L)
	var left := UiFactory.make_label(tr("GATE_ANSWER_FIRST") if blocked else note, &"MetaMuted")
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	row.add_child(left)
	for b in buttons:
		var btn := Button.new()
		btn.text = String(b[0])
		btn.theme_type_variation = &"PrimaryButtonDark" if b[2] else &"Button"
		btn.focus_mode = Control.FOCUS_NONE
		btn.disabled = blocked
		btn.pressed.connect(b[1])
		row.add_child(btn)
	_col.add_child(row)


func _go(tab: String, subpage := "") -> void:
	EventBus.tab_changed.emit(tab)
	if subpage != "":
		EventBus.finance_subpage_requested.emit(subpage)


func _close() -> void:
	EventBus.tab_changed.emit("")


func _empty() -> CenterContainer:
	var center := CenterContainer.new()
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var col := VBoxContainer.new()
	col.add_theme_constant_override("separation", UiTokens.SPACE_L)
	center.add_child(col)
	var glyph := UiFactory.make_glyph("res://assets/icons/util/mail_open.svg", UiTokens.SPACE_3XL, UiTokens.D_INK_4)
	glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	col.add_child(glyph)
	col.add_child(UiFactory.make_label(tr("INBOX_PANE_EMPTY"), &"MetaMuted"))
	return center


## A sender's face at `px`: Frank's disc, a person's bust, or a box with initials or a glyph.
static func avatar(from: Dictionary, px: int) -> Control:
	var face: Control
	if from.portrait != "" and px <= AVATAR:
		face = UiFactory.make_mentor_avatar(px)
	elif not (from.look as Dictionary).is_empty():
		face = UiFactory.make_person_avatar(String(from.name), from.look, px)
	else:
		face = PanelContainer.new()
		face.theme_type_variation = &"MonoBox"
		face.custom_minimum_size = Vector2(px, px)
		face.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		var mark: Control = UiFactory.make_glyph(String(from.glyph), UiTokens.D_ICON_CONTROL, UiTokens.D_INK_3) \
			if from.glyph != "" else UiFactory.make_label(String(from.mono), &"CaptionStrong",
				from.ink if from.ink.a > 0.0 else null)
		mark.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		mark.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		face.add_child(mark)
	if from.gone:
		face.modulate = Color(Color.WHITE, UiTokens.D_GONE_ALPHA)
	return face


## A topic's pill in its hue (the colour-blind palette's when it is on).
static func topic_pill(key: String) -> Label:
	var pill := UiFactory.make_label(Fmt.upper(TranslationServer.translate(key)), &"TopicPill")
	var hue: Color = UiTokens.D_topic(key) if UiTokens.D_TOPICS.has(key) else UiTokens.D_INK_3
	pill.add_theme_color_override("font_color", hue)
	# The theme's box is reachable once the pill is in the tree.
	pill.ready.connect(func() -> void:
		var box: StyleBoxFlat = pill.get_theme_stylebox("normal").duplicate()
		box.bg_color = Color(hue, UiTokens.D_PILL_FILL_ALPHA)
		box.border_color = hue
		pill.add_theme_stylebox_override("normal", box))
	pill.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	pill.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return pill


static func _wrapped(text: String, variation: StringName) -> Label:
	var label := UiFactory.make_label(text, variation)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return label


## Markdown's bold and italic as BBCode; a blank line between paragraphs is the theme's
## paragraph gap.
static func _bbcode(text: String) -> String:
	var bold := RegEx.create_from_string("\\*\\*(.+?)\\*\\*")
	var italic := RegEx.create_from_string("\\*(.+?)\\*")
	var gaps := RegEx.create_from_string("\\n{2,}")
	return gaps.sub(italic.sub(bold.sub(text, "[b]$1[/b]", true), "[i]$1[/i]", true), "\n", true)
