# Hata defteri

Oyuncunun gördüğü her hata burada bir satırdır. Defter kalıcıdır: satır silinmez, kapanır. Karar: Erdem, 2026-11-11 (K17)
ve 2026-11-12 (N09, model C). Biçimi bu dosya tanımlar; satırlar aşağıdaki tabloya girer, kareler `kareler/<kimlik>/`'e.

## Kim ne yapar

- **Deftere yazan:** hatayı bulan. Erdem'in playtest'i, QA turu ya da bir oturum.
- **Önceliği koyan:** yalnız Erdem, "Karar" sütunuyla. Önemi QA önerir, öncelik ayrı şeydir.
- **Dağıtan:** yardımcı yönetmen. "Şimdi düzelt" satırlarını oturumlara verir.
- **Düzelten:** bir oturum. Düzeltmeyle aynı commit'e bir K2 oyuncu yolu vakası koyar. Düzeltme geri alınınca bu vaka
  kırmızıya döner. Vaka `tools/test.sh hizli`'de kalır.
- **QA turu:** yalnız push'tan ve dönüm noktasından önce açılır. İlk tur bir sonraki push'tan önce koşar. Turu kimin
  koşacağını yardımcı yönetmen ayarlar.

## Bir satırın sütunları

| Sütun | Ne yazılır |
|---|---|
| Kimlik | `H-001`, `H-002` … sırayla. Kimlik bir kez verilir, başka satıra geçmez. |
| Bulundu | Tarih, kaynak (playtest, QA turu ya da oturum adı) ve hatanın görüldüğü commit. |
| Oyuncu ne görür | Tek cümle, oyuncunun dilinde ("Satış görüşmesinin düğmesi saat ilerlediği hâlde eski durumunda kalıyor"). Kod adı yok. |
| Kare | `kareler/<kimlik>/once.png`, oyunun kendi karesi (1920, TR ya da EN). Kare yoksa satır açılmaz. |
| Nasıl tekrarlanır | Numaralı adımlar. Debug bayrağı varsa onu da yaz (`--sales-shot=morning` gibi). |
| Önem (QA önerir) | 1–4, aşağıdaki basamaklardan biri. |
| Karar (Erdem) | **Şimdi düzelt** · **Sonraya** · **Düzeltme** (bilerek böyle). Boşsa satır Erdem'i bekler. |
| Durum | `açık` → `dağıtıldı: <oturum>` → `kapandı`. "Düzeltme" kararıyla kapanan satır `kapandı (bilerek)` olur. |
| Kapanış | Düzeltmenin commit'i, hatayı koruyan K2 vakasının adı ve `kareler/<kimlik>/sonra.png`. |

## Önem basamakları

| Basamak | Ad | Ne demek | Bizden örnek |
|---|---|---|---|
| 1 | Oyun durur | Çökme, donma ya da oyuncunun ilerleyememesi. | — |
| 2 | Yanlış sonuç | Oyun çalışıyor ama yanlış şey oluyor ya da yanlış şey söylüyor. | Saat ilerlediği hâlde satış görüşmesinin düğmesi eski durumda kalıyordu (playtest #15). |
| 3 | Okunmuyor | Doğru bilgi var ama oyuncu okuyamıyor: taşan, kesilen, üst üste binen metin. | Kadro'da uzun metin taşıyordu (D-4). |
| 4 | Görünüş | Bilgi doğru ve okunuyor ama kötü duruyor. | Ofisteki kahve ikonu 27 px'te leke gibi duruyordu (D-5d). |

Bir hata iki basamağa uyuyorsa küçük numaralı olan, yani daha ağır olan yazılır.

## Kurallar

- Bir satır, tek bir hata. Aynı ekranda iki hata görülürse iki satır açılır.
- Satır açarken önce tabloda aynı hatayı ara. Aynısı varsa yeni satır açılmaz; "Bulundu" sütununa yeni görülüş eklenir.
- Kapanan satırın hatası geri dönerse satır yeniden açılır (`açık`). Kapanış sütunundaki K2 vakası neden yakalamadığıyla
  birlikte yazılır.
- Defterin sayfası (Erdem'in düğmeleri, kareler yan yana) bu dosyadan üretilir. Sayfada verilen karar bu tabloya geri
  yazılır. İkisi çelişirse bu dosya geçerlidir.

## Defter

| Kimlik | Bulundu | Oyuncu ne görür | Kare | Nasıl tekrarlanır | Önem | Karar | Durum | Kapanış |
|---|---|---|---|---|---|---|---|---|
| H-001 | 2026-11-12, OLAYLAR (ayrılık çipinin kod incelemesi), e45b7054 | Gerçek lider huylu çalışanın morali biri istifa edince 10, biri işten çıkarılınca 5 düşüyor; huyu ayrılıkları ağır aldığını söylüyor. | `kareler/H-001/once.png` (istifa kartının çipi; işten çıkarmanın farkı karede görünmez, adımlarda) | 1. Ekipte Gerçek lider huylu bir çalışan ve iki çalışan daha olsun. 2. Birini Ekip'ten işten çıkar: Gerçek liderin morali 5 düşer. 3. Öbürü istifa etsin (`--event-shot=team.resignation` kartı): Gerçek liderin morali 10 düşer. Kodda `HRActions.fire` huyun `departure_morale_extra` ekini uygulamıyor, `HRMoraleSystem._charge_departure` uyguluyor. | 2 | | açık | |
