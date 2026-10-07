# Writes the Menajer Masası icon files from glyphs.py.
#   python build_icons.py   -> <group>/<name>.svg (24 px, #FFFFFF), office/<name>.svg (128 px head icons), theme/*.svg
# The SVG files are what Godot imports: plain filled paths, fill-rule evenodd, the tone as fill-opacity 0.4.
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import kit
from glyphs import build, HEAD, HEAD_ORDER, BREAK

HERE = os.path.dirname(os.path.abspath(__file__))
GL = build()


def write(rel, text):
    p = os.path.join(HERE, rel)
    os.makedirs(os.path.dirname(p), exist_ok=True)
    open(p, "w", encoding="utf-8", newline="\n").write(text)


def write_ui_svgs():
    n = 0
    for key, g in GL.items():
        if key.startswith("office/"):
            continue  # drawn only inside the 128 px head icons
        write(key + ".svg", kit.svg(g))
        n += 1
    return n


# ---------------------------------------------------------------- office head icons (Sprite3D, 128 x 128)
# Scene data, not UI tokens: they belong in OfficeConstants as HEAD_DISC, HEAD_EDGE, HEAD_GLYPH (working) and
# HEAD_BREAK_DISC, HEAD_BREAK_EDGE, HEAD_BREAK_GLYPH (on a break). OfficeActor still tints with ICON_TINT.
HEAD_WORK = {"disc": "#1E1B18", "edge": "#0E0C0A", "glyph": "#F1ECE2"}
HEAD_BREAK = {"disc": "#F1ECE2", "edge": "#2B2722", "glyph": "#1E1B18"}
# the first pass's alternative, kept for the comparison on the sheet: dark disc and a hue ring per break
HEAD_RING_HUES = {"meeting": "#A58FDB", "coffee": "#D39A66", "food": "#7DBE72", "wc": "#72AEDD"}


def head_svg(name, scheme="invert"):
    """scheme: 'invert' (recommended: a break flips the disc), 'ring' (first pass: hue ring), 'dark' (no break cue)."""
    st = HEAD_BREAK if (scheme == "invert" and name in BREAK) else HEAD_WORK
    ring = ""
    if scheme == "ring" and name in HEAD_RING_HUES:
        ring = '<circle cx="64" cy="62" r="45" fill="none" stroke="%s" stroke-width="7"/>\n' % HEAD_RING_HUES[name]
    g = kit.paths(GL[HEAD[name]], st["glyph"])
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">\n'
            '<circle cx="64" cy="68" r="54" fill="#000000" fill-opacity="0.3"/>\n'
            '<circle cx="64" cy="62" r="54" fill="%s"/>\n'
            '<circle cx="64" cy="62" r="51.5" fill="none" stroke="%s" stroke-width="5"/>\n'
            '%s<g transform="translate(26 24) scale(3.1667)">\n%s\n</g>\n</svg>\n'
            % (st["disc"], st["edge"], ring, g))


def write_head_svgs():
    for name in HEAD_ORDER:
        write("office/%s.svg" % name, head_svg(name))


# ---------------------------------------------------------------- theme SVGs, dark (colours baked: the theme draws them as-is)
# Tokens: track surface-5 #2E2924, border line-2 #4A4239, knob ink-2 #E9E4DA (on) and ink-4 #9A9184 (off).
THEME = {
    "slider_grabber": ('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">\n'
                       '<circle cx="12" cy="12" r="9" fill="#E9E4DA"/>\n'
                       '<path fill="#4A4239" fill-rule="evenodd" d="M9.2 8.6 H10.8 V15.4 H9.2 Z M13.2 8.6 H14.8 V15.4 H13.2 Z"/>\n'
                       '</svg>\n'),
    "switch_off": ('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="22" viewBox="0 0 40 22">\n'
                   '<rect x="0.5" y="0.5" width="39" height="21" rx="10.5" fill="#2E2924" stroke="#4A4239" stroke-width="1"/>\n'
                   '<circle cx="11" cy="11" r="7" fill="#9A9184"/>\n'
                   '</svg>\n'),
    "switch_on": ('<svg xmlns="http://www.w3.org/2000/svg" width="40" height="22" viewBox="0 0 40 22">\n'
                  '<rect x="0" y="0" width="40" height="22" rx="11" fill="#E9E4DA"/>\n'
                  '<circle cx="29" cy="11" r="7.5" fill="#1E1B18"/>\n'
                  '<path fill="#E9E4DA" d="M25.9 11.6 L27.1 10.4 L28.4 11.7 L31.4 8.7 L32.6 9.9 L28.4 14.1 Z"/>\n'
                  '</svg>\n'),
}


def write_theme_svgs():
    for k, v in THEME.items():
        write("theme/%s.svg" % k, v)


def symbols(color="currentColor"):
    return "\n".join('<symbol id="i-%s" viewBox="0 0 24 24">%s</symbol>' % (k.replace("/", "-"), kit.paths(g, color))
                     for k, g in GL.items())


if __name__ == "__main__":
    print("ui svgs:", write_ui_svgs())
    write_head_svgs()
    write_theme_svgs()
