# RAPOR Q · Ürün kalitesi · devir raporu
Faz Q kapandı (2026-10-22). Bütün kod `main`'de commit'li, push yok. Ağaçta Q'nun commit'lenmemiş farkı yok. Görev:
`PRD_FAZ_Q_KALITE.md`. Erdem'in sonraki kararları: `ERDEM_KARARLAR_2026-10-20.md`. Çalışma dosyaları
`docs/tasks/faz_cde/q_calisma/` altında; bu klasör izlenmiyor:
- adım defteri `q_calisma/R_DEFTER.md`;
- E1 durağı `q_calisma/E1_OLCUM.md`;
- taban `q_calisma/Q0b_TABAN.md`;
- E1 ölçümü `q_calisma/K8_TABLOLAR.md`;
- kapanış ölçümü `q_calisma/K9_TABLOLAR.md`.

**Q'nun son commit'i: `7012218a` (K20).**
- Ana tur K0'dan K9c'ye (`910ad1f`) 18 ile 20 Ekim arasında koştu; §1 ile §10 o turu anlatır.
- İkinci ve üçüncü tur (K10 ile K24, 20 ile 22 Ekim) Erdem'in 2026-10-20 kararlarını uyguladı; bu tur §0'dadır.
- Yardımcı yönetmenin 2026-10-22 kararı:
  - K22'de kalan aileler (§0.3) şimdi silinmiyor.
  - Bulunup düzeltilmeyenler (§0.4) işler bitince yapılacak kod denetiminde ele alınacak.
  - TR/EN onayı bekleyen metinler (§0.5) tek metin turuna gidiyor (Erdem'in 30. kararı: "araştırma ve tasarım bittikten sonra
    tek metin turu; bugünkü metinler büyük ölçüde kabul").

## 0. Devir: ikinci ve üçüncü tur (20 ile 22 Ekim)
### 0.1 Durum
- ✅ Erdem'in Q'ya verdiği kararlar uygulandı: takvim, 17-24 ve tire kuralı (aşağıdaki tablo). Tek istisna 20. kararın
  inceleme yarısı, o kayda geçmedi (§0.4 madde 7).
- ✅ Oyuncuya görünen hiçbir metinde tire (— –) yok. Bunu artık iki kapı denetliyor:
  - event-lint kuralı 17.8 kartın bütün metin bloğunu tarar;
  - `loc_csv_integrity` CSV'nin her kaydını tarar.
- ⚠️ Ana turun ❌'ları (§1 madde 1, 2, 3) kodda olduğu gibi duruyor. Bugünkü yerleri §0.6'da.
- Kayıt şeması 18. Bu turda göç yok. Q'nun yeni `class_name`'i yok.

### 0.2 Commit'ler ve oyuncunun gördüğü
| Commit | Adım | Oyuncu ne görür |
|---|---|---|
| `2d28b521` | K10 | Takvim 1 Ocak 2012 Pazar'da başlıyor. Tarih satırı, gelen kutusu, dönem özeti, gazete künyesi ve kayıt yuvası 2012'den sayıyor ("Hafta 1 · Ocak 2012"). Piyasa'nın bağlam satırı 2012 verisiyle aynı yılı okuyor. |
| `e4e7e9b9` | K11 | Değişen bir şey görmez. Okuyucusu olmayan 14 anahtar silindi: Frank'in dört ürün satırı ve on `HR_AREA_MEANING_*` (Erdem'in 18. ve 19. kararı). |
| `f89bb4fa` | K12 | VC görüşmesinin ilk seçeneği "Odayı oku." / "Read the room." oldu; açılış satırı tiresiz. Satış zarının satırları büyük harfle başlıyor ("Ürün uyumu · Çekirdek Zayıf"). Erdem'in 20. ve 21. kararı. |
| `e22a0650` | K14 | Beş sprint kâğıdında "serbest çalışana yaptır" seçeneği yok. Dışarıdan iş kâğıdı (`sprint_dev_contractor`) hiç gelmiyor. Erdem'in 24. kararı. |
| `3bc600f2` | K15 | "Kapsam büyüdü" kâğıdı "Tasarlandığı gibi yap" diyor (önceden "Çizildiği gibi yap"); başlığı "Kartı tasarlarken büyüttük". Eldiven kâğıdı "Tasarlandığı gibi kalsın" diyor. |
| `c6160c89` | K13 | Değişen bir şey görmez. ACIK_KARARLAR ve ISLER bugünkü koda göre temizlendi (Erdem'in 22. ve 23. kararı). |
| `1b9f2f31` | K16 | Beş kartta "birini tut" seçeneği yok (test, güvenlik açığı, destek taşması, şifre kuralı, silinen tablo). Tek kurucuya hazır bileşen lisansı kâğıdı gelmiyor. Son işlemlerde "Dış kaynak ücreti" satırı yok. Eski kayıttaki bu satırlar yüklemede düşüyor; kasa değişmiyor. |
| `93e41314` | K21 | Değişen bir şey görmez. Okuyucusu olmayan 18 anahtar silindi, kapanan açık kararlar temizlendi. |
| `76994ff7` | K17 | Satış görüşmesinin zar kartı en etkili dört etkeni ve "+1 etken daha" / "+1 more factor" satırını gösteriyor (önceden "Ve daha fazlası"). İkna yüzdesinin ipucu bütün etkenleri sıralıyor. |
| `d1a87739` | K18 | Panel satırları büyük harfle başlıyor ve tiresiz. Örnekler: VC zarında "+ Karizma"; risk sözcüğü "Riskli / Güvenli / Tehlikeli"; term sheet masasında "Temel %45 · +%30 satış"; tohum masasında "İma edilen değerleme $812.500"; olay kartı çipi "Müdahale yok · …". |
| `006bc28a` | K19 | 2026 takvimiyle kaydedilmiş bir koşu açılınca çalışanların yaz izni hakkı doğru yılda sayılıyor. Önceden "bu yıl izin aldı" 14 yıl takılı kalırdı. |
| `72b2b785` | K23 | Değişen bir şey görmez (yalnız çekim harness'i). Teklif süresi kartı kendi dünyasında çekiliyor; gövdeye 69993 gibi yedek değer çıkmıyor. |
| `03d24a3d` | K24 | Değişen bir şey görmez (yalnız çekim harness'i). `--event-shot` katalogdaki her kartı kendi dünyasında çekiyor; gövdeye `{customer}` kalıntısı, boş ad, $0 ya da "Sprint 0" çıkmıyor. Katalogdaki 129 kartın hepsi TR ve EN tarandı. |
| `cf452525` | K22 | Değişen bir şey görmez. Okuyucusu olmayan 155 anahtar ve onlara bağlı ölü kod silindi (şirket geçmişleri, aday dosya notları, ilişki etiketleri ve başkaları). |
| `7012218a` | K20 | Hiçbir metinde tire yok: 14 satır yeniden noktalandı, Frank'in beş satırı da bunlara dahil. Av'ın kilitli satırında "2. kademe fonu" / "Tier 2 fund" yazıyor (önceden "— · Tier 2'de"). Satış hesap kartında temsilci yokken satır "Müşteri temsilcisi: atanmadı" diyor. Ekip Kadro'da işi olmayanın GÖREV hücresi ve rozeti olmayanın DURUM hücresi boş. PM "masaüstüne göre tasarladık" diyor. |

İki ara commit Faz C'nindir: `ec781975` (kayıt parmak izi fikstürü) ve `50dcb19c` (C2b runway seam'i). Q'nun dosyalarına
dokunmadılar; K24'ün C2b'ye bıraktığı iki kartı onlar kapattı.

### 0.3 K22'de kalan aileler (okuyucusu yok, bilerek bırakıldı)
CLAUDE.md §2 ve §3 gereği silinmedi: hepsinin bir GDD maddesi ya da açık bir ACIK maddesi var. Yardımcı yönetmenin
2026-10-22 kararıyla şimdi silinmiyorlar; maddeleri kapanınca kod denetiminde ele alınacaklar.

| # | Aile | Bağlı olduğu madde |
|---|---|---|
| 1 | `PROD_STEP_*_DESC` (90 satır, kademe açıklamaları) | GDD ch03 §12.12; ACIK 50 ("Kademe açıklamaları yazılmış ama hiçbir ekranda görünmüyor") |
| 2 | `RND_NEED_CROSS_BLIND` | Ar-Ge GDD §3; ACIK 26 ("Kilitli yuvada çapraz koşul satırı yok") |
| 3 | `unwired/` kartlarının 7 satırı | GUNCELLEMELER "metin korunur" |
| 4 | `PROD_FEAT_*` (122 satır; `_VOICE` ailesini yalnız smoke okuyor) | GUNCELLEMELER, düz kataloğun silinmesini ACIK 44'e ("Düz özellik kataloğunun emekliliği") bırakıyor |
| 5 | Mühürlü üç tipin `PROD_TYPE_*_BET` ve `_PITCH`'i | GDD ch03 |
| 6 | 23 `SECTOR_*` satırı, `ProductCatalog.type_sector_labels`, tiplerin `sectors` alanı | ISLER yeniden yuva listesi |
| 7 | `HEALTH_*` | ACIK 40 ("Kayıtlı ama okunmayan `Customer.health` alanı"), B seçeneği |

Okuyucusu olduğu için kalanlar şunlar. 13 tipin `_NAME`'i, eski kayıtta o tipi koşan ürünün adı olarak okunuyor. Tip ekranının
kilitli beş kartının `_CATEGORY`, `_DESC` ve `_TRADEOFF`'u da okunuyor (GUNCELLEMELER ch14 §2). `FEATURE_LABEL_*`'ın hepsi ise
eski kayıttaki hesapların isteklerini adlandırıyor.

### 0.4 Bulunup düzeltilmeyenler
Hepsi işler bitince yapılacak kod denetimine gidiyor.
1. **Üç PM kâğıdı oyunda hiç gelmiyor.** `urun.decision_request_votes` tüketici talep verisi olmadığı için hep 0 döner.
   Bu yüzden `sprint_pm_core_first`, `sprint_pm_phone_too_b2c` ve `sprint_pm_spec_unclear_b2c`'nin koşulu tutmuyor
   (K24 taramasında gövde "0 kişi").
2. **"Boşta"nın yeri GDD'den ayrılmış ve bu yazılmamış.** Ekip GDD §12.2'ye göre "Boşta" görev sütununun metni. Kod ve onaylı
   Menajer maketi ise onu DURUM rozetine koyuyor. Bu ayrılık ACIK_KARARLAR'da yok.
3. **Boş GÖREV hücresi hiçbir karede görülmedi.** Ürünü olan ama işi olmayan bir Kadro çalışanı için çekim fikstürü yok.
   K20'nin karelerinde GÖREV hep "Henüz yapılacak ürün yok" diyordu.
4. **İflas sonundaki sayı belgeyle çelişiyor.** Frank'in iflas satırı oyunda "28 gün kırmızıda kaldın" diyor
   (`END_META_BANKRUPTCY_FRANK`); `docs/writing/FRANK_ORPHANS.md:43` ise "thirty" yazıyor. Belgedeki paragraf bayat. Sayının
   haftalık zaman modeliyle uyuşup uyuşmadığına bakılmadı.
5. **EN ekranda haber şeridinin kaynak adları Türkçe.** "Gündem", "Girişim Bülteni", "Sektör Telgrafı" ve "Ekonomi Postası"
   EN'de de Türkçe çıkıyor. Bunların marka adı olarak bilerek mi bırakıldığına bakılmadı.
6. **Motor md ağaçta olmayan bir PRD'ye atıf yapıyor.** `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` §27.36 izlenmeyen
   `docs/tasks/faz_cde/PRD_FAZ_Q_KALITE.md`'yi anıyor. Erdem'in 23. kararı faz PRD'lerini repoya almıyor, o yüzden atıf
   ya silinmeli ya da içeriği md'ye yazılmalı.
7. **Erdem'in 20. kararının ikinci yarısı hiçbir yere yazılmamış.** Karar şunu soruyor: VC'nin "Odayı oku." seçeneği ne
   değiştiriyor, karizmaya mı bağlanmalı, gerek var mı? Bu soru ISLER'de de ACIK'ta da yok.
8. **Kapsam büyüdü kâğıdında bedelsiz görünen bir seçenek var.** `sprint_pm_scope_grew`'ün "Tasarlandığı gibi yap"ının tek
   bedeli kartın bu sprintte bitmemesi ve çipi nötr (K14 denetimi). K14'ten önce de böyleydi.
9. **`--event-probe`'un bir satırı düşüyor:** "week 2: the opening card is admitted (G4)". K10'dan önce de, takvim 2026'dayken
   de düşüyordu.
10. **Bayat belge satırları:** `docs/mockups/menajer/baseline/INDEX.md:218` (`--event-shot` temsilî kart seti anlatısı).
    `docs/writing/FRANK_ORPHANS.md`'deki "The number" paragrafı (madde 4).
11. **Sözlükte olmayan iki kelime:** "Callback" ve "term sheet" ne sözlükte ne izinli ödünç kelime listesinde
    (ACIK "Karışık dilli satırlar").
12. **Aralık yazımı tek tip değil.** Oyuncu metninde aralık "X ile Y" yazılıyor; ASCII tireyle yazılan tek anahtar
    `SUMMARY_RANGE`. Kural hiçbir yere yazılmamış.
13. **Ana turun ISLER adayları yazılmadı** (§9 soru 13): `ProductLines.reload()` GDScript'in `Script.reload`'una gidiyor
    olabilir; `--tab-shot=product` tema tohumu kırık. ISLER C-10'un "%14 düşük fiyat" ölçüsü yeni kalite terimiyle yeniden
    ölçülmedi.

### 0.5 TR/EN onayı bekleyen metinler
Bunlar tek metin turuna gidiyor. Ana turun metinleri §4.3'te.
- **K12:** `VC_B1_CHOICE` "Odayı oku." / "Read the room." (Erdem'in kararı). Kararın dışında kalan, aynı ekrandaki `VC_B1_LINE`
  "{investor}. Otur. Vaktim kısa. Beni neden buraya çağırdığını göster." Zar panelinin sekiz `SALES_MOD_*` etiketi büyük harfle.
- **K15:** `sprint_pm_scope_grew` ("Kartı tasarlarken büyüttük", "Tasarlandığı gibi yap" ve gövdesiyle süre notu) ve
  `sprint_design_gloves` ("Tasarlandığı gibi kalsın" ve süre notu).
- **K16:** Beş kartın silinen "birini tut" seçenekleri ve lisans kâğıdının bütün metni. Silinen `[WORKING]` sabitler
  (`paper.outside_week_mult`, `paper.license`) sabit olarak onay bekliyor.
- **K17:** `EV_MODIFIERS_MORE` "+{n} etken daha" / "+{n} more factors", `EV_MODIFIERS_MORE_ONE` "+{n} more factor".
- **K18:**
  - Büyük harfe geçen satırlar: `TERM_SPLIT_BASE`, `SEED_IMPLIED_POST`, `MEETING_RISK_SAFE`, `MEETING_RISK_RISKY`,
    `MEETING_RISK_DANGER`, `EFFECT_RETAIN_IGNORE`.
  - Tiresi kalkan satırlar: `VC_B4_CALLBACK`, `VC_B4_PUSH`, `TERM_LEVERAGE_BOX`, `VC_Q_CHURN`.
- **K20:**
  - Yeniden noktalanan dokuz kayıt: `DESK_PAPER_GATE_TITLE`, `PERSONAL_MS_SHIP_NOTE` ("Ürün raflara çıktı; artık dünya da
    oynuyor."), `ANGEL_MONTH_HIGHLIGHT`, `HUNT_COUNTER_PIVOT`, `END_HL_SHUTTER_STARTED` ve dört `PROD_FEAT_*_VOICE`.
  - Yeni `HUNT_TIER2_SLOT` "2. kademe fonu" / "Tier 2 fund".
  - `REC_AM_NONE`'un satış hesap kartında da okunması ("atanmadı" / "not assigned").
  - PM'in "tasarladık"ı (`sprint_pm_phone_too` ve `_b2c`).
  - **Frank'in beş satırı ayrıca** (külliyat Erdem'in):
    - `GATE_ADVANCE` "Hazırız, geçelim" / "We are ready, let us move"
    - `GATE_SERIES_A_BODY_0` "… Runway'in dar da olsa girebilirsin, ama masada kokusunu alırlar." / "… Thin runway or not,
      you can walk in, but they will smell it at the table."
    - `PROD_EV_VERSION_SHIP_BODY`, `END_META_SERIES_A_CLOSE_FRANK`, `END_META_BANKRUPTCY_FRANK`

### 0.6 Ana turun açık konuları bugün nerede
| Konu | Bugün |
|---|---|
| §1 madde 1 ve §9 soru 1: 2★ Çekirdek 1,25 mi, 1,5 mi | Beklentinin yeniden tasarımına bağlandı ("bu tasarımla konusuz", ERDEM_KARARLAR "Beklenti araştırması sonucu"). Pazar merdiveni reddedildi; gerçek ERP pazarı araştırması (Pazar 2) ve C'nin PLAN_C_P2'si (5 yıldız, modüller) sürüyor. Kod bugün `CORE_2` 1,25. |
| §1 madde 2: satışçı zarı neredeyse hiç atılmıyor | Aynı yere bağlandı. Pazar merdiveni K8: %60 tabanı kalkar, satışçı yıldızının etkisi araştırılır, iş C'nin. Kod bugün `CLOSE_CURVE` ile. |
| §1 madde 3: B2C kitle eğrisi 18/24 | Karar yok. Kod C10 değerleriyle (`WOM_*`). |
| §9 soru 2: E1'in ikinci turu | Cevap yok; yapılmadı. |
| §9 soru 3: ACIK 52 ve 59, ISLER C-13 | ✅ 52 ve 59 K9d'de, C-13 K21'de silindi. |
| §9 soru 4: alanlara özgü cümleler | ✅ Erdem'in 17. kararı: geri gelmez. |
| §9 soru 5 ve 6: Frank'in dört satırı, on İK cümlesi | ✅ 18. ve 19. karar, K11'de silindi. §4.3'ün "İK alan anlamı" satırı da bu yüzden konusuz. |
| §9 soru 7: rakip modeli | Pazar merdiveni K2: kopyalama yok, rakipler bizim gibi şirket. C'nin PLAN_C_P2 kapsamında. Kod bugün üç eski eksenle (`RivalCatalog.COMPOSITE_AXES`). |
| §9 soru 8: `VC_B1_CHOICE` tiresi | ✅ 20. karar, K12. Seçeneğin işlevi sorusu kayıtsız (§0.4 madde 7). |
| §9 soru 9: "Kitlen büyüdükçe" cümlesi | 30. karar (bugünkü metinler büyük ölçüde kabul): tek metin turunda. |
| §9 soru 10: zar ipucu harfi | ✅ 21. karar: büyük harf, K12. |
| §9 soru 11: bayat açık kararlar | ✅ 22. karar, K13. |
| §9 soru 12: ağaçta olmayan PRD'ye atıf | 23. karar: PRD'ler repoya alınmaz. Atıf duruyor (§0.4 madde 6). |
| §9 soru 13: ISLER adayları | Yazılmadı (§0.4 madde 13). |

### 0.7 Sonraki oturum için çalışma notları
- **Ortak ağaç:** Q, C ve D aynı ağaçta çalışıyor.
  - Sahnelemeden önce duyur; commit'ten sonra "index boş" yaz.
  - Godot'yu sırayla kullan: önce "kapı bende" yaz, işin bitince "bitti" yaz.
  - Commit'e yalnız kendi dosyaların girer. `project.godot`'taki editör satır sırası farkı kimsenin değildir, commit'lenmez.
- **Kapıyı nerede koşmalı:** Bellek baskısında (16 GB'ın yaklaşık 3 GB'ı boşken) Claude Code arka plandaki işi durduruyor.
  Sahnelenmiş ağacı ayrı klasöre aktarıp orada koşmak bu yüzden iki kez düştü. K20'nin kapısı Erdem'in onayıyla çalışma
  klasöründe, CLAUDE.md §12'nin komutlarıyla, ön planda ve birer birer koşuldu. Sarmalayıcı betik izin denetiminden geçmedi;
  düz komutlar geçti.
- **Commit:** `git -c gc.auto=0 commit`. Otomatik `gc` bellek baskısında yarıda kalıyor.

Ürünün tek kalitesi artık sprint ekranındaki alanlardır. Üç gizli eksen (İnovasyon, Kararlılık, Deneyim) koddan, veriden ve
kayıttan silindi. Ürün uyumu U (0-100) müşterinin büyüklüğüne (yıldız) ve sektörüne göre okunuyor. Satış görüşmesi, satışçının
kapanışı, hesabın memnuniyeti, yatırımcı, B2C kitlesi ve taban kartları aynı kaynaktan (`ProductQuality`) okuyor.

Erdem'in bu fazdaki kararları:
- 18 Ekim: onay bekleyen sayılar geçici yazılır; damga zinciri ve kapı üstü bonusu silinir; `QUALITY_AXES` rakip modeline taşınır;
  ACIK 59, 10 ve 52'yi Q kapatır.
- 19 Ekim, E1: kapılar 2★+3★ satırından okunur; 2★ satırı sertleşir; imza düşüşü kabul (kapı %55-65); B2C eğrisi tabana çekilir
  ve ürün sayfası B2C'de en az 2★'ı okur.
- 19 Ekim, kapanış: B2C eğrisi için C10 ("C10'u yaz"); B2B yavaşlayınca 2★ Çekirdek beklentisi 1,5 yerine 1,25.

Bütün sabitler ve metinler **onay bekliyor** (§4). Onaylı olanlar ayrıca yazılı.

---

## 1. Önce bakılacaklar (cevabın oyunu değiştirdiği konular)
Bu bölüm ana turun kapanışındaki (`910ad1f`, 20 Ekim) hâldir. Bu konuların bugün nerede durduğu §0.6'da.

1. ❌ **B2B hızı ile 2★ doyumu arasındaki seçim (§9 soru 1).**
   - Çekirdek 1,25 B2B'yi biraz hızlandırdı. Kurucunun tek başına sattığı dört kolda 52. hafta MRR'ı 52-66 bin oldu (1,5'te 38-63
     bin, eski kodda 63-110 bin). Series A Avı'na giriş 88-98. haftaya geldi; sekiz koşunun biri hiç varamadı (1,5'te 94-99,
     üçü hiç; eski kodda 57-83). Temkinli VC kolu iki tohumda da Series A'yı kapattı (92. ve 101. hafta; 1,5'te biri kapattı).
   - Bedeli: 2★ ve 3★ imzaların %40'ında ürün müşteriyi tamamen doyuruyor (U = 100). PRD kapısı en çok %25; 1,5'te bu pay %0'dı.
     Traction'daki 2★+3★ imza ortancası 86 (kapı 70-85).
   - Asıl açık ilk 26 haftada: 26. hafta MRR'ı 1,25 ile 1,5'te aynı (16-28 bin), eski kodda 38-47 bin. Bu, E1'de kabul ettiğin
     imza düşüşü (MVP sonrası 26 haftada imza eski kodun %62'si). Erken 2★ aday MVP'yle karşılaşıp zayıf alandan kaybediliyor.
     Çekirdek beklentisi bu haftalara dokunmuyor.
2. ❌ **Satışçı zarı neredeyse hiç atılmıyor (§4.4-5).** Masalı fix_worst kolunda 328 satışçı kapanışının hiçbiri kaybedilmedi
   (kapı %5-15; 1,5'te 1/312). Zar yalnız müşterinin baktığı bir alan eksikken atılıyor. Satışçılar 1★ ve 2★ bandında çalışıyor
   ve ürün o bandı doyuruyor. Yalnız Çekirdek'e yatıran kolda zar çalışıyor (2★+3★ kaybı %45,5 ✅). C'nin imza kapısı ve
   `CLOSE_CURVE` kararıyla birlikte ele alınmalı.
3. ❌ **B2C kitle eğrisi 24 okumanın 18'inde eski kodun ± %20'sinde** (1,5'te 19/24). En büyük sapma +%46. 1,5'teki uç sapma (fix_none
   tohum 7, 104. hafta +%382) bu ölçümde +%45; nedenini ayrıca ölçmedim. Bant dışı altı okumanın dördü 104. haftada, biri 52.,
   biri 26. haftada. Önerim: kabul. PRD'nin 24/24 hedefi bu modelde tutmuyor (§8 PRD düzeltmeleri).
4. ⚠️ **§4.5-2 ölçülemiyor:** yalnız Çekirdek'e yatıran kol 104 haftada Series A Avı'na hiç varmıyor. Yani yalnız Çekirdek'e
   yatırmak kaybettiriyor, sektörün vurgu alanları önemli. §4.5-1 PRD'nin sözüyle tutuyor (fark −49 puan), yön ters.
5. **E1'in ikinci turu onay bekliyor (§9 soru 2).** 1★ müşterinin bakmadığı alan bugün "Yok" sayılıyor. B2C'de hiç yapılmamış
   alan uyarı kartını atlıyor.
6. **Bilmen gereken yan etkiler.**
   - 2★ vurgu beklentisi tam 1 olduğu için Ar-Ge bir alana gizli hat açınca o alanın seviyesi (boş hat) yarıya iner ve 2★ adayların
     U'su düşer. Hat bitince geri gelir.
   - B2C ürün sayfası küçük kitlede de 2★'ı okuyor. VC'nin zayıf alan sorusu ve yatırım masasının "eksik alan yok" +4'ü de aynı
     referansı okur, o yüzden az alanlı küçük B2C ürünü zayıf sayılır.
7. **Rakip modeli de elden geçmeli (§9 soru 7).** Rakiplerin kalitesi hâlâ üç eski eksenle hesaplanıyor, oyunda okuyan yok.

---

## 2. Sana açıklama: E1'deki "kapı kapsamı" kararı
E1'de "bu konuda hiç bir şey anlamadım, iş bitiminde açıkla" dedin. Sade hâli:

**Neydi.** PRD, kalitenin işe yarayıp yaramadığını birkaç ölçütle sınıyordu. En önemlisi şuydu: "imzaların en çok dörtte biri
tam uyumla (U = 100) atılsın". Yani müşterilerin çoğu ürünü beğenip imzalasın, ama ürün onları tamamen doyurmasın; oyuncu hep bir
sonraki sürümü kovalasın. Bu ölçütler bütün imzalardan sayılıyordu.

Sorun 1★ müşterilerdi. Küçük bir muhasebe bürosu (1★) tasarım gereği MVP'yle doyar: "Bu hâliyle 1★ şirketlere yeter." Botun
imzalarının üçte ikisi 1★ olduğu için bütün imzalara bakınca ölçüt hep "çok fazla tam uyum" diyordu (E1'de %68). Bunu tutturmanın
tek yolu 1★'ı zorlaştırmaktı. O da oyunun ilk saatini cezalandırırdı: MVP'yi çıkaran oyuncu ilk küçük müşterisini de kaybederdi.

**Nasıl değiştirdik.** Ölçütleri yalnız 2★ ve 3★ imzalardan sayıyoruz, yani orta ve büyük şirketlerden. Sorulan soru artık "büyük
müşteriler ürünü kovalatıyor mu". Bu kararla oyunda hiçbir kural değişmedi; değişen yalnız ölçümün hangi imzalara baktığı. Ama
2★ satırını sertleştirme kararı bunun üstüne kuruldu: ölçüt 2★'a bakınca 2★ satırının gerçekten bir şey istemesi gerekti.
- E1'e kadar (Q'nun ilk tablosu): 2★ şirket için Çekirdek'in ilk sürümü yeterdi. Ürün 2★'ı erken doyuruyordu: 2★ imzaların %46'sı
  tam uyumla.
- E1'den sonra: 2★ şirket Çekirdek'in her hattının ilk sürümünü ve yarısının ikinci sürümünü (1,5), sektörünün iki vurgu alanının
  da ilk sürümünü ister.
- Kapanışta senin kararınla: Çekirdek'in her hattı ilk sürümde ve dörtte biri ikinci sürümde (1,25) yeter.

**Şimdi ne.** Ölçüt yalnız 2★ ve 3★ imzaları sayıyor. 1★ müşteriler MVP'yle doymaya devam ediyor.
- 1,25'le bot ürününde 2★ ve 3★ imzaların %40'ında ürün müşteriyi tamamen doyuruyor (kapı en çok %25; 1,5'te %0'dı).
- Örnek: ERP'n Traction'da, Çekirdek'in beş hattından ikisi ikinci sürümde, sektörün iki vurgu alanı ilk sürümde. Ürün sayfası
  Çekirdek'e "Yeterli" der ve "Bu hâliyle 2★ şirketlere yeter. 3★ şirketler daha fazlasını ister." yazar; 1,5'te üçüncü hat da
  ikinci sürümde olmalıydı.
- 3★ şirket hâlâ uzak: Çekirdek'in bütün hatları ikinci sürümde, vurgu alanlarının hatlarının yarısı ikinci sürümde ve öbür
  alanlar ilk sürümde olmalı. Bot iki 104 haftalık koşuda toplam 7 tane 3★ imzalıyor.
- Hızla doyum arasındaki seçim §1 madde 1'de ve §9 soru 1'de.

---

## 3. Kabul ölçütleri (PRD §4)
Kapanış ölçümü `910ad1f`'te. "1,5" sütunu aynı ölçümün K9b'deki (`bd9a5ed`, Çekirdek 1,5) hâlidir. Kapılar E1 kararıyla 2★+3★
imzalardan okunur; "masalı" = temsilci masasıyla oynayan ikiz kol (`_desk`).

| PRD | Kapı | Hedef | 1,5 | Son (1,25) | Durum |
|---|---|---|---|---|---|
| §4.1 | Eksen belirteçleri | 0 (göç istisnası) | 2 satır | 2 satır (`save_codec.gd:25` ve fikstürü) | ✅ |
| §4.2 | Uç vakalar | smoke | yeşil | `product_fit_table`, `fit_star_context`, `fit_scale`, aile 123/123 | ✅ |
| §4.3 | Nedensiz U değişimi | 0 hafta | 0 | 0 (9 B2B kolu × 2 tohum, 1.684 hafta) | ✅ |
| §4.4-1 | İmzada U = 100 payı, 2★+3★ | ≤ %25 | %0 (0/107; masalı 0/376) | %40,3 (60/149); masalı %27,4 (133/485) | ❌ |
| §4.4-2 | Traction 2★+3★ imza U ortancası | 70-85 | 72 (masalı 67) | 86 (masalı 74) | ❌ (masalıda ✅) |
| §4.4-3 | Traction'ın ilk 12 haftasında 2★ aday U ortancası | ≥ 48 | 45 | 50 | ✅ |
| §4.4-4 | MVP sonrası 26 haftada imza ÷ eski kod | %55-65 (E1) | %61,2 | %62,4 (103/165) | ✅ |
| §4.4-5 | Satışçı kapanış kaybı, masalı fix_worst | %5-15 | %0,3 (1/312) | %0 (0/328; 2★+3★ 0/19) | ❌ |
| §4.4-5 | aynı, masalı quality_core, 2★+3★ | ≥ %20 | %54,8 | %45,5 (15/33) | ✅ |
| §4.4-5 | Kayıp maili haftada (kayıplı hafta başına) | ≤ 1 | 1 | 1 (15 kayıplı hafta, 15 mail) | ✅ |
| §4.4-6 | B2C kitle, 26/52/104. hf, eski koda sapma | ≤ %20 | 19/24 | 18/24 (en büyük +%45,6) | ❌ |
| §4.4-7 | VC zayıf alan cümlesi, koşu başına | ≤ 3 | en çok 2 | en çok 2 | ✅ |
| §4.5-1 | quality_core ile fix_worst farkı, Traction 2★+3★ | ≥ 10 puan | −33,5 | −49 (37 / 86); masalı −37 | ✅ (yön ters) |
| §4.5-2 | Series A Avı'nda 3★ aday payı farkı | ≥ 5 puan | ölçülemedi | ölçülemedi: quality_core Avı'na varmıyor (fix_worst %15,2) | ⚠️ |
| §4.5-3 | Sektörler arası 2★ U farkı / zayıf alan vurgu 1 farkı | ≥ 8 / ≥ 10 | 18 / 28 | 14 / 24 | ✅ |
| §4.5-4 | Kurucu kaybında alan adlı pay, 2★+3★ | ≥ %50 | %100 | %97,9 (47/48) | ✅ |
| §4.5-4 | Satışçı kaybında alan adlı pay | %100 | %100 | %100 (quality_core masalı 15/15) | ✅ |
| §4.5-5 | Traction haftalık kart ortancası | ≤ eski kod (3) | 2 | 2 | ✅ |
| §4.6 | 330 hesapta gece tiki | ≤ 148,2 ms (eski 141,1 + %5) | 134,8 | 133,6 (9 gecenin ortancası) | ✅ |
| §4.7 | Görsel kabul TR, EN, renk körü, 1,25 | temiz | 22 kare | K9c'nin 4 karesi + taban kartı cb ve 1,25 | ✅ |
| §4.8 | `run_gate` | 3/3, 0 ERROR | 3/3 | 3/3 (full_run ve full_run_b2c 104. hf, full_run_vc_cautious Series A 83. hf), 0 ERROR | ✅ |
| §4.8 | Plausibility | `fails=0` | 0 | 40 koşu 379 kart, uzun 4 koşu 270 kart, `fails=0` | ✅ |
| §4.8 | Sprint probu uyuşmazlığı | büyümez, adsız 0 | b2c 8, b2b 10 | b2c 8 (198/206), b2b 10 (156/166), adsız 0 | ⚠️ b2b adlı 7 → 10 |

§4.8'in b2b satırı: eski kodda 7 adlı uyuşmazlık vardı; E1 ölçümünde 10 oldu (aday dünyası kaydı) ve öyle kaldı. Hepsi adlı, adsız yok.

---

## 4. Onay bekleyenler
### 4.1 Sabitler
Hepsi kodda tek ayar yerinde ve `[WORKING] onay bekliyor` işaretli, aksi yazılmadıkça.

**Ürün uyumu ve yıldız tablosu (`ProductQuality`):**
- Onaylı: `FIT_SCALE` 70, `CORE_LEAD` 0,25, `W_CORE` 0,50, `W_B2B` [0,25; 0,15; 0,10] (K1); `CORE_2` 1,25 ve `EMPHASIS_2` 1
  (E1 ve kapanış kararı); `PAGE_STAR` 2'nin B2C ürün sayfasının tabanı olması (E1); `USE_AREA_MIN` 0,15 (K3b).
- Onay bekliyor: `RATIO_CAP` 1,5 (bir alanın fazlası uyuma eklenmez); 3★ satırı `CORE_3` 2, `EMPHASIS_3` 1,5, `REST_3` 1; 1★ Çekirdek
  hücresi (`mvp_lines` ÷ Çekirdek hat sayısı, yani MVP); `PAGE_STAR` 2 (B2B ürün sayfasının referansı); `AUDIENCE_STARS`
  1.000 / 10.000 / 50.000 (B2C kitlenin 1★, 2★, 3★ eşikleri); sektör tablosunun `textile` ve `media` satırları (PRD Karar 3).
- Rakip penceresi: `rival_bump`, `rival_max`, `rival_window` (`data/product/sprint.json`) anlam değiştirdi: yalnız aday ve ekonomi
  bağlamında, çıkış kaydı başına, pencere sprint cinsinden (K2).

**Satış (`ProductQuality`, `SalesConstants`, `SalesProbes`):**
- `CLOSE_CURVE` U ≤ 40 → %30 · 55 → %60 · 70 → %85 · ≥ 80 → %95 (satışçının kapanış ihtimali; K3b).
- Yıldız karışımı eşikleri `QUALITY_STRENGTH_LOW` 0,6 ve `QUALITY_STRENGTH_HIGH` 1,0 (eskiden 1,6; `market_fit(3) ÷ 70` okur; K3b).
- Vurgu sorusunun cevap deltaları `EMPHASIS_ANSWERS`: güçlü cevap 1,0, kabul 0,35, karizma 0,8 (eski Kararlılık satırından; K3a).

**B2B memnuniyeti (`B2BConstants`, `SalesSystem`; değeri aynı, ölçeği U oldu; K4b):** `TOLERANCE_BASE` 33, `TOLERANCE_PER_SCALE` 9,
`SECTOR_TOLERANCE_BONUS`, `SIGNING_SAT_OVER_TOL` 10, `SIGNING_SAT_MIN` 50, `B2B_BUG_SAT_PER` 0,3, `B2B_BUG_SAT_CAP` 20,
`ONBOARDING_GRACE_MARGIN` 2. Zayıf ürünle imzalanan 2★ ve 3★ hesap tabanla açılır ve Onboarding bitince hedefine düşer (C3a'nın konusu).

**B2C (`SalesSystem`):**
- `B2C_QUALITY_PER_FIT` 5/7 (kalite terimi = B2C U × 5/7; K4c).
- Ağızdan ağıza, Erdem'in C10 seçimi (K9b): `WOM_MULT_PIVOT` 233, `WOM_SAT_GATE` 65, `WOM_COEF` 0,00103.
- Anlamı kayan, değeri aynı: `EROSION_THRESHOLD` 25, `CHURN_COEF`, `VALUE_QUALITY_COEF` (kalite terimi artık 0-71, memnuniyet
  hedefi 70-100).

**Yatırımcı (`TermSheetTableSystem`):** `E_FIT_PRODUCT_DIMS` +4 artık "yayındaki ürünün sayfasında eksik alan yok" demek (K4v).

**Taban merdiveni (`ProductRead`, K5):** `FLOOR_WARNING_RATIO` 0,6, `FLOOR_CROSSED_RATIO` 0,4; `urun.trust_level`'ın "seviye 0" tanımı
(yarım adım; kapı == 0).

**Silinenler (Karar 1 ve 11, Erdem: "PRD ne diyorsa onu yap"; silinmesi onay bekliyor, K7b):** damga zinciri ve kapı üstü bonusunun
gerçekleşmeye etkisi; `UPGRADE_RATIO_MIN` 1,6 ve yükleme denetimi; `PHASE_BAR` 12,0 / 13,2 / 14,5; `BASELINE_LINES_PER_AXIS`;
`EMPTY_AXIS_PENALTY` 0,6; `READING_MIN` / `READING_MAX`; `NORMALIZE_HALF_SAT` 25; `KANO_COEF`.

### 4.2 Kurallar (PRD sessizdi ya da Q yorumladı)
1. B2C'de U, kitle iki yıldız satırının arasındayken iki satırın U'sunun kitle payıyla karışımıdır; eşikte U sıçramaz (K2).
2. B2C ürün yayından önce alan cümlesi yazmaz (K2).
3. Taban merdiveni kitlenin kendi referansını okur, ürün sayfasınınkini değil (K9a). Ürün sayfası küçük kitlede 2★ tabanını okuduğu
   için ayrıştılar; sayfayı okusaydı MVP'den hemen sonra taban kartları ateşlerdi.
4. Eksik alan varsa görüşme kaybının nedeni hep `weak_area`'dır; güven, eksik kademe ve geçiş riski nedenlerinin önüne geçer (K3a).
5. Zar ipucu küçük harf ("ürün uyumu · Çekirdek Zayıf"), öbür zar satırları gibi; PRD büyük harf yazıyordu (K3a).
6. Masadaki kurucunun kaybı mail değil, özet satırıdır; yalnız kayıplı haftada defter satırı kayıpların üstünde durur; "Temsilciye ver"
   geri dönüş kapısı kapalı adayda kapalıdır (K3b).
7. `area_row`'da beklentisi 0 olan alanın karesi 0'dır ama `word_for` "Güçlü" der; çizimi C'nin (K4b).
8. 2★ vurgu beklentisi tam 1 olduğu için Ar-Ge bir alana gizli hat açınca beklenti inmez, alanın seviyesi (boş hat) yarıya iner ve
   2★ adayların U'su düşer (K9a; `fit_star_context` sabitliyor).
9. E1'in ikinci turu (onaylanmadı, yapılmadı): (a) 1★ adayda beklentisi 0 olan vurgu alanı cevapta ve geri dönüş kapısında "Yeterli"
   sayılsın; (b) B2C taban merdiveninde seviyesi 0 olan alan kitle 1.000'i geçince önce bir hafta uyarı, sonra crossed alsın (bugün
   doğrudan crossed; uyarı kartı ve churn kartı o alanda hiç gelmez).
10. Plan varsayılanları (adım tablosuyla onaylandı): ürün sayfası ham seviyeyi okur, ekran yarıma yuvarlar; Gelir U'ya girmez;
    rakip artışı çıkış kaydı başına; `market_fit(3)` 13 sektör üzerinden; satışçının kaybı kurucunun kaybıyla aynı yola girer;
    `quality_core` kolu ERP + `fix: worst`.

### 4.3 Metinler (TR/EN onay bekliyor)
- **Ürün sayfası (K2):** `PRODUCT_STAR_NONE`, `_SKIPPED`, `_SERVES`, `_TOP`, `PRODUCT_AUDIENCE_ENOUGH`, `_OUTGROWN`. Eski 19 alan × sözcük
  cümlesi silindi; alanlara özgü tat ("Veri elle taşınıyor" gibi) gitti.
- **Satış görüşmesi (K3a):** `SALES_MEETING_OBJECTION`, `SALES_PROBE_PROBE_EMPHASIS_*`, `SALES_ANS_PROBE_EMPHASIS_A_*`,
  `SALES_LOCK_EMPHASIS_ENOUGH`, `SALES_LOCK_ONBOARDING_ENOUGH`, `SALES_LOSS_WEAK_AREA`, `SALES_MEMORY_WEAK_AREA`,
  `SALES_ARCH_OPS_CAUTIOUS_LINE`; ajanın yazdığı `SALES_REASON_STABILITY` ("ürün yeterince güvenilir değil (Güven & Ölçek)"),
  `PROD_TYPE_ERP_TRADEOFF`, `PROD_PATH_B2B_DESC`, `PROD_RND_NODE_BUG_TRACKER_UNLOCK`.
- **Satışçının kaybı (K3b):** `SALES_REP_LOST_TITLE`, `SALES_REP_LOST_BODY`, `SALES_WEEKLY_LOST` (PRD §3.4 birebir).
- **Yatırımcı (K4v):** `VC_Q_WEAK_DIM` `{area}` ile; iç ses "En zayıf alanı bulacak."
- **Taban kartları (K5):** `b2c_floor_signal` "Son yorumlar hep {seam:urun.floor_area} tarafına dönüyor." (ikinci cümle "Henüz bu
  yüzden giden olmadı" düştü); `b2c_floor_churn` "Ayrılış anketi iptallerin sebebi olarak {seam:urun.floor_area} tarafını gösteriyor."
- **İK alan anlamı (K7a):** konusuz. On `HR_AREA_MEANING_*` cümlesi Erdem'in 19. kararıyla K11'de silindi.
- **Ar-Ge (K7b):** `PROD_RND_NODE_DESIGN_SYSTEM_UNLOCK` "Mobil & Erişim hattının son kademesi ve ürünün kendi tasarım kademelerinden
  biri. Tasarım ağırlıklı kademeler artık daha az efor istiyor, çünkü onları hazır parçalardan kuruyoruz."
- Onaylı (Erdem 17 Ekim, K6): alan adı "İlk Kullanım ve Erişim" (kısa "İlk kullanım"), Ar-Ge düğümü "İlk Açılış Akışı".

---

## 5. Ölçüm
- **Kapanış (`910ad1f`):** 15 kol × tohum 7 ve 11 × 104 hafta, iki sprint probu, eski ve yeni tik probu × 3. 38 koşunun hepsi
  0 ile çıktı; her bot koşusunda tek `PROBE END`, `PROBE ERROR` ve motor hatası yok. Tablolar `q_calisma/K9_TABLOLAR.md`, hız
  kıyası (MRR 26/52/104. hafta, Series A Avı'na giriş, son) `q_calisma/K9_HIZ.md`.
- **Eski kod tabanı:** `q_calisma/Q0b_TABAN.md` ve `q_calisma/q0b_logs/` (K0 harness'iyle, Q'nun ilk kod commit'inden önce).
- **E1:** `q_calisma/K8_TABLOLAR.md`, `E1_OLCUM.md` (`bd7ed53`).
- **B2C eğrisi aday araması (K9a, K9b):** 10 aday küme; C10'un tablosu R_DEFTER'de.
- **Hız (kurucunun tek başına sattığı fix kolları, 52. hafta MRR, Series A Avı'na giriş):** eski kod 63-110 bin, 57-83. hafta;
  1,5'te 38-63 bin, 94-99. hafta ya da hiç (8 koşunun 3'ü); son hâlde 52-66 bin, 88-98. hafta ya da hiç (8 koşunun 1'i). Masalı
  fix_worst 112-139 bin, 50-56. hafta. Temkinli VC kolu Series A'yı 92. ve 101. haftada kapatıyor (eski kod 64-67). B2C 52. hafta
  MRR'ı 41-53 bin (eski kod 21-38 bin), Series A Avı 64-75. hafta (eski kod 73-81).
- **Komutlar:** `project-unicorn/`'dan, koşu başına ayrı `APPDATA`, en çok iki paralel:
  `--run-log=<preset>:104:sim:<tohum> --lang=tr`; `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1[:market=b2b]`;
  `--tick-probe=3` ve `--tick-probe=3:accounts=330` tek başına. Tabloları çıkaran betik (`k8_tables.py`) ve hız betiği repo dışında
  (oturumun scratchpad'i); okuma kuralları tabloların başlıklarında yazılı.

---

## 6. Commit listesi
| Adım | Commit | Ne |
|---|---|---|
| K0 | `beb797e` | Taban harness'i: PROBE LEAD, PROBE SIGN'a imza anı alanları, PROBE AREAS, PROBE VCQ, `--tick-probe=…:accounts=<n>` |
| K1 | `d211d65` | `ProductQuality` sözleşmesi, 13 sektör tablosu, hat `profile` + `ProductLines.work_profile` |
| K6 | `1ba4a69` | "İlk Kullanım ve Erişim" ve "İlk Açılış Akışı" TR adları |
| K2 | `9a0dff9` | Yıldız beklentisi, B2C kitle bağlamı, rakip penceresi, `Customer.market_ref`, şema 18, ürün sayfası sözcüğü ve yıldız cümlesi |
| K4v | `2af6eef` | VC ve yatırım masası alan dili: `weakest_area`, `VC_Q_WEAK_DIM` |
| K5 | `f549597` | B2C taban merdiveni alanlara, `urun.floor_state` / `floor_area` / `trust_level`, altı kart |
| K4c | `fb0372f` | B2C kitle, memnuniyet ve fiyat U'yu okur (`b2c_quality`) |
| K3a | `3f988dc` | Satış görüşmesi U'yu okur, vurgu sorusu, itiraz, `LOSS_WEAK_AREA`, geri dönüş kapısı |
| K8a | `75041f6` | Ölçüm harness'i: PROBE FIT, UFLUX, `_desk`, `quality_core`, `vc_product` kolları |
| K3b | `85603d5` | Satışçı zarı, kayıp maili ve özet satırı, yıldız karışımı, 13 sektör satışta, üyelik |
| K7a | `02d22dc` | Ar-Ge tasarım indirimi iş profilini okur |
| K4b | `31f962c` | B2B memnuniyeti `account_fit`'e kayar, imza tohumu adayın U'su, `area_row` |
| K8b | `6e33b56` | PROBE MLOSS (kurucunun kaybı) |
| K7b | `bd7ed53` | Eksen zinciri silindi; `QUALITY_AXES` → `RivalCatalog.COMPOSITE_AXES` |
| K9d | `350ba3b` | Belge kapanışı (ACIK_KARARLAR 52 ve 59, ISLER, GUNCELLEMELER, sözlük, motor md §27.39, HARITA) |
| K9a | `9221d00` | E1 kararları (2★ satırı, B2C sayfası en az 2★), `capabilities` önbelleği, smoke `fit_scale` |
| K9b | `bd9a5ed` | B2C ağızdan ağıza C10 ve ücretli plan öncesi tuzağın düzeltmesi |
| K9c | `910ad1f` | 2★ Çekirdek beklentisi 1,25 |

Son satır ana turun son commit'idir. Q'nun son commit'i `7012218a` (K20); ikinci ve üçüncü turun commit'leri §0.2'de.

---

## 7. C ve D için
### 7.1 Sözleşme (gerçek adlar ve imzalar)
**`ProductQuality`** (`scripts/systems/product_quality.gd`, yalnız okur):
- `level(area, tiers := {}) -> float`: alanın yuvarlanmamış seviyesi = hatlarının (kademe + cila) ortalaması, en çok hattın son
  kademesi; 1 = her hattın K1'i yayında. `tiers` öngörünün varsaydığı kademeleri ezer. D'nin derinlik kazancı buraya eklenir;
  oran `RATIO_CAP`'te (1,5) kesilir.
- `expectation(area, ctx := {}) -> float`: ctx `market`, `star`, `sector`, `rivals`, `subtype`, `audience` (B2C'de star yokken
  true ise kitlenin kendi konumu). ctx boşsa ürün sayfasının referansı: B2B'de 2★, B2C'de kitlenin yıldızı ile 2★'ın büyüğü.
- `word(area, ctx := {}) -> String` (`none` | `weak` | `enough` | `strong`), `word_for(lvl, expect)`, `is_enough(area, ctx)`,
  `serves(area) -> int`, `next_star() -> int`, `next_ratio(area, star := next_star()) -> float`, `weakest_area(ctx := {}) -> String`.
- `area_row(area) -> Dictionary` = {area, word, tone (`pos` | `neutral` | `warn`, `WORD_TONES`), sentence, squares 0-10 (beşinci
  kare referans), faint_from 8}. Genel Bakış satırlarının tek kaynağı; bugün hiçbir ekran okumuyor (C çizer).
- `fit(ctx) -> Dictionary` = {value 0-100, match, capped, weakest_emphasis, loss_area, note [{area, word}], label_key};
  `fit_from_levels(levels, ctx)`.
- `prospect_ctx(p)`, `prospect_fit(p)`, `account_fit(c) -> Dictionary` (+ `market_value`: aynı hesabın bugünkü satırla U'su),
  `market_ref_for(star, sector, subtype := canlı) -> Dictionary`, `market_fit(star) -> int`, `close_chance(p) -> float`.
- `weights(market, sector)`, `emphasis(sector)`, `used_areas(sector)`, `uses_area(sector, area)` (hesabın kullandığı alanlar:
  ağırlığı ≥ 0,15 olanlar; Karar 10).

**Öbür adlar:**
- `CustomerRegistry.set_market_ref(id, ref)` (`market_ref`'in tek yazarı; imzada ve `SprintBridges.next_renewal_day`'in yenileme
  açılışında çağrılır; C5 tetikleyiciyi sözleşme kaydının açılışına taşır).
- `B2BSalesSystem.satisfaction_target(c)` = `account_fit(c).value` − hesabın hatlarındaki açık hata bedeli + `trust_offset`.
- `SalesSystem.signing_satisfaction_seed(prospect)` = `prospect_fit.value` (taban tol + 10, en az 50; masa ve satışçı aynı tohum).
- `SalesSystem.b2c_quality()`, `b2c_satisfaction_target()`.
- Satışçı: `SalesRepSystem.lost_area(lead)` (C'nin imza kapısı `_close`'ta zardan önce buraya); `SalesFinalizer.lose(lead_id,
  account, reason, target, lock_weeks)`; `SalesLedger.repitch_blocked`, `record_loss`, `lost_week`; sinyaller
  `EventBus.rep_deal_lost(rep_id, prospect_id, area)`, `rep_deal_closed(rep_id, customer_id)`; `meeting_lost` masa kaybında da
  ateşlenir (`rep_deal_lost` ile ayır). Mesaj türü `sales_loss` {rep, company, area}; bayraklar `sales_weekly_loss_rows`,
  `sales_loss_mail_day`.
- Profil: `ProductLines.work_profile(line)`, `ResearchTree.hidden_line_profile(id)` (D'nin aşama payının tek kaynağı).
- Taban merdiveni: `ProductRead.floor_ratios()`, `floor_state(ratio)`, `worst_floor()`; sinyaller `axis_floor_warning(area)`,
  `axis_floor_crossed(area)`; seam'ler `urun.floor_state`, `urun.floor_area`, `urun.trust_level`.
- Kayıt: şema 18 (`_migrate_17`), `SaveCodec.RETIRED_PRODUCT_FLAGS` (üç eksen bayrağı ve `mvp_step_realization` her yüklemede düşer).
- Önbellek: `ProductLines.memo` (yalnız `SprintCatalog.capabilities`; hat kümesi değişince boşalır).
- Rakip: `RivalCatalog.COMPOSITE_AXES`, `Rival.composite()` (argümansız).

### 7.2 Ortak dosyalar
PRD §8'in listesi (`sales_rep_system.gd`, `sales_system.gd`, `sales_meeting_system.gd`, `sales_ledger.gd`, `b2b_sales_system.gd`,
`b2b_constants.gd`, `sales_finalizer.gd`, `sales_constants.gd`, `sprint_catalog.gd`, `sprint_bridges.gd`, `sprint_system.gd`,
`product_lines.gd`, `product_model.gd`, `data/product/`, `customer.gd`, `save_manager.gd`, `strings.csv`, `run_probe.gd`,
`endgame_smoke.gd`) ve Q'nun dokunduğu ekler: `product_quality.gd`, `product_read.gd`, `product_state.gd`, `research_tree.gd`,
`rival.gd`, `rival_catalog.gd`, `rival_registry.gd`, `quality_model.gd`, `save_codec.gd`, `customer_registry.gd`, `vc_pitch_system.gd`,
`term_sheet_table_system.gd`, `sales_meeting_adapter.gd`, `vc_meeting_adapter.gd`, `sales_probes.gd`, `sales_faucet_system.gd`,
`sales_archetypes.gd`, `negotiation_system.gd`, `seams_product.gd`, `incident_system.gd`, `inbox.gd`, `mail_pane.gd`,
`message_system.gd`, `event_bus.gd`, `main.gd`, `product_fixtures.gd`, `game_state.gd`, kart JSON'ları (`launch_leak.json`,
`password_rule.json`, `b2c_floor_signal.json`, `b2c_floor_churn.json`, `shutdown_notice.json`, `b2c_creator_feature.json`),
`lint_v3_frozen.json`. Hepsi Q'nun son commit'inde (`910ad1f`) kapalı.

### 7.3 Şema ve bot
- Q şema 18'i aldı (`market_ref`). C 19, D 20 (PRD §9).
- Preset'ler (`RunProbe.PRESETS`): düzeltme kolları `full_run_fix_{none,worst,due,off}` ve `full_run_b2c_fix_*`; masalı
  `full_run_fix_worst_desk` (anahtar `desk`); `full_run_quality_core`, `full_run_quality_core_desk` (anahtar `core_only`);
  `full_run_vc_cautious`, `full_run_vc_product`, `full_run_b2c_vc_cautious`, `full_run_b2c_vc_product`. Satırlar: PROBE FIT, LEAD,
  SIGN, REPLOSS, MLOSS, UFLUX, B2C (u=, aud_star=), VCQ, SAT (target), FIXTURE.
- §4.4 ve §4.5'i üreten komutlar: `q_calisma/` dışındaki betikler scratchpad'de (repo dışı); ölçüm koşusu 15 kol × tohum 7 ve 11 ×
  104 hf `--run-log=<preset>:104:sim:<tohum>` (`--lang=tr`, koşu başına ayrı `APPDATA`, en çok 2 paralel), sprint probları
  `--sprint-probe=hours=40:cards=2:ticks=60:team=3:fill=1:events=1[:market=b2b]`, tik `--tick-probe=3` ve
  `--tick-probe=3:accounts=330` × 3 tek başına. Tabloyu çıkaran betik (`k8_tables.py`) okuma kurallarını `K9_TABLOLAR.md`'nin başlıklarında yazar.

### 7.4 C'nin ve D'nin bilmesi gerekenler
- C: imzada U < tol + 10 payı (C'nin imza kapısının girdisi, kapanış ölçümü): fix_worst 2★ %8,5 (12/142), 3★ %57 (4/7); masalı 2★ %4,9 (15/309), 3★ %11,9 (21/176); quality_core 2★ %73,7 (70/95). 1★'ta
  %0. Hesap toleransı U ölçeğinde 2★ ve 3★
  hesabı zayıf üründe altta bırakıyor (C3a'nın konusu). `Inbox.risk_reason` hata kapısı altında güven defteri ≥ 0 iken hâlâ "Güven &
  Ölçek" diyor; hesabın düşük uyumu başka alandan olabilir. Ar-Ge gizli hattı açılınca hesabın donuk `market_ref`'i yenilemeye kadar
  kalır. `risk_exit_stamps_day` uyum terimine duyarsız.
- D: `LineGates.speed_bonus_for` ve `ABOVE_GATE_*` okuyucusuz duruyor; D bağlamamaya karar verdi ve RAPOR_D'ye yazıyor. Lider
  önerisi ve çeyrek şeridi `next_star()` / `next_ratio()` okur.
- İkisi için: 330 hesaplı gece tiki 133,6 ms (eski kod 141,1, kapı 148,2); `account_fit` hesap başına okunur, `capabilities` önbellekli.

---

## 8. Silinenler, §4.1 ve PRD düzeltmeleri
**§4.1 kalan eşleşmeler (PRD'nin on belirteci + `push_axes`):** 2 satır, ikisi de PRD'nin "kayıt göçlerinin eski alan adları"
istisnası: `save_codec.gd:25` `RETIRED_PRODUCT_FLAGS` ve onu sınayan `endgame_smoke.gd` fikstürü (`save_retired_product_flags`).
`sprint.json`'da evre başına `expectation` tablosu yok. Geniş desende kalanlar: rakip modeli, İK deneyim çubuğu, eski göçler,
`chips.gd` `EFFECT_AXIS` (morale çipinin ad yuvası), `axis_floor_*` sinyal adları (Karar 12 korur).

**Silinenler (K7b):** hat JSON'larında eksen, eksen puanı, ikincil eksen puanı; Kano katsayısı; 1,6 yükseltme kuralı; `axis_of`,
`line_ids_by_axis`, `weighted_points`, `net_gain`, `AXIS_OWNER_AREA`; QualityModel'in ürün kısmı (eksen okuması, faz çıtası, doyum
eğrisi); `SprintBridges.push_axes`; kademe damgası; `LineGates.above_gate_bonus`; `ProductRead.axis_reading`, `market_word`,
`market_floors`; `ProductState.axis_readings`, `realized_dims`; `ProductCatalog.get_quality_axes`, `axis_label`;
`RivalRegistry.get_player_rank_in_startup_league`; `PROD_AXIS_*` anahtarları; `phase_bar_raised` sinyali (K5);
`VCPitchSystem._weakest_dimension`, `E_FIT_PRODUCT_DIM_FLOOR` (K4v); `_rival_relative_quality` (K4c); ölü arketip ve eksen
parçaları (K3b).

**PRD düzeltmeleri:**
- `push_axes` çağıranı `sprint_system.gd:1530` (PRD :1540). Üç eksen bayrağının debug yerleri `main.gd:506-508`, `:1448-1450`;
  `:3625-3630` damga fikstürüydü. `QUALITY_AXES` :170 idi.
- `lint_v3_frozen.json` üretilmez, elle tutulur. `urun.axis_reading` kayıtlı seam değil, katkı kimliğiydi. `urun.product_fit` olay
  motoruna kayıtlı seam değil (gerekirse ayrı iş).
- §3.5 kart gövdesinde `{area}` iki smoke kapısını düşürür; satır içi `{seam:urun.floor_area}` olmalı.
- `loc_b2b_derived_keys` aday üretimini kanıtlamaz. Karar 2'nin "Kararlılık" listesi eksikti (dört anahtar daha). Customer yolu
  `scripts/data_models/customer.gd`.
- Karar 5 `match` aralığı "0,0-1,43" değil "0,0-1,5" (U 1,43'te 100'e varır).
- Karar 12 "oran ürün sayfasının referansına göredir" → "kitlenin kendi referansına" (§4.2 kural 3).
- §4.4'ün "B2C kitle eğrisi bugünkünden en çok %20 sapar" hedefi aynı sabitle 24/24 tutmaz: Q0b'de düzeltmesiz kollar düzeltmeli
  kollardan %36-52 yüksekti (eski U hatayı okuyordu), yeni modelde bu sıra yok.

---

## 9. Erdem'e sorular (tam liste)
Bu liste ana turun kapanışında sorulan hâlidir. Hangisinin cevaplandığı ve kalanların nerede olduğu §0.6'da.

1. **2★ Çekirdek: 1,25 mi kalsın, 1,5'e mi dönelim?** Örnek: ERP'n Traction'da, Çekirdek'in beş hattından ikisi ikinci sürümde.
   - 1,25'te (bugün) orta boy bir lojistik firması (2★) Çekirdek'i "Yeterli" bulur ve yüksek uyumla imzalar; Çekirdek biraz
     daha ilerleyince tam uyuma (U = 100) varır. Bot 52. haftada
     52-66 bin MRR'a, Series A Avı'na 88-98. haftada varıyor. Ama 2★ ve 3★ imzaların %40'ı tam uyumla: bu müşteriler için
     kovalanacak sürüm kalmıyor (kapı en çok %25).
   - 1,5'te aynı firma Çekirdek'i "Zayıf" bulur: ya daha düşük uyumla imzalar ya da zayıf alan yüzünden kaybedersin; üçüncü hat
     ikinci sürüme çıkınca "Yeterli" olur. Bot 52. haftada 38-63 bin MRR'da,
     Series A Avı 94-99. hafta, sekiz koşunun üçü hiç varamıyor. 2★ ve 3★ imzaların hiçbiri tam uyumla değil.
   - İkisinde de ilk 26 hafta aynı (26. hafta MRR 16-28 bin, eski kod 38-47 bin). Botun eski koda göre yavaşlığının çoğu oradan
     geliyor, yani E1'de kabul ettiğin imza düşüşünden. Çekirdek beklentisi orayı değiştirmiyor.
   - Önerim: **1,5'e dön.** 1,25'in kazandırdığı hız küçük, Faz Q'nun amacı olan "büyük müşteri ürünü kovalatır" duygusunu ise
     imzaların %40'ında kaldırıyor. Erken haftaların hızı ayrı karar: C'nin imza kapısı geldikten sonra yeniden ölçülür.
     1,25'i seçersen §4.4-1 kapısını ölçülen yere (%30-40) çekerim.
2. **E1'in ikinci turu (onaylanmadı, yapılmadı).**
   - (a) Örnek: 1★ küçük bir muhasebe bürosu Entegrasyonlar'a hiç bakmıyor (beklentisi 0). Ürününde Entegrasyonlar yoksa bugün
     görüşmede o alan "Yok" sayılıyor: vurgu sorusunun güçlü cevabı kilitli ve kaybettiğin aday bu yüzden geri dönmüyor.
     Önerim: müşterinin bakmadığı alan cevapta ve geri dönüş kapısında "Yeterli" sayılsın.
   - (b) B2C'de hiç yapılmamış bir alan (seviye 0) varken kitle 1.000'i geçince taban merdiveni doğrudan "eşik aşıldı" diyor.
     "Son yorumlar hep o tarafa dönüyor" uyarı kartı ve ayrılış anketi kartı o alan için hiç gelmiyor. Önerim: önce bir hafta
     uyarı, sonra eşik.
3. **Açık kararlar 52 ve 59, ISLER C-13 (K9d).** Konuları Q'da kalktı. 52 ve 59 silindi; C-13 onayından sonra silinecek. Onaylıyor
   musun? "Hayır" dersen geri alırım.
4. **Alanlara özgü tat.** Eski ürün sayfasında 19 alan × sözcük cümlesi vardı ("Veri elle taşınıyor" gibi); K2 onları sildi.
   Şimdi her alan aynı yıldız cümlesini okuyor ("Bu haliyle 1★ şirketlere yeter."). Alanlara özgü bir satır geri gelsin mi
   (C'nin ya da ayrı bir yazı işinin konusu)?
5. **Frank'in okuyucusuz dört satırı** (`PROD_TIP_WEAK`, `PROD_TIP_GOOD`, `PROD_DESIGN_CEILING_NOTE`, `PROD_ITER_CEILING_NOTE`):
   hiçbir ekranda görünmüyorlar ve silinen eksenlerin dilini taşıyorlar ("İnovasyon {inn}"). ACIK_KARARLAR 43 gereği silmedim;
   külliyat senin. Sil mi, alan diliyle taslak mı yazayım?
6. **Okuyucusuz on İK cümlesi** (`HR_AREA_MEANING_*`): bir rolün hangi alanda ne işe yaradığını anlatıyorlar; okuyan ekran Ekip
   rev 11'de kalkmış, yalnız smoke okuyor. K7a dördünü alan diline çevirdi (TR/EN onay bekliyor). Sil mi, bir ekrana bağlansın mı
   (D'nin ya da C'nin konusu)?
7. **Rakip modeli de elden geçmeli.** Rakiplerin kalite bileşkesi (`Rival.composite()`, `RivalCatalog.COMPOSITE_AXES`,
   `QualityModel.composite_quality`, `DEFAULT_AXES`) hâlâ üç eski eksenle hesaplanıyor ama oyunda okuyan yok, yalnız smoke
   (`rival_composite_table`). Rakibin ürünü oyuncunun ürünüyle aynı alan diliyle mi ölçülsün, ne zaman (ayrı faz mı)?
8. **Tire.** VC görüşmesinin ilk seçeneği "Odayı oku — karşındakini tart." / "Read the room — take their measure."
   (`VC_B1_CHOICE`, `strings.csv:1259`) tire taşıyor; Q'dan önce de vardı. Öneri: "Odayı oku, karşındakini tart." / "Read the
   room, take their measure." Onaylarsan tek satırlık commit.
9. **"Kitlen büyüdükçe" cümlesi.** B2C sayfası küçük kitlede de 2★'ı okuduğu için MVP'de Çekirdek "Zayıf · Kitlen büyüdükçe
   kullanıcılar bu alanda daha fazlasını ister" diyor, 672 kullanıcıda da. Cümle doğru ama ileriyi anlatıyor. Kalsın mı?
10. **Zar ipucu küçük harf** ("ürün uyumu · Çekirdek Zayıf"), öbür zar satırları gibi; PRD büyük harf yazıyordu (§4.2 kural 5).
    Kalsın mı?
11. **Bayat açık kararlar.** #39 (`SALES_REASON_STABILITY` "ürünün kararlılığı"; metin K3a'da değişti), #45
    (`QualityModel.economy_dims_from_flags`, artık yok), #96 (`above_gate_bonus`, K7b'de silindi) ve ACIK_KARARLAR 1303-1305'teki
    eski ağızdan ağıza değerleri (0,005 → 0,0012; 60 → 30; 50 → 15; bugün C10). CLAUDE.md §3 gereği dokunmadım. Bugünkü koda
    göre yeniden yazayım mı?
12. **Ağaçta olmayan belgeye atıf.** Motor md §27.36-38 ve GUNCELLEMELER'in K7b girdileri izlenmeyen `PRD_FAZ_Q_KALITE.md`'ye
    atıf yapıyor (CLAUDE.md §13 kaynak dosya için yasaklıyor, belge için gri). PRD izlemeye mi alınsın, atıflar mı silinsin?
13. **ISLER adayları** (yazayım mı?):
    - `ProductLines.reload()` GDScript'in `Script.reload`'una gidiyor olabilir (motorda doğrulanmadı). Önbellek iki yolda da
      boşaldığı için bugün zararsız.
    - `--tab-shot=product` tema tohumu Q'dan önce de kırık (tür seçilmemiş, sprint durumu yok).
    - ISLER C-10'un "%14 düşük fiyat" ölçüsü eksen dönemine ait; yeni kalite terimiyle yeniden ölçülmedi.
14. **Bilgi, karar değil:** `LineGates.speed_bonus_for` ve `ABOVE_GATE_*` okuyucusuz duruyor; D bağlamamaya karar verdi ve
    RAPOR_D'ye yazıyor.

---

## 10. Süreç notları
- Adımlar paralel partilerle yürüdü (K3a ∥ K4v ∥ K4c ∥ K5; K3b ∥ K8a; K4b ∥ K7a; K7b ∥ K8b; K9a ∥ K9d). Her paralel commit'in
  sahnelenmiş ağacı ayrı dizine çıkarılıp kendi vakalarıyla koşuldu.
- Ortak fikstür değiştiren dilimde fikstürün bütün çağıranları koşuldu (K3a'nın `_seed_b2b` değişikliği `save_v13`'ü kırmış ve hedefli
  kapı görmemişti; dersten sonra kural oldu).
- K6'dan sonra otomatik `git gc` bellek baskısında biçildi; Erdem'in onayıyla ön planda koşuldu, sonraki commit'ler `gc.auto=0` ile.
- Kapanışta bir kapı koşusu iki Godot sürecini aynı anda çalıştırdı (lint ile loc_residue); sonuç geçerli, tek süreç kuralına aykırı.
- Tam smoke koşulmadı (push yok; push öncesi de istenmiyor).
