# Geometry kit for the Menajer Masası icon family ("masa damgası" dialect).
#
# Every glyph is built as filled shapes on a 24 x 24 grid and exported as plain paths with fill-rule evenodd:
# no strokes, masks, filters, CSS or <use>, so Godot's SVG importer (ThorVG) draws exactly what Chrome draws.
#
# Needs shapely 2.x (pip install shapely). Only a rebuild needs it: the SVG files in this folder are the product.
import math, os, sys

for _p in (os.environ.get("ICON_PYLIB"),):
    if _p and _p not in sys.path:
        sys.path.insert(0, _p)

from shapely.geometry import Point, Polygon, LineString, MultiPolygon, GeometryCollection, box
from shapely.ops import unary_union
from shapely import affinity

# ---------------------------------------------------------------- the family constants (24 grid)
LINE = 2.6    # line glyph weight; the office head icons use the same 2.6
KO = 2.0      # every knock-out channel and every gap between two pieces
TONE = 0.4    # the second tone: same colour, fill-opacity 0.4
NOTCH = 4.0   # the paper notch: a 45 degree cut on the top right corner of every paper object
Q = 16        # arc segments per quarter circle

ROUND = dict(cap_style="round", join_style="round")


def C(cx, cy, r):
    return Point(cx, cy).buffer(r, quad_segs=Q)


def E(cx, cy, rx, ry):
    return affinity.scale(Point(cx, cy).buffer(1.0, quad_segs=Q), rx, ry, origin=(cx, cy))


def R(x, y, w, h, r=0.0):
    if r <= 0:
        return box(x, y, x + w, y + h)
    r = min(r, w / 2.0, h / 2.0)
    return box(x + r, y + r, x + w - r, y + h - r).buffer(r, quad_segs=Q)


def P(*pts, r=0.0):
    g = Polygon(pts)
    return soften(g, r) if r else g


def L(*pts, w=LINE, cap="round", join="round"):
    return LineString(pts).buffer(w / 2.0, quad_segs=Q, cap_style=cap, join_style=join)


def arc_pts(cx, cy, r, a0, a1, n=None):
    """Points on an arc, degrees, y down (0 = right, 90 = down)."""
    n = n or max(4, int(abs(a1 - a0) / 6))
    return [(cx + r * math.cos(math.radians(a0 + (a1 - a0) * i / n)),
             cy + r * math.sin(math.radians(a0 + (a1 - a0) * i / n))) for i in range(n + 1)]


def A(cx, cy, r, a0, a1, w=LINE, cap="round"):
    return LineString(arc_pts(cx, cy, r, a0, a1)).buffer(w / 2.0, quad_segs=Q, cap_style=cap, join_style="round")


def ring(cx, cy, r, w=LINE):
    return C(cx, cy, r + w / 2.0).difference(C(cx, cy, r - w / 2.0))


def wedge(cx, cy, r, a0, a1):
    return Polygon([(cx, cy)] + arc_pts(cx, cy, r, a0, a1))


def U(*g):
    return unary_union([x for x in g if x is not None and not x.is_empty])


def cut(a, *b):
    """a with b removed."""
    return a.difference(U(*b))


def ko(a, *lines, w=KO, cap="round"):
    """Knock-out channels of width w along polylines (each a list of points) through a."""
    return a.difference(U(*[L(*pts, w=w, cap=cap) for pts in lines]))


def gap(back, *front, g=KO):
    """back with a g-wide gap around front."""
    return back.difference(U(*front).buffer(g, quad_segs=Q))


def soften(g, r):
    """Round convex corners with radius r."""
    return g.buffer(-r, quad_segs=Q, join_style="round").buffer(r, quad_segs=Q, join_style="round")


def notch(g, x1, y0, n=NOTCH):
    """The paper notch: cut the top right corner (x1 = right edge, y0 = top edge) at 45 degrees."""
    return g.difference(Polygon([(x1 - n, y0 - 2), (x1 + 2, y0 - 2), (x1 + 2, y0 + n + 2)]))


def rot(g, deg, o=(12, 12)):
    return affinity.rotate(g, deg, origin=o)


def mv(g, dx, dy):
    return affinity.translate(g, dx, dy)


def sc(g, f, o=(12, 12)):
    return affinity.scale(g, f, f, origin=o)


def flipx(g, cx=12.0):
    return affinity.scale(g, -1, 1, origin=(cx, 0))


def pick(g, x, y):
    """The part of a multi-piece geometry that contains (x, y), and the rest."""
    parts = list(g.geoms) if hasattr(g, "geoms") else [g]
    p = Point(x, y)
    hit = [q for q in parts if q.buffer(0.01).contains(p)]
    rest = [q for q in parts if q not in hit]
    return U(*hit), U(*rest)


def star_pts(cx, cy, ro, ri, n=5, a0=-90):
    return [(cx + (ro if i % 2 == 0 else ri) * math.cos(math.radians(a0 + i * 180 / n)),
             cy + (ro if i % 2 == 0 else ri) * math.sin(math.radians(a0 + i * 180 / n))) for i in range(2 * n)]


def sparkle(cx, cy, r, pinch=0.18, n=64):
    """Four point star with concave sides: an astroid blended with a circle (pinch = how much circle)."""
    pts = []
    for i in range(n):
        t = 2 * math.pi * i / n
        c, s = math.cos(t), math.sin(t)
        pts.append((cx + r * ((1 - pinch) * c ** 3 + pinch * c), cy + r * ((1 - pinch) * s ** 3 + pinch * s)))
    return Polygon(pts)


# ---------------------------------------------------------------- export
def _f(v):
    s = ("%.2f" % v).rstrip("0").rstrip(".")
    return "0" if s in ("-0", "") else s


def _ring_d(coords):
    pts = list(coords)[:-1]
    return "M" + " L".join("%s %s" % (_f(x), _f(y)) for x, y in pts) + " Z"


def polys(g):
    if g is None or g.is_empty:
        return []
    if isinstance(g, Polygon):
        return [g]
    out = []
    for q in getattr(g, "geoms", []):
        out += polys(q)
    return out


def to_d(g):
    g = g.simplify(0.015, preserve_topology=True)
    out = []
    for p in polys(g):
        if p.area < 0.05:
            continue
        out.append(_ring_d(p.exterior.coords))
        out += [_ring_d(i.coords) for i in p.interiors]
    return " ".join(out)


def paths(glyph, color="#FFFFFF", tone=TONE):
    """glyph: dict with 's' (solid) and optional 't' (tone). Returns the SVG body."""
    out = []
    t = glyph.get("t")
    if t is not None and not t.is_empty:
        out.append('<path fill="%s" fill-opacity="%g" fill-rule="evenodd" d="%s"/>' % (color, tone, to_d(t)))
    s = glyph.get("s")
    if s is not None and not s.is_empty:
        out.append('<path fill="%s" fill-rule="evenodd" d="%s"/>' % (color, to_d(s)))
    return "\n".join(out)


def svg(glyph, color="#FFFFFF", size=24, tone=TONE):
    return ('<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 24 24">\n%s\n</svg>\n'
            % (size, size, paths(glyph, color, tone)))


# ---------------------------------------------------------------- SVG path data to polygons (absolute M L H V C Q Z)
def _bez(p, n=12):
    out = []
    for i in range(1, n + 1):
        t = i / n
        if len(p) == 3:
            out.append(tuple((1 - t) ** 2 * p[0][k] + 2 * (1 - t) * t * p[1][k] + t * t * p[2][k] for k in (0, 1)))
        else:
            out.append(tuple((1 - t) ** 3 * p[0][k] + 3 * (1 - t) ** 2 * t * p[1][k] + 3 * (1 - t) * t * t * p[2][k]
                             + t ** 3 * p[3][k] for k in (0, 1)))
    return out


def pathpoly(d):
    import re
    tok = re.findall(r"[MLHVCQZ]|-?\d*\.?\d+", d)
    rings, cur, i, cmd, pos = [], [], 0, None, (0.0, 0.0)

    def num():
        nonlocal i
        v = float(tok[i]); i += 1
        return v
    while i < len(tok):
        if tok[i] in "MLHVCQZ":
            cmd = tok[i]; i += 1
        if cmd == "M":
            if cur:
                rings.append(cur)
            pos = (num(), num()); cur = [pos]; cmd = "L"
        elif cmd == "L":
            pos = (num(), num()); cur.append(pos)
        elif cmd == "H":
            pos = (num(), pos[1]); cur.append(pos)
        elif cmd == "V":
            pos = (pos[0], num()); cur.append(pos)
        elif cmd == "C":
            p1 = (num(), num()); p2 = (num(), num()); p3 = (num(), num())
            cur += _bez([pos, p1, p2, p3]); pos = p3
        elif cmd == "Q":
            p1 = (num(), num()); p2 = (num(), num())
            cur += _bez([pos, p1, p2]); pos = p2
        elif cmd == "Z":
            if cur:
                rings.append(cur)
            cur = []
    if cur:
        rings.append(cur)
    out = None
    for r in rings:
        p = Polygon(r).buffer(0)
        out = p if out is None else out.symmetric_difference(p)
    return out


def leaf(x0, y0, x1, y1, w):
    """A lens (vesica) from (x0, y0) to (x1, y1), w wide at the middle."""
    ln = math.hypot(x1 - x0, y1 - y0)
    h = w / 2.0
    r = (ln * ln / 4.0 + h * h) / (2 * h)
    a = Point(0, 0)
    c1 = Point(ln / 2.0, r - h).buffer(r, quad_segs=Q)
    c2 = Point(ln / 2.0, -(r - h)).buffer(r, quad_segs=Q)
    g = c1.intersection(c2)
    g = affinity.rotate(g, math.degrees(math.atan2(y1 - y0, x1 - x0)), origin=(0, 0))
    return affinity.translate(g, x0, y0)


def hull(*g):
    return U(*g).convex_hull
