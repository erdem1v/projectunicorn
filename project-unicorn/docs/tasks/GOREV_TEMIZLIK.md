# Görev: Genel temizlik, kıdemli kod incelemesi ve kod haritası

2026-10-23 · Yazan: yardımcı yönetmen (oturum `co-director`) · Erdem istedi: "D bittikten sonra, commitlendikten sonra
genel bir senior code review, kod temizliği, eski dosyaların temizlenmesi, alakasız PRD'lerin, projeyi şişiren
mockup'ların ve ekran görüntülerinin temizlenmesi; gereksiz kod satırı silinebilir; kod haritası güncel olsun."

## Başlama şartı

Tuttu (2026-10-26): Faz D kapandı (son commit `baa63da`, rapor `docs/tasks/faz_cde/RAPOR_D.md`), Ürün arayüzü U1s'te
durdu (`c71a691`); U2, Erdem A4 maketine bakana kadar başlamaz. Erdem görevi 2026-10-26'da aşağıdaki adım tablosuyla
onayladı; görev kendi oturumunda koşar, yardımcı yönetmen (`co-director`) başka işlerle meşgul.

**Aynı anda iki oturum daha çalışır** (Erdem 2026-10-26): Ürün arayüzü (`GOREV_URUN_ARAYUZU_DEVAM.md`) ve Olaylar
(`GOREV_OLAY_UYGULAMA.md`).

**Ortak çalışmanın bütün kuralları `docs/tasks/ORTAK_CALISMA.md`'dedir ve bu dosyadaki her kuralın önüne geçer.**
Kapsadıkları:
- sahiplik;
- kod kopyası, özel index'le commit;
- kapı, ekran ve ağır koşu kilitleri;
- APPDATA ve bellek;
- kayıt şeması ve `strings.csv`;
- HARITA'nın emekliliği;
- `docs/tasks/`'tan taşıma yasağı.

Bu görev için en önemlileri:
- Sahipli alanlarda yalnız adıyla verilen maddeler yapılır: C1, A7, B1, B2, `Chrome*`.
- C8, Ürün arayüzünün U7'sinden sonra yapılır.
- Son kapılar HEAD'in taze dışa aktarımında ve kendi APPDATA'nla koşar.

## Bugün (2026-10-26 ölçümü)

Proje klasörü 2,5 GB, `.git` 0,46 GB (23 Ekim'de 7,8 ve 5,0 GB'tan indi). Büyükler: `docs/tasks` 604 MB,
`assets` 587 MB, `docs/mockups` 550 MB, `.godot` 296 MB (önbellek), `docs/audits` 181 MB, `sandbox` 165 MB.
`scripts/` 246 `.gd` dosyası, 109 bin satır (`endgame_smoke.gd` 27,8 bin, `main.gd` 5,4 bin).

## Adım tablosu (Erdem onayı 2026-10-26)

| # | Ne | Kim / model | Süre | Commit |
|---|---|---|---|---|
| 1 | Envanter: klasör × dosya türü × izlenen/izlenmeyen × boyut × kim okuyor (adıyla okuyan belge ya da kod) | Haiku, low | 30 dk | yok |
| 2 | Üretilmiş dosyalar gider; biten PRD, görev ve raporlar repodan çıkar (aşağıda İş 1) | Sonnet, high | 45 dk | Temizlik 1 (belge, inceleme yok) |
| 3 | Okunmayan asset'ler (`.import` eşiyle) | Sonnet, high; import + `all_scripts_load` Haiku | 45 dk | Temizlik 2 |
| 4 | İnceleme raporu §3a A1–A8 | Sonnet xhigh kodlar, Opus high inceler | 3 sa | konu başına |
| 5 | §3b B1–B6 (B7 yok); B3 ve B6 görsel kabulle | Sonnet xhigh, Opus high | 3 sa | konu başına |
| 6 | §3c C1, C4–C9 | Sonnet xhigh, Opus high | 3 sa | konu başına |
| 7 | Ek notlardaki iki harness hatası ve okunmayan `Chrome*` varyasyonları | Sonnet xhigh, Opus high | 1,5 sa | konu başına |
| 8 | `scripts/` ölü kod taraması (İş 2) | Haiku aday listesi, Sonnet xhigh doğrular ve siler, Opus high inceler | 4–6 sa | sistem başına |
| 9 | Kod haritası ve HARITA geçişi (İş 3) | Sonnet, high | 1 sa | Temizlik n |
| 10 | Son kapı: `bash tools/run_gate.sh`, `--headless --import`, `all_scripts_load` | Haiku, low | 1,5 sa | yok |
| 11 | Rapor ve `.git` geçmişindeki büyük dosyaların ölçümü | ana oturum | 30 dk | yok |

Yardımcı yönetmenin kararları (2026-10-26):
- **8. adım okyanus değil göl olur.** 109 bin satır satır satır okunmaz. Aday listesi `docs/kod_haritasi/SEMBOLLER.tsv`'den
  ve grep'ten çıkar: çağıranı olmayan fonksiyon, sabit, alan, sinyal; okunmayan CSV anahtarı; yoruma alınmış kod; debug
  `print`. Yalnız adaylar doğrulanır (dinamik çağrı kuralları İş 2'de). Sistem başına tek commit, tek inceleme.
- **C2 ve C3:** önce U1'e (`29ae999`) girip girmediğine bak (K02 U1'de yapıldı; K13 ve K14 U1'e katılacaktı). Girdiyse
  raporda "U1'de yapıldı" yaz; girmediyse Ürün arayüzü işine kalır, burada yapılmaz.
- **`sprint_catalog.gd:921` `_suggest` hatası** U1'de artık görülmedi (`--product-shot=live:plan` temiz). Önce yeniden
  üret; oluşmuyorsa raporda "artık yok" yaz, kod yazma.

## İş

**1. Dosya envanteri ve temizlik.** Her büyük klasörü dosya türüne göre çıkar (izlenen ya da izlenmeyen, boyut, son
değişiklik, kim okuyor). Sonra:
- Üretilmiş dosyalar silinir: ekran görüntüleri, maket kareleri, loglar, `.status`, `appdata*` kopyaları, simülasyon
  çıktıları, ölçüm dökümleri. Bugün yürürlükteki bir belgenin (CLAUDE.md, HARITA, kod haritası, GDD, açık PRD) adıyla
  okuduğu dosya kalır.
- Biten fazların çalışma klasörleri (`faz_ab`, Q, C'nin park edilmemiş taslakları, D bittiyse `d_taslak`'ın üretilmiş
  kısmı) ve işi biten PRD'ler, görev yazıları, raporlar repodan çıkar (CLAUDE.md §8: "İş bittiğinde rapor, plan ya da
  ölçüm dosyası repoya konmaz"). Erdem'in 23. kararı: faz PRD'leri repoya alınmaz; izlenenler `git rm --cached` ile
  çıkar ve `.gitignore`'a girer, yerelde kalır.
- **Kalır** (2026-10-26 eki):
  - `docs/tasks/GOREV_*.md`;
  - `ORTAK_CALISMA.md`;
  - `PRD_OLAY_MOTORU_V3.md`;
  - ileride yazılacak `RAPOR_URUN_ARAYUZU.md`.

  Paralel dönemde `docs/tasks/`'tan arşive yeni taşıma yapılmaz.
- **Kalır:** `ERDEM_KARARLAR_2026-10-20.md`, açık işlerin PRD'leri (PRD_FAZ_D, ADIM_TABLOSU_D_v2, PRD_URUN_SPRINT_ARAYUZU,
  GOREV_URUN_ARAYUZU, park edilen C adımlarının PRD'si), `docs/strateji/` (yayınlanmış sayfaların kaynakları),
  Pazar 2 sentezi ve Erdem'e açık sorular taşıyan her belge, `docs/ACIK_ISLER/`, `GDDs/`, `docs/writing/`, `docs/content/`.
- `docs/mockups/menajer`: Menajer tasarım dilinin kaynağı olan HTML ve tasarım dosyaları kalır, render PNG'leri ve
  aday klasörleri gider. Hangi kare bir belgede adıyla geçiyor, önce bak.
- `assets/`: hiçbir sahne, script ya da `data/` dosyasının okumadığı asset silinir (Godot `.import` eşiyle birlikte).
  GDD'de adı geçen ama henüz bağlanmamış asset kalır (CLAUDE.md §2).
- `sandbox/`: ne olduğunu çıkar; oyunun okumadığı deneme çıktısı gider.
- İzlenen dosya `git rm` ile gider (geçmişte durur). İzlenmeyen ve elle yazılmış (yeniden üretilemez) belge silinmez:
  `C:\Users\erdem\Desktop\Unicorn_arsiv\2026-10-26\` altına klasör yapısıyla taşınır. İzlenmeyen üretilmiş dosya silinir.
- Başka oturumun commit'lenmemiş değişikliğine dokunma; `git checkout -- <yol>` kullanma.
- `.git` geçmişini yeniden yazma (filter-repo, force push) bu görevin işi değildir: hangi dosyaların geçmişte ne kadar
  yer tuttuğunu ölç ve kazancı rapora yaz; karar Erdem'in.

**2. Kıdemli kod incelemesi ve temizliği.** `scripts/` baştan sona, sistem sistem (kod haritası `sistemler/`
sırasıyla). Ölçüt CLAUDE.md §8 ve §9; başlangıç listesi `docs/kod_haritasi/KALITE.md`. Bulunacaklar: çağıranı olmayan
fonksiyon, sabit, alan, sinyal; okunmayan CSV anahtarı; aynı işi yapan ikinci yardımcı; tek yerde kullanılan
sarmalayıcı; imkânsız durum için savunma; tarihçe ya da kodu tekrar eden yorum; yoruma alınmış kod; debug `print`.
- Silmeden önce her çağıranı ara (GDScript dinamik çağrılarına dikkat: `call`, `has_method`, sinyal adları dizesi,
  smoke vakalarının kaynak okuması, sahne dosyalarındaki bağlantılar). GDD'de adı ya da kuralı geçen bağlanmamış kod
  silinmez (CLAUDE.md §2). Kayıt alanı silinirken eski kayıt yüklenmeye devam etmeli (SaveCodec).
- Davranış değişmez. Bir bulgu davranışı değiştirecekse (hata düzeltmesi dahil) yapılmaz, rapora yazılır.
- Smoke ve probe paketinin yeniden yazımı ayrı görevdir; burada yalnız çağıranı kalmamış debug kodu gider.

**3. Kod haritası.** Temizlik bittikten sonra `python -I tools/kod_haritasi/uret.py`; sistem sayfaları silinen ve
taşınan kodla güncellenir. `docs/kod_haritasi/HARITA_GECIS.md`'deki geçiş (D'nin adımlarından sonra yapılacaktı) bu
görevde yapılır: CLAUDE.md'nin harita atıfları kod haritasına döner, `docs/HARITA.md` emekli olur. Geçişi Ürün arayüzü
oturumuna tek mesajla bildir (onun görevi iki haritayı da güncelliyordu).

## Çalışma kuralları

- Model: envanter ve boyut ölçümü Haiku; silme ve kod değişikliği Sonnet (yüksek düşünme); her commit'in diff'i Opus
  kıdemli gözle incelenir (yalnız diff). Commit başına en çok 1 inceleme ve 1 düzeltme.
- Commit'ler küçük ve tek konulu: `Temizlik n: <ne>`. Kod commit'lerinde dokunulan sistemin smoke vakaları ve ortak
  kapılar (CLAUDE.md §12 sırası: event-lint, loc_residue, loc_csv_integrity) yeşil olmadan commit yok. Sonda bir kez
  `bash tools/run_gate.sh` (üç koşu) ve `--headless --import` sonrası `all_scripts_load`.
- **Push yok.**

## Bitince

Erdem'e rapor sayfası (artifact) ve yardımcı yönetmene (`co-director`) kısa haber; rapor repoya konmaz: klasör klasör önce/sonra boyut, silinen ve arşive taşınan dosya sayıları,
commit listesi, silinen kod satırı sayısı sistem başına, davranış değiştireceği için yapılmayan bulgular, `.git`
geçmişindeki büyük dosyalar ve yeniden yazımın kazancı, kapıların sonucu.

## Ek notlar

- Krem temanın `ChromeValue`, `ChromeClock`, `ChromeAlert` varyasyonlarını hiçbir sahne ya da script okumuyor (TopBar ve
  NewsTicker koyu temayı okuyor; Ürün arayüzü U0 bulgusu). Okuyucusuz tema varyasyonu olarak silinir; CLAUDE.md §7'nin
  Chrome kuralı bugünkü gerçeğe göre yeniden yazılır. Temaya dokunan adım, Ürün arayüzü oturumunun tema commit'leriyle
  çakışmasın diye onun U0'ı bittikten sonra ve "kapı bende" ile yapılır.
- Son haftanın kod incelemesinin doğrulanmış bulguları ve düzeltme planı:
  `C:\Users\erdem\AppData\Local\Temp\claude\C--Users-erdem-Desktop-Project-Unicorn\1eb70ce4-b7b7-4a33-a29b-4043e7472f47\scratchpad\kod_inceleme\RAPOR.md`.
  Davranışı değiştirmeyen bulgular bu görevde uygulanır; davranış değiştirenler Erdem'in onayını bekler.
- Kod incelemesinin uygulanışı (yardımcı yönetmenin kararı, 2026-10-23): RAPOR §3a (A1–A8) uygulanır. §3b'deki hatalar
  (B1–B6) da uygulanır: davranışı oyunun yazılı kuralına ve Erdem'in kararlarına geri döndürüyorlar (masa tavanı, karar
  kapısı, çipin uygulananı yazması, gece notları); tasarım sabiti değiştirmiyorlar. B2'de düzeltme lint'le aynı dili
  konuşan koldur (`amount_seam` varken `amount_mult`'un işaretine bakılır). B7 yapılmaz (bayrak D3'te kalkıyor).
  §3c (C1, C4–C9) D bittikten sonra; `sprint_system.gd` Ürün arayüzü oturumuyla ortak, "kapı bende" ile. C2'nin
  `product_model.gd` parçası ve C3 (K13, K14) Ürün arayüzü oturumuna verildi, burada yapılmaz.
- Ürün arayüzü U0'ın bulduğu, U0'dan önce de var olan iki hata (HEAD'de de): Ürün sekmesi kare kurulumunda
  `sprint_catalog.gd:921` `_suggest` "Invalid access to 'sprint'"; `--inbox-shot=flow` 1,25 ölçekte 8. adımda
  `main.gd:1409` "Out of bounds". İkisi de kök nedeniyle bulunur; oyuncu yolunda da oluyorsa hata düzeltmesi olarak
  uygulanır. `docs/mockups/menajer/screens/ana_menu/tools/lockup.py` artık olmayan `assets/fonts/cond/` yolunu okuyor:
  `tools/brand/make_lockup.py` ile aynı işi yapıyorsa eski araç gider.
  `docs/mockups/menajer/screens/urun/tools/gen.py:1180` Ut'den sonra silinen `PROD_TYPE_STEP_TITLE`'ı okuyor ve eski iki adımlı
  tür seçicisini çiziyor: maket aracı hâlâ lazımsa o satır düzeltilir, değilse araç maket kaynağı kuralına göre değerlendirilir.
