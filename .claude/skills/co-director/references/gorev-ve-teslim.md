# Adım tablosu, görev yazısı ve teslim şablonları

SKILL.md §2, §7 ve §9'un şablonları.

## 1. Adım tablosu örneği

İstek: "Rakip yönetim oyunlarında çalışan moralinin nasıl çalıştığını araştır, bize öneri getir."
Ne istemedi: kod yok, yeni ekran yok, sabit değişikliği yok.

| Adım | Ne | Kim | Model | Düşünme | Süre | Neden |
|---|---|---|---|---|---|---|
| 1 | Bugünkü moral kodunu ve GDD maddesini dök (dosya:satır) | alt ajan | Haiku | low | 10 dk | Önerinin neyi değiştirdiğini bilmek |
| 2 | 6 oyunun moral mekanik dökümü, 3'ü olumsuz yorumlu; Steam yorumları | 2 alt ajan | Sonnet | medium | 40 dk | Başarılı ve başarısızın farkı |
| 3 | Şüpheci doğrulama turu | ana | Opus | high | 15 dk | Kaynaksız iddia ve tek kaynak yükü |
| 4 | 2-3 seçenek, oynanış ve ölçek merceği, pre-mortem | ana | Opus | high | 20 dk | Karar kartı |
| 5 | Kısa rapor sayfası, ilk ekranda karar kartı | ana | Opus | medium | 15 dk | Erdem'in okuyacağı yer |

Bütçe: WebSearch ~30 (başarısız izi en az 8). İnceleme: belge işi, ayrı inceleme yok.

Kurallar: "Süre" gerçekçi tahmin; "Neden" o adımın hangi karara hizmet ettiği. Tabloda yer almayan adım
onaylanmış sayılmaz.

## 2. Alt ajan görev yazısı

```
Amaç: <hangi kararı ya da oyuncu sonucunu besliyor, tek cümle>
Bağlam: <okuması gereken en az dosya; yollar tam>
Yap: <adımlar>
Yapma: <kapsam dışı; dokunulmayacak dosyalar; kirli dosyalar (başka oturumun)>
Oyuncunun göreceği: <ekran / metin / his> ya da "oyuncu bir şey görmez"
Beklenen sonuç: <dosya yolu ve biçim> ya da <son mesajın biçimi>
Kabul ölçütü: <kapı adı, ekran görüntüsü, sayı, tablo dolu>
Bağımlılık: <önce bitmesi gereken iş; paralel koşan ajanlar ve dokundukları dosyalar>
Bütçe: <WebSearch sayısı, süre>; her hükümde `searches` (sayı) ve `evidence` (URL ya da "sonuç yok")
Model / düşünme: <Haiku|Sonnet|Opus> / <low|medium|high|xhigh|max>
Bildirim: bulamadığını "bulunamadı" yaz; tahmini olgu gibi yazma; başarı iddiasına kanıt ekle
```

Araştırma ajanına ayrıca `references/arastirma.md` yolu ve ona ayrılan kaynak numarası bloğu verilir.

Kod ajanına ayrıca: hangi smoke önekleri koşulacak, görsel kabul senaryosu, commit mesajında taşınacak
"onay bekliyor" işaretleri.

## 3. İnceleme görev yazısı (commit başına en çok bir)

```
Yalnız şu diff'i oku: <komut ya da dosya>.
Soru: bu kod en kısa ve en açık doğru hâlinde mi? Hata var mı?
Çıktı: bulgu listesi (dosya:satır, sorun, önerilen düzeltme), en ciddisi başta. Bulgu yoksa "bulgu yok".
İkinci tur yok; düzeltme bir tur, sonra commit ya da ❌ ile rapor.
```

Gelen incelemeye körü körüne uyulmaz: bulgu kodda doğrulanır; yanlışsa teknik gerekçeyle reddedilir.

## 4. Teslim mesajı

```
<Tek satır sonuç>

<Görsel ya da tek tablo: ekran görüntüsü, önce/sonra, karar kartı>

✅ <madde>: <kanıt: dosya:satır / commit / kapı / ekran>
⚠️ <madde>: <neden yarım, ne gerekiyor>
❌ <madde>: <ne olmadı, kanıtı, önerilen yol>

Onay bekleyen: <sabitler, TR/EN metinler>
Erdem'e karar: <K kartları ya da "yok">

Ne idi: ...
Ne değişti: ...
Şimdi: ...
```

Kurallar:
- İlk ekran yeter olmalı; ayrıntı ek dosyada ya da artifact sayfasında.
- Her ✅ bu oturumda yeni koşulmuş bir kanıta dayanır; önceki koşu ya da ajanın sözü yetmez.
- Kat 2 (Erdem'in oynayıp kabul etmesi) gerekiyorsa açıkça "Kat 2 bekliyor: şu dilimi oyna" yazılır.

## 5. Görsel aday teslimi (teknik görsel iş)

| Aday | Ne yapar (tek cümle) | 13:00 önce / sonra | 22:00 önce / sonra | Maliyet (bu makinede ms) | Önerim |
|---|---|---|---|---|---|

Aynı kamera, aday başına tek çift. Görünürlük hükmü gerekiyorsa kör bir hakeme de bakılır.
