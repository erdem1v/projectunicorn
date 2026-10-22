> 2026-10-20 E1 cevabıyla değişenler: PLAN_C_E1.md

# Faz C · Adım tablosu (Ürün sayfası, sunucu, giderler, B2B hesaplar)

## Bağlam
Görev `project-unicorn/docs/tasks/faz_cde/PRD_FAZ_C_URUN_HESAP.md` (bağlayıcı); öncelik `ERDEM_QCD_CEVAP.md` §1 → §2.2 → PRD.
Bu oturum Faz C'nin uygulayıcısı. İlk iş adım tablosu ve Erdem'in onayı. Tablo Erdem'e gelmeden önce bir Opus kıdemli
incelemesinden geçti; bulguları işlendi (aşağıda "PRD'den farklar").

**Bugünkü durum (2026-10-18, okundu):**
- `main` @ `fc6b392`. PRD'nin satır numaraları `889b9b8`'e göre. Aradaki fark yalnız `sprint_system.gd`, `sprint_probe.gd` ve
  `endgame_smoke.gd`'de: RAPOR_B madde 7 düzeltmesi commit'li, üç dosya temiz.
- Faz Q'nun commit'i yok, `RAPOR_Q.md` yok. Kayıt şeması 17 (Q 18, C 19, D 20).
- `c_taslak/msim/` hazır (MEMNUNIYET_SIM betikleri).
- Koddan iki gerçek:
  - Oyunda sunucu arayüzü yok: `scripts/tabs` ve `scripts/ui` altında `InfraSystem`'i okuyan dosya yok.
  - `InfraSystem` kayda girmiyor: `save_manager.gd:373-382` `_capture_systems` listesinde yok.

## Adım tablosu

**Dalga 1 · Q kod yazarken.** Godot koşmaz; oyun koduna, `strings.csv`'ye ve `data/`'ya yazılmaz; çıktılar `c_taslak/`'ta.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| C0 | Bağlantı haritası (§6). Commit'li `HEAD`'i okur, Q'nun yarım dosyasını okumaz. Q'nun yeniden yazacağı dosyalarda (`sales_*`, `b2b_sales_system`, `customer.gd`, `sprint_bridges`) yalnız fonksiyon adı düzeyinde haritalar; satır düzeyi C0q'ya kalır | Alt ajan | Sonnet | yüksek | 45 dk | Kod taraması |
| C0v | Haritayı kodla doğrular. Adım ekleri: her adımın dokunduğu dosya ve satır, güncellenecek ve silinecek smoke vakaları, Q ve D sınırı. E1 soruları. Çıktı `C0_HARITA.md`, `C0v_ADIM_EKLERI.md` | Alt ajan | Opus | yüksek | 20 dk | Kopukluk kod yazılmadan yakalanır |
| C0r | Otomatik ölçekleme araştırması (§5): üç oyun ve AWS, GCP, Kubernetes HPA. Eşik, adım (oran mı sabit mi), küçültme, bekleme. Her satır URL taşır, URL'siz satır [kanıtsız] yazılır | Alt ajan | Sonnet | yüksek | 45 dk | Anahtarın eşiği ve adımı |
| W1 | Yazım dalgası (ayrıntı aşağıda). İngilizce önce yazılır, Türkçe sahneyi yeniden yazar. Tek JSON kaynak ve md. Çıkış kapısı `python -I` mekanik denetimi: tire yok, TR ve EN yer tutucuları aynı, yalnız adlı `{slot}`, sözlüğün ödünç kelimeleri | Alt ajan + denetim | Opus (yazar) · Haiku (denetim) | yüksek · düşük | 1 sa 30 dk | Yazım kalitesi; belgeye ayrı inceleme yok |

**W1'in kapsamı:**
- §3'ün bütün satırları.
- v2 §2.3 Kurumsal mailleri, §2.4 HESAPLAR (başlıklar, dört görünüm, Durum etiketleri), §2.6 yenileme kâğıtları.
- C_PLAN §2.1 ve §2.2 (Genel Bakış blokları, İstekler) ve §2.8 destek raporu.
- Defter satır adları ve durum terimleri, istek kartının iki şıkkı, sektör eğilimi sözcükleri.
- Kesinti kartının yük cümlesi (yalnız yük %90'ın üstündeyken).

**Bitiş:** Erdem'e tek satır: "C0, C0v, C0r ve W1 hazır; Q'yu bekliyorum." Hafif bir izleyici `RAPOR_Q.md`'yi ve raporun son
commit'inin `git log`'a düşmesini bekler. RAPOR_Q'da ❌ varsa önce Erdem'e sorulur.

**Dalga 2 · Q'nun raporundan sonra, C1'den önce**

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| C0q | **Yeni adım.** Q'dan sonra haritayı tazeler: `git diff fc6b392..<Q son>` haritadaki dosyalarda. RAPOR_Q'dan seam adları: `account_fit`, `prospect_fit`, `loss_area`, `area_row`, `uses_area`, `market_ref`, satışçı zarının adı ve `_close`'taki yeri, şema 18 | Alt ajan | Sonnet | yüksek | 30 dk | Q ortak dosyaların çoğunu değiştirir |
| C0s ∥ C0m | **C0s:** ayrıntı aşağıda; yalnız `python -I` ile, `c_taslak/msim/`'de | Alt ajan | Sonnet | yüksek | 1 sa 45 dk | Oranlar, kira, runway ve Frank şartı buna dayanır |
| | **C0m:** ekranlar oyunun kendi arayüzüyle: Genel Bakış, Sunucu bloğu, Atlas tavanı, HESAPLAR, memnuniyet ipucu, satışçı raporu. `UiFactory` ve `menajer_theme` ile kurulur. Betik `class_name` taşımaz, `-s` ile koşar, `c_taslak/C0m/`'de durur. Pencereli, TR ve bir EN karesi. Sen oynamıyorken koşar. Bitince sana "C0m bitti, D'nin M'i koşabilir" derim | Alt ajan | Sonnet | yüksek | 2 sa | UI koddan önce gösterilir |
| E1 | **Erdem durağı**, tek sayfada: C0r tablosu ve eşik/adım önerisi, C0s kapıları ve ekonomi, C0m kareleri, W1 metinleri, C0v'nin soruları, C'nin onay bekleyen bütün sabitleri (aşağıdaki liste; öneri, dayanak, ölçüm) ve kapı hedef önerileri | Ana | Opus | orta | sana bağlı | Onaysız sabit yazılmaz: kod onaylı değerle başlar |

**C0s'in ölçtükleri:**
- MEMNUNIYET_SIM yıldız beklentisiyle (Q3) yeniden koşar; M1 ile M13 kapıları.
- Yenileme sonuç dağılımı; 13 sektörün eğilim önerisi.
- Hata tavanı 60, 62 ve 64 (M5); Karar 7'nin vurgu alanı tanımı (M8).
- Ekonomi: M11, Bootstrap runway, ilk 40 haftanın açığı, Frank şartı iki hâliyle, Plaza şartlarının ne zaman tuttuğu.

**Dalga 3 · Kod.** E1 onaylanınca ve D'nin M'i bitince başlar; adımlar seri yürür.

| Adım | Ne | Kim | Model | Düşünme | Süre | Kapı | Neden |
|---|---|---|---|---|---|---|---|
| C1 | Sunucu, ayrıntı aşağıda | Sonnet → Haiku → Opus | S / H / O | xhigh / düşük / yüksek | 6 sa 30 dk | §4.4 m.4; `run_gate`; görsel | Sunucunun bugün ekranı ve botu yok; ikisi olmadan ara kapılar anlamsız |
| C2 | Giderler: araç ve servis silinir, ofis kirası, boş gider listesi, HR önizlemeleri, metinler. `daily_burn` yüklemede yeniden hesaplanır (bugün ilk tike kadar eski burn görünüyor). `MONTH_BURN` ve `GATE`'ten `tools` ve `service` çıkar | aynı | aynı | xhigh / düşük / yüksek | 3 sa 30 dk | §4.4 m.5; `loc_residue`; `run_gate`; görsel | Ekonomi ve metin |
| C3a | Memnuniyet defteri, ayrıntı aşağıda | aynı | aynı | **max** / düşük / yüksek | 6 sa 30 dk | §4.4 m.1, m.3, `update_age_emphasis_only`; göç vakaları; `--event-lint`; `plausibility`; `run_gate`; A'nın `fix_*` B2B churn kapıları (Q bunları C3a'ya bıraktı) | En büyük dilim, kayıt riski |
| C3b | İmza değeri ve kapısı (Q'nun zarının tabanı). Aday kartında U sözcüğü, sektör cümlesi, en zayıf yer (Q yazar, C çizer). `market_ref` satırı Q'nun bugünkü tetikleyicisinde. PROBE'da kapı kaybı ve zar kaybı ayrı | aynı | aynı | xhigh / düşük / yüksek | 4 sa | §4.4 m.2; `run_gate`; görsel (`--sales-shot`) | Q'nun sözleşmesine dayanır |
| C4 | Kurumsal madde: takvim, −10, mailler, etiketler | aynı | aynı | xhigh / düşük / yüksek | 3 sa | §4.4 m.6; `run_gate` | Takvim ve mail |
| C5 | Yenileme, ayrıntı aşağıda | aynı | aynı | **max** / düşük / yüksek | 7 sa | §4.4 m.6; `plausibility`; `run_gate` | Akış ve kâğıt motoru |
| C6 | Genel Bakış'ın kalan blokları: Sürüm, Kararlılık, İstekler, İş. İstekler 3★'a daralır, söz kesintisi; 1★ ve 2★'ın açık istekleri cezasız düşer. PROBE'da istek kesintisi | aynı | aynı | **max** / düşük / yüksek | 4 sa | §4.4 m.7; `plausibility`; `run_gate`; görsel | UI kanunu |
| C7 | Haftalık destek raporu | aynı | aynı | xhigh / düşük / yüksek | 2 sa | §4.4 m.7; `run_gate` | Küçük |
| C8 | HESAPLAR tablosu | aynı | aynı | **max** / düşük / yüksek | 4 sa 30 dk | `run_gate`; görsel (330 satır) | UI ve ölçek |
| C9 | Maaş ×1,5, masa tavanı, Plaza şartı 10 kişi, ilk işe alımın taşınma akışı, İş hanı şartı (E1'in cevabı), botun taşınma politikası, `cash_spend` ve `cash_hoard` kolları, `PROBE DECISION`; tek commit | aynı | aynı | **max** / düşük / yüksek | 4 sa | §4.4 m.5; `run_gate`; görsel | Tavan botun taşınmasıyla aynı commit'te girer, yoksa koşu işe alamaz |
| E2 | **Erdem durağı:** §4.2 ve §4.3 ölçümleri: tohum 7 ve 11, B2B ve B2C, ek kollar. B2C'de 20 koşunun iflas sayısı ve nedeni. Tutmayan kapı ve önerisi | Alt ajan → Ana | Haiku koşar, Opus okur | düşük / orta | 2 sa | bot koşuları | Oynanış kapıları gerçek koşuyla |
| R | `RAPOR_C.md`: §9'un altı bölümü, ayrıntı aşağıda | Ana | Opus | orta | 30 dk | yok | D'nin tetiği |

Toplam ajan süresi yaklaşık 57 saat; E1 ve E2'deki bekleme hariç.

**C1 · Sunucu:**
- Kapasite oyuncuya geçer; sürümle gelen kendiliğinden büyüme silinir.
- Genel Bakış iskeleti (üç kâğıt, v1.0 kilidi, son açık kâğıdın hatırlanması) ve kademe seçicili Sunucu bloğu.
- Blokta Yük %, boş pay ve parası, büyüme satırı, sürüm satırı ve Otomatik ayarla anahtarı (eşik E1'den).
- Kademe fiyatları; bu iş PRD'de C2'deydi, C1'e geçti.
- `outage_load_mult` kurulur. Aşımın üç gizli etkisi ve bağlanmamış uyarı kartı silinir.
- Anahtar ve son otomatik büyüme `GameState`'te tutulur (`InfraSystem` kayda girmediği için).
- Botun varsayılan kapasite politikası; `server_lean`, `server_wide`, `server_auto` kolları ve PROBE'un sunucu alanları.

**C3a · Memnuniyet defteri:**
- Memnuniyet terimlerin toplamıdır; defter satırları kurulur, adsız destek zararı kalkar.
- B'nin çipi ve izleri deftere satır yazar; 13 `satisfaction_delta` kartı 8 haftalık satır olur.
- Güncelleme yaşı burada kurulur (PRD'de C3b'deydi).
- **Şema 19 ve tek göç.**

**C5 · Yenileme:**
- Satışçı ve kurucu yolu; koltuk sonuçları ve başka ürüne geçiş (oranlar E1'den).
- Sektör eğilimi, bütçe kesintisi ve kesinti tablosu.
- `market_ref` tetikleyicisi sözleşme kaydının açılışına taşınır.
- Yenileme sinyali kâğıdı silinir.
- PROBE'da yenileme sonuçları ve kâğıtlı ay sayısı.

**R · Rapor:**
- §9'un altı bölümü.
- D için ayrıca: kesinti tablosunun adı ve sırası, D'nin gönder sorusunu ekleyeceği yer, istek listesi verisi, düzeltme kartına
  giden yol, `PROBE DECISION` komutu.
- Haftalık kesinti bütçesi notu: bugünkü kayıt sprint başına tek yuvadır (`sprint_system.gd:564`).
- D'nin şartları (2026-10-18, oturumlar arası sözleşme): C6'dan sonra `SprintBridges.tick_requests`'in son hâli tek satır
  (imza, 3★ süzgecinin yeri, kesinti yolu); "C bitti" mesajı şemayı da yazar (`save_manager.gd:16`).
- **C9 askıda (2026-10-19, yardımcı yönetmenin bilgi notu):** Erdem kurucu evdeyken 1–2 uzaktan çalışan alabilmeyi istiyor;
  "masa = işe alım tavanı, evde 1 masa, ilk çalışan İş hanı" kuralıyla çelişir. Ofis şartı/seed zamanı/başlangıç kasası
  sorusu `docs/strateji/ANA_RESIM.md`'de Erdem'e gider. Karar gelene kadar C9 ve E1'deki İş hanı sorusu kesinleşmez;
  E1'de açık madde olarak durur.
- C0q'nun ek dosyaları (Q'nun Q0 haritasından): `sales_meeting_adapter`, `inbox`, `mail_pane`, `message_system`, `main`,
  `product_fixtures`, `sales_probes`, `sales_faucet_system`, `sales_archetypes`, `negotiation_system`, `seams_product`,
  `incident_system`, `game_state`, `data_models/customer.gd`, `launch_leak.json`, `password_rule.json`.

## Her commit'in akışı (C1 … C9)
1. **Sonnet kodlar.** Düşünme xhigh; C3a, C5, C6, C8 ve C9'da max. Girdi: PRD kararı, C0v adım eki, E1 kararları. Yeni smoke
   vakası yalnız §4.4'ün çekirdek mantığına yazılır ve falsification ile sınanır: kasıtlı bozulmada düşmeli.
2. **Haiku kapıları ön planda koşar,** sırasıyla:
   - `--event-lint` → `loc_residue` → `loc_csv_integrity`
   - hedefli smoke
   - adımın kapıları
   - UI adımında kareler: TR, EN, renk körü, 1,25 ölçek. Fikstürler HARITA'ya yazılır.
3. **Opus kıdemli inceleme:** yalnız diff ve kareleri okur, CLAUDE.md §9'un sorularını sorar. En çok bir düzeltme turunu
   kendisi yapar; Haiku kapıları bir kez daha koşar.
4. **Commit'i ana oturum yapar.**
   - Dosyalar açık listeyle eklenir; `project.godot`, tema farkı ve `docs/tasks/` girmez.
   - Mesaj `Faz C Cn: …`; gerekiyorsa "TR/EN onay bekliyor" ve "sabitler onay bekliyor".
   - Attribution satırları eklenir ve `git log -1` ile denetlenir. Faz A'da Haiku bu satırı değiştirmişti.
5. Commit kendi belge payını günceller: CLAUDE.md §6 (şema 19), HARITA fikstürleri, GUNCELLEMELER, sözlük, `_vocabulary.md`
   ve sinyal manifesti.
- Kapı yeşile dönmezse commit yapılmaz; ekran ve ölçümle sana dönerim.
- **Workflow betiği (senin onayına):** her adımı scratchpad'te duran bir `faz_c_step.js` yürütür (repoya girmez). Her
  `agent()` çağrısı modelini ve düşünme düzeyini bu tablodan alır.

## Kayıt (şema 19)
- 18'den 19'a göç yalnız C3a'da, bir kez yazılır. C3a başlarken `save_manager.gd:16`'yı okur; Q 18'i almadıysa raporda yazar.
- Göçün yaptıkları:
  - `trust_offset` defterde 4 haftalık tek satır olur.
  - `last_touch_day` göç günü olur.
  - `market_ref` Q'nun göçünden gelir.
- Sonraki adımlar göç koduna dokunmaz, yalnız göç vakası ekler:
  - Sözleşme bitişi `acquired_on_day`'den türer.
  - 1★ ve 2★'ın açık istekleri C6'nın kuralıyla düşer.
  - Otomatik ayar kapalı doğar, açık Kurumsal madde yoktur: ikisi de yalnız varsayılan değerdir. Göç bunları yazmaz, yoksa
    C1 ya da C2'de alınmış kayıttaki açık anahtarı ezer.
  - `burn_breakdown`'daki `tools` ve `service` yüklemede kendiliğinden düşer (`finance_system.gd:111-115`).
- Kanıt: göç vakaları; eski kayıt yüklendikten sonra nedensiz düşüş 0.

## E1'de onaya gelen sabitler (PRD'de "onay bekliyor" ya da işaretsiz)
1. **K1 · Sunucu düğmeleri:** adım birimin %10'u, en az 1 birim. Otomatik ayar: eşik %80, adım yükü yaklaşık %65'e indirir,
   küçültmez.
2. **K1 · Yük basamakları:** %90'a kadar 1,0; %90 ile %100 arası 1,5; %100 üstü ya da kapasitesiz 2,5.
3. **K1 · Büyüme satırı:** son 4 haftanın büyümesi, 1 ile 4 haftalık ufuk, %90 eşiği.
4. **K2 · Kademe fiyatları:** B2B 50 koltuk başına $60 / $120 / $240; B2C 1.000 kullanıcı başına $125 / $250 / $500.
5. **K3 · Taşınma ve İş hanı:** aday taşınma bitmeden işe başlamaz. İş hanı'nın Frank şartı kalır mı, yoksa kasada $6.500
   yeter mi.
6. **K4 · Kurumsal madde:** süre 8 hafta.
7. **K5 · Defter tutarları:**
   - Söz: zamanında +6 kalıcı, geç −3 (8 hafta), tutulmadı −12 (13 hafta).
   - İstek yayına girdi +4 kalıcı.
   - Kesinti 13 hafta, ertelenen hata 8 hafta, `satisfaction_delta` 8 hafta.
   - Durum terimleri: indirim +8, zam −2, gönülsüz yenileme −6, Kurumsal madde −10.
   - M5 tutmazsa hata terimi tavanı 62 ya da 64.
8. **K6 · Zar tabanı:** kapıyı geçen anlaşmada en az %60.
9. **K7 · Güncelleme yaşı:** 26 haftaya kadar 0, sonra her 4 haftada −1, en çok −12; ipucu 20. haftadan.
10. **K8 · Koltuk sonuçlarının oranları:**
    - Artış: taban %25 / 20 / 15; sektör ×1,25 / 1 / 0,75; eşik + 25 üstünde ×1,5; koltuk %10 ile %30 artar.
    - Azalış: %5 / 4 / 3; durağan sektörde ×1,5; koltuk %10 ile %25 azalır.
    - Başka ürüne geçiş: %1,5 / 1 / 0,5; Zayıf ×2, Güçlü ×0,5.
    - Sektör eğilimi 13 sektörde.
11. **K8 · Yenileme kuralları:**
    - Yıldız imzada sabittir.
    - Kesinti kuralı: ayda en çok 1 yenileme kâğıdı, kâğıtların birleşmesi, karşı teklif ertesi haftaya, haftalık bütçe 1,
      sıra, 2 haftalık süre.
    - Satışçı masası hesap başına 0,25 hafta.
12. **K8 ve K9 · Memnun hesap:** memnuniyet ≥ eşik + 12 (işaretsiz sayı).
13. **K12 · "Yetişemedim":** cevapsız bildirim, haftanın gelenlerinin beşte biri.
14. **§4.2 · Ek bot kolları:** `server_lean` (pay %5), `server_wide` (pay %40), `server_auto`, `cash_spend`, `cash_hoard`.
15. **Kapı hedef önerileri:**
    - M9 ve M13.
    - Risk 1: yenileme ≥ %90; 10 haftada 3 gerçek karar, yılda 15.
    - Risk 2: ilk işe alımda runway ≥ 6,7 ay; spend ile hoard arasında ≥ 6 hafta fark; B2C açığı ve net hedefleri.
16. **§3'ün bütün metinleri:** TR/EN onay bekliyor.

## PRD'den farklar (gerekçeli)
1. **C1, E1 sırasında yürümez.** PRD "C1 bu sırada ilerleyebilir" ve "C2 E1'i beklemez" diyor; senin talimatın "onaydan sonra
   C1". C1 ayrıca D'nin M'ini bekler (D PRD §8).
2. **C1 büyüdü.** Genel Bakış iskeleti, Sunucu bloğu, kademe fiyatları ve botun kapasite politikası C1'e geçti. Bugün sunucunun
   ekranı da botu da yok: bunlar olmadan C1'den C8'e kadar her koşuda kapasite 1 birimde takılı kalır, yük %100'ün üstünde
   olur, kesinti ×2,5 işler. C6 kalan dört bloğu ekler.
3. **Güncelleme yaşı C3b'den C3a'ya geçti,** göç tek yerde kalsın ve `sat_total_is_sum` tam formülü sınasın diye.
   `market_ref` bölündü: C3b satırı yazar, C5 tetikleyiciyi taşır.
4. **`run_gate` her adımda koşar** (PRD satır 14). `plausibility` C3a, C5 ve C6'da koşar. A'nın churn kapıları C3a'da yeniden
   kurulur (Q PRD satır 672).
5. **C0q eklendi.** Q'nun değiştirdiği ortak dosyalarda haritayı tazeler.
6. **E1'e bütün sabitler ve hedefler tek listede gelir;** kod onaylı değerle yazılır.
7. **W1'in kapsamı genişledi; mekanik denetimi W1'in çıkış kapısıdır,** ayrı adım değildir.
8. **Commit'i ana oturum yapar,** Haiku değil.
9. **PROBE alanları adımlara dağıtıldı;** `PROBE DECISION` C9'da kurulur. D bunu okur.

## Korumalar
- Ağır iş (`run_gate`, bot kolları, C0m, kareler) başlamadan çalışan süreçlere bakarım; sen oynuyorsan beklerim.
- Ekranlı Godot koşuları sırayla yürür; makinede aynı anda en çok 2 başsız Godot olur.
- `git checkout --` yok, worktree yok, push yok. Yalnız kendi değişikliğimi commit'lerim.
- Oyuncu metni TR ve EN birlikte ve tiresiz. Yeni Frank satırı yazılmaz.

## Doğrulama
- **Her commit:** adımın §4.4 vakaları yeşil; `--event-lint` ve `loc_residue` temiz; `run_gate`'in üç koşusu bir sonla biter ve
  sıfır `ERROR` taşır; UI adımlarında §4.6'nın kareleri alınır.
- **E2:** §4.2 kolları 104 hafta, tohum 7 ve 11 ile koşar: A'nın kolları ve `server_*`, `cash_*`. §4.3'ün oynanış kapıları ayrı
  tabloda.
- **R:** `RAPOR_C.md` ✅ / ⚠️ / ❌ ve kanıtla yazılır; son satır C'nin son kod commit'idir.
