# A7 incelemesinin metin duzeltmeleri: a6_metin.md'ye uygular (her eski parca tam bir kez gecmeli). python -I a7duzelt.py
import os, sys
HERE = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")
P = os.path.join(HERE, "a6_metin.md")
s = open(P, encoding="utf-8").read()
REP = [
    # §1 madde 2: simulasyonda olmayan 3* kilitli kart yerine gercek en zor kart
    ("2. **Oyuncunun ekranında ne değişir.** Hacim-nötr ayarla (K-H, aşağıda) gereksinimi 3★ olan 40 puanlık bir kartı 3★ geliştirici yaparsa beklenen hata 5,1; 5★ geliştirici yaparsa 2,5. 1★ isteyen 15 puanlık küçük kartta 1★ kişi 0,64, 5★ kişi 0,16 hata sokar. Yani zor kartta yıldız farkı hatayı ikiye böler (yaklaşık 2,5 hatalık fark), basit kartta farkı hissettirmez (yarım hata).",
     "2. **Oyuncunun ekranında ne değişir.** Simülasyonun kartlarında Yazılım kilidi en çok 2★ (3★ ya da 5★ isteyen kart yok; A7 incelemesi). Hacim-nötr ayarla (K-H, aşağıda) simülasyonun en zor kartını (40 puan, 2★ Yazılım kilidi) 2★ geliştirici yaparsa beklenen hata 3,4; 4★ geliştirici yaparsa 1,7. Kilitsiz 40 puanlık kartta (1★ sayılır) 1★ kişi 1,7, 4★ kişi 0,6; kilitsiz 15 puanlık küçük kartta 1★ kişi 0,64, 5★ kişi 0,16 hata sokar. Yani zor kartta yıldız farkı hatayı ikiye böler (1,7 hatalık fark), basit kartta fark yarım hata. Bugünkü modelde aynı iki fark 0,4 (40 puan, 2★ → 4★) ve 0,3 (15 puan, 1★ → 5★) hata."),
    # §1 madde 3: K-E katinin tanima bagliligi
    ("Kolların sıralaması iki ayarda aynı: yani aşağıdaki bulgular ayar seçimine bağlı değil.",
     "Kolların sıralaması iki ayarda aynı: yani aşağıdaki bulgular ayar seçimine bağlı değil. Bu \"iki kat\" \"3 sprintlik iş\" tanımıma çok bağlı (A7 incelemesi): 3 sprint süren işi \"Yazılım aşaması tek başına 3 sprint süren kart\" diye okursak `c = 0,264` olur ve hacim bugünkünün 1,23 katı (6 kişi) / 1,20 katı (50 kişi); senin 3★ işini simülasyonun en zor kartına (2★) eşlersek `c = 0,718` ve 2,82 katı (6 kişi)."),
    # §1 madde 4: ek suffix ve iki yeni neden
    ("%<<raw altinda_R_S3>>'i, 12 kişide %<<raw altinda_R_S4>>'ü", "%<<raw altinda_R_S3>>'si, 12 kişide %<<raw altinda_R_S4>>'sı"),
    ("(A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde).\n5.",
     "(A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde). A7 incelemesi iki neden daha ölçtü: (1) kartlarda karmaşıklık farkı küçük: Yazılım kilidi en çok 2★ ve sınırsız arzda ölçüm penceresindeki özellik kartlarının hepsi 40 puan (6 kişide kartların %68'i kilitsiz, %32'si 2★ kilitli), yani en karmaşık özellik kartının tavanı en basitininkinin yalnız 2 katı; (2) kazancın bir kısmı benim seçtiğim \"gereksinimin altındaki kişi daha çok hata sokar\" uzatmasından (§0 satır 3) geliyor: bu uzatma kaldırılınca (Δ < 0'da oran 0,20'de kalır) tarifin doğan hata farkı 12 kişide −5,7 ± 1,9'dan −2,5 ± 2,0'a (ayırt edilemez), 25 kişide −9,6 ± 2,0'dan −8,2 ± 2,4'e, 50 kişide −33,3 ± 4,0'dan −23,3 ± 3,3'e iniyor; 6 kişide tarif R'den fazla hata üretiyor (+2,4 ± 1,0; kaynaklı arzda +5,6 ± 2,1).\n5."),
    # §1 madde 6: standart hata kati
    ("(standart hatanın 1-2 katı)",
     "(teslim farkı 12 ve 25 kişide standart hatanın 2,3 ve 3,7 katı, ayırt edilebilir; 50 kişide teslim ve üç ekipte doğan hata farkı standart hatanın 0,1-1,9 katı, ayırt edilemiyor)"),
    # §1 soru 1: gercek kartla ornek
    ("Örnek: 6 kişilik ekipte 40 puanlık 3★ isteyen bir kartı 3★ geliştirici yapıyor. (A) Hacim-nötr (K-H): kartın beklenen hatası 5,1,",
     "Örnek: 6 kişilik ekipte simülasyonun en zor kartını (40 puan, 2★ Yazılım kilidi) 2★ geliştirici yapıyor. (A) Hacim-nötr (K-H): kartın beklenen hatası 3,4,"),
    ("aynı kartın beklenen hatası 11,5, oyunda bugünkünün <<raw oran_E_S3>> katı hata doğar;",
     "aynı kartın beklenen hatası 7,7, oyunda bugünkünün <<raw oran_E_S3>> katı hata doğar (bu kat \"3 sprintlik iş\"in nasıl okunduğuna bağlı: 1,2 ile 2,8 kat arası, madde 3);"),
    # §4.3: olcu tanimi ve ek
    ("kaçan sözü %<<lv soz T_plan H PR_S3>>'e (R: %<<lv soz R H PR_S3>>); ayrıca kalır kapalıyken (`T_plan_np`) %<<raw tani_soz_plannp>>'e indiriyor (a6tani.py, toplam vadesi gelen karta bölünmüş oran).",
     "kaçan sözü %<<lv soz T_plan H PR_S3>>'a (tohum ortalaması, ana tablonun ölçüsü; R: %<<lv soz R H PR_S3>>) indiriyor; toplam vadesi gelen karta bölünmüş oranla (a6tani.py) `T_plan` %<<raw tani_soz_plan>>, kalır kapalıyken (`T_plan_np`) %<<raw tani_soz_plannp>>."),
    # §5 madde 2
    ("[GÖRÜŞ] İki neden: (a) R de en hızlı kişiyi en büyük karta veriyor (ilkeye zaten yakın), (b) Yazılım işinin çoğu dar bir yıldız aralığında yapılıyor (A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde); 5★ ağırlıklı bir ekipte fark büyür [DEĞERLENDİREMEM, ölçülmedi].",
     "[GÖRÜŞ] Nedenler: (a) R de en hızlı kişiyi en büyük karta veriyor (ilkeye zaten yakın), (b) Yazılım işinin çoğu dar bir yıldız aralığında yapılıyor (A3 §2.2: 25 kişide Geliştirme işinin %62'si 2,5-3,5★ kişilerde); 5★ ağırlıklı bir ekipte fark büyür [DEĞERLENDİREMEM, ölçülmedi]. Ölçüm (A7 incelemesi): (c) simülasyonun kartlarında karmaşıklık farkı küçük (Yazılım kilidi en çok 2★; sınırsız arzda pencerede bütün özellik kartları 40 puan, tavanları yalnız 1'e 2 oranında ayrışıyor); (d) 12 kişide kazancın yarısından çoğu, 50 kişide yaklaşık üçte biri gereksinimin altı için seçtiğim eğri uzatmasından (§1 madde 4)."),
    # §5 madde 4
    ("doğan hatada (ii) 12-50 kişide önde (§3).",
     "doğan hatada (ii) 12-50 kişide önde görünüyor ama farklar standart hatanın 0,1-1,9 katı, ayırt edilemiyor (§3). (ii)'nin ataması bugünkü PM kuralıyla (en iyi PM'den başlayarak kartları büyükten küçüğe dağıtmak) neredeyse aynı; tek fark kartların puan yerine \"puan × gereksinim\" ile sıralanması (a6test.py pm: 6 kartlık örnekte (ii) ve bugünkü kural aynı atamayı veriyor)."),
    # §5 madde 6
    ("[GÖRÜŞ] Erdem'in örnek sayıları ilkenin biçimini veriyor, ölçeği değil; ölçek ayrı karar (§1 soru 1).",
     "[GÖRÜŞ] Erdem'in örnek sayıları ilkenin biçimini veriyor, ölçeği değil; ölçek ayrı karar (§1 soru 1). Ölçüm (A7): kat \"3 sprintlik iş\" tanımına bağlı, 1,2 (Yazılım aşaması 3 sprint süren kart, `c = 0,264`) ile 2,8 (Erdem'in 3★ işi simülasyonun 2★ kartına eşlenince, `c = 0,718`) arası."),
    # §7
    ("- **Kapı verisi** yalnız ERP + paylaşılan hatlardan (R ≤ 3).",
     "- **Kapı verisi** yalnız ERP + paylaşılan hatlardan; Yazılım kapısı en çok 2★ (dokuz hattın dördünde K2 ve K3'te 2★, gerisinde kapı yok), yani R yalnız 1 ya da 2 (A7 incelemesi; önceki metinde \"R ≤ 3\" yazıyordu)."),
    ("Erdem başka tanım (ör. ekip büyüklüğüne bağlı) isterse yalnız `c(K-E)` değişir, K-H etkilenmez.",
     "Erdem başka tanım (ör. ekip büyüklüğüne bağlı) isterse yalnız `c(K-E)` değişir, K-H etkilenmez. Tanımda 69,6 bir 3★ kişinin 6 haftalık **Yazılım** işidir ama tavan kartın **toplam** puanıyla (Tasarım + Yazılım + Test) çarpılır; K3 kartında Yazılım payı ortalama %55 (40 puanın 18 / 26 / 22'si). Ölçüm (A7, R kolu, 20 tohum): `c = 0,264` ile hacim bugünkünün 1,23 (6 kişi) / 1,20 (50 kişi) katı, `c = 0,718` ile 2,82 katı (6 kişi)."),
    ("Δ < 0'ı 0'a kırpmak R'nin hatasını azaltır, tarife karşı farkı küçültür [DEĞERLENDİREMEM, koşulmadı].",
     "Δ < 0'ı 0'a kırpmak R'nin hatasını azaltır, tarife karşı farkı küçültür. Ölçüm (A7, `a7neg.py`, 20 tohum): kırpınca R'nin doğan hatası 6 / 12 / 25 / 50 kişide %2,5 / %2,5 / %0,5 / %1,7 azalıyor (kaynaklı 6 kişide %7,9); tarif − R doğan hata farkı 6 kişide +0,8 ± 1,3 → +2,4 ± 1,0, 12 kişide −5,7 ± 1,9 → −2,5 ± 2,0, 25 kişide −9,6 ± 2,0 → −8,2 ± 2,4, 50 kişide −33,3 ± 4,0 → −23,3 ± 3,3, kaynaklı 6 kişide −1,6 ± 2,3 → +5,6 ± 2,1, kaynaklı 50 kişide −45,2 ± 4,4 → −36,6 ± 4,5."),
    ("- **Kurucu ve eşiği:** kurucu Tasarım ve Test için 2★ sayılır (A3 gibi); Yazılım yıldızı ham.",
     "- **Kurucu ve eşiği:** kurucu her alanda en az 2★ sayılır (A3'ün `tinfo`'su, Yazılım dahil); kurucunun Yazılım becerisi zaten 2★ olduğundan Yazılımda fark yok."),
]
for a, b in REP:
    n = s.count(a)
    if n != 1:
        sys.exit("BULUNAMADI (%d): %s" % (n, a[:80]))
    s = s.replace(a, b)
open(P, "w", encoding="utf-8", newline="\n").write(s)
print("uygulandi", len(REP))
