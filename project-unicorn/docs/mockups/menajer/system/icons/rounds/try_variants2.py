import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from kit import *
from glyphs import person, S, bubble, G
V = {}
def v(k):
    def d(fn): V[k] = fn; return fn
    return d

def note(x, y, w, h):
    n = R(x, y, w, h, 1.6)
    return cut(n, C(x + w / 2, y + h / 2, min(w, h) * 0.24))

@v("note_offset")
def _():
    front = note(2.0, 9.4, 17.6, 11.0)
    back = R(6.0, 4.6, 16.0, 11.0, 1.6)
    return S(front, gap(back, front))

@v("note_fan")
def _():
    front = rot(note(2.6, 8.6, 17.0, 10.6), -10, (11, 14))
    back = rot(R(4.0, 6.4, 17.0, 10.6, 1.6), 8, (12, 11))
    return S(front, gap(back, front))

@v("safe")
def _():
    body = R(2.8, 3.4, 18.4, 15.8, 2.0)
    dial = C(11.0, 11.3, 4.4)
    body = cut(body, ring(11.0, 11.3, 4.4, w=KO))
    body = ko(body, [(11.0, 9.0), (11.0, 11.3)], w=1.8)
    body = ko(body, [(18.0, 8.4), (18.0, 14.2)], w=KO)
    feet = U(R(4.6, 19.6, 3.4, 2.0, 0.6), R(16.0, 19.6, 3.4, 2.0, 0.6))
    return S(U(body, feet))

@v("coin_dollar")
def _():
    d = C(12, 12, 9.8)
    s = LineString([(15.0, 8.8), (13.6, 7.6), (10.6, 7.6), (9.0, 9.0), (9.0, 10.6), (10.6, 12.0), (13.4, 12.0), (15.0, 13.4), (15.0, 15.0), (13.4, 16.4), (10.4, 16.4), (9.0, 15.2)])
    s = s.buffer(1.0, quad_segs=Q, cap_style="round", join_style="round")
    bar = L((12, 5.0), (12, 19.0), w=1.8)
    return S(cut(d, s, bar))

@v("coin_pile")
def _():
    c3 = C(12, 7.8, 5.2)
    c1 = C(7.4, 15.4, 5.4)
    c2 = C(16.6, 15.4, 5.4)
    f1 = cut(c1, ring(7.4, 15.4, 3.2, w=1.6))
    f2 = cut(c2, ring(16.6, 15.4, 3.2, w=1.6))
    f3 = gap(cut(c3, ring(12, 7.8, 3.0, w=1.6)), c1, c2, g=1.4)
    return S(U(f1, gap(f2, c1, g=1.4)), f3)

@v("stack_coins_side")
def _():
    slabs = [R(4.0 + dx, y, 16.0, 3.0, 1.5) for dx, y in ((-0.8, 18.6), (0.6, 14.0), (-0.4, 9.4))]
    top = E(12.2, 6.4, 7.6, 2.6)
    return S(U(*slabs, gap(top, slabs[2], g=1.4)))

@v("flag_mound")
def _():
    pole = R(10.8, 2.4, 2.2, 15.4, 1.1)
    fl = soften(P((13.6, 3.0), (21.0, 5.6), (13.6, 8.6)), 0.6)
    mound = C(12, 26.0, 9.2).intersection(box(0, 0, 24, 21.6))
    return S(U(pole, fl), gap(mound, pole, g=1.4))

@v("flag_mound2")
def _():
    pole = R(7.8, 2.4, 2.2, 14.6, 1.1)
    fl = soften(P((10.6, 2.8), (20.2, 2.8), (17.6, 6.4), (20.2, 10.0), (10.6, 10.0)), 0.6)
    mound = soften(P((1.8, 21.6), (8.6, 15.2), (13.2, 18.0), (16.0, 15.6), (22.2, 21.6)), 0.8)
    return S(U(pole, fl), gap(mound, pole, g=1.4))

@v("umbrella_solid")
def _():
    can = C(12, 11.6, 9.8).intersection(box(0, 0, 24, 11.6))
    for x in (4.65, 9.55, 14.45, 19.35):
        can = can.difference(C(x, 11.6, 2.45))
    can = soften(can, 0.4)
    h, b = person(12, 14.8, 2.4, 9.4, 21.6, neck=1.4)
    return S(can, U(h, b))

if __name__ == "__main__":
    import proof
    gl = {k: fn() for k, fn in V.items()}
    proof.build = lambda: gl
    proof.main([], out="rounds/variants2.html", cols=5)
