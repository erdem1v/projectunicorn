# Kod haritası · giriş

Yollar `project-unicorn/` köküne göredir; komutlar oradan koşulur. Her satır en çok 240 karakterdir, grep çıktısı kısa kalır.

## 1. Nedir, ne zaman kullanılır

- Kod tabanının aranabilir dizinidir: hangi dosya ne yapar, hangi sembol nerede tanımlı, hangi sinyali kim yayar ve kim dinler, bir sistemi değiştirirken neye dokunulur.
- KOD ARAMADAN ÖNCE buraya bak. Önce soruya uyan dosyayı grep'le, sonra yalnız gösterdiği `yol:satır`ı aç. Tam dosya okuma ve depo çapında tarama son çaredir.
- Harita yön gösterir, kanıt değildir: satır numaraları üretildiği ağaca göredir (başlıktaki git sha). Düzenlemeden önce hedef satırı kaynakta doğrula.

## 2. Nasıl kullanılır

| Soru | Dosya |
|---|---|
| X sembolü (func, var, const, signal, class) nerede tanımlı? | `SEMBOLLER.tsv` (sütunlar: sembol, tür, yer, sınıf) |
| Bu dosya ne kadar büyük, sınıfı ve tabanı ne? | `DIZIN.md` "Dosyalar" |
| Bu sinyali kim yayar, kim dinler? | `DIZIN.md` "Sinyaller"; olay motoru izin listesi `sistemler/07_olay_motoru.md` |
| Sahnenin kök betiği, JSON'un üst anahtarları, metin anahtarı ailesini kim okur? | `DIZIN.md` "Sahneler", "Veri dosyaları", "Metin anahtarı aileleri" |
| Bir sistemin giriş noktaları, durumu, testleri, tuzakları, değişiklik listesi? | `sistemler/NN_*.md` |
| Temizlik ve denetim için aday listesi? | `KALITE.md` |

Örnek komutlar (Git Bash; `-P` için `LC_ALL` şart, yoksa "unibyte" hatası verir):

```
LC_ALL=C.UTF-8 grep -P "^reflect_mrr\t" docs/kod_haritasi/SEMBOLLER.tsv          # sembolün tanımı
awk -F'\t' '$1=="reflect_mrr"' docs/kod_haritasi/SEMBOLLER.tsv                    # aynısı, -P'siz
awk -F'\t' '$4=="SalesSystem" && $2=="func"' docs/kod_haritasi/SEMBOLLER.tsv       # bir sınıfın fonksiyonları
grep -E "^- customer_churned\(|↳ customer_churned (emit|connect):" docs/kod_haritasi/DIZIN.md   # sinyalin yayanı ve dinleyeni
grep "sales_system.gd ·" docs/kod_haritasi/DIZIN.md                                # dosyanın satır, sınıf, func sayısı
grep -l "SprintSystem.start" docs/kod_haritasi/sistemler/*.md                     # sembol hangi sistem sayfasında
grep -n "^## " docs/kod_haritasi/sistemler/02_urun_sprint.md                       # sistem sayfasının bölümleri
```

- Claude Code Grep aracında sembol deseni `^reflect_mrr\t`, yol `docs/kod_haritasi/SEMBOLLER.tsv`.
- Sinyal satırı uzunsa yerler alt satıra `  ↳ ad emit:` / `  ↳ ad connect:` diye taşar; bu yüzden desen iki biçimi de arar.
- Eşleme ada göredir (tür çözümü yok): iki sınıfta aynı adlı fonksiyon ikisini de döndürür, sınıf sütunuyla süz.
- Sistem sayfalarının bölüm sırası sabittir: Dosyalar · Giriş noktaları · Sinyaller · Durum ve veri · Metin anahtarları · Testler · Dikkat · Bir değişiklik yaparken.

## 3. Sistemler

- `sistemler/01_cekirdek.md`: autoload'lar, GameState, TimeManager ve günlük/saatlik dağıtım sırası, kayıt ve göç, ayarlar, dil, ses, ekran, `main.gd`/`game_shell.gd` kökü. Zaman, kayıt, yeni alan, yeni ayar.
- `sistemler/02_urun_sprint.md`: sprint motoru, ürün hatları ve kademeler, kalite, hata deposu, sunucu, gecenin acil durumu, Ar-Ge. Sprint, kart, sürüm, kâğıt, söz olayı, `sprint.json`.
- `sistemler/03_satis_b2b.md`: lead şelalesi, satış görüşmesi ve pazarlık, satış masası, imza, B2B hesap yaşam döngüsü, müşteri masası, Destek, B2C kitle. Müşteri, MRR, churn, söz.
- `sistemler/04_ekip.md`: HR tik sırası, Atlas araması, aday üretimi, moral, izin, eğitim, mesai, kurucu becerileri ve huyları, görünüş. Kişi alanı, HR sayısı, çalışma saati.
- `sistemler/05_fon_finans.md`: kasa ve burn, Frank'in çeki, faz kapısı, seed ve Series A görüşmesi, term sheet, sonlar, rakipler, Piyasa, haber şeridi, mesaj ve teslim saati, beceri zarı.
- `sistemler/06_ofis.md`: ofis merdiveni ve taşınma, 3B ofis görünümü, kişiler, şehir haritası, toplantı yolculuğu ve davet, ofis dışa aktarım hattı. Ofis, 3B sahne, kişi animasyonu.
- `sistemler/07_olay_motoru.md`: `EventGate`, `Ev*` sınıfları, kapı G1-G8, kuyruk ve masa, etki fiilleri, seam'ler, sinyal izin listesi, kart JSON şeması, lint ve sözlük araçları. Kart ve olay.
- `sistemler/08_sekmeler.md`: `scripts/tabs/` pencereleri (Ürün, Satış, Ekip, Finans, Yatırım, Piyasa, Kişisel, Ar-Ge, Olaylar), sekme sözleşmesi, kalabalık kadroda tablo düzeni. Sekme arayüzü.
- `sistemler/09_arayuz_bilesen.md`: UiTokens, UiFactory, tema üretimi, TopBar, sol ray, pencere katmanı, modallar, ana menü, onboarding, görüşme paneli, portre ve avatar. Ortak UI ve tema.
- `sistemler/10_test_harness.md`: smoke süiti, `--run-log` probe, sprint/tempo/tick/render probe'ları, `--*-shot` ailesi, kabuk kapıları, `tools/`. Test koşmak ya da harness eklemek.
- Bir dosya birden çok sayfada geçebilir: ana anlatım "Dosyalar" bölümünde ayrıntılı satırı olan sayfadadır, öbürleri "Dışarıda ama ayrılmaz" ya da "Komşu" diye yalnız anar.

## 4. Kod incelemesi ve temizlik

- `KALITE.md` yalnız `scripts/` altını kapsar (tools/ hariç). Her liste bir başlangıç noktasıdır, hüküm değildir.
- "En büyük 25 .gd" ve "80 satırdan uzun fonksiyonlar": bölme ve sadeleştirme adayları; `endgame_smoke.gd` ve `main.gd` harness'leri listeyi doldurur, oyun kodunu ayrı değerlendir.
- "Ölü kod adayları": tanım dışında adı hiç geçmeyen func. YANLIŞ POZİTİF OLABİLİR: `call("a"+b)` ile kurulan ad, sinyale adla bağlama, harness bayrağı, `tools/*.sh`, GDD'de adı geçen bağlanmamış kod.
- Ölü adayı silmeden önce: depo çapında `grep -rn "ad" scripts scenes data tools` koş, CLAUDE.md §2'ye bak (GDD'de adı geçen bağlı olmayan kod silinmez), sonra ilgili sistem sayfasının "Dikkat" bölümünü oku.
- "Yarım sinyaller": emit ya da connect'i bulunamayan sinyal. Dizi içi bağ (`_signals = [EventBus.a, ...]`), `await x.ad` ve olay motoru izin listesi (`EvSignals.BINDINGS`) connect sayılır;
  ↳ `bind(sig)` ile değer olarak geçip değişkenden yayılan sinyal (ör. `confirm_modal.gd` `alt_selected`) yanlış alarm verir.
- "Birden çok dosyada tanımlı const": aynı ad, kopya değer ya da yalnız ad çakışması olabilir; tek evi olması gereken sayıyı (CLAUDE.md §3 tek ayar sabiti kuralı) bulmak için oku.
- Kıdemli inceleme sırası: diff'teki dosyanın sistem sayfası "Dikkat" ve "Bir değişiklik yaparken" → aynı işi yapan mevcut yardımcı (`SEMBOLLER.tsv`'de ad ara) → KALITE listeleri.
- Sistem sayfalarının "Dikkat" bölümleri kodda bulunmuş tuzakları (sıra sözleşmeleri, tek yazıcı kuralları, kolsuz fiiller, ikiz sabitler) taşır; inceleme notunu tekrar keşfetmek yerine oraya bak.

## 5. Bakım kuralı

- `DIZIN.md`, `SEMBOLLER.tsv` ve `KALITE.md` ELLE DÜZENLENMEZ. Betikle üretilir: `python -I tools/kod_haritasi/uret.py` (10 saniyeden kısa, yalnız okur, yalnız bu klasöre yazar).
- Üretici diskteki hâli okur (kirli ağaç dahil) ve başlığa git sha ile tarihi yazar. `.gd`, sahne, sinyal, `data/` JSON ya da CSV anahtar ailesi değişen commit'ten önce yeniden üret.
- `sistemler/*.md` elle yazılır. Bir sistemin giriş noktasını, sinyalini, durumunu, kayıt şemasını, tik sırasını ya da kuralını değiştiren commit, o sistemin sayfasını AYNI commit'te günceller.
- Sistem sayfasında yeni dosya açan commit onu "Dosyalar"a satır sayısıyla ekler; silinen dosyanın ve sembolün satırları silinir. Tarihçe yazılmaz (CLAUDE.md §8), yalnız bugünkü durum.
- Başvuru biçimi: `` `Sınıf.fonksiyon()` `yol/dosya.gd:satır` ``; aynı dosyada sonraki başvurular `` `:satır` ``. Dosya yolu tam yazılır ki grep bulsun.
- Satır en çok 240 karakter; uzun madde `  ↳ ` ile alt satıra taşınır. Denetim: `awk 'length>240' docs/kod_haritasi/sistemler/*.md` (Git Bash awk bayt sayar; Türkçe harf 2 sayılır, şüphede Python ile say).
- Bir sistem sayfası başka sayfanın konusunu ayrıntılı anlatmaz, dosya adıyla oraya gösterir (örnek: "ana anlatım 05_fon_finans.md").
- Sayfa kodla ya da CLAUDE.md ile çelişirse çelişkiyi fark eden commit çözer: sayfa bugünkü kodu, CLAUDE.md kuralı söyler; kaynağa bakılır, yanlış olan düzeltilir.

## 6. Alt ajan görev yazısı

- Görev yazısına ilgili sistem dosyasının adını ve gereken `yol:satır` başvurularını koy. Örnek: "Bağlam: `docs/kod_haritasi/sistemler/03_satis_b2b.md` Giriş noktaları ve Dikkat;
  ↳ düzenlenecek yer `scripts/systems/b2b_sales_system.gd:146` (`satisfaction_target`), çağıranlar `sales_tab.gd`, olay çipleri."
- Ajan önce o sayfayı ve verilen satırları okur; depo çapında keşif yalnız sayfada cevap yoksa yapılır ve ne arandığı rapora yazılır.
- İnceleme ajanına diff ile birlikte dokunulan sistemlerin sayfa adlarını ver; "Dikkat" ve "Bir değişiklik yaparken" listeleri inceleme kontrol listesidir.
- Temizlik görevine `KALITE.md`'nin ilgili bölümünü ve aday satırlarını aynen ver; ajandan her silme için "adın başka yerde geçmediği" grep kanıtını iste.
- Görev sistemi değiştiriyorsa görev yazısı "sistem sayfasını ve gerekirse `uret.py` çıktısını aynı commit'te güncelle" maddesini taşır.
