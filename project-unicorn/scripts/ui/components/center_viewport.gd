extends Panel

# Center viewport per TECH_SPEC §5.2. Hosts either the desk view or the
# active dashboard tab. Tab scenes that exist (Spec #1 ships Product) mount
# as a child of self. Tabs without a scene file still fall back to the
# title-paint placeholder.

const TAB_SCENES := {
	"product": preload("res://scenes/tabs/ProductTab.tscn"),
	"sales": preload("res://scenes/tabs/SalesTab.tscn"),
	"finance": preload("res://scenes/tabs/FinanceTab.tscn"),  # Spec 6 — hosts the Yatırım sub-page
}

@onready var content_box: VBoxContainer = $Content
@onready var title_label: Label = $Content/TitleLabel

var _current_tab_node: Node = null


func _ready() -> void:
	EventBus.tab_changed.connect(_on_tab_changed)
	# Initial paint to the default tab (Product).
	_on_tab_changed(UiTokens.TABS[0].id)


func _exit_tree() -> void:
	EventBus.tab_changed.disconnect(_on_tab_changed)


func _on_tab_changed(tab_id: String) -> void:
	# Free previous tab instance (if any)
	if _current_tab_node != null:
		_current_tab_node.queue_free()
		_current_tab_node = null

	if TAB_SCENES.has(tab_id):
		# Real tab scene exists — mount it and hide the placeholder Content
		# VBox entirely (TitleLabel + SubtitleLabel both bleed through if
		# only the title is hidden).
		_current_tab_node = (TAB_SCENES[tab_id] as PackedScene).instantiate()
		add_child(_current_tab_node)
		# Keep the BuildHUD overlay (a sibling declared in GameShell.tscn) drawn
		# on top of the freshly-mounted tab. add_child() appends, so the new tab
		# would otherwise render last (over the HUD); push it to the bottom of the
		# sibling draw order instead.
		move_child(_current_tab_node, 0)
		content_box.visible = false
	else:
		# Placeholder path — show Content with the tab's uppercase label
		content_box.visible = true
		for tab in UiTokens.TABS:
			if tab.id == tab_id:
				title_label.text = UiTokens.tr_upper(tab.label as String)
				return
