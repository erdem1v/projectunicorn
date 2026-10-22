exec(open("an_common.py", encoding="utf-8").read())
G = L("G"); P = L("P_p19_skip12")
print("oneri doluluğu: taban -> atlayarak doldurma (12 aday)")
for b in ("S1","S2","S3","S4","S5","S6"):
    for sw in (1, 2):
        n = "A|%s|kaynakli|%d" % (b, sw)
        print("%-18s doluluk %.3f -> %.3f | teslim %6.1f -> %6.1f | bosta %.3f -> %.3f | kart/sprint %.1f -> %.1f | asked %.2f -> %.2f | kacan/100 %.2f -> %.2f | ac hata %.1f -> %.1f | duz.payi %.3f -> %.3f | hata spr %s -> %s" % (
            n, md(G, n, "fill_ratio"), md(P, n, "fill_ratio"), md(G, n, "deliv"), md(P, n, "deliv"), md(G, n, "idle_pct"), md(P, n, "idle_pct"), md(G, n, "wip"), md(P, n, "wip"), md(G, n, "asked"), md(P, n, "asked"),
            md(G, n, "esc100"), md(P, n, "esc100"), md(G, n, "open_med"), md(P, n, "open_med"), md(G, n, "fix_late"), md(P, n, "fix_late"), hs(G, n), hs(P, n)))
print("pred max", max(m["pred"] for n in P for m in P[n].values()))
Q = L("P_p11")
print("PM yildizi: 25 kisi 3 PM, 24 kisi 2 PM")
for pre in ("PM6", "PM7"):
    d1, d5 = md(Q, pre + "_1", "deliv"), md(Q, pre + "_5", "deliv")
    e1, e5 = md(Q, pre + "_1", "esc_card"), md(Q, pre + "_5", "esc_card")
    print(pre, "teslim %.1f -> %.1f (%+.1f%%)  kacan/kart %.3f -> %.3f (%+.1f%%)  hazir %.2f -> %.2f" % (d1, d5, 100*(d5/d1-1), e1, e5, 100*(e5/e1-1), md(Q, pre+"_1", "ready"), md(Q, pre+"_5", "ready")))
