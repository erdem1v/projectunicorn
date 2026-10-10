class_name RnDUiShared
extends RefCounted

# ============================================================================
# Ar-Ge sayfasının paylaşılan parçaları, koyu dilde (HRUiShared deseni: class_name +
# yalnız static, hiç durum tutmaz).
#
# BURADA HİÇBİR SAYI TÜRETİLMEZ. Her değer bir motor çağrısından gelir
# (`RnDSystem.*`, `ResearchTree.*`, `ResearchSeam.*`); bu dosya onları düğüme
# çevirir. Tek istisna BİÇİMLEME: kesir → yüzde, float hafta → tavana yuvarlanmış
# tam sayı.
#
# METİN: statikler `tr()` çağıramaz, o yüzden `TranslationServer.translate`.
# Çözülmeyen anahtar kendine döner, yani eksik anahtar ekranda ham token olarak
# görünür ve SESSİZ kalmaz.
# ============================================================================

## §3 — aile başlığının anahtarı. Aile ADI ile ALAN ADI ayrı şeylerdir: aile
## Ar-Ge'nin kendi sözcüğü (İŞLEV/PLATFORM/SÜREÇ/TASARIM), alan İK'nın cetveli
## (Ürün/Yazılım/Test/Tasarım). Tasarım ailesinde ikisi çakışır.
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

## Karo durumları, beş tane. Nakit engeli bir karo durumu DEĞİLDİR: tehlike yalnız
## kartın nakit çipinde görünür. Araştırma bir zaman durumu değil: sayfada amber yok.
const TILE_LOCKED := "locked"
const TILE_AVAILABLE := "available"
const TILE_RUNNING := "running"
const TILE_FROZEN := "frozen"
const TILE_DONE := "done"

## Karonun adı, altıgeni ve kutusu durumuna göre (seçili karo kutusunu RndTileSelected'tan alır).
const TILE_LOOKS := {
	TILE_AVAILABLE: [UiTokens.D_INK_2, UiTokens.D_INK_2, &"RndTile"],
	TILE_RUNNING: [UiTokens.D_INK_1, UiTokens.D_INK_1, &"RndTileActive"],
	TILE_FROZEN: [UiTokens.D_INK_2, UiTokens.D_INK_3, &"RndTileFrozen"],
	TILE_DONE: [UiTokens.D_INK_3, UiTokens.D_INK_4, &"RndTileDone"],
}

const ICON := "res://assets/icons/rail/rnd.svg"
const STAR := "res://assets/icons/util/star_full.svg"
const PAUSE := "res://assets/icons/util/pause.svg"


# ---------------------------------------------------------------- metin

## Çözülmeyen anahtar kendine döner (ResearchSeam.node_name'in kalıbı); t_or buna dayanır.
static func t(key: String) -> String:
	return TranslationServer.translate(key)


## İsteğe bağlı anahtar: çözülmezse yedeğe düşer. Yalnız BAZI düğümlerde yazılmış
## metinler için (ör. §8'in adlandırılmış maliyet etiketi).
static func t_or(key: String, fallback: String) -> String:
	var out: String = TranslationServer.translate(key)
	return fallback if out == key else out


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


## Karonun mertebe yazısı: kök / dal / devam.
static func tier_caption(node_id: String) -> String:
	return t(String(TIER_KEY.get(ResearchSeam.placement(node_id), "")))


## Hafta tahmini ekranda tavana yuvarlanır ve en az 1'dir; kart, panel ve çubuk aynı
## sayıyı göstersin diye tek yerde. -1.0 ("katkı yok", §5.5) buraya hiç gelmez:
## çağıran o durumda sayı yerine sebep satırını yazar.
static func whole_weeks(weeks: float) -> int:
	return maxi(1, int(ceil(weeks)))


## Tavana yuvarlanmış hafta sayısı {n} olarak anahtarına ya da tekil ikizine girer.
static func weeks_line(key: String, weeks: float) -> String:
	var n: int = whole_weeks(weeks)
	return t(Fmt.count_key(key, n)).format({"n": n})


static func weeks_text(weeks: float) -> String:
	return weeks_line("RND_WEEKS_LEFT", weeks)


## Yüzde: tek ev UiTokens.build_percent — barın sayısı ile yazının sayısı
## farklı yuvarlarsa aynı karede "%48" ile "%47" yan yana durur.
static func percent_text(progress: float) -> String:
	return t("PROD_PERCENT").format({"n": UiTokens.build_percent(progress)})


## Başlat'ın kapalı olma sebebi, oyuncunun cümlesiyle: hiçbir düğme sessizce sönmez
## (§5.3). Kartın engel satırı ve atama panelinin sebep satırı AYNI cümleyi buradan okur;
## yıldızlı cümle yıldız glifiyle kurulur (refusal_line).
static func refusal_text(node_id: String, refusal: String) -> String:
	match refusal:
		RnDSystem.REFUSE_NOBODY:
			return t("RND_ASSIGN_PICK")
		RnDSystem.REFUSE_ZERO:
			return t("RND_ASSIGN_ZERO")
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


## The refusal as a line: the star rule's sentence with the star glyph, every other one in words.
static func refusal_line(node_id: String, refusal: String, variation: StringName, ink: Variant = null) -> Control:
	if refusal == RnDSystem.REFUSE_STARS:
		var area: String = HRConstants.area_label(RnDSystem.missing_star_area(node_id))
		return with_stars(t("RND_NEED_AREA").format({"area": area}), ResearchTree.stars_of(node_id), variation, ink)
	return UiFactory.make_label(refusal_text(node_id, refusal), variation, ink)


## A sentence whose `{stars}` is the rule's star glyph and its count: ★ is a rule unit, drawn as the glyph,
## since the dark faces carry no ★.
static func with_stars(text: String, stars: int, variation: StringName, ink: Variant = null) -> HBoxContainer:
	var parts: PackedStringArray = text.split("{stars}")
	var row := SprintUiShared.box(UiTokens.SPACE_XS)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if parts[0].strip_edges() != "":
		row.add_child(SprintUiShared.label(parts[0].strip_edges(), variation, ink))
	# The star and its count read as one unit.
	var unit := SprintUiShared.box(UiTokens.SPACE_XXS)
	unit.add_child(UiFactory.make_glyph(STAR, UiTokens.D_ICON_STAR, UiTokens.D_INK_2))
	unit.add_child(SprintUiShared.label(str(stars) + (parts[1] if parts.size() > 1 else ""), variation, ink))
	row.add_child(unit)
	return row


# ---------------------------------------------------------------- durum

## Karonun beş durumundan hangisi. TEK EV: hem karo hem kart buradan okur, yoksa
## aynı düğüm iki yerde iki farklı şey görünür.
static func tile_state(node_id: String) -> String:
	match RnDSystem.state_of(node_id):
		RnDSystem.STATE_DONE: return TILE_DONE
		RnDSystem.STATE_ACTIVE: return TILE_FROZEN if RnDSystem.is_frozen() else TILE_RUNNING
		RnDSystem.STATE_REVEALED: return TILE_AVAILABLE
	return TILE_LOCKED


# ---------------------------------------------------------------- düğümler

## TEK GLİF, HER DÜĞÜMDE (§3: aile rengi yok, aile ikonu yok); hiyerarşi ÇİZGİ
## KALINLIĞINDAN okunur — kök kalın, dal orta, devam ince. `_draw` ile çiziliyor
## çünkü glif üç farklı kalınlıkta gerekiyor ve bir ikon dosyası bunu taşıyamaz.
class HexGlyph extends Control:
	var color: Color
	var weight: float

	func _draw() -> void:
		var c: Vector2 = size * 0.5
		var h: Vector2 = UiTokens.D_RND_HEX
		draw_polyline(PackedVector2Array([c + Vector2(0.0, -h.y), c + Vector2(h.x, -h.y * 0.5), c + Vector2(h.x, h.y * 0.5),
			c + Vector2(0.0, h.y), c + Vector2(-h.x, h.y * 0.5), c + Vector2(-h.x, -h.y * 0.5), c + Vector2(0.0, -h.y)]),
			color, weight, true)


static func hex_glyph(node_id: String, color: Color) -> Control:
	var g := HexGlyph.new()
	g.color = color
	var s: Vector3 = UiTokens.D_RND_HEX_STROKE
	g.weight = {ResearchSeam.PLACE_ROOT: s.x, ResearchSeam.PLACE_BRANCH: s.y}.get(ResearchSeam.placement(node_id), s.z)
	g.custom_minimum_size = Vector2.ONE * UiTokens.D_ICON_PART
	g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


## The tree key's line sample: a link inside the family or a requirement from another.
class LineSwatch extends Control:
	var cross: bool

	func _draw() -> void:
		var mid := Vector2(0.0, size.y * 0.5)
		if cross:
			draw_dashed_line(mid, mid + Vector2(size.x, 0.0), UiTokens.D_INK_4, UiTokens.D_RND_LINE, UiTokens.D_RND_DOT)
		else:
			draw_line(mid, mid + Vector2(size.x, 0.0), UiTokens.D_LINE_3, UiTokens.D_RND_LINE)


## The tree key's one entry: its sample (the line, the dashed slot, a tile's box) and its words.
static func legend_item(kind: String, text: String) -> HBoxContainer:
	var sample: Control
	match kind:
		"intra", "cross":
			var line := LineSwatch.new()
			line.cross = kind == "cross"
			sample = line
		"locked":
			sample = Control.new()
			HRUiShared.D_dashed(sample)
		_:
			sample = Panel.new()
			sample.theme_type_variation = &"RndTileDone" if kind == "done" else &"RndTile"
	sample.custom_minimum_size = UiTokens.D_SWATCH
	sample.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_M)
	row.add_child(sample)
	row.add_child(UiFactory.make_label(text, &"Caption"))
	HRUiShared.set_mouse_ignore(row)
	return row


## The row's free width, or a fixed `width` gap.
static func spacer(width := 0) -> Control:
	var s := Control.new()
	s.custom_minimum_size.x = width
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL if width == 0 else Control.SIZE_SHRINK_BEGIN
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## The research's two links as the float card draws them, off while a decision waits: pause and assign while it runs.
## Freezing a frozen research is an empty click, so while it stands frozen the first link drops it.
static func links(frozen: bool, off: bool, on_pause: Callable, on_assign: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_XS)
	if frozen:
		row.add_child(_link(t("RND_ABANDON"), off, func() -> void: RnDSystem.abandon()))
	else:
		row.add_child(_link(t("RND_BAR_PAUSE"), off, on_pause))
	row.add_child(UiFactory.make_label("·", &"CaptionFaint"))
	row.add_child(_link(t("RND_ASSIGN_TITLE"), off, on_assign))
	for part: Control in row.get_children():
		part.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	return row


## A link is a text key; no focus: game_shell reads Space as the speed key.
static func _link(text: String, off: bool, on_press: Callable) -> Button:
	var b := Button.new()
	b.theme_type_variation = &"FloatLink"
	b.text = text
	b.focus_mode = Control.FOCUS_NONE
	b.disabled = off
	b.pressed.connect(on_press)
	return b
