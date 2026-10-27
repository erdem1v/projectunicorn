# D_W2

Faz D yazım dalgası, W2 (2026-10-22): PRD §3'ün oyuncu metinleri Erdem'in 2026-10-20/21 kararları ve yardımcı yönetmenin 2026-10-22 cevaplarıyla yenilendi. Darboğaz satırı yalnız taşmada ve sayaçlı; kural cümlesi, gereksinim parçası ve kalır satırı; "Bu çeyrek: hedef yok"; gönder sorusu bağlı kipte (eşikli kip metni ayrı işaretli); sürüm notunda Karar 28; PM kural A; Destek kartının eşik satırı; önerinin hedefsiz neden parçası. Derinlik kartı ve hesap isteği kartının metinleri kart yenilemesine ertelendi ("ertelendi" bölümü, silinmedi). Bütün metinler TR/EN onay bekliyor. Yer tutucular [a-z_]+ ve iki dilde aynı; yer tutucunun ardına ek gelmez, ek gereken yerde aşama başına ayrı anahtar var. Çoğul gereken EN satırlarının _ONE ikizi body_variants'tadır. Değişiklik listesi W_METINLER.md'nin "W2 değişiklikleri" bölümünde.

## W2 değişiklikleri (2026-10-22)

Kaynaklar: `ERDEM_KARARLAR_2026-10-20.md` ("D · Sprint metinleri" 25 ile 28; 1 ile 23 cevaplarından 19 ile 22; 24 ile 31 cevaplarından 24 ve 25), yardımcı yönetmenin 2026-10-22 kararları (`ADIM_TABLOSU_D_v2.md` §0, §3, §4), `ATAMA/A4_TASARIM.md` §1 ve §2, `ATAMA/A8_PROAKTIF_PLAN.md` §4.1, `M/M_KARELER.md`. Madde sayısı 88'den 64'e indi; 23 madde JSON'un `ertelendi` bölümüne taşındı. `wavecheck_d` temiz (0 hata, 0 uyarı); ertelenen maddeler de ayrıca temiz.

### Değişen

- **Darboğaz satırı** (`PRODUCT_NECK_LATE_*`, `PRODUCT_NECK_NOBODY_*`): metin aynı. Satır yalnız taşmada yazar; taşma yokken boştur ve yerine hiçbir metin gelmez (Karar 26). Kaynak planın oynatmasıdır, oran değil; öneri yazmaz. Söz verilmiş ya da tarihli kart listede başa yazılır (Karar 20, yeni metin yok).
- **Boşta ve arz cümleleri** (`PRODUCT_NECK_NO_CARDS`, `PRODUCT_NECK_IDLE_*`, `PRODUCT_NECK_NO_PREP`): metin ve anahtar aynı, yer değişti. Darboğaz satırından kişi satırına, aşama özetinin altına ve ipuçlarına iner (A4 §1b).
- **Kural cümlesi** `PRODUCT_TIP_RULE`: "En büyük işe en iyi kişi atanır." yerine TR "En zor işe en iyi kişiler, küçük işe onu bitirmeye yeten kişi atanır." · EN "The hardest job gets the best people; a small job gets whoever is good enough to finish it." (Karar 19; ilke Test'te de işler, cümle aşama adı taşımaz.)
- **Çeyrek başlığı:** `PRODUCT_QUARTER_WEAKEST` ("Bu çeyrek: en zayıf alan") yerine `PRODUCT_QUARTER_NONE` TR "Bu çeyrek: hedef yok" · EN "This quarter: no goal" (Karar 27). Anahtar adı anlam değiştiği için değişti; CSV'de henüz yok.
- **Sürüm notu** `PRODUCT_NOTE_SHIPPED_KNOWN`: "{card} bilinen hatalarıyla çıktı: {line} hattında {n} açık hata." yerine TR "{card} bilinen {n} hatayla çıktı." · EN "{card} shipped with {n} known bugs." (Karar 28). `{line}` kalktı; birden çok kart için `_MANY` eklendi.
- **Gönder sorusu** (`sprint_ship_known_bugs`): bırak seçeneğinin "Söz bu sprintte tutulmaz" çipi kalktı. Yerine TR "Söz bir sprint uzar: {customer}" · EN "Promise moves one sprint later: {customer}" (ilk bırakış) ve TR "Söz kırılır: {customer}" · EN "Promise broken: {customer}" (söz zaten bir kez uzadıysa) geldi (T1). Konuşan o kartın testini yapanlardan en çok hata bulan kişi, rolü ne olursa olsun; testi yalnız kurucu yaptıysa kurucunun notu (T2 A). Sabitlerin durumu güncellendi: kip "bağlı", eşikli kip Erdem'e soruldu; kesinti sırası D3b'de tek veri satırı, C5 devralır.
- **Görevler kutusu** `HR_TASK_UNFIT_TEST`: TR "Testte ×{mult} hız; test yaptığı her hafta için sprint sonunda −{n} moral" · EN "Testing at ×{mult} speed; −{n} morale at sprint end for each week of testing". D5'in özeti "sprint sonunda 2 moral" diyor; ama kayıp uymayan işte çalışılan her hafta için (PRD Karar 2) ve kutu sprintten önce okunuyor.
- **Uymayan iş satırı** `PRODUCT_UNFIT_TEST`: EN kısaldı (M_KARELER: sağ sütun uzayınca 2 satıra iniyordu). TR aynı.
- **Kişinin hız girdisi** `PRODUCT_PERSON_STAGE`: `{stage}` artık `PRODUCT_PERSON_WORD_*`'den gelir; EN kısa (Dev, Fix, Prep). Kişi satırının girdisi artık kalır satırıdır; hız girdisi tek kurucunun satırında ve ipucunda kalır.
- **Aşama özeti** `PRODUCT_STAGE_SUMMARY`: `{stage}` HAZIRLIK'ı da alır; PM'in boş zamanı boşta sayısına girmez.
- **Yalnız not değişenler:** `PRODUCT_CARD_PREP` (PM kural A), `PRODUCT_TIP_CREW_CAP` (U6: yalnız kartı en çok kısan aşama), `PRODUCT_NEXT_*` (U4: dar biçim), `PRODUCT_DELEGATED`, sürüm notunun test, düzeltmede kalan, çekilen kart ve hazırlık satırları (metin aynı), `HR_ATLAS_STAGE_SPEED`.

### Eklenen

- `PRODUCT_NECK_STREAK`: TR "Bu sorun {n} sprinttir sürüyor." · EN "This has been going on for {n} sprints." Aynı aşama üst üste ikinci sprintten itibaren taşıyorsa taşma cümlesinin arkasına gelir; n en az 2 olduğu için tekil yok (Karar 22).
- `PRODUCT_TIP_REQ`: TR "{stage} en az {stars}★" · EN "{stage} {stars}★ or more". İpucunun ihtiyaç satırında, gereksinim sıfırdan büyükse.
- `PRODUCT_TIP_RULE_PREP` (PM kural A): TR "En karmaşık kartı en iyi ürün yöneticisi, basit kartı onu hazırlamaya yeten ürün yöneticisi hazırlar." `PRODUCT_TIP_RULE_KEEP`: TR "Kişi, aşaması bitene kadar kartında kalır."
- **Kalır satırı** `PRODUCT_PERSON_KEEP`, `_THEN`, `_NEXT`, `_LATER`: TR "{name} · {card} · {stage} · {week}. haftada biter" ve "…, sonra {next}", "… · sonraki sprintin {week}. haftasında biter", "… · {n} sprint sonra biter". Kim hangi kartın hangi aşamasında ve ne zaman çıkıyor; planlayıcının kurduğu dağılım (Erdem'in örneğinde üçüncü geliştiricinin iki küçük kartı) bu satırda okunur.
- `PRODUCT_PERSON_WORD_DESIGN`, `_DEV`, `_TEST`, `_FIX`, `_PREP`: kişi satırının aşama sözcükleri.
- `PRODUCT_STAGE_SUMMARY_NONE_IDLE_ONE`: EN "{stage} · {n} person" (M_KARELER sorunu).
- `PRODUCT_SUGGEST_WHY_WEAKEST`: TR "Bu çeyrek hedef yok; öneri en zayıf alanı öne alıyor: {area}." · EN "No goal this quarter, so the suggestion puts the weakest area first: {area}." (D8a.)
- `PRODUCT_DELEGATE_PLAIN` ("Planlamayı devret" / "Delegate planning") ve `PRODUCT_PHASE_PREP` ("Hazırlık" / "Prep"): maketin zorunlu eklediği iki metin.
- `BUILD_SUPPORT_NEGLECT_TIP`: TR "Açık hata {limit} ve üstünde kalırsa {weeks}. haftadan başlayarak itibar her hafta 1 düşer." Destek kartının k'li eşik satırı (Karar 15, D7).
- `PRODUCT_NOTE_SHIPPED_KNOWN_MANY`: TR "{count} kart bilinen {n} hatayla çıktı: {cards}."
- Gönder sorusunda "YALNIZ EŞİKLİ KİPTE" işaretli iki gövde (testçi, kurucunun notu) ve bir çip ("{kart} bu sprintte teslim sayılır"). Erdem eşikli kipi kaldırırsa bunlar silinir.

### Silinen

- `PRODUCT_NECK_FITS_*` (taşma yokken satır boş, Karar 26).
- `PRODUCT_NECK_FULL_*` ("aşama satırı ≤ 2× kapasite" şartı düştü, ADIM_TABLOSU §3; cümlenin tetiği kalmadı).
- `PRODUCT_DELEGATE_SUGGEST` ("Son üç sprinti öneriyle aynen başlattın…"): devret önerisi düştü.
- `HR_AREA_MEANING_*` dört güncelleme (Q K19 anahtarları sildi).
- `PRODUCT_QUARTER_WEAKEST` (yerine `PRODUCT_QUARTER_NONE`) ve gönder sorusunun "Söz bu sprintte tutulmaz" çipi.

### Ertelenen (silinmedi; JSON'da `ertelendi`)

D8c ve D8d kart yenilemesine kaldı: `card.depth_gain` (`PRODUCT_DEPTH_GAIN*`), `card.request_title` (`PRODUCT_REQUEST_TITLE`), `card.depth_title`, 19 hattın derinlik adları (`name.line_*`), sözlükteki "kare / square" satırı. Kart yenilemesinde Karar 25 (istek kartının adı istek kâğıdının konusundan) ve U7 ("talebi zamanında" parçası kalkar) bunlara uygulanır.

### M_KARELER'in "W metninde bulunan sorunlar"ı

- `PRODUCT_STAGE_SUMMARY_NONE_IDLE` tekil biçimi: kapandı (`_NONE_IDLE_ONE`).
- `PRODUCT_NECK_FITS_*`: Karar 26 ile silindi; 1 kişi karesinde taşma yoksa satır çizilmez.
- EN kişi satırının uzunluğu: kapandı (`PRODUCT_PERSON_WORD_*`, EN kısa sözcük).
- EN `PRODUCT_UNFIT_TEST` 2 satıra iniyordu: EN kısaldı.

### Maket (M2) için

- Darboğaz satırı taşma yokken çizilmez; taşmada `NECK_LATE_*` ya da `NECK_NOBODY_*`, sayaç varsa arkasında `NECK_STREAK`.
- Kişi satırının girdisi `PRODUCT_PERSON_KEEP*`; boştaki kişi `PRODUCT_PERSON_IDLE`, nedeni ipucunda (`NECK_IDLE_*`, PM için `NECK_NO_PREP`); kart arzı biterse `NECK_NO_CARDS` aşama özetinin ya da kişi satırının altında.
- İpucu: ihtiyaç satırına `PRODUCT_TIP_REQ` ve en bağlayıcı aşamanın `PRODUCT_TIP_CREW_CAP`'ı; son satır `PRODUCT_TIP_RULE`, hazırlık satırının ipucunda `PRODUCT_TIP_RULE_PREP`, kalır cümlesi `PRODUCT_TIP_RULE_KEEP`.
- Çeyrek seçici hedef yokken `PRODUCT_QUARTER_NONE`; öneri satırı hedefsiz nedenini `PRODUCT_SUGGEST_WHY_WEAKEST` ile yazar.
- Kilitli devret düğmesi `PRODUCT_DELEGATE_PLAIN`; devret önerisi satırı çizilmez.

### Erdem'in cevabını bekleyen (M2 sayfasında soruluyor)

- Eşikli gönder kipi ayarı kalsın mı: "YALNIZ EŞİKLİ KİPTE" metinleri onun cevabına bağlı.
- A4'ün [WORKING] kararları T1 ve T2 (gönder sorusunun bırak çipleri ve konuşanı), U4 ve U6 (Sırada ve kadro tavanı biçimi) bu metinlerde uygulandı; Erdem değiştirirse ilgili satırlar değişir.
- Bütün metinler TR/EN onay bekliyor.

## plan.strip_row
`PRODUCT_STRIP_ROW` · ui · Ürün · Sprint planı · aşama şeridi, her satır

- **text**: EN: {stage} · work {work} · team {team} / TR: {stage} · iş {work} · ekip {team}

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, PRODUCT_PHASE_* anahtarından (TASARIM / GELİŞTİRME / TEST, Fmt.upper ile) |
| `{work}` | aşamada bu sprintin işi, puan, tam sayı |
| `{team}` | ekibin o aşamadaki sprint kapasitesi, puan |

_Not:_ PRD: TR "26 iş · ekip 20", EN "26 work · team 20". "26 work" İngilizce değil; iki dilde de ad önce, sayı sonra yazıldı ki iki parça aynı okunsun. Anlam aynı.

## plan.strip_over
`PRODUCT_STRIP_OVER` · ui · Ürün · Sprint planı · şerit satırının sağı, aşım varken

- **text**: EN: {n} points wait for the next sprint / TR: {n} puan sonraki sprinte kalır
- **body_variants[0] (n = 1)**: EN: {n} point waits for the next sprint / TR: {n} puan sonraki sprinte kalır

| Belirteç | Taşıdığı |
|---|---|
| `{n}` | aşamada sprinte sığmayan iş, puan, yukarı yuvarlanır |

_Not:_ PRD metni aynen.

## plan.neck_late
`PRODUCT_NECK_LATE_<STAGE>` · ui · Ürün · Sprint planı · darboğaz satırı, yalnız taşmada: planın oynatmasında plan kartlarından biri bu sprintte bitmiyorsa, en çok işin kaldığı aşama

- **text**: EN: Testing can't keep up: {cards} stay in testing. / TR: Test yetişmiyor: {cards} testte kalır.
- **body_variants[0] (test, birden çok kart)**: EN: Testing can't keep up: {cards} stay in testing. / TR: Test yetişmiyor: {cards} testte kalır.
- **body_variants[1] (test, tek kart)**: EN: Testing can't keep up: {cards} stays in testing. / TR: Test yetişmiyor: {cards} testte kalır.
- **body_variants[2] (tasarım, birden çok kart)**: EN: Design can't keep up: {cards} stay in design. / TR: Tasarım yetişmiyor: {cards} tasarımda kalır.
- **body_variants[3] (tasarım, tek kart)**: EN: Design can't keep up: {cards} stays in design. / TR: Tasarım yetişmiyor: {cards} tasarımda kalır.
- **body_variants[4] (geliştirme, birden çok kart)**: EN: Development can't keep up: {cards} stay in development. / TR: Geliştirme yetişmiyor: {cards} geliştirmede kalır.
- **body_variants[5] (geliştirme, tek kart)**: EN: Development can't keep up: {cards} stays in development. / TR: Geliştirme yetişmiyor: {cards} geliştirmede kalır.
- **body_variants[6] (düzeltme, birden çok kart)**: EN: Fixing can't keep up: {cards} stay in fixing. / TR: Düzeltme yetişmiyor: {cards} düzeltmede kalır.
- **body_variants[7] (düzeltme, tek kart)**: EN: Fixing can't keep up: {cards} stays in fixing. / TR: Düzeltme yetişmiyor: {cards} düzeltmede kalır.

| Belirteç | Taşıdığı |
|---|---|
| `{cards}` | kart adları, PRODUCT_LIST_* ile birleşmiş |

_Not:_ PRD metni aynen; aşama başına ayrı anahtar, çünkü TR'de aşama adı ek alıyor (testte, tasarımda) ve araya giren değer ek alamaz. Düzeltme alt aşaması da darboğaz olabildiği için FIX satırı eklendi. PRD örneğindeki kart adları oyunda "Hesap Planı / Chart of Accounts" ve "Stok Sayacı / Stock Count"tur; PRD'nin EN örneği (Account Plan, Stock Counter) mevcut kart adlarıyla uyuşmuyor. W2: Satır yalnız taşmada yazar; taşma yokken boştur, yerine hiçbir metin gelmez (Karar 26). Kaynak planın oynatmasıdır, yük ÷ kapasite oranı değil. Öneri yazmaz. Söz verilmiş ya da tarihli kart {cards} listesinde başa yazılır (Karar 20; yeni metin yok). Aynı aşama üst üste ikinci sprintten itibaren taşıyorsa cümlenin arkasına PRODUCT_NECK_STREAK eklenir.

## plan.neck_streak
`PRODUCT_NECK_STREAK` · ui · Ürün · Sprint planı · darboğaz satırı, taşma cümlesinin (PRODUCT_NECK_LATE_* ya da PRODUCT_NECK_NOBODY_*) arkasına, aynı aşama üst üste ikinci sprintten itibaren taşıyorsa

- **text**: EN: This has been going on for {n} sprints. / TR: Bu sorun {n} sprinttir sürüyor.

| Belirteç | Taşıdığı |
|---|---|
| `{n}` | aynı aşamanın üst üste taştığı sprint sayısı, bu planınki dahil; 2 ve üstüyken yazılır. Sayaç sürüm kaydındaki taşan aşama ve ardışık sayıdan gelir (D1); aşama değişince ya da taşma kalkınca 1'e döner |

_Not:_ W2, yeni. Erdem'in istediği ton aynen. n en az 2 olduğu için tekil biçim gerekmez. Ayrı cümle olduğu için aşama başına anahtar çoğalmaz; satır en çok iki cümle olur. Öneri yazmaz.

## plan.neck_no_cards
`PRODUCT_NECK_NO_CARDS` · ui · Ürün · Sprint planı · aşama özetinin altı (8 kişiden büyük ekipte) ya da kişi satırının altı; darboğaz satırında değil

- **text**: EN: No cards left to plan: {n} people are idle this sprint. / TR: Planlanacak kart kalmadı: {n} kişi bu sprint boşta.
- **body_variants[0] (n = 1)**: EN: No cards left to plan: {n} person is idle this sprint. / TR: Planlanacak kart kalmadı: {n} kişi bu sprint boşta.

| Belirteç | Taşıdığı |
|---|---|
| `{n}` | sprintte boşta kalan kişi sayısı |

_Not:_ PRD metni aynen. W2: Darboğaz satırı artık yalnız taşma içindir (Karar 26); kart arzı cümlesi kişi ve özet satırlarına iner (A4 §1b). Metin değişmedi.

## plan.neck_idle
`PRODUCT_NECK_IDLE_<STAGE>` · ui · Ürün · Sprint planı · kişi satırında boştaki kişinin ipucu; 8 kişiden büyük ekipte aşama özetinin ipucu (darboğaz satırında değil)

- **text**: EN: {name} is idle: no card is open for development. / TR: {name} boşta: geliştirmeye açık kart yok.
- **body_variants[0] (geliştirme)**: EN: {name} is idle: no card is open for development. / TR: {name} boşta: geliştirmeye açık kart yok.
- **body_variants[1] (tasarım)**: EN: {name} is idle: no card is open for design. / TR: {name} boşta: tasarıma açık kart yok.
- **body_variants[2] (test)**: EN: {name} is idle: no card is open for testing. / TR: {name} boşta: teste açık kart yok.

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kişinin adı; kurucu için HR_ROLE_FOUNDER |

_Not:_ PRD metni aynen; aşama başına anahtar (TR ek: tasarıma, geliştirmeye, teste). W2: Yeri değişti (A4 §1b, Karar 26); metin değişmedi.

## plan.neck_no_prep
`PRODUCT_NECK_NO_PREP` · ui · Ürün · Sprint planı · ürün yöneticisinin kişi satırı ipucu (darboğaz satırında değil)

- **text**: EN: {name} has no cards left to prepare. / TR: {name} için hazırlanacak kart kalmadı.

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | ürün yöneticisinin adı |

_Not:_ PRD TR "Selin'in hazırlayacağı kart kalmadı." adın ardına ek koyuyordu ('in); "{name} için hazırlanacak kart" ile ek kalktı, anlam aynı. EN aynen. W2: Yeri değişti (A4 §1b); PM'in boş zamanı aşama özetinin boşta sayısına girmez.

## plan.neck_nobody
`PRODUCT_NECK_NOBODY_<STAGE>` · ui · Ürün · Sprint planı · darboğaz satırı, yalnız taşmada: aşamaya girebilecek kimse yokken

- **text**: EN: Nobody can test. / TR: Testi yapacak kimse yok.
- **body_variants[0] (test)**: EN: Nobody can test. / TR: Testi yapacak kimse yok.
- **body_variants[1] (tasarım)**: EN: Nobody can work on design. / TR: Tasarımı yapacak kimse yok.
- **body_variants[2] (geliştirme)**: EN: Nobody can work on development. / TR: Geliştirmeyi yapacak kimse yok.

_Not:_ Test satırı PRD'den aynen. Kurucu toplantıda ya da Ar-Ge'deyken tasarım ve geliştirme de boş kalabildiği için iki satır eklendi. Bugünkü PRODUCT_ROLE_MISSING ("Ekipte {role} yok · kartlar hatalı çıkabilir") D'de anlamını yitirir (testçisiz kart işareti kalkıyor) ve öneri yazıyor; D bu anahtarı siler. W2: Bu da bir taşmadır (kart o aşamada kalır); üst üste sürerse arkasına PRODUCT_NECK_STREAK eklenir.

## plan.founder_testing
`PRODUCT_FOUNDER_TESTING` · ui · Ürün · Sprint planı · kurucunun işi düştüğünde, neden cümlesi 1

- **text**: EN: The founder is testing: nobody else on the team can test. / TR: Kurucu testte: ekipte testi yapacak başka kimse yok.

_Not:_ TR aynen. EN'e "The" eklendi ("Founder is testing" İngilizcede eksik kalıyor; mevcut PRODUCT_TEAM_IN_RND da "The founder is in R&D" der).

## plan.founder_shares
`PRODUCT_FOUNDER_SHARES_<STAGE>` · ui · Ürün · Sprint planı · kurucunun işi düştüğünde, neden cümlesi 2

- **text**: EN: The founder shares development with {people}. / TR: Kurucu geliştirmeyi {people} ile paylaşıyor.
- **body_variants[0] (geliştirme)**: EN: The founder shares development with {people}. / TR: Kurucu geliştirmeyi {people} ile paylaşıyor.
- **body_variants[1] (tasarım)**: EN: The founder shares design with {people}. / TR: Kurucu tasarımı {people} ile paylaşıyor.
- **body_variants[2] (test)**: EN: The founder shares testing with {people}. / TR: Kurucu testi {people} ile paylaşıyor.

| Belirteç | Taşıdığı |
|---|---|
| `{people}` | aynı aşamadaki öbür kişiler, yalnız adlar, PRODUCT_LIST_* ile |

_Not:_ PRD TR "Kurucu Geliştirme'yi Mert ile paylaşıyor." Aşama adı cümle içinde özel ad değildir; Türkçede kesme işaretsiz ve küçük harfle yazılır ("geliştirmeyi"). Aşama başına anahtar, çünkü ek aşamaya göre değişir. EN'e "The" eklendi.

## plan.founder_prepared
`PRODUCT_FOUNDER_PREPARED` · ui · Ürün · Sprint planı · kurucunun işi düştüğünde, neden cümlesi 3

- **text**: EN: Cards came prepared: the same work took fewer points. / TR: Kartlar hazır geldi: aynı iş daha az puan tuttu.

_Not:_ PRD metni aynen.

## plan.founder_meetings
`PRODUCT_FOUNDER_MEETINGS` · ui · Ürün · Sprint planı · kurucunun satırı, toplantılı haftada

- **text**: EN: The founder has {n} meetings this week: sprint share {pct}. / TR: Kurucu bu hafta {n} görüşmede: sprint payı {pct}.
- **body_variants[0] (n = 1)**: EN: The founder has {n} meeting this week: sprint share {pct}. / TR: Kurucu bu hafta {n} görüşmede: sprint payı {pct}.

| Belirteç | Taşıdığı |
|---|---|
| `{n}` | kurucunun bu haftaki görüşme sayısı |
| `{pct}` | Fmt ile biçimlenmiş yüzde: TR %30, EN 30% |

_Not:_ PRD metni aynen (PRD'nin kendisi bu yüzdeyi gösteriyor); EN'e "The" eklendi.

## plan.next_pull
`PRODUCT_NEXT_PULL` · ui · Ürün · Sprint planı · "Sırada" satırı, çekilen kart sprintte biterken

- **text**: EN: Up next: {card}. The team picks it up in week {week}. / TR: Sırada: {card}. Ekip {week}. haftada bu kartı çeker.

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{week}` | sprintin haftası, 1 ya da 2 |

_Not:_ PRD metni aynen.

## plan.next_carry
`PRODUCT_NEXT_PULL_CARRY` · ui · Ürün · Sprint planı · "Sırada" satırı, çekilen kart sprinte yetişmezken

- **text**: EN: Up next: {card}. It starts in week {week} and carries over to the next sprint. / TR: Sırada: {card}. {week}. haftada başlar, sonraki sprinte devreder.

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{week}` | sprintin haftası, 1 ya da 2 |

_Not:_ PRD metni aynen.

## plan.next_short
`PRODUCT_NEXT_LABEL / PRODUCT_NEXT_ROW*` · ui · Ürün · Sprint planı · "Sırada" satırının dar hâli (maketteki tek satır)

- **text**: EN: Up next / TR: Sırada
- **body_variants[0] (etiket)**: EN: Up next / TR: Sırada
- **body_variants[1] (biten)**: EN: {card} · picked up in week {week} / TR: {card} · {week}. haftada çekilir
- **body_variants[2] (devreden)**: EN: {card} · starts in week {week}, carries over / TR: {card} · {week}. haftada başlar, devreder

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{week}` | sprintin haftası, 1 ya da 2 |

_Not:_ Maketteki "SIRADA  Stok uyarısı · 2. haftada çekilir" biçimi. Mevcut PRODUCT_QUEUED ("Sırada / Queued") kart damgasıdır, EN'i farklı olduğu için ayrı anahtar. Uzun cümle mi dar satır mı, M maketi seçer. W2: U4 (A4 [WORKING]): dar biçim; uzun cümle (PRODUCT_NEXT_PULL*) ipucunda kalır.

## plan.unfit
`PRODUCT_UNFIT_TEST` · ui · Ürün · Sprint planı · uymayan iş, kişinin adıyla

- **text**: EN: {name} is testing at ×{mult} speed with no other work, and loses {n} morale at sprint end. / TR: {name} testte ×{mult} hızla çalışıyor; başka işi yok. Sprint sonunda {n} moral kaybeder.

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kişinin adı; kurucu için HR_ROLE_FOUNDER |
| `{mult}` | Fmt ile biçimlenmiş çarpan, × işareti metinde: TR 0,4, EN 0.4 |
| `{n}` | sprint sonu moral kaybı, uymayan iş haftası × 2 |

_Not:_ TR aynen. EN'deki "her" ve "She" kalktı: ad bir yer tutucudur, cinsiyeti bilinmez. Karar 2 tablosunda uymayan iş yalnız Test kutusunda doğar (PM ve tasarımcı ×0,4); bu yüzden yalnız test anahtarı var. W2: EN kısaltıldı (M_KARELER: sağ sütun uzayınca 2 satıra iniyordu); anlam aynı. {n} kişinin o sprintte uymayan işte çalıştığı hafta × 2.

## plan.quarter
`PRODUCT_QUARTER_GOAL` · ui · Ürün · Sprint planı · başlığın sağı, çeyrek hedefi (PM'siz de açık)

- **text**: EN: This quarter: {goal} / TR: Bu çeyrek: {goal}
- **body_variants[0] (seçenek: hatalar)**: EN: Bugs / TR: Hatalar
- **body_variants[1] (hedef seçilmemişken başlık)**: EN: This quarter: no goal / TR: Bu çeyrek: hedef yok

| Belirteç | Taşıdığı |
|---|---|
| `{goal}` | seçilen alanın kısa adı (PRODUCT_AREA_*_SHORT) ya da PRODUCT_QUARTER_BUGS |

_Not:_ PRD metni aynen. Seçenekler mevcut PRODUCT_AREA_*_SHORT anahtarları ve yeni "Hatalar"; çeyrek PM'siz de seçilir. Çeyrek PM'siz açıldığı için PRODUCT_QUARTER_NEED_PM ("PM işe alınca") ölü anahtar olur, D8b siler. W2: hedef yokken başlık "Bu çeyrek: hedef yok" (Karar 27). Eski PRODUCT_QUARTER_WEAKEST ("Bu çeyrek: en zayıf alan") kalktı; anahtar adı yeni anlamı taşısın diye PRODUCT_QUARTER_NONE oldu. Hedef yokken önerinin en zayıf alana gittiğini başlık değil öneri satırı söyler (PRODUCT_SUGGEST_WHY_WEAKEST).

## plan.delegate_locked
`PRODUCT_DELEGATE_LOCKED` · ui · Ürün · Sprint planı · "Planlamayı devret" kilitliyken gerekçe

- **text**: EN: You need a product manager on the team to delegate planning. / TR: Planlamayı devretmek için ekipte bir ürün yöneticisi olmalı.

_Not:_ TR aynen. EN "hand planning over" yerine "delegate planning": düğmenin mevcut anahtarı PRODUCT_DELEGATE "Delegate planning: {name}" der; aynı eylem iki ayrı fiille yazılmasın.

## plan.delegate_plain
`PRODUCT_DELEGATE_PLAIN` · ui · Ürün · Sprint planı · "Planlamayı devret" düğmesinin adsız etiketi (PM yokken kilitli düğme)

- **text**: EN: Delegate planning / TR: Planlamayı devret

_Not:_ W2, yeni (maketin zorunlu eklediği metin). Mevcut PRODUCT_DELEGATE "Planlamayı devret: {name}" PM'in adını ister; PM yokken ad olmadığı için kilitli düğme bu anahtarı okur. PM varken düğme mevcut anahtarla adı yazar.

## plan.delegated
`PRODUCT_DELEGATED` · ui · Ürün · Sprint planı · planlama PM'deyken

- **text**: EN: {name} runs the planning. Each sprint starts on its own with the suggested plan. / TR: Planlamayı {name} yürütüyor. Her sprint önerilen planla kendiliğinden başlar.

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | planlamayı yürüten ürün yöneticisi |

_Not:_ PRD TR "Planlama Selin'de." adın ardına ek koyuyordu ('de). Yeni cümle eksiz ve bir öncekiyle aynı fiili kullanır. EN "has the planning" ve "start on the suggestion by themselves" doğal değil; yeniden yazıldı. W2: Devret önerisi satırı düştüğü için (yardımcı yönetmen 2026-10-22) devirle ilgili satırlar kilit nedeni, devirde durum, geri alma ve PM ayrılınca kalkma; metin değişmedi.

## plan.delegate_undo
`PRODUCT_DELEGATE_UNDO` · ui · Ürün · Sprint planı · devirdeyken geri alma düğmesi

- **text**: EN: Take planning back / TR: Planlamayı geri al

_Not:_ PRD'de metni yok; Karar 12'nin istediği düğme.

## plan.delegate_ended
`PRODUCT_DELEGATE_ENDED` · ui · Ürün · Sprint planı · planlamayı yürüten PM ayrılınca

- **text**: EN: {name} has left, so planning is back with you. / TR: {name} ayrıldı, planlama yeniden sende.

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | ayrılan ürün yöneticisi |

_Not:_ PRD'de metni yok, öneri: plan oyuncuyu neden beklediğini söylemezse saat sebepsiz durmuş görünür.

## plan.stage_summary
`PRODUCT_STAGE_SUMMARY` · ui · Ürün · Sprint planı · kişi satırı sığmayan ekipte aşama başına özet

- **text**: EN: {stage} · {n} people · {idle} idle / TR: {stage} · {n} kişi · {idle} boşta
- **body_variants[0] (boşta kimse yok)**: EN: {stage} · {n} people / TR: {stage} · {n} kişi
- **body_variants[1] (boşta kimse yok, n = 1)**: EN: {stage} · {n} person / TR: {stage} · {n} kişi
- **body_variants[2] (n = 1)**: EN: {stage} · {n} person · {idle} idle / TR: {stage} · {n} kişi · {idle} boşta

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, PRODUCT_PHASE_* anahtarından (TASARIM / GELİŞTİRME / TEST / HAZIRLIK, Fmt.upper ile) |
| `{n}` | o aşamada çalışan kişi |
| `{idle}` | o aşamada boşta kalan kişi |

_Not:_ PRD metni aynen. W2: M_KARELER'in bulduğu tekil eksiği kapandı: EN "DESIGN · 1 people" yerine PRODUCT_STAGE_SUMMARY_NONE_IDLE_ONE "DESIGN · 1 person". PM'in satırı "HAZIRLIK · 3 kişi" (PRODUCT_PHASE_PREP); PM'in boş zamanı boşta sayısına girmez (A4 §1b). 8 kişiden büyük ekipte kişi satırının yerini alır (U2, A4 [WORKING]).

## plan.person_row
`PRODUCT_PERSON_STAGE / PRODUCT_PERSON_IDLE / PRODUCT_PERSON_WORD_*` · ui · Ürün · Sprint planı · kişinin hız girdisi: tek kurucunun satırı ve kişi satırındaki girdinin ipucu; boştaki kişinin girdisi

- **text**: EN: {name} · {stage} {pts}/wk / TR: {name} · {stage} {pts}/hf
- **body_variants[0] (boşta)**: EN: {name} · idle / TR: {name} · boşta
- **body_variants[1] (aşama sözcüğü: tasarım)**: EN: Design / TR: Tasarım
- **body_variants[2] (aşama sözcüğü: geliştirme)**: EN: Dev / TR: Geliştirme
- **body_variants[3] (aşama sözcüğü: test)**: EN: Test / TR: Test
- **body_variants[4] (aşama sözcüğü: düzeltme)**: EN: Fix / TR: Düzeltme
- **body_variants[5] (aşama sözcüğü: PM'in hazırlığı)**: EN: Prep / TR: Hazırlık

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kişinin adı; kurucu için HR_ROLE_FOUNDER |
| `{stage}` | aşamanın kişi satırındaki adı, PRODUCT_PERSON_WORD_* (EN kısa: Dev, Fix, Prep) |
| `{pts}` | kişinin o aşamadaki haftalık hızı, tam sayı |

_Not:_ Maketteki "Kurucu · Tasarım 9/hf", "Mert · boşta". "Ayşe · Test" için mevcut PRODUCT_PERSON_ROLE kullanılır. "/hf" kısaltması yeni (sözlükte yok), EN "/wk". W2: M_KARELER'in bulduğu sorun: EN kişi satırı TR'den uzundu ("Founder · Development 5/wk" 3 satıra iniyordu). Kişi satırının aşama sözcüğü artık ayrı anahtar (PRODUCT_PERSON_WORD_*): EN kısa (Dev, Fix, Prep), TR tam ad; böylece EN satırı TR'den kısa ya da eşit kalır. PM'in sözcüğü "Hazırlık / Prep" maketin zorunlu eklediği metindi (M_KARELER madde 2), burada anahtar oldu. Kişi satırının girdisi artık "kalır" satırıdır (PRODUCT_PERSON_KEEP*); hız girdisi tek kurucunun satırında ve ipucunda kalır.

## plan.person_keep
`PRODUCT_PERSON_KEEP*` · ui · Ürün · Sprint planı · kişi satırı (8 kişiye kadar), kişi başına: hangi kartın hangi aşamasında, ne zaman bitirip çıkacağı; bilgi planın oynatmasından

- **text**: EN: {name} · {card} · {stage} · done in week {week} / TR: {name} · {card} · {stage} · {week}. haftada biter
- **body_variants[0] (bu sprintte biter)**: EN: {name} · {card} · {stage} · done in week {week} / TR: {name} · {card} · {stage} · {week}. haftada biter
- **body_variants[1] (bu sprintte biter, aynı sprintte başka karta geçer)**: EN: {name} · {card} · {stage} · done in week {week}, then {next} / TR: {name} · {card} · {stage} · {week}. haftada biter, sonra {next}
- **body_variants[2] (sonraki sprintte biter)**: EN: {name} · {card} · {stage} · done in week {week} of the next sprint / TR: {name} · {card} · {stage} · sonraki sprintin {week}. haftasında biter
- **body_variants[3] (iki sprint ya da daha sonra biter)**: EN: {name} · {card} · {stage} · done in {n} sprints / TR: {name} · {card} · {stage} · {n} sprint sonra biter

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kişinin adı; kurucu için HR_ROLE_FOUNDER |
| `{card}` | kişinin şu an girdiği kart (PROD_STEP_* ya da düzeltme kartının adı) |
| `{stage}` | aşamanın kişi satırındaki adı, PRODUCT_PERSON_WORD_* |
| `{week}` | kişinin o kartın aşamasını bitirdiği sprint haftası, 1 ya da 2 (sonraki sprintte bitiyorsa o sprintin haftası) |
| `{next}` | oynatmada kişinin sonra geçtiği kart (aynı sprintte) |
| `{n}` | aşamanın bitmesine kalan sprint sayısı, 2 ve üstü |

_Not:_ W2, yeni. Kişi aşaması bitene kadar kartında kalır; satır bunu ve kişinin ne zaman çıkacağını söyler. "biter" kişinin o kartta yaptığı aşamanın bitmesidir, kartın değil. Erdem'in örneğinde üçüncü geliştiricinin satırı "Kaan · Küçük kart · Geliştirme · 1. haftada biter, sonra İkinci küçük kart" olur: planlayıcının kurduğu dağılım kişi satırında okunur. Çok sprintlik büyük kartta "sonraki sprintin 2. haftasında biter" ya da "2 sprint sonra biter". Boştaki kişi PRODUCT_PERSON_IDLE, uymayan iş PRODUCT_UNFIT_TEST ile yazılır. EN "done in week" kısa tutuldu ki satır TR'den uzun olmasın.

## plan.suggestion
`PRODUCT_SUGGEST_*` · ui · Ürün · Sprint planı · öneri satırı ve düğmesi

- **text**: EN: Suggestion / TR: Öneri
- **body_variants[0] (etiket)**: EN: Suggestion / TR: Öneri
- **body_variants[1] (tek kart)**: EN: {card} goes into this sprint. / TR: {card} bu sprinte girer.
- **body_variants[2] (iki kart)**: EN: {first} and {second} go into this sprint. / TR: {first} ve {second} bu sprinte girer.
- **body_variants[3] (üç ve üstü)**: EN: {first}, {second} and {n} more cards go into this sprint. / TR: {first}, {second} ve {n} kart daha bu sprinte girer.
- **body_variants[4] (üç kart)**: EN: {first}, {second} and {n} more card go into this sprint. / TR: {first}, {second} ve {n} kart daha bu sprinte girer.
- **body_variants[5] (neden parçası: çeyrek hedefi yokken önerinin 5. basamağı en zayıf alana gitti)**: EN: No goal this quarter, so the suggestion puts the weakest area first: {area}. / TR: Bu çeyrek hedef yok; öneri en zayıf alanı öne alıyor: {area}.
- **body_variants[6] (düğme)**: EN: Apply the suggestion / TR: Öneriyi uygula

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kart adı |
| `{first}` | ilk kart |
| `{second}` | ikinci kart |
| `{n}` | kalan kart sayısı |
| `{area}` | en zayıf alanın adı (PRODUCT_AREA_*) |

_Not:_ Maketin satırı. Mevcut PRODUCT_LEAD_* ailesi ("... bu sprintte bitmeli", "Lead's pick") Karar 12'nin tek önerisine dönüşüyor; D0 haritası hangisinin kalacağını yazar. Yeni cümle "girer" der, "bitmeli" demez: öneri bir gözlemdir, zorunluluk değil. W2: Hedef yokken 5. basamak en zayıf alana gider (D8a); öneri satırı nedenini PRODUCT_SUGGEST_WHY_WEAKEST ile yazar, yalnız o alanın kartı öneriye girdiyse. Ekrana D6'da çıkar.

## plan.fix_share
`PRODUCT_FIX_SHARE_FULL` · ui · Ürün · Sprint planı · sonraki sprint sütununda bekleyen düzeltme kartının ipucu

- **text**: EN: Half of this sprint already goes to fix cards. / TR: Bu sprintin yarısı zaten düzeltme kartlarına gidiyor.

_Not:_ Kaynak: "Bu sprintin yarısı zaten düzeltmeye gidiyor." D'de "Düzeltme" aynı zamanda kartın içindeki alt aşamanın adı; tavan yalnız düzeltme kartlarını sayar (kart içi düzeltme işi pay tavanına girmez, Karar 7), bu yüzden "düzeltme kartlarına". D_MODEL_v2 düzeltme payını planda yüzdeyle göstermeyi öneriyordu; PRD planda yüzdeyi yasaklıyor, yüzde yok. "yarısı" FIX_SHARE_MAX 0,5'e bağlıdır.

## plan.list_join
`PRODUCT_LIST_*` · ui · Ürün · ortak · kart ve kişi listelerinin birleşimi ({cards}, {people})

- **text**: EN: {first} and {second} / TR: {first} ve {second}
- **body_variants[0] (iki öğe)**: EN: {first} and {second} / TR: {first} ve {second}
- **body_variants[1] (kart, üç ve üstü)**: EN: {first}, {second} and {n} more cards / TR: {first}, {second} ve {n} kart daha
- **body_variants[2] (kart, üç)**: EN: {first}, {second} and {n} more card / TR: {first}, {second} ve {n} kart daha
- **body_variants[3] (kişi, üç ve üstü)**: EN: {first}, {second} and {n} others / TR: {first}, {second} ve {n} kişi daha
- **body_variants[4] (kişi, üç)**: EN: {first}, {second} and {n} other / TR: {first}, {second} ve {n} kişi daha

| Belirteç | Taşıdığı |
|---|---|
| `{first}` | ilk öğe |
| `{second}` | ikinci öğe |
| `{n}` | kalan öğe sayısı |

_Not:_ Darboğaz, kurucu, test ve aşama satırlarındaki listeler bunları okur. İki öğeden çoğunda ilk ikisi ve sayı yazılır, satır uzamaz (kapı §4.3 madde 5).

## card.prep
`PRODUCT_CARD_PREP` · ui · Ürün · Sprint planı · kart yüzü, satır 1 (kart hazırlandıysa)

- **text**: EN: Prepared by {name} {stars}★ · speed +{pct} / TR: {name} {stars}★ hazırladı · hız +{pct}
- **body_variants[0] (kart kısmen hazır)**: EN: Partly prepared by {name} {stars}★ · speed +{pct} / TR: {name} {stars}★ kısmen hazırladı · hız +{pct}

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kartı hazırlayan ürün yöneticisi |
| `{stars}` | kişinin gerçek yıldızı, tam sayı (kurucu tabanı yazılmaz) |
| `{pct}` | Fmt ile biçimlenmiş yüzde: TR %30, EN 30% |

_Not:_ PRD metni aynen. Örnek iyi PM: "Selin 5★ hazırladı · hız +%30" / "Prepared by Selin 5★ · speed +30%"; zayıf PM: "Can 2★ hazırladı · hız +%15" / "Prepared by Can 2★ · speed +15%". Yarım hazırlık için ikinci satır eklendi: yoksa yarım hazırlanmış büyük kartta 5★ PM'in +%15'i, tam hazırlanmış küçük kartta 2★ PM'in +%15'iyle aynı okunur. EN "speed": sözlükte "hız (sprint) ↔ velocity" ekibin sprint hızıdır; kişinin ve kartın hızı için sözlüğe "hız (kişi, kart) ↔ speed" satırı öneriliyor. W2: PM kural A: kartlar karmaşıklığa (puan × gereksinim) göre dizilir; karmaşık dilim en iyi PM'e, basit dilim yeten en zayıf PM'e gider (D4). Satır hazırlayan PM'i ve bonusunu yazar; büyük kartta "Selin 5★ hazırladı · hız +%30", küçük kartta "Can 2★ hazırladı · hız +%15". Ürün kapısını geçemeyen PM'in payı en yakın uygun PM'e kayar, hazırlayan değişmez; satır hazırlayanı yazar. Metin değişmedi.

## card.crew
`PRODUCT_CARD_CREW_ENTRY` · ui · Ürün · Sprint planı · kart yüzü, satır 2: aşama başına baştaki kişi (Tasarım · Geliştirme · Test sırası)

- **text**: EN: {name} {stars}★ / TR: {name} {stars}★
- **body_variants[0] (aşamada birden çok kişi)**: EN: {name} {stars}★ +{more} / TR: {name} {stars}★ +{more}

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | kişinin adı; kurucu için HR_ROLE_FOUNDER |
| `{stars}` | kişinin gerçek yıldızı, tam sayı (kurucu tabanı yazılmaz) |
| `{more}` | o aşamadaki öbür kişi sayısı |

_Not:_ PRD: "Ece 3★ · Mert 4★ +1 · Ayşe 3★", iki dilde aynı. Ayraç " · ". Kartın işi olmayan aşama atlanır.

## card.unfit_tag
`PRODUCT_CARD_UNFIT` · ui · Ürün · Sprint planı · kart yüzü, uymayan kişi o aşamadaysa

- **text**: EN: {stage} ×{mult} / TR: {stage} ×{mult}

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, PRODUCT_PHASE_* anahtarından (TASARIM / GELİŞTİRME / TEST, Fmt.upper ile) |
| `{mult}` | Fmt ile biçimlenmiş çarpan, × işareti metinde: TR 0,4, EN 0.4 |

_Not:_ Karar 2'nin okunuşu; iki dilde aynı şablon.

## tip.needs
`PRODUCT_TIP_NEED` · ui · Ürün · Sprint planı · kart ipucu, ihtiyaç satırı (parça başına)

- **text**: EN: {stage} {pts} / TR: {stage} {pts}

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, cümle düzeninde |
| `{pts}` | kartın o aşamadaki ihtiyacı, puan |

_Not:_ PRD metni aynen, parça parça: ihtiyacı 0 olan aşama (ör. araştırma kartında test) yazılmaz. Ayraç " · ".

## tip.crew_cap
`PRODUCT_TIP_CREW_CAP` · ui · Ürün · Sprint planı · kart ipucu, ihtiyaç satırının sonu (kadro tavanı)

- **text**: EN: {stage} {n} people at most / TR: {stage} en çok {n} kişi
- **body_variants[0] (n = 1)**: EN: {stage} {n} person at most / TR: {stage} en çok {n} kişi

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, cümle düzeninde |
| `{n}` | aşamanın kadrosu ⌈ihtiyaç ÷ dilim⌉ |

_Not:_ PRD metni aynen, aşama yer tutucuyla (TR'de aşama adı ek almıyor). Kadro 1 olan aşamada da yazmak bilgidir: beş testçi varken neden biri çalışıyor sorusunu cevaplar. Hangi aşamaların yazılacağını M maketi seçer. W2: U6 (A4 [WORKING]): yalnız kartı en çok kısan aşamanın tavanı yazılır, ihtiyaç satırı tek satır kalır.

## tip.req
`PRODUCT_TIP_REQ` · ui · Ürün · Sprint planı · kart ipucu, ihtiyaç satırının parçası: aşamanın gereksinimi, yalnız sıfırdan büyükse ("Tasarım 9 · Geliştirme 11 · Test 5 · Geliştirme en az 2★")

- **text**: EN: {stage} {stars}★ or more / TR: {stage} en az {stars}★

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, cümle düzeninde |
| `{stars}` | aşamanın gereksinimi, yıldız, tam sayı (hattın kilit verisi requires.person; kilitsiz kartta A4 §1(a) madde 1'in kabulleri) |

_Not:_ W2, yeni. Tarifin ikinci ölçüsü görünmezse oyuncu "bu kişi neden orada" diye sorar (A4 §1a). Parça ihtiyaç satırına, kadro tavanının yanına girer; kart yüzüne girmez. Ekipte gereksinimi karşılayan yoksa kural ekibin o aşamadaki en iyisine iner, satır yine kartın gereksinimini yazar: alım sinyali. A4'ün önerdiği "Geliştirme · en az 2★: Deniz 4★ ve Ece 3★" biçimi yerine ayrı parça: aşama satırı (PRODUCT_TIP_STAGE) değişmez, iki anahtar tek yerde birleşmez.

## tip.stage
`PRODUCT_TIP_STAGE` · ui · Ürün · Sprint planı · kart ipucu, aşama satırı (atanan kişiler ve yapım kalitesi)

- **text**: EN: {stage}: {people} / TR: {stage}: {people}
- **body_variants[0] (kalite sözcüğüyle)**: EN: {stage}: {people} · {quality} / TR: {stage}: {people} · {quality}

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, cümle düzeninde |
| `{people}` | kişi girdileri ({name} {stars}★), PRODUCT_LIST_* ile birleşmiş |
| `{quality}` | PRODUCT_QUALITY_CAREFUL ya da _HASTY; ikisi de değilse yazılmaz |

_Not:_ PRD metni aynen; kalite sözcüğü yalnız geliştirme ve düzeltme satırında.

## tip.prep
`PRODUCT_TIP_PREP` · ui · Ürün · Sprint planı · kart ipucu, hazırlık satırı

- **text**: EN: Prep: {name} {stars}★ · speed +{pct} · bugs ×{mult} / TR: Hazırlık: {name} {stars}★ · hız +{pct} · hata ×{mult}

| Belirteç | Taşıdığı |
|---|---|
| `{name}` | hazırlayan ürün yöneticisi |
| `{stars}` | kişinin gerçek yıldızı, tam sayı (kurucu tabanı yazılmaz) |
| `{pct}` | Fmt ile biçimlenmiş yüzde: TR %30, EN 30% |
| `{mult}` | hazırlığın hata çarpanı, Fmt ile |

_Not:_ PRD metni aynen (PRD'nin kendisi "hız +%30" ve "×0,6"yı gösteriyor). Bu çarpan hata ihtimali değildir, kart hata hakkında başka bir şey yazmaz.

## tip.rule
`PRODUCT_TIP_RULE*` · ui · Ürün · Sprint planı · kart ipucunun son satırı (atama kuralı); hazırlık ve kalır satırları ipucunda

- **text**: EN: The hardest job gets the best people; a small job gets whoever is good enough to finish it. / TR: En zor işe en iyi kişiler, küçük işe onu bitirmeye yeten kişi atanır.
- **body_variants[0] (atama kuralı (yapım ve test))**: EN: The hardest job gets the best people; a small job gets whoever is good enough to finish it. / TR: En zor işe en iyi kişiler, küçük işe onu bitirmeye yeten kişi atanır.
- **body_variants[1] (PM kuralı A, hazırlık satırının ipucunda)**: EN: The best product manager prepares the most complex card; a simple card goes to a product manager good enough to prepare it. / TR: En karmaşık kartı en iyi ürün yöneticisi, basit kartı onu hazırlamaya yeten ürün yöneticisi hazırlar.
- **body_variants[2] (kalır kuralı)**: EN: People stay on their card until their stage is done. / TR: Kişi, aşaması bitene kadar kartında kalır.

_Not:_ W2: PRD'nin "En büyük işe en iyi kişi atanır." cümlesi Erdem'in ilkesiyle değişti: zor işe en iyiler, basit işe yeten en zayıf. İlke Test'te de işler (açık 3), bu yüzden cümle aşama adı taşımaz. PM'in kuralı (kural A) ayrı cümlede, hazırlık satırının ipucunda. "Kalır" cümlesi kişi satırının ve kart ipucunun "neden Ece buraya gelmedi" sorusunu cevaplar.

## quality.words
`PRODUCT_QUALITY_CAREFUL / PRODUCT_QUALITY_HASTY` · ui · Ürün · kart ipucu ve Ekip · Atlas ile dosya: yapım kalitesi sözcüğü

- **text**: EN: Careful / TR: Özenli
- **body_variants[0] (yüksek kalite)**: EN: Careful / TR: Özenli
- **body_variants[1] (düşük kalite)**: EN: Hasty / TR: Aceleci

_Not:_ PRD metni aynen. Yıldız eşikleri onay bekliyor (#12); sayı yazılmaz.

## card.test
`PRODUCT_CARD_TEST` · ui · Ürün · Sprint planı · kart ipucu ve koşan kart: testi kim yapıyor

- **text**: EN: Test: {people} / TR: Test: {people}
- **body_variants[0] (kartı kendisi yazan kişinin girdisi)**: EN: {name} {stars}★ (wrote this card) / TR: {name} {stars}★ (kartı kendisi yazdı)

| Belirteç | Taşıdığı |
|---|---|
| `{people}` | kişi girdileri ({name} {stars}★), PRODUCT_LIST_* ile birleşmiş |

_Not:_ PRD metni aynen. Kendi kartını test eden kişinin girdisi listede ayrı biçimle yazılır, böylece birden çok testçide de doğru kişiye bağlanır; kurucu dahil. Testten önce kart hata hakkında hiçbir şey yazmaz.

## card.stage_short
`PRODUCT_STAGE_SHORT_*` · ui · Ürün · koşan kart ve kart zinciri: aşama kutuları

- **text**: EN: Des / TR: Tas
- **body_variants[0] (tasarım)**: EN: Des / TR: Tas
- **body_variants[1] (geliştirme)**: EN: Dev / TR: Gel
- **body_variants[2] (test)**: EN: Test / TR: Test
- **body_variants[3] (düzeltme)**: EN: Fix / TR: Düz
- **body_variants[4] (düzeltme, tam ad (PRODUCT_PHASE_* ailesi))**: EN: Fixing / TR: Düzeltme

_Not:_ EN kısaltmaları Design, Development, Test, Fixing'den. Düzeltme alt aşamasının tam adı da burada (sözlük satırı önerisi ayrıca).

## plan.phase_prep
`PRODUCT_PHASE_PREP` · ui · Ürün · Sprint planı · PM'in hazırlığının aşama adı (PRODUCT_PHASE_* ailesi): aşama özeti ("HAZIRLIK · 3 kişi") ve ipucu

- **text**: EN: Prep / TR: Hazırlık

_Not:_ W2, yeni (maketin zorunlu eklediği metin). Sözlükteki "Hazırlık / Prep" satırının anahtarı. Kişi satırındaki eşi PRODUCT_PERSON_WORD_PREP.

## card.chain
`PRODUCT_CHAIN_*` · ui · Ürün · Sprint planı · kart zinciri (kartın üstüne gelince): sütun başlıkları

- **text**: EN: Week {week} / TR: {week}. hafta
- **body_variants[0] (sprintin haftası)**: EN: Week {week} / TR: {week}. hafta
- **body_variants[1] (sprintin dışı)**: EN: Next sprint / TR: Sonraki sprint

| Belirteç | Taşıdığı |
|---|---|
| `{week}` | sprintin haftası, 1 ya da 2 |

_Not:_ Zincirin sütunları; "Hafta {n}" sözlükteki tam tarih biçimidir, burada sprintin haftası olduğu için sıra sayısı.

## card.test_result
`PRODUCT_TEST_*` · ui · Ürün · koşan kart: test bitince

- **text**: EN: Test: found {found} bugs, fixed {fixed}. / TR: Test: {found} hata buldu, {fixed} tanesi düzeltildi.
- **body_variants[0] (hata bulundu)**: EN: Test: found {found} bugs, fixed {fixed}. / TR: Test: {found} hata buldu, {fixed} tanesi düzeltildi.
- **body_variants[1] (found = 1)**: EN: Test: found {found} bug, fixed {fixed}. / TR: Test: {found} hata buldu, {fixed} tanesi düzeltildi.
- **body_variants[2] (hata bulunmadı)**: EN: Test: no bugs found. / TR: Test: hata bulunmadı.
- **body_variants[3] (düzeltme sürüyor)**: EN: Fixing: {left} bugs left. / TR: Düzeltiliyor: {left} hata kaldı.
- **body_variants[4] (left = 1)**: EN: Fixing: {left} bug left. / TR: Düzeltiliyor: {left} hata kaldı.

| Belirteç | Taşıdığı |
|---|---|
| `{found}` | testte bulunan hata |
| `{fixed}` | düzeltilen hata |
| `{left}` | düzeltilmeyi bekleyen hata |

_Not:_ PRD TR "2'si düzeltildi" sayının ardına ek koyuyordu ve ek sayıya göre değişir (2'si, 9'u, 6'sı); "{fixed} tanesi" her sayıyla doğru okunur. EN aynen.

## product.sprint_ship_known_bugs
`data/events/cards/product/sprint_ship_known_bugs.json` · paper · Olaylar · sprint kapanışı, karar kâğıdı biçiminde

**Başlık (TR):** Gönder sorusu · Bilinen hatalarla gönderilsin mi?
**Ne zaman:** Bağlı kip (varsayılan). Sprint kapanışında testi bitmiş ama düzeltmesi bitmemiş kart verilmiş bir söze ya da tarihi bu veya sonraki sprint olan bir hesap talebine bağlı. Sprint başına tek soru; bağlı kartlar tek tabloda. Kesinti sırasında sprint kâğıdının altında, istek kartının üstünde; önce bir kesinti geldiyse sorulmaz ve "bırak" uygulanır. Söz olayında "testi kısalt" ya da "fazla mesai" seçildiyse söz kartı sorulmadan gönderilir, "ek süre" ya da "söz kaçsın" seçildiyse bırakılır. Konuşan o kartın testini yapanlardan en çok hata bulan kişidir, rolü ne olursa olsun (T2 A, A4 [WORKING]; geliştirici kendi kartını test ettiyse soruyu o sorar); testi yalnız kurucu yaptıysa kurucunun notu. Gövdenin "testçi" kolları bu kişinin ağzıdır; D3b konuşanı `speaker_role`'den değil kartın Test aşamasındaki kişilerden seçer. Söze bağlı kart bırakılırsa söz bir sprint uzar, ikinci bırakışta kırılır (T1, A4 [WORKING]; PromiseRegistry.extend bugün böyle). "YALNIZ EŞİKLİ KİPTE" işaretli gövde ve çipler yalnız Erdem eşikli kipi ayar olarak tutarsa kullanılır (M2 sayfasındaki soru); eşikli kip kalkarsa silinir.
- **title**: EN: Ship with known bugs? / TR: Bilinen hatalarla gönderilsin mi?
- **body**: EN: {seam:urun.ship_card} still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. We promised this card to {customer}. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde bulduğum hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Kartı {customer} bekliyor; söz verdik. Bu hâliyle gönderelim mi, sonraki sprinte mi bırakalım?
- **sender**: EN: Ayşe · QA Engineer / TR: Ayşe · Test Mühendisi
- **sender_founder**: EN: Note to self / TR: Kendine not
- **body_variants[0] (testçi · tek kart · talep)**: EN: {seam:urun.ship_card} still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. {customer} asked for this card, and the deadline is close. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde bulduğum hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Kartı {customer} istemişti, son tarihi yakın. Bu hâliyle gönderelim mi, sonraki sprinte mi bırakalım?
- **body_variants[1] (kurucunun notu · tek kart · söz)**: EN: {seam:urun.ship_card}, promised to {customer}, still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde çıkan hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Kartı {customer} bekliyor; söz verdin. Bu hâliyle mi gönderirsin, sonraki sprinte mi bırakırsın?
- **body_variants[2] (kurucunun notu · tek kart · talep)**: EN: {seam:urun.ship_card} still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. {customer} asked for it, and the deadline is close. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde çıkan hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Kartı {customer} istemişti, son tarihi yakın. Bu hâliyle mi gönderirsin, sonraki sprinte mi bırakırsın?
- **body_variants[3] (testçi · birden çok kart (tablo))**: EN: {seam:urun.ship_count} cards tied to a promise or a request still have bugs from testing that aren't fixed. Ship them as they are, or leave them for the next sprint? / TR: Söze ya da talebe bağlı {seam:urun.ship_count} kartta testte bulduğumuz hatalar henüz düzeltilmedi. Hepsini bu hâliyle gönderelim mi, sonraki sprinte mi bırakalım?
- **body_variants[4] (kurucunun notu · birden çok kart (tablo))**: EN: {seam:urun.ship_count} cards tied to a promise or a request still have bugs from testing that aren't fixed. Ship them as they are, or leave them for the next sprint? / TR: Söze ya da talebe bağlı {seam:urun.ship_count} kartta testte çıkan hatalar henüz düzeltilmedi. Hepsini bu hâliyle mi gönderirsin, sonraki sprinte mi bırakırsın?
- **body_variants[5] (YALNIZ EŞİKLİ KİPTE · testçi · söze ya da talebe bağlı olmayan kart)**: EN: {seam:urun.ship_card} still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde bulduğum hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Bu hâliyle gönderelim mi, sonraki sprinte mi bırakalım?
- **body_variants[6] (YALNIZ EŞİKLİ KİPTE · kurucunun notu · söze ya da talebe bağlı olmayan kart)**: EN: {seam:urun.ship_card} still has known bugs from testing: {seam:urun.ship_bugs} not fixed yet. Ship it as it is, or leave it for the next sprint? / TR: {seam:urun.ship_card} kartının testinde çıkan hatalardan {seam:urun.ship_bugs} tanesi henüz düzeltilmedi. Bu hâliyle mi gönderirsin, sonraki sprinte mi bırakırsın?
- **option ship label**: EN: Ship / TR: Gönder
- **option ship chip[0]**: EN: Promise kept this sprint: {customer} / TR: Söz bu sprintte tutulur: {customer}
- **option ship chip[1]**: EN: Request met on time: {customer} / TR: Talep zamanında karşılanır: {customer}
- **option ship chip[2]**: EN: {seam:urun.ship_bugs} open bugs are added to {seam:urun.ship_line} / TR: {seam:urun.ship_line} hattına {seam:urun.ship_bugs} açık hata yazılır
- **option ship chip[3]**: EN: Promises and requests kept this sprint: {seam:urun.ship_count} cards / TR: Söz ve talepler bu sprintte tutulur: {seam:urun.ship_count} kart
- **option ship chip[4]**: EN: {seam:urun.ship_bugs} open bugs are added to the product / TR: Ürüne {seam:urun.ship_bugs} açık hata yazılır
- **option ship chip[5]**: EN: {seam:urun.ship_card} counts as delivered this sprint / TR: {seam:urun.ship_card} bu sprintte teslim sayılır
- **option leave label**: EN: Leave for next sprint / TR: Sonraki sprinte bırak
- **option leave chip[0]**: EN: {seam:urun.ship_card} finishes next sprint after {seam:urun.ship_fix_points} points of fixing / TR: {seam:urun.ship_card} sonraki sprintte {seam:urun.ship_fix_points} puanlık düzeltmeyle biter
- **option leave chip[1]**: EN: Promise moves one sprint later: {customer} / TR: Söz bir sprint uzar: {customer}
- **option leave chip[2]**: EN: Promise broken: {customer} / TR: Söz kırılır: {customer}
- **option leave chip[3]**: EN: Promise kept next sprint: {customer} / TR: Söz sonraki sprintte tutulur: {customer}
- **option leave chip[4]**: EN: Request one sprint late: {customer} / TR: Talep bir sprint gecikir: {customer}
- **option leave chip[5]**: EN: {seam:urun.ship_count} cards finish next sprint after {seam:urun.ship_fix_points} points of fixing / TR: {seam:urun.ship_count} kart sonraki sprintte {seam:urun.ship_fix_points} puanlık düzeltmeyle biter
- **expire**: EN: Nobody decided, so the card waits for the next sprint. / TR: Karar verilmedi, kart sonraki sprinte kaldı.
- **seçenek [ship]** · ne yapar: Kart teslim sayılır (kademe ve alan puanı şimdi); bilinen hata kartın hattına açık hata olur (ProductState.add_bugs), C'nin memnuniyet satırına ve B'nin sürüm sonrası bozulmasına bu sürümün hatası olarak girer. Söz ya da talep bu sprintte tutulur. · en iyi: Hesap kartı bu sprint bekliyor, kalan hata az; sözün kaçması açık hatadan pahalı.
- **seçenek [leave]** · ne yapar: Vurgulu ve varsayılan. Kart sonraki planın 3. basamağına kalan düzeltmeyle girer; işi düzeltme payına girmez. Söze bağlıysa söz bir sprint uzar, ikinci bırakışta kırılır (T1); talepse bir sprint gecikir. · en iyi: Sözün tarihi sonraki sprint, söz henüz hiç uzamadı ya da kalan hata çok; hesabın memnuniyeti açık hatadan daha çok etkilenir.

| Belirteç | Taşıdığı |
|---|---|
| `{seam:urun.ship_card}` | bağlı kartın adı |
| `{seam:urun.ship_bugs}` | kartta (tabloda: bütün kartlarda) kalan bilinen hata |
| `{seam:urun.ship_line}` | kartın hattının adı |
| `{seam:urun.ship_fix_points}` | kalan düzeltme işi, puan |
| `{seam:urun.ship_count}` | tablodaki bağlı kart sayısı |
| `{customer}` | sözün ya da talebin sahibi hesap |

**Onay bekleyen:** SHIP_QUESTION_MODE = bağlı; INTERRUPT_ORDER = acil durum > söz olayı > yenileme kâğıdı > sprint kâğıdı > gönder sorusu > istek kartı

_Not:_ PRD TR "Ege Sigorta'ya söz verdiğimiz Toplu fatura'da 2 bilinen hata kaldı" iki yer tutucunun ardına ek koyuyordu ('ya, 'da). Yeni TR ekleri yer tutucudan ayırır: "{kart} kartının", "Kartı {customer} bekliyor; söz verdik". PRD çipi "Ege Sigorta'ya verilen söz bu sprintte tutulur" da öyle: "Söz bu sprintte tutulur: {customer}" (mevcut "Söz: {customer}" kalıbıyla aynı). Çipler Faz B'deki gibi noktasız. "Bu haliyle" TDK yazımıyla "bu hâliyle" oldu (CSV'de "hâl" 27 kez, "haliyle" hiç yok). EN gövde PRD'nin cümlesini konuşanın ağzına taşır; "{n} not fixed yet" 1 ve çok hatada aynı doğru okunur, tekil anahtar gerekmez. Düğmeler PRD'den aynen; "Gönder" Erdem'in fiilidir ("Şu haliyle gönderelim mi"), sözlükteki "Yayınla ↔ Ship" yapım düğmesidir, ayrı satır önerildi. Kurucunun notu Faz B kalıbıyla ("Kendine not", ikinci tekil). Başlık iki konuşanda ve tek ya da çok kartta aynı okunsun diye edilgen. Tablonun satırı ayrı öğede (ship.table_row). W2: T1 ve T2 A4'ün kararlarıyla [WORKING] (M2 sayfasında Erdem'e soruluyor). Bırak çipi "Söz bu sprintte tutulmaz" kalktı: söz ilk bırakışta bir sprint uzar ("Söz bir sprint uzar"), ikincide kırılır ("Söz kırılır"). Eşikli kip için iki gövde ve bir çip eklendi, "YALNIZ EŞİKLİ KİPTE" işaretli.

## ship.table_row
`PRODUCT_SHIP_ROW` · ui · Olaylar · gönder sorusu · birden çok bağlı kartın tablosu, satır başına

- **text**: EN: {card} · {bond} · {n} known bugs / TR: {card} · {bond} · {n} bilinen hata
- **body_variants[0] (n = 1)**: EN: {card} · {bond} · {n} known bug / TR: {card} · {bond} · {n} bilinen hata

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{bond}` | mevcut PRODUCT_FX_PROMISE ("Söz: {customer}") ya da PRODUCT_FX_REQUEST ("{customer} talebi") |
| `{n}` | kartta kalan bilinen hata |

_Not:_ PRD'de metni yok; tablonun satırı.

## note.test
`PRODUCT_NOTE_TEST*` · note · Ürün · sürüm notu · testin özeti

- **text**: EN: Testing found {found} bugs this sprint: {fixed} fixed, {known} not fixed yet. / TR: Test bu sprintte {found} hata buldu: {fixed} tanesi düzeltildi, {known} tanesi bilinen hata olarak kaldı.
- **body_variants[0] (kalan var)**: EN: Testing found {found} bugs this sprint: {fixed} fixed, {known} not fixed yet. / TR: Test bu sprintte {found} hata buldu: {fixed} tanesi düzeltildi, {known} tanesi bilinen hata olarak kaldı.
- **body_variants[1] (hepsi düzeltildi)**: EN: Testing found {found} bugs this sprint, and all of them were fixed. / TR: Test bu sprintte {found} hata buldu, hepsi düzeltildi.
- **body_variants[2] (found = 1, düzeltildi)**: EN: Testing found {found} bug this sprint, and it was fixed. / TR: Test bu sprintte {found} hata buldu, o da düzeltildi.
- **body_variants[3] (hata yok)**: EN: Testing found no bugs this sprint. / TR: Test bu sprintte hata bulmadı.

| Belirteç | Taşıdığı |
|---|---|
| `{found}` | sprintte testte bulunan hata |
| `{fixed}` | düzeltilen |
| `{known}` | bilinen hata olarak kalan |

_Not:_ PRD TR "testçiler 11 hata buldu. 9'u düzeltildi, 2'si...": testi kurucu ya da geliştirici de yapabildiği için "testçiler" yerine "Test" özne oldu (kart satırı "Test: 3 hata buldu" ile aynı); sayının ardındaki ek (9'u, 2'si) "tanesi" ile kalktı. EN "remain known" eksik kalıyordu ve "9 were fixed" 1 sayısında bozuluyordu; iki nokta ile liste her sayıda doğru okunur. Hata bulunmayan ve hepsi düzeltilen hâller eklendi. W2: Karar 24'ün hata modeliyle sayılar değişir, metin değişmedi (§3.4).

## note.left_in_fix
`PRODUCT_NOTE_LEFT_IN_FIX` · note · Ürün · sürüm notu · sessiz "bırak" (bağlı olmayan kart ya da sıraya giremeyen soru)

- **text**: EN: {card} stayed in fixing: {known} known bugs, finishes next sprint. / TR: {card} düzeltmede kaldı: {known} bilinen hata, sonraki sprintte biter.
- **body_variants[0] (known = 1)**: EN: {card} stayed in fixing: {known} known bug, finishes next sprint. / TR: {card} düzeltmede kaldı: {known} bilinen hata, sonraki sprintte biter.

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{known}` | kartta kalan bilinen hata |

_Not:_ PRD metni aynen. W2: Karar 24'ün hata modeliyle sayılar değişir, metin değişmedi (§3.4).

## note.pulled
`PRODUCT_NOTE_PULLED*` · note · Ürün · sürüm notu · sprint içinde çekilen kart

- **text**: EN: The team also picked up {card} in week {week}. / TR: Ekip {week}. haftada bir kart daha çekti: {card}.
- **body_variants[0] (tek kart)**: EN: The team also picked up {card} in week {week}. / TR: Ekip {week}. haftada bir kart daha çekti: {card}.
- **body_variants[1] (birden çok kart)**: EN: The team also picked up {count} more cards during the sprint: {cards}. / TR: Ekip sprint içinde {count} kart daha çekti: {cards}.

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da PROD_DEPTH_*) |
| `{week}` | sprintin haftası, 1 ya da 2 |
| `{cards}` | çekilen kartlar, PRODUCT_LIST_* ile |
| `{count}` | çekilen kart sayısı |

_Not:_ PRD TR "Stok uyarısı'nı da çekti" kart adının ardına ek koyuyordu ('nı); kart adı iki noktanın arkasına geçti. EN aynen. Birden çok kart için ikinci anahtar. W2: Karar 24'ün hata modeliyle sayılar değişir, metin değişmedi (§3.4).

## note.prep_gain
`PRODUCT_NOTE_PREP_GAIN` · note · Ürün · sürüm notu · PM hazırlığının kazancı

- **text**: EN: Cards came prepared: the same work took {pts} fewer points. / TR: Kartlar hazır geldi: aynı iş {pts} puan az tuttu.
- **body_variants[0] (pts = 1)**: EN: Cards came prepared: the same work took {pts} fewer point. / TR: Kartlar hazır geldi: aynı iş {pts} puan az tuttu.

| Belirteç | Taşıdığı |
|---|---|
| `{pts}` | hazırlığın sprintte kazandırdığı puan, aşağı yuvarlanır |

_Not:_ PRD metni aynen. W2: Karar 24'ün hata modeliyle sayılar değişir, metin değişmedi (§3.4).

## note.shipped_known
`PRODUCT_NOTE_SHIPPED_KNOWN*` · note · Ürün · sürüm notu · bağlı kart bilinen hatayla gönderilince ("Gönder" seçilince ya da söz olayında "testi kısalt" / "fazla mesai" ile sorulmadan)

- **text**: EN: {card} shipped with {n} known bugs. / TR: {card} bilinen {n} hatayla çıktı.
- **body_variants[0] (tek kart)**: EN: {card} shipped with {n} known bugs. / TR: {card} bilinen {n} hatayla çıktı.
- **body_variants[1] (tek kart, n = 1)**: EN: {card} shipped with {n} known bug. / TR: {card} bilinen {n} hatayla çıktı.
- **body_variants[2] (birden çok kart)**: EN: {count} cards shipped with {n} known bugs: {cards}. / TR: {count} kart bilinen {n} hatayla çıktı: {cards}.

| Belirteç | Taşıdığı |
|---|---|
| `{card}` | kartın adı (PROD_STEP_* ya da düzeltme kartının adı) |
| `{n}` | kartla çıkan bilinen hata (kartın hattına açık hata olarak yazılır) |
| `{cards}` | bilinen hatayla çıkan kartlar, PRODUCT_LIST_* ile |
| `{count}` | bilinen hatayla çıkan kart sayısı |

_Not:_ W2: Erdem'in tonu aynen ("{kart} bilinen {n} hatayla çıktı"): kart bilerek yayınlandı, sürümü durduran bir hata değil. Eski öneri cümlesindeki hat ve açık hata parçası kalktı; hattın açık hatası zaten ürün sayfasında. Birden çok kart gönderildiyse tek satır (PRODUCT_NOTE_SHIPPED_KNOWN_MANY), {n} hepsinin toplamı.

## hr.stage_speed
`HR_ATLAS_STAGE_SPEED` · hr · Ekip · Atlas ve dosya · kişinin aşama başına haftalık hızı (bugünkü tek sayının yerine)

- **text**: EN: {stage} {pts}/wk / TR: {stage} {pts}/hf
- **body_variants[0] (ürün yöneticisi)**: EN: Prep {pts}/wk / TR: Hazırlık {pts}/hf

| Belirteç | Taşıdığı |
|---|---|
| `{stage}` | aşamanın adı, cümle düzeninde |
| `{pts}` | o aşamadaki haftalık hız, tam sayı |

_Not:_ PRD: "Geliştirme 12/hf · Test 8/hf" aynen, parça başına (ayraç " · "). PM'in sprint puanı yok; hazırlık hızı ayrı satır. Bugünkü HR_ATLAS_WEEK_POINTS ("Sprintte haftada {pts} puan") bunun yerine geçer ve silinir. W2: D5: Atlas aşama hızları bu satırla; kurucu dosyası gerçek yıldızları gösterir, 2★ tabanı yazılmaz. Metin değişmedi.

## hr.unfit_box
`HR_TASK_UNFIT_TEST` · hr · Ekip · Görevler matrisi · uymayan kutu

- **text**: EN: Testing at ×{mult} speed; −{n} morale at sprint end for each week of testing / TR: Testte ×{mult} hız; test yaptığı her hafta için sprint sonunda −{n} moral
- **body_variants[0] (ikincil uyum)**: EN: ×{mult} speed / TR: ×{mult} hız

| Belirteç | Taşıdığı |
|---|---|
| `{mult}` | Fmt ile biçimlenmiş çarpan, × işareti metinde: TR 0,4, EN 0.4 |
| `{n}` | uymayan işte çalışılan hafta başına moral kaybı (bugün 2) |

_Not:_ PRD: "sprint sonunda 2 moral" / "2 morale at sprint end" yönü söylemiyor; "−2" (U+2212) kayıp olduğunu gösterir. İkincil uyumdaki kutu için (×0,7, moral yok) ikinci anahtar. W2: D5'in özeti "Testte ×0,4 hız; sprint sonunda 2 moral" diyor; ama PRD Karar 2'de kayıp uymayan işte çalışılan her hafta için (2 haftalık sprintte en çok −4). Kutu sprintten önce okunduğu için "her hafta için" eklendi; plan ekranındaki PRODUCT_UNFIT_TEST o sprintin toplamını yazar.

## support.neglect_tip
`BUILD_SUPPORT_NEGLECT_TIP` · ui · BuildBar · DESTEK kartının ipucu, BUILD_SUPPORT_TIP'in altında: itibarı düşüren açık hata eşiği

- **text**: EN: If open bugs stay at {limit} or more, reputation drops by 1 each week from week {weeks} on. / TR: Açık hata {limit} ve üstünde kalırsa {weeks}. haftadan başlayarak itibar her hafta 1 düşer.

| Belirteç | Taşıdığı |
|---|---|
| `{limit}` | k × NEGLECT_BUGS, tam sayı (k = en büyüğü(1; canlı hat ÷ 9; √(son 8 haftanın haftalık teslimi ÷ 55)); 1 kişide 30, 50 kişide yaklaşık 95) |
| `{weeks}` | NEGLECT_WEEKS (bugün 4): eşikte geçen kaçıncı haftada itibar düşmeye başlar |

_Not:_ W2, yeni. Bugün NEGLECT_BUGS'u okuyan arayüz yok; oyuncu itibar düşüşünü yalnız sonradan TopBar'da görüyordu (REP_DROP_BUGS). Formül yazılmaz, yalnız eşiğin sayısı. Karşılaştırılan sayı ProductState.costed(open_bugs()) ile aynı olmalı. {weeks} sabit ve 2'den büyük olduğu için tekil yok.

## hr.onb_skill_qa
`ONB_SKILL_QA_DESC` · hr · Açılış · kurucu becerileri · Test'in açıklaması

- **text**: EN: Test-star tiers; how fast testing runs and how many bugs it catches. You catch fewer bugs on cards you wrote yourself. / TR: Test yıldızı isteyen kademeler; testin hızı ve yakaladığı hata. Kendi yazdığın kartta daha az hata yakalarsın.
- **current**: EN: Test-star tiers, and how fast the test phase of sprint cards runs. / TR: Test yıldızı isteyen kademeler ve sprint kartlarının test aşamasının hızı.

_Not:_ Kurucu da kendi kartında ×0,6 bulur; açılışta söylenmezse tek kurucunun canlıda çıkan hatası açıklamasız kalır. "Test yıldızı isteyen kademeler" D'nin değiştirmediği kısımdır; Q kademe yıldız kapılarını kaldırırsa o kısım da düşer.

## gl.duzeltme
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: Fixing / TR: Düzeltme

_Not:_ İstenen satır. Düzeltme *(aşama)* ↔ Fixing; kısa Düz ↔ Fix. Testte bulunan hatanın aynı kartın içinde düzeltildiği alt aşama; Geliştirme satırında sayılır, geliştirme kuralıyla atanır (PRODUCT_PHASE_FIX, PRODUCT_STAGE_SHORT_FIX). Canlı hatanın düzeltme kartından ("{capability} düzeltmesi ↔ {capability} fix", PRODUCT_FIX_CARD) ayrıdır; cümlede ayrım gerekiyorsa kart "düzeltme kartı ↔ fix card" diye yazılır. TR/EN onay bekliyor.

## gl.known_bug
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: known bug / TR: bilinen hata

_Not:_ Testte bulunmuş, henüz düzeltilmemiş hata (kart içinde). Kart gönderilince hattında "açık hata ↔ open bug" olur. TR/EN onay bekliyor.

## gl.quality
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: Careful / Hasty / TR: Özenli / Aceleci

_Not:_ Yapım kalitesinin iki sözcüğü, sayısız (PRODUCT_QUALITY_*). TR/EN onay bekliyor.

## gl.prep
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: Prep / Prepared by / TR: Hazırlık / hazırladı

_Not:_ PM'in önden hazırlığı (PRODUCT_CARD_PREP, PRODUCT_TIP_PREP, HR_ATLAS_PREP_SPEED). TR/EN onay bekliyor.

## gl.speed
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: speed / TR: hız *(kişi, kart)*

_Not:_ Kişinin aşama hızı ve hazırlığın kazancı ("hız +%30 ↔ speed +30%", "×0,4 hızla ↔ at ×0.4 speed"). Sözlükteki "hız *(sprint)* ↔ velocity" ekibin sprint hızıdır ve "Hız ↔ Pace" kişi eksenidir; üçü ayrı. TR/EN onay bekliyor.

## gl.up_next
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: Up next / pick up / TR: Sırada / çekmek

_Not:_ Sprint içinde çekilen kart: "Sırada: {card}" ↔ "Up next: {card}", "Ekip ... çeker ↔ The team picks it up". Kart damgası PRODUCT_QUEUED ("Sırada ↔ Queued") ayrı anahtar kalır. TR/EN onay bekliyor.

## gl.idle
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: idle / TR: boşta

_Not:_ Plan ve özet satırlarında. Mevcut PRODUCT_IDLE ile aynı. TR/EN onay bekliyor.

## gl.ship
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: Ship / Leave for next sprint / TR: Gönder / Sonraki sprinte bırak

_Not:_ Sprint sonu gönder sorusu. "Gönder" Erdem'in fiilidir; sözlükteki "Yayınla → ↔ Ship →" yapım düğmesidir, ikisi ayrı anahtar. TR/EN onay bekliyor.

## gl.delegate
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: delegate planning / TR: planlamayı devret

_Not:_ EN her yerde "delegate" (mevcut PRODUCT_DELEGATE düğmesiyle aynı); "hand over" kullanılmaz. TR/EN onay bekliyor.

## gl.per_week
`docs/design/localization_glossary.md §3` · glossary · Sözlük, Build & ürün tablosu

- **text**: EN: /wk / TR: /hf

_Not:_ Haftalık hızın kısaltması ("Geliştirme 12/hf ↔ Development 12/wk"). TR/EN onay bekliyor.

## Ertelendi (kart yenilemesi)

D8c (derinlik kartı) ve D8d (hesap isteği kartı) kart yenilemesine kaldı (ADIM_TABLOSU_D_v2 §0 ve §3): arz Pazar 2'de modül, kademe ve dönem üzerinden yeniden kuruluyor; C6'nın istek akışı da yeniden yazılıyor. Metinler atılmadı, burada saklanıyor; wavecheck ve maket bu bölümü okumaz. Kart yenilemesinde Erdem'in Karar 25'i (istek kartının adı istek kâğıdının konusundan) ve U7 ("talebi zamanında" parçası kalkar) bu metinlere uygulanır.

- `card.depth_gain` · `PRODUCT_DEPTH_GAIN*`
- `card.request_title` · `PRODUCT_REQUEST_TITLE`
- `card.depth_title` · `PROD_DEPTH_<LINE>_<n>`
- `gl.square` · `docs/design/localization_glossary.md §3`
- `name.line_erp_cashflow` · `PROD_DEPTH_ERP_CASHFLOW_<n>`
- `name.line_erp_intake` · `PROD_DEPTH_ERP_INTAKE_<n>`
- `name.line_erp_ledger` · `PROD_DEPTH_ERP_LEDGER_<n>`
- `name.line_erp_stock` · `PROD_DEPTH_ERP_STOCK_<n>`
- `name.line_erp_invoicing` · `PROD_DEPTH_ERP_INVOICING_<n>`
- `name.line_shared_integrations` · `PROD_DEPTH_SHARED_INTEGRATIONS_<n>`
- `name.line_shared_security` · `PROD_DEPTH_SHARED_SECURITY_<n>`
- `name.line_shared_durability` · `PROD_DEPTH_SHARED_DURABILITY_<n>`
- `name.line_shared_mobile` · `PROD_DEPTH_SHARED_MOBILE_<n>`
- `name.line_note_tool_capture` · `PROD_DEPTH_NOTE_TOOL_CAPTURE_<n>`
- `name.line_note_tool_linking` · `PROD_DEPTH_NOTE_TOOL_LINKING_<n>`
- `name.line_note_tool_sync` · `PROD_DEPTH_NOTE_TOOL_SYNC_<n>`
- `name.line_note_tool_editor` · `PROD_DEPTH_NOTE_TOOL_EDITOR_<n>`
- `name.line_note_tool_search` · `PROD_DEPTH_NOTE_TOOL_SEARCH_<n>`
- `name.line_video_clip_clipping` · `PROD_DEPTH_VIDEO_CLIP_CLIPPING_<n>`
- `name.line_video_clip_captions` · `PROD_DEPTH_VIDEO_CLIP_CAPTIONS_<n>`
- `name.line_video_clip_pipeline` · `PROD_DEPTH_VIDEO_CLIP_PIPELINE_<n>`
- `name.line_video_clip_timeline` · `PROD_DEPTH_VIDEO_CLIP_TIMELINE_<n>`
- `name.line_video_clip_framing` · `PROD_DEPTH_VIDEO_CLIP_FRAMING_<n>`
