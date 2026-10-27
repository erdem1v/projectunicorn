---
name: feedback-scalable-mechanics-deep-research
description: "Erdem 2026-10-17: çekirdek mekanik 20–50 çalışanda kırılmamalı, sabit yerine ölçeklenen kural; araştırma oyun oyun mekanik dökümü olmalı; UI değişikliği koddan önce Claude Design maketiyle gösterilir"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869
  modified: 2026-10-17T16:43:42.574Z
---

Faz D (ekip modeli) planını okuyunca Erdem şunu söyledi: "çok sığ düşündüğünü düşünüyorum". Bir örnek de verdi:
"çalışan başına %5" gibi bir sabit, aynı rolde 10 kişi olunca oyunu kırar. Sorduğu sorular:
- 5 testçi küçük bir karta aynı anda çalışabilir mi?
- Tasarımcı sprintte mi çalışmalı, yoksa PM'le birlikte önden mi?
- Ekip kaybı olmalı mı, yoksa yalnızca Software Inc.'te var diye mi ekliyoruz?

**Why:**
- Erken Erişim'de koşu sonsuz olacak, şirket 20–50 çalışana çıkacak.
- Geri dönüp çekirdeği onarmak çok pahalı.
- Erdem'in sözü: "şu anda C ve D'yi production'a alsak başka yerler patlar".

**How to apply:**
- **Mekanik tasarımı:**
  - Her kural 1, 3, 6, 12, 25 ve 50 kişide sınanır. Uç bileşimler de denenir: hepsi testçi, aynı rolde 10 kişi, küçük
    karta çok kişi.
  - Sayı tablosu ve simülasyon plana girer.
  - Sabit yerine oranla ya da iş büyüklüğüyle ölçeklenen kural tercih edilir.
  - Her kuralın "neden var" cevabı yazılır. "X oyununda var" tek başına gerekçe değildir.
- **Araştırma:**
  - Oyun oyun mekanik dökümü yapılır: kural, formül, sayı, ekran, ölçekte ne olduğu, oyuncu şikâyetleri.
  - Sonra seçenekler ve öneri gelir. Üstünkörü özet araştırma sayılmaz. Kaynak URL'si zorunludur.
- **UI:**
  - Yeni ya da değişen ekran koddan önce maketle gösterilir. Erdem'in sözü: "UI'da değişiklik yapmak oldukça uzun
    sürüyor".
  - **2026-10-17 akşam güncellemesi (D6):** Claude Design maketi gerekmez. Ekran doğrudan oyunun kendi arayüz diliyle
    gösterilir. Erdem'in sözü: "Direkt oyunun UI'yla bu tarz ekranları bana gösterebilirsin". Araç olarak Menajer
    sistemi (`docs/mockups/menajer/`) ya da oyun içi ekran görüntüsü kullanılır.
  - Yeni görsel dil gerektiren işte sıra hâlâ [[feedback-design-research-first]]'teki gibidir.
- **Görünmez model:** Oyuncunun hiçbir yerde göremediği bir model kurulmaz. Örnek: kart eksenleri (deneyim, inovasyon,
  kararlılık) oyuncuya görünmüyor; Erdem "neyi temsil ettiğini ben bile bilmiyorum" dedi.

İlgili: [[sprint-urun-phases-2026-10-16]] · [[feedback-step-table-model-roles]]
