# PRD · Yazar Ajanı v2 · 100 olay, 9/10 çıtası

**Kim çalıştırır:** bir yazar ajanı oturumu (Claude Code), ayrı bir cihazda, motor PRD'sini içeren push'un taze klonundan;
sahibin makinesinde koşarsa klonsuz, salt okunur `git -C <repo> show <sha>:./<yol>` yoluyla (§2). Başlatma cümlesi:
"project-unicorn/docs/tasks/PRD_YAZAR_AJANI_V2.md dosyasını oku ve uygula." Entegrasyon ayrı bir turdur: sahibin
onayından ve motor PRD'sinin (C oturumunun ikinci parçası) `main`'e inişinden sonra, sahibin makinesinde (§2.1, §13).
**Durum:** yardımcı yönetmen taslağı, 2026-10-10. Sahibin bugünkü olay kuralları (OWNER_RULES 1-8) ve 2026-10-08 şık
kuralları bağlayıcı. Kart şeması v3 `docs/tasks/PRD_OLAY_MOTORU_V3.md` §2'de yazılı ama motorda HENÜZ YOK; K1-K5
varsayımları onay bekliyor (§0). Kod okuması HEAD `124e54b`; bulgu doğrulaması HEAD `87530c0`.
**Tek cümle:** yazar önce oyunu ve motoru öğrenir ve bunu bir sınavla kanıtlar; sonra evre-kadro bantlarına dağılmış
yaklaşık 100 kartı gerçek kurucu hikâyelerinden, yalnız uygulayıcısı ve çipi olan 30 fiille, makullük bloğu dolu
şema v3 JSON olarak önce EN sonra TR yazar; her kart yedi ölçütün her birinde kör eleştirmenden en az 9 alır, almazsa
en çok iki kez yeniden yazılır, sonra düşer.
**Çıktı:** repo DIŞINDA `C:\Users\erdem\Desktop\unicorn_writer_v2\` (pilotun düzeni): `cards.json`, `strings_draft.csv`,
`review.html` (özel artifact, işaret veritabanlı), `INDEX.md` (kart başına kaynak ve yedi puan), `MOTOR_ISTEKLERI.md`,
`_tools/cardcheck.py` (şema v3). Repo'da tek bayt değişmez; git yazma komutu ve Godot koşusu yok.

Kanıt: `OWNER_RULES_EVENTS_2026-10-10.md` (yardımcı yönetmen klasöründe; içeriği §0'da), motor PRD'si (§2 şema, §4 fiiller,
§5 göç ve aileler, §8 sabitler), `EVENT_TIMING_ONERI.md` + `audit/ours/paradox/verify-*.md` (özeti motor §0, R11), pilot
`Desktop/unicorn_writer_pilot/` (`INDEX.md`, `_context/`, `_tools/cardcheck.py`). `docs/writing/OLAY_YAZIM_YONTEMI.md` yok.

---
## 0. Sahip kararları ve bulgu → gereksinim
**Bağlayıcı (OWNER_RULES 1-8, 2026-10-08):**
- OR 1: deste "çok çok kötü" (saçma şık, işe alım başına tekrar, evreye uymayan kart, oyunu bilmeyen yazar).
  OR 2: evre ve kadro ayrımı; başlangıç = ürün, araştırma, sprint, kurucu; çalışan olayı ancak çalışan varken; "1-2
  çalışan" sonraki kadrodan ayrı bant; demoda Series A, yatırımcılar, B2B, B2C; her kart evre ve kadro bandını taşır.
- OR 3: aynı olay her işe alımda gelemez; aile özne başına bir kez VE uzun bekleme. OR 4 (+2026-10-08): şık gerçek hamle,
  bedel özneye, bedava çıkış yok, tek kişilik olayda sprint saati yok, dünyayla çelişmez (ofis fiziksel, kurucu eğitmen
  değil, pazarlama demoda yok). OR 5: yalnız kollu ve çipli fiil. OR 6: ateşlenme kıdem, modül, evre, ürün, hafta
  tabanıyla, pencere içinde; aile arka arkaya gelmez; ilk haftalar korunur. OR 7: ~100 olay, çıta 9/10 (yedi madde);
  asgari çalışansız bant 10-15, her evre ≥ 20, "1-2 çalışan" ayrı. OR 8: kod tabanını okumadan yazılmaz; çıktı repo
  dışına; entegrasyon ayrı turda sahibin makinesinde. Demo penceresi 0-130. hafta (BRIEF §9b.8).

**Çalışma varsayımları (motor §0 K1-K5; onay bekliyor, INDEX'te ⚠️):** K1 belirlenimci gecikme (`delay_weeks` her kartta)
· K2 pazarlama şıkları demoda kilitli, dünya teklifleri kitle/nakit tabanıyla · K3 para isteyen çalışan kıdemi 26 · K4
global koruma 3 hafta · K5 makullük bloğu lint'te hata. Reddedilen varsayımda alan yine yazılır, motorun geri dönüşü işler.

**Bulgu → gereksinim:**

| Bulgu (kanıt) | Gereksinim |
|---|---|
| Pilotun 18 kartı 7,0 ağırlıklı kapıdan 7,18-7,75 ile geçti (pilot `INDEX.md` §2-3); sahip yine de desteyi "çok çok kötü" buldu, ret sebebi şıklar ("ne alaka", BRIEF §9c.1) | Y7 (her ölçüt ≥ 9, çapa kartlar, denetim merceği) |
| Yazarlar oyunu bilmeden yazdı (OR 1, 8); pilot bağlamı yalnız 10 GDD metni ve BRIEF'ti (`_context/gdd/`) | Y1 (zorunlu okuma + sınav) |
| `bootstrap_solo`'da ürün öncesi 8 kart (4'ü not); `bootstrap_team`'de çalışan öznesi taşıyan hikâye kartı 3 (motor PRD'si §5 sayım satırı) | Y2 (matris) |
| `team.first_weeks` (`newest_hire`, özne başına `one_shot`) her işe alımda, kurucuyu eğiten "Birkaç gün yanında otur" şıkkıyla (`strings.csv:2936-2940`; motor PRD'si E1) | Y3 aile kuralları, Y5 dünya kuralı |
| Eşik ateşlenme tarihi: `conference_trip` 2/2 koşuda tam kıdem 12'de (motor PRD'si §0) | Y3 (`subject_tenure_weeks`, `delay_weeks` zorunlu) |
| `_vocabulary.md` 63 fiil listeler; 30'u yazar fiili, 18 ayrılmış, 15 yazılamaz (motor PRD'si §4); motorun lint'i yalnız üyelik sorar (`lint.gd:220-223`) | Y4, Y8 |
| 30 fiilin 4'ü çipsiz (`chips.gd:20-24` `SILENT_VERBS`); 9'u bağlam dışında sessizce no-op ya da yan etkili, çip yine basılır (ör. `morale_all` kadro 0'da, `effects.gd:353-356`; `add_prospect` yalnız canlı B2B'de, `sales_faucet_system.gd:46-47`) | Y4 bağlam tablosu (§6.2) |
| `employee_hired` + `latch_key: entity` + `one_shot` = özne başına bir mandal (`latches.gd:9-11`, `:35-38`): `first_weeks` deseni | Y3 kural 4 |
| Pazarlama sekmesi demoda kilitli (`ui_tokens.gd:300` `{"id":"marketing","lock":"ea"}`) ama iki kartın şıkkı pazarlama harcıyor (motor PRD'si F4, F5) | Y5 dünya kuralı; iki şık §4'te yeniden yazılır (hüküm E5) |
| Memnuniyet deltası hedefe haftada 21 puana kadar geri çekilir (BRIEF §9b.5) | Y5 modifier kuralı |
| Pilot 18 kart için 47/60 WebSearch harcadı; 92 aday topladı, 54'ü ayıklamadan geçti, 18'i kullanıldı (pilot `INDEX.md` §1) | Y6 (pilot adayları + HN Algolia; bütçe 60) |
| Canlı destede modifier aralıkları (HEAD `data/events/cards/**` taraması, §6.3) | Y4 orantılılık tablosu |

### 0a. Brief'ten farklar (kodla ya da depoyla çelişen ifadeler)

| İfade | Bugünkü gerçek (kanıt) | Bu PRD'de |
|---|---|---|
| "GDD ch01-ch14" | v2 setinde 04, 05, 07 yok (`GDDs/README.md:42-43`); satış → Satış GDD, ekip → Ekip GDD | Okuma listesi var olan 11 bölüm + 3 modül GDD'si (§3) |
| "60 fiilden 49'u kollu" (OR 5) | HEAD'de 63 listeli; 30 yazar fiilinin 30'unun `effects.gd` kolu var; `chips.gd`'de 26'sı etiketli, 4'ü `SILENT_VERBS` (`:20-24`) | Yazar kümesi 30; sessiz 4 ne bedel ne kazanç (§6.1) |
| "Şemanın olduğu commit'i klonla" | `PRD_OLAY_MOTORU_V3.md` ve bu PRD izlenmiyor (`git status`: `??`), uzakta yok; yazar klonu motor PRD'sini içeren push'tan alınır | Ön koşul: sahip iki PRD'yi commit'letir ve "push et" der (§2.2); sha o push'un `origin/main`'i (§2.3) |
| Pilot çıktıları "okunur" | `Desktop/unicorn_writer_pilot/` repo dışında; başka makinede yok; `cardcheck.py:19` REPO sabit, `:20` OUT `PILOT_OUT`'tan | Pilot paketi taşınır ya da F0'da yeniden üretilir; yollar ortam değişkeni (§2, §10) |
| Şema v3 alanları "her kartta dolu" | Motor v3'ü okumuyor; bugünkü katalog bilinmeyen alanı yok sayar, makullük derlenmez (motor PRD'si R1) | Yazar v3 yazar; entegrasyon motor (V0-V8) `main`'e indikten sonra (§13, hüküm E7) |
| "Tek kişilik olayda sprint saati yok" | Motor O3 bunu istisnasız koyar: her tek kişilik kartta, kadro `[0,0]` dahil; canlı `side_contract`, `meetup_talk`, `lead_overtime` bugün `sprint_hours` taşır, motor R11 siler | Yazar kartında O3 motorla aynı, yerine `productivity_mod scope: founder` (§6.2); `lead_overtime`'ın kazancı §4'te yeniden yazılır (hüküm E2) |
| Sahibin yedi kalite maddesi (OR 7) | Görev altı ölçüt istiyordu | Yedi ölçüt; "dünyadan gerçek olay" ayrı ölçüt (6), kaynaksız kart düşer (§9) |
| `marketing_push` "modül kilidiyle" yazar fiili | Demo build'de kilit hiç açılmaz; kilitli şık demo boyunca ölü kalır | Demo kartında `marketing_push` yok; yalnız `version_scope: ea` (§6.2) |
| Araştırma raporu okuma listesinde | `EVENT_TIMING_ONERI.md` yardımcı yönetmenin geçici klasöründe, depoda yok | Özeti motor PRD'si §0 ve R11'den okunur |

## 1. Bu oturumun kuralları
- **Repo yalnız okunur.** `add`, `commit`, `push`, `stash`, `reset`, `clean` yasak. Godot koşulmaz: kartlar repo dışında
  olduğu için `--why-fire` onları göremez, `--event-vocab` ise repo'ya yazar.
  - **Ayrı cihaz (Yol A, §2.3):** taze klon; `fetch` ve `checkout <sha>` yalnız o klonda.
  - **Sahibin makinesi (Yol B, §2.4):** `clone`, `checkout`, `fetch`, `worktree`, `archive` yasak (tek klasör yasası; ağaç
    paylaşımlı: A saat, C açılış oturumları yazıyor; C `data/events/cards/**`, `scripts/events/core/*`, `inbox.gd`,
    `scripts/events/present/*`, `mail_pane.gd`, onboarding'in sahibi); kaynak yalnız `git -C <repo> show <sha>:./<yol>`.
  - Python her yerde `PYTHONDONTWRITEBYTECODE=1` ve `-I` ile koşar (repo'ya `__pycache__` düşmez).
  - **Kabul (sahibin makinesi):** oturumdan önce ve sonra `git -C "<paylaşılan>" status --short` aynı; `git worktree
    list` tek satır; iki çıktı INDEX §0'da.
- **Çıktı yalnız `OUT`** (§2). Repo'ya rapor, not ya da araç yazılmaz.
- **Alt ajanlar Sonnet** (`model: "sonnet"`, sahibin haftalık limiti; eleştirmen/denetim Opus'u sahip kararı, §14.1).
  Yazar kendi kartının kapı puanını vermez.
- **İşletim sistemi düzeyinde fare/klavye girdisi yok.** İnceleme sayfası Artifact aracıyla yayımlanır; tarayıcı yalnız
  derleme sınaması için (`artifact-page-verification`: `new Function` + başsız `--dump-dom`).
- **WebSearch toplam 60**, sayaçlı (`research/search_log.json`: sorgu, ajan, sonuç sayısı); WebFetch sınırsız, günlüklü.
  Bütçe biterse kanıtsız aday havuza girmez; her ajan `searches_used` ve kaynak başına `evidence: fetched | snippet` bildirir.
- **Telif ve gizlilik (pilot §0):** kaynak kendi cümlelerimizle; 15 kelimeden uzun alıntı yok; gerçek kullanıcı, şirket,
  ürün, kişi adı yok; URL yalnız kart dosyasının "Kaynak" bölümünde ve `candidates.json`'da.
- **Push:** yazar hiçbir şey push etmez. Ön koşul push'u (§2) yalnız sahibin "push et" sözüyle, sahibin oturumunda.
- **Metin onayı:** her kart metni "TR/EN onay bekliyor"dur. **Tasarım sabiti:** yazarın önerdiği her tutar, kıdem
  tabanı, gecikme penceresi, aile aralığı, `min_week` tabanı, kitle/nakit tabanı ve §4'ün hedef sayıları INDEX §6'da
  "onay bekliyor" listesindedir.
- `CLAUDE.md` §2 (GDD otoritesi; GDD sessizse dur ve sor, mekanik icat edilmez), §5 (oyuncu metni) bağlayıcıdır.
  Kod ile motor GDD'si ayrışıyorsa ayrılık `MOTOR_ISTEKLERI.md`'ye "§27 adayı" diye yazılır; GDD'ye yazar dokunmaz.

## 2. Makine, klon ve yollar (Y9)
1. **Sıra (hüküm E7):** (a) sahip bu PRD'yi ve motor PRD'sini commit'letir ve push eder (madde 2); (b) yazar v2 ayrı cihazda
   o push'un klonundan, repo salt okunur çalışır (madde 3); (c) motor PRD'si C oturumunun ikinci parçasıdır (PRD_ACILIS
   bitince, sahibin makinesinde), yazarı beklemez; (d) entegrasyon sahibin makinesinde, motor (V0-V8) indikten sonra (§13).
2. **Ön koşul push'u (sahibin oturumu):** iki PRD `main`'e commit'lenir; ağaç paylaşımlı: önce `git diff --cached --quiet`
   (başarısızsa dur: A ya da C index'e hunk koymuş), sonra `git add -- <iki yol> && git commit -m … -- <iki yol>`. "push et"
   istenmeden önce sahibe `git log --oneline origin/main..main` ve `git ls-remote --heads origin` gösterilir; push A ve C'nin
   o ana dek commit'lediği işi de yayımlar, bu açıkça yazılır (`single-folder-single-remote-rule`). Bugün iki PRD uzakta yok.
3. **Yol A · ayrı cihaz (varsayılan):** `git clone <uzak> unicorn_src`; `<repo>` = `unicorn_src/project-unicorn`; sha = klon
   anındaki `origin/main`, motor PRD'sini içerir (`git -C <repo> log -1 --format=%H <sha> -- docs/tasks/PRD_OLAY_MOTORU_V3.md`
   boş değil); `checkout <sha>` yalnız bu klonda, oturum boyunca `fetch`/`pull` yok; `UNICORN_REPO` = `<repo>`.
4. **Yol B · sahibin makinesi (salt okunur; yalnız sahip burada koşturursa):** klon, checkout, fetch, worktree, `archive` ve
   çalışma ağacından okuma yok; `<repo>` = `C:/Users/erdem/Desktop/project steam/project-unicorn`, sha = push edilen
   `origin/main`, her dosya `git -C "<repo>" show <sha>:./<yol>` ile (`<yol>` `project-unicorn/`'a göre). Git kökü bir üst
   dizindir: `./` `-C`'ye göre çözer, çıplak `<sha>:<yol>` kökten çözer ve düşer (HEAD `81da8f3`'te doğrulandı:
   `HEAD:./scripts/events/core/effects.gd` çıkış 0, çıplak `HEAD:scripts/events/core/effects.gd` 128, "exists, but not").
   `UNICORN_REPO` boş; araçlar `UNICORN_GIT` = `<repo>` ve `--git-sha <sha>` ile yalnız `show`, `ls-tree`, `rev-parse`, `log`.
5. **Kabul (iki yol):** `git -C "<repo>" -c core.quotePath=false ls-tree -r --name-only <sha> -- <yollar>` (yollar `-C`'ye
   göre; çıktı INDEX §0'a) şunları listeler: `docs/tasks/PRD_OLAY_MOTORU_V3.md`, bu PRD, `docs/tasks/PRD_ACILIS.md` (§4 R5),
   `GDDs/GDD — OLAY MOTORU (EVENT ENGINE) rev 2.md`, `GDDs/GDD — ZAMAN MODELİ.md`, `docs/content/events_draft/_vocabulary.md`,
   `scripts/events/core/effects.gd`, `scripts/events/present/chips.gd`, `data/product/sprint.json`; biri yoksa dur ve sor.
   Sha ve motor PRD'sinin blob kimliği (`git -C "<repo>" rev-parse <sha>:./docs/tasks/PRD_OLAY_MOTORU_V3.md`) INDEX §0'a.
6. **Pilot paketi:** başka makineye zip ile taşınır (`_tools/`, `_context/BRIEF.md`, `MOTOR_DEGISIKLIKLERI.md`,
   `owner_marks_v1/v2.json`, altı `*/candidates.json`, `review.html` şablonu), ayrı boş dizine açılır. **Yoksa:** F0 GDD
   metnini `word/document.xml`'den üretir, `cardcheck.py` §10'a göre sıfırdan yazılır, bütçe yeni adaylara gider.
7. **Çıktı ve teslim:** `OUT` = `%USERPROFILE%\Desktop\unicorn_writer_v2\` (`UNICORN_WRITER_OUT`); başka makinedeyse `OUT`
   zip'lenir ve sahibe gönderilir (SendUserFile); inceleme sayfasının bağlantısı ayrıca.

## 3. Önce oyunu öğren (Y1)
Yazar ve her alt ajan yazmadan önce aşağıdakileri okur; çıkarılan bilgi `OUT/_context/OYUN_NOTU.md`'ye dosya:satır ile
yazılır (en çok 400 satır; alt ajanların ortak zemini, pilotun BRIEF'inin yerine). Yollar `REPO`'ya göre.

| # | Kaynak | Çıkarılacak |
|---|---|---|
| 1 | `CLAUDE.md` §1, §5 | Üç evre, iki pazar, fon merdiveni, kepenk, 104 hafta tavan, demo sınırı; BILINGUAL BIRTH, LANGUAGE INTEGRITY, EFFECT-VISIBILITY, tire yasağı |
| 2 | `GDDs/README.md`, `GDDs/GUNCELLEMELER.md` | Hangi bölüm yürürlükte; Ürün rev 7 (sprint döngüsü) GDD ch03'ün yerine |
| 3 | GDD ch01 Run, ch13 Endings, ch14 Scope | Evrelerin anlamı ve geçiş kapıları; demo/EA/full sınırı; sonlar |
| 4 | GDD ch02 Founder & People + **Ekip GDD** | Kurucu ayrı tip ve moralsiz; çalışan seviyeleri, moral, maaş, mesai; kurucunun işi (eğitmen değildir) |
| 5 | GDD ch03 + `PRD_URUN_REV7_SPRINT_DONGUSU.md` + **Ar-Ge GDD** | Ürün öncesi/canlı, sprint, sürüm, hata, eksenler; Ar-Ge ağacı (`arge.*`) |
| 6 | **Satış GDD** (ch04'ün yerine), ch06 Operations | B2B hesap yaşam döngüsü (onboarding, risk, söz, yenileme), B2C tek kitle kaydı, destek masası |
| 7 | ch08 Finance, ch09 Funding | Kasa, burn, runway; Frank'in tek çeki, dört VC, seed, Series A yaklaşma işaretleri, term sheet |
| 8 | ch10 Rivals, `PRD_RAKIP_DUNYASI.md` §1 karar B, §4.5 | Dönem 2012-2014; rakip kancaları; parodi adlar |
| 9 | ch11 Events & Narrative (TAM metin) | Arklar ve doku havuzu, sözlük yasası §3, bedel yasası §4, sistem kenarları §5, ses §7 |
| 10 | Motor GDD'si rev 2 §3, §5, §8, §11-§14, §17, §22, §25, §27 | Şema, koşul dili, etki kökenleri, sınıflar, süre dolumu, tempo, lint, scope |
| 11 | `docs/tasks/PRD_OLAY_MOTORU_V3.md` §2, §4, §5 (yeniden yazım listesi dahil), §8 | Şema v3 alanları, yazar fiilleri, canlı kartların bandı ve ailesi, frenler; §4'ün yeniden yazım listesi |
| 12 | `_vocabulary.md` §a, §b + `scripts/events/seams/*.gd` | sha'daki seam'ler (bugün 179), tip ve kapsam; `V3_SEAMS` (motor PRD'si R2, §10) entegrasyonda gelir |
| 13 | `effects.gd` `_apply` (217-556), `chips.gd` (20-45 ve `describe`) | Fiil listesini kendin doğrula; sayım `OYUN_NOTU`'na |
| 14 | `scripts/events/core/signals.gd:22-38`, `scripts/events/gate/scope.gd` (seçiciler 215-294: çalışan 215-239, yatırımcı 242-270, müşteri 273-294; `where` 75-97), `data/product/sprint.json:39` | 15 sinyal, seçiciler, slot süzgeci, sprint karar listesi |
| 15 | `data/events/cards/**` + `strings.csv` `EV_*` | Canlı deste (eş kontrolü); ton referansı yalnız `founder/side_contract`, `team/outside_offer`, `customer/security_review`, `product/sprint_two_paths` (yalnız gövde tonu; `known_way` seçeneği örnek değildir: bedelsiz, O1, BRIEF §12b) |
| 16 | `docs/content/events_draft/Frank Diyalogları · v6.md`, `docs/writing/FRANK_VOICE_INVENTORY.md` | Frank'in payı olan yerler, ses kuralları; Frank satırı yalnız taslak |
| 17 | `docs/design/localization_glossary.md` | TR↔EN terim kanonu, izinli ödünç kelimeler |
| 18 | Dünya: `scripts/systems/office_constants.gd:16-64`, `_vocabulary.md:282`, `ui_tokens.gd:293-303` | Ofis fizikseldir: ev (1 masa), İş hanı (10), plaza (36), loft (64), `office.current`; pazarlama `ea` kilitli |
| 19 | Evre ve kadro: `seams_world.gd:17` (`phase.current` 1/2/3), `:48-50` (`time.week` 1'den), `seams_hr.gd:124-126` (`hr.headcount` kurucusuz), `:42` (`hr.tenure_weeks`), `seams_sales.gd:48`, `seams_product.gd:16` | Bant tanımları (§5) |
| 20 | Pilot: `PRD_YAZAR_AJANI_PILOT.md`, pilot `INDEX.md` §4-6, `BRIEF.md` §5-§13, `owner_marks_v1/v2.json`, `MOTOR_DEGISIKLIKLERI.md` | Sahibin reddettiği şık örnekleri; tekrar edilmeyecek kusurlar |
| 21 | Motor PRD'si R11 tablosu (F1-F9, E1) | Doğrulanmış dokuz saçma ateşlenme: yazar aynı kalıbı üretmez |
| 22 | `GDDs/GDD — ZAMAN MODELİ.md` (`GDDs/README.md:38`) + motor GDD §27.9 | Tik = hafta, `time.week` 1'den, gün/hafta adları, süre alanlarının birimi |

**Demo içeriği (OYUN_NOTU'nda ayrı bölüm):** Series A (`phase.series_a_approach`, kapı, term sheet), yatırımcılar (Frank,
dört VC, `investor.*`), B2B hesaplar (`musteri.*`, tek tek), B2C (`sales.b2c_audience`, tek kitle). Demoda olmayan yazılmaz.

**Kavrama sınavı (Y1 kabulü):** yazar `OUT/_context/SINAV.md`'ye 25 soruyu dosya:satır kanıtıyla cevaplar; ayrı bir Sonnet
ajanı kaynağı (§2) okuyarak puanlar. Puanlayan, yazar cevaplamadan önce aşağıdaki anahtarı kaynakta yeniden doğrular ve
`_internal/SINAV_ANAHTAR.md`'ye yazar (satır kaydıysa sha'daki satır geçerli). Geçme 25/25; yanlış cevapta kaynak yeniden
okunur ve o soru yeniden cevaplanır. Soru → beklenen (kanıt):
1 `hr.headcount` kurucuyu sayar mı → hayır, mentoru da (`seams_hr.gd:124-126`) · 2 bir tik kaç gün → bir hafta (ZAMAN
MODELİ; motor GDD §27.9) · 3 `time.week` kaçtan → 1 (`seams_world.gd:48-50`) · 4 `phase.current` değerleri → 1/2/3
(`seams_world.gd:17`) · 5 ürün canlı mı nasıl okunur → `urun.is_live` (`seams_product.gd:16`); bootstrap'ta canlı olabilir ·
6 `churn_customer` B2C'de → kitle %15 aşınır (`effects.gd:266-270`, `B2C_CHURN_PCT` `:86`) · 7 memnuniyet deltası neden
kalıcı değil → hedefe haftada 21'e dek geri çekilir (BRIEF §9b.5) · 8 `sprint_card_*` nerede → `tick: request` karar kartı,
`sprint.json:39` · 9 `productivity_mod` solo → −30 ve 2 hafta (`hr_system.gd:376-382`, `hr_constants.gd:842-843`) ·
10 pazarlama demoda → kilitli `ea` (`ui_tokens.gd:300`) · 11 hangi sinyal özne slotunu doldurur → ör. `employee_hired` →
`employee` (`signals.gd:27`) · 12 `employee_departed` anında giden kişiye etki → hayır (`signals.gd:26`; §6.2) ·
13 `on_expire` → ekonomik fiil yalnız negatif (`effects.gd:115`, `:177-178` I2) · 14 `{company}` var mı → yok; yalnız
`{slot}`, `{seam:ns.ad}` (smoke `card_body_tokens_resolve`) · 15 Frank'in çeki → tek karar, MRR eşiğinde
(`_vocabulary.md:177` `funding.angel_threshold_met`, `:231` `investor.angel_taken`; CLAUDE.md §1) · 16 dört VC → aynı dört
VC seed ve Series A'da (CLAUDE.md §1, ch09; seçiciler `scope.gd:242-270`) · 17 `morale_all` kadro 0'da → no-op, çip yine
basılır (`effects.gd:353-356`, `chips.gd:75`) · 18 `change_morale` kurucuya → ham yazım, kurucu moralsiz (`effects.gd:347-350`)
· 19 `add_prospect` ne zaman doğurur → `mvp_shipped ∧ B2B` (`sales_faucet_system.gd:46-47`) · 20 `b2b_retain_ignore`
bedel mi → hayır, `pass` (`b2b_sales_system.gd:281-285`) · 21 `fix_run_start` ne ister → canlı, koşu yok, hata > 0, masa
dolu (`support_system.gd:291-300`; `destek.can_start_fix_run`) · 22 çipsiz yazar fiilleri → `set_flag`, `stamp_day`,
`schedule_event`, `cancel_scheduled` (`chips.gd:20-24`) · 23 `latch_key: entity` → özne başına mandal (`latches.gd:9-11`)
· 24 ev kaç masa → 1; İş hanı 10 (`office_constants.gd:16-20`) · 25 `paper` kart süresi dolunca → `expire_note` haber
şeridine (`engine.gd:114-117`); boşsa lint §17.7 E (`lint.gd:128-136`).

## 4. Hedef matris (Y2)
Bantlar motor PRD'si §2'nin tanımıdır, aynen: `bootstrap_solo` = `phase.current==1 ∧ hr.headcount==0`, `bootstrap_team` =
`phase.current==1 ∧ hr.headcount>=1`, `traction` = `phase.current==2`, `series_a` = `phase.current==3`. **Kadro ekseni**
(OR 2; yalnız INDEX ve `cardcheck` için, kartın `headcount` alanından okunur): `crew_band` ∈ {`solo` [0,0], `crew_1_2`
[1,2], `crew_3plus` [3,null]}. Çalışan öznesi taşıyan kartın `headcount` aralığı ya [1,2] ya [3,null] içinde kalır; ikisini
kapsarsa E. **Sayım kuralı:** her kart INDEX'te tek bir sayım hücresi (`primary_band` + `crew_band`; kart alanı değildir,
kart JSON'una girmez) taşır ve yalnız orada sayılır; kart o hücrede `phase_band` ve `headcount` alanıyla gerçekten
yaşamalıdır. `[VOCAB?]`/`[COND?]` taşıyan kart, not (beat) kartı ve takip düğümü asgari sayıya girmez. Asgariler
OWNER_RULES 7; hedef, alt kota, pazar dengesi, yedek oranı ve not tavanı **onay bekliyor** (INDEX §6, §14.6).

| Bant · kadro | Tanım | Asgari | Hedef | İçerik alt kotası (asgari) |
|---|---|---|---|---|
| `bootstrap_solo` · `solo` | faz 1 ∧ kadro 0; ev ofisi; ürün çoğunlukla `pre_launch` | 10 | 15 | sprint 3 (kurucunun sprinti; karar kartı `tick: request`), ürün 3, araştırma 2 (Ar-Ge ağacı ya da ürün öncesi müşteri keşfi), kurucu 3 |
| `bootstrap_team` · `crew_1_2` | faz 1 ∧ kadro `[1,2]` | 20 | 22 | çalışan öznesi 8 (o kişinin kendi hikâyesi; işe alım başına tekrar yok), ilk müşteri/ilk sürüm 4, kurucu ile küçük ekip 4, sprint 3 |
| `bootstrap_team` · `crew_3plus` | faz 1 ∧ kadro ≥ 3 (İş hanı 10 masa, `office_constants.gd`) | — (§14.3) | 4 | ekip (kadro ≥ 3) 4 |
| `traction` | faz 2 | 20 | 24 | B2B hesap 6, B2C kitle 6, büyüme 3, yatırımcı ve seed 4 (Frank'in payına dokunmadan), ekip (kadro ≥ 3) 4 |
| `series_a` | faz 3 | 20 | 22 | Series A süreci ve dört VC 6, B2B 4, B2C 4, ekip (kadro ≥ 3) 4, rakip/dünya 2 |
| takip düğümleri | `follows` taşıyan | — | 15-20 | ebeveynin hücresinde; ebeveynin seçeneği `schedule_event` ile kurar |

Toplam hedef ≈ 87 bağımsız kart + 15-20 takip ≈ 100-105, yeniden yazım listesi dahil. **Pazar dengesi:** `traction` ve
`series_a`'da `guards.market` b2b ve b2c sayıları birbirinin en az %40'ı. **Yedek:** her bant için hedefin %30'u kadar
fikir slate'te yedek durur (kapıdan düşenlerin yerine). **Not kartları:** en çok 3, yalnız `bootstrap_solo`'da, sayıma
girmez (C'nin not yolu: tek seçenek, etkisiz, `critical` değil, `paper` değil; `PRD_ACILIS.md` R5).
**Yeniden yazım listesi** (hüküm E2, E3, E5; motor §5 sonundaki liste, aynen): canlı kart, 100'ün içinde, motor §5 hücresinde
sayılır, id korunur; kapısı yeni kartınki (her ölçüt ≥ 9, ≤ 2 yeniden yazım), yeniden yazılınca dondurulmuş listeden düşer
ve R9'un her kuralı E olur. Geçemeyen kart emekli önerilir: INDEX §5'te tek satır gerekçe, `cards.json`'a girmez (yol motor
§9.4). Nihai liste V6'nın W'leridir: orada çıkmayan emekli edilmez, orada çıkıp burada olmayan entegrasyonun açık satırıdır.

| Kart | Neden | Yeniden yazılacak |
|---|---|---|
| `customer.chargeback` / `customer.named_in_leak` / `customer.new_owner_group` | O4: şık hiçbir çalışan ya da müşteri slotuna düşmüyor | `keep` / `lawyer` / `pitch` |
| `product.sprint_colors_again` / `product.sprint_rewrite_bugs` / `product.sprint_rewrite_owner` / `product.sprint_rewrite_reader` | O4 (son üçü `scope: team`, slota düşmez) | `by_hand`, `one_file`, `freelancer` / `freeze` / `trainer` / `peer` |
| `funding.portfolio_vendor` / `rival.shutdown_notice` | O5 (hüküm E5): demo kartında `marketing_push`; motorun F4/F5 kilidi yeniden yazılana dek W | `own_ads` / `more_marketing`: yerine pazarlamasız bir demo hamlesi |
| `team.wiped_table` | T3: `select: newest_hire`, kıdem 4 < 8 | özne seçimi |
| `team.lead_overtime` | Hüküm E2 (lint dışı): R11 `sprint_hours`'u silince kazançsız; ekip kartı sayılmaz, saat dönmez | `carry`, `bonus`: sprint saatsiz yeni kazanç |

- **Kabul:** `INDEX.md` §1 matris tablosu: bant · kadro × alt kota × sayılan kart; her hücre asgariyi tutuyor ya da açık
  satırı "eksik N, neden" diye yazılı. Bir kart iki hücrede sayılmıyor (betikle: `primary_band` + `crew_band` tekil,
  `primary_band` ∈ `phase_band`); yeniden yazım listesinin 11 kartı ya geçti ya INDEX §5'te emekli satırında.

## 5. Şema v3 kart (Y3)
Alanlar motor PRD'si §2'dendir; yazar kopyalar, değiştirmez. Mantık bloğuna:
- `schema: 3` · `system: false` (yazar kartı asla `system` değildir, `critical` taşımaz).
- `plausibility.phase_band` (boş değil) · `plausibility.headcount: [min, max|null]` · `plausibility.subject_tenure_weeks`
  (`select`li her employee/customer slotu varsa; `select`siz verilen slotta yazılmaz; slot başına
  `plausibility.subject_tenure_by_slot`; 0 ise `fresh_reason`) · `plausibility.product: pre_launch|live|any`
  (`guards.product_live` varsa aynı değer) · `plausibility.modules: [UiTokens.TABS id]` (boş olabilir) ·
  `plausibility.min_week` (≤ 130; istek/sinyal dışı kartta ≥ 4, onay bekliyor: OR 6 koruması K4'ten bağımsız, K4
  reddedilirse motor `START_IMMUNITY_WEEKS = 0` olur; 4'ün altı W).
- `family` (zorunlu) · `family_subject: {once: true} | {cooldown_weeks: N}` · `follows: <ebeveyn id>`.
- `delay_weeks: [N, M]` (0 ≤ N ≤ M ≤ 26, zorunlu) · `[0,0]` ise `delay_reason` · isteğe bağlı `delay_mult`.
- `weight` 1,0 (yazar değiştirmez) · etkisiz seçenekte `status_quo_reason` · `version_scope: demo` (`ea` kart sayılmaz).

**Yazarın ek tutarlılık kuralları (cardcheck E):**
1. `bootstrap_solo` ⇒ `headcount [0,0]`, employee slotu yok. `bootstrap_team` kartı `headcount`'u `crew_band`'ine göre
   ⊂ [1,2] ya da ⊂ [3,null] daraltır. Employee slotu ⇒ min ≥ 1, iki kadro bandını kapsamaz; `crew_3plus` ⇒ min ≥ 3.
2. Kıdem tabanları (onay bekliyor): para isteyen çalışan 26 (K3); sıradan çalışan hikâyesi 8; ilk haftalara özgü durum
   yasak (emekli aile `new_hire_onboarding`); B2B hesap 4, yenileme dili 44 (motor PRD'si R12); taze özne yalnız
   `fresh_reason` ile ve metin tazeliği söylüyorsa.
3. Gecikme (onay bekliyor): günlük süpürme kartı `[1,4]` ile `[2,8]`; sinyal tepkisi ve sprint isteği `[0,0]` +
   `delay_reason`; zincir düğümü `[0,0]` + `follows`.
4. **Tekrar yasağı (OR 3: özne başına bir kez VE uzun bekleme):** `trigger.signal: employee_hired` taşıyan kartta
   `latch: {one_shot: true}`, `latch_key: "run"` (ya da alan yok; `latches.gd:45` varsayılanı) ve `hr.run_hires` koşulu
   `==` ile zorunlu (ör. "ilk işe alım" `== 1`); `latch_key: entity` E (`latches.gd:9-11`: özne başına mandal, her işe
   alım yeni özne). Çalışan öznesi taşıyan her aile `family_subject.once` VE aile aralığı ≥ 26 hafta (onay bekliyor);
   `once` yalnız aynı özneyi keser (motor R5), özneler arası fren aile aralığıdır (motor §8 varsayılanı 6). Aralık INDEX
   §3'te motorun `FAMILY_GAP_WEEKS` tablosu için satır olarak yazılır. `newest_hire` seçicisi yalnız kıdem tabanı ≥ 8 ile.
5. Aile adı `<konu>_<öz>` (`founder_money`, `employee_asks_money`); canlı aileler motor PRD'si §5'ten yeniden kullanılır;
   yeni aile INDEX §3'te tek satır gerekçe ve önerilen aralık (varsayılan 6 hafta, onay bekliyor) ile.
6. Koşulda motorun okumadığı `trigger.condition` yok (motor PRD'si §0a); koşul `condition` ağacına yazılır.
7. `class: paper` ya da `interrupt` ⇒ `expires_weeks` + `on_expire` + üst düzey `expire_note` dolu (lint §17.7,
   `lint.gd:120-136`; `engine.gd:114` notu bu anahtarla metin bloğundan çözer; canlıda 60+ kart `"expire_note":
   "expire_note"` taşır, ör. `team/first_weeks.json`).

**İskelet (yalnız biçim; değerler örnek):**
```json
{"id": "team.<ad>", "schema": 3, "category": "team", "version_scope": "demo", "tick": "daily", "class": "paper",
 "sender": "employee", "scope": {"employee": {"type": "employee", "required": true, "select": "most_senior"}},
 "plausibility": {"phase_band": ["bootstrap_team"], "headcount": [1, 2], "subject_tenure_weeks": 8,
   "product": "any", "modules": [], "min_week": 4},
 "family": "employee_<öz>", "family_subject": {"once": true}, "delay_weeks": [2, 6],
 "latch": {"one_shot": true}, "latch_key": "entity", "condition": {"all": []},
 "options": [{"id": "<fiil>", "outcome_id": "<id>", "effects": [{"verb": "change_morale", "scope": "employee", "amount": -6}]}],
 "expires_weeks": 2, "on_expire": {"penalties": []}, "expire_note": "expire_note",
 "text": {"en": {"title": "EV_TEAM_<AD>_TITLE", "body": "EV_TEAM_<AD>_BODY", "options": {}, "expire_note": "EV_TEAM_<AD>_EXPIRED"},
          "tr": {"title": "EV_TEAM_<AD>_TITLE", "body": "EV_TEAM_<AD>_BODY", "options": {}, "expire_note": "EV_TEAM_<AD>_EXPIRED"}}}
```
`latch_key: entity` yalnız günlük süpürme kartında (bu iskelet); `employee_hired` kartında asla (kural 4).
- **Kabul:** `cardcheck.py --schema 3` her kartta 0 error; INDEX §2 her kart için bant, kadro, kıdem, ürün, modül, aile,
  gecikme sütunlarını taşır (motor PRD'si §5 tablosunun biçimi).

## 6. Fiiller, modifier ve okunur durum (Y4)
### 6.1 Yazar fiilleri (30; motor PRD'si §4; HEAD'de 30/30 `effects.gd` kolu; 26 çipli + 4 sessiz)
Sessiz 4: `set_flag`, `stamp_day`, `schedule_event`, `cancel_scheduled` (`chips.gd:20-24` `SILENT_VERBS`, `:155-157` boş
döner); sessiz fiil ne bedel ne kazanç sayılır.
`add_cash` (etiket `FinanceSystem.ONE_TIME_LABELS`'tan), `add_brand`, `add_reputation`, `customer_mrr_delta`, `seats`,
`churn_customer`, `audience_delta`, `add_prospect`, `employee_leaves`, `b2b_retain_discount`, `b2b_expand`, `change_morale`,
`morale_all`, `satisfaction_delta`, `promise_create`, `sprint_hours`, `sprint_card_effort`, `sprint_card_progress`,
`sprint_card_carry`, `fix_run_start`, `b2b_retain_delay`, `b2b_retain_ignore`, `b2b_expand_decline`, `set_flag`,
`stamp_day`, `schedule_event`, `cancel_scheduled`, `productivity_mod`, `investor_strain`, `marketing_push`.
Parametre ve çip: pilot `BRIEF.md` §5a, §5f, §6. Yazar listeyi F0'da kendi sayar (§3 #13); farklıysa dur, `MOTOR_ISTEKLERI`.

**Yasak:** ayrılmış 18 (`advance_phase`, `phase_gate_decline`, `angel_accept`, `open_term_table`, `open_seed_table`,
`decline_offer`, `decline_buyout`, `trigger_ending`, `mentor_advisory`, `goto_tab`, `unlock_content`, `spend_budget`,
`set_game_flag`, `start_arc`, `advance_arc`, `end_arc`, `abort_arc`, `set_arc_var`); yazılamaz 15 (`assign_to`,
`send_on_leave`, `start_training`, `damage_product`, `add_customer`, `convert_audience`, `open_paid_tier`, `change_salary`,
`fire_employee`, `add_mrr`, `open_negotiation`, `clear_flag`, `set_timed_flag`, `ticker_push`, `notify`). Bunlardan biri
gerekiyorsa kart `[VOCAB?]` olur, sayıma girmez.

### 6.2 Fiil kısıtları (cardcheck E; motor lint R9 ile bire bir)
R9'un V, O ve T kuralları motorun okumalarıyla aynen aşağıdadır (P1-P3, C1 §5'te); yazar kartında hepsi E, dondurulmuş
listenin W indirimi yalnız motorun canlı kartlarına (§4). **Yazar eki** R9'u yalnız daraltır, onunla çelişmez.
- **V1-V3:** yazılabilir 48 dışı fiil (yazar kartında 30 dışı, §6.1); `system` olmayan kartta ayrılmış 18; `tick: request`
  olmayan kartta `sprint_card_*` (o karar kartı entegrasyonda `data/product/sprint.json:39` `decision.cards`'a satır ister).
- **O1/O2:** iki ya da daha çok seçenekli kartta etkisiz seçenek yalnız `status_quo_reason` ile ("olduğu gibi bırak" O1'den
  geçer, O2'ye takılmaz: etkisiz seçenek O1'indir); etkili her seçenek en az bir bedel taşır: çip kutbu `cost`/`danger` ya da
  sonuç fiili (`sprint_card_carry`, `fix_run_start`, `b2b_retain_delay`, `b2b_retain_ignore`, `b2b_expand_decline`,
  `promise_create`); `system` ve not kartı (PRD_ACILIS R5: tek seçenek ∧ etkisiz ∧ `critical` değil ∧ `class != paper`) muaf.
  **Yazar eki:** etkili her seçenek bir **çipli** fiil ve bir kazanç da taşır; sessiz fiil (§6.1) ne bedel ne kazançtır;
  `schedule_event`'li takip seçeneği kendi çipli bedelini taşır; `status_quo_reason`'ı eleştirmen 2. ölçütte sınar.
- **O3:** tek kişilik kartta (tek employee slotu ya da `category: founder`; kadro `[0,0]` dahil, istisnasız) `sprint_hours`
  ve negatif `morale_all` yok; kurucunun vakti `productivity_mod scope: founder`. **Yazar eki:** `sprint_hours` yalnız bütün
  ekibin vakti gidiyorsa (kadro ≥ 1), seçenekte `requires urun.sprint_running == true` + `EV_LOCK_NO_SPRINT` ile.
- **O4:** slotlu kartın her seçeneği o slota ya da kartın kaynağına bedel düşürür (employee: `change_morale`,
  `productivity_mod`, `employee_leaves` `scope: <slot>`; customer: `satisfaction_delta`, `customer_mrr_delta`, `seats`,
  `churn_customer`, `promise_create`, `b2b_*`); çok slotlu kartta en az bir çalışan ya da müşteri slotuna düşen seçenek
  geçer, `scope`'suz etki türünün ilk slotuna düşer; denetim işarete bakmaz (motor §5 sonu listesi böyle çıkar).
- **O5:** demo kartında `marketing_push` yok (§0a); `ea` kartında `requires build.module_unlocked.marketing == true`.
- **T1-T3:** `employee_hired` sinyalli kartta koşu kapsamlı `one_shot` ve `hr.run_hires` yaprağı; employee slotlu ailede
  `family_subject.once` ya da `cooldown_weeks` ≥ 26; `newest_hire` ⇒ `subject_tenure_weeks` ≥ 8 (yazar eki: §5 kural 4).
- **Yazar eki:** `productivity_mod` `pct` −50..+30 (0 değil), `weeks` 1..8; tek başına kurucu −30 ve 2 haftada kenetlenir;
  `scope: founder` `founder` slotu, `scope: team` sprint kilidi ister; aynı slota tek satır (motor §4). `investor_strain`
  `amount` 1..15, `weeks` 4..52, yalnız investor slotu. Ekonomik fiil `on_expire`'da yalnız negatif (I2);
  `employee_departed`/`customer_churned` sinyalinde giden özneye etki yok. Memnuniyet tek başına bedel değildir:
  `satisfaction_delta` yanında kalıcı iz (MRR, koltuk, söz, itibar, marka, nakit, churn) olur.

**Fiil → zorunlu bağlam** (cardcheck E; bağlam dışında etki düşmez ama çip basılır = COPY LIE; her satıra §10'da bir
`bad_ctx_<fiil>` fikstürü):

| Fiil | Zorunlu bağlam | Kanıt |
|---|---|---|
| `add_prospect` | `guards.market: b2b` + `plausibility.product: live` | `sales_faucet_system.gd:46-47`, `spawn` 200-201; canlı 6/6 b2b |
| `audience_delta`, `churn_customer` (B2C yorumu) | `guards.market: b2c` ya da B2C şubesi açık | canlı 9/9 b2c; `effects.gd:266-270` |
| customer slotu, `b2b_*`, `seats`, `customer_mrr_delta`, `promise_create` | `guards.market: b2b` | B2C tek toplu kayıt (`effects.gd:266-270`, `scope.gd:274`) |
| `b2b_retain_delay`, `b2b_retain_ignore` | customer slotu `select: at_risk`; `b2b_retain_ignore` bedel sayılmaz | `b2b_sales_system.gd:248-259`; `:281-285` `pass` |
| `b2b_retain_discount` | seçenekte `requires musteri.discounts_used < RETAIN_DISCOUNT_MAX_USES` (bugün 2, `_vocabulary.md:252`) + kilit gerekçesi | tavanda sessiz dönüş (`b2b_sales_system.gd:272`); canlı `price_cut`, `false_partner`, `request_renewal` |
| `b2b_expand`, `b2b_expand_decline` | `select: expansion_ready` (sprint karar kartı dışında) | `last_expansion_day` damgası (`b2b_sales_system.gd:309-318`); `scope.gd:284-286` |
| `fix_run_start` | `requires destek.can_start_fix_run == true` | `support_system.gd:291-300`; canlı `bug_pile` |
| `morale_all`, `change_morale`, `employee_leaves`, `productivity_mod` (employee/team) | `headcount` min ≥ 1 | kadro 0'da no-op, çip "Ekip +N" (`effects.gd:353-356`, `chips.gd:75`) |
| `change_morale` | founder slotuna asla | ham yazım (`effects.gd:347-350`); kurucu moralsiz (§3 #4) |

### 6.3 Orantılılık (canlı deste, HEAD 124e54b; yalnız seçenek etkileri, `on_expire` ve `unwired/` hariç; min · ortanca · maks)
`add_cash` −30.000 · −3.000 · +20.000 · `add_brand` −4 · −1 · +5 · `add_reputation` −2 · +1 · +4 · `change_morale`
−12 · +3 · +10 · `morale_all` −5 · +2 · +3 · `satisfaction_delta` −30 · +3 · +10 · `customer_mrr_delta` −200 · −100 · +400 ·
`seats` −4 · −2 · +6 · `audience_delta` (pct) −0,15 · +0,02 · +0,20 · `productivity_mod` −50 · −25 · +10 ·
`investor_strain` 4 · 6 · 12 · `sprint_hours` 0,6 · 0,9 · 1,25 · `sprint_card_effort` −3 · +2 · +5.
Para ölçeği evreye göre (BRIEF §6: alan adı $900, kullanıcı denemesi $300, buluşma $200-600, dış kaynak $2.000, bağlılık
primi $5.000, kesinti $6.000, denetim $8.000, fuar $30.000): `bootstrap_*` kartında tek seçenek ±$3.000'ü aşmaz;
`traction` ±$20.000; `series_a` ±$50.000 (onay bekliyor). Aralık dışı her değer kart dosyasında bir cümle gerekçe ister.
`on_expire` dahil sayılınca ortanca kayar (`change_morale` −3, `satisfaction_delta` −2,5, `customer_mrr_delta` −125,
`investor_strain` 8): `on_expire` tutarı aynı kartın en büyük seçenek tutarının ≤ yarısı (onay bekliyor; aşarsa W).

### 6.4 Okunur durum
Koşul ve gövde yalnız sha'daki `_vocabulary.md` §b seam'lerini okur (bugün 179; B ve C seam ekliyor) + `V3_SEAMS` (motor
R2: `build.module_unlocked.<id>`, `hr.weeks_since_last_hire`, `hr.run_hires`; R8: `build.last_unlocked_module`; INDEX'te
"v3 seam" işaretli). Sinyaller `signals.gd:22-38`'in 15'i + `V3_SIGNALS` (motor R8: `customer_added`, `module_unlocked`).
Seçiciler `scope.gd:215-294` (çalışan 215-239, yatırımcı 242-270, müşteri 273-294); slot süzgeci `where` (`scope.gd:75-97`).
Gövdede yalnız `{slot}` ve `{seam:ns.ad}`; `{company}` yok; `{seam:}` taşıyan gövde CSV'ye değil kartın `text`'ine.
- **Kabul (6.1-6.4):** `cardcheck` V1 (30 dışı fiil), V2 (ayrılmış), V3 (`sprint_card_*`), O1-O5, çipsiz seçenek, bağlam
  tablosu, orantılılık W listesi her kartta temiz; `MOTOR_ISTEKLERI.md` her `[VOCAB?]`/`[COND?]` için kart listesi taşır.

## 7. Araştırma (Y6)
- **Kaynaklar:** HN Algolia API (`hn.algolia.com/api/v1/search?query=<q>&tags=ask_hn`, `items/<id>`; WebFetch, bütçe
  dışı), Indie Hackers, kurucu blogları ve ölüm sonrası yazılar, Reddit (r/startups, r/SaaS, r/Entrepreneur, r/sales,
  r/managers, r/venturecapital vb.; `old.reddit.com/.../.json`). WebSearch yalnız bunlarda bulunamayan konuda.
- **Pilot adayları önce:** pilotun 54 ayıklanmış adayından kullanılmayan 36'sı bantlara yeniden eşlenir (`evidence`
  korunur). **Bütçe:** 60 WebSearch: `bootstrap_solo` 12, `bootstrap_team` 16, `traction` 14, `series_a` 14, yedek 4.
- **Aday kaydı** (`OUT/<bant>/candidates.json`): id, URL, tarih, kendi cümlelerimizle bir paragraf, karar anı, kaynaktaki
  insanların gerçekten düşündüğü ve yaptığı yollar, sonuç, `evidence`, önerilen bant ve gerekçesi (şirket boyu, ürün
  canlı mı, müşteri var mı), ayıklama hükmü.
- **Ayıklama:** pilot §5.2'nin beş ölçütü + **bant uyumu** (kaynaktaki şirketin boyu ve evresi karttaki bantla aynı) +
  **dünya uyumu** (§8.2).
- **Kabul:** `research/search_log.json` satır sayısı ≤ 60 ve INDEX'teki sayıyla eşit; her kart dosyasının "Kaynak" bölümü
  aday id + `evidence` + URL taşır; takip düğümü ebeveyninin kaynağını gösterir; bant başına aday sayısı ≥ hedefin 1,5 katı.

## 8. Yazım kuralları (Y5)
### 8.1 Şık (2026-10-08 kuralları + pilot BRIEF §9b, §9c; hepsi aynen geçerli)
1. Seçenek, o anda bir kurucunun gerçekten yapacağı somut hamledir; kaynak hikâyedeki insanların yolları önce gelir.
   Soyut tutum ("Yoluna devam et", "Not alındı") yok.
2. Bedel olayın öznesine düşer: çalışan olayında o çalışan; müşteri olayında o hesap; ürün olayında ürün ya da karar kartı;
   para olayında kasa; ün olayında marka ya da itibar.
3. Bedava çıkış yok: her seçenek en az bir çipli fiil (yalnız sessiz fiil = bedava çıkış), bir artı ve bir eksi taşır, ikisi
   de hamleden doğar, başka bir durumda en iyisidir ("kim için doğru" cümlesi); istisna O1'in "olduğu gibi bırak"ı (§6.2).
4. Tek kişilik olayda sprint saati yok (§6.2).
5. Etki hamleyi anlatır: "yeni aday" çipi ancak hamle yeni bir aday doğuruyorsa; gerekirse takip olayı.
6. "Ne alaka" sınavı: eleştirmen her seçenek için "bu kurucu gerçekten bunu mu yapar?" sorusunu yazılı cevaplar.
7. Avukat tutmak geçerli bir yoldur (`add_cash label: legal`).

### 8.2 Dünya tutarlılığı
- **Ofis fizikseldir.** Kurucu evde başlar (`office_constants.gd:16-20`, 1 masa); ekip aynı odada; ofise atıf
  `office.current` ile uyumlu (evdeyken "ofisimiz" yok); uzaktan çalışma ve ekip sohbet uygulaması yok (2012, BRIEF §11).
- **Kurucu eğitmen değildir:** ürünü yapar, satar, para arar, işe alır; "yanına oturup gösteririm" yolu yok
  (`start_training` kolsuz). **Pazarlama demoda yoktur** (`ui_tokens.gd:300`): reklam, kampanya, bütçe şık olamaz; dünya
  teklifi (vitrin, içerik üreticisi) yalnız kitle/nakit tabanıyla ve kendi `add_cash`'iyle (K2).
- **Frank:** kartta konuşursa satır "taslak, onay bekliyor"; yalnız Frank'in payı olan yerde (kendi çeki, açtığı kapı,
  hissedarı olduğu şirketin toplantısı, teklif masası, kepenk); Frank'i sahnede gösterme; hüküm yalnız onda.
- **Evreye uygunluk:** `bootstrap_*` kartı müşteri, yatırımcı ya da büyük ekip varsaymaz; ürün öncesi kartta kullanıcı yok;
  `traction` kartı seed öncesi ya da seed sürecindedir; `series_a` kartı dört VC'den birini ve yaklaşma işaretlerini bilir.
- Sektöre fazla özgü olay yok ("daha common ama niş"); gerçek marka, şirket, kişi yok (2012 olguları serbest).

### 8.3 Metin
- **İki dilde doğum:** önce EN (İngilizce yazılmış gibi okunur), TR ayrı yazım, çeviri değil; TR'de İngilizce yalnız
  izinli ödünç kelimeler. Anahtarlar `EV_<KATEGORİ>_<AD>_<PARÇA>`; repo `strings.csv`'de çakışmaz.
- **Yasak:** tire (— –, cümle arasında " - "); "PH:" ya da her türlü yer tutucu; benzetme; aforizma; sahne ve aksesuar
  betimi; UI talimatı, sekme ya da düğüm adı; gün içi zaman ("sabah", "akşam", "tonight"); Frank dışında hüküm.
- **Edgü kesimi:** gözlem, hüküm yok, son cümle en kısa; mizah durumdan. Ton `ciddi | kuru mizah | acı tatlı`; bant
  başına ~üçte bir hafif. **Uzunluk:** başlık ≤ 4 kelime; gövde EN ≤ 45 (hedef 20-35); seçenek ≤ 6, fiille başlar (TR
  emir kipi); `expire_note` ≤ 12, olgu; kilit gerekçesi durumu adlandırır.
- **COPY LIE yok:** her iddia, seçenek etiketi dahil, bir etkiyle karşılanır. CSV: araya giren değer ek almaz; iki dilde
  jeton kümesi aynı; virgüllü değer çift tırnakta.
- **Kabul (8.1-8.3):** `cardcheck` metin kuralları 0 error; eleştirmen dosyasında "ne alaka" cevabı her seçenek için var;
  `grep -E '—|–| - |PH:' strings_draft.csv` boş.

## 9. Kör eleştiri, kapı ve denetim merceği (Y7)
**Yedi ölçüt (OR 7'nin yedi maddesi), her biri 1-10** (ağırlık yok; kapı en düşük ölçüttür):

| # | Ölçüt | 9 ne demek | Otomatik tavan |
|---|---|---|---|
| 1 | Yazım | EN doğal, TR iyi bir yeniden yazım, Edgü kesimi, klişe yok | Metin kuralı ihlali → 5 |
| 2 | Şık doğruluğu | Her şık somut gerçek hamle; bedel özneye; bedava çıkış yok; baskın şık yok | O1-O4 ihlali ya da "ne alaka" cevabı "hayır" → 5 |
| 3 | Oyunla ilgi | Bugünkü bir sistem kenarına bağlı; sonuç oyunda görünür; canlı destede eşi yok | Eşi varsa → 6 |
| 4 | Anlatım | Durum iki-üç cümlede kurulur; karar anı açık; ton yerinde | — |
| 5 | Modifier uyumu | Her etki hamleyi anlatır; büyüklük §6.3 bandında; memnuniyet yanında kalıcı iz | 30 dışı fiil ya da gerekçesiz aralık dışı → 5 |
| 6 | Dünyadan gerçek olay | Kaynak aynı boyda bir şirketten; karar anı kaynakta var; seçenekler kaynaktaki insanların yolları | Kaynaksız → kart düşer; `evidence: snippet` tek kaynak → 7 |
| 7 | Evre ve dünya makullüğü | Bant, kadro, kıdem, ürün durumu, gecikme hikâyeyle uyumlu; dünya kuralları (§8.2) tutuyor | §8.2 ihlali → 5 |

- **Çapalar:** eleştirmen önce `OUT/_context/CAPALAR.md`'yi okur: sahibin onayladığı/reddettiği pilot kartları
  (owner_marks v1/v2; varsa `6F4qLi2y5TPsg8ds6ia5q3` `marks_v3`) her ölçütte puanlı; pilotun 7,2-7,75 kartları 9'un altında.
- **Kör:** eleştirmen yazarın puanını, öbür eleştirileri ve `_internal/`'ı görmez; kartı, kaynak özetini, uyarlama
  tablosunu, `cardcheck` raporunu, `OYUN_NOTU.md`'yi okur; ölçüt başına bir cümle gerekçe ve bir düzeltme.
- **Kapı:** yedi ölçütün **her biri ≥ 9**, `cardcheck` 0 error, sert ihlal yok. Geçemeyen kart en çok iki kez yeniden
  yazılır (her seferinde YENİ kör eleştirmen); üçüncüde düşer, yerine yedek girer.
- **Sert kurallar (kart düşer):** §8.3 yasakları; 30 dışı fiil; işaretsiz `[VOCAB?]`/`[COND?]`; COPY LIE; işaretsiz Frank
  satırı; kaynaksız kart; kurucu eğitmen; demoda pazarlama; `critical`/`system`; işe alım başına tekrar (§5 kural 4).
- **Denetim merceği (bant başına bir ajan, kapıdan sonra):** geçmiş kartları birlikte okur: aynı durumun iki kartı, aile
  çakışması, tek konuya yığılma, çelişen dünya, aynı bedel kalıbı (her kartta `change_morale −5`), kopuk takip zinciri,
  130 haftada ulaşılamayan koşul. Rastgele %25'i yedi ölçütte yeniden puanlar; < 9 ya da eleştirmenden 2'den büyük fark →
  yeniden yazım kuyruğu (iki yeniden yazım sınırına sayılır).
- **Kabul:** `INDEX.md` §3 her kart için yedi eleştirmen puanı, denetim puanı (örneklendiyse), yeniden yazım sayısı;
  `_internal/reviews/<id>.r<n>.json` her eleştiri; düşen kartlar ve nedenleri §5'te.

## 10. Mekanik denetçi: `cardcheck.py` şema v3 (Y8)
Pilot aracından (`_tools/cardcheck.py`, 778 satır) türetilir, `OUT/_tools/`'a:
- **Yollar:** `UNICORN_REPO`, `UNICORN_GIT`, `UNICORN_WRITER_OUT` (§2; `PILOT_OUT` eski ad, yedek). Bugün `cardcheck.py:19`
  REPO sabit, `:20` OUT `PILOT_OUT`'tan, `:137` ve `:166` canlı ağacın kart ve CSV dosyalarını açıyor; Yol B'de dosyalar
  `--git-sha <sha>` ile `git -C "$UNICORN_GIT" show <sha>:./<yol>`'dan okunur. Seam listesi = sha'daki `_vocabulary.md` §b ∪
  `V3_SEAMS = {hr.run_hires, hr.weeks_since_last_hire, build.last_unlocked_module} ∪ {build.module_unlocked.<id> : id ∈
  sha'daki UiTokens.TABS}`; `V3_SIGNALS = {customer_added, module_unlocked}`; v3 seam ve sinyal E değil W'dir, INDEX §4'e
  yazılır. Seam ve jeton regex'i `[a-z_]+(?:\.[a-z_]+)+` (pilot `:23` iki parçaya sınırlı).
- **CLI:** `cardcheck.py [--schema 3] [--chips] [--git-sha <sha>] <dosya...>`; `--schema` varsayılan 3 (P1/C1/V/O/T/E
  kuralları; pilot CLI'si yalnız `--chips`, `:761-765`).
- **Fiil kümeleri:** `SAFE` (`:26`) = §6.1'in 30'u; `SILENT` = §6.1'in sessiz 4'ü; `STUB` + `CHIPLESS` = §6.1 yasak 15;
  yeni `RESERVED` = 18.
- **Yeni kurallar (E):** motor PRD'si R9'un P1, C1, V1-V3, O1-O5, T1-T3'ü (§6.2 aynası; P2, P3 W); §5'in tutarlılık kuralları
  1-7; §6.2 yazar ekleri ve bağlam tablosu; çipli fiilsiz etkili seçenek (not kartı muaf, `is_note` aynası); `follows` ya
  pakette ya kaynağın kataloğunda; `family` adı biçimi; çalışan ailesinde aralık < 26.
- **Uyarılar (W):** §6.3 aralık dışı tutar; `on_expire` tutarı seçenek yarısından büyük; `min_week > 130`; istek/sinyal
  dışı kartta `min_week < 4`; v3 seam/sinyal; aynı aileden üç kart aynı bantta; seçenek başına tek etki.
- **Falsifikasyon:** her yeni kural için `OUT/_tools/fixtures/bad_<kural>.md` aracı düşürür (en az `bad_paper_no_expire_note`,
  `bad_silent_only`, `bad_hire_entity_latch`, `bad_unknown_seam`, `bad_family_gap`, `bad_crew_span`, `bad_ctx_<fiil>` ×9);
  `good_v3_seam.md`, `good_note.md`, `good_status_quo.md` ve `good_o4_one_slot.md` geçer. `run_fixtures.py` hepsini koşar ve
  `FIXTURES PASS <n>/<n>` basar. Pilotun 28 düğümü v3 bloğu olmadan koşulunca P1 hatası vermelidir.
- **Diğer araçlar:** `check_package.py` (§11 kabulü), `fire_join.py` (§13 ateş sayımı; entegrasyon turunda koşar).
- **Kabul:** `python -I _tools/run_fixtures.py` çıktısı INDEX §0'da; paketteki her kart 0 error; `--chips` çıktısı
  inceleme sayfasının çip satırlarıyla aynı (paketleyici aynı fonksiyonu çağırır). Bire bir sınaması: sha'daki 56 canlı
  karta O4, O5, T3 koşulunca motor §5 sonu listesinin 10 kartı ve şıkları çıkar (fark varsa dur, INDEX §7'ye soru).

## 11. Teslim (Y10)
`OUT` altında (pilot düzeni; departman yerine bant klasörü):
- `INDEX.md`: §0 sha, motor PRD blob'u, `ls-tree` ve `git status` kanıtı, fixture ve paket çıktısı, sınav · §1 matris ·
  §2 kart başına v3 tablosu · §3 puanlar (yedi ölçüt, denetim, yeniden yazım), kaynak, aile aralıkları · §4 entegrasyon
  notları (sprint listesi, yeni aileler, v3 seam/sinyal) · §5 düşen kartlar · §6 "onay bekliyor" · §7 sorular · arama sayısı.
- `<bant>/candidates.json`, `research_log.json`, `<kart_id>.md` (pilot BRIEF §13 şablonu + "Makullük": bant, kadro,
  kıdem, ürün, modül, aile, gecikme, her biri bir cümle gerekçeyle); `cards.json` (şema v3), `strings_draft.csv`.
- `review.html`: kart oyundaki gibi (gönderen, başlık, gövde, seçenekler, çipler EN/TR) + bant rozeti, makullük satırı,
  kaynak özeti, yedi puan; kart başına **onay / düzelt / ret** + not; işaretler `window.claude.use("db")` `v2_marks_r1`
  (turda bir artar; yoksa tarayıcıda, metin dışa alımı). Özel artifact (araç varsa), bağlantı INDEX'e; yoksa dosya.
- `MOTOR_ISTEKLERI.md`: her `[VOCAB?]`/`[COND?]` için istek, kartlar, en küçük tanım, boy (S/M), isteksiz hâl var mı;
  motor GDD'si §27 adayları. `_context/` (`OYUN_NOTU`, `SINAV`, `CAPALAR`), `_tools/`, `_internal/`.
- **Kabul:** `python -I _tools/check_package.py` üç kümeyi (`cards.json` id, INDEX §3 "geçti", `review.html` kartları),
  `strings_draft.csv` anahtarlarını kartların andığı anahtarlarla ve sha'daki `strings.csv` ile çakışmayı karşılaştırır,
  `PACKAGE OK n=<k>` basar; çıktı INDEX §0'a. Çakışma denetimi entegrasyonda o günün `main`'ine karşı yinelenir (§13).

## 12. Evre planı ve kapılar (commit yok)
| # | Evre | Kapı (geçmeden sonraki evre başlamaz) |
|---|---|---|
| F0 | Kaynak (Yol A klonu ya da Yol B `git show`, §2), yollar, pilot paketi, `OYUN_NOTU.md`, `cardcheck` v3 + fixture'lar | §2 kabulü; `FIXTURES PASS`; sınav 25/25 |
| F1 | Slate: bant × alt kota × aile planı (~120 fikir: hedef + %30 yedek), canlı desteyle eş taraması | Her hücre dolu; her aile `family_subject`'li; hiçbir fikir canlı karta eş değil (ayrı ajan onaylar) |
| F2 | Keşif (bant sırası: solo → team → traction → series_a) | §7 kabulü; bütçe sayacı |
| F3 | Ayıklama + uyarlama tablosu | Her adayın bant ve dünya uyumu yazılı |
| F4 | Yazım: EN → TR, kart dosyası, `cardcheck` 0 error | Yazar kartı ancak 0 error ile teslim eder |
| F5 | Kör eleştiri → kapı → en çok iki yeniden yazım | §9 kapısı |
| F6 | Denetim merceği (bant başına) | §9 denetim kabulü; düşen yerine yedek |
| F7 | Paket: INDEX, `cards.json`, CSV, `review.html`, `MOTOR_ISTEKLERI.md`; sayfa derleme sınaması | §11 kabulü; matris asgarileri ya da açık satırı |

`bootstrap_solo` ilk bant olarak F2-F6'yı tek başına geçer ve çapa kalibrasyonu olur: bu banttan kapıdan geçme oranı
%30'un altındaysa yazar durur, nedenini INDEX'e yazar ve rubriği değiştirmeden yazım yöntemini düzeltir.

## 13. Sahibin inceleme döngüsü ve entegrasyon turu (Y11)
**İnceleme döngüsü:**
1. **Onay** → entegrasyon kuyruğu. **Düzelt** → kart yeniden yazılır, YENİ kör eleştirmenden geçer (not karşılanmadıysa
   sert ihlal). **Ret** → düşer; asgari bozulduysa yedekten yazılır. Her tur `v2_marks_r<n>`, arşiv `_r<n>/`; önceki
   işaret kartın altında. Genel not kurala dönüşürse `CAPALAR.md`'ye ve §8'e eklenir.

**Entegrasyon turu (ayrı PRD, sahibin makinesinde; bu oturumun işi değil):**
- Ön koşul (hüküm E7): motor PRD'si V0-V8 `main`'de (derleyici, frenler, gecikme, lint P/C/V/O/T, V7 `--event-plausibility`, V8
  belgeler ve `_vocabulary.md`); A, B, C task'ları bitmiş. Motor PRD'sinin blob'u INDEX §0'dakinden farklıysa önce §2 ve
  §4 farkı okunur, `cardcheck` güncellenip pakete yeniden koşulur. Kart kimlikleri ve CSV anahtarları o günün `main`'ine
  karşı yeniden çakışma denetiminden geçer (C bu arada `frank_v1`, `paid_tier` ve CSV anahtarları ekliyor).
- Kartlar `data/events/cards/<kategori>/` altına, CSV bayt-span ekleme (`strings-csv-surgery`); sprint karar kartları
  `data/product/sprint.json` `decision.cards`'a, ama `sprint.json` B'nin dosyasıdır (PRD_SPRINT §1): B bittikten sonra.
- Kapılar: `--event-lint` 0 error (P1, C1, V1-V3, O1-O5, T1-T3 dahil); `-s res://scripts/debug/loc_residue.gd` + `bash
  tools/smoke_run.sh loc_csv_integrity` + `card_body_tokens_resolve` + `event_chip_coverage`;
  `--event-harness=random:seeds=10:weeks=12` `HARNESS PASS`; her yeni kart için `--why-fire=<id>` derlenen
  `[plausibility]` yapraklarını basar; motor PRD'si R13 `PLAUS SUMMARY runs=40 fails=0` (16 hafta, ayrı kapı).
- **Ateşlenme sayımı:** 44 koşu (`RunProbe.PRESETS`'in 11 `full_run*` preset'i × 4 tohum × 130 hafta, `run_probe.gd:61-74`,
  `--run-log=<preset>:130:sim:<seed>`, her koşu kendi `APPDATA`'sı). `PROBE FIRE` satırı (`run_probe.gd:391`) kadro
  taşımaz: `OUT/_tools/fire_join.py` her `PROBE FIRE`'ı aynı günün son `PROBE STATE ... emp= phase=` satırıyla
  (`run_probe.gd:443`) birleştirir, `FIRE id= day= emp= phase=` tablosu basar. Kabul (bu tablodan): yeni kartların ≥ %70'i
  en az bir kez ateşlenir, ateşlenmeyen her kart için `--why-fire` nedeni rapora; `once` aile özne başına ≤ 1; bir çalışan
  ailesinin farklı öznelere iki ateşi aile aralığından yakın değil; `newest_hire` ya da kıdem < 12 kart koşu başına ≤ 1;
  aile aralığı ihlali 0; 1-3. haftada sistem dışı ateş 0; `solo` kartı yalnız emp 0, `crew_1_2` yalnız emp 1-2, `crew_3plus`
  yalnız emp ≥ 3; bant başına ateş dağılımı tabloya.
- Sahip F5 ile oynar; "ne alaka" bulunan kart geri döner.

## 14. Sahibe bırakılan kararlar
1. Eleştirmen ve denetim ajanları Opus'ta mı koşsun (9/10 çıtası için)? Varsayılan Sonnet.
2. Sayım kuralı: kart yalnız `primary_band`'inde sayılır; not ve takip sayılmaz. Uygun mu?
3. Faz 1 ∧ kadro ≥ 3 (`crew_3plus`) hücresinin asgarisi ve hedefi kaç (bu PRD: asgarisiz, hedef 4; motor PRD'si §9.3)?
4. "Araştırma" Ar-Ge ağacı mı, ürün öncesi müşteri keşfi mi, ikisi mi (bu PRD: ikisi)?
5. Kart düşerse yedekten yazmaya devam mı, az kartla teslim mi (bu PRD: asgariler tutana dek yedek, sonra açık satırı)?
6. Onay bekliyor: §6.3 para tavanları ve `on_expire` yarı kuralı; §5 kıdem, gecikme, `min_week ≥ 4`, çalışan ailesi
   aralığı ≥ 26; §4 hedefler, alt kotalar, %40 pazar dengesi, %30 yedek, 3 not tavanı; §12 %30 kalibrasyon durağı.
7. Yeniden yazım listesi (§4) dışındaki canlı kartlar (28 pilot düğümü dahil) bu çıtayla yeniden puanlanacak mı? Kapsam dışı.
8. Ara kalibrasyon: `bootstrap_solo` bandı bitince sahip ilk 10-15 kartı görmek ister mi, yoksa yazar tüm paketi mi getirsin?

## 15. Erdem'in bakacakları
- `review.html` bant bant: makullük satırı (bant, kadro, kıdem, gecikme) hikâyeyle uyumlu mu; oyunun başı gerçekten ürün,
  sprint, kurucu ve 1-2 kişilik ekip mi; "her işe alımda aynı kart" yok mu; kurucu hiçbir şıkta eğitmen değil mi.
- Şıklar: "bu kurucu gerçekten bunu mu yapar?"; her şıkta artı ve eksi; bedel öznede.
- `MOTOR_ISTEKLERI.md` (hangi istekler yapılsın) ve INDEX §6 "onay bekliyor" sabitleri.

## 16. Doğrulama listesi
1. Kaynak sha'sı motor PRD'sini taşıyor; repo değişmedi (klonda `status --short` boş; sahibin makinesinde önce/sonra aynı,
   `git worktree list` tek satır).
2. `OYUN_NOTU.md` §3'ün 22 kaynağını dosya:satırla kapsıyor; sınav 25/25, ayrı ajan anahtarla puanladı.
3. `FIXTURES PASS`; paketteki her kart `cardcheck --schema 3` 0 error.
4. Matris asgarileri (10 / 20 / 20 / 20) ya da açık satırı; kart çift sayılmıyor; çalışan kartı iki kadro bandını kapsamıyor.
5. Her kartta, yeniden yazılanlar dahil, yedi ölçüt ≥ 9; yeniden yazım ≤ 2; denetim merceği her bantta, %25 örneklem INDEX'te.
6. Kullanılan fiil kümesi ⊂ 30; etkili her seçenekte çipli fiil; R9 aynası (§6.2) ve bağlam tablosu temiz; demo kartında
   `marketing_push` (O5) ve tek kişilik kartta `sprint_hours` (O3) yok; her `paper` kartta üst düzey `expire_note`.
7. Her çalışan ailesi `once` VE aralık ≥ 26; `employee_hired` sinyalli kart `one_shot`, `latch_key` run ve `hr.run_hires ==`.
8. WebSearch ≤ 60 ve sayaç INDEX ile eşit; her kartın kaynağı var; 15 kelimeyi aşan alıntı ve gerçek ad yok.
9. Metinde tire, "PH:", gün içi zaman, UI talimatı yok (grep çıktısı INDEX §0'da).
10. `check_package.py` `PACKAGE OK`; TR ve EN jeton kümeleri eşit.
11. İnceleme sayfası derleniyor (`new Function` + başsız render) ve işaret koleksiyonu adı INDEX'te.

## 17. Done mesajı
Sahibe: sha; sınav; bant başına aday / yazılan / geçen / düşen ve ortanca en düşük ölçüt; matris ve açık satırları; ton
dağılımı; WebSearch sayısı; bant başına en iyi iki kart (EN/TR, yedi puan); `MOTOR_ISTEKLERI` özeti; "onay bekliyor"
sabitleri; yeniden yazım sonucu (geçen / emekli); §14 soruları; sayfa bağlantısı ya da zip; `git status` kanıtı (§16.1).

## 18. Öğretici notlar
- **Çıta neden ölçüt başına 9.** Ağırlıklı ortalama zayıf şıkkı güçlü yazımla kapatır (pilotun 18 kartı böyle geçti);
  sahip kartı en zayıf yerinden okur. **Çapa olmadan 9 enflasyondur:** sahibin gerçek işaretleri ölçeği sabitler.
- **Tekrar bir şema hatasıdır.** `first_weeks` her çalışana bir kez geldiği için her işe alımda geldi: `entity` mandalı
  doğruydu, özneler arası fren yoktu. `family_subject.once` "bu kişiye bir kez", aile aralığı "kişiler arası uzun
  bekleme", `hr.run_hires ==` "bu şirkette bir kez" der.
- **Çip basılması etkinin düştüğünü kanıtlamaz.** `morale_all` kadro 0'da çip basar, kimseye dokunmaz: bağlam tablosu bu
  yüzden var. **Bant şirketin gerçeğidir:** kaynaktaki şirketin boyu kartın bandını belirler.
- **Yazar Godot koşmaz:** yazarda mekanik denetçi (R9 ile bire bir), entegrasyonda motor lint'i, `--why-fire` ve 44 koşu.
