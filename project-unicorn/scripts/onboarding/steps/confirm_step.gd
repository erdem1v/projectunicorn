extends OnboardingStep

# Step 6 — Confirm.
# Pure summary view of the draft. The controller's Next button (relabeled
# "Başla") fires the commit; this step is always valid because it only
# reflects choices already validated by earlier steps.

const ORIGIN_LABELS := {
	"self_made": "Self-Made Founder",
}
const SUBGENRE_LABELS := {
	"ai": "AI",
	"saas": "SaaS",
}
const LOGO_LABELS := {
	"minimalist": "Minimalist",
	"tech": "Tech",
	"playful": "Playful",
	"serious": "Serious",
}
const TRAIT_LABELS := {
	"charismatic": "Charismatic",
	"pragmatic": "Pragmatic",
	"tech_visionary": "Technical Visionary",
	"resilient": "Resilient",
	"imposter_syndrome": "Imposter Syndrome",
	"conflict_avoidant": "Conflict Avoidant",
	"burnt_out": "Burnt-Out",
	"stubborn": "Stubborn",
}

@onready var origin_label: Label = $Panel/List/OriginLabel
@onready var skills_label: Label = $Panel/List/SkillsLabel
@onready var traits_label: Label = $Panel/List/TraitsLabel
@onready var subgenre_label: Label = $Panel/List/SubgenreLabel
@onready var company_label: Label = $Panel/List/CompanyLabel
@onready var founder_label: Label = $Panel/List/FounderLabel


func prefill(draft: Dictionary) -> void:
	if not is_node_ready():
		await ready
	origin_label.text = "Origin · %s" % ORIGIN_LABELS.get(draft.get("origin_id", ""), "?")
	subgenre_label.text = "Subgenre · %s" % SUBGENRE_LABELS.get(draft.get("subgenre_id", ""), "?")

	var alloc: Dictionary = draft.get("skill_alloc", {})
	skills_label.text = "Beceriler · Tech %d · Markets %d · Charisma %d · Politics %d" % [
		int(alloc.get("tech", 0)),
		int(alloc.get("markets", 0)),
		int(alloc.get("charisma", 0)),
		int(alloc.get("politics", 0)),
	]

	traits_label.text = "Trait'ler · +%s   /   −%s" % [
		TRAIT_LABELS.get(draft.get("trait_positive_id", ""), "?"),
		TRAIT_LABELS.get(draft.get("trait_negative_id", ""), "?"),
	]

	var slogan: String = draft.get("slogan", "")
	if slogan == "":
		slogan = "—"
	else:
		slogan = "\"%s\"" % slogan
	company_label.text = "Şirket · %s   ·   Logo: %s   ·   Slogan: %s" % [
		draft.get("company_name", "?"),
		LOGO_LABELS.get(draft.get("logo_style", ""), "?"),
		slogan,
	]

	var founder_name: String = draft.get("founder_name", "")
	if founder_name == "":
		founder_name = "Founder"
	founder_label.text = "Founder · %s" % founder_name

	validity_changed.emit(true)


func is_valid() -> bool:
	return true


func collect_payload() -> Dictionary:
	return {}
