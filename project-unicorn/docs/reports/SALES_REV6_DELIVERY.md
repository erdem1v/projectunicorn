# Satış modülü yeniden inşası — teslim raporu

**GDD:** `GDDs/GDD — SATIŞ MODÜLÜ (rev 6 · İNŞA SÜRÜMÜ).docx` · **Tarih:** 2026-08-26
**Taban:** `main` @ `95eb8aa` · **Faz 0 defteri:** [`docs/plans/SALES_REBUILD_2026-08-26.md`](../plans/SALES_REBUILD_2026-08-26.md)

---

## 1 · Ne teslim edildi

### Faz 1 — veri, musluk, boru hattı

**Buton öldü, musluk açıldı.** `SalesFaucetSystem` günlük akışı üç şeyden okuyor: atanmış
satış kapasitesi (taban 3/hafta, atanmış temsilci başına +2/hafta), ilgi (`urun.interest`
→ ×0,8–1,3) ve faz (Bootstrap ×1,0 · Traction ×1,25). **Sıfır satış kadrosunda taban akış
sürüyor** — rev 6'nın kapattığı ilk delik bu: eskiden boru hattı temsilcisiz ölüydü ve bir
buton onu dolduruyordu, yani işe alım arzı artırıyor ama oyuncuyu hiç kısıtlamıyordu.
1★ bandının altında sert bir taban var, yani musluk yavaşlar ama **kurumaz**.

**Havuz tükenmiyor.** `SalesNamePool` kürasyonlu 65 ismi havuzun başına koyuyor, arkasına
gövde × sektör-eki üretiminden gelen çoğunluğu ekliyor (~50 gövde × 3–4 ek × 13 sektör).
Calibration Round A'nın F1 bulgusu — 7. aydan sonra ~25 hesapta plato — yapısal olarak
kapandı. İmzalanan isim koşu boyunca düşer; süresi dolan şirket 30 gün sonra **kendisi olarak**
döner.

**Yıldız tek ölçek oldu.** `Prospect.archetype` (small/mid/enterprise) + ayrı `scale` +
`difficulty_stars` üçlüsü tek `star` alanına indi (§2). Karışım fazdan okunuyor
(Bootstrap %75/22/3 · Traction %35/50/15) ve **kalite kaydırıcısı** üst bandın payını ürün
okumasıyla açıyor: zayıf ürünle büyük balık kapıyı çalmıyor. Demo tavanı 3★ ve mühürlü —
4–5★ üretilmiyor, yazılmıyor, kilitli kart da çizilmiyor.

**Boru hattı bir saat kazandı.** Lead 7 gün bekliyor, sayaç kartta, süresi dolunca dürüst
düşüyor ve satırı satış kütüğüne yazılıyor (kart gittiği için cümlenin yaşayacağı başka yer
yok). Rezerv süreyi durdurmuyor; işlenen lead'in sayacı donuyor.

### Faz 2 — toplantı sahnesi, Perde 1, kayıp yolu

**Tam sahne değişimi.** Lead kartından açılıyor, GameShell (ODA + terminal, ikisi birden)
görünmez oluyor ve sahne `Main`'in tek görünür çocuğu olarak monte ediliyor. Kapanışta saat
2 saat atlıyor ve o saatler **gerçekten simüle ediliyor** — motorun kendi saatlik yolu, kurucu
meşgul sayılarak. Ekip §2.1'in cümlesi kendiliğinden çıkıyor: ekipte boş biri varsa yapım
akar, kurucu tek işçiyse durur. İkinci bir "yetişme" formülü yazılmadı.

**Perde 1 storylet'lerden kuruluyor.** Kriterler düz bir olgu sözlüğüne bağlanıyor ve o
sözlüğün her satırı adlandırılmış bir sorgudan geliyor — yani "motor okumadığını söylemez"
bir inceleme kuralı değil, yapısal bir özellik: `rival.offer_seriousness` diye bir olgu
olmadığı için o cümle yazılamıyor. En spesifik kural kazanıyor, söylenen satır koşu
hafızasına yazılıyor.

**İğne sessiz.** Tek yüzde, farklı tonda, hover'da motorun kendi `EvDice.modifier_lines`
grameriyle: işaretli, büyüklüğe göre sıralı, **sayısız**, en fazla dört satır. Satış bu
fonksiyonun ilk üretim tüketicisi.

**Müşteri toplantıyı bitiriyor.** Çift eşik (üst 0,72 → Perde 2, alt 0,12 → kayıp), arada
kurcalama güvenlik tavanına kadar sürüyor, toplantı şekli yıldıza göre değişiyor (1★ tek
nefes · 2★ standart · 3★ derin). "Teklife geç" ikinci kurcalamadan itibaren açık ve cezasız.

**Zar tek yerde.** Ne eşik aşıldı ne de alt eşik delindi ise — yani güvenlik tavanında ya da
"Teklife geç"te — motorun `EvDice.check`'i karar veriyor. Anahtar: koşu tohumu + gün + lead +
**oynanan yol**. Aynı yol aynı sonuç; farklı yol gerçekten farklı zar. Zar balıkçılığı
imkânsız, ve yeniden-pitch tasarımının dayandığı yasa bu.

**Kayıp isimlendiriliyor.** Neden gerçek durumdan türetiliyor, hesabın hafızasına ve koşunun
kütüğüne yazılıyor, `meeting_lost` yayınlanıyor. Kütük **budanmıyor** — talep üreteci indiğinde
okuyacağı tampon o.

### Faz 3 — Perde 2, imza, fiyat izi

**Perde 2'de tek replik yok.** Cetvel, kadran çapası, sözle daralmış kilitli üst uç, hakaret
bölgesi, gizli rezerv, cetvele işlenen karşı-teklif rakamları, sabır kutuları (sonuncusu
vurgulu), her an açık "Kabul et", her an açık "Kalk", ve onay şeridi: koltuk × fiyat = MRR +
kapasite okuması. Telgrafların hepsi **görsel durum**.

**Sözleşme birebir §5.3.** `open(type, context)` → `{outcome_id, values, effects_to_apply}`.
Sahne `type: "series_a"` ile de çağrılabiliyor: koltuk → hisse, fiyat → değerleme, etiketler
anahtar üzerinden değişiyor ve **tek mekanik satırı değişmiyor**.

**İmza fiyatı damgalıyor.** Hesap kendi koltuk fiyatını taşıyor, genişleme o fiyattan koltuk
ekliyor, imza indirimi ayrı bir iz olarak duruyor. Sabit `EXPANSION_PER_SEAT_MRR` artık yalnız
damgasız kayıtların yedeği.

### Faz 4 — temsilci otomasyonu, kadran, sunum, adaylar

Yıldız kapısı (§7.1) · tek lead işleme ve boru hattında görünen "X ile görüşüyor · N. gün" ·
lig-farkı süre tablosu `hr.effective_skill` üzerinden · band tavanı ve §7.2.2'nin gösterim
kuralları (**1★ temsilcide seçici çizilmiyor, düz bilgi satırı**) · seçim kuralı (banddaki en
yüksek yıldız, eşitlikte süresi bitmek üzere olan, ayrılmış masalar atlanıyor) ·
Rekabetçi/Standart/Premium kadranı **B2B fiyatının tek kaynağı** olarak · lig içi deterministik
kapanış · fiyat-kırma kartı **veri olarak tanımlı ve hiç ateşlenmiyor** · haftalık özet bilgi
kartı (yalnız kapanışlar) · ticker yalnız haber değerinde · balina adaptif şartı (sıralı ilk
karşılanmayan kalem, karta telgraflanmış, karşılanmış kalem asla istenmiyor) · yeniden-pitch
engel kapısı, hafıza satırı ve kalıcı küçük ceza · satış adayı yıldız eğrisi ve tuzak-huy yasağı
`HRCandidateGenerator`'ın **parametreleri** olarak — ikinci bir üreteç değil (§15 aday üretimini
Ekip §10.2'ye veriyor ve satışa özel bir kopya tam olarak o tablonun yasakladığı ikinci kaynak
olurdu). Eğri her seviyede ve her arketipte rol-nötr kardeşinin ALTINDA (§11.7: satışta yıldız
paradır ve rolün ikincil alanı yok), demo tavanı ★3,5, üst dosya seviye-duyarlı (junior ★2,
kıdemli ★3,5), ve GERÇEK LİDER ile TİTİZ satış havuzuna girmiyor (§11.8) — havuz filtresi,
silme değil: ikisi de her başka rolde canlı.

### Faz 5 — emeklilik, göç, testler, lokalizasyon

Şema 10 → 11, `_migrate_sales_rev6` kendi emekli tablolarıyla. Smoke: mevcut satış vakaları
yeniden noktalandı (silinmedi), on bir yeni vaka eklendi. Lokalizasyon: **127 anahtar**,
TR + EN aynı commit'te, hepsi APPEND (0 silme — CSV'nin tek tırnak konvansiyonu yok, o yüzden
dosya asla yeniden yazılmıyor). 54'ü `PH:` etiketli anlatı, 73'ü gerçek UI etiketi. Emekli
`PITCH_*` satırları CSV'de BIRAKILDI: hiçbir okuyucusu kalmadı (`loc_csv_integrity` yeşil),
silmek bayt-splice gerektirirdi ve yazım turu numaralı havuzları yeniden kullanabilir.

---

## 2 · GDD'nin harfinden sapmalar

1. **Toplantı sahnesi `change_scene_to_packed` değil, GameShell'i gizleyen bir alt-ağaç
   takası.** Oyuncu tarafından aynı şey; motor tarafından değil. Gerçek sahne değişimi `Main`'i
   yıkardı ve modal yönlendirmesi, ticker, olay bağlantıları ve on beş `--*-shot` harness'ının
   hepsi için bir geri-kurulum yolu gerekirdi. **Kaldırmak yerine gizlemek**, çünkü kaldırmak
   sayfa ağacının tamamında `_exit_tree`'yi ateşler ve sekme sayfaları sinyallerini orada
   çözüyor; `_ready` örnek başına bir kez koştuğu için geri eklenen düğüm hiçbir şeye bağlı
   olmazdı. *(Planlama sırasında direktör hükmü.)*

2. **`JOB_SALES` Görevler matrisine geri geldi.** §3.1 kilitli-görünür bir Satış sütunu
   istiyor ve §3'ün musluğu "atanmış satış kapasitesi" okuyor; ikisi de Satış alanı `accounts`
   işi üzerinden taşınırken imkânsızdı. Ekip'in 2026-08-25 hükmünün GEREKÇESİ korundu:
   kurucunun toplantısı hâlâ slot tüketmiyor ve hiçbir şeyi duraklatmıyor. İş, temsilcinin
   6–7 günlük işlemesi. *(Direktör hükmü.)*

3. **Musluk atanmış temsilci sayısında doğrusal.** Eski masanın istif azalması (`REP_STACK_DECAY`)
   taşınmadı: §3 "temsilci başına +2/hafta" diyor, azalma demiyor. Arz artık kalabalık bir kuyruk
   değil bir pazar okuması. Patlama koruması **günlük tavana** taşındı.

4. **`EXPANSION_PER_SEAT_MRR` silinmedi, yedeğe düştü.** Motorun `b2b_expand` efekti onu
   geçirmeye devam ediyor ve bu görev hiçbir motor dosyası açmadı. `expand()` damgalı hesapta
   onu görmezden geliyor, damgasızda (v10 kaydı, fikstür) kullanıyor — yani eski davranış tam
   olarak eski davranışın geçerli olduğu yerde korunuyor.

5. **`PitchSystem` sınıf adı yaşıyor.** İki fonksiyonluk bir uyum dosyası: `spawn_prospect`
   (motorun `add_prospect` efektinin adlandırdığı sembol ve §3'ün balina kanalı) ve
   `signing_satisfaction_seed` (iki imza yolunun paylaştığı ifade). Sebebi başlıkta yazılı ki
   sonraki okuyucu "temizlemesin".

6. **Şirket adları `PH:` etiketi taşımıyor.** Özel isimler lokalize olmuyor ve bir lead
   kartında "PH: Kuzey Lojistik" okunmuyor. Mekanik bulunabilirlik iki const tablosuyla
   sağlandı (`SalesNamePool.STEMS` / `SECTOR_WORDS`) — tek grep.

7. **Süresi dolan lead satış kütüğüne bir satır yazıyor.** §4 dürüst cümleyi istiyor ama kart
   lead'le birlikte gidiyor; görülmeyen bir kayıp telgrafsız kayıptır. Kütük o cümlenin
   yaşadığı yer.

8. **Fiyat kadranı şeritte DEĞİL, boru hattı sütununun başında.** §7.5 "Satış sekmesinde"
   diyor, yeri söylemiyor. Şeridin sağ ucu Build HUD panelinin altında kalıyor (GameShell onu
   görüntü alanının sağ üstüne bindiriyor) ve oyuncunun tıklayamadığı bir kontrol kontrol
   değildir. Ekran görüntüsüyle ölçüldü, sonra taşındı.

9. **§3.1'in "Satış işi sütunu kilitli-görünür" hükmü Görevler matrisinde uygulandı**
   (`hr_assignments.gd`). Matrisin zaten gerekçeli-kilitli-hücre deseni vardı (araştırma
   sütunu, üçüncü-iş kilidi); satır o desenin bir örneği. Sıra ALAN kapısından SONRA: satış
   alanı olmayan birine dünyanın hâlini anlatmak yalan olurdu, o sütunu gerçekten
   tıklayabilecek tek kişi kurucudur.

10. **İki sinyalin ikinci yayıncısı kaldırıldı.** `lead_routed` bir ARA temsilci masası iş
    aldığında da atılıyordu ve `whale_condition_met` hem musluktan hem imzadan. §14 sinyal
    başına tek yayıncı istiyor ve gerekçesi mekanik: iki emitter, bir olayın dinleyiciye iki
    kez varması demek. Manifest üreteciyle doğrulandı.

11. **`--pitch-shot` emekli, yerine `--meeting-shot=<probe|locked|won|lost>`.** Vurduğu yüzey
    (`B2BPitchMeeting` → paylaşılan MeetingScene) artık yok.

12. **`sales_tab.gd`'nin gün kancası `day_advanced` → `day_tick_completed`.** Eski kanca
   `GameState.advance_day()` İÇİNDE, günlük tick'ler dağıtılmadan önce atılıyor; sayfa dünkü
   durumu okuyordu. Bu bir sapma değil bir düzeltme, ama GDD'nin istemediği bir dosyaya
   dokunduğu için burada.

---

## 2.5 · TEK MOTOR DOSYASI — ve neden açıldı

Görev "motor dosyalarına dokunma" diyor ve gerekçesi aynı dalda süren ikinci bir yazardı.
Ağaç boyunca o kural tutuldu: `effects.gd`, `scope.gd`, `seams_sales.gd`, `signals.gd` ve
kartların bağlandığı her yüzey **açılmadı** — dördünün de nasıl ayakta kaldığı §1'de yazılı.

**Bir satır istisna:** `scripts/events/tools/engine_probe.gd:444`.

```
- _ok("schema is v10", SaveManager.SCHEMA_VERSION == 10)
+ _ok("schema carries the event_engine block (v10+)", SaveManager.SCHEMA_VERSION >= 10)
```

O satır motorun DAVRANIŞI değil, bir TEST iddiasıydı, ve şema 11'e çıkınca bayatladı:
`--event-probe` **158/159**'a düştü, sebebi de olay motoruyla ilgisi olmayan bir modülün
meşru bir sürüm artırımıydı. İddianın NİYETİ "şemada event_engine bloğu VAR" — bu v10'da
doğru oldu ve sonrasında doğru kalıyor; sayıyı sabitlemek her sonraki modülün artırımını
başka bir şey hakkındaki bir motor iddiasına çarptırıyordu. Alt sınır (`MIN_LOADABLE == 10`)
**tam** bırakıldı, çünkü o gerçekten motorun kendi hükmü: v10 öncesi kayıtlar bilerek ölü.
Sonuç: `--event-probe` **159/159**.

Bir motor iddiasını kırmızı bırakıp raporda "bu benim değil" demek de bir seçenekti;
kapıyı bilerek kırmızı bırakmak, bir sonraki turun onu gürültü sanmasının yoludur.

## 2.6 · Kapıların bulduğu iki gerçek hata (ikisi de bu turdan ÖNCE oradaydı)

1. **`_salary_trio`'nun beş-yıldız çapası %20-45 kuralını çiğniyordu.** Üst dosya bandın
   TAVANINI istiyor (§10.2'nin adı konmuş istisnası) ama çapa bandın TABANINA sabitleniyordu;
   her rolde `tavan/taban = 1,5 > 1,45`, yani kural ÜÇ SEVİYENİN HİÇBİRİNDE sağlanamıyordu.
   Gizli kalmasının sebebi olasılıktı: üst dosya yalnız kıdemli bantta ve %8'le çıkıyordu, ve
   invariant vakasının yürüdüğü tohumlar ona nadiren denk geliyordu. §11.7 junior satış
   aramasına ~%25 üst dosya verince ilk turda düştü (`sales_rep/lvl0` tohum 19876: 1500..2250
   = %50). Çapa artık tavanın en fazla %45 altına oturuyor.
2. **`funding/gate_series_a.json`'ın gövdesi bir sözlük**, ve `lint.gd:320`'nin
   `String(block.get("body", ""))` çağrısı onda `Nonexistent 'String' constructor` atıyor.
   Motorun kendi lint'inde, bu turdan önce vardı ve **bu turda düzeltilmedi**: kart Yatırım
   modülünün, düzeltmesi de ya o kartın ya da lint'in — yani bir motor dosyasının — işi.
   `--event-lint` yine de **PASS** basıyor (0 hata, 0 uyarı, 48 kart); hata tek bir kartın
   metin kontrolünü yarıda kesiyor, sayımı değil. Bulgu olarak bırakıldı.

---

## 3 · Park edilmiş tasarım kararları

Her biri kodda `# DESIGN-PARKED:` ile aranabilir.

| # | Soru | Yer tutucu | Görülen alternatifler |
|---|---|---|---|
| 1 | Perde 1'den oyuncu çıkışı var mı? §5.1.1 sonu müşteriye veriyor, oyuncuya bir kapı tanımlamıyor. | **Yok.** Masaya oturmak bir karar; oturum her zaman bir sonuca varır. | (a) Nötr "Kalk" — 2 saatlik bedeli atlatılabilir yapar ve "masa kurucunundur"u zayıflatır. (b) Çıkış ama toplantı hakkı yine de yanar. |
| 2 | Kayıp nedeni sırası. §5.2 taksonomiyi veriyor, önceliği vermiyor. | kararlılık → sağlayıcı → eksik kademe → geçiş riski → fiyat; fiyat düşen dal. | (a) Arketipin eksen ağırlıklarına göre tartmak. (b) En büyük negatif modifier'ı seçmek (sayıyı cümleye çevirir, §9.6'ya aykırı hissettirir). |
| 3 | Temsilcinin kapattığı anlaşmada koltuk sayısı. §5.3'ün bandı kurucunun masasında pazarlık edilir; temsilcinin masası yok. | Bandın **ortası**. | (a) Temsilcinin yıldızıyla ölçeklemek — §7.5 "yıldızı fiyata dokunmaz" ile çelişir. (b) Rastgele — RNG yasak. |
| 4 | Kapanışsız hafta özet kartı düşürür mü? | **Hayır.** Sıfır kapanış rapor değildir. | (a) "Bu hafta kapanış yok" kartı — gürültü, ve §13.6'nın tabanı motorun işi. |
| 5 | İç ses satırı nasıl seçilir? §5.1.1 bütçeli ve koşullu diyor, hangisini demiyor. | Oturum başına en fazla bir kez, ikinci kurcalamada, üç satır dönüşümlü. | (a) Kurcalamalar gibi kriter-skorlu seçici — üç satır için fazla makine. |
| 6 | Hakaret bölgesi cetvelde ÇİZİLİYOR. §5.3 rezervin çizilmemesini şart koşuyor, bölge için "farklı ton" diyor. | Bölge çiziliyor. | (a) Yalnız buton tonu değişsin — oyuncu çizgiyi hiç görmeden üstüne basabilir, ki I3 telgrafsız kaybı yasaklıyor. |
| 7 | Dürüstlük primi arketip başına bool. | Bool. | (a) Arketip başına ölçek — üç stub'da ayırt edilemez, kalibrasyon yüzeyi şişer. |
| 8 | Balina şartı karşılandığında ne olur? | Kart şartı **düşürür** ve `whale_condition_met` bir kez yayınlanır. | (a) Yalnız imzada yayınlamak — kapının açıldığı an oyuncuya hiç söylenmez. |

---

## 4 · §19 emeklilik listesi — koddaki akıbeti

Tam tablo Faz 0 defterinde. Özet: **on maddenin onu da karşılandı**; ikisi silinmek yerine
göç ettirildi ve gerekçesi yukarıda (`EXPANSION_PER_SEAT_MRR` yedeğe, `PitchSystem` uyum
dosyasına). `SCALE_DEMO_MAX` ve enterprise bandı **etkisiz** bırakıldı: musluk 1–3★ üretiyor
ve `roll_scale` hiçbir üretim yolundan çağrılmıyor. Korunanların hiçbirine dokunulmadı; tek
istisna §19'un kendi izniyle genişlemenin fiyat kaynağı.

---

## 5 · Bilinen boşluklar ve olay paketinin bağlayacakları

1. **Fiyat-kırma kartı bağlanmadı** (§18). Kart `data/events/cards/customer/price_break.json`
   olarak var, davranışı ve tetik penceresi `SalesRepSystem.price_break_due` içinde, an
   geldiğinde `rep_discount_requested` yayınlanıyor — ama `EventGate.request` **çağrılmıyor**.
   Bağlamak tek satır; yeri kartın `_wiring_note` alanında yazılı.
2. **Talep deposu yok** (§5.2). Kayıp kütüğü yerel olarak birikiyor ve budanmıyor.
3. **Özellik talebi kanalı kırık — ve Satış'ın işi değil.** `ProductCatalog.FEATURE_POOLS`
   emekli `ai_*` / `saas_*` alt-tip id'lerinde duruyor; oynanan alt-tipler (`erp`, `note_tool`,
   `video_clip`) orada yok. Sonucu: gerçek bir rev 6.1 koşusunda
   `B2BSalesSystem.pick_pain_feature` **""** dönüyor. Satış tarafındaki dürüst cevap, motorun
   adlandıramadığı bir şey için **söz fiilini hiç sunmamak** oldu (`has_promise_target`
   olgusu). Kanalı hat kademelerine yeniden noktalamak Ürün'ün işi; o gün olgu kendiliğinden
   doğruya döner ve fiil geri gelir, burada hiçbir değişiklik gerekmez.
4. **Arketip küraşonu ve kahraman hesaplar** içerik fazının (§18). Üç stub makineyi uçtan uca
   koşturuyor.
5. **Satış masasına lider** (§7.4) demo'da yok; alan iklimi kurucunun Liderliğinden okunuyor,
   ki `HRSystem.area_lead` zaten öyle davranıyor.
6. **Rakip seam'i** açık ve içerik rakip modülünde.
7. **`AREA_PRIMARY_JOB["sales"]` hâlâ `accounts`'u gösteriyor** ve yanındaki yorum hâlâ
   "satış işi emekli" diyor (`hr_constants.gd:302`). İkisi de JOB_SALES geri geldikten sonra
   bayat. **DAVRANIŞ ETKİLENMİYOR** ve ölçüldü: `accounts` işi Satış alanını taşıyor (§12.0),
   `HRSystem.assigned_to(AREA_SALES)` TÜRETİLMİŞ alan listesine bakıyor, ve Satış
   Temsilcisinin Müşteri İlişkileri alanı yok — yani yeni işe alınan bir temsilci ilk günden
   satış kapasitesi sayılıyor, musluk ilk günden büyüyor, masası ilk günden çalışıyor. Tek
   fark hangi SÜTUNDA göründüğü, ve Ekip §4.4'ün türetilmiş tablosu ikisini de o rolün ana işi
   sayıyor. Bir tık uzaklıktaki bir yerleşim farkı için tam süiti (≈3 saat) bir kez daha
   koşmak orantısızdı; bir sonraki Ekip turunun tek satırlık işi.

8. **`sales_price_break_<lead id>` bayrağı `FLAG_TYPE_PREFIXES`'e kaydedilmedi.**
   `game_state.gd:507` kayıtsız bayrağı ADIYLA meşru sayıyor ("unregistered content flag —
   legal, no claim to contradict") ve bool JSON'dan bool dönüyor, yani bu bir tip riski değil;
   `b2b_broke_` ailesiyle aynı hizaya gelmesi tercih meselesi.

9. **`sales.*` seam'leri motorun allowlist'ine kaydedilmedi.** Adlar kararlı; kaydetmek
   `seams_sales.gd` düzenlemesi ve bu görev hiçbir motor dosyası açmadı.

---

## 5.5 · Kapılar — koşulmuş hâlleriyle

| Kapı | Sonuç |
|---|---|
| **Taban** (işe başlamadan, satışa dokunan 74 vaka) | **74/74 YEŞİL.** Atıf için alındı: bu turda kırmızıya dönen her şey bu turun eseridir. |
| **Tam süit** (`tools/smoke_run.sh --all`) | **297/300** · **sıfır** `SCRIPT ERROR` / `Parse Error` / `Compile Error` satırı (runner bir hata token'ı gören vakayı verdictine bakmadan düşürür, o yüzden bu sayı ayrıca ölçülüyor) |
| Kalan üç kırmızı | **ÜÇÜ DE BU TURDAN ÖNCEKİ, ve üçü de kanıtlandı** — aşağıda tek tek. |
| Yeni vaka | **11**: musluk guard'ı · süre + dönüş kilidi · zaman atlaması kurucu-sıfır · zar tekrarı (oturum içi) · zar tekrarı (kayıt sonrası) · tek açık söz kilidi · temsilci seçim kuralı · koltuk fiyatı damgası ve genişleme · §13 kayıt turu · türetilmiş anahtarlar · sunum kuralları · aday eğrisi ve huy filtresi |
| Yeniden noktalanan vaka | **19**. **Hiçbiri silinmedi**; biri (`b2b_rep_portrait_rotation`) konusu — emekli bir görünüm adaptöründeki portre rotasyonu — ortadan kalktığı için `sales_meeting_replays_identically`'ye dönüştü ve yerine zar determinizmini ölçüyor. Kaybolan tek kapsam o portre kuralıdır ve karşılığı olan bir yüzey artık yok. |
| `loc_residue.gd` | **0 hit [CLEAN]**, 2.492 anahtar |
| `loc_csv_integrity` · `loc_format_args` | yeşil (ikincisi bir gerçek hata yakaladı: bir çağrı yeri CSV satırının istemediği bir argüman geçiyordu) |
| `python tools/gen_signal_manifest.py` | 128 sinyal, **emitter'sız 3** — üçü de bu turdan ÖNCEKİ (`employee_eligible_for_promotion`, `raise_requested`, `meeting_requested`). §14'ün on sekizinin hepsinin üretim emitter'ı var. |
| `UiTokens.THEME_STAMP` | **7'de durdu.** `themes/` ve `scripts/theme/` altında tek bayt değişmedi: iki yeni sahne de var olan `Dialogue*` ailesini kullanıyor ve duruma bağlı şekiller kod tarafında `StyleBoxFlat` olarak kuruluyor (`rnd_ui_shared.gd:13-16`'nın sanksiyonlu deseni). |
| Görsel kabul | 11 kare, 1920×1080, tek tek okundu: kenarda kırpılma yok · içeriğinden büyük panel yok · kilitli satır gerekçesini yazıyor · Perde 2'de sıfır replik. İlk turda İKİ gerçek kusur bulundu ve düzeltildi (her iki sahne de 1920 genişliğe yayılıyordu; kadran HUD'un altındaydı). |
| **Duraklama probu** | `--meeting-shot` ve `--negotiation-shot`, ağacı GERÇEKTEN duraklatıp `can_process()` soruyor: `root_can_process=true`, meeting 3/3 ve negotiation 3/3 buton duraklamış ağaçta canlı. Bu tuzak sahne dosyasından da ekran görüntüsünden de görünmez — hız 0 `get_tree().paused`'u çeviriyor ve duraklamış bir Control ÇİZİLMEYE devam edip `gui_input` ALMIYOR. |


### Kalan üç kırmızı, tek tek

Hiçbiri bu turun eseri değil ve hiçbiri bu turun düzeltmesi değil. Atıf iddia değil, ölçüm:

1. **`b2c_satisfaction_gate_experience`** — B2C memnuniyetinin ikinci bir günlük yazarı var
   (`SupportSystem.apply_daily_satisfaction_damage`), vaka ise tek yazar ölçtüğünü sanıyor.
   Ağaçta kendi defter kaydı duruyor:
   `docs/audits/DEFECT_b2c_satisfaction_second_writer_2026-08-26.md`, sahibi Ops, ve defterin
   kendi cümlesi "neither should be made by a task that does not own the satisfaction model".
2. **`save_migration_v7_to_v8`** ve **`trait_migration_real_load`** — ikisi de v7/v5 fixture'ı
   yazıp `read_slot` çağırıyor, `read_slot` ise `MIN_LOADABLE_VERSION`'ın altındaki her şeyi
   `SAVE_ERR_TOO_OLD` ile reddediyor. O sabit **10** ve olay motoru turundan beri 10
   (`cc952e4`); bu turun diff'i ona DOKUNMADI (`git diff` üzerinde satır yok) ve eklenen
   `if version < 11` basamağı reddin ARKASINDA koşuyor. Yani iki vaka bu tur başlamadan önce
   de kırmızıydı. Motorun kendi ladder yorumu aynı şeyi zaten söylüyor: v1→v8 göçleri "v9
   kapısından beri ULAŞILAMAZ" ve "direktöre bayraklandı, süpürülmedi".

**Bu turun kırmızıya döndürdüğü iki vaka vardı ve ikisi de düzeltildi**, çünkü ikisi de
gerçekten bu turun hükmüydü: `job_assignment_and_idle` Satış'ın iş defterinden çıktığını iddia
ediyordu (§3 geri getirdi) ve `save_v10_product_state` şemayı 10'a sabitliyordu (v11'e çıktı).
İkincisinin kendi yorumu ne yapılacağını zaten yazıyordu — "REPOINTED with the schema bump
itself, in the same change" — ve bu sefer de öyle yapıldı.

---

## 6 · F5 rehberi — direktör hangi tıklamayla neyi görür

Her satır bir kabul maddesi.

| Görmek istediğin | Nasıl |
|---|---|
| **Buton yok, prospect kendi geliyor** | Yeni koşu → B2B ürün (ERP) yayınla → Satış sekmesi. BORU HATTI sütununda "Aday bul" kartı YOK; başlıkta "Akış: N/hafta" var. Birkaç gün geçir, kartlar kendiliğinden düşer. |
| **B2C koşu sıfır B2B lead üretir** | Yeni koşu → B2C ürün (Not aracı) yayınla → Satış sekmesi. Boru hattı kilitli-görünür, tek satır: "Canlı B2B ürün yok." Görevler matrisinde Satış sütunu da kilitli. |
| **Temsilci akışı büyütür** | Satış sekmesindeki "Akış" sayısını not et → İK'dan Satış Temsilcisi al ve **Satış** işine ata → Satış sekmesine dön; sayı büyümüş olur. |
| **Lead kartı** | Yıldız satırı (her zaman beş glif), arketip tek satır, sağda kalan gün (son iki günde kırmızı), varsa balina şartı ve "Bu masa liginin üstünde." |
| **Süresi dolan lead** | Bir lead'i yedi gün elleme → kart düşer, SON HAREKETLER'e "… beklemekten vazgeçti" satırı girer. Otuz gün o şirket geri gelmez. |
| **Toplantı tam sahne değişimi** | Bir lead kartında "Görüşmeye git" → ODA ve terminal kaybolur, ekranda yalnız masa vardır. Çıkışta üst bardaki saat **2 saat** ilerlemiştir. |
| **Kurucu-sıfır** | Ekipte kimse yokken bir yapım başlat, toplantıya gir ve çık → build barı kıpırdamaz. Bir mühendisi Build'e atayıp tekrar dene → ilerler. |
| **Günde bir toplantı** | Aynı gün ikinci bir "Görüşmeye git" → buton kilitli, hover: hakkın yarın mesai başında yenileneceğini söyler. Mesai bitimine iki saatten az kala da kilitli. |
| **Kilitli cevap satırı gerekçesini yazar** | `--meeting-shot=locked` ya da oyunda: sağlayıcıyı Yerel'e indir ve bir 2★ masaya otur → "Gücü göster" satırı kilitli ve altında "Sağlayıcın kurumsal kademede değil." |
| **Sessiz iğne + hover** | Toplantıda sağ üstteki yüzdenin üzerine gel → işaretli, sayısız, en fazla dört satır. |
| **Teklife geç** | İkinci kurcalamadan itibaren sağ altta belirir. |
| **Perde 2'de replik yok** | Kazanılan bir toplantıda "Rakamı konuş" → cetvel, rakam, sabır kutuları. Tek cümle yok. |
| **Hakaret uyarısı** | Cetveli sağ uca sürükle → buton tonu değişir, hover "Bu rakam masayı devirir." der. Basarsan masa devrilir. |
| **Onay şeridi** | Kabul edilen bir rakamdan sonra: "N koltuk × $X = $Y MRR" ve altında "Kapasite: 310/400". |
| **İmza fiyatı ve genişleme** | İmzaladıktan sonra hesap kartında "$X/koltuk" görünür. 45 gün sonra Büyüt kartı geldiğinde eklenen MRR **o fiyattan** hesaplanır. |
| **Band tavanı ve 1★ kuralı** | Satış sekmesi → SATIŞ MASASI bloğu. 2★+ temsilcide "Çalıştığı bant:" satırında kademeler + "Kendi ligi". **1★ temsilcide seçici yoktur**, düz bilgi satırı vardır. |
| **Kadran** | Şeridin sağındaki Rekabetçi / Standart / Premium. Değiştir → bir sonraki kapanış o fiyattan olur; süren işleme başladığı kadrandan biter. |
| **Haftalık özet** | Temsilci bir hafta içinde en az bir kapanış yaptıysa yedi günde bir bilgi kartı düşer. Karar butonu yoktur. |
| **Ekran görüntüleri** | `--sales-shot=pipeline\|desk\|b2c` · `--meeting-shot=probe\|locked\|won\|lost` · `--negotiation-shot=open\|countered\|insult\|confirm` |


---
---

# EK · SAHNE TAŞINMASI (rev 6.1 §5.1.1) + HOTFIX TURU 1
### 2026-08-27

> **ÜÇ DALGA NEDEN TEK COMMIT.** Sahne taşınması ayrı indi (`754a822`). Kalan üç dalga —
> Hotfix, Destek Hattı, Kurucu Sahipliği — TEK commit'te, ve bu bir tercih değil bir SONUÇ:
> Destek Hattı'nın B1'i, Hotfix'in EKLEDİĞİ fiili SİLİYOR. Hotfix commit'lenmeden B1'e
> geçildiği için o ara durum çalışma ağacında hiç var olmadı ve `git add -p` yalnız ağaçta
> OLANI aşamalayabilir; sadık bir "yalnız hotfix" commit'i silinmiş kodu yeniden yazmak, yani
> tarihi uydurmak olurdu. Kapılar bu yüzden BİRLEŞİK ağaç üzerinde koşuldu ve tek yerde
> raporlanıyor (bu belgenin sonundaki *Kapılar*). Ders deftere yazıldı: bir dalga yeşilse ve
> bir sonraki dalga onun kodunu değiştirecekse, ÖNCE commit'le.

Aşağısı 4bdc1fb'nin ÜSTÜNE gelen turdur. İki ayrı iş: sahne kabuğu VC pitch düzenine taşındı
(mekaniklere dokunulmadı), ve F5 turunun bulduğu on üç kusur onarıldı.

---

## A · Sahne taşınması — ne taşındı, VC sahnesinden ne alındı

Satış rev 6 doğru mekanikleri yanlış sahnede teslim etmişti: iki sahne de terminal
gramerinde, düz bir zemin üstünde ortalanmış bir metin sütunuydu. rev 6.1 §5.1.1 sahneyi
mühürledi, ve bu tur yalnız kabuğu taşıdı. Yeni `SalesStage` odayı, perdeyi, diyalog sütununu
ve sütun başındaki kimlik bloğunu sahipleniyor; iki perde de onun içindeki TEK içerik
bölgesini sırayla dolduruyor. Perde değişiminin kesintisiz olması bir animasyonla değil
YAPIYLA sağlanıyor: oda, portre ve başlık düğümlerine hiç dokunulmuyor, yalnız içerik bölgesi
boşaltılıp yeniden dolduruluyor. Direktör hükmü: kimlik bloğu sütunun BAŞINDA, VC pitch
sahnesiyle aynı kompozisyonda.

VC sahnesinden **doğrudan alınanlar**: iskeletin kendisi ve sayıları (`RoomFallback` →
`RoomArt` covered-aspect → `Scrim` → `DialogueColumn` paneli 0,605 çapada), `DialoguePortraitCard`
bileşeni olduğu gibi, ve `Dialogue*` tema ailesinin tamamı. **Yeni tema öğesi YOK** —
`THEME_STAMP` 7'de durdu, `themes/` ve `scripts/theme/` altında tek bayt değişmedi.
`UiFactory.initials_of` zaten vardı, yani planın öngördüğü yardımcı-taşıma gerekmedi.

**Kareleri okurken bulunanlar** (hiçbiri tahmin değil; her biri bir karede ölçüldü):

| # | Bulgu | Ne yapıldı |
|---|---|---|
| 1 | İğnenin çevresinde `CardPanelTight` | Kaldırıldı — terminal kartı grameri §5.1.1'de bu sahnede yasak |
| 2 | Sütunun 28px içerleği `room_bosphorus`'un dar krem paspartusundan üç parlak kıymık açıyordu | Sütun üç kenara taştı (`COLUMN_INSET = 0`); VC pariteden bilinçli sapma, gerekçesi kodda |
| 3 | Portresiz müşteride `DialoguePortraitCard` boş bir fotoğraf çerçevesi; `UiFactory.make_avatar` ise 112px'te panele karışıyor (24px çipe göre ayarlı) | Kod tarafı `StyleBoxFlat` madalyon; portre gelirse kart geri gelir, slot yüksekliği ikisinde de sabit |
| 4 | Konuşma tepede, altında 580px boşluk; cevapları aşağı itince soru ile kendi cevapları arasına 260px giriyordu | Konuşma TEK BLOK, iki eşit esnek boşluk arasında ortalandı; blok İÇİ boşluk sabit |
| 5 | Cetvelin rayı ve çapa çizgisi görünmüyordu (`SEPARATOR` / `ACCENT_DIM` sütunun kendi dolgusuna karışıyor) | `SURFACE_SUNKEN` ve `INK_DIM` |
| 6 | Tutamak bandın tabanında yarısı dışarıda çiziliyordu | Sol kenarı kelepçeli |
| 7 | `SalesStage` tek başına monte edildiğinde duraklama probu `root_can_process=false` diyordu | Sahne `process_mode = ALWAYS`'i KENDİSİ kuruyor — çağırana bağlı bir sözleşme sözleşme değildir |
| 8 | `_lose()` prospect'i kayıttan siliyor ve kapanış karesi ADSIZ geliyordu: müşteri, ayrılma gerekçesini söylerken buharlaşıyordu | Sistem haklı ve donmuş; GÖRÜNÜM son kimliği hatırlıyor |
| 9 | `--meeting-shot=lost` gerçekten kaybetmiyordu | Masa artık umutsuz kuruluyor (kurucu Satış/Karizma 0, ürün K1, sağlayıcı yerel, lead 3★) |

**Kareler:** `--meeting-shot=probe|locked|won|lost|handoff` · `--negotiation-shot=open|countered|insult|confirm`.
`handoff` bu turda EKLENDİ ve perde değişiminin tek kanıtıdır: kazanılan masadan Perde 2'ye
geçişte oda, monogram, ad, yıldız satırı ve arketip satırı AYNI piksellerde duruyor. Dokuz
karenin dokuzu tek tek okundu; duraklama probu iki sahnede de 3/3.

---

## B · Hotfix Turu 1 — bulgu bulgu

### Faz 0 · Atribüsyon (F1, F2)

**F1 ÖNCEDEN VARDI, satış yeniden inşasının eseri DEĞİL.** `git log -S` ile ölçüldü: destek
masasını boş bırakan iki şeyin ikisi de daha eski — `AREA_PRIMARY_JOB["customer_success"] =
"accounts"` `2b56fd2`'den (Ekip rev 11 Faz 1+2a), `REFUSAL_DESK_SHUT` ise `cc952e4`'ten (olay
motoru). `4bdc1fb` `hr_constants.gd`'ye dokundu, ama yalnız `JOB_SALES`'i geri getirmek ve
satış aday tablolarını eklemek için.

**F2 DE ÖNCEDEN VARDI.** `pick_pain_feature` `c4eba05`'ten beri `FEATURE_POOLS`'u okuyor ve o
tablo emekli alt-tür sözlüğüyle (`ai_assistant`, `ai_photo_editor`, …) anahtarlı; canlı
sözlük `erp`/`note_tool`/`video_clip`. Uyumsuzluk Ürün rev 6.1 turunda doğdu. Satış yeniden
inşası bunu BULDU ve kendi tarafını `has_promise_target` ile kapattı; kartlar kapatılmamıştı.

### F1 · Destek doğrulaması ölüydü — iki yol da

Kök sebep ölçüldü ve sanılandan derin: **alan ile iş AYNI listedir** (Ekip rev 11 adaptörü;
`clear_areas` doğrudan `clear_jobs`'tur) ve MÜŞTERİ BAŞARISI alanının birincil işi
`AREA_PRIMARY_JOB`'da **HESAPLAR**'dır. Yani bir Müşteri Temsilcisi kendi alanının birincil
işine doğuyor, o iş de hesap sahipliği — masa hiç dolmuyor. Formüller doğruydu, ekran eksikti.

- **(a) Ayrım artık GÖRÜNÜR.** Boş masanın iki hâli ayrıldı: masayı taşıyabilecek biri VARSA
  adıyla söyleniyor ve onu hangi hücrenin oturttuğu yazıyor; yoksa gerekçe atama değil işe
  alımdır.
- **(b) Kurucu masaya oturabiliyor.** `SupportSystem.founder_can_take_desk` +
  `seat_founder_at_desk`, ve İKİ yüzey de (ürün sayfası ve yapım kartı) aynı kurala bakıyor.
  Bedeli görünür ve Ekip §2.1'in kendi kuralıdır: kurucu tek işte olur, masaya oturduğu an
  yapımdan düşer, ve bunu yapım çubuğu söyler. Onay kutusu yok.
- **Kendi düzeltmemde iki hata çıktı ve ikisini de ÖLÇÜM buldu, okuma değil.** Birincisi:
  ilk sürüm işten sonra bir de `assign_area(MÜŞTERİ BAŞARISI)` koşuyordu ve kurucuyu az önce
  oturduğu masadan İNDİRİYORDU (yukarıdaki adaptör yüzünden). İkincisi: kapı
  `fix_run_refusal() == DESK_SHUT` idi, ama masa boşken doğrulanmış hata sıfırdır ve ret
  NO_BUGS olur — yani kurucu o düğmeden ASLA oturamazdı. Kapı artık MASANIN KENDİSİ.
- **Yan bulgu, düzeltildi:** `AREA_PRIMARY_JOB["sales"]` hâlâ `"accounts"` diyordu ve yorumu
  "satış işi emekli". Satış rev 6 `JOB_SALES`'i geri getirdi ve bu tabloyu güncellemedi — yani
  Satış alanına atanan herkes HESAPLAR'a oturuyordu ve §3'ün "atanmış satış kapasitesi"
  musluğu hiç dolmuyordu. **Bu kusur `4bdc1fb`'nin eseridir.**

### F2 · Hayalet söz kilidi ve ölü token'lar

Üç ayrı kusurdu, üçü de kapandı:

1. **Hayalet.** `pick_pain_feature` "" döndürüyor, `promise_create` de ondan HEDEFSİZ söz
   üretiyordu. Böyle bir söz asla tutulamaz (hiçbir zaman "" yayınlanmaz), süre süpürmesi ona
   ulaşamaz, ve `has_open_for` sonsuza dek true kalır: bir hesabın bir retention kartını
   cevaplaması, söz kolunu koşunun geri kalanı için kapatıyordu. `PromiseRegistry.create` artık
   boş hedefi REDDEDİYOR, ve yüklemede `drop_targetless()` eski kayıtlardaki hayaletleri
   süpürüyor (kapanmış sözlere dokunmadan — tarih tarihtir).
2. **Yalan kilit satırı.** Söz satırı ÜÇ koşula bağlıydı ve üçünün TEK ortak gerekçesi vardı:
   "bu hesaba verilmiş bir söz zaten açık". Gerçekte reddeden koşul "bu hesabın adı konmuş bir
   talebi yok" idi. Koşullar artık kendi gerekçelerini taşıyor, ve modal kilitli satırda CANLI
   gerekçeyi okuyor — motor `EvCondition.reason_of` ile bunu zaten destekliyordu, yalnız cephe
   bağlamı düşürüyordu (aşağıdaki tek satırlık motor dokunuşu).
3. **Ölü token'lar.** `{company}` diye bir scope slotu YOK — slotun adı `customer`. Kart
   metninde çözülen beş anahtar düzeltildi. `{feature}` için kaynak yok, cümleler onsuz yeniden
   kuruldu. `{voice}` iki kartta `{seam:musteri.complaint_voice}`'a bağlandı — ama CSV'ye
   DEĞİL: `loc_csv_integrity` haklı olarak reddetti (seam biçimi kart sözdizimidir), o yüzden
   o iki gövde kartın kendi TR/EN alanlarına taşındı ve artık kimsesiz kalan iki CSV satırı
   düştü. Bir cümle, tek ev.

### F3–F13 · kısa kısa

| # | Sonuç |
|---|---|
| **F3** | Hesap kartında açık söz satırı (özellik + gün). Bugün nadiren çizilir ve bu bir ÖLÇÜM: havuz canlı sözlüğe dönene kadar hiçbir hesap adı konmuş talep taşımıyor. |
| **F4** | Bilgi kartı karar giysisini bıraktı — "KARAR" damgası ve "SEÇİM KALICIDIR" altlığı yok. Test TÜRETİLMİŞ: `GameEvent` kart sınıfını taşımıyor, o yüzden modal kartın NE OLDUĞUNU soruyor (tek seçenek + o seçenek hiçbir şeyi değiştirmiyor). Ayrıca özet artık SATIR taşıyor: hesap · yıldız · koltuk × fiyat · MRR, artı toplam. |
| **F5** | Yeni imzalanan hesap, yeri olan en az yüklü sorumluya oturuyor (`AUTO_ASSIGN_ON_SIGN`, `# DESIGN-PARKED`). Pinlenmiyor — pin oyuncunun kararıdır. |
| **F6** | Temsilci masası koltuk sayısını bandın ORTASINDAN alıyordu; orta nokta bir sabittir, yani aynı yıldızdaki her hesap aynı anlaşmayı imzalıyordu. Artık koşu tohumu + lead kimliği + arketip. §7.5 kıpırdamadı: temsilcinin YILDIZI hâlâ fiyata dokunmuyor. |
| **F7** | ÖLÇÜLDÜ, kod değişmedi. Tekrar bir latch arızası değildi: gövde token'ları çözülmediği için iki AYRI hesabın kartı birbirinin aynıydı; F2c onu kapattı. Ailedeki her kartın zaten varlık-başına bekleme süresi var (14–21 gün; `retention`'ın 1 günü belgeli ve İlgilen'i yaşatıyor). **AİLE ÇAPINDA bekleme ifade EDİLEMİYOR:** `latch_key` yalnız `run` ve `entity` alıyor. Motor işi, açık bırakıldı. |
| **F8** | "İndirim ver → MRR +$0" — etki canlıydı, ÖNİZLEME ölüydü: kart JSON'ının hiç taşımadığı bir `mrr_delta` alanını okuyordu. Önizleme artık etkinin okuduğu yerden, aynı sabitle hesaplıyor. |
| **F9** | Ticker kapısı §7.3'ün üçünü de kaçırmıştı: balina terimi yoktu ve HER 3★ koşunun sonuna kadar sızıyordu. Tek ev (`SalesLedger.is_newsworthy_signing`), iki tüketici. |
| **F10** | ÖLÇÜLDÜ: sayaç zaten canlı durumu okuyordu (`roster_size` → `CustomerRegistry`). SIFIR GERÇEKTİ — hiçbir hesap atanmamıştı, çünkü `_delegate_excess` yalnız kurucunun tavanını AŞANI devrediyor ve onboarding'e bilerek dokunmuyor. Asıl eksik F5'ti; o kapandı. |
| **F11** | Kadranın seçili konumu iki neredeyse-aynı tema varyasyonuyla ayırt ediliyordu. Kod tarafı `StyleBoxFlat`: amber dolgu + accent kenar + accent yazı. Tema öğesi eklenmedi. |
| **F12** | İki sayma kuralı vardı ve ikisi de kendi sorusuna göre haklıydı. HESAP = aktif müşteri eksi B2C toplu kullanıcı tabanı kaydı (o bir KİTLE, sıfır koltuklu) → `CustomerRegistry.account_count()`, yeni `sales.account_count` seam'i, ve haftalık özet oraya bakıyor. **İlk denemem `musteri.count`'u oraya noktalamaktı ve YANLIŞTI** — traction kapısı o seam'i "ilk gerçek müşterin" diye okuyor ve B2C koşusunda o müşteri toplu kayıttır, yani B2C yolunda kapı hiç açılmıyordu. Süitin ilk dakikasında `gate1_b2c` yakaladı. İki soru, iki ad; vaka artık ikisini birden çiviliyor. |
| **F13** | Ölçüldü ve GERÇEKTEN KIRIKTI — stub kıtlığı değildi. `erp` tek canlı alt-tür, onu `subtype_affinity`'de yalnız bir arketip adlandırıyor, ve seçici afinite listesini boş değilse OLDUĞU GİBİ döndürüyordu: havuz her zaman tek elemanlı, üç arketipin ikisi hiçbir yıldızda çıkamıyor. Afinite artık AĞIRLIK (`AFFINITY_WEIGHT = 2`), dışlama değil. |

---

## C · Park edilmiş kararlar (bu tur)

1. **İmza indirimi yazılmıyor** (`sales_finalizer.gd`). Alan şemada duruyor ve 0 kalıyor.
   Sebep: beslediği yüzey §12'nin fiyat-kırma izidir ve o kart tanımlı-ama-atıl. Alternatif:
   sayıyı tut, yüzeyi dürüstçe "pazarlık farkı" diye yeniden adlandır — arkasında bir string
   olan bir isimlendirme kararı, o yüzden direktöre gidiyor.
2. **F5'in atama tablosu** (`AUTO_ASSIGN_ON_SIGN`) hesap-yönetimi oturumunun işi. Bugünkü
   kural: yeri olan en az yüklü sorumlu, eşitlikte id.
3. **`AFFINITY_WEIGHT = 2`** bir [ÇALIŞMA] değeri. Üç stub'la ölçülemez; arketip küratörlüğü
   turunda kalibre edilir.

## D · Modül-arası ve motor bildirimleri

- **`FEATURE_POOLS` yeniden noktalanması ALINMADI, ve gerekçesi ölçüldü.** Kriterin cevabı
  "birden fazla yer": havuz kaynağı VE `PromiseRegistry._on_build_phase_changed`, ki o bir sözü
  `GameState.get_flag("mvp_components")` içinde arayarak tutuyor — hat/kademe modelinin
  yazmadığı bir bayrak. Yalnız havuzu noktalamak her sözü sessizce TUTULAMAZ yapardı, ki bu
  kapıyı kapatmaktan kötüdür. **Ürün turuna devredildi**; o gelene kadar söz satırı dürüstçe
  kilitli ve gerekçesini adıyla söylüyor.
- **İki satırlık motor dokunuşu, ikisi de eklemeli ve bildirimli.** (1) `EventGate.condition_report`
  isteğe bağlı bir `context` alıyor ve `condition_reason` eklendi — bağlamsız sorulduğunda bir
  `entity_seam` yaprağının öznesi yoktur, o yüzden suçlama ağacı yanlış koşulu adlandırıyordu;
  açıklayan yol zaten bir ctx taşıyordu, yalnız cephe onu düşürüyordu. (2) `musteri.count`
  `sales.account_count` ve `sales.weekly_closes` KAYDEDİLDİ (F12, F4) — seam kaydı içeriğin
  motora soru sorma yoludur; aritmetik ve biçim Satış'ta durur. `musteri.count` KIPIRDAMADI ve
  kıpırdamamalı: anlamı "aktif KAYIT", ve traction kapısı ona dayanıyor.
- **`funding/gate_series_a.json`'ın sözlük gövdesi hâlâ `lint.gd:320`'de atıyor.** Geçen turun
  bulgusu, bu turda da düzeltilmedi: Yatırım modülünün ya da lint'in işi.

## E · Bilinen açıklar

- Yapım HUD'u Satış sekmesinin sağ üst köşesini örtüyor (portföy sütununun başı ve "BU AY NET"
  hücresi). Bu turdan önce de vardı ve paylaşılan bir kabuk kararıdır; F listesinde yok.
- Aile çapında kart bekleme süresi ifade edilemiyor (F7).
- Söz kolu, havuz Ürün turunda noktalanana kadar dürüstçe kilitli (F2d).


---
---

# EK 2 · DESTEK HATTI REWORKU (B1–B5)
### 2026-08-27 · ayrı commit, aynı push

Yönetmen hükümleri müşteri bakım hattını yeniden şekillendirdi. Beş davranış indi; gerisi
dondu. **Sıralama hükmü:** görev "Event Deck Delete" commit'ini taban gösteriyordu, ama öyle
bir commit YOK — direktör "Hotfix'i indir, sonra bunun üstüne başla" dedi ve öyle yapıldı.

---

## B1 · Pasif kurucu doğrulaması

**Bir önceki turun eklediği FİİL SİLİNDİ.** Hotfix turu kurucuyu masaya oturtan bir düğme,
bir iş yazımı, bir bedel satırı ve iki UI dalı eklemişti. B1 hepsini kaldırıyor ve yerine
**tek bir okuma** koyuyor: kurucu başka hiçbir şey yapmıyorsa müşterilerle ilgileniyordur.

Saklanan hiçbir şey yok, o yüzden ayrışabilecek hiçbir şey de yok. "Meşgul olunca durur,
bitince kendiliğinden geri gelir" şartı için **tek satır kod yazılmadı** — türetilmiş bir
okumanın, türediği şey geri değiştiğinde yaptığı şey zaten budur.

`founder_passive_care()` üç var olan okumanın birleşimi: hiçbir işe atanmamış
(`assigned_job_ids` boş), `HRSystem.is_busy` değil (izin · eğitim · yatırım hazırlığı · satış
toplantısı), ve durumu aktif. Artı **canlı ürün şartı**, ki §2.3'ün BOŞTA hâli korunsun:
oyunun ilk günlerinde kurucu gerçekten boştadır, ilgilenen değil.

`founder_task_state()` ÇAĞRILMIYOR ve bu bilinçli — o fonksiyon bu yanıtı okuyup `CARE`
dönüyor, yani buradan onu çağırmak sonsuz özyineleme olurdu.

**Yol açtığı bir bayat dal düzeltildi ve B1 ona BAĞIMLIYDI.** `founder_task_state()` hâlâ
`JOB_ACCOUNTS → SALES` diyordu, yorumu da "Satış bir İŞ değil" — 2026-08-25'te doğruydu,
Satış rev 6 `JOB_SALES`'i geri getirince yanlış oldu. Sonucu bugüne kadar sessizdi: SATIŞ
işindeki kurucu makineden **BOŞTA** diye çıkıyordu. B1 altında bu sessiz hata bir yalana
dönüşürdü — boşta okunan kurucu "müşterilerle ilgileniyor" sayılır ve satış yaparken destek
üretirdi.

**Ekran:** yeni `FOUNDER_STATE_CARE` durumu ve destek bandının **üç ayrı cümlesi**. İkisi
karede okundu: meşgul kurucu → *"Meşgulsün: Bir yapımda çalışıyor. Masaya bakan kimse yok."*,
pasif kurucu → *"Kimse atanmadı; sen ilgileniyorsun."* (uyarı rengi yok, çünkü kaybedilen bir
şey yok). İlk yazımda gerekçe satırı `founder_task_label()`'ı cümlenin ORTASINA gömüyordu ve
karede *"Sen Bir yapımda çalışıyor durumundasın"* diye okunuyordu — etiket üçüncü tekil bir
CÜMLE, iki nokta ile alıntılanınca düzeldi.

## B2 · Temsilci + kurucu, oranlar toplanır

Kod yazılmadı, çünkü gerekmedi: `_desk_sum` zaten roster üzerinde TOPLUYOR. B1 pasif kurucuyu
o listeye koyunca yığma kendiliğinden oldu. Yapılan iş kanıttı — vaka üç oranı ölçüyor
(yalnız kurucu · yalnız temsilci · ikisi) ve üçüncüsünün ilk ikisinin TOPLAMI olduğunu
çiviliyor.

## B3 · Rolüne doğan işe alım

Tek tablo: `AREA_PRIMARY_JOB`. `sales` satırı Hotfix turunda düzelmişti; bu tur
`customer_success → support`. Hesap sahipliği etkilenmiyor, çünkü o `Customer.assigned_to`
ile taşınıyor, bir işle değil.

**Üç vaka bu yüzden yeniden noktalandı ve üçü de B3'ün ÇALIŞTIĞININ kanıtı:**
`destek_empty_desk_piles_up`'ın "bordroda var, masada yok" fikstürü kendi kendini çürütür
oldu (taze bir Mİ artık masaya doğuyor); `job_assignment_and_idle` HESAPLAR'ı dolu bekliyordu;
ve `cs_auto_assignment_capacity` zaten bir kez noktalanmıştı. Yeni `hires_land_in_own_column`
vakası bunun bir daha sessizce bozulmasını engelliyor: her rol için varsayılan işin, o rolün
ANA ALANININ çalışabildiği bir iş olması gerekiyor.

## B4 · Yıldız ölçekli kapasite + bakım bonusu

**Kapasite** artık `4 + 2 × yıldız`, tek çift sabitten (`ACCOUNT_CAP_BASE` /
`ACCOUNT_CAP_PER_STAR`, ikisi de [K]). Direktörün çapaları vakada birebir iddia ediliyor:
1★ → 6 · 1,5★ → 7 · 2★ → 8. Yarım yıldız artık GERÇEKTEN bir slot değeri taşıyor; eski
merdiven puanı üçe bölüyordu ve yarımı hiç göremiyordu. Kurucu aynı çağrıyı kendi Mİ
puanıyla kullanıyor, yani **`FOUNDER_DIRECT_CAP` emekli** — "özel kural yok".

**Kalibrasyon uyarısı:** formül `AREA_MAX`'te **14** veriyor, eski 3-6 bandının çok üstünde.
Ayarlanmış değil, bildirilmiş bir yüzey.

**Bakım bonusu zaten vardı ve yeniden noktalandı.** `_tick_satisfaction` yalnız AŞAĞI yönlü
sürüklenmeyi zaten yumuşatıyordu; iki şey değişti: (a) "sahip" artık kurucuyu da kapsıyor
(direktör hükmü — `assigned_to == ""` "sahipsiz" değil "kurucunun masasında" demek, ve
`assign_customer`'ın kendi sözleşmesi bunu söylüyor), (b) bonus HAM EKSENDEN değil
`HRSystem.effective_skill`'den okunuyor, yani alan katsayısı, odak, moral ve huy çarpanları
sayılıyor — iki işe bölünmüş bir temsilci artık gerçekten daha az koruyor.

**Bu gerçek bir ekonomi değişimidir ve öyle raporlanıyor:** erken tek kişilik koşularda
defterin tamamı kurucunundur, yani churn ölçülebilir biçimde yavaşlar.

`# DESIGN-PARKED`: aşınma ÇARPANI çalışma şekli; adlandırılmış alternatif toleransı
genişletmekti (hesap "daha yavaş ekşimek" yerine "daha çok affetmek" olurdu ve §5.2'nin kayıp
nedenleriyle başka türlü etkileşirdi) — direktörün kararı.

## B5 · Mİ aday huy filtresi

Tek satır: `ROLE_TRAIT_BAN["customer_rep"]`. TİTİZ çıktı (faydası yalnız GELİŞTİRMEDE
ateşleniyor, bu rolde saf hız cezası), GERÇEK LİDER çıktı (demoda masa liderliği yok),
HAYIR DİYEMEZ **kaldı** ve rolün imza takası olarak zaten bağlı. Havuz aritmetiği: iki yasak
da bedelli havuzda (beş → üç), aday sayısı üç, tam yeter — satış satırı aynı aritmetiği zaten
geçiyor.

---

## Vakalar

| Yeni | Ne çiviliyor |
|---|---|
| `support_desk_rates_stack` | B2 — üç oran, ve üçüncüsü ilk ikisinin TOPLAMI |
| `hires_land_in_own_column` | B3 — her rol için varsayılan iş, ana alanının çalışabildiği bir iş |
| `owned_account_erodes_slower` | B4 — sahipli hesap daha yavaş aşınır VE fark sahibin çıktısıyla büyür |
| `cs_candidate_trait_filter` | B5 — iki yasak hiç çıkmaz, HAYIR DİYEMEZ çıkar |
| `account_ownership_round_trip` | B4/§13 — sahiplik ve pin gerçek bir kayıttan geri gelir; kapasite TÜRETİLMİŞ olduğu için saklanmaz |

**Yeniden noktalanan (hepsi kendi hükmüyle, aynı commit'te):**
`hotfix_founder_takes_support_desk` (B1 test ettiği fiili sildi; vaka pasif modele taşındı ve
üç geçişi de ölçüyor) · `destek_empty_desk_piles_up` · `job_assignment_and_idle` ·
`cs_capacity_resolution` · `cs_auto_assignment_capacity` · `hr_active_filters`
(`_cs_expertise_of` → `_account_owner`; yokluk yanıtı artık sıfır puan değil `null`, ve vaka
izindeki temsilcinin hesabının kurucuya SESSİZCE düşmediğini de çiviliyor).

## Kapılar

smoke **311/314** (koşulan 314 vakanın üçü de bu turdan ÖNCEKİ kırmızı) · sıfır hata token'ı · `--event-lint` PASS · `--event-probe` 159/159 ·
`loc_residue` 0 hit (2.501 anahtar) · `THEME_STAMP` 7'de sabit, `themes/` bayt-aynı ·
iki kare okundu (`--product-shot=detail_b2b` meşgul hâl · `--product-shot=detail_care` pasif hâl).

## Bilinen açık

Sorumlu atama seçicisinin "3/9" okuması KARE ile doğrulanmadı: popover bir tıklama istiyor ve
onu açan bir harness yok. Sayının kendisi `cs_capacity_resolution`'da çivili; seçici o sayıyı
yalnız biçimlendiriyor.


---

## EK 2b · KURUCU SAHİPLİĞİ (A1–A3)

**Görevin öncülü kısmen yanlıştı ve ölçüldü.** Brief "seçici kurucuyu hiç sunmuyor, hesap ona
verilemiyor" diyordu; kod öyle değildi. `SALES_STEWARD_FOUNDER` satırı VARDI, ÇALIŞIYORDU
(`assign_customer(c.id, "", true)`) ve yalnız hesap ZATEN kurucudayken kapalıydı — ki o doğru
davranış. Gerçekten eksik olan ÖLÇÜYDÜ: personel satırları yük/kapasite gösterirken kurucununki
çıplak bir düğmeydi ve tavanda hiçbir şey onu durdurmuyordu (sessiz taşma).

- **A1/A3 · yapıldı.** Kurucu satırı artık aynı `yük/kapasite` biçimini okuyor (kapasite kendi
  Mİ yıldızından, `founder_account_capacity`; yük doğrudan taşıdığı hesaplar) ve tavanda
  personel satırıyla BİREBİR aynı kapıyı uyguluyor: seçilemez, ve gerekçesini söyler.
- **A2 · zaten yürürlükteydi**, çünkü `_ranked` yalnız `category == "employee"` döndürüyor.
  Yapılan iş hükmü KODA YAZMAK oldu (neden: pasif bakım tek kişilik koşuyu zaten taşıyor;
  üstüne otomatik sahiplik erken oyunu İKİ KAT yastıklardı) ve onu bir nöbetçiyle çivilemek.

### A2 tam olarak DOĞRULANAMIYOR, ve bu bir bulgu

B4'ten beri `assigned_to == ""` İKİ ANLAMA geliyor: "kimse almadı" ve "kurucunun masasında".
`_account_owner` ikincisini okuyor. Dolayısıyla "kurucuya otomatik hesap verilmez" cümlesi
DOĞRUDAN ölçülemez — temsilci bulamayan bir hesap zaten yapısı gereği onundur.

Bunu vakayı yazarken değil, **vakayı ÇÜRÜTMEYE çalışırken** buldum: yasaklanan davranışı koda
enjekte ettim ve vaka yine GEÇTİ. İlk iddiam bir nöbetçi değildi. Ölçülebilir ve hükmün
gerçekten koruduğu iki yarıya taşındı, ve ikisi de çürütmeyle kanıtlandı:

| Yarı | Enjekte edilen kusur | Vaka |
|---|---|---|
| Yeri olan temsilci HER ZAMAN kazanır | `auto_assign_new` devre dışı | **FAIL** ✓ |
| Otomatik atama ASLA pinlemez | `assign_customer(..., true)` | **FAIL** ✓ |

Pin burada mekanik olarak yüklü: `assigned_to` iki anlamı ayıramadığı için, "bilerek kurucuya
verildi" ile "kimse almadı" arasındaki TEK fark odur. Sistemin pinlemesi oyuncunun imzasını
taklit etmek olurdu ve sabah süpürmesi bir daha kendini düzeltemezdi.

**Direktöre açık soru:** A2'yi gerçekten yaptırıma bağlamak istiyorsan kurucu sahipliğinin
"sahipsiz"den ayrı bir işareti olmalı. Bugün o işaret pindir ve yalnız oyuncu koyuyor; ayrı bir
alan istemek hesap-yönetimi turunun kararı.
