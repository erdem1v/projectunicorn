extends Panel

# Merkez alanın pencere yöneticisi. Arka plan (ilk çocuk) ofistir, ardından BuildHUD; üstlerinde en
# fazla bir birincil pencere (sekme) ve ona bağlı bir ayrıntı penceresi. Açık pencerenin altında
# ofis kararır. Ray bu katmanın sol kenarının üstüne biner: ofis, BuildHUD ve pencereler rayın
# canlı genişliğinin sağında kalır.
# Yuvalar sabit, sürükleme yok. tab_changed("") = pencere yok; kapatmanın üç yolu (×, Esc,
# aktif sekmeye tekrar tıklama) bu sinyale çıkar. Pencereler ModalLayer'a ASLA gitmez:
# game_shell orada Space/1-4'ü yutuyor, pencere açıkken hız kontrolü çalışmalı. Kurucunun
# toplantı yolculuğunda katmanda yalnız ofis kalır (set_veiled): pencereler kapanmadan gizlenir,
# dönüşte aynı pencere gelir.

const TAB_SCENES := {
	"product": preload("res://scenes/tabs/ProductTab.tscn"),
	"hr": preload("res://scenes/tabs/HRTab.tscn"),
	"sales": preload("res://scenes/tabs/SalesTab.tscn"),
	"finance": preload("res://scenes/tabs/FinanceTab.tscn"),  # Yatırım alt sayfası burada
	"piyasa": preload("res://scenes/tabs/PiyasaTab.tscn"),
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
const OFFICE := preload("res://scripts/ui/office/office_view.gd")
## 1920×1080 tabanında pencere boyları; pencere alanı daha darsa pencere ona sığacak kadar
## küçülür. Sahnesi olmayan sekme yer tutucunun (marketing) boyunu alır. Ekip 1352: kadronun EN
## sütunları; 1920'de BuildHUD'un 16 px solunda biter. Finans 1344 BuildHUD'un solunda biter; Ürün
## 1424 ona biner ve BuildHUD gizlenir; Piyasa da 1424, dar alanda liste ve kart kendi içinde kayar.
## `fit_height()` taşıyan sayfanın penceresi (Ekip, dosya)
## içeriği kadar uzar, boyu en çok buradaki kadardır. Kişisel 680'in altına inmez
## (`UiTokens.D_H_PERSONAL_BODY`); salt okunur şerit ve uzun hâller onu alan içinde uzatır. Ar-Ge
## ağaçla kısa, seçili düğümün kartıyla uzun açılır.
const SPECS := {
	"finance": Vector2(1344, 720), "hr": Vector2(1352, 928), "product": Vector2(1424, 928), "piyasa": Vector2(1424, 928),
	"sales": Vector2(1280, 760), "rnd": Vector2(1280, 928), "personal": Vector2(1000, 928),
	"events": Vector2(1240, 900), "marketing": Vector2(900, 640), "hr_dossier": Vector2(320, 928),
}
const EDGE := 24.0            # pencere ile pencere alanının (ray dışı merkez alan) kenarı arasındaki boşluk
## Ofis ve sayfalar ayrıntı penceresini bu gruptan açar: open_detail(kind, payload).
const GROUP := &"window_layer"

var _current_page: FRAME = null   # birincil pencere
var _detail: FRAME = null
var _primary_id: String = ""
var _detail_kind: String = ""
var _detail_payload: Dictionary = {}
var _veiled: bool = false

## Sol kenarın üstüne binen ray (GameShell'de kardeş); genişliği kipine göre değişir.
@export var rail: Control
@onready var _office: Control = $OfficeView
@onready var _build_hud: Control = $BuildHUD


func _ready() -> void:
	add_to_group(GROUP)
	EventBus.tab_changed.connect(open_primary)
	# Sayfa gövdeleri metnin çoğunu kodda besteler (tr().format, Fmt) ve semantik rengi kendi
	# _ready'lerinde override olarak basar; ikisi de kendiliğinden dönmez. Yerinde repaint
	# seam'i yok, tek kurulum yolu free-and-rebuild: açık pencereler yeniden kurulur.
	EventBus.palette_changed.connect(_rebuild.unbind(1))
	EventBus.language_changed.connect(_rebuild.unbind(1))
	resized.connect(_place)
	rail.resized.connect(_place)
	_place()


## tab_changed'in alıcısı: her şeyi kapatır, id boşsa ofis çıplak kalır, değilse o sekmenin
## penceresi açılır. Sekme açmak isteyen sinyali yayar, ray da onu dinliyor.
func open_primary(tab_id: String) -> void:
	_close_detail()
	if _current_page != null:
		# Kapanan sayfa tuttuğunu bırakır (ürün sekmesi sürüm notunda saati tutar).
		# propagate_call sayfaya VE onu uygulayan her torununa ulaşır.
		_current_page.propagate_call("on_page_closing")
		_current_page.queue_free()
		_current_page = null
	_primary_id = tab_id
	if _primary_id == "":
		_place()
		return
	var body: Control
	if TAB_SCENES.has(_primary_id):
		body = (TAB_SCENES[_primary_id] as PackedScene).instantiate()
	else:
		body = _placeholder(_primary_id)
	# The inbox is where a waiting decision is answered; every other window reads only while it waits.
	_current_page = FRAME.new(body, func() -> void: EventBus.tab_changed.emit(""), _primary_id != "events")
	_mount(_current_page)


## Birincile bağlı ayrıntı penceresi (aynı anda tek): alanın sağ üst köşesinde, birincilin yanında ya
## da dar alanda onun üstünde. Kapatma bu gövdeye bağlı: yerini yenisine bırakmış bir dosyanın geç
## isteği yenisini kapatmaz.
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


## Esc: önce ayrıntı, sonra birincil (× ile aynı kanal); birincil sayfa Esc'i önce kendisi
## kullanabilir (gelen kutusunda kurulu seçenek çözülür). Kapatacak pencere yoksa false.
func close_top() -> bool:
	if _detail == null and _current_page != null and _current_page.page.has_method(&"on_escape") \
			and _current_page.page.on_escape():
		return true
	if _detail != null:
		_close_detail()
	elif _current_page != null:
		EventBus.tab_changed.emit("")
	else:
		return false
	return true


## Örtülü katmanda yalnız ofis görünür: açık pencereler ve örtü sürerken açılanlar gizli kalır,
## ofisin üstündeki denetimler (BuildHUD, bildirim yığını, taşınma düğmesi) OfficeView'dan çekilir.
## Katmanın kendisi gizlenemez: yolculuk ofiste, yani onun ilk çocuğunda oynar.
func set_veiled(veiled: bool) -> void:
	_veiled = veiled
	for frame: Control in [_current_page, _detail]:
		if frame != null:
			frame.visible = not veiled
	get_tree().call_group(&"office_view", &"set_veiled", veiled)
	_place()


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
	_place()


func _rebuild() -> void:
	var kind: String = _detail_kind
	var payload: Dictionary = _detail_payload
	if _primary_id != "":
		open_primary(_primary_id)
	if kind != "":
		open_detail(kind, payload)


func _mount(frame: Control) -> void:
	frame.visible = not _veiled
	# A page that grows with its content says so, and the read-only strip changes its frame's height.
	if frame.page.has_signal(&"fit_changed"):
		frame.page.fit_changed.connect(_place)
		frame.minimum_size_changed.connect(_place)
	add_child(frame)
	_place()


## The window under a PanelLayer panel steps back: it dims as the office does, and its page gives up
## its amber (the page's on_panel_over).
func set_under(on: bool) -> void:
	if _current_page == null:
		return
	_current_page.modulate = Color(OFFICE.DIM, OFFICE.DIM, OFFICE.DIM) if on else Color.WHITE
	_current_page.page.propagate_call(&"on_panel_over", [on])


## A PanelLayer panel's global rect: at the area's top, centred on the open window and kept inside the
## area. With `cover`, a panel as wide as the window is at least as tall as it.
func panel_rect(want: Vector2, cover: bool) -> Rect2:
	var area: Rect2 = _area()
	var box: Vector2 = want.min(area.size)
	var mid: float = area.get_center().x
	if _current_page != null:
		mid = _current_page.get_rect().get_center().x
		if cover and box.x >= _current_page.size.x:
			box.y = clampf(_current_page.size.y, box.y, area.size.y)
	var x: float = clampf(mid - box.x / 2.0, area.position.x, area.end.x - box.x)
	return Rect2(global_position + Vector2(x, area.position.y), box)


## The window area: the centre right of the rail, EDGE inside it.
func _area() -> Rect2:
	var corner := Vector2(rail.get_rect().end.x - position.x + EDGE, EDGE)
	return Rect2(corner, size - Vector2(EDGE, EDGE) - corner)


## Ofis ve BuildHUD rayın sağındaki alanı alır; pencereler o alanın EDGE kadar içinde kalır.
## Birincil sol üstte, ayrıntı sağ üstte. Katman ya da ray yeniden boyutlanınca (arayüz ölçeği,
## rayın kipi) yeniden oturur.
func _place() -> void:
	var left: float = rail.get_rect().end.x - position.x
	_office.set_safe_left(left)
	_build_hud.offset_left = left
	var area: Rect2 = _area()
	if _current_page != null:
		_current_page.position = area.position
		_current_page.size = _fit(_current_page, SPECS.get(_primary_id, SPECS["marketing"]), area.size)
	if _detail != null:
		_detail.size = _fit(_detail, SPECS[_detail_kind], area.size)
		_detail.position = Vector2(maxf(area.end.x - _detail.size.x, area.position.x), area.position.y)
	_tell_floats()


## A page with fit_height() is as tall as its content plus the frame around it, up to its spec.
func _fit(frame: FRAME, spec: Vector2, room: Vector2) -> Vector2:
	if frame.page.has_method(&"fit_height"):
		var chrome: float = frame.get_combined_minimum_size().y - frame.page.get_combined_minimum_size().y
		spec.y = minf(spec.y, chrome + frame.page.fit_height())
	return spec.min(room)


## Ofisin üstündeki yüzen denetimler (office_overlays) üstlerine pencere binince gizlenir; görünen
## pencerelerin kapladığı alanı onlara söyler. Görünen pencere varken ofis kararır; yolculukta
## pencereler gizli olduğu için kararma da kalkar.
func _tell_floats() -> void:
	var cover := Rect2()
	for frame: Control in [_current_page, _detail]:
		if frame != null and frame.visible:
			cover = frame.get_global_rect() if not cover.has_area() else cover.merge(frame.get_global_rect())
	get_tree().call_group(&"office_overlays", &"set_window_cover", cover)
	_office.set_dimmed(cover.has_area())


## Sahnesi olmayan sekme: ortalanmış başlık + tek satır. Başlık id'den türer (TAB_ + ID),
## rayla aynı anahtar, ayrışamazlar.
func _placeholder(tab_id: String) -> Control:
	var body := Control.new()
	body.add_child(UiFactory.make_placeholder_column(
		Fmt.upper(tr("TAB_" + tab_id.to_upper())), tr("WIN_PAGE_PLACEHOLDER")))
	return body
