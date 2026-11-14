class_name LaunchGate
extends PanelContainer

# Yayın şartı şeridi: ürün yayına çıkmadan bitmesi gereken adlı modüller ve durumları (`SprintCatalog.mvp_parts`);
# şerit ürün türünü bilmez. Durum biçimle okunur: bitti onay işareti, planda (bu ya da sıradaki sprintte) dolu nokta,
# bekliyor boş halka; sözcüğü ipucundadır.

const STATE_KEYS := {"done": "LAUNCH_GATE_DONE", "sprint": "LAUNCH_GATE_SPRINT", "next": "LAUNCH_GATE_NEXT",
	"waiting": "LAUNCH_GATE_WAITING"}
## Parçanın adı: planda duran (bu ya da sıradaki sprintte) öne çıkar, bekleyen sönük.
const NAME_INK := {"done": UiTokens.D_INK_2, "sprint": UiTokens.D_INK_1, "next": UiTokens.D_INK_1, "waiting": UiTokens.D_INK_3}


## Bitmemiş parçanın işareti: planda duran halkalı dolu nokta, bekleyen boş halka.
class Mark extends Control:
	var state: String

	func _init(part_state: String) -> void:
		state = part_state
		custom_minimum_size = Vector2.ONE * UiTokens.D_ICON_ROW
		size_flags_vertical = Control.SIZE_SHRINK_CENTER
		mouse_filter = Control.MOUSE_FILTER_IGNORE

	func _draw() -> void:
		var middle: Vector2 = size / 2.0
		if state != "waiting":
			draw_circle(middle, size.x * 0.5, UiTokens.D_ACCENT_GLOW)
			draw_circle(middle, size.x * 0.32, UiTokens.D_ACCENT)
		else:
			draw_arc(middle, size.x * 0.38, 0.0, TAU, 32, UiTokens.D_INK_4, UiTokens.BORDER_FOCUS, true)


## Yayın şartının işareti: şeridin başında ve şartın modülünün satırında aynı bayrak.
static func flag() -> TextureRect:
	return UiFactory.make_glyph(SprintUiShared.FLAG, UiTokens.D_ICON_PART, UiTokens.D_ACCENT)


## `parts`: [{name, state}].
func _init(parts: Array) -> void:
	theme_type_variation = &"NoticeStrip"
	custom_minimum_size.y = UiTokens.D_H_ROW
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var row := SprintUiShared.box(UiTokens.SPACE_XXL)
	add_child(row)
	var title := SprintUiShared.box(UiTokens.SPACE_S)
	title.add_child(flag())
	title.add_child(SprintUiShared.label(Fmt.upper(tr("LAUNCH_GATE_TITLE")), &"KeyLabel"))
	row.add_child(title)
	var flow := HFlowContainer.new()
	flow.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flow.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	flow.add_theme_constant_override("h_separation", UiTokens.SPACE_4XL)
	flow.add_theme_constant_override("v_separation", UiTokens.SPACE_XS)
	row.add_child(flow)
	for part: Dictionary in parts:
		flow.add_child(_part(part))


func _part(part: Dictionary) -> HBoxContainer:
	var state: String = part.state
	var item := SprintUiShared.box(UiTokens.SPACE_S)
	item.tooltip_text = SprintUiShared.SEP.join([part.name, tr(STATE_KEYS[state])])
	if state == "done":
		item.add_child(UiFactory.make_glyph(SprintUiShared.CHECK, UiTokens.D_ICON_ROW, UiTokens.D_pos()))
	else:
		item.add_child(Mark.new(state))
	item.add_child(SprintUiShared.label(part.name, &"DataText" if state in ["done", "waiting"] else &"DataStrong", NAME_INK[state]))
	return item
