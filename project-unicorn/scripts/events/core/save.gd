class_name EvSave
extends RefCounted

# THE ENGINE'S SAVE BLOCK (GDD §16.1). One dictionary gathered from every store.
#
# The CATALOGUE is deliberately out: cards and arcs are disk content re-read at every boot, and
# persisting them would freeze a content edit out of every existing save.
#
# SCALARS ONLY. `Character` extends Resource, so an entity stored as an object rather than an id
# would be serialised whole and come back on load as a private copy of someone who left — the
# resurrection §20 A2 forbids. `verify_no_resources()` checks for it and a smoke case calls it.
#
# RESTORE ORDER: flags and history first, latches before the queue, because the later restores
# validate against the catalogue and may ask what has already happened.

const BLOCK_KEY := "event_engine"
const BLOCK_VERSION := 1


static func to_dict() -> Dictionary:
	var block: Dictionary = {
		"version": BLOCK_VERSION,
		"run_seed": GameState.run_seed,
	}
	block.merge(EvFlags.to_dict())
	block.merge(EvHistory.to_dict())
	block.merge(EvLatches.to_dict())
	block.merge(EvSchedule.to_dict())
	block.merge(EvArcs.to_dict())
	block.merge(EvQueue.to_dict())
	block.merge(EvPapers.to_dict())
	block.merge(EvBudgets.to_dict())
	block.merge(EvTicker.to_dict())
	block.merge(EvTempo.to_dict())
	return block


static func from_dict(block: Dictionary) -> void:
	# §16.4: a corrupt or absent block starts an empty engine, logs, and does NOT crash. The
	# run continues — a player whose engine state is gone still has a company.
	if block.is_empty():
		reset()
		return
	if int(block.get("version", 0)) != BLOCK_VERSION:
		push_error("[EvSave] engine block is version %s, expected %d — starting empty"
			% [block.get("version", "?"), BLOCK_VERSION])
		reset()
		return

	EvFlags.from_dict(block)
	EvHistory.from_dict(block)
	EvLatches.from_dict(block)
	EvSchedule.from_dict(block)
	EvArcs.from_dict(block)
	EvQueue.from_dict(block)
	EvPapers.from_dict(block)
	EvBudgets.from_dict(block)
	EvTicker.from_dict(block)
	EvTempo.from_dict(block)


static func reset() -> void:
	EvFlags.reset()
	EvHistory.reset()
	EvLatches.reset()
	EvSchedule.reset()
	EvArcs.reset()
	EvQueue.reset()
	EvPapers.reset()
	EvBudgets.reset()
	EvTicker.reset()
	EvTempo.reset()
	EvSeams.reset()


## "" when the block is clean, else the first path holding a serialised Resource (SaveCodec's
## type tag) or a live object.
static func verify_no_resources(block: Dictionary = to_dict()) -> String:
	return _walk_for_res(block, BLOCK_KEY)


static func _walk_for_res(value: Variant, path: String) -> String:
	match typeof(value):
		TYPE_DICTIONARY:
			var d: Dictionary = value
			if d.has(SaveCodec.TYPE_TAG):
				return path
			for k in d:
				var found: String = _walk_for_res(d[k], "%s.%s" % [path, k])
				if found != "":
					return found
		TYPE_ARRAY:
			var a: Array = value
			for i in a.size():
				var found: String = _walk_for_res(a[i], "%s[%d]" % [path, i])
				if found != "":
					return found
		TYPE_OBJECT:
			return path
	return ""
