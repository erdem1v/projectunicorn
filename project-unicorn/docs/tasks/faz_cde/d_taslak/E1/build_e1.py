"""build_e1: embed the E1 data blocks into the review page.

Usage: python -I build_e1.py   (from anywhere; paths are relative to this file)
Writes e1.html next to this file. Frames are served beside the page as png/<file> (Artifact `files`).
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
D = os.path.dirname(HERE)
sys.path.insert(0, os.path.join(D, "araclar"))
import wavecheck_d  # noqa: E402

FRAMES = [
    ("a_1kisi", "1 kişi", "Tek kurucu, MVP öncesi, tek Çekirdek kartı. Çeyrek hedefi Çekirdek'te kilitli, devret kilitli; taşma olmadığı için \"her aşama yetişiyor\" cümlesi."),
    ("b_6kisi_iyi_pm", "6 kişi, iyi PM (5★)", "Üç kart, hazırlık satırı (hız +%30) ve ekip satırı; test darboğazı, öneri, Sırada, devret açık ve devret önerisi. Üçüncü kart yaklaşık 65 px kesik."),
    ("c_6kisi_zayif_pm", "6 kişi, zayıf PM (2★)", "Aynı ekip ve kartlar, PM 2★: hazırlık hız +%15, kart puanları yükselir (29'dan 33'e, 37'den 42'ye), test aşımı 9 puan. Önceki kareyle yan yana bak."),
    ("d_12kisi", "12 kişi", "PM yok, devret kilitli; tasarımcı testte ×0,4 (uymayan iş), hesap isteği kartı, derinlik kartı, çeyrek hedefi Entegrasyonlar. 6 kartın 2'si görünüyor: kişi satırı 4 satır tutuyor."),
    ("d_12kisi_ozet", "12 kişi, aşama özetiyle", "Kişi satırı yerine aşama özeti. Kazanç yalnız 9 px; yeri kurucu ve uymayan iş cümleleri tutuyor. EN'de \"1 people\" hatası var (W'de tekil biçim eksik)."),
    ("e_50kisi", "50 kişi, planlama devirde", "26 kart, 3 PM'in hazırlığı kart büyüklüğüne göre; aşama özeti; \"Planlanacak kart kalmadı: 6 kişi boşta\"; Sprinti başlat ve boş geçir gizli, yalnız Planlamayı geri al."),
    ("e_50kisi_02", "50 kişi, kaydırılmış", "Aynı liste 1.500 px aşağıda: derinlik kartının ikinci hâli \"+1 kare (bu alandaki ilk karttan az)\"."),
    ("f_ipucu", "Kart ipucu", "6 kişi, Toplu Fatura'nın ipucu: aşama işleri, kadro tavanı, aşama satırları, hazırlık ve kural. İhtiyaç satırı hazırlıktan önceki işi yazıyor (U5)."),
    ("g_ipucu_kendi", "Kendi kartını test eden", "12 kişi, hesap isteği kartının ipucu: \"Test: Ayşe 3★ ve Onur 2★ (kartı kendisi yazdı)\". Üç kadro tavanı ilk satırı iki satıra sarıyor (U6)."),
]

OLCUM = {
    "scale": {
        "sizes": [1, 3, 6, 12, 25, 50],
        "rows": [
            {"label": "Teslim, bugünkü kural", "values": ["5,1", "20,1", "48,0", "108,0", "267,5", "540,0"]},
            {"label": "Teslim, önerilen okuma", "values": ["4,5", "21,1", "49,0", "109,0", "264,0", "514,0"]},
            {"label": "Boşta kalma, önerilen", "values": ["%26,4", "%16,6", "%11,6", "%8,5", "%2,8", "%5,4"]},
            {"label": "Plan doluluğu, önerilen", "values": ["%70,1", "%99,8", "%110,9", "%116,6", "%121,1", "%123,3"]},
        ],
    },
    "gates": [
        {"no": "1", "name": "Kişi eklemek teslimi düşürmez", "r": "k", "v": "en kötü −4,0; gürültüden ayrılan eksi adım 1/182", "q": "P2"},
        {"no": "2", "name": "Kurucu büyümesi", "r": "k", "v": "kurucu işi en çok %8,1 düşüyor; 2 adımda teslim artmıyor, MVP gecikiyor", "q": "K7"},
        {"no": "3", "name": "Tek kurucuda MVP", "r": "g", "v": "6. hafta 17 tohum, 8. hafta 3 tohum", "q": ""},
        {"no": "4", "name": "Kişi başı ölçek", "r": "g", "v": "25 kişi %129, 50 kişi %126", "q": ""},
        {"no": "5", "name": "Darboğaz rolü", "r": "g", "v": "darboğaza kişi eklemek teslimi artırıyor", "q": ""},
        {"no": "6", "name": "Düzeltme payı", "r": "k", "v": "tek hücre: geç düzeltme %21,5 (sınır %20)", "q": "bilgi"},
        {"no": "7", "name": "Toplam hata işi", "r": "k", "v": "tek hücre %22,6 (sınır %20)", "q": "bilgi"},
        {"no": "8", "name": "Açık hata sınırlı", "r": "k", "v": "tek hücre eğim 0,2045 (sınır 0,2)", "q": "bilgi"},
        {"no": "9", "name": "Testçi yıldızı", "r": "k", "v": "1★→5★ kaçan −%30 (hedef −%40); testçi yalnız testte −%62", "q": "K6"},
        {"no": "10", "name": "Testçinin değeri", "r": "k", "v": "3★ testçi kaçan hatayı 12 kişide −%13, 25 kişide −%16 (hedef −%20)", "q": "K6, bilgi"},
        {"no": "11", "name": "PM yıldızı", "r": "g", "v": "teslim +%19 ile +%22, kaçan −%29 ile −%35", "q": ""},
        {"no": "12", "name": "Gönder sorusunun sıklığı", "r": "k", "v": "bağlı kipte 25 ve 50 kişide %12 ve %15 (sınır %10)", "q": "bilgi"},
        {"no": "13", "name": "Gönder politikaları", "r": "g", "v": "teslim farkı en çok %0,6", "q": ""},
        {"no": "14", "name": "Tahmin = sonuç", "r": "g", "v": "en büyük fark 1,4e-14, 9.460 koşu", "q": ""},
        {"no": "15", "name": "A'nın sınırları ölçekle", "r": "g", "v": "hiç düzeltmeyen 13 ile 23 haftada sınıra varıyor", "q": ""},
        {"no": "16", "name": "Kart arzı", "r": "g", "v": "büyüme eğrisinde %100", "q": ""},
        {"no": "17", "name": "Boşta kalmanın nedeni yazılı", "r": "g", "v": "nedensiz boşta 0", "q": ""},
        {"no": "4.3/7", "name": "50 kişide boşta en çok %15", "r": "k", "v": "en kötü hücre %17,7; büyüyen ekipte %6,4", "q": "bilgi"},
        {"no": "18", "name": "Kart kalmadı sprinti", "r": "g", "v": "%0", "q": ""},
        {"no": "19", "name": "Öneri doluluğu", "r": "g", "v": "en düşük %99,1", "q": ""},
        {"no": "20", "name": "Derinlik kazancı azalır", "r": "g", "v": "5. kart ilkinin %31,6'sı", "q": "G2"},
        {"no": "21", "name": "İstek payı", "r": "g", "v": "raporlandı, yalnız 3★ ve üstü hesap", "q": ""},
        {"no": "22", "name": "EA takımı", "r": "o", "v": "EA ertelendi", "q": ""},
        {"no": "23", "name": "Uymayan işin morali", "r": "k", "v": "koşullu −28, koşulsuz −98 (bant 60 ile 90)", "q": "P1"},
        {"no": "N1", "name": "PM eklemek düşürmez", "r": "k", "v": "önerilen okumada −0,32 ± 0,27 (fark yok)", "q": "K2, P2"},
        {"no": "N2", "name": "Atama sırası", "r": "g", "v": "628.317 satırda ters 0; aynı girdi aynı atama", "q": ""},
        {"no": "N3", "name": "Kendi kartı ×0,6", "r": "g", "v": "kurucu dahil", "q": ""},
        {"no": "N4", "name": "Erken kapanan sprint yok", "r": "g", "v": "0", "q": ""},
        {"no": "N5", "name": "Plan anında doluluk", "r": "k", "v": "yalnız tek kurucu, sınırsız arzda %70,1 (gerçek arzda %91,9)", "q": "bilgi"},
    ],
}


def block(name, obj):
    data = json.dumps(obj, ensure_ascii=False).replace("</", "<\\u002f")
    return f'<script type="application/json" id="{name}">{data}</script>'


def main():
    e1 = json.load(open(os.path.join(HERE, "e1_kararlar.json"), encoding="utf-8"))
    w = json.load(open(os.path.join(D, "W", "W_METINLER.json"), encoding="utf-8"))
    _, errs, warns = wavecheck_d.check(w)
    w["check_line"] = f"Mekanik denetim: {errs} hata, {warns} uyarı (tire, iki dil, aynı belirteçler, sözlük)."
    png = os.path.join(D, "M", "png")
    frames = []
    for key, title, caption in FRAMES:
        tr, en = f"m_{key}.png", f"m_{key}_en.png"
        assert os.path.exists(os.path.join(png, tr)) and os.path.exists(os.path.join(png, en)), key
        frames.append({"key": key, "title": title, "caption": caption, "tr": tr, "en": en})
    ids = [d["id"] for d in e1["decisions"]]
    assert len(ids) == len(set(ids)), "duplicate decision id"
    tpl = open(os.path.join(HERE, "e1_sablon.html"), encoding="utf-8").read()
    blocks = "\n".join([block("d-e1", e1), block("d-w", w), block("d-frames", frames), block("d-olcum", OLCUM)])
    html = tpl.replace("<!--DATA-->", blocks)
    out = os.path.join(HERE, "e1.html")
    open(out, "w", encoding="utf-8").write(html)
    print(f"BUILD {out} decisions={len(ids)} items={len(w['items'])} frames={len(frames)} check={errs}/{warns} bytes={len(html.encode('utf-8'))}")


if __name__ == "__main__":
    main()
