import os
HERE = os.path.dirname(os.path.abspath(__file__))
p = os.path.join(HERE, "template.md")
s = open(p, encoding="utf-8").read()
a = "## 6. Varsayımlar: Python yaklaşımı kodun kopyası değildir\nMemnuniyet:\n"
assert a in s
b = """## 6. Varsayımlar: Python yaklaşımı kodun kopyası değildir
**Doğrulamalar (kodun kopyası olmasa da girdiyi ve formülü sınadım):**
- Eski mekanizma kopyası K5 kaydıyla: `none` %95,8, `off` %99,0 geçiş tutuyor (§2.1).
- K5 gerçek kayıp satırları A'nın `K5_OLCUM.md` tablosuyla birebir (§2.3).
- U uygulaması `KALITE_v2.md` §2.6 tablosuyla: 9 hücrenin 8'i birebir; inşaat P1'de 81 çıkıyor, belge 80 (belge Python yuvarlamasıyla, ben Godot'nun yarım-yukarı yuvarlamasıyla).
- Ekonomi: "Bugün" satırı `C_ICERIK_v3.md` §3.5 tablosuyla aynı (açık -41K / -37K, hafta 36; 52. hafta +9K / +43K; 101. hafta +316K / +534K). A ve C satırlarında açık aynı büyüklükte (A: -13K / -12K, v3: -12K / -10K); 52. hafta farkı (A: +143K / +188K, v3: +124K / +162K) ofis kirasından: v3 ofisi çalışan sayısından seçmişti (12 ve üstü Plaza), ben taşınma koşullarını (marka ≥ 40, nakit) uyguladım, Plaza daha geç açılıyor.

Memnuniyet:
"""
s = s.replace(a, b, 1)
open(p, "w", encoding="utf-8").write(s)
print("ok")
