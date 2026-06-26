extends OnboardingStep

# Step 5 — Company Creation per PROJECT_SPEC §3.1.
# Required: company name + logo style. Optional: founder name, slogan.

const LOGO_STYLES := ["minimalist", "tech", "playful", "serious"]
const LOGO_LABELS := {
	"minimalist": "Minimalist",
	"tech": "Tech",
	"playful": "Playful",
	"serious": "Serious",
}

var _logo_style: String = ""

@onready var name_input: LineEdit = $List/CompanyNameRow/Input
@onready var founder_name_input: LineEdit = $List/FounderNameRow/Input
@onready var slogan_input: LineEdit = $List/SloganRow/Input
@onready var logo_cards: Dictionary = {
	"minimalist": $List/LogoRow/Cards/Minimalist,
	"tech": $List/LogoRow/Cards/Tech,
	"playful": $List/LogoRow/Cards/Playful,
	"serious": $List/LogoRow/Cards/Serious,
}
@onready var preview_label: Label = $List/PreviewRow/PreviewLabel
@onready var preview_logo: Label = $List/PreviewRow/LogoChip


func _ready() -> void:
	name_input.text_changed.connect(_on_name_or_logo_changed)
	founder_name_input.text_changed.connect(_on_any_text_changed)
	slogan_input.text_changed.connect(_on_any_text_changed)
	for style_id in LOGO_STYLES:
		var card: Panel = logo_cards[style_id]
		card.gui_input.connect(_on_logo_input.bind(style_id))
	_refresh_visual()


func _on_name_or_logo_changed(_text: String) -> void:
	_refresh_preview()
	validity_changed.emit(is_valid())


func _on_any_text_changed(_text: String) -> void:
	_refresh_preview()


func _on_logo_input(event: InputEvent, style_id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_logo_style = style_id
		_refresh_visual()
		validity_changed.emit(is_valid())


func _refresh_visual() -> void:
	for style_id in LOGO_STYLES:
		var card: Panel = logo_cards[style_id]
		card.get_node("SelectedBorder").visible = (style_id == _logo_style)
	_refresh_preview()


func _refresh_preview() -> void:
	var display_name: String = name_input.text.strip_edges()
	if display_name == "":
		display_name = "[Şirket adı]"
	preview_label.text = display_name
	preview_logo.text = LOGO_LABELS.get(_logo_style, "?")[0] if _logo_style != "" else "?"


# --- OnboardingStep contract ---

func prefill(draft: Dictionary) -> void:
	if not is_node_ready():
		await ready
	name_input.text = draft.get("company_name", "")
	founder_name_input.text = draft.get("founder_name", "")
	slogan_input.text = draft.get("slogan", "")
	_logo_style = draft.get("logo_style", "")
	_refresh_visual()
	validity_changed.emit(is_valid())


func is_valid() -> bool:
	return name_input != null \
		and name_input.text.strip_edges() != "" \
		and _logo_style != ""


func collect_payload() -> Dictionary:
	return {
		"company_name": name_input.text.strip_edges(),
		"founder_name": founder_name_input.text.strip_edges(),
		"slogan": slogan_input.text.strip_edges(),
		"logo_style": _logo_style,
	}
