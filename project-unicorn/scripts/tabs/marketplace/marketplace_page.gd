extends VBoxContainer

# Pazaryeri penceresinin gövdesi: başlığın üç ölçüsü, alt sayfa şeridi ve etkin alt sayfa. Sayfa durumu okur ve sahiplerinin
# seam'lerini tetikler, kendisi yazmaz. Alt sayfalar bir kez kurulur ve durumunu (seçili kategori, bekleyen seçim) kendi tutar;
# değişimde yalnız etkin olan kendini yeniden çizer.

## The sub-pages in the strip's order: [tab key, script]. A script is a VBoxContainer that repaints itself in `refresh()`.
const PAGES := [["MP_TAB_OVERVIEW", preload("res://scripts/tabs/marketplace/mp_overview.gd")]]
const PARTS := preload("res://scripts/tabs/marketplace/mp_parts.gd")

var _pages: Array[Control] = []
## The page the window opens on, an index into PAGES: Genel.
var _active := 0


func _init() -> void:
	for entry: Array in PAGES:
		var page: Control = (entry[1] as GDScript).new()
		_pages.append(page)
		add_child(page)


## The window header's three cells, empty until `paint_header` fills them.
static func header_cells() -> Array:
	return ["MP_KPI_USERS", "MP_KPI_STORES", "MP_KPI_ORDERS"].map(
		func(key: String) -> Control: return UiFactory.D_kpi(TranslationServer.translate(key), ""))


## Active users and stores, whole; last week's delivered orders written as Genel writes its weekly counts.
static func paint_header(cells: Array) -> void:
	var state := MarketplaceSystem.read_state()
	UiFactory.D_kpi_value(cells[0]).text = Fmt.group(roundi(state.users))
	UiFactory.D_kpi_value(cells[1]).text = Fmt.group(roundi(MarketplaceSystem.stores()))
	UiFactory.D_kpi_value(cells[2]).text = PARTS.count(MarketplaceModel.metrics(state, MarketplaceSystem.world()).orders)


## The sub-page strip.
func tabs() -> HBoxContainer:
	return UiFactory.D_seg_tabs(PAGES.map(func(entry: Array) -> String: return tr(entry[0])), _active, func(i: int) -> void:
		_active = i
		refresh())


func refresh() -> void:
	for i in _pages.size():
		_pages[i].visible = i == _active
		if i == _active:
			_pages[i].refresh()
