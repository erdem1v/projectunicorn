# Menajer Masası icon family, "masa damgası" dialect: the single source of every glyph.
#
# 24 grid, 20 px live area. The primary shape is SOLID; its details are knock-outs (cuts through to the
# ground), every cut and every gap KO = 2. Line glyphs (chevrons, plus, close, arrows) are LINE = 2.6, the same
# weight as the office head icons, so the 3D world and the windows share one voice. A second plane (the person
# behind, the empty half, the shade side) is the TONE: same colour at 40 %. Paper objects carry the family's
# mark, the paper notch: a 45 degree cut on the top right corner.
#
# Each entry returns {"s": solid geometry, "t": tone geometry or None}. kit.py exports them as plain filled
# paths (fill-rule evenodd), drawn in #FFFFFF so Godot colours them with modulate.
from kit import *

G = {}


def glyph(key):
    def deco(fn):
        G[key] = fn
        return fn
    return deco


def S(s, t=None):
    return {"s": s, "t": t}


# ---------------------------------------------------------------- shared parts
def person(cx, head_cy, hr, bw, bottom, neck=KO):
    """Head and bust. bw = bust width at the bottom."""
    head = C(cx, head_cy, hr)
    top = head_cy + hr + neck
    ry = (bottom - top) * 1.25
    bust = E(cx, top + ry, bw / 2.0, ry).intersection(box(cx - bw, top - 1, cx + bw, bottom))
    return head, soften(bust, 0.6)


def bubble(x, y, w, h, tail, r=2.2):
    return soften(U(R(x, y, w, h, r), P(*tail)), 0.5)


def bug_body():
    head = C(12, 8.0, 3.0).intersection(box(0, 0, 24, 8.0))
    body = E(12, 15.0, 5.5, 6.2)
    legs = U(L((6.8, 12.4), (3.4, 10.6), w=2.2), L((6.4, 15.6), (2.8, 15.6), w=2.2),
             L((7.2, 18.8), (4.2, 21.2), w=2.2))
    legs = U(legs, flipx(legs))
    ant = U(L((10.6, 5.6), (9.0, 3.2), w=2.0), L((13.4, 5.6), (15.0, 3.2), w=2.0))
    return head, body, legs, ant


SHIELD = "M12 2.6 L20 5.6 V11.4 C20 16.2 16.6 19.8 12 21.4 C7.4 19.8 4 16.2 4 11.4 V5.6 Z"


def gearshape(cx, cy, n=6, rc=6.6, ro=9.8, tw=4.4, hole=3.0):
    g = C(cx, cy, rc)
    for i in range(n):
        t = R(cx - tw / 2, cy - ro, tw, ro, 0)
        g = U(g, rot(t, i * 360 / n, (cx, cy)))
    g = soften(g.intersection(C(cx, cy, ro)), 0.7)
    return g.difference(C(cx, cy, hole))


# ================================================================ RAIL (8 tabs + settings + optional rivals)
@glyph("rail/product")
def _():
    top, rt, rb, bot, lb, lt, c = (12, 2.4), (20.8, 7.2), (20.8, 16.8), (12, 21.6), (3.2, 16.8), (3.2, 7.2), (12, 12)
    hexa = soften(P(top, rt, rb, bot, lb, lt), 1.0)
    cutted = ko(hexa, [(1, 6.1), c, (23, 6.1)], [c, (12, 24)], cap="flat")
    right, rest = pick(cutted, 17, 14)
    return S(rest, right)


@glyph("rail/sales")
def _():
    f = soften(P((2.6, 3.4), (21.4, 3.4), (14.2, 12.4), (14.2, 16.6), (9.8, 16.6), (9.8, 12.4)), 0.9)
    f = ko(f, [(0, 8.0), (24, 8.0)], cap="flat")
    return S(U(f, C(12, 20.2, 1.8)))


@glyph("rail/hr")
def _():
    fh, fb = person(9.2, 7.6, 3.8, 14.4, 21.4)
    bh, bb = person(16.8, 6.6, 3.1, 10.0, 19.4)
    back = gap(U(bh, bb), fb, fh)
    return S(U(fh, fb), back)


def dollar_coin():
    s_ = LineString(arc_pts(12, 9.5, 2.7, -35, -270) + arc_pts(12, 14.9, 2.7, -90, 145)[1:])
    s_ = s_.buffer(KO / 2, quad_segs=Q, cap_style="round", join_style="round")
    bars = U(L((12, 4.2), (12, 5.6), w=KO), L((12, 18.8), (12, 20.2), w=KO))
    return cut(C(12, 12.2, 9.8), s_, bars)


@glyph("rail/finance")
def _():
    # a coin with the dollar knocked out: the game's money. A coin stack read as "database", two banknotes as a camera.
    return S(dollar_coin())


@glyph("rail/personal")
def _():
    h, b = person(12, 7.2, 4.4, 16.6, 21.4)
    return S(U(h, b))


@glyph("rail/marketing")
def _():
    body = soften(P((3.0, 9.0), (8.0, 9.0), (16.8, 4.0), (16.8, 20.0), (8.0, 15.0), (3.0, 15.0)), 1.0)
    body = ko(body, [(8.4, 0), (8.4, 24)], cap="flat")
    handle = soften(P((4.6, 16.6), (8.4, 16.6), (9.8, 21.2), (6.4, 21.2)), 0.6)
    wave = A(17.4, 12, 4.4, -42, 42)
    return S(U(body, wave), gap(handle, body))


@glyph("rail/rnd")
def _():
    flask = soften(P((9.6, 4.4), (14.4, 4.4), (14.4, 9.4), (20.6, 19.0), (19.6, 21.4), (4.4, 21.4), (3.4, 19.0),
                     (9.6, 9.4)), 1.2)
    lip = R(8.0, 2.4, 8.0, 2.6, 1.3)
    glass = U(flask, lip)
    liquid = glass.intersection(box(0, 13.4, 24, 24))
    liquid = cut(liquid, C(13.4, 17.2, 1.2))
    return S(liquid, gap(glass, liquid))


@glyph("rail/events")
def _():
    env = notch(R(2.4, 4.6, 19.2, 14.8, 2.0), 21.6, 4.6)
    env = ko(env, [(1.2, 5.2), (12, 12.8), (22.8, 5.2)])
    return S(env)


@glyph("rail/settings")
def _():
    return S(gearshape(12, 12))


@glyph("rail/rivals")
def _():
    mid = R(8.4, 8.6, 7.2, 13.0, 1.0)
    left = R(2.2, 12.8, 4.6, 8.8, 1.0)
    right = R(17.2, 15.4, 4.6, 6.2, 1.0)
    st = soften(P(*star_pts(12, 4.0, 3.6, 1.6)), 0.3)
    return S(U(mid, st), U(left, right))


# ================================================================ SKILLS (Ekip column heads = sprint card roles)
@glyph("skill/product")
def _():
    post = R(10.8, 2.2, 2.4, 19.4, 1.2)
    b1 = soften(P((5.0, 4.0), (17.6, 4.0), (20.8, 7.2), (17.6, 10.4), (5.0, 10.4)), 0.8)
    b2 = soften(P((6.4, 12.6), (19.0, 12.6), (19.0, 18.6), (6.4, 18.6), (3.4, 15.6)), 0.8)
    return S(U(b1, post), gap(b2, post))


@glyph("skill/design")
def _():
    nib = soften(P((12, 21.8), (5.8, 12.6), (8.6, 6.6), (15.4, 6.6), (18.2, 12.6)), 0.8)
    nib = ko(nib, [(12, 24), (12, 14.4)], cap="flat")
    nib = cut(nib, C(12, 12.8, 1.8))
    collar = R(8.4, 2.2, 7.2, 2.6, 1.0)
    return S(U(nib, collar))


@glyph("skill/engineering")
def _():
    br = U(L((8.0, 6.4), (2.8, 12), (8.0, 17.6)), L((16.0, 6.4), (21.2, 12), (16.0, 17.6)))
    sl = L((13.6, 4.6), (10.4, 19.4))
    return S(br, sl)


@glyph("skill/qa")
def _():
    # the bug with a check through it: finds and verifies. The bug alone is product/bug, the bug count.
    head = C(12, 7.4, 3.0).intersection(box(0, 0, 24, 7.4))
    body = E(12, 14.6, 6.6, 6.8)
    legs = U(L((5.6, 11.4), (2.8, 10.0), w=2.2), L((5.4, 15.2), (2.4, 15.2), w=2.2), L((6.2, 19.0), (3.6, 21.0), w=2.2))
    legs = U(legs, flipx(legs))
    ant = U(L((10.6, 5.0), (9.0, 2.8), w=2.0), L((13.4, 5.0), (15.0, 2.8), w=2.0))
    body = ko(body, [(8.2, 14.8), (11.0, 17.6), (16.2, 11.8)], w=2.2)
    return S(U(head, body, legs, ant))


@glyph("skill/sales")
def _():
    tag = soften(P((3.0, 3.0), (11.4, 3.0), (21.0, 12.6), (12.6, 21.0), (3.0, 11.4)), 1.4)
    return S(cut(tag, C(7.8, 7.8, 2.0)))


@glyph("skill/customer_success")
def _():
    band = A(12, 12.6, 8.0, 180, 360, w=2.4)
    cups = U(R(2.6, 11.4, 5.4, 8.4, 1.8), R(16.0, 11.4, 5.4, 8.4, 1.8))
    boom = L((18.6, 19.4), (18.0, 21.0), (15.6, 21.4), w=2.0)
    mic = R(10.6, 20.0, 4.4, 2.8, 1.4)
    return S(U(band, cups), U(boom, mic))


# ================================================================ DEPARTMENTS (roster group headers)
@glyph("dept/product_design")
def _():
    globe = soften(U(C(12, 9.4, 7.0), P((8.0, 12.8), (16.0, 12.8), (14.8, 16.0), (9.2, 16.0))), 0.6)
    globe = cut(globe, A(12, 9.4, 3.9, 195, 265, w=KO))
    base = U(R(8.8, 17.6, 6.4, 1.8, 0.9), R(10.0, 20.0, 4.0, 1.8, 0.9))
    return S(U(globe, base))


@glyph("dept/development")
def _():
    w = R(2.4, 4.0, 19.2, 16.4, 2.0)
    w = ko(w, [(0, 8.4), (24, 8.4)], cap="flat")
    w = ko(w, [(6.6, 11.4), (9.6, 14.0), (6.6, 16.6)], [(12.2, 16.6), (17.0, 16.6)])
    return S(w)


@glyph("dept/sales")
def _():
    body = R(2.4, 7.6, 19.2, 13.0, 2.0)
    body = ko(body, [(0, 13.0), (24, 13.0)], cap="flat")
    clasp = R(10.0, 11.2, 4.0, 3.6, 0.8)
    handle = L((8.8, 7.6), (8.8, 4.2), (15.2, 4.2), (15.2, 7.6), w=2.2)
    return S(U(body, clasp, handle))


@glyph("dept/customer_success")
def _():
    front = bubble(2.4, 9.0, 13.2, 8.8, [(5.0, 16.6), (4.8, 21.2), (10.2, 16.6)])
    back = bubble(8.4, 2.8, 13.2, 8.6, [(15.6, 10.8), (19.6, 14.8), (19.4, 10.8)])
    return S(front, gap(back, front))


# ================================================================ TRAITS (8 employee traits + unspecified)
@glyph("trait/loyal")
def _():
    eye = ring(12, 4.6, 1.9, w=2.2)
    shank = L((12, 7.4), (12, 20.6), w=2.6)
    stock = L((7.6, 10.4), (16.4, 10.4), w=2.4)
    arms = A(12, 12.6, 7.8, 28, 152, w=2.6)
    fl = soften(P((2.4, 16.0), (7.4, 15.0), (4.2, 11.6)), 0.4)
    return S(U(eye, shank, stock, arms, fl, flipx(fl)))


@glyph("trait/picks_it_up_fast")
def _():
    return S(soften(P((14.0, 2.2), (4.6, 13.8), (11.0, 13.8), (9.6, 21.8), (19.4, 10.0), (13.0, 10.0)), 0.5))


@glyph("trait/last_one_out")
def _():
    moon = soften(C(11.0, 13.0, 8.6).difference(C(16.8, 8.0, 7.0)), 0.4)
    star = sparkle(18.4, 4.6, 3.2, pinch=0.2)
    return S(U(moon, star))


@glyph("trait/takes_them_under")
def _():
    # an umbrella over a small figure: "takes them under". (A wing did not read at 16 px.)
    can = C(12, 11.6, 9.8).intersection(box(0, 0, 24, 11.6))
    for x in (4.65, 9.55, 14.45, 19.35):
        can = can.difference(C(x, 11.6, 2.45))
    h, b = person(12, 14.8, 2.4, 9.4, 21.6, neck=1.4)
    return S(soften(can, 0.4), U(h, b))


@glyph("trait/double_checker")
def _():
    return S(L((10.2, 14.6), (12.4, 16.8), (21.6, 6.8)), L((2.4, 12.6), (6.6, 16.8), (14.4, 8.4)))


@glyph("trait/cant_say_no")
def _():
    b = bubble(4.4, 2.2, 15.2, 9.4, [(7.0, 11.0), (6.0, 13.6), (11.4, 11.0)])
    b = ko(b, [(8.2, 6.8), (10.6, 9.0), (15.4, 4.4)])
    papers = U(R(5.2, 15.6, 15.6, 2.4, 1.0), R(3.2, 19.6, 15.6, 2.4, 1.0))
    return S(b, papers)


@glyph("trait/bag_packed")
def _():
    body = R(5.6, 7.4, 12.8, 11.6, 2.2)
    body = ko(body, [(10.0, 9.6), (10.0, 16.8)], [(14.0, 9.6), (14.0, 16.8)])
    handle = L((9.6, 7.4), (9.6, 3.0), (14.4, 3.0), (14.4, 7.4), w=2.2)
    wheels = U(C(8.8, 21.0, 1.5), C(15.2, 21.0, 1.5))
    return S(U(body, handle, wheels))


@glyph("trait/mood_buster")
def _():
    cloud = U(C(7.4, 11.6, 4.0), C(12.6, 8.6, 5.2), C(17.4, 12.0, 3.6), R(7.4, 10.0, 10.0, 5.6))
    cloud = soften(cloud.intersection(box(0, 0, 24, 15.6)), 0.6)
    rain = U(L((8.4, 18.0), (7.2, 21.0), w=2.2), L((12.4, 18.0), (11.2, 21.0), w=2.2), L((16.4, 18.0), (15.2, 21.0), w=2.2))
    return S(cloud, rain)


@glyph("trait/unspecified")
def _():
    d = soften(P((12, 2.4), (21.6, 12), (12, 21.6), (2.4, 12)), 1.4)
    return S(cut(d, C(12, 12, 2.6)))


# ================================================================ PRODUCT (sprint card kinds, voices, bug count)
@glyph("product/kind_feature")
def _():
    return S(U(sparkle(10.4, 13.2, 8.6, pinch=0.16), sparkle(18.6, 5.0, 3.4, pinch=0.2)))


@glyph("product/kind_polish")
def _():
    return S(L((5.2, 11.4), (12, 4.8), (18.8, 11.4)), L((5.2, 18.8), (12, 12.2), (18.8, 18.8)))


@glyph("product/kind_fix")
def _():
    band = R(1.4, 7.4, 21.2, 9.2, 4.6)
    band = ko(band, [(8.6, 0), (8.6, 24)], [(15.4, 0), (15.4, 24)], cap="flat")
    pad, ends = pick(band, 12, 12)
    return S(rot(ends, -45), rot(pad, -45))


@glyph("product/kind_research")
def _():
    lens = ring(10.2, 10.2, 6.6, w=2.6)
    handle = L((15.4, 15.4), (20.8, 20.8), w=3.2)
    h, b = person(10.2, 8.2, 2.0, 7.0, 15.4, neck=1.2)
    inner = C(10.2, 10.2, 6.6 - 1.3 - 1.2)
    return S(U(lens, handle, h.intersection(inner), b.intersection(inner)))


@glyph("product/voices")
def _():
    b = bubble(2.4, 3.8, 19.2, 13.2, [(6.2, 16.0), (6.2, 21.0), (11.6, 16.0)], r=2.4)
    b = ko(b, [(6.8, 8.6), (17.2, 8.6)], [(6.8, 12.4), (13.4, 12.4)])
    return S(b)


@glyph("product/bug")
def _():
    head, body, legs, ant = bug_body()
    body = ko(body, [(12, 9.0), (12, 24)], cap="flat")
    return S(U(head, body, legs, ant))


# ================================================================ STAKE (the decision cost glyphs; SPEC rule 5)
@glyph("stake/cash_in")
def _():
    d = C(12, 12, 9.8)
    return S(ko(d, [(12, 17.6), (12, 7.0)], [(7.4, 11.6), (12, 7.0), (16.6, 11.6)], w=2.4))


@glyph("stake/cost")
def _():
    return S(ko(C(12, 12, 9.8), [(7.0, 12), (17.0, 12)], w=2.4))


@glyph("stake/equity")
def _():
    cx, cy, r = 11.0, 13.0, 8.6
    pie = soften(C(cx, cy, r).difference(wedge(cx, cy, r + 1, -90, -30)), 0.5)
    sl = soften(mv(wedge(cx, cy, r, -90, -30), 1.2, -2.0), 0.5)
    return S(U(pie, sl))


# ================================================================ UTILITY
@glyph("util/warn")
def _():
    t = soften(P((12, 2.4), (22.4, 20.6), (1.6, 20.6)), 1.6)
    t = ko(t, [(12, 9.0), (12, 13.8)], w=2.4)
    return S(cut(t, C(12, 17.2, 1.4)))


@glyph("util/lock")
def _():
    body = R(4.4, 10.0, 15.2, 11.6, 2.2)
    body = cut(body, U(C(12, 14.6, 1.8), R(11.2, 14.6, 1.6, 3.8, 0.8)))
    shackle = U(A(12, 8.2, 4.4, 180, 360), L((7.6, 8.2), (7.6, 10.2)), L((16.4, 8.2), (16.4, 10.2)))
    return S(U(body, shackle))


@glyph("util/clock")
def _():
    d = C(12, 12, 9.8)
    return S(ko(d, [(12, 6.4), (12, 12), (16.0, 14.4)], w=KO))


@glyph("util/pause")
def _():
    return S(U(R(6.0, 4.4, 4.4, 15.2, 1.2), R(13.6, 4.4, 4.4, 15.2, 1.2)))


@glyph("util/play")
def _():
    return S(soften(P((6.8, 4.0), (20.0, 12), (6.8, 20.0)), 1.2))


@glyph("util/check")
def _():
    return S(L((4.4, 12.6), (9.6, 17.6), (19.6, 6.8)))


@glyph("util/plus")
def _():
    return S(U(L((12, 4.4), (12, 19.6)), L((4.4, 12), (19.6, 12))))


@glyph("util/minus")
def _():
    return S(L((4.4, 12), (19.6, 12)))


@glyph("util/close")
def _():
    return S(U(L((6.0, 6.0), (18.0, 18.0)), L((18.0, 6.0), (6.0, 18.0))))


@glyph("util/arrow_right")
def _():
    return S(U(L((3.6, 12), (19.6, 12)), L((13.6, 5.8), (19.8, 12), (13.6, 18.2))))


@glyph("util/revert")
def _():
    return S(U(A(12.4, 12.6, 7.8, 216, 515), L((4.6, 3.6), (5.4, 8.4), (10.2, 7.6))))


@glyph("util/flat")
def _():
    return S(L((5.4, 12), (18.6, 12)))


@glyph("util/chevron_right")
def _():
    return S(L((9.2, 5.4), (15.8, 12), (9.2, 18.6)))


@glyph("util/chevron_left")
def _():
    return S(L((14.8, 5.4), (8.2, 12), (14.8, 18.6)))


@glyph("util/chevron_up")
def _():
    return S(L((5.4, 14.8), (12, 8.2), (18.6, 14.8)))


@glyph("util/chevron_down")
def _():
    return S(L((5.4, 9.2), (12, 15.8), (18.6, 9.2)))


@glyph("util/search")
def _():
    return S(U(ring(10.2, 10.2, 6.4, w=2.6), L((15.0, 15.0), (20.8, 20.8), w=3.2)))


@glyph("util/filter")
def _():
    knobs = U(C(8.0, 6.2, 2.6), C(16.0, 12.0, 2.6), C(10.6, 17.8, 2.6))
    lines = U(L((3.2, 6.2), (20.8, 6.2), w=2.2), L((3.2, 12.0), (20.8, 12.0), w=2.2), L((3.2, 17.8), (20.8, 17.8), w=2.2))
    return S(knobs, gap(lines, knobs, g=1.2))


@glyph("util/inbox")
def _():
    tray = soften(P((2.4, 11.4), (8.0, 11.4), (9.2, 14.4), (14.8, 14.4), (16.0, 11.4), (21.6, 11.4), (21.6, 21.4),
                    (2.4, 21.4)), 1.6)
    paper = notch(R(8.2, 2.2, 7.6, 10.4, 0.8), 15.8, 2.2, n=2.6)
    return S(tray, gap(paper, tray))


@glyph("util/mail_open")
def _():
    body = R(2.4, 9.4, 19.2, 12.0, 2.0)
    body = ko(body, [(1.2, 10.0), (12, 16.6), (22.8, 10.0)])
    flap = soften(P((2.6, 8.0), (12, 2.2), (21.4, 8.0)), 0.8)
    return S(body, gap(flap, body, g=1.4))


@glyph("util/reply")
def _():
    arc = LineString([(4.4, 11.0), (13.0, 11.0)] + arc_pts(13.0, 18.2, 7.2, 270, 360)[1:])
    return S(U(L((9.8, 5.0), (3.8, 11.0), (9.8, 17.0)), arc.buffer(LINE / 2, quad_segs=Q, cap_style="round",
                                                                    join_style="round")))


@glyph("util/calendar")
def _():
    body = R(2.4, 4.6, 19.2, 17.0, 2.0)
    body = ko(body, [(0, 9.6), (24, 9.6)], cap="flat")
    body = cut(body, R(13.0, 13.2, 4.6, 4.6, 0.8))
    rings = U(L((7.6, 2.2), (7.6, 6.6), w=2.4), L((16.4, 2.2), (16.4, 6.6), w=2.4))
    return S(U(gap(body, rings, g=1.2), rings))


@glyph("util/news")
def _():
    page = notch(R(2.4, 3.8, 15.6, 17.4, 1.6), 18.0, 3.8)
    page = cut(page, R(5.2, 7.0, 7.4, 3.6, 0.4))
    page = ko(page, [(5.6, 14.0), (14.6, 14.0)], [(5.6, 17.6), (11.6, 17.6)])
    back = R(19.4, 8.2, 2.4, 13.0, 1.2)
    return S(page, back)


@glyph("util/move")
def _():
    box_ = R(2.2, 5.4, 12.2, 11.4, 1.4)
    cab = soften(P((16.0, 8.8), (19.2, 8.8), (21.8, 12.2), (21.8, 16.8), (16.0, 16.8)), 0.8)
    cab = cut(cab, soften(P((17.2, 10.4), (18.8, 10.4), (20.2, 12.6), (17.2, 12.6)), 0.3))
    wheels = U(C(6.6, 18.6, 2.4), C(17.6, 18.6, 2.4))
    return S(U(gap(U(box_, cab), wheels, g=1.4), wheels))


@glyph("util/shield")
def _():
    sh = pathpoly(SHIELD)
    left = sh.intersection(box(0, 0, 11.0, 24))
    right = sh.intersection(box(13.0, 0, 24, 24))
    return S(left, right)


@glyph("util/dice")
def _():
    d = R(3.0, 3.0, 18.0, 18.0, 3.2)
    return S(cut(d, C(8.0, 8.0, 1.9), C(12, 12, 1.9), C(16.0, 16.0, 1.9)))


STAR = P(*star_pts(12, 12.8, 10.0, 4.3))


@glyph("util/star_full")
def _():
    return S(soften(STAR, 0.8))


@glyph("util/star_half")
def _():
    s = soften(STAR, 0.8)
    return S(s.intersection(box(0, 0, 12, 24)), s.intersection(box(12, 0, 24, 24)))


@glyph("util/star_empty")
def _():
    return S(None, soften(STAR, 0.8))


@glyph("util/tri_up")
def _():
    return S(soften(P((12, 5.4), (19.6, 17.4), (4.4, 17.4)), 1.0))


@glyph("util/tri_down")
def _():
    return S(soften(P((12, 18.6), (19.6, 6.6), (4.4, 6.6)), 1.0))


@glyph("util/sparkle")
def _():
    return S(sparkle(12, 12, 9.4, pinch=0.16))


@glyph("util/enter")
def _():
    return S(U(L((19.4, 4.6), (19.4, 13.0), (5.4, 13.0)), L((9.8, 8.6), (5.4, 13.0), (9.8, 17.4))))


@glyph("util/history")
def _():
    arc = A(12.6, 12.2, 8.0, 205, 505, w=2.4)
    head = L((3.6, 4.4), (4.6, 9.0), (9.2, 8.0), w=2.4)
    hands = L((12.6, 7.8), (12.6, 12.2), (15.6, 14.0), w=2.2)
    return S(U(arc, head, hands))


@glyph("util/info")
def _():
    d = C(12, 12, 9.8)
    d = ko(d, [(12, 10.8), (12, 16.8)], w=2.4)
    return S(cut(d, C(12, 7.2, 1.5)))


@glyph("util/queue")
def _():
    front = R(3.0, 11.0, 18.0, 10.6, 1.6)
    mid = R(5.0, 6.8, 14.0, 2.2, 1.1)
    back = R(7.4, 2.6, 9.2, 2.2, 1.1)
    return S(front, U(mid, back))


@glyph("util/doc")
def _():
    page = notch(R(4.2, 2.4, 15.6, 19.2, 1.6), 19.8, 2.4, n=5.0)
    page = ko(page, [(8.0, 10.6), (16.0, 10.6)], [(8.0, 14.2), (16.0, 14.2)], [(8.0, 17.8), (12.8, 17.8)])
    return S(page)


@glyph("util/keyboard")
def _():
    k = R(2.0, 5.6, 20.0, 12.8, 2.0)
    keys = [R(x, 8.4, 2.4, 2.4, 0.4) for x in (5.0, 9.0, 13.0, 16.6)]
    k = cut(k, *keys)
    k = ko(k, [(7.6, 14.8), (16.4, 14.8)])
    return S(k)


@glyph("util/save")
def _():
    body = soften(P((3.0, 3.0), (17.0, 3.0), (21.0, 7.0), (21.0, 21.0), (3.0, 21.0)), 1.6)
    body = cut(body, R(7.0, 3.0 - 1, 8.6, 6.4 + 1, 0.6), R(6.6, 12.8, 10.8, 6.2, 0.8))
    return S(body)


@glyph("util/load")
def _():
    back = soften(P((2.4, 4.6), (8.8, 4.6), (10.8, 6.8), (19.4, 6.8), (19.4, 10.4), (2.4, 10.4)), 1.2)
    front = soften(P((5.6, 10.8), (22.0, 10.8), (18.6, 20.6), (2.2, 20.6)), 1.0)
    side = R(2.4, 8.0, 2.0, 12.6, 0)
    return S(front, gap(U(back, side), front, g=1.6))


@glyph("util/menu")
def _():
    return S(U(L((4.4, 6.4), (19.6, 6.4)), L((4.4, 12), (19.6, 12)), L((4.4, 17.6), (19.6, 17.6))))


@glyph("util/language")
def _():
    g = C(12, 12, 9.8)
    meridian = E(12, 12, 4.2, 9.8).boundary.buffer(KO / 2, quad_segs=Q)
    g = cut(g, meridian)
    g = ko(g, [(1, 12), (23, 12)], cap="flat")
    return S(g)


# ================================================================ WORLD (game concepts with no glyph before)
@glyph("world/person_left")
def _():
    h, b = person(8.8, 7.4, 3.8, 13.6, 21.4)
    arrow = U(L((14.6, 13.6), (21.2, 13.6), w=2.4), L((18.2, 10.6), (21.2, 13.6), (18.2, 16.6), w=2.4))
    return S(arrow, gap(U(h, b), arrow))


@glyph("world/seat")
def _():
    back = R(5.8, 2.6, 12.4, 9.0, 2.4)
    seat = R(5.8, 13.4, 12.4, 4.4, 1.2)
    arms = U(R(2.2, 10.0, 3.0, 9.2, 1.4), R(18.8, 10.0, 3.0, 9.2, 1.4))
    legs = U(L((5.0, 20.0), (5.0, 21.4), w=2.0), L((19.0, 20.0), (19.0, 21.4), w=2.0))
    return S(U(seat, arms, legs), gap(back, seat, g=1.6))


@glyph("world/milestone")
def _():
    # a flag planted on a summit: Kilometre Taşları, the milestone ending
    pole = R(7.8, 2.4, 2.2, 14.6, 1.1)
    fl = soften(P((10.6, 2.8), (20.2, 2.8), (17.6, 6.4), (20.2, 10.0), (10.6, 10.0)), 0.6)
    mound = soften(P((1.8, 21.6), (8.6, 15.2), (13.2, 18.0), (16.0, 15.6), (22.2, 21.6)), 0.8)
    return S(U(pole, fl), gap(mound, pole, g=1.4))


@glyph("world/shutter")
def _():
    box_ = R(2.4, 2.4, 19.2, 4.4, 1.4)
    curtain = R(4.8, 8.8, 14.4, 8.8, 0.8)
    curtain = ko(curtain, [(0, 11.6), (24, 11.6)], [(0, 14.6), (24, 14.6)], w=1.4, cap="flat")
    grip = R(10.0, 17.4, 4.0, 1.8, 0.9)
    rails = U(R(2.4, 8.8, 1.4, 12.8, 0.7), R(20.2, 8.8, 1.4, 12.8, 0.7))
    return S(U(box_, curtain, grip), rails)


@glyph("world/term_sheet")
def _():
    page = notch(R(4.2, 2.4, 15.6, 19.2, 1.6), 19.8, 2.4, n=5.0)
    page = ko(page, [(8.0, 8.0), (13.0, 8.0)], [(8.0, 11.6), (16.0, 11.6)])
    page = ko(page, [(7.8, 17.4), (9.6, 15.2), (11.4, 17.6), (13.0, 15.4), (14.6, 17.2), (16.2, 16.4)], w=1.8)
    return S(page)


@glyph("world/fund")
def _():
    roof = soften(P((2.2, 8.2), (12, 2.4), (21.8, 8.2)), 0.6)
    cols = U(*[R(x, 10.2, 3.0, 7.8, 0.4) for x in (4.2, 10.5, 16.8)])
    base = R(2.2, 19.6, 19.6, 2.0, 0.6)
    return S(U(roof, cols, base))


@glyph("world/runway")
def _():
    strip = soften(P((8.6, 2.4), (15.4, 2.4), (21.6, 21.6), (2.4, 21.6)), 0.6)
    strip = ko(strip, [(12, 4.8), (12, 6.8)], w=1.6)
    strip = ko(strip, [(12, 9.6), (12, 12.4)], w=2.0)
    strip = ko(strip, [(12, 15.4), (12, 19.4)], w=2.4)
    return S(strip)


@glyph("world/crown")
def _():
    c = soften(P((2.8, 6.8), (7.6, 12.0), (12, 4.0), (16.4, 12.0), (21.2, 6.8), (19.2, 17.4), (4.8, 17.4)), 0.8)
    band = R(4.8, 19.2, 14.4, 2.4, 1.2)
    return S(U(c, band))


@glyph("world/training")
def _():
    board = soften(P((12, 3.4), (22.0, 8.6), (12, 13.8), (2.0, 8.6)), 0.6)
    cap = gap(R(6.4, 9.0, 11.2, 8.6, 3.4).intersection(box(0, 10.6, 24, 24)), board, g=1.4)
    tassel = U(L((19.8, 9.8), (19.8, 15.6), w=1.8), C(19.8, 17.0, 1.6))
    return S(U(board, cap), tassel)


@glyph("world/raise")
def _():
    # the Finans coin and an arrow up: a raise is money that goes up for good
    arrow = U(L((19.6, 12.6), (19.6, 3.2), w=2.4), L((16.4, 6.4), (19.6, 3.2), (22.8, 6.4), w=2.4))
    coin = mv(sc(dollar_coin(), 0.74, (12, 12.2)), -3.4, 2.6)
    return S(U(gap(coin, arrow, g=1.6), arrow))


@glyph("world/map")
def _():
    m = P((2.4, 5.4), (8.6, 3.2), (15.4, 5.6), (21.6, 3.4), (21.6, 18.6), (15.4, 20.8), (8.6, 18.4), (2.4, 20.6))
    m = soften(m, 0.5)
    m = ko(m, [(8.6, 1), (8.6, 23)], [(15.4, 1), (15.4, 23)], cap="flat")
    mid, sides = pick(m, 12, 12)
    return S(sides, mid)


# ---------------------------------------------------------------- office places (map chips, office card)
@glyph("place/home")
def _():
    h = soften(P((12, 2.6), (21.6, 11.0), (19.0, 11.0), (19.0, 21.4), (5.0, 21.4), (5.0, 11.0), (2.4, 11.0)), 0.8)
    return S(cut(h, R(10.0, 14.6, 4.0, 8.0, 0.8)))


@glyph("place/ishani")
def _():
    # the han: a stone block with one big arched gate and rows of small windows (fund has a pediment)
    b = R(2.4, 4.4, 19.2, 17.2, 1.0)
    cornice = R(1.4, 2.2, 21.2, 2.4, 0.6)
    gate = U(R(9.2, 14.4, 5.6, 8.0, 0), C(12, 14.4, 2.8))
    wins = [R(x, y, 2.6, 2.6, 0.4) for x in (4.6, 9.0, 12.4, 16.8) for y in (7.6,)] +            [R(x, 13.0, 2.6, 2.6, 0.4) for x in (4.6, 16.8)]
    return S(U(cut(b, gate, *wins), cornice))


@glyph("place/plaza")
def _():
    t = R(6.6, 2.4, 10.8, 19.2, 1.0)
    wins = [R(x, y, 2.2, 2.2, 0.3) for x in (8.8, 13.0) for y in (5.0, 8.6, 12.2, 15.8)]
    t = cut(t, *wins, R(10.6, 19.2, 2.8, 3.0, 0))
    side = U(R(19.0, 10.4, 3.0, 11.2, 0.6), R(2.0, 13.4, 3.0, 8.2, 0.6))
    return S(t, side)


@glyph("place/loft")
def _():
    w = soften(P((2.4, 21.4), (2.4, 10.4), (8.8, 5.2), (8.8, 10.4), (15.2, 5.2), (15.2, 10.4), (21.6, 5.2), (21.6, 21.4)), 0.5)
    w = cut(w, R(5.0, 13.4, 5.8, 4.4, 0.4), R(13.2, 13.4, 5.8, 4.4, 0.4))
    return S(w)


# ---------------------------------------------------------------- origins (onboarding cards)
@glyph("origin/self_made")
def _():
    stem = L((12, 20.4), (12, 10.4), w=2.4)
    l1 = leaf(12, 13.6, 3.4, 8.6, 5.2)
    l2 = leaf(12, 10.8, 21.0, 4.0, 6.0)
    soil = R(4.0, 19.8, 16.0, 2.0, 1.0)
    return S(U(stem, l1, l2), soil)


@glyph("origin/heir")
def _():
    bow = cut(C(7.6, 12, 5.2), C(7.6, 12, 2.0))
    shaft = R(11.8, 10.8, 10.2, 2.6, 0.6)
    teeth = U(R(16.4, 13.0, 2.2, 3.6, 0.4), R(19.6, 13.0, 2.2, 4.8, 0.4))
    return S(U(bow, shaft, teeth))


@glyph("origin/corporate")
def _():
    knot = soften(P((8.8, 2.4), (15.2, 2.4), (14.0, 7.0), (10.0, 7.0)), 0.5)
    blade = soften(P((10.0, 8.8), (14.0, 8.8), (17.8, 17.4), (12, 22.0), (6.2, 17.4)), 0.6)
    blade = ko(blade, [(4, 15.6), (20, 10.8)], w=1.8, cap="flat")
    return S(U(knot, blade))


# ================================================================ OFFICE (glyphs only the 3D head icons use)
@glyph("office/phone")
def _():
    return S(soften(pathpoly("M5.2 4.4 L8.6 3.4 L10.6 8 L8.4 9.6 C9.4 12 11.8 14.6 14.4 15.6 L16 13.4 L20.6 15.4 "
                             "L19.6 18.8 C19.2 20 18 20.8 16.6 20.6 C10.4 19.6 4.4 13.6 3.4 7.4 C3.2 6 4 4.8 5.2 4.4 Z"), 0.5))


@glyph("office/coffee")
def _():
    cup = U(R(3.8, 8.6, 12.4, 5.0, 0), R(3.8, 8.6, 12.4, 12.4, 4.8)).intersection(box(0, 8.6, 24, 24))
    handle = ring(16.6, 13.0, 2.6, w=2.4).intersection(box(16.2, 0, 24, 24))
    steam = U(L((7.8, 2.8), (7.8, 5.6), w=2.2), L((12.2, 2.8), (12.2, 5.6), w=2.2))
    return S(U(cup, handle), steam)


@glyph("office/food")
def _():
    fork = U(L((4.6, 2.8), (4.6, 7.4), (7.4, 10.2), (10.2, 7.4), (10.2, 2.8), w=2.2), L((7.4, 2.8), (7.4, 21.2), w=2.4))
    knife = U(soften(P((16.4, 2.6), (19.8, 6.0), (19.8, 12.8), (15.6, 12.8), (15.6, 3.4)), 0.5), L((17.6, 12.0), (17.6, 21.2), w=2.6))
    return S(U(fork, knife))


@glyph("office/wc")
def _():
    w = L((2.4, 7.6), (4.4, 16.4), (6.9, 10.6), (9.4, 16.4), (11.4, 7.6), w=2.4)
    c = LineString([(17.6 + 3.8 * math.cos(math.radians(a)), 12 + 4.4 * math.sin(math.radians(a)))
                    for a in range(38, 323, 6)]).buffer(1.2, quad_segs=Q, cap_style="round")
    return S(U(w, c))


# ---------------------------------------------------------------- head icon map (office_actor.gd ICONS)
HEAD = {"code": "skill/engineering", "design": "skill/design", "test": "skill/qa", "research": "util/search",
        "phone": "office/phone", "meeting": "rail/hr", "coffee": "office/coffee", "food": "office/food",
        "wc": "office/wc"}
HEAD_ORDER = ["code", "design", "test", "research", "phone", "meeting", "coffee", "food", "wc"]
BREAK = ("meeting", "coffee", "food", "wc")


def build():
    return {k: fn() for k, fn in G.items()}
