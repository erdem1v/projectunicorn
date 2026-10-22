# R7 · Bizim durum: yeniden açılan işler, revizyon döngüleri, demo kapsamı
2026-10-19 · Salt okunur iç inceleme (web araştırması yok, kod değişmedi, Godot koşmadı, git'te yalnız log/show). Kaynaklar: hafıza klasörü (80 kayıt), `git log` (404 commit), `docs/tasks/**` (PRD'ler, RAPOR_A/B, OYNANIS_HUKMU, ERDEM_*), `docs/audits/`, `docs/ACIK_ISLER/`, `CLAUDE.md`.

Okuma notu: sha'lar commit başlığındaki kısa kimliktir. "Sınıf" harfleri görevdeki gibidir: a Erdem'in playtest ya da zevk kararı, b yeni modülün dokunuşu ya da entegrasyon, c hata, d cila ya da görsel, e sabit ya da denge ayarı. Sınıflandırmayı ben yaptım; çoğu işte birden çok neden vardır, tabloda baskın olanı yazdım. Git tarihleri commit zamanıdır, yazım zamanı değildir (§1'deki boşluğa bak).

## 0. Özet (10 madde)
1. 404 commit, 43 aktif günde, 115 günlük aralıkta. Son 10 günde (10-10 ile 10-19) 135 commit var, yani toplamın üçte biri aralığın %9'unda.
2. Bir PRD'nin koda inmesi ortalama bir gün sürüyor (§6.3). Sorun kodun yazılması değil; Erdem'in oyunu açıp "meh" ya da "hayır" demesi ertesi gün geliyor ve geri dönüş o noktada başlıyor.
3. Yeniden açılan 17 sistem çıkardım (§2). Baskın neden sınıfı a: Erdem'in playtest ya da zevk kararı (17'nin 11'i). Sınıf b 2, c 2, d 2.
4. En sık yeniden açılan beş alan: arayüz dili (5 yön, 3 ay), ürün/sprint döngüsü (en az 8 kez), olay motoru (6), ekip modülü (en az 8), hız merdiveni (6).
5. Bir kararın kısa sürede geri alındığı somut örnekler: Piyasa'nın v1.0'a kadar kilitlenmesi (10-11) 1 gün sonra kalktı (10-12); Frank'in çek kartı (10-11) 1 gün sonra kalktı; Hotfix düğmesi (10-11) 6 gün sonra silindi; "Sesler" (10-12) 5 gün sonra silindi.
6. Revizyonun en pahalı olduğu aşama "oyun içinde": ret, kod ve ekran kareleri bittikten sonra geliyor. En ucuz olduğu aşama "yazılı plan": Faz D ve Rakip Dünyası yazılı turlarda reddedildi, kod yazılmadan düzeldi.
7. Aynı tür ret tekrarlıyor: "araştırmasız üretim" (UI Lab, Piyasa maketleri), "ağırlıksız ya da sahte seçim" (olay şıkları, bütçe kesintisi kâğıdı), "görünmeyen model" (kart eksenleri, açıklanamayan memnuniyet kayması). Her biri hafızada ayrı bir kural olarak kayıtlı ama bir sonraki alanda yine yaşandı.
8. Ölçüm hep bot ile yapılıyor. 7 Ekim'den beri 14. haftanın ötesini oynayan bir insan oturumu kayıtlı değil (R15 §1.5). Kapıların hepsi yeşil olup oyun "meh" hissettirebilir; bu, §7'deki en önemli gözlem.
9. Demonun bitiş noktası üç yerde üç farklı yazılı: Series A kararının sonucu (CLAUDE.md §1), seed imzası (7 Ekim yardımcı yönetmen önerisi), 0-130 hafta penceresi (olay yazım kuralı). Süre de çelişkili: 60-90 dk hedef, 104 hafta 1×'te 39 dk (ACIK 104 açık).
10. Çıtaya göre açık: Steam sayfası yok, `steam_appid` yok, ses tek MP3 ve SFX sıfır, doruk (Series A) formalite, kayıp ekranı "ne öldürdü" demiyor, saat her karardan sonra elle başlıyor, yazılan 46 kâğıdın 27'si bot koşusunda hiç gelmiyor.

## 1. Zaman çizelgesi (2026-06-26 → 2026-10-19)
| Ay | Commit | Aktif gün | Büyük işler |
|---|---:|---:|---|
| 2026-06 | 2 | 2 | İlk import (PostShip satış aşaması, `dafd33c`); Faz 1 hata turu, 8 bug (`d28d3d5`) |
| 2026-07 | 15 | 7 | 07-02 açık tema + ses + ayarlar; 07-03 Blok A-D ve büyük revert; 07-14 endgame motorları, Ay sonu özeti, MeetingScene, VC pitch; 07-16 B2B satış sistemi, onboarding, lokalizasyon sistemi; 07-21 Ürün Rev3, Ekonomi Postası; 07-29 HR çekirdeği + Product×HR; 07-31 HR sekmesi, Finans v1 |
| 2026-08 | 81 | 13 | 08-03 Font Duruşması; 08-08 kayıt/yükleme, ultrawide; 08-10 koyu deri tema; 08-10..19 Lokalizasyon Faz 2 (~20 commit); 08-19 Kalibrasyon Turu A (§0-§16, ~15 commit); 08-20 Build Bar, Teslim yasası, ODA 3B spike; 08-21..24 Ekip modülü ve rev 11 (7 faz), kurucu cetveli, ghost code; 08-23 Frank v6; 08-26 olay motoru yeniden kuruldu, Satış rev 6; 08-27 görüşme sahnesi, seed turu |
| 2026-09 | 101 | 7 | 09-24 ölçüm botu, olay revizyonu; 09-25 Series A masası K1-K12 ve push öncesi düzeltmeler; 09-26 temizlik dalgası (~18 commit) ve CLAUDE.md sıfırdan; 09-27 3B ofis + pencereli sekmeler + krem palet, ODA emekli, temizlik sürüyor; 09-28 haftalık zaman modeli; 09-29 ofis insanları, görüşme paneli |
| 2026-10 (1-19) | 205 | 14 | 10-01 Ürün rev 7 sprint döngüsü; 10-02/03 Menajer tema altyapısı ve kabuk; 10-05 Ekran F1-F9; 10-07 Piyasa I1, Onarım 0; 10-08/09 yazar ajanı pilotu, olay motoru çekirdeği; 10-09 render + asset lab; 10-10 Saat, Sprint, Onarım 1, Açılış, mahalle (50 commit); 10-11 Ana menü AM0-AM11, Ekip G1-G4, Sprint, Açılış (58 commit); 10-12 Playtest K1-K5; 10-17 Faz A; 10-18 Faz B, Faz Q K0-K6; 10-19 Q K2 |

Notlar ve sınırlar:
- 08-31 ile 09-24 arasında 24 gün hiç commit yok. Nedeni kaynaklarda yazılı değil; olay motoru v3 commit'i "Mac'te yazılan V1-V8 main'e taşındı" (`5933acc`) diyor, yani başka bir makinede yazılmış iş sonradan toplu inmiş olabilir. Bu boşluktaki iş büyük ihtimalle 09-24/25 yığınına sıkışmış durumda (Görüş).
- Temmuz-Ağustos sayıları altta kalıyor: 6 "Local sync" commit'i haftalarca işi tek commit'e sıkıştırıyor (örn. `a71d762`, `3ee3963`, `c4eba05`).
- Ortalama 9,4 commit/aktif gün. En yoğun günler: 10-11 (58), 10-10 (50), 09-27 (33), 09-26 (28), 08-19 (26).
- Kalıcı biçim: dokunulan alan başına bir "tur" (Kalibrasyon Turu A, Temizlik, Onarım 0/1, Playtest K1-K5, Faz A/B/Q). 190 commit başlığı bir PRD/faz önekiyle başlıyor; 21'i "Temizlik", 39'u belge commit'i.
- 185 commit mesajı "onay bekliyor" taşıyor (TR/EN metin ya da sabit). Hiçbir noktada toplu kapanışı kayıtlı değil.

## 2. "Bitti" denip yeniden açılan sistemler
Sayım: yeniden açılış = daha önce "tamam" olarak commit'lenmiş ya da onaylanmış bir sistemin tasarım ya da davranışının yeniden yazılması ya da geri alınması. Cila düzeltmeleri (tek satır hata) sayılmadı.

| # | Sistem | Açılış sayısı | Tarihler ve kanıt | Baskın sınıf | Not |
|---|---|---:|---|---|---|
| 1 | Arayüz dili / tema | 5 yön | 07-02 açık tema `aab3497` → 07-03 revert `8c41f3d`,`5ab5bdb` → 08-10 koyu deri `3d11896` → 09-27 krem palet + pencereli sekmeler `f75d3e6` → 10-02 Menajer koyu sıcak `07594db`, kabuk D1-D4 `ad03653`..`e00d41c`, ekranlar F1-F9 `adb7af3`..`e9b29b8` | a | Üç ay içinde dört tema değişimi; her biri Erdem'in oyunu görüp reddetmesi ya da yön seçmesiyle |
| 2 | Ürün / yapım / sprint döngüsü | en az 8 | 07-03 Blok A/C reddi `fac923c`; 07-12 dört fazlı tracker; 07-17 Ürün Rev3 `3ee3963`; 08-20 Build Bar `780b06e`; 10-01 Rev7, eski yapım motoru silindi `1abbb7e`; 10-10/11 Sprint 1-11 (11 commit); 10-17 Faz A K1-K8; 10-18 Faz Q K0-K6 (sürüyor) | a | Her tur öncekini silip yenisini kuruyor; Faz Q beklenti formülünü 24 saatte yeniden yazdı (`9a0dff9`) |
| 3 | Hata / hotfix / aşınma | 4 | 07-13 bug sprint FeatureBuild'den çıktı; 10-11 G1 "hotfix düğmesi" `88aedb6`, G6 "Sesler'in yenisi" `aeae8a9`; 10-17 Faz A K2 Hotfix ve Hata yığını kalktı `c6b19c8`, K5 aşınma silindi `d52f199`, K6 Sesler kalktı `496e229`; 10-17 B kararı "bedelsiz hata yok" | a | Hotfix 6 gün, Sesler 5 gün yaşadı (RAPOR_A, sprint-urun-phases kaydı) |
| 4 | Hız merdiveni / zaman modeli | 6 | 07-29 yeniden ayar + 3× (`b8bd29f`); 08-19 §10 1×/2×/3× kod ve arayüz `7aecd35`; 09-28 haftalık model `1b8f2f3`; 10-09 merdiven ×4 `a90d910`, ofis temposu `74d0b8b`, satış telefonu `9404b5d`; 10-10 üç basamak `6d75ad8` | a (+e) | 10-09 değişikliği demo süresi hedefini bozdu: ACIK 104 hâlâ açık |
| 5 | Olay motoru | 6 | 08-26 "eski motor silindi" `cc952e4`; 09-27 özne başına örnek `8c914ec`; 10-03 E1-E3 gelen kutusu; 10-08 verim çekirdeği `6148884`; 10-10 v3 V1-V8 (`5933acc` + ~10 commit); 10-18 Faz B B1-B9 (`05966f3`..`cb5f51c`) | c/b | 08-21 denetimi 28 olaydan 27'sinde "kopya yalanı" buldu (etiket bir kaynağı söyler, motor başkasını ya da hiçbir şeyi keser); `Büyüt` bedelsiz MRR pompası |
| 6 | Olay / kâğıt içeriği | 6 tur | 08-19 rev1 reddi (1/10) → rev2; 09-24 event revizyonu `1906352`; 10-08 pilot sonrası "sorun şıklarda"; 10-09 yazar pilotu `a40a298`; 10-16 tur 2 "komik" bulundu; 10-18 40 kâğıt `ea3c20c` ama 46'nın 27'si bot koşusunda gelmiyor | a | Şık kalitesi 3 ayrı kuralla (3 hafıza kaydı) yeniden yazıldı |
| 7 | Frank'in sesi / kartları | 5 | 08-19 Voice Pass; 08-20 v6 bütün külliyat (`Frank Diyalogları · v6`, 128 string); 08-23 v6 turu `262cfd4`; 09-25 soğuk çıkış ve yaklaşma satırları; 10-11 C6 v1.0 kartı taslak `fb9946e`; 10-12 çek kartı ofiste ve Olaylar'da kalkar `5936af8` | a | CLAUDE.md §3: yeni Frank satırı yalnız taslak, onaysız ekrana çıkmaz |
| 8 | Series A / VC masası / seed | 6 | 07-14 Spec 4 VC pitch; 08-27 seed turu `7946ff3`; 09-25 K1-K12 `2cbbcd8`,`28d5edc`,`8e49dbd`, push öncesi düzeltmeler `fc58e7c`, "madde 5 geri alındı" `86e33eb`; 09-29 görüşme paneli `cf80260`; 10-17 B9 yatırımcı hazırlığı kalktı `cb5f51c`; 10-18 hüküm hâlâ "doruk formalite" | a | Kapıdan imzaya 1-5 hafta, 10 tohumda 9 imza, masada 0 zorlama (R15 §3.3). ACIK_ISLER #5: elden geçirilecek |
| 9 | Ekip / HR modülü | en az 8 | 07-29 HR çekirdeği `b8bd29f`; 07-31 HR sekmesi `c069b56`; 08-21 ekip modülü yeni motor `18d27e3`; 08-23 rev 11 (7 faz, `2b56fd2`..`8e2c149`); 08-24 kurucu cetveli 0-10, şema 8 `90d8654`; 10-03 F1 `adb7af3`; 10-11/12 G1-G6; 10-17 Faz D "çok sığ" → D_MODEL v2 → v3 | a | Rev 11 planı: atama birimi alan→iş, moralin çıktıyı etkilemesi, maaş bantları (3 yapısal değişiklik). 10-12 Erdem: "kaydırma çubuğu olmalı", kararı yardımcı yönetmen yanlış vermişti |
| 10 | Satış / B2B / görüşme | 6 | 07-16 B2B sistemi `c4eba05`; 08-26 Satış rev 6 `4bdc1fb`; 09-29 görüşme paneli; 10-05 F4; 10-11 O22 "Satış bir süreçtir" `8eacfe7` → 10-12 Erdem: kurucu aynı anda birden çok anlaşma yürütmemeli; 10-18 R15: en kötü cevapla %98 kazanılıyor | a | Görüşme "çözülmüş": ACIK_ISLER #2 |
| 11 | Gider ve ekonomi | 4 | 09-27/28 "yalnız sunucu faturası" kararı → 10-02 geri alındı (`ec49028`, kalibrasyon turu: Araçlar tabanı + servis gideri) → 10-10 C7 "Geçim ve araçlar" `3e0c976` → 10-17 Erdem: araç ve servis gideri kalkar (fair-economy kaydı) | a (+e) | Aynı kalem üç ayrı yönde karar gördü |
| 12 | Memnuniyet modeli | 3 | 07-16 iki katmanlı B2B memnuniyeti; 10-08 yazar pilotu "bir tikte siler" bulgusu; 10-11 O19 nötr açılış `419ee6e`; 10-17 Erdem: "niye 45'e düşüyor, anlamıyorum"; Faz C: kayma yok | a (+c) | Erdem'in kuralı: nedensiz düşüş yok |
| 13 | Açılış kilitleri ve çek kartı | 2 | 10-11 Açılış C3 `f45ca13` (çek her yüzeyde), C4 `7a42c0b` (Piyasa v1.0'a kadar kilitli) → 10-12 Playtest K1 `5936af8`, K3 `6a1225a` ikisini geri aldı | a | PRD onaylıydı; oyun içi playtest 1 gün içinde reddetti |
| 14 | Ana menü arka planı | 2 | 10-11 AM4 `69f4786` (akşam şehri, 19 onaylı maket karesiyle birlikte) → 10-12 "bunu onaylamam mümkün değil" → K4 `55f0f89` | d | Onaylı maket vardı; uygulama makete benzemedi |
| 15 | Ofis görseli / render / mahalle | 4 dalga | 08-17/20 ODA pişmiş sanat ve 3B spike `76870958`; 09-27 ODA emekli, 3B ofis; 09-29 karakterler; 10-09 render düzeltmeleri (8 commit, z-çatışması, PCF, 19:26 güneş-ay); 10-10 mahalle (`210c2a8` ve 4 ek düzeltme `81da8f3`,`33a89e5`,`bcb6a05`,`28099ec`); 10-10 paket asetler reddedildi | d | "Paketteki asetleri beğenmedim, jenerik" (feedback-bespoke-assets) |
| 16 | Sprint süresi ve erken kapanış | 2 | 10-11 G4 "sprint 1 ya da 2 hafta, kartlar bitince erken kapanır" `6660058` → RAPOR_B §1.4: 1.506 sprintin 956'sı 1 tikte kapandı, kâğıt zarı atılamadı (%9,8 kâğıt) → 10-18 Erdem "sabit iki hafta bırakılabilir mi" | b | Bir modülün (G4) başka modülü (B kâğıdı) sessizce susturması: entegrasyon sınıfı |
| 17 | Piyasa penceresi | 3 | 10-02 PRD v4 (ince) → v5 5.812 satır (ağır) → v6 971 satır; 10-07 P3 maketleri 2 kez reddedildi; I1 `69d21c0`..`b241411`; 10-12 K3 kilit kalktı | a/d | Bkz. §3 R3 |

Sınıf özeti (baskın sınıf, 17 satır): a 11, b 1 (+ #5'in bir kısmı), c 2 (#5 ve #12'nin hata bulguları), d 2 (#14, #15), e 0 baskın ama #4 ve #11 içinde var. Satır #16 b'nin tek net örneği; bunun nedeni "modül A bittikten sonra modül B ölçüldü" olduğu için görüldü, aksi hâlde sessiz kalacaktı (§7).

Kalite kapısını geçip kullanıcıya reddedilen işler: 07-03 paketi "mantık 35/35 harness PASS, görsel reddedildi"; yazar pilotu "16/18 kör kapıdan geçti", Erdem "ne alaka"; Faz Q K1 "oyuncu hiçbir şey görmez" dedi, gerçek geri bildirim K2 sonrası bekliyor.

## 3. Revizyon döngüleri
Her satır: tur sayısı, ret nedeni, ret anında elde ne vardı (Y: yazılı plan, M: maket/kare, O: oyun içi), sonunda ne çözdü.

### R1 · Ürün sayfası ve BuildHUD (07-03 → 07-17)
- Tur: 3 (07-03 Blok A/C reddi; 07-12 Erdem'in F5-onaylı Claude Design maketi port edildi; 07-17 Rev3 BuildHUD yeniden reddi).
- Ret nedeni: 07-03 "rezalet, eskisinden kötü"; çift build gösterimi, sağ bar taşması, kurma ekranı estetiği. 07-17: "sana bunu düzenle diyen oldu mu" (spec'ten türetilmiş bir karar onaylanmamıştı).
- Elde ne vardı: Y (mantık doğrulanmış, 35/35 harness), görsel hiç maket yok. Kör ajanlar tek atışta üretti.
- Çözen: küçük adım → Erdem ekran görüntüsü/F5 → sonraki adım. Hafızada kural: "tek ekran tek tur, maket ya da referans görsel üzerinden konuş" (design-work-lessons).

### R2 · UI Lab: üç yön (09-30 → 10-02)
- Tur: 1 (üç yönün üçü de reddedildi: Evrak/Dosya/Gazete).
- Ret nedeni: "hiç birini beğenmedim, sen hiç araştırma yaptın mı, diğer oyunlar nasıl yapmış". Altyapı kusursuz çıkmıştı (piksel eşliği, glif, override kapıları geçti).
- Elde ne vardı: Y (spec'te metafor + palet) ve O (gerçek ekran örnekleyen lab). Kapılar estetik kaliteyi ölçmez.
- Çözen: referans araştırması → dört yön (Oyuncak/Menajer/Editoryal/Kurucu) → Erdem Menajer'i seçti (10-02) → "önce bütün ekranların maketi, tuvalde onay; sonra oyun". Plan 11 kararlı; F1-F9 sonradan oyuna girdi.
- Sonuç: bir hafta içinde tema altyapısından dokuz ekrana geçildi; ret nedeni tekrar etmedi ama font (Barlow/Plex/Serif) bugün yine zayıf bulunuyor (görev metni).

### R3 · Rakip Dünyası ve Piyasa penceresi (10-02 → 10-12)
- Tur: yazılı 3 (v4 ince, v5 ağır, v6 kabul) + maket 3 (P3 11 kare reddi, dört yön referanssız reddi, V1 liste+rapor kartı kabul) + oyun içi 1 (kilit kalktı).
- Ret nedeni: v5 5.812 satır "bu kadar detaylı olmasına gerek var mı; sos olsun çekirdek olmasın". P3: "gelişigüzel, eklenmiş olmak için eklenmiş, oyunu yansıtmıyor, bilgi yoğunluğu gereksiz". Dört yön: "rakip oyunların ekranlarını incelediniz mi???".
- Elde ne vardı: Y (PRD), sonra M (kareler). Referans ekran görüntüsü yoktu; araştırma raporunun sütun listesi brief'e kopyalanmıştı.
- Çözen: önce gerçek ekran görüntüleri → referans panosu → Erdem işaretler → yön/maket. Kural: 3-4 yön, her biri TEK kare, sahip seçmeden tam set yok.

### R4 · Frank ve olay metni, 1. dalga (08-19 → 08-23)
- Tur: rev1 reddi (1/10) → rev2 aynı gün → Voice Pass → v6 külliyatı (128 string) 08-20 → v6 turu 08-23 → 08-21 denetim.
- Ret nedeni: rev1'de sahne düzeni (aksesuar, beden anlatımı, benzetme, sahnelenmiş sessizlik). Rev2'de kelime yasağı aşırı düzeltmeydi: "niye kelimeleri banlıyorsun, doğru düzgün kullansan yeterdi".
- Elde ne vardı: Y (EVENT_POOL_DESIGN v1, dosya adı `docs/.md`), taslak metinler.
- Çözen: mühürlü referans sahne (Y5.1), yapısal kontroller (Frank ≤3 cümle), kelime listesi iptal. Metni sonunda Erdem ve yönetmen yazdı ("they rewrite the prose anyway"); ajan işi ham madde + kusur raporuna indirildi.

### R5 · Olay şıkları ve kâğıtlar (10-08 → 10-18)
- Tur: 3 (10-08 pilot sonrası; 10-16 tur 2; 10-18 Faz B teslimi).
- Ret nedeni: 10-08 "olaylar fena değil, problem şıklarda: ne alaka dedirtiyor, modifier'lar alakasız" (çalışan olayı sprint hızını düşürüyor; seçimi bariz). 10-16: sabit "$4.000 kupon", "−%40" ve kesik üslup "komik"; kart tekrarı. 10-18: yazılanın yarısından fazlası gelmiyor (27/46).
- Elde ne vardı: O+M (inceleme sayfası artifact 6F4qLi2y5TPsg8ds6ia5q3, işaretler). Kör kapı 16/18 geçirmişti; kapı Erdem'in zevkini ölçmüyordu.
- Çözen: BRIEF §9b (bedel öznesine düşer, bedava çıkış yok, koşul hikâyeye uyar); bedel olayın ölçeğinden; Faz B (40 kâğıt, tetik hızları). Açık: tetik oranı (kâğıt %9,8), tasarımcı kâğıdı 0 (RAPOR_B §1.3).

### R6 · Faz D ekip modeli ve Faz C içerik (10-17)
- Tur: yazılı 3 (D_MODEL v1 → v2 → v3; C_ICERIK v2 → v3; D_SIM, D_SIM_v3).
- Ret nedeni: "çok sığ düşündüğünü düşünüyorum"; çalışan başına %5 gibi sabit 10 kişide oyunu kırar. Gider: "göremediği gideri koyma". Memnuniyet: nedensiz kayma.
- Elde ne vardı: Y (yazılı model + 145 senaryo × 20 tohum simülasyon).
- Çözen: oyun oyun mekanik dökümü (R1-R15 araştırma), 1-3-6-12-25-50 kişi sınaması, D_SIM_v3. Kod yazılmadan düzeldi; bu, §7'deki en ucuz revizyon örneği.

### R7 · Ana menü arka planı (10-11 → 10-12)
- Tur: 1 (ret) + 1 (K4).
- Ret nedeni: şehir ekranı doldurmuyor, dört köşede harita dışı boşluk, "çok turuncu", tekne ve dalgakıran süsü. "Maketteki görseli onaylarım, bunu onaylamam mümkün değil."
- Elde ne vardı: M (19 onaylı maket karesi) ve O (uygulama). Maket onaylıydı, uygulama makete yaklaşmadı.
- Çözen: Playtest K4 `55f0f89`: tam ekran, koyu gri ton, süs yok. Tek turda.

### R8 · Açılış kilitleri (10-11 → 10-12)
- Tur: 1.
- Ret nedeni: Frank'in çeki ofiste ve Olaylar'da dolaşıyor; Piyasa v1.0'a kadar kilitli; ekranlarda kalıcı açıklama satırları.
- Elde ne vardı: Y (Açılış PRD'si, Erdem'in 10-10 kararları ile onaylı).
- Çözen: Playtest 5 maddelik TASK (K1-K5), 1 gün. PRD'nin kendisi kabul edilmiş olsa da oyun içi görünüş kabul edilmedi.

### R9 · Ofis ve render (10-09 → 10-10)
- Tur: 3+ (render düzeltme dalgası, paket aset reddi, mahalle 5 ek düzeltme).
- Ret nedeni: kaydırınca değişen gölge bandı (z-çatışması), güneş ile ay geçişinde bir anda dönen gölgeler; paket asetler "jenerik"; mahalle blokları kaldırım ve yolların üstüne oturuyor.
- Elde ne vardı: O (kaydırma probu, ölçüm). Önce-sonra karşılaştırması 9 kümelik deney hâline gelmişti; Erdem "aday başına tek önce/sonra çifti, bu makinede ms" dedi.
- Çözen: PCF deseni ve z-fix, `210c2a8` mahalle; kural: tek çift önce/sonra (13:00 + 22:00, aynı kamera).

### R10 · Ofis yönü (08-17 → 09-27)
- Tur: 3 (ODA mühürlü sanat → 3B spike → 3B ofis ve ODA emekli).
- Ret nedeni: yazılı karar; masa POV (ODA) tamamen silindi. Kararı Erdem verdi (3 karar), Claude Design v12 maketi hedefti.
- Elde ne vardı: M (Claude Design "Ofis Görünümü v12") + Y (plan, 10 bölüm).
- Çözen: tasarım JS'i byte-verbatim alındı, dışa aktarım hattı, ardından karakterler (Quaternius, 8 karar). Bu zincir iki sprintlik emeği (ODA'nın sekiz katmanı 3B'den üretilmişti, 08-20) 5 hafta sonra emekli etti (`76870958` → `f75d3e6`).

### R11 · Series A masası (09-25 → 10-18)
- Tur: 2 ve 3. tur kapanmadı.
- Ret nedeni: 09-25 push öncesi düzeltmeler (seed board kilidi, kapalı yol satırı, masa TR metinleri); 10-07 değerlendirme "2 haftada 0 push ile imza"; 10-18 hüküm "doruk formalite".
- Elde ne vardı: O (bot koşuları 10 tohum), Y (hüküm).
- Çözen: hâlâ yok. ACIK_ISLER #5 "elden geçirilecek", yeri Faz Q/C/D sonrası.

### R12 · Hata mekaniği ve kümeleme (10-16)
- Tur: 2 (kümeleme önerisi reddi, "bedelsiz hata yok" E1 cevabı).
- Ret nedeni: "tamamen random olsun ancak oyuncuyu sürekli bug sprint koşarken görmeyelim".
- Elde ne vardı: Y (PRD_FAZ_A_HATALAR) + bot ölçümü.
- Çözen: A Karar 3 + 4. RAPOR_B yine 40 hedefin 6'sının tutmadığını söyledi; sabit oynatılmadı (§3.1).

### R13 · Faz Q beklenti formülü (10-18 → 10-19)
- Tur: 1 yazılı + 1 kod.
- Ret nedeni: "Bootstrap'te yalnız çekirdek, Traction'da çekirdek 1, öteki 0,5, Series A'da 1,5-1... mesela bunları neye göre kuruyorsun? Anlaşılır da değil."
- Elde ne vardı: Y (PRD_FAZ_Q_KALITE + KALITE_v2).
- Çözen: Q K2 `9a0dff9`: beklenti evreden değil müşterinin büyüklüğünden okunur. Bir gün.

### R14 · Yazı tipi (08-03 → 10-02 → bugün)
- Tur: 2 karar + bugünkü eleştiri.
- Ret nedeni: 08-03 Set A kanon (Source Serif 4 / IBM Plex Sans / JetBrains Mono); 10-02 Menajer ile Barlow Condensed + Plex + Serif; görev metni bugün fontu zayıf buluyor.
- Elde ne vardı: O (Font Duruşması specimeni, 4 render). Seçim ölçülmüş render üzerinden yapıldı ama sonraki yön değişimi fontu da götürdü.
- Çözen: açık.

Tur özeti: 14 döngünün ret anındaki durumu: yalnız yazılı elde olan 5 (R2'nin ilk yarısı, R6, R8, R11 PRD hâli, R13), maket elde olan 3 (R3, R7, R10), oyun içi elde olan 6 (R1, R5, R9, R12, R14, R8 playtest hâli). En ucuz çözülenler (R6, R13) yazılı aşamada yakalananlar.

## 4. Bugünkü ajan düzeni, uygulandığı hâliyle
Kaynak: 13 `feedback-*` kaydı, `CLAUDE.md` (347 satır), hafıza girdileri. Her kuralın yanında konma nedeni.

| # | Kural | Neden konduğu |
|---|---|---|
| 1 | Tek klasör, tek dal; worktree, rebase, merge yok; uzakta yalnız `main` (08-20) | Paralel oturumlar aynı checkout'a yazıyor; dal ve merge çatışması, `git switch -c` HEAD'i herkes için taşıması. Teslim yasası `14f4a13` |
| 2 | `git checkout -- <yol>` yasak, `stash`/`reset --hard`/`clean` yok (08-23) | Kirli dosyada başkasının işini siler; 6 smoke vakası kayboldu, süit derlenmez oldu (SMOKE_LOSS_2026-08-23) |
| 3 | Push yalnız "push et" dendiğinde; push öncesi tam smoke yok (10-06) | "100. kez smoke test yapılıyor" (Erdem); 351 vakalık süit 2 paralel ~50 dk; hedefli kapılar commit'te zaten koşuyor |
| 4 | Tam smoke yalnız lead entegrasyonunda (07-29) | Ara fazlarda tam süit ve baseline byte-diff harcıyor |
| 5 | Commit'ten önce diff, ayrı ajan tarafından kıdemli mühendis gözüyle (CLAUDE §9) | "Şişen kod bir sonraki task'ın keşfini pahalılaştırıyor" |
| 6 | Model rolleri: Haiku mekanik, Sonnet normal, Opus yalnız zor; commit başına en çok 1 inceleme, en çok 1 düzeltme, delta/ölçüm turu yok (10-11) | İki $200 hesap 1,5 günde bitti; Erdem task'ın 10 saat sürmesini istemiyor |
| 7 | 10-16 revizyonu: Sonnet kod (xhigh/max), Opus 5.5 commit öncesi kıdemli inceleme + düzeltme hakkı, Haiku mekanik; plan Opus'a incelettirilir | Kalite ve maliyeti aynı anda istiyor; iki hafta içinde kural değişti (bkz. §7 çelişki) |
| 8 | Her faz önce adım tablosu + onay; faz = görev yazısı → plan → onay → uygulama (10-16) | Kod yazılmadan yönü yakalamak (Faz D "sığ"); maliyeti görünür kılmak |
| 9 | Tasarım sabitleri "onay bekliyor" altında listelenir, kalibrasyonda ölç, sabit değiştirme (CLAUDE §3) | Ajanın denge kararı vermesini engellemek; sahip onayı |
| 10 | TR/EN metin onaysız değişmez; "TR/EN onay bekliyor" işareti (185 commit); Frank satırı yalnız taslak | Erdem metni kendi sesi olarak görüyor; B2B/olay metni 1.882+ anahtar |
| 11 | PRD bir eylemi açıkça söylüyorsa, "onay bekliyor" işaretli olsa da yeniden sorma (10-18) | Erdem: "PRD ne diyorsa onu yap"; adım tablosundaki gereksiz soru |
| 12 | Görsel iş: önce referans araştırması (gerçek ekran görüntüsü), sonra 3-4 yön × tek kare, Erdem seçer, sonra üretim (10-01, 10-07) | UI Lab 3/3 reddi; Piyasa maketlerinin iki reddi |
| 13 | Görsel kabul: değişen ekranın TR+EN çekimi 1920'de; en çok 2 düzeltme turu; ekranı ajan kendisi okur (CLAUDE §11) | "Kare çekildi" doğrulama değil; kapılar estetiği ölçmüyor |
| 14 | Görsel araştırmada aday başına tek önce/sonra çifti, bu makinede ms (10-10) | Dokuz kümelik render deneyi |
| 15 | Paket asetler yok; mevcut özel asetler kalır (10-10) | "Paketteki asetleri beğenmedim, jenerik" |
| 16 | Ölçeklenen mekanik: her kural 1-3-6-12-25-50 kişide sınanır; oyun oyun mekanik dökümü, kaynak URL zorunlu (10-17) | "Çalışan başına %5" sabiti 10 kişide kırılır; EA'da şirket 20-50 kişi olacak |
| 17 | Adil ekonomi: oyuncunun göremediği/yönetemediği gider yok; B2B memnuniyet nedensiz düşmez (10-17) | Erdem: "amacımız oyuncuyu gerçek hayat gibi aşırı zorlamak değil" |
| 18 | Oynanış merceği: her mekanikte "oynanışı nasıl etkiler?" (hangi karar, ne sıklıkta, tek satırda okunuyor mu, angarya mı); çıta %90 olumlu (10-18) | "Steam AI generated oyun kaynıyor, sıradan olamayız" |
| 19 | Olay seçeneği: somut hamle, bedel olayın öznesine düşer, bedava çıkış yok; kelime listesi yasağı yok | Yazar pilotu ve Batch 1 reddi |
| 20 | Kart tekrarı çok seyrek, olay sıklığı rastgele (en az 4 hafta) | EA 20 yıl oynanabilir; "düzenli gelirse tasarlanmadığı ortaya çıkar" |
| 21 | Görünmez model kurulmaz (kart eksenleri vb.) | "Neyi temsil ettiğini ben bile bilmiyorum" |
| 22 | WebSearch oturumda 200 aramalık bütçe; `searches`/`evidence` alanıyla kapıla | Bütçe bitince ajanlar sessizce model bilgisine düşüyor |
| 23 | Bellek baskısında arka plan kabuğu yeniden başlatılmaz, Erdem oyun oynarken ağır iş açılmaz | 16 GB RAM, LoL ile birlikte; Godot alt ağacı yetim kalıyor |

Uygulanışta görülen sonuç: kural sayısı 23, yarısı "yeni bir hata yaşandı" anından doğmuş (SMOKE_LOSS, UI Lab, Piyasa, olay şıkları, token limiti). Kuralların neredeyse tamamı süreç ya da maliyet kuralı; "oyun eğlenceli mi?" sorusuna bağlı olan yalnız 18. kural (10-18) ve 16-17. Hiçbiri bir insan oturumunu zorunlu kılmıyor (§7).

## 5. Demo kapsamı
### 5.1 Demonun tanımı (kayıtlı)
- CLAUDE.md §1: "Demo Bootstrap'tan Series A kararının sonuçlanmasına kadar sürer, 60 ile 90 dakika [WORKING] hedefler."
- Export: `export_presets.cfg` 3 preset (Demo, EA, Full), AM1a `44f74d9`; `EndingsSystem.build_scope()` varsayılanı demo; Frank şeridi, wishlist ve "SIRADA NE VAR?" kartları yalnız demoda (ACIK_KARARLAR).
- 10-07 yardımcı yönetmen önerisi: "demo seed imzasında biter; pazarlama demodan sonra" (codirector-session-2026-10-07; Erdem'in açık kabulü kayıtlı değil, 10-11 kaydında "demoya ileride pazarlama" geçiyor).
- Rakip dünyası kararı (10-06): "demo = 2012-13 dilimi; AI yalnız ayak sesi".
- Olay yazım kuralı (10-08): "demo penceresi 0-130 hafta".
- OYNANIS_HUKMU (10-18): demonun orta oyununu satış, sprint, söz ve acil durum taşır; ilk yenileme imzadan 44 hafta sonra, yani yaklaşık 53. haftada; demoda yenileme neredeyse yok; yenileme EA'nın işi. Bot Series A'yı 57-71. haftada imzalıyor.
- Hız merdiveni değişimi sonrası: 104 hafta 1×'te 39 dk, 60-90 dk saf saat 160-240 hafta eder (ACIK 104, açık). Bot Series A'ya 21-27 dk saf saatte varıyor; farkı "duraklı süre" doldurmak zorunda (R15 §0.1, ölçüm yok).

Çelişki: üç farklı bitiş noktası (Series A sonucu, seed imzası, 130. hafta) ve iki farklı süre (60-90 dk, 39 dk) yazılı. Kabul edilmiş tek bir "demo bitti" tanımı bulamadım.

### 5.2 Var olanlar (kanıtlı)
- Çekirdek döngü uçtan uca çalışıyor: 5/5 bot koşusu sona ulaşıyor, kayıt RNG dâhil geri geliyor (10-07 değerlendirme; 10-18 20 koşu daha).
- Sprint döngüsü (Rev7 + Sprint 1-11), ekip modülü (rev 11 + G1-G6), hata mekaniği (Faz A), olay motoru v3 + 40 kâğıt (Faz B), Piyasa I1, Ofis 3B + karakterler, ana menü, çıkış onayı, Devam yuvaları, TR+EN.
- Ürün: B2B yalnız ERP (5 Çekirdek hat: Fatura, Defter, Nakit akışı, Stok, Belge girişi), B2C yalnız e-ticaret (10-11 kararı).
- Faz Q: K0-K2 ve K6 inmiş; K3a-K9 sürüyor.
- Belgeler: 1.338 izlenen dosya `docs/` altında; 20 PRD/TASK belgesi (23.871 satır `docs/tasks` altında).

### 5.3 Eksik ya da kırık (kaynak: OYNANIS_HUKMU §5-§6, R15, ACIK_ISLER)
| Alan | Durum |
|---|---|
| İnsan oturumu | Yok. 14. haftanın ötesini oynayan insan kayıtlı değil (R15 §1.5) |
| Doruk (Series A) | Formalite: 9/10 imza, masada 0 zorlama, ret sonrası 40 hafta boş; "Üçüncüde yol biter" metni yanlış; ret `faced_series_a` yazmıyor |
| Orta oyun hedefi | Seed sonrası TopBar "Sıradaki" boş; 40 hafta adlı hedef yalnız Finans'ta; para baskısı yok (Traction'ın %94'ünde runway sonsuz) |
| Satış görüşmesi | En kötü cevapla %98 kazanılıyor (3.828 oturum) |
| Saat | Her karardan sonra elle başlıyor; B2B Traction'da haftada 1,7 durma |
| Kayıp ekranı | "Ne öldürdü" cümlesi ve tek tık Tekrar Dene yok; `ending_scene.gd` 7 Ekim'den değişmedi |
| Zorluk | Yalnız başlangıç nakdi; 3 basamak ve rahat mod yok |
| Etkisiz yüzeyler | Huylar etkisiz, 4 Ar-Ge düğümünün okuyucusu yok, 2 kilitli köken |
| B2C orta oyun | Haftaların %65'inde kart yok; fiyat kolu E'ye bağlı |
| Kâğıt hacmi | 46 kâğıdın 27'si bot koşusunda hiç gelmiyor; tasarımcı kâğıdı 0/8; sprint 1 tikte kapanınca zar atılmıyor |
| Vitrin | Ses tek MP3 (AI aracıyla üretildi, $10 ticari lisans Erdem'e kalmış), SFX 0, gazete sanatı yer tutucu, `steam_appid` yok, 720p'de 9 px yazı, Steam sayfası yok |
| Yapay zekâ açıklaması | Yazar ajanı ve paket asetler için Steam açıklaması kararı Erdem'de |
| Kararlar | `ACIK_KARARLAR` 2.124 satır, kararlar en az 107 numaraya çıkıyor; ISLER.md 30 madde (8 başlık); faz_cde ACIK_ISLER 17 madde |
| Onay bekleyenler | 185 commit "onay bekliyor"; RAPOR_A ve B'nin sabit/metin listeleri |
| Test paketi | 345-351 vaka, "yalın pakete" değiştirilecek (ISLER) ama tam süit hâlâ 50 dk |
| Faz Q/C/D | Q sürüyor; C ve D yalnız PRD (700 satır her biri), uygulanmadı; E hiç başlamadı |

7 Ekim'in dört kırık alanı (ilk saat, orta oyun, doruk, vitrin) 12 gün sonra: ilk saat kapandı (bir kalıntıyla), orta oyun açık, doruk açık, vitrin kısmen (R15 §0.9). Yani dört alandan biri kapandı.

### 5.4 Hedef sayılar
- Hedef: Steam'de %90 üstü olumlu, ilk 6 ay 5.000+ satış. 10-07'de yardımcı yönetmen hükmü: %85 bu build ile olmaz; 5K "düzeltilmiş build + demo + 20-40K wishlist" ile makul.
- Demo için Steam sayfası, wishlist toplama ve mağaza görselleri henüz yok; ilk 10 saatte olumsuz yorumların %46-61'i toplanıyor (R14 §2) ama demo 60-90 dk.

## 6. Sayılar
### 6.1 Commit
| Ay | Commit | Aktif gün | Commit/aktif gün |
|---|---:|---:|---:|
| 2026-06 | 2 | 2 | 1,0 |
| 2026-07 | 15 | 7 | 2,1 |
| 2026-08 | 81 | 13 | 6,2 |
| 2026-09 | 101 | 7 | 14,4 |
| 2026-10 (19 gün) | 205 | 14 | 14,6 |
| Toplam | 404 | 43 | 9,4 |

Hız arttı: Eylül ve Ekim'de commit/aktif gün Ağustos'un 2,3 katı. Ekim'in 205 commit'inin 135'i son 10 günde.

### 6.2 Faz ve PRD
- İzlenen PRD/TASK dosyaları: `docs/tasks` içinde 14 `PRD_*` + 1 `TASK_*`; `faz_ab` 2 PRD (A, B); `faz_cde` 3 PRD (C, D, Q). Toplam 20 yazılı görev belgesi. İzlenmeyenler: PRD_ANA_MENU_ONBOARDING, PRD_URUN_DERINLIK, `faz_ab/`, `faz_cde/`.
- Önek taşıyan commit dizileri: Faz A 8, Faz B 9 (+`fc6b392` düzeltme), Faz Q 4 (K0, K1, K2, K6), Sprint 11, Açılış ~15, Ana menü ~15, Onarım 0 ~11, Onarım 1 ~22, Saat 10, Ekip G 6, Playtest K 5, Ekran F 7, Kabuk D 4, Piyasa I1 4, Kalibrasyon Turu A ~16, Lokalizasyon Faz 2 ~18, Ekip rev 11 ~12.
- 190 commit başlığı bu öneklerden biriyle başlıyor (sayım ön ek kümelerine göre, yaklaşık).

### 6.3 PRD'den kabule
Git'ten çıkarılabilen: PRD'nin eklendiği gün → son uygulama commit'inin günü.
| PRD | PRD günü | Son uygulama commit | Süre | Oyun içi geri alma |
|---|---|---|---:|---|
| Ürün rev 7 | 10-01 | 10-01 `1abbb7e`, kalibrasyon 10-03 | 0-2 gün | Erdem'in 8 kararı 10-02 |
| Onarım 0 | 10-07 | 10-08 `2e071b6` | 1 | yok kayıtlı |
| Yazar pilotu | 10-08 | 10-09 `a40a298` | 1 | 10-08'de şık eleştirisi |
| Render + asset lab | 10-09 | 10-10 | 1 | paket aset reddi 10-10 |
| Saat | 10-10 | 10-10 K10 `67ee47f` | 0 | K7 finans eşiği ❌ |
| Sprint | 10-10 | 10-11 Sprint 11 `7c26ce5` | 1 | K5 beta kanalı çıktı 10-12 |
| Açılış | 10-10 | 10-11 C10 `edea607` | 1 | K1, K3 geri aldı 10-12 |
| Onarım 1 | 10-10 | 10-11 O21 `85ac180` | 1 | bazı maddeler bekliyor (O11) |
| Ana menü | 10-11 | 10-11 AM11 `ebdfe70` | 0 | K4 10-12 |
| Ekip verim | 10-11 | 10-12 G6 `aeae8a9` | 1 | G1 hotfix, G6 Sesler 10-17'de silindi |
| Faz A | 10-16 | 10-17 K8 `26b60da` | 1 | Faz B ile 6 hedef ❌ |
| Faz B | 10-16 | 10-18 B9 `cb5f51c` | 2 | Erdem onayladı 10-18 |
| Faz Q | 10-18 | K2 10-19, sürüyor | ≥1 | bekliyor |
Medyan: 1 gün. Gerçek kabul (Erdem'in oyunda onayı) git'te yok; hafıza kayıtlarından: 13 PRD'nin en az 5'inde ilk 2 gün içinde geri alma ya da düzeltme turu var (Sprint, Açılış, Ana menü, Ekip verim, Render). İlk geri alma oranı yaklaşık %40 (5/13), kaba tahmin.

### 6.4 Açık iş
- `docs/ACIK_ISLER/ISLER.md`: 30 madde, 8 başlık, 161 satır.
- `docs/ACIK_ISLER/ACIK_KARARLAR.md`: 2.124 satır, 6 üst başlık, numaralı kararlar en az 107'ye çıkıyor.
- `docs/tasks/faz_cde/ACIK_ISLER.md`: 17 madde ("Q, C, D dışında kalanlar").
- OYNANIS_HUKMU §6: 13 PRD dışı risk. §4: Erdem'e 10 açık soru.
- RAPOR_A §1: 4 "önce bakılacak" soru; RAPOR_B §1: 6+ soru, 29 numaralı soru listesi.
- Birikim sorunu: ACIK_KARARLAR kuralı "ajan açık maddelere dokunmaz"; yani maddelerin kapanması Erdem'in cevabını bekliyor (CLAUDE §3).

## 7. Gözlemler (Görüş)
Aşağıdakiler benim yorumum; sayısal temelleri §2-§6'da.

1. Yeniden açılmanın en büyük kaynağı, oyuncu (Erdem) yerine bot ve kapıların "tamam" demesi. Sınıf a baskınlığı (17'nin 11'i) ve §3'teki 14 döngüden 11'inde ret kaynağı insan zevki ya da playtest. Kapılar doğruluk ölçüyor (parse, smoke, event-lint, loc_residue, piksel eşliği); oyun "güzel mi, eğlenceli mi, anlaşılır mı" sorusunu hiçbiri ölçmüyor. Sonuç: iş "kabul kapısında yeşil, oyunda meh".
2. İkinci kaynak: karar sahipliği sırasında sessiz varsayılan. 07-03'te Erdem'in cevaplamadığı çatallar "önerilen" değerlerle uygulandı (R1); 10-17'de "bütün sorular ön onaylı" gece teslimi sabah 6 hedef MISS ile döndü (RAPOR_B); 10-12'de yardımcı yönetmen "kaydırma yok" kararı verdi ve Erdem "skandal olur" dedi. Gece ya da uzak teslimde sorular ön onaylı sayılınca geri dönüş sabaha kalıyor.
3. Revizyon en ucuz aşama: yazılı plan. Faz D (R6) ve Faz Q formülü (R13) yazılı aşamada reddedilip kod yazılmadan düzeldi. En pahalı aşama: oyun içi, çünkü ret kod, çeviri (TR/EN), kapı ve ekran karesi harcandıktan sonra geliyor (R1, R7, R8, R9). Maket aşaması orta; maket bile garanti vermiyor, çünkü ana menüde onaylı maketle uygulama farklı çıktı (R7).
4. Üçüncü kaynak: modüller arası etkileşim. Sprint erken kapanışı (G4) kâğıt zarını sessizce susturdu (#16). Hotfix (G1) ve Sesler (G6) bir hafta içinde Faz A tarafından silindi, çünkü yan yana tasarlanmadılar. Piyasa kilidi (C4) ile Piyasa PRD'si (I1) farklı oturumlarda yazıldı. Paralel oturumlar aynı ağaçta çalışıyor (kayıtlı ~4 farklı oturum); her biri kendi PRD'sini kapı kapı bitiriyor ama "bütün oyun" ölçümü yalnız bot koşusunda yapılıyor.
5. Yön kararları arka arkaya değişince alt işler çöpe gidiyor: tema (5 yön, 3 ay), ODA'nın 3B sanat zinciri (08-20 → 09-27 emekli), Rakip Dünyası v5 (5.812 satır, commit edilmedi). Bu alanlarda her kullanıcı yüzeyi bir sonraki yön değişikliğinde yeniden boyandı; yön kararı bir kez kilitlenmeden ekran işi yapıldı (Ekran F1-F9, Piyasa I1).
6. "Çok iş, az oyun" dengesi: 404 commit'in sayısı ve 20 PRD hacmi (23.871 satır belge) gerçek bir insan oyun oturumundan çok daha hızlı büyüyor. 14. haftanın ötesini oynayan insan olmadan 3. ve 4. tur kalibrasyon yapılıyor. R15'in kendi cümlesi: "Karar çeşitliliği alt sınır: insan şıkları dener."
7. Süreç kuralları sonuç ölçmüyor, tasarruf ediyor. 23 kuralın büyük çoğunluğu maliyet, çakışma ve geri alma hasarı üzerine (tek klasör, checkout yasağı, model seçimi, push öncesi smoke yok). Bunlar gerekli ama "kaç tur revize edildi?" ya da "Erdem ilk açışta ne dedi?" diye ölçen bir kural yok. Revizyon sayısını ölçen tek yer yardımcı yönetmen notları.
8. Kural çelişkisi: 10-11 "Opus yalnız zor, commit başına en çok 1 inceleme" ve 10-16 "Opus 5.5 her commit'ten önce kıdemli inceleme, düzeltme hakkı". İki hafta içinde iki farklı yön; ikisi de maliyet kaynaklı. Hangisinin geçerli olduğu iş akışı betiğinden okunuyor, tek kayıtta yazılı değil.
9. "Bir şeyi yapmak istiyorum" ile "ajan çıkarıyor, beğenmiyorum, 3 tur" arasındaki mesafe, Erdem'in ifadesiyle: görev yazısı (istenen, bugünkü akış, hedef akış, kararlar) kodlanmış ama "beğeni" yazılı değil. Elimizdeki en iyi çare kayıtlı olanlar: referans önce (R2/R3), tek çift (R9), adım tablosu (kural 8). Üçü de yeni, sonuçları henüz ölçülmedi.
10. Çıta: demo "polished, kapsamı küçük" olmalı. Bugünkü kapsam bunun tersine büyüyor: Rakip Dünyası, yazar ajanı, ofis mahallesi, Piyasa, 13 sektör, EA takımı (ertelendi), Ar-Ge ağacı. Yönetmen hükmü bu yönde kesme önerdi (EA takımı ertele, 2 sektör çıkar, kâğıt kesintisi) ama Erdem sektör kesmeyi reddetti (tekstil/medya kalsın). Kesme kararları var, uygulama ve ölçü yok.

## 8. Doğrulanamayanlar ve sınırlar
- Revizyon sayıları ve sınıf etiketleri benim yorumum; hafıza kayıtlarındaki bir ret her zaman tek bir commit'e bağlanamadı (R4, R5, R14 gibi yazılı dönüşler).
- Erdem'in oyunu açıp verdiği onay anı git'te yok; "kabul" süresi hafıza notlarından kaba tahmin.
- Eylül'ün ilk üç haftası (08-31 → 09-24) commit'siz; o aralıkta ne yapıldığı kaynaklardan çıkarılamadı.
- Smoke vaka sayısı kaynaklarda 345 (ISLER), 347 (tur 2 raporu), 351 (10-06 kaydı); aynı süit farklı günlerde sayıldı.
- Eski çalışma ağacı: `git status` snapshot'ında `M project.godot` ve izlenmeyen dosyalar var (başka oturumun işi); dokunulmadı.
- Searches=0: web ya da arama yok, yalnız dosya okuma ve git log.

## 9. Kaynak dosyalar (bu rapor için okunanlar)
- Hafıza: MEMORY.md, feedback-*.md (13), design-work-lessons, ui-redesign-menajer-2026-10-02, ui-lab-task-2026-09-30, rival-world-prd-2026-10-02, event-authoring-batch1, frank-v6-landing-pass, writer-agent-pilot-2026-10-08, event-layer-audit-2026-08-21, unicorn-assessment-2026-10-07, ekip-rev11-*, office-3d-task-2026-09-27, office-characters-task-2026-09-28, ana-menu-task-2026-10-11, render-assetlab-task-2026-10-09, weekly-time-model-task, saat-onarim1-task-2026-10-10, sprint-urun-phases-2026-10-16, faz-a-execution-2026-10-16, faz-q-execution-2026-10-18, next-session-review-2026-10-12, codirector-* ve lost-session-recovery.
- Repo: `docs/tasks/faz_cde/OYNANIS_HUKMU.md`, `ACIK_ISLER.md`, `ERDEM_CDQ_CEVAP.md`, `ERDEM_CD_YORUM.md`, `ERDEM_QCD_CEVAP.md`, `arastirma/R15_BIZIM_DONGU.md`; `docs/tasks/faz_ab/RAPOR_A.md`, `RAPOR_B.md`; `docs/tasks/TASK_PLAYTEST_DUZELTMELER_2026-10-12.md`; `docs/ACIK_ISLER/ISLER.md`, `ACIK_KARARLAR.md`; `CLAUDE.md`; `git log` (404 commit).
