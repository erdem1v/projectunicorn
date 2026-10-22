searches: 25, fetches: 15

# Runway gösterimi (C2 girdisi)

Tarih 2026-10-20. Karar Erdem'in. Besleyen karar: ERDEM_KARARLAR_2026-10-20.md:37 (madde 7).

## Özet

1. Bugün oyunda gider 0 iken ve net akış sıfır ya da artıyken runway INF döner ve her ekran yeşil "Artıda" (EN "Default Alive") yazar [K: game_state.gd:486-487, ui_tokens.gd:410-412]. İlk hafta belgesi ise ayrı bir yoldan gider ve INF'yi sayıya çevirmeye çalışır [K: first_week_doc.gd:228-229]. Gerçek çıktısı Godot koşturulmadığı için [DEĞERLENDİREMEM], ama "sonsuz" metni değildir.
2. Oyunların çoğu runway ay sayısını hiç göstermiyor: bakiye ve nakit akışı renkle, eksiye düşünce süreli bir geri sayım var (Prison Architect 2, Voxel Tycoon) [S7, S8]. Oyun tarafında "kârdayken ne yazar" sorusuna kanıtlı cevap bulunamadı. Bizim oyun bu alanda zaten öndedir (ay sayısı, hafta sayacı, kepenk).
3. Gerçek araçlarda tek kanıtlı davranış: kâr durumunda runway "infinite" yazar (Midday) [S2]; birkaç hesaplayıcı ve rehber aynı mantığı anlatır ama davranışı kendi sayfasında göstermez [S3, S4, S5, S6, S20, S21]. Mercury, Brex, Baremetrics, ChartMogul, Carta için kaynak bulunamadı.
4. Paul Graham'ın "default alive" ölçütü henüz kâra geçmemiş ama büyümesiyle geçecek şirketi tarif eder; zaten kârdaki şirketi ele almaz [S1]. EN etiket "Default Alive" bu yüzden hem jargon hem hafif yanlış, TR "Artıda" ile anlamı da aynı değil.
5. Oyuncunun runway göstergesini yanlış okuduğuna dair örnek bulunamadı. Bulunan şikâyetler "göstergesiz yavaş batış" ya da kuralı bilmemek türünden [S11, S12, S19, S15].
6. [GÖRÜŞ] İlk hafta belgesi: satır kalsın, "Gider yok" yazsın (Seçenek İH-B). Finans: kârdayken durum sözü kalsın, EN "In the black" olsun, gider 0 özel durumu ayrı yazılsın (Seçenek F-A). Gerekçe aşağıda.

## Bugün oyunda (HEAD, kodla doğrulandı)

Komut: git grep -i runway HEAD -- project-unicorn/scripts ve strings.csv taraması. Çalışma ağacı okunmadı.

- Hesap: günlük net = günlük gelir (MRR ÷ 30, yuvarlanır) eksi günlük gider. Net ≥ 0 ise INF, değilse nakit ÷ (-net) ÷ 30 ay [K: game_state.gd:476-488]. Gider 0 ve MRR 0 iken net tam 0 olduğundan INF çıkar; "gelir gider üstünde" şartı aranmaz.
- Gösterim kapısı tek yerde: net_runway_parts. Kasa < 0 ise "0 hafta"; INF ise "Artıda" (EN "Default Alive") yeşil, ipucu RUNWAY_PROFITABLE_NOTE; 1 aydan azsa hafta; değilse tam ay [K: ui_tokens.gd:403-420, strings.csv:2-5]. İpucu "Gider gelirin altında" der; gider ve gelir ikisi de 0 iken bu cümle doğru değildir (eşitlik).
- Ekranlar: üst bar [K: top_bar.gd:208-218], Finans sekmesi KPI [K: finance_tab.gd:91-97], Finans Özet notu [K: finance_ozet_view.gd:196-198], ay/hafta özeti postası (yeşil yalnız kasa ≥ 0 ve net ≥ 0) [K: summary_system.gd:211-213, mail_pane.gd:599-600], işe alım önizlemesi "önce → sonra" [K: hr_search_system.gd:221,275, hr_atlas_modal.gd:356-361], event seam'i (INF, haftada 9999) [K: seams_finance.gd:26-42].
- Uyarılar: Frank'in Finans notu 6 ayın altında çıkar, INF'de hiç çıkmaz [K: finance_ozet_view.gd:19,475-482]. Ticker yalnız 3 ve 1 ay eşiklerinde konuşur; INF tüm eşikleri yeniden kurar [K: finance_system.gd:84-85, summary_system.gd:158-172].
- VC ve yatırım masası BRÜT runway kullanır: gider tabanı 1, hep sonlu. Gider 0 iken kasa $10.000 ise 10000 ÷ 1 ÷ 30 = 333 ay yazar ("Kasa: $10K · Runway: 333 ay") [K: vc_pitch_system.gd:1198-1202, term_sheet_table_system.gd:955-959, strings.csv:1378]. Kasa $10.000 varsayımı C_ICERIK_v3.md:231'dendir [DOĞRULANAMADI: bu turda açılmadı].
- İlk hafta belgesi net_runway_text kullanmaz: runway_months_for(nakit, -başlangıç gideri) sonra "%d ay" biçimi [K: first_week_doc.gd:226-229]. Gider 0 olunca months = INF ve roundi(INF) metin üretir mi sayı mı belli değil; "sonsuz" ya da "Artıda" çıkmaz.
- EN/TR farkı: RUNWAY_PROFITABLE TR "Artıda", EN "Default Alive" [K: strings.csv:2]. Smoke bu iki metni bekler [K: endgame_smoke.gd:3043,3073-3079].
- Negatif ay çıkmaz: kasa < 0 önce yakalanır, önizlemeler maxf(0, ...) ile tabanlanır [K: ui_tokens.gd:407, hr_search_system.gd:221,275].

## Kaynak sicili

| S# | URL | yayıncı | yayın tarihi | erişim | güven |
|---|---|---|---|---|---|
| S1 | https://paulgraham.com/aord.html | Paul Graham | Ekim 2015 | 2026-10-20 | Yüksek |
| S2 | https://midday.ai/docs/check-runway | Midday (kendi ürün dokümanı) | bulunamadı | 2026-10-20 | Düşük (satıcı; kendi ürünü için birincil) |
| S3 | https://puzzle.io/blog/puzzles-tools-for-analyzing-burn-and-runway | Puzzle | 2022-08-24 | 2026-10-20 | Düşük (satıcı) |
| S4 | https://www.rho.co/blog/cash-runway | Rho | 2024-10-07, güncelleme 2026-08-12 | 2026-10-20 | Düşük (satıcı) |
| S5 | https://pilot.com/calculators/startup-runway-calculator | Pilot | bulunamadı | 2026-10-20 | Düşük (satıcı) |
| S6 | https://terms.law/Calcs/startup-runway-calculator/ | terms.law | bulunamadı | 2026-10-20 | Düşük |
| S7 | https://www.paradoxinteractive.com/games/prison-architect-2/news/feature-highlight-finances | Paradox Interactive | 2024-03-19 | 2026-10-20 | Yüksek (yayıncı) |
| S8 | https://voxeltycoon.guru/articles/read/index/id/20/name/Bankruptcy | Voxel Tycoon Guru (hayran rehberi) | bulunamadı | 2026-10-20 | Orta |
| S9 | https://steamcommunity.com/app/535930/discussions/0/1743352529779588584 | Steam forumu, Two Point Hospital (moderatör cevabı) | bulunamadı | 2026-10-20 | Orta |
| S10 | https://steamcommunity.com/app/1342330/discussions/0/3113656428083196969 | Steam forumu, Mad Games Tycoon 2 | Haziran 2021 (arama özeti) | 2026-10-20 | Orta |
| S11 | https://steamcommunity.com/app/239820/discussions/0/864977026045070690 | Steam forumu, Game Dev Tycoon (geliştirici Greenheart Games dahil) | 2013 (arama özeti) | 2026-10-20 | Orta |
| S12 | https://steamcommunity.com/app/415200/discussions/0/133257959060069197 | Steam forumu, Motorsport Manager (yalnız arama özeti, sayfa okunmadı) | bulunamadı | 2026-10-20 | Düşük |
| S13 | https://steamcommunity.com/app/1644320/discussions/3/3810657811763928745 | Steam forumu, Railway Empire 2 (yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |
| S14 | https://pcinvasion.com/prison-architect-alpha-20-adds-fail-states | PC Invasion (yalnız arama özeti, sayfa okunmadı) | bulunamadı | 2026-10-20 | Düşük |
| S15 | https://steamcommunity.com/app/362620/discussions/0/613956964596417077 (ve app 362620 altında 3 başlık daha) | Steam forumu, Software Inc (yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |
| S16 | https://www.capitalismlab.com/?p=10362 | Capitalism Lab (yapımcı sitesi, yalnız arama özeti) | bulunamadı | 2026-10-20 | Orta |
| S17 | https://store.steampowered.com/app/1045610/ | Steam mağaza sayfası, Startup Panic (yalnız arama özeti) | bulunamadı | 2026-10-20 | Orta |
| S18 | https://discreet-braid-394.notion.site/Dev-Tycoon-Support-3037c02bb08f80cba9e2d5a70a66dc34 | "Dev Tycoon" destek sayfası (başka bir oyun, yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |
| S19 | https://www.fmscout.com/a-how-to-avoid-getting-into-heavy-debt.html | FM Scout (topluluk rehberi, yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |
| S20 | https://www.allianz-trade.com/en_US/insights/cash-runway.html | Allianz Trade (yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |
| S21 | https://www.intervue.io/tools/burn-rate-calculator | Intervue (hesaplayıcı, yalnız arama özeti) | bulunamadı | 2026-10-20 | Düşük |

Okunamayan sayfalar: Software Inc Fandom vikisi (HTTP 402), Trevor Blackwell hesaplayıcısı growth.tlb.org/runway (sertifika hatası), Baremetrics hesaplayıcısı (ana sayfaya yönlendi, takip edilmedi), Klipfolio (yönlendirildi, takip edilmedi).

## Tablo

"Gider 0 iken": gider sıfırken ne yazar. Oyunlarda bu durum ayrı bir ekran değil; kanıt bulunamadığında öyle yazılır.

| Ürün/oyun | Eksideyken | Kârdayken | Gider 0 iken | Kaynak |
|---|---|---|---|---|
| Paul Graham, "Default Alive or Default Dead" | Ölçüt: gider sabit, gelir son büyümesini korursa kâra paranın yetip yetmediği. Formül yok, hesaplayıcıya yönlendirir. "Kurucuların yarısı hangisi olduğunu bilmiyor." | Ele alınmaz (essay kâra geçmemiş şirketi anlatır) | Ele alınmaz | [S1] |
| Midday | Ay sayısı | "Infinite" yazar | Burn sıfır ya da negatifse "infinite" | [S2] |
| Puzzle | Kesirli ay (180.000 ÷ 24.000 = 7,5), son tam ayın burn'üne dayanır | Sayfada yok | Sayfada yok | [S3] |
| Rho (rehber) | Net burn ile ay sayısı | Rehber runway'i "henüz kârda olmayan" şirket metriği diye çerçeveler, kârı anlatmaz | Anlatılmaz | [S4] |
| Pilot, terms.law (hesaplayıcı sayfaları) | Nakit ÷ aylık net burn formülü | Sayfada çıktı mesajı yok | Sayfada yok | [S5, S6] |
| Allianz Trade, Intervue (yalnız özet) | Ay sayısı | "Runway sorunu yok, nakit büyür"; hesaplayıcı nakit akışı pozitifi otomatik işaretler [DOĞRULANAMADI: sayfalar açılmadı, arama özeti] | Teknik olarak sonsuz [DOĞRULANAMADI] | [S20, S21] |
| Mercury, Brex, Baremetrics, ChartMogul, Carta | bulunamadı | bulunamadı | bulunamadı | yok |
| Prison Architect 2 | Bakiye ve nakit akışı çizelgesi; eksi bakiye "birkaç gün" içinde artıya dönmezse hapishane elinden alınır. Önceden tahmin ya da "bitişe kaç gün" göstergesi yok | Pozitif değerler yeşil | Anlatılmaz | [S7] |
| Prison Architect (ilk oyun) | "Her zaman önce uyarı alırsın, düzeltmen için süre verilir" (özette para değil genel başarısızlık durumları; para olup olmadığı belirsiz) | bulunamadı | bulunamadı | [S14] |
| Voxel Tycoon | Bildirim menüsünde işletme "iflas riskinde"; uyarıda parasal tutar var, tıklayınca öder; sayfa somut son tarih vermez, "süreyi kaçırabilirsin" der; kaçırılırsa kırmızı "iflas etti" bildirimi; kritik bildirim oyun hızını 1x'e düşürür | bulunamadı | bulunamadı | [S8] |
| Two Point Hospital | Moderatöre göre tek kaybetme koşulu -200 bin bakiye; konuda oyun içi uyarıdan söz eden yok | bulunamadı | bulunamadı | [S9] |
| Mad Games Tycoon 2 | Oyuncu -114 milyar dolara kadar indi, sonra şirket "iflas etmiş" ilan edildi; uyarıdan söz yok | bulunamadı | bulunamadı | [S10] |
| Game Dev Tycoon | Konuda eşik ya da uyarı anlatılmıyor; oyuncular ikinci işçi ve daire sonrası batıyor, "taşınmadan önce sermaye biriktir" öğüdü | bulunamadı | bulunamadı | [S11] |
| Motorsport Manager | Borçluyken sürücü, parça, tesis alınamaz; gelir yalnız yarış ve sponsor | bulunamadı | bulunamadı | [S12] |
| Railway Empire 2 | Negatif nakit faiz biriktirir; yavaş batış olarak anlatılıyor | bulunamadı | bulunamadı | [S13] |
| Capitalism Lab | Para biterse şirket tasfiye; temel oyunda oyun biter, DLC ile devam edilir. Uyarı metni bulunamadı | bulunamadı | bulunamadı | [S16] |
| Startup Panic | Para azsa kredi ya da yatırımcı yolu var; ay cinsinden runway göstergesi bulunamadı | bulunamadı | bulunamadı | [S17] |
| Football Manager, Software Inc, Startup Company, Big Ambitions, Two Point (kulüp finansı) | Runway göstergesi bulunamadı. FM için yalnız topluluk rehberi: bütçe, yönetim kurulu, idare/tasfiye anlatılıyor, ay sayısı anlatılmıyor [BOŞLUK] | bulunamadı | bulunamadı | [S19, S15] |
| Dev Tycoon (BAŞKA bir oyun) | Nakit art arda 90 gün negatifse iflas | bulunamadı | bulunamadı | [S18] |

Sonuç: oyun tarafındaki 14 ürünün hiçbirinde "kârdayken runway yerine ne yazar" kanıtlanamadı. Tablodaki tek doğrudan karşılık gerçek araçlardan: Midday kâr durumunda "infinite" der [S2]. Bunun dışındaki "sonsuz" iddiaları araç sayfaları değil rehber/özet cümleleridir ve ürün davranışı kanıtlamaz.

## Başarısızlar ve eleştirilenler

- Aranan: oyuncunun runway ya da kasa göstergesini yanlış okuduğu, "iflas habersiz geldi" dediği örnek. Kanıtlı doğrudan örnek bulunamadı; kapsam Steam forumları ve arama özetleriyle sınırlı kaldı.
- Game Dev Tycoon: oyuncu ikinci kişiyi alıp daireye taşınınca sürekli iflas ediyor; konuda oyunun uyardığına dair bir cümle yok, öneriler "önce sermaye" [S11]. Ders: eşik değil, harcamanın yeni sürekli gideri doğurduğunu önceden göstermek. Bizim işe alım önizlemesi (önce → sonra) bunun karşılığıdır [K: hr_atlas_modal.gd:356-361].
- Mad Games Tycoon 2: konu iflasın geç ilan edilmesi ve otomatik kaydın elle kaydın üzerine yazması üstüne kurulu; eşik -114 milyar [S10]. Ders: uyarı yoksa oyuncu sonuna kadar gider; ama bu bir göstergenin yanlış okunması değil, göstergenin yokluğudur.
- Railway Empire 2: negatif nakitte faiz birikmesi "yavaş batış" diye anlatılıyor [S13]. Two Point Hospital'da "negatif döngüye düşmek kolay" yorumu var [S9].
- Software Inc: oyuncular rehber olarak bir yıllık gider kadar nakit tutmayı öğütlüyor [S15]. Bu, oyunun bunu göstermemesinin dolaylı belirtisi olabilir ama kanıtlanmadı [GÖRÜŞ].
- Genel: kurucuların yarısı default alive mi dead mi olduğunu bilmiyor [S1]. Yani gerçek dünyada da durum sözü ayrı bir ihtiyaç.
- Kârdaki durum sözünün yanlış güven verdiği örnek bulunamadı. Bizim kodda böyle bir risk var: yeşil "Artıda" yalnız anlık net akışa bakar, gelecek aya MRR düşerse bilgi vermez [K: game_state.gd:486-487].

## Seçenekler

Ortak kural: hiçbir seçenekte "sonsuz", "∞" ya da "INF" metni görünmez.

### İlk hafta belgesi (GİDER $0 iken RUNWAY satırı)

Oyuncu bu belgede kasayı, gideri, ofisi ve ekibi görüp koşuya başlar. Karar: ilk işe ne zaman ve ne kadar harcayacağı.

- İH-A: Runway satırı gizlenir. TR gider notu: "Henüz gider yok." EN: "No costs yet." Oyuncu hesaplanmış bir süre görmez; karar işe alım ekranına kalır. Artısı: sıfır yanlış okuma. Eksisi: belge dört satıra iner, "süre" kavramı ilk kez ilk işe alım önizlemesinde öğrenilir.
- İH-B: Satır kalır, değer durum sözü olur. TR: "RUNWAY: Gider yok" ve alt not "İlk işe alımla sayaç başlar." EN: "RUNWAY: No costs yet", note "The clock starts with your first hire." Oyuncu bu satırın bir sayaç olduğunu ve henüz işlemediğini görür, ilk işe alımın onu başlatacağını bilerek karar verir. Eksisi: sözcük "Gider yok" üst bardaki "Artıda"dan farklı bir durum; iki ifade yan yana öğrenilir.
- İH-C: Satır ileri bakar. TR: "RUNWAY: İlk işe alımla yaklaşık {n} ay". EN: "RUNWAY: About {n} mo after your first hire". Oyuncu harcamanın bedelini baştan görür ve ilk işe alımın ne kadar sert olacağını ayarlar. Eksisi: {n} için "tipik ilk işe alım" gideri gerekir (C2'nin kira ve maaş kararına bağlı, bu belgede sabit bir sayı önerilmez); yanlış varsayım yanlış söz verir.

### Finans (kârdaki şirket)

Kapsam: üst bar hücresi, Finans KPI'ı, ay/hafta özeti satırı, işe alım önizlemesi şeridi. Oyuncu "kasam erimiyor mu" sorusunu cevaplar; karar: işe alım, gider, büyüme hızı.

- F-A: Durum sözü kalır, etiket düzelir, gider 0 özel durumu eklenir. TR "Artıda", EN "In the black" (Default Alive çıkar). İpucu TR: "Gelir giderleri karşılıyor; kasa erimiyor. Sayaç, net akış eksiye dönerse başlar." EN: "Revenue covers costs, so cash is not shrinking. The clock starts if net flow turns negative." Gider 0 ve gelir 0 iken: "Gider yok" / "No costs yet", ipucu "İlk gider girince sayaç hesaplanır." / "The clock is calculated once the first cost appears." Oyuncu işe alım önizlemesinde "Artıda → 5 ay" geçişini görür ve işe alımın sayacı başlattığını anlar. Eksisi: yeşil söz yalnız bugünkü akışa bakar.
- F-B: Net ≥ 0 iken runway gizlenir, yalnız eksideyken görünür. Üst bar hücresi TR "Yok" / EN "None" ya da boş kalır; Finans KPI'ı çıkar. Oyuncu "Aylık net +$X" satırını okur [K: finance_tab.gd:85-90]. Artısı: sayı yalnız bir anlam taşırken görünür. Eksisi: işe alım önizlemesindeki "önce → sonra" şeridinin sol tarafı boşalır [K: hr_atlas_modal.gd:359]; üst bar sabit hücreli olduğundan boşluk "arıza" gibi okunabilir; sayaç belirince oyuncu için yeni bilgi sürpriz olur.
- F-C: Durum sözü artı yastık. TR: "Artıda · gelir kesilse 14 ay". EN: "In the black · 14 mo if revenue stopped". Oyuncu gelirinin ne kadar büyük bir yastık sağladığını görür ve büyümeyi buna göre ayarlar. Kod tarafında BRÜT hesap hazır [K: vc_pitch_system.gd:1198-1202]; ama gider 0 iken 333 ay çıkar, o yüzden F-A'nın "Gider yok" özel durumu şarttır. Eksisi: ekranda iki runway kavramı olur (net ve brüt); VC masası brüt kullanır, karışabilir.

## Öneri [GÖRÜŞ]

- İlk hafta belgesi: İH-B. Satır sayaç olduğunu öğretir, "sonsuz" yazmaz, sabit sayı gerektirmez. İH-C daha öğretici ama sabit bir ilk işe alım varsayımı ister; C2'nin maaş ve kira kararı oturduktan sonra eklenebilir.
- Finans: F-A. İşe alım önizlemesindeki "Artıda → N ay" geçişi, tabloda hiçbir oyunun vermediği ve oyuncunun harcama kararına en çok yarayan bilgidir; F-B bunu siler. F-C sonraya bırakılabilir (iki runway kavramı riski). EN "Default Alive" çıkmalı: Graham'ın ölçütü kâra geçmemiş şirket içindir [S1] ve smoke metni de buna göre güncellenmeli [K: endgame_smoke.gd:3043,3073].
- Ayrıca düzeltilecek üç kod sapması (C2 kapsamı Erdem'in kararı): (1) first_week_doc.gd:229 INF'yi net_runway_text'e vermiyor; (2) "Gider gelirin altında" cümlesi gider ve gelir 0 iken yanlış (strings.csv:3); (3) VC masası gider 0 iken "333 ay" yazar (vc_pitch_system.gd:1201-1202).
- Bu araştırmanın sınırı: oyun örneklerinin çoğu arama özetine dayanır, kâr durumundaki oyun davranışı kanıtlanamadı. Karar zevk kararıdır, kanıt yön verir ama belirlemez.

## Doğrulama turu

Tarih 2026-10-20. Bu turda 9 sayfa açıldı (S1, S2, S3, S4, S7, S8, S9, S10, S11), arama yapılmadı. Kod HEAD'den okundu (git show).

| # | İddia | Sonuç | Kaynak |
|---|---|---|---|
| 1 | Midday kârdayken "infinite" yazar [S2] | DOĞRULANDI. Harfiyen: "If your burn rate is zero or negative (you're profitable), runway shows as infinite." Yayın tarihi sayfada yok (yalnız 2026 telif satırı) | midday.ai/docs/check-runway |
| 2 | PG: default alive tanımı, "kurucuların yarısı bilmiyor", Ekim 2015 [S1] | DOĞRULANDI. "Half the founders I talk to don't know whether they're default alive or default dead." Not: essay kârı hedef ölçüt sayar, "kârdaki şirket ele alınmaz" doğru ama "kâra geçmemiş şirket içindir" yorumudur | paulgraham.com/aord.html |
| 3 | Prison Architect 2: eksi bakiyede "birkaç gün", yeşil pozitif, tahmin göstergesi yok, 2024-03-19 [S7] | DOĞRULANDI. "a couple of days to get back to a positive balance"; grafik geçmiş veridir | paradoxinteractive.com ... feature-highlight-finances |
| 4 | Voxel Tycoon bildirim, tutar ve son tarih, 1x hız [S8] | KISMEN YANLIŞ, düzeltildi. Tutar var, somut son tarih yok; kritik bildirimde hız 1x'e düşer (varsayılan, kapatılabilir); kırmızı iflas bildirimi doğru | voxeltycoon.guru ... Bankruptcy |
| 5 | Puzzle 180.000 ÷ 24.000 = 7,5, 2022-08-24 [S3] | DOĞRULANDI. Makale kârı ya da sonsuzu anlatmaz (belgedeki "sayfada yok" doğru) | puzzle.io/blog/... |
| 6 | Rho 2024-10-07, güncelleme 2026-08-12, kârdaki şirketi anlatmaz [S4] | DOĞRULANDI. "not yet profitable" çerçevesi, sonsuz runway anılmaz | rho.co/blog/cash-runway |
| 7 | Mad Games Tycoon 2: -114 milyar, otomatik kayıt ezmesi, Haziran 2021 [S10] | DOĞRULANDI. 1 Haziran 2021; "didn't realize that the auto save was overwriting my manual save" | steamcommunity.com/app/1342330/... |
| 8 | Game Dev Tycoon: daire ve işe alımdan sonra iflas, "önce sermaye" [S11] | DOĞRULANDI. Ağustos 2013; AnonTwo "Build Capital before taking risky moves"; geliştirici yalnız dış ipuçlarına yönlendirir. Ek: oyuncular çelişkili tavsiye veriyor (1 kişi mi 4 kişi mi), "göstergesiz batış" yorumunu zorlamaz | steamcommunity.com/app/239820/... |
| 9 | Two Point Hospital: tek kaybetme koşulu -200 bin, "negatif döngü kolay" [S9] | DOĞRULANDI. İki ayrı moderatör cümlesi; oyun içi uyarıdan söz yok | steamcommunity.com/app/535930/... |
| 10 | Kod okuması (HEAD) | DOĞRULANDI, iki satır numarası düzeltildi. Net >= 0 ise INF (game_state.gd:485-487); net_runway_parts INF ve kasa < 0 sırası (ui_tokens.gd:403-419); üst bar D_runway_reading üzerinden aynı kapıya gider (ui_tokens.gd:909-919); ilk hafta roundi(months) doğrudan (first_week_doc.gd:228-229); VC brüt: maxi(daily_burn,1), kasa > 0 değilse 0 (vc_pitch_system.gd:1198-1202); 10000 ÷ 1 ÷ 30 = 333 (DAYS_PER_MONTH 30, time_model.gd:17); smoke "Default Alive" bekler (endgame_smoke.gd:3043,3073); RUNWAY_PROFITABLE_NOTE satır 3, gider 0 ve gelir 0 iken "Gider gelirin altında" yanlış (eşitlik) | git show HEAD |

Sonuçlar
- Kaynak yoğunlaşması: kanıtlı tek gerçek araç davranışı (Midday) tek bir satıcı sayfasına ve yayın tarihsiz bir dokümana dayanıyor. Üç sonuç ("kârdayken sonsuz yazılır" emsali) bu tek kaynağı taşıyor; emsal gücü zayıf, karar zevk kararı olarak kalır (belgedeki sınır cümlesi doğru).
- Omurga tek yayıncı değil: PG, Paradox, Midday, hayran rehberi ve Steam forumları ayrı kaynaklar. Oyun örneklerinin çoğu forum ve yalnız arama özetidir.
- Başarısız örnekler gerçek ve kaynaklı (S9, S10, S11 açılıp okundu). Ancak üçü de "gösterge yanlış okundu" değil "gösterge ya da uyarı yok" örneği; belge bunu zaten söylüyor.
- Açılmayan, yalnız arama özetiyle duran satırlar: S12 ile S21 arası ve S14 [DOĞRULANAMADI]; tabloda "Düşük" etiketiyle kalıyor, karar bunlara yaslanmamalı.
- Roundi(INF) çıktısı çalıştırılmadığı için hâlâ bilinmiyor.
