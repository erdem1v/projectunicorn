# Menajer Masası icon family: the single source of every glyph.
#
# Grid 24 x 24, live area 20 (2 px margin). Line weight 2 at 24 (1.67 at 20, 1.33 at 16), round caps and joins.
# Two tones only, both the same colour: the LINE at full strength and the TONE at 40 % (a flat fill, like the
# office's toon faces under their ink contour). Godot tints with modulate, so files are drawn in #FFFFFF and the
# tone is fill-opacity, never a second colour.
#
# Element classes (converted to explicit attributes by build_icons.py, no CSS, no masks, no filters):
#   p   line            fill none, stroke 2 (data-w overrides), round caps and joins
#   ps  line, square    same with butt caps (used only where a cap must stay flush)
#   t   tone fill       fill at 40 %
#   ts  tone line       stroke at 40 %
#   f   solid fill
#   fe  solid fill, evenodd (knock-outs)
#   fp  solid fill + line (rounded solid shapes)
import math

TONE = 0.4


def _f(v):
    s = ("%.2f" % v).rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def circle_isect(c1, r1, c2, r2):
    (x1, y1), (x2, y2) = c1, c2
    d = math.hypot(x2 - x1, y2 - y1)
    a = (r1 * r1 - r2 * r2 + d * d) / (2 * d)
    h = math.sqrt(max(r1 * r1 - a * a, 0))
    xm, ym = x1 + a * (x2 - x1) / d, y1 + a * (y2 - y1) / d
    return ((xm + h * (y2 - y1) / d, ym - h * (x2 - x1) / d), (xm - h * (y2 - y1) / d, ym + h * (x2 - x1) / d))


def polar(cx, cy, r, deg):
    a = math.radians(deg)
    return (cx + r * math.cos(a), cy + r * math.sin(a))


def gear(cx, cy, ro, ri, teeth, half_out, half_in, hole):
    pts = []
    d = ""
    for i in range(teeth):
        a = -90 + i * 360 / teeth
        p1 = polar(cx, cy, ri, a - half_in)
        p2 = polar(cx, cy, ro, a - half_out)
        p3 = polar(cx, cy, ro, a + half_out)
        p4 = polar(cx, cy, ri, a + half_in)
        if i == 0:
            d += "M%s %s " % (_f(p1[0]), _f(p1[1]))
        else:
            d += "A%s %s 0 0 1 %s %s " % (_f(ri), _f(ri), _f(p1[0]), _f(p1[1]))
        d += "L%s %s L%s %s L%s %s " % (_f(p2[0]), _f(p2[1]), _f(p3[0]), _f(p3[1]), _f(p4[0]), _f(p4[1]))
        pts.append(p1)
    d += "A%s %s 0 0 1 %s %s Z" % (_f(ri), _f(ri), _f(pts[0][0]), _f(pts[0][1]))
    hole_d = "M%s %s A%s %s 0 1 0 %s %s A%s %s 0 1 0 %s %s Z" % (
        _f(cx - hole), _f(cy), _f(hole), _f(hole), _f(cx + hole), _f(cy), _f(hole), _f(hole), _f(cx - hole), _f(cy))
    return d, hole_d


def star(cx, cy, ro, ri):
    pts = [polar(cx, cy, ro if i % 2 == 0 else ri, -90 + i * 36) for i in range(10)]
    full = "M" + " L".join("%s %s" % (_f(x), _f(y)) for x, y in pts) + " Z"
    left = [pts[5], pts[6], pts[7], pts[8], pts[9], pts[0]]
    right = [pts[0], pts[1], pts[2], pts[3], pts[4], pts[5]]
    lh = "M" + " L".join("%s %s" % (_f(x), _f(y)) for x, y in left) + " Z"
    rh = "M" + " L".join("%s %s" % (_f(x), _f(y)) for x, y in right) + " Z"
    return full, lh, rh


def crescent(c1, r1, c2, r2):
    a, b = circle_isect(c1, r1, c2, r2)
    # outer arc the long way from a to b, then the inner arc back
    return "M%s %s A%s %s 0 1 0 %s %s A%s %s 0 0 1 %s %s Z" % (
        _f(a[0]), _f(a[1]), _f(r1), _f(r1), _f(b[0]), _f(b[1]), _f(r2), _f(r2), _f(a[0]), _f(a[1]))


def cloud():
    L, rl = (7.4, 11.6), 3.4
    T, rt = (12.4, 8.8), 4.6
    R, rr = (17.2, 12.0), 3.0
    lt = min(circle_isect(L, rl, T, rt), key=lambda p: p[1])
    tr = min(circle_isect(T, rt, R, rr), key=lambda p: p[1])
    y = 15.0
    return ("M%s %s A%s %s 0 0 1 %s %s A%s %s 0 0 1 %s %s A%s %s 0 0 1 %s %s Z" % (
        _f(L[0]), _f(y), _f(rl), _f(rl), _f(lt[0]), _f(lt[1]), _f(rt), _f(rt), _f(tr[0]), _f(tr[1]),
        _f(rr), _f(rr), _f(R[0]), _f(y)))


def rtri(ax, ay, bx, by, cx, cy, cut):
    # triangle with each corner cut back `cut` along both edges and rounded with a quadratic
    P = [(ax, ay), (bx, by), (cx, cy)]
    d = ""
    for i in range(3):
        v, nx, pv = P[i], P[(i + 1) % 3], P[(i - 1) % 3]

        def toward(p, q):
            L = math.hypot(q[0] - p[0], q[1] - p[1])
            return (p[0] + (q[0] - p[0]) * cut / L, p[1] + (q[1] - p[1]) * cut / L)
        s, e = toward(v, pv), toward(v, nx)
        d += ("M" if i == 0 else "L") + "%s %s Q%s %s %s %s " % (_f(s[0]), _f(s[1]), _f(v[0]), _f(v[1]), _f(e[0]), _f(e[1]))
    return d + "Z"


def rrect(x, y, w, h, r):
    return ("M%s %s H%s A%s %s 0 0 1 %s %s V%s A%s %s 0 0 1 %s %s H%s A%s %s 0 0 1 %s %s V%s A%s %s 0 0 1 %s %s Z" % (
        _f(x + r), _f(y), _f(x + w - r), _f(r), _f(r), _f(x + w), _f(y + r), _f(y + h - r), _f(r), _f(r),
        _f(x + w - r), _f(y + h), _f(x + r), _f(r), _f(r), _f(x), _f(y + h - r), _f(y + r), _f(r), _f(r),
        _f(x + r), _f(y)))


def dot(cx, cy, r):
    return "M%s %s A%s %s 0 1 0 %s %s A%s %s 0 1 0 %s %s Z" % (
        _f(cx - r), _f(cy), _f(r), _f(r), _f(cx + r), _f(cy), _f(r), _f(r), _f(cx - r), _f(cy))


GEAR, GEAR_HOLE = gear(12, 12, 9.0, 6.6, 6, 13, 21, 2.9)
STAR, STAR_L, STAR_R = star(12, 12.8, 9.6, 4.1)
MOON = crescent((11.2, 12.8), 8.2, (16.6, 8.2), 6.6)
CLOUD = cloud()
WARN = rtri(12, 3.2, 21.8, 20.2, 2.2, 20.2, 2.0)
WARN_HOLES = rrect(10.9, 8.6, 2.2, 6.4, 1.1) + " " + dot(12, 17.3, 1.3)

# Shared person: head + closed bust. Used by Ekip, Kişisel, Gerçek lider, toplantı.
G = {}

# ---------------------------------------------------------------- rail (8 tabs + settings + optional rivals)
G["rail/product"] = f'''
<path class="t" d="M12 3 L20 7.5 L12 12 L4 7.5 Z"/>
<path class="p" d="M12 3 L20 7.5 V16.5 L12 21 L4 16.5 V7.5 Z M4 7.5 L12 12 L20 7.5 M12 12 V21"/>'''

G["rail/sales"] = '''
<path class="t" d="M3.2 4.6 H20.8 L18.4 8.2 H5.6 Z"/>
<path class="p" d="M3.2 4.6 H20.8 L14 14.8 H10 Z M5.6 8.2 H18.4 M8 11.6 H16"/>
<circle class="f" cx="12" cy="19" r="2"/>'''

G["rail/hr"] = '''
<path class="t" d="M16.4 4.4 A3 3 0 1 1 16.4 10.4 A3 3 0 1 1 16.4 4.4 Z M15.2 12.6 C15.6 12.5 16 12.4 16.4 12.4 C19.4 12.4 21.6 14.8 21.6 18.4 V19.6 H17.2 C17.1 16.6 16.3 14.2 15.2 12.6 Z"/>
<circle class="p" cx="8.8" cy="7.6" r="3.4"/>
<path class="t" d="M3 19.6 C3 16 5.6 13.4 8.8 13.4 C12 13.4 14.6 16 14.6 19.6 Z"/>
<path class="p" d="M3 19.6 C3 16 5.6 13.4 8.8 13.4 C12 13.4 14.6 16 14.6 19.6 Z"/>'''

G["rail/finance"] = '''
<path class="t" d="M5 6.4 A7 2.9 0 1 0 19 6.4 A7 2.9 0 1 0 5 6.4 Z"/>
<path class="p" d="M5 6.4 A7 2.9 0 1 0 19 6.4 A7 2.9 0 1 0 5 6.4 Z M5 6.4 V17.6 A7 2.9 0 0 0 19 17.6 V6.4 M5 10.2 A7 2.9 0 0 0 19 10.2 M5 13.9 A7 2.9 0 0 0 19 13.9"/>'''

G["rail/personal"] = '''
<circle class="p" cx="12" cy="7.4" r="4"/>
<path class="t" d="M4.4 20.4 C4.4 15.8 7.6 13.2 12 13.2 C16.4 13.2 19.6 15.8 19.6 20.4 Z"/>
<path class="p" d="M4.4 20.4 C4.4 15.8 7.6 13.2 12 13.2 C16.4 13.2 19.6 15.8 19.6 20.4 Z"/>'''

G["rail/marketing"] = '''
<path class="t" d="M8 9.2 L16.4 4.6 V19.4 L8 14.8 Z"/>
<path class="p" d="M3.6 9.6 A0.6 0.6 0 0 1 4.2 9.2 H8 L16.4 4.6 V19.4 L8 14.8 H4.2 A0.6 0.6 0 0 1 3.6 14.2 Z M8 9.2 V14.8 M6 14.8 L7.4 19.8 H9.6 L9.2 15.4 M19.4 9.4 A3.4 3.4 0 0 1 19.4 14.6"/>'''

G["rail/rnd"] = '''
<path class="t" d="M7.4 14.2 H16.6 L19 18.4 A1.7 1.7 0 0 1 17.5 21 H6.5 A1.7 1.7 0 0 1 5 18.4 Z"/>
<path class="p" d="M9 3 H15 M10 3 V9.2 L5 18.4 A1.7 1.7 0 0 0 6.5 21 H17.5 A1.7 1.7 0 0 0 19 18.4 L14 9.2 V3"/>
<circle class="f" cx="13.2" cy="11.6" r="1"/>'''

G["rail/events"] = '''
<path class="t" d="M5 5.4 H19 L12 11.6 Z"/>
<path class="p" d="M5 5.4 H19 A2 2 0 0 1 21 7.4 V16.6 A2 2 0 0 1 19 18.6 H5 A2 2 0 0 1 3 16.6 V7.4 A2 2 0 0 1 5 5.4 Z M3.6 6.6 L12 13.2 L20.4 6.6"/>'''

G["rail/settings"] = f'''
<path class="t" fill-rule="evenodd" d="{GEAR} {GEAR_HOLE}"/>
<path class="p" d="{GEAR}"/>
<circle class="p" cx="12" cy="12" r="2.9"/>'''

G["rail/rivals"] = '''
<path class="t" d="M9 7.4 H15 V20.4 H9 Z"/>
<path class="p" d="M3 20.4 V12.6 H9 V7.4 H15 V14.6 H21 V20.4 Z M9 12.6 V20.4 M15 14.6 V20.4"/>
<path class="f" d="M11.3 3.4 L12 2.2 L12.7 3.4 L14 3.6 L13.1 4.5 L13.3 5.8 L12 5.2 L10.7 5.8 L10.9 4.5 L10 3.6 Z"/>'''

# ---------------------------------------------------------------- skills (= sprint card role icons)
G["skill/product"] = '''
<circle class="t" cx="12" cy="12" r="5.2"/>
<circle class="p" cx="12" cy="12" r="8.6"/>
<circle class="f" cx="12" cy="12" r="2.1"/>'''

G["skill/design"] = '''
<path class="t" d="M12 21 L6.2 12.6 L8.6 6.6 H15.4 L17.8 12.6 Z"/>
<path class="p" d="M12 21 L6.2 12.6 L8.6 6.6 H15.4 L17.8 12.6 Z M8.6 6.6 V3.4 H15.4 V6.6 M12 21 V15.4"/>
<circle class="f" cx="12" cy="13.2" r="1.7"/>'''

G["skill/engineering"] = '''
<path class="ts" d="M13.8 4.6 L10.2 19.4"/>
<path class="p" d="M7.6 6.6 L2.8 12 L7.6 17.4 M16.4 6.6 L21.2 12 L16.4 17.4"/>'''

G["skill/qa"] = '''
<ellipse class="t" cx="12" cy="14.2" rx="5" ry="6.2"/>
<path class="p" d="M12 8 C14.8 8 17 10.8 17 14.2 C17 17.6 14.8 20.4 12 20.4 C9.2 20.4 7 17.6 7 14.2 C7 10.8 9.2 8 12 8 Z M9.4 8.6 A2.6 2.6 0 0 1 14.6 8.6 M10.4 5.8 L8.8 3.6 M13.6 5.8 L15.2 3.6 M7.2 11.6 L3.8 10.2 M7 15 H3.6 M7.6 18 L4.8 20.2 M16.8 11.6 L20.2 10.2 M17 15 H20.4 M16.4 18 L19.2 20.2 M12 11 V20.2"/>'''

G["skill/sales"] = '''
<path class="t" d="M3.6 4.9 A1.3 1.3 0 0 1 4.9 3.6 H11.2 L20.1 12.5 A1.5 1.5 0 0 1 20.1 14.6 L14.6 20.1 A1.5 1.5 0 0 1 12.5 20.1 L3.6 11.2 Z"/>
<path class="p" d="M3.6 4.9 A1.3 1.3 0 0 1 4.9 3.6 H11.2 L20.1 12.5 A1.5 1.5 0 0 1 20.1 14.6 L14.6 20.1 A1.5 1.5 0 0 1 12.5 20.1 L3.6 11.2 Z"/>
<circle class="f" cx="8.1" cy="8.1" r="1.7"/>'''

G["skill/customer_success"] = '''
<path class="t" d="M4.6 12 H6.4 A1.4 1.4 0 0 1 7.8 13.4 V17.6 A1.4 1.4 0 0 1 6.4 19 H4.6 A1.4 1.4 0 0 1 3.2 17.6 V13.4 A1.4 1.4 0 0 1 4.6 12 Z M17.6 12 H19.4 A1.4 1.4 0 0 1 20.8 13.4 V17.6 A1.4 1.4 0 0 1 19.4 19 H17.6 A1.4 1.4 0 0 1 16.2 17.6 V13.4 A1.4 1.4 0 0 1 17.6 12 Z"/>
<path class="p" d="M4.2 13 V11.4 A7.8 7.8 0 0 1 19.8 11.4 V13 M4.6 12 H6.4 A1.4 1.4 0 0 1 7.8 13.4 V17.6 A1.4 1.4 0 0 1 6.4 19 H4.6 A1.4 1.4 0 0 1 3.2 17.6 V13.4 A1.4 1.4 0 0 1 4.6 12 Z M17.6 12 H19.4 A1.4 1.4 0 0 1 20.8 13.4 V17.6 A1.4 1.4 0 0 1 19.4 19 H17.6 A1.4 1.4 0 0 1 16.2 17.6 V13.4 A1.4 1.4 0 0 1 17.6 12 Z M18.6 19.2 A2.6 2.6 0 0 1 16 21.2 H13"/>'''

G["skill/leadership"] = '''
<path class="t" d="M5.6 4 H18.6 L15.6 8.4 L18.6 12.8 H5.6 Z"/>
<path class="p" d="M5.6 21 V3 M5.6 4 H18.6 L15.6 8.4 L18.6 12.8 H5.6"/>'''

# ---------------------------------------------------------------- departments (roster group headers)
G["dept/product_design"] = '''
<path class="t" d="M8.6 15.6 C6.2 14.2 4.8 11.8 4.8 9.4 A7.2 7.2 0 0 1 19.2 9.4 C19.2 11.8 17.8 14.2 15.4 15.6 Z"/>
<path class="p" d="M8.6 17.4 V15.6 C6.2 14.2 4.8 11.8 4.8 9.4 A7.2 7.2 0 0 1 19.2 9.4 C19.2 11.8 17.8 14.2 15.4 15.6 V17.4 Z M9.6 20.6 H14.4"/>'''

G["dept/development"] = '''
<path class="t" d="M5 4.6 H19 A2 2 0 0 1 21 6.6 V8.6 H3 V6.6 A2 2 0 0 1 5 4.6 Z"/>
<path class="p" d="M5 4.6 H19 A2 2 0 0 1 21 6.6 V17.4 A2 2 0 0 1 19 19.4 H5 A2 2 0 0 1 3 17.4 V6.6 A2 2 0 0 1 5 4.6 Z M3 8.6 H21 M7 11.6 L9.8 14 L7 16.4 M12.4 16.4 H17"/>'''

G["dept/sales"] = '''
<path class="t" d="M3 12.6 H21 V17.6 A2 2 0 0 1 19 19.6 H5 A2 2 0 0 1 3 17.6 Z"/>
<path class="p" d="M5 7.4 H19 A2 2 0 0 1 21 9.4 V17.6 A2 2 0 0 1 19 19.6 H5 A2 2 0 0 1 3 17.6 V9.4 A2 2 0 0 1 5 7.4 Z M9 7.4 V5.6 A1.4 1.4 0 0 1 10.4 4.2 H13.6 A1.4 1.4 0 0 1 15 5.6 V7.4 M3 12.6 H10.4 M13.6 12.6 H21"/>
<path class="fp" d="M10.6 11.4 H13.4 V14 H10.6 Z" data-w="1"/>'''

G["dept/customer_success"] = '''
<path class="t" d="M9 4.8 A1.4 1.4 0 0 1 10.4 3.4 H19.6 A1.4 1.4 0 0 1 21 4.8 V10.6 A1.4 1.4 0 0 1 19.6 12 H19.2 L19.8 14.6 L16.8 12 V7.2 H9 Z"/>
<path class="p" d="M4.4 9.2 H13.6 A1.4 1.4 0 0 1 15 10.6 V16.2 A1.4 1.4 0 0 1 13.6 17.6 H8.8 L5.6 20.4 V17.6 H4.4 A1.4 1.4 0 0 1 3 16.2 V10.6 A1.4 1.4 0 0 1 4.4 9.2 Z"/>'''

# ---------------------------------------------------------------- traits (8 employee traits + unspecified)
G["trait/loyal"] = '''
<path class="t" d="M4.6 13.6 H19.4 C19 17.8 15.8 20.6 12 20.6 C8.2 20.6 5 17.8 4.6 13.6 Z"/>
<circle class="p" cx="12" cy="4.8" r="1.9"/>
<path class="p" d="M12 6.7 V20.6 M8.4 9.6 H15.6 M4.6 13.6 C5 17.8 8.2 20.6 12 20.6 C15.8 20.6 19 17.8 19.4 13.6 M3 15.2 L4.6 13.6 L6.2 15.2 M17.8 15.2 L19.4 13.6 L21 15.2"/>'''

G["trait/picks_it_up_fast"] = '''
<path class="t" d="M13.6 2.8 L5.4 13.6 H11.2 L10.2 21.2 L18.6 10.2 H12.8 Z"/>
<path class="p" d="M13.6 2.8 L5.4 13.6 H11.2 L10.2 21.2 L18.6 10.2 H12.8 Z"/>'''

G["trait/last_one_out"] = f'''
<path class="t" d="{MOON}"/>
<path class="p" d="{MOON}"/>
<path class="fp" d="M17.4 4.6 L18 6.4 L19.8 7 L18 7.6 L17.4 9.4 L16.8 7.6 L15 7 L16.8 6.4 Z" data-w="0.8"/>'''

G["trait/takes_them_under"] = '''
<path class="t" d="M12 4.2 L21.4 8.8 L12 13.4 L2.6 8.8 Z"/>
<path class="p" d="M12 4.2 L21.4 8.8 L12 13.4 L2.6 8.8 Z M6.4 10.8 V15.4 C6.4 17.2 9 18.6 12 18.6 C15 18.6 17.6 17.2 17.6 15.4 V10.8 M21.4 8.8 V14.2"/>
<circle class="f" cx="21.4" cy="15.6" r="1.4"/>'''

G["trait/double_checker"] = '''
<path class="ts" d="M2.6 12.6 L6.6 16.6 L14.2 8.4"/>
<path class="p" d="M10.4 14.6 L12.4 16.6 L21.4 6.8"/>'''

G["trait/cant_say_no"] = '''
<path class="t" d="M3.4 11 H6.6 V20 H3.4 Z"/>
<path class="p" d="M3.4 11 H6.6 V20 H3.4 Z M6.6 11.6 L9.8 4.8 C10.3 3.8 11.5 3.5 12.4 4 C13.3 4.6 13.6 5.6 13.3 6.6 L12.4 10 H18.2 C19.6 10 20.6 11.3 20.3 12.6 L18.9 18.5 C18.6 19.4 17.8 20 16.9 20 H6.6"/>'''

G["trait/bag_packed"] = '''
<path class="t" d="M3 20.4 H8 V15.4 H13 V10.4 H16 V20.4 Z"/>
<path class="p" d="M3 20.4 H8 V15.4 H13 V10.4 H16 V20.4 H3 M14 8.6 L20.6 3.4 M15.8 3.4 H20.6 V8.2"/>'''

G["trait/bag_packed_alt"] = '''
<path class="t" d="M8 7.4 H16 A2 2 0 0 1 18 9.4 V17.6 A2 2 0 0 1 16 19.6 H8 A2 2 0 0 1 6 17.6 V9.4 A2 2 0 0 1 8 7.4 Z"/>
<path class="p" d="M8 7.4 H16 A2 2 0 0 1 18 9.4 V17.6 A2 2 0 0 1 16 19.6 H8 A2 2 0 0 1 6 17.6 V9.4 A2 2 0 0 1 8 7.4 Z M10 7.4 V3.4 H14 V7.4 M10 10.6 V16.4 M14 10.6 V16.4"/>
<circle class="f" cx="8.8" cy="21.4" r="1.2"/>
<circle class="f" cx="15.2" cy="21.4" r="1.2"/>'''

G["trait/mood_buster"] = f'''
<path class="t" d="{CLOUD}"/>
<path class="p" d="{CLOUD}"/>
<path class="p" d="M8.4 17.8 L7.4 20.6 M12.4 17.8 L11.4 20.6 M16.4 17.8 L15.4 20.6"/>'''

G["trait/unspecified"] = '''
<path class="t" d="M12 3.4 L20.6 12 L12 20.6 L3.4 12 Z"/>
<path class="p" d="M12 3.4 L20.6 12 L12 20.6 L3.4 12 Z"/>
<circle class="f" cx="12" cy="12" r="2"/>'''

# ---------------------------------------------------------------- product (sprint card kinds + voices)
G["product/kind_feature"] = '''
<path class="t" d="M10.6 4.4 Q11.6 12 19 13 Q11.6 14 10.6 21.6 Q9.6 14 2.2 13 Q9.6 12 10.6 4.4 Z"/>
<path class="p" d="M10.6 4.4 Q11.6 12 19 13 Q11.6 14 10.6 21.6 Q9.6 14 2.2 13 Q9.6 12 10.6 4.4 Z"/>
<path class="f" d="M18.4 2.4 Q18.8 5 21.4 5.4 Q18.8 5.8 18.4 8.4 Q18 5.8 15.4 5.4 Q18 5 18.4 2.4 Z"/>'''

G["product/kind_polish"] = '''
<path class="ts" d="M5.6 19 L12 12.6 L18.4 19"/>
<path class="p" d="M5.6 12 L12 5.6 L18.4 12"/>'''

G["product/kind_fix"] = f'''
<g transform="rotate(-45 12 12)">
<path class="t" d="M8.6 7.6 H15.4 V16.4 H8.6 Z"/>
<path class="p" d="{rrect(1.6, 7.6, 20.8, 8.8, 4.4)} M8.6 7.6 V16.4 M15.4 7.6 V16.4"/>
<circle class="f" cx="10.6" cy="10.6" r="0.9"/><circle class="f" cx="13.4" cy="13.4" r="0.9"/>
<circle class="f" cx="13.4" cy="10.6" r="0.9"/><circle class="f" cx="10.6" cy="13.4" r="0.9"/>
</g>'''

G["product/kind_research"] = '''
<path class="t" d="M5.3 13.2 C6.4 11.6 8.1 10.9 10 10.9 C11.9 10.9 13.6 11.6 14.7 13.2 C13.6 15 11.9 16 10 16 C8.1 16 6.4 15 5.3 13.2 Z"/>
<circle class="p" cx="10" cy="10" r="6.8"/>
<circle class="f" cx="10" cy="7.8" r="2"/>
<path class="p" d="M15 15 L20.6 20.6"/>'''

G["product/voices"] = '''
<path class="t" d="M5 4.6 H19 A2 2 0 0 1 21 6.6 V14.8 A2 2 0 0 1 19 16.8 H11.2 L6.6 20.4 V16.8 H5 A2 2 0 0 1 3 14.8 V6.6 A2 2 0 0 1 5 4.6 Z"/>
<path class="p" d="M5 4.6 H19 A2 2 0 0 1 21 6.6 V14.8 A2 2 0 0 1 19 16.8 H11.2 L6.6 20.4 V16.8 H5 A2 2 0 0 1 3 14.8 V6.6 A2 2 0 0 1 5 4.6 Z"/>'''

# ---------------------------------------------------------------- utility
G["util/warn"] = f'''
<path class="fe" d="{WARN} {WARN_HOLES}"/>'''

G["util/clock"] = '''
<path class="t" d="M12 12 V4.4 A7.6 7.6 0 0 1 18.6 15.8 Z"/>
<circle class="p" cx="12" cy="12" r="8.6"/>
<path class="p" d="M12 7.2 V12 L15.6 14.2"/>'''

G["util/plus"] = '''<path class="p" d="M12 5 V19 M5 12 H19"/>'''
G["util/minus"] = '''<path class="p" d="M5 12 H19"/>'''
G["util/close"] = '''<path class="p" d="M6.6 6.6 L17.4 17.4 M17.4 6.6 L6.6 17.4"/>'''
G["util/chevron_right"] = '''<path class="p" d="M9.4 5.6 L15.8 12 L9.4 18.4"/>'''
G["util/chevron_left"] = '''<path class="p" d="M14.6 5.6 L8.2 12 L14.6 18.4"/>'''
G["util/chevron_up"] = '''<path class="p" d="M5.6 14.6 L12 8.2 L18.4 14.6"/>'''
G["util/chevron_down"] = '''<path class="p" d="M5.6 9.4 L12 15.8 L18.4 9.4"/>'''
G["util/check"] = '''<path class="p" d="M4.6 12.8 L9.4 17.4 L19.4 6.8"/>'''
G["util/arrow_right"] = '''<path class="p" d="M4 12 H19.6 M13.8 6.2 L19.6 12 L13.8 17.8"/>'''

G["util/lock"] = '''
<path class="t" d="M7 10.4 H17 A2 2 0 0 1 19 12.4 V18.6 A2 2 0 0 1 17 20.6 H7 A2 2 0 0 1 5 18.6 V12.4 A2 2 0 0 1 7 10.4 Z"/>
<path class="p" d="M7 10.4 H17 A2 2 0 0 1 19 12.4 V18.6 A2 2 0 0 1 17 20.6 H7 A2 2 0 0 1 5 18.6 V12.4 A2 2 0 0 1 7 10.4 Z M8.2 10.4 V7.6 A3.8 3.8 0 0 1 15.8 7.6 V10.4"/>
<circle class="f" cx="12" cy="15.4" r="1.6"/>'''

G["util/pause"] = '''
<path class="fp" d="M7 5 H9.6 V19 H7 Z M14.4 5 H17 V19 H14.4 Z" data-w="1.6"/>'''

G["util/play"] = '''
<path class="fp" d="M7.6 5.2 L18.8 12 L7.6 18.8 Z"/>'''

G["util/news"] = '''
<path class="t" d="M6.4 7.4 H14.6 V11 H6.4 Z"/>
<path class="p" d="M3.4 5.6 A1.2 1.2 0 0 1 4.6 4.4 H16.4 A1.2 1.2 0 0 1 17.6 5.6 V18.2 A1.8 1.8 0 0 0 19.4 20 H5.4 A2 2 0 0 1 3.4 18 Z M17.6 8.4 H20.6 V18.2 A1.8 1.8 0 0 1 19.4 20 M6.4 7.4 H14.6 V11 H6.4 Z M6.4 14 H14.6 M6.4 17 H11.6"/>'''

G["util/shield"] = '''
<path class="t" d="M12 3.2 V20.8 C7.6 19.2 4.4 15.8 4.4 11.4 V5.8 Z"/>
<path class="p" d="M12 3.2 L19.6 5.8 V11.4 C19.6 15.8 16.4 19.2 12 20.8 C7.6 19.2 4.4 15.8 4.4 11.4 V5.8 Z"/>'''

G["util/move"] = '''
<path class="t" d="M3 6 H13.6 V16.4 H3 Z"/>
<path class="p" d="M3 6 H13.6 V16.4 H3 Z M13.6 9.2 H17.4 L21 12.8 V16.4 H13.6 M9.4 16.4 H13.6"/>
<circle class="p" cx="7" cy="17.8" r="2"/>
<circle class="p" cx="17.2" cy="17.8" r="2"/>'''

G["util/search"] = '''
<circle class="t" cx="10.4" cy="10.4" r="5.6"/>
<circle class="p" cx="10.4" cy="10.4" r="6.6"/>
<path class="p" d="M15.2 15.2 L20.4 20.4"/>'''

G["util/filter"] = '''
<path class="p" d="M3.6 6.4 H20.4 M6.8 12 H17.2 M10 17.6 H14"/>'''

G["util/inbox"] = '''
<path class="t" d="M7.4 3.4 H16.6 V12.4 H7.4 Z"/>
<path class="p" d="M7.4 9.6 V3.4 H16.6 V9.6 M3 12 V18.6 A2 2 0 0 0 5 20.6 H19 A2 2 0 0 0 21 18.6 V12 H15.6 L14.4 14.6 H9.6 L8.4 12 Z M10 6.4 H14"/>'''

G["util/mail_open"] = '''
<path class="t" d="M3 10 L12 3.8 L21 10 L12 15.6 Z"/>
<path class="p" d="M3 10 L12 3.8 L21 10 V18.6 A2 2 0 0 1 19 20.6 H5 A2 2 0 0 1 3 18.6 Z M3.6 10.6 L12 15.6 L20.4 10.6"/>'''

G["util/reply"] = '''
<path class="p" d="M9.6 5 L3.6 11 L9.6 17 M4.2 11 H13 C17 11 20.4 14 20.4 19"/>'''

G["util/calendar"] = '''
<path class="t" d="M5 5.4 H19 A2 2 0 0 1 21 7.4 V9.8 H3 V7.4 A2 2 0 0 1 5 5.4 Z"/>
<path class="p" d="M5 5.4 H19 A2 2 0 0 1 21 7.4 V18.6 A2 2 0 0 1 19 20.6 H5 A2 2 0 0 1 3 18.6 V7.4 A2 2 0 0 1 5 5.4 Z M3 9.8 H21 M8 3.2 V7 M16 3.2 V7"/>
<path class="fp" d="M13.4 13.4 H16.6 V16.6 H13.4 Z" data-w="1"/>'''

G["util/dice"] = '''
<path class="t" d="M6.4 3.6 H17.6 A2.8 2.8 0 0 1 20.4 6.4 V17.6 A2.8 2.8 0 0 1 17.6 20.4 H6.4 A2.8 2.8 0 0 1 3.6 17.6 V6.4 A2.8 2.8 0 0 1 6.4 3.6 Z"/>
<path class="p" d="M6.4 3.6 H17.6 A2.8 2.8 0 0 1 20.4 6.4 V17.6 A2.8 2.8 0 0 1 17.6 20.4 H6.4 A2.8 2.8 0 0 1 3.6 17.6 V6.4 A2.8 2.8 0 0 1 6.4 3.6 Z"/>
<circle class="f" cx="8.4" cy="8.4" r="1.7"/><circle class="f" cx="12" cy="12" r="1.7"/><circle class="f" cx="15.6" cy="15.6" r="1.7"/>'''

G["util/revert"] = '''
<path class="p" d="M5.4 8.4 A7.6 7.6 0 1 1 4.4 12.8 M4.6 3.8 V8.6 H9.4"/>'''

G["util/flat"] = '''<path class="p" d="M5.6 12 H18.4"/>'''

G["util/star_full"] = f'''<path class="fp" d="{STAR}" data-w="1.6"/>'''
G["util/star_half"] = f'''<path class="t" d="{STAR_R}"/><path class="fp" d="{STAR_L}" data-w="1.6"/>'''
G["util/star_empty"] = f'''<path class="t" d="{STAR}"/>'''

# ---------------------------------------------------------------- stake (decision cost glyphs)
G["stake/cash_in"] = '''
<circle class="t" cx="12" cy="12" r="9.4"/>
<path class="p" d="M12 17.4 V6.8 M7.4 11.4 L12 6.8 L16.6 11.4" data-w="2.4"/>'''

G["stake/cash_out"] = '''
<circle class="t" cx="12" cy="12" r="9.4"/>
<path class="p" d="M12 6.6 V17.2 M7.4 12.6 L12 17.2 L16.6 12.6" data-w="2.4"/>'''

G["stake/equity"] = '''
<path class="t" d="M11 13.4 V4.8 A8.6 8.6 0 1 0 18.45 9.1 Z"/>
<path class="p" d="M11 13.4 V4.8 A8.6 8.6 0 1 0 18.45 9.1 Z"/>
<path class="fp" d="M13.2 11.2 V2.6 A8.6 8.6 0 0 1 20.65 6.9 Z" data-w="1.6"/>'''

# ---------------------------------------------------------------- office head glyphs (24 grid, drawn bolder)
# Same metaphors as the UI where the activity is a skill; line 2.6, tone 0.35 on the disc.
H = {}
H["code"] = '''
<path class="p" d="M8 6.4 L3 12 L8 17.6 M16 6.4 L21 12 L16 17.6 M13.6 4.6 L10.4 19.4"/>'''
H["test"] = '''
<ellipse class="t" cx="12" cy="14" rx="5.2" ry="6.4"/>
<path class="p" d="M12 7.6 C14.9 7.6 17.2 10.5 17.2 14 C17.2 17.5 14.9 20.4 12 20.4 C9.1 20.4 6.8 17.5 6.8 14 C6.8 10.5 9.1 7.6 12 7.6 Z M9.6 7.8 A2.4 2.4 0 0 1 14.4 7.8 M6.8 12 L3.6 10.6 M6.8 16.4 L3.6 17.8 M17.2 12 L20.4 10.6 M17.2 16.4 L20.4 17.8 M10.6 5.6 L9.2 3.6 M13.4 5.6 L14.8 3.6"/>'''
H["research"] = '''
<circle class="t" cx="10.4" cy="10.4" r="5.6"/>
<circle class="p" cx="10.4" cy="10.4" r="6.6"/>
<path class="p" d="M15.2 15.2 L20.4 20.4" data-w="3.4"/>'''
H["design"] = '''
<path class="t" d="M12 21 L6 12.6 L8.6 6.4 H15.4 L18 12.6 Z"/>
<path class="p" d="M12 21 L6 12.6 L8.6 6.4 H15.4 L18 12.6 Z M8.6 6.4 V3.2 H15.4 V6.4 M12 21 V15.6"/>
<circle class="f" cx="12" cy="13.4" r="1.8"/>'''
H["phone"] = '''
<path class="fp" d="M5.2 4.4 L8.6 3.4 L10.6 8 L8.4 9.6 C9.4 12 11.8 14.6 14.4 15.6 L16 13.4 L20.6 15.4 L19.6 18.8 C19.2 20 18 20.8 16.6 20.6 C10.4 19.6 4.4 13.6 3.4 7.4 C3.2 6 4 4.8 5.2 4.4 Z" data-w="1.4"/>'''
H["coffee"] = '''
<path class="t" d="M4.6 9 H16 V14.6 A4.4 4.4 0 0 1 11.6 19 H9 A4.4 4.4 0 0 1 4.6 14.6 Z"/>
<path class="p" d="M4.6 9 H16 V14.6 A4.4 4.4 0 0 1 11.6 19 H9 A4.4 4.4 0 0 1 4.6 14.6 Z M16 10.4 H17.4 A2.6 2.6 0 0 1 17.4 15.6 H16 M8.4 3.6 V6 M12.2 3.6 V6"/>'''
H["wc"] = '''
<path class="p" d="M2.6 8 L4.4 16 L6.8 10.4 L9.2 16 L11 8 M20.8 9.4 A3.8 4.2 0 1 0 20.8 14.6" data-w="2.4"/>'''
H["meeting"] = '''
<circle class="f" cx="7" cy="8.2" r="3"/>
<circle class="f" cx="17" cy="8.2" r="3"/>
<path class="fp" d="M2.8 19.2 C2.8 15.6 4.6 13.4 7 13.4 C9.4 13.4 11.2 15.6 11.2 19.2 Z M12.8 19.2 C12.8 15.6 14.6 13.4 17 13.4 C19.4 13.4 21.2 15.6 21.2 19.2 Z" data-w="1"/>'''
H["food"] = '''
<path class="t" d="M16.4 3.4 C18.8 4.6 19.6 8.4 19.6 12.4 H16.4 Z"/>
<path class="p" d="M5.2 3.4 V8.4 A2.8 2.8 0 0 0 10.8 8.4 V3.4 M8 3.4 V20.6 M16.4 20.6 V3.4 C18.8 4.6 19.6 8.4 19.6 12.4 H16.4"/>'''

HEAD_ORDER = ["code", "design", "test", "research", "phone", "meeting", "coffee", "food", "wc"]
