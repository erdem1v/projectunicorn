"""SIM3 sonuç okuyucu: sim3_*.json dosyalarından kapı özetini basar (yalnız okuma). Kullanım:
python -I sim3_oku.py <ad> [<ad> ...]   (ad = sim3_<ad>.json)
Bağımsız yeniden türetme için hücre ölçüleri JSON'daki ham hücre listelerinden hesaplanır."""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")


def pc(x, d=0):
    return "-" if x is None else f"%{x * 100:.{d}f}"


def load(ad):
    with open(os.path.join(HERE, f"sim3_{ad}.json"), encoding="utf-8") as f:
        return json.load(f)


def g4(d, N="10", end="2030"):
    out = []
    for tm in ("buyuyen", "25", "50"):
        c = d["g4"].get(f"{N}|durgun|{tm}")
        if c:
            out.append(f"{tm}: kayıp {pc(c['kayip_mrr_med'])} (adlı {pc(c['adli_pay'])}, ud hariç {pc(c.get('adli_pay_urun_disi_haric'))}, 1★ {pc(c['bir_yildiz_kayip'])})")
    return " | ".join(out)


def g6(d, N="10", end="2030"):
    r = d["g6"].get(f"{N}|{end}")
    if not r:
        return "-"
    ok = r["ok"]
    return (f"koltuk {pc(r['koltuk'][0])}-{pc(r['koltuk'][1])} {ok['koltuk']} · yıldız {pc(r['yildiz'], 1)} · 1★ büy {pc(r['bir_buyume'], 1)} · "
            f"1★ tutma {pc(r['tutma1'][0], 1)}-{pc(r['tutma1'][1], 1)} {ok['tutma1']} · 5★ tutma {pc(r['tutma5'][0], 1)}-{pc(r['tutma5'][1], 1)} "
            f"({r['tutma5_hucre']} hücre) {ok['tutma5']}")


def g2(d, N="10", end="2030"):
    out = []
    for tm in ("buyuyen", "50"):
        g = d["g2"].get(f"{N}|{end}|{tm}|A")
        if g:
            c = g["guclu"]
            out.append(f"{tm}: erken {pc(c['erken_lider'])} · geç gölge son {pc(c['gec_golge_son'])} (herhangi {pc(c['gec_golge_herhangi'])}) · "
                       f"ürün önde {pc(c['gec_urun_son'])} · gölge oyuncu/dev {pc(c['son_golge_med'])}/{pc(c['son_golge_dev_med'])}")
    return " || ".join(out)


def g5(d, N="10", end="2030"):
    r = d["g5_kapi"].get(f"{N}|{end}")
    if not r:
        return "-"
    return (f"mail med {r['mail_med']:.1f} p99 {r['mail_p99']} {r['ok_mail']} · kart p95 {r['kart_p95']} (en kötü {r['kart_p95_enkotu']}) {r['ok_kart']} · "
            f"şartlı {pc(r['sartli_min'], 1)}-{pc(r['sartli_max'], 1)} {r['ok_sartli']}")


def g1(d, N, end="2030"):
    g = d["g1"].get(str(N))
    if not g:
        return "-"
    r = g[end]
    y = g["yillar"][end]
    yy = g["yillar"]
    fe = [k for k in sorted(yy) if int(k) >= 2015 and int(k) <= int(end)]
    return (f"{'✅' if r['ok'] else '❌'} fark-düşen yıl {r['fail_years']} dev>%60 yıl {r['dev_fail_years']} · S artış/yıl {r['S_yillik_artis']:.2f} · "
            f"son yıl tavana kalan {r['son_fark']:.1f} (etkin {y.get('fark_etkin')}) · dev tavanda son {pc(r['son_dev_pay'])}")


def show(ad):
    d = load(ad)
    print(f"=== {ad}  ayar={d['ayar']}")
    for N in ("5", "7", "10"):
        if N in d["g1"]:
            print(f"G1 N={N}: {g1(d, N)}")
    print("G4:", g4(d))
    print("G6:", g6(d))
    print("G2:", g2(d))
    print("G5:", g5(d))
    print("G8:", len(d["g8"]))


if __name__ == "__main__":
    for a in sys.argv[1:]:
        show(a)
