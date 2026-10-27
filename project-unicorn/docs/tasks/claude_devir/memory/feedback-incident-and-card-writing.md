---
name: feedback-incident-and-card-writing
description: "Erdem 2026-10-16 (tur 2 yorumları) — acil olay sıklığı rastgele (en az 4 hf, düzenli asla), bedel olayın ölçeğinden türer (sabit $/% yok), karar kâğıdı yazım dili, kart tekrarı çok seyrek (EA 20 yıl), her faz görev yazısı → plan → onay → uygulama"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869
  modified: 2026-10-18T22:24:56.775Z
---

Tur 2 tasarımına verdiği yorumlardan kalıcı olanlar:
1. **Olay sıklığı rastgele.** "En fazla 4 haftada bir" taban; 8, 10 hafta da olabilir. Düzenli gelirse oyuncu bunalır ve
   "tasarlanmadığı ortaya çıkar".
2. **Bedel olayın ölçeğinden türer.** Olayda "212 sepet yarıda kaldı" yazıyorsa kupon o kullanıcılarla orantılı; sabit
   $4.000 ya da sabit "+%3 kitle" yazılmaz. Telafi oranları sektör normundan (SLA kredisi %10–20) araştırılır.
   Seçenekler olaya göre değişir; her olay aynı şık setini taşımaz.
3. **Yazım dili.** Doğal beyaz yaka Türkçesi, tam cümle; "Nadir ama para." gibi kesik vurgu yok; "yarısını kesersek" değil
   "yarısını önümüzdeki sprinte atarsak". Mantık çelişkisi yok ("muhasebe kapanışı iki gün erken yaptı" reddedildi).
   B2C ikizleri basit/cheesy olmamalı.
4. **Kart tekrarı çok seyrek.** EA'da oyun 20 yıl oynanabilir; aynı kâğıdı 4. kez görmek oyundan soğutur. 6 sprintlik
   engel yetmez; havuz büyük, koşu boyu hafıza.
5. **Süreç.** Her faz: görev yazısı (istenen, bugünkü akış, hedef akış, kararlar, araştırılacaklar; "şunu yap" listesi
   değil) → ajan araştırır ve plan yazar → Erdem'le değerlendirilir → uygulama.

6. **Çıta örneği (2026-10-19).** "Bir hafta geçer, remote çalışan yazar: Patron, işe alım görüşmesinde sormayı
   unuttum, bana iş bilgisayarı göndereceksiniz değil mi?" İlk kez kurucu olmanın doğal sürprizi, oyuncunun kendi
   durumundan doğar (ofis yok, çalışan remote), kasadan somut para çıkar. Erdem: "akıllıca tasarlanmış, jenerik değil,
   üzerine düşünüldüğü belli olan eventler bizi çok ileri götürür." Satış ve VC görüşmeleri de derin, çeşitli,
   tekrarsız olmalı; oyuncu başta satışta başarısız olabilmeli.

7. **Evrak işi olay değildir (2026-10-19).** ANA_RESIM'in 25 tohumu (avukat faturası, net/brüt maaş, depozito/kefalet,
   kod devir imzası, stopaj, faktoring) "rezil, tümü ret" dendi: "benim verdiğim örnekle bunlar bir mi". Yasak: hukuk,
   vergi, sözleşme, sigorta, finans terimi, oyuncunun araması gereken konu. Olay bir insanın ağzından, gündelik, oyuncunun
   bir önceki hamlesinden doğan, okununca "tabii ya" denen sürprizdir. Araştırma ajanına "kurucu gerçekleri" diye
   kaynaklı gerçeklik aratmak bu sonucu verdi; ton örneğini ajana değil kendin yaz, İncil §Olaylar'daki örnekler ölçü.

8. **32 taslağın yorumu (2026-10-23).** Şık sayısı serbest: tek şıklı olay da olur ("illa hepsinde 3 olsun diye kısıt yok").
   Kurucu (CEO) müşteriye bizzat gitmez; temsilciyi gönderir ya da telefonla arar. Düşük ihtimalli kumar şıkkı istenir
   (%15 gibi, %40–50 değil). Gönderen rolü olayın doğal sahibi olur (kaba müşteri → müşteri temsilcisi, verilen söz → PM,
   hastane → ekip arkadaşı; eşi patrona yazmaz). Uzun ve ayrıntılı metin en sık eleştiri; özel yer adı yok. B2C olayları
   pazaryeri için yazılır (not/video uygulaması kalkıyor). Görev ve aynen yorum: `docs/tasks/GOREV_OLAY_REVIZYON.md`.

**Why:** tur 2'de şıkların sabit sayıları ("$4.000 kupon", "−%40") ve kesik üslup "komik" bulundu; aynı tekrar eden
kart uzun koşuda oyunu öldürür.
**How to apply:** olay/karar kâğıdı yazdıran her görevde bu beş maddeyi görev yazısına koy. Bkz.
[[feedback-event-option-quality]] · [[feedback-step-table-model-roles]].
