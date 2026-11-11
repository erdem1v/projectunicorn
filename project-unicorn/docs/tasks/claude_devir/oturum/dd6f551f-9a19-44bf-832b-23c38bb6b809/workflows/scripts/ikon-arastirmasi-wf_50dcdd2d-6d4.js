export const meta = {
  name: 'ikon-arastirmasi',
  description: 'Icon research: games + SaaS + conventions + criticised examples for 4 product modules, with screenshots and independent verification',
  phases: [
    { title: 'Topla', detail: '5 collectors, each a different modality, screenshots downloaded and viewed' },
    { title: 'Doğrula', detail: 'one skeptic per collector re-opens every screenshot and URL' },
  ],
}

const S = args.S
const IMG = S + '/research/img'

const CONTEXT = `
BAĞLAM (oku, tekrar araştırma): Project Unicorn, Godot'da TR/EN bir startup yönetim oyunu. Ürün penceresinin sprint ekranında sol
sütunda "MODÜLLER" listesi var. Her modülün bugünkü iki harfli kısaltması (ÇK, İK, EN, GÜ, BÜ, GE) yerine 24 px'lik bir kutuda 16 px'lik
DÜZ DOLGULU BEYAZ bir ikon gelecek; zemin koyu kömür rengi. Oyuncu modülü adını okumadan, ilk bakışta ikondan tanımalı.
Modüller ve oyunda neyi kapsadıkları:
- Çekirdek (Core): ürünün kendisi. ONAYLI ikon: küp. Araştırma dışı.
- Güven & Ölçek (Trust & Scale): güvenlik + dayanıklılık. ONAYLI ikon: kalkan. Araştırma dışı.
- İlk Kullanım ve Erişim (Onboarding & Access), B2B ve B2C: hatları "Mobil uygulama" ve "Yardım Merkezi" (help center); kullanıcının ürüne
  ilk girişi, ilk kullanım, erişim. REDDEDİLDİ: mezuniyet şapkası.
- Entegrasyonlar (Integrations), yalnız B2B (ERP yazılımı): API, webhook, başka araçlara bağlanma. REDDEDİLDİ: komut satırı penceresi (>_).
- Büyüme (Growth), yalnız B2C: kitle büyümesi, paylaşma, davet, edinim. REDDEDİLDİ: daire içinde yukarı ok.
- Gelir (Revenue), yalnız B2C: ücretli plan, abonelik, ödeme. REDDEDİLDİ: fiyat etiketi.

SORU: Bu dört kavram (onboarding, integrations, growth, revenue) için (a) yönetim/şirket/tycoon oyunları ve (b) gerçek SaaS panoları hangi
ikon metaforlarını kullanıyor? Hangileri okunuyor, hangileri okunmuyor ya da eleştiriliyor? Bu araştırma Erdem'in (oyunun sahibi) ikon
seçimini besler.

KURALLAR:
1. Kaynak = gerçek ekran görüntüsü. Her kaynak için en az bir görüntüyü indir ve Read aracıyla AÇIP BAK. Görüntü yoksa ya da ikon
   görüntüde seçilemiyorsa o kaynak sayılmaz. Metin özeti araştırma değildir. Uydurma yok; bulamazsan "bulunamadı" yaz.
2. İndirme: curl -sL -m 30 -A "Mozilla/5.0" -o "${IMG}/<ID>_<kısa-ad>.<uzantı>" "<url>". Yalnız görüntü indir (jpg/png/webp/gif);
   indirdiğin hiçbir şeyi çalıştırma. 'file' ile türünü denetle (HTML gelirse sil). webp ya da gif ise
   'sips -s format png <dosya> --out <aynı ad>.png' ile PNG'ye çevir ve PNG'yi aç. Görüntünün boyutunu
   'sips -g pixelWidth -g pixelHeight <dosya>' ile oku.
3. Steam mağaza görüntüleri: https://store.steampowered.com/api/appdetails?appids=<appid>&filters=screenshots (path_full 1920x1080).
   Steam yorumları: https://store.steampowered.com/appreviews/<appid>?json=1&filter=all&language=english&review_type=negative&num_per_page=100
   (yorum metninde "icon" geçenleri ara: curl ile al, python3 ile süz). Wiki, yapımcı sitesi, belge sayfası görüntüleri de olur.
4. Her kaynak için ikonun ve yanındaki etiketin bulunduğu bölgeyi orijinal görüntü pikseliyle ver (crop: x,y,w,h). Bölge ikonu ve
   etiketini içermeli; en az 120x60 px olsun ki 2x büyütünce okunsun. Bölgeyi doğrulamak için kırpıp bakabilirsin:
   'sips --cropToHeightWidth <h> <w> --cropOffset <y> <x> <dosya> --out <geçici.png>' sonra Read. (sips cropOffset önce y sonra x alır.)
5. Kaynak sicili: her kaynağa sana ayrılan bloktan bir ID (değişmez), URL, yayıncı, yayın tarihi (bilinmiyorsa "bilinmiyor"), erişim
   2026-10-28, güven (Yüksek: oyunun/ürünün kendi sayfası ya da belgesi, Steam'in kendi verisi, hakemli çalışma; Orta: tanınmış basın,
   yöntemini yazan analiz, wiki; Düşük: tek blog, forum anekdotu, satıcının kendini anlatması).
6. 'finding' ve 'criticism' alanlarını Türkçe yaz; oyuncu ya da yazar sözünü harfi harfine (orijinal dilde) alıntıla.
7. Görüntüde gerçekten gördüğünü yaz; ikonun neyi çizdiğini (ör. "yapboz parçası", "fiş", "yukarı giden çizgi grafiği") somut söyle.
8. WebSearch bütçen en çok 10 arama. Kaç arama yaptığını 'searches' alanına yaz. Sayfa okumak için WebFetch kullan.
9. Yalnız kendi ID bloğunu kullan. Dosyaları yalnız ${IMG} altına yaz.
`

const SOURCE = {
  type: 'object',
  properties: {
    id: { type: 'string' },
    title: { type: 'string' },
    url: { type: 'string' },
    publisher: { type: 'string' },
    published: { type: 'string' },
    accessed: { type: 'string' },
    trust: { type: 'string', enum: ['Yüksek', 'Orta', 'Düşük'] },
    kind: { type: 'string', enum: ['oyun', 'saas', 'kutuphane', 'elestiri'] },
    subject: { type: 'string', description: 'game or product name' },
    concepts: { type: 'array', items: { type: 'string', enum: ['onboarding', 'integrations', 'growth', 'revenue', 'genel'] } },
    icon_desc: { type: 'string', description: 'what the icon depicts, concretely' },
    label_shown: { type: 'string', description: 'text label next to the icon, or "etiketsiz"' },
    screenshot_url: { type: 'string' },
    local_file: { type: 'string', description: 'absolute path of the downloaded image you opened with Read (PNG if converted)' },
    img_w: { type: 'integer' },
    img_h: { type: 'integer' },
    crop: { type: 'object', properties: { x: { type: 'integer' }, y: { type: 'integer' }, w: { type: 'integer' }, h: { type: 'integer' } }, required: ['x', 'y', 'w', 'h'] },
    viewed: { type: 'boolean', description: 'true only if you opened the image with Read and saw the icon' },
    readable: { type: 'string', enum: ['okunuyor', 'okunmuyor', 'karisik', 'bilinmiyor'] },
    finding: { type: 'string' },
    criticism: { type: 'string', description: 'quoted criticism with its URL, or empty' },
  },
  required: ['id', 'title', 'url', 'publisher', 'published', 'accessed', 'trust', 'kind', 'subject', 'concepts', 'icon_desc', 'label_shown', 'screenshot_url', 'local_file', 'crop', 'viewed', 'readable', 'finding', 'criticism'],
}

const OUT = {
  type: 'object',
  properties: {
    sources: { type: 'array', items: SOURCE },
    not_found: { type: 'array', items: { type: 'string' }, description: 'what you looked for and did not find, with the queries tried' },
    searches: { type: 'integer' },
    notes: { type: 'string' },
  },
  required: ['sources', 'not_found', 'searches', 'notes'],
}

const COLLECTORS = [
  {
    key: 'oyun-a', block: 'S1-S9',
    task: `Oyunlar A: Startup Company (Hovgaard Games, Steam appid 618140) ve Software Inc. (Coredumping, appid 362620). Bu oyunlarda
ürün özellikleri/bileşenleri, pazarlama/büyüme, gelir/abonelik, API/entegrasyon, kullanıcı/onboarding gibi kavramlar için kullanılan
ikonları ekran görüntülerinde bul. Steam mağaza görüntüleri, resmi wiki (startupcompany.fandom.com, softwareinc.coredumping.com/wiki),
geliştirici blogu. Oyun bu kavramlar için ikon kullanmıyorsa (yalnız metin) bunu da bulgu olarak yaz. Her oyundan 2-3 kaynak hedefle.
Steam yorumlarında ikon ya da arayüz okunurluğu şikâyeti varsa harfi harfine alıntıla (olumsuz yorumlar).`,
  },
  {
    key: 'oyun-b', block: 'S10-S19',
    task: `Oyunlar B: Big Ambitions (Hovgaard, appid 1331550), Game Dev Tycoon (Greenheart, appid 239820), Startup Panic (appid 1196430),
gerekirse Mad Games Tycoon 2 (appid 1342330). Bu oyunlarda gelir, büyüme/pazarlama, müşteri/onboarding, bağlantı/entegrasyon benzeri
kavramlar için kullanılan ikonları ekran görüntülerinde bul. Oyun bu kavramlar için ikon kullanmıyorsa bunu da yaz. Her oyundan 1-3 kaynak.
Steam yorumlarında ikon ya da arayüz okunurluğu şikâyeti varsa harfi harfine alıntıla.`,
  },
  {
    key: 'saas', block: 'S20-S29',
    task: `Gerçek SaaS panoları: Stripe Dashboard (gelir, abonelik, faturalama menüsü ikonları), Intercom (onboarding / product tours /
help center), HubSpot, Zapier ya da Slack/Notion/Linear'ın "Integrations"/"Apps" bölümü, Shopify admin, Mixpanel ya da Amplitude
("Growth"), Paddle/Chargebee. Kendi belge sayfalarındaki (docs) gerçek arayüz ekran görüntülerini kullan; menüde ikonun ve etiketin
göründüğü görüntüleri seç. Hedef: dört kavramın her biri için en az iki ürünün gerçek ikonunu görmek. Pazarlama illüstrasyonu değil,
ürünün kendi arayüzü olsun.`,
  },
  {
    key: 'gelenek', block: 'S30-S39',
    task: `İkon kütüphanelerinin gelenekleri: Lucide (lucide.dev), Google Material Symbols (fonts.google.com/icons), Font Awesome, Phosphor,
Apple SF Symbols. Dört kavram için kütüphanelerin hangi ikonları hangi adla sunduğunu ve hangi etiketlerle (tags/keywords) eşlediğini bul:
ör. "integrations" için plug / puzzle / blocks / link / webhook; "growth" için trending-up / sprout / rocket / users; "revenue" için
banknote / coins / wallet / circle-dollar-sign / receipt; "onboarding" için door-open / log-in / rocket / hand / smartphone / life-buoy.
Her kütüphane için arama sayfasının ya da ikon sayfasının ekran görüntüsü (görüntü dosyası olarak indirilebilen bir önizleme, ör.
lucide.dev ikon SVG'si unpkg.com/lucide-static@1.63.0/icons/<ad>.svg; SVG'yi 'qlmanage -t -s 256 -o <klasör> <svg>' ile PNG'ye çevirip
bak; Material için fonts.gstatic.com ikon PNG'leri). Ayrıca Lucide ve Material'ın bu ikonlar için yazdığı etiket listelerini (tags) kaynakla.
Bu kaynaklar "gerçek kullanım" değil "gelenek" kanıtıdır; öyle işaretle (kind=kutuphane).`,
  },
  {
    key: 'elestiri', block: 'S40-S49',
    task: `Okunmayan ya da eleştirilen ikon örnekleri (başarısızlar izi; ayrı sorgularla ara): Nielsen Norman Group'un ikon kullanılabilirliği
araştırmaları (ör. "Icon Usability", "ambiguous icons", "universal icons" — etiketsiz ikonların tanınma sorunu), Google'ın 2020 Workspace
ikonlarına gelen "ayırt edilemiyor" eleştirisi, Chrome uzantı (yapboz) ikonu tartışması, "hamburger menu" tanınırlık çalışmaları,
yönetim/tycoon oyunlarında ikon okunurluğu şikâyetleri (Steam olumsuz yorumları, Reddit, forum). Özellikle aradığımız: yukarı ok (upload
ile karışır mı?), fiyat etiketi (indirim/etiketle karışır mı?), mezuniyet şapkası, komut satırı ikonlarının yanlış okunduğu örnekler; ve
yapboz/fiş/çizgi grafik/para ikonlarının okunurluğuna dair bulgular. Her kaynakta tartışılan ikonun görüldüğü bir görüntü indir
(makalenin kendi görseli olur). Kaynağın ana iddiasını harfi harfine alıntıla.`,
  },
]

const VERDICT = {
  type: 'object',
  properties: {
    checks: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          verdict: { type: 'string', enum: ['dogrulandi', 'duzeltildi', 'yanlis', 'dogrulanamadi'] },
          icon_desc_check: { type: 'string', description: 'what YOU see in the crop region' },
          crop_ok: { type: 'boolean' },
          crop_fix: { type: 'object', properties: { x: { type: 'integer' }, y: { type: 'integer' }, w: { type: 'integer' }, h: { type: 'integer' } } },
          url_ok: { type: 'boolean' },
          note: { type: 'string' },
        },
        required: ['id', 'verdict', 'icon_desc_check', 'crop_ok', 'url_ok', 'note'],
      },
    },
  },
  required: ['checks'],
}

phase('Topla')
const results = await pipeline(
  COLLECTORS,
  c => agent(`${CONTEXT}\n\nSENİN İZİN (${c.key}), ID bloğun ${c.block}:\n${c.task}`, { label: `topla:${c.key}`, phase: 'Topla', schema: OUT }),
  (r, c) => {
    if (!r || !r.sources.length) return { key: c.key, collected: r, checks: [] }
    return agent(`Şüpheci doğrulayıcısın. Bir araştırma ajanının ikon kaynaklarını doğrula; varsayılan tutumun "yanlış olabilir".
Bağlam: oyun içi modül ikonları için referans toplandı; her kaynak bir ekran görüntüsü ve ikonun bölgesini (crop) iddia ediyor.
Her kaynak için:
1. local_file'ı Read ile aç. Dosya yoksa ya da görüntü değilse: yanlis.
2. Crop bölgesini kes ve bak: sips --cropToHeightWidth <h> <w> --cropOffset <y> <x> <local_file> --out ${S}/research/verify_<id>.png
   (sips önce y sonra x alır), sonra Read. Bölgede iddia edilen ikon ve etiketi görüyor musun? Ne görüyorsan icon_desc_check'e yaz.
   Bölge yanlışsa görüntünün tamamına bakıp doğru bölgeyi crop_fix olarak ver (ikon + etiket, en az 120x60) ve verdict=duzeltildi.
3. url'yi WebFetch ile aç: kaynak var mı ve görüntü ya da iddia oradan mı geliyor? (Steam API ve görüntü CDN'leri için 'url_ok' görüntünün
   indirilebilmesine bakar.) Açılamıyorsa url_ok=false.
4. 'finding' ve 'criticism' alıntıları kaynakta gerçekten var mı? Yoksa note'a yaz.
WebSearch kullanma. Kaynaklar (JSON):\n${JSON.stringify(r.sources, null, 1)}`, { label: `dogrula:${c.key}`, phase: 'Doğrula', schema: VERDICT })
      .then(v => ({ key: c.key, collected: r, checks: v ? v.checks : [] }))
  },
)
return results.filter(Boolean)
