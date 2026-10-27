---
name: feedback-design-research-first
description: "Erdem 2026-10-01: görsel yön önermeden/üretmeden ÖNCE referans araştırması şart (diğer oyunlar nasıl yapmış); UI Lab'ın üç yönü araştırmasız üretildi ve üçü de reddedildi"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0e406678-a661-4d23-90af-2e43deb375cc
  modified: 2026-09-30T22:29:06.638Z
---

UI Lab (2026-09-30/10-01) üç klasör yönünü (Evrak/Dosya/Gazete) spec'teki metaforu doğrudan uygulayarak üretti; altyapı
kusursuzdu ama Erdem üçünü de reddetti: "hiç birini beğenmedim ... sen hiç araştırma yaptın mı bu UI nasıl olabilir diye
... diğer oyunlar nasıl yapmış".

**Why:** Görsel iş spec'teki metafor + palet tarifinden üretildi; benzer oyunların (yoğun veri yöneten yönetim/tycoon/
strateji oyunları) sorunu nasıl çözdüğüne bakılmadı, mevcut ekranın asıl zaafları analiz edilmedi, metafor sorgulanmadı.
Doğrulama kapıları (piksel eşliği, glif, override) estetik kaliteyi ölçmez. [[design-work-lessons]] dersinin tekrarı.

**How to apply:**
- Görsel yön, tema, ekran tasarımı işinde ilk adım referans araştırması: somut oyunlar, ekran görüntüleri/kaynak linkleri,
  neden işe yaradıkları, bizim ekranlarımıza ne taşınır. Sonuç Erdem'e gösterilir, o seçer; üretim ondan sonra.
- Spec bir metafor/yön dayatsa bile araştırma onu sınar; zayıfsa söylenir.
- Altyapı (lab, kurucu, denetim) yön kararından bağımsız değerlidir; reddedilen yön klasörüyle silinir, altyapı kalır.

**Tekrarı 2026-10-07 (Piyasa P3):** brief'i doğrudan 11 kareye çevirdim (8 sütun + fiyat + kıvılcım + "SENİN SIRAN"
KPI'ı = finans sitesi tablosu kabuğa yapıştırılmış). Erdem: "gelişigüzel, eklenmiş olmak için eklenmiş, oyunu
yansıtmıyor, bilgi yoğunluğu gereksiz; daha sade ama daha rafine" ve "oyuncu listede değilken SIRA göstermek
yanlış; değerleme olabilir". Düzeltme yolu: 4 yön × tek kare (endeks sayfası / değer merdiveni / piyasa haritası /
sade liste) → Erdem seçer → tam set. Kural keskinleşti: **yeni bir ekran için önce 3-4 yön, her biri TEK kare, sahip
seçmeden tam set yok; oyuncu için sıra numarası hiçbir zaman, yalnız değerleme; her sayı "oyuncu bunu neden görsün?"
sorusunu geçsin.** Araştırma raporunun sütun listesini brief'e kopyalamak tasarım değildir.

**İkinci tekrar, aynı gün (Piyasa yönleri):** dört yönü de referans görüntüsü olmadan, "bilinen tasarım
kalıplarından" ürettim; Erdem: "hâlâ yeterli değil, rakip oyunların ekranlarını incelediniz mi???". Doğru sıra:
**(1) rakip oyunların GERÇEK ekran görüntüleri (Steam galerisi, wiki, yapımcı sitesi; arama yoksa bilinen URL)
→ (2) referans panosu, Erdem beğendim/beğenmedim işaretler → (3) ancak o zaman yön/maket.** "Araştırma yaptım"
demek için ekran görüntüsü şart; metin özeti araştırma sayılmaz.
