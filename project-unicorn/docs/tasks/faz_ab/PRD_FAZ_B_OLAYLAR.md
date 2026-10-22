# Faz B · Görev · Olaylar (acil durum, sprint ortası kâğıtlar, söz olayı, sürüm anı, mail saatleri)
2026-10-16 · Sahip: Erdem · Bu belge **ne beklediğimizi** söyler: çıktı ne olmalı, oyuncu ne görmeli, nasıl görmeli,
neyle kabul edilir. Nasıl yapılacağına uygulayıcı ajan karar verir.

## Bu belgeyi alan ajana
- Faz B'nin uygulama sorumlusu sensin. İşi alt ajanlarla yürütürsün; modeller §8'dedir.
- **İlk iş:**
  1. Bu belgeyi ve §0'daki ekleri oku.
  2. Erdem'e adım tablonu ver. Sütunlar: Adım | Ne | Kim | Model | Düşünme | Süre | Neden.
  3. Onayını bekle.
  - §8'deki tablo başlangıç noktasıdır. Değiştirirsen gerekçesini yaz.
- **Erdem'e döndüğün yerler:**
  1. adım tablosunun onayı,
  2. üç yazım dalgası (W1, W2, W3),
  3. A'yı bekleme (§9),
  4. son rapor (R).
- Bunların dışında sormadan ilerlersin.
- **"Onay bekliyor" işareti:** Bu belgede "önerildi, Erdem itiraz etmedi" diye geçen her sabit ve kural, kodda ve raporda
  "onay bekliyor" diye işaretlenir (CLAUDE.md §3).
- **Faz A önce gelir.** A başka bir ajanda koşuyor olabilir. A bitene kadar oyun koduna dokunmazsın; o sırada
  yapabileceklerin §9'dadır.

## 0. Ekler ve öncelik
Ekler `docs/tasks/faz_ab/ek/` klasöründedir.

| Ek | Ne işe yarar |
|---|---|
| `B_PLAN.md` | Tasarım girdisi: formüller, dosya:satır başvuruları, commit dilimleri. İncelendi; `B_INCELEME.md`'deki 90 düzeltme işlendi |
| `B_ARASTIRMA.md` | SLA kredisi, B2C telafisi ve olay sıklığı araştırması |
| `ERDEM_TUR2_YORUM.md`, `ERDEM_AB_CEVAP.md` | Erdem'in sözleri, birebir |
| `ORTAK.md` | Fazlar arası sınırlar. İçindeki dosya yolları planlama turuna aittir; yalnız sınırlar için oku |
| `TUR2_SUNUM.md` | Erdem'e gösterilen ikinci tur tasarımı ve reddedilen fikirlerin işaretleri |
| `docs/tasks/faz_ab/PRD_FAZ_A_HATALAR.md` (`ek/`'in bir üstünde) | A'nın görevi. B'nin okuduğu her şey oradan gelir |

**Öncelik ve kaynaklar**
- Bu belge `B_PLAN.md` ile çelişirse **bu belge** geçerlidir.
- **A'nın gerçek adları:** `docs/tasks/faz_ab/RAPOR_A.md`'deki okuma ve yazma noktalarındadır. Plandaki A adları
  tahmindir.
- **Satır numaraları:** Plandakiler plan günündendir; güncel satırları B0 haritası bulur.
- **Adım numaraları:** `B_PLAN` ve `B_INCELEME`'deki B1–B9 dilim numaraları bu belgenin adım numaralarıyla aynı değildir.
  Bu belgede B1–B9 her zaman §8 tablosunu kasteder.
- **C_PLAN:** Bu klasörde yoktur. C'nin doluluk kararı açıktır.
- **Proje kuralları:** `CLAUDE.md`'de. Kod haritası `docs/HARITA.md`'dedir.

**`B_PLAN.md`'de geçersiz olanlar** (kodlanmaz)
1. Gece düzeltmesinde moralin süreye bağlı formülü −(6 + saat) ve bedelin mesai süresi olarak yazılması. Yerine Karar 6
   gelir.
2. Gece düzeltmesindeki "%25 ihtimalle o hatta 1 yeni açık hata" bedeli. Bedel yalnız moraldir (Karar 6).
3. %50 kesinti kredisi kademesi. Yerine Karar 5 gelir.
4. B2C söz ikizi: `b2c_roadmap_ask` ve `b2c_roadmap_due`. Bunlarla birlikte `Promise.source` B2C dalı da kalkar.
5. Testçi KDV kâğıdı (K2).
6. Not ve video uygulamasına özel bütün metinler: belirtiler, alıntılar, "not asgarisi" yorumları, K7.
7. Plandaki bütün örnek metinler. Erdem hepsini uzun buldu. Metinler §3'e göre baştan yazılır.
8. **Hat başına hata eşikleri:**
   - Şu eşikler hataların bir hatta yığıldığı varsayımıyla yazılmıştı:
     - yorum fırtınası: bir hatta en az 6 hata,
     - ay sonu: fatura, defter ya da nakit hattında en az 2 hata,
     - K1 kâğıdı: hatta en az 3 hata,
     - checkout ağırlığı.
   - A'da hatalar artık hatlara rastgele dağılıyor (A Karar 3). Bu yüzden eşikler yeniden seçilir:
     - B0, A'nın `fix_worst` ve `fix_none` kollarında hat başına açık hata dağılımını okur.
     - Eşikler bu dağılıma göre "onay bekliyor" diye önerilir.
9. §5.8'deki "SCHEMA_VERSION değişmez" cümlesi. Şema B1'de 17 olur.
10. `A_PLAN` ve `A_INCELEME`'deki "D 17" şema numarası.
11. Haftalık kâğıt zarı (`week_chance` 0,45). Kabul §4.5'e göre yeniden seçilir.

## 1. Amaç
Sprint döngüsü oyuncunun en çok vakit geçirdiği yer. Erdem: "Angarya gibi görünmemeli; tüm sihri burada yarattığını
hissetmeli."

Bu fazdan sonra:
- **Krizler:** Seyrek, sürpriz ve gerçek gelir. Her seçenek kime neye mal olacağını sayıyla söyler.
- **Sprint ortası kâğıtları:** Ekipten biri konuşur. Kâğıt kısa ve okunur olur, aylarca tekrar etmez.
- **Söz:** B2B'de verilen sözün teslimi yaklaşınca oyuncu sıkışır.
- **Sürüm sonrası:** Müşteri kısa bir teşekkür yazar ya da kullanıcı yorumları gelir.
- **Mail saatleri:** Mail ve bildirim mesai saatinde gelir. Gece yarısı birden düşmez.

## 2. Kararlar (bağlayıcı)
### Acil durumlar
1. **Beş olay:**
   - gece kesintisi (B2B ve B2C),
   - ay sonu kapanışı yapamıyoruz (B2B mail),
   - ödeme alınamıyor (B2C),
   - sürüm sonrası bozulma,
   - yorum fırtınası (B2C).

   Satıcıların ödeme alamadığı ikiz olay yoktur.

   Ağırlık seviyeleri:
   - servis çöktü,
   - tek akış ya da önemli bir müşteri tıkandı,
   - küçük sorun. Küçük sorun olay olmaz.
2. **Sıklık:**
   - İki olay arasında en az 4 hafta geçer (Erdem). Sonrası rastgeledir; Erdem'in örnekleri 8 ve 10 haftadır. Olaylar
     asla düzenli gelmez.
   - "Sürüm sonrası bozulma" da bu aralık kuralına tabidir.
   - Olay kapısı kartı reddederse olay başlamamış sayılır. Bedel, saat tutuşu ve aralık sayacı ilerlemez.
3. **Olasılık:**
   - Olasılığı üç şey belirler: sunucu kalitesi, açık hata (A'nın deposu) ve son sürümün hatalı çıkması.
   - **Doluluk henüz karar değildir.** Erdem doluluğun gerekip gerekmediğini ve diğer oyunların nasıl yaptığını araştırma
     sonucuyla görmek istiyor. Olasılığın "sunucu kalitesi × doluluk" ile hesaplanması da bu araştırmaya dahildir.
     Araştırma C'de yapılır.
   - **Bu fazda doluluk:**
     - B doluluğu tek bir çarpan fonksiyonundan okur. Fonksiyon C karar verene kadar 1 döner.
     - Çarpan 1 dönerken `BASE` 0,10'dur [onay bekliyor].
     - "Sunucular kapasitenin sınırındaydı" gibi bir yük sebep cümlesi bu fazda yazılmaz.
4. **Gece olayı:**
   - Olay gece başlar (örnek 02:10). Kart ilk tam saatte (03:00) açılır ve geçmiş zamanla anlatır.
   - Gece saatlerinde **yalnız acil durum kartı** açılır.
   - Kuyruktaki öbür kart ve kâğıtlar şirketin mesai başına kadar bekler (Karar 21'deki tanım). Karar verildikten sonra
     da beklerler.
5. **Bedel olayın ölçeğinden türer.** Olaydan kopuk sabit $ ya da sabit % yoktur.
   - **B2B kesinti kredisi:**
     - Hesabın aylık ücretinden düşülür. Oran, kesinti süresine göre %10 ile %25 arasında kademelidir. %50 yoktur.
     - Kredi **tek seferliktir**: bir faturadan düşülür ve finansa tek seferlik gider olarak girer.
     - Hesabın aylık ücreti (`mrr`) değişmez.
     - Kredinin tabanı olay anındaki `mrr`'dir.
   - **B2C telafisi:** Etkilenen kişi sayısıyla orantılıdır.
   - **"Ödeme alınamıyor" olayı:** Bu olayın telafisi sepet kuponudur. Kupon pazaryeriyle birlikte E'de gelir. B'de bu
     olayın telafi seçeneği yoktur.
6. **Ekip sorunu hemen düzeltirse (gece ya da mesai dışı):**
   - **Ne yazılmaz:** Bedel mesai süresi olarak yazılmaz; "3 saat mesai" gibi bir ifade olmaz (Erdem).
   - **Ne yazılabilir:** Seçenek sorunun ne zaman çözüleceğini söyleyebilir ("servis 03:00 sularında açılır"). Süre
     ekibin yıldızından türeyebilir.
   - **Bedel yalnız moraldir.** Verim düşüşü yazılmaz; moral zaten çıktıyı düşürür.
   - **Moral düşüşü** saatten değil olayın ağırlığından türer. Erdem 6'dan fazla olmasını istedi. Önerilen değerler
     aşağıdadır; Erdem itiraz etmedi (2026-10-16) [onay bekliyor]:
     - servis çöktüyse −10,
     - tek akış tıkandıysa −7.
   - **Bedeli kim öder:**
     1. Olayın hattında, koşan sprintte kartı olan geliştirici ve testçiler.
     2. O hatta kimsenin kartı yoksa ya da olayın hattı yoksa (kesinti gibi): Görevler matrisinde Yapım ya da Test işine
        atanmış herkes (A Karar 13).
     3. İki küme de boşsa seçenek kilitlenir ve gerekçesi yazar.
   - Çip, bedeli ödeyen kişileri adıyla gösterir.
7. **"Kendin bak":**
   - Yalnız kurucu tekken ya da ekip en fazla 2 kişiyken açılır.
   - Bedeli: kurucunun gelecek haftaki verimi %15 düşer, 1 hafta sürer [onay bekliyor]. Erdem yalnız %40'ı ağır buldu.
   - Karar 6'daki süre kuralı burada da geçerlidir.
8. **"Sonraki sprinte bırak":**
   - **B2B.** Erdem ilk açıklamayı anlamadığını söyledi. Kural sade hâliyle yeniden açıklandı; Erdem itiraz etmedi
     (2026-10-16) [onay bekliyor].
     - O hesabın memnuniyeti hemen 6 puan düşer.
     - Düzeltmeden geçen her sprint sonunda 3 puan daha düşer.
     - Düşüş haftada yaklaşık 3 puan affedilir.
     - Sonuç: bir kez erteleyen oyuncu hesabı kaybetmez; ertelemeyi alışkanlık yapan kaybedebilir.
     - Sayılar ayar sabitidir. Erdem ayrılma eşiğinin 30 civarında olmasını istiyor (tur 2). Eşik C'de bu isteğe göre
       ayarlanacağı için sayılar o zaman yeniden ölçülür.
   - **B2C, düzeltilebilen hata:** Kitle düzelene kadar haftada %2 azalır.
     - Süren düşüş, olay sisteminin kayıtlı durumudur.
     - Düşüş, A'nın deposunda o hattın hatası kapanınca ya da düzeltme sürümle çıkınca biter.
   - **B2C, tam kesinti:** Bu seçenek kilitlidir; gerekçe yalnız olguyu söyler. Hangi seçenek seçilirse seçilsin kitle
     anında bir kez düşer.
9. **"Sprinti durdur, şimdi düzelt":**
   - O hattın düzeltme kartı koşan sprintin en başına girer.
   - Kart zaten sprintteyse ikinci kart açılmaz; var olan kart başa taşınır.
   - Bedel, sprintten kayan karttır. Çip kayan kartın adını söyler: "Toplu fatura sonraki sprinte kayar".
   - Seçenek ekip ikiden büyükken de açıktır. Böylece hiçbir olayda tek bir seçenek kalmaz.
   - A'nın "sürekli hata sprinti yok" hedefini (A Karar 4) bozmaz: olaylar en az 4 hafta arayla gelir ve §4.11 bunu ölçer.

### Sprint ortası kâğıtları
10. **Konuşan kişi:** O kartta, o aşamada gerçekten çalışan kişidir.
    - Kaynak tektir: SprintSystem'in kart ataması (`assignees`, `role_of`).
    - A, Görevler matrisini sprinte bağlar (A Karar 13). Bu yüzden atama, ekipte kime hangi işin verildiğini de yansıtır.
    - Payının bir kısmı Destek'te olan kişi, kartta atanmışsa konuşabilir. Payının tamamı Destek'te olan kişi sprintte
      değildir ve konuşmaz.
    - **PM kâğıtları istisnadır.** PM sprintte kart almaz; Erdem'e göre PM önden gider.
      - Konuşan, ekipteki ürün yöneticisidir.
      - Kâğıdın konusu o sprintte planlanmış bir müşteri isteği kartıdır.
      - Ekipte PM yoksa PM kâğıdı gelmez.
11. **Havuz:** 40 kâğıt, rol ve aşamaya göre.
12. **Sıklık:**
    - Sprint başına **en fazla bir** kâğıt gelir. Erdem: iki kâğıt "yorar, boğar".
    - **Bazı sprintlerde hiç kâğıt gelmez.** Her sprintte bir kâğıt gelmesi de beklenmez.
    - Aynı kâğıt 52 hafta geçmeden dönmez ve bir koşuda en çok 3 kez görünür.
    - **Kesinti sırası** [önerildi, Erdem itiraz etmedi (2026-10-16); onay bekliyor]. Bu kural Erdem'in "iki kâğıt yorar"
      sözünün uzantısıdır: bir sprintte en çok bir kesinti olur.
      - Söz olayı ya da acil durum gelen sprintte kâğıt gelmez.
      - Kâğıt gelen sprintte yalnız "servis çöktü" ağırlığındaki acil durum gelebilir. Öbür olaylar sonraki sprinte kayar.
13. **Testçi KDV kâğıdı çıkar.** Erdem: "Gördüğüm en kötü eventlerden biri." Yerine okununca hemen anlaşılan bir testçi
    kâğıdı gelir.

### Söz olayı ve sürüm anı
14. **B2B söz olayı** onaylandığı gibi kalır. Seçenekleri:
    - Testi kısalt,
    - Ekipten fazla mesai iste,
    - Arayıp bir sprint ek süre iste,
    - Söz kaçsın.

    **"Testi kısalt"ın bedeli:**
    - D'nin `escape_chance` fonksiyonu bugün yoktur. D gelene kadar bedel tek bir ayar sabitinden okunur:
      - Kısaltılmış testin hatalı çıkma ihtimali `sprint.json`'da durur.
      - Öneri %15'tir [onay bekliyor].
      - Bugünkü %40 testsiz zarı kullanılmaz; Erdem onu fazla buldu.
    - Çip önceki ve sonraki değeri aynı yerden okur.
    - D gelince bu sabit `escape_chance`'e bağlanır.
15. **B2C'de söz olayı yoktur.** Şirketler sürüm çıkmadan tarih vermez; sürüm çıkınca sürüm notu paylaşır.
    - Erdem B2C eşdeğerini "üstüne düşünmek lazım" diye açık bıraktı.
    - Bu fazda aranmaz. `docs/ACIK_ISLER/ISLER.md`'ye bir satır düşülür.
16. **Teşekkür maili (B2B):**
    - 1–2 cümledir ve duruma göre yazılır.
    - Üç tetikleyicisi vardır:
      - **Acil durum hızla kapandı** (acil durum sisteminden): olay "Ekip hemen düzeltsin" ya da "Kendin bak" seçeneğiyle
        aynı gece ya da aynı gün kapandı.
      - **Söz verilen özellik çıktı** (`PromiseRegistry`).
      - **İstenen özellik çıktı** (istek verisi).
    - **Sınırlar:**
      - Bir hesaba bir sürümde en çok bir teşekkür gider.
      - Bir sürümde en çok 3 teşekkür gider.
      - Söz ile istek aynı özellikse söz metni seçilir.
17. **B2C "Sürüm sonrası öne çıkan yorumlar":**
    - Toplam 2–3 kısa yorumdur. Her biri kaynağıyla görünür: sosyal medya ya da uygulama mağazası.
    - Yorum sürümde çıkan özelliğe ya da düzeltmeye değinir, ama nota ya da videoya özgü değildir.
    - Mağaza (satıcı) sesi ve pazaryeri yorumları E'de eklenir.

### Diğer
18. **Yatırımcı hazırlığı tamamen kalkar** (Erdem). Bugün yalnız Series A'da var.
    - **Silinecekler:**
      - `GameState.prep` ve `pitch_prep_active`,
      - `founder_state`'in `pitch_prep` değeri (`_vocabulary.md` güncellenir),
      - Series A sekmesindeki hazırlık satırı,
      - `PREP_*` sabitleri ve `PREP_BONUS`,
      - `HUNT_PREP_*`, `VC_PREP_*` ve `HR_FOUNDER_STATE_PITCH_PREP` metinleri,
      - hazırlık smoke vakaları.
    - **Kalan:** `MEETING_CHIP_PREP` satış görüşmesinde de kullanılıyor; yalnız VC satırı silinir.
    - **Telafi:** Hazırlık bonusu gidince Series A görüşmesi biraz zorlaşır. Yerine telafi eklenmez [önerildi, Erdem itiraz
      etmedi (2026-10-16)]. Etki §4.8'deki gibi ölçülür.
19. **Not ve video uygulamasına özel metin yazılmaz;** bu iki ürün E'de silinecek.
    - B'nin B2C metinleri ürüne bağlı olmayan genel metinlerdir: uygulama açılmıyor, ödeme alınamıyor, yorum fırtınası,
      sürüm yorumu.
20. **Ay sonu maili** 22:10 ile 22:55 arasında gelir ve kartı 23:00'te açılır. 00:00 adımı hiç kullanılmaz.
    - Bu bir öneridir; Erdem'in cevabı belirsizdi.
    - W1'de saatiyle birlikte gösterilir.
21. **YENİ HATA: gece 00:00 mailleri.**
    - **Erdem'in gözlemi:** Gün 00:00'da dönünce sıradan bir mail gece yarısı düşüyor. Oysa bu mail sabah 09:00 ya da
      10:00'da gelmesi gereken bir mail.
    - **Mesai tanımı:** Mesai, şirketin çalışma penceresidir (`WorkHoursSystem.company_window()`).
      - Başlangıcı oyuncunun ayarıdır: 08:00 ile 11:00 arası, varsayılan 09:00.
      - Bitişi en geç 24:00'tür.
      - `WEEK_START_HOUR` (08:00) mesai başı değildir.
    - **Beklenen:**
      - Acil olmayan mail, kâğıt, hatırlatıcı ve bildirim gün dönümünde düşmez.
      - Her biri mesai içinde bir geliş saati alır. Oyun saati o saate gelince gelen kutusuna ve bildirim yığınına düşer.
      - Bilerek gece gelen acil durumlar kendi saatinde kalır.
      - Kepenk kartı ve son kâğıdı acil sayılır; 00:00'da kalır.
    - **Bilinen üreticiler** (hepsi 00:00 günlük tikinde çalışıyor):
      - `MessageSystem.post`: dönem özeti, haftalık satış raporu, Ar-Ge notu ve keşfi.
      - `tick: daily` olay kartları (82 kart: pool, schedule, arc, signal, floor).
      - `SprintSystem._end_week`: karar kâğıdı ve `team.demo_day`.
      - `CustomerRepSystem`: `customer.request_*`.
      - `HRMoraleSystem`: tükenmişlik ve istifa.
      - `HRSearchSystem`: aday dosyaları hazır.
      - `VCPitchSystem`: term sheet teslimi ve hatırlatıcısı, geri arama, Frank'in mentor satırı.
      - Gelen kutusu hatırlatıcıları (`inbox.gd` `desk()`): B2B Risk ve Genişleme, çalışan ayrılma riski, kapı
        hatırlatıcısı.
      - Kâğıt son uyarısı ve süre bitimi notu (`EvTicker`).
      - Haber bandının canlı satırları (`SummarySystem`, `NewsFeedSystem`, `SprintBridges`).
      - Sprint kapanışındaki sürüm notu.
      - `EndingsSystem`'in kepenk kartı. Bu kart acil sayılır.
    - **Liste eksik olabilir.** Zaman yöneticisinin günlük dağıtımındaki her sistem ve gelen kutusuna ya da bildirim
      yığınına yazan her yol taranır (§5).
    - B'nin yeni üreticileri de aynı teslim kuralına uyar: kâğıt, söz olayı, teşekkür, yorum.
    - **Bugünkü kusurlar:**
      - Mesaj, olay geçmişi ve kâğıt yalnız gün damgası taşıyor. Hatırlatıcılar hiç damga taşımıyor.
      - `mail_pane.gd:122` damga yerine o anki saati yazıyor.

## 3. Yazım (Erdem'in en sert eleştirisi; bağlayıcı)
**Kısa:**
- Müşteri maili en çok 2–3 kısa cümledir.
- Kâğıt gövdesi en çok 3 kısa cümledir.
- Teşekkür maili 1–2 cümledir.
- Oyuncu metni bir bakışta anlar. Cümleyi çözmeye uğraşmaz, okurken sıkılmaz.

**Düz ve doğal:**
- Gerçek bir müşteri ya da çalışan nasıl yazarsa öyle yazılır.
- Uzun açıklama, iş süreci anlatısı ve teknik bulmaca (KDV hesabı gibi) yoktur.
- Müşteri dolambaçsız ister. "Bu gece bakabilecek biri var mı" demez, "Acil çözebilir misiniz?" der.
- Seçenekler kısa birer hamledir.

**Kurallar:**
- Tire yok.
- Gerçek marka ya da şirket adı yok.
- Metin hüküm vermez (CLAUDE.md §5).
- Önce İngilizce yazılır, Türkçe yeniden yazımdır.
- **Değişken yerler:**
  - Değişken yerler yalnız kartın slot adıyla (`{customer}`, `{employee}`) ya da `{seam:ad.ad}` belirteciyle yazılır.
  - Belirtecin ardına ek gelmez: "{customer} ekibi" yazılabilir, "{customer}'nin" yazılmaz.
  - Hatta ya da duruma göre değişen cümle, varyant olarak tam yazılır.
  - Dalgada her belirtecin hangi sayıyı ya da adı taşıdığı metnin yanında yazar. Böylece Erdem'in onayladığı metin
    bağlamada değişmez.

**Ton örnekleri** (ton içindir, son metin değildir)

| Yer | TR | EN |
|---|---|---|
| Ay sonu maili | "Toplu fatura onayı çalışmıyor, ay sonu kapanışını yapamıyoruz. Acil çözebilir misiniz?" | "Batch invoice approval is down and we can't close the month. Can you fix it urgently?" |
| Gece kesintisi | "Servis 02:10'dan beri kapalı. 3 müşteri giriş yapamıyor, en büyüğü Demir Holding (100 kullanıcı)." | "The service has been down since 02:10. 3 customers can't log in, the largest is Demir Holding (100 users)." |
| Ödeme alınamıyor (B2C) | "Dün geceden beri 212 kişi ödeme yapamadı." | "212 people haven't been able to pay since last night." |
| Testçi kâğıdı | "Kupon iki kez düşüyor, müşteri iki kat indirim alıyor. Düzeltirsek kart biraz uzar." | "The coupon is applied twice, so customers get double the discount. Fixing it makes the card a bit longer." |
| Teşekkür (hızlı müdahale) | "Sorunu bu kadar hızlı çözdüğünüz için teşekkürler." | "Thanks for fixing it so quickly." |
| Teşekkür (söz verilen özellik) | "Söz verdiğiniz toplu fatura onayı geldi, teşekkürler." | "The batch approval you promised is here. Thank you." |
| PM kâğıdı (Erdem beğendi; ölçü budur) | "Bu kartı Demir Holding istedi; biz çizerken büyüttük. Filtre ve dışa aktarma bizim fikrimiz. Onları önümüzdeki sprinte atarsak kart bu sprintte biter." | aynı anlam |
| Geliştirici kâğıdı (Erdem beğendi) | "Faturalamadaki hataların üçü aynı yerden çıkıyor. Altını yeniden yazarsam bir daha çıkmaz." | aynı anlam |

**Onay:**
- Metinler dalga dalga yazılır ve commit'ten önce Erdem'e toplu sunulur.
- Reddedilen örnekler geri gelmez:
  - testçi KDV kâğıdı,
  - uzun ay sonu maili,
  - uzun teşekkür maili,
  - B2C'de duyurulan tarih.

## 4. Kabul ölçütleri
1. **Olay aralığı.**
   - **Smoke vakası** (sabit girdiyle 300 haftalık koşu):
     - En küçük aralık en az 4 haftadır.
     - Aralıkların en az %30'u 4–6 hafta aralığının dışındadır.
   - **Rapor** (104 haftalık 10 tohum):
     - Koşu başına olay sayısı ve aralıklar raporlanır.
     - Önerilen hedef: koşu başına 4–14 olay [onay bekliyor].
2. **Bedel.** Smoke vakası şunları kanıtlar:
   - Her bedel çipteki sayıyla aynıdır.
   - B2B kredisi aylık ücretin %10 ile %25'i arasındadır ve tek seferlik gider olarak girer; `mrr` değişmez.
   - B2C telafisi etkilenen kişiyle orantılıdır.
3. **Gece.** Smoke vakası şunları falsification ile kanıtlar:
   - Kart 03:00'te açılır.
   - Kuyrukta süresi dolmak üzere olan bir kâğıt varken de 03:00'te açılan kart acil durum kartıdır.
   - Karar verildikten sonra mesai başına kadar başka kart açılmaz. Gece kaldığı yerden sürer.
   - 00:00 adımında hiç istek yapılmaz.
4. **00:00 mailleri.**
   - Gelen kutusundaki her öğe geliş saatini (ss:dd) taşır: mesaj, kâğıt, karar kartı, geçmiş satırı, hatırlatıcı.
   - Ekran o anki saati değil, bu damgayı gösterir.
   - Damga, öğenin görüldüğü andaki oyun saatinden ileride olamaz.
   - Acil olmayan öğe şirketin mesai penceresi içinde damgalanır ve o saatte teslim edilir.
   - Bildirim yığınındaki hatırlatıcılar ve Frank'in satırı da mesai içinde görünür hâle gelir.
   - Bekleyen öğeler kayda girer.
   - Şema bir artar. Eski kayıttaki öğeler "saatsiz" açılır.
   - **Kanıt:**
     - **Smoke vakası `inbox_no_night_stamp`:** 104 hafta boyunca acil olmayan hiçbir öğe mesai penceresinin dışında
       damgalanmaz.
       - Vaka iki ayarda koşar: 08:00 başlayıp 17:00 biten pencere, 11:00 başlayıp 24:00 biten pencere.
       - Falsification: teslim kuyruğu kapatılınca vaka FAIL verir.
     - **`--inbox-shot` için yeni bir "gece sonrası sabah" durumu.** Kareler 00:00'da ve mesai başından yarım saat sonra
       alınır.
5. **Kâğıt sıklığı.**
   - **Prob ölçümü:**
     - `--sprint-probe` bugün yalnız kurucunun B2C `note_tool` koşusunu oynar. Bu yüzden proba bir pazar alanı eklenir
       (ör. `market=b2b`, ürün `erp`).
     - Ölçüm iki pazarda da yapılır: `events=1`, `team=3` (tasarımcı, geliştirici, testçi), 104 tik, 10 tohum.
     - Prob sprint başına `SPRINTPROBE PAPER|<seed>|<sprint>|<event_id>|<speaker>` satırı basar, sonunda da boş sprint
       oranını.
   - **Beklenen:**
     - Sprint başına en çok bir kâğıt gelir.
     - Sprintlerin en az üçte birinde hiç kâğıt gelmez [önerilen hedef; onay bekliyor]. Bu oran bir ve iki haftalık
       sprintte ayrı tutturulur.
     - 104 haftada aynı kâğıt en çok 2 kez gelir.
     - Sprint başına toplam kesinti (kâğıt + söz + acil durum) da raporlanır. Bir sprintte birden çok kesinti olmaz
       (Karar 12).
6. **Konuşan kişi ve bedeli ödeyen.**
   - **Smoke vakası `paper_speaker_is_assignee`:**
     - Konuşan kişi, kartın o aşamadaki `assignees` listesindedir.
     - `role_of` o aşamanın rolünü döner.
     - PM kâğıtları bu vakanın dışındadır; onların kuralı Karar 10'dadır.
   - **Bedeli ödeyen:**
     - Acil durumdaki "Ekip hemen düzeltsin" bedeli Karar 6'daki sırayla düşer.
     - Atama değişince çipteki adlar da değişir.
     - Görevler matrisinde yalnız Destek'e atanmış kişi kâğıtta konuşmaz ve gece düzeltmesinin bedelini ödemez.
   - Bu vakalar D'nin kabulünde yeniden koşar.
7. **Tahmin ile sonuç.**
   - `--sprint-probe=...:events=1` koşusunda adsız uyuşmazlık 0'dır.
   - Prob, olayı belli bir tikte zorlayan yeni bir parametre alır (ör. `incident=<tür>@<tik>`).
   - "Sprinti durdur" ve "Testi kısalt" bu parametreyle en az birer kez koşulur. "Testi kısalt" B2B kolunda `team=3`
     ile koşulur.
   - Acil kart girdiği sprintte plan tahmini yeniden okunur ve kapanışla eşleşir.
8. **Yatırımcı hazırlığı.**
   - Kod, metin, kayıt ve smoke tarafında iz kalmaz. `MEETING_CHIP_PREP` satış tarafında çalışmaya devam eder.
   - `full_run_vc_cautious` bir sonla biter.
   - **Önce ve sonra ölçümü.** Bot bugün hazırlığı hiç kullanmaz. Bu yüzden düz bir önce/sonra koşusu fark göstermez.
     Ölçüm şöyle yapılır:
     - Silmeden önce `full_run_vc_cautious`'a geçici bir bot kolu eklenir. Bu kol her Series A görüşmesinden önce
       hazırlığı başlatır.
     - 10 tohumda Series A imza oranı bu kolla ve hazırlıksız kolla karşılaştırılır.
     - Odaklanan sorunun geçme ihtimali `PREP_BONUS`'la ve onsuz hesaplanıp rapora konur.
     - Geçici kol B9'da silinir.
9. **Kapılar.**
   - Şunlar temiz geçer:
     - `--event-lint`,
     - `loc_residue`,
     - `--why-fire` (her yeni kart için),
     - `plausibility_run.sh` (`fails=0`),
     - `run_gate.sh` (üç koşu bir sonla biter, sıfır `ERROR`).
   - Ekonomi kayması raporlanır.
10. **Görsel kabul.**
    - Çekilecekler: her yeni kart, teşekkür maili, sürüm yorum satırı, gece kartı ve gelen kutusu saatleri.
    - TR ve EN çekilir; taşma olmaz.
    - Her teşekkür türü bir vakayla tetiklenir.
11. **A'nın hedefi bozulmaz.** A'nın bot kolları olaylar açıkken yeniden koşar.
    - **Botun acil durum kartındaki seçimi** (A §4.4):
      - Bot seçeneği etikete göre değil, fiile göre seçer.
      - `fix_none` "Sonraki sprinte bırak"ı seçer. Bu seçenek kilitliyse ilk açık seçeneği seçer.
      - Öbür kollar "Sprinti durdur, şimdi düzelt"i seçer.
    - **İkinci koşu:** Her kol bir de "Sprinti durdur" hiç seçilmeden koşulur. İki sonuç yan yana raporlanır.
    - **Beklenen:**
      - Düzeltme payı ve hata sprinti oranı A'nın onaylı hedeflerinde kalır.
      - Kalmazsa sayılar Erdem'e gider.
12. **Her olay türü gerçekten gelir.**
    - Rapor, her olay türünün ve her kâğıt rolünün 104 haftada kaç kez geldiğini A'nın `fix_worst` kolunda ayrıca verir.
    - Hiç gelmeyen tür ⚠️ olur.

## 5. Araştırma (uygulayıcı yapar)
- **SLA kredisi:** %10–25 arasındaki kademelerin kesinti süresine dağılımı. Bulgular `B_ARASTIRMA.md`'de.
- **00:00 maillerinin kökü:**
  - Karar 21'deki bütün üreticiler doğrulanır.
  - Yenileri aranır. Bunun için zaman yöneticisinin günlük dağıtımındaki her sistem (`time_manager.gd`) ve gelen kutusuna
    ya da bildirim yığınına yazan her yol taranır.
  - Mesai penceresine en az değişiklikle taşıma yolu bulunur: geliş saati, teslim kuyruğu ve kayıt.

## 6. Bağlantılar: kopukluk olmayacak
Kod yazılmadan önce bir **bağlantı haritası** çıkarılır ve Opus bu haritayı kodla doğrular.

**A'nın noktaları:**
- B, A'nın deposuna ve matrisine yalnız `RAPOR_A.md`'deki adlı okuma ve yazma noktalarından dokunur.
- Bunlardan biri yoksa B0 bunu Erdem'e ⚠️ olarak bildirir.
- B kendi hesap süzgecini ya da kendi hata sayacını yazmaz.

Haritada en az şunlar olmalı.

**Acil durum sistemi**
- A'nın hata deposu: açık hata, hat dökümü, hattı kullanan hesapların listesi, etkilenen hesap ve kullanıcı, hatalı
  sürüm, hatta hata ekleme, `line_blocked`, "hat temizlendi" sinyali.
- Sunucu kademesi:
  - C gelene kadar bugünkü sağlayıcı okunur.
  - Doluluk çarpanı bugün 1 döner.
  - Doluluk araştırması C'nin görevidir.
- Zaman yöneticisi: gece tutuşu, gün dönümü, otomatik kayıt, gece saatlerinde kuyruk kuralı.
- Kayıt ve `reset_all_owners`.
- Olay kapısı: ret durumu ve tempo kotasına sayılıp sayılmadığı.
- Sprint: acil kartın eklenmesi ya da başa taşınması, plan tahmini.
- Kart ataması ve Görevler matrisi: bedeli ödeyen kişiler.
- B2B güven izi (`trust_offset`).
- B2C kitlesi: tek seferlik düşüş ve kayıtlı haftalık düşüş.
- Finans: tek seferlik gider (`FinanceSystem.apply_one_time_cost`).
- Bot: A'nın kollarında acil durum kartı seçimi.

**Kâğıt motoru**
- Kart ataması: `assignees` ve `role_of`.
- PM kâğıdı: ekipteki ürün yöneticisi ve sprintteki istek kartı.
- Mandal ve tekrar sayacı.
- Kayıt.
- Kesinti sırası (Karar 12).
- "Testi kısalt"ın ara sabiti (Karar 14).
- Teslim saati kuralı (Karar 21).

**Söz olayı**
- `PromiseRegistry`.
- B2B satış ve memnuniyet.
- Sprint kartı.

**Sürüm anı ve teşekkür**
- Sürüm köprüsü.
- Acil durum kapanışı.
- `PromiseRegistry`.
- İstek verisi. C gelene kadar bugünkü `requests` okunur.
- Gelen kutusu.
- Teslim saati kuralı.

**Yatırımcı hazırlığının kalkması**
- VC görüşme sistemi.
- Kurucu meşguliyeti ve durumu.
- Series A sekmesi.
- `vc_meeting_adapter`.
- `MEETING_CHIP_PREP`'in satış kullanımı (dokunulmaz).
- Metinler, smoke, belgeler.

**Mail ve bildirim saatleri**
- Karar 21'deki bütün üreticiler ve §5'te bulunan yenileri.
- `MessageSystem` (saat alanı).
- `WorkHoursSystem.company_window()`.
- Olay geçmişi ve kâğıt kaydı.
- `mail_pane.gd` saat gösterimi.
- Gelen kutusu hatırlatıcıları ve bildirim yığını.
- Haber bandı.
- Kayıt şeması.

**Belgeler**
- `HARITA.md`.
- Motor md §27.
- `_vocabulary.md`.
- Sinyal manifesti.
- `GUNCELLEMELER.md`.
- CLAUDE.md §5 ve §6: gün sınırı ve teslim saati kuralı, kayıt şeması numarası.

## 7. Kapsam dışı
- Tek hata sayısı, hata dağılımı ve Görevler matrisi bağı (A).
- Sunucu kademeleri ve doluluk kararı (C).
- Testçinin hata ihtimali ve rol puanı (D).
- Pazaryeri ekonomisi, sepet kuponu ve pazaryerine özel metinler (E).
- Sürüm duyurusu ve pazarlama.
- Kurucunun müşteri görüşmesi.
- Öneri çipi ve retro.

## 8. Çalışma biçimi ve adım tablosu
**Kurallar** (A ile aynı):
- Tek klasörde çalışılır, commit doğrudan `main`'e atılır. Worktree açılmaz.
- Push yalnız Erdem'in sözüyle yapılır, öncesinde tam smoke koşulmaz.
- Commit mesajı `Faz B Bn: ...` ile başlar.
- **Her commit şu sırayla ilerler:**
  1. Sonnet kodlar.
  2. Haiku kapıları koşar ve ekranı çeker; kareleri CLAUDE.md §11 listesine göre raporlar.
  3. Opus kıdemli inceleme yapar: diff'i ve kareleri görür, düzeltme hakkı vardır.
  4. En çok bir düzeltme turu yapılır.
  5. Commit atılır.
- **Yazım dalgaları:** Opus yazar. Dalgalar Erdem'e toplu gider, onaydan sonra bağlanır.
- **Kayıt şeması:**
  - A 16 alır, B 17 alır (gelen kutusu saatleri). Sonraki numaraları fazlar kod yazdıkları sırayla alır.
  - Yatırımcı hazırlığının kayıttan kalkması sürüm numarasına bağlanmaz. Yükleyici `prep` ve `pitch_prep_active`
    anahtarlarını her yüklemede düşürür. Bu, B1'in göçüyle B9 arasında yazılan kayıtları da kapsar.

| Adım | Ne | Kim | Model | Düşünme | Süre | A sürerken? | Neden |
|---|---|---|---|---|---|---|---|
| W1 | Yazım dalgası 1: 5 olay, gece kartı, bütün seçenekler ("Sprinti durdur" dahil), ay sonu maili saati → Erdem'e | Alt ajan | Opus | yüksek | 50 dk | evet | Yazım kalitesi |
| W2 | Yazım dalgası 2: 40 kâğıt kısa biçimde → Erdem'e | Alt ajan | Opus | yüksek | 1 sa 30 dk | evet | Yazım |
| W3 | Yazım dalgası 3: söz olayı, teşekkür mailleri, genel B2C sürüm yorumları → Erdem'e | Alt ajan | Opus | yüksek | 45 dk | evet | Yazım |
| B0t | §5 araştırması ve bağlantı haritasının taslağı (salt okuma) | Alt ajan | Sonnet | yüksek | 50 dk | evet | A bitince tazelenir |
| B0 | Haritanın A'nın gerçek adlarıyla tazelenmesi; hat başına eşiklerin A'nın dağılımıyla yeniden seçimi | Alt ajan | Sonnet | yüksek | 30 dk | hayır | A'nın kodu değişti |
| B0v | Haritanın doğrulanması | Alt ajan | Opus | yüksek | 15 dk | hayır | Kopukluk kod yazılmadan yakalanır |
| B1 | Mail ve bildirim saatleri: geliş saati, mesai penceresi, teslim kuyruğu, hatırlatıcılar, şema 17, `mail_pane` | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | **max** / düşük / yüksek | 3 sa 30 dk | hayır | Çok üretici, kayıt ve arayüz |
| B2 | Motor fiilleri: bedelin olaydan türemesi, kalıcı güven izi, kişiye moral | aynı | aynı | xhigh / düşük / yüksek | 1 sa 35 dk | hayır | Motor dokunuşu |
| B3 | Acil durum sistemi, gece tutuşu, gece kuyruk kuralı, kesinti kartları | aynı | aynı | **max** / düşük / yüksek | 4 sa | hayır | Yeni sistem, kayıt, saat |
| B4 | Kalan acil durum kartları; botun acil durum seçimi; A'nın hedefinin yeniden ölçümü (§4.11, §4.12) | aynı | aynı | xhigh / düşük / yüksek | 3 sa | hayır | Ekonomi ölçümü |
| B5 | Kâğıt motoru: en çok bir, boş sprintler, kesinti sırası, 52 hafta ve en çok 3 kuralı, konuşan kişi, PM istisnası, probun pazar ve olay parametreleri | aynı | aynı | xhigh / düşük / yüksek | 3 sa | hayır | Seçim ve ölçüm |
| B6 | Kâğıt içeriğinin bağlanması (iki dilim) | aynı | aynı | xhigh / düşük / yüksek | 3 sa | hayır | Kart verisi |
| B7 | B2B söz olayı ve "Testi kısalt"ın ara sabiti | aynı | aynı | xhigh / düşük / yüksek | 2 sa | hayır | |
| B8 | Sürüm anı: üç tetikleyicili teşekkür, B2C yorum satırı | aynı | aynı | xhigh / düşük / yüksek | 2 sa 15 dk | hayır | Arayüz ve seçim |
| B9 | Yatırımcı hazırlığının kalkması; önce geçici bot koluyla ölçüm | aynı | aynı | xhigh / düşük / yüksek | 2 sa | hayır | Geniş silme, tuzak var |
| R | Sonuç raporu: ✅ / ⚠️ / ❌, onay bekleyen sabitler ve metinler, commit listesi | Ana | Opus (ana) | orta | 15 dk | hayır | Rapor kuralı |

**Süre:** Toplam yaklaşık 26 saat. Bunun yaklaşık 4 saati (W1–W3, B0t) A sürerken yapılabilir. Erdem'in onay bekleme
süresi buna dahil değildir.

## 9. Faz A ile aynı ağaç
**Neden bekliyorsun?**
- Tek klasör kuralı vardır; worktree açılmaz.
- İki ajan aynı anda kod yazıp kapı koşarsa biri öbürünün yarım dosyasını test eder.
- Kayıt şeması numarası çakışır.
- B'nin acil durum sistemi, kâğıt motoru ve bedeli ödeyen kişi kuralı A'nın hata deposuna ve Görevler matrisi bağına
  dayanır.

**A sürerken yapabileceklerin:**
- adım tablosu ve Erdem'in onayı,
- W1, W2, W3 yazım dalgaları (Erdem'e gider),
- §5 araştırması,
- bağlantı haritasının taslağı (B0t, salt okuma).

Bu sırada oyun dosyalarına, `localization/strings.csv`'ye ve `data/`'ya yazmazsın. Taslaklar
`docs/tasks/faz_ab/b_taslak/` altında durur.

**Bunlar bitince durursun.** Erdem'e "W1–W3 ve harita taslağı hazır, A'yı bekliyorum" dersin. A bitince Erdem seni
yeniden başlatır.

**Koda başlama koşulu:**
- `docs/tasks/faz_ab/RAPOR_A.md` vardır.
- İçindeki commit listesinin son commit'i `git log`'da görünür.
- Raporda ❌ varsa önce Erdem'e sorarsın.

**Her zaman:**
- Commit'e yalnız kendi değişikliklerini koyarsın. Ağaçta sana ait olmayan değişikliğe dokunmazsın.
- `git checkout -- <yol>` yasaktır.
- `docs/tasks/faz_ab/` klasörü ve rapor dosyaları commit'lenmez (CLAUDE.md §8).
- R raporu `docs/tasks/faz_ab/RAPOR_B.md`'ye yazılır.
