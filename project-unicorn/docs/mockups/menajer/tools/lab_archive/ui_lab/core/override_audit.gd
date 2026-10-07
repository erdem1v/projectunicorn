extends RefCounted

## Census of the theme items the sampled game nodes set in place of the theme, written to
## docs/audits/UI_OVERRIDES.md as the migration task's worklist. The node API cannot list its
## overrides, so every Control and Window is asked about a union of names: its class chain's items
## in Godot's default theme, every item name in master_theme.tres, and every literal name the
## project passes to add_theme_*_override or writes as theme_override_* in a scene.

## kind -> [Theme data type, column label]
const KINDS := {
	"color": [Theme.DATA_TYPE_COLOR, "renk"],
	"font": [Theme.DATA_TYPE_FONT, "font"],
	"font_size": [Theme.DATA_TYPE_FONT_SIZE, "font boyutu"],
	"constant": [Theme.DATA_TYPE_CONSTANT, "sabit"],
	"stylebox": [Theme.DATA_TYPE_STYLEBOX, "kutu"],
	"icon": [Theme.DATA_TYPE_ICON, "ikon"],
}
const SCENE_KEYS := {"colors": "color", "fonts": "font", "font_sizes": "font_size",
	"constants": "constant", "styles": "stylebox", "icons": "icon"}
## Constants the UI law leaves to scenes and scripts (with margin_*); every other override is visual.
const LAYOUT_CONSTANTS := ["separation", "h_separation", "v_separation"]

var _shared := {}         # kind -> {name: true}: master_theme.tres item names + literal override names
var _by_class := {}       # native class -> kind -> names probed on it
var _rows := {}           # "scene \t node \t kind \t item" -> {value: true}; screens can differ in value
var _outside := {}        # look set outside the theme, seen in the walk: "what · node" -> {value: true}
var _screens: PackedStringArray = []
var _calls := {}          # script -> kind -> add_theme_*_override call sites
var _reads := {}          # label -> ["file:line", ...]


func _init() -> void:
	for kind in KINDS:
		_shared[kind] = {}
	var master := ThemeDB.get_project_theme()
	for type in master.get_type_list():
		for kind in KINDS:
			for item in master.get_theme_item_list(KINDS[kind][0], type):
				_shared[kind][StringName(item)] = true
	var setter := RegEx.create_from_string(
		"add_theme_(color|font_size|font|constant|stylebox|icon)_override\\(\\s*(?:&?\"([^\"]+)\")?")
	var reads := {
		"ThemeDB.get_project_theme()": RegEx.create_from_string("ThemeDB\\.get_project_theme\\("),
		"get_theme_*()": RegEx.create_from_string("\\bget_theme_(?:stylebox|color|font_size|font|constant|icon)\\("),
		"_draw / draw.connect": RegEx.create_from_string("func _draw\\(|\\.draw\\.connect\\("),
		"[color=": RegEx.create_from_string("\\[color="),
	}
	for label in reads:
		_reads[label] = []
	for path in _files("res://scripts", "gd"):
		var lines := FileAccess.get_file_as_string(path).split("\n")
		for i in lines.size():
			if lines[i].strip_edges().begins_with("#"):
				continue
			for m in setter.search_all(lines[i]):
				var counts: Dictionary = _calls.get_or_add(path, {})
				counts[m.get_string(1)] = counts.get(m.get_string(1), 0) + 1
				if m.get_string(2) != "":
					_shared[m.get_string(1)][StringName(m.get_string(2))] = true
			for label in reads:
				if (reads[label] as RegEx).search(lines[i]) != null:
					_reads[label].append("%s:%d" % [path, i + 1])
	var key := RegEx.create_from_string("theme_override_(colors|fonts|font_sizes|constants|styles|icons)/(\\w+)")
	for path in _files("res://scenes", "tscn"):
		for m in key.search_all(FileAccess.get_file_as_string(path)):
			_shared[SCENE_KEYS[m.get_string(1)]][StringName(m.get_string(2))] = true


func walk(root: Node, screen: String) -> void:
	if not _screens.has(screen):
		_screens.append(screen)
	_visit(root, root)


## Writes the map unless the file already holds this text. False when it cannot be written.
func write(path: String) -> bool:
	var text := render()
	var same := FileAccess.file_exists(path) and FileAccess.get_file_as_string(path) == text
	if not same:
		DirAccess.make_dir_recursive_absolute(path.get_base_dir())
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f == null:
			print("UI_LAB|AUDIT_FAIL|%s|%s" % [path, error_string(FileAccess.get_open_error())])
			return false
		f.store_string(text)
	var layout := _rows.keys().filter(func(row: String) -> bool: return _is_layout(row)).size()
	print("UI_LAB|AUDIT|%s|rows=%d|visual=%d|layout=%d|sha1=%s|written=%d" % [path, _rows.size(),
		_rows.size() - layout, layout, text.sha1_text(), int(not same)])
	return true


func render() -> String:
	var per_scene := {}   # scene -> [visual, layout]
	var keys := _rows.keys()
	keys.sort()
	for row: String in keys:
		var counts: Array = per_scene.get_or_add(row.get_slice("\t", 0), [0, 0])
		counts[1 if _is_layout(row) else 0] += 1
	var scenes := per_scene.keys()
	scenes.sort_custom(func(a: String, b: String) -> bool:
		var ta: int = per_scene[a][0] + per_scene[a][1]
		var tb: int = per_scene[b][0] + per_scene[b][1]
		return ta > tb or (ta == tb and a < b))
	var names: PackedStringArray = []
	for kind in KINDS:
		names.append("%s %d" % [KINDS[kind][1], _shared[kind].size()])
	var out: PackedStringArray = [
		"# Satır içi tema override haritası",
		"",
		"UI LAB'ın ürettiği denetim (`sandbox/ui_lab/core/override_audit.gd`). Laboratuvar her açılışta yeniden üretir, içerik değişmediyse dosyaya dokunmaz; elle düzenlenmez. Taşıma görevinin iş listesidir: bu görevde hiçbir override kaldırılmaz.",
		"",
		"- Veri: `main.gd` `_seed_theme_surface` tohumu %d, gün %d, ofis %s, saat %02d:00." % [
			GameState.run_seed, GameState.day, GameState.office_id, GameState.current_hour],
		"- Renk körü paleti: %s. Oyuncunun ayarıdır; koddan basılan anlamsal renkler ona göre yazılır." % [
			"açık" if UiTokens.is_colorblind() else "kapalı"],
		"- Tema: mevcut. Laboratuvar kökünde tema yok, her şey proje temasından (`themes/master_theme.tres`) çözülür.",
		"- Gezilen ekranlar: %s. Yalnız oyun düğümleri: GameShell alt ağacı ve olay modalı, Window'lar dahil." % ", ".join(_screens),
		"- Yoklama: düğüm API'si override listesi vermez. Her Control ve Window'a sınıf zincirinin Godot varsayılan temasındaki öğe adları, master temadaki bütün öğe adları ve `scripts/` ile `scenes/` içinde `add_theme_*_override(\"…\")` ya da `theme_override_*/…` olarak geçen her sabit ad sorulur. Zincir dışı ortak ad sayısı: %s." % ", ".join(names),
		"- Değer: renk `#RRGGBBAA`; font ve ikon kaynak yolu (yolsuzsa sınıfı); boyut ve sabit sayı; kutuda dolgu, kenar, köşe, gölge, taşma ve etkin iç boşluk (sol, üst, sağ, alt).",
		"- Sınıf: `separation`, `h_separation`, `v_separation` ve `margin_*` sabitleri yerleşimdir (UI yasası izinli); gerisi görseldir (temaya taşınacak).",
		"- Sahne: düğümün ait olduğu sahne dosyası; kodla kurulan düğümde `kod · <script>`, yani onu taşıyan en yakın script. Düğüm yolu gezinin kökünden başlar; adsız düğüm `Sınıf#sıra` yazılır, çünkü Godot'un verdiği `@Sınıf@N` adı koşudan koşuya değişir.",
		"",
		"## Satırlar",
	]
	var current := ""
	for row: String in keys:
		var f := row.split("\t")
		if f[0] != current:
			current = f[0]
			out.append_array(["", "### `%s`" % current, "", "| Düğüm | Tür | Öğe | Değer | Sınıf |",
				"|---|---|---|---|---|"])
		out.append("| `%s` | %s | `%s` | %s | %s |" % [f[1], KINDS[f[2]][1], f[3],
			_joined(_rows[row]).replace("|", "\\|"), "yerleşim" if _is_layout(row) else "görsel"])
	out.append_array(["", "## Sahne başına sayım", "", "| Sahne | Görsel | Yerleşim | Toplam |", "|---|---:|---:|---:|"])
	var visual := 0
	var layout := 0
	for scene: String in scenes:
		var c: Array = per_scene[scene]
		out.append("| `%s` | %d | %d | %d |" % [scene, c[0], c[1], c[0] + c[1]])
		visual += c[0]
		layout += c[1]
	out.append("| **Toplam** | %d | %d | %d |" % [visual, layout, visual + layout])
	out.append_array(["", "## En çok override taşıyan üç sahne", ""])
	for i in mini(3, scenes.size()):
		var c: Array = per_scene[scenes[i]]
		out.append("%d. `%s`: %d (görsel %d, yerleşim %d)" % [i + 1, scenes[i], c[0] + c[1], c[0], c[1]])
	out.append_array(["", "## Ek A: tema dışında kalan görünüm (gezide görülen)", "",
		"Tema değişince bunlar değişmez: kodda boyanan `ColorRect`, beyaz olmayan `modulate`, BBCode rengi taşıyan metin.", ""])
	var outside := _outside.keys()
	outside.sort()
	for line: String in outside:
		out.append("- %s · %s" % [line, _joined(_outside[line])])
	out.append_array(["", "## Ek B: temayı kodda okuyan ya da tema dışında çizen yerler (statik, `scripts/`)", "",
		"`get_theme_*()` okuması yapıldığı andaki temayı dondurur; düğüm ağaca girmeden okuyan kurulum kodu (ör. `hr_ui_shared.gd` moral çubuğu) laboratuvar temasını hiç görmez. `ThemeDB.get_project_theme()` okuyan her zaman master'ı görür."])
	for label: String in _reads:
		out.append_array(["", "### `%s`" % label, ""])
		for site: String in _reads[label]:
			out.append("- `%s`" % site)
	out.append_array(["", "## Ek C: `add_theme_*_override` çağrı yerleri (statik, `scripts/`)", "",
		"Gezinin görmediği ekranlar dahil bütün scriptler. Çağrı yeri sayılır: döngüdeki tek çağrı bir kez sayılır, çalışma anında birçok düğüme düşebilir.",
		"", "| Script | renk | font | font boyutu | sabit | kutu | ikon | Toplam |",
		"|---|---:|---:|---:|---:|---:|---:|---:|"])
	var totals := {}
	var files := _calls.keys()
	files.sort()
	for file: String in files:
		var cells: PackedStringArray = []
		var sum := 0
		for kind in KINDS:
			var n: int = _calls[file].get(kind, 0)
			cells.append(str(n))
			sum += n
			totals[kind] = totals.get(kind, 0) + n
		out.append("| `%s` | %s | %d |" % [file, " | ".join(cells), sum])
	var total_cells: PackedStringArray = []
	var grand := 0
	for kind in KINDS:
		total_cells.append(str(totals.get(kind, 0)))
		grand += totals.get(kind, 0)
	out.append("| **Toplam** | %s | %d |" % [" | ".join(total_cells), grand])
	return "\n".join(out) + "\n"


func _visit(n: Node, root: Node) -> void:
	if n is Control or n is Window:
		_probe(n, root)
	if n is ColorRect:
		_seen_outside("ColorRect", n, root, _hex((n as ColorRect).color))
	if n is CanvasItem:
		var item := n as CanvasItem
		if item.modulate != Color.WHITE:
			_seen_outside("modulate", n, root, _hex(item.modulate))
		if item.self_modulate != Color.WHITE:
			_seen_outside("self_modulate", n, root, _hex(item.self_modulate))
	if n is RichTextLabel and (n as RichTextLabel).text.contains("[color="):
		_seen_outside("BBCode", n, root, "`[color=`")
	for child in n.get_children():
		_visit(child, root)


func _probe(n: Node, root: Node) -> void:
	var names: Dictionary = _names_for(n.get_class())
	for item: StringName in names["color"]:
		if n.has_theme_color_override(item):
			_row(n, root, "color", item, _hex(n.get_theme_color(item)))
	for item: StringName in names["font"]:
		if n.has_theme_font_override(item):
			_row(n, root, "font", item, _res(n.get_theme_font(item)))
	for item: StringName in names["font_size"]:
		if n.has_theme_font_size_override(item):
			_row(n, root, "font_size", item, str(n.get_theme_font_size(item)))
	for item: StringName in names["constant"]:
		if n.has_theme_constant_override(item):
			_row(n, root, "constant", item, str(n.get_theme_constant(item)))
	for item: StringName in names["stylebox"]:
		if n.has_theme_stylebox_override(item):
			_row(n, root, "stylebox", item, _box(n.get_theme_stylebox(item)))
	for item: StringName in names["icon"]:
		if n.has_theme_icon_override(item):
			_row(n, root, "icon", item, _res(n.get_theme_icon(item)))


func _names_for(cls: String) -> Dictionary:
	if not _by_class.has(cls):
		var fallback := ThemeDB.get_default_theme()
		var names := {}
		for kind in KINDS:
			var seen: Dictionary = _shared[kind].duplicate()
			var c := cls
			while c != "":
				for item in fallback.get_theme_item_list(KINDS[kind][0], c):
					seen[StringName(item)] = true
				c = ClassDB.get_parent_class(c)
			names[kind] = seen.keys()
		_by_class[cls] = names
	return _by_class[cls]


func _row(n: Node, root: Node, kind: String, item: StringName, value: String) -> void:
	(_rows.get_or_add("\t".join([_scene_of(n), _path(n, root), kind, String(item)]), {}) as Dictionary)[value] = true


func _seen_outside(what: String, n: Node, root: Node, value: String) -> void:
	(_outside.get_or_add("%s · `%s`" % [what, _path(n, root)], {}) as Dictionary)[value] = true


static func _is_layout(row: String) -> bool:
	var item := row.get_slice("\t", 3)
	return row.get_slice("\t", 2) == "constant" and (item in LAYOUT_CONSTANTS or item.begins_with("margin_"))


static func _joined(values: Dictionary) -> String:
	var list := values.keys()
	list.sort()
	return "; ".join(list)


static func _scene_of(n: Node) -> String:
	var at: Node = n if n.scene_file_path != "" or n.owner == null else n.owner
	if at.scene_file_path != "":
		return at.scene_file_path
	# Every walk root (GameShell, EventModal) carries a script, so the climb ends at one.
	at = n
	while at.get_script() == null:
		at = at.get_parent()
	return "kod · " + (at.get_script() as Script).resource_path


static func _path(n: Node, root: Node) -> String:
	var parts: PackedStringArray = []
	var at := n
	while true:
		var nm := String(at.name)
		parts.append("%s#%d" % [at.get_class(), at.get_index()] if nm.begins_with("@") else nm)
		if at == root:
			break
		at = at.get_parent()
	parts.reverse()
	return "/".join(parts)


static func _box(sb: StyleBox) -> String:
	var pad := "iç " + _quad(sb.get_margin(SIDE_LEFT), sb.get_margin(SIDE_TOP),
		sb.get_margin(SIDE_RIGHT), sb.get_margin(SIDE_BOTTOM))
	if sb is StyleBoxFlat:
		var f := sb as StyleBoxFlat
		var parts: PackedStringArray = ["Flat", "dolgu " + _hex(f.bg_color) if f.draw_center else "dolgusuz"]
		if f.border_width_left + f.border_width_top + f.border_width_right + f.border_width_bottom > 0:
			parts.append("kenar %s %s" % [_hex(f.border_color), _quad(f.border_width_left,
				f.border_width_top, f.border_width_right, f.border_width_bottom)])
		if f.corner_radius_top_left + f.corner_radius_top_right + f.corner_radius_bottom_right \
				+ f.corner_radius_bottom_left > 0:
			parts.append("köşe " + _quad(f.corner_radius_top_left, f.corner_radius_top_right,
				f.corner_radius_bottom_right, f.corner_radius_bottom_left))
		if f.shadow_size > 0:
			parts.append("gölge %d %s" % [f.shadow_size, _hex(f.shadow_color)])
		if f.expand_margin_left + f.expand_margin_top + f.expand_margin_right + f.expand_margin_bottom > 0.0:
			parts.append("taşma " + _quad(f.expand_margin_left, f.expand_margin_top,
				f.expand_margin_right, f.expand_margin_bottom))
		parts.append(pad)
		return " ".join(parts)
	if sb is StyleBoxLine:
		var line := sb as StyleBoxLine
		return "Line %s %dpx%s" % [_hex(line.color), line.thickness, " dikey" if line.vertical else ""]
	if sb is StyleBoxTexture:
		return "Texture %s %s" % [_res((sb as StyleBoxTexture).texture), pad]
	return "%s %s" % [sb.get_class(), pad]


static func _quad(a: float, b: float, c: float, d: float) -> String:
	return ",".join([_num(a), _num(b), _num(c), _num(d)])


static func _num(v: float) -> String:
	return str(int(v)) if is_equal_approx(v, roundf(v)) else "%.2f" % v


static func _hex(c: Color) -> String:
	return "#" + c.to_html().to_upper()


static func _res(r: Resource) -> String:
	if r == null:
		return "null"
	return r.resource_path if r.resource_path != "" else r.get_class()


static func _files(dir: String, ext: String) -> PackedStringArray:
	var out: PackedStringArray = []
	for f in DirAccess.get_files_at(dir):
		if f.get_extension() == ext:
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		out.append_array(_files(dir.path_join(d), ext))
	out.sort()
	return out
