# Writes the legal files that ship beside the exe into <dir>/LICENSES/, from the sources the Licenses
# screen reads: the running engine's own license and copyright data, and the packaged licence files.
#   "$GODOT" --headless --path . -s res://scripts/debug/write_licenses.gd -- <dir>
# The engine data comes from the binary that runs this, so run it with the binary that exported the build.
extends SceneTree

const FONT_FAMILIES := {
	"cond": "BarlowCondensed", "sans": "IBMPlexSans", "serif": "SourceSerif4",
	"mono": "JetBrainsMono", "fallback": "NotoSansSymbols2",
}
const LUCIDE := "res://assets/art/office/icons/LICENSE-lucide.txt"
const CC0_DIR := "res://assets/art/people/LICENSES/"
const LICENSES_SCREEN := preload("res://scripts/menu/licenses.gd")


# The work waits for the first frame: Localization loads the CSV in its _ready.
func _process(_delta: float) -> bool:
	var out: String = OS.get_cmdline_user_args()[0].path_join("LICENSES")
	DirAccess.make_dir_recursive_absolute(out.path_join("fonts"))
	DirAccess.make_dir_recursive_absolute(out.path_join("CC0"))
	var en: Translation = TranslationServer.get_translation_object("en")
	var files := {
		"GODOT_LICENSE.txt": Engine.get_license_text(),
		"GODOT_COPYRIGHT.txt": _copyright(),
		"LICENSE-lucide.txt": FileAccess.get_file_as_string(LUCIDE),
	}
	var notices := PackedStringArray([en.get_message(&"LIC_THIRD_PARTY"), "",
		en.get_message(&"LIC_FREETYPE").format({"year": LICENSES_SCREEN.freetype_year()}), "",
		en.get_message(&"LIC_GODOT_LOGO"), "", en.get_message(&"LIC_FONTS")])
	for dir in FONT_FAMILIES:
		var rel: String = "fonts/%s-OFL.txt" % FONT_FAMILIES[dir]
		files[rel] = FileAccess.get_file_as_string("res://assets/fonts/%s/OFL.txt" % dir)
		notices.append("%s (%s)" % [files[rel].get_slice("\n", 0).strip_edges(), rel])
	notices.append_array(["", en.get_message(&"LIC_ICONS"),
		"%s (LICENSE-lucide.txt)" % files["LICENSE-lucide.txt"].get_slice("\n", 2).strip_edges()])
	files["THIRD_PARTY_NOTICES.txt"] = "\n".join(notices) + "\n"
	for f in DirAccess.get_files_at(CC0_DIR):
		files["CC0/" + f] = FileAccess.get_file_as_string(CC0_DIR + f)
	for rel in files:
		FileAccess.open(out.path_join(rel), FileAccess.WRITE).store_string(files[rel])
	print("LICENSES|dir=%s|files=%d|components=%d" % [out, files.size(), Engine.get_copyright_info().size()])
	return true


## Godot's COPYRIGHT.txt layout (Debian copyright format) under a first line naming the engine version.
func _copyright() -> String:
	var lines := PackedStringArray([Engine.get_version_info().string, ""])
	for c in Engine.get_copyright_info():
		for part in c.parts:
			lines.append_array(["Files: " + " ".join(part.files), "Comment: " + c.name,
				"Copyright: " + "\n ".join(part.copyright), "License: " + part.license, ""])
	var licenses: Dictionary = Engine.get_license_info()
	for id in licenses:
		lines.append("License: " + id)
		for line in String(licenses[id]).split("\n"):
			lines.append(" " + line if line != "" else " .")
		lines.append("")
	return "\n".join(lines)
