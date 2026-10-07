extends SceneTree
# Run from a throwaway project: godot --headless --path <dir with a bare project.godot> -s godot_check.gd
# with ICON_DIR=<this folder> and ICON_OUT=<png>. Rasterises every icon SVG with Godot's own importer path (Image.load_svg_from_string) at 96, 24, 20 and 16 px
# and writes one contact sheet, to compare with Chrome.
func _init() -> void:
	var root := OS.get_environment("ICON_DIR")
	var out := OS.get_environment("ICON_OUT")
	var files: Array[String] = []
	for d in ["rail", "skill", "dept", "trait", "product", "stake", "util", "world", "place", "origin"]:
		var da := DirAccess.open(root + "/" + d)
		for f in da.get_files():
			if f.ends_with(".svg"):
				files.append(root + "/" + d + "/" + f)
	files.sort()
	var cols := 11
	var cw := 140
	var ch := 112
	var rows := int(ceil(files.size() / float(cols)))
	var sheet := Image.create(cols * cw, rows * ch, false, Image.FORMAT_RGBA8)
	sheet.fill(Color8(30, 27, 24))
	for i in files.size():
		var src := FileAccess.get_file_as_string(files[i]).replace("#FFFFFF", "#E9E4DA")
		var x := (i % cols) * cw + 4
		var y := (i / cols) * ch + 4
		for spec in [[96, 0, 0], [24, 100, 4], [16, 104, 40], [20, 102, 64]]:
			var img := Image.new()
			var err := img.load_svg_from_string(src, spec[0] / 24.0)
			if err != OK:
				print("FAIL ", files[i], " ", err)
				continue
			img.convert(Image.FORMAT_RGBA8)
			sheet.blend_rect(img, Rect2i(0, 0, img.get_width(), img.get_height()), Vector2i(x + spec[1], y + spec[2]))
	sheet.save_png(out)
	print("ok ", files.size())
	quit()
