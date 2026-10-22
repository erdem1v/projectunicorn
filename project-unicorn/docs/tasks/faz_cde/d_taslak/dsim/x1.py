exec(open("analyze.py",encoding="utf-8").read())
def row(n):
    a=A[n]
    return "%-26s n=%2d teslim %6.1f [%5.1f-%5.1f] kisi %5.2f kart/spr %5.2f esc %.2f acik %5.1f dz_gec %s dz_erk %s bsL %s bsE %s ard %d bosta %.1f dar %s hazir %s mvp %s (%s-%s) slope %s pred %.1e cv %d" % (n,a["n"],a["deliv"],a["deliv_min"],a["deliv_max"],a["per_person"],a["cards_sprint"],a["esc_card"],a["open_med"],pc(a["fix_late"]),pc(a["fix_early"]),ratio(a["bs_late"]),ratio(a["bs_early"]),a["consec"],a["idle_w"],a["bott"],pc(a["ready"]),f(a["mvp"],0),a["mvp_min"],a["mvp_max"],f(a["slope"],2),a["pred"],a["cviol"])
for n in R:
    if not n.startswith("C") and not n.startswith("M|") and not n.startswith("T") and " +" not in n: print(row(n))
