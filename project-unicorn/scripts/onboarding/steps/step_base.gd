class_name OnboardingStep
extends Control

# Contract every onboarding step honors. The controller talks to steps only
# through this surface — payload shape and validation. Step scenes implement
# their own UI freely below the contract.
#
# Lifecycle (controller-driven):
#   1. instantiate the step scene and add it under StepHost
#   2. prefill(draft) — give the step its slice of prior choices; the step
#      paints its selection state here, so prefill always follows add_child
#   3. the step emits validity_changed when its selection changes
#   4. controller checks .is_valid() to enable / disable Next
#   5. on Next / Back: controller merges step.collect_payload() into draft

signal validity_changed(is_valid: bool)


func prefill(_draft: Dictionary) -> void:
	pass


func is_valid() -> bool:
	# Returning true here would let Next fire prematurely; assume invalid
	# until a step overrides.
	return false


func collect_payload() -> Dictionary:
	return {}


func _spacer(height: int) -> Control:
	var s := Control.new()
	s.custom_minimum_size = Vector2(0, height)
	return s
