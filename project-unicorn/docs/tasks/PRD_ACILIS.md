# PRD · Açılış: Frank'in çeki, ilk dakika, ilk saatin tuzakları

**Kim çalıştırır:** bir geliştirici ajanı oturumu. Başlatma cümlesi: "project-unicorn/docs/tasks/PRD_ACILIS.md dosyasını oku ve uygula."
**Durum:** yardımcı yönetmen taslağı, 2026-10-10; açık sorular aynı gün yardımcı yönetmen hükümleriyle (ortak §0, C-1…C-19, B-D4, F4–F8) kapandı ve gövdeye işlendi.
Erdem'e yalnız §7 gider (Frank metinleri + TR/EN tabloları). Kod okuması HEAD `0fe77fc` üstünde (grafik ön ayarları commit'i); `main.gd` 1539 sonrası,
`localization/strings.csv` ve `docs/HARITA.md` atıfları bu commit'e göre yeniden doğrulandı.
**Tek cümle:** yeni oyuncu ilk dakikadan seed kapısına kadar ne yapacağını ekranda görür; Frank'in çeki tek şart listesi olarak kabuğa işlenir; ilk saatte yakalanan
tuzaklar kapanır.
**Çıktı:** 16 commit (§6; S15 Frank kopyası onaydan sonra ayrı), Erdem'in F5 vereceği ekran görüntüleri (TR ve EN), ✅/⚠️/❌ raporu.

Kanıt kaynakları (yol değil, dosya:satır taşınır): araştırma R1 (duraklatma), R3 (benzer oyunlar), canlı oynama bulguları 2026-10-10 (O1-O4, S1-1…S2-7) ve 2026-10-07
notları.

---

## 0. Sahip kararları ve bulgu → gereksinim

Onaylı (2026-10-10): (1) Frank'in çeki 5 adımlık şart listesidir, görev sistemi değildir; "görev yok" hükmü "para verenin şartı serbest" diye daralır. (2) İntro
düğmesi Ürün'ü tip seçiminde açar; ilk Boşluk ipucu. (3) v1.0'da Frank'ten tebrik kartı, taslak ve pasif. (4) Tek seçenekli beat kartı saati tutmaz, nota döner,
geçmişte gövde kalır. (5) Süreli kâğıtlar görünür: zaten uygulanmış, yalnız TopBar Sıradaki dalı kalır (C-19). (6) Onboarding düzeltmeleri. (7) Piyasa rayda v1.0'a
kadar kilitli. (8) "Araçlar" kalem adı. (9) Belgeler.

Hükümler (2026-10-10, bağlayıcı) → yer: C-1 H · C-2 §1 · C-3 R5 · C-4 §2 · C-5 R1/§2 (F6 ile daraltıldı) · C-6 R1/R2 · C-7 R10 · C-8 R6/§7 · C-9 R5 · C-10 R4 · C-11 R11 ·
C-12/C-13/C-14/C-15 R8 · C-16 R12 · C-17 R4 · C-18 R5 · C-19 R7 · B-D4 R13 · F4 §7.5 · F5 R17 · F6 R15 · F7 R16/§2 · F8 başlık, §1, atıflar. Çapraz denetim (Ek, U
maddeleri): U6 §2/R3/C13 · U7 C8 · U10 §1/R8 · U11 R12. Senaryo pürüzleri §0b → R5, R11, R14–R17, §7.

| Bulgu (kanıt) | Gereksinim |
|---|---|
| Hedef iki yüzeyde gömülü ve farklı söylüyor: Finans "Traction'a 0/3" (`finance_ozet_view.gd:294-325`), Kişisel "Bu fazın hedefi" (`personal_tab.gd:12,197-199`) (S1-4) | R1, R2 |
| İntro kapanınca oyuncu duraklı dairede yönsüz kalıyor; düğme yalnız kapatıyor (`mail_pane.gd:137-139`, `_close` :764-765) (S1-1) | R4 |
| Tek seçenekli "Birikim", "Tek kişilik şirket" saati tutuyor, geçmişte gövdesi yok (2026-10-07 notları) | R5 |
| v1.0'ın kutlaması yok (2026-10-07: "Zero celebration for the first milestone") | R6 |
| "Yan iş" kâğıdı görülmeden doldu (2026-10-07) | R11 (R7 düştü, C-19) |
| Köken adları TR ekranda İngilizce (O1); İleri sönük ve gerekçesiz (O2); yetenek vaadi yanlış (O3); sahte seçim (O4) | R8 |
| Kişisel "Huylar · YAKINDA" sahte yüzey (S1-6); huy kartları bağlı olmayan etki vaat ediyor | R8 |
| Piyasa 1. haftada 39 şirketlik bağlamsız liste (S1-7) | R9 |
| Finans gider kalemi "Araçlar $1,5K %100" (S1-5) | R10 |
| Şirket adı kabukta yok, marka "Project Unicorn" (S1-1) | R11 |
| Tek kartlı sprintte "devret" sprinti boşaltır, kart bunu söylemiyor (Sprint B6) | R13 |

### 0a. Brief'ten farklar (kodla çelişen ifadeler; hükümlerle kapandı)

| Brief | Kod gerçeği (kanıt) | Bu PRD'de |
|---|---|---|
| Finans kutusu `scripts/tabs/finance/finance_tab.gd` | Kutu `scripts/tabs/finance/finance_ozet_view.gd:294-325` (`_refresh_goal`); `finance_tab.gd` `scripts/tabs/` altında ve kutuyu taşımıyor | C yalnız `_refresh_goal`'a, A'dan sonra hunk bazlı; A aynı dosyada yalnız sinyallere (57-85) |
| CSV `data/localization/strings.csv` | `localization/strings.csv` | Doğru yol; yalnız C anahtarları, bayt-span |
| Beat kuralı "`options.size()==1` ve `interrupt` değilse" | Katalogdaki 22 tek seçenekli kartın 20'si `class: interrupt` (Birikim ve Tek kişilik şirket dahil); `paper` olan ikisi (`funding.seed_stalled`, `world.final_stretch_press`) zaten kuyruğa girmez (`engine.gd:384-389`); `unwired/` katalog dışı (`catalog.gd:17`). Kural yazıldığı gibi hiçbir kartı değiştirmez | Ayırıcı: tek seçenek ∧ etkisiz ∧ `critical` değil ∧ `class != "paper"`; `quiet` etiketi gerekmez (C-3, R5) |
| "MRR eşiği `funding.frank_cheque` koşulundaki değer" | Kart değer taşımaz; seam `funding.angel_threshold_met` (`seams_ported.gd:108-110`) `AngelRoundSystem.MRR_THRESHOLD = 2500`'ü okur (`angel_round_system.gd:27`) | ChequeRead sabiti oradan okur |
| Örnek kopya "Yazılım: hata oranı ve canlı ürünün aşınması" | Aşınma Test becerisini okur (`product_system.gd:136`); hatalı kart rol eksikliğinden gelir (`sprint_system.gd:543-544`); kurucunun sprint puanı beceri okumaz (`sprint_system.gd:938-948`, `sprint.json:21`) | Düzeltme kabul (C-15): §4 beceri tablosu |
| R7: kâğıt son haftasında yığında ve rozette, dolunca geçmişte "süresi doldu" | Üçü de var: `office_notice_stack.gd:99-129`, rozet `left_tabs.gd:281-284`, `EXPIRED` satırı `engine.gd:111-112`, "Süresi doldu" damgası `inbox.gd:50-53,219-227` | Madde düştü (C-19); yalnız TopBar Sıradaki (R11, A sonrası) |
| "Araçlar" → "Kurucu geçimi" | `FIN_BURN_TOOLS` evre tabanı + çalışan başı koltuk bedeli (`finance_system.gd:13-14,218-221`); 2026-10-02 hükmü ayrı kurucu geçim kalemini kaldırdı (`GDDs/GUNCELLEMELER.md:248`) | "Geçim ve araçlar / Living and tools" (C-7, R10) |
| "Rakip dünyasında görev yok" hükmü ACIK_KARARLAR'da | Hüküm `docs/tasks/PRD_RAKIP_DUNYASI.md:21` (karar A) | Daralma notu oraya ve GUNCELLEMELER'e (C-16, R12) |
| İntro düğmesi `goto_tab_requested.emit("product","")` | `mail_pane.gd:758-761` zaten `_go(tab)` taşıyor (Ar-Ge notu aynı yolu kullanır, :152) | `_go.bind("product")` (C-17) |
| 2026-10-07 gövde hatası tek seçeneğe özgü | `mail_pane.gd:119,558-560` `_static_body` gövde düz String değilse ya da `{seam:` taşıyorsa false: `{seam:` taşıyan ya da `by_seam` varyantlı HER kartın gövdesi geçmişte silinir (`working_parts.json:41-47` dahil) | Genel düzeltme: sayı ve bool seam'i çözümde donar, TYPE_STRING donmaz (C-18, R5; kalanı §7.4) |
| C'nin dosya listesi | Kabul kapıları `endgame_smoke.gd`, `harness.gd`, `event_gate.gd`, `ui_tokens.gd`, motor md §27, `main.gd` harness kollarını da ister | C'ye verildi (C-1, C-2; §1) |
| `--office-shot=…:toast` | `toast` eki var (`main.gd:1056-1057`, `_shot_toasts` :1111-1138: kayıt, kaydedilmedi, erteleme, taşınma, yükleme tostları) ve tema tohumunda koşar (`_seed_theme_surface`, gün 14, `main.gd:985-987,1024`): Boşluk ipucu (gün 1) ve "2/5" tostu çıkamaz | H'de yeni ek `cheque` (C-1) |

### 0b · Senaryo pürüzleri

Kaynak `SCENARIO_SNAGS.md` (HEAD `1e2d9a0`). Task sütunu `ACILIS` olan 27 satırdan yıldızlı beşi (S13, S19, S21, S24, S55) ve ONARIM 1 §1'deki S12 hariç: 21 satır; F5 ile
C'ye geçen S03, S04, S15, S37 payları R17'de. Kanıtlar `0fe77fc`'de doğrulandı. "§7.3/§7.4" = §7'nin 3. ve 4. maddesi, C planlamaz.

| id | sev | başlık | kanıt | karşılayan |
|---|---|---|---|---|
| S01 | major | Hiçbir ekran ilk işi (Ürün) göstermiyor | İntro düğmesi yalnız `_close` (`mail_pane.gd:139`, :764-765); Sıradaki `TOPBAR_NEXT_WORKDAY_END`'e düşüyor (`top_bar.gd:209`); ilk hafta yığın boş. | R4 (düğme → Ürün seçici), R3 (kâğıt + yığın satırı "Ürün tipini seç"), R11 (Sıradaki). Ray rozeti eklenmez: üç yüzey aynı adımı söylüyor. `main.gd:2803` bayat yorum → §7.4 (A) |
| S10 | major | Tek düğmeli beat'ler her hafta saati durdurup pencereyi kaplıyor | Her interrupt `hold_clock` + `INBOX.show` (`main.gd:2866-2885`); taban 1 sessiz haftada doluyor (`engine.gd:313-348`); `company_of_one` kepenk içinde de geliyor. | R5 (not; saat tutulmaz). Kepenk haftası için `company_of_one.json` koşul yaprağı var olan kartın koşulu (BRIEF yalnız yeni kart) → §7.4 |
| S11 | major | 1 haftalık kâğıtlar (Yan iş, Sprint yetişmeyecek) uyarısız doluyor | `is_expiring` ömrü > `EXPIRY_URGENT_WEEKS` ister (`papers.gd:75-82`, `tuning.gd:83`): son uyarı yok; yığın pencerelerin altında. | R11 (a) dalı `weeks_left <= 1` okur, 1 haftalıklar dahil; son hafta tostu ertelendi (C-11) |
| S23 | major | Frank'in çeki ilk adlı hedef, şartı ($2.500) hiçbir ekranda yok | `MRR_THRESHOLD` yalnız seam okuyor (`seams_ported.gd:108-110`), hiçbir dize 2.500 taşımıyor. | R1–R3 (5. adım çıtayı basar). Harita kartı bağlantısı ve "Ofisi taşı" notu → §7.4 (Onarım 1 D) |
| S25 | major | Hedef listeleri çelişiyor, parayı getiren adımı adlandırmıyor | Finans P1 Traction kapısını yansıtıyor ve `get_all()` sayıyor (`finance_ozet_view.gd:302-305`), kapı `get_active()` (`seams_sales.gd:80-82`). | R1, R2 (tek kaynak, P1 kolu silinir; B2C 4. adım `b2c_paying_users`). Kişisel dönüm taşları (`game_state.gd:727-737`) kayıttır, hedef değil: değişmez |
| S26 | major | Traction kartı tek "Tamam", ne evreyi ne sonraki basamağı söylüyor; yığında gömülü | Tek seçenek `GATE_TRACTION_ADVANCE` "Tamam" (`strings.csv:1283`), çip genel `EFFECT_PHASE_ADVANCE` (`chips.gd:40`). | Kısmen: sonraki basamak R2/R3/R11. Düğme metni (`GATE_TRACTION_ADVANCE`, C anahtarı değil) ve `launch_leak` kaydırması (Onarım 1 A) → §7.4 |
| S27 | major | Traction boyunca sonraki basamak (çek, seed) adsız | 2. evre kartı yalnız başlık (`finance_ozet_view.gd:306-307`); seed çıtası basılmıyor (`seed_constants.gd:19-21`). | R1 ikinci liste (C-6), R2, R3, R11 |
| S28 | major | Açılışta Devam/Yükle yok, dönen oyuncu sahte şirket kurmak zorunda | `main.gd:107-110` her açılışta dil kapısı ya da onboarding; `save_load_requested` yalnız kabukta bağlanıyor (`main.gd:2840`). | → §7.4 (sahipsiz `main.gd` açılış yolu) |
| S29 | major | Zorunlu yeni koşunun otomatik kayıtları eski koşununkileri eziyor; satırda şirket adı yok | `_next_auto_slot_id` en eski auto yuvasını koşudan bağımsız eziyor (`save_manager.gd:382-394`), `_slot_row` (:466) adı düşürüyor. | → §7.4 (A `save_manager.gd`; `save_load_modal.gd` sahipsiz) |
| S31 | major | Koşu uyarıdan önce kurtarılamaz, kepenk tavsiyesi ürünsüz koşuda imkânsız, bitiş nedensiz | `SHUTTER_WEEKS 4` (`endings_system.gd:25`) solo MVP'den kısa; kepenk metni "yeni müşteri bul" diyor. | Kısmen R3/R11 (ürün adımı her yüzeyde). Frank satırı, kepenk metni, bitiş nedeni → §7.3/§7.4 |
| S35 | major | Finans yatırım okumaları yanlış basamağı ve olmayan kapıyı söylüyor | `FIN_SUBTAB_LOCKED` "Series A Avı'nda açılır" seed kapısında açılan sayfada (`finance_tab.gd:107-109`); çip canlı MRR'den 'open' (`phase_gate_system.gd:146`). | Kısmen R2 (seed listesi). Kilit gerekçesi ve çip → §7.4 |
| S36 | major | Seed'in büyüme sözü yalnız imzadan sonra yazılıyor | Onay ve imza metinleri (`strings.csv:2426,1340`) `EXPECT_MOM_PCT`'yi söylemiyor (`seed_constants.gd:113-115`); söz yalnız `seed_lead` dalında (`hunt_tab.gd:146-152`). | R16 (F7): seed listesi imzaya dek açık, söz pitch'ten ve imzadan önce okuma bölmesinde (§2). Pitch onayı (`hunt_tab.gd:222`) ve imza (`term_sheet_table_scene.gd:390`) metinleri değişmez |
| S40 | minor | "Konuşma daveti" Cevapla'da kayboluyor; "İlk bakış" 2 haftalık kâğıda "bu hafta" diyor | Kabul koşulunda `sprint_running` (`meetup_talk.json:21-25`), `open_paper` G7'de siliyor (`engine.gd:605-612`), UI false'u yok sayıyor (`mail_pane.gd:499`). | Kısmen R14.1 (açılamayan kâğıt tost atar). `meetup_talk` koşul yaprağı ve `EV_FOUNDER_FRIENDS_BODY` → §7.4 |
| S41 | minor | Sessiz havuz ürün öncesi ve B2C yayını sonrası ince | Motor "quiet pool is too thin" uyarıyor (`engine.gd:341-342`). | Kısmen: R5 notları saat tutmaz. Ürün öncesi meetup ve yeni kart → §7.4 |
| S46 | minor | İntro "onu beş geçiyor" derken saat 08:00 | `MENTOR_INTRO_BODY` (`strings.csv:1615`) mühürlü Frank metni; saat `WEEK_START_HOUR` 8. | → §7.3 (Erdem) |
| S47 | minor | Geçmiş `{seam:}`/`by_seam` taşıyan her kartın gövdesini düşürüyor | `_static_body` (`mail_pane.gd:119,558-560`). | Kısmen R5 madde 3–4 (C-18): sayı seam'li gövdeler donar (katalogda 12 kart, dört not kartı dahil). TYPE_STRING seam taşıyan 15 kartın gövdesi geçmişte yine düşer (altı `urun.decision_card` sprint kartı, `sprint_late` R13 "1" dahil; `rival.leader`, `musteri.*`, `hr.resign_voice`, `funding.acq_*`, `investor.est_*`) → §7.4 "S47 kalanı" |
| S50 | minor | Hafta içi iş kaydedilmiş sayılıyor, kayıt/yükleme geri bildirimsiz | `_dirty` yalnız gün tikinde (`save_manager.gd:341`); menüden yükleme tostsuz (`main.gd:3277`). | → §7.4 (A `save_manager.gd`; modallar sahipsiz) |
| S51 | minor | F9 onaysız ve sessiz reddediyor, F5/F9 yazılmıyor, "Kaydet ve çık" hızlı yuvayı eziyor | F9 modal bekçilerinden önce (`game_shell.gd:57-66`), doğrudan `_load_slot` (`main.gd:3298-3301`); `system_menu_modal.gd:77` quicksave. | → §7.4 (A `game_shell.gd`; modallar sahipsiz) |
| S54 | minor | Ayar artıkları: kurucu varsayılan adı tek dilde donuyor, Efektler boş, yolculukta AYARLAR ölü tık | Çevrilmiş ad kaydediliyor (`game_state.gd:935-938`); `_in_transit`'te sessiz dönüş (`main.gd:3198-3200`). | → §7.4 (sahipsiz `game_state.gd`; A `settings_modal.gd`, `main.gd`) |
| S56 | minor | Çek kartı: bayat açılış, sahte Reddet, nadir koşuda sessizce kayıp | Mandal kabulde harcanıyor (`engine.gd:393-395`), `pump` G7'de düşürüyor (:433-439), seam canlı MRR (`seams_ported.gd:108-110`). | R15 (mandal iadesi, F6); düşen satır listeyi kapatmaz (§2, C-5 daraltıldı). Açılış metni ve Reddet kilidi → §7.3 |
| S57 | minor | "İK'ya git" Ekip sekmesine; kapı hatırlatıcısı Finans'a gidiyor | `ANGEL_NUDGE_ACK` (`strings.csv:438`) ↔ `TAB_HR` "Ekip" (:457); hatırlatıcı `active_id`'ye bakmadan "finance" (`inbox.gd:86-88`). | Kısmen R14.2 (hatırlatıcı kapı kartı varken susar, Finans'a gitmez). `ANGEL_NUDGE_ACK` metni → §7.4 |

## 1. Kurallar

- `CLAUDE.md` bağlayıcı: §3 (doğrudan main, push yok, tasarım sabiti "onay bekliyor", TR metni "TR/EN onay bekliyor", Frank satırı yalnız taslak), §5 (BILINGUAL
  BIRTH, önce İngilizce, tire yok, `static func` içinde `tr()` yok; ek yer tutucuya bitişmez: `{tab} sayfasına git`, `Seed turu: aylık gelir {bar}`), §7 UI/STYLE LAW
  (koyu yüzey yalnız `D_*`), §8-§9 (kısa kod; her commit öncesi ayrı ajan incelemesi), §10 (yeni smoke yalnız çekirdek: ChequeRead ve olay motoru), §11 (fikstürle
  ekrana gel, en çok 2 düzeltme turu), §12 (kapı sırası).
- **Sıra kesin: A (SAAT) → B (SPRİNT) → C.** İçerik/veri/onboarding işi (C1, C2, C4, C5, C6, C7 = R10, C11, C12) A ile paralel başlar; `main.gd`, `top_bar.gd`,
  `finance_ozet_view.gd` hunk'ları (H, C3, C8; H'ye bağlı C14) ve belgeler (C10) SAAT K10 main'de olunca (PRD_SAAT §12: A bu dosyalara K1-K8 boyunca dokunur); C9 B'nin
  `urun.sprint_single_card` seam'i, C15 B'nin `crunch_finishes()` commit'i, C13 B commit 8 inince (U6). `game_shell.gd`'ye C dokunmaz.
- **Ağaç paylaşımlı.** `git status --short` ile başla. Başkasının hunk'ına dokunma; kirli dosyada yalnız kendi hunk'larını `git apply --cached` ile stage et, commit
  ağacını `git checkout-index` ile geçici dizine kurup kapıları orada koş. `git checkout -- <yol>`, `reset --hard`, `stash`, `clean` yasak. **Canlı ağaç:** ağaç şu an
  temiz (grafik ayarı işi `0fe77fc` olarak indi; commit'lenmemiş yabancı iş yok). Kural kalır: her oturum `git status --short` ile başlar, kirli dosyada yalnız C
  hunk'ları. Satır numaraları `0fe77fc`'nindir; kayan hunk işlev ya da anahtar adıyla yeniden bulunur.
- **Ortak dosyalar.** `finance_ozet_view.gd`: C yalnız `_refresh_goal` (294-325), A'dan sonra, hunk bazlı. `localization/strings.csv`: yalnız C anahtarları,
  bayt-span ekleme (dosya yeniden yazılmaz; token `[a-z_]+`, iki dilde aynı). `top_bar.gd`: A main'deyken, A'nın satırlarını değiştirmeden iki dal. `main.gd`: C
  yalnız kendi harness kollarını ayrı hunk olarak ekler (H), saat/hız/tutuş yollarına dokunmaz. `main.gd`, `top_bar.gd`, `finance_ozet_view.gd` numaraları
  `0fe77fc`'nindir; A sonrası kayar, hunk'ı işlev adıyla (`_run_inbox_shot`, `_run_office_shot`, `_run_tab_shot`, `_refresh_brand`, `_refresh_goal`) yeniden bul.
- **C'ye verilen sahipsiz dosyalar (C-2, F5, F6):** `scripts/events/event_gate.gd` (`mark_read`), `scripts/events/tools/harness.gd` (`BEAT_MODAL` sayacı),
  `scripts/theme/ui_tokens.gd:298` (Piyasa kilidi), olay motoru md §27.17-18, `data/events/cards/product/sprint_late.json` (B-D4, F5), `paid_tier.json` (F5),
  `scripts/events/core/latches.gd` ve `engine.gd` `pump` 433-439 (F6). `UiTokens.TABS` tema token'ı değildir (`build_theme.gd` okumaz), THEME_STAMP artmaz.
- **Dokunulacak dosyalar (brief + C-2'ye ek).** `scripts/systems/founder_constants.gd:75` (U10, R8); `seams_product.gd`'de iki seam satırı (R17; B'nin commit'inde yoksa
  B'den sonra ayrı hunk); `CLAUDE.md` §6/§12 yalnız C'nin bayrak satırları, A'dan sonra, hunk bazlı (U10); yeni tema token'ı gerekirse yalnız kendi token'ı için
  `ui_tokens.gd` + `build_theme.gd` + iki tema (U10). `finance_tab.gd` brief'te yalnız hedef kutusu için verildi, kutu orada değil (§0a): C dokunmaz. Başka var olan
  kartın koşulu, `core/*.gd`'de tek-seçenek yolu, seam dondurma (C-18) ve mandal iadesi (F6) dışı iş, C'nin olmayan CSV anahtarı ve 0b'nin sahipsiz ya da başka task'a
  düşen dosyaları §7.4.
- **`endgame_smoke.gd`:** C yalnız `cheque_read_steps`, `event_beat_is_note`, `event_beat_freezes_seams`, `event_critical_drop_refunds_latch` (F6) vakalarına dokunur.
  C'nin değişikliği başka vakayı kırarsa C düzeltir ve raporlar; adaylar: `quiet_cards_fill_empty_floor` (`endgame_smoke.gd:17060`, not yolu `fire_count`'u korumalı),
  `onboarding_pages_contract`, `rail_tabs_match_scene_order`, `rnd_rail_open_with_waiting_page`, `seed_door_number_never_rendered` (15553; yeşil kalır, §11'e bak),
  `angel_*` (:259-266; R15), `sprint_late_only_when_behind` (:461), `sprint_paid_plan_opens_paid_tier` (:445; R17).
- Alt ajanlar Opus ya da Sonnet; Fable değil. İşletim sistemi düzeyinde fare/klavye girdisi yok. Pencereli Godot koşuları sırayla, her biri kendi `APPDATA`'sında;
  başlamadan `tasklist | grep -i godot`; kendi başlatmadığın süreci kapatma. Ekran istemeyen her koşu `--headless`.
- **Saat bütçesi.** A saatlik adım için ≤ 3 ms hedefliyor. C saatlik ya da `mrr_changed` sinyaline yeni abone eklemez; ChequeRead bayrak ve sayaç okur, döngü kurmaz
  (TopBar onu her `hour_changed`'de okur).

## 2. Hedef yüzeyleri envanteri ve ChequeRead türetimi

| Yüzey | Bugünkü kaynak (HEAD) | Açılıştan sonra |
|---|---|---|
| Finans "Traction'a 0/3 · Sürüm + ilk müşteri + ilk gelir" | `finance_ozet_view.gd:302-305`: `is_live + not CustomerRegistry.get_all().is_empty() + mrr > 0`; anahtarlar `FIN_GOAL_P1_LABEL/META` (`strings.csv:153-154`). `get_all()` pasif kaydı ve 0 ödeyenli B2C toplu kaydını da sayar, kapının yaprağı `get_active()` sayar (`seams_sales.gd:80-82`) | 1. evrede her zaman bir liste açık (çek ya da seed) → 1. evre kolu ulaşılmaz, silinir (R2) |
| Kişisel "Bu fazın hedefi" | `personal_tab.gd:12` `GOAL_KEYS`, :197-199; `PER_GOAL_*` (`strings.csv:366-369`) sabit cümle, ilerleme yok | Liste açıkken ChequeRead; `PER_GOAL_BOOTSTRAP` ulaşılmaz, silinir |
| Faz kapısı 1→2 | `phase_gate_system.gd:38-47`: `urun.is_live`, `musteri.count ≥ 1`, `finance.mrr > 0`; mandal `:68-91` | Değişmez |
| Faz kapısı 2→3 | `phase_gate_system.gd:48-64`: yalnız `finance.mrr ≥ TRACTION_MRR_TARGET`, rakam basılmaz (`:52-53`) | Değişmez; Series A çıtası basılmaz (C-6) |
| Seed kapısı | `seed_round_system.gd:41-49` `door_open`, `:52-53` `page_unlocked`; `DOOR_MRR = 20_000` [ÇALIŞMA] (`seed_constants.gd:21`); bugün basılmıyor | Çekten sonraki ikinci liste, çıta ekranda (C-6), imzaya dek açık (F7) |
| `funding.frank_cheque` | `frank_cheque.json:16-33`: `urun.is_live` ∧ `funding.angel_threshold_met` ∧ ¬`investor.angel_taken`; `critical`, `one_shot` | Değişmez; ChequeRead aynı üç okumayı yapar |

**ChequeRead listeleri.** `ChequeRead.list()` → `"cheque"` | `"seed"` | `""`; `steps()` → `[{id, done, text_key, tab}]` (etkin listenin); `summary()` → `{list,
title_key, done, total, next}`, `next` ilk `done == false` adım, hepsi bittiyse `{}`. Liste yokken `summary() == {}`, `steps() == []`. MRR adımları ayrıca `value`
(canlı MRR) ve `target` taşır; `{bar}` ve `{mrr}` `Fmt.money_chip` ile biçimlenir ("$2.5K", "$20K"; `fmt.gd:129-142`). Metin anahtardır; `tr()` çağıran UI'dır.

| # | id | `done` (B2C) | `done` (B2B) | tab |
|---|---|---|---|---|
| 1 | `type` | `SprintSystem.is_typed()` (`sprint_system.gd:308-309`) | aynı | product |
| 2 | `sprint` | `is_typed() and (mode() != "plan" or sprint_number() > 1)` (`:312-317`; tür seçimi Sprint 1'i `plan`'da açar `:62-66`, başlatma `active` yazar `:143`) | aynı | product |
| 3 | `ship` | `ProductState.is_live()` (`product_state.gd:35-36`) | aynı | product |
| 4 | `paying` | `SalesSystem.b2c_paying_users() > 0` (`sales_system.gd:274-276`) | `CustomerRegistry.account_count() > 0` (`customer_registry.gd:48-53`) | sales |
| 5 | `mrr` | `GameState.mrr >= AngelRoundSystem.MRR_THRESHOLD` (seam ile aynı ifade, `seams_ported.gd:109`) | aynı | sales |
| s1 | `traction` | `GameState.phase >= 2` | aynı | sales |
| s2 | `seed` | `SeedRoundSystem.page_unlocked()`; `target = SeedConstants.DOOR_MRR` | aynı | finance |

- Adım 2 B'nin üç yolunda da kapanır: "Bu sprinti boş geçir" (`skip()`, B-K4) oyuncunun açık onayıdır; boş otomatik başlatma (B-K3) ve devirle PM başlatması (B-K5)
  oyuncunun planı sayılır (PRD_SPRINT S7).
- `"cheque"`: `GameState.run_angel_amount == 0` (`accept_offer` yazar, `angel_round_system.gd:46-49`) ve `funding.frank_cheque`'in son geçmiş satırı ne `chosen` ne
  `expired` (`EventGate.condition_met` `{"history": "resolution", …}` yaprağı, `condition.gd:266-269` → `EvHistory.last_resolution`, `history.gd:91-92`, O(1)). Ret de
  cevaptır, listeyi kapatır; `dropped` satır (`engine.gd:433-439`) kapatmaz: mandal iade edilir (R15), liste canlı 5. adımla 4/5'e iner, kart geri gelir (C-5, F6).
- `"seed"`: çek listesi kapalı ∧ `GameState.phase <= 2` ∧ imza yok (`seed_lead == ""`, `game_state.gd:602-607`) ∧ tur yanmadı
  (`not (seed_pitch_used and seed_sheet == null and not VCPitchSystem.is_active())`). Kapı açılınca 2/2'de imzaya dek açık kalır (F7, R16). Başlık `SEED_SECTION_TITLE`
  (mevcut). Son adımları kendi kritik kartları duyurur (`funding.frank_cheque`, `funding.seed_door`).
- `next == {}` (çekte 5/5: kart kuyrukta, masada ya da ekranda, satır yalnız çözümde, `history.gd:28-32`; seed'de 2/2): kâğıdın konusu `GOAL_TOAST` (`{title} · 5/5`),
  sekmesi çekte `"events"`, seed'de `"finance"` (`CHEQUE_GO`; pitch orada); tost gövdesi boş; TopBar (b) dalı atlanır; Finans ve Kişisel `CHEQUE_NEXT` çizmez.
- Pazar: `SalesSystem.is_b2b_market()` (`sales_system.gd:137-138`); tür seçilmeden B2C dalı okunur.
- 4. ve 5. adım CANLI (C-4): müşteri giderse ya da MRR düşerse işaret kalkar (kapının mandal öncesi okuması gibi).
- U6: B2C'de `sales` sekmeli adımlar (4, 5, s1) B commit 8 (Satış B2C sayfası) inene dek `product`'a gider (HEAD'de Satış B2C'de boş hâl, `sales_tab.gd:218-232`);
  tek yer `cheque_read.gd`'de `B2C_MONEY_TAB` sabiti; C13 onu `"sales"` yapar.
- Finans, Kişisel, kutu, yığın, tost ve TopBar yalnız `summary()`/`steps()` okur. Tek kaynak budur.

## 3. Gereksinimler

### R1 · `ChequeRead` (yeni, `scripts/systems/cheque_read.gd`)
- **Ne:** `extends RefCounted`, statik, **`class_name` yok**; okuyanlar (`finance_ozet_view`, `personal_tab`, `inbox`, `mail_pane`, `office_notice_stack`, `top_bar`,
  smoke) `const ChequeRead := preload("res://scripts/systems/cheque_read.gd")` ile alır (`bar_kit.gd:7-9` deseni: paylaşılan ağaçta yeni `class_name` öteki
  oturumların başsız koşularını class-cache yarım kalınca düşürür). §2 tabloları birebir. Durum tutmaz, kayda girmez, `reset_all_owners`'a girmez. Sabit tutmaz:
  eşikler `AngelRoundSystem.MRR_THRESHOLD` ve `SeedConstants.DOOR_MRR`'dan.
- **Neden:** iki yüzey aynı hedefi farklı söylüyor (§2); brief'in tek kaynak kuralı; çekten sonra hedef boşluğu (C-6).
- **Kabul:** smoke `cheque_read_steps`. Fikstür günlük tik koşturmaz. B2C: tür (`SprintSystem.choose_type`) → `SprintSystem.apply_lead()` + `SprintSystem.start()`
  (açık çağrı, B-D1) → yayın: B indiyse `SprintSystem.publish()`, inmediyse `mvp_shipped` bayrağıyla doğrudan → ödeyen
  `CustomerRegistry.set_seats(SalesSystem.B2C_USERBASE_ID, 1)` (userbase kaydı `_seed_b2c_world` deseniyle) → MRR 2.500 (`SalesSystem.reflect_mrr()` ya da
  `GameState.set_mrr`). B2B'de 4. adım hesap eklemeyle. Her basamakta `summary().done` 0..5 ve `next.id` beklenen; ödeyen sıfıra inince 4. adım `done == false`;
  `accept_offer()` sonrası `list() == "seed"`, `done` 0/2; `GameState.phase_gate_ready = true; GameState.pending_next_phase = 2; GameState.advance_phase()` sonrası
  1/2 (`game_state.gd:364-368`); `seed_door_open_day = day` sonrası `"seed"` 2/2, `next == {}` (F7); `GameState.record_seed_round(…)` ya da teklifsiz yanan pitch
  (`seed_pitch_used = true`) sonrası `list() == ""`, `summary() == {}`. Geçmiş dalları (C-5, F6): `funding.frank_cheque` için `DROPPED` satırında `"cheque"` kalır,
  `EXPIRED` satırında `"seed"`. Falsifikasyon: 2. adımı `mode() != "plan"` yalnızına indirince vaka düşmeli (sprint 2 planındaki koşu); geçmiş okuması `fire_count`'a
  çevrilince `DROPPED` dalı düşmeli. C9'da `skip()` dalına bir assert eklenir.

### R2 · Finans ve Kişisel aynı sayıyı söyler
- **Ne:** `finance_ozet_view.gd` `_refresh_goal` (294-325): `ChequeRead.list() != ""` ise evreden bağımsız başlık `title_key`, sağda `FIN_GOAL_PROGRESS` (`{met}/{total}`,
  `strings.csv:1569`) ile `done/total`, satır `CHEQUE_NEXT` (`next` boşsa satır yok), çubuk `done/total`. Liste yokken bugünkü `match`'in 2. ve 3. kolu. 1. evre kolu
  (302-305) ve `FIN_GOAL_P1_LABEL/META` (yalnız orada okunuyor) silinir (CLAUDE §8). `personal_tab.gd:197-199`: liste açıksa başlık `PER_PHASE_GOAL`, altında `GOAL_TOAST`
  ("Frank'in çeki · 2/5") ve `CHEQUE_NEXT`; kapalıysa `GOAL_KEYS` (evre 2 ve 3; `PER_GOAL_BOOTSTRAP` silinir, dizi evreyle anahtarlanır).
- **Neden:** S1-4; `get_all()` ile `get_active()` ayrışması 1. evre kolu silinince kapanır.
- **Nasıl:** iki pencere de açılışta kurulur; yeni sinyal eklenmez (Finans `version_shipped`, `customer_added`, `equity_changed` dinliyor,
  `finance_ozet_view.gd:63,69-71`; evre ve seed kapısı günlük tikte, seed imzası `equity_changed`'le değişir).
- **Kabul:** `--tab-shot=finance:cheque` ve `--tab-shot=personal:cheque` (H) ikisi de "2/5" ve aynı sıradaki adımı basar (TR ve EN); `--tab-shot=finance:seed` ve
  `personal:seed` (H) ikisi de "Seed turu · 0/2" ve "Seed turu: aylık gelir $20K".

### R3 · Gelen kutusu kâğıdı, ofis satırı, tost
- **Ne:**
  1. `inbox.gd` `desk()` (73): liste açıkken listenin BAŞINA `_reminder("goal", "DESK_PAPER_TAG_FUNDING", _desk(TranslationServer.translate(title_key),
     GameState.company_name), TranslationServer.translate("CHEQUE_NEXT").format({"step": TranslationServer.translate(next.text_key)}), next.tab)` (`next == {}` için
     §2); ek alanlar `goal: true`, `value: "2/5"` (satırın sağındaki rakam `events_tab.gd:312-319` mevcut dalından). `inbox.gd` statiktir (`extends RefCounted`,
     `static func desk()`): `tr()` yasak, dosyanın geri kalanı gibi `TranslationServer.translate` (:88, :93, :102-103). Gönderen Frank değil (Frank satırı taslak
     kuralı): kâğıdın başlığı listenin başlığı.
  2. `connect_changes` (`inbox.gd:141-147`) listesine `EventBus.sprint_planned`, `sprint_started`, `version_shipped`, `seed_round_closed` (seyrek; sonuncusu imzada seed
     listesini kapatır, F7). 4., 5. ve seed adımları `customer_added` ve `day_tick_completed` ile tazelenir (zaten listede).
  3. `mail_pane.gd` `_record()` (686-718): `_item.goal` dalı: çek listesinde `CHEQUE_LEAD`, seed listesinde `GOAL_SEED_LEAD` (R16); adımlar: biten `check.svg` +
     `D_pos()`, sıradaki ve gelecek menajer temasındaki var olan iki varyasyonla (vurgulu ve soluk; adlar `menajer_theme.tres`'ten doğrulanıp rapora yazılır, yeni
     varyasyon yok); MRR adımının (5 ve s2) altında `CHEQUE_MRR_NOW`; düğme `CHEQUE_GO` (`{tab}` = `TAB_PRODUCT`/`TAB_SALES`/`TAB_FINANCE`) → `_go(next.tab)`.
  4. Ofis yığını: `desk()` zaten yığının kaynağı (`office_notice_stack.gd:99`); satır kendiliğinden çıkar.
  5. Tost: yığın listeyi ve o listede görülen en yüksek `done`'u tutar; ilk dolumda yazar, tost atmaz (`_refresh(false)` deseni, :40-41); tost yalnız bu tepe
     aşılınca: `call_group(&"toast", &"show_toast", GOAL_TOAST, CHEQUE_NEXT, preload("res://assets/icons/util/check.svg"), D_pos())` (`show_toast(head, sub, glyph:
     Texture2D, tone)`, `toast.gd:75`; deseni `office_hud.gd:14,127-129`). Canlı 4. ve 5. adımın düşüşü ve geri dönüşü tost atmaz. Yığın gizliyken de tazelenir; tost
     pencerelerin üstündeki katmandadır.
- **Kabul:** `--inbox-shot=cheque` (H): liste başında kâğıt, okuma bölmesinde beş adım, 2/5; `--office-shot=home:8:cheque` `_02` karesi: yığında kâğıt satırı ve
  "Frank'in çeki · 2/5" tostu. TR ve EN taşmasız.

### R4 · İlk dakika
- **İntro düğmesi (C-17):** `mail_pane.gd:139` `[tr("MENTOR_INTRO_CTA"), _close, true]` → `_go.bind("product")`. Ürün penceresi tür seçilmemişse seçicide açılır
  (`product_tab.gd:134-138`). A öncesi `_go("product")` bugünkü `_close` ile aynı `main._on_tab_changed` geri verişinden geçer (`main.gd:2942-2949`; davranış
  değişmez); A sonrası (PRD_SAAT §3.2 2946-2949'u siler) hiçbir şey hız vermez, saat duraklı kalır (Model S). Metin değişmez.
- **İlk Boşluk ipucu (C-10):** yığında, Frank satırından sonra tek satır `OFFICE_HINT_SPACE` (`keyboard.svg`), yalnız ilk dakika: `GameState.day == 1 and
  TimeManager.current_speed == 0 and not TimeManager.is_clock_held() and TimeManager.day_minute() <= TimeModel.WEEK_START_HOUR * 60.0` (tutuş altında Boşluk yutulur
  ve A'nın durum satırı tutuş nedenini gösterir; B'nin `sprint_plan` tutuşu tür seçiminden sonra gelir). A'nın TopBar "DURDU · Boşluk ile sürdür" satırıyla birlikte
  yaşar. İpucu satırı tıklanmaz (yığının `MOUSE_FILTER_IGNORE` deseni); saati yalnız Boşluk ve TopBar düğmeleri başlatır (PRD_SAAT §3). Yığın
  `TimeManager.speed_changed` ve `TimeManager.hold_changed`'e (PRD_SAAT §4.1) abone olur (seyrek).
- **Tür → Başlat tek tık:** B'nin sonucu (B-K10: başlatma saati akıtmaz); C yalnız doğrular (§9 madde 5).
- **Kabul:** `--inbox-shot=intro_go` (H) `GATEFLOW tab=product picking=true speed=0` basar; H gelene dek MCP `call-runtime-method` ile mail bölmesinde
  `_go("product")`. `--office-shot=home:8:cheque` `_02` karesinde ipucu görünür; `home:9:cheque` karesinde görünmez; B indikten sonra `home:8:cheque` `_01` karesinde
  (tür seçili, plan tutuşu) görünmez.

### R5 · Tek seçenekli beat → not (motor)
- **Kural (C-3):** kart tek seçenekli, o seçenekte `effects`, `check`, `requires` yok, kart `critical` değil ve `class != "paper"` ise "not"tur; `quiet` etiketi
  gerekmez. Kapsadığı kartlar: `founder.company_of_one`, `founder.savings_note`, `founder.unseen_build`, `product.working_parts` ve yeni `funding.frank_v1`.
  `funding.seed_stalled` (tek seçenekli etkisiz `paper`) masadaki kâğıt kalır. Frank'in `critical` yaklaşma kartları, `gate_traction`, `hire_nudge`, `paid_tier`,
  `frank_intro`, `resignation` karar kalır.
- **Nasıl:**
  1. `presenter.gd`: `static func is_note(card) -> bool` (kural tek yerde; motor ve harness okur).
  2. `engine.gd` `_admit` (380-400): `is_note` ise kuyruğa da masaya da girmez; mandal harcanır; `names` = `freeze_names(context)` + seam değerleri;
     `EvHistory.record(..., CHOSEN, tek seçenek id, outcome, context, [], arc_id, false, names, true)` (`history.gd:30` yeni `note := false` parametresi; true ise
     satıra `note`, `unread`); `EventBus.event_triggered.emit(event_id)` (kutu ve yığın tazelenir; main.gd dinlemez). `event_resolved` YAYILMAZ
     (`main._on_gate_closed` → `_settle_gate` → `_restore_speed(-1)`, `main.gd:2855-2857,2902-2918`). `_today_admissions`'a eklenmez (not kesinti bütçesi harcamaz).
     `fire_count` notu sayar (`quiet_cards_fill_empty_floor` korunur). Not yolu yalnız `_admit`'tir (istek, günlük, sinyal); `force_fire` (`engine.gd:579-591`)
     `_admit`'i atlar, `modal_requested` yayar ve satırına `forced` yazar (kutu `forced` satırı listelemez, `inbox.gd:54-55`): not yolu değildir, değişmez.
  3. Seam dondurma (tüm kartlar, C-18): `EvPresenter.freeze_seams(card, context)` gövde, başlık ve `by_seam` değişkenlerinin seam'lerini `names["seam:<ad>"]` olarak
     verir; `_interpolate` (219-249) ve `_resolve_variant` (197-214) önce `names`'e bakar. Sayı seam'i `str(değer)`, bool seam'i `str(int(v))` ("0"/"1") olarak donar;
     `_resolve_variant` donmuş değeri `int()` ile okur (`presenter.gd:202`). TYPE_STRING seam'ler (`urun.decision_card` gibi çevrilmiş ad döndürenler,
     `seams_product.gd:43-45,107-109`) DONMAZ: satır id ve özel ad taşır, çevrilmiş metin taşımaz (`history.gd:8-11`); bu gövdeler (katalogda 15 kart, `sprint_late`'in
     iki varyantı dahil) geçmişte düşmeye devam eder (S47 kalanı, §7.4). `resolve` (`engine.gd:458`) ve süre dolumu (`:109-112`) da dondurur.
  4. `mail_pane.gd:119,558-560` `_static_body`: gövde düz String'se ve `{seam:` taşımıyorsa ya da satırda gövdenin bütün seam'leri (`by_seam` seçici dahil) donmuşsa
     çizilir; donmayan (TYPE_STRING) seam'li gövde ve eski kayıtlar bugünkü gibi. Not satırı: "Seçimin" kutusu ve damga yok; tek düğme kartın seçenek etiketi, `_close`.
  5. `inbox.gd` `_history_item` (219-229): `row.note` ise öğe `unread: false` kalır (liste noktası `events_tab.gd:285-286` ve `counts()[2]` `inbox.gd:151-158` notu
     saymaz), okunmamışlık ayrı `note_unread` alanında; `line` gövdenin ilk satırı, damga yok; `mark_read` (174-181) not satırını `EventGate.mark_read(i)` ile
     `EvHistory`'de `unread = false` yapar, `messages_changed` yayar. `unread_discovery()` (132-137) en yeni okunmamış keşfi VE `note_unread` notu dönen tek
     fonksiyona genişler (tek çağıranı `office_notice_stack.gd:99`). Okunmamış işareti YALNIZ ofis yığınında (C-9): `note_unread`'i yalnız `unread_discovery()` ve
     yığın okur; ray rozeti kuyruk + masa sayar (`left_tabs.gd:281-284`), değişmez. `events_tab.gd:320-321` not satırında damga çizmez.
  6. `harness.gd`: `modal_requested` sayacı; not kartı için sayaç > 0 ise `HARNESS FAIL` ve `BEAT_MODAL <id> <n>`.
- **Kabul:** smoke `event_beat_is_note`: `founder.savings_note`'un koşulunu fikstürle sağla, `EventGate.request( "founder.savings_note")` ile admit et
  (`engine.gd:556-571` → `_admit`): `modal_requested` yayılmaz, `EventGate.has_pending() == false`, geçmişte `note` ve `unread` satır, `mark_read` sonrası `unread ==
  false`. `event_beat_freezes_seams`: seam'li gövdeli kart çöz, seam değerini değiştir, geçmiş eski sayıyı basar; `by_seam`'li bool gövde (fikstür) çözülür, seam
  değişir, geçmiş "1" varyantını basar. `--event-harness=random:seeds=10:weeks=12` → `BEAT_MODAL` yok, `HARNESS PASS`; `bash tools/run_gate.sh` 3/3. Görsel:
  `--inbox-shot=beat` (H; okunmamış not yığında, listede işaretsiz, gövdesi geçmişte).

### R6 · v1.0 Frank kartı (taslak, pasif; C-8)
- **Ne:** `data/events/cards/funding/frank_v1.json`: `class: interrupt`, `tags: []`, `tick: signal`, `trigger: {signal: version_shipped}` (`signals.gd:29`; yayın B öncesi
  `sprint_system.gd:803-805`, B sonrası `SprintSystem.publish()` → `_go_public`, PRD_SPRINT S5: oyuncunun tıkı), koşul `urun.version == 1`, iki pazarda, `one_shot`,
  `speaker: char_mentor_frank`, tek seçenek etkisiz (R5 ile not; saati tutmaz), `expires_weeks: 1`, `on_expire: {penalties: []}`, `expire_note: "expire_note"` (lint
  zorunlu: `lint.gd:122-136`; `working_parts` deseni), `text.tr`/`text.en` satır içi (frank_intro deseni). B2B'de aynı yayın anında `customer.frank_intro` da gelebilir;
  not olduğu için araya karar girmez. **Pasiflik:** `"version_scope": "draft"`: `SHIPPED_SCOPES`'ta yok, G2 her build'de reddeder (`gate.gd:152-156`), katalogda olduğu
  için `--event-shot` önizler (`main.gd:606-627`). Onayda tek değişiklik `"demo"`. `drafts/` klasörü değil: katalog dışıdır (`catalog.gd:17`).
- **Kabul:** lint temiz; `--event-shot=funding.frank_v1` TR ve EN; `--why-fire=funding.frank_v1` "version_scope 'draft'" der (B indikten sonra
  `--product-shot=live:gate` + publish durumunda da yalnız scope reddi); commit mesajı "TR/EN + Frank onay bekliyor". Metin onaysız ekrana çıkmaz (§7). Sürüm notunun
  kutlaması B'nindir.

### R7 · Süreli kâğıtlar: düştü (C-19)
Yığın, rozet ve "Süresi doldu" zaten var (§0a); son hafta tostu ertelendi (C-11); her zaman görünen yüzey R11'in Sıradaki dalı. Yığın tavanı `MAX_CARDS = 4`
(`office_notice_stack.gd:12`): ilk hafta Frank + liste + ipucu; sığmayan `+N` (mevcut).

### R8 · Onboarding
- **Köken adları (onaylı 2026-08-08, `localization_glossary.md:157-159`):** `ONB_ORIGIN_SELF_MADE_NAME` TR "Sıfırdan", `ONB_ORIGIN_HEIR_NAME` TR "Mirasyedi",
  `ONB_ORIGIN_CORP_NAME` TR "Kurumsal Firari" (`strings.csv:37,39,41`; yalnız TR sütunu, bayt-span). Kişisel'in köken etiketi aynı anahtarı okur
  (`personal_tab.gd:110-111`).
- **Ön seçim (C-14):** `onboarding_flow.gd:34` taslağı `"origin_id": "self_made"` ile başlar; tıklama serbest, gerekçe satırı yine çalışır.
- **Tek kilit etiketi:** `founder_constants.gd:75` `LOCK_SOON` → `LOCK_FULL`; `origin_traits_step.gd:113-115` ikinci "KİLİTLİ" hapı kalkar (`LOCK_CHIP`
  `mail_pane.gd:460`'ta kullanılıyor, kalır); `LOCK_SOON` (`strings.csv:44`) ölü kalırsa silinir. Dokunulan blokta ham `Color(1, 1, 1, 0.05)` (:104) ve `Color(1, 1,
  1, 0.45)` (:119) var olan bir `UiTokens` adına taşınır (CLAUDE §7.4; yeni token gerekirse aynı commit'te `build_theme.gd` + THEME_STAMP + iki tema, §7.2, U10);
  :115 hap silindiği için gider. ACIK_KARARLAR 29 kapanır.
- **İleri gerekçesi:** `OnboardingStep` (`step_base.gd`) sözleşmesine `invalid_reason() -> String` (anahtar, geçerliyse ""). Köken ve şirket adımlarında `is_valid`
  gövdesi `invalid_reason`'a taşınır, `is_valid` `invalid_reason() == ""` döner (koşul iki kez yazılmaz, CLAUDE §8): köken adımı huy formülü
  (`founder_constants.gd:156-174`), sonra kalan puan (`Fmt.count_key`); şirket adımı ad ve logo stili (`company_step.gd:191-192`). Karakter adımı gerekçe taşımaz:
  ilk portre ön seçili, `is_valid` yalnız portreyi okur (`character_step.gd:138-145`); köken de ön seçili ve kilitli kart tıklanmaz (`origin_traits_step.gd:117`).
  `onboarding_flow.gd:133,139` düğme kapanırken gerekçeyi `Footer`'daki yeni `Reason` etiketine yazar (`OnboardingFlow.tscn:43-61`).
- **Beceri cetveli (C-13):** `origin_traits_step.gd:355` değer etiketi `str(FounderConstants.to_ruler(v))` yazar (Kişisel'le aynı 0-10 ölçek, `RULER_SCALE = 2`,
  `founder_constants.gd:30`); +/- bir dağıtım puanı adımlar, "KALAN PUAN" dağıtım biriminde kalır.
- **Yetenek metinleri (C-15):** §4'teki 8 satır, her biri koddaki etkiyle kanıtlı.
- **Huy kartları (C-12):** `TRAIT_*_EFFECT` (`strings.csv:54-68`, `origin_traits_step.gd:213`) etki vaat ediyor, hiçbiri bağlı değil (`founder_constants.gd:42-43`,
  `game_state.gd:928`). Metinler etki değil tarif olarak yeniden yazılır (§4, EN önce); anahtar adları kalır.
- **Huylar · YAKINDA:** `personal_tab.gd:120-124` `SYS_SOON` etiketi ve yorum satırı kalkar; seçilen huyların adları kalır, etki iddiası yazılmaz. `SYS_SOON` ray
  kilidinde kullanılıyor (`left_tabs.gd:222`), kalır.
- **Kabul:** `--onboard-shot=1|2|3` TR ve EN: köken adları Türkçe, Sıfırdan seçili, tek etiket, boş adımda gerekçe; `--onboard-shot=2` (H: taslak bir beceriye 2
  dağıtım puanı yazar; bugün taslak boş, `main.gd:1664-1669`, `origin_traits_step.gd:369-371`) beceri "4"; `--tab-shot=personal`: köken "Sıfırdan", Huylar başlığında
  etiket yok. Smoke `onboarding_pages_contract`, `founder_5skill_init`, `alloc_guard` yeşil.

### R9 · Piyasa rayda v1.0'a kadar kilitli
- **Ne:** `ui_tokens.gd:298` `{"id": "piyasa", "lock": "live"}` (adlı kapı, `left_tabs.gd:235-238` yorumunun istediği biçim). `left_tabs.gd`: `_is_locked` "live"
  kapısını `not ProductState.is_live()` ile çözer; kilit düğümleri (:84-95) kilitlenebilir her satır için kurulur, `_paint` (138-155) görünürlüğü ve `mouse_filter`'ı
  durumdan çizer; `pressed` her satıra bağlanır, `_on_tab_button` kilitliyse döner; `_lock_reason` "live" → `RAIL_LOCK_AFTER_V1`; `EventBus.version_shipped`'e abone.
  Programatik açılış (`--tab-shot=piyasa`) etkilenmez. Ar-Ge ve Pazarlama bugünkü gibi.
- Kilidin anlamı genişler: `left_tabs.gd:235-236` ("Bugünkü tek kapı 'ea'") yorumu aynı commit'te yeni anlama güncellenir ('ea' = bu yapıda yok, 'live' =
  v1.0'a kadar). `ui_tokens.gd:288-292` ("a lock means only 'not in this build'") C-2 dışı (yalnız :298), bayatlar → §7.4. Ar-Ge'nin bilerek
  kilitsiz bırakıldığı emsal (yönetmen hükmü 2026-08-25, `rnd_rail_open_with_waiting_page` `endgame_smoke.gd:14037-14072`) raporda ⚠️.
- **Kabul:** `--office-shot=home:8:untyped` (H, tür seçilmemiş) ray karesinde Piyasa soluk ve "V1.0'DAN SONRA"; `--office-shot=home:8` (tema tohumu, yayında) açık;
  simge kipinde kilit ikonu. `rail_tabs_match_scene_order` ve `rnd_rail_open_with_waiting_page` yeşil.

### R10 · "Araçlar" kalemi (C-7)
- `FIN_BURN_TOOLS` (`strings.csv:2890`, okuyan `finance_system.gd:252`) → TR "Geçim ve araçlar", EN "Living and tools" (evre tabanı + çalışan koltuğu, her durumda
  doğru; GUNCELLEMELER:248 ile uyumlu). `HR_ROW_TOOLS` (`hr_actions.gd:191-192`) aynı faturayı (`monthly_tools_for(staff)`) gösterir ama C-7 kapsamında değil,
  değişmez; Ekip "Araçlar" / Finans "Geçim ve araçlar" ad ayrılığı raporda ⚠️. Kabul: `--finance-shot=gider` TR ve EN, `burn_tools_and_service` yeşil.

### R11 · A inince: TopBar
- **Yenileme:** `EventBus.sprint_planned`, `sprint_started`, `version_shipped`, `customer_added` → `_queue_refresh` (PRD_SAAT §7.1 yolu; A'nın bağlantı bloğunun
  altına ayrı satırlar, `_refresh`'e doğrudan değil). Bugün TopBar bunların hiçbirine bağlı değil (`top_bar.gd:88-105`) ve Model S'te saat duraklı kaldığı için
  `hour_changed` da gelmez.
- **Sıradaki:** `top_bar.gd` Sıradaki dalları (bugün 208-229) A'nın son hâline iki dal: (a) masada son haftasındaki herhangi bir kâğıt (`weeks_left <= 1`, yığının
  kuralı `office_notice_stack.gd:116`; `is_expiring` değil, o 1 haftalıkları dışlar, `papers.gd:75-82`, S11) `TOPBAR_NEXT_PAPER_FINAL` (`{subject}` = kâğıdın konusu;
  mevcut `TOPBAR_NEXT_SPRINT_FINAL` sprint kâğıdı için kalır), (b) liste açıksa `line = tr(next.text_key)` (MRR adımında `{bar}` doldurulur); `$NextKey` zaten
  "SIRADAKİ" bastığı için (`:208`) `CHEQUE_NEXT` TopBar'da kullanılmaz; `next == {}` ise dal atlanır. Öncelik: görüşme > teklif > sprint kararı > son hafta kâğıdı >
  çağrı > liste > mesai bitimi. Son hafta tostu yok (C-11).
- **Marka bloğu:** `_refresh_brand` (148-160) `$LogoName.text = GameState.company_name` (özel ad, çevrilmez); sahnedeki `TOPBAR_BRAND` önizleme olarak kalır.
- **Kabul:** `--office-shot=home:11:cheque` ve `--tab-shot=product:cheque` karelerinde şirket adı ve SIRADAKİ başlığı altında "v1.0'ı yayınla"; sıkışık kipte taşma
  yok; A'nın "DURDU · Boşluk ile sürdür" satırı bozulmadı. MCP: duraklıyken tür seç → Sıradaki "İlk sprinti başlat"; Başlat → "v1.0'ı yayınla", saat hâlâ duraklı.

### R12 · Belgeler (C10)
- `GDDs/GUNCELLEMELER.md`: ch12 altına "§5 Onboarding" (yürürlükteki: intro → Ürün seçici, çek ve seed listesi yüzeyleri, Piyasa kilidi, beat notu, Sıfırdan ön
  seçili); ch02 bölümüne (`GUNCELLEMELER.md:34` altı) yeni madde "Köken adları TR: Sıfırdan, Mirasyedi, Kurumsal Firari (glossary :157-159)"; ch14 bölümüne (:425
  altı) "Kilitli iki köken de `LOCK_FULL` taşır; ch14 §4'ün EA ifadesi Mirasyedi için geçmez (ACIK_KARARLAR 29)"; "Para verenin şartı serbest (2026-10-10)" daralması
  (C-16); seed çıtasının ekranda olması (iştah gramerinin seed kapısında daralması, C-6). `:380` (ch12 §2) satırına C dokunmaz (U11: A "Hız üç basamaklıdır; saat
  yalnız oyuncu sürdürünce akar." yazar); Sıradaki dalı ve çek kâğıdı hükmü ch12 §5'e ayrı paragraf.
- `docs/tasks/PRD_RAKIP_DUNYASI.md:21` karar A hücresine bir cümlelik daralma notu (C-16).
- Olay motoru md'si: `§27.17 · Tek seçenekli beat notu ve donmuş seam değerleri` C2 ile, `§27.18 · Kritik kartın mandal iadesi` C12 ile iner (CLAUDE §2).
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`: madde 29 kapanır (köken kilit etiketi).
- `docs/HARITA.md`: Kabuk (83, 85, 109; 84/85 A'nın metni üstüne), Olay motoru (271-277), Gelen kutusu (290 yeni durumlar `cheque`, `seed`, `beat`, `intro_go`, `dying`),
  Onboarding (304-313); ChequeRead'in yeri ve smoke öneki `cheque_`.
- `CLAUDE.md`: §12 `--office-shot` ek listesine `cheque`, `untyped` ve `v1`; SAAT K10 sonrası, A'nın metni üstüne ayrı hunk, yalnız C'nin bayrak satırları (U10).
  §6 olay cümlesine beat notu bayrak satırı değil → §7.4.

### R13 · `product.sprint_late` tek kart varyantı (B-D4)
- **Ne:** B `seams_product.gd`'ye `urun.sprint_single_card` (TYPE_BOOL) ekler (B'nin dosyası). C `sprint_late.json` gövdesini (`text.tr.body`, `text.en.body`)
  `{"by_seam": "urun.sprint_single_card", "variants": {"0": <bugünkü gövde>, "1": §4}}` yapar (desen `working_parts.json:41-47`; `_resolve_variant` değeri `int()`
  ile okur, bool `true` → 1, `presenter.gd:202`). "0" kolu bugünkü mühürlü metin, değişmez. Seçenekler, etkiler, anahtarlar aynı (crunch kilidi R17).
- **Kabul:** lint temiz; `--why-fire=product.sprint_late`; "0" varyantı `--event-shot=product.sprint_late` TR ve EN; "1" varyantı MCP ile (tek kartlı aktif sprint
  fikstüründe kart önizlemesi, `_shot_pane` deseni) TR ve EN; `sprint_late_only_when_behind` yeşil (B'nin vakası; kırılırsa C düzeltir, raporlar).

### R14 · Kâğıt düzeltmeleri (S40, S57; kalanı §7.4)
1. Açılamayan kâğıt sessiz kalmaz: `mail_pane.gd:499` ve `events_tab.gd:121` `EventGate.open_paper` false dönünce (düğme etkin kart yokken açık; false = kâğıt
   G5/G6/G7'de silindi, `engine.gd:605-612`) `PAPER_GONE_TOAST` tostu (R3'ün `show_toast` deseni). Tek yardımcı `mail_pane.open_paper(key)`; `events_tab` `_pane`
   üstünden çağırır (CLAUDE §8).
2. `inbox.gd` `desk()` (86-88): kapı hatırlatıcısı, kapı kartı (`pending_next_phase` 2 → `funding.gate_traction`, 3 → `funding.gate_series_a`) etkin ya da
   kuyruktayken (`EventGate.instances_of(id) > 0`, `event_gate.gd:173-175`; fonksiyon yerinde kalır, C-2) listelenmez (:70-72'nin dediği). Kalırsa (bekleme,
   kepenk) sekmesi `""`; `mail_pane.gd` `_record` (712-718) sekmesiz ve istek yoksa eylem satırı çizmez (Finans'ta kapı denetimi yok).
- **Kabul:** loc kapıları; MCP: kâğıdın koşulunu boz → Cevapla → tost (TR/EN), kâğıt listeden düşer; MCP: kapı kartı kuyruktayken `desk()`'te `r:gate` yok.

### R15 · Kritik kartın mandalı düşüşte iade edilir (S56; F6)
- **Ne:** `engine.gd` `pump` (433-439): `critical` ve `latch.one_shot` kart G7'de (koşul) düşünce mandal yeni `EvLatches.refund(key)` ile iade edilir (`latches.gd:94-95`
  `spend`'in tersi, `fires` 0'a inince kayıt silinir; `clear_one` :116-119 yalnız debug); `DROPPED` satırı yine yazılır, G5/G6 düşüşü iade etmez. Motor md §27.18 (R12).
- **Neden:** mandal kabulde harcanır (`engine.gd:393-395`), seam canlı MRR okur (`seams_ported.gd:108-110`): B2C'de MRR 00:00 kabulüyle 08:00 gösterimi arasında eşiğin
  altına inerse çek koşu boyu gelmez ($25K). Aynı iade kepenkte düşen `gate_traction`'ı da kurtarır (`gate_traction.json:28-33`).
- **Kabul:** smoke `event_critical_drop_refunds_latch`: canlı ürün + MRR 2.500 → çek kuyrukta; MRR 2.000 → `pump` → `DROPPED`, `EvLatches.fires(key) == 0`,
  `ChequeRead.list() == "cheque"`; MRR yine 2.500, günlük tik → kart yeniden kuyrukta, kabulde `run_angel_amount > 0`. Falsifikasyon: iade satırı silinince ikinci kabul
  düşmeli. `angel_*` (`endgame_smoke.gd:259-266`), `event_*`, `run_gate.sh` 3/3 yeşil.

### R16 · Seed listesinde büyüme sözü (S36; F7)
- **Ne:** R3.3 seed listesinin okuma bölmesinde giriş satırı `GOAL_SEED_LEAD`; `{window}` = `SeedConstants.EXPECT_WINDOW_MONTHS`, `{pct}` =
  `Fmt.percent(SeedConstants.EXPECT_MOM_PCT, 0)` (`seed_constants.gd:113-114`; biçim `hunt_tab.gd:150` deseni). Söz pitch'ten ve imzadan ÖNCE okuma bölmesinde görünür:
  liste kapı açılınca kapanmaz, 2/2'de imzaya dek açık kalır (§2); imza öncesinde gizlenmez.
- **Neden:** söz yalnız imzadan sonra yazılıyor (`hunt_tab.gd:146-152`); pitch onayı ve imza metinleri söylemiyor (`strings.csv:2426,1340`) ve değişmez.
- **Kabul:** `--inbox-shot=seed` (H) TR ve EN: giriş satırı "3 aylık ortalama büyüme %10" (EN "10%"), taşma yok; `cheque_read_steps` kapı açıkken `"seed"` 2/2 (R1).

### R17 · Sprint artıklarının C payları (F5, onaylı)

| Pürüz | Ne (dosya:satır) | Bağımlılık | Kabul |
|---|---|---|---|
| S03 ölen sayfa | `Inbox.show` (`inbox.gd:29-33`) grupta canlı sayfa (`is_queued_for_deletion()` false) yoksa Olaylar'ı kapalı sayar ve `tab_changed("events")` yayar. Bugün Ürün'ü açan `tab_changed` (`game_shell.gd:42-45`) sayfayı aynı karede `queue_free` eder (`window_layer.gd:75-82`); ardından gelen kart (`main.gd:2885`) ölen sayfaya seçim yollar, ekrana çıkmaz | A payı ayrı (F2: `_open_after_gate`, `main.gd:2922-2931`); kabul H'ye bağlı | `--inbox-shot=dying` (H): `GATEFLOW` `window=events`, kart okuma bölmesinde; TR/EN |
| S04 crunch vaadi | `sprint_late.json:35-48` `crunch` seçeneğine `requires` yaprağı `urun.crunch_finishes == true`, gerekçe `EV_PRODUCT_SPRINT_LATE_CRUNCH_LOCK`: ×1,25 saat kartı sprint sonuna yetiştirmiyorsa seçenek kilitli ve gerekçeli (bugün gövde ve `EV_PRODUCT_SPRINT_LATE_CRUNCH`, `strings.csv:2927`, yetiştirmeyi vaat ediyor) | B: `SprintSystem.crunch_finishes()` (F5). Seam `urun.crunch_finishes` (TYPE_BOOL) `seams_product.gd`'de (B'nin dosyası): B'nin commit'inde yoksa C, B'den sonra ayrı hunk ekler. C9 (aynı dosya) | lint; `--event-shot=product.sprint_late` TR/EN gerekçe taşmasız; B'nin `live:decision_paper` fikstüründe MCP ile kâğıt, kilit `crunch_finishes()` ile tutarlı; `sprint_late_only_when_behind` yeşil |
| S15 "Fiyatı belirle" | `paid_tier.json:14-27` koşuluna `urun.paid_plan_set == false`: Ücretli plan çıktıysa (`SprintCatalog.tier(PAID_PLAN) > 0`, `sprint_catalog.gd:81-83`) ya da kartı koşan ya da planlanan sprintteyse (`GameState.product` `sprint`/`next` kartları) kart gelmez. `FRANK_ADVISORY_PAID_TIER` (`strings.csv:2677`, `paid_tier.json:36-38`) fiyat denetimi olmayan oyunda "Fiyatı belirle" diyor: §4 taslağı Frank satırıdır, onaydan sonra ayrı commit'le iner (§7.1) | Seam `urun.paid_plan_set` (TYPE_BOOL) S04'ünkü gibi; B'nin sprint durumunu yalnız okur | lint; `--why-fire=product.paid_tier` B'nin `live:b2c_mvp` durumunda (lider planı Ücretli planı taşır, `sprint_catalog.gd:793`) G7 `urun.paid_plan_set` reddi; `sprint_paid_plan_opens_paid_tier` yeşil |
| S37 sessiz Ar-Ge | `left_tabs.gd:291-295`: R9'un `version_shipped` aboneliği `ProductState.version() == 1` ise oturumluk `_rnd_new` işaretini açar; rozet `attention_count() + int(_rnd_new)`; Ar-Ge açılınca (`_on_tab_changed`, :230) kapanır; kayda girmez | R9 (aynı abonelik, C4); kabul H'ye bağlı | `--office-shot=home:8:v1` (H): `_01` rayda Ar-Ge "1" ve Piyasa açık, `_02` Ar-Ge açıldıktan sonra rozet yok; `rnd_rail_open_with_waiting_page` yeşil |

## 4. Metinler (TR/EN onay bekliyor; EN önce yazılır)

| Anahtar | EN | TR |
|---|---|---|
| `CHEQUE_TITLE` | Frank's cheque | Frank'in çeki |
| `CHEQUE_NEXT` | Next: {step} | Sıradaki: {step} |
| `CHEQUE_LEAD` | Five steps. At the fifth, Frank writes the cheque. | Beş adım. Beşincisinde Frank çeki yazar. |
| `CHEQUE_STEP_TYPE` | Pick a product type | Ürün tipini seç |
| `CHEQUE_STEP_SPRINT` | Start the first sprint | İlk sprinti başlat |
| `CHEQUE_STEP_SHIP` | Ship v1.0 | v1.0'ı yayınla |
| `CHEQUE_STEP_PAYING` | First paying customer | İlk ödeyen müşteri |
| `CHEQUE_STEP_MRR` | Monthly revenue {bar} | Aylık gelir {bar} |
| `CHEQUE_MRR_NOW` | Now {mrr} | Şu an {mrr} |
| `GOAL_STEP_TRACTION` | Reach Traction | Traction'a geç |
| `GOAL_STEP_SEED` | Seed round: monthly revenue {bar} | Seed turu: aylık gelir {bar} |
| `GOAL_TOAST` | {title} · {done}/{total} | {title} · {done}/{total} |
| `CHEQUE_GO` | Go to {tab} | {tab} sayfasına git |
| `OFFICE_HINT_SPACE` | Space: start the clock | Boşluk: saati başlat |
| `RAIL_LOCK_AFTER_V1` | After v1.0 | v1.0'dan sonra |
| `TOPBAR_NEXT_PAPER_FINAL` | {subject} · final week | {subject} · bu hafta son |
| `ONB_WHY_TRAIT_POS` | Pick at least one strength | En az bir pozitif seç |
| `ONB_WHY_TRAIT_NEG` | Two strengths owe a flaw | İki pozitif seçtin, bir negatif de seç |
| `ONB_WHY_POINTS` / `_ONE` | {n} points left to spend / {n} point left to spend | Dağıtılacak {n} puan kaldı |
| `ONB_WHY_COMPANY` | Name the company | Şirkete bir ad ver |
| `ONB_WHY_LOGO` | Pick a logo style | Bir logo stili seç |
| `FIN_BURN_TOOLS` | Living and tools | Geçim ve araçlar |
| `PAPER_GONE_TOAST` (R14) | That paper no longer applies | Bu kâğıdın konusu kalmadı |
| `GOAL_SEED_LEAD` (R16) | Take the seed and you owe growth: a {window} month average of {pct} | Seed alırsan söz verirsin: {window} aylık ortalama büyüme {pct} |
| `EV_PRODUCT_SPRINT_LATE_CRUNCH_LOCK` (R17) | Not done this sprint even with the nights | Gecelerle de bu sprintte bitmiyor |
| `FRANK_ADVISORY_PAID_TIER` (R17; Frank TASLAK, değişir) | Time to start charging. Ship the paid plan. | Artık ücret almanın vakti. Ücretli planı yayınla. |

Yetenek açıklamaları (`ONB_SKILL_*_DESC`, `strings.csv:72,74,389-399`); kanıt sağda:

| Beceri | EN | TR | Kodda etkisi |
|---|---|---|---|
| Ürün | Product-star tiers on feature cards; product research. | Özellik kartlarında Ürün yıldızı isteyen kademeler; ürün araştırması. | `line_gates.gd:39-53` (kurucu dahil), `rnd_system.gd:161,395-399` |
| Tasarım | Design-star tiers on feature cards; design research. | Özellik kartlarında Tasarım yıldızı isteyen kademeler; tasarım araştırması. | aynı |
| Yazılım | Engineering-star tiers on feature cards; technical research. | Özellik kartlarında Yazılım yıldızı isteyen kademeler; teknik araştırma. | aynı; bugünkü "geliştirme hızı ve hata oranı" yanlış (§0a) |
| Test | Test-star tiers, and how fast the live product wears. | Test yıldızı isteyen kademeler ve canlı ürünün aşınma hızı. | `product_system.gd:131-139` (kurucu yapımdaysa, :71-79) |
| Satış | Which leads you can reach, and your odds in the meeting. | Ulaşabildiğin adaylar ve toplantıdaki şansın. | `sales_faucet_system.gd:291-292`, `sales_meeting_system.gd:144-146` |
| Müşteri İlişkileri | Support desk speed, and how slowly your accounts sour. | Destek masasının hızı ve hesaplarının memnuniyetinin ne yavaş düştüğü. | `support_system.gd:49`, `b2b_sales_system.gd:93-96` |
| Liderlik | Team morale, and how fast the team learns. | Ekibin morali ve öğrenme hızı. | `hr_morale_system.gd:111`, `hr_system.gd:69-70` |
| Karizma | Investor meetings and term sheet pushes. | Yatırımcı görüşmeleri ve term sheet pazarlığı. | `vc_pitch_system.gd:218-219`, `pitch_constants.gd:124,155` |

Huy tarifleri (`TRAIT_*_EFFECT`, `strings.csv:54-68`; etki yok, `game_state.gd:928`):

| Huy | EN | TR |
|---|---|---|
| visionary | Sees where the market is going before it gets there. | Pazarın nereye gittiğini oraya varmadan görür. |
| disciplined | Keeps to the plan, week after week. | Hafta hafta plana sadık kalır. |
| networker | Knows someone at every company worth knowing. | Önemli her şirkette bir tanıdığı vardır. |
| resilient | Takes a hit and is back at the desk the next morning. | Darbeyi yer, ertesi sabah yine masasındadır. |
| stubborn | Once decided, hard to turn. | Bir kez karar verdi mi, döndürmesi zordur. |
| micromanager | Wants to see every line before it ships. | Çıkan her satırı önce kendisi görmek ister. |
| risk_blind | Sees the upside first and the cliff last. | Önce kazancı, en son uçurumu görür. |
| lone_wolf | Would rather work it out alone than ask. | Sormaktansa tek başına çözmeyi seçer. |

`product.sprint_late` varyant "1" (satır içi gövde; "0" bugünkü metin):

| EN | TR |
|---|---|
| At this pace {seam:urun.decision_card} will not be done by the end of the sprint. It is the only card in this sprint; carried over, the sprint has nothing left to work on. Finishing it in time means nights on it. | Bu hızla {seam:urun.decision_card} sprint sonuna yetişmeyecek. Sprintteki tek kart bu; devredilirse sprintte yapılacak iş kalmaz. Zamanında bitmesi için geceler ona gidecek. |

v1.0 Frank kartı (TASLAK, Frank külliyatı Erdem'in; onaysız ekrana çıkmaz):

| Alan | EN | TR |
|---|---|---|
| title | Live | Yayında |
| body | The phone rings. It's Frank. / "It's out. Most people never get this far. Now find someone who'll pay for it." / He hangs up. | Telefon çalıyor, arayan Frank. / "Çıktı. Çoğu insan buraya kadar gelemez. Şimdi buna para verecek birini bul." / Kapatıyor. |
| options.ok | Back to work | İşe dön |
| expire_note | The call went unanswered. | Telefon cevapsız kaldı. |

## 5. Tasarım sabitleri ve kurallar (hepsi onaylı 2026-10-10)

| Madde | Değer | Kaynak |
|---|---|---|
| Çekin 5 adımı ve sırası; 4. ve 5. adım canlı; listeyi cevaplanan ya da süresi dolan çek kartı kapatır, düşen kapatmaz (mandal iadesi) | §2, R15 | brief, C-4, C-5, F6 |
| Frank'in çıtası ekranda | `MRR_THRESHOLD` 2.500 $ (`angel_round_system.gd:27`), değer değişmez | brief (ilk kez basılıyor) |
| İkinci liste: Traction + seed kapısı; seed çıtası basılır, Series A basılmaz; liste imzaya dek açık | `DOOR_MRR` 20.000 $ [ÇALIŞMA], değer değişmez | C-6, F7 |
| Beat ayırıcısı | tek seçenek ∧ etkisiz ∧ `critical` değil ∧ `class != "paper"` | C-3 |
| Notun okunmamış işareti yalnız yığında | kutu listesinde ve rozette yok | C-9 |
| Piyasa ray kilidi | v1.0'a kadar | brief |
| Köken kilit etiketi | ikisi de `LOCK_FULL` (ACIK_KARARLAR 29 kapanır; ch14 §4 notu R12'de) | brief |
| Sıfırdan ön seçili | onboarding taslağı | C-14 |
| Onboarding beceri değeri cetvelde | `RULER_SCALE = 2` | C-13 |
| v1.0 Frank kartı koşulu | `urun.version == 1`, iki pazar, not | C-8 (metin §7) |

## 6. Commit sırası ve kapılar

Her commit: `"$GODOT" --headless --path . --event-lint` → `-s res://scripts/debug/loc_residue.gd` → `bash tools/smoke_run.sh loc_csv_integrity` → hedefli smoke →
görsel kabul (gerekiyorsa) → ayrı ajan incelemesi (CLAUDE §9) → commit. TR metin taşıyan commit mesajı "TR/EN onay bekliyor" der. Push yok. Hedefli smoke vaka başına
bir çağrıdır: `for c in <vakalar>; do bash tools/smoke_run.sh "$c" || exit 1; done`. `smoke_run.sh` yalnız ilk argümanı koşar ve kalıp kabul etmez
(`tools/smoke_run.sh:80` `run_one "$1"`).

| # | İçerik | Bağımlılık | Kapı (smoke = vaka listesi) |
|---|---|---|---|
| C1 | R1 `cheque_read.gd` (iki liste, `class_name` yok) + smoke `cheque_read_steps` | yok (A ile paralel) | smoke `cheque_read_steps`, `all_scripts_load` |
| C2 | R5 motor yolu, seam dondurma, kutu/bölme/yığın not desteği, harness sayacı, smoke iki vaka, md §27.17 | yok (A ile paralel) | smoke `event_beat_is_note`, `event_beat_freezes_seams`, `quiet_cards_fill_empty_floor` + `awk '/^\tmatch case_name:/{on=1;next} on&&/^\t\t_:/{exit} on' scripts/debug/endgame_smoke.gd \| grep -oE '"event_[a-z0-9_]+"' \| tr -d '"'` ile çıkan 19 `event_*` vakası; `--event-harness=random:seeds=10:weeks=12`, `run_gate.sh` 3/3, `--inbox-shot=history` |
| C4 | R4 intro düğmesi + R9 Piyasa kilidi, `RAIL_LOCK_AFTER_V1` | yok (A ile paralel) | smoke `rail_tabs_match_scene_order`, `rnd_rail_open_with_waiting_page`; `--inbox-shot=intro` + MCP `_go("product")`; ray karesi (MCP tür seçilmemiş; `--office-shot=home:8` yayında) |
| C5 | R8 onboarding + Kişisel Huylar, CSV | yok (A ile paralel) | smoke `onboarding_pages_contract`, `founder_5skill_init`, `alloc_guard`; `--onboard-shot=1..3` TR/EN, `--theme-audit=onboard:2`, `--tab-shot=personal` |
| C6 | R6 taslak kart | C2 | lint, `--why-fire=funding.frank_v1`, `--event-shot=funding.frank_v1` TR/EN |
| C7 | R10 kopya | yok (A ile paralel) | loc kapıları, `--finance-shot=gider`, smoke `burn_tools_and_service` |
| C11 | R14 kâğıt tostu ve kapı hatırlatıcısı, CSV `PAPER_GONE_TOAST` | yok (A ile paralel; `inbox.gd` `desk()` C3 ile hunk bazlı) | loc kapıları, R14 MCP denetimleri (tost TR/EN) |
| C12 | R15 mandal iadesi, smoke `event_critical_drop_refunds_latch`, motor md §27.18 | C1, C2 (aynı `engine.gd`) | smoke yeni vaka, `cheque_read_steps`, `angel_*` 8 vaka, `event_*` vakaları; `--event-harness=random:seeds=10:weeks=12`, `run_gate.sh` 3/3 |
| H | `main.gd` harness kolları ayrı hunk (C-1). Fikstür `cheque`: `_seed_run_reproducible()`, gün 1, `current_hour` = kare saati + `TimeManager.sync_to_current_hour()`, hız 0, `SprintSystem.choose_type("erp", …)`, sonra `apply_lead()` + `start()` (B-D1; 2/5). `seed`: `cheque` + `AngelRoundSystem.accept_offer()`. Kollar: `--inbox-shot=cheque`, `=seed` (R16), `=beat` (not `EventGate.request` ile admit edilir; `_shot_card`/`force_fire` değil), `=intro_go` (intro + `_go("product")`, `GATEFLOW tab=<id> picking=<bool> speed=<n>`), `=dying` (R17: Olaylar açıkken aynı karede `tab_changed("product")` + `force_fire`) (`_run_inbox_shot`); `--tab-shot=finance:cheque`, `personal:cheque`, `product:cheque`, `finance:seed`, `personal:seed` (`_run_tab_shot`); `--office-shot` ekleri `cheque` (`_01` tür seçili, `start()` öncesi; `_02` `start()` sonrası tost), `untyped` (`cheque` fikstürü, tür seçimsiz) ve `v1` (R17: `cheque` + yayın; B öncesi `mvp_shipped`, `mvp_version` 1 ve `version_shipped.emit(1)`, B sonrası `publish()`; `_02` `tab_changed("rnd")` sonrası) (`_run_office_shot`); `--onboard-shot=2` taslağına bir beceriye 2 puan. Canlı fikstür B sonrası `_seed_product_live` (publish eder) | SAAT K1–K10 main'de | smoke `all_scripts_load`; her yeni durum bir kez çekilir |
| C3 | R2 + R3 + R4 Boşluk ipucu + R16, CSV `CHEQUE_*`, `GOAL_*`, `OFFICE_HINT_SPACE`; B2C para adımları `product`'a (U6); 1. evre kolları ve anahtarları silinir | C1, H; SAAT K1–K10 main'de | smoke `cheque_read_steps`; `--tab-shot=finance:cheque`, `personal:cheque`, `finance:seed`, `personal:seed`, `--inbox-shot=cheque`, `seed`, `--office-shot=home:8:cheque`, `home:9:cheque` (TR, EN) |
| C8 | R11 TopBar dalları, `TOPBAR_NEXT_PAPER_FINAL` | SAAT K1–K10 main'de | `--office-shot=home:11:cheque` ve `--tab-shot=product:cheque` (her biri bir de `--shot-size=1280x720` ile), smoke `topbar_speed_cluster_three_rungs`, `--clock-shot=paused`, R11 MCP denetimi; `--tick-probe=1` `TICK\|hour` p95 ≤ 3 ms, A'nın K10 değeriyle yan yana (U7) |
| C14 | R17 S03 `Inbox.show` + S37 Ar-Ge rozeti | H (`dying`, `v1`), C4 (aynı `left_tabs.gd`) | smoke `rail_tabs_match_scene_order`, `rnd_rail_open_with_waiting_page`; `--inbox-shot=dying`, `--office-shot=home:8:v1` (TR, EN) |
| C9 | R13 `sprint_late` varyantı + `cheque_read_steps` `skip()` assert'i | B'nin seam commit'i main'de | lint, smoke `sprint_late_only_when_behind`, `cheque_read_steps`; `--event-shot=product.sprint_late` ve MCP "1" varyantı TR/EN |
| C15 | R17 S04 crunch kilidi + S15 `paid_tier` koşulu, iki seam (B'nin commit'inde yoksa), CSV `EV_PRODUCT_SPRINT_LATE_CRUNCH_LOCK` | B'nin `crunch_finishes()` commit'i main'de; C9 (aynı `sprint_late.json`) | lint, `--why-fire=product.paid_tier`, `--event-shot=product.sprint_late` TR/EN, MCP kâğıt kilidi; smoke `sprint_late_only_when_behind`, `sprint_paid_plan_opens_paid_tier` |
| C13 | U6 ikinci aşama: `B2C_MONEY_TAB` → `"sales"` | C3 + B commit 8 main'de | smoke `cheque_read_steps`; MCP: B2C fikstüründe 4. adım düğmesi Satış B2C sayfasını açar |
| C10 | R12 belgeler | C1–C15 + SAAT K10 (HARITA 84/85 ve CLAUDE §6/§12 A'nın metni üstüne ayrı hunk; GUNCELLEMELER :380'e dokunulmaz, U11) | loc kapıları; `git show --stat` yalnız belgeler |

H gelmeden önce C2, C4'ün görsel kabulü mevcut durumlarla (`intro`, `history`, `paper_last_week`, `--onboard-shot`, `--event-shot`) ve gerekirse MCP çalışma zamanı
çağrısıyla yapılır; `beat` karesi H'de tamamlanır.

## 7. Sahibe bırakılan kararlar (SAHİBE; ajan uygular ama onaysız ekrana çıkmaz/onay bekliyor işaretler)

1. **Frank taslakları (C-8, F5; külliyat Erdem'in).** v1.0 kartı (§4, `expire_note` dahil; onaya kadar `version_scope: draft`) ve `FRANK_ADVISORY_PAID_TIER` (R17).
2. **TR/EN metin tabloları (§4).** `CHEQUE_*`, `GOAL_*`, `OFFICE_HINT_SPACE`, `RAIL_LOCK_AFTER_V1`, `TOPBAR_NEXT_PAPER_FINAL`, `ONB_WHY_*`, beceri açıklamaları, huy
   tarifleri, `FIN_BURN_TOOLS`, `sprint_late` varyant "1", `PAPER_GONE_TOAST`, `EV_PRODUCT_SPRINT_LATE_CRUNCH_LOCK`. Commit'lenir, mesaj "TR/EN onay bekliyor" der.
3. **Frank metni (0b'den; öneri taslak).** `MENTOR_INTRO_BODY` "onu beş geçiyor" ↔ 08:00, öneri "sekizi beş geçiyor" / "Five past eight" (S46); `ANGEL_EVENT_BODY`
   ilk ödemeden haftalar sonra "para kazandırmaya başladı" diyor (S56); Reddet kilidi "Zor modda açılır." yazılmamış moda işaret ediyor (görünür-kilitli kapı
   bilerek, `angel_round_system.gd:6-10`; ACIK ~900); `END_EV_SHUTTER_BODY` ürünsüz koşuda "yeni müşteri bul" diyor (S31).
4. **Çapraz task bağımlılıkları ve yardımcı yönetmen soruları (0b'den; C planlamaz; kanıt §0b).**
   - A (SAAT) dosyaları, A'nın PRD kapsamı dışı (A'ya mı Onarım'a mı?): `main.gd:2803` yorumu (S01); `save_manager.gd` auto yuvası ve şirket adı (S29), `_dirty` (S50);
     `game_shell.gd`/`main.gd` F9 (S51); `settings_modal.gd` Efektler, `main.gd` transit (S54; ray düğmesi `left_tabs.gd:97` C'nin, A transit sinyali verirse C bağlar).
   - Onarım 1 D: harita kartı çek satırı, "Ofisi taşı" notu (`office_map_card.gd:135-137`, `office_hud.gd:90-112`; S23). Onarım 1 A: `launch_leak` kapı kartından en
     az bir tik sonra (S26, S17 tetiğiyle ölçülür).
   - Sahipsiz: açılışta Devam/Yükle (S28; onboarding bağlantısı `main.gd` olmadan çalışmaz); `save_load_modal.gd`, `system_menu_modal.gd` (S29, S50, S51);
     `endings_*.gd` bitiş nedeni (S31); `finance_tab.gd:107-109`, `investor_appetite_ui.gd:36-39`, `phase_gate_system.gd:146`, `hunt_tab.gd:312-313` (A) (S35);
     `game_state.gd:935-938` (S54); yeni sessiz kartlar (S41, yazım).
   - C'nin sahipliği dışında kalan düzeltmeler (C'ye mi verilir, sahibine mi?):
     - S47 kalanı: TYPE_STRING seam dondurma (katalogda 15 kart, §0b). `urun.decision_card` çevrilmiş kart adı döndürür (`seams_product.gd:43-45,107-109`), satır
       çevrilmiş metin taşımaz (`history.gd:8-11`). Öneri: id döndüren ikiz seam (seam dosyasının sahibi), çizimde `tr`. O zamana dek bu gövdeler geçmişte düşer.
     - Var olan kart koşulları (BRIEF: yalnız yeni kart + bayrak): `company_of_one.json:16`'ya `finance.shutter_weeks_left < 0` yaprağı (S10;
       `gate_traction.json:28-33` deseni); `meetup_talk.json:21-25` kabulünden `urun.sprint_running` silinir, seçenek kilidi `:37-42` kalır (S40, S41).
     - C'nin olmayan CSV anahtarları (öneri EN / TR): `GATE_TRACTION_ADVANCE` (:1283) "On to Traction" / "Traction'a geç", `GATE_ADVANCE`'tan ayrı
       (`endgame_smoke.gd:1002-1003`, `traction_gate_one_option` :76) (S26); `EV_FOUNDER_FRIENDS_BODY` (:3013) "bu hafta" → "bu aralar", kâğıt 2 hafta yaşar
       (`friends_test.json:79`) (S40); `ANGEL_NUDGE_ACK` (:438) "Go to Team" / "Ekip'e git" (`TAB_HR` :457) (S57); `DESK_PAPER_GATE_TITLE` (:148) tiresiz
       "Faz kapısı açık: karar bekliyor" (ACIK 68 açık madde).
     - Yorum ve belge: `ui_tokens.gd:288-292` kilit yorumu R9'un 'live' kapısıyla bayatlar (C-2 yalnız :298); `event_gate.gd` `instances_of`'u "Test seams"
       başlığından çıkarmak (R14.2 çağırır; C-2 yalnız `mark_read`); `CLAUDE.md` §6 olay cümlesine beat notu (U10 yalnız bayrak satırı).
5. **Sahibe bırakılan kararlar → Onarım 1 (F4).** S16, S34, S49, S22 atama paneli uyarısı ve S48 işe alım işareti Onarım 1 E "Ürün/Ar-Ge artıkları"na gider; C dokunmaz.

## 8. Erdem'in bakacakları

§3'teki her Kabul karesinin TR ve EN PNG'si (öncelik: `--inbox-shot=cheque`, `--tab-shot=finance:cheque|personal:cheque`, `--office-shot=home:8:cheque`,
`--inbox-shot=beat`, `--onboard-shot=2`, `--office-shot=home:8:untyped`, `--event-shot=funding.frank_v1`, A sonrası TopBar, `--inbox-shot=seed`, R14 tostu, R17 kareleri:
`--inbox-shot=dying`, `--office-shot=home:8:v1`) ve §4 tabloları.

## 9. Doğrulama listesi

1. `ChequeRead` tek kaynak: C diff'inde `is_typed`, `b2c_paying_users`, `MRR_THRESHOLD`, `DOOR_MRR`, `page_unlocked` için yeni okuyucu yalnız `cheque_read.gd`; yeni
   `class_name` yok.
2. `cheque_read_steps` B2C ve B2B'de 0→5, seed 0→2, kapı açılınca 2/2 kalır, imzada liste yok; `DROPPED` listeyi açık tutar, `EXPIRED` kapatır; falsifikasyon rapora.
3. Not kartları `modal_requested` yaymıyor (`BEAT_MODAL`), `has_pending` false, saat tutulmuyor; karar kartları değişmedi: `--event-harness`
   `CARDS`/`TEMPO`/`COVERAGE` satırları önce/sonra (`harness.gd:329,334,405`; beş not kartı `COVERAGE`'da "never fired", beklenen), `run_gate.sh` 3/3.
4. Geçmişte seam'li gövde donmuş değerle; smoke `legacy_v12_save_opens_live_table`, `save_roundtrip_fingerprint`, `save_double_load_no_residue` yeşil; şema 15 kalır
   (`row.get("note", false)`, göç yok).
5. Intro düğmesi Ürün seçicisini açıyor, saat duraklı; tür seçimi sonrası "Sprinti başlat" tek tık, saat akmıyor (B inince `--product-shot=live:plan`).
6. Onboarding: TR adlar, Sıfırdan seçili, tek kilit etiketi, iki adımda gerekçe (köken/huy/puan, şirket), cetvel değeri.
7. Piyasa kilidi ship öncesi ve sonrası; programatik açılış etkilenmedi; `left_tabs.gd` kilit yorumu güncel.
8. C diff'inde yeni `hour_changed`/`mrr_changed` aboneliği ve yeni `speed_change_requested.emit` yok.
9. `loc_residue` temiz, EN karelerde anahtar yok, oyuncu metninde tire yok, ek yer tutucuya bitişik değil, glif temiz.
10. Silinen 1. evre kolları ve `FIN_GOAL_P1_*`, `PER_GOAL_BOOTSTRAP` için okuyucu kalmadı (`grep -rn` scripts, scenes).
11. Kirli dosyalarda yalnız C hunk'ları commit'lendi (`git show --stat` her commit).
12. R14: düşen kâğıt tost atar; kapı kartı kuyruktayken hatırlatıcı yok. R15: düşen çek geri gelir. R16: seed sözü pitch ve imzadan önce listede. R17: ölen sayfada kart
    ekranda, crunch kilidi `crunch_finishes()` ile tutarlı, `paid_tier` planlıyken gelmez, v1.0'da Ar-Ge rozeti. C8 sonrası `TICK|hour` p95 ≤ 3 ms (U7).

## 10. Done mesajı

Erdem'e ✅/⚠️/❌ listesi: her R maddesi, commit kimliği, kapı çıktısı (smoke vaka adı ve sonucu, harness `HARNESS PASS`, `run_gate` 3/3), ekran görüntüsü yolları (TR ve
EN), "TR/EN onay bekliyor" metinlerin listesi (§4, §7), A'ya bağlı kalanlar (H, C3, C8, C10, C14), B'ye bağlı kalanlar (C9, C13, C15), §7.3/§7.4 açık bağımlılıklar,
kırılıp düzeltilen başka task vakaları, bilinen sorunlar (⚠️: `HR_ROW_TOOLS` ad ayrılığı R10, Ar-Ge kilit emsali R9, `seed_constants.gd` yorumları §11).

## 11. Öğretici notlar

- **Tutuş semantiği.** Kart ekrana gelince `main.gd` saati `hold_clock("event")` ile tutar (`main.gd:2866-2885`); `event_resolved` gelince `_settle_gate` hızı geri
  verir (`:2912-2918`, A bu geri verişi siliyor). Not yolu bu yüzden `event_resolved` yaymaz; aksi hâlde A gelmeden duraklı saat kendi kendine akar.
  `modal_requested` olmadan kapı hiç açılmaz (`engine.gd:450-453`).
- **SENKRON KURALI** (`time_manager.gd:20-25`): fikstürde `GameState.current_hour` yazan `TimeManager.sync_to_current_hour()` çağırır; aksi hâlde saatlik tik atılmaz
  ve Boşluk ipucu koşulu (`day_minute`) yanlış okur.
- **Taban dolgusu** (`engine.gd:313-350`): sessiz haftayı quiet beat'ler doldurur. Harness kararı yalnız `_drain_active`'te etkin kartla sayar
  (`harness.gd:213-236`); not hiç etkin olmadığı için karar sayılmaz, `TEMPO` değişir (beklenen, §9.3).
- **Seed çıtası ve iştah grameri.** `seed_constants.gd:19-20` ve `endgame_smoke.gd:15555` yorumları "çıta basılmaz" der; C-6 ile çıta liste satırında basılır.
  `seed_door_number_never_rendered` yalnız `SEED_*` anahtarlarını tarar, yeşil kalır. `seed_constants.gd` C'nin dosyası değil, vaka C'nin vakası değil: yorumlar
  değişmez, raporda ⚠️ olarak bildirilir.
