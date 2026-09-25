# Lokal ölçüm: B2 (kapı günü) ve E modeli (5 tohum × 2 politika)

**Tarih:** 2026-09-25
**Koşu:** `--run-log=<preset>:700:sim:<tohum>`, tohum 1–5.
- Oyun kodu `fc58e7c` + madde 5'in geri alınması (`86e33eb`).
- Harness: `05e6a3f` (B2 satırları) ve `63800db` (VC politikaları ve tekrarlar).

**Ham loglar** yaklaşık 170K satır/koşu; repoya alınmadı. Aynı komutla yeniden üretilir; koşular deterministik (aşağıda).

**Kalibrasyona ve tasarım sabitlerine dokunulmadı.** Aşağıdaki rakamlar yorumsuz verilmiştir.

---

## 0. Tekrarlanabilirlik

- `full_run` tohum 1 iki kez koşuldu. `PROBE` çıktısı birebir aynı.
- Kapı günü, `gate_series_a` günü ve kapıdaki durum 5 tohumun 5'inde cloud ölçümüyle (`RUN_OZET.md`, `de6ab7f`) birebir aynı: nakit, MRR, marka, burn, müşteri, çalışan, kârlı ay serisi.
- Yeni satırlar (`PROBE GATE`, `PROBE MONTH_BURN`) eklendikten sonra, bu satırlar filtrelenince 9 presetin 9'unda `PROBE` çıktısı değişmedi. Presetler: `full_run` 1–5, `full_run_naive`, `full_run_discount`, `full_run_weak` (tohum 1), `b2b_slip_keep:90`.

---

## 1. B2: kapının açıldığı gün

**Kaynak:** `PROBE GATE`. Kapı günü, o günün `PROBE STATE` satırıyla aynı anda basılır: günün kartları ve botun hamlelerinden sonra. `RUN_OZET` sütunlarıyla aynı an.

**Tanımlar:**
- **Aylık maaş yükü:** `CharacterRegistry.get_total_monthly_salaries()`, o günkü kadronun sözleşmeli aylık maaşı. İzinliler dahil.
- **Run-rate gider:** günlük burn × 30. Günlük burn = maaş + fazla mesai + kurucu + sunucu + pazarlama + ofis (`finance_system.gd:34-43`).
- **Run-rate marj:** (MRR − run-rate gider) / MRR.
- **Son kapanan ay:** kapı gününden önceki (ya da o gün kapanan) takvim ayı, `month_history`. Gider = günlük burn toplamı + tek seferlik giderler (işe alım komisyonu, kıdem, eğitim, geliştirme bedeli).
- **Ay marjı:** net / gelir. 3 ve 6 aylık marj = Σnet / Σgelir (`GameState.get_window_margin_pct`).

**Ofis:**
- Bütün rakamlar **ofis gideri olmadan** hesaplandı.
- `finance_system.gd:39`: `"office": 0`, TODO. Ofis gideri ofis sistemiyle gelecek; tasarımı henüz yok.
- Bu TODO'ya sayı konmadı.

### 1.1 Kapı günü: kadro ve run-rate

| Tohum | Kapı günü | Çalışan (izinli) | Roller (hepsi junior) | Aylık maaş yükü | Günlük burn: maaş + kurucu + sunucu | Run-rate gider (×30) | MRR | Run-rate marj |
|---|---|---|---|---|---|---|---|---|
| 1 | 305 | 7 (0) | `product_manager` 1 · `sales_rep` 6 | 15.660 | 522 + 50 + 137 = 709 | 21.270 | 120.736 | %82 |
| 2 | 357 | 12 (2) | `developer` 2 · `sales_rep` 5 · `customer_rep` 5 | 26.870 | 896 + 50 + 132 = 1.078 | 32.340 | 120.423 | %73 |
| 3 | 287 | 10 (0) | `product_manager` 1 · `developer` 1 · `sales_rep` 6 · `customer_rep` 2 | 22.570 | 823 + 50 + 135 = 1.008 | 30.240 | 120.443 | %74 |
| 4 | 442 | 13 (1) | `product_manager` 4 · `developer` 3 · `sales_rep` 4 · `customer_rep` 2 | 31.305 | 1.044 + 50 + 132 = 1.226 | 36.780 | 122.190 | %69 |
| 5 | 261 | 12 (0) | `product_manager` 1 · `developer` 3 · `tester` 1 · `sales_rep` 4 · `customer_rep` 3 | 26.900 | 897 + 50 + 132 = 1.079 | 32.370 | 120.705 | %73 |

- Fazla mesai, pazarlama ve ofis 5 tohumda da 0.
- Kapıda müşteri sayısı ve müşteri başına MRR: 156 / 774 · 176 / 684 · 162 / 743 · 186 / 657 · 172 / 702 (tohum 1–5).
- `designer` hiçbir tohumda yok.
- Günlük maaş satırı o günün finans diliminde yazılır. Aylık maaş yükü ise günün sonundaki kadroyu okur. Tohum 3'te ikisi arasındaki fark (823 × 30 ≠ 22.570) aynı gün kadrodan ayrılan bir çalışandan geliyor: kapı günü dağıtım sonunda 11 çalışan vardı, gün sonunda 10.

### 1.2 Son kapanan ay

| Tohum | Ay (gün) | Gelir | Maaş (gerçekleşen) | Kurucu | Sunucu | Tek seferlik | Toplam gider | Net | Ay marjı | 3 ay | 6 ay |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | 275–305 | 116.659 | 18.475 | 1.550 | 3.947 | 4.475 | 28.447 | 88.212 | %75 | %66 | %60 |
| 2 | 306–335 | 104.856 | 27.369 | 1.500 | 3.594 | 4.025 | 36.488 | 68.368 | %65 | %61 | %57 |
| 3 | 245–274 | 103.035 | 27.732 | 1.500 | 3.420 | 2.475 | 35.127 | 67.908 | %65 | %61 | %57 |
| 4 | 398–425 | 93.252 | 29.013 | 1.400 | 3.091 | 0 | 33.504 | 59.748 | %64 | %58 | %54 |
| 5 | 214–244 | 96.689 | 29.729 | 1.550 | 3.099 | 600 | 34.978 | 61.711 | %63 | %59 | %52 |

- Ay penceresi `(start_day, end_day]`: ayın 1'inin gideri kapanan aya girer. `PROBE MONTH_BURN` bunu kendisi doğruluyor: 8 presetin 184 satırında (115'i bu 5 tohumdan) gün sayısı tutuyor ve tek seferlik ≥ 0.
- Yüzdeler tam sayı bölmesiyle aşağı yuvarlanmış (`get_window_margin_pct` ile aynı).
- Tohum 1'de kapı günü bir ay kapanışına denk geliyor (305).
- Tohum 4'te son kapanan ay 28 gün.

### 1.3 Botun işe alım kuralı (olgu, yorum yok)

- `run_probe.gd:877-893` `STAFF_LADDER`: 13 basamak.
  - Sıra: `developer` · `customer_rep` (3 müşteri) · `tester` (MRR 3K) · `sales_rep` (4K) · `sales_rep` (12K) · `developer` (15K) · `customer_rep` (12 müşteri) · `sales_rep` (30K) · `product_manager` (30K) · `sales_rep` (50K) · `developer` (60K) · `customer_rep` (25 müşteri) · `sales_rep` (80K).
- Basamak mevcut çalışan sayısıyla seçiliyor (`:912`): biri ayrılınca sıradaki işe alım farklı bir basamaktan gelir.
- Her zaman junior (`:921`), ilk aday dosyası (`HRSearchSystem.hire(0)`, `:903`, `:928`).
- İşe alım melek çeki kabul edildikten sonra başlıyor. Nakit ≥ 6 × aylık açık şartı var (`:918-919`).

---

## 2. E modeli: 5 tohum × 2 politika

**Politikalar** (`run_probe.gd`, "The Series A hunt"; çalışma tanımları):
- **Saf (`full_run_vc_naive`):**
  - Kapıdan sonra (faz 3, `gate_series_a` cevabıyla kapının ertesi günü) `InvestorRegistry` sırasıyla (Anchor, Nexus, Bosphorus, Meridian) ilk uygun fonla görüşme ayarlar.
  - Masada itilebilir kaldıraçlardan birini her itişte rastgele seçer ve sabır bitene kadar iter. Üreteç masa başına yereldir; tohumu `EvDice.fnv1a` ile koşu tohumu, gün ve fondan türetilir, oyunun akışlarına dokunmaz.
  - Son teklif gelirse imzalar.
- **Temkinli (`full_run_vc_cautious`):** aynı görüşme; masada hiç itmeden imzalar.

**Görüşme kuralı** (iki politikada aynı):
- Beat 1 oda okuma.
- Beat 2 gösterilen ihtimali en yüksek açı.
- Beat 3 dürüst.
- Ilık çatal: masayı zorla.
- Hazırlık yok.
- Red gelirse ertesi gün sıradaki fon.
- Kurucu becerileri probe'un yükünden: satış 2, mühendislik 2, ürün 1, karizma 1 (`main.gd:3069-3083`).

**Tek masa.** İmza koşuyu bitiriyor (`series_a_close`). Fon kalkarsa `faced_series_a` işaretleniyor ve kapıdaki kârlı şirkette `profitable_bootstrap` ertesi gün koşuyu bitiriyor. 2 kalkmanın 2'sinde de böyle oldu.

### 2.1 Masalar

| Tohum | Görüşmeler (sonuç) | Masa | Sheet inancı | E0 (uyum) | Sabır / eşik | Saf | Temkinli |
|---|---|---|---|---|---|---|---|
| 1 | Anchor red · Nexus red · Bosphorus teklif | Bosphorus | 83 | 81 (−2) | 2 / 55 | **son teklif → imza**: itiş `b,d`, 0 kazanç, E 58 | imza (itişsiz) |
| 2 | Anchor red · Nexus zorla → red · Bosphorus red · Meridian teklif | Meridian | 81 | 79 (−2) | 2 / 55 | **son teklif → imza**: itiş `d,d`, 0 kazanç, E 59 | imza (itişsiz) |
| 3 | Anchor, Nexus, Bosphorus, Meridian: dördü de red | — | — | — | — | masa yok (yol kapandı) | masa yok |
| 4 | Anchor zorla → teklif | Anchor | 45 (zorla) | 45 (0) | 3 / 45 | **fon kalktı**: itiş `d,v,d,v,b,v`, 3 kazanç, E 0 | imza (itişsiz) |
| 5 | Anchor zorla → red · Nexus teklif | Nexus | 74 | 84 (+10) | 4 / 35 | **fon kalktı**: itiş `v,d,d,v,d`, 1 kazanç, E 24 | imza (itişsiz) |

İtiş harfleri: `v` değerleme, `d` pay, `b` yönetim kurulu.

**Özet:**

| Politika | Masa | İmza (son teklifsiz) | Son teklif → imza | Fon kalktı | Kalkma oranı |
|---|---|---|---|---|---|
| Saf | 4 | 0 | 2 | 2 | 2/4 (%50) |
| Temkinli | 4 | 4 | 0 | 0 | 0/4 |

- **Hedef** (saf politikada kalkma ≤ %25): ölçülen 2/4. n = 4, çok küçük.
- Saf politikada "itişsiz imza" sınıfı pratikte oluşmuyor. Değerlemenin tavanı yok (`term_sheet_table_system.gd` `_lever_at_best`), bu yüzden itilecek bir kaldıraç hep kalıyor.
- Tohum 3'te dört görüşmenin dördü de reddedildi, ret sayısı 4. Koşu 700. güne kadar sürdü. Ret, yüzleşme sayılmıyor; zincir, MRR ≥ 2.000 olduğu için pivot mandalında takılıyor (`endings_system.gd:203-212`).
- Görüşmeler 14; 4'ü teklif, 10'u red. Açılış inancı 28–40.
- Fon kalkan 2 koşunun ikisi de ertesi gün `profitable_bootstrap` ile bitti.

### 2.2 Tekrarlar: aynı gün, aynı şirket, dört fon × 20 masa (yalnız saf)

**Kurulum:** Her tohumda masa açılmadan hemen önce (tohum 3'te masa yok anında), her fon için 20 masa oynandı:
- tek taze teklif, sheet inancı 70 (kazanma eşiği) → E0 = 70 + o fonun gerçek uyumu;
- her masada `skill` zar akışı ayrı tohumlandı.

**Yan etki yok:** Hiç imza atılmadı. Her tekrardan sonra dokunulan GameState alanları geri yüklendi; `skill` akışının tohumu ve konumu bütün tekrarların sonunda bir kez geri yüklendi. Bir parmak izi (GameState, kayıtlar, kaydın bütün sistem blokları dahil olay motoru ve RNG akışları, olay motoru sinyal tamponunun uzunluğu) önce ve sonra karşılaştırıldı; fark yok. `replay=0` ve `replay=20` koşuları, `VC_REPLAY` satırları dışında 5 tohumun 5'inde birebir aynı.

| Fon | n | Son teklif | Fon kalktı | Kalkma | E0 (tohumlar) | Sabır / eşik | Ort. itiş | Ort. kazanç |
|---|---|---|---|---|---|---|---|---|
| Anchor | 100 | 0 | 100 | %100 | 70 (uyum 0) | 3 / 45 | 5,35 | 2,35 |
| Nexus | 100 | 0 | 100 | %100 | 68–80 (uyum −2 / +10) | 4 / 35 | 6,90 | 2,90 |
| Bosphorus | 100 | 0 | 100 | %100 | 68 (uyum −2) | 2 / 55 | 3,87 | 1,87 |
| Meridian | 100 | 0 | 100 | %100 | 68 (uyum −2) | 2 / 55 | 3,73 | 1,73 |

**Sabitlerden türetilen sınır** (`term_sheet_table_system.gd` EAGERNESS bloğu; koşu sonuçlarıyla tutarlı):
- Sabır yalnız başarısız itişte düşer. Başarısız itişin bedeli: 6 + 4 × adım (en az 10), fonun kendi kaldıracında +3. Başarılı itişin bedeli 3 (+3).
- Sabır p'den 0'a inene kadar itmek en az p başarısız itiş demek. Toplam bedel en az 10 × p.
- Kalkma eşiği 75 − 10 × p.
- Sonuç: sabır bitene kadar iten bir oyuncu son teklifi ancak **E0 ≥ 75 + kazanılan itişlerin, adım artışlarının ve fonun kendi kaldıracına yapılan itişlerin bedeli** ise alır. Bu, sabrın büyüklüğünden bağımsız.
- Bu sınır, E0 < 75 olan 320 tekrarda kalkmayı kesinleştiriyor: Anchor 70, Bosphorus ve Meridian 68, tohum 1'de Nexus 68.
- Nexus'un E0 80 olan 80 tekrarında 5 puanlık pay var. Oralarda son teklif mümkün: hiç kazanmadan ve fonun kendi kaldıracına en çok bir itişle, 4 başarısız itiş E'yi 80 − 40 − (3 × kendi kaldıracına itiş) = 37–40'ta bırakır, bu da ≥ 35. Düzeltilmemiş ilk koşuda bir Nexus tekrarı tam böyle son teklife ulaştı (E0 80, 4 itiş, 0 kazanç, E 40). Buradaki 0/80 ampirik sonuçtur, sabitlerin zorunlu kıldığı bir şey değil.
- Sınır "diğer teklifi göster"in (K7) E bedelini içermiyor; saf politika K7 kullanmıyor.
- Gerçek masalar:
  - Son teklife ulaşan iki masa E0 81 ve 79 ile, hiç kazanmadan, 2 başarısız itişle bitti:
    - Bosphorus: 81 − 13 − 10 = 58 ≥ 55; kurul Bosphorus'un kendi kaldıracı, +3.
    - Meridian: 79 − 10 − 10 = 59 ≥ 55.
  - Kalkan iki masa: Anchor E0 45 (zorla ile gelen teklif, inanç 45) ve Nexus E0 84 (5 itiş, 1 kazanç).

**Ölçümün tarihçesi:** Politikanın ilk sürümünde kaldıraç her itişte `EvDice.unit(..., "push<n>")` ile seçiliyordu. Bu karma, son baytı farklı anahtarlarda neredeyse aynı sayıyı veriyor, bu yüzden her masada hep aynı kaldıraç itildi (WF-H incelemesi). Düzeltildi: masa başına yerel bir üreteç, her itişte yeni çekiliş. Yukarıdaki bütün rakamlar düzeltilmiş koddan. Eski koşunun saf sonucu 1 son teklif / 3 kalkmaydı.

---

## 3. Ham satırlar

### 3.1 B2 (`PROBE GATE` ve eşleşen `PROBE MONTH_BURN`)

```
seed=1 PROBE GATE day=305 emp=7 on_leave=0 roles=product_manager:1/1-0-0,designer:0/0-0-0,developer:0/0-0-0,tester:0/0-0-0,sales_rep:6/6-0-0,customer_rep:0/0-0-0 payroll_monthly=15660 salaries=522 overtime=0 founder=50 servers=137 marketing=0 office=0 bd_sum=709 daily_burn=709 expense_runrate=21270 mrr=120736 runrate_margin_pct=82 cust=156 accounts=156 cash=355250 last_n=10 last_start=274 last_end=305 last_income=116659 last_expense=28447 last_net=88212 last_margin_pct=75 win3_margin_pct=66 win6_margin_pct=60 profit_streak=10 growth_avg_pct=13
seed=1 PROBE MONTH_BURN day=305 n=10 start=274 end=305 days=31 days_expected=31 salaries=18475 overtime=0 founder=1550 servers=3947 marketing=0 office=0 cat_sum=23972 expense=28447 one_time=4475 income=116659
seed=2 PROBE GATE day=357 emp=12 on_leave=2 roles=product_manager:0/0-0-0,designer:0/0-0-0,developer:2/2-0-0,tester:0/0-0-0,sales_rep:5/5-0-0,customer_rep:5/5-0-0 payroll_monthly=26870 salaries=896 overtime=0 founder=50 servers=132 marketing=0 office=0 bd_sum=1078 daily_burn=1078 expense_runrate=32340 mrr=120423 runrate_margin_pct=73 cust=176 accounts=176 cash=391918 last_n=11 last_start=305 last_end=335 last_income=104856 last_expense=36488 last_net=68368 last_margin_pct=65 win3_margin_pct=61 win6_margin_pct=57 profit_streak=11 growth_avg_pct=14
seed=2 PROBE MONTH_BURN day=335 n=11 start=305 end=335 days=30 days_expected=30 salaries=27369 overtime=0 founder=1500 servers=3594 marketing=0 office=0 cat_sum=32463 expense=36488 one_time=4025 income=104856
seed=3 PROBE GATE day=287 emp=10 on_leave=0 roles=product_manager:1/1-0-0,designer:0/0-0-0,developer:1/1-0-0,tester:0/0-0-0,sales_rep:6/6-0-0,customer_rep:2/2-0-0 payroll_monthly=22570 salaries=823 overtime=0 founder=50 servers=135 marketing=0 office=0 bd_sum=1008 daily_burn=1008 expense_runrate=30240 mrr=120443 runrate_margin_pct=74 cust=162 accounts=162 cash=333754 last_n=9 last_start=244 last_end=274 last_income=103035 last_expense=35127 last_net=67908 last_margin_pct=65 win3_margin_pct=61 win6_margin_pct=57 profit_streak=8 growth_avg_pct=21
seed=3 PROBE MONTH_BURN day=274 n=9 start=244 end=274 days=30 days_expected=30 salaries=27732 overtime=0 founder=1500 servers=3420 marketing=0 office=0 cat_sum=32652 expense=35127 one_time=2475 income=103035
seed=4 PROBE GATE day=442 emp=13 on_leave=1 roles=product_manager:4/4-0-0,designer:0/0-0-0,developer:3/3-0-0,tester:0/0-0-0,sales_rep:4/4-0-0,customer_rep:2/2-0-0 payroll_monthly=31305 salaries=1044 overtime=0 founder=50 servers=132 marketing=0 office=0 bd_sum=1226 daily_burn=1226 expense_runrate=36780 mrr=122190 runrate_margin_pct=69 cust=186 accounts=186 cash=330665 last_n=12 last_start=397 last_end=425 last_income=93252 last_expense=33504 last_net=59748 last_margin_pct=64 win3_margin_pct=58 win6_margin_pct=54 profit_streak=10 growth_avg_pct=18
seed=4 PROBE MONTH_BURN day=425 n=12 start=397 end=425 days=28 days_expected=28 salaries=29013 overtime=0 founder=1400 servers=3091 marketing=0 office=0 cat_sum=33504 expense=33504 one_time=0 income=93252
seed=5 PROBE GATE day=261 emp=12 on_leave=0 roles=product_manager:1/1-0-0,designer:0/0-0-0,developer:3/3-0-0,tester:1/1-0-0,sales_rep:4/4-0-0,customer_rep:3/3-0-0 payroll_monthly=26900 salaries=897 overtime=0 founder=50 servers=132 marketing=0 office=0 bd_sum=1079 daily_burn=1079 expense_runrate=32370 mrr=120705 runrate_margin_pct=73 cust=172 accounts=172 cash=261841 last_n=8 last_start=213 last_end=244 last_income=96689 last_expense=34978 last_net=61711 last_margin_pct=63 win3_margin_pct=59 win6_margin_pct=52 profit_streak=7 growth_avg_pct=24
seed=5 PROBE MONTH_BURN day=244 n=8 start=213 end=244 days=31 days_expected=31 salaries=29729 overtime=0 founder=1550 servers=3099 marketing=0 office=0 cat_sum=34378 expense=34978 one_time=600 income=96689
```

### 3.2 E modeli (VC satırları)

Bkz. `LOKAL_OLCUM_2026-09-25_vc.txt` (aynı klasörde).
