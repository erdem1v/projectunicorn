# Satış rev 6 — Faz 0 keşif defteri ve emeklilik tablosu

**Tarih:** 2026-08-26 · **Kaynak:** `GDDs/GDD — SATIŞ MODÜLÜ (rev 6 · İNŞA SÜRÜMÜ).docx` §19
**Taban:** `main` @ `95eb8aa`

§19'un listesi 2026-08-20 uyum denetimine karşı yazıldı. O tarihten sonra ağaca **iki yeniden
inşa** indi — olay motoru (`cc952e4`, `95eb8aa`) ve Ekip rev 11 — ve listenin birkaç maddesi o
yüzden bugünkü kodda başka bir yerde duruyor. Bu defter listeyi **HEAD'e karşı** doğrular;
inşa buradan yapıldı.

---

## 1 · Emeklilik listesi, madde madde

| §19 maddesi | 2026-08-26'da kodda nerede | Kaderi |
|---|---|---|
| `find_prospects` butonu ve 2/5-gün üretimi | `sales_tab.gd:13-14, 172-197, 473-485` | **SİLİNDİ.** Sayfa yeniden kuruldu; sabitler `GameState.FLAG_TYPES`'tan da çıktı (`next_find_prospects_day`). Yerine `SalesFaucetSystem` (§3). |
| 65 isimlik katalogun "tek arz" rolü | `pitch_system.gd:127-132` → `company_catalog.gd:28-120` | **ROL EMEKLİ, KATALOG DURUYOR.** `SalesNamePool` kürasyonlu 65 ismi havuzun BAŞINA koyuyor, arkasına üretilmiş çoğunluğu ekliyor. Tek satır bile atılmadı. |
| Sektör-afinite daraltması | `b2b_constants.gd:234-238`, `pitch_system.gd:62-75` | **EMEKLİ.** Yerine arketip afinitesi (`SalesArchetypes.sectors`) + §3.1 guard'ı. `SECTOR_AFFINITY` tablosu duruyor ama satışın hiçbir yolu artık okumuyor. |
| `warm_progress` ve ısıtma modeli | `prospect.gd:29`, `sales_rep_system.gd:153-179` | **SİLİNDİ** (alan + tüm okuyucuları). Yerine §7.2 işleme süresi: adı belli bir temsilcinin masasında geçen gün. |
| 2 günlük cooldown | `pitch_system.gd:17, 196, 342` | **SİLİNDİ.** Yerine §5.0'ın günde-bir hakkı (`sales_meeting_used_day`), mesai başında yenilenen. |
| Dört-vuruş pitch scripti | `pitch_system.gd:215-325` | **SİLİNDİ.** Yerine Perde 1 storylet seçicisi (`SalesProbes`) + sessiz Perde 2 (`NegotiationSystem`). |
| Arketip bandından deal MRR | `pitch_system.gd:357-365`, `customer_archetypes.gd:21-46` | **EMEKLİ.** Yerine koltuk × koltuk fiyatı; fiyatın tek evi kadran (§7.5). `CustomerArchetypes` tablosu yalnız `expansion_seats` için okunuyor. |
| Sabit genişleme koltuk-MRR'ı | `b2b_constants.gd:249` | **GÖÇ EDİLDİ, SİLİNMEDİ.** `EXPANSION_PER_SEAT_MRR` artık YALNIZ damgasız kayıtların (v10 kaydı, fikstür) yedeği. Motorun `b2b_expand` efekti onu geçirmeye devam ediyor ve `expand()` görmezden geliyor — motor dosyası açılmadı. |
| CALLBACK sonsuz-lead davranışı | `pitch_system.gd:351, 368` | **SİLİNDİ.** rev 6'da iki sonuç var: kazanım ve kayıp. Dönüş §9'un engel kapısından geçiyor. |
| `SCALE_DEMO_MAX` bayrağı ve enterprise bandı | `b2b_constants.gd:24, 62-68`; `customer_archetypes.gd:38-45` | **ETKİSİZ.** Musluk 1-3★ üretiyor (§2 mühürlü tavan) ve `roll_scale` hiçbir üretim yolundan çağrılmıyor. `b2b_high_scale_unlocked`'ın zaten HİÇ YAZANI YOKTU — tavan pratikte koşulsuzdu, ki denetimin F10 bulgusu buydu. |

## 2 · Korunanlar — dokunulmadı

Tolerans · risk serisi · churn geri sayımı · retention kartı (indirim tavanı ve histerezis
dahil) · genişleme kapısı · CS eskalasyonu · MRR köprüsü · marka bedelleri. Tek istisna
§19'un kendi izniyle: **genişlemenin FİYAT KAYNAĞI** (§5.4).

## 3 · Motorun satışa bağlandığı dört yer — ve dördü de motora dokunmadan karşılandı

| Motor yüzeyi | Ne çağırıyor | Nasıl ayakta kaldı |
|---|---|---|
| `effects.gd:316` (`add_prospect`) | `PitchSystem.spawn_prospect(size, source)` | `pitch_system.gd` iki fonksiyonluk bir uyum dosyasına indi. Bu bir nezaket değil: §3 balinayı olay kanalına veriyor, yani bu çağrı CANLI bir gereksinim. Eski üç-kademe id'si burada yıldıza çevriliyor. |
| `scope.gd:168,189,221` | `ProspectRegistry.count/get_prospect/get_all` | Kayıt olduğu gibi korundu. |
| `seams_sales.gd:100-115` | `ProspectRegistry.count`, `SalesSystem.is_b2b_market/b2c_audience/growth_band` | Hepsi korunan kümede. |
| `effects.gd:544` (`b2b_expand`) | `B2BSalesSystem.expand(id, seats, sabit)` | İmza değişmedi; sabit yedeğe düştü. |

`EvSignals.BINDINGS`'te satış satırı YOK, yani yeni bir sinyal bugün kart TETİKLEYEMEZ.
Gerek de yok: §14'ün on sekiz sinyali **sözlük** için yayınlanıyor (motor konvansiyonu §15.1)
ve satışın kaldırdığı her kart `EventGate.request` ile geliyor — sekmenin retention kartını
zaten öyle kaldırdığı yol. **Hiçbir motor dosyası açılmadı.**

## 4 · Denetimin bulmadığı, Faz 0'ın bulduğu iki şey

1. **Alt-tip id'leri taşındı, özellik havuzu taşınmadı.** Ürün rev 6.1 oynanan alt-tipleri
   `note_tool` · `video_clip` · `erp` yaptı (`ProductCatalog.SUB_PRODUCT_TYPES`), ama
   `FEATURE_POOLS` hâlâ emekli `ai_*` / `saas_*` id'lerinde. Sonucu ölçülebilir:
   `B2BSalesSystem.pick_pain_feature("erp", n)` bugün **""** dönüyor, yani gerçek bir rev 6.1
   koşusunda hesabın "istediği özellik" kanalı boş. Satış tarafındaki dürüst cevap, motorun
   adlandıramadığı bir şey için **söz fiilini hiç sunmamak** oldu (`has_promise_target`
   olgusu). Kanalın kendisi Ürün'ün işi.
2. **`sales_tab.gd` `EventBus.day_advanced`'e bağlıydı.** O sinyal `GameState.advance_day()`
   İÇİNDE, günlük tick'ler dağıtılmadan önce atılıyor; sayfa dünkü durumu okuyordu. Yeni
   sayfa `day_tick_completed`'e bağlı.
