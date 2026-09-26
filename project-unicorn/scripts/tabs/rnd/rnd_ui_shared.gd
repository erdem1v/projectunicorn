class_name RnDUiShared
extends RefCounted

# ============================================================================
# Ar-Ge sayfasının paylaşılan çizim parçaları (HRUiShared deseni: class_name +
# yalnız static, hiç durum tutmaz).
#
# BURADA HİÇBİR SAYI TÜRETİLMEZ. Her değer bir motor çağrısından gelir
# (`RnDSystem.*`, `ResearchTree.*`, `ResearchSeam.*`); bu dosya onları düğüme
# çevirir. Tek istisna BİÇİMLEME: kesir → yüzde, float gün → tavana yuvarlanmış
# tam sayı.
#
# TEMA: sıfır yeni `theme_type_variation`. Durum-bağımlı her stil KODDA kurulmuş
# `StyleBoxFlat`tır; tek seferlik şekiller için tema öğesi eklenmez (team_panel ile
# aynı kural), THEME_STAMP bu yüzden yerinde duruyor.
#
# METİN: statikler `tr()` çağıramaz, o yüzden `TranslationServer.translate`.
# Çözülmeyen anahtar kendine döner, yani eksik anahtar ekranda ham token olarak
# görünür ve SESSİZ kalmaz.
# ============================================================================

## §3 — aile başlığının anahtarı. Aile ADI ile ALAN ADI ayrı şeylerdir: aile
## Ar-Ge'nin kendi sözcüğü (İŞLEV/PLATFORM/SÜREÇ/TASARIM), alan İK'nın cetveli
## (Ürün/Yazılım/Test/Tasarım). Tasarım ailesinde ikisi çakışır (bkz. column_header).
const FAMILY_KEY := {
	ResearchSeam.FAMILY_CAPABILITY: "RND_FAMILY_CAPABILITY",
	ResearchSeam.FAMILY_PLATFORM: "RND_FAMILY_PLATFORM",
	ResearchSeam.FAMILY_PRACTICE: "RND_FAMILY_PRACTICE",
	ResearchSeam.FAMILY_DESIGN: "RND_FAMILY_DESIGN",
}

## §3 — kök / dal / devam. Karonun alt satırındaki mertebe yazısı.
const TIER_KEY := {
	ResearchSeam.PLACE_ROOT: "RND_PLACE_ROOT",
	ResearchSeam.PLACE_BRANCH: "RND_PLACE_BRANCH",
	ResearchSeam.PLACE_CONT: "RND_PLACE_CONT",
}

## Karo durumları, beş tane. Nakit engeli bir karo durumu DEĞİLDİR: kırmızı yalnız
## kartın nakit satırında görünür, yeşil bu sayfada hiç kullanılmaz.
const TILE_LOCKED := "locked"
const TILE_AVAILABLE := "available"
const TILE_RUNNING := "running"
const TILE_FROZEN := "frozen"
const TILE_DONE := "done"

const MARK_DONE := "✓"
const HEX_PX := 18


# ---------------------------------------------------------------- metin

## Çözülmeyen anahtar kendine döner (ResearchSeam.node_name'in kalıbı); t_or buna dayanır.
static func t(key: String) -> String:
	return TranslationServer.translate(key)


## İsteğe bağlı anahtar: çözülmezse yedeğe düşer. Yalnız BAZI düğümlerde yazılmış
## metinler için (ör. §8'in adlandırılmış maliyet etiketi).
static func t_or(key: String, fallback: String) -> String:
	var out: String = TranslationServer.translate(key)
	return fallback if out == key else out


## Ailenin anahtardaki adı; sütun başlığı bunu Fmt.upper'dan geçirir.
static func family_name(family: String) -> String:
	return t(String(FAMILY_KEY.get(family, "")))


## Ailenin okunduğu İK ALANININ adı (§5.2). Eşleme ResearchTree.FAMILY_AREA'da,
## etiket HRConstants'ta; Ar-Ge kendi kopyasını tutmaz.
static func area_name(family: String) -> String:
	return HRConstants.area_label(String(ResearchTree.FAMILY_AREA.get(family, "")))


## Düğümün okuduğu her alan için bir "{alan} alanı" parçası (§5.2).
static func area_parts(node_id: String) -> PackedStringArray:
	var parts := PackedStringArray()
	for area in ResearchTree.areas_of(node_id):
		parts.append(t("RND_AREA_OF").format({"area": HRConstants.area_label(String(area))}))
	return parts


## Sütun başlığı — "{aile} · {alan} alanı · {bitti}/{toplam}". Tasarım ailesinde aile
## adı ile alan adı AYNI sözcüktür ("TASARIM · Tasarım alanı"); o sütun kısa biçime
## düşer. Karşılaştırma büyük harfte, çünkü iki metin farklı kaynaklardan geliyor ve
## yalnız kasada ayrışabilirler. Fmt.upper yerelleşmiş büyütmedir: ham to_upper()
## Türkçe noktalı i'yi I yapar.
static func column_header(family: String, done: int, total: int) -> String:
	var fam: String = Fmt.upper(family_name(family))
	var area: String = area_name(family)
	if Fmt.upper(area) == fam:
		return t("RND_COL_HEADER_SHORT").format({"family": fam, "done": done, "total": total})
	return t("RND_COL_HEADER").format({"family": fam, "area": area, "done": done, "total": total})


## Karonun mertebe yazısı: kök / dal / devam, donmuşta "{mertebe} · donmuş". Ayraç
## cümlenin parçası, o yüzden kodda değil anahtarda yaşıyor.
static func tier_caption(node_id: String, frozen: bool = false) -> String:
	var tier: String = t(String(TIER_KEY.get(ResearchSeam.placement(node_id), "")))
	return t("RND_TIER_FROZEN").format({"tier": tier}) if frozen else tier


## Gün tahmini ekranda tavana yuvarlanır ve en az 1'dir; kart, panel ve çubuk aynı
## sayıyı göstersin diye tek yerde. -1.0 ("katkı yok", §5.5) buraya hiç gelmez:
## çağıran o durumda sayı yerine sebep satırını yazar.
static func whole_days(days: float) -> int:
	return maxi(1, int(ceil(days)))


static func days_text(days: float) -> String:
	return t("RND_DAYS_LEFT").format({"days": whole_days(days)})


## Yüzde: tek ev UiTokens.build_percent — barın sayısı ile yazının sayısı
## farklı yuvarlarsa aynı karede "%48" ile "%47" yan yana durur.
static func percent_text(progress: float) -> String:
	return t("PROD_PERCENT").format({"n": UiTokens.build_percent(progress)})


## Başlat'ın kapalı olma sebebi, oyuncunun cümlesiyle: hiçbir düğme sessizce sönmez
## (§5.3). Kartın engel satırı, kapalı Başlat'ın ipucu ve atama panelinin sebep
## satırı AYNI cümleyi buradan okur.
static func refusal_text(node_id: String, refusal: String) -> String:
	match refusal:
		RnDSystem.REFUSE_NOBODY:
			return t("RND_ASSIGN_PICK")
		RnDSystem.REFUSE_ZERO:
			return t("RND_ASSIGN_ZERO")
		RnDSystem.REFUSE_STARS:
			return t("RND_NEED_STARS").format({"n": ResearchTree.stars_of(node_id),
				"area": HRConstants.area_label(String(ResearchTree.areas_of(node_id)[0]))})
		RnDSystem.REFUSE_CASH:
			return t("RND_NEED_CASH").format({"amount": Fmt.money(ResearchTree.cash_of(node_id))})
		RnDSystem.REFUSE_CROSS:
			var src: String = ResearchTree.cross_of(node_id)
			return t("RND_NEED_CROSS_NAMED").format({
				"node": ResearchSeam.node_name(src), "family": family_name(ResearchSeam.family(src))})
		RnDSystem.REFUSE_LOCKED:
			return t("RND_NEED_PARENT").format({
				"node": ResearchSeam.node_name(ResearchTree.parent_of(node_id))})
	return t("RND_TREE_CLOSED")


# ---------------------------------------------------------------- durum

## Karonun beş durumundan hangisi. TEK EV: hem karo hem kart buradan okur, yoksa
## aynı düğüm iki yerde iki farklı şey görünür.
static func tile_state(node_id: String) -> String:
	match RnDSystem.state_of(node_id):
		RnDSystem.STATE_DONE: return TILE_DONE
		RnDSystem.STATE_ACTIVE: return TILE_FROZEN if RnDSystem.is_frozen() else TILE_RUNNING
		RnDSystem.STATE_REVEALED: return TILE_AVAILABLE
	return TILE_LOCKED


## Durumun mürekkebi. AĞIRLIKLA okunur, RENKLE değil (§3: aile rengi yok) — bu
## yüzden amber yalnız KENAR'da, mürekkepte hiç yok.
static func state_ink(state: String) -> Color:
	match state:
		TILE_LOCKED: return UiTokens.INK_FAINT
		TILE_FROZEN: return UiTokens.INK_MUTED
		TILE_DONE: return UiTokens.INK_DIM
		_: return UiTokens.INK


## Kartın üst kenarındaki 2px şeridin rengi.
static func state_edge_color(state: String) -> Color:
	match state:
		TILE_RUNNING: return UiTokens.ACCENT
		TILE_AVAILABLE: return UiTokens.ACCENT_HOVER
		TILE_FROZEN: return UiTokens.BORDER_HOVER
		TILE_DONE: return UiTokens.CARD_BORDER
		_: return UiTokens.BORDER_DASHED


# ---------------------------------------------------------------- düğümler

## Bağ (link), buton DEĞİL: `duraklat` / `ata` metin olarak duruyor
## (feature_lines_view'ın canlı bağlarıyla aynı reçete).
class Link extends Label:
	signal clicked

	func _gui_input(event: InputEvent) -> void:
		if RnDUiShared.is_left_click(event):
			accept_event()
			clicked.emit()


static func link(text: String) -> Link:
	var l := Link.new()
	l.theme_type_variation = &"RowMeta"
	l.text = text
	l.add_theme_color_override("font_color", UiTokens.ACCENT)
	l.mouse_filter = Control.MOUSE_FILTER_STOP
	l.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	l.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return l


## TEK GLİF, HER DÜĞÜMDE (§3: aile rengi yok, aile ikonu yok); hiyerarşi ÇİZGİ
## KALINLIĞINDAN okunur — kök kalın, dal orta, devam ince. `_draw` ile çiziliyor
## çünkü glif üç farklı kalınlıkta gerekiyor ve bir ikon dosyası bunu taşıyamaz.
class HexGlyph extends Control:
	var color: Color = UiTokens.INK
	var weight: float = 1.5

	func _draw() -> void:
		var r: float = minf(size.x, size.y) * 0.5 - weight
		if r <= 1.0:
			return
		var c: Vector2 = size * 0.5
		var pts := PackedVector2Array()
		for i in 6:
			var a: float = deg_to_rad(-90.0 + 60.0 * float(i))
			pts.append(c + Vector2(cos(a), sin(a)) * r)
		pts.append(pts[0])
		draw_polyline(pts, color, weight, true)


static func hex_glyph(node_id: String, color: Color) -> Control:
	var g := HexGlyph.new()
	g.color = color
	match ResearchSeam.placement(node_id):
		ResearchSeam.PLACE_ROOT: g.weight = 2.0
		ResearchSeam.PLACE_BRANCH: g.weight = 1.5
		_: g.weight = 1.0
	g.custom_minimum_size = Vector2(HEX_PX, HEX_PX)
	g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


## Efsane örneği. Metin tek başına "aile içi bağ" ile "çapraz bağ"ı ayırt ettiremez —
## örnek çizgiyi GÖSTERİR, sayfadaki çizgiyle aynı token ve aynı ritimle.
class Swatch extends Control:
	var kind: String = ""

	func _draw() -> void:
		var mid: float = size.y * 0.5
		match kind:
			"intra":
				draw_line(Vector2(0, mid), Vector2(size.x, mid), UiTokens.CARD_BORDER, 1.5)
			"cross":
				draw_dashed_line(Vector2(0, mid), Vector2(size.x, mid), UiTokens.ACCENT, 1.5, 4.0)
			"locked":
				RnDUiShared.draw_dashed_rect(self,
					Rect2(Vector2(0.5, 2.5), Vector2(size.x - 1.0, size.y - 5.0)),
					UiTokens.BORDER_DASHED, 1.0, 3.0)
			"available", "done":
				var r := Rect2(Vector2.ZERO, Vector2(size.x, size.y - 2.0))
				draw_rect(r, UiTokens.CARD_BG, true)
				draw_rect(r, UiTokens.ACCENT if kind == "available" else UiTokens.CARD_BORDER,
					false, 1.0)
				if kind == "available":
					draw_rect(Rect2(r.position, Vector2(2.0, r.size.y)), UiTokens.ACCENT, true)


## Efsanenin tek maddesi: örnek (kind "" ise yok) + yazı.
static func legend_item(kind: String, text: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if kind != "":
		var s := Swatch.new()
		s.kind = kind
		s.custom_minimum_size = Vector2(22, 12)
		s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		s.mouse_filter = Control.MOUSE_FILTER_IGNORE
		row.add_child(s)
	row.add_child(UiFactory.make_label(text, &"MicroLabel", UiTokens.INK_DIM))
	return row


static func spacer() -> Control:
	var s := Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## YÜZDE ÇAPALI DOLGU (build_bar'ın reçetesi). StyleBoxFlat bir yüzde İFADE EDEMEZ,
## o yüzden dolgu ayrı bir düğümdür: sola çapalı Panel, genişliği `anchor_right`.
## Kap `clip_contents` ile kırpar, yani kart genişleyince dolgu oranını korur ve
## elle yeniden boyutlandırma hiç gerekmez.
static func fill_host(out_refs: Dictionary, key: String) -> Control:
	var host := Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.clip_contents = true
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := Panel.new()
	fill.anchor_bottom = 1.0
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = UiTokens.AMBER_BG
	sb.set_corner_radius_all(UiTokens.RADIUS_NONE)
	sb.anti_aliasing = false
	fill.add_theme_stylebox_override("panel", sb)
	host.add_child(fill)
	out_refs[key] = fill
	return host


static func set_fill(fill: Panel, fraction: float) -> void:
	if fill != null and is_instance_valid(fill):
		fill.anchor_right = clampf(fraction, 0.0, 1.0)


## Kesikli dikdörtgen: StyleBoxFlat kesikli kenar taşımaz.
static func draw_dashed_rect(ci: CanvasItem, r: Rect2, color: Color,
		width: float = 1.0, dash: float = 5.0) -> void:
	var b := Vector2(r.end.x, r.position.y)
	var d := Vector2(r.position.x, r.end.y)
	ci.draw_dashed_line(r.position, b, color, width, dash)
	ci.draw_dashed_line(b, r.end, color, width, dash)
	ci.draw_dashed_line(r.end, d, color, width, dash)
	ci.draw_dashed_line(d, r.position, color, width, dash)


static func is_left_click(ev: InputEvent) -> bool:
	var mb := ev as InputEventMouseButton
	return mb != null and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
