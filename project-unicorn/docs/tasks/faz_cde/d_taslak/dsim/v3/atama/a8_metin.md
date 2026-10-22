# A8 · Proaktif ve reaktif sprint planlayıcısı

21 Ekim 2026 · Faz D, adım A8 · Godot koşturulmadı; oyun koduna, `strings.csv`'ye, `data/`'ya, `project.godot`'a dokunulmadı; git'te durum değişmedi. Yeni kod yalnız `d_taslak/dsim/v3/atama/` altında (`a8plan.py` planlayıcı, `a8run.py`, `a8tab.py`, `a8test.py`, `a8iz.py`, `a8rapor.py`); `dsim3.py`, `a3core.py` ve `hata2.py` değişmedi. Bu işin ilk adımı olarak `A6_HATA_MODELI.md`'nin sonuna "Karar (2026-10-21)" bölümü eklendi (Erdem'in 24. kararı ve yardımcı yönetmenin hacim kararı: biçim K-E, ölçek `c` [WORKING], kartlar yenilenene kadar K-H, `c` = 0,212); bu belgenin bütün ölçümleri K-H ile koşar.
Girdiler: `ERDEM_KARARLAR_2026-10-20.md` "24–31 cevapları" madde 25 (atama proaktif ve reaktif olmalı) ve önceki 18-21; `A3_OLCUM.md`, `A4_TASARIM.md`, `A6_HATA_MODELI.md`. Sayıların hepsi koşulardan gelir; ham sonuçlar `atama/out8/`'de. R, Tarif ve T_plan kolları A6'nın kayıtlarından (`out6/ana/H`) okunur; bu kodla yeniden koşulunca aynı sonucu verdikleri `a8test.py regress` ile doğrulandı (§6).

**Okuma anahtarı.** *P* = bu belgenin planlayıcısı. *R* = bugünkü kural (D0s'un önerdiği okuma). *Tarif* = Erdem'in atama tarifi (A6'daki T: en yüksek gereksinimli karta en iyiler, "kalır", PM'de en basit kart en zayıf PM, hata modeli K-H). *T_plan* = A6'nın tanı kolu (tarifin yalnız 1. adımında "en önde duran kart" gereksinim yerine plan sırasıyla seçilir; öneri değil, nedeni ayırmak içindi). *Plan sırası* = sprint planındaki kart sırası (devreden, söz, düzeltme, yeni kartlar). *Gereksinim* = kartın istediği yıldız. *Kalır* = kişi kartın aşamasına girince aşama bitene kadar orada kalır. *Oynatma* = motorun bir sprinti (ya da kalan kısmını) baştan sona bir kez hesaplaması. Ölçütler: *MVP haftası* üç MVP kartının da teslim edildiği ilk sprintin bittiği hafta (en erken 2); *açık hata* sprint sonlarında canlı üründe duran hatanın medyanı; *kaçan söz* vadesi gelen söz kartlarından vadeyi kaçıranların payı (yalnız kaynaklı arz); *boşta* iş bulamayan insan zamanının payı, iki sayı: **PM hariç / PM dahil** (PM'in boş zamanı hazırlığa gider; kartta çalışmayan PM zamanı ikinci sayıda boşta görünür, 1 ve 3 kişide PM yok, tek sayı); *teslim* haftada teslim edilen kart puanı; *doğan hata* pencerede kartlarda ortaya çıkan toplam hata. *Eşli fark* = aynı 20 tohumda iki kolun farkının ortalaması ± ortalamanın standart hatası, parantezde "farkın eksi çıktığı tohum / 20". Tablolarda ondalık nokta kullanılır (A3 ve A6 gibi). `[GÖRÜŞ]` benim yargım, `[DEĞERLENDİREMEM]` veri yok.

## 0. Erdem için: oyuncunun ekranında ne oluyor

{{dosya:a8_parcalar/madde0.md}}

## 1. Tek tablo

20 tohumun ortalaması, hata modeli K-H. Ekip büyüklüğü 1, 3, 6, 12, 25, 50 kişi. "Tarif" sütunları A6'nın T kolu. Boşta sütununda iki sayı varsa ilki PM hariç, ikincisi PM dahil.

{{tab:tek}}

Aynı tablo, tanı kolu T_plan yanında (P, T_plan, R):

{{tab:tek_tplan}}

### 1.1 Eşli farklar (P, R, Tarif ve T_plan'a göre)

Eksi işaret MVP, açık hata, kaçan söz, boşta, doğan hata ve kaçan hatada P lehine, teslimde P aleyhinedir. Parantezde farkın eksi çıktığı tohum sayısı.

*MVP haftası*

{{tab:fark_mvp}}

*Açık hata*

{{tab:fark_acik}}

*Kaçan söz (yalnız kaynaklı arz; pp = yüzde puanı)*

{{tab:fark_soz}}

*Boşta (PM hariç)*

{{tab:fark_bosta}}

*Boşta (PM dahil)*

{{tab:fark_bosta_pm}}

*Teslim (puan/hf)*

{{tab:fark_teslim}}

*Doğan hata (pencerede toplam; ilkenin ölçüsü)*

{{tab:fark_dogan}}

*Sürüme kaçan hata (pencerede toplam)*

{{tab:fark_kacan}}

### 1.2 Düz sayılarla doğan hata ve kaçan hata

*Doğan hata*

{{tab:lv_dogan}}

*Sürüme kaçan hata*

{{tab:lv_kacan}}

{{dosya:a8_parcalar/okuma1.md}}

## 2. İz 1: Erdem'in örneği birebir

{{dosya:a8_parcalar/iz1.md}}

## 3. İz 2: "3 kişi + 4 kart", MVP'nin 4. haftadan 6. haftaya kaydığı gerçek tohum

{{dosya:a8_parcalar/iz2.md}}

## 4. Planlayıcının kuralı ve plan süresi

{{dosya:a8_parcalar/kural4.md}}

## 5. Yorum ve [GÖRÜŞ]

{{dosya:a8_parcalar/yorum5.md}}

## 6. Doğrulama

{{dosya:a8_parcalar/dogrulama6.md}}

## 7. Bitmeyenler ve sınırlar

{{dosya:a8_parcalar/bitmeyen7.md}}

## 8. Yeniden üretim

{{dosya:a8_parcalar/uretim8.md}}

## İnceleme notu (Opus)

{{dosya:a8_parcalar/inceleme9.md}}
