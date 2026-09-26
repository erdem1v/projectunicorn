class_name Fmt
extends RefCounted

# Locale-aware display formatting: the single home for every number, date and percent the
# player reads.
#
# Static + TranslationServer, not tr(): a static function has no Object to translate through.
#
# Locale data (month names, weekday abbreviations, date field ORDER, percent shape, numeric
# separators) lives in strings.csv, so adding a locale is a CSV column, not a code edit.
#
# Money is a full locale flip: TR $1.234.567 / $3,5K, EN $1,234,567 / $3.5K. The "$" stays in
# both (the fiction is USD). The numeric part comes from printf and only the separator character
# is swapped afterwards, so English output is exactly printf's.


static func _t(key: String) -> String:
	return TranslationServer.translate(key)


## True when the active locale is English.
static func is_english() -> bool:
	return TranslationServer.get_locale().begins_with("en")


# --- Case -------------------------------------------------------------------

## Locale-correct uppercase. String.to_upper() maps "i"→"I", which is wrong in Turkish, so the
## Turkish branch pre-substitutes i→İ ("ı"→"I" already maps correctly). English text must not
## take the Turkish rule (Display→DİSPLAY).
static func upper(s: String) -> String:
	if is_english():
		return s.to_upper()
	return s.replace("i", "İ").to_upper()   # LOC-DATA Turkish dotted-i mapping


# --- Calendar ---------------------------------------------------------------

## Title-case month name, 1-based (1 = January / Ocak).
static func month_name(month: int) -> String:
	return _t("MONTH_%d" % clampi(month, 1, 12))


## Three-letter month, derived from the canonical name (Eylül→Eyl, September→Sep).
static func month_abbr(month: int) -> String:
	return month_name(month).substr(0, 3)


## Uppercase month for header registers (Month-End summary, gazette dateline).
static func month_upper(month: int) -> String:
	return upper(month_name(month))


## The chrome date line from GameState.get_date_dict(). Field order is data: DATE_LINE is
## "{dow}, {day} {mon} {year}" in Turkish and "{dow}, {mon} {day} {year}" in English.
## Weekday index follows Godot's Time.weekday (0 = Sunday).
static func date_line(d: Dictionary) -> String:
	return _t("DATE_LINE").format({
		"dow": _t("DOW_%d" % clampi(int(d.get("weekday", 0)), 0, 6)),
		"day": int(d.get("day", 1)),
		"mon": month_abbr(int(d.get("month", 1))),
		"year": int(d.get("year", 2026)),
	})


# --- Numbers ----------------------------------------------------------------

## Thousands-grouped integer without a currency mark ("1.234.567" / "1,234,567").
static func group(n: int) -> String:
	var sep: String = _t("NUM_GROUP_SEP")
	var digits: String = str(absi(n))
	var out: String = ""
	var c: int = 0
	for i in range(digits.length() - 1, -1, -1):
		out = digits[i] + out
		c += 1
		if c % 3 == 0 and i > 0:
			out = sep + out
	return ("-" + out) if n < 0 else out


## Decimal number with the locale's decimal mark ("12,5" / "12.5").
static func number(v: float, decimals: int = 1) -> String:
	return String.num(v, decimals).replace(".", _t("NUM_DECIMAL_SEP"))


## Percent in the locale's shape: Turkish "%12,5", English "12.5%" (PCT_PATTERN).
static func percent(v: float, decimals: int = 1) -> String:
	return _t("PCT_PATTERN").format({"v": number(v, decimals)})


# --- Money ------------------------------------------------------------------
# money() and money_chip() deliberately keep different thresholds (the chip's ≥$10K
# no-decimal branch keeps it narrow). The sign is peeled off once and re-attached around the
# finished magnitude, so a negative reads "-$12K", not "$-12K".

## Compact money for body copy: "$999" · "$1.8K"/"$1,8K" · "$12.5M"/"$12,5M".
static func money(amount: int) -> String:
	var a: int = absi(amount)
	var s: String
	if a >= 1_000_000:
		if a >= 10_000_000 and a % 1_000_000 == 0:
			s = "$%dM" % int(a / 1_000_000.0)
		else:
			s = "$%.1fM" % (a / 1_000_000.0)
	elif a >= 1_000:
		s = "$%.1fK" % (a / 1_000.0)
	else:
		s = "$%d" % a
	return _signed(amount, s)


## TopBar finance-chip money; stays abbreviated so it cannot widen the chrome group.
static func money_chip(value: int) -> String:
	var a: int = absi(value)
	var s: String
	if a >= 1_000_000:
		s = "$%.1fM" % (a / 1_000_000.0)
	elif a >= 10_000:
		s = "$%.0fK" % (a / 1_000.0)
	elif a >= 1_000:
		s = "$%.1fK" % (a / 1_000.0)
	else:
		s = "$%d" % a
	return _signed(value, s)


## Cash in full, thousands-grouped: "$12.340"/"$12,340". Cash is shown exactly because money
## management is precise.
static func money_exact(value: int) -> String:
	return ("-$" if value < 0 else "$") + group(absi(value))


## Swap printf's decimal point for the locale's mark and re-attach the sign.
static func _signed(value: int, s: String) -> String:
	var sep: String = _t("NUM_DECIMAL_SEP")
	if sep != ".":
		s = s.replace(".", sep)
	return ("-" + s) if value < 0 else s
