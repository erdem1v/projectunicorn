class_name EvDice
extends RefCounted

# THE DICE (GDD §9). One type, `check`, and a hash rather than a generator.
#
# Why not `RngStreams`: it is position-resuming, which is right for a shuffle and wrong here.
# §9.3 wants reload + re-pick the same option = the same result. With a positional stream any
# change in draw order after a reload changes the outcome and save-scumming is back. A pure
# function of (seed, day, event, option) cannot drift. Picking a DIFFERENT option genuinely
# rerolls — but costs something different, so a reload buys learning, not exploitation.
# `option_id` being in the hash is what makes that true.
#
# Why an in-project FNV-1a and not `String.hash()`: the builtin is not documented-stable across
# engine versions or platforms, and these outcomes are save-critical — a patched game must roll
# the same on the same saved run. A smoke case pins known input to known output.

const FNV_OFFSET_BASIS: int = -3750763034362895579   # 14695981039346656037 as a signed int64
const FNV_PRIME: int = 1099511628211


## FNV-1a, 64-bit, over the UTF-8 bytes.
static func fnv1a(text: String) -> int:
	var h: int = FNV_OFFSET_BASIS
	for byte in text.to_utf8_buffer():
		h ^= int(byte)
		h *= FNV_PRIME          # GDScript ints are int64 and wrap, which is what FNV wants
	return h


## 0.0 <= x < 1.0 from the four coordinates §9.3 names.
static func unit(kind: String, day: int, event_id: String, option_id: String) -> float:
	var key: String = "%d|%s|%d|%s|%s" % [GameState.run_seed, kind, day, event_id, option_id]
	# The low 53 bits: the range a float64 represents exactly, so the division is not lossy.
	var bits: int = fnv1a(key) & 0x1FFFFFFFFFFFFF
	return float(bits) / 9007199254740992.0


## §9.2's check. `odds` is 0..1 from a named seam, never a number typed into a card (I7).
static func check(odds: float, event_id: String, option_id: String) -> bool:
	return unit("check", GameState.day, event_id, option_id) < clampf(odds, 0.0, 1.0)


## The hover list (§9.6): signed, magnitude-sorted, at most `max_lines` lines with the rest
## folded into one. NO NUMBERS — a number turns a human moment into a spreadsheet.
##
## I7 is enforced by the shape: a contribution names a seam and `labels` supplies that seam's
## line, so a contribution without a label cannot render.
static func modifier_lines(contributions: Array, labels: Dictionary, max_lines: int = 4) -> Array:
	var scored: Array = []
	for c in contributions:
		var seam: String = String((c as Dictionary).get("seam", ""))
		if labels.has(seam):
			scored.append({"seam": seam, "label": String(labels[seam]),
				"delta": float((c as Dictionary).get("delta", 0.0))})
	scored.sort_custom(func(a, b): return absf(a["delta"]) > absf(b["delta"]))

	var out: Array = []
	for i in scored.size():
		if i >= max_lines:
			out.append({"sign": "", "label": TranslationServer.translate("EV_MODIFIERS_MORE"),
				"seam": ""})
			break
		var row: Dictionary = scored[i]
		out.append({
			"sign": "▲" if float(row["delta"]) >= 0.0 else "▼",
			"label": row["label"],
			"seam": row["seam"],
		})
	return out
