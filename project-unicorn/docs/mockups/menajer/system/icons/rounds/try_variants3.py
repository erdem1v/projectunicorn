import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from kit import *
from glyphs import S
V = {}
def v(k):
    def d(fn): V[k] = fn; return fn
    return d

@v("now")
def _():
    front = cut(R(2.0, 9.4, 17.6, 11.0, 1.6), C(10.8, 14.9, 2.7))
    back = R(6.0, 4.6, 16.0, 11.0, 1.6)
    return S(front, gap(back, front))

@v("note_L")
def _():
    front = cut(R(2.0, 9.4, 16.0, 11.0, 1.6), C(10.0, 14.9, 2.6))
    back = R(6.0, 4.4, 16.0, 11.0, 1.6)
    return S(front, gap(back, front))

@v("note_L_dots")
def _():
    front = R(2.0, 9.4, 16.0, 11.0, 1.6)
    front = cut(front, C(10.0, 14.9, 2.6), C(5.4, 12.6, 1.1), C(14.6, 17.2, 1.1))
    back = R(6.0, 4.4, 16.0, 11.0, 1.6)
    return S(front, gap(back, front))

@v("note_3")
def _():
    front = cut(R(2.0, 11.0, 15.4, 10.4, 1.6), C(9.7, 16.2, 2.4))
    mid = R(4.6, 7.6, 15.4, 10.4, 1.6)
    back = R(7.2, 2.6, 14.6, 9.0, 1.4)
    return S(front, U(gap(mid, front), gap(gap(back, mid), front)))

@v("note_band")
def _():
    # a bundle of notes with a paper band around it
    b = R(2.0, 6.6, 20.0, 11.6, 1.6)
    b = ko(b, [(9.2, 0), (9.2, 24)], [(14.8, 0), (14.8, 24)], cap="flat")
    band, rest = pick(b, 12, 12)
    return S(band, rest)

@v("coin_dollar")
def _():
    d = C(12, 12, 9.8)
    s = LineString([(15.0, 8.8), (13.6, 7.6), (10.6, 7.6), (9.0, 9.0), (9.0, 10.6), (10.6, 12.0), (13.4, 12.0), (15.0, 13.4), (15.0, 15.0), (13.4, 16.4), (10.4, 16.4), (9.0, 15.2)])
    s = s.buffer(1.0, quad_segs=Q, cap_style="round", join_style="round")
    bar = L((12, 5.0), (12, 19.0), w=1.8)
    return S(cut(d, s, bar))

if __name__ == "__main__":
    import proof
    gl = {k: fn() for k, fn in V.items()}
    proof.build = lambda: gl
    proof.main([], out="rounds/variants3.html", cols=6)
