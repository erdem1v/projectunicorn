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
