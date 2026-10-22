import os, re
HERE = os.path.dirname(os.path.abspath(__file__))


def patch(fname, pairs):
    p = os.path.join(HERE, fname)
    s = open(p, encoding="utf-8").read()
    for a, b in pairs:
        assert a in s, (fname, a[:70])
        s = s.replace(a, b, 1)
    open(p, "w", encoding="utf-8").write(s)


# ---- model.py: Turkce tutum adlari
patch("model.py", [('STANCE_NAME = ["Zamma acik", "Ayni fiyat", "Indirim ister", "Ayrilmayi dusunuyor", "Yenilemeyecek"]',
                    'STANCE_NAME = ["Zamma açık", "Aynı fiyat", "İndirim ister", "Ayrılmayı düşünüyor", "Yenilemeyecek"]')])

# ---- p2: M6 None -> "-"
patch("p2_scen.py", [('''                                 "ayrıldı (hf %d)" % r["left"] if r["left"] else "-", gone if gone is not None else "-", ser.get(80)])''',
                      '''                                 "ayrıldı (hf %d)" % r["left"] if r["left"] else "-", gone if gone is not None else "-", ser.get(80, "-")])''')])

# ---- p3: E1 runway kolonu
patch("p3_econ.py", [('''                                 s["first_pos"], s["sustained"], "%.1f ay" % (s["min_runway"][1] or 0) if s["min_runway"][1] else "-",''',
                      '''                                 s["first_pos"], s["sustained"], " / ".join(("%.1f" % s["min_runway"][ph]) if s["min_runway"][ph] else "açık yok" for ph in (1, 2, 3)),'''),
                     ('"ilk net>=0 ay sonu (hf)", "3 ay üst üste net>=0 (hf)", "en düşük runway (evre 1)", "en düşük nakit (çek dahil)"',
                      '"ilk net>=0 ay sonu (hf)", "3 ay üst üste net>=0 (hf)", "en düşük runway, ay (evre 1 / 2 / 3)", "en düşük nakit (çek dahil)"')])

# ---- build_report: CS tablosuna ondalik donusumu uygulama
patch("build_report.py", [('''    tpl = tpl.replace(tag, dec(val))''', '''    tpl = tpl.replace(tag, val if key == "CS" else dec(val))''')])

# ---- template
p = os.path.join(HERE, "template.md")
s = open(p, encoding="utf-8").read()
i = s.index("## 0. Erdem'e özet")
j = s.index("---\n\n## 1. Kapı tablosu")
new0 = """## 0. Erdem'e özet

1. **Kayma (ölçüm).** Eski kodda hesap imzada 50-52 ile açılıp haftada en çok 21 puan (ilk 4 hafta 35) gizli hedefe yürüyor. K5'te (2.769 hesap) hiç düzeltmeyen kolda hesapların %87'si ilk haftada en az 5 puan düşüyor; ortalama 52 → 44 → 42 (1. ve 4. hafta). Düzelten kollarda ortalama 58'e çıkıyor, ama %18-20'si yine ilk haftada en az 5 puan düşüyor.
2. **Nedensiz düşüş (M1): GEÇTİ.** K5'te 14.175 düşüş haftasının 1.450'si (dar tanım) ya da 337'si (geniş tanım) hiçbir adlı olaya bağlanamıyor. Yeni modelde 250 bin hesap-haftasında ve bütün senaryolarda sayı 0.
3. **İmza (M2, M10): GEÇTİ.** Yeni modelde hesap gerçek değerle açılıyor ve ilk 12 haftada altına inmiyor (2.197 imza, 0 istisna). Eski mekanizmada 2.256 imzanın 105'i iniyor (erken haftalarda %25). Kapı `fix_worst` imzalarının %86,4'ünü geçiriyor.
4. **Dikkat: ürün uyumu 100'e doyuyor.** Bot ürünü 30. haftada Series A çıtasını karşılıyor, imzaların %75'i U = 100. Düzelten kollarda ortalama memnuniyet 92-96 (kayıtta 62-63); yenilemede eşiğin 53-72 puan üstü. Tutum %100 "Zamma açık", kâğıt hiç gelmez. Bantlar yeniden ayarlanmalı (§2.10).
5. **Kayıp (M3, M4: GEÇTİ; M5: KALDI).** Düzelten kollarda kayıp 0 (kayıtta %3,7-6,8). Hiç düzeltmeyen kolda geç kayıp %1,4 ve %6,9 (hedef en az %10): hata terimi tavanı 60, U = 100 iken memnuniyet 40, eşik 30-38. Öneri: tavan 64 (%35 ve %59); M3 ve M4 değişmez (§5.1).
6. **Söz ve güncelleme (M6, M8: GEÇTİ).** Tutulmayan söz 13 haftada siliniyor (temsilcide 10); eşiğe 8 puan yakın hesap Risk'e giriyor, 20 uzak girmiyor; tutulan söz +6 kalıcı. Yaş terimi 26 / 52 / 104 haftada 0 / -6 / -12.
7. **Sunucu (M12: GEÇTİ).** Standart, 26-104. haftada gelirin %9,1'i (B2B) ve %9,8'i (B2C); Ekonomik yarısı, Kurumsal iki katı.
8. **Gider (M11: KALDI).** Araç ve servis kalkınca B2B'de en derin açık -41K'dan -13K'ya, 52. hafta net +9K'dan +143K'ya, evre 3 aylık net +27K'dan +89K'ya çıkıyor (tahmin). Bootstrap runway 6,7 ay, aynı. Maaş ×1,5 yetmiyor; dört koşul ancak ×2,2'de tutuyor. Servisin gerçek karşılığı müşteri temsilcisi maaşı: 38 temsilci, ayda yaklaşık $71K (tahmin).
9. **Kesinti ve bütçe (M7, M9: KALDI).** Kademe çarpanı tavandan önce uygulandığı için 9 hücrenin 3'ünde Ekonomik ile Standart yaklaşıyor; çarpanı tavandan sonra uygulamak 9 hücrenin 9'unu tutturuyor. Bakımlı üründe bütçe kesintisi yılda 5,8 olay ve hepsi küçülme: tam kayıp 0 (hedef %0,5-1,5).
10. **Kapılar:** 13'ten 8'i GEÇTİ (M1, M2, M3, M4, M6, M8, M10, M12), 4'ü KALDI (M5, M7, M9, M11), M13 karşılaştırma tablosu. Karar bekleyen beş nokta §5.5'te.

"""
s = s[:i] + new0 + s[j:]
a = "54. haftada yenileme dönemi açılınca Traction çıtası okunuyor (ürün Çekirdek 0,6'da kalmış; 77 → 60, adlı olay, en büyük düşüş -17)."
assert a in s
s = s.replace(a, "54. haftada yenileme dönemi açılınca Traction çıtası okunuyor (ürün Çekirdek 0,6'da kalmış): ürün uyumu 77 → 60, memnuniyet 65 → 49 (adlı olay: yenileme dönemi açılışı).")
open(p, "w", encoding="utf-8").write(s)
print("ok")
