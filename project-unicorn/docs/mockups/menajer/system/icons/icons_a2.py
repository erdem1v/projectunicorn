"""Drop-in for ../tools/icons.py: the same ICON names and ic() signature, drawn from this family's SVG files.
A page generator switches with two lines (no shapely needed, it reads the built files):
    sys.path.insert(0, "<menajer>/system/icons"); from icons_a2 import ICON, ic
ICON also takes the family's own keys ("rail/product", "util/doc", ...)."""
import os

HERE = os.path.dirname(os.path.abspath(__file__))

# v0 draft name -> family key. The meaning moved for three: satis is the funnel on the rail (the tag stays the
# Satış skill), test is the bug with a check, lider is the umbrella (the flag became the milestone).
V0 = {"urun": "rail/product", "satis": "rail/sales", "ekip": "rail/hr", "finans": "rail/finance",
      "kisisel": "rail/personal", "pazarlama": "rail/marketing", "arge": "rail/rnd", "olaylar": "rail/events",
      "ayarlar": "rail/settings", "tasarim": "skill/design", "kod": "skill/engineering", "test": "skill/qa",
      "kulak": "skill/customer_success", "lider": "trait/takes_them_under", "iskolik": "trait/last_one_out",
      "sadik": "trait/loyal", "titiz": "trait/double_checker", "cabuk": "trait/picks_it_up_fast",
      "hayir": "trait/cant_say_no", "bavul": "trait/bag_packed", "bulut": "trait/mood_buster",
      "belirsiz": "trait/unspecified", "warn": "util/warn", "clock": "util/clock", "plus": "util/plus",
      "close": "util/close", "chev": "util/chevron_right", "chevdown": "util/chevron_down", "lock": "util/lock",
      "pause": "util/pause", "news": "util/news", "shield": "util/shield", "play": "util/play", "move": "util/move",
      "check": "util/check", "up": "stake/cash_in", "pie": "stake/equity", "minus": "stake/cost", "dice": "util/dice",
      "doc": "util/doc", "info": "util/info", "stack": "util/queue", "reply": "util/reply", "history": "util/history",
      "left": "world/person_left", "search": "util/search", "flag": "world/milestone", "kbd": "util/keyboard",
      "save": "util/save"}


def _load(key):
    t = open(os.path.join(HERE, key + ".svg"), encoding="utf-8").read()
    t = t.replace("#FFFFFF", "currentColor").replace(' width="24" height="24"', "")
    return t.replace("\n", "")


class _Icons(dict):
    def __missing__(self, name):
        v = _load(V0.get(name, name))
        self[name] = v
        return v


ICON = _Icons()


def ic(name, size=None, color=None, cls=""):
    style = []
    if size:
        style.append("width:%dpx;height:%dpx" % (size, size))
    if color:
        style.append("color:%s" % color)
    st = (' style="%s"' % ";".join(style)) if style else ""
    return '<span class="ic %s"%s>%s</span>' % (cls, st, ICON[name])
