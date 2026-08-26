class_name EvDice
extends RefCounted

# THE DICE (GDD §9). One type, `check`, and a hash rather than a generator.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY NOT `RngStreams`, WHICH ALREADY EXISTS AND IS GOOD
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# `RngStreams` is POSITION-RESUMING. Its whole design serialises `{seed, state}` because
# position matters (rng_streams.gd:4-28 explains at length why the global generator could not
# be resumed and had to be replaced). That is exactly right for a shuffle. It is exactly wrong
# for this.
#
# §9.3 wants: reload, re-pick the same option, get the same result. With a positional stream,
# reloading and doing anything at all in a different order changes how many draws have been
# spent, so the same option returns a different outcome — and save-scumming is back, through a
# door nobody opened on purpose. A pure function of (seed, day, event, option) cannot drift,
# whatever else the run did.
#
# THE CONSEQUENCE IS THE DESIGN (§9.3). Re-picking the same option after a reload is pointless.
# Picking a DIFFERENT option genuinely rerolls — but costs something different. So the only
# thing a reload buys is a better and more expensive offer, which is learning rather than
# exploiting. `option_id` being in the hash is what makes that true; drop it and every option
# on the card shares one outcome.
#
# ─────────────────────────────────────────────────────────────────────────────────────────
# WHY AN IN-PROJECT HASH AND NOT `String.hash()`
# ─────────────────────────────────────────────────────────────────────────────────────────
#
# Godot's `String.hash()` is not a documented-stable algorithm across engine versions or
# platforms, and these outcomes are SAVE-CRITICAL: a player who patches the game must get the
# same roll out of the same saved run. news_ticker.gd:130 uses the builtin for picking a
# filler line, which is fine — nothing is riding on it. This is not that.
#
# So: FNV-1a, 64-bit, written out here. Same discipline `RngStreams` applied when it rebuilt
# Fisher-Yates by hand (rng_streams.gd:53-64) rather than trusting `Array.shuffle()`.
# A smoke case pins known input to known output, so an accidental "optimisation" of this
# function is caught rather than silently re-rolling everyone's saves.

const FNV_OFFSET_BASIS: int = -3750763034362895579   # 14695981039346656037 as a signed int64
const FNV_PRIME: int = 1099511628211


## FNV-1a over the UTF-8 bytes. Deterministic across versions, platforms and processes, because
## every step of it is written down here.
static func fnv1a(text: String) -> int:
	var h: int = FNV_OFFSET_BASIS
	for byte in text.to_utf8_buffer():
		h ^= int(byte)
		h *= FNV_PRIME          # GDScript ints are int64 and wrap, which is what FNV wants
	return h


## 0.0 <= x < 1.0 from the four coordinates §9.3 names. `option_id` is not optional — see the
## header.
static func unit(kind: String, day: int, event_id: String, option_id: String) -> float:
	var key: String = "%d|%s|%d|%s|%s" % [GameState.run_seed, kind, day, event_id, option_id]
	# The low 53 bits: the range a float64 represents exactly, so the division is not lossy.
	var bits: int = fnv1a(key) & 0x1FFFFFFFFFFFFF
	return float(bits) / 9007199254740992.0


## §9.2's check. `odds` is 0..1 from a named seam — never a number typed into a card, because
## I7 says every modifier line behind it must be seam-backed too.
static func check(odds: float, event_id: String, option_id: String) -> bool:
	# The smoke suite's determinism override, mirroring SkillCheck's `debug_skill_force`
	# (skill_check.gd:66-71) so both dice in the game are pinned the same way.
	var forced: String = String(GameState.get_flag("debug_check_force", ""))
	if OS.is_debug_build() and forced == "pass":
		return true
	if OS.is_debug_build() and forced == "fail":
		return false
	return unit("check", GameState.day, event_id, option_id) < clampf(odds, 0.0, 1.0)


## The hover list (§9.6): signed, magnitude-sorted, at most four lines, everything past that
## folded into one. NO NUMBERS — §9.6 is explicit, and the reason is worth keeping: a number
## turns a human moment into a spreadsheet, and nothing at all leaves the decision blind.
## Hiding the list behind a hover resolves both: the surface stays calm, the depth is there.
##
## I7 is enforced by the SHAPE. A contribution names a seam; `modifier_lines` supplies the
## label for that seam. A contribution with no label cannot render, and a label with no
## contribution is a dead line the linter reports. Nobody can write "the rival's offer is
## serious" without first opening `rival.offer_seriousness`, which is a design decision rather
## than a piece of set dressing.
## `SkillCheck.breakdown()` in the shape §9.6 needs: `[{seam, delta}]`.
##
## THE BOUNDARY THE DIRECTIVE ASKED FOR. `breakdown()` returns `base` / `skill` / `bonus`, which
## are free-text keys, not seam names — so I7 ("no modifier line without a named seam") could
## not hold on them, and the choice was to map them here or to weaken the lint rule. Mapping is
## the right half to give: the rule keeps its teeth and the skill system keeps its own
## vocabulary.
##
## `base` is deliberately DROPPED. It is the difficulty, not a modifier, and §9.6's list is the
## things that moved the odds AWAY from the baseline — putting the baseline in the list of
## reasons the baseline changed is how a tooltip stops meaning anything.
static func contributions_from_breakdown(bd: Dictionary) -> Array:
	var out: Array = []
	var skill_name: String = String(bd.get("skill_name", ""))
	if not is_zero_approx(float(bd.get("skill", 0.0))):
		var seam: String = "founder.%s" % skill_name
		out.append({"seam": seam if EvSeams.has(seam) else "founder.skill",
			"delta": float(bd["skill"])})
	if not is_zero_approx(float(bd.get("bonus", 0.0))):
		out.append({"seam": "investor.leverage", "delta": float(bd["bonus"])})
	return out


static func modifier_lines(contributions: Array, labels: Dictionary, max_lines: int = 4) -> Array:
	var scored: Array = []
	for c in contributions:
		var entry: Dictionary = c
		var seam: String = String(entry.get("seam", ""))
		if not labels.has(seam):
			continue                        # no label, no line — I7, silently and correctly
		scored.append({
			"seam": seam,
			"label": String(labels[seam]),
			"delta": float(entry.get("delta", 0.0)),
		})
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
