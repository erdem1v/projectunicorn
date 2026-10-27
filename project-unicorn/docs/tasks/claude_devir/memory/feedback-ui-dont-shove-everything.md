---
name: feedback-ui-dont-shove-everything
description: "Erdem 2026-10-22 (M2 sprint ekranı incelemesi): açıklayıcı cümle satırları ekrana değil ipucuna; oyuncu durumu gösterimden kendisi anlamalı; yazı kısaltması yerine ikon; yoğun ekranda font ve hiyerarşi"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 4eb24b6e-e052-4367-accb-762dbc3e78d2
  modified: 2026-10-22T19:02:16.473Z
---

Erdem M2 sprint planı maketine (2026-10-22): "Her şeyi oyuncunun gözüne sokmamalıyız; slop yapan bu." Sistem kurgusu kabul,
sorun arayüz.

- Açıklayıcı cümle satırları ("Yeterli: fatura kesme çalışıyor…", "test yetişmiyor", "devretmek için ürün yöneticisi olmalı")
  ya kalkar ya ipucuna (hover) iner.
- Oyuncu darboğazı iş büyüklüğü ile ekip büyüklüğünün gösteriminden kendisi okumalı; cümleyle söylenmez.
- Kişi satırlarında "DMK" gibi yazı kısaltması yerine ikon. "Defne 2★ Test 04" gibi sıkışık gösterim kötü.
- Öneri kart sayımı değil kapasite diliyle: "X ve iki kart daha girer" değil "şu kadar SP daha alınabilir".
- Nedeni görünmeyen etiket olmaz ("Öncelikli" neden?). Tarih oyuncunun takvimiyle: "Sprint 17 sonu" değil "bu çeyrek sonu".
- Kart üstü dökümün içeriği iyi, sunumu fazla basit; yoğun ekranda font çirkin, hiyerarşi zayıf.
- Sprint ekranı dış maket ortamında tasarım skill'leri ve Erdem'in bulacağı repolarla baştan yorumlanacak.

**Why:** Ekran kalabalıklaşınca okunmuyor ve "AI slop" hissi veriyor; Erdem oyuncunun keşfetmesini istiyor.
**How to apply:** Yeni ekran ya da metin önerirken önce "bu satır ekranda mı olmalı, ipucunda mı?" diye sor; açıklama cümlesi
yerine gösterim (çubuk, ikon, sayı) kur. İlgili: [[feedback-design-research-first]] · [[ui-redesign-menajer-2026-10-02]]
