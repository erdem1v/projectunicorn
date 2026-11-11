# Görev: Olaylar ve playtest düzeltmeleri, Erdem'in 2026-11-11 kararları (OLAYLAR)

Oturum `project-unicorn-03` (dd6f551f). Yazan: yardımcı yönetmen (`co-director`), 2026-11-11.

## Başlamadan oku

- `project-unicorn/CLAUDE.md`, `docs/tasks/ORTAK_CALISMA.md` (önce §0).
- Hafıza: `erdem-kararlar-2026-11-11`, `feedback-papers-must-be-answered`, `feedback-event-option-quality`,
  `feedback-event-names-from-system` (2026-11-11 değişikliği dahil).
- Playtest raporu `docs/tasks/dizustu/raporlar/playtest_2026-10-28/RAPOR.md` ve `dogrulama.json`.

## Başlama koşulu

Hemen başla, ama kendi kopyanda. `kapi` kilidi yeniden kurma bitene kadar yardımcı yönetmende; commit'ler "YENIDEN-KURMA bitti"
mesajından sonra. `main.gd`'ye o mesajdan önce dokunma: harness düzeltmen (portreyi bekleyen `--event-shot`) yeniden kurmanın son
adımında senin kaydından geri kuruluyor, onu yeniden yapma. Pencereli koşu o zamana kadar `--screen 2`.

## Adımlar (her biri ayrı commit; sıra önerimdir)

1. **O-1, çeyrek bülteni (H01).** Kart 14. haftada geliyor. 15. haftada Cevapla'ya basınca "Bu kâğıdın konusu kalmadı" çıkıyor,
   kâğıt düşüyor ve bir daha gelmiyor. Neden: koşul (`time.quarter_start`) açılışta yeniden okunuyor
   (`quarterly_bulletin.json:43-45`, `:85`; `engine.gd:766-780`; `mail_pane.gd:540-542`). Kâğıt ömrü boyunca cevaplanabilir olmalı.
2. **O-2, Zor modda Reddet (H02).** Frank'in çekinde (`funding.frank_cheque`) Reddet "Zor modda açılır" diyor, ama
   `hard_mode_unlocked`'ı yazan kod yok. Erdem: "Zor modda gerçekten açılsın". Zor zorluk seçilince bayrak sahibin seam'iyle
   yazılır (`set_game_flag` beyaz listesi); yükleme ve kayıt uyumu korunur. Çekirdek mantık olduğu için bir smoke vakası uygun.
3. **O-3, kâğıt cevapsız geçmez (H07).** Erdem: "bu tarz eventlere yanıt zorunlu olmalı; oyuncu yanıt vermeden ne süre akar ne oyun
   akar".
   - Karar isteyen hiçbir kâğıt ya da kart görülmeden dolmaz, bedeli sessizce inmez.
   - En geç son anında saat tutulur (`hold_clock`) ve kâğıt açılır; olay kartı zaten böyle davranıyor.
   - `expires_weeks` taşıyan bütün kartları ve "dropped/expired" yollarını tara. Örnek vaka: `product.sprint_dev_backfill`,
     29. haftada geldi, sprint kapanırken görülmeden doldu.
   - Teknik kararı sen ver, bir paragrafla raporla. Oyuncunun yeni gördüğü bir metin olursa önce yardımcı yönetmene gönder.
4. **O-4, hiç gelmeyen kâğıtlar ve sıklık mekanizması (K19).** Erdem: "hiç gelmeyen kâğıt oyunda mutlaka olacaktır; neden
   gelmediği tespit edilmeli, hata mı randomluk mu".
   - Teşhis: `docs/tasks/dizustu/raporlar/olay_sikligi/`'deki 18 kâğıdın her biri için neden gelmediği (`--why-fire`,
     harness). Kanıtıyla: ulaşılamaz koşul mu, ağırlık ya da zar mı. Hatalar onarılır.
   - Mekanizma onarımı (Erdem "ilke ve mekanizma onarımı"nı seçti):
     - kâğıt zarı birinci haftada kapanan sprintte de atılır;
     - kâğıtsız sessizliğe bir üst sınır konur.
     
     Sayılar [WORKING] olarak "onay bekliyor" listesine girer.
   - CLAUDE.md §6'daki "en az üçte biri" cümlesi ilke ve tarihli ölçüm olarak yeniden yazılır. Erdem onayladı.
5. **O-5, olay fiilleri (K20).**
   - "Müşteri ekle" kalır: olay müşteriyi doğrudan ekler (Erdem, 26 Ekim'deki "olay imzalatmaz" kuralını bu fiil için kaldırdı).
     Yürütücü sahibin seam'inden geçer (WRITE-THROUGH); bir çip ve bir geçmiş satırı yazar. Fikstür kartıyla ve smoke'la
     kanıtla.
   - `convert_audience` ve `open_paid_tier` fiil listesinden ve GDD'den silinir (Erdem onayladı). Sözlüğü yeniden üret.
   - ACIK 14'ün durumunu güncelle.
6. **O-6, kart 7 "İkisi de gitsin" (K21).** İzin haftaları yerinde kalır, çip "izinleri çakışır" der (TR/EN onay bekliyor).
   Bugün öne çekiliyor. Kart 32 kabul, değişmez. "Kendi aralarında" şıkkı Erdem'e yeniden soruldu; ona dokunma.
7. **O-7, sessiz havuz sayacı.** "the floor has found nothing N times running" sayacı hiç sıfırlanmıyor
   (`engine.gd:397-404`). Doğru anda sıfırlansın.
8. **O-8.** `GOREV_OLAY_UYGULAMA.md`'deki "Dizüstü turu" notunu tamamla: commit'ler, playtest hataları, açık kararlar.

## Kurallar

- Kapılar CLAUDE.md §12: lint, loc_residue, loc_csv_integrity, hedefli smoke. Değişen kartların TR ve EN `--event-shot`
  kareleri rapora girer.
- Pencereli koşu `--screen 1` ya da `--screen 2`, asla ekran 0 değil.
- Commit başına en çok bir dar Opus incelemesi ve bir düzeltme turu. Push yok.
- Her commit'ten sonra yardımcı yönetmene "OLAYLAR <adım> <sha>" yaz. Bitince "hazır, son commit <sha>".
