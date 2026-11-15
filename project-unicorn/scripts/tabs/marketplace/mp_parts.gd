extends RefCounted

# Pazaryeri penceresinin sayfalarının ortak parçaları. Parçalar yalnız çizer; değeri ve eylemi çağıran verir.


## A row or a chip that opens a rich tip over itself when it has one (`build`); a table row with a tip lights while the pointer
## rests on it.
class TipRow extends PanelContainer:
	var build: Callable

	func _make_custom_tooltip(_for_text: String) -> Object:
		return build.call() if build.is_valid() else null

	func _notification(what: int) -> void:
		if build.is_valid() and theme_type_variation in [&"TableRow", &"TableRowHover"]:
			if what == NOTIFICATION_MOUSE_ENTER:
				theme_type_variation = &"TableRowHover"
			elif what == NOTIFICATION_MOUSE_EXIT:
				theme_type_variation = &"TableRow"


## A weekly order figure: one decimal under 10, so a small marketplace's gain does not read "+0"; grouped whole from there.
static func count(v: float) -> String:
	return Fmt.number(v, 1) if v < 10.0 else Fmt.group(roundi(v))


## A label of a fixed width: a column's cell in a table row.
static func cell(text: String, look: StringName, width: int, align: HorizontalAlignment, ink: Variant = null) -> Label:
	var label := SprintUiShared.label(text, look, ink)
	label.custom_minimum_size.x = width
	label.horizontal_alignment = align
	return label
