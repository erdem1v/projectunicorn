# Onaylı mockup'lar — Tema Çekirdeği'nin ölçüm kaynağı

Bu klasördeki kareler **ölçüm kaynağıdır, yeniden tasarım emri değildir.** Tema Çekirdeği
(2026-08-03) tip ölçeğini, boşluk/şekil token'larını ve paletini bunlardan türetti; hiçbir
ekranın yerleşimi bir mockup'a "uysun diye" değiştirilmedi.

Kareler el yapımı — piksel-mükemmel değiller. İki kare bir değerde ayrışırsa **ortak zemin
alınır, bir kez seçilir ve raporlanır**; tek bir kare piksel-piksel kovalanmaz.

## Dosyalar

| Dosya | Kare | Neyin kanonu |
|---|---|---|
| `oda_kare1_gunduz.png` | 3a · KARE 1 · TEMİZ MASA | Üst bar istatistik ritmi (`CASH/MRR/BURN` mono caps 9px + değer sans-sb 15px), sol ray sekme etiketi (11px), haber şeridi, pano kartları. Gündüz ışık katmanı. |
| `oda_kare3_olay.png` | 3c · KARE 3 · OLAY ANI | Aynı kabuk, olay anı: ürün ekranı ilerleme çubuğu, sağ üst müşteri kartı (başlık serif-sb + gövde serif + aksiyon satırları), ATLAS şeridi. |
| `event_modal.png` | 1e · KARAR OLAYI · MODAL | Karar kartı: manşet (30px serif-sb), deck gövde (15px serif), seçim kartları (başlık serif-sb + italik alt satır), rozet çipleri (9px mono caps), MENTOR TAVSİYESİ amber çerçeve, footer meta. |
| `gazete_ending.png` | 1f · RUN SONU · GAZETE | Editorial display katmanı: masthead 54, manşet 30, deck italik 15, istatistik rakamları 44 + altlarındaki mono caps etiketler, iki sütun gövde 13, koyu ray + amber CTA. |

## Eksikler

Task metni `finance_tab` ve `hr_kare2/4/6` + `oda_katman_gece` karelerinden de söz ediyor;
bunlar teslim edilmedi. Yukarıdaki dördü tip rollerinin tamamını zaten örneklediği için
ölçek onlarsız kapatıldı — eksik kareler gelirse **yoğun-veri boyutlarını doğrular**, yeni
bir rol eklemeleri beklenmiyor.

## Token izlenebilirliği

Tema Çekirdeği raporundaki her satır üç etiketten birini taşır:

- **measured** — değer doğrudan bu karelerden okundu
- **inferred** — karelerde temiz bir örneği yok, ölçeğin oranından türetildi
- **carried-over** — değer zaten kodda vardı ve daha önceki bir oturumda bu aynı
  karelerden türetilmişti (`build_theme.gd` yorumları bunu söylüyor: satır 98, 131, 157, 165)

## Not

PNG'ler bu klasöre Erdem tarafından elle konur (ölçüm oturumunda görsel bağlamdaydılar ama
diske yazılabilir halde değillerdi). Dosya adları yukarıdaki tabloyla **birebir** olmalı —
rapor ve `ui_tokens.gd` yorumları bu adlara atıf yapıyor.
