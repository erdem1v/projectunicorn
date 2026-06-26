class_name OnboardingStep
extends Control

# Contract every onboarding step honors. The controller talks to steps only
# through this surface — payload shape and validation. Step scenes implement
# their own UI freely below the contract.
#
# Lifecycle (controller-driven):
#   1. instance(step_scene) -> OnboardingStep
#   2. prefill(draft) — give the step its slice of prior choices (Back-nav)
#   3. step refresh_validity() emits when its internal selection changes
#   4. controller checks .is_valid() to enable / disable Next
#   5. on Next: payload = step.collect_payload(); controller merges into draft

signal validity_changed(is_valid: bool)


func prefill(_draft: Dictionary) -> void:
	# Default no-op — steps override to restore prior selections on Back.
	pass


func is_valid() -> bool:
	# Default no-op — steps override. Returning true here would let Next
	# fire prematurely; assume invalid until proven otherwise.
	return false


func collect_payload() -> Dictionary:
	# Default empty — steps override to return their slice of draft.
	return {}
