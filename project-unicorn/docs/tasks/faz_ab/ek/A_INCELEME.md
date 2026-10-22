# Faz A planı · Kıdemli inceleme (Opus, 2026-10-16)
İncelenen: `A_PLAN.md`. Okunanlar: `ERDEM_TUR2_YORUM.md`, karar defteri (Faz A ve "Fazlar arası sınırlar"), `ORTAK.md`,
`A_GOREV.md`, `../sprint/T2_2_bugs.md`, `B_PLAN.md`, `B_INCELEME.md`, `C_PLAN.md`, `D_PLAN.md`, `E_PLAN.md`.
Kod `main` @ `1faeb82` üstünde doğrulandı. Repoda hiçbir dosya değişmedi. Plana yapılan her değişiklik "(inceleme)"
işaretiyle duruyor.

**Hüküm: düzeltmeyle hazır.** Kod okuması titiz, 20 okuyuculu tablo doğru çıktı. Asıl eksik tasarımdaydı: plan seli
yalnız görünüm tarafında çözüyordu. Hotfix gidince oyuncunun gördüğü sayı üç katına çıkıyordu ve plan "ucuz önlem
gerekmedi" diyordu. Tek sabitlik bir düzeltme ve bir ölçüm kapısı eklendi (bulgu 1). Kalan 6 karar Erdem'in.

---

## 1. Bulgular

| # | Bulgu | Nerede | Düzeltme | Uygulandı mı |
|---|---|---|---|---|
| 1 | **Sel tedavi edilmiyordu, büyüyordu.** Erdem'in ilk şikâyeti hacimdi ("o kadar fazla ticket geliyor"). Plan bilet başına 6 yüzeyi tek sayıya indiriyor, bu iyi. Ama Hotfix gidince botta B2B gönderim ortalaması 8'den 25'e çıkıyor (kümelemesiz 35–38). Geç B2B'de akış `1 + hesap/10` ile doğrusal büyüyor: 170 hesapta ×18, haftada ≈ 25 hata. Plan bunu ölçüp "ucuz önlem gerekmedi" demişti. | §0 madde 6, §4.3, §5.4, K5 | `USAGE_DIV_B2B` 10 → 25 (tek sabit; gerekçe: aynı hatayı çok hesap bildirir, ayrı hata sayısı hesapla doğrusal artmaz). 170 hesapta ×7,8, haftada ≈ 11. K5'e kapı eklendi: bot B2B gönderim ortalaması ≤ 12, yani bugünkünün en çok 1,5 katı. Tutmazsa sayı Erdem'e gider, sessizce oynatılmaz. B2C çarpanı E'ye kalır. | Evet (sahip sorusu 6) |
| 2 | **"Özenli oyuncuda ortalama 5 civarı kalır" iddiası yanlış.** Düzeltme kartı yalnız sprint başında planlanır ve kapanışta hattı sıfırlar. Sprint sürerken gelen hata bir sonraki sprinte kadar açık kalır. Kusursuz oyuncunun alt sınırı "haftalık akış × sprint uzunluğu"dur; geç B2B'de bu 25–50 eder. Bot acil kartları zaten zorunlu alıyor. Kümelemeyle her haftanın hattı 3 eşiğini geçip acile döndüğü için bot, düzeltme seçiminde özenli bir oyuncuya yakın davranıyor. Yani ölçülen 25 ihmalden değil akıştan geliyor. **Bot hacmi ölçmek için temsilci, özeni ölçmek için değil.** | §4.3 | İddianın üstü çizildi, gerekçe yazıldı. | Evet |
| 3 | Öbür seçenekler (önemsiz hatayı saymamak, doğrulamayı yavaşlatmak, hatanın kendiliğinden kapanması) değerlendirildi. İlk ikisi yeni durum ister ve yalnız görünümü küçültür. Üçüncüsü "hatayı yalnız düzeltme kartı çözer" kararıyla çelişir. | §4.3 | Önerilmedi; gerekçe plana yazıldı. | Evet |
| 4 | **Etki zinciri doğru.** Spot kontrol: `support_system.gd:172, 273`, `sales_system.gd:33/424, 467`, `quality_model.gd:111, 233`, `b2b_sales_system.gd:136, 504`, `vc_pitch_system.gd:493, 503, 1149, 1199, 1291`, `term_sheet_table_system.gd:549`, `sales_meeting_system.gd:141, 340`, `sales_faucet_system.gd:171`, `sales_ledger.gd:338`, `sales_probes.gd:62`, `product_read.gd:37, 154`, `seams_product.gd:90`, `rnd_system.gd:601`, `inbox.gd:211`, `b2c_refunds.json:39`. Hepsi tabloda doğru yerde. Eksik okuyucu yok. | §5.1 | — | Doğrulandı |
| 5 | **İtibar satışa ve yatırımcıya sızmıyor.** Okuyucuları yalnız B2C kitle büyümesi (`sales_system.gd:188`) ve VC sorgusu; VC yalnız `itibar < 0`'a bakıyor (`vc_pitch_system.gd:1145, 1193`). `finance.reputation` seam'ini okuyan kart yok. Taban 0 ile sızıntı yok. Memnuniyeti okuyan satış ya da yatırımcı kodu da yok (faucet, toplantı, VC, term sheet tarandı). Plan bir şeyi açık yazmamıştı: B2C memnuniyeti ağızdan ağıza büyümeyi sürüyor. Bu, yeni kullanıcı gelişini yavaşlatır, dönüşüm oranına dokunmaz. | §5.1 satır 2 ve 20 | Not eklendi. Bu, Erdem'in "memnuniyeti ve itibarı düşebilir" cümlesinin karşılığı. | Evet |
| 6 | **İtibar kuralı neredeyse hiç işlemiyor.** İtibar yalnız olay kartlarıyla oynuyor (47 seçenekte ±1–4) ve 0'dan başlıyor. Tabanı 0 olan "−1/hafta" kuralı yalnız kazanılmış itibarı siler. Taban 0'ın altına inemez, inerse yatırımcı sorusu tetiklenir. | §2.6, §8 | Not eklendi, sahip sorusu 5. | Evet (soru) |
| 7 | **Kayıtta bekleyen VC geri dönüşü.** `bugs_under` koşulu yatırımcı durumunda (`st.callback`) saklanıyor. Plan bu türü silip yeni koşul koyuyor ama eski kayıttaki bekleyen koşulu göç etmiyordu. | §5.1 satır 21, §5.5, K5 | `_migrate_16` bekleyen `bugs_under`'ı yeni eksen koşuluna çevirir. Yeni vaka `save_v15_callback_bugs_under`. | Evet |
| 8 | **24 kat aşınma iddiası gerçekten çürük.** Dosya başlığına göre oran takvim saati başına (`product_system.gd:9-11`). Saatlik tik `per_tick` ile ×7 uyguluyor (`time_model.gd:28`), haftada 24 × 7 = 168 takvim saati ediyor. Plandaki +0,336 ölçümü bununla tutarlı. | §4.1 | — | Doğrulandı |
| 9 | **Şema 15 → 16 doğru** (`save_manager.gd:16`, `MIN_LOADABLE_VERSION` 10, `_migrate_15` var). D, "A ve B'den sonraki ilk sayı" diyor: B şema değiştirmiyor, D 17 alır. | §5.5, §5.7 | D'nin numarası plana yazıldı. | Evet |
| 10 | **K3 kendi başına tutarlı değildi.** K3, L'yi (`live_bug_count`) ve aşınmayı siliyordu, ama L'nin 9 okuyucusu (satış, kalite, VC, term sheet, gelen kutusu) ancak K5'te kesiliyordu. K3 ya derlenmez ya da geçici bir köprü ister. Ayrıca K3 ≈ 25 dosyayla en riskli dilimdi. | §5.6, K3, K5, §9 | Aşınma, L ve akışın taşınan terimi K5'e taşındı: L'nin yazarı ve okuyucuları aynı commit'te gider. K3'te C'yi okuyan yerler `open_bugs()`'a döner. K3 ≈ 18 dosyaya iner, K5 ≈ 19 olur. Ara durum bugünkü oyundur. Ayrıca bir dilim bölmeye gerek kalmadı. | Evet |
| 11 | **K2'nin K3'ten önce gelmesi doğru.** Düzeltme koşusu C'yi eritiyor (`support_system.gd:132-133`). `bug_pile`'ın tek seçeneği `fix_run_start` fiilini çağırıyor ve bu fiil K2'de siliniyor; kart K2'de gitmezse lint kırılır. B planı "A bıraktıysa B siler" diyor, yani çakışma yok. Bu yüzden 4. soru sahip sorusu olmaktan çıktı; A5 kararının parçası. | §8, §5.7, risk 3 | Soru kapatıldı. | Evet |
| 12 | **B, C ve E'nin istediği okuma noktaları eksikti.** B hesap listesi istiyor (güven bedeli hesaba yazılır), A yalnız sayı veriyordu. B'nin açık olayı "hattın düzeltmesi çıkınca kapanır", A'nın yazımı ise hatsız `build_progress_changed` yayıyordu. B'nin `line_harden`'ı "aşınmadan yeni hata düşmez" diyor, oysa aşınma kalkıyor. E "A'nın B2C payı"nı istiyor. C hat satırını "A'nın biçiminde" çizecek. | §5.2, §5.7, K3, K6 | Altı küçük ek: `ProductState.line_bugs(hat)`, `SprintCatalog.line_accounts(hat)`, `SprintCatalog.line_share(hat)`, `EventBus.line_bugs_cleared(hat, n)`, `ProductState.line_blocked(hat)` (B doldurur, `bug_line()` sorar), `ProductModel.bug_row(hat)`. | Evet |
| 13 | **Alan cümlesi çelişkisi.** Bugünkü "Temel iş sorunsuz yürüyor" ve "Ürün güvenilir çalışıyor" cümlelerinin yanına "· 9 açık hata" geliyordu. Erdem'in "mantık çelişkisi yok" kuralına aykırı; planın kendi ASCII örneğinde de vardı. | §2.1, §6, K6 | `PRODUCT_AREA_CORE_ENOUGH`: "Users can get the basic job done / Kullanıcılar temel işi yapabiliyor". `PRODUCT_AREA_TRUST_ENOUGH`: "Backups and access control are in place / Yedek ve yetki yerinde". | Evet |
| 14 | EN ipucu "Hits {accounts} and {users}." manşet gibi kesik duruyor; EN önce yazılır ve TR ondan yeniden kurulur. | §6 | "{accounts} and {users} are affected. The largest account is {stars}★." / "{users} are affected." | Evet |
| 15 | **Öbür metinler kurala uyuyor.** Sayılar sayı olarak yazılıyor, müşteri adı ve "%4 sipariş" yok, tire yok ("→" tire değil), "ticket" oyuncu metninden tümden çıkıyor, belirteçlerin ardına ek gelmiyor. Gözde hesabın adla değil ipucunda yıldızla gösterilmesi Erdem'in "müşteri adı değil sayı" kuralına uyuyor. | §6 | — | Doğrulandı |
| 16 | "Tam smoke yalnız push öncesi" yazıyordu. Erdem 2026-10-06'da şunu söyledi: "push et" doğrudan push demektir, tam smoke yok. B planında da aynı hata düzeltilmişti. | §7 | Düzeltildi. | Evet |
| 17 | K3 "inceleme iki tur" ve K3'te 60 haftalık ×4 ölçüm turu vardı; aynı ölçüm K5'te bir kez daha koşuyordu. Erdem 2026-10-11 kuralı: commit başına tek inceleme, en çok bir düzeltme turu, ölçüm turu tekrarlanmaz. | K3, risk 1, §9 | K3 tek inceleme (Opus, düzeltme hakkıyla) ve 30 haftalık tek hatasız bitiş koşusu. Ölçüm yalnız K5'te. | Evet |
| 18 | **K7'deki tema yeniden üretimi sahipsiz farkı geri dönülmez siliyor.** Plan "commit öncesi ayrıştırılır" diyordu; ama üretim dosyayı diskte baştan yazdığı için ayrıştıracak bir şey kalmaz. Bugünkü fark yalnız editörün eklediği `uid` satırları (`git diff` ile doğrulandı). | Başlık, risk 5, 7a | Üretimden önce `git diff -- themes/` yamasına ve iki dosyanın kopyasına yedek alınır. Rapor Erdem'e söyler. `project.godot`'a dokunulmaz. `git checkout --` yasak. | Evet |
| 19 | `b2b_sales_system.gd:446`, T2_2 B5'e göre gerçek oyunda zaten çıkmış bir yeteneği söz olarak verebiliyor. Bu bir oyun hatası. Plan bunu yalnız K8 raporuna "ayrı iş" diye yazıyordu. | §5.6 K8 | K8 bunu `ACIK_KARARLAR`'a madde olarak yazar. Kapsama alınmadı: `mvp_components` söz kaydına ve 11 vakaya bağlı. | Evet (not) |
| 20 | Etkilenen hesap kuralının bir tuhaf yanı var: teknik alıcının Deneyim ağırlığı 0,20 (< 0,25), yani teknik hesaplar Fatura ve Stok'u "kullanmıyor". Kural deterministik ve hatlar arasında anlamlı bir fark çıkarıyor; alternatif ("herkes her hattı kullanır") sayıyı her hatta aynı yapar. | §4.4 | Değiştirilmedi; 3. soruda Erdem'e açık. | Hayır (soru) |
| 21 | **Haftalık kümeleme B2B'de bir duvar yaratabilir.** O haftanın hattı Defter'se (bütün hesaplar kullanır) her hesabın hedefi aynı anda −0,5 × n düşer. Akış 25 iken bu −12,5 ediyordu; bölen 25 ile ≈ −5,5'e iner. | §5.3 madde 7 | K5'in kalibrasyon raporu ayrılmaların haftalara dağılımını da gösterir (tek haftada toplu Risk var mı). | Hayır (K5 raporuna not) |
| 22 | **Fazlalık kontrolü (CLAUDE.md §8).** Plan eklediğinden çok siliyor: iki sayaç, bilet defteri, sesler, düzeltme koşusu, aşınma, sağlık ve risk türetmeleri, 20 sabit. Yeni durum bir sözlük ve bir önceki-hafta kopyası. Yeni sistem ve yeni ekran yok. Doğrulama makinesi oyuncudan gizlenen bir ara adım için kalıyor; C'nin "Yetişemedim" satırı ve memnuniyet zararı onu okuduğu için kabul edilebilir. | genel | — | Doğrulandı |
| 23 | **Süreler.** Toplam ≈ 15 saat gerçekçi. K3 105 dk'ya, K5 90 dk'ya kaydı; toplam değişmedi. Model seçimi kurala uyuyor: kodu Sonnet (xhigh/max), kapıları Haiku (düşük), her commit öncesi Opus kıdemli inceleme (düzeltme hakkıyla). | §9 | Satırlar güncellendi. | Evet |

---

## 2. Fazlar arası ad uyuşmazlıkları (öbür planlara dokunulmadı; her plan tazelemesinde uygular)

**B planı**
| B'de yazan | A'daki karşılığı |
|---|---|
| `ProductState.open_bugs(line)` | `ProductState.line_bugs(hat)` |
| `open_bugs_total()` | `ProductState.open_bugs()` |
| `affected(line) → {accounts, seats, users}` | `SprintCatalog.line_impact(hat)` → B2B `{accounts, seats, top_star}`, B2C `{users}`; hesap listesi `SprintCatalog.line_accounts(hat)` |
| "sürüm kaydında hatalı çıkan hatlar listesi" | `release.faulty` |
| "düzeltme kartı kapanınca … sinyal ya da çağrı" | `EventBus.line_bugs_cleared(hat, n)` |
| `line_harden`: "aşınmadan yeni hata düşmez" | Aşınma kalkıyor. Fiil `ProductState.line_blocked(hat)`'ı doldurur; `SprintCatalog.bug_line()` engelli hattı seçmez. Hatalı kapanış hatası bundan etkilenmez; metin "yeni hata düşmez" kalabilir |
| `product.bug_pile` "B'de silinir" | A'nın K2'sinde silinir; B'nin silme listesinden çıkar (B'nin "A bıraktıysa" cümlesi zaten bunu kapsıyor) |
| `month_close` koşulu "o hatları kullanan hesap" | `SprintCatalog.line_accounts(hat)` (yüklem `SalesArchetypes.uses_axis`) |
| Olasılıktaki `açık_hata_toplam` ve `checkout` ağırlığı | `ProductState.open_bugs()`, `ProductState.line_bugs(hat)` |
| Erteleme izi ile A'nın hesap başına terimi | A'nın terimi `B2BSalesSystem.account_bugs(c)` × 0,5, tavan 20. Akış bölen 25 ile küçüldüğü için B3 ölçümündeki çift sayım karşılaştırması yeni akışla yapılır |

**C planı**
| C'de yazan | A'daki karşılığı |
|---|---|
| `ProductSystem.open_bugs()` / `open_bugs_by_line()` | `ProductState.open_bugs()` / `ProductState.open_bugs_by_line()` |
| "haftalık değişimiyle" | `ProductState.open_bugs_delta(hat := "")` |
| "Hat satırı A'nın biçiminde, tek fonksiyondan" | `ProductModel.bug_row(hat) -> {text, tip, delta}` |
| `target_terms` 2. terim "A'nın hesap başına terimi" | `B2BSalesSystem.account_bugs(c)` × `B2BConstants.B2B_BUG_SAT_PER`, tavan `B2B_BUG_SAT_CAP` |
| `target_terms` 1. terim "A hatayı ayırırsa hatasız hâli" | Evet, ayırıyor: ham Kararlılık (`QualityModel.dims_from_flags`) |
| "Yetişemedim" gelen akışı | `ProductState.reports_incoming()` (kalır) |
| Build bar tıklaması | A'da `ProductTab.open_area(hat_alanı)`; C kendi `product_view_requested` sinyaline taşır |
| Eşik ölçümü | A'nın akışı bölen 25 ile değişiyor; C3'ün "A'dan sonra yeniden ölç" kapısı bunu da kapsar |

**D planı**
| D'de yazan | A'daki karşılığı |
|---|---|
| `sprint.json` `effort.fix*` | `sprint.json` `fix_effort {steps: [3, 6], points: [1, 2, 3]}`; `effort.fix` ve `effort.fix_urgent` silinir; kartta tamsayı `effort` |
| "A'nın `_close` içindeki yazımı" | `_go_public`'te `ProductState.add_bugs(kart.hattı, 1)`; v1.0 öncesi `product.pending_faulty` (eski `gate_faulty`) |
| Smoke `sprint_faulty_ticket_deterministic` | A, K3'te `sprint_faulty_bug_on_card_line` olarak yeniden adlandırır; D onu `sprint_escape_by_tester`'a çevirir |
| "Şema 16 ya da 17 alınmış olabilir" | A 16 alır, B almaz; D 17 |

**E planı**
| E'de yazan | A'daki karşılığı |
|---|---|
| "A'nın B2C kuralı tek bir pay üretir" | `SprintCatalog.line_share(hat) -> float` |
| "A hat başına Açık hata okuması verir" | `ProductState.line_bugs(hat)` / `open_bugs_by_line()` |
| "A'nın B2C churn'ü kitle üzerinden yazar" | Evet: `SalesSystem` kitle deltası, `B2C_BUG_CHURN_COEF` 2e-6 × min(max(0, O − 3), 40) |
| `urun.usage` çarpanı | B2B böleni A'da 25 olur; B2C böleni (2000) E'nin kararıdır |

---

## 3. Erdem'in kararı gereken maddeler (kapalı, önerili; planın kendi sorularıyla birleşik, en çok 6)

1. **Aşınma kalksın mı?** Yayındaki ürünün kendiliğinden biriktirdiği gizli hata kalkar. Hata yalnız yeni koddan, kullanımdan
   ve hatalı kapanan karttan doğar. Bugünkü oyunda karmaşıklık hep 0 olduğu için gerçek değişiklik küçük. **Öneri: evet.**
2. **Bir haftanın yeni hataları tek hatta mı düşsün?** O hat, son iki sürümde kademesi çıkan hatlar arasından ağırlıklı
   seçilir ("yeni yazılan kod bozulur"). Ölçümde açık hata ortalaması 45'ten 25'e iniyor ve düzeltme daha az hat geziyor.
   **Öneri: evet.**
3. **Etkilenen hesap kuralı:** hesap, alıcı tipinin o hattın eksenine %25 ve üstü ağırlık verdiği hatları kullansın mı?
   Sonuç: Defter'i her hesap kullanır, Fatura ve Stok'u yaklaşık %77'si, Nakit Akışı ve Veri Girişi'ni %23'ü. Gözde hesap
   adla değil, ipucunda "En büyük hesap 3★" diye gösterilir. Alternatif "herkes her hattı kullanır" sayıyı her hatta aynı
   yapar. **Öneri: evet.**
4. **Yatırımcı ve satış:** üç değişiklik birlikte gelir. Ürün odaklı fonun geri dönüş koşulu "Aktif hata < 3" yerine "En zayıf eksen > 40" olur.
   "Ürününüzde hata kaynıyor" sorgusu silinir. Satış toplantısındaki "açık hatalarınız var" sorusu silinir.
   **Öneri: evet.** Hata satışa ve yatırımcıya dönmez.
5. **İtibar:** "ihmal edilen ürünün itibarı düşer" kuralı tabanı 0 ile kalsın mı? İtibar çoğu koşuda 0 civarında, bu yüzden
   kural çoğu zaman bir şey değiştirmez. 0'ın altına inerse yatırımcı soru sorar. **Öneri: kalsın.** Sözünüz karşılanır ve
   yatırımcıya sızmaz. İhmalin asıl bedelini memnuniyet ödetir: B2C'de ağızdan ağıza büyüme, B2B'de hesap hedefi.
6. **Hata akışı yumuşasın mı?** Hotfix gidince oyuncunun gördüğü açık hata sayısı üç katına çıkıyor: B2B'de 8'den 25'e,
   geç oyunda haftada ≈ 25 yeni hata. İlk şikâyetinizdeki sel bu. B2B'de akışın hesap sayısıyla büyümesi yarıdan fazla
   yavaşlar (aynı hatayı çok hesap bildirir). Beklenen ortalama ≈ 12; uygulamada ölçülür, tutmazsa size gelir.
   **Öneri: evet.**

Ayrıca onay bekleyenler: 5.4'teki sabitler ve 6. bölümdeki TR/EN metinler (iki alan cümlesinin yeni hâli dahil).

---

## 4. Ana oturuma not
- B tazelemesi: 2. bölümdeki B adları. `line_harden` metni aşınmaya değil hat seçimine bağlanır.
- C tazelemesi: 2. bölümdeki C adları. Eşik ölçümü A'nın yeni akışıyla yapılır.
- D tazelemesi: `fix_effort`, `pending_faulty`, şema 17, vaka adı.
- E tazelemesi: `line_share`, `line_bugs`; B2C akış böleni E'nin kararı.
