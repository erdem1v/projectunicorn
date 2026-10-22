| Doğrulama | Beklenen | Bulunan | Sonuç |
|---|---|---|---|
| Regress: planlayıcı kodu yüklü, atama kipi "p8" değilken R, Tarif (K-H ve bugünkü hata modeli) ve T_plan kolları A6'nın kayıtlarıyla (S1-S6 ve kaynaklı S2-S4, ilk 5 tohum; 25 ve 50 kişide 1 tohum) | 0 fark | 10.730 metrik, 0 fark (`out8/a8_regress.txt`) | GEÇTİ |
| Planlayıcı kodunun son hâliyle kayıtlı P ve P_sabit sonuçlarının yeniden koşusu (3 tohum × 8 hücre) | 0 fark | 1.176 metrik, 0 fark (`out8/a8_tekrar.txt`) | GEÇTİ |
| P_r85 (P'nin aynı ayarı, ayrı koşu) = P | 0 fark | 5.400 metrik, 0 fark (`out8/a8_dogrula.txt`) | GEÇTİ |
| Mikro testler: Erdem'in örneği (büyük kart 2 kişi, küçük kart 1 kişi, 3. kart bekler); büyük iş 2 kişiye sığmayınca 3 kişi; gereksinimin altındaki kişi girmez; karmaşık karta en iyi kişi (yer değişimi); plan sırası ve havuz bitince bekleme; saklama; `t_full`; `_pick_crew` (tek yeten en zayıf, en küçük toplamlı yeten çift, yetmeyen istek) | 12/12 | 12/12 (`out8/a8_micro.txt`) | GEÇTİ |
| Sahte bozma (testler boş değil): gereksinim kapısı kapatılınca, yer değişimi kapatılınca, saklama etkisizleştirilince, tek yeten kişi hep en güçlü seçilince | her bozmada en az 1 mikro vaka düşmeli | düşen vaka sayısı 2 / 1 / 1 / 1; bozmasız 0 (`out8/a8_falsify.txt`) | GEÇTİ |
| Tahmin = sonuç | ≤ 1e-6 | 1.620 koşunun (81 dosya, 20 tohum) hepsinde en büyük fark 7,1e-15 | GEÇTİ |
| P'de hafta başı seçimi gerçek oynatmada plan oynatmasından önbellekle gelir (durum aynıysa) | her koşuda önbellek isabeti × 2 = hafta başı sayısı | ihlal eden koşu 0 | GEÇTİ |
| Tepki: Erdem'in örneğinde gerçek oynatmada hız sapması yok | iki hafta da önbellekten, ilerleme plan = gerçek | 2/2 hafta önbellekten; ilerleme [55,543; 10,5; 10,5] ikisinde de | GEÇTİ |
| Tepki: A'nın hızı 2. haftada %40 düşük (plan bilmiyordu) | o hafta önbellek tutmaz, planlayıcı yeniden kurar | 1 hafta önbellekten, 1 hafta yeniden kuruldu; gerçek ilerleme [51,04; 10,0; 10,0] (plan [55,543; 10,5; 10,5]) | GEÇTİ |
| "Kalır": hafta sonunda aşaması süren kartta olan kişi sonraki hafta başı aynı kartta (S4, tohum 1) | P'de 0 değişim | P: sprint içi 0/166, sprint sınırı 0/151; R: 90/171 ve 67/149 | GEÇTİ |
| Determinizm: aynı hücre iki kez | aynı sonuç | aynı (`a8test.py determ`) | GEÇTİ |
| Gereksinimin altındaki Yazılım işi P kollarında | 0 | 0 koşuda var; R'de 6 / 12 / 25 / 50 kişide {{m:R:S3:altinda}} / {{m:R:S4:altinda}} / {{m:R:S5:altinda}} / {{m:R:S6:altinda}} | GEÇTİ |
| Bulunan hata ≤ doğan hata | 0 ihlal | 0 | GEÇTİ |
| Her hücrede 20 tohum | 20 | 81 dosyanın hepsinde 20 | GEÇTİ |

Ham çıktılar `out8/`'de: `a8_regress.txt`, `a8_micro.txt`, `a8_falsify.txt`, `a8_react.txt`, `a8_kalir.txt`, `a8_determ.txt`, `a8_dogrula.txt`, `a8_secim.txt`.

**Tepki testinin ham çıktısı** (Erdem'in örneği; gerçek oynatmada 2. hafta A'nın hızı %40 düşük; tablo kişi başına süre, h = hafta):

```
{{dosya:out8/a8_react.txt}}
```

**Hangi seçenek kazanıyor** (`a8sec.py`, ilk 3 tohum, hafta başı seçim sayısı ve payı): tek bir seçenek baskın değil, bu yüzden aramanın bir işi var.

```
{{dosya:out8/a8_secim.txt}}
```
