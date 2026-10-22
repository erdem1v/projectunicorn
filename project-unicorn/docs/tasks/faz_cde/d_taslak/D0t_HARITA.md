# D0t · Bağlantı haritası (Faz D, salt okuma)
İlk yazım 2026-10-18 (D0t.1, `fc6b392`). **D0v tazelemesi 2026-10-22, `main` @ `8038c424` (Faz D D0a).** Kaynak: `PRD_FAZ_D_EKIP_SPRINT.md`
§6, §8, §9 (satırları `889b9b8`'e göre), `ADIM_TABLOSU_D_v2.md` §0b, `git log fc6b392..HEAD` (45 commit), bugünkü kod. Godot koşmadı,
oyun dosyasına yazılmadı, index'e dokunulmadı.

## 0. Nasıl okunur
- **"HEAD" sütunu `8038c424` içeriğidir.** Çalışma kopyasında yalnız `scripts/debug/run_probe.gd` kirli (C'nin commit'siz +37 satırı:
  `PROBE END support_reports/support_news` sayaçları) ve `project.godot`. `run_probe.gd` satırları `git show HEAD:` ile okundu; C
  commit'leyince `:314` sonrası +6, `:404` sonrası +10, `:925` sonrası +27 kayar. Okuma sırasında C'nin destek raporu işi şu dosyalara da
  commit'siz yazdı; hepsi atıf yapılan satırların altında ya da satır kaydırmıyor (doğrulandı): `endgame_smoke.gd` (`:25041` sonrası),
  `support_system.gd` (`:311` sonrası), `main.gd:1095` (tek satır), `CLAUDE.md` (`:138` ve `:284` sonrası +1), `HARITA.md:158`, `:386`,
  `GUNCELLEMELER.md:332`, motor md `:3071`. Burada yazan bütün satırlar HEAD'indir.
- "PRD'deki yer" PRD'nin `889b9b8` satırıdır (PRD güncellenmedi). Kayma özeti §10'da.
- **Adım adları `ADIM_TABLOSU_D_v2` §0b'dendir.** (a) tam tanımlı, bugünkü motorda yürür, bu sırayla: **D1, D1b, D2b, D3, D4, D7, D8a, D8b,
  D5a**. (b) park, Erdem'in M2 cevabını bekler: **D2a, D2c, D3b, D6, D5b, D9**. Ertelenen: D8c, D8d (kart yenilemesi). Düşen: devret önerisi,
  "en çok bir devreden" kalkanı (D2b'de kalkar), aşama satırı ≤ 2× kapasite, P3, negatif Δ, `HR_AREA_MEANING_*`, `NECK_FITS_*`.
  "park" yazan satır (a) adımlarında bugünkü davranışı korur.
- **İki ayrı "K" numaralaması.** Bu dosyanın K1–K27'si kopukluk riskidir (§9). ADIM_TABLOSU'nun K4, K6, K7'si A4'ün tasarımcı kararlarıdır
  (kadro tavanı, testçinin Geliştirme/Düzeltme satırı, kurucunun aşama sırası); karıştırılmaz.
- "Q/C" sütunu: Faz Q bitti (K20 dahil commit'li, `7012218a`); kalan C adımları C3a (memnuniyet defteri, şema), C3b, C5 (yenileme,
  kesinti tablosu), C6 (Genel Bakış, istekler 3★), C8, E2. "Q bitti" yazan yerde Q'nun değişikliği HEAD'dedir.

**`fc6b392` → HEAD (45 commit):** Faz Q 33 (K0–K24), Faz C 11 (C1, C2 + düzeltme, C2b, C2c, C4, C7, C9a, C9a-3B, C9a-3C, C9b), Faz D 1 (D0a).
D'yi ilgilendiren kapanışlar:
- `ProductLines.work_profile` var (`product_lines.gd:333-334`); her gerçek hat `profile` taşıyor (`data/product/lines/*.json`).
- `ProductQuality` var (`product_quality.gd`).
- Dolar × puan riski kapandı (Q K14/K16: dışarıdan iş ve kâğıdın dolar/puan bedelleri silindi).
- Eksen `push_axes` silindi (Q K7b); evre beklenti tablosu kalktı (Q K2).
- `PROBE DECISION` var (C9a).
- D0a: 12/25/50 kişilik prob, `PLANMS`, Erdem örneği fikstürleri.

`sprint_system.gd` bu aralıkta yalnız `_close`/`_go_public` içinde değişti: `:1528`'e kadar satırlar aynı, `:1529` sonrası −1.

## 1. Sprint motoru (`scripts/systems/sprint_system.gd`)

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| M1 `team()` | `:705-723` | `:705-720` | Görevler matrisinde Yapım ya da Test işini tutan aktif kişiler ve kurucu: `{id, name, points, share, fits, founder, ahead}`; `points` = `_points` × koşan sprintin mesai çarpanı. | Karar 1: `points` kişinin hızı (D1b); Karar 2: uyum ve rol kutusu (D2a). Okuyucular K1. | D1b; şekil D2a (park) | yok |
| M2 `capacity()` | `:633-638` | `:633-637` | Ekibin haftalık puanları × sprint haftası, tek sayı. | ×5 sayı D1'den kendiliğinden gelir; aşama başına kapasite D2a/D6. Okuyucular K2. | D1 (ölçek); D2a, D6 (park) | yok |
| M3 `week_points(draft)` | `:694-699` | `:694-699` | Mesai modalının taslak saatli ekip puanı. | Sayı D1'de ×5 görünür; anlam Karar 1'de değişir (U16). | D1b; modal satırı sahipsiz | yok |
| M4 `points_for` / `_points` | `:1731-1745` | `:1720-1725`, `:1729-1733` | 2 × beceri bandı × saat; çalışanda × verim × pay, kurucuda 2 × `founder_mult` × verim × saat × pay. | D1: `person_points_week` 2 → 10. D1b: 10 × Y(s) × U × verim × saat × pay × huy. | D1, D1b | yok |
| M5 `_share` | `:1749-1751` | `:1738-1740` | Sprint işi sayısı × `focus_mult`. Kurucunun toplantı payını okumuyor (K17). | Kurucuda 1 − toplantı payı (Karar 5). | D1b | yok |
| M6 `_fits` | `:1722-1727` | `:1711-1715` | Kurucuya `founder_roles`, çalışana ana ya da ikincil alanının rollerini verir; ikincil tam uyum. | U çarpanı (ana 1,0, ikincil 0,7, uymayan 0,4) D1b'de; rol × kutu tablosu ve PM/Tasarımcı Test kutusu D2a'da. Çelişki K3, K4. | D1b; tablo D2a (park) | yok |
| M7 `role_of` | `:1710-1718` | `:1699-1706` | Kişinin bu hafta çalıştığı kartın fazının rolü ya da "". | Düzeltme "dev" (D3), PM hazırlığı (D4); okuyucular K5. | D3, D4; D2a (park) | yok |
| M8 `_restaff` | `:1362` | `:1352-1360`; çağıranlar `remove` `:122`, `decision_carry` `:404`, `_on_team_changed` `:1329` | Ekipte olmayanı karttan düşürür, boştakileri kimsesiz kartlara dağıtır. | "Kalır" istisnası; tek atama girişine bağlanır (§14). | D2a (park) | yok |
| M9 `_assign` | `:1129-1159` | `:1120-1147` (`able` süzgeci `:1131-1132`, sıralama `:1136-1141`, kalan puan devri `:1142-1147`) | Kartları sprint sırasıyla doldurur: fazın rolüne uyan, sonra çok puanı kalan, sonra kimlik; PM ve tasarımcı (`ahead`) yalnız faz 0'da. | Karar 4 dağıtım kuralı (§14). D4 kural A bu sıralamaya PM hazırlığını ekler. | D2a (park); D4 | yok |
| M10 `_work` | `:1162-1177` | `:1153-1164` (uymayan hız `:1157`, `faulty` işareti `:1161-1162`) | Kişinin bütçesini kartın fazlarına döker; uymayan rolde `no_role_speed` 0,5. | Hız U'dan (D1b); `faulty` işareti D3'te kalkar; `shares` okuması (`:1158`) D1'de ihtiyaca geçer. | D1, D1b, D3 | yok |
| M11 `_play_out` | `:1180-1210` | `:1171-1193` (`_assign` `:1178`) | Kopya kartları verilen ekiple N hafta oynatır, `split` ve `spare` döndürür. | Çekme (D2b), test bitişindeki hata (D3), reaktif P (D2a), seçenek (D2c, N3). | D2b, D3; D2a, D2c (park) | yok |
| M12 `_end_week` | `:1087-1112` | `:1078-1104` (`_work` `:1090`) | Haftanın işini atananların bütçesiyle döker; süre dolduysa ya da kartlar bittiyse `_close()`, değilse `_staff_week(true)`, `_ask_promise()`. | Çekme ve test anı burada; kapanış yalnız süre dolunca. | D2b, D3 | yok |
| M13 Erken kapanış | `:1109-1110` | `:1100-1101` | `week() > sprint_weeks() or _finished(...)`. | `_finished` kolu kalkar (Karar 11). | D2b | yok |
| M14 `_staff_week(ask_paper)` | – | `:1109-1112` (`_assign` `:1110`, `:1112`) | Haftanın ataması; `ask_paper` ise kâğıt zarı, kâğıt geldiyse yeniden atama. `_begin` `:164`, `_end_week` `:1103`, `_clear_decision` `:1310` çağırır. | `_begin`'in `sprint_weeks() == 1` argümanı kalkar (D1); zar ilk haftanın sonunda (D2b). | D1, D2b | yok |
| M15 `plan_outcome` | `:774-777` | `:774-776` | Plan ekranının oynatması. | Çekilen kart oynatmada (D2b); prob onu yazar. | D2b | yok |
| M16 `_outcome` | – | `:781-794` (`_play_out` `:785`) | Kopyaları `_play_out`'a verir. | D2b çekilen kartı, D3 n/F'yi ekler. | D2b, D3 | yok |
| M17 `mvp_eta` | `:804` | `:804-843` (`_takes` `:828`, `_play_out` `:831`) | Çekirdek K1'lerinin hangi sprintte biteceğini haftalık oynatır (ufuk 24). | Tek alım sınaması (D2b). D0a tabanı: 50 kişide tek başına 36 ile 45 ms. | D2b | yok |
| M18 `_takes` | `:753-761` | `:753-760` | "+" yüklemi: yük + kart ≤ kapasite × 1,25 ve oynatmada boş puan. | Tek alım sınaması (D2b); aşama satırı şartı düştü. | D2b | yok |
| M19 `card_late`, `late_with`, `finishes_with`, `crunch_finishes`, `cut_test_finishes` | `:848-899` | `:848-849`, `:854-855`, `:859-860`, `:866-876`, `:880-888` | Kalan haftaları oynatıp kartın yetişip yetişmeyeceğini söyler; `crunch_finishes` karar bekleyen kartı baştan atayarak oynar. | Çekmeyle aynı oynatma (D2b); "Testi kısalt" yakalamayı düşürür (D3). | D2b, D3 | yok |
| M20 `remaining`, `ready_share`, `total`, `phase` | `:657-680`, `:1687-1701` | `:657-662`, `:675-678`, `:1676-1677`, `:1685-1690` | Kalan puan, tasarım payı, `effort + effort_mod`, sıradaki faz. | `shares` ve `effort_mod` gider (D1, K13); hazırlık (D4). | D1, D4 | yok |
| M21 `_role` | – | `:1693-1694` | Fazın rolü `roles.<tür>[faz]`. | Düzeltme Geliştirme satırında (D3). | D1, D3 | yok |
| M22 `used`, `card_load`, `done_points` | – | `:642-646`, `:651-652`, `:682-688` | Plan çubuğunun yükü, biten puan, sürüm kaydının `velocity`'si. | ×5; eski kayıtlı `velocity` (K12). | D1 | yok |
| M23 `sprint_weeks()` | `:612-613` | `:612-613` | `sprint.weeks`, yoksa `sprint_weeks` (2). | Sabit 2; `sprint.weeks` kayıttan düşer. | D1 | yok |
| M24 `sprints_in(weeks)` | – | `:618-619` | Hafta → sprint. | Hep ÷2; anlam aynı. | D1 | yok |
| M25 `set_weeks` | `:324-328` | `:320-328` (yorum `:322-323`) | Planlamada `sprint.weeks`'i değiştirir. | Silinir. Çağıranlar §12.3. | D1 | yok |
| M26 1 haftalık dal | `:164-166` | `:164-166` | `_staff_week(sprint_weeks() == 1)`; 1 haftalıkta `team.demo_day` istenir. | Kalkar (E9'a bak). | D1 | yok |
| M27 `new_state` | `:75-86` | `:75-88` (`weeks` `:78`) | Yeni ürünün ilk durumu. | `weeks` kalkar; yeni alanlar varsayılanla. | D1 | yok |
| M28 `weeks_left` | `:629` | `:628-629` | `sprint_weeks() − max(week,1) + 1`. | Değişmez. | D1 | yok |
| M29 `escape_chance` | `:954-956` | `:945-950` (`c.faulty` `:946`) | `faulty` ise `faulty_chance`; kısaltılmış testte en az `cut_test_escape`. | Silinir (D3). D1 ile D3 arası `c.get("faulty", false)`. | D1 (okuma), D3 | yok |
| M30 `cut_test`, `_halve_test` | `:944-949` | `:935-940`, `:928-931` (`shares` yazımı `:929-930`) | Kalan testi yarıya indirir, `cut` işaretler. | `_halve_test` `shares[TEST]`'i yazıyor: D1 ihtiyaca taşır; yakalama D3. | D1, D3 | yok |
| M31 `_close` zarı | `:1462-1464` | `:1450-1454` | `line_blocked` olmayan her çıkan kart için `hash([id, sprint])` zarı. | Silinir; kaçan hata kartın hattına; bağışıklık korunur (K27). | D3 | yok |
| M32 `pending_faulty` | `:1477-1481` | `:1467-1471` | `leaks` ve zarla hatalı çıkanlar. | Kaçan hata buraya (D3); gönderilen bilinen hata D3b. | D3; D3b (park) | yok |
| M33 `_land_faulty` | `:1547-1552` | `:1536-1541`; çağıranlar `:1472`, `:299` | Canlı üründe bekleyen hatları `add_bugs` ile düşer. | Kalır, kaynağı değişir. | D3 | yok |
| M34 Sürüm kaydının `faulty`'si | `:1508` | `:1498` | Zarla hatalı çıkanların hatları. | Kaçan hatanın hatları; okuyucular K8. | D3 | yok |
| M35 `_refresh_fix_cards` | `:1642-1653` | `:1631-1641` (efor `:1636`) | Başlamamış düzeltme kartının eforunu `fix_effort`'tan yeniden okur. | D1'de ×5 (`fix_effort.points`), D7'de 2 × açık hata. | D1, D7 | yok |
| M36 Yeni kod terimi | – | `:298`, `:1428`, `:1449`, `:1465`, `_go_public` `:1519-1532` (`refresh_on_publish` `:1529`), `_shipped_code` `:1569-1578` | Çıkan kademelerin `ProductLines.effort_of`'unu toplar, Destek akışına yazar. | Zincir bütünüyle silinir (K14). | D3 | Q bitti (`push_axes` silindi) |
| M37 `record_interrupt` | `:564-567` | `:564-568` | Sprintin son kesintisi `{sprint, kind}`. | Gönder sorusu türü (Karar 16). | D3b (park) | C5 |
| M38 `_request_decision` | `:1213-1255` | `:1204-1242` (anahtar `:1211`) | Sprint başına tek zar, `decision.sprint_chance.<hafta>`. | `"1"` silinir, okuma tek anahtara (D1); konuşan (D2a). | D1; D2a (park) | yok |
| M39 `_speaker` | `:1258-1267` | `:1249-1256` (PM kolu `:1250-1252`) | PM kâğıdını `quarter_pm()`, öbürlerini kartın `assignees`'inden rolü uyan ilk kişi söyler. | PM'siz çeyrekte bugünkü gibi gelmez (D8b); Karar 4 (D2a). K9. | D8b; D2a (park) | yok |
| M40 `_paper_blocked`, `paper_sprint`, `_interrupted_by` | `:1270-1274` | `:1261-1264`, `:1269-1270`, `:1274-1276` | Söz olayı ya da acil durum gelen sprintte kâğıt gelmez. | Gönder sorusu araya (Karar 16). | D3b (park) | C5 |
| M41 `late_promise`, `_ask_promise` | `:964-1003` | `:955-973` (`:956`), `:979-993` | Son haftada sözü verilmiş kart yetişmiyorsa `product.promise_due`. | 2. haftada sorulur (sabit 2 haftayla kendiliğinden). | D2b | yok |
| M42 `payers` | `:727-741` | `:727-739` | Moral bedelini ödeyenler: hattın kartına atanmış ve `ahead` olmayanlar, yoksa ekip (kurucu hariç). | Düzeltme (D3); PM (D4); K10. | D3, D4 | yok |
| M43 `_settle_decision`, `_clear_decision` | – | `:1280-1287`, `:1303-1310` (`_staff_week(false)` `:1310`) | Kâğıt cevaplanınca haftanın ataması baştan yapılır. | "Kalır" istisnası (§14). | D2a (park) | yok |
| M44 `decision_progress` | – | `:360-373` (sahte kişi `:365`) | `sprint_card_progress`: `_work`'e `{fits, ahead}` sözlüğüyle puan döker. | Miktar ×5 (D1); `_work` kişi şekli değişirse kırılır (K7). | D1, D1b; D2a (park) | yok |
| M45 `apply_lead` | `:332-338` | `:332-341` | Önerinin kartlarını koyar, `lead_applied`. | Altı basamak (D8a). | D8a | yok |
| M46 `pick_goal` | `:556-558` | `:556-558` | `quarter.goal_area`. | PM'siz, "Hatalar" dahil (D8b). | D8b | yok |
| M47 `set_delegate` | `:286-288` | `:286-288` | `delegate` anahtarı. | PM yokken kapalı (D8b). | D8b | yok |
| M48 `delegated` | `:592-594` | `:592-593` | Anahtar açık ve `quarter_pm() != null`. | PM şartı kalır; ayrılınca kalkar (K25). | D8b | yok |
| M49 `awaits_plan` | `:581-589` | `:581-588` | Planlamada ekip ve kart varken, devir yoksa saat bekler. | Korunur. | D8b | yok |
| M50 `sync_plan_hold` | `:1604-1615` | `:1593-1603` | `HOLD_PLAN` tutuşu. | Korunur. | D8b | yok |
| M51 `_auto_start` | `:1392` | `:1382-1399` | Devirde PM'in planı, yoksa lider önerisi. | Tek öneri (D8a); devir (D8b). | D8a, D8b | yok |
| M52 `fix_first`, `put_first`, `decision_carry`, `_carried_out` | `:208-235` | `:208-214`, `:221-231` (`_assign` `:230`), `:390-406`, `:1645-1648` | Düzeltme kartını başa alır ve haftayı baştan atar; `decision_carry` kartı devreder. | Kayan kart çekme sırasında (D2b); "kalır" istisnası (§14). | D2b; D2a (park) | yok |
| M53 `effort_mod` yazanları (yeni satır) | – | `decision_effort` `:344-349`, `effort_change` `:354-356` (en az 1 puan), `trim_points` `:411-413`, `trim_plan` `:419-422`, `decision_trim` `:427-439` (`:431`), `_unfinished` `:898-905` (`:902`) | Kâğıt fiillerinin ±puanı ve kırpması kartın `effort_mod`'una yazılır. | `effort_mod` silinir; ±n'in hangi aşamaya yazılacağı K13. | D1 | yok |

## 2. Katalog ve öneri (`scripts/systems/sprint_catalog.gd`)

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| L1 `candidates` | `:212-256` | `:198-240` (düzeltme kartı `:226`, araştırma `:231`) | Alan başına aday kartlar; hatası olan hat için düzeltme kartı. | Düzeltme kartı 2 × açık hata (D7); kimlik `fix:<hat>` korunur (K20). Derinlik ve istek kartı ertelendi. | D7; D8c, D8d (ertelendi) | C6 |
| L2 `fix_effort` | `:179-182` | `:165-167` | `fix_effort.steps/points` basamakları (4 ve altı 1, üstü 2). | D1'de `points` ×5, D7'de kalkar. Yazanlar `main.gd:890`, smoke `:18223`. | D1, D7 | yok |
| L3 `is_priority` | `:258-259` | `:244-245`, `is_priority_count` `:249-250` | Düzeltme kartı ve `bugs >= fix_effort.priority` (5). | `priority` yeni ev (D7). Okuyucular `product_fixtures.gd:564`, smoke `sprint_fix_*`. | D7 | yok |
| L4 `step_effort` | `:185-193` | `:171-178` (Ar-Ge indirimi `:176-177`) | K1/K2/K3 `effort.k*`, ücretli plan `paid_plan.effort`; tasarım profilli hatta %20 indirim. | ×5 (D1). | D1 | Q bitti (indirim profilden) |
| L5 `lead_suggestion` | `:509-510` | `:477-478` | `_suggest(capacity, used, …, "", true)`: hedefi okumaz. | 5. basamak hedefi okur (D8a, D8b). | D8a, D8b | yok |
| L6 `_suggest` | `:884-921` | `:873-913` (tek talep `:886`, devreden kalkanı `:903-911`) | Zorunlu kartlar tavana kadar, kalanı etki/efor sırasıyla; `played` ise ilk bitmeyecek kartı alıp durur. | Altı basamak, 12 aday (D8a); devreden kalkanı kalkar, tek talep kalır (D2b). | D8a, D2b | yok |
| L7 `_lead_area` | `:862-881` | `:851-861` (küçük ekip `:854`) | Kartı olan alanların en zayıfı. `capacity / effort.k1` ×5'te değişmez. | 5. basamağın "hedef yoksa en zayıf alan" kolu. | D8a | yok |
| L8 `_weakest` | `:832-847` | `:820-835` | Beklentinin en altındaki alan. | D okur. | D8a | Q bitti |
| L9 `open_cards` | `:850-859` | `:839-844` | Aday, kilitsiz, ayrılmamış kartlar. | Derinlik/istek kartı ertelendi. | D8c, D8d (ertelendi) | yok |
| L10 `quarter_pm` | `:563-568` | `:531-535` | İlk aktif PM, yoksa null. | Hazırlayan PM kartta (D4); PM'siz çeyrek (D8b); K9. | D4, D8b | yok |
| L11 `quarter_goal` | `:571-575` | `:539-541` | Seçilmiş hedef alan, yoksa PM'in önerisi. | PM'siz seçilir, "Hatalar" dahil. | D8b | yok |
| L12 `pm_plans` | `:582-606` | `:550-572` (PM yoksa `[]` `:551-552`) | PM varsa ufuk kadar sprintlik plan. | PM'siz çeyrekte sütunlar K22. | D8b | yok |
| L13 `_impact`, `_ratio` | `:809-823` | `:796-811`, `:814-815` | Etki puanı ve etki ÷ efor. | ×5 efor oranı kaydırır (D9 ölçer). | D8a | yok |
| L14 `new_card` | – | `:253-258` | Kart sözlüğü: `roles`, `shares`, `progress [0,0,0]`, `effort_mod`, `faulty`, `cut`, `assignees`. | `shares`, `effort_mod`, `faulty` gider; ihtiyaç, `keep`, Düzeltme ve hazırlık alanları gelir (D1). `_migrate_15` de çağırır (K12). | D1 | yok |
| L15 `card_shares`, `card_roles` | – | `:182-183`, `:187-191` | `shares` ve `roles`'tan fazlar; `card_roles` payı 0 olan fazı atar. | İhtiyaç profilden (D1). | D1 | Q bitti (profil verisi) |
| L16 `card_effect`, `forecast` | – | `:312-338`, `:343-372` | Kartın etki satırı ve sprint sonu öngörüsü. | Derinlik kartı ertelendi; puanlar ×5 görünür. | D1 (görünür); D8c (ertelendi) | Q bitti |
| L17 `mvp_candidates` | – | `:520-528` | Çekirdek K1 adayları efor sırasıyla. | ×5'te sıra aynı. | D2b | yok |
| L18 `line_accounts`, `line_impact`, `larger_account` | – | `:376-379`, `:395-404`, `:408-411` | Hattı kullanan hesaplar. | Hesap isteği kartı ertelendi. | D8d (ertelendi) | yok |
| L19 `_request_of`, `open_requests`, `_on_time` | – | `:756-760`, `:764-766`, `:770-771` | Kartın karşıladığı talep ve son tarihi. | Tarihli talep 2. basamak (D8a). | D8a | C6 |
| L20 `bugs_part` | – | `:463-473` | Etki satırının hata parçası. `license_cost`, `outside_tester_week` Q K14/K16'da silindi. | 2× eforu yazar. | D7 | Q bitti |

## 3. Veri (`data/product/sprint.json` ve hat dosyaları)

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| V1 `sprint_weeks` | `:2` | `:2` | 2; `new_state`, `sprint_weeks()`, `product_model.gd:444` okur. | Tek süre olarak kalır. | D1 | yok |
| V2 `sprint_lengths` | `:3` | `:3` | `[1, 2]`; okuyanlar `product_model.gd:313`, yorum `sprint_system.gd:322`; fikstür `product_fixtures.gd:606` kendi kopyasını taşır. | Silinir (K16). | D1 | yok |
| V3 `effort` | `:6` | `:6` | `{k1 3, k2 5, k3 8, research 1}`. | 15/25/40, araştırma 5. Okuyucular `sprint_catalog.gd:175`, `:231`, `:854`, `save_manager.gd:863` (K12). | D1 | yok |
| V4 `fix_effort` | `:7` | `:7` | `{steps [4], points [1, 2], priority 5}`. | D1'de `points` [5, 10]; D7'de `steps`/`points` kalkar, `priority` taşınır. | D1, D7 | yok |
| V5 `shares`, `roles` | `:8-19` | `:8-13`, `:14-19` | Tür başına faz payları ve rolleri. | `shares` kalkar: özellik ve talep hattın profilinden, düzeltme 0/0,7/0,3 ve araştırma 1/0/0 türünden (D1). `roles` kalabilir. | D1 | Q bitti (profil) |
| V6 `role_areas` | `:20` | `:20` | Sprint rolü → alan; `_fits` okur. | Rol × kutu × uyum tablosu. | D2a (park) | yok |
| V7 Puan ve uyum | `:21-25` | `:21-25` | `person_points_week` 2, `skill`, `founder_mult`, `founder_roles`, `no_role_speed` 0,5. | D1: `person_points_week` 10. D1b: Y(s), U (`no_role_speed` 0,4 uyuma döner). Smoke okuma/yazma §12.6. | D1, D1b | yok |
| V8 `cap_ceiling` | `:26` | `:26` | 1,25. | Kalır. | D2b | yok |
| V9 `lead` | `:28` | `:28` | `small_team_cards` 2. | Altı basamakta yeri yazılı değil (D8a'da korunur). | D8a | yok |
| V10 `faulty_chance` | `:29` | `:29` | 0,4. | Silinir. Smoke 17 satır, 5 işlev (§12.6). | D3 | yok |
| V11 `promise` | `:30` | `:30` | `cut_test_escape` 0,15. | Silinir. Smoke 9 satır. | D3 | yok |
| V12 `pm` | `:40` | `:39` | `horizon`, `goal_weight`, `low_skill_cards`, `goal_squares`, `goal_mark`. | D4 ve D8b okur; `low_skill_cards` kalır. | D4, D8b | Q bitti (`goal_*`) |
| V13 `decision` | `:41` | `:40` | `sprint_chance {"1": 0,3, "2": 0,5}`, `seen_weight` 2, `cards` (**44** kâğıt; PRD 46). | `"1"` silinir (D1). Sözlük kalırsa anahtar gezen 9 yer çalışır; skalar olursa kırılır (K15). | D1 | yok |
| V14 `paper` | `:42-49` | `:41-47` (`reopen_points`, `phone_points` `:42`, `colors` `:45`) | Puan: `reopen_points` 1, `phone_points` 2, `colors {hand 2, central 4, again_extra 1}`; sayım: `ask_silent_mult`, `root_min`; oran: `trim_share` 0,4. `contract_per_point` Q'da silindi. | Puan olanlar ×5; sayım ve oran değişmez. | D1 | Q bitti |
| V15 `incident.fix` | `:54-57` | `:53-56` | B'nin düzeltme süresi, en iyi mühendisin yıldızından. | Karar gerek (K26). | park | yok |
| V16 `paid_plan` | `:78` | `:77` | `effort` 3. | 15 (D1). PRD aşama dağılımı 2/10/3 (`D_MODEL_v3` §3.2). | D1 | yok |
| V17 `impact` | `:79` | `:78` | Etki ağırlıkları. | ×5 efor ve 2× düzeltme eforuyla `_ratio` kayar; ölç. | D8a, D9 | Q bitti |
| V18 `areas` | `:132-139` | `:130-137` | Altı alan ve hatları (`line_hidden_self_serve` `:132`). | Derinlik kartı ertelendi. | D8c (ertelendi) | Q bitti |
| V19 Hat dosyaları | `data/product/lines/` | `erp.json`, `note_tool.json`, `video_clip.json` (5'er hat), `shared.json` (4 hat), her hatta `profile` (ör. `erp.json:16`); `ProductLines.work_profile` `:333-334`, `effort_of` `:341-347` | Hat başına `profile` ∈ {design, dev, test}; katalog eforu 5/7/10. | D1 aşama payını profilden okur; `line_hidden_self_serve` (`data/techtree/rnd_tree.json:39`) ve ücretli plan profilsiz (§12.4). | D1 | Q bitti (K7) |
| V20 `request` | – | `:38` | `deadline_weeks` 8 … | Son tarih 4 sprint kalır. | D8d (ertelendi) | C6 |
| V21 Mutlak hata sayıları | – | `:49` (`bug_cap` 12, `bug_div` 8), `:63` (`month_close.line_bugs` 3), `:73` (storm `line_bugs` 7), `:82` (`neg_line_bugs` 5) | B'nin hazard, ay kapanışı, fırtına, yorum eşikleri. | k'siz kalır (K21). | D7 | yok |

V22 (`expectation`) silindi: Q K2 tabloyu kaldırdı; `:31-33` yalnız `rival_*`, D dokunmaz.

## 4. Öbür sistemler

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| O1 `ProductState.add_bugs` | `product_state.gd:210` | `:199-203` | Hatta `n` açık hata ekler. | Kaçan hata kart çıkınca kartın hattına. | D3 | C3a |
| O2 `clear_line_bugs` | `:218` | `:207-220` | Hattın açık hatasını düşer. | Düzeltme kartı çıkınca; testte bulunan hata kartın içinde. | D3, D7 | yok |
| O3 `line_bugs`, `open_bugs_by_line` | `:180`, `:176` | `:162-163`, `:158-159` | Hat ve bütün hatların açık hatası. | 2× düzeltme büyüklüğü. | D7 | C3a |
| O4 Destek yeni kod terimi | `support_system.gd:37`, `:156-162` | `:37`, `:40`, `reports_per_day` `:160-168` (`:164-166`) | Taban + 0,03 × yeni kod eforu × e^(−yaş/3). | Terim silinir (K14). | D3 | C |
| O5 `NEGLECT_BUGS` | `:86`, `:283` | `:86`, `:284`; `neglect_note` `:300-303` → `build_bar.gd:135-142` (`_tip`) | 30 açık hata 4 hafta sürerse itibar düşer; DESTEK kartının ipucu yalnız düşüşten sonra nedeni yazar, eşiği yazmaz. | × k; ipucu eşiği sayıyla yazar (Karar 15). | D7 | C |
| O6 `_regression_line` | `incident_system.gd:351-366` | `:369-378` (`faulty` `:374`) | Kapanan sürümün `faulty` listesinden kritik hat. | Kaçan hatanın hatları. | D3 | yok |
| O7 Hazard | `:76` | `hazard` `:83-86`, `load_mult` `:75-78` | Açık hatayı (en çok 12) olasılığa katar. | Hacim D0b tabanıyla yan yana. | D3 (ölçüm D9) | C |
| O8 B2B memnuniyeti | `b2b_sales_system.gd:155-156` | `:155-158` (`B2B_BUG_SAT_*` `b2b_constants.gd:72-73`) | Hedef = hesap uyumu − min(açık hata × 0,3, 20). | C3a kaldırır; D ölçeklemez. | — (C3a) | C3a |
| O9 `account_bugs` | `:171` | `:173-180`; `COMPLAINT_BUG_GATE` `b2b_constants.gd:70`, okuyan `b2b_sales_system.gd:625` | Hesabın hatlarındaki açık hata. | C3a'nın satırı yerini alır. | — (C3a) | C3a |
| O10 `focus_mult` | `hr_constants.gd:184-185` | `:184-185` | Tek iş 1, iki iş 0,5. | `_share` içinde kalır. | D1b | yok |
| O11 `MAX_JOBS_PER_PERSON` | `:142` | `:142` | Kişi başına iki iş. | Matris uyarısı. | D5a | yok |
| O12 `can_hold_area` | `:253` | `:253-260` | Çalışan ana ya da ikincil alanında, kurucu her alanda. | Uyum tablosu. | D2a (park) | yok |
| O13 Uymayan iş morali | – | `hr_morale_system.gd:186` (`apply_delta`), `character_registry.gd:614` (`set_morale`) | Huy ve liderlikle ölçekli moral değişimi. | Uymayan işin her haftası −2. | D2a (park); D5a (uyarı metni) | yok |
| O14 Atlas | `hr_atlas_modal.gd:343` | `:387-392` (`points_for` `:390`) | "Sprintte haftada {pts} puan" (`HR_ATLAS_WEEK_POINTS`, `strings.csv:417`). | D1'de sayı ×5; D5a'da aşama hızları. | D1 (görünür), D5a | yok |
| O15 `release_clock` | `time_manager.gd:359` | `:359` | Tutuşu bırakır. | Yalnız `sync_plan_hold` çağırır. | D8b | yok |
| O16 Görevler matrisi kapısı | – | `character_registry.gd:204-205`, `hr_constants.gd:121-131` (`"test": ["qa"]` `:123`), `job_coefficient` `:166`, `can_hold_job` `:180` | Test işi yalnız `qa`; PM ve Tasarımcı Test kutusunu açamaz. | Uyarı D5a; kutunun açılması A4'ün K6'sı. | D5a; D2a (park) | yok |
| O17 Huy | – | `hr_constants.gd:407-411` (OKUYUCUSU YOK yorumları), `trait_mult` `:529`, `hr_system.gd:376` (`effective_skill`) | `bug_rate_mult` okuyucusuz; `speed_mult`/`output_mult` yalnız `effective_skill`. | Hız D1b, hata D3; Özenli/Aceleci D5b. | D1b, D3; D5b (park) | yok |
| O18 Kurucu toplantı payı | – | `game_state.gd:415-425`, `time_manager.gd:152`, `:177`; okuyucular `rnd_system.gd:116`, `:183`, `:447`, `research_bar.gd:70`, `:78` | Haftanın toplantı saati ÷ 40, yalnız Ar-Ge. | Sprint payı 1 − bu (Karar 5). | D1b | yok |
| O19 `SprintBridges.tick_requests` | – | `sprint_bridges.gd:22-56` (`continue` `:49`, son tarih `:55-56`) | Her B2B hesaba talep açar. | İstek kartı ertelendi. | D8d (ertelendi) | C6 |
| O20 `_unhappy` | – | `sprint_bridges.gd:303-315` | `faulty` doluysa yorum "güncellemeyi suçlar". | Gönderilen bilinen hata. | D3b (park) | yok |
| O21 `thank`, `_thanks_candidates` | – | `:189-200`, `:216-232` | `shipped`'e göre teşekkür. | Bırakılan söz kartı. | D3b (park) | yok |
| O22 `worked`, `role_of` okuyucuları | – | `hr_system.gd:84`, `:231`, `support_system.gd:230` | Deneyim bonusu, kurucu "plan" etkinliği, Destek doğrulama. | Atama tanımı aynı kalmalı (K5). | D2a (park) | yok |
| O23 `ProductLines.effort_of` | – | `product_lines.gd:341-347` | Katalog eforu (5/7/10), sprint eforundan ayrı. | ×5'ten etkilenmez; yeni kod terimi gidince yalnız doğrulamada. | D3 | Q bitti |

## 5. Olay motoru

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| E1 `sprint_card_test` | `effects.gd:482-487` | `effects.gd:485-488` | Kalan testi `cut_test` ile yarıya indirir. | Yakalamayı orantılı düşürür. | D3 | yok |
| E2 Çip `EFFECT_TEST_CUT` | `chips.gd:114-119` | `chips.gd:114-118`, `strings.csv:2796` | "{card}: test işi yarıya iner". | Çip yakalamaya göre. | D3 | yok |
| E3 Öbür sprint fiilleri | – | `effects.gd:476-514`; çipler `chips.gd:91-135` | `sprint_card_effort/progress/carry/trim/outlook/first`, `sprint_hours`, `sprint_fix_first`. | Kart miktarları ×5 (D1, §12.5); `effort_mod` karşılığı K13. | D1 | yok |
| E4 Seam `urun.decision_test_half` | `seams_product.gd:273-274` | `:255-256` (`SprintSystem.decision_test_half` `:504-508`) | Kalan testin yarısı (puan). | ×5 kendiliğinden; `shares` okuması D1'de değişir. | D1, D3 | yok |
| E5 Seam `urun.sprint_has_tester` | `:198-202` | `:192-196` | Takımda kurucu olmayan Tester var mı. | Anlamı karar gerek. | D3 | yok |
| E7 Seam `urun.sprint_last_week` | `:43` | `:42-44` | `week() == sprint_weeks()`; açıklama "the only week of a one-week one". | Açıklama güncellenir. | D1 | yok |
| E8 Kâğıtlar | 4 kart | `data/events/cards/product/` | 44 kâğıt `decision.cards`'ta; puan taşıyan 34 dosya, 47 sabit miktar + 9 seam'li kullanım; 5 dosyada 6 puan eşiği. | Hepsi ×5 (§12.5). | D1 | C3a (`trust_delta`) |
| E9 `team.demo_day` | `team/demo_day` | `data/events/cards/team/demo_day.json`; isteyen tek yer `sprint_system.gd:165-166` | Sessiz taban kartı (`tags: quiet`, `cooldown_weeks` 8), koşulu `hr.headcount ≥ 3`, sprint koşuyor, `urun.sprint_last_week`; günlük havuzdan da gelir. | 1 haftalık dal silinince istek kalkar; kart 2. haftada taban havuzundan gelmeye devam eder. PRD "2. haftanın başında istenir, kâğıt gelen sprintte gelmez" [onay bekliyor] (§12.3). | D1 | yok |
| E10 Konuşan bağlamı | `_speaker` | `scope.gd:240-249` (`sprint_dev`), `lint.gd:59` (`PAPER_SPEAKERS`) | Konuşan `EventGate.request(id, {employee/founder})`. | Karar 4; PM konuşanı K9. | D2a (park) | yok |
| E11 Gönder sorusu | – | yok | – | Yeni kâğıt. | D3b (park) | C5 |
| E12 `payers` okuyucuları | – | `effects.gd:495`, `:744-757`; `chips.gd:137`; `seams_incident.gd:22-23`; `scope.gd:246` | Kilit, moral bedeli, `solo` çipi. | Düzeltme ve PM. | D3, D4 | yok |
| E13 `sprint_fix_first` | – | `effects.gd:497-501` | Düzeltme kartını başa alır. | Kayan kart çekme sırasında. | D2b | yok |
| E14 Puan seam'leri (yeni satır) | – | `seams_product.gd:54-57` (`urun.decision_card_effort`), `:154-156` (`decision_card_done`), `:263-264` (`paper_phone_points`), `:282-293` (`colors_*`), `_colors_points` `:311-313` | Kâğıt koşulları ve miktarları puan okur. | Seam'ler kendiliğinden ×5; kartlardaki sabit eşikler ×5 (§12.5). | D1 | yok |

E6 (`urun.paper_tester_week`) silindi: Q K16 seam'i kaldırdı.

## 6. Arayüz

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| U1 `sprint_panel.gd` `_center` | `:65` | `:65-170` | Merkez sütun. | Şerit, darboğaz, kişi yükü. | D6 (park) | yok |
| U2 Süre seçicisi | `:75-81` | `:76-81` (`lengths` `:78`, eylem `weeks` `:81`); aktifte `PRODUCT_WEEK_OF` `:74-75` kalır | Planlamada `UiFactory.D_seg_pick`. | Silinir; planlamada başlık meta'sı kalır mı (boş) D1'de seçilir. | D1 | yok |
| U3 Ekip satırı | `:96`, `_member` `:201-210` | `:93-96`, `_member` `:201-210` | Yüzler ve sprint payı. | Aşama özeti. | D6 (park) | yok |
| U4 `_lead_row` | `:386` | `:386-400` | Önerinin satırı. | Tek öneri satırı. | D8a; ekran D6 (park) | yok |
| U5 `sprint_card.gd` | atama satırları | `:104-106` (rol glifleri), `_phase_row` `:241-262` (atananlar `:260`), `_effort` `:301-316` (`PRODUCT_WEEKS` `:310`) | Kart yüzü ve efor dökümü. | Hazırlık ve ekip satırları. | D6 (park) | yok |
| U6 `product_model.gd` `weeks`, `lengths` | `:299` | `:312-313` (yorum `:42`) | `weeks: sprint_weeks()`, `lengths: cfg("sprint_lengths")`. | `lengths` silinir. | D1 | yok |
| U7 `_quarter` | `:411-434` | `:424-447` (`locked_no_pm` `:425-426`, `quarter_weeks / sprint_weeks` `:444`) | PM yoksa kilitli. | PM'siz açılır (K22). | D8b | yok |
| U8 `_goal` | `:439` | `:452-459` | Hedef şeridi. | PM'siz hedef. | D8b | Q bitti |
| U9 `delegate` ve uyarılar | – | `:327` (`delegate`), `:295` ("Test rolü eksik"), `:298` (boşta) | PM yoksa `delegate` null. | Devret kilitli görünür (D8b); uyarı yeni şekle (D6). | D8b; D6 (park) | yok |
| U10 `quarter_view.gd` | `:83`, `:111-137` | `_goal_strip` `:83-106`, `_open_goal_menu` `:111-139` | Hedef menüsü. | Alanlar ve "Hatalar". | D8b | yok |
| U11 `product_tab.gd` eylemler | `:252-275` | `_act` `:277-306` (`weeks` `:287`, `delegate` `:284`) | Eylemleri `SprintSystem`'e iletir. | `weeks` silinir (D1); devret (D8b). | D1, D8b | yok |
| U12 `_build_ctl` | – | `:219-238` (ÇEYREK kilidi `:230-231`, devret anahtarı `:235-238`) | PM yokken ÇEYREK kilitli (`PRODUCT_QUARTER_NEED_PM`, `strings.csv:2658`). | Kilit kalkar. | D8b | C6 |
| U13 Ofis `role_of` | – | `office_people.gd:41` (`SPRINT_WORK`), `:97` (kickoff), `_work_of` `:666-669` | `SPRINT_WORK[role_of]`. | Yeni durum `KeyError` (K5). | D3, D4; D2a (park) | yok |
| U14 Görevler matrisi | – | `hr_assignments.gd:106-128` (`_cell`) | "Alanın değil" ve iş tavanı kilidi; uyarı yok. | Uyarı satırı. | D5a | yok |
| U15 `plan_outcome` tüketimi | – | `product_model.gd:134`, `:272-273`, `:287` (`shares`) | `effort_split`, `spills`, `no_start`, `phase_pts`. | `phase_pts` D1'de ihtiyaçtan; çekilen kart D2b. | D1, D2b; D6 (park) | yok |
| U16 Mesai modalı | – | `work_hours_modal.gd:217-218`; `HR_HOURS_SPRINT_POINTS*` `strings.csv:614-615` | "Haftalık sprint puanı {before} → {after}". | D1'de sayı ×5; anlam (M3) karar gerek. | D1 (görünür) | yok |
| U17 `product_fixtures.gd` | – | `:239-240` (`weeks` eylemi), `:606` (`"lengths": [1, 2]`, `capacity` 12) | Debug fikstürü. | `weeks`/`lengths` silinir (D1); fikstür sayıları ×5 (D1); `edge:` adları D6. | D1; D6 (park) | yok |

## 7. Araçlar

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| T1 `_plan_the_sprint` | `run_probe.gd:963-1003` | `run_probe.gd:1269-1306` (`_plan_promises` `:1280`, `_keep_building` `:1295`, `capacity` `:1306`) | Bot: tür, yayın, `plan_next`, sözler, ücretli plan, `apply_lead`, düzeltme kolu, K1 kısıtı, araştırma, başlat. | Yalnız öneri; eylem sayısı. | D8a | C (kirli fark) |
| T2 Düzeltme kolları | `:1006-1040` | `_plan_fix_arm` `:1312-1337` (`DUE_BUGS` `:334`, `:1321`) | `fix_none/worst/due/off`. | Kalır; `DUE_BUGS` × k (D7). | D8a, D7 | yok |
| T3 Bot elle seçimleri | `:1045-1075` | `_keep_building` `:1359-1369`, `_plannable` `:1373-1374`, `_plan_promises` `:1379-1390` | Söz, araştırma yanı, K1 kısıtı. | Silinir. | D8a | yok |
| T4 `PROBE FIX` | `:347` | `:523`, `_fix_ledger` `:528-537` | `weeks=%d` (`sprint_weeks()`), `fix_load`, `capacity`. | `weeks=` hep 2, alan kalır (baytlar aynı); `fix_load`/`capacity` ×5. | D1 | yok |
| T5 Bot cevap politikası | – | `_drain_modals` `:942-993`, `_pick_choice` `:996-1042` | Kâğıtta ilk açık satır. | Gönder sorusu politikaları. | D3b (park) | yok |
| T6 `sprint_probe.gd` | fikstürler, `PRED`/`CLOSE` | başlık `:3-62` (`weeks=` `:4`, `:10`; "for either sprint length" `:41-42`), `chance` gezmesi `:103-105`, `weeks=` uygulaması `:125-126`, `LOADSUM`/`PAPERSUM` `:156-160`, `CLOSE` `:176`, `PRED` `:224-225`, `_seat` `:252-266` (`RunProbe.seed_crew` `run_probe.gd:2347-2366`, `seed_hire` `:2370-2379`), `_example_cards` `:273-284`, `_plan_ms` `:287-298`, `PLANMS` `:316`, `_count_idle` `:383-390`, `REPRED` `:427` | D0a'dan beri 1–6, 12, 25, 50 kişi, `tstar`, `pmstar`, `plus`, `founder`, `fixture=iz1|iz1b|iz2`, `build`, `planms`. | `weeks=` kalkar ve sözlük gezmesi tek anahtara (D1); çekilen kart (D2b); n, F, K, Düzeltme işi (D3); atananlar (D2a). | D1, D2b, D3; D2a (park) | D0a bitti |
| T7 Fikstür `main.gd` | `main.gd:3556` | `_stage_emergency` `:882-` (`sprint_chance` `:887-889`, `fix_effort.points` `:890`, `release.faulty` `:909`); `_seed_promise_world` `:995-` (`team()` `:1010-1012`, `effort = 100` `:1014`, `shares` `:1015-1016`); `_seed_product_live` `:3847-` (`week1` `:3883-3884`, `:3886`, `:3888`; `sprint_chance` `:3893-3895`); `live:week1` adımı `:3750`, yorumlar `:3702`, `:3827`, `:3835`; `fix:` `:1066` | Fikstürler sprint anahtarlarını ezer. | `week1` silinir, öbürleri yeni anahtara (D1); `faulty` (D3). | D1, D3 | C |
| T8 Smoke: `faulty` vakaları | `endgame_smoke.gd:479-480` | dispatcher `:502-503`; gövde `:20834`, `:20891`; `incident_regression_fixture` `:345` (gövde `:17987`, `faulty_chance = 1.0` `:17992`), `_close_faulty` `:18002-18008` | Sürüm sonrası bozulma ve kartın hattı. | Yeni modele (`sprint_escaped_bug_on_card_line`). | D3 | yok |
| T9 Smoke: `set_weeks` | 6 yer | 7 yer: `_promise_world` `:21846`, `_late_world` `:22643`, `sprint_decision_card_fires_shipped` `:22234`, `paper_speaker_is_assignee` `:22779`, `decision_no_fourth_show` `:22893`, `paper_empty_sprint_ratio` `:23002`, `_paper_world` `:23031` | Süre 1 ya da 2. | Tek süre (§12.3). | D1 | yok |
| T10 Smoke: `sprint_chance` | 7 yer | `_paper_chance` `:20388-20390`, `quiet_cards_fill_empty_floor` `:22161-22163`, `sprint_decision_card_fires_shipped` `:22208-22242`, `sprint_late_for_requests` `:22667-22703`, `_paper_pool` `:22718-22720`, `_paper_pool_end` `:22727-22730`, `paper_empty_sprint_ratio` `:23000` | Sözlüğü gezer, kopyalar, geri yazar. | Tek anahtar. | D1 | yok |
| T11 Smoke: anahtar yazımları | – | `faulty_chance` 17 satır (`:17990-17997`, `:20837-20882`, `:20894-20929`, `:21970-21994`, `:22444-22456`); `founder_roles` 10; `decision.cards` 17; `cut_test_escape` 9; `person_points_week`, `founder_mult`, `skill.mult` `:20478-20480`, `:20523-20525`; `no_role_speed` `:21854`, `:22651`; `fix_effort` `:18223`, `:20947`, `:20957` | `SprintCatalog._data.<anahtar>` yazımı. | Silinen/değişen anahtar aynı commit'te taşınır. | D1, D3, D7 | yok |
| T12 Smoke kapsamı | `:472-538` | dispatcher `:79-583`; `sprint_` 24, `paper_` 14, `promise_` 13, `decision_` 2, `save_` 19 | – | §12.6. | D1–D8 | yok |
| T13 Ölçüm betikleri | – | `d_taslak/olcum/` | `PROBE FIX`, `SPRINTPROBE` okur. | Alan değişirse D9. | D9 (park) | yok |

## 8. Kayıt ve belgeler

| Öğe | PRD'deki yer (889b9b8) | HEAD dosya:satır | Bugün ne yapıyor | D'de ne olur (PRD Kararı) | Sahip adım | Q/C |
|---|---|---|---|---|---|---|
| B1 Şema | `save_manager.gd:16` | `:16` (`SCHEMA_VERSION := 18`), `:23` (`MIN_LOADABLE_VERSION := 10`) | 18. | İlk inen alır: D1 önce inerse 19 (ADIM §0). | D1 | C3a |
| B2 Göç zinciri | – | `:194-205` (`if version < 18: _migrate_17` `:204-205`) | Ad kaynak sürümü taşır. | `if version < 19: _migrate_18`. | D1 | C3a |
| B3 `_migrate_15` | – | `:817-900` (`cfg("effort.k%d")` `:863`, tasarım indirimi `:864-865`, `new_card` `:866`, `shares` `:868`, sürümler `:876`, `new_state` `:882`) | v14 yapımını sprint kartlarına çevirir. | K12 (§12.2). | D1 | yok |
| B4 Sürüm kayıtları | – | `sprint_system.gd:1493-1498` (`velocity` `:1413`, `carried.total` `:1495`) | `shipped` anlık görüntüleri, `velocity`, `carried`, `faulty`. | Eski ölçekte kalır (K12); taşan aşama ve sayaç alanları varsayılanla (D1). | D1 | yok |
| B5 `reset_all_owners` | – | `save_manager.gd:324`; `ProductSystem.reset` `product_system.gd:11` | Statik durumu sıfırlar. | Plan önbelleği. | D2c (park) | yok |
| B6 `HARITA.md` | Ürün, Ekip | Kayıt `:27-44` (`:39`), UI kiti `:67` (`D_seg_pick` "Ürün'ün sprint süresi"), Ürün `:139-165` (`:147` kâğıt fırsatı, `:164` `--sprint-probe`), Ekip `:182-200`, Araçlar `:380-395` | – | Her adım kendi satırını. | her adım | C |
| B7 `CLAUDE.md` | §6 | §6 "Söz olayı" `:115-120`, "Karar kâğıdı" `:121-122` ("1 haftalık sprintte başlarken"), Kayıt `:178`; §12 sprint planı `:289-290` (`weeks`), ürün çekimi `:336` (`week1`) | – | D1 sabit 2 hafta; D3 yakalama. | D1, D3 | C5/C6 |
| B8 ZAMAN MODELİ | `:211` | `GDDs/GDD — ZAMAN MODELİ.md:211` | "1 ya da 2, varsayılan 2". | Sabit 2. | D1 | yok |
| B9 `GUNCELLEMELER.md` | `:223`, `:345` | `:218` (sprint süresi kuralı), `:229` (`sprint_lengths`), `:357` (`sprint_chance` 1/2 haftalık) | – | Güncellenir. | D1, D3 | yok |
| B10 Motor md | §27 | `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md:2754-2756` | Kâğıt fırsatı ve `{"1": 0,3, "2": 0,5}`. | Tek anahtar. | D1 | yok |
| B11 `ISLER.md` | – | `:62-64` | Yalnız "sprint puanı liderliği ve koordinasyonu okumaz (ACIK 96)" kaldı; "iş ataması ve odak" satırı Q K13'te silindi. | D1b doğruluğunu korur. | D1b | Q bitti |
| B12 Ekip GDD Test alanı | Ekip GDD | `.docx` | İkincil 0,8 gerekçesi. | K4. | D1b (ACIK'a yazım) | yok |
| B13 CSV | W, §3 | `EFFECT_TEST_CUT` `:2796`, `HR_ATLAS_WEEK_POINTS` `:417`, `HR_HOURS_SPRINT_POINTS*` `:614-615`, `PRODUCT_WEEKS*` `:2563-2564`, `PRODUCT_WEEK_OF` `:2565`, `PRODUCT_DELEGATE` `:2652`, `PRODUCT_QUARTER_NEED_PM` `:2658` | Puan tek sayı. | Metinler W2'den. | D5a, D8b, D3; D6 (park) | yok |
| B14 Üretilmiş belgeler | – | `_vocabulary.md`, sinyal manifesti | – | Yeni kart üretimle. | D3b (park) | yok |

## 9. Kopukluk riskleri (HEAD satırlarıyla, adıma göre)
En ağırdan. Her riskin sonunda düştüğü adım.

**K1. `team()` sözlüğünün şekli on yerde okunuyor.** Okuyucular: `incident_system.gd:300-307` (`_builder`: `member.fits.has("dev")`, `:303`),
`:567` (`_fix_minutes`: `founder`), `effects.gd:384-385` (`productivity_mod`), `seams_product.gd:192-196`, `main.gd:1010-1012`
(`ahead`, `fits`, `points`), `office_people.gd:97`, `product_model.gd:251`, `:295` (`"test" in t.fits`), `:298`, `sprint_probe.gd:274`,
`:289`, `:390`, `:396`; motorun içi `:735`, `:1131-1138`, `:1157`; smoke 13 çağrı (`:20411`, `:20597-20608`, `:20647`, `:20840`, `:21852`,
`:21860`, `:22649`, `:22678`, `:22823-22825`). D1b yalnız `points`'in değerini değiştirir, şekil aynı kalır. **→ D1b (değer), D2a (şekil, park).**

**K2. `capacity()` tek sayı, kapı.** `sprint_system.gd:151` (`_begin`), `:587` (`awaits_plan`), `:745` (`can_add`), `:765` (`can_start`),
`:805` (`mvp_eta`), `:1053` (`fits_plannable`), `:1390` (`_auto_start`); `sprint_catalog.gd:478`, `:507`, `:560`; `product_model.gd:250`,
`:429`; `run_probe.gd:1306` (HEAD) ve `_fix_ledger` `:528-537`. PM `JOB_BUILD` ile takıma girip puan taşıyor (`hr_constants.gd:190`
`AREA_PRIMARY_JOB`). ×5'te `> 0` kapıları değişmez. **→ D1 (ölçek), D4 (PM'in puanı), D2a ve D6 (park).**

**K3. Görevler matrisi PM ve Tasarımcıya Test kutusunu açmıyor.** `hr_constants.gd:123` (`"test": ["qa"]`), `job_coefficient` `:166`,
`can_hold_job` `:180`; `hr_assignments.gd:106-128`; `character_registry.gd:204-205` (`not_your_job`). `_fits` ikincili tam uyum sayıyor
(`sprint_system.gd:1715`). A4'ün K6'sı (park) açılmadıkça uymayan iş yalnız kurucu ve Geliştirici/Testçi çaprazındadır.
**→ D5a (uyarı metni yalnız açılabilen kutuda), D1b (U 0,7), D2a (park).**

**K4. İki ikincil alan katsayısı.** `HRConstants.SECONDARY_AREA_MULT = 0,8` (`hr_constants.gd:236`; `area_fatigue_mult` `:293`;
okuyucular `hr_system.gd:366`, `:386`) ve Karar 2'nin 0,7'si. GDD metni (docx) bu turda yeniden okunmadı. **→ D1b:** U'yu yazan commit
`ACIK_KARARLAR.md`'ye ayrılığı yazar.

**K5. `role_of` altı okuyucu.** `office_people.gd:666-669` (`SPRINT_WORK` `:41`, dört anahtar), `hr_system.gd:84` (`worked`), `:231`,
`support_system.gd:230`, `product_model.gd:298`, `_speaker` `sprint_system.gd:1254`. `ahead` (`team()` `:719`) hem PM'in hem tasarımcının
faz-0 işini taşıyor (`_ahead_cards` `:1613-1615`, `ready_share` `:675-678`). **→ D3 (Düzeltme "dev" döner), D4 (PM hazırlığı ayrı durum;
`SPRINT_WORK`'te `product` var), D2a (park).**

**K6. `_restaff` ayrı atama yolu.** `:1352-1360`; çağıranlar `remove` `:122`, `decision_carry` `:404`, `_on_team_changed` `:1329`. **→ D2a (park), §14.**

**K7. `_work`'ü sahte kişi sözlüğüyle çağıranlar.** `decision_progress` `:365` (`{"fits": roles, "ahead": false}`, `points` yok);
`_finish_sprint` `:910-919` (`by_id[id]`). D1b `_work`'ün hız hesabına U ya da huy koyarsa sahte sözlükte alan yok: varsayılan gerekir.
**→ D1b; D2a (park).**

**K8. `release.faulty` dört okuyucu.** `incident_system.gd:374` (`_regression_line` `:369-378`), `sprint_bridges.gd:304-306` (`_unhappy`),
`run_probe.gd:515-517` (HEAD, `PROBE SHIP`), `main.gd:909` (fikstür); yazan `sprint_system.gd:1498`. `SprintBridges.thank` `:189-200`
`shipped`'e bakar. **→ D3; gönderilen bilinen hata D3b (park).**

**K9. PM kâğıdının konuşanı ile hazırlayan PM.** `_speaker` `:1250-1252` `quarter_pm()` (`sprint_catalog.gd:531-535`); aynı "ilk PM"
`delegated` `:593`, `pm_plans` `:550-572`, `product_model.gd:253`. **→ D4 (hazırlayan PM kartta), D8b (PM'siz), D2a (park).**

**K10. `payers` ve `sprint_dev` sırası `team()` alanlarına bağlı.** `payers` `:727-739` (`share`, `ahead`); okuyucular `scope.gd:244-249`,
`effects.gd:495`, `:751`, `:757`, `chips.gd:137`, `seams_incident.gd:22-23`. **→ D3 (Düzeltme ödeyenlere), D4 (PM).**

**K11. ×5 yüzeyi (kısmen kapandı).** Dolar × puan Q K14/K16'da kapandı. Kalan: 34 kart dosyası, 47 sabit miktar (42 `sprint_card_effort`,
1 `sprint_card_progress`, 4 `sprint_card_trim`), 9 seam'li kullanım, 6 koşul eşiği; `paper.reopen_points`, `phone_points`, `colors`;
`ask_silent_mult` ve `root_min` sayımdır. Ayrıntı §12.5. **→ D1.**

**K12. Göçte çift ölçek.** `_migrate_15` `save_manager.gd:863` `cfg("effort.k%d")` okur (D1'den sonra ×5), `:866` `new_card` çağırır (D1
şeklini değiştirir), `:868` `card.shares` okur (D1 siler: v14 kaydı **çöker**). Ardından `_migrate_18` (zincirde `version < 19`) bir kez daha
×5 yapar. `releases[].shipped`, `velocity` (`:1413`), `carried.total` (`:1495`) eski ölçekte. **→ D1 (§12.2).**

**K13. `effort_mod`'un karşılığı tanımsız.** Yazanlar `:347`, `:431`, `:902`; okuyan `total` `:1676-1677`; `new_card` `sprint_catalog.gd:258`;
sınır `effort_change` `:354-356` (en az 1 puan). `shares` okuyanlar `sprint_system.gd:508`, `:661`, `:676-678`, `:929-930` (yazar),
`:1158`, `:1688`; `product_model.gd:287`; `main.gd:1015-1016`; `save_manager.gd:868`; `sprint_catalog.gd:182-191`, `:256`. Bir ±n'in hangi
aşamaya yazılacağı PRD'de yok. **→ D1; tasarım seçimi gerekirse ADIM §0b şart 2 (dur, park listesine yaz).**

**K14. Yeni kod terimi sekiz yerde.** `support_system.gd:37`, `:40`, `:81` (yorum), `:164-166`; `product_state.gd:39`, `:275-276`, `:282-288`;
`game_state.gd:77` (`mvp_new_code_effort`); `sprint_system.gd:298`, `:1428`, `:1449`, `:1465`, `:1529`, `:1569-1578`; smoke
`_seed_support_fixture` `:14426` (`refresh_on_publish(20.0)`; Destek vakalarının yardımcısı) ve `destek_empty_desk_piles_up` `:14444`.
**→ D3.**

**K15. Smoke, fikstür ve prob sprint.json anahtarlarını doğrudan yazıyor.** `faulty_chance` 17 satır/5 işlev, `founder_roles` 10,
`decision.cards` 17, `cut_test_escape` 9, `decision.sprint_chance` 7 işlev (T10); `fix_effort.points` `endgame_smoke.gd:18223`,
`main.gd:890`; sözlük gezenler `sprint_probe.gd:103-105`, `main.gd:887-889`, `:3893-3895`, smoke `_paper_chance` `:20389`.
**→ D1 (`sprint_chance`, `set_weeks`, puan anahtarları), D3 (`faulty_chance`, `cut_test_escape`), D7 (`fix_effort`).**

**K16. Süre seçicisinin listelenmeyen okuyucuları.** `product_model.gd:313` (+ yorum `:42`), `product_fixtures.gd:239-240`, `:606`,
`sprint_probe.gd:4`, `:10`, `:125-126`, `main.gd:3883-3888` (+ `:3702`, `:3750`, `:3827`, `:3835`), `product_tab.gd:287`,
`sprint_panel.gd:76-81`, `HARITA.md:67`, `CLAUDE.md:336`, `:289-290`. `PRODUCT_WEEKS*` (`strings.csv:2563-2564`) seçicinin değil:
`sprint_card.gd:310` de okur, silinmez. **→ D1.**

**K17. Kurucu toplantı payı sprinte bağlı değil.** `game_state.gd:415-425`; sayaç `time_manager.gd:152` (08:00), `:177`; yalnız Ar-Ge okur
(`rnd_system.gd:116`, `:183`, `:447`, `research_bar.gd:70`, `:78`); `_share` `:1738-1740` okumaz. `_end_week` 00:00'da: biten haftanın payı
okunur, plan ekranı gelecek haftayı bilemez (adlı uyuşmazlık). ACIK 96 (6) bunu karar diye yazıyor (N1). **→ D1b.**

**K18. Huy sprintte bağlı değil.** `hr_constants.gd:411` (`bug_rate_mult` OKUYUCUSU YOK), `trait_mult` `:529`, `hr_system.gd:376`
(`effective_skill`); `_points` `:1729-1733` huy okumaz. **→ D1b (hız), D3 (TİTİZ hata), D5b (Özenli/Aceleci, park).**

**K19. İki "boşta".** `hr_system.gd:293` (`is_idle`), `:311` (`is_waiting`), `seams_hr.gd:135` (`hr.idle_count`) ve sprintin boştası
(`product_model.gd:298`, `sprint_probe.gd:383-390`). **→ D6 (park).**

**K20. Düzeltme kartının kimliği `fix:<hat>`.** `sprint_catalog.gd:226`, `sprint_system.gd:212`, `:238-241`, `seams_product.gd:208`,
`main.gd:1066`, `run_probe.gd:1326-1330` (HEAD), `sprint_probe.gd:377`. C'nin Genel Bakış bağı henüz yok. **→ D7.**

**K21. Mutlak hata eşikleri k'siz.** `sprint.json:49`, `:63`, `:73`, `:82`; `incident_system.gd:83-86`; `run_probe.gd:334` (`DUE_BUGS`).
`NEGLECT_BUGS` `support_system.gd:86`, `:284`. **→ D7 (yalnız `NEGLECT_BUGS`, `DUE_BUGS`, `SLIP` eşikleri, ölçüm hedefleri).**

**K22. PM'siz çeyrekte PM'e bağlı parçalar.** `sprint_catalog.gd:551-552`, `product_model.gd:425-426`, `product_tab.gd:230-231`,
`product_model.gd:327`. **→ D8b.**

**K23. `tick_requests` iki fazın ortak noktası.** `sprint_bridges.gd:22-56` (`:49`, `:55-56`). **→ D8d (ertelendi); C6.**

**K24. Plan hesabı üç yerde çarpılıyor.** `_takes` `:753-760` → `_play_out`; `_suggest(played)` `sprint_catalog.gd:903-911`
(`plan_outcome` `:905`); `ProductModel._center` `plan_outcome` `:134`, `mvp_eta` `:256`, `lead_suggestion` `:293`. D0a ölçtü (`PLANMS`,
`sprint_probe.gd:287-298`): 50 kişide ekranın tam kurulumu ortanca 68 ile 74 ms, en çok 96 ms. **→ D8a (öneri döngüsü süresi), D2c (park).**

**K25. Çok PM ve tek `delegate`.** `new_state` `:84`, `set_delegate` `:286-288`, `delegated` `:592-593`: başka PM kalırsa devir kalır (bugünkü
davranış). **→ D8b (korunur).**

**K26. `incident.fix`.** `sprint.json:53-56`; `_fix_minutes` `incident_system.gd:566-579`. **→ park (karar gerek).**

**K27. Yeniden yazılmış hat bağışıklığı.** `_close` `:1450-1454` (`line_blocked` `product_state.gd:230-231`); `harden_line` `:235`,
fiil `effects.gd:516-519`. **→ D3.**

**N1. ACIK_KARARLAR 96'nın iki maddesi D'nin kararlarıyla değişiyor.** `docs/ACIK_ISLER/ACIK_KARARLAR.md:905-925`: (4) `:913-915` "uymayan
fazda %50 hız, testsiz biten kart hatalı" (Karar 2 ve 6), (5) `:915-920` sprint ekibi ve payı, (6) `:920-922` "kurucunun satış toplantısı sprint
kapasitesini düşürmez" (Karar 5). Kodu değiştiren commit ACIK ve GUNCELLEMELER satırını aynı commit'te günceller. **→ D1b ((5), (6), U kısmı
(4)), D3 ("testsiz biten kart hatalı").**

**N2. Kâğıt havuzu 44 ve üç B2C PM kâğıdı ölü.** `sprint.json:40` `decision.cards` 44 kimlik (PRD/D0t 46). `urun.decision_request_votes`
sabit 0 döner (`seams_product.gd:241-243`); `sprint_pm_core_first.json:58`, `sprint_pm_phone_too_b2c.json:58`,
`sprint_pm_spec_unclear_b2c.json:58` `>= 1` ister: oyunda gelmezler (kodla doğrulandı). İkisi puan taşır (§12.5); D1 onları da ölçekler,
yoksa havuz açıldığında yanlış ölçekle gelirler. `sprint_late*.json` aynı seam'i yalnız gövde varyantı için okur. **→ D1 (ölçek); kart yenilemesi.**

**N3. Planlayıcıda özyineleme ve tek yol.** `_play_out` `:1171-1193` → `_assign` `:1178`; `_outcome` `:781-794` → `_play_out` `:785`;
gerçek hafta ise `_end_week` `:1078-1104` `_work`'ü doğrudan (`:1090`), atamayı `_staff_week` `:1109-1112` ile yapar. Seçenek oynatma içinde
yeniden karar vermemeli (seçim parametreyle aşağı taşınır); tahmin = sonuç için gerçek hafta ile oynatma aynı atama girişini kullanmalı.
**→ D2a, D2c (park).** D2b'nin çekmesi bugünkü motorda iki yola (oynatma ve `_end_week`) aynı işlevle yazılmalı.

## 10. Kayan satırlar
PRD'nin refleri `889b9b8`'e göredir; tablolar PRD sütunuyla HEAD sütununu yan yana taşır.
- `sprint_system.gd`: `fc6b392`'ye göre `:1528`'e kadar aynı, sonrası −1 (`_land_faulty`, `sync_plan_hold`, `_refresh_fix_cards`, `total`,
  `phase`, `_role`, `role_of`, `_fits`, `points_for`, `_points`, `_share`). PRD'ye göre −9/−10 kayma D0t'nin ilk hâlindeki gibi.
- `sprint_catalog.gd`: Q −9 ile −32 (ör. `new_card` `:262`→`:253`, `candidates` `:212`→`:198`, `_suggest` `:884`→`:873`, `quarter_pm`
  `:563`→`:531`).
- `product_model.gd` +12/+13 (`:299`→`:312`, `:411`→`:424`); `product_tab.gd` +25/+31 (`:262`→`:287`, `:199`→`:230`).
- `main.gd`: `:808`→`:887`, `:869`→`:1010`, `:3556`→`:3884`. `run_probe.gd` (HEAD): `:963`→`:1269`, `:347`→`:523`. `sprint_probe.gd` D0a'da
  yeniden yazıldı (T6). `endgame_smoke.gd`: `set_weeks` `:19953`→`:21846` vb.; dispatcher `:79-583`.
- `strings.csv`: Q silmeleriyle `EFFECT_TEST_CUT` `:3004`→`:2796`, `HR_ATLAS_WEEK_POINTS` `:426`→`:417`, `HR_HOURS_SPRINT_POINTS*`
  `:636-637`→`:614-615`.
- `GUNCELLEMELER.md` `:223`→`:218`/`:229`, `:345`→`:357`; motor md `:2751-2756`→`:2754-2756`.
- `effects.gd` `:383`→`:384` (C2c); `save_manager.gd` `_migrate_15` `:861`→`:863`.

## 11. PRD'de olup kodda bulunamayanlar (HEAD)
1. **Çip metni.** PRD'nin "Hesap Planı'nın testi yarıya iner." metni kodda yok; bugünkü `EFFECT_TEST_CUT` (`strings.csv:2796`).
2. **İş profili payları.** `work_profile` var (kapandı); ama profil → aşama payı tablosu veride yok, yalnız `D_MODEL_v3` §3.2'de
   (K1 15: 5/7/3, 2/10/3, 2/8/5; K2 25: 9/11/5, 4/16/5, 3/13/9; K3 40: 14/18/8, 6/26/8, 4/22/14; ücretli plan 2/10/3; araştırma yalnız Ürün 5).
   `D_MODEL_v3:1015` payları "v2'den onay bekleyenler" arasında sayıyor. D1 bu tabloyu `sprint.json`'a yazar (§12.4).
3. **`ProductQuality`.** Var (kapandı).
4. **Görevler matrisinde Düzeltme kutusu ve PM/Tasarımcı Test kutusu.** Yok (K3; A4'ün K6'sı park).
5. **"Aşama açılışı" atama anı değil.** Hafta ortası yeniden atama yalnız `_clear_decision` `:1310` ve `put_first` `:230`'da.
6. **PM hazırlığı, hazırlayan PM, `prep`.** Yok (D4).
7. **Gönder sorusu, bağlı kip, `held`.** Yok (D3b park).
8. **Kart başına n, F, K.** Yok (D3); D0a `PLANMS` ve ölçek fikstürlerini ekledi, `PRED`/`CLOSE` alanları aynı.
9. **`PROBE DECISION`.** Var (C9a) — kapandı.
10. **İstekleri yalnız 3★ ve üstü.** Yok (C6, K23).
11. **Devret önerisi.** Düştü (ADIM §3) — madde kalkar.
12. **`release_clock` neden listede.** Hâlâ yalnız `sync_plan_hold` çağırıyor.
13. **Düzeltme faz payı 0/0,7/0,3.** Bugünkü `shares.fix` zaten öyle (`sprint.json:11`); D1 türden okur.

## 12. D1 ayrıntılı listesi (kod ajanı için)
Kapsam ADIM_TABLOSU satırı D1. Her madde HEAD satırıyla. "Tuzak" işaretli yerler D0v'nin bulduğu, tabloda yazmayan şeylerdir.

### 12.1 Şema ve göç zinciri
- `save_manager.gd:16` `SCHEMA_VERSION := 18` → 19 (C3a önce inerse 20; ADIM §0). `:23` `MIN_LOADABLE_VERSION` 10 kalır.
- Zincir `:194-205`; yeni kol `:205`'in altına `if version < 19: _migrate_18(state)`. Göç işlevleri `_migrate_17` `:969-989`'un ardına.
- Göçün işi (PRD §4.6): saklı kartın ihtiyacı tablodan, ilerleme aşama payıyla ×5; yarım testli kart testi baştan alır; `faulty`, `shares`,
  `effort_mod` düşer (`effort_mod` silinmeden önce eforun içine katılır); `sprint.weeks` düşer (koşan 1 haftalık sprint 2 haftaya uzar);
  `releases[]` için karar (K12, aşağı). Okunacak yerler: `GameState.product.cards` (düz sözlük, `game_state.gd:302`), `product.sprint`,
  `product.next`, `product.releases`. Kaydın kendi ürünü `flags.mvp_sub_product_type_id`'den okunur (`_migrate_17` `:979` deseni).
- Yeni varsayılanlı alanlar (göç yazmaz, okuyan `get` ile): kartta `keep`, Düzeltme (n, F, düzeltme işi, ilerlemesi), hazırlayan PM ve hazırlık
  ilerlemesi (D4); sürüm kaydında taşan aşama ve ardışık sayı (Karar 22). Yazım yeri `new_card` `sprint_catalog.gd:253-258`, sürüm kaydı
  `sprint_system.gd:1493-1498`.
- Belge: `HARITA.md:39` (Kayıt), `CLAUDE.md:178` ("SCHEMA_VERSION 18").

### 12.2 K12 tuzağı (`_migrate_15`)
- `save_manager.gd:863` `int(SprintCatalog.cfg("effort.k%d" % tier))`: D1'den sonra 15/25/40 okur.
- `:864-865` tasarım indirimi `maxi(1, roundi(effort × RND_DESIGN_EFFORT_MULT))` aynı ölçekten.
- `:866` `SprintCatalog.new_card(...)`: D1 kart şeklini değiştirir.
- `:868` `card.progress = [effort * card.shares[0], effort * card.shares[1] * done, 0.0]`: `shares` silinince v14 kaydı yüklemede hata verir.
- `:882` `SprintSystem.new_state(today)` (D1'den sonra `weeks`'siz: sorun yok).
- v14 kaydı zincirde önce `_migrate_15`, sonra `_migrate_18`'den geçer; ikisi de ×5 yaparsa çift. Tek ölçekleyici olmalı: `_migrate_15`'in eski
  sabitlerle (3/5/8, `[0,2, 0,6, 0,2]`) eski şekilli kart yazması ve dönüşümü yalnız `_migrate_18`'in yapması bir yol.
- Kanıt vakaları: `save_v14_build_becomes_sprint_plan` (dispatcher `:550`; `card_shares("feature")` ve `c.effort` okur `:23561-23573`),
  `save_v14_history_becomes_releases` `:551`, `save_v15_tickets_become_open_bugs` `:552`, `save_v15_callback_bugs_under` `:553`.
- `releases[].shipped` anlık görüntüleri `shares`/`effort_mod`/`faulty` taşır; `velocity` `:1413` ve `carried.total` `:1495` eski ölçekte.
  Geçmiş ve sürüm notu bunları okur: göç ya çevirir ya da okuyucular eski kartı `get` ile okur.

### 12.3 Sabit 2 hafta
Silinecek ve değişecek her yer:
- Motor: `set_weeks` `sprint_system.gd:320-328` (yorumu dahil); `_begin` `:164` `_staff_week(sprint_weeks() == 1)` → `_staff_week(false)`,
  `:165-166` `team.demo_day` dalı; `new_state` `:78` ve `plan_next` `:186` `"weeks"` alanı; `sprint_weeks()` `:612-613` cfg'yi okur;
  `_request_decision` `:1211` `decision.sprint_chance.<hafta>` okuması tek anahtara.
- Veri: `sprint.json:3` `sprint_lengths` silinir; `:40` `sprint_chance` `"1"` silinir (`"2": 0,5` kalır; sözlük kalırsa gezen 9 yer çalışır).
- Arayüz: `sprint_panel.gd:76-81` seçici (yorum `:77`); `product_model.gd:313` `lengths` ve yorum `:42`; `product_tab.gd:287` `"weeks"` eylemi.
- `team.demo_day` (Tuzak): bugün tek isteyeni `sprint_system.gd:165-166`; kart ayrıca günlük taban havuzundan gelir (`demo_day.json`
  `tags: quiet`, koşul `urun.sprint_last_week`), dal silinince 2. haftada havuzdan gelmeye devam eder. PRD'nin "2. haftanın başında istenir,
  kâğıt gelen sprintte gelmez" maddesi [onay bekliyor]: PRD'de yazılı (Erdem'in kuralı "PRD ne diyorsa"), yeni bir istek yeri gerekir;
  yazılmazsa raporda adıyla.
- Fikstür: `product_fixtures.gd:239-240` (`weeks` eylemi), `:606` (`"lengths"`); `main.gd:3883-3884` (`week1` → `set_weeks(1)`), `:3886`,
  `:3888`, `live:week1` adımı `:3750`, yorumlar `:3702`, `:3827`, `:3835` (`week1` türü silinir ya da sabit 2'ye anlam değiştirir);
  `main.gd:887-889`, `:3893-3895` sözlük gezmesi.
- Prob: `sprint_probe.gd:125-126` (`weeks=`), başlık `:4`, `:10`, `:41-42`; `:103-105` sözlük gezmesi; `LOADSUM`/`PAPERSUM` `weeks=` alanı
  `:156-160` kalabilir (hep 2). `run_probe.gd:523` `PROBE FIX weeks=` (HEAD) kalır, değer 2.
- Seam: `seams_product.gd:42-44` açıklaması.
- Smoke: `set_weeks` 7 yer (T9); `sprint_chance` 7 işlev (T10).
- CSV: seçicinin kendine ait anahtarı yok. `PRODUCT_WEEKS`, `PRODUCT_WEEKS_ONE` (`strings.csv:2563-2564`) `sprint_card.gd:310` de okur:
  **silinmez** (ADIM satırı "seçicinin anahtarları silinir" diyor; silinecek anahtar yok). `PRODUCT_WEEK_OF` `:2565` aktif sprintte kalır.
- Belgeler: `HARITA.md:67` (`D_seg_pick` "Ürün'ün sprint süresi"), `:147` (kâğıt fırsatı 1 haftalıkta), `:164` (`--sprint-probe` `weeks`);
  `CLAUDE.md:121-122`, `:289-290`, `:336` (`week1`); `GDD — ZAMAN MODELİ.md:211`; `GUNCELLEMELER.md:218`, `:229`, `:357`; motor md `:2754-2756`.

### 12.4 Kart ihtiyacı, `shares`, `effort_mod`, `faulty`
- `shares` okuyan ve yazanlar: `sprint_system.gd:14` (yorum), `:508` (`decision_test_half`), `:661` (`remaining`), `:676-678`
  (`ready_share`), `:929-930` (`_halve_test` yazar), `:1158` (`_work`), `:1688` (`phase`); `sprint_catalog.gd:182-183` (`card_shares`),
  `:187-191` (`card_roles` payı 0 olan fazı atar: araştırma ve düzeltme kartının rolleri buradan), `:256` (`new_card`); `product_model.gd:287`
  (`phase_pts`); `main.gd:1015-1016`; `save_manager.gd:868`; smoke `_promise_world` `:21856-21857`, `promise_cut_test_escape` `:21986`,
  `:21989`, `_late_world` `:22653-22654`, `save_v14_build_becomes_sprint_plan` `:23561-23566`.
- İhtiyacın kaynağı: `ProductLines.work_profile` `product_lines.gd:333-334`; payların tablosu veride yok (§11 madde 2). Tuzak: profilsiz hatlar
  `line_hidden_self_serve` (`rnd_tree.json:39`, `sprint.json:132`'deki onboarding alanında) ve ücretli plan `cap_paid_plan`
  (`sprint_catalog.gd:14`, `:172-173`): `work_profile` "" döner, bir varsayılan gerekir (ücretli plan için PRD 2/10/3 verir; gizli hat için yok:
  ADIM §0b şart 2).
- `effort_mod` (K13): yazanlar `:347`, `:431`, `:902`; okuyan `:1677`; katalog `:258`. ±n'in aşamaya dağılımı tanımsız.
- `faulty`: `new_card` `:258` varsayılanı düşer; yazan `_work` `:1161-1162` ve okuyan `escape_chance` `:946` D3'e kadar yaşar, okuma
  `c.get("faulty", false)` olur. Tuzak: smoke `sprint_faulty_bug_on_card_line` `:20854` sürüm anlık görüntüsünde `shipped[0].faulty`'yi
  doğrudan okur (yazılmamış kartta hata); `_close_faulty` `:18008` yazar (sorunsuz).
- `sprint.weeks`: `:78`, `:186`, `:613`, `set_weeks` `:326`.

### 12.5 ×5 ölçeğin dokunacağı her sabit ve veri
**`data/product/sprint.json`:**
| Satır | Anahtar | Bugün | D1 |
|---|---|---|---|
| `:6` | `effort` k1/k2/k3/research | 3/5/8/1 | 15/25/40/5 |
| `:7` | `fix_effort.points` | [1, 2] | [5, 10] (D7'ye kadar) |
| `:21` | `person_points_week` | 2 | 10 |
| `:42` | `paper.reopen_points`, `paper.phone_points` | 1, 2 | 5, 10 |
| `:45` | `paper.colors` hand/central/again_extra | 2/4/1 | 10/20/5 |
| `:77` | `paid_plan.effort` | 3 | 15 |

Değişmeyenler: `trim_share` (oran), `ask_silent_mult`, `root_min` (sayım), `cap_ceiling`, `hours_mult`, `lead.small_team_cards`
(`sprint_catalog.gd:854` `capacity / effort.k1` oranı ×5'te aynı), `pm.*`, `impact` (oran kayar, D9 ölçer).

**Kod sabitleri ve okuyucular:** `points_for` `:1720-1725`, `_points` `:1729-1733` (cfg okur); `step_effort` `sprint_catalog.gd:171-178`
(`maxi(1, …)` `:177`); `fix_effort` `:165-167`; `candidates` araştırma `:231`; `_refresh_fix_cards` `:1636`; `fix_first` yeni kart `:240-241`;
`trim_plan` `:422` (`reopen_points`); `effort_change` `:354-356` en az **1** puan (×5'te 5 mi, karar; tabloda yazmıyor); `decision_test_half`
`:504-508` (oran); `EXAMPLE_BIG` `sprint_probe.gd:72` (kişi-hafta, kendiliğinden); `ProductLines.effort_of` (5/7/10) ölçeklenmez (O23).

**`effects.gd` sprint fiilleri** (`:476-514`): miktarlar kartta; `sprint_card_effort` `:476-478`, `sprint_card_progress` `:479-480`,
`sprint_card_trim` `:503-505` (`trim_plan` `:697-699`). Fiil kodunda sabit yok.

**`seams_product.gd`:** kendiliğinden ×5 olanlar `urun.decision_card_effort` `:54-57`, `decision_card_done` `:154-156`, `decision_test_half`
`:255-256`, `paper_phone_points` `:263-264`, `decision_trim_finishes` `:258-261`, `phone` gecikmesi `:268`, `colors_*` `:282-293`
(`_colors_points` `:311-313`).

**`data/events/cards/product/`** (34 dosya, 47 sabit miktar; satır = `verb` satırı):
- `sprint_design_color_blind.json:83` (+1); `sprint_design_drawings_late.json:72` (progress +1), `:82` (+1), `:123` (+1);
  `sprint_design_empty_state.json:77` (+1); `sprint_design_empty_state_b2c.json:70` (+1); `sprint_design_first_screen.json:72` (+2);
  `sprint_design_gloves.json:77` (+2), `:87` (trim 2); `sprint_design_notifications.json:84` (+1).
- `sprint_dev_backfill.json:85` (+1); `sprint_dev_import_tool.json:90` (+2); `sprint_dev_multi_currency.json:80` (+2), `:90` (trim 2);
  `sprint_dev_old_phones.json:73` (+2), `:83` (+1); `sprint_dev_relogin.json:72` (+2); `sprint_dev_root_cause.json:66` (+2);
  `sprint_dev_security_update.json:69` (+1); `sprint_dev_shorter_path.json:71` (−3); `sprint_dev_unasked_rewrite.json:110` (−1), `:125` (−2).
- `sprint_pm_spec_unclear.json:79` (+1), `:89` (−1), `:104` (+3), `:136` (−1); `sprint_pm_spec_unclear_b2c.json:80`, `:90`, `:105`, `:137`
  (aynı; N2: ölü kart); `sprint_pm_two_accounts.json:96` (+2).
- `sprint_solo_backup.json:66` (+1); `sprint_solo_server_bill.json:71` (+1), `:87` (trim 1), `:124` (trim 1).
- `sprint_test_after_midnight.json:74`, `sprint_test_coupon.json:77`, `sprint_test_devices.json:84`, `sprint_test_readonly_delete.json:82`,
  `sprint_test_slow_many.json:80`, `sprint_test_slow_many_b2c.json:78` (+1'er); `sprint_test_stock_transfer.json:77` (+1), `:87` (−1);
  `sprint_test_their_data.json:81` (+2); `sprint_test_too_much.json:79` (+1), `:141` (+1); `sprint_untested_old_screens.json:84` (+1).
- Seam'li (kendiliğinden ölçeklenir, dokunulmaz): `sprint_design_customer_colors.json:97`, `:115`, `:200` (`colors_*`; `:200`'de
  `amount_mult` 3); `sprint_dev_shorter_path.json:75` (`decision_card_done` × −1); `sprint_pm_phone_too.json:84`, `:98` ve
  `sprint_pm_phone_too_b2c.json:85`, `:99` (`paper_phone_points`); `sprint_test_too_much.json:109` (`decision_test_half`).
- **Koşul eşikleri (tabloda yok, tuzak):** `sprint_design_customer_colors.json:73-75` `decision_card_effort >= 3`;
  `sprint_dev_shorter_path.json:54-56` `>= 5` ve `:59-61` `decision_card_done >= 1`; `sprint_dev_unasked_rewrite.json:68-70` `>= 5`;
  `sprint_pm_spec_unclear.json:62-64` `>= 5`; `sprint_pm_spec_unclear_b2c.json:63-65` `>= 5`. Ölçeklenmezse kâğıtlar ×5 kartta çok kolay açılır.
- Kart metninde sayılı puan yok (tarandı). Test fikstürleri `_fixtures/paper_{design,dev,founder,plain,pm}.json` birer miktar taşır.
- Ortak dosya: `sprint_pm_phone_too*.json` K20'de değişti (commit'li); C3a `trust_delta` yazacak.

**Fikstür ve smoke sabitleri:** `main.gd:890` `fix_effort.points = [6, 8]` → [30, 40]; smoke `incident_sprint_stop_moves_the_card` `:18223`
aynı; `sprint_fix_preview_matches_close` `:21017-21018` (efor 1 ve 2 sabit), `sprint_fix_card_refreshes_until_it_runs` `:21098-21110`
(2/1/2 sabit); `product_fixtures.gd:606` `capacity {total 12}` ve kart puanları (görsel fikstür).

**Görünür sonuç:** Atlas "Sprintte haftada {pts} puan" (`hr_atlas_modal.gd:390`), mesai modalı (`work_hours_modal.gd:217-218`), plan çubuğu,
kart efor dökümü ve çiplerdeki puanlar ×5 görünür: TR ve EN kare gerekir.

### 12.6 Smoke'ta etkilenen vakalar
Sayım `endgame_smoke.gd` HEAD'in çağrı grafiğiyle (doğrudan ve yardımcı üzerinden), dispatcher satırıyla.
- **Doğrudan `set_weeks`/`sprint_chance` (7):** `quiet_cards_fill_empty_floor` `:542`, `sprint_decision_card_fires_shipped` `:543`,
  `sprint_late_for_requests` `:546`, `paper_speaker_is_assignee` `:516`, `decision_no_fourth_show` `:518`, `paper_interrupt_order` `:519`,
  `paper_empty_sprint_ratio` `:520`.
- **Yardımcılar:** doğrudan `_paper_chance` `:20388`, `_promise_world` `:21834`, `_late_world` `:22624`, `_paper_pool` `:22718`,
  `_paper_pool_end` `:22727`, `_paper_world` `:23025`; geçişli `_seed_sprint` `:20379`, `_seed_sprint_live` `:20395`, `_seed_promise_sprint`
  `:22133`, `_seed_open_request` `:21418`, `_paper_pm_asked` `:23460`, `_incident_world` `:17455`, `_incident_world_b2c` `:17474`,
  `_incident_scale_audience` `:17644`, `_regression_book` `:18027`, `_regression_audience` `:18065`, `_trust_standing_cost` `:17249`.
- **Toplam 89 vaka** (ADIM'daki sayı doğru): account_uses_area_rule, request_area_follows_emphasis, leave_does_not_pause_build,
  capacity_step_immediate, load_mult_steps, auto_capacity_grows_only, event_trust_delta_lasting, event_morale_payers, incident_gap_and_spread,
  incident_night_hold_resumes, incident_scale, incident_save_roundtrip, incident_month_close_window, incident_gates,
  incident_regression_fixture, incident_checkout_fix_card, incident_defer_ends_with_line, incident_sprint_stop_moves_the_card,
  release_thanks_each_kind, release_thanks_limits, release_thanks_incident_scope, release_reviews_pick, release_through_close,
  event_history_chip_matches_live, founder_not_double_counted, fit_star_context, fit_account_ref, fit_scale, save_v17_market_ref,
  save_retired_product_flags, research_occupies_person, research_and_build_pause_each_other, rnd_note_author_and_lines, sprint_two_days_close,
  sprint_capacity_from_team, sprint_team_follows_job_matrix, productivity_mod_paces_the_sprint, sprint_ceiling_125_blocks_add,
  sprint_carry_keeps_progress, sprint_mvp_three_identity_k1, sprint_faulty_bug_on_card_line, sprint_faulty_pre_launch_lands_at_v1,
  sprint_fix_card_clears_its_line, sprint_fix_preview_matches_close, sprint_fix_card_refreshes_until_it_runs,
  sprint_fix_first_puts_the_card_on_top, line_impact_names_the_accounts, product_bug_rows_read_the_store, worst_bug_line_breaks_ties_by_users,
  sprint_starts_only_with_consent, sprint_request_on_time_met, sprint_paid_plan_opens_paid_tier, sprint_save_roundtrip,
  sprint_decision_blocks_progress, paper_speaker_is_assignee, decision_one_per_sprint, decision_no_fourth_show, paper_interrupt_order,
  paper_empty_sprint_ratio, paper_card_trim, paper_outlook_reads_the_plan, next_renewal_day_one_place, paper_renewal_card_first,
  paper_colors_two_arrivals, paper_trust_until_ships, paper_account_selectors, paper_cards_render, paper_cards_are_asked,
  sprint_legacy_beta_cards_ship, sprint_departure_restaffs_card, sprint_never_stalls_in_plan, sprint_lead_offers_paid_plan_b2c,
  sprint_solo_mvp_by_week_six, promise_due_sprint_kept_when_shipped_next_sprint, promise_due_sprint_breaks_after_close,
  promise_due_fires_when_late, promise_cut_test_escape, promise_extend_once, promise_break_chain, quiet_cards_fill_empty_floor,
  sprint_decision_card_fires_shipped, promise_row_locked_when_no_room, sprint_late_for_requests, paper_line_harden, paper_card_effects,
  paper_seams, save_v15_tickets_become_open_bugs, product_paid_plan_locked_until_mvp, product_pm_plan_opens_as_next_sprint.
- **Bu 89'un dışında D1'in dokunduğu:** `shares` okuyan (`save_v14_build_becomes_sprint_plan` `:550`; `promise_*` dördü ve
  `sprint_late_for_requests` 89'da); `faulty` okuyan `sprint_faulty_bug_on_card_line` `:502` (89'da); puan anahtarı okuyan
  `sprint_capacity_from_team` `:496`, `sprint_team_follows_job_matrix` `:497` (89'da); `effort.k`/`paid_plan` okuyan
  `rnd_design_discount_reads_profile` `:463`, `sprint_request_on_time_met` `:512`, `sprint_paid_plan_opens_paid_tier` `:513`,
  `sprint_lead_offers_paid_plan_b2c` `:533`, `product_paid_plan_locked_until_mvp` `:562`; göç zinciri `save_v14_history_becomes_releases`
  `:551`, `save_v15_callback_bugs_under` `:553`, `save_roundtrip_fingerprint` `:298`, `save_v10_product_state` `:465`. 89'un dışında
  kalanlar: kesin `rnd_design_discount_reads_profile`, `save_v14_build_becomes_sprint_plan`, `save_v14_history_becomes_releases`,
  `save_v15_callback_bugs_under` (4); olası `save_roundtrip_fingerprint`, `save_v10_product_state` (2; tam gidiş dönüş ve `_migrate_15`'ten
  geçen eski kayıt, gövdeleri bu turda okunmadı). **D1'in kümesi 93, olasılarla 95 vaka.**
- Yeni: `save_v19_*` (sprint ortası gidiş dönüş dahil). `effort_mod` smoke'ta doğrudan okunmuyor.

### 12.7 Kapı ve sıra notları
- Ortak dosyalar: `main.gd`, `run_probe.gd` (çalışma kopyası C'nin farkını taşıyor: hunk düzeyinde sahne), `endgame_smoke.gd`, `strings.csv`
  (D1'de CSV değişikliği yok, §12.3), HARITA, CLAUDE.md §6.
- `class_name` eklenmez (D1); import gerekmez.

## 13. Öbür (a) adımları için kısa listeler

**D1b (Karar 1 kişi hızı, Karar 5 kurucu payı).** `points_for` `:1720-1725`, `_points` `:1729-1733`, `_share` `:1738-1740`, `team` `:705-720`,
`week_points` `:694-699`, `_fits` `:1711-1715`, `_work` hız `:1157`; `sprint.json:21-25`; huy `hr_constants.gd:407-411` (yorum), `trait_mult`
`:529`; `focus_mult` `:184-185`; kurucu payı `game_state.gd:415-425`, `time_manager.gd:152`, `:177`; sahte kişi `:365`, `_finish_sprint`
`:910-919` (K7); görünen `hr_atlas_modal.gd:390`, `work_hours_modal.gd:217-218`; belgeler ACIK 96 (5) `:915-920`, (6) `:920-922` (N1),
`ISLER.md:62-64`, `SECONDARY_AREA_MULT` ayrılığı ACIK'a (K4). Smoke `sprint_capacity_from_team` `:496`, `sprint_team_follows_job_matrix` `:497`,
`sales_meeting_time_skip_founder_share` `:158`, `founder_not_double_counted` `:434`, `productivity_mod_paces_the_sprint` `:498`.

**D2b (sabit 2 haftalık oynatma).** Erken kapanış `_end_week` `:1100-1101`; zar `_staff_week` `:1109-1112`, `_request_decision` `:1204-1242`;
çekme iki yolda: `_play_out` `:1171-1193` (`ahead` kesmesi `:1191-1192`) ve `_end_week` `:1078-1104` (N3); sıra `_suggest` `:873-913`;
devreden kalkanı `sprint_catalog.gd:903-911` kalkar, tek talep `:886` kalır; tek alım `_takes` `:753-760`, `can_add` `:744-746`, `mvp_eta`
`:828`, `:831`, `_suggest` `:905`, `product_model.gd:222`, `:240`, `:335`; kayan kart `put_first` `:221-231`, `_carried_out` `:1645-1648`,
`decision_carry` `:390-406`, `first_bumps` `:247-261`; söz `late_promise` `:955-973`; taşan aşama sürüm kaydı `:1493-1498`; prob `PRED`
`sprint_probe.gd:224-225`, `CLOSE` `:176`, `REPRED` `:427`. Smoke `sprint_two_days_close` `:495`, `sprint_never_stalls_in_plan` `:532`,
`sprint_carry_keeps_progress` `:500`, `sprint_ceiling_125_blocks_add` `:499`, `sprint_fix_first_puts_the_card_on_top` `:507`,
`sprint_solo_mvp_by_week_six` `:534`, `promise_due_fires_when_late` `:538`; yeni `sprint_two_weeks_pull`, `sprint_intake_uses_applied_plan`.

**D3 (Karar 24 hata modeli).** `escape_chance` `:945-950`; `_work` `:1161-1162`; `_close` zarı `:1450-1454`; `pending_faulty` `:1467-1471`;
sürüm `faulty` `:1498`; `_land_faulty` `:1536-1541`; `cut_test`/`_halve_test` `:928-940`; yeni kod terimi (K14 listesi); `sprint.json:29-30`;
`support_system.gd:37`, `:40`, `:164-166`; `product_state.gd:39`, `:275-288`; `game_state.gd:77`; okuyucular K8; `payers` `:727-739`
(K10); `role_of` (K5); `effects.gd:485-488`, `chips.gd:114-118`, `strings.csv:2796`; `seams_product.gd:192-196`; TİTİZ `hr_constants.gd:411`;
`CLAUDE.md:115-120`. Smoke `sprint_faulty_bug_on_card_line` `:502`, `sprint_faulty_pre_launch_lands_at_v1` `:503`, `promise_cut_test_escape`
`:539`, `incident_regression_fixture` `:345`, `paper_line_harden` `:547`, `destek_empty_desk_piles_up` `:205` ve `_seed_support_fixture`
`:14415`, `incident_gates` `:344`, `release_thanks_*` `:349-352`, `paper_card_trim` `:521`; `faulty_chance` yazan 5 işlev (T11).

**D4 (PM kural A).** `_assign` `:1120-1147` (PM `ahead` süzgeci `:1131-1132`); `team` `ahead` `:719`; `ready_share` `:675-678`,
`_ahead_cards` `:1613-1615`; `quarter_pm` `sprint_catalog.gd:531-535`; `payers` `:727-739`; `effects.gd:744-757`; `scope.gd:240-249`;
`office_people.gd:41` (`product` anahtarı var). Smoke `event_morale_payers` `:338`, `product_pm_plan_opens_as_next_sprint` `:563`;
yeni `sprint_skill_assignment` (PM kolu), `pm_ekleme` 12/25 (prob `pmstar=`, `plus=`).

**D7 (Düzeltme kartı 2 × açık hata).** `fix_effort` `sprint_catalog.gd:165-167`, `is_priority` `:244-250`, `candidates` `:226`,
`bugs_part` `:463-473`; `_refresh_fix_cards` `sprint_system.gd:1631-1641`; `fix_first` `:208-214`, `:238-241`; `sprint.json:7`;
`NEGLECT_BUGS` `support_system.gd:86`, `:284`; DESTEK ipucu `build_bar.gd:135-142` (`neglect_note` `support_system.gd:300-303`);
`DUE_BUGS` `run_probe.gd:334`, `:1321`, `SLIP_CLEAR_MARGIN` `:2208` (HEAD); `fix_effort.points` yazanlar `main.gd:890`, smoke `:18223`;
`priority` okuyan `product_fixtures.gd:564`. Smoke `sprint_fix_card_clears_its_line` `:504`, `sprint_fix_preview_matches_close` `:505`,
`sprint_fix_card_refreshes_until_it_runs` `:506`, `incident_sprint_stop_moves_the_card` `:348`, `neglect_reputation_below_zero` `:559`.
`B2B_BUG_SAT_*` (`b2b_constants.gd:72-73`) ve `COMPLAINT_BUG_GATE` (`:70`) C3a'nın: dokunulmaz.

**D8a (öneri altı basamak).** `_suggest` `sprint_catalog.gd:873-913`, `lead_suggestion` `:477-478`, `lead_sentence` `:483-496`,
`_lead_area` `:851-861`, `_weakest` `:820-835`, `_impact`/`_ratio` `:796-815`, `_request_of` `:756-760`; `apply_lead` `sprint_system.gd:332-341`;
`_auto_start` `:1382-1399`; bot `run_probe.gd:1269-1306`, `_keep_building` `:1359-1369` (silinir), `_plannable` `:1373-1374`, `_plan_promises`
`:1379-1390`, `_plan_fix_arm` `:1312-1337` (HEAD); süre `sprint_probe.gd:297` (`lead` satırı); ekran `product_model.gd:293`, `_lead` `:617-625`.
Smoke `sprint_lead_offers_paid_plan_b2c` `:533`; yeni `sprint_lead_fills_to_ceiling`.

**D8b (PM'siz çeyrek, devretin PM şartı).** `pick_goal` `:556-558`, `set_delegate` `:286-288`, `delegated` `:592-593`, `awaits_plan` `:581-588`,
`_speaker` `:1250-1252`; `quarter_goal` `sprint_catalog.gd:539-541`, `pm_plans` `:550-572`; `product_model.gd:327`, `_quarter` `:424-447`,
`_goal` `:452-459`; `product_tab.gd:230-231`, `:235-238`, `:284`; `quarter_view.gd:83-139`; `strings.csv:2652`, `:2658`. Smoke
`product_pm_plan_opens_as_next_sprint` `:563`; yeni `quarter_goal_without_pm`, `delegate_needs_pm`.

**D5a (Atlas hızları, Görevler uyarısı, kurucu yıldızları).** `hr_atlas_modal.gd:387-392` (`points_for` `:390`), `HR_ATLAS_WEEK_POINTS`
`strings.csv:417`; `hr_assignments.gd:106-128` (`_cell`), `HR_TASK_*` `strings.csv:589-595`; kutu kuralı `hr_constants.gd:121-131`, `:166-181`
(K3); kurucu dosyası `hr_dossier.gd:142` (kurucu kolu) ve `personal_tab.gd:159-170` (yıldız ölçeri). Smoke yok, görsel kabul (TR, EN, renk
körü, 1,25).

## 14. D2a (park) · P portu kopukluk listesi
**`_assign`'in doğrudan çağrı noktaları (5):** `put_first` `:230`, `_staff_week` `:1110` ve `:1112`, `_play_out` `:1178`, `_restaff` `:1359`.
Tek atama girişine bağlanır.

**`_assign`'e dolaylı varanlar** (hepsi aynı girişi oynatmalı; açık 5):
- `can_add` `:744-746` → `_takes` `:759` → `_play_out`.
- `mvp_eta` `:828` (`_takes`), `:831`.
- `_outcome` `:785` ← `plan_outcome` `:774-776`, `first_bumps` `:256-257`, `decision_first_finishes` `:476`.
- `crunch_finishes` `:873`, `_unfinished` `:903`, `_finish_sprint` `:919`, `design_late` `:497`, `_suggest` `sprint_catalog.gd:905`.

**`_work`'ü atamasız çağıranlar:** `decision_progress` `:365` (sahte kişi, K7), `_end_week` `:1090`, `_finish_sprint` `:918`.

**"Kalır" istisnaları** (kişi aşama ya da hafta bitmeden yeniden dağıtılır):
- `_clear_decision` `:1303-1310` → `_staff_week(false)` `:1310` (kâğıt cevaplanınca hafta baştan).
- `crunch_finishes` `:866-876` (karar bekleyen kartı baştan atayarak oynar).
- `put_first` `:221-231` (acil durumda "Sprinti durdur": `effects.gd:497-501` → `fix_first` `:208-214` → `put_first`; kâğıdın
  `sprint_card_first`'ü `decision_first` `:458-464` → `:463`).
- `_restaff` `:1352-1360` (ayrılış, izin, iş değişikliği; çağıranlar `remove` `:122`, `decision_carry` `:404`, `_on_team_changed` `:1329`
  ← `EventBus.hr_day_processed` ve `character_removed` `:1318-1319`).
- Uymayan iş (Karar 2).

`_on_assignment_changed` `:1335-1337` koşan sprintte atamaya dokunmaz (yalnız plan dışında `_changed`).

**Atamayı okuyan dış yerler** (yeni şekle geçer): K1 listesi, K5 listesi, `payers` okuyucuları (K10), `office_people.gd:97`, `:666-669`.
**Eşitlik:** `_assign`'in `sort_custom`'u `:1136-1141` kimlikle kırar; yeni kural da açık anahtarla kırmalı.

Kopukluk listesi kapalı: beş doğrudan çağrı, dokuz dolaylı yol, üç atamasız `_work` çağrısı ve beş istisna HEAD'de tek tek bulundu.
