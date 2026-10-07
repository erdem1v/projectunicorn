import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from kit import *
import glyphs as Gm
from glyphs import person, S, bubble
V = {}
def v(k):
    def d(fn): V[k] = fn; return fn
    return d

@v("wing_arch")
def _():
    arch = C(12.4, 15.6, 10.2).intersection(box(0, 0, 24, 15.6)).difference(C(12.4, 15.6, 6.4))
    # feather fingers on the right end, scallops on the inner edge
    for a in (300, 330):
        arch = arch.difference(L((12.4 + 6.0*math.cos(math.radians(a)), 15.6 + 6.0*math.sin(math.radians(a))),
                                 (12.4 + 9.0*math.cos(math.radians(a)), 15.6 + 9.0*math.sin(math.radians(a))), w=1.6))
    shoulder = C(4.0, 14.6, 2.4)
    h, b = person(12.4, 15.4, 2.6, 9.0, 21.6, neck=1.6)
    return S(U(arch), U(h, b))

@v("wing_side")
def _():
    f1 = hull(C(4.6, 5.0, 2.6), C(19.6, 3.6, 1.4))
    f2 = hull(C(4.6, 8.0, 2.4), C(21.0, 8.2, 1.2))
    f3 = hull(C(4.6, 10.8, 2.0), C(20.4, 12.6, 1.0))
    wing = U(f1, gap(f2, f1, g=1.2), gap(f3, f2, g=1.2), C(4.4, 7.8, 3.4))
    h, b = person(13.4, 15.6, 2.4, 9.0, 21.6, neck=1.4)
    return S(wing, U(h, b))

@v("umbrella")
def _():
    can = C(12, 11.4, 9.6).intersection(box(0, 0, 24, 11.4))
    for x in (4.8, 9.6, 14.4, 19.2):
        can = can.difference(C(x, 11.4, 2.4))
    can = soften(can, 0.4)
    h, b = person(12, 14.6, 2.4, 9.0, 21.6, neck=1.4)
    return S(can, U(h, b))

@v("mentor")
def _():
    bh, bb = person(9.0, 6.6, 3.8, 14.0, 21.6)
    sh, sb = person(17.0, 13.0, 2.4, 8.4, 21.6, neck=1.4)
    big = gap(U(bh, bb), sh, sb)
    return S(big, U(sh, sb))

@v("cant_bubble_stack")
def _():
    b = bubble(4.4, 2.2, 15.2, 9.4, [(7.0, 11.0), (6.0, 13.6), (11.4, 11.0)])
    b = ko(b, [(8.2, 6.8), (10.6, 9.0), (15.4, 4.4)])
    papers = U(R(5.2, 15.6, 15.6, 2.4, 1.0), R(3.2, 19.6, 15.6, 2.4, 1.0))
    return S(U(b, papers))

@v("cant_bubbles")
def _():
    # three overlapping yes-bubbles: a pile of promises
    b1 = bubble(2.4, 9.6, 12.0, 8.4, [(4.8, 17.0), (4.4, 21.0), (9.2, 17.0)])
    b1 = ko(b1, [(5.4, 13.8), (7.4, 15.6), (11.4, 11.8)])
    b2 = bubble(7.2, 5.6, 12.4, 8.4, [(16.6, 13.0), (19.2, 16.2), (18.8, 13.0)])
    b3 = bubble(10.8, 2.0, 11.0, 7.2, [(20.0, 8.0), (21.6, 10.4), (21.4, 8.0)])
    return S(b1, gap(U(gap(b2, b3), b3), b1))

@v("fin_stack_coin")
def _():
    coin = C(15.4, 15.0, 6.4)
    face = cut(coin, ring(15.4, 15.0, 3.9, w=1.8))
    slabs = U(*[R(x, y, 10.4, 3.0, 1.5) for x, y in ((2.6, 18.4), (3.4, 13.4), (2.4, 8.4), (3.2, 3.4))])
    return S(U(face, gap(slabs, coin)))

@v("fin_coins_front")
def _():
    c1 = C(9.0, 13.6, 6.6)
    c2 = C(15.4, 9.2, 6.0)
    f1 = cut(c1, ring(9.0, 13.6, 4.0, w=1.8))
    back = gap(cut(c2, ring(15.4, 9.2, 3.5, w=1.8)), c1)
    return S(f1, back)

@v("fin_note")
def _():
    n = R(2.0, 6.0, 20.0, 12.0, 1.6)
    n = cut(n, C(12, 12, 3.0))
    n = cut(n, ring(12, 12, 6.6, w=0.01).buffer(0) if False else C(0,0,0.01))
    n = cut(n, U(C(5.2, 9.2, 1.0), C(18.8, 14.8, 1.0)))
    return S(n)

@v("fin_stack_note")
def _():
    n1 = R(2.2, 9.0, 19.6, 11.4, 1.6)
    n1 = cut(n1, C(12, 14.7, 2.8))
    back = R(4.2, 4.6, 15.6, 2.4, 1.2)
    return S(n1, back)

@v("milestone2")
def _():
    stone = soften(U(C(12, 8.6, 5.6), R(6.4, 8.6, 11.2, 11.2, 0)), 0.6)
    cap, body = pick(ko(stone, [(0, 9.6), (24, 9.6)], cap="flat"), 12, 5)
    body = ko(body, [(9.8, 15.0), (14.2, 15.0)])
    ground = R(2.4, 19.8, 19.2, 2.0, 1.0)
    return S(U(cap, body), ground)

if __name__ == "__main__":
    import proof
    gl = {k: fn() for k, fn in V.items()}
    proof.build = lambda: gl
    proof.main([], out="rounds/variants.html", cols=6)
