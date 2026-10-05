class_name InvestorAppetiteUi
extends RefCounted

# "Yatırımcı iştahı" — the ONLY player-facing reading of the Series A gate (GDD v2 ch. 01 §2:
# the signal is shown, the revenue figure never is). Words PhaseGateSystem.series_a_signal()
# as a state tag + one line — no progress bar and no growth count; the Finans summary's goal card
# draws them. Whether the tag stays or gives way to ch. 08 §5's one-line Frank note is open in
# docs/ACIK_ISLER/ACIK_KARARLAR.md.
#
# Static: no Object, so TranslationServer.translate() rather than tr() (loc_residue bans
# tr() in statics — it compiles and dies at runtime).

const STATE_KEYS := {
	"closed": "INV_APPETITE_CLOSED",
	"warming": "INV_APPETITE_WARMING",
	"open": "INV_APPETITE_OPEN",
}


static func title_text() -> String:
	return TranslationServer.translate("INV_APPETITE_TITLE")


static func state_text(state: String) -> String:
	return TranslationServer.translate(String(STATE_KEYS.get(state, "INV_APPETITE_CLOSED")))


## The one line under the tag. The door is MRR only (ch. 08 §5) and the readout carries no
## ratio: no growth months, no progress. Below the bar it says so without a figure;
## three special readings for "not asked yet" (phase 1), "door open" (phase 2, latched) and
## "hunt on" (phase 3). How near the bar is Frank's to say, once per mark, in his approach
## cards — not this line's.
static func line(sig: Dictionary) -> String:
	if GameState.phase <= 1:
		return TranslationServer.translate("INV_APPETITE_TOO_EARLY")
	if String(sig.get("state", "closed")) == "open":
		if GameState.phase >= 3:
			return TranslationServer.translate("INV_APPETITE_HUNT")
		return TranslationServer.translate("INV_APPETITE_GATE_OPEN")
	return TranslationServer.translate("INV_APPETITE_BELOW_BAR")
