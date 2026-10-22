import re
# --- tablo uretici duzeltmeleri
for fn in ("tb1.py", "tb2.py", "mkreport.py"):
    s = open(fn, encoding="utf-8").read()
    s = s.replace('def pc(x, d=0):\n    return tr(100 * x, d) + "%"', 'def pc(x, d=0):\n    return "%" + tr(100 * x, d)\n\n\ndef sp(x, d=0):\n    v = 100 * x\n    return ("+%" if v >= 0 else "−%") + tr(abs(v), d)')
    open(fn, "w", encoding="utf-8").write(s)

s = open("tb1.py", encoding="utf-8").read()
s = s.replace('("%+.0f%%" % (100 * (t3[0] / y[0] - 1))).replace(".", ",")', 'sp(t3[0] / y[0] - 1)')
s = s.replace('("%+.0f%%" % (100 * (t3[1] / y[1] - 1))).replace(".", ",")', 'sp(t3[1] / y[1] - 1)')
s = s.replace('"negatif adım: %d; sıfır adım: %d; en kötü %s"', '"Negatif adım: %d; sıfır adım: %d; en kötü %s"')
open("tb1.py", "w", encoding="utf-8").write(s)

s = open("tb2.py", encoding="utf-8").read()
s = s.replace('("%+.0f%%" % (100 * (wm(H, n, 66, 130, 0) / e0 - 1))).replace(".", ",")', 'sp(wm(H, n, 66, 130, 0) / e0 - 1)')
s = s.replace('rows.append("| %s | %s |" % (ak.replace("* ", "★ ").replace("+3★", "+3★"), " | ".join(cells)))',
              'rows.append("| %s | %s |" % (ak.replace("* ", "★ ").replace("gelistirici", "geliştirici").replace("testci", "testçi").replace("tasarimci", "tasarımcı"), " | ".join(cells)))')
open("tb2.py", "w", encoding="utf-8").write(s)

s = open("mkreport.py", encoding="utf-8").read()
s = s.replace('rows.append("| %s | %s → %s (%s%%) | %s → %s (%s%%) | %s → %s |" % (lab, tr(d1), tr(d5), sg(100 * (d5 / d1 - 1)), tr(e1, 2), tr(e5, 2), sg(100 * (e5 / e1 - 1)), pc(md(Q, pre + "_1", "ready")), pc(md(Q, pre + "_5", "ready"))))',
              'rows.append("| %s | %s → %s (%s) | %s → %s (%s) | %s → %s |" % (lab, tr(d1), tr(d5), sp(d5 / d1 - 1, 1), tr(e1, 2), tr(e5, 2), sp(e5 / e1 - 1, 1), pc(md(Q, pre + "_1", "ready")), pc(md(Q, pre + "_5", "ready"))))')
# kontrol tablosu duzeltmeleri + son isleme
s = s.replace('''X["check"] = "\\n".join(rows)''', '''X["check"] = "\\n".join(rows)
for a_, b_ in (("0* baskasi", "başkasının kartı 0★"), ("3* baskasi", "başkasının kartı 3★"), ("5* baskasi", "başkasının kartı 5★"), ("3* kendi karti", "kendi kartı 3★"),
               ("[3.45, 2.33, 1.95, 1.77, 1.77, 1.77]", "[3,45, 2,33, 1,95, 1,77, 1,77, 1,77]")):
    X["check"] = X["check"].replace(a_, b_)''')
s = s.replace('out = "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/D_SIM_v3.md"', 'import re\ntxt = re.sub(r"(?<![\\w)])-(?=\\d)", "−", txt)\nout = "C:/Users/erdem/Desktop/Project Unicorn/project-unicorn/docs/tasks/faz_cde/D_SIM_v3.md"')
open("mkreport.py", "w", encoding="utf-8").write(s)

# --- sablon duzeltmeleri
p = "rapor_taslak.md"
s = open(p, encoding="utf-8").read()


def rep(old, new):
    global s
    assert s.count(old) == 1, ("bulunamadi ya da birden cok", old[:70], s.count(old))
    s = s.replace(old, new)


rep("Kaynak: `D_MODEL_v3.md` §6 (\"Simülasyon tanımı\") ve §4, `SPRINT_DUZENI.md` §4 ile §5, `D_SIM.md` (v2 raporunun biçimi ve kapıları).",
    "Kaynak: `D_MODEL_v3.md` §6 (\"Simülasyon tanımı\") ve §4, `SPRINT_DUZENI.md` (bundan sonra SD) §4 ile §5, `D_SIM.md` (v2 raporunun biçimi ve kapıları).")
rep("Fark, takım hız çarpanı ile takıma bağlı arzdan boşta kalmanın çarpımıyla %92 ile %100 açıklanıyor.", "Fark, takım hız çarpanı ile takıma bağlı arzdan boşta kalmanın çarpımıyla 3 ve 7 takımda %92 ile %100 açıklanıyor (67-130. hf).")
rep("- **Tek kurucu hariç hata yük altında değil.** 3 kişiden", "- **Hata ölçekle patlamıyor.** 3 kişiden")
rep("**Tanı.** İki cümleli kapının iki yanı tutmuyor.", "**Tanı.** Kapının iki koşulu da tam tutmuyor.")
rep("Hesap ne kadar çok olursa olsun (330 hesapta bile) açık derinlik kartı 36'yı geçmiyor, istek kartları ise yetiştikçe tüketiliyor. Formül §3.13 B: min(4, 1 + ⌊hesap ÷ 10⌋).",
    "Hesap ne kadar çok olursa olsun açık derinlik kartı 36'yı geçmiyor; 330 hesapta bile 50 kişi 386 puana kalıyor ve %23 boşta. Formül §3.13 B: min(4, 1 + ⌊hesap ÷ 10⌋).")

# plan = sonuc bolumu
rep("### 6.6 D5: A'nın sınırları oranlı (80 hafta)", "### 6.6 D5: A'nın sınırları oranlı (80 hafta)")
rep("## 7. Kapı tablosu (§6.12)", """### 6.7 Plan tahmini = sonuç kontrolü (§3.11, kapı 14)
Her sprint başında plan, kartların kopyalarını aynı oynatma fonksiyonuyla (önden tasarım ve hazırlık kuyruğu dahil) 2 hafta oynatır; sprint bitince gerçek kartlar kopyalarla karşılaştırılır. Karşılaştırılanlar: kart başına dört aşamanın ilerlemesi, bitiş zamanı, kartın n (hata sayısı), F (bulunan) ve düzeltme işi toplamı. Hata sayısı kart tohumundan test anında çekildiği için plan ve kapanış aynı sayıyı bulur; v2'nin "çekiliş karşılaştırılmaz" istisnası kalktı.

Sonuç: 8.220 koşuda (tüm ölçek, uç bileşim, politika, arz ve EA senaryoları) en büyük fark **1,4e-14** (kapı: 1e-6). Aynı kart, aynı ekip, iki ayrı koşuda aynı n, F, düzeltme işi ve bitiş zamanını verdi (§2, son satır). Benzetimde adlı uyuşmazlık nedenleri (B'nin kararları, işe alım ya da ayrılık, izin, kurucu toplantısı) yok; bunlar tahmini oyunda bozar, benzetimde değil.

## 7. Kapı tablosu (§6.12)""")
open(p, "w", encoding="utf-8").write(s)
print("tamam")
