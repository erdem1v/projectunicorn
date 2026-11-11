class_name SprintCard
extends PanelContainer

# ÇEYREK'in sütunlarındaki mini kart: üstte tür ikonu ve efor (devreden kart kalan eforuyla), altında ad. Ad kendi satırındadır,
# kesilmez, kelime sınırında sarar ve uzunsa satırlara bölüp kartı uzatır. Sonraki sprinte ya da sonrakilere planlanmış kart
# kesikli kenarlıdır; kapısı sonradan kapanmış kart soluk, biten kart ikincil mürekkepte. Kart yalnız sözlüğünü çizer.

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
	var col := SprintUiShared.column(UiTokens.SPACE_XS)
	add_child(col)
	var top := SprintUiShared.box(UiTokens.SPACE_S)
	col.add_child(top)
	top.add_child(UiFactory.make_glyph(SprintUiShared.KIND_ICON % card.kind, UiTokens.D_ICON_PART, glyph_ink))
	top.add_child(RnDUiShared.spacer())
	var pts := UiFactory.make_label(SprintUiShared.points(points), &"PtsBox")
	pts.custom_minimum_size.x = UiTokens.D_W_PTS
	pts.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top.add_child(pts)
	col.add_child(SprintUiShared.prose(String(card.name), &"CaptionStrong", name_ink))
