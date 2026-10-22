# Faz B adım defteri (R'nin girdisi; commit'lenmez)

## B1 · `05966f3`
**Başlık:** Faz B B1: Mail, kâğıt, not, hatırlatıcı ve Frank'in satırı gece 00:00'da değil, şirketin mesai penceresinde çekilmiş bir geliş saatinde gelir; gelen kutusu satırı ve kart başlığı bu saati ss:dd yazar, şema 17 (sabitler onay bekliyor)

### Kabul
PRD §4.4 (00:00 mailleri), §4.9 (kapılar), §4.10 (görsel; gelen kutusu saatleri):

4.4-a Her öğe geliş saatini taşıyor (mesaj, kâğıt, karar kartı, geçmiş satırı, hatırlatıcı): ✅ inbox.gd: _message_item `at` (m.at), _paper_item (p.at), active_item (EventGate.active_at → EvQueue._active_at), _history_item (row.at), _reminder (MailClock.reminder_at). Tek kenar: hatırlatıcının durumu gün içinde doğup bir sonraki saatlik sync_desk'e kadar (en çok 1 oyun saati) saatsiz listelenir.
4.4-b Ekranda şimdiki saat yerine damga: ✅ mail_pane.gd:122'deki `GameState.current_hour` satırı silindi, `_mail` başlığı INBOX.date_text(day, _item.at) okuyor; events_tab.gd:269-270 liste satırına clock_text(at). Kareler: TR 09:30'da "Hafta 15 · Nisan 2026 · 09:00", 13:30'da "· 12:00"; liste 10:00/12:00/11:00/09:30 (inbox_shot_morning*.png, TR ve EN aynı).
4.4-c Damga görüldüğü andan ileride değil: ✅ _audit_stamps her saat `shown` listesinde at > now arıyor (endgame_smoke `_case_inbox_no_night_stamp`), SMOKE PASS.
4.4-d Acil olmayan öğe pencere içinde damgalanıp o saatte teslim: ✅ inbox_no_night_stamp 104 hafta × iki pencere (08-17, 11-24) PASS. Falsification: kod ajanının b1_falsify_f1.log'u "754 stamp(s) outside the workday, first: message summary summary:6:0 stamped 00:00 on tick 6"; vaka ayrıca kendi içinde instant=true kontrol koşusu yapıyor ve FAIL'i yakalamazsa düşüyor.
4.4-e Bildirim yığınındaki hatırlatıcı ve Frank'in satırı mesaide: ✅ office_notice_stack.gd:101 `MailClock.delivered(GameState.mentor_line_at)`, desk() yalnız gelmiş hatırlatıcıları veriyor; vaka desk_arrivals ve mentor_line_at'i denetliyor. 13:30 karesinde yığın Nordica/Kuzey/Selin satırlarını gösteriyor.
4.4-f Bekleyen öğeler kayda girer: ✅ mail_pending_survives_save PASS (dış kutu, kuyruk, kâğıt, hatırlatıcı, Frank'in satırı; saatler kayıttan aynı dönüyor). ⚠️ Kenar durum: EvEngine._unannounced kaydedilmiyor, bu yüzden yüklemeden sonra bekleyen not yeniden doğrulanmadan listeleniyor (geçmiş satırı ve `at` kayıtlı).
4.4-g Şema +1, eski öğeler saatsiz: ✅ save_manager.gd:16 SCHEMA_VERSION 17. Göç yok; get("at", -1). Vakanın eski kayıt kolu `at`'ı silip yüklüyor, kuyruk ve masa görünür kalıyor.
4.4 Kanıt `--inbox-shot` "gece sonrası sabah": ✅ main.gd `_morning_frames`, 00:00 + 09:30 (+13:30), TR/EN; MORNING satırlarındaki her damga pencerenin içinde, yalnız acil giriş notu 08:00.
4.9 Kapılar: ✅ lint PASS 0 error; loc_residue CLEAN (csv_keys=3318); loc_csv_integrity PASS; plausibility runs=40 fires=421 fails=0, LONG runs=4 fires=345 fails=0; run_gate 3/3 ok; harness 3×26 PASS; sprint-probe match=5/5. Yeni kart olmadığı için --why-fire yok. ⚠️ Ekonomi kayması raporlanmadı (önceki bitiş günleriyle karşılaştırma yok). Notların yeniden doğrulanması fire sayısını 457'den 421'e, "nothing" haftalarını 252'den 291'e çıkardı.
4.10 Görsel (gelen kutusu saatleri): ✅ 6 PNG'yi açtım. Damgalar sağa hizalı ve Caption stilinde; TR ve EN'de taşma ya da kesilme yok. 00:00 karesinde gece yığını yok.
§9 incelemesi: MailClock kısa ve tek evli. EvDice.unit, WorkHoursSystem.company_window ve TimeManager.day_minute yeniden kullanılıyor. Onay bekleyen iki sabit tek yerde ve [WORKING] işaretli. Write-through tamam: mail_outbox'a yalnız MessageSystem, desk_arrivals'a yalnız MailClock yazıyor. UI'da ham renk ya da boyut yok (UiTokens.SPACE_M, &"Caption"). Ölü kod yok: DESK_SCAN ve item.hourly silindi. Bu adımda onaylı metin bağlanmadı, CSV'ye dokunulmadı.

### Onay bekleyen
Sabitler [WORKING, onay bekliyor]: MailClock.SPREAD_HOURS = 4 (geliş saati pencerenin ilk 4 saatinden), MailClock.SHORT_LIVED_SPREAD_HOURS = 1 (expires_weeks <= 1 kâğıt pencerenin ilk saatinde gelir).
Erdem'e sorular:
(R9) Dönem özeti ve ilk Ar-Ge notu artık teslim anında, öğleye yakın bir saatte gelen kutusunu kendiliğinden açıp saati durduruyor. Bu istenen davranış mı?
Notların teslimde yeniden doğrulanması bazı sessiz notları hiç göstermiyor. Fire 457 → 421, boş zemin ("nothing") haftaları 252 → 291 (40 koşu). Mandal iade edilmiyor.
Haber bandının bekleyen canlı satırı kayda girmiyor.
Sistem menüsündeki tarih artık dakika gösteriyor.
ACIK_KARARLAR 78 fiilen B yönünde kapandı ama dosya güncellenmedi.
Ekonomi kayması (bitiş günü karşılaştırması) ölçülmedi.
Yeni TR/EN metin yok.

### Sabitler (kod ajanı)
- MailClock.SPREAD_HOURS 4 [WORKING, onay bekliyor]: geliş saati pencerenin ilk 4 saatinden çekilir
- MailClock.SHORT_LIVED_SPREAD_HOURS 1 [WORKING, onay bekliyor]: expires_weeks <= 1 kâğıt pencerenin ilk saatinde gelir, haftası kısalmaz

### Metinler (kod ajanı)


### Riskler
- R9 ⚠️ (sürer): dönem özeti ve ilk Ar-Ge notu artık teslim anında gelen kutusunu kendiliğinden açıp saati durdurur (main._open_note, _on_summary_ready, _on_product_note_issued); gece yarısı değil mesai içinde, çoğunlukla öğleye yakın. Tasarımın istediği bu olabilir; Erdem'e sorulmalı. Koda dokunulmadı.
- R10 kapsam dışı: sprint planının 08:00 tutuşu (kapı mail değil, günü başlatma eşiği). Sol rayın rozet sayaçları (attention_count, durumdan okunur) ve ofis taşıma toast'ı geliş saatini beklemez.
- Notların teslimde yeniden doğrulanması (PRD 4.4 ile uyumlu, plausibility kapısı için şart): oyuncunun sabahki hamlesi dünyayı taşıdıysa not `dropped` olur, mandal iade edilmez, arkın adımı ve aile freni yazıldığı anda işlenmiş kalır (kuyrukta düşen kartla aynı). Ölçüm (40+4 koşu): PLAUS fire 457 -> 421, PLAUS RATE toplamında nothing 252 -> 291, empty 245 -> 245; yani bazı sessiz notlar artık hiç görünmüyor ve boş zemin haftaları arttı. _unannounced kaydedilmez: kayıttan dönen bekleyen not yeniden doğrulanmadan listelenir (kenar durum).
- Şema 17 göçsüz; `if version < 17` EKLENMEDİ. Eski kayıttaki öğe saatsiz (at -1) açılır ve her zaman gösterilir (mail_pending_survives_save eski kayıt kolunu da sınar).
- 00:00 saatlik dilimi advance_day()'den önce koşar: is_rolling_over() doğruyken MailClock.now() yeni tiki sayar (ilk smoke koşusu now()'ın geriye gittiğini yakaladı); bayrak advance_day'den ÖNCE temizlenir. hourly_tick(0) normal çalışır.
- MailClock.instant harness bayrağı: EndgameSmoke.run_case doğru kurar, gerçek saati süren teslim saati vakaları kapatır; _sim_day ve _sim_day_full çağıranları değişmedi. Yeni bir smoke vakası instant'ı kapatmadan geliş saatini sınayamaz.
- Kuyruk girdisinin `urgent` alanını yalnız smoke okuyor; B3'ün gece kapısı aynı süzgece (EvQueue._shown) eklenecek, ikinci bir süzgeç yazılmayacak. `urgent` etiketini henüz hiçbir kart kullanmıyor.
- ACIK_KARARLAR 78: fiilen B seçeneği yönünde kapandı ama dosyaya dokunulmadı.
- Sistem menüsü tarihi artık dakika gösterir (eskiden tam saat). Haber bandı canlı satırı geçici dinleyici bekletmesidir (kayda girmez): pencere dışında yüklenen oyunda bekleyen satır kaybolur.
- Bot/ekonomi kayması: kartlar 09:00-13:00 arasına dağılır; run_gate 3/3 (errs=0) ve plausibility fails=0, ancak önceki bitiş günleriyle karşılaştırma yapılmadı (karar ya da sabit değişikliği yok).
- Tam smoke süiti koşulmadı (görev gereği); etkilenen 78 vaka tek tek PASS, ancak bunların 66'sı _rolling_over temizleme sırasının tek satırlık düzeltmesinden ÖNCEKİ kodda koştu; düzeltmeden sonra 12 vaka, run_gate, plausibility, harness, sprint-probe ve iki ekran yeniden koşuldu. Haiku'nun kapı koşusu listenin tamamını son kodda tekrarlar.

### İnceleme düzeltmeleri
Tek tur, yalnız belge; koda dokunmadım:
1) docs/ACIK_ISLER/ISLER.md: "Kâğıt masada mı okuması yok … DESK_SCAN (64)" maddesini sildim. Bu adım EventGate.on_desk'i kurdu ve DESK_SCAN'ı sildi, madde bu yüzden kapandı. CLAUDE.md §9 "yerini alan eskisini aynı commit'te siler".
2) GDD OLAY MOTORU §27.27: "saat 08:00'de yazılmış bir not" yanlıştı, "00:00'da yazılmış bir not" yaptım. Notlar günlük tikte yazılır.
Kod değişmediği için yeniden koşulacak kapı yok. Bakıp dokunmadığım, kabul edilebilir bulduğum noktalar: main._morning_frames TimeManager._in_game_hours'a yazıyor (debug fikstürü); clock_text top_bar'daki "%02d:%02d" ile küçük bir ikizlik; eski kayıt gece yüklenirse türetilmiş hatırlatıcılar ilk saatlik sync'te sabahki pencereye kayıp o zamana kadar görünmüyor (B0t "-1 ile açılır" önerisi uygulanmadı, zararsız).

## B2 · `f4a623b`
**Başlık:** Faz B B2: Olayın bedeli olaydan türer. Tutar seam'den okunabilir ve çip, geçmiş satırı ile bot aynı sayıyı okur. Ertelenen hata hesabın memnuniyetine kalıcı iz bırakır, düzelene kadar her sprint sonunda bir bedel daha yazar. Gece düzeltmesinin moral bedeli Karar 6'daki ödeyenlere düşer ve çip onları adıyla gösterir. Memnuniyet çipi oyuncunun bir tik sonra okuyacağı sayıyı yazar ("Ege Sigorta: memnuniyet 38 → 35"). TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
B2'nin payına düşen PRD §4 maddeleri:

§4.2 Bedel, "her bedel çipteki sayıyla aynıdır" (B2'nin fiilleri için): ✅
- Seam tutarı: event_amount_seam PASS. Çip, geçmiş satırı, kasa (−840) ve RunProbe._cash_delta_of aynı sayıyı veriyor; on_expire işaret denetimi çarpandan okunuyor (effects.gd amount() ve _is_negative).
- Güven izi: event_trust_delta_lasting PASS. −6, −8 ve −3 için çipteki "to", bir tik sonra oyuncunun okuduğu değere eşit. Defter iz tutuyor. Süren bedel gerçek sprint kapanışında yazılıyor (sprint_system.gd _close → B2BSalesSystem.charge_trust_drains), hattı düzelten sprintte yazılmıyor, step_live ile bitiyor, kayıtta gidip dönüyor, eski kayıtta boş açılıyor.
- Moral: event_morale_payers PASS. Moral gerçekten düşüyor, kurucununki düşmüyor, çip ile geçmiş satırı eşit.
- Kredinin %10–25 olması, mrr'nin değişmemesi ve B2C orantısı B3/B4'ün kartlarında; B2'nin kapsamı dışında.

§4.6 Bedeli ödeyen: ✅
- Karar 6'nın sırası tek fonksiyonda: sprint_system.gd payers(). Küme 1 = hattın kartlarındaki atananlar, ahead olmayanlar, kurucu hariç. Küme 2 = team() eksi kurucu. İkisi de boşsa [] döner.
- event_morale_payers üç durumu da kanıtlıyor: küme 1, küme 2 (hatsız olay dahil) ve boş ekip.
- Atama değişince çipteki adlar değişir: çip adları her seferinde crew_of → payers'tan kuruyor; vaka da assignees değişince ödeyenlerin değiştiğini kanıtlıyor.
- "Yalnız Destek'e atanmış kişi ödemez": inceleme turunda vakaya eklendi ve PASS. Falsification yapıldı: team() Destek'teki kişiyi alınca vaka "payers read [..char_pay_sup..]" diyerek FAIL verdi. Bozma geri alındı, sprint_system.gd farkı yine yalnız +20 satır.
- paper_speaker_is_assignee B5'in işi.

§4.7 Tahmin ile sonuç: ✅ --sprint-probe=hours=8:cards=2:ticks=12:events=1 çıktısı "SPRINTPROBE SUMMARY|match=5/5", adsız uyuşmazlık yok.

§4.9 Kapılar (B2'nin payı): ✅
- --event-lint: "LINT PASS 0 error(s), 0 warning(s), 13 baselined, 98 card(s)". Düzeltmeden sonra yeniden koşuldu.
- loc_residue CLEAN, loc_csv_integrity PASS.
- why-fire için yeni oyun kartı yok, yalnız fikstür var.
- plausibility ve run_gate B3 ile sonraki adımların kapısı.

§4.10 Görsel kabul (çipler): ✅ b2b_shot_chips.png ve b2b_shot_chips_en.png açıldı.
- TR: "Ege Sigorta: memnuniyet 38 → 35", "Deniz, Elif, Selin: moral -10", "38 → 33", "Düzelene kadar her sprint sonunda memnuniyet -3".
- EN karşılıkları doğru.
- Her seçenek tek satır; taşma ya da kesilme yok.

Onaylı metnin bağlanması: ✅ textparity PARITY checked=8 missing=0. strings.csv'deki dört W1 anahtarı TR ve EN'de bayt bayt eş; satırlar byte-span ile eklenmiş (diff +5 satır).

Kapı raporundaki tek kırmızı yanlış alarm: _vocabulary.md farkı tam olarak B2'nin değişikliği (fiil 63→65, writer 31→33, kart 97→98, eklenen satırlar morale_crew ve trust_delta). Başka fark yok.

§9 incelemesi:
- HARITA'daki yardımcılar yeniden yazılmamış. set_trust_offset, line_accounts, apply_delta ve _forgiven_trust/_drift ortak kullanılıyor; sıralama lambdası larger_account'a çıkarılmış ve iki yerde kullanılıyor.
- Write-through kuralına uyulmuş: memnuniyet izi set_trust_offset'ten, moral apply_delta'dan, süren bedel tek yazıcı B2BSalesSystem'den geçiyor.
- Ölü kod yok: eski _amount silinmiş.

Bu turda yaptığım düzeltmeler:
- NAMES_SHOWN'a [WORKING] işareti eklendi.
- Lint'in O3 ve O4 kuralları yeni fiilleri yanlış okuyordu, düzeltildi.
- Destek kuralı smoke vakasına eklendi.

### Onay bekleyen
Onay bekleyen sabitler:
- EvChips.NAMES_SHOWN = 4 [WORKING]: dört kişiyi geçen listede ilk iki ad, sonra "ve {n} kişi" (B0_ESIKLER).
- B2 yeni oyun sabiti getirmiyor. Kullanılan var olan değerler: TRUST_OFFSET_DECAY_PER_DAY 0,4 (haftada 2,8), SAT_DRIFT_STEP 3 (tikte en çok 21), TRUST_OFFSET_MIN/MAX −25/+10.
- Karar 8'in değerleri (−6, sprint başına −3) ve Karar 6'nın değerleri (−10/−7) B3/B4'ün kartlarında ve sprint.json bloklarında girecek.

Onay bekleyen metin:
- EFFECT_NAMES_MORE "ve {n} kişi / and {n} more": yeni metin, W dalgalarında yok.
- W1'den bayt bayt bağlanan dört anahtar: EFFECT_TRUST_ACCOUNT, EFFECT_TRUST_ACCOUNTS, EFFECT_NIGHT_CREW, EFFECT_TRUST_PER_SPRINT. Erdem'in "şimdilik onaylı say" kararıyla bağlandılar, sabah elden geçecekler.

R'ye giden sorular:
1. Ödeyenlerin küme 2'si harfiyen tasarımcı ve PM'i de içeriyor; kurucu iki kümeden de çıkarıldı. Erdem küme 1'de kurucuyu saymak isterse not edildi.
2. −3, −2 ve −1'lik izler çipte "58 → 58" görünür. Ayrıca hedefin dışında yürüyen bir hesapta çipin "to"su sürüklenmeyi de içerir, yani bedelin kendi payı değil görünecek sayıdır. Eşik C'de ölçülürken bu da birlikte ölçülsün mü?
3. Moral çipi nominal miktarı yazar; kişi başı huy çarpanı (scaled_delta) çipte görünmez.
4. Süren bedelin bitişi sinyalle değil, kapanıştaki durumla okunuyor (line_bugs == 0 ya da is_feature_live).

### Sabitler (kod ajanı)
- EvChips.NAMES_SHOWN = 4: dört kişiyi geçen ad listesinde ilk iki ad + EFFECT_NAMES_MORE (B0_ESIKLER'deki öneri; onay bekliyor)
- Yeni oyun sabiti yok. Kullanılan var olan değerler: TRUST_OFFSET_DECAY_PER_DAY 0,4 (haftada 2,8 affedilir), SAT_DRIFT_STEP 3 (tikte en çok 21), TRUST_OFFSET_MIN/MAX −25/+10. Karar 8 değerleri (−6, sprint başı −3) ve Karar 6 değerleri (−10/−7) kodda değil, B3/B4'ün kartlarında ve sprint.json bloklarında girecek
- R soru 1: ödeyen küme 2 harfiyen tasarımcı ve PM dahil (cevaba kadar böyle)
- R soru 2: −3, −2, −1 izleri çipte '58 → 58' görünür; sayılar C'de eşikle birlikte ölçülsün mü
- Kurucunun moral ödeyip ödemediği: kurucu iki kümeden de çıkarıldı (HRMoraleSystem.apply_delta kurucuyu zaten yok sayıyor); Erdem'in küme 1 tanımında kurucuyu saymak istemesi ihtimali için not

### Metinler (kod ajanı)
- EFFECT_NAMES_MORE: tr 've {n} kişi', en 'and {n} more' (YENİ metin, TR/EN onay bekliyor)
- EFFECT_TRUST_ACCOUNT, EFFECT_TRUST_ACCOUNTS, EFFECT_NIGHT_CREW, EFFECT_TRUST_PER_SPRINT: W1'den bayt bayt bağlandı, 'TR/EN onay bekliyor' (Erdem 2026-10-17 00:10: dalgalar onaylı sayılır, sabah tek tek elden geçecek); commit mesajına eklenmeli
- fixture.b2_chips kartının TR/EN metni yalnız test içeriği (fixture), oyuncuya hiç gösterilmez

### Riskler
1) 'incident' kaynağı yok: trust_delta accounts ve morale_crew line/until için 'incident' (olayın hesap listesi, olayın hattı, gece vardiyalı/öbür hesap ayrımı) IncidentSystem durumuna bağlı ve o durum B3'te doğuyor; B2 yalnız slot, decision_line ve düz kimlik ya da 'decision' belirtecini uygular. B3/B4 bu kaynağı EvEffects.trust_accounts, crew_of, _of_decision'a ve lint'teki TRUST_ACCOUNTS/MORALE_CREWS listelerine ekler (arayüz bu noktada genişlemeye hazır, kod değişikliği tek match kolu). 2) Çipin 'to'su bir tik sonra oyuncunun okuyacağı değerin TAMAMI: hesap hedefinde duruyorsa yalnız iz+affetmedir (−6 → −3), hedefin dışında yürüyorsa normal sürüklenme de girer (ilk çekimde fikstür hesabı 70'ten düşük hedefe 21 yürüdüğü için '70 → 35' çıktı; çekim hesabı hedefe oturtularak düzeltildi). Yani açık hatalı, düşmekte olan bir hesapta çip bedelin tamamını değil görünecek sayıyı gösterir; bedelin kendi payını göstermek isteniyorsa tasarım kararı (R). 3) Süren bedelin bitişi sinyalle değil durumla okunur: B0v 'EventBus.line_bugs_cleared' dedi; kapanışta ProductState.line_bugs(hat) == 0 ya da is_feature_live okunur. Aynı kapanışta düzelen hat ücret almaz (smoke kanıtlı); kapanışlar arasında düzelip yeniden hata alan hat sinyal yolunda biterdi, burada sürer. Kayıt/yükleme sinyal bağlantısına ihtiyaç duymaz. 4) Moral çipi nominal miktarı yazar (change_morale gibi); kişi başı huy çarpanı (HRMoraleSystem.scaled_delta) kişiye göre ayrışabilir, çip kişi başı etkili sayıyı göstermez. 5) Kapsam sınırı: 'ödeyen kaybı' (EFFECT_PAYING_USERS) için fiil yazılmadı, W18/R soru 3 cevabını bekliyor; 'incident' bilgi çipleri (EFFECT_TRUST_NIGHT_ACCOUNTS, _OTHER_ACCOUNTS) B3'ün. 6) card_crew bugün yalnız bekleyen karar kartının atananlarını okur; B7'nin söz kartı karar kartı olmadığı için onun kart kimliği yolu B7'de eklenecek. 7) project.godot sahipsiz farkı (editörün yeniden kaydı) başlangıçtan beri var, dokunulmadı. tools/__pycache__, themes, docs/mockups, docs/tasks/PRD_* dokunulmadı. 8) glyph_audit (CLAUDE.md, kapı değil) '→' için BarlowCondensed-SemiBold'da eksik bildirir; bu var olan HR_HOURS_SPRINT_POINTS gibi anahtarlarda da var ve çipler gövde yüzünde doğru çiziliyor (çekimde görüldü).

### İnceleme düzeltmeleri
1. chips.gd: `NAMES_SHOWN := 4` onay bekleyen bir sabit ama [WORKING] işareti yoktu. `# [WORKING]` eklendi (yürütücü notu §2, CLAUDE.md §2).

2. lint.gd `_touched_slots` (O4): yeni fiiller kartın slotuna düşmüş sayılıyordu. morale_crew'in incident_crew/card_crew'u ve trust_delta'nın decision_line'ı kartın ilk employee/customer slotuna düşmüş sayılıyordu. Böylece konuya hiç dokunmayan bir seçenek O4'ten kaçabiliyordu. Artık yalnız speaker ve slot hesabı slota düşmüş sayılıyor.

3. lint.gd O3: tek kişilik kartta ekibin moralini harcamak morale_all için yasaktı, ama aynı şey morale_crew ile (speaker dışında) bu kurala hiç takılmıyordu. Kurala dahil edildi. Bugünkü katalogda bu fiili kullanan kart yok (fikstürler v3 lint'inden muaf), lint yine PASS.

4. endgame_smoke.gd event_morale_payers: PRD §4.6'daki "yalnız Destek'e atanmış kişi gece düzeltmesinin bedelini ödemez" maddesi kanıtsızdı. Vakaya yalnız Destek işini tutan bir customer_rep eklendi: ödeyenlerde yok ve morali değişmiyor. FALSIFICATION yorumu güncellendi. Falsification koşuldu (FAIL) ve geri alındı.

Düzeltmeden sonra koşulanlar:
- --event-lint PASS (98 kart).
- event_morale_payers, event_lint_v3_rules, event_chip_coverage, all_scripts_load: hepsi SMOKE PASS, Parse/Compile/Failed to instantiate satırı yok.

Düzeltmeyip not ettiğim yer: trust_delta ya da morale_crew'un hedefi canlı durumda boşsa (B2C slotu, hattı kullanan hesap yok, ödeyen yok) çip ": memnuniyet 0 → 0" ya da ": moral -10" gibi adsız çıkar. event_chip_coverage çipi boş ctx ile istediği için bu davranış korundu. Kilit ve geçit B3/B4'ün kartlarında kurulmalı. Kilitli satırda çip gösteriliyorsa B3 bunu görsel kabulde denetlemeli.

## B3 · `7e168aa`
**Başlık:** Faz B B3: Gece kesintisi artık bir sistemin zarıdır. Servis gece 00:30 ile 04:30 arasında çöker, kart ilk tam saatte açılır ve saat cevaba kadar durur. Gece yalnız acil durum kartı görünür, öbür kartlar ve kâğıtlar mesai başına kadar bekler. Kesinti kartının dört cevabı vardır (B2B ve B2C ayrı): ekip şimdi düzeltsin, kendin düzelt, sabah düzelt ve kredi ya da ücretsiz ayla sabah düzelt. Çip servisin açılacağı saati, B2B'de hesapların aylık ücretine göre %10/%15/%25 kesinti kredisini ve giremedikleri saatin memnuniyet izini, B2C'de kitle kaybını gösterir. Kademe çarpanları sahibin onayıyla yerel 1,0, bulut 0,5, kurumsal 0,25. Eski product.outage kalktı. TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
B3'ün PRD §4 maddeleri:

§4.1 Olay aralığı (smoke): ✅ incident_gap_and_spread (endgame_smoke.gd, _case_incident_gap_and_spread). 300 haftalık koşu, 12 açık hata, onaylı kademelerle yeniden koşuldu:
- local: 46 olay, en küçük aralık 4, 4–6 dışı 18/45 (%40)
- cloud: 33 olay, 22/32
- enterprise: 19 olay, 15/18
Satır: `SMOKE PASS incident_gap_and_spread`. 104 hafta × 10 tohum raporu bu adımın işi değil, B6b'nin.

§4.2 Bedel (B3 payı): ✅ incident_scale.
- Kredi üç basamakta doğru: %10, %15, %25 × hesapların MRR toplamı.
- Kasa yalnız kredi kadar azalıyor, `outage_credit` defter satırı tek, `get_total_mrr` değişmiyor.
- Çip ile geçmiş satırı aynı metni okuyor.
- Güven izi: gece vardiyası −6, öbür hesaplar −2, kredide −1.
- B2C kitle kaybı süreyle orantılı ve %4'te kesiliyor; ücretsiz ay = ödeyen × fiyat, `refunds` etiketiyle.
`SMOKE PASS incident_scale`.

§4.3 Gece (falsification ile): ✅ incident_night_hold_resumes.
- 00:00'da istek ve gösterim yok.
- Kart ilk tam saatte açılıyor, damgası o saat, `incident` tutuşu var.
- Süresi dolmak üzere olan kâğıt (RETAIN_ID) kuyrukta beklerken açılan kart acil durum kartı.
- Cevaptan sonra 08:00'e kadar hiçbir kart açılmıyor; bekleyen kart mesai başında açılıyor.
- Gönderen Yapım işindeki yazılımcı; ekip yoksa "Sunucu uyarısı".
Üç mutasyonla düşürüldü (ajanın kanıtı). `SMOKE PASS incident_night_hold_resumes`.

§4.4 Saatler: ✅ (B1'in alanı) inbox_no_night_stamp gerçek zar açıkken yeniden geçti: `SMOKE PASS inbox_no_night_stamp`. Acil kartın damgası açılış saati.

§4.6 Gece düzeltmesinin bedelini ödeyen: ⚠️
- `olay.payers` → `SprintSystem.payers("")`; kural B2'nin.
- Çip adları gösteriyor ("Deniz, Elif, Selin: moral -10"). event_morale_payers PASS.
- Kümeye tasarımcı da giriyor; R soru 1 açık.

§4.7 Prob: ✅
- `incident=outage@8` ve `market=b2b` dize olarak ayrıştırılıyor.
- Haiku adım 16: `PROBE PICK day=8 id=product.incident_outage_b2b`.
- "Sprinti durdur" ve "Testi kısalt" B4'ün kartlarında olduğu için burada yok.

§4.9 Kapılar:
- `--event-lint`: ✅ `LINT PASS 0 error(s), 0 warning(s)`; bu turda yeniden koşuldu.
- loc_residue: ✅ temiz. loc_csv_integrity: ✅ PASS.
- `--why-fire`: ✅ iki kart da "G4 tick:request" der. Kart yalnız IncidentSystem'den istenir; bu bir hata değil, beklenen sonuç.
- plausibility: ✅ 40 koşu, 0 fail.
- run_gate: ✅ 3/3, sıfır ERROR.

§4.10 Görsel: ✅ PNG'leri açtım.
- B2B TR/EN ve B2C TR/EN kartlarında taşma yok; 3 satırlık çip yeni iç boşlukla kenara değmiyor.
- Saat çubuğunda "CEVAP BEKLİYOR · Sunucu uyarısı 02:00" yazıyor.
- Gece gelen kutusu: Haiku'nun ❌'ı yanlış okuma. "İlk sabah" satırı Hafta 1 · 08:00'de teslim edilmiş eski bir mektup. NIGHT satırında shown=0, bekleyen müşteri uyarısı listede yok.

Bayt eşliği: ✅ textparity W1 58/58 ve 44/44, eksik yok.

§9 incelemesi:
- Write-through doğru: güven `CustomerRegistry.set_trust_offset`, kredi `FinanceSystem.apply_one_time_cost`, kitle `SalesSystem.add_b2c_audience`, kesinti kaydı `SprintSystem.record_interrupt`.
- Ham renk ya da boyut yok (`UiTokens.SPACE_M`).
- Yeniden yazılmış yardımcı yok: `clock_text` MailClock'a taşındı, eski kopya silindi.
- Bir sapma ve iki küçük kusur bulup düzelttim (fixes_tr'de).

### Onay bekleyen
Onay bekleyen sabitler (data/product/sprint.json `incident`, [WORKING]):
- Taban ve sınırlar: base 0,10; bug_cap 12; bug_div 8; p_max 0,30 (onaylı kademelerle artık bağlamıyor, en yüksek p 0,25); min_gap 4 (kural Erdem'in); launch_quiet 3 hafta; load_mult 1 (C'ye kadar).
- Kesintinin başlaması: start 00:30–04:30, adım 10 dk; B2C min_audience 1000.
- Düzeltme süresi: fix_hours 3; crew_base 0,75; crew_per_star 0,125; founder_slower 1,5; fix_step 10.
- Hesaplar: night_sectors logistics/manufacturing/health; day_start 08:30; kredi [[0,%10],[7,%15],[12,%25]].
- Memnuniyet izi: trust_per_hour 0,6; trust_cap 8; credit_forgives 0,85.
- B2C: try_share_hour 0,015; loss_per_hour 0,003; loss_cap 0,04; free_month_loss 0,5.
- Kart sabitleri: gece düzeltmesi moral −10; "Kendin düzelt" verim −%15 · 1 hafta, kilit hr.headcount <= 2; expires_weeks 1; family cooldown 26.

ONAYLI (onay beklemiyor): tier yerel 1,0 · bulut 0,5 · kurumsal 0,25.

Onay bekleyen metin:
- W1 kartları ve çipleri (bayt bayt bağlandı).
- Türetilmiş tekil EN `EFFECT_OUTAGE_CREDIT_ONE`: "Outage credit · {n} account · {pct}% {v}" (W1'de yok, Fmt.count_key kuralından).
- MAIL_SENDER_SERVER_ALERT.
- FIN_ONETIME_OUTAGE_CREDIT.

Sahibe açık sorular:
- (R soru 10) Kepenk kartı ve son uyarı da mesai başına kadar bekliyor. Mesai bitiminde kuyrukta kalan kart da ertesi sabaha kalıyor.
- (R soru 1) Gece düzeltmesinin moral bedelini tasarımcı da ödüyor.
- (B2 W17) −1/−2'lik izler çipte "70 → 70" okunuyor.
- (W1 notu) B2C ücretsiz ay ucuz.

Notlar:
- `olay.clock` geçmiş satırında donmuyor; bu bilinen bir kısıt.
- W1 dalga dosyasındaki `olay.customer_users` → `musteri.seats` ad değişikliği izlenmeyen faz_ab'de; yazım dalgasının kaynağına taşınmalı.
- Seçici `select: "asked"` bir kipten ibaret, yeni seçici değil. Varsayılan seçicinin rastgele bir çalışanı gönderen yapmasını önlüyor.

### Sabitler (kod ajanı)
- data/product/sprint.json incident.base = 0,10: haftalık kesinti olasılığı tabanı (PRD: onay bekliyor)
- incident.tier = {local 1,5, cloud 1,0, enterprise 0,6}: sunucu kademesinin olasılık çarpanı
- incident.bug_cap = 12 ve incident.bug_div = 8: hata terimi 1 + min(costed(açık hata), 12) / 8
- incident.p_max = 0,30: olasılık tavanı (smoke 4-6 dışı ≥ %30 koşulu p ≤ 0,331 ister; yerel + çok hata 0,375 olurdu)
- incident.min_gap = 4 (tik): iki olay arası alt sınır (Erdem'in kuralı; yalnız yeri sabit)
- incident.launch_quiet = 3 (hafta): v1.0'dan sonra sessiz süre
- incident.load_mult = 1 (IncidentSystem.load_mult): doluluk çarpanı C karar verene kadar 1
- incident.outage.start = [30, 270] dk ve start_step = 10: kesinti 00:30 – 04:30 arası on dakikalık adımla başlar
- incident.outage.min_audience = 1000: B2C'de olayın olması için en az kitle
- incident.outage.fix_hours = 3, crew_base = 0,75, crew_per_star = 0,125, founder_slower = 1,5, fix_step = 10: düzeltme süresi = 3 sa / (0,75 + 0,125 × en iyi mühendisin yıldızı), kurucu tek başına 1,5 kat yavaş, 10 dk'ya yuvarlı
- incident.outage.night_sectors = [logistics, manufacturing, health] ve day_start = 510 (08:30): gece vardiyalı sektörler ve vardiyasızların gün başı
- incident.outage.credit = [[0,10],[7,15],[12,25]]: kapalı kalma saati eşiği → aylık ücretin % kredisi
- incident.outage.trust_per_hour = 0,6, trust_cap = 8, credit_forgives = 0,85: kalıcı memnuniyet izi saat başı, tavan ve kredinin sildiği pay
- incident.outage.try_share_hour = 0,015: B2C'de saat başı uygulamayı denemeye çalışan kitle payı
- incident.outage.loss_per_hour = 0,003, loss_cap = 0,04, free_month_loss = 0,5: B2C kitle kaybı saat başı, tavan, ücretsiz ayda yarısı
- Kart sabitleri: night_fix morale_crew incident_crew −10; founder_fix productivity_mod −%15 1 hafta ve kilit hr.headcount <= 2; expires_weeks 1; family_subject cooldown_weeks 26 (lint T2'yi sağlar, request kökeni için okunmaz); latch cooldown 0

### Metinler (kod ajanı)
- product.incident_outage_b2b ve product.incident_outage_b2c: başlık, gövde (tekil/çoğul varyantlar), seçenek etiketleri, kilit nedenleri, expire_note, geçmiş satırı metinleri (W1_OLAYLAR.json'dan bayt bayt; TR ve EN onayı bekliyor)
- MAIL_SENDER_SERVER_ALERT: Sunucu uyarısı / Server alert
- EFFECT_SERVICE_BACK ve EFFECT_APP_BACK: Servis / Uygulama {clock} sularında açılır; Service / App back around {clock}
- EFFECT_OUTAGE_CREDIT ve EFFECT_OUTAGE_CREDIT_ONE: Kesinti kredisi · {n} hesap · %{pct} {v}; Outage credit · {n} accounts / account · {pct}% {v}
- EFFECT_FREE_MONTH: Bir ay ücretsiz · {n} kişi · ödeyen {paying} {v}; Free month · {n} people · {paying} paying {v}
- EFFECT_TRUST_NIGHT_ACCOUNTS ve EFFECT_TRUST_OTHER_ACCOUNTS: {n} gece vardiyalı hesap: memnuniyet {v} ...; Öbür {n} hesap: memnuniyet {v}; EN karşılıkları
- FIN_ONETIME_OUTAGE_CREDIT: Kesinti kredisi / Outage credit (Finans'ta tek seferlik gider etiketi)
- Kaldırılan: EV_PRODUCT_OUTAGE_* (6 anahtar, eski outage kartı)

### Riskler
1) Zar oynanan koşuda artık canlı (sim probe, plausibility, run_gate, gerçek oyun); smoke koşturucusu, shot tohumu ve gerçek saat probe'u IncidentSystem.rolls = false ile zarı kapatır, çünkü tutuş cevaplanmayan kartta saati sonsuza dek durdurur (bir mutasyon denemesinde bu bir takılma olarak göründü; derleme hatasıydı, mutasyon düzeltildi). Eski vakalar zarı görmez; gerçek zar yalnız dört yeni vaka ve inbox_no_night_stamp'ta (104 haftada ~9 olay, plausibility 40 koşuda 30 kart). Sıklık ve bedel sayıları [ÇALIŞMA], onay bekliyor.
2) Gece kapısı kararı: kepenk kartı ve kâğıdın son uyarısı da mesai başına kadar bekler (B0v 'R soru 10' varsayılanı). PRD Karar 21'in "kepenk ve son kâğıdı 00:00'da kalır" satırıyla gerilim taşır; sahip onayı bekliyor. Ayrıca EvQueue._shown artık mesai dışında hiçbir normal kartı göstermez: akşam mesai bitiminde kuyrukta kalan kart ertesi mesai başına kalır (eskiden damgası geçmişse hemen açılırdı).
3) Çipin "to" değeri B2'nin kuralıyla bir tik sonrasının değeridir; −1 / −2'lik izler çipte "70 → 70" okunur (kredili seçenekte görünüyor). Sahibe açık tasarım sorusu (B2'den), B3 yeni değil ama bu kartlarda ilk kez göze çarpıyor.
4) W1_OLAYLAR.json taslağında {seam:olay.customer_users} 42 yerde {seam:musteri.seats} yapıldı (yalnız seam adı, metin aynı; textparity 58/58). Dosya izlenmeyen docs/tasks/faz_ab/ içinde, commit'e girmez; yazım dalgasının kaynağına geri taşınmalı. Geçmiş satırında olay.clock (dize seam'i) donmaz: yanıtlanmış kartın geçmiş satırı en son kesintinin başlangıç saatini okur; sonraki kesintide eski satırın saati değişir (kabul edilen kısıt, seam notunda).
5) UI: mail_pane.gd seçenek çubuğuna üst/alt SPACE_M iç boşluk eklendi (çipler 2-3 satıra sarınca kenara değiyordu; theme'de OptionBar dikey boşluğu 0). Tek satırlı çubuk 56 px kaldı; theme dosyalarına dokunulmadı. Başka kart henüz üç satırlık çip taşımıyordu.
6) sprint_probe incident= için lansmandan 3 hafta sonrasına uzanan koşu ister: varsayılan K1 kartlarıyla koşu 4. tikte biter, fill=1 şart. B2B fikstür hesapları (co_probe_*) fill=1 koşusunda 11. tikte topluca kayboluyor ve yeniden imzalanıyor; aynı koşuda olay olmadan da oluyor (fikstür ürün kalitesiyle ilgili, olayla değil). Probe'un 6 uyuşmazlığı adlı (product.sprint_two_paths, team.demo_day), çıkış kodu 0.
7) GameState.product.interrupt yalnız yazılıyor, okuyan henüz yok (B4/B5/B7 okuyacak); SprintSystem.record_interrupt bugün yalnız "incident" türüyle çağrılıyor ve sprint başına son kayıt kalıyor.
8) --why-fire iki kart için G4'te reddeder (tick: request, sistem kartı); beklenen, kart yalnız IncidentSystem'den gelir. Kapı, kartı reddederse olay başlamamış sayılır (PRD): last_day yazılmaz, zar ertesi hafta yeniden atılır.
9) Sahipsiz farklar dokunulmadı: project.godot (editör kaynaklı sıra farkı), Godot/, tools/__pycache__, docs/mockups, docs/tasks/PRD_*, docs/tasks/faz_ab ve faz_cde. Commit atılmadı; faz_ab commit'lenmez.

### İnceleme düzeltmeleri
Tek düzeltme turu:

1. Asıl sapma, kademe çarpanları. Yürütücü notu §1'e göre Erdem 2026-10-17 akşamı (faz_cde/ERDEM_CDQ_CEVAP.md) `incident.tier`'ı yerel 1,0 · bulut 0,5 · kurumsal 0,25 olarak onayladı ve B_PLAN'ın 1,5/1,0/0,6'sını geçersiz saydı. Kod ajanı eski değerleri yazmıştı. Düzeltilen yerler:
   - data/product/sprint.json: değerler değişti.
   - incident_system.gd başlık yorumu: `tier` onaylı, öbür sayılar [WORKING].
   - docs/HARITA.md ve GDDs/GUNCELLEMELER.md: kademe değerleri ve onay notu.

2. incident_gap_and_spread yeni değerlere uyarlandı:
   - Satırlar artık local/cloud/enterprise, hepsi 12 hatayla: beklenen p 0,25 / 0,125 / 0,0625.
   - "Çok az olay" alt sınırı 15'ten 10'a indi (enterprise 19 olay veriyor).
   - Falsification yorumu güncellendi: P_MAX artık yalnız 0,2'ye indirilince local olasılık denetimini düşürüyor, çünkü onaylı kademelerle tavan bağlamıyor.

3. engine.gd: tek yerde kullanılan `_is_emergency` sarmalayıcısı silindi, satır içine alındı (§5 kuralı).

4. Yanlış ya da bayat iki yorum:
   - incident_system.gd `MORNING_ACTS` yorumu sabitin içeriğini yanlış anlatıyordu; düzeltildi.
   - main.gd `--inbox-shot=night` belgesinde "03:00" yazıyordu, shot 02:00'de duruyor; "its hour" yapıldı.

Yeniden koşulanlar:
- Dört incident vakası, inbox_no_night_stamp ve event_morale_payers: hepsi `SMOKE PASS`.
- `--event-lint`: 0 hata, 0 uyarı.

### Ana oturumun commit öncesi değişikliği (B3)
- C/D oturumunun iletisiyle (`faz_cde/C_ICERIK_v3.md` §8 madde 5): `IncidentSystem.hazard` kademeyi tavandan sonra çarpar,
  `p = min(base × load × (1 + hata/8), p_max) × tier`. Bugün yük 1 olduğundan sayı değişmez (en yüksek 0,25); C'nin yük
  çarpanı gelince oran korunur. Dört incident vakası + lint yeniden PASS.
- Kademe 1,0 / 0,5 / 0,25 Erdem'in onaylı kararı (ERDEM_CDQ_CEVAP.md); B0v sorusu 6 (`P_MAX` 0,30) neredeyse konusuz: tavan
  ancak C'nin yük çarpanıyla bağlar.
- Gece gelen kutusu PNG'sindeki "İlk sabah" satırı Hafta 1'de teslim edilmiş eski mektup (Haiku'nun FAIL'i yanlış okuma);
  `--why-fire` iki kartta "G4 tick:request" beklenen sonuç.

## B9 · `cb5f51c`
**Başlık:** Faz B B9: Yatırımcı hazırlığı kalktı. Series A sekmesinde toplantı ayarlanınca yalnız Ertele ve İptal et kalır, hazırlık odağı düğmeleri ve Bekleyen'deki hazırlık satırı yoktur; görüşmede hiçbir zar hazırlık bonusu almaz, "prova edildi" işareti ve hazırlık çipi görünmez, kurucunun "yatırım hazırlığı" görev durumu yoktur. Telafi eklenmedi; cautious botta 10 tohumda imza %100'den %90'a iner. Eski kayıttaki hazırlık alanı ve bayrağı her yüklemede düşer.

### Kabul
PRD §4.8 (Yatırımcı hazırlığı) ve karar 18:
- ✅ Kodda iz yok: `grep -rnE "pitch_prep|PITCH_PREP|start_prep|prep_blocked|_prep_focus|FOCUS_KEYS|PREP_BONUS|PREP_WEEKS|PREP_MIN|HUNT_PREP|HUNT_FOCUS|VC_PREP|VC_REHEARSED|GameState\.prep|_tick_prep|_consume_prep|prep_bonus|meeting_daylock"` docs/tasks dışında yalnız iki eşleşme veriyor: save_codec.gd:235 (yükte düşürme satırı) ve endgame_smoke.gd:2597-2631 (save_drops_retired_prep vakası). Silinenler: game_state.gd FLAG_TYPES pitch_prep_active, `var prep` ve sıfırlaması; hr_system.gd FOUNDER_STATE_PITCH_PREP ve is_busy / founder_task_label / founder_task_state okuyucuları; vc_pitch_system.gd prep_blocked_reason / start_prep / _consume_prep / _tick_prep / _beat2_bonus / _beat3_bonus / _prep_focus, _check_view'ın bonus parametresi ve "prep" alanı, VC_REHEARSED işareti, iptal ve pivot temizliği; pitch_constants.gd FOCUS_KEYS / PREP_WEEKS / PREP_MIN_WEEKS_BEFORE / PREP_BONUS; hunt_tab.gd _prep_row ve Bekleyen'deki hazırlık satırı; vc_meeting_adapter.gd hazırlık çipi.
- ✅ Metinde iz yok: strings.csv diff'inde tam 13 satır silinmiş (HR_FOUNDER_STATE_PITCH_PREP, HUNT_PREP_RUNNING/REASON/PENDING/READY, HUNT_FOCUS_NUMBERS/STORY/REHEARSAL, VC_PREP_BUSY/NEED_MEETING/TOO_SOON/TOO_SOON_ONE, VC_REHEARSED), başka B9 satırı yok. `grep PREP strings.csv` yalnız ONB_PREPARING ile MEETING_CHIP_PREP'i döndürüyor. Kapılar: loc_residue 0 hit, loc_csv_integrity PASS.
- ✅ MEETING_CHIP_PREP satışta çalışıyor: sales_meeting_adapter.gd:31-33 yerinde, CSV:1895 duruyor.
- ✅ Kayıtta iz yok (W15): save_codec.gd:235 `out.erase("pitch_prep_active")` her yüklemede ve sürümden bağımsız çalışır. apply_game_state yalnız game_state_fields() üzerinden döndüğü için (save_codec.gd:200) `prep` bloğu kendiliğinden yok sayılır. save_manager.gd _migrate_14'teki prep damgası silindi. save_drops_retired_prep PASS, falsifikasyonu kod ajanı kanıtladı.
- ✅ Smoke'ta iz yok: prep_bonus_and_capacity ve meeting_daylock silindi; hr_read_catalogue ve split_bars_name_their_cause'daki hazırlık satırları çıktı.
- ✅ full_run_vc_cautious bir sonla bitiyor: run_gate.sh "RUN OK full_run_vc_cautious day=61 ending=series_a_close errs=0" ve "RUN SUMMARY 3/3 ok".
- ✅ Önce/sonra ölçümü yapıldı. Geçici kol 10 tohum × 2 kol koştu; imza hazırlıklı kolda 10/10, hazırlıksız kolda 9/10, görüşme başına teklif %52,6'ya karşı %37,5. Odaklanan sorunun geçme ihtimali PREP_BONUS ile ve onsuz: metrik 0,60 → 0,80, dürüst 0,30 → 0,50. Kolun kalıntısı yok: run_probe.gd'de yalnız chance_for çağrısının imzası değişti.
- ✅ Telafi eklenmedi (karar 18).
- ⚠️ Kayıp kapsam (düzelttim): silinen prep_bonus_and_capacity, VC görüşmesinin kurucuyu meşgul tutup oturum kapanınca bıraktığını ölçen tek vakaydı. Ajanın "başka vakalarda ölçülüyor" demesi yalnız satış toplantısı için doğruydu (endgame_smoke.gd ~5244 ve ~17157). İki kontrolü vc_call_postpones_once'ın sonuna, zaten açılan VC görüşmesinin üstüne ekledim ("a founder seated at the pitch reads as free" / "the founder stayed busy after the sitting closed"). Koşu: SMOKE PASS vc_call_postpones_once.
- ✅ Görsel kabul: dört kareyi açtım (vc_shot_hunt_meeting TR, meeting_shot_open EN, Haiku'nun TR/EN notları). Bosphorus satırında yalnız "Toplantı ayarlandı" + "Ertele (2 hafta sonra)" + "İptal et" var; Bekleyen'de tek satır "Toplantı: Bosphorus Partners · gelecek hafta". Görüşme panelinde hazırlık çipi yok; taşma ve ham anahtar da yok.
- ✅ CLAUDE.md §9: diff silme ağırlıklı ve en kısa hâlinde. _check_view'ın parametresi ve "prep" alanı da temizlendi, ölü kod ya da tarihçe yorumu kalmadı. save_codec.gd:235'teki tek satırlık yorum bugünkü nedeni söylüyor. Yeni sabit yok, onaylı metin bağlanmadı (yalnız silme). UI/STYLE kanununa aykırı ekleme yok.
- ⚠️ Bırakılanlar (CLAUDE.md §3): ACIK_KARARLAR madde 77 ve ~1219 eski adları anıyor. ZAMAN MODELİ §4.7/§8.6 ile Ekip GDD'deki hazırlık maddesi yerinde ama GUNCELLEMELER girdisiyle geçersiz.
- ⚠️ Süreç: ajan iki Godot sınırını kısa süre aştığını kendisi bildirdi. Benim koşum sayım 2'den düşünce başladı.

### Onay bekleyen
Onay bekleyen yeni sabit ya da yeni metin yok (adım yalnız siliyor). Rapor R'ye girecekler: cautious botta hazırlıksız kol imzası 9/10; tohum 6 Series A'ya varamadı, 104. günde running_on_fumes ile bitti. Telafi eklenmedi. ACIK_KARARLAR madde 77 ve ~1219'daki eski adlar sahip kararına bırakıldı.

### Sabitler (kod ajanı)


### Metinler (kod ajanı)


### Riskler
1) Ölçüm tek bot politikasıyla (cautious) ve 10 tohumla; fark küçük örneklemde iki tohumdan geliyor, bunlar bire bir aynı koşuya hazırlığın tek farkı eklenerek elde edildi. 2) Hazırlıksız kolda tohum 6 hiç imzalayamadı (4 fon reddetti, running_on_fumes): hazırlık silinince cautious botun bir koşusu Series A'ya varamıyor; telafi eklenmedi (PRD karar 18). Rapor R'ye girmeli. 3) docs/ACIK_ISLER/ACIK_KARARLAR.md madde 77 (PREP_WEEKS, PREP_MIN_WEEKS_BEFORE) ve satır ~1219 (prep_bonus_and_capacity) eski adları anıyor; CLAUDE.md §3 açık maddelere dokunmayı yasakladığı için bırakıldı. GDD ZAMAN MODELİ.md §4.7 ve §8.6'daki PREP satırları da yerinde; her ikisi GUNCELLEMELER girdisiyle geçersiz kılındı. Ekip GDD docx'teki 'yatırım hazırlığı' maddesi de aynı girdiyle kapsandı. 4) Brief 'save_manager v13 damgası' dedi; gerçek yer _migrate_14 idi (prep.done_day damgası); oradan silindi. 5) Paralel çalışma: B7'nin yarım sprint_system.gd kodu (_ask_promise, crunch_finishes) iki kez parse hatası verdi ve smoke koşuları 300 sn takıldı; kendi Godot süreçlerimi (komut satırıyla ayırt edip) elle durdurdum, sonra B7 bitirince yeniden koştum, hata benim dosyalarımda değildi. Ayrıca lint+loc_residue ve gate koşusunda başka ajanın bir Godot'su varken ben de başladığım için kısa süre üç/iki süreç sınırını aştım. 6) endgame_smoke.gd, strings.csv, main.gd, run_probe.gd, HARITA.md, GUNCELLEMELER.md ve _vocabulary.md öbür adımların farklarını da taşıyor; commit'te hunk düzeyinde ayrılmalı (own_markers). 7) _vocabulary.md ve EVENT_SIGNAL_MANIFEST.md tüm ağacı yazar: içinde B4, B7, B8 satırları da var.

### İnceleme düzeltmeleri
endgame_smoke.gd _case_vc_call_postpones_once sonuna ekledim: açılan VC görüşmesinde HRSystem.is_busy(founder) doğru olmalı; VCPitchSystem.withdraw() + end_sitting() sonrası yanlış olmalı. Silinen prep_bonus_and_capacity ile kaybolan, VC oturumunun kurucuyu tutup bırakmasına dair tek guard'ı geri getirir. Yeni vaka adı eklenmedi. Koşu: SMOKE PASS vc_call_postpones_once (APPDATA appdata_B9_opus).

### B9 ölçümü (geçici kol, full_run_vc_cautious, 10 tohum × 2 kol)
- Hazırlıksız: imza 9/10, görüşme 24, teklif 9 (%37,5); tohum 6 imzasız (running_on_fumes). Hazırlıklı: imza 10/10,
  görüşme 19, teklif 10 (%52,6). Odaklanan soru: metrik 0,60 → 0,80, dürüst 0,30 → 0,50 (PREP_BONUS 2 × 0,10).
- Telafi eklenmedi (Karar 18). Paralel turda commit'lendi: ortak dosyalar (strings.csv, endgame_smoke, run_probe, main,
  HARITA, _vocabulary) hunk düzeyinde ayrıldı; commit ağacı ayrıca koşturulmadı, yalnız kalıntı taraması (git grep --cached).

## Ana oturum notu · paralel parti (B4, B7, B8, B5, B6a, B6b)
- Altı adım aynı ağaçta paralel yazıldı. Ortak dosyalarda (sprint_system, endgame_smoke, effects, chips, lint, main, sprint.json, strings.csv, belgeler) değişiklikler satır düzeyinde iç içe geçti: B6a, B4'ün `fix_first_bumps`'ını `first_bumps`'a indirdi; B6b, B7'nin `cut_promise_test`'ini `cut_test` yaptı; B6b, B7'nin kapanış zarı satırına `line_blocked` ekledi. Ara adım ağaçları hiç var olmadığı için altı adım tek commit'e girdi; her adımın paragrafı mesajda.
- Kapı: birleşik ağaçta bütün adımların hedefli vakaları + run_gate + plausibility tek seferde koşuldu (int_gate).
- Onaylı metin dosyasına dokunuş: B6a kod ajanı W2_KAGITLAR.json'da iki testçi kâğıdının (`sprint_test_readonly_delete`, `sprint_test_too_much`) seçenek etiketinde ve belirteç tablosunda `{employee}` → `{dev}` yaptı (slot adı; konuşan testçi `employee` slotunda, seçenekte adı geçen yazılımcı ayrı `dev` slotunda). Ekranda görünen metin aynı (yazılımcının adı). B8'in W3'teki belirteç değişikliği gibi R'de Erdem'e bildirilecek.
- Eşlik (son ağaç, ana oturum): W2 B6a önekleri checked=258 missing=0; B6b önekleri + çip kimlikleri checked=242 missing=0.

## B4 · `ea3c20c`
**Başlık:** Faz B B4: Dört acil durum daha gelir. B2B'de ay sonu kapanışı ayın son haftasında 23:00'te hesabın Finans Müdürü'nden gelir. B2C'de ödeme alınamıyor ve yorum fırtınası gelir. İki pazarda da hatalı sürüm kritik bir hattı bozarsa ertesi sabah sürüm sonrası bozulma gelir. "Sprinti durdur" hattın düzeltme kartını koşan sprintin başına alır; sprintin son gecesi mesaiden sonra gelirse kart sonraki sprintin başına girer. Çip sprintten kayan kartın adını yazar. "Sonraki sprinte bırak" B2B'de hesaba hemen −6 ve düzelene kadar her sprint kapanışında −3 yazar, B2C'de hat temizlenene dek kitleyi haftada %2 azaltır. Çözülme saati çipi gece yarısını geçen düzeltmeyi o gecenin saatiyle, sabaha kalanı "yarın" diye yazar. Bot acil durum kartını fiile göre cevaplar. TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
§9 sorularına bakıldı. Kod genel olarak kısa. Mevcut yardımcılar yeniden kullanılmış: `_outcome` plan_outcome'un gövdesinden ayrıldı, `put_first` fix_first'ten ayrıldı, `_named` eski `_of_decision`'ın yerini aldı ve eskisi silindi. Gereksiz savunma ya da tarihçe yorumu yok. Write-through doğru: hata yalnız `ProductState.add_bugs` ile yazılıyor, iz `set_trust_offset` ile, kitle `SalesSystem.add_b2c_audience` ile, gider `FinanceSystem.apply_one_time_cost` ile. W1 metni bayt bayt bağlı: textparity checked=146, eksik 8. Eksik olanlar bilerek bağlanmayan regression B2B Veri Girişi ve Mobil varyantları. Kart anahtarları yeniden numaralandı ve `variant()` ile birebir uyuşuyor (dosyada tek tek kontrol ettim: 8 = Entegrasyonlar … 14–17 = B2C). Sabitler sprint.json `incident` bloğunda; [WORKING] işareti başlık yorumunda (incident_system.gd:25), B3'ün düzeni bu.

İncelemede iki hata buldum ve düzelttim:
(1) `SprintSystem._fix_goes_next` mesaiden ÖNCEKİ saatleri de (00:00 ile mesai başı arası) "mesai bitti" sayıyordu. Sonuç: son haftada 03:00'te ya da 1 haftalık sprintin her gününün sabahında düzeltme kartı sonraki sprinte gidiyordu, oysa o haftanın işi daha önünde. Düzeltme: koşul artık günün dakikası ≥ mesai bitişi (sprint_system.gd:258-261). Smoke'a 03:00 kontrolü eklendi.
(2) `IncidentSystem.plan` gece yarısını geçen gece düzeltmesini "yarın" sayıyordu: ekranda "Sorun yarın 02:00 sularında çözülür" yazıyordu. W1'in onaylı örneği ise "Sorun 01:40 sularında çözülür". Düzeltme: `tomorrow` yalnız ertesi günün mesaisine kalan düzeltmede true (incident_system.gd plan). Smoke'a kontrol eklendi. Yeniden çekilen kare: scratchpad\appdata_B4_rev1shot\...\event_shot_customer.incident_month_close.png. "Sorun 02:00 sularında çözülür" ve "Sorun yarın 12:00 sularında çözülür" görünüyor.

PRD §4 maddeleri:
- §4.1 Olay aralığı ✅ (smoke) ⚠️ (rapor). Yeni türler aynı `min_gap` ile `can_happen`'dan geçiyor (incident_system.gd:79-91). incident_gap_and_spread yeni türlere uyarlandı, PASS (Haiku). 104 hafta × 10 tohum raporu B6b'de.
- §4.2 Bedel ✅. Çip, geçmiş satırı ve uygulama aynı `plan()` sözlüğünü okuyor. Kanıtlar:
  - incident_checkout_fix_card: düşen kitle = çip.
  - incident_defer_ends_with_line: B2B −6 ve sprint başına −3; hattı kapatan kapanış ücret almıyor; B2C %2 ve %1.
  - B2C ücretsiz ay `line_users` ile orantılı.
  ⚠️ W1'deki ödeme çipi ("Ödeyen −7 · MRR −$56") bağlanmadı. Yerine B0v madde 9 / R soru 3 önerisi (a) uygulandı ("Kitle −N").
- §4.3 Gece ✅. Ay sonu kartı 23:00'te `urgent` olarak açılıyor. incident_month_close_window, incident_night_hold_resumes ve incident_scale PASS (Haiku).
- §4.6 Bedeli ödeyen ✅. `olay.payers` artık olayın hattını okuyor (seams_incident.gd). event_morale_payers PASS.
- §4.7 Tahmin ile sonuç ✅. Haiku'nun sprint-probe sonuçları:
  - checkout@17: CLOSE 7/7 MATCH.
  - regression@15: 8/8 MATCH.
  - storm@13: REPRED var, kart sprintinde MATCH.
  - Kalan 6 MISMATCH'in hepsi adlı (sprint_late, sprint_two_paths, team.demo_day) ve olaya bağlı değil; adsız uyuşmazlık 0. Haiku'nun storm'u "pass:false" işaretlemesi brief'teki beklenti metninden geliyor, kanıt temiz.
  - b2b regression@13 ve month_close@14 koşularında REPRED yok, girdi değişmedi.
- §4.9 Kapılar ✅:
  - event-lint PASS (0 hata).
  - loc_residue bu turda yeniden koşuldu: "LOC RESIDUE: 0 hit(s) [CLEAN]".
  - loc_csv_integrity PASS.
  - why-fire dört kart.
  - plausibility "PLAUS LONG runs=4 fires=363 fails=0".
  - run_gate "RUN SUMMARY 3/3 ok".
  - gen_signal_manifest Haiku koşusunda Errno 22 verdi. Manifestin farkı yalnız tarih satırı (02:15'te başarıyla yazılmış); geçici dosya kilidi, kod sorunu değil.
- §4.10 Görsel ✅. Dört kart TR ve EN olarak (b2c regression dahil 10 PNG) açılıp bakıldı; taşma yok, dil doğru.
- §4.11 Bot ✅ (seçim) ⚠️ (ölçüm). `_pick_emergency` fiile göre seçiyor; `fix_none` erteliyor, kilitliyse ilk açık seçeneği alıyor. `*_free` preset'leri sprinti hiç durdurmuyor (run_probe.gd). Yan yana ölçüm B6b'de.
- §4.12 ⚠️. Bozulma doğal oyunda gelemiyor, çünkü `release.faulty` B7'nin `escape_chance`'ı gelene dek dolmuyor (W4, R soru 5). Fikstürle incident_regression_fixture PASS.

Bu turda koşulanlar:
- incident_month_close_window: düzeltmeyle PASS. Falsification için `tomorrow`'u her sonraki gün sayınca FAIL ("the night's fix reads tomorrow: true").
- incident_sprint_stop_moves_the_card: düzeltmeyle PASS. Sonraki koşular aynı ağaçta B5'in yarım `_request_decision` (decision.sprint_chance) hunk'ı yüzünden 03:00 kontrolünden ÖNCE kırmızı: "the plan said feat:line_erp_invoicing_k1 finishes: false…". Aynı hata kendi düzeltmem geri konunca da çıkıyor; neden B4 değil. Fikstür kâğıtları kapatmıyor, B5 bu vakayı kendi zarına göre güncellemeli.
- all_scripts_load PASS.

### Onay bekleyen
Onay bekleyen sabitler (sprint.json `incident`):
- weights: outage 1,0 · month_close 1,5 · checkout 1,0 · storm 1,5.
- fix.hours: kesinti 3 · ay sonu 3 · ödeme 2 · bozulma 4 · fırtına 3 saat; crew_base 0,75, crew_per_star 0,125, founder_slower 1,5, step 10.
- month_close: line_bugs 3; damga 22:10–22:55, kart 23:00; hatlar invoicing / ledger / cashflow.
- checkout: began [−120, 240] dk, after_start 10–50 dk, try_share_hour 0,0022, give_up 0,25.
- regression: kritik hatlar B2B 7, B2C 4 ortak hat; after_start 10–50 dk.
- storm: line_bugs 7, min_audience 2000, damga 11:00–16:00, share 0,025.
- defer: trust −6, per_sprint −3, audience %2, free_month_audience %1.

Kartlardaki sayılar (onay bekliyor):
- Moral bedeli: −7 (ay sonu, bozulma, fırtına), −10 (ödeme).
- Kurucu yolu: −%15 · 1 hafta.
- Ay sonu "Sabah düzelt" hesaba −3 (MONTH_CLOSE_SPRINT_TRUST).
- Kademe çarpanı onaylı, listeye girmez.

Erdem'e gidecek metin ve sayı sapmaları (metin değişmedi):
1. Ödeme kartında W1'in "Ödeyen −7 · MRR −$56" çipi yerine "Kitle −N" çıkıyor (R soru 3, öneri a). Ekranda tuhaf okunuyor: gövde "45 kişi ödeme yapamadı" derken çip "Kitle −76" diyor, çünkü kayıp kitleye ödeyen ÷ dönüşüm oranıyla çevriliyor.
2. Ay sonu "Sabah düzelt" seçeneğinde memnuniyet çipi bedel olmasına rağmen fikstürde "72 → 73" (artış) okunuyor. Neden B2'nin "bir tik sonra görünen değer" kuralı ve yüksek hedef (R soru 2). Aynı nedenle erteleme çipi −6 için "72 → 70" gösteriyor.
3. Seam sayıları binlik ayraçsız basılıyor ("2480 kişi"). Bu motorun genel `freeze_seams`/str davranışı, B4'ten önce de vardı; W1 örnekleri küçük sayılı.
4. `olay.version` metin seam'i geçmiş satırında donmuyor: sonradan başka bir acil durum açılırsa bozulma satırı sürümü boş okur.
5. Kayan kart çipi yalnız ilk kayan kartı adlandırıyor. Son gece gelen olayda adlandırılan kart sonraki sprintin kartı oluyor.

Yeniden koşulacaklar:
- incident_sprint_stop_moves_the_card: B5 kendi kâğıt zarını vakaya uydurduktan sonra. Bu vaka B4'ün commit ağacında PASS verdi; paylaşılan ağaçta B5'in hunk'ı yüzünden kırmızı.
- B4'ün commit ağacı `git apply --cached` ile ayrılınca, o ağaçta all_scripts_load koşulmalı.

### Sabitler (kod ajanı)
- sprint.json incident.weights: outage 1,0 · month_close 1,5 · checkout 1,0 · storm 1,5 (B0_ESIKLER, onay bekliyor)
- incident.fix.hours: kesinti 3 · ay sonu 3 · ödeme 2 · bozulma 4 · fırtına 3 saat; crew_base 0,75, crew_per_star 0,125, founder_slower 1,5, step 10
- incident.month_close: line_bugs 3 (MONTH_CLOSE_LINE_BUGS), damga 22:10–22:55 (kart 23:00), hatlar invoicing/ledger/cashflow
- incident.checkout: began [-120, 240] dk, after_start 10–50 dk, try_share_hour 0,0022, give_up 0,25 (ödeyemeyenlerin dörtte biri kaybolur; kitleye ödeyen ÷ dönüşümle çevrilir, R soru 3 önerisi a)
- incident.regression: kritik hatlar B2B 7, B2C 4 ortak hat (REGRESSION_CRITICAL_LINES), after_start 10–50 dk
- incident.storm: line_bugs 7 (STORM_LINE_BUGS), min_audience 2000, damga 11:00–16:00, share 0,025
- incident.defer: trust −6, per_sprint −3, audience %2, free_month_audience %1
- Kart moral bedelleri −7 (ay sonu, bozulma, fırtına) ve −10 (ödeme), kurucu yolu −%15 · 1 hafta
- Ay sonu 'Sabah düzelt' hesabın iznine −3 (MONTH_CLOSE_SPRINT_TRUST)
- Kademe çarpanı tier 1,0/0,5/0,25 ONAYLI (listeye girmez)

### Metinler (kod ajanı)
- Dört kartın TR ve EN metni (başlık, gövdeler, seçenek etiketleri, kilit gerekçeleri, süre doldu notları): customer.incident_month_close, product.incident_checkout, product.incident_regression (18 gövde), product.incident_review_storm (4 gövde)
- CSV: MAIL_SENDER_FINANCE_MANAGER, EFFECT_FIXED_AROUND, EFFECT_FIXED_TOMORROW, EFFECT_SPRINT_BUMP, EFFECT_AUDIENCE_WEEKLY (W1 chip.* ile bayt eş)

### Riskler
1) Ödeme kartı: W1'in 'Ödeyen −7 · MRR −$56' çipi (chip.EFFECT_PAYING_USERS) bağlanmadı; R soru 3'ün önerisi (a) uygulandı: ödeyemeyen ödeyenler kitleye çevrilip mevcut 'Kitle −N' çipi yazılıyor (metin değişmedi, sapma burada). 2) `olay.version` metin seam'i satırda donmuyor (olay.clock gibi kabul edilmiş kısıt): bozulma kartının geçmiş satırı, sonradan başka bir acil durum açılmışsa sürümü boş okur. 3) Kayan kart: çip yalnız ilk kaymayı adlandırıyor (iki kart kayarsa ilki); sprintin son gecesi gelen olayda ad sonraki sprintin kartıdır, 'sonraki sprinte kayar' cümlesi o durumda 'bir sonraki sprinte' anlamına gelir. 4) Çipin 'to' değeri oyuncunun bir tik sonra okuyacağıdır; hedefi yüksek hesapta ay sonu −3 çipi memnuniyeti ARTAR gösterebilir (fikstür hesabı 72, hedef yüksek: '72 → 73'); gerçek oyunda W17'deki gibi küçük izler görünmez, R soru 2. 5) Sprint probe: kapanan sprint hattın düzeltme kartını taşıyorsa zorlanan olayın hatası temizlenir ve olay hiç gelmez; probda kurulan hat artık sprintin düzeltme kartı olmayan hatttan seçiliyor (`_free_line`). b2b ay sonu ve bozulma problarında düzeltme kartı zaten başta ya da sonraki sprintteydi (girdi değişmedi, REPRED yok): 'kayan kartı adlandırma' koşulu problarda değil smoke'ta (incident_sprint_stop_moves_the_card, fix_effort.points büyütülerek) ve shot'ta kanıtlı. `_reread` olay cevabından sonra uyuşmazlığı olayın değil sonradan gelen değişikliğin adıyla etiketliyor (storm@13'te security_k2'nin uyuşmazlığı product.sprint_two_paths'e düştü). 6) §4.12: düzeltme kartı sprint ortasında girince PROBE FIX basmıyor; PROBE STOP ayrı satır olarak yükü basıyor, A'nın kollarının yeniden ölçümü B6b'de. 7) Ben tam kapıları (plausibility_run, run_gate) koşmadım; yeni kartlar o koşularda ilk kez doğal zarla gelecek. 8) Paylaşılan dosyalarda B7/B8/B9 hunk'ları aynı dosyalarda: sprint_system.gd (söz olayı, escape_chance), endgame_smoke.gd, run_probe.gd, sprint_probe.gd (REPRED'in söz dalı), main.gd (_seed_promise_world, thanks shot), effects.gd (promise_*), chips.gd, lint.gd, strings.csv (yorumlar), CLAUDE.md, HARITA.md, motor md (27.30 ve 27.31) ayrı; commit'te hunk düzeyinde ayrılmalı. 9) Süreç notu: iki kez (bir hata ayıklama koşusu ve bir loc_residue) başlatırken Godot sayısı 2 idi; kısa süreli üçüncü süreç oldu. Bir falsification denemesinde `_month_ends` sonsuz döngü yaptı, süreç öldürüldü ve değişiklik elle geri alındı; vakadaki döngüler artık sınırlı."

### İnceleme düzeltmeleri
1) sprint_system.gd `_fix_goes_next`: düzeltme kartı sonraki sprinte yalnız son haftada ve günün mesaisi BİTTİKTEN sonra gider. Önceden mesai öncesi saatler de (00:00 ile mesai başı arası, 1 haftalık sprintte her gün) yanlışlıkla sonraki sprinte atıyordu.
2) incident_system.gd `plan()`: `tomorrow` yalnız ertesi günün mesaisine kalan düzeltmede true. Gece yarısını geçen gece düzeltmesi artık W1'deki gibi "Sorun 02:00 sularında çözülür" yazıyor, "yarın 02:00" yazmıyor. Yorum güncellendi.
3) endgame_smoke.gd:
   - incident_sprint_stop_moves_the_card'a 03:00 kontrolü eklendi (line_erp_invoicing, koşan sprintin başına girmeli); falsification yorumu eklendi.
   - incident_month_close_window'a `plan("now").tomorrow == false` ve `plan("morning").tomorrow == true` kontrolü eklendi; falsification yorumu eklendi.
4) HARITA.md IncidentSystem satırında `tomorrow` tanımı yeni kurala göre güncellendi.

## B7 · `ea3c20c`
**Başlık:** Faz B B7: Söz verilen kademenin kartı sprintin son haftasında ekibin hızıyla yetişmiyorsa "<kart> bu sprinte yetişmiyor" kartı gelir. Kartı, o kartta çalışan ilk çalışan yazar; kartta çalışan yoksa kart kurucunun notu olarak gelir. Dört cevap vardır. Testi kısalt: kalan test işi yarıya iner ve kart sürümde hatalı çıkabilir, çip yüzde yazmaz. Fazla mesai: karttaki çalışanların morali -5. Bir sprint ek süre iste: hesabın güven izi -6, her söz için bir kez. Söz kaçsın: bugünkü kırılma zinciri işler (memnuniyet, marka, 8 hafta yeni söz yok). Söz olayı gelen sprintte karar kâğıdı gelmez. TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
B7'nin PRD §4 maddeleri (B0v B7 §1–11 ve Karar 14–15 ile birlikte):

- ✅ Karar 14, olay ve seçenekleri. Kart: data/events/cards/product/promise_due.json. Dört seçenek W3 ile bayt bayt aynı: title, iki gövde varyantı, 4 etiket, 3 kilit metni ve expire_note TR/EN'de python ile karşılaştırıldı, hepsi eşit. EFFECT_PROMISE_KEPT, EFFECT_PROMISE_MOVED ve EFFECT_PROMISE_RELOCK strings.csv'de W3 ile bayt bayt aynı. EFFECT_TEST_CUT W3'te yok: D2 kararıyla EFFECT_BUG_CHANCE'in yerine yeni metin olarak geldi, onay bekliyor.
- ✅ "Testi kısalt"ın bedeli tek ayar sabitinden okunuyor. sprint.json `promise.cut_test_escape` 0,15. `SprintSystem.escape_chance` tek fonksiyon ve [WORKING] yorumunu taşıyor. `_close` zarı `< escape_chance(c)` ile okuyor. %40 kısaltmanın değeri olarak kullanılmıyor, yalnız hatalı kartta max ile devreye giriyor. Çipte yüzde yok (D2). Vaka `promise_cut_test_escape` PASS, falsification 4 mutasyonla yapılmış.
- ✅ Karar 12, gelen sprintte kâğıt yok. `_request_decision` `late_promise()` doluysa dönüyor, `record_interrupt("promise")` yazılıyor. Vaka `promise_due_fires_when_late` PASS: kâğıt gelmiyor, kesinti kaydı "promise". Kontrol kolunda da kâğıt geliyor.
- ✅ Karar 15. ISLER.md'ye "B2C söz eşdeğeri açık" maddesi eklendi. Gameplay metni olmadığı için satır kırılarak yazıldı.
- ✅ §4.4, mail saatleri. `inbox_no_night_stamp` PASS (B7_chain.out).
- ✅ §4.6, konuşan kişi. Konuşan, kartta çalışan ilk çalışan; yoksa kurucunun notu (inbox.card_sender). Vaka `promise_due_fires_when_late`, ctx.employee'yi kartın assignees listesinden kontrol ediyor. TR/EN ekranda gönderen "Selin Kaya · Test Mühendisi / QA Engineer".
- ⚠️ §4.7, tahmin ile sonuç. promise=1 probu: team=4 ve team=2, 4 tohum, 33 söz olayı; adsız uyuşmazlık 0. Adlı uyuşmazlıklar `cause=product.promise_due`, `sprint_late`, `demo_day` olarak etiketli (b7_probe3/4/5.txt; SUMMARY match=317/336 ve 195/202). Ancak probta "Testi kısalt" hiç açılmadı: kartlar son haftada teste girmemişti, bot hep mesaiyi seçti. Bu seçeneğin kapanışla eşleştiğinin kanıtı yalnız smoke'ta: `promise_cut_test_escape` vakasında kart kapanışta çıkıyor ve zar escape_chance'ten okunuyor. PRD'nin "team=3" şartı yerine B0v'nin team=4'ü geçerli.
- ⚠️ §4.9, kapılar. Geçenler: event-lint PASS, loc_residue 0 hit, loc_csv_integrity PASS, --why-fire tanılaması temiz. Yeni 4 vaka PASS. Eski vakalardan inbox_no_night_stamp, event_chip_coverage, event_amount_seam, event_trust_delta_lasting, sprint_decision_blocks_progress, sprint_late_only_when_behind ve sprint_faulty_bug_on_card_line PASS (B7_chain.out). İnceleme sırasında zincir hâlâ koşuyordu: g7'nin kalan vakaları, g8–g9 sprint-probe, g10 plausibility, g11 run_gate, g12 vocab+manifest ve g13 parity sonuçları henüz okunmadı. Commit'ten önce ana oturum şu dosyada CHAIN_DONE'ı ve fails=0 / ERROR 0 satırlarını görmeli: C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/B7_chain.out
- ✅ §4.10, görsel. İki ekranı Read ile açtım: .../scratchpad/appdata_B7_shot2_tr/.../event_shot_product.promise_due_customer=co_nordica.png ve ..._en.png. Taşma yok. EN'de ek süre ve bırakma satırlarının çipleri iki satıra iniyor ama düzen bozulmuyor. Çiplerde yüzde yok. Gönderen ve imza doğru.
  Not: çekim dünyasında Nordica'nın memnuniyet hedefi 0, bu yüzden ek süre çipi "72 → 51" okuyor. Bu, bir haftalık kaymanın sayısı; -6 izin kendisi değil. Hesabı hedefine koymayı denedim, çipler "0 → 0" okudu; daha kötü olduğu için geri aldım. Gerçek oyunda hedefine oturmuş hesapta çip seçeneğin kendi bedelini okur.

CLAUDE.md §9 soruları:
- Kod kısa ve doğrudan. Eski `decision_card_late` / sıfır argümanlı `crunch_finishes` / `_decision_in_sprint` aynı değişiklikte silinmiş, seam'ler kart kimliğiyle yeni yollara taşınmış.
- `_on_decision_card` → `_on_card` adlandırması, `_trust_part` ve `trust_plan` gibi var olan yardımcılar yeniden kullanılmış, kopya yardımcı yok.
- Gereksiz savunma yok. `promise_crew`'daki category okuması güvenli: çalışan silinince `_restaff` önce assignees listesini süzüyor.
- Write-through kuralı korunuyor: söz yalnız PromiseRegistry.extend ve break_promise ile değişiyor, güven izi trust_delta ile, moral morale_crew ile.
- UI/STYLE kanununa aykırı bir şey yok; ham renk ya da boyut eklenmemiş.
- Onay bekleyen sabitler: 0,15 sprint.json'da ve [WORKING] yorumu escape_chance'te. -5, -6 ve 1,25 kartın seçeneklerinde duruyor; çarpan CRUNCH_MULT ile aynı. Bunu yanlış söyleyen CLAUDE.md cümlesini düzelttim.

### Onay bekleyen
Onay bekleyen sabitler:
- PROMISE_CUT_TEST_ESCAPE = 0,15. Yeri: sprint.json `promise.cut_test_escape`. Sonraki değer max(önceki, 0,15); D gelince escape_chance'e bağlanır.
- PROMISE_CRUNCH_MORALE = -5. Yeri: promise_due.json, crunch seçeneği.
- Fazla mesai çarpanı 1,25. Değeri CRUNCH_MULT ile aynı.
- PROMISE_EXTEND_TRUST = -6, söz başına bir kez.
- Uzatılmış sözün ödülü bugün `kept`, yani tam ödül. Erdem'e soru: yarım mı olmalı?

Onay bekleyen metinler: kart metni ve 3 çip anahtarı W3 ile bayt bayt aynı. EFFECT_TEST_CUT ("{card}: test işi yarıya iner" / "{card}: testing cut in half") W3'te yok, D2'den gelen yeni metin.

R'ye girmesi gerekenler:
1) Memnuniyet çipi bir tik sonraki kaymayı da içine alıyor (B2'nin modeli). Hedefin altındaki hesapta "Arayıp ek süre" çipi -6'dan çok daha büyük bir düşüş gösteriyor; çekimde 72 → 51 görünüyor ve bunun sebebi kayma. SupportSystem'in günlük zararı da modelde yok.
2) Kilit metni iki durumda kesin değil: kart testteyken kısaltma yetmiyorsa ekranda yine "Kart henüz teste gelmedi" çıkıyor; kartta yalnız kurucu çalışıyorsa "Fazla mesaiyle de bu sprintte bitmiyor" çıkıyor.
3) Aynı sprintte iki kademe yetişmiyorsa yalnız en büyük hesabın olayı geliyor; öbür söz kapanışta sessizce kırılıyor.
4) Söz olayı istendiği halde motor reddederse (late_promise dolu ama istek reddedildi) o hafta kâğıt da gelmiyor.
5) "Testi kısalt" probta hiç koşmadı; §4.7'nin bu kısmı yalnız smoke ile kanıtlandı.
6) §27.30 numarası B4/B8/B9 ile çakışabilir.

Kapı zincirinin sonucu okunmadı. Commit'ten önce B7_chain.out'ta CHAIN_DONE ile g8–g13 sonuçları kontrol edilmeli: plausibility fails=0, run_gate ERROR 0, textparity çıkış kodu 0.

### Sabitler (kod ajanı)
- PROMISE_CUT_TEST_ESCAPE = 0,15: data/product/sprint.json `promise.cut_test_escape` (sonraki değer max(önceki, 0,15); D'nin test modeli gelince escape_chance'e bağlanır) [WORKING, onay bekliyor]
- PROMISE_CRUNCH_MORALE = -5 ve fazla mesai çarpanı 1,25: data/events/cards/product/promise_due.json crunch seçeneği (çarpan SprintSystem.CRUNCH_MULT ile aynı) [onay bekliyor]
- PROMISE_EXTEND_TRUST = -6, söz başına bir kez: promise_due.json extend seçeneğinin trust_delta tutarı [onay bekliyor]
- Uzatılmış sözün ödülü bugünkü `kept` (tam): W3'ün Erdem sorusu R'ye (yarım mı?)

### Metinler (kod ajanı)
- product.promise_due kartının bütün metni (başlık, iki gövde varyantı, 4 seçenek etiketi, 3 kilit gerekçesi, süre dolumu notu): W3'ten bayt bayt, TR/EN onay bekliyor
- EFFECT_PROMISE_KEPT, EFFECT_PROMISE_MOVED, EFFECT_PROMISE_RELOCK: W3 çip şablonları bayt bayt, TR/EN onay bekliyor
- EFFECT_TEST_CUT ('{card}: test işi yarıya iner' / '{card}: testing cut in half'): YENİ metin (Erdem D2 yüzde yasağı, D'nin önerisi), TR/EN onay bekliyor; W3'teki EFFECT_BUG_CHANCE bağlanmadı
- docs/ACIK_ISLER/ISLER.md B2C söz satırı (W3 metni, 'Faz B Karar 15' atfı ağaçta olmayan belgeye gittiği için çıkarıldı)

### Riskler
1) Memnuniyet çipi yalnız B2B sürüklenmesini modeller (B2'nin satisfaction_next_tick'i); SupportSystem.apply_daily_satisfaction_damage (açık hata ve altyapı zararı, hesaplara eşit bölünür) aynı tikte ayrıca yazar. Zayıf ürünlü fikstürde çip 23 derken oyuncu 17 okuyor, bırakmada 3 yerine 0. Bu B2'nin kör noktası, B7 değil; vakalarım B2'nin vakası gibi yalnız `B2BSalesSystem.daily_tick()` ile karşılaştırır. Sağlıklı üründe zarar 0 olduğundan çip doğru. R'ye girmeli. 2) W3 kilit metinleri bazı durumlarda kesin değil: 'Kart henüz teste gelmedi' kart testte ama kısaltma yetmiyorsa da çıkar (seam `promise_cut_finishes` = testte VE kısaltma bitirir; çipteki 'Söz tutulur' yalan olmasın diye); 'Fazla mesaiyle de bu sprintte bitmiyor' kartta çalışan çalışan yokken de çıkar (yalnız kurucu: bedelsiz çıkış olmasın diye seam çalışan şartı da arar). Üçüncü bir metin gerekirse Erdem'e. 3) 'Testi kısalt' pratikte nadir açılıyor: test aşaması kartın son %20'si, 2 haftalık sprintin son haftasında kartın testte VE hâlâ geç olması az; probta (team=4 ve team=2, 4 tohum, 33 söz olayı) bot hep mesai ya da ek süre seçti, kısaltma hiç açılmadı. Kısaltma yolunun PRED=CLOSE kanıtı smoke'ta (promise_cut_test_escape: kart kapanışta çıkar, zar escape_chance'ten okunur); probtaki PRED=CLOSE kanıtı mesai ve ek süre yolları için. 4) Aynı sprintte iki ayrı kademe yetişmiyorsa yalnız sözü en büyük hesaba verilmiş olan için tek olay gelir; öbürünün sözü kapanışta sessizce kırılır (sprintte tek kesinti kuralı). Aynı kademeye birden çok hesap söz verdiyse seçim hepsine uygulanır, çipler en büyük hesabı ve sayıyı yazar. 5) Konuşan 'kartta çalışan ilk çalışan' (PRD: o aşamadaki atanan): kurucu o aşamadaysa ve başka çalışan başka aşamada çalışıyorsa çalışan konuşur, kurucunun notu yalnız kartta çalışan yokken; W3 örneğiyle (Selin) uyumlu. 6) inbox.card_sender: sender 'employee' olup slotu boş ve sender_desk'i olmayan her kart artık kurucunun notu gösterir (eskiden boş 'gone' kişi); paylaşılan dosya. 7) sprint_probe.gd'de B4 `_reread`'e `if who != 'product.promise_due': _cause = ''` eklemiş: söz olayı cevabından sonra planla kapanış farkı 'cause=product.promise_due' ile adlı kalıyor (mesai sonrası öbür kartlar yeniden atanmadığı için plan birebir tutmuyor); team=4 probunda 2 adlı uyuşmazlık, adsız 0. 8) Motor md §27.30 numarası B4/B8/B9 ile çakışabilir; ana oturum commit'te yeniden numaralar. 9) Paylaşılan dosyalarda (sprint_system, effects, chips, lint, endgame_smoke, sprint_probe, main, inbox, strings.csv, HARITA, CLAUDE.md) başkalarının farkı da var: commit'te own_markers ile hunk düzeyinde ayrılmalı. 10) Falsification için ağaçtan scratchpad'e kopya aldım (ana ağaca hiçbir bozucu değişiklik girmedi) ve kopyayı sildim; assets junction'ı rmdir ile kaldırıldı. 11) Tam plausibility_run, run_gate ve tam smoke koşulmadı (Haiku); full_run 200 hafta ve probe koşuları temiz, bot koşularında söz olayı hiç tetiklenmedi (kart ancak söz verilmiş geç kartla gelir), plausibility'de ilk kez gelirse family/koruma kuralları sınanacak.

### İnceleme düzeltmeleri
Tek düzeltme turunda yalnız belge düzeltildi.

1) CLAUDE.md Söz olayı maddesi: "Sayılar `sprint.json` `promise` bloğunda [WORKING]" cümlesi yanlıştı. Yeni hali: "Kısaltılmış testin ihtimali `sprint.json` `promise.cut_test_escape`'te, mesainin moral bedeli ve ek sürenin izi kartın (`promise_due.json`) seçeneklerinde [WORKING]."

2) main.gd `_seed_promise_world` için denenen ve geri alınan değişiklik: hesabı memnuniyet hedefine koymayı denedim. Çekim dünyasında hedef 0 olduğu için çipler "0 → 0" okudu. İki Edit'i elle geri aldım; dosya kod ajanının bıraktığı halde (git diff'te satisfaction_target geçmiyor). Bu deneme için yeniden çekilen ekran görüntüleri appdata_B7_rev_tr ve appdata_B7_rev_en altında; atılmalı, kabul kanıtı değiller.

Kodda değişiklik yok, bu yüzden yeniden koşulacak kapı yok. Yalnız arka planda süren kapı zincirinin (B7_chain.sh) sonuçları commit'ten önce okunmalı.

## B8 · `ea3c20c`
**Başlık:** Faz B B8: Sürüm çıkınca B2B hesapları kısa bir teşekkür notu yazar. Not, sözü tutulan, isteği karşılanan ya da acil durumu hızla kapanan hesaptan gelir; hesap başına sürümde bir not, sürümde en çok üç not gider. Öncelik söz, istek, acil durum sırasıdır ve eşitlikte büyük hesap öne geçer. Söz ile istek aynı özellikse söz metni seçilir. Not mesai içinde, hesabın yetkilisinden tek düğmeli olarak gelir ve özelliğin adını ekranın dilinde yazar; geçmiş satırı gövdesini korur. B2C güncellemesinin sürüm notunda, bir tik sonra mesai içinde "Sürüm sonrası öne çıkan yorumlar" bölümü açılır. Bölümde kaynağıyla (sosyal medya ya da uygulama mağazası) 2 ya da 3 yorum yer alır: yeni özellik, kapanan düzeltme ve sorunlu hattın olumsuz yorumu. Aynı yorum 52 hafta içinde tekrar gelmez. TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
Bu adımın PRD maddeleri:
- Karar 16, teşekkür notu ve üç tetikleyici: ✅
  - Kanıt: sprint_bridges.gd `thank` / `_thanks_candidates` ve `release_thanks_each_kind` PASS. Söz, istek ve acil durum üç ayrı hesaba gidiyor, sıralama doğru. Gönderen `contact` olarak geliyor. Geçmiş satırı her seam'i tutuyor. Özelliğin adı EN'de "Batch Invoicing" diye çiziliyor.
- Karar 16, sınırlar: ✅
  - Kanıt: `release_thanks_limits` PASS. Hesap başına 1 not, sürümde 3 not, söz istekten önce, büyük hesap önde. Aynı özellik için hem söz hem istek varsa söz metni gidiyor. Son kullanılan gövde 12 turda bir kez bile dönmüyor. Ertelenmiş söz yalnız 5/7/9 gövdelerini okuyor.
- Karar 16, acil durum "hızla kapandı": ✅, şu ⚠️ ile:
  - Kanıt: incident_system.gd `QUICK_ACTS` (now, founder, evening; W3 metniyle aynı) ve `quick_fix`; `release_thanks_incident_scope` PASS.
  - ⚠️ W3 "mail sonraki mesai penceresinde gelir" diyor. Kod notu ise olaydan sonraki ilk sürümün kapanışında istiyor. Sürüm başına sayaç bunu gerektiriyor; ama teşekkür olaydan 1–2 tik sonra gelebiliyor. Bu bir tasarım sapması olarak ana oturuma bildirilmeli.
- Karar 17, B2C yorumları: ✅
  - Kanıt: `pick_reviews` / `review_lines` ve `release_reviews_pick` PASS. 2–3 yorum, kaynaklarıyla, olumsuz eşik 4/5, suçlama, Mobil K2, sakin yorum ve 52 hafta kuralı tutuyor. B2B ve v1.0'da bölüm boş.
  - `release_through_close` PASS: gerçek kapanışla istek teşekkürü hem kayda hem gelen kutusuna düşüyor; B2C yorumları bir tik sonra açık nota geliyor.
- §4.4, yeni üreticiler teslim kuralına uyuyor: ✅
  - Kanıt: `inbox_no_night_stamp` PASS (Haiku). Not `EventGate.request` üzerinden mesai içinde geliyor; yorumların saati `reviews.at = MailClock.arrival`, gösterim `MailClock.delivered` kapısından geçiyor.
- §4.9, kapılar: ✅
  - event-lint PASS (0 hata).
  - loc_residue CLEAN.
  - loc_csv_integrity PASS.
  - `--why-fire=customer.release_thanks` hatasız koşuyor. Kart istekle açıldığı için boş dünyada G5'te durması beklenen sonuç.
  - plausibility_run.sh: `fails=0`, `PLAUS LONG runs=4 fires=363`.
  - run_gate bu adımın kapısı değil (onaylı tabloda B1/B4/B6b/B7/B9).
- §4.10, görsel kabul: ✅
  - inbox_thanks_tr/en ve reviews_tr/en PNG'lerini açtım. Öğeler yerinde, taşma yok, dil doğru.
  - Her teşekkür türü bir smoke vakasıyla tetikleniyor (`release_thanks_each_kind`).
- theme-contrast-audit: ✅ (569 çift, fails=0).
- Onaylı metin bayt bayt bağlanmış: ✅ (textparity W3: checked=92 missing=0).
- CLAUDE.md §9 incelemesi:
  - Yardımcı tekrarı yok; mevcut evler kullanılmış (`EvDice.unit`, `SprintCatalog.larger_account`, `MailClock`, `costed`).
  - Write-through doğru: köprü yalnız kendisine verilen sürüm kaydının `thanks` alanını yazıyor ve bu CLAUDE.md §6'ya da işlenmiş.
  - UI yalnız `D_*` ve tema varyasyonlarını kullanıyor.
  - presenter.gd'deki motor ayarı en küçük doğru hâlinde. mail_pane.gd:576 her seam'in dondurulmuş olmasını şart koşuyor; bu yüzden ayar gerekli.

### Onay bekleyen
Onay bekleyen sabitler (sprint.json [WORKING]):
- thanks.max = 3. Hesap başına sürümde 1 not ve sürümde 3 not PRD Karar 16'da bağlayıcı. Öncelik sırası (söz > istek > acil durum) ve eşitlikte büyük hesap kuralı W3'ün önerisi.
- reviews.neg_line_bugs = 5 (`costed` ile okunur).
- reviews.min = 2; en çok 3 yorum, en çok 1 olumsuz.
- reviews.repeat_weeks = 52.
- reviews.named_share = 0,7.
- RELEASE_THANKS_EFFECT = yok (yalnız mail).
- QUICK_ACTS = now, founder, evening. Gece sınırı, hesapların gün başı (outage.day_start, 510 dk).

Onay bekleyen metin:
- W3'ün 14 teşekkür gövdesi, 28 yorum, 2 kaynak etiketi ve başlık.
- PRODUCT_REVIEW_QUOTED dalgada yok, kod ajanının eklediği tırnak biçimi. TR'de düz tırnak kullanıyor; tipografik tırnak isteniyorsa Erdem karar verir.

Ana oturuma notlar:
- (a) Acil durum teşekkürü olayın ertesi mesaisinde değil, sonraki sürümün kapanışında gidiyor (W3 'sonraki mesai penceresi' diyor). Sürüm başına sayaç yüzünden böyle; bu R'de ⚠️ olmalı.
- (b) Kod ajanının bulduğu A'ya ait sorun düzeltilmedi (A'nın kodu): sprint_bridges.gd `tick_requests` içindeki `absi(hash(...)) % steps.size()` adaylar 3 ya da 6 olunca hep aynı kademeyi seçiyor.
- (c) `p.extended` B7'nin alanı; B7'nin commit'i bu adımdan önce ya da birlikte girmeli.
- (d) W3_SOZ_SURUM.json'daki 9 belirteç değişikliği ({seam:urun.release_feature} → {feature}) docs/tasks/faz_ab altında, commit'lenmez; raporda listelenmeli.
- (e) Paylaşılan dosyalarda hunk ayrımı own_markers'a göre yapılmalı. sprint.json, incident_system.gd ve ISLER.md'de B3/B4/B7 farkları da var.

### Sabitler (kod ajanı)
- thanks.max = 3 (RELEASE_THANKS_LIMITS: hesap başına sürümde 1, sürümde 3, öncelik söz > istek > acil durum, eşitlikte büyük hesap; PRD Karar 16 sayıları bağlayıcı, öncelik ve eşitlik kuralı W3 önerisi)
- reviews.neg_line_bugs = 5 (RELEASE_REVIEW_NEG_LINE_BUGS; = fix_effort.priority, `costed` ile okunur)
- reviews.min = 2 ve en çok 3 yorum, en çok 1 olumsuz (RELEASE_REVIEW_COUNT)
- reviews.repeat_weeks = 52 (aynı yorum 52 hafta dönmez)
- reviews.named_share = 0.7 (adlı yorum payı; satırda başka yorum yokken adlı yorum zorunlu)
- RELEASE_THANKS_EFFECT = yok (yalnız mail), kodda etki yazılmadı
- QUICK_ACTS = now, founder, evening ve gece sınırı = hesapların gün başı (incident.outage.day_start 510 dk) hızlı kapanış tanımının kodu; W3 etiketlerinden okundu, onay bekliyor

### Metinler (kod ajanı)
- customer.release_thanks: başlık ve 14 gövde (TR/EN) W3'ten bayt bayt, TR/EN onay bekliyor
- 28 B2C yorumu, PRODUCT_REVIEWS başlığı, REVIEW_SOURCE_SOCIAL ve REVIEW_SOURCE_STORE W3'ten bayt bayt; tek değişiklik belirteç adı: {seam:urun.release_feature} -> {feature} (yorum bir kart değil sürüm notunun satırı, CSV'de {seam:} yazılamaz); W3 dosyası aynı biçimde güncellendi
- W3'te olmayan yeni metin 1: teşekkür notunun tek düğme etiketi TR 'Tamam' / EN 'Got it' (kartın text.options.ok), onay bekliyor
- W3'te olmayan yeni metin 2: PRODUCT_REVIEW_QUOTED biçimi "{review}" (düz tırnak, iki dilde aynı; W3 'tırnak arayüzün işidir' dedi), onay bekliyor

### Riskler
["Motor ayarı (kapsam dışı sayılabilir, ama zorunluydu): presenter.gd `freeze_seams` artık boş ya da anahtar dönen TYPE_STRING seam'ini satırda tutuyor, `_interpolate` anahtarı çevirir. Not geçmiş satırında yalnız bu sayede çiziliyor. Yan etki: yalnız tüm metin seam'leri o an boş olan eski kartların geçmiş gövdesi artık çizilir; event_beat_*, event_history_*, event_chip_coverage koştu, yeşil.", "Godot string hash'i `hash(s) % 3` (ya da 33'ün çarpanı) için son karaktere bağlı: sabit önekli anahtarlarda her seferinde aynı sonuç verir. Yeni kod EvDice.unit kullanıyor; ama mevcut A koduna dokunmadım: sprint_bridges.gd `tick_requests` içinde `steps[absi(hash(\"%s|%d\" % [c.id, window])) % steps.size()]` adaylar 3 ya da 6 olunca hep aynı kademeyi seçer. Ana oturum bunu A'nın açık bulgusu olarak değerlendirmeli.", "Sapmalar (hepsi gerekçeli): (a) W3'ün `urun.release_feature` seam'i kaydedilmedi: yorum satırı kart değil, okuyan kimse yok (ölü kod olurdu); özellik kayıtta `reviews.feature` ve CSV yer tutucusu {feature}. Bir kart gerekirse seam tek satırdır. (b) Kart sınıfı `info`: interrupt olsa son uyarı ve süre dolumu metni (yeni metin) gerekirdi; not yolu kota tüketmez (§27.17), ISLER'deki cümle güncellendi. (c) Yorum satırı mesai içinde gelir: `reviews.at`, `review_lines` gelene dek boş. (d) 'impact puanı en yüksek kademe' sürüm kaydında yeniden hesaplanamadığı için başlık özellik = kimlik hattı kartları arasında en yüksek target_tier, sonra efor. (e) Satırda başka yorum yokken adlı yorum zorunlu (aksi halde tamamlayıcıyla aynı gruptan iki yorum çıkıyordu); olumsuz yorum varken her adsız yorum yalnız sakin olandır (W3 yalnız tamamlayıcıyı kısıtlıyordu, çelişen çiftler çıkmasın diye genişletildi). Tamamlamada aynı grup iki kez ancak kimlik kademesi hiç yoksa çıkar.", "Başka adımlarla temas: incident_system.gd `resolve` içine tek satır (`open.act`) ve QUICK_ACTS/quick_fix ekledim (B4'ün dosyası, yalnız kendi satırlarım). sprint_system.gd iki küçük kanca (B7 ile aynı dosya). `p.extended` (B7'nin Promise alanı) artık ağaçta; B7 geri alırsa sprint_bridges.gd 218. satır derlenmez. Motor md §27.31 numarası B4 aynı anda §27.31 alırsa çakışır, ana oturum yeniden numaralandırmalı. endgame_smoke.gd sonuna eklenen bölüm başka adımın sonradan ekleyeceği vakalarla aynı yere yazılıyor.", "Koşulmayanlar: tam `plausibility_run.sh` (40 koşu + PLAUS LONG), `run_gate.sh`, tam smoke. Kısa sweep (SEEDS=1 WEEKS=16 LONG_SEEDS=0) fails=0 ve kart 13. haftada iki kez ateşlendi. Kayıt şeması sabit: yeni alanlar (release.thanks, release.reviews, incident.open.act) eski kayıtta .get ile varsayılan taşır, SCHEMA_VERSION artmadı; sprint_save_roundtrip yeşil.", "Falsification sırasında bir kez geçici bozma geri alınamadı (falsify betiğinin geri yükleme koşulu) ve elle düzeltildi: sprint_bridges.gd tier satırı ve sprint_system.gd `SprintBridges.thank` satırı; ikisi de şimdi yerinde, vakalar sonradan yeşil koştu. Makinede başka ajanların tam smoke koşusu 2 Godot süreci tutuyordu; kendi koşularımı tek süreçle ve sırayla yürüttüm, üç ekranlı çekim sırasında toplam 3-4 süreç vardı."]

### İnceleme düzeltmeleri
Tek düzeltme turu (sprint_bridges.gd ve endgame_smoke.gd):
1. Hata düzeltildi: `_thanks_candidates` içinde acil durum aralığının başı `releases[-2]`'den okunuyordu. Sürüm çıkarmadan kapanan sprint de `releases`'e girdiği için (number 0) aralığı kaydırıyordu. Örnek: sprint 6'da gece kesintisi hızla kapanıyor, sprint 6 sürümsüz kapanıyor, sprint 7 sürüm çıkarıyor; teşekkür hiç gitmiyordu. Artık önceki KAMUYA AÇIK sürüm okunuyor: `_p().releases.slice(0, -1).filter(number > 0)`.
2. Smoke: `release_thanks_incident_scope`'a düzeltme ile sürüm arasına sürümsüz bir kapanış eklendi; falsification yorumu güncellendi. Falsification gerekçeyle yapıldı, koşturulmadı: eski kodda `since` bu kapanışın gününe düşer, `first.thanks` boş kalır ve vaka FAIL verir.
3. Ölü kod: `_add_review`'ün bool dönüşünü hiçbir çağıran okumuyordu; fonksiyon void yapıldı.
4. `[WORKING]` işareti `thank` (`thanks.max`) ve `pick_reviews` (`reviews` bloğu) doc yorumlarına eklendi.

Sonra beş vaka sırayla koşuldu, aynı anda en çok 2 Godot süreciyle: release_thanks_incident_scope, release_thanks_each_kind, release_thanks_limits, release_reviews_pick ve release_through_close'un hepsi PASS. Parse/Compile hatası yok.

## B5 · `ea3c20c`
**Başlık:** Faz B B5: Sprint kâğıdı artık sprint başına tek zarla gelir. Bir sprintte en çok bir kâğıt gelir, bazı sprintler kâğıtsız geçer (1 haftalık sprintte %30, 2 haftalıkta %50 ihtimal; ölçümde sprintlerin en az üçte biri kâğıtsız). Görülmüş kâğıdın sırası geriye düşer, aynı kâğıt 52 hafta geçmeden dönmez ve koşuda en çok 3 kez gelir. Kâğıdı, kartta o aşamada çalışan kişi söyler; gelen kutusunda gönderen o kişinin adı ve unvanıdır. PM kâğıdını çeyreğin PM'i söyler ve kâğıt sprintteki müşteri isteğiyle ilgilidir; işinin tamamı Destek'te olan kişi kâğıt söylemez. Kesinti sırası şöyledir: söz olayı ya da acil durum gelen sprintte, bugün saatini bekleyen bir bozulma varken de kâğıt gelmez. Kâğıt gelen sprintte yalnız servisin çöktüğü acil durum (gece kesintisi, ödeme) gelir, öbürü kaybolmaz, kâğıtsız ilk sprintte gelir. sabitler onay bekliyor

### Kabul
PRD §4, B5'in maddeleri (kanıt bu ağaçta, B6a ve B6b'nin paralel farkıyla birlikte):
- 4.5 Sprint başına en çok bir kâğıt ✅: `decision_one_per_sprint` PASS (Haiku). Falsification yapılmış: `decision_sprint` karşılaştırması silinince FAIL. Kod sprint_system.gd `_request_decision`, `p["decision_sprint"] = number`.
- 4.5 Sprintlerin en az üçte biri kâğıtsız, bir ve iki haftalık sprint ayrı ✅: `paper_empty_sprint_ratio` PASS. Ölçüm: 1 haftalıkta 30 sprintin 19'u, 2 haftalıkta 12'si kâğıtsız (0,40; sınırın üstünde ama dar). Prob çıktısı: b2b team=4 2 haftalık `PAPERSUM|weeks=2|sprints=16|papers=4|empty=12|empty_rate=0.75`, 1 haftalık `PAPERSUM|weeks=1|sprints=23|papers=5|empty=18|empty_rate=0.78`.
- 4.5 Aynı kâğıt 104 haftada en çok 2 kez, 52 hafta ve en çok 3 kez ✅: `decision_no_fourth_show` PASS. Falsification yapılmış: `max_fires` silinince ve `cooldown` silinince FAIL. `latches.gd` `_cooldown_of` yorumu düzeltildi. Mandal kart verisidir; B6'da kartlara yazılır.
- 4.5 Prob satırı ✅: sprint_probe.gd `SPRINTPROBE PAPER|<tohum>|<sprint>|<kâğıt>|<konuşan>` ve `PAPERSUM` satırları var.
- 4.5 Tam ölçüm ⚠️: 10 tohum, iki pazar ve sprint başına toplam kesinti raporu B6b'ye bırakıldı (plan §5 satırı "son ölçüm B6b"). Bu adımda 1 tohumla ölçüldü.
- 4.6 `paper_speaker_is_assignee` ✅: PASS. Konuşan kartın atananlarındadır ve `role_of` o aşamanın rolünü verir. Atanmış PM tasarımcı kâğıdını söylemez. İşinin tamamı Destek'te olan yazılımcı konuşmaz. PM kâğıdı istek kartına düşer, hesap isteğin hesabıdır; PM yoksa PM kâğıdı gelmez. Tek kurucu kendi notunu söyler. Üç falsification yapılmış.
- 4.6 Karar 10 (PM kart almaz) ⚠️: A'nın `_assign`'ı PM'i hâlâ tasarım kartına atıyor. Kâğıt tarafı bunu atlatıyor (PM tasarımcı kâğıdını söylemez); atamanın kendisi R soru 9'da (yürütücü notu tuzak 7).
- Karar 12 kesinti sırası ✅ (bu turda düzeltildi):
  - `paper_interrupt_order` PASS.
  - Yeni dalın falsification'ı yapıldı: `waiting not in IncidentSystem.SERVICE_DOWN` yerine false yazılınca `SMOKE FAIL paper_interrupt_order: a regression waiting for its hour let in the sprint's paper`, geri konunca PASS.
- §4.1 smoke yeniden ✅: `incident_gap_and_spread` PASS (bu turda koşuldu).
- 4.4 `inbox_no_night_stamp` ✅: PASS (Haiku).
- 4.7 Prob adsız uyuşmazlık 0 ✅: `--sprint-probe ...events=1:market=b2b:team=4` çıkış 0, `SUMMARY|match=72/84`; uyuşmazlıkların hepsi adlı.
- 4.9 Kapılar ✅: `--event-lint` bu turda yeniden koşuldu, `LINT PASS 0 error(s), 0 warning(s), 13 baselined, 110 card(s)`. `loc_residue` ve `loc_csv_integrity` PASS (Haiku). `--why-fire` uygulanmaz, yeni oyun kartı yok.
- 4.10 Görsel kabul ✅: `product_shot_live_decision_paper.png` (TR) ve `_en.png` açılıp bakıldı.
  - Olaylar'da gönderen "Mert Yıldız · Yazılım Mühendisi / Software Engineer".
  - Kâğıt başlığı, gövde ve "Bu hafta son / Final week" yerinde.
  - Taşma ve dil karışması yok.
- §9 inceleme:
  - Kod kısa ve doğrudan. Var olan evler kullanılıyor: `EvDice.unit`, `EvLatches.fires`, `SprintCatalog.quarter_pm`, `role_of`, `_slots_of_type`.
  - Ölü `decision.rate` okuyucusu kalmadı (grep: yalnız probun `rate=` parametresi).
  - Sabitler tek ayar yerinde (sprint.json `decision`). `[WORKING]` işareti eksikti; `_request_decision` yorumuna eklendi.
  - Write-through: `IncidentSystem.shifted`'i yalnız IncidentSystem yazıyor, SprintSystem yalnız okuyor.

### Onay bekleyen
Onay bekleyen sabitler:
- `decision.sprint_chance`: 1 haftalık sprintte 0,3, 2 haftalıkta 0,5. 2 haftalıkta boş oran 0,40, ⅓ sınırına yakın.
- `decision.seen_weight` 2: ağırlık 1 / (1 + 2 × görülme).
- Kesinti sırası kuralı:
  - Kâğıtlı sprintte yalnız `SERVICE_DOWN` gelir: kesinti ve ödeme.
  - Öbür tür bir sprint kayar. Kayan olay bütün hâliyle gelir; ay sonu koşulu yeniden sorulmaz, yani takvim ayının sonu olmayabilir.
  - Bugün saatini bekleyen bozulma kâğıdı kapatır.
- Mandal: 52 hafta ve koşuda en çok 3; kart verisi, B6'da yazılır.

Metin: yalnız fikstür kâğıtları (version_scope fixture, oyuncuya çıkmaz). Yeni CSV anahtarı yok.

Ana oturum için uyarılar:
1. sprint_system.gd'de `_request_decision` ve `_speaker`'ı şu an B6 değiştirmiş durumda: `roles` listesi, `account`, `_paper_account`. B5'in hunk'ları B6'nın satırlarıyla iç içe; commit'te hunk ayırırken B5 sürümü ağaçta tek başına yok.
2. Paylaşılan dosyalarda B4, B7 ve B8'in de bekleyen farkı var (smoke, main.gd, incident_system, HARITA, CLAUDE.md).
3. `product.sprint_late` hâlâ `decision.cards`'ta. B6b ya listede tutacak ya da ona kendi isteğini yazacak.
4. Tasarımcı kâğıdı 2 haftalık sprintte nadir gelir, çünkü konuşan kartın o anki fazından seçilir. B6b ölçümünde uyarı olarak raporlanmalı.

### Sabitler (kod ajanı)
- decision.sprint_chance: 1 haftalik sprintte 0,3, 2 haftalikta 0,5 (sprintlerin en az ucte biri kagitsiz; olcum: 2 haftalik sprintte 30 sprintin 12'si kagitsiz, sinirin ustunde ama dar)
- decision.seen_weight 2 (kagit agirligi 1 / (1 + 2 x gorulme))
- kesinti sirasi kurali (kagitli sprintte yalniz outage; obur acil durum bir sprint kayar) ve kayan ay sonu kapanisinin takvim ayinin sonu olmamasi (kayan olay tum haliyle gelir, ay sonu kosulu yeniden sorulmaz)
- mandal 52 hafta + kosuda en cok 3 (kart verisi; B6'da kartlara yazilir)

### Metinler (kod ajanı)
- Yeni oyuncu metni yok; fiksturlerin (data/events/cards/_fixtures/paper_*.json) TR/EN govdeleri yalniz test ve shot icindir, oyuna girmez

### Riskler
1) Paylasilan agac: sprint_system.gd, incident_system.gd, endgame_smoke.gd, main.gd, HARITA.md ve CLAUDE.md'de B4/B7/B8'in bekleyen farklari var; benimkiler own_markers'taki hunk'lardir. Birkac yerde (smoke, HARITA, motor md, incident_system basligi) tek parca, tam eslesmeli Python oku-degistir-yaz kullandim; eszamanli yazim cakismasi gozlemlemedim ama ana oturum commit'te smoke ve incident_system diff'ini baska adimlarin satirlari acisindan gozden gecirsin. 2) Genis kosu tamamlanmadi: 28 vakalik sprint/soz/acil durum/surum kumesinin ilk 12'si (incident_*, release_thanks_*, release_through_close) ve ek olarak sprint_two_days_close, sprint_never_stalls_in_plan, sprint_departure_restaffs_card, sprint_solo_mvp_by_week_six yesil; makine yavas oldugu icin geri kalan (sprint_capacity_from_team, sprint_team_follows_job_matrix, sprint_carry_keeps_progress, sprint_fix_*, sprint_starts_only_with_consent, promise_due_sprint_*, promise_row_locked_when_no_room, event_trust_delta_lasting, event_morale_payers, product_pm_plan_opens_as_next_sprint) Haiku'nun kapilarina birakildi; _begin ve _end_week yeniden siralamasi (once atama, sonra kagit) icin en riskli vakalar yukaridaki yesil olanlardir. 3) Konusan yalniz B6'da yazilacak kartlarda gorunur: bugunku alti kagit konusansizdir ve masa gondericisiyle gelir; gorsel kabul bu yuzden fiksturle yapildi. product.sprint_late (sistem kagidi) bugun decision.cards listesindedir; B6b 40 kimlikli listeyi yazarken onu listede mi tutacagina ya da ona ayri bir istek yolu mu yazacagina karar vermeli, yoksa hic gelmez. 4) pool_group'u motor okumaz (olcum grubu); B6b 4.12 sayimini konusanin rolunden ya da bu alandan yapabilir. 5) Konusan, kartin o anki fazinda calisan atananlardan secilir: 2 haftalik sprintte ilk hafta sonunda tasarim genelde bittigi icin tasarimci kagitlari neredeyse yalniz 1 haftalik sprintte (baslarken) gelir; B6b olcumunde tasarimci kagidi sayisi dusuk cikarsa bu sebeple, uyari olarak raporlanmali. 6) shot kolu main.gd'de EvTuning.SHIPPED_SCOPES'a fixture ekler (shot sureci boyunca) ve decision_paper kolunda izindeki gelistiriciyi geri dondurur; baska shot'lari etkilemez.

### İnceleme düzeltmeleri
Tek düzeltme turu:
1. Karar 12 yanlış uygulanmıştı. Kâğıtlı sprintte yalnız `outage` yaşıyordu, oysa B0v §B3.7 ve W1'in `severity` alanı ödeme arızasını da (`checkout`) "servis çöktü" sayar.
   - incident_system.gd'ye `const SERVICE_DOWN := ["outage", "checkout"]` eklendi.
   - `daily_tick`'teki koşul `kind not in SERVICE_DOWN and SprintSystem.paper_sprint()` oldu.
   - Başlık yorumu buna göre güncellendi.
2. Gerçek bir boşluk vardı: sürümün ertesi sabahında (bozulmanın, yani `regression`'ın doğal günü) oyuncu 1 haftalık sprinti acil durum kartı saatinden önce başlatırsa, kâğıt ve 00:00'da zarı atılmış bozulma aynı sprintte gelebiliyordu. `_paper_blocked` artık `GameState.incident.pending`'de servis çökmesi dışında bir tür bekliyorsa kâğıdı kapatıyor.
   - `paper_interrupt_order`'a falsification'lı bir dal eklendi: bekleyen `checkout` kâğıdı kapatmaz, bekleyen `regression` kapatır.
3. `[WORKING]` işareti `decision.sprint_chance` ve `decision.seen_weight` için `_request_decision` yorumuna eklendi.
4. HARITA'nın `urun.*` seam satırında bayat bir ifade vardı ("oran `decision.rate`; zar koşu tohumunu da okur"). Yerine `decision.sprint_chance` yazıldı.
5. CLAUDE.md, HARITA, motor md §27.33 ve GUNCELLEMELER'deki "yalnız servis kesintisi" ifadesi "servisin çöktüğü tür (kesinti, ödeme)" olarak düzeltildi. HARITA'daki `_paper_blocked` tarifine bekleyen acil durum eklendi.

Uygulanamayan: `_request_decision`'daki `given["founder" if …category == "founder"…]` satırını `role == ROLE_FOUNDER` olarak sadeleştirdim, ama bu sırada B6 ajanı aynı fonksiyonu yeniden yazdı (`speaker_role` artık liste: `roles`; `account` ve `_paper_account` eklendi). Benim satır değişikliğim onun yazımıyla gitti. Liste hâlinde kategori okuması doğru olduğu için yeniden uygulamadım.

Yeniden koşulanlar:
- `paper_interrupt_order` PASS.
- `incident_gap_and_spread` PASS.
- `--event-lint` PASS.

## B6a · `ea3c20c`
**Başlık:** Faz B B6a: Sprint ortasında PM, tasarımcı ve testçi kâğıtları gelir (21 kâğıt; pazara özgü seçeneği olan dördünün B2C ikiziyle havuzda 25 kimlik). Oyuncu kartın işini sonraki sprinte bırakabilir: kart puan kaybeder, takip kartı sonraki sprinte girer. Kartı bilinen hatayla da çıkarabilir: hata kart çıkınca kendi hattında açık hata olur. İsteyen hesabı yenilemeden önce kartı sprintin başına alabilir ya da bir ay indirim verebilir. Hesabı "kart çıkana kadar" bekletirse her sprint sonunda memnuniyet bedeli öder. Çip kartın bu sprintte bitip bitmeyeceğini ve kayan kartın adını yazar. Renk kâğıtları iki gelişi olan tek karttır. Yenileme günü tek yerden okunur (SprintBridges.next_renewal_day). TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
Bu adımın PRD §4 maddeleri:
- 4.9 Kapılar: ✅ `--event-lint` düzeltmeden sonra da temiz: "LINT PASS 0 error(s), 0 warning(s), 7 baselined, 148 card(s)". loc_residue 0 hit ve loc_csv_integrity PASS (Haiku). `--why-fire` 25/25 kart için çalıştı. plausibility_run.sh: fails=0 (40 koşu) ve LONG fails=0 (4 × 60 hafta). ⚠️ `--why-fire`'ın 25 sonucunun hepsi "REFUSED AT G4" (başlangıç bağışıklığı); koşul ağaçları canlı yolda yalnız smoke ile sınandı. ⚠️ run_gate.sh bu adımda koşmadı (B6b'nin entegrasyon ölçümü).
- 4.2 Bedel çipteki sayıyla aynı: ✅ Çip ile geçmiş satırı aynı metni okur. Vakalar: paper_card_trim (8 puanlık kartın %40'ı: 4 puan çıkar, sonraki sprinte 5 puan kalır; çip = satır), paper_renewal_card_first (kayan kart çipi = satır), paper_trust_until_ships (EFFECT_TRUST_UNTIL_SHIPS çipi = satır, drain step_live kartın kademesi), paper_outlook_reads_the_plan. b2b_month_discount `FinanceSystem.apply_one_time_cost(..., "retention")` ile yazar, MRR'a dokunmaz (effects.gd b2b_month_discount kolu).
- 4.6 Konuşan kişi: ✅ PM kâğıdını çeyreğin PM'i söyler ve konusu müşteri isteği kartıdır. Bunu B5'in `_speaker`'ı zorlar (`c.kind == "request"`, sprint_system.gd `_speaker`) ve hesap istek kartının `customer_id`'sine bağlanır (`_request_decision`). Kanıt `_paper_pm_asked`: konuşan quarter_pm, hesap co_asked. Tasarımcı ve testçi kâğıdında konuşan kartta o fazda çalışan kişidir: paper_cards_are_asked (drawings_late tasarımcı; stock_transfer ve readonly_delete testçi, `dev` slotu yazılımcı; depo hesabı line_warehouse). Benim tekrar koşumda PASS.
- Karar 11/13 (havuz, KDV kâğıdı yok): ✅ 25 dosya `sprint_(pm|design|test)_*`, `decision.cards`'ta. `kdv|vat` araması hiç sonuç vermedi. Eski renk kâğıtları ve 8 CSV anahtarı silindi; paper_colors_two_arrivals eski kimliklerin oyunda olmadığını da sınar.
- Onaylı metin bayt bayt: ✅ textparity W2: checked=270, missing=0 (chip seti dahil); ön ek seti checked=258, missing=0.
- 4.10 Görsel kabul: ⚠️ PRD her yeni kartın çekilmesini ister; yalnız 3 kart çekildi (scope_grew, drawings_late, test_too_much; TR ve EN). PNG'leri açtım: taşma ve kesilme yok, dil doğru, konuşanın adı ve rolü görünüyor. ⚠️ test_too_much çekiminde "Test every path" seçeneğinin çipi "Stock Count finishes this sprint" diyor, gövde ise "the card won't finish this sprint". Neden: `main._seed_paper_world` kartı geç kalmış kurmuyor (koşul `urun.decision_card_late` çekimde sınanmıyor). Oyunda bu çelişki çıkmaz, çünkü kâğıt yalnız kart geç kalmışken gelir. Yine de görsel kabul için bu kare yanıltıcı.
- 4.5 / 4.12 (kâğıt sıklığı, her rol gelir): ⚠️ bu adımda ölçüm yok, B6b ölçecek. Gelmesi C'ye bağlı olanlar: pm_two_accounts (`urun.decision_second_account` bugün hiç dolmuyor) ve üç B2C PM kâğıdı (`urun.decision_request_votes` sabit 0). PM rolü 4.12'de ⚠️ çıkabilir.
- Write-through ve UI/STYLE: ✅ Kart, sahibinin seam'leri üzerinden yazar (SprintSystem.decision_trim/decision_first, FinanceSystem.apply_one_time_cost, CustomerRegistry.set_trust_offset, B2BSalesSystem.add_trust_drain). Ham renk ya da ham boyut yok (değişen tek UI yolu bir debug çekim kurulumu).
- [WORKING] sabitleri: ✅ hepsi tek blokta, `sprint.json` `paper`. JSON yorum taşıyamadığı için [WORKING] işareti SprintCatalog bölüm başlığında ve HARITA'da.

### Onay bekleyen
Onay bekleyen sabitler (sprint.json `paper`):
- trim_share 0,4 (kartın %40'ı, yukarı yuvarlanır)
- reopen_points +1
- ask_silent_mult ×5
- phone_points +2
- contract_per_point $1.000 (B6b ile ortak)
- b2c_loss: small %0,5, mid %1
- renewal_discount %20 (bir ay, bir kez, `retention` etiketi)
- first_screen_loss: haftalık yeni kullanıcı × %10 × 8 hafta
- coupon_share: kitlenin %1'i (R3 (a), kitle kaybı olarak)
- test_phones $1.200 (etiket `user_tests`; R8 açık)
- slow_seats 15
- warehouse_sectors: logistics, manufacturing, retail
- colors: hand 2, central 4, again_extra +1

Yenileme penceresi ayrı bir sabit değil, `request.before_renewal_weeks` 12 kullanılıyor.

Kart literalleri:
- trust −8 (renk, as_is)
- −6 ve her sprint −3, kart çıkana kadar (phone_too desktop, renewal let_wait)
- dev_helps verim −%30 · 1 hafta
- test_all +1 puan; renk ikinci gelişte süre dolarsa kart +3
- bütün ±puan miktarları (PAPER_POINTS_SCALE'i D ×5 yapacak)

Metin: W2'nin 21 kâğıdı ve EFFECT_NEXT_SPRINT_WORK(_ONE), EFFECT_CARD_LATE, EFFECT_CARD_ON_TIME, EFFECT_SHIP_BUGS(_ONE), EFFECT_ONE_MONTH_DISCOUNT, EFFECT_TRUST_UNTIL_SHIPS. TR/EN onay bekliyor. W2'de `{employee}` belirteci `{dev}` oldu; dalga dosyası commit'lenmiyor.

Erdem'e ⚠️:
- Pazara özgü seçenek gizlenemediği için 21 kâğıt 25 kimlik oldu.
- pm_two_accounts ve üç B2C PM kâğıdı C'ye kadar uykuda.
- Yaklaştırmalar: depo sektörü kuralı, `sprint_dev` = sprint payı en büyük yazılımcı, drawings_late koşulu, dev_helps ilerlemesi, coupon yalnız Entegrasyonlar hattında ve ücretli plan açıkken.
- Görsel kabul 3/25 kartta.

### Sabitler (kod ajanı)
- PAPER_TRIM_SHARE 0,4 (kartın %40'ı, yukarı yuvarlanır), PAPER_REOPEN_POINTS +1, PAPER_ASK_SILENT_MULT ×5, PAPER_PHONE_POINTS +2 (sprint.json paper)
- PAPER_CONTRACT_PER_POINT $1.000 ve PAPER_B2C_LOSS %0,5 / %1 (sprint.json paper; B6b ile ortak)
- RENEWAL_DISCOUNT %20 (aylık ücret, bir kez); RENEWAL_WINDOW = request.before_renewal_weeks 12 (ayrı sabit değil: yenileme bu sprintin kapanışından sonra, sonrakinden önce olmalı)
- FIRST_SCREEN_LOSS: haftalık yeni kullanıcı × %10 × 8 hafta; COUPON_SHARE %1 (kitlenin; R3 öneri (a): kitle kaybı olarak yazıldı, ödeyen ÷ dönüşüm = kitle × %1); TEST_PHONES $1.200 (etiket `user_tests`, R8 açık)
- SLOW_SEATS 15; depo sektörleri logistics, manufacturing, retail; renk kâğıdı el 2 / tek dosya 4 / ikinci gelişte +1; serbest çalışan = el puanı × contract_per_point
- Kart literalleri (JSON'da): PAPER_TRUST_HIT −8, PAPER_TRUST_WAITING −6 ve her sprint −3, PAPER_MORALE_ONE −4, dev_helps verim −%30 · 1 hafta, bütün ±puan miktarları (PAPER_POINTS_SCALE: D ×5 yapacak); süre dolumu bedelleri (renk ikinci gelişte kart +3)

### Metinler (kod ajanı)
- Yeni, dalgada olmayan CSV metinleri: EFFECT_NEXT_SPRINT_WORK_ONE (EN 'point of work left'), EFFECT_SHIP_BUGS_ONE (EN '1 open bug at release'); TR ikisinde çoğulla aynı
- Belirteç adı değişti (TR/EN, 2 etiket): test_readonly_delete 'dev_tonight' ve test_too_much 'dev_helps' etiketlerinde {employee} -> {dev} (konuşan {employee} slotunda, adı geçen yazılımcı {dev} slotunda; dalga dosyası W2_KAGITLAR.json da aynı commit'te güncellendi, kelime değişmedi)
- Renk kâğıdının ikinci gelişinin süre notu eski onaylı metin (TR/EN, CSV'den bayt bayt): '{customer} şikâyet etti, ekip sayfaları elle değiştirdi.' / '{customer} complained, and the team changed the pages by hand.'; kartta varyant kümesi olarak durur (W2 yalnız ilk gelişin notunu taşır)
- Bütün 21 kâğıdın metni W2'den bayt bayt, TR/EN onay bekliyor

### Riskler
["PAZARA ÖZGÜ SEÇENEK: motor seçeneği gizleyemiyor (kilitli seçenek görünür kalır, lint §17.8) ve PRD tek kimlik istiyor; phone_too, spec_unclear, empty_state, slow_many B2B kartı + `_b2c` ikizi oldu (25 kimlik, 21 değil). Bunu Erdem'e raporda ⚠️ olarak söyle.", "UYKUDA/GELMEYEN: pm_two_accounts (`urun.decision_second_account` bugün hiç dolmaz: bir kademeyi tek hesap isteyebilir, R4) ve PM'in üç B2C kâğıdı (phone_too_b2c, spec_unclear_b2c, core_first; `urun.decision_request_votes` C'ye kadar 0, B2C'de istek kartı yok). Kodlu ve lint temiz, gelmeleri C'ye bağlı.", "YAKLAŞTIRMALAR (⚠️): 'çok depolu hesap' verisi yok, test_stock_transfer ve design_gloves depo sektörü kuralıyla bağlanıyor; 'kartı yazan yazılımcı' kayıtlı değil, `sprint_dev` ekibin sprint payı en büyük yazılımcısı; drawings_late'in 'geliştirme payı atanmış biri bekliyor' koşulu 'bu haftanın işiyle tasarım bitmiyor ve ekipte yazılımcı var'; dev_helps'in 'testi sprintte biter' iddiasını kalan test işinin yarısı kadar ilerleme (+ çip 'kart −N puan') taşır, W2'nin örnek çipi yalnız verim satırını gösteriyordu; test_coupon yalnız Entegrasyonlar hattı + ücretli plan açıkken (B0 kararı, ücretli plan kartı tetiklemez); 'Kuponları kapat' R3(a): kitle kaybı olarak (ödeyen ve MRR dolaylı).", "PAYLAŞILAN DOSYADA BAŞKASININ HUNK'ına dokundum: sprint_system.gd `fix_first_bumps` (first_bumps'a indirildi, B4), `_unfinished`'a `(id, extra)` parametresi, effects.gd `_named` (varsayılan dönüş in_product), engine.gd süre dolumu (expire_note varyantı, B5). Commit'te hunk düzeyinde ayrılmalı. B6b ağaçta aynı anda `card_ref`, `_card_points`, `paper_account` `request` kipi, `urun.decision_line` (temel kimlik) eklemişti; benimkilerle birleşti, `decision_line` temel kimlik döndüğü için kart koşullarım temel kimlikle yazıldı.", "Motor değişikliği küçük ama kapsamlı: `expire_note` artık varyant kümesi olabilir (yalnız renk kâğıdı kullanıyor). Eski kayıt etkilenmez; takip kartı (`follow`) yeni alan, `.get` ile okunur.", "SPRINT.JSON PAYLAŞIMI: `paper` bloğu B6b ile ortak; ben `test_phones` ve diğerlerini ekledim, B6b harden_weeks, root_min, signup_loss, license vb. ekledi. B6b EFFECT_CARD_POINTS, EFFECT_WORK_LOST, EFFECT_NEW_BUGS, EFFECT_LINE_HARDEN, EFFECT_FIX_FRONT anahtarlarını ve eski EFFECT_SPRINT_EFFORT/PROGRESS silmesini yaptı (CSV'de yok, doğruladım).", "ÖLÇÜM YOK: bu adımda 104 haftalık/10 tohumlu ölçüm yapılmadı (B6b'nin işi); yalnız iki tohumla 60 hafta plausibility ön ölçümü (fails=0, sprint_test_after_midnight ateşlendi). Koşullu kâğıtların çoğu dar tetikli (kart gecikmiş + payı çıkınca yetişiyor gibi) ve botun oynadığı koşuda nadir gelir; 'her kâğıt rolü gelir' (§4.12) B6b ölçümünde PM için ⚠️ çıkabilir (B0_ESIKLER §3.4).", "Finans etiketi: test_devices 'user_tests' (Kullanıcı denemesi) satırına yazılıyor; R8 (yeni satır mı) çözülmedi. pm_renewal indirimi 'retention' (Bağlılık primi) satırında."]

### İnceleme düzeltmeleri
Bir düzeltme turu yaptım, iki gerçek bulgu:
1. scripts/events/gate/scope.gd `_select_employee` "sprint_dev" kolu: satır devamındaki `\` kaybolmuş, ifadenin ortasında 6 sekme kalmıştı (`if pool.has(...)  <TAB×6> and ...`). Ayrıca `get_character(id)` iki kez çağrılıyordu. Yeni hâli: `var dev: Character = CharacterRegistry.get_character(id)` ve `if pool.has(dev) and dev.role == HRConstants.ROLE_DEVELOPER:`.
2. scripts/events/seams/seams_product.gd `urun.decision_contract_cost`: aynı bozulma (`trim_points(...) <TAB×4> * int(...)`). Satır devamı `\` ile geri kondu.
3. docs/HARITA.md Ürün "Kâğıt içeriği" maddesinin vaka listesine eksik kalan `paper_cards_are_asked` eklendi.

Denenip geri alınan: B2B PM kartlarının `customer` slotuna `select: request` eklemeyi denedim (konu istek kartının hesabı olsun diye). Falsification gösterdi ki B5'in `_speaker`'ı PM kâğıdını zaten yalnız `kind == "request"` kartında getiriyor ve hesap `given` ile bağlanıyor, yani ekleme gereksiz bir savunmaydı. Kart değişikliği, eklediğim smoke parçası ve HARITA notu elle geri alındı. Kartlar özgün hâlinde, JSON doğrulandı.

Kalan, düzeltilmeyen notlar:
- sprint_system.gd `design_late(id)`'in belge yorumu "Bekleyen kararın kartı" diyor, oysa id alıyor (küçük).
- `urun.colors_again` (bool) ve `urun.colors_first` (int) aynı bayrağın iki yüzü. İkisi de amount_seam'de kullanılıyor; zararsız ama simetrik değil.
- test_too_much görsel çelişkisi yukarıda (çekim kurulumu).
- endgame_smoke.gd'de satır ortasında sekme kalan iki eski satır daha var (1060, 13294) ve biri B4/B5 bölgesinde (19282). Bu adımın değiller, dokunulmadı.

Düzeltmelerden sonraki kapılar: LINT PASS (148 kart); SMOKE PASS paper_cards_are_asked, paper_account_selectors, paper_cards_render, paper_renewal_card_first. Parse, Compile ya da instantiate hatası yok.

## B6b · `ea3c20c`
**Başlık:** Faz B B6b: Yazılımcının 10, testçisiz ekibin 3 ve tek kurucunun 6 kâğıdı ile "Kart sprinte yetişmeyecek" sistem kâğıdı (ekip ve kurucu tek için ayrı kart) havuza girdi. Her seçenek bedelini çipte sayıyla gösterir: kartın adıyla puanı ("Toplu Fatura +2 puan"), kısa yola geçince boşa giden iş, dışarıdan iş ve lisans parası, hemen düşen açık hata ve hattın yeniden yazımı ("Fatura: 26 hafta yeni hata çıkmaz": o hatta bildirimden ve kapanış zarından hata düşmez, oyuncunun seçtiği hata yine düşer). "Ana akışları test et" kartın testini yarıya indirir, çip yüzde yazmaz. "Kart sprinte yetişmeyecek" yalnız sözsüz bir müşteri isteği kartı fazla mesaiyle yetişecekken gelir; ekipte çalışanların morali −5, kurucu tekken verimi 1 hafta −%15. Eski "İki yol var", "Dışarıdan destek", "Arayüz baştan yazılmış" ve üç takip kâğıdı kalktı. TR/EN onay bekliyor, sabitler onay bekliyor

### Kabul
Kapsam: B6b içerik bölümü (ölçüm ayrı adım, brief "ölçüm yok").
- Karar 11 Havuz 40: ✅ decision.cards = B6a 21 (+4 _b2c ikizi) + B6b 19 + 2 sistem kâğıdı (sprint.json decision.cards); paper_card_effects "21 kâğıt havuzda ve gösterilir" PASS.
- Karar 10 Konuşan: ✅ _speaker rol listesi (sprint_system.gd _speaker), paper_speaker_is_assignee PASS (kapı raporu); sprint_late konuşanı kartın o aşamadaki çalışanı, kurucu tekken sprint_late_solo (sprint_late_for_requests PASS, ben de yeniden koştum: PASS).
- Karar 12 Sıklık/mandal: ✅ her kâğıtta latch {52, 3}, unasked_rewrite one_shot, sprint_late/_solo {26, 3}; kesinti sırası _paper_blocked (B5) + sprint_late havuzdan geçtiği için tek kesinti sayılır. ⚠️ sprint_late zarla gelir (decision.sprint_chance 0,3/0,5): bekleyen istek kartı her geride kalışta kâğıt almaz, havuz kâğıtlarıyla yarışır; W2 "öbür durumlarda sessizce devreder" ile uyumlu ama Erdem'e not.
- §3/§4 yazım, bayt eşliği: ✅ textparity W2 checked=246 missing=0 (çip şablonları dahil) ve 236/0; byte-span CSV, loc_csv_integrity PASS, loc_residue 0 hit (yeniden koştum: CLEAN).
- §4.2 Bedel = çip: ✅ paper_card_effects (WORK_LOST seam'den, kart adıyla puan, anlık hata tekil/çoğul, test kesmesi yüzdesiz) PASS; event_chip_coverage, event_history_chip_matches_live PASS (kapı raporu).
- §4.6 vakalar yeniden: ✅ paper_speaker_is_assignee, decision_one_per_sprint, decision_no_fourth_show, paper_interrupt_order, paper_empty_sprint_ratio PASS (kapı raporu).
- §4.9 Kapılar: ✅ event-lint 0 hata (düzeltmeden sonra yeniden: LINT PASS 0/0, 148 kart); why-fire 21 kart G4'te (istek kartı, beklenen); plausibility LONG runs=4 fails=0; run_gate 3/3 RUN OK errs=0. ⚠️ _close zarı değişti: plausibility ve run_gate yeniden koşulmalı (rerun).
- §4.10 Görsel: ⚠️ 21 kartın 3'ü TR/EN çekildi (sprint_dev_contractor, sprint_untested_own_code, sprint_solo_license); baktığım iki karede taşma yok, çipler kart ve hat adıyla doğru dilde. Öbür 18 kart (özellikle untested_old_screens'in kurucu varyantı ve kilidi, sprint_late/_solo) çekilmedi.
- §4.1, §4.5 ölçüm, §4.11, §4.12: ⚠️ bu adımda yok (brief); ayrı ölçüm adımı.
- §9 inceleme: kısa ve doğrudan; yardımcılar yeniden yazılmamış (FinanceSystem/ProductState.add_bugs/SprintCatalog.in_product kullanılıyor); write-through doğru (harden_line ProductState'ten, bayrak FLAG_TYPES'ta); sabitler sprint.json paper bloğunda, HARITA/motor md'de [WORKING]. Küçük not: scope.gd sprint_dev satırındaki tab boşluğu B6a'nın satırı, dokunmadım.

### Onay bekleyen
Sabitler (sprint.json paper, [WORKING]): harden_weeks 26, root_min 3, signup_loss 0,3 (haftalık yeni kullanıcı payı), outside_week_mult 1,5 (örnek $1.400), license {per_seat 6, per_user 0,3, min 1200}; B6a'nın contract_per_point 1000 ve b2c_loss {0,005, 0,01}. Kart içi sayılar: hesap izi −8 (multi_currency, import_tool, solo_watch); verim −%40/1 hf (import_tool), −%30/1 hf (founder_test_pile), −%20/2 hf (unasked_rewrite okuma, solo_rushed_code), −%15 (untested_own_code 1 hf, solo_watch 2 hf, sprint_late_solo 1 hf), −%10/1 hf (old_screens); moral +4/+6/+8/−8, süre dolunca −10 (unasked_rewrite), −3 (import_tool), −5 (sprint_late sprint_crew); efor ±1/2/3. Koşul eşikleri: efor ≥5, decision_tier 2–3, hattı ≥2 hesap (backfill), yeni hesap ≤8 hf, ≥12 hf yazılımcı, ürün ≥24 hf, kadro ≥3, ay sonuna ≤2 tik (W2 "2 haftadan az"; ≤1 de okunabilir), security_tier ≥1 (yeni, inceleme düzeltmesi), mandallar 52/3 ve 26/3, unasked_rewrite one_shot. Etiketler: sunucu faturası add_cash 'incident' (Kesinti gideri; R soru 8 önerisi), dış kaynak 'contractor', lisans 'build_commit'. Tasarım kararı (W2 açık sorusu, raporlanmalı): yeniden yazılmış hatta zarla gelen hata düşmez, oyuncunun seçtiği hata (çıkış hatası, anlık hata) düşer. W2'den sadeleştirmeler: solo_watch aşaması any, unasked_rewrite konuşanı kartın ilk ≥12 hf yazılımcısı, founder_test_pile "bir haftadır" = testi hiç başlamamış, untested_own_code "Testi sen yap" izin kilidi yok, "ilk sürüm" = v≤1.0 sürümleri, sprint_late zarla gelir. Metin: 21 kartın TR/EN'i ve 9 yeni çip anahtarı (EFFECT_CARD_POINTS[_ONE], EFFECT_WORK_LOST[_ONE], EFFECT_NEW_BUGS[_ONE], EFFECT_LINE_HARDEN, EFFECT_FIX_FRONT, EFFECT_SPRINT_HOURS_SOLO; _ONE EN biçimleri ve SPRINT_HOURS_SOLO W2'de şablon olarak yok, örnek çipten türetildi) TR/EN onay bekliyor. Görsel: 18 kart TR/EN çekilmedi.

### Sabitler (kod ajanı)
- sprint.json paper: harden_weeks 26, root_min 3, signup_loss 0,3 (haftalık yeni kullanıcı payı), outside_week_mult 1,5, license {per_seat 6, per_user 0,3, min 1200}; contract_per_point 1000 ve b2c_loss {small 0,005, mid 0,01} B6a'nın bloğundan okunur
- Kart içi sayılar [WORKING]: hesap izi −8 (multi_currency, import_tool, solo_watch), verim −%40/1 hf (import_tool), −%30/1 hf (founder_test_pile), −%20/2 hf (unasked_rewrite okuma, solo_rushed_code), −%15 (untested_own_code 1 hf, solo_watch 2 hf, sprint_late_solo 1 hf), −%10/1 hf (old_screens), moral +4/+6/+8/−8, süre dolunca −10 (unasked_rewrite), −3 (import_tool), −5 (sprint_late ekip fazla mesaisi, sprint_crew), efor ±1/2/3 ve hata sayıları W2 doğrultusunda
- Koşul eşikleri: efor ≥5, decision_tier 2-3, hattı ≥2 hesabın kullanması (backfill), yeni hesap ≤8 hafta (import_tool where), ≥12 haftalık yazılımcı, ürün ≥24 hafta, kadro ≥3 (unasked_rewrite), ay sonuna ≤2 tik (server_bill), mandal 52 hf/3 kez (kâğıtlar), 26 hf/3 kez (sprint_late, sprint_late_solo), one_shot (unasked_rewrite)
- sunucu faturası etiketi: add_cash label 'incident' (Kesinti gideri / Incident costs): R soru 8'in 'var olan en yakın satır' önerisi, onay bekliyor

### Metinler (kod ajanı)
- 21 kartın tüm metni W2'den bayt bayt (başlık, gövde ve gövde varyantları, seçenek etiketleri, kilit gerekçesi, süre doldu notu): TR/EN onay bekliyor
- Çip şablonları W2'den bayt bayt bağlandı: EFFECT_CARD_POINTS, EFFECT_WORK_LOST, EFFECT_NEW_BUGS, EFFECT_LINE_HARDEN, EFFECT_FIX_FRONT; kod ajanının türettiği tekil biçimler (W2 'EN tekil biçim gerekir' dedi): EFFECT_CARD_POINTS_ONE EN '{card} {v} point', EFFECT_WORK_LOST_ONE EN '{n} point of finished work is lost', EFFECT_NEW_BUGS_ONE EN '{line}: {n} new open bug'
- EFFECT_SPRINT_HOURS_SOLO (EN 'Your work hours ×{v} this sprint' / TR 'Bu sprint çalışma saatin ×{v}'): W2'nin sprint_late crunch_solo örnek çipinden, kurucu tekken fazla mesai çipi
- Silinen eski metinler (onaylı eski kâğıtlar): İki yol var, Dışarıdan destek, Arayüz baştan yazılmış ve üç takip kâğıdı; karşılıkları W2'nin yeni kartları

### Riskler
["Paylaşılan koda dokundum, ana oturum hunk ayırırken bakmalı: (a) B5'in _request_decision/_speaker'ı speaker_role'ü rol listesi kabul ediyor (sprint_late ve untested_old_screens tek rolle söylenemiyor); lint §17.7 listeyi öğe öğe sınıyor; (b) B7'nin crunch_finishes'ı: kâğıt istenirken karar kartının atananları henüz silinmemiş olduğundan fazla mesai yetiştiriyor mu hep false çıkıyordu ve sprint_late hiç gelmiyordu (mutasyon 10 bunu kanıtlıyor); artık kartın kendi atananı sayılmıyor; (c) B6a'nın scope.gd/paper_account'una 'request' kipi eklendi (karar kartını isteyen hesap); (d) lint: speaker_role taşıyan kartta O4 uygulanmaz (kâğıdın konusu sprint kartı), sprint_card_test ve sprint_fix_first WRITER_VERBS'e geçti, sprint_fix_first O2 için sonuç fiili; (e) B6a'nın paper_cards_render ve sprint.json decision.cards satırı ile aynı dosya/satırlarda eşzamanlı çalıştım, her yazma tam eşleşmeli tek parçaydı ama son bir kez farkı elle gözden geçirmek gerek.", "Tasarım kararı (W2'nin açık sorusu): _land_faulty artık line_blocked'a soruyor; gerekçe: çip '26 hafta yeni hata çıkmaz' diyor ve söz hatalı kapanışın hatasını da kapsamalı. Yan etki: B6a'nın sprint_card_trim {bugs} çipi ('çıkışta N açık hata') yeniden yazılmış hatta hata düşürmez; aynı hatta önce yeniden yazım sonra trim seçeneği nadir bir tutarsızlık. damage_product (oyuncunun kendi seçtiği anlık hata) hat kapalı olsa da düşer.", "sprint_late iki karta bölündü (product.sprint_late ekip, product.sprint_late_solo kurucu tek): motor seçeneği gizleyemiyor, W2'nin ekip ve kurucu fazla mesaisi ayrı seçenekler ve kilit metni yazılmamış. Toplam 19+2 = 21 kart; 'sistem kâğıdı 40'a sayılmaz' kuralı iki kimlik için de geçerli. B2C varyantları metinde var ama B2C istek verisi (urun.decision_request_votes, B6a'da 0) C'ye kadar olmadığı için ulaşılamaz.", "W2'den bilinçli sadeleştirmeler: solo_watch aşaması 'any' (W2 verisi 'design', WHEN 'tasarım ya da geliştirme'); unasked_rewrite konuşanı 'en kıdemli' değil kartta çalışan ilk ≥12 haftalık yazılımcı (motor seçici yok); founder_test_pile 'bir haftadır bekliyor' = kartın testi hiç başlamamış (urun.decision_test_untouched); untested_own_code 'Testi sen yap' için izin kilidi yok (W2 kilit metni yazmadı); solo_rushed_code 'ilk sürümde açılmış hat' = v1.0 ve öncesi sürümlerde kartı çıkmış hat; solo_backup 'Otomatik Kayıt dışında kademe yok' = durability kademesi 1.", "Etiketler: sunucu faturası 'incident' (Kesinti gideri) ile yazılıyor, R soru 8'in önerisi; dış kaynak 'contractor' (Dış kaynak ücreti), lisans 'build_commit' (Özellik maliyeti).", "Eski vakalar değişti: sprint_decision_blocks_progress, promise_due_fires_when_late, event_history_chip_matches_live artık gerçek sprint_late yerine yeni fixture.paper_crunch kullanıyor (geride kalan kart için konuşansız kâğıt); sprint_decision_card_fires_shipped gerçek havuzdan tek kurucunun lisans kâğıdını (product.sprint_solo_license) bekliyor; sprint_late_only_when_behind kaldırıldı, yerine sprint_late_for_requests geldi.", "Harness: --product-shot=live:decision_paper:<kart id> (main.gd) gerçek bir kâğıdı ister, tek kartlı sprint ve kâğıdın aşamasına uyan ilerleme kurar, 'Karara git' ve 'Cevapla'ya basar; kare cevap açıkken çekilir. Yalnız yazılımcı, testçisiz ve tek kurucu kâğıtları için denendi (üçü de bakıldı: kâğıt çip ve etiketlerle taşmadan görünüyor); öteki kâğıtlar için ilerleme tablosu gerekebilir.", "Falsification scratchpad'deki proje kopyasında yapıldı (gerçek ağaca dokunmadan): 18 kural bozma, hepsi ilgili vakada FAIL; kopyada taban 4 vaka PASS. Kapıların tamamı (plausibility_run, run_gate, tam smoke) koşulmadı; kısa plausibility (SEEDS=2, 4 koşu) fails=0 ve kâğıtlarım PLAUS FIRE'da görünüyor.", "Beklenmedik yan bulgu: B6a'nın event_chip_coverage hatası ve smoke dosyasındaki '\\n' parse sorunu ben çalışırken kendiliğinden düzeldi, bana ait değil. Brief'teki 'Not video kâğıdı yok' ve 'ölçüm yok' uyuldu; §4.1/§4.5/§4.11/§4.12 ölçümü ayrı adımda."]

### İnceleme düzeltmeleri
Tek düzeltme turu:
1) Yeniden yazılmış hatta çip yalanı: kod ajanı _land_faulty'ye line_blocked koymuştu; bu B6a'nın sprint_card_trim {bugs} çipini ("çıkışta 1 açık hata") yeniden yazılmış hatta yalan yapıyordu (leaks da pending_faulty'den geçiyor). Kural artık: zarla gelen hata (saatlik bildirim, kapanışın hatalı çıkma zarı) kapalı hattı atlar, oyuncunun seçtiği hata (leaks, damage_product) düşer. sprint_system.gd _close'da zar `not ProductState.line_blocked(c.line)` ile koşullandı, _land_faulty HEAD hâline döndü; product_state.gd line_blocked yorumu güncellendi. paper_line_harden vakası: çıkış hatası kapalı hatta düşer (3 hata) ve yeni blok: kurucunun test rolü olmadan test ettiği iki kartın kapanışında yalnız açık hattınki faulty'ye girer. Falsifikasyon (scratchpad/mirror, b6b_rev_fals.py): taban PASS; zar koşulunu sil → FAIL ("rolled faulty [stock, cashflow]"); _land_faulty'ye line_blocked ekle → FAIL ("landed 2, want 3").
2) sprint_dev_security_update kurulmamış Güvenlik hattına hata yazabiliyordu (hat kademesi 0 iken damage_product; düzeltme kartı ve çip var olmayan hattı adlandırırdı). Yeni seam urun.security_tier (seams_product.gd, durability_tier'ın yanında) ve kartın koşulu security_tier >= 1. paper_seams 0 ve 1 kademeyi sınar; falsifikasyon: seam'i 0 döndür → FAIL.
3) HARITA bayat cümleler: Karar kartları listesi (sprint_two_paths/sprint_contractor), "speaker_role yoksa ... sprint_late dahil", ProductState "bugün hiçbir kural hat kapatmaz", _land_faulty cümlesi. Motor md §27.34 ve GUNCELLEMELER kuralı yeni hâle göre; motor md seam listesine urun.security_tier.
4) sprint.json decision.cards'ta eksik boşluk ("sprint_late_solo","sprint_pm_scope_grew").
Koşulanlar (gerçek ağaç): paper_line_harden, paper_seams, paper_card_effects, sprint_faulty_bug_on_card_line, sprint_faulty_pre_launch_lands_at_v1, paper_card_trim, promise_cut_test_escape, sprint_late_for_requests hepsi SMOKE PASS; why-fire sprint_dev_security_update G4; --event-vocab (264 seam) ve gen_signal_manifest yeniden üretildi; event-lint PASS 0 hata; loc_residue CLEAN. İlk lint koşusu bir kez "5 error" verdi, hemen ardından aynı ağaçta 0 hata: paralel adımın yarım yazmasıyla örtüşmüş olmalı, ikinci ve üçüncü koşu temiz.

## Ana oturum · birleşik commit `ea3c20c` (B4, B5, B6a, B6b, B7, B8)
- int_gate (birleşik ağaç): lint 0 hata 148 kart; loc_residue temiz; 71/71 hedefli vaka PASS (altı adımın vakaları + B7'nin promise_* ailesi); run_gate 3/3 (full_run 104 running_on_fumes, b2c 104 running_on_fumes, vc_cautious 68 series_a_close), errs=0; plausibility runs=40 fires=512 fails=0, LONG 4 fires=404 fails=0; --event-vocab ve manifest değişmedi.
- Sprint probu (team=4 fill=1, 2 ve 1 haftalık) ilk koşuda 1 ile çıktı: 3 adsız uyuşmazlık, hepsi `product.sprint_dev_contractor` "Serbest çalışan getir" (yalnız nakit). Kâğıt kartını bekletir, ekip haftanın kalanında başka kartlara geçer (B'den önce de böyle); seçenek kartı değiştirmediği için prob sebep yazamıyordu. Harness düzeltmesi (sprint_probe.gd): kâğıt sorulduğu sprintin uyuşmazlıklarına adını verir. Sonra iki prob exit 0 (78/86, 86/95), B4'ün beş acil durum probu exit 0, promise=1 ve b2c exit 0.
- ⚠️ Açık: `incident=month_close@12` (b2b) 1 adsız uyuşmazlık: aynı tikte team.demo_day ve ay sonu kartı ("Sabah düzelt") gelir, yeniden okunan plan `feat:line_shared_durability_k2` için 1,70 der, kapanış 1,00. B4'ün kapısı `month_close@14` temiz. Tanı ayrı iş (plan sabah düzeltmesinin saatini saymıyor olabilir).

## B4 düzeltmesi · `889b9b8`
- Tanı (Sonnet): `incident=month_close@12` adsız uyuşmazlığı gerçek oyun hatası. Son gece 23:00'te "Sabah düzelt" → `_fix_goes_next` → düzeltme kartı sonraki sprinte; `put_first` `_assign`'ı yalnız `not next` iken yapıyordu, kartın kişisinin haftalık bütçesi boşa gitti, plan 1,70 / kapanış 1,00. Düzeltme: `mode()=="active"` iken atama her zaman. Falsification: eski kod exit 1, yeni exit 0 (`scratchpad/mc_diag/run1.log`, `run2.log`). 8 prob exit 0; incident_sprint_stop_moves_the_card, incident_month_close_window, sprint_fix_first_puts_the_card_on_top, sprint_fix_preview_matches_close, sprint_never_stalls_in_plan PASS; lint PASS.
- Opus incelemesi: mantık doğru (karar kartı ve önden giden kart yolları dahil; eski bayat atanan sorunu da kapandı); yalnız yorum yeniden yazıldı.
- Düzeltilmeyen (R soru 27): sprintte koşan düzeltme kartı da son gece sonraki sprinte itiliyor, yapılan işi hızdan düşüyor (`carried_out`'a girmiyor).
- B6m koşularının bir kısmı düzeltmeden önceki kodla koştu.

## B6m · ölçüm (commit yok)
- Rapor `b_taslak/B6m_OLCUM.md`, loglar `scratchpad/b6m/`. 56 koşu. §4.1 ⚠️ (7/20 koşu 4 olayın altında), §4.5 ⚠️ (hedefler tutuyor; prob team=3 testçisiz, tam spec 104 hafta ölçmüyor, gerçek kâğıt oranı %9,8), §4.11 ❌ (düzeltilmiş okumayla 6 MISS, A'da 4; `_free` aynı), §4.12 ⚠️ (27/46 kâğıt, regression, promise_due, sprint_late hiç gelmedi).
- `fix_tables.py` hatası: `bug_sprint=="True"`; RAPOR_A §4 hata sprinti satırı boş okuma. Düzeltilmiş kopya `scratchpad/b6m/fix_tables_fixed.py`.

## B6v · görsel kabul (commit yok)
- 40/40 kâğıt TR+EN, 80 kare açıldı (`scratchpad/b6v/png/`). Taşma, kesilme, yanlış dil, tire yok. B6a 18/22 ✅; `pm_two_accounts` ve üç B2C PM kâğıdı çekim kurulumunda eksik (B2C PM'de `main.gd:920` SCRIPT ERROR, debug çekim kodu). B6b: yalnız `dev_shorter_path` canlı dünyada bağlandı; 17 kart `--event-shot` ile dünyasız çekildi, çip sayıları doğrulanmadı (smoke'ta).
