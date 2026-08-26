class_name RnDUiShared
extends RefCounted

# ============================================================================
# Ar-Ge sayfasının paylaşılan çizim parçaları (HRUiShared / ProductUiShared deseni:
# class_name + yalnız static, hiç durum tutmaz).
#
# BU KLASÖRÜN YASASI, HRUiShared'dan aynen devralındı: BURADA HİÇBİR SAYI
# TÜRETİLMEZ. Her değer bir motor çağrısından gelir (`RnDSystem.*`,
# `ResearchTree.*`, `ResearchSeam.*`); bu dosya onları düğüme çevirir, o kadar.
# Tek istisna BİÇİMLEME: kesir → yüzde, float gün → tavana yuvarlanmış tam sayı.
#
# TEMA: sıfır yeni `theme_type_variation`. Durum-bağımlı her stil KODDA kurulmuş
# `StyleBoxFlat`tır — team_panel.gd:31-34'ün yasalaşmış cümlesi ("tek seferlik
# şekiller için tema öğesi EKLEMEMEK sanksiyonlu desendir") ve THEME_STAMP bu
# yüzden 7'de duruyor. Ham `Color(...)` ve ham font boyutu yok.
#
# METİN: statikler `tr()` çağıramaz (Node metodu değil), o yüzden
# `TranslationServer.translate` — HRConstants._derived ve team_panel._t ile aynı
# gerekçe ve aynı davranış: çözülmeyen anahtar kendine döner, yani ekranda ham
# token görünür ve eksik anahtar SESSİZ kalmaz.
# ============================================================================

## §4 — aile başlığının anahtarı. Aile ADI ile ALAN ADI ayrı şeylerdir: aile
## Ar-Ge'nin kendi sözcüğü (YETENEK/PLATFORM/PRATİK/TASARIM), alan İK'nın cetveli
## (Ürün/Yazılım/Test/Tasarım). Tasarım ailesinde ikisi çakışır — sütun başlığı
## bu yüzden iki biçimlidir (bkz. column_header).
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

## Karo durumları — tek yerden okunur, beş tanedir ve BEŞ TANEDİR (onaylı R1).
## Nakit engeli BİR KARO DURUMU DEĞİLDİR: kırmızı yalnız panelin nakit satırında
## görünür (R8'in palet kuralı), yeşil ise bu sayfada hiç kullanılmaz.
const TILE_LOCKED := "locked"
const TILE_AVAILABLE := "available"
const TILE_RUNNING := "running"
const TILE_FROZEN := "frozen"
const TILE_DONE := "done"

const MARK_DONE := "✓"

# Karo iç ölçüleri. Kutu geometrisi RnDTreeView'ın; bunlar yalnız İÇ dolgu.
const TILE_PAD_X := 10
const TILE_PAD_Y := 8
const HEX_PX := 18
const STAR_PX := 11


# ---------------------------------------------------------------- metin

## Çözülmeyen anahtar kendine döner (ResearchSeam.node_name'in kanıtlanmış
## kalıbı) — bu yüzden "anahtar var mı" sorusunun cevabı da burada.
static func t(key: String) -> String:
	return TranslationServer.translate(key)


## İsteğe bağlı anahtar: çözülmezse yedeğe düşer. Düğüme özel maliyet etiketi
## gibi YALNIZ BAZI düğümlerde yazılmış metinler için (§8 · cost_label).
static func t_or(key: String, fallback: String) -> String:
	var out: String = TranslationServer.translate(key)
	return fallback if out == key else out


static func has_key(key: String) -> bool:
	return TranslationServer.translate(key) != key


## Ailenin BÜYÜK HARF başlığı. Fmt.upper yerelleşmiş büyütmedir (TR i→İ);
## ham to_upper() Tasarım'ı TASARIM yerine TASARIM'a çevirirken İngilizce'de
## sözcük bozar — tek ev Fmt.
static func family_caption(family: String) -> String:
	return Fmt.upper(t(String(FAMILY_KEY.get(family, ""))))


## Ailenin cümle içi adı (BÜYÜTÜLMEMİŞ). Sütun başlığı büyük harf ister, kart
## içindeki "{aile} · {mertebe}" satırı istemez — aynı sözcüğün iki kaydı var ve
## ikisi de tek anahtardan çözülür.
static func family_name(family: String) -> String:
	return t(String(FAMILY_KEY.get(family, "")))


## Ailenin okunduğu İK ALANININ adı (§5.2 FAMILY_AREA). Ar-Ge kendi kopyasını
## tutmaz: eşleme ResearchTree.FAMILY_AREA'da, etiket HRConstants'ta.
static func area_name(family: String) -> String:
	return HRConstants.area_label(String(ResearchTree.FAMILY_AREA.get(family, "")))


static func area_label(area_id: String) -> String:
	return HRConstants.area_label(area_id)


## Sütun başlığı — "{aile} · {alan} alanı · {bitti}/{toplam}".
## KEKELEME İSTİSNASI (onaylı R1): Tasarım ailesinde aile adı ile alan adı AYNI
## sözcüktür ("TASARIM · Tasarım alanı · 1/5" diye okunurdu). O sütun kısa biçime
## düşer ve "TASARIM · 1/5" olur. Karşılaştırma büyük harfte yapılır, çünkü iki
## metin farklı kaynaklardan geliyor ve yalnız kasada ayrışabilirler.
static func column_header(family: String, done: int, total: int) -> String:
	var fam: String = family_caption(family)
	var area: String = area_name(family)
	if Fmt.upper(area) == fam:
		return t("RND_COL_HEADER_SHORT").format({"family": fam, "done": done, "total": total})
	return t("RND_COL_HEADER").format({
		"family": fam, "area": area, "done": done, "total": total})


## Karonun mertebe yazısı: kök / dal / devam. Donmuşta aynı sözcük "donmuş" ile
## birleşir — birleştirme bir BİÇİM kararı değil, cümlenin kendisi, o yüzden
## ayraç kodda değil anahtarda yaşıyor (dil yasası: named placeholder, ham "·" yok).
static func tier_caption(node_id: String, frozen: bool = false) -> String:
	var tier: String = t(String(TIER_KEY.get(ResearchSeam.placement(node_id), "")))
	return t("RND_TIER_FROZEN").format({"tier": tier}) if frozen else tier


## Çapraz köşe işareti: "⇠ Tasarım". Ok anahtarın içinde (iki dilde de aynı glif).
static func cross_mark(source_node_id: String) -> String:
	return t("RND_CROSS_MARK").format({"area": area_name(ResearchSeam.family(source_node_id))})


## Kilitli yuvanın tek yazısı: "? Ürün" (§3 — ağacın ŞEKLİ görünür, ADI değil).
static func locked_caption(family: String) -> String:
	return t("RND_LOCKED_SLOT").format({"area": area_name(family)})


## Kalan gün. days_estimate -1.0 = "katkı yok" döner ve ASLA bölünmez (§5.5);
## çağıran o durumda bu fonksiyonu hiç çağırmaz, sebep satırını yazar.
static func days_text(days: float) -> String:
	return t("RND_DAYS_LEFT").format({"n": maxi(1, int(ceil(days)))})


## Kurucu-tek tahmini: "~9 gün (Kurucu)" (§5.5 · onaylı R2).
static func days_solo_text(days: float) -> String:
	return t("RND_DAYS_SOLO").format({"n": maxi(1, int(ceil(days)))})


## Yüzde: tek ev UiTokens.build_percent — barın sayısı ile yazının sayısı
## farklı yuvarlarsa aynı karede "%48" ile "%47" yan yana durur.
static func percent_text(progress: float) -> String:
	return t("PROD_PERCENT").format({"n": UiTokens.build_percent(progress)})


static func money(amount: int) -> String:
	return Fmt.money(amount)


# ---------------------------------------------------------------- durum

## Karonun beş durumundan hangisi. TEK EV: hem karo hem panel hem de efsane
## buradan okur, yoksa aynı düğüm iki yerde iki farklı şey görünür.
static func tile_state(node_id: String) -> String:
	var st: String = RnDSystem.state_of(node_id)
	if st == RnDSystem.STATE_DONE:
		return TILE_DONE
	if st == RnDSystem.STATE_ACTIVE:
		return TILE_FROZEN if RnDSystem.is_frozen() else TILE_RUNNING
	if st == RnDSystem.STATE_REVEALED:
		return TILE_AVAILABLE
	return TILE_LOCKED


## Durumun mürekkebi. AĞIRLIKLA okunur, RENKLE değil (direktör hükmü: aile rengi
## YOK) — bu yüzden tabloda amber yalnız KENAR'da, mürekkepte hiç yok.
static func state_ink(state: String) -> Color:
	match state:
		TILE_LOCKED: return UiTokens.INK_FAINT
		TILE_FROZEN: return UiTokens.INK_MUTED
		TILE_DONE: return UiTokens.INK_DIM
		_: return UiTokens.INK


## Panelin üst kenarındaki 2px şeridin rengi (R2). Koşan amber, araştırılabilir
## açık amber, donmuş nötr, tamamlanmış gri.
static func state_edge_color(state: String) -> Color:
	match state:
		TILE_RUNNING: return UiTokens.ACCENT
		TILE_AVAILABLE: return UiTokens.ACCENT_HOVER
		TILE_FROZEN: return UiTokens.BORDER_HOVER
		TILE_DONE: return UiTokens.CARD_BORDER
		_: return UiTokens.BORDER_DASHED


# ---------------------------------------------------------------- düğümler

## Bağ (link), buton DEĞİL: `duraklat` / `ata` onaylı R2'de altı çizili metin
## olarak duruyor. feature_lines_view.gd:355-362'nin birebir reçetesi —
## ACCENT mürekkep + MOUSE_FILTER_STOP + işaret parmağı + gui_input.
class Link extends Label:
	signal clicked

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton:
			var mb: InputEventMouseButton = event as InputEventMouseButton
			if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
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


## TEK GLİF, HER DÜĞÜMDE (direktör hükmü). Aile rengi yok, aile ikonu yok;
## hiyerarşi ÇİZGİ KALINLIĞINDAN okunur — kök kalın, dal orta, devam ince.
## `_draw` ile çiziliyor çünkü altıgen bir ikon dosyası eklemek yeni bir asset
## + import adımı demekti ve glif üç farklı kalınlıkta gerekiyor.
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


static func hex_glyph(node_id: String, color: Color, px: int = HEX_PX) -> Control:
	var g := HexGlyph.new()
	g.color = color
	match ResearchSeam.placement(node_id):
		ResearchSeam.PLACE_ROOT: g.weight = 2.0
		ResearchSeam.PLACE_BRANCH: g.weight = 1.5
		_: g.weight = 1.0
	g.custom_minimum_size = Vector2(px, px)
	g.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	g.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return g


## Efsane örneği. Metin tek başına "içi ailede kalan bağ" ile "çapraz bağ"ı
## ayırt ettiremez — örnek çizgiyi GÖSTERİR, sayfadaki çizgiyle aynı token ve
## aynı ritimle.
class Swatch extends Control:
	var kind: String = ""

	func _draw() -> void:
		var mid: float = size.y * 0.5
		match kind:
			"intra":
				draw_line(Vector2(0, mid), Vector2(size.x, mid), UiTokens.CARD_BORDER, 1.5)
			"cross":
				draw_dashed_line(Vector2(0, mid), Vector2(size.x, mid),
					UiTokens.ACCENT, 1.5, 4.0)
			"locked":
				# Kesikli dikdörtgen ELDE çiziliyor: iç sınıf, sarmalayan sınıfın
				# statiğine kendi adıyla uzanırdı ve o ad global sınıf önbelleği
				# tazelenmeden çözülmüyor (yeni class_name + headless tuzağı).
				var r := Rect2(Vector2(0.5, 2.5), Vector2(size.x - 1.0, size.y - 5.0))
				var col: Color = UiTokens.BORDER_DASHED
				draw_dashed_line(r.position, Vector2(r.end.x, r.position.y), col, 1.0, 3.0)
				draw_dashed_line(Vector2(r.end.x, r.position.y), r.end, col, 1.0, 3.0)
				draw_dashed_line(r.end, Vector2(r.position.x, r.end.y), col, 1.0, 3.0)
				draw_dashed_line(Vector2(r.position.x, r.end.y), r.position, col, 1.0, 3.0)
			"available":
				var r := Rect2(Vector2.ZERO, Vector2(size.x, size.y - 2.0))
				draw_rect(r, UiTokens.CARD_BG, true)
				draw_rect(r, UiTokens.ACCENT, false, 1.0)
				draw_rect(Rect2(r.position, Vector2(2.0, r.size.y)), UiTokens.ACCENT, true)
			"done":
				var rd := Rect2(Vector2.ZERO, Vector2(size.x, size.y - 2.0))
				draw_rect(rd, UiTokens.CARD_BG, true)
				draw_rect(rd, UiTokens.CARD_BORDER, false, 1.0)


static func swatch(kind: String, w: int = 22, h: int = 12) -> Control:
	var s := Swatch.new()
	s.kind = kind
	s.custom_minimum_size = Vector2(w, h)
	s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## Efsanenin tek maddesi: örnek + yazı.
static func legend_item(kind: String, text: String) -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", UiTokens.SPACE_S)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if kind != "":
		row.add_child(swatch(kind))
	row.add_child(UiFactory.make_label(text, &"MicroLabel", UiTokens.INK_DIM))
	return row


static func hairline(color: Color = UiTokens.DIVIDER_LIGHT) -> Panel:
	var line := Panel.new()
	line.custom_minimum_size = Vector2(0, 1)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sb := StyleBoxFlat.new()
	sb.bg_color = color
	sb.anti_aliasing = false
	line.add_theme_stylebox_override("panel", sb)
	return line


static func spacer() -> Control:
	var s := Control.new()
	s.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	s.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return s


## YÜZDE ÇAPALI DOLGU — build_bar.gd:243-251'in reçetesi. StyleBoxFlat bir yüzde
## İFADE EDEMEZ, o yüzden dolgu ayrı bir düğümdür: sola çapalı Panel, genişliği
## `anchor_right`. Kap `clip_contents` ile kırpar, yani kart genişleyince dolgu
## oranını korur ve elle yeniden boyutlandırma hiç gerekmez.
static func fill_host(out_refs: Dictionary, key: String) -> Control:
	var host := Control.new()
	host.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	host.clip_contents = true
	host.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var fill := Panel.new()
	fill.anchor_left = 0.0
	fill.anchor_top = 0.0
	fill.anchor_bottom = 1.0
	fill.anchor_right = 0.0
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


## Kesikli dikdörtgen. StyleBoxFlat kesikli kenar taşımaz; kilitli yuvanın
## çerçevesi bu yüzden karonun DEĞİL, tuvalin işi (RnDTreeView._draw).
static func draw_dashed_rect(ci: CanvasItem, r: Rect2, color: Color,
		width: float = 1.0, dash: float = 5.0) -> void:
	var a: Vector2 = r.position
	var b: Vector2 = Vector2(r.end.x, r.position.y)
	var c: Vector2 = r.end
	var d: Vector2 = Vector2(r.position.x, r.end.y)
	ci.draw_dashed_line(a, b, color, width, dash)
	ci.draw_dashed_line(b, c, color, width, dash)
	ci.draw_dashed_line(c, d, color, width, dash)
	ci.draw_dashed_line(d, a, color, width, dash)


static func is_left_click(ev: InputEvent) -> bool:
	if not (ev is InputEventMouseButton):
		return false
	var mb: InputEventMouseButton = ev as InputEventMouseButton
	return mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT
