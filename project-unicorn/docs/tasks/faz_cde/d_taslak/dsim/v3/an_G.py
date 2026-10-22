exec(open("an_common.py", encoding="utf-8").read())
G = L("G")
print("A| arz kipleri (20-60 hf pencere): teslim, bosta%, bosta nedenleri(kart_yok,asama,rol,hazirlik), pool_ok, nocard, fill, kart/sprint(ncards), yeni/sprint, stops")
for b in ("S1","S2","S3","S4","S5","S6"):
    for arz in ("sonlu","kaynakli"):
        for sw in (1,2):
            n = "A|%s|%s|%d" % (b, arz, sw)
            why = [md(G, n, "why", None) if False else statistics.median([m["why"][k] for m in G[n].values()]) for k in ("kart_yok","asama_dolu","rol_uymuyor","hazirlik_yok")]
            print("%-22s" % n, "teslim %6.1f idle %.2f why %s pool_ok %s nocard %.2f fill %s wip %.1f new %.1f mvp %s req(%s)" % (
                md(G,n,"deliv"), md(G,n,"idle_pct"), ["%.2f"%x for x in why], md(G,n,"pool_ok"), md(G,n,"nocard"), md(G,n,"fill_ratio"), md(G,n,"wip"), md(G,n,"new_sp"), md(G,n,"mvp"),
                ",".join("%d"%md(G,n,"req",i) for i in range(7))))
for n in ("GC|sonlu","GC|kaynakli"):
    print(n, "n_end %s teslim(21-130) %.1f idle %.3f pool_ok %s nocard %.3f fill %s req %s pts_src %s" % (md(G,n,"n"), md(G,n,"deliv"), md(G,n,"idle_pct"), md(G,n,"pool_ok"), md(G,n,"nocard"), md(G,n,"fill_ratio"),
          [md(G,n,"req",i) for i in range(7)], [md(G,n,"pts_src",i) for i in range(3)]))
