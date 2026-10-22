"""SIM3 kapı tablosu için sayıları sim3_<ad>.json'dan çıkarır (yalnız okuma). Kullanım: python -I sim3_tablo.py <ad>"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")


def pc(x, d=0):
    return "-" if x is None else f"%{x * 100:.{d}f}"


def main(ad):
    d = json.load(open(os.path.join(HERE, f"sim3_{ad}.json"), encoding="utf-8"))
    print(f"##### {ad} · ayar {d['ayar']} · süre {d['sure_sn']:.0f} sn · tohum {d['tohum']} · G8 ihlal {len(d['g8'])}")
    for N in ("5", "7", "10"):
        g = d["g1"][N]
        for e in ("2030", "2035"):
            r, yy = g[e], g["yillar"]
            dev = max(yy[str(y)]["dev_pay"] for y in range(2015, int(e) + 1))
            print(f"G1 N={N} {e}: {'OK' if r['ok'] else 'FAIL'} düşen-yıl {r['fail_years']} dev>%60 {r['dev_fail_years']} · dev en çok {pc(dev)} (yıl "
                  f"{max(range(2015, int(e) + 1), key=lambda y: yy[str(y)]['dev_pay'])}) · S artış/yıl {r['S_yillik_artis']:.2f} · son fark {r['son_fark']}")
    for e in ("2030", "2035"):
        r = d["g6"][f"10|{e}"]
        ok = r["ok"]
        c5 = [(c["bot"], c["takim"], round(c["tutma"][4], 3), round(c["hesap_yil"][4])) for c in r["hucre"]]
        print(f"G6 10|{e}: koltuk {pc(r['koltuk'][0])}-{pc(r['koltuk'][1])} {ok['koltuk']} · yıldız {pc(r['yildiz'], 1)} {ok['yildiz']} · 1★ büy {pc(r['bir_buyume'], 1)} {ok['bir_buyume']} · "
              f"1★ tutma {pc(r['tutma1'][0], 1)}-{pc(r['tutma1'][1], 1)} {ok['tutma1']} · 5★ tutma {pc(r['tutma5'][0], 1)}-{pc(r['tutma5'][1], 1)} ({r['tutma5_hucre']}) {ok['tutma5']}")
        if e == "2030":
            print("  5★ tutma hücreleri:", c5)
            in_band = sum(1 for c in r["hucre"] if c["hesap_yil"][4] >= 20 and 0.9 <= c["tutma"][4] <= 0.97)
            print("  5★ bantta hücre:", in_band, "/", sum(1 for c in r["hucre"] if c["hesap_yil"][4] >= 20))
    for e in ("2030", "2035"):
        g7 = d["g7"][f"10|{e}"]
        st = g7["yildiz"]
        print(f"G7 10|{e}: 1★ {pc(st[0]['esles_tam'], 1)} (n {st[0]['esles_tam_n']}) · 5★ {pc(st[4]['esles_tam'], 1)} (n {st[4]['esles_tam_n']}) · oranlar "
              f"{[round(x['oran'], 2) if x['oran'] is not None else None for x in st]} · pmax {g7['p_en_cok']:.2f} · bayat {pc(g7['bayat'], 2)} (en kötü {pc(g7['bayat_en_kotu'], 1)}) · kapı {g7['ok']['hepsi']}")
    for tm in ("buyuyen", "25", "50"):
        c = d["g4"].get(f"10|durgun|{tm}")
        if c:
            print(f"G4 durgun {tm}: kayıp {pc(c['kayip_mrr_med'])} ({pc(c['kayip_mrr_min'])}-{pc(c['kayip_mrr_max'])}) · adlı {pc(c['adli_pay'])} (ud hariç {pc(c.get('adli_pay_urun_disi_haric'))}) · 1★ kayıp {pc(c['bir_yildiz_kayip'])} · kanal {c['kanal']} · yeni imza {c['yeni_imza_med']} · ilgi {c['ilgi_med']:.2f}")
    print("G4 kapı:", d["g4_kapi"]["10"])
    for e in ("2030", "2035"):
        for tm in ("buyuyen",):
            g = d["g2"].get(f"10|{e}|{tm}|A")
            if g:
                c = g["guclu"]
                print(f"G2 10|{e}|{tm}: erken {pc(c['erken_lider'])} · geç gölge son {pc(c['gec_golge_son'])} (herhangi {pc(c['gec_golge_herhangi'])}) · ürün önde {pc(c['gec_urun_son'])} · "
                      f"oyuncu/dev gölge {pc(c['son_golge_med'])}/{pc(c['son_golge_dev_med'])}  bot: " +
                      "; ".join(f"{b} {pc(x['gec_golge_son'])}" for b, x in g["bot"].items()))
    for N in ("5", "7"):
        for e in ("2030", "2035"):
            g = d["g2"].get(f"{N}|{e}|buyuyen|A")
            if g:
                c = g["guclu"]
                print(f"G2 {N}|{e}: erken {pc(c['erken_lider'])} geç gölge son {pc(c['gec_golge_son'])} ürün önde {pc(c['gec_urun_son'])}")
    for e in ("2030", "2035"):
        r = d["g5_kapi"][f"10|{e}"]
        print(f"G5 10|{e}: mail med {r['mail_med']} p99 {r['mail_p99']} {r['ok_mail']} · kart p95 {r['kart_p95']} (en kötü {r['kart_p95_enkotu']}) {r['ok_kart']} · şartlı {pc(r['sartli_min'], 1)}-{pc(r['sartli_max'], 1)} {r['ok_sartli']}")
    for r in d["g10"]:
        print("G10", r["kol"][:40], r["olcu"], pc(r["sapma"]), r["ok"])
    print("Demo (4★/5★ payı, N=10):")
    for bot in ("odakli", "verimli", "satici"):
        print("  ", bot, {tm: (pc(d["demo"][f"10|{bot}|{tm}"]["4"]), pc(d["demo"][f"10|{bot}|{tm}"]["5"])) for tm in ("buyuyen", "1", "3", "6", "12", "25", "50") if f"10|{bot}|{tm}" in d["demo"]})
    if "tempo" in d:
        print("Tempo N=10:")
        for bot in ("odakli", "verimli", "satici", "daginik"):
            for tm in ("1", "3", "6", "buyuyen"):
                t = d["tempo"].get(f"10|{bot}|{tm}")
                if t:
                    print(f"   {bot} {tm}: K1 {t['k1'][0]} K2 {t['k2'][0]} K3 {t['k3'][0]} · 52: {t['a52']} · 104: {t['a104']} · puan104 {t['puan104']:.0f} kapasite {t['k3_kapasite']:.1f}")
    for e in ("2030",):
        for N in ("5", "7", "10"):
            for bot in ("oncu", "odakli"):
                for tm in ("buyuyen", "50"):
                    g = d["g3"].get(f"{N}|{e}|{bot}|{tm}")
                    if g:
                        print(f"G3 {N}|{e}|{bot}|{tm}: hepsi {g['ilk']}/{g['acik']} eşit {g['esit']} pay {pc(g['pay'])} dev {pc(g['dev_pay'])} · teknoloji {g['ilk_tek']}/{g['acik_tek']} pay {pc(g['pay_tek'])} dev {pc(g['dev_pay_tek'])}")
    for bot in ("durgun", "daginik", "odakli"):
        for tm in ("1", "25", "buyuyen", "50"):
            g = d["g9"].get(f"10|2030|{bot}|{tm}")
            if g:
                y = g["yil"]
                print(f"G9 {bot} {tm}: en düşük yıl {g['min']} · kazanılabilir 2016-2030 (2 yılda bir) {[int(y[str(k)][1]) for k in range(2016, 2031, 2)]}")
    print("Fiyat kolları (ilk-bot medyanı MRR 2030, A/A+h/B/B+h/C):")
    for bot in ("odakli", "verimli", "oncu", "satici", "daginik"):
        c = d["fiyat"].get(f"10|{bot}|buyuyen|330|2030")
        if c:
            print("  ", bot, [round(v) for v in c["mrr_son"]], "5★ (n)", c["bes_n"], "seed-aşan", [pc(v) for v in c["bes_seed_ustu_pay"]])
    sr = d["siralama"]
    for bot in ("odakli", "oncu", "verimli", "daginik", "durgun"):
        c = sr.get(f"10|2030|{bot}")
        if c:
            print(f"Sıralama {bot}: modül top3 {pc(c['mod_top3'])} ödül {pc(c['mod_odul'])} · sektör top3 {pc(c['prof_top3'])} · yükselen {pc(c['yuk_top3'])} · en büyük gölge {c['kul_sira_golge']}")


if __name__ == "__main__":
    main(sys.argv[1])
