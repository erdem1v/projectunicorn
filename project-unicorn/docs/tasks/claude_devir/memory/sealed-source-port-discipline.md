---
name: sealed-source-port-discipline
description: "Mühürlü kaynaktan pose/oryantasyon/materyal deltası portlarken BİLDİR — objenin okunuşunu değiştirir; port sonrası çıkan kusurda önce PORTU şüphelen, görünümü tedavi etme"
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 184c9fed-be7b-4ced-8777-2e12ecb0dd5b
  modified: 2026-08-17T16:57:01.009Z
---

2026-08-17, ODA mühürlü sanat turu. Erdem'i gerçekten sinirlendiren şey bir sabit değil, **aynı objenin tek oturumda üç kez değişmesiydi**: "brom neden lamba sürekli değişiyor bana bunun cevabını verir misin?????????"

**Ne oldu.** Mühürlü `office-room.html` lamba başını ışık havuzuna nişanlıyordu (`lampHead.quaternion.setFromUnitVectors(...)`, yorumu "baktığı nokta = ışığın düştüğü nokta"). Onu "mühürlü sanatı entegre et" kapsamında geometriyle birlikte SESSİZCE portladım. O nişan ağzı kameraya çevirdi, yani **aydınlanmayan iç yüzey objenin en büyük görünen yüzeyi oldu** ve lamba gündüz biçimsiz bir siyah kütle ("kapüşonlu göz") gibi okundu. Erdem şikâyet etti. Ben BELİRTİYİ tedavi ettim: içe krem astar koydum, profili spline'a çevirdim, ampulü indirdim. Sonuç: lamba siyah olmaktan çıktı — Erdem'in asıl istediği şeyi kaybettim. Doğru düzeltme nişanı geri almaktı; astar ve spline benim icadımdı, mühürlü kaynakta yoktu, ikisi de silindi ve `REGIONS.lamp` ilk assetin `(219,1308,200,494)` değerine BİREBİR döndü.

**Why:** İki ayrı hata var ve ikisi de tekrar edebilir. (1) Bir kaynak-delta **pose/oryantasyon/materyal** değiştiriyorsa objenin OKUNUŞUNU değiştirir — bu bir tasarım kararıdır, geometri güncellemesi değil; "mühürlü kaynağı entegre ediyorum" onu sessizce almaya izin vermez. (2) Bir kusur portun HEMEN ARDINDAN çıktıysa o tesadüf ipucudur; transform'u kontrol etmeden materyale uzanmak bana iki fazladan tur ve yönetmenin güvenini kaybettirdi. Ayrıca churn'ün kendisi bir maliyettir: aynı objeyi üç kez değiştirmek, üçüncüsü doğru olsa bile, yönetmene "bu iş kontrolsüz" hissi verir.

**How to apply:**
- Kaynak-delta tablosu çıkarırken satırları İKİYE ayır: **ölçü/konum** (sessizce portlanır) ve **pose/oryantasyon/materyal/ışık** (BİLDİRİLİR, gerekirse onay alınır). Nişan/rotation/`side`/emissive bu ikinci kümededir.
- Port sonrası ilk kusurda sorulacak ilk soru: "bu portla mı geldi?" Cevabı ölçmek için **rollback snapshot'ından ÖNCE/SONRA yan yana koy** — 2026-08-17'de eski katmanı eski plakaya kompozitleyip üç nesli Erdem'in ekran görüntüleriyle yan yana dizmek teşhisi dakikalar içinde kanıtladı (ve Erdem'in gönderdiği görüntülerin "ilk asset" değil BENİM güncel render'ım olduğunu ortaya çıkardı — bu varsayılsaydı yanlış yöne gidilirdi).
- Bir objenin görünümünü ikinci kez değiştirmek üzereysen DUR ve önce ilk değişikliği geri almayı değerlendir. Üçüncü varyant neredeyse her zaman yanlış katmanda çalıştığının işaretidir.
- Kusuru "üç bağımsız sebep" diye çözümlediğinde şüphelen: üçü de aynı tek değişiklikten türüyor olabilir. 2026-08-17'de kırışıklık + karanlık iç + patlamış ampul diye üç sebep saydım; üçü de tek bir nişan bloğunun sonucuydu.
- Defteri düzeltmeyi unutma: yanlış teşhisi kaydeden bölüm SUPERSEDED işaretlenir ve doğru sebep yazılır, yoksa bir sonraki kişiye yanlış dersi öğretir ([[project-unicorn-current-stage]]).

İlgili: [[concurrent-session-hazard]], [[godot-import-cache-gotchas]], [[design-work-lessons]]
