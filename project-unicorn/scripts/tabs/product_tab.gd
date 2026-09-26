extends Control

# ============================================================================
# Product tab — görünüm YÖNLENDİRİCİSİ.
# Dört görünüm: portfoy | creation | tracker | detail. Hepsi kod-kurulu (tscn yok)
# ve ihtiyaç anında yüklenir.
#
# Görünüm sözleşmesi (her view uygular):
#   func setup(args: Dictionary) -> void   — add_child SONRASI çağrılır (ev
#                                            konvansiyonu: populate-after-add_child)
#   func repaint() -> void                 — yerinde metin güncellemesi
#   signal navigate_requested(view_id: String, args: Dictionary)
#
# Açılış HER ZAMAN "portfoy" (center_viewport tab'ı her girişte yeniden kurar;
# görünüm state'i bilinçli olarak geçici), yalnız saklanmış bir kurma taslağı onu
# geçer. Rota düzeltmeleri build_phase_changed üzerinden: "shipped" → detail,
# "cancelled" → creation (iptal prefill'i ile).
# ============================================================================

const VIEW_PATHS := {
	"portfoy": "res://scripts/tabs/product/portfolio_view.gd",   # LOC-DATA sub-page id
	"creation": "res://scripts/tabs/product/creation_flow.gd",
	# "tracker" = kurma ekranının KİLİTLİ hali: build sürerken oyuncu neyi kurduğunu
	# görür, dokunamaz. Takip + iptal aynı ekranın durum kartında.
	"tracker": "res://scripts/tabs/product/creation_flow.gd",
	"detail": "res://scripts/tabs/product/detail_view.gd",
}

var _view_id: String = ""
var _view_node: Control = null


func _ready() -> void:
	for pair in _signal_map():
		(pair[0] as Signal).connect(pair[1])
	# Sekme değişiminde saklanan kurma TASLAĞI geri gelir — yalnız hâlâ bir taslağın
	# anlamlı olduğu durumda (build yok, ürün henüz çıkmamış).
	var draft: Dictionary = GameState.get_flag("creation_draft", {})
	if not draft.is_empty():
		GameState.flags.erase("creation_draft")
		if ProductSystem.get_active_build() == null and not bool(GameState.get_flag("mvp_shipped", false)):
			_navigate("creation", {"step": int(draft.get("step", 1)), "prefill": draft})
			return
	_navigate("portfoy", {})   # LOC-DATA sub-page id


func _exit_tree() -> void:
	for pair in _signal_map():
		var sig: Signal = pair[0]
		if sig.is_connected(pair[1]):
			sig.disconnect(pair[1])


func _signal_map() -> Array:
	# [Signal, Callable] çiftleri — connect/disconnect tek listeden. `unbind` eşit
	# Callable üretir, o yüzden disconnect yeniden kurulan listeyle eşleşir.
	var on_1: Callable = _on_state_changed.unbind(1)
	return [
		[EventBus.day_advanced, on_1],
		[EventBus.hour_changed, on_1],
		[EventBus.build_progress_changed, _on_state_changed],
		[EventBus.build_phase_changed, _on_build_phase_changed],
		[EventBus.mrr_changed, on_1],
		[EventBus.cash_changed, on_1],
		[EventBus.customer_added, on_1],
		[EventBus.customer_removed, on_1],
		[EventBus.customer_mrr_changed, _on_state_changed.unbind(2)],
		[EventBus.promise_created, on_1],
		[EventBus.promise_kept, on_1],
		[EventBus.promise_broken, on_1],
		[EventBus.rival_advanced, _on_state_changed],
		[EventBus.phase_changed, on_1],
	]


# --- Navigasyon -------------------------------------------------------------

func _navigate(view_id: String, args: Dictionary) -> void:
	if is_instance_valid(_view_node):
		_view_node.queue_free()
	if view_id == "tracker":
		args = {"locked": true}   # kilitli kurma görünümü (creation_flow tek sahip)
	var node: Control = (load(VIEW_PATHS[view_id]) as GDScript).new()
	node.name = "View_" + view_id
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_id = view_id
	_view_node = node
	add_child(node)  # önce add_child, sonra setup (ev konvansiyonu)
	node.navigate_requested.connect(_navigate)
	node.setup(args)


# --- Sinyal hunisi ----------------------------------------------------------

func _on_build_phase_changed(new_phase: String) -> void:
	# Rota düzeltmeleri: ship → detay; iptal → kurma ekranı adım 03 (seçim
	# prefill'i tek seferlik flag'den okunur ve tüketilir — yanlış-tık affı).
	match new_phase:
		"shipped":
			_navigate("detail", {})
		"cancelled":
			var prefill: Dictionary = GameState.get_flag("cancelled_build_prefill", {})
			GameState.flags.erase("cancelled_build_prefill")
			_navigate("creation", {"step": 3, "prefill": prefill})
		_:
			_on_state_changed()


func _on_state_changed() -> void:
	if not is_instance_valid(_view_node):
		return
	# Geçersiz-durum korkulukları: görünümün dayandığı state altından kaymışsa
	# repaint yerine güvenli rotaya dön.
	var shipped: bool = bool(GameState.get_flag("mvp_shipped", false))
	if _view_id == "detail" and not shipped:
		_navigate("portfoy", {})   # LOC-DATA sub-page id
		return
	if _view_id == "tracker" and ProductSystem.get_active_build() == null:
		_navigate("detail" if shipped else "portfoy", {})   # LOC-DATA sub-page id
		return
	_view_node.repaint()
