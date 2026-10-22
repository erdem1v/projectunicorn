# Faz Q · Adım tablosu (güncel koda göre, HEAD `fc6b392`)

## Context
Faz Q (PRD_FAZ_Q_KALITE.md) ekonomiyi süren üç gizli ekseni (İnovasyon, Kararlılık, Deneyim) siler. Ürünün tek kalitesi
sprint ekranındaki alanlar olur. Ürün uyumu U müşterinin yıldızına ve sektörüne göre okunur; satış, imza, satışçı zarı,
yatırımcı ve B2C kitle onu okur. C ve D tek sözleşmeden (`ProductQuality`) okur. İlk iş: §8 adım tablosunu güncel koda göre
getirmek ve onay beklemek. Onaya kadar yalnız Q0 haritası ve Q0v yürüdü; ikisi de dosyaya yazmadı, Godot koşmadı.

## Başlama koşulu ✅
- RAPOR_B §1 madde 7'nin düzeltmesi `fc6b392` olarak commit'li ("Faz B B5: Karar kâğıdı cevaplanınca ekip karta döner",
  18 Ekim 15:31). Tam olarak `sprint_system.gd`, `sprint_probe.gd`, `endgame_smoke.gd`'ye dokunuyor; üçü `git status`'ta temiz.
  Ağaçta yalnız `project.godot` (M, commit edilmez) ve izlenmeyen docs var.
- PRD `889b9b8`'e göre yazıldı. Kayma yalnız `sprint_system.gd`'de (`push_axes` çağıranı :1540 → **:1530**) ve smoke'ta.

## Erdem'in kararları (18 Ekim, adım tablosu turu)
1. **Onay bekleyen sayılar geçici yazılır.** PRD'nin önerdiği değerler tek ayar sabitinde; kodda, commit'te ve raporda
   "onay bekliyor". E1'de ölçümle kesinleşir, sessizce değişmez.
2. **Damga ve kapı üstü bonusu: PRD ne diyorsa o.** Karar 1 "ikisi silinir" diyor → K7'de silinir, raporda "onay bekliyor"
   altında listelenir.
3. **`QUALITY_AXES` üründen silinir, ağırlıkları şimdilik rakip modeline taşınır** (rakip sayıları değişmez). RAPOR_Q'da
   "rakip modeli de elden geçmeli" maddesi yazılır.
4. **Açık kararları Q kapatır:** K4 #59'u ve #10'un metnini değiştirir, #52'nin konusu K7'de kalkar, K9'da ACIK_KARARLAR'a
   kapanış satırları girer.

## Q0 ve Q0v sonucu (tabloyu değiştiren bulgular)
5 Sonnet haritacı + 5 Opus doğrulayıcı + 1 Opus bütünlük eleştirmeni, 31 dk. 210 satır doğrulandı, 43'ü düzeltildi; ana
bulguların hiçbiri çürütülmedi. Harita onaydan sonra `docs/tasks/faz_cde/q_calisma/Q0_HARITA.md`'ye yazılır (commit edilmez).
1. **Taban eski kodda alınmalı, araç eksik.** §5 tabanının bir kısmı bugünkü loglarda yok: aday yıldız karışımı, imza anındaki
   alan seviyeleri, VC zayıf eksen cümlesi, 330 hesaplı tik dünyası (`run_probe.gd:295-310`, `main.gd:501-540`). `git checkout`
   ve worktree yasak olduğu için K1'den sonra alınamaz → yeni **K0 harness** adımı.
2. **Sıra zorunlu:** K1 → K2 → K3 → (K4, K5) → K7. K7'nin sildiği okuyucular K3, K4, K5'te taşınıyor.
3. **Smoke vakaları okuyucunun taşındığı dilimde kırılıyor** (K7 ve K9'da değil). 28 ile 43 smoke fonksiyonu, `_seed_b2b`'nin
   82 çağıranı, `testing` sektörlü 22 elle kurulmuş aday. "Kapı, onu iddia eden commit'ten önce yeşildir" kuralı gereği her
   dilim kendi vakalarını taşır; göç (`save_v17_*`) ve bağlam vakaları K2'ye geçer.
4. **K3 tek commit için çok büyük** (yaklaşık 20 dosya, 25 smoke vakası, UI dosyaları) → K3a ve K3b.
5. **Aday sektörü iki dilimde yazılı** (Karar 9 m.5 K3'te, §8 K6'da). Veri zaten hazır; iş iki liste satırı ve istek alanı
   eşlemi. Sektör listesi uzayınca bütün tohumlarda aday çekimi kayar → üyelik değişikliğiyle birlikte **K3b**'de. K6'ya yalnız
   TR ad değişikliği kalır, o da onaylı ve bağımsız → **K2'den önceye**.
6. **`work_profile` iki sahipli** (K1 sözleşmesinde, verisi K7'de, D de yazmak istiyor) → profil verisi **K1**'de eklenir,
   eksen alanları K7'de silinir.
7. **Görsel kabul fikstürlerinin çoğu yok:** olgun ürün, sektörü sabitli aday, kayıp hafızalı aday, satışçı kayıp maili, B2C
   taban kartı dünyası, 330 hesaplı tik. VC sorusu `--vc-shot`'ta değil `--meeting-shot=sorgu`'da. Fikstürler ilgili dilimde yazılır.
8. Süreler dar: K2, K3, K4, K5, K9 (yukarıdaki yük yüzünden). Toplam 46 sa → yaklaşık 58 sa.

## Adım tablosu
| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| Q0 ✅ | Bağlantı haritası (§6, Karar referansları, §4.1 envanteri), salt okuma | 5 alt ajan | Sonnet | yüksek | 31 dk (bitti) | Kopukluk kod yazılmadan yakalanır |
| Q0v ✅ | Haritanın doğrulanması ve bütünlük taraması | 5 + 1 alt ajan | Opus | yüksek | (aynı koşuda) | 43 düzeltme, sıra çatışmaları, PRD hataları |
| **K0** (yeni) | Taban harness'i: `PROBE LEAD` (gelen adayın yıldızı ve sektörü), `PROBE SIGN`'a imza anındaki alan seviyeleri ve kanal, VC sorusunun anahtarı, `--tick-probe`'a tempo dünyasından ayrı 330 hesaplı dünya; `run_probe.gd` başlık sözleşmesi | Sonnet → Haiku → Opus | Sonnet / Haiku / Opus | xhigh / düşük / yüksek | 2 sa 30 dk | Taban eski kodda ölçülmeli, sonra alınamaz. Oyuncu görmez; görsel kabul yok |
| **Q0b** | Taban koşuları: 8 düzeltme kolu × tohum 7, 11 × 104 hafta; `full_run_vc_cautious` ve `full_run_b2c_vc_cautious` × 7, 11; sprint probe PRD spec'i ve `market=b2b`; `--tick-probe=3` 330 hesap. Tablolar `python -I`; "bugünkü ürün, yeni formül" U sütunu imza anı seviyelerinden | Haiku koşar, Sonnet tabloyu çıkarır | Haiku / Sonnet | düşük / yüksek | 1 sa 30 dk (koşu ~10 dk) | E1'in "bugün" sütunu. Ağır iş |
| K1 | `ProductQuality`: oran, tavan, ağırlıklar, kayıp alanı, sözleşme (Karar 5); 13 sektörlük tablo ve doğrulayıcı; tanınmayan sektör (`testing` fikstürü) için varsayılan satır; hat verisine `profile` alanı ve `ProductLines.work_profile`; `product_fit_table` ve §4.2 uç vakaları | aynı | aynı | xhigh / düşük / yüksek | 6 sa 30 dk | Çekirdek sözleşme; profilin tek sahibi |
| K6 (öne) | Onboarding alanının ve Ar-Ge düğümünün TR adı (`strings.csv:586, 2902, 2903`, `product_fixtures.gd:19`, sözlük) | aynı | aynı | xhigh / düşük / yüksek | 45 dk | Onaylı, bağımsız; K2-K5 kareleri yeni adı gösterir |
| K2 | Yıldız beklenti tablosu (geçici, onay bekliyor), B2C kitle bağlamı (geçici eşikler), rakip penceresi, aday ve hesap bağlamı; `market_ref` ve seam'i, imzada ve yenileme açılışında kopya, boş referansta yıldız satırı; şema 18 göçü; SprintCatalog'un 12 okuma yeri; ürün sayfası sözcüğü ve yıldız cümlesi (23 eski cümle silinir); sıradaki yıldız (lider, PM planı, çeyrek şeridi); `sprint.json:31` silinir; `save_v17_market_ref`, `fit_account_ref`, `fit_star_context`; olgun ürün fikstürü | aynı | aynı | **max** / düşük / yüksek | 7 sa | Kayıt ve beklenti; vakalar K9'dan buraya |
| **K3a** | Satış görüşmesi: `urun.product_fit`, sayısız zar ipucu; vurgu sorusu üç biçim, geçiş riski kapısı, itiraz; `LOSS_WEAK_AREA` ve geri dönüş kapısı; eski "stability" kayıp nedeninin okunması; oyuncu metninde "Kararlılık" temizliği (Karar 2 ve listede olmayan dört anahtar); ortak ürün fikstürü (`_seed_b2b` hat kademesi kurar); dört LOSS_STABILITY vakası | aynı | aynı | **max** / düşük / yüksek | 5 sa | K3 bölündü |
| **K3b** | Satışçı zarı (`close_chance`, tohumlu), ortak kayıp yolu ve kanal taşıyan sinyal, kayıp maili (haftada en çok 1) ve özet satırı, C'nin imza kapısına zar öncesi yer; yıldız karışımı `market_fit(3)` (eşikler geçici); 13 sektör satışta (Sağlık, Tekstil, Medya listelerin sonuna), istek alanı vurgu 1; üyelik `uses_area` ≥ 0,15 ve okuyucuları; ölü `step_appetite`, `axis_weights`; aday üretimi vakası | aynı | aynı | **max** / düşük / yüksek | 6 sa | Tohum kayması ve üyelik kayması tek commit'te |
| K4 | VC `weakest_area`, `VC_Q_WEAK_DIM` ve iç ses metni (ACIK #59 ve #10 kapanır), yatırım masası; B2C kitle (U × 5/7, saatte bir hesap), memnuniyet, fiyat; B2B ara bağ (hesap U'su; imza tohumu adayın U'su); 18 eksen fonksiyonlu smoke, `_seed_live_product`, `run_probe` derlemesi; HR'deki "Deneyim ekseni" metni | aynı | aynı | **max** / düşük / yüksek | 6 sa | Ekonomi kayması; ölçülen yük 4 saatten büyük |
| K5 | Taban merdiveni (alan oranı, yalnız B2C), sinyaller, `urun.floor_state` / `floor_area` / `trust_level`; altı kart, gövde satır içi `{seam:urun.floor_area}`; `lint_v3_frozen`'dan çıkan kartların lint düzeltmesi; `phase_bar_raised`; `_vocabulary.md` ve manifest; yeni `floor_` vakası; plausibility | aynı | aynı | xhigh / düşük / yüksek | 4 sa | Olay motoru sözleşmesi; lint işi PRD'de yoktu |
| K7 | Ar-Ge indirimi profile (3 yer, yeni kontrol); eksen verisi, `push_axes`, üç eksen bayrağı (her yüklemede düşer), QualityModel'in ürün kısmı; `QUALITY_AXES` ve `axis_label` üründen silinir, ağırlıklar rakip modeline taşınır; damga zinciri ve kapı üstü bonusu (Karar 1); ölü parçalar ve ölü eksen metinleri; `_migrate_15` profili okur; kalan smoke vakaları; §4.1 sayımı sıfır | aynı | aynı | **max** / düşük / yüksek | 5 sa | Geniş silme; K3, K4, K5'ten önce derlenmez |
| K8 | `PROBE FIT`, `quality_core` kolu, B2C U satırı, hesap U'su değişim sayacı; ölçüm koşuları, §4.4 ve §4.5 tabloları | aynı | aynı | xhigh / düşük / yüksek | 6 sa | E1'in girdisi. Ağır iş |
| E1 | **Erdem durağı:** ölçüm tabloları (bütün imzalar ve 2★ ile 3★); yıldız tablosu, zar eğrisi, karışım eşikleri, B2C kitle eşikleri önerisi; §10 kalan soru 1 | Ana | Opus | orta | Erdem'e bağlı | K9 bu cevaba dayanır |
| K9 | Onaylanan değerler ve yeniden ölçüm; `fit_scale` ve tik süresi; tam görsel kabul (TR, EN, renk körü, 1,25); `run_gate`, plausibility; belgeler (HARITA, CLAUDE.md, GUNCELLEMELER, GDD motor §27, sözlük, ACIK_KARARLAR, ISLER) | Sonnet → Haiku → Opus | aynı | xhigh / düşük / yüksek | 7 sa | Kapanış |
| R | `RAPOR_Q.md`: önce bakılacaklar, kabul ölçütleri, onay bekleyenler, commit listesi, sorular; C ve D için sözleşme adları ve imzaları, genişletilmiş ortak dosya listesi, "rakip modeli de elden geçmeli" | Ana | Opus | orta | 45 dk | C ve D'nin girdisi |

Toplam yaklaşık 58 sa ajan süresi, E1 beklemesi hariç (PRD 46). E1 beklenirken K9'un belge kısmı ilerleyebilir.

## Her commit'in akışı
1. Sonnet kodlar (xhigh, max dilimlerde max). Tek dilim aynı anda; worktree yok, ana ağaçta.
2. Haiku kapıları koşar: yeni `class_name` varsa önce `--headless --import`; `--event-lint` → `loc_residue` →
   `loc_csv_integrity` → dilimin hedefli smoke vakaları. Oyuncu metni değiştiyse TR ve EN kare çeker (sırayla, ekranlı).
3. Opus diff'i ve kareleri inceler (CLAUDE.md §9 soruları), düzeltme hakkı var. Düzeltme olursa Haiku kapıları bir kez daha koşar.
4. Ana oturum commit eder: `Faz Q Kn: ...`, yalnız kendi dosyaları; `project.godot` ve tema farkı yok. Sabitler ve metinler
   mesajda "onay bekliyor" / "TR/EN onay bekliyor".
Commit başına en çok 1 inceleme ve 1 düzeltme. Kapı ikinci kez düşerse commit etmem, ekran görüntüsü ve logla sana gelirim.

## Ağır iş ve Godot
- Godot'u yalnız Q koşturur. Ağır iş: Q0b, K5 ve K9 plausibility, K8 ve K9 ölçümleri, `run_gate`. Her ağır işten önce tek
  satırla haber veririm; "oynuyorum" dersen beklerim. Tam smoke yok (push öncesi değil, push yok).
- Her bot koşusu ayrı `APPDATA` ile; gerçek kayıtlar korunur.

## Varsayılanlarım (onayla birlikte geçerli; itiraz edersen değişir)
1. Ürün sayfasında `serves` ve sözcük ham seviyeyi okur, ekran yarıma yuvarlanmışı gösterir (yoksa MVP 0,6 → 0,5 olur ve
   cümle "1★'a yeter" diyemez).
2. Gelir alanı U'ya girmez; satırı ve dört cümlesi kalır, sözcüğü B2C vurgu sütunuyla okunur (yalnız gösterim).
3. Rakip artışı bugünkü gibi çıkış kaydı başına sayılır (bugünkü veride "rakip başına" ile fark yok).
4. `market_fit(3)` PRD'deki gibi 13 sektör üzerinden.
5. Satışçının kaybettiği aday kurucunun kaybıyla aynı yola girer ve satışçı da geri dönüş kapısına bakar; mail "yeniden
   denerim" derken doğru söyler.
6. `quality_core` = ERP, `fix: worst`, lider yalnız Çekirdek kartı alır; düzeltme ve araştırma kartları süzgeçten muaf.
   B2C `quality_core` kolu yok.
7. §4.1 kapısı PRD'nin on belirteciyle sayılır (bugün smoke 65, run_probe 13 satır, 25 dosya), artı `push_axes` ve JSON
   eksen alanları. PRD'nin 117/32 sayısı daha geniş bir desenle; raporda ikisi de yazılır.
8. Ortak dosya listesi eksik (sales_meeting_adapter, inbox, mail_pane, message_system, main.gd, product_fixtures, sales_probes,
   sales_faucet_system, sales_archetypes, negotiation_system, seams_product, incident_system, game_state, launch_leak.json,
   password_rule.json). RAPOR_Q bunları da Q'nun son commit'ine bağlar.
9. "Kararlılık" geçen ama C'nin satırı olan risk nedeni (`SALES_REASON_STABILITY`, `strings.csv:145`) yalnız metin olarak
   K3a'da yeniden yazılır; mekanizması C'nin.

## RAPOR_Q'ya gidecek PRD düzeltmeleri
`push_axes` çağıranı :1530; `main.gd:3625-3630` damga fikstürü (üç eksen bayrağı yalnız :506-508, :1448-1450); `QUALITY_AXES`
:170; `lint_v3_frozen.json` üretilmez, elle tutulur; `urun.axis_reading` kayıtlı seam değil, katkı kimliği; §3.5 `{area}` kart
gövdesinde iki smoke kapısını düşürür, satır içi `{seam:...}` olmalı; `loc_b2b_derived_keys` aday üretimini kanıtlamaz;
Karar 2 listesi eksik; Customer yolu `scripts/data_models/customer.gd`.

## Doğrulama
- Her dilim: Haiku kapıları (yukarıda) + hedefli smoke + oyuncu metni değiştiyse TR/EN kareler.
- K2 sonrası şema 17 kaydı açılır, `market_ref` dolar, ilk tik memnuniyeti değiştirmez (`save_v17_market_ref`).
- K5 ve K9: `--event-lint`, altı kart için `--why-fire`, `plausibility_run.sh` (`fails=0`).
- K9: §4.2, §4.3, §4.6, §4.7 vakaları; `run_gate.sh` 3/3 sonla biter, 0 `ERROR`; sprint probe uyuşmazlık listesi büyümez;
  dört varyantlı görsel kabul. `run_gate` ve §4.8 yeşil değilse R yazılmaz.
