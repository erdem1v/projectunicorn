extends Control

# Pitch dialogue modal — PostShip spec §D/§E. Thin renderer over PitchSystem.
# Mounted by main.gd into GameShell/ModalLayer on EventBus.pitch_requested
# (same lifecycle as EventModal: pause on open, restore on close). Walks the
# 4-stage pitch; choice buttons are built dynamically. On the close stage,
# shows a result panel; Continue emits EventBus.pitch_finished.
#
# process_mode = ALWAYS so buttons stay responsive while the tree is paused.

@onready var speaker_label: Label = $CenterPanel/Margin/VBox/HeaderRow/SpeakerLabel
@onready var npc_label: Label = $CenterPanel/Margin/VBox/NpcLabel
@onready var inner_label: Label = $CenterPanel/Margin/VBox/InnerLabel
@onready var reveal_label: Label = $CenterPanel/Margin/VBox/RevealLabel
@onready var check_label: Label = $CenterPanel/Margin/VBox/CheckLabel
@onready var choices_box: VBoxContainer = $CenterPanel/Margin/VBox/ChoicesContainer
@onready var result_panel: VBoxContainer = $CenterPanel/Margin/VBox/ResultPanel
@onready var result_label: Label = $CenterPanel/Margin/VBox/ResultPanel/ResultLabel
@onready var continue_button: Button = $CenterPanel/Margin/VBox/ResultPanel/ContinueButton


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	result_panel.visible = false
	continue_button.pressed.connect(_on_continue_pressed)


func populate(prospect_id: String) -> void:
	if not PitchSystem.begin(prospect_id):
		EventBus.pitch_finished.emit()
		return
	_render_stage(PitchSystem.get_stage(), {})


func _render_stage(stage: Dictionary, check: Dictionary) -> void:
	speaker_label.text = String(stage.get("speaker", "—"))
	npc_label.text = String(stage.get("npc", ""))
	inner_label.text = String(stage.get("inner", ""))
	var reveal: String = String(stage.get("reveal", ""))
	reveal_label.visible = reveal != ""
	reveal_label.text = reveal
	if not check.is_empty() and check.has("band"):
		check_label.visible = true
		check_label.text = _check_line(check)
	else:
		check_label.visible = false
	_build_choices(stage.get("choices", []))


func _build_choices(choices: Array) -> void:
	for c in choices_box.get_children():
		c.queue_free()
	for i in choices.size():
		var btn := Button.new()
		btn.text = String((choices[i] as Dictionary).get("label", "—"))
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choices_box.add_child(btn)


func _on_choice_pressed(idx: int) -> void:
	var res: Dictionary = PitchSystem.choose(idx)
	if res.get("done", false):
		_show_result(res.get("result", {}))
	else:
		_render_stage(PitchSystem.get_stage(), res.get("check", {}))


func _show_result(result: Dictionary) -> void:
	for c in choices_box.get_children():
		c.queue_free()
	choices_box.visible = false
	check_label.visible = false
	reveal_label.visible = false
	npc_label.text = ""
	var outcome: String = String(result.get("outcome", "LOST"))
	inner_label.text = _result_inner(outcome)
	result_label.text = _result_text(outcome, result)
	result_panel.visible = true


func _on_continue_pressed() -> void:
	EventBus.pitch_finished.emit()


# --- Voice helpers (TR working drafts; Erdem revises) ---

func _check_line(check: Dictionary) -> String:
	match String(check.get("band", "")):
		"crit_success": return "→ Tam isabet. Onu yakaladın."
		"success": return "→ İyi gitti."
		"near_pass": return "→ Kıl payı tuttu."
		"near_miss": return "→ Az kalsın — kaçırdın."
		"fail", "crit_fail": return "→ Tutmadı. Hava soğudu."
		_: return ""


func _result_text(outcome: String, result: Dictionary) -> String:
	var company: String = String(result.get("company", "Müşteri"))
	match outcome:
		"SIGNED":
			return "%s imzaladı. Aylık $%d. İlk gerçek müşterin." % [company, int(result.get("mrr", 0))]
		"CALLBACK":
			return "%s 'düşünüp döneceğim' dedi. Pipeline'da kaldı — tekrar deneyebilirsin." % company
		_:
			return "%s bu sefer olmadı. Kapı kapandı." % company


func _result_inner(outcome: String) -> String:
	match outcome:
		"SIGNED": return "Biri, yaptığın şeye para verdi. Küçük ama gerçek."
		"CALLBACK": return "'Düşüneceğim' — satışın en kaygan cümlesi. Ama kapı tam kapanmadı."
		_: return "Olmadı. Frank ne der bilmiyorum ama bir sonraki var."
