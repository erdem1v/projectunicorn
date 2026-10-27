class_name SprintCard
extends PanelContainer

# ÇEYREK'in sütunlarındaki mini kart: tür ikonu, ad ve efor (devreden kart kalan eforuyla). Sonraki sprinte ya da sonrakilere planlanmış
# kart kesikli kenarlıdır; kapısı sonradan kapanmış kart soluk, biten kart ikincil mürekkepte. Kart yalnız sözlüğünü çizer.

enum State { SPRINT_PLAN, SPRINT_AKTIF, BITTI, DEVREDEN, PLANLANAN, KILITLI }

const PLANNED := [State.PLANLANAN, State.DEVREDEN]


func setup(card: Dictionary) -> void:
	var state: State = card.state
	var planned: bool = state in PLANNED
	if planned:
		HRUiShared.D_dashed(self)
	theme_type_variation = &"SprintCardMiniPlanned" if planned else &"SprintCardMini"
	var points: float = card.remaining if card.remaining >= 0 else card.effort
	var glyph_ink: Color = UiTokens.D_INK_OFF if state == State.KILITLI else UiTokens.D_INK_3
	var name_ink: Color = glyph_ink if state in [State.KILITLI, State.BITTI] else UiTokens.D_INK_1
	var top := SprintUiShared.box(UiTokens.SPACE_S)
	add_child(top)
	top.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % card.kind, UiTokens.D_ICON_PART, glyph_ink))
	var title := UiFactory.make_label(String(card.name), &"CaptionStrong", name_ink)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.max_lines_visible = 2
	top.add_child(title)
	var pts := UiFactory.make_label(SprintUiShared.points(points), &"PtsBox")
	pts.custom_minimum_size.x = UiTokens.D_W_PTS
	pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(pts)
	for part: Control in top.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
