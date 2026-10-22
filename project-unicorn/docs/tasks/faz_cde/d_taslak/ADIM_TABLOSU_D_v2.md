# Faz D · Adım tablosu v2 (iki şeritli geliştirme, Karar 24 ve 25)

Taslak 2026-10-22. Onaylanınca `C:\Users\erdem\.claude\plans\sen-project-unicorn-da-faz-playful-bentley.md`'nin "Dalga 3"
bölümünün yerine geçer; eski tablo silinir. Kaynak okumalar: dört okuyucu (iş akışı `wf_ba3766fc-b2f`, HEAD `cf452525`).

## 0. Ne değişti

- **Başlama.** D artık C'yi beklemiyor. Kod adımları Erdem'in açık "evet"ini bekler (ilk kuralı "C bitmeden yazma" idi; yardımcı
  yönetmen soruyu listesine ekledi). Tek ön adım M2 + W2'dir; oyun koduna, `strings.csv`'ye, `data/`'ya ve index'e dokunmaz.
  Yardımcı yönetmenin 2026-10-22 cevapları §4'te; bu tablo onlarla yazıldı.
- **Kararlar.**
  - 24: hata biçimi K-E, toplam hacim K-H, c = 0,212 [WORKING].
  - 25: planlayıcı P.
  - Açık (1): PM kural A.
  - Açık (3): ilke Test'te de işler.
  - Açık (4): ileri oynatma beklenen hatayla.
  - Açık (5): alım sınaması uygulanan yerleşimi oynatır.
  - Açık (6): GDScript süresi ölçülür.
- **Kayıt şeması.** İlk inen adım sıradaki numarayı alır. D1, C3a'dan önce inerse 19 D'nin, C3a 20'yi alır. Göç kolu
  `if version < 19: _migrate_18` biçimindedir (işlev adı kaynak sürümü taşır). Smoke adı D'nin aldığı numarayla
  `save_v19_*` olur (C3a önce inerse `save_v20_*`, kol `if version < 20: _migrate_19`). Sonraki adımların kart ve sürüm
  alanları D1'in listesindedir; listede olmayan alan sonradan eklenirse varsayılanla okunur (`get`), şema açmaz.
- **Bu turda kodlanmayanlar.** Gerekçeleri §3'te.
  - D8c (derinlik kartı) ve D8d (hesap isteği kartı) kart yenilemesine kalır.
  - Devret önerisi satırı, "yalnız bitecek kartlar, en çok bir devreden" kalkanı, "aşama satırı ≤ 2× kapasite" şartı, puan
    başına dolar ÷5 (P3), negatif Δ uzantısı ve `HR_AREA_MEANING_*` metinleri düşer.
  - Eşikli gönder kipi ayarı Erdem'in sözüdür ("ayar olarak durur"); M2 sayfasında Erdem'e sorulur, D3b onun cevabıyla yazılır.
- **Motor.** P, olay düzeyinde bir hafta motorunda ölçüldü (aşama biter bitmez boşalan kişi yeniden dağıtılır). Oyunun bugünkü
  motoru haftalık tek döküm yapar (`sprint_system.gd:1120-1193`): aşama bitiş anı, gereksinim kapısı, "kalır" ve kart başına hata
  yükü yok. Bu yüzden "bugünkü kartlarla" kart verisi demektir, motor yine baştan yazılır (D2a).
- **Süre riski.** Python'da 50 kişide sprint planı 0,53 sn, 25 kişide 0,19 sn sürüyor. Bütçe ise şöyle:
  - Gece tiki 330 hesaplı dünyada ≤ 148,2 ms olmalı; bugün 133,6 ms (`RAPOR_Q.md:110`), plana kalan pay yaklaşık 15 ms.
    O dünyanın ekibi 50 kişi değildir; 50 kişi ve 330 hesaplı dünya D0a'da kurulur.
  - Kare bütçesi 16,7 ms (`tick_probe.gd:13`).
  - Plan ekranı yalnız sprint başı planı koşmaz: her kurulumda her aday için `can_add`, `mvp_eta`'nın 24 haftaya kadar
    haftalık `_takes`'i ve önerinin adayları da koşar (`product_model.gd:222`, `:240`, `:256`, `:293`). Açık (5) ile bunların
    her biri uygulanan yerleşimi, yani tam P'yi oynatır. Python'un 0,53 sn'si bu çarpanı içermez (A8 §4.2).
  - GDScript'in Python'dan hızlı olması beklenmez. 25 ve 50 kişide büyük olasılıkla açık (6) tetiklenir.
  - Bütçe (yardımcı yönetmen): oyuncunun tıklamasında ve iki haftada bir gecede plan ≤ 100 ms, 50 kişilik dünyada ölçülür; gece
    tikinin geri kalanı bugünkü 148,2 ms kapısında kalır. Aşarsa ilk çare oynanışı değiştirmeyen yol: hesap karelere bölünür.
    Hafif kip ya da arayüz değişikliği ancak o da yetmezse yardımcı yönetmene gider. Süre D2c'nin (ve D8a, D6'nın) kapısında ölçülür.

## 0b. Ayrım: tam tanımlı (a) ve park (b) · 2026-10-22

Yardımcı yönetmenin yönü (Erdem'den): yalnız tam tanımlı işler koda girer, netleşmeyen her şey park edilir ve listelenir. A4'ün
açık kararları [WORKING] girmez. Bu bölüm aşağıdaki tablonun sırasını ezer.

**(a) Kapanmış kararlara dayanan adımlar** (Erdem 18 = A, 19, 20, 21, 22, 24, 25, 26, 27, PRD'nin kararları, yardımcı
yönetmenin teknik cevapları). Q K20 commit'inden sonra, bugünkü hafta motorunun üstünde, bu sırayla:

| Sıra | Adım | Kapsam | Süre |
|---|---|---|---|
| 1 | D0a | Ölçüm araçları (12/25/50 kişilik prob, Erdem örneği fikstürü, `PLANMS`) | 3 sa 30 dk |
| 2 | D0b ∥ D0v | Taban koşuları (arka planda, commit yok) ve haritanın tazelenmesi | 3 sa (arka plan) + 40 dk |
| 3 | D1 | Şema, ×5 ölçek, sabit 2 hafta, silmeler, yeni alanlar (`keep`, Düzeltme, hazırlayan PM, taşan aşama sayacı) | 5 sa |
| 4 | D1b | D2a'dan alınan iki tanımlı parça: Karar 1 kişi hızı (Y(s), U, huy) ve Karar 5 kurucunun toplantı payı | 2 sa |
| 5 | D2b | Erken kapanış kalkar, çekme, devreden kalkanı kalkar, tek alım sınaması (bugünkü motorda zaten tek yol), taşan aşamanın kaydı | 4 sa |
| 6 | D3 | Karar 24 hata modeli: tohumlu gerçek kip, beklenen hata işlevi, yakalama, Düzeltme işi, kaçan hata, `faulty` silinir, c kalibrasyonu | 4 sa 30 dk |
| 7 | D4 | PM kural A | 3 sa |
| 8 | D7 | Düzeltme kartı 2 × açık hata, k ile D'nin sınırları | 2 sa 30 dk |
| 9 | D8a | Öneri altı basamak, 12 aday, düzeltme pay tavanı, bot | 2 sa 30 dk |
| 10 | D8b | PM'siz çeyrek hedefi, "Bu çeyrek: hedef yok", devretin PM şartı (düğmenin yeri D6'da) | 1 sa 30 dk |
| 11 | D5a | Atlas aşama hızları, Görevler matrisi uyarısı, kurucu dosyasının yıldızları | 2 sa |

Toplam yaklaşık 31 sa (D0b'nin 3 saati arka planda). Açık kararın dokunduğu yerde (a) oyunun bugünkü davranışını korur, yeni
bir şey seçmez: testçi bugün yalnız Test'e uyar, bu yüzden D3'ün Düzeltme işini geliştirme rolleri yapar (K6'nın cevabı D2a'da
iner); kurucunun aşama sırası bugünkü gibi kalır (K7); kadro tavanı bugünkü motorda yoktur (K4).

**(b) Park: M2 sayfasıyla Erdem'e gider.**

| Adım | Neden park | Hangi açık karar |
|---|---|---|
| D2a | Yeni hafta motoru ve reaktif P: dağıtım kuralı kadro tavanını, testçinin Geliştirme ve Düzeltme satırına girişini ve kurucunun aşama sırasını ister. Açık 3 (Test'te ilke) burada | K4, K6, K7 |
| D2c | Proaktif P ve süre kapısı; D2a'nın motoruna bağlı | D2a'ya bağlı |
| D3b | Gönder sorusu: bırakılan söze bağlı kartın sözü, konuşan kişi, eşikli kip ayarı. §3.4 sürüm notu satırları ve Karar 28 bununla gelir | T1, T2, eşikli kip |
| D6 | Plan ekranı: kompakt kart, kişi satırı ya da aşama özeti, devretin yeri, "Sırada", ipucu, kadro tavanı ipucu; darboğaz cümlesinin ve kuralın ekrandaki yeri | U1 ile U6, maket |
| D5b | Özenli ve Aceleci etiketi: Karar 24 modelinde kişinin tek bir "yapım kalitesi" yok (hata kartın gereksinimine göre değişiyor); etiketin tanımı yok | tanımsız, M2 sayfasına yazılır |
| D9 | Ölçüm; uymayan işin moral bandı ve P'nin bütünü | P1, D2a ile D2c |
| R | Rapor | sona |

**Onay ve şartlar (yardımcı yönetmen, 2026-10-22).** (a) onaylı; K20 inince bu sırayla başlar.
1. Her commit uyguladığı Erdem kararını ya da PRD kararını numarasıyla yazar; dayanağı olmayan parça commit'e girmez.
2. Kodlarken yeni bir tasarım seçimi gerektiği ortaya çıkarsa o parça durur, park listesine ve M2 sayfasına eklenir; varsayılan
   seçilmez.
3. K4, K6 ve K7'de bugünkü davranış korunur; raporda "yeni karar yok" diye işaretli kalır.
M2 sayfası önceliklidir: Erdem ne kadar erken cevaplarsa D2a o kadar erken iner, taşıma bedeli o kadar az olur.

Park listesine ayrıca: U7 ve hesap isteği kartı (D8d), derinlik kartı (D8c) kart yenilemesine; PM'siz çeyrekte PM kâğıdını
kimin söylediği (PRD sessiz, D8b bugünkü davranışı korur).

Bedel: D2b, D3, D4 ve D8a bugünkü motorda yazılır, D2a yeni motoru kurarken bunları taşır (çekme, test bitişindeki hata kancası,
PM hazırlığı, alım sınamasının tek girişi). Taşıma D2a'ya yaklaşık 2 ile 3 saat ekler.

## 1. Adım tablosu

Kod adımlarında akış her commit için aynıdır.
1. Sonnet kodlar.
2. Haiku kapıları koşar ve kareleri çeker.
3. Opus inceler; düzeltme hakkı vardır.
4. Commit `Faz D Dn:` önekiyle atılır.

Commit başına en çok 1 inceleme ve 1 düzeltme. Düzeltmeden sonra kapı yine düşerse adım durur, ölçümle yardımcı yönetmene gelinir.

**Her commit'in ortak kapıları.**
- `--sprint-probe` 1, 3, 6, 12, 25 ve 50 kişide; PRED = CLOSE, adsız uyuşmazlık 0.
- Dokunulan sistemin smoke vakaları. Yeni vaka falsification ile gelir: kasıtlı bozulmada düşmeli.
- `event-lint`, `loc_residue`, `loc_csv_integrity`, `all_scripts_load`.
- Görünür değişiklikte TR ve EN kare.

`run_gate` ve plausibility tabloda ayrıca yazılı.

### Ön adım (Erdem'in "evet"inden önce yürür; oyun kodu yok)

D0s2 (Python yeniden ölçümü) ve D0p (GDScript süre spike'ı) yardımcı yönetmenin kararıyla düştü: ölçüm turu yok, açık 3, 4 ve 5
doğrudan D2a ve D2c'de yazılır, süre D2c'nin kapısında ölçülür.

| Adım | Ne | Dosyalar | Kapı | Model (düşünme) | Süre | C bağı |
|---|---|---|---|---|---|---|
| M2 + W2 | M maketi ve D'nin bütün oyuncu metinleri kararlara göre yenilenir; kod adımları metni buradan alır (D3b, D5, D7, D8a, D8b, D6). Darboğaz cümlesi yalnız taşmada ve sayaçlı ("bu sorun N sprinttir sürüyor"). `NECK_FITS_*` silinir. Kural cümlesi ve gereksinim satırı, "kalır" satırı ("kim hangi kartın hangi aşamasında, ne zaman çıkar"), "Bu çeyrek: hedef yok", gönder sorusu ve çipleri, sürüm notu satırları (§3.4 ve Karar 28), kurucu cümleleri, Atlas hızları ve Görevler uyarısı, Destek kartının k'li eşik satırı, önerinin hedefsiz neden parçası; devret önerisi yok. TR ve EN birlikte, tiresiz. Kareler ve sorular Erdem'e tek görsel sayfada gider: A4'ün tasarımcı kararları (K4, K6, K7, P1, T1, T2, U1 ile U7) ve eşikli gönder kipi ayarı sade soru olarak durur (araştırma ya da ölçüm özeti, seçeneğin oyunda neyi değiştirdiği, oyuncu örneği; "önerim" etiketi yok); D8c ve D8d'nin ertelenmesi bilgi olarak yazılır. Erdem tek seferde cevaplar. | `d_taslak/M/`, `d_taslak/W/`, sayfa kaynağı `d_taslak/M2/` | 1/6/12/50 kişi, TR ve EN kareler; `wavecheck_d` temiz; sayfa derleme ve başsız render denetimi | Sonnet (xhigh, maket) / Opus (metin ve sorular) / Haiku (kareler) | 4 sa | Godot'lu kısım Q K20 commit'inden sonra, "kapı bende / bitti" ile |

### Kod adımları (Erdem'in "evet"i ve Q K20'nin commit'i gelince)

| Adım | Ne | Dosyalar | Kapı (ortaklara ek) | Model (düşünme) | Süre | C bağı |
|---|---|---|---|---|---|---|
| D0a | Ölçüm araçları. `--sprint-probe` bugün en çok 6 kişi koşabiliyor (`HIRES` 5 rol); 12, 25 ve 50 kişilik fikstür (`OfficeCrowdProbe.seed_staff` deseni, karışık yıldız), testçi 1★/5★, PM yıldızı ve +1 kişi eklenir. Erdem örneği ve "3 kişi + 4 kart" fikstürü gelir. Bota 25/50 kişilik merdiven ve 330 hesaplı dünya eklenir; prob ve bot EA yapısıyla da koşar (§4.3 madde 3 ve 7). `PLANMS` satırı `--sprint-probe`'un anahtarıdır, yeni bayrak yoktur: bugünkü `plan_outcome`, `can_add`, `mvp_eta` ve ekranın tam kurulumu, 50 kişi ve 50 kartta taban olarak ölçülür. Var olan preset'lerin `^PROBE` satırları bayt bayt aynı kalır. | `sprint_probe.gd`, `run_probe.gd`, `main.gd` (probun EA yapısı), HARITA Araçlar | yeni fikstürlerde prob koşar; eski preset'ler bayt eşit | Sonnet (xhigh) / Haiku / Opus | 3 sa 30 dk | `main.gd`, `run_probe.gd`, HARITA ortak: sırayla |
| D0b | Taban koşuları, commit yok: D1'den hemen önceki HEAD'de, HEAD'in `git archive` anlık görüntüsünden (boşluksuz bir yola açılır, önce `--import`). Kapsam §4.2'nin 16 kolu ve `_free` ikizleri, §4.3 madde 4'ün 80 koşusu, §4.4 madde 1 (team=3) ve testçili ayrı satır, 25/50 kişi ve 330 hesaplı koşular. Her log klasörüne commit hash'i yazılır. D0v arka planda D0b sürerken yürür. | log klasörü (`d_taslak/olcum/`) | koşu tamam | Haiku (düşük) | 3 sa, arka planda | C'nin PROBE ve ekonomi değişiklikleri tabanı bayatlatır. D'siz C tabanı ağaçta kurulamaz (worktree yok): D9, D0b ile D9 arasında inen C commit'lerini listeler ve farkı "D ve şu C adımları" diye okur |
| D0v | Haritanın tazelenmesi ve doğrulanması. `D0t_HARITA`'nın K1 ile K27 arası riskleri ve 3 yeni risk (N1, N2, N3) HEAD satırlarıyla yazılır. P portunun kopukluk listesi: `_assign`'in beş çağrı noktası (`put_first`, `_staff_week`, `_play_out`, `_restaff`, `can_add`) tek girişe bağlanır; "kalır" istisnaları (`_clear_decision`, `crunch_finishes`, `put_first`, `_restaff`, acil durumda "Sprinti durdur"). | `d_taslak/D0t_HARITA.md` | kopukluk listesi kapalı | Opus (yüksek) | 40 dk | yok |
| D1 | Önce `SCHEMA_VERSION` okunur: 18 ise D 19'u alır. Ölçek ×5 (kart 15/25/40, araştırma 5, ücretli plan 15, kâğıt puanları, `fix_effort.points` D7'ye kadar). Kişinin haftalık puanı da ×5 olur (`person_points_week` 2 → 10), yoksa D1 ile D2a arasında oyun beş kat yavaşlar; Y(s) eğrisi D2a'da. Kart ihtiyacı ve iş profili `ProductLines.work_profile`'dan okunur; düzeltme (0 / 0,7 / 0,3) ve araştırma kartının payı türünden gelir. Sabit 2 hafta: seçici, `set_weeks`, `sprint_lengths`, `sprint_chance["1"]`, `team.demo_day`, `main.gd` fikstürü, smoke çağıranları, probun `weeks=`'i. Göç ve bütün silmeler bu adımda yapılır: `faulty`, `shares`, `effort_mod`, `sprint.weeks`; yarım testli kart testi baştan alır. `faulty`'nin yazanı ve okuyucusu D3'e kadar yaşar ve göçten gelen kartı `get("faulty", false)` ile okur. K12: `_migrate_15` `effort.k` ve `shares` okuyor (`save_manager.gd:863`, `:868`), v14 kaydı iki kez ×5 almaz. Varsayılanlı yeni alanlar: kartta `keep`, Düzeltme alanları (n, F, düzeltme işi ve ilerlemesi), hazırlayan PM ve hazırlık ilerlemesi (D4); sürüm kaydında taşan aşama ve ardışık sayı (Karar 22'nin sayacı). | `sprint_system.gd`, `sprint_catalog.gd`, `sprint.json`, `save_manager.gd`, `product_fixtures.gd`, `main.gd`, `effects.gd`, `seams_product.gd`, `data/events/cards/product/` (×5 miktarlar), `sprint_probe.gd`, `run_probe.gd`, `sprint_panel.gd`, `product_tab.gd`, `product_model.gd`, `strings.csv` (seçicinin anahtarları silinir), `endgame_smoke.gd`, ZAMAN MODELİ, GUNCELLEMELER, CLAUDE.md §6 | `save_v19_*` (sprint ortası gidiş dönüş dahil), `save_v14_*` ve `save_v15_*` zinciri; `set_weeks` ya da `sprint_chance`'a doğrudan (7 vaka) ya da yardımcıyla (`_seed_sprint`, `_paper_chance`, `_paper_pool`, `_paper_world`, `_promise_world`, `_late_world`) dokunan bütün vakalar (HEAD'de 89); `run_gate`; plausibility | Sonnet (**max**) / Haiku / Opus | 5 sa | Şema numarası iniş sırasına göre. CLAUDE.md §6 "Karar kâğıdı" paragrafı C5/C6 ile ortak: sırayla, ikinci yazan HEAD'den okur. Kâğıt kartları C3a ile (`trust_delta`) ve K20'nin commit'siz farkıyla (`sprint_pm_phone_too*.json`) ortak; `strings.csv` bayt kesme |
| D2a | **Reaktif P: yeni hafta motoru ve dağıtım kuralı.** Motor olay düzeyinde çalışır: hafta tik içinde hesaplanır, aşama bitince boşalan kişi aynı anda yeniden dağıtılır. Gerçek hafta ile tahmin aynı motoru koşar. Dağıtım kuralı A8 §4.1'deki gibidir: ufuk, plan sırasıyla en az kişilik ekip, kimse boşta kalmaz, gereksinim kapısı, ilke yer değişimi, satır seçimi, kalır. Açık 3 burada yazılır: aynı yer değişimi Test satırına da uygulanır, karmaşık kartın testine en iyi testçi, basit kartın testine yeten en zayıf testçi gider; fazla testçi boşta kalmaz, ikincil satıra geçer. Kadro tavanı ⌈ihtiyaç ÷ 8⌉. Kişinin aşama hızı Karar 1'dir: 10 × Y(s) × U × verim × saat × pay × huy (TİTİZ ×0,85, GÖZÜ YÜKSEKTE ×1,15). Kurucunun sprint payı haftanın toplantı saatinden gelir (Karar 5; `GameState.founder_meeting_share` bugün yalnız Ar-Ge'de okunur); ACIK 96 (4) ve (6) aynı commit'te güncellenir. Aynen kalanlar: uyum, kurucu tabanı ve güçlü alan, uymayan işin koşulu ve −2 moral, testçi Düzeltme'ye girmez. "Kalır"ın istisnaları D0v'nin listesiyle (kâğıt, `put_first`, `_restaff`, acil durumda "Sprinti durdur", uymayan iş). `team()` sözlüğünün okuyucuları (K1: `incident_system.gd`, `effects.gd`, `seams_product.gd`, `product_model.gd`, `main.gd` fikstürü, `sprint_probe.gd`) yeni şekle geçer. Prob `PRED`/`CLOSE`'a atanan kişileri yazar (§4.4 madde 2); "6 kişi + PM'in Test kutusu" fikstürü eklenir. Eşitlikler açık anahtarla kırılır, çünkü `sort_custom` kararlı değil. `office_people.gd` `role_of` düzeltilir. | yeni `sprint_week.gd` ve `sprint_alloc.gd` (`a8plan.py` ve `a3core.week3`'ün portu), `sprint_system.gd`, `office_people.gd`, `hr_constants.gd` (PM ve tasarımcı için Test kutusu), K1 okuyucuları, `ACIK_KARARLAR.md` | `sprint_alloc_erdem_example`, `sprint_alloc_req_gate`, `sprint_alloc_min_crew`, `sprint_keep_until_phase_end`, `sprint_test_row_principle`, `sprint_founder_floor_silent`; var olan `incident_sprint_stop_moves_the_card`, `sprint_departure_restaffs_card`, `sprint_decision_blocks_progress` kalırla geçer; `a8test` mikro vakalarının karşılıkları; `run_gate` | Sonnet (**max**) / Haiku / Opus | 9 sa | yok (C9a commit'li; kalan C adımları `hr_constants.gd`'ye dokunmuyor). `sprint_system.gd` ve `main.gd` ortak: sırayla |
| D2b | Sabit 2 haftalık oynatma. Erken kapanış kalkar. Çekme sırası plan sırasıdır ve önerinin sıra işlevini okur; altı basamak D8a'da bu işleve gelir, çekme ayrıca değişmez. "En çok bir devreden" kalkanı kalkar, "sprintte en çok bir talep" kalır. Alım sınaması tek kuraldır: `_takes`, `can_add`, `mvp_eta` ve önerinin aday sınaması uygulanan yerleşimin tek girişini oynatır (açık 5); bu adımda giriş reaktif P'dir, D2c aramayı aynı girişe bağlar. `put_first` kartının `carried_out`'u, kâğıt zarı ilk haftanın sonunda. Taşan aşama sürüm kaydına yazılır. Prob `PRED`/`CLOSE`'a çekilen kartı yazar (§4.4 madde 2). | `sprint_system.gd`, `sprint_catalog.gd`, `sprint_probe.gd`, `run_probe.gd` | `sprint_two_weeks_pull` (devreden kalkanı kalktı: falsification), `sprint_intake_uses_applied_plan`; `run_gate` | Sonnet (**max**) / Haiku / Opus | 4 sa | yok |
| D3 | **Karar 24 hata modeli.** Formül: H = T × tür × (1 − PM hazırlığı) × Σ(pay × m(Δ) × TİTİZ); T = c × puan × gereksinim; m(Δ) = 0,20 × 0,5^(Δ/2); c = 0,212 `sprint.json` "bugs" bloğunda [WORKING]. Gerçek kip ve tahmin, kart tohumundan Poisson çeker; RNG ilerlemez. Beklenen kip zar atmaz. Yakalama, kendi kartını test etme ×0,6 ve Düzeltme işi (ağır 5,3, hafif 1,3) gelir. Kaçan hata hattına yazılır. Silinenler: `faulty` (yazanı ve okuyucusu), `faulty_chance`, kapanış zarı, `promise.cut_test_escape` ve destekteki yeni kod terimi. Sürüm kaydının `faulty`'sinin okuyucuları (K8: `_regression_line`, `_unhappy`, `PROBE SHIP`, `main.gd` fikstürü) kaçan ve gönderilen hatanın hatlarını okur. "Testi kısalt" yakalamayı orantılı düşürür; çipi buna göre yazar. Ekip GDD'nin Test cümlesi GUNCELLEMELER'e. Proba n, F, K ve Düzeltme işi eklenir. | yeni `sprint_bugs.gd`, `sprint_system.gd`, `sprint.json`, `support_system.gd`, `incident_system.gd`, `product_state.gd`, `sprint_bridges.gd`, `effects.gd`, `chips.gd`, `strings.csv`, `sprint_probe.gd`, `run_probe.gd`, `main.gd`, CLAUDE.md §6 "Söz olayı", HARITA, GUNCELLEMELER | `sprint_bug_ceiling_formula` (40 puanlık 2★ kartta 2★ kişi 3,392, 4★ kişi 1,696), `sprint_test_seed_deterministic`, `sprint_expected_bug_no_rng`, `sprint_escaped_bug_on_card_line`; `promise_cut_test_escape` ve `incident_regression_fixture` yeni modele geçer; oyunda koşu başına doğan ve kaçan hata, açık hata ve acil durum D0b tabanıyla yan yana (§4.3 madde 8); toplam hacim %30'dan çok saparsa c oyunun bugünkü hacmine kalibre edilir ve raporda yazılır (yardımcı yönetmenin kararı, sorulmaz); `run_gate`; plausibility | Sonnet (**max**) / Haiku / Opus | 4 sa 30 dk | Hata hatta yazılır, C3a okur. K-H hacmi dsim'in modeline göre nötrdür, oyunun bugünkü `faulty` zarına göre değil (`sprint_system.gd:945`, `:1452`): c oyunun hacmine kalibre edildiği için C'nin M5 kalibrasyonu korunur (§4 madde 6). `support_system.gd`, `incident_system.gd`, CLAUDE.md §6 "Söz olayı" C3a ile ortak: sırayla |
| D4 | PM kural A. Kartlar karmaşıklığa (puan × gereksinim) göre büyükten küçüğe dizilir; PM'ler yıldıza göre ve kapasiteyle orantılı dilimlere ayrılır. Ürün kapısını geçemeyen PM'in payı en yakın uygun PM'e kayar; hazırlayan değişmez. Aynen kalanlar: hazırlık kartın %20'si, P(s), hız ve hata çarpanları. `payers` düzenlenir. Bilinen bedel: P−R teslim farkı 12 kişide −1,8, 25 kişide −2,8 puan/hf; D9'da tolerans olarak yazılır. | yeni `sprint_prep.gd` ya da `sprint_alloc.gd`, `sprint_system.gd`, `effects.gd`, `scope.gd` | `sprint_skill_assignment` (PM kolu: büyük kart 5★ PM'e, küçük kart yeten en zayıf PM'e; ters sırada düşer); `pm_ekleme` 12/25 kişide yön kapısıyla (PM eklemek teslimi düşürmez; düşürürse kural A'nın bedeli olarak raporlanır) | Sonnet (xhigh) / Haiku / Opus | 3 sa | yok |
| D2c | **Proaktif P.** `SprintPlanner`: hafta başında 8 yerleşim seçeneği sprint sonuna oynatılır. Oynatma beklenen hatayla koşar (açık 4): zar atılmaz, n = H, F = H × C, Düzeltme = H × C × 2,02; gösterilen tahmin ve gerçek sprint kartın tohumlu zarını çeker. Alım sınaması aramayla birlikte uygulanan yerleşimi oynatır (açık 5). Seçenekler A8'de ölçülen 8 seçenektir. Seçim plan puanına göredir: ρ = 0,85, boşta %3 ve ilerleme %2 toleransı. Hafta başı durum imzasıyla önbellek tutulur; sapma olursa reaktif yeniden kurma. Önbellek `ProductSystem.reset`'te temizlenir, kayda girmez. **Süre kapısı (açık 6):** 50 kişilik gerçek dünyada (bugünkü katalog en çok 14 kart; sentetik 50 kartlık fikstür kurulmaz, yardımcı yönetmenin kararı) oyuncunun tıklamasında (ekranın tam kurulumu dahil) ve iki haftada bir gecede plan ≤ 100 ms; gece tikinin geri kalanı 148,2 ms kapısında. `PLANMS` 1/3/6/12/25/50 kişide, gece `--tick-probe`. Aşarsa önce hesap karelere bölünür (oynanış değişmez) ve yeniden ölçülür; o da yetmezse adım commit'ten önce durur, hafif kip ya da arayüz seçeneği yardımcı yönetmene gider. | yeni `sprint_planner.gd`, `sprint_system.gd` (`_begin`, `_staff_week`), `product_system.gd`, `sprint.json` "planner" bloğu [WORKING] | `sprint_planner_borderline_70` (arama kapalıyken düşer), `sprint_planner_react_slowdown`, `sprint_plan_equals_close` (önbellek isabeti × 2 = hafta başı sayısı), `sprint_rollout_ignores_seed` (açık 4: kartın tohumu değişince `decide`'ın seçimi değişmez; oynatma zar çekerse düşer), `sprint_intake_uses_applied_plan` arama açıkken yeniden (açık 5), sprint ortası kayıt ve yüklemeden sonra tahmin = sonuç (`save_manager.gd:520` `JSON.stringify` tam hassasiyetsiz yazar); `run_gate` | Sonnet (**max**) / Haiku / Opus | 5 sa | yok |
| D7 | Düzeltme kartı 2 × açık hata, alt sınır yok, faz payı 0 / 0,7 / 0,3; `fix_effort` kademeleri kalkar, `fix_effort.priority` taşınır. A'nın D'ye ait sınırları k ile ölçeklenir: `NEGLECT_BUGS`, botun `DUE_BUGS` ve `SLIP_BUGS` eşikleri, ölçüm hedefleri. Destek kartının ipucu k'li eşiği sayıyla yazar (Karar 15; bugün `NEGLECT_BUGS`'u okuyan arayüz yok), metin W2'den. Proba k alanı eklenir. | `sprint_catalog.gd`, `support_system.gd`, BuildBar'ın DESTEK kartı, `strings.csv`, `run_probe.gd`, `sprint.json` | `sprint_fix_card_double` (falsification), var olan `fix_*` vakaları; TR ve EN kare | Sonnet (xhigh) / Haiku / Opus | 2 sa 30 dk | **Gerçek bağ:** `B2B_BUG_SAT_*` ve `COMPLAINT_BUG_GATE` C3a'da silinip yeniden kurulacak; D onları ölçeklemez. k kuralı C3a'ya not olarak geçer (AJAN_MESAJLARI) |
| D8a | Öneri: altı basamak ve 12 aday atlama. Her aday için alım sınaması P oynatmasıdır. Düzeltme pay tavanı (plan ve çekmenin kendiliğinden aldığı düzeltme işi kapasitenin yarısını aşmaz, sprintte düzeltme kartı yoksa ilk kart girer; Karar 14, bugün kodda yok) öneri ve çekme için tek yerdedir. Hedef yokken 5. basamak en zayıf alana gider; öneri satırının neden parçası W2'den gelir, ekrana D6'da çıkar. Bot yalnız öneriyi kullanır, `_keep_building` silinir, sprint başına eylem sayısını basar. Öneri döngüsünün süresi `PLANMS`'te ayrı satırdır; ≤ 100 ms bütçesine D2c'deki gibi bağlıdır. | `sprint_catalog.gd`, `sprint_system.gd`, `run_probe.gd` | `sprint_lead_fills_to_ceiling`; öneri döngüsü süresi; `run_gate` | Sonnet (xhigh) / Haiku / Opus | 2 sa 30 dk | yok |
| D3b | Gönder sorusu bağlı kipte. Eşikli kip ayarı Erdem'in M2 sayfasındaki cevabıyla yazılır ("ayar olarak durur" ya da kalkar). Kapanış akışı bugünkü tek yuvalı kesinti kaydına girer; sıra `sprint.json`'da tek veri satırıdır. Bırakılan kart öneride 3. basamağa döner. T1: söze bağlı kart bırakılırsa söz bir sprint uzar, ikincide kırılır. T2 (Erdem'in cevabına bağlı): M2 sayfasındaki A'ya göre konuşan, rolü ne olursa olsun o kartın testini yapanlardan en çok hata bulandır; kartı yalnız kurucu test ettiyse kurucunun notu gelir. Sürüm notu satırları: §3.4'ün test özeti, düzeltmede kalan kart, çekilen kart, hazırlığın kazancı (Karar 8) ve Karar 28; metinler W2'den. Yeni kart için `--why-fire`, `_vocabulary.md`, manifest, motor md §27. Botta dört gönder politikası ve söz veren B2B kolu. | `sprint_system.gd`, `sprint.json`, `data/events/cards/product/`, `strings.csv`, motor md | `sprint_ship_question_order`; plausibility | Sonnet (xhigh) / Haiku / Opus | 3 sa | **Gerçek bağ:** kesinti tablosunu C5 kuracak (Pazar 2 ile yeniden yazılıyor). D sırayı tek veri satırına koyar, C5 o satırı devralır. Bu sözleşme C'ye yazılır |
| D8b | Çeyrek hedefi PM'siz seçilebilir ("Hatalar" dahil); boş başlık "Bu çeyrek: hedef yok". PM'siz çeyrekte PM kâğıdı bugünkü gibi gelmez (`_speaker` PM'i bulamaz); PRD sessiz, değişecekse yardımcı yönetmene sorulur. Devret PM şartı: PM yoksa açılmaz, PM ayrılınca kalkar. Devret önerisi satırı yok (yardımcı yönetmenin kararı). Metinler W2'den. | `sprint_system.gd`, `product_tab.gd`, `quarter_view.gd`, `strings.csv` | `quarter_goal_without_pm`, `delegate_needs_pm` | Sonnet (xhigh) / Haiku / Opus | 1 sa 30 dk | `strings.csv` ortak: bayt kesme |
| D5 | Ekip ekranları: Atlas'ta aşama hızları; Görevler matrisi uyarısı (W2 `HR_TASK_UNFIT_TEST`: testte ×0,4 hız, test yaptığı her hafta için sprint sonunda 2 moral); Özenli ve Aceleci yalnız arayüzde, artık yıldız eşiğine bağlı. Kurucu dosyası gerçek yıldızları gösterir. Metinler W2'den. | `hr_atlas_modal.gd`, `hr_assignments.gd`, `work_hours_modal.gd`, `strings.csv` | TR, EN, renk körü, 1,25 kareleri | Sonnet (xhigh) / Haiku / Opus | 2 sa 30 dk | yok (C9a commit'li); `strings.csv` bayt kesme |
| D6 | Plan ekranı, M2'de onaylanan hâliyle. Şerit, darboğaz cümlesi ve sayacı, kart başına atama ve bonus, "Sırada", kart zinciri, kişi yükü ve kalır satırı, aşama özeti, test satırları, devretin kilit nedeni. Kurucunun üç cümlesi ve sprint payı satırı (Karar 5), uymayan işi kişinin adıyla yazan satır (Karar 2), önerinin hedefsiz neden parçası (D8a). 8 kişiden sonra kompakt kart. §4.3 madde 5'in satır sayımı yapılır. `edge:` fikstürleri HARITA'ya girer. Ekranın tam kurulumu `PLANMS` ile ölçülür. | `sprint_panel.gd`, `sprint_card.gd`, `product_model.gd`, `quarter_view.gd`, `product_fixtures.gd`, `strings.csv`, HARITA | TR, EN, renk körü, 1,25; 1/6/12/50 kişi kareleri; ekranın tam kurulumu ≤ 100 ms (50 kişi) | Sonnet (**max**) / Haiku / Opus | 7 sa | `strings.csv`, HARITA ortak: sırayla |
| D9 | Ölçüm, commit yok. §4.1 kapıları yeniden yazılır: atama sırası (gereksinim altı Yazılım işi 0, aynı girdi aynı atama, sprint içi yer değişimi 0), Erdem örneği birebir, 3 kişide MVP ≤ R. `ekleme_dusurmez` ve `pm_ekleme` P ve kural A altında; `uymayan_moral` için 20 ile 35 bandı. Ayrıca §4.2'nin 16 kolu, §4.3, §4.4 ve süre. Referans A8'in tek tablosudur, birebir eşitlik değil yön kapısı: 3 ile 12 kişide P teslimde R'den en çok %2 geride; MVP ve açık hata A8'deki P değerlerinden kötü değil. Sonuçlar D0b tabanıyla yan yana. | `d_taslak/olcum/` | kapı tablosu | Haiku koşar, Sonnet okur (yüksek) | 5 sa | C'nin E2'si ayrı; memnuniyet ölçümü C3a'dan sonra tekrarlanır |
| R | `RAPOR_D.md` şunları taşır: ✅/⚠️/❌ ve kanıt; [WORKING] sabitler (c, m(Δ), planner bloğu, kadro tavanı 8, Özenli/Aceleci eşikleri); ertelenenler ve gerekçeleri; kart yenilemesinde yeniden ölçülecekler (c, ilke etkisi, süre, arz kapıları); şema el sıkışması; C ile ortak dosyalar; §4.3 madde 6'nın "her sabitin görünen satırı" tablosu; `speed_bonus_for`; `ISLER` maddeleri. | `faz_cde/RAPOR_D.md` | yok | Ana (Opus, orta) | 30 dk | yok |

**Sıra:** M2+W2 (Godot'suz kısmı şimdi; kareler K20 commit'inden sonra; Erdem'in tek seferlik cevabı) → (Erdem "evet", K20 commit'li) → D0a →
D0b (arka planda) ∥ D0v → D1 → D2a → D2b → D3 → D4 → D2c → D7 → D8a → D3b → D8b → D5 → D6 (M2 onaylıysa) → D9 → R.

D3 ve D4, D2c'den önce gelir; çünkü ileri oynatma tam motoru (beklenen hata, PM hazırlığı) görmeli. W2 kod adımlarından önce
biter, çünkü D3b, D5, D7, D8b metni ondan alır. Kod adımları seri yürür.

**Süre:** ön adım 4 sa (M2+W2), kod 49 sa 40 dk (D0a'dan D5'e; D0b'nin 3 saati arka planda), D6 7 sa, ölçüm ve rapor
5 sa 30 dk; toplam yaklaşık 66 sa (eski tablo 76).

## 2. Yürütme kuralları (C ile aynı ağaç)

- **Index.** Q K20 commit'lenmeden index'e girilmez. K20'nin farkı `strings.csv`, `endgame_smoke.gd`, `lint.gd`, `hr_*.gd` ve iki
  `sprint_pm_phone_too*.json`'da duruyor.
- **Godot ve index sırası.** Aynı anda yalnız bir oturum Godot koşar ya da index'e yazar. C'ye "kapı bende" / "bitti" yazılır; adres her
  seferinde `ListAgents`'tan okunur, çünkü adlar kayıyor.
- **Ortak dosyalar.**
  - `strings.csv` bayt kesmeyle değişir, asla yeniden yazılmaz.
  - `main.gd`, HARITA, CLAUDE.md §6, `run_probe.gd`, `endgame_smoke.gd` ve `sprint_system.gd` C3a/C5/C6 ile ortak. Her commit
    öncesi `git log` ile C'nin son hâli okunur. Yalnız kendi parçalar hunk düzeyinde sahnelenir; commit ağacı `checkout-index`
    ile koşturularak doğrulanır.
- **Yasaklar.** `project.godot` ve tema farkı commit edilmez. `git checkout --` yok, worktree yok, push yok.
- **Yeni `class_name` dosyaları.** `SprintWeek`, `SprintAlloc`, `SprintBugs`, `SprintPlanner` ve olası `SprintPrep`: headless
  koşudan önce sıra import → ısınma → kapı.
- **Ağır koşular.** Erdem oynarken açılmaz. Smoke en çok 2 paralel, ölçüm 2 paralel; her koşu kendi `APPDATA`'sında.

## 3. Düşenler ve ertelenenler (gerekçe)

| Madde | Karar | Neden |
|---|---|---|
| D8c derinlik kartı (G1 ile G4, g₀, 162 ad) | ertelenir | Arz Pazar 2'de modül, kademe ve dönem üzerinden yeniden kuruluyor. Bugünkü kartlarla yazılırsa atılır. Elde kalanlar saklanır: `Wa_ADLAR`, `D0t_G0`, dsim kolları. Arz kapıları (§4.1 madde 6) ölçülür, tutmazsa "ertelenen arz" diye raporlanır |
| D8d hesap isteği kartı (T3, U7) | ertelenir | C6'nın istek akışı (3★ ve üstü) Pazar 2 ile yeniden yazılıyor |
| Devret önerisi satırı | düşer | Hiç onaylanmadı (PRD'de [onay bekliyor]); yeni bir dürtme sistemi; Erdem'in 20 Ekim kuralı: "konuştukça yeni sistem eklenmez" (yardımcı yönetmenin kararı) |
| Eşikli gönder kipi ayarı | Erdem'e soru (M2 sayfası) | Erdem 18 Ekim'de "ayar olarak durur" dedi (PRD §10 madde 1); yardımcı yönetmen kaldıramaz. Oyunda okuyucusu olmayan ayar (CLAUDE.md §8), karşılaştırma D0s'ta yapıldı. D3b Erdem'in cevabıyla yazılır |
| "Yalnız bitecek kartlar, en çok bir devreden" (K3) | düşer | Sabit 2 haftada planı %34 ile %57'ye boşaltıyor; Erdem'in tarifi "bütün ekip kullanılır" |
| "Aşama satırı ≤ 2× kapasite" | düşer | PRD'de [onay bekliyor]; ölçüm turu yok, sade olan kalır (yardımcı yönetmenin kararı). D9'da aşama satırı şişmesi görülürse raporlanır |
| P3 puan başına dolar ÷5 | düşer | Dışarıdan iş Q K14/K16'da kalktı |
| Negatif Δ uzantısı | düşer | Gereksinim kapısı varken Δ < 0 olmaz |
| `HR_AREA_MEANING_*` metinleri | düşer | Q K19 sildi |
| Darboğaz oran cümlesi, `NECK_FITS_*` | düşer | Karar 26: taşma yokken satır boş |

## 4. Yardımcı yönetmenin cevapları (2026-10-22)

1. **Bütçe (c).** Oyuncunun tıklamasında ve iki haftada bir gecede plan ≤ 100 ms, 50 kişilik dünyada ölçülür; gece tikinin
   geri kalanı bugünkü 148,2 ms kapısında kalır. Aşarsa ilk çare oynanışı değiştirmeyen yol: hesap karelere bölünür. Hafif kip
   ya da arayüz değişikliği ancak o da yetmezse yardımcı yönetmene gider. (D2c, D8a, D6.)
2. **Ön adımlar.** D0s2 ve D0p düşer (Erdem'in kuralı: ölçüm turu yok). Açık 3, 4 ve 5 doğrudan D2a ve D2c'de yazılır. D9'un
   referansı A8 tablosu, yön kapısıyla. "Aşama satırı ≤ 2× kapasite" şartı ve T_plan'sız 7 seçenek denemesi de düşer: A8'de
   ölçülen 8 seçenek kalır. M2 + W2 şimdi başlar; Godot'lu kısmı Q K20 commit'inden sonra, "kapı bende / bitti" ile.
3. **Devret önerisi düşer.** D8c ve D8d'nin ertelenmesi Erdem'e bilgi olarak gider. Eşikli gönder kipi ayarı Erdem'in sözüdür;
   M2 sayfasında soru olarak durur.
4. **A4'ün tasarımcı kararları** (K4, K6, K7, P1, T1, T2, U1 ile U7) koda GİRMEZ (yardımcı yönetmen önceki "[WORKING] girer"
   cevabını geri aldı; §0b): bunlara dayanan adımlar park, Erdem'in cevabını bekler. Ayrı soru listesi yok: M2 maketi görsel
   sayfa olarak hazırlanır, bu kararların her biri ve eşikli kip o sayfada sade soru olarak durur (araştırma ya da ölçüm özeti,
   seçeneğin oyunda neyi değiştirdiği, oyuncu örneği). Erdem tek seferde cevaplar.
5. **C'ye üç sözleşme** D'den yazıldı, C kabul etti (2026-10-22; `c_taslak/PLAN_C_P2.md`'ye giriyor):
   - Şema: ilk inen sıradaki numarayı alır; C'nin kolu D'ninkinden sonra gelir.
   - Kesinti sırası: D3b `sprint.json`'da tek veri satırı, C5 devralır ve sırasını değiştirmez.
   - B2B hata terimi: D7 ölçeklemez; C3a terimi `SprintCatalog`'daki k ile kurar.
6. **Hata hacmi.** c oyunun bugünkü hacmine kalibre edilir (Karar 24'ün gerekçesi "toplam hacim bugünkü kalsın"). D3'te sapma
   %30'u aşarsa sorulmadan kalibre edilir ve raporda yazılır.

Kod adımları hâlâ Erdem'in "evet"ini ve Q'nun K20 commit'ini bekliyor.

## 5. RAPOR_D'ye ve kart PRD'sine giden notlar

- Kart sayısı artınca plan süresi yeniden ölçülecek. D2c'nin süre kapısı bugünkü gerçek dünyayla ölçülür (50 kişi, en çok 14
  kart); Pazar 2'nin modülleri ve kademeleri kart sayısını artırınca kapı yeniden koşulur (yardımcı yönetmen, 2026-10-22).
- D0a tabanı (iki Godot paralelken, yaklaşık): 50 kişide plan ekranının tam kurulumu ortanca 68 ile 74 ms, en çok 96 ms;
  `mvp_eta` tek başına 36 ile 45 ms. Bütçe ≤ 100 ms; P gelince ilk çare hesabı karelere bölmek, ilk aday `mvp_eta`.
- Bot 104. haftada yumuşak tavana takılıyor (`running_on_fumes`, `endings_system.gd` `_check_soft_cap`; bütün yapılarda):
  tohum 424242 ile `full_run_staff25/50` ve `build=ea` koşuları 22 kişide bitiyor. 25 ve 50 kişilik ölçümler yalnız
  `b2b_book20/330` fikstürüyle yapılır; büyüyen koşu 104 haftayla sınırlı (yardımcı yönetmen, 2026-10-22). Bulgu ekonomi
  PRD'sine girdi.
- c = 0,212 [WORKING]; kartlar yenilenince oyunun hacmine yeniden kalibre edilir. İlke yer değişimi 3 ile 5★ gereksinimli
  kartlarla yeniden ölçülür. Arz kapıları derinlik ve istek kartı olmadan raporlanır.

