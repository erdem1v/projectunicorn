# M2 karar sayfasını kurar: m2_sablon.html + m2_sorular.json -> m2.html. Kareler ../M/png/ altında, sayfa onları png/ yoluyla okur.
# Koşu: python -I build_m2.py
import json
import pathlib

HERE = pathlib.Path(__file__).resolve().parent
PNG = HERE.parent / "M" / "png"

FRAMES = [
    {"keys": ["a_3kisi_erdem_ornegi"], "cap": "Senin örneğin: 3 geliştirici. Deniz 4★ ve Mert 3★ büyük kartta iki sprint çalışıyor; Kaan 3★ iki küçük kartı ilk sprintte birer haftada bitiriyor. Alttaki satırlar kimin hangi kartın hangi aşamasında kaldığını ve ne zaman çıkacağını yazıyor."},
    {"keys": ["b_6kisi_tasma_yok"], "cap": "6 kişi, plan sprinte sığıyor: darboğaz satırı boş. Çeyrek hedefi seçilmemiş, başlık \"Bu çeyrek: hedef yok\" yazıyor."},
    {"keys": ["b_12kisi_tasma_ilk", "b_12kisi_tasma_sayac"], "tags": ["Taşmanın ilk sprinti", "Aynı sorun üçüncü sprintte"], "cap": "12 kişi, test yetişmiyor. Darboğaz satırı yalnız iş sprinte sığmayınca yazıyor ve testte kalan kartları adıyla sayıyor; sorun sürünce \"Bu sorun 3 sprinttir sürüyor.\" ekleniyor."},
    {"keys": ["c_12kisi_iki_pm_kural_a"], "cap": "İki ürün yöneticisi: karmaşık kartları Selin 4★, basit kartı Can 2★ hazırlıyor; hız farkı kart yüzünde okunuyor."},
    {"keys": ["b_6kisi_iyi_pm", "c_6kisi_zayif_pm"], "tags": ["Ürün yöneticisi 5★", "Ürün yöneticisi 2★"], "cap": "Aynı ekip, aynı kartlar; yalnız ürün yöneticisinin yıldızı farklı. Kart puanları ve test yükü yan yana."},
    {"keys": ["f_12kisi_uymayan_is"], "cap": "Kendi işi olmayan iş: tasarımcı Defne testte 0,4 hızla çalışıyor; kartta etiket, altta adıyla uyarı satırı."},
    {"keys": ["g_ipucu_kendi"], "cap": "Kart ipucu: işin büyüklüğü, istenen yıldız ve en çok kaç kişi; kartı kendisi yazıp test eden kişi; atama kuralı."},
    {"keys": ["d_1kisi_tek_kurucu", "e_50kisi_devirde"], "tags": ["1 kişi", "50 kişi"], "cap": "Ölçeğin iki ucu. Tek kurucuda darboğaz satırı yok ve devret kilitli, nedeni yazılı. 50 kişide planlama ürün yöneticisinde, kartlar tek satır, altta aşama özeti; kart kalmayınca \"Planlanacak kart kalmadı\" yazıyor."},
]


def main() -> None:
    data = json.loads((HERE / "m2_sorular.json").read_text(encoding="utf-8"))
    keys = [k for g in FRAMES for k in g["keys"]]
    for q in data["sorular"]:
        keys += q.get("kareler", [])
    missing = [k for k in keys for lang in ("", "_en") if not (PNG / f"m_{k}{lang}.png").exists()]
    if missing:
        raise SystemExit("eksik kare: " + ", ".join(missing))
    for g in FRAMES:
        g.setdefault("tags", [None] * len(g["keys"]))
    html = (HERE / "m2_sablon.html").read_text(encoding="utf-8")
    payload = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    html = html.replace("__DATA__", payload).replace("__FRAMES__", json.dumps(FRAMES, ensure_ascii=False))
    if "—" in html or "–" in html:
        raise SystemExit("sayfada tire var")
    (HERE / "m2.html").write_text(html, encoding="utf-8", newline="\n")
    files = {f"png/m_{k}{lang}.png": str(PNG / f"m_{k}{lang}.png") for k in dict.fromkeys(keys) for lang in ("", "_en")}
    (HERE / "m2_files.json").write_text(json.dumps(files, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"m2.html {len(html)} bayt, {len(files)} kare")


if __name__ == "__main__":
    main()
