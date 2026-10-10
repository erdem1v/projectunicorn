extends RefCounted

# MODULE LOCKS — is a module's page reachable in this build? `UiTokens.TABS` carries a NAMED
# gate (`"lock": "ea"`) rather than a boolean, so UiTokens stays free of game state; an
# unknown gate counts as LOCKED, because an unfinished page must not open on the player.
#
# ONE HOME for that rule: the rail asks through LeftTabs._is_locked and content asks through
# the `build.module_unlocked.<id>` seams, and both land here.

## Smoke-only. `is_open` consults this first so a case can open a gated module without
## editing UiTokens.
static var _override: Dictionary = {}


static func is_open(id: String) -> bool:
	if _override.has(id):
		return bool(_override[id])
	for row in UiTokens.TABS:
		if String(row.id) == id:
			return String(row.get("lock", "")) == ""
	return false


static func set_override(id: String, open: bool) -> void:
	_override[id] = open


static func clear_overrides() -> void:
	_override.clear()
