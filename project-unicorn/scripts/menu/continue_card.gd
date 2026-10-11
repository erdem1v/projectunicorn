extends Button

## The returning player's way back: the newest save that opens, read as its company, week, cash and when it was
## played. The button is the card; its content is a child it sizes itself to.

const EMBLEM := 64.0

var slot_id := ""


## Shows `row` (a SaveManager.list_slots row); a run's week is its tick.
func show_slot(row: Dictionary) -> void:
	slot_id = row.slot_id
	%Emblem.custom_minimum_size = Vector2.ONE * EMBLEM
	%Emblem.configure(row.meta.logo)
	%Company.text = row.meta.company_name
	%Facts.text = tr("MENU_CARD_LINE").format({"week": row.meta.day, "cash": Fmt.money_exact(row.meta.cash)})
	%LastPlayed.text = tr("MENU_LAST_PLAYED").format({"when": Fmt.ago(row.meta.saved_msec / 1000)})
	custom_minimum_size.y = $Pad.get_combined_minimum_size().y
