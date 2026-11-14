# Seçim ekranı dili (tur 4, ARAYUZ, 2026-11-13)

Öbür üç oturumun ekranlarına ortak dil önerisi. Kaynak: Erdem'in iki sözü ("her yerde çok fazla minik ekstra bilgi var",
"hiyerarşik düzen ... çok korkunç"), referans ekranlar (`TESLIM.md` §7) ve oyunun koyu Menajer dili (`UiTokens`,
`UiFactory`). Örnek kare `kareler/B1_katalog_dosya_iki_tur.png`; bugünkü ekran `00_once_bugunku_ekran.png`.
Üç oturumun notu (URUN, PAZARYERI, DUZELTME) ve eleştirmen turu işlendi.

## 1. Hiyerarşi: bir ekran, bir karar

- Bir seçim ekranı ya da pencere bir karar taşır. Masa sekmeleri (Satış, Ürün, Pazarlama) her satırda bir karar
  taşır; satırın ayrıntısı yalnız açılınca görünür.
- Ekranın başlığı kararın fiilidir ("Yolunu seç", "Kategoriyi aç"), `TitleH2` (30). Altında açıklama cümlesi yok.
- Üç katman, her katman bir boy:
  1. **Grup**, ör. listede pazar: `Eyebrow` (12, geniş büyük harf, soluk) + küçük glif.
  2. **Seçenek**: `OptionLabel` (20). Seçilenin adı ayrıntı alanında `DisplayName` (40).
  3. **Destek**: tek satır, `BodyMuted` (16) ya da `LeadText` (20, yalnız seçilenin cümlesi).
- Seçenekler pencerenin gövdesini doldurur. Ortada küçük kart, boş pencere yok (bugünkü tür ekranının hatası).
- Ayrıntı yalnız seçilenindir: sağda bir dosya ya da altta bir şerit. Seçilmeyenin ayrıntısı ekranda durmaz.

## 2. Tipografi merdiveni (UiTokens'tan; yeni boy yok)

| Ne | Varyasyon | Boy |
|---|---|---|
| Kararın başlığı | `TitleH2` | 30 |
| Seçilenin adı | `DisplayName` | 40 |
| Ekran iki büyük bölüme ayrılıyorsa bölümün başlığı | `CompanyTitle` | 26 |
| Seçeneğin adı | `OptionLabel` | 20 |
| Seçilenin tek cümlesi | `LeadText` | 20 |
| Bir olgunun değeri, dosyada mekanik adı | `ValueTextStrong` / `ValueText` | 18 |
| Destek satırı | `BodyMuted` | 16 |
| Bölüm etiketi (dosyada) | `KeySmall` (büyük harf) | 12 |
| Grup etiketi (listede) | `Eyebrow` (geniş büyük harf, soluk) | 12 |

Seçenek kartında en çok iki boy; seçilenin dosyasında en çok dört (40, 20, 18, 12). Sayı ve değer kalın; etiket soluk
ve küçük, yalnız bölüm başında.

## 3. Kart yoğunluğu

- Seçenek kartında üç şey olur: glif, ad, en çok bir satır. İkinci paragraf yok; tradeoff ve açıklama seçilenin
  dosyasına ya da ipucuna gider.
- Bir olgu glif ve kalın değerdir; olgunun adı ipucundadır (glif ve değer birlikte okunur). Olgu en çok iki tane.
- Seçimin bedeli iki satırdır: iyi tarafı ve zor tarafı, artı ve eksi glifiyle (ONI'nin asteroit seçimindeki artı ve
  eksi gibi). Sayı yok.
- Bu iki kural (olgunun adı ipucunda, bedelde sayı yok) bir kerelik seçim ekranı içindir. Yönetim sayfasında olgunun adı
  ekranda kalır ve koşu içi kararın bedeli sonucuyla ve sayısıyla yazılır ("Kategori kartı · 40 puan").
- Durumu biçim söyler, yazı değil. Seçili kartın zemini bir ton açılır, sol kenarında işaret durur (`PickCardSelected`,
  `D_mark`).
- Kilit iki türlüdür:
  - **Seçim ekranında** (tür seçimi gibi bir kerelik karar) henüz gelmeyen içerik gösterilmez (envanter kuralı:
    sürpriz bozma).
  - **Kalıcı ekranda** oyuncunun yarın açabileceği kilit satırında, gerekçesiyle durur; gerekçe kararın kendisidir
    ("Duyarlı Arayüz · 1★ Tasarım gerekli": kimi işe alacağın). Gerekçe satırda kısadır, ayrıntısı ipucundadır.
    Yalnız sıradaki kademe görünür, ötesi görünmez; kilidin neyi açacağı yazılmaz, yalnız şartı yazılır.
    Tıklanınca kilidin açıldığı yere gider (Ar-Ge düğümü, işe alım). Olay kartında da kilitli seçenek gerekçesiyle
    görünür (CLAUDE.md §5). Bu turda karesi yok; örnekleri URUN'un ve PAZARYERI'nin ekranlarında.
- Tek birincil eylem, sağ altta; etiketi fiildir ("Onayla ve başlat", "Kampanyayı kur"). Geri alınmayan ya da
  süreyle kilitlenen kararda yanında kilit glifi ve tek satır: "Sonradan değişmez", "Dört hafta değişmez".

## 4. İpucuna giden

- Tanım, kural, hesap ve geçmiş ipucundadır. Ekranda yalnız kararı değiştiren bilgi kalır.
- Bir mekanik adı (ör. "Kargo ve iade") çerçeveli bir kutudur. Seçilenin dosyasında değer boyundadır (18): ekranın vaadi
  orada, en küçük yazıya konmaz. Satır içinde küçük etiket olur. İpucu, o mekaniğin oyuncuya ne yaptırdığını tek satırla
  söyler.

## 5. Derinlik duygusu (Erdem'in §1b'si)

Seçilenin dosyası seçimin neyi açtığını gösterir:
- "Bu yolda yöneteceklerin": 4–5 mekanik, değer boyunda.
- İyi tarafı ve zor tarafı.
- "Frank'in çeki": yolun beş durağı, üst barın listesiyle aynı.

Oyuncu tek bakışta "bu yol beni şunlarla uğraştıracak" der. Ekran sayıyla değil, açılan masalarla derinlik vaat eder.

Metinler taslaktır: TR ve EN onay bekliyor.
