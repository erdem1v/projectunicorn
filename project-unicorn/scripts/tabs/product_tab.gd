extends Control

# ============================================================================
# Product tab — Rev3 görünüm YÖNLENDİRİCİSİ (plan Step 9 "Scaffold").
# Dört görünüm: portfoy | creation | tracker | detail. Hepsi kod-kurulu
# (tscn yok) ve LAZY yüklenir — preload / class_name referansı YOK: tracker
# ve detail paralel ajanda iniyor, bu dosya onlarsız da parse edilmeli.
#
# Görünüm sözleşmesi (her view uygular):
#   func setup(args: Dictionary) -> void   — add_child SONRASI çağrılır (ev
#                                            konvansiyonu: populate-after-add_child)
#   func repaint() -> void                 — yerinde metin güncellemesi
#   signal navigate_requested(view_id: String, args: Dictionary)
#
# Açılış HER ZAMAN "portfoy" (center_viewport tab'ı her girişte yeniden kurar;
# görünüm state'i bilinçli olarak geçici). Rota düzeltmeleri build_phase_changed
# üzerinden: "shipped" → detail, "cancelled" → creation (iptal prefill'i ile).
# ============================================================================

const VIEW_PATHS := {
	"portfoy": "res://scripts/tabs/product/portfolio_view.gd",
	"creation": "res://scripts/tabs/product/creation_flow.gd",
	# "tracker" = kurma ekranının KİLİTLİ hali (eski kalıp: build sürerken oyuncu
	# neyi kurduğunu görür, dokunamaz) — ayrı boş tracker sayfası Erdem tarafından
	# reddedildi (2026-07-17). Takip + Yayınla/iptal aynı ekranın durum kartında
	# ve yüzen Build Takip Kartı'nda.
	"tracker": "res://scripts/tabs/product/creation_flow.gd",
	"detail": "res://scripts/tabs/product/detail_view.gd",
}

var _view_id: String = ""
var _view_node: Control = null


func _ready() -> void:
	for pair in _signal_map():
		(pair[0] as Signal).connect(pair[1])
	# Bekleyen iptal prefill'i taze mount'ta tüketilir: HUD kartının ✕'i başka
	# sekmedeyken kullanıldıysa "cancelled" emit'ini duyan router yoktu — flag
	# burada karşılanır (tek seferlik; canlı-instance yolu emit anında tüketir).
	var pf: Dictionary = GameState.get_flag("cancelled_build_prefill", {})
	if not pf.is_empty() and ProductSystem.get_active_build() == null:
		GameState.flags.erase("cancelled_build_prefill")
		_navigate("creation", {"step": 3, "prefill": pf})
		return
	_navigate("portfoy", {})


func _exit_tree() -> void:
	for pair in _signal_map():
		var sig: Signal = pair[0]
		if sig.is_connected(pair[1]):
			sig.disconnect(pair[1])


func _signal_map() -> Array:
	# [Signal, Callable] çiftleri — connect/disconnect tek listeden (§13.3).
	return [
		[EventBus.day_advanced, _on_changed_1],
		[EventBus.hour_changed, _on_changed_1],
		[EventBus.build_progress_changed, _on_changed_0],
		[EventBus.build_phase_changed, _on_build_phase_changed],
		[EventBus.mrr_changed, _on_changed_1],
		[EventBus.cash_changed, _on_changed_1],
		[EventBus.customer_added, _on_changed_1],
		[EventBus.customer_removed, _on_changed_1],
		[EventBus.customer_mrr_changed, _on_changed_2],
		[EventBus.promise_created, _on_changed_1],
		[EventBus.promise_kept, _on_changed_1],
		[EventBus.promise_broken, _on_changed_1],
		[EventBus.rival_advanced, _on_changed_0],
		[EventBus.phase_changed, _on_changed_1],
	]


# --- Navigasyon -------------------------------------------------------------

func _navigate(view_id: String, args: Dictionary) -> void:
	if is_instance_valid(_view_node):
		_view_node.queue_free()
	_view_node = null
	if view_id == "tracker":
		args = {"locked": true}   # kilitli kurma görünümü (creation_flow tek sahip)
	var path: String = String(VIEW_PATHS.get(view_id, ""))
	if path == "":
		push_warning("[ProductTab] bilinmeyen view id: %s" % view_id)
		return
	# LAZY load — tracker/detail dosyaları inmeden de bu script parse edilir;
	# eksik dosyaya navigasyon runtime'da uyarır, tab çökmez.
	var view_script: GDScript = load(path)
	if view_script == null:
		push_warning("[ProductTab] view script yok: %s" % path)
		return
	var node: Control = view_script.new()
	node.name = "View_" + view_id
	node.set_anchors_preset(Control.PRESET_FULL_RECT)
	_view_id = view_id
	_view_node = node
	add_child(node)  # önce add_child, sonra setup (ev konvansiyonu)
	if node.has_signal("navigate_requested"):
		node.navigate_requested.connect(_on_view_navigate)
	if node.has_method("setup"):
		node.setup(args)


func _on_view_navigate(view_id: String, args: Dictionary) -> void:
	_navigate(view_id, args)


# --- Sinyal hunisi ----------------------------------------------------------

func _on_changed_0() -> void:
	_on_state_changed()


func _on_changed_1(_a: Variant) -> void:
	_on_state_changed()


func _on_changed_2(_a: Variant, _b: Variant) -> void:
	_on_state_changed()


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
	if _view_id == "detail" and not GameState.get_flag("mvp_shipped", false):
		_navigate("portfoy", {})
		return
	if _view_id == "tracker" and ProductSystem.get_active_build() == null:
		if GameState.get_flag("mvp_shipped", false):
			_navigate("detail", {})
		else:
			_navigate("portfoy", {})
		return
	if _view_node.has_method("repaint"):
		_view_node.repaint()
