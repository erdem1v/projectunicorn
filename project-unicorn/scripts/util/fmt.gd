class_name Fmt
extends RefCounted

# ============================================================================
# LOCALE-AWARE DISPLAY FORMATTING — the single home for every number, date and
# percent the player reads.
# ============================================================================
# WHY THIS FILE EXISTS. Before it, locale-dependent formatting was scattered and
# Turkish-only: three separate month tables, a weekday table in TopBar, US comma
# grouping hardcoded in UiTokens, a dot-grouped twin in ProductUiShared, and a
# Turkish percent form in RivalRegistry. None of it could answer "what does this
# look like in English?" — so English got Turkish dates and a Turkish "%12,5".
#
# WHY STATIC + TranslationServer (not tr()): a static function has no Object to
# translate through. This is the project's documented pattern, the same reason
# UiTokens.net_runway_parts and DisplaySettings.step_blocked_note reach for it.
#
# WHY THE LOCALE DATA IS IN THE CSV, NOT IN TABLES HERE: month names, weekday
# abbreviations, the date field ORDER, the percent shape and the two numeric
# separators are all locale content. Keeping them as keys means strings.csv is a
# complete description of a locale — adding one is a CSV column, not a code edit —
# and it is what retires the three twin month tables the codebase used to carry.
#
# MONEY IS A FULL LOCALE FLIP (gate ruling 6, 2026-08-08): TR $1.234.567 / $3,5K,
# EN $1,234,567 / $3.5K. The "$" stays in both — the fiction is USD. Implementation
# note that matters: the numeric part is still produced by the SAME printf branches
# as before and only the SEPARATOR CHARACTER is swapped afterwards. That is
# deliberate — it makes the English output byte-identical to what shipped, so this
# change can only be seen on the Turkish side, which is exactly what was ruled.
#
# DERIVATION OVER DUPLICATION: the abbreviated month is the first three characters
# of the canonical name (Eylül→Eyl, September→Sep) — exactly the trick TopBar
# already used — so a locale supplies twelve names, not twenty-four.

const MONTHS := 12
const WEEKDAYS := 7


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


## True when the active locale is English. Public because a few callers legitimately
## need the branch itself (EndingsCopy picks a whole prose pool, not a format).
static func is_english() -> bool:
	return TranslationServer.get_locale().begins_with("en")


# --- Case -------------------------------------------------------------------

## Locale-correct uppercase. Godot's String.to_upper() is not locale-aware: it maps
## "i"→"I" (dotless), which is wrong in Turkish. The Turkish branch pre-substitutes
## i→İ; "ı"→"I" already maps correctly under the default Unicode rules.
##
## THE ENGLISH BRANCH IS A FIX, NOT A REFACTOR. UiTokens.tr_upper was applied to
## ALREADY-TRANSLATED text at 15 sites, so English strings were being run through the
## Turkish rule and came out mangled: Display→DİSPLAY, Audio→AUDİO,
## Accessibility→ACCESSİBİLİTY, "all quiet"→"ALL QUİET". Measured on the live EN
## Settings modal before this landed.
static func upper(s: String) -> String:
	if is_english():
		return s.to_upper()
	return s.replace("i", "İ").to_upper()


# --- Calendar ---------------------------------------------------------------

## Title-case month name, 1-based (1 = January / Ocak).
static func month_name(month: int) -> String:
	return _t("MONTH_%d" % clampi(month, 1, MONTHS))


## Three-letter month, derived from the canonical name (Eylül→Eyl, September→Sep).
static func month_abbr(month: int) -> String:
	return month_name(month).substr(0, 3)


## Uppercase month for header registers (Month-End summary, gazette dateline).
static func month_upper(month: int) -> String:
	return upper(month_name(month))


## Abbreviated weekday. Index follows Godot's Time.weekday: 0 = Sunday.
static func dow_abbr(weekday: int) -> String:
	return _t("DOW_%d" % clampi(weekday, 0, WEEKDAYS - 1))


## The chrome date line. FIELD ORDER IS DATA, not code: DATE_LINE is
## "{dow}, {day} {mon} {year}" in Turkish and "{dow}, {mon} {day} {year}" in English,
## so "Çar, 9 Eyl 2026" and "Wed, Sep 9 2026" come out of one call site.
## Takes GameState.get_date_dict() — the engine's single date seam.
static func date_line(d: Dictionary) -> String:
	return _t("DATE_LINE").format({
		"dow": dow_abbr(int(d.get("weekday", 0))),
		"day": int(d.get("day", 1)),
		"mon": month_abbr(int(d.get("month", 1))),
		"year": int(d.get("year", 2026)),
	})


# --- Numbers ----------------------------------------------------------------

## Thousands-grouped integer WITHOUT a currency mark ("1.234.567" / "1,234,567").
## Godot has no locale grouping, so it is done by hand — the same loop that used to
## live in UiTokens.format_money_exact, with the separator now read from the locale.
static func group(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	var c: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = _t("NUM_GROUP_SEP") + out
	return ("-" + out) if n < 0 else out


## Decimal number with the locale's decimal mark ("12,5" / "12.5").
static func number(v: float, decimals: int = 1) -> String:
	return String.num(v, decimals).replace(".", _t("NUM_DECIMAL_SEP"))


## Percent in the locale's shape: Turkish puts the sign FIRST ("%12,5"), English last
## ("12.5%"). Both come from PCT_PATTERN, so neither is hardcoded anywhere else.
static func percent(v: float, decimals: int = 1) -> String:
	return _t("PCT_PATTERN").format({"v": number(v, decimals)})


# --- Money ------------------------------------------------------------------
# The three shapes below keep their ORIGINAL branch thresholds byte-for-byte; only the
# separator character is swapped. Thresholds deliberately differ between money() and
# money_chip() (the ≥$10K no-decimal branch) — that divergence predates this file and
# its merge belongs to the curve session, not to a localization pass.

## Compact money for body copy: "$999" · "$1.8K"/"$1,8K" · "$12.5M"/"$12,5M".
static func money(amount: int) -> String:
	var a: int = absi(amount)
	var s: String
	if a >= 1_000_000:
		var millions: float = a / 1_000_000.0
		if a >= 10_000_000 and a % 1_000_000 == 0:
			s = "$%dM" % int(millions)
		else:
			s = "$%.1fM" % millions
	elif a >= 1_000:
		s = "$%.1fK" % (a / 1_000.0)
	else:
		s = "$%d" % a
	s = _swap_decimal(s)
	return ("-" + s) if amount < 0 else s


## TopBar finance-chip money. Stays abbreviated so it cannot widen the chrome group.
## The sign is peeled off ONCE and re-attached around the finished magnitude: dividing
## the signed value strands the minus inside the number ("$-12K" instead of "-$12K").
static func money_chip(value: int) -> String:
	var a: int = absi(value)
	var s: String
	if a >= 1000000:
		s = "$%.1fM" % (a / 1000000.0)
	elif a >= 10000:
		s = "$%.0fK" % (a / 1000.0)
	elif a >= 1000:
		s = "$%.1fK" % (a / 1000.0)
	else:
		s = "$%d" % a
	s = _swap_decimal(s)
	return ("-" + s) if value < 0 else s


## Cash in full, thousands-grouped: "$12.340"/"$12,340" · "$1.234.567"/"$1,234,567".
## CASH is shown exactly because money management is precise (Erdem); the StatCol_Cash
## width bound plus clip_text keeps even seven digits from shoving the chrome.
static func money_exact(value: int) -> String:
	return ("-$" if value < 0 else "$") + group(absi(value))


## Replace the printf decimal point with the locale's mark. Split out so the money
## shapes above can keep using the exact printf branches that shipped: under English
## this is a no-op by construction, so English money cannot drift.
static func _swap_decimal(s: String) -> String:
	var sep: String = _t("NUM_DECIMAL_SEP")
	return s if sep == "." else s.replace(".", sep)
