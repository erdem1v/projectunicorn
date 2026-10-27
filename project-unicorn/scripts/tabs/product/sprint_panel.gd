class_name SprintPanel
extends HBoxContainer

# Ürün sekmesinin orta (bu sprint) ve sağ (sonraki sprint) sütunları. Yalnız modeli çizer: izin ve eşikler modelden gelir, her tık
# sekmeye `action` olarak çıkar. Orta sütunun başlığı (sprint başlığı ve kapasite), panosunun başlığı ve alt şeridi sabit, arada
# panonun gövdesi kayar; sağ sütun (`SprintNext`) kendi içinde kayar. Saat ilerleyince `set_now` panoyu, kapasiteyi ve ilerlemeyi
# sayfa kurulmadan günceller.

signal action(kind: String, args: Dictionary)

const PAUSE := "res://assets/icons/util/pause.svg"
const TEAM_GLYPH := "res://assets/icons/rail/hr.svg"
## Devreden kartın ilerleme karesi 5 puandır: K3 sekiz kare tutar.
const SQUARE_POINTS := 5.0


## Orta sütun: başlık ve alt sabit, arada gövde. Alt şerit ilk istendiğinde kurulur.
class Column extends PanelContainer:
	var head := SprintUiShared.column(UiTokens.SPACE_L)
	var stack := SprintUiShared.column(UiTokens.SPACE_M)
	var _col := SprintUiShared.column(0)
	var _foot: VBoxContainer

	func _init() -> void:
		theme_type_variation = &"SprintColumn"
		size_flags_horizontal = Control.SIZE_EXPAND_FILL
		add_child(_col)
		_col.add_child(SprintUiShared.pad(head, Vector4i(UiTokens.SPACE_L, UiTokens.SPACE_XL, UiTokens.SPACE_L, 0)))
		stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
		var body := SprintUiShared.pad(stack, Vector4i(UiTokens.SPACE_L, UiTokens.SPACE_M, UiTokens.SPACE_L, 0))
		body.size_flags_vertical = Control.SIZE_EXPAND_FILL
		_col.add_child(body)

	func foot() -> VBoxContainer:
		if _foot == null:
			var band := PanelContainer.new()
			band.theme_type_variation = &"SprintColumnFoot"
			band.custom_minimum_size.y = UiTokens.D_H_FOOT
			_foot = SprintUiShared.column(UiTokens.SPACE_XL)
			_foot.alignment = BoxContainer.ALIGNMENT_CENTER
			band.add_child(_foot)
			_col.add_child(band)
		return _foot


var _capacity: CapacityView
var _board: SprintBoard
var _foot: SprintFoot
var _next: SprintNext
var _running := false
## Koşan sprintte kartların bilinen yükü: ilerleme yüzdesinin paydası.
var _known: Array = []


func _init() -> void:
	add_theme_constant_override("separation", UiTokens.SPACE_XL)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL


## Yeniden kurulumda panonun ve sağ sütunun kaydırma yeri korunur.
func setup(model: Dictionary) -> void:
	var board_at: int = _board.scroll.scroll_vertical if _board != null else 0
	var next_at: int = _next.scroll_vertical if _next != null else 0
	UiFactory.clear(self)
	_capacity = null
	_board = null
	_foot = null
	_next = null
	_running = false
	_known = []
	_center(model)
	_next = SprintNext.new()
	_next.action.connect(action.emit)
	_next.setup(model)
	add_child(_next)
	if _board != null:
		SprintUiShared.keep_scroll(_board.scroll, board_at)
	SprintUiShared.keep_scroll(_next, next_at)


## Üstüne gelinen adayın hayaleti kapasitede ve panoda: sayfa kurulmaz (kimlik boşsa hayalet kalkar).
func set_ghost(card_id: String) -> void:
	if _capacity != null:
		_capacity.set_ghost(ProductModel.ghost_effort(card_id) if card_id != "" else {})
	if _board != null:
		_board.set_ghost(card_id)


## Koşan sprint var mı: saat ilerleyince `set_now` ancak o zaman bir şey günceller.
func running() -> bool:
	return _running


## Saat ilerleyince (koşan sprintte) şimdiki an çizgisi, koşan çubuklar ve yüzleri, kapasitenin "yapılan" dolgusu ve alt şeridin
## ilerlemesi sayfa kurulmadan, saklanan parçalardan güncellenir.
func set_now(at: float) -> void:
	_board.set_now(at)
	var stages: Array = _board.stage_lists()
	_capacity.set_done(ProductModel.stage_done(stages, at))
	_foot.set_progress(ProductModel.progress_at(stages, _known, at))


func _center(model: Dictionary) -> void:
	var c: Dictionary = model.center
	var col := Column.new()
	add_child(col)
	if c.mode == "release":
		_release(col, c, model.next.sprint)
		return
	if c.sprint < 0:
		return
	var head := SprintHead.new()
	head.action.connect(action.emit)
	head.setup(model)
	col.head.add_child(head)
	_capacity = CapacityView.new()
	_capacity.action.connect(action.emit)
	_capacity.setup(model)
	col.head.add_child(_capacity)

	_running = c.mode == "active"
	_board = SprintBoard.new()
	_board.action.connect(action.emit)
	_board.setup(model, _nobody(c) if c.team_empty and c.cards.is_empty() else null)
	col.stack.add_child(_board)

	if _running:
		_known = c.progress.known
	_foot = SprintFoot.new()
	_foot.action.connect(action.emit)
	_foot.setup(c)
	col.foot().add_child(_foot)


## Kimse çalışamıyorken sütunun gövdesi: ekip glifi, not ve çıkış yolu.
func _nobody(c: Dictionary) -> VBoxContainer:
	var empty := SprintUiShared.column(UiTokens.SPACE_L)
	empty.alignment = BoxContainer.ALIGNMENT_CENTER
	empty.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var glyph := UiFactory.make_glyph(TEAM_GLYPH, UiTokens.D_ICON_EMPTY, UiTokens.D_INK_4)
	glyph.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	empty.add_child(glyph)
	var note := UiFactory.make_label(tr("HR_EMPTY_ROW"), &"NoteMuted")
	note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty.add_child(note)
	var go := SprintUiShared.way_out(c, &"SecondaryButton", action.emit)
	go.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	empty.add_child(go)
	return empty


## Sürüm notu: sprint kapanınca orta sütunun yerini alır; açıkken oyun durur.
func _release(col: Column, c: Dictionary, next_sprint: int) -> void:
	var r: Dictionary = c.release
	var head := SprintUiShared.box(UiTokens.SPACE_M)
	head.custom_minimum_size.y = UiTokens.D_H_FX
	head.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_RELEASE_NOTE")), &"KeyLabel"))
	head.add_child(SprintUiShared.label(tr("PRODUCT_SPRINT_END").format({"n": c.sprint}), &"MetaMuted"))
	col.head.add_child(head)

	# MVP'ye varan kapanış kapıdır: v1.0 hazır, yayın oyuncunun. Öncesindeki kapanış sürüm çıkarmaz:
	# başlığın altında sürüm koşulu, notta v1.0'a kalan kart.
	if r.gate:
		col.stack.add_child(SprintUiShared.label(tr("PRODUCT_GATE_TITLE").format(c.mvp), &"ReleaseValue"))
		col.stack.add_child(SprintUiShared.prose(tr("PRODUCT_GATE_BODY").format(c.mvp), &"DataText"))
	elif c.mvp != null:
		col.head.add_child(_mvp_rule(c.mvp))
		var left: int = c.mvp.need - c.mvp.done
		col.stack.add_child(SprintUiShared.label(tr(Fmt.count_key("PRODUCT_MVP_LEFT", left)).format(
			{"n": left, "version": c.mvp.version}), &"DataText"))
	elif r.version == "":
		col.stack.add_child(SprintUiShared.label(tr("PRODUCT_NO_RELEASE"), &"DataText"))
	else:
		var version := SprintUiShared.box(UiTokens.SPACE_XXL)
		version.add_child(SprintUiShared.label(String(r.version), &"ReleaseValue"))
		version.add_child(UiFactory.D_stamp(Fmt.upper(tr("PRODUCT_LIVE"))))
		col.stack.add_child(version)

	if not r.shipped.is_empty():
		col.stack.add_child(SprintUiShared.section("PRODUCT_SHIPPED"))
	for card in r.shipped:
		var row := _release_row(col.stack, card.kind, card.name)
		row.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_pos()))
		var pts := SprintUiShared.label(str(card.effort), &"PtsBoxRaised")
		pts.custom_minimum_size.x = UiTokens.D_W_PTS
		pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row.add_child(pts)

	if not r.carried.is_empty():
		col.stack.add_child(SprintUiShared.section("PRODUCT_CARRIED_OVER"))
	for item in r.carried:
		var row := _release_row(col.stack, item.kind, item.name)
		# Biten puan dolu, kalan boş kare: devreden kart ilerlemesiyle taşınır.
		row.add_child(SprintUiShared.squares(float(item.done) / SQUARE_POINTS, UiTokens.D_SQUARE_SM, UiTokens.D_BAR_EMPH,
			ceili(float(item.total) / SQUARE_POINTS)))
		row.add_child(UiFactory.make_glyph(SprintUiShared.ARROW, UiTokens.D_ICON_PART, UiTokens.D_INK_4))
		row.add_child(SprintUiShared.label(tr("PRODUCT_TAG_SPRINT").format({"n": item.to_sprint}), &"KeyText"))

	var v: Dictionary = r.velocity
	var pts := {"done": SprintUiShared.points(v.done), "total": SprintUiShared.points(v.total)}
	var speed := SprintUiShared.box(UiTokens.SPACE_L)
	speed.add_child(SprintUiShared.label("%s/%s" % [pts.done, pts.total], &"FigureValue"))
	speed.add_child(SprintUiShared.prose(tr(SprintUiShared.points_key("PRODUCT_VELOCITY_LINE", pts.total)).format(pts),
		&"MetaMuted"))
	var rows: Array = [["PRODUCT_VELOCITY", speed]]
	if r.result != null:
		rows.append(["PRODUCT_RESULT", SprintUiShared.result_line(r.result, &"DataText")])
	if not r.press.is_empty():
		var press := SprintUiShared.box(UiTokens.SPACE_S)
		press.add_child(SprintUiShared.label(tr(r.press.outlet), &"DataStrong", UiTokens.D_outlet(r.press.outlet)))
		press.add_child(SprintUiShared.prose(SprintUiShared.SEP.strip_edges() + " " + String(r.press.text), &"DataText"))
		rows.append(["PRODUCT_PRESS", press])
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", UiTokens.SPACE_XL)
	grid.add_theme_constant_override("v_separation", UiTokens.SPACE_L)
	for pair in rows:
		var key := UiFactory.make_label(Fmt.upper(tr(pair[0])), &"KeyLabel")
		key.custom_minimum_size.x = UiTokens.D_W_RESULT_KEY
		grid.add_child(key)
		pair[1].size_flags_horizontal = Control.SIZE_EXPAND_FILL
		grid.add_child(pair[1])
	col.stack.add_child(SprintUiShared.pad(grid, Vector4i(0, UiTokens.SPACE_L, 0, UiTokens.SPACE_M)))
	if not r.reviews.is_empty():
		col.stack.add_child(SprintUiShared.section("PRODUCT_REVIEWS"))
		for review in r.reviews:
			var line := SprintUiShared.box(UiTokens.SPACE_L)
			line.add_child(SprintUiShared.prose(review.text, &"DataText"))
			line.add_child(SprintUiShared.label(review.source, &"MetaMuted", UiTokens.D_INK_3))
			col.stack.add_child(line)
	if r.rnd_open:
		var rnd := _note(RnDUiShared.ICON, tr("PRODUCT_RELEASE_RND_OPEN"), UiTokens.D_INK_2)
		rnd.add_child(SprintUiShared.button(tr("PRODUCT_GO_RND"), &"FloatLink", action.emit.bind("rnd", {"node": ""})))
		col.stack.add_child(rnd)
	col.stack.add_child(_lead_row(r.lead))

	var hold := _note(PAUSE, tr("PRODUCT_RELEASE_HOLD"), UiTokens.D_INK_3)
	hold.size_flags_horizontal = Control.SIZE_SHRINK_END
	col.foot().add_child(hold)
	var plan_next := action.emit.bind("plan_next", {"sprint": next_sprint})
	col.foot().add_child(_foot_row([
		SprintUiShared.button(tr("PRODUCT_GATE_ONE_MORE"), &"SecondaryButton", plan_next),
		SprintUiShared.button(tr("PROD_SHIP_PUBLISH"), &"PrimaryButtonDark", action.emit.bind("publish", {})),
	] if r.gate else [SprintUiShared.button(tr("PRODUCT_PLAN_SPRINT").format({"n": next_sprint}), &"PrimaryButtonDark",
		plan_next)]))


## Sürüm notunun satırı: tür glifi ve ad; sağ ucu çağıran doldurur.
func _release_row(box: VBoxContainer, kind: String, card_name: String) -> HBoxContainer:
	var row_panel := PanelContainer.new()
	row_panel.theme_type_variation = &"TableRow"
	row_panel.custom_minimum_size.y = UiTokens.D_H_ROW_RELEASE
	var row := SprintUiShared.box(UiTokens.SPACE_M)
	row_panel.add_child(row)
	row.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % kind, UiTokens.D_ICON_ROW, UiTokens.D_INK_3))
	var title := SprintUiShared.label(card_name, &"DataText")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(title)
	box.add_child(row_panel)
	return row


## Sürüm notundaki lider cümlesi: yüz, anahtar ve ad, cümle. Lider kurucunun kendisiyse not onundur: "Kendi notun", ad
## yazılmaz.
func _lead_row(lead: Dictionary) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(SprintUiShared.avatar(lead, UiTokens.D_AVATAR_ROW))
	var words := SprintUiShared.column(UiTokens.SPACE_XXS)
	words.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var caption := SprintUiShared.box(UiTokens.SPACE_S)
	caption.add_child(SprintUiShared.label(Fmt.upper(tr("PRODUCT_LEAD_TIP_SELF" if lead["self"] else "PRODUCT_LEAD_LINE")), &"KeyLabel"))
	if not lead["self"]:
		caption.add_child(SprintUiShared.label(String(lead.name), &"KeyText"))
	words.add_child(caption)
	words.add_child(SprintUiShared.prose(String(lead.text), &"DataText"))
	row.add_child(words)
	return row


## Sürüm koşulu: "v1.0 = 3 Çekirdek kartı · 1/3 bitti · tahmin Sprint 3 sonu (Hafta 6)"; motorun tahmini
## yoksa yalnız koşul.
func _mvp_rule(line: Dictionary) -> Label:
	return SprintUiShared.prose(tr("PRODUCT_MVP_RULE" if line.sprint >= 0 else "PRODUCT_MVP_RULE_NO_ETA").format(line),
		&"MetaMuted")


## Alt satır: sağda düğmeler, birincil en sağda.
func _foot_row(buttons: Array) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_L)
	row.add_child(RnDUiShared.spacer())
	for button: Button in buttons:
		row.add_child(button)
	return row


## Uyarı ya da bilgi cümlesi: glifi (varsa) ve metni aynı mürekkepte, büyük harfsiz.
func _note(glyph_path: String, text: String, ink: Color) -> HBoxContainer:
	var row := SprintUiShared.box(UiTokens.SPACE_S)
	if glyph_path != "":
		row.add_child(UiFactory.make_glyph(glyph_path, UiTokens.D_ICON_ROW, ink))
	row.add_child(SprintUiShared.label(text, &"Caption", ink))
	row.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row
