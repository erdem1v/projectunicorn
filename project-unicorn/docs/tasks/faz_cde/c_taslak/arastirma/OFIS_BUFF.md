searches: 25, fetches: 15 (3'ü 402 ile boş döndü: Fandom'un Software Inc., Game Dev Tycoon ve Motorsport Manager sayfaları)

# OFIS_BUFF · Ofis ve bina yükseltmesi oyuncuya ne veriyor (C9b'yi besler)

Tarih: 2026-10-20. Karar Erdem'in; bu belge seçmez, önerir. Oyun dosyalarına dokunulmadı; kod HEAD'den okundu.
Bütçe uyarısı: fetch bütçesi bitti. Software Inc.'in oda sayfaları (softwareinc.coredumping.com wiki) ve Game Dev Tycoon wiki'si hiç açılamadı; bu yüzden oyun içi SAYILAR zayıf (Bölüm 9).

## 0. Özet (8 satır)

1. Emsallerde ofis/bina yükseltmesinin en sık verdiği şey KAPASİTE (koltuk) ve KİLİT (yeni eğitim, reklam, işe alım yolu), "verim buff'ı" ikinci sırada. Game Dev Story: her yükseltme +2 koltuk ve yeni eğitim/reklam/işe alım yöntemi [S12]; Startup Company: 8, 20, 50 iş istasyonlu binalar [S6]; Game Dev Tycoon: daha çok çalışan, daha büyük bordro [S11].
2. Verim/moral gibi buff'ın asıl yaşadığı yer bina kademesi değil ODA ve DEKOR: Software Inc.'te oda ortamı (gürültü, kalabalık) verimi etkiler [S1]; Startup Company'de dekor ve yan haklar işçi hızını artırır [S6]; Two Point Campus'ta oda prestiji mutluluğu ve sağlığı artırır [S21]; Football Manager'da tesis seviyesi gelişim hızını artırır [S17].
3. Kademe başına verim yüzdesi veren tek bir kaynak bulunamadı. Sayı olarak yalnız Software Inc. oyuncularının "oda başına yaklaşık 10 kişiden sonra verim düşer" beyanı var [S1] (alpha dönemi, Düşük güven).
4. Oyuncunun kızdığı yer buff yokluğu değil, geçişin MALİYET UÇURUMU ve ANGARASI: Game Dev Tycoon'da taşınınca aylık 32 bin ile 70 bin dolar gider kasayı batırıyor [S28][S29]; Startup Company'de binayı değiştirince mobilya silinip yeniden kurulmak zorunda [S6]. "Ofis yalnız kozmetik" biçiminde doğrudan şikâyet bulunamadı.
5. Uzaktan çalışma cezası olan bir yönetim oyunu bulunamadı. Ekip büyüklüğü/kalabalık cezası olanlar var: Software Inc. (önerilen takım boyutu, aynı odada çok takım) [S3][S1], Game Dev Tycoon (yeni eleman geçici verim düşürür) [S9].
6. Gerçek dünya "ofis verimi artırır" demiyor: evde çalışma Ctrip'te +%13 performans [S25]; haftada 2 gün evden çalışma verimi değiştirmedi, işten ayrılmayı %33 azalttı [S26]. [GÖRÜŞ] Oyun için "verim" buff'ı oyun mantığıdır (emsallerle uyumlu), gerçek veri değil; gerçek veriye daha yakın ad "mesai daha az yorar / ekip daha çok kalır".
7. Kodda "ekip büyüdükçe koordinasyon kaybı" bugün YOK: `hr_constants.gd:1030` "Bugün okuyucusu yok: sprint motoru koordinasyon çarpanı uygulamaz". Faz D planında var ama yalnız aynı kartta kalabalığa bağlı, takım nesnesi EA'da (`D_MODEL_v3.md` §3.5). Erdem'in "zaten var" varsayımı kodda doğrulanmadı.
8. [GÖRÜŞ] Öneri: ofis kademesi başına TEK sayı ("düzen çarpanı" k), var olan iki tabloyu ölçekler (gün içi verim düşüşü ve moral aşınması), Faz D gelince kalabalık kaybına da bağlanır; Frank'in "ofis tutalım" yazısı bu sayıyı adıyla söyler. Ayrıntı Bölüm 7.

## 1. Bugün oyunda (3-5 satır, koddan)

- Ofis kademeleri `office_constants.gd:15-64` (HEAD): ev, İş hanı, Plaza, Loft; masa, oda listesi, şartlar. HEAD'de masa 1/10/36/64 ([WORKING]); görev metnindeki 1/12/38/70 HEAD ile uyuşmuyor [DOĞRULAMA TURU: kira/masa türetmeleri aşağıda HEAD'e göre 400/222/281, sıralama (Plaza en ucuz) değişmedi]; HEAD şartları: İş hanı melek çeki + $6.500, Plaza 12 kişi + $45.000 + marka 40, Loft 35 kişi + $110.000 + marka 70 (Erdem'in "yalnız paraya bağlı" kararıyla marka şartı çelişebilir). Görev metnine göre kira $4.000/$8.000/$18.000 (kod HEAD'de kira alanı yok; kira C9'da girecek, `C0_HARITA.md:164`). Kira masa başına: 4.000/12 = $333, 8.000/38 = $211, 18.000/70 = $257 (türetilmiş); Plaza masa başına en ucuz.
- Ofisin bugün hiçbir verim/moral/itibar etkisi yok; kademe yalnız masa ve görünüm (HEAD'de `OfficeSystem` okuyanlar: `time_manager.gd:409`, `seams_world.gd:139`).
- Koordinasyon: `COORD_MIN 0.85 … COORD_MAX 1.20` Liderlik'e bağlı, `hr_constants.gd:1011-1047`; okuyucusu yok (satır 1030). Ekip büyüklüğü cezası kodda yok.
- Var olan kollar: gün içi verim `DECAY_PER_HOUR 0.02` (`hr_constants.gd:772`), moral bandı `MORALE_PACE_STEPS` (`:855`), moral aşınması `MORALE_BASE_DRIFT_PER_DAY 0.25` (`:878`), `GameState.brand` 0-100 (alan `game_state.gd:33`, yazan `set_brand` `:349`) ve `GameState.reputation`. Aday havuzu kalitesi için kol bulunamadı (`hr_search_system.gd`'de pool/quality/reputation eşleşmesi yok).
- Erdem'in 2026-10-20 kararı: evde sınır yok, ofis yalnız paraya bağlı, seed sonrası Frank "ofis tutmalıyız" der (`ERDEM_KARARLAR_2026-10-20.md:36`).

## 2. Kaynak sicili

Güven: Yüksek = resmi sayfa/duyuru/hakemli makale/çalışma kâğıdı; Orta = fan wiki, basın, fan rehberi; Düşük = tek oyuncu beyanı, forum. "özet" = yalnız arama özetini gördüm, sayfa açılmadı.

| S# | URL | Yayıncı | Yayın tarihi | Erişim | Güven |
|---|---|---|---|---|---|
| S1 | https://steamcommunity.com/app/362620/discussions/0/1837937637903404603 | Steam forumu, Software Inc. (açıldı) | 2019-03-13..21 | 2026-10-20 | Düşük |
| S2 | https://steamcommunity.com/app/362620/discussions/0/4205868123785820338 | Steam forumu, Software Inc. (açıldı) | 2024-02-07 | 2026-10-20 | Düşük |
| S3 | https://steamcommunity.com/app/362620/discussions/0/133259227517675456 (ikinci aday: .../365163686064884721) | Steam forumu, Software Inc. (özet) | 2016 (özet) | 2026-10-20 | Düşük |
| S4 | https://steamcommunity.com/app/1342330/discussions/0/3058492406517208479 | Steam forumu, Mad Games Tycoon 2 (açıldı) | bulunamadı | 2026-10-20 | Düşük |
| S5 | https://steamcommunity.com/app/1342330/discussions/0/4737210531938532878 | Steam forumu, Mad Games Tycoon 2 (açıldı) | 2021-08-15..10-20 | 2026-10-20 | Düşük |
| S6 | https://www.keengamer.com/articles/previews/startup-company-preview/ | KeenGamer (açıldı) | 2017-08-16 (beta dönemi) | 2026-10-20 | Orta |
| S7 | https://store.steampowered.com/app/606800/Startup_Company | Steam mağaza, Hovgaard Games (açıldı) | güncel sayfa | 2026-10-20 | Yüksek |
| S8 | https://steamcommunity.com/app/606800/discussions/0/1639787494964853945 | Steam forumu, Startup Company; geliştirici yanıtı var (açıldı) | 2019-06-09..14 | 2026-10-20 | Orta |
| S9 | https://steamcommunity.com/app/239820/discussions/0/648814845135478267 | Steam forumu, Game Dev Tycoon (açıldı) | 2014-01-04 | 2026-10-20 | Düşük |
| S10 | https://steamcommunity.com/app/239820/discussions/0/1746772719862516103 | Steam forumu, Game Dev Tycoon; Greenheart Games yanıtı (özet, AÇILMADI) | 2020 (özet) | 2026-10-20 | Orta (açılmadığı için zayıf) |
| S11 | https://www.softpedia.com/reviews/games/pc/Game-Dev-Tycoon-Review-355267.shtml | Softpedia (özet) | bulunamadı | 2026-10-20 | Orta |
| S12 | https://kairosoft.wiki.gg/wiki/Game_Dev_Story | Kairosoft wiki, topluluk (açıldı) | bulunamadı | 2026-10-20 | Orta |
| S13 | https://kairosoft.wiki.gg/wiki/Employees_(Game_Dev_Story) | Kairosoft wiki (özet) | bulunamadı | 2026-10-20 | Orta |
| S14 | https://steamcommunity.com/app/1331550/discussions/0/3825284575375157695 ve .../3825284575376127483 | Steam forumu, Big Ambitions (özet; hangisi hangi cümleyi söylüyor belirsiz) | 2023 (özet) | 2026-10-20 | Düşük |
| S15 | https://motorsportmanagerpc.fandom.com/wiki/Headquarters | Motorsport Manager PC Wiki, topluluk (özet; fetch 402) | bulunamadı | 2026-10-20 | Orta |
| S16 | https://steamcommunity.com/app/415200/discussions/0/133261370016016639 | Steam forumu, Motorsport Manager (özet; birkaç başlıktan biri, hangisi belirsiz) | 2017 ve sonrası (özet) | 2026-10-20 | Düşük |
| S17 | https://www.passion4fm.com/?p=1547 | Passion4FM, fan rehberi (özet) | bulunamadı | 2026-10-20 | Orta |
| S18 | https://www.passion4fm.com/youth-intake-guide-how-clubs-produce-newgens/ | Passion4FM (özet) | bulunamadı | 2026-10-20 | Orta |
| S19 | https://www.passion4fm.com/football-manager-youth-development-guide/ | Passion4FM (özet; "FM24 rehberi" bu mu belirsiz) | bulunamadı | 2026-10-20 | Orta |
| S20 | https://whatculture.com/gaming/football-manager-2014-tips-10-ways-guarantee-world-domination?page=9 | WhatCulture (özet; "FM14 rehberi" bu olabilir) | 2013-2014 | 2026-10-20 | Düşük |
| S21 | https://www.pcgamesn.com/two-point-campus/attractiveness | PCGamesN (özet) | bulunamadı (2022) | 2026-10-20 | Orta |
| S22 | https://www.gamesradar.com/two-point-campus-level | GamesRadar (özet) | bulunamadı (2022) | 2026-10-20 | Orta |
| S23 | https://en.wikipedia.org/wiki/Two_Point_Hospital | Wikipedia (özet) | güncel sayfa | 2026-10-20 | Orta |
| S24 | https://ladiesgamers.com/startup-company-console-edition-review/ | LadiesGamers (özet) | bulunamadı | 2026-10-20 | Düşük |
| S25 | https://www.nber.org/papers/w18871 | NBER, Bloom, Liang, Roberts, Ying (açıldı) | 2013-03 | 2026-10-20 | Yüksek |
| S26 | https://www.sciencedaily.com/releases/2024/06/240612113235.htm | ScienceDaily, Nature 2024 (DOI 10.1038/s41586-024-07500-2) haberi (açıldı; makale açılmadı) | 2024-06-12 | 2026-10-20 | Orta |
| S27 | https://www.microsoft.com/en-us/research/uploads/prod/2019/02/johnson-tse-2019.pdf | Microsoft Research, Johnson ve Tse (özet) | 2019 | 2026-10-20 | Orta |
| S28 | https://steamcommunity.com/app/239820/discussions/0/2949168687319084666 | Steam forumu, Game Dev Tycoon (A3 [63]'ten devralındı, yeniden açılmadı) | 2018-03-18 | 2026-10-19 (A3) | Düşük |
| S29 | https://steamcommunity.com/app/239820/discussions/0/3825299103413571355/ | Steam forumu, Game Dev Tycoon (A3 [64]'ten devralındı) | 2023-08-29 | 2026-10-19 (A3) | Düşük |
| S30 | https://steamcommunity.com/games/606800/announcements/detail/2152021858900112360 | Startup Company, Beta 13 duyurusu (A3 [21]'den devralındı) | 2017-12-01 | 2026-10-19 (A3) | Yüksek |
| S31 | https://steamcommunity.com/games/1331550/announcements/detail/1811772772408660 | Big Ambitions, EA 0.9 duyurusu (A3 [17]'den devralındı) | 2025-09-30 | 2026-10-19 (A3) | Yüksek |
| S32 | https://softwareinc.coredumping.com/wiki/index.php/Teams | Software Inc. wiki (`D_ARASTIRMA.md:57`'den devralındı, AÇILMADI) | bulunamadı | 2026-10-18 (D) | Orta |
| S33 | https://steamcommunity.com/games/362620/announcements/detail/2454911758748566987 | Software Inc., Alpha 10 duyurusu (A3 [7]'den devralındı; metinde kullanılmadı) | 2018-08-11 | 2026-10-19 (A3) | Yüksek |
| S34 | https://steamcommunity.com/games/1342330/announcements/detail/4237325463675656030 | Mad Games Tycoon 2, Birinci Yıl duyurusu (A3 [24]'ten devralındı, yeniden açılmadı) | 2022-01-21 | 2026-10-19 (A3) | Yüksek |

Kaynak yoğunlaşması uyarısı: oyun mekaniği omurgası (Software Inc., MGT2, Game Dev Tycoon, Startup Company) 10 Düşük/Orta forum ve önizleme kaynağına dayanıyor; resmi wiki hiç açılamadı. Hiçbir sayı yük taşıyan tek kaynağa bırakılmadı; sayısal tasarım Bölüm 7'de [GÖRÜŞ] ve [VARSAYIM] diye işaretli.

## 3. Oyun oyun döküm

Sütun sırası: Ofis neyi verir, Sayı/formül, Bedel, 1 ve 50 çalışanda, Şikâyet. "Bulunamadı" kafadan doldurulmadı.

| Oyun | Ofis neyi verir | Sayı/formül | Bedel | 1 ve 50 çalışanda | Şikâyet | Kaynak |
|---|---|---|---|---|---|---|
| Software Inc. (bizim tür) | Oda ortamı verimi etkiler: gürültü, kalabalık; lider tek odada olunca performans bonusu alır; kahve/buzdolabı odada olursa insan masayı terk eder, kaldırılırsa mutsuz olur | Oyuncu beyanı: oda başına ~10 kişiden sonra verim düşer ("hatırladığım kadarıyla"), kural "10-12 PC/oda"; Dynas aynı başlıkta 12, takımlarına göre 16'ya kadar diyor, yani bant tek ses değil; "(X*Y)/3 yuvarlanıp aşağı" formülü başka biri "garip" buluyor; resmî sayı yok. Aynı odada birden çok takım: performans cezası | Lider tek odada bonus alır ama tatmini düşer, maaş zammı ister [S1]; kira: 2015 forumunda küçük kurulum günde 50-60 dolar (A3) | 1 kişi: oda sorunu yok. 50 kişi: oda başına 10-12 kuralıyla ~5 oda (türetilmiş: 50/12..50/10) | Alpha'da 20 PC'lik odada şikâyet; yeni elemanda "-%50 ortam" göstergesi bir hataydı, kayıt yeniden yüklenince geçti [S2] | S1, S2, S3 |
| Startup Company (bizim tür) | Bina kademesi: 8, 20, 50 iş istasyonu (beta dönemi); dekor ve yan haklar işçi hızını artırır; masa yükseltmesi "needs/wants"e göre bonus verir | 8 / 20 / 50 [S6]; Beta 13'te gökdelen 80 iş istasyonu (A3'e göre) [S30]. Dekor yüzdesi: bulunamadı | Taşınınca mobilya silinir, tam iade, yeniden alım [S6]. Kira rakamı: bulunamadı | 1 kişi: 8'lik bina yeter. 50 kişi: 50'lik bina ya da gökdelen. Bir oyuncu hiçbir zaman 38'den fazla çalışan gerekmedi diyor [S6] | Masa yükseltmesi çalışanı tek tek kaldırıp oturtmayı gerektiriyor, angarya [S8]; küçük ofislerde nakit yoksa personel mutsuz ve verimsiz [S24] | S6, S8, S24, S30 |
| Game Dev Tycoon (bizim tür) | Garaj, sonra ofis, sonra daha büyüklerine geçiş: daha çok çalışan, daha büyük bordro | Geliştirici: yükseltme mesajı TÜM KOLTUKLAR DOLUYKEN ve nakit en az 16M iken gelir (2020, özet, açılmadı) [S10]. Koltuk sayıları: bulunamadı (bir oyuncu "daha büyük binada 6 koltuk" diyor [S9]) | Oyuncu beyanı: "32k bir ay" gider [S28]; 70 bin ise ofis gideri değil, taşındıktan sonra "ayda 70k+ kaybediyorum" diyen oyuncunun zararı [S29] | 1 kişi: garajda 1 kişi mümkün. 50 kişi: oyunda bu ölçek yok (kaynak yok) | Erken taşınan batıyor [S28][S29]; her işe alım "birbirine alışana kadar" geçici verim düşürüyor [S9] | S9, S10, S11, S28, S29 |
| Mad Games Tycoon 2 (bizim tür) | Kademe yok: taşınma kaldırıldı, yeni bina bir tık [S34]; verim ODA kalitesinde: halı, resim, kahve, radyo | Oyuncu rehberi: 3 çalışana 1 kahve, 10'a 1 su/çöp, 3'e 1 ilaç dolabı [S4]; sayısal buff: bulunamadı. Dev odasında 10 kişi sınırı aşılınca sorun [S4][S5] | Kira: bulunamadı | 1 kişi: oda yok sorun. 50 kişi: 20+ kişilik odada yol bulma sorunu, oyuncular 10 ile sınırlıyor [S5] | Yönetici odası "eğlenceli ama yapılacak bir oda daha, yük" [S5]; oda doluluğu dolu oyunda motivasyon %66 ve istifa [S4] | S4, S5 |
| Big Ambitions (bizim tür, yan) | Merkez ofis yönetici masası ve bilgisayarı için gerekir; "para kazandırmaz, altyapıdır" (geliştirici) | Buff yok; masa sayısı serbest, sınır dış müşteri gelen işlerde [S14] | Taşıma yok: bina taşınamaz, ikinci merkez açılır [S14] | 1 kişi: ev/tek ofis. 50 kişi: birden çok merkez | Taşınınca sözleşmeler ve ayarlar siliniyor, rotalar sıfırdan kuruluyor [S14] | S14, S31 |
| Game Dev Story (bizim tür, mobil) | Her yükseltme: +2 koltuk, yeni eğitim, reklam ve işe alım yöntemleri | $600K (1. yükseltme), $2.500K (2.); tetik: bir oyun + belli nakit ve yıl koşulları; Ofis 2: TV reklamı $350K, hayvan kostümü, vb.; Ofis 3: kart oyunu yarışması $3.300K vb.; eşya fiyatları artar [S12]. İşe alım: Vocational School ve Open House ofis 2, Hollywood Agent ofis 3 [S13] | Kira: yok. Tek düzenli gider yıllık maaş [S12] | 1 kişi: başlangıç. 50 kişi: oyunda yok (en çok birkaç koltuk) | Bulunamadı | S12, S13 |
| Motorsport Manager | HQ binaları (Factory, Design Centre 4 seviye; Wind Tunnel 3 seviye) | Wind Tunnel £7.000.000; Brakes £8.000.000, Handling £5.000.000; her ikisi 3 seviye; etkiler: bulunamadı [S15] | Yıllık işletme gideri, yarış başına gösterilir [S15]; "yükseltmelerin aylık bakımı da var, aşırıya kaçma" (oyuncu) [S16] | 1 ve 50 çalışan kavramı yok | Bakım giderleri hızla birikiyor [S16] | S15, S16 |
| Football Manager | Tesisler: senior antrenman gelişimi hızlandırır; gençlik tesisleri ve genç koçluk gençlerin kalitesini; gençlik toplayıcılığı kimlerin gelebileceğini belirler | 1-20 puan, "Basic"ten "Exceptional"a kadar adlandırılmış kademeler [S17]; seviye başına sayısal etki: bulunamadı | Yükseltme kurul üzerinden pahalı ve yavaş [S18]; inşaat transfer bütçesinden gider (FM14) [S20] | 1 oyuncu: ilgisiz. 50: kadro büyük, etki kadroya dağılır (yorum) | FM24 rehberi: gençlik tesisleri gelişimi etkilemez, yalnız antrenman tesisi etkiler [S19]; tesis harcaması kimine göre israf [S20] | S17, S18, S19, S20 |
| Two Point Campus / Hospital | Oda prestiji öğrenci ve personelin mutluluğunu ve sağlığını etkiler; dekor çekiciliği ve hijyeni artırır; kampüs seviyesi personel, öğrenci, oda sayısı ve ortalama oda prestijinden çıkar; hastane seviyesi daha çok hasta ve yetenekli personel çeker | Sayısal formül: bulunamadı. Aynı eşyadan çok koymak prestiji düşürür [S21] | Dekor ucuz; bakım/hijyen/yan oda gideri: bulunamadı | Personel sayısı arttıkça mola odası kapasitesi yetmez, bekleme uzar [S21] | Çekicilik mutluluk için en güçlü kol değil: sağlık/ruhsal bakım, oda prestiji, kulüpler önde [S21] | S21, S22, S23 |

Henüz aranmadı/açılamadı: Startup Panic, Project Hospital, Production Line (bütçe); Software Inc. resmi wiki oda sayfaları (bütçe); Game Dev Tycoon wiki ofis sayfası (402).

### Oyunlardan çıkan örüntü

- Bina kademesi = kapasite + kilit + bedel; buff sürekli bir kaydırıcıdır ve ODA/dekor/tesis düzeyinde yaşar [S6][S12][S1][S21].
- Buff'ın OKUNURLUĞU zayıf: Software Inc.'in oda ortamı oyuncuların tartıştığı bir bilmece [S1][S2]; FM'de seviye başına etki yok [S17]. Ekranda tek satırla okunan tek örnek bulunamadı. [GÖRÜŞ] Bu, bizim için fırsat: tek satırla okunan buff emsalde yok.
- Kapasite sınırı çoğu yerde kalıcı değil, oyuncu kapıya yaklaşınca MESAJ/GÖREV olarak geliyor: Game Dev Tycoon ve Game Dev Story (Bölüm 6).

## 4. Uzaktan çalışma ve ekip büyüklüğü cezası

- Uzaktan çalışma cezası olan oyun: bulunamadı. İki arama (Software Inc. "work from home"; genel "management sim remote workers") ilgili oyun mekaniği döndürmedi; bulunanlar ofis merkezli oyunlar (Office Management 101, Project Manager SIM), uzaktan seçeneği yok.
- Ekip/kalabalık cezası olanlar:
  - Software Inc.: önerilen takım boyutunu aşmak kaliteyi düşürür; lider önerilen kişi sayısına sayılır [S3]; aynı projeye birden çok takım çok az verim kaybı yaratır (kodu alıntılayan bir oyuncu, 2016) [S3]; aynı odada birden çok takım ceza [S1]. Wiki'ye göre sınırsız takım olur, önerilen boyut ~10-12, sayısal ceza wiki'de yok [S32] (D araştırmasından devralındı).
  - Game Dev Tycoon: yeni eleman gelince takım "alışana kadar" kötü oyun yapar; 6 koltuklu binada son 2 işe alım küçük verimsizlik yaratır [S9].
  - MGT2: dev odasında 10 kişi üstü sorun, 20+ yol bulma sorunu [S4][S5].
- Ekran: bulunamadı (hiçbir kaynak cezayı ekranda gösteren bir satırdan söz etmiyor). Software Inc.'te oda başına bir gürültü katmanı (overlay) var [S2].

## 5. Başarısızlar ve eleştirilen yerler (ayrı aramalarla)

| Oyun | Oyuncunun kızdığı yer | Kaynak |
|---|---|---|
| Game Dev Tycoon | Taşınma maliyet uçurumu: "garajda kal, 1M'de taşınma, ayda 32 bin gömer"; 1,5M'de taşınan "ayda 70 bin+ kaybediyorum, iflas" diyor. Oyun yine de %94,5 olumlu (A3'te Steam API) | S28, S29 |
| Startup Company | Yeni binaya geçerken mobilya silinip yeniden alınıyor; masa yükseltmesi çalışanı tek tek kaldırıp oturtmak | S6, S8 |
| Mad Games Tycoon 2 | Ofis/oda eklemek "yük"; odada 20+ kişide yol bulma sorunu | S5 |
| Big Ambitions | Merkez taşınamıyor; taşıyınca sözleşmeler siliniyor | S14 |
| Motorsport Manager | Yükseltmeler bakım gideri doğuruyor, sezon boyu birikiyor | S16 |
| Football Manager | Tesis harcaması kimine göre israf; FM24 rehberine göre gençlik tesisi gelişime etkisiz; inşaat transfer bütçesinden | S19, S20 |

Doğrudan "ofis yükseltmesi anlamsız" ya da "yalnız kozmetik" biçiminde şikâyet: Game Dev Tycoon ("pointless/no benefit"), Startup Company ve MGT2 aramalarında bulunamadı. Bu bir yokluk kanıtı değil, bir bütçe sınırının sonucu.

Ders (ikisinin farkı): başarılı yerde buff görünmez ya da kademeye bağlı değil bile olsa şikâyet konusu olmuyor; şikâyet yalnız (a) gizli/ani gider uçurumunda ve (b) taşınma/yeniden kurulum angarasında çıkıyor. Bu, C9'daki "kira ve kalan runway'i ofis kartında göster" kararını destekler (A3 Soru 4 görüş) ve [GÖRÜŞ] buff'ın kendisinden çok geçişin ANGARASIZ ve ÖNİZLEMELİ olmasının önemli olduğunu söyler. Bizde taşınma bedelsiz kalır ve kişiler kendiliğinden gelir (O18, `C0_HARITA.md`), yani Startup Company'nin yeniden kurulum angarası yok.

## 6. Yönlendirme örnekleri (Frank'in "ofis tutalım" yazısına benzer)

| Oyun | Ne tetikliyor, nasıl söylüyor | Kaynak |
|---|---|---|
| Game Dev Tycoon | Oyun, tüm koltuklar dolu ve nakit eşiğin üstündeyken "ofis yükseltmesi" mesajı yollar; mesaj olay çubuğunda durur, süresi dolabilir (geliştirici 16M diyor, 2020) | S10 (özet, doğrulanmadı) |
| Game Dev Story | Yükseltme koşulları (bir oyun, belli nakit, yıla göre ödül) sağlanınca ofis yükseltmesi açılır | S12 |
| Big Ambitions | Eğitici görevlerden biri "40% trafikli bir bina kirala" (bina kiralamayı öğretir; ofis değil) | S31 (A3'ten) |
| Two Point Hospital | Hedef/yıldız sistemi: bir hastane tamamlanınca sonraki açılır; hedefler yazılı | S23 |
| Software Inc., Startup Company, MGT2 | Ofis yönlendirmesi/görevi bulunamadı | arama |

[GÖRÜŞ] Emsallerde yönlendirme bir SİSTEM MESAJIdır, bir karakterin sesi değildir. Frank'in yazısı bu açıdan özgün; ona ek olarak yazının buff'ı ve gideri ADIYLA söylemesi (Bölüm 7) emsalde olmayan bir okunurluk kazandırır.

## 7. Bizim oyun için seçenekler

Kural: "konuştukça yeni sistem eklenmez". Üç seçeneğin ortak noktası: yeni sayaç, yeni ekran, yeni durum YOK; var olan tablolara çarpan bağlanır. Sayılar [VARSAYIM] ve [GÖRÜŞ]; ekonomi dengesi (buff kirayı karşılıyor mu) `msim` ile ölçülmeli: bunu ben [DEĞERLENDİREMEM] çünkü maaş ölçeği ($ ve ×1,5) Faz C'de henüz kodda değil.

### Seçenek 0 · Buff yok, ofis yalnız kapasite ve görünüm (yapma)

Oyuncu kararı: yalnız "kasa yetiyor mu". Emsal: Big Ambitions böyle (merkez para kazandırmaz) [S14]. Ders: Erdem'in istediği "ofise çekici sebep" kalmaz; kira bir gider olarak kalır, Game Dev Tycoon'un "ofis beni batırdı" şikâyetini besler [S28][S29]. Bu yüzden Erdem'in kararına (buff'lı ofis) aykırı; karşılaştırma tabanı olarak yazıldı.

### Seçenek 1 · "Mesai daha az yorar": tek düzen çarpanı k (verim eğrisi + moral aşınması)

- Ne: ofis kademesi başına tek sayı k < 1. İki mevcut tablo bu k ile çarpılır: gün içi verim düşüşü `DECAY_PER_HOUR 0.02` (`hr_constants.gd:772`) ve moral aşınması `MORALE_BASE_DRIFT_PER_DAY 0.25` (`:878`). Ev k = 1,0.
- Örnek (placeholder): İş hanı k = 0,85; Plaza 0,70; Loft 0,55. Gün SONU verimi (8. saat, gün başına oran): ev 0,860; İş hanı 0,881; Plaza 0,902; Loft 0,923. Gün ortalaması 1 − 0,07k: 0,930 → 0,941 → 0,951 → 0,962 (ev'e göre +%1,1 / +%2,3 / +%3,4 çıktı). Moral aşınması ayda ~7,5 puan (`PRD_EKIP_VERIM_DESTEK.md:47`; V2 değişmediyse) → 6,4 / 5,3 / 4,1 puan (türetilmiş).
- Oyuncu hangi kararı verir: ne zaman taşınacağı (kira ve k karşısında), bir kez üç kez; aşağı taşınmak serbest ve ev dahil k geri döner. Sıklık: koşu başına en çok 3 karar.
- Tek satırla okunur mu: evet. Ofis kartı (İş hanı): "Mesai daha az yorar: gün sonu verimi %86 yerine %88". Ekip satırında zaten "Verim %105 → %88" gösterimi var (`PRD_EKIP_VERIM_DESTEK.md:52`), yeni satır sebep olarak "Ofis" eklemek yeter.
- 1 / 12 / 38 / 70 kişide: 1 kişi (ev): hissedilmez, k yok. 12: küçük (+%2). 38 ve 70: etki kişi başına aynı, toplam çıktı kişiyle orantılı büyür; Loft'ta +%3,4 ama masa başı kira $257 (Plaza $211'den pahalı), yani Loft'un buff'ı gider artışını tek başına karşılamayabilir [DEĞERLENDİREMEM, msim]. Loft'a marka/itibar katmanı eklemek bu yüzden mantıklı (Seçenek 2 ile birleşim).
- Gider görünür ve yönetilebilir mi: evet. Kira Finans'ta tek satır (C2/C9); buff Ekip satırında; oyuncu istediği an aşağı taşınarak gideri keser.
- Kurala uyum: iyi. Yeni sistem yok; iki var olan sabite çarpan. Faz D gelince aynı k kalabalık kaybına da çarpan olur (bir sayı, üç yer).
- Ters gidebilir: (a) buff küçük kalır (+%1-3 çıktı) ve oyuncu "ofis kirası bedava değil, işe yaramıyor" yorumu yazar; erken uyarı: msim'de ofise geçen koşunun 6 ay içinde nakit farkı ev koşusundan kötü; (b) V1/V2 henüz kodda değilse çarpan bağlanacak yer kayar.

### Seçenek 2 · "İtibar": ofis kademesi marka puanını bir kez yükseltir

- Ne: taşınma tamamlanınca `GameState.set_brand(brand + n)` (`game_state.gd:349`, kullanan yerler `effects.gd:245`). n placeholder: İş hanı +3, Plaza +6, Loft +10, bir kez; aşağı taşınınca geri alınmaz ya da alınır (ayrı karar).
- Sebep-sonuç: marka bugün satın alma çarpanı ve marka çöküşü gibi yerlerde okunuyor (`endings_system.gd:265` satın alma çarpanı bandı, `:103` marka çöküşü) ve B2B kayıpları markayı düşürüyor (`b2b_sales_system.gd:297,485`). VC masasında marka doğrudan okunuyor: `vc_pitch_system.gd:171,227` (dönüşüm farkı), `term_sheet_table_system.gd:542`; B2C kitle akışında marka ve itibar katsayıyla okunuyor, `sales_system.gd:191-192`. [DÜZELTİLDİ, doğrulama turu: önceki "bulunamadı" yanlıştı.] Erdem'in "itibar" dediği şey marka mı, itibar (`reputation`) mı: ikisi de kodda var, karar gerek.
- Oyuncu kararı: yalnız taşınma zamanı; sıklık 3 kez. Tek satır: "Marka +6". 1/12/38/70: ev 0; ofislerde aynı sayı ekip büyüklüğüne bakmaz (ölçeklenmez: 70 kişide +10 marka az, 12 kişide +3 fazla olabilir).
- Gider görünür mü: evet; buff tek seferlik olduğu için kira boyunca "ödediğini geri almadığı" hissi var (Game Dev Tycoon dersi). Zayıf yanı: bir kez gelen sayı, sürekli kira ile eşleşmiyor.
- Kurala uyum: iyi (var olan kol); ama marka puanının ekranda görünmediği ya da okunmadığı yerde buff görünmez [HUD'da marka görünüyor: `top_bar.gd:218`, itibar `:220`; doğrulama turunda düzeltildi].
- Ters gidebilir: oyuncu markanın ne işe yaradığını görmezse "ofis +6 verdi ama bir şey değişmedi"; erken uyarı: playtest'te "marka" soru işareti.

### Seçenek 3 · "Kalabalık kaybını ofis geri verir"

- Ne: Faz D'de aynı kartta kalabalığın doğurduğu verim kaybının bir kısmı ofiste geri gelir (aynı k çarpanı). Erdem'in kendi cümlesine en yakın seçenek ("ekip büyüdükçe zaten debuff var, ofis azaltır").
- Bağımlılık: kayıp kodda yok; yalnız `D_MODEL_v3.md` §3.5 (onaylı v2): "şirket çapında kayıp yoktur; kayıp yalnız aynı kartta yaşar; takım nesnesi demoda yok". Eski eğri tablosu (3 kişiye kadar kayıp yok, 5'te %2, 10'da %7, 20'de %17, tavan %25) `D_INCELEME.md:103`'te, ama şirket çapı kaldırıldığı için güncel değil. Faz sırası Q, C, D: C9b D'den ÖNCE geliyor, yani bu seçenek C'de teslim edilemez.
- 1/12/38/70: 1 kişi etki yok; 12: küçük; 38 ve 70: en büyük etki (kayıp tavanı büyük ekipte yükselir). Ölçek bakımından en doğal, ama aynı kartta kalabalık olmadıkça sıfır etki: oyuncu çoğu koşuda hissetmeyebilir.
- Kurala uyum: iyi ama D'ye bağlı. Ofisin "tek satırla okunur" etkisi D'nin kayıp ekranına bağlı ("Koordinasyon: -%10, 8 kişi", `D_ARASTIRMA.md:65`).

### Karşılaştırma

| Ölçüt | Seçenek 1 (k) | Seçenek 2 (marka) | Seçenek 3 (kalabalık) |
|---|---|---|---|
| Oyuncu kararı | Ne zaman taşınmalı (kira ya da k), 3 kez | Aynı | Aynı, ekip büyüdükçe daha anlamlı |
| Tek satır | "Gün sonu verimi %86 yerine %88" | "Marka +6" | "Koordinasyon kaybı −%4" (D'den sonra) |
| 1 / 12 / 38 / 70 | 0 / küçük / orta / orta | 0 / aynı / aynı / aynı | 0 / küçük / büyük / en büyük (yalnız aynı kartta kalabalıkta) |
| Gider görünür/yönetilebilir | Evet | Evet, ama tek seferlik | Evet |
| Yeni sistem | Yok (2 sabite çarpan) | Yok (1 kol) | Yok ama D'ye bağlı |
| C'de teslim edilebilir mi | Evet (V1/V2 koddaysa) | Evet | Hayır, D'den sonra |
| Ters gidebilir | Küçük buff, kira karşılamaz | Buff görünmez/okunmaz | D'siz boş |

### [GÖRÜŞ] Önerim

Seçenek 1'i ana buff yap, tek bir k sayısı olarak; Seçenek 2'yi YALNIZ Loft'ta küçük ekstra olarak ekle (kira masa başına $257 ile $211 arasındaki farkı karşılaması için) ve marka mı itibar mı sorusunu Erdem'e sor; Seçenek 3'ü "D gelince aynı k'yi kalabalık kaybına bağla" notu olarak sakla. Frank'in yazısı k'yi adıyla söylesin: "Ofiste mesai daha az yorar: gün sonu verimin %86 yerine %88, ayrıca kira $4.000". Bu hem emsalde olmayan okunurluğu verir hem Erdem'in "gider görünür ve yönetilebilir" ilkesine uyar.

Ne yapmayacağız: oda başına/dekor başına buff sistemi (Software Inc., MGT2, Startup Company yolu: okunmuyor, yük [S1][S5][S8]); aday havuzu kalitesi (bugün kol yok, yeni sistem olur); uzaktan çalışana debuff (Erdem sonraya bıraktı, açık iş). Seçilmeyen yolun bedeli: ofis farkı küçük kalır ve Plaza'dan Loft'a geçişin "neden" sorusu marka ekiyle zayıf cevaplanır.

Erdem'e sorular (toplu, en önemlisi başta):
1. Kodda "ekip büyüdükçe koordinasyon kaybı" yok (Bölüm 1). Bu kayıp ofiste buff'ın karşılığı olacaksa, onu Faz D'ye (aynı kartta kalabalık) bağlamak kabul mü, yoksa C9b için bugünden basit bir kayıp mı istiyorsun? (Ben ikincisini önermem: yeni sistem olur.)
2. "İtibar" derken marka mı (herkesin sana güveni, 0-100) yoksa itibar mı (`reputation`, VC sorularında okunan)?
3. Aşağı taşınınca (Plaza'dan İş hanı'na) buff gider, marka kalır mı kaybolur mu?
4. Uzaktan çalışma debuff'ını "sonraya açık iş" olarak ACIK_ISLER'e yazayım mı (Erdem'in kararı gereği)?

## 8. Gerçek dünya (arka plan, 3 kaynak)

- Ctrip, 16.000 çalışanlı şirkette çağrı merkezi gönüllüleri, 9 ay rastgele ev/ofis: ev performansı %13 artırdı (%9 daha uzun çalışma süresi, %4 dakikada daha çok çağrı), daha az işten ayrılma, ama performans koşullu terfi oranı evdekilerde DÜŞTÜ [S25].
- Trip.com, Şangay, 1.612 kişi, 6 ay, haftada 2 gün evden: verim ve terfi farkı yok, işten ayrılma %33 düştü (yalnız yönetici olmayanlarda) [S26]. Makalenin kendisi açılmadı.
- Microsoft Research: yazılımcılarda özel ofis daha yüksek algılanan verimlilikle ilişkili; kesintisiz çalışma ve ekiple iletişim önemli etkenler [S27] (özet).
- [GÖRÜŞ] Kanıt "ofis verim artırır"ı desteklemiyor; "terfi/öğrenme" ve "iletişim" ofis lehine, "çıktı" ve "tutundurma" evde lehine. Oyun için emsallerin geleneği (kademe = verim) tutmak daha güvenli; gerçek dünya oranı tek başına gerekçe değil.

## 9. Doğrulama turu ve boşluklar

Karara en çok yük bindiren iddialar kaynağa karşı:

| İddia | Durum |
|---|---|
| Software Inc. oda başına ~10 kişi verim eşiği | S1 açıldı, iki yazar (Phiber Optik, Dynas) aynı bandı söylüyor; alpha dönemi; resmi wiki açılmadı. Zayıf-orta |
| Startup Company 8/20/50 | S6 açıldı; beta dönemi, güncel sayı bilinmiyor; Beta 13 80 iş istasyonlu gökdelen (S30, devralındı) |
| Game Dev Story +2 koltuk, $600K/$2.500K | S12 açıldı |
| Game Dev Tycoon yükseltme tetiği (dolu koltuk + 16M) | Yalnız arama özeti, açılmadı. DOĞRULANMADI. Oyuncu tavsiyeleri (6-8M, 1-5M bekle) başka şey: tavsiye, tetik değil |
| Bloom 2015, Bloom 2024 | S25, S26 açıldı; Nature makalesi açılmadı; ScienceDaily'deki "yalnız yönetici olmayanlarda" notu makaleden doğrulanmadı |
| Motorsport Manager, Football Manager, Two Point, Big Ambitions | Yalnız arama özeti; sayısal etki hiçbirinde bulunamadı |
| "Kodda koordinasyon yok" | `git show HEAD:project-unicorn/scripts/systems/hr_constants.gd` satır 1030 açıldı; HEAD'de başka okuyucu yok (`git grep` yalnız debug dosyalarını döndürdü). Q'nun commit'lenmemiş farkları bakılmadı |
| Verim/moral hesapları | `hour_yield` formülü `hr_constants.gd:776-780`'den yeniden hesaplandı: 1 − 0,02·(h−1); h = 8 → 0,86; ortalama 1 − 0,02·3,5 |

Çözülmeyen uyarılar: (1) oyun mekaniği sayısı yok; (2) yoğunlaşma: omurga Steam forumu; (3) Game Dev Tycoon yükseltme tetiği tek özet; (4) sonraki tur için ilk iş: `softwareinc.coredumping.com` oda/ortam sayfası ve Startup Company wiki'si.

## Doğrulama turu

Tarih 2026-10-20. Kaynaklar yeniden açıldı (10 fetch), kod HEAD'den okundu. Not: Q'nun commit'lenmemiş farklarına bakılmadı.

| # | İddia | Sonuç | Kaynak |
|---|---|---|---|
| 1 | Ctrip: 16.000 çalışan, 9 ay, +%13 (≈%9 dakika, %4 dakikada çağrı), terfi koşullu düştü | DOĞRULANDI. Tarih 2013-03 (QJE 2015); eski ama belgede tarihli | S25 |
| 2 | Trip.com 1.612 kişi, 6 ay, haftada 2 gün, verim/terfi farkı yok, ayrılma %33 düştü | DOĞRULANDI. ScienceDaily kendi içinde çelişiyor: "%33" genel, "yalnız yönetici olmayanlarda" kısıtı sonradan geliyor; kısıt makaleden doğrulanamadı: [DOĞRULANAMADI] | S26 |
| 3 | Game Dev Story: +2 koltuk, yeni eğitim/reklam/işe alım, $600K ve $2.500K | DOĞRULANDI. 1. yükseltme koşulu sayfada "[Confirm]" işaretli (doğrulanmamış); 2. yükseltme koşulu yıla göre değişiyor, belgede yok | S12 |
| 4 | Startup Company 8/20/50, taşınınca mobilya tam iade ve yeniden alım, dekor/yan haklar hız artırır | DOĞRULANDI. Yayın 2017-08-16 (beta önizleme; güncel sayı bilinmiyor). "38 kişi" önizleme yazarının kendi sözü | S6 |
| 5 | Software Inc.: oda başına ~10 kişiden sonra verim düşer | KISMEN. "Hatırlıyorsam" kaydıyla bir oyuncu; 10-12 ikinci mesaj; Dynas 12-16 diyor. Sayısal ceza yok, resmî kaynak yok. Lider tek odada bonus ve tatmin kaybı doğrulandı. Düzeltme yapıldı (Bölüm 3) | S1 |
| 6 | Game Dev Tycoon taşınma maliyet uçurumu: ayda 32-70 bin | DÜZELTİLDİ. 32 bin gider olarak geçiyor (2018); 70 bin ofis gideri değil oyuncunun "ayda 70k+ kaybediyorum" zararı (2023). Taşınma eşiği oyuncu beyanı (1M, 1,5M) | S28, S29 |
| 7 | GDT yükseltme tetiği: tüm koltuklar dolu ve ≥16M | DOĞRULANDI (önceden DOĞRULANMADI idi). Geliştirici, 2020-03-04: "full staff (all seats are taken) and at least 16M". Aynı başlıkta tetiği üretemedikleri de yazıyor (2020-03-23) | S10 |
| 8 | Startup Company masa yükseltme angarası | DOĞRULANDI, ama "çalışanı kaldır, yeni masa al, oturt" tarifi yalnız ilk mesajı yazanın (2019-06-09); geliştirici yalnız "aynı boy masada çalışır, UI zor" diyor. Binayı değiştirince mobilya silinmesi ayrı iddia ve S6'da | S8, S6 |
| 9 | Kod: koordinasyon çarpanının okuyucusu yok | DOĞRULANDI. `hr_constants.gd:1030` yorumu, `COORD_*` yalnız `:1011-1047` ve smoke'ta | HEAD |
| 10 | Kod: DECAY_PER_HOUR 0,02 (`:772`), moral aşınması 0,25 (`:878`), MORALE_PACE_STEPS (`:855`), hour_yield 8. saat 0,86 | DOĞRULANDI. Ek: 8 saati aşan saat için `DECAY_OVERTIME_PER_HOUR 0.03` var (`:773`) | HEAD |
| 11 | Kod: VC masasında/HUD'da marka okunmuyor | YANLIŞTI, DÜZELTİLDİ. `vc_pitch_system.gd:171,227`, `term_sheet_table_system.gd:542`, `sales_system.gd:191`, `top_bar.gd:218`. Seçenek 2'nin "okunmaz" riski bu kadar güçlü değil | HEAD |
| 12 | Kod: masa 1/12/38/70 | YANLIŞ. HEAD 1/10/36/64 (`office_constants.gd`); belgede işaretlendi | HEAD |

Kaynak yoğunlaşması: omurga tek yayıncıdan değil ama tek tür kaynaktan, Steam forumu (S1, S2, S4, S5, S8, S9, S28, S29), ve bunlar Düşük. Yük taşıyan tek Düşük kaynak yok, ama "ofis buff'ı oda/dekor düzeyinde yaşar" sonucunun omurgası S1 (2019 alpha forumu) ile S6 (2017 beta önizlemesi), ikisi de eski; güncel sürümde farklı olabilir. Bölüm 1 ve 2'deki kademe tespiti yine de S12 ve S21 ile ayrıca destekli.

Başarısız örnekler: GDT (S28, S29) ve Startup Company (S8) gerçek ve kaynaklı. Big Ambitions (S14), MGT2 yönetici odası (S5), Motorsport Manager (S16), Football Manager (S19, S20) açılmadı (özet/doğrulanmadı). GDT'nin "%94,5 olumlu" sayısı A3'ten devralındı, yeniden açılmadı.

Kalan uyarılar: (a) Bölüm 5 tablosundaki S14, S16, S19, S20 satırları [DOĞRULANAMADI]; (b) S26'daki "yalnız yönetici olmayanlarda" [DOĞRULANAMADI]; (c) HEAD'deki Plaza ve Loft marka şartı Erdem'in "yalnız paraya bağlı" kararıyla çelişebilir.
