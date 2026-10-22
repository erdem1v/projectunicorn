# B0 · Eşikler ve paylar (PRD §0 madde 8, Karar 8)
Salt okuma. Godot koşulmadı. Tüm değerler **onay bekliyor**; kodda tek ayar sabitinde `[WORKING]` ile durur (`data/product/sprint.json` `incident` ve `paper` blokları).

## 0. Veri, yöntem, güven
**Hat başına açık hata dağılımı hiçbir logda yok.** `PROBE BUGS` yalnız haftalık toplam verir (`new`, `open`, `pre`; `run_probe.gd:585-592`), `PROBE FIX` yalnız sprintte hangi düzeltme kartlarının olduğunu (`:317-329`). K5_OLCUM.md de toplamdır. Bu yüzden değerler **ölçüm değil, kalibre modeldir**.

**Model** (stdlib Python, Godot'suz; betikler `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/` altında `line_model.py`, `incident_model.py`, `subsets.py`, `root_min.py`, `real_cleared.py`; repoya girmez):
- Her yeni hata canlı hatlardan birine eşit olasılıkla düşer: A'nın kuralı (`support_system.gd:117-126`).
- Girdi: K5 loglarından (`a_calisma/K5_runs/*_fix_{none,worst}_{7,11}.log`) haftalık `new`; canlı hat kümesi `PROBE SPRINT shipped=feat:...` kapanışlarından; düzeltme kartları `PROBE FIX cards=` ve `PROBE SPRINT shipped=fix:...` satırlarından. Haftanın 16 saati kapanıştan önce, 8 saati sonra düşer (08:00 → 00:00 → 08:00).
- `fix_worst`: sprint başında o anki en çok hatalı hat seçilir, kapanışta o hattın hepsi silinir (`sprint_system.gd:1032`). `fix_none` B2B'de hiç düzeltmez.
- "Erken" = hata akışı başladıktan sonraki ilk 20 hafta (A'nın tanımından birkaç hafta kaymış). "Kapanıştan önce" (pre) = haftanın sonu, ay sonu 23:00 anı; "sonra" (post) = hafta başı 08:00.
- 300 tekrar × 2 tohum (7, 11); olay modeli 60 tekrar.

**Doğrulama** (model / log; ikisi de aynı hafta kümesinde):
| Ölçü | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| `fix_worst` toplam açık hata, kapanıştan önce | 16,8 / 18,1 | 10,4 / 10,8 | 5,8 / 5,5 | 21,6 / 22,1 |
| `fix_worst` düzeltme kartında ≥5 hata payı (model / **ölçülen** `PROBE FIX fix_load ≥ 2`) | %80,9 / %78,6 | %6,8 / %9,9 | %2,6 / %4,8 | %39,8 / %37,4 |
| `fix_none` toplam, kapanıştan önce | 53,2 / 51,8 | 202,8 / 201,5 | 18,0 / 17,3 | **68,0 / 56,4** |
Model `fix_worst` toplamlarında ölçüme %7 içinde oturuyor (kart payı sütununda 1-3 puan fark). **Zayıf nokta: B2C `fix_none` geç dönem.** Orada lider 133 kapanışın 103'ünde düzeltme kartı getiriyor (§B0_HARITA 5) ve hangi hattı seçtiği bilinmiyor; rastgele seçimle toplam 33,6, "ucuz hattı seç" ile 68,0 çıkıyor, gerçek 56,4. O hücre için tek sayı yerine aralık yazıldı.

**Ölçüm koşusu gerekiyor (B0 koşmadı).** Model hat başına sayıyı varsayımla verir. Kesin sayı için B3 kapısında, harness değişikliğiyle (sabit değil): `_log_bugs()` (`run_probe.gd:585`) yanına `PROBE LINES day=<d> <hat>=<n>,...` ve `PROBE SHIP` satırına `faulty=<n>` ekle; sonra 8 koşu: `full_run_fix_none`, `full_run_fix_worst`, `full_run_b2c_fix_none`, `full_run_b2c_fix_worst` × tohum 7 ve 11, 104 hafta (`"$GODOT" --headless --path . --lang=tr --run-log=<preset>:104:sim:<tohum>`, her koşu kendi `APPDATA`'sı, boşluksuz yol; 4 paralel yaklaşık 3 dakika). Bu §1-§3'ün sayılarını ölçümle değiştirir; eşik önerileri ancak kenarlarda oynar.

## 1. En kötü hattın açık hatası (model)
`P(en kötü hat ≥ N)`, % olarak, hata akışı başlamış haftalar. Pre = kapanıştan hemen önce, post = hafta başı.
| Pazar · kol · dönem | an | N=2 | 3 | 4 | 5 | 6 | 7 | 8 | 10 |
|---|---|---|---|---|---|---|---|---|---|
| B2B `fix_none` erken | pre | 99,7 | 97,2 | 95,5 | 94,6 | 92,7 | 89,9 | 86,5 | 76,6 |
| B2B `fix_none` geç | pre | 100 | 100 | 100 | 100 | 100 | 100 | 100 | 100 |
| B2B `fix_worst` erken | pre | 99,5 | 92,2 | 74,6 | 57,8 | 45,8 | 35,4 | 24,7 | 7,0 |
| B2B `fix_worst` erken | post | 98,9 | 88,3 | 64,9 | 49,1 | 40,0 | 30,2 | 19,4 | 4,7 |
| B2B `fix_worst` geç | pre | 97,4 | 69,5 | 35,5 | 14,0 | 4,6 | 1,3 | 0,3 | 0 |
| B2B `fix_worst` geç | post | 92,4 | 55,0 | 23,2 | 7,6 | 2,2 | 0,5 | 0,1 | 0 |
| B2C `fix_none` erken | pre | 99,4 | 96,6 | 89,7 | 78,5 | 65,6 | 49,9 | 33,0 | 8,9 |
| B2C `fix_none` geç (aralığın üst ucu) | pre | 100 | 100 | 100 | 100 | 100 | 99,8 | 99,0 | 93,0 |
| B2C `fix_worst` erken | pre | 84,1 | 55,7 | 31,4 | 12,3 | 3,4 | 0,6 | 0,1 | 0 |
| B2C `fix_worst` geç | pre | 94,9 | 76,5 | 55,7 | 42,3 | 31,2 | 23,2 | 18,8 | 13,6 |
| B2C `fix_worst` geç | post | 92,5 | 70,4 | 50,7 | 37,6 | 27,0 | 20,7 | 17,3 | 11,9 |

Ortanca ve yüzdelikler (kapanıştan önce, en kötü hat): B2B `fix_worst` geç 3 / 4 / 5 (ortanca / %75 / %90); B2C `fix_worst` geç 4 / 6 / 11; B2B `fix_none` geç 36 / 47 / 53; B2C `fix_none` geç 10 (rastgele seçim) ile 19 (ucuz hat seçimi) arası. Canlı hat sayısı ortalama: B2B 6,3 (erken) → 7,3 (geç); B2C 5,0-5,8 (erken) → 9,0 (geç).

**Ay sonu hatları** (Fatura, Defter, Nakit Akışı; üçünden en az biri ≥ N), B2B, kapanıştan önce:
| Kol · dönem | N=2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|
| `fix_none` erken | 95,2 | 92,0 | 88,0 | 83,3 | 77,9 |
| `fix_none` geç | 100 | 100 | 100 | 100 | 100 |
| `fix_worst` erken | 68,3 | 49,6 | 35,3 | 25,4 | 17,8 |
| `fix_worst` geç | 63,5 | 32,0 | 13,0 | 4,7 | 1,5 |
Hesap kapsamı (`SalesArchetypes.uses_axis`, `USE_AXIS_MIN` 0,25, `sales_archetypes.gd:34, 141`): **Defter** (kararlılık) bütün sektörlerce kullanılır; **Fatura** (deneyim) lojistik, inşaat, üretim, sağlık, tekstil, medya (hepsi `ops_cautious` okunur) ve sigorta, hukuk, perakende, emlak ile kullanılır, teknoloji, e-ticaret, finansça kullanılmaz; **Nakit Akışı** (yenilik) **yalnız** teknoloji, e-ticaret, finans hesaplarınca kullanılır (13 sektörün 3'ü). Model üç hattın hepsinde hesap olduğunu varsayar; Nakit Akışı için tech hesap yoksa koşul Fatura ve Defter'e düşer.

## 2. Önerilen değerler
| Ad | Öneri | Dayanak | Olayın aralığına etkisi | Durum |
|---|---|---|---|---|
| `MONTH_CLOSE_LINE_BUGS` (ay sonu, Fatura/Defter/Nakit Akışı hattı) | **3** | `fix_worst` geç ay sonu anında %32 (erken %50), `fix_none` %92-100 | aralığı değiştirmez, tür karışımını değiştirir: B2B `fix_worst`'te 0,57 ay sonu olayı/koşu (koşuların %43'ünde); N=2 → 1,17 (%71); N=4 → 0,31 (%28); N=5 → 0,13 (%13) | onay bekliyor |
| `STORM_LINE_BUGS` (yorum fırtınası; kitle ≥ 2.000 şartı sürer) | **7** (yani `B2BConstants.COMPLAINT_BUG_GATE` 6'dan fazla) | `fix_worst` geç %23 (post %21), erken %0,6; `fix_none` geç %99,8-100, erken %50 | B2C `fix_worst`: 1,15 fırtına/koşu (%73 koşuda); `fix_none` 4,33. N=6 → 1,57 (%83); N=8 → 0,92 (%68) | onay bekliyor |
| Sürüm sonrası bozulma hat eşiği | **gerekmez**: tetik `release.faulty` ∩ kritik hatlar (W1) | `release.faulty` sıklığı ölçülmedi (B0_HARITA W4) | olay aralığına bağlı değil (sürüm yolu) | ölçüm gerek |
| `RELEASE_REVIEW_NEG_LINE_BUGS` (W3, hatalı çıkmayan sürümde olumsuz yorum) | **5** = `fix_effort.priority` (ekranda "Öncelikli" ve alan uyarısı "!" ile aynı eşik; yeni sabit yok) | B2C `fix_worst` geç %42 (post %38), erken %12; `fix_none` geç %100, erken %79 | olay değil, sürüm satırı; aralığa etkisi yok | onay bekliyor |
| `ROOT_MIN` (W2 kök neden kâğıdı) | **3** (Erdem'in onayladığı ton örneği "üçü aynı yerden", PRD §3) | `fix_worst` düzeltme kartının ≥3 hata taşıma payı: B2B erken %96, geç %55; B2C erken %37, geç %70 (≥5: %81 / %7 / %3 / %40, ölçüm bununla uyuşuyor §0) | kâğıt olayı değil; sprint başına tek kâğıt kuralı (Karar 12) payı belirler | onay bekliyor |
| `RENEWAL_WINDOW` (W2 PM yenileme kâğıdı) | **12 hafta** = `data/product/sprint.json` `request.before_renewal_weeks` | talep, yenilemeden tam 12 hafta önce doğar (`sprint_bridges.gd:30-35`); sözleşme 52 hafta (`request.contract_weeks`) | yenileme kaynaklı talep ancak hesap 40. haftayı geçince doğar. Bot logları: 104 haftada 3-4 istek kartı çıkıyor, yenileme kaynaklı 0 (§3.4) | onay bekliyor |
| `B2C_NIGHT_TRY_SHARE` (W1 gece kesintisi gövdesi) | **%1,5 / saat** (tam: ACTIVE_SHARE 0,35 ÷ 24 = %1,46); W1'deki %1,8 yerine | modelde saatlik kullanım eğrisi yok (`sales_system.gd:141-205` yalnız kitle akışı); ölçülemez | olay aralığına etkisi yok; W1 örnek sayısı 186 yerine 150 (12.400 × %1,46 × 0,83), metin belirteç olduğu için değişmez | onay bekliyor, ölçülemez |
| Depo işi sektörleri (W2 `design_gloves`) | **lojistik, üretim, perakende** (W2 listesi aynen) | `ProductCatalog` ERP'nin kendi sektörleri: `manufacturing, retail, logistics` (`product_catalog.gd:29-30`); Stok hattı deneyim ekseni, üçü de ≥0,25 ile kullanır (`ops_cautious` 0,30, `finance_brisk` 0,45) | etkisiz | onay bekliyor |
| Durum ekranı olan hatlar (W2 `color_blind`) | **Fatura (`line_erp_invoicing`), Stok (`line_erp_stock`), Nakit Akışı (`line_erp_cashflow`), Entegrasyonlar (`line_shared_integrations`), Sürüm Geçmişi = Dayanıklılık K2 adımı (`line_shared_durability_k2`)** | "Sürüm Geçmişi" bir hat değil adımdır (`strings.csv:2058`); B2C ürününde ERP hatları yok, yalnız Entegrasyonlar ve Sürüm Geçmişi kalır. Eklenmesi önerilen: Eşitleme (`line_note_tool_sync`, "Bulut Eşitleme" durumu) | etkisiz | onay bekliyor |
| Dört kişiyi aşan ödeyen listesi (W1 `EFFECT_NIGHT_CREW`) | ≤4 kişi: virgüllü tam liste ("Deniz, Mert, Selin: moral −10"); **>4: ilk iki ad + "ve N kişi" / "and N more"**, sıra sprint payı çoktan aza, eşitse ad | W1 şablonu virgülle listeler; `Fmt` içinde ad listesi yardımcısı yok | etkisiz; yeni CSV anahtarı `EFFECT_NAMES_MORE` | onay bekliyor |

Diğer "B0'da seçilecek" ya da "B0 doğrular" geçen yerler:
| Yer | Öneri | Dayanak |
|---|---|---|
| W2 `pm_two_accounts`: seçenek etiketinde `{seam:...}` çözülüyor mu | **çözülüyor, ✅ doğrulandı** | `choice.label = resolve_text(...)` `presenter.gd:65`; `_interpolate` seam'i `:268-281` çözer; etiket "Öbür hesap nasıl istiyorsa öyle yap" yedeği gerekmez |
| W2 `dev_import_tool`: "8 haftadan yeni hesap" | **8 hafta kalsın** (`NEW_ACCOUNT_WEEKS`) | koddaki en yakın sabit `ONBOARDING_WEEKS` 4 (`b2b_constants.gd:10`) daha dar; imza hızı 3,4 hesap/hafta (K5: 348-357 imza / 104 hafta) olduğundan her zaman ≥1 aday var |
| W2 `test_slow_many`: `SLOW_SEATS` | **15** = `SEAT_BAND[2].low` (`sales_constants.gd:115-119`) | 40 seçilirse (3★ alt sınırı) B2B kolu pratikte hiç gelmez: 3★ hesap imzaların %2-3'ü (K5 `PROBE SIGN star=3`: 8/348, 11/357, 12/354); 15 ve üstü 2★+ imzaların %43-64'ü (348 / 357 / 354 imza: 2★+3★ = 155 / 228 / 151) |
| W2 `test_coupon`: "ödeme ekranına dokunan, hattı olan kart" | tetik: B2C, ücretli plan açık, test aşamasında **Entegrasyonlar hattından kart ya da Ücretli plan kartı**; hata **`line_shared_integrations`'a** yazılır | Ücretli plan kartının hattı `cap_paid_plan` sahte kimlik (`sprint_catalog.gd:14`), `ProductLines`'ta yok: `add_bugs("cap_paid_plan")` gerçek hatta düşmez, `line_accounts` boş, `line_share` 0 (B0_HARITA W8) |
| W2 `solo_backup`: "Otomatik Kayıt dışında kademe yok" | **`ProductState.line_tier("line_shared_durability") == 1`** | K1 Otomatik Kayıt, K2 Sürüm Geçmişi (`strings.csv:2057-2058`); tier 0 olursa "yeni açık hata" canlı olmayan hatta düşerdi, o yüzden `== 1` |
| PRD §0 madde 8 "checkout ağırlığı" | **sabit 1,0, hata terimi yok** | ödeme hattı yok (yukarıdaki sahte hat); açık hata zaten `p_hafta` çarpanında (`1 + min(açık, 12) / 8`) |

## 3. Eşik gerekçeleri
### 3.1 Ay sonu: 3
- `fix_none`'da her ay sonu koşul sağlanır (%92-100): ihmal her ay sonunda bedel ödetir. `fix_worst`'te %32 (geç) ile %50 (erken): dikkatli oyuncu çoğu ay sonunu atlatır, ama bazı aylarda yakalanır.
- N=2 `fix_worst`'te %64 (geç) ile ay sonlarının üçte ikisinde sağlanırdı; dikkatli oyuncu da sık yakalanır, eşik ihmali değil varlığı ölçmeye başlar. N=4 `fix_worst` geç %13: 104 haftada koşuların %28'inde bir kez.
- Ay sonu olayı yalnız ay sonu haftasında gelebilir: tiklerin yaklaşık %23'ü (`TimeModel.DAYS_PER_MONTH` 30, tik 7 gün, 4,3 hafta / ay). Bu yüzden eşik gevşese de koşu başına 1,6'dan fazla ay sonu olayı çıkmaz (`fix_none` 1,56).

### 3.2 Yorum fırtınası: 7
- A'nın "şikâyet sesi" eşiği zaten 6'dan fazla (`COMPLAINT_BUG_GATE`, `b2b_constants.gd:56`). Aynı sayıyı B2C'ye taşımak yeni sabit açmaz.
- B2C `fix_worst`'te geç dönem kuyruğu ağır (kapanıştan önce %90'lık dilim 11): fırtına buradan gelir. Erken dönemde kitle 2.000'in altında (K5 B2C: 26. tikte 874, 46. tikte 3.996) ve `fix_worst`'te hat başına ≥7 payı %0,6: fırtına pratikte yok.
- N=5 ("Öncelikli") `fix_worst`'te %42: fırtına 1,98/koşu (koşuların %90'ında); N=7'de 1,15. Fırtına her iki değerde kesinti ve ödemeden seyrek kalır; 5 fazla kolay, 8 (0,92/koşu, %68) sınıra yakın.

### 3.3 Düzeltme kartı örneği (W14)
`fix_effort` `steps [4]`, `points [1, 2]` (`sprint.json`, `sprint_catalog.gd:179`): 1-4 hata 1 puan, 5 ve üstü 2 puandır. W2 `dev_root_cause` notundaki örnek "Fatura düzeltmesi, 4 hata, 2 puan" bununla çelişir. Örnek "5 hata, 2 puan" ya da "3 hata, 1 puan" olmalı. Seçeneğin "+2 puan" çipi kartın puanından bağımsız (kâğıdın kendi bedeli), etkilenmez.

### 3.4 PM kâğıtları ve botun ölçümü (PRD §4.12 riski)
K5 loglarında 104 haftada yalnız 3-4 müşteri isteği kartı sprintten çıkıyor (`PROBE SPRINT shipped=req:...`; `fix_worst` 4 ve 4, `fix_none` 3); yenileme kaynaklı (imzadan ≥40 hafta sonra doğan) 0. PM kâğıtları "sprintte planlanmış bir müşteri isteği kartı" ister (Karar 10); bot liderin planıyla yürüyor ve liderin istek kartı seçme payı ölçülmedi. **Altı PM kâğıdının `fix_worst` kolunda hiç gelmeme riski yüksek.** Bu bir eşik değil bot politikası sorunu: B5 ölçümü "her kâğıt rolü gelir" derken PM için botun istek kartı almasını sağlamalı, yoksa PM satırı ⚠️ yazılır.

## 4. Olay aralığı kontrolü (PRD §4.1)
Model: haftalık `p = BASE × TIER × (1 + min(açık_toplam, 12) / 8)`, `BASE` 0,10, `MIN_GAP` 4, v1.0'dan 3 hafta sonra, `P_MAX` 0,6; tür ağırlıkları B_PLAN §5.1 (kesinti 1,0×TIER; ay sonu 1,5; ödeme 1,0; fırtına 1,5). Girdi: logdaki gerçek `pre` toplamı. `regression` modele girmedi (`faulty` sıklığı ölçülmedi).
| Kol · kademe | olay/koşu (ortalama; %10-%90) | tür başına koşu | en küçük aralık | 4-6 dışı aralık |
|---|---|---|---|---|
| B2B `fix_worst` · cloud (eşikler 3 / 7) | 11,4 (9-13) | kesinti 10,84 · ay sonu 0,57 | 4 | %45,1 |
| B2B `fix_none` · cloud | 12,2 (10-14) | kesinti 10,62 · ay sonu 1,56 | 4 | %40,9 |
| B2C `fix_worst` · cloud | 12,1 (10-15) | ödeme 5,61 · kesinti 5,36 · fırtına 1,15 | 4 | %43,3 |
| B2C `fix_none` · cloud | 13,1 (11-15) | ödeme 4,53 · kesinti 4,22 · fırtına 4,33 | 4 | %40,4 |
| B2B `fix_worst` · enterprise (×0,6) | 8,2 (6-11) | ay sonu 0,50 | 4 | %65,8 |
| B2B `fix_worst` · local (×1,5) | **14,1 (12-16)** | ay sonu 0,47 | 4 | %30,6 |
| B2C `fix_worst` · local (×1,5) | **15,1 (13-17)** | fırtına 1,17 | 4 | **%29,6** |
- **Eşikler aralığı değiştirmez**: kesinti türü her hafta uygun olduğundan "uygun tür yok, olay yok" hâli oluşmaz. Aralığı `BASE`, kademe ve açık hata toplamı belirler. Eşik yalnız tür karışımını oynatır.
- Aralık hedefi: en küçük aralık 4 ✅ her kolda; 4-6 dışı pay ≥%30 ✅ cloud ve enterprise'ta, **local B2C'de %29,6 sınırın altında**.
- Olay sayısı: hedef "koşu başına 4-14" (PRD §4.1). cloud 11-13 ✅ (üst uca yakın), enterprise 8 ✅, **local 14-15 ✗** (B0_HARITA W13). Açık hata toplamı A'dan sonra büyük olduğu için çarpan çoğu hafta tavanda (12/8): ortalama `p` 0,22-0,25. Öneri B3'e: `BASE` 0,08 olursa (B_PLAN'ın ilk değeri) aynı modelde enterprise 6,9-7,0, cloud 9,9-10,4, local 12,8-13,3 olay/koşu ve 4-6 dışı pay %37-72 çıkar: üç kademe de 4-14 içinde ve %30 üstünde kalır. Ya da hedef yeniden konur; B0 sabit değiştirmez, onay ister.
- **Tür karışımı:** B2B'de olayların %95'i kesinti, ay sonu %5. Erdem "beş olay" istedi; ay sonu yalnız ayın son haftasında (~%23 hafta) ve hat koşuluyla gelebilir. Ağırlığı 1,5 yerine artırmak ya da ay sonu haftasında kesinti ağırlığını azaltmak B3'ün tasarım sorusu, Erdem'e gider.

## 5. B3 ölçüm kapısına bırakılan
1. `PROBE LINES` ve `SHIP faulty=` ile hat başına gerçek dağılım (§0) ve `regression` sıklığı.
2. B2C `fix_none` düzeltme seçimi kuralı (lider hangi hattı alıyor) için bir kez hat kimliği dökümü.
3. Bot istek kartı politikası (PM kâğıtları, §3.4).
4. Yukarıdaki dört değerin (3, 7, 5, 3) ölçümle teyidi; ±1 sapma bu belgenin sonuçlarını değiştirmez.

## 6. B0v · Opus kontrolü (2026-10-17)
Model B0'ınkidir (K5 logları, hat başına rastgele düşüş); B0v iki düzeltmeyle yeniden koştu (40 tekrar × 2 tohum,
betik scratchpad'de `incident_model_b0v.py`, repoya girmez). Bütün değerler **onay bekliyor**.

**Düzeltme 1 · fırtına yalnız ortak hatlarda.** W1'in yorum fırtınası gövdesi yalnız dört ortak hat için yazıldı
(Dayanıklılık, Güvenlik & Yetki, Mobil & Erişim, Entegrasyonlar); not hatları (`line_note_tool_*`) metinsiz kalır,
fırtına doğuramaz. B0 modeli bütün hatları sayıyordu. Ortak hatlarla B2C, cloud, `BASE` 0,10:
| `STORM_LINE_BUGS` | `fix_worst` fırtına/koşu (koşuların %'si) | `fix_none` |
|---|---|---|
| 5 | 1,60 (%84) | 3,81 |
| 6 | 1,26 (%81) | 3,65 |
| **7** | **1,10 (%74)** | 3,46 |
Hüküm: **7 kalır.** Fark küçük; dikkatli oyuncu da koşuların dörtte üçünde bir fırtına görür, §4.12'nin "her tür gelir"i
`fix_worst`'te tutar.

**Düzeltme 2 · `release.faulty` bugün hiç dolmaz** (B0_HARITA W4). Bozulma olayı model dışı kalmakla kalmaz, D'ye ya da
"testi kısalt" yollarına kadar **sıfırdır**. §4.12 raporunda bu tür ⚠️ çıkar (Erdem'e soru).

**Olay aralığı (PRD §4.1) yeniden okundu.**
- Bot kademesi hep cloud: v1.0'da `SprintBridges.on_mvp` cloud seçer (`sprint_bridges.gd:123`), bot değiştirmez. §4.1
  raporu (104 hf × 10 tohum, A'nın kolları) cloud'da koşar: **11,5 (`fix_worst` B2B) · 12,0 (B2C) · 12,0 / 12,9
  (`fix_none`)**, aralıkların %40-45'i 4-6 dışında. Hedef 4-14 ✅. local kademeyi yalnız oyuncu seçer.
- Smoke ölçütü ("aralıkların ≥ %30'u 4-6 dışında") matematikle bağlanır: en küçük aralık 4 iken bir aralık 4-6'da kalma
  olasılığı `1 − (1 − p)^3`'tür, ölçüt ancak `p ≤ 0,331` iken tutar. Tavandaki `p = BASE × TIER × 2,5`: cloud 0,25 ✅,
  enterprise 0,15 ✅, **local 0,375 ✗** (dışarıda kalan %24).
- **Öneri: `P_MAX` 0,30** (B_PLAN 0,6). PRD'nin `BASE` 0,10'u değişmez; cloud ve enterprise hiç etkilenmez (tavanları
  zaten altında). local'de olay/koşu 13,4 (`fix_worst` B2B) · 14,0 (B2C) · 13,6 / 14,7 (`fix_none`), 4-6 dışı %33-34.
  B0'ın `BASE` 0,08 önerisi de tutar ama PRD'nin sabitini değiştirir ve cloud'u 9,7-11,3'e indirir; tercih edilmedi.
- B_PLAN'ın `MIN_GAP_AFTER_S1` 6'sı PRD'de yok (Karar 2: tek kural 4 hafta); kodlanmaz.

**Tür karışımı (cloud, `fix_worst`):** B2B kesinti 11,0 · ay sonu 0,51 (koşuların %40'ı); B2C ödeme 5,4 · kesinti 5,6 ·
fırtına 1,1. B2B olayların %95'i kesinti, B2C'de ödeme kesinti kadar sık. Ağırlık değiştirmek tasarım kararıdır: Erdem'e
soru (B0 §4 son madde aynen).

**Görünürlük (B0_HARITA W17).** Güven izi haftada 2,8 affedilir ve satisfaction hedefe tikte en çok 21 puan yürür:
oyuncunun gördüğü düşüş ilk hafta `|iz| − 2,8`'dir. Bu yüzden `PAPER_TRUST_HIT` −8 (görünen −5,2) ve
`PROMISE_EXTEND_TRUST` −6 (−3,2) görünür; `DEFER_TRUST_B2B`'nin sprint başı −3'ü, kesintinin "öbür hesaplar" −2'si ve
kredili −1'i hiç görünmez. Eşik değil, sabit sorusu: R'de Erdem'e.

**Ay sonu haftası** takvim ayının son tikidir (`GameState.get_date_dict`, `summary_system.gd:57-59`); modelin 30 günlük
ayı (`7/30`) yılda aynı sayıda ay sonu verdiği için §1-§4'ün sayıları değişmez.

**Değişmeyenler:** `MONTH_CLOSE_LINE_BUGS` 3, `RELEASE_REVIEW_NEG_LINE_BUGS` 5 (olumsuz yorum metni 4 ortak hat ve kimlik
hatları için var, W3), `ROOT_MIN` 3, `RENEWAL_WINDOW` 12, `B2C_NIGHT_TRY_SHARE` %1,5, depo sektörleri, durum ekranlı
hatlar, `SLOW_SEATS` 15, `NEW_ACCOUNT_WEEKS` 8, kupon tetiği Entegrasyonlar. Hepsi makul; ölçülebilenler B3'ün `PROBE
LINES` koşusunda teyit edilir.
