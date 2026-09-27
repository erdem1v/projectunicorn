extends Panel

# Merkez alanın pencere yöneticisi. Arka plan (ilk çocuk) ofistir; üstünde en fazla bir birincil
# pencere (sekme) ve ona bağlı bir ayrıntı penceresi, hepsinin üstünde BuildHUD (son çocuk).
# Yuvalar sabit, sürükleme yok. tab_changed("") = pencere yok; kapatmanın üç yolu (×, Esc,
# aktif sekmeye tekrar tıklama) bu sinyale çıkar. Pencereler ModalLayer'a ASLA gitmez:
# game_shell orada Space/1-3'ü yutuyor, pencere açıkken hız kontrolü çalışmalı.

const TAB_SCENES := {
	"product": preload("res://scenes/tabs/ProductTab.tscn"),
	"hr": preload("res://scenes/tabs/HRTab.tscn"),
	"sales": preload("res://scenes/tabs/SalesTab.tscn"),
	"finance": preload("res://scenes/tabs/FinanceTab.tscn"),  # Yatırım alt sayfası burada
	"personal": preload("res://scenes/tabs/PersonalTab.tscn"),
	"rnd": preload("res://scenes/tabs/RnDTab.tscn"),
	"events": preload("res://scenes/tabs/EventsTab.tscn"),
}
## Ayrıntı sayfaları `populate(payload)` uygular.
const DETAILS := {
	"hr_dossier": preload("res://scripts/tabs/hr/hr_dossier.gd"),
}
# preload: global class cache'e bağımlılık yok (yeni class_name + headless tuzağı).
const FRAME := preload("res://scripts/ui/components/window_frame.gd")
## 1920×1080 tabanında pencere boyları; merkez alan daha darsa pencere ona sığacak kadar
## küçülür. Sahnesi olmayan sekme yer tutucunun (marketing) boyunu alır. Ekip 1200: defterin
## sabit sütunları ve ÇALIŞAN 1000'e sığmıyor.
const SPECS := {
	"finance": Vector2(1410, 700), "hr": Vector2(1200, 720), "product": Vector2(1280, 760),
	"sales": Vector2(1280, 760), "rnd": Vector2(1280, 780), "personal": Vector2(1000, 640),
	"events": Vector2(900, 640), "marketing": Vector2(900, 640), "hr_dossier": Vector2(380, 580),
}
const EDGE := 16.0            # pencere ile merkez alan kenarı arasındaki en az boşluk
const DETAIL_DROP := 130.0    # ayrıntı, birincilin üst kenarından bu kadar aşağıda başlar
const DETAIL_OVERHANG := 4.0  # ...ve sağ kenarından bu kadar taşar
## Ofis ve sayfalar ayrıntı penceresini bu gruptan açar: open_detail(kind, payload).
const GROUP := &"window_layer"

var _current_page: FRAME = null   # birincil pencere
var _detail: FRAME = null
var _primary_id: String = ""
var _detail_kind: String = ""
var _detail_payload: Dictionary = {}


func _ready() -> void:
	add_to_group(GROUP)
	EventBus.tab_changed.connect(open_primary)
	# Sayfa gövdeleri metnin çoğunu kodda besteler (tr().format, Fmt) ve semantik rengi kendi
	# _ready'lerinde override olarak basar; ikisi de kendiliğinden dönmez. Yerinde repaint
	# seam'i yok, tek kurulum yolu free-and-rebuild: açık pencereler yeniden kurulur.
	EventBus.palette_changed.connect(_rebuild.unbind(1))
	EventBus.language_changed.connect(_rebuild.unbind(1))
	resized.connect(_place)


## tab_changed'in alıcısı: her şeyi kapatır, id boşsa ofis çıplak kalır, değilse o sekmenin
## penceresi açılır. Sekme açmak isteyen sinyali yayar, ray da onu dinliyor.
func open_primary(tab_id: String) -> void:
	_close_detail()
	if _current_page != null:
		# Free-and-rebuild dil/palet yenilemesini kendi kendini iyileştiren şeydir; yarım taslak
		# o yüzden kapanışta saklanır (creation_flow.on_page_closing → GameState `creation_draft`)
		# ve ürün sekmesi bir sonraki açılışta geri yükler. propagate_call sayfaya VE onu
		# uygulayan her torununa ulaşır.
		_current_page.propagate_call("on_page_closing")
		_current_page.queue_free()
		_current_page = null
	_primary_id = tab_id
	if _primary_id == "":
		return
	var body: Control
	if TAB_SCENES.has(_primary_id):
		body = (TAB_SCENES[_primary_id] as PackedScene).instantiate()
	else:
		body = _placeholder(_primary_id)
	_current_page = FRAME.new(body, func() -> void: EventBus.tab_changed.emit(""))
	_mount(_current_page)


## Birincile bağlı ayrıntı penceresi (aynı anda tek); birincil yoksa onun yuvasına oturur.
## Kapatma bu gövdeye bağlı: yerini yenisine bırakmış bir dosyanın geç isteği yenisini kapatmaz.
func open_detail(kind: String, payload: Dictionary) -> void:
	_close_detail()
	var body: Control = (DETAILS[kind] as GDScript).new()
	_detail = FRAME.new(body, _close_detail.bind(body))
	_detail_kind = kind
	_detail_payload = payload
	_mount(_detail)
	body.populate(payload)   # önce add_child, sonra populate (ev konvansiyonu)
	if kind == "hr_dossier":
		get_tree().call_group(&"office_view", &"select_person", String(payload["character_id"]))


## Esc: önce ayrıntı, sonra birincil (× ile aynı kanal). Kapatacak pencere yoksa false.
func close_top() -> bool:
	if _detail != null:
		_close_detail()
	elif _current_page != null:
		EventBus.tab_changed.emit("")
	else:
		return false
	return true


## Harness erişimi: birincil pencerenin sayfası; pencere yoksa null.
func get_current_page_body() -> Control:
	return _current_page.page if _current_page != null else null


## Ofisteki seçim halkası açık dosyanın kişisini gösterir; dosya kapanınca halka da gider.
## `body` verilince yalnız o gövdenin penceresi kapanır.
func _close_detail(body: Control = null) -> void:
	if _detail == null or (body != null and _detail.page != body):
		return
	_detail.queue_free()
	_detail = null
	_detail_kind = ""
	get_tree().call_group(&"office_view", &"clear_selection")


func _rebuild() -> void:
	var kind: String = _detail_kind
	var payload: Dictionary = _detail_payload
	if _primary_id != "":
		open_primary(_primary_id)
	if kind != "":
		open_detail(kind, payload)


func _mount(frame: Control) -> void:
	add_child(frame)
	move_child(frame, get_child_count() - 2)   # BuildHUD (son çocuk) pencerelerin üstünde kalır
	_place()


## Birincil sol üstte; ayrıntı birincilin sağ kenarına biner. İkisi de merkez alanın EDGE
## kadar içinde kalır. Merkez alan yeniden boyutlanınca (arayüz ölçeği) yeniden oturur.
func _place() -> void:
	var corner := Vector2(EDGE, EDGE)
	var room: Vector2 = size - corner * 2.0
	if _current_page != null:
		_current_page.position = corner
		_current_page.size = (SPECS.get(_primary_id, SPECS["marketing"]) as Vector2).min(room)
	if _detail == null:
		return
	_detail.size = (SPECS[_detail_kind] as Vector2).min(room)
	var at: Vector2 = corner
	if _current_page != null:
		at = Vector2(_current_page.get_rect().end.x - _detail.size.x + DETAIL_OVERHANG,
			_current_page.position.y + DETAIL_DROP)
	_detail.position = at.clamp(corner, (size - corner - _detail.size).max(corner))


## Sahnesi olmayan sekme: ortalanmış başlık + tek satır. Başlık id'den türer (TAB_ + ID),
## rayla aynı anahtar, ayrışamazlar.
func _placeholder(tab_id: String) -> Control:
	var body := Control.new()
	body.add_child(UiFactory.make_placeholder_column(
		Fmt.upper(tr("TAB_" + tab_id.to_upper())), tr("WIN_PAGE_PLACEHOLDER")))
	return body
