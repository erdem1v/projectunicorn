extends RefCounted

# MODULE LOCKS — is a module's page reachable in this build? `UiTokens.TABS` carries a NAMED
# gate (`"lock": "ea"`) rather than a boolean, so UiTokens stays free of game state: "ea" never
# opens in this build, "live" opens with v1.0, and an unknown gate counts as LOCKED, because an
# unfinished page must not open on the player.
#
# ONE HOME for that rule: the rail asks through LeftTabs._is_locked and content asks through
# the `build.module_unlocked.<id>` seams, and both land here.

## Smoke-only. `is_open` consults this first so a case can open a gated module without
## editing UiTokens.
static var _override: Dictionary = {}


## Every module the build knows, in rail order. The one walk over UiTokens.TABS, so a caller
## that needs the set does not grow a second copy of the rule's vocabulary.
static func ids() -> Array:
	return UiTokens.TABS.map(func(row): return String(row.id))


static func is_open(id: String) -> bool:
	if _override.has(id):
		return bool(_override[id])
	for row in UiTokens.TABS:
		if String(row.id) == id:
			match String(row.get("lock", "")):
				"": return true
				"live": return ProductState.is_live()
				_: return false
	return false


static func set_override(id: String, open: bool) -> void:
	_override[id] = open


static func clear_overrides() -> void:
	_override.clear()
