import json, os
from PIL import Image
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.join(HERE, "project")
UP = os.path.join(HERE, "up")
os.makedirs(ROOT, exist_ok=True)
BLOB = {
 "01":"5b35590ab84e790f49d131df900869dc","02":"10adab664a9dd741af5fbd7792a4b26d","03":"91ac994af009e685986f1537fb38bacb",
 "04":"db2aab152c68374046f36b9a5d27cfe6","05":"8a0150530a120930e6c9115d5067c1e7","06":"84237e9fd32efa0050e11e28c4a9132c",
 "07":"688078d2a8661a3556c59ab5cae0812f","08":"446f16788fd4f6984a071c142591f7a8","09":"db022809041d6d8b0fbc523bcea6cbbc",
 "10":"f025ad05f9cd4d9884cd4d29784e1ca6","11":"2e35bc9ce712e7d36dc74454995c8702","12":"f31905bfaa909d87d11e47c64b0e2b28",
 "13":"614d3cd682aca9d8fb1b39307d1384e9","14":"1ec2c412af317135e3a37d26d32d8f21","15":"d0bd9458f38b7ee97a2d754773fa4084",
 "16":"37fad7ab9deea513aabfe9d280f66cac","17":"da762d4373d890555701836846ca3384","18":"38dcdacb901d05b874f4fc7d758a794f",
 "19":"2282d6968dbb7572ddca8345b6883f6e","20":"e0d6634ead025f2d3e437b8adede906f","21":"defd3762f368f68b8e5d5b655d8acd92",
 "22":"66817e5eb55dfecb87cd078e427cc96f","23":"64db4e7b552ed75023128f659cecfc61","24":"3d43aa8443c6cea63ec0d1ddd4f12b50",
 "25":"9556323321e4cd4a4bc5413bb1548fb5","26":"35ecd795876cc6c4bbda478786739f32","27":"23b96229426deb10142152f318e04c35",
 "28":"a7c1db706b15f5bb067b9573f79fde12","29":"c2ad5b15f5b10dddb1e82adad11eab0a","30":"d7a8f3b893555ed83c459781f31bec6b",
 "31":"b7e109c1abc404ce85dd18176508ca69",
}
TITLES = {
 "01":"Frank adayları A, B, C, D","02":"Frank adayları okuma bölmesinde","03":"Kurucular: yağlı boya ve render",
 "04":"Ekran: Ekip, 1920","05":"Renk","06":"Yazı","07":"Kontroller ve durumlar","08":"Veri bileşenleri","09":"Gelen kutusu",
 "10":"Karar parçaları","11":"Kabuk","12":"Renk körü paleti","13":"Yerleşim","14":"Grafik ve ilerleme","15":"Ürün, Ar-Ge, Satış parçaları",
 "16":"Toplantı ve açılış","17":"Diyalog, tablo, metin","18":"İngilizce genişlik: kabuk ve kutu","19":"İngilizce genişlik: Ekip",
 "20":"Ekran: Ekip, 1536 (ölçek 1.25)","21":"Ekran: harita ve ofis katmanı","22":"Okunurluk 1280×720, %100","23":"Okunurluk 1280×720, %125",
 "24":"İkon 1: dil ve ray","25":"İkon 2: beceri ve bölüm","26":"İkon 3: huy","27":"İkon 4: ürün ve bedel","28":"İkon 5: yardımcı",
 "29":"İkon 6: dünya, yer, köken","30":"İkon 7: ofis kafa ikonları","31":"İkon 8: Godot doğrulaması",
}
files = {k: [f for f in os.listdir(UP) if f.startswith(k + "_")][0] for k in BLOB}
size = {k: Image.open(os.path.join(UP, f)).size for k, f in files.items()}
PAGES = [("portre", "Portreler", [["01", "02"], ["03"]]),
         ("sistem", "Tasarım sistemi", [["04", "05", "06"], ["07", "08", "09"], ["10", "11", "12"], ["13", "14", "15"], ["16", "17", "18"], ["19", "20", "21"], ["22", "23"]]),
         ("ikon", "İkonlar", [["24", "25", "26", "27"], ["28", "29", "30", "31"]])]
HEAD = {"portre": "Frank adayları ve kurucu portreleri", "sistem": "Menajer Masası tasarım sistemi", "ikon": "İkon ailesi"}
STICKY = {
"portre": """Frank ve kurucular

1. Frank için bir aday seç: A, B, C ya da D.
A: gri sakal, gri takım, bordo kravat. Başı ve saçı kadrodaki bir çalışanla ve bir VC analistiyle aynı; seçilirse onlarınki değişir.
B: gözlük, lacivert takım; koyu zeminde eriyor.
C: bıyık, kahverengi takım, yeşil kravat.
D: gözlük, adaçayı takım, kravatsız; sayfalarda yer tutucu olarak duruyor.
İstersen adaylardan parça birleştir (saç, sakal, takım rengi).

2. Kurucular: 11 yağlı boyanın yerine kendi 3B görünüşlerinden portre. Bilinen kusurlar: açık ten soluk çıkıyor (04, 05, 10), saç tepesi kesik, gözlük kalın; ışık ve kadraj Faz C'de düzelir. Asıl soru: düşük poligon yüzler bu boyda yeterli mi, yoksa portre için özel ışık ya da yakın kadraj mı istersin?""",
"sistem": """Karar bekleyen sorular (görselin üstüne yorum bırakabilir ya da numarayla cevap verebilirsin)

4. Üst barda saat yuvası hep dolu: karar yoksa "Sıradaki" yazar. Öncelik: karar, kepenk, teklif, sprint kararı, görüşme, mesai bitimi. (Kabuk)
5. Çok seçenekli kararda hiçbir seçenek amber değil: oyuncu bir seçeneği açar, sonra tek amber "Seç". Tek açık seçenek doğrudan birincil olur (Frank'in teklifi gibi). (Karar parçaları)
6. Seçenekler için sayı kısayolu yok; 1-4 hız tuşu olarak kalır.
7. Kâğıt olan her şeyin (karar, kağıt, rapor, toast) sağ üst köşesi pahlı; bitenlere damga basılır (Cevaplandı, Bitti, Ayrıldı). Sistemin imzası olsun mu?
8. Pencere ölçüleri (Yerleşim): Ekip 1352 genişliğe çıkıyor ki İngilizce sığsın; Olaylar 1240×900; Finans 1344. BuildHUD pencerelerin altında; pencere üstüne binince gizlenir.
9. Ofiste kurucunun halkası amber kalsın mı, yoksa kömür + beyaz iç çizgi mi?
10. Renk körü paleti: olumlu mavi, uyarı açık sarı, olumsuz turuncu. (Renk körü)
11. 1280×720 pencerede %100 ölçekte 12 px yazı ekranda 8 px çiziliyor. Orada %125'e izin verelim mi (yazı 10 px olur)? (Okunurluk)
12. Gazetenin üst bilgi satırı mono'dan çıkıyor: IBM Plex Sans Condensed (öneri) mi, Source Serif küçük büyük harf mi?
13. Haber şeridi kapatılabilsin: köşede küçük düğme kalır, tercih saklanır.
14. İzindeki çalışan: sayılar tam renk; yüz gri, ad soluk, "İzinde" etiketi.
15. Okuma bölmesi başlığı 30 px ve cümle düzeninde; bedel ekrandaki en büyük sayı kalır.
16. İlişki kelimeleri: Müttefik / Dost / Nötr / Temkinli / Düşman.
17. "Sprint otomatik başladı" notu üst bardan BuildHUD'a ve Ürün'e taşınsın.
18. Metin bulguları (ayrı onay listesine gider): 36 Türkçe metinde tire var, bazıları Frank'in; "UNİCORN INC." büyük harf hatası; rol unvanları bu sayfalarda CSV düzeninde ("UX/UI Designer").""",
"ikon": """İkon ailesi: dolu şekil, oyulmuş ayrıntı, iki ton; kâğıt olan nesnelerin köşesi pahlı. Lucide'in yerine 98 arayüz ikonu ve 9 ofis kafa ikonu.

19. Anlamlar doğru mu? Gerçek lider: şemsiye altında kişi. Hayır diyemez: onaylı balon ve kâğıt yığını. Gözü yüksekte: bavul. Ürün becerisi: tabela. Test becerisi: onaylı böcek. Satış rayı: huni. Finans: dolar sikke.
20. Ofis kafa ikonları: çalışırken koyu disk, molada krem disk (sayfa 7, oyunun kendi render'ında). Bugünkü açık diskin yerine geçsin mi?
21. Kurucu huyları henüz çizilmedi, "belirsiz" glifine düşüyor. Onlar da çizilsin mi?""",
}
TPL = """<!doctype html>
<html lang="tr">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<style>
body{{margin:0}}
</style>
</helmet>
<div style="width: {w}px; height: {h}px; background: #100E0B">
<img src="/_blob/{blob}" alt="{title}" style="display: block; width: {w}px; height: {h}px">
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{{"$preview":{{"width":{w},"height":{h}}}}}'>
class Component extends DCLogic {{
renderVals() {{
return {{}};
}}
}}
</script>
</body>
</html>
"""
boards, order, notes, pages = {}, [], {}, []
first = True
for pid, pname, rows in PAGES:
    pages.append({"id": pid, "name": pname})
    y = 0
    maxx = 0
    for row in rows:
        x = 0
        rh = 0
        for k in row:
            w, h = size[k]
            name = "Main.dc.html" if first else f"a{k}.dc.html"
            first = False
            boards[name] = {"x": x, "y": y, "w": w, "h": h, "title": TITLES[k], "page": pid}
            order.append(name)
            with open(os.path.join(ROOT, name), "w", encoding="utf-8", newline="\n") as f:
                f.write(TPL.format(title=TITLES[k], blob=BLOB[k], w=w, h=h))
            x += w + 80
            rh = max(rh, h)
        maxx = max(maxx, x - 80)
        y += rh + 120
    notes[f"t_{pid}"] = {"x": 0, "y": -300, "text": HEAD[pid], "kind": "title1", "maxW": maxx, "page": pid}
    notes[f"s_{pid}"] = {"x": maxx + 160, "y": 0, "text": STICKY[pid], "w": 1200, "maxH": 3200, "size": "l", "fill": "orange", "page": pid}
canvas = {"v": 3, "createdOnFiles": {"v": 1, "at": "2026-10-02T21:00:00Z"}, "title": "Menajer Masası · Tasarım Sistemi",
          "launch": {"view": "canvas", "page": "portre"}, "pages": pages, "boards": boards, "order": order, "notes": notes, "designSystems": []}
with open(os.path.join(ROOT, "canvas.json"), "w", encoding="utf-8", newline="\n") as f:
    json.dump(canvas, f, ensure_ascii=False, indent=1)
print(len(order), "boards")
