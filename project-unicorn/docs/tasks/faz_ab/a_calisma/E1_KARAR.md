# E1 · Erdem'in kararları (2026-10-16 gece / 17 sabahı) · BAĞLAYICI
Sunum: `E1_SUNUM.md`. Erdem'in birebir cevapları en altta. Sabitlerin hepsi kodda ve raporda **onay bekliyor** işaretlidir.
Bu karar, PRD'nin E1'e bıraktığı yerleri doldurur; PRD'nin öbür kararları aynen geçerlidir.

## 1. Bedelsiz hata yok
Hat başına bedelsiz eşik (A0 önerisi) **reddedildi**. Her açık hata ilk hatadan başlayarak küçük bir bedel öder.
Ekranda ve bedelde aynı sayı kullanılır: açık hata.

## 2. Akış (Karar 2 ve 11)
Formül bugünkü akıştır (`SupportSystem.reports_per_day`); yalnız değerler değişir ve bir terim silinir.
- Açık hataya bağlı terim silinir (`INFLOW_CARRIED_COEF`, 0,05 × açık hata). Hata yalnız kullanımdan ve yeni koddan doğar.
- `INFLOW_BASE` günde 0,2 → **0,1**; araştırılmış hâli 0,14 → **0,07**.
- `USAGE_DIV_B2B` 10 → **80**. Gerekçe: aynı hatayı çok hesap bildirir.
- `USAGE_DIV_B2C` 2000 → **10000**. A ayarlar; E pazaryeri kitlesini kurunca gözden geçirir.
- Yeni kod terimi ve altyapı çarpanı değişmez.
- Beklenen: B2B erken ≈ 1,4, geç ≈ 4 (320 hesapta ≈ 6); B2C erken ≈ 1,3, geç ≈ 3.

## 3. Düzeltme kartı eforu (Karar 7'nin değeri)
- **1–4 hata 1 puan, 5 ve üstü 2 puan.** Düzeltme kartı en küçük özellik kartından (k1 = 3) her zaman hafiftir. Erdem:
  "buglar feature kartları kadar fazla SP'ye sahip olmamalı".
- `sprint.json`'da tek ayar, ör. `fix_effort: {"steps": [4], "points": [1, 2]}`.

## 4. Öncelikli kart (bugünkü "Acil")
- **Eşik 5 açık hata.** Bot planlayıcının zorunlu listesi yalnız bunları alır.
- Etiketin yeni adı B'nin "acil durum"uyla karışmaz. Öneri: EN "Priority", TR "Öncelikli". TR/EN onay bekliyor.

## 5. Bedeller (Karar 9 ve 10)
- **B2B:** hesabın memnuniyet hedefi `− min(B2B_BUG_SAT_PER × b, B2B_BUG_SAT_CAP)`.
  - `b` = hesabın kullandığı hatlardaki açık hata (`SalesArchetypes.uses_axis`).
  - Başlangıç değerleri `B2B_BUG_SAT_PER` 0,3, `B2B_BUG_SAT_CAP` 20.
  - Onboarding tabanı cezadan sonra uygulanır. Var olan Risk → sayaç → ayrılma makinesi çalışır.
- **B2C:** kitle saatte `B2C_BUG_CHURN_COEF × min(açık hata, 40) × kitle` kadar erir. Eşik yoktur.
  - Katsayıyı K5 matristen **önce** analitik seçer.
  - Hedef: `fix_worst`'ün ek kaybı ≈ %5; `fix_none` en az `fix_off` × 2.
- **İtibar:**
  - Açık hata 4 haftalık tikte üst üste 30 ve üstündeyse o hafta itibar −1 olur. Koşul sürdükçe her hafta −1.
  - En düşük −10 (`GameState` sınırı). `max(0, …)` tabanı yoktur.
  - Düzenli düzelten oyuncu bu koşula girmez.
- Var olan Destek memnuniyet zararı kalır; açık hatayı okur.

## 6. İtibar sebebi iki yerde (Karar 10)
- **Destek kartının ipucu:** "Uzun süredir bekleyen hatalar itibarı düşürdü" türü bir satır.
- **TopBar'daki itibar değerinin ipucu:** son hata kaynaklı düşüşün sebebi.
- Metinler TR/EN onay bekliyor.

## 7. VC: ürün odaklı fonun geri dönüş koşulu
Erdem: "Eksen okuması ne alaka, şu anda oyunda eksen yok. Gerçek hayatta yatırımcı neye bakarsa ona göre yeni hesaplama
çalışmalı."

Seçim: **müşteri kaybı.** `bugs_under` yerine yeni bir tür gelir (ör. `churn_under`).
- **Koşul:** Geri dönüş verildikten sonraki 12 haftada kaybedilen müşteri oranı eşiğin altındadır.
  - Oran = pencerede kaybedilen müşteri ÷ pencere başındaki müşteri.
  - "Bir çeyreklik tutma verisi göster": pencere dolmadan koşul karşılanmaz.
- **B2B:** ayrılan hesap sayısı (churn olayları).
- **B2C:** pencerede churn ve aşınma terimleriyle (hata kaybı dahil) kaybedilen kullanıcı, kitleye oranla.
- **Eşik başlangıcı:** B2B %5 (aylık ≈ %1,7), B2C %15. Onay bekliyor.
- **Metin:** "En zayıf eksen" yoktur. Yeni anahtar, ör. `HUNT_CB_CHURN` (EN önce, TR/EN onay bekliyor).
- **Göç:** `_migrate_16`, kayıtta bekleyen `bugs_under` geri dönüşünü yeni türe çevirir. Pencere göç günü başlar.
  Kanıt: `save_v15_callback_bugs_under`.
- **Sınır:** `_weakest_dimension`'ın öbür okuyucuları (seed ve Series A sorguları) A'nın kapsamı dışında kalır.
  ACIK_KARARLAR 59'a yalnız not düşülür.

## 8. Bot kolları
- **`fix_worst`:** her sprintte en çok açık hatası olan hattın kartı (en az 1 hata).
- **`fix_due` ("düzeltilmesi gereken hat"):** sprint başında 2 ve üstü açık hatası olan her hat, artı öncelikli olanlar.
  B2B'de hattı en az bir aktif ya da deneme hesabı kullanır.
  - Gerekçe: 1 puan 4 hataya kadar yetiyor. Titiz oyuncu tek hatalı hat için puan harcamaz, ikinci hata gelince düzeltir.
- **`fix_none` ve `fix_off`:** PRD'deki gibi.

## 9. Hedefler (Karar 11 ve §4.4)
**Akış ve açık hata** (`fix_due` kolu):
| Ölçü | B2B erken | B2B geç | B2C erken | B2C geç |
|---|---|---|---|---|
| Haftada yeni hata (medyan) | ≤ 1,5 | ≤ 4 | ≤ 1,5 | ≤ 3 |
| Açık hata, sürüm anında | ≤ 4 | ≤ 8 | ≤ 4 | ≤ 8 |
| Açık hata, sprint sonu tepesi | ≤ 8 | ≤ 16 | ≤ 8 | ≤ 16 |

- Erken = v1.0'dan sonraki ilk 20 hafta.
- `fix_worst`'ün açık hatası bilgi olarak raporlanır, hedef değildir. Beklenen geç dönemde 10–20.

**Düzeltme payı:**
| | Geç | Erken |
|---|---|---|
| `fix_worst` medyan | ≤ %15 | ≤ %30 |
| `fix_due` medyan | ≤ %20 | ≤ %30 |
| `fix_due` hata sprinti oranı | ≤ %5 | ≤ %15 |
| Üst üste iki hata sprinti | 0 | ≤ %1 |

**Churn:** `fix_worst` kaybı ≤ `fix_off` + %10; `fix_none` kaybı ≥ 2 × `fix_off` (PRD).

## 10. Bilgi olarak kalanlar
- %40 hatalı kapanış zarı K1'den sonra da atılmaz (A2 §3).
- Oyuncu kurucuyu Destek'e atayamaz; A yalnız motor bağını kurar (A2 §5.3). Erdem itiraz etmedi.

## Erdem'in cevapları (birebir)
- Mekanizma: "bedelsiz hata olmamalı? ne alaka ama tabi buglar feature kartları kadar fazla spye sahip olmamalı"
- VC ölçeği: "eksen okuması ne alaka şu anda oyunda eksen yok ne eksen okuması gerçek hayatta yatırımcı neye bakarsa ona
  göre yeni hesağlama çalışmalı"
- B2C akışı: "A ayarlasın (Recommended)"
- İtibar sebebi: "İkisi de"
- VC ölçüsü: "Müşteri kaybı (Recommended)"
- Revize mekanizma (bedelsiz hata yok; kart en çok 2 puan, 1–4 → 1, 5+ → 2; öncelikli eşiği 5; akış ve hedefler; itibar
  4 hafta üst üste 30+ → −1): "Evet, bu (Recommended)"
