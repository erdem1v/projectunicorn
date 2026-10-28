# Lucide (stroke) -> the set's flat solid style: closed shapes filled, detail strokes lying inside a filled shape cut out
# as holes, the rest of the strokes outlined. Subpaths listed in `light` go on the 0.4 layer (the set's second layer).
# Usage: fill2.py <in.svg> <out.svg> <stroke width> [light subpath indexes, comma separated]
import sys
from svgelements import SVG, Shape, Path, Move, Close, Line
from shapely.geometry import LineString, Polygon
from shapely.ops import unary_union

src, dst, sw = sys.argv[1], sys.argv[2], float(sys.argv[3])
light = {int(x) for x in sys.argv[4].split(',')} if len(sys.argv) > 4 and sys.argv[4] else set()
subs = []
for el in SVG.parse(src).elements():
    if not isinstance(el, Shape) or isinstance(el, SVG):
        continue
    for sub in Path(el).as_subpaths():
        pts, closed = [], False
        for seg in sub:
            if isinstance(seg, Move):
                pts.append((seg.end.x, seg.end.y)); continue
            if isinstance(seg, Close):
                closed = True; continue
            n = 1 if isinstance(seg, Line) else 24
            pts += [(seg.point(i / n).x, seg.point(i / n).y) for i in range(1, n + 1)]
        if len(pts) < 2:
            pts.append(pts[0])
        if not closed and len(pts) > 2 and abs(pts[0][0] - pts[-1][0]) < 1e-3 and abs(pts[0][1] - pts[-1][1]) < 1e-3:
            closed = True
        stroke = LineString(pts + ([pts[0]] if closed else [])).buffer(sw / 2, cap_style=1, join_style=1, quad_segs=6) \
            if len(set(pts)) > 1 else LineString([pts[0], (pts[0][0] + 0.01, pts[0][1])]).buffer(sw / 2, quad_segs=6)
        inner = Polygon(pts).buffer(0) if closed and len(pts) >= 3 else None
        subs.append({'stroke': stroke, 'inner': inner if inner is not None and inner.area > 0.5 else None})
holes = []
for i, s in enumerate(subs):
    for j, t in enumerate(subs):
        if i != j and t['inner'] is not None and t['inner'].buffer(0.05).contains(s['stroke'].buffer(-sw / 2 + 0.01).union(s['stroke'].centroid.buffer(0.01))):
            if s['stroke'].intersection(t['inner']).area > 0.6 * s['stroke'].area:
                holes.append(s['stroke']); break
def layer(idx):
    return unary_union([g for i in idx for g in (subs[i]['stroke'], subs[i]['inner']) if g is not None]) if idx else None
full = layer([i for i in range(len(subs)) if i not in light])
if holes:
    full = full.difference(unary_union(holes))
dim = layer(sorted(light))
if dim is not None:
    dim = dim.difference(full.buffer(0.6))

def d_of(geom):
    if geom is None or geom.is_empty:
        return ''
    polys = [geom] if isinstance(geom, Polygon) else [g for g in getattr(geom, 'geoms', []) if isinstance(g, Polygon)]
    out = []
    for poly in polys:
        poly = poly.simplify(0.02)
        for ring in [poly.exterior, *poly.interiors]:
            out.append('M' + ' L'.join('%g %g' % (round(x, 2), round(y, 2)) for x, y in list(ring.coords)[:-1]) + ' Z')
    return ' '.join(out)

parts = ['<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">']
if dim is not None and not dim.is_empty:
    parts.append('<path fill="#FFFFFF" fill-opacity="0.4" fill-rule="evenodd" d="%s"/>' % d_of(dim))
parts.append('<path fill="#FFFFFF" fill-rule="evenodd" d="%s"/>' % d_of(full))
parts.append('</svg>')
open(dst, 'w').write('\n'.join(parts) + '\n')
