class_name Fmt
extends RefCounted

# Locale-aware display formatting: the single home for every number, date and percent the
# player reads.
#
# Static + TranslationServer, not tr(): a static function has no Object to translate through.
#
# Locale data (month names, date field ORDER, percent shape, numeric separators) lives in
# strings.csv, so adding a locale is a CSV column, not a code edit.
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

## English loanwords Turkish text keeps as written: in caps they keep the Latin I (SPRINT, not SPRİNT).
const LOANWORD_STEMS: Array[String] = ["mail", "onboarding", "pitch", "sprint"]


## Locale-correct uppercase. String.to_upper() maps "i"→"I", which is wrong in Turkish, so the
## Turkish branch pre-substitutes i→İ ("ı"→"I" already maps correctly). English text must not
## take the Turkish rule (Display→DİSPLAY), nor must a loanword stem inside Turkish text; the
## Turkish suffix after it does (sprinti → SPRINTİ).
static func upper(s: String) -> String:
	if is_english():
		return s.to_upper()
	var out: String = s.replace("i", "İ").to_upper()   # LOC-DATA Turkish dotted-i mapping
	for stem in LOANWORD_STEMS:
		var at: int = s.findn(stem)
		while at >= 0:
			out = out.left(at) + stem.to_upper() + out.substr(at + stem.length())
			at = s.findn(stem, at + stem.length())
	return out


# --- Counts -----------------------------------------------------------------

## The singular twin of a counted key: "<KEY>_ONE" when n is 1 (EN "1 week" vs "2 weeks").
static func count_key(key: String, n: int) -> String:
	return key + "_ONE" if n == 1 else key


## A count of weeks: "3 hafta" / "3 weeks", "1 week".
static func weeks(n: int) -> String:
	return _t(count_key("HR_DURATION_WEEKS", n)).format({"n": n})


# --- Calendar ---------------------------------------------------------------

## The localization key of a month's name, 1-based.
static func month_key(month: int) -> String:
	return "MONTH_%d" % clampi(month, 1, 12)


## Title-case month name, 1-based (1 = January / Ocak).
static func month_name(month: int) -> String:
	return _t(month_key(month))


## Three-letter month, derived from the canonical name (Eylül→Eyl, September→Sep).
static func month_abbr(month: int) -> String:
	return month_name(month).substr(0, 3)


## The chrome date line from GameState.get_date_dict(): the tick's week of the year, its month and its
## year ("Hafta 14 · Nisan 2012"). Field order is data (DATE_LINE).
static func date_line(d: Dictionary) -> String:
	return _t("DATE_LINE").format({"week": int(d.week), "mon": month_name(int(d.month)), "year": int(d.year)})


## The tick's calendar day and month: "9 Nisan" / "9 April", abbreviated "9 Nis" / "9 Apr".
static func day_month(d: Dictionary, abbreviated := false) -> String:
	return "%d %s" % [int(d.day), month_abbr(int(d.month)) if abbreviated else month_name(int(d.month))]


## A real-world moment's date and time, in the locale's field order (TR 19.08.2026, EN 08/19/2026).
static func stamp(unix: int) -> String:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix)
	return _t("SAVE_SLOT_TIMESTAMP").format({
		"day": "%02d" % d.day, "month": "%02d" % d.month, "year": d.year,
		"hour": "%02d" % d.hour, "minute": "%02d" % d.minute})


## How long ago a real-world moment was ("2 hours ago"); from a week on, its stamp.
static func ago(unix: int) -> String:
	var s: int = int(Time.get_unix_time_from_system()) - unix
	for unit in [["FMT_AGO_MINUTES", 60, 3600], ["FMT_AGO_HOURS", 3600, 86400], ["FMT_AGO_DAYS", 86400, 7 * 86400]]:
		if s < unit[2]:
			var n: int = maxi(1, s / unit[1])
			return _t(count_key(unit[0], n)).format({"n": n})
	return stamp(unix)


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
## A plan in half weeks as weeks, a decimal only on a half week ("2,5", "3").
static func half_weeks(halfweeks: int) -> String:
	return number(halfweeks / 2.0, halfweeks % 2)


static func number(v: float, decimals: int = 1) -> String:
	return String.num(v, decimals).replace(".", _t("NUM_DECIMAL_SEP"))


## Percent in the locale's shape: Turkish "%12,5", English "12.5%" (PCT_PATTERN).
static func percent(v: float, decimals: int = 1) -> String:
	return _t("PCT_PATTERN").format({"v": number(v, decimals)})


## Whole percentage points with their sign outside the locale's shape: "-%20" / "-20%", "+%15" / "+15%".
static func signed_percent(points: int) -> String:
	return ("-" if points < 0 else "+") + percent(absi(points), 0)


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
	return _localize_signed(amount, s)


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
	return _localize_signed(value, s)


## Cash in full, thousands-grouped: "$12.340"/"$12,340". Cash is shown exactly because money
## management is precise.
static func money_exact(value: int) -> String:
	return ("-$" if value < 0 else "$") + group(absi(value))


## A market value or a valuation from $M, the Piyasa surfaces' one shape: "$3,0T"/"$3.0T" · "$560B" ·
## "$9,2B" · "$236M" · "$0,8M". Trillions keep their decimal; billions and millions drop it from ten up.
static func money_market(m: float) -> String:
	# The band is picked on the tenth the decimal bands print, so 999.95 reads "$1.0B", not "$1000M",
	# and 9.94 stays "$9.9M".
	var t: float = snappedf(m / 1_000_000.0, 0.1)
	var b: float = snappedf(m / 1_000.0, 0.1)
	var mm: float = snappedf(m, 0.1)
	var s: String
	if t >= 1.0:
		s = "$%.1fT" % t
	elif b >= 10.0:
		s = "$%dB" % roundi(m / 1_000.0)
	elif b >= 1.0:
		s = "$%.1fB" % b
	elif mm >= 10.0:
		s = "$%dM" % roundi(m)
	else:
		s = "$%.1fM" % mm
	return s.replace(".", _t("NUM_DECIMAL_SEP"))


## A share price to the cent, thousands-grouped: "$1.292,52"/"$1,292.52".
static func price(v: float) -> String:
	var cents: int = roundi(v * 100.0)
	return "$%s%s%02d" % [group(cents / 100), _t("NUM_DECIMAL_SEP"), cents % 100]


## Swap printf's decimal point for the locale's mark and re-attach the sign.
static func _localize_signed(value: int, s: String) -> String:
	var sep: String = _t("NUM_DECIMAL_SEP")
	if sep != ".":
		s = s.replace(".", sep)
	return ("-" + s) if value < 0 else s
