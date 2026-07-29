extends Panel

# Bottom news ticker — ambient UI chrome per PROJECT_SPEC §6 (World & Drama)
# and TECH_SPEC §5.2 / §11.3.
#
# Design notes:
#  - Hardcoded dummy headline pool. Real news engine (phase-aware,
#    reactive) is a later task — see TODO below.
#  - Scrolls leftward at a fixed real-time pace, ignoring game speed
#    and game pause. The Panel sets process_mode = PROCESS_MODE_ALWAYS
#    so this _process keeps running even when SceneTree.paused is true.
#  - Seamless loop via duplicated content + half-width wrap. The label
#    contains two copies of the headline stream end-to-end; when the
#    label has scrolled past one copy width we add the same amount
#    back. Visual: zero gap, zero jump.
#
#  - LIVE LINES (HR Core): EventBus.headline_added pushes a real gameplay line, which is
#    prepended to the ambient pool and the stream is rebuilt. This is the game's only
#    non-modal notification channel — the HR spec needs candidate arrival to raise a badge
#    and a ticker line WITHOUT interrupting the player. Rebuilding resets the scroll
#    position, so a line landing mid-scroll causes one visible jump; acceptable for a
#    once-in-a-while beat, and the fix (splice without reset) belongs to the news engine.
#
# TODO when news engine comes online:
#   - Replace HEADLINES const with EventManager.get_news_pool(phase)
#   - Connect .scandal_breaking for breaking news
#   - Add critical-news visual treatment (red accent, slower scroll)
#   - Splice live lines without resetting scroll position

const SCROLL_SPEED := 50.0  # pixels per second
const SEPARATOR := "   ·   "
const SOURCE_COLOR := UiTokens.ACCENT_HEX  # amber source name (single token source)

const HEADLINES := [
	{"src": "Webrazzi",      "txt": "Vertical SaaS valuations cool 12% in Q1"},
	{"src": "TechCrunch",    "txt": "Mavi-Loop raises $4M seed for compliance AI"},
	{"src": "Bloomberg HT",  "txt": "TCMB holds policy rate steady, lira flat"},
	{"src": "Hürriyet Tech", "txt": "KVKK draft tightens vendor data residency rules"},
	{"src": "Reuters",       "txt": "OpenAI launches enterprise tier with on-prem option"},
	{"src": "Webrazzi",      "txt": "Founders Brunch Istanbul opens RSVP for May"},
	{"src": "TechCrunch",    "txt": "Volthane hires four ex-Meta engineers in Berlin"},
	{"src": "Bloomberg HT",  "txt": "Inflation print beats estimate, equities rally"},
	{"src": "Hürriyet Tech", "txt": "ISO 27001 audits surge as SaaS deals require it"},
	{"src": "Reuters",       "txt": "YC Demo Day shifts to live-streamed format"},
]

# Live gameplay lines, newest first, capped so the loop never grows without bound.
const MAX_LIVE_LINES := 6

@onready var stream: RichTextLabel = $Stream

var _half_width: float = 0.0
var _live_lines: Array[Dictionary] = []


func _ready() -> void:
	EventBus.headline_added.connect(_on_headline_added)
	await _rebuild()


func _exit_tree() -> void:
	if EventBus.headline_added.is_connected(_on_headline_added):
		EventBus.headline_added.disconnect(_on_headline_added)


func _on_headline_added(source: String, text: String) -> void:
	if text.strip_edges() == "":
		return
	_live_lines.push_front({"src": source, "txt": text})
	while _live_lines.size() > MAX_LIVE_LINES:
		_live_lines.pop_back()
	await _rebuild()


func _rebuild() -> void:
	# Two identical copies of the stream end-to-end → seamless loop.
	var single: String = _build_bbcode()
	stream.text = single + single
	stream.position.x = 0.0

	# Layout needs one frame to settle before get_content_width returns
	# a meaningful value. Same for get_content_height (used for y-center).
	await get_tree().process_frame
	_half_width = stream.get_content_width() / 2.0
	_center_vertically()


func _build_bbcode() -> String:
	var parts: PackedStringArray = []
	# Live gameplay lines lead; the ambient pool follows so the ticker never runs empty.
	for h in _live_lines:
		parts.append("[color=%s]%s[/color]  %s" % [SOURCE_COLOR, h.src, h.txt])
	for h in HEADLINES:
		parts.append("[color=%s]%s[/color]  %s" % [SOURCE_COLOR, h.src, h.txt])
	return SEPARATOR.join(parts) + SEPARATOR


func _process(delta: float) -> void:
	if _half_width <= 0.0:
		return
	stream.position.x -= SCROLL_SPEED * delta
	if stream.position.x <= -_half_width:
		stream.position.x += _half_width


func _center_vertically() -> void:
	# Place the stream so its single line sits mid-panel. content_height
	# is the natural height of one wrap-free line.
	var content_h: float = stream.get_content_height()
	stream.position.y = (size.y - content_h) / 2.0
