extends Button

## The returning player's way back: the newest save that opens, read as its company, week and cash. The button is
## the card; its content is a child it sizes itself to.

var slot_id := ""


## Shows `row` (a SaveManager.list_slots row); a run's week is its tick. The row's meta carries no company name.
func show_slot(row: Dictionary) -> void:
	slot_id = row.slot_id
	%Company.text = String(SaveManager.read_slot(slot_id).meta.get("company_name", ""))
	%Facts.text = tr("MENU_CARD_LINE").format({"week": row.meta.day, "cash": Fmt.money_exact(row.meta.cash)})
	custom_minimum_size.y = $Pad.get_combined_minimum_size().y
