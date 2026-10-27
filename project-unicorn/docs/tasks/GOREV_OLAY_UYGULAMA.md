# Görev: Revize olayların oyuna girişi

2026-10-26 · Yazan: yardımcı yönetmen (oturum `co-director`) · Erdem bu görevi yeni bir oturumda başlatır. Aynı anda iki oturum
daha çalışır: Temizlik (`GOREV_TEMIZLIK.md`, oturum `project-unicorn-1c`) ve Ürün arayüzü (`GOREV_URUN_ARAYUZU_DEVAM.md`).
**Ortak çalışmanın kuralları `docs/tasks/ORTAK_CALISMA.md`'dedir: işe başlamadan oku.** Senin etiketin OLAYLAR. Bu yazı bir
Opus incelemesinin bulgularıyla düzeltildi.

## Amaç

Erdem'in iki tur yorumuyla olgunlaşan olaylar oyuna girer. İki hedef var:
- Oyuncunun ekip, müşteri ve ürün kararları, ona "tabii ya" dedirten, insan ağzından gelen sürprizlerle karşılık bulur.
- Her şık gerçek bir seçime zorlar: oyuncu ne kaybettiğini ve ne kazandığını okur, hiçbir şık bedava değildir, risk anlamlıdır
  ama oyunu cezalandırmaz. Erdem: "Değiştiriciler yetmiyor ya da çok fazla, çok düşük; seçime zorlamıyor. Bokunu çıkarmayın."

## Girdi

**Olaylar:** `C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\5ad1dc82-4870-4507-b82a-591327527a0f\scratchpad\revize.json`
- 38 kayıt. Alanlar: `id, durum, kategori, ton, an, gonderen(_en), konu(_en), metin(_en), secenekler[{etiket(_en),
  sonuc(_en)}], degisen, kosul_notu, kod_notu, ilham`.
- Erdem'in okuduğu sayfa: https://claude.ai/artifact/1oVCzm1aDw9okhGFVrFHsG.
- **Numaralar ilk turun 32'lik sırasıdır, revize.json dizini değildir.** #7 revize.json'da üç kayıttır. Kayıtlar numarayla
  değil id ile seçilir. Eşleme:

| Sayfa no | Dizin | id |
|---|---|---|
| #8 | 10 | `ekip.kod_inceleme` |
| #9 | 11 | `ekip.soz_verdi` |
| #15 | 17 | `urun.eski_tarayici` |
| #19 | 21 | `rakip.ayni_ozellik` |
| #21 | 23 | `rakip.panel` |
| #23 | 25 | `dunya.disk` |
| #25 | 27 | `dunya.veri_nerede` |
| #26 | 28 | `dunya.ceyrek_bulteni` |
| #30 | 32 | `odul.final` |
| #32 | 34 | `kriz.ameliyat` |
| P1–P4 | 35–38 | dört pazaryeri olayı |

**Erdem'in 2026-10-26 yorumu:** `docs/tasks/faz_cde/ERDEM_KARARLAR_2026-10-20.md`, "Olay revizyonu: implementasyona
geçilebilir" tablosu. Bağlayıcıdır.

**Yazım kuralları:** `docs/tasks/GOREV_OLAY_REVIZYON.md` "Yazım kuralları" 1–9 ve oradaki ilk turun karar tablosu.

**Motor ve içerik:**
- CLAUDE.md §5 (kart kuralları, EFFECT-VISIBILITY RULE) ve §6 (olay motoru, WRITE-THROUGH LAW, karar kâğıdı, kesinti sırası).
- Motor GDD `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md` (§3.1, §8, §9, §17.13–17.15) ve ch11.
- Fiil listesi `docs/content/events_draft/_vocabulary.md`.
- Kod haritası `docs/kod_haritasi/sistemler/07_olay_motoru.md`.

**Hafıza:** `feedback-event-option-quality`, `feedback-incident-and-card-writing`, `card-text-token-rules`,
`unresolvable-card-token-class`, `satisfaction-delta-drift`, `vocab-verbs-without-executor`, `strings-csv-surgery`.

## Kapsam

**Bağlanacak 23 kart** (#7 üç varyant):
- Çalışan: #1 `calisan.bilgisayar`, #3 `calisan.dugun`, #5 `calisan.yuksek_lisans`, #6 `calisan.kaba_musteri`.
- Ekip: #7 `ekip.ayni_izin.{pm,gelistirici,testci}`, #8 `ekip.kod_inceleme`, #9 `ekip.soz_verdi`.
- Müşteri: #10 `musteri.egitim`, #11 `musteri.kendi_hatasi`, #12 `musteri.muhasebeci`.
- Ürün ve rakip: #15 `urun.eski_tarayici`, #18 `rakip.kesinti`, #19 `rakip.ayni_ozellik`, #21 `rakip.panel`.
- Dünya: #23 `dunya.disk`, #24 `dunya.bulut`, #25 `dunya.veri_nerede`, #26 `dunya.ceyrek_bulteni` (B2B sayısı).
- Ödül ve kriz: #30 `odul.final`, #31 `kriz.acik`, #32 `kriz.ameliyat`.

**Ek kartlar** (şıklardan doğar; 5–7. adımların kapılarından aynı biçimde geçer):
- #25'in ortaya çıkış kartı (karar 6);
- #31'in 4–8 hafta sonraki basın kartı;
- #31'in B2B ikizi (kitle yerine bütün hesapların memnuniyeti);
- #5'in dört hafta sonraki ayrılış kartı.

**Park edilecek 6 kart** (B2C pazaryeri Faz E'de kurulacak): #22 `dunya.halka_arz`, #27 `dunya.okur_anketi`, #28 `basin.kayit`,
P1 `pazaryeri.yanlis_fiyat`, P2 `pazaryeri.fare`, P3 `pazaryeri.rekor_ay`.
- Erdem'in yorumlarıyla revize edilir. `data/events/cards/unwired/` altına konur; orası yüklenmez.
- Metin `strings.csv`'ye girmez: TR ve EN metin `_draft` alanında, `[COND?]` ve `[VOCAB?]` işaretleri `_draft.kod_notu`'nda
  durur.
- Bugünkü B2C ürünlerine (not, video) uyarlanmaz.

**Silinen:** P4 `pazaryeri.cift_siparis` ve revize.json'da `sil` ya da `veto` olanlar.

**Yapma:**
- Yeni oyun mekaniği icat etme. Mağaza memnuniyeti ve pazaryeri komisyonu yok; onlara dayanan şık parka gider.
- Bugünkü kartlara ve arklara dokunma.
- Frank satırı yazma.
- Ürün arayüzü oturumunun dosyalarının gövdesini değiştirme (ORTAK_CALISMA §2).

## Hazır sanılan ama hazır olmayan fiiller

revize.json'un `kod_notu`'larında "hazır" denen bazı fiiller bir olay kartından kullanılamıyor:

| Fiil | Durum |
|---|---|
| `sprint_card_*` | Yalnız `SprintSystem.decision_card()` ya da `promise_card()` üzerine iner; lint V3 onu yalnız `tick: request` kartında kabul eder. |
| `promise_extend`, `promise_break` | `SYSTEM_VERBS`'tedir (V2) ve yalnız söz olayının sözlerine iner. |
| `set_timed_flag` | `WRITER_VERBS` dışındadır (V1). |
| `send_on_leave` | Oyuncunun gönderdiği izindir: o yılın yaz iznini yer, haber şeridine "tatile çıktı" yazar, dönüşte moral verir, 8 haftalık beklemede reddedilir. |
| `b2b_month_discount` | Tek aylık kasa çıkışıdır, MRR'a dokunmaz. |
| `assign_to`, `add_customer`, `change_salary` | Kolsuzdur (ACIK_KARARLAR 14, karar 15). |

Kullanılabilenler: `productivity_mod`, `trust_delta`, `promise_create`, `add_prospect`, `sprint_fix_first` (hat üzerinden),
`damage_product`, `change_morale`, `add_brand`, `add_cash`.

## Yardımcı yönetmenin kararları

1. **#23, sunucu zammı.** Olaydaki "sağlayıcı" bir firmadır. Oyundaki kademelerin (Ekonomik, Standart, Kurumsal) üstünde bir
   fiyat çarpanı olarak durur.
   - `ProductState`'e `infra_price_mult` bayrağı eklenir (varsayılan 1,0); `InfraSystem.unit_price` bununla çarpar.
   - Şıklar:
     - zammı kabul: ×1,15;
     - ucuz firmaya geç: ×0,90; kademe değişmez, bedeli Kerem'in sprintidir;
     - yıllık sözleşme: ×1,07 ve 52 hafta kilit.
   - Kilit sürerken `set_provider` kademe değiştirmez (Kurumsal dahil); kapasite imza anındaki birimin altına inmez. Kilit ve
     taban `ProductState` bayrağında durur, kayıt sürümü artmaz.
   - "Hep yıllık imzalarım" diye bir yol yok: yıllık sözleşme yalnız bu olayda, koşuda bir kez sunulur. Kurumsal'a geçemeyen
     B2B oyuncusu sunucu maddeli hesabı riske atar; küçülmek isteyen B2C oyuncusu fazla kapasite öder.
   - #24: Standart ve Kurumsal birim fiyatı ×0,70.
   - **İş bölümü:**
     - Kilidi motorda bu görev yazar. `set_provider` ve kapasite azaltma tabanın altını reddeder. Gerekçeyi okuyan public
       `InfraSystem.lock_reason()` ve yeni CSV anahtarı da bu görevdendir.
     - Seam Ürün arayüzüne tek mesajla verilir. Ürün arayüzü sunucu düğmesini `product_model.gd`'de kilitli, ipucunda
       gerekçeli çizer, sıradaki U commit'inde.
     - `mail_pane.gd`'nin sunucu maddesi düğmesine kilidi bu görev ekler: Temizlik'in B3'ü commit'lendikten sonra, Temizlik'e
       haber vererek, küçük hunk'la.
     - `run_probe` botu kilitliyken Kurumsal'a geçmeyi denemez.
2. **#27 (park).** Okur indirimi kasadan değil, o ayın gelirinden düşer: platformun karşıladığı indirim kodu satış gelirini
   azaltır, nakit gideri değildir. Taslağın `kod_notu`'na girer.
3. **#30 MVP dönemine alınır.**
   - Koşul: ilk sürüm (v1.0) çıkmış ve şirket Bootstrap evresinde; koşuda en çok bir kez.
   - Marka ve kitle eşiği düşer.
   - Ödül $10.000 [WORKING] kalır: o dönemde yaklaşık bir aylık giderdir.
4. **#7, aynı izin.** Yaz izni oyuncuya sorulmadan başlar. Herkesin bir izin haftası vardır: `leave_week = 5 × işe giriş sırası
   mod 13` (`HRConstants.leave_week_for`).
   - (a) **Çakışma:** aynı roldeki iki kişinin bu yılki iki haftalık izin blokları en az bir hafta örtüşür (`leave_week`
     farkı ≤1). Bunun için yeni seam ve iki çalışan yuvası yazılır.
   - (b) **Zamanlama:** kart, önce başlayan iznin haftasından 2–4 hafta [WORKING] önce gelir.
   - (c) **Metin** ay adı yazmaz, "aynı haftalara" der (TR/EN onay bekliyor).
   - (d) **"Kendi aralarında karar versinler" şıkkı.** Her varyantta bir kişinin iznini kaydıran şıkkın yerine gelir:
     - geç başlayanın izni yalnız bu yıl, örtüşmeyecek kadar kayar (yeni HR seam'i);
     - ikisinin de morali biraz düşer.
     Böylece bu şık, ikisinin birden iki hafta yok olduğu şıktan ayrışır. Geliştirici varyantındaki "ertele" şıkkı çıkar,
     yerine 2. adımda bedelli bir şık yazılır.
   - (e) **Yıl zarı:** yeni seam'le kurulur: `EvDice.unit("year", yıl, kart id, "") < 0,5` [WORKING]; latch cooldown 52 hafta.
     Kart her yıl gelmez.
   - (f) **"İkisi de gitsin, sürüm kaysın":** kayma izinlerin doğal sonucudur, ayrı fiil yazılmaz. Çip yalnız uygulananı
     yazar (iki izin, moral); kayma planda görünür.
5. **#26, çeyrek bülteni.**
   - Etki çipi kalır (EFFECT-VISIBILITY RULE); Türkçesi yeniden yazılır.
   - Erdem'in örneği oyuncunun ağzındadır: "Bu çeyrek satış görüşmelerinde kurulum desteğine ağırlık veririm". Tek şıkkın
     etiketi bu olabilir, çip etkiyi yazar.
   - Süreli etki için `set_timed_flag` `WRITER_VERBS`'e alınır ya da yeni bir yazar fiili yazılır; seçim raporda.
6. **#25'in 3. şıkkı yalan olur:** "Verileriniz Türkiye'de ayrı bir sunucuya alınıyor".
   - Şimdi: hesabın memnuniyeti çok artar.
   - %25 [WORKING] ihtimalle birkaç hafta içinde ortaya çıkar (ortaya çıkış kartı) ve hesap fesih bildirir.
   - Bugünkü bildirim yalnız sunucu maddesinin yoludur. Bu yüzden `B2BSalesSystem`'e maddeden bağımsız bir bildirim seam'i
     yazılır:
     - `notice_end_day` = bugün + 4 hafta [WORKING];
     - kendi sebebi ve mail anahtarları vardır;
     - `meet_clauses` onu geri aldırmaz;
     - süre bitince `_remove_lost`.
   - #6'nın kumarı ("yenilemez" yerine "fesih bildirir") aynı seam'den iner.
7. **#19, Ardenna'nın toplu faturası.**
   - Erken deneme anında üç hesaba `trust_delta +A` (kalıcı iz `trust_offset` ile).
   - Kartın testi bitince (`EventBus.card_phase_changed`) bulunan hata 1 ya da daha fazlaysa aynı üç hesaba `−B`.
   - 3. şık: "Testi kısalt, kart bu sprintin sürümüne girsin". Sürüm yalnız sprint kapanışında çıkar.
   - A ve B 2. adımda belirlenir.
8. **#21, Pythia bizden söz etmiş.**
   - 2. şık: "İlk yıl indirimli fiyat ver".
   - Bunun için süreli MRR indirimi yeni bir seam'le yazılır: hesapta bitiş tiki, `CustomerRegistry` seam'i;
     `b2b_month_discount` değil.
   - Hesabın MRR'ı 52 hafta %X eksik; X 2. adımda.
9. **Oyunda karşılığı olmayan koşul** (#25'in "dinleme haberleri", #31'in "dönemin şifreleme açığı" gibi):
   - Olayın anlamını koruyan en yakın mevcut durum seçilir: haber şeridinin bugünkü bir satırı, sektör ya da tarih penceresi.
   - Seçim raporda yazılır. Böyle bir durum yoksa kart parka gider.
10. **Fiil yerine hamleyi değiştirme.**
    - Şıkkın anlattığını yapan fiil yoksa önce mevcut fiillerle aynı anlamı veren kurgu aranır.
    - Anlam değişiyorsa yeni fiil yazılır. Yeni fiil tek karta özel olmaz, başka kartların da kullanabileceği genellikte
      yazılır, sahibi sistemin seam'ini çağırır.
11. **Sprint kartına bağlı olaylar sprint kâğıdı olarak kurulur.** Bunlar #8, #19 ve #32.
    - Biçim: `data/events/cards/product/sprint_*.json`, `tick: request`, `speaker_role`, `stage` ve `pool_group` alanlarıyla.
    - `data/product/sprint.json`'un `decision.cards` havuzuna eklenir. Eklemeden önce Ürün arayüzü oturumuna haber verilir.
    - Böylece `sprint_card_*` fiilleri ve kâğıdın "kart bekler, kimse atanmaz" kuralı hazır gelir.
    - Kâğıda oturmayan bir hamle `sprint_system.gd`'de var olan bir gövdeyi değiştirmeyi gerektirirse (ör. `_assign`'ın karta
      kilitli kişiyi okuması) değişikliği Ürün arayüzü yazar. Olmazsa şık karar 10'a göre yeniden kurulur.
    - Erdem kâğıtların sprintlerin %7–10'unda gelmesini kabul etti; havuz büyüyünce her kâğıdın sıklığı düşer, raporda yazılır.
12. **Kategori ve id.** Kartın id öneki ve klasörü motor kategorisidir (`EvTuning.CATEGORY_QUOTA_WEEK`).

    | revize.json öneki | Klasör |
    |---|---|
    | `calisan.*`, `ekip.*`, `kriz.ameliyat` (kâğıt olmayan yanı) | `team/` |
    | `musteri.*`, `urun.eski_tarayici` | `customer/` |
    | `rakip.*` | `rival/` |
    | `dunya.*`, `odul.final` | `world/` |
    | `kriz.acik` | `product/` |

    Ad İngilizce, küçük harf ve alt çizgiyle yazılır (ör. `team.work_laptop`). revize.json id'siyle eşlemesi raporda tablo
    olarak verilir.
13. **#9, verilen söz.** Satış temsilcisinin imzası oyunda söz yaratmaz; sözü yalnız kurucunun masası yaratır.
    - Koşul: "hesabın açık sözü varken".
    - Metin: söz kurucunun masasından geldiği için gönderen satırı ve metin "verdiğimiz söz" der (TR/EN onay bekliyor).
    - 2. şık Erdem'in yorumuyla "Müşteriyi ara, ek süre iste" olur.
14. **#32, Mert hastanede.** Hastalık yokluğu `send_on_leave` değildir:
    - yaz iznini yemez;
    - tatil satırı ve dönüş morali yoktur.
    Yeni HR seam'i yazılır.
15. **ACIK_KARARLAR 14, Erdem'in cevabı (2026-10-26):**
    - **Kişiyi bir karta kilitlemek: bağlanır.** `assign_to` kol alır ve çipi olur. Kişiyi karta kilitleyen `_assign`
      değişikliğini Ürün arayüzü yazar (karar 11). Kullanan şıklar: #9 "yalnız buna baksın", #32 "başkası devralsın".
    - **Terfi ve maaş artışı: bağlanır.** `HRActions.apply_promotion` ve `apply_raise` kapılarıyla bağlanır, çipi olur
      (#5).
    - **Adayı olaydan imzalatmak: hayır. Olay imzalatmaz, teklif verir.**
      - Adaya bir teklif koşulu yazılır: indirim yüzdesi ve süresi, ya da söz.
      - Aday satış akışının kendi yolunda imzalarsa (kurucunun görüşmesi ya da temsilcinin kapanışı) sözleşme o koşulla
        açılır: indirimli MRR ya da söz kaydı. İmzalamazsa teklif düşer.
      - Teklif imza şansını değiştirecekse bu, akışın var olan kapanış zarının bir girdisi olur [WORKING]; ayrı kumar yok.
      - Seam satış sisteminde yazılır (WRITE-THROUGH LAW): adaya teklif koyan bir işlev ve `SalesFinalizer.sign_deal`'in
        teklifi okuması. Süreli indirim karar 8'in seam'ini kullanır.
      - Kullanan şıklar: #15 "Desteğe söz ver" (teklif: söz koşulu), #21 "İlk yıl indirimli fiyat ver" (teklif: 52 hafta
        %X).
      - Şık etiketi kesin imza vaat etmez; "imzayı şimdi al" gibi ifade çıkar (TR/EN onay bekliyor).
    - `add_customer`, `start_training`, `fire_employee`, `convert_audience` ve `open_paid_tier`'e dokunulmaz. ACIK 14'ün bu
      kısmı açık kalır.
16. **Hiçbir çalışan, müşteri ya da aday adı karta yazılmaz** (Erdem, 2026-10-26: "çalışan ve müşteri adları hard kodlu
    olmamalı, sistemden çekilmeli").
    - revize.json'daki adlar yalnız örnektir: Mert, Ece, Selin, Kaan, Bilge, Anadolu Market, Aras Klinik, Bosphorus Sağlık,
      Pınar Çetin ve öbürleri.
    - **Her kişi ve şirket bir `scope` yuvasıdır** (tür `employee`, `customer`, `prospect`, `founder`) ve motorun
      seçicisiyle dolar. Seçici iki türlüdür:
      - uygun olanlar arasından rastgele;
      - duruma bağlı: memnuniyeti en düşük hesap, en büyük hesap, en yeni çalışan, kartın geliştiricisi.
    - **Metin adı yuvadan okur** (`{slot}`; hafızada `card-text-token-rules`).
    - Gereken seçici yoksa yazılır. Bugün "rastgele" yok, var olanlar: `largest`, `smallest`, `newest_hire`, `most_senior`,
      `lowest_morale`, `sprint_dev`, `line_top`. Rastgele seçici tohumludur (`EvDice`): aynı tohum aynı kişiyi seçer.
    - **Rakip adları** da sistemden gelir: Ardenna, Pythia ve Sumpter `RivalRegistry`'den okunur. Koşul "pazarda şu türden
      bir rakip varken" olur, ad rakip yuvasından gelir. Rakip yuva türü yoksa yazılır.
    - **Hesaptaki muhatap** (ör. bilgi işlem müdürü), sistemde muhatap adı yoksa adla değil unvanla yazılır.
    - Basın ve yayın adları (Girişim Bülteni, TeknoGündem) kurgusal sabit olarak kalabilir.
    - **Görsel kabulde her kart iki farklı tohumla çekilir; iki karede adlar değişmeli.** Gerekirse koşul ya da seçici
      değişir ki kart iki dünyada da gelsin.

## Adım tablosu

| # | Ne | Kim / model (düşünme) | Süre |
|---|---|---|---|
| 1 | **Yazı turu.** Erdem'in yorumlarını ve kararları uygula: #7, #8, #9, #15, #19 (sonuç satırı), #21, #23 (şıklar ve `kosul_notu`), #25, #26, #30 (`an` ve `kosul_notu`), P2 (kategori şıkkı o özellik varken ya da yapılırken görünmez; `kosul_notu`'na), P3, #27 (`kod_notu`). #8 ile P3 baştan yazılır. Çıktı `revize2.json`: bu oturumun scratchpad'inde, değişen her kayıtta `degisen_2`; yolu yardımcı yönetmene mesajla. TR ve EN birlikte, kurallar 1–9. | Sonnet (high) | 2 sa |
| 2 | **Değiştirici turu.** 23 kartın ve ek kartların her şıkkı için kazanç, bedel ve risk tablosu (aşağıdaki kurallar). Tablo scratchpad'de. | Opus (high) | 2 sa |
| 3 | **Fiil ve seam envanteri.** Her `[VOCAB?]`, "kod işi" ve "seam yok" için seçim: mevcut fiil, kurgu değişikliği ya da yeni fiil (karar 10). Yukarıdaki "hazır olmayan" tablosuyla başla. Çıktı: yeni fiiller ve seam'ler, sahibi (WRITE-THROUGH LAW), kayıt etkisi (ORTAK_CALISMA §6), hangi oturumun dosyasına girdiği. | Opus (high) | 1,5 sa |
| 4 | **Kod.** Yeni fiiller ve seam'ler: bildirim, süreli MRR indirimi, fiyat çarpanı ve kilit, hastalık yokluğu, izin çakışması ve kayması, yıl zarı, olasılık seam'leri ve çipi, `amount_slot`. Ayrıca `EvChips.describe` etiketleri, `--event-vocab` ve lint. Gruplu commit'ler: sprint ve kâğıt, satış ve hesap, altyapı, kişi, olasılık. | Sonnet (xhigh) kodlar, Opus (high) inceler | 8–10 sa |
| 5 | **Kartlar.** JSON şema 3 (aşağıda), yuvalar, ateşleme koşulları, `version_scope` (demo kapsamı; aksi gerekçeli). Kartlar Erdem'in "kart tekrarı çok seyrek" kuralıyla tekrarlanmaz. Park kartları `unwired/`'a. | Sonnet (high) | 4 sa |
| 6 | **Kapılar.** Ayrıntı aşağıda. | Haiku (low) koşar, Sonnet okur | 2 sa |
| 7 | **Görsel kabul.** Her kart ve kâğıt `--event-shot` ile TR ve EN, uzun adlı yuvayla. Taşma, kesilme, tire, dil karışması yok. Olasılık çipi görünür. | Haiku kareler, Sonnet denetim | 1,5 sa |
| 8 | **Erdem'e sayfa.** Yalnız metni değişen kartların önce ve sonrası: yorumuna göre değişenler, #8 ile P3'ün yenisi, kararların değiştirdiği metinler. Değiştirici tablosu bilgi olarak altta, onay sorusu değil. Park listesi. Sayfayı yardımcı yönetmene ver. | Sonnet (high) | 0,5 sa |

**6. adımın kapıları:**
- `--event-lint`, `loc_residue`, `loc_csv_integrity`, `event_chip_coverage` ve dokunulan sistemlerin smoke'u.
- Her kart için `--why-fire=<id>`.
- `bash tools/plausibility_run.sh` (`fails=0`).
- **Kart başına geliş sayısı makullük defterinden okunur, harness'ten değil.** Harness motoru tek başına koşar ve kart başına
  sayı basmaz. Komut:
  `"$GODOT" --headless --path . -s res://scripts/events/tools/plausibility_main.gd -- --event-plausibility-probe=seeds=1-20:weeks=104:variant=both:preset=<full_run | full_run_staff25 | full_run_b2c>`.
  Her koşu kendi APPDATA'sıyla koşar. `PLAUS FIRE id=<kart>` satırları sayılır. Kartın dünyasına uyan preset raporda yazılır.
- `--event-harness=random:seeds=20:weeks=104` yalnız çökme, sarkan referans ve tempo içindir.

**Commit kuralları:**
- Toplam yaklaşık **23–26 saat**: teklif seam'i, rastgele ve rakip seçicisi dahil.
- Her kod commit'inin diff'i bir Opus (high) ajanınca incelenir: en çok 1 inceleme ve 1 düzeltme. Yalnız JSON ve metin
  taşıyan commit ayrı incelenmez.
- Metni Erdem'in onayladığı metinden farklı olan kart, commit mesajında "TR/EN onay bekliyor" taşır ve yine bağlanır.
  Erdem'in "implementasyona geçilebilir" kararı bunu kapsar; değişiklik gelirse yalnız metin değişir.
- Commit öneki `Olaylar n:`. **Push yok.**

## Kart şeması (5. adım)

- Yeni kart şema 3'tür (`"schema": 3`; motor GDD §3.1 ve §17.13–17.15, `lint.gd` `_lint_v3`).
- Zorunlu alanlar:
  - `plausibility` (`phase_band`, `headcount`, `product`, `modules`, `min_week`);
  - `family`, `delay_weeks`;
  - çalışan yuvası varsa `family_subject` (`once` ya da ≥26 hafta);
  - kendi öznesini seçen yuvada `subject_tenure_weeks`.
- Tek kişilik kartta `sprint_hours` ve takım morali harcanmaz (O3).
- Dünya duyuruları #24 ve #26 tek şıklı ve bedelsizdir. O2 bulgusu gerekçesiyle `tools/lint_baseline.json`'a girer
  (`--event-lint=baseline`).

## Değiştirici kuralları (2. adım)

**Seçime zorla.**
- Her şıkkın okunur bir kazancı ve okunur bir bedeli vardır.
- Hiçbir şık başka bir şıktan her yönden iyi değildir. Tabloda her şık için "bu şık hangi oyuncu durumunda en iyisi" satırı
  yazılır.
- Bedelsiz şık yalnız açık bir "beat"tir (#1 gibi tek şıklı not, #24 ve #26 duyurusu).

**Bedel öznesine düşer** ve olayın ölçeğinden türer: çalışan → o kişi, hesap → o hesap, ürün → kart ya da hata, para → kasa.

**Tutarlar ölçeklenir.** Sabit dolar değil, olayın öznesinden okunur:
- hesabın MRR'ı, haftalık gider, ekip büyüklüğü ya da kartın eforu;
- yuvaya bağlı tutar için `amount_seam`'in yanına `amount_slot` yazılır: `EvEffects.amount(e, ctx)` slotun varlığı için
  entity seam'ini okur (`EvSeams.read_for`); çip, geçmiş satırı ve bot aynı `ctx`'le okur;
- küçük şirkette yıkıcı, büyük şirkette görünmez tutar yazılmaz.

**Abartma.**
- Tek şık kasayı en çok yaklaşık iki haftalık gider kadar oynatır. #30'un ödülü gibi açık istisna gerekçeyle yazılır.
- Marka ±1–3.
- Moral: "biraz" ±3–5, "çok" ±8–12 [WORKING]. Bugünkü kartlar −15 ile +10 arasındadır.
- Hesap kaybı yalnız kumar şıkkında ve yazılı ihtimalle olur.

**Kumar şıkkı** %10–30.
- İhtimal karta sayı olarak yazılmaz (motor §9.2, I7). Sabit ihtimaller `EvTuning`'de tek bir [WORKING] tablosunda durur ve
  adlı seam'lerle okunur (ör. `olay.odds_10`, `olay.odds_15`, `olay.odds_25`).
- Durumdan gelen ihtimal kendi seam'ini kullanır; ör. #30'da açık hatadan gelen takılma.
- `EvChips` check dalını şöyle çizer: "%15 ihtimalle:" ve ardından `on_fail` çipleri, tehlike renginde. Oran hep görünür;
  `on_pass` boşsa yazılmaz. Bu iş "olasılık" commit grubundadır ve 7. adımda görsel kabulle doğrulanır.

**Kalıcı iz.** Memnuniyet olay kartında tek tik sürer, sonra hedefine döner. Kalıcı etki `trust_offset` ile verilir (hafızada
`satisfaction-delta-drift`).

**Sayıların yeri.** Bütün sayılar [WORKING]'dir. Kartın JSON'unda ya da `EvTuning`'de durur. Tablo raporun ekidir; Erdem'e
onay için değil, bilgi olarak gider.

## Bitince

- Her commit'ten sonra yardımcı yönetmene tek satır: adım, sha, oyuncu ne görür.
- Yardımcı yönetmene, repoya konmayan bir rapor (scratchpad'de) ve 8. adımın sayfası. Raporda şunlar bulunur:
  - ✅ / ⚠️ / ❌ ve kanıt;
  - oturum adresleri;
  - bağlanan, park edilen ve ek kartlar, id eşleme tablosuyla;
  - yeni fiiller ve seam'ler;
  - kart başına `--why-fire` ve makullük defterinden geliş sayısı;
  - değiştirici tablosu;
  - koşulu değişen olaylar (karar 9);
  - "TR/EN onay bekliyor" kartları;
  - kâğıt havuzunun yeni sıklıkları.


## Devir (2026-10-27)

Bu makine bir haftalığına kapanıyor; iş dizüstünde yeni bir oturumla sürer. Bu not ve görevin yukarısı yeni oturuma
yeter. Push yok: push'u Erdem ya da yardımcı yönetmen yapar.

### Son commit

`8fbb189` **Olaylar 7b** (main). Olaylar zinciri: 1 `20636e7`, 2 `8926bc8`, 3 `80c6033`, 4 `3cc582c`, 4b `7b98763`,
5 `7e0dbb9`, 6 `f7a878c`, 7 `07364a5`, 7b `8fbb189`. Aradaki öbür commit'ler Ürün arayüzü (c7) ve Temizlik (1c)
oturumlarının.

### Biten adımlar

- Adım 1–6: ✅ (yazım turu, değiştirici tablosu, fiil/seam envanteri, beş kod grubu, kart JSON'u, kapılar ve ölçüm).
- Adım 7: ✅. Görsel kabul `07364a5`'te; bulunan iki çip kusuru ve memnuniyet çipinin anlamı 7b'de düzeldi:
  - tek şıklı kutuda çiplerin üstünde ve altında boşluk;
  - aynı çipler birleşir (sayılı anahtar varsa toplam, yoksa "×n");
  - hedefi boş çip çizilmez;
  - memnuniyet ve acil olay çipi kartın kendi payını okur ("-8 · Nordica 72 → 64").
- Adım 8: ✅, sayfa https://claude.ai/artifact/LaMBoCBjGfiyEht9w5sA9j (özel; Erdem'e paylaşımı sayfanın Paylaş menüsünden). Kalan iş yok; Erdem'in okuması ve açık kararlar bekliyor.

### Adım 8 (Erdem'in sayfası): yayınlandı

Klasör: `docs/tasks/olaylar_adim8/` (git'te yok sayılır, `docs/tasks/` ile elle taşınır). İçinde:
- `page/`: kurucu betikler `build_data.py`, `build_extra.py`, `build_page.py` (yollar klasöre göreli; proje kökü
  `OLAY_PROJ` ile değişir), girdileri `map.json`, `notes.json`, `extra.json`, son kurulmuş `data.json`, `index.html` ve
  `img/` (WebP).
- `kareler/<kart>/{A,B}_{tr,en}.{png,log}`: 7. adımın 108 karesi; üstüne 7b'den sonra yeniden çekilenler yazıldı.
- `kareler_7b/`: 7b kanıt kareleri (önce/sonra, hesapsız basın kartı, değişmeyen tek şıklı kart).
- `revize.json` (Erdem'in okuduğu "önce"), `cards/revize3.json` (son metinler), `RAPOR_OLAYLAR.md` (görevin "Bitince"
  raporu, tam), `cip_taramasi_*.txt` (7b çip taraması önce/sonra farkı).

**Durum (2026-10-27 16:30): yayınlandı.** https://claude.ai/artifact/LaMBoCBjGfiyEht9w5sA9j
- 35 kart satırı (22 metni değişen, 5 yeni, 1 değişmeyen, 7 park/silinen), 108 kare (iki basın kartı yuvasız, tek kare).
- 7b'de çipi değişen 11 kartın kareleri 7b'den sonra yeniden çekildi (`kareler_7b_sonrasi_yeniden_cekilen.txt`); öbürleri 7. adımın kareleri, çipleri değişmedi (çip taraması).
- Kareler panelin sağ kenarına göre kırpılır (uzun adlı EN karede panel 1100 px'i bulur).
- Yayından önce: JS derlemesi, başsız Chrome'da yatay taşma yok, 375 px iframe'de telefon genişliği.

Sayfanın sözleşmesi (görev adım 8 ve yardımcı yönetmenin 2026-10-27 kararları):
- yalnız metni değişen kartlar önce/sonra;
- en altta değiştirici tablosu (bilgi);
- park listesi;
- her kart çiftinin altında hangi yuvanın hangi varlığa iğnelendiğini yazan tek satır.
Yayın: Artifact (quickstart `intent: "other"`, `index.html` + `img/*.webp` `files` ile, ikon "document"). Bağlantı
yardımcı yönetmene gider. Yayından önce:
- `new Function` ile JS derlemesi;
- başsız Chrome render;
- 375 px iframe içinde telefon genişliği.

### Açık kararlar

- **Erdem:**
  - ACIK 14'ün kalan kısmı: `add_customer`, `start_training`, `fire_employee`, `convert_audience`, `open_paid_tier`'e
    dokunulmadı (karar 15).
  - TR/EN onay bekleyenler: 24 kart metni, 39 anahtar ve Olaylar 7'nin `rep_visits` etiketi (liste `RAPOR_OLAYLAR.md`
    §10). 7b'de yeni metin yok.
  - Sayfadaki üç açık nokta: #7'nin iki şıkkı, #32 hastalık izni.
- **Yardımcı yönetmen:** açık kararı yok (2026-10-27'de ikisi kararlaştı, aşağıda).
- Gizli kenar (bugün hiçbir kart tetiklemiyor; karar istemez, not): `merge_same` `after_test` başlığının içindeki ve
  dışındaki aynı çipi birleştirebilir; iç etkilerin hepsi hedefsizse boş "Kartın testi hata bulursa:" başlığı kalır.

### Yardımcı yönetmenin kararları (2026-10-27, 7b'den sonra)

1. **Dizüstündeki ilk küçük iş: `promise_break` çipi de kartın kendi payını okur**, `trust_delta` şıkkıyla aynı kural
   (dayanak C_ICERIK_v3 §5.7 "B'nin çipleri" satırı ve RAPOR_B §7 soru 2). Bugün `promise_break` çipi bir tik sonrasını
   (kayma dahil) okur (`B2BSalesSystem.satisfaction_after_break`, `EvEffects.break_plan`, `EvChips._break_parts`);
   aynı kartta iki şık iki ayrı kuralla okunuyor, 7b'nin düzelttiği çelişkinin aynısı.
   - Kanıt: `product.promise_due`'nun `extend` ve `slip` şıklarının önce/sonra okuması. Bugün `extend` 72 → 66, `slip`
     72 → 31 (çekim dünyası, `--event-shot=product.promise_due`; `team.promise_made` `ask_time` ile `drop` de aynı).
   - Sürecin kuralları 7b ile aynı: kopya, tek Opus inceleme, en çok bir düzeltme, kapı, `Olaylar 7c:` commit'i.
2. **Tik affı paya katılmaz, şimdiki hâl kalır.** Çip "-8" yazıyorsa okuma 72 → 64'tür; 72 → 67 yeniden çelişki doğurur.

### Bu makineye bağlı yollar (dizüstünde yok)

- Scratchpad: `S = C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/eeffbe9c-d5c1-4a8e-8ce4-9e4b60603345/scratchpad`.
  - Çalışma kopyası `S/work/project-unicorn` (= HEAD + kendi `project.godot`), taban `S/tree_base`.
  - Araçlar `S/tools/`: `merge_onto.py`, `regen.sh`, `gate_merged.sh`, `commit_private.py`, `lock.sh`, `c7c_win.sh`.
  - Çekim klasörleri: `S/groups/c7b/shots` (7. adım), `S/groups/c7c/shots`, `extra`, `kare` (7b).
  - 7b çip taraması: `S/groups/c7c/tarama/{once,sonra,sonra2}`.
  - Sayfa: `S/page`. Rapor: `S/RAPOR_OLAYLAR.md`. Durum günlüğü: `S/DURUM.md`.
  - Bu dosyalar `docs/tasks/olaylar_adim8/`e kopyalandı.
- Erdem'in okuduğu revize verisi başka bir oturumun scratchpad'inde
  (`.../5ad1dc82-4870-4507-b82a-591327527a0f/scratchpad/revize.json`); kopyası `olaylar_adim8/revize.json`.
- APPDATA: her Godot süreci kendi klasöründe, `S/appdata/<etiket>`. Erdem'in kayıtları varsayılan APPDATA'dadır;
  oraya yazılmaz.
- Kilit klasörü: `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/kilit`
  (`kapi`, `ekran`, `sessiz`, sahip dosyası `sahip`). Bu oturum kilit bırakmadı.
- Godot: `C:/Users/erdem/Desktop/Godot_v4.6.2-stable_win64_console.exe`.

### Dizüstünde ilk üç komut

`project-unicorn/` içinde; `$GODOT` dizüstündeki Godot 4.6.2 konsol yürütücüsü; her koşu kendi APPDATA'sıyla.

1. `git log --oneline -3` → en üstte `8fbb189 Olaylar 7b` (ya da üstünde başka oturumların commit'leri).
2. `$GODOT --headless --path . --import` ve ardından `$GODOT --headless --path . --event-lint` → `LINT PASS 0 error(s),
   0 warning(s), 10 baselined, 174 card(s)`.
3. `CASE_TIMEOUT=300 GODOT=$GODOT bash tools/smoke_run.sh event_chip_live_targets` (ardından `event_chip_merge_same`,
   `event_trust_chip_share`) → `SMOKE PASS`.

Sayfada bir şey değişecekse: kareleri tamamla (eksik varsa `$GODOT --path . --event-shot=<spec> --lang=tr` ve `--lang=en`; log'daki `[Shot] saved <yol>` PNG'si `kareler/<kart>/{A,B}_{tr,en}.png`'ye, log'u yanına), ardından `python docs/tasks/olaylar_adim8/page/build_data.py docs/tasks/olaylar_adim8/kareler`, `python docs/tasks/olaylar_adim8/page/build_extra.py`, `python docs/tasks/olaylar_adim8/page/build_page.py` (Pillow gerekir); doğrula, yayınla, bağlantıyı yardımcı yönetmene ver.
