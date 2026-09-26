class_name InvestorAppetiteUi
extends RefCounted

# "Yatırımcı iştahı" — the ONLY player-facing reading of the Series A gate (GDD v2 ch. 01 §2:
# the signal is shown, the revenue figure never is). Paints PhaseGateSystem.series_a_signal()
# as a Terminal state chip + one line — no progress bar and no growth count. Whether the chip
# stays or gives way to ch. 08 §5's one-line Frank note is open in docs/ACIK_ISLER/ACIK_KARARLAR.md.
# Three surfaces read it — the Finance title row, the product page's traction strip and the
# ODA board's goal card — so the words and the palette live here once.
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


## Terminal DURUM ÇİPİ (UiFactory.make_state_chip): muted / amber / positive by state. Built
## at runtime, never a theme variation — the colour-blind swap cannot be baked into a .tres.
static func chip(state: String) -> PanelContainer:
	match state:
		"open":
			return UiFactory.make_state_chip(state_text(state), UiTokens.positive(), UiTokens.positive_bg(), UiTokens.positive_rule())
		"warming":
			return UiFactory.make_state_chip(state_text(state), UiTokens.ACCENT, UiTokens.AMBER_BG, UiTokens.ACCENT)
		_:
			return UiFactory.make_state_chip(state_text(state), UiTokens.INK_MUTED, UiTokens.NEUTRAL_BADGE_BG, UiTokens.BORDER_DISABLED)


## The one line under the chip. The door is MRR only (ch. 08 §5) and the readout carries no
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
