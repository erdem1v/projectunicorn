class_name BoardRow
extends PanelContainer

# Panonun bir kart satırı. Solda bilgi sütunu: tür ikonu, ad, hata riski ve efor; altında modülün kısa adı (düzeltme kartında hata
# metni), durum yuvası (söz tarihi, devreden ya da yetişmez) ve PM ya da soru yuvası. Sağda zaman ekseni: aşama çubukları (önden
# bitmiş aşamanın tik kutusu çubuğun başında), beklemeler, PM'in gölgesi ve kurucunun görüşme günleri, sprint dışına kalan pay
# turuncu taramalı. Satır modelin kartını ve zaman ekseni kaydını çizer; hesap yapmaz. Koşan sprintte saat ilerleyince `set_now`
# çubukların hâlini, dolgusunu ve çalışanların yüzlerini saklanan parçalardan yeniden okur. Art arda önden biten aşamalar tek tik
# kutusudur (son bitenin renginde; bitmiş aşamaların listesi kartın `stages`ında kalır). Her öğe kendi Control'üdür: çubuk,
# bekleme, gölge, tarama ve tik kutusu `StagePaint`, çip ve yuvalar kendi Label ya da Panel'i; ipucu o öğeye bağlanır.

signal action(kind: String, args: Dictionary)

const ARROW := "res://assets/icons/util/arrow_right.svg"

## Satırın verisi, bağlam ({mode "plan" | "active", now (sprint başından hafta), people {kimlik: kişi + parçaları}, candidate
## (aday satırı: hayalet çubuklar, hep açık "+"), hot (aday satırı üstüne gelinmiş gibi açık)}).
var card: Dictionary
var _ctx: Dictionary
var _two := false
var _mark: ColorRect
var _acts: Control
## Koşan çubuklar {ground, label, faces, stage, workers}: saat ilerleyince hâli, yazısı ve yüzleri yeniden okunur.
var _live: Array = []


func setup(row: Dictionary, ctx: Dictionary) -> void:
	card = row
	_ctx = ctx
	_two = String(row.name).length() > UiTokens.D_CARD_NAME_SHORT
	var h: int = UiTokens.D_H_CARD_ROW_TWO if _two else UiTokens.D_H_CARD_ROW
	custom_minimum_size = Vector2(UiTokens.D_W_CARD_INFO + UiTokens.D_W_TIMELINE, h)
	mouse_filter = Control.MOUSE_FILTER_PASS
	var cell := Control.new()
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cell)
	_mark = ColorRect.new()
	_mark.size = Vector2(UiTokens.BORDER_ACCENT, h)
	_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cell.add_child(_mark)
	cell.add_child(_info(h))
	cell.add_child(_lane(h))
	if ctx.mode == "plan" and not ctx.candidate and not row.buttons.is_empty():
		_acts = _keys(row.buttons)
		cell.add_child(_acts)
	mouse_entered.connect(_hover.bind(true))
	mouse_exited.connect(_exited)
	_hover(ctx.hot)


func _draw() -> void:
	# Aday satırının alt çizgisi kesiktir.
	if _ctx.candidate:
		draw_dashed_line(Vector2(0.0, size.y - 0.5), Vector2(size.x, size.y - 0.5), UiTokens.D_ROW_RULE, UiTokens.BORDER_HAIRLINE,
			UiTokens.SPACE_XS)


## Satırın üstüne gelme: zemin açılır, solda çizgi; planlamada "→" ve "×" görünür; aday satırı tam görünür.
func _hover(on: bool) -> void:
	var ground: String = "SprintRowCand" if _ctx.candidate else "SprintRow"
	theme_type_variation = UiTokens.D_variation(&"SprintRowLate") if card.late else StringName(ground + ("Hover" if on else ""))
	_mark.visible = on or card.late
	_mark.color = UiTokens.D_neg() if card.late else UiTokens.D_INK_1
	if _acts != null:
		_acts.visible = on
	if _ctx.candidate:
		modulate.a = 1.0 if on else UiTokens.D_ROW_ALPHA


func is_candidate() -> bool:
	return _ctx.candidate


## Aday satırının imleç sol sütunda adayın "+"ındaymış gibi açık görünmesi.
func set_hot(on: bool) -> void:
	_ctx.hot = on
	_hover(on)


## Çocuk düğmeye geçmek satırı bırakmak değildir.
func _exited() -> void:
	if not get_global_rect().has_point(get_global_mouse_position()):
		_hover(_ctx.hot)


# --- Bilgi sütunu ---------------------------------------------------------------------------

func _info(h: int) -> Control:
	var margin := MarginContainer.new()
	margin.size = Vector2(UiTokens.D_W_CARD_INFO, h)
	margin.add_theme_constant_override("margin_top", UiTokens.D_PAD_CARD_ROW)
	margin.add_theme_constant_override("margin_right", UiTokens.SPACE_L)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	col.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(col)
	col.add_child(_first_line())
	col.add_child(_second_line())
	return margin


## Tür ikonu, ad (22 karakterden uzunsa iki satır, yine taşarsa üç nokta), hata riski, efor ve aday satırında "+".
func _first_line() -> HBoxContainer:
	var ink: Variant = UiTokens.D_neg_ink() if card.late else null
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	line.custom_minimum_size.y = UiTokens.D_H_CARD_LINE_TWO if _two else UiTokens.D_H_CARD_LINE
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var kind := UiFactory.make_glyph(SprintUiShared.KIND_ICON % card.kind, UiTokens.D_ICON_ROW, UiTokens.D_INK_3)
	kind.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	line.add_child(SprintUiShared.pad(kind, Vector4i(0, UiTokens.D_PAD_CARD_ICON, 0, 0)))
	var title := SprintUiShared.prose(String(card.name), &"DataStrong", ink)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART if _two else TextServer.AUTOWRAP_OFF
	title.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	title.max_lines_visible = 2 if _two else 1
	title.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	title.mouse_filter = Control.MOUSE_FILTER_PASS
	line.add_child(title)
	var risk := SprintUiShared.box(UiTokens.SPACE_XS)
	risk.custom_minimum_size.y = UiTokens.D_H_CARD_LINE
	risk.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	risk.mouse_filter = Control.MOUSE_FILTER_PASS
	risk.add_child(UiFactory.make_glyph(SprintUiShared.BUG, UiTokens.D_ICON_TAG, UiTokens.D_INK_4))
	risk.add_child(StagePaint.risk(card.risk, card.risk_raw))
	line.add_child(risk)
	var effort := SprintUiShared.label(str(card.effort), &"CardEffort", ink)
	effort.custom_minimum_size.x = UiTokens.D_W_CARD_EFFORT
	effort.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	effort.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	effort.mouse_filter = Control.MOUSE_FILTER_PASS
	line.add_child(effort)
	if _ctx.candidate:
		var add := SprintUiShared.add_key()
		add.custom_minimum_size = Vector2.ONE * UiTokens.D_H_KEY_CAND
		add.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
		add.tooltip_text = tr("PRODUCT_ADD_TO_PLAN")
		add.pressed.connect(action.emit.bind("add", {"card_id": String(card.id)}))
		line.add_child(add)
	return line


## Modülün kısa adı (düzeltme kartında hata metni), durum yuvası ve PM yuvası.
func _second_line() -> HBoxContainer:
	var line := SprintUiShared.box(UiTokens.SPACE_M)
	line.custom_minimum_size.y = UiTokens.D_AVATAR_ROW_SM
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	line.add_child(RnDUiShared.spacer(UiTokens.D_ICON_ROW))
	var slot: Dictionary = card.slot
	if card.kind == "fix":
		var text := SprintUiShared.label(String(card.fix_text), &"Caption")
		text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		text.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		text.mouse_filter = Control.MOUSE_FILTER_PASS
		line.add_child(text)
		if not slot.is_empty():
			line.add_child(_status(slot))
	else:
		var module := SprintUiShared.label(String(card.module), &"CaptionName")
		module.custom_minimum_size.x = UiTokens.D_W_CARD_SLOT
		module.mouse_filter = Control.MOUSE_FILTER_PASS
		line.add_child(module)
		line.add_child(_status(slot))
	line.add_child(_person())
	return line


## Durum yuvası, en az `D_W_CARD_SLOT` geniş: söz tarihi çipi, "devreden" ya da kırmızı "yetişmez"; yoksa boş.
func _status(slot: Dictionary) -> Control:
	var cell := SprintUiShared.box(UiTokens.SPACE_S)
	cell.custom_minimum_size.x = UiTokens.D_W_CARD_SLOT
	cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
	match String(slot.get("kind", "")):
		"due":
			var chip: PanelContainer = SprintUiShared.due_chip(String(slot.text), slot.soon)
			chip.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
			chip.mouse_filter = Control.MOUSE_FILTER_PASS
			cell.add_child(chip)
		"carried":
			var back := UiFactory.make_glyph(ARROW, UiTokens.D_ICON_TAG, UiTokens.D_INK_4)
			(back as TextureRect).flip_h = true
			cell.add_child(back)
			cell.add_child(SprintUiShared.label(tr("PRODUCT_CARRIED_SLOT"), &"Caption"))
			cell.mouse_filter = Control.MOUSE_FILTER_PASS
		"late":
			cell.add_child(SprintUiShared.label(tr("PRODUCT_LATE"), &"CaptionName", UiTokens.D_neg_ink()))
	return cell


## PM yuvası: karta bekleyen bir soru varsa soranın yüzü ve sağ üstte "?", yoksa kartı hazırlayan PM'in yüzü.
func _person() -> Control:
	var slot := Control.new()
	slot.custom_minimum_size = Vector2.ONE * UiTokens.D_AVATAR_ROW_SM
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var ask: Variant = card.ask
	var who: Variant = card.pm if ask == null else ask.person
	var face: Control = null
	if who != null:
		face = SprintUiShared.avatar(who, UiTokens.D_AVATAR_ROW_SM)
	elif ask != null:
		face = UiFactory.make_avatar("?", UiTokens.D_AVATAR_ROW_SM)
	if face != null:
		face.mouse_filter = Control.MOUSE_FILTER_PASS   # tık satıra ve yuvaya geçer
		slot.add_child(face)
	if ask == null:
		return slot
	var disc := StagePaint.part(&"ask", "", {}, Rect2(UiTokens.D_AVATAR_ROW_SM + UiTokens.SPACE_S - UiTokens.D_ASK_DISC,
		-UiTokens.SPACE_XS, UiTokens.D_ASK_DISC, UiTokens.D_ASK_DISC))
	slot.add_child(disc)
	for part: Control in [slot, face, disc]:
		part.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	slot.mouse_filter = Control.MOUSE_FILTER_PASS
	slot.gui_input.connect(func(ev: InputEvent) -> void:
		if UiFactory.is_left_click(ev):
			action.emit("decide", {"card_id": String(card.id), "item": String(ask.item)}))
	return slot


## Planlamada üstüne gelince görünen "→" ve "×": satırın bilgi sütununun sağ üstünde, efor sayısının üstünde.
func _keys(kinds: Array) -> Control:
	var acts := SprintUiShared.row_keys(kinds, String(card.id), action.emit)
	# Panelin sağ kenarı bilgi sütununun sağ kenarından `SPACE_M + SPACE_XXS` içeride, üstü satırın üstünden `SPACE_XS` aşağıda.
	var keys_w: float = kinds.size() * UiTokens.D_H_KEY_SM + (kinds.size() + 1) * UiTokens.SPACE_XXS
	acts.offset_left = UiTokens.D_W_CARD_INFO - UiTokens.SPACE_M - UiTokens.SPACE_XXS - keys_w
	acts.offset_top = UiTokens.SPACE_XS
	return acts


# --- Zaman ekseni ---------------------------------------------------------------------------

func _x(week: float) -> float:
	return roundf(week * UiTokens.D_W_TIMELINE / UiTokens.D_TIMELINE_WEEKS)


## Kartın aşamaları eksende: bekleme noktalı çizgisi, çubuk, sprint dışına kalan pay ve PM'in gölgesi. Eksenden önce ya da önden
## bitmiş aşama çizilmez: art arda bitenler tek tik kutusudur, son bitenin renginde, sonraki çubuğun başına takılır (arkasında çubuk
## yoksa tek başına). Sprint dışına kalan paylar arka arkaya durur: sonraki aşamanın payı öncekinin bittiği yerden başlar, eksenin
## sonunda kesilir.
func _lane(h: int) -> Control:
	var lane := Control.new()
	lane.position = Vector2(UiTokens.D_W_CARD_INFO, 0.0)
	lane.size = Vector2(UiTokens.D_W_TIMELINE, h)
	lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top: float = (h - UiTokens.D_H_STAGE_BAR) / 2.0
	var shadows: Array = []
	var waits: Array = []
	var bars: Array = []
	var tick := ""
	var out_end := 0.0
	for s: Dictionary in card.stages:
		if s.before or (s.need <= SprintSystem.EPS and s.pre > SprintSystem.EPS):
			tick = s.stage
			continue
		for wait: Dictionary in s.waits:
			var from: float = _x(wait.from)
			var width: float = _x(minf(wait.to, UiTokens.D_TIMELINE_WEEKS)) - from
			if width >= 1.0:
				waits.append(StagePaint.part(&"wait", s.stage, {"from": wait.from, "to": wait.to, "person": wait.person, "role": wait.role},
					Rect2(from, top + (UiTokens.D_H_STAGE_BAR - UiTokens.D_H_WAIT) / 2.0, width, UiTokens.D_H_WAIT)))
		if s.start >= 0.0:
			var left: float = _x(s.start)
			bars.append(_bar(s, Rect2(left, top, maxf(_x(s.end) - left, UiTokens.D_W_STAGE_BAR_LEAST), UiTokens.D_H_STAGE_BAR), "in", tick))
			tick = ""
			var shade: StagePaint = _shadow(s, top)
			if shade != null:
				shadows.append(shade)
		if s.out_from >= 0.0:
			var out_left: float = maxf(_x(s.out_from), out_end)
			var out_right: float = minf(out_left + _x(s.out_to) - _x(s.out_from), UiTokens.D_W_TIMELINE)
			if out_right - out_left >= 1.0:
				bars.append(_bar(s, Rect2(out_left, top, out_right - out_left, UiTokens.D_H_STAGE_BAR), "out", tick))
				tick = ""
				out_end = out_right
	if tick != "":
		bars.append(StagePaint.part(&"tick", tick, {}, Rect2(0.0, top, UiTokens.D_W_TICK_BOX, UiTokens.D_H_STAGE_BAR)))
	for part: Control in shadows + waits + bars:
		lane.add_child(part)
	if _ctx.mode == "active":
		set_now(_ctx.now)
	return lane


## Bir aşamanın çubuğu: zemini, önden bitmiş aşamaların tik kutusu (`tick` son bitenin aşaması, yoksa ""), görüşme taramaları, ikon ve
## sayı, çalışanların yüzleri. `piece` "in" sprintin içindeki çubuk, "out" sprint dışına kalan pay.
func _bar(s: Dictionary, rect: Rect2, piece: String, tick: String) -> StagePaint:
	var running: bool = _ctx.mode == "active"
	var candidate: bool = _ctx.candidate
	var out: bool = piece == "out"
	var state: String = "ghost" if candidate else ("out" if out else "plan")
	var total: float = s.pre + s.need
	var main: String = str(roundi(s.out if out else s.in_sprint - s.done0))
	var sub := ""
	var fill := 0.0
	if not out and s.pre > SprintSystem.EPS and not running:
		main = str(roundi(s.pre))
		sub = "/%d" % roundi(total)
		fill = s.pre / total
	var bar: StagePaint = StagePaint.part(&"bar", s.stage, {"state": state, "late": card.late, "fill": fill,
		"from": s.out_from if out else s.start, "to": s.out_to if out else s.end, "piece": piece}, rect)
	bar.clip_contents = true
	if candidate:
		bar.modulate.a = UiTokens.D_GHOST_ALPHA
	if tick != "":
		bar.add_child(StagePaint.part(&"tick", tick, {}, Rect2(0.0, 0.0, UiTokens.D_W_TICK_BOX, rect.size.y)))
	if not out and not candidate:
		for m: Dictionary in s.meet:
			var from: float = maxf(_x(m.from), rect.position.x)
			var to: float = minf(_x(m.to), rect.end.x)
			if to - from >= 1.0:
				bar.add_child(StagePaint.part(&"meet", s.stage, m, Rect2(from - rect.position.x, 0.0, to - from, rect.size.y)))
	var left: float = UiTokens.D_W_TICK_BOX + UiTokens.SPACE_S if tick != "" else float(UiTokens.D_STAGE_BAR_PAD.x)
	var label: StagePaint = StagePaint.part(&"label", s.stage, {"state": state, "late": card.late, "main": main, "sub": sub, "left": left,
		"room": 0.0, "icon": _icon(s.stage)}, Rect2(Vector2.ZERO, rect.size))
	bar.add_child(label)
	var faces := SprintUiShared.box(-UiTokens.SPACE_S)
	faces.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.add_child(faces)
	var entry := {"ground": bar, "label": label, "faces": faces, "stage": s, "out": out, "left": left, "main": main, "sub": sub, "work": main}
	if running and not out:
		entry["workers"] = _workers(s)
		_live.append(entry)
	elif not running and not out and not candidate:
		_founder_face(entry)
	return bar


func _icon(stage: String) -> String:
	return RnDUiShared.ICON if stage == "product" else SprintUiShared.ROLE_ICONS[stage]


## PM'in kısalttığı payın gölgesi: çubuğun altında, çubuğun başından hazırlanmasaydı biteceği yere uzanan şerit. Hazırlanmamış
## hâlin ek süresi, ek işin son parçanın hızına bölünmesidir.
func _shadow(s: Dictionary, top: float) -> StagePaint:
	if card.pm == null or s.need_raw <= s.need + SprintSystem.EPS or s.pieces.is_empty():
		return null
	var last: Dictionary = s.pieces[-1]
	var pace: float = float(last.work) / maxf(last.to - last.from, SprintSystem.EPS)
	var from: float = _x(s.pieces[0].from)
	var to: float = minf(_x(float(last.to) + (s.need_raw - s.need) / pace), UiTokens.D_W_TIMELINE)
	if to - from < 1.0:
		return null
	return StagePaint.part(&"shadow", s.stage, {}, Rect2(from + UiTokens.D_SHADOW_INSET, top + UiTokens.D_H_STAGE_BAR - UiTokens.BORDER_HAIRLINE,
		to - from - UiTokens.D_SHADOW_INSET, UiTokens.D_H_SHADOW))


## Planlamada kurucunun çalıştığı çubuğun ucunda yüzü; çubuk sığmıyorsa çizilmez.
func _founder_face(entry: Dictionary) -> void:
	var s: Dictionary = entry.stage
	for id: String in s.people:
		if _ctx.people.has(id):
			_faces(entry, [id], true)


## Çubuğa `ids` kişilerinin yüzleri (kurucu halkalı) sağ uca konur ve etiket onlara yer ayırır; çubuk sığmıyorsa yüz çizilmez.
func _faces(entry: Dictionary, ids: Array, planned := false) -> void:
	var faces: HBoxContainer = entry.faces
	UiFactory.clear(faces)
	var bar: StagePaint = entry.ground
	var face_px: int = UiTokens.D_AVATAR_ROW_SM
	var width: float = ids.size() * (face_px - UiTokens.SPACE_S) + UiTokens.SPACE_S
	var text_w: float = StagePaint.text_width(String(entry.main) + String(entry.sub))
	var room: float = 0.0
	var need: float = float(entry.left) + UiTokens.D_ICON_TAG + UiTokens.SPACE_S + text_w + width + UiTokens.SPACE_S + UiTokens.D_STAGE_BAR_PAD.y
	if not ids.is_empty() and bar.size.x >= (need if planned else width + float(entry.left) + UiTokens.D_STAGE_BAR_PAD.y):
		for id: String in ids:
			faces.add_child(SprintUiShared.face(_ctx.people[id], face_px, false, false))
		faces.position = Vector2(bar.size.x - UiTokens.D_STAGE_BAR_PAD.y - width, (bar.size.y - face_px) / 2.0)
		room = width + UiTokens.SPACE_S
	(entry.label as StagePaint).set_bar({"room": room})


func _workers(s: Dictionary) -> Array:
	var out: Array = []
	for id: String in _ctx.people:
		for p: Dictionary in _ctx.people[id].pieces:
			if p.card == card.id and p.stage == s.stage and not p.ahead and p.to > s.start and p.from < s.end:
				out.append({"id": id, "from": p.from, "to": p.to})
	return out


## Koşan sprintte şimdiki an `at` (sprint başından hafta): her çubuğun hâli (biten, sürüyor, bekliyor), dolgusu, yazısı ve o an
## çalışanların yüzleri saklanan parçalardan okunur. Süren çubuk "{yapılan}/{toplam}" yazar (yapılan tamsayıya aşağı yuvarlanır: biten
## çubuk dışında tam görünmez), başlamamış çubuk planlamadaki gibi aşamanın bu eksendeki işini.
func set_now(at: float) -> void:
	for entry: Dictionary in _live:
		var s: Dictionary = entry.stage
		var total: float = s.pre + s.need
		var made: float = s.pre + SprintTimeline.done_at(s, at)
		var state: String = "done" if at >= s.end - SprintSystem.EPS else ("run" if at >= s.start - SprintSystem.EPS else "wait")
		entry.main = entry.work if state == "wait" else str(floori(made + SprintSystem.EPS))
		entry.sub = "" if state == "wait" else "/%d" % roundi(total)
		(entry.ground as StagePaint).set_bar({"state": state, "fill": clampf(made / total, 0.0, 1.0) if state == "run" else 0.0})
		(entry.label as StagePaint).set_bar({"state": state, "main": entry.main, "sub": entry.sub})
		var working: Array = []
		if state == "run":
			for w: Dictionary in entry.workers:
				if w.from <= at and at < w.to:
					working.append(w.id)
		_faces(entry, working)
