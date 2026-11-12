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
| H-002 | 2026-11-12, OLAYLAR (olay kartı tükenme ölçümü), a40b9c8e | Uzun süredir müşteri olan bir hesabın yenileme talebi oyuncuya hiç gelmiyor: talep masaya düşüyor, hafta biterken açılmadan kayboluyor. | Önce karesi yok, kart ekrana hiç gelmez; kanıt ölçüm: 25 B2B bot koşusunda (`full_run_staff1/3/6/12/25`, 104 hafta) kart kapıdan 556 kez geçti, 0 kez göründü; `full_run_staff6` tohum 1'de açılışta 33 kez G7 ile düştü. Sonra: `kareler/H-002/sonra.png` | 1. Bir B2B hesabı 44 haftadan uzun müşteri olsun, ona bir Müşteri İlişkileri temsilcisi baksın. 2. Hesabın talebi masadan oyuncuya çıksın (tür yenileme seçilir). 3. Mesai biter, gece başlar: kâğıt açılmaz, talep kaybolur. `--player-path=cs_renewal_request_reaches_player` düzeltmeden önce FAIL. | 2 | | kapandı | Bu satırla aynı commit; K2 `cs_renewal_request_reaches_player`; `kareler/H-002/sonra.png` |
| H-003 | 2026-11-12, OLAYLAR (olay kartı tükenme ölçümü), 60b369d8 | Aynı müşteri birkaç haftada bir yeniden özellik isteğiyle geliyor. | `kareler/H-003/once.png` (tekrar eden kart; ikinci talep kâğıdı aynı karttır) | 1. Bir B2B hesabına Müşteri İlişkileri temsilcisi baksın, talebi masadan oyuncuya çıksın ve cevaplansın. 2. Dört hafta sonra aynı hesabın yeni talebi masadan çıksın. 3. Gece ikinci talep kâğıdı açılır; kartın "hesap başına 26 haftada bir" kuralı işlemiyor. Ölçüm: `customer.request_feature` B2B'de koşu başına 85 gösterim (25 bot koşusu). `--player-path=cs_request_rule_holds_second_ask` düzeltmeden önce FAIL. | 2 | | kapandı | Bu satırla aynı commit; K2 `cs_request_rule_holds_second_ask`; sonra karesi yok (gelmeyen kart) |
