# R15 · Bizim döngü bugün nasıl?
2026-10-18 · Kod: `main` @ `889b9b8` (Faz A ve Faz B bitti, push yok) · Girdi: `../QCD_GOREV_PAKETI.md`.
Kod değişmedi, commit yok, Godot koşmadı. Yalnız kod okuması ve var olan bot kayıtları. Sayılar bot sayılarıdır; insan oturumu yok.

## 0. Özet
1. **Saat.** 1 tik = 1 hafta = 22,5 sn (1×), 7,5 sn (3×). 104 hafta 1×'te 39 dk saf saat. Bot Series A imzasına 57. ile 71. haftada varıyor, yani 21 ile 27 dk saf saat. Demo hedefi 60 ile 90 dk. Aradaki farkı duraklı süre doldurmak zorunda. İnsan ölçümü yok.
2. **Etkileşim yoğunluğu.** B2B botta Traction'da haftada 8,2 etkileşim (4,0 görüşme + 4,2 karar). Hiç boş hafta yok. B2C botta Traction'da haftada 1,3 karar. Haftaların %65'inde hiç kart yok, %16'sında hiçbir şey yok.
3. **B2B kartlarının %66'sı üç müşteri kartı.** İstek 114, tutma 36, genişleme 14 (koşu başına). İstek kartının iki şıkkı bir tikte siliniyor.
4. **Satış görüşmesi çözülmüş.** Bot en kötü politikayla (ilk açık cevap, ilk karşı teklif) 3.828 oturumun %98'ini kazanıyor.
5. **Para baskısı yok.** Traction'ın %94'ünde, Series A'nın tamamında runway sonsuz. Kasa 103. haftada B2B'de 621 bin, B2C'de 1,75 milyon dolar (medyan).
6. **Sprint planı boş geçiyor.** Plan başına kapasitenin medyan %13 ile %15'i dolu. Koşu başına 65 ile 88 sprint var.
7. **Her kararın sonunda saat duruyor ve oyuncu elle başlatıyor.** B2B Traction'da haftada 1,7 durma.
8. **Series A formalite, ret öğretmiyor.** Kapı kartından imzaya 1 ile 5 hafta. 10 tohumda 9 imza, masada 0 zorlama. Onuncuda 4 ret sonrası 40 hafta bomboş.
9. **7 Ekim'in 4 alanı.** İlk saat kapandı (bir kalıntıyla). Orta oyun açık. Doruk açık. Vitrin kısmen (§5).
10. **Q, C, D.** D sprint boşluğunu kapatır. C telafi gelmezse orta oyunu daha da kolaylaştırır. Üçü de Series A'ya ve etkisiz yüzeylere dokunmuyor; C ve D dur-başla akışına kesinti ekler (§7).
11. **En zayıf 8 an** §8'de.

---

## 1. Yöntem ve sınırlar
### 1.1 Kaynaklar
| Kaynak | Yer | Ne |
|---|---|---|
| Kod | `project-unicorn/scripts`, `data/` | dosya:satır `889b9b8` |
| A logları | `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/5d19279e-6a73-4fd8-b7f8-dcb373bb1fc5/scratchpad/b6m/logs_A/` | 20 koşu: `full_run_{1..10}.log` (B2B, erp) ve `full_run_b2c_{1..10}.log` (B2C, note_tool). 104 hafta, tohum 1 ile 10. Ölçümü `B6m_OLCUM.md` §1 anlatır |
| VC logları | aynı kök, `scratchpad/b9/full_run_vc_cautious_s{1..10}.log` | B9 sonrası (`cb5f51c`), 10 tohum, B2B |
| Çözümleme betikleri | `C:/Users/erdem/AppData/Local/Temp/claude/C--Users-erdem-Desktop-Project-Unicorn/3ef3b847-b97e-4e0a-b9b4-c8ae6a99e869/scratchpad/` | `an.py`, `an3.py`, `parsed.json`, `cards.json` |
| Raporlar | `../../faz_ab/RAPOR_A.md`, `RAPOR_B.md`, `b_taslak/B6m_OLCUM.md` | A ve B ölçümleri |
| 7 Ekim raporu | `.../2a632836-.../scratchpad/REPORT_2026-10-07.md` | 4 kırık alan |

### 1.2 Bot kim
- Oyuncu sırasıyla: hafta açılınca en çok 4 görüşme, kartları cevaplar, sprint başlar, kadroyu merdivenle büyütür.
- Görüşmede **ilk açık cevabı** seçer, masada ilk karşı teklifi kabul eder. Kodun kendi sözü: "DELIBERATELY UNSKILLED" (`scripts/debug/run_probe.gd:1103-1146`).
- Sprintte yalnız lider önerisini uygular ve başlatır (`run_probe.gd:981,997`).
- B2B kadrosu 13 kişi: 1 PM, 3 yazılımcı, 1 testçi, 5 satış, 3 müşteri temsilcisi (`PROBE GATE` satırı, tasarımcı yok).
- Fiyat duruşunu ve ofis taşımayı hiç oynamaz. Araştırma, zam ve izin oynar. B2C fiyatı ve sunucu zaten oyuncuda değil (§6.2).

### 1.3 Bu yüzden
- Kart ve görüşme sayıları **üst sınır** olabilir: hesap sayısıyla orantılı (§4.3).
- Karar çeşitliliği **alt sınır**: insan şıkları dener.
- Tek cümle: bot "hızlı ve düşünmeyen" oyuncu. Yavaş ve düşünen oyuncuyu ölçmüyor.

### 1.4 Sınıflama
Kart kaydı `data/events/cards/**.json` (131 kart): `class`, seçenek sayısı, etki.
- **Not**: tek seçenek, etkisiz, `critical` değil, kâğıt değil. Saati tutmaz (`scripts/events/present/presenter.gd:132-137`, `scripts/events/core/engine.gd:478-512`).
- **Kâğıt**: `class: paper`. Masada `expires_weeks` bekler, saati tutmaz (`engine.gd:507-510`).
- **Karar**: `class: interrupt`, ikiden çok seçenek. Saati tutar (`scripts/main/main.gd:4059-4070`).
- **Tek düğmeli karar** ("modal1"): tek seçenek ama etkili ya da `critical`. Not olmadığı için saati tutar.

### 1.5 Bulamadıklarım
- İnsan oturumu (7 Ekim'den sonra kimse 14. haftanın ötesini oynamamış [kanıtsız]). Süre, okuma, tereddüt sayıları yok.
- B2C için Series A logu yok. `full_run_b2c_vc_cautious` preseti var (`run_probe.gd:102`), Faz B sonrası koşusu bulunmadı.
- B2C Series A için eski loglar var (`.../C--Users-erdem-Desktop-project-steam/.../p4_baseline/full_run_b2c_vc_cautious_s*.log`) ama Faz A ve B'den önceki koddan; bugünün dönemi için geçersiz.
- Kurumsal madde, yenileme bantları ve sunucu kademesi kodlanmadı; yalnız belge sayıları var.
- Ar-Ge kullanım ölçümü yok.

---

## 2. Haftanın mekaniği (her evrede aynı)
### 2.1 Saat
| Olgu | Değer | Kanıt |
|---|---|---|
| Hız merdiveni | duraklat, 1×, 2×, 3× = 2,5 / 1,25 / 0,83 sn her oyun saati | `scripts/systems/time_model.gd:9` |
| Hafta | 08:00'de başlar, varsayılan mesai 09:00 ile 17:00 | `time_model.gd:10,43-45` |
| 1 hafta | 1×'te 22,5 sn, 3×'te 7,5 sn | `time_model.gd:43-45` |
| Gece | mesai bitip ofis boşalınca tek toplu adım; kart yalnız acil durumsa o saatte durur | `scripts/autoload/time_manager.gd:100-124,183-190` |
| Saati kim başlatır | yalnız oyuncu. Tutuş kalkınca hiçbir şey kendiliğinden sürmez | `time_manager.gd:358-361` |
| Odak kaybı | duraklatır (ayar) | `time_manager.gd:342-345` |

### 2.2 Bildirim akışı: kim saati tutar
| Kanal | Saati tutar mı | Kanıt |
|---|---|---|
| Karar kartı | **Evet.** Açık paneller kapanır, Olaylar kartın üstünde açılır, öbür pencereler salt okunur | `main.gd:4059-4070,4151-4153` |
| Tek düğmeli karar | **Evet** | `presenter.gd:132-137` |
| Not | Hayır, gelen kutusuna düşer | `engine.gd:495-505` |
| Kâğıt | Hayır. Son haftası ofis yığınında ve TopBar "Sıradaki"nde | `engine.gd:507-510`, `scripts/ui/components/top_bar.gd:268-275` |
| Sprint planı | **Evet** (`sprint_plan`) | `scripts/systems/sprint_system.gd:23,581-589,1604-1616` |
| Sürüm notu | **Evet**, Ürün sayfası açıkken | `scripts/tabs/product_tab.gd:153,288-292` |
| MVP yayın kapısı | **Evet** | `sprint_system.gd:581-585` |
| Acil durum (gece) | **Evet**, gece adımı o saatte durur | `CLAUDE.md` §6, `time_manager.gd:34` |
| Satış ya da VC oturumu | Oturum boyunca dünya durur; kapanınca saat 2 saat ilerler | `scripts/systems/sales_constants.gd:66`, `time_manager.gd:173-178` |
| Mail, toast, haber bandı | Hayır | |

Kuyruk sırası: terminal, süresi dolan, kritik, karar, kâğıt, bilgi (`scripts/events/core/queue.gd:23`).
Teslim saati: mail ve kâğıt gece 00:00'da düşmez, mesai penceresinde çekilmiş saatte gelir (B1, `05966f3`).

### 2.3 Ekranda her zaman
- Merkez: 3B ofis (`scenes/office/OfficeView.tscn`).
- Sol ray: 8 sekme açık (Ürün, Satış, Ekip, Finans, Piyasa, Kişisel, Ar-Ge, Olaylar), Pazarlama EA kilitli (`scripts/theme/ui_tokens.gd:294-304`).
- TopBar: saat, hız, kasa, MRR, runway, marka ve "Sıradaki" yuvası (`top_bar.gd:251-290`).
- Ofis yığını (en çok 4 satır), toast, alt haber bandı.

---

## 3. Evre evre
Sayılar bot, 10 koşu ortalaması. "Karar" = karar kartı + tek düğmeli karar + kâğıt + sprint başlatma + işe alım/arama + öbür eylem (araştırma, zam, izin, söz, yayın). "Etkileşim" = karar + görüşme.

### 3.1 Bootstrap (hafta 1 ile 9)
**Tik.** 9 hafta. Traction'a geçiş B2B'de 7 koşuda 10., 2 koşuda 11., 1 koşuda 12. haftada; B2C'de 10 koşuda da 10. haftada. 1×'te 3,4 dk saf saat.

**Ekranda ne var.**
1. Onboarding 3 adım: karakter, köken ve beceri ve huy, şirket (`scripts/onboarding/onboarding_flow.gd:15-18`).
2. Duraklı ofis. Frank'in intro maili Olaylar'da; düğme Ürün'ün tür seçicisini açar (`scripts/tabs/events/mail_pane.gd:141`). Ofis yığınında "Boşluk" ipucu (`scripts/ui/office/office_notice_stack.gd:125`).
3. TopBar "Sıradaki" Frank'in çek listesini okur: tür, ilk sprint, yayın, ilk ödeyen, MRR $2.500 (`scripts/systems/cheque_read.gd:15-55`).
4. Satış: pazar v1.0 yayınlanana dek kapalı (`scripts/systems/sales_ledger.gd:311-313`). Ar-Ge kilitli ağaçla açılır. Finans ve Piyasa salt okunur.

**Hangi kararı veriyor.**
| Karar | Kaç kez | Not |
|---|---|---|
| Ürün türü ve adı | 1 | B2C'de 2 tür, B2B'de 1 (`scripts/systems/product_catalog.gd:55-60`) |
| Sprint planı: öneriyi uygula, başlat | 4 ile 5 | MVP: Çekirdek'in 5 hattından 3'ünün K1'i; kapasite %75 dolu |
| Yayınla ya da bir sprint daha | 1 | `sprint_system.gd:1419-1527` |
| Beat kartları (Birikim, Çalışan parçalar) | 2 | not; saati tutmaz |
| `founder.friends_test` | 1 | tek gerçek şık |
| Satış görüşmesi | hafta 8'den | pazar açılınca |

**Bot zaman çizelgesi** (`full_run_7.log`): hf1 tür + sprint 1; hf3 sprint 2; hf5 sprint 3; hf7 yayın (v1.0); hf8 Frank intro, 4 görüşme; hf9 ilk imza; hf10 Traction kapısı. Frank'in çeki hf12 ile 13, seed hf18 ile 21 (B2B). B2C'de çek hf22 ile 24, seed hf50 ile 55.

**Bekleme ve izleme.** İlk 7 hafta pazar kapalı. Karar 0,98/hf. Haftaların %30'unda karar yok (görüşme dahil %27'sinde hiçbir şey yok). Bu haftalarda oyuncu 22 sn ofisi izliyor. Toplam yaklaşık 1 ile 1,5 dk (9 haftanın 3'ü, 1×).

**Kesinti.** Karar kartı yok, not 0,23/hf, kâğıt 0,12/hf, tek düğmeli karar 0,11/hf. Durma sayısı (karar + tek düğmeli + sprint başlatma) 0,65/hf.

### 3.2 Traction (hafta 10 ile 60 B2B, 10 ile 78 B2C)
**Tik.** B2B 51, B2C 69 hafta. 1×'te 19 ve 26 dk saf saat.

**Ekranda ne var.**
- **B2B Satış**: lead boru hattı (haftada 3 taban + temsilci başına 2, en çok 14 lead, `sales_constants.gd:30-38`), satış masası, hesap portföyü (bot 103. haftada 341 hesap). Fiyat duruşu 3 seçenek (%85 / %100 / %115, `sales_constants.gd:124-133`).
- **B2C Satış**: kullanıcı, ödeyen, dönüşüm, fiyat, haftalık kullanıcı sütunları. **Salt okunur** (`scripts/tabs/sales_tab.gd:259-289`).
- **Ürün**: Sprint / Çeyrek; hat paneli açık hata sayar; Destek kartı (`scripts/tabs/product_tab.gd`).
- **Ekip**: Kadro, Görevler, Atlas (işe alım), Mesai, Eğitim (`scripts/tabs/hr_tab.gd:136-144`).
- **Finans**: kasa eğrisi, gider dağılımı, hedef kutusu. Tek düğme: Frank'in notunu ertele (`scripts/tabs/finance/finance_ozet_view.gd:165,492`).
- TopBar "Sıradaki": çek 12. ile 13. haftada, seed 18. ile 21. haftada kapanınca **satır kalmıyor**; "Mesai bitimine N saat" yazıyor (`cheque_read.gd:15-23`). Seed ile kapı arasındaki yaklaşık 40 haftada adlı hedef yalnız Finans'ın hedef kutusunda ve Frank'in 4 yaklaşma kartında.

**Hangi kararı veriyor** (haftada, B2B / B2C):
| | B2B | B2C |
|---|---|---|
| Görüşme | 3,98 | 0 |
| Karar kartı | 0,82 | 0,11 |
| Tek düğmeli karar | 0,16 | 0,08 |
| Kâğıt | 1,55 | 0,20 |
| Sprint başlatma | 0,74 | 0,61 |
| İşe alım ve arama | 0,56 | 0,14 |
| Öbür (araştırma, zam, izin, söz) | 0,41 | 0,11 |
| **Karar toplamı** | **4,25** | **1,26** |
| **Etkileşim (görüşme dahil)** | **8,22** | **1,26** |

**Bekleme ve izleme.**
- B2B: etkileşimsiz hafta %0. Saati görüşme sürüyor: 4 oturum x 2 saat = 8 saat, hafta 9 saat (08:00 ile 17:00) (`sales_constants.gd:66,68`). Her oturum kurucunun haftalık işinden 2/40 götürür, 4 oturum %20 (`time_manager.gd:223-228`).
- B2C: karar yok ya da yalnız sprint var. Haftaların **%65'inde hiç kart yok**, %16'sında hiçbir etkileşim yok. Kartsız en uzun seri koşu başına 6 ile 11 hafta (10 koşunun medyanı 8).
- Kasa sorunu yok; izlenen ekran: büyüyen sayılar.

**Kesinti.** B2B: durma (karar + tek düğmeli + sprint) **1,72/hf**. B2C 0,81/hf. B2B'de 0,50 not/hf (teşekkür mailleri).

**Orta nokta (hf52, medyan).** B2B: MRR 102 bin, kasa 224 bin. B2C: MRR 20 bin, kasa 87 bin.

### 3.3 Series A Hunt (B2B hafta 60 ile imza; B2C hafta 78'den)
**Tik.** Kapı kartından imzaya 1 ile 5 hafta (cautious bot, 9/10 imza; kapı → imza: 5, 5, 5, 1, 5, 3, 1, 5, 1 hafta; imza günleri 57 ile 71). 1×'te 0,4 ile 1,9 dk saf saat.

**Kapı.** MRR yaklaşık 120 bin (`PROBE SIGNAL ... appetite=warming->open mrr=120855`, hf58). Kapıda Frank kartı: "Hazırız, geçelim" (`funding.gate_series_a`).

**Ekranda.** Finans > Yatırım (`scripts/tabs/hunt_tab.gd`): 4 fon (Anchor, Nexus, Bosphorus, Meridian), her biri için toplantı al (1 hafta sonra), ertele, iptal et (B9'dan beri hazırlık yok, `cb5f51c`).

**Kararlar.**
1. Hangi fon, hangi sırayla.
2. Oturum: 4 perde (oku, anlatı, sorgu duruşu, masayı zorla) (`b1_read ... b4_close` `PROBE VC_MEET` satırı).
3. Teklif gelirse masa: sabır 2, zorlama kolu, imza (`TermSheetTableSystem`).

**Bot ölçümü** (`scratchpad/b9`, 10 tohum):
| | |
|---|---|
| İmza | 9/10 |
| Oturum / imzaya kadar ret | 1 ile 3 oturum, 0 ile 2 ret |
| Masada zorlama | 0 (hepsinde `pushes=0`) |
| Masa girişi | 9 masa; ikna 70 ile 93, eşik 35 ile 55 (`thr`), değerleme $14 ile 24 milyon |
| Fon farkı (24 oturum) | Bosphorus 6 oturumun 5'inde teklif verdi, Anchor 10'da 3, Nexus 7'de 1, Meridian 1'de 0. Bot sırası sabit; ama "hangi fon" şimdiden tek doğru cevaba yakın |
| Marka maliyeti | ret başına −3 civarı (`brand=67→64`) |
| İmzasız koşu | tohum 6: 4 ret, 64. günde `road_closed`; 104. haftaya dek 40 hafta |

**Ret sonrası.** Tohum 6'da 62. günden sonra 40 haftada kartlar: 48 istek, 8 genişleme, 4 kesinti, 3 rakip fonu. Oyunun söylediği: yok. Bitiş `running_on_fumes` 104'te, kârlı şirkete rağmen (§5, K5, K6).

**B2C.** B2C bot Series A kapısına hf75 ile 84'te geliyor. Oturum logu yok [bulamadım].

---

## 4. Bot ölçümü
### 4.1 Olay ve kâğıt sıklığı (B6m, 20 koşu)
| Ölçü | Değer | Kaynak |
|---|---|---|
| Acil durum | 84 olay / 20 koşu (B2B 4,4, B2C 4,0). Min aralık 4 hf. 4 ile 14 hedefine 13/20 uyuyor | `B6m_OLCUM.md` §2 |
| Kâğıt (sprint ortası) | 147 / 1.506 sprint (%9,8); koşu başına 7,35. Sprint başına ≤1, kâğıtsız sprint %90,2 | B6m §5.1 |
| Gelen kâğıt kartı | 19 / 46 | B6m §4.2 |
| Hiç gelmeyen | tasarımcı 8/8, PM 6/7, testçi 6/9, `sprint_late`, `promise_due`, `regression` | B6m §4.1, §4.2 |
| Çok kesintili sprint | 16/1.506 (%1,1), hepsi izinli bileşim | B6m §5.2 |
| 1 tikte kapanan sprint | 956 / 1.506 | B6m §5.1 |

### 4.2 Kart sayıları (bu çalışma, 20 koşu, koşu başına)
| | B2B | B2C |
|---|---|---|
| Toplam kart | 248,7 | 44,9 |
| Not | 29,8 | 2,2 |
| Tek düğmeli karar | 17,8 | 7,7 |
| Karar (çok şıklı) | 51,9 | 14,1 |
| Kâğıt | 149,2 | 20,9 |
| Sprint | 81 ile 88 | 65 ile 69 |
| Görüşme | 383 (kazanılan 374) | 0 |
| İmza | 350 | 3 |
| İşe alım | 21 | 5 |

**B2B kart payı** (koşu başına): `customer.request_feature` 113,8; `customer.retention` 36,3; `customer.release_thanks` 27,6 (not); `customer.expansion` 13,8; `team.resignation` 9,2; `rival.price_cut` 4,3; `product.incident_outage_b2b` 4,2; `rival.funding_round` 3,7; `world.trade_fair` 3,6.
İlk üç müşteri kartı (istek + tutma + genişleme) = 164 / 249 = %66.

### 4.3 Ölçek notu
İstek kartı hesap sayısıyla doğrusal: ortalama 152 hesapta 113,8 kart = **0,0073 kart / hesap-hafta** (hesap başına yılda 0,38). 10, 25, 50 hesapta haftada 0,07 / 0,18 / 0,36 kart. Botun 103. haftadaki yaklaşık 340 hesabı haftada 4 oturum ve %98 kazanımdan geliyor.

### 4.4 Haftalık karar tablosu
| | Bootstrap | Traction | Series A |
|---|---|---|---|
| **B2B** karar | 0,98 | 4,25 | 3,78 |
| B2B görüşme | 1,02 | 3,98 | 4,00 |
| B2B etkileşim | 2,00 | 8,22 | 7,78 |
| B2B kartsız hafta | %60 | %3 | %12 |
| B2B etkileşimsiz hafta | %27 | %0 | %0 |
| B2B durma / hf | 0,65 | 1,72 | 1,41 |
| **B2C** karar | 1,23 | 1,26 | 1,48 |
| B2C kartsız hafta | %52 | %65 | %53 |
| B2C etkileşimsiz hafta | %33 | %16 | %2 |
| B2C durma / hf | 0,67 | 0,81 | 1,07 |
Hafta sayıları: B2B 94 / 512 / 424, B2C 90 / 692 / 248.

### 4.5 Sprint doluluğu
Plan başlarken `used / capacity` (`PROBE PLAY ... sprint N start ... used= capacity=`), her sprint:
| | Sprint | Doluluk ortalama | Doluluk medyan | Plan başına kart |
|---|---|---|---|---|
| B2B Bootstrap | 51 | %75 | %75 | 1,00 |
| B2B Traction | 381 | %38 | **%15** | 2,95 |
| B2B Series A | 412 | %15 | **%13** | 2,75 |
| B2C Bootstrap | 50 | %90 | %75 | 1,00 |
| B2C Traction | 423 | %64 | %67 | 2,97 |
| B2C Series A | 193 | %34 | %26 | 4,52 |
Özellik ya da talep kartı içeren son sprint: B2B'de 43. ile 89. gün (medyan 81), B2C'de 98. ile 103. gün. Yani kart tükenmiyor; plana giren kart küçük.
Kart eforu K1 3, K2 5, K3 8 puan (`data/product/sprint.json` `effort`); kişi başı 2 puan/hf. Plana giren küçük düzeltme kartları (2 puan) ve tek özellik kartı kapasiteyi doldurmuyor. Sprint kartlar bitince erken kapanıyor, her tikte yeni plan geliyor. Düşük doluluğun kök nedeni (açık aday azlığı mı, kilitli kapı mı) ölçülmedi [kanıtsız]; D'nin hedefi bu boşluğu adlandırıyor (§7.3).

### 4.6 Ekonomi
| | B2B | B2C |
|---|---|---|
| Sonlu runway haftası: Bootstrap | 94/94 | 90/90 |
| Traction | **30/512 (%5,9)** | 142/692 (%20,5) |
| Series A | **0/424** | 0/248 |
| Kasa medyan hf14 / hf20 / hf30 / hf52 / hf80 / hf103 | 31K / 146K / 150K / 224K / 377K / 621K | 6K / 5K / 28K / 87K / 365K / 1,75M |
| MRR medyan hf30 / hf52 / hf80 / hf103 | 52K / 102K / 163K / 214K | 4K / 20K / 155K / 726K |
| Bitiş | 20/20 `running_on_fumes` (104. hf) | aynı |
Min kasa seed öncesi: B2B yaklaşık 5.800 ile 6.400 dolar (`min_cash_pre_seed`). İlk 9 hafta gerçekten sıkışık; sonrası değil.

### 4.7 Acil durum bedeli
Kart bedelleri sabit dolar: fuar −$30.000, kampanya −$18.000, uygulama yerleşimi −$25.000 (`data/events/cards/world/trade_fair.json`, `rival/funding_round.json`, `world/app_placement.json`). Kasa 150 bin iken bunlar kasanın %12 ile %20'si, 621 bin iken %3 ile %5'i. Karşılığı marka −2 ile −3. Bot 10 B2B koşuda fuarda 27 kez "Standı kirala", 9 kez "Katılma" dedi.

---

## 5. 7 Ekim'in 4 kırık alanı bugün
Rapor: `REPORT_2026-10-07.md` §0 ve §2 (temel `b131255`; 167 commit sonra). Durum: ✅ kapandı, ⚠️ kısmen, ❌ açık.

### 5.1 Özet
| # | Alan | Bugün | Neden |
|---|---|---|---|
| 1 | İlk saat boş | ✅ (bir kalıntıyla) | Rehberlik, yer tutucu metin, tek tuşlu beat, planlama tutuşu kapandı. Kalıntı: ilk 7 hafta ince, huy seçimi etkisiz (§8.8) |
| 2 | Orta oyun baskısız | ❌ | Sonlu runway Traction'da %5,9, Series A'da %0. Kasa 621 bin. Faz A ve B ekonomiyi sertleştirmedi |
| 3 | Doruk formalite, kayıp öğretmiyor | ❌ | 9/10 imza, 0 zorlama. K5 ve K6 aynı. Kepenk uyarısının zamanı kapandı |
| 4 | Vitrin bitmemiş | ⚠️ | Menü, Devam, çıkış onayı, export, grafik ön ayarı, ölçek var. Ses, gazete sanatı, Steam adresi yok |

### 5.2 İlk saat (alan 1)
| Bulgu | Durum | Kanıt |
|---|---|---|
| K1 saat duraklı, hedef yok | ✅ | `mail_pane.gd:141` (intro → Ürün), `office_notice_stack.gd:125` (Boşluk ipucu), `cheque_read.gd:15-55` (5 adım), `top_bar.gd:251-290` (Sıradaki). Commit'ler: Açılış C1 `a9d88f8`, C4 `7a42c0b`, C8 `e1e183b` (10 ile 11 Ekim) |
| K2 satış sayfası kilidi | ✅ | `sales_tab.gd:82,101-104` saatlik yeniden çizer |
| K3 55 "PH:" satırı | ✅ | `grep -c "PH:" localization/strings.csv` = 0; O5 `43e0a28` |
| K7 planlama haftasında saat akıyor | ✅ | `sprint_system.gd:23,581-589,1604-1616`; Sprint 7 `173b56c`: plan saati tutar |
| K8 tek seçenekli beat saati tutuyor | ⚠️ | Not oldu (`presenter.gd:132-137`, C2 `3a5db7b`). Ama **etkili tek seçenek** (istifa 9,2/koşu, Frank'in 7 kartı) hâlâ saati tutuyor (§8.4) |
| K4 `frank_32.png` yok | ✅ | `assets/art/portraits/frank_32.png` var |
| Köken adları TR, kapalı İleri gerekçesi | ✅ | Açılış C5 `7ccc0d9` |
| Huylar etkisiz | ❌ | `scripts/systems/founder_constants.gd:41-43` "RESERVED: ... consumed by no system" |

### 5.3 Orta oyun (alan 2)
| Bulgu | Durum | Kanıt |
|---|---|---|
| Runway 12. ile 16. haftadan sonra sonsuz | ❌ | 7 Ekim: Traction 57/62 (%92), Series A 34/34 sonsuz. Bugün 482/512 (%94) ve 424/424 (§4.6). Aynı |
| Kasa harcanacak yer yok | ❌ | Kasa 621 bin (B2B), 1,75 milyon (B2C); kart bedelleri kasanın %3 ile %5'i (§4.7). 7 Ekim: 80 haftada 126K → 411K. Bugün 80. haftada 377K (medyan), 103. haftada 621K. Aynı büyüklük |
| 178 kart ateşlemesinin 51'i tek tuşlu istifa | ⚠️ | 9,2/koşu (13 kişilik kadro). Moral 8 saatte aşınmıyor, G1 `88aedb6`. Hâlâ tek düğme ve saati tutuyor |
| Retention + istifa okunanların %45'i | ⚠️ | Üç müşteri kartı (istek, tutma, genişleme) kartların %66'sı; istifa %3,7 |
| 3 kısa ark, Frank tepkisi, rakip/pazar şoku | ❌ | `data/events/arcs/`: yalnız `soft_cap_stretch` (gerçek ark) ve 2 fikstür. Rakip kartı 2 (`rival.price_cut` 4,3, `rival.funding_round` 3,7 / koşu). Kart dosyası 69'dan 131'e çıktı (`git ls-tree`), ark sayısı artmadı |
| Series A barı 120K, oda 60K'da doyuyor | ❌ | `PROBE SIGNAL day=58 appetite=->open mrr=120855`. Sabit aynı |
| Faz B'nin etkisi | ⚠️ | Acil durum, kâğıt, söz olayı geldi: 4,2 + 7,4 kesinti/koşu (B6m). Bedel kasayı oynatmıyor (krediler aylık ücretin %10 ile %25'i) |

### 5.4 Doruk (alan 3)
| Bulgu | Durum | Kanıt |
|---|---|---|
| K5 ret `faced_series_a` yazmıyor | ❌ | `_reject()` yalnız `vc_rejections += 1` ve marka/moral (`scripts/systems/vc_pitch_system.gd:535-548`). `mark_faced_series_a` yalnız `walk_table`'dan (`vc_pitch_system.gd:608-627`, tek çağıran). Kârlı bootstrap sonu `faced_ok` ister (`endings_system.gd:216`) |
| K6 "Üçüncüde yol biter" yalan | ❌ | `strings.csv:831`; `endings_system.gd:155-175`: MRR ≥ 2.000 ve kasa > 0 iken kaskad hiç ateşlenmez (`PIVOT_MRR_MIN` :31) |
| K9 kepenk kartı bir tik sonra, ikincisi hiç | ✅ | `endings_system.gd:121` (`EventGate.request(SHUTTER_CARD)` sayaç kurulurken), `shutter_warning.json` `latch.cooldown_weeks: 0`. Onarım 0 A3 `1a6d72e` (7 Ekim) |
| Doruk formalite | ❌ | §3.3: 9/10 imza, 0 zorlama, 9 masada ikna 70 ile 93 karşı eşik 35 ile 55 |
| Oda şirketi okusun, 2 ile 3 turlu push-or-fold | ❌ | Yok; hazırlık kaldırıldı (B9) ama yerine bir şey gelmedi (telafi yok, Karar 18) |
| Kepenkte verb | ❌ | `endings_system.gd` farkı (`git diff b131255 HEAD`) yalnız `SHUTTER_CARD` isteği; kepenke verb eklenmedi |
| Kayıp gazetesi otopsisi, TEKRAR DENE | ❌ | `scripts/modals/ending_scene.gd` 7 Ekim'den beri değişmedi (`git diff b131255 HEAD --stat` boş); `endings_copy.gd` farkı yalnız B2B sayısı (A8) |
| Son gazetede B2B sayısı | ✅ | A8 `52db813` |

### 5.5 Vitrin (alan 4)
| Bulgu | Durum | Kanıt |
|---|---|---|
| Ana menü, Devam yok | ✅ | AM3 `97bb57f`, `scripts/menu/continue_card.gd`, koşu başına yuvalar AM5 |
| Pencere X'i sormuyor | ✅ | AM7 `7598bc8` |
| Export preset yok | ✅ | `export_presets.cfg` 3 preset (Demo, EA, Full), AM1a `44f74d9` |
| `steam_appid` | ❌ | Dosya yok (`find . -iname steam_appid*` boş) |
| Ses yok (tek MP3, SFX sıfır) | ❌ | `assets/audio/` yalnız `Döngü Modu.mp3`; `scripts/autoload/audio_manager.gd:41` "The SFX bus has no players yet" |
| Gazete sanatı "GÖRSEL YAKINDA" | ❌ | `strings.csv:162`, `ending_scene.gd:171`, `assets/endings/README.md` yalnız |
| Ölü WISHLIST (`STEAM_PAGE_URL`) | ❌ | `scripts/modals/ending_scene.gd:34` `""` |
| 720p/Deck'te 8 px yazı | ⚠️ | Arayüz ölçeği 0,75 ile 1,25 (`scripts/systems/display_settings.gd:51`); `SIZE_MICRO` 9 duruyor |
| Grafik ayarı | ✅ | `0fe77fc` (4 ön ayar) |
| Ticker EN'de Türkçe | ✅ | `news_feed_system.gd:26-29,235` satır `{key,args}` saklıyor |
| Tam koşu kapısı | ✅ | `tools/run_gate.sh`, 3 koşu |

---

## 6. Karar envanteri
S = gerçek ödünleşim. T = tek doğru cevap ya da çözülmüş. B = boş tık ya da etkisiz yüzey. ? = ölçülmedi.

### 6.1 Kuruluş (bir kez)
| # | Karar | Yer | Etki | Sınıf |
|---|---|---|---|---|
| 1 | Portre, ad | `character_step` | kozmetik | B |
| 2 | Köken (3'ten 1) | `origin_traits_step`; `founder_constants.gd:74-76` | `heir` ve `corporate_refugee` kilitli; tek açık seçenek | B |
| 3 | Beceri dağıtımı (5 beceri) | `origin_traits_step` | satış zarı, sprint puanı, VC zarı okur [kanıt: `docs/tasks/PRD_ACILIS.md` §4 beceri tablosu, her satır koddaki etkiyle kanıtlı] | S |
| 4 | Huy (1 ile 2 artı, ≤1 eksi) | `origin_traits_step` | **hiçbir sistem okumuyor** (`founder_constants.gd:41-43`) | B |
| 5 | Şirket adı, logo | `company_step` | kozmetik | B |
| 6 | Zorluk | `founder_constants.gd:59,188` | yalnız başlangıç nakdi ×1,5 / 1,0 / 0,6; Zor 1 bitmiş koşudan sonra açılır | S (tek sayı) |
| 7 | Ürün türü (B2C 2, B2B 1) | `product_catalog.gd:55-60` | pazar iki ayrı oyun | S (pazar) / T (B2B içinde) |

### 6.2 Ürün ve sprint
| # | Karar | Yer | Sıklık (bot) | Etki | Sınıf |
|---|---|---|---|---|---|
| 8 | Öneriyi uygula + başlat | `sprint_system.gd:128-136,332` | 65 ile 88 / koşu | doluluk medyan %13 ile %15; liderin önerisi bot politikası | T |
| 9 | Kart ekle (+), ertele (→), çıkar | `product_tab.gd:245-275` | bot yapmıyor | aday kıt (§4.5) | S ama kıt |
| 10 | Sprint 1 ya da 2 hafta | `sprint_system.gd:324` | 1 kez | kâğıt şansı 0,3 / 0,5 (`sprint.json` `decision.sprint_chance`), 1 haftalıkta `team.demo_day` kartı (`sprint_system.gd:146-147`) | zayıf S |
| 11 | PM'e devret, çeyrek hedefi | `product_tab.gd:256-267` | bot yapmıyor | plan ekranını kaldırır (`sprint_system.gd:592-594`) | S (kolaylık) |
| 12 | Yayınla / bir sprint daha | MVP kapısı | 1 | küçük | S |
| 13 | Sprint kâğıdı (40 kâğıt) | `sprint_system.gd:1213-1255` | 7,4 / koşu | bedeli seçenekte | S ama 27/46 kart hiç gelmedi |
| 14 | Acil durum (5 tür) | `incident_system.gd` | 4,2 / koşu | ekip/kendin/sabah/sprinti durdur | S |
| 15 | Söz olayı | `sprint_system.gd:964-1006` | **0** / koşu | testi kısalt, mesai, ileri al, bırak | S ama gelmiyor |
| 16 | Hata düzeltme kartı | sprint planı | bot: lider | hat başına | S küçük |
| 17 | **B2C fiyatı** | yok | | "Ücretli plan" kartı fiyatı `optimal`a kurar (`sprint_bridges.gd:136-139`); sayfa salt okunur | **yok** |
| 18 | **Sunucu kapasite / sağlayıcı** | yok | | MVP'de bulut, sürümde otomatik büyür (`sprint_bridges.gd:69-73,130-134`); oyuncu arayüzü yok | **yok** |

### 6.3 Satış (B2B)
| # | Karar | Yer | Sıklık | Etki | Sınıf |
|---|---|---|---|---|---|
| 19 | Hangi lead'le görüşme (≤4/hf) | `sales_ledger.gd:311-329`, `sales_constants.gd:68` | 3,98 / hf | haftanın saati | T |
| 20 | Görüşme cevapları (≤6 prob) | `sales_meeting_system.gd`, `sales_constants.gd:99` | 383 oturum | ilk açık cevap %98 kazanıyor | T [insan ölçümü yok] |
| 21 | Fiyat duruşu (3) | `sales_ledger.gd:124-133`, `sales_constants.gd:128-132` | oyuncu | masa sinyali ±, fiyat %85 / 100 / 115 | S |
| 22 | Pazarlık: teklif / kabul / terk | `negotiation_system.gd` | bot ilk karşı teklifi kabul eder | | ? |
| 23 | Lead'i temsilciye ver, ayır | `sales_tab.gd:404-411` | | kurucu saati ile temsilci | S |
| 24 | Müşteri sorumlusu seç | `sales_tab.gd:643-645` | | memnuniyet aşınması | S küçük |
| 25 | **İstek kartı**: söz ver / listede / şimdi değil | `customer/request_feature.json` | **1,1 / hf** | "listede" +3, "şimdi değil" −4; ikisi de tikte siliniyor (`b2b_sales_system.gd:48-76,96-130`) | "söz ver" S; öbür ikisi B |
| 26 | Tutma kartı: söz / oyala / indirim / bırak | `customer/retention.json` | 0,35 / hf | kapasite, itibar −1, indirim | S |
| 27 | Genişleme: ekle / şimdi değil | `customer/expansion.json`; `b2b_sales_system.gd:373-402` | 0,13 / hf | "şimdi değil" bedelsiz kayıp; bot 138/138 "ekle" | T |
| 28 | Söz (promise) | `promise_registry` | ≈ 42 söz / koşu (B6m §0, `RAPOR_B.md` §1 madde 3) | sprint kapasitesi, itibar | S |

### 6.4 Ekip
| # | Karar | Yer | Sıklık | Etki | Sınıf |
|---|---|---|---|---|---|
| 29 | İşe alım: rol, seviye, dosya seç (aynı anda 1 arama) | `hr_search_system.gd:61-64,96-145` | 21 / koşu | maaş, runway | S ama kasa sınırsız (§4.6) |
| 30 | Zam, terfi, izin, eğitim, kovma | `hr_actions.gd` | zam 13, izin 8,6 / koşu | moral, verim | S küçük |
| 31 | Mesai saatleri | `work_hours_modal.gd`, `hr_tab.gd:136` | | verim eğrisi, ek mesai gideri | S |
| 32 | Görev matrisi | `hr_assignments.gd` | | sprint puanı | S |
| 33 | **İstifa duyurusu** | `team/resignation.json` | 9,2 / koşu | tek düğme "Anlaşıldı" | **B** |

### 6.5 Ar-Ge, para, ofis, dünya
| # | Karar | Yer | Etki | Sınıf |
|---|---|---|---|---|
| 34 | Araştırma ata (20 düğüm) | `rnd_tab.gd`; bot 12,7 / koşu | **4 düğümün okuyucusu yok**: `cicd`, `accessibility`, `semantic_index`, `analytics_engine` yalnız `research_seam.gd:29,35,40,48` sınıf tablosunda geçiyor | S / B |
| 35 | Finans | `finance_ozet_view.gd` | salt okunur; tek düğme Frank notunu ertele | yok |
| 36 | **Ofisi taşı** | `office_system.gd:48-55` | bedelsiz, "no money moves"; masa sayısı yalnız gösterim (`office_map_card.gd:63`) | **B** |
| 37 | Dünya kartları (fuar −30K, kampanya −18K, yerleşim −25K) | `world/*.json`, `rival/*.json` | kasa varken seçenek aynı | T |
| 38 | Rakip: fiyatı eşitle / söz / dur | `rival/price_cut.json` | bot hep eşitle (43/43) | S |

### 6.6 Fonlama
| # | Karar | Yer | Etki | Sınıf |
|---|---|---|---|---|
| 39 | Frank'in çeki kabul / ret | `funding/frank_cheque.json` | "Ret" kilitli (`requires`) | T |
| 40 | Seed: fon, pitch, masa | `hunt_tab.gd:175-193` | | S |
| 41 | Series A: fon seçimi, 4 perde, masa, imza | `hunt_tab.gd:352-454`, `vc_pitch_system.gd` | 9/10 imza | S ama formalite |
| 42 | Ret sonrası | | **hiçbir şey** | yok |

### 6.7 Sayım
42 satır:
- **Gerçek ödünleşim (S): 22.** #3, 6, 9, 10, 11, 12, 13, 14, 15, 16, 21, 23, 24, 26, 28, 29, 30, 31, 32, 38, 40, 41. İçinde zayıf ya da kıt olanlar var: #9 (aday kıt), #10 (zayıf), #13 ve #15 (içeriğin çoğu hiç gelmiyor), #29 (kasa sınırsız).
- **Tek cevap ya da çözülmüş (T): 6.** #8, 19, 20, 27, 37, 39.
- **Boş tık ya da etkisiz (B): 6.** #1, 2, 4, 5, 33, 36.
- **Karışık: 3.** #7 (pazar S, B2B içi T), #25 (söz ver S, öbür iki şık B), #34 (16 düğüm S, 4 düğüm B).
- **Oyuncuda olmayan: 4.** #17 B2C fiyatı, #18 sunucu, #35 Finans, #42 ret sonrası.
- **Ölçülmedi: 1.** #22 pazarlık.
- Yani 42 yüzeyin 22'si gerçek, 9'u çözülmüş ya da boş, 4'ü hiç yok. Sınıf kararı bot politikasına ve kod okumasına dayanıyor; insan oturumuyla doğrulanmadı [kanıtsız].

---

## 7. Q, C, D döngüye ne getiriyor
Kaynak: `../OYUN_SISTEMLERI.md`, `../C_ICERIK_v3.md`, `../D_MODEL_v3.md`, `../SPRINT_DUZENI.md`, `../KALITE_v2.md`, `../MEMNUNIYET_SIM.md`. Sayılar belge sayıları ya da bu raporun hesabı. "Hesap" yazanı ben hesapladım.

### 7.1 Q (ürün kalitesi)
| | Sayı | Not |
|---|---|---|
| Yeni karar fiili | **0** | Karar ağırlığı değişir: hangi alana kart (en zayıf alanın en iyi kartı), işe alım rolü |
| Yeni okuma | **7** | alan seviyesi sözcüğü (Yok, Zayıf, Yeterli, Güçlü); "Henüz beklenmiyor"; Kararlılık satırı (açık hata ▲); sektör cümlesi; hesap ipucunda ürün uyumu; kayıp nedeni cümlesi; yatırımcı sorgusu zayıf alan adı (`OYUN_SISTEMLERI.md` §4) |
| Yeni kesinti | **0** | |
| Kalkan | 3 gizli eksen (Deneyim, İnovasyon, Kararlılık) ekonomiyi sürmez | `OYUN_SISTEMLERI.md` §4 |
| Dikkat | imzaların **%75'inde ürün uyumu 100'e doyuyor** (`KALITE_v2.md` İnceleme 2) | kalibrasyon yapılmazsa görüşme çözülmüş kalır (§8.3) |

### 7.2 C (ürün sayfası, sunucu, giderler, B2B hesaplar)
| | Sayı | Not |
|---|---|---|
| Yeni karar | **5 yüzey** | sunucu kademesi (3 seçenek, geçiş anında ve bedava); kapasite artır / azalt (%10 adım, en az 1 birim); bütçe kesintisi kartı (2 şık); yenileme kâğıdı; kurumsal sunucu maddesi. Sunucuda bugün oyuncu kararı **yok** (§6.2 madde 18) |
| Kapasite tıkı | 10 kat büyüyen ürün için ≈ **24 tık** (hesap: ln 10 / ln 1,1) | sabit adımla 330 hesapta 13 tık (`C_ICERIK_v3.md` §2.2) |
| Yeni kesinti | bütçe kesintisi: **5,75 / yıl** (330 hesap, bakımlı ürün) ⇒ 0,11 / hf, 20 hesapta 0,3 / yıl (`C_ICERIK_v3.md` §4, `MEMNUNIYET_SIM.md` M9) | |
| | yenileme kâğıdı: **en çok 3 / ay** ⇒ ≤ 0,7 / hf; 330 hesapta hemen her ay ≥ 1 (`C_ICERIK_v2.md` §2.6.5) | B'nin "sprint başına bir kesinti" kuralına sayılmaz (öneri, onay bekliyor) |
| Yeni okuma | memnuniyet ipucu (satır satır toplam), Hesaplar tablosu (sıralama, 4 görünüm, arama), "Yük %" ve boş pay, büyüme uyarısı, yenileme bantları | |
| Kalkan | gizli memnuniyet hedefi ve kayma; onboarding tabanı; anlık sıçramalar (+15, −20); otomatik sunucu büyümesi; **araç gideri ve servis maliyeti** (iki satır) | `C_ICERIK_v3.md` §5.7 |
| **İstek kartını düzeltir** | "listede" +3 ve "şimdi değil" −4 artık **8 hafta** kalıyor (15 kart sertleşir, `C_ICERIK_v3.md` §5.9) | §8.2'yi kısmen çözer |
| **Orta oyunu kolaylaştırır** | servis giderinin kalkması: B2B nakit açığı 41 binden 12 bine, evre 3 aylık net 29 binden ≈ 90 bine (`C_ICERIK_v3.md` §3.5). Önerilen maaş ×1,5 telafisi 4 kapının 2'sini tutar | §8.1'i kötüleştirir; telafi kararı Erdem'de |

### 7.3 D (ekip ve sprint)
| | Sayı | Not |
|---|---|---|
| Karar fiili (değişen) | sprint başına **2 ile 3 eylem** | öneri, değiştir, başlat. Bugün de aynı (`product_tab.gd:245-275`). Fark: 50 kişide kart seçimi yok. Karta kişi atanmıyor (bugün de öyle, `sprint_system.gd:1129`) |
| Yeni karar | **2 yüzey**: gönder sorusu (2 şık); EA'da takım kurma | |
| Yeni kesinti | gönder sorusu: bilinen hata bulunanın üçte birine ulaşınca. 3 ile 25 kişide sprintlerin **%4 ile %29'u** (en çok 3 sprintte 1) (`D_MODEL_v3.md` §0 madde 5) | Sprintte en çok bir kesinti; sıra acil durum, söz olayı, kâğıt, bu soru (öneri) |
| Yeni okuma | darboğaz cümlesi; kurucu verim nedeni (3 satır); "Test: 3 hata buldu, 2'si düzeltildi"; aşama şeridi; takım satırı (hız, boşta); kişi yükü | |
| Kalkan | liderin "yalnız bitecek kartlar ve en çok bir devreden kart" kuralı (`sprint_catalog.gd:505-509`); yerine kart sayısı sonuç: sprint başına kart 0,4 / 1,1 / 2,4 / 5,4 / 13 / 27 (1, 3, 6, 12, 25, 50 kişi). Ayrıca sürekli hata sprinti ve kartta yüzde | `OYUN_SISTEMLERI.md` §1,§2,§3. Bugün 13 kişide plan başına 2,75 ile 2,95 kart (§4.5), D'de 12 kişide 5,4 |
| **Sprint boşluğunu kapatır** | hedef: plan anında açık aday ≥ 0,75 × ekip, öneri doluluğu ≥ %94 (`D_SIM_v3.md` §8.4). Bugün %13 ile %15 (§4.5) | Zayıf an 5'i çözer. Arz: kademe + derinlik kartı (1 + hesap ÷ 5, en çok 8) + istek + düzeltme |
| Dikkat | 12 kişilik katalog 12 haftada biter (`D_MODEL_v3.md` İnceleme 9) | derinlik kartı olmadan döngü kısa kalır |

### 7.4 Toplam
| | Q | C | D | Toplam |
|---|---|---|---|---|
| Yeni karar yüzeyi | 0 | 5 | 2 | 7 |
| Yeni okuma | 7 | 5 | 6 | 18 |
| Yeni kesinti, hf başına, en kötü | 0 | 0,81 (kesinti 0,11 + yenileme 0,7) | 0,29 | 1,1 |
| Yeni kesinti, hf başına, tipik | 0 | 0,36 (0,11 + 0,25) | 0,15 | 0,5 |
| Kalkan kesinti ya da gizli sayı | 3 eksen | 2 gider + 4 gizli parça | lider kuralı | 10 |

B2B Traction'da bugünkü durma 1,72/hf. En kötü toplam artış +1,1 ⇒ %64. Tipik artış +0,5 ⇒ %29.
Hesap: gönder sorusu sprintlerin %4 ile %29'unda gelir (`D_MODEL_v3.md` §0 madde 5); sprint hızı 0,5 (2 hf) ile 1 (1 hf) sprint/hf ⇒ 0,02 ile 0,29/hf; tipik %15 x 1 = 0,15. Yenileme kâğıdı en çok 3/ay = 0,7/hf; "hemen her ay ≥ 1" ⇒ tipik 0,25/hf. Bütçe kesintisi 5,75/yıl = 0,11/hf.
Not: B'nin kuralı sprintte en çok bir kesinti (`CLAUDE.md` §6). Bu üst sınır artışı kısmen keser; yenileme kâğıdı bu sayıma girmiyor (öneri, onay bekliyor).
B2C'ye etkisi: sunucu kolu (B2C birimi 1.000 kullanıcı) ve Q okumaları. B2C fiyatı E'ye dek geçici (`OYUN_SISTEMLERI.md` §7).

### 7.5 Q, C, D'nin 8 zayıf ana etkisi
| Zayıf an | Q | C | D |
|---|---|---|---|
| 1 Orta oyun parası | | **kötüleştirir**, telafisiz | |
| 2 İstek kâğıdı | | kısmen çözer | |
| 3 Görüşme çözülmüş | kısmen (doyum %75) | imza kapısı: eşik + 10 | |
| 4 Dur-başla | | **ekler** (+0,36 ile +0,81 / hf) | **ekler** (+0,15 ile +0,29 / hf) |
| 5 Sprint planı boş | | | **çözer** |
| 6 B2C orta | okuma | sunucu kolu (yeni karar) | |
| 7 Series A | yatırımcı sorgusu zayıf alan | | |
| 8 Etkisiz yüzeyler | | | |

---

## 8. Döngünün en zayıf 8 anı
Sıra: oyuncunun sıkılacağı, kaybolacağı ya da boş tıklayacağı yer, ağırlığa göre.

### 8.1 Orta oyunda para yok, hedef de yok
- **Ne olur.** Hafta 12 ile 20'den sonra kasa yalnız artıyor. Oyuncu "hangi karar bana bedel ödetir?" sorusunun cevabını bulamıyor.
- **Kanıt.** Sonlu runway: B2B Traction 30/512 hafta (%5,9), Series A 0/424; B2C Traction %20,5, Series A 0/248 (§4.6). Kasa medyan B2B 31K (hf14), 146K (hf20), 621K (hf103). Fuar −$30.000 ve kampanya −$18.000 kasanın %3 ile %5'ine iniyor (§4.7).
- **Hedef.** Seed kapanınca TopBar "Sıradaki" satırı boş (`scripts/systems/cheque_read.gd:15-23`). Seed (hf18 ile 21) ile Series A kapısı (hf58 ile 60) arası yaklaşık 40 hafta, adlı hedef yalnız Finans'ta.
- **Finans** sayfası salt okunur (`finance_ozet_view.gd:165,492`).
- **Etki.** 40 hafta x 22,5 sn = 15 dk saf saatte para kararı yok.
- **Q/C/D.** C servis giderini kaldırınca kötüleşir (§7.2).

### 8.2 İstek kâğıdı: haftada 1,1 kez aynı üç şık
- **Ne olur.** B2B hesap istek kartı gönderiyor. Üç şık: söz ver (kilitli koşullu), listede olduğunu söyle (+3), şimdi değil (−4). Oyuncu 1,1/hf aynı kartı görüyor.
- **Kanıt.** 113,8 kart / koşu (§4.2). Bot 1.084/1.138 kez "Listede" seçti (`PROBE PICK`). Ölçek: hesap başına yılda 0,38 (§4.3).
- **Neden boş.** `satisfaction_delta` yalnız görünen değeri yazar; `_drift` bir tikte hedefe çeker, yukarı yönde tam güçle (`scripts/systems/b2b_sales_system.gd:48-76,96-130`; `scripts/events/core/effects.gd:420-427`). Sıra: önce kayma (`_tick_satisfaction`), sonra risk kontrolü (`_tick_customer`, `:48-71`). İki şık aynı sonuç.
- **Süre.** `expires_weeks: 2`; 2 hafta içinde cevap yoksa −5 (`request_feature.json` `on_expire`).
- **Etki.** 150 hesapta haftada 1,1 tık, hepsinin ucu aynı. Yalnız "söz ver" gerçek (sprint kapasitesi).
- **Q/C/D.** C kalıcı yapıyor (8 hafta, §7.2).

### 8.3 Satış görüşmesi çözülmüş verb
- **Ne olur.** B2B'de ana verb haftada ≤ 4 görüşme. Oyuncu 104 haftada en çok 416 oturum açabiliyor.
- **Kanıt.** Bot: ilk açık cevap + ilk karşı teklif. 3.828 oturumun 3.739'u kazanıldı (%98) (§4.2; `run_probe.gd:1103-1146`). 350 imza / koşu. İmzaların %61'i 1★, %36'sı 2★, %3'ü 3★ (3.514 imzada 2.158 / 1.258 / 98).
- **Etki.** Kazanma becerisi gerektirmiyor. Beceri tek yerde: fiyat duruşu (%85 / 100 / 115) ve 3★ lead'ler.
- **Sınır.** İnsan ölçümü yok. Becerili oyuncunun farkı bilinmiyor [kanıtsız].
- **Q/C/D.** Q imza kapısı ve kayıp nedeni getiriyor; ama imzaların %75'inde ürün uyumu 100'e doyuyor, yani kapı çoğu görüşmede tutmaz (`KALITE_v2.md` İnceleme 2).

### 8.4 Her karardan sonra saat duruyor ve elle başlıyor
- **Ne olur.** Karar kartı, sprint planı ya da sürüm notu saati durdurur. Bittiğinde saat kendiliğinden sürmez; oyuncu Boşluk'a ya da hız düğmesine basar.
- **Kanıt.** `time_manager.gd:358-361` ("Nothing resumes: only the player starts the clock"). `sprint_system.gd:126-127` ("saati oyuncu sürdürür"). `main.gd:4099-4106`.
- **Sayı.** B2B Traction'da durma 1,72/hf (karar 0,82 + tek düğmeli 0,16 + sprint başlatma 0,74). 1×'te her 13 sn saatte bir durma. Series A'da 1,41/hf. B2C 0,81/hf.
- **Tek düğmeli.** B2B koşuda 17,8 kart (istifa 9,2; Frank'in 7 kartı: `funding.gate_traction`, `seed_closed`, `frank_door_open`, `frank_approach_near/half/close`, `hire_nudge`; `frank_intro`, `final_stretch_verdict`). B2C 7,7. İstifa kartı etkili tek seçenek olduğu için not sayılmıyor (`presenter.gd:132-137`, `team/resignation.json`).
- **Açık paneller.** Karar kartı açılınca Atlas ya da zam diyaloğu gibi açık paneller kapanır (`main.gd:4066-4070`).
- **Etki.** Akış parçalanıyor. C ve D bunu artırıyor (§7.4).

### 8.5 Sprint planı boş: kapasite %85 boşta
- **Ne olur.** Plan ekranı açılıyor: öneri uygula, başlat. Kartlar bir haftada bitiyor, sprint erken kapanıyor, yeniden plan.
- **Kanıt.** Doluluk medyan B2B Traction %15, Series A %13 (§4.5). 956/1.506 sprint 1 tikte kapandı (B6m §5.1). B2B 81 ile 88 plan / koşu (`PROBE SPRINT`). Kart eforu 3 / 5 / 8 puan, kapasite 20 puan / 2 hf (13 kişide) (`PROBE PLAY ... capacity=20.40`).
- **Bot kararı.** Lider önerisini uygula ve başlat = 2 eylem (`run_probe.gd:981,997`).
- **Etki.** 80 kez plan + 80 kez saati yeniden başlatma, hiçbiri gerçek seçim değil.
- **Çıkış.** PM'e devret (`sprint_system.gd:592-594`) planı kaldırır. Oyuncunun bu çıkışı bulup bulmadığı ölçülmedi [kanıtsız].
- **Q/C/D.** D çözer (§7.3).

### 8.6 B2C orta oyun: izliyor, karar vermiyor
- **Ne olur.** B2C'de pazar iki yönlü ama oyuncunun kolu yok: fiyatı kart kuruyor, sunucu otomatik, satış sayfası salt okunur.
- **Kanıt.** Karar 1,26/hf (çoğu sprint başlatma). Haftaların %65'inde kart yok, %16'sında hiçbir etkileşim yok. Kartsız en uzun seri 6 ile 11 hafta (§4.4). MRR 4 binden (hf30) 726 bine (hf103) çıkıyor; oyuncunun bu eğriye dokunan kolu yok.
- **Kod.** `sprint_bridges.gd:136-139` (fiyat), `:69-73,130-134` (sunucu), `sales_tab.gd:259-289`. Ses: tek MP3, SFX sıfır (`audio_manager.gd:41`).
- **Süre.** Bot B2C'de Series A kapısına hf75 ile 84'te geliyor. 68 hafta Traction x 22,5 sn = 26 dk saf saat; ekranda sessiz sayı yarışı.
- **Q/C/D.** C sunucu kolu ekler. Fiyat E'ye dek geçici.

### 8.7 Series A: formalite, ret sonrası hiçbir şey
- **Ne olur.** Kapı açılıyor, 1 ile 5 haftada imza. Reddedilen oyuncuya oyun bir şey anlatmıyor, hedef vermiyor.
- **Kanıt.** 9/10 imza, masada 0 zorlama, 9 masada ikna 70 ile 93 / eşik 35 ile 55 (§3.3). Tohum 6: 4 ret, 64. günde `road_closed`, 40 hafta bomboş (48 istek, 8 genişleme, 4 kesinti kartı).
- **Fon seçimi de çözülmüş sayılır.** Bosphorus 6 oturumun 5'inde teklif verdi, Nexus 7'de 1 (§3.3).
- **Yalan.** "Üçüncüde yol biter" (`strings.csv:831`); MRR ≥ 2.000 ise kaskad ateşlemez (`endings_system.gd:155-175`). Ret `faced_series_a` yazmaz (`vc_pitch_system.gd:535-548`); kârlı bootstrap sonu hiç gelmez, 104'te `running_on_fumes` (`endings_system.gd:216,240-255`).
- **Etki.** Oyunun doruğu en kısa evre.
- **Q/C/D.** Dokunmuyor.

### 8.8 Karar gibi duran etkisiz yüzeyler
- **Huylar.** Onboarding'de ilk karar. Hiçbir sistem okumuyor (`founder_constants.gd:41-43`).
- **Köken.** 3 kart, 2 kilitli (`founder_constants.gd:74-76`).
- **Ofisi taşı.** Bedelsiz, masa sayısı yalnız gösterim (`office_constants.gd:6`, `office_system.gd:48-55`, `office_map_card.gd:63`). Ofis hiçbir kuralı değiştirmiyor.
- **Ar-Ge.** 20 düğümün 4'ü okuyucusuz (`cicd`, `accessibility`, `semantic_index`, `analytics_engine`; `research_seam.gd:29,35,40,48`).
- **Etki.** İlk dakikada yanlış sinyal: seçim etkisiz. Orta oyunda: ofis ve Ar-Ge "yapılacak iş" gibi görünüyor.

---

## 9. Sonraki ölçüm
Önerilen en ucuz üç ölçüm (kod değişmeden):
1. **İnsan oturumu**, 30 dk, hafta 1 ile 20: süre, durma, tereddüt, hangi kartı atladı. Zayıf an 2, 3, 4 için.
2. **B2C Series A koşusu** (`full_run_b2c_vc_cautious`, 10 tohum): hf75 sonrası döngü.
3. **Sprint planı** `--sprint-probe=hours=8:cards=2:ticks=104:fill=1` ile kart arzı: D'nin sayıları bugünkü koda karşı.
